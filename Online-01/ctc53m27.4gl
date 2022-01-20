#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m27                                                   # 
# Objetivo.......: Cadastro Bloco X Assunto                                   # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 01/04/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m27 array[500] of record
      blocod     integer           
    , blodes     char(60)                
end record
 
define mr_param   record
     codper     smallint,                    
     desper     char(60),                    
     c24astcod  like  datkassunto.c24astcod, 
     c24astdes  like  datkassunto.c24astdes      
end record
 
define mr_ctc53m27 record
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
 function ctc53m27_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod                 ' 
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by cpocod                '     
 prepare p_ctc53m27_001 from l_sql
 declare c_ctc53m27_001 cursor for p_ctc53m27_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc53m27_002 from l_sql
 declare c_ctc53m27_002 cursor for p_ctc53m27_002
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m27_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc53m27_005    from l_sql                                             	
 declare c_ctc53m27_005 cursor for p_ctc53m27_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc53m27_006 from l_sql
 
 
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
 prepare p_ctc53m27_007 from l_sql
 declare c_ctc53m27_007 cursor for p_ctc53m27_007
 
 	
 let m_prepare = true


end function

#===============================================================================
 function ctc53m27(lr_param)
#===============================================================================
 
define lr_param record
    codper     smallint,  
    desper     char(60),   
    c24astcod  like  datkassunto.c24astcod, 
    c24astdes  like  datkassunto.c24astdes       
end record
 
define lr_retorno record
    flag       smallint  ,
    cont       integer   ,                   
    confirma   char(01) 
