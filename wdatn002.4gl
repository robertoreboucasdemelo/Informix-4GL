#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Ponto Socorro                                              #
# Modulo.........: wdatn002                                                   #
# Analista Resp..: Beatriz Araujo                                             #
# Descricao......: Listener de resposta do SAP para operacoes de pagamento    #
# ........................................................................... #
# Desenvolvimento: Robson Ruas                                                #
# Liberacao......: 07/02/2013                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#


globals '/homedsa/projetos/geral/globals/I4GLParams.4gl'

#------------------------------------------------------------------------------
function ExecuteService(l_servicename)
#------------------------------------------------------------------------------

  define l_servicename char(50),      # -- Service Name
         l_xml         char(32766),   # -- XML de Retorno
         l_docHandle   integer        # -- ID XML recuperado

  define lr_geral      record
         situacao      smallint,      # -- Situacao
         msgerro       char(250)      # -- Mensagem de erro
  end    record


  set isolation to dirty read
  set lock mode to wait 20

  initialize lr_geral.* to null

  let l_xml       = null
  let l_docHandle = null

  let l_docHandle = figrc011_parse_bigchar()

  let l_servicename = figrc011_xpath(l_docHandle,"/mensagem/servico")

  display " Executando servico: ", l_servicename
  display " l_docHandle: ", l_docHandle

  case l_servicename

     when 'retornoGeracaoOP'

        call I4GLService_parse_xml_retornoGeracaoOP(l_docHandle)
       returning lr_geral.situacao, lr_geral.msgerro

     when 'cancelarOP'

        call I4GLService_parse_xml_cancelarOP_SAP(l_docHandle)
       returning lr_geral.situacao, lr_geral.msgerro

     otherwise

        let lr_geral.situacao = 1
        let lr_geral.msgerro = 'Servico nao recebido ou invalido.'
        call I4GLService_parse_xml_sem_Service(l_docHandle)
        call figrc011_fim_parse()

  end case

  call I4GLService_retorno_xml_geral(lr_geral.situacao, lr_geral.msgerro)
       returning l_xml

  display " Retornando XML: ", l_xml clipped, " para a chamada do servico: ", l_servicename

  return l_xml

end function

#------------------------------------------------------------------------------
function I4GLService_retorno_xml_geral(lr_param)
#------------------------------------------------------------------------------
  define lr_param    record
         situacao    smallint,  # -- Situacao
         msgerro     char(250)  # -- Mensagem de erro
  end    record

  define l_xml       char(5000) # -- XML de Retorno
        ,l_docHandle integer    # -- ID XML Retorno

  let l_xml       = null
  let l_docHandle = null

  let l_docHandle = figrc011_novo_xml("retorno")

  call figrc011_atualiza_xml(l_docHandle,"/retorno/codigo",lr_param.situacao using "<<<<<&")

  call figrc011_atualiza_xml(l_docHandle,"/retorno/mensagem",lr_param.msgerro clipped)

  let l_xml = figrc011_retorna_xml_gerado(l_docHandle)

  call figrc011_fim_novo_xml(l_docHandle)

  return l_xml

end function

