###############################################################################
# Nome do Modulo: CTN32C00                                                    #
#                                                                   Almeida   #
# Mostra todas Sucursais                                            Maio/1998 #
###############################################################################

database porto
#main
# call ctn32c00()
#end main

#-----------------------------------------------------------
 function ctn32c00()
#-----------------------------------------------------------

 define r_gabksuc record like gabksuc.*

 define a_ctn32c00 array[100] of record
     succod    like gabksuc.succod,
     sucnom    like gabksuc.sucnom
 end record

 define arr_aux    smallint

 define sql        char (100)

 open window ctn32c00 at 10,10 with form "ctn32c00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctn32c00   to null

 declare c_ctn32c00    cursor for
    select succod,sucnom
      from gabksuc
    order by succod

 let arr_aux  = 1

 foreach c_ctn32c00 into a_ctn32c00[arr_aux].succod,
                         a_ctn32c00[arr_aux].sucnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, tabela de sucursais com mais de 100!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctn32c00 to s_ctn32c00.*

    on key (interrupt,control-c)
       initialize a_ctn32c00   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 close window  ctn32c00
 let int_flag = false

 return a_ctn32c00[arr_aux].succod

end function  ###  ctn32c00
