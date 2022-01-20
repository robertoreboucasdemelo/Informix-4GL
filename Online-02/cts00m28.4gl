###############################################################################
# Nome do Modulo: cts00m28                                           Ruiz     #
#                                                                    Marcus   #
# Mostra o cadastro de Motivos                                       Ago/2000 #
###############################################################################

database porto

#main
# call cts00m28()
#end main

#-----------------------------------------------------------
 function cts00m28()
#-----------------------------------------------------------

 define a_cts00m28 array[30] of record
    etpmtvcod   like datksrvintmtv.etpmtvcod,
    etpmtvdes   like datksrvintmtv.etpmtvdes
 end record

 define arr_aux    smallint


 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cts00m28[w_pf1].*  to  null
	end	for

   initialize a_cts00m28,
              arr_aux      to null

 open window cts00m28 at 10,30 with form "cts00m28"
                     attribute(form line 1, border)

 let int_flag = false
 initialize a_cts00m28  to null

 let arr_aux = 1

 declare c_cts00m28 cursor for
    select etpmtvcod,etpmtvdes
      from datksrvintmtv
     where atdetpcod = 3
      order by etpmtvdes

 foreach c_cts00m28  into  a_cts00m28[arr_aux].etpmtvcod,
                           a_cts00m28[arr_aux].etpmtvdes
    let arr_aux = arr_aux + 1
 end foreach

 message "  (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux - 1)

 display array a_cts00m28 to s_cts00m28.*

    on key (interrupt,control-c)
       initialize a_cts00m28   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

   end display

   let int_flag = false

   close window  cts00m28

   return a_cts00m28[arr_aux].etpmtvcod,
          a_cts00m28[arr_aux].etpmtvdes

end function  ###  cts00m28
