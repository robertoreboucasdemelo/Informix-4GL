###############################################################################
# Nome do Modulo: CTC30M01                                           Marcelo  #
#                                                                    Gilberto #
# Exibe pop-up para selecao da locadora                              Ago/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc30m01()
#-----------------------------------------------------------

   define a_ctc30m01 array[300] of record
      lcvnom         like datklocadora.lcvnom,
      lcvcod         like datklocadora.lcvcod
   end record

   define ws         record
      lcvcod         like datklocadora.lcvcod,
      lcvstt         like datklocadora.lcvstt
   end record

   define arr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  300
		initialize  a_ctc30m01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   open window ctc30m01 at 08,18 with form "ctc30m01"
                        attribute(form line 1, border)

   let int_flag = false
   initialize a_ctc30m01   to null
   initialize ws.*         to null

   declare c_ctc30m01 cursor for
     select lcvcod, lcvnom, lcvstt
       from datklocadora
      order by lcvnom

   let arr_aux  = 1

   foreach c_ctc30m01 into a_ctc30m01[arr_aux].lcvcod,
                           a_ctc30m01[arr_aux].lcvnom,
                           ws.lcvstt

      if ws.lcvstt <> "A"  then
         continue foreach
      end if

      let arr_aux = arr_aux + 1

      if arr_aux  >  300   then
         error "Limite excedido. Foram encontradas mais de 300 locadoras!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctc30m01 to s_ctc30m01.*

      on key (interrupt,control-c)
         initialize a_ctc30m01   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ws.lcvcod = a_ctc30m01[arr_aux].lcvcod
         exit display

   end display

   let int_flag = false
   close window ctc30m01

   return ws.lcvcod

end function  ###  ctc30m01
