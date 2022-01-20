#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc96m08                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15987                                              #
# Objetivo......: Tela de cadastro de Tipo de moradia                         #
#.............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao......: 29/06/2012                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep      smallint
  define m_operacao  char(1)
  define m_errflg    char(1)
  define m_confirma  char(1)
  define m_data      date
  define m_aux_codigo char(4)

  define a_ctc96m08 array[500] of record
            codigo    char(4)
           ,descricao char(50)
        end record

  define r_ctc96m08 record
         atlemp     like datkitacia.atlemp
        ,atlmat     like datkitacia.atlmat
        ,atldat     like datkitacia.atldat
        ,funnom     like isskfunc.funnom
        end record
#============================
function ctc96m08_prepare()
#============================
 define l_sql char(500)

 let l_sql =  '  select rscsegimvtipcod      '
             ,'       , rscsegimvtipdes      '
             ,'    from datkrscsegimvtip   '
             ,'  order by rscsegimvtipcod    '

 prepare pctc96m08001 from l_sql
 declare cctc96m08001 cursor for pctc96m08001


 let l_sql =   ' select rscsegimvtipcod        '
              ,'   from datkrscsegimvtip       '
              ,'  where rscsegimvtipcod  = ?   '
 prepare pctc96m08002 from l_sql
 declare cctc96m08002 cursor for pctc96m08002


 let l_sql =   '  insert into datkrscsegimvtip (  rscsegimvtipcod  ,       '
                                         ,'    rscsegimvtipdes  ,       '
                                         ,'    atlusrtipcod,   '
                                         ,'    atlempcod,      '
                                         ,'    atlmatnum,         '
                                         ,'    atldat )        '
                                         ,' values(?,?,?,?,?,?)   '
 prepare pctc96m08003 from l_sql


 let l_sql =   '  update datkrscsegimvtip  set rscsegimvtipdes  = ?  ,  '
                                          ,'    atlusrtipcod  = ?     ,   '
                                          ,'    atlempcod     = ?     ,   '
                                          ,'    atlmatnum     = ?     ,   '
                                          ,'    atldat        = ?         '
                                          ,'  where rscsegimvtipcod   = ?       '
 prepare pctc96m08004 from l_sql


 let l_sql =  'select count(rscsegimvtipdes )   '
             ,'from datkrscsegimvtip            '
             ,'where rscsegimvtipdes  = ?       '
 prepare pctc96m08005 from l_sql
 declare cctc96m08005 cursor for pctc96m08005


 let l_sql =  'delete datkrscsegimvtip       '
              ,'where rscsegimvtipcod  = ?   '
 prepare pctc96m08006 from l_sql

 let l_sql =  'select count(rscsegimvtipcod )  '
             ,'from datkrscsegimvtip           '
             ,'where rscsegimvtipcod  = ?      '
 prepare pctc96m08007 from l_sql
 declare cctc96m08007 cursor for pctc96m08007

 let l_sql =  '  select rscsegimvtipdes     '
             ,'    from datkrscsegimvtip    '
             ,' where rscsegimvtipcod  = ?  '

 prepare pctc96m08008 from l_sql
 declare cctc96m08008 cursor for pctc96m08008

 let l_sql =  '  select first 1 rscsegimvtipcod  '
             ,'    from datmresitaaplitm         '
             ,'   where rscsegimvtipcod  =  ?    '

 prepare pctc96m08009 from l_sql
 declare cctc96m08009 cursor for pctc96m08009

 let l_sql = '   select atlempcod           '
            ,'         ,atlmatnum              '
            ,'         ,atldat              '
            ,'     from datkrscsegimvtip          '
            ,'    where rscsegimvtipcod  =  ?     '
 prepare pctc96m08010 from l_sql
 declare cctc96m08010 cursor for pctc96m08010
 let m_prep = 1

end function

