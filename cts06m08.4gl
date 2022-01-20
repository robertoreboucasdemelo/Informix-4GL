###############################################################################
# Nome do Modulo: CTS06M08                                           Marcelo  #
#                                                                    Gilberto #
# Exibe todas as finalidades para vistoria previa                    Out/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cts06m08()
#-----------------------------------------------------------

 define a_cts06m08 array[20] of record
    cpodes         like iddkdominio.cpodes,
    cpocod         like iddkdominio.cpocod
 end record

 define arr_aux    smallint

 define w_fnlcod   smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	w_fnlcod  =  null

	for	w_pf1  =  1  to  20
		initialize  a_cts06m08[w_pf1].*  to  null
	end	for

 let int_flag = false
 initialize a_cts06m08   to null
 initialize w_fnlcod     to null

 let arr_aux = 1

 declare c_cts06m08_001 cursor for
    select cpodes, cpocod
      from iddkdominio
     where cponom = "vstfld"
     order by cpocod

 foreach c_cts06m08_001 into a_cts06m08[arr_aux].*
    let arr_aux = arr_aux + 1
 end foreach

 if arr_aux > 1  then
    open window w_cts06m08 at 08,42 with form "cts06m08"
                attribute(border, form line first)

    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux - 1)

    display array a_cts06m08 to s_cts06m08.*

       on key (interrupt,control-c)
          initialize a_cts06m08   to null
          initialize w_fnlcod     to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let w_fnlcod = a_cts06m08[arr_aux].cpocod
          exit display

    end display

    let int_flag = false
    close window w_cts06m08
 else
    error "Tabela de finalidades nao encontrada! AVISE A INFORMATICA!"
 end if

 return w_fnlcod

end function  ###  cts06m08
