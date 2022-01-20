#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc96m04                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15798                                              #
# Objetivo......: Tela de cadastro de plano                                   #
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

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


  define m_prep      smallint
  define m_operacao  char(1)
  define m_errflg    char(1)
  define m_confirma  char(1)
  define m_data      date
  define m_aux_codigo char(4)

  define a_ctc96m04 array[500] of record
            codigo    char(4)
           ,descricao char(50)
  end record

  define r_ctc96m04 record
         atlemp     like datkitacia.atlemp
        ,atlmat     like datkitacia.atlmat
        ,atldat     like datkitacia.atldat
        ,funnom     like isskfunc.funnom
  end record

  define d_ctc96m04 record
       codprd like datkresitaprd.prdcod
      ,desprd like datkresitaprd.prddes
  end record


#============================
function ctc96m04_prepare()
#============================
 define l_sql char(500)

 let l_sql =  '  select plncod     '
             ,'       , plndes     '
             ,'  from datkresitapln    '
             ,'  where prdcod = ?  '
             ,'  order by plncod   '

 prepare pctc96m04001 from l_sql
 declare cctc96m04001 cursor for pctc96m04001



 let l_sql =   '  insert into datkresitapln (  prdcod ,'
                                          ,'  plncod ,'
                                          ,'  plndes ,'
                                          ,'  atlusrtipcod ,'
                                          ,'  atlempcod    ,'
                                          ,'  atlmat    ,'
                                          ,'  atldat   ) '
                                          ,'  values(?,?,?,?,?,?,?)'
 prepare pctc96m04003 from l_sql


 let l_sql =   '  update datkresitapln  set  plndes  = ?,'
                                      ,'    atlusrtipcod  = ? , '
                                      ,'    atlempcod     = ? , '
                                      ,'    atlmat     = ? , '
                                      ,'    atldat     = ?   '
                                      ,'   where prdcod   = ? '
                                      ,'   and plncod = ? '
 prepare pctc96m04004 from l_sql

 let l_sql =  'select count(plndes )  '
             ,'from datkresitapln   '
             ,'where prdcod = ? '
             ,' and  plndes = ? '
 prepare pctc96m04005 from l_sql
 declare cctc96m04005 cursor for pctc96m04005


 let l_sql =  'delete datkresitapln  '
              ,'where prdcod  = ? '
              ,' and plncod = ? '
 prepare pctc96m04006 from l_sql

 let l_sql =  'select count(plncod )   '
             ,'from datkresitapln    '
             ,'where prdcod  = ? '
             ,' and  plncod = ? '
 prepare pctc96m04007 from l_sql
 declare cctc96m04007 cursor for pctc96m04007

 let l_sql =  '  select plndes     '
             ,'    from datkresitapln    '
             ,'  where prdcod  = ?  '
             ,'  and plncod = ?'

 prepare pctc96m04008 from l_sql
 declare cctc96m04008 cursor for pctc96m04008

 let l_sql =  '  select first 1 plncod   '
             ,'    from datmresitaaplitm '
             ,'  where plncod  =  ?      '
             ,'    and prdcod = ?        '

 prepare pctc96m04009 from l_sql
 declare cctc96m04009 cursor for pctc96m04009

 let l_sql = '   select atlempcod              '
            ,'         ,atlmat              '
            ,'         ,atldat              '
            ,'     from datkresitapln       '
            ,'    where prdcod  =  ?  '
            ,'    and plncod = ? '
 prepare pctc96m04010 from l_sql
 declare cctc96m04010 cursor for pctc96m04010


  let l_sql =  'select prddes '
             ,'from datkresitaprd           '
             ,'where prdcod  = ?      '
 prepare pctc96m04011 from l_sql
 declare cctc96m04011 cursor for pctc96m04011

 let m_prep = 1

end function

