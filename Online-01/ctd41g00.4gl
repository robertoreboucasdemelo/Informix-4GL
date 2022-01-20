#*****************************************************************************#
# Modulo .........: ctd41g00.4gl                                              #
# Analista .......: Fabio Lamartine                                           #
# Desenvolvimento.: Rodolfo Massini - 10/2013                                 #
# Objetivo........: Chamada MQ das operacoes da regulacao de agenda AW        #
#                                                                             #
#-----------------------------------------------------------------------------# 
# 10/10/2013 - Rodolfo Massini                                                #
#-----------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Adaptacao regulacao via AW     #
#-----------------------------------------------------------------------------#
# 25/06/2015  Norton,Biztalk SPR-2015-13411 Otimizacao para Envio do de Email #
#                                           pelo Sistema e-mail_reL           #
#-----------------------------------------------------------------------------#
# 03/08/2015  Norton,Biztalk SPR-2015-15533 Otimizacao para Envio do de Email #
#                            para a PortoFaz                                  #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

# Confirmar se a chave de reserva ainda esta ativa
#--------------------------------------------------------------------------
function ctd41g00_checar_reserva(l_rsrchv) 
#--------------------------------------------------------------------------

 # DEFINICAO E INICIALIZACAO DE VARIAVEIS LOCAIS

 define l_rsrchv        char(25)   # Chave de reserva a ser verificada (param) 
       ,l_coderro       smallint   # Codigo de erro do retorno MQ
       ,l_msg_erro      char(30)   # Mensagem de erro do retorno MQ
       ,l_xml_envio     char(5000) # XML enviado para o MQ
       ,l_xml_retorno   char(5000) # XML retornado pelo MQ
       ,l_xml_limpo     char(5000) # XML retornado pelo MQ sem namespaces
       ,l_qtd           smallint   # Quantidade de registros do retorno MQ
       ,l_docHandle     integer    # Variavel para realizar parse
       ,l_path          char(200)  # Caminho generico do XML
       ,l_reserva_ativa smallint   # Flag de reserva ativa
       ,l_texto_parse   char(05)   # Texto retornado do servico (true ou false)
       ,l_path_count    char(150)  # Caminho da TAG a ser contadada
       ,l_nro_registros smallint   # Numero de registros encontrados
       ,l_caminho       char(150)  # Caminho para realizar parse

 initialize l_coderro 
           ,l_msg_erro
           ,l_xml_envio
           ,l_xml_retorno
           ,l_xml_limpo
           ,l_qtd
           ,l_docHandle
           ,l_path
           ,l_reserva_ativa
           ,l_path_count
           ,l_nro_registros
 to null

 #display 'ctd41g00_checar_reserva acionado'
 
 # MONTAGEM DO XML DE ENVIO

 let l_xml_envio = '<?xml version="1.0" encoding="UTF-8"?>'
                  ,'<ns0:checarReservaIn xmlns:tns="http://www.portoseguro.c'
                  ,'om.br/ebo/AgendaAtendimentoSocorrista/V1_0" xmlns:ns0="h'
                  ,'ttp://www.portoseguro.com.br/atendimento'
                  ,'Socorrista/business/AgendaAtendimentoSoc'
                  ,'orristaEBM/V1_0/">'
                        
                        # TAG numeroReserva
                        ,'<ns0:numeroReserva>'
                        ,l_rsrchv clipped
                        ,'</ns0:numeroReserva>'
                   
                   ,'</ns0:checarReservaIn>'

 # CHAMADA DO SERVICO MQ "CHECAR RESERVA"

 call figrc006_enviar_pseudo_mq('PSOCHECRESSOA01R', 
                                 l_xml_envio clipped, 
                                 online())
           returning l_coderro
                    ,l_msg_erro
                    ,l_xml_retorno

 #display 'Retorno da checagem: '
 #display 'l_coderro    : ', l_coderro 
 #display 'l_msg_erro   : ', l_msg_erro clipped
 #display 'l_xml_retorno: ', l_xml_retorno clipped
 
 # VERIFICAR E TRATAR O RETORNO DA CHAMADA MQ

 if l_coderro = 0 then

    call cts02m08_retira_namespce(l_xml_retorno)
         returning l_xml_limpo 
   
    let l_docHandle = figrc011_parse(l_xml_limpo clipped)

    let l_path = "/checarReservaOut/checarReserva" clipped

    let l_path_count = "count(",l_path clipped,")"
    let l_nro_registros = figrc011_xpath(l_docHandle, l_path_count)

    if l_nro_registros = 1 then

       # RESERVA ATIVA
       let l_caminho = l_path clipped, "/checarRegulacaoResult"
       let l_texto_parse = figrc011_xpath(l_docHandle, l_caminho)
       
       if l_texto_parse = 'false' then
          let l_reserva_ativa = false
          
          # INICIO - DISPLAY LOG
          error "Reserva consta inativa"
          sleep 1
          #display 'ctd41g00 - Reserva consta inativa'
          # FIM - DISPLAY LOG
                      
       end if
       
       if l_texto_parse = 'true' then
          let l_reserva_ativa = true
          
          # INICIO - DISPLAY LOG
          error "Reserva da cota, consta ativa."
          sleep 1
          #display 'ctd41g00 - Reserva consta ativa'
          # FIM - DISPLAY LOG
          
       end if
    else 

       let l_reserva_ativa = true
       
       # INICIO - DISPLAY LOG
       error "Presumindo que a cota esta ativa."
       sleep 1
       #display 'ctd41g00 - Erro ao tentar checar reserva, assumiremos como ativa'
       # FIM - DISPLAY LOG

    end if

 else

    let l_reserva_ativa = false

 end if

 return l_reserva_ativa

