#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc92m10                                                   # 
# Objetivo.......: Cadastro Problema X Plano                                  # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 13/04/2015  PJ                                             # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc92m10 array[500] of record
      c24pbmgrpcod     like datkpbmgrp.c24pbmgrpcod          
    , c24pbmgrpdes     like datkpbmgrp.c24pbmgrpdes 
    , limite           integer               
end record
 
define mr_param   record
     cod        smallint,                    
     descricao  char(60)   
end record
 
define mr_ctc92m10 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record

define m_operacao  char(1)
define m_cod_aux   like datkpbmgrp.c24pbmgrpcod  
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc92m10_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod ,               ' 
         ,  '          cpodes                 '
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by cpocod                '     
 prepare p_ctc92m10_001 from l_sql
 declare c_ctc92m10_001 cursor for p_ctc92m10_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc92m10_002 from l_sql
 declare c_ctc92m10_002 cursor for p_ctc92m10_002
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc92m10_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc92m10_005    from l_sql                                             	
 declare c_ctc92m10_005 cursor for p_ctc92m10_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc92m10_006 from l_sql
 
 
 let l_sql =  ' update datkdominio  '
           ,  ' set cpodes   = ?    ' 
           ,  ' where cponom = ?    '    
           ,  ' and   cpocod = ?    '                 
 prepare p_ctc92m10_007 from l_sql
 
 let m_prepare = true


end function

