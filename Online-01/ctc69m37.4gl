#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Central                                           #
# Modulo.........: ctc69m37                                                   #
# Objetivo.......: Cadastro de Parametros Limpeza Movimento                   #
# Analista Resp. : R.Fornax                                                   #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 01/11/2015                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  arr_aux     integer

define mr_ctc69m37 record
      flag_full           char(01)
     ,qtd_quebra          integer
     ,dias                integer
     ,diretorio           char(50)  
     ,atldat              date    
     ,funmat              char(20)
end record

#------------------------------------------------------------
 function ctc69m37_prepare()
#------------------------------------------------------------

define l_sql char(10000)


 let l_sql =  ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '    
 prepare p_ctc69m37_001 from l_sql
 declare c_ctc69m37_001 cursor for p_ctc69m37_001


 let l_sql =  ' update datkdominio  '    
          ,  '     set cpodes  = ?  '
          ,  '     ,   atlult  = ?  '   
          ,  '   where cpocod  = ?  '    
          ,  '     and cponom  = ?  '    
 prepare p_ctc69m37_002 from l_sql
 
 let l_sql = '   select cpodes[01,10]        '                                  	
            ,'         ,cpodes[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         ' 
 prepare p_ctc69m37_003 from l_sql
 declare c_ctc69m37_003 cursor for p_ctc69m37_003
 

 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m37_005 from l_sql


 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '      
          ,  '  and   cpocod = ?  '                  
 prepare p_ctc69m37_007 from l_sql
 declare c_ctc69m37_007 cursor for p_ctc69m37_007
 	
 	
let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc69m37()
#------------------------------------------------------------

 let int_flag = false
 initialize mr_ctc69m37.* to null


 open window ctc69m37 at 4,2 with form "ctc69m37"
 
 call ctc69m37_prepare()   

 call ctc69m37_consulta()
 
 call ctc69m37_input()
 

 close window ctc69m37

 end function


#------------------------------------------------------------
 function ctc69m37_consulta()
#------------------------------------------------------------

 
 let int_flag = false

 initialize mr_ctc69m37.*  to null 
 
 
 #--------------------------------------------------------
 # Recupera Flag de Processamento Full                    
 #--------------------------------------------------------
 call ctc69m37_recupera_dados("bdata010_full")  
 returning mr_ctc69m37.flag_full                    

 #--------------------------------------------------------
 # Recupera a Data Inicial                   
 #--------------------------------------------------------
 call ctc69m37_recupera_dados("bdata010_dias")  
 returning mr_ctc69m37.dias
 
  
 #--------------------------------------------------------
 # Recupera a Quantidade de Registros para Commit                   
 #--------------------------------------------------------
 call ctc69m37_recupera_dados("bdata010_quebra")  
 returning mr_ctc69m37.qtd_quebra           
  
 #--------------------------------------------------------
 # Recupera o Diretorio do Arquivo                     
 #--------------------------------------------------------
 call ctc69m37_recupera_dados("bdata010_dir_ben")  
 returning mr_ctc69m37.diretorio                                                           
 
 #--------------------------------------------------------
 # Recupera Matricula                     
 #--------------------------------------------------------
 call ctc69m37_recupera_matricula("ctc69m37_mat")
 returning mr_ctc69m37.atldat,
           mr_ctc69m37.funmat
 
 display by name mr_ctc69m37.*                                        
                                                                      
                                                                      
end function                                                         


#--------------------------------------------------------------------
 function ctc69m37_input()
