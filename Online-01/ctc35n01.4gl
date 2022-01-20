###########################################################################
# Nome do Modulo: ctc35n01                                       Gilberto #
#                                                                 Marcelo #
#                                                                 Wagner  #
# Menu manutencao cadastros de vistorias dos veiculos            Dez/1998 #
###########################################################################

 database porto

#-----------------------------------------------------------
 function ctc35n01()
#-----------------------------------------------------------

   open window w_ctc35n01 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc35n01--" at 3,1

   menu "CADASTROS"

      command key ("L") "Locais"
                        "Manutencao dos locais para realizacao da vistoria"
        call ctc35m08()

      command key ("T") "Tipos"
                        "Manutencao dos tipos de laudos de vistoria"
        call ctc35m01()

      command key ("G") "Grupos"
                        "Manutencao dos grupos de itens de vistoria"
        call ctc35m02()

      command key ("I") "Itens"
                        "Manutencao dos itens da vistoria"
        call ctc35m03()

      command key ("V") "Verificacoes"
                        "Manutencao das verificacoes dos itens"
        call ctc35m04()

      command key ("M") "Monta_laudos"
                        "Manutencao dos lay-outs dos laudos de vistoria"
        call ctc35m05()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc35n01

   let int_flag = false

end function   ##-- ctc35n01
