###############################################################################
# Nome do Modulo: ctd40g00                                             Sergio #
#                                                                      Burini #
# Integracao Porto Socorro x Seguranca - Portonet Prestadores        Ago/2010 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL    DESCRICAO                           #
#-----------------------------------------------------------------------------#
# 06/01/2012  P12010029    Celso Yamahaki Verficacao do tipo de retorno na fun#
#                                         cao usrweb_qra                      #
###############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_ctd40g00_prep smallint

#---------------------------#
 function ctd40g00_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = "select nomgrr ",
                  " from dpaksocor ",
                 " where pstcoddig = ? "

     prepare pctd40g00_01 from l_sql
     declare cctd40g00_01 cursor for pctd40g00_01

     #COMENTADO BURINI let l_sql = "select pst.pstcoddig, ",
     #COMENTADO BURINI                   " pst.pcpatvcod, ",
     #COMENTADO BURINI                   " rel.pstvintip ",
     #COMENTADO BURINI              " from datrsrrpst rel, ",
     #COMENTADO BURINI                   " dpaksocor  pst",
     #COMENTADO BURINI             " where rel.srrcoddig = ? ",
     #COMENTADO BURINI               " and today between viginc and vigfnl ",
     #COMENTADO BURINI               " and pst.pstcoddig = rel.pstcoddig "

     let l_sql = "select pst.pstcoddig, ",
	         " pst.pcpatvcod, ",
	         " rel.pstvintip ",
		 " from datrsrrpst rel, ",
	         " dpaksocor  pst ",
	 	 " where rel.srrcoddig = ? ",
		 " and pst.pstcoddig = rel.pstcoddig ",
	         " and vigfnl = (select max(vigfnl) ",
		 " from datrsrrpst vgn ",
	         " where vgn.srrcoddig = rel.srrcoddig) "

     prepare pctd40g00_02 from l_sql
     declare cctd40g00_02 cursor for pctd40g00_02

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = ? ",
                   " and cpocod = ? "

     prepare pctd40g00_03 from l_sql
     declare cctd40g00_03 cursor for pctd40g00_03

     let l_sql = " select cgccpfnum, ",
                       " srrabvnom, ",
                       " celdddcod, ",
                       " celtelnum, ",
                       " dddcod, ",
                       " telnum, ",
                       " maides ",
                  " from datksrr  srr, ",
                       " datksrrend srrend ",
                 " where srr.srrcoddig = ? ",
                   " and srr.srrcoddig = srrend.srrcoddig "

     prepare pctd40g00_04 from l_sql
     declare cctd40g00_04 cursor for pctd40g00_04

     let l_sql = "select max(srrcoddig) ",
                  " from datksrr ",
                 " where cgccpfnum = ? "

     prepare pctd40g00_05 from l_sql
     declare cctd40g00_05 cursor for pctd40g00_05

     let l_sql = "select cgccpfnum ",
                  " from datksrr ",
                 " where srrcoddig = ? "

     prepare pctd40g00_06 from l_sql
     declare cctd40g00_06 cursor for pctd40g00_06

     let l_sql = "select socanlsitcod, ",
                       " srrstt ",
                  " from datksrr ",
                 " where srrcoddig = ? "

     prepare pctd40g00_07 from l_sql
     declare cctd40g00_07 cursor for pctd40g00_07

     let l_sql = "select srr.srrcoddig ",
                  " from datrsrrpst pst, ",
                       " datksrr    srr ",
                 " where pst.pstcoddig = ? ",
                   " and pst.srrcoddig = srr.srrcoddig ",
                   " and srr.srrstt    = 1 ",
                   " and today between viginc and vigfnl "

     prepare pctd40g00_08 from l_sql
     declare cctd40g00_08 cursor for pctd40g00_08

     let l_sql = "select count(*) ",
                  " from datrsrrpst ",
                 " where pstcoddig = ? ",
                   " and today between viginc and vigfnl "

     prepare pctd40g00_09 from l_sql
     declare cctd40g00_09 cursor for pctd40g00_09

     let l_sql = "select 1 ",
                  " from iddkdominio ",
                 " where cponom = 'PSOATLUSRPOR' ",
                   " and cpodes = ? "

     prepare pctd40g0001  from l_sql
     declare cctd40g00_10  cursor for pctd40g0001

     let m_ctd40g00_prep = true

 end function

#-----------------------------------#
 function ctd40g00_usrweb_qra(param)
