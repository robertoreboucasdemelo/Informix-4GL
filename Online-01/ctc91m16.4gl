###########################################################################
# Nome do Modulo: ctc91m16                                   Marcos Goes  #
#                                                                         #
# Cadastro de Canal de Venda                                     Set/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descri��o                    #
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

  define a_ctc91m16 array[500] of record
            codigo    char(4)
           ,descricao char(50)
        end record

  define r_ctc91m16 record
         atlemp     like datkitavndcnl.atlemp
        ,atlmat     like datkitavndcnl.atlmat
        ,atldat     like datkitavndcnl.atldat
        ,funnom     like isskfunc.funnom
        end record
        
#============================
function ctc91m16_prepare()
#============================
 define l_sql char(500)

 let l_sql =  '  select vndcnlcod       '
             ,'       , vndcnldes       '
             ,'    from datkitavndcnl   '
             ,'  order by vndcnlcod     '

 prepare pctc91m16001 from l_sql
 declare cctc91m16001 cursor for pctc91m16001


 let l_sql =   ' select vndcnlcod      '
              ,'   from datkitavndcnl  '
              ,'  where vndcnlcod  = ? '
 prepare pctc91m16002 from l_sql
 declare cctc91m16002 cursor for pctc91m16002


 let l_sql =   '  insert into datkitavndcnl (        vndcnlcod ,    '
                                             ,'      vndcnldes ,    '
                                             ,'      atlusrtip ,    '
                                             ,'      atlemp    ,    '
                                             ,'      atlmat    ,    '
                                             ,'      atldat   )     '
                                             ,'    values(?,?,?,?,?,?)    '
 prepare pctc91m16003 from l_sql


 let l_sql =   ' update datkitavndcnl  set         vndcnldes = ?  ,      '
                                             ,'   atlusrtip  = ?  ,      '
                                             ,'   atlemp     = ?  ,      '
                                             ,'   atlmat     = ?  ,      '
                                             ,'   atldat     = ?         '
                                             ,'  where vndcnlcod  = ?   '
 prepare pctc91m16004 from l_sql


 let l_sql =  ' select count(*)   '
             ,' from datkitavndcnl            '
             ,' where vndcnldes  = ?       '
 prepare pctc91m16005 from l_sql
 declare cctc91m16005 cursor for pctc91m16005


 let l_sql =  ' delete datkitavndcnl     '
             ,'  where vndcnlcod  = ?    '
 prepare pctc91m16006 from l_sql

 let l_sql =  ' select count(*)      '
             ,' from datkitavndcnl   '
             ,' where vndcnlcod  = ? '
 prepare pctc91m16007 from l_sql
 declare cctc91m16007 cursor for pctc91m16007

 let l_sql =  ' select vndcnldes       '
             ,'   from datkitavndcnl   '
             ,'  where vndcnlcod  = ?  '

 prepare pctc91m16008 from l_sql
 declare cctc91m16008 cursor for pctc91m16008

 let l_sql =  '  select first 1 vndcnlcod '
             ,'    from datmitaapl        '
             ,'   where vndcnlcod  =  ?   '

 prepare pctc91m16009 from l_sql
 declare cctc91m16009 cursor for pctc91m16009

 let l_sql = '   select atlemp                 '
            ,'         ,atlmat                 '
            ,'         ,atldat                 '
            ,'     from datkitavndcnl       '
            ,'    where vndcnlcod  =  ?  '
 prepare pctc91m16010 from l_sql
 declare cctc91m16010 cursor for pctc91m16010

 let m_prep = 1

end function

