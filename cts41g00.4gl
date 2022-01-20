#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cts41g00.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 202363                                              #
#                Trata cotas para serviço imediato                    #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 28/08/2006                                         #
#                                                                     #
# Objetivo: Funcoes de "controle" para verificar se existe veiculo    #
#           disponivel para atender o servico imediato                #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint

#-----------------------------------------------------#
function cts41g00_prepare()
#-----------------------------------------------------#

   define l_sql    char(200)

   let l_sql = " select socntzgrpcod ",
               " from datksocntz     ",
               " where socntzcod = ? "
   prepare p_cts41g00_001 from l_sql
   declare c_cts41g00_001 cursor for p_cts41g00_001

   let m_prepare = true

end function


#-----------------------------------------------------#
function cts41g00_obtem_veic_para_acionar(param)
#-----------------------------------------------------#
    define param record
          cidcod       like datrcidsed.cidcod,
          atdsrvorg    like datmservico.atdsrvorg,
          socntzcod    like datmsrvre.socntzcod,
          data         char (10),
          hora         char (05),
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt,
          atmacnprtcod like datkatmacnprt.atmacnprtcod,
          acnlmttmp    like datkatmacnprt.acnlmttmp,
          ciaempcod    like datmservico.ciaempcod
    end record

    define l_socvclcod  like datkveiculo.socvclcod
    define l_ctc59m03   smallint

    let l_socvclcod = null
    let l_ctc59m03 = false

    #se endereço não está indexado, não tem como buscar prestador
    if  param.lclltt is null or
        param.lcllgt is null then

        if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
           display  "Sem Coordenadas: ", g_documento.succod, "/",
                    g_documento.aplnumdig, "/", g_documento.itmnumdig
        end if
        return l_socvclcod, l_ctc59m03
    end if

    call ctc59m03_quota_imediato ( param.cidcod,
                                   param.atdsrvorg,
                                   param.socntzcod,
                                   param.data,
                                   param.hora)
         returning l_ctc59m03

    call cts41g00_busca_veiculo_disponivel(param.cidcod,
                                           param.lclltt,
                                           param.lcllgt,
                                           param.atdsrvorg,
                                           param.hora,
                                           param.atmacnprtcod,
                                           param.acnlmttmp,
                                           param.socntzcod,
                                           param.ciaempcod)
         returning l_socvclcod

    #retornar código do veículo caso encontre veículo disponível
    # e aviso se existe cota disponível para este horário ou não
    return l_socvclcod,
           l_ctc59m03

end function    ##cts41g00_obtem_veic_para_acionar

