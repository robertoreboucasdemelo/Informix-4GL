#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : bdbsr040                                                       #
# Programa   : bdbsr040 - Relatorio de servicos a residencia acionados por    #
#                         internet ou fax                                     #
#-----------------------------------------------------------------------------#
# Analista Resp. : Priscila Staingel                                          #
# PSI            : 195138                                                     #
#                                                                             #
# Desenvolvedor  : Priscila Staingel                                          #
# DATA           : 17/11/2005                                                 #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
# ---------- --------------------- ------ ------------------------------------#
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 26/05/2014 Rodolfo Massini    ------  Alteracao na forma de envio de        #
#                                       e-mail (SENDMAIL para FIGRC009)       # 
###############################################################################

database porto

define m_pathlog     char(200)
define m_pathrel     char(200)
define m_patharq     char(200)
define m_nomearq     char(200)
define m_remetente   char(200)
define m_assunto     char(200)
define m_comando     char(500)
define m_retorno     smallint
define m_erro        char(200)

main

    #abre banco
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    #localiza local onde sera salvo
    let m_pathlog = f_path("DBS", "LOG")

    if m_pathlog is null then
      let m_pathlog = "."
    end if

    let m_pathlog = m_pathlog clipped, "/bdbsr040.log"
    call startlog(m_pathlog)

    let m_pathrel = f_path("DBS", "RELATO")

    if m_pathrel is null then
      let m_pathrel = "."
    end if

    let m_pathrel = m_pathrel clipped, "/ADBS04001"

    let m_patharq = f_path("DBS", "ARQUIVO")

    if m_patharq is null then
      let m_patharq = "."
    end if

    call bdbsr040_prepare()

    display "-----------------------------------------------------------"
    display "Inicio Processamento - bdbsr040"
    call cts40g03_exibe_info ("I","BDBSR040")
    display " "

    call bdbsr040()

    display " "
    call cts40g03_exibe_info ("F","BDBSR040")

end main

function bdbsr040_prepare()
    define l_sql   char(1500)

    #Busca dados para montar relatório
    # Ler todos os registros de servico a residencia (a.atdsrvorg = 9)
    # que foram acionados (a.atdfnlflg = S) e programados para a data solicitada
    # validar se a maior etapa desse servico tem atdetpcod = 3 (foi realmente
    # acionado) ou atdetpcod = 10(foi realmente acionado e eh retorno) e tenha
    # sido enviado o aviso de acionamento por internet ou fax (envtipcod = 2)
    # deve ser ordenado por prestador (pstcoddig) para a geracao dos relatorios
    let l_sql = 'select a.atdsrvnum, b.atdsrvano,  '
               ,' a.nom, a. atddatprg, a.atdhorprg,'
               ,' b.pstcoddig, c.atdorgsrvnum,     '
               ,' c.atdorgsrvano,                  '
               ,' c.srvretmtvcod,                  '
               ,' c.socntzcod,                     '
               ,' c.espcod                         '
               ,'from datmservico a, datmsrvacp b, '
               ,'     datmsrvre c                  '
               ,' where a.atdsrvorg = 9            '
               ,'   and a.atdfnlflg = ?            '
               ,'   and a.atddatprg = ?            '
               ,'   and a.atdsrvnum = c.atdsrvnum  '
               ,'   and a.atdsrvano = c.atdsrvano  '
               ,'   and c.atdsrvnum = b.atdsrvnum  '
               ,'   and c.atdsrvano = b.atdsrvano  '
               ,'   and b.atdsrvseq = (select max(atdsrvseq)          '
               ,'                     from datmsrvacp                 '
               ,'                     where  atdsrvnum = a.atdsrvnum  '
               ,'                       and  atdsrvano = a.atdsrvano )'
               ,'   and (b.atdetpcod = 3 or b.atdetpcod = 10)         '
               ,'   and b.envtipcod = 2            '
               ,'order by b.pstcoddig, a.atdsrvnum '
    prepare pbdbsr040001  from l_sql
    declare cbdbsr040001 cursor for pbdbsr040001

    #Buscar descrição do motivo de retorno
    let l_sql = 'select srvretmtvdes      '
               ,' from datksrvret         '
               ,' where srvretmtvcod  = ? '
    prepare pbdbsr040002  from l_sql
    declare cbdbsr040002 cursor for pbdbsr040002

    #Buscar descricao motivo retorno quando o codigo do motivo é 999
    let l_sql = 'select srvretexcdes from datmsrvretexc   '
               ,' where atdsrvnum = ? '
               ,'   and atdsrvano = ? '
    prepare pbdbsr040003  from l_sql
    declare cbdbsr040003 cursor for pbdbsr040003

    #Buscar nome e email do prestador
    let l_sql = 'select  nomrazsoc, maides '
               ,' from dpaksocor           '
               ,' where pstcoddig = ?      '
    prepare pbdbsr040004  from l_sql
    declare cbdbsr040004 cursor for pbdbsr040004