#-----------------------------------#

     define param record
         opcao     char(001),
         srrcoddig like datksrr.srrcoddig,
         srrabvnom like datksrr.srrabvnom,
         celdddcod like datksrr.celdddcod,
         celtelnum like datksrr.celtelnum,
         maides    like datksrr.maides
     end record

     define lr_aux record
         errcod      smallint,
         errmsg      char(100),
         srrcoddig   like datksrr.srrcoddig,
         pstcoddig   like dpaksocor.pstcoddig,
         perfil      char(50),
         nomgrr      like dpaksocor.nomgrr,
         pcpatvdes   like iddkdominio.cponom,
         pstvindes   like iddkdominio.cponom,
         xmlresponse char(32000)
     end record

     define lr_err record
         coderr smallint,
         codmsg char(070),
         usrcod char(010)
     end record
     define lr_err2 record
         coderr smallint,
         codmsg char(070),
         usrcod char(010)
     end record
     define l_srrstt like datksrr.srrstt

     initialize lr_aux.*,
                lr_err2.*,
                lr_err.*, l_srrstt to null

     if  (param.opcao     is null or param.opcao     = " ") and
         (param.srrcoddig is null or param.srrcoddig = " ") then
         let lr_err.coderr = -1
         let lr_err.codmsg = "Parametros inválidos."
         return lr_err.coderr,
                lr_err.codmsg
     end if

     #display "g_issk.funmat = ",  g_issk.funmat

     #if  ctd40g00_permissao_atl(g_issk.funmat) then

         #display "USUARIO COM PERMISSAO PARA ALTERACAO"

         if m_ctd40g00_prep is null or
            m_ctd40g00_prep <> true then
            call ctd40g00_prepare()
         end if

         #call ctd40g00_busca_qra_cpf("CPF", param.cgccpfnum)
         #     returning lr_aux.errcod,
         #               lr_aux.errmsg,
         #               lr_aux.srrcoddig
         #
         #if  lr_aux.errcod <> 0 then
         #    return lr_aux.errcod,
         #           lr_aux.errmsg
         #end if

         call ctd40g00_vinculo_info(param.srrcoddig)
              returning lr_aux.errcod,
                        lr_aux.errmsg,
                        lr_aux.pstcoddig,
                        lr_aux.pcpatvdes,
                        lr_aux.pstvindes

       if  ctd40g00_permissao_atl(g_issk.funmat) then
          display " INFORMAÇÕES DO VINCULO "
          display "lr_aux.errcod    = ", lr_aux.errcod
          display "lr_aux.errmsg    = ", lr_aux.errmsg clipped
          display "lr_aux.pstcoddig = ", lr_aux.pstcoddig
          display "lr_aux.pcpatvdes = ", lr_aux.pcpatvdes clipped
          display "lr_aux.pstvindes = ", lr_aux.pstvindes clipped
       end if
         if  lr_aux.errcod <> 0 then
             let lr_err.coderr = -1
             let lr_err.codmsg = "Parametros inválidos."
             return lr_err.coderr,
                    lr_err.codmsg
         end if

         let lr_aux.perfil = lr_aux.pcpatvdes clipped, "_", lr_aux.pstvindes clipped

         open cctd40g00_01 using lr_aux.pstcoddig
         fetch cctd40g00_01 into lr_aux.nomgrr

         if  sqlca.sqlcode <> 0 then
             let lr_err.coderr = 100
             let lr_err.codmsg = "Nome do socorrista não encontrado."
             return lr_aux.errcod,
                    lr_aux.errmsg
         end if

         if  g_issk.funmat is null or g_issk.funmat = " " then
             let g_issk.funmat = 999999
         end if

         case param.opcao
              when "I"

                  call ctd40g00_inclui_webusr_qra(param.srrabvnom,
                                                  lr_aux.pstvindes,
                                                  param.celdddcod,
                                                  param.celtelnum,
                                                  param.maides,
                                                  lr_aux.pstcoddig,
                                                  lr_aux.nomgrr,
                                                  param.srrcoddig,
                                                  lr_aux.perfil, "","")
                        returning lr_err.coderr,
                                  lr_err.codmsg,
                                  lr_err.usrcod
                  whenever error continue
                     select srrstt into l_srrstt
                       from datksrr
                      where srrcoddig = param.srrcoddig

                     if l_srrstt = 4 then
                        call ctd40g00_verifica_bloqueio(param.srrcoddig)
                                 returning lr_err2.coderr,
                                           lr_err2.codmsg
                        if lr_err2.coderr <> 0 then
                           display 'Erro ao Verificar bloqueio: ', param.srrcoddig
                           display 'Erro: ', lr_err2.codmsg clipped
                        end if
                     end if
                  whenever error stop

                        return lr_err.coderr,
                               lr_err.codmsg,
                               lr_err.usrcod

              when "A"
                  call ctd40g00_altera_webusr_qra(param.srrcoddig)
                        returning lr_err.coderr,
                                  lr_err.codmsg

                  if  lr_err.coderr = 0 then
                      call ctd40g00_verifica_bloqueio(param.srrcoddig)
                           returning lr_err.coderr,
                                     lr_err.codmsg
                  end if
              otherwise

         end case
     #else
     #    let lr_err.coderr = 100
     #    let lr_err.codmsg = 'Usuario sem permissao de atualização'
     #end if

     case param.opcao
        when "A"
           return lr_err.coderr,
                  lr_err.codmsg
        when "I"
           let lr_err.coderr = 100
           let lr_err.codmsg = 'Usuario sem permissao de atualização'
           let lr_err.usrcod = "X"
           return lr_err.coderr,
                  lr_err.codmsg,
                  lr_err.usrcod
        otherwise
     end case

 end function

#------------------------------------------#
 function ctd40g00_inclui_webusr_qra(param)
#------------------------------------------#

     define param record
         srrabvnom like datksrr.srrabvnom,
         pstvindes like iddkdominio.cpodes,
         celdddcod like datksrr.celdddcod,
         celtelnum like datksrr.celtelnum,
         maides    like datksrr.maides,
         pstcoddig like dpaksocor.pstcoddig,
         nomgrr    like dpaksocor.nomgrr,
         srrcoddig like datksrr.srrcoddig,
         perfil    char(50),
         pstcoddig_novo like dpaksocor.pstcoddig,
         srrcoddig_novo like datksrr.srrcoddig
     end record

     define lr_xml record
         request  char(32000),
         response char(32000)
     end record

     define lr_aux record
	    errcod    smallint,
	    errmsg    char(100),
	    srrabvnom like datksrr.srrabvnom,
	    cgccpfnum like datksrr.cgccpfnum,
  	    celdddcod like datksrr.celdddcod,
            celtelnum like datksrr.celtelnum,
            dddcod    like datksrrend.dddcod,
            telnum    like datksrrend.telnum,
            maides    like datksrr.maides,
            pstcoddig like dpaksocor.pstcoddig,
	    nomgrr    like dpaksocor.nomgrr,
	    pstvindes like iddkdominio.cpodes,
            pcpatvdes like iddkdominio.cpodes,
            perfil    char(50)
     end record


     define lr_retorno record
         errcod smallint,
         errmsg char(100),
         usrcod char(020)
     end record

     define l_tipo   smallint,
            l_online smallint,
            l_status integer,
            l_msg    char(80),
            l_cmp    char(200),
            l_doc_handle integer,
            l_dig smallint,
	    l_login char(11)

     initialize lr_xml.*,
                lr_retorno.*,
                l_tipo,
                l_online,
                l_status,
                l_msg,
                l_cmp,
                l_doc_handle,
		lr_aux.* to null

     if  param.pstvindes = "GESTOR" then
         let l_tipo = 1
     else
         let l_tipo = 2
     end if


     if  ctd40g00_permissao_atl(g_issk.funmat) then
         DISPLAY "PARAMETROS DA FUNÇÃO ctd40g00_inclui_webusr_qra"
         display "param.srrabvnom = ", param.srrabvnom
         display "param.pstvindes = ", param.pstvindes
         display "param.celdddcod = ", param.celdddcod
         display "param.celtelnum = ", param.celtelnum
         display "param.maides    = ", param.maides clipped
         display "param.pstcoddig = ", param.pstcoddig
         display "param.nomgrr    = ", param.nomgrr clipped
         display "param.srrcoddig = ", param.srrcoddig
         display "param.perfil    = ", param.perfil clipped
     end if

     if  param.srrabvnom is null or param.srrabvnom = " " and
         param.pstvindes is null or param.pstvindes = " " and
         param.celdddcod is null or param.celdddcod = " " and
         param.celtelnum is null or param.celtelnum = " " and
         param.maides    is null or param.maides    = " " and
         param.pstcoddig is null or param.pstcoddig = " " and
         param.nomgrr    is null or param.nomgrr    = " " and
         param.srrcoddig is null or param.srrcoddig = " " and
         param.perfil    is null or param.perfil    = " " then
         let lr_retorno.errcod = -1
         let lr_retorno.errmsg = "Parametros invalidos."
         return lr_retorno.*
     end if

     #ligia fornax jul/2012
