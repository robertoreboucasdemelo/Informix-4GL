###########################################################################
# Nome do Modulo: ctc92m08                               Helder Oliveira  #
#                                                                         #
# Cadastro Pessoa VIP                                            May/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep      smallint
  define m_operacao  char(1)
  define m_errflg    char(1)
  define m_confirma  char(1)
  define m_data      date
  define m_aux_codigo char(4)
  define m_pesquisa  smallint
  define m_flag_todos smallint
  define l_pesq_tipo_pessoa like datkitavippes.pestipcod
  define l_pesq_cpf_num   like  datkitavippes.cgccpfnum
  define l_pesq_ord_num   like  datkitavippes.cgccpford
  define l_pesq_cpf_dig   like  datkitavippes.cgccpfdig
  define l_pesq_seg_nom   like  datkitavippes.pesnom

  define a_ctc92m08 array[2000] of record
            tipo_pessoa   like  datkitavippes.pestipcod
          , cpf_num       like  datkitavippes.cgccpfnum
          , ord_num       like  datkitavippes.cgccpford
          , cpf_dig       like  datkitavippes.cgccpfdig
          , seg_nom       like  datkitavippes.pesnom
        end record

   define l_digito_cpf like datkitavippes.cgccpfdig

   define r_ctc92m08 record
         atlemp     like datkitavippes.atlemp
        ,atlmat                    like datkitavippes.atlmat               
        ,atldat     like datkitavippes.atldat  
        ,funnom     char(50)
        end record

# variaveis para input
  define l_index       smallint
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
  define l_tamanho     smallint
  define l_i           smallint
  define l_flag        smallint   #verifica se existe letras no campo codigo
  define l_flg         smallint   #verifica se foi up down
  define l_descricao   char(50)
  define l_prox_arr    smallint
  define l_err         smallint
  define l_arr_count   smallint
  define l_atv_flag    char(1)
# fim

#============================
function ctc92m08_prepare()
#============================
 define l_sql char(500)

 let l_sql =  ' select cgccpfnum       '
             ,'      , cgccpford       '
             ,'      , cgccpfdig       '
             ,'      , pesnom          '
             ,'      , pestipcod       '
             ,'   from datkitavippes   '
             ,'  where atvflg    = "S" '
             ,' order by pesnom        '

 prepare pctc92m08001 from l_sql
 declare cctc92m08001 cursor for pctc92m08001

 let l_sql =  ' select cgccpfnum    '
             ,'      , cgccpford    '
             ,'      , cgccpfdig    '
             ,'      , pesnom          '
             ,'      , pestipcod       '
             ,'   from datkitavippes   '
             ,'  where cgccpfnum  = ?  '
             ,'    and pestipcod  = ?  '
             ,'    and atvflg     = "S"'
             ,' order by pesnom        '

 prepare pctc92m08002 from l_sql
 declare cctc92m08002 cursor for pctc92m08002

 let l_sql =    ' insert into  datkitavippes   '
               ,' ( cgccpfnum                  '
               ,'  ,cgccpford                  '
               ,'  ,cgccpfdig                  '
               ,'  ,pesnom                     '
               ,'  ,pestipcod                  '
               ,'  ,atlemp                     '
               ,'  ,atlmat                     '
               ,'  ,atlusrtip                  '
               ,'  ,atldat                     '
               ,'  ,atvflg   )                 '
               ,' values( ?,?,?,?,?,?,?,?,?,"S") '
 prepare pctc92m08003 from l_sql

 let l_sql =    ' update datkitavippes         '
               ,' set pesnom     = ?          '
               ,'    ,atlusrtip  = ?          '
               ,'    ,atlemp     = ?          '
               ,'    ,atlmat     = ?          '
               ,'    ,atldat     = ?          '
               ,' where cgccpfnum = ?      '
               ,'   and cgccpford = ?      '
               ,'   and cgccpfdig = ?      '
 prepare pctc92m08004 from l_sql

 let l_sql  =   ' select atvflg            '
               ,' from datkitavippes       '
               ,' where cgccpfnum = ?      '
               ,'   and cgccpford = ?      '
               ,'   and cgccpfdig = ?      '
 prepare pctc92m08005 from l_sql
 declare cctc92m08005 cursor for pctc92m08005
 
 let l_sql =  ' update datkitavippes   '
             ,'    set atvflg    = "N" '
             ,'  where cgccpfnum = ?   '
             ,'    and cgccpford = ?   '
             ,'    and cgccpfdig = ?   '
 prepare pctc92m08006 from l_sql

 let l_sql =  ' select count(pesnom)    '
             ,'   from datkitavippes    '
             ,'  where cgccpfnum = ? '
             ,'    and cgccpford = ? '
             ,'    and cgccpfdig = ? '
 prepare pctc92m08007 from l_sql
 declare cctc92m08007 cursor for pctc92m08007

 let l_sql =  ' select pesnom           '
             ,'   from datkitavippes    '
             ,'  where cgccpfnum = ? '
             ,'    and cgccpford = ? '
             ,'    and cgccpfdig = ? '
 prepare pctc92m08008 from l_sql
 declare cctc92m08008 cursor for pctc92m08008

 let l_sql  =   ' delete datkitavippes     '
               ,' where cgccpfnum = ?      '
               ,'   and cgccpford = ?      '
               ,'   and cgccpfdig = ?      '
 prepare pctc92m08009 from l_sql

 let l_sql = '   select atlemp                '
            ,'         ,atlmat                               '
            ,'         ,atldat                '
            ,'     from datkitavippes         '
            ,'    where cgccpfnum  =  ?    '
            ,'      and cgccpford  =  ?    '
            ,'      and cgccpfdig  =  ?    '
 prepare pctc92m08010 from l_sql
 declare cctc92m08010 cursor for pctc92m08010

  let l_sql = ' update datmitaapl       '
           , '    set vipsegflg = "S"  '
           , '  where segcgccpfnum = ? '
           , '    and segcgccpfdig = ? '
 prepare pctc92m08013 from l_sql

 let l_sql = ' update datmitaapl       '
           , '    set vipsegflg = "S"  '
           , '  where segcgccpfnum = ? '
           , '    and segcgcordnum = ? '
           , '    and segcgccpfdig = ? '
  prepare pctc92m08014 from l_sql
  
 let l_sql = ' select count(*)            '
           , '   from datmitaapl          '
           , '  where segcgccpfnum = ?    '
           , '    and segcgccpfdig = ?    '
 prepare pctc92m08015 from l_sql
 declare cctc92m08015 cursor for pctc92m08015
           
 let l_sql = ' select count(*)            '
           , '   from datmitaapl          '
           , '  where segcgccpfnum = ? '
           , '    and segcgcordnum = ? '
           , '    and segcgccpfdig = ? '          
 prepare pctc92m08016 from l_sql
 declare cctc92m08016 cursor for pctc92m08016
  
   let l_sql = ' update datmitaapl       '
           , '    set vipsegflg = "N"  '
           , '  where segcgccpfnum = ? '
           , '    and segcgccpfdig = ? '
 prepare pctc92m08017 from l_sql 
  
  let l_sql = ' update datmitaapl       '
           , '    set vipsegflg = "N"  '
           , '  where segcgccpfnum = ? '
           , '    and segcgcordnum = ? '
           , '    and segcgccpfdig = ? '
  prepare pctc92m08018 from l_sql 
  
 let m_prep = 1
