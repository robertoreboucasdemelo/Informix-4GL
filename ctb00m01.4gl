 ############################################################################
 # Menu de Modulo: CTB00M01                                        Marcelo  #
 #                                                                 Gilberto #
 # Pagamento de locacoes de veiculos (digitacao dos itens)         Set/1996 #
 ############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------
 function ctb00m01(param)
#-------------------------------------------------------------------

  define param        record
     operacao         char (01)                  ,
     atdsrvnum        like dblmpagto.atdsrvnum   ,
     atdsrvano        like dblmpagto.atdsrvano   ,
     nfsnum           like dblmpagto.nfsnum      ,
     nfsvctdat        like dblmpagto.nfsvctdat   ,
     nfspgtdat        like dblmpagto.nfspgtdat   ,
     c24utidiaqtd     like dblmpagto.c24utidiaqtd,
     c24pagdiaqtd     like dblmpagto.c24pagdiaqtd,
     c24diaparvlr     like dblmpagto.c24diaparvlr,
     c24diatotvlr     like dblmpagto.c24diaparvlr,
     cademp           like dblmpagto.cademp      ,
     cadmat           like dblmpagto.cadmat      ,
     caddat           like dblmpagto.caddat      ,
     cadhor           like dblmpagto.cadhor      ,
     vclalgdat        like datmavisrent.vclalgdat
  end record

  define a_ctb00m01   array[10] of record
     c24pgtitmcod     like dblkpagitem.c24pgtitmcod,
     c24pgtitmtip     like dblkpagitem.c24pgtitmtip,
     c24pgtitmdes     like dblkpagitem.c24pgtitmdes,
     c24pgtitmvlr     like dblmpagitem.c24pgtitmvlr
  end record

  define ws           record
     operacao         char (01)                   ,
     sqlcode          integer                     ,
     retorno          smallint                    ,
     confirma         char (01)                   ,
     linha1           char (40)                   ,
     linha2           char (40)                   ,
     atldat           date                        ,
     viginc           like abbmdoc.viginc         ,
     succod           like datrservapol.succod    ,
     aplnumdig        like datrservapol.aplnumdig ,
     itmnumdig        like datrservapol.itmnumdig ,
     c24diadifvlr     like dblmpagto.c24diaparvlr ,
     c24itmtotvlr     like dblmpagto.c24diaparvlr
  end record

  define arr_aux      smallint
  define scr_aux      smallint

  declare c_ctb00m01  cursor for
    select dblmpagitem.c24pgtitmcod,
           dblkpagitem.c24pgtitmtip,
           dblkpagitem.c24pgtitmdes,
           dblmpagitem.c24pgtitmvlr
      from dblmpagitem, dblkpagitem
     where dblmpagitem.atdsrvnum    = param.atdsrvnum   and
           dblmpagitem.atdsrvano    = param.atdsrvano   and
           dblkpagitem.c24pgtitmcod = dblmpagitem.c24pgtitmcod

  initialize a_ctb00m01  to null
  initialize ws.*        to null
  let arr_aux   = 1
  let ws.atldat = today

  foreach c_ctb00m01 into a_ctb00m01[arr_aux].c24pgtitmcod,
                          a_ctb00m01[arr_aux].c24pgtitmtip,
                          a_ctb00m01[arr_aux].c24pgtitmdes,
                          a_ctb00m01[arr_aux].c24pgtitmvlr

     let arr_aux = arr_aux + 1
     if arr_aux > 10 then
        error " Limite excedido, locacao com mais de 10 itens!"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)

  open window ctb00m01 at 11,02 with form "ctb00m01"
       attribute(form line first)

  if param.operacao is not null  then
     message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

     let ws.c24diadifvlr = param.c24diatotvlr - param.c24diaparvlr

     if ws.c24diadifvlr > 0  then
        display "Excedente:"  to  resexctxt
     else
        display "Residuo..:"  to  resexctxt
     end if

     display by name ws.c24diadifvlr attribute (reverse)

      BEGIN WORK
      while TRUE
         let int_flag = false

         input array a_ctb00m01 without defaults from s_ctb00m01.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctb00m01[arr_aux].* to null
               display    a_ctb00m01[arr_aux].* to s_ctb00m01[scr_aux].*

            before field c24pgtitmcod
               if ws.operacao = "a"  then
                  if a_ctb00m01[arr_aux].c24pgtitmcod is null then
                     let ws.operacao = "i"
                     display a_ctb00m01[arr_aux].c24pgtitmcod to
                             s_ctb00m01[scr_aux].c24pgtitmcod attribute (reverse)
                  else
                     display a_ctb00m01[arr_aux].c24pgtitmcod to
                             s_ctb00m01[scr_aux].c24pgtitmcod
                     next field c24pgtitmvlr
                  end if
               else
                  display a_ctb00m01[arr_aux].c24pgtitmcod to
                          s_ctb00m01[scr_aux].c24pgtitmcod attribute (reverse)
               end if

            after  field c24pgtitmcod
               display a_ctb00m01[arr_aux].c24pgtitmcod to
                       s_ctb00m01[scr_aux].c24pgtitmcod

               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  let ws.operacao = " "
               else
                  if a_ctb00m01[arr_aux].c24pgtitmcod is null  then
                     error " Codigo do item e' de preenchimento obrigatorio!"
                     call ctb00m02() returning a_ctb00m01[arr_aux].c24pgtitmcod
                     next field c24pgtitmcod
                  end if

                  #-----------------------------------------------
                  # Verifica se este item ja' foi cadastrado
                  #-----------------------------------------------

                  if ws.operacao = "i"  then
                     select * from dblmpagitem
                      where atdsrvnum    = param.atdsrvnum   and
                            atdsrvano    = param.atdsrvano   and
                            c24pgtitmcod = a_ctb00m01[arr_aux].c24pgtitmcod

                     if sqlca.sqlcode <> NOTFOUND then
                        error " Item ja' cadastrado!"
                        next field c24pgtitmcod
                     end if
                  end if

                  select c24pgtitmtip, c24pgtitmdes
                    into a_ctb00m01[arr_aux].c24pgtitmtip,
                         a_ctb00m01[arr_aux].c24pgtitmdes
                    from dblkpagitem
                   where c24pgtitmcod = a_ctb00m01[arr_aux].c24pgtitmcod

                  if sqlca.sqlcode = NOTFOUND  then
                     error " Item nao cadastrado!"
                     next field c24pgtitmcod
                  end if

                  display a_ctb00m01[arr_aux].c24pgtitmdes to
                          s_ctb00m01[scr_aux].c24pgtitmdes
               end if

            before field c24pgtitmvlr
               display a_ctb00m01[arr_aux].c24pgtitmvlr to
                       s_ctb00m01[scr_aux].c24pgtitmvlr attribute (reverse)

            after  field c24pgtitmvlr
               display a_ctb00m01[arr_aux].c24pgtitmvlr to
                       s_ctb00m01[scr_aux].c24pgtitmvlr

               if fgl_lastkey() = fgl_keyval("down")   then
                  if a_ctb00m01[arr_aux + 1].c24pgtitmcod  is null   then
                     error " Nao existem linhas nesta direcao!"
                     next field c24pgtitmcod
                  end if
               end if

               if a_ctb00m01[arr_aux].c24pgtitmvlr is null  or
                  a_ctb00m01[arr_aux].c24pgtitmvlr = 0      then
                  error " Valor do item deve ser informado!"
                  next field c24pgtitmvlr
               end if

               if a_ctb00m01[arr_aux].c24pgtitmtip = 2  and
                  ws.operacao = "i"                     then
                  let a_ctb00m01[arr_aux].c24pgtitmvlr =
                      a_ctb00m01[arr_aux].c24pgtitmvlr * -1
               end if

            on key (interrupt)

               call ctb00m00_grava(param.operacao,
                                   param.atdsrvnum   ,
                                   param.atdsrvano   ,
                                   param.nfsnum      ,
                                   param.nfsvctdat   ,
                                   param.nfspgtdat   ,
                                   param.c24utidiaqtd,
                                   param.c24pagdiaqtd,
                                   param.c24diaparvlr,
                                   param.cademp      ,
                                   param.cadmat      ,
                                   param.caddat      ,
                                   param.cadhor      ,
                                   param.vclalgdat   )
                         returning ws.sqlcode

               if ws.sqlcode <> 0  then
                  rollback work
                  let ws.c24itmtotvlr = 0
                  let int_flag = true
                  exit input
               else
                  initialize param.operacao to null
               end if

               let ws.c24itmtotvlr = 0

               select sum(c24pgtitmvlr)
                 into ws.c24itmtotvlr
                 from dblmpagitem
                where atdsrvnum = param.atdsrvnum  and
                      atdsrvano = param.atdsrvano

               if ws.c24itmtotvlr is null then
                  let ws.c24itmtotvlr = 0
               end if

               if ws.c24itmtotvlr <> ws.c24diadifvlr  then
                  let ws.linha1 = "O VALOR INFORMADO NAO CONFERE COM "
                  let ws.linha2 = "O TOTAL (", ws.c24itmtotvlr using "<<<<<<<<<<&.&&", ") DOS ITENS DIGITADOS!"

                  call ctb00m03(ws.linha1, ws.linha2) returning ws.retorno

                  if ws.retorno = TRUE  then
                     let int_flag = false
                     continue input
                  else
                     let int_flag = true
                     exit input
                  end if
               else
                  exit input
               end if

            before delete
               let ws.operacao = "d"

               if a_ctb00m01[arr_aux].c24pgtitmcod is null then
                  continue input
               else
                  call cts08g01("A","S","","CONFIRMA A EXCLUSAO",
                                "DO REGISTRO ?","")
                       returning ws.confirma

                  if ws.confirma = "N"   then
                     exit input
                  else
                     delete from dblmpagitem
                      where atdsrvnum    = param.atdsrvnum  and
                            atdsrvano    = param.atdsrvano  and
                            c24pgtitmcod = a_ctb00m01[arr_aux].c24pgtitmcod

                     initialize a_ctb00m01[arr_aux].* to null
                     display a_ctb00m01[arr_aux].* to s_ctb00m01[scr_aux].*
                     next field c24pgtitmcod
                  end if
               end if

            after  row
               call ctb00m00_grava(param.operacao     ,
                                   param.atdsrvnum   ,
                                   param.atdsrvano   ,
                                   param.nfsnum      ,
                                   param.nfsvctdat   ,
                                   param.nfspgtdat   ,
                                   param.c24utidiaqtd,
                                   param.c24pagdiaqtd,
                                   param.c24diaparvlr,
                                   param.cademp      ,
                                   param.cadmat      ,
                                   param.caddat      ,
                                   param.cadhor      ,
                                   param.vclalgdat   )
                         returning ws.sqlcode

               if ws.sqlcode <> 0 then
                  rollback work
                  let ws.c24itmtotvlr = 0
                  let int_flag = true
                  exit input
               else
                  initialize param.operacao to null
               end if

               case ws.operacao
                  when "i"
                     insert into dblmpagitem (atdsrvnum   , atdsrvano   ,
                                              c24pgtitmcod, c24pgtitmvlr)
                                      values (param.atdsrvnum,
                                              param.atdsrvano,
                                              a_ctb00m01[arr_aux].c24pgtitmcod,
                                              a_ctb00m01[arr_aux].c24pgtitmvlr)

                     if sqlca.sqlcode <> 0 then
                        error " Erro (",sqlca.sqlcode,") na gravacao do pagamento. AVISE A INFORMATICA!"
                        rollback work
                        let ws.c24itmtotvlr = 0
                        let int_flag = true
                        exit input
                     end if

                  when "a"
                     update dblmpagitem set
                            c24pgtitmvlr = a_ctb00m01[arr_aux].c24pgtitmvlr
                      where atdsrvnum    = param.atdsrvnum  and
                            atdsrvano    = param.atdsrvano  and
                            c24pgtitmcod = a_ctb00m01[arr_aux].c24pgtitmcod

                     if sqlca.sqlcode <> 0 then
                        error " Erro (",sqlca.sqlcode,") na gravacao do pagamento. AVISE A INFORMATICA!"
                        rollback work
                        let ws.c24itmtotvlr = 0
                        let int_flag = true
                        exit input
                     end if
               end case

               let ws.operacao = " "

         end input

         if int_flag    then
            exit while
         end if

      end while

      COMMIT WORK
      let int_flag = false
   else
      select sum(c24pgtitmvlr)
        into ws.c24diadifvlr
        from dblmpagitem
       where atdsrvnum = param.atdsrvnum  and
             atdsrvano = param.atdsrvano

      if ws.c24diadifvlr is null then
         let ws.c24diadifvlr = 0
      end if

      display by name ws.c24diadifvlr attribute (reverse)

      message " (F17)Abandona"
      if arr_aux  >  1  then
         call set_count(arr_aux)
         display array a_ctb00m01 to s_ctb00m01.*
            on key (interrupt,control-c)
               exit display
         end display
      else
         error " Nao ha' nenhum excedente de valor para este pagamento!"
      end if
   end if

   close window ctb00m01

end function  ###  ctb00m01