end record
 
 let mr_param.codper     = lr_param.codper   
 let mr_param.desper     = lr_param.desper   
 let mr_param.c24astcod  = lr_param.c24astcod
 let mr_param.c24astdes  = lr_param.c24astdes
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc53m27[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc53m27.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m27_prepare()
 end if
    
 let m_chave = ctc53m27_monta_chave(mr_param.codper, mr_param.c24astcod)
 
 open window w_ctc53m27 at 6,2 with form 'ctc53m27'
 attribute(form line 1)
  
 let mr_ctc53m27.msg =  '               (F17)Abandona,(F1)Inclui,(F2)Exclui,(F6)Naturezas' 
   
  display by name mr_param.codper   
                , mr_param.desper   
                , mr_param.c24astcod
                , mr_param.c24astdes
                , mr_ctc53m27.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Assunto X Bloco           
  #-------------------------------------------------------- 
  
  open c_ctc53m27_001  using  m_chave                                             
  foreach c_ctc53m27_001 into ma_ctc53m27[arr_aux].blocod
  	                                                                                                                          
       #--------------------------------------------------------                  
       # Recupera a Descricao da Bloco                                          
       #--------------------------------------------------------                  
                                                                                  
       call ctc69m04_recupera_descricao(14,ma_ctc53m27[arr_aux].blocod)       
       returning ma_ctc53m27[arr_aux].blodes                                     
                                                                                  
       let arr_aux = arr_aux + 1                                                  
                                                                                  
       if arr_aux > 500 then                                                      
          error " Limite Excedido! Foram Encontrados Mais de 500 Blocos!"       
          exit foreach                                                            
       end if                                                                     
                                                                                  
  end foreach                                                                     
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc53m27 without defaults from s_ctc53m27.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m27[arr_aux].blocod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc53m27[arr_aux] to null
                  
         display ma_ctc53m27[arr_aux].blocod  to s_ctc53m27[scr_aux].blocod 
         display ma_ctc53m27[arr_aux].blodes  to s_ctc53m27[scr_aux].blodes
              
      #---------------------------------------------
       before field blocod
      #---------------------------------------------
        
        if ma_ctc53m27[arr_aux].blocod is null then                                                   
           display ma_ctc53m27[arr_aux].blocod to s_ctc53m27[scr_aux].blocod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc53m27[arr_aux].* to s_ctc53m27[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Assunto X Bloco          
        	 #--------------------------------------------------------
        	
           call ctc53m27_dados_alteracao(ma_ctc53m27[arr_aux].blocod) 
        end if 
      
      #---------------------------------------------
       after field blocod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc53m27[arr_aux].blocod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Bloco         
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup(14)
        		 returning ma_ctc53m27[arr_aux].blocod 
        		         , ma_ctc53m27[arr_aux].blodes
        		 
        		 if ma_ctc53m27[arr_aux].blocod is null then 
        		    next field blocod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Bloco         
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao(14,ma_ctc53m27[arr_aux].blocod)
        		returning ma_ctc53m27[arr_aux].blodes   
        		
        		if ma_ctc53m27[arr_aux].blodes is null then      
        		   next field blocod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Assunto X Bloco Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc53m27_002 using m_chave,
                                    ma_ctc53m27[arr_aux].blocod                                                
          whenever error continue                                                
          fetch c_ctc53m27_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Bloco ja Cadastrada Para Este Assunto!!" 
             next field blocod 
          end if 
          
          display ma_ctc53m27[arr_aux].blocod to s_ctc53m27[scr_aux].blocod 
          display ma_ctc53m27[arr_aux].blodes to s_ctc53m27[scr_aux].blodes                                                                
                              
           
        else          
        	display ma_ctc53m27[arr_aux].* to s_ctc53m27[scr_aux].*                                                     
        end if
        
         
               
         if m_operacao = 'i' then 
                     
            #-------------------------------------------------------- 
            # Inclui Associacao Bloco X Assunto                  
            #-------------------------------------------------------- 
            call ctc53m27_inclui()    
            
            next field blocod            
         end if
         
         display ma_ctc53m27[arr_aux].blocod  to s_ctc53m27[scr_aux].blocod
         display ma_ctc53m27[arr_aux].blodes  to s_ctc53m27[scr_aux].blodes
        
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m27[arr_aux].blocod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
            if ctc53m28_valida_exclusao(mr_param.codper,mr_param.c24astcod,(ma_ctc53m27[arr_aux].blocod)) then
            
                #-------------------------------------------------------- 
                # Exclui Associacao Bloco X Clausula                  
                #-------------------------------------------------------- 
                
                if not ctc53m27_delete(ma_ctc53m27[arr_aux].blocod) then       	
                    let lr_retorno.flag = 1                                              	
                    exit input                                                  	
                end if   
                
                
                next field blocod
            else                                                                        
                error "Naturezas Cadastradas para Esse Bloco! Por Favor Exclua-os Primeiro." 
                let lr_retorno.flag = 1                                                 
                exit input                                                              
            end if	         
                                                                   	
         end if
         
      
      #---------------------------------------------                  	
       on key (F6)                                                    	
      #---------------------------------------------                  	
                                                                      	
          if ma_ctc53m27[arr_aux].blocod is not null then      	  
                                                                      
              call ctc53m28(mr_param.codper                  ,        
                            mr_param.desper                  ,        
                            mr_param.c24astcod               ,        
                            mr_param.c24astdes               ,        
                            ma_ctc53m27[arr_aux].blocod      ,    	
                            ma_ctc53m27[arr_aux].blodes      )        
          end if                                                           
         
      
  end input
  
 close window w_ctc53m27
 
 if lr_retorno.flag = 1 then
    call ctc53m27(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc53m27_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	blocod     integer 
end record
                                                                                                    
                                                                                      
   initialize mr_ctc53m27.* to null                                                    
                                                                                      
                                                               
   open c_ctc53m27_005 using m_chave,
                             lr_param.blocod                                                   
      
   whenever error continue                                                 
   fetch c_ctc53m27_005 into  mr_ctc53m27.atldat                                       
                             ,mr_ctc53m27.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc53m27.atldat                                           
                   ,mr_ctc53m27.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc53m27_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		blocod     integer    
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DO BLOCO?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc53m27_006 using m_chave,
                                     lr_param.blocod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Bloco!'   
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
 function ctc53m27_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ""                      

    whenever error continue
    execute p_ctc53m27_004 using ma_ctc53m27[arr_aux].blocod   
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Bloco!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc53m27_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    codper     smallint,                                           
    c24astcod  like  datkassunto.c24astcod    
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "PF_", lr_param.codper using "&&", "_ASS" ,"_BLO_", lr_param.c24astcod clipped 

 return lr_retorno.chave 
 
end function

#---------------------------------------------------------                                            
 function ctc53m27_valida_exclusao(lr_param)                                                                                               
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
    call ctc53m27_prepare()                                   
end if                                                        
                                                              
   initialize lr_retorno.* to null                            
                                                              
   let m_chave = ctc53m27_monta_chave(lr_param.codper, lr_param.c24astcod)                       
                                                              
   open c_ctc53m27_007 using m_chave                         
                                                                                                        
   whenever error continue                                    
   fetch c_ctc53m27_007 into  lr_retorno.cont                 
   whenever error stop                                        
                                                              
   if lr_retorno.cont > 0 then                                
      return false                                           
   else                                                       
   	  return true                                            
   end if                                                     
                                                              
end function                                                  
