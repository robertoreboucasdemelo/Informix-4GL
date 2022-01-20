#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty04g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Aciona o metodo de pesquisa de dados do cliente            #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 20/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
database porto

#-------------------------------#
function cty04g00_pesq_cliente()
#-------------------------------#
  define lr_ppt     record
         segnumdig  like rptmcmn.segnumdig
        ,cmnnumdig  like rptmcmn.cmnnumdig
        ,lgdtip     like rviklocalrisco.lgdtip
        ,lgdnom     like rviklocalrisco.lgdnom
        ,endnum     like rviklocalrisco.endnum
        ,ufdcod     like rviklocalrisco.ufdcod
        ,endcmp     like rviklocalrisco.endcmp
        ,brrnom     like rviklocalrisco.brrnom
        ,cidnom     like rviklocalrisco.cidnom
        ,lgdcep     like rviklocalrisco.lgdcep
        ,lgdcepcmp  like rviklocalrisco.lgdcepcmp
        ,situacao   char(12)
        ,viginc     date
        ,vigfnl     date
        ,atldat     date
        ,corsus     char(06)
        ,frmpgt     dec(2,0)
        ,moeda      char(03)
        ,lclrsccod  like rviklocalrisco.lclrsccod
        end record
  define al_ppt       array[05] of record
         cmnclscod    char(03)
        ,datfim       date
         end record

  initialize lr_ppt to null
  initialize al_ppt to null
  call orptc020_pesq_cliente()
  returning lr_ppt.*
          , al_ppt[1].*
          , al_ppt[2].*
          , al_ppt[3].*
          , al_ppt[4].*
          , al_ppt[5].*

  return lr_ppt.*
        ,al_ppt[1].*
        ,al_ppt[2].*
        ,al_ppt[3].*
        ,al_ppt[4].*
        ,al_ppt[5].*
end function

