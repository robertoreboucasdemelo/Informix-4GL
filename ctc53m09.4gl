#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m09                                                   # 
# Objetivo.......: Cadastro KM X Assunto                                      # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 03/04/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m09 array[500] of record
      clscod        like aackcls.clscod            
    , clsdes        like aackcls.clsdes             
    , limite        integer
    , atende        char(01)
end record
 
define mr_param   record
     codper     smallint,                    
     desper     char(60),                    
     c24astcod  like  datkassunto.c24astcod, 
     c24astdes  like  datkassunto.c24astdes      
end record
 
define mr_ctc53m09 record
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
 function ctc53m09_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpodes[01,03],         ' 
         ,  '          cpodes[05,05],         ' 
         ,  '          cpodes[07,10]          '            
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by cpodes                '     
 prepare p_ctc53m09_001 from l_sql
 declare c_ctc53m09_001 cursor for p_ctc53m09_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpodes[01,03] = ?        '
 prepare p_ctc53m09_002 from l_sql
 declare c_ctc53m09_002 cursor for p_ctc53m09_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[05,05]    = ? , ' 
           ,  '         cpodes[07,10]    = ? , ' 
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '    
           ,  ' and   cpodes[01,03] = ?        '                 
 prepare p_ctc53m09_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m09_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes[01,03]  =  ?  '  
 prepare p_ctc53m09_005    from l_sql                                             	
 declare c_ctc53m09_005 cursor for p_ctc53m09_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes[01,03]  =  ?  '                             	                            	
 prepare p_ctc53m09_006 from l_sql 
 
 let l_sql = '   select max(cpocod)     '         
            ,'   from datkdominio       '         
            ,'   where cponom  =  ?     '         
 prepare p_ctc53m09_007    from l_sql             
 declare c_ctc53m09_007 cursor for p_ctc53m09_007
 	
 let l_sql = ' select count(*)                '  
          ,  ' from datkdominio               '  	
          ,  ' where cponom = ?               '  	
 prepare p_ctc53m09_008 from l_sql               	
 declare c_ctc53m09_008 cursor for p_ctc53m09_008	

 let m_prepare = true


end function

#===============================================================================
 function ctc53m09(lr_param)
#===============================================================================
 
define lr_param record
    codper     smallint,  
    desper     char(60),   
    c24astcod  like  datkassunto.c24astcod, 
    c24astdes  like  datkassunto.c24astdes       
end record
 
define lr_retorno record
    flag       smallint                     ,
    cont       integer                      ,
    limite     integer                      ,
    atende     char(01)                     ,
    confirma   char(01) 