end function

#============================================
function ctc92m08_prepare2(l_nome)
#============================================
define l_nome char(100)
define l_sql  char(5000)

 let l_sql =  ' select cgccpfnum          '
             ,'      , cgccpford          '
             ,'      , cgccpfdig          '
             ,'      , pesnom             '
             ,'      , pestipcod          '
             ,'   from datkitavippes      '
             ,'  where pesnom like "%',l_nome clipped,'%"'
             ,'    and atvflg     = "S"'
             ,' order by pesnom           '

 prepare pctc92m08012 from l_sql
 declare cctc92m08012 cursor for pctc92m08012
 
let l_sql =  ' select cgccpfnum         '
             ,'      , cgccpford         '
             ,'      , cgccpfdig         '
             ,'      , pesnom            '
             ,'      , pestipcod         '
             ,'   from datkitavippes     '
             ,'  where pesnom like "%',l_nome clipped,'%"'
             ,'    and pestipcod =   ?   '
             ,'    and atvflg     = "S"'
             ,' order by pesnom          '

 prepare pctc92m08011 from l_sql
 declare cctc92m08011 cursor for pctc92m08011


end function

#==============================
function ctc92m08_input_array()
#==============================
  initialize a_ctc92m08 to null
  initialize r_ctc92m08.* to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today
  let m_pesquisa = false

  if m_prep <> 1 then
    call ctc92m08_prepare()
  end if

  open window w_ctc92m08 at 6,2 with form 'ctc92m08'
             attribute(form line first, message line last,comment line last - 1, border)

  display 'CADASTRO DE PESSOA VIP ' at 1,28

     call ctc92m08_busca_dados()
    
  close window w_ctc92m08

end function

#=========================================================
function ctc92m08_busca_dados()
#=========================================================
  initialize a_ctc92m08 to null
   let l_index = 1

    if m_pesquisa then
       
# --------- [ Pesquisa por CPF/CNPJ ] --------- #
       if l_pesq_cpf_num is not null then #and  
          #l_pesq_seg_nom is null then

         whenever error continue
          open cctc92m08002 using l_pesq_cpf_num
                                , l_pesq_tipo_pessoa
         whenever error stop
                                
          foreach cctc92m08002 into a_ctc92m08[l_index].cpf_num
                                  , a_ctc92m08[l_index].ord_num
                                  , a_ctc92m08[l_index].cpf_dig
                                  , a_ctc92m08[l_index].seg_nom
                                  , a_ctc92m08[l_index].tipo_pessoa

              let l_index = l_index + 1
       
              if l_index > 1500 then
                 error " Limite excedido! Foram encontrados mais de 1500 Pessoas VIP!"
                 exit foreach
              end if
       
          end foreach
          message " (F1)-Inclui (F2)-Exclui (F5)-Pesquisa (F6)-Todos  (F17)-Abandona "
       end if
       