end function

# Confirmar a utilização de chave previamente reservada 
#--------------------------------------------------------------------------
function ctd41g00_baixar_agenda(l_rsrchv, l_atdsrvano, l_atdsrvnum)
#--------------------------------------------------------------------------
 
# DEFINICAO E INICIALIZACAO DE VARIAVEIS LOCAIS
  
 define l_coderro       smallint                   # Cod. de erro do retorno MQ
       ,l_msg_erro      char(30)                   # Msg. de erro do retorno MQ
       ,l_xml_envio     char(5000)                 # XML enviado para o MQ
       ,l_msgid         char(24)                   # ID da Mensagem
       ,l_correlid      char(24)                   # Correletion ID
       ,l_rsrchv        char(25)                   # Chave reserva (param)
       ,l_atdsrvano     like datmservico.atdsrvano # Ano do servico (param)
       ,l_atdsrvnum     like datmservico.atdsrvnum # Numero servico (param)
       ,l_msgEmail      varchar(255)               # Solicitacao Renato Bastos
 initialize l_coderro 
           ,l_msg_erro
           ,l_xml_envio
           ,l_msgid
           ,l_correlid
           ,l_msgEmail
 to null

 #display 'ctd41g00_baixar_agenda acionado'
 
 # MONTAGEM DO XML DE ENVIO

 let l_xml_envio = '<?xml version="1.0" encoding="UTF-8"?>'
                  ,'<ns0:baixarAgendaIn xmlns:tns="http://www.portoseguro.com.'
                  ,'br/ebo/AgendaAtendimentoSocorrista/V1_0" xmlns:ns0="http'
                  ,'://www.portoseguro.com.br/atendimentoSocorrista/busines'
                  ,'s/AgendaAtendimentoSocorristaEBM/V1_0/">'

                      # TAG parChave
                      ,'<ns0:parChave>'
                      ,l_rsrchv clipped
                      ,'</ns0:parChave>'

                      # TAG parAnoServico
                      ,'<ns0:parAnoServico>'
                      ,l_atdsrvano using "<<"
                      ,'</ns0:parAnoServico>'

                      # TAG parCodigoServico
                      ,'<ns0:parCodigoServico>'
                      ,l_atdsrvnum clipped using "<<<<<<<<<<"
                      ,'</ns0:parCodigoServico>'

                  ,'</ns0:baixarAgendaIn>'


 # INICIO - DISPLAY LOG
 #display "XML ENVIADO (BAIXAR AGENDA):"
 #display l_xml_envio clipped
 # FIM - DISPLAY LOG
 
 # CHAMADA DO SERVICO MQ "BAIXAR AGENDA"

 error "Baixando cota da agenda..."
 
 call figrc006_enviar_datagrama_mq_rq('PSOBAIAGENSOA01D',
                                     l_xml_envio clipped,
                                     "",
                                     online())
     returning l_coderro,
               l_msg_erro,
               l_msgid,
               l_correlid  
 sleep 1
 error ""              
               
 #display 'Retorno da baixa: '
 #display 'l_coderro : ', l_coderro 
 #display 'l_msg_erro: ', l_msg_erro clipped
 #display 'l_msgid   : ', l_msgid    clipped
 #display 'l_correlid: ', l_correlid clipped

 # INICIO - DISPLAY LOG
 if l_coderro = 0 then
    error "Cota da agenda baixada com sucesso!"
    sleep 1
    error ""
    #display 'ctd41g00 - Sucesso na chamada MQ baixar agenda'
 else
    let l_msgEmail ="Erro: ",l_coderro," ao baixar cota da agenda para o servico, "
                    ,l_atdsrvnum,"-",l_atdsrvano,"."
    ## SPR-2015-15533 - Inicio
    if g_documento.ciaempcod <> 43 then                   
       call ctd41g00_enviar_email(l_msgEmail)
    else
    	 call ctd41g00_enviar_email_portofaz(l_atdsrvnum,
    	                                     l_atdsrvano, 
    	                                     "",
    	                                     l_coderro)   
    end if
    ## SPR-2015-15533 - Fim               
    error "Cota da agenda nao baixada."
    sleep 1
    error ""
    #display "ctd41g00 - Erro ",l_coderro," na chamada MQ baixar agenda."
 end if
 # FIM - DISPLAY LOG

 return l_coderro, l_msg_erro
 