end function


function bdbsr040()
    define lr_prestador record
        pstcoddig like datmsrvacp.pstcoddig,
        nomrazsoc like dpaksocor.nomrazsoc,
        maides    like dpaksocor.maides,
        data      date,
        total     smallint
    end record

    define lr_servico record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        nom       like datmservico.nom,
        atddatprg like datmservico.atddatprg,
        atdhorprg like datmservico.atdhorprg,
        lgdtxt    char (65), # datmlcl.lgdtip + datmlcl.lgdnom + datmlcl.lgdnum
        brrnom    like datmlcl.brrnom,
        cidnom    like datmlcl.cidnom,
        ufdcod    like datmlcl.ufdcod,
        atdorgsrvnum  like datmsrvre.atdorgsrvnum,
        atdorgsrvano  like datmsrvre.atdorgsrvano,
        srvretmtvcod  like datmsrvre.srvretmtvcod,
        srvretmtvdes  like datksrvret.srvretmtvdes,
        socntzcod     like datmsrvre.socntzcod,
        socntzdes     like datksocntz.socntzdes,
        espcod        like datmsrvre.espcod,
        espdes        like dbskesp.espdes
    end record

    define lr_exibe record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        nom       like datmservico.nom,
        atddatprg like datmservico.atddatprg,
        atdhorprg like datmservico.atdhorprg,
        endereco      char (100),
        servicoorig   char (50),
        natur_esp     char (40)
    end record

    define l_lclidttxt        like datmlcl.lclidttxt,
           l_endzon           like datmlcl.endzon,
           l_lclrefptotxt     like datmlcl.lclrefptotxt,
           l_dddcod           like datmlcl.dddcod,
           l_lcltelnum        like datmlcl.lcltelnum,
           l_lclcttnom        like datmlcl.lclcttnom,
           l_socntzgrpcod     like datksocntz.socntzgrpcod


    define l_prest like datmsrvacp.pstcoddig
    define l_aux   like datmsrvacp.pstcoddig
    define l_atdfnlflg like datmservico.atdfnlflg
    define l_hora datetime hour to minute
    define l_ret smallint
    define l_mensagem char(80)
    define l_qtd_relat smallint
    define l_espsit like dbskesp.espsit

    define l_envia_email char(01)

    initialize lr_prestador.* to null
    initialize lr_servico.* to null

    let l_envia_email = "N"

    let l_prest = 0
        let l_hora = null
    let l_qtd_relat = 0
    let l_atdfnlflg = 'S'

    #Verifica se recebeu a data de processamento como argumento
    let lr_prestador.data = arg_val(1)

    if lr_prestador.data is null then
        #caso nao tenha recebido buscar a data atual no banco
        # e somar 1 para pegar o dia seguinte
        call cts40g03_data_hora_banco(2)
             returning lr_prestador.data, l_hora
        let lr_prestador.data = lr_prestador.data + 1 units day
    end if

    display "Gerar relatorio para os servicos programadas e acionados para ",
             lr_prestador.data
    display " "

    #assumir remetente
    ## let m_remetente = "EmailCorr.ct24hs@correioporto" Chamado 6064593
    let m_remetente = "EmailCorr.ct24hs@portoseguro.com.br"
    open cbdbsr040001 using l_atdfnlflg,
                            lr_prestador.data
    foreach cbdbsr040001 into lr_servico.atdsrvnum,
                              lr_servico.atdsrvano,
                              lr_servico.nom,
                              lr_servico.atddatprg,
                              lr_servico.atdhorprg,
                              lr_prestador.pstcoddig,
                              lr_servico.atdorgsrvnum,
                              lr_servico.atdorgsrvano,
                              lr_servico.srvretmtvcod,
                              lr_servico.socntzcod,
                              lr_servico.espcod

        if lr_prestador.pstcoddig <> l_prest then
            if l_qtd_relat > 0 and l_envia_email = "S" then   #se nao e o primeiro registro
               #guarda codigo do novo prestador
               let l_aux = lr_prestador.pstcoddig
               #copia codigo do prestador anterior para enviar email
               let lr_prestador.pstcoddig = l_prest
               #envia email para prestador
               call bdbsr040_envia_email(lr_prestador.*)
               #display "Prestador: ", l_prest, " - ", lr_prestador.nomrazsoc
               #display "   e-mail: ", lr_prestador.maides
               #display "           ", lr_prestador.total, " servicos"
               #display " "
               #devolve o codigo do prestador do novo registro
               let lr_prestador.pstcoddig = l_aux
            end if
            # buscar nome do novo prestador
            open cbdbsr040004 using lr_prestador.pstcoddig
            fetch cbdbsr040004 into lr_prestador.nomrazsoc,
                                    lr_prestador.maides
            if lr_prestador.maides is null then
               #nao enviar relatório para o prestador, pois ele nao tem email
               display "ERRO: Prestador sem email cadastrado!!!! "
               display "Prestador: ", lr_prestador.pstcoddig,
                        " - ", lr_prestador.nomrazsoc
               let l_envia_email = "N"
               continue foreach
            end if
            let lr_prestador.total = 1
            let l_qtd_relat = l_qtd_relat + 1
            let m_nomearq = m_patharq clipped, "/RDBS040_",
                            lr_prestador.pstcoddig using "<<<<<&",
                             ".doc"
            #iniciar novo report (lr_prestador.pstcoddig)
            let l_envia_email = "S"
            start report bdbsr040_rel to m_nomearq
        else
            let lr_prestador.total = lr_prestador.total + 1
        end if
        let l_prest = lr_prestador.pstcoddig

        #buscar endereço
        call ctx04g00_local_reduzido(lr_servico.atdsrvnum,
                                     lr_servico.atdsrvano,
                                     1) # no caso de residencia deve buscar o endereço d ocorrencia
              returning l_lclidttxt,
                        lr_servico.lgdtxt,
                        lr_servico.brrnom,
                        l_endzon,
                        lr_servico.cidnom,
                        lr_servico.ufdcod,
                        l_lclrefptotxt,
                        l_dddcod,
                        l_lcltelnum,
                        l_lclcttnom,
                        l_ret

        if l_ret <> 0 then
           display "ERRO: Problemas ao buscar endereço!!!"
           display "prestador: ", l_prest ," servico: ", lr_servico.atdsrvnum
           continue foreach
        end if

        let lr_exibe.endereco = lr_servico.lgdtxt clipped, " - ",
                                lr_servico.brrnom clipped, " - ",
                                lr_servico.cidnom clipped, " - ",
                                lr_servico.ufdcod

        let lr_servico.srvretmtvdes = null
        let lr_exibe.servicoorig = null
        #se rotorno buscar a descrição do motivo
        if lr_servico.atdorgsrvnum is not null or
           lr_servico.atdorgsrvano is not null then
           if lr_servico.srvretmtvcod is null then
               display "ERRO: Problemas com o serviço - eh retorno, mas nao tem motivo preenchido"
               display "prestador: ", l_prest ," servico: ", lr_servico.atdsrvnum
               continue foreach
           end if
           if lr_servico.srvretmtvcod = 999 then
              open cbdbsr040003 using lr_servico.atdsrvnum,
                                      lr_servico.atdsrvano
              whenever error continue
              fetch cbdbsr040003 into lr_servico.srvretmtvdes
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 display "Problemas ao buscar descricao do motivo retorno (999)"
                 display "prestador: ", l_prest ," servico: ", lr_servico.atdsrvnum
                 continue foreach
              end if
           else
              open cbdbsr040002 using lr_servico.srvretmtvcod
              whenever error continue
              fetch cbdbsr040002 into lr_servico.srvretmtvdes
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 display "Problemas ao buscar descricao do motivo retorno"
                 display "prestador: ", l_prest ," servico: ", lr_servico.atdsrvnum
                 continue foreach
              end if
           end if
           let lr_exibe.servicoorig = lr_servico.atdorgsrvnum using "&&&&&&&",
                  "/", lr_servico.atdorgsrvano using "&&", " - ",
                  lr_servico.srvretmtvdes[1,37]
        end if

        #Buscar descricao da natureza
        let lr_servico.socntzdes = null
        call ctc16m03_inf_natureza(lr_servico.socntzcod, "A")
             returning l_ret,
                       l_mensagem,
                       lr_servico.socntzdes,
                       l_socntzgrpcod

        #Buscar descricao da especialidade, caso tenha
        let lr_servico.espdes = null
        if lr_servico.espcod is not null then
            # como para relatorio nao me importa se a especialidade esta
            # ativa ou nao, passo null para a funcao
            let l_espsit = null
            call cts31g00_descricao_esp(lr_servico.espcod, l_espsit)
                 returning lr_servico.espdes
        end if

        let lr_exibe.natur_esp = lr_servico.socntzcod using "&&", " - ",
                                 lr_servico.socntzdes clipped, " - ",
                                 lr_servico.espdes

        let lr_exibe.atdsrvnum  =  lr_servico.atdsrvnum
        let lr_exibe.atdsrvano  =  lr_servico.atdsrvano
        let lr_exibe.nom        =  lr_servico.nom
        let lr_exibe.atddatprg  =  lr_servico.atddatprg
        let lr_exibe.atdhorprg  =  lr_servico.atdhorprg

        #enviar dados para o relatório (output)
        output to report bdbsr040_rel(lr_prestador.*, lr_exibe.*)

     end foreach

     #fechar relatorio
     if l_qtd_relat > 0 and l_envia_email = "S" then    #teve pelo menos 1 relatorio montado
         #envia email para prestador
         call bdbsr040_envia_email(lr_prestador.*)

         #display "Prestador: ", l_prest, " - ", lr_prestador.nomrazsoc
         #display "   e-mail: ", lr_prestador.maides
         #display "           ", lr_prestador.total, " servicos"
         #display " "
     end if
     #display "Enviou ", l_qtd_relat, " relatorios."

