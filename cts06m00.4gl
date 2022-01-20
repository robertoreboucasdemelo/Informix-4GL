###############################################################################
# Nome do Modulo: CTS06M00                                            Pedro   #
#                                                                   Marcelo   #
# Marcacao de Vistoria Previa Domiciliar                           Jan/1995   #
###############################################################################
# Alteracoes:                                                                 #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta-   #
#                                       bela DATMSERVICO.                     #
#-----------------------------------------------------------------------------#
# 29/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-    #
#                                       reco atraves do guia postal.          #
#-----------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti-   #
#                                       ma etapa do servico.                  #
#-----------------------------------------------------------------------------#
# 21/06/1999  PSI 8111-6   Wagner       Criar tecla funcao p/copia de laudo   #
#-----------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a     #
#                                       serem excluidos.                      #
#-----------------------------------------------------------------------------#
# 16/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03  #
#                                       e padroniza gravacao do historico.    #
#-----------------------------------------------------------------------------#
# 23/12/1999  PSI 7263-0   Gilberto     Substituir geracao do numero do       #
#                                       vico por funcao (cts10g02_servico).   #
#-----------------------------------------------------------------------------#
# 08/02/2000  PSI 10206-7  Wagner       Manutencao no campo nivel prioridade  #
#-----------------------------------------------------------------------------#
# 16/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de        #
#                                       solicitante.                          #
#-----------------------------------------------------------------------------#
# 27/04/2000  PSI-9125-0   Akio         Adaptacao do modulo para chamadas     #
#                                       externas                              #
#-----------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO        #
#                                       via funcao                            #
#                                       Exclusao da coluna atdtip             #
#-----------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03           #
#-----------------------------------------------------------------------------#
# 07/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
#-----------------------------------------------------------------------------#
# 13/09/2000  PSI 11459-6  Wagner       Adaptacao acionamento servico.        #
#-----------------------------------------------------------------------------#
# 25/09/2000  PSI 11253-4  Ruiz         Grava oficina na datmlcl para o       #
#                                       relatorio bdata080.                   #
#-----------------------------------------------------------------------------#
# 06/10/2000  PSI 10911-8  Ruiz         Alteracao para roterizacao da         #
#                                       vistoria previa                       #
#-----------------------------------------------------------------------------#
# 29/11/2000               Raji         Inclusao do paramentro codigo da      #
#                                       oficina destino para laudos           #
#-----------------------------------------------------------------------------#
# 26/03/2001 PSI 12753-1   Raji         Inclusao do paramentro codigo do      #
#                                       veiculo a ser vistoriado.             #
#-----------------------------------------------------------------------------#
# 17/05/2002 PSI 15417-2   Ruiz         Disponibilizar marcacao vp p/ RJ.     #
#-----------------------------------------------------------------------------#
#=============================================================================#
# Alterado : 23/07/2002 - Celso                                               #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores   #
#=============================================================================#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------- #
# 27/06/2003  James, Meta    174688    Manutencao Vistoria Previa Domiciliar  #
#                                                                             #
# 16/10/2003  Robson, Meta   PSI172022 Passar 2 parametros para funcao        #
#                            OSF027480 cts06m11 e receber um codigo e uma men-#
#                                      sagem.                                 #
#-----------------------------------------------------------------------------#
# 10/03/2004  Marcio,Meta    PSI183644 Inibir linhas do programa              #
#                            OSF 3340                                         #
#-----------------------------------------------------------------------------#
# 16/04/2004  Cesar Lucca    CT 199427 - Comentar o bloco na funcao           #
#                            'cts06m00_busca_endereco()'                      #
#                                                                             #
# 21/10/2004  Daniel, Meta   PSI188514 Nas chamadas da funcao cto00m00 passar #
#                                      como parametro o numero 1              #
#-----------------------------------------------------------------------------#
# 17/05/2005 Julianna,Meta    PSI191108   Implementar o codigo da via         #
#-----------------------------------------------------------------------------#
# 27/03/2006 Zyon,Porto       CT 408310   Tratamento avcmplmurgvst            #
#-----------------------------------------------------------------------------#
# 15/09/2006 Zyon,Porto       PSI203637   -Gravar vp mesmo dia tab consulta   #
#                                         -Incluida opcao "C"ancelar palm     #
#                                         -Incluida mensagem Palm sem concl   #
#-----------------------------------------------------------------------------#
# 14/02/2007 Saulo,Meta       AS130087    Migracao para a versao 7.32         #
#-----------------------------------------------------------------------------#
# 15/02/2007 Geraldo,Porto    PSI206253   -Consistir validacao de chassi      #
#-----------------------------------------------------------------------------#
# 03/03/2008 Zyon,Porto       PSI215767   -Alterada ordem dos campos          #
#                                         -Incluido codigo empresa            #
#-----------------------------------------------------------------------------#
# 15/09/2008 Zyon,Porto       PSI227315   Incluido renavam                    #
#                                         Incluida funcao fvpic190            #
#                                         Alterada funcao fvpic180            #
#                                         Retirado observacao horario         #
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# 12/09/2008 Roberto,Porto    PSI 223689  Troca dos insert/update/delete das  #
#                                         tabelas da vistoria pela funcao     #
#                                         fvpia400                            #
#                                         Inclusao da funcao figrc072():      #
#                                         essa funcao evita que o programa    #
#                                         caia devido ha uma queda da         #
#                                         instancia da tabela de origem para  #
#                                         a tabela de replica                 #
#-----------------------------------------------------------------------------#
# 04/03/2009 Maia             PSI 237663  Alteracao do envio de email, para   #
#                                         envio de sms para os vistoriadores  #
#-----------------------------------------------------------------------------#
# 30/05/2009 Eloisa,Porto     PSI 242233  Envia email de cancelamento da vis- #
#                                         toria para prestador                #
#-----------------------------------------------------------------------------#
# 13/08/2009 Sergio Burini    PSI 244236  Inclusão do Sub-Dairro              #
#-----------------------------------------------------------------------------#
# 07/10/2009 Geraldo Souza    CT 729086   Consistir marcacao VP aos Domingos  #
#-----------------------------------------------------------------------------#
# 30/10/2009 Geraldo Souza    CT 729086   Consistir marcacao VP aos Feriados  #
#-----------------------------------------------------------------------------#
# 27/05/2010 Geraldo Souza    PAS 95168   Dimensionar variavel l_palminf      #
#-----------------------------------------------------------------------------#
# 29/07/2010 Geraldo Souza    PAS 100676  Incluir mensagem bloqueio datmblqmsg#
#-----------------------------------------------------------------------------#
# 21/10/2010 Alberto Rodrigues            Correcao de ^M                      #
#-----------------------------------------------------------------------------#
# 20/03/2012 Eduardo Gomes  PSI-2011-00076-PR    Zerar coordenadas com        #
#                                              agendamento feito via informix #
#-----------------------------------------------------------------------------#
# 11/05/2012 Adelar, META   PSI-2012-07408   Mudanca do tamanho das variaveis #
#                                            de DDD e TELEFONE para 4 e 10    #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/figrc012.4gl"   #Saymon ambnovo
globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"

 define d_cts06m00    record
    vstnumdig         like datmvistoria.vstnumdig,
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmvistoria.atdsrvnum,
    atdsrvano         like datmvistoria.atdsrvano,
    c24solnom         like datmligacao.c24solnom,
    c24soltipcod      like datmligacao.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    vstdat            like datmvistoria.vstdat,
    vstc24tip         like datmvistoria.vstc24tip,
    vstc24des         char (07),
    succod            like datmvistoria.succod,
    sucnom            like gabksuc.sucnom,
    vstfld            like datmvistoria.vstfld,
    vstflddes         char (30),
    ciaempcod         like datmservico.ciaempcod,
    empnom            like gabkemp.empnom,
    lgdcep            like datmlcl.lgdcep,
    lgdcepcmp         like datmlcl.lgdcepcmp,
    corsus            like gcaksusep.corsus,
    cornom            like gcakcorr.cornom,
    cordddcod         like datmvistoria.cordddcod,
    cortelnum         like datmvistoria.cortelnum,
    segnom            like gsakseg.segnom,
    pestip            like gsakseg.pestip,
    cgccpfnum         like datmvistoria.cgccpfnum,
    cgcord            like datmvistoria.cgcord,
    cgccpfdig         like datmvistoria.cgccpfdig,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06),
    atdatznom         like datmvistoria.atdatznom,
    vclcoddig         like datmservico.vclcoddig,
    vclmrcnom         like datmvistoria.vclmrcnom,
    vcltipnom         like datmvistoria.vcltipnom,
    vclmdlnom         like datmvistoria.vclmdlnom,
    vclcordes         char (11),
    vcllicnum         like datmvistoria.vcllicnum,
    vclchsnum         like datmvistoria.vclchsnum,
    vclanofbc         datetime year to year,
    vclanomdl         datetime year to year,
    atdtxt            char (70),
    prfhor            like datmvistoria.prfhor,
    horobs            like datmvistoria.horobs,
    vclrnvnum         like datmvistoria.vclrnvnum,
    cidcod            like datmvistoria.cidcod,
    segematxt         like datmvistoria.segematxt
 end record

 define w_cts06m00    record
    cancelada         char (01),
    atdsoltip         like datmservico.atdsoltip,
    atdfnlflg         like datmservico.atdfnlflg ,
    vclmrccod         like agbkmarca.vclmrccod   ,
    vclmrcnom         like agbkmarca.vclmrcnom   ,
    vcltipcod         like agbktip.vcltipcod     ,
    vcltipnom         like agbktip.vcltipnom     ,
    vclmdlnom         like agbkveic.vclmdlnom    ,
    atdhorpvt         like datmservico.atdhorpvt ,
    atddatprg         like datmservico.atddatprg ,
    vclcorcod         like datmservico.vclcorcod ,
    vcldes            like datmservico.vcldes    ,
    flgerro           dec(01,0)                  ,
    param             char(100)                  ,
    corsus            like gcaksusep.corsus      ,
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define a_cts06m00    array[1] of record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig       ,
    emeviacod         like datkemevia.emeviacod    ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp
 end record

 define salva         record
    vstdat            like datmvistoria.vstdat   ,
    vstc24tip         like datmvistoria.vstc24tip,
    vcllicnum         like datmvistoria.vcllicnum,
    vclchsnum         like datmvistoria.vclchsnum,
    lgdcep            like datmlcl.lgdcep
 end record

 define g_cts06m00    record
        corlignum     like dacmligass.corlignum  ,
        corligitmseq  like dacmligass.corligitmseq
 end record

 define hist_cts06m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define arr_aux         smallint
 define w_data          char (10)
 define w_hora          char (05)
 define m_atdsrvorg     like datmservico.atdsrvorg,
        m_acesso_ind    smallint
 #-------------------------------------------------------------------------
 # Bloqueios de vp domiciliar
 #-------------------------------------------------------------------------
 define mr_entrada_bloq record
     ciaempcod   like datmservico.ciaempcod,     #-- Codigo da Empresa
     vstfld      like avlmlaudo.vstfld,          #-- Codido da Finalidade da VP
     ufdcod      like datmlcl.ufdcod,            #-- Sigla do Estado
     cidcod      like glakcid.cidcod,            #-- Codigo da Cidade
     chassi      like datmvistoria.vclchsnum,    #-- Chassi do Veiculo
     placa       like datmvistoria.vcllicnum,    #-- Placa do Veiculo
     renavam     like datmvistoria.vclrnvnum     #-- Renavam do Veiculo
 end record

 define mr_retorno_bloq record
     codigo      smallint,
     descricao   char(40)
 end record
 #-------------------------------------------------------------------------

 define m_prep_sql    smallint
 define m_lclbrrnom     char(65)

 #-----------------------------------------------
 # Variavel para gravar no final do campo contato
 #-----------------------------------------------
 define m_val_chassi_veic   char(05)
 #PAS 100676 - Geraldo Souza - 29/07/2010
 define m_his_chassi_veic   like datmblqmsg.blqmsgdes


function cts06m00_prepara()
    define l_sql   char(3000)
    #---------------------------------
    # Recupera socorrista pela viatura
    #---------------------------------
    let l_sql = "select dattfrotalocal.srrcoddig,   ",
                "       datkveiculo.pstcoddig,      ",
                "       datkveiculo.socvclcod       ",
                "  from datkveiculo,                ",
                "       dattfrotalocal              ",
                "where datkveiculo.socvclcod = dattfrotalocal.socvclcod ",
                "  and datkveiculo.atdvclsgl = ?    "
    prepare pcts06m00001 from l_sql
    declare ccts06m00001 cursor for pcts06m00001
    #---------------------------------------
    # Recupera viatura pelo codigo do pocket
    #---------------------------------------
    let l_sql = "select avckplmidt.atdvclsgl        ",
                "  from avckplmidt                  ",
                " where avckplmidt.plmidtnum = ?    "
    prepare pcts06m00002 from l_sql
    declare ccts06m00002 cursor for pcts06m00002
    #---------------------------------------
    # Recupera numero do nextel, ddd do celular e celular pela viatura #    - PSI -
    #---------------------------------------
    let l_sql = " select datkveiculo.dadnxtnum      ",
                "       ,datkveiculo.celdddcod      ",
                "       ,datkveiculo.celtelnum      ",
                " from datkveiculo                  ",
                " where datkveiculo.atdvclsgl = ?   "
    prepare pcts06m00003 from l_sql
    declare ccts06m00003 cursor for pcts06m00003
    #-------------------------------------
    # Recupera nome da empresa pelo codigo
    #-------------------------------------
    let l_sql = "select gabkemp.empnom  ",
                "  from gabkemp         ",
                " where gabkemp.empcod = ? "

    prepare pcts06m00004 from l_sql
    declare ccts06m00004 cursor for pcts06m00004
    #--------------------------------
    # Recupera finalidade pelo codigo
    #--------------------------------
    let l_sql = "select avlkdomcampovst.vstcpodomdes ",
                "  from avlkdomcampovst ",
                " where avlkdomcampovst.vstcpocod = 1  ",
                "   and avlkdomcampovst.vstcpodomcod = ?  ",
                "   and avlkdomcampovst.atlult[09,12] <> 'DELE' "
    prepare pcts06m00005 from l_sql
    declare ccts06m00005 cursor for pcts06m00005
    #--------------------------------------
    # Recupera o codigo da cidade pelo nome
    #--------------------------------------
    let l_sql = "select c.cidcod ",
                "  from glakcid c ",
                " where c.cidnom = ? ",
                "   and c.ufdcod = ? "
    prepare pcts06m00006 from l_sql
    declare ccts06m00006 cursor for pcts06m00006
    #------------------------------------------------------
    # Recupera vistoria marcada para o mesmo dia pela placa
    #------------------------------------------------------
    let l_sql = "select datmvistoria.vstnumdig      ",
                "  from datmvistoria                ",
                " where datmvistoria.vstdat    = ?  ",
                "   and datmvistoria.vcllicnum = ?  ",
                "   and not exists                  ",
                "  (select datmvstcanc.atdsrvnum    ",
                "     from datmvstcanc              ",
                "    where datmvstcanc.atdsrvnum = datmvistoria.atdsrvnum   ",
                "      and datmvstcanc.atdsrvano = datmvistoria.atdsrvano ) "
    prepare pcts06m00007 from l_sql
    declare ccts06m00007 cursor for pcts06m00007
    #-------------------------------------------------------
    # Recupera vistoria marcada para o mesmo dia pelo chassi
    #-------------------------------------------------------
    let l_sql = "select datmvistoria.vstnumdig      ",
                "  from datmvistoria                ",
                " where datmvistoria.vstdat    = ?  ",
                "   and datmvistoria.vclchsnum = ?  ",
                "   and not exists                  ",
                "  (select datmvstcanc.atdsrvnum    ",
                "     from datmvstcanc              ",
                "    where datmvstcanc.atdsrvnum = datmvistoria.atdsrvnum   ",
                "      and datmvstcanc.atdsrvano = datmvistoria.atdsrvano)  "
    prepare pcts06m00008 from l_sql
    declare ccts06m00008 cursor for pcts06m00008
    #-----------------------------------------------------
    # Recupera marca, tipo e modelo do veiculo pelo codigo
    #-----------------------------------------------------
    let l_sql = "select agbkmarca.vclmrcnom,    ",
                "       agbktip.vcltipnom,      ",
                "       agbkveic.vclmdlnom      ",
                "  from agbkveic,   ",
                " outer agbkmarca,  ",
                " outer agbktip     ",
                " where agbkveic.vclcoddig  = ? ",
                "   and agbkmarca.vclmrccod = agbkveic.vclmrccod    ",
                "   and agbktip.vclmrccod   = agbkveic.vclmrccod    ",
                "   and agbktip.vcltipcod   = agbkveic.vcltipcod    "
    prepare pcts06m00009 from l_sql
    declare ccts06m00009 cursor for pcts06m00009
    #-----------------------------------------------
    # Recupera a descricao da prioridade pelo codigo
    #-----------------------------------------------
    let l_sql = "select iddkdominio.cpodes ",
                "  from iddkdominio ",
                " where iddkdominio.cponom = 'atdprinvlcod' ",
                "   and iddkdominio.cpocod = ?  "
    prepare pcts06m00010 from l_sql
    declare ccts06m00010 cursor for pcts06m00010


     let l_sql = "select vstcpodomdes  ",
                "  from avlkdomcampovst ",
                " where avlkdomcampovst.vstcpocod = 107 ",
                "   and avlkdomcampovst.vstcpodomdes  = ? ",
                "   and avlkdomcampovst.atlult[09,12] <> 'DELE' "
    prepare pcts06m00011 from l_sql
    declare ccts06m00011 cursor for pcts06m00011

    let l_sql = "select vstcpodomdes  ",
               "  from avlkdomcampovst ",
               " where avlkdomcampovst.vstcpocod = 107 ",
               "   and avlkdomcampovst.atlult[09,12] <> 'DELE' "
    prepare pcts06m00012 from l_sql
    declare ccts06m00012 cursor for pcts06m00012

   let l_sql = "update datmlcl   ",
               "  set lclltt = 0 ",
               "     ,lcllgt = 0 ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? "
    prepare pcts06m00013 from l_sql

    let m_prep_sql = true

end function

## PSI 174 688 - Final

#------------------------------------------------------------
 function cts06m00(param)
#------------------------------------------------------------
 define l_msgddd char(50)
 define l_msgcel char(50)
 define l_infcel char(8)
 define l_loop   smallint
 define l_infddd char(2)
 define l_msg_sms1 char(143)
 define l_msg_sms2 char(143)
 define l_dia_real datetime month to day
 define l_ano char(4)
 define l_mes char(2)
 define l_grlchv char (10)
 define l_celdddcod dec(4)
 define l_celtelnum dec(10)
 define l_erro      smallint
 define l_menserro  char(50)
 define param         record
    exec              char(01),
    vstnumdig         like datmvistoria.vstnumdig,   # Recebido da tela do radio
    corlignum         like dacmligass.corlignum  ,
    corligitmseq      like dacmligass.corligitmseq
 end record

## PSI 174 688 - Inicio

 define l_ws            record
        srrcoddig       like dattfrotalocal.srrcoddig
       ,pstcoddig       like datkveiculo.pstcoddig
       ,socvclcod       like dattfrotalocal.socvclcod
       ,atdetpcod       like datmsrvacp.atdetpcod
 end record

 define l_status        integer
       ,l_simounao      char(01)
       ,l_palm          like avckplmidt.plmidtnum
       ,l_palminf       char(04)
       ,l_atdvclsgl     like avckplmidt.atdvclsgl
       ,l_cont          integer
       ,l_palmok        char(01)
       ,l_msgpalm       char(70)
       ,l_dadnxtnum     char(10)
       ,l_msgnextel     char(2000)
       ,l_separador     char(1) ### char(2)
       ,l_comando       char(2000)
       ,l_retorno       smallint
       ,l_qtd           integer
       ,l_lixo          integer
       ,l_ult_etp_p     smallint
       ,l_ult_etp_s     smallint
 if   m_prep_sql = false or
      m_prep_sql is null
 then
      call cts06m00_prepara()
 end if

#------------------------------------------------------------------------------
### let g_documento.ciaempcod = 1 # vistoria previa somente para empresa Porto.
#------------------------------------------------------------------------------

