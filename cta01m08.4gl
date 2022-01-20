###############################################################################
# Nome do Modulo: cta01m08                                           Gilberto #
#                                                                     Marcelo #
# Exibe vencimentos alternativos da parcela                          Set/1997 #
# ----------------------------------------------------------------------------#  
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          # 
#-----------------------------------------------------------------------------# 

database porto


#---------------------------------------------------------------------
 function cta01m08(param)
#---------------------------------------------------------------------

 define param       record
    titnumdig       like fctmtitulos.titnumdig
 end record

 define d_cta01m08  record
    vctpridat       like fctmvctalt.vctpridat,
    vctprivlr       like fctmvctalt.vctprivlr,
    vctsgndat       like fctmvctalt.vctsgndat,
    vctsgnvlr       like fctmvctalt.vctsgnvlr
 end record

 define ws          record
    pergunta        char(01)
 end record




	initialize  d_cta01m08.*  to  null

	initialize  ws.*  to  null

 initialize d_cta01m08.*  to null
 initialize ws.*          to null

 select vctpridat, vctprivlr,
        vctsgndat, vctsgnvlr
   into d_cta01m08.vctpridat, d_cta01m08.vctprivlr,
        d_cta01m08.vctsgndat, d_cta01m08.vctsgnvlr
   from fctmvctalt
  where titnumdig = param.titnumdig

 if sqlca.sqlcode <> 0     and
    sqlca.sqlcode <> 100   then
    error " Erro (",sqlca.sqlcode,") vencto alternativo, AVISE INFORMATICA!"
    sleep 4
    return
 else
    if sqlca.sqlcode = 100   then
       error " Parcela nao possui vencimento alternativo!"
       return
    end if
 end if


 open window cta01m08 at 10,36 with form "cta01m08"
      attribute (border, form line first)

 display by name  d_cta01m08.vctpridat, d_cta01m08.vctprivlr,
                  d_cta01m08.vctsgndat, d_cta01m08.vctsgnvlr

 prompt " (F17)Abandona "  for char  ws.pergunta

 close window cta01m08

end function   #--- cta01m08
