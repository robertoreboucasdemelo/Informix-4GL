############################################################################
# Menu de Modulo: CTC35M06                                        Gilberto #
#                                                                  Marcelo #
#                                                                   Wagner #
# Manutencao no cadastro de Laudo de vistoria (itens)             Dez/1998 #
############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
function ctc35m06(param)
#--------------------------------------------------------------------
  define param       record
     operacao        char(01),
     socvstlaunum    like datmvstlau.socvstlaunum,
     socvstlautipcod like datmvstlau.socvstlautipcod,
     socvstlautipdes like datkvstlautip.socvstlautipdes,
     viginc          like datmvstlau.viginc,
     vigfnl          like datmvstlau.vigfnl,
     caddat          like datmvstlau.caddat,
     cadfunnom       like isskfunc.funnom,
     cademp          like datmvstlau.cademp,
     cadmat          like datmvstlau.cadmat
  end record

  define a_ctc35m06  array[250] of record
     socvstitmgrpcod like datrvstitmver.socvstitmgrpcod,
     socvstitmgrpdes like datkvstitmgrp.socvstitmgrpdes,
     socvstitmcod    like datrvstitmver.socvstitmcod,
     socvstitmdes    like datkvstitm.socvstitmdes,
     socvstitmvercod like datrvstitmver.socvstitmvercod,
     socvstitmverdes like datkvstitmver.socvstitmverdes,
     socvstitmrevflg like datrvstitmver.socvstitmrevflg
  end record

  define ws          record
     operacao        char(01),
     prxcod          like datrvstitmver.socvstlaunum,
     count           dec(2,0),
     contflg         smallint,
     confirma        smallint,
     socvstitmgrpcod like datkvstitmgrp.socvstitmgrpcod,
     socvstitmgrpsit like datkvstitmgrp.socvstitmgrpsit,
     socvstitmcod    like datkvstitm.socvstitmcod,
     socvstitmsit    like datkvstitm.socvstitmsit,
     socvstitmvercod like datkvstitmver.socvstitmvercod,
     socvstitmversit like datkvstitmver.socvstitmversit
  end record

  define arr_aux      integer
  define scr_aux      integer


  initialize a_ctc35m06  to null
  initialize ws.*        to null
  let arr_aux = 1

  declare c_ctc35m06 cursor for
     select datrvstitmver.socvstitmgrpcod,
            datkvstitmgrp.socvstitmgrpdes,
            datrvstitmver.socvstitmcod,
            datkvstitm.socvstitmdes,
            datrvstitmver.socvstitmvercod,
            datkvstitmver.socvstitmverdes,
            datrvstitmver.socvstitmrevflg
       from datrvstitmver, datkvstitmgrp, datkvstitm, datkvstitmver
      where datrvstitmver.socvstlaunum    = param.socvstlaunum
        and datkvstitmgrp.socvstitmgrpcod = datrvstitmver.socvstitmgrpcod
        and datkvstitm.socvstitmcod       = datrvstitmver.socvstitmcod
        and datkvstitmver.socvstitmvercod = datrvstitmver.socvstitmvercod
   order by datrvstitmver.socvstitmgrpcod,
            datrvstitmver.socvstitmcod,
            datrvstitmver.socvstitmvercod

   foreach c_ctc35m06 into a_ctc35m06[arr_aux].socvstitmgrpcod,
                           a_ctc35m06[arr_aux].socvstitmgrpdes,
                           a_ctc35m06[arr_aux].socvstitmcod,
                           a_ctc35m06[arr_aux].socvstitmdes,
                           a_ctc35m06[arr_aux].socvstitmvercod,
                           a_ctc35m06[arr_aux].socvstitmverdes,
                           a_ctc35m06[arr_aux].socvstitmrevflg

     let arr_aux = arr_aux + 1
     if arr_aux > 250 then
        error " Limite excedido, laudo com mais de 250 grupos/itens"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)
  options comment line last - 1

  open window w_ctc35m06 at 06,2 with form "ctc35m06"
       attribute(form line first)

  message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

  display param.socvstlaunum     to  socvstlaunum
  display param.socvstlautipcod  to  socvstlautipcod
  display param.socvstlautipdes  to  socvstlautipdes
  display param.viginc           to  viginc
  display param.vigfnl           to  vigfnl
  display param.caddat           to  caddat
  display param.cadfunnom        to  cadfunnom

  while true
     let int_flag = false

     input array a_ctc35m06 without defaults from s_ctc35m06.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
              if arr_aux <= arr_count()  then
                 let ws.operacao         = "a"
                 let ws.socvstitmgrpcod  = a_ctc35m06[arr_aux].socvstitmgrpcod
                 let ws.socvstitmcod     = a_ctc35m06[arr_aux].socvstitmcod
                 let ws.socvstitmvercod  = a_ctc35m06[arr_aux].socvstitmvercod
              end if

           before insert
              let ws.operacao = "i"
              initialize a_ctc35m06[arr_aux].*  to null
              display a_ctc35m06[arr_aux].* to s_ctc35m06[scr_aux].*

           before field socvstitmgrpcod
              display a_ctc35m06[arr_aux].socvstitmgrpcod to
                      s_ctc35m06[scr_aux].socvstitmgrpcod attribute (reverse)

           after field socvstitmgrpcod
              display a_ctc35m06[arr_aux].socvstitmgrpcod to
                      s_ctc35m06[scr_aux].socvstitmgrpcod

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("down")  or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field socvstitmgrpcod
              end if

              if a_ctc35m06[arr_aux].socvstitmgrpcod is null then
                 error " Codigo do grupo de itens deve ser informado!"
                 call ctc35m10()  returning a_ctc35m06[arr_aux].socvstitmgrpcod
                 next field socvstitmgrpcod
              end if

              if ws.operacao = "a" and
                 a_ctc35m06[arr_aux].socvstitmgrpcod <> ws.socvstitmgrpcod then
                 error " Codigo do grupo de itens nao deve ser alterado!"
                 next field socvstitmgrpcod
              end if

             initialize a_ctc35m06[arr_aux].socvstitmgrpdes,
                        ws.socvstitmgrpsit  to null
              select socvstitmgrpdes, socvstitmgrpsit
                into a_ctc35m06[arr_aux].socvstitmgrpdes, ws.socvstitmgrpsit
                from datkvstitmgrp
               where datkvstitmgrp.socvstitmgrpcod  =  a_ctc35m06[arr_aux].socvstitmgrpcod

              if sqlca.sqlcode = notfound   then
                 error " Grupo de itens nao cadastrado!"
                 call ctc35m10()  returning a_ctc35m06[arr_aux].socvstitmgrpcod
                 next field socvstitmgrpcod
              end if
              display a_ctc35m06[arr_aux].socvstitmgrpdes  to
                      s_ctc35m06[scr_aux].socvstitmgrpdes

              if ws.socvstitmgrpsit <> "A" then
                 error " Grupo informado nao esta' ativo!"
                 next field socvstitmcod
              end if

           before field socvstitmcod
              display a_ctc35m06[arr_aux].socvstitmcod  to
                      s_ctc35m06[scr_aux].socvstitmcod  attribute (reverse)

           after field socvstitmcod
              display a_ctc35m06[arr_aux].socvstitmcod  to
                     s_ctc35m06[scr_aux].socvstitmcod

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field socvstitmgrpcod
              end if

              if a_ctc35m06[arr_aux].socvstitmcod is null then
                 error " Item de vistoria deve ser informado!"
                 call ctc35m11()  returning  a_ctc35m06[arr_aux].socvstitmcod
                 next field socvstitmcod
              end if

              if ws.operacao = "a" and
                 a_ctc35m06[arr_aux].socvstitmcod <> ws.socvstitmcod then
                 error " Item de vistoria nao deve ser alterado!"
                 next field socvstitmcod
              end if

              initialize a_ctc35m06[arr_aux].socvstitmdes,
                         ws.socvstitmsit to null
              select socvstitmdes, socvstitmsit
                into a_ctc35m06[arr_aux].socvstitmdes, ws.socvstitmsit
                from datkvstitm
               where socvstitmcod = a_ctc35m06[arr_aux].socvstitmcod

              if sqlca.sqlcode <> 0   then
                 error " Codigo do item de vistoria nao cadastrado!"
                 call ctc35m11()  returning  a_ctc35m06[arr_aux].socvstitmcod
                 next field socvstitmcod
              end if

              # VERIFICA SE O ITEM JA ESTA EM OUTRO GRUPO
              #------------------------------------------
              if ws.operacao  =  "i"   then
                 let ws.contflg = 0
                 select count(*) into ws.contflg
                   from datrvstitmver
                  where datrvstitmver.socvstlaunum     = param.socvstlaunum
                    and datrvstitmver.socvstitmgrpcod <> a_ctc35m06[arr_aux].socvstitmgrpcod
                    and datrvstitmver.socvstitmcod     = a_ctc35m06[arr_aux].socvstitmcod

                 if ws.contflg <> 0   then
                    error " Item ja' cadastrado em outro grupo!"
                    next field socvstitmcod
                 end if
              end if

              if ws.socvstitmsit <> "A" then
                 error " Item de vistoria informado nao esta' ativo!"
                 next field socvstitmcod
              end if

              display a_ctc35m06[arr_aux].socvstitmdes  to
                      s_ctc35m06[scr_aux].socvstitmdes

           before field socvstitmvercod
              display a_ctc35m06[arr_aux].socvstitmvercod  to
                      s_ctc35m06[scr_aux].socvstitmvercod  attribute (reverse)

           after field socvstitmvercod
              display a_ctc35m06[arr_aux].socvstitmvercod  to
                      s_ctc35m06[scr_aux].socvstitmvercod

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field socvstitmcod
              end if

              if a_ctc35m06[arr_aux].socvstitmvercod is null then
                 error " Verificacao do item deve ser informado!"
                 call ctc35m12()  returning  a_ctc35m06[arr_aux].socvstitmvercod
                 next field socvstitmvercod
              end if

              if ws.operacao = "a" and
                 a_ctc35m06[arr_aux].socvstitmvercod <> ws.socvstitmvercod then
                 error " Verificacao do item nao deve ser alterado!"
                 next field socvstitmvercod
              end if

              initialize a_ctc35m06[arr_aux].socvstitmverdes,
                         ws.socvstitmversit to null
              select socvstitmverdes, socvstitmversit
                into a_ctc35m06[arr_aux].socvstitmverdes, ws.socvstitmversit
                from datkvstitmver
               where socvstitmvercod = a_ctc35m06[arr_aux].socvstitmvercod

              if sqlca.sqlcode <> 0   then
                 error " Codigo do item de vistoria nao cadastrado!"
                 call ctc35m12()  returning  a_ctc35m06[arr_aux].socvstitmvercod
                 next field socvstitmvercod
              end if

              if ws.socvstitmvercod <> "A" then
                 error " Verificacao do item informado nao esta' ativo!"
                 next field socvstitmvercod
              end if

              #-----------------------------------------------------
              # Verifica se grupo/item/verif. ja' foi cadastrado
              #-----------------------------------------------------
              if ws.operacao  =  "i"   then
                 select * from  datrvstitmver
                  where datrvstitmver.socvstlaunum    = param.socvstlaunum
                    and datrvstitmver.socvstitmgrpcod = a_ctc35m06[arr_aux].socvstitmgrpcod
                    and datrvstitmver.socvstitmcod    = a_ctc35m06[arr_aux].socvstitmcod
                    and datrvstitmver.socvstitmvercod = a_ctc35m06[arr_aux].socvstitmvercod

                 if sqlca.sqlcode = 0   then
                    error " Grupo/item/verificacao ja' cadastrado!"
                    next field socvstitmvercod
                 end if
              end if

              display a_ctc35m06[arr_aux].socvstitmverdes  to
                      s_ctc35m06[scr_aux].socvstitmverdes

           before field socvstitmrevflg
              let ws.contflg = 0
              select count(*) into ws.contflg
                from datrvstitmver
               where datrvstitmver.socvstlaunum    =  param.socvstlaunum
                 and datrvstitmver.socvstitmcod    =  a_ctc35m06[arr_aux].socvstitmcod
                 and datrvstitmver.socvstitmvercod <> a_ctc35m06[arr_aux].socvstitmvercod
                 and datrvstitmver.socvstitmrevflg =  "S"

                 if ws.contflg <> 0  then
                    let a_ctc35m06[arr_aux].socvstitmrevflg = "N"
                 end if

              display a_ctc35m06[arr_aux].socvstitmrevflg to
                      s_ctc35m06[scr_aux].socvstitmrevflg attribute (reverse)

           after field socvstitmrevflg
              display a_ctc35m06[arr_aux].socvstitmrevflg to
                      s_ctc35m06[scr_aux].socvstitmrevflg

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field socvstitmvercod
              end if

              If a_ctc35m06[arr_aux].socvstitmrevflg  is null   or
                (a_ctc35m06[arr_aux].socvstitmrevflg  <> "S"    and
                 a_ctc35m06[arr_aux].socvstitmrevflg  <> "N")   then
                 error " Revistoria para este item deve ser: (S)im ou (N)ao!"
                 next field socvstitmrevflg
              end if

              If a_ctc35m06[arr_aux].socvstitmrevflg  =  "S"    and
                 ws.contflg <> 0    then
                 error " Ja' existe uma verificacao deste mesmo item com (S)!"
                 next field socvstitmrevflg
              end if

              display a_ctc35m06[arr_aux].socvstitmrevflg  to
                      s_ctc35m06[scr_aux].socvstitmrevflg

           on key (interrupt)
              exit input

           before delete
              let ws.operacao = "d"
              if a_ctc35m06[arr_aux].socvstitmgrpcod  is null   or
                 a_ctc35m06[arr_aux].socvstitmcod  is null   then
                 continue input
              end if

              if param.viginc  <=  today   then
                 error " Grupo vigente nao deve ser removido!"
                 exit input
              end if

              let  ws.confirma = true
              call ctc35m14() returning ws.confirma
              if ws.confirma = false   then
                 exit input
              end if

              let ws.count = 0
              select count(*)  into  ws.count
                from datrvstitmver
               where socvstlaunum  =  param.socvstlaunum

              if ws.count =  1   then
                 error " Vigencia deve ser removida!"
                 exit input
              end if

              begin work
                 delete from datrvstitmver
                  where socvstlaunum    = param.socvstlaunum
                    and socvstitmcod    = a_ctc35m06[arr_aux].socvstitmcod
                    and socvstitmrevflg = a_ctc35m06[arr_aux].socvstitmrevflg
              commit work

              initialize a_ctc35m06[arr_aux].* to null
              display a_ctc35m06[arr_aux].* to s_ctc35m06[scr_aux].*

           after row

              begin work
              case ws.operacao
                 when "i"
                    if param.operacao = "i"   then  #--> qdo inclui vigencia
                       initialize param.operacao  to null
                       call ctc35m06_vig(param.*) returning param.socvstlaunum
                       if param.socvstlaunum  is null   then
                          exit input
                       end if
                    end if

                    insert into datrvstitmver
                                (socvstlaunum,
                                 socvstitmgrpcod,
                                 socvstitmcod,
                                 socvstitmvercod,
                                 socvstitmrevflg)
                           values
                                (param.socvstlaunum,
                                 a_ctc35m06[arr_aux].socvstitmgrpcod,
                                 a_ctc35m06[arr_aux].socvstitmcod,
                                 a_ctc35m06[arr_aux].socvstitmvercod,
                                 a_ctc35m06[arr_aux].socvstitmrevflg)
              end case
              commit work

              let ws.operacao = " "
     end input

     if int_flag    then
        exit while
     end if

 end while

 let int_flag = false
 close c_ctc35m06
 options comment line last
 close window w_ctc35m06

