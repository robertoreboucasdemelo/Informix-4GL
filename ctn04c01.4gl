############################################################################
# Nome do Modulo: CTN04C01                                        Marcelo  #
#                                                                 Gilberto #
# Pop-up para selecao do regulador de sinistro de transportes     Jun/1997 #
############################################################################

database porto
#---------------------------------------------------------------
 function ctn04c01(param)
#---------------------------------------------------------------

 define param       record
    endufd          like sstkprest.endufd,
    endcid          like sstkprest.endcid
 end record

 define a_ctn04c01  array[200] of record
    endufd          like sstkprest.endufd,
    endcid          like sstkprest.endcid,
    sinprscod       like sstkprest.sinprscod,
    sinprsnom       like sstkprest.sinprsnom
 end record

 define arr_aux     smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn04c01[w_pf1].*  to  null
	end	for

 initialize a_ctn04c01  to null

 declare c_ctn04c01 cursor for
    select endufd   , endcid,
           sinprscod, sinprsnom
      from sstkprest
     where endufd    =    param.endufd  and
           endcid matches param.endcid
     order by endufd, endcid, sinprsnom

 let arr_aux = 1

 foreach c_ctn04c01 into a_ctn04c01[arr_aux].*

    let arr_aux = arr_aux + 1

    if arr_aux > 200  then
       error "Limite de consulta excedido. AVISE A INFORMATICA!"
       exit foreach
    end if
 end foreach

 if arr_aux > 1  then
    open window w_ctn04c01 at 08,12 with form "ctn04c01"
                 attribute (form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux - 1)

    display array a_ctn04c01 to s_ctn04c01.*
       on key (interrupt,control-c)
          initialize a_ctn04c01[arr_aux].* to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          exit display
    end display

    close window w_ctn04c01
 end if

 return a_ctn04c01[arr_aux].sinprscod

end function  #  ctn04c01