#     if param.pstcoddig_novo is not null and
#	param.srrcoddig_novo is not null then
#
#	if param.pstcoddig <> param.pstcoddig_novo then
#	   let l_cmp = "<novoCodigoPrestador>", param.pstcoddig_novo,
#		       "</novoCodigoPrestador>",
#	               "<novoCodigoMatricula>", param.srrcoddig_novo,
#		       "</novoCodigoMatricula>"
#	end if
#     end if

     initialize lr_xml.* to null

#     let param.perfil = ctd40g00_removeespacoembranco(param.perfil)
#
#     let lr_xml.request = "<?xml version='1.0' encoding='ISO-8859-1'?>",
#                          "<service>",
#                          	"<servicename>SincronizaParceiro</servicename>",
#  	 			"<usrtip>X</usrtip>",
#  	 			"<operacao>AI</operacao>",
#  	 			"<usrnom>", param.srrabvnom clipped, "</usrnom>",
#  	 			"<usrdptnom>", param.pstvindes clipped, "</usrdptnom>",
#  	 			"<usrteldddcod>", param.celdddcod using "<<<&&", "</usrteldddcod>",
#        			"<usrtelnum>", param.celtelnum using "<<<<&&&&&&&&", "</usrtelnum>",
#  	 			"<usrrmlnum></usrrmlnum>",
#  	 			"<usrmaides>", param.maides clipped, "</usrmaides>",
#  	 			"<pstcoddig>", param.pstcoddig using "<<<<<<<&", "</pstcoddig>",
#  	 			"<nomrazsoc>", param.nomgrr clipped, "</nomrazsoc>",
#  	 			"<usrclsacescod>", l_tipo using "<<<<<&", "</usrclsacescod>",
#  	 			"<matricula>", param.srrcoddig using "<<<<<<<<<<<&", "</matricula>",
#  	 			"<perfil>", param.perfil clipped, "</perfil>",
#  	 			"<sissgl>PSRONLINE</sissgl>",
#  	 			"<codigoUsuarioLogado>F01",g_issk.funmat using "&&&&&","</codigoUsuarioLogado>",
#	 		 l_cmp clipped,
#	 		 "</service>"
#
     let l_online = online()

#     if  ctd40g00_permissao_atl(g_issk.funmat) then
#         display 'Request da funcao ctd40g00_inclui_webusr_qra()'
#         display "REQUEST :", lr_xml.request clipped
#     end if
#
#     call figrc006_enviar_pseudo_mq("SINCRO.PTNET.LDAPR",
#                                    lr_xml.request,
#                                    l_online)
#           returning l_status,
#                     l_msg,
#                     lr_xml.response
#
#     if  ctd40g00_permissao_atl(g_issk.funmat) then
#         display 'Response da funcao ctd40g00_inclui_webusr_qra()'
#         display "RESPONSE :", lr_xml.response clipped
#     end if
#
#     let l_doc_handle = figrc011_parse(lr_xml.response)
#
#     let lr_retorno.errcod = figrc011_xpath(l_doc_handle, "/retorno/codigo")
#     let lr_retorno.errmsg = figrc011_xpath(l_doc_handle, "/retorno/mensagem")
#     let lr_retorno.usrcod = figrc011_xpath(l_doc_handle, "/retorno/usrtip"),
#                             figrc011_xpath(l_doc_handle, "/retorno/webusrcod")
#


    call ctd40g00_busca_info_qra(param.srrcoddig)
	      returning lr_aux.errcod,
	  		lr_aux.errmsg,
      			lr_aux.srrabvnom,
			lr_aux.cgccpfnum,
      			lr_aux.celdddcod,
	  		lr_aux.celtelnum,
      			lr_aux.dddcod,
  			lr_aux.telnum,
     			lr_aux.maides,
 			lr_aux.pstcoddig,
     			lr_aux.nomgrr,
  			lr_aux.pstvindes,
     			lr_aux.pcpatvdes,
 			lr_aux.perfil

     let l_dig = F_FUNDIGIT_DIGITOCPF(lr_aux.cgccpfnum)
     let l_login = lr_aux.cgccpfnum using "&&&&&&&&&",
			l_dig using "<<<<<<<&&"


     ### Cria novo login na seguranca
     let lr_xml.request = ctd40g00_recupera_xml(param.srrabvnom,
						param.maides,
						l_login	)

     #display  "Enviado para Seg: ", lr_xml.request clipped

     call figrc006_enviar_pseudo_mq("SINCRO.PTNET.LDAPR",
				     lr_xml.request,
				 l_online)
          returning l_status,
		    l_msg,
		    lr_xml.response

     #display "Retorno do MQ ", l_status using "<<<<<<&", " ", l_msg clipped
     #display "Retornado da Seg: ", lr_xml.response clipped

     let l_doc_handle = figrc011_parse(lr_xml.response)

     let lr_retorno.errcod = figrc011_xpath(l_doc_handle, "/retorno/codigo")
     let lr_retorno.errmsg = figrc011_xpath(l_doc_handle, "/retorno/mensagem")

     if lr_retorno.errcod != 0 then
	display "Erro ", lr_retorno.errcod using "<<<<<<<&", " ",
			 lr_retorno.errmsg clipped
     end if

     return lr_retorno.*

 end function

#-------------------------------------------------------#
 function ctd40g00_recupera_xml(l_nome, l_email, l_login)
