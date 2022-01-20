#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc69m24                                                   # 
# Objetivo.......: De-Para Natureza,Tipo ou Motivo X Especialidade            # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 15/01/2015                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m24 array[500] of record
	    codori     integer
    , codigo     integer      
    , descricao  char(50) 
    , subcod     integer
    , srvespnum  like datksrvesp.srvespnum         
    , srvespnom  like datksrvesp.srvespnom        
end record
 
 
define mr_ctc69m24 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record

define mr_param array[500] of record
	    cod_depara     integer ,    
      subdes         char(50),	    
	    srvtipabvdes   like datksrvtip.srvtipabvdes      
end record

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc69m24_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod,                '
         ,  '          cpodes[01,02],         '         
         ,  '          cpodes[04,05],         '
         ,  '          cpodes[07,09],         ' 
         ,  '          cpodes[11,13]          '    
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by 2,3,4,5               '    
 prepare p_ctc69m24_001 from l_sql
 declare c_ctc69m24_001 cursor for p_ctc69m24_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpodes[01,02] = ?        '
          ,  ' and   cpodes[04,05] = ?        '
          ,  ' and   cpodes[07,09] = ?        '  
          ,  ' and   cpocod <> ?              '  
 prepare p_ctc69m24_002 from l_sql
 declare c_ctc69m24_002 cursor for p_ctc69m24_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[01,02]    = ? , '  
           ,  '         cpodes[04,05]    = ? , '    
           ,  '         cpodes[07,09]    = ? , '    
           ,  '         cpodes[11,13]    = ? , '    
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '    
           ,  ' and   cpocod = ?               '                 
 prepare p_ctc69m24_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m24_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc69m24_005    from l_sql                                             	
 declare c_ctc69m24_005 cursor for p_ctc69m24_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc69m24_006 from l_sql
 
 
 let l_sql = ' select max(cpocod)             '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
 prepare p_ctc69m24_007 from l_sql
 declare c_ctc69m24_007 cursor for p_ctc69m24_007
 	
 
 let l_sql = ' select cpodes[11,13]           '  	         
          ,  ' from datkdominio               '  	         
          ,  ' where cponom = ?               '  	         
          ,  ' and   cpodes[01,02] = ?        '  	         
          ,  ' and   cpodes[04,05] = ?        '  	         
          ,  ' and   cpodes[07,09] = ?        '  	 	       
 prepare p_ctc69m24_008 from l_sql                         
 declare c_ctc69m24_008 cursor for p_ctc69m24_008          

 let m_prepare = true


end function

#===============================================================================
 function ctc69m24()
#===============================================================================
 

define lr_retorno record
    flag       smallint                  ,
    cont       integer                   ,
    srvespnum  like datksrvesp.srvespnum ,
    cod_depara integer                   ,
    confirma   char(01)                  ,
    codori     integer        