end function



report bdbsr040_rel(lr_prestador, lr_exibe)
    define lr_prestador record
        pstcoddig like datmsrvacp.pstcoddig,
        nomrazsoc like dpaksocor.nomrazsoc,
        maides    like dpaksocor.maides,
        data      date,
        total     smallint
    end record

    define lr_exibe record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        nom       like datmservico.nom,
        atddatprg like datmservico.atddatprg,
        atdhorprg like datmservico.atdhorprg,
        endereco      char (100),
        servicoorig   char (50),
        natur_esp     char (40)
    end record

    output
      left   margin    00
      right  margin    150
      top    margin    00
      bottom margin    00
      page   length    60

    format

      first page header
         print column 1, "PORTO SEGURO CIA DE SEGUROS GERAIS"
         print column 1, "RELAÇÃO DE SERVIÇOS À RESIDENCIA ACIONADOS",
               column 99, lr_prestador.data
         print column 1, "------------------------------------------------------------------------------------------------------------"
         print column 1, "Prestador: ", lr_prestador.pstcoddig, " - ", lr_prestador.nomrazsoc
         skip 1 line
         print column 1, "Serviço",
               column 12, "Segurado",
               column 43, "Data/Hora Prog",
               column 59, "Servico Original"
         print column 1, "Natureza",
               column 43, "Endereço"
         skip 1 line

      on every row
         print column 1, lr_exibe.atdsrvnum using "&&&&&&&",
               column 8, "/",
               column 9, lr_exibe.atdsrvano using "&&",
               column 12, lr_exibe.nom[1,30],
               column 43, lr_exibe.atddatprg using "dd/mm/yy",
                          " ",  lr_exibe.atdhorprg,
               column 59, lr_exibe.servicoorig

         print column 1, lr_exibe.natur_esp ,
               column 43, lr_exibe.endereco

         skip 1 line

      on last row
         skip 1 line
         print column 1, "Total de Serviços: ", lr_prestador.total