# ----------- [ Pesquisa por Nome ] ----------- #
       if l_pesq_cpf_num is null and
          l_pesq_seg_nom is not null then
          if l_pesq_tipo_pessoa is null then

             call ctc92m08_prepare2(l_pesq_seg_nom)

             open cctc92m08012 
             
             foreach cctc92m08012 into a_ctc92m08[l_index].cpf_num
                                     , a_ctc92m08[l_index].ord_num
                                     , a_ctc92m08[l_index].cpf_dig
                                     , a_ctc92m08[l_index].seg_nom
                                     , a_ctc92m08[l_index].tipo_pessoa
          
                 let l_index = l_index + 1
          
                 if l_index > 1500 then
                    error " Limite excedido! Foram encontrados mais de 1500 Pessoas VIP!"
                    exit foreach
                 end if
          
             end foreach
             message " (F1)-Inclui (F2)-Exclui (F5)-Pesquisa (F6)-Todos  (F17)-Abandona "            
          else
          
             call ctc92m08_prepare2(l_pesq_seg_nom)
          
             open cctc92m08011 using l_pesq_tipo_pessoa
             
             foreach cctc92m08011 into a_ctc92m08[l_index].cpf_num
                                     , a_ctc92m08[l_index].ord_num
                                     , a_ctc92m08[l_index].cpf_dig
                                     , a_ctc92m08[l_index].seg_nom
                                     , a_ctc92m08[l_index].tipo_pessoa
          
                 let l_index = l_index + 1
          
                 if l_index > 1500 then
                    error " Limite excedido! Foram encontrados mais de 1500 Pessoas VIP!"
                    exit foreach
                 end if
          
             end foreach
             message " (F1)-Inclui (F2)-Exclui (F5)-Pesquisa (F6)-Todos  (F17)-Abandona "      
         end if       
       end if 
    else
        whenever error continue
         open cctc92m08001
       whenever error stop
       
       foreach cctc92m08001 into a_ctc92m08[l_index].cpf_num
                               , a_ctc92m08[l_index].ord_num
                               , a_ctc92m08[l_index].cpf_dig
                               , a_ctc92m08[l_index].seg_nom
                               , a_ctc92m08[l_index].tipo_pessoa
       
          let l_index = l_index + 1
       
          if l_index > 1500 then
             error " Limite excedido! Foram encontrados mais de 1500 Pessoas VIP!"
             exit foreach
          end if
       
       end foreach
       message " (F1)-Inclui (F2)-Exclui (F5)-Pesquisa (F6)-Todos  (F17)-Abandona "
    end if

    let arr_aux = l_index
    if arr_aux = 1  then
       if m_pesquisa then
         error "Nenhum registro encontrado!"
         let m_operacao = ''
       else
         error "Nao foi encontrado nenhum registro, inclua novos!"
       end if
    end if

    let m_errflg = "N"
    let l_flag = true

    let m_flag_todos = false
    
    call ctc92m08_input_dados()

end function


