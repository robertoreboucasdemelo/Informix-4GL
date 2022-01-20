#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTN55C00.4GL                                              #
# ANALISTA RESP..: SERGIO BURINI                                             #
# PSI/OSF........:                                                           #
# OBJETIVO.......: INTERFACE PORTO SOCORRO X DAF.                            #
#............................................................................#
# DESENVOLVIMENTO: SERGIO BURINI                                             #
# LIBERACAO......: 04/05/2009                                                #
#............................................................................#
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 28/03/2012 Sergio Burini  PSI-2010-01968/PB                                #
# -------------------------------------------------------------------------- #

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_dados record
     vcllicnum   like abbmveic.vcllicnum,
     vclchsfnl   like abbmveic.vclchsfnl,
     servicename char(25)
 end record

#-----------------------------------------#
 function ctn55c00_busca_coordenada(param)
#-----------------------------------------#

 define param record
      vcllicnum   like abbmveic.vcllicnum,
      vclchsfnl   like abbmveic.vclchsfnl
 end record

 define lr_retorno record
     lclltt like datmlcl.lclltt,
     lcllgt like datmlcl.lcllgt,
     errcod smallint,
     msgtxt char(25)
 end record

 call ctn55c00_integracao_daf(param.vcllicnum,
                              param.vclchsfnl,
                              "BUSCA_ULTIMA_COOR_DAF")
      returning lr_retorno.lclltt,
                lr_retorno.lcllgt,
                lr_retorno.errcod,
                lr_retorno.msgtxt

 return lr_retorno.lclltt,
        lr_retorno.lcllgt,
        lr_retorno.errcod,
        lr_retorno.msgtxt

 end function

#---------------------------------------#
 function ctn55c00_integracao_daf(param)
#---------------------------------------#

 define param record
     vcllicnum   like abbmveic.vcllicnum,
     vclchsfnl   like abbmveic.vclchsfnl,
     servicename char(25)
 end record

 define lr_xml record
     request  char(2000),
     response char(2000),
     online   smallint,
     errcod   integer,
     msgtxt   char(30)
 end record

 define lr_retorno record
     statusdaf smallint,
     lclltt    like datmlcl.lclltt,
     lcllgt    like datmlcl.lcllgt,
     errcod    smallint,
     msgtxt    char(25)
 end record

 initialize lr_retorno.* to null

 let mr_dados.vcllicnum   = param.vcllicnum
 let mr_dados.vclchsfnl   = param.vclchsfnl
 let mr_dados.servicename = param.servicename

 if  mr_dados.servicename <> "BUSCA_ULTIMA_COOR_DAF" then
     let lr_retorno.errcod = "1"
     let lr_retorno.msgtxt = "SERVICO INVALIDO"
     return lr_retorno.lclltt,
            lr_retorno.lcllgt,
            lr_retorno.errcod,
            lr_retorno.msgtxt
 end if

 call figrc011_inicio_parse()

 # CHAMA A FUNCAO P/ RETORNAR O XML DE RESPONSE A PARTIR DO XML DE REQUEST
 let lr_xml.online = online()

 let lr_xml.request = ctn55c00_monta_request()
 
 if  g_issk.funmat = 4236 then
     display "LR_XML.REQUEST = ", lr_xml.request clipped
 end if

 call figrc006_enviar_pseudo_mq("KDFCOORDEDAFJAVA01R",
                                lr_xml.request,
                                lr_xml.online)
      returning lr_xml.errcod,
                lr_xml.msgtxt,
                lr_xml.response

 if  g_issk.funmat = 4236 then
     display "lr_xml.errcod   = ", lr_xml.errcod  
     display "lr_xml.msgtxt   = ", lr_xml.msgtxt  
     display "lr_xml.response = ", lr_xml.response clipped
 end if

 call ctn55c00_verifica_retorno(mr_dados.servicename,
                                lr_xml.response)
      returning lr_retorno.lclltt,
                lr_retorno.lcllgt,
                lr_retorno.errcod,
                lr_retorno.msgtxt
                
 if  g_issk.funmat = 4236 then
     display "lr_retorno.lclltt = ", lr_retorno.lclltt
     display "lr_retorno.lcllgt = ", lr_retorno.lcllgt
     display "lr_retorno.errcod = ", lr_retorno.errcod
     display "lr_retorno.msgtxt = ", lr_retorno.msgtxt
 end if                

 call figrc011_fim_parse()

 return lr_retorno.lclltt,
        lr_retorno.lcllgt,
        lr_retorno.errcod,
        lr_retorno.msgtxt

 end function

