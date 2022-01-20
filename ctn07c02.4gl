###############################################################################
# Nome do Modulo: CTC30M01                                           Marcelo  #
#                                                                    Gilberto #
# Exibe pop-up para selecao da locadora                              Ago/1996 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctn07c02(prefixo)
#-----------------------------------------------------------

   define a_ctn07c02 array[30] of record
          srvdes     like avckservico.srvdes,
          srvcod     like avckservico.srvcod
   end    record

   define ret_srvcod like avckservico.srvcod

   define prefixo    char(03)

   define arr_aux    smallint


	define	w_pf1	integer

	let	ret_srvcod  =  null
	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_ctn07c02[w_pf1].*  to  null
	end	for

   open window ctn07c02 at 08,19 with form "ctn07c02"
                        attribute(form line 1, border)

   let prefixo  = prefixo clipped, "*"
   let int_flag = false
   initialize  a_ctn07c02   to null
   initialize  ret_srvcod   to null

   case prefixo
        when "IN*"
             display "INSTALACAO"  to cabec
        when "VP*"
             display "VISTORIA"    to cabec
   end case

   declare c_ctn07c02    cursor for
     select srvcod, srvdes
       from avckservico
      where srvcod matches prefixo  and
            c24libconflg = "S"

   let arr_aux  = 1

   foreach c_ctn07c02 into a_ctn07c02[arr_aux].srvcod,
                           a_ctn07c02[arr_aux].srvdes

      let arr_aux = arr_aux + 1
      if arr_aux  >  30   then
         error "Limite excedido, tabela de locadoras com mais de 30 itens!"
         exit foreach
      end if

   end foreach

   if prefixo = "VP*" then
      declare c_ctn07c02a   cursor for
         select srvcod, srvdes
           from avckservico
          where srvcod matches "GM*"    and
                c24libconflg = "S"
      foreach c_ctn07c02a into a_ctn07c02[arr_aux].srvcod,
                               a_ctn07c02[arr_aux].srvdes
         let arr_aux = arr_aux + 1
         if arr_aux  >  30   then
            error "Limite excedido, tabela de locadoras com mais de 30 itens!"
            exit foreach
         end if
      end foreach
   end if


   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctn07c02 to s_ctn07c02.*

      on key (interrupt,control-c)
         initialize a_ctn07c02   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ret_srvcod = a_ctn07c02[arr_aux].srvcod
         exit display

   end display

   let int_flag = false
   close window  ctn07c02

   return ret_srvcod

end function  #  ctn07c02
