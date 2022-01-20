#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : bdbsr110                                                       #
# Programa   : bdbsr110 - Relatorio de bonificacao por desempenho             #
#-----------------------------------------------------------------------------#
# Analista Resp. : ZYON                                                       #
# PSI            : 188603                                                     #
#                                                                             #
# Desenvolvedor  : JUNIOR (META)                                              #
# DATA           : 05/04/2005                                                 #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica      PSI       Alteracoes                          #
# ---------- ------------------ --------  ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#                                                                             #
# 26/05/2014 Rodolfo Massini    --------  Alteracao na forma de envio de      #
#                                         e-mail (SENDMAIL para FIGRC009)     # 
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

#-----------------------------------------------------------------------------#
main

  call fun_dba_abre_banco("CT24HS") 

  set isolation to dirty read 

  let m_pathlog = f_path("DBS", "LOG")

  if m_pathlog is null then
     let m_pathlog = "."
  end if

  let m_pathlog = m_pathlog clipped, "/bdbsr110.log"
  call startlog(m_pathlog)

  let m_pathrel = f_path("DBS", "RELATO")

  if m_pathrel is null then
     let m_pathrel = "."
  end if

  let m_pathrel = m_pathrel clipped, "/RDBS11001"        

  let m_patharq = f_path("DBS", "ARQUIVO")

  if m_patharq is null then
     let m_patharq = "."
  end if

  call bdbsr110_prepare()
  call bdbsr110()

end main

#-----------------------------------------------------------------------------#
function bdbsr110_prepare()
#-----------------------------------------------------------------------------#

define l_sql   char(1500)


###  CURSOR PRINCIPAL ###
###  ---------------- ###  

let l_sql = " select  datmservico.atdprscod, "
            ,"        dpaksocor.nomgrr ,     "
            ,"        dpaksocor.maides ,     "
            ,"        datmsrvacp.srrcoddig,  "
            ,"        datksrr.srrabvnom,     "
            ,"        datksrr.cgccpfnum,     "
            ,"        datksrr.cgccpfdig,     "
            ,"        datkveiculo.socvclcod, "
            ,"        datkveiculo.atdvclsgl, "
            ,"        datkveiculo.mdtcod,    "
            ,"        datmsrvacp.atdetpdat,  "
            ,"        datmservico.atdsrvorg, "
            ,"        datmservico.atdsrvnum, "
            ,"        datmservico.atdsrvano  "
	    ,"  from datmservico, dpaksocor, "
	    ,"       datmsrvacp, datksrr, datkveiculo "
	    ," where datmsrvacp.atdetpcod in (3,4) "
	    ,"   and datmsrvacp.atdsrvseq = "
	    ,"   (select max(atdsrvseq) "
	    ,"      from datmsrvacp ultetapa "
	    ,"    where ultetapa.atdsrvnum = datmservico.atdsrvnum "
	    ,"      and ultetapa.atdsrvano = datmservico.atdsrvano) "
	    ,"   and datmsrvacp.atdetpdat >= ? "
	    ,"   and datmsrvacp.atdetpdat <= ? "
	    ,"   and datmservico.atdsrvnum = datmsrvacp.atdsrvnum "
	    ,"   and datmservico.atdsrvano = datmsrvacp.atdsrvano "
	    ,"   and datmservico.atdsrvorg in (1,2,4,5,6,7,17) "
	    ,"   and datmservico.atdfnlflg <> 'X' " 
	    ,"   and dpaksocor.pstcoddig = datmservico.atdprscod "
	    ,"   and dpaksocor.qldgracod   = 1 "
	    ,"   and datksrr.srrcoddig     = datmsrvacp.srrcoddig "
	    ,"   and datkveiculo.socvclcod = datmsrvacp.socvclcod "
	    ,"   and datkveiculo.mdtcod    > 0 "
	    ,"   order by datmservico.atdprscod, datmsrvacp.srrcoddig, "
	    ,"            datkveiculo.atdvclsgl, datmsrvacp.atdetpdat, "
	    ,"            datmservico.atdsrvano, datmservico.atdsrvano,"
	    ,"            datmservico.atdsrvnum "

prepare pbdbsr110001  from l_sql
declare cbdbsr110001  cursor for pbdbsr110001


###  Recupera o email do remetente (Porto Socorro) ###
###  --------------------------------------------- ###  

let l_sql = " select relpamtxt "
	    ,"  from igbmparam "
	    ," where relsgl = 'BDBSR110' "
	    ,"   and relpamseq = 1 "
	    ,"   and relpamtip = 1 "