#==============================
function ctc96m08_input_array()
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

  define lr_tela record
         tela char(8)
  end record         
  
  
  initialize a_ctc96m08 to null
  initialize r_ctc96m08.* to null
  initialize lr_tela.*    to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today
  let lr_tela.tela = 'ctc96m08'

  if m_prep <> 1 then
    call ctc96m08_prepare()
  end if

  open window w_ctc96m08 at 6,2 with form 'ctc96mxx'
             attribute(form line first, message line last,comment line last - 1, border)

  display 'CADASTRO DE TIPO DE MORADIA' at 1,29


  while true
    let l_index = 1

    whenever error continue
      open cctc96m08001
    whenever error stop

    foreach cctc96m08001 into a_ctc96m08[l_index].codigo,
                              a_ctc96m08[l_index].descricao
       let l_index = l_index + 1

       if l_index > 500 then
          error " Limite excedido! Foram encontrados mais de 500 produtos!"
          exit foreach
       end if

    message "           (F1) - Inclui      (F2) - Exclui     (F17) - Abandona  "
    end foreach

    let arr_aux = l_index
    if arr_aux = 1  then
       error "Nao foi encontrado nenhum registro, inclua novos!"
    end if

    let m_errflg = "N"
    let l_flag = true

    display by name lr_tela.tela
    call set_count(arr_aux - 1)    
    input array a_ctc96m08 without defaults from s_ctc96mxx.*

         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()

             if arr_aux <= arr_count()  then
                let m_operacao = "p"
             end if
             
             whenever error continue
             open cctc96m08008 using a_ctc96m08[arr_aux].codigo
             fetch cctc96m08008 into l_descricao
             whenever error stop

         #------------------
          before insert
         #------------------
              let m_operacao = 'i'
              initialize a_ctc96m08[arr_aux] to null
              display a_ctc96m08[arr_aux].codigo     to
                      s_ctc96mxx[scr_aux].codigo

        #--------------------
         before field codigo
        #--------------------
               if m_operacao <> 'i' then
                   call ctc96m08_dados_alteracao(a_ctc96m08[arr_aux].codigo)
               end if

               if a_ctc96m08[arr_aux].codigo is null then
                  let m_operacao = 'i'
               else
                  display a_ctc96m08[arr_aux].* to s_ctc96mxx[scr_aux].* attribute(reverse)
                  let m_aux_codigo = a_ctc96m08[arr_aux].codigo
               end if

        #--------------------
         after field codigo
        #--------------------
              display a_ctc96m08[arr_aux].* to s_ctc96mxx[scr_aux].*

              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let a_ctc96m08[arr_aux].codigo = ''
                 display a_ctc96m08[arr_aux].codigo to s_ctc96mxx[scr_aux].codigo

                 let l_flg = 1

                 let m_operacao = "p"
              else
                if a_ctc96m08[arr_aux].codigo is null then
                  if  m_operacao = 'i' then
                     error " Informe o codigo do produto"
                     next field codigo
                  end if
                else
                  if m_operacao = 'i'then
                     let l_tamanho = length(a_ctc96m08[arr_aux].codigo)
                     for i = 1 to l_tamanho
                        if a_ctc96m08[arr_aux].codigo[i] not matches'[0-9]' then
                          let l_flag = false
                        end if
                     end for

                     if l_flag = false then
                         error "O Codigo So Pode Conter Numeros"
                         let a_ctc96m08[arr_aux].codigo = null
                         let l_flag = true
                         next field codigo
                     end if

                     whenever error continue
                        open cctc96m08007 using a_ctc96m08[arr_aux].codigo
                        fetch cctc96m08007 into l_count
                     whenever error stop

                     if l_count > 0 then
                        initialize a_ctc96m08[arr_aux] to null
                        error " Codigo do produto ja cadastrado!"
                        close cctc96m08007
                        next field codigo
                     end if
                     if a_ctc96m08[arr_aux].descricao is null then
                        next field  descricao
                  end if
                   end if
                end if
              end if
              if a_ctc96m08[arr_aux].descricao is not null then
                 let a_ctc96m08[arr_aux].codigo = m_aux_codigo
                 display a_ctc96m08[arr_aux].codigo to s_ctc96mxx[scr_aux].codigo
              end if

        #-------------------------
          before field descricao
        #-------------------------
                 display a_ctc96m08[arr_aux].descricao to
                         s_ctc96mxx[scr_aux].descricao attribute(reverse)

                 if a_ctc96m08[arr_aux].codigo is null then
                    let a_ctc96m08[arr_aux].descricao = null
                    display a_ctc96m08[arr_aux].descricao to
                            s_ctc96mxx[scr_aux].descricao
                    next field codigo
                 end if


        #-------------------------
          after field descricao
        #-------------------------
              display a_ctc96m08[arr_aux].descricao to
                      s_ctc96mxx[scr_aux].descricao

            # Retirar espaços em branco a esqeurada e a direita
              let a_ctc96m08[arr_aux].descricao = fungeral_trim(a_ctc96m08[arr_aux].descricao)
              display a_ctc96m08[arr_aux].descricao to
                      s_ctc96mXX[scr_aux].descricao
            # -

              if l_flg = 1 then
                 let l_prox_arr = arr_aux + 1

                 if a_ctc96m08[l_prox_arr].codigo is not null and
                    a_ctc96m08[l_prox_arr].descricao is null then
                    let a_ctc96m08[l_prox_arr].codigo = null
                 end if
              end if

              let l_count = 0


              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then

                 let l_flg = 1

                 let m_operacao = "p"
              end if
              if a_ctc96m08[arr_aux].descricao is null then
                if m_operacao <> " " then
                   error " Informe a descricao do produto"
                   next field descricao
                end if
              else
                 if m_operacao = 'i' then
                    whenever error continue
                    open cctc96m08005 using a_ctc96m08[arr_aux].descricao
                    fetch cctc96m08005 into l_count
                    whenever error stop

                    if l_count > 0 then
                      error "Este produto ja foi cadastrado com outro codigo"
                      next field descricao
                   end if
                 end if
              end if
                message "           (F1) - Inclui      (F2) - Exclui     (F17) - Abandona  "

        #--------------------
          after row
        #--------------------
               whenever error continue

               case
                   when m_operacao = 'i'
                      call ctc96m08_insert_dados(arr_aux)

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc96m08_update_pergunta_altera(arr_aux, scr_aux) returning l_err
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
               if ctc96m08_verifica_existencia(a_ctc96m08[arr_aux].codigo) then
                  # não existe este registro na tabela datmitaapl
                  call cts08g01("A"
                               ,"S"
                               ,"CONFIRMA A REMOCAO"
                               ,"DO PRODUTO ?"
                               ," "
                               ," " )
                               
                      returning m_confirma
                  
                  if m_confirma = "S"  then
                     let m_errflg = "N"
                  
                     begin work
                  
                     whenever error continue
                     execute pctc96m08006 using a_ctc96m08[arr_aux].codigo
                  
                     if sqlca.sqlcode <> 0  then
                            error " Erro (", sqlca.sqlcode, ") na remocao do ´produto!"
                  
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
                     error " Remocao Cancelada!"
                     exit input
                  end if
               else
                 #o registro existe datmitaapl
                 clear form
                 error " Este Registro Nao pode ser Excluido! "
                 exit input
               end if

               let m_operacao = " "
               initialize a_ctc96m08[arr_aux].*   to null
               display a_ctc96m08[arr_aux].* to s_ctc96mxx[scr_aux].*

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

 close window w_ctc96m08

