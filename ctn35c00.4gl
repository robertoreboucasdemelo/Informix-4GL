###############################################################################
# Nome do Modulo: ctn35c00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up fabricantes de equipamentos para veiculos de assistencia    Ago/1998 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn35c00()
#-----------------------------------------------------------

 define a_ctn35c00 array[50] of record
    eqpfabnom      like datkeqpfab.eqpfabnom,
    eqpfabcod      like datkeqpfab.eqpfabcod
 end record

 define ws         record
    eqpfabcod      like datkeqpfab.eqpfabcod
 end record

 define arr_aux    smallint


 initialize ws.*         to null
 initialize a_ctn35c00   to null
 let int_flag = false
 let arr_aux  = 1

 declare c_ctn35c00 cursor for
    select eqpfabnom, eqpfabcod
      from datkeqpfab
     where datkeqpfab.eqpfabstt = "A"
     order by eqpfabnom

 foreach c_ctn35c00 into a_ctn35c00[arr_aux].eqpfabnom,
                         a_ctn35c00[arr_aux].eqpfabcod

    let arr_aux = arr_aux + 1

    if arr_aux > 50  then
       error " Limite excedido. Existem mais de 50 fabricantes cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctn35c00 at 10,20 with form "ctn35c00"
         attribute(form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctn35c00 to s_ctn35c00.*

       on key (interrupt,control-c)
          initialize a_ctn35c00    to null
          initialize ws.eqpfabcod  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.eqpfabcod = a_ctn35c00[arr_aux].eqpfabcod
          exit display

    end display

    let int_flag = false
    close window ctn35c00
 else
    initialize ws.eqpfabcod to null
    error " Nao existem fabricantes cadastrados!"
 end if

 return ws.eqpfabcod

end function  ###  ctn35c00
