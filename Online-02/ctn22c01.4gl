################################################################################
# Nome do Modulo: CTN22C01                                            Gilberto #
#                                                                      Marcelo #
# Consulta telefones de um nome da agenda                             Fev/1996 #
################################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------
 function ctn22c01(par_pescod)
#------------------------------------------------------------------------
 define par_pescod    like datkpesagetel.pescod

 define a_ctn22c01 array[09] of record
    teltipdes         char(09)                  ,
    dddcod            like datkagendatel.dddcod ,
    telnum            like datkagendatel.telnum ,
    rmlnum            like datkagendatel.rmlnum ,
    bipnum            like datkagendatel.bipnum
 end record

 define ws            record
    pesnom            like datkpesagetel.pesnom    ,
    pesobs            like datkpesagetel.pesobs    ,
    teltipcod         like datkagendatel.teltipcod
 end record

 define arr_aux       integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  9
		initialize  a_ctn22c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 open window w_ctn22c01 at  06,02 with form "ctn22c01"
             attribute(form line first)

 select pesnom, pesobs
   into ws.pesnom, ws.pesobs
   from datkpesagetel
  where pescod = par_pescod

 display ws.pesnom   to  pesnom  attribute(reverse)
 display ws.pesobs   to  pesobs
 let arr_aux = 1

 declare c_ctn22c01  cursor for
    select teltipcod, dddcod, telnum, rmlnum, bipnum
      from datkagendatel
     where pescod  =  par_pescod

 foreach  c_ctn22c01  into  ws.teltipcod               ,
                            a_ctn22c01[arr_aux].dddcod ,
                            a_ctn22c01[arr_aux].telnum ,
                            a_ctn22c01[arr_aux].rmlnum ,
                            a_ctn22c01[arr_aux].bipnum
    case ws.teltipcod
         when  1
            let a_ctn22c01[arr_aux].teltipdes = "TELEFONE"
         when  2
            let a_ctn22c01[arr_aux].teltipdes = "FAX"
         when  3
            let a_ctn22c01[arr_aux].teltipdes = "BIP"
         when  4
            let a_ctn22c01[arr_aux].teltipdes = "CELULAR"
         otherwise
            let a_ctn22c01[arr_aux].teltipdes = "N/PREVISTO"
    end case

    let arr_aux = arr_aux + 1
    if arr_aux > 09   then
       error "Limite excedido, nome com mais de 09 telefones !!"
       exit foreach
    end if
 end foreach
 close c_ctn22c01

 if arr_aux  >  1   then
    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array  a_ctn22c01 to s_ctn22c01.*
       on key(interrupt)
          exit display
    end display
 else
    error "Nao foi encontrado nenhum telefone p/ o nome informado !!"
 end if

 let int_flag = false
 close window  w_ctn22c01

end function  #  ctn22c01

