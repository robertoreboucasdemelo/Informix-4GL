#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Itau                                              # 
# Modulo.........: ctc91m39                                                   # 
# Objetivo.......: Cadastro Grupo X Produto                                   # 
# Analista Resp. : R.Fornax                                                   # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 09/04/2016                                                 # 
#.............................................................................# 

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc91m39 array[500] of record
      itaprdcod     like datkitaprd.itaprdcod            
    , itaprddes     like datkitaprd.itaprddes              
end record
 
define mr_param   record                      
     grpprdcod  smallint,
     grpprddes  char(60)  
end record
 
define mr_ctc91m39 record
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
 function ctc91m39_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod                 '
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by cpocod                '     
 prepare p_ctc91m39_001 from l_sql
 declare c_ctc91m39_001 cursor for p_ctc91m39_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc91m39_002 from l_sql
 declare c_ctc91m39_002 cursor for p_ctc91m39_002
 	
 let l_sql = ' select  count(*)                      '  
              ,' from datkdominio                    '             
              ,' where cponom matches "IT_ASS_PRD_*" '                
              ,' and   cpocod =  ?                   '            
 prepare p_ctc91m39_003 from l_sql                 
 declare c_ctc91m39_003 cursor for p_ctc91m39_003  	

 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod,                '          
           ,  '    cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc91m39_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc91m39_005    from l_sql                                             	
 declare c_ctc91m39_005 cursor for p_ctc91m39_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc91m39_006 from l_sql
 
 

 	
 let m_prepare = true


end function

#===============================================================================
 function ctc91m39(lr_param)
#===============================================================================
 
define lr_param record
    grpprdcod  smallint,  
    grpprddes  char(60)      
end record
 
define lr_retorno record
    flag       smallint                     ,
    cont       integer                      ,
    confirma   char(01) 
