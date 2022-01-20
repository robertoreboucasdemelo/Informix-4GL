#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX25G01                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: PSI 198434 - ROTERIZACAO E INTEGRACAO DE MAPAS.            #
#                  CONSULTA LOGRAD. DOS DADOS RECEB. DOS MDT'S - ROTERIZADO.  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 21/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 13/07/07   Ligia Mattge     210838  Retorno de parametros desta funcao      #
# 25/08/09   Sergio Burini    240591  Integração Porto Socorro DAF            #
# 29/12/2009 Fabio Costa  PSI 198404  Tratar fim de linha windows Ctrl+M      #
# 21/10/2010 Alberto Rodrigues        Correcao de ^M                          #
# 28/03/2012 Sergio Burini  PSI-2010-01968/PB                                 #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------#
function ctx25g01(lr_parametro)
#------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         proc         char(1) ## (B)atch, (O)nline
  end record

  define lr_dados  record
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom,
         brrnom       like datkmpabrr.brrnom,
         lgdnom       like datkmpalgd.lgdnom,
         lgdtip       like datkmpalgd.lgdtip,
         numero       integer,
         msgtxt1      char(40),
         msgtxt2      char(40),
         msgtxt3      char(40),
         msgtxt4      char(40),
         xml_response char(2000),
         xml_request  char(500),
         msg          char(80),
         status_ret   smallint,
         doc_handle   integer,
         online       smallint,
         ret          char(1)
  end record

  define l_msg        char(200)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_dados.*  to  null
  let l_msg = null
  
  call ctx25g01_endereco(lr_parametro.lcllgt,
                         lr_parametro.lclltt,
                         lr_parametro.proc)
       returning lr_dados.status_ret,
                 lr_dados.ufdcod,
                 lr_dados.cidnom,
                 lr_dados.lgdtip,
                 lr_dados.lgdnom,
                 lr_dados.brrnom,
                 lr_dados.numero
  
  if lr_dados.status_ret = 0 then

     # -> MONTA A MENSAGEM PARA SER EXIBIDA
     let lr_dados.msgtxt1  = "*** LOCAL DA TRANSMISSAO ***"
     let lr_dados.msgtxt2  = "UF-Cidade: ",
                             lr_dados.ufdcod clipped, "-",
                             lr_dados.cidnom
     let lr_dados.msgtxt3  = "Bairro   : ",
                             lr_dados.brrnom

     if lr_dados.lgdnom is not null then
        let lr_dados.msgtxt4  = lr_dados.lgdtip clipped, " ",
                                lr_dados.lgdnom clipped, ", ",
                                lr_dados.numero using "<<<<<<<<&"

        let lr_dados.msgtxt4[40] = '.'
     else
        let lr_dados.msgtxt4 = null
     end if

     let lr_dados.msgtxt2[40] = '.'

     # -> EXIBE A MENSAGEM
     #let lr_dados.ret = cts08g01("A",
     #                            "",
     #                            lr_dados.msgtxt1,
     #                            lr_dados.msgtxt2,
     #                            lr_dados.msgtxt3,
     #                            lr_dados.msgtxt4)  let lr_dados.msgtxt3[40] = '.'
  end if
  
  return lr_dados.msgtxt1, lr_dados.msgtxt2, lr_dados.msgtxt3, lr_dados.msgtxt4

end function

#-----------------------------------------#
function ctx25g01_xml_request(lr_parametro)
#-----------------------------------------#

  # -> FUNCAO PARA GERAR O XML DE ENVIO PARA A FUNCAO DE PESQUISA

  define lr_parametro record
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt         
  end record

  define l_xml_request char(500)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_xml_request = null
  let l_xml_request = '<?xml version="1.0" encoding="ISO-8859-1"?>',
                      '<REQUEST>',
                        '<AppID>PS_CT24H_CTG2</AppID>',
                        #'<AppID>PORTO_MAPTP</AppID>',
                        # '<AppID>PORTO_MAPTP</AppID>',       
                         '<SERVICO>IdentificarPosicao</SERVICO>',
                         '<POSICAO>',
                            '<COORDENADAS>',
                            '<TIPO>WGS84</TIPO>',
                            '<X>',
                            lr_parametro.lclltt,                                                     
                            '</X>',
                            '<Y>',                            
                            lr_parametro.lcllgt,    
                            '</Y>',
                            '</COORDENADAS>',
                         '</POSICAO>',
                      '</REQUEST>'

  return l_xml_request

