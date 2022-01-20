################################################################################
# Nome do Modulo: CTC23M02                                            Gilberto #
#                                                                      Marcelo #
# Pesquisa nomes na agenda de telefones                               Fev/1996 #
################################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------
 function ctc23m02()
#------------------------------------------------------------------------

 define d_ctc23m02    record
    nomepsq           char(30) ,  # Nome para pesquisa
    tipopsq           char(01)    # Tipo pesquisa  A-Apartir de, P-Parcial
 end record

 define a_ctc23m02 array[350] of record
    pesnom            like datkpesagetel.pesnom  ,
    pescod            like datkpesagetel.pescod
 end record

 define ws            record
    nomepsq           char(36)                   ,
    pescod            like datkpesagetel.pescod
 end record

 define arr_aux       smallint


 open window w_ctc23m02 at  06,02 with form "ctc23m02"
             attribute(form line first)

 while true

    initialize a_ctc23m02    to null
    initialize d_ctc23m02.*  to null
    initialize ws.*          to null
    let int_flag  =  false
    let arr_aux   =  1

    input by name d_ctc23m02.*  without defaults

       before field nomepsq
          display by name d_ctc23m02.nomepsq attribute (reverse)

       after  field nomepsq
          display by name d_ctc23m02.nomepsq

          if d_ctc23m02.nomepsq is null    then
             error " Nome para pesquisa deve ser informado !!"
             next field nomepsq
          end if

       before field tipopsq
          display by name d_ctc23m02.tipopsq attribute (reverse)

       after  field tipopsq
          display by name d_ctc23m02.tipopsq

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field nomepsq
          end if

          if d_ctc23m02.tipopsq  is null   or
             d_ctc23m02.tipopsq  = " "     then
             error " Tipo de pesquisa deve ser informado !!"
             next field tipopsq
          end if

          if d_ctc23m02.tipopsq  =  "A"   then
             let ws.nomepsq = d_ctc23m02.nomepsq clipped, "*"
          else
             if d_ctc23m02.tipopsq  =  "P"   then
                let ws.nomepsq = "*", d_ctc23m02.nomepsq clipped, "*"
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

    declare c_ctc23m02  cursor for
       select pesnom, pescod
         from datkpesagetel
        where pesnom  matches  ws.nomepsq

    foreach  c_ctc23m02  into  a_ctc23m02[arr_aux].pesnom  ,
                               a_ctc23m02[arr_aux].pescod

       let arr_aux = arr_aux + 1
       if arr_aux > 350   then
          error "Limite excedido, pesquisa com mais de 50 nomes !!"
          exit foreach
       end if
    end foreach

    if arr_aux  >  1   then
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_ctc23m02 to s_ctc23m02.*
          on key(interrupt)
             let int_flag = false
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.pescod = a_ctc23m02[arr_aux].pescod
             let int_flag = true
             exit display
       end display

       for arr_aux = 1 to 11
          clear s_ctc23m02[arr_aux].pesnom
          clear s_ctc23m02[arr_aux].pescod
       end for
    else
       error "Nao foi encontrado nenhum nome pela pesquisa !!"
    end if

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close window  w_ctc23m02

 return ws.pescod

end function  #  ctc23m02

