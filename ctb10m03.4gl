#-------------------------------------------------------------------------#
# Menu de Modulo: CTB10M03                                       Gilberto #
#                                                                 Marcelo #
# Manutencao no cadastro de vigencias de tarifas                 Nov/1996 #
#-------------------------------------------------------------------------#
#                               ALTERACOES                                #
# Fabrica de Software - Teresinha Silva  - 22/10/2003 - OSF 25143         #
# Objetivo : Aumentar o tamanho do array de 50 para 500 posicoes          #
#-------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
function ctb10m03(param)
#--------------------------------------------------------------------
  define param         record
     operacao        char(01),
     soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
     soctrfvigincdat like dbsmvigtrfsocorro.soctrfvigincdat,
     soctrfvigfnldat like dbsmvigtrfsocorro.soctrfvigfnldat,
     caddat          like dbsmvigtrfsocorro.caddat,
     cadfunnom       like isskfunc.funnom,
     atldat          like dbsmvigtrfsocorro.atldat,
     funnom          like isskfunc.funnom,
     soctrfcod       like dbsmvigtrfsocorro.soctrfcod,
     soctrfdes       like dbsktarifasocorro.soctrfdes
  end record

  define a_ctb10m03  array[500] of record
     socgtfcod       like dbstgtfcst.socgtfcod,
     socgtfdes       like dbskgtf.socgtfdes,
     soccstcod       like dbstgtfcst.soccstcod,
     soccstdes       like dbskcustosocorro.soccstdes,
     socgtfcstvlr    like dbstgtfcst.socgtfcstvlr
  end record

  define ws          record
     operacao        char(01),
     prxcod          like dbstgtfcst.soctrfvignum,
     count           dec(2,0),
     confirma        char (01),
     soccstsitcod    like dbskcustosocorro.soccstsitcod,
     socgtfcod       like dbstgtfcst.socgtfcod,
     soccstcod       like dbstgtfcst.soccstcod,
     socgtfcstvlr    like dbstgtfcst.socgtfcstvlr,
     soccstexbseq    like dbskcustosocorro.soccstexbseq
  end record

  define arr_aux      integer
  define scr_aux      integer


  initialize a_ctb10m03  to null
  initialize ws.*        to null
  let arr_aux = 1

  declare c_ctb10m03 cursor for
     select dbstgtfcst.socgtfcod,
            dbskgtf.socgtfdes,
            dbstgtfcst.soccstcod,
            dbskcustosocorro.soccstdes,
            dbstgtfcst.socgtfcstvlr,
            dbskcustosocorro.soccstexbseq
      from dbstgtfcst, dbskgtf, dbskcustosocorro
     where dbstgtfcst.soctrfvignum    = param.soctrfvignum     and
           dbskgtf.socgtfcod          = dbstgtfcst.socgtfcod   and
           dbskcustosocorro.soccstcod = dbstgtfcst.soccstcod
    order by dbstgtfcst.socgtfcod,
             dbskcustosocorro.soccstexbseq

   foreach c_ctb10m03 into a_ctb10m03[arr_aux].socgtfcod,
                           a_ctb10m03[arr_aux].socgtfdes,
                           a_ctb10m03[arr_aux].soccstcod,
                           a_ctb10m03[arr_aux].soccstdes,
                           a_ctb10m03[arr_aux].socgtfcstvlr,
                           ws.soccstexbseq

     let arr_aux = arr_aux + 1
     if arr_aux > 500 then
        error " Limite excedido, vigencia com mais de 500 grupos/custos"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)
  options comment line last - 1

  open window w_ctb10m03 at 06,2 with form "ctb10m03"
       attribute(form line first)

  message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

  display param.soctrfvignum     to  soctrfvignum
  display param.soctrfvigincdat  to  soctrfvigincdat
  display param.soctrfvigfnldat  to  soctrfvigfnldat
  display param.caddat           to  caddat
  display param.cadfunnom        to  cadfunnom
  display param.atldat           to  atldat
  display param.funnom           to  funnom
  display param.soctrfcod        to  soctrfcod
  display param.soctrfdes        to  soctrfdes

  while true
     let int_flag = false

     input array a_ctb10m03 without defaults from s_ctb10m03.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
              if arr_aux <= arr_count()  then
                 let ws.operacao     = "a"
                 let ws.socgtfcod    = a_ctb10m03[arr_aux].socgtfcod
                 let ws.soccstcod    = a_ctb10m03[arr_aux].soccstcod
                 let ws.socgtfcstvlr = a_ctb10m03[arr_aux].socgtfcstvlr
              end if

           before insert
              let ws.operacao = "i"
              initialize a_ctb10m03[arr_aux].*  to null
              display a_ctb10m03[arr_aux].* to s_ctb10m03[scr_aux].*

           before field socgtfcod
              display a_ctb10m03[arr_aux].socgtfcod to
                      s_ctb10m03[scr_aux].socgtfcod attribute (reverse)

           after field socgtfcod
              display a_ctb10m03[arr_aux].socgtfcod to
                      s_ctb10m03[scr_aux].socgtfcod

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("down")  or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field socgtfcod
              end if

              if a_ctb10m03[arr_aux].socgtfcod   is null    then
                 error " Codigo do grupo tarifario deve ser informado!"
                 call ctb10m09()  returning a_ctb10m03[arr_aux].socgtfcod
                 next field socgtfcod
              end if

              if ws.operacao          =  "a"                       and
                 a_ctb10m03[arr_aux].socgtfcod  <>  ws.socgtfcod   then
                 error " Codigo do grupo tarifario nao deve ser alterado!"
                 next field socgtfcod
              end if

             initialize a_ctb10m03[arr_aux].socgtfdes   to null
              select socgtfdes
                into a_ctb10m03[arr_aux].socgtfdes
                from dbskgtf
               where dbskgtf.socgtfcod  =  a_ctb10m03[arr_aux].socgtfcod

              if sqlca.sqlcode = notfound   then
                 error " Grupo tarifario nao cadastrado!"
                 call ctb10m09()  returning a_ctb10m03[arr_aux].socgtfcod
                 next field socgtfcod
              end if
              display a_ctb10m03[arr_aux].socgtfdes  to
                      s_ctb10m03[scr_aux].socgtfdes

           before field soccstcod
              display a_ctb10m03[arr_aux].soccstcod  to
                      s_ctb10m03[scr_aux].soccstcod  attribute (reverse)

           after field soccstcod
              display a_ctb10m03[arr_aux].soccstcod  to
                     s_ctb10m03[scr_aux].soccstcod

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field socgtfcod
              end if

              if a_ctb10m03[arr_aux].soccstcod   is null   then
                 error " Codigo do custo deve ser informado!"
                 call ctb10m06()  returning  a_ctb10m03[arr_aux].soccstcod
                 next field soccstcod
              end if

              if ws.operacao          =  "a"                       and
                 a_ctb10m03[arr_aux].soccstcod  <>  ws.soccstcod   then
                 error " Custo nao deve ser alterado!"
                 next field soccstcod
              end if

              initialize ws.soccstsitcod   to null
              select soccstsitcod, soccstdes
                into ws.soccstsitcod, a_ctb10m03[arr_aux].soccstdes
                from dbskcustosocorro
               where soccstcod = a_ctb10m03[arr_aux].soccstcod

              if sqlca.sqlcode <> 0   then
                 error " Codigo do custo nao cadastrado!"
                 call ctb10m06()  returning  a_ctb10m03[arr_aux].soccstcod
                 next field soccstcod
              end if

              if ws.soccstsitcod  <>  "A"   then
                 error " Custo informado nao esta' ativo!"
                 next field soccstcod
              end if

              display a_ctb10m03[arr_aux].soccstdes  to
                      s_ctb10m03[scr_aux].soccstdes

              #-----------------------------------------------------
              # Verifica se grupo tarifario/custo ja' foi cadastrado
              #-----------------------------------------------------
              if ws.operacao  =  "i"   then
                 select * from  dbstgtfcst
                  where dbstgtfcst.soctrfvignum = param.soctrfvignum
                    and dbstgtfcst.socgtfcod    = a_ctb10m03[arr_aux].socgtfcod
                    and dbstgtfcst.soccstcod    = a_ctb10m03[arr_aux].soccstcod

                 if sqlca.sqlcode = 0   then
                    error " Grupo tarifario/Custo ja' cadastrado!"
                    next field socgtfcod
                 end if
              end if

           before field socgtfcstvlr
              display a_ctb10m03[arr_aux].socgtfcstvlr  to
                      s_ctb10m03[scr_aux].socgtfcstvlr  attribute (reverse)

           after field socgtfcstvlr
              display a_ctb10m03[arr_aux].socgtfcstvlr  to
                      s_ctb10m03[scr_aux].socgtfcstvlr

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field soccstcod
              end if

              if a_ctb10m03[arr_aux].socgtfcstvlr   is null   or
                 a_ctb10m03[arr_aux].socgtfcstvlr   = 0000    then
                 error " Valor do grupo tarifario/custo deve ser informado!"
                 next field socgtfcstvlr
              end if

              if ws.operacao          =  "a"                            and
                 a_ctb10m03[arr_aux].socgtfcstvlr  <>  ws.socgtfcstvlr  then
                 error " Valor do grupo tarifario/custo nao deve ser alterado!"
                next field socgtfcstvlr
              end if

           on key (interrupt)
              exit input

           before delete
              let ws.operacao = "d"
              if a_ctb10m03[arr_aux].socgtfcod  is null   or
                 a_ctb10m03[arr_aux].soccstcod  is null   then
                 continue input
              end if

              if param.soctrfvigincdat  <=  today   then
                 error " Grupo tarifario/custo vigente nao deve ser removido!"
                 exit input
              end if

              let  ws.confirma = "N"
              call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                   returning ws.confirma

              if ws.confirma = "N"   then
                 exit input
              end if

              let ws.count = 0
              select count(*)  into  ws.count
                from dbstgtfcst
               where soctrfvignum  =  param.soctrfvignum

              if ws.count =  1   then
                 error " Vigencia deve ser removida!"
                 exit input
              end if

              begin work
                 delete from dbstgtfcst
                  where soctrfvignum  = param.soctrfvignum              and
                        socgtfcod     = a_ctb10m03[arr_aux].socgtfcod   and
                        soccstcod     = a_ctb10m03[arr_aux].soccstcod
              commit work

              initialize a_ctb10m03[arr_aux].* to null
              display a_ctb10m03[arr_aux].* to s_ctb10m03[scr_aux].*

           after row

              begin work
              case ws.operacao
                 when "i"
                    if param.operacao = "i"   then  #--> qdo inclui vigencia
                       initialize param.operacao  to null
                       call vig_ctb10m03(param.*) returning param.soctrfvignum
                       if param.soctrfvignum  is null   then
                          exit input
                       end if
                    end if

                    insert into dbstgtfcst
                                (soctrfvignum,
                                 socgtfcod,
                                 soccstcod,
                                 socgtfcstvlr
                                )
                           values
                                (param.soctrfvignum,
                                 a_ctb10m03[arr_aux].socgtfcod,
                                 a_ctb10m03[arr_aux].soccstcod,
                                 a_ctb10m03[arr_aux].socgtfcstvlr
                                )
              end case
              commit work

              let ws.operacao = " "
     end input

     if int_flag    then
        exit while
     end if

 end while

 let int_flag = false
 close c_ctb10m03
 options comment line last
 close window w_ctb10m03

