################################################################################
# Nome do Modulo: CTC12M01                                            Marcelo  #
#                                                                     Gilberto #
# Pesquisa estabelecimento por nome e servico que realiza             Mar/1996 #
################################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------
function ctc12m01()
#------------------------------------------------------------------------

 define d_ctc12m01    record
    nomepsq           char(25)                ,
    pstsrvtip         like dpckserv.pstsrvtip ,
    pstsrvdes         like dpckserv.pstsrvdes
 end record

 define a_ctc12m01 array[100] of record
    nome              char(25)                ,
    endufd            like dpaklista.endufd   ,
    endcid            like dpaklista.endcid   ,
    endbrr            like dpaklista.endbrr   ,
    emplstcod         like dpaklista.emplstcod
 end record

 define ws            record
    nomepsq           char(026) ,
    comando           char(500) ,
    cond              char(200) ,
    selec             char(01)  ,
    inteiro               smallint
 end record

 define arr_aux       integer


open window w_ctc12m01 at  06,02 with form "ctc12m01"
            attribute(form line first)

while true

    initialize ws.*          to null
    initialize a_ctc12m01    to null

    let ws.inteiro     = 0
    let int_flag   = false
    let arr_aux    = 1

    input by name d_ctc12m01.*  without defaults

       before field nomepsq
          display by name d_ctc12m01.nomepsq   attribute (reverse)

       after  field nomepsq
          display by name d_ctc12m01.nomepsq
          if d_ctc12m01.nomepsq   is not null or
             d_ctc12m01.nomepsq   <> " "      then

             if  length (d_ctc12m01.nomepsq) < 4  then
                 error "Minimo de 4 letras para pesquisar!"
                 next field nomepsq
             end if
             let ws.nomepsq = "*", d_ctc12m01.nomepsq clipped, "*"

             display by name d_ctc12m01.nomepsq
          end if

       before field pstsrvtip
          display by name d_ctc12m01.pstsrvtip attribute (reverse)

       after field pstsrvtip
          display by name d_ctc12m01.pstsrvtip

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field nomepsq
          end if

          if d_ctc12m01.pstsrvtip is null or
             d_ctc12m01.pstsrvtip = " "   then
             error "Codigo do servico nao informado!"
             call ctn06c03() returning d_ctc12m01.pstsrvtip,
                                       d_ctc12m01.pstsrvdes
             next field pstsrvtip
          else
             select pstsrvdes
               into d_ctc12m01.pstsrvdes
               from dpckserv
              where pstsrvtip  =  d_ctc12m01.pstsrvtip

             if status = notfound then
                error "Tipo de servico nao cadastrado!"

                call ctn06c03() returning d_ctc12m01.pstsrvtip,
                                          d_ctc12m01.pstsrvdes
                next field pstsrvtip

             end if
          end if

          display by name d_ctc12m01.pstsrvdes
          exit input

    on key (interrupt)
       exit input

    end input

    if int_flag   then
       exit while
    end if

    #-----------------------------------------------------------
    # PESQUISA ESTABELECIMENTO POR NOME
    #-----------------------------------------------------------

    if d_ctc12m01.nomepsq   is not null  and
       d_ctc12m01.nomepsq   <> " "       then

       let ws.comando = "select dpaklista.empnom,     " ,
                     "       dpaklista.endufd,        " ,
                     "       dpaklista.endcid,        " ,
                     "       dpaklista.endbrr,        " ,
                     "       dpaklista.emplstcod      " ,
                     "  from dpaklista, dparservlista " ,
                     " where dparservlista.pstsrvtip = ?                     " ,
                     "   and dpaklista.emplstcod    = dparservlista.emplstcod" ,
                     "   and dpaklista.empnom  matches '",
                     ws.nomepsq, "' ",
                     "       order by empnom                                 "
    else
       let ws.comando = "select dpaklista.empnom,     " ,
                     "       dpaklista.endufd,        " ,
                     "       dpaklista.endcid,        " ,
                     "       dpaklista.endbrr,        " ,
                     "       dpaklista.emplstcod      " ,
                     "  from dpaklista, dparservlista " ,
                     " where dparservlista.pstsrvtip = ?                     ",
                     "   and dpaklista.emplstcod    = dparservlista.emplstcod",
                     "      order by empnom                                  "
   end if

    prepare sql_select from ws.comando

    declare c_ctc12m01 cursor for sql_select
    open    c_ctc12m01 using d_ctc12m01.pstsrvtip

    foreach  c_ctc12m01 into  a_ctc12m01[arr_aux].nome     ,
                              a_ctc12m01[arr_aux].endufd   ,
                              a_ctc12m01[arr_aux].endcid   ,
                              a_ctc12m01[arr_aux].endbrr   ,
                              a_ctc12m01[arr_aux].emplstcod

       let arr_aux = arr_aux + 1
       if arr_aux > 100  then
          error "Limite excedido, pesquisa com mais de 100 estabelecimentos !"
          exit foreach
       end if
    end foreach

    if arr_aux  >  1   then
       message " (F17)Abandona, (F8)Seleciona"
       let ws.selec = "n"
       call set_count(arr_aux-1)

       display array  a_ctc12m01 to s_ctc12m01.*
          on key(interrupt)
             for arr_aux = 1 to 11
                 clear s_ctc12m01[arr_aux].nome
                 clear s_ctc12m01[arr_aux].endufd
                 clear s_ctc12m01[arr_aux].endcid
                 clear s_ctc12m01[arr_aux].endbrr
                 clear s_ctc12m01[arr_aux].emplstcod
             end for
            let ws.selec = "n"
             exit display

          on key(f8)
             let arr_aux = arr_curr()
             let ws.selec = "s"
             error " Selecione e tecle ENTER !"
             exit display
       end display
    else
       error " Nao foi encontrado nenhum estabelecimento para pesquisa!"
    end if

    if ws.selec = "s"   then
       exit while
    end if

end while

let int_flag = false
close window  w_ctc12m01
return a_ctc12m01[arr_aux].emplstcod

end function  #  ctc12m01
