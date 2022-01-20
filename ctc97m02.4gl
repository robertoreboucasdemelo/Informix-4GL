#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc97m02                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15798                                              #
# Objetivo......: Tela de cadastro de Grupos de Assistencia                   #
#.............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               # 
#                                                                             # 
# Data       Autor Fabrica PSI       Alteracao                                # 
# --------   ------------- ------    -----------------------------------------# 
#                                                                             # 
#-----------------------------------------------------------------------------#
 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define ma_ctc97m02 array[500] of record
       grpcod    like datkresitagrp.grpcod
     , desnom    like datkresitagrp.desnom
     , ctonumflg like datkresitagrp.ctonumflg
     , launumflg like datkresitagrp.launumflg
 end record

 
  define r_ctc97m02 record
         atlemp     like datkresitagrp.atlempcod
        ,atlmat     like datkresitagrp.atlmatnum  
        ,atldat     like datkresitagrp.atldat
        ,funnom     like isskfunc.funnom
        end record

 define m_operacao  char(1)
 define arr_aux     smallint
 define scr_aux     smallint
 
 define m_grpcod    like datkresitagrp.grpcod     
 define m_desnom    like datkresitagrp.desnom   
 define m_ctonumflg like datkresitagrp.ctonumflg
 define m_launumflg like datkresitagrp.launumflg

 define  m_ctc97m02_prepare  char(1)

#===============================================================================
 function ctc97m02_prepare()
#===============================================================================

define l_sql char(10000)
 
 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc97m02_001 from l_sql
 declare c_ctc97m02_001 cursor for p_ctc97m02_001
 
 let l_sql =  ' select grpcod     '
             ,'      , desnom     '
             ,'      , ctonumflg  '
             ,'      , launumflg  '
             ,'   from datkresitagrp    '
 prepare p_ctc97m02_002 from l_sql
 declare c_ctc97m02_002 cursor for p_ctc97m02_002

 let l_sql =  ' select  atlempcod          '
             ,'        ,atlmatnum          '
             ,'        ,atldat             '
             ,'        ,atlusrtipcod          ' 
             ,'   from datkresitagrp    '
             ,'  where grpcod = ? '
 prepare p_ctc97m02_003 from l_sql
 declare c_ctc97m02_003 cursor for p_ctc97m02_003
 
  let l_sql =  ' insert into datkresitagrp'
             ,'  (grpcod,desnom,ctonumflg  '
             ,'  ,atlusrtipcod,atlempcod,atlmatnum,atldat,launumflg) '
             ,'  values '
             ,'  (?,?,?,?,?,?,?,?) '
 prepare p_ctc97m02_004 from l_sql
 
  let l_sql =  ' update datkresitagrp set                                    '
              ,' (desnom,ctonumflg,atlusrtipcod,atlempcod,atlmatnum,atldat,launumflg)  '
              ,' = (?,?,?,?,?,?,?) ' 
              ,' where grpcod = ? '
 prepare p_ctc97m02_005 from l_sql
 
 let l_sql =  '  select count(grpcod) '
             ,'    from datkresitagrp       '
             ,'   where grpcod = ?    '
 prepare p_ctc97m02_006 from l_sql
 declare c_ctc97m02_006 cursor for p_ctc97m02_006
 
 let l_sql =  '  delete datkresitagrp       '
             ,'   where grpcod = ?    '
 prepare p_ctc97m02_007 from l_sql
 
 let l_sql =  ' select count(*) '
             ,' from datrntzasipln  '
             ,'   where grpcod = ? '
 prepare p_ctc97m02_008 from l_sql               
 declare c_ctc97m02_008 cursor for p_ctc97m02_008
 
 
let m_ctc97m02_prepare = 'S'


end function

#===============================================================================
 function ctc97m02()