#--------------------------------------------------------------------

 define lr_retorno record
     erro        smallint,
     mensagem    char(60),
     count       smallint,
     confirma    char(01)
 end record


 let lr_retorno.count    = 0
 let lr_retorno.erro     = 0
 let lr_retorno.mensagem = null

 let int_flag = false

 input by name  mr_ctc69m37.flag_full             
 	             ,mr_ctc69m37.dias
 	             ,mr_ctc69m37.qtd_quebra   
 	             ,mr_ctc69m37.diretorio without defaults 
 	              


             
           
    
    before field flag_full
           display by name mr_ctc69m37.flag_full attribute (reverse)

    after  field flag_full
           display by name mr_ctc69m37.flag_full
           

           if  mr_ctc69m37.flag_full   is null or
           	  (mr_ctc69m37.flag_full  <> "S"   and
           	   mr_ctc69m37.flag_full  <> "N")  then
                 error "Por Favor Informe <S> ou <N>!!"            
                 next field flag_full         
           end if       
      
     
     
      
     before field dias                                            
            display by name mr_ctc69m37.dias attribute (reverse)   
                                                                          
     after  field dias                                             
            display by name mr_ctc69m37.dias                        
                                                                          
                                                                          
            if fgl_lastkey() = fgl_keyval ("up")     or                   
               fgl_lastkey() = fgl_keyval ("left")   then                 
                  next field flag_full                                   
            end if                                                        
                                                                          
            if  mr_ctc69m37.dias   is null then                  
                  error "Por Favor Informe a Quantidade de Dias!"                  
                  next field dias                                  
            end if                                                        
           
            
    
     before field qtd_quebra                                             
            display by name mr_ctc69m37.qtd_quebra attribute (reverse)    
                                                                         
     after  field qtd_quebra                                              
            display by name mr_ctc69m37.qtd_quebra                        
                                                                         
                                                                         
            if fgl_lastkey() = fgl_keyval ("up")     or                  
               fgl_lastkey() = fgl_keyval ("left")   then                
                  next field dias                                   
            end if                                                       
                                                                         
            if   mr_ctc69m37.qtd_quebra   is null then                                        
                  error "Por Favor Informe uma Quantidade Valida!!"                 
                  next field qtd_quebra                                  
            end if                                                       
              
       
      
     before field diretorio                                              
            display by name mr_ctc69m37.diretorio attribute (reverse)    
                                                                                  
     after  field diretorio                                              
            display by name mr_ctc69m37.diretorio                        
                                                                                  
                                                                                  
            if fgl_lastkey() = fgl_keyval ("up")     or                            
               fgl_lastkey() = fgl_keyval ("left")   then                          
                  next field qtd_quebra                                           
            end if                                                                 
                                                                                   
            if   mr_ctc69m37.diretorio   is null then                  
                  error "Por Favor Informe um Diretorio!!"                            
                  next field diretorio                                    
            end if                                                                 
      
                      
            call ctc69m37_grava_dados()
                      
            display by name mr_ctc69m37.*
           
            
       
    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize mr_ctc69m37.*  to null
 end if
 
 prompt "Digite CTRL<C> para Sair" for char lr_retorno.confirma


 end function


#========================================================================   
 function ctc69m37_recupera_dados(lr_param)                                          
#======================================================================== 

define lr_param record                  
	cponom  like datkdominio.cponom                                           
end record         
                                                                                                   
define lr_retorno record                                                                                            
	cpocod  like datkdominio.cpocod,                                          
	cpodes  like datkdominio.cpodes                                           
end record                                                                  
                                                                            
initialize lr_retorno.* to null                                             
                                                                                                              
let lr_retorno.cpocod = 1                                                   
                                                                            
                                                                            
  open c_ctc69m37_001 using  lr_param.cponom   ,                            
                             lr_retorno.cpocod                              
  whenever error continue                                                   
  fetch c_ctc69m37_001 into lr_retorno.cpodes                               
  whenever error stop                                                       
                                                                                                                                       
  return lr_retorno.cpodes                                                              
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 

#========================================================================   
 function ctc69m37_valida_dados(lr_param)                                
#========================================================================  
                                                                           
define lr_param record                                                     
	cponom  like datkdominio.cponom                                          
end record                                                                 
                                                                           
