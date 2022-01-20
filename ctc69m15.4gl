#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Regras Siebel                                              # 
# Modulo.........: ctc69m15                                                   # 
# Objetivo.......: Cadastro Unidades de Limites                               # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 22/08/2013                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m15 array[500] of record
      limcod   integer
    , limdes   char(60)   
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc69m15_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod    '
          ,  '      , cpodes      '          
          ,  '   from datkdominio         '
          ,  '  where cponom = "unid_siebel" ' 
          ,  '  order by 1   '
 prepare p_ctc69m15_001 from l_sql
 declare c_ctc69m15_001 cursor for p_ctc69m15_001
 	
 let l_sql = ' select count(*)         '
          ,  '   from datkdominio '
          ,  '  where cponom = "unid_siebel" '        
          ,  '   and  cpocod = ? '
 prepare p_ctc69m15_002 from l_sql
 declare c_ctc69m15_002 cursor for p_ctc69m15_002
 
 let l_sql = ' update datkdominio  '
           ,  '     set cpodes = ?   '                      
           ,  '   where cpocod  =  ? '       
           ,  '   and cponom = "unid_siebel" '  
 prepare p_ctc69m15_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,"unid_siebel",?) '
 prepare p_ctc69m15_004 from l_sql 	
  
 
 let l_sql = '  delete datkdominio    '                               	
         ,  '   where cpocod = ?          '                             	
         ,  '   and cponom = "unid_siebel"      '                             	
 prepare p_ctc69m15_005 from l_sql 
 
 
 let l_sql = ' select count(*)         '         
          ,  '   from datkdominio '              
          ,  '  where cponom = "unid_siebel" '   
          ,  '   and  cpodes = ? '               
 prepare p_ctc69m15_006 from l_sql               
 declare c_ctc69m15_006 cursor for p_ctc69m15_006
 
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc69m15()
#===============================================================================
 
 
define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    limcod              integer  ,
    limdes              char(60) 
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc69m15[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m15_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc69m15 at 6,2 with form 'ctc69m15'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui'
   
  
  open c_ctc69m15_001  
  foreach c_ctc69m15_001 into ma_ctc69m15[arr_aux].limcod 
                            , ma_ctc69m15[arr_aux].limdes                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Unidade Excedida! Foram Encontradas Mais de 500 Unidades!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m15 without defaults from s_ctc69m15.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m15[arr_aux].limcod  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field limcod 
      #---------------------------------------------
                  
        if ma_ctc69m15[arr_aux].limcod  is null then                                                   
           display ma_ctc69m15[arr_aux].limcod  to s_ctc69m15[scr_aux].limcod  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let lr_retorno.limcod = ma_ctc69m15[arr_aux].limcod
          display ma_ctc69m15[arr_aux].* to s_ctc69m15[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field limcod                    
      #---------------------------------------------
          
        if m_operacao = 'i' then
        	
        	if ma_ctc69m15[arr_aux].limcod  is null then
        		 error "Por Favor Informe o Codigo da Unidade "
        		 next field limcod          		
          end if 
          
          
          open c_ctc69m15_002 using ma_ctc69m15[arr_aux].limcod         
          whenever error continue                                                
          fetch c_ctc69m15_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Codigo ja Cadastrado!" 
             next field limcod  
          end if 
                        
        else          
        	let ma_ctc69m15[arr_aux].limcod = lr_retorno.limcod
        	display ma_ctc69m15[arr_aux].* to s_ctc69m15[scr_aux].*       	                                                    
        end if
        
       
      
      #---------------------------------------------
       before field limdes
      #---------------------------------------------         
         display ma_ctc69m15[arr_aux].limdes to s_ctc69m15[scr_aux].limdes attribute(reverse)         
         let lr_retorno.limdes =  ma_ctc69m15[arr_aux].limdes                                        
      
      #---------------------------------------------
       after field limdes
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field limcod 
         end if 
         
         if ma_ctc69m15[arr_aux].limdes is null then
         	  error "Por Favor Informe a Descricao da Unidade "
        		next field limdes          		        	
         end if 
         
         
         open c_ctc69m15_006 using ma_ctc69m15[arr_aux].limdes 
         whenever error continue                               
         fetch c_ctc69m15_006 into lr_retorno.cont             
         whenever error stop                                   
                                                               
         if lr_retorno.cont >  0   then                        
            error " Descricao ja Cadastrado!"                                           
            next field limdes                                  
         end if                                                       
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m15[arr_aux].limdes <> lr_retorno.limdes then
               	
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc69m15_003 using ma_ctc69m15[arr_aux].limdes                                           
                                           , ma_ctc69m15[arr_aux].limcod
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao da Unidade!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field limcod                                
         else
           
                              
           whenever error continue
           execute p_ctc69m15_004 using ma_ctc69m15[arr_aux].limcod 
                                      , ma_ctc69m15[arr_aux].limdes                                     
                                      , 'today'
                                      
           whenever error continue
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao da Unidade!'
           end if
           
           display ma_ctc69m15[arr_aux].limcod   to s_ctc69m15[scr_aux].limcod 
           display ma_ctc69m15[arr_aux].limdes   to s_ctc69m15[scr_aux].limdes 
           
           let m_operacao = " "  
           next field limcod 
           
         end if
         
         display ma_ctc69m15[arr_aux].limcod   to s_ctc69m15[scr_aux].limcod
         display ma_ctc69m15[arr_aux].limdes   to s_ctc69m15[scr_aux].limdes
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc69m15[arr_aux] to null                             
                                                                              
         display ma_ctc69m15[arr_aux].limcod   to s_ctc69m15[scr_aux].limcod  
         display ma_ctc69m15[arr_aux].limdes   to s_ctc69m15[scr_aux].limdes  
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m15[arr_aux].limcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            if not ctc69m15_delete(ma_ctc69m15[arr_aux].limcod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc69m15
 
 if lr_retorno.flag = 1 then
    call ctc69m15()
 end if
 
 
end function

#==============================================                                                
 function ctc69m15_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	limcod   integer     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE UNIDADE ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc69m15_005 using lr_param.limcod                                                     
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Unidade!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function                                                                                   

































             
          






                                                                                      