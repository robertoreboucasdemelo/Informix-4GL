###########################################################################
# Nome do Modulo: CTC29N00                                       Marcelo  #
#                                                                Gilberto #
# Menu de Consultas de informacoes sobre Relatorios              Mai/1996 #
###########################################################################
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ---------------------------------- #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function ctc29n00()
#--------------------------------------------------------------------

   open window w_ctc29n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc29n00--" at 03,01

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc29n00") then
   #   error " Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   let int_flag = false

   menu "Relatorios"

       before menu
          hide option all
          #PSI 202290
          #if g_issk.acsnivcod >= g_issk.acsnivcns  then
          #   show option "Consulta"
          #end if
          #if g_issk.acsnivcod >= g_issk.acsnivatl  then
          #   show option "Solicitacao"
          #end if

          show option "Consulta", "Solicitacao", "Encerra"

      command key ("S") "Solicitacao"     "Solicitacao de relatorios"
         call ctc29m00()

      command key ("C") "Consulta"        "Consulta aos relatorios solicitados"
         call ctc29m02()

      command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc29n00

   let int_flag = false

end function   #---- ctc29n00