end record
 
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc69m24[arr_aux].*, mr_param[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc69m24.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m24_prepare()
 end if
    
 let m_chave = ctc69m24_monta_chave()
 
 open window w_ctc69m24 at 6,2 with form 'ctc69m24'
 attribute(form line 1)
  
 let mr_ctc69m24.msg =  '                    (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_ctc69m24.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do De-Para Especialidade          
  #-------------------------------------------------------- 
  
  open c_ctc69m24_001  using  m_chave                                             
  foreach c_ctc69m24_001 into mr_param[arr_aux].cod_depara    ,
  	                          ma_ctc69m24[arr_aux].codori     ,
                              ma_ctc69m24[arr_aux].subcod     ,	                          
  	                          ma_ctc69m24[arr_aux].codigo     ,
  	                          ma_ctc69m24[arr_aux].srvespnum  
                                                                                   
       case ma_ctc69m24[arr_aux].codori                   
          when 1                                                             
        	                                                                   
        	   #--------------------------------------------------------        
        	   # Recupera a Descricao do Tipo de Assistencia                              
        	   #--------------------------------------------------------        
        	                                                                    
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	   returning ma_ctc69m24[arr_aux].descricao  
        	   
        	when 2                                                             
        	                                                                   
        	   #--------------------------------------------------------        
        	   # Recupera a Descricao do Motivo                              
        	   #--------------------------------------------------------        
        	                                                                    
        	   call ctc69m04_recupera_descricao(12,ma_ctc69m24[arr_aux].codigo) 
        	   returning ma_ctc69m24[arr_aux].descricao     
          
          when 3                                                            
        	                                                                      
        	   #--------------------------------------------------------        
        	   # Recupera a Descricao do Motivo                              
        	   #--------------------------------------------------------        
        	                                                                    
        	   call ctc69m04_recupera_descricao(12,ma_ctc69m24[arr_aux].codigo) 
        	   returning ma_ctc69m24[arr_aux].descricao   
          
          when 4                                                                                              
        	                                                                                           
        	   #--------------------------------------------------------                            
        	   # Recupera a Descricao do Tipo de Assistencia                                        
        	   #--------------------------------------------------------                            
        	                                                                                        
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori)                     
        	   returning ma_ctc69m24[arr_aux].descricao 
        	
        	when 5                                                                                              
        	                                                                                           
        	   #--------------------------------------------------------                            
        	   # Recupera a Descricao do Tipo de Assistencia                                        
        	   #--------------------------------------------------------                            
        	                                                                                        
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori)                     
        	   returning ma_ctc69m24[arr_aux].descricao                                             
                                                         
          
          
          when 6                                                                                              
        	                                                                                           
        	   #--------------------------------------------------------                            
        	   # Recupera a Descricao do Tipo de Assistencia                                        
        	   #--------------------------------------------------------                            
        	                                                                                        
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori)                     
        	   returning ma_ctc69m24[arr_aux].descricao                                             
          
          when 7                                                                                              
        	                                                                                           
        	   #--------------------------------------------------------                            
        	   # Recupera a Descricao do Tipo de Assistencia                                        
        	   #--------------------------------------------------------                            
        	                                                                                        
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori)                     
        	   returning ma_ctc69m24[arr_aux].descricao      
                
          when 8                                                             
        	                                                                   
        	   #--------------------------------------------------------        
        	   # Recupera a Descricao do Motivo                              
        	   #--------------------------------------------------------        
        	                                                                    
        	   call ctc69m04_recupera_descricao(12,ma_ctc69m24[arr_aux].codigo) 
        	   returning ma_ctc69m24[arr_aux].descricao     
          
          
          when 9                                                   
             
             #--------------------------------------------------------       
             # Recupera a Descricao da Natureza                              
             #--------------------------------------------------------       
                                                                             
             call ctc69m04_recupera_descricao(10,ma_ctc69m24[arr_aux].codigo)          
             returning ma_ctc69m24[arr_aux].descricao
             
          when 15                                                                                              
        	                                                                                           
        	   #--------------------------------------------------------                            
        	   # Recupera a Descricao do Tipo de Assistencia                                        
        	   #--------------------------------------------------------                            
        	                                                                                        
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori)                     
        	   returning ma_ctc69m24[arr_aux].descricao      
        	   
        	
        	when 18                                                                                             
        	                                                                                           
        	   #--------------------------------------------------------                            
        	   # Recupera a Descricao do Tipo de Assistencia                                        
        	   #--------------------------------------------------------                            
        	                                                                                        
        	   call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori)                     
        	   returning ma_ctc69m24[arr_aux].descricao      
        	
        	
        	                                    
                   
       end case
       
       
       #--------------------------------------------------------           
       # Recupera a Descricao da Especialidade                                  
       #--------------------------------------------------------           
                                                                           
       call ctc69m04_recupera_descricao(1,ma_ctc69m24[arr_aux].srvespnum)    
       returning ma_ctc69m24[arr_aux].srvespnom                            
       
                                                                                                                                                  
       let arr_aux = arr_aux + 1                                                  
                                                                                  
       if arr_aux > 500 then                                                      
          error " Limite Excedido! Foram Encontrados Mais de 500 De-Paras!"       
          exit foreach                                                            
       end if                                                                     
                                                                                  
  end foreach                                                                     
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m24 without defaults from s_ctc69m24.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m24[arr_aux].codori is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m24[arr_aux] to null
                  
         display ma_ctc69m24[arr_aux].codori     to s_ctc69m24[scr_aux].codori  
         display ma_ctc69m24[arr_aux].codigo     to s_ctc69m24[scr_aux].codigo 
         display ma_ctc69m24[arr_aux].descricao  to s_ctc69m24[scr_aux].descricao
         display ma_ctc69m24[arr_aux].subcod     to s_ctc69m24[scr_aux].subcod 
         display ma_ctc69m24[arr_aux].srvespnum  to s_ctc69m24[scr_aux].srvespnum 
         display ma_ctc69m24[arr_aux].srvespnom  to s_ctc69m24[scr_aux].srvespnom                         

      #---------------------------------------------                                         
       before field codori                                                                    
      #---------------------------------------------                                          
                                                                                              
        if mr_param[arr_aux].cod_depara is null then
        	 let lr_retorno.cod_depara = 0
        else
        	 let lr_retorno.cod_depara = mr_param[arr_aux].cod_depara
        end if
        
        if ma_ctc69m24[arr_aux].codori is null then                                           
           display ma_ctc69m24[arr_aux].codori to s_ctc69m24[scr_aux].codori attribute(reverse) 
           let m_operacao = 'i'                                                               
        else   
        	 let lr_retorno.codori = ma_ctc69m24[arr_aux].codori                                                                                       
           display ma_ctc69m24[arr_aux].* to s_ctc69m24[scr_aux].* attribute(reverse)          
        end if                                                                                
                                                                                              
                                                                                              
        if m_operacao <> 'i' then                                                             
        	                                                                                    
        	 #--------------------------------------------------------                          
        	 # Recupera os Dados Complementares do De-Para                           
        	 #--------------------------------------------------------                          
        	                                                                                    
           call ctc69m24_dados_alteracao(mr_param[arr_aux].cod_depara)                         
        end if                                                                                
                                                                                              
      #---------------------------------------------                                          
       after field codori                                                                     
      #---------------------------------------------                                          
          
         if fgl_lastkey() = fgl_keyval ("down")     or      
            fgl_lastkey() = fgl_keyval ("return")   then    
                  
                                                                                              
             if m_operacao = 'i' then                                                              
             	                                                                                    
             	if ma_ctc69m24[arr_aux].codori is null then                                         
             		                                                                                  
             		                                                                                  
             		 #--------------------------------------------------------                        
             		 # Abre o Popup da Origem                                                       
             		 #--------------------------------------------------------                        
             		                                                                                  
             		 call ctc69m04_popup(18)                                                          
             		 returning ma_ctc69m24[arr_aux].codori   ,
             		           mr_param[arr_aux].srvtipabvdes                                           
             		                                              
             		                                                                                  
             		 if ma_ctc69m24[arr_aux].codori is null then                                      
             		    next field codori                                                             
             		 end if                                                                           
                   
               end if                                                                             
                                                                                                                                                 
                                                                                                  
               display ma_ctc69m24[arr_aux].codori to s_ctc69m24[scr_aux].codori                                                                                                       
                                                                                                  
             else      
             	 let ma_ctc69m24[arr_aux].codori = lr_retorno.codori                                                                           
             	 display ma_ctc69m24[arr_aux].* to s_ctc69m24[scr_aux].*                            
             end if                                                                               
         else                                                                     
          	 if m_operacao = 'i' then                                             
          	    let ma_ctc69m24[arr_aux].codori = ''                           
          	    display ma_ctc69m24[arr_aux].* to s_ctc69m24[scr_aux].*           
          	    let m_operacao = ' '                                              
          	 else                                                                 
          	    let ma_ctc69m24[arr_aux].codori = lr_retorno.codori        
          	    display ma_ctc69m24[arr_aux].* to s_ctc69m24[scr_aux].*           
          	 end if                                                               
         end if	                                                                  
         
                                                                                                  
      
      #---------------------------------------------
       before field codigo
      #---------------------------------------------
                                                     
         display ma_ctc69m24[arr_aux].codigo to s_ctc69m24[scr_aux].codigo attribute(reverse)  
         
      
      #---------------------------------------------
       after field codigo                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("up")     or                
           fgl_lastkey() = fgl_keyval ("left")   then              
              next field codori                                    
        end if                           
  
             	
        if ma_ctc69m24[arr_aux].codigo is null then
        	 
        	 
        	 case ma_ctc69m24[arr_aux].codori  
        	 	  when 1                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1,ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao                                               
        	    
        	    when 2                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Motivo                                
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup(12)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao                  
        	    
        	    when 3                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Motivo                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup(12)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao     
        	    
        	    
        	    when 4                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1, ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao   
        	    
        	    when 5                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1, ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao
        	    
        	    when 6                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1, ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao   
        	    
        	    when 7                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1, ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao   
        	    
        	    
        	    when 8                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Motivo                                
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup(12)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao  
        	     
        	    
        	    when 9                                                                
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup da Natureza                                  
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup(10)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao
        	           	    
        	    when 15                                                               
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1, ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao  
        	               
        	    when 18                                                               
        	                                                                          
        	       #--------------------------------------------------------    
        	       # Abre o Popup do Tipo de Assistencia                                 
        	       #--------------------------------------------------------    
        	                                                                    
        	       call ctc69m04_popup_2(1, ma_ctc69m24[arr_aux].codori)                                      
        	       returning ma_ctc69m24[arr_aux].codigo                        
        	               , ma_ctc69m24[arr_aux].descricao  
        	                                                                                                                
        	 
        	 end case                                                                 
        	                                                                          
        	 
        	 if ma_ctc69m24[arr_aux].codigo is null then 
        	    next field codigo 
        	 end if
        else
        	
        	case ma_ctc69m24[arr_aux].codori
        		 when 1                                                             
        	                                                                      
        	      #--------------------------------------------------------        
        	      # Recupera a Descricao do Tipo de Assistencia                              
        	      #--------------------------------------------------------        
        	                                                                       
        	      call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	      returning ma_ctc69m24[arr_aux].descricao  
        	      
        	   when 2                                                             
        	                                                                      
        	      #--------------------------------------------------------        
        	      # Recupera a Descricao do Motivo                              
        	      #--------------------------------------------------------        
        	                                                                       
        	      call ctc69m04_recupera_descricao(12,ma_ctc69m24[arr_aux].codigo) 
        	      returning ma_ctc69m24[arr_aux].descricao   
        	      
        	   when 3                                                             
        	                                                                      
        	      #--------------------------------------------------------        
        	      # Recupera a Descricao do Motivo                              
        	      #--------------------------------------------------------        
        	                                                                       
        	      call ctc69m04_recupera_descricao(12,ma_ctc69m24[arr_aux].codigo) 
        	      returning ma_ctc69m24[arr_aux].descricao 
        	      
        	   when 4                                                             
        	                                                                     
        	     #--------------------------------------------------------        
        	     # Recupera a Descricao do Tipo de Assistencia                              
        	     #--------------------------------------------------------        
        	                                                                      
        	     call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	     returning ma_ctc69m24[arr_aux].descricao                
        	   
        	   when 5                                                             
        	                                                                     
        	     #--------------------------------------------------------        
        	     # Recupera a Descricao do Tipo de Assistencia                              
        	     #--------------------------------------------------------        
        	                                                                      
        	     call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	     returning ma_ctc69m24[arr_aux].descricao     
        	   
        	   when 6                                                             
        	                                                                     
        	     #--------------------------------------------------------        
        	     # Recupera a Descricao do Tipo de Assistencia                              
        	     #--------------------------------------------------------        
        	                                                                      
        	     call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	     returning ma_ctc69m24[arr_aux].descricao                                   
        	                                            
        	   when 7                                                             
        	                                                                     
        	     #--------------------------------------------------------        
        	     # Recupera a Descricao do Tipo de Assistencia                              
        	     #--------------------------------------------------------        
        	                                                                      
        	     call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	     returning ma_ctc69m24[arr_aux].descricao     
        	   
        	   when 8                                                             
        	                                                                      
        	      #--------------------------------------------------------        
        	      # Recupera a Descricao do Motivo                              
        	      #--------------------------------------------------------        
        	                                                                       
        	      call ctc69m04_recupera_descricao(12,ma_ctc69m24[arr_aux].codigo) 
        	      returning ma_ctc69m24[arr_aux].descricao  
        	   
        	   when 9                                                             
        	                                                                      
        	      #--------------------------------------------------------        
        	      # Recupera a Descricao da Natureza                              
        	      #--------------------------------------------------------        
        	                                                                       
        	      call ctc69m04_recupera_descricao(10,ma_ctc69m24[arr_aux].codigo) 
        	      returning ma_ctc69m24[arr_aux].descricao      
        	      
        	   when 15                                                             
        	                                                                     
        	     #--------------------------------------------------------        
        	     # Recupera a Descricao do Tipo de Assistencia                              
        	     #--------------------------------------------------------        
        	                                                                      
        	     call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	     returning ma_ctc69m24[arr_aux].descricao    
        	     
        	   when 18                                                             
        	                                                                     
        	     #--------------------------------------------------------        
        	     # Recupera a Descricao do Tipo de Assistencia                              
        	     #--------------------------------------------------------        
        	                                                                      
        	     call ctc69m04_recupera_descricao_2(1,ma_ctc69m24[arr_aux].codigo, ma_ctc69m24[arr_aux].codori) 
        	     returning ma_ctc69m24[arr_aux].descricao                        
        	      
        	                                                                      
        	end case                                                              
        	       		
        
        	if ma_ctc69m24[arr_aux].descricao is null then      
        	   next field codigo                             
        	end if                                                        
        		
         end if 
          
         
         display ma_ctc69m24[arr_aux].codigo to s_ctc69m24[scr_aux].codigo 
         display ma_ctc69m24[arr_aux].descricao to s_ctc69m24[scr_aux].descricao                                                                
                              
      
      #---------------------------------------------                                         
       before field subcod                                                                    
      #---------------------------------------------                                          
          
          display ma_ctc69m24[arr_aux].subcod to s_ctc69m24[scr_aux].subcod attribute(reverse)                                                                                     
                                                                                                                                           
      #---------------------------------------------                                          
       after field subcod                                                                     
      #---------------------------------------------                                          
                                                                                              
        if fgl_lastkey() = fgl_keyval ("up")     or                
           fgl_lastkey() = fgl_keyval ("left")   then              
              next field subcod                                    
        end if          
        
                                                          	                                                                                    
        if ma_ctc69m24[arr_aux].subcod is null then                                         
        	                                                                                  
        	                                                                                  
        	 #--------------------------------------------------------                        
        	 # Abre o Popup da Sub Natureza                                                       
        	 #--------------------------------------------------------                        
        	                                                                                  
        	 call ctc69m04_popup(19)                                                          
        	 returning ma_ctc69m24[arr_aux].subcod   ,
        	           mr_param[arr_aux].subdes                                          
        	                                              
        	                                                                                  
        	 if ma_ctc69m24[arr_aux].subcod is null then                                      
        	    next field subcod                                                             
        	 end if                                                                           
            
        end if  
        
        
        #--------------------------------------------------------              
        # Valida Se a Associacao do De-Para Ja Existe                          
        #--------------------------------------------------------              
                                                                               
        open c_ctc69m24_002 using m_chave                     ,                
                                  ma_ctc69m24[arr_aux].codori , 
                                  ma_ctc69m24[arr_aux].subcod ,               
                                  ma_ctc69m24[arr_aux].codigo ,                
                                  lr_retorno.cod_depara                        
        whenever error continue                                                
        fetch c_ctc69m24_002 into lr_retorno.cont                              
        whenever error stop                                                    
                                                                               
        if lr_retorno.cont >  0   then                                         
           error " De-Para ja Cadastrado para essa Natureza, Tipo ou Motivo"   
           next field subcod                                                   
        end if                                                                  
                                                                                                                                                                                                                                                                                                       
        display ma_ctc69m24[arr_aux].subcod to s_ctc69m24[scr_aux].subcod                                                                                                       
                                                                                                                                                       
      #---------------------------------------------
       before field srvespnum
      #---------------------------------------------
                                                     
         display ma_ctc69m24[arr_aux].srvespnum to s_ctc69m24[scr_aux].srvespnum attribute(reverse)
         let lr_retorno.srvespnum = ma_ctc69m24[arr_aux].srvespnum   
         
      
      #---------------------------------------------
       after field srvespnum                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("up")     or      
           fgl_lastkey() = fgl_keyval ("left")   then    
              next field codigo                          
        end if                                           
        
       
        	
        if ma_ctc69m24[arr_aux].srvespnum is null then
        	        		                                                                          
        	 #--------------------------------------------------------    
        	 # Abre o Popup da Especialidade                                  
        	 #--------------------------------------------------------    
        	                                                              
        	 call ctc69m04_popup(1)                                      
        	 returning ma_ctc69m24[arr_aux].srvespnum                        
        	         , ma_ctc69m24[arr_aux].srvespnom                                                                                       
        	 
        	                                                                        		                                                                               		 
        	 if ma_ctc69m24[arr_aux].srvespnum is null then 
        	    next field srvespnum 
        	 end if
        else
        	
        	                                                                                                   
        	 #--------------------------------------------------------        
        	 # Recupera a Descricao da Especialidade                               
        	 #--------------------------------------------------------        
        	                                                                  
        	 call ctc69m04_recupera_descricao(1,ma_ctc69m24[arr_aux].srvespnum) 
        	 returning ma_ctc69m24[arr_aux].srvespnom                         
        	                                                              
        	       		
 
        	if ma_ctc69m24[arr_aux].srvespnom is null then      
        	   next field srvespnum                             
        	end if                                                        
        	
        end if 
        
        display ma_ctc69m24[arr_aux].srvespnum to s_ctc69m24[scr_aux].srvespnum 
        display ma_ctc69m24[arr_aux].srvespnom to s_ctc69m24[scr_aux].srvespnom                                                                
                                     
     
        if m_operacao <> 'i' then                                                  
                                                                                   
           if ma_ctc69m24[arr_aux].srvespnum  <> lr_retorno.srvespnum then 	           
                                                                                   
                 #--------------------------------------------------------         
                 # Atualiza Associacao do De-Para                       
                 #--------------------------------------------------------         
                                                                                   
                 call ctc69m24_altera()                                            
                 next field codori                                                 
           end if                                                                  
                                                                                   
           let m_operacao = ' '                                                    
        else                                                                       
                                                                                   
           #--------------------------------------------------------
           # Gera Codigo do De-Para                           
           #--------------------------------------------------------
           call ctc69m24_gera_codigo()
           
           #--------------------------------------------------------               
           # Inclui Associacao do De-Para                                  
           #--------------------------------------------------------               
           call ctc69m24_inclui()                                                  
                                                                                   
           next field codori                                                       
        end if                                                                     
                                                                                   
        display ma_ctc69m24[arr_aux].codori     to s_ctc69m24[scr_aux].codori
        display ma_ctc69m24[arr_aux].codigo     to s_ctc69m24[scr_aux].codigo         
        display ma_ctc69m24[arr_aux].descricao  to s_ctc69m24[scr_aux].descricao   
        display ma_ctc69m24[arr_aux].subcod     to s_ctc69m24[scr_aux].subcod
        display ma_ctc69m24[arr_aux].srvespnum  to s_ctc69m24[scr_aux].srvespnum      
        display ma_ctc69m24[arr_aux].srvespnom  to s_ctc69m24[scr_aux].srvespnom     
     

               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m24[arr_aux].codori  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            #-------------------------------------------------------- 
            # Exclui Associacao do De-Para                  
            #-------------------------------------------------------- 
            
            if not ctc69m24_delete(mr_param[arr_aux].cod_depara) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
           
      
            next field codori
                                                                   	
         end if
         
         
      
  end input
  
 close window w_ctc69m24
 
 if lr_retorno.flag = 1 then
    call ctc69m24()
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc69m24_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	codigo     integer  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m24.* to null                                                    
                                                                                        
                                                                 
   open c_ctc69m24_005 using m_chave,
                             lr_param.codigo                                                   
      
   whenever error continue                                                 
   fetch c_ctc69m24_005 into  mr_ctc69m24.atldat                                       
                             ,mr_ctc69m24.funmat                                       
                                                             
                                                                                      
   whenever error stop 
   
   #--------------------------------------------------------            
   # Recupera a Descricao da Origem                                     
   #--------------------------------------------------------            
                                                                         
   call ctc69m04_recupera_descricao(18,ma_ctc69m24[arr_aux].codori)                                                                                                                                          
   returning mr_param[arr_aux].srvtipabvdes    
   
   #--------------------------------------------------------              
   # Recupera a Descricao da Sub Natureza                                      
   #--------------------------------------------------------              
                                                                          
   call ctc69m04_recupera_descricao(19,ma_ctc69m24[arr_aux].subcod)       
   returning mr_param[arr_aux].subdes       
                                                                                                                                      
   display by name  mr_ctc69m24.atldat                                           
                   ,mr_ctc69m24.funmat
                   ,mr_param[arr_aux].srvtipabvdes 
                   ,mr_param[arr_aux].subdes
                                                    
                                                                                                                                                                             
