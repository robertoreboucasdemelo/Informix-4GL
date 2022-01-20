###########################################################################
# Nome do Modulo: ctc42n00                                        Wagner  #
#                                                                         #
# Menu do modulo manutencao dos cadastros referentes ao Teletrim Jan/2001 #
###########################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc42n00()
#------------------------------------------------------------

   open window w_ctc42n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc42n00--" at 3,1

   menu "TELETRIM"

      command key ("M") "Mensagens"
                        "Manutencao do Cadastro de Mensagens para Teletrim"
        call ctc51m00()

      command key ("G") "Grupos"
                        "Manutencao do Cadastro de Grupos para envio Teletrim"
        call ctc52m00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc42n00

   let int_flag = false

end function   ##-- ctc42n00