end record
 
 let mr_param.grpprdcod  = lr_param.grpprdcod
 let mr_param.grpprddes  = lr_param.grpprddes
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc91m39[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc91m39.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc91m39_prepare()
 end if
    
 let m_chave = ctc91m39_monta_chave(mr_param.grpprdcod)
 
 open window w_ctc91m39 at 6,2 with form 'ctc91m39'
 attribute(form line 1)
  
 let mr_ctc91m39.msg =  '                    (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_param.grpprdcod
                , mr_param.grpprddes
                , mr_ctc91m39.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Grupo X Produto           
  #-------------------------------------------------------- 
  
  open c_ctc91m39_001  using  m_chave                                             
  foreach c_ctc91m39_001 into ma_ctc91m39[arr_aux].itaprdcod
  	                                                                         
       #--------------------------------------------------------                  
       # Recupera a Descricao da Natureza                                          
       #--------------------------------------------------------                  
                                                                                  
       call ctc69m04_recupera_descricao(25,ma_ctc91m39[arr_aux].itaprdcod)       
       returning ma_ctc91m39[arr_aux].itaprddes                                     
                                                                                  
       let arr_aux = arr_aux + 1                                                  
                                                                                  
       if arr_aux > 500 then                                                      
          error " Limite Excedido! Foram Encontrados Mais de 500 Produtos!"       
          exit foreach                                                            
       end if                                                                     
                                                                                  
  end foreach                                                                     
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc91m39 without defaults from s_ctc91m39.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc91m39[arr_aux].itaprdcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc91m39[arr_aux] to null
                  
         display ma_ctc91m39[arr_aux].itaprdcod  to s_ctc91m39[scr_aux].itaprdcod 
         display ma_ctc91m39[arr_aux].itaprddes  to s_ctc91m39[scr_aux].itaprddes
                        

              
      #---------------------------------------------
       before field itaprdcod
      #---------------------------------------------
        
        if ma_ctc91m39[arr_aux].itaprdcod is null then                                                   
           display ma_ctc91m39[arr_aux].itaprdcod to s_ctc91m39[scr_aux].itaprdcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc91m39[arr_aux].* to s_ctc91m39[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Grupo X Produto          
        	 #--------------------------------------------------------
        	
           call ctc91m39_dados_alteracao(ma_ctc91m39[arr_aux].itaprdcod) 
        end if 
      
      #---------------------------------------------
       after field itaprdcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc91m39[arr_aux].itaprdcod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Produto          
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup(25)
        		 returning ma_ctc91m39[arr_aux].itaprdcod 
        		         , ma_ctc91m39[arr_aux].itaprddes
        		 
        		 if ma_ctc91m39[arr_aux].itaprdcod is null then 
        		    next field itaprdcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Produto         
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao(25,ma_ctc91m39[arr_aux].itaprdcod)
        		returning ma_ctc91m39[arr_aux].itaprddes   
        		
        		if ma_ctc91m39[arr_aux].itaprddes is null then      
        		   next field itaprdcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Grupo X Produto Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc91m39_002 using m_chave,
                                    ma_ctc91m39[arr_aux].itaprdcod                                                
          whenever error continue                                                
          fetch c_ctc91m39_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Produto ja Cadastrada Para Este Grupo!!" 
             next field itaprdcod 
          end if 
          
          #-------------------------------------------------------------------------
          # Valida Se a Associacao Grupo X Produto Ja Existe em Outro Agrupamento           
          #-------------------------------------------------------------------------
          
          open c_ctc91m39_003 using ma_ctc91m39[arr_aux].itaprdcod                                                
          whenever error continue                                                
          fetch c_ctc91m39_003 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Produto ja Cadastrado em Outro Grupo!!" 
             next field itaprdcod 
          end if 
          
          display ma_ctc91m39[arr_aux].itaprdcod to s_ctc91m39[scr_aux].itaprdcod 
          display ma_ctc91m39[arr_aux].itaprddes to s_ctc91m39[scr_aux].itaprddes                                                                
                              
           
        else          
        	display ma_ctc91m39[arr_aux].* to s_ctc91m39[scr_aux].*                                                     
        end if
        
         
     
                                                                                                
        if m_operacao <> 'i' then                        
           let m_operacao = ' '                           
        else
           
           #-------------------------------------------------------- 
           # Inclui Associacao Grupo X Produto                  
           #-------------------------------------------------------- 
           call ctc91m39_inclui()    
           
           next field itaprdcod            
        end if
        
        display ma_ctc91m39[arr_aux].itaprdcod  to s_ctc91m39[scr_aux].itaprdcod
        display ma_ctc91m39[arr_aux].itaprddes  to s_ctc91m39[scr_aux].itaprddes
       
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc91m39[arr_aux].itaprdcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            #-------------------------------------------------------- 
            # Exclui Associacao Grupo X Produto                 
            #-------------------------------------------------------- 
            
            if not ctc91m39_delete(ma_ctc91m39[arr_aux].itaprdcod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
           
      
            next field itaprdcod
                                                                   	
         end if
         
         
      
  end input
  
 close window w_ctc91m39
 
 if lr_retorno.flag = 1 then
    call ctc91m39(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc91m39_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	itaprdcod     like datkitaprd.itaprdcod  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc91m39.* to null                                                    
                                                                                      
                                                               
   open c_ctc91m39_005 using m_chave,
                             lr_param.itaprdcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc91m39_005 into  mr_ctc91m39.atldat                                       
                             ,mr_ctc91m39.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc91m39.atldat                                           
                   ,mr_ctc91m39.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc91m39_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		itaprdcod     like datkitaprd.itaprdcod     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DO PRODUTO ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc91m39_006 using m_chave,
                                     lr_param.itaprdcod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Produto!'   
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
 function ctc91m39_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"                     

    whenever error continue
    execute p_ctc91m39_004 using ma_ctc91m39[arr_aux].itaprdcod   
                               , mr_param.grpprdcod
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao do Produto!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc91m39_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                                                          
    grpprdcod  smallint   
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "IT_ASS_PRD_", lr_param.grpprdcod using "&&" 

 return lr_retorno.chave 
 
end function

                        
