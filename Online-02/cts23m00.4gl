###########################################################################
# Nome do Modulo: cts23m00                                       Marcus   #
#                                                                         #
#                                                                         #
# Menu acesso as telas de inconsistencias da Frota               OUT/2000 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 23/01/2002  PSI 16377-5  Raji         Opcao de historio das inconsist.  #
###########################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts23m00()
#-----------------------------------------------------------

   open window w_cts23m00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----cts23m00--" at 3,1

   menu "INCONSISTENCIAS"

      command key ("L") "Localizacao"
                        "Viaturas com problemas de Localizacao/Sinal"
         call cts23m01()

      command key ("S") "Socorro"
                        "Andamento do Servico - QRU-REC"
         call cts25m00()

      command key ("H") "Historico"
                        "Historico de inconsistencias"
         call ctn52c00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu

   clear screen

   end menu

   close window w_cts23m00

   let int_flag = false

end function
