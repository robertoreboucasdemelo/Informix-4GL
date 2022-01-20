#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HORAS                                           #
# Modulo        : cty05g01                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 183431                                                     #
# OSF           : 036439                                                     #
#                 Chamar metodo f_funapol_ultima_situacao.                   #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 20/07/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

#-----------------------------------------#
function cty05g01_ultsit_apolice(lr_param)
#-----------------------------------------#
  define lr_param record
     succod    like abbmitem.succod
    ,aplnumdig like abbmitem.aplnumdig
    ,itmnumdig like abbmitem.itmnumdig
  end record
  define lr_cty05g01 record
     resultado char(01)
    ,dctnumseg decimal(04)
    ,vclsitatu decimal(04)
    ,autsitatu decimal(04)
    ,dmtsitatu decimal(04)
    ,dpssitatu decimal(04)
    ,appsitatu decimal(04)
    ,vidsitatu decimal(04)
  end record

  initialize lr_cty05g01 to null
  if (lr_param.succod is not null) and
     (lr_param.aplnumdig is not null) and
     (lr_param.itmnumdig is not null) then
     call f_funapol_ultima_situacao(lr_param.*)
     returning lr_cty05g01.*
  end if
  return lr_cty05g01.*
end function

