#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX25G02                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: PSI 198434 - ROTERIZACAO E INTEGRACAO DE MAPAS.            #
#                  CALCULA DIST.(KM) ENTRE DOIS PONTOS (LAT/LON) - ROTERIZADO.#
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 22/06/2006                                                 #
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
function ctx25g02(lr_parametro)
#-----------------------------#

  define lr_parametro   record
         lclltt_1       like datkmpalgdsgm.lclltt,
         lcllgt_1       like datkmpalgdsgm.lcllgt,
         lclltt_2       like datkmpalgdsgm.lclltt,
         lcllgt_2       like datkmpalgdsgm.lcllgt,
         tipo_rota      char(07),
         gera_percurso  smallint
  end record

  define l_xml_request  char(1000),
         l_xml_response char(32000),
         l_online       smallint,
         l_doc_handle   integer,
         l_status       smallint,
         l_qtd_rotas    smallint,
         l_msg          char(200),
         l_rota_final   char(32000),
         l_dist_total   decimal(8,3),
         l_temp_total   decimal(6,1),
         l_txtfilagis   char(20)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_xml_request   = null
  let l_xml_response  = null
  let l_online        = null
  let l_doc_handle    = null
  let l_status        = null
  let l_qtd_rotas     = null
  let l_msg           = null
  let l_rota_final    = null
  let l_dist_total    = null
  let l_temp_total    = null
  let l_txtfilagis    = null

  if lr_parametro.lclltt_1 is null or
     lr_parametro.lcllgt_1 is null or
     lr_parametro.lclltt_2 is null or
     lr_parametro.lcllgt_2 is null or
     lr_parametro.lclltt_1 = 0 or
     lr_parametro.lcllgt_1 = 0 or
     lr_parametro.lclltt_2 = 0 or
     lr_parametro.lcllgt_2 = 0 then
     return l_dist_total, l_temp_total, l_rota_final
  end if
 
  # --> GERA O XML DE REQUEST P/SELECIONAR O VEICULO
  let l_xml_request = ctx25g02_xml_request(lr_parametro.lclltt_1,
                                           lr_parametro.lcllgt_1,
                                           lr_parametro.lclltt_2,
                                           lr_parametro.lcllgt_2,
                                           lr_parametro.tipo_rota)

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

     let l_msg = l_msg clipped, " Erro: ", l_status using "<<<<<<<<&"
     error "Erro ao chamar a funcao figrc006_enviar_pseudo_mq()" sleep 2
     error l_msg sleep 2

     call ctx25g05_email_erro(l_xml_request,
                              l_xml_response,
                              "ERRO NO MQ - CTX25G02",
                              l_msg)
  else
     call figrc011_fim_parse()
     call figrc011_inicio_parse()
     let l_doc_handle = figrc011_parse(l_xml_response)

     # -> VERIFICA A MENSAGEM DE ERRO
     let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERRO")

     if (l_msg is not null and l_msg <> " ") then
     	
     	   # ERROS NAO TRATADOS DESATIVA MAPA
     	   if l_msg not like "%(Internal failure in preparing destinations)%" and
            l_msg not like "%(No route destinations set or destinations invalid)%" and 
            l_msg not like "%Insufficient number of valid locations%" and 
            l_msg not like "%No solution found%" then

            # -> DESATIVA A ROTERIZACAO
            call ctx25g05_desativa_rota()
         end if
         
         # -> ENVIO EMAIL PARA QUALQUER ERRO
         call ctx25g05_email_erro(l_xml_request,
                                  l_xml_response,
                                  "ERRO NO AMBIENTE MAPA - CTX25G02",
                                  l_msg)
         
     end if

     # --> BUSCA A QUANTIDADE DE ENDERECOS RETORNADA NO XML DE RESPONSE
     let l_qtd_rotas = figrc011_xpath(l_doc_handle,
                                      "count(/RESPONSE/VEICULOS/VEICULO/ROTA/PASSO)")

     # --> EXTRAI OS DADOS NECESSARIOS DO XML DE RESPONSE
     call ctx25g02_texto_rota(l_qtd_rotas,
                              l_doc_handle,
                              lr_parametro.gera_percurso)

          returning l_dist_total,
                    l_temp_total,
                    l_rota_final

     call figrc011_fim_parse()

  end if

  return l_dist_total,
         l_temp_total,
         l_rota_final

end function