#-------------------------------------------------------#
 define l_corpo		char(32766),
	l_nome		char(100),
	l_email		char(100),
	l_login		char(11)

     let l_corpo = "<![CDATA[Caro " , l_nome clipped , ",<br>",
     "Estamos lhe enviando a senha para acesso ao Portal de Prestadores.<br>",
     "Seu login e seu CPF e sua senha e #PASSWORD#.<br>",
     "Por razoes de seguranca voce deve altera-la, obrigatoriamente, no momento do primeiro acesso.<br>",
     "Agradecemos seu interesse em utilizar o Portal de Prestadores.]]>"

     ### Cria novo login na seguranca
     let l_corpo ="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?> ",
     "<gestaoAcessoRequestVO>",
     "<serviceName>CRIAR_LOGIN</serviceName>",
     "<tag>INTEGRACAOPTNEG</tag>",
     "<usuarioRequestVO>",
     "	 <codigoPortal>2</codigoPortal>",
     "	 <corpoEmail>", l_corpo clipped, "</corpoEmail>",
     "	 <enderecoEmail>", l_email clipped, "</enderecoEmail> ",
     "   <loginUsuario>", l_login clipped , "</loginUsuario>",
     "<tituloEmail>Acesso ao Portal de Prestadores.</tituloEmail>",
     "</usuarioRequestVO>",
     "</gestaoAcessoRequestVO>"

     return l_corpo

 end function

#------------------------------------------#
 function ctd40g00_altera_webusr_qra(param)
#------------------------------------------#

     define param record
         srrcoddig like datksrr.srrcoddig
     end record

     define lr_aux record
         errcod    smallint,
         errmsg    char(100),
         srrabvnom like datksrr.srrabvnom,
         cgccpfnum like datksrr.cgccpfnum,
         celdddcod like datksrr.celdddcod,
         celtelnum like datksrr.celtelnum,
         dddcod    like datksrrend.dddcod,
         telnum    like datksrrend.telnum,
         maides    like datksrr.maides,
         pstcoddig like dpaksocor.pstcoddig,
         nomgrr    like dpaksocor.nomgrr,
         pstvindes like iddkdominio.cpodes,
         pcpatvdes like iddkdominio.cpodes,
         perfil    char(50),
         tel       like datksrrend.telnum,
         ddd       like datksrrend.dddcod
     end record

     define lr_ret record
         errcod    smallint,
         errmsg    char(100),
         pstcoddig like dpaksocor.pstcoddig,
         perfil    char(50)
     end record

     define lr_xml record
         request  char(32000),
         response char(32000)
     end record

     define l_tipo   smallint,
            l_online smallint,
            l_status integer,
            l_msg    char(80),
            l_doc_handle integer,
	    l_dig	smallint,
	    l_login	char(11),
	    l_srrstt	like datksrr.srrstt,
	    l_socanlsitcod	like datksrr.socanlsitcod


     initialize lr_aux.*,
                lr_ret.*,
                lr_xml.*,
                l_tipo,
                l_online,
                l_status,
                l_msg,
                l_doc_handle to null

     call ctd40g00_busca_info_qra(param.srrcoddig)
          returning lr_aux.errcod,
                    lr_aux.errmsg,
                    lr_aux.srrabvnom,
                    lr_aux.cgccpfnum,
                    lr_aux.celdddcod,
                    lr_aux.celtelnum,
                    lr_aux.dddcod,
                    lr_aux.telnum,
                    lr_aux.maides,
                    lr_aux.pstcoddig,
                    lr_aux.nomgrr,
                    lr_aux.pstvindes,
                    lr_aux.pcpatvdes,
                    lr_aux.perfil

     if  ctd40g00_permissao_atl(g_issk.funmat) then
        display "QRA : ", param.srrcoddig
        DISPLAY "PARAMETROS DA FUNCAO ctd40g00_altera_webusr_qra"
        display "lr_aux.pstcoddig = ", lr_aux.pstcoddig
        display "lr_aux.cgccpfnum = ", lr_aux.cgccpfnum
        display "lr_aux.srrabvnom = ", lr_aux.srrabvnom
        display "lr_aux.pstvindes = ", lr_aux.pstvindes
        display "lr_aux.maides    = ", lr_aux.maides
        display "lr_aux.nomgrr    = ", lr_aux.nomgrr
        display "lr_aux.perfil    = ", lr_aux.perfil
     end if

     if  (lr_aux.pstcoddig is null or lr_aux.pstcoddig = " ") or
         (lr_aux.cgccpfnum is null or lr_aux.cgccpfnum = " ") or
         (lr_aux.srrabvnom is null or lr_aux.srrabvnom = " ") or
         (lr_aux.pstvindes is null or lr_aux.pstvindes = " ") or
         (lr_aux.maides    is null or lr_aux.maides    = " ") or
         (lr_aux.nomgrr    is null or lr_aux.nomgrr    = " ") or
         (lr_aux.perfil    is null or lr_aux.perfil    = " ") then

         if  ctd40g00_permissao_atl(g_issk.funmat) then
            display "Parametros invalidos"
         end if

         #display "ENTROU PARAM 1"
         let lr_ret.errcod = -1
         let lr_ret.errmsg = "Parametros invalidos."
         return lr_ret.errcod,
                lr_ret.errmsg
     end if

     if  ctd40g00_permissao_atl(g_issk.funmat) then
        display "lr_aux.celdddcod = ", lr_aux.celdddcod
        display "lr_aux.celtelnum = ", lr_aux.celtelnum
        display "lr_aux.dddcod    = ", lr_aux.dddcod
        display "lr_aux.telnum    = ", lr_aux.telnum
     end if

     if  lr_aux.celdddcod is null or lr_aux.celdddcod = " " or
         lr_aux.celtelnum is null or lr_aux.celtelnum = " " then

         if  (lr_aux.dddcod is null or lr_aux.dddcod = " " or
              lr_aux.telnum is null or lr_aux.telnum = " ") then
             if  ctd40g00_permissao_atl(g_issk.funmat) then
               DISPLAY "NAO ACHOU O TELEFONE PARA O QRA ", param.srrcoddig
             end if
             let lr_ret.errcod = -1
             let lr_ret.errmsg = "Parametros invalidos."
             return lr_ret.errcod,
                    lr_ret.errmsg
         else
             let lr_aux.ddd = lr_aux.dddcod
             let lr_aux.tel = lr_aux.telnum
         end if
     else
         let lr_aux.ddd = lr_aux.celdddcod
         let lr_aux.tel = lr_aux.celtelnum
     end if
    if  ctd40g00_permissao_atl(g_issk.funmat) then
         display "lr_aux.ddd = ", lr_aux.ddd
         display "lr_aux.tel = ", lr_aux.tel
    end if
     if  lr_aux.errcod <> 0 then
         return lr_aux.errcod,
                lr_aux.errmsg
     end if



