###########################################################################
# Nome do Modulo: ctc91m11                               Helder Oliveira  #
#                                                                         #
# Garantia de Carro Reserva ITAU                                 Dez/2010 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep      smallint
  define m_operacao  char(1)
  define m_errflg    char(1)
  define m_confirma  char(1)
  define m_data      date
  define m_aux_codigo char(4)

  define a_ctc91m11 array[500] of record
            codigo    char(4)
           ,flag      char(1)
           ,descricao char(50)
        end record

  define r_ctc91m11 record
         atlemp     like datkitacia.atlemp
        ,atlmat     like datkitacia.atlmat
        ,atldat     like datkitacia.atldat
        ,funnom     like isskfunc.funnom
        end record

#============================
function ctc91m11_prepare()
#============================
 define l_sql char(500)

 let l_sql =  '  select rsrcaogrtcod          '
             ,'       , itarsrcaogrtcod       '
             ,'       , itarsrcaogrtdes       '
             ,'    from datkitarsrcaogar      '
             ,'   order by rsrcaogrtcod       '

 prepare pctc91m11001 from l_sql
 declare cctc91m11001 cursor for pctc91m11001


 let l_sql =   ' select rsrcaogrtcod        '
              ,'   from datkitarsrcaogar       '
              ,'  where rsrcaogrtcod   = ?  '
 prepare pctc91m11002 from l_sql
 declare cctc91m11002 cursor for pctc91m11002


 let l_sql =   '  insert into datkitarsrcaogar         ( rsrcaogrtcod        ,   '
                                                 ,'      itarsrcaogrtcod     ,   '
                                                 ,'      itarsrcaogrtdes     ,   '
                                                 ,'      atlusrtip           ,   '
                                                 ,'      atlemp              ,   '
                                                 ,'      atlmat              ,   '
                                                 ,'      atldat             )    '
                                                 ,'     values(?,?,?,?,?,?,?)      '
 prepare pctc91m11003 from l_sql


 let l_sql =   ' update datkitarsrcaogar       set  itarsrcaogrtdes   = ?      ,  '
                                          ,'   atlusrtip  = ?                  ,  '
                                          ,'   atlemp     = ?                  ,  '
                                          ,'   atlmat     = ?                  ,  '
                                          ,'   atldat     = ?                     '
                                          ,' where rsrcaogrtcod    = ?               '
 prepare pctc91m11004 from l_sql

 let l_sql =  ' select count(itarsrcaogrtdes  )    '
             ,' from datkitarsrcaogar              '
             ,' where itarsrcaogrtdes   = ?        '
 prepare pctc91m11005 from l_sql
 declare cctc91m11005 cursor for pctc91m11005


 let l_sql =  ' delete datkitarsrcaogar         '
             ,'  where rsrcaogrtcod   = ?    '
 prepare pctc91m11006 from l_sql

 let l_sql =  ' select count(rsrcaogrtcod  )    '
             ,' from datkitarsrcaogar              '
             ,' where rsrcaogrtcod   = ?        '
 prepare pctc91m11007 from l_sql
 declare cctc91m11007 cursor for pctc91m11007

 let l_sql =  ' select itarsrcaogrtdes         '
             ,'   from datkitarsrcaogar        '
             ,'  where rsrcaogrtcod   = ?   '

 prepare pctc91m11008 from l_sql
 declare cctc91m11008 cursor for pctc91m11008

 let l_sql =  '  select first 1 rsrcaogrtcod   '
             ,'    from datmitaaplitm    '
             ,'   where rsrcaogrtcod  =  ?     '

 prepare pctc91m11009 from l_sql
 declare cctc91m11009 cursor for pctc91m11009

 let l_sql = '   select atlemp                    '
            ,'         ,atlmat                    '
            ,'         ,atldat                    '
            ,'     from datkitarsrcaogar       '
            ,'    where rsrcaogrtcod  =  ?  '
 prepare pctc91m11010 from l_sql
 declare cctc91m11010 cursor for pctc91m11010

 let l_sql = '   select itarsrcaogrtcod      '
            ,'     from datkitarsrcaogar     '
            ,'    where itarsrcaogrtcod = ?  '
 prepare pctc91m11011 from l_sql
 declare cctc91m11011 cursor for pctc91m11011

 let l_sql = '  delete datrmtvrsrcaogrt     '
            ,'  where  rsrcaogrtcod = ?     '
 prepare pctc91m11012 from l_sql
 let m_prep = 1

end function

