#############################################################################
# Nome do Modulo: CTS06G03                                           Sergio #
#                                                                    Burini #
# Laudo - Replace                                                  Mar/1995 #
# ######################################################################### #
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta- #
#                                       bela DATMSERVICO.                   #
#---------------------------------------------------------------------------#

 database porto

#-----------------------------------------#
 function cts06g10_monta_brr_subbrr(param)
#-----------------------------------------#

 define param record
                  brrnom     like datmlcl.brrnom,
                  lclbrrnom  like datmlcl.lclbrrnom
              end record
 define lr_retorno record
     brrnom like datmlcl.brrnom
 end record
 
 initialize lr_retorno.brrnom to null

 if  (param.brrnom is not null and param.brrnom <> " ") and
     (param.lclbrrnom is not null and param.lclbrrnom <> " ") then
     if  param.lclbrrnom = param.brrnom then
         let lr_retorno.brrnom = param.brrnom
     else
         let lr_retorno.brrnom = param.brrnom clipped, " - ", param.lclbrrnom
     end if
 else
     if  (param.brrnom is null or param.brrnom = " ") and
         (param.lclbrrnom is not null and param.lclbrrnom <> " ") then
         let lr_retorno.brrnom = param.lclbrrnom
     else
         if  (param.brrnom is not null and param.brrnom <> " ") and
             (param.lclbrrnom is null or param.lclbrrnom = " ") then
             let lr_retorno.brrnom = param.brrnom
         end if
     end if
 end if
 return lr_retorno.brrnom
 end function