prepare pbdbsr110002  from l_sql
declare cbdbsr110002  cursor for pbdbsr110002


###  Carrega os valores das bonificacoes  ###
###  -----------------------------------  ###  

let l_sql = " select bnfvlr "
	    ,"  from dpakprfind "
	    ," where prfindcod = ? "

prepare pbdbsr110003  from l_sql
declare cbdbsr110003  cursor for pbdbsr110003

end function

#-----------------------------------------------------------------------------#
function bdbsr110()
#-----------------------------------------------------------------------------#
define lr_trab         record
       datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,datavig         date                            ## Data Vigencia Seguros 
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrabvnom       like datksrr.srrabvnom          ## Nome do Socorrista
      ,cgccpfnum       like datksrr.cgccpfnum          ## CPF do Socorrista
      ,cgccpfdig       like datksrr.cgccpfdig          ## Dig. CPF do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          char(03)                        ## SIM / NAO
      ,disp_manha      char(03)                        ## SIM / NAO
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,disp_tarde      char(03)                        ## SIM / NAO
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,satisf          char(03)                        ## SIM / NAO
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,pontual         char(03)                        ## SIM / NAO
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor bonif total
end record

define lr_qualifpont   record
       atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
end record

define lr_qualifsatisf record
       srrcoddig       like datksrr.srrcoddig          ## Codigo do Socorrista 
      ,dataini         date                            ## Data Inicial          
      ,datafim         date                            ## Data Final            
end record

define lr_qualifseg    record
       srrcoddig       like datksrr.srrcoddig          ## Codigo do Socorrista 
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo     
      ,datavig         date                            ## Data para vig dos seguros
end record

define lr_qualifdisp   record
       mdtcod          like datkveiculo.mdtcod         ## Codigo do Socorrista 
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,pertip          char(01)                        ## M=Manha T=Tarde       
end record

define lr_retorno      record
       coderro         integer                         ## Cod.erro ret.0=OK/<>0 Error
      ,msgerro         char(50)                        ## Mensagem erro retorno 
      ,qualificado     char(01)                        ## SIM ou NAO   
end record

define lr_valores      record
       vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor Bonific disp manha
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor Bonific disp tarde
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor Bonific satisfacao
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor Bonific pontualidade
end record

define lr_soma         record 
       manha           decimal(12,2)
      ,tarde           decimal(12,2)
      ,cliente         decimal(12,2)
      ,pontual         decimal(12,2)
      ,bonif           decimal(12,2)
end record

define lr_linha        record
       atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra do Prestador
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrabvnom       like datksrr.srrabvnom          ## Nome do Socorrista 
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          char(03)                        ## SIM / NAO 
      ,disp_manha      char(03)                        ## SIM / NAO
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor Bonif disp manha
      ,disp_tarde      char(03)                        ## SIM / NAO
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor Bonif disp tarde
      ,satisf          char(03)                        ## SIM / NAO
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor Bonif satisfacao
      ,pontual         char(03)                        ## SIM / NAO
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor Bonif pontual
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor Bonif total
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
end record

define l_ant_srrcoddig   like datmservico.atdprscod,
       l_flag            smallint,
       l_data            date

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

 initialize lr_trab.*         to null
 initialize lr_linha.*        to null
 initialize lr_qualifpont.*   to null
 initialize lr_qualifsatisf.* to null
 initialize lr_qualifseg.*    to null
 initialize lr_qualifdisp.*   to null
 initialize lr_retorno.*      to null
 initialize lr_valores.*      to null
 initialize lr_soma.*         to null

###  Verifica se recebeu a data de processamento como argumento ###
###  ---------------------------------------------------------- ###  

 let lr_trab.datastr = arg_val(1)
 
 if lr_trab.datastr is null or
    lr_trab.datastr = " "  then
    let lr_trab.datastr =  today
 else
    let l_data = null
    let l_data = lr_trab.datastr
    if l_data is null then
       display "*** ERRO NO PARAMETRO: DATA INVALIDA ! ***"
       exit program(1)
    end if
 end if

