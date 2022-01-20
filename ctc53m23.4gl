#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m23                                                   # 
# Objetivo.......: Cadastro Fluxo1 X Clausula                                 # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 05/04/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m23 array[500] of record
      clscod  like aackcls.clscod          
    , clsdes  like aackcls.clsdes             
end record
 
 
define mr_ctc53m23 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc53m23_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpodes                  '
          ,  '  from datkdominio               '  
          ,  '  where cponom = ?               '  
          ,  '  order by cpodes                '
 prepare p_ctc53m23_001 from l_sql
 declare c_ctc53m23_001 cursor for p_ctc53m23_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpodes = ?               '
 prepare p_ctc53m23_002 from l_sql
 declare c_ctc53m23_002 cursor for p_ctc53m23_002

  
let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m23_004 from l_sql 	
  
 
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes  =  ?         ' 
 prepare p_ctc53m23_005    from l_sql                                             	
 declare c_ctc53m23_005 cursor for p_ctc53m23_005  
 	
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes  =  ?         '                             	                            	
 prepare p_ctc53m23_006 from l_sql  
 
 
 let l_sql = '   select max(cpocod)     '                
            ,'   from datkdominio       '    
            ,'   where cponom  =  ?     '                
 prepare p_ctc53m23_007    from l_sql             
 declare c_ctc53m23_007 cursor for p_ctc53m23_007 
 	
 
 	
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         '                      	                            	  	                 	
 prepare p_ctc53m23_009 from l_sql                	
 

 let m_prepare = true


end function

#===============================================================================
 function ctc53m23()
#===============================================================================
 
define lr_retorno record
    flag                 smallint                               ,
    cont                 integer                                ,
    confirma             char(01) 