#---------------------------------#
 function ctn55c00_monta_request()
#---------------------------------#

 define l_xml    char(2000),
        l_tmpmax smallint

 whenever error continue
 select grlinf
   into l_tmpmax
   from datkgeral
  where grlchv = 'PSOTMPMAXDAF'
 whenever error stop

 let l_xml = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                 "<REQUEST> ",
                     "<SERVICO>", mr_dados.servicename clipped, "</SERVICO>",
                     "<DADOS>",
                     #    "<CHASSI>",mr_dados.vclchsfnl clipped, "</CHASSI>",
                          "<CHASSI><INICIAL/><FINAL/></CHASSI>",
                         "<PLACA>", mr_dados.vcllicnum clipped, "</PLACA>",
                         "<TEMPOMAX>", l_tmpmax using "<<<<<<&" , "</TEMPOMAX>",
                     "</DADOS>",
                 "</REQUEST>"

 return l_xml

 end function

#-----------------------------------------#
 function ctn55c00_verifica_retorno(param)
#-----------------------------------------#

 define param record
              service    char(25),
              response char(2000)
 end record

 define l_doc_handle integer

 define lr_retorno record
     statusdaf char(50),
     lclltt    char(50),
     lcllgt    char(50),
     errcod    char(50),
     msgtxt    char(50)
 end record

 define lr_coordenadas record
     lclltt like datmlcl.lclltt,
     lcllgt like datmlcl.lcllgt
 end record

 initialize lr_retorno.*, l_doc_handle to null

 call figrc011_inicio_parse()

 let l_doc_handle = figrc011_parse(param.response)

 let lr_retorno.statusdaf = figrc011_xpath(l_doc_handle, "/RESPONSE/DAF/VALIDO")
 let lr_retorno.lcllgt    = figrc011_xpath(l_doc_handle, "/RESPONSE/COORDENADAS/COORDENADAX") #alterado
 let lr_retorno.lclltt    = figrc011_xpath(l_doc_handle, "/RESPONSE/COORDENADAS/COORDENADAY") #alterado
 let lr_retorno.errcod    = figrc011_xpath(l_doc_handle, "/RESPONSE/COORDENADAS/ERRO/CODIGO")
 let lr_retorno.msgtxt    = figrc011_xpath(l_doc_handle, "/RESPONSE/COORDENADAS/ERRO/MENSAGEM")

 let lr_retorno.lclltt = ctn55c00_corrige_coor(lr_retorno.lclltt)
 let lr_retorno.lcllgt = ctn55c00_corrige_coor(lr_retorno.lcllgt)

 call figrc011_fim_parse()

 let lr_coordenadas.lclltt = lr_retorno.lclltt
 let lr_coordenadas.lcllgt = lr_retorno.lcllgt

 return lr_coordenadas.lclltt,
        lr_coordenadas.lcllgt,
        lr_retorno.errcod,
        lr_retorno.msgtxt

 end function

#--------------------------------------------#
 function ctn55c00_valida_endereco_daf(param)