#------------------------------------------------------------------------------
function I4GLService_parse_xml_retornoGeracaoOP(l_docHandle)
#------------------------------------------------------------------------------
   define l_docHandle            integer

   define lr_dados               record
           orgporto        char(4)          ## origem porto
          ,codempresa      char(5)          ## codigo empresa
          ,pedidosap       decimal(10,0)    ## pedido SAP
          ,docReferencia   decimal(16,0)    ## nro docto ref legado
          ,datgeracao      date             ## data Geração
          ,docSAP          char(16)         ## nro da op gerada
          ,montante        integer          ## montante
          ,coderro         smallint         ## codigo do erro
          ,errdsc          char(200)        ## mensagem de erro
          ,msgerro         char(3000)
   end    record

   define l_ind                  smallint
         ,l_count                smallint
         ,l_situacao             smallint
         ,l_msgerro              char(3000)
         ,l_tag                  char(200)
         ,l_caminho              char(200)
         ,l_ocorrencia           char(200)
         ,l_docReferenciaTemp    char(16)
         ,l_desccancelamento     char(300)

   let l_ind               = null
   let l_count             = null
   let l_situacao          = null
   let l_msgerro           = null
   let l_tag               = null
   let l_caminho           = null
   let l_ocorrencia        = null
   let l_docReferenciaTemp = null
   let l_desccancelamento  = null

   initialize lr_dados.* to null

   display ""
   display "============================================================"
   display " Servico : I4GLService_parse_xml_retornoGeracaoOP "
   display " Funcao  : ctb00g17_retorno_op_emitida "

   call figrc011_debug_bigchar()

   let l_caminho = "count(/mensagem/Response/Retornos/Retorno)"
   let l_count = figrc011_xpath (l_docHandle, l_caminho clipped)
   let l_caminho = "/mensagem/Response/Retornos"


   display "Qtd Informacao ", l_count

   if l_count is null or l_count = 0 then
      let l_situacao = 1
      let l_msgerro  = "Nenhum registro encontrado no XML."
   else

    for l_ind = 1 to l_count

          let l_ocorrencia = l_caminho clipped, "/Retorno[",l_ind using "<<<<<<<&","]/"

          let l_tag = l_ocorrencia clipped, "origemPorto"
          let lr_dados.orgporto     = figrc011_xpath(l_docHandle, l_tag clipped)

          let l_tag = l_ocorrencia clipped, "codigoEmpresa"
          let lr_dados.codempresa   = figrc011_xpath(l_docHandle, l_tag clipped)

          let l_tag = l_ocorrencia clipped, "pedidoSAP"
          let lr_dados.pedidosap   = figrc011_xpath(l_docHandle, l_tag clipped)


          let l_tag = l_ocorrencia clipped, "codigoRetorno"
          let lr_dados.coderro      = figrc011_xpath(l_docHandle, l_tag clipped)

          let l_tag = l_ocorrencia clipped, "mensagemErro"
          let lr_dados.errdsc       = figrc011_xpath(l_docHandle, l_tag clipped)

          if lr_dados.msgerro is null or lr_dados.msgerro = ' ' then
             let lr_dados.msgerro = lr_dados.coderro using '<<<<<<<<',"-",lr_dados.errdsc clipped
          else
             let lr_dados.msgerro = lr_dados.msgerro clipped , "; ", lr_dados.coderro using '<<<<<<<<',"-",lr_dados.errdsc clipped
          end if

          let l_tag = l_ocorrencia clipped, "dataGeracao"
          let lr_dados.datgeracao = figrc011_xpath(l_docHandle, l_tag clipped)

          let l_tag = l_ocorrencia clipped, "numeroDocumentoOrdemPag"
          let lr_dados.docSAP    = figrc011_xpath(l_docHandle, l_tag clipped) #Numero de Documento SAP

          let l_tag = l_ocorrencia clipped, "numeroDocumento"
          let l_docReferenciaTemp = figrc011_xpath(l_docHandle, l_tag clipped) #Documento do Porto Socorro

          #Inicio - PSI-2014-30294/IN
          #Receber as OPs vindas do sistema de Pagamentos Manuais e retornar OK para o SAP
          if l_docReferenciaTemp[1] == 'M' then
            let l_situacao = 0
            let l_msgerro  = 'Documento referencia recebido'
            display "OP vinda do sistema de pagamentos manuais"

            let l_desccancelamento = "Codigo do erro: "       , lr_dados.coderro    clipped, " | ",
                                     "Descricao do erro: "    , lr_dados.msgerro    clipped, " | ",
                                     "Numero doc referencia: ", l_docReferenciaTemp clipped


            call wdatn002_mail(l_docReferenciaTemp, l_desccancelamento)
            return l_situacao, l_msgerro
          end if
          #Fim - PSI-2014-30294/IN 
          
          let lr_dados.docReferencia = l_docReferenciaTemp

          display ""
          display " Parametros apos parse : "
          display "lr_dados.orgporto     : " , lr_dados.orgporto
          display "lr_dados.codempresa   : " , lr_dados.codempresa
          display "lr_dados.pedidosap    : " , lr_dados.pedidosap
          display "lr_dados.docReferencia: " , lr_dados.docReferencia
          display "lr_dados.datgeracao   : " , lr_dados.datgeracao
          display "lr_dados.docSAP       : " , lr_dados.docSAP
          display "lr_dados.montante     : " , lr_dados.montante
          display "lr_dados.coderro      : " , lr_dados.coderro
          display "lr_dados.errdsc       : " , lr_dados.errdsc

    end for

          display "mensagem: ",lr_dados.msgerro clipped
          display ""

          whenever error continue
             call ctb00g17_retorno_op_emitida ( lr_dados.orgporto
                                               ,lr_dados.codempresa
                                               ,lr_dados.pedidosap
                                               ,lr_dados.docReferencia
                                               ,lr_dados.datgeracao
                                               ,lr_dados.docSAP
                                               ,lr_dados.montante
                                               ,lr_dados.coderro
                                               ,lr_dados.msgerro )
                  returning l_situacao
                          , l_msgerro
          whenever error stop

          if l_situacao is null or l_situacao = ' ' then
              let l_situacao = 1
          end if

          case l_situacao
               when    0  let l_situacao = 0 # Processamento OK
               when    1  let l_situacao = 0 # Mensagen de erro retornada pelo SAP
               when  100  let l_situacao = 1 # Erro de negocio (tags nulas, inconsistencias ...)
               otherwise  let l_situacao = 2 # Erro de INFRA (banco fora do ar,insert,delete ...)
          end  case

          display " Parametros de retorno da ctb00g17_retorno_op_emitida : "
          display " . l_situacao = ", l_situacao
          display " . l_msgerro  = ", l_msgerro clipped

   end if

   call figrc011_fim_parse()

   display ""
   display "============================================================"

   return l_situacao, l_msgerro

