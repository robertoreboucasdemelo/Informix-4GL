###############################################################################
# Nome do Modulo: ctn23c00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de prestadores que possuem veiculos controlados pelo radio  Set/1998 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn23c00()
#-----------------------------------------------------------

 define a_ctn23c00 array[300] of record
    pstcoddig         like datkveiculo.pstcoddig,
    nomgrr            like dpaksocor.nomgrr
 end record

 define ws            record
    pstcoddig         like datkveiculo.pstcoddig
 end record

 define arr_aux    smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  300
		initialize  a_ctn23c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*         to null
 initialize a_ctn23c00   to null
 let int_flag = false
 let arr_aux  = 1

 declare c_ctn23c00_001 cursor for
    select pstcoddig
      from datkveiculo
     where datkveiculo.socoprsitcod  =  1
       and datkveiculo.socctrposflg  = "S"
    group by datkveiculo.pstcoddig

 foreach c_ctn23c00_001 into a_ctn23c00[arr_aux].pstcoddig

    initialize a_ctn23c00[arr_aux].nomgrr  to null

    select dpaksocor.nomgrr
      into a_ctn23c00[arr_aux].nomgrr
      from dpaksocor
     where dpaksocor.pstcoddig = a_ctn23c00[arr_aux].pstcoddig

    let arr_aux = arr_aux + 1

    if arr_aux > 300  then
       error " Limite excedido. Existem mais de 300 prestadores cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctn23c00 at 10,20 with form "ctn23c00"
         attribute(form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctn23c00 to s_ctn23c00.*

       on key (interrupt,control-c)
          initialize a_ctn23c00    to null
          initialize ws.pstcoddig  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.pstcoddig = a_ctn23c00[arr_aux].pstcoddig
          exit display

    end display

    let int_flag = false
    close window ctn23c00
 else
    initialize ws.pstcoddig  to null
    error " Nao existem prestadores cadastrados!"
 end if

 return ws.pstcoddig

end function  ###  ctn23c00
