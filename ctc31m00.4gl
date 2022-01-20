############################################################################
# Nome do Modulo: CTC31M00                                        Marcelo  #
#                                                                 Gilberto #
# Manutencao no Cadastro de Itens de Pagamento (Locacao)          Set/1996 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc31m00()
#----------------------------------------------------------------

   define a_ctc31m00 array[20] of record
      c24pgtitmcod   like dblkpagitem.c24pgtitmcod,
      c24pgtitmtip   like dblkpagitem.c24pgtitmtip,
      c24pgttipdes   char (10),
      c24pgtitmdes   like dblkpagitem.c24pgtitmdes
   end record

   define ws         record
      sql            char (200),
      operacao       char (001)
   end record

   define arr_aux    smallint
   define scr_aux    smallint

   if not get_niv_mod(g_issk.prgsgl, "ctc31m00") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   options delete key F35

   let ws.sql = "select cpodes from iddkdominio",
                " where cponom = 'c24pgtitmtip'",
                "   and cpocod = ? "
   prepare sel_iddkdominio from ws.sql
   declare c_iddkdominio cursor with hold for sel_iddkdominio

   open window ctc31m00 at 06,02 with form "ctc31m00"
        attribute (form line first, comment line last - 2)

   message " (F17)Abandona, (F1)Inclui"

   declare c_ctc31m00 cursor for
      select c24pgtitmcod,
             c24pgtitmtip,
             c24pgtitmdes
        from dblkpagitem
       order by c24pgtitmcod

   let int_flag = false
   initialize a_ctc31m00  to null

   while not int_flag
      let arr_aux = 1

      foreach c_ctc31m00 into a_ctc31m00[arr_aux].c24pgtitmcod,
                              a_ctc31m00[arr_aux].c24pgtitmtip,
                              a_ctc31m00[arr_aux].c24pgtitmdes
         let a_ctc31m00[arr_aux].c24pgttipdes = "N/PREVISTO"

         open  c_iddkdominio using a_ctc31m00[arr_aux].c24pgtitmtip
         fetch c_iddkdominio into  a_ctc31m00[arr_aux].c24pgttipdes
         close c_iddkdominio

         let arr_aux = arr_aux + 1

         if arr_aux > 20 then
            error " Limite de consulta excedido. AVISE A INFORMATICA!"
            exit program
         end if
      end foreach

      call set_count(arr_aux-1)

      input array a_ctc31m00 without defaults from s_ctc31m00.*

      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         if arr_aux <= arr_count() then
            let ws.operacao = "a"
         end if

      before insert
         let ws.operacao = "i"
         initialize a_ctc31m00[arr_aux].c24pgtitmcod,
                    a_ctc31m00[arr_aux].c24pgtitmtip,
                    a_ctc31m00[arr_aux].c24pgtitmdes to null

      before field c24pgtitmtip
         display a_ctc31m00[arr_aux].c24pgtitmtip to
                 s_ctc31m00[scr_aux].c24pgtitmtip attribute (reverse)

      after field c24pgtitmtip
         display a_ctc31m00[arr_aux].c24pgtitmtip to
                 s_ctc31m00[scr_aux].c24pgtitmtip

         if fgl_lastkey() = fgl_keyval("down")   then
            if a_ctc31m00[arr_aux + 1].c24pgtitmtip  is null   then
               error " Nao existem linhas nesta direcao!"
               next field c24pgtitmtip
            end if
         end if

         if a_ctc31m00[arr_aux].c24pgtitmtip is null  then
            error " Tipo do item deve ser informado!"
            next field c24pgtitmtip
         else
            open  c_iddkdominio using a_ctc31m00[arr_aux].c24pgtitmtip
            fetch c_iddkdominio into  a_ctc31m00[arr_aux].c24pgttipdes
            if sqlca.sqlcode = notfound  then
               error " Tipo do item deve ser (1)Excedente ou (2)Desconto!"
               next field c24pgtitmtip
            end if
            close c_iddkdominio
         end if

         display a_ctc31m00[arr_aux].c24pgttipdes to
                 s_ctc31m00[scr_aux].c24pgttipdes

      before field c24pgtitmdes
         display a_ctc31m00[arr_aux].c24pgtitmdes to
                 s_ctc31m00[scr_aux].c24pgtitmdes attribute (reverse)

      after field c24pgtitmdes
         display a_ctc31m00[arr_aux].c24pgtitmdes to
                 s_ctc31m00[scr_aux].c24pgtitmdes

         if fgl_lastkey() = fgl_keyval("down")   then
            if a_ctc31m00[arr_aux + 1].c24pgtitmdes  is null   then
               error " Nao existem linhas nesta direcao!"
               next field c24pgtitmdes
            end if
         end if

         if a_ctc31m00[arr_aux].c24pgtitmdes is null  then
            error " Descricao do item deve ser informado!"
            next field c24pgtitmdes
         end if

      on key (interrupt)
         exit input

      after row
         case ws.operacao
         when "i"
            BEGIN WORK

            select max(c24pgtitmcod)
              into a_ctc31m00[arr_aux].c24pgtitmcod
              from dblkpagitem

            if a_ctc31m00[arr_aux].c24pgtitmcod is null then
               let a_ctc31m00[arr_aux].c24pgtitmcod = 0
            end if

            let a_ctc31m00[arr_aux].c24pgtitmcod =
                a_ctc31m00[arr_aux].c24pgtitmcod + 1

            insert into dblkpagitem ( c24pgtitmcod, c24pgtitmtip, c24pgtitmdes )
                             values ( a_ctc31m00[arr_aux].c24pgtitmcod ,
                                      a_ctc31m00[arr_aux].c24pgtitmtip ,
                                      a_ctc31m00[arr_aux].c24pgtitmdes )
            COMMIT WORK

            display a_ctc31m00[arr_aux].* to s_ctc31m00[scr_aux].*

	 when "a"
               update dblkpagitem set (c24pgtitmtip, c24pgtitmdes) =
                                      (a_ctc31m00[arr_aux].c24pgtitmtip,
                                       a_ctc31m00[arr_aux].c24pgtitmdes)
                where c24pgtitmcod = a_ctc31m00[arr_aux].c24pgtitmcod
         end case

         let ws.operacao = " "
      end input

      if int_flag  then
         exit while
      end if

   end while

   close window ctc31m00
   let int_flag = false

end function  ###  ctc31m00