#=========================================================
function ctc92m08_input_dados()
#=========================================================
define l_existe smallint

  while true
    
    call set_count(arr_aux - 1)
    input array a_ctc92m08 without defaults from s_ctc92m08.*

         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
             let l_arr_count = arr_count()

             if arr_aux <= arr_count()  then
                let m_operacao = "p"
             end if

        #-------------------------
          before insert
         #-------------------------
              let m_operacao = 'i'
              initialize a_ctc92m08[arr_aux] to null
              display a_ctc92m08[arr_aux].tipo_pessoa     to
                      s_ctc92m08[scr_aux].tipo_pessoa

        #-------------------------
         before field tipo_pessoa
         #-------------------------

               if m_operacao <> 'i' then
                   call ctc92m08_dados_alteracao( a_ctc92m08[arr_aux].cpf_num
                                               ,  a_ctc92m08[arr_aux].ord_num
                                               ,  a_ctc92m08[arr_aux].cpf_dig  )
               end if
 
               if m_pesquisa and
                  ( a_ctc92m08[arr_aux].tipo_pessoa is null or 
                    a_ctc92m08[arr_aux].tipo_pessoa = '' or
                    a_ctc92m08[arr_aux].tipo_pessoa = ' ' )  then
                  let m_pesquisa = false
                  let m_flag_todos = true
                  let int_flag = true
                  exit input
               else
                  let m_pesquisa = false
               end if

               if a_ctc92m08[arr_aux].tipo_pessoa is null then
                  let m_operacao = 'i'
               else
                  display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].* attribute(reverse)
                  let m_aux_codigo = a_ctc92m08[arr_aux].tipo_pessoa
               end if

        #-------------------------
         after field tipo_pessoa
        #-------------------------
              display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].*

              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let a_ctc92m08[arr_aux].tipo_pessoa = ''
                 display a_ctc92m08[arr_aux].tipo_pessoa to s_ctc92m08[scr_aux].tipo_pessoa

                 let l_flg = 1

                 let m_operacao = "p"

              else
                if a_ctc92m08[arr_aux].tipo_pessoa is null then
                  if  m_operacao = 'i' then
                     error " Informe o Tipo de Pessoa (F)isica ou (J)uridica"
                     next field tipo_pessoa
                  end if
                else
                  if m_operacao = 'i'then
                     if a_ctc92m08[arr_aux].tipo_pessoa <> "F" and
                        a_ctc92m08[arr_aux].tipo_pessoa <> "J" then
                         error " Digite tipo de pessoa -> (F)isica ou (J)uridica "
                         let a_ctc92m08[arr_aux].tipo_pessoa = null
                         next field tipo_pessoa
                     end if
                   else
                     if fgl_lastkey() = fgl_keyval("return") or
                        fgl_lastkey() = fgl_keyval("right")   then
                        let m_operacao = "p"

                        if a_ctc92m08[arr_aux].cpf_num is not null and
                           a_ctc92m08[arr_aux].ord_num is not null and
                           a_ctc92m08[arr_aux].cpf_dig is not null and
                           a_ctc92m08[arr_aux].seg_nom is not null then
                           let a_ctc92m08[arr_aux].tipo_pessoa = m_aux_codigo
                           display a_ctc92m08[arr_aux].tipo_pessoa to s_ctc92m08[scr_aux].tipo_pessoa
                           next field seg_nom
                        end if
                     end if
                   end if
                end if
              end if

              if a_ctc92m08[arr_aux].cpf_num is not null then
                 let a_ctc92m08[arr_aux].tipo_pessoa = m_aux_codigo
                 display a_ctc92m08[arr_aux].tipo_pessoa to s_ctc92m08[scr_aux].tipo_pessoa
              end if

        #-------------------------
          before field cpf_num
        #-------------------------
                 display a_ctc92m08[arr_aux].cpf_num to
                         s_ctc92m08[scr_aux].cpf_num attribute(reverse)

                 if a_ctc92m08[arr_aux].tipo_pessoa is null then
                    let a_ctc92m08[arr_aux].cpf_num = null
                    display a_ctc92m08[arr_aux].cpf_num to
                            s_ctc92m08[scr_aux].cpf_num
                    next field tipo_pessoa
                 end if

        #-------------------------
          after field cpf_num
        #-------------------------
              display a_ctc92m08[arr_aux].cpf_num  to
                      s_ctc92m08[scr_aux].cpf_num

              if l_flg = 1 then
                 let l_prox_arr = arr_aux + 1

                 if a_ctc92m08[l_prox_arr].tipo_pessoa is not null and
                    a_ctc92m08[l_prox_arr].cpf_num is null then
                    let a_ctc92m08[l_prox_arr].tipo_pessoa = null
                 end if
              end if

              let l_count = 0

              if fgl_lastkey() = fgl_keyval("up")   then
                 let l_flg = 1
                 initialize a_ctc92m08[arr_aux] to null
                 display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].*
                 let m_operacao = "p"
                 next field tipo_pessoa
              else
                 if a_ctc92m08[arr_aux].cpf_num is null then
                    if m_operacao <> " " then
                       error " Informe o numero do cpf!"
                       next field cpf_num
                    end if
                 else
                   if m_operacao = 'i' then
                      if a_ctc92m08[arr_aux].tipo_pessoa = "F" then
                         let a_ctc92m08[arr_aux].ord_num = 0
                         display a_ctc92m08[arr_aux].ord_num to s_ctc92m08[scr_aux].ord_num
                         next field cpf_dig
                      end if
                   end if
                end if
              end if

          message " (F1)-Inclui (F2)-Exclui (F5)-Pesquisa (F6)-Todos  (F17)-Abandona "

        #-------------------------
          before field ord_num
        #-------------------------
            display a_ctc92m08[arr_aux].ord_num  to
                    s_ctc92m08[scr_aux].ord_num attribute(reverse)

            if a_ctc92m08[arr_aux].tipo_pessoa is null then
               let a_ctc92m08[arr_aux].ord_num = null
               display a_ctc92m08[arr_aux].ord_num to
                       s_ctc92m08[scr_aux].ord_num
               next field tipo_pessoa
            end if

        #-------------------------
          after field ord_num
        #-------------------------
            display a_ctc92m08[arr_aux].ord_num  to
                    s_ctc92m08[scr_aux].ord_num

              if fgl_lastkey() = fgl_keyval("up")   then
                 let l_flg = 1
                 initialize a_ctc92m08[arr_aux] to null
                 display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].*
                 let m_operacao = "p"
                 next field tipo_pessoa
              else
                 if a_ctc92m08[arr_aux].ord_num is null or
                    a_ctc92m08[arr_aux].ord_num = '' then
                    error 'Numero da Ordem nao pode ser nulo para pessoa (J)uridica'
                    next field ord_num
                 end if
             end if
             
        #-------------------------
          before field cpf_dig
        #-------------------------
            display a_ctc92m08[arr_aux].cpf_dig  to
                    s_ctc92m08[scr_aux].cpf_dig attribute(reverse)

                 if a_ctc92m08[arr_aux].tipo_pessoa is null then
                    let a_ctc92m08[arr_aux].cpf_dig = null
                    display a_ctc92m08[arr_aux].cpf_dig to
                            s_ctc92m08[scr_aux].cpf_dig
                    next field tipo_pessoa
                 end if

        #-------------------------
          after field cpf_dig
        #-------------------------
            display a_ctc92m08[arr_aux].cpf_dig  to
                    s_ctc92m08[scr_aux].cpf_dig

             if fgl_lastkey() = fgl_keyval("up")   then
                 let l_flg = 1
                 initialize a_ctc92m08[arr_aux] to null
                 display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].*
                 let m_operacao = "p"
                 next field tipo_pessoa
              else
                 if a_ctc92m08[arr_aux].cpf_dig is null or
                    a_ctc92m08[arr_aux].cpf_dig = '' then
                    error 'Digito de CPF/CNPJ nao pode ser nulo !'
                    next field cpf_dig
                 else
                    if a_ctc92m08[arr_aux].tipo_pessoa =  "J"    then
                      call F_FUNDIGIT_DIGITOCGC(a_ctc92m08[arr_aux].cpf_num,
                                                a_ctc92m08[arr_aux].ord_num   )
                       returning l_digito_cpf
                    else
                       call F_FUNDIGIT_DIGITOCPF(a_ctc92m08[arr_aux].cpf_num)
                       returning l_digito_cpf
                    end if

                    if l_digito_cpf                is null            or
                       a_ctc92m08[arr_aux].cpf_dig  <>  l_digito_cpf   then
                       error " Digito do CGC/CPF incorreto!"
                       next field cpf_dig
                    else
                         let l_count = 0
                         whenever error continue
                         open cctc92m08007 using a_ctc92m08[arr_aux].cpf_num
                                               , a_ctc92m08[arr_aux].ord_num
                                               , a_ctc92m08[arr_aux].cpf_dig
                         fetch cctc92m08007 into l_count
                         whenever error stop

                          if l_count > 0 then
                            whenever error continue 
                             open cctc92m08005 using  a_ctc92m08[arr_aux].cpf_num
                                                    , a_ctc92m08[arr_aux].ord_num
                                                    , a_ctc92m08[arr_aux].cpf_dig
                            
                             fetch cctc92m08005 into l_atv_flag   3
                             whenever error stop               
                             
                             if l_atv_flag = 'S' then
                                initialize a_ctc92m08[arr_aux] to null
                                display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].*
                                error " Este CPF/CNPJ ja esta cadastrado! "
                                close cctc92m08007
                                next field cpf_num
                             end if
                          end if
                    end if
                 end if
             end if

        #-------------------------
          before field seg_nom
        #-------------------------
            display a_ctc92m08[arr_aux].seg_nom  to
                    s_ctc92m08[scr_aux].seg_nom attribute(reverse)

                 if a_ctc92m08[arr_aux].tipo_pessoa is null then
                    let a_ctc92m08[arr_aux].seg_nom = null
                    display a_ctc92m08[arr_aux].seg_nom to
                            s_ctc92m08[scr_aux].seg_nom
                    next field tipo_pessoa
                 end if
                 
        #-------------------------
          after field seg_nom
        #-------------------------
            display a_ctc92m08[arr_aux].seg_nom  to
                    s_ctc92m08[scr_aux].seg_nom

            if fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("down") then
                next field tipo_pessoa
            else
               # Retirar espaços em branco a esqeurada e a direita
                 let a_ctc92m08[arr_aux].seg_nom = ctc91m00_trim(a_ctc92m08[arr_aux].seg_nom)
                 display a_ctc92m08[arr_aux].seg_nom to
                         s_ctc92m08[scr_aux].seg_nom
               # -

                   if a_ctc92m08[arr_aux].seg_nom is null or
                       a_ctc92m08[arr_aux].seg_nom = '' then
                       error 'Nome do Segurado Pessoa VIP nao pode ser nulo!'
                       next field seg_nom
                    end if
            end if

        #--------------------
          after row
        #--------------------
               whenever error continue

               case
                   when m_operacao = 'i'
                      if not ctc92m08_insert_dados()  then
                         let m_flag_todos = true
                         let int_flag = true
                         exit input 
                      end if

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc92m08_update_pergunta_altera() 
                      returning l_err
                      if l_err = 1 then
                         next field tipo_pessoa
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

               call cts08g01("A"
                            ,"S"
                            ,"CONFIRMA A REMOCAO"
                            ,"DA PESSOA VIP ?"
                            ," "
                            ," " )
                   returning m_confirma

               if m_confirma = "S"  then
                  let m_errflg = "N"

                  #begin work

                  whenever error continue
                  execute pctc92m08006 using  a_ctc92m08[arr_aux].cpf_num
                                            , a_ctc92m08[arr_aux].ord_num
                                            , a_ctc92m08[arr_aux].cpf_dig
                  whenever error stop
                  if sqlca.sqlcode <> 0  then
                         error " Erro (", sqlca.sqlcode, ") na remocao da Pessoa VIP!"

                         let m_errflg = "S"
                         whenever error stop
                  end if
                  
                  # --- verifica se existe apolice para esta Pessoa VIP e atualiza N
                    if a_ctc92m08[arr_aux].tipo_pessoa = 'F' then
                       whenever error continue
                       open cctc92m08015 using a_ctc92m08[arr_aux].cpf_num
                                             , a_ctc92m08[arr_aux].cpf_dig
                       fetch cctc92m08015 into l_existe
                       whenever error stop
                       
                       if l_existe > 0 then
                          whenever error continue
                             execute pctc92m08017 using a_ctc92m08[arr_aux].cpf_num
                                                      , a_ctc92m08[arr_aux].cpf_dig
                          whenever error stop
                          
                          if sqlca.sqlcode <> 0 then
                             error 'Erro (',sqlca.sqlcode,') na atualizacao dos dados da apolice'
                             let m_errflg = 'S'
                          end if           
                       end if
                    else
                       whenever error continue
                       open cctc92m08016 using a_ctc92m08[arr_aux].cpf_num
                                             , a_ctc92m08[arr_aux].ord_num
                                             , a_ctc92m08[arr_aux].cpf_dig
                       fetch cctc92m08016 into l_existe
                       whenever error stop
                       
                       if l_existe > 0 then
                          whenever error continue
                          execute pctc92m08018 using a_ctc92m08[arr_aux].cpf_num
                                                   , a_ctc92m08[arr_aux].ord_num
                                                   , a_ctc92m08[arr_aux].cpf_dig
                          whenever error stop
                          if sqlca.sqlcode <> 0 then
                             error 'Erro (',sqlca.sqlcode,') na atualizacao dos dados da apolice'
                             let m_errflg = 'S'
                          end if    
                       end if
                    end if 
                  

                      whenever error stop
                      if m_errflg = "S"  then
                    #     rollback work
                      else
                   #      commit work
                         error " Remocao Efetuada! "

                             let m_flag_todos = true
                             let int_flag = true
                             exit input
  
                      end if
               else
                  clear form
                  error " Remocao Cancelada! "
                  

                     let m_flag_todos = true
                     let int_flag = true
                     exit input

                  
               end if

               let m_operacao = " "
               initialize a_ctc92m08[arr_aux].*   to null
               display a_ctc92m08[arr_aux].* to s_ctc92m08[scr_aux].*

          #--------------------
            on key (F5)
          #--------------------
            let m_operacao = '' 
            call ctc92m08_pesquisa()
                 returning l_pesq_tipo_pessoa
                          ,l_pesq_cpf_num
                          ,l_pesq_ord_num
                          ,l_pesq_cpf_dig
                          ,l_pesq_seg_nom

            if l_pesq_cpf_num is null and
               l_pesq_seg_nom is null then
               error "Pesquisa Cancelada!"
               
               let m_flag_todos = true
               let int_flag = true
               exit input
               
            else
               let m_pesquisa = true 
               exit input           
            end if
            
          #--------------------
            on key (F6)
          #--------------------
            let m_flag_todos = true
            let int_flag = true
            exit input
            
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
 
       if m_pesquisa then
          exit while
       end if

       if int_flag  then
          let int_flag = false
          exit while
       end if

  end while

  if m_pesquisa then
     call ctc92m08_busca_dados()
  else
     if m_flag_todos then
        let m_pesquisa = false
        call ctc92m08_busca_dados()
     end if
  end if

  let int_flag = false