define lr_retorno record                                                   
	cpocod  like datkdominio.cpocod,                                         
	cont    integer                                          
end record                                                                 
                                                                           
initialize lr_retorno.* to null                                            
                                                                           
let lr_retorno.cpocod = 1                                                  
let lr_retorno.cont   = 0                                                                           
                                                                           
  open c_ctc69m37_007 using  lr_param.cponom   ,                           
                             lr_retorno.cpocod                             
  whenever error continue                                                  
  fetch c_ctc69m37_007 into lr_retorno.cont                         
  whenever error stop                                                      
                                                                           
  if lr_retorno.cont > 0 then 
  	return true
  else
  	return false
  end if                                                
                                                                           
#========================================================================  
end function                                                               
#========================================================================  


#========================================================================   
 function ctc69m37_grava_dados()                                
#========================================================================  
 

 
 #-------------------------------------------------------- 
 # Grava Dados Flag de Processamento Full                 
 #-------------------------------------------------------- 
 if ctc69m37_valida_dados("bdata010_full") then                        
    call ctc69m37_atualiza_dados("bdata010_full", mr_ctc69m37.flag_full)
 else                                                                  
 	  call ctc69m37_inclui_dados("bdata010_full", mr_ctc69m37.flag_full)  
 end if	
 
 #-------------------------------------------------------- 
 # Grava Dados de Dias           
 #-------------------------------------------------------- 
 if ctc69m37_valida_dados("bdata010_dias") then                             
    call ctc69m37_atualiza_dados("bdata010_dias", mr_ctc69m37.dias)    
 else                                                                       
 	  call ctc69m37_inclui_dados("bdata010_dias", mr_ctc69m37.dias)                                                                    
 end if	                                                                   
  
                                                                         
 
 #-------------------------------------------------------- 
 # Grava Dados da Quebra de Commit               
 #-------------------------------------------------------- 
 if ctc69m37_valida_dados("bdata010_quebra") then                                   
    call ctc69m37_atualiza_dados("bdata010_quebra", mr_ctc69m37.qtd_quebra) 
 else                                                                                
 	  call ctc69m37_inclui_dados("bdata010_quebra", mr_ctc69m37.qtd_quebra)                             
 end if	                                                                             
  
 #-------------------------------------------------------- 
 # Grava Dados do Diretorio do Arquivo               
 #-------------------------------------------------------- 
 if ctc69m37_valida_dados("bdata010_dir_ben") then                            
    call ctc69m37_atualiza_dados("bdata010_dir_ben", mr_ctc69m37.diretorio) 
 else                                                                        
 	  call ctc69m37_inclui_dados("bdata010_dir_ben", mr_ctc69m37.diretorio)   
 end if	  
 
 #-------------------------------------------------------- 
 # Grava Dados Matricula                 
 #-------------------------------------------------------- 
 if ctc69m37_valida_dados("ctc69m37_mat") then                            
    call ctc69m37_atualiza_matricula("ctc69m37_mat") 
 else                                                                       
 	  call ctc69m37_inclui_matricula("ctc69m37_mat")   
 end if	                        
 
                                                                                                                                                                                                    
#========================================================================  
end function                                                               
#========================================================================

#========================================================================                                                                                              
 function ctc69m37_inclui_dados(lr_param)                                             
#========================================================================   

define lr_param record                                                     
	cponom  like datkdominio.cponom ,
	cpodes  like datkdominio.cpodes                                           
end record                                                                 
                                                                           
define lr_retorno record                                                   
	cpocod     like datkdominio.cpocod ,                                          
	data_atual date                    ,
  atlult     like datkdominio.atlult	                                         
end record                                                                 
                                                                           
initialize lr_retorno.* to null    

let lr_retorno.cpocod = 1                             

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue
    execute p_ctc69m37_005 using lr_retorno.cpocod   
                               , lr_param.cpodes
                               , lr_param.cponom
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'                                                                                                                                        
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if  
                  
                                                                                   
end function  

