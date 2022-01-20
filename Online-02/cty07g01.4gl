#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cty07g01                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI187550                                                  #
#                 Gravar sinistro para grilo.                                #
#............................................................................#
# Desenvolvimento: Robson Inocencio, META                                    #
# Liberacao      : 10/09/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

#-----------------------------------#
function cty07g01_fadia010(lr_param)
#-----------------------------------#
 define lr_param record
    vcllicnum like abbmveic.vcllicnum
   ,vclchsfnl like abbmveic.vclchsfnl
   ,letra     char(01)
 end record

 call fadia010_grilo(lr_param.*)

end function

