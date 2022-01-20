#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cty01g02                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI187550                                                  #
#                 Obter Pop-up de sinistros informados para o documento.     #
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

#------------------------------------#
function cty01g02_fsauc540(lr_param)
#------------------------------------#
 define lr_param record
    succod    like ssamsin.succod
   ,ramcod    like ssamsin.ramcod
   ,aplnumdig like ssamsin.aplnumdig
   ,itmnumdig like ssamsin.itmnumdig
 end record

 define lr_retorno record
    sinramcod like ssamsin.ramcod
   ,sinano    like ssamsin.sinano
   ,sinnum    like ssamsin.sinnum
 end record

 initialize lr_retorno to null

 if lr_param.succod is not null and
    lr_param.ramcod is not null and
    lr_param.aplnumdig is not null and
    lr_param.itmnumdig is not null then
    call fsauc540(lr_param.succod
                 ,lr_param.ramcod
                 ,lr_param.aplnumdig
                 ,lr_param.itmnumdig)
       returning lr_retorno.sinramcod
                ,lr_retorno.sinano
                ,lr_retorno.sinnum
 end if

 return lr_retorno.*

end function

