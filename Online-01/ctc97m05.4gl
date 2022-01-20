#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc97m05                                                   # 
# Objetivo.......: Cadastro Plano X Natureza X Assunto                        # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 27/05/2015                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc97m05 array[500] of record
      c24astcod  like  datkassunto.c24astcod           
    , c24astdes  like  datkassunto.c24astdes              
end record
 
 
define mr_ctc97m05 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record

define mr_param   record                                      
       cod         integer  
     , descricao   char(60)             
     , grpcod      like datkresitagrp.grpcod                
     , grpdes      like datkresitagrp.desnom                
     , socntzcod   like datksocntz.socntzcod                
     , socntzdes   like datksocntz.socntzdes                
end record                                              



define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_cod_aux   like datkassunto.c24astcod

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc97m05_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpodes                  '
          ,  '  from datkdominio               '  
          ,  '  where cponom = ?               '  
          ,  '  order by cpodes                '
 prepare p_ctc97m05_001 from l_sql
 declare c_ctc97m05_001 cursor for p_ctc97m05_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpodes = ?               '
 prepare p_ctc97m05_002 from l_sql
 declare c_ctc97m05_002 cursor for p_ctc97m05_002

  
let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc97m05_004 from l_sql 	
  
 
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes  =  ?         ' 
 prepare p_ctc97m05_005    from l_sql                                             	
 declare c_ctc97m05_005 cursor for p_ctc97m05_005  
 	
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes  =  ?         '                             	                            	
 prepare p_ctc97m05_006 from l_sql  
 
 
 let l_sql = '   select max(cpocod)     '                
            ,'   from datkdominio       '    
            ,'   where cponom  =  ?     '                
 prepare p_ctc97m05_007    from l_sql             
 declare c_ctc97m05_007 cursor for p_ctc97m05_007
 	
 let l_sql = ' select count(*)                '   	
          ,  ' from datkdominio               '   	
          ,  ' where cponom = ?               '   		 
 prepare p_ctc97m05_008 from l_sql                	
 declare c_ctc97m05_008 cursor for p_ctc97m05_008 
 	
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         '                      	                            	  	                 	
 prepare p_ctc97m05_009 from l_sql                	
 

 let m_prepare = true


end function

#===============================================================================
 function ctc97m05(lr_param)
#===============================================================================

define lr_param record
     cod         integer                  
   , descricao   char(60)                 
   , grpcod      like datkresitagrp.grpcod
   , grpdes      like datkresitagrp.desnom
   , socntzcod   like datksocntz.socntzcod
   , socntzdes   like datksocntz.socntzdes
end record
 
define lr_retorno record
    flag                 smallint                               ,
    cont                 integer                                ,
    confirma             char(01) 
