#############################################################################
# Nome do Modulo: CTS14M04                                            Pedro #
#                                                                   Marcelo #
# Pop-up de horario de regioes                                     Jun/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 08/12/1998  PSI 7265-6   Gilberto     Incluir criticas referentes a data  #
#                                       de marcacao da vistoria de sinistro #
#############################################################################

 database porto

#-----------------------------------------------------------------------
 function cts14m04(param)
#-----------------------------------------------------------------------

 define param       record
    succod          like gkpkregi.succod,
    ofnrgicod       like gkpkregi.ofnrgicod,
    vstretflg       like datmvstsin.vstretflg
 end record

 define a_cts14m04  array[07] of record
    vstdat          date,
    dianum          dec (1,0),
    diasem          char (07)
 end record

 define d_cts14m04  record
    vstsegflg       like gkpkregi.vstsegflg,
    vstterflg       like gkpkregi.vstterflg,
    vstquaflg       like gkpkregi.vstquaflg,
    vstquiflg       like gkpkregi.vstquiflg,
    vstsexflg       like gkpkregi.vstsexflg,
    vstsabflg       like gkpkregi.vstsabflg,
    vstdomflg       like gkpkregi.vstdomflg
 end record

 define ws          record
    hojdat          date,
    utldat          date
 end record

 define arr_aux     smallint
 define i           smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	i  =  null

	for	w_pf1  =  1  to  7
		initialize  a_cts14m04[w_pf1].*  to  null
	end	for

	initialize  d_cts14m04.*  to  null

	initialize  ws.*  to  null

 initialize a_cts14m04    to null
 initialize d_cts14m04.*  to null
 initialize ws.*          to null

 let int_flag   = false
 let arr_aux    = 1

 let ws.hojdat = today

 if weekday(ws.hojdat) = 6  or    ###  Marcando vistoria no sabado
    weekday(ws.hojdat) = 0  then  ###  Marcando vistoria no domingo
    let ws.hojdat = dias_uteis(ws.hojdat, +1, "", "N", "N")
 end if

#--------------------------------------------------------------------
# Marcando vistoria em feriado
#--------------------------------------------------------------------

 call dias_uteis(ws.hojdat, 0, "", "N", "N")
       returning ws.utldat

 if ws.utldat is not null  and
    ws.utldat <> ws.hojdat then
    let ws.hojdat = dias_uteis(ws.hojdat, +1, "", "N", "N")
 end if

 if time > "18:30:00"  then
    let ws.hojdat = dias_uteis(ws.hojdat, +1, "", "N", "N")
 end if

 if param.vstretflg = "S"  then
    if time     > "18:00:00"    then
       let ws.hojdat = ws.hojdat + 1 units day

       if weekday(ws.hojdat) = 5  then  ###  Marcando retorno na sexta
          let ws.hojdat = ws.hojdat + 3 units day
       end if
    end if
 end if

 select vstsegflg, vstterflg,
        vstquaflg, vstquiflg,
        vstsexflg, vstsabflg,
        vstdomflg
   into d_cts14m04.vstsegflg,
        d_cts14m04.vstterflg,
        d_cts14m04.vstquaflg,
        d_cts14m04.vstquiflg,
        d_cts14m04.vstsexflg,
        d_cts14m04.vstsabflg,
        d_cts14m04.vstdomflg
   from gkpkregi
  where succod    = param.succod     and
        ofnrgicod = param.ofnrgicod

 if sqlca.sqlcode <> 0  then
    error " Dias para vistoria nao definidos para SUCURSAL ", param.succod, "/REGIAO ", param.ofnrgicod, "!"
    return a_cts14m04[arr_aux].vstdat
 end if

 for i = 01 to 07
    let a_cts14m04[arr_aux].vstdat = ws.hojdat + i units day
    let a_cts14m04[arr_aux].dianum = weekday(a_cts14m04[arr_aux].vstdat)

    if dias_uteis(a_cts14m04[arr_aux].vstdat, 0, "", "N", "N") = a_cts14m04[arr_aux].vstdat  then
       case a_cts14m04[arr_aux].dianum
          when 0  if d_cts14m04.vstdomflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Domingo"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
          when 1  if d_cts14m04.vstsegflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Segunda"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
          when 2  if d_cts14m04.vstterflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Terca"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
          when 3  if d_cts14m04.vstquaflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Quarta"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
          when 4  if d_cts14m04.vstquiflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Quinta"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
          when 5  if d_cts14m04.vstsexflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Sexta"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
          when 6  if d_cts14m04.vstsabflg = "S"  then
                     let a_cts14m04[arr_aux].diasem = "Sabado"
                     let arr_aux = arr_aux + 1
                  else
                     initialize a_cts14m04[arr_aux].*  to null
                  end if
       end case
    end if
 end for

 if arr_aux = 1  then
    error " Dias para vistoria nao definidos para SUCURSAL ", param.succod, "/REGIAO ", param.ofnrgicod, "!"
    return a_cts14m04[arr_aux].vstdat
 end if

 open window cts14m04 at 11,49 with form "cts14m04"
      attribute(border, form line first)

 call set_count(arr_aux - 1)
 message " (F8)Seleciona"

 display array a_cts14m04 to s_cts14m04.*
      on key (interrupt)
         initialize a_cts14m04  to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display
 end display

 let int_flag = false
 close window cts14m04

 return a_cts14m04[arr_aux].vstdat

 end function  ###  cts14m04