end report

function bdbsr040_envia_email(lr_prestador)
    define lr_prestador record
        pstcoddig like datmsrvacp.pstcoddig,
        nomrazsoc like dpaksocor.nomrazsoc,
        maides    like dpaksocor.maides,
        data      date,
        total     smallint
    end record
    
    ### RODOLFO MASSINI - INICIO 
    #---> Variaves para:
    #     remover (comentar) forma de envio de e-mails anterior e inserir
    #     novo componente para envio de e-mails.
    #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
    define lr_mail record       
           rem char(50),        
           des char(250),       
           ccp char(250),       
           cco char(250),       
           ass char(500),       
           msg char(32000),     
           idr char(20),        
           tip char(4)          
    end record 
   
    define l_anexo   char (300)
          ,l_retorno smallint
  
    initialize lr_mail
              ,l_anexo
              ,l_retorno
    to null
 
    ### RODOLFO MASSINI - FIM 

    #finalizar report anterior (l_prest)
    finish report bdbsr040_rel

    let m_assunto = "Relatorio de Servicos para ",
                       lr_prestador.nomrazsoc," em ",
                       lr_prestador.data using "dd/mm/yyyy"

    ### RODOLFO MASSINI - INICIO 
    #---> remover (comentar) forma de envio de e-mails anterior e inserir
    #     novo componente para envio de e-mails.
    #---> feito por Rodolfo Massini (F0113761) em maio/2013
    
    #let m_comando = ' echo "', m_assunto clipped, '" | send_email.sh ',
    #                 ' -a  ', lr_prestador.maides clipped,
    #                 ' -s "', m_assunto clipped, '" ',
    #                 ' -f  ', m_nomearq clipped,
    #                 ' -r  ', m_remetente clipped

    #run m_comando returning m_retorno
   
    let lr_mail.ass = m_assunto clipped
    let lr_mail.msg = m_assunto clipped     
    let lr_mail.rem = m_remetente clipped  
    let lr_mail.des = lr_prestador.maides clipped
    let lr_mail.tip = "text"
    let l_anexo =  m_nomearq clipped
  
    call ctx22g00_envia_email_overload(lr_mail.*
                                      ,l_anexo)
    returning l_retorno   
    
    let m_retorno = l_retorno                                     
                                                
    ### RODOLFO MASSINI - FIM
        
    if m_retorno <> 0 then
           let m_erro = "Problemas ao enviar relatorio(BDBSR040) - ", m_nomearq clipped
           call errorlog(m_erro)
           display "bdbsr040 / ", m_erro clipped
    end if

end function