end function


#================================================
function ctc92m08_update_pergunta_altera() 
#================================================

     whenever error continue
     open cctc92m08008 using  a_ctc92m08[arr_aux].cpf_num
                            , a_ctc92m08[arr_aux].ord_num
                            , a_ctc92m08[arr_aux].cpf_dig
     fetch cctc92m08008 into l_descricao
     whenever error stop

     if l_descricao <> a_ctc92m08[arr_aux].seg_nom  then

          let l_err = 0

          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DA PESSOA VIP ?"
                       ," "
                       ," ")
            returning m_confirma

           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc92m08[arr_aux].seg_nom = l_descricao clipped
              display a_ctc92m08[arr_aux].seg_nom to s_ctc92m08[scr_aux].seg_nom
           end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute pctc92m08004 using  a_ctc92m08[arr_aux].seg_nom
                                     , g_issk.usrtip
                                     , g_issk.empcod
                                     , g_issk.funmat
                                     , m_data
                                     , a_ctc92m08[arr_aux].cpf_num
                                     , a_ctc92m08[arr_aux].ord_num
                                     , a_ctc92m08[arr_aux].cpf_dig
       whenever error stop
          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "Alteracao Realizada!"
             commit work
          end if
    end if

 return l_err

end function
#
#=======================================
function ctc92m08_insert_dados()
#=======================================
define l_existe smallint

 let l_existe = 0

