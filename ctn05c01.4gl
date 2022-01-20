##############################################################################
# Nome do Modulo: CTN05C01                                             Pedro #
#                                                                            #
# Consulta Dispositivos de seguranca                                Set/1994 #
##############################################################################

#---------------------------------------------------------
# modulo de consulta da tabela agckdisp - tab. dispositivos
#---------------------------------------------------------

database porto

#---------------------------------------------------------
function ctn05c01()
#---------------------------------------------------------

define a_ctn05c01 array [400] of record
   discoddig      like agckdisp.discoddig,
   disnom         like agckdisp.disnom
end record
define w_count integer
define arr_aux integer


	define	w_pf1	integer

	let	w_count  =  null
	let	arr_aux  =  null

	for	w_pf1  =  1  to  400
		initialize  a_ctn05c01[w_pf1].*  to  null
	end	for

open window w_ctn05c01 at 08,15 with form "ctn05c01"
   attribute (border, form line 1)

let int_flag = false

while not int_flag
   declare c_ctn05c01 cursor for
      select
         discoddig,
         disnom
      from agckdisp
           order by 2

   let arr_aux = 1
   foreach c_ctn05c01 into a_ctn05c01[arr_aux].*

     #-----------------------------------------------------------
     # Exclui os dispositivos/servicos nao mais realizados
     #
      select count(*)
        into w_count
        from ADBMACTCRT
             where discoddig = a_ctn05c01[arr_aux].discoddig
               and vigfnl = "31/12/2099"
      if  w_count = 0  then
          continue foreach
      end if
     #
     #-----------------------------------------------------------

      let arr_aux = arr_aux + 1

      if arr_aux > 400  then
         error " Limite de consulta excedido. Avise a informatica!"
         sleep 3
         exit foreach
      end if
   end foreach

   message " (F17)Abandona, (F8)Seleciona"

   call set_count(arr_aux-1)

   display array a_ctn05c01 to agckdisp.*
      on key (interrupt,control-c)
         initialize a_ctn05c01 to null
         exit display

      on key (f8)
         let int_flag = true
         exit display
   end display
end while

let int_flag = false
let arr_aux = arr_curr()

close window w_ctn05c01

return a_ctn05c01[arr_aux].discoddig, a_ctn05c01[arr_aux].disnom

end function