#==============================
function ctc91m11_input_array()
#==============================
  define l_index       smallint
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
  define l_tamanho     smallint
  define i             smallint
  define l_flag        smallint   #verifica se existe letras no campo codigo
  define l_flg         smallint   #verifica se foi up down
  define l_descricao   char(50)
  define l_prox_arr    smallint
  define l_err         smallint
  define l_ext_flag    like datkitarsrcaogar.itarsrcaogrtcod

  initialize a_ctc91m11 to null
  initialize r_ctc91m11.* to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today
  let l_ext_flag = ''

  if m_prep <> 1 then
    call ctc91m11_prepare()
  end if

  open window w_ctc91m00a at 6,2 with form 'ctc91m00a'
             attribute(form line first, message line last,comment line last - 1, border)

  display 'GARANTIA DE CARRO RESERVA ITAU' at 1,26

  while true
    let l_index = 1

    whenever error continue
      open cctc91m11001
    whenever error stop

    foreach cctc91m11001 into a_ctc91m11[l_index].codigo,
                              a_ctc91m11[l_index].flag,
                              a_ctc91m11[l_index].descricao

       let l_index = l_index + 1

       if l_index > 500 then
          error " Limite excedido! Foram encontrados mais de 500 Garantias de Carro Reserva!"
          exit foreach
       end if

    message "   (F1) - Inclui (F2) - Exclui  (F7) - Motivos  (F17) - Abandona  "
    end foreach

    let arr_aux = l_index
    if arr_aux = 1  then
       error "Nao foi encontrado nenhum registro, inclua novos!"
    end if

    let m_errflg = "N"
    let l_flag = true

    call set_count(arr_aux - 1)
    input array a_ctc91m11 without defaults from s_ctc91m00a.*

         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()

             if arr_aux <= arr_count()  then
                let m_operacao = "p"
             end if

             whenever error continue
             open cctc91m11008 using a_ctc91m11[arr_aux].codigo
             fetch cctc91m11008 into l_descricao
             whenever error stop

         #------------------
          before insert
         #------------------
              let m_operacao = 'i'
              initialize a_ctc91m11[arr_aux] to null
              display a_ctc91m11[arr_aux].codigo     to
                      s_ctc91m00a[scr_aux].codigo

        #--------------------
         before field codigo
        #--------------------
               if m_operacao <> 'i' then
                   call ctc91m11_dados_alteracao(a_ctc91m11[arr_aux].codigo)
               end if

               if a_ctc91m11[arr_aux].codigo is null then
                  let m_operacao = 'i'
               else
                  display a_ctc91m11[arr_aux].* to s_ctc91m00a[scr_aux].* attribute(reverse)
                  let m_aux_codigo = a_ctc91m11[arr_aux].codigo
               end if

        #--------------------
         after field codigo
        #--------------------
               display a_ctc91m11[arr_aux].* to s_ctc91m00a[scr_aux].*

              if fgl_lastkey() = fgl_keyval("up")    then

                 display a_ctc91m11[arr_aux].codigo to s_ctc91m00a[scr_aux].codigo

                 let l_flg = 1
                 let m_operacao = "p"
              end if

              if fgl_lastkey() = fgl_keyval("left")   then
                 let l_flg = 1
                 next field descricao
              end if

              if a_ctc91m11[arr_aux].codigo is null then
                  if  m_operacao = 'i' then
                     error " Informe o codigo da Garantia de Carro reserva"
                     next field codigo
                  end if
              else
                  if m_operacao = 'i'then
                     let l_tamanho = length(a_ctc91m11[arr_aux].codigo)
                     for i = 1 to l_tamanho
                        if a_ctc91m11[arr_aux].codigo[i] not matches'[0-9]' then
                          let l_flag = false
                        end if
                     end for

                     if l_flag = false then
                         error "O Codigo so pode conter numeros"
                         let a_ctc91m11[arr_aux].codigo = null
                         let l_flag = true
                         next field codigo
                     end if

                     whenever error continue
                        open cctc91m11007 using a_ctc91m11[arr_aux].codigo
                        fetch cctc91m11007 into l_count
                     whenever error stop

                     if l_count > 0 then
                        initialize a_ctc91m11[arr_aux] to null
                        error " Codigo da Garantia de Carro reserva ja cadastrado!"
                        close cctc91m11007
                        next field codigo
                     end if
                  end if

                  if a_ctc91m11[arr_aux].descricao is not null then
                     let a_ctc91m11[arr_aux].codigo = m_aux_codigo
                     display a_ctc91m11[arr_aux].codigo to s_ctc91m00a[scr_aux].codigo
                  else
                     if m_operacao <> 'i' then
                        let a_ctc91m11[arr_aux].codigo = ''
                        display a_ctc91m11[arr_aux].codigo to s_ctc91m00a[scr_aux].codigo
                     end if
                  end if

              end if

        #--------------------
         before field flag
        #--------------------
               if a_ctc91m11[arr_aux].flag is not null then
                  next field descricao
               else
                  let m_operacao = 'i'
               end if

        #--------------------
         after field flag
        #--------------------
               display a_ctc91m11[arr_aux].flag to s_ctc91m00a[scr_aux].flag

              if a_ctc91m11[arr_aux].flag is null then
                 let a_ctc91m11[arr_aux].flag = " "
              end if

              if fgl_lastkey() <> fgl_keyval("up")    and
                 fgl_lastkey() <> fgl_keyval("left")    then

                 whenever error continue
                   open cctc91m11011 using a_ctc91m11[arr_aux].flag
                   fetch cctc91m11011 into l_ext_flag
                 whenever error stop

                 if l_ext_flag is not null then
                    error 'Flag ja cadastrada em outro codigo'
                    let l_ext_flag = ''
                    let a_ctc91m11[arr_aux].flag = ''
                    next field flag
                 end if
              end if


              if fgl_lastkey() = fgl_keyval("up")    then
                 let l_flg = 1
                 let m_operacao = "p"
              else
                 if fgl_lastkey() = fgl_keyval("left")   then
                    let l_flg = 1
                    #next field descricao
                 end if
              end if

        #-------------------------
          before field descricao
        #-------------------------
                 display a_ctc91m11[arr_aux].descricao to
                         s_ctc91m00a[scr_aux].descricao attribute(reverse)

                 if a_ctc91m11[arr_aux].codigo is null then
                    let a_ctc91m11[arr_aux].descricao = null
                    display a_ctc91m11[arr_aux].descricao to
                            s_ctc91m00a[scr_aux].descricao
                    next field codigo
                 end if


        #-------------------------
          after field descricao
        #-------------------------
              display a_ctc91m11[arr_aux].descricao to
                      s_ctc91m00a[scr_aux].descricao

            # Retirar espaços em branco a esqeurada e a direita
              let a_ctc91m11[arr_aux].descricao = ctc91m00_trim(a_ctc91m11[arr_aux].descricao)
              display a_ctc91m11[arr_aux].descricao to
                      s_ctc91m00a[scr_aux].descricao
            # -

              let l_count = 0

              if fgl_lastkey() = fgl_keyval("up")    then
                 let l_flg = 1
                 if a_ctc91m11[arr_aux].descricao is null then
                    error " Informe a descricao da Garantia do Carro eserva"
                 end if
              end if

              if fgl_lastkey() = fgl_keyval("left")   then
                 let l_flg = 1
                 next field codigo
              end if

              if a_ctc91m11[arr_aux].descricao is null then
                if m_operacao <> " " then
                   error " Informe a descricao da Garantia do Carro eserva"
                   next field descricao
                end if
              else
                 if m_operacao = 'i' then
                    whenever error continue
                    open cctc91m11005 using a_ctc91m11[arr_aux].descricao
                    fetch cctc91m11005 into l_count
                    whenever error stop

                    if l_count > 0 then
                      error "Esta Garantia de Carro Reserva ja foi cadastrada com outro codigo"
                      next field descricao
                   end if
                 end if
              end if
              message "   (F1) - Inclui (F2) - Exclui  (F7) - Motivos  (F17) - Abandona  "

        #--------------------
          after row
        #--------------------

               whenever error continue

               case
                   when m_operacao = 'i'
                      call ctc91m11_insert_dados(arr_aux)

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc91m11_update_pergunta_altera(arr_aux, scr_aux) returning l_err
                      if l_err = 1 then
                         next field descricao
                      end if
               end case

               if m_errflg = "S"  then
                  let int_flag = true
                  exit input
               end if

               whenever error stop

               let m_operacao = " "

        #--------------------
          before delete
        #--------------------
               let m_operacao = "d"

               initialize m_confirma to null

               if ctc91m11_verifica_existencia(a_ctc91m11[arr_aux].codigo) then

               call cts08g01("A"
                            ,"S"
                            ,"CONFIRMA A REMOCAO"
                            ,"DA GARANTIA DO "
                            ,"CARRO RESERVA ? "
                            ," " )
                   returning m_confirma

               if m_confirma = "S"  then
                  let m_errflg = "N"

                  begin work

                  whenever error continue
                  execute pctc91m11012 using a_ctc91m11[arr_aux].codigo
                  if sqlca.sqlcode <> 0  then
                         error " Erro (", sqlca.sqlcode, ") na Remocao do Motivo da Garantia!"
                         let m_errflg = "S"
                         whenever error stop
                  end if
                  whenever error continue
                  execute pctc91m11006 using a_ctc91m11[arr_aux].codigo

                  if sqlca.sqlcode <> 0  then
                         error " Erro (", sqlca.sqlcode, ") na remocao da Garantia do Carro Reserva!"

                         let m_errflg = "S"
                         whenever error stop
                  end if

                  whenever error stop
                  if m_errflg = "S"  then
                     rollback work
                  else
                     commit work
                  end if
               else
                  clear form
                  error " Remocao Cancelada! "
                  exit input
               end if
               else

                 clear form
                 error " Este Registro nao pode ser excluido! "
                 exit input
               end if

               let m_operacao = " "
               initialize a_ctc91m11[arr_aux].*   to null
               display a_ctc91m11[arr_aux].* to s_ctc91m00a[scr_aux].*

          #---------------------------------------------
           on key (F7)
          #---------------------------------------------
              if a_ctc91m11[arr_aux].codigo is not null then
                  call ctc91m25(a_ctc91m11[arr_aux].codigo,
                                a_ctc91m11[arr_aux].descricao)
              end if
          #--------------------
            on key (accept)
          #--------------------
               continue input

          #--------------------
            on key (interrupt, control-c)
          #--------------------
              let int_flag = true
              exit input

       end input

       if int_flag  then
          let int_flag = false
          exit while
       end if

  end while

  let int_flag = false

 close window w_ctc91m00a

