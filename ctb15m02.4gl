###############################################################################
# Nome do Modulo: CTB15M02                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Pop-up de Fases dos eventos de analise de servicos                 Nov/1999 #
###############################################################################

 database porto

#---------------------------------------------------------------
 function ctb15m02()
#---------------------------------------------------------------

 define a_ctb15m02 array[20] of record
    c24fsecod      like datkfse.c24fsecod,
    c24fsedes      like datkfse.c24fsedes
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 initialize a_ctb15m02  to null
 let arr_aux = 1

 open window w_ctb15m02 at 10,33 with form "ctb15m02"
      attribute(form line first, border)

 declare c_datkfse cursor for
  select c24fsecod, c24fsedes
    from datkfse

 foreach c_datkfse into a_ctb15m02[arr_aux].c24fsecod,
                        a_ctb15m02[arr_aux].c24fsedes

    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error " Limite excedido. Foram encontradas mais de 20 fases!"
       exit foreach
    end if
 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctb15m02 to s_ctb15m02.*
    on key (interrupt,control-c)
       initialize a_ctb15m02   to null
       exit display

   on key (F8)
      let arr_aux = arr_curr()
      exit display
 end display

 close window  w_ctb15m02
 let int_flag = false

 return a_ctb15m02[arr_aux].c24fsecod

end function  ###  ctb15m02