end record
 
 let mr_param.codper     = lr_param.codper   
 let mr_param.desper     = lr_param.desper   
 let mr_param.c24astcod  = lr_param.c24astcod
 let mr_param.c24astdes  = lr_param.c24astdes
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc53m09[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc53m09.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m09_prepare()
 end if
    
 let m_chave = ctc53m09_monta_chave(mr_param.codper, mr_param.c24astcod)
 
 open window w_ctc53m09 at 6,2 with form 'ctc53m09'
 attribute(form line 1)
  
 let mr_ctc53m09.msg =  '    (F17)Abandona,(F1)Inclui,(F2)Exclui,(F6)Tipo Assistencia,(F7)Alertas' 
   
  display by name mr_param.codper   
                , mr_param.desper   
                , mr_param.c24astcod
                , mr_param.c24astdes
                , mr_ctc53m09.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Assunto X KM          
  #-------------------------------------------------------- 
  
  open c_ctc53m09_001  using  m_chave                                             
  foreach c_ctc53m09_001 into ma_ctc53m09[arr_aux].clscod   ,
  	                          ma_ctc53m09[arr_aux].atende   ,
                              ma_ctc53m09[arr_aux].limite                                                       
       
       #--------------------------------------------------------                  
       # Recupera a Descricao da Clausula                                         
       #--------------------------------------------------------                  
                                                                                  
       call ctc69m04_recupera_descricao_6(11,ma_ctc53m09[arr_aux].clscod,531)       
       returning ma_ctc53m09[arr_aux].clsdes                                     
                                                                                  
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

 input array ma_ctc53m09 without defaults from s_ctc53m09.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m09[arr_aux].clscod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc53m09[arr_aux] to null
                  
         display ma_ctc53m09[arr_aux].clscod    to s_ctc53m09[scr_aux].clscod 
         display ma_ctc53m09[arr_aux].clsdes    to s_ctc53m09[scr_aux].clsdes
         display ma_ctc53m09[arr_aux].limite    to s_ctc53m09[scr_aux].limite
         display ma_ctc53m09[arr_aux].atende    to s_ctc53m09[scr_aux].atende                     

              
      #---------------------------------------------
       before field clscod
      #---------------------------------------------
        
        if ma_ctc53m09[arr_aux].clscod is null then                                                   
           display ma_ctc53m09[arr_aux].clscod to s_ctc53m09[scr_aux].clscod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc53m09[arr_aux].* to s_ctc53m09[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Assunto X KM        
        	 #--------------------------------------------------------
        	
           call ctc53m09_dados_alteracao(ma_ctc53m09[arr_aux].clscod) 
        end if 
      
      #---------------------------------------------
       after field clscod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc53m09[arr_aux].clscod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup da Clausula          
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup_2(11,531)
        		 returning ma_ctc53m09[arr_aux].clscod 
        		         , ma_ctc53m09[arr_aux].clsdes
        		 
        		 if ma_ctc53m09[arr_aux].clscod is null then 
        		    next field clscod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao da Clausula        
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao_6(11,ma_ctc53m09[arr_aux].clscod,531)
        		returning ma_ctc53m09[arr_aux].clsdes   
        		
        		if ma_ctc53m09[arr_aux].clsdes is null then      
        		   next field clscod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Assunto X KM Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc53m09_002 using m_chave,
                                    ma_ctc53m09[arr_aux].clscod                                                
          whenever error continue                                                
          fetch c_ctc53m09_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Clausula ja Cadastrada Para Este Assunto!!" 
             next field clscod 
          end if 
          
          display ma_ctc53m09[arr_aux].clscod to s_ctc53m09[scr_aux].clscod 
          display ma_ctc53m09[arr_aux].clsdes to s_ctc53m09[scr_aux].clsdes                                                                
                              
           
        else          
        	display ma_ctc53m09[arr_aux].* to s_ctc53m09[scr_aux].*                                                     
        end if
        
     
         
     
     #---------------------------------------------                                             
      before field limite                                                                       
     #---------------------------------------------                                             
         display ma_ctc53m09[arr_aux].limite   to s_ctc53m09[scr_aux].limite   attribute(reverse) 
         let lr_retorno.limite = ma_ctc53m09[arr_aux].limite  
                                                                                              
     #---------------------------------------------                                                 
      after  field limite                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field clscod                                                           
         end if 
     
     
     #---------------------------------------------
      before field atende 
     #---------------------------------------------                                         
         
         if m_operacao = 'i' then
             let ma_ctc53m09[arr_aux].atende = "S"
         end if   
         
         
         display ma_ctc53m09[arr_aux].atende  to s_ctc53m09[scr_aux].atende  attribute(reverse)
         let lr_retorno.atende = ma_ctc53m09[arr_aux].atende
                                                                  
     #--------------------------------------------- 
      after  field atende                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field limite                                    
         end if                                                     
                                                                    
         if ma_ctc53m09[arr_aux].atende  is null or
         	 (ma_ctc53m09[arr_aux].atende <> "S"   and
         	  ma_ctc53m09[arr_aux].atende <> "N")  then                    
            error "Por Favor Informe <S>im ou <N>ao!"           
            next field atende                                          
         end if 
              
                      
         if m_operacao <> 'i' then 
                        
            if ma_ctc53m09[arr_aux].limite  <> lr_retorno.limite  or
            	 ma_ctc53m09[arr_aux].atende  <> lr_retorno.atende  or 
            	 lr_retorno.limite            is null               then

                  
                  #--------------------------------------------------------
                  # Atualiza Associacao Assunto X KM         
                  #--------------------------------------------------------
                  
                  call ctc53m09_altera()
                  next field clscod                  
            end if
                       
            let m_operacao = ' '                           
         else
            
            #--------------------------------------------------------  
            # Recupera Codigo da Associacao Perfil X Assunto           
            #--------------------------------------------------------  
            call ctc53m09_recupera_chave()                             
                     
            #-------------------------------------------------------- 
            # Inclui Associacao Limite X Assunto                  
            #-------------------------------------------------------- 
            call ctc53m09_inclui()    
            
            next field clscod            
         end if
         


         display ma_ctc53m09[arr_aux].clscod     to s_ctc53m09[scr_aux].clscod
         display ma_ctc53m09[arr_aux].clsdes     to s_ctc53m09[scr_aux].clsdes
         display ma_ctc53m09[arr_aux].limite     to s_ctc53m09[scr_aux].limite  
         display ma_ctc53m09[arr_aux].atende     to s_ctc53m09[scr_aux].atende
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m09[arr_aux].clscod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            if ctc53m10_valida_exclusao(mr_param.codper, mr_param.c24astcod, ma_ctc53m09[arr_aux].clscod) then 
            
                if ctc53m22_valida_exclusao(mr_param.codper, mr_param.c24astcod, ma_ctc53m09[arr_aux].clscod) then
                                             
                     #-------------------------------------------------------- 
                     # Exclui Associacao Assunto X KM                  
                     #-------------------------------------------------------- 
                     
                     if not ctc53m09_delete(ma_ctc53m09[arr_aux].clscod) then       	
                         let lr_retorno.flag = 1                                              	
                         exit input                                                  	
                     end if   
                     
                     
                     next field clscod
                else                                                                                     
                	  error "Alertas Cadastrados para Essa Clausula! Por Favor Exclua-os Primeiro."     
                	  let lr_retorno.flag = 1                                                              
                    exit input                                                                           
                end if	                                                                                                   
            else                                                                              
            	  error "Tipo de Assistencias Cadastradas para Essa Clausula! Por Favor Exclua-os Primeiro."
            	  let lr_retorno.flag = 1                                                       
                exit input                                                                    
            end if	                                                                          
                                                                   	
         end if
         
      #---------------------------------------------                  	
       on key (F6)                                                    	
      #---------------------------------------------                  	
                                                                      	
          if ma_ctc53m09[arr_aux].atende = "S"  then      	
                                                                      	
              call ctc53m10(mr_param.codper                  ,
                            mr_param.desper                  ,      	               
                            mr_param.c24astcod               , 
                            mr_param.c24astdes               ,
                            ma_ctc53m09[arr_aux].clscod      ,   
                            ma_ctc53m09[arr_aux].clsdes)      	        	
          end if
          
      
      #---------------------------------------------                
       on key (F7)                                                  
      #---------------------------------------------                
                                                                    
          if ma_ctc53m09[arr_aux].clscod is not null then      	
                                                                    
              call ctc53m22(mr_param.codper                  ,      
                            mr_param.desper                  ,      
                            mr_param.c24astcod               ,      
                            mr_param.c24astdes               ,      
                            ma_ctc53m09[arr_aux].clscod      ,      
                            ma_ctc53m09[arr_aux].clsdes      )     
          end if                                                 

          
      
  end input
  
 close window w_ctc53m09
 
 if lr_retorno.flag = 1 then
    call ctc53m09(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc53m09_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	clscod     like aackcls.clscod  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc53m09.* to null                                                    
                                                                                      
                                                               
   open c_ctc53m09_005 using m_chave,
                             lr_param.clscod                                                   
      
   whenever error continue                                                 
   fetch c_ctc53m09_005 into  mr_ctc53m09.atldat                                       
                             ,mr_ctc53m09.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc53m09.atldat                                           
                   ,mr_ctc53m09.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc53m09_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		clscod     like aackcls.clscod     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DO LIMITE DE KM ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc53m09_006 using m_chave,
                                     lr_param.clscod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Limite!'   
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
 function ctc53m09_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc53m09_003 using ma_ctc53m09[arr_aux].atende
                               , ma_ctc53m09[arr_aux].limite   
                               , lr_retorno.data_atual          
                               , lr_retorno.funmat         
                               , m_chave                                                
                               , ma_ctc53m09[arr_aux].clscod
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Limite!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if   
    
    let m_operacao = ' '            
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc53m09_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc53m09[arr_aux].clscod               , "|", 
                            ma_ctc53m09[arr_aux].atende clipped       , "|", 
                            ma_ctc53m09[arr_aux].limite using "&&&&"                     

    whenever error continue
    execute p_ctc53m09_004 using mr_ctc53m09.cpocod  
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao do Limite!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc53m09_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    codper     smallint,                                           
    c24astcod  like  datkassunto.c24astcod    
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "PF_", lr_param.codper using "&&", "_ASS" ,"_KM_", lr_param.c24astcod clipped 

 return lr_retorno.chave 
 
end function

#---------------------------------------------------------                                                
 function ctc53m09_recupera_chave()                                                                                                           
#---------------------------------------------------------        
                                                                  
    open c_ctc53m09_007 using m_chave                             
    whenever error continue                                       
    fetch c_ctc53m09_007 into mr_ctc53m09.cpocod                  
    whenever error stop                                           
                                                                  
    if mr_ctc53m09.cpocod is null or                              
    	 mr_ctc53m09.cpocod = ""    or                              
    	 mr_ctc53m09.cpocod = 0     then    	 	                    
    	 	let mr_ctc53m09.cpocod = 1                                
    else                                                          
    	  let mr_ctc53m09.cpocod = mr_ctc53m09.cpocod + 1           
    end if	                                                      
                                                                  
end function

#---------------------------------------------------------                                                                                
 function ctc53m09_valida_exclusao(lr_param)                                        
#---------------------------------------------------------                          
                                                                                    
define lr_param record                                                              
    codper     smallint,                                                            
    c24astcod  like  datkassunto.c24astcod                                          
end record                                                                          
                                                                                    
                                                                                    
define lr_retorno record                                                            
	cont integer                                                                      
end record                                                                          
                                                                                    
if m_prepare is null or                                                             
    m_prepare <> true then                                                          
    call ctc53m09_prepare()                                                         
end if                                                                              
                                                                                    
   initialize lr_retorno.* to null                                                  
                                                                                    
   let m_chave = ctc53m09_monta_chave(lr_param.codper, lr_param.c24astcod)          
                                                                                    
   open c_ctc53m09_008 using m_chave                                                
                                                                                    
   whenever error continue                                                          
   fetch c_ctc53m09_008 into  lr_retorno.cont                                       
   whenever error stop                                                              
                                                                                    
   if lr_retorno.cont > 0 then                                                      
      return false                                                                  
   else                                                                             
   	  return true                                                                   
   end if                                                                           
                                                                                    
end function                                                                        