end function


#---------------------------------------#
function ctx25g01_endereco(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         proc         char(1) ## (B)atch, (O)nline
  end record

  define lr_dados  record
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom,
         brrnom       like datkmpabrr.brrnom,
         lgdnom       like datkmpalgd.lgdnom,
         lgdtip       like datkmpalgd.lgdtip,
         numero       integer,
         status_ret   smallint
  end record  

  call ctx25g01_endereco_comp(lr_parametro.*) 
       returning lr_dados.status_ret,
                 lr_dados.ufdcod,    
                 lr_dados.cidnom,    
                 lr_dados.lgdtip,    
                 lr_dados.lgdnom,    
                 lr_dados.brrnom,    
                 lr_dados.numero     
       
  return lr_dados.status_ret,
         lr_dados.ufdcod,    
         lr_dados.cidnom,    
         lr_dados.lgdtip,    
         lr_dados.lgdnom,    
         lr_dados.brrnom,    
         lr_dados.numero       
              
end function

#---------------------------------------------#
 function ctx25g01_endereco_comp(lr_parametro)
#---------------------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         proc         char(1) ## (B)atch, (O)nline
  end record

  define lr_dados  record
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom,
         brrnom       like datkmpabrr.brrnom,
         lgdnom       like datkmpalgd.lgdnom,
         lgdtip       like datkmpalgd.lgdtip,
         numero       integer,
         msgtxt1      char(40),
         msgtxt2      char(40),
         msgtxt3      char(40),
         msgtxt4      char(40),
         xml_response char(2000),
         xml_request  char(500),
         msg          char(80),
         status_ret   smallint,
         doc_handle   integer,
         online       smallint,
         ret          char(1)
  end record

  define l_msg        char(200)
  define l_txtfilagis char(20)

  initialize lr_dados.* to null
  let l_msg = null
  let l_txtfilagis = null
  
  # Verifica se as coordenadas estao preenchidas
  if lr_parametro.lclltt = 0 or lr_parametro.lcllgt = 0 then
     let lr_dados.status_ret = 1
     let lr_dados.lgdnom = 'COORDENADAS ZERADAS'
     return lr_dados.status_ret,
            lr_dados.ufdcod,    
            lr_dados.cidnom,    
            lr_dados.lgdtip,    
            lr_dados.lgdnom,    
            lr_dados.brrnom,    
            lr_dados.numero     
  end if

  # --> GERA O XML DE REQUEST P/IDENTIFICAR A POSICAO
  let lr_dados.xml_request = ctx25g01_xml_request(lr_parametro.lclltt,
                                                  lr_parametro.lcllgt)
  # --> CHAMA A FUNCAO P/RETORNAR O XML DE RESPONSE A PARTIR DO XML DE REQUEST
  let lr_dados.online = online()

  call ctx25g05_fila_mq()
       returning l_txtfilagis
  call figrc006_enviar_pseudo_mq(l_txtfilagis,
                                 lr_dados.xml_request,
                                 lr_dados.online)

        returning lr_dados.status_ret,
                  lr_dados.msg,
                  lr_dados.xml_response                 

  if lr_dados.status_ret <> 0 then

     # -> DESATIVA A ROTERIZACAO
     call ctx25g05_desativa_rota()

     let l_msg = " Erro: ", lr_dados.status_ret using "<<<<<<<<&",
                            lr_dados.msg clipped

     if lr_parametro.proc = "O" then
        error "Erro ao chamar a funcao figrc006_enviar_pseudo_mq()" sleep 2
        error l_msg sleep 2
     else
        display "Erro ao chamar a funcao figrc006_enviar_pseudo_mq()"
        display l_msg
     end if

     call ctx25g05_email_erro(lr_dados.xml_request,
                              lr_dados.xml_response,
                              "ERRO NO MQ - CTX25G01",
                              l_msg)
  else

     let lr_dados.doc_handle = figrc011_parse(lr_dados.xml_response)

     # -> VERIFICA A MENSAGEM DE ERRO
     let l_msg = figrc011_xpath(lr_dados.doc_handle, "/RESPONSE/ERRO")

     if l_msg is not null and l_msg <> " " then

        # -> DESATIVA A ROTERIZACAO
        call ctx25g05_desativa_rota()

        call ctx25g05_email_erro(lr_dados.xml_request,
                                 lr_dados.xml_response,
                                 "ERRO NO AMBIENTE MAPA - CTX25G01",
                                 l_msg)
     end if

     # --> EXTRAI OS DADOS NECESSARIOS DO XML DE RESPONSE

     # -> UF
     let lr_dados.ufdcod = figrc011_xpath(lr_dados.doc_handle,
                                          "/RESPONSE/ENDERECO/UF")

     # -> CIDADE
     let lr_dados.cidnom = figrc011_xpath(lr_dados.doc_handle,
                                          "/RESPONSE/ENDERECO/CIDADE")

     # -> TIPO
     let lr_dados.lgdtip = figrc011_xpath(lr_dados.doc_handle,
                                          "/RESPONSE/ENDERECO/TIPOEND")

     # -> LOGRADOURO
     let lr_dados.lgdnom = figrc011_xpath(lr_dados.doc_handle,
                                          "/RESPONSE/ENDERECO/LOGRADOURO")                                         
     
     # -> BAIRRO
     let lr_dados.brrnom = figrc011_xpath(lr_dados.doc_handle,
                                          "/RESPONSE/ENDERECO/BAIRRO")

     # -> BAIRRO
     let lr_dados.numero = figrc011_xpath(lr_dados.doc_handle,
                                          "/RESPONSE/ENDERECO/NUMERO")


     # -> MONTA A MENSAGEM PARA SER EXIBIDA
     let lr_dados.msgtxt1  = "*** LOCAL DA TRANSMISSAO ***"
     let lr_dados.msgtxt2  = "UF-Cidade: ",
                             lr_dados.ufdcod clipped, "-",
                             lr_dados.cidnom
     let lr_dados.msgtxt3  = "Bairro   : ",
                             lr_dados.brrnom

     if lr_dados.lgdnom is not null then
        let lr_dados.msgtxt4  = lr_dados.lgdtip clipped, " ",
                                lr_dados.lgdnom clipped, ", ",
                                lr_dados.numero using "<<<<<<<<&"

        let lr_dados.msgtxt4[40] = '.'
     else
        let lr_dados.msgtxt4 = null
     end if

     let lr_dados.msgtxt2[40] = '.'
     let lr_dados.msgtxt3[40] = '.'

     # -> EXIBE A MENSAGEM
     #let lr_dados.ret = cts08g01("A",
     #                            "",
     #                            lr_dados.msgtxt1,
     #                            lr_dados.msgtxt2,
     #                            lr_dados.msgtxt3,
     #                            lr_dados.msgtxt4)
  end if
  
  return lr_dados.status_ret,
         lr_dados.ufdcod,    
         lr_dados.cidnom,    
         lr_dados.lgdtip,    
         lr_dados.lgdnom,    
         lr_dados.brrnom,    
         lr_dados.numero     

  #return lr_dados.msgtxt1, lr_dados.msgtxt2, lr_dados.msgtxt3, lr_dados.msgtxt4

end function

##-----------------------------------------#
#function ctx25g01_xml_request(lr_parametro)
##-----------------------------------------#
#
#  # -> FUNCAO PARA GERAR O XML DE ENVIO PARA A FUNCAO DE PESQUISA
#
#  define lr_parametro record
#         lclltt       like datmlcl.lclltt,
#         lcllgt       like datmlcl.lcllgt
#  end record
#
#  define l_xml_request char(500)
#
##@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
#
#  let l_xml_request = null
#  let l_xml_request = '<?xml version="1.0" encoding="UTF-8" ?>',
#                      '<REQUEST>',
#                         '<SERVICO>IdentificarPosicao</SERVICO>',
#                         '<POSICAO>',
#                            '<COORDENADAS>',
#                            '<TIPO>WGS84</TIPO>',
#                            '<X>',
#                            lr_parametro.lcllgt,
#                            '</X>',
#                            '<Y>',
#                            lr_parametro.lclltt,
#                            '</Y>',
#                            '</COORDENADAS>',
#                         '</POSICAO>',
#                      '</REQUEST>'
#
#  return l_xml_request
#
# end function