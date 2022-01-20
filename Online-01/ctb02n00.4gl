###########################################################################
# Nome do Modulo: CTB02N00                                       Wagner   #
#                                                                         #
# Menu de pagamentos - Carro-Extra                               Out/2000 #
###########################################################################

database porto

#--------------------------------------------------------------------------
 function ctb02n00()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctb02n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb02n00--" at 03,01

   menu "PAGAMENTOS"

      command key ("P") "Protocolo"
                        "Manutencao do protocolo de ordem de pagamento"
        call ctb02m00()

      command key ("O") "O.P."
                        "Manutencao da ordem de pagamento"
        call ctb02m01()

      command key ("C") "Consultas"
                        "Consultas genericas"
        call ctb03n00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb02n00

   let int_flag = false

end function   #---- ctb02n00