end function

#------------------------------------------------------------------------------
function I4GLService_parse_xml_cancelarOP_SAP(l_docHandle)
#------------------------------------------------------------------------------
   define l_docHandle     integer

   define lr_dados        record
           empcod           decimal(02,00) ## empresa
          ,docReferencia    decimal(16,00) ## doc referencia
          ,docSAP           char(16)       ## op people
          ,ppsopgcanmtvcod  smallint       ## codigo motivo
          ,atlmat           dec(06,00)     ## matricula resp. pelo cancelamento
          ,atlemp           dec(02,00)     ## empresa do resp. pelo cancelamento
          ,desccancelamento char(100)      ## descricao do cancelamento
          ,datcancelamento  date           ## data do cancelamento
          ,tipmatricula     char(10)       ## tipo matricula
          ,cpfcnpj          char(16)       ## CPF/CNPF
   end    record

   define l_situacao            smallint
         ,l_msgerro             char(250)
         ,l_caminho             char(200)
         ,l_tag                 char(200)
         ,l_docReferenciaTemp   char(16)
         ,l_desccancelamento    char(300)

   initialize lr_dados.* to null

   let l_situacao          = null
   let l_msgerro           = null
   let l_caminho           = null
   let l_tag               = null
   let l_docReferenciaTemp = null
   let l_desccancelamento  = null

   display ""
   display "============================================================"
   display " Servico : I4GLService_parse_xml_cancelarOP_SAP "
   display " Funcao  : ctb00g17_recebe_canc_op_sap "

   call figrc011_debug_bigchar()

   let l_caminho = "/mensagem/"

   let l_tag = l_caminho clipped, "codigoEmpresaSAP"
   let lr_dados.empcod          = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "codigoEmpresa"
   let lr_dados.atlemp          = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "numeroDocumentoReferenciaSistemaLegado"
   let l_docReferenciaTemp = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "motivoCancelamento"
   let lr_dados.ppsopgcanmtvcod = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "descricaoCancelamento"
   let lr_dados.desccancelamento = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "dataCancelamento"
   let lr_dados.datcancelamento = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "numeroDocumentoSistemaSAP"
   let lr_dados.docSAP       = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "tipoMatricula"
   let lr_dados.tipmatricula = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "matricula"
   let lr_dados.atlmat          = figrc011_xpath(l_docHandle, l_tag clipped)

   let l_tag = l_caminho clipped, "numeroCPFCNPJFavorecido"
   let lr_dados.cpfcnpj         = figrc011_xpath(l_docHandle, l_tag clipped)

   #Inicio - PSI-2014-30294/IN
   #Receber as OPs vindas do sistema de Pagamentos Manuais e retornar OK para o SAP
   if l_docReferenciaTemp[1] == 'M' then
      let l_situacao = 0
      let l_msgerro  = 'Documento referencia recebido'
      display "OP vinda do sistema de pagamentos manuais"

      let l_desccancelamento = "Descricao do cancelamento: ", lr_dados.desccancelamento clipped, " | ",
                               "Data do cancelamento: "     , lr_dados.datcancelamento  clipped, " | ",
                               "CPF/CNPJ Favorecido:  "     , lr_dados.cpfcnpj          clipped, " | ",
                               "Numero documento interno: " , l_docReferenciaTemp       clipped

      call wdatn002_mail(lr_dados.docSAP, l_desccancelamento)
      return l_situacao, l_msgerro
   end if
   #Fim - PSI-2014-30294/IN

   let lr_dados.docReferencia    = l_docReferenciaTemp




   display ""
   display " Parametros apos parse : "
   display "lr_dados.empcod           ",lr_dados.empcod
   display "lr_dados.docReferencia    ",lr_dados.docReferencia
   display "lr_dados.docSAP           ",lr_dados.docSAP
   display "lr_dados.ppsopgcanmtvcod  ",lr_dados.ppsopgcanmtvcod
   display "lr_dados.atlmat           ",lr_dados.atlmat
   display "lr_dados.atlemp           ",lr_dados.atlemp
   display "lr_dados.desccancelamento ",lr_dados.desccancelamento
   display "lr_dados.datcancelamento  ",lr_dados.datcancelamento
   display "lr_dados.tipmatricula     ",lr_dados.tipmatricula
   display "lr_dados.cpfcnpj          ",lr_dados.cpfcnpj
   display ""

   #begin work
   display " Comeco ctb00g17_recebe_canc_op_sap : "
   call ctb00g17_recebe_canc_op_sap (lr_dados.empcod
                                     ,lr_dados.docReferencia
                                     ,lr_dados.docSAP
                                     ,lr_dados.ppsopgcanmtvcod
                                     ,lr_dados.atlmat
                                     ,lr_dados.atlemp
                                     ,lr_dados.desccancelamento
                                     ,lr_dados.datcancelamento
                                     ,lr_dados.tipmatricula
                                     ,lr_dados.cpfcnpj)

        returning l_situacao
                , l_msgerro

   #if l_situacao = 0 then
   #   commit work
   #else
   #   rollback work
   #end if

   #case l_situacao
   #     when    0  let l_situacao = 0 # Processamento OK
   #     when  100  let l_situacao = 1 # Erro de negocio (tags nulas, inconsistencias ...)
   #     otherwise  let l_situacao = 2 # Erro de INFRA (banco fora do ar,insert,delete ...)
   #end case

   display " Parametros de retorno da ctb00g17_recebe_canc_op_sap : "
   display " . l_situacao = ", l_situacao
   display " . l_msgerro  = ", l_msgerro clipped

   call figrc011_fim_parse()

   display ""
   display "============================================================"

   return l_situacao, l_msgerro