#===============================================================================
 define l_ret       smallint
 define m_cod_aux   like datkresitagrp.grpcod 
 define l_flag      smallint
 define l_index     smallint 
 define l_count     smallint
 define m_confirma  char(1)
 
 let arr_aux = 1
 let l_index = 1
 
 if m_ctc97m02_prepare is null or
    m_ctc97m02_prepare <> 'S' then
    call ctc97m02_prepare()
 end if
    
 options delete key F2
 
 open window w_ctc97m02 at 6,2 with form 'ctc97m02'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui'
 
 
 #---------------------[ seleciona dados ]------------------------#
  open c_ctc97m02_002 
  foreach c_ctc97m02_002 into ma_ctc97m02[l_index].grpcod   
                            , ma_ctc97m02[l_index].desnom   
                            , ma_ctc97m02[l_index].ctonumflg
                            , ma_ctc97m02[l_index].launumflg
     
     let l_index = l_index + 1
    
     if l_index > 500 then
         error " Limite excedido! Foram encontradas mais de 500 regras cadastradas!"
         exit foreach
      end if
  end foreach
  
  call set_count(l_index - 1)
  input array ma_ctc97m02 without defaults from s_ctc97m02.*
     #---------------------------------------------
      before row
     #---------------------------------------------
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
          
         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then
            if ma_ctc97m02[arr_aux].grpcod is null or
               ma_ctc97m02[arr_aux].grpcod = 0     then
               let m_operacao = 'i'             
            end if
         end if
    
     #---------------------------------------------
       before insert
     #---------------------------------------------
         let m_operacao = 'i'
         initialize  ma_ctc97m02[arr_aux] to null
         display ma_ctc97m02[arr_aux].grpcod  to
                  s_ctc97m02[scr_aux].grpcod
         display ma_ctc97m02[arr_aux].desnom  to
                  s_ctc97m02[scr_aux].desnom
     
     #---------------------------------------------
      before field grpcod
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].grpcod to s_ctc97m02[scr_aux].grpcod attribute(reverse)
         
         if ma_ctc97m02[arr_aux].grpcod is null and
            ma_ctc97m02[arr_aux].grpcod <> 0 then
            let m_operacao = 'i'
         else
            if m_operacao <> 'i'or
               m_operacao is null or
               m_operacao = ' ' then
               display ma_ctc97m02[arr_aux].* to s_ctc97m02[scr_aux].* attribute(reverse)
            end if
            
            let m_grpcod = ma_ctc97m02[arr_aux].grpcod
            
            if fgl_lastkey() <> fgl_keyval ("left")     or
               fgl_lastkey() <> fgl_keyval ("up")   then
               let m_cod_aux  = ma_ctc97m02[arr_aux].grpcod
            end if
         end if
         
         if m_operacao <> 'i' then
            call ctc97m02_dados_alteracao(ma_ctc97m02[arr_aux].grpcod)
         end if 
        
     #---------------------------------------------
      after field grpcod
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].grpcod to s_ctc97m02[scr_aux].grpcod 
         display ma_ctc97m02[arr_aux].* to s_ctc97m02[scr_aux].* 
         
         if fgl_lastkey() <> fgl_keyval ("left")   and
            fgl_lastkey() <> fgl_keyval ("up")   then 
            if ma_ctc97m02[arr_aux].grpcod is null then
               error 'Codigo nao pode ser nulo!'
               next field grpcod         
            end if
            
            let l_count = 0

           if m_operacao = 'i' then
              whenever error continue
              open c_ctc97m02_006 using ma_ctc97m02[arr_aux].grpcod
              fetch c_ctc97m02_006 into l_count
              whenever error stop
              
              if l_count > 0 then
                 error 'Este codigo ja esta cadastrado. Digite outro!'
                 next field grpcod
              end if
              
              let l_count = 0
           else
              display m_cod_aux to s_ctc97m02[scr_aux].grpcod 
              let ma_ctc97m02[arr_aux].grpcod = m_cod_aux
           end if
         else
            display m_cod_aux to s_ctc97m02[scr_aux].grpcod 
            let ma_ctc97m02[arr_aux].grpcod = m_cod_aux
            let m_operacao = ' '
         end if
         
         
     #---------------------------------------------
      before field desnom
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].* to s_ctc97m02[scr_aux].*
         display ma_ctc97m02[arr_aux].desnom to s_ctc97m02[scr_aux].desnom attribute(reverse)
         let m_desnom = ma_ctc97m02[arr_aux].desnom
     
     #---------------------------------------------
      after field desnom
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].desnom to s_ctc97m02[scr_aux].desnom

         if fgl_lastkey() <> fgl_keyval ("left") and
            fgl_lastkey() <> fgl_keyval ("up")   then 
            if ma_ctc97m02[arr_aux].desnom is null or
               ma_ctc97m02[arr_aux].desnom = ' '   then
               error 'Digite a Descricao do grupo'
               next field desnom
           end if
         end if
         
