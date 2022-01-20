###########################################################################
# Nome do Modulo: CTC30N00                                          Pedro #
#                                                                 Marcelo #
# Menu de Cadastros - CARRO EXTRA                                Out/1995 #
###########################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc30n00()
#----------------------------------------------------------------

   let int_flag = false

   open window w_ctc30n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc30n00--" at 03,01

   menu "CADASTROS"

     before menu
          hide option "Itens_Pagto"
          if get_niv_mod(g_issk.prgsgl,"ctc31m00") then
             if g_issk.acsnivcod >= g_issk.acsnivatl then ## NIVEL 6
                show option "Itens_Pagto"
             end if
          end if

      command key ("L") "Locadoras"    "Manutencao de locadoras"
        call ctc30m00()

      command key ("J") "loJas"        "Manutencao de lojas"
        call ctc18m00()

      command key ("V") "Veiculos"     "Manutencao de veiculos"
        call ctc19m00()

      command key ("I") "Itens_Pagto"  "Manutencao dos itens de pagamento"
        call ctc31m00()

      command key (interrupt,E) "Encerra"    "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc30n00

   let int_flag = false

end function  ###  ctc30n00
