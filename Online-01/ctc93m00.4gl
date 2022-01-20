#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc93m00                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00287/EV                                           #
# Objetivo......: Tela para exibir o menu dos cadastros para contabilizacao   #
#                 correta dos servicos                                        #
#.............................................................................#
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao......: 16/01/2012                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

#------------------------------------------------------------
 function ctc93m00()
#------------------------------------------------------------
 
 menu "Cadatros"

  command key ("O") "Origens"
                   "Cadastros de/para de origens"
          call ctc93m01()
 
 command key ("M") "Motivos"
                   "Cadastros de/para de motivos"
          call ctc93m03()
  
 command key ("C") "Contabilizacao"
                   "Cadastros dos parametros de contabilizacao"
          call ctc93m05() 
 
 #Fornax-Quantum - Inicio
 command key ("R") "Retencao"
                   "Cadastros codigo de retencao"
          call ctc93m06()
 #Fornax-Quantum - Fim  
          
 command key (interrupt,E) "Encerra"   
                   "Retorna ao menu anterior"
          exit menu
 end menu

end function  ###  ctc93m00
 