#==============================
function ctc96m04_input_array()
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
  define l_retorno     smallint
  define l_ret         smallint



  initialize a_ctc96m04 to null
  initialize r_ctc96m04.* to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today
  let l_retorno = 0
  let l_ret = 0

  if m_prep <> 1 then
    call ctc96m04_prepare()
  end if

  initialize d_ctc96m04.* to null

  open window w_ctc96m04 at 6,2 with form 'ctc96m04'
             attribute(form line first, message line last,comment line last - 1, border)

  display 'CADASTRO PLANOS' at 1,25

  while not int_flag
    clear form

    input by name d_ctc96m04.codprd without defaults
       before field codprd
          display by name d_ctc96m04.codprd attribute (reverse)

       after  field codprd
          display by name d_ctc96m04.codprd
          if d_ctc96m04.codprd is null then
             error " Informe a chave de dominio a ser pesquisada!"
             #next field cponom
             call ctc96m05()
                  returning d_ctc96m04.codprd,d_ctc96m04.desprd
          else
             #whenever error continue
             open cctc96m04011 using d_ctc96m04.codprd
             fetch cctc96m04011 into d_ctc96m04.desprd
             #whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   error "Produto não cadastrado !" sleep 2
                   call ctc96m05()
                        returning d_ctc96m04.codprd,d_ctc96m04.desprd
                end if
             end if
          end if

       display by name d_ctc96m04.desprd




       on key (interrupt, control-c)
          let int_flag = true
          exit input
    end input

    if int_flag then
       exit while
    end if


  while true
    let l_index = 1

    whenever error continue
      open cctc96m04001 using d_ctc96m04.codprd
    whenever error stop

    foreach cctc96m04001 into a_ctc96m04[l_index].codigo,
                              a_ctc96m04[l_index].descricao

       let l_index = l_index + 1

       if l_index > 500 then
          error " Limite excedido! Foram encontrados mais de 500 Segmentos!"
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
    let m_operacao = ""

    call set_count(arr_aux - 1)
    input array a_ctc96m04 without defaults from s_ctc96m04.*

         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()

                 {if arr_aux <= arr_count()  then
                    let m_operacao = "p"
                 end if}

             whenever error continue
             open cctc96m04008 using d_ctc96m04.codprd
                                    ,a_ctc96m04[arr_aux].codigo
             fetch cctc96m04008 into l_descricao
             whenever error stop
             next field codigo

         #------------------
          before insert
         #------------------
              let m_operacao = 'i'
              initialize a_ctc96m04[arr_aux] to null

           ##----------------------------------------------------------

        #--------------------
         before field codigo
        #--------------------
               if m_operacao <> 'i' then
                   call ctc96m04_dados_alteracao(a_ctc96m04[arr_aux].codigo)
               end if

               if a_ctc96m04[arr_aux].codigo is null then
                  let m_operacao = 'i'
               else
                  display a_ctc96m04[arr_aux].* to s_ctc96m04[scr_aux].* attribute(reverse)
                  let m_aux_codigo = a_ctc96m04[arr_aux].codigo
               end if

                 if l_flg = 1 then
                    let l_flg = 0
                    next field codigo
                 end if
        #--------------------
         after field codigo
        #--------------------
              display a_ctc96m04[arr_aux].* to s_ctc96m04[scr_aux].*

              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let a_ctc96m04[arr_aux].codigo = ''
                 display a_ctc96m04[arr_aux].codigo to s_ctc96m04[scr_aux].codigo

                 let l_flg = 1

                 let m_operacao = "p"
              else
                if a_ctc96m04[arr_aux].codigo is null then
                  if  m_operacao = 'i' then
                     error " Informe o codigo do Segmento"
                     next field codigo
                  end if
                else
                  let l_tamanho = length(a_ctc96m04[arr_aux].codigo)
                  for i = 1 to l_tamanho
                     if a_ctc96m04[arr_aux].codigo[i] not matches'[0-9]' then
                       let l_flag = false
                     end if
                  end for

                   if m_operacao = 'i'then
                         #whenever error continue
                        open cctc96m04007 using d_ctc96m04.codprd,a_ctc96m04[arr_aux].codigo
                        fetch cctc96m04007 into l_count
                        # whenever error stop

                     if l_count > 0 then
                        initialize a_ctc96m04[arr_aux] to null
                        error " Codigo de plano ja cadastrado!"
                        close cctc96m04007
                        next field codigo
                     end if
                     if a_ctc96m04[arr_aux].descricao is null then
                        next field  descricao
                     end if
                   end if
                end if
                end if
              if a_ctc96m04[arr_aux].descricao is not null then
                 let a_ctc96m04[arr_aux].codigo = m_aux_codigo
                 display a_ctc96m04[arr_aux].codigo to s_ctc96m04[scr_aux].codigo
              end if

        #-------------------------
          before field descricao
        #-------------------------
                 display a_ctc96m04[arr_aux].descricao to
                         s_ctc96m04[scr_aux].descricao attribute(reverse)

                 if a_ctc96m04[arr_aux].codigo is null then
                    let a_ctc96m04[arr_aux].descricao = null
                    display a_ctc96m04[arr_aux].descricao to
                            s_ctc96m04[scr_aux].descricao
                    next field codigo
                 end if


        #-------------------------
          after field descricao
        #-------------------------
              display a_ctc96m04[arr_aux].descricao to
                      s_ctc96m04[scr_aux].descricao

            # Retirar espaços em branco a esqeurada e a direita
              let a_ctc96m04[arr_aux].descricao = fungeral_trim(a_ctc96m04[arr_aux].descricao)
              display a_ctc96m04[arr_aux].descricao to
                      s_ctc96m04[scr_aux].descricao
            # -

              if l_flg = 1 then
                 let l_prox_arr = arr_aux + 1

                 if a_ctc96m04[l_prox_arr].codigo is not null and
                    a_ctc96m04[l_prox_arr].descricao is null then
                    let a_ctc96m04[l_prox_arr].codigo = null
                 end if
              end if

              let l_count = 0


              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then

                     let l_flg = 1
                     if m_operacao = "i" then
                        initialize a_ctc96m04[arr_aux] to null
                        display a_ctc96m04[arr_aux].* to s_ctc96m04[scr_aux].*
                        next field codigo
                     end if

                 let m_operacao = "p"
              end if
              if a_ctc96m04[arr_aux].descricao is null then
                if m_operacao <> " " then
                   error " Informe a descricao do plano"
                   next field descricao
                end if
              else
                 if m_operacao = 'i' then
                    whenever error continue
                    open cctc96m04005 using d_ctc96m04.codprd
                                           ,a_ctc96m04[arr_aux].descricao
                    fetch cctc96m04005 into l_count
                    whenever error stop

                    if l_count > 0 then
                      error "Este plano ja foi cadastrado com outro codigo"
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
                      call ctc96m04_insert_dados(arr_aux)
                        returning l_ret
                      if l_ret = 1 then
                        let m_operacao = " "
                        exit input
                      end if
                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc96m04_update_pergunta_altera(arr_aux, scr_aux)
                         returning l_err
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

             call ctc96m04_verifica_existencia(a_ctc96m04[arr_aux].codigo,d_ctc96m04.codprd)
                  returning l_retorno
             if l_retorno = 0 then
                  # não existe este registro na tabela datmitaapl
               call cts08g01("A"
                            ,"S"
                            ,"CONFIRMA A REMOCAO"
                            ,"DO SEGMENTO ?"
                            ," "
                            ," " )
                   returning m_confirma

                  if m_confirma = "S"  then
                     let m_errflg = "N"

                     begin work

                     whenever error continue
                     execute pctc96m04006 using d_ctc96m04.codprd
                                               ,a_ctc96m04[arr_aux].codigo

                     if sqlca.sqlcode <> 0  then
                         error " Erro (", sqlca.sqlcode, ") na remocao do Segmento!"
                         let m_errflg = "S"
                         whenever error stop
                     end if

                         whenever error stop
                         if m_errflg = "S"  then
                            rollback work
                         else
                            commit work
                            exit input
                         end if
                         error "Remocao realizada com sucesso!"
                  else
                    clear form
                    error " Remocao Cancelada!"
                    exit input
                 end if
              else
                 #o registro existe na datmitaapl
                 clear form
                 error " Este Registro Nao pode ser Excluido! "
                 exit input
              end if

               let m_operacao = " "
               initialize a_ctc96m04[arr_aux].*   to null
               display a_ctc96m04[arr_aux].* to s_ctc96m04[scr_aux].*

          #--------------------
            on key (accept)
          #--------------------
               continue input

          #--------------------
            on key (interrupt, control-c)
          #--------------------
                 exit input

       end input

       if int_flag  then
          let int_flag = false
          exit while
       end if

    end while
  end while

  let int_flag = false

 close window w_ctc96m04

