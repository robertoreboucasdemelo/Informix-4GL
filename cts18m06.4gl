###############################################################################
# Nome do Modulo: CTS18M06                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de vinculos com segurado                                    Ago/1997 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cts18m06()
#-----------------------------------------------------------

 define a_cts18m06 array[20] of record
    cpocod         like iddkdomsin.cpocod,
    cpodes         like iddkdomsin.cpodes
 end record

 define arr_aux       smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  20
		initialize  a_cts18m06[w_pf1].*  to  null
	end	for

 open window w_cts18m06 at 08,56 with form "cts18m06"
                        attribute (border, form line first)

 message " (F8) Seleciona"

 let arr_aux = 1

 declare c_cts18m06_001 cursor for
    select cpocod, cpodes
      from iddkdomsin
     where cponom = "sinsgrvin"
     order by cpodes

 foreach c_cts18m06_001 into a_cts18m06[arr_aux].cpocod,
                         a_cts18m06[arr_aux].cpodes

    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error "Limite excedido! Foram encontrados mais de 20 tipos de vinculo!"
       exit foreach
    end if
 end foreach

 if arr_aux = 1  then
    error "Nao foi encontrado nenhum tipo de vinculo!"
 else
    call set_count(arr_aux - 1)

    display array a_cts18m06 to s_cts18m06.*
       on key (F8)
          let arr_aux = arr_curr()
          exit display

       on key (interrupt, control-c)
          let arr_aux = arr_curr()
          initialize a_cts18m06[arr_aux].* to null
          exit display
    end display
 end if

 close window w_cts18m06

 let int_flag = false

 return a_cts18m06[arr_aux].cpocod, a_cts18m06[arr_aux].cpodes

end function  ###  cts18m06