#-----------------------------------------#
function ctx25g02_xml_request(lr_parametro)
#-----------------------------------------#

  # -> FUNCAO PARA GERAR O XML DE ENVIO PARA A FUNCAO DE PESQUISA

  define lr_parametro record
         lclltt_1     like datkmpalgdsgm.lclltt,
         lcllgt_1     like datkmpalgdsgm.lcllgt,
         lclltt_2     like datkmpalgdsgm.lclltt,
         lcllgt_2     like datkmpalgdsgm.lcllgt,
         tipo_rota    char(07) # -> RAPIDA OU CURTA
  end record

  define l_xml_request char(1000)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_xml_request =  null
  let l_xml_request = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
                      '<REQUEST>',
                         '<SERVICO>SelecionarVeiculo</SERVICO>',
                         '<AppID>PS_CT24H_CTG2</AppID>',
                         '<CHAMADO>',
                            '<ENDERECO>',
                               '<DESCRICAO>PONTO DE CHEGADA</DESCRICAO>',
                               '<COORDENADAS>',
                                  '<TIPO>WGS84</TIPO>',
                                  '<X>',
                                  lr_parametro.lcllgt_2,
                                  '</X>',
                                  '<Y>',
                                  lr_parametro.lclltt_2,
                                  '</Y>',
                               '</COORDENADAS>',
                            '</ENDERECO>',
                            '<VEICULOS>',
                               '<VEICULO>',
                                  '<ID>0</ID>',
                                  '<COORDENADAS>',
                                     '<TIPO>WGS84</TIPO>',
                                     '<X>',
                                     lr_parametro.lcllgt_1,
                                     '</X>',
                                     '<Y>',
                                     lr_parametro.lclltt_1,
                                     '</Y>',
                                  '</COORDENADAS>',
                               '</VEICULO>',
                            '</VEICULOS>',
                            '<TIPOROTA>',
                            lr_parametro.tipo_rota clipped,
                            '</TIPOROTA>',
                         '</CHAMADO>',
                      '</REQUEST>'

  return l_xml_request

end function

#----------------------------------------#
function ctx25g02_texto_rota(lr_parametro)
#----------------------------------------#

  define lr_parametro  record
         qtd_rotas     smallint,
         doc_handle    integer,
         gera_percurso smallint
  end record

  define l_ind             smallint,
         l_numero_rota     smallint,
         l_aux_char        char(100),
         l_texto           char(500),
         l_rota_final      char(32000),
         l_texto_dinamico  char(10),
         l_texto_distancia char(15),
         l_dist_total      decimal(8,3),
         l_temp_total      decimal(6,1),
         l_dist_m          integer,
         l_dist_km         decimal(8,3) # DISTANCIA EM KM

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_ind             = null
  let l_numero_rota     = null
  let l_aux_char        = null
  let l_texto           = null
  let l_rota_final      = null
  let l_dist_total      = null
  let l_temp_total      = null
  let l_dist_km         = null
  let l_dist_m          = null
  let l_texto_dinamico  = null
  let l_texto_distancia = null

  let lr_parametro.qtd_rotas = (lr_parametro.qtd_rotas - 1)

  # -> DISTANCIA TOTAL
  let l_aux_char   = "/RESPONSE/VEICULOS/VEICULO[1]/DISTANCIATOTAL"
  let l_dist_total = ctx25g02_virgula_ponto(figrc011_xpath(lr_parametro.doc_handle, l_aux_char))

  # -> TEMPO TOTAL
  let l_aux_char   = "/RESPONSE/VEICULOS/VEICULO[1]/TEMPOTOTAL"
  let l_temp_total = ctx25g02_virgula_ponto(figrc011_xpath(lr_parametro.doc_handle, l_aux_char))

  if lr_parametro.gera_percurso = true then
     # --> MONTA A STRING COM AS ROTAS ENCONTRADAS
     for l_ind = 2 to lr_parametro.qtd_rotas

        # -> TEXTO
        let l_texto    = null
        let l_aux_char = "/RESPONSE/VEICULOS/VEICULO/ROTA/PASSO[", l_ind using "<<<<&", "]/TEXTO"
        let l_texto    = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

        # -> DISTANCIA
        let l_dist_km  = null
        let l_aux_char = "/RESPONSE/VEICULOS/VEICULO/ROTA/PASSO[", l_ind using "<<<<&", "]/DISTANCIA"
        let l_dist_km  = ctx25g02_virgula_ponto(figrc011_xpath(lr_parametro.doc_handle, l_aux_char))

        # -> TRANSFORMA DE KM PARA METROS
        if l_dist_km > 1 then
           let l_texto_distancia = l_dist_km using "<<<<&.<<", "km."
        else
           let l_dist_m          = (l_dist_km * 1000)
           let l_texto_distancia = l_dist_m using "<<<<<<<<&", "m."
        end if

        # -> MONTA A ROTA FINAL
        if l_texto[1,14] = "Siga em frente" then
           let l_texto_dinamico = "por"
        else
           let l_texto_dinamico = "e percorra"
        end if

        let l_numero_rota = (l_ind - 1)
        let l_rota_final  = l_rota_final      clipped,
                            l_numero_rota     using "<<<<&", ") ",
                            l_texto           clipped, " ",
                            l_texto_dinamico  clipped, " ",
                            l_texto_distancia clipped, ";"
     end for
  else
     let l_rota_final = null
  end if

  return l_dist_total,
         l_temp_total,
         l_rota_final

end function

#--------------------------------------#
function ctx25g02_virgula_ponto(l_valor)
#--------------------------------------#

  define l_valor char(10),
         l_i     smallint,
         l_valnew char(10)

#display "* ctx25g02 - l_valor = ", l_valor

# let l_i = null
# let l_valnew = ""
# for l_i = 1 to length(l_valor)

#    if l_valor[l_i] <> "." then
#       let l_valnew = l_valnew clipped, l_valor[l_i]
#    end if

# end for

#display "(1) l_valnew = ", l_valnew

  let l_i = null
  for l_i = 1 to length(l_valor)

     if l_valor[l_i] = "," then
        let l_valor[l_i] = "."
     end if

  end for

#display "(2) l_valor = ", l_valor

  return l_valor

end function
