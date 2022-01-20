###########################################################################
# Nome do Modulo: ctc36n00                                       Gilberto #
#                                                                 Marcelo #
#                                                                 Wagner  #
# Menu consultas genericas de vistoria                           Dez/1998 #
###########################################################################

 database porto

#-----------------------------------------------------------
 function ctc36n00()
#-----------------------------------------------------------

   define ws       record
     socvstlaunum  like datmvstlau.socvstlaunum
   end record

   open window w_ctc36n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc36n00--" at 3,1

   menu "CONSULTAS"

      command key ("L") "Laudos"
                        "Consulta laudos de vistoria"
        call ctc35m07() returning  ws.socvstlaunum

      command key ("V") "Vistorias"
                        "Consulta vistorias"
        call ctc36m06()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc36n00

   let int_flag = false

end function   ##-- ctc36n00
