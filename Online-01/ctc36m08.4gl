#############################################################################
# Nome de Modulo: CTC36M08                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Revisao dos itens da Vistoria                                    Dez/1998 #
#############################################################################

database porto

define d_ctc36m08  record
   socvstsit       like datmsocvst.socvstsit,
   sitdesc         char(30)
end record

#--------------------------------------------------------------------
function ctc36m08(param)
#--------------------------------------------------------------------
  define param       record
     socvstnum       like datmvstmvt.socvstnum
  end record

  define a_ctc36m08  array[400] of record
     socvstitmcod    like datmvstmvt.socvstitmcod,
     socvstitmdes    like datkvstitm.socvstitmdes,
     socvstitmvercod like datmvstmvt.socvstitmvercod,
     socvstitmverdes like datkvstitmver.socvstitmverdes,
     socvstitmgrpcod like datmvstmvt.socvstitmgrpcod,
     socvstitmgrpdes like datkvstitmgrp.socvstitmgrpdes,
     revidesc        char(1)
  end record

  define ws          record
     socvstitmcod    like datmvstmvt.socvstitmcod,
     socvstlautipcod like datmsocvst.socvstlautipcod,
     socvstorgdat    like datmsocvst.socvstorgdat,
     socvstlaunum    like datrvstitmver.socvstlaunum,
     socvstitmsit    like datkvstitm.socvstitmsit,
     socvstitmvercod like datkvstitmver.socvstitmvercod,
     socvstitmversit like datkvstitmver.socvstitmversit,
     count           dec(5,0),
     operacao        char(01)
  end record

  define arr_aux     smallint
  define scr_aux     smallint

  initialize a_ctc36m08    to null
  initialize d_ctc36m08.*  to null
  initialize ws.*          to null

  open window w_ctc36m08 at 06,02 with form "ctc36m08"
       attribute(form line first, comment line last - 1)

  let arr_aux = 1

  # CARREGA DADOS DA VISTORIA
  #--------------------------
  select socvstlautipcod, socvstsit, socvstorgdat
   into ws.socvstlautipcod, d_ctc36m08.socvstsit, ws.socvstorgdat
    from datmsocvst
   where socvstnum = param.socvstnum

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura da vistoria! "
     close window w_ctc36m08
     return
  end if

  select cpodes
    into d_ctc36m08.sitdesc
    from iddkdominio
   where cponom = "socvstsit"
     and cpocod = d_ctc36m08.socvstsit

  if sqlca.sqlcode <> 0 then
     let d_ctc36m08.sitdesc = "INVALIDO !!"
  end if

  display by name param.socvstnum
  display by name d_ctc36m08.socvstsit
  display by name d_ctc36m08.sitdesc

  select socvstlaunum into ws.socvstlaunum
    from datmvstlau
   where datmvstlau.socvstlautipcod = ws.socvstlautipcod
     and (datmvstlau.viginc <= ws.socvstorgdat and
          datmvstlau.vigfnl >= ws.socvstorgdat)

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura do tipo de laudo! "
     close window w_ctc36m08
     return
  end if

  # MONTA ITENS DA VISTORIA
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctc36m08  cursor for
    select datmvstmvt.socvstitmcod      , datmvstmvt.socvstitmvercod   ,
           datmvstmvt.socvstitmgrpcod
      from datmvstmvt
     where datmvstmvt.socvstnum    = param.socvstnum
     order by datmvstmvt.socvstitmgrpcod, datmvstmvt.socvstitmcod

  foreach c_ctc36m08 into a_ctc36m08[arr_aux].socvstitmcod,
                          a_ctc36m08[arr_aux].socvstitmvercod,
                          a_ctc36m08[arr_aux].socvstitmgrpcod

     select socvstitmdes into a_ctc36m08[arr_aux].socvstitmdes
       from datkvstitm
      where datkvstitm.socvstitmcod = a_ctc36m08[arr_aux].socvstitmcod

     if sqlca.sqlcode <> 0    then
        let a_ctc36m08[arr_aux].socvstitmdes = "Item nao cadatrado!"
     end if

     select socvstitmverdes into a_ctc36m08[arr_aux].socvstitmverdes
       from datkvstitmver
      where datkvstitmver.socvstitmvercod = a_ctc36m08[arr_aux].socvstitmvercod

     if sqlca.sqlcode <> 0    then
        let a_ctc36m08[arr_aux].socvstitmverdes = "Verificacao nao cadatrado!"
     end if

     select socvstitmgrpdes into a_ctc36m08[arr_aux].socvstitmgrpdes
       from datkvstitmgrp
      where datkvstitmgrp.socvstitmgrpcod = a_ctc36m08[arr_aux].socvstitmgrpcod

     if sqlca.sqlcode <> 0    then
        let a_ctc36m08[arr_aux].socvstitmgrpdes = "Grupo nao cadatrado!"
     end if

     select socvstitmrevflg into a_ctc36m08[arr_aux].revidesc
       from datrvstitmver
      where datrvstitmver.socvstlaunum    = ws.socvstlaunum
        and datrvstitmver.socvstitmcod    = a_ctc36m08[arr_aux].socvstitmcod
        and datrvstitmver.socvstitmvercod = a_ctc36m08[arr_aux].socvstitmvercod

     if a_ctc36m08[arr_aux].revidesc = "N" then
        let a_ctc36m08[arr_aux].revidesc = " "
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 400   then
        error " Limite excedido! Vistoria com mais de 400 itens!"
        exit foreach
     end if

  end foreach

  message ""
  call set_count(arr_aux-1)
  message " (F17)Abandona "

  display array a_ctc36m08 to s_ctc36m08.*
     on key (interrupt,control-c)
        exit display
  end display

  let int_flag = false
  close window w_ctc36m08

end function  ###  ctc36m08