end function



#================================================
function ctc96m08_update_pergunta_altera(arr_aux, scr_aux)
#================================================

  define arr_aux       smallint
  define scr_aux       smallint
  define l_descricao   char(50)
  define l_count       smallint
  define l_err         smallint

     whenever error continue
     open cctc96m08008 using a_ctc96m08[arr_aux].codigo
     fetch cctc96m08008 into l_descricao
     whenever error stop

     if l_descricao <> a_ctc96m08[arr_aux].descricao  then

       open cctc96m08005 using a_ctc96m08[arr_aux].descricao
       fetch cctc96m08005 into l_count

       if l_count > 0 then
          error "Este produto ja foi cadastrado com outro codigo"
          let l_err = 1
          return l_err
       else
          let l_err = 0
          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DO PRODUTO ?"
                       ," "
                       ," ")
            returning m_confirma

           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc96m08[arr_aux].descricao = l_descricao clipped
              display a_ctc96m08[arr_aux].descricao to s_ctc96mxx[scr_aux].descricao
           end if
        end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute pctc96m08004 using  a_ctc96m08[arr_aux].descricao
                                     , g_issk.usrtip
                                     , g_issk.empcod
                                     , g_issk.funmat
                                     , m_data
                                     , a_ctc96m08[arr_aux].codigo

          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "Produto Alterado Com Sucesso!"
             commit work
          end if
    end if

return l_err

end function

#=======================================
function ctc96m08_insert_dados(arr_aux)
#=======================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint


begin work
  whenever error continue
  open cctc96m08007 using a_ctc96m08[arr_aux].codigo
  fetch cctc96m08007 into l_count
  whenever error stop

  if l_count = 0 then
     execute pctc96m08003 using  a_ctc96m08[arr_aux].codigo
                                ,a_ctc96m08[arr_aux].descricao
                                ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,m_data
     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "Produto Incluido Com Sucesso!"
        commit work
    end if
  end if

end function

#==============================================
function ctc96m08_verifica_existencia(l_cod)
#==============================================
define l_cod          char(4)
define l_registro       char(300)

   error 'Aguarde ... '

   whenever error continue
   open cctc96m08009 using l_cod
   fetch cctc96m08009 into l_registro
   whenever error stop 
   
   error ' '
   
   if l_registro is null then
      return true
   else
      return false
   end if

 end function

#============================================
function ctc96m08_dados_alteracao(l_cod)
#============================================
define l_cod char(4)

   initialize r_ctc96m08.* to null

   whenever error continue
   open cctc96m08010 using l_cod
   fetch cctc96m08010 into  r_ctc96m08.atlemp
                           ,r_ctc96m08.atlmat
                           ,r_ctc96m08.atldat
   whenever error stop
   
   call fungeral_func(r_ctc96m08.atlemp, r_ctc96m08.atlmat)
        returning r_ctc96m08.funnom

   display by name  r_ctc96m08.atldat
                   ,r_ctc96m08.funnom

end function