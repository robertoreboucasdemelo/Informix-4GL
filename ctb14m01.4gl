###############################################################################
# Nome do Modulo: CTB14M01                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Pop-up de Eventos de analise de servicos                           Nov/1999 #
###############################################################################

 database porto

#---------------------------------------------------------------
 function ctb14m01()
#---------------------------------------------------------------

 define a_ctb14m01 array[30] of record
    c24evtcod      like datkevt.c24evtcod,
    c24evtrdzdes   like datkevt.c24evtrdzdes
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 initialize a_ctb14m01  to null
 let arr_aux = 1

 open window w_ctb14m01 at 10,33 with form "ctb14m01"
      attribute(form line first, border)

 declare c_datkevt cursor for
  select c24evtcod, c24evtrdzdes
    from datkevt
   where c24evtstt = "A"

 foreach c_datkevt into a_ctb14m01[arr_aux].c24evtcod,
                        a_ctb14m01[arr_aux].c24evtrdzdes

    let arr_aux = arr_aux + 1

    if arr_aux > 30  then
       error " Limite excedido. Foram encontradas mais de 30 eventos!"
       exit foreach
    end if
 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctb14m01 to s_ctb14m01.*
    on key (interrupt,control-c)
       initialize a_ctb14m01   to null
       exit display

   on key (F8)
      let arr_aux = arr_curr()
      exit display
 end display

 close window  w_ctb14m01
 let int_flag = false

 return a_ctb14m01[arr_aux].c24evtcod

end function  ###  ctb14m01