#---------------------------------------------
      before field ctonumflg
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].ctonumflg to s_ctc97m02[scr_aux].ctonumflg attribute(reverse)
         let m_ctonumflg = ma_ctc97m02[arr_aux].ctonumflg
     
     #---------------------------------------------
      after field ctonumflg
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].ctonumflg to s_ctc97m02[scr_aux].ctonumflg 
         
         if fgl_lastkey() <> fgl_keyval ("left") and
            fgl_lastkey() <> fgl_keyval ("up")   then             
            if ma_ctc97m02[arr_aux].launumflg <> "S" and 
               ma_ctc97m02[arr_aux].launumflg <> "N" then             
               error 'Digite S ou N '
               next field ctonumflg
           end if
         end if
         
     #---------------------------------------------
      before field launumflg
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].launumflg to s_ctc97m02[scr_aux].launumflg attribute(reverse)
         let m_launumflg = ma_ctc97m02[arr_aux].launumflg
     
     #---------------------------------------------
      after field launumflg
     #---------------------------------------------
         display ma_ctc97m02[arr_aux].launumflg to s_ctc97m02[scr_aux].launumflg 
         
         if fgl_lastkey() <> fgl_keyval ("left")   and
            fgl_lastkey() <> fgl_keyval ("up")   then 
            if ma_ctc97m02[arr_aux].launumflg is null then
               error 'teste'
               next field launumflg
            else
               if m_operacao = 'i' then
               
                 #---[insert]---#
                 execute p_ctc97m02_004 using ma_ctc97m02[arr_aux].grpcod
                                            , ma_ctc97m02[arr_aux].desnom
                                            , ma_ctc97m02[arr_aux].ctonumflg
                                            , g_issk.usrtip
                                            , g_issk.empcod
                                            , g_issk.funmat
                                            , 'today'
                                            , ma_ctc97m02[arr_aux].launumflg 
                  if sqlca.sqlcode = 0 then
                     error 'Dados Incluidos com Sucesso!'
                     let m_operacao = ' '
                  else
                     error 'ERRO(',sqlca.sqlcode,') na Insercao de Dados! AVISE A INFORMATICA!! (datkresitagrp)'
                  end if
                  
               else
                  if m_grpcod     <>  ma_ctc97m02[arr_aux].grpcod or
                     m_desnom     <>  ma_ctc97m02[arr_aux].desnom or
                     m_ctonumflg  <>  ma_ctc97m02[arr_aux].ctonumflg or 
                     m_launumflg  <>  ma_ctc97m02[arr_aux].launumflg then
                      #POPUP VERIFICA
                      call cts08g01("A","S"
                            ,"CONFIRMA ALTERACAO"
                            ,"DO REGISTRO DE GRUPO ?"
                            ," "
                            ," ")
                      returning m_confirma
                     
                     if m_confirma = 'S' then 
                        #---[update]---#
                        execute p_ctc97m02_005 using ma_ctc97m02[arr_aux].desnom
                                                   , ma_ctc97m02[arr_aux].ctonumflg
                                                   , g_issk.usrtip
                                                   , g_issk.empcod
                                                   , g_issk.funmat
                                                   , 'today'
                                                   , ma_ctc97m02[arr_aux].grpcod
                                                   , ma_ctc97m02[arr_aux].launumflg
                     else 
                        let ma_ctc97m02[arr_aux].grpcod   = m_grpcod
                        let ma_ctc97m02[arr_aux].desnom   = m_desnom
                        let ma_ctc97m02[arr_aux].ctonumflg = m_ctonumflg
                        let ma_ctc97m02[arr_aux].launumflg = m_launumflg
                        
                        display ma_ctc97m02[arr_aux].grpcod to s_ctc97m02[scr_aux].grpcod 
                        display ma_ctc97m02[arr_aux].desnom to s_ctc97m02[scr_aux].desnom
                        display ma_ctc97m02[arr_aux].ctonumflg to s_ctc97m02[scr_aux].ctonumflg 
                        display ma_ctc97m02[arr_aux].launumflg to s_ctc97m02[scr_aux].launumflg
                        
                        error 'Alteracao Cancelada!'
                     end if
                     
                     let m_operacao = ' '
                 end if    
               end if
            end if
         end if
         
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         let m_operacao = ' '
         exit input
         
         
      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc97m02[arr_aux].grpcod  is null   then
            continue input
         else
            if not ctc97m02_delete(ma_ctc97m02[arr_aux].grpcod) then
                let l_flag = 1
                exit input
            end if
         end if
      
      #---------------------------------------------
       after row
      #---------------------------------------------
         if m_operacao <> 'i' then
            display ma_ctc97m02[arr_aux].* to s_ctc97m02[scr_aux].*
         end if
         
  end input 
  
  close window w_ctc97m02
  
  if l_flag = 1 then
    call ctc97m02()
  end if
  