#     let lr_xml.request = "<?xml version='1.0' encoding='ISO-8859-1'?>",
#                          "<service>",
#                          	"<servicename>SincronizaParceiro</servicename>",
#                          	"<usrtip>X</usrtip>",
#                          	"<webusrcod></webusrcod>",
#                          	"<pstcoddig>", lr_aux.pstcoddig using "<<<<<<<&", "</pstcoddig>",
#                          	"<matricula>", param.srrcoddig using "<<<<<<<&", "</matricula>",
#                          	"<operacao>AI</operacao>",
#                          	"<usrnom>", lr_aux.srrabvnom clipped, "</usrnom>",
#                          	"<usrdptnom>",lr_aux.pstvindes clipped,"</usrdptnom>",
#                          	"<usrteldddcod>", lr_aux.ddd using "<<<&&", "</usrteldddcod>",
#                          	"<usrtelnum>", lr_aux.tel using "<<<&&&&&&&&", "</usrtelnum>",
#                          	"<usrrmlnum></usrrmlnum>",
#                          	"<usrmaides>", lr_aux.maides clipped, "</usrmaides>",
#                          	"<nomrazsoc>", lr_aux.nomgrr clipped, "</nomrazsoc>",
#                          	"<perfil>", lr_aux.perfil clipped, "</perfil>",
#                          	"<sissgl>PSRONLINE</sissgl>",
#                          	"<codigoUsuarioLogado>F01",g_issk.funmat using "&&&&&","</codigoUsuarioLogado>",
#                          "</service>"
#
     let l_online = online()

#     if  ctd40g00_permissao_atl(g_issk.funmat) then
#        display 'ctd40g00_altera_webusr_qra'
#        display "REQUEST :", lr_xml.request clipped
#    end if

#     call figrc006_enviar_pseudo_mq("SINCRO.PTNET.LDAPR",
#                                    lr_xml.request,
#                                    l_online)
#           returning l_status,
#                     l_msg,
#                     lr_xml.response
#
#     if  ctd40g00_permissao_atl(g_issk.funmat) then
#         display 'ctd40g00_altera_webusr_qra'
#         display "RESPONSE :", lr_xml.response clipped
#     end if
#
#
#     let l_doc_handle = figrc011_parse(lr_xml.response)
#
#     let lr_ret.errcod = figrc011_xpath(l_doc_handle, "/retorno/codigo")
#     let lr_ret.errmsg = figrc011_xpath(l_doc_handle, "/retorno/mensagem")
#
#     return lr_ret.errcod,
#            lr_ret.errmsg
#

     # somente vai chamar a seguranca se o cadastro estiver ativo, conforme solicitacao para o novo portal
     open cctd40g00_07 using param.srrcoddig
     fetch cctd40g00_07 into l_socanlsitcod,
			     l_srrstt

     if l_srrstt = 1 then

        let l_dig = F_FUNDIGIT_DIGITOCPF(lr_aux.cgccpfnum)
        let l_login = lr_aux.cgccpfnum using "&&&&&&&&&",
   			   l_dig using "<<<<<<<&&"


        ### Cria novo login na seguranca
        let lr_xml.request = ctd40g00_recupera_xml(lr_aux.srrabvnom,
					           lr_aux.maides,
					           l_login )


        #display  "Enviado para Seg: ", lr_xml.request clipped

        call figrc006_enviar_pseudo_mq("SINCRO.PTNET.LDAPR",
				        lr_xml.request,
				        l_online)
             returning l_status,
		       l_msg,
		       lr_xml.response

        #display "Retorno do MQ ", l_status using "<<<<<<&", " ", l_msg clipped
        #display "Retornado da Seg: ", lr_xml.response clipped

        let l_doc_handle = figrc011_parse(lr_xml.response)

        let lr_ret.errcod = figrc011_xpath(l_doc_handle, "/retorno/codigo")
        let lr_ret.errmsg = figrc011_xpath(l_doc_handle, "/retorno/mensagem")

        if lr_ret.errcod != 0 then
	   display "Erro ", lr_ret.errcod using "<<<<<<<&", " ",
			    lr_ret.errmsg clipped
        end if

     end if

     return lr_ret.errcod, lr_ret.errmsg
end function

#---------------------------------------#
 function ctd40g00_busca_info_qra(param)
#---------------------------------------#

     define param record
         srrcoddig like datksrr.srrcoddig
     end record

     define lr_ret record
         errcod    smallint,
         errmsg    char(100),
         srrabvnom like datksrr.srrabvnom,
         cgccpfnum like datksrr.cgccpfnum,
         celdddcod like datksrr.celdddcod,
         celtelnum like datksrr.celtelnum,
         dddcod    like datksrrend.dddcod,
         telnum    like datksrrend.telnum,
         maides    like datksrr.maides,
         pstcoddig like dpaksocor.pstcoddig,
         nomgrr    like dpaksocor.nomgrr,
         pstvindes like iddkdominio.cpodes,
         pcpatvdes like iddkdominio.cpodes,
         perfil    char(50)
     end record

     define lr_aux record
         pstvintip like datrsrrpst.pstvintip
     end record

     initialize lr_ret.*,
                lr_aux.* to null

     if m_ctd40g00_prep is null or
        m_ctd40g00_prep <> true then
        call ctd40g00_prepare()
     end if