end function

#================================================
function ctc91m11_update_pergunta_altera(arr_aux, scr_aux)
#================================================

  define arr_aux       smallint
  define scr_aux       smallint
  define l_descricao   char(50)
  define l_count       smallint
  define l_err         smallint

     whenever error continue
     open cctc91m11008 using a_ctc91m11[arr_aux].codigo
     fetch cctc91m11008 into l_descricao
     whenever error stop

     if l_descricao <> a_ctc91m11[arr_aux].descricao  then

       open cctc91m11005 using a_ctc91m11[arr_aux].descricao
       fetch cctc91m11005 into l_count

       if l_count > 0 then
          error "Esta Garantia de Carro Reserva ja foi cadastrada com outro codigo"
          let l_err = 1
          return l_err
       else
          let l_err = 0
          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DA GARANTIA DO "
                       ,"CARRO RESERVA ?"
                       ," ")
            returning m_confirma

           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc91m11[arr_aux].descricao = l_descricao clipped
              display a_ctc91m11[arr_aux].descricao to s_ctc91m00a[scr_aux].descricao
           end if
        end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute pctc91m11004 using  a_ctc91m11[arr_aux].descricao
                                     , g_issk.usrtip
                                     , g_issk.empcod
                                     , g_issk.funmat
                                     , m_data
                                     , a_ctc91m11[arr_aux].codigo

         if sqlca.sqlcode <> 0  then
            rollback work
            error " Erro (", sqlca.sqlcode, ") na insercao de dados"
            let m_errflg = "S"
         else
            error "Garantia De Carro Reserva Alterada Com Sucesso!"
            commit work
         end if
    end if

