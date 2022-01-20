###########################################################################
# Nome do Modulo: CTB11N00                                       Gilberto #
#                                                                 Marcelo #
# Menu de pagamentos - Porto Socorro                             Dez/1996 #
###########################################################################

database porto

#--------------------------------------------------------------------------
 function ctb11n00()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctb11n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb11n00--" at 03,01

   menu "PAGAMENTOS"

      command key ("P") "Protocolo"
                        "Manutencao do protocolo de ordem de pagamento"
        call ctb11m00()

      command key ("O") "O.P."
                        "Manutencao da ordem de pagamento"
        call ctb11m01()

      command key ("S") "conSultas"
                        "Consultas genericas"
        call ctb12n00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb11n00

   let int_flag = false

end function   #---- ctb11n00
