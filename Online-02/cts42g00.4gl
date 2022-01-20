#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: cts42g00                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 205.206 - AZUL SEGUROS                                     #
#                  Recebe a apolice e retorna o doc_handle                    #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 23/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

#--------------------------------------#
function cts42g00_doc_handle(lr_param)
#--------------------------------------#

  define lr_param     record
         succod       like datkazlapl.succod,
         ramcod       like datkazlapl.ramcod,
         aplnumdig    like datkazlapl.aplnumdig,
         itmnumdig    like datkazlapl.itmnumdig,
         edsnumdig    like datkazlapl.edsnumdig
         end record

  define l_azlaplcod  like datkazlapl.azlaplcod,
         l_resultado  smallint,
         l_mensagem   char(30),
         l_doc_handle integer

  let l_azlaplcod  = null
  let l_resultado = 1
  let l_mensagem  = null
  let l_doc_handle  = null

  ## Obter o codigo da apolice da azul (azlaplcod)
  call ctd02g01_azlaplcod(lr_param.succod, lr_param.ramcod,
                          lr_param.aplnumdig, lr_param.itmnumdig,
                          lr_param.edsnumdig)
       returning l_resultado, l_mensagem, l_azlaplcod
  ## Achou o codigo da apolice
  if l_resultado = 1 then
     call ctd02g00_agrupaXML(l_azlaplcod)
          returning l_doc_handle
  else
     let l_resultado = 2
     let l_mensagem = "Nao achou o codigo da apolice"
  end if

  return l_resultado, l_mensagem, l_doc_handle

end function
