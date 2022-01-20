#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc92m12                                                   # 
# Objetivo.......: Cadastro Assistencia X Plano                               # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 16/04/2015      PJ                                         # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc92m12 array[500] of record
      asitipcod        like datkasitip.asitipcod          
    , asitipdes        like datkasitip.asitipdes 
    , limite           integer               
end record
 
define mr_param   record
     cod        smallint,                    
     descricao  char(60)   
end record
 
define mr_ctc92m12 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record

define m_operacao  char(1)
define m_cod_aux   like datkasitip.asitipcod  
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc92m12_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod ,               ' 
         ,  '          cpodes                 '
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by cpocod                '     
 prepare p_ctc92m12_001 from l_sql
 declare c_ctc92m12_001 cursor for p_ctc92m12_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc92m12_002 from l_sql
 declare c_ctc92m12_002 cursor for p_ctc92m12_002
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc92m12_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc92m12_005    from l_sql                                             	
 declare c_ctc92m12_005 cursor for p_ctc92m12_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc92m12_006 from l_sql
 
 
 let l_sql =  ' update datkdominio  '
           ,  ' set cpodes   = ?    ' 
           ,  ' where cponom = ?    '    
           ,  ' and   cpocod = ?    '                 
 prepare p_ctc92m12_007 from l_sql
 
 let m_prepare = true


end function

#===============================================================================
 function ctc92m12(lr_param)
#===============================================================================
 
define lr_param record
    cod        smallint,  
    descricao  char(60)  
end record
 
define lr_retorno record
    flag       smallint  ,
    cont       integer   ,                   
    confirma   char(01)  ,
    limite     integer