end function

# Desistir da utilização de chave previamente reservada liberando para outro agendamtento 
#--------------------------------------------------------------------------
function ctd41g00_liberar_agenda(l_atdsrvano, l_atdsrvnum, l_atddatprg, l_atdhorprg)
#--------------------------------------------------------------------------
 
# DEFINICAO E INICIALIZACAO DE VARIAVEIS LOCAIS

 define l_coderro        smallint                   # Cod. de erro do retorno MQ
       ,l_msg_erro       char(30)                   # Msg. de erro do retorno MQ
       ,l_xml_envio      char(5000)                 # XML enviado para o MQ
       ,l_msgid          char(24)                   # ID da Mensagem
       ,l_correlid       char(24)                   # Correletion ID
       ,l_data_hora_char char(19)                   # Data e Hora (texto)
       ,l_data_char      char(10)                   # Data - Multiuso (texto)
       ,l_hora_char      char(05)                   # Hora - Multiuso (texto)
       ,l_atdsrvano      like datmservico.atdsrvano # Ano do servico (param)
       ,l_atdsrvnum      like datmservico.atdsrvnum # Numero servico (param)
       ,l_atddatprg      like datmservico.atddatprg # Data programa (param)
       ,l_atdhorprg      like datmservico.atdhorprg # Hora programa (param)
       ,l_msgEmail       varchar(255)               # Solicitacao Renato Bastos

 initialize l_coderro 
           ,l_msg_erro
           ,l_xml_envio
           ,l_msgid
           ,l_correlid
           ,l_data_hora_char
           ,l_data_char
           ,l_hora_char
           ,l_msgEmail
 to null

 # FORMATACAO DO CAMPO DATA E HORA DO SERVICO

 #display 'ctd41g00_liberar_agenda acionado'
 
 let l_data_char = l_atddatprg
 let l_hora_char = l_atdhorprg

 let l_data_hora_char = l_data_char[7,10] clipped
                       ,"-" clipped
                       ,l_data_char[4,5] clipped
                       ,"-" clipped
                       ,l_data_char[1,2] clipped
                       ,"T" clipped
                       ,l_hora_char clipped
                       , ":00"   # transformar hour to minute para o formato oracle

 # MONTAGEM DO XML DE ENVIO

 let l_xml_envio = '<?xml version="1.0" encoding="UTF-8"?>'
                  ,'<ns0:liberarAgendaIn xmlns:tns="http://www.portoseguro.co'
                  ,'m.br/ebo/AgendaAtendimentoSocorrista/V1_0" xmlns:ns0="htt'
                  ,'p://www.portoseguro.com.br/atendimentoSocorrista/business'
                  ,'/AgendaAtendimentoSocorristaEBM/V1_0/">'

                      # TAG parAnoServico
                      ,'<ns0:parAnoServico>'
                      ,l_atdsrvano
                      ,'</ns0:parAnoServico>'

                      # TAG parCodigoServico
                      ,'<ns0:parCodigoServico>'
                      ,l_atdsrvnum clipped
                      ,'</ns0:parCodigoServico>'

                      # TAG parDataHoraServico
                      ,'<ns0:parDataHoraServico>'
                      ,l_data_hora_char clipped
                      ,'</ns0:parDataHoraServico>'

                  ,'</ns0:liberarAgendaIn>'
                  
 # INICIO - DISPLAY LOG
 #display "XML ENVIADO (LIBERAR AGENDA):"
 #display l_xml_envio clipped
 # FIM - DISPLAY LOG

 # CHAMADA DO SERVICO MQ "BAIXAR AGENDA"
 
 error "Liberando cota da agenda..."
 
 call figrc006_enviar_datagrama_mq_rq('PSOLIBAGENSOA01D', 
                                     l_xml_envio clipped, 
                                     "",
                                     online())
     returning l_coderro,
               l_msg_erro,
               l_msgid,
               l_correlid
  sleep 1
  error ""             
               
 #display 'Retorno da liberacao: '
 #display 'l_coderro : ', l_coderro 
 #display 'l_msg_erro: ', l_msg_erro clipped
 #display 'l_msgid   : ', l_msgid    clipped
 #display 'l_correlid: ', l_correlid clipped
 
 # INICIO - DISPLAY LOG
 if l_coderro = 0 then
    error "Cota liberada com sucesso."
    sleep 2
    error ""
    #display "ctd41g00 - Sucesso na chamada MQ liberar agenda."
 else
    error "Cota da agenda nao liberada."
    sleep 2
    error ""
    let l_msgEmail ="Erro: ",l_coderro," ao liberar cota da agenda para o servico, "
                    ,l_atdsrvnum,"-",l_atdsrvano,"."
    
    ##call ctd41g00_enviar_email(l_msgEmail)
    ## SPR-2015-15533 - Inicio
    if g_documento.ciaempcod <> 43 then                  
       call ctd41g00_enviar_email(l_msgEmail)
    else
    	 call ctd41g00_enviar_email_portofaz(l_atdsrvnum,
    	                                     l_atdsrvano,
    	                                     l_data_hora_char,
    	                                     l_coderro)   
    end if
    ## SPR-2015-15533 - Fim                
 end if
 # FIM - DISPLAY LOG

