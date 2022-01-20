###############################################################################
# Nome do Modulo: CTB18M02                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Pop-up de Cronograma de datas de entrega                           Dez/1999 #
###############################################################################

 database porto

#---------------------------------------------------------------
 function ctb18m02()
#---------------------------------------------------------------

 define a_ctb18m02 array[30] of record
    crnpgtcod      like dbsmcrnpgt.crnpgtcod,
    crnpgtdes      like dbsmcrnpgt.crnpgtdes
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 initialize a_ctb18m02  to null
 let arr_aux = 1

 open window w_ctb18m02 at 10,33 with form "ctb18m02"
      attribute(form line first, border)

 declare c_dbsmcrnpgt cursor for
  select crnpgtcod, crnpgtdes
    from dbsmcrnpgt
   where crnpgtstt = "A"

 foreach c_dbsmcrnpgt into a_ctb18m02[arr_aux].crnpgtcod,
                           a_ctb18m02[arr_aux].crnpgtdes

    let arr_aux = arr_aux + 1

    if arr_aux > 30  then
       error " Limite excedido. Foram encontradas mais de 30 cronogramas!"
       exit foreach
    end if
 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctb18m02 to s_ctb18m02.*
    on key (interrupt,control-c)
       initialize a_ctb18m02   to null
       exit display

   on key (F8)
      let arr_aux = arr_curr()
      exit display
 end display

 close window  w_ctb18m02
 let int_flag = false

 return a_ctb18m02[arr_aux].crnpgtcod

end function  ###  ctb18m02
