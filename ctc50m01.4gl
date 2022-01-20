###############################################################################
# Nome do Modulo: ctc50m01                                                    #
#                                                                             #
# Pesquisa cadastro de cidades                                                #
#                                                                             #
# Data: 08/12/00                                                              #
###############################################################################

 database porto

#------------------------------------------------------------
 function ctc50m01()
#------------------------------------------------------------

 define d_ctc50m01    record
    ufdcodpsq         like datkmpacid.ufdcod,
    cidnompsq         like datkmpacid.cidnom
 end record

 define a_ctc50m01    array[500]  of  record
    ufdcod            like datkmpacid.ufdcod,
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom
 end record

 define ws            record
    today             date,
    nomepsq           char (47),
    total             char (10),
    seleciona         char (01),
    cont              dec  (6,0)
 end record

 define arr_aux       smallint


 open window w_ctc50m01 at  06,02 with form "ctc50m01"
             attribute(form line first)

 while true

    initialize d_ctc50m01  to null
    initialize a_ctc50m01  to null
    initialize ws.*        to null
    clear form
    let int_flag  =  false
    let arr_aux   =  1

    input by name d_ctc50m01.ufdcodpsq,
                  d_ctc50m01.cidnompsq   without defaults

       before field ufdcodpsq
           display by name d_ctc50m01.ufdcodpsq

       after field ufdcodpsq
           display by name d_ctc50m01.ufdcodpsq

           if d_ctc50m01.ufdcodpsq  is null   then
              error " UF deve ser informada!"
              next field ufdcodpsq
           end if

           select ufdcod
             from glakest
            where ufdcod  =  d_ctc50m01.ufdcodpsq

           if sqlca.sqlcode  =  notfound   then
              error " UF nao cadastrada!"
              next field ufdcodpsq
           end if

       before field cidnompsq
           display by name d_ctc50m01.cidnompsq

       after field cidnompsq
           display by name d_ctc50m01.cidnompsq

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field ufdcodpsq
           end if

           if d_ctc50m01.cidnompsq  is null   then
              error " Cidade deve ser informada!"
              next field cidnompsq
           end if

           let ws.cont  =  0
           let ws.cont  =  length(d_ctc50m01.cidnompsq)
           if ws.cont  <  4   then
              error " Nome da cidade nao deve conter menos que 4 caracteres!"
              next field cidnompsq
           end if
           let ws.nomepsq = "*", d_ctc50m01.cidnompsq clipped, "*"

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    declare  c_ctc50m01  cursor for
       select ufdcod,
              mpacidcod,
              cidnom
         from datkmpacid
        where datkmpacid.ufdcod  =  d_ctc50m01.ufdcodpsq
          and datkmpacid.cidnom  matches  ws.nomepsq

    message " Aguarde, pesquisando..."  attribute(reverse)

    foreach  c_ctc50m01  into  a_ctc50m01[arr_aux].ufdcod,
                               a_ctc50m01[arr_aux].mpacidcod,
                               a_ctc50m01[arr_aux].cidnom

       let arr_aux = arr_aux + 1
       if arr_aux > 500  then
          error " Limite excedido, pesquisa com mais de 500 cidades!"
          exit foreach
       end if

    end foreach

    if arr_aux  =  1   then
       error " Nao existem cidades para pesquisa!"
    end if

    let ws.total = "Total: ", arr_aux - 1 using "&&&"
    display by name ws.total  attribute (reverse)
    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux-1)
    let ws.seleciona = "n"

    display array  a_ctc50m01 to s_ctc50m01.*
       on key (interrupt)
          initialize ws.total   to null
          initialize a_ctc50m01 to null
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

    for arr_aux = 1 to 11
       clear s_ctc50m01[arr_aux].*
    end for

    close c_ctc50m01

 end while

 let int_flag = false
 close window  w_ctc50m01

 return a_ctc50m01[arr_aux].mpacidcod

end function   ###--  ctc50m01
