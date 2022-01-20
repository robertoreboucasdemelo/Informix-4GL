#############################################################################
# Nome do Modulo: CTS09G02                                         Marcelo  #
#                                                                  Gilberto #
# Elimina caracteres alfabeticos do numero de telefone/fax         Mai/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/08/1999  ** ERRO **   Gilberto     Alterar o tamanho minimo do DDD de  #
#                                       tres posicoes para duas posicoes.   #
#############################################################################

 database porto


#-----------------------------------------------------------
 function cts09g02(param)
#-----------------------------------------------------------

 define param        record
    dddcod           like gcakfilial.dddcod ,
    factxt           like gcakfilial.factxt
 end record

 define ws           record
    vez              smallint               ,
    dddcod           char (04)              ,
    faxnum           char (10)
 end record

 define i       smallint



	let	i  =  null

	initialize  ws.*  to  null

 initialize ws.*   to null

 if param.dddcod is null  or
    param.factxt is null  then
    return ws.dddcod, ws.faxnum
 end if

 for i = 1  to  4
    if param.dddcod[i,i] = "0"  or
       param.dddcod[i,i] = "1"  or
       param.dddcod[i,i] = "2"  or
       param.dddcod[i,i] = "3"  or
       param.dddcod[i,i] = "4"  or
       param.dddcod[i,i] = "5"  or
       param.dddcod[i,i] = "6"  or
       param.dddcod[i,i] = "7"  or
       param.dddcod[i,i] = "8"  or
       param.dddcod[i,i] = "9"  then
       let ws.dddcod = ws.dddcod clipped, param.dddcod[i,i]
    end if
 end for

 let ws.vez = 0

 for i = 1  to  20
    if param.factxt[i,i] = "0"  or
       param.factxt[i,i] = "1"  or
       param.factxt[i,i] = "2"  or
       param.factxt[i,i] = "3"  or
       param.factxt[i,i] = "4"  or
       param.factxt[i,i] = "5"  or
       param.factxt[i,i] = "6"  or
       param.factxt[i,i] = "7"  or
       param.factxt[i,i] = "8"  or
       param.factxt[i,i] = "9"  then
       let ws.faxnum = ws.faxnum clipped, param.factxt[i,i]
       let ws.vez = ws.vez + 1
       if ws.vez > 9  then
          exit for
       end if
    else
       if ws.vez > 1  then
          if param.factxt[i,i] <> "-"   then
             exit for
          end if
       end if
    end if
 end for

#if length(ws.dddcod) < 3  or
#if length(ws.dddcod) < 2  or
#   length(ws.faxnum) < 6  then
#   initialize ws.dddcod  to null
#   initialize ws.faxnum  to null
#end if
 if length(ws.dddcod) < 2  then
    initialize ws.dddcod  to null
 end if
 if length(ws.faxnum) < 7  then
    initialize ws.faxnum  to null
 end if
 return ws.dddcod, ws.faxnum

end function  ###  cts09g02