#===============================================================================
 function ctc92m10(lr_param)
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
    initialize  ma_ctc92m10[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc92m10.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc92m10_prepare()
 end if
    
 let m_chave = ctc92m10_monta_chave(mr_param.cod)
 
 open window w_ctc92m10 at 6,2 with form 'ctc92m10'
 attribute(form line 1)
  
 let mr_ctc92m10.msg =  '                (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_param.cod   
                , mr_param.descricao   
                , mr_ctc92m10.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Plano X Problema           
  #-------------------------------------------------------- 
  
  open c_ctc92m10_001  using  m_chave                                             
  foreach c_ctc92m10_001 into ma_ctc92m10[arr_aux].c24pbmgrpcod,
  	                          ma_ctc92m10[arr_aux].limite
  	                                                                                                                          
       #--------------------------------------------------------                  
       # Recupera a Descricao do Problema                                          
       #--------------------------------------------------------                  
                                                                                  
       call cto00m10_recupera_descricao(25,ma_ctc92m10[arr_aux].c24pbmgrpcod)       
       returning ma_ctc92m10[arr_aux].c24pbmgrpdes                                     
                                                                                  
       let arr_aux = arr_aux + 1                                                  
                                                                                  
       if arr_aux > 500 then                                                      
          error " Limite Excedido! Foram Encontrados Mais de 500 Problemas!"       
          exit foreach                                                            
       end if                                                                     
                                                                                  
  end foreach                                                                     
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc92m10 without defaults from s_ctc92m10.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc92m10[arr_aux].c24pbmgrpcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc92m10[arr_aux] to null
                  
         display ma_ctc92m10[arr_aux].c24pbmgrpcod  to s_ctc92m10[scr_aux].c24pbmgrpcod 
         display ma_ctc92m10[arr_aux].c24pbmgrpdes  to s_ctc92m10[scr_aux].c24pbmgrpdes
         display ma_ctc92m10[arr_aux].limite        to s_ctc92m10[scr_aux].limite
              
      #---------------------------------------------
       before field c24pbmgrpcod
      #---------------------------------------------
        
        if ma_ctc92m10[arr_aux].c24pbmgrpcod is null then                                                   
           display ma_ctc92m10[arr_aux].c24pbmgrpcod to s_ctc92m10[scr_aux].c24pbmgrpcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let m_cod_aux  = ma_ctc92m10[arr_aux].c24pbmgrpcod
          display ma_ctc92m10[arr_aux].* to s_ctc92m10[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Plano X Problema          
        	 #--------------------------------------------------------
        	
           call ctc92m10_dados_alteracao(ma_ctc92m10[arr_aux].c24pbmgrpcod) 
        end if 
      
      #---------------------------------------------
       after field c24pbmgrpcod                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("down")     or   
           fgl_lastkey() = fgl_keyval ("return")   then 
        
                
            if m_operacao = 'i' then
            	
            	if ma_ctc92m10[arr_aux].c24pbmgrpcod is null then
            		 
            		 if fgl_lastkey() = fgl_keyval ("down")   or         
            		    fgl_lastkey() = fgl_keyval ("return")     then   
            		 
            		 
            		    #--------------------------------------------------------
            		    # Abre o Popup do Problema         
            		    #--------------------------------------------------------
            		    
            		    call cto00m10_popup(25)
            		    returning ma_ctc92m10[arr_aux].c24pbmgrpcod 
            		            , ma_ctc92m10[arr_aux].c24pbmgrpdes
            		    
            		    if ma_ctc92m10[arr_aux].c24pbmgrpcod is null then 
            		       next field c24pbmgrpcod 
            		    end if   
            		 else                     
            		    let m_operacao = ' '    
            		 end if                     
            	else
            		
            		#--------------------------------------------------------
            		# Recupera a Descricao do Problema         
            		#--------------------------------------------------------
            		
            		call cto00m10_recupera_descricao(25,ma_ctc92m10[arr_aux].c24pbmgrpcod)
            		returning ma_ctc92m10[arr_aux].c24pbmgrpdes   
            		
            		if ma_ctc92m10[arr_aux].c24pbmgrpdes is null then      
            		   next field c24pbmgrpcod                             
            		end if                                                        
            		
              end if 
              
              
              #--------------------------------------------------------
              # Valida Se a Associacao Plano X Problema Ja Existe           
              #--------------------------------------------------------
              
              open c_ctc92m10_002 using m_chave,
                                        ma_ctc92m10[arr_aux].c24pbmgrpcod                                                
              whenever error continue                                                
              fetch c_ctc92m10_002 into lr_retorno.cont           
              whenever error stop                                                    
                                                                                     
              if lr_retorno.cont >  0   then                                          
                 error " Problema ja Cadastrada Para Este Plano!!" 
                 next field c24pbmgrpcod 
              end if 
              
              display ma_ctc92m10[arr_aux].c24pbmgrpcod to s_ctc92m10[scr_aux].c24pbmgrpcod 
              display ma_ctc92m10[arr_aux].c24pbmgrpdes to s_ctc92m10[scr_aux].c24pbmgrpdes                                                                
                                  
               
            else          
              let ma_ctc92m10[arr_aux].c24pbmgrpcod = m_cod_aux            	
            	display ma_ctc92m10[arr_aux].* to s_ctc92m10[scr_aux].*                                                     
            end if
        else
        	 if m_operacao = 'i' then                                      
        	    let ma_ctc92m10[arr_aux].c24pbmgrpcod = ''                      
        	    display ma_ctc92m10[arr_aux].* to s_ctc92m10[scr_aux].*    
        	    let m_operacao = ' '                                       
        	 else                                                          
        	    let ma_ctc92m10[arr_aux].c24pbmgrpcod = m_cod_aux               
        	    display ma_ctc92m10[arr_aux].* to s_ctc92m10[scr_aux].*    
        	 end if                                                            
        end if	 
        
        
     #---------------------------------------------
      before field limite 
     #---------------------------------------------                                         
         display ma_ctc92m10[arr_aux].limite  to s_ctc92m10[scr_aux].limite  attribute(reverse)
         let lr_retorno.limite = ma_ctc92m10[arr_aux].limite
                                                                  
     #--------------------------------------------- 
      after  field limite                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field c24pbmgrpcod                                     
         end if                                                     
                                                                    
         if ma_ctc92m10[arr_aux].limite  is null then                  
            error "Por Favor Informe o Limite!"           
            next field limite                                          
         end if 
         
         
                      
         if m_operacao <> 'i' then 
                        
            if ma_ctc92m10[arr_aux].limite   <> lr_retorno.limite then               
                  #--------------------------------------------------------
                  # Atualiza Associacao Problema X Limite         
                  #--------------------------------------------------------
                  
                  call ctc92m10_altera()
                  next field c24pbmgrpcod                   
            end if
                       
            let m_operacao = ' '                           
        
         else
        
                           
            #-------------------------------------------------------- 
            # Inclui Associacao Problema X Plano                  
            #-------------------------------------------------------- 
            call ctc92m10_inclui()    
            
            next field c24pbmgrpcod            
         
         end if
         
         display ma_ctc92m10[arr_aux].c24pbmgrpcod  to s_ctc92m10[scr_aux].c24pbmgrpcod
         display ma_ctc92m10[arr_aux].c24pbmgrpdes  to s_ctc92m10[scr_aux].c24pbmgrpdes
         display ma_ctc92m10[arr_aux].limite        to s_ctc92m10[scr_aux].limite
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc92m10[arr_aux].c24pbmgrpcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
            
             #-------------------------------------------------------- 
             # Exclui Associacao Problema X Plano                  
             #-------------------------------------------------------- 
             
             if not ctc92m10_delete(ma_ctc92m10[arr_aux].c24pbmgrpcod) then       	
                 let lr_retorno.flag = 1                                              	
                 exit input                                                  	
             end if   
             
             
             next field c24pbmgrpcod
                                                                              	
         end if
         
    
         
      
  end input
  
 close window w_ctc92m10
 
 if lr_retorno.flag = 1 then
    call ctc92m10(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc92m10_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	c24pbmgrpcod     integer 
end record
                                                                                                    
                                                                                      
   initialize mr_ctc92m10.* to null                                                    
                                                                                      
                                                               
   open c_ctc92m10_005 using m_chave,
                             lr_param.c24pbmgrpcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc92m10_005 into  mr_ctc92m10.atldat                                       
                             ,mr_ctc92m10.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc92m10.atldat                                           
                   ,mr_ctc92m10.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc92m10_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		c24pbmgrpcod     integer    
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DO PROBLEMA?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc92m10_006 using m_chave,
                                     lr_param.c24pbmgrpcod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Problema!'   
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
 function ctc92m10_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc92m10[arr_aux].limite                     

    whenever error continue
    execute p_ctc92m10_004 using ma_ctc92m10[arr_aux].c24pbmgrpcod   
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Problema!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc92m10_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    cod     smallint  
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "ITA_PLA_PRO_", lr_param.cod using "&&&&" 

 return lr_retorno.chave 
 
end function 

#---------------------------------------------------------                 
 function ctc92m10_altera()                                                
#---------------------------------------------------------                 
                                                                           
define lr_retorno record                                                   
   data_atual date,                                                        
   funmat     like isskfunc.funmat                                         
end record	                                                               
                                                                           
initialize lr_retorno.* to null                                            
                                                                           
    let lr_retorno.data_atual = today                                      
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"               
                                                                           
    whenever error continue                                                
    execute p_ctc92m10_007 using ma_ctc92m10[arr_aux].limite                  
                               , m_chave                                   
                               , ma_ctc92m10[arr_aux].c24pbmgrpcod              
    whenever error continue                                                
                                                                           
    if sqlca.sqlcode <> 0 then                                             
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Limite!'            
    else                                                                   
    	  error 'Dados Alterados com Sucesso!'                               
    end if                                                                 
                                                                           
    let m_operacao = ' '                                                   
                                                                           
end function                                                               
