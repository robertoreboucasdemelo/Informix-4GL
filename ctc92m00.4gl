###########################################################################
# Nome do Modulo: ctc92m00                               Helder Oliveira  #
#                                                                         #
# Regras Cobertura                                               Mar/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

#==============================================================================
function ctc92m00_prepare()
#==============================================================================

end function


#==============================================================================
function ctc92m00()
#==============================================================================

  open window w_ctc92m00 at 4,2 with form 'ctc92m00'
       attribute(form line first)

  menu "REGRAS ITAU"
      command "Plano_Assistencia"
                "Manutencao Plano Assitencia das Regras Itau"
                call ctc92m01()

      command "Motivo_Reserva"
                "Manutencao Motivo Reserva das Regras Itau"
                call ctc92m06()
      
      command key (interrupt,E) "Encerra" 
               "Fim de servico"
               exit menu 

  end menu

  close window w_ctc92m00
end function