return l_err

end function

#=======================================
function ctc91m11_insert_dados(arr_aux)
#=======================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint

begin work
  whenever error continue
  open cctc91m11007 using a_ctc91m11[arr_aux].codigo
  fetch cctc91m11007 into l_count
  whenever error stop

  if l_count = 0 then
     execute pctc91m11003 using  a_ctc91m11[arr_aux].codigo
                                ,a_ctc91m11[arr_aux].flag
                                ,a_ctc91m11[arr_aux].descricao
                                ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,m_data

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "Garantia de Carro Reserva Incluida com Sucesso!"
        commit work
    end if
  end if

end function

#==============================================
function ctc91m11_verifica_existencia(l_cod)
#==============================================
define l_cod          char(4)
define l_cont         smallint

let l_cont = 0

   whenever error continue
   open cctc91m11009 using l_cod
   fetch cctc91m11009 into l_cont
   whenever error stop


   if l_cont = 0 then
      return true
   else
      return false
   end if

 end function

#============================================
function ctc91m11_dados_alteracao(l_cod)
#============================================
define l_cod char(4)

   initialize r_ctc91m11.* to null

   if m_prep <> 1 then
      call ctc91m11_prepare()
   end if
   whenever error continue
   open cctc91m11010 using l_cod
   fetch cctc91m11010 into  r_ctc91m11.atlemp
                           ,r_ctc91m11.atlmat
                           ,r_ctc91m11.atldat

        whenever error stop

   call ctc91m00_func(r_ctc91m11.atlemp, r_ctc91m11.atlmat)
        returning r_ctc91m11.funnom

   display by name  r_ctc91m11.atldat
                   ,r_ctc91m11.funnom

end function