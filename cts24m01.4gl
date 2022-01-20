###############################################################################
# Nome do Modulo: ctS24M01                                           Wagner   #
#                                                                             #
# Pop-up de Mensagens teletrim                                       Jan/2001 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cts24m01()
#-----------------------------------------------------------

 define a_cts24m01 array[30] of record
    tltmsgcod      like datktltmsg.tltmsgcod,
    tltmsgtxt1     char(50),
    tltmsgtxt2     char(50)
 end record

 define ws         record
    tltmsgcod      like datktltmsg.tltmsgcod,
    tltmsgtxt      like datktltmsg.tltmsgtxt
 end record

 define arr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cts24m01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false

 let arr_aux  = 1
 initialize a_cts24m01   to null

 declare c_cts24m01_001 cursor for
    select tltmsgcod, tltmsgtxt
      from datktltmsg
     where tltmsgcod <> 0
       and tltmsgstt = "A"
     order by tltmsgcod

 foreach c_cts24m01_001 into a_cts24m01[arr_aux].tltmsgcod,
                         ws.tltmsgtxt

    let a_cts24m01[arr_aux].tltmsgtxt1 = ws.tltmsgtxt[1,50]
    let a_cts24m01[arr_aux].tltmsgtxt2 = ws.tltmsgtxt[51,100]

    let arr_aux = arr_aux + 1

    if arr_aux > 30  then
       error " Limite excedido. Foram encontrados mais de 30 mansagens para teletrim!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window cts24m01 at 12,22 with form "cts24m01"
                         attribute(form line 1, border)

    message " (F17)Abandona  (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_cts24m01 to s_cts24m01.*

       on key (interrupt,control-c)
          initialize a_cts24m01   to null
          initialize ws.tltmsgcod to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.tltmsgcod = a_cts24m01[arr_aux].tltmsgcod
          exit display

    end display

    let int_flag = false
    close window cts24m01
 else
    initialize ws.tltmsgcod to null
    error " Nao foi encontrada nenhua mensagem para teletrim!"
 end if

 return ws.tltmsgcod

end function  ###  cts24m01
