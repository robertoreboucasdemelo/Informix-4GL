##############################################################################
# Nome do Modulo: CTN01C02                                             Pedro #
#                                                                            #
# Consulta Tipos de Guinchos                                        Out/1994 #
##############################################################################

#------------------------------------------------------------
# modulo de consulta da tabela dpckguincho - Tab. de Guinchos
#------------------------------------------------------------

database porto

#---------------------------------------------------------
function ctn01c02()
#---------------------------------------------------------

define a_ctn01c02 array [50] of record
       gchtip     like dpckguincho.gchtip,
       gchdes     like dpckguincho.gchdes
end record

define arr_aux integer


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn01c02[w_pf1].*  to  null
	end	for

open window w_ctn01c02 at 09,20 with form "ctn01c02"
   attribute (border, form line 1)

let int_flag = false

while not int_flag
   declare c_ctn01c02 cursor for
      select
         gchtip,
         gchdes
      from dpckguincho

   let arr_aux = 1
   foreach c_ctn01c02 into a_ctn01c02[arr_aux].*
      let arr_aux = arr_aux + 1

      if arr_aux > 100  then
         error "Limite de consulta excedido(100). Avise a informatica!"
         sleep 3
         exit foreach
      end if
   end foreach

   message " (F17)Abandona, (F8)Seleciona"

   call set_count(arr_aux-1)

   display array a_ctn01c02 to dpckguincho.*
      on key (interrupt,control-c)
         initialize a_ctn01c02 to null
         exit display

      on key (f8)
         let int_flag = true
         exit display
   end display
end while

let int_flag = false
let arr_aux = arr_curr()

close window w_ctn01c02

return a_ctn01c02[arr_aux].gchtip, a_ctn01c02[arr_aux].gchdes

end function
