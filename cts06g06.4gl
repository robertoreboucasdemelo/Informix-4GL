#############################################################################
# Nome do Modulo: CTS06G06                                         Marcelo  #
#                                                                  Gilberto #
# Funcoes genericas - Endereco sem complemento                     Mar/1999 #
#############################################################################

database porto


#----------------------------------------------------------------------------
 function cts06g06(param)
#----------------------------------------------------------------------------

 define param        record
    lgdnom           like glaklgd.lgdnom
 end record

 define ws           record
    maxtam           smallint,
    lgdnom           like glaklgd.lgdnom
 end record

 define i            smallint


	let	i  =  null

	initialize  ws.*  to  null

 initialize ws.* to null

 let ws.maxtam = length(param.lgdnom)

 for i = 2 to ws.maxtam
    if param.lgdnom[i,i]     = "-"  and
       param.lgdnom[i-1,i-1] = " "  and
       param.lgdnom[i+1,i+1] = " "  then
       let ws.lgdnom = param.lgdnom[1,i-1] clipped
       exit for
    end if
 end for

 if ws.lgdnom is null  then
    return param.lgdnom
 else
    return ws.lgdnom
 end if

end function  ###  cts06g06
