###############################################################################
# Nome do Modulo: CTC35M14                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Abre janela de confirmacao                                         Dez/1998 #
###############################################################################

#-----------------------
 function ctc35m14()
#-----------------------

   define retorno  smallint

   open window w_ctc35m14 at 11,22 with 7 rows, 36 columns
        attribute(border)

   display "CONFIRMA EXCLUSAO" at 1,10
   display "--------------------------ctc35m14--" at 2,1

   let retorno = false

   options menu line 3

   message " (F17)Abandona"

   menu " Opcoes "
      command key ("N", interrupt) "Nao" " Nao exclui o registro"
              error "Exclusao cancelada!"
              exit menu

      command key ("S")            "Sim" " Exclui o registro"
              let retorno = true
              exit menu
   end menu

   let int_flag = false
   close window w_ctc35m14
   return retorno

end function # ctc35m14

