#############################################################################
# Nome do Modulo: CTS06G04                                         Marcelo  #
#                                                                  Gilberto #
# Pesquisa padrao de cidades                                       Mar/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/06/2014 Fabio, Fornax  PSI-2014-11756/EV Melhorias na indexacao fase 2 #
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts06g04(param)
#-----------------------------------------------------------

 define param      record
    cidnom         like glakcid.cidnom,
    ufdcod         like glakest.ufdcod
 end record

 define d_cts06g04 record
    digcidnom      like glakcid.cidnom,
    digufdcod      like glakest.ufdcod
 end record

 define a_cts06g04 array[1000] of record
    ufdcod         like glakest.ufdcod,
    cidnom         like glakcid.cidnom,
    cidcod         like glakcid.cidcod
 end record

 define ws         record
    ufdcod         like glakest.ufdcod,
    cidcod         like glakcid.cidcod,
    cidnom         like glakcid.cidnom
 end record

 define arr_aux    smallint
 define	w_pf1	integer

 let	arr_aux  =  null

 for	w_pf1  =  1  to  1000
    initialize  a_cts06g04[w_pf1].*  to  null
 end	for

 initialize  d_cts06g04.*  to  null

 initialize  ws.*  to  null

 initialize ws.*          to null
 initialize d_cts06g04.*  to null
 initialize a_cts06g04    to null

 let d_cts06g04.digcidnom = param.cidnom
 let d_cts06g04.digufdcod = param.ufdcod


 open window cts06g04 at 09,11 with form "cts06g04"
      attribute(border, form line 1, message line last, comment line last)

 display by name d_cts06g04.*

 while not int_flag

    let int_flag = false

    input by name d_cts06g04.digcidnom,
                  d_cts06g04.digufdcod  without defaults

      before field digcidnom
             display by name d_cts06g04.*
             display by name d_cts06g04.digcidnom attribute (reverse)

      after  field digcidnom
             display by name d_cts06g04.digcidnom

             if fgl_lastkey() <> fgl_keyval("up")    and
                fgl_lastkey() <> fgl_keyval("left")  then

                 if d_cts06g04.digcidnom is null  then
                    error " Cidade deve ser informada!"
                    next field digcidnom
                 end if

             end if

      before field digufdcod
             display by name d_cts06g04.digufdcod attribute (reverse)

      after  field digufdcod
             display by name d_cts06g04.digufdcod

             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then
                if d_cts06g04.digufdcod is null  then
                   error " Sigla da unidade da federacao deve ser informada!"
                   next field digufdcod
                end if

                select ufdcod from glakest
                 where ufdcod = d_cts06g04.digufdcod

                if sqlca.sqlcode = notfound then
                   error " Unidade federativa nao cadastrada!"
                   next field digufdcod
                end if
             end if

      on key (interrupt)
         exit input

    end input

    if int_flag   then
       continue while
    end if

    # PSI-2014-11756 - usar o matches com o termo tambem no meio do nome
    let ws.cidnom = "*", d_cts06g04.digcidnom clipped, "*"

    let arr_aux = 1

    declare c_cts06g04_001 cursor for
       select cidnom,
              ufdcod,
              cidcod
         from glakcid
        where cidnom matches ws.cidnom
          and ufdcod = d_cts06g04.digufdcod

    message " Aguarde, pesquisando..." attribute (reverse)

    foreach c_cts06g04_001 into a_cts06g04[arr_aux].cidnom,
                                   a_cts06g04[arr_aux].ufdcod,
                                   a_cts06g04[arr_aux].cidcod

       let arr_aux = arr_aux + 1

       if arr_aux > 1000  then
          error " Limite excedido! Foram encontradas mais de 1000 cidades para a pesquisa!"
          exit foreach
       end if
    end foreach

    message " (F17)Abandona, (F8)Seleciona "

    if arr_aux > 1  then
       call set_count(arr_aux-1)

       display array a_cts06g04 to s_cts06g04.*
          on key (interrupt,control-c)
             initialize d_cts06g04.* to null
             exit display

          on key (F8)
             let int_flag = true
             let arr_aux = arr_curr()

             let ws.cidcod            = a_cts06g04[arr_aux].cidcod
             let d_cts06g04.digcidnom = a_cts06g04[arr_aux].cidnom
             let d_cts06g04.digufdcod = a_cts06g04[arr_aux].ufdcod

             exit display
       end display
    else
       error " Nao foi encontrada nenhuma cidade para esta pesquisa!"
    end if

 end while

 error ""
 close window cts06g04

 let int_flag = false

 return ws.cidcod,
        d_cts06g04.digcidnom,
        d_cts06g04.digufdcod