end function   #--  ctb10m03


#---------------------------------------------------------------
function vig_ctb10m03(param2)
#---------------------------------------------------------------
  define param2       record
     operacao         char(01),
     soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum,
     soctrfvigincdat  like dbsmvigtrfsocorro.soctrfvigincdat,
     soctrfvigfnldat  like dbsmvigtrfsocorro.soctrfvigfnldat,
     caddat           like dbsmvigtrfsocorro.caddat,
     cadfunnom        like isskfunc.funnom,
     atldat           like dbsmvigtrfsocorro.atldat,
     funnom           like isskfunc.funnom,
     soctrfcod        like dbsmvigtrfsocorro.soctrfcod,
     soctrfdes        like dbsktarifasocorro.soctrfdes
  end record

  define ws_resp      char(01)


  declare ctb10m03m  cursor with hold  for
          select  max(soctrfvignum)
            from  dbsmvigtrfsocorro
           where  dbsmvigtrfsocorro.soctrfvignum > 0

  foreach ctb10m03m  into  param2.soctrfvignum
      exit foreach
  end foreach

  if param2.soctrfvignum is null   then
     let param2.soctrfvignum = 0
  end if
  let param2.soctrfvignum = param2.soctrfvignum + 1

  insert into dbsmvigtrfsocorro (soctrfvignum,
                                 soctrfvigincdat,
                                 soctrfvigfnldat,
                                 soctrfcod,
                                 caddat,
                                 cadfunmat,
                                 atldat,
                                 funmat
                                )
                        values  (param2.soctrfvignum,
                                 param2.soctrfvigincdat,
                                 param2.soctrfvigfnldat,
                                 param2.soctrfcod,
                                 today,
                                 g_issk.funmat,
                                 today,
                                 g_issk.funmat
                                )

  if sqlca.sqlcode <>  0  then
     error " Erro (",sqlca.sqlcode,") na Inclusao da Vigencia!"
     rollback work
     initialize param2.soctrfvignum  to null
     return param2.soctrfvignum
  else
     display param2.soctrfvignum  to  soctrfvignum  attribute (reverse)
     error " Verifique o codigo do registro e tecle ENTER!"
     prompt "" for char ws_resp
  end if

  return param2.soctrfvignum

end function  #  vig_ctb10m03