## PSI 174 688 - Inicio

 initialize g_cts06m00.*   to null
 initialize d_cts06m00.*   to null
 initialize w_cts06m00.*   to null
 initialize a_cts06m00     to null

 let w_data = today
 let w_hora = current hour to minute

 initialize mr_entrada_bloq.*   to null
 initialize mr_retorno_bloq.*   to null

 let l_separador = ascii(13)
 let l_qtd       = null
 let m_lclbrrnom = null
 let g_documento.atdsrvorg = 10

 call get_param()

 let w_cts06m00.param  =  arg_val(15)
 let w_cts06m00.corsus =  w_cts06m00.param[31,36]

 open window cts06m00 at 04,02 with form "cts06m00"

     menu "MARCACAO "

     before menu
        hide option all

        case param.exec
          when "I"
            let g_cts06m00.corlignum    = param.corlignum
            let g_cts06m00.corligitmseq = param.corligitmseq
            if  get_niv_mod(g_issk.prgsgl,"cts06m00") then
                if  g_issk.acsnivcod >= g_issk.acsnivatl then     ## NIVEL 4
                    show option "Seleciona","Inclui","coPia"
                end if
            end if
          when "A"
            let g_cts06m00.corlignum    = param.corlignum
            let g_cts06m00.corligitmseq = param.corligitmseq
            if  get_niv_mod(g_issk.prgsgl,"cts06m00") then
                if  g_issk.acsnivcod >= g_issk.acsnivatl then     ## NIVEL 4
                    show option "Seleciona","Modifica","Historico","Cancela"
                end if
            end if
          otherwise
            if  get_niv_mod(g_issk.prgsgl,"cts06m00") then
                if  g_issk.acsnivcod >= g_issk.acsnivcns then     ## NIVEL 2
                    show option "Seleciona", "Historico", "impRime"
                end if
                if  g_issk.acsnivcod >= g_issk.acsnivatl then     ## NIVEL 4
                    show option "Inclui","Modifica","Cancela","cOnclui","coPia","Envia"    ## PSI 174 688
                end if
            end if
        end case
        show option "Pto_Referenc"

        #-- Consulta Produtividade por Inspetor
        if get_niv_mod(g_issk.prgsgl, 'oavpc019') then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option 'proD_insp'
            end if
        end if
        #-- Consulta Produtividade por Funcionario
        if get_niv_mod(g_issk.prgsgl, 'oavpc020') then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option 'prod_fUnc'
            end if
        end if

        show option "eNcerra"         ## PSI 174 688

        #------------------------------------------------------------
        # Caso tenha vindo do MotoGPS com um vistoriador selecionado,
        # seleciona o menu para maior agilidade
        #------------------------------------------------------------
        if param.exec = "N" and
           param.vstnumdig is not null then
            next option "Seleciona"
        end if

        command key ("I")  "Inclui"    "Inclui vistoria previa domiciliar"
           clear form
           initialize w_cts06m00.atddatprg, w_cts06m00.atdhorpvt  to null
           initialize d_cts06m00.*  to null
           initialize a_cts06m00    to null
           if param.exec    = "I"    then   # atd_cor
              let d_cts06m00.c24solnom = w_cts06m00.param[37,51]
              display by name d_cts06m00.c24solnom
           end if

           call cts06m00_input("I")
           initialize d_cts06m00.*  to null
           initialize a_cts06m00    to null
           clear form
           if  not int_flag then
               if  param.exec <> "N"  then
                   exit menu
               end if
           end if

        command key ("S")  "Seleciona" "Seleciona vistoria previa domiciliar"
           clear form
           initialize d_cts06m00.*  to null
           initialize a_cts06m00    to null
           if param.vstnumdig is not null  then             # QUANDO VIER DA
              let d_cts06m00.vstnumdig = param.vstnumdig    # TELA DE LOCALIZA
           end if                                           # OU RADIO
           call cts06m00_localiza()

        command key ("M")  "Modifica"  "Modifica vistoria previa domiciliar"
           if d_cts06m00.vstnumdig  is not null    then
              if d_cts06m00.vstc24tip  =  1   and
                 w_cts06m00.atdfnlflg  = "S"  then
                 error " Servico ja' acionado nao pode ser modificado!"
                 continue menu
              end if
              if w_cts06m00.cancelada = "s"  then
                 error " Vistoria cancelada, nao pode ser modificada!"
                 continue menu
              end if
              if g_documento.atdsrvnum is null and
                 g_documento.atdsrvano is null then
                 let g_documento.atdsrvnum  = d_cts06m00.atdsrvnum
                 let g_documento.atdsrvano  = d_cts06m00.atdsrvano
                 call cts06m00_input("M")
                 initialize g_documento.atdsrvnum,g_documento.atdsrvano to null
              else
                 call cts06m00_input("M")
              end if
              clear form
              initialize d_cts06m00.*  to null
              initialize a_cts06m00    to null
           else
              error " Selecione uma vistoria previa domiciliar!"
              next option "Seleciona"
           end if
           if  not int_flag then
               if  param.exec <> "N"  then
                   exit menu
               end if
           end if

        command key ("H")  "Historico" "Historico vistoria previa domiciliar"
           if d_cts06m00.atdsrvnum  is not null  and
              d_cts06m00.atdsrvano  is not null  then
              call cts06n01(d_cts06m00.atdsrvnum, d_cts06m00.atdsrvano,
                            d_cts06m00.vstnumdig, g_issk.funmat, w_data,
                            w_hora)
           else
              error " Selecione uma vistoria previa domiciliar!"
           end if
           next option "Seleciona"

        command key ("C")  "Cancela"   "Cancela vistoria previa domiciliar"
           if d_cts06m00.vstnumdig   is not null  then
              call cts06m01(d_cts06m00.atdsrvnum,
                            d_cts06m00.atdsrvano,
                            d_cts06m00.vstc24tip,
                            d_cts06m00.vstdat,
                            d_cts06m00.succod,
                            g_cts06m00.corlignum,
                            g_cts06m00.corligitmseq,
                            d_cts06m00.vstnumdig)
           else
              error " Selecione uma vistoria previa domiciliar!"
              next option "Seleciona"
           end if
           if  not int_flag then
               if  param.exec <> "N"  then
                   exit menu
               end if
           end if

        command key ("O")  "cOnclui"   "Conclui vistoria previa domiciliar"
           if d_cts06m00.vstnumdig   is not null  then
              if d_cts06m00.vstc24tip  =  1   or
                 d_cts06m00.vstc24tip  =  0   then
                 let g_documento.atdsrvnum = d_cts06m00.atdsrvnum
                 let g_documento.atdsrvano = d_cts06m00.atdsrvano
                 # Funcao para buscar a ultima etapa do servico
                 call cts10g04_ultima_etapa(d_cts06m00.atdsrvnum, d_cts06m00.atdsrvano)
                     returning l_ult_etp_p
                 call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
                 # Funcao para buscar a ultima etapa do servico
                 call cts10g04_ultima_etapa(d_cts06m00.atdsrvnum, d_cts06m00.atdsrvano)
                      returning l_ult_etp_s
                 if l_ult_etp_p = 1 and l_ult_etp_s = 4 then
                    #Chamada funcao para enviar vistoria via e-mail para prestadores
                    ### call fvpic004_verifica_email(d_cts06m00.vstnumdig,
                    ###                              d_cts06m00.atdsrvnum,
                    ###                              d_cts06m00.atdsrvano,
                    ###                              1)
                    ###     returning l_retorno

                    call fvpic004_envia_email(
                              d_cts06m00.atdsrvnum
                             ,d_cts06m00.atdsrvano
                             ,'S')
                    returning l_retorno
                             ,l_msgpalm
                    if l_retorno <> 0 then
                        error l_msgpalm clipped
                        sleep 2
                    end if

                 end if
                 #-- Alteracao para Palm - CT 313807
                 initialize l_palm      to null
                 initialize l_palminf   to null
                 initialize l_atdvclsgl to null
                 initialize l_cont      to null
                 initialize l_palmok    to null
                 #-- Verifica se a VP ja esta disponibilizada como urgente
                 call fvpia400_seleciona_palm_vp(d_cts06m00.vstnumdig)
                 returning l_palm, sqlca.sqlcode
                 if sqlca.sqlcode = notfound then
                     let l_msgpalm = " Deseja disponibilizar a vistoria para o Palm (Sim/Nao) ?:"
                 else
                     let l_msgpalm = " Deseja disponibilizar a vistoria para o Palm (Sim/Nao/Cancela ",
                         l_palm using "<<<<<", ") ?:"
                 end if
                 prompt l_msgpalm clipped for char l_simounao
                 initialize l_palm to null
                 if upshift(l_simounao) = "S" then
                     whenever error continue
                     while true
                         prompt " Informe o numero do Palm ou zero para cancelar : " for l_palminf
                         let l_palmok = "S"
                         for l_cont = 1 to length(l_palminf)
                             let l_simounao = l_palminf[l_cont,l_cont] clipped
                             if l_simounao not matches "[0,1,2,3,4,5,6,7,8,9]" then
                                 let l_palmok = "N"
                                 exit for
                             end if
                         end for
                         if l_palmok = "S" then
                             let l_palm = l_palminf
                             if l_palm = 0 then
                                 exit while
                             end if
                             #---------------------------------------
                             # Recupera viatura pelo codigo do pocket
                             #---------------------------------------
                             open ccts06m00002 using l_palm
                             fetch ccts06m00002 into l_atdvclsgl
                             whenever error stop
                             if l_atdvclsgl is not null then
                                 exit while
                             end if
                         end if
                     end while
                     if l_palm is not null and l_palm > 0 then
                         #-- Verifica se a vistoria ja foi marcada como urgente
                         call fvpia400_seleciona_palm_vp(d_cts06m00.vstnumdig)
                         returning l_lixo, sqlca.sqlcode
                         if  sqlca.sqlcode = notfound then
                             #-- Se nao existe o registro, cria para o palm indicado
                             call figrc072_setTratarIsolamento()
                             call fvpia400_inclui_palm_vp(d_cts06m00.vstnumdig ,
                                                          d_cts06m00.vstdat    ,
                                                          l_palm               ,
                                                          d_cts06m00.atdsrvano ,
                                                          g_documento.atdsrvnum)
                             if g_isoAuto.sqlCodErr <> 0 then
                                error "Criacao do Palm Indisponivel! Erro: "
                                      ,g_isoAuto.sqlCodErr
                             end if
                         else
                             #-- Se ja existe o registro, altera o palm -- CT 408310
                             call figrc072_setTratarIsolamento()
                             call fvpia400_atualiza_palm_vp(d_cts06m00.vstnumdig ,
                                                            d_cts06m00.vstdat    ,
                                                            l_palm               ,
                                                            d_cts06m00.atdsrvano ,
                                                            g_documento.atdsrvnum)
                             if g_isoAuto.sqlCodErr <> 0 then
                                error "Atualizacao do Palm Indisponivel! Erro: "
                                      ,g_isoAuto.sqlCodErr
                             end if
                         end if
                         #------------------------------------------------------------------------------
                         # ALTERACAO PSI 237663 - ENVIO PARA SMS - MAIA
                         initialize l_dadnxtnum to null
                         initialize l_celtelnum to null
                         initialize l_celdddcod to null
                         #busca telefone nextel e celular do vistoriador
                         open ccts06m00003 using l_atdvclsgl
                         fetch ccts06m00003 into l_dadnxtnum
                                                ,l_celdddcod
                                                ,l_celtelnum
                         if sqlca.sqlcode = 0 then
                            let l_msgpalm = " Deseja enviar a vistoria por SMS  (Sim/Nao) ?:"
                            prompt l_msgpalm clipped for char l_simounao
                            if upshift(l_simounao) = "S" then

                                call fvpic004_envia_sms(
                                     d_cts06m00.atdsrvnum
                                    ,d_cts06m00.atdsrvano
                                    ,l_celdddcod
                                    ,l_celtelnum)
                                returning l_retorno
                                         ,l_msgpalm
                                if l_retorno <> 0 then
                                    error l_msgpalm clipped
                                    sleep 2
                                end if
#
#                                  let l_dia_real = today
#                                  let l_ano = year(l_dia_real)
#                                  let l_mes = month(l_dia_real)
#                                  case
#                                       when l_mes = '1 '
#                                            let l_mes = '01'
#                                       when l_mes = '2 '
#                                            let l_mes = '02'
#                                       when l_mes = '3 '
#                                            let l_mes = '03'
#                                       when l_mes = '4 '
#                                            let l_mes = '04'
#                                       when l_mes = '5 '
#                                            let l_mes = '05'
#                                       when l_mes = '6 '
#                                            let l_mes = '06'
#                                       when l_mes = '7 '
#                                            let l_mes = '07'
#                                       when l_mes = '8 '
#                                            let l_mes = '08'
#                                       when l_mes = '9 '
#                                            let l_mes = '09'
#                                  end case
#                                  let l_grlchv = 'SMS_',l_mes,l_ano
#                                 #------------------------------------------------------------------------------
#                                  # SMS 1/2 - PRIMEIRA PARTE DA MENSAGEM
#                                  let l_msg_sms1[1,3]     = '1/2'                                     # PARTE SMS
#                                  let l_msg_sms1[4]       = ','                                       # SEPARADOR
#                                  let l_msg_sms1[5,13]    = d_cts06m00.vstnumdig CLIPPED              # NUM VISTORIA
#                                  let l_msg_sms1[14]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[15,19]   = l_dia_real                                # DIA REAL
#                                  let l_msg_sms1[20]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[21,38]   = d_cts06m00.vstflddes[1,18] CLIPPED        # FINALIDADE
#                                  let l_msg_sms1[39]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[40,46]   = d_cts06m00.vcllicnum[1,7]  CLIPPED        # PLACA
#                                  let l_msg_sms1[47]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[48,55]   = d_cts06m00.vclchsnum[12,20]CLIPPED        # CHASSI FINAL
#                                  let l_msg_sms1[56]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[57,66]   = d_cts06m00.vcltipnom[1,10] CLIPPED        # VEICULO DESCRICAO
#                                  let l_msg_sms1[67]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[68,76]   = d_cts06m00.vclanofbc, "/"                 # ANO FABRICACAO
#                                                           ,d_cts06m00.vclanomdl                      # ANO MODELO
#                                  let l_msg_sms1[77]      = ','                                       # SEPARADOR
#                                  let l_msg_sms1[78,126]  = a_cts06m00[1].lgdtip[1,2]CLIPPED," "      # LOCAL
#                                                           ,a_cts06m00[1].lgdnom[1,40] CLIPPED," "    # LOCAL
#                                                           ,a_cts06m00[1].lgdnum       USING "<<<<<<" # LOCAL
#                                  let l_msg_sms1[127]     = ','                                       # SEPARADOR
#                                  let l_msg_sms1[128,143] = a_cts06m00[1].brrnom[1,16] CLIPPED        # BAIRRO
#                                  #------------------------------------------------------------------------------
#                                  # SMS 2/2 - SEGUNDA PARTE DA MENSAGEM
#                                  let l_msg_sms2[1,3]     = '2/2'                                         # PARTE SMS
#                                  let l_msg_sms2[4]       = ','                                           # SEPARADOR
#                                  let l_msg_sms2[5,13]    = d_cts06m00.vstnumdig CLIPPED                  # NUM VISTORIA
#                                  let l_msg_sms2[14]      = ','                                           # SEPARADOR
#                                  let l_msg_sms2[15,35]   = a_cts06m00[1].cidnom[1,21] CLIPPED            # CIDADE
#                                  let l_msg_sms2[36]      = ','                                           # SEPARADOR
#                                  let l_msg_sms2[37,49]   = a_cts06m00[1].dddcod                          # FONE
#                                                           ,a_cts06m00[1].lcltelnum                       # FONE
#                                  let l_msg_sms2[50]      = ','                                           # SEPARADOR
#                                  let l_msg_sms2[51,56]   = d_cts06m00.corsus[1,6] CLIPPED                # SUSEP
#                                  let l_msg_sms2[57]      = ','                                           # SEPARADOR
#                                  let l_msg_sms2[58,70]   = d_cts06m00.cordddcod,' ',                     # FONE CORRETOR
#                                                            d_cts06m00.cortelnum                          # FONE CORRETOR
#                                  let l_msg_sms2[71]      = ','                                           # SEPARADOR
#                                  let l_msg_sms2[72,97]   = d_cts06m00.segnom[1,26] CLIPPED               # NOME/RAZAO
#                                  let l_msg_sms2[98]      = ','                                           # SEPARADOR
#                                  let l_msg_sms2[99,110]  = a_cts06m00[1].lclcttnom[1,12] CLIPPED         # CONTATO
#                                  let l_msg_sms2[111]     = ','                                           # SEPARADOR
#                                  let l_msg_sms2[112,121] = d_cts06m00.prfhor[1,10] CLIPPED               # HORA PREFERENCIA
#                                  let l_msg_sms2[122]     = ','                                           # SEPARADOR
#                                  let l_msg_sms2[123,143] = a_cts06m00[1].lclrefptotxt[1,23] CLIPPED      # PONTO REFERENCIA
#                                  let l_msgpalm = " Deseja enviar para o celular ",l_celtelnum," (Sim/Nao) ?:"
#                                  let l_loop = true
#                                  prompt l_msgpalm clipped for char l_simounao
#                                  if upshift(l_simounao) = "S" then
#                                     #------------------------------------------------------------------------------
#                                     # SMS 1/2 - ENVIO PRIMEIRA PARTE DA MENSAGEM
#                                       call cts06m00_smsvp(a_cts06m00[1].dddcod,l_celtelnum,l_msg_sms1,l_grlchv)
#                                       error "Primeira SMS enviada com sucesso"
#                                       sleep 2
#                                     #------------------------------------------------------------------------------
#                                     # SMS 2/2 - ENVIO SEGUNDA PARTE DA MENSAGEM
#                                       call cts06m00_smsvp(a_cts06m00[1].dddcod,l_celtelnum,l_msg_sms2,l_grlchv)
#                                       error "Segunda SMS enviada com sucesso"
#                                       sleep 2
#                                  else
#                                      if (upshift(l_simounao) = "N") then
#                                         let l_msgddd = "Informe o ddd ou '0' para sair: [Ex: 11] "
#                                         let l_msgcel = "Informe o celular ou '0' para sair: [Ex: 12345678] "
#                                         while l_loop = true
#                                                  prompt l_msgddd clipped for l_infddd
#                                                  if (l_infddd CLIPPED = "0") then
#                                                       exit while
#                                                  end if
#                                                  prompt l_msgcel clipped for l_infcel
#                                                  if (l_infcel CLIPPED = "0")then
#                                                       exit while
#                                                  end if
#                                                  if (length(l_infddd)< 2) or (length(l_infcel) < 8) then
#                                                       error "Informe ddd/celular Valido"
#                                                       continue while
#                                                  else
#                                                     #------------------------------------------------------------------------------
#                                                     # SMS 1/2 - ENVIO PRIMEIRA PARTE DA MENSAGEM
#                                                      call cts06m00_smsvp(l_infddd,l_infcel,l_msg_sms1,l_grlchv)
#                                                      error "Primeira SMS enviada com sucesso"
#                                                      sleep 2
#                                                    #------------------------------------------------------------------------------
#                                                    # SMS 2/2 - ENVIO SEGUNDA PARTE DA MENSAGEM
#                                                      call cts06m00_smsvp(l_infddd,l_infcel,l_msg_sms2,l_grlchv)
#                                                      error "Segunda SMS enviada com sucesso"
#                                                      sleep 2
#                                                  let l_loop = false
#                                                  end if
#                                         end while
#                                      end if
#                                  end if
                            end if
                         else
                             error "Vistoriador sem numero para enviar SMS"
                             sleep 2
                         end if
                         # Fim da alteracao para SMS - PSI 237663 - MAIA
                         #------------------------------------------------------------------------------
                     end if
                 else
                     #-- Se a resposta for "C"ancela exclui a VP da tabela avcmplmurgvst
                     if upshift(l_simounao) = "C" then
                         #-- Verifica se a vistoria ja foi marcada como urgente
                         call fvpia400_seleciona_palm_vp(d_cts06m00.vstnumdig)
                         returning l_lixo, sqlca.sqlcode
                         if sqlca.sqlcode <> notfound then
                             #-- Se ja existe o registro, exclui
                             call figrc072_setTratarIsolamento()
                             call fvpia400_exclui_palm_vp(d_cts06m00.vstnumdig)
                             if g_isoAuto.sqlCodErr <> 0 then
                                error "Exclusao do Palm Indisponivel! Erro: "
                                      ,g_isoAuto.sqlCodErr
                             end if
                         end if
                     end if
                 end if
                 # Fim da alteracao para Palm - CT 313807
                 initialize g_documento.atdsrvnum, g_documento.atdsrvano to null
              else
                 error " Vistoria previa nao realizada pela Central 24 Horas!"
                 next option "Seleciona"
              end if
           else
              error " Selecione uma vistoria previa domiciliar"
              next option "Seleciona"
           end if
## PSI 174 688 - Inicio

        command key ("E")  "Envia"   "Envia vistoria previa domiciliar"
           if d_cts06m00.vstnumdig   is not null  then
              if d_cts06m00.vstc24tip  =  1  or
                 d_cts06m00.vstc24tip  =  0  then

                 let g_documento.atdsrvnum = d_cts06m00.atdsrvnum
                 let g_documento.atdsrvano = d_cts06m00.atdsrvano
                 call cts10g04_ultima_etapa(g_documento.atdsrvnum, g_documento.atdsrvano)
                                           returning l_ws.atdetpcod
                 if  l_ws.atdetpcod <> 4 then
                     #---------------------------------
                     # Recupera socorrista pela viatura
                     #---------------------------------
                     open ccts06m00001  using g_documento.solnom
                     whenever error continue
                     fetch ccts06m00001 into  l_ws.srrcoddig,
                                              l_ws.pstcoddig,
                                              l_ws.socvclcod
                     whenever error stop
                     if sqlca.sqlcode <> 0 then
                        if sqlca.sqlcode = notfound then
                           error " Nenhuma Viatura Selecionada, utilize a opcao MOTO_GPS na VP"
                           next option "Seleciona"
                        else
                           display "Erro de Acesso a Tabela DATKVEICULO",
                                   sqlca.sqlcode," | ",sqlca.sqlerrd[2]
                           exit menu
                        end if
                     end if
                     close ccts06m00001
                     #-- Somente atualiza se encontrou
                     if l_ws.srrcoddig is not null and
                        l_ws.pstcoddig is not null and
                        l_ws.socvclcod is not null then
                         let   l_status = 0
                         call  cts10g04_insere_etapa(g_documento.atdsrvnum,
                                                     g_documento.atdsrvano,
                                                     4,
                                                     l_ws.pstcoddig,
                                                     "",
                                                     l_ws.socvclcod,
                                                     l_ws.srrcoddig) returning l_status
                         if  l_status <> 0 then
                             display "Problema na rotina insere_etapa. Status : ",l_status
                             exit menu
                         end if
                         # Atualiza status do servico
                         update datmservico
                            set atdprscod = l_ws.pstcoddig,
                                socvclcod = l_ws.socvclcod,
                                srrcoddig = l_ws.srrcoddig,
                                c24nomctt = ""            ,
                                atdfnlhor = current       ,
                                c24opemat = g_issk.funmat ,
                                cnldat    = current       ,
                                atdcstvlr = 0             ,
                                atdprvdat = current       ,
                                atdfnlflg = "S"
                          where atdsrvnum = g_documento.atdsrvnum   and
                                atdsrvano = g_documento.atdsrvano

                           call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,g_documento.atdsrvano)

                     end if
                 end if
                 call cts00g04_msgvp(g_documento.atdsrvnum, g_documento.atdsrvano)
                 initialize g_documento.atdsrvnum, g_documento.atdsrvano to null
              else
                 error " Vistoria previa nao realizada pela Central 24 Horas!"
                 next option "Seleciona"
              end if
           else
              error " Selecione uma vistoria previa domiciliar!"
              next option "Seleciona"
           end if

