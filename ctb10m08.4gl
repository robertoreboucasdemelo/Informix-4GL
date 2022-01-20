 ############################################################################
 # Menu de Modulo: CTB10M08                                        Gilberto #
 #                                                                  Marcelo #
 # Manutencao no cadastro de grupos tarifarios (veiculos)          Dez/1996 #
 ############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_retorno   smallint

#--------------------------------------------------------------------
 function ctb10m08(param)
#--------------------------------------------------------------------

 define param           record
        operacao        char (01),
        socgtfcod       like dbskgtf.socgtfcod,
        socgtfdes       like dbskgtf.socgtfdes,
        caddat          like dbskgtf.caddat,
        cadfunnom       like isskfunc.funnom,
        atldat          like dbskgtf.atldat,
        funnom          like isskfunc.funnom,
        socgtfstt       like dbskgtf.socgtfstt
  end record

  define a_ctb10m08 array[3000] of record
         vclcoddig       like dbsrvclgtf.vclcoddig,
         vcldes          char(60)
  end record

  define ws              record
         comando         char(400),
         vclcoddig       like dbsrvclgtf.vclcoddig,
         ctgtrfdes       like agekcateg.ctgtrfdes,
         socgtfcod       like dbskgtf.socgtfcod,
         operacao        char(01),
         count           smallint,
         confirma        char(01)
  end record

  define arr_aux         smallint
  define scr_aux         smallint


  initialize a_ctb10m08  to null
  initialize ws.*        to null
  let arr_aux = 1

  let ws.comando = " select ctgtrfdes ",
                     " from agekcateg ",
                    " where tabnum = (select max(tabnum) ",
                                      " from agekcateg ",
                                     " where ramcod = 531 ",
                                       " and ctgtrfcod = ?) ",
                      " and ramcod = 531 ",
                      " and ctgtrfcod = ? "
  prepare comando_aux1  from  ws.comando
  declare c_aux1  cursor for  comando_aux1

  error " Aguarde, pesquisando..."  attribute (reverse)

  declare c_ctb10m08 cursor for
   select vclcoddig
     from dbsrvclgtf
    where socgtfcod = param.socgtfcod
  foreach c_ctb10m08 into a_ctb10m08[arr_aux].vclcoddig

     initialize a_ctb10m08[arr_aux].vcldes   to null

     open  c_aux1  using a_ctb10m08[arr_aux].vclcoddig,
                         a_ctb10m08[arr_aux].vclcoddig
     fetch c_aux1  into  ws.ctgtrfdes

     if sqlca.sqlcode <> 0   then
        error " Erro (",sqlca.sqlcode,") na leitura da categoria tarifaria!"
        sleep 5
        continue foreach
     end if
     close c_aux1

     let a_ctb10m08[arr_aux].vcldes = ws.ctgtrfdes clipped

     let arr_aux = arr_aux + 1

  end foreach

  error ""
  call set_count(arr_aux - 1)

  open window w_ctb10m08 at 06,2 with form "ctb10m08"
       attribute(form line first, comment line last - 1)

  message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

  display param.socgtfcod  to  socgtfcod
  display param.socgtfdes  to  socgtfdes
  display param.caddat     to  caddat
  display param.cadfunnom  to  cadfunnom
  display param.atldat     to  atldat
  display param.funnom     to  funnom
  display param.socgtfcod  to  socgtfcod
  display param.socgtfstt  to  socgtfstt

  while true
      let int_flag = false

      input array a_ctb10m08 without defaults from s_ctb10m08.*
         before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
                  let ws.vclcoddig = a_ctb10m08[arr_aux].vclcoddig
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctb10m08[arr_aux].*  to null
               display a_ctb10m08[arr_aux].* to s_ctb10m08[scr_aux].*

            before field vclcoddig
               display a_ctb10m08[arr_aux].vclcoddig to
                       s_ctb10m08[scr_aux].vclcoddig attribute (reverse)

            after field vclcoddig
               display a_ctb10m08[arr_aux].vclcoddig to
                       s_ctb10m08[scr_aux].vclcoddig

               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  let ws.operacao = " "
               end if

               if ws.operacao  =  "a"                             and
                  a_ctb10m08[arr_aux].vclcoddig <> ws.vclcoddig   then
                  error " Codigo da categoria tarifaria nao deve ser alterada!"
                  next field vclcoddig
               end if

               if a_ctb10m08[arr_aux].vclcoddig is null or
                  a_ctb10m08[arr_aux].vclcoddig = 0     then
                  let ws.comando =
                    " select ctgtrfcod ,ctgtrfdes ",
                      " from agekcateg ",
                     " where tabnum = (select max(tabnum) from agekcateg ",
                                      " where ramcod = 531)",
                       " and ramcod = 531 "
                  call ofgrc001_popup(3,
                                      3,
                                      "CATEGORIA TARIFARIA ",
                                      "CODIGO",
                                      "DESCRICAO",
                                      "N",
                                      ws.comando,
                                      "",
                                      "X")
                  returning m_retorno,
                            a_ctb10m08[arr_aux].vclcoddig,
                            a_ctb10m08[arr_aux].vcldes

                  if a_ctb10m08[arr_aux].vcldes is null or
                     a_ctb10m08[arr_aux].vcldes = " " then
                     error "Informe o Codigo Tarifario "
                     next field vclcoddig
                  end if
               else
                  open  c_aux1  using a_ctb10m08[arr_aux].vclcoddig,
                                      a_ctb10m08[arr_aux].vclcoddig
                  fetch c_aux1  into  ws.ctgtrfdes
                  if sqlca.sqlcode = notfound then
                     error " Codigo da categoria tarifaria nao cadastrada!"
                     next field vclcoddig
                  end if
                  close c_aux1
               end if

               initialize a_ctb10m08[arr_aux].vcldes to null

               open  c_aux1  using a_ctb10m08[arr_aux].vclcoddig,
                                   a_ctb10m08[arr_aux].vclcoddig
               fetch c_aux1  into  ws.ctgtrfdes
               if sqlca.sqlcode <> 0 then
                  error " Erro (",sqlca.sqlcode,") na leitura da categoria tarifaria!"
                  next field vclcoddig
               end if
               close c_aux1

               let a_ctb10m08[arr_aux].vcldes = ws.ctgtrfdes clipped

               display a_ctb10m08[arr_aux].vcldes to s_ctb10m08[scr_aux].vcldes
               #-----------------------------------------------
               # Verifica se este veiculo ja' foi cadastrado
               #-----------------------------------------------
               if ws.operacao = "i"  then
                  select dbskgtf.socgtfcod
                    into ws.socgtfcod
                   from dbsrvclgtf,dbskgtf
                  where dbsrvclgtf.socgtfcod = dbskgtf.socgtfcod
                    and dbsrvclgtf.vclcoddig = a_ctb10m08[arr_aux].vclcoddig
                    and socgtfstt <> "C"


                  if sqlca.sqlcode = 0   then
                     error " Categoria ja' cadastrado no grupo -> ", ws.socgtfcod
                     next field vclcoddig
                  end if
               end if

            on key (interrupt)
               exit input

            before delete
               let ws.confirma = "N"
              call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                   returning ws.confirma

               if ws.confirma = "N"   then
                  exit input
               end if

               let ws.count = 0
               select count(*)  into  ws.count
                 from dbsrvclgtf
                where socgtfcod = param.socgtfcod

               if ws.count =  1   then
                  error " Grupo tarifario deve ser removido!"
                  exit input
               end if

               let ws.operacao = "d"
               if a_ctb10m08[arr_aux].vclcoddig   is null   then
                  continue input
               else
                  begin work
                     delete from dbsrvclgtf
                            where socgtfcod = param.socgtfcod          and
                                  vclcoddig = a_ctb10m08[arr_aux].vclcoddig
                  commit work

                  initialize a_ctb10m08[arr_aux].* to null
                  display a_ctb10m08[arr_aux].* to s_ctb10m08[scr_aux].*
               end if

            after row
               begin work

               case ws.operacao
                  when "i"
                     if param.operacao = "i"   then  #--> qdo inclusao de grupo
                        initialize param.operacao   to null
                        call grupo_ctb10m08(param.*)  returning param.socgtfcod
                        if param.socgtfcod  is null   then
                           exit input
                        end if
                     end if

                     insert into dbsrvclgtf  (socgtfcod,
                                              vclcoddig,
                                              funmat,
                                              atldat)
                                    values
                                             (param.socgtfcod,
                                              a_ctb10m08[arr_aux].vclcoddig,
                                              g_issk.funmat,
                                              today)
               end case

               commit work
               let ws.operacao = " "
      end input

      if int_flag    then
         exit while
      end if

   end while

   let int_flag = false
   close window w_ctb10m08

