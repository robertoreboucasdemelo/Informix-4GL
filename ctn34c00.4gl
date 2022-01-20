###############################################################################
# Nome do Modulo: CTN33C00                                                    #
#                                                                   Almeida   #
# Mostra todas Classes de localizacao                               Maio/1998 #
###############################################################################

database porto
#main
# call ctn34c00()
#end main

#-----------------------------------------------------------
 function ctn34c00()
#-----------------------------------------------------------

 define r_agekregiao record like agekregiao.*

 define a_ctn34c00 array[100] of record
     clalclcod    like agekregiao.clalclcod,
     clalcldes    like agekregiao.clalcldes
 end record

 define arr_aux    smallint

 define sql        char (100)

 open window ctn34c00 at 08,08 with form "ctn34c00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctn34c00   to null

 declare c_ctn34c00    cursor for
    select clalclcod,clalcldes
      from agekregiao
    order by clalclcod

 let arr_aux  = 1

 foreach c_ctn34c00 into a_ctn34c00[arr_aux].clalclcod,
                         a_ctn34c00[arr_aux].clalcldes

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, tabela de ramursais com mais de 100!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctn34c00 to s_ctn34c00.*

    on key (interrupt,control-c)
       initialize a_ctn34c00   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 close window  ctn34c00
 let int_flag = false

 return a_ctn34c00[arr_aux].clalclcod

end function  ###  ctn34c00
