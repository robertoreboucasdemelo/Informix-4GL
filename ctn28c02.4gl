###############################################################################
# Nome do Modulo: CTN28C02                                           Marcelo  #
#                                                                    Gilberto #
# Mostra todas as situacoes de transmissao p/ impressao remota       Set/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn28c02()
#-----------------------------------------------------------

 define a_ctn28c02 array[10] of record
        cpocod     like iddkdominio.cpocod,
        cpodes     like iddkdominio.cpodes
 end    record

 define arr_aux    smallint
 define scr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  10
		initialize  a_ctn28c02[w_pf1].*  to  null
	end	for

   open window ctn28c02 at 11,38 with form "ctn28c02"
                        attribute(form line 1, border)

   let int_flag = false
   initialize  a_ctn28c02   to null

   declare c_ctn28c02    cursor for
     select  cpocod, cpodes
       from  iddkdominio
       where cponom = "atdtrxsit"

   let arr_aux  = 1

   foreach c_ctn28c02 into a_ctn28c02[arr_aux].cpocod,
                           a_ctn28c02[arr_aux].cpodes
      let arr_aux = arr_aux + 1
      if arr_aux  >  10   then
         error "Limite excedido. Existem mais de 10 status cadastrados!"
         exit foreach
      end if
   end foreach

   if arr_aux = 1 then
      error "Nao existe nenhum status de impressora cadastrado. AVISE A INFORMATICA!"
      close window  ctn28c02
      return a_ctn28c02[arr_aux].cpocod
   end if

   message "(F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctn28c02 to s_ctn28c02.*

      on key (interrupt,control-c)
         initialize a_ctn28c02   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display

   end display

   close window  ctn28c02
   let int_flag = false
   return a_ctn28c02[arr_aux].cpocod

end function  #  ctn28c02