end function

#================================================
function ctc96m04_update_pergunta_altera(arr_aux, scr_aux)
#================================================

  define arr_aux       smallint
  define scr_aux       smallint
  define l_descricao   char(50)
  define l_count       smallint
  define l_err         smallint


 {let g_issk.funmat = 12435
  let g_issk.empcod = 1
  let g_issk.usrtip = 'F'}


     whenever error continue
     open cctc96m04008 using d_ctc96m04.codprd
                            ,a_ctc96m04[arr_aux].codigo
     fetch cctc96m04008 into l_descricao
     whenever error stop

     if l_descricao <> a_ctc96m04[arr_aux].descricao  then
       whenever error continue
        open cctc96m04005 using d_ctc96m04.codprd,a_ctc96m04[arr_aux].descricao
        fetch cctc96m04005 into l_count
       whenever error stop
       if l_count > 0 then
          error "Este plano ja foi cadastrada com outro codigo"
          let l_err = 1
          return l_err
       end if
     end if


     if l_descricao <> a_ctc96m04[arr_aux].descricao then
          let l_err = 0
          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DO SEGMENTO ?"
                       ," "
                       ," ")
            returning m_confirma

           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc96m04[arr_aux].descricao = l_descricao clipped
              display a_ctc96m04[arr_aux].descricao to s_ctc96m04[scr_aux].descricao
           end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute pctc96m04004 using   a_ctc96m04[arr_aux].descricao
                                     , g_issk.usrtip
                                     , g_issk.empcod
                                     , g_issk.funmat
                                     , m_data
                                     , d_ctc96m04.codprd
                                     , a_ctc96m04[arr_aux].codigo

          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "Segmento Alterado com Sucesso!"
             commit work
          end if
          let m_operacao = ' '
    end if

