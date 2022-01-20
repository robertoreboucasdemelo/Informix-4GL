##############################################################################
# Nome do Modulo: CTN06C03                                             Pedro #
#                                                                            #
# Consulta Tipos de Servicos                                        Out/1994 #
##############################################################################

database porto

#---------------------------------------------------------
 function ctn06c03()
#---------------------------------------------------------

define a_ctn06c03 array [500] of record
   pstsrvtip      like dpckserv.pstsrvtip,
   pstsrvdes      like dpckserv.pstsrvdes
end record

define arr_aux smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctn06c03[w_pf1].*  to  null
	end	for

open window w_ctn06c03 at 09,20 with form "ctn06c03"
   attribute (border, form line 1)

let int_flag = false

while not int_flag
   declare c_ctn06c03_001 cursor for
      select pstsrvtip,
             pstsrvdes
        from dpckserv
       order by pstsrvdes

   let arr_aux = 1
   foreach c_ctn06c03_001 into a_ctn06c03[arr_aux].*
      let arr_aux = arr_aux + 1

      if arr_aux > 500   then
         error "Limite de consulta excedido. AVISE A INFORMATICA!"
         exit foreach
      end if
   end foreach

   message " (F17)Abandona, (F8)Seleciona"

   call set_count(arr_aux-1)

   display array a_ctn06c03 to dpckserv.*
      on key (interrupt,control-c)
         initialize a_ctn06c03 to null
         exit display

      on key (F8)
         let int_flag = true
         exit display
   end display
end while

let int_flag = false
let arr_aux = arr_curr()

close window w_ctn06c03

return a_ctn06c03[arr_aux].pstsrvtip, a_ctn06c03[arr_aux].pstsrvdes

end function

