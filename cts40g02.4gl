#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G02                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 205.206 - AZUL SEGUROS                                     #
#                  RETORNA AS INFORMACOES DO XML DAS APOLICES DA AZUL.        #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 21/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 18/08/08   Carla Rampazzo             Acrescentar mais duas tag p/ cls. 037 #
#                                       ASSISTENCIA_RETORNO  e                #
#                                       ASSISTENCIA_DESCRICAO                 #
#-----------------------------------------------------------------------------#
database porto

#-----------------------------------------#
function cts40g02_extraiDoXML(lr_parametro)
#-----------------------------------------#

  define lr_parametro   record
         doc_handle     integer,  # -> DOC HANDLE DO XML
         retorno        char(30)  # -> TIPO DE RETORNO
  end record

  if lr_parametro.doc_handle is not null and
     lr_parametro.retorno    is not null then

     case upshift(lr_parametro.retorno)

        when "SUCURSAL"

        # RETORNA OS DADOS DA SUCURSAL
             # 1 -> CODIGO DA SUCURSAL
             # 2 -> NOME DA SUCURSAL

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SUCURSAL"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SUCURSALNOME")

        when "CORRETOR"

        # RETORNA OS DADOS DO CORRETOR
             # 1 -> SUSEP
             # 2 -> NOME
             # 3 -> DDD DO TELEFONE
             # 4 -> NUMERO DO TELEFONE
             # 5 -> DDD DO FAX
             # 6 -> NUMERO DO FAX
             # 7 -> E-MAIL

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/SUSEP"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/NOME"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/FONES/FONE/DDD"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/FONES/FONE/NUMERO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/FAX/DDD"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/FAX/NUMERO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/EMAIL")

        when "CORRETOR_ENDERECO"

        # RETORNA OS DADOS DO ENDERECO DO CORRETOR
             # 1 -> UF
             # 2 -> CIDADE
             # 3 -> TIPO
             # 4 -> LOGRADOURO
             # 5 -> NUMERO
             # 6 -> COMPLEMENTO
             # 7 -> BAIRRO
             # 8 -> CEP

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/UF"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/CIDADE"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/TIPO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/LOGRADOURO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/NUMERO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/COMPLEMENTO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/BAIRRO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/CORRETOR/ENDERECO/CEP")

        when "APOLICE_TIPO"

        # 1 -> RETORNA O TIPO DA APOLICE

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICES/TIPO")

        when "APOLICE_GERACAO"

        # RETORNA OS DADOS DA GERACAO DA APOLICE
             # 1 -> DATA dd/mm/yyyy
             # 2 -> HORA hh:mm:ss

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICES/GERACAO/DATA"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICES/GERACAO/HORA")

        when "APOLICE_EMISSAO"

        # RETORNA OS DATA DE EMISSAO DA APOLICE
             # -> DATA dd/mm/yyyy

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/EMISSAO")

        when "APOLICE_VIGENCIA"

        # RETORNA A VIGENCIA INICIAL E FINAL DA APOLICE
             # -> VIGENCIA INICIAL dd/mm/yyyy
             # -> VIGENCIA FINAL   dd/mm/yyyy

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VIGENCIA/INICIAL"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VIGENCIA/FINAL")

        when "APOLICE_SITUACAO"

        # RETORNA A SITUACAO DA APOLICE
             # 1 -> SITUACAO

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SITUACAO")

        when "SEGURADO"

        # RETORNA OS DADOS DO SEGURADO
             # 1 -> NOME
             # 2 -> CGC OU CPF
             # 3 -> TIPO DE PESSOA (F)FISICA (J)JURIDICA
             # 4 -> DDD DO TELEFONE
             # 5 -> NUMERO DO TELEFONE
             # 6 -> E-MAIL

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/NOME"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/CGCCPF"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/TIPOPESSOA"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/FONES/FONE/DDD"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/FONES/FONE/NUMERO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/EMAIL")

        when "SEGURADO_ENDERECO"

        # RETORNA OS DADOS DO ENDERECO DO SEGURADO
             # 1 -> UF
             # 2 -> CIDADE
             # 3 -> TIPO
             # 4 -> LOGRADOURO
             # 5 -> NUMERO
             # 6 -> COMPLEMENTO
             # 7 -> BAIRRO
             # 8 -> CEP

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/UF"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/CIDADE"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/TIPO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/LOGRADOURO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/NUMERO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/COMPLEMENTO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/BAIRRO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/ENDERECO/CEP")

        when "VEICULO"

        # RETORNA OS DADOS DO VEICULO
             # 1  -> CODIGO
             # 2  -> MARCA
             # 3  -> TIPO
             # 4  -> MODELO
             # 5  -> CHASSI(COMPLETO)
             # 6  -> PLACA
             # 7  -> ANO DE FABRICACAO yyyy
             # 8  -> ANO DO MODELO     yyyy
             # 9  -> CATEGORIA TARIFARIA
             # 10 -> AUTOMATICO (SIM OU NAO)

           return figrc011_xpath(lr_parametro.doc_handle,
                             "/APOLICE/VEICULO/CODIGO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/MARCA"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/TIPO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/MODELO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/CHASSI"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/PLACA"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/ANO/FABRICACAO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/ANO/MODELO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/CATEGORIATARIFARIA"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/AUTOMATICO")

        when "VEICULO_CHASSI_PLACA"

        # RETORNA O CHASSI DO VEICULO E A PLACA
             # 1 -> CHASSI
             # 2 -> PLACA

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/CHASSI"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/PLACA")

        when "CLASSE_LOCALIZACAO"

        # RETORNA O CODIGO E DESCRICAO DA CLASSE DE LOCALIZACAO
             # 1 -> CODIGO
             # 2 -> DESCRICAO

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/CLASSELOCALIZACAO/CODIGO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/VEICULO/CLASSELOCALIZACAO/DESCRICAO")

        when "IS"

        # RETORNA OS VALORES DA IS(IMPORTANCIA SEGURADA)
             # 1 -> CASCO
             # 2 -> BLINDAGEM
             # 3 -> DM (DANOS MATERIAIS)
             # 4 -> DP (DANOS PESSOAIS)
             # 5 -> MORTE
             # 6 -> INVALIDEZ
             # 7 -> DMH (DANOS MATERIAIS HOSPITALARES)
             # 8 -> FRANQUIA

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/CASCO"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/BLINDAGEM"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/DM"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/DP"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/MORTE"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/INVALIDEZ"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/DMH"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/IS/FRANQUIA")

        when "OBSERVACOES"

        # RETORNA OS DADOS DAS OBSERVACOES DA APOLICE
             # 1 -> OBSERVACAO 1
             # 2 -> OBSERVACAO 2
             # 3 -> OBSERVACAO 3

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/OBSERVACOES/OBSERVACAO[1]"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/OBSERVACOES/OBSERVACAO[2]"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/OBSERVACOES/OBSERVACAO[3]")

        when "ASSISTENCIA_GUINCHO"

        # RETORNA OS DADOS DA ASSISTENCIA DE GUINCHO
             # 1 -> KM LIMITE
             # 2 -> QUANTIDADE

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/ASSISTENCIA/GUINCHO/KMLIMITE"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/ASSISTENCIA/GUINCHO/QUANTIDADE")

        when "ASSISTENCIA_RESERVA"

        # RETORNA OS DADOS DA ASSISTENCIA DE RESERVA
             # 1 -> DIARIAS

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/ASSISTENCIA/RESERVA/DIARIAS")

        when "ASSISTENCIA_TAXI"

        # RETORNA OS DADOS DA ASSISTENCIA DE TAXI
             # 1 -> VALOR LIMITE

          return figrc011_xpath(lr_parametro.doc_handle,
                             "/APOLICE/ASSISTENCIA/TAXI/VALORLIMITE")

        when "ASSISTENCIA_PASSAGENS"

        # RETORNA OS DADOS DA ASSISTENCIA DE PASSAGENS
             # 1 -> VALOR LIMITE

           return figrc011_xpath(lr_parametro.doc_handle,
                          "/APOLICE/ASSISTENCIA/PASSAGENS/VALORLIMITE")

        when "ASSISTENCIA_HOSPEDAGEM"

        # RETORNA OS DADOS DA ASSISTENCIA DE HOSPEDAGEM
             # 1 -> DIARIAS
             # 2 -> VALOR LIMITE

           return figrc011_xpath(lr_parametro.doc_handle,
                         "/APOLICE/ASSISTENCIA/HOSPEDAGEM/DIARIAS"),
                  figrc011_xpath(lr_parametro.doc_handle,
                         "/APOLICE/ASSISTENCIA/HOSPEDAGEM/VALORLIMITE")

        when "ASSISTENCIA_RETORNO"

        # RETORNA O LIMITE DO RETORNO
             # 1 -> LIMITE

           return figrc011_xpath(lr_parametro.doc_handle,
                          "/APOLICE/ASSISTENCIA/RETORNO/LIMITERETORNO")

        when "ASSISTENCIA_DESCRICAO"


        # RETORNA A DESCRICAO DO TIPO DE ASSISTENCIA
             # 1 -> DESCRICAO

           return figrc011_xpath(lr_parametro.doc_handle,
                          "/APOLICE/ASSISTENCIA/DESCRICAOASSISTENCIA")

        when "FONE_SEGURADO"

        # RETORNA O TELEFONE DO SEGURADO
             # 1 -> DDD DO TELEFONE
             # 2 -> NUMERO DO TELEFONE

           return figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/FONES/FONE/DDD"),
                  figrc011_xpath(lr_parametro.doc_handle,
                              "/APOLICE/SEGURADO/FONES/FONE/NUMERO")
        when "FRANQUIA"

        # RETORNA O VALOR DA FRANQUIA
             # 1 -> FRANQUIA

           return  figrc011_xpath(lr_parametro.doc_handle,
                                  "/APOLICE/IS/FRANQUIA")

        when "CNPJ/CPF"
           return figrc011_xpath(lr_parametro.doc_handle,
                       "/APOLICE/SEGURADO/CGCCPF")
        otherwise
           error "RETORNO N EXISTE: ", lr_parametro.retorno clipped,
                 " NA FUNCAO cts40g02_extraiDoXML() " sleep 4

     end case
  else
     error "PARAMETROS NULOS cts40g02_extraiDoXML ! ",
            "PAR 1: ", lr_parametro.doc_handle, "|",
            "PAR 2: ",lr_parametro.retorno clipped sleep 4
  end if

end function
