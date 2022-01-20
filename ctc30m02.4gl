###############################################################################
# Nome do Modulo: CTC30M02                                           Wagner   #
# Exibe pop-up para selecao da lojas                                 Out/2000 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc30m02(param_lcvcod)
#-----------------------------------------------------------

   define param_lcvcod like datklocadora.lcvcod

   define a_ctc30m02 array[200] of record
      aviestnom      like datkavislocal.aviestnom,
      aviestcod      like datkavislocal.aviestcod,
      lcvextcod      like datkavislocal.lcvextcod
   end record

   define ws         record
      lcvextcod      like datkavislocal.lcvextcod,
      aviestcod      like datkavislocal.aviestcod,
      vclalglojstt   like datkavislocal.vclalglojstt
   end record

   define arr_aux    smallint

   open window ctc30m02 at 08,18 with form "ctc30m02"
                        attribute(form line 1, border)

   let int_flag = false
   initialize a_ctc30m02   to null
   initialize ws.*         to null

   declare c_ctc30m02 cursor for
     select aviestnom, aviestcod, lcvextcod, vclalglojstt
       from datkavislocal
      where lcvcod       = param_lcvcod
        and lcvextcod    is not null
      order by aviestnom, lcvextcod

   let arr_aux  = 1

   foreach c_ctc30m02 into a_ctc30m02[arr_aux].aviestnom,
                           a_ctc30m02[arr_aux].aviestcod,
                           a_ctc30m02[arr_aux].lcvextcod,
                           ws.vclalglojstt

      if ws.vclalglojstt <> 1    then
         continue foreach
      end if

      let arr_aux = arr_aux + 1

      if arr_aux  >  200 then
         error "Limite excedido. Foram encontradas mais de 200 lojas para esta Locadora!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctc30m02 to s_ctc30m02.*

      on key (interrupt,control-c)
         initialize a_ctc30m02   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ws.lcvextcod = a_ctc30m02[arr_aux].lcvextcod
         let ws.aviestcod = a_ctc30m02[arr_aux].aviestcod
         exit display

   end display

   let int_flag = false
   close window ctc30m02

   return ws.lcvextcod

end function  ###  ctc30m02
