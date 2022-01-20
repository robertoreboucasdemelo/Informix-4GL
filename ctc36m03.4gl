#############################################################################
# Nome de Modulo: CTC36M03                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Manutencao dos itens da Vistoria                                 Dez/1998 #
#############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define d_ctc36m03  record
   socvstsit       like datmsocvst.socvstsit,
   sitdesc         char(30)
end record

#--------------------------------------------------------------------
function ctc36m03(param)
#--------------------------------------------------------------------
  define param       record
     socvstnum       like datmvstmvt.socvstnum,
     atlemp          like datmsocvst.atlemp,
     atlmat          like datmsocvst.atlmat
  end record

  define a_ctc36m03  array[700] of record
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
     socvstlaunum    like datrvstitmver.socvstlaunum,
     socvstitmsit    like datkvstitm.socvstitmsit,
     socvstitmvercod like datkvstitmver.socvstitmvercod,
     socvstitmversit like datkvstitmver.socvstitmversit,
     count           dec (5,0),
     operacao        char (01)
  end record

  define arr_aux     smallint
  define scr_aux     smallint

  initialize a_ctc36m03    to null
  initialize d_ctc36m03.*  to null
  initialize ws.*          to null

  open window w_ctc36m03 at 06,02 with form "ctc36m03"
       attribute(form line first, comment line last - 1)

  let arr_aux = 1

  # CARREGA DADOS DA VISTORIA
  #--------------------------
  select socvstlautipcod, socvstsit
   into ws.socvstlautipcod, d_ctc36m03.socvstsit
    from datmsocvst
   where socvstnum = param.socvstnum

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura da vistoria! "
     close window w_ctc36m03
     return
  end if

  select cpodes
    into d_ctc36m03.sitdesc
    from iddkdominio
   where cponom = "socvstsit"
     and cpocod = d_ctc36m03.socvstsit

  if sqlca.sqlcode <> 0 then
     let d_ctc36m03.sitdesc = "INVALIDO !!"
  end if

  display by name param.socvstnum
  display by name d_ctc36m03.socvstsit
  display by name d_ctc36m03.sitdesc

  select socvstlaunum into ws.socvstlaunum
    from datmvstlau
   where datmvstlau.socvstlautipcod = ws.socvstlautipcod
     and (datmvstlau.viginc <= today and
          datmvstlau.vigfnl >= today)

  if sqlca.sqlcode <> 0    then
     if sqlca.sqlcode = 100   then
        error " Laudo fora da vigencia! "
     else
        error " Erro (",sqlca.sqlcode,") na leitura do tipo de laudo! "
     end if
     close window w_ctc36m03
     return
  end if

  # MONTA ITENS DA VISTORIA
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctc36m03  cursor for
    select datmvstmvt.socvstitmcod      , datmvstmvt.socvstitmvercod   ,
           datmvstmvt.socvstitmgrpcod
      from datmvstmvt
     where datmvstmvt.socvstnum    = param.socvstnum
     order by datmvstmvt.socvstitmgrpcod, datmvstmvt.socvstitmcod

  foreach c_ctc36m03 into a_ctc36m03[arr_aux].socvstitmcod,
                          a_ctc36m03[arr_aux].socvstitmvercod,
                          a_ctc36m03[arr_aux].socvstitmgrpcod

     select socvstitmdes into a_ctc36m03[arr_aux].socvstitmdes
       from datkvstitm
      where datkvstitm.socvstitmcod = a_ctc36m03[arr_aux].socvstitmcod

     if sqlca.sqlcode <> 0    then
        let a_ctc36m03[arr_aux].socvstitmdes = "Item nao cadatrado!"
     end if

     select socvstitmverdes into a_ctc36m03[arr_aux].socvstitmverdes
       from datkvstitmver
      where datkvstitmver.socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod

     if sqlca.sqlcode <> 0    then
        let a_ctc36m03[arr_aux].socvstitmverdes = "Verificacao nao cadatrado!"
     end if

     select socvstitmgrpdes into a_ctc36m03[arr_aux].socvstitmgrpdes
       from datkvstitmgrp
      where datkvstitmgrp.socvstitmgrpcod = a_ctc36m03[arr_aux].socvstitmgrpcod

     if sqlca.sqlcode <> 0    then
        let a_ctc36m03[arr_aux].socvstitmgrpdes = "Grupo nao cadatrado!"
     end if

     select socvstitmrevflg into a_ctc36m03[arr_aux].revidesc
       from datrvstitmver
      where datrvstitmver.socvstlaunum    = ws.socvstlaunum
        and datrvstitmver.socvstitmcod    = a_ctc36m03[arr_aux].socvstitmcod
        and datrvstitmver.socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod

     if a_ctc36m03[arr_aux].revidesc = "N" then
        let a_ctc36m03[arr_aux].revidesc = " "
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 700   then
        error " Limite excedido! Vistoria com mais de 700 itens!"
        exit foreach
     end if

  end foreach

  message ""
  call set_count(arr_aux-1)

  if  d_ctc36m03.socvstsit <> 3 then

    message " (F17)Abandona"

    display array  a_ctc36m03 to s_ctc36m03.*

      on key(interrupt)
         exit display

    end display

   else

    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

    while true
       let int_flag = false

       input array a_ctc36m03 without defaults from s_ctc36m03.*
          before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
                if arr_aux <= arr_count()  then
                   let ws.operacao = "a"
                end if

             before insert
                let ws.operacao = "i"
                initialize a_ctc36m03[arr_aux].*  to null
                display a_ctc36m03[arr_aux].* to s_ctc36m03[scr_aux].*

             before field socvstitmcod
                if ws.operacao = "a" then
                   let ws.socvstitmcod  = a_ctc36m03[arr_aux].socvstitmcod
                end if
                display a_ctc36m03[arr_aux].socvstitmcod    to
                        s_ctc36m03[scr_aux].socvstitmcod    attribute (reverse)

             after field socvstitmcod
                if ws.operacao = "a" then
                   let a_ctc36m03[arr_aux].socvstitmcod = ws.socvstitmcod
                end if
                display a_ctc36m03[arr_aux].socvstitmcod    to
                        s_ctc36m03[scr_aux].socvstitmcod

                if a_ctc36m03[arr_aux].socvstitmcod is null then
                   error " Item de vistoria deve ser informado!"
                   call ctc35m11()  returning  a_ctc36m03[arr_aux].socvstitmcod
                   next field socvstitmcod
                end if

                initialize a_ctc36m03[arr_aux].socvstitmdes,
                           ws.socvstitmsit to null
                select socvstitmdes, socvstitmsit
                  into a_ctc36m03[arr_aux].socvstitmdes, ws.socvstitmsit
                  from datkvstitm
                 where socvstitmcod = a_ctc36m03[arr_aux].socvstitmcod

                if sqlca.sqlcode <> 0   then
                   error " Codigo do item de vistoria nao cadastrado!"
                   call ctc35m11()  returning  a_ctc36m03[arr_aux].socvstitmcod
                   next field socvstitmcod
                end if

                # VERIFICA SE O ITEM CONSTA NO LAUDO DO VEICULO
                #----------------------------------------------
                if ws.operacao  =  "i"   then
                   let ws.count = 0
                   select count(*) into ws.count
                     from datmvstmvt
                    where datmvstmvt.socvstnum    = param.socvstnum
                      and datmvstmvt.socvstitmcod = a_ctc36m03[arr_aux].socvstitmcod

                   if ws.count <> 0 then
                      error " Item ja' verificado neste laudo !"
                      next field socvstitmcod
                   end if

                   initialize a_ctc36m03[arr_aux].socvstitmgrpcod to null
                   declare curgrp cursor for
                    select socvstitmgrpcod
                      from datrvstitmver
                     where datrvstitmver.socvstlaunum = ws.socvstlaunum
                       and datrvstitmver.socvstitmcod = a_ctc36m03[arr_aux].socvstitmcod
                    foreach curgrp into a_ctc36m03[arr_aux].socvstitmgrpcod
                       exit foreach
                    end foreach

                    if a_ctc36m03[arr_aux].socvstitmgrpcod is null then
                       error " Item nao cadastrado neste tipo de laudo !"
                       next field socvstitmcod
                    end if
                end if

                select socvstitmgrpdes into a_ctc36m03[arr_aux].socvstitmgrpdes
                  from datkvstitmgrp
                 where datkvstitmgrp.socvstitmgrpcod = a_ctc36m03[arr_aux].socvstitmgrpcod

                 if sqlca.sqlcode <> 0    then
                    let a_ctc36m03[arr_aux].socvstitmgrpdes = "Grupo nao cadatrado!"
                 end if

                if ws.socvstitmsit <> "A" then
                   error " Item de vistoria informado nao esta' ativo!"
                   next field socvstitmcod
                end if

                display a_ctc36m03[arr_aux].socvstitmdes     to
                        s_ctc36m03[scr_aux].socvstitmdes

                display a_ctc36m03[arr_aux].socvstitmgrpcod  to
                        s_ctc36m03[scr_aux].socvstitmgrpcod

                display a_ctc36m03[arr_aux].socvstitmgrpdes  to
                        s_ctc36m03[scr_aux].socvstitmgrpdes

             before field socvstitmvercod
                if ws.operacao = "a" then
                   let ws.socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod
                end if
                display a_ctc36m03[arr_aux].socvstitmvercod  to
                        s_ctc36m03[scr_aux].socvstitmvercod  attribute (reverse)

             after field socvstitmvercod
                if ws.operacao = "a" then
                   let a_ctc36m03[arr_aux].socvstitmvercod = ws.socvstitmvercod
                end if
                display a_ctc36m03[arr_aux].socvstitmvercod  to
                        s_ctc36m03[scr_aux].socvstitmvercod

                if fgl_lastkey() = fgl_keyval("up")   or
                   fgl_lastkey() = fgl_keyval("left") then
                   next field socvstitmcod
                end if

                if a_ctc36m03[arr_aux].socvstitmvercod is null then
                   error " Verificacao do item deve ser informado!"
                   call ctc35m12()  returning  a_ctc36m03[arr_aux].socvstitmvercod
                   next field socvstitmvercod
                end if

                initialize a_ctc36m03[arr_aux].socvstitmverdes,
                           ws.socvstitmversit to null
                select socvstitmverdes, socvstitmversit
                  into a_ctc36m03[arr_aux].socvstitmverdes, ws.socvstitmversit
                  from datkvstitmver
                 where socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod

                if sqlca.sqlcode <> 0   then
                   error " Codigo do item de vistoria nao cadastrado!"
                   call ctc35m12()  returning  a_ctc36m03[arr_aux].socvstitmvercod
                   next field socvstitmvercod
                end if

                if ws.socvstitmversit <> "A" then
                   error " Verificacao do item informado nao esta' ativo!"
                   next field socvstitmvercod
                end if

                #-----------------------------------------------------
                # Verifica se grupo/item/verif. ja' foi cadastrado
                #-----------------------------------------------------
                if ws.operacao  =  "i"   then
                 select * from  datrvstitmver
                    where datrvstitmver.socvstlaunum    = ws.socvstlaunum
                      and datrvstitmver.socvstitmcod    = a_ctc36m03[arr_aux].socvstitmcod
                      and datrvstitmver.socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod

                   if sqlca.sqlcode <> 0   then
                      error " Item/Verificacao para este laudo nao cadastrado!"
                      next field socvstitmvercod
                   end if
                end if

                display a_ctc36m03[arr_aux].socvstitmverdes  to
                        s_ctc36m03[scr_aux].socvstitmverdes

                select socvstitmrevflg into a_ctc36m03[arr_aux].revidesc
                  from datrvstitmver
                 where datrvstitmver.socvstlaunum    = ws.socvstlaunum
                   and datrvstitmver.socvstitmcod    = a_ctc36m03[arr_aux].socvstitmcod
                   and datrvstitmver.socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod

                if a_ctc36m03[arr_aux].revidesc = "N" then
                   let a_ctc36m03[arr_aux].revidesc = " "
                end if

                display a_ctc36m03[arr_aux].*  to  s_ctc36m03[scr_aux].*
             on key(esc,interrupt)
                exit input

             before delete
                let ws.operacao = "d"
                if a_ctc36m03[arr_aux].socvstitmcod   is null   or
                   a_ctc36m03[arr_aux].socvstitmcod   =  0      then
                   continue input
                end if

                if ctc35m14() = false  then
                   exit input
                end if

                # CASO SEJA ULTIMO ITEM DA VISTORIA
                # ---------------------------------
                let ws.count = 0
                select count(*)  into  ws.count
                 from datmvstmvt
                 where socvstnum  =  param.socvstnum

                if ws.count = 1   then
                   error " Nao e' possivel excluir todos itens da vistoria em digitacao!"
                   exit input
                end if

                begin work
                 delete from datmvstmvt
                  where datmvstmvt.socvstnum       = param.socvstnum
                    and datmvstmvt.socvstitmcod    = a_ctc36m03[arr_aux].socvstitmcod
                    and datmvstmvt.socvstitmvercod = a_ctc36m03[arr_aux].socvstitmvercod

                 if sqlca.sqlcode <> 0   then
                    error "Erro (",sqlca.sqlcode,") na exclusao do item da vistoria!"
                    next field socvstitmcod
                 end if
                commit work

                initialize a_ctc36m03[arr_aux].* to null
                display a_ctc36m03[arr_aux].* to s_ctc36m03[scr_aux].*

             after row
                case ws.operacao
                   when "i"         # INCLUI ITEM DA VISTORIA
                      begin work
                      insert into datmvstmvt
                                  (socvstnum,
                                   socvstitmcod,
                                   socvstitmvercod,
                                   socvstitmgrpcod)
                           values (param.socvstnum,
                                   a_ctc36m03[arr_aux].socvstitmcod,
                                   a_ctc36m03[arr_aux].socvstitmvercod,
                                   a_ctc36m03[arr_aux].socvstitmgrpcod)
                      if sqlca.sqlcode <>  0  then
                         error " Erro (",sqlca.sqlcode,") na alteracao da vistoria!"
                         rollback work
                         initialize a_ctc36m03  to null
                         next field socvstitmcod
                      end if
                      commit work

                   when "a"         # ALTERA ITEM DA VISTORIA
 #                     begin work
 #                     commit work
                end case

                display a_ctc36m03[arr_aux].* to s_ctc36m03[scr_aux].*
                let ws.operacao = " "
       end input

       # FAZ BATIMENTO E ATUALIZA SITUACAO DA VISTORIA
       #----------------------------------------------
       if int_flag    then
          call ctc36m04(param.socvstnum, param.atlemp, param.atlmat)
          exit while
       end if

   end while

 end if

 let int_flag = false
 close window w_ctc36m03

end function  ###  ctc36m03