## PSI 174 688 - Final

        command key ("P")  "coPia"    "Copia de vistoria previa domiciliar"
           if d_cts06m00.vstnumdig  is not null    then
              initialize w_cts06m00.atddatprg, w_cts06m00.atdhorpvt  to null
              initialize d_cts06m00.vstnumdig, d_cts06m00.atdsrvnum,
                         d_cts06m00.atdsrvano, d_cts06m00.vclmrcnom,
                         d_cts06m00.vcltipnom, d_cts06m00.vclmdlnom,
                         d_cts06m00.vclcordes, d_cts06m00.vcllicnum,
                         d_cts06m00.vclchsnum, d_cts06m00.vclanofbc,
                         d_cts06m00.vclanomdl, d_cts06m00.atdtxt   ,
                         d_cts06m00.atdsrvorg   to null
              display by name d_cts06m00.vstnumdig,
                              d_cts06m00.atdsrvorg,
                              d_cts06m00.atdsrvnum,
                              d_cts06m00.atdsrvano,
                              d_cts06m00.c24solnom,
                              d_cts06m00.c24soltipcod,
                              d_cts06m00.c24soltipdes,
                              d_cts06m00.vstdat,
                              d_cts06m00.vstc24tip,
                              d_cts06m00.vstc24des,
                              d_cts06m00.succod,
                              d_cts06m00.sucnom,
                              d_cts06m00.vstfld,
                              d_cts06m00.vstflddes,
                              d_cts06m00.ciaempcod,
                              d_cts06m00.empnom,
                              d_cts06m00.lgdcep,
                              d_cts06m00.lgdcepcmp,
                              d_cts06m00.corsus,
                              d_cts06m00.cornom,
                              d_cts06m00.cordddcod,
                              d_cts06m00.cortelnum,
                              d_cts06m00.segnom,
                              d_cts06m00.pestip,
                              d_cts06m00.cgccpfnum,
                              d_cts06m00.cgcord,
                              d_cts06m00.cgccpfdig,
                              d_cts06m00.atdprinvlcod,
                              d_cts06m00.atdprinvldes,
                              d_cts06m00.atdatznom,
                              d_cts06m00.vclcoddig,
                              d_cts06m00.vclmrcnom,
                              d_cts06m00.vcltipnom,
                              d_cts06m00.vclmdlnom,
                              d_cts06m00.vclcordes,
                              d_cts06m00.vcllicnum,
                              d_cts06m00.vclchsnum,
                              d_cts06m00.vclanofbc,
                              d_cts06m00.vclanomdl,
                              d_cts06m00.atdtxt,
                              d_cts06m00.prfhor,
                              d_cts06m00.vclrnvnum,
                              d_cts06m00.segematxt
              call cts06m00_input("I")
              clear form
              initialize d_cts06m00.*  to null
              initialize a_cts06m00    to null
           else
              error " Selecione uma vistoria previa domiciliar!"
              next option "Seleciona"
           end if

           if  not int_flag then
               if  param.exec <> "N"  then
                   exit menu
               end if
           end if

        command key ("R")  "impRime"   "Imprime vistoria previa domiciliar"
           if d_cts06m00.vstnumdig   is not null  then
              call cts06m05(d_cts06m00.vstnumdig)
           else
              error " Selecione uma vistoria previa domiciliar!"
              next option "Seleciona"
           end if
        command key ("F") "Pto_Referenc"
           "Ponto de Referencia"
           if d_cts06m00.atdsrvnum  is not null  and
              d_cts06m00.atdsrvano  is not null  then
              call cts00m23(d_cts06m00.atdsrvnum,d_cts06m00.atdsrvano)
           else
              error " Selecione uma vistoria previa domiciliar!"
           end if
           next option "Seleciona"

        #------------------------------------
        # PSI 206261 - Consulta produtividade
        #------------------------------------
        command key ("D") "proD_insp"       "Produtividade por inspetor"
            call oavpc019(d_cts06m00.vstdat,d_cts06m00.vstdat,g_documento.solnom,0)
        #------------------------------------
        # PSI 206261 - Consulta produtividade
        #------------------------------------
        command key ("U") "prod_fUnc"       "Produtividade por funcionario"
            call oavpc020(d_cts06m00.vstdat,d_cts06m00.vstdat,g_issk.empcod,g_issk.funmat,0)

        command key (interrupt, N )  "eNcerra"        ## PSI 174 688
           "Retorna ao Menu Anterior"
           exit menu
     end menu

     let int_flag = false
     close window cts06m00

 end function  ###  cts06m00

#------------------------------------------------------------------
 function cts06m00_localiza()
#------------------------------------------------------------------

 let int_flag  =  false

 input by name d_cts06m00.vstnumdig,
               d_cts06m00.atdsrvnum,
               d_cts06m00.atdsrvano  without defaults

    before field vstnumdig
       display by name d_cts06m00.vstnumdig  attribute (reverse)

    after field vstnumdig
       display by name d_cts06m00.vstnumdig

       if d_cts06m00.vstnumdig is not null  then
          if cts06m00_consulta(d_cts06m00.vstnumdig,
                               d_cts06m00.atdsrvnum,
                               d_cts06m00.atdsrvano) = false then
             next field vstnumdig
          else
             exit input
          end if
       end if

    before field atdsrvnum
       display by name d_cts06m00.atdsrvnum  attribute (reverse)

    after  field atdsrvnum
       display by name d_cts06m00.atdsrvnum

    before field atdsrvano
       display by name d_cts06m00.atdsrvano  attribute (reverse)

    after  field atdsrvano
       display by name d_cts06m00.atdsrvano

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.atdsrvano is null      and
             d_cts06m00.atdsrvnum is not null  then
             error " Ano do servico deve ser informado!"
             next field atdsrvano
          end if

          if d_cts06m00.atdsrvano is not null  and
             d_cts06m00.atdsrvnum is null      then
             error " Numero do servico deve ser informado!"
             next field atdsrvnum
          end if

          if d_cts06m00.vstnumdig is null  and
             d_cts06m00.atdsrvnum is null  then
             error " Numero da vistoria ou do servico deve ser informado!"
             next field vstnumdig
          end if

          if cts06m00_consulta(d_cts06m00.vstnumdig,
                               d_cts06m00.atdsrvnum,
                               d_cts06m00.atdsrvano) = false then
             next field atdsrvnum
          else
             exit input
          end if
       end if

   on key (interrupt)
      exit input
 end input

 if int_flag  then
    initialize d_cts06m00.* to null
    clear form
    let int_flag = false
 end if

end function  ###  cts06m00_localiza

#-----------------------------------------------------------------
 function cts06m00_input(param)
#-----------------------------------------------------------------

  define r_gcakfilial    record
         endlgd          like gcakfilial.endlgd
        ,endnum          like gcakfilial.endnum
        ,endcmp          like gcakfilial.endcmp
        ,endbrr          like gcakfilial.endbrr
        ,endcid          like gcakfilial.endcid
        ,endcep          like gcakfilial.endcep
        ,endcepcmp       like gcakfilial.endcepcmp
        ,endufd          like gcakfilial.endufd
        ,dddcod          like gcakfilial.dddcod
        ,teltxt          like gcakfilial.teltxt
        ,dddfax          like gcakfilial.dddfax
        ,factxt          like gcakfilial.factxt
        ,maides          like gcakfilial.maides
        ,crrdstcod       like gcaksusep.crrdstcod
        ,crrdstnum       like gcaksusep.crrdstnum
        ,crrdstsuc       like gcaksusep.crrdstsuc
        ,stt             smallint
  end record

 define param         record
    operacao          char (01)
 end record

 define ws            record
    vstqtdaut         like datmvstagen.vstqtdaut,
    atrvstqtdc24      like datmvstagen.atrvstqtdc24,
    vstqtdvol         like datmvstagen.vstqtdvol,
    vstqtdc24         like datmvstagen.vstqtdc24,
    cgccpfdig         like datmvistoria.cgccpfdig,
    vstnumdig         like datmvistoria.vstnumdig,
    vstautvol         smallint,
    vstautc24         smallint,
    diasem            smallint,
    corteltxt         char (12),
    datautil          date,
    vclcordes         char (11),
    anoatu            char (04),
    privez            char (01),
    retflg            char (01),
    confirma          char (01),
    codigosql         integer  ,
    erro              smallint ,
    msg               char(40) ,
    msg1              char(40) ,
    msg2              char(40) ,
    base              smallint ,
    vclporqtd         smallint ,
    vclcmbcod         smallint ,
    grlchv            like datkgeral.grlchv,
    conta             integer,
    ret               integer,
    hora              datetime hour to second,
    ctgtrfcod         like abbmcasco.ctgtrfcod
 end record

 define prompt_key    char (01)
 define sql_select    char (1200)
 define l_resposta    char(01)
 define l_ciaempcod   like datmservico.ciaempcod
 define l_condicao    char(100)
 define l_cont        smallint


    #-------------------------------------------------------------------------
    # Geraldo - validacao de chassi
    #-------------------------------------------------------------------------
    define lr_param_fvpic400 record
        vclchsinc   like apbmveic.vclchsinc,
        vclchsfnl   like apbmveic.vclchsfnl,
        vclcoddig   like apbmveic.vclcoddig
    end record
    define lr_retorno_fvpic400 record
        vclcoddig   like avlmchsvld.vclcoddig,
        vclanomdl   like avlmchsvld.vclanomdl,
        vclcmbcod   like avlmchsvld.vclcmbcod,
        vclporqtd   like avlmchsvld.vclporqtd
    end record
    define l_ret_fvpic400 smallint
    #-------------------------------------------------------------------------
    #-------------------------------------------------------------------------
    # Periodos de vp domiciliar
    #-------------------------------------------------------------------------
    define lr_entperhor record                  #-- Parametros para pesquisa
        ciaempcod   like datmservico.ciaempcod, #-- Codigo da Empresa
        vstfld      like avlmlaudo.vstfld,      #-- Codido da Finalidade da VP
        ufdcod      like datmlcl.ufdcod,        #-- Sigla do Estado
        cidcod      like glakcid.cidcod,        #-- Codigo da Cidade
        vstdat      like avlmlaudo.vstdat,      #-- Data do Agendamento
        solichor    datetime hour to minute     #-- Hora da Solicitacao
    end record
    define lr_saiperhorcontr record             #-- Controle dos periodos
        coderro     smallint,                   #-- Codigo de erro ou zero
        msgerro     char(100),                  #-- Mensagem de erro
        qtdper      smallint                    #-- Quantidade de periodos retornados
    end record
    define la_saiperhorper array[30] of record  #-- Periodos de horario
        cod_periodo smallint,                   #-- Codigo do periodo de horario
        cod_grupo   char(02),                   #-- Codigo do grupo de periodos
        pri_periodo char(01),                   #-- Prioridade do periodo de horario
        msg_periodo char(30)                    #-- Mensagem do periodo de horario
    end record
    define lr_saidacodper record                        #-- Periodo escolhido
        cod_periodo like avlkdomcampovst.vstcpodomcod,  #-- Codigo do periodo
        cod_grupo   char(02),                           #-- Codigo do grupo de periodos
        pri_periodo char(01),                           #-- Prioridade do periodo de horario
        msg_periodo char(30)                            #-- Mensagem do periodo de horario
    end record
    define l_contper    smallint                        #-- Contador
    #-------------------------------------------------------------------------
    let	prompt_key  =  null
    let	sql_select  =  null

    initialize  r_gcakfilial.*  to  null

    initialize  ws.*  to  null

 initialize hist_cts06m00.*  to null
 initialize ws.*             to null
 let int_flag = false
 let l_ciaempcod = null
 let l_condicao = null
 let l_cont = 1


 let sql_select = "select vstqtdaut, atrvstqtdc24,",
                  "       vstqtdvol, vstqtdc24    ",
                  "  from datmvstagen",
                  " where vstdat = ? ",
                  "   and succod = ? "
 prepare sel_agenda from sql_select
 declare c_agenda cursor with hold for sel_agenda

 if param.operacao = "M"  then
    let salva.vstdat    = d_cts06m00.vstdat
    let salva.vcllicnum = d_cts06m00.vcllicnum
    let salva.vclchsnum = d_cts06m00.vclchsnum
    let salva.lgdcep    = d_cts06m00.lgdcep
 end if

 let salva.vstc24tip = d_cts06m00.vstc24tip

 if param.operacao = "I"  then
    let ws.privez = "S"
 else
    let ws.privez = "N"
 end if

 let ws.grlchv = "mvisto",
                 g_issk.funmat using "&&&&&&",
                 g_issk.maqsgl clipped
 select count(*)
      into ws.conta
      from datkgeral
     where grlchv = ws.grlchv
 if ws.conta  > 0  then
    delete from datkgeral
       where grlchv = ws.grlchv
 end if
 let ws.conta = 0

 input by name d_cts06m00.c24solnom,
               d_cts06m00.c24soltipcod,
               d_cts06m00.vstdat,
               d_cts06m00.vstc24tip,
               d_cts06m00.succod,
               d_cts06m00.ciaempcod,
               d_cts06m00.vstfld,
               #d_cts06m00.vstregcod,
               #---------------------------------------------------
               d_cts06m00.vcllicnum,
               d_cts06m00.vclchsnum,
               d_cts06m00.vclrnvnum,
               d_cts06m00.vclcoddig,
               #d_cts06m00.vclmrcnom,
               #d_cts06m00.vcltipnom,
               #d_cts06m00.vclmdlnom,
               d_cts06m00.vclcordes,
               d_cts06m00.vclanofbc,
               d_cts06m00.vclanomdl,
               #---------------------------------------------------
               d_cts06m00.lgdcep,
               d_cts06m00.lgdcepcmp,
               d_cts06m00.corsus,
               d_cts06m00.cornom,
               d_cts06m00.cordddcod,
               d_cts06m00.cortelnum,
               d_cts06m00.segnom,
               d_cts06m00.pestip,
               d_cts06m00.cgccpfnum,
               d_cts06m00.cgcord,
               d_cts06m00.cgccpfdig,
               d_cts06m00.segematxt,
               d_cts06m00.prfhor,
               #d_cts06m00.horobs,
               d_cts06m00.atdprinvlcod,
               d_cts06m00.atdatznom
               without defaults

    before field c24solnom
       display by name d_cts06m00.c24solnom attribute (reverse)

       if param.operacao = "I"   and
          w_cts06m00.corsus is not null then
          let d_cts06m00.corsus = w_cts06m00.corsus
          select gcakcorr.cornom
            into d_cts06m00.cornom
            from gcakfilial,
                 gcaksusep,
                 gcakcorr
           where gcaksusep.corsus     = d_cts06m00.corsus
             and gcaksusep.corsuspcp  = gcakfilial.corsuspcp
             and gcakfilial.corfilnum = 1
             and gcakcorr.corsuspcp   = gcakfilial.corsuspcp
          #---> Utilizacao da nova funcao de comissoes p/ enderecamento
          initialize r_gcakfilial.* to null
          call fgckc811(d_cts06m00.corsus)
               returning r_gcakfilial.*
          let d_cts06m00.cordddcod = r_gcakfilial.dddcod
          let ws.corteltxt         = r_gcakfilial.teltxt
          #------------------------------------------------------------

          if ws.corteltxt is not null  then
             call cts09g02(d_cts06m00.cordddcod, ws.corteltxt)
                          returning d_cts06m00.cordddcod,
                                    d_cts06m00.cortelnum
          end if
          display by name d_cts06m00.corsus
          display by name d_cts06m00.cornom
          display by name d_cts06m00.cordddcod
          display by name d_cts06m00.cortelnum
          if d_cts06m00.c24solnom is not null then
             next field c24soltipcod
          end if
       end if

    after field c24solnom
       display by name d_cts06m00.c24solnom

       if d_cts06m00.c24solnom  is null   then
          error " Nome do solicitante deve ser informado!"
          next field c24solnom
       end if

    before field c24soltipcod
       display by name d_cts06m00.c24soltipcod attribute (reverse)

    after field c24soltipcod
       display by name d_cts06m00.c24soltipcod

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if d_cts06m00.c24soltipcod  is null   then
             error " Tipo do solicitante deve ser informado!"
             let d_cts06m00.c24soltipcod = cto00m00(1)
             next field c24soltipcod
          end if

          select c24soltipdes
            into d_cts06m00.c24soltipdes
            from datksoltip
                 where c24soltipcod = d_cts06m00.c24soltipcod

          if  sqlca.sqlcode = notfound  then
              error " Tipo de solicitante nao cadastrado!"
              let d_cts06m00.c24soltipcod = cto00m00(1)
              next field c24soltipcod
          end if

          if  d_cts06m00.c24soltipcod < 3 then
              let w_cts06m00.atdsoltip = d_cts06m00.c24soltipdes[1,1]
          else
              let w_cts06m00.atdsoltip = "O"
          end if
          display by name d_cts06m00.c24soltipdes
       end if

    before field vstdat
       display by name d_cts06m00.vstdat attribute (reverse)

    after field vstdat
       display by name d_cts06m00.vstdat

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if d_cts06m00.vstdat  is null   then
             error " Data para realizacao da vistoria deve ser informada!"
             next field vstdat
          end if

          if d_cts06m00.vstdat  <  today    then
             error " Data da realizacao nao deve ser menor que a data atual!"
             next field vstdat
          else
             if d_cts06m00.vstdat  >=  today + 30 units day  then
                error " Data da realizacao nao deve ser maior/igual a um mes!"
                next field vstdat
             end if
          end if

#-- Quando necessario simular horas
#if g_issk.funmat = 7339 or
#   g_issk.funmat = 6990 then
#   initialize w_hora to null
#   prompt "Digite a hora a simular, Exemplo 16:00 : " for w_hora
#   if w_hora is null then
#      let w_hora = current hour to minute
#   end if
#end if
          if w_hora >= "16:00" and (d_cts06m00.vstdat = today) then
             call cts08g01("A","N","","Apos as 16:00 horas marcar VP","","para o dia seguinte!")
                  returning ws.confirma
             next field vstdat
          end if
	  #------------------------------------------------------------
	  #CT 729086 - Consistir marcacao de VP aos Domingos e Feriados
          #Analista : Geraldo Souza / Data : 07/10/2009
	  #------------------------------------------------------------
             call c24geral9(d_cts06m00.vstdat, 0,"01000","N","S")
                  returning ws.datautil
             if ws.datautil  is not null   then                #
                if d_cts06m00.vstdat  <>  ws.datautil  then    #  Feriado
                   let ws.diasem = 0                           #
                   error "Nao e' possivel agendar vistorias aos Feriados!"
                   next field vstdat
                end if
             end if

          if param.operacao  =  "M"   then
             if d_cts06m00.vstdat  <>  salva.vstdat  then
                if salva.vstdat     =  today         then
                   error " Nao e' possivel alterar data para vistoria",
                         " a ser realizada hoje!"
                   next field vstdat
                end if
                if salva.vstdat < today  then
                   error " Nao e' possivel alterar data de vistoria ja'",
                         " realizada! Marque nova vistoria!"
                   next field vstdat
                end if
             end if
          end if
       end if

    before field vstc24tip
       if d_cts06m00.vstnumdig is null  and
          d_cts06m00.atdsrvnum is null  then
          if d_cts06m00.vstdat = today  then
             let d_cts06m00.vstc24tip = 1    # nao roterizada ct24hs
          else
             let d_cts06m00.vstc24tip = 0    # roterizada
          end if
       end if
       display by name d_cts06m00.vstc24tip attribute (reverse)

    after field vstc24tip
       display by name d_cts06m00.vstc24tip

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          initialize w_cts06m00.atdfnlflg  to null

          if d_cts06m00.vstc24tip  is  null  then
             let d_cts06m00.vstc24tip = 0
          end if

          display by name d_cts06m00.vstc24tip
          #Geraldo Souza - Data 07/10/2009
          if d_cts06m00.vstc24tip  =  1   then
             let d_cts06m00.vstc24des = "CENTRAL"
             display by name d_cts06m00.vstc24des
             if d_cts06m00.vstdat  >  today    then
                error " Data realizacao deve ser igual a data atual!"
                next field vstdat
             end if
             let w_cts06m00.atdfnlflg = "N"
          else
             if d_cts06m00.vstc24tip  =  0  then
               #let w_cts06m00.atdfnlflg = "S" #rainieri - chamado 3102244
                let w_cts06m00.atdfnlflg = "N"
                let d_cts06m00.vstc24des = "VOLANTE"
                display by name d_cts06m00.vstc24des
                if d_cts06m00.vstdat  =  today    then
                   error " Data de realizacao deve ser maior que a data atual!"
                   next field vstdat
                end if
             else
                error " Tipo da vistoria: (0)VOLANTE ou (1)CENTRAL 24 HORAS!"
                next field vstc24tip
             end if
          end if
       end if
    before field succod
       if param.operacao = "I"   then
          if d_cts06m00.succod is null then
             let d_cts06m00.succod = g_issk.succod
          end if
          if w_cts06m00.flgerro = 1 then
             #initialize d_cts06m00.vstregcod to null
             #initialize d_cts06m00.vstregsgl to null
             #display by name d_cts06m00.vstregcod
             #display by name d_cts06m00.vstregsgl
             initialize d_cts06m00.succod to null
             initialize d_cts06m00.sucnom to null
             display by name d_cts06m00.succod
             display by name d_cts06m00.sucnom
          end if
       else
          if param.operacao = "M"   then
             next field vstfld
          end if
       end if
       display by name d_cts06m00.succod    attribute (reverse)

    after  field succod
       let w_cts06m00.flgerro = 0
       display by name d_cts06m00.succod

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
         #if d_cts06m00.succod is null  then
         #   error "ATENCAO: Digite  01-Sao Paulo  ou  02-Rio de Janeiro. "
         #   let w_cts06m00.flgerro = 1
         #   next field succod
         #end if
          #-- Obter o nome da sucursal --#
          call f_fungeral_sucursal(d_cts06m00.succod)
          returning d_cts06m00.sucnom

