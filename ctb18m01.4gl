###############################################################################
# Nome do Modulo: CTB18M01                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Cronograma das datas de entrega do movimento dos servicos          Dez/1999 #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function ctb18m01(param)
#--------------------------------------------------------------

 define param        record
    crnpgtcod        like dbsmcrnpgtetg.crnpgtcod
 end record

 define a_ctb18m01   array[100] of record
    crnpgtetgdat     like dbsmcrnpgtetg.crnpgtetgdat
 end record

 define ws           record
    crnpgtdes        like dbsmcrnpgt.crnpgtdes,
    crnpgtetgdat     like dbsmcrnpgtetg.crnpgtetgdat,
    confirma         char (01),
    operacao         char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer
 define x            smallint


 initialize a_ctb18m01  to null
 initialize ws.*        to null

 for arr_aux = 1 to 100
    let a_ctb18m01[arr_aux].crnpgtetgdat = null
 end for

 let arr_aux = 1

 open window ctb18m01 at 10,22 with form "ctb18m01"
             attribute (form line 1, border, comment line last - 1)

 select crnpgtdes
   into ws.crnpgtdes
   from dbsmcrnpgt
  where crnpgtcod = param.crnpgtcod

 display by name param.crnpgtcod, ws.crnpgtdes

 declare c_ctb18m01 cursor for
  select dbsmcrnpgtetg.crnpgtetgdat
    from dbsmcrnpgtetg
   where dbsmcrnpgtetg.crnpgtcod  = param.crnpgtcod

 foreach c_ctb18m01 into a_ctb18m01[arr_aux].crnpgtetgdat

    let arr_aux = arr_aux + 1
    if arr_aux > 100 then
       error " Limite excedido, cronograma com mais de 30 datas"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)
 options comment line last - 1

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 while true

    let int_flag = false

    input array a_ctb18m01 without defaults from s_ctb18m01.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
          else
             let ws.operacao = "i"
             initialize a_ctb18m01[arr_aux].*  to null
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctb18m01[arr_aux].*  to null
          display a_ctb18m01[arr_aux].* to s_ctb18m01[scr_aux].*

       before field crnpgtetgdat
          display a_ctb18m01[arr_aux].crnpgtetgdat to
                  s_ctb18m01[scr_aux].crnpgtetgdat attribute (reverse)
          let ws.crnpgtetgdat = a_ctb18m01[arr_aux].crnpgtetgdat


       after  field crnpgtetgdat
          display a_ctb18m01[arr_aux].crnpgtetgdat to
                  s_ctb18m01[scr_aux].crnpgtetgdat

           if fgl_lastkey() <> fgl_keyval ("up")     and
              fgl_lastkey() <> fgl_keyval ("left")   then
              if a_ctb18m01[arr_aux].crnpgtetgdat is null then
                 if ws.operacao = "a"    then
                    error " Data nao pode ser modificada!"
                    let a_ctb18m01[arr_aux].crnpgtetgdat = ws.crnpgtetgdat
                    next field crnpgtetgdat
                 else
                    error " Data entrega deve ser informada!"
                    next field crnpgtetgdat
                 end if
              end if

              if ws.operacao = "a"                                   and
                 ws.crnpgtetgdat <> a_ctb18m01[arr_aux].crnpgtetgdat then
                 error " Data nao pode ser modificada!"
                 let a_ctb18m01[arr_aux].crnpgtetgdat = ws.crnpgtetgdat
                 next field crnpgtetgdat
              end if

              if ws.operacao <> "a"                        and
                 a_ctb18m01[arr_aux].crnpgtetgdat <= today then
                 error " Data entrega deve ser maior que hoje!"
                 next field crnpgtetgdat
              end if

              for x = 1 to 20
                  if arr_aux <> x                                and
                     a_ctb18m01[arr_aux].crnpgtetgdat =
                     a_ctb18m01[x].crnpgtetgdat                  then
                     error " Data ja' consta neste cronograma!"
                     sleep 2
                     initialize a_ctb18m01[arr_aux].crnpgtetgdat to null
                     next field crnpgtetgdat
                  end if
              end for
           end if

       before delete
          let ws.operacao = "d"
          if a_ctb18m01[arr_aux].crnpgtetgdat is not null then
             display a_ctb18m01[arr_aux].crnpgtetgdat to
                     s_ctb18m01[scr_aux].crnpgtetgdat
             while true
                call cts08g01("C","S","","CONFIRA EXCLUSAO DESTA DATA ?","","")
                     returning ws.confirma
                if ws.confirma = "S"  then
                   delete from dbsmcrnpgtetg
                    where crnpgtcod    = param.crnpgtcod
                      and crnpgtetgdat = a_ctb18m01[arr_aux].crnpgtetgdat

                   if sqlca.sqlcode <> 0 then
                      error " Erro (", sqlca.sqlcode, ") na exclusao desta data, favor verificar!"
                   else
                      initialize a_ctb18m01[arr_aux].* to null
                      display a_ctb18m01[arr_aux].* to s_ctb18m01[scr_aux].*
                   end if
                   exit while
                else
                   if ws.confirma = "N" then
                      exit input
                   end if
                end if
             end while
          end if

       after row
          if a_ctb18m01[arr_aux].crnpgtetgdat is not null then
             case ws.operacao
                when "i"
                  insert into dbsmcrnpgtetg (crnpgtcod,
                                             crnpgtetgdat,
                                             atldat,
                                             atlemp,
                                             atlmat    )
                                     values (param.crnpgtcod,
                                             a_ctb18m01[arr_aux].crnpgtetgdat,
                                             today,
                                             g_issk.empcod,
                                             g_issk.funmat)

                  if sqlca.sqlcode <> 0 then
                     error " Erro (", sqlca.sqlcode, ") na inclusao desta autorizacao favor verificar!"
                  end if
             end case
          end if
          let ws.operacao = " "

       on key (interrupt)
          exit input

    end input

    if int_flag    then
       exit while
    end if

 end while

 close window ctb18m01

 let int_flag = false

end function  #  ctb18m01

