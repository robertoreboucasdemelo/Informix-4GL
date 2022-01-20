###############################################################################
# Nome do Modulo: CTS18M05                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de profissoes                                               Ago/1997 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cts18m05(param)
#-----------------------------------------------------------

 define param         record
    irfprfdes         like ssakprf.irfprfdes
 end record

 define d_cts18m05    record
    irfprfcod         like ssakprf.irfprfcod       ,
    irfprfdes         like ssakprf.irfprfdes
 end record

 define ws            record
    irfprfdes         char (51)
 end record

 define a_cts18m05 array[200] of record
    irfprfcod         like ssakprf.irfprfcod       ,
    irfprfdes         like ssakprf.irfprfdes
 end record

 define arr_aux       smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts18m05[w_pf1].*  to  null
	end	for

	initialize  d_cts18m05.*  to  null

	initialize  ws.*  to  null

 initialize a_cts18m05  to null
 initialize ws.*        to null

 let d_cts18m05.irfprfdes = param.irfprfdes

 if d_cts18m05.irfprfdes is not null  then
    select irfprfcod
      into d_cts18m05.irfprfcod
      from ssakprf
     where irfprfdes = d_cts18m05.irfprfdes

    if sqlca.sqlcode = 0  then
       return d_cts18m05.*
    end if

    let ws.irfprfdes = d_cts18m05.irfprfdes clipped, "*"

    open window w_cts18m05 at 08,22 with form "cts18m05"
                           attribute (border, form line first)

    message " (F17)Abandona, (F8)Seleciona"

    let arr_aux = 1

    declare c_cts18m05_001 cursor for
       select irfprfcod, irfprfdes
         from ssakprf
        where irfprfcod = 999           or
              irfprfdes matches ws.irfprfdes
        order by irfprfdes

    foreach c_cts18m05_001 into a_cts18m05[arr_aux].irfprfcod,
                            a_cts18m05[arr_aux].irfprfdes

       let arr_aux = arr_aux + 1

       if arr_aux > 200  then
          error "Limite excedido! Foram encontradas mais de 200 profissoes!"
          exit foreach
       end if
    end foreach

    if arr_aux = 1  then
       error "Nao foi encontrada nenhuma profissao!"
    else
       call set_count(arr_aux - 1)

       display array a_cts18m05 to s_cts18m05.*
          on key (F8)
             let arr_aux = arr_curr()
             let d_cts18m05.irfprfcod = a_cts18m05[arr_aux].irfprfcod
             let d_cts18m05.irfprfdes = a_cts18m05[arr_aux].irfprfdes
             exit display

          on key (interrupt, control-c)
             initialize d_cts18m05.* to null
             exit display
       end display
    end if
 end if

 close window w_cts18m05

 let int_flag = false

 return d_cts18m05.*

end function  ###  cts18m05
