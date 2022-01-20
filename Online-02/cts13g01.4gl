###############################################################################
# Nome do Modulo: cts13g01                                           Gilberto #
#                                                                     Marcelo #
# Consulta observacoes do bloqueio                                   Mai/1998 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cts13g01(param)
#-----------------------------------------------------------

 define param       record
    blqnum          like datkblq.blqnum
 end record

 define a_cts13g01  array[30] of record
    blqobstxt       like datmblqobs.blqobstxt
 end record

 define arr_aux    integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cts13g01[w_pf1].*  to  null
	end	for

 initialize  a_cts13g01   to null
 let int_flag = false
 let arr_aux  = 1

 declare c_cts13g01_001  cursor for
   select blqobstxt
     from datmblqobs
    where blqnum = param.blqnum

 foreach c_cts13g01_001 into a_cts13g01[arr_aux].blqobstxt

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, bloqueio c/ mais de 30 linhas de observacoes!"
       exit foreach
    end if

 end foreach

 if arr_aux  >  1    then

    open window cts13g01 at 10,15 with form "cts13g01"
         attribute(form line 1, border)

    display by name param.blqnum
    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array a_cts13g01 to s_cts13g01.*

       on key (interrupt,control-c)
          exit display

    end display

    let int_flag = false
    close window  cts13g01
    close c_cts13g01_001
 else
    error " Nao existe observacao cadastrada para este bloqueio!"
 end if

end function  ##--  cts13g01