#     display "5"

     if  param.srrcoddig is null or
         param.srrcoddig = " " then
         let lr_ret.errcod = -1
         let lr_ret.errmsg = "O QRA informado é nulo."
         return lr_ret.*
     end if

     # BUSCA O NUMERO DO CPF ATRAVES DO QRA
     open cctd40g00_04 using param.srrcoddig
     fetch cctd40g00_04 into lr_ret.cgccpfnum,
                             lr_ret.srrabvnom,
                             lr_ret.celdddcod,
                             lr_ret.celtelnum,
                             lr_ret.dddcod,
                             lr_ret.telnum,
                             lr_ret.maides

     if  sqlca.sqlcode <> 0 then
         DISPLAY "NAO ACHOU O CPF ATRAVES DO QRA"
         let lr_ret.errcod = 100
         let lr_ret.errmsg = "QRA nao localizado."
         return lr_ret.*
     end if

     call ctd40g00_vinculo_info(param.srrcoddig)
          returning lr_ret.errcod,
                    lr_ret.errmsg,
                    lr_ret.pstcoddig,
                    lr_ret.pcpatvdes,
                    lr_ret.pstvindes

     if  lr_ret.errcod <> 0 then
         DISPLAY "NAO ACHOU O VINCULO INFORMACOES "
         return lr_ret.*
     end if

     let lr_ret.perfil = lr_ret.pcpatvdes clipped, "_", lr_ret.pstvindes

     let lr_ret.perfil = ctd40g00_removeespacoembranco(lr_ret.perfil)

     # BUSCA O NOME DE GUERRA DO PRESTADOR
     open cctd40g00_01 using lr_ret.pstcoddig
     fetch cctd40g00_01 into lr_ret.nomgrr

     if  sqlca.sqlcode <> 0 then
         DISPLAY "NAO ACHOU O NOME DE GUERRA DO PRESTADOR"
         let lr_ret.errcod = 100
         let lr_ret.errmsg = "Prestador nao encontrado."
         return lr_ret.*
     end if

     # SE TODOS OS DADOS FOREM RETORNADOS CORRETAMENTE
     let lr_ret.errcod = 0
     let lr_ret.errmsg = "Dados do QRA encontrados com sucesso."

     return lr_ret.*

 end function
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO #------------------------------------#
# PROXIMA LIBERAÇAO  function ctd40g00_perfil_qra(param)
# PROXIMA LIBERAÇAO #------------------------------------#
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      define param record
# PROXIMA LIBERAÇAO          srrcoddig like datksrr.srrcoddig
# PROXIMA LIBERAÇAO      end record
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      define lr_ret record
# PROXIMA LIBERAÇAO          errcod    smallint,
# PROXIMA LIBERAÇAO          errmsg    char(100),
# PROXIMA LIBERAÇAO          pstcoddig like dpaksocor.pstcoddig,
# PROXIMA LIBERAÇAO          perfil    char(50)
# PROXIMA LIBERAÇAO      end record
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      define lr_aux record
# PROXIMA LIBERAÇAO          pcpatvdes like iddkdominio.cpodes,
# PROXIMA LIBERAÇAO          pstvindes like iddkdominio.cpodes
# PROXIMA LIBERAÇAO      end record
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      initialize lr_ret.*,
# PROXIMA LIBERAÇAO                 lr_aux.* to null
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      if  param.srrcoddig is null or
# PROXIMA LIBERAÇAO          param.srrcoddig = " " then
# PROXIMA LIBERAÇAO          let lr_ret.errcod = -1
# PROXIMA LIBERAÇAO          let lr_ret.errmsg = "O QRA informado é nulo."
# PROXIMA LIBERAÇAO          return lr_ret.*
# PROXIMA LIBERAÇAO      end if
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      if m_ctd40g00_prep is null or
# PROXIMA LIBERAÇAO         m_ctd40g00_prep <> true then
# PROXIMA LIBERAÇAO         call ctd40g00_prepare()
# PROXIMA LIBERAÇAO      end if
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      call ctd40g00_vinculo_info(param.srrcoddig)
# PROXIMA LIBERAÇAO           returning lr_ret.errcod,
# PROXIMA LIBERAÇAO                     lr_ret.errmsg,
# PROXIMA LIBERAÇAO                     lr_ret.pstcoddig,
# PROXIMA LIBERAÇAO                     lr_aux.pcpatvdes,
# PROXIMA LIBERAÇAO                     lr_aux.pstvindes
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      if  lr_ret.errcod <> 0 then
# PROXIMA LIBERAÇAO          return lr_ret.*
# PROXIMA LIBERAÇAO      end if
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      let lr_ret.perfil = lr_aux.pcpatvdes clipped, "_", lr_aux.pstvindes
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      # SE TODOS OS DADOS FOREM RETORNADOS CORRETAMENTE
# PROXIMA LIBERAÇAO      let lr_ret.errcod = 0
# PROXIMA LIBERAÇAO      let lr_ret.errmsg = "Perfil encontrado com sucesso."
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO      return lr_ret.*
# PROXIMA LIBERAÇAO
# PROXIMA LIBERAÇAO  end function
# PROXIMA LIBERAÇAO
#------------------------------------#
 function ctd40g00_vinculo_info(param)
#------------------------------------#

     define param record
         #opcao      char(01),   # T: Total / P: Prestador / V: Vinculo
         srrcoddig  like datksrr.srrcoddig
     end record

     define lr_ret record
         errcod    smallint,
         errmsg    char(100),
         pstcoddig like dpaksocor.pstcoddig,
         pcpatvdes like iddkdominio.cpodes,
         pstvindes like iddkdominio.cpodes
     end record

     define lr_aux record
         pcpatvcod like dpaksocor.pcpatvcod,
         pstvintip like datrsrrpst.pstvintip
     end record

     initialize lr_ret.*,
                lr_aux.* to null

#     display "2"

   #  display "param.srrcoddig = ",  param.srrcoddig

     if  param.srrcoddig is null or
         param.srrcoddig = " " then
         let lr_ret.errcod = -1
         let lr_ret.errmsg = "O QRA informado é nulo."
         return lr_ret.*
     end if

     if m_ctd40g00_prep is null or
        m_ctd40g00_prep <> true then
        call ctd40g00_prepare()
     end if

     # BUSCA PRESTADOR / ATIVIDADE / VINCULO VIGENTE PARA O QRA
     open cctd40g00_02  using param.srrcoddig
     fetch cctd40g00_02 into lr_ret.pstcoddig,
                             lr_aux.pcpatvcod,
                             lr_aux.pstvintip

     if  sqlca.sqlcode <> 0 then
         let lr_ret.errcod = 100
         let lr_ret.errmsg = "Relacao Prestador x Socorrista nao encontrado."
         return lr_ret.*
     end if

     call ctd40g00_busca_dominio('pstvintip',
                                 lr_aux.pstvintip)
          returning lr_ret.errcod,
                    lr_ret.errmsg,
                    lr_ret.pstvindes

     if  lr_ret.errcod <> 0 then
         let lr_ret.errcod = 100
         let lr_ret.errmsg = "Vinculo nao encontrado."
         return lr_ret.*
     end if

     call ctd40g00_busca_dominio('pcpatvcod',
                                 lr_aux.pcpatvcod)
          returning lr_ret.errcod,
                    lr_ret.errmsg,
                    lr_ret.pcpatvdes

     if  lr_ret.errcod <> 0 then
         let lr_ret.errcod = 100
         let lr_ret.errmsg = "Atividade prestador nao encontrada."
         return lr_ret.*
     end if

     let lr_ret.errcod = 0
     let lr_ret.errmsg = "Informações do vinculo encontradas com sucesso."

     return lr_ret.errcod,
            lr_ret.errmsg,
            lr_ret.pstcoddig,
            lr_ret.pcpatvdes,
            lr_ret.pstvindes

 end function

