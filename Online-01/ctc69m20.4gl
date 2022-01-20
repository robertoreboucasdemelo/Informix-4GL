#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Regras Siebel                                              # 
# Modulo.........: ctc69m20                                                   # 
# Objetivo.......: Cadastro De Dominios                                       # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 10/09/2013                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m20 array[500] of record
      cpocod   like datkdominio.cpocod
    , cpodes   like datkdominio.cpodes  
end record
 
 
define mr_ctc69m20 record
      datcod   like datkdominio.cpocod  
    , datdes   like datkdominio.cpodes  
    , atlult   like datkdominio.atlult   
end record

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc69m20_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod                      '
          ,  '      , cpodes                      '       
          ,  '   from datkdominio                 '   
          ,  '  where cponom  = ?                 '
          ,  '  order by cpocod                   '
 prepare p_ctc69m20_001 from l_sql
 declare c_ctc69m20_001 cursor for p_ctc69m20_001
 	
 let l_sql = ' select count(*)                   '
          ,  ' from datkdominio                  '
          ,  ' where cponom  = ?                 '      
          ,  ' and   cpodes  = ?                 '
 prepare p_ctc69m20_002 from l_sql
 declare c_ctc69m20_002 cursor for p_ctc69m20_002
 
  
 let l_sql =  ' insert into datkdominio       '
           ,  '   (cponom                     '          
           ,  '   ,cpocod                     '
           ,  '   ,cpodes                     '
           ,  '   ,atlult)                    '
           ,  ' values(?,?,?,?)   '
 prepare p_ctc69m20_004 from l_sql 	
  
 
 let l_sql = ' select atlult                     '                                  	                            	
            ,' from datkdominio                  '     
            ,' where cponom  = ?                 '  
            ,' and   cpocod  = ?                 '  
 prepare p_ctc69m20_005    from l_sql                                             	
 declare c_ctc69m20_005 cursor for p_ctc69m20_005                                 	
    
 
 let l_sql = ' delete datkdominio                '   
            ,' where cponom  = ?                 '    
            ,' and   cpocod  = ?                 '  
 prepare p_ctc69m20_006 from l_sql 
 
 
 let l_sql = ' select max(cpocod)                '                         	                           	
          ,  ' from datkdominio                  '  
          ,  ' where cponom  = ?                 '  
 prepare p_ctc69m20_007 from l_sql                                                 	
 declare c_ctc69m20_007 cursor for p_ctc69m20_007
 	
 	
 let l_sql =  ' update datkdominio    '   
            , ' set   cpodes =  ?     '    	
            , ' where cponom =  ?     '    	
            , ' and   cpocod =  ?     '    	
 prepare p_ctc69m20_008 from l_sql        	
 	
 	
 	     
 
 let m_prepare = true


end function

#===============================================================================
 function ctc69m20(lr_param)
#===============================================================================
 
define lr_param record                            
    datcod   like datkdominio.cpocod     
  , datdes   like datkdominio.cpodes             
end record                                        


define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    cpodes              char(60) ,
    confirma            char(01) 