###  Determina  as datas conforme o parametro ou today  ###
###  -------------------------------------------------  ###  

 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let lr_trab.dataini = lr_trab.datastr
 let lr_trab.dataini = lr_trab.dataini - 1 units month
 let lr_trab.datafim = lr_trab.dataini + 1 units month - 1 units day

 let lr_trab.datastr = lr_trab.dataini
 let lr_trab.datastr = "15", lr_trab.datastr[3,10]
 let lr_trab.datavig = lr_trab.datastr

 let lr_valores.vlr_dispmanha = bdbsr110_dpakprfind(2)
 let lr_valores.vlr_disptarde = bdbsr110_dpakprfind(3)
 let lr_valores.vlr_satisf    = bdbsr110_dpakprfind(4)
 let lr_valores.vlr_pontual   = bdbsr110_dpakprfind(5)

 open cbdbsr110002
 whenever error continue 
 fetch cbdbsr110002 into m_remetente
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let m_remetente = null
    else
       let m_erro = "Problemas no acesso tabela igbmparam, sql = ", sqlca.sqlcode
       call errorlog(m_erro)
       display "bdbsr110 / ", m_erro clipped
       exit program(1)
    end if
 end if
 
 if m_remetente is null then
    let m_remetente = "porto.socorro@porto-seguro.com.br"
 end if

 let lr_trab.atdprscod = 0
 let l_ant_srrcoddig   = 0 
 let l_flag            = false
 let lr_soma.manha     = 0
 let lr_soma.tarde     = 0
 let lr_soma.cliente   = 0
 let lr_soma.pontual   = 0
 let lr_soma.bonif     = 0

 start report bdbsr1102_rel to m_pathrel 
   
 open cbdbsr110001 using lr_trab.dataini,
			 lr_trab.datafim

 foreach cbdbsr110001 into  lr_trab.atdprscod,
                            lr_trab.nomgrr,
                            lr_trab.maides,
                            lr_trab.srrcoddig,
                            lr_trab.srrabvnom,
                            lr_trab.cgccpfnum,
                            lr_trab.cgccpfdig,
                            lr_trab.socvclcod,
                            lr_trab.atdvclsgl,
                            lr_trab.mdtcod,
                            lr_trab.atdetpdat,
                            lr_trab.atdsrvorg,
                            lr_trab.atdsrvnum,
                            lr_trab.atdsrvano
                            
     if l_flag = false then
        let m_nomearq = m_patharq clipped, "/RDB00",lr_trab.atdprscod using "<<<<<<", ".txt"
        start report bdbsr110_rel to m_nomearq
        let l_ant_srrcoddig = lr_trab.atdprscod
        let lr_soma.manha   = 0
        let lr_soma.tarde   = 0
        let lr_soma.cliente = 0
        let lr_soma.pontual = 0
        let lr_soma.bonif   = 0
     end if

     if lr_trab.atdprscod <> l_ant_srrcoddig then
        finish report bdbsr110_rel
        let m_assunto = "Relatorio de Bonificacao por desempenho no periodo: ",
                         lr_trab.dataini using "dd/mm/yyyy", " a ", 
                         lr_trab.datafim using "dd/mm/yyyy" ," do prestador ", 
                         lr_linha.atdprscod using "<<<<<<"
        
        ### RODOLFO MASSINI - INICIO 
        #---> remover (comentar) forma de envio de e-mails anterior e inserir
        #     novo componente para envio de e-mails.
        #---> feito por Rodolfo Massini (F0113761) em maio/2013
       
        #let m_comando = ' echo "', m_assunto clipped, '" | send_email.sh ',
        #                ' -a  ', lr_linha.maides clipped,
        #                ' -s "', m_assunto clipped, '" ',
        #                ' -f  ', m_nomearq clipped,
        #                ' -r  ', m_remetente clipped
        #run m_comando returning m_retorno
        
        let lr_mail.ass = m_assunto clipped
        let lr_mail.msg = m_assunto clipped   
        let lr_mail.rem = m_remetente clipped
        let lr_mail.des = lr_linha.maides clipped
        let lr_mail.tip = "text"
        let l_anexo = m_nomearq clipped
  
        call ctx22g00_envia_email_overload(lr_mail.*
                                          ,l_anexo)
        returning l_retorno   
        
        let m_retorno = l_retorno                                     
                                                     
        ### RODOLFO MASSINI - FIM         
       
        
        if m_retorno <> 0 then
           let m_erro = "Problemas ao enviar relatorio(BDSR110) - ", m_nomearq clipped
           call errorlog(m_erro)
           display "bdbsr110 / ", m_erro clipped
        end if

        output to report bdbsr1102_rel(lr_soma.*,
                                       lr_linha.atdprscod,
                                       lr_linha.nomgrr,
                                       lr_linha.dataini,
                                       lr_linha.datafim)

        let m_nomearq = m_patharq clipped, "/RDB00",lr_trab.atdprscod using "<<<<<<", ".txt"
        start report bdbsr110_rel to m_nomearq
        let lr_soma.manha   = 0
        let lr_soma.tarde   = 0
        let lr_soma.cliente = 0
        let lr_soma.pontual = 0
        let lr_soma.bonif   = 0
     end if
     
     let l_ant_srrcoddig = lr_trab.atdprscod
     
     ###  Qualifica a pontualidade do servico ###
     ###  ----------------------------------- ###
     
     let lr_qualifpont.atdsrvnum = lr_trab.atdsrvnum
     let lr_qualifpont.atdsrvano = lr_trab.atdsrvano
     
     call ctb00g06_qualifpont(lr_qualifpont.atdsrvnum,
                              lr_qualifpont.atdsrvano)
          returning lr_retorno.*
     
     if lr_retorno.coderro <> 0 then
        let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
        call errorlog(m_erro)
        display "bdbsr110 / ", m_erro clipped
        exit program(1)
     end if
     
     if lr_retorno.qualificado = "S" then
        let lr_trab.pontual = "Sim"
        let lr_trab.vlr_pontual = lr_valores.vlr_pontual
     else
        let lr_trab.pontual = "Nao"
        let lr_trab.vlr_pontual = 0
     end if
     
     ###  Se mudou o codigo do socorrista, qualifica satisfacao ###
     ###  ----------------------------------------------------- ###

     if l_flag = false or lr_trab.srrcoddig <> lr_linha.srrcoddig then
        let lr_qualifsatisf.srrcoddig = lr_trab.srrcoddig
        let lr_qualifsatisf.dataini   = lr_trab.datafim - 90 units day
        let lr_qualifsatisf.datafim   = lr_trab.datafim
        call ctb00g07_qualifsatisf(lr_qualifsatisf.srrcoddig,
                                   lr_qualifsatisf.dataini,
                                   lr_qualifsatisf.datafim)
             returning lr_retorno.*
        if lr_retorno.coderro <> 0 then
           let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
           call errorlog(m_erro)
           display "bdbsr110 / ", m_erro clipped
           exit program(1)
        end if
        if lr_retorno.qualificado = "S" then
           let lr_trab.satisf = "Sim"
           let lr_trab.vlr_satisf = lr_valores.vlr_satisf
        else
           let lr_trab.satisf = "Nao"
           let lr_trab.vlr_satisf = 0
        end if
     end if
     
     ###  Se mudou o codigo do veiculo, qualifica disponibilidade ###
     ###  ------------------------------------------------------- ###
     
     if l_flag = false or lr_trab.socvclcod <> lr_linha.socvclcod then
        ## Qualifica a disponibilidade pela manha
        ## --------------------------------------
        let lr_qualifdisp.mdtcod    = lr_trab.mdtcod
        let lr_qualifdisp.dataini   = lr_trab.dataini 
        let lr_qualifdisp.datafim   = lr_trab.datafim
        let lr_qualifdisp.pertip    = "M"
        call ctb00g09_qualifdisp(lr_qualifdisp.mdtcod,
                                 lr_qualifdisp.dataini,
                                 lr_qualifdisp.datafim,
                                 lr_qualifdisp.pertip)
             returning lr_retorno.*
        if lr_retorno.coderro <> 0 then
           let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
           call errorlog(m_erro)
           display "bdbsr110 / ", m_erro clipped
           exit program(1)
        end if
        if lr_retorno.qualificado = "S" then
           let lr_trab.disp_manha = "Sim"
           let lr_trab.vlr_dispmanha = lr_valores.vlr_dispmanha
        else
           let lr_trab.disp_manha = "Nao"
           let lr_trab.vlr_dispmanha = 0
        end if
     end if
     
     if l_flag = false or lr_trab.socvclcod <> lr_linha.socvclcod then
        ## Qualifica a disponibilidade pela tarde
        ## --------------------------------------
        let lr_qualifdisp.mdtcod    = lr_trab.mdtcod
        let lr_qualifdisp.dataini   = lr_trab.dataini 
        let lr_qualifdisp.datafim   = lr_trab.datafim
        let lr_qualifdisp.pertip    = "T"
        call ctb00g09_qualifdisp(lr_qualifdisp.mdtcod,
                                 lr_qualifdisp.dataini,
                                 lr_qualifdisp.datafim,
                                 lr_qualifdisp.pertip)
             returning lr_retorno.*
        if lr_retorno.coderro <> 0 then
           let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
           call errorlog(m_erro)
           display "bdbsr110 / ", m_erro clipped
           exit program(1)
        end if
        if lr_retorno.qualificado = "S" then
           let lr_trab.disp_tarde = "Sim"
           let lr_trab.vlr_disptarde = lr_valores.vlr_disptarde
        else
           let lr_trab.disp_tarde = "Nao"
           let lr_trab.vlr_disptarde = 0
        end if
     end if
     
     ###  Se mudou o socorrista ou o veiculo, qualifica seguros ###
     ###  ----------------------------------------------------- ###
     
     if l_flag = false or 
        lr_trab.srrcoddig <> lr_linha.srrcoddig or
        lr_trab.socvclcod <> lr_linha.socvclcod then
        ## Qualifica seguro do prestador + veiculo
        ## ---------------------------------------
        let lr_qualifseg.srrcoddig = lr_trab.srrcoddig
        let lr_qualifseg.socvclcod = lr_trab.socvclcod
        let lr_qualifseg.datavig   = lr_trab.datavig
        call ctb00g08_qualifseg(lr_qualifseg.srrcoddig,
                                lr_qualifseg.socvclcod,
                                lr_qualifseg.datavig)
             returning lr_retorno.*
        if lr_retorno.coderro <> 0 then
           let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
           call errorlog(m_erro)
           display "bdbsr110 / ", m_erro clipped
           exit program(1)
        end if
        if lr_retorno.qualificado = "S" then
           let lr_trab.seguro = "Sim"
        else
           let lr_trab.seguro = "Nao"
        end if
     end if
     
     ## O indicador de seguros e classificatorio
     ## e desqualifica os demais, zerando o valor
     ## ---------------------------------------
     
     if lr_trab.seguro = "Nao" then
        let lr_trab.vlr_dispmanha = 0
        let lr_trab.vlr_disptarde = 0
        let lr_trab.vlr_satisf    = 0
        let lr_trab.vlr_pontual   = 0
     end if
     
     ## Bonifica total (linha)
     ## ----------------------
     
     let lr_trab.vlr_bonif = (lr_trab.vlr_dispmanha +
                              lr_trab.vlr_disptarde +
                              lr_trab.vlr_satisf    +
                              lr_trab.vlr_pontual)

     let lr_soma.manha   = lr_soma.manha   + lr_trab.vlr_dispmanha
     let lr_soma.tarde   = lr_soma.tarde   + lr_trab.vlr_disptarde
     let lr_soma.cliente = lr_soma.cliente + lr_trab.vlr_satisf
     let lr_soma.pontual = lr_soma.pontual + lr_trab.vlr_pontual
     let lr_soma.bonif   = lr_soma.bonif   + lr_trab.vlr_bonif
                              
     let lr_linha.atdprscod     =  lr_trab.atdprscod
     let lr_linha.nomgrr        =  lr_trab.nomgrr
     let lr_linha.maides        =  lr_trab.maides
     let lr_linha.srrcoddig     =  lr_trab.srrcoddig
     let lr_linha.srrabvnom     =  lr_trab.srrabvnom
     let lr_linha.socvclcod     =  lr_trab.socvclcod
     let lr_linha.atdvclsgl     =  lr_trab.atdvclsgl
     let lr_linha.atdetpdat     =  lr_trab.atdetpdat
     let lr_linha.atdsrvorg     =  lr_trab.atdsrvorg
     let lr_linha.atdsrvnum     =  lr_trab.atdsrvnum
     let lr_linha.atdsrvano     =  lr_trab.atdsrvano
     let lr_linha.seguro        =  lr_trab.seguro
     let lr_linha.disp_manha    =  lr_trab.disp_manha
     let lr_linha.vlr_dispmanha =  lr_trab.vlr_dispmanha
     let lr_linha.disp_tarde    =  lr_trab.disp_tarde
     let lr_linha.vlr_disptarde =  lr_trab.vlr_disptarde
     let lr_linha.satisf        =  lr_trab.satisf
     let lr_linha.vlr_satisf    =  lr_trab.vlr_satisf
     let lr_linha.pontual       =  lr_trab.pontual
     let lr_linha.vlr_pontual   =  lr_trab.vlr_pontual
     let lr_linha.vlr_bonif     =  lr_trab.vlr_bonif
     let lr_linha.dataini       =  lr_trab.dataini
     let lr_linha.datafim       =  lr_trab.datafim
     
     output to report bdbsr110_rel(lr_linha.*)

     if l_flag = false then
        let l_flag = true
     end if

 end foreach

 if l_flag = true then
    finish report bdbsr110_rel
    let m_assunto = "Relatorio de Bonificacao por desempenho no periodo: ",
                     lr_trab.dataini using "dd/mm/yyyy", " a ", 
                     lr_trab.datafim using "dd/mm/yyyy" ," do prestador ", 
                     lr_linha.atdprscod using "<<<<<<"
    
    ### RODOLFO MASSINI - INICIO 
    #---> remover (comentar) forma de envio de e-mails anterior e inserir
    #     novo componente para envio de e-mails.
    #---> feito por Rodolfo Massini (F0113761) em maio/2013

    #let m_comando = ' echo "', m_assunto clipped, '" | send_email.sh ',
    #                ' -a  ', lr_linha.maides clipped,
    #                ' -s "', m_assunto clipped, '" ',
    #                ' -f  ', m_nomearq clipped,
    #                ' -r  ', m_remetente clipped
    #run m_comando returning m_retorno
         
    let lr_mail.ass = m_assunto clipped
    let lr_mail.msg = m_assunto clipped   
    let lr_mail.rem = m_remetente clipped
    let lr_mail.des = lr_linha.maides clipped
    let lr_mail.tip = "text"
    let l_anexo = m_nomearq clipped

    call ctx22g00_envia_email_overload(lr_mail.*
                                      ,l_anexo)
    returning l_retorno   
        
    let m_retorno = l_retorno                                     
                                                     
    ### RODOLFO MASSINI - FIM       
     
    if m_retorno <> 0 then
       let m_erro = "Problemas ao enviar relatorio(BDSR110) - ", m_nomearq clipped
       call errorlog(m_erro)
       display "bdbsr110 / ", m_erro clipped
    end if
    output to report bdbsr1102_rel(lr_soma.*,
                                   lr_linha.atdprscod,
                                   lr_linha.nomgrr,
                                   lr_linha.dataini,
                                   lr_linha.datafim)
 end if

 finish report bdbsr1102_rel