#--------------------------------------#
 function ctd40g00_busca_dominio(param)
#--------------------------------------#

     define param record
         cponom like iddkdominio.cponom,
         cpocod like iddkdominio.cpocod
     end record

     define lr_ret record
         errcod smallint,
         errmsg char(100),
         cpodes like iddkdominio.cpodes
     end record

     initialize lr_ret.* to null

     open cctd40g00_03 using param.cponom,
                             param.cpocod
     fetch cctd40g00_03 into lr_ret.cpodes

     let lr_ret.errcod = sqlca.sqlcode
     let lr_ret.errmsg = "Dominio ", param.cponom


     case lr_ret.errcod
          when 0
               let lr_ret.errmsg = lr_ret.errmsg clipped, " encontrado com sucesso."
          when 100
               let lr_ret.errmsg = lr_ret.errmsg clipped, " nao encontrado."
          otherwise
               let lr_ret.errmsg = "ERRO ", lr_ret.errcod , " na localizacao do ", lr_ret.errmsg
     end case

     return lr_ret.*

 end function


#--------------------------------------#
 function ctd40g00_busca_qra_cpf(param)
#--------------------------------------#

     define param record
         opcao char(03),
         chave integer
     end record

     define lr_retorno record
         coderr    smallint,
         codmsg    char(100),
         retorno   integer
     end record

     initialize lr_retorno.* to null

     if m_ctd40g00_prep is null or
        m_ctd40g00_prep <> true then
        call ctd40g00_prepare()
     end if

     #display "FUNCAO ctd40g00_busca_qra_cpf"
     #display "param.opcao = ", param.opcao
     #display "param.chave = ", param.chave

     if  param.opcao = "CPF" then
         open cctd40g00_05 using param.chave
         fetch cctd40g00_05 into lr_retorno.retorno
     else
         open cctd40g00_06 using param.chave
         fetch cctd40g00_06 into lr_retorno.retorno
     end if

     let lr_retorno.coderr = sqlca.sqlcode

     #display "lr_retorno.retorno = ", lr_retorno.retorno

     case lr_retorno.coderr
          when 0
             let lr_retorno.codmsg = param.opcao clipped, " encontrado com sucesso."
          when 100
             let lr_retorno.codmsg = param.opcao clipped, " encontrado com sucesso."
          otherwise
             let lr_retorno.codmsg = "Problema função ctd40g00_busca_qra_cpf. ERRO: ", sqlca.sqlcode
     end case

     return lr_retorno.*

 end function

#------------------------------------------#
 function ctd40g00_sincroniza_acesso(param)
#------------------------------------------#

     define param record
         operacao  char(02),
         srrcoddig like datksrr.srrcoddig
     end record

     define lr_xml record
         request  char(32000),
         response char(32000)
     end record

     define lr_retorno record
         errcod smallint,
         errmsg char(100)
     end record

     define lr_aux record
         pstcoddig like dpaksocor.pstcoddig,
         cgccpfnum like datksrr.cgccpfnum
     end record

     define l_online     smallint,
            l_status     integer,
            l_msg        char(80),
            l_doc_handle integer,
            l_pstcoddig  like dpaksocor.pstcoddig,
            l_aux        char(100)

     initialize lr_xml.*,
                lr_aux.*,
                lr_retorno.*,
                l_online,
                l_status,
                l_msg,
                l_doc_handle to null


     #if  ctd40g00_permissao_atl(g_issk.funmat) then

         if  param.srrcoddig is null or param.srrcoddig = " " and
             param.operacao  is null or param.operacao  = " " then
             let lr_retorno.errcod = -1
             let lr_retorno.errmsg = "Parametros invalidos."
             return lr_retorno.*
         end if

         if  param.operacao <> 'BI' and
             param.operacao <> 'DI' then
             let lr_retorno.errcod = -1
             let lr_retorno.errmsg = "Parametros invalidos - Opcao de sincronismo invalido."
             return lr_retorno.*
         end if

         if  g_issk.funmat is null or g_issk.funmat = " " then
             let g_issk.funmat = 999999
         end if

         #call ctd40g00_busca_qra_cpf("QRA", param.srrcoddig)
         #     returning lr_retorno.errcod,
         #               lr_retorno.errmsg,
         #               lr_aux.cgccpfnum

         if  lr_retorno.errcod <> 0 then
             return lr_retorno.errcod,
                    lr_retorno.errmsg
         end if

         call ctd40g00_vinculo_info(param.srrcoddig)
              returning l_status,
                        l_msg,
                        lr_aux.pstcoddig,
                        l_aux,
                        l_aux

         if  l_status <> 0 then
             let lr_retorno.errcod = -1
             let lr_retorno.errmsg = "Parametros inválidos."
             return lr_retorno.errcod,
                    lr_retorno.errmsg
         end if

         let lr_xml.request = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                              "<service>",
                                 "<servicename>SincronizaParceiro</servicename>",
                                 "<usrtip>X</usrtip>",
                                 "<webusrcod></webusrcod>",
                                 "<pstcoddig>", lr_aux.pstcoddig using "<<<<<<<&", "</pstcoddig >",
                                 "<matricula>", param.srrcoddig using "<<<<<<<<<<<&", "</matricula>",
                                 "<operacao>", param.operacao, "</operacao>",
                                 "<sissgl>PSRONLINE</sissgl>",
                                 #"<codigoUsuarioLogado>", g_issk.funmat, "</codigoUsuarioLogado>",
                                 "<codigoUsuarioLogado>F01",g_issk.funmat using "&&&&&","</codigoUsuarioLogado>",
                              "</service>"

         let l_online = online()

         if ctd40g00_permissao_atl(g_issk.funmat) then
            display 'ctd40g00_sincroniza_acesso'
            display "REQUEST :", lr_xml.request clipped
         end if

         call figrc006_enviar_pseudo_mq("SINCRO.PTNET.LDAPR",
                                        lr_xml.request,
                                        l_online)
               returning l_status,
                         l_msg,
                         lr_xml.response

         if ctd40g00_permissao_atl(g_issk.funmat) then
             display 'ctd40g00_sincroniza_acesso'
             display "RESPONSE :", lr_xml.response clipped
         end if

         let l_doc_handle = figrc011_parse(lr_xml.response)

         let lr_retorno.errcod = figrc011_xpath(l_doc_handle, "/retorno/codigo")
         let lr_retorno.errmsg = figrc011_xpath(l_doc_handle, "/retorno/mensagem")

     #else
     #    let lr_retorno.errcod = 100
     #    let lr_retorno.errmsg = 'Usuario sem permissao de atualização'
     #end if

     return lr_retorno.*

 end function

