#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc69m23                                                   # 
# Objetivo.......: Cadastro de Especialidade                                  # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 15/01/2015                                                 # 
#.............................................................................# 

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m23 array[500] of record
      srvespnum   like datksrvesp.srvespnum , 
      srvespnom   like datksrvesp.srvespnom    
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint


define  m_prepare  smallint

#===============================================================================
 function ctc69m23_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select srvespnum       '
          ,  '      , srvespnom       '          
          ,  '   from datksrvesp      '
          ,  '  order by 1            '
 prepare p_ctc69m23_001 from l_sql
 declare c_ctc69m23_001 cursor for p_ctc69m23_001
 	
 let l_sql = ' select count(*)      '
          ,  '   from datksrvesp    '
          ,  '  where srvespnum = ? '        
 prepare p_ctc69m23_002 from l_sql
 declare c_ctc69m23_002 cursor for p_ctc69m23_002
 
 let l_sql = ' update datksrvesp        '
           ,  '     set srvespnom  = ?  '                      
           ,  '   where srvespnum  = ?  '       
 prepare p_ctc69m23_003 from l_sql
  
 let l_sql =  ' insert into datksrvesp   '
           ,  '   (srvespnum             '          
           ,  '   ,srvespnom             '
           ,  '   ,regatldat)            '           
           ,  ' values(?,?,?)            '
 prepare p_ctc69m23_004 from l_sql 	
  
 
 let l_sql = '  delete datksrvesp    '                               	
         ,  '   where srvespnum = ?  '                             	                            	
 prepare p_ctc69m23_005 from l_sql 
 
 
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc69m23()
#===============================================================================
 
 
define lr_retorno record
    flag                smallint                  ,
    cont                integer                   ,
    srvespnum           like datksrvesp.srvespnum , 
    srvespnom           like datksrvesp.srvespnom ,
    msg                 char(60)                  ,
    data                date
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc69m23[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1 
 
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m23_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc69m23 at 6,2 with form 'ctc69m23'
 attribute(form line 1)
  
 let lr_retorno.msg = '                (F17)Abandona, (F1)Inclui, (F2)Exclui'
 
 display by name lr_retorno.msg    
  
  open c_ctc69m23_001 
  foreach c_ctc69m23_001 into ma_ctc69m23[arr_aux].srvespnum 
                            , ma_ctc69m23[arr_aux].srvespnom                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Especialidade Excedido! Foram Encontradas Mais de 500 Especialidades!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m23 without defaults from s_ctc69m23.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m23[arr_aux].srvespnum  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field srvespnum 
      #---------------------------------------------
                  
        if ma_ctc69m23[arr_aux].srvespnum  is null then                                                   
           display ma_ctc69m23[arr_aux].srvespnum  to s_ctc69m23[scr_aux].srvespnum  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let lr_retorno.srvespnum = ma_ctc69m23[arr_aux].srvespnum
          display ma_ctc69m23[arr_aux].* to s_ctc69m23[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field srvespnum                    
      #---------------------------------------------
          
         if fgl_lastkey() = fgl_keyval ("down")     or    
            fgl_lastkey() = fgl_keyval ("return")   then  
          
             if m_operacao = 'i' then
             	
             	if ma_ctc69m23[arr_aux].srvespnum  is null then
             		 error "Por Favor Informe o Codigo da Especialidade "
             		 next field srvespnum          		
               end if 
               
               
               open c_ctc69m23_002 using ma_ctc69m23[arr_aux].srvespnum         
               whenever error continue                                                
               fetch c_ctc69m23_002 into lr_retorno.cont           
               whenever error stop                                                    
                                                                                      
               if lr_retorno.cont >  0   then                                          
                  error " Codigo ja Cadastrado!" 
                  next field srvespnum  
               end if 
                             
             else          
             	let ma_ctc69m23[arr_aux].srvespnum = lr_retorno.srvespnum
             	display ma_ctc69m23[arr_aux].* to s_ctc69m23[scr_aux].*       	                                                    
             end if
         else                                                                          
          	 if m_operacao = 'i' then                                                   
          	    let ma_ctc69m23[arr_aux].srvespnum = ''                                    
          	    display ma_ctc69m23[arr_aux].* to s_ctc69m23[scr_aux].*                 
          	    let m_operacao = ' '                                                    
          	 else                                                                       
          	    let ma_ctc69m23[arr_aux].srvespnum = lr_retorno.srvespnum                    
          	    display ma_ctc69m23[arr_aux].* to s_ctc69m23[scr_aux].*                 
          	 end if                                                                     
         end if	                                                                        
       
      
      #---------------------------------------------
       before field srvespnom
      #---------------------------------------------         
         display ma_ctc69m23[arr_aux].srvespnom to s_ctc69m23[scr_aux].srvespnom attribute(reverse)         
         let lr_retorno.srvespnom =  ma_ctc69m23[arr_aux].srvespnom                                        
      
      #---------------------------------------------
       after field srvespnom
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field srvespnum 
         end if 
         
         if ma_ctc69m23[arr_aux].srvespnom is null then
         	  error "Por Favor Informe a Descricao da Especialidade "
        		next field srvespnom          		        	
         end if 
                                                
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m23[arr_aux].srvespnom <> lr_retorno.srvespnom then
               	
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc69m23_003 using ma_ctc69m23[arr_aux].srvespnom                                           
                                           , ma_ctc69m23[arr_aux].srvespnum
                                            
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao da Especialidade!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field srvespnum                                
         else
           
                              
           let lr_retorno.data = today
           
           
           whenever error continue
           execute p_ctc69m23_004 using ma_ctc69m23[arr_aux].srvespnum 
                                      , ma_ctc69m23[arr_aux].srvespnom 
                                      , lr_retorno.data
                                      
           whenever error stop
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao da Especialidade!'
           end if
           
           display ma_ctc69m23[arr_aux].srvespnum   to s_ctc69m23[scr_aux].srvespnum 
           display ma_ctc69m23[arr_aux].srvespnom   to s_ctc69m23[scr_aux].srvespnom 
           
           let m_operacao = " "  
           next field srvespnum 
           
         end if
         
         display ma_ctc69m23[arr_aux].srvespnum   to s_ctc69m23[scr_aux].srvespnum
         display ma_ctc69m23[arr_aux].srvespnom   to s_ctc69m23[scr_aux].srvespnom
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc69m23[arr_aux] to null                             
                                                                              
         display ma_ctc69m23[arr_aux].srvespnum   to s_ctc69m23[scr_aux].srvespnum  
         display ma_ctc69m23[arr_aux].srvespnom   to s_ctc69m23[scr_aux].srvespnom  
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m23[arr_aux].srvespnum  is null   then                    	
            continue input                                                  	
         else                                                               	
            if not ctc69m23_delete(ma_ctc69m23[arr_aux].srvespnum) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc69m23
 
 if lr_retorno.flag = 1 then
    call ctc69m23()
 end if
 
 
end function

#==============================================                                                
 function ctc69m23_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	srvespnum   like datksrvesp.srvespnum       
end record                                                      

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DA ESPECIALIDADE ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc69m23_005 using lr_param.srvespnum 
                                                                                        
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Especialidade!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function                                                                                   

































             
          






                                                                                      