end function

#-----------------------------------#
function bdbsr110_dpakprfind(l_param)
#-----------------------------------#

 define l_param       smallint,
        l_valor       like dpakprfind.bnfvlr
        
 let l_valor = null

 open cbdbsr110003 using l_param
 whenever error continue
 fetch cbdbsr110003 into l_valor
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let m_erro = "Registro (dpakprfind.prfindcod = ", l_param using "<<",") nao encontrado "
    else
       let m_erro = "Problemas no acesso tabela dpakprfind, sql2 = ", sqlca.sqlcode
    end if
    call errorlog(m_erro)
    display "bdbsr110 / ", m_erro clipped
    exit program(1)
 end if
 close cbdbsr110003
 
 return l_valor

end function

#-------------------------------#
function bdbsr110_valor(l_valor)
#-------------------------------#

  define l_valor     decimal(12,2),
         l_retorno   char(10),
         l_ix1       smallint
         
  if l_valor is null then
     let l_valor = 0
  end if
         
  let l_retorno = l_valor using "###,##&.&&"
  
  for l_ix1 = 1 to 10
      if l_retorno[l_ix1] = "." then
         let l_retorno[l_ix1] = ","
      else
         if l_retorno[l_ix1] = "," then
            let l_retorno[l_ix1] = "."
         end if
      end if
  end for
  
  return l_retorno