end record
 

 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc69m20[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc69m20.*, lr_retorno.* to null 
 
 let mr_ctc69m20.datcod  = lr_param.datcod
 let mr_ctc69m20.datdes  = lr_param.datdes
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m20_prepare()
 end if
    
 
 
 open window w_ctc69m20 at 6,2 with form 'ctc69m20'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui'
   
 display by name mr_ctc69m20.datcod   
               , mr_ctc69m20.datdes  
              
              
 #--------------------------------------------------------
 # Recupera os Dados da Classe                         
 #--------------------------------------------------------  
   
  open c_ctc69m20_001 using mr_ctc69m20.datdes  
  foreach c_ctc69m20_001 into ma_ctc69m20[arr_aux].cpocod 
                            , ma_ctc69m20[arr_aux].cpodes                          
                            
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontradas Mais de 500 Dominios!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m20 without defaults from s_ctc69m20.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m20[arr_aux].cpodes  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m20[arr_aux] to null
                  
         display ma_ctc69m20[arr_aux].cpodes   to s_ctc69m20[scr_aux].cpodes                                           

              
      #---------------------------------------------
       before field cpodes
      #---------------------------------------------
        
        let lr_retorno.cpodes = ma_ctc69m20[arr_aux].cpodes 
        
        if ma_ctc69m20[arr_aux].cpodes  is null then                                                   
           display ma_ctc69m20[arr_aux].cpodes  to s_ctc69m20[scr_aux].cpodes  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc69m20[arr_aux].* to s_ctc69m20[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then
           call ctc69m20_dados_alteracao(ma_ctc69m20[arr_aux].cpocod) 
        end if 
      
      #---------------------------------------------
       after field cpodes                    
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc69m20[arr_aux].cpodes  is null then
        		 error "Por Favor Informe a Descricao do Dominio"   		 
        		 next field cpodes        		              		
          end if 
          
          #-------------------------------------------------------- 
          # Valida Se o Dominio Ja Foi Cadastrado                             
          #-------------------------------------------------------- 
           
          open c_ctc69m20_002 using  mr_ctc69m20.datdes ,
                                     ma_ctc69m20[arr_aux].cpodes          
                                           
          whenever error continue                                                
          fetch c_ctc69m20_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Associacao ja Cadastrada!" 
             next field cpodes 
          end if 
                                                                                              
          display ma_ctc69m20[arr_aux].cpocod  to s_ctc69m20[scr_aux].cpocod  
          display ma_ctc69m20[arr_aux].cpodes  to s_ctc69m20[scr_aux].cpodes 
              
          #--------------------------------------------------------   
          # Recupera a Chave do Dominio                              
          #--------------------------------------------------------   
          call ctc69m20_recupera_chave()                              
          
          
          #-------------------------------------------------------- 
          # Inclui o Dominio                            
          #-------------------------------------------------------- 
          call ctc69m20_inclui()
                  
                   
          next field cpodes                                                             
                                        
        else          
        	
        	display ma_ctc69m20[arr_aux].* to s_ctc69m20[scr_aux].* 
        	
        	if ma_ctc69m20[arr_aux].cpodes <> lr_retorno.cpodes then
        	   	  
        	   	  
        	   	 #--------------------------------------------------------      
        	   	 # Valida Se o Dominio Ja Foi Cadastrado                        
        	   	 #--------------------------------------------------------      
        	   	                                                                
        	   	 open c_ctc69m20_002 using  mr_ctc69m20.datdes ,                
        	   	                            ma_ctc69m20[arr_aux].cpodes         
        	   	                                                                
        	   	 whenever error continue                                        
        	   	 fetch c_ctc69m20_002 into lr_retorno.cont                      
        	   	 whenever error stop                                            
        	   	                                                                
        	   	 if lr_retorno.cont >  0   then                                 
        	   	    error " Associacao ja Cadastrada!"                          
        	   	    next field cpodes                                           
        	   	 end if 
        	   	 
        	   	 #--------------------------------------------------------  
        	   	 # Atualiza o Dominio                                         
        	   	 #--------------------------------------------------------  
        	   	 call ctc69m20_atualiza()                                     
        	      	   	  
        	
          end if	
        	                                                     
        end if
        
       
        
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
      
         exit input
      
      
      #---------------------------------------------                  
       before delete                                                  
      #---------------------------------------------                  
         if ma_ctc69m20[arr_aux].cpodes  is null   then               
            continue input                                            
         else                                                         
                                 
               #-------------------------------------------------------- 
               # Exclui o Dominio                            
               #-------------------------------------------------------- 
               
               if not ctc69m20_delete(ma_ctc69m20[arr_aux].cpocod) then  
                   let lr_retorno.flag = 1                               
                   exit input                                            
               end if 
             
            
               next field cpodes
                                                               
         end if 
          
  end input
  
 close window w_ctc69m20
 
 if lr_retorno.flag = 1 then
    call ctc69m20(mr_ctc69m20.datcod, mr_ctc69m20.datdes)
 end if
 
 
end function



#---------------------------------------------------------                                                                                            
 function ctc69m20_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	cpocod like datkdominio.cpocod
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m20.atlult to null                                                    
                                                                                      
                                                               
   open c_ctc69m20_005 using  mr_ctc69m20.datdes,
                              lr_param.cpocod                                               
      
   whenever error continue                                                 
   fetch c_ctc69m20_005 into  mr_ctc69m20.atlult                                       
                                                                                                                                                    
   whenever error stop                                 
                                                                                 
   display by name  mr_ctc69m20.atlult                                                                                
                                                                                      
end function

#==============================================                                                                                                           
 function ctc69m20_delete(lr_param)                                                                                                                                   
#==============================================                                 
                                                                                
define lr_param record                                                          
	cpocod   like datkdominio.cpocod                                                              
end record                                                                      
                                                                                
define lr_retorno record                                                        
	confirma char(1)                                                              
end record                                                                      
                                                                                
initialize lr_retorno.* to null                                                 
                                                                                
  call cts08g01("A","S"                                                         
               ,""                                             
               ,"CONFIRMA EXCLUSAO"                                                    
               ,"DO DOMINIO  ?"                                                  
               ," ")                                                            
     returning lr_retorno.confirma                                              
                                                                                
     if lr_retorno.confirma  = "S" then                                         
        let m_operacao = 'd'                                                    
                                                                                
        begin work
        
        whenever error continue                                                 
        execute p_ctc69m20_006 using mr_ctc69m20.datdes,
                                     lr_param.cpocod                           
                                                                                
        whenever error stop                                                     
        if sqlca.sqlcode <> 0 then                                              
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Dominio!'               
           rollback work
           return false                                                         
        end if  
                      
        commit work                                                                
        return true                                                             
     else                                                                       
        return false                                                            
     end if                                                                     
                                                                                
end function  

#---------------------------------------------------------                                                                                                
 function ctc69m20_inclui()                                                                                                                            
#---------------------------------------------------------                              
                                                                                        
define l_data date

let l_data = today   
   
   whenever error continue                                        
   execute p_ctc69m20_004 using mr_ctc69m20.datdes
                              , ma_ctc69m20[arr_aux].cpocod    
                              , ma_ctc69m20[arr_aux].cpodes                      
                              , l_data                           
                                                                  
   whenever error continue                                        
   if sqlca.sqlcode = 0 then                                      
      error 'Dados Incluidos com Sucesso!'                        
      let m_operacao = ' '                                        
   else                                                           
      error 'ERRO(',sqlca.sqlcode,') na Insercao do Dominio!'  
   end if                                                         
  
  
end function  

#---------------------------------------------------------                                                                                                                                        
 function ctc69m20_recupera_chave()                                                                                                                         
#---------------------------------------------------------            

define l_cont integer
                                                                 
    open c_ctc69m20_007 using mr_ctc69m20.datdes               
    whenever error continue                                           
    fetch c_ctc69m20_007 into l_cont       
    whenever error stop 
       
    if l_cont is null then
    	 let l_cont = 0
    end if  
        
    let ma_ctc69m20[arr_aux].cpocod = l_cont + 1                                                
                                                                                                                                                     
end function

#---------------------------------------------------------                   
 function ctc69m20_atualiza()                                                 
#---------------------------------------------------------                                                                                       
                                                                            
                                                                                                                                               
   whenever error continue                                                  
   execute p_ctc69m20_008 using ma_ctc69m20[arr_aux].cpodes                           
                              , mr_ctc69m20.datdes
                              , ma_ctc69m20[arr_aux].cpocod                 
                                        
                                        
                                                                            
   whenever error continue                                                  
   if sqlca.sqlcode = 0 then                                                
      error 'Dados Alterados com Sucesso!'                                  
      let m_operacao = ' '                                                  
   else                                                                                                                                                    
      error 'ERRO(',sqlca.sqlcode,') na Alteracao do Dominio!'               
   end if                                                                   
                                                                            
                                                                            
end function                                                                
