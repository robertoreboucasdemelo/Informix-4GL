###########################################################################
# Nome do Modulo: CTB04N00                                       Wagner   #
#                                                                         #
# Menu de pagamentos - Ramos Elementares RE                      Nov/2001 #
###########################################################################

database porto

#--------------------------------------------------------------------------
 function ctb04n00()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctb04n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb04n00--" at 03,01

   menu "PAGAMENTOS-RE"

      command key ("P") "Protocolo"
                        "Manutencao do protocolo de ordem de pagamento - RE"
        call ctb04m00()

      command key ("O") "O.P."
                        "Manutencao da ordem de pagamento - RE"
        call ctb04m01()

      command key ("S") "conSultas"
                        "Consultas genericas referentes ao RE"
        call ctb05n00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb04n00

   let int_flag = false

end function   #---- ctb04n00

