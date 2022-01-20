###########################################################################
# Nome do Modulo: ctc92m04                               Helder Oliveira  #
#                                                                         #
# Cadastro Natureza x plano                                      Mar/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define ma_ctc92m04 array[500] of record
       nat_cod    like datksocntz.socntzcod
     , nat_desc   like datksocntz.socntzdes
     , limite     smallint 
 end record
 
 define param       record
        cod         like datkitaasipln.itaasiplncod   # codigo do Plano
      , descricao   like datkitaasipln.itaasiplndes   # descricao do Plano
 end record
 
   define r_ctc92m04 record
         atlemp     like datkitaasipln.atlemp
        ,atlmat     like datkitaasipln.atlmat
        ,atldat     like datkitaasipln.atldat
        ,funnom     like isskfunc.funnom
        end record

 define m_operacao  char(1)
 define arr_aux     smallint
 define scr_aux     smallint

 define  m_sql  char(1)

#===============================================================================
 function ctc92m04_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.socntzcod                                             '
          ,  '      , a.socntzdes                                             '
          ,  '      , b.utzlmtqtd                                             '
          ,  '   from datksocntz a                                            '
          ,  '      , datritaasiplnnat b                                      '
          ,  '      , datkitaasipln c                                         '
          ,  '  where a.socntzcod    = b.socntzcod                            '
          ,  '    and c.itaasiplncod = b.itaasiplncod                         '
          ,  '    and b.itaasiplncod = ?                                      '
          ,  '  order by a.socntzcod                                          '
 prepare p_ctc92m04_001 from l_sql
 declare c_ctc92m04_001 cursor for p_ctc92m04_001
 
 let l_sql = ' update  datritaasiplnnat  '
           ,  '     set utzlmtqtd =  ?      '
           ,  '   where socntzcod =  ?      '
           ,  '     and itaasiplncod =?     '
 prepare p_ctc92m04_002 from l_sql
  
 let l_sql = '   select atlemp              '
            ,'         ,atlmat              '
            ,'         ,atldat              '
            ,'         ,atlusrtip           '
            ,'     from datritaasiplnnat '     # porto@u07:datkitaempasi      
            ,'    where socntzcod  =  ?     '
            ,'      and itaasiplncod = ?    '
 prepare p_ctc92m04_003 from l_sql
 declare c_ctc92m04_003 cursor for p_ctc92m04_003
 
  let l_sql = '   select count(socntzcod)        '    
            , '     from datritaasiplnnat     '
            , '    where socntzcod = ?           '
            , '      and itaasiplncod = ?        '
 prepare p_ctc92m04_004 from l_sql
 declare c_ctc92m04_004 cursor for p_ctc92m04_004
    
 let l_sql = '   select socntzdes          '    
            , '     from datksocntz        '
            , '    where socntzcod = ?     '
 prepare p_ctc92m04_005 from l_sql
 declare c_ctc92m04_005 cursor for p_ctc92m04_005
  
 let l_sql =  ' insert into datritaasiplnnat      '
           ,  '   (itaasiplncod                   '
           ,  '   ,socntzcod                      '
           ,  '   ,utzlmtqtd                      '
           ,  '   ,atlusrtip                      '
           ,  '   ,ctisrvflg                      '
           ,  '   ,ctinaosrvflg                   '
           ,  '   ,atlemp                         '
           ,  '   ,atlmat                         '
           ,  '   ,atldat)                        '
           ,  ' values(?,?,?,?,"N","N",?,?,?)     '
 prepare p_ctc92m04_006 from l_sql
 
  let l_sql = '   select count(socntzcod)   '
            , '     from datksocntz         '
            , '    where socntzcod = ?      '
 prepare p_ctc92m04_007 from l_sql
 declare c_ctc92m04_007 cursor for p_ctc92m04_007
 
 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc92m04_008 from l_sql
 declare c_ctc92m04_008 cursor for p_ctc92m04_008
 
 let l_sql = '  delete datritaasiplnnat    '
          ,  '   where socntzcod = ?          '
          ,  '     and itaasiplncod = ?       '
  prepare p_ctc92m04_009 from l_sql
 
let m_sql = 'S'

#let g_issk.empcod  = 1
#let g_issk.funmat  = '013020'                           
#let g_issk.usrtip  = 'F'

end function

#===============================================================================
 function ctc92m04(l_cod, l_descricao)
