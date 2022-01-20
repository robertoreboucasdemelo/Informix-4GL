#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc97m00                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15798                                              #
# Objetivo......: Tela de cadastro de plano Assistencia                       #
#.............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

#==============================================================================
#function ctc97m00_prepare()
##==============================================================================
#
#end function


#==============================================================================
function ctc97m00()
#==============================================================================

  open window w_ctc97m00 at 4,2 with form 'ctc97m00'
       attribute(form line first)

  menu "REGRAS ITAU"
      command "Plano_Assistencia"
                "Manutencao Plano Assitencia das Regras Itau Residencia"
                call ctc97m01()

      command "Grupo de Assistencia"
                "Manutencao Grupo de assistencia"
                call ctc97m02()
      
      command key (interrupt,E) "Encerra" 
               "Fim de servico"
               exit menu 

  end menu

  close window w_ctc97m00
end function