#         select sucnom
#           into d_cts06m00.sucnom
#           from gabksuc
#         where succod = d_cts06m00.succod
#         if sqlca.sqlcode = notfound  then

          if d_cts06m00.sucnom is null then
             error " Sucursal nao cadastrada!"
             call c24geral11()
                  returning d_cts06m00.succod, d_cts06m00.sucnom
             next field succod
          end if

          display by name d_cts06m00.succod
          display by name d_cts06m00.sucnom

          if  g_issk.dptsgl  <>  "desenv"  then
              if g_outFigrc012.Is_Teste and #ambnovo
                  g_issk.funmat = 5048  then

## PSI 183644 - Inicio

##              else
##                 if g_issk.dptsgl = "ct24hs" then
##                    if d_cts06m00.succod <> 01 and   # S.paulo
##                       d_cts06m00.succod <> 02 then  # RJ
##                       error "Vistoria so e valida para as sucursais ",
##                             "01-S.Paulo ou 02-RJ."
##                       next field succod
##                    else
##                       if d_cts06m00.vstc24tip  =  1  and
##                          d_cts06m00.succod     =  2  then  # RJ
##                          error "Essa sucursal nao realiza V.P. no mesmo dia"
##                          next field succod
##                       end if
##                    end if
##                 else
##                    if g_issk.funmat = 908  or
##                       g_issk.funmat = 9775 or
##                       g_issk.funmat = 9974 or
##                       g_issk.funmat = 505  or
##                       g_issk.funmat = 270  or
##                       g_issk.funmat = 9109 or
##                       g_issk.funmat = 502  or    # sofia 04/02/03
##                       g_issk.funmat = 8644 or    # sofia 04/02/03
##                       g_issk.funmat = 9771 or    # sofia 17/03/03
##                       g_issk.funmat = 507  or    # sofia 11/04/03
##                       g_issk.funmat = 1402 then  # sofia 11/04/03
##                       ## autorizar a marcacao de vp para outra sucursal a
##                       ## pedido da Miriam/sofia (ct24h) 24/01/2003
##                    else
##                       if d_cts06m00.succod  <>  g_issk.succod   then
##                          error " Nao devem ser marcadas vistorias para",
##                                " outra sucursal!"
##                          next field succod
##                       end if
##                    end if
##                 end if

## PSI 183644 - Final

              end if
          end if
       end if

    #------------------------------------------------------------
    # Zyon 03/03/2008 - Solicita confirmacao do codigo da empresa
    #------------------------------------------------------------
    before field ciaempcod

        display d_cts06m00.ciaempcod to ciaempcod attribute (reverse)
    after field ciaempcod

        if d_cts06m00.ciaempcod is null or
           d_cts06m00.ciaempcod <= 0 then
            let l_cont = 1

            whenever error continue
            open ccts06m00012
            foreach ccts06m00012 into l_ciaempcod


               if l_cont = 1 then
                  let l_condicao = l_ciaempcod
               else
                  let l_condicao = l_condicao clipped, ',', l_ciaempcod
               end if

               let l_cont = l_cont + 1

            end foreach


            let sql_select = " select gabkemp.empcod, ",
                             "        gabkemp.empnom  ",
                             "   from gabkemp         ",
                             "  where empcod in (",l_condicao clipped ,")",
                             "  order by gabkemp.empcod "


            call ofgrc001_popup(10
                               ,10
                               ,'CADASTRO DE EMPRESAS ATENDIDAS PELA VP'
                               ,'CODIGO'
                               ,'EMPRESA'
                               ,'N'
                               ,sql_select
                               ,''
                               ,'D')
                     returning ws.ret,
                               d_cts06m00.ciaempcod,
                               d_cts06m00.empnom
            if ws.ret <> 0 or
               d_cts06m00.ciaempcod <= 0 then
                error "Empresa nao cadastrada ou nao atendida pela vistoria !"
                next field ciaempcod
            end if
        else
            whenever error continue
            open ccts06m00011 using d_cts06m00.ciaempcod
            fetch ccts06m00011 into l_ciaempcod
            if sqlca.sqlcode <> 0 then
                error "Empresa nao atendida pela vistoria !"
                close ccts06m00011
                next field ciaempcod
            else
              open ccts06m00004 using l_ciaempcod
              fetch ccts06m00004 into d_cts06m00.empnom
              if sqlca.sqlcode <> 0 then
                error "Empresa nao cadastrada !"
                close ccts06m00004
                next field ciaempcod
              end if
            end if
            whenever error stop
            close ccts06m00004
            close ccts06m00011
        end if
        display d_cts06m00.ciaempcod to ciaempcod
        display d_cts06m00.empnom    to empnom
        #-----------------------------------------------------
        # Se a empresa for 35-Azul assume a finalidade 22-Azul
        # ate que a VP decida o que fazer com a cobranca
        #-----------------------------------------------------
        if d_cts06m00.ciaempcod = 35 then
            if d_cts06m00.vstfld is null or
               d_cts06m00.vstfld <> 22 then
                let d_cts06m00.vstfld = 22
                open ccts06m00005 using d_cts06m00.vstfld
                fetch ccts06m00005 into d_cts06m00.vstflddes
                if sqlca.sqlcode = notfound  then
                    close ccts06m00005
                    error " Finalidade da vistoria invalida!"
                    next field ciaempcod
                else
                   let d_cts06m00.vstflddes = upshift(d_cts06m00.vstflddes)
                   display by name d_cts06m00.vstfld
                   display by name d_cts06m00.vstflddes
                end if
                close ccts06m00005
            end if
        else
            if d_cts06m00.vstfld = 22 then
                let d_cts06m00.vstfld    = null
                let d_cts06m00.vstflddes = null
                display by name d_cts06m00.vstfld
                display by name d_cts06m00.vstflddes
            end if
        end if
    #------------------------------------------------------------
    before field vstfld

       #-------------------------------------------------------
       # Verifica se limite de V.P. nao foi excedido para data (ct24hs)
       #-------------------------------------------------------

      if d_cts06m00.vstc24tip   =    1   then   # nao roterizada
         open  c_agenda using d_cts06m00.vstdat,
                              d_cts06m00.succod
         fetch c_agenda into  ws.vstqtdaut, ws.atrvstqtdc24,
                              ws.vstqtdvol, ws.vstqtdc24
         if sqlca.sqlcode = notfound  then
            let ws.diasem = weekday(d_cts06m00.vstdat)
            call c24geral9(d_cts06m00.vstdat, 0,"01000","N","S")
                 returning ws.datautil
            if ws.datautil  is not null   then                #
               if d_cts06m00.vstdat  <>  ws.datautil  then    #  Feriado
                  let ws.diasem = 0                           #
               end if
            end if
            let ws.vstautc24 = 50
            if ws.diasem     = 0  then         #--> Domingo/Feriado
               let ws.vstautc24 = 10
            else
               if ws.diasem = 6  then
                  let ws.vstautc24 = 15
               end if
            end if
         end if
         close c_agenda
         if (param.operacao  = "I")              or
            (param.operacao = "M"                and
             d_cts06m00.vstdat <> salva.vstdat)  then
            if ws.atrvstqtdc24  <>  0   then
               let ws.vstqtdc24    =  ws.vstqtdc24 + 1
               if ws.atrvstqtdc24  <  ws.vstqtdc24   then
                  error " Limite de vistorias previas excedido para esta data!"
                  call cts06m04() returning  d_cts06m00.atdatznom
                  if d_cts06m00.atdatznom  is null   then
                     error " Vistoria deve ser autorizada!"
                     next field vstdat
                  end if
                  display by name d_cts06m00.atdatznom
               end if
            end if
         end if
      end if
      let w_cts06m00.atddatprg = d_cts06m00.vstdat
      display by name d_cts06m00.vstfld    attribute (reverse)
      #-------------------------------------------------------------
      # Se for empresa 35-Azul e finalidade 22-Azul vai para a placa
      #-------------------------------------------------------------
      if d_cts06m00.ciaempcod = 35 and
         d_cts06m00.vstfld    = 22 then
          display by name d_cts06m00.vstfld
          display by name d_cts06m00.vstflddes
          next field vcllicnum
      end if
    after field vstfld
       display by name d_cts06m00.vstfld
       if d_cts06m00.vstfld is null  then
            let sql_select = "select avlkdomcampovst.vstcpodomcod, ",
                             "       avlkdomcampovst.vstcpodomdes  ",
                             "  from avlkdomcampovst               ",
                             " where avlkdomcampovst.vstcpocod = 1 ",
                             "   and avlkdomcampovst.atlult[09,12] <> 'DELE' "
            call ofgrc001_popup(10
                               ,10
                               ,'FINALIDADES'
                               ,'CODIGO'
                               ,'DESCRICAO'
                               ,'N'
                               ,sql_select
                               ,''
                               ,'D')
                     returning ws.ret,
                               d_cts06m00.vstfld,
                               d_cts06m00.vstflddes
            if ws.ret <> 0 or
                d_cts06m00.vstfld <= 0 then
                error "Finalidade da vistoria deve ser informada !"
                next field vstfld
            end if
            display by name d_cts06m00.vstfld
            display by name d_cts06m00.vstflddes
       else
            open ccts06m00005 using d_cts06m00.vstfld
            fetch ccts06m00005 into d_cts06m00.vstflddes
            if sqlca.sqlcode = notfound  then
                close ccts06m00005
                error " Finalidade da vistoria invalida!"
                next field vstfld
            else
                let d_cts06m00.vstflddes = upshift(d_cts06m00.vstflddes)
                display by name d_cts06m00.vstfld
                display by name d_cts06m00.vstflddes
            end if
            close ccts06m00005
       end if
       #-------------------------------------------------
       # Para empresa 35-Azul finalidade deve ser 22-Azul
       #-------------------------------------------------
       if d_cts06m00.ciaempcod = 35 and
          d_cts06m00.vstfld   <> 22 then
            error " Para Empresa 35-Azul Finalidade deve ser 22-Azul !"
            next field vstfld
       end if
       #-------------------------------------------------
       # Para finalidade 22-Azul empresa deve ser 35-Azul
       #-------------------------------------------------
       if d_cts06m00.ciaempcod <> 35 and
          d_cts06m00.vstfld     = 22 then
            error " Para Finalidade 22-Azul Empresa deve ser 35-Azul !"
            next field vstfld
       end if
