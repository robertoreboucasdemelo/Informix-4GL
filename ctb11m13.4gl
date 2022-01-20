################################################################################
# Nome do Modulo: ctb11m13                                            Marcelo  #
#                                                                     Gilberto #
# Seleciona contribuinte para tributacao                              Out/1997 #
################################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------
 function ctb11m13(d_ctb11m13)
#-----------------------------------------------------------------------

 define d_ctb11m13    record
    cgccpfnum         like cgpkprestn.cgccpfnum,
    cgcord            like cgpkprestn.cgcord,
    empcod            like cgpkprestn.empcod,
    succod            like cgpkprestn.succod,
    prstip            like cgpkprestn.prstip
 end record

 define ws            record
    cntnom            like cgpkcontrn.cntnom,
    endlgd            char (50),
    endbrr            like cgpkcontrn.endbrr,
    endcid            like cgpkcontrn.endcid,
    endufd            like cgpkcontrn.endufd,
    endnum            like cgpkcontrn.endnum,
    endcmp            like cgpkcontrn.endcmp,
    sitreg            like cgpkprestn.sitreg,
    confirma          char (01)
 end record

 define a_ctb11m13    array[15] of record
    empcod            like cgpkprestn.empcod,
    succod            like cgpkprestn.succod,
    sucnom            like gabksuc.sucnom,
    prstip            like cgpkprestn.prstip,
    prstipdes         like cgckprest.prstipdes
 end record

 define arr_aux       smallint

 initialize a_ctb11m13 to null
 initialize ws.*       to null

 select cntnom   , endlgd   , endnum   , endcmp   ,
        endbrr   , endcid   , endufd
   into ws.cntnom, ws.endlgd, ws.endnum, ws.endcmp,
        ws.endbrr, ws.endcid, ws.endufd
   from cgpkcontrn
  where cgccpfnum = d_ctb11m13.cgccpfnum  and
        cgcord    = d_ctb11m13.cgcord     and
        sitreg    <> "D"

 if sqlca.sqlcode = notfound  then
    initialize d_ctb11m13.empcod thru d_ctb11m13.prstip to null
    call cts08g01("A", "N", "PRESTADOR NAO CADASTRADO",
                       "PARA TRIBUTACAO!",
                       "SOLICITE O CADASTRAMENTO JUNTO",
                       "AO DEPARTAMENTO DE TRIBUTOS")
         returning ws.confirma

    error " Prestador nao cadastrado!"
    return d_ctb11m13.*
 else
    let ws.endlgd = ws.endlgd clipped, " ",
                    ws.endnum using "<<<<<#", " ", ws.endcmp
 end if

 open window w_ctb11m13 at 08,18 with form "ctb11m13"
             attribute(form line first, border)

 message " (F17)Abandona, (F8)Seleciona"

 display by name ws.cntnom thru ws.endufd

 let arr_aux = 1

 declare c_ctb11m13 cursor for
    select empcod, succod, prstip, sitreg
      from cgpkprestn
     where cgccpfnum = d_ctb11m13.cgccpfnum  and
           cgcord    = d_ctb11m13.cgcord
     order by empcod, succod, prstip

 foreach c_ctb11m13 into a_ctb11m13[arr_aux].empcod,
                         a_ctb11m13[arr_aux].succod,
                         a_ctb11m13[arr_aux].prstip,
                         ws.sitreg

    if ws.sitreg = "D"  then
       continue foreach
    end if

    if a_ctb11m13[arr_aux].prstip = "Z" then   # Z nao aceito para Coop.Taxi
       continue foreach
    end if

    let a_ctb11m13[arr_aux].sucnom = "*** NAO CADASTRADA! ***"

    select sucnom
      into a_ctb11m13[arr_aux].sucnom
      from gabksuc
     where succod = a_ctb11m13[arr_aux].succod

    let a_ctb11m13[arr_aux].prstipdes = "*** NAO CADASTRADO! ***"

    select prstipdes
      into a_ctb11m13[arr_aux].prstipdes
      from cgckprest
     where prstip = a_ctb11m13[arr_aux].prstip

    let arr_aux = arr_aux + 1

    if arr_aux > 15  then
       error " Limite excedido! Foram encontradas mais de 15 atividades relacionadas a este prestador!"
       exit foreach
    end if
 end foreach

 if arr_aux > 1  then
    call set_count(arr_aux - 1)

    display array a_ctb11m13 to s_ctb11m13.*
       on key (F8)
          let arr_aux = arr_curr()

          if a_ctb11m13[arr_aux].prstip <> "F"  and
             a_ctb11m13[arr_aux].prstip <> "Z"  and
             g_issk.acsnivcod < 6               then
             error " So' sao permitidas as tributacoes de FRETE ou COOPERATIVA!"
          else
             let d_ctb11m13.empcod = a_ctb11m13[arr_aux].empcod
             let d_ctb11m13.succod = a_ctb11m13[arr_aux].succod
             let d_ctb11m13.prstip = a_ctb11m13[arr_aux].prstip
             exit display
          end if

       on key (interrupt)
          let arr_aux = arr_curr()
          initialize a_ctb11m13 to null
          exit display

    end display
 else
    error " Prestador nao esta' relacionado a nenhuma atividade! Entre em contato com depto. de tributos!"
 end if

 let int_flag = false
 close window  w_ctb11m13
 return d_ctb11m13.*

end function  ###  ctb11m13
