############################################################################
# Nome do Modulo: CTS02G01                                        Marcelo  #
#                                                                 Gilberto #
# Rotinas genericas para servidor de fax VSI-Fax                  Out/1998 #
############################################################################


database porto

#----------------------------------------------------------------------------
 function cts02g01_fax(param)
#----------------------------------------------------------------------------

 define param      record
    dddcod         like dpaksocor.dddcod,
    faxnum         like dpaksocor.faxnum
 end record

 define ws         record
    faxtxt         char (12)
 end record



	initialize  ws.*  to  null

 initialize ws.faxtxt  to null

 if param.dddcod is null  and
    param.faxnum is null  then
    return ws.faxtxt
 end if

 if param.dddcod <> "011" and param.dddcod <> "11" and
    param.dddcod <> "0011"  then
    if param.dddcod > 0099  then
       let ws.faxtxt = param.dddcod using "&&&&"
    else
       let ws.faxtxt = param.dddcod using "&&&"
    end if
 end if

 if param.faxnum > 99999999  then
    let ws.faxtxt = ws.faxtxt clipped, param.faxnum using "&&&&&&&&&"
 else
 if param.faxnum > 9999999  then
    let ws.faxtxt = ws.faxtxt clipped, param.faxnum using "&&&&&&&&"
 else
       let ws.faxtxt = ws.faxtxt clipped, param.faxnum using "&&&&&&&"
    end if
 end if

 return ws.faxtxt

end function  ###  cts02g01
