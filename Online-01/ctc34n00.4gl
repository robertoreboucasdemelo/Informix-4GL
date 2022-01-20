###########################################################################
# Nome do Modulo: ctc34n00                                       Gilberto #
#                                                                 Marcelo #
#                                                                         #
# Menu manutencao dos cadastros referentes aos veiculos          Jul/1999 #
###########################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc34n00()
#-----------------------------------------------------------

   open window w_ctc34n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc34n00--" at 3,1

   menu "VEICULOS"

      command key ("C") "Cadastro"
                        "Manutencao do cadastro de veiculos"
        call ctc34m01()

      command key ("Q") "eQuipamentos"
                        "Manutencao do cadastro de equipamentos dos veiculos"
        call ctc34m04()

      command key ("F") "Fabricantes"
                        "Manutencao do cadastro de fabricantes de equipamentos"
        call ctc34m05()

      command key ("D") "Distribuicao"
                        "Manutencao do cadastro de grupos de distribuicao"
        call ctc34m07()
        
      command key ("P") "Pesq_GPS"
                        "Pesquisa veiculos por localidade"
        call ctn53c00()         

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc34n00

   let int_flag = false

end function   ##-- ctc34n00