end function  ###  ctb10m08

#---------------------------------------------------------------
function grupo_ctb10m08(param2)
#---------------------------------------------------------------
 define param2           record
         operacao        char(01),
         socgtfcod       like dbskgtf.socgtfcod,
         socgtfdes       like dbskgtf.socgtfdes,
         caddat          like dbskgtf.caddat,
         cadfunnom       like isskfunc.funnom,
         atldat          like dbskgtf.atldat,
         funnom          like isskfunc.funnom,
         socgtfstt       like dbskgtf.socgtfstt
 end record

 define ws2              record
         socgtfprx       like dbskgtf.socgtfcod,
         resp            char(01)
 end record


  initialize  ws2.*   to null

  select max(socgtfcod)
    into ws2.socgtfprx
    from dbskgtf
   where dbskgtf.socgtfcod > 0

  if ws2.socgtfprx  is null   then
    let ws2.socgtfprx = 0
  end if
  let ws2.socgtfprx = ws2.socgtfprx + 1

  insert into dbskgtf (socgtfcod,
                       socgtfdes,
                       caddat,
                       cadmat,
                       atldat,
                       funmat,
                       socgtfstt
                      )
              values
                      (ws2.socgtfprx,
                       param2.socgtfdes,
                       today,
                       g_issk.funmat,
                       today,
                       g_issk.funmat,
                       "A"
                      )

  if sqlca.sqlcode <> 0   then
     error " Erro (",sqlca.sqlcode,") na inclusao do grupo tarifario!"
     rollback work
     initialize ws2.socgtfprx   to null
  else
     display ws2.socgtfprx  to  socgtfcod  attribute (reverse)
     error "Verifique o codigo do grupo e tecle ENTER!"
     prompt "" for char ws2.resp
  end if

  return ws2.socgtfprx

end function  ###  grupo_ctb10m08
