###########################################################################
# Nome do Modulo: ctc35n00                                       Gilberto #
#                                                                 Marcelo #
#                                                                 Wagner  #
# Menu do modulo manutencao de vistorias de veiculos(P.Socorro)  Dez/1998 #
###########################################################################

 database porto

#-----------------------------------------------------------
 function ctc35n00()
#-----------------------------------------------------------

   open window w_ctc35n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc35n00--" at 3,1

   menu "VISTORIAS"

      command key ("C") "Cadastros"
                        "Manutencao dos cadastros da vistoria"
        call ctc35n01()

      command key ("A") "Agenda"
                        "Manutencao da agenda de vistorias"
        call ctc36m01()

      command key ("L") "Laudos"
                        "Manutencao dos laudos de vistorias"
        call ctc36m02()

      command key ("O") "cOnsultas"
                        "Consultas genericas de vistoria"
        call ctc36n00()

      command key ("I") "Impressao"
                        "Impressao de laudo/vistoria"
        call ctc38n00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc35n00

   let int_flag = false

end function   ##-- ctc35n00