#--------------------------------------------#

 define param record
     succod    like abbmveic.succod,
     aplnumdig like abbmveic.aplnumdig,
     itmnumdig like abbmveic.itmnumdig,
     dctnumseq like abbmveic.dctnumseq,
     vcllicnum like abbmveic.vcllicnum,
     vclchsfnl like abbmveic.vclchsfnl
 end record

 define lr_retorno record
     status_ret smallint,
     lclltt     like datmlcl.lclltt,
     lcllgt     like datmlcl.lcllgt,
     ufdcod     like datmlcl.ufdcod,
     cidnom     like datmlcl.cidnom,
     lgdtip     like datmlcl.lgdtip,
     lgdnom     like datmlcl.lgdnom,
     brrnom     like datmlcl.brrnom,
     numero     integer,
     erro       integer,
     mensagem   char(50)
 end record

 define lr_erro record
     cod integer,
     msg char(50)
 end record
 
 define lr_aux record
     vclcoddig  like abbmveic.vclcoddig,
     vclchsinc	like abbmveic.vclchsinc
 end record

 define w_ret             smallint
 define w_orrdat          like adbmbaixa.orrdat
 define w_qtd_dispo_ativo integer

 define l_status     smallint,
        l_resultado  smallint,
        l_mensagem   char(30),
        l_doc_handle integer,
        l_dafidx     smallint,
        l_disp       smallint

 initialize l_status to null

 initialize lr_retorno.*, lr_erro.*, lr_aux.*,
            w_ret, w_orrdat, w_qtd_dispo_ativo to null         

 #if  (param.vcllicnum is null or param.vcllicnum = " ") and
 #    (param.vclchsfnl is null or param.vclchsfnl = " ") then
                  
     #if  g_documento.semdocto = "N" then
     #    case g_documento.ciaempcod
     #       when 35
     #          # VERIFICAR call figrc011_inicio_parse()
     #          # VERIFICAR call cts42g00_doc_handle(g_documento.succod,
     #          # VERIFICAR                          g_documento.ramcod,
     #          # VERIFICAR                          g_documento.aplnumdig,
     #          # VERIFICAR                          g_documento.itmnumdig,
     #          # VERIFICAR                          g_documento.edsnumref)
     #          # VERIFICAR      returning l_resultado, l_mensagem, l_doc_handle
     #          # VERIFICAR call cts40g02_extraiDoXML(l_doc_handle,'VEICULO_CHASSI_PLACA')
     #          # VERIFICAR               returning param.vclcoddig,
     #          # VERIFICAR                         param.vclchsfnl,
     #          # VERIFICAR                         param.vcllicnum
     #          # VERIFICAR call figrc011_fim_parse()
     #
     #       when 84
     #          #VERIFICAR  call cty22g00_rec_dados_itau(g_documento.itaciacod,
	#       #VERIFICAR                               g_documento.ramcod   ,
	#       #VERIFICAR                               g_documento.aplnumdig,
	#       #VERIFICAR                               g_documento.edsnumref,
	#       #VERIFICAR                               g_documento.itmnumdig)
     #          #VERIFICAR             returning lr_retorno.erro,
	#       #VERIFICAR                       lr_retorno.mensagem
     #          #VERIFICAR 
	#       #VERIFICAR let param.vclchsfnl = g_doc_itau[1].autchsnum
     #          #VERIFICAR let param.vcllicnum = g_doc_itau[1].autplcnum
     #
     #       otherwise
               if  (param.succod    is not null and param.succod    <> " ") and
                   (param.aplnumdig is not null and param.aplnumdig <> " ") and
                   (param.itmnumdig is not null and param.itmnumdig <> " ") and
                   (param.dctnumseq is not null and param.dctnumseq <> " ") then
                    whenever error continue
                     select vclcoddig, vcllicnum, vclchsinc, vclchsfnl
                       into lr_aux.vclcoddig, param.vcllicnum, lr_aux.vclchsinc, param.vclchsfnl
                       from abbmveic
                      where abbmveic.succod     = param.succod
                        and abbmveic.aplnumdig  = param.aplnumdig
                        and abbmveic.itmnumdig  = param.itmnumdig
                        and abbmveic.dctnumseq  = param.dctnumseq
                    whenever error stop
                    if  sqlca.sqlcode <> 0 then
                        #display "NAO ENCONTROU A APOLICE"
                        # RETORNA NULO
                    end if
               end if
         #end case
      #end if
 #end if

 if  param.vclchsfnl is null then
     let param.vclchsfnl = "        "
 end if

 whenever error continue
 select grlinf
   into l_dafidx
   from datkgeral
  where grlchv = 'PSOIDXDAFPSO'
 whenever error stop

 if  l_dafidx then
     
     if  g_issk.funmat = 4236 then
         display "INDEXACAO DAF LIGADO"
     end if     

     #case g_documento.ciaempcod
     #   when 1
     #        let l_disp = 3646
     #   when 35
     #        let l_disp = 4367
     #   when 84
     #        let l_disp = 7994
     #end case
     
     #display "DISPOSITIVO: ", l_disp
     
     if  g_documento.ciaempcod = 1 then
         # VERIFICA SE O VEICULO POSSUI DAF INSTALADO.
         #call fadic005(param.vclchsfnl, param.vcllicnum, 3646)
         #     returning l_status

         if  g_issk.funmat = 4236 then
             display "EMPRESA PORTO SEGURO"
         end if 

         call fadic005_existe_dispo(lr_aux.vclchsinc, 
                                    param.vclchsfnl,	
                                    param.vcllicnum,
                                    lr_aux.vclcoddig,
                                    3646)
              returning l_status,              
                        w_orrdat,         
                        w_qtd_dispo_ativo
                        
         if  g_issk.funmat = 4236 then
             display "l_status          = ", l_status         
             display "w_orrdat          = ", w_orrdat         
             display "w_qtd_dispo_ativo = ", w_qtd_dispo_ativo
         end if                
     else
         let l_status = false
         if  g_issk.funmat = 4236 then
             display "ATENDIMENTO NAO PERTENCE A PORTO SEGURO"
         end if 
     end if
 else
     let l_status = false
     
     if  g_issk.funmat = 4236 then
         display "INDEXACAO DAF LIGADO DESLIGADO"
     end if  
 end if


 ## VERIFICA SE O VEICULO POSSUI DAF INSTALADO.
 #call fadic005(param.vclchsfnl, param.vcllicnum, 3646)
 #     returning l_status

 if  l_status then

     call ctn55c00_busca_coordenada(param.vcllicnum, param.vclchsfnl)
          returning lr_retorno.lclltt,
                    lr_retorno.lcllgt,
                    lr_erro.cod,
                    lr_erro.msg
     call figrc011_inicio_parse()

     if  lr_erro.cod = 0 then

         call ctx25g01_endereco_comp(lr_retorno.lcllgt, lr_retorno.lclltt,"O")
              returning lr_retorno.status_ret,
                        lr_retorno.ufdcod,
                        lr_retorno.cidnom,
                        lr_retorno.lgdtip,
                        lr_retorno.lgdnom,
                        lr_retorno.brrnom,
                        lr_retorno.numero

     else
         if  g_issk.funmat = 4236 then               
             display "NAO POSSUI SINAL DAF VALIDO"
         end if                                      
     end if                                      

     call figrc011_fim_parse()
 else
     if  g_issk.funmat = 4236 then
         display "NOA POSSUI DAF INSTALADO - VISTORIA"
     end if 
 end if

 if  lr_retorno.status_ret is null or
     lr_retorno.status_ret = " " then
     let lr_retorno.status_ret = 1
 end if

 return lr_retorno.status_ret,
        lr_retorno.lclltt,
        lr_retorno.lcllgt,
        lr_retorno.ufdcod,
        lr_retorno.cidnom,
        lr_retorno.lgdtip,
        lr_retorno.lgdnom,
        lr_retorno.brrnom,
        lr_retorno.numero

 end function

