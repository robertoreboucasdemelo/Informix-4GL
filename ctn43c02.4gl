 ##############################################################################
 # Nome do Modulo: ctn43c02                                          Marcelo  #
 #                                                                   Gilberto #
 # Consulta mensagens(texto) enviadas para MDT's                     Ago/1999 #
 ##############################################################################

 database porto

#------------------------------------------------------------
 function ctn43c02(param)
#------------------------------------------------------------

 define param        record
    mdtmsgnum        like datmmdtmsgtxt.mdtmsgnum
 end record

 define a_ctn43c02   array[80]   of record
    mdtmsgtxt        char (50)
 end record

 define ws           record
    mdtmsgtxt        like datmmdtmsgtxt.mdtmsgtxt
 end record

 define arr_aux      smallint
 define ws_totpos    smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	ws_totpos  =  null

	for	w_pf1  =  1  to  80
		initialize  a_ctn43c02[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_ctn43c02   to null
 initialize ws.*         to null
 let int_flag = false
 let arr_aux  = 1

 open window w_ctn43c02 at  06,02 with form "ctn43c02"
             attribute(form line first)

 display by name param.mdtmsgnum

 declare c_ctn43c02_001 cursor for
    select mdtmsgtxt
      from datmmdtmsgtxt
     where mdtmsgnum = param.mdtmsgnum

 foreach  c_ctn43c02_001  into  ws.mdtmsgtxt

    for ws_totpos = 1 to 2000

      initialize a_ctn43c02[arr_aux].mdtmsgtxt  to null
      let a_ctn43c02[arr_aux].mdtmsgtxt = ws.mdtmsgtxt[ws_totpos, ws_totpos+49]
      let ws_totpos = ws_totpos + 49

      if a_ctn43c02[arr_aux].mdtmsgtxt  = "  "    or
         a_ctn43c02[arr_aux].mdtmsgtxt  is null   then
         exit for
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 81  then
         error " Limite excedido, mensagem com mais de 4000 caracteres!"
         exit foreach
      end if

    end for

 end foreach

 if arr_aux  =  1   then
    error " Nao foi informado texto para mensagem, AVISE INFORMATICA!"
 end if

 message " (F17)Abandona"

 call set_count(arr_aux-1)

 display array  a_ctn43c02 to s_ctn43c02.*
    on key (interrupt)
       exit display
 end display

 let int_flag = false
 close window  w_ctn43c02

end function   ###--- ctn43c02