end function                                                                          
              

#==============================================                                                
 function ctc69m24_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		codigo  integer     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,""                                                            
               ,"CONFIRMA EXCLUSAO"                                                       
               ,"DO DE-PARA?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc69m24_006 using m_chave,
                                     lr_param.codigo                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o De-Para!'   
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
 function ctc69m24_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc69m24_003 using ma_ctc69m24[arr_aux].codori
                               , ma_ctc69m24[arr_aux].subcod  
                               , ma_ctc69m24[arr_aux].codigo 
                               , ma_ctc69m24[arr_aux].srvespnum                                
                               , lr_retorno.data_atual          
                               , lr_retorno.funmat         
                               , m_chave                                                
                               , mr_param[arr_aux].cod_depara
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do De-Para!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if   
    
    let m_operacao = ' '            
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc69m24_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc69m24[arr_aux].codori    using "&&" , "|", 
                            ma_ctc69m24[arr_aux].subcod    using "&&" , "|",  
                            ma_ctc69m24[arr_aux].codigo    using "&&&", "|",
                            ma_ctc69m24[arr_aux].srvespnum using "&&&"                     

    whenever error continue
    execute p_ctc69m24_004 using mr_param[arr_aux].cod_depara   
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao do De-Para!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc69m24_monta_chave()                                                         
#=============================================================================== 

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "SIE_DEPARA_ESP"

 return lr_retorno.chave 
 