end function

#============================================
 function ctc97m02_dados_alteracao(l_cod)
#============================================
define l_cod char(4)
define l_usrtip  like datkresitagrp.atlusrtipcod

   initialize r_ctc97m02.* to null

   whenever error continue
   open c_ctc97m02_003 using l_cod

   fetch c_ctc97m02_003 into  r_ctc97m02.atlemp
                             ,r_ctc97m02.atlmat
                             ,r_ctc97m02.atldat
                             ,l_usrtip

    if sqlca.sqlcode <> 0  then
        whenever error stop
    end if

   call ctc97m02_func(r_ctc97m02.atlemp, r_ctc97m02.atlmat, l_usrtip)
        returning r_ctc97m02.funnom

   display by name  r_ctc97m02.atldat
                   ,r_ctc97m02.funnom

end function


#==============================================
 function ctc97m02_func(l_empcod, l_funmat, l_usrtip)
#==============================================

 define  l_empcod      like   datkresitagrp.atlempcod
 define  l_funmat      like   datkresitagrp.atlmatnum       
 define  l_funnom      char(100) 
 define  l_usrtip      like datkresitagrp.atlusrtipcod 

 whenever error continue
 open c_ctc97m02_001 using l_empcod,
                           l_funmat,
                           l_usrtip

 fetch c_ctc97m02_001 into l_funnom
 
   if sqlca.sqlcode = notfound then
    whenever error stop
    let l_funnom = '    '
 end if

 close c_ctc97m02_001
 return l_funnom

end function


#==============================================
 function ctc97m02_delete(l_cod)
#==============================================
define l_cod like datkresitagrp.grpcod
define l_confirma char(1)     
define l_count   integer
define l_mens    char(300)


let l_count = 0 
let l_mens  = null


  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO REGISTRO DE GRUPO ?"
               ," "
               ," ")
     returning l_confirma

     if l_confirma = "S" then
        let m_operacao = 'd'
        
        whenever error continue 
        open c_ctc97m02_008 using l_cod
        fetch c_ctc97m02_008 into l_count
        whenever error stop 
        
        if l_count > 0 then 
           let l_mens = 'Grupo na pode ser excluido, existem ',l_count ,' natureza(s) vinculadas'
           error l_mens
           call errorlog(l_mens)
        else        
           whenever error continue
           execute p_ctc97m02_007 using l_cod
           
           if sqlca.sqlcode <> 0 then
              error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datkresitagrp)'
              return false            
           end if
          whenever error stop
        end if   
        return true
     else
        error 'Exclusao Cancelada'
        return false 
     end if 

end function