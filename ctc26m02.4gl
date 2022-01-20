#============================================================================#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: CT24h                                                     #
# Modulo.........: ctc26m02.4gl                                              #
# Analista Resp..: Helder Oliveira                                           #
# Objetivo.......: Cadastro de SUB-Motivos.                                  #
#............................................................................#
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# Data        Autor Fabrica   PSI/OSF       Alteracao                        #
# ----------  -------------   ------------  -------------------------------- #
#============================================================================#

database porto

define ma_ctc26m02 array[500] of record
       rcuccsmtvsubcod like datkrcuccsmtvsub.rcuccsmtvsubcod
     , rcuccsmtvsubdes like datkrcuccsmtvsub.rcuccsmtvsubdes
     , mtvsubflg like datkrcuccsmtvsub.mtvsubflg
end record

define c24astcod    like datkassunto.c24astcod
define c24astdes    like datkassunto.c24astdes       
define rcuccsmtvcod like datkrcuccsmtv.rcuccsmtvcod
define rcuccsmtvdes like datkrcuccsmtv.rcuccsmtvdes

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_aux_codigo char(4)
define m_errflg    char(1)
define m_confirma  char(1)

#===============================================================================
function ctc26m02_prepare()
#===============================================================================
define l_sql char(32000) 

let l_sql = ' SELECT rcuccsmtvsubcod  '
          , '      , rcuccsmtvsubdes  '
          ,'       , mtvsubflg  '
          ,'   FROM  datkrcuccsmtvsub '
          ,'  WHERE  c24astcod    = ? '
          ,'    AND  rcuccsmtvcod = ? '
          ,'ORDER BY rcuccsmtvsubcod  '
 prepare p_ctc26m02_001 from l_sql
 declare c_ctc26m02_001 cursor for p_ctc26m02_001

let l_sql = ' SELECT count(*)            '
          ,'   FROM  datkrcuccsmtvsub    '
          ,'  WHERE  c24astcod    = ?    '
          ,'    AND  rcuccsmtvcod = ?    '
          ,'    AND  rcuccsmtvsubcod = ? '
 prepare p_ctc26m02_002 from l_sql
 declare c_ctc26m02_002 cursor for p_ctc26m02_002

 let l_sql = ' SELECT count(*)            '
          ,'   FROM  datkrcuccsmtvsub    '
          ,'  WHERE  c24astcod    = ?    '
          ,'    AND  rcuccsmtvcod = ?    '
          ,'    AND  rcuccsmtvsubdes = ? '
 prepare p_ctc26m02_003 from l_sql
 declare c_ctc26m02_003 cursor for p_ctc26m02_003

 let l_sql = ' INSERT INTO datkrcuccsmtvsub    '
          ,' ( c24astcod                       '
          ,'  ,rcuccsmtvcod                    '
          ,'  ,rcuccsmtvsubcod                 '
          ,'  ,rcuccsmtvsubdes                 '
          ,'  ,mtvsubflg                      )'
          ,' VALUES (?,?,?,?,?)                '
 prepare p_ctc26m02_004 from l_sql
 
 
 let l_sql = ' SELECT rcuccsmtvsubdes     '
          ,'   FROM  datkrcuccsmtvsub    '
          ,'  WHERE  c24astcod    = ?    '
          ,'    AND  rcuccsmtvcod = ?    '
          ,'    AND  rcuccsmtvsubcod = ? '
 prepare p_ctc26m02_005 from l_sql
 declare c_ctc26m02_005 cursor for p_ctc26m02_005
 
  let l_sql = ' UPDATE datkrcuccsmtvsub        '
          ,' set rcuccsmtvsubdes  = ?          '
          ,'    ,mtvsubflg  = ?          '
          ,'  WHERE  c24astcod    = ?          '
          ,'    AND  rcuccsmtvcod = ?          '
          ,'    AND  rcuccsmtvsubcod = ?       '
 prepare p_ctc26m02_006 from l_sql
 
   let l_sql = ' DELETE datkrcuccsmtvsub          '
              ,'  WHERE c24astcod    = ?          '
              ,'    AND rcuccsmtvcod = ?          '
              ,'    AND rcuccsmtvsubcod = ?       '
 prepare p_ctc26m02_007 from l_sql
 
  let l_sql = ' SELECT  mtvsubflg         '
             ,'   FROM  datkrcuccsmtvsub    '
             ,'  WHERE  c24astcod    = ?    '
             ,'    AND  rcuccsmtvcod = ?    '
             ,'    AND  rcuccsmtvsubcod = ? '
 prepare p_ctc26m02_008 from l_sql
 declare c_ctc26m02_008 cursor for p_ctc26m02_008
 
