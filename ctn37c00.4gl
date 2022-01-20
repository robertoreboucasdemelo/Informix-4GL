###############################################################################
# Nome do Modulo: ctn37c00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de equipamentos para veiculos de assistencia                Set/1998 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn37c00()
#-----------------------------------------------------------

 define a_ctn37c00 array[200] of record
    soceqpdes      like datkvcleqp.soceqpdes,
    soceqpcod      like datkvcleqp.soceqpcod
 end record

 define ws         record
    soceqpcod      like datkvcleqp.soceqpcod
 end record

 define arr_aux    smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn37c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*         to null
 initialize a_ctn37c00   to null
 let int_flag = false
 let arr_aux  = 1

 declare c_ctn37c00_001 cursor for
    select soceqpdes, soceqpcod
      from datkvcleqp
     where datkvcleqp.soceqpstt = "A"
     order by soceqpdes

 foreach c_ctn37c00_001 into a_ctn37c00[arr_aux].soceqpdes,
                         a_ctn37c00[arr_aux].soceqpcod

    let arr_aux = arr_aux + 1

    if arr_aux > 200  then
       error " Limite excedido. Existem mais de 200 equipamentos cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctn37c00 at 10,20 with form "ctn37c00"
         attribute(form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctn37c00 to s_ctn37c00.*

       on key (interrupt,control-c)
          initialize a_ctn37c00    to null
          initialize ws.soceqpcod  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.soceqpcod = a_ctn37c00[arr_aux].soceqpcod
          exit display

    end display

    let int_flag = false
    close window ctn37c00
 else
    initialize ws.soceqpcod to null
    error " Nao existem equipamentos cadastrados!"
 end if

 return ws.soceqpcod

end function  ###  ctn37c00
