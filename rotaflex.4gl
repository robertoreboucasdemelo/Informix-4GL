database porto
main

  # -> REALIZAR OS TESTES NECESSARIOS PARA
  # -> VERIFICAR SE O AMBIENTE DE ROTERIZACAO ESTA OK

  define l_xml_request   char(1000),
         l_comando       char(2000),
         l_dathorini     datetime year to second,
         l_msg           char(10000),
         l_arq		 char(36),
         l_year		 datetime year to year,
         l_month	 datetime month to month,
         l_day           datetime day to day
         

  let l_dathorini = current
  let l_year = current
  let l_month = current
  let l_day = current
  
  let l_comando = "echo '", l_dathorini
  let l_arq = "/logs/rotaflex/rotaflex_", l_year, l_month, l_day, ".log"
  
  
  ### TESTA IdentificarEndereco
  let l_xml_request =
           '<?xml version="1.0" encoding="ISO-8859-1"?>',
           '<REQUEST>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<SERVICO>IdentificarEndereco</SERVICO>',
           '<LISTA><ENDERECO>',
           '<UF>SP</UF>',
           '<CIDADE>SAO PAULO</CIDADE>',
           '<LOGRADOURO>RIO BRANCO</LOGRADOURO>',
           '<NUMERO>1489</NUMERO>',
           '</ENDERECO>',
           '</LISTA>',
           '</REQUEST>'
  call rotaflex_enviamq(l_xml_request)
       returning l_msg
       
  let l_comando = l_comando clipped, ";", l_msg clipped
  

  ### TESTA IdentificarPosicao
  let l_xml_request =
           '<?xml version="1.0" encoding="ISO-8859-1"?>',
           '<REQUEST>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<SERVICO>IdentificarPosicao</SERVICO>',
           '<POSICAO>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-46.64626503</X>',
           '<Y>-23.53129089</Y>',
           '</COORDENADAS>',
           '</POSICAO>',
           '</REQUEST>'
  call rotaflex_enviamq(l_xml_request)
       returning l_msg
  let l_comando = l_comando  clipped,";", l_msg clipped
  
  ### TESTA SelecionarVeiculo
  let l_xml_request =
           '<?xml version="1.0" encoding="ISO-8859-1" ?>',
           '<REQUEST>',
           '<SERVICO>SelecionarVeiculo</SERVICO>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<CHAMADO>',
           '<ENDERECO>',
           '<DESCRICAO>TESTE</DESCRICAO>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-46.596557</X>',
           '<Y>-23.520375</Y>',
           '</COORDENADAS>',
           '</ENDERECO>',
           '<VEICULOS>',
           '<VEICULO>',
           '<ID>0</ID>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-48.646130</X>',
           '<Y>-23.531433</Y>',
           '</COORDENADAS>',
           '</VEICULO>',
           '<VEICULO>',
           '<ID>1</ID>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-52.646130</X>',
           '<Y>-20.531433</Y>',
           '</COORDENADAS>',
           '</VEICULO>',
           '<VEICULO>',
           '<ID>3</ID>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-45.646130</X>',
           '<Y>-23.531433</Y>',
           '</COORDENADAS>',
           '</VEICULO>',
           '</VEICULOS>',
           '<TIPOROTA>CURTA</TIPOROTA>',
           '</CHAMADO>',
           '</REQUEST>'
  call rotaflex_enviamq(l_xml_request)
       returning l_msg
  let l_comando = l_comando  clipped,";", l_msg clipped
  
  ### TESTA OrdenarCoordenada
  let l_xml_request =
           '<?xml version="1.0" encoding="UTF-8" ?>',
           '<REQUEST>',
           '<SERVICO>OrdenarCoordenada</SERVICO>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<LISTA>',
           '<ENDERECO>',
           '<UF>SP</UF>',
           '<CIDADE>SAO PAULO</CIDADE>',
           '<TIPO>R</TIPO>',
           '<LOGRADOURO>CAMBURIU</LOGRADOURO>',
           '<NUMERO></NUMERO>',
           '<BAIRRO>VILA IPOJUCA</BAIRRO>',
           '<CEP></CEP>',
           '<CODIGO></CODIGO>',
           '<FONETICA1>J{-SAE!!!!!!!!!</FONETICA1>',
           '<FONETICA2>J{-SAE!!!!!!!!!</FONETICA2>',
           '<FONETICA3>J{-SAE!!!!!!!!!</FONETICA3>',
           '</ENDERECO>',
           '</LISTA>',
           '<POSICAO>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-46.596557</X>',
           '<Y>-23.520375</Y>',
           '</COORDENADAS>',
           '</POSICAO>',
           '</REQUEST>'
  call rotaflex_enviamq(l_xml_request)
       returning l_msg
  
  
  let l_comando = l_comando  clipped,";", l_msg clipped, "' >> ", l_arq clipped
  run l_comando
  
  display "Resultado: ", l_comando clipped
  
end main


function rotaflex_enviamq(l_xml_request)
  define l_online        smallint,
         l_status        integer,
         l_msg           char(1000),
         l_xml_response  char(10000),
         l_doc_handle    integer,
         l_xml_request   char(1000),
         l_dathorini     datetime year to fraction,
         l_dathorfim     datetime year to fraction,
         l_tempo         interval second (3) to fraction (3),
         l_retmsg        char(10000),
         l_txtfilagis    char(20)
         
  let l_status       = null
  let l_msg          = null
  let l_doc_handle   = null
  let l_retmsg       = null
  let l_online       = online()

  let l_xml_response = null
  let l_txtfilagis   = null

  call ctx25g05_fila_mq()
       returning l_txtfilagis

  let l_dathorini = current
       
  call figrc006_enviar_pseudo_mq(l_txtfilagis,
                                 l_xml_request,
                                 l_online)
       returning l_status,
                 l_msg,
                 l_xml_response

  let l_dathorfim = current

  if l_status <> 0 then
     display " erro retornado do figrc006_enviar_pseudo_mq ", l_txtfilagis
     display " l_status: ", l_status
     display " l_msg: ", l_msg clipped
     display " l_xml_response: ", l_xml_response clipped
     let l_retmsg = -1
  else
     call figrc011_fim_parse()
     call figrc011_inicio_parse()
     let l_doc_handle = figrc011_parse(l_xml_response)

     # -> VERIFICA A MENSAGEM DE ERRO
     let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERRO")

     if (l_msg is not null and l_msg <> " ") then
         display "erro retornado do servico"
         display "l_msg: ", l_msg clipped
         let l_retmsg = -1
     else
         # -> VERIFICA A MENSAGEM DE ERRO
         let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERROR")
         if l_msg is not null and l_msg <> " " then
            display "erro retornado do servico ", l_txtfilagis
            display "l_msg: ", l_msg clipped
            let l_retmsg = -1
         else
            let l_tempo = l_dathorfim - l_dathorini
            let l_retmsg = l_tempo
         end if
     end if
  end if
  call figrc011_fim_parse()

  return l_retmsg
  
end function