end function

#-----------------------------------------------------------------------------#
report bdbsr110_rel(lr_linha)
#-----------------------------------------------------------------------------#

define lr_linha        record
       atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra do Prestador
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrabvnom       like datksrr.srrabvnom          ## Nome do Socorrista 
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          char(03)                        ## SIM / NAO 
      ,disp_manha      char(03)                        ## SIM / NAO
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor Bonif disp manha
      ,disp_tarde      char(03)                        ## SIM / NAO
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor Bonif disp tarde
      ,satisf          char(03)                        ## SIM / NAO
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor Bonif satisfacao
      ,pontual         char(03)                        ## SIM / NAO
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor Bonif pontual
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor Bonif total
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
end record

define l_soma_manha    dec(12,2)
define l_soma_tarde    dec(12,2)
define l_soma_cliente  dec(12,2)
define l_soma_pontual  dec(12,2)
define l_soma_bonif    dec(12,2)
define l_arquivo       char(20)

define lr_valores      record 
       manha           char(10)
      ,tarde           char(10)
      ,cliente         char(10)
      ,pontual         char(10)
      ,bonif           char(10)
end record

output

   left   margin    00
   right  margin    150
   top    margin    00
   bottom margin    00
   page   length    60

order external by lr_linha.atdprscod, lr_linha.srrcoddig

