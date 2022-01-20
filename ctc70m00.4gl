#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24h                                  #
#  Modulo         : ctc70m00.4gl                                 #
#                   Cadastro de Recusa de servicos (Internet /   #
#                   Outros)                                      #
#  Analista Resp. : Carlos Zyon                                  #
#  PSI            : 177903                                       #
#  OSF            : 31682                                        #
#................................................................#
#................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Mariana Gimenez         #
#  Liberacao      : 30/01/2004                                   #
#................................................................#
#                     * * *  ALTERACOES  * * *                   #
#                                                                #
#  Data         Autor Fabrica  Data   Alteracao                  #
#  ----------   -------------  ------ -------------------------- #

database porto


{
main

defer interrupt

call ctc70m00()

end main
}
#---------------------#
function ctc70m00()
#---------------------#

define l_escolha char(01)

   open window w_escolha  at 4,2 with 22 rows, 78 columns    
     # attribute (border)               


      menu "Recusas"

        command key ('O') "Outros" 
           call ctc70m01()

        command key ('I') "Internet"
           call ctc70m02() 

        command key (interrupt,'E') "Encerra"
           exit menu

      end menu 

 
    close window w_escolha  

end function


