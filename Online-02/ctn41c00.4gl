###############################################################################
# Nome do Modulo: ctn41c00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de congeneres (seguradoras)                                 Out/1998 #
###############################################################################

 database porto

#-----------------------------------------------------------
 function ctn41c00()
#-----------------------------------------------------------

 define a_ctn41c00 array[200] of record
    sgdnom            like gcckcong.sgdnom,
    sgdirbcod         like gcckcong.sgdirbcod
 end record

 define ws            record
    sgdirbcod         like gcckcong.sgdirbcod
 end record

 define arr_aux    smallint


 initialize ws.*         to null
 initialize a_ctn41c00   to null
 let int_flag = false
 let arr_aux  = 1

 declare c_ctn41c00 cursor for
    select sgdnom,
           sgdirbcod
      from gcckcong
     where gcckcong.sgdirbcod  >  0
     order by sgdnom

 foreach c_ctn41c00 into a_ctn41c00[arr_aux].sgdnom,
                         a_ctn41c00[arr_aux].sgdirbcod

    let arr_aux = arr_aux + 1

    if arr_aux > 200  then
       error " Limite excedido. Existem mais de 200 seguradoras cadastradas!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctn41c00 at 10,28 with form "ctn41c00"
         attribute(form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctn41c00 to s_ctn41c00.*

       on key (interrupt,control-c)
          initialize a_ctn41c00    to null
          initialize ws.sgdirbcod  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.sgdirbcod = a_ctn41c00[arr_aux].sgdirbcod
          exit display

    end display

    let int_flag = false
    close window ctn41c00
 else
    initialize ws.sgdirbcod  to null
    error " Nao existem seguradoras cadastradas!"
 end if

 return ws.sgdirbcod

end function  ###  ctn41c00
