###############################################################################
# Nome do Modulo: CTC35M07                                           Gilberto #
#                                                                     Marcelo #
#                                                                      Wagner #
# Consulta Laudos                                                    Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc35m07()
#------------------------------------------------------------

 define a_ctc35m07    array[50]  of  record
    socvstlaunum      like datmvstlau.socvstlaunum,
    socvstlautipcod2  like datmvstlau.socvstlautipcod,
    socvstlautipdes2  like datkvstlautip.socvstlautipdes,
    viginc2           like datmvstlau.viginc,
    vigfnl2           like datmvstlau.vigfnl
 end record

 define d_ctc35m07    record
    datapsq           date,
    socvstlautipcod   like datmvstlau.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes
 end record

 define ws            record
    seleciona         char(01),
    total             char(10),
    comando1          char(500),
    comando2          char(200)
 end record

 define arr_aux       smallint


 open window w_ctc35m07 at  06,02 with form "ctc35m07"
             attribute(form line first)

 while true

    initialize ws.*          to null
    initialize d_ctc35m07    to null
    initialize a_ctc35m07    to null
    let int_flag = false
    let arr_aux  = 1
    let ws.seleciona = "n"

    input by name d_ctc35m07.*

       before field datapsq
              display by name d_ctc35m07.datapsq   attribute(reverse)

       after field datapsq
              display by name d_ctc35m07.datapsq

       before field socvstlautipcod
              initialize d_ctc35m07.socvstlautipdes   to null
              display by name d_ctc35m07.socvstlautipdes
              display by name d_ctc35m07.socvstlautipcod attribute (reverse)

       after field socvstlautipcod
              display by name d_ctc35m07.socvstlautipcod

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field datapsq
              end if

              if d_ctc35m07.socvstlautipcod   is null   and
                 d_ctc35m07.datapsq     is null   then
                 error " Data para pesquisa ou laudo deve ser informado!"
                 next field datapsq
              end if

              if d_ctc35m07.socvstlautipcod   is not null   then
                 select socvstlautipdes
                   into d_ctc35m07.socvstlautipdes
                   from datkvstlautip
                  where datkvstlautip.socvstlautipcod = d_ctc35m07.socvstlautipcod

                 if sqlca.sqlcode = notfound   then
                    error " Codigo do laudo invalido!"
                    call ctc35m09()  returning d_ctc35m07.socvstlautipcod
                    next field socvstlautipcod
                 else
                    display by name d_ctc35m07.socvstlautipdes
                 end if
              end if

              if d_ctc35m07.socvstlautipcod  is null   then
                 let d_ctc35m07.socvstlautipdes = "TODOS"
                 display by name d_ctc35m07.socvstlautipdes
              end if

       on key (interrupt)
              exit input

    end input

    if int_flag   then
       exit while
    end if

    #-------------------------------------------
    # MONTA CONDICAO PARA PESQUISA
    #-------------------------------------------
    if d_ctc35m07.socvstlautipcod   is not null   and
       d_ctc35m07.datapsq     is null       then
       let ws.comando2 = "  from datmvstlau ",
                         " where socvstlautipcod = ?     "
    end if

    if d_ctc35m07.socvstlautipcod   is null       and
       d_ctc35m07.datapsq     is null       then
       let ws.comando2 = "  from datmvstlau ",
                         " where socvstlautipcod > ?     "
    end if

    if d_ctc35m07.socvstlautipcod   is null       and
       d_ctc35m07.datapsq     is not null   then
       let ws.comando2 = "  from datmvstlau ",
                         " where ?                 ",
                         " between  viginc and vigfnl "
    end if

    if d_ctc35m07.socvstlautipcod   is not null   and
       d_ctc35m07.datapsq     is not null   then
       let ws.comando2 = "  from datmvstlau ",
                         " where socvstlautipcod = ?              and  ",
                         " ?                                     ",
                         " between  viginc and vigfnl "
    end if

    let ws.comando1 = " select           ",
                      " socvstlaunum,    ",
                      " socvstlautipcod,       ",
                      " viginc, ",
                      " vigfnl  ",
                      ws.comando2 clipped

    message " Aguarde, pesquisando..."  attribute(reverse)
    prepare comando_aux from ws.comando1
    declare c_ctc35m07 cursor for comando_aux

    if d_ctc35m07.socvstlautipcod   is not null   and
       d_ctc35m07.datapsq     is null       then
       open c_ctc35m07  using d_ctc35m07.socvstlautipcod
    end if

    if d_ctc35m07.socvstlautipcod   is null       and
       d_ctc35m07.datapsq     is null       then
       let d_ctc35m07.socvstlautipcod = 0
       open c_ctc35m07  using d_ctc35m07.socvstlautipcod
    end if

    if d_ctc35m07.socvstlautipcod   is null       and
       d_ctc35m07.datapsq     is not null   then
       open c_ctc35m07  using d_ctc35m07.datapsq
    end if

    if d_ctc35m07.socvstlautipcod   is not null   and
       d_ctc35m07.datapsq     is not null   then
       open c_ctc35m07  using d_ctc35m07.socvstlautipcod, d_ctc35m07.datapsq
    end if

    foreach  c_ctc35m07  into  a_ctc35m07[arr_aux].socvstlaunum,
                               a_ctc35m07[arr_aux].socvstlautipcod2,
                               a_ctc35m07[arr_aux].viginc2,
                               a_ctc35m07[arr_aux].vigfnl2

       initialize a_ctc35m07[arr_aux].socvstlautipdes2   to null
       select socvstlautipdes
         into a_ctc35m07[arr_aux].socvstlautipdes2
         from datkvstlautip
        where socvstlautipcod = a_ctc35m07[arr_aux].socvstlautipcod2

       let arr_aux = arr_aux + 1
       if arr_aux > 50  then
          error "Limite excedido, pesquisa com mais de 50 laudos!"
          exit foreach
       end if

    end foreach

    if arr_aux  =  1   then
       error "Nao existem laudos para pesquisa!"
    end if

    let ws.total = "Total: ", arr_aux - 1 using "&&&"
    display by name ws.total  attribute (reverse)
    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux-1)

    display array  a_ctc35m07 to s_ctc35m07.*
       on key (interrupt)
          initialize ws.total   to null
          initialize a_ctc35m07 to null
          display by name ws.total
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.seleciona = "s"
          exit display
    end display

    if ws.seleciona = "s"  then
       exit while
    end if

    clear form

    close c_ctc35m07

 end while

 let int_flag = false
 close window  w_ctc35m07

 return a_ctc35m07[arr_aux].socvstlaunum

end function  #  ctc35m07
