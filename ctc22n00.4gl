###########################################################################
# Nome do Modulo: CTC22C00                                       Gilberto #
#                                                                 Marcelo #
# Menu de Consultas de informacoes sobre Convenios               Mar/1996 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 11/07/2002  PSI 15590-0  Wagner       Inclusao acesso ao ctc22m01       #
###########################################################################

database porto

#-----------------------------------------------------------
 function ctc22n00()
#-----------------------------------------------------------

   open window w_ctc22n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc22n00--" at 3,1

   menu "Convenios"

      command key ("S") "Sucursais"
                        "Manutencao das Sucursais"
        call ctc22m00()

      command key ("P") "Procedimentos"
                        "Manutencao dos Procedimentos para Atendimento"
        call ctc24m00()

      command key ("I") "Informativo"          
                        "Informativo para convenios por assunto"  
        call ctc22m01()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc22n00

   let int_flag = false

end function   #---- ctc22n00