#-----------------------------------------------------#
function cts41g00_busca_veiculo_disponivel(param)
#-----------------------------------------------------#
    define param record
          cidcod       like datrcidsed.cidcod,
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt,
          atdsrvorg    like datmservico.atdsrvorg,
          hora         char (05),
          atmacnprtcod like datkatmacnprt.atmacnprtcod,
          acnlmttmp    like datkatmacnprt.acnlmttmp,
          socntzcod    like datksocntz.socntzcod,
          ciaempcod    like datmservico.ciaempcod
    end record

    define d_cts41g00 record
          result       smallint,
          mensagem     char(100),
          cidcod       like glakcid.cidcod,     #codigo da cidade origem
          cidsedcod    like glakcid.cidcod,     #codigo da cidade sede da cidade origem
          cidsednom    like glakcid.cidnom,     #nome da cidade sede
          cidseduf     like glakcid.ufdcod,     #uf da cidade sede
          cidacndst    like datracncid.cidacndst,   #distancia parametrizada
          acntntlmtqtd like datkatmacnprt.acntntlmtqtd,  #utilizado apenas para retorno de funcoes
          netacnflg    like datkatmacnprt.netacnflg,     #utilizado apenas para retorno de funcoes
          socntzgrpcod like datksocntz.socntzgrpcod      #grupo de naturezas
    end record

    define veiculo record
         msg_motivo like datmservico.acnnaomtv,     #utilizado apenas para retorno de funcoes
         srrcoddig  like dattfrotalocal.srrcoddig,  #utilizado apenas para retorno de funcoes
         socvclcod  like datkveiculo.socvclcod,
         pstcoddig  like datkveiculo.pstcoddig,     #utilizado apenas para retorno de funcoes
         distancia  decimal(8,4),                   #utilizado apenas para retorno de funcoes
         lclltt     like datmfrtpos.lclltt,         #utilizado apenas para retorno de funcoes
         lcllgt     like datmfrtpos.lcllgt,         #utilizado apenas para retorno de funcoes
         tempo_total decimal(6,1),                  #utilizado apenas para retorno de funcoes
         qtd_srr_possiveis smallint
    end record

    define retorno record
          socvclcod  like datkveiculo.socvclcod
    end record

    define l_hora_cheia   char (05),
           l_hora_limite  char(05),
           l_aux_hora     datetime hour to minute,
           l_aux_data     date,
           l_qtde_servico smallint,
           l_aux_qtde     smallint

    initialize d_cts41g00.* to null
    initialize veiculo.* to null
    initialize retorno.* to null
    let l_hora_cheia   = null
    let l_hora_limite  = null
    let l_aux_hora     = null
    let l_aux_data     = null
    let l_qtde_servico = 0
    let l_aux_qtde     = 0

    if m_prepare <> true then
       call cts41g00_prepare()
    end if

    #obter código da cidade sede
    call ctd01g00_obter_cidsedcod(1, param.cidcod)
         returning d_cts41g00.result,
                   d_cts41g00.mensagem,
                   d_cts41g00.cidsedcod

    if d_cts41g00.result <> 1 then
       if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
          display "Nao obteve codigo da cidade sede para ", param.cidcod
       end if
       return retorno.socvclcod
    end if

    #obter nome e uf da cidade sede
    call cty10g00_cidade_uf (d_cts41g00.cidsedcod)
         returning d_cts41g00.result,
                   d_cts41g00.mensagem,
                   d_cts41g00.cidsednom,
                   d_cts41g00.cidseduf

    #se nao encontrou cidade e uf da cidade sede, não tem como buscar prestado
    if d_cts41g00.result <> 1 then
       if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
          display "Nao encontrou cidade cadastrada para: ",
                  d_cts41g00.cidsedcod
       end if
       return retorno.socvclcod
    end if

    ## OBTEM DISTANCIA PARAMETRIZADA NA CIDADE SEDE - PSI 202363
    call cts40g00_obter_distancia(param.atmacnprtcod,
                                  d_cts41g00.cidsedcod)
         returning d_cts41g00.result,
                   d_cts41g00.mensagem,
                   d_cts41g00.cidacndst

    if d_cts41g00.cidacndst is null then
       if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
          display "Distancia nao parametrizada ",
                  param.atmacnprtcod,' ', d_cts41g00.cidsedcod
       end if
       return retorno.socvclcod
    end if

    #calcular hora cheia
    let l_hora_cheia = param.hora[1,2] , ":00"

    #buscar veículo em QRV que atenda a natureza do serviço
    # dentro da distancia limite do acionamento e que não esteja bloqueado

    call cts40g05_obter_veiculo(param.lclltt,            #latitude do servico
                                param.lcllgt,            #longitude do servico
                                d_cts41g00.cidacndst,    #distancia limite de acionamento
                                d_cts41g00.cidsedcod,    #nome cidade sede
                                d_cts41g00.cidseduf,     #uf cidade sede
                                "",                      #numero servico
                                "",                      #ano servico
                                l_hora_cheia,            #hora
                                param.ciaempcod)         #empresa
         returning d_cts41g00.result,
                   veiculo.msg_motivo,
                   veiculo.srrcoddig ,
                   veiculo.socvclcod ,
                   veiculo.pstcoddig ,
                   veiculo.distancia ,
                   veiculo.lclltt    ,
                   veiculo.lcllgt    ,
                   veiculo.tempo_total,
                   veiculo.qtd_srr_possiveis

    let  retorno.socvclcod = veiculo.socvclcod
    #se nao encontrou veículo disponível que atenda o servico, retorna
    if retorno.socvclcod is null then
       return retorno.socvclcod
    end if

    if veiculo.distancia is null or veiculo.distancia = 0 then
       if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
          display 'Distancia nula/zerada ', veiculo.socvclcod,'/',
                                            veiculo.lclltt,'/',
                                            veiculo.lcllgt,'/'
       end if
    end if

    #buscar serviços não acionados para a próxima hora e com distancia até
    # o dobro do limite parametrizado para acionamento com o mesmo grupo de
    # natureza

    #calcular distancia - o dobro do limite parametrizado para acionamento
    ###let d_cts41g00.cidacndst = d_cts41g00.cidacndst * 2 #ligia 12/12/06

    #calcular proximo hora
    let l_hora_limite = cts41g02_hora_limite_servico(param.acnlmttmp)

    #busca data
    call cts40g03_data_hora_banco(2) returning l_aux_data, l_aux_hora

    open c_cts41g00_001 using param.socntzcod
    fetch c_cts41g00_001 into d_cts41g00.socntzgrpcod
    close c_cts41g00_001

    #se proxima hora menor que hora atual - mudança de dia
    if l_hora_limite < l_hora_cheia then

        #entao somar quantidade de servicos para o dia de hoje até 23:59
        call cts41g02_obter_qtd_srv(param.lclltt,            #latitude do servico
                                        param.lcllgt,            #longitude do servico
                                        d_cts41g00.cidacndst,    #distancia parametrizada
                                        d_cts41g00.socntzgrpcod, #grupo de natureza
                                        l_aux_data,              #data
                                        "23:59" )                #hora limite (maxima)
              returning l_aux_qtde

        if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
           display 'Mudanca de dia ', l_hora_limite, ' ', l_hora_cheia
           display 'Qtd servicos contados ', l_aux_qtde
        end if


         #acumular em l_qtde_servico
         let l_qtde_servico = l_qtde_servico + l_aux_qtde

         #mudar data para próximo dia
         let l_aux_data = (l_aux_data + 1 units day)
    end if

    call cts41g02_obter_qtd_srv(param.lclltt,            #latitude do servico
                                    param.lcllgt,            #longitude do servico
                                    d_cts41g00.cidacndst,    #distancia parametrizada
                                    d_cts41g00.socntzgrpcod, #grupo de natureza
                                    l_aux_data,              #data
                                    l_hora_limite )          #hora limite (maxima)
              returning l_aux_qtde

    #acumular em l_qtde_servico
    let l_qtde_servico = l_qtde_servico + l_aux_qtde

        if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
           display 'Servicos contados ate as ', l_hora_limite
           display 'Qtd servicos contados  ', l_aux_qtde
        end if

    #se encontrou mais servicos do que socorristas
    if veiculo.qtd_srr_possiveis < l_qtde_servico then

       if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
         display "Exitem mais servicos programados do que viaturas disponiveis "
         display 'QTD SERVICOS: ', l_qtde_servico,
                 ' QTD VIATURAS: ', veiculo.qtd_srr_possiveis
       end if

       call cts40g06_desb_veic(retorno.socvclcod,999997)
            returning d_cts41g00.result
       let retorno.socvclcod = null
    end if

    return retorno.socvclcod

end function
