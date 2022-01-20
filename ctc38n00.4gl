###########################################################################
# Nome do Modulo: CTC38N00                                       Gilberto #
#                                                                 Marcelo #
#                                                                 Wagner  #
# Menu de Impressao de laudos/vistorias                          Jan/1999 #
###########################################################################

 database porto


 globals "/homedsa/projetos/geral/globals/glct.4gl"


#-----------------------------------------------------------
 function ctc38n00()
#-----------------------------------------------------------

   open window w_ctc38n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc38n00--" at 3,1

   menu "IMPRESSAO"

      command key ("I") "Imprime"            "Imprime laudo/vistoria"
        call ctc38m01()

      command key (interrupt,E) "Encerra"    "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc38n00

   let int_flag = false

end function   ##-- ctc38n00
