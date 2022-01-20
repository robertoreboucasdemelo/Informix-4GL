#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc69m25                                                   # 
# Objetivo.......: De-Para Pacote                                             # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 16/01/2015                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m25 array[500] of record
	    codori     integer
    , c24astcod  char(3)      
    , c24astdes  char(50) 
    , codpac     integer          
    , despac     char(50)       
end record
 
 
define mr_ctc69m25 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record

define mr_param array[500] of record
	    cod_depara     integer ,
      paclim         integer ,  	    
      pacuni         char(60), 	    
	    srvtipabvdes   like datksrvtip.srvtipabvdes      
end record

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc69m25_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod,                '
         ,  '          cpodes[01,02],         '
         ,  '          cpodes[04,06],         ' 
         ,  '          cpodes[08,10]          '    
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by 2,3,4                 '    
 prepare p_ctc69m25_001 from l_sql
 declare c_ctc69m25_001 cursor for p_ctc69m25_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpodes[01,02] = ?        '
          ,  ' and   cpodes[04,06] = ?        '  
          ,  ' and   cpocod <> ?              '  
 prepare p_ctc69m25_002 from l_sql
 declare c_ctc69m25_002 cursor for p_ctc69m25_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[01,02]    = ? , '  
           ,  '         cpodes[04,06]    = ? , '    
           ,  '         cpodes[08,10]    = ? , '    
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '    
           ,  ' and   cpocod = ?               '                 
 prepare p_ctc69m25_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m25_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc69m25_005    from l_sql                                             	
 declare c_ctc69m25_005 cursor for p_ctc69m25_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc69m25_006 from l_sql
 
 
 let l_sql = ' select max(cpocod)             '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
 prepare p_ctc69m25_007 from l_sql
 declare c_ctc69m25_007 cursor for p_ctc69m25_007
 	
 let l_sql = ' select count(*)                '   	
          ,  ' from datkdominio               '   	
          ,  ' where cponom = ?               '   	
          ,  ' and   cpodes[08,10] = ?        ' 
          ,  ' and   cpocod <> ?              '     	
 prepare p_ctc69m25_008 from l_sql                	
 declare c_ctc69m25_008 cursor for p_ctc69m25_008 
 	
 let m_prepare = true


end function

#===============================================================================
 function ctc69m25()
#===============================================================================
 

define lr_retorno record
    flag       smallint               ,
    cont       integer                ,
    codpac     integer                ,
    cod_depara integer                ,
    confirma   char(01)               ,
    empcod     like datkplncls.empcod ,    
    ramcod     like datkplncls.ramcod ,
    codori     integer              