end record

 let mr_param.cod        = lr_param.cod        
 let mr_param.descricao  = lr_param.descricao  
 let mr_param.grpcod     = lr_param.grpcod     
 let mr_param.grpdes     = lr_param.grpdes     
 let mr_param.socntzcod  = lr_param.socntzcod  
 let mr_param.socntzdes  = lr_param.socntzdes  
 
 
 let m_chave = ctc97m05_monta_chave(mr_param.cod      ,
                                    mr_param.grpcod   ,
                                    mr_param.socntzcod) 
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc97m05[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc97m05.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc97m05_prepare()
 end if
    
 
 
 open window w_ctc97m05 at 6,2 with form 'ctc97m05'
 attribute(form line 1)
   
 message '               (F17)Abandona,(F1)Inclui,(F2)Exclui'  
  
  display by name mr_param.cod                
                , mr_param.descricao          
                , mr_param.grpcod              
                , mr_param.grpdes             
                , mr_param.socntzcod  
                , mr_param.socntzdes  
                
  #--------------------------------------------------------
  # Recupera os Dados do Natureza X Assunto           
  #-------------------------------------------------------- 
  
  open c_ctc97m05_001  using  m_chave 
  foreach c_ctc97m05_001 into ma_ctc97m05[arr_aux].c24astcod

       #--------------------------------------------------------
       # Recupera a Descricao do Assunto
       #--------------------------------------------------------
       
       call ctc69m04_recupera_descricao_7(9,ma_ctc97m05[arr_aux].c24astcod)
       returning ma_ctc97m05[arr_aux].c24astdes

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Assuntos!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc97m05 without defaults from s_ctc97m05.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc97m05[arr_aux].c24astcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc97m05[arr_aux] to null
                  
         display ma_ctc97m05[arr_aux].c24astcod   to s_ctc97m05[scr_aux].c24astcod 
       
      #---------------------------------------------
       before field c24astcod
      #---------------------------------------------
        
        if ma_ctc97m05[arr_aux].c24astcod is null then                                                   
           display ma_ctc97m05[arr_aux].c24astcod to s_ctc97m05[scr_aux].c24astcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else  
        	let m_cod_aux  = ma_ctc97m05[arr_aux].c24astcod                                                                                               
          display ma_ctc97m05[arr_aux].* to s_ctc97m05[scr_aux].* attribute(reverse)                          
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares da Natureza X Assunto          
        	 #--------------------------------------------------------
        	
           call ctc97m05_dados_alteracao(ma_ctc97m05[arr_aux].c24astcod) 
        end if 
      
      #---------------------------------------------
       after field c24astcod                   
      #---------------------------------------------
      
        if fgl_lastkey() = fgl_keyval ("down")     or    
           fgl_lastkey() = fgl_keyval ("return")   then  
        
           if m_operacao = 'i' then
           	
           	if ma_ctc97m05[arr_aux].c24astcod is null then
           		 
           		 
           		 #--------------------------------------------------------
           		 # Abre o Popup do Assunto        
           		 #--------------------------------------------------------
           		 
           		 call ctc69m04_popup(09)
           		 returning ma_ctc97m05[arr_aux].c24astcod 
           		         , ma_ctc97m05[arr_aux].c24astdes       		      
           		 
           		 if ma_ctc97m05[arr_aux].c24astcod is null then 
           		    next field c24astcod 
           		 end if
           	else
           		
           		#--------------------------------------------------------
           		# Recupera a Descricao do Assunto        
           		#--------------------------------------------------------
           		
           		call ctc69m04_recupera_descricao_7(9,ma_ctc97m05[arr_aux].c24astcod)
           		returning ma_ctc97m05[arr_aux].c24astdes  
           		
           		if ma_ctc97m05[arr_aux].c24astdes  is null then      
           		   next field c24astcod                             
           		end if                                                        
           		
             end if 
             
             
             #--------------------------------------------------------
             # Valida Se a Associacao Natureza X Assunto Ja Existe           
             #--------------------------------------------------------
             
             open c_ctc97m05_002 using m_chave, 
                                       ma_ctc97m05[arr_aux].c24astcod            
                                             
             whenever error continue                                                
             fetch c_ctc97m05_002 into lr_retorno.cont           
             whenever error stop                                                    
                                                                                    
             if lr_retorno.cont >  0   then                                          
                error " Assunto ja Cadastrado!" 
                next field c24astcod 
             end if 
             
             display ma_ctc97m05[arr_aux].c24astcod to s_ctc97m05[scr_aux].c24astcod 
             display ma_ctc97m05[arr_aux].c24astdes to s_ctc97m05[scr_aux].c24astdes                                                               
                                 
              
           else   
           	  let ma_ctc97m05[arr_aux].c24astcod = m_cod_aux         
            	display ma_ctc97m05[arr_aux].* to s_ctc97m05[scr_aux].*                                                     
           end if 
        
        else                                                               
        	 if m_operacao = 'i' then                                        
        	    let ma_ctc97m05[arr_aux].c24astcod = ''                         
        	    display ma_ctc97m05[arr_aux].* to s_ctc97m05[scr_aux].*      
        	    let m_operacao = ' '                                         
        	 else                                                            
        	    let ma_ctc97m05[arr_aux].c24astcod = m_cod_aux                  
        	    display ma_ctc97m05[arr_aux].* to s_ctc97m05[scr_aux].*      
        	 end if                                                          
        end if	                                                           
         
         if m_operacao = 'i' then 
               
            #-------------------------------------------------------- 
            # Recupera Codigo da Associacao Natureza X Assunto                  
            #--------------------------------------------------------          
            call ctc97m05_recupera_chave()          
            
            #-------------------------------------------------------- 
            # Inclui Associacao Natureza X Assunto                  
            #-------------------------------------------------------- 
            call ctc97m05_inclui()  
                    
            next field c24astcod            
         end if
         
         display ma_ctc97m05[arr_aux].c24astcod   to s_ctc97m05[scr_aux].c24astcod
         display ma_ctc97m05[arr_aux].c24astdes   to s_ctc97m05[scr_aux].c24astdes   
      
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc97m05[arr_aux].c24astcod  is null   then                    	
            continue input                                                  	
         else                                                               	
                      
            #-------------------------------------------------------- 
            # Exclui Associacao Natureza X Assunto                  
            #-------------------------------------------------------- 
            
            if not ctc97m05_delete(ma_ctc97m05[arr_aux].c24astcod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
                              
            next field c24astcod
                                                                   	
         end if                     
      
      
  end input
  
 close window w_ctc97m05
 
 if lr_retorno.flag = 1 then
    call ctc97m05(lr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc97m05_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	c24astcod like  datkassunto.c24astcod
end record
                                                                                                    
                                                                                      
   initialize mr_ctc97m05.* to null                                                    
                                                                                      
                                                               
   open c_ctc97m05_005 using m_chave,
                             lr_param.c24astcod                                                  
      
   whenever error continue                                                 
   fetch c_ctc97m05_005 into  mr_ctc97m05.atldat                                       
                             ,mr_ctc97m05.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc97m05.atldat                                           
                   ,mr_ctc97m05.funmat                                   
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc97m05_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		c24astcod like  datkassunto.c24astcod    
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE ASSUNTO ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc97m05_006 using m_chave,
                                     lr_param.c24astcod                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Assunto!'   
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
 function ctc97m05_inclui()                                             
#---------------------------------------------------------

define lr_retorno record
   data_atual date,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue
    execute p_ctc97m05_004 using mr_ctc97m05.cpocod    
                               , ma_ctc97m05[arr_aux].c24astcod
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
 function ctc97m05_recupera_chave()                                                                                                                                       
#---------------------------------------------------------                                                                                                        
                                                                                
    open c_ctc97m05_007 using m_chave                                                           
    whenever error continue                                       
    fetch c_ctc97m05_007 into mr_ctc97m05.cpocod                                                             
    whenever error stop 
    
    if mr_ctc97m05.cpocod is null or
    	 mr_ctc97m05.cpocod = ""    or
    	 mr_ctc97m05.cpocod = 0     then    	 	
    	 	let mr_ctc97m05.cpocod = 1  
    else
    	  let mr_ctc97m05.cpocod = mr_ctc97m05.cpocod + 1
    end if	                                                                                                                                
                              
end function



#===============================================================================     
 function ctc97m05_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param   record                          
       cod         integer                                         
     , grpcod      like datkresitagrp.grpcod      
     , socntzcod   like datksocntz.socntzcod      
end record   
                                     
define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "IR_NAT_", lr_param.cod        using "&&", "_", 
                                   lr_param.grpcod     using "&&&","_",
                                   lr_param.socntzcod  using "&&&"

 return lr_retorno.chave 
 
end function 

#---------------------------------------------------------                                                                                            
 function ctc97m05_valida_assunto(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	c24astcod   like datkassunto.c24astcod  ,
	cod         integer                     ,  
	grpcod      like datkresitagrp.grpcod   ,  
	socntzcod   like datksocntz.socntzcod   
end record

define lr_retorno record
	cont integer
end record

if m_prepare is null or
    m_prepare <> true then
    call ctc97m05_prepare()
end if

   initialize lr_retorno.* to null
                                                                                    
   let m_chave = ctc97m05_monta_chave(lr_param.cod      ,
                                      lr_param.grpcod   ,
                                      lr_param.socntzcod)                                           
                                                               
   open c_ctc97m05_002 using m_chave,
                             lr_param.c24astcod                                                  
      
   whenever error continue                                                 
   fetch c_ctc97m05_002 into  lr_retorno.cont                                                                                                                            
   whenever error stop  
   
   if lr_retorno.cont > 0 then
      return true                                                                                                                                  
   else
   	  return false
   end if                                                                             
                                                  
end function 

#---------------------------------------------------------                                                                                                           
 function ctc97m05_valida_plano(lr_param)                                                                                                       
#---------------------------------------------------------            
                                                                      
define lr_param   record                           
       cod         integer                         
     , grpcod      like datkresitagrp.grpcod                              
     , socntzcod   like datksocntz.socntzcod                              
end record                                                                
                                                                      
define lr_retorno record                                              
	cont integer                                                        
end record                                                            
                                                                      
if m_prepare is null or                                               
    m_prepare <> true then                                            
    call ctc97m05_prepare()                                           
end if                                                                
                                                                      
   initialize lr_retorno.* to null                                    
                                                                      
   let m_chave = ctc97m05_monta_chave(lr_param.cod      ,             
                                      lr_param.grpcod   ,             
                                      lr_param.socntzcod)             
                                                                      
   open c_ctc97m05_008 using m_chave                                                                                                     
   whenever error continue                                            
   fetch c_ctc97m05_008 into  lr_retorno.cont                         
   whenever error stop                                                
                                                                      
   if lr_retorno.cont > 0 then                                        
      return true                                                     
   else                                                               
   	  return false                                                    
   end if                                                             
                                                                      
end function  