#========================================================================                                                                                              
 function ctc69m37_atualiza_dados(lr_param)                                             
#========================================================================   

define lr_param record                                                     
	cponom  like datkdominio.cponom, 
	cpodes  like datkdominio.cpodes                                             
end record                                                                 
                                                                           
define lr_retorno record                                                   
	cpocod     like datkdominio.cpocod ,                                        
	data_atual date                    ,
  atlult     like datkdominio.atlult	                                         
end record                                                                 
                                                                           
initialize lr_retorno.* to null    

let lr_retorno.cpocod = 1                             

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue 
    execute p_ctc69m37_002 using lr_param.cpodes 
                               , lr_retorno.atlult                                          
                               , lr_retorno.cpocod 
                               , lr_param.cponom
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if 
                                                                                      
end function 

#========================================================================                                                                                              
 function ctc69m37_inclui_matricula(lr_param)                                             
#========================================================================   

define lr_param record                                                     
	cponom  like datkdominio.cponom                                         
end record                                                                 
                                                                           
define lr_retorno record                                                   
	cpocod     like datkdominio.cpocod ,  
	cpodes     like datkdominio.cpodes ,                                          
	data_atual date                    ,
  atlult     like datkdominio.atlult	                                         
end record                                                                 
                                                                           
initialize lr_retorno.* to null    

let lr_retorno.cpocod = 1                             

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = lr_retorno.atlult
   
    whenever error continue
    execute p_ctc69m37_005 using lr_retorno.cpocod   
                               , lr_retorno.cpodes
                               , lr_param.cponom
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'                                                                                                                                        
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if 
    
    let mr_ctc69m37.atldat  = lr_retorno.data_atual 
    let mr_ctc69m37.funmat  = g_issk.funmat
                       
                                                                                      
end function  

#========================================================================                                                                                              
 function ctc69m37_atualiza_matricula(lr_param)                                             
#========================================================================   

define lr_param record                                                     
	cponom  like datkdominio.cponom                                         
end record                                                                 
                                                                           
define lr_retorno record                                                   
	cpocod     like datkdominio.cpocod ,  
	cpodes     like datkdominio.cpodes ,                                       
	data_atual date                    ,
  atlult     like datkdominio.atlult	                                         
end record                                                                 
                                                                           
initialize lr_retorno.* to null    

let lr_retorno.cpocod = 1                             

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = lr_retorno.atlult    
   
    whenever error continue 
    execute p_ctc69m37_002 using lr_retorno.cpodes 
                               , lr_retorno.atlult                                          
                               , lr_retorno.cpocod 
                               , lr_param.cponom
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if 
    
    let mr_ctc69m37.atldat  = lr_retorno.data_atual 
    let mr_ctc69m37.funmat  = g_issk.funmat         
    
                                                                                      
end function  

#========================================================================   
 function ctc69m37_recupera_matricula(lr_param)                                          
#======================================================================== 

define lr_param record                  
	cponom  like datkdominio.cponom                                           
end record         
                                                                                                   
define lr_retorno record                                                                                            
	cpocod  like datkdominio.cpocod,                                          
	cpodes1 like datkdominio.cpodes,   
	cpodes2 like datkdominio.cpodes                                           
end record                                                                  
                                                                            
initialize lr_retorno.* to null                                             
                                                                                                              
let lr_retorno.cpocod = 1                                                   
                                                                            
                                                                            
  open c_ctc69m37_003 using  lr_param.cponom   ,                            
                             lr_retorno.cpocod                              
  whenever error continue                                                   
  fetch c_ctc69m37_003 into lr_retorno.cpodes1 ,
                            lr_retorno.cpodes2                               
  whenever error stop                                                       
                                                                                                                                       
  return lr_retorno.cpodes1,
         lr_retorno.cpodes2                                                             
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 