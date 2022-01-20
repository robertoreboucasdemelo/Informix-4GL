#############################################################################
# Nome do Modulo: CTB11M03                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao das observacoes da ordem de pagamento                 Dez/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/04/1999  Robson       Gilberto     Aumentar a quantidade de linhas de  #
#                                       observacoes de 3 para 10.           #
#									    #
#############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctb11m03(param)
#---------------------------------------------------------------

   define param        record
      socopgnum        like dbsmopgobs.socopgnum
   end record

   define a_ctb11m03 array[100] of record
      socopgobs        like dbsmopgobs.socopgobs,
      socopgobsseq     like dbsmopgobs.socopgobsseq
   end record

   define ws           record
      socopgobsseq     like dbsmopgobs.socopgobsseq ,
      socopgobs        like dbsmopgobs.socopgobs,
      socopgobsaux     like dbsmopgobs.socopgobs,
      operacao         char(01),
      confirma         char(01),
      situacao	       smallint
   end record

   define arr_aux      smallint
   define arr_alt      smallint
   define scr_aux      smallint
   define j            smallint

   #Nova implementação
   define l_sql        char(100)

   open window  w_ctb11m03  at 08,02  with form  "ctb11m03"
        attribute(form line first, comment line last - 2)

   message " (F17)Abandona, (F9)Exclui"
   let arr_aux = 1

   declare  c_ctb11m03  cursor for
     select socopgobs, socopgobsseq
       from dbsmopgobs
      where dbsmopgobs.socopgnum = param.socopgnum

   foreach  c_ctb11m03  into  a_ctb11m03[arr_aux].socopgobs,
                              a_ctb11m03[arr_aux].socopgobsseq

        let arr_aux = arr_aux + 1
        if arr_aux > 100   then
           exit foreach
        end if
   end foreach

   #Nova implementação
   let l_sql = " select socopgsitcod from dbsmopg where socopgnum = ? "
   prepare pctb11m03002 from l_sql
   declare cctb11m03002 cursor for pctb11m03002

   open cctb11m03002 using param.socopgnum
   fetch cctb11m03002 into ws.situacao
   close cctb11m03002

   while true
      let int_flag = false
      call set_count(arr_aux - 1)

      options insert key F35

      input array a_ctb11m03 without defaults from s_ctb11m03.*
         before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               
               if arr_aux <= arr_count()   then
                  #CT: 574732
                  initialize ws.socopgobsaux to null
                  let ws.socopgobsaux =  a_ctb11m03[arr_aux].socopgobs

                  let ws.operacao = "a"
               end if
    
            before insert
               initialize a_ctb11m03[arr_aux].socopgobs  to null
               let ws.operacao = "i"

               display a_ctb11m03[arr_aux].socopgobs  to
                       s_ctb11m03[scr_aux].socopgobs

            before field socopgobs
               display a_ctb11m03[arr_aux].socopgobs to
                       s_ctb11m03[scr_aux].socopgobs attribute (reverse)

            after field socopgobs
               display a_ctb11m03[arr_aux].socopgobs to
                       s_ctb11m03[scr_aux].socopgobs

               if a_ctb11m03[arr_aux].socopgobs is null  or
                  a_ctb11m03[arr_aux].socopgobs =  "  "  then
                  error " Linha de observacao deve ser preenchida!"
                  next field socopgobs
               end if

            on key (interrupt)
               exit input

            #CT: 574732
            on key(F9)
               if ws.situacao <> 7 then
                   error "Teste situação "

                   let ws.operacao = "d"
                   if a_ctb11m03[arr_aux].socopgobsseq  is null   then
                      continue input
                   end if

                   call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                        returning ws.confirma

                   if ws.confirma = "N"   then
                      exit input
                   end if

                   begin work
                      delete from dbsmopgobs
                       where socopgnum    = param.socopgnum                  and
                             socopgobsseq = a_ctb11m03[arr_aux].socopgobsseq
                   commit work

                   initialize a_ctb11m03[arr_aux].* to null
                   display    a_ctb11m03[arr_aux].* to s_ctb11m03[scr_aux].*
               else
                   #CT: 574732
                   error "Não é possível excluir observação de OP emitida"
                   next field socopgobs
               end if

            after row
                display arr_aux
                if (arr_aux = 99) and (
                    fgl_lastkey() <> fgl_keyval("up") or 
                    fgl_lastkey() <> fgl_keyval("left")) then
                         error "Não existe mais linha disponivel."
                         next field socopgobs
                end if

               if ws.operacao = "i"   then
                  select max (socopgobsseq)
                    into ws.socopgobsseq
                    from dbsmopgobs
                   where dbsmopgobs.socopgnum = param.socopgnum

                  if ws.socopgobsseq is null   then
                     let ws.socopgobsseq = 0
                  end if
                  let ws.socopgobsseq = ws.socopgobsseq + 1
		  
                  begin work
                    
                         insert into dbsmopgobs (socopgnum ,
                                                 socopgobsseq ,
                                                 socopgobs
                                                )
                                values          (param.socopgnum,
                                                 ws.socopgobsseq,
                                                 a_ctb11m03[arr_aux].socopgobs
                                                )
                    
                     if sqlca.sqlcode <>  0    then
                       error "Erro (",sqlca.sqlcode,") na inclusao da observacao,"
                        rollback work
                        next field socopgobs
                     end if
                  commit work
               end if

               if ws.operacao = "a"   then
                  #CT: 574732
                  if ws.situacao <> 7 then
                      begin work
                        update dbsmopgobs set (socopgobs)
                                           =  (a_ctb11m03[arr_aux].socopgobs)
                        where socopgnum    = param.socopgnum                   and
                              socopgobsseq = a_ctb11m03[arr_aux].socopgobsseq

                         if sqlca.sqlcode <>  0    then
                           error "Erro (",sqlca.sqlcode,") na alteracao da observacao,"
                            rollback work
                            next field socopgobs
                         end if
                      commit work
                  else
                      #CT: 574732
                      #let arr_alt = arr_curr()
                      let scr_aux = scr_line()
                      error "Não é possível alterar observação para OP emitida "
                      display ws.socopgobsaux to
                              s_ctb11m03[scr_aux].socopgobs
                              #s_ctb11m03[arr_alt].socopgobs
                  end if
               end if

               #CT 562386
               {on key (interrupt)
                   begin work
                       delete from dbsmopgobs
                       where dbsmopgobs.socopgnum = param.socopgnum

                   let i = arr_count()

                   commit work

                   for j = 1 to i

                      select max (socopgobsseq)
                        into ws.socopgobsseq
                        from dbsmopgobs
                       where dbsmopgobs.socopgnum = param.socopgnum

                      if ws.socopgobsseq is null   then
                         let ws.socopgobsseq = 0
                      end if
                      let ws.socopgobsseq = ws.socopgobsseq + 1

                      if a_ctb11m03[j].socopgobs is not null or
                         a_ctb11m03[j].socopgobs =  "  "  then

                      begin work
                         insert into dbsmopgobs (socopgnum ,
                                                 socopgobsseq ,
                                                 socopgobs
                                                 )
                                values          (param.socopgnum,
                                                 ws.socopgobsseq,
                                                 a_ctb11m03[j].socopgobs
                                                 )

                         if sqlca.sqlcode <>  0    then
                            error "Erro (",sqlca.sqlcode,") na inclusao da observacao,"
                            rollback work
                            next field socopgobs
                         end if

                      commit work

                      end if

                   end for

               exit input}

       end input

       if int_flag  then
          exit while
       end if

   end while

   options insert key F1
   close window w_ctb11m03
   let int_flag = false

end function  ###  ctb11m03