#===============================================================================
 define l_cod       like datkitaasipln.itaasiplncod   # codigo do Plano
 define l_descricao like datkitaasipln.itaasiplndes   # Descricao do Plano
 define l_ret       smallint
 define m_cod_aux   like datksocntz.socntzcod 
 define l_flag      smallint
 
 let param.cod = l_cod
 let param.descricao = l_descricao
 
 let arr_aux = 1
 
 if m_sql is null or
    m_sql <> 'S' then
    call ctc92m04_prepare()
 end if
    
 options delete key F2
 
 open window w_ctc92m04 at 6,2 with form 'ctc92m04'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui'
   
  display by name param.cod
                , param.descricao
  
 #---------------[ seleciona dados ]----------------#
  open c_ctc92m04_001  using param.cod
  foreach c_ctc92m04_001 into ma_ctc92m04[arr_aux].nat_cod
                            , ma_ctc92m04[arr_aux].nat_desc
                            , ma_ctc92m04[arr_aux].limite

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite excedido! Foram encontrados mais de 500 empresas!"
          exit foreach
       end if
       
  end foreach 
  #--------------------------------------------------#
  
  if arr_aux = 1  then
       error "Nao foi encontrado nenhum registro, inclua novos!"
    end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc92m04 without defaults from s_ctc92m04.*
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             if ma_ctc92m04[arr_aux].nat_cod is null or
                ma_ctc92m04[arr_aux].nat_cod = 0     then
                let m_operacao = 'i'             
             end if
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         initialize  ma_ctc92m04[arr_aux] to null
         display ma_ctc92m04[arr_aux].nat_cod        to
                  s_ctc92m04[scr_aux].nat_cod
         display ma_ctc92m04[arr_aux].nat_desc  to
                  s_ctc92m04[scr_aux].nat_desc

      #---------------------------------------------
       before field nat_cod
      #---------------------------------------------
         if ma_ctc92m04[arr_aux].nat_cod is null then
            display ma_ctc92m04[arr_aux].nat_cod to s_ctc92m04[scr_aux].nat_cod attribute(reverse)
            let m_operacao = 'i'
         else
           let m_cod_aux  = ma_ctc92m04[arr_aux].nat_cod
           display ma_ctc92m04[arr_aux].* to s_ctc92m04[scr_aux].* attribute(reverse)
         end if
         
         if m_operacao <> 'i' then
            call ctc92m04_dados_alteracao(ma_ctc92m04[arr_aux].nat_cod)
         end if
        
      #---------------------------------------------
       after field nat_cod
      #---------------------------------------------
         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then
            
            if m_operacao = 'i' then
               if ma_ctc92m04[arr_aux].nat_cod is null then
                   if fgl_lastkey() = fgl_keyval ("down")   or
                      fgl_lastkey() = fgl_keyval ("return")     then
                      call cto00m10_popup(16) 
                         returning ma_ctc92m04[arr_aux].nat_cod
                                 , ma_ctc92m04[arr_aux].nat_desc
                                 
                         display ma_ctc92m04[arr_aux].nat_cod to s_ctc92m04[scr_aux].nat_cod
                         display ma_ctc92m04[arr_aux].nat_desc to s_ctc92m04[scr_aux].nat_desc 
                                 
                        #--------[ verifica se natureza existe ]---------#
                        let l_ret = 0
                        
                        open c_ctc92m04_007 using ma_ctc92m04[arr_aux].nat_cod
                        fetch c_ctc92m04_007 into l_ret
                        
                        if l_ret < 1 then
                           error 'Codigo de Natureza nao existe!'
                           next field nat_cod
                        end if
                        
                        #---------[ verifica codigo duplicado ]----------#
                        let l_ret = 0
                        
                        open c_ctc92m04_004 using ma_ctc92m04[arr_aux].nat_cod
                                                , param.cod
                        fetch c_ctc92m04_004 into l_ret
                        
                        if l_ret > 0  then
                           error 'Esse Codigo ja esta cadastrado!'
                           next field nat_cod
                        end if
                   else
                      let m_operacao = ' '
                   end if                     
               else
                  
                  #--------[ verifica se natureza existe ]---------#
                  let l_ret = 0
                  
                  open c_ctc92m04_007 using ma_ctc92m04[arr_aux].nat_cod
                  fetch c_ctc92m04_007 into l_ret
                  
                  if l_ret < 1 then
                     error 'Codigo de Natureza nao existe!'
                     next field nat_cod
                  end if
               
                  #---------[ verifica codigo duplicado ]----------#
                  let l_ret = 0
 
                  open c_ctc92m04_004 using ma_ctc92m04[arr_aux].nat_cod
                                          , param.cod
                  fetch c_ctc92m04_004 into l_ret
                  
                  if l_ret > 0  then
                     error 'Esse Codigo ja esta cadastrado!'
                     next field nat_cod
                  end if
                  
                   #--------[ seleciona descricao ]--------#
                   open c_ctc92m04_005 using ma_ctc92m04[arr_aux].nat_cod
                   fetch c_ctc92m04_005 into ma_ctc92m04[arr_aux].nat_desc
                  
                   display ma_ctc92m04[arr_aux].nat_cod to s_ctc92m04[scr_aux].nat_cod
                   display ma_ctc92m04[arr_aux].nat_desc to s_ctc92m04[scr_aux].nat_desc
                  #---------------------------------------#
               end if
                           
            else
              let ma_ctc92m04[arr_aux].nat_cod = m_cod_aux
              display ma_ctc92m04[arr_aux].* to s_ctc92m04[scr_aux].*
            end if
            
         else
           if m_operacao = 'i' then
              let ma_ctc92m04[arr_aux].nat_cod = ''
              display ma_ctc92m04[arr_aux].* to s_ctc92m04[scr_aux].*
              let m_operacao = ' '
           else
              let ma_ctc92m04[arr_aux].nat_cod = m_cod_aux
              display ma_ctc92m04[arr_aux].* to s_ctc92m04[scr_aux].*
           end if 
           
         end if
         
         
      #---------------------------------------------
       before field nat_desc
      #---------------------------------------------
         next field limite
      
      #---------------------------------------------
       before field limite
      #---------------------------------------------
         display ma_ctc92m04[arr_aux].limite to s_ctc92m04[scr_aux].limite attribute(reverse)
         
         if ma_ctc92m04[arr_aux].nat_cod is null then
            display ' ' to s_ctc92m04[scr_aux].limite
            next field nat_cod
         end if
         
     
      #---------------------------------------------
       after field limite
      #---------------------------------------------
         if ma_ctc92m04[arr_aux].limite is null then
            error 'Limite nao pode ser nulo!'
            next field limite
         end if

         if m_operacao <> 'i' then 
           # -------- [ update de limite ] -------- #
            execute p_ctc92m04_002 using ma_ctc92m04[arr_aux].limite
                                       , ma_ctc92m04[arr_aux].nat_cod
                                       , param.cod
            let m_operacao = ' '                           
         else
           # -------- [ grava dados novos] -------- #
           execute p_ctc92m04_006 using param.cod
                                      , ma_ctc92m04[arr_aux].nat_cod
                                      , ma_ctc92m04[arr_aux].limite
                                      , g_issk.usrtip
                                      , g_issk.empcod
                                      , g_issk.funmat
                                      , 'today'
                                      
            if sqlca.sqlcode = 0 then
               error 'Dados Incluidos com Sucesso!'
               let m_operacao = ' '
            else
               error 'ERRO(',sqlca.sqlcode,') na Insercao de Dados! AVISE A INFORMATICA!! (datritaasiplnnat)'
            end if
           
         end if

         display ma_ctc92m04[arr_aux].limite to s_ctc92m04[scr_aux].limite       
      
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
      
      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc92m04[arr_aux].nat_cod  is null   then
            continue input
         else
            if not ctc92m04_delete(ma_ctc92m04[arr_aux].nat_cod) then
                let l_flag = 1
                exit input
            end if
         end if
         
  end input
  
 close window w_ctc92m04
 
 if l_flag = 1 then
    call ctc92m04(param.*)
 end if
 
 