#begin work
  whenever error continue
 open cctc92m08007 using a_ctc92m08[arr_aux].cpf_num
                       , a_ctc92m08[arr_aux].ord_num
                       , a_ctc92m08[arr_aux].cpf_dig
 fetch cctc92m08007 into l_count
  whenever error stop

  if l_count = 0 then
    whenever error continue
     execute pctc92m08003 using  a_ctc92m08[arr_aux].cpf_num
                                ,a_ctc92m08[arr_aux].ord_num
                                ,a_ctc92m08[arr_aux].cpf_dig
                                ,a_ctc92m08[arr_aux].seg_nom
                                ,a_ctc92m08[arr_aux].tipo_pessoa
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,g_issk.usrtip
                                ,m_data
   whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        #rollback work
     else
        error "Pessoa VIP Incluida com Sucesso!"
        #commit work
    end if
  else
    whenever error continue
    open cctc92m08005 using  a_ctc92m08[arr_aux].cpf_num
                           , a_ctc92m08[arr_aux].ord_num
                           , a_ctc92m08[arr_aux].cpf_dig

    fetch cctc92m08005 into l_atv_flag   
    whenever error stop
    
    if l_atv_flag = 'N' then
       call cts08g01("A"
                    ,"S"
                    ,"ESTE CPF JA FOI CADASTRADO"
                    ,"MAS ESTA INATIVO! "
                    ,"DESEJA TORNA-LO ATIVO ?"
                    ," " )
       returning m_confirma
          
       if m_confirma = 'S' then
         whenever error continue
          execute pctc92m08009 using a_ctc92m08[arr_aux].cpf_num
                                    ,a_ctc92m08[arr_aux].ord_num
                                    ,a_ctc92m08[arr_aux].cpf_dig
         whenever error stop
                                    
           if sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") troca de dados da tabela datkitavippes"
              let m_errflg = "S"
              rollback work
           end if
                                               
         whenever error continue                           
         execute pctc92m08003 using  a_ctc92m08[arr_aux].cpf_num
                                    ,a_ctc92m08[arr_aux].ord_num
                                    ,a_ctc92m08[arr_aux].cpf_dig
                                    ,a_ctc92m08[arr_aux].seg_nom
                                    ,a_ctc92m08[arr_aux].tipo_pessoa
                                    ,g_issk.empcod
                                    ,g_issk.funmat
                                    ,g_issk.usrtip
                                    ,m_data
         whenever error stop

           if sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na insercao de dados"
              let m_errflg = "S"
              #rollback work
           else
              # --- verifica se existe apolice para esta Pessoa VIP e atualiza S
               if a_ctc92m08[arr_aux].tipo_pessoa = 'F' then
                  whenever error continue
                  open cctc92m08015 using a_ctc92m08[arr_aux].cpf_num
                                        , a_ctc92m08[arr_aux].cpf_dig
                  fetch cctc92m08015 into l_existe
                  whenever error stop
                  
                  if l_existe > 0 then
                     whenever error continue
                        execute pctc92m08013 using a_ctc92m08[arr_aux].cpf_num
                                                 , a_ctc92m08[arr_aux].cpf_dig
                     whenever error stop
                     
                     if sqlca.sqlcode <> 0 then
                        error 'Erro (',sqlca.sqlcode,') na atualizacao dos dados da apolice'
                     end if           
                  end if
               else
                  whenever error continue
                  open cctc92m08016 using a_ctc92m08[arr_aux].cpf_num
                                        , a_ctc92m08[arr_aux].ord_num
                                        , a_ctc92m08[arr_aux].cpf_dig
                  fetch cctc92m08016 into l_existe
                  whenever error stop
                  
                  if l_existe > 0 then
                     whenever error continue
                     execute pctc92m08014 using a_ctc92m08[arr_aux].cpf_num
                                              , a_ctc92m08[arr_aux].ord_num
                                              , a_ctc92m08[arr_aux].cpf_dig
                     whenever error stop
                     if sqlca.sqlcode <> 0 then
                        error 'Erro (',sqlca.sqlcode,') na atualizacao dos dados da apolice'
                     end if    
                  end if
               end if 
 
               error "Pessoa VIP Incluida com Sucesso!"
              
              #commit work
           end if   
       else
          return false
       end if   
    end if   
  end if

  return true
  
