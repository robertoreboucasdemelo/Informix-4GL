################################################################################
# Nome do Modulo: CTN22C00                                            Gilberto #
#                                                                      Marcelo #
# Consulta nomes da agenda de telefones                               Fev/1996 #
################################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------
 function ctn22c00()
#------------------------------------------------------------------------

 define d_ctn22c00    record
    nomepsq           char(30) ,  # Nome para pesquisa
    tipopsq           char(01)    # Tipo pesquisa  A-Apartir de, P-Parcial
 end record

 define a_ctn22c00 array[50] of record
    pesnom            like datkpesagetel.pesnom  ,
    pescod            like datkpesagetel.pescod
 end record

 define ws            record
    nomepsq           char(36)                ,
    w_int               integer
 end record

 define arr_aux       integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn22c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn22c00.*  to  null

	initialize  ws.*  to  null

 open window w_ctn22c00 at  06,02 with form "ctn22c00"
             attribute(form line first)

 while true

    initialize a_ctn22c00    to null
    initialize d_ctn22c00.*  to null
    initialize ws.*          to null
    let int_flag  =  false
    let arr_aux   =  1

    input by name d_ctn22c00.*  without defaults

       before field nomepsq
          display by name d_ctn22c00.nomepsq attribute (reverse)

       after  field nomepsq
          display by name d_ctn22c00.nomepsq

          if d_ctn22c00.nomepsq is null    then
             error " Nome para pesquisa deve ser informado !!"
             next field nomepsq
          end if

       before field tipopsq
          display by name d_ctn22c00.tipopsq attribute (reverse)

       after  field tipopsq
          display by name d_ctn22c00.tipopsq

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field nomepsq
          end if

          if d_ctn22c00.tipopsq  is null   or
             d_ctn22c00.tipopsq  = " "     then
             error " Tipo de pesquisa deve ser informado !!"
             next field tipopsq
          end if

          if d_ctn22c00.tipopsq  =  "A"   then
             let ws.nomepsq = d_ctn22c00.nomepsq clipped, "*"
          else
             if d_ctn22c00.tipopsq  =  "P"   then
                let ws.nomepsq = "*", d_ctn22c00.nomepsq clipped, "*"
             else
                error " Tipo pesquisa deve ser (A)apartir, (P)Parte do nome !!"
                next field tipopsq
             end if
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    declare c_ctn22c00  cursor for
       select pesnom, pescod
         from datkpesagetel
        where pesnom  matches  ws.nomepsq

    foreach  c_ctn22c00  into  a_ctn22c00[arr_aux].pesnom  ,
                               a_ctn22c00[arr_aux].pescod

       let arr_aux = arr_aux + 1
       if arr_aux > 50   then
          error "Limite excedido, pesquisa com mais de 50 nomes !!"
          exit foreach
       end if
    end foreach
    close c_ctn22c00

    if arr_aux  >  1   then
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_ctn22c00 to s_ctn22c00.*
          on key(interrupt)
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             call ctn22c01(a_ctn22c00[arr_aux].pescod)
       end display

       for arr_aux = 1 to 11
          clear s_ctn22c00[arr_aux].pesnom
          clear s_ctn22c00[arr_aux].pescod
       end for
    else
       error "Nao foi encontrado nenhum nome pela pesquisa !!"
    end if

 end while

 let int_flag = false
 close window  w_ctn22c00

end function  #  ctn22c00