end function

#============================================
 function ctc92m04_dados_alteracao(l_cod)
#============================================
define l_cod char(4)
define l_usrtip  like datritaasiplnnat.atlusrtip

   initialize r_ctc92m04.* to null

   whenever error continue
   open c_ctc92m04_003 using l_cod
                           , param.cod
   fetch c_ctc92m04_003 into  r_ctc92m04.atlemp
                             ,r_ctc92m04.atlmat
                             ,r_ctc92m04.atldat
                             ,l_usrtip

    if sqlca.sqlcode <> 0  then
        whenever error stop
    end if

   call ctc92m04_func(r_ctc92m04.atlemp, r_ctc92m04.atlmat, l_usrtip)
        returning r_ctc92m04.funnom

   display by name  r_ctc92m04.atldat
                   ,r_ctc92m04.funnom

end function


#==============================================
 function ctc92m04_func(l_empcod, l_funmat, l_usrtip)
#==============================================

 define  l_empcod      like   datkitaasipln.atlemp
 define  l_funmat      like   datkitaasipln.atlmat       
 define  l_funnom      char(100) 
 define  l_usrtip      like datritaasiplnnat.atlusrtip 

 whenever error continue
 open c_ctc92m04_008 using l_empcod,
                           l_funmat,
                           l_usrtip

 fetch c_ctc92m04_008 into l_funnom
 
   if sqlca.sqlcode = notfound then
    whenever error stop
    let l_funnom = '    '
 end if

 close c_ctc92m04_008
 return l_funnom

end function


#==============================================
 function ctc92m04_delete(l_cod)
#==============================================
define l_cod like datksocntz.socntzcod
define l_confirma char(1)


  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO REGISTRO DE LIMITE "
               ,"DE NATUREZA ?"
               ," ")
     returning l_confirma

     if l_confirma = "S" then
        let m_operacao = 'd'
        
        whenever error continue
        execute p_ctc92m04_009 using l_cod
                                   , param.cod
        
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datritaasiplnnat)'
           return false
           whenever error stop
        end if
        
        return true
     else
        return false 
     end if 

end function