return l_err

end function

#=======================================
function ctc96m04_insert_dados(arr_aux)
#=======================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
  define l_retorno     smallint

{let g_issk.usrtip = "F"
let g_issk.empcod = 1
let g_issk.funmat = 12435}

begin work
  whenever error continue
  open cctc96m04007 using d_ctc96m04.codprd,a_ctc96m04[arr_aux].codigo
  fetch cctc96m04007 into l_count
  whenever error stop

  if l_count = 0 then
     let l_retorno = 0
     execute pctc96m04003 using  d_ctc96m04.codprd
                                ,a_ctc96m04[arr_aux].codigo
                                ,a_ctc96m04[arr_aux].descricao
                                ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,m_data

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "Plano Incluido com Sucesso!"
        commit work
        let l_retorno = 1
    end if
  end if
 return l_retorno
end function

#====================================================
function ctc96m04_verifica_existencia(l_cod,l_prod)
#====================================================
define l_cod         char(4)
define l_prod        smallint
define l_registro    char(300)
define l_retorno     smallint

   error 'Aguarde ... '

   whenever error continue
   open cctc96m04009 using l_cod
                          ,l_prod
   fetch cctc96m04009 into l_registro
   whenever error stop

   error ' '

   if sqlca.sqlcode = 100 then
      let l_retorno = 0
   else
      let l_retorno = 1
   end if
  return l_retorno

 end function

#============================================
function ctc96m04_dados_alteracao(l_cod)
#============================================
define l_cod char(4)


   initialize r_ctc96m04.* to null

   if m_prep <> 1 then
      call ctc96m04_prepare()
   end if
   whenever error continue
   open cctc96m04010 using d_ctc96m04.codprd,l_cod
   fetch cctc96m04010 into  r_ctc96m04.atlemp
                           ,r_ctc96m04.atlmat
                           ,r_ctc96m04.atldat
   whenever error stop


   call fungeral_func(r_ctc96m04.atlemp, r_ctc96m04.atlmat)
        returning r_ctc96m04.funnom

   display by name  r_ctc96m04.atldat
                   ,r_ctc96m04.funnom

end function