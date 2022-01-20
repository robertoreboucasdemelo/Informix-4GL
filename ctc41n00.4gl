 ###########################################################################
 # Nome do Modulo: ctc41n00                                       Gilberto #
 #                                                                 Marcelo #
 #                                                                         #
 # Menu do modulo manutencao dos cadastros referentes ao GPS      Jul/1999 #
 #-------------------------------------------------------------------------#
 # 18/12/2000  PSI 12023-5  Marcus       Alterar cadastro de viaturas para #
 #                                       trabalhar com grupo de acionamento#
 ###########################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc41n00()
#-----------------------------------------------------------

   open window w_ctc41n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc41n00--" at 3,1

   menu "GPS"

      before menu

        if  not ctc42m01_verifica_usu(g_issk.funmat) then
            hide option "bLoq_simcard"
        end if

      command key ("C") "Controladoras"
                        "Manutencao do cadastro de controladoras"
        call ctc41m00()

      command key ("F") "conFig_MDTs"
                        "Manutencao do cadastro de configuracoes dos MDTs"
        call ctc46m00()

      command key ("D") "MDTs"
                        "Manutencao do cadastro de MDTs"
        call ctc42m00()

      command key ("B") "Botoes"
                        "Manutencao do cadastro de botoes"
        call ctc43m00()

      command key ("P") "Programacao"
                        "Manutencao dos cadastros de programacao dos botoes"
        call ctc43m01()

      command key ("T") "ponTos"
                        "Manutencao do cadastro de pontos geograficos"
        call ctc45m00()

      command key ("M") "Mapas"
                        "Manutencao do cadastro de mapas digitais"
        call ctc50m00()
        
      command key ("L") "bLoq_simcard"  
                        "Manutencao do cadastro de mapas digitais"
        call ctc42m02()                     

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc41n00

   let int_flag = false

end function   ##-- ctc41n00
