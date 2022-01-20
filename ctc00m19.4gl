#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc00m19                                                       #
# Programa   : Tela Help    - Circular 380 -                                  #
#-----------------------------------------------------------------------------#
# Analista Resp. : Robert Lima                                                #
# PSI            : 259136                                                     #
#                                                                             #
# Desenvolvedor  : Robert Lima                                                #
# DATA           : 18/08/2010                                                 #
#.............................................................................#
# Data        Autor      Alteracao                                            #
#                                                                             #
# ----------  ---------  -----------------------------------------------------#
#-----------------------------------------------------------------------------#


#----------------------------------------------
function ctc00m19(l_texto,l_texto2)
#----------------------------------------------

define l_texto char(5000),
       l_texto2 char(50),
       prompt_key char(1)

open window w_ctc00m19 AT 2,2 with form "ctc00m19"
             attribute (border, form line first)
display l_texto to texto
display l_texto2 to texto2
 error "Aperte ENTER para sair...."
 prompt "" for char prompt_key
close window w_ctc00m19


end function
