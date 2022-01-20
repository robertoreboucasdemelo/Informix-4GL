#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX25G06                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: PSI 198434 - ROTERIZACAO E INTEGRACAO DE MAPAS.            #
#                  RETORNA A MELHOR ROTA.                                     #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 21/07/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

#-----------------------------#
function ctx25g06(lr_parametro)
#-----------------------------#

  define lr_parametro record
         lclltt_srv   like datmfrtpos.lclltt, # LATITUDE DO SERVICO
         lcllgt_srv   like datmfrtpos.lcllgt, # LONGITUDE DO SERVICO
         xml_veiculos char(32000)
  end record

  define l_xml_request   char(32000),
         l_tipo_rota     char(10),
         l_online        smallint,
         l_status        smallint,
         l_id            smallint,
         l_msg           char(200),
         l_aux_char      char(100),
         l_dist_total    decimal(8,3),
         l_temp_total    decimal(6,1),
         l_doc_handle    integer,
         l_xml_response  char(32000),
         l_txtfilagis    char(20)

  let l_xml_request   = null
  let l_online        = null
  let l_status        = null
  let l_msg           = null
  let l_xml_response  = null
  let l_doc_handle    = null
  let l_aux_char      = null
  let l_dist_total    = null
  let l_id            = null
  let l_temp_total    = null
  let l_txtfilagis    = null

  # -> BUSCA O TIPO DE ROTA: RAPIDA OU CURTA
  let l_tipo_rota = ctx25g05_tipo_rota()

  let l_xml_request = '<?xml version="1.0" encoding="ISO-8859-1" ?> ',
                      '<REQUEST>',
                         '<SERVICO>SelecionarVeiculo</SERVICO>',
                         '<AppID>PS_CT24H_CTG2</AppID>',
                         '<CHAMADO>',
                            '<ENDERECO>',
                               '<DESCRICAO>PONTO DE CHEGADA</DESCRICAO>',
                               '<COORDENADAS>',
                                  '<TIPO>WGS84</TIPO>',
                                  '<X>',
                                  lr_parametro.lcllgt_srv,
                                  '</X>',
                                  '<Y>',
                                  lr_parametro.lclltt_srv,
                                  '</Y>',
                               '</COORDENADAS>',
                            '</ENDERECO>',
                            lr_parametro.xml_veiculos clipped,
                            '<TIPOROTA>',
                               l_tipo_rota clipped,
                            '</TIPOROTA>',
                         '</CHAMADO>',
                      '</REQUEST>'


  # --> CHAMA A FUNCAO P/RETORNAR O XML DE RESPONSE A PARTIR DO XML DE REQUEST
  let l_online = online()
  
  call ctx25g05_fila_mq()
       returning l_txtfilagis

  call figrc006_enviar_pseudo_mq(l_txtfilagis,
                                 l_xml_request,
                                 l_online)

        returning l_status,
                  l_msg,
                  l_xml_response

  
  if l_status <> 0 then

     # -> DESATIVA A ROTERIZACAO
     call ctx25g05_desativa_rota()

     call errorlog ("Erro ao chamar a funcao figrc006_enviar_pseudo_mq()")
     let l_msg = l_msg clipped, " Erro: ", l_status using "<<<<<<<<&"
     call errorlog (l_msg)

     call ctx25g05_email_erro(l_xml_request,
                              l_xml_response,
                              "ERRO NO MQ - BATCH",
                              l_msg)
  else

     if l_xml_response is null or
        l_xml_response = " " then
        call errorlog("XML_response nulo ou branco-ctx25g06")
     end if

     let l_doc_handle = figrc011_parse(l_xml_response)

     # -> VERIFICA A MENSAGEM DE ERRO
     let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERRO")

     if (l_msg is not null and l_msg <> " ") then
     	
     	   # ERROS NAO TRATADOS DESATIVA MAPA
         if l_msg not like "%(Internal failure in preparing destinations)%" and
            l_msg not like "%(No route destinations set or destinations invalid)%" and 
            l_msg not like "%Insufficient number of valid locations%"  and 
            l_msg not like "%No solution found%"  then
            	
            # -> DESATIVA A ROTERIZACAO
            call ctx25g05_desativa_rota()
         end if

         # -> ENVIO EMAIL PARA QUALQUER ERRO
         call ctx25g05_email_erro(l_xml_request,
                                  l_xml_response,
                                  "ERRO NO AMBIENTE MAPA - CTX25G06",
                                  l_msg)
         
     end if
     
     # -> ID DO VEICULO
     let l_aux_char = "/RESPONSE/VEICULOS/VEICULO/ID"
     let l_id       = ctx25g02_virgula_ponto(figrc011_xpath(l_doc_handle, l_aux_char))

     # -> DISTANCIA TOTAL
     let l_aux_char   = "/RESPONSE/VEICULOS/VEICULO/DISTANCIATOTAL"
     let l_dist_total = ctx25g02_virgula_ponto(figrc011_xpath(l_doc_handle, l_aux_char))

     # -> TEMPO TOTAL
     let l_aux_char   = "/RESPONSE/VEICULOS/VEICULO/TEMPOTOTAL"
     let l_temp_total = ctx25g02_virgula_ponto(figrc011_xpath(l_doc_handle, l_aux_char))
     let l_temp_total = ((l_temp_total * 2) + 3)

     if l_temp_total > 60 then
        let l_temp_total = 60
     end if

  end if
  

  return l_id,
         l_dist_total,
         l_temp_total

end function
