##############################################################################
# Nome do Modulo: CTN06C08                                             Pedro #
#                                                                    Marcelo #
# Mostra todos os servicos de um prestador                          Ago/1995 #
##############################################################################

database porto

#---------------------------------------------------------
function ctn06c08(par_pstcoddig)
#---------------------------------------------------------

define a_ctn06c08    array [50] of record
       pstsrvtip     like dpckserv.pstsrvtip,
       pstsrvdes     like dpckserv.pstsrvdes
end record

define par_pstcoddig like dpaksocor.pstcoddig
define arr_aux       integer


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn06c08[w_pf1].*  to  null
	end	for

open window w_ctn06c08 at 09,23 with form "ctn06c03"
   attribute (border, form line 1)

let int_flag = false

while not int_flag
   declare c_ctn06c08_001 cursor for
      select
             dpatserv.pstsrvtip,
             pstsrvdes
        from dpatserv, dpckserv
       where dpatserv.pstcoddig = par_pstcoddig      and
             dpckserv.pstsrvtip = dpatserv.pstsrvtip

   let arr_aux = 1
   foreach c_ctn06c08_001 into a_ctn06c08[arr_aux].*
      let arr_aux = arr_aux + 1

      if arr_aux > 50   then
         error "Limite de consulta excedido. Avise a informatica!"
         exit foreach
      end if
   end foreach

   message " (F17)Abandona"

   call set_count(arr_aux-1)

   display array a_ctn06c08 to dpckserv.*
      on key (interrupt,control-c)
         initialize a_ctn06c08 to null
         exit display

   end display
end while

let int_flag = false

close window w_ctn06c08

return

end function