end record
 
 
 let m_chave = ctc53m23_monta_chave()
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc53m23[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc53m23.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m23_prepare()
 end if
    
 
 
 open window w_ctc53m23 at 6,2 with form 'ctc53m23'
 attribute(form line 1)
  
  let mr_ctc53m23.msg = '                (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_ctc53m23.msg  
  
 
  #--------------------------------------------------------
  # Recupera os Dados do Fluxo1 X Clausula           
  #-------------------------------------------------------- 
  
  open c_ctc53m23_001  using  m_chave 
  foreach c_ctc53m23_001 into ma_ctc53m23[arr_aux].clscod

       #--------------------------------------------------------
       # Recupera a Descricao do Clausula
       #--------------------------------------------------------
       
       call ctc69m04_recupera_descricao_6(11,ma_ctc53m23[arr_aux].clscod,531) 
       returning ma_ctc53m23[arr_aux].clsdes                                  

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Clausulas!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc53m23 without defaults from s_ctc53m23.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m23[arr_aux].clscod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc53m23[arr_aux] to null
                  
         display ma_ctc53m23[arr_aux].clscod   to s_ctc53m23[scr_aux].clscod 
       
      #---------------------------------------------
       before field clscod
      #---------------------------------------------
        
        if ma_ctc53m23[arr_aux].clscod is null then                                                   
           display ma_ctc53m23[arr_aux].clscod to s_ctc53m23[scr_aux].clscod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc53m23[arr_aux].* to s_ctc53m23[scr_aux].* attribute(reverse)                          
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Restricao X Clausula          
        	 #--------------------------------------------------------
        	
           call ctc53m23_dados_alteracao(ma_ctc53m23[arr_aux].clscod) 
        end if 
      
      #---------------------------------------------
       after field clscod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc53m23[arr_aux].clscod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Clausula        
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup_2(11,531) 
        		 returning ma_ctc53m23[arr_aux].clscod 
        		         , ma_ctc53m23[arr_aux].clsdes       		      
        		 
        		 if ma_ctc53m23[arr_aux].clscod is null then 
        		    next field clscod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Clausula        
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao_6(11,ma_ctc53m23[arr_aux].clscod,531) 
        		returning ma_ctc53m23[arr_aux].clsdes                                  
        		
        		if ma_ctc53m23[arr_aux].clsdes  is null then      
        		   next field clscod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Fluxo1 X Clausula Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc53m23_002 using m_chave, 
                                    ma_ctc53m23[arr_aux].clscod            
                                          
          whenever error continue                                                
          fetch c_ctc53m23_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Clausula ja Cadastrado!" 
             next field clscod 
          end if 
          
          display ma_ctc53m23[arr_aux].clscod to s_ctc53m23[scr_aux].clscod 
          display ma_ctc53m23[arr_aux].clsdes to s_ctc53m23[scr_aux].clsdes                                                               
                              
           
        else          
        	display ma_ctc53m23[arr_aux].* to s_ctc53m23[scr_aux].*                                                     
        end if
        
         
         if m_operacao = 'i' then 
               
            #-------------------------------------------------------- 
            # Recupera Codigo da Associacao Fluxo1 X Clausula                  
            #--------------------------------------------------------          
            call ctc53m23_recupera_chave()          
            
            #-------------------------------------------------------- 
            # Inclui Associacao Fluxo1 X Clausula                  
            #-------------------------------------------------------- 
            call ctc53m23_inclui()  
                    
            next field clscod            
         end if
         
         display ma_ctc53m23[arr_aux].clscod   to s_ctc53m23[scr_aux].clscod
         display ma_ctc53m23[arr_aux].clsdes   to s_ctc53m23[scr_aux].clsdes   
      
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m23[arr_aux].clscod  is null   then                    	
            continue input                                                  	
         else                                                               	
                      
            #-------------------------------------------------------- 
            # Exclui Associacao Fluxo1 X Clausula                  
            #-------------------------------------------------------- 
            
            if not ctc53m23_delete(ma_ctc53m23[arr_aux].clscod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
                              
            next field clscod
                                                                   	
         end if                     
      
      
      
  end input
  
 close window w_ctc53m23
 
 if lr_retorno.flag = 1 then
    call ctc53m23()
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc53m23_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	clscod like aackcls.clscod 
end record
                                                                                                    
                                                                                      
   initialize mr_ctc53m23.* to null                                                    
                                                                                      
                                                               
   open c_ctc53m23_005 using m_chave,
                             lr_param.clscod                                                  
      
   whenever error continue                                                 
   fetch c_ctc53m23_005 into  mr_ctc53m23.atldat                                       
                             ,mr_ctc53m23.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc53m23.atldat                                           
                   ,mr_ctc53m23.funmat                                   
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc53m23_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		clscod like aackcls.clscod     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE CLAUSULA ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc53m23_006 using m_chave,
                                     lr_param.clscod                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Clausula!'   
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
 function ctc53m23_inclui()                                             
#---------------------------------------------------------

define lr_retorno record
   data_atual date,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue
    execute p_ctc53m23_004 using mr_ctc53m23.cpocod    
                               , ma_ctc53m23[arr_aux].clscod
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if                    
                                                                                      
end function

#---------------------------------------------------------                                                                                         
 function ctc53m23_recupera_chave()                                                                                                                                       
#---------------------------------------------------------                                                                                                        
                                                                                
    open c_ctc53m23_007 using m_chave                                                           
    whenever error continue                                       
    fetch c_ctc53m23_007 into mr_ctc53m23.cpocod                                                             
    whenever error stop 
    
    if mr_ctc53m23.cpocod is null or
    	 mr_ctc53m23.cpocod = ""    or
    	 mr_ctc53m23.cpocod = 0     then    	 	
    	 	let mr_ctc53m23.cpocod = 1  
    else
    	  let mr_ctc53m23.cpocod = mr_ctc53m23.cpocod + 1
    end if	                                                                                                                                
                              
end function



#===============================================================================     
 function ctc53m23_monta_chave()                                                         
#=============================================================================== 

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "PF_FLUXO1"

 return lr_retorno.chave 
 
end function                                                               
                                                                            























