###############################################################################
# Nome do Modulo: CTB00M03                                           Marcelo  #
#                                                                    Gilberto #
# Exibe janela para confirmacao da acao a ser tomada                 Set/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb00m03(param)
#-----------------------------------------------------------

   define param    record
      linha1       char (40),
      linha2       char (40)
   end record

   define retorno  smallint

   open window ctb00m03 at 11,12 with form "ctb00m03"
        attribute(border, form line 1)

   display by name param.*

   options
      menu line 6

   let retorno = false
   message " (F17) Abandona"

   menu " Opcoes "
      command key ("C", interrupt) "Corrige" " Corrige o valor da diferenca"
              exit menu

      command key ("R") "Retorna" " Retorna para digitacao dos itens"
              let retorno = true
              exit menu
   end menu

   let int_flag = false
   close window ctb00m03
   return retorno

end function # ctb00m03