end record
 
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc69m25[arr_aux].*, mr_param[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc69m25.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m25_prepare()
 end if
    
 let m_chave = ctc69m25_monta_chave()
 
 let lr_retorno.empcod = 1
 let lr_retorno.ramcod = 531
 
 open window w_ctc69m25 at 6,2 with form 'ctc69m25'
 attribute(form line 1) 

 message 'Aguarde, Pesquisando Pacotes...' 
 
 if not ctc69m07_pesquisa_xml(lr_retorno.empcod,1,lr_retorno.ramcod) then
 	  error "Erro ao Consultar os Pacotes!!" sleep 5
 	  
 	  close window w_ctc69m25 
 	  return                  
 	  
 end if 
 
  
 let mr_ctc69m25.msg =  '                    (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_ctc69m25.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do De-Para Pacote          
  #-------------------------------------------------------- 
  
  open c_ctc69m25_001  using  m_chave                                             
  foreach c_ctc69m25_001 into mr_param[arr_aux].cod_depara    ,
  	                          ma_ctc69m25[arr_aux].codori     ,
  	                          ma_ctc69m25[arr_aux].c24astcod  ,
  	                          ma_ctc69m25[arr_aux].codpac  
                                                                                   
                               
             
        #--------------------------------------------------------       
        # Recupera a Descricao do Assunto                              
        #--------------------------------------------------------       
                                                                        
        call ctc69m04_recupera_descricao_7(9,ma_ctc69m25[arr_aux].c24astcod)          
        returning ma_ctc69m25[arr_aux].c24astdes                              
                   
  
           
       #--------------------------------------------------------           
       # Recupera a Descricao do Pacote                                  
       #--------------------------------------------------------           
                                                                           
       call ctc69m03_recupera_descricao(ma_ctc69m25[arr_aux].codpac)    
       returning ma_ctc69m25[arr_aux].despac,
                 mr_param[arr_aux].paclim   ,                           
                 mr_param[arr_aux].pacuni
                                                                                                                                                  
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

 input array ma_ctc69m25 without defaults from s_ctc69m25.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m25[arr_aux].codori is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m25[arr_aux] to null
                  
         display ma_ctc69m25[arr_aux].codori     to s_ctc69m25[scr_aux].codori  
         display ma_ctc69m25[arr_aux].c24astcod  to s_ctc69m25[scr_aux].c24astcod 
         display ma_ctc69m25[arr_aux].c24astdes  to s_ctc69m25[scr_aux].c24astdes
         display ma_ctc69m25[arr_aux].codpac     to s_ctc69m25[scr_aux].codpac 
         display ma_ctc69m25[arr_aux].despac     to s_ctc69m25[scr_aux].despac                         

      #---------------------------------------------                                         
       before field codori                                                                    
      #---------------------------------------------                                          
                                                                                              
        if mr_param[arr_aux].cod_depara is null then
        	 let lr_retorno.cod_depara = 0
        else
        	 let lr_retorno.cod_depara = mr_param[arr_aux].cod_depara
        end if
        
        if ma_ctc69m25[arr_aux].codori is null then                                           
           display ma_ctc69m25[arr_aux].codori to s_ctc69m25[scr_aux].codori attribute(reverse) 
           let m_operacao = 'i'                                                               
        else                                                                                  
          let lr_retorno.codori = ma_ctc69m25[arr_aux].codori
          display ma_ctc69m25[arr_aux].* to s_ctc69m25[scr_aux].* attribute(reverse)          
        end if                                                                                
                                                                                              
                                                                                              
        if m_operacao <> 'i' then                                                             
        	                                                                                    
        	 #--------------------------------------------------------                          
        	 # Recupera os Dados Complementares do De-Para                           
        	 #--------------------------------------------------------                          
        	                                                                                    
           call ctc69m25_dados_alteracao(mr_param[arr_aux].cod_depara)                         
        end if                                                                                
                                                                                              
      #---------------------------------------------                                          
       after field codori                                                                     
      #---------------------------------------------                                          
                                                                                              
        if fgl_lastkey() = fgl_keyval ("down")     or  
           fgl_lastkey() = fgl_keyval ("return")   then
        
              
           if m_operacao = 'i' then                                                              
           	                                                                                    
           	if ma_ctc69m25[arr_aux].codori is null then                                         
           		                                                                                  
           		                                                                                  
           		 #--------------------------------------------------------                        
           		 # Abre o Popup da Origem                                                       
           		 #--------------------------------------------------------                        
           		                                                                                  
           		 call ctc69m04_popup(18)                                                          
           		 returning ma_ctc69m25[arr_aux].codori   ,
           		           mr_param[arr_aux].srvtipabvdes                                           
           		                                              
           		                                                                                  
           		 if ma_ctc69m25[arr_aux].codori is null then                                      
           		    next field codori                                                             
           		 end if                                                                           
                 
             end if                                                                             
                                                                                                                                               
                                                                                                
             display ma_ctc69m25[arr_aux].codori to s_ctc69m25[scr_aux].codori                                                                                                       
                                                                                                
           else
           	 let ma_ctc69m25[arr_aux].codori = lr_retorno.codori                                                                                  
             display ma_ctc69m25[arr_aux].* to s_ctc69m25[scr_aux].*                            
           end if                                                                              
        else                                                            
         	  if m_operacao = 'i' then                                    
         	     let ma_ctc69m25[arr_aux].codori = ''                     
         	     display ma_ctc69m25[arr_aux].* to s_ctc69m25[scr_aux].*  
         	     let m_operacao = ' '                                     
         	  else                                                        
         	     let ma_ctc69m25[arr_aux].codori = lr_retorno.codori      
         	     display ma_ctc69m25[arr_aux].* to s_ctc69m25[scr_aux].*  
         	  end if                                                      
        end if	                                                         
                                                                                                  
      
      #---------------------------------------------
       before field c24astcod
      #---------------------------------------------
                                                     
         display ma_ctc69m25[arr_aux].c24astcod to s_ctc69m25[scr_aux].c24astcod attribute(reverse)  
         
      
      #---------------------------------------------
       after field c24astcod                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("up")     or                
           fgl_lastkey() = fgl_keyval ("left")   then              
              next field codori                                    
        end if                           
  
             	
        if ma_ctc69m25[arr_aux].c24astcod is null then
        	 
  	                                                                          
        	#--------------------------------------------------------    
        	# Abre o Popup do Assunto                                  
        	#--------------------------------------------------------    
        	                                                             
        	call ctc69m04_popup(9)                                      
        	returning ma_ctc69m25[arr_aux].c24astcod                        
        	        , ma_ctc69m25[arr_aux].c24astdes                                                                                       
        	      	                                                                          
        	 
        	 if ma_ctc69m25[arr_aux].c24astcod is null then 
        	    next field c24astcod 
        	 end if
        else       	                                                   
        	                                                                      
          #--------------------------------------------------------        
          # Recupera a Descricao do Assunto                                
          #--------------------------------------------------------        
                                                                           
          call ctc69m04_recupera_descricao_7(9,ma_ctc69m25[arr_aux].c24astcod) 
          returning ma_ctc69m25[arr_aux].c24astdes                         
        	      
        	           
        	if ma_ctc69m25[arr_aux].c24astdes is null then      
        	   next field c24astcod                             
        	end if                                                        
        		
         end if 
          
          
         #--------------------------------------------------------
         # Valida Se a Associacao do De-Para Ja Existe           
         #--------------------------------------------------------
         
         open c_ctc69m25_002 using m_chave                        ,
                                   ma_ctc69m25[arr_aux].codori    ,
                                   ma_ctc69m25[arr_aux].c24astcod ,
                                   lr_retorno.cod_depara                                                
         whenever error continue                                                
         fetch c_ctc69m25_002 into lr_retorno.cont           
         whenever error stop                                                    
                                                                                
         if lr_retorno.cont >  0   then                                          
            error " De-Para ja Cadastrado para esse Assunto" 
            next field c24astcod 
         end if 
         
         display ma_ctc69m25[arr_aux].c24astcod to s_ctc69m25[scr_aux].c24astcod 
         display ma_ctc69m25[arr_aux].c24astdes to s_ctc69m25[scr_aux].c24astdes                                                                
                              
        
        
        
      #---------------------------------------------
       before field codpac
      #---------------------------------------------
                                                     
         display ma_ctc69m25[arr_aux].codpac to s_ctc69m25[scr_aux].codpac attribute(reverse)
         let lr_retorno.codpac = ma_ctc69m25[arr_aux].codpac   
         
      
      #---------------------------------------------
       after field codpac                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("up")     or      
           fgl_lastkey() = fgl_keyval ("left")   then    
              next field c24astcod                          
        end if                                           
        
       
        	
        if ma_ctc69m25[arr_aux].codpac is null then
        	        		                                                                          
        	 #--------------------------------------------------------    
        	 # Abre o Popup do Pacote                                
        	 #--------------------------------------------------------    
        	                                                              
        	 call ctc69m03_popup()                                       
        	 returning ma_ctc69m25[arr_aux].codpac                        
        	         , ma_ctc69m25[arr_aux].despac 
        	         , mr_param[arr_aux].paclim                                                                                       
        	         , mr_param[arr_aux].pacuni 
        	                                                                        		                                                                               		 
        	 if ma_ctc69m25[arr_aux].codpac is null then 
        	    next field codpac 
        	 end if
        else
        	
        	                                                                                                   
        	 #--------------------------------------------------------        
        	 # Recupera a Descricao do Pacote                               
        	 #--------------------------------------------------------        
        	                                                                  
        	 call ctc69m03_recupera_descricao(ma_ctc69m25[arr_aux].codpac) 
        	 returning ma_ctc69m25[arr_aux].despac,                       
        	           mr_param[arr_aux].paclim   ,                                                                                    
        	           mr_param[arr_aux].pacuni                                 		
 
        	 if ma_ctc69m25[arr_aux].despac is null then      
        	    next field codpac                             
        	 end if                                                        
        	
        end if 
        
        
        #--------------------------------------------------------
        # Valida Se a Associacao do De-Para Ja Existe           
        #--------------------------------------------------------
        
        open c_ctc69m25_008 using m_chave                     ,
                                  ma_ctc69m25[arr_aux].codpac ,
                                  lr_retorno.cod_depara 
                                                                              
        whenever error continue                                                
        fetch c_ctc69m25_008 into lr_retorno.cont           
        whenever error stop                                                    
                                                                               
        if lr_retorno.cont >  0   then                                          
           error " De-Para ja Cadastrado para esse Pacote" 
           next field codpac 
        end if 
        
        display ma_ctc69m25[arr_aux].codpac to s_ctc69m25[scr_aux].codpac 
        display ma_ctc69m25[arr_aux].despac to s_ctc69m25[scr_aux].despac                                                                
                                     
     
        if m_operacao <> 'i' then                                                  
                                                                                   
           if ma_ctc69m25[arr_aux].codpac  <> lr_retorno.codpac then 	           
                                                                                   
                 #--------------------------------------------------------         
                 # Atualiza Associacao do De-Para                       
                 #--------------------------------------------------------         
                                                                                   
                 call ctc69m25_altera()                                            
                 next field codori                                                 
           end if                                                                  
                                                                                   
           let m_operacao = ' '                                                    
        else                                                                       
                                                                                   
           #--------------------------------------------------------
           # Gera Codigo do De-Para                           
           #--------------------------------------------------------
           call ctc69m25_gera_codigo()
           
           #--------------------------------------------------------               
           # Inclui Associacao do De-Para                                  
           #--------------------------------------------------------               
           call ctc69m25_inclui()                                                  
                                                                                   
           next field codori                                                       
        end if                                                                     
                                                                                   
        display ma_ctc69m25[arr_aux].codori     to s_ctc69m25[scr_aux].codori
        display ma_ctc69m25[arr_aux].c24astcod  to s_ctc69m25[scr_aux].c24astcod         
        display ma_ctc69m25[arr_aux].c24astdes  to s_ctc69m25[scr_aux].c24astdes   
        display ma_ctc69m25[arr_aux].codpac     to s_ctc69m25[scr_aux].codpac      
        display ma_ctc69m25[arr_aux].despac     to s_ctc69m25[scr_aux].despac     
     

               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m25[arr_aux].codori  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            #-------------------------------------------------------- 
            # Exclui Associacao do De-Para                  
            #-------------------------------------------------------- 
            
            if not ctc69m25_delete(mr_param[arr_aux].cod_depara) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
           
      
            next field codori
                                                                   	
         end if
         
         
      
  end input
  
 close window w_ctc69m25
 
 if lr_retorno.flag = 1 then
    call ctc69m25()
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc69m25_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	c24astcod     integer  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m25.* to null                                                    
                                                                                      
                                                               
   open c_ctc69m25_005 using m_chave,
                             lr_param.c24astcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc69m25_005 into  mr_ctc69m25.atldat                                       
                             ,mr_ctc69m25.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc69m25.atldat                                           
                   ,mr_ctc69m25.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc69m25_delete(lr_param)                                                               
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
        execute p_ctc69m25_006 using m_chave,
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
 function ctc69m25_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc69m25_003 using ma_ctc69m25[arr_aux].codori
                               , ma_ctc69m25[arr_aux].c24astcod 
                               , ma_ctc69m25[arr_aux].codpac                                
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
 function ctc69m25_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc69m25[arr_aux].codori       using "&&" , "|", 
                            ma_ctc69m25[arr_aux].c24astcod    clipped    , "|",
                            ma_ctc69m25[arr_aux].codpac       using "&&&"                     

    whenever error continue
    execute p_ctc69m25_004 using mr_param[arr_aux].cod_depara   
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
 function ctc69m25_monta_chave()                                                         
#=============================================================================== 

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "SIE_DEPARA_PAC"

 return lr_retorno.chave 
 
end function

#---------------------------------------------------------                                                                                            
 function ctc69m25_gera_codigo()                                             
#--------------------------------------------------------- 

define lr_retorno record
	 codigo integer
end record                                      
                                                  
                                                               
   open c_ctc69m25_007 using m_chave                                                   
   whenever error continue                                                 
   fetch c_ctc69m25_007 into  lr_retorno.codigo                                                                                                                                                                 
   whenever error stop  
                                                                                                                                        
   if lr_retorno.codigo is null or
   	  lr_retorno.codigo = 0     then	  	
   	    let lr_retorno.codigo = 1
   else
   	    let lr_retorno.codigo =  lr_retorno.codigo + 1                                                                           
   end if  
   
   let mr_param[arr_aux].cod_depara = lr_retorno.codigo                             
                                                                                                                                                                              
end function 