end function

#===============================================================
function ctc92m08_dados_alteracao(l_cpf_num,l_ord_num,l_cpf_dig)
#===============================================================
 define  l_cpf_num       like  datkitavippes.cgccpfnum
 define  l_ord_num       like  datkitavippes.cgccpford
 define  l_cpf_dig       like  datkitavippes.cgccpfdig

   initialize r_ctc92m08.* to null

   if m_prep <> 1 then
      call ctc92m08_prepare()
   end if
   whenever error continue
   open cctc92m08010 using l_cpf_num
                         , l_ord_num
                         , l_cpf_dig

   fetch cctc92m08010 into  r_ctc92m08.atlemp
                           ,r_ctc92m08.atlmat               
                           ,r_ctc92m08.atldat

   whenever error stop

   call ctc91m00_func(r_ctc92m08.atlemp, r_ctc92m08.atlmat               )
        returning r_ctc92m08.funnom

   display by name  r_ctc92m08.atldat
                   ,r_ctc92m08.funnom

end function

#===============================================================
function ctc92m08_pesquisa()
#===============================================================
  define l_interrupt      smallint

  define a_pop_ctc92m08 record
            tipo_pessoa   like  datkitavippes.pestipcod
          , cpf_num       like  datkitavippes.cgccpfnum
          , ord_num       like  datkitavippes.cgccpford
          , cpf_dig       like  datkitavippes.cgccpfdig
          , seg_nom       like  datkitavippes.pesnom
        end record

 initialize a_pop_ctc92m08.* to null

 open window w_ctc92m08a at 9,9 with form "ctc92m08a"
      attribute(border, form line first)

 message "  (F17)-Abandona"

 display "PESQUISA DE PESSOA VIP" to titulo attribute(reverse)

 input by name a_pop_ctc92m08.tipo_pessoa
             , a_pop_ctc92m08.cpf_num
             , a_pop_ctc92m08.ord_num
             , a_pop_ctc92m08.cpf_dig
             , a_pop_ctc92m08.seg_nom
             without defaults

     #----------------------------------
       before field tipo_pessoa
     #----------------------------------
       display a_pop_ctc92m08.tipo_pessoa to tipo_pessoa attribute(reverse)

     #----------------------------------
       after field tipo_pessoa
     #----------------------------------
       display a_pop_ctc92m08.tipo_pessoa to tipo_pessoa

       if a_pop_ctc92m08.tipo_pessoa is null then
          next field seg_nom
       end if

       if a_pop_ctc92m08.tipo_pessoa <> 'F' and
          a_pop_ctc92m08.tipo_pessoa <> 'J' then
          error " Informe o Tipo de Pessoa (F)isica ou (J)uridica"
          next field tipo_pessoa
       end if

     #----------------------------------
       before field cpf_num
     #----------------------------------
        display a_pop_ctc92m08.cpf_num to cpf_num attribute(reverse)

        if a_pop_ctc92m08.tipo_pessoa is null then
           display a_pop_ctc92m08.cpf_num to cpf_num
           next field seg_nom
        end if

     #----------------------------------
       after field cpf_num
     #----------------------------------
        display a_pop_ctc92m08.cpf_num to cpf_num

     #----------------------------------
       before field ord_num
     #----------------------------------
        display a_pop_ctc92m08.ord_num to ord_num attribute(reverse)

        if ( fgl_lastkey() = fgl_keyval("left") or
             fgl_lastkey() = fgl_keyval("up")    ) and
           ( a_pop_ctc92m08.tipo_pessoa is null  ) then
                display a_pop_ctc92m08.ord_num to ord_num
                next field tipo_pessoa
        else
           if a_pop_ctc92m08.tipo_pessoa = 'F' then
              let a_pop_ctc92m08.ord_num = 0
              display a_pop_ctc92m08.ord_num to ord_num
              next field cpf_dig
           end if
        end if

     #----------------------------------
       after field ord_num
     #----------------------------------
        display a_pop_ctc92m08.ord_num to ord_num

     #----------------------------------
       before field cpf_dig
     #----------------------------------
        display a_pop_ctc92m08.cpf_dig to cpf_dig attribute(reverse)

        if ( fgl_lastkey() = fgl_keyval("left") or
             fgl_lastkey() = fgl_keyval("up")    ) and
           ( a_pop_ctc92m08.tipo_pessoa is null      ) then
                display a_pop_ctc92m08.cpf_dig to cpf_dig
                next field tipo_pessoa
        end if

     #----------------------------------
       after field cpf_dig
     #----------------------------------
        display a_pop_ctc92m08.cpf_dig to cpf_dig

        if fgl_lastkey() = fgl_keyval("left") or
           fgl_lastkey() = fgl_keyval("up")   then
           next field cpf_num
        end if


     #----------------------------------
       before field seg_nom
     #----------------------------------
        display a_pop_ctc92m08.seg_nom to seg_nom attribute(reverse)

     #----------------------------------
       after field seg_nom
     #----------------------------------
        display a_pop_ctc92m08.seg_nom to seg_nom

        if fgl_lastkey() <> fgl_keyval("left") and
           fgl_lastkey() <> fgl_keyval("up")   then
           if a_pop_ctc92m08.seg_nom is null and
              a_pop_ctc92m08.cpf_num is null then
              error 'Sem dados para pesquisa!'
              next field tipo_pessoa
           end if
        end if

     #--------------------
      on key (interrupt, control-c)
     #--------------------
        let l_interrupt = 1
        exit input

 end input

 if l_interrupt = 1 then
    initialize a_pop_ctc92m08.* to null
 end if

 if a_pop_ctc92m08.cpf_num is null then
    let a_pop_ctc92m08.ord_num = null
    let a_pop_ctc92m08.cpf_dig = null
 end if

 close window w_ctc92m08a

 return a_pop_ctc92m08.tipo_pessoa
       ,a_pop_ctc92m08.cpf_num
       ,a_pop_ctc92m08.ord_num
       ,a_pop_ctc92m08.cpf_dig
       ,a_pop_ctc92m08.seg_nom

end function