end function  ###  cts06g04



#-----------------------------------------------------------
 function cts06g04_oficial(param)
#-----------------------------------------------------------

 define param      record
    cidnom         like datkmpacid.cidnom,
    ufdcod         like datkmpacid.ufdcod
 end record

 define d_cts06g04 record
    digcidnom      like datkmpacid.cidnom,
    digufdcod      like datkmpacid.ufdcod
 end record

 define a_cts06g04 array[1000] of record
    ufdcod         like datkmpacid.ufdcod,
    cidnom         like datkmpacid.cidnom,
    cidcod         like datkmpacid.mpacidcod
 end record

 define ws         record
    ufdcod         like datkmpacid.ufdcod,
    cidcod         like datkmpacid.mpacidcod,
    cidnom         like datkmpacid.cidnom
 end record

 define arr_aux    smallint
 define	w_pf1	integer

 let	arr_aux  =  null

 for	w_pf1  =  1  to  1000
    initialize  a_cts06g04[w_pf1].*  to  null
 end	for

 initialize  d_cts06g04.*  to  null

 initialize  ws.*  to  null

 initialize ws.*          to null
 initialize d_cts06g04.*  to null
 initialize a_cts06g04    to null

 let d_cts06g04.digcidnom = param.cidnom
 let d_cts06g04.digufdcod = param.ufdcod


 open window cts06g04 at 09,11 with form "cts06g04"
      attribute(border, form line 1, message line last, comment line last)

 display by name d_cts06g04.*

 while not int_flag

    let int_flag = false

    input by name d_cts06g04.digcidnom,
                  d_cts06g04.digufdcod  without defaults

      before field digcidnom
             display by name d_cts06g04.*
             display by name d_cts06g04.digcidnom attribute (reverse)

      after  field digcidnom
             display by name d_cts06g04.digcidnom

             if fgl_lastkey() <> fgl_keyval("up")    and
                fgl_lastkey() <> fgl_keyval("left")  then

                 if d_cts06g04.digcidnom is null  then
                    error " Cidade deve ser informada!"
                    next field digcidnom
                 end if

             end if

      before field digufdcod
             display by name d_cts06g04.digufdcod attribute (reverse)

      after  field digufdcod
             display by name d_cts06g04.digufdcod

             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then
                if d_cts06g04.digufdcod is null  then
                   error " Sigla da unidade da federacao deve ser informada!"
                   next field digufdcod
                end if

                select ufdcod from glakest
                 where ufdcod = d_cts06g04.digufdcod

                if sqlca.sqlcode = notfound then
                   error " Unidade federativa nao cadastrada!"
                   next field digufdcod
                end if
             end if

      on key (interrupt)
         exit input

    end input

    if int_flag   then
       continue while
    end if

    # PSI-2014-11756 - usar o matches com o termo tambem no meio do nome
    let ws.cidnom = "*", d_cts06g04.digcidnom clipped, "*"

    let arr_aux = 1

    declare c_cts06g04_002 cursor for
       select cidnom,
              ufdcod,
              mpacidcod
         from datkmpacid
        where cidnom matches ws.cidnom
          and ufdcod = d_cts06g04.digufdcod

    message " Aguarde, pesquisando..." attribute (reverse)

    foreach c_cts06g04_002 into a_cts06g04[arr_aux].cidnom,
                                   a_cts06g04[arr_aux].ufdcod,
                                   a_cts06g04[arr_aux].cidcod

       let arr_aux = arr_aux + 1

       if arr_aux > 1000  then
          error " Limite excedido! Foram encontradas mais de 1000 cidades para a pesquisa!"
          exit foreach
       end if
    end foreach

    message " (F17)Abandona, (F8)Seleciona "

    if arr_aux > 1  then
       call set_count(arr_aux-1)

       display array a_cts06g04 to s_cts06g04.*
          on key (interrupt,control-c)
             initialize d_cts06g04.* to null
             exit display

          on key (F8)
             let int_flag = true
             let arr_aux = arr_curr()

             let ws.cidcod            = a_cts06g04[arr_aux].cidcod
             let d_cts06g04.digcidnom = a_cts06g04[arr_aux].cidnom
             let d_cts06g04.digufdcod = a_cts06g04[arr_aux].ufdcod

             exit display
       end display
    else
       error " Nao foi encontrada nenhuma cidade para esta pesquisa!"
    end if

 end while

 error ""
 close window cts06g04

 let int_flag = false

 return ws.cidcod,
        d_cts06g04.digcidnom,
        d_cts06g04.digufdcod

end function  ###  cts06g04