#       if d_cts06m00.succod = 2  then
#          let a_cts06m00[1].ufdcod = "RJ"
#          call cts06m00_busca_endereco() returning ws.retflg
#          if ws.retflg = "N"  then
#             next field vstfld
#          end if
#          if w_cts06m00.flgerro = 1 then
#             next field succod
#          end if
#          next field lgdcep
#       end if
###     before field vstregcod
### #      if d_cts06m00.succod = 2  then  # Judite 10/11/2006
###        if d_cts06m00.succod <> 1 then  # solicita regiao so p/ sao paulo
###           next field vclcoddig         #     Judite 10/11/2006
###        end if
###
###        display by name d_cts06m00.vstregcod attribute (reverse)
###        if ws.privez = "S"  then
###           call cts06m07(d_cts06m00.vstc24tip) returning d_cts06m00.vstregcod
###           let ws.privez = "N"
###        end if
###
###     after field vstregcod
###        display by name d_cts06m00.vstregcod
###
###        if fgl_lastkey() <> fgl_keyval("up")    and
###           fgl_lastkey() <> fgl_keyval("left")  then
###           if d_cts06m00.vstregcod is null  then
###              error " Regiao para vistoria deve ser informada!"
###              call cts06m07(d_cts06m00.vstc24tip)
###                  returning d_cts06m00.vstregcod
###              next field vstregcod
###           else
###              select vstregsgl
###                into d_cts06m00.vstregsgl
###                from avckreg
###               where vstregcod    = d_cts06m00.vstregcod
###                 and vstatdtip   >= d_cts06m00.vstc24tip
###
###              if sqlca.sqlcode = notfound  then
###                 error " Regiao para vistoria nao cadastrada no roteiro!"
###                 call cts06m07(d_cts06m00.vstc24tip)
###                     returning d_cts06m00.vstregcod
###                 next field vstregcod
###              end if
###              display by name d_cts06m00.vstregsgl
###           end if
###           if d_cts06m00.succod = 1 then
###              let a_cts06m00[1].ufdcod = "SP"
###           else
###              if d_cts06m00.succod = 2  then
###                 let a_cts06m00[1].ufdcod = "RJ"
###              end if
###           end if
###           next field vclcoddig
###          #call cts06g03(1, 10 , 0,
###          #           w_data,
###          #           w_hora,
###          #           a_cts06m00[1].lclidttxt,
###          #           a_cts06m00[1].cidnom,
###          #           a_cts06m00[1].ufdcod,
###          #           a_cts06m00[1].brrnom,
###          #           a_cts06m00[1].lclbrrnom,
###          #           a_cts06m00[1].endzon,
###          #           a_cts06m00[1].lgdtip,
###          #           a_cts06m00[1].lgdnom,
###          #           a_cts06m00[1].lgdnum,
###          #           a_cts06m00[1].lgdcep,
###          #           a_cts06m00[1].lgdcepcmp,
###          #           a_cts06m00[1].lclltt,
###          #           a_cts06m00[1].lcllgt,
###          #           a_cts06m00[1].lclrefptotxt,
###          #           a_cts06m00[1].lclcttnom,
###          #           a_cts06m00[1].dddcod,
###          #           a_cts06m00[1].lcltelnum,
###          #           a_cts06m00[1].c24lclpdrcod,
###          #           a_cts06m00[1].ofnnumdig,
###          #           hist_cts06m00.*)
###          # returning a_cts06m00[1].lclidttxt,
###          #           a_cts06m00[1].cidnom,
###          #           a_cts06m00[1].ufdcod,
###          #           a_cts06m00[1].brrnom,
###          #           a_cts06m00[1].lclbrrnom,
###          #           a_cts06m00[1].endzon,
###          #           a_cts06m00[1].lgdtip,
###          #           a_cts06m00[1].lgdnom,
###          #           a_cts06m00[1].lgdnum,
###          #           a_cts06m00[1].lgdcep,
###          #           a_cts06m00[1].lgdcepcmp,
###          #           a_cts06m00[1].lclltt,
###          #           a_cts06m00[1].lcllgt,
###          #           a_cts06m00[1].lclrefptotxt,
###          #           a_cts06m00[1].lclcttnom,
###          #           a_cts06m00[1].dddcod,
###          #           a_cts06m00[1].lcltelnum,
###          #           a_cts06m00[1].c24lclpdrcod,
###          #           a_cts06m00[1].ofnnumdig      ,
###          #           ws.retflg,
###          #           hist_cts06m00.*
###          #let a_cts06m00[1].lgdtxt = a_cts06m00[1].lgdtip clipped, " ",
###          #                           a_cts06m00[1].lgdnom clipped, " ",
###          #                           a_cts06m00[1].lgdnum using "<<<<#"
###          #display by name a_cts06m00[1].lgdtxt
###          #display by name a_cts06m00[1].lgdcep
###          #display by name a_cts06m00[1].lgdcepcmp
###          #display by name a_cts06m00[1].lclbrrnom
###          #display by name a_cts06m00[1].cidnom
###          #display by name a_cts06m00[1].ufdcod
###          #display by name a_cts06m00[1].lclrefptotxt
###          #display by name a_cts06m00[1].lclcttnom
###          #display by name a_cts06m00[1].dddcod
###          #display by name a_cts06m00[1].lcltelnum
###          #let d_cts06m00.lgdcep    =  a_cts06m00[1].lgdcep
###          #let d_cts06m00.lgdcepcmp =  a_cts06m00[1].lgdcepcmp
###
###          #if d_cts06m00.succod     = 1    and
###          #   a_cts06m00[1].ufdcod <> "SP" then
###          #   error "Endereco nao confere com a Sucursal informada.."
###          #   next field succod
###          #else
###          #   if d_cts06m00.succod     =  2   and
###          #      a_cts06m00[1].ufdcod <> "RJ" then
###          #      error "Endereco nao confere com a Sucursal informada.."
###          #      next field succod
###          #   end if
###          #end if
###          #if ws.retflg = "N"  then
###          #   error " Dados referentes ao local incorretos ou nao preenchidos!"
###          #   next field vstregcod
###          #end if
###        end if

    before field vcllicnum
       display by name d_cts06m00.vcllicnum   attribute (reverse)

    after field vcllicnum
       display by name d_cts06m00.vcllicnum

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.vcllicnum is not null  then
             if not srp1415(d_cts06m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if

             if salva.vcllicnum is null  or
                salva.vcllicnum <> d_cts06m00.vcllicnum  then
                #------------------------------------------------------
                # Recupera vistoria marcada para o mesmo dia pela placa
                #------------------------------------------------------
                initialize ws.vstnumdig to null
                open ccts06m00007 using d_cts06m00.vstdat,
                                        d_cts06m00.vcllicnum
                foreach ccts06m00007 into ws.vstnumdig
                end foreach
                close ccts06m00007
                if ws.vstnumdig is not null  then
                   let ws.msg1 = "JA' FOI MARCADA A VISTORIA ", ws.vstnumdig
                   let ws.msg2 = " NESTA DATA PARA ESTE VEICULO !"
                   call cts08g01("A","S","",ws.msg1,"",ws.msg2)
                                 returning ws.confirma
                   if ws.confirma = "N"  then
                      next field vcllicnum
                   end if
                end if
             end if
          end if
       else
          #-----------------------------------------------------------
          # Se empresa 35-Azul e finalidade 22-Azul vai para a empresa
          #-----------------------------------------------------------
          if d_cts06m00.ciaempcod = 35 and
             d_cts06m00.vstfld    = 22 then
              next field ciaempcod
          end if
       end if

    before field vclchsnum
        display by name d_cts06m00.vclchsnum   attribute (reverse)

    after field vclchsnum
        display by name d_cts06m00.vclchsnum
        if fgl_lastkey() <> fgl_keyval("up")    and
           fgl_lastkey() <> fgl_keyval("left")  then
            if d_cts06m00.vcllicnum  is null   and
               d_cts06m00.vclchsnum  is null   then
                error " Placa ou Chassi do veiculo deve ser informado!"
                next field vcllicnum
            end if
            initialize mr_entrada_bloq.*    to null
            initialize mr_retorno_bloq.*    to null
            let mr_entrada_bloq.ciaempcod   = d_cts06m00.ciaempcod  # Hoje nao usa
            let mr_entrada_bloq.vstfld      = d_cts06m00.vstfld     # Hoje nao usa
            let mr_entrada_bloq.ufdcod      = ''                    # Hoje nao usa
            let mr_entrada_bloq.cidcod      = 0                     # Hoje nao usa
            let mr_entrada_bloq.chassi      = d_cts06m00.vclchsnum
            let mr_entrada_bloq.placa       = d_cts06m00.vcllicnum
            let mr_entrada_bloq.renavam     = d_cts06m00.vclrnvnum  # Hoje nao usa
            call fvpic180(mr_entrada_bloq.ciaempcod,
                          mr_entrada_bloq.vstfld,
                          mr_entrada_bloq.ufdcod,
                          mr_entrada_bloq.cidcod,
                          mr_entrada_bloq.chassi,
                          mr_entrada_bloq.placa,
                          mr_entrada_bloq.renavam)
                returning mr_retorno_bloq.codigo,
                          mr_retorno_bloq.descricao
            if mr_retorno_bloq.codigo is null then
                let int_flag = true
                exit input
            end if
            if mr_retorno_bloq.codigo = 2 then
                error " Informe chassi ou placa "
                sleep 3
                next field vcllicnum
            end if
            if mr_retorno_bloq.codigo = 1 then
                error mr_retorno_bloq.descricao clipped
                call cts08g01("A",
                              "N",
                              "Para este veiculo e necessaria a",
                              "realizacao de uma Vistoria Especial,",
                              "que deve ser agendada nos postos",
                              "autorizados.")
                    returning l_resposta
                next field vcllicnum
            end if
            if mr_retorno_bloq.codigo = 101 then
                error mr_retorno_bloq.descricao clipped
                call cts08g01("A",
                              "N",
                              "",
                              "Esta vistoria deve ser agendada",
                              "em qualquer posto autorizado.",
                              "")
                    returning l_resposta
                next field vcllicnum
            end if
            error mr_retorno_bloq.descricao clipped
            if d_cts06m00.vclchsnum is not null  then
                if salva.vclchsnum is null  or
                   salva.vclchsnum <> d_cts06m00.vclchsnum  then
                    #-------------------------------------------------------
                    # Recupera vistoria marcada para o mesmo dia pelo chassi
                    #-------------------------------------------------------
                    initialize ws.vstnumdig to null
                    open ccts06m00008 using d_cts06m00.vstdat,
                                            d_cts06m00.vclchsnum
                    foreach ccts06m00008 into ws.vstnumdig
                    end foreach
                    close ccts06m00008
                    if ws.vstnumdig is not null  then
                        let ws.msg1 = "JA' FOI MARCADA A VISTORIA ", ws.vstnumdig
                        let ws.msg2 = " NESTA DATA PARA ESTE VEICULO !"
                        call cts08g01("A","S","",ws.msg1,"",ws.msg2)
                            returning ws.confirma
                        if ws.confirma = "N"  then
                            next field vclchsnum
                        end if
                    end if
                end if
            end if
        else
            next field vcllicnum
        end if
    before field vclrnvnum
        display by name d_cts06m00.vclrnvnum  attribute (reverse)
    after  field vclrnvnum
       display by name d_cts06m00.vclrnvnum
    before field vclcoddig
        display by name d_cts06m00.vclcoddig  attribute (reverse)
    after  field vclcoddig
       display by name d_cts06m00.vclcoddig
       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts06m00.vclcoddig is null  or
                d_cts06m00.vclcoddig =  0     then
                call akgcvers(2)
                     returning d_cts06m00.vclcoddig,
                               d_cts06m00.vclanomdl,
                               ws.vclporqtd,
                               ws.vclcmbcod

                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts06m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if
            #-----------------------------------------------------
            # Recupera marca, tipo e modelo do veiculo pelo codigo
            #-----------------------------------------------------
             open ccts06m00009 using d_cts06m00.vclcoddig
             fetch ccts06m00009 into d_cts06m00.vclmrcnom,
                                     d_cts06m00.vcltipnom,
                                     d_cts06m00.vclmdlnom
             close ccts06m00009
             display by name d_cts06m00.vclmrcnom
             display by name d_cts06m00.vcltipnom
             display by name d_cts06m00.vclmdlnom
             display by name d_cts06m00.vclanomdl

             if d_cts06m00.vclanomdl < "1995"  then

                select autctgatu into ws.ctgtrfcod
                  from agetdecateg
                 where vclcoddig  = d_cts06m00.vclcoddig
                   and viginc    <= w_data
                   and vigfnl    >= w_data

                if ws.ctgtrfcod <> 40 and ws.ctgtrfcod <> 41 and
                   ws.ctgtrfcod <> 42 and ws.ctgtrfcod <> 43 and
                   ws.ctgtrfcod <> 50 and ws.ctgtrfcod <> 51 and
                   ws.ctgtrfcod <> 52 and ws.ctgtrfcod <> 53 and
                   ws.ctgtrfcod <> 58 and ws.ctgtrfcod <> 59 and
                   ws.ctgtrfcod <> 60 and ws.ctgtrfcod <> 61 and
                   ws.ctgtrfcod <> 62 and ws.ctgtrfcod <> 63 and
                   ws.ctgtrfcod <> 72 and ws.ctgtrfcod <> 73 then
                   call cts08g01("A","N","Ano modelo nao pode ser","anterior ao ano de 1995!","","Indique um posto de vistoria!")
                        returning ws.confirma
                   next field vclcoddig
                end if
             end if
       end if
        #-------------------------------------------------------------------
        # Geraldo - Validacao de chassi - Inicio
        #-------------------------------------------------------------------
        initialize lr_param_fvpic400.*    to null
        initialize lr_retorno_fvpic400.*  to null
        initialize l_ret_fvpic400         to null
        initialize m_val_chassi_veic      to null
        initialize m_his_chassi_veic      to null
        let lr_param_fvpic400.vclchsinc = d_cts06m00.vclchsnum[01,12]
        let lr_param_fvpic400.vclchsfnl = d_cts06m00.vclchsnum[13,20]
        call fvpic400_chassi(lr_param_fvpic400.vclchsinc,
                             lr_param_fvpic400.vclchsfnl)
                   returning l_ret_fvpic400,
                             lr_retorno_fvpic400.vclcoddig,
                             lr_retorno_fvpic400.vclanomdl,
                             lr_retorno_fvpic400.vclcmbcod,
                             lr_retorno_fvpic400.vclporqtd
        case l_ret_fvpic400
            when 0
                let m_val_chassi_veic = "     "
                initialize m_his_chassi_veic      to null
                initialize lr_param_fvpic400.*    to null
                initialize lr_retorno_fvpic400.*  to null
                initialize l_ret_fvpic400         to null
                let lr_param_fvpic400.vclchsinc = d_cts06m00.vclchsnum[01,12]
                let lr_param_fvpic400.vclchsfnl = d_cts06m00.vclchsnum[13,20]
                let lr_param_fvpic400.vclcoddig = d_cts06m00.vclcoddig
                call fvpic400_modelo(lr_param_fvpic400.vclchsinc,
                                     lr_param_fvpic400.vclchsfnl,
                                     lr_param_fvpic400.vclcoddig)
                           returning l_ret_fvpic400,
                                     lr_retorno_fvpic400.vclcoddig,
                                     lr_retorno_fvpic400.vclanomdl,
                                     lr_retorno_fvpic400.vclcmbcod,
                                     lr_retorno_fvpic400.vclporqtd
                case l_ret_fvpic400
                    when 0
                        let m_val_chassi_veic = "     "
                        initialize m_his_chassi_veic      to null
                    when 1
                        let m_val_chassi_veic = "-VEIC"
                        let m_his_chassi_veic = "MODELO DO VEICULO DIVERGE DO CHASSI INFORMADO"
                    otherwise
                        error "Erro ao validar chassi"
                        next field vclchsnum
                end case
            when 1
                let m_val_chassi_veic = "-CHAS"
                let m_his_chassi_veic = "CHASSI INFORMADO INVALIDO"
            otherwise
                error "Erro ao validar chassi"
                next field vclchsnum
        end case
        #-------------------------------------------------------------------
    before field vclcordes
       display by name d_cts06m00.vclcordes  attribute (reverse)

    after  field vclcordes
       display by name d_cts06m00.vclcordes

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.vclcordes  is null   then
             error " Cor do veiculo deve ser informada!"
             call c24geral4() returning w_cts06m00.vclcorcod,
                                        d_cts06m00.vclcordes
             next field vclcordes
          end if

          let ws.vclcordes = d_cts06m00.vclcordes[2,9]

          select cpocod
            into w_cts06m00.vclcorcod
            from iddkdominio
           where cponom      = "vclcorcod"   and
                 cpodes[2,9] = ws.vclcordes

          if sqlca.sqlcode = notfound    then
             error " Cor fora do padrao!"
             call c24geral4() returning w_cts06m00.vclcorcod,
                                        d_cts06m00.vclcordes
             next field vclcordes
          end if
          display by name  d_cts06m00.vclcordes
       end if

    before field vclanofbc
       display by name d_cts06m00.vclanofbc   attribute (reverse)

    after field vclanofbc
       display by name d_cts06m00.vclanofbc

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.vclanofbc  is null   then
             error " Ano de fabricacao do veiculo deve ser informado!"
             next field vclanofbc
          end if

          if d_cts06m00.vclanofbc > current year to year  then
             let ws.anoatu = current year to year
             error " Ano de fabricacao nao pode ser maior que ", ws.anoatu, "!"
             next field vclanofbc
          end if

          if d_cts06m00.vclanofbc < "1990"  and
             d_cts06m00.vstc24tip = 1       and
             time > "17:30"                 then
             error " Vistoria para veiculos anteriores a 1990",
                   " nao podem ser marcadas apos `as 17:30!"
             next field vclanofbc
          end if
       end if

    before field vclanomdl
       display by name d_cts06m00.vclanomdl   attribute (reverse)

    after field vclanomdl
       display by name d_cts06m00.vclanomdl

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field vclanofbc
       end if

       if d_cts06m00.vclanomdl  is null   then
          error " Ano modelo do veiculo deve ser informado!"
          next field vclanomdl
       end if

       if d_cts06m00.vclanomdl < d_cts06m00.vclanofbc  then
          error " Ano modelo nao pode ser anterior ao ano de fabricacao!"
          next field vclanomdl
       end if

       if d_cts06m00.vclanomdl > d_cts06m00.vclanofbc + 1 units year  then
          error " Ano modelo nao pode ser superior a ano de fabricacao!"
          next field vclanomdl
       end if

       if d_cts06m00.vclanomdl < "1995"  then

          select autctgatu into ws.ctgtrfcod
            from agetdecateg
           where vclcoddig  = d_cts06m00.vclcoddig
             and viginc    <= w_data
             and vigfnl    >= w_data

          if ws.ctgtrfcod <> 40 and ws.ctgtrfcod <> 41 and
             ws.ctgtrfcod <> 42 and ws.ctgtrfcod <> 43 and
             ws.ctgtrfcod <> 50 and ws.ctgtrfcod <> 51 and
             ws.ctgtrfcod <> 52 and ws.ctgtrfcod <> 53 and
             ws.ctgtrfcod <> 58 and ws.ctgtrfcod <> 59 and
             ws.ctgtrfcod <> 60 and ws.ctgtrfcod <> 61 and
             ws.ctgtrfcod <> 62 and ws.ctgtrfcod <> 63 and
             ws.ctgtrfcod <> 72 and ws.ctgtrfcod <> 73 then
             call cts08g01("A","N","Ano modelo nao pode ser","anterior ao ano de 1995!","","Indique um posto de vistoria!")
                  returning ws.confirma
             next field vclanomdl
          end if
       end if

    before field lgdcep

       call cts06m00_busca_endereco() returning ws.retflg
       if ws.retflg = "N"  then
          next field vclanomdl
       end if
       if w_cts06m00.flgerro = 1 then
          next field vclanomdl
       end if
       if d_cts06m00.succod <> 1 then
          if d_cts06m00.lgdcep is not null or
             d_cts06m00.vstc24tip  =  1  then # vp p/ mesmo dia nao roteriz.
             next field corsus
          else
             display by name d_cts06m00.lgdcep    attribute (reverse)
          end if
       else
          next field corsus
       end if

    after field lgdcep
       display by name d_cts06m00.lgdcep
       if d_cts06m00.lgdcep is null then
          error "Cep e obrigatorio"
          next field lgdcep
       end if
       let a_cts06m00[1].lgdcep    = d_cts06m00.lgdcep
       let a_cts06m00[1].lgdcepcmp = d_cts06m00.lgdcepcmp

    before field corsus

    #-------------------------------------------------------
    # Verifica se limite de V.P. nao foi excedido para data (roterizada)
    #-------------------------------------------------------
    if d_cts06m00.vstc24tip  =  0  then    # roterizada
        if d_cts06m00.lgdcep is null then
            let d_cts06m00.lgdcep = 0
        end if
        call figrc072_setTratarIsolamento()
        call fvpia100 (0,d_cts06m00.vstdat,d_cts06m00.lgdcep,"")
             returning ws.erro,
                       ws.msg,
                       ws.base
        if g_isoAuto.sqlCodErr <> 0 then
           error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
                 ,g_isoAuto.sqlCodErr
        end if
        if ws.erro  <>  0  then
            error "Limite de V.Previas excedido para esta base! ", ws.base
            call cts06m04() returning  d_cts06m00.atdatznom
            if d_cts06m00.atdatznom  is null   then
                error " Vistoria deve ser autorizada!"
                next field vstdat
            end if
            display by name d_cts06m00.atdatznom
        end if
    end if
    display by name d_cts06m00.corsus    attribute (reverse)

    after field corsus
       display by name d_cts06m00.corsus

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          ### if d_cts06m00.succod = 01  then
          ###    next field vstregcod
          ### else
          ###    next field vstfld
          ### end if
          next field vclanomdl
       else
          if d_cts06m00.corsus is null then
             select count(*)
               into ws.conta
               from datkgeral
              where grlchv = ws.grlchv
             if ws.conta = 0  then
                let ws.hora = time
                insert into datkgeral
                       (grlchv,grlinf,atldat,atlhor,atlemp,atlmat)
                values (ws.grlchv,"0",today,ws.hora,g_issk.empcod,
                        g_issk.funmat)
             end if
             call chama_prog("Con_ct24h","ctg3","cts06m00") returning ws.ret
             if ws.ret  =  -1   then
                error "Modulo Con_ct24h-Corretores nao disponivel no momento!"
             end if

             select grlinf
               into d_cts06m00.corsus
               from datkgeral
              where grlchv = ws.grlchv
             if sqlca.sqlcode <> notfound then
                delete from datkgeral
                   where grlchv = ws.grlchv
             end if
             if d_cts06m00.corsus = 0  then
                let d_cts06m00.corsus = null
             end if
             next field corsus
          end if
          if d_cts06m00.corsus is not null  then
              select gcakcorr.cornom
                into d_cts06m00.cornom
                from gcakfilial,
                     gcaksusep,
                     gcakcorr
               where gcaksusep.corsus     = d_cts06m00.corsus
                 and gcaksusep.corsuspcp  = gcakfilial.corsuspcp
                 and gcakfilial.corfilnum = 1
                 and gcakcorr.corsuspcp   = gcakfilial.corsuspcp

             if sqlca.sqlcode = notfound   then
                error " Corretor nao cadastrado!"
                let ws.conta  =  0
                select count(*)
                     into ws.conta
                     from datkgeral
                    where grlchv = ws.grlchv
                if ws.conta = 0  then
                   let ws.hora = time
                   insert into datkgeral
                          (grlchv,grlinf,atldat,atlhor,atlemp,atlmat)
                   values (ws.grlchv,"0",today,ws.hora,g_issk.empcod,
                           g_issk.funmat)
                end if

                call chama_prog("Con_ct24h","ctg3","cts06m00") returning ws.ret
                if ws.ret  =  -1   then
                  error "Modulo Con_ct24h-Corretores nao disponivel no momento!"
                end if

                select grlinf
                  into d_cts06m00.corsus
                  from datkgeral
                 where grlchv = ws.grlchv
                if sqlca.sqlcode <> notfound then
                   delete from datkgeral
                      where grlchv = ws.grlchv
                end if
                if d_cts06m00.corsus = 0  then
                   let d_cts06m00.corsus = null
                end if
                next field corsus
             else
                #---> Utilizacao da nova funcao de comissoes p/ enderecamento
                initialize r_gcakfilial.* to null
                call fgckc811(d_cts06m00.corsus)
                     returning r_gcakfilial.*
                let d_cts06m00.cordddcod = r_gcakfilial.dddcod
                let ws.corteltxt         = r_gcakfilial.teltxt
                #------------------------------------------------------------

                if ws.corteltxt is not null  then
                   call cts09g02(d_cts06m00.cordddcod, ws.corteltxt)
                       returning d_cts06m00.cordddcod,
                                 d_cts06m00.cortelnum
                end if

                display by name d_cts06m00.cornom
                display by name d_cts06m00.cordddcod
                display by name d_cts06m00.cortelnum
                next field cordddcod
             end if
          end if
       end if

    before field cornom
       display by name d_cts06m00.cornom   attribute (reverse)

    after field cornom
       display by name d_cts06m00.cornom

    before field cordddcod
       display by name d_cts06m00.cordddcod  attribute (reverse)

    after field cordddcod
       display by name d_cts06m00.cordddcod

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.corsus is not null  or
             d_cts06m00.cornom is not null  then
             if d_cts06m00.cordddcod is null  then
                error " DDD do telefone do corretor deve ser informado!"
                next field cordddcod
             end if
          end if
       end if

    before field cortelnum
       display by name d_cts06m00.cortelnum  attribute (reverse)

    after field cortelnum
       display by name d_cts06m00.cortelnum

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.corsus   is not null    or
             d_cts06m00.cornom   is not null    then
             if d_cts06m00.cortelnum  is null   then
                error " Telefone do corretor deve ser informado!"
                next field cortelnum
             end if
          end if
       end if

    before field segnom
       display by name d_cts06m00.segnom   attribute (reverse)

    after field segnom
       display by name d_cts06m00.segnom

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.segnom  is null   then
             error " Nome ou razao social deve ser informada!"
             next field segnom
          end if
       end if

     before field pestip
      display by name d_cts06m00.pestip   attribute (reverse)

    after field pestip
       display by name d_cts06m00.pestip

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.pestip is null  then
             error " Tipo de pessoa deve ser informado!"
             next field pestip
          end if

          if d_cts06m00.pestip <> "F"  and
             d_cts06m00.pestip <> "J"  then
             error " Tipo de pessoa deve ser: (F)isica ou (J)uridica!"
             next field pestip
          end if

          if d_cts06m00.pestip  =  "F"  then
             initialize d_cts06m00.cgcord    to null
             display by name d_cts06m00.cgcord
          end if
       end if

    before field cgccpfnum
       display by name d_cts06m00.cgccpfnum   attribute (reverse)

    after field cgccpfnum
       display by name d_cts06m00.cgccpfnum

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.cgccpfnum is null  then
             initialize d_cts06m00.cgcord    to null
             initialize d_cts06m00.cgccpfdig to null
             display by name d_cts06m00.cgcord
             display by name d_cts06m00.cgccpfdig
             if d_cts06m00.pestip  =  "F"   then
                next field cgccpfdig
             end if
          else
             if d_cts06m00.pestip  =  "F"   then
                next field cgccpfdig
             end if
          end if
       end if

    before field cgcord
       display by name d_cts06m00.cgcord      attribute (reverse)

    after field cgcord
       display by name d_cts06m00.cgcord

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts06m00.cgcord is null  or
             d_cts06m00.cgcord =  0     then
             error " Filial do CGC deve ser informada!"
             next field cgcord
          end if
       end if

    before field cgccpfdig
       display by name d_cts06m00.cgccpfdig   attribute (reverse)

    after field cgccpfdig
       display by name d_cts06m00.cgccpfdig

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          if d_cts06m00.pestip  =  "F"   then
             next field cgccpfnum
          else
             next field cgcord
          end if
       end if

       if d_cts06m00.cgccpfnum is not null  and
          d_cts06m00.cgccpfdig is null      then
          error " Digito do CGC/CPF deve ser informado!"
          next field cgccpfdig
       end if

       if d_cts06m00.cgccpfdig    is not null  then
          if d_cts06m00.cgccpfnum is null      then
             error " Numero do CGC/CPF deve ser informado!"
             next field cgccpfnum
          end if

          if d_cts06m00.pestip = "F"  then
             call F_FUNDIGIT_DIGITOCPF(d_cts06m00.cgccpfnum)
                             returning ws.cgccpfdig
          else
             call F_FUNDIGIT_DIGITOCGC(d_cts06m00.cgccpfnum, d_cts06m00.cgcord)
                             returning ws.cgccpfdig
          end if

          if ws.cgccpfdig         is null          or
             d_cts06m00.cgccpfdig <> ws.cgccpfdig  then
             error " Digito do CGC/CPF incorreto!"
             next field cgccpfdig
          end if
       end if
    before field segematxt
       display by name d_cts06m00.segematxt attribute (reverse)
    after field segematxt
       display by name d_cts06m00.segematxt
       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
            if d_cts06m00.cgccpfdig is null then
                next field cgccpfnum
            else
                next field cgccpfdig
            end if
       end if
    before field prfhor
        #----------------------------------------
        # Monta entrada com empresa + uf + cidade
        #----------------------------------------
        initialize lr_entperhor.* to null
        let lr_entperhor.ciaempcod = d_cts06m00.ciaempcod      #-- Codigo Empresa
        let lr_entperhor.vstfld    = d_cts06m00.vstfld         #-- Codigo Finalidade
        let lr_entperhor.ufdcod    = a_cts06m00[1].ufdcod      #-- Sigla do Estado
        #--------------------------------------
        # Recupera o codigo da cidade pelo nome
        #--------------------------------------
        open ccts06m00006 using a_cts06m00[1].cidnom,
                                a_cts06m00[1].ufdcod
        fetch ccts06m00006 into lr_entperhor.cidcod            #-- Codigo da cidade
        close ccts06m00006
        let lr_entperhor.vstdat    = d_cts06m00.vstdat
        select current into lr_entperhor.solichor from dual    #-- Hora da solicitacao
        #### error "vai chamar com cia=", lr_entperhor.ciaempcod,
        ####      " fin=", lr_entperhor.vstfld,
        ####       " uf=", lr_entperhor.ufdcod,
        ####      " cid=", lr_entperhor.cidcod,
        ####      " dat=", lr_entperhor.vstdat,
        ####      " hor=", lr_entperhor.solichor
        #### prompt "" for char prompt_key
        #--------------------------------------
        # Recupera periodos conforme parametros
        #--------------------------------------
        call fvpic190_per_horarios(lr_entperhor.ciaempcod,
                                   lr_entperhor.vstfld,
                                   lr_entperhor.ufdcod,
                                   lr_entperhor.cidcod,
                                   lr_entperhor.vstdat,
                                   lr_entperhor.solichor)
                         returning lr_saiperhorcontr.*,
                                   la_saiperhorper[001].*,
                                   la_saiperhorper[002].*,
                                   la_saiperhorper[003].*,
                                   la_saiperhorper[004].*,
                                   la_saiperhorper[005].*,
                                   la_saiperhorper[006].*,
                                   la_saiperhorper[007].*,
                                   la_saiperhorper[008].*,
                                   la_saiperhorper[009].*,
                                   la_saiperhorper[010].*,
                                   la_saiperhorper[011].*,
                                   la_saiperhorper[012].*,
                                   la_saiperhorper[013].*,
                                   la_saiperhorper[014].*,
                                   la_saiperhorper[015].*,
                                   la_saiperhorper[016].*,
                                   la_saiperhorper[017].*,
                                   la_saiperhorper[018].*,
                                   la_saiperhorper[019].*,
                                   la_saiperhorper[020].*,
                                   la_saiperhorper[021].*,
                                   la_saiperhorper[022].*,
                                   la_saiperhorper[023].*,
                                   la_saiperhorper[024].*,
                                   la_saiperhorper[025].*,
                                   la_saiperhorper[026].*,
                                   la_saiperhorper[027].*,
                                   la_saiperhorper[028].*,
                                   la_saiperhorper[029].*,
                                   la_saiperhorper[030].*
        #### error "retornou cod=", lr_saiperhorcontr.coderro,
        ####       " msg=", lr_saiperhorcontr.msgerro clipped,
        ####       " qtd=", lr_saiperhorcontr.qtdper,
        ####       " grp=", la_saiperhorper[1].cod_grupo
        #### prompt "" for char prompt_key
        #----------------------------------------------------------------
        # Se houver apenas um horario para mostrar, ja mostra selecionado
        #----------------------------------------------------------------
        if lr_saiperhorcontr.qtdper = 1 then
            let lr_saidacodper.cod_periodo  = la_saiperhorper[1].cod_periodo #-- Codigo do periodo
            let lr_saidacodper.cod_grupo    = la_saiperhorper[1].cod_grupo   #-- Codigo do grupo
            let lr_saidacodper.pri_periodo  = la_saiperhorper[1].pri_periodo #-- Prioridade do periodo
            let lr_saidacodper.msg_periodo  = la_saiperhorper[1].msg_periodo #-- Mensagem do periodo
            let d_cts06m00.prfhor           = lr_saidacodper.msg_periodo     #-- Mensagem do periodo
            let d_cts06m00.atdprinvlcod     = lr_saidacodper.pri_periodo     #-- Prioridade do periodo
            #-----------------------------------------------
            # Recupera a descricao da prioridade pelo codigo
            #-----------------------------------------------
            open ccts06m00010 using d_cts06m00.atdprinvlcod
            fetch ccts06m00010 into d_cts06m00.atdprinvldes
            if sqlca.sqlcode <> 0 then
                let d_cts06m00.atdprinvldes = "N.ENC."
            end if
            close ccts06m00010
            display by name d_cts06m00.prfhor
            display by name d_cts06m00.atdprinvlcod
            display by name d_cts06m00.atdprinvldes
            #---------------------------
            # Pula o campo de prioridade
            #---------------------------
            next field atdatznom
        else
            let d_cts06m00.prfhor = null
            display by name d_cts06m00.prfhor
        end if
    after field prfhor
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
            next field segematxt
        end if
        if d_cts06m00.prfhor is null or
           d_cts06m00.prfhor = " " then
            #----------------------------------------------------------------
            # Se houver apenas um horario para mostrar, ja mostra selecionado
            #----------------------------------------------------------------
            if lr_saiperhorcontr.qtdper = 1 then
                let lr_saidacodper.cod_periodo  = la_saiperhorper[1].cod_periodo #-- Codigo do periodo
                let lr_saidacodper.cod_grupo    = la_saiperhorper[1].cod_grupo   #-- Codigo do grupo
                let lr_saidacodper.pri_periodo  = la_saiperhorper[1].pri_periodo #-- Prioridade do periodo
                let lr_saidacodper.msg_periodo  = la_saiperhorper[1].msg_periodo #-- Mensagem do periodo
                let d_cts06m00.prfhor           = lr_saidacodper.msg_periodo     #-- Mensagem do periodo
                let d_cts06m00.atdprinvlcod     = lr_saidacodper.pri_periodo     #-- Prioridade do periodo
                #-----------------------------------------------
                # Recupera a descricao da prioridade pelo codigo
                #-----------------------------------------------
                open ccts06m00010 using d_cts06m00.atdprinvlcod
                fetch ccts06m00010 into d_cts06m00.atdprinvldes
                if sqlca.sqlcode <> 0 then
                    let d_cts06m00.atdprinvldes = "N.ENC."
                end if
                close ccts06m00010
                display by name d_cts06m00.prfhor       #-- Periodo de horario
                display by name d_cts06m00.atdprinvlcod #-- Codigo da prioridade
                display by name d_cts06m00.atdprinvldes #-- Descricao da prioridade
                #---------------------------
                # Pula o campo de prioridade
                #---------------------------
                next field atdatznom
            else
                #------------------------------------------------
                # Se o atendente digitou ENTER mostra popup
                #------------------------------------------------
                # Obs: Como a funcao fvpic190 ja retornou o array
                #      com os horarios, monta uma query 'virtual'
                #      para nao acessar a base novamente
                #------------------------------------------------
                let sql_select = null
                for l_contper = 1 to lr_saiperhorcontr.qtdper
                    if l_contper <> 1 then
                        let sql_select = sql_select clipped, " union"
                    end if
                    let sql_select = sql_select clipped,
                                     " select ",
                                     la_saiperhorper[l_contper].cod_periodo, ",'",
                                     la_saiperhorper[l_contper].msg_periodo, "' from dual"
                end for
                let sql_select = sql_select clipped, ' order by 2,1'
                initialize lr_saidacodper.*   to null
                call ofgrc001_popup(10                          # Nr linha
                                   ,10                          # Nr Colula
                                   ,'HORARIOS PREFERENCIAIS'    # Titulo
                                   ,'CODIGO'                    # Titulo 1a coluna
                                   ,'HORARIO'                   # Titulo 2a colula
                                   ,'N'                         # Tipo de retorno = Numerico
                                   ,sql_select                  # Comando SQL
                                   ,''                          # Complemento apos WHERE
                                   ,'D')                        # Tipo = Direto
                         returning ws.ret,                      # Erro
                                   lr_saidacodper.cod_periodo,   # Codigo selecionado
                                   lr_saidacodper.msg_periodo    # Descricao selecionada
                #### error "ret=", ws.ret, " cod=", lr_saidacodper.cod_periodo, " per=", lr_saidacodper.msg_periodo
                #### prompt "" for char prompt_key
                if ws.ret <> 0 or
                   lr_saidacodper.cod_periodo is null or
                   lr_saidacodper.cod_periodo = 0 then
                    error "Periodo de horario deve ser selecionado !"
                    #### prompt "" for char prompt_key
                    next field prfhor
                end if
            end if
            call fvpic190_cod_periodo(lr_saidacodper.cod_periodo)
                            returning lr_saidacodper.cod_periodo,
                                      lr_saidacodper.cod_grupo,
                                      lr_saidacodper.pri_periodo,
                                      lr_saidacodper.msg_periodo
            let d_cts06m00.prfhor = lr_saidacodper.msg_periodo           #-- Mensagem
            let d_cts06m00.atdprinvlcod = lr_saidacodper.pri_periodo     #-- Prioridade
            #-----------------------------------------------
            # Recupera a descricao da prioridade pelo codigo
            #-----------------------------------------------
            open ccts06m00010 using d_cts06m00.atdprinvlcod
            fetch ccts06m00010 into d_cts06m00.atdprinvldes
            if sqlca.sqlcode <> 0 then
                let d_cts06m00.atdprinvldes = "N.ENC."
            end if
            close ccts06m00010
            display by name d_cts06m00.prfhor       #-- Periodo de horario
            display by name d_cts06m00.atdprinvlcod #-- Codigo da prioridade
            display by name d_cts06m00.atdprinvldes #-- Descricao da prioridade
            #---------------------------
            # Pula o campo de prioridade
            #---------------------------
            next field atdatznom
        else
            #------------------------------------------------
            # Se nao escolheu do pop-up nao permite continuar
            #------------------------------------------------
            if lr_saidacodper.cod_periodo is null or
               lr_saidacodper.cod_periodo = 0 then
                error "Periodo de horario deve ser selecionado !"
                #### prompt "" for char prompt_key
                next field prfhor
            else
                #---------------------------------------------------
                # Se escolheu, verifica se nao modificou a descricao
                #---------------------------------------------------
                if d_cts06m00.prfhor <> lr_saidacodper.msg_periodo then
                    error "Horario nao cadastrado ou nao atendido pela vistoria !"
                    #### prompt "" for char prompt_key
                    next field prfhor
                end if
            end if
        end if
   before field atdprinvlcod
          let d_cts06m00.atdprinvlcod = lr_saidacodper.pri_periodo     #-- Prioridade
          display by name d_cts06m00.atdprinvlcod attribute (reverse)
          let ws.ret = 0
          select cpodes
            into d_cts06m00.atdprinvldes
            from iddkdominio
           where cponom = "atdprinvlcod"
             and cpocod = d_cts06m00.atdprinvlcod
          if sqlca.sqlcode = notfound then
              error " Nivel de prioridade pode ser (1)-Baixa,",
                    " (2)-Normal ou (3)-Urgente"
              next field atdprinvlcod
          end if
          display by name d_cts06m00.atdprinvldes
   after field atdprinvlcod
          display by name d_cts06m00.atdprinvlcod
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts06m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts06m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts06m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa,",
                      " (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if
             display by name d_cts06m00.atdprinvldes
          else
             if lr_saiperhorcontr.qtdper = 1 then
                next field segematxt
             else
                next field prfhor
             end if
          end if
    before field atdatznom
       if d_cts06m00.vstc24tip = 0  then
          initialize w_cts06m00.atdhorpvt to null
          let w_cts06m00.atddatprg = d_cts06m00.vstdat
       else
          initialize w_cts06m00.atddatprg to null
          let w_cts06m00.atdhorpvt = "00:00"
       end if

       display by name d_cts06m00.atdatznom   attribute (reverse)

    after field atdatznom
       display by name d_cts06m00.atdatznom

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          #### next field atdprinvlcod
          next field prfhor #### Pula campo de prioridade
       end if

       #-------------------------------------------------------------
       # Acumula vistoria na agenda de VP marcadas
       #-------------------------------------------------------------
       whenever error continue
       begin work

       if (param.operacao     =  "I"  )        or
          (param.operacao     =  "M"           and
           d_cts06m00.vstdat <> salva.vstdat)  then
          if d_cts06m00.vstc24tip  =   1   then  # NAO ROTERIZADA
             initialize ws.vstqtdaut, ws.atrvstqtdc24,
                        ws.vstqtdvol, ws.vstqtdc24  to null

             open    c_agenda using d_cts06m00.vstdat,
                                    d_cts06m00.succod
             foreach c_agenda into  ws.vstqtdaut, ws.atrvstqtdc24,
                                    ws.vstqtdvol, ws.vstqtdc24
                exit foreach
             end foreach

             if ws.atrvstqtdc24 is null  then
                let ws.vstqtdvol = 0
                let ws.vstqtdc24 = 1
                insert into datmvstagen (vstdat,
                                         vstqtdaut,
                                         atrvstqtdc24,
                                         vstqtdvol,
                                         vstqtdc24,
                                         succod)
                                 values (d_cts06m00.vstdat,
                                         ws.vstautvol,
                                         ws.vstautc24,
                                         ws.vstqtdvol,
                                         ws.vstqtdc24,
                                         d_cts06m00.succod)
                if sqlca.sqlcode <> 0  then
                   error " Erro (", sqlca.sqlcode, ") na inclusao da agenda.",
                         " AVISE A INFORMATICA!"
                   rollback work
                   prompt "" for char prompt_key
                   exit input
                end if
             end if

             if ws.atrvstqtdc24 is not  null  then
                let ws.vstqtdc24 = ws.vstqtdc24 + 1
                if ws.atrvstqtdc24 < ws.vstqtdc24  and
                   d_cts06m00.atdatznom is null    then
                   error "Limite de vistoria previa excedido para esta data!"
                   rollback work
                   prompt "" for char prompt_key
                   next field vstdat
                end if

                update datmvstagen set (vstqtdvol,
                                        vstqtdc24)
                                     = (ws.vstqtdvol,
                                        ws.vstqtdc24)
                        where vstdat = d_cts06m00.vstdat
                          and succod = d_cts06m00.succod

                if sqlca.sqlcode <> 0  then
                   error " Erro (", sqlca.sqlcode using "<<<<<&", ")",
                         " na alteracao da agenda. AVISE A INFORMATICA!"
                   rollback work
                   prompt "" for char prompt_key
                   exit input
                end if
               #-------------------------------------------------------------
               # Subtrai vistoria na agenda de VP marcadas
               #-------------------------------------------------------------
                if param.operacao  =  "M"     and
                   d_cts06m00.vstdat <> salva.vstdat  then
                   initialize ws.vstqtdaut,
                              ws.atrvstqtdc24,
                              ws.vstqtdvol,
                              ws.vstqtdc24 to null

                   open    c_agenda using salva.vstdat,
                                          d_cts06m00.succod
                   foreach c_agenda into  ws.vstqtdaut, ws.atrvstqtdc24,
                                          ws.vstqtdvol, ws.vstqtdc24
                      exit foreach
                   end foreach

                   if ws.atrvstqtdc24 is null  then
                      error "Data anterior nao encontrada. AVISE A INFORMATICA!"
                      rollback work
                      prompt "" for char prompt_key
                      exit input
                   end if

                   let ws.vstqtdc24 = ws.vstqtdc24 - 1
                   update datmvstagen set vstqtdvol = ws.vstqtdvol,
                                          vstqtdc24 = ws.vstqtdc24
                                    where vstdat    = salva.vstdat
                                      and succod    = d_cts06m00.succod

                   if sqlca.sqlcode <> 0 then
                      error " Erro (", sqlca.sqlcode using "<<<<<&", ")",
                            " na alteracao da agenda. AVISE A INFORMATICA!"
                      rollback work
                      prompt "" for char prompt_key
                      exit input
                   end if
                end if
                if param.operacao    = "M"   and         #EXCLUIR DA ROTERIZADA
                   d_cts06m00.vstdat < salva.vstdat then #VISTORIA ALTERADA DE
                   call figrc072_setTratarIsolamento()
                   call fvpia100(d_cts06m00.vstnumdig,   #VOLANTE P/ CT24HS
                                 salva.vstdat        ,
                                 "0"                 ,
                                 "C" ) returning  ws.erro, ws.msg , ws.base
                   if g_isoAuto.sqlCodErr <> 0 then
                      error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
                            ,g_isoAuto.sqlCodErr
                   end if
                end if
             end if
          end if

          if d_cts06m00.vstc24tip  =   0  then  #  ROTERIZADA
             call figrc072_setTratarIsolamento()
             call fvpia100(d_cts06m00.vstnumdig,
                           salva.vstdat        ,
                           "0"                 ,
                           "C" ) returning  ws.erro, ws.msg , ws.base
             if g_isoAuto.sqlCodErr <> 0 then
                error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
                      ,g_isoAuto.sqlCodErr
             end if
             if ws.erro    =    0   then
                call figrc072_setTratarIsolamento()
                call fvpia100(d_cts06m00.vstnumdig,
                              d_cts06m00.vstdat   ,
                              d_cts06m00.lgdcep   ,
                              "S" ) returning  ws.erro, ws.msg , ws.base
                if g_isoAuto.sqlCodErr <> 0 then
                   error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
                         ,g_isoAuto.sqlCodErr
                end if
             end if
          end if

          if param.operacao = "I"  then
             if cts06m00_inclui(hist_cts06m00.* ) = true  then
###             commit work
                whenever error stop
                call cts06N01(d_cts06m00.atdsrvnum,
                              d_cts06m00.atdsrvano,
                              d_cts06m00.vstnumdig,
                              g_issk.funmat,
                              w_data,
                              w_hora)
             else
                whenever error stop
                let int_flag = true
                exit input
             end if
          end if
       end if

       if param.operacao = "M"  then
          if cts06m00_modifica() = false  then
             whenever error stop
             let int_flag = true
             exit input
          else
             commit work
             whenever error stop
             call cts06N01(d_cts06m00.atdsrvnum,
                           d_cts06m00.atdsrvano,
                           d_cts06m00.vstnumdig,
                           g_issk.funmat,
                           w_data,
                           w_hora)
          end if
       end if

       exit input

   on key (F6)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts10m02 (hist_cts06m00.*) returning hist_cts06m00.*
      else
         call cts10n00(g_documento.atdsrvnum,
                       g_documento.atdsrvano,
                       g_issk.funmat,
                       w_data,w_hora)
      end if

   on key (interrupt)
      if param.operacao = "I"  then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","") = "S" then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if
 end input

 if int_flag  then
    initialize d_cts06m00.*  to null
    initialize w_cts06m00.*  to null
    initialize a_cts06m00    to null
    let w_cts06m00.param  =  arg_val(15)
    let w_cts06m00.corsus =  w_cts06m00.param[31,36]
    error " Operacao cancelada! "
    clear form
 end if

end function  ###  cts06m00_input

#-----------------------------------------------------------
 function cts06m00_busca_endereco()
#-----------------------------------------------------------
   define ws     record
      retflg     char (01)
   end record


    initialize  ws.*  to  null

   #-- CT 199427
   ### let v_retorno = d_cts06m00.vstc24tip #v_retorno global para cts06g03

   ### if d_cts06m00.succod = 1 then
   ### end if
   #--

   let v_retorno = 1

   let w_cts06m00.flgerro = 0
   let a_cts06m00[1].lclbrrnom = m_lclbrrnom
   let m_acesso_ind = false
   let m_atdsrvorg = 10
   call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
        returning m_acesso_ind
   if m_acesso_ind = false then
     call cts06g03(1,
                   m_atdsrvorg,
                   0,
                   w_data,
                   w_hora,
                   a_cts06m00[1].lclidttxt,
                   a_cts06m00[1].cidnom,
                   a_cts06m00[1].ufdcod,
                   a_cts06m00[1].brrnom,
                   a_cts06m00[1].lclbrrnom,
                   a_cts06m00[1].endzon,
                   a_cts06m00[1].lgdtip,
                   a_cts06m00[1].lgdnom,
                   a_cts06m00[1].lgdnum,
                   a_cts06m00[1].lgdcep,
                   a_cts06m00[1].lgdcepcmp,
                   a_cts06m00[1].lclltt,
                   a_cts06m00[1].lcllgt,
                   a_cts06m00[1].lclrefptotxt,
                   a_cts06m00[1].lclcttnom,
                   a_cts06m00[1].dddcod,
                   a_cts06m00[1].lcltelnum,
                   a_cts06m00[1].c24lclpdrcod,
                   a_cts06m00[1].ofnnumdig,
                   a_cts06m00[1].celteldddcod,
                   a_cts06m00[1].celtelnum,
                   a_cts06m00[1].endcmp,
                   hist_cts06m00.*,
                   a_cts06m00[1].emeviacod)
         returning a_cts06m00[1].lclidttxt,
                   a_cts06m00[1].cidnom,
                   a_cts06m00[1].ufdcod,
                   a_cts06m00[1].brrnom,
                   a_cts06m00[1].lclbrrnom,
                   a_cts06m00[1].endzon,
                   a_cts06m00[1].lgdtip,
                   a_cts06m00[1].lgdnom,
                   a_cts06m00[1].lgdnum,
                   a_cts06m00[1].lgdcep,
                   a_cts06m00[1].lgdcepcmp,
                   a_cts06m00[1].lclltt,
                   a_cts06m00[1].lcllgt,
                   a_cts06m00[1].lclrefptotxt,
                   a_cts06m00[1].lclcttnom,
                   a_cts06m00[1].dddcod,
                   a_cts06m00[1].lcltelnum,
                   a_cts06m00[1].c24lclpdrcod,
                   a_cts06m00[1].ofnnumdig      ,
                   a_cts06m00[1].celteldddcod,
                   a_cts06m00[1].celtelnum,
                   a_cts06m00[1].endcmp,
                   ws.retflg,
                   hist_cts06m00.*,
                   a_cts06m00[1].emeviacod
     else
        call cts06g11(1,
                      m_atdsrvorg,
                      0,
                      w_data,
                      w_hora,
                      a_cts06m00[1].lclidttxt,
                      a_cts06m00[1].cidnom,
                      a_cts06m00[1].ufdcod,
                      a_cts06m00[1].brrnom,
                      a_cts06m00[1].lclbrrnom,
                      a_cts06m00[1].endzon,
                      a_cts06m00[1].lgdtip,
                      a_cts06m00[1].lgdnom,
                      a_cts06m00[1].lgdnum,
                      a_cts06m00[1].lgdcep,
                      a_cts06m00[1].lgdcepcmp,
                      a_cts06m00[1].lclltt,
                      a_cts06m00[1].lcllgt,
                      a_cts06m00[1].lclrefptotxt,
                      a_cts06m00[1].lclcttnom,
                      a_cts06m00[1].dddcod,
                      a_cts06m00[1].lcltelnum,
                      a_cts06m00[1].c24lclpdrcod,
                      a_cts06m00[1].ofnnumdig,
                      a_cts06m00[1].celteldddcod,
                      a_cts06m00[1].celtelnum,
                      a_cts06m00[1].endcmp,
                      hist_cts06m00.*,
                      a_cts06m00[1].emeviacod)
            returning a_cts06m00[1].lclidttxt,
                      a_cts06m00[1].cidnom,
                      a_cts06m00[1].ufdcod,
                      a_cts06m00[1].brrnom,
                      a_cts06m00[1].lclbrrnom,
                      a_cts06m00[1].endzon,
                      a_cts06m00[1].lgdtip,
                      a_cts06m00[1].lgdnom,
                      a_cts06m00[1].lgdnum,
                      a_cts06m00[1].lgdcep,
                      a_cts06m00[1].lgdcepcmp,
                      a_cts06m00[1].lclltt,
                      a_cts06m00[1].lcllgt,
                      a_cts06m00[1].lclrefptotxt,
                      a_cts06m00[1].lclcttnom,
                      a_cts06m00[1].dddcod,
                      a_cts06m00[1].lcltelnum,
                      a_cts06m00[1].c24lclpdrcod,
                      a_cts06m00[1].ofnnumdig      ,
                      a_cts06m00[1].celteldddcod,
                      a_cts06m00[1].celtelnum,
                      a_cts06m00[1].endcmp,
                      ws.retflg,
                      hist_cts06m00.*,
                      a_cts06m00[1].emeviacod
     end if
   let a_cts06m00[1].lgdtxt = a_cts06m00[1].lgdtip clipped, " ",
                              a_cts06m00[1].lgdnom clipped, " ",
                              a_cts06m00[1].lgdnum using "<<<<#"
   let m_lclbrrnom = a_cts06m00[1].lclbrrnom
   call cts06g10_monta_brr_subbrr(a_cts06m00[1].brrnom,
                                  a_cts06m00[1].lclbrrnom)
        returning a_cts06m00[1].lclbrrnom

   display by name a_cts06m00[1].lgdtxt
   display by name a_cts06m00[1].lgdcep
   display by name a_cts06m00[1].lgdcepcmp
   display by name a_cts06m00[1].lclbrrnom
   display by name a_cts06m00[1].cidnom
   display by name a_cts06m00[1].ufdcod
   display by name a_cts06m00[1].lclrefptotxt
   display by name a_cts06m00[1].lclcttnom
   display by name a_cts06m00[1].dddcod
   display by name a_cts06m00[1].lcltelnum
   display by name a_cts06m00[1].endcmp
   display by name a_cts06m00[1].celteldddcod
   display by name a_cts06m00[1].celtelnum
   let d_cts06m00.lgdcep    =  a_cts06m00[1].lgdcep
   let d_cts06m00.lgdcepcmp =  a_cts06m00[1].lgdcepcmp
   let w_cts06m00.flgerro   = 0
###if d_cts06m00.succod     = 1    and
###   a_cts06m00[1].ufdcod <> "SP" then
###   error "Endereco nao confere com a Sucursal informada.."
###   let w_cts06m00.flgerro = 1
###else
#     if d_cts06m00.succod   = 2      and
#        a_cts06m00[1].ufdcod <> "RJ" then
#        error "Endereco nao confere com a Sucursal informada.."
#        let w_cts06m00.flgerro = 1
#     end if
###end if
   if ws.retflg = "N"  then
      error " Dados referentes ao local incorretos ou nao preenchidos!"
   end if
   return ws.retflg

 end function
#-----------------------------------------------------------
 function cts06m00_consulta(param)
#-----------------------------------------------------------

 define param         record
    vstnumdig         like datmvistoria.vstnumdig,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define ws            record
    monta_sql         char (5000),
    codigosql         integer,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    dptsgl            like isskfunc.dptsgl   ,
    funmat            like isskfunc.funmat   ,
    funnom            like isskfunc.funnom   ,
    vstbascod         like avcmbasvst.vstbascod,
    atdetpcod         like datmsrvacp.atdetpcod,
    plmidtnum         like avcmplmcnx.plmidtnum,
    plmcnxinchor      datetime hour to minute,
    msgpalm           char(80)
 end record

 initialize  ws.*  to  null

 message " Aguarde, pesquisando... " attribute (reverse)

 let ws.monta_sql = " select datmvistoria.vstnumdig,    ",
                    "        datmvistoria.atdsrvnum,    ",
                    "        datmvistoria.atdsrvano,    ",
                    "        datmvistoria.vstc24tip,    ",
                    "        datmvistoria.succod,       ",
                    "        datmvistoria.vstfld,       ",
                    "        datmvistoria.corsus,       ",
                    "        datmvistoria.cornom,       ",
                    "        datmvistoria.cordddcod,    ",
                    "        datmvistoria.cortelnum,    ",
                    "        datmvistoria.segnom,       ",
                    "        datmvistoria.pestip,       ",
                    "        datmvistoria.cgccpfnum,    ",
                    "        datmvistoria.cgcord,       ",
                    "        datmvistoria.cgccpfdig,    ",
                    "        datmvistoria.vclmrcnom,    ",
                    "        datmvistoria.vclmdlnom,    ",
                    "        datmvistoria.vcltipnom,    ",
                    "        datmvistoria.vclanomdl,    ",
                    "        datmvistoria.vclanofbc,    ",
                    "        datmvistoria.vcllicnum,    ",
                    "        datmvistoria.vclchsnum,    ",
                    "        datmvistoria.atdatznom,    ",
                    "        datmvistoria.vstdat,       ",
                    "        datmvistoria.c24solnom,    ",
                    "        datmvistoria.c24soltipcod, ",
                    "        datmvistoria.prfhor,       ",
                    "        datmvistoria.horobs,       ",
                    "        datmvistoria.vclrnvnum,    ",
                    "        datmvistoria.cidcod,       ",
                    "        datmvistoria.segematxt     ",
                    "   from datmvistoria               "

 if param.vstnumdig is not null  then
    let ws.monta_sql = ws.monta_sql clipped, " where datmvistoria.vstnumdig = ? "
 else
    if param.atdsrvnum is not null  and
       param.atdsrvano is not null  then
       let ws.monta_sql = ws.monta_sql clipped, " where datmvistoria.atdsrvnum = ? ",
                                                "   and datmvistoria.atdsrvano = ? "
    else
       error " Parametros nao informados. AVISE A INFORMATICA!"
       return false
    end if
 end if
 prepare sel_datmvistoria from ws.monta_sql
 declare c_datmvistoria cursor for sel_datmvistoria

 if param.vstnumdig is not null  then
    open  c_datmvistoria using param.vstnumdig
 else
    open  c_datmvistoria using param.atdsrvnum, param.atdsrvano
 end if

 fetch c_datmvistoria into d_cts06m00.vstnumdig,
                           d_cts06m00.atdsrvnum,
                           d_cts06m00.atdsrvano,
                           d_cts06m00.vstc24tip,
                           d_cts06m00.succod,
                           d_cts06m00.vstfld,
                           #d_cts06m00.vstregcod,
                           #d_cts06m00.ciaempcod,
                           d_cts06m00.corsus,
                           d_cts06m00.cornom,
                           d_cts06m00.cordddcod,
                           d_cts06m00.cortelnum,
                           d_cts06m00.segnom,
                           d_cts06m00.pestip,
                           d_cts06m00.cgccpfnum,
                           d_cts06m00.cgcord,
                           d_cts06m00.cgccpfdig,
                           d_cts06m00.vclmrcnom,
                           d_cts06m00.vclmdlnom,
                           d_cts06m00.vcltipnom,
                           d_cts06m00.vclanomdl,
                           d_cts06m00.vclanofbc,
                           d_cts06m00.vcllicnum,
                           d_cts06m00.vclchsnum,
                           d_cts06m00.atdatznom,
                           d_cts06m00.vstdat,
                           d_cts06m00.c24solnom,
                           d_cts06m00.c24soltipcod,
                           d_cts06m00.prfhor,
                           d_cts06m00.horobs,
                           d_cts06m00.vclrnvnum,
                           d_cts06m00.cidcod,
                           d_cts06m00.segematxt

 if sqlca.sqlcode = notfound  then
    error " Vistoria previa domiciliar nao cadastrada!"
    return false
 end if

 close c_datmvistoria
 ### if d_cts06m00.succod <> 2 then # Rio de janeiro
 ###    let d_cts06m00.vstregsgl = "NAO CADASTRADO"
 ###    select vstregsgl
 ###      into d_cts06m00.vstregsgl
 ###      from avckreg
 ###     where vstregcod = d_cts06m00.vstregcod
 ### end if
 select datmservico.atdfnlflg,
        datmservico.atddat,
        datmservico.atdhor,
        datmservico.funmat,
        datmservico.atddatprg,
        datmservico.atdhorpvt,
        datmservico.vclcorcod,
        datmservico.atdprinvlcod,
        datmservico.atdsrvorg,
        datmservico.vclcoddig,
        datmservico.ciaempcod
   into w_cts06m00.atdfnlflg,
        ws.atddat,
        ws.atdhor,
        ws.funmat,
        w_cts06m00.atddatprg,
        w_cts06m00.atdhorpvt,
        w_cts06m00.vclcorcod,
        d_cts06m00.atdprinvlcod,
        d_cts06m00.atdsrvorg,
        d_cts06m00.vclcoddig,
        d_cts06m00.ciaempcod
   from datmservico
  where datmservico.atdsrvnum = d_cts06m00.atdsrvnum
    and datmservico.atdsrvano = d_cts06m00.atdsrvano
 if sqlca.sqlcode = notfound  then
    error " Servico de vistoria domiciliar nao encontrado. AVISE A INFORMATICA!"
    return false
 end if

 select gabkemp.empnom
   into d_cts06m00.empnom
   from gabkemp
  where gabkemp.empcod = d_cts06m00.ciaempcod
 if sqlca.sqlcode <> 0 then
     let d_cts06m00.empnom = "EMPRESA NAO ENCONTRADA!"
 end if
 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(d_cts06m00.atdsrvnum,
                         d_cts06m00.atdsrvano,
                         1)
               returning a_cts06m00[1].lclidttxt   ,
                         a_cts06m00[1].lgdtip      ,
                         a_cts06m00[1].lgdnom      ,
                         a_cts06m00[1].lgdnum      ,
                         a_cts06m00[1].lclbrrnom   ,
                         a_cts06m00[1].brrnom      ,
                         a_cts06m00[1].cidnom      ,
                         a_cts06m00[1].ufdcod      ,
                         a_cts06m00[1].lclrefptotxt,
                         a_cts06m00[1].endzon      ,
                         a_cts06m00[1].lgdcep      ,
                         a_cts06m00[1].lgdcepcmp   ,
                         a_cts06m00[1].lclltt      ,
                         a_cts06m00[1].lcllgt      ,
                         a_cts06m00[1].dddcod      ,
                         a_cts06m00[1].lcltelnum   ,
                         a_cts06m00[1].lclcttnom   ,
                         a_cts06m00[1].c24lclpdrcod,
                         a_cts06m00[1].celteldddcod,
                         a_cts06m00[1].celtelnum   ,
                         a_cts06m00[1].endcmp      ,
                         ws.codigosql,
                         a_cts06m00[1].emeviacod
 let m_lclbrrnom = a_cts06m00[1].lclbrrnom
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_cts06m00[2].brrnom,
                                a_cts06m00[2].lclbrrnom)
      returning a_cts06m00[2].lclbrrnom
 select ofnnumdig into a_cts06m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = d_cts06m00.atdsrvano
    and atdsrvnum = d_cts06m00.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do",
          " local de ocorrencia. AVISE A INFORMATICA!"
    return false
 end if

 let a_cts06m00[1].lgdtxt = a_cts06m00[1].lgdtip clipped, " ",
                            a_cts06m00[1].lgdnom clipped, " ",
                            a_cts06m00[1].lgdnum using "<<<<#"
 select atdsrvnum, atdsrvano
   from datmvstcanc
  where atdsrvnum = d_cts06m00.atdsrvnum    and
        atdsrvano = d_cts06m00.atdsrvano

 if sqlca.sqlcode = notfound   then
    let w_cts06m00.cancelada = "n"
 else
    let w_cts06m00.cancelada = "s"
    error " Vistoria previa domiciliar cancelada!"
 end if

 if d_cts06m00.vstc24tip  =  0  then
    let d_cts06m00.vstc24des = "VOLANTE"
 else
    let d_cts06m00.vstc24des = "CENTRAL"
 end if

 #---------------------------------------
 #select cpodes into d_cts06m00.vstflddes
 #  from iddkdominio
 # where cponom = "vstfld"  and
 #       cpocod = d_cts06m00.vstfld
 #---------------------------------------
  select avlkdomcampovst.vstcpodomdes
    into d_cts06m00.vstflddes
    from avlkdomcampovst
   where avlkdomcampovst.vstcpocod      = 1
     and avlkdomcampovst.vstcpodomcod   = d_cts06m00.vstfld
     and avlkdomcampovst.atlult[09,12] <> 'DELE'

 if sqlca.sqlcode = notfound  then
    let d_cts06m00.vstflddes = "*** NAO PREVISTO ***"
 else
    let d_cts06m00.vstflddes = upshift(d_cts06m00.vstflddes)
 end if

 if d_cts06m00.corsus is not null  then
    let d_cts06m00.cornom = "CORRETOR NAO CADASTRADO"
      select gcakcorr.cornom
        into d_cts06m00.cornom
        from gcakfilial,
             gcaksusep,
             gcakcorr
       where gcaksusep.corsus     = d_cts06m00.corsus
         and gcaksusep.corsuspcp  = gcakfilial.corsuspcp
         and gcakfilial.corfilnum = 1
         and gcakcorr.corsuspcp   = gcakfilial.corsuspcp
 end if

 let d_cts06m00.sucnom = "*** NAO CADASTRADA ***"

 select sucnom
   into d_cts06m00.sucnom
   from gabksuc
  where succod = d_cts06m00.succod

 initialize ws.dptsgl to null
 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = g_issk.empcod
    and funmat = ws.funmat

 let ws.dptsgl = upshift(ws.dptsgl)
 let ws.funnom = upshift(ws.funnom)

 let d_cts06m00.atdtxt = "Atd: ", ws.atddat,
                         " ", ws.atdhor,
                         " ", upshift(ws.dptsgl),
                         " ", ws.funmat using "<<<<<<",
                         " ", upshift(ws.funnom)

 if w_cts06m00.vclcorcod is not null  then
    select cpodes
      into d_cts06m00.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = w_cts06m00.vclcorcod
 end if

 select cpodes
   into d_cts06m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts06m00.atdprinvlcod

 select c24soltipdes
   into d_cts06m00.c24soltipdes
   from datksoltip
        where c24soltipcod = d_cts06m00.c24soltipcod

 message ""

 let d_cts06m00.lgdcep      =   a_cts06m00[1].lgdcep
 let d_cts06m00.lgdcepcmp   =   a_cts06m00[1].lgdcepcmp

  display by name d_cts06m00.vstnumdig,
                  d_cts06m00.atdsrvorg,
                  d_cts06m00.atdsrvnum,
                  d_cts06m00.atdsrvano,
                  d_cts06m00.c24solnom,
                  d_cts06m00.c24soltipcod,
                  d_cts06m00.c24soltipdes,
                  d_cts06m00.vstdat,
                  d_cts06m00.vstc24tip,
                  d_cts06m00.vstc24des,
                  d_cts06m00.succod,
                  d_cts06m00.sucnom,
                  d_cts06m00.vstfld,
                  d_cts06m00.vstflddes,
                  d_cts06m00.ciaempcod,
                  d_cts06m00.empnom,
                  d_cts06m00.lgdcep,
                  d_cts06m00.lgdcepcmp,
                  d_cts06m00.corsus,
                  d_cts06m00.cornom,
                  d_cts06m00.cordddcod,
                  d_cts06m00.cortelnum,
                  d_cts06m00.segnom,
                  d_cts06m00.pestip,
                  d_cts06m00.cgccpfnum,
                  d_cts06m00.cgcord,
                  d_cts06m00.cgccpfdig,
                  d_cts06m00.atdprinvlcod,
                  d_cts06m00.atdprinvldes,
                  d_cts06m00.atdatznom,
                  d_cts06m00.vclcoddig,
                  d_cts06m00.vclmrcnom,
                  d_cts06m00.vcltipnom,
                  d_cts06m00.vclmdlnom,
                  d_cts06m00.vclcordes,
                  d_cts06m00.vcllicnum,
                  d_cts06m00.vclchsnum,
                  d_cts06m00.vclanofbc,
                  d_cts06m00.vclanomdl,
                  d_cts06m00.atdtxt,
                  d_cts06m00.prfhor,
                  d_cts06m00.vclrnvnum,
                  d_cts06m00.segematxt
 display by name a_cts06m00[1].lgdtxt,
                 a_cts06m00[1].lclbrrnom,
                 a_cts06m00[1].cidnom,
                 a_cts06m00[1].ufdcod,
                 a_cts06m00[1].lclrefptotxt,
                 a_cts06m00[1].dddcod,
                 a_cts06m00[1].lcltelnum,
                 a_cts06m00[1].lclcttnom,
                 a_cts06m00[1].endcmp,
                 a_cts06m00[1].celteldddcod,
                 a_cts06m00[1].celtelnum

 # Retirado segundo Marcus Charles da VP - 21/11/2008
 #whenever error continue
 #  select vstbascod
 #      into ws.vstbascod
 #      from avcmbasvst
 #     where vstnumdig = d_cts06m00.vstnumdig
 #  if sqlca.sqlcode <> 0 then
 #     let ws.vstbascod = 0
 #  end if
 #  call apgfvst(d_cts06m00.vstnumdig,"",ws.vstbascod,"",
 #               d_cts06m00.vstdat   ,"cts06m00",g_issk.usrtip,
 #               g_issk.empcod       , g_issk.funmat)
 #whenever error stop

 #-----------------------------------
 # Recupera a ultima etapa do servico
 #-----------------------------------
 initialize ws.atdetpcod to null
 call cts10g04_ultima_etapa(d_cts06m00.atdsrvnum,
                            d_cts06m00.atdsrvano)
                  returning ws.atdetpcod
 ### select datmsrvacp.atdetpcod
 ###   into ws.atdetpcod
 ###   from datmsrvacp
 ###  where datmsrvacp.atdsrvnum   = d_cts06m00.atdsrvnum
 ###    and datmsrvacp.atdsrvano   = d_cts06m00.atdsrvano
 ###    and datmsrvacp.atdsrvseq   =
 ###   (select max(atdsrvseq)
 ###      from datmsrvacp ultetapa
 ###     where ultetapa.atdsrvnum = d_cts06m00.atdsrvnum
 ###       and ultetapa.atdsrvano = d_cts06m00.atdsrvano)

 #--------------------------------------
 # Se a ultima etapa NAO for 4-Concluida
 #--------------------------------------
 if ws.atdetpcod is null or
    ws.atdetpcod <> 4 then

     #----------------------
     # Recupera conexao Palm
     #----------------------
     initialize ws.plmidtnum    to null
     initialize ws.plmcnxinchor to null

     declare c_conex cursor for
     select avcmplmcnx.plmidtnum,
            avcmplmcnx.plmcnxinchor
       from avcmplmcnx
      where avcmplmcnx.vstnumdig    = d_cts06m00.vstnumdig
        and avcmplmcnx.plmcnxincdat = today
     open c_conex
     foreach c_conex into ws.plmidtnum,
                          ws.plmcnxinchor
     end foreach

     if ws.plmidtnum is not null and
        ws.plmcnxinchor is not null then
         let ws.msgpalm = "ATENCAO: O PALM ", ws.plmidtnum using "<<<<<<",
                          " RECEBEU ESTA VISTORIA AS ",
                          ws.plmcnxinchor,
                          " HS SEM CONCLUSAO !!!"
     else
         let ws.msgpalm = ""
     end if

     display by name ws.msgpalm

 end if

 return true