end function   #--  ctc35m06


#---------------------------------------------------------------
function ctc35m06_vig(param2)
#---------------------------------------------------------------
  define param2      record
     operacao        char(01),
     socvstlaunum    like datmvstlau.socvstlaunum,
     socvstlautipcod like datmvstlau.socvstlautipcod,
     socvstlautipdes like datkvstlautip.socvstlautipdes,
     viginc          like datmvstlau.viginc,
     vigfnl          like datmvstlau.vigfnl,
     caddat          like datmvstlau.caddat,
     cadfunnom       like isskfunc.funnom,
     cademp          like datmvstlau.cademp,
     cadmat          like datmvstlau.cadmat
  end record

  define ws_resp      char(01)

  declare ctc35m06m  cursor with hold  for
          select  max(socvstlaunum)
            from  datmvstlau
           where  datmvstlau.socvstlaunum > 0

  foreach ctc35m06m  into  param2.socvstlaunum
      exit foreach
  end foreach

  if param2.socvstlaunum is null   then
     let param2.socvstlaunum = 0
  end if
  let param2.socvstlaunum = param2.socvstlaunum + 1

  insert into datmvstlau (socvstlaunum,
                          socvstlautipcod,
                          viginc,
                          vigfnl,
                          caddat,
                          cademp,
                          cadmat)
                 values  (param2.socvstlaunum,
                          param2.socvstlautipcod,
                          param2.viginc,
                          param2.vigfnl,
                          today,
                          g_issk.empcod,
                          g_issk.funmat)

  if sqlca.sqlcode <>  0  then
     error " Erro (",sqlca.sqlcode,") na Inclusao do Laudo!"
     rollback work
     initialize param2.socvstlaunum  to null
     return param2.socvstlaunum
  else
     display param2.socvstlaunum  to  socvstlaunum  attribute (reverse)
     error " Verifique o codigo do registro e tecle ENTER!"
     prompt "" for char ws_resp
  end if

  return param2.socvstlaunum

end function  #  ctc35m06_vig