#==============================
function ctc91m16_input_array()
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

  initialize a_ctc91m16 to null
  initialize r_ctc91m16.* to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today

  if m_prep <> 1 then
    call ctc91m16_prepare()
  end if

   #RETIRAR ANTES DE COLOCAR EM PRODUCAO
   #let g_issk.usrtip = "F"
   #let g_issk.empcod = 1
   #let g_issk.funmat = 12559  

  open window w_ctc91m00 at 6,2 with form 'ctc91m00'
             attribute(form line first, message line last,comment line last - 1, border)

  display 'CADASTRO DE CANAL DE VENDA' at 1,22

  while true
    let l_index = 1

    whenever error continue
      open cctc91m16001
    whenever error stop

    foreach cctc91m16001 into a_ctc91m16[l_index].codigo,
                              a_ctc91m16[l_index].descricao

       let l_index = l_index + 1

       if l_index > 500 then
          error " Limite excedido! Foram encontrados mais de 500 registros!"
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

    call set_count(arr_aux - 1)
    input array a_ctc91m16 without defaults from s_ctc91m00.*

         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()

             if arr_aux <= arr_count()  then
                let m_operacao = "p"
             end if

             whenever error continue
             open cctc91m16008 using a_ctc91m16[arr_aux].codigo
             fetch cctc91m16008 into l_descricao
             whenever error stop

         #------------------
          before insert
         #------------------
              let m_operacao = 'i'
              initialize a_ctc91m16[arr_aux] to null
              display a_ctc91m16[arr_aux].codigo     to
                      s_ctc91m00[scr_aux].codigo

        #--------------------
         before field codigo
        #--------------------
               if m_operacao <> 'i' then
                   call ctc91m16_dados_alteracao(a_ctc91m16[arr_aux].codigo)
               end if

               if a_ctc91m16[arr_aux].codigo is null then
                  let m_operacao = 'i'
               else
                  display a_ctc91m16[arr_aux].* to s_ctc91m00[scr_aux].* attribute(reverse)
                  let m_aux_codigo = a_ctc91m16[arr_aux].codigo
               end if

        #--------------------
         after field codigo
        #--------------------
              display a_ctc91m16[arr_aux].* to s_ctc91m00[scr_aux].*
              
              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let a_ctc91m16[arr_aux].codigo = ''
                 display a_ctc91m16[arr_aux].codigo to s_ctc91m00[scr_aux].codigo

                 let l_flg = 1

                 let m_operacao = "p"
              else
                if a_ctc91m16[arr_aux].codigo is null then
                  if  m_operacao = 'i' then
                     error " Informe o codigo do CANAL DE VENDA"
                     next field codigo
                  end if
                else
                  if m_operacao = 'i'then
                     let l_tamanho = length(a_ctc91m16[arr_aux].codigo)
                      for i = 1 to l_tamanho
                         if a_ctc91m16[arr_aux].codigo[i] not matches'[0-9]' then
                           let l_flag = false
                         end if
                      end for

                     if l_flag = false then
                         error "O Codigo so pode conter numeros"
                         let a_ctc91m16[arr_aux].codigo = null
                         let l_flag = true
                         next field codigo
                     end if

                     whenever error continue
                        open cctc91m16007 using a_ctc91m16[arr_aux].codigo
                        fetch cctc91m16007 into l_count
                     whenever error stop

                     if l_count > 0 then
                        initialize a_ctc91m16[arr_aux] to null
                        error " Codigo ja cadastrado!"
                        close cctc91m16007
                        next field codigo
                     end if
                     if a_ctc91m16[arr_aux].descricao is null then
                        next field  descricao
                  end if
                   end if
                end if
              end if
              if a_ctc91m16[arr_aux].descricao is not null then
                 let a_ctc91m16[arr_aux].codigo = m_aux_codigo
                 display a_ctc91m16[arr_aux].codigo to s_ctc91m00[scr_aux].codigo
              end if

        #-------------------------
          before field descricao
        #-------------------------
                 display a_ctc91m16[arr_aux].descricao to
                         s_ctc91m00[scr_aux].descricao attribute(reverse)

                 if a_ctc91m16[arr_aux].codigo is null then
                    let a_ctc91m16[arr_aux].descricao = null
                    display a_ctc91m16[arr_aux].descricao to
                            s_ctc91m00[scr_aux].descricao
                    next field codigo
                 end if


        #-------------------------
          after field descricao
        #-------------------------
              display a_ctc91m16[arr_aux].descricao to
                      s_ctc91m00[scr_aux].descricao

            # Retirar espa�os em branco a esquerda e a direita
              let a_ctc91m16[arr_aux].descricao = ctc91m00_trim(a_ctc91m16[arr_aux].descricao)
              display a_ctc91m16[arr_aux].descricao to
                      s_ctc91m00[scr_aux].descricao
            # -

              if l_flg = 1 then
                 let l_prox_arr = arr_aux + 1

                 if a_ctc91m16[l_prox_arr].codigo is not null and
                    a_ctc91m16[l_prox_arr].descricao is null then
                    let a_ctc91m16[l_prox_arr].codigo = null
                 end if
              end if

              let l_count = 0


              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then

                 let l_flg = 1

                 let m_operacao = "p"
              end if
              if a_ctc91m16[arr_aux].descricao is null then
                if m_operacao <> " " then
                   error " Informe a descricao do CANAL DE VENDA"
                   next field descricao
                end if
              else
                 if m_operacao = 'i' then
                    whenever error continue
                    open cctc91m16005 using a_ctc91m16[arr_aux].descricao
                    fetch cctc91m16005 into l_count
                    whenever error stop

                    if l_count > 0 then
                      error "Este CANAL DE VENDA ja foi cadastrado com outro codigo"
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
                      call ctc91m16_insert_dados(arr_aux)

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc91m16_update_pergunta_altera(arr_aux, scr_aux) returning l_err
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
               
               if ctc91m16_verifica_existencia(a_ctc91m16[arr_aux].codigo) then
                  # n�o existe este registro na tabela datmitaapl
               call cts08g01("A"
                            ,"S"
                            ,"CONFIRMA A REMOCAO"
                            ,"DO CANAL DE VENDA ?"
                            ," "
                            ," " )
                   returning m_confirma

               if m_confirma = "S"  then
                  let m_errflg = "N"

                  begin work

                  whenever error continue
                  execute pctc91m16006 using a_ctc91m16[arr_aux].codigo

                  if sqlca.sqlcode <> 0  then
                         error " Erro (", sqlca.sqlcode, ") na remocao do CANAL DE VENDA!"

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
                 #o registro existe na datmitaaplitm
                 clear form
                 error " Este Registro Nao pode ser Excluido! "
                 exit input
               end if

               let m_operacao = " "
               initialize a_ctc91m16[arr_aux].*   to null
               display a_ctc91m16[arr_aux].* to s_ctc91m00[scr_aux].*

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

 close window w_ctc91m00