#------------------------------------------#
 function ctd40g00_verifica_bloqueio(param)
#------------------------------------------#

     define param record
         srrcoddig like datksrr.srrcoddig
     end record

     define lr_retorno record
         sttsrr char(01)
     end record

     define lr_aux record
         socanlsitcod like datksrr.socanlsitcod,
         srrstt       like datksrr.srrstt,
         errcod       integer,
         errmsg       char(100)
     end record

     open cctd40g00_07 using param.srrcoddig
     fetch cctd40g00_07 into lr_aux.socanlsitcod,
                             lr_aux.srrstt

     if  (lr_aux.socanlsitcod = 2 and lr_aux.srrstt = 1) then

         #display "ENTROU 1"

         call ctd40g00_sincroniza_acesso("DI", param.srrcoddig)
              returning lr_aux.errcod,
                        lr_aux.errmsg
     else
         #display "ENTROU 2"

         call ctd40g00_sincroniza_acesso("BI", param.srrcoddig)
              returning lr_aux.errcod,
                        lr_aux.errmsg
     end if

     return lr_aux.errcod,
            lr_aux.errmsg

 end function

#---------------------------------------------#
 function ctd40g00_removeespacoembranco(l_chr)
#---------------------------------------------#
     define l_chr	  char(100),
            l_nchr	  char(100),
            l_indice integer,
            l_len	  integer

     initialize l_nchr to null

     let l_len = length (l_chr)

     for l_indice = 1 to l_len
         if l_chr[l_indice,l_indice] <> " " then
            let l_nchr = l_nchr clipped, l_chr[l_indice,l_indice]
         end if
     end for

     return l_nchr

 end function

#-----------------------------------------#
 function ctd40g00_atualiza_usr_emp(param)
#-----------------------------------------#

   define param record
       pstcoddig like dpaksocor.pstcoddig
   end record

   define lr_retorno record
       coderr  smallint,
       msgerr  char(050)
   end record

   define lr_aux record
       srrcoddig like datksrr.srrcoddig,
       total     smallint,
       inc       char(50),
       texto     char(100)
   end record

   define l_ind smallint

   initialize lr_retorno,
              lr_aux,
              l_ind to null

   if  param.pstcoddig is null or
       param.pstcoddig = " " then
       return
   end if

   if m_ctd40g00_prep is null or
      m_ctd40g00_prep <> true then
      call ctd40g00_prepare()
   end if

   #if  ctd40g00_permissao_atl(g_issk.funmat) then

       open cctd40g00_09 using param.pstcoddig
       fetch cctd40g00_09 into lr_aux.total

       #display "TOTAL DE REGISTROS: ", lr_aux.total

       open cctd40g00_08 using param.pstcoddig
       fetch cctd40g00_08 into lr_aux.srrcoddig

       if  sqlca.sqlcode = 0 then

           open window w_ctd40g00w at 11,21 with form "ctd40g00w"
                attribute (form line 1, border)

           #begin work

           let l_ind = 1

           foreach cctd40g00_08 into lr_aux.srrcoddig

                   if length(lr_aux.inc) < 40 then
                      if l_ind mod 2 = 0 then
                         let lr_aux.inc = lr_aux.inc clipped, ascii 157
                      end if

                      let lr_aux.texto[06,32] = 'Atualizando usuarios'
                      display by name lr_aux.inc attribute (reverse)
                      display by name lr_aux.texto
                   else
                      let lr_aux.texto[02,32] = 'Finalizando processo. Aguarde'

	              display by name lr_aux.texto
                   end if

                   call ctd40g00_altera_webusr_qra(lr_aux.srrcoddig)
                        returning lr_retorno.coderr,
                                  lr_retorno.msgerr

                   #if  lr_retorno.coderr <> 0 then
                   #    exit foreach
                   #end if

                   let l_ind = l_ind + 1

           end foreach

           sleep 1
           close window w_ctd40g00w

           #if  lr_retorno.coderr <> 0 then
           #    rollback work
           #else
           #    commit work
           #end if
       else
           if  sqlca.sqlcode = 100 then
               let lr_retorno.msgerr = "Nenhum socorrista encontrado para esse prestador."
           else
               let lr_retorno.msgerr = "Erro ", sqlca.sqlcode, " SELECT datrsrrpst (ctd40g00)"
           end if

           let lr_retorno.coderr = sqlca.sqlcode
       end if
   #else
   #    let lr_retorno.coderr = 100
   #    let lr_retorno.msgerr = 'Usuario sem permissao de atualização'
   #end if

   return lr_retorno.coderr,
          lr_retorno.msgerr

 end function

#---------------------------------------#
 function ctd40g00_permissao_atl(l_param)
#---------------------------------------#

     define l_funmat    like datmservico.funmat,
            l_param     like datmservico.funmat

     if m_ctd40g00_prep is null or
        m_ctd40g00_prep <> true then
        call ctd40g00_prepare()
     end if

     open cctd40g00_10 using l_param
     fetch cctd40g00_10 into l_funmat

     if  sqlca.sqlcode = 0 then
         return true
     end if

     return false

 end function