#----------------------------------------------#
 function ctn55c00_compara_end(param)
#----------------------------------------------#

 define param record
     lgdnom1 like datmlcl.lgdnom,
     lgdnom2 like datmlcl.lgdnom
 end record

 define lr_fonetica   record
        prifoncod1     char(50),
        segfoncod1     char(50),
        terfoncod1     char(50),
        prifoncod2     char(50),
        segfoncod2     char(50),
        terfoncod2     char(50)
 end record

 define l_status smallint

 if  param.lgdnom1 is null then
     return false
 end if

 if  param.lgdnom2 is null then
     return false
 end if

 call ctx25g05_gera_codfon(param.lgdnom1)
      returning l_status,
                lr_fonetica.prifoncod1,
                lr_fonetica.segfoncod1,
                lr_fonetica.terfoncod1

 call ctx25g05_gera_codfon(param.lgdnom2)
      returning l_status,
                lr_fonetica.prifoncod2,
                lr_fonetica.segfoncod2,
                lr_fonetica.terfoncod2

 if  lr_fonetica.prifoncod1 = lr_fonetica.prifoncod2 or
     lr_fonetica.segfoncod1 = lr_fonetica.segfoncod2 or
     lr_fonetica.terfoncod1 = lr_fonetica.terfoncod2 then
     return true
 end if

 return false

end function

#----------------------------------------------#
 function ctn55c00_verifica_srv_org(l_c24astcod)
#----------------------------------------------#

 define l_status    smallint,
        l_c24astcod like datkassunto.c24astcod

 select 1
   into l_status
   from datkassunto
  where prgcod in (2,27,8,1)
    and c24astcod = l_c24astcod

 if  sqlca.sqlcode = 0 then

     return true
 end if

 return false

end function

#-------------------------------------#
 function ctn55c00_corrige_coor(param)
#-------------------------------------#
                      
 define param    char(50),
        l_length smallint,
        l_ind    smallint
                      
 let l_length = length(param)
                      
 for l_ind = 1 to l_length
                      
     if  param[l_ind] = "," then
         let param[l_ind] = "."
     end if           
                      
 end for              
 
 return param         
                      
 end function  