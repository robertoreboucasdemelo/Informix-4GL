################################################################################
# Nome do Modulo: CTN21C00                                            Gilberto #
#                                                                      Marcelo #
# Consulta congeneres(outras seguradoras)                             Fev/1996 #
################################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------
 function ctn21c00()
#------------------------------------------------------------------------

 define d_ctn21c00    record
    nomepsq           char(30)    # Nome para pesquisa
 end record

 define a_ctn21c00 array[40] of record
    sgdnom            like gcckcong.sgdnom    ,
    sgdirbcod         like gcckcong.sgdirbcod ,
    endlgd            like gcckcong.endlgd    ,
    endcmp            like gcckcong.endcmp    ,
    endbrr            like gcckcong.endbrr    ,
    endcid            like gcckcong.endcid    ,
    endufd            like gcckcong.endufd    ,
    dddcod            like gcckcong.dddcod    ,
    teltxt            like gcckcong.teltxt    ,
    factxt            like gcckcong.factxt    ,
    sgdescnum         like gcckcong.sgdescnum
 end record

 define ws            record
    endnum            like gcckcong.endnum    ,
    nomepsq           char(36)                ,
    w_int               integer
 end record

 define arr_aux       integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  40
		initialize  a_ctn21c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn21c00.*  to  null

	initialize  ws.*  to  null

 open window w_ctn21c00 at  06,02 with form "ctn21c00"
             attribute(form line first)

 while true

    initialize a_ctn21c00  to null
    initialize ws.*        to null

    let int_flag   = false
    let arr_aux    = 1

    input by name d_ctn21c00.*  without defaults

       before field nomepsq
          display by name d_ctn21c00.nomepsq attribute (reverse)

       after  field nomepsq
          display by name d_ctn21c00.nomepsq

          if d_ctn21c00.nomepsq is null    then
             error " Nome para pesquisa e' item obrigatorio !!"
             next field nomepsq
          end if

          let ws.w_int      = (length (d_ctn21c00.nomepsq))
          if  ws.w_int      < 3  then
              error " Minimo de 3 letras para pesquisar !!"
              next field nomepsq
          end if
          let ws.nomepsq = "*", d_ctn21c00.nomepsq clipped, "*"

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    message " Aguarde, pesquisando..."  attribute(reverse)

    declare c_ctn21c00  cursor for
       select sgdnom, endlgd   , endnum   , endbrr,
              endcid, endufd   , dddcod   , teltxt,
              factxt, sgdirbcod, sgdescnum, endcmp
         from gcckcong
        where sgdnom  matches  ws.nomepsq

    foreach  c_ctn21c00  into  a_ctn21c00[arr_aux].sgdnom    ,
                               a_ctn21c00[arr_aux].endlgd    ,
                               ws.endnum                     ,
                               a_ctn21c00[arr_aux].endbrr    ,
                               a_ctn21c00[arr_aux].endcid    ,
                               a_ctn21c00[arr_aux].endufd    ,
                               a_ctn21c00[arr_aux].dddcod    ,
                               a_ctn21c00[arr_aux].teltxt    ,
                               a_ctn21c00[arr_aux].factxt    ,
                               a_ctn21c00[arr_aux].sgdirbcod ,
                               a_ctn21c00[arr_aux].sgdescnum ,
                               a_ctn21c00[arr_aux].endcmp

       let a_ctn21c00[arr_aux].endlgd =
           a_ctn21c00[arr_aux].endlgd  clipped, " ", ws.endnum

       let arr_aux = arr_aux + 1
       if arr_aux > 40   then
          error "Limite excedido, pesquisa com mais de 40 congeneres !!"
          exit foreach
       end if
    end foreach
    close c_ctn21c00
    message " "

    if arr_aux  >  1   then
       message " (F17)Abandona"
       call set_count(arr_aux-1)

       display array  a_ctn21c00 to s_ctn21c00.*
          on key(interrupt)
             exit display
       end display

       for arr_aux = 1 to 2
          clear s_ctn21c00[arr_aux].sgdnom
          clear s_ctn21c00[arr_aux].endlgd
          clear s_ctn21c00[arr_aux].endcmp
          clear s_ctn21c00[arr_aux].endbrr
          clear s_ctn21c00[arr_aux].endcid
          clear s_ctn21c00[arr_aux].endufd
          clear s_ctn21c00[arr_aux].dddcod
          clear s_ctn21c00[arr_aux].teltxt
          clear s_ctn21c00[arr_aux].factxt
          clear s_ctn21c00[arr_aux].sgdirbcod
          clear s_ctn21c00[arr_aux].sgdescnum
       end for
    else
       error " Nao foi encontrada nenhuma congenere pela pesquisa!"
    end if

 end while

 let int_flag = false
 close window  w_ctn21c00

end function  #  ctn21c00