end function  ###  cts06m00_consulta

#-------------------------------------------------------------------------------
 function cts06m00_inclui(hist_cts06m00)
#-------------------------------------------------------------------------------

 define hist_cts06m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define ws              record
        cont            integer                    ,
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        ano             char (02)                  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        atdetpcod       like datmsrvacp.atdetpcod  ,
        vstnum          like datmvistoria.vstnumdig,
        vstnumdig       like datmvistoria.vstnumdig,
        vstnumdat       like datmvistoria.vstnumdig,
        confirma        char (01)                  ,
        histerr         smallint                   ,
        erro            smallint                   ,
        base            smallint
 end record

 define w_retorno       smallint
 define l_ciaempcod_salvo   like datmservico.ciaempcod

    let	w_retorno  =  null

    initialize  ws.*  to  null

 while true
   initialize ws.*  to null

   let ws.ano = w_data[9,10]

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------
 if g_documento.lclocodesres = "S" then
    let w_cts06m00.atdrsdflg = "S"
 else
    let w_cts06m00.atdrsdflg = "N"
 end if
 #------------------------------------------------------------------------------
 # Busca numeracao
 #------------------------------------------------------------------------------
 # begin work

   call cts10g03_numeracao( 2, "4" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS06M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let d_cts06m00.atdsrvano = ws.atdsrvano
   let d_cts06m00.atdsrvnum = ws.atdsrvnum
   let d_cts06m00.atdsrvorg = 10
   let w_cts06m00.vcldes = cts15g00(d_cts06m00.vclcoddig)

 #------------------------------------------------------------------------------
 # Grava servico
 #------------------------------------------------------------------------------
   begin work
   #---------------------------------------------------
   # Salva o valor da global com a empresa do atendente
   #---------------------------------------------------
   let l_ciaempcod_salvo = g_documento.ciaempcod
   let g_documento.ciaempcod = d_cts06m00.ciaempcod
   call cts10g02_grava_servico( d_cts06m00.atdsrvnum,
                                d_cts06m00.atdsrvano,
                                w_cts06m00.atdsoltip,
                                d_cts06m00.c24solnom,
                                w_cts06m00.vclcorcod,
                                g_issk.funmat       ,
                                "S"                 ,     # atdlibflg
                                current hour to minute,   # atdlibhor
                                w_data              ,     # atdlibdat
                                w_data              ,     # atddat
                                w_hora              ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts06m00.atdhorpvt,
                                w_cts06m00.atddatprg,
                                ""                  ,     # atdhorprg
                                "4"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                ""                  ,     # atdprscod
                                ""                  ,     # atdcstvlr
                                w_cts06m00.atdfnlflg,
                                ""                  ,     # atdfnlhor
                                w_cts06m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                ""                  ,     # c24opemat
                                ""                  ,     # nom
                                w_cts06m00.vcldes   ,     # vcldes
                                d_cts06m00.vclanomdl,     # vclanomdl
                                d_cts06m00.vcllicnum,     # vcllicnum
                                ""                  ,     # corsus
                                ""                  ,     # cornom
                                ""                  ,     # cnldat
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                "N"                 ,     # atdpvtretflg
                                ""                  ,     # atdvcltip
                                7                   ,     # asitipcod
                                ""                  ,     # socvclcod
                                d_cts06m00.vclcoddig,     # vclcoddig
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts06m00.atdprinvlcod,
                                10                      ) # ATDSRVORG
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   #------------------------------------------------------
   # Retorna o valor da global para a empresa do atendente
   #------------------------------------------------------
   let g_documento.ciaempcod = l_ciaempcod_salvo

 #------------------------------------------------------------------------------
 # Busca numero da vistoria
 #------------------------------------------------------------------------------
   declare c_xgralvst cursor for
           select grlinf[01,08]
             from IGBKGERAL
                  where mducod = "C24"
                    and grlchv = "NUMVISTORIA"
                  for update of grlinf

   let ws.cont = 0

   while true
     let ws.cont = ws.cont + 1

     open  c_xgralvst
     fetch c_xgralvst into ws.vstnum

       let ws.codigosql = sqlca.sqlcode

       if  ws.codigosql <> 0  then
           if  ws.codigosql = -243  or
               ws.codigosql = -245  or
               ws.codigosql = -246  then
               if  ws.cont < 11  then
                   sleep 1
                   continue while
               else
                   let ws.msg = " Numero da ligacao travado!",
                                " AVISE A INFORMATICA! "
               end if
           else
               let ws.msg = " Erro (", ws.codigosql, ") na selecao do",
                            " numero da vistoria! AVISE A INFORMATICA!"
           end if
       end if

       exit while
   end while

   if  ws.codigosql <> 0  then
       error ws.msg
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let ws.vstnum = ws.vstnum + 1
   if  ws.vstnum > 49999999  then
       error " Faixa de numeracao de vistoria esgotada! AVISE A INFORMATICA! "
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   ##################################
   ### TEMPORARIO RAJI
   ##################################
  #select ((max(vstnumdig) - mod(max(vstnumdig), 10)) / 10) into ws.vstnumdat from datmvistoria
  #if ws.vstnum < ws.vstnumdat then
  #   let ws.vstnum = ws.vstnumdat + 1
  #end if
 #------------------------------------------------------------------------------
 # Atualiza numero da vistoria
 #------------------------------------------------------------------------------
   update IGBKGERAL
      set grlinf = ws.vstnum
          where mducod = "C24"
            and grlchv = "NUMVISTORIA"

   if  sqlca.sqlcode <> 0  then
       error " Erro (", ws.codigosql, ") na atualizacao do",
             " numero da vistoria. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # Grava informacoes da vistoria
 #------------------------------------------------------------------------------
   call F_FUNDIGIT_DIGITOVIST(ws.vstnum) returning d_cts06m00.vstnumdig
   ### if  d_cts06m00.corsus is not null  and
   ###     d_cts06m00.corsus <> " "       then
   ###     initialize d_cts06m00.cornom to null
   ### end if
   ### PSI 203637 - Gravar tambem vps para o mesmo dia
   ### if d_cts06m00.vstc24tip = 0  then
      call figrc072_setTratarIsolamento()
      call fvpia100( d_cts06m00.vstnumdig ,
                     d_cts06m00.vstdat    ,
                     d_cts06m00.lgdcep ,
                     "S" )
             returning ws.erro,
                       ws.msg ,
                       ws.base
     if g_isoAuto.sqlCodErr <> 0 then
        error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
              ,g_isoAuto.sqlCodErr
     end if
   ### end if

   if d_cts06m00.cidcod is null then
        #--------------------------------------
        # Recupera o codigo da cidade pelo nome
        #--------------------------------------
        open ccts06m00006 using a_cts06m00[1].cidnom,
                                a_cts06m00[1].ufdcod
        fetch ccts06m00006 into d_cts06m00.cidcod #-- Codigo da cidade
        close ccts06m00006
   end if

   insert into DATMVISTORIA( atdsrvnum,
                             atdsrvano,
                             vstnumdig,
                             vstc24tip,
                             succod,
                             vstfld,
                             #vstregcod,
                             corsus,
                             cornom,
                             cordddcod,
                             cortelnum,
                             segnom,
                             pestip,
                             cgccpfnum,
                             cgcord,
                             cgccpfdig,
                             vclmrcnom,
                             vclmdlnom,
                             vcltipnom,
                             vclanomdl,
                             vclanofbc,
                             vcllicnum,
                             vclchsnum,
                             atdatznom,
                             vstdat,
                             c24solnom,
                             c24soltipcod,
                             prfhor,
                             horobs,
                             vclrnvnum,
                             cidcod,
                             segematxt
                             )
                     values( d_cts06m00.atdsrvnum,
                             d_cts06m00.atdsrvano,
                             d_cts06m00.vstnumdig,
                             d_cts06m00.vstc24tip,
                             d_cts06m00.succod,
                             d_cts06m00.vstfld,
                             #d_cts06m00.vstregcod,
                             d_cts06m00.corsus,
                             d_cts06m00.cornom,
                             d_cts06m00.cordddcod,
                             d_cts06m00.cortelnum,
                             d_cts06m00.segnom,
                             d_cts06m00.pestip,
                             d_cts06m00.cgccpfnum,
                             d_cts06m00.cgcord,
                             d_cts06m00.cgccpfdig,
                             d_cts06m00.vclmrcnom,
                             d_cts06m00.vclmdlnom,
                             d_cts06m00.vcltipnom,
                             d_cts06m00.vclanomdl,
                             d_cts06m00.vclanofbc,
                             d_cts06m00.vcllicnum,
                             d_cts06m00.vclchsnum,
                             d_cts06m00.atdatznom,
                             d_cts06m00.vstdat,
                             d_cts06m00.c24solnom,
                             d_cts06m00.c24soltipcod,
                             d_cts06m00.prfhor,
                             d_cts06m00.horobs,
                             d_cts06m00.vclrnvnum,
                             d_cts06m00.cidcod,
                             d_cts06m00.segematxt
                             )

   if  sqlca.sqlcode <> 0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " vistoria. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # Grava relacionamento Atd corretor x Servico e Vistoria
 #------------------------------------------------------------------------------
   if  g_cts06m00.corlignum    is not null  and
       g_cts06m00.corligitmseq is not null  then
       if  not ctx08g01( g_cts06m00.corlignum   ,
                         g_cts06m00.corligitmseq,
                         d_cts06m00.atdsrvnum   ,
                         d_cts06m00.atdsrvano   ,
                         d_cts06m00.vstnumdig    )  then
           error " Erro na gravacao do",
                 " relacionamento servico x vistoria. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end if

 #------------------------------------------------------------------------------
 # Grava local de realizacao
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 1
       let a_cts06m00[arr_aux].operacao = "I"

       #--------------------------------------------------------
       # Geraldo - Validacao de chassi
       #--------------------------------------------------------
       let a_cts06m00[arr_aux].lclcttnom[16,20] = m_val_chassi_veic

       let a_cts06m00[arr_aux].lclbrrnom = m_lclbrrnom
       call cts06g07_local( a_cts06m00[arr_aux].operacao    ,
                            d_cts06m00.atdsrvnum            ,
                            d_cts06m00.atdsrvano            ,
                            arr_aux                         ,
                            a_cts06m00[arr_aux].lclidttxt   ,
                            a_cts06m00[arr_aux].lgdtip      ,
                            a_cts06m00[arr_aux].lgdnom      ,
                            a_cts06m00[arr_aux].lgdnum      ,
                            a_cts06m00[arr_aux].lclbrrnom   ,
                            a_cts06m00[arr_aux].brrnom      ,
                            a_cts06m00[arr_aux].cidnom      ,
                            a_cts06m00[arr_aux].ufdcod      ,
                            a_cts06m00[arr_aux].lclrefptotxt,
                            a_cts06m00[arr_aux].endzon      ,
                            a_cts06m00[arr_aux].lgdcep      ,
                            a_cts06m00[arr_aux].lgdcepcmp   ,
                            a_cts06m00[arr_aux].lclltt      ,
                            a_cts06m00[arr_aux].lcllgt      ,
                            a_cts06m00[arr_aux].dddcod      ,
                            a_cts06m00[arr_aux].lcltelnum   ,
                            a_cts06m00[arr_aux].lclcttnom   ,
                            a_cts06m00[arr_aux].c24lclpdrcod,
                            a_cts06m00[arr_aux].ofnnumdig   ,
                            a_cts06m00[arr_aux].emeviacod   ,
                            a_cts06m00[arr_aux].celteldddcod,
                            a_cts06m00[arr_aux].celtelnum   ,
                            a_cts06m00[arr_aux].endcmp)
            returning ws.codigosql

       if  ws.codigosql is null  or
           ws.codigosql <> 0     then
           error " Erro (", ws.codigosql, ") na gravacao do",
                 " local de realizacao. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for

 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
   if  w_cts06m00.atdfnlflg = "N"  then
       let ws.atdetpcod = 1  ###  Vistoria CT24HS.: liberada
   else
       let ws.atdetpcod = 4  ###  Vistoria VOLANTE: acionada
   end if

   call cts10g04_insere_etapa(d_cts06m00.atdsrvnum,
                              d_cts06m00.atdsrvano,
                              ws.atdetpcod        ,
                              " ",
                              " ",
                              " ",
                              " ") returning w_retorno

   if  w_retorno  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(d_cts06m00.atdsrvnum,
                               d_cts06m00.atdsrvano)

   # Zerar coordenadas com agendamento feito via informix
   whenever error continue
   execute pcts06m00013 using d_cts06m00.atdsrvnum
                            ,d_cts06m00.atdsrvano

   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'Erro UPDATE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
   end if

 #--------------------------------------------------
 # Grava validacao de chassi no historico do servico
 #--------------------------------------------------
 #if m_his_chassi_veic is not null then
 #   call ctd07g01_ins_datmservhist(d_cts06m00.atdsrvnum,
 #                                  d_cts06m00.atdsrvano,
 #                                  g_issk.funmat,
 #                                  m_his_chassi_veic,
 #                                  today,
 #                                  current,
 #                                  g_issk.empcod,
 #                                  g_issk.usrtip)
 #                        returning ws.codigosql,
 #                                  ws.msg
 #end if
 #-----------------------------------------------
 # Grava validacao de chassi na mensagem bloqueio
 #-----------------------------------------------
 if m_his_chassi_veic is not null then
    #PAS 100676 - Geraldo Souza - 29/07/2010
    call cts06m12_ins_datmblqmsg(d_cts06m00.atdsrvnum,
                                 d_cts06m00.atdsrvano,
                                 m_his_chassi_veic)
                       returning ws.codigosql,
                                 ws.msg
 end if
 #--------------------------------------------------

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( d_cts06m00.atdsrvnum,
                            d_cts06m00.atdsrvano,
                            w_data              ,
                            w_hora              ,
                            g_issk.funmat       ,
                            hist_cts06m00.*      )
        returning ws.histerr

   if  ws.histerr  = 0  then
       initialize g_documento.acao  to null
   end if

   if  mr_retorno_bloq.codigo >= 3 and mr_retorno_bloq.codigo <= 9 then
       initialize hist_cts06m00.*  to  null
       let hist_cts06m00.hist1 = mr_retorno_bloq.descricao clipped
       #PAS 100676 - Geraldo Souza - 29/07/2010
       #call cts10g02_historico( d_cts06m00.atdsrvnum,
       #                         d_cts06m00.atdsrvano,
       #                         w_data              ,
       #                         w_hora              ,
       #                         g_issk.funmat       ,
       #                         hist_cts06m00.*      )
       #     returning ws.histerr
       call cts06m12_ins_datmblqmsg(d_cts06m00.atdsrvnum,
                                    d_cts06m00.atdsrvano,
                                    hist_cts06m00.hist1)
                          returning ws.codigosql,
                                    ws.msg
   end if

 #------------------------------------------------------------------------------
 # Exibe o numero do servico e o numero da vistoria
 #------------------------------------------------------------------------------
   display d_cts06m00.atdsrvorg  to  atdsrvorg   attribute(reverse)
   display d_cts06m00.atdsrvnum  to  atdsrvnum   attribute(reverse)
   display d_cts06m00.atdsrvano  to  atdsrvano   attribute(reverse)
   display d_cts06m00.vstnumdig  to  vstnumdig   attribute(reverse)
   error  " Verifique o numero de SERVICO e VISTORIA e tecle ENTER! "
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   if  d_cts06m00.vstc24tip = 1  then
       call cts08g01("A","N","","REGISTRE NA PRIMEIRA LINHA DO",
                                "HISTORICO OUTRAS INFORMACOES",
                                "NECESSARIAS PARA O VISTORIADOR")
            returning ws.confirma
   end if

   exit while
 end while

 return ws.retorno


end function  ###  cts06m00_inclui

#-----------------------------------------------------------
 function cts06m00_modifica()
#-----------------------------------------------------------

 define ws            record
    codigosql         integer,
    erro              smallint,
    base              smallint,
    msg               char(40)
 end record

 define prompt_key    char (01)

    let	prompt_key  =  null

    initialize  ws.*  to  null

 let w_cts06m00.vcldes = cts15g00(d_cts06m00.vclcoddig)

### whenever error continue
### begin work

 update  datmservico
    set (atdfnlflg,
         funmat,
         atddatprg,
         atdhorpvt,
         vclcorcod,
         atdpvtretflg,
         atdprinvlcod,
         c24solnom,
         atdsoltip,
         vclcoddig,
         vcldes,
         vclanomdl,
         vcllicnum,
         ciaempcod) =
        (w_cts06m00.atdfnlflg,
         g_issk.funmat,
         w_cts06m00.atddatprg,
         w_cts06m00.atdhorpvt,
         w_cts06m00.vclcorcod,
         "N",
         d_cts06m00.atdprinvlcod,
         d_cts06m00.c24solnom,
         w_cts06m00.atdsoltip,
         d_cts06m00.vclcoddig,
         w_cts06m00.vcldes,
         d_cts06m00.vclanomdl,
         d_cts06m00.vcllicnum,
         d_cts06m00.ciaempcod)
   where atdsrvnum = d_cts06m00.atdsrvnum
     and atdsrvano = d_cts06m00.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode using "<<<<<&", ") na alteracao",
          " do servico de vistoria. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update  datmvistoria
    set (vstc24tip,
         succod,
         vstfld,
        #vstregcod,
         corsus,
         cornom,
         cordddcod,
         cortelnum,
         segnom,
         pestip,
         cgccpfnum,
         cgcord,
         cgccpfdig,
         vclmrcnom,
         vclmdlnom,
         vcltipnom,
         vclanomdl,
         vclanofbc,
         vcllicnum,
         vclchsnum,
         atdatznom,
         vstdat,
         c24solnom,
         c24soltipcod,
         prfhor,
         horobs,
         vclrnvnum,
         cidcod,
         segematxt
         ) =
        (d_cts06m00.vstc24tip,
         d_cts06m00.succod,
        #d_cts06m00.vstregcod,
         d_cts06m00.vstfld,
         d_cts06m00.corsus,
         d_cts06m00.cornom,
         d_cts06m00.cordddcod,
         d_cts06m00.cortelnum,
         d_cts06m00.segnom,
         d_cts06m00.pestip,
         d_cts06m00.cgccpfnum,
         d_cts06m00.cgcord,
         d_cts06m00.cgccpfdig,
         d_cts06m00.vclmrcnom,
         d_cts06m00.vclmdlnom,
         d_cts06m00.vcltipnom,
         d_cts06m00.vclanomdl,
         d_cts06m00.vclanofbc,
         d_cts06m00.vcllicnum,
         d_cts06m00.vclchsnum,
         d_cts06m00.atdatznom,
         d_cts06m00.vstdat,
         d_cts06m00.c24solnom,
         d_cts06m00.c24soltipcod,
         d_cts06m00.prfhor,
         d_cts06m00.horobs,
         d_cts06m00.vclrnvnum,
         d_cts06m00.cidcod,
         d_cts06m00.segematxt
         )
   where atdsrvnum = d_cts06m00.atdsrvnum
     and atdsrvano = d_cts06m00.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode using "<<<<<&", ") na alteracao da",
          " vistoria. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 if salva.lgdcep <> d_cts06m00.lgdcep then
    call figrc072_setTratarIsolamento()
    call fvpia100(d_cts06m00.vstnumdig,
                  d_cts06m00.vstdat   ,
                  salva.lgdcep        ,
                  "C" ) returning  ws.erro, ws.msg , ws.base
    if g_isoAuto.sqlCodErr <> 0 then
       error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
             ,g_isoAuto.sqlCodErr
    end if
    if ws.erro = 0 then
       call figrc072_setTratarIsolamento()
       call fvpia100(d_cts06m00.vstnumdig,
                     d_cts06m00.vstdat   ,
                     d_cts06m00.lgdcep   ,
                     "S" ) returning  ws.erro, ws.msg , ws.base
       if g_isoAuto.sqlCodErr <> 0 then
          error "Marcacao da Vistoria Roteirizada Indisponivel! Erro: "
                ,g_isoAuto.sqlCodErr
       end if
    end if
    if ws.erro <> 0  then
       error " Erro (", sqlca.sqlcode using "<<<<<&", ") na funcao ",
       " fvpia100. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if
 if  g_cts06m00.corlignum    is not null  and
     g_cts06m00.corligitmseq is not null  then
     if  not ctx08g01( g_cts06m00.corlignum   ,
                       g_cts06m00.corligitmseq,
                       d_cts06m00.atdsrvnum   ,
                       d_cts06m00.atdsrvano   ,
                       d_cts06m00.vstnumdig    )  then
         error " Erro na inclusao do relacionamento ligacao x vistoria. ",
               "AVISE A INFORMATICA!"
         rollback work
         prompt "" for char prompt_key
         return false
     end if
 end if

 for arr_aux = 1 to 1
    let a_cts06m00[arr_aux].operacao = "M"

    #--------------------------------------------------------
    # Geraldo - Validacao de chassi
    #--------------------------------------------------------
    let a_cts06m00[arr_aux].lclcttnom[16,20] = m_val_chassi_veic

    let a_cts06m00[arr_aux].lclbrrnom = m_lclbrrnom

    call cts06g07_local(a_cts06m00[arr_aux].operacao,
                        d_cts06m00.atdsrvnum,
                        d_cts06m00.atdsrvano,
                        arr_aux,
                        a_cts06m00[arr_aux].lclidttxt,
                        a_cts06m00[arr_aux].lgdtip,
                        a_cts06m00[arr_aux].lgdnom,
                        a_cts06m00[arr_aux].lgdnum,
                        a_cts06m00[arr_aux].lclbrrnom,
                        a_cts06m00[arr_aux].brrnom,
                        a_cts06m00[arr_aux].cidnom,
                        a_cts06m00[arr_aux].ufdcod,
                        a_cts06m00[arr_aux].lclrefptotxt,
                        a_cts06m00[arr_aux].endzon,
                        a_cts06m00[arr_aux].lgdcep,
                        a_cts06m00[arr_aux].lgdcepcmp,
                        a_cts06m00[arr_aux].lclltt,
                        a_cts06m00[arr_aux].lcllgt,
                        a_cts06m00[arr_aux].dddcod,
                        a_cts06m00[arr_aux].lcltelnum,
                        a_cts06m00[arr_aux].lclcttnom,
                        a_cts06m00[arr_aux].c24lclpdrcod,
                        a_cts06m00[arr_aux].ofnnumdig,
                        a_cts06m00[arr_aux].emeviacod,
                        a_cts06m00[arr_aux].celteldddcod,
                        a_cts06m00[arr_aux].celtelnum,
                        a_cts06m00[arr_aux].endcmp)
              returning ws.codigosql

    if ws.codigosql is null   or
       ws.codigosql <> 0      then
       error " Erro (", ws.codigosql using "<<<<<&", ") na alteracao do",
             " local para realizacao. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

  # Zerar coordenadas com agendamento feito via informix
      whenever error continue
  execute pcts06m00013 using d_cts06m00.atdsrvnum
                            ,d_cts06m00.atdsrvano
    whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro UPDATE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
  end if

 #--------------------------------------------------
 # Grava validacao de chassi no historico do servico
 #--------------------------------------------------
 #if m_his_chassi_veic is null then
 #   let m_his_chassi_veic = "MODELO DO VEICULO E CHASSI INFORMADOS OK"
 #   call ctd07g01_ins_datmservhist(d_cts06m00.atdsrvnum,
 #                                  d_cts06m00.atdsrvano,
 #                                  g_issk.funmat,
 #                                  m_his_chassi_veic,
 #                                  today,
 #                                  current,
 #                                  g_issk.empcod,
 #                                  g_issk.usrtip)
 #                        returning ws.codigosql,
 #                                  ws.msg
 #end if
 #--------------------------------------------------

 #--------------------------------------------------
 # Grava validacao de chassi na mensagem de bloqueio
 #--------------------------------------------------
 if m_his_chassi_veic is null then
    let m_his_chassi_veic = "MODELO DO VEICULO E CHASSI INFORMADOS OK"
    #PAS 100676 - Geraldo Souza - 29/07/2010
    call cts06m12_ins_datmblqmsg(d_cts06m00.atdsrvnum,
                                 d_cts06m00.atdsrvano,
                                 m_his_chassi_veic)
                         returning ws.codigosql,
                                   ws.msg
 end if
 #--------------------------------------------------
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(d_cts06m00.atdsrvnum,
                             d_cts06m00.atdsrvano)

 error " Alteracao efetuada com sucesso!"

### commit work
### whenever error stop

 return true

end function  ###  cts06m00_modifica

#------------------------------------------------------------------------------
# ALTERACAO PSI 237663 - ENVIO PARA SMS - MAIA
#function cts06m00_smsvp(l_celsms)
#
#  define l_menserro char
#  define l_erro smallint
#  define l_totalsms integer
#
#  define l_celsms record
#    celddd    char(4)
#   ,celtelnum char(10)
#   ,msgsms    char(143)
#   ,grlchv    char(10)
#  end record
#
#    call figrc007_sms_send1(l_celsms.celddd    # ddd
#                           ,l_celsms.celtelnum # celular comum
#                           ,l_celsms.msgsms    # primeira sms
#                           ,"VISTORIA PREVIA"  # remetente
#                           ,9                  # prioridade alta
#                           ,172800)            # expiracao 48H
#    returning l_erro
#             ,l_menserro
#    if l_erro <> 0 then
#        error "Erro no envio do SMS! Tente Novamente! "
#        sleep 2
#    else
#         ###############################################################
#         #verifica antes de salvar se o registro de quantidades de sms #
#         #ja exise na tabela, se existir apenas alterar o valor, se nao#
#         #existir cria um novo                                         #
#         ###############################################################
#         select grlinf into l_totalsms
#         from igbkgeral
#         where mducod = 'AVP'
#         and  grlchv  = l_celsms.grlchv
#         if sqlca.sqlcode = 100 then
#            whenever error continue
#               insert into igbkgeral values('AVP',l_celsms.grlchv,'1',null)
#               if sqlca.sqlcode <> 0 then
#                    error 'Problema ao incluir o sms no banco para consulta mensal'
#                    sleep 3
#               end if
#            whenever error stop
#         else
#            let l_totalsms = l_totalsms + 1
#            whenever error continue
#                 update igbkgeral set grlinf = l_totalsms
#                 where mducod = 'AVP'
#                 and  grlchv  = l_celsms.grlchv
#                 if sqlca.sqlcode <> 0 then
#                    error 'Problema ao incluir o sms no banco para consulta mensal'
#                    sleep 3
#                 end if
#            whenever error stop
#         end if
#    end if
#
#end function
# FIM ALTERACAO PSI 237663 - ENVIO PARA SMS - MAIA
#------------------------------------------------------------------------------