end function



#------------------------------------------------------------------------------
function I4GLService_parse_xml_sem_Service(l_docHandle)
#------------------------------------------------------------------------------
   define l_docHandle     integer
   define l_xml           char(32766)   # -- XML de Retorno

   let l_xml = figrc011_retorna_xml_gerado(l_docHandle)

   display "l_xml: ",l_xml clipped

end function


#--------------------------------------------------------------------------------------------
function wdatn002_mail(l_docSap, l_desccancelamento)
#--------------------------------------------------------------------------------------------

  define lr_param record
         modulo    like igbmparam.relsgl
        ,assunto   char(300)
        ,texto     char(300)
  end record


  define l_ret               integer
        ,l_docSap            char(16)
        ,l_desccancelamento  char(300)

  let lr_param.modulo  = "pgtomanual"
  let lr_param.assunto = 'Resumo de emissao da OP: ', l_docSap clipped
  let lr_param.texto   = l_desccancelamento



  call ctx22g00_mail_corpo(lr_param.modulo, lr_param.assunto, lr_param.texto) returning l_ret

  if l_ret != 0 then
     if l_ret != 99 then
        display "Erro ao enviar email(pgtomanual) - ", l_ret
     else
        display "Nao ha email cadastrado para o modulo "
     end if
  end if

end function
