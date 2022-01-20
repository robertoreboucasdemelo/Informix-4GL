############################################################################
# Nome do Modulo: CTS02G00                                        Marcelo  #
#                                                                 Gilberto #
# Rotina generica p/ tratamento de caracteres invalidos no fax    Mai/1997 #
############################################################################

database porto


#----------------------------------------------------------------------------
 function cts02g00(param)
#----------------------------------------------------------------------------
 define param      record
    destinatario   char(24)
 end record

 define ws_pos     integer


 #------------------------------------------------------------------
 # Substitui caracteres invalidos p/ o gerenciador(gsfax) em brancos
 #------------------------------------------------------------------

	let	ws_pos  =  null

 for ws_pos = 1 to length(param.destinatario)

     if param.destinatario[ws_pos, ws_pos]  =  "#"   or
        param.destinatario[ws_pos, ws_pos]  =  "("   or
        param.destinatario[ws_pos, ws_pos]  =  ")"   or
        param.destinatario[ws_pos, ws_pos]  =  "{"   or
        param.destinatario[ws_pos, ws_pos]  =  "}"   or
        param.destinatario[ws_pos, ws_pos]  =  "["   or
        param.destinatario[ws_pos, ws_pos]  =  "]"   or
        param.destinatario[ws_pos, ws_pos]  =  ">"   or
        param.destinatario[ws_pos, ws_pos]  =  "<"   or
        param.destinatario[ws_pos, ws_pos]  =  "|"   or
        param.destinatario[ws_pos, ws_pos]  =  "^"   or
        param.destinatario[ws_pos, ws_pos]  =  "!"   or
        param.destinatario[ws_pos, ws_pos]  =  "~"   or
        param.destinatario[ws_pos, ws_pos]  =  "."   or
        param.destinatario[ws_pos, ws_pos]  =  "/"   or
        param.destinatario[ws_pos, ws_pos]  =  "*"   or
        param.destinatario[ws_pos, ws_pos]  =  "@"   then
        let param.destinatario[ws_pos, ws_pos] = " "
    end if

 end for

 return param.destinatario

 end function   #-- cts02g00