format

  first page header

      print "Relatorio de Bonificacao por Desempenho no periodo: ",
             lr_linha.dataini, " a ", lr_linha.datafim

      skip 1 line

      print column 001, "Prestador : ", lr_linha.atdprscod using "<<<<<<", 
                        " - ", lr_linha.nomgrr
    
  before group of lr_linha.srrcoddig

      skip 1 line

      print column 001, "Socorrista: ", lr_linha.srrcoddig, " - ",lr_linha.srrabvnom

      skip 1 line

      print column 001, "Veiculo",
            column 013, "Data",
            column 022, "Servico",
            column 037, "Seguro",
            column 045, "Disponibilidade",
            column 061, "Manha",
            column 068, "Disponibilidade",
            column 084, "Tarde",
            column 091, "Satisfacao",
            column 102, "Cliente",
            column 111, "Pontualidade",
            column 127, "Bonificacao Total"

      skip 1 line

  on every row

      let lr_valores.manha   = bdbsr110_valor(lr_linha.vlr_dispmanha)
      let lr_valores.tarde   = bdbsr110_valor(lr_linha.vlr_disptarde)
      let lr_valores.cliente = bdbsr110_valor(lr_linha.vlr_satisf)
      let lr_valores.pontual = bdbsr110_valor(lr_linha.vlr_pontual)
      let lr_valores.bonif   = bdbsr110_valor(lr_linha.vlr_bonif)

      print column 001, lr_linha.atdvclsgl
	   ,column 010, lr_linha.atdetpdat
	   ,column 022, lr_linha.atdsrvorg using "&&","/",
	                lr_linha.atdsrvnum using "&&&&&&&","-",
	                lr_linha.atdsrvano using "&&"
	   ,column 038, lr_linha.seguro
	   ,column 045, lr_linha.disp_manha
	   ,column 056, lr_valores.manha
	   ,column 068, lr_linha.disp_tarde
	   ,column 079, lr_valores.tarde
	   ,column 091, lr_linha.satisf
	   ,column 099, lr_valores.cliente
	   ,column 111, lr_linha.pontual
	   ,column 115, lr_valores.pontual
	   ,column 134, lr_valores.bonif

  after group of lr_linha.srrcoddig 

      let l_soma_manha   = group sum(lr_linha.vlr_dispmanha) 
      let l_soma_tarde   = group sum(lr_linha.vlr_disptarde) 
      let l_soma_cliente = group sum(lr_linha.vlr_satisf)    
      let l_soma_pontual = group sum(lr_linha.vlr_pontual)   
      let l_soma_bonif   = group sum(lr_linha.vlr_bonif)     

      let lr_valores.manha   = bdbsr110_valor(l_soma_manha)
      let lr_valores.tarde   = bdbsr110_valor(l_soma_tarde)
      let lr_valores.cliente = bdbsr110_valor(l_soma_cliente)
      let lr_valores.pontual = bdbsr110_valor(l_soma_pontual)
      let lr_valores.bonif   = bdbsr110_valor(l_soma_bonif)

      skip 1 line

      print column 001, "   Total do Socorrista: ", lr_linha.srrcoddig
           ,column 056, lr_valores.manha
	   ,column 079, lr_valores.tarde
	   ,column 099, lr_valores.cliente
	   ,column 115, lr_valores.pontual
	   ,column 134, lr_valores.bonif

      skip 1 line

  after group of lr_linha.atdprscod 

      let l_soma_manha   = group sum(lr_linha.vlr_dispmanha) 
      let l_soma_tarde   = group sum(lr_linha.vlr_disptarde) 
      let l_soma_cliente = group sum(lr_linha.vlr_satisf)    
      let l_soma_pontual = group sum(lr_linha.vlr_pontual)   
      let l_soma_bonif   = group sum(lr_linha.vlr_bonif)     

      let lr_valores.manha   = bdbsr110_valor(l_soma_manha)
      let lr_valores.tarde   = bdbsr110_valor(l_soma_tarde)
      let lr_valores.cliente = bdbsr110_valor(l_soma_cliente)
      let lr_valores.pontual = bdbsr110_valor(l_soma_pontual)
      let lr_valores.bonif   = bdbsr110_valor(l_soma_bonif)

      print column 001, "   Total do Prestador : ", lr_linha.atdprscod
           ,column 056, lr_valores.manha
	   ,column 079, lr_valores.tarde
	   ,column 099, lr_valores.cliente
	   ,column 115, lr_valores.pontual
	   ,column 134, lr_valores.bonif

