###########################################################################
# Nome do Modulo: ctc14n00                                       Gilberto #
#                                                                 Marcelo #
# Menu de cadastramento de codigos de assunto                    Mar/1998 #
###########################################################################

 database porto

#-----------------------------------------------------------
 function ctc14n00()
#-----------------------------------------------------------

   open window w_ctc14n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc14n00--" at 3,1

   menu "ASSUNTOS"

      command key ("A") "Agrupamentos"
                        "Manutencao dos agrupamentos e/ou codigos de assunto"
        call ctc14m00()

      command key ("R") "impRime"
                "Imprime relacao de assuntos por agrupamento"
        call ctc14m03()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc14n00

   let int_flag = false

end function   ##-- ctc14n00
