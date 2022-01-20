###########################################################################
# Nome do Modulo: ctc32n00                                       Gilberto #
#                                                                 Marcelo #
# Menu de cadastramento de bloqueios de atendimento              Abr/1998 #
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

#-----------------------------------------------------------
 function ctc32n00()
#-----------------------------------------------------------

   open window w_ctc32n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc32n00--" at 3,1

   menu "BLOQUEIOS"

      before menu
        hide option all
       #PSI 202290
       #if  g_issk.acsnivcod  >=  8   then # conforme Arnaldo 10/09/2002.
       # if  g_issk.acsnivcod  >=  6   then
              show option "Cadastro"
       # end if
        show option "Pesquisa"
        show option "impRime"
        show option "Encerra"

      command key ("C") "Cadastro"
                        "Manutencao dos bloqueios de atendimento"
        call ctc32m00()

      command key ("P") "Pesquisa"
                        "Pesquisa bloqueios de atendimento"
        call ctc32m04()

      command key ("R") "impRime"
                "Imprime relacao de bloqueios de atendimento"
        call ctc32m05()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc32n00

   let int_flag = false

end function   ##-- ctc32n00