end report

#-------------------------------------#
report bdbsr1102_rel(lr_soma, lr_trab)
#-------------------------------------#

define lr_soma    record 
       manha      decimal(12,2)
      ,tarde      decimal(12,2)
      ,cliente    decimal(12,2)
      ,pontual    decimal(12,2)
      ,bonif      decimal(12,2)
end record

define lr_valores record 
       manha      char(10)
      ,tarde      char(10)
      ,cliente    char(10)
      ,pontual    char(10)
      ,bonif      char(10)
end record

define lr_total   record 
       manha      decimal(12,2)
      ,tarde      decimal(12,2)
      ,cliente    decimal(12,2)
      ,pontual    decimal(12,2)
      ,bonif      decimal(12,2)
end record

define lr_trab    record
       atdprscod  like datmservico.atdprscod,
       nomgrr     like dpaksocor.nomgrr,
       dataini    date,
       datafim    date
end record

define l_hora       datetime hour to second

output

   left   margin    00
   right  margin    132
   top    margin    00
   bottom margin    00
   page   length    60


format

  page header

      if pageno = 01 then
         let lr_total.manha   = 0
         let lr_total.tarde   = 0
         let lr_total.cliente = 0
         let lr_total.pontual = 0
         let lr_total.bonif   = 0
         print "OUTPUT JOBNAME=RBDSR11001 FORMNAME=BRANCO"
         print "HEADER PAGE"
         print "JOBNAME=RSBDSR1101 - Relatorio de Bonificacao por Desempenho no periodo: " 
         print "$DJDE$ JDL=XJ0000,JDE=XD0000, DEPT= 'PSOCORRO', COPIES=1, END;"
         print ASCII(12)
      else
         print "$DJDE$ C LIXOLIXO ,;"
         print "$DJDE$ C LIXOLIXO ,;"
         print "$DJDE$ C LIXOLIXO ,;"
         print "$DJDE$ C LIXOLIXO ,;"
         print ASCII(12)
      end if

      let l_hora = current
      
      print column 100, "RDBS110-01    PAGINA :", pageno using "###"
      print column 114, "DATA   : ", today
      print column 022, "Relatorio de Bonificacao por Desempenho no periodo: ",
                        lr_trab.dataini, " a ", lr_trab.datafim,
            column 114, "HORA   : ", l_hora

      skip 1 line
    
      print column 001, "Prestador",
            column 036, "Disponibilidade Manha",
            column 059, "Disponibilidade Tarde",
            column 082, "Satisfacao Cliente",
            column 102, "Pontualidade",
            column 116, "Bonificacao Total"

      skip 1 line

  on every row

      let lr_valores.manha   = bdbsr110_valor(lr_soma.manha)
      let lr_valores.tarde   = bdbsr110_valor(lr_soma.tarde)
      let lr_valores.cliente = bdbsr110_valor(lr_soma.cliente)
      let lr_valores.pontual = bdbsr110_valor(lr_soma.pontual)
      let lr_valores.bonif   = bdbsr110_valor(lr_soma.bonif)

      print column 001, lr_trab.atdprscod using "<<<<<<", " - ", lr_trab.nomgrr clipped
           ,column 047, lr_valores.manha
	   ,column 070, lr_valores.tarde
	   ,column 090, lr_valores.cliente
	   ,column 104, lr_valores.pontual
	   ,column 123, lr_valores.bonif

      let lr_total.manha   = lr_total.manha   + lr_soma.manha
      let lr_total.tarde   = lr_total.tarde   + lr_soma.tarde
      let lr_total.cliente = lr_total.cliente + lr_soma.cliente
      let lr_total.pontual = lr_total.pontual + lr_soma.pontual
      let lr_total.bonif   = lr_total.bonif   + lr_soma.bonif

  on last row   

      skip 1 line

      let lr_valores.manha   = bdbsr110_valor(lr_total.manha)
      let lr_valores.tarde   = bdbsr110_valor(lr_total.tarde)
      let lr_valores.cliente = bdbsr110_valor(lr_total.cliente)
      let lr_valores.pontual = bdbsr110_valor(lr_total.pontual)
      let lr_valores.bonif   = bdbsr110_valor(lr_total.bonif)

      print column 001, "Total Geral:"
           ,column 047, lr_valores.manha
	   ,column 070, lr_valores.tarde
	   ,column 090, lr_valores.cliente
	   ,column 104, lr_valores.pontual
	   ,column 123, lr_valores.bonif

end report

function fonetica2()

# essa funcao esta sendo adicionada, pois nao ha registro dela em fonte algum

end function
