#-------------------------------------------------------------------------#
# Nome do Modulo: CTB10M04                                       Gilberto #
#                                                                 Marcelo #
# Consulta vigencia de tarifas do porto socorro                  Nov/1996 #
#-------------------------------------------------------------------------#
#                               ALTERACOES                                #
# Fabrica de Software - Teresinha Silva  - 22/10/2003 - OSF 25143         #
# Objetivo : Aumentar o tamanho do array de 50 para 500 posicoes          #
#-------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctb10m04()
#------------------------------------------------------------

 define a_ctb10m04    array[500]  of  record
    soctrfvignum      like dbsmvigtrfsocorro.soctrfvignum,
    soctrfcod2        like dbsmvigtrfsocorro.soctrfcod,
    soctrfdes2        like dbsktarifasocorro.soctrfdes,
    soctrfvigincdat2  like dbsmvigtrfsocorro.soctrfvigincdat,
    soctrfvigfnldat2  like dbsmvigtrfsocorro.soctrfvigfnldat
 end record

 define d_ctb10m04    record
    datapsq           date,
    soctrfcod         like dbsmvigtrfsocorro.soctrfcod,
    soctrfdes         like dbsktarifasocorro.soctrfdes
 end record

 define ws            record
    total             char(10),
    comando1          char(500),
    comando2          char(200),
    seleciona         char(01)
 end record

 define arr_aux       smallint


 open window w_ctb10m04 at  06,02 with form "ctb10m04"
             attribute(form line first)

 while true

    initialize ws.*          to null
    initialize d_ctb10m04    to null
    initialize a_ctb10m04    to null
    let int_flag = false
    let arr_aux  = 1

    input by name d_ctb10m04.*

       before field datapsq
              display by name d_ctb10m04.datapsq   attribute(reverse)

       after field datapsq
              display by name d_ctb10m04.datapsq

       before field soctrfcod
              initialize d_ctb10m04.soctrfdes   to null
              display by name d_ctb10m04.soctrfdes
              display by name d_ctb10m04.soctrfcod attribute (reverse)

       after field soctrfcod
              display by name d_ctb10m04.soctrfcod

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field datapsq
              end if

              if d_ctb10m04.soctrfcod   is null   and
                 d_ctb10m04.datapsq     is null   then
                 error " Data para pesquisa ou tarifa deve ser informado!"
                 next field datapsq
              end if

              if d_ctb10m04.soctrfcod   is not null   then
                 select soctrfdes
                   into d_ctb10m04.soctrfdes
                   from dbsktarifasocorro
                  where dbsktarifasocorro.soctrfcod = d_ctb10m04.soctrfcod

                 if sqlca.sqlcode = notfound   then
                    error " Codigo da tarifa invalido!"
                    call ctb10m05()  returning d_ctb10m04.soctrfcod
                    next field soctrfcod
                 else
                    display by name d_ctb10m04.soctrfdes
                 end if
              end if

              if d_ctb10m04.soctrfcod  is null   then
                 let d_ctb10m04.soctrfdes = "TODAS"
                 display by name d_ctb10m04.soctrfdes
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
    if d_ctb10m04.soctrfcod   is not null   and
       d_ctb10m04.datapsq     is null       then
       let ws.comando2 = "  from dbsmvigtrfsocorro ",
                         " where soctrfcod = ?     "
    end if

    if d_ctb10m04.soctrfcod   is null       and
       d_ctb10m04.datapsq     is null       then
       let ws.comando2 = "  from dbsmvigtrfsocorro ",
                         " where soctrfcod > ?     "
    end if

    if d_ctb10m04.soctrfcod   is null       and
       d_ctb10m04.datapsq     is not null   then
       let ws.comando2 = "  from dbsmvigtrfsocorro ",
                         " where ?                 ",
                         " between  soctrfvigincdat and soctrfvigfnldat "
    end if

    if d_ctb10m04.soctrfcod   is not null   and
       d_ctb10m04.datapsq     is not null   then
       let ws.comando2 = "  from dbsmvigtrfsocorro ",
                         " where soctrfcod = ?              and  ",
                         " ?                                     ",
                         " between  soctrfvigincdat and soctrfvigfnldat "
    end if

    let ws.comando1 = " select           ",
                      " soctrfvignum,    ",
                      " soctrfcod,       ",
                      " soctrfvigincdat, ",
                      " soctrfvigfnldat  ",
                      ws.comando2 clipped

    message " Aguarde, pesquisando..."  attribute(reverse)
    prepare comando_aux from ws.comando1
    declare c_ctb10m04 cursor for comando_aux

    if d_ctb10m04.soctrfcod   is not null   and
       d_ctb10m04.datapsq     is null       then
       open c_ctb10m04  using d_ctb10m04.soctrfcod
    end if

    if d_ctb10m04.soctrfcod   is null       and
       d_ctb10m04.datapsq     is null       then
       let d_ctb10m04.soctrfcod = 0
       open c_ctb10m04  using d_ctb10m04.soctrfcod
    end if

    if d_ctb10m04.soctrfcod   is null       and
       d_ctb10m04.datapsq     is not null   then
       open c_ctb10m04  using d_ctb10m04.datapsq
    end if

    if d_ctb10m04.soctrfcod   is not null   and
       d_ctb10m04.datapsq     is not null   then
       open c_ctb10m04  using d_ctb10m04.soctrfcod, d_ctb10m04.datapsq
    end if

    foreach  c_ctb10m04  into  a_ctb10m04[arr_aux].soctrfvignum,
                               a_ctb10m04[arr_aux].soctrfcod2,
                               a_ctb10m04[arr_aux].soctrfvigincdat2,
                               a_ctb10m04[arr_aux].soctrfvigfnldat2

       initialize a_ctb10m04[arr_aux].soctrfdes2   to null
       select soctrfdes
         into a_ctb10m04[arr_aux].soctrfdes2
         from dbsktarifasocorro
        where soctrfcod = a_ctb10m04[arr_aux].soctrfcod2

       let arr_aux = arr_aux + 1
       if arr_aux > 500  then
          error "Limite excedido, pesquisa com mais de 500 vigencias!"
          exit foreach
       end if

    end foreach

    if arr_aux  =  1   then
       error "Nao existem vigencias para pesquisa!"
    end if

    let ws.total = "Total: ", arr_aux - 1 using "&&&"
    display by name ws.total  attribute (reverse)
    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux-1)
    let ws.seleciona = "n"

    display array  a_ctb10m04 to s_ctb10m04.*
       on key (interrupt)
          initialize ws.total   to null
          initialize a_ctb10m04 to null
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

    for arr_aux = 1 to 10
       clear s_ctb10m04[arr_aux].soctrfvignum
       clear s_ctb10m04[arr_aux].soctrfcod2
       clear s_ctb10m04[arr_aux].soctrfdes2
       clear s_ctb10m04[arr_aux].soctrfvigincdat2
       clear s_ctb10m04[arr_aux].soctrfvigfnldat2
    end for

    close c_ctb10m04

 end while

 let int_flag = false
 close window  w_ctb10m04

 return a_ctb10m04[arr_aux].soctrfvignum

end function  #  ctb10m04