end function

#===============================================================================
function ctc26m02_sub_motivo(l_c24astcod, l_c24astdes, l_rcuccsmtvcod, l_rcuccsmtvdes)
#===============================================================================
 define l_c24astcod    like datkassunto.c24astcod
 define l_c24astdes    like datkassunto.c24astdes       
 define l_rcuccsmtvcod like datkrcuccsmtv.rcuccsmtvcod
 define l_rcuccsmtvdes like datkrcuccsmtv.rcuccsmtvdes
 define l_index      smallint
 define l_tamanho    smallint
 define l_flag       smallint
 define l_flg        smallint
 define i            smallint
 define l_count      smallint
 define l_prox_arr   smallint
 define l_err        smallint
 define l_flg_anterior char(1)
 
 initialize ma_ctc26m02 to null
 let l_err     = 0
 let int_flag  = false
 let l_tamanho = 1
 let l_flag    = 1
 let l_flg     = 1
 let i = 1
 let l_count   = 0
 let l_prox_arr = 0
 let m_errflg = 'N'
 
 let c24astcod    = l_c24astcod   
 let c24astdes    = l_c24astdes   
 let rcuccsmtvcod = l_rcuccsmtvcod
 let rcuccsmtvdes = l_rcuccsmtvdes

 call ctc26m02_prepare()
  
 open window w_ctc26m02 at 7,5 with form "ctc26m02"
 attribute(border, form line first)

 display by name c24astcod
               , c24astdes
               , rcuccsmtvcod
               , rcuccsmtvdes 
  
 while true
 
     let l_index = 1
     
     whenever error continue
       open c_ctc26m02_001 using c24astcod
                               , rcuccsmtvcod

       foreach c_ctc26m02_001 into ma_ctc26m02[l_index].rcuccsmtvsubcod
                                 , ma_ctc26m02[l_index].rcuccsmtvsubdes
                                 , ma_ctc26m02[l_index].mtvsubflg

              
               if l_index > 500 then
                  error 'Limite de 500 Sub-Assuntos atingido!'
               end if
                
               let l_index = l_index + 1
          
       end foreach
     whenever error stop
     
     if l_index = 1 then 
        error 'Motivo nao possui Sub-Motivos cadastrados. Inclua Novos!'
     end if
     
     call set_count(l_index)
     input array ma_ctc26m02 without defaults from s_ctc26m02.*
           
           #-----------------------------------------------------------
             before row
           #-----------------------------------------------------------
                 let arr_aux = arr_curr()
                 let scr_aux = scr_line()
     
                 if arr_aux <= arr_count()  then
                    let m_operacao = "p"
                 end if
             
           #-----------------------------------------------------------
              before insert
           #-----------------------------------------------------------
                  let m_operacao = 'i'
                  initialize ma_ctc26m02[arr_aux] to null
                  
           ##----------------------------------------------------------
             before field rcuccsmtvsubcod    
           #-----------------------------------------------------------
                 if m_operacao <> 'i' then
                     #call ctc91m09_dados_alteracao( ma_ctc26m02[arr_aux].rcuccsmtvsubcod)
                 end if
                 
                 if ma_ctc26m02[arr_aux].rcuccsmtvsubcod is null then
                    let m_operacao = 'i'
                 else
                    display ma_ctc26m02[arr_aux].* to s_ctc26m02[scr_aux].* attribute(reverse)
                    let m_aux_codigo = ma_ctc26m02[arr_aux].rcuccsmtvsubcod
                 end if
                 
                 if l_flg = 1 then
                    let l_flg = 0
                    next field rcuccsmtvsubcod
                 end if               
               
           #-----------------------------------------------------------
             after field  rcuccsmtvsubcod
           #-----------------------------------------------------------
                display ma_ctc26m02[arr_aux].* to s_ctc26m02[scr_aux].*

                if fgl_lastkey() = fgl_keyval("up")     or
                   fgl_lastkey() = fgl_keyval("left")   then
                   let ma_ctc26m02[arr_aux].rcuccsmtvsubcod = ''
                   display ma_ctc26m02[arr_aux].rcuccsmtvsubcod to s_ctc26m02[scr_aux].rcuccsmtvsubcod

                   let l_flg = 1

                   let m_operacao = "p"
                else
                
                   if ma_ctc26m02[arr_aux].rcuccsmtvsubcod is null then
                      if  m_operacao = 'i' then
                        error " Informe o codigo do SUB-Motivo"
                        next field rcuccsmtvsubcod
                      end if
                   else
                      if m_operacao = 'i'then

                         #whenever error continue
                           open c_ctc26m02_002 using c24astcod
                                                   , rcuccsmtvcod 
                                                   , ma_ctc26m02[arr_aux].rcuccsmtvsubcod
                           fetch c_ctc26m02_002 into l_count
                        # whenever error stop

                         if l_count > 0 then
                            initialize ma_ctc26m02[arr_aux] to null
                            error " Codigo de SUB-Motivo ja cadastrado!"
                            close c_ctc26m02_002
                            next field rcuccsmtvsubcod
                         end if
                         
                         if ma_ctc26m02[arr_aux].rcuccsmtvsubdes is null then
                            next field  rcuccsmtvsubdes
                         end if
                      end if
                   end if
                end if
              
                if ma_ctc26m02[arr_aux].rcuccsmtvsubdes is not null then
                   let  ma_ctc26m02[arr_aux].rcuccsmtvsubcod = m_aux_codigo
                   display  ma_ctc26m02[arr_aux].rcuccsmtvsubcod to s_ctc26m02[scr_aux].rcuccsmtvsubcod
                end if

           ##----------------------------------------------------------
             before field rcuccsmtvsubdes     
           #-----------------------------------------------------------
               display ma_ctc26m02[arr_aux].rcuccsmtvsubdes to
                         s_ctc26m02[scr_aux].rcuccsmtvsubdes attribute(reverse)

                 if ma_ctc26m02[arr_aux].rcuccsmtvsubcod is null then
                    let     ma_ctc26m02[arr_aux].rcuccsmtvsubdes = null
                    display ma_ctc26m02[arr_aux].rcuccsmtvsubdes to
                            s_ctc26m02[scr_aux].rcuccsmtvsubdes
                    next field rcuccsmtvsubcod
                 end if
           #-----------------------------------------------------------
             after field  rcuccsmtvsubdes
           #-----------------------------------------------------------
               display ma_ctc26m02[arr_aux].rcuccsmtvsubdes to
                       s_ctc26m02[scr_aux].rcuccsmtvsubdes
               
                # Retirar espaços em branco a esqeurada e a direita
                  let ma_ctc26m02[arr_aux].rcuccsmtvsubdes = ctc26m02_trim(ma_ctc26m02[arr_aux].rcuccsmtvsubdes)
                  display ma_ctc26m02[arr_aux].rcuccsmtvsubdes to
                          s_ctc26m02[scr_aux].rcuccsmtvsubdes
                # -
               
                  if l_flg = 1 then
                     let l_prox_arr = arr_aux + 1
                     if ma_ctc26m02[l_prox_arr].rcuccsmtvsubcod is not null and
                        ma_ctc26m02[l_prox_arr].rcuccsmtvsubdes is null then
                        let ma_ctc26m02[l_prox_arr].rcuccsmtvsubcod = null
                     end if
                  end if
               
                  let l_count = 0
               
                  if fgl_lastkey() = fgl_keyval("up")     or
                     fgl_lastkey() = fgl_keyval("left")   then
               
                     let l_flg = 1
                     if m_operacao = "i" then
                        initialize ma_ctc26m02[arr_aux] to null
                        display ma_ctc26m02[arr_aux].* to s_ctc26m02[scr_aux].*
                        next field rcuccsmtvsubcod
                     end if
               
                     let m_operacao = "p"
                     
                  end if
                 
                  if ma_ctc26m02[arr_aux].rcuccsmtvsubdes is null then
                    if m_operacao <> " " then
                       error " Informe a descricao do Motivo"
                       next field rcuccsmtvsubdes
                    end if
                  else
                     if m_operacao = 'i' then
                        whenever error continue
                        open c_ctc26m02_003 using c24astcod
                                                , rcuccsmtvcod 
                                                , ma_ctc26m02[arr_aux].rcuccsmtvsubdes
                        fetch c_ctc26m02_003 into l_count
                        whenever error stop
               
                        if l_count > 0 then
                          error "Este SUB-Motivo ja foi cadastrada com outro codigo"
                          next field rcuccsmtvsubdes
                       end if
                     end if
                  end if
                  message "           (F1) - Inclui      (F2) - Exclui     (F17) - Abandona  "
           
           
           ##----------------------------------------------------------
            before field mtvsubflg     
           #-----------------------------------------------------------
              if ma_ctc26m02[arr_aux].mtvsubflg is null then
                 let ma_ctc26m02[arr_aux].mtvsubflg = 'A'
              end if  
              
              let l_flg_anterior = ma_ctc26m02[arr_aux].mtvsubflg
     
           #-----------------------------------------------------------
             after field  mtvsubflg
           #-----------------------------------------------------------
               if fgl_lastkey() = fgl_keyval("up")     or
                  fgl_lastkey() = fgl_keyval("left")   then
                  if m_operacao = 'i' then
                     next field rcuccsmtvsubdes
                  end if
                 
                  let m_operacao = "p"
                 
               else
                 if ma_ctc26m02[arr_aux].mtvsubflg is null or
                  ( ma_ctc26m02[arr_aux].mtvsubflg <> 'A' and
                    ma_ctc26m02[arr_aux].mtvsubflg <> 'C'  )  then
                    error 'Defina o Status do SUB-Motivo! (A)tivo / (C)ancelado'
                    next field mtvsubflg