end function

#Envia email de erro com a integracao via MQ
#--------------------------------
function ctd41g00_enviar_email(l_msgEmail)
#--------------------------------
define l_msgEmail      varchar(255)
      ,l_retorno       smallint

let l_retorno = null
##--SPR-2015-13411
##let l_retorno = ctx22g00_mail_corpo("AGENDA_PSO","Erro Agenda Porto Socorro",l_msgEmail)

##--SPR-2015-13411
let l_retorno = ctx22g00_mail_corpo("CTD41G00","Erro Agenda Porto Socorro",l_msgEmail)

if l_retorno <> 0 then
   if l_retorno <> 99 then
      error "Nao enviou email de erro na Agenda PSO. Avise Informatica!"
      sleep 2
   else
      error "Nao foi encontrado email para Agenda PSO."
      sleep 2
   end if
end if
end function #Fim ctd41g00_enviar_email 

#-- SPR-2015-15533

#Envia email de erro com a integracao via MQ para a PORTOFAZ
#-----------------------------------------------
function ctd41g00_enviar_email_portofaz(lr_param)
#------------------------------------------------
 define lr_param          record
        atdsrvnum         like datmservico.atdsrvnum   # Numero Servico
       ,atdsrvano         like datmservico.atdsrvano   # Ano Servico
       ,data_hora_char    char(19)                     # Data e Hora (texto)
       ,coderro           smallint                     # Codigo do Erro
 end record
 
 define l_coderro       smallint,     # Codigo de erro do retorno MQ
        l_msg           char(32000),
        l_retorno       smallint,
        l_natureza      char(30),
        l_cgccpf        char(16),
        l_data_char     char(20), 
        l_cidnom        like datmlcl.cidnom,
        l_ufdcod        like datmlcl.ufdcod,
        l_atddatprg     like datmservico.atddatprg,
        l_atdhorprg     like datmservico.atdhorprg  
 
 let l_retorno   = null
 let l_natureza  = null
 let l_cgccpf    = null
 let l_data_char = null 
 let l_cidnom    = null
 let l_ufdcod    = null
 let l_atddatprg = null
 let l_atdhorprg = null
 
