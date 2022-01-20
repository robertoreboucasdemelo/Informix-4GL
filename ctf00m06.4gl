################################################################################
# Sistema  : CTS      - Central 24 Horas                           AGOSTO/2008 #
# Programa :                                                                   #
# Modulo   : ctf00m06 - Gerar Xml de Erro para os Servicos - Portal do Segurado#
# Analista : Carla Rampazzo                                                    #
# PSI      :                                                                   #
# Liberacao:                                                                   #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
#                           * * * Comentarios * * *                            #
#                                                                              #
################################################################################

#-----------------------------------------------------------------------------
function ctf00m06_xmlerro(param)
#-----------------------------------------------------------------------------

   define param   record
          servico char(100)
         ,erro    smallint
         ,msgerro char (1000)
   end record

   define l_xml   char(2000)

   let l_xml  = null

   let l_xml = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
               "<RESPONSE>",
               "<SERVICO>"   ,param.servico clipped ,"</SERVICO>" ,
               "<ERRO>",
               "<CODIGO>"    ,param.erro    clipped using '<<<<',"</CODIGO>" ,
               "<DESCRICAO>" ,param.msgerro clipped,"</DESCRICAO>",
               "</ERRO>",
               "</RESPONSE>"

   return l_xml

end function