end function

#---------------------------------------------------------                                                                                            
 function ctc69m24_gera_codigo()                                             
#--------------------------------------------------------- 

define lr_retorno record
	 codigo integer
end record                                      
                                                  
                                                               
   open c_ctc69m24_007 using m_chave                                                   
   whenever error continue                                                 
   fetch c_ctc69m24_007 into  lr_retorno.codigo                                                                                                                                                                 
   whenever error stop  
                                                                                                                                        
   if lr_retorno.codigo is null or
   	  lr_retorno.codigo = 0     then	  	
   	    let lr_retorno.codigo = 1
   else
   	    let lr_retorno.codigo =  lr_retorno.codigo + 1                                                                           
   end if  
   
   let mr_param[arr_aux].cod_depara = lr_retorno.codigo                              
                                                                                                                                                                              
end function 

#-------------------------------------------------#                                                                                                
function ctc69m24_recupera_especialidade(lr_param)                                             
#-------------------------------------------------# 

define lr_param  record
	    codori     integer
    , codigo     integer      
    , subcod     integer        
end record

define lr_retorno record
      srvespnum  integer   
end record


      initialize lr_retorno.* to null
      
      if m_prepare is null or
         m_prepare <> true then
         call ctc69m24_prepare()
      end if
           
      let m_chave = ctc69m24_monta_chave()                           
                                                                                                                                                                    
      #---------------------------------------------------------#                
      # CURSOR PARA TRAZER A NATUREZA DO SERVICO                #                
      #---------------------------------------------------------#                
      whenever error continue                                                    
        open c_ctc69m24_008 using m_chave           ,
                                  lr_param.codori   ,  
                                  lr_param.subcod   ,                            
                                  lr_param.codigo                                                            
                                                                                 
        fetch c_ctc69m24_008 into lr_retorno.srvespnum                             
      whenever error stop           
      
      return lr_retorno.srvespnum                                             
                                                                                  
end function                                                                                             