#                 else
#                    if ma_ctc26m02[arr_aux].mtvsubflg <> l_flg_anterior then
#                       let m_operacao = 'p'                    
#                    end if
                 end if
               end if
     
     
           #-----------------------------------------------------------
             after row
           #-----------------------------------------------------------
               whenever error continue

               case
                   when m_operacao = 'i'
                      call ctc26m02_insert_dados(arr_aux)

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc26m02_update_pergunta_altera(arr_aux, scr_aux) returning l_err
                      if l_err = 1 then
                         next field rcuccsmtvsubdes
                      end if
               end case

               if m_errflg = "S"  then
                  let int_flag = true
                  exit input
               end if

               whenever error stop

               let m_operacao = " "
           
           #----------------------------------------------------------
             before delete
           #-----------------------------------------------------------
               let m_operacao = "d"
               
               initialize m_confirma to null
               call cts08g01("A"
                            ,"S"
                            ,"CONFIRMA A REMOCAO"
                            ,"DO SUB-MOTIVO ?"
                            ," "
                            ," " )
                   returning m_confirma

               if m_confirma = "S"  then
                  let m_errflg = "N"

                  begin work

                  whenever error continue
                  execute p_ctc26m02_007 using c24astcod
                                             , rcuccsmtvcod
                                             , ma_ctc26m02[arr_aux].rcuccsmtvsubcod
                  if sqlca.sqlcode <> 0  then
                         error " Erro (", sqlca.sqlcode, ") na remocao do sub-motivo!"

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
               
               let m_operacao = " "
               initialize ma_ctc26m02[arr_aux].*   to null
               display ma_ctc26m02[arr_aux].* to s_ctc26m02[scr_aux].*
           #----------------------------------------------------------- 
             on key (accept)
           #----------------------------------------------------------- 
               continue input

           #-----------------------------------------------------------        
             on key (interrupt, control-c)
           #-----------------------------------------------------------
                 exit input
     
     end input
 
     if int_flag  then
        let int_flag = false
        exit while
     end if
 
 end while
 
 close window w_ctc26m02