end function

#================================================
function ctc91m16_update_pergunta_altera(arr_aux, scr_aux)
#================================================

  define arr_aux       smallint
  define scr_aux       smallint
  define l_descricao   char(50)
  define l_count       smallint
  define l_err         smallint

     let l_descricao = ""

     whenever error continue
     open cctc91m16008 using a_ctc91m16[arr_aux].codigo
     fetch cctc91m16008 into l_descricao
     whenever error stop

     if l_descricao <> a_ctc91m16[arr_aux].descricao  then

       open cctc91m16005 using a_ctc91m16[arr_aux].descricao
       fetch cctc91m16005 into l_count

       if l_count > 0 then
          error "Este CANAL DE VENDA ja foi cadastrado com outro codigo"
          let l_err = 1
          return l_err
       else
          let l_err = 0
          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DO CANAL DE VENDA ?"
                       ," "
                       ," ")
            returning m_confirma

           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc91m16[arr_aux].descricao = l_descricao clipped
              display a_ctc91m16[arr_aux].descricao to s_ctc91m00[scr_aux].descricao
           end if
        end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute pctc91m16004 using  a_ctc91m16[arr_aux].descricao
                                     , g_issk.usrtip
                                     , g_issk.empcod
                                     , g_issk.funmat
                                     , m_data
                                     , a_ctc91m16[arr_aux].codigo

          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "CANAL DE VENDA alterado com sucesso!"
             commit work
          end if
    end if

return l_err

end function

#=======================================
function ctc91m16_insert_dados(arr_aux)
#=======================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint

begin work
  whenever error continue
  open cctc91m16007 using a_ctc91m16[arr_aux].codigo
  fetch cctc91m16007 into l_count
  whenever error stop


  if l_count = 0 then
     execute pctc91m16003 using a_ctc91m16[arr_aux].codigo
                                ,a_ctc91m16[arr_aux].descricao
                                ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,m_data
                                
     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "CANAL DE VENDA incluido com sucesso!!"
        commit work
    end if
  end if

end function

#==============================================
function ctc91m16_verifica_existencia(l_cod)
#==============================================
define l_cod          char(4)
define l_registro       char(300)

   error 'Aguarde ... '

   whenever error continue
   open cctc91m16009 using l_cod
   fetch cctc91m16009 into l_registro
   whenever error stop

   error ' '
    
   if l_registro is null then
      return true
   else
      return false
   end if

 end function
 
#============================================
function ctc91m16_dados_alteracao(l_cod)
#============================================
define l_cod char(4)

   initialize r_ctc91m16.* to null

   if m_prep <> 1 then
      call ctc91m16_prepare()
   end if
   whenever error continue
   open cctc91m16010 using l_cod
   fetch cctc91m16010 into  r_ctc91m16.atlemp
                           ,r_ctc91m16.atlmat
                           ,r_ctc91m16.atldat

        whenever error stop
    
   call ctc91m00_func(r_ctc91m16.atlemp, r_ctc91m16.atlmat)
        returning r_ctc91m16.funnom

   display by name  r_ctc91m16.atldat
                   ,r_ctc91m16.funnom

end function