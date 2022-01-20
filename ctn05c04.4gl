##############################################################################
# Nome do Modulo: CTN05C04                                             Ruiz  #
#                                                                            #
# Consulta Dispositivos de seguranca realizados nos postos.         Abr/2002 #
##############################################################################

database porto


#---------------------------------------------------------
function ctn05c04(param)
#---------------------------------------------------------
  define param record
     vstpstcod      like avcrdiservpost.vstpstcod
  end record
  define a_ctn05c04 array [100] of record
     discoddig      like agckdisp.discoddig,
     marca          char (1),
     disnom         like agckdisp.disnom
  end record
  define w_count integer
  define arr_aux integer


	define	w_pf1	integer

	let	w_count  =  null
	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn05c04[w_pf1].*  to  null
	end	for

  open window w_ctn05c04 at 12,25 with form "ctn05c04"
     attribute (border, form line 1)

  let int_flag = false

  while not int_flag
     declare c_ctn05c04_001 cursor for
        select discoddig
           from avcrdiservpost
          where vstpstcod = param.vstpstcod

     let arr_aux = 1
     foreach c_ctn05c04_001 into a_ctn05c04[arr_aux].discoddig
       #-----------------------------------------------------------
       # Exclui os dispositivos/servicos nao mais realizados
       #
       #select count(*)
       #  into w_count
       #  from ADBMACTCRT
       #       where discoddig = a_ctn05c04[arr_aux].discoddig
       #         and vigfnl = "31/12/2099"
       #if  w_count = 0  then
       #    continue foreach
       #end if
        select disnom
          into a_ctn05c04[arr_aux].disnom
          from agckdisp
         where discoddig = a_ctn05c04[arr_aux].discoddig

        select count(*)
            into w_count
            from temp_ctn05c03a
           where discoddig = a_ctn05c04[arr_aux].discoddig
        if w_count > 0 then
           let a_ctn05c04[arr_aux].marca = "X"
        end if
       #-----------------------------------------------------------
        let arr_aux = arr_aux + 1

        if arr_aux > 100  then
           error " Limite de consulta excedido. Avise a informatica!"
           sleep 3
           exit foreach
        end if
     end foreach

     message " (F17)Abandona"

     call set_count(arr_aux-1)

     display array a_ctn05c04 to s_ctn05c04.*
        on key (interrupt,control-c)
           initialize a_ctn05c04 to null
           exit display
     end display
  end while
  let int_flag = false
  let arr_aux = arr_curr()

  close window w_ctn05c04
end function