end function

#===============================================================================
function ctc26m02_insert_dados(arr_aux)
#===============================================================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint

begin work
  whenever error continue
  open c_ctc26m02_003 using c24astcod
                          , rcuccsmtvcod 
                          , ma_ctc26m02[arr_aux].rcuccsmtvsubdes
  fetch c_ctc26m02_003 into l_count
  whenever error stop

  if l_count = 0 then
     execute p_ctc26m02_004 using c24astcod
                                , rcuccsmtvcod
                                , ma_ctc26m02[arr_aux].rcuccsmtvsubcod
                                , ma_ctc26m02[arr_aux].rcuccsmtvsubdes
                                , ma_ctc26m02[arr_aux].mtvsubflg
                                #, g_issk.usrtip
                                #, g_issk.empcod
                                #, g_issk.funmat
                                #, m_data
     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "SUB-Motivo Incluido com Sucesso!"
        commit work
    end if
  end if

end function

#===============================================================================
function ctc26m02_update_pergunta_altera(arr_aux, scr_aux)
#===============================================================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_descricao   char(50)
  define l_count       smallint
  define l_err         smallint
  define l_mtvsubflg   char(1)

     whenever error continue
     open c_ctc26m02_005 using c24astcod
                             , rcuccsmtvcod 
                             , ma_ctc26m02[arr_aux].rcuccsmtvsubcod
     fetch c_ctc26m02_005 into l_descricao
     whenever error stop
     
     if l_descricao <> ma_ctc26m02[arr_aux].rcuccsmtvsubdes then

       whenever error continue
        open c_ctc26m02_003 using c24astcod
                                , rcuccsmtvcod 
                                , ma_ctc26m02[arr_aux].rcuccsmtvsubdes
        fetch c_ctc26m02_003 into l_count
       whenever error stop

       if l_count > 0 then
          error "Este SUB-Motivo ja foi cadastrado com outro codigo"
          let l_err = 1
          return l_err
        end if
        
     end if

     whenever error continue
     open c_ctc26m02_008 using c24astcod
                             , rcuccsmtvcod 
                             , ma_ctc26m02[arr_aux].rcuccsmtvsubcod
     fetch c_ctc26m02_008 into l_mtvsubflg
     whenever error stop



     if l_descricao <> ma_ctc26m02[arr_aux].rcuccsmtvsubdes or
        l_mtvsubflg <> ma_ctc26m02[arr_aux].mtvsubflg then

        let l_err = 0
        call cts08g01("A","S"
                     ,"CONFIRMA ALTERACAO"
                     ,"DO SUB-MOTIVO ?"
                     ," "
                     ," ")
          returning m_confirma
        
        if m_confirma = "S" then
           let m_operacao = 'a'
        else
           let ma_ctc26m02[arr_aux].rcuccsmtvsubdes = l_descricao clipped
           display ma_ctc26m02[arr_aux].rcuccsmtvsubdes to s_ctc26m02[scr_aux].rcuccsmtvsubdes
           let ma_ctc26m02[arr_aux].mtvsubflg = l_mtvsubflg clipped
           display ma_ctc26m02[arr_aux].mtvsubflg to s_ctc26m02[scr_aux].mtvsubflg
        end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute p_ctc26m02_006 using ma_ctc26m02[arr_aux].rcuccsmtvsubdes
                                     , ma_ctc26m02[arr_aux].mtvsubflg 
                                     , c24astcod
                                     , rcuccsmtvcod
                                     , ma_ctc26m02[arr_aux].rcuccsmtvsubcod
                                     #, g_issk.usrtip
                                     #, g_issk.empcod
                                     #, g_issk.funmat
                                     #, m_data

          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "SUB-Motivo Alterado com Sucesso!"
             commit work
          end if
          let m_operacao = ' '
    end if

return l_err

end function

#===============================================================================
function ctc26m02_trim(l_string)
#===============================================================================
 define l_string     char(200)
 define l_tamanho    smallint
 define i            smallint
 define l_aux        char(200)

 let l_string = l_string clipped
 let l_tamanho = length(l_string)

 for i = 1 to l_tamanho
     if l_string[i] <> " " then
        let l_aux = l_string[i,l_tamanho] clipped
        exit for
     else
       continue for
     end if
 end for
 return l_aux

end function