end record
 
 let mr_param.cod        = lr_param.cod   
 let mr_param.descricao  = lr_param.descricao   
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc92m12[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc92m12.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc92m12_prepare()
 end if
    
 let m_chave = ctc92m12_monta_chave(mr_param.cod)
 
 open window w_ctc92m12 at 6,2 with form 'ctc92m12'
 attribute(form line 1)
  
 let mr_ctc92m12.msg =  '                (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_param.cod   
                , mr_param.descricao   
                , mr_ctc92m12.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Plano X Assistencia           
  #-------------------------------------------------------- 
  
  open c_ctc92m12_001  using  m_chave                                             
  foreach c_ctc92m12_001 into ma_ctc92m12[arr_aux].asitipcod,
  	                          ma_ctc92m12[arr_aux].limite
  	                                                                                                                          
       #--------------------------------------------------------                  
       # Recupera a Descricao do Assistencia                                          
       #--------------------------------------------------------                  
                                                                                  
       call cto00m10_recupera_descricao(26,ma_ctc92m12[arr_aux].asitipcod)       
       returning ma_ctc92m12[arr_aux].asitipdes                                     
                                                                                  
       let arr_aux = arr_aux + 1                                                  
                                                                                  
       if arr_aux > 500 then                                                      
          error " Limite Excedido! Foram Encontrados Mais de 500 Assistencias!"       
          exit foreach                                                            
       end if                                                                     
                                                                                  
  end foreach                                                                     
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc92m12 without defaults from s_ctc92m12.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc92m12[arr_aux].asitipcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc92m12[arr_aux] to null
                  
         display ma_ctc92m12[arr_aux].asitipcod  to s_ctc92m12[scr_aux].asitipcod 
         display ma_ctc92m12[arr_aux].asitipdes  to s_ctc92m12[scr_aux].asitipdes
         display ma_ctc92m12[arr_aux].limite     to s_ctc92m12[scr_aux].limite
              
      #---------------------------------------------
       before field asitipcod
      #---------------------------------------------
        
        if ma_ctc92m12[arr_aux].asitipcod is null then                                                   
           display ma_ctc92m12[arr_aux].asitipcod to s_ctc92m12[scr_aux].asitipcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let m_cod_aux  = ma_ctc92m12[arr_aux].asitipcod
          display ma_ctc92m12[arr_aux].* to s_ctc92m12[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Plano X Assistencia          
        	 #--------------------------------------------------------
        	
           call ctc92m12_dados_alteracao(ma_ctc92m12[arr_aux].asitipcod) 
        end if 
      
      #---------------------------------------------
       after field asitipcod                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("down")     or   
           fgl_lastkey() = fgl_keyval ("return")   then 
        
                
            if m_operacao = 'i' then
            	
            	if ma_ctc92m12[arr_aux].asitipcod is null then
            		 
            		 if fgl_lastkey() = fgl_keyval ("down")   or         
            		    fgl_lastkey() = fgl_keyval ("return")     then   
            		 
            		 
            		    #--------------------------------------------------------
            		    # Abre o Popup do Assistencia         
            		    #--------------------------------------------------------
            		    
            		    call cto00m10_popup(26)
            		    returning ma_ctc92m12[arr_aux].asitipcod 
            		            , ma_ctc92m12[arr_aux].asitipdes
            		    
            		    if ma_ctc92m12[arr_aux].asitipcod is null then 
            		       next field asitipcod 
            		    end if   
            		 else                     
            		    let m_operacao = ' '    
            		 end if                     
            	else
            		
            		#--------------------------------------------------------
            		# Recupera a Descricao do Assistencia         
            		#--------------------------------------------------------
            		
            		call cto00m10_recupera_descricao(26,ma_ctc92m12[arr_aux].asitipcod)
            		returning ma_ctc92m12[arr_aux].asitipdes   
            		
            		if ma_ctc92m12[arr_aux].asitipdes is null then      
            		   next field asitipcod                             
            		end if                                                        
            		
              end if 
              
              
              #--------------------------------------------------------
              # Valida Se a Associacao Plano X Assistencia Ja Existe           
              #--------------------------------------------------------
              
              open c_ctc92m12_002 using m_chave,
                                        ma_ctc92m12[arr_aux].asitipcod                                                
              whenever error continue                                                
              fetch c_ctc92m12_002 into lr_retorno.cont           
              whenever error stop                                                    
                                                                                     
              if lr_retorno.cont >  0   then                                          
                 error " Assistencia ja Cadastrada Para Este Plano!!" 
                 next field asitipcod 
              end if 
              
              display ma_ctc92m12[arr_aux].asitipcod to s_ctc92m12[scr_aux].asitipcod 
              display ma_ctc92m12[arr_aux].asitipdes to s_ctc92m12[scr_aux].asitipdes                                                                
                                  
               
            else          
              let ma_ctc92m12[arr_aux].asitipcod = m_cod_aux            	
            	display ma_ctc92m12[arr_aux].* to s_ctc92m12[scr_aux].*                                                     
            end if
        else
        	 if m_operacao = 'i' then                                      
        	    let ma_ctc92m12[arr_aux].asitipcod = ''                      
        	    display ma_ctc92m12[arr_aux].* to s_ctc92m12[scr_aux].*    
        	    let m_operacao = ' '                                       
        	 else                                                          
        	    let ma_ctc92m12[arr_aux].asitipcod = m_cod_aux               
        	    display ma_ctc92m12[arr_aux].* to s_ctc92m12[scr_aux].*    
        	 end if                                                            
        end if	 
        
        
     #---------------------------------------------
      before field limite 
     #---------------------------------------------                                         
         display ma_ctc92m12[arr_aux].limite  to s_ctc92m12[scr_aux].limite  attribute(reverse)
         let lr_retorno.limite = ma_ctc92m12[arr_aux].limite
                                                                  
     #--------------------------------------------- 
      after  field limite                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field asitipcod                                     
         end if                                                     
                                                                    
         if ma_ctc92m12[arr_aux].limite  is null then                  
            error "Por Favor Informe o Limite!"           
            next field limite                                          
         end if 
         
         
                      
         if m_operacao <> 'i' then 
                        
            if ma_ctc92m12[arr_aux].limite   <> lr_retorno.limite then               
                  #--------------------------------------------------------
                  # Atualiza Associacao Assistencia X Limite         
                  #--------------------------------------------------------
                  
                  call ctc92m12_altera()
                  next field asitipcod                   
            end if
                       
            let m_operacao = ' '                           
        
         else
        
                           
            #-------------------------------------------------------- 
            # Inclui Associacao Assistencia X Plano                  
            #-------------------------------------------------------- 
            call ctc92m12_inclui()    
            
            next field asitipcod            
         
         end if
         
         display ma_ctc92m12[arr_aux].asitipcod  to s_ctc92m12[scr_aux].asitipcod
         display ma_ctc92m12[arr_aux].asitipdes  to s_ctc92m12[scr_aux].asitipdes
         display ma_ctc92m12[arr_aux].limite     to s_ctc92m12[scr_aux].limite
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc92m12[arr_aux].asitipcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
            
             #-------------------------------------------------------- 
             # Exclui Associacao Assistencia X Plano                  
             #-------------------------------------------------------- 
             
             if not ctc92m12_delete(ma_ctc92m12[arr_aux].asitipcod) then       	
                 let lr_retorno.flag = 1                                              	
                 exit input                                                  	
             end if   
             
             
             next field asitipcod
                                                                              	
         end if
         
    
         
      
  end input
  
 close window w_ctc92m12
 
 if lr_retorno.flag = 1 then
    call ctc92m12(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc92m12_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	asitipcod     integer 
end record
                                                                                                    
                                                                                      
   initialize mr_ctc92m12.* to null                                                    
                                                                                      
                                                               
   open c_ctc92m12_005 using m_chave,
                             lr_param.asitipcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc92m12_005 into  mr_ctc92m12.atldat                                       
                             ,mr_ctc92m12.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc92m12.atldat                                           
                   ,mr_ctc92m12.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc92m12_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		asitipcod     integer    
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DA ASSISTENCIA?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc92m12_006 using m_chave,
                                     lr_param.asitipcod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Assistencia!'   
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
 function ctc92m12_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc92m12[arr_aux].limite                     

    whenever error continue
    execute p_ctc92m12_004 using ma_ctc92m12[arr_aux].asitipcod   
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Assistencia!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc92m12_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    cod     smallint  
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "ITA_PLA_AST_", lr_param.cod using "&&&&" 

 return lr_retorno.chave 
 
end function 

#---------------------------------------------------------                 
 function ctc92m12_altera()                                                
#---------------------------------------------------------                 
                                                                           
define lr_retorno record                                                   
   data_atual date,                                                        
   funmat     like isskfunc.funmat                                         
end record	                                                               
                                                                           
initialize lr_retorno.* to null                                            
                                                                           
    let lr_retorno.data_atual = today                                      
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"               
                                                                           
    whenever error continue                                                
    execute p_ctc92m12_007 using ma_ctc92m12[arr_aux].limite                  
                               , m_chave                                   
                               , ma_ctc92m12[arr_aux].asitipcod              
    whenever error continue                                                
                                                                           
    if sqlca.sqlcode <> 0 then                                             
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Limite!'            
    else                                                                   
    	  error 'Dados Alterados com Sucesso!'                               
    end if                                                                 
                                                                           
    let m_operacao = ' '                                                   
                                                                           
end function                                                               