if g_documento.socntzdes is not null then
    let l_natureza = g_documento.socntzdes clipped
else
	  let l_natureza = g_documento.asitipabvdes	clipped  
 end if	
 
 if g_documento.cgcord > 0 then
    let l_cgccpf   = g_documento.cgccpfnum using "&&&&&&&&"
                    ,"/"
                    ,g_documento.cgcord    using "&&&&"      
                    ,"-"
                    ,g_documento.cgccpfdig using "&&"
 else
    let l_cgccpf   = g_documento.cgccpfnum using "&&&&&&&&&"
                    ,"-"
                    ,g_documento.cgccpfdig using "&&" clipped
 end if
 
 whenever error continue
    select  b.cidnom,b.ufdcod,a.atddatprg,a.atdhorprg   into
            l_cidnom,l_ufdcod, l_atddatprg,l_atdhorprg
     from datmservico a, datmlcl b        
    where a.atdsrvnum = lr_param.atdsrvnum                 
      and a.atdsrvano = lr_param.atdsrvano                 
      and a.atdsrvnum = b.atdsrvnum       
      and a.atdsrvano = b.atdsrvano       
      and b.c24endtip = 1                 
 whenever error stop  
 
 if lr_param.data_hora_char is null  or 
    lr_param.data_hora_char = ""  	then
    let l_data_char = l_atddatprg 
                     ," " 
                     ,l_atdhorprg clipped
 else
 	  let l_data_char =  lr_param.data_hora_char
 end if

 let l_msg  = 
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"',
  ' "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
  '<html xmlns="http://www.w3.org/1999/xhtml">',
  '<head>',
    '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />',
    '<title>Porto Seguro FAZ - Relat&oacute;rio de Servi&ccedil;o fechados',
      ' automaticamente pelo prestador',
    '</title>',
  '</head>',
  '<body bgcolor="#F6F6F6">',
  '<table width="650" border="0" align="center" cellpadding="10"',
     ' cellspacing="0">',
     '<tr>',
       '<td bgcolor="#FFFFFF"><a href="http://www.portosegurofaz.com.br/"',
         ' target="_blank"><img src="http://s1.portosegurofaz.com.br/skin/',
         'frontend/portoseguro/default/images/logo.png" width="219"',
         ' height="51" border="0" /></a>',
      '</td>',
     '</tr>',
     '<tr>',
       '<td bgcolor="#FFFFFF"><h1 style="font-family:Verdana;font-size:20px;',
         '">Problema Integra&ccedil;&atilde;o - Agenda Porto Socorro</h1>',
       '</td>',
     '</tr>',
     '<tr>',
        '<td bgcolor="#FFFFFF">',
          '<table width="100%" border="0" cellspacing="1"',
              ' cellpadding="10">',
            '<tr>',
              '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
                '#FFFFFF;font-family:Verdana;font-size:12px;">ERRO</span>',
                '</strong>',
              '</td>',
              '<td><span style="color:#333333;font-family:Verdana;font-size:',
                 '12px;">',lr_param.coderro,' - MQ FORA</span>',
              '</td>',
            '</tr>',
            '<tr>',
               '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
                 '#FFFFFF;font-family:Verdana;font-size:12px;">CPF</span>',
                 '</strong>',
               '</td>',
               '<td><span style="color:#333333;font-family:Verdana;',
                  'font-size:12px;">',l_cgccpf,'</span>',
               '</td>',
            '</tr>',
            '<tr>',
              '<td bgcolor="#00ADF5" align="right"><strong><span style="color:#',
                'FFFFFF;font-family:Verdana;font-size:12px;">CIDADE</span>',
                '</strong>',
              '</td>',
              '<td><span style="color:#333333;font-family:Verdana;font-size:12px;',
                 '">',l_cidnom,'</span>',
              '</td>',
            '</tr>',
            '<tr>',
              '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
              '#FFFFFF;font-family:Verdana;font-size:12px;">UF</span></strong>',
           '</td>',
        '<td><span style="color:#333333;font-family:Verdana;font-size:12px;">',
          l_ufdcod,'</span>',
        '</td>',
     '</tr>',
     '<tr>',
        '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
          '#FFFFFF;font-family:Verdana;font-size:12px;">HOR&Aacute;RIO AGENDADO',
          '</span></strong>',
        '</td>',
        '<td><span style="color:#333333;font-family:Verdana;font-size:12px;',
          '">',l_data_char,'</span>',
        '</td>',
     '</tr>',
     '<tr>',
        '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
          '#FFFFFF;font-family:Verdana;font-size:12px;">NATUREZA</span>',
          '</strong>',
        '</td>',
        '<td><span style="color:#333333;font-family:Verdana;font-size:',
           '12px;">',l_natureza,'</span>',
        '</td>',
     '</tr>',
     '<tr>',
        '<td width="29%" bgcolor="#00ADF5" align="right"><strong><span',
           ' style="color:#FFFFFF;font-family:Verdana;font-size:12px;',
           '">PROBLEMA</span></strong>',
        '</td>',
        '<td width="71%"><span style="color:#333333;font-family:Verdana',
           ';font-size:12px;">',g_documento.atddfttxt,'</span>',
        '</td>',
     '</tr>',
     '</table>',
    '</td>',
   '</tr>',
  '</table>',
'</body>',
'</html>'

 let l_retorno = ctx22g00_envia_email_html("PTS02M08",
                                           "Erro Agenda Porto Socorro",l_msg)

 if l_retorno <> 0 then
    if l_retorno <> 99 then
       error "Nao enviou email de erro na Agenda PSO Portofaz. Avise Informatica!"
       sleep 2
    else
       error "Nao foi encontrado email para Agenda PSO Portofaz."
       sleep 2
    end if
 end if

end function #Fim cts02m08_enviar_email_portofaz 


