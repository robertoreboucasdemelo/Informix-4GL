#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Central                                           #
# Modulo.........: ctc69m35                                                   #
# Objetivo.......: Cadastro de Parametros Itau RE                             #
# Analista Resp. : R.Fornax                                                   #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 01/11/2015                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  arr_aux     integer

define mr_ctc69m35 record
      flag_full           char(01)
     ,qtd_quebra          integer
     ,data_ini            date
     ,data_fim            date  
     ,qtd_ret             integer
     ,atldat              date    
     ,funmat              char(20)
end record

#------------------------------------------------------------
 function ctc69m35_prepare()
#------------------------------------------------------------

define l_sql char(10000)


 let l_sql =  ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '    
 prepare p_ctc69m35_001 from l_sql
 declare c_ctc69m35_001 cursor for p_ctc69m35_001


 let l_sql =  ' update datkdominio  '    
          ,  '     set cpodes  = ?  '
          ,  '     ,   atlult  = ?  '   
          ,  '   where cpocod  = ?  '    
          ,  '     and cponom  = ?  '    
 prepare p_ctc69m35_002 from l_sql
 
 let l_sql = '   select cpodes[01,10]        '                                  	
            ,'         ,cpodes[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         ' 
 prepare p_ctc69m35_003 from l_sql
 declare c_ctc69m35_003 cursor for p_ctc69m35_003
 

 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m35_005 from l_sql


 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '      
          ,  '  and   cpocod = ?  '                  
 prepare p_ctc69m35_007 from l_sql
 declare c_ctc69m35_007 cursor for p_ctc69m35_007
 	
 	
let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc69m35()
#------------------------------------------------------------

 let int_flag = false
 initialize mr_ctc69m35.* to null


 open window ctc69m35 at 4,2 with form "ctc69m35"
 
 call ctc69m35_prepare()   

 call ctc69m35_consulta()
 
 call ctc69m35_input()
 

 close window ctc69m35

 end function


#------------------------------------------------------------
 function ctc69m35_consulta()
#------------------------------------------------------------

 
 let int_flag = false

 initialize mr_ctc69m35.*  to null 
 
 
 #--------------------------------------------------------
 # Recupera Flag de Processamento Full                    
 #--------------------------------------------------------
 call ctc69m35_recupera_dados("bdata009_full")  
 returning mr_ctc69m35.flag_full                    

 #--------------------------------------------------------
 # Recupera a Data Inicial                   
 #--------------------------------------------------------
 call ctc69m35_recupera_dados("bdata009_inicio")  
 returning mr_ctc69m35.data_ini
 
 #--------------------------------------------------------
 # Recupera a Data Final                                    
 #--------------------------------------------------------
 call ctc69m35_recupera_dados("bdata009_fim")                            
 returning mr_ctc69m35.data_fim     
  
 #--------------------------------------------------------
 # Recupera a Quantidade de Registros para Commit                   
 #--------------------------------------------------------
 call ctc69m35_recupera_dados("bdata009_quebra")  
 returning mr_ctc69m35.qtd_quebra           
  
 #--------------------------------------------------------
 # Recupera a Quantidade de Dias Retroativos                     
 #--------------------------------------------------------
 call ctc69m35_recupera_dados("bdata009_retro")  
 returning mr_ctc69m35.qtd_ret                                                           
 
 #--------------------------------------------------------
 # Recupera Matricula                     
 #--------------------------------------------------------
 call ctc69m35_recupera_matricula("ctc69m35_mat")
 returning mr_ctc69m35.atldat,
           mr_ctc69m35.funmat
 
 display by name mr_ctc69m35.*                                        
                                                                      
                                                                      
end function                                                         


#--------------------------------------------------------------------
 function ctc69m35_input()
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

 input by name  mr_ctc69m35.flag_full             
 	             ,mr_ctc69m35.data_ini
 	             ,mr_ctc69m35.data_fim
 	             ,mr_ctc69m35.qtd_quebra   
 	             ,mr_ctc69m35.qtd_ret without defaults 
 	              


             
           
    
    before field flag_full
           display by name mr_ctc69m35.flag_full attribute (reverse)

    after  field flag_full
           display by name mr_ctc69m35.flag_full
           

           if  mr_ctc69m35.flag_full   is null or
           	  (mr_ctc69m35.flag_full  <> "S"   and
           	   mr_ctc69m35.flag_full  <> "N")  then
                 error "Por Favor Informe <S> ou <N>!!"            
                 next field flag_full         
           end if       
      
     
     
      
     before field data_ini                                            
            display by name mr_ctc69m35.data_ini attribute (reverse)   
                                                                          
     after  field data_ini                                             
            display by name mr_ctc69m35.data_ini                        
                                                                          
                                                                          
            if fgl_lastkey() = fgl_keyval ("up")     or                   
               fgl_lastkey() = fgl_keyval ("left")   then                 
                  next field flag_full                                   
            end if                                                        
                                                                          
            if  mr_ctc69m35.data_ini   is null then                  
                  error "Por Favor Informe a Data de Inicio!"                  
                  next field data_ini                                  
            end if                                                        
     
     
     before field data_fim                                                
            display by name mr_ctc69m35.data_fim attribute (reverse)      
                                                                                    
     after  field data_fim                                                
            display by name mr_ctc69m35.data_fim                          
                                                                                    
                                                                                    
            if fgl_lastkey() = fgl_keyval ("up")     or                             
               fgl_lastkey() = fgl_keyval ("left")   then                           
                  next field data_ini                                            
            end if                                                                  
                                                                                    
            if  mr_ctc69m35.data_fim   is null then               
                  error "Por Favor Informe a Data Final!!"                            
                  next field data_fim                                     
            end if                                                                  
     
            
            if  mr_ctc69m35.data_ini > mr_ctc69m35.data_fim  then               
                  error "Data Inicial Maior que Final!!"                            
                  next field data_fim                                     
            end if                          
            
    
     before field qtd_quebra                                             
            display by name mr_ctc69m35.qtd_quebra attribute (reverse)    
                                                                         
     after  field qtd_quebra                                              
            display by name mr_ctc69m35.qtd_quebra                        
                                                                         
                                                                         
            if fgl_lastkey() = fgl_keyval ("up")     or                  
               fgl_lastkey() = fgl_keyval ("left")   then                
                  next field data_fim                                   
            end if                                                       
                                                                         
            if   mr_ctc69m35.qtd_quebra   is null then                                        
                  error "Por Favor Informe uma Quantidade Valida!!"                 
                  next field qtd_quebra                                  
            end if                                                       
              
       
      
     before field qtd_ret                                              
            display by name mr_ctc69m35.qtd_ret attribute (reverse)    
                                                                                  
     after  field qtd_ret                                              
            display by name mr_ctc69m35.qtd_ret                        
                                                                                  
                                                                                  
            if fgl_lastkey() = fgl_keyval ("up")     or                            
               fgl_lastkey() = fgl_keyval ("left")   then                          
                  next field qtd_quebra                                           
            end if                                                                 
                                                                                   
            if   mr_ctc69m35.qtd_ret   is null then                  
                  error "Por Favor Informe a Quantidade de Dias!!"                            
                  next field qtd_ret                                    
            end if                                                                 
      
                      
            call ctc69m35_grava_dados()
                      
            display by name mr_ctc69m35.*
           
            
       
    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize mr_ctc69m35.*  to null
 end if
 
 prompt "Digite CTRL<C> para Sair" for char lr_retorno.confirma


 end function


#========================================================================   
 function ctc69m35_recupera_dados(lr_param)                                          
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
                                                                            
                                                                            
  open c_ctc69m35_001 using  lr_param.cponom   ,                            
                             lr_retorno.cpocod                              
  whenever error continue                                                   
  fetch c_ctc69m35_001 into lr_retorno.cpodes                               
  whenever error stop                                                       
                                                                                                                                       
  return lr_retorno.cpodes                                                              
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 

#========================================================================   
 function ctc69m35_valida_dados(lr_param)                                
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
                                                                           
  open c_ctc69m35_007 using  lr_param.cponom   ,                           
                             lr_retorno.cpocod                             
  whenever error continue                                                  
  fetch c_ctc69m35_007 into lr_retorno.cont                         
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
 function ctc69m35_grava_dados()                                
#========================================================================  
 

 
 #-------------------------------------------------------- 
 # Grava Dados Flag de Processamento Full                 
 #-------------------------------------------------------- 
 if ctc69m35_valida_dados("bdata009_full") then                        
    call ctc69m35_atualiza_dados("bdata009_full", mr_ctc69m35.flag_full)
 else                                                                  
 	  call ctc69m35_inclui_dados("bdata009_full", mr_ctc69m35.flag_full)  
 end if	
 
 #-------------------------------------------------------- 
 # Grava Dados da Data Inicial Full             
 #-------------------------------------------------------- 
 if ctc69m35_valida_dados("bdata009_inicio") then                             
    call ctc69m35_atualiza_dados("bdata009_inicio", mr_ctc69m35.data_ini)    
 else                                                                       
 	  call ctc69m35_inclui_dados("bdata009_inicio", mr_ctc69m35.data_ini)                                                                    
 end if	                                                                   
  
 #-------------------------------------------------------- 
 # Grava Dados da Data Final Full                  
 #-------------------------------------------------------- 
 if ctc69m35_valida_dados("bdata009_fim") then                                      
    call ctc69m35_atualiza_dados("bdata009_fim", mr_ctc69m35.data_fim)    
 else                                                                                   
 	  call ctc69m35_inclui_dados("bdata009_fim", mr_ctc69m35.data_fim)      
 end if	                                                                                   
 
 #-------------------------------------------------------- 
 # Grava Dados da Quebra de Commit               
 #-------------------------------------------------------- 
 if ctc69m35_valida_dados("bdata009_quebra") then                                   
    call ctc69m35_atualiza_dados("bdata009_quebra", mr_ctc69m35.qtd_quebra) 
 else                                                                                
 	  call ctc69m35_inclui_dados("bdata009_quebra", mr_ctc69m35.qtd_quebra)                             
 end if	                                                                             
  
 #-------------------------------------------------------- 
 # Grava Dados da Quantidades de Dias Retroativos              
 #-------------------------------------------------------- 
 if ctc69m35_valida_dados("bdata009_retro") then                            
    call ctc69m35_atualiza_dados("bdata009_retro", mr_ctc69m35.qtd_ret) 
 else                                                                        
 	  call ctc69m35_inclui_dados("bdata009_retro", mr_ctc69m35.qtd_ret)   
 end if	  
 
 #-------------------------------------------------------- 
 # Grava Dados Matricula                 
 #-------------------------------------------------------- 
 if ctc69m35_valida_dados("ctc69m35_mat") then                            
    call ctc69m35_atualiza_matricula("ctc69m35_mat") 
 else                                                                       
 	  call ctc69m35_inclui_matricula("ctc69m35_mat")   
 end if	                        
 
                                                                                                                                                                                                    
#========================================================================  
end function                                                               
#========================================================================

#========================================================================                                                                                              
 function ctc69m35_inclui_dados(lr_param)                                             
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
    execute p_ctc69m35_005 using lr_retorno.cpocod   
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
 function ctc69m35_atualiza_dados(lr_param)                                             
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
    execute p_ctc69m35_002 using lr_param.cpodes 
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
 function ctc69m35_inclui_matricula(lr_param)                                             
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
    execute p_ctc69m35_005 using lr_retorno.cpocod   
                               , lr_retorno.cpodes
                               , lr_param.cponom
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'                                                                                                                                        
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if 
    
    let mr_ctc69m35.atldat  = lr_retorno.data_atual 
    let mr_ctc69m35.funmat  = g_issk.funmat
                       
                                                                                      
end function  

#========================================================================                                                                                              
 function ctc69m35_atualiza_matricula(lr_param)                                             
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
    execute p_ctc69m35_002 using lr_retorno.cpodes 
                               , lr_retorno.atlult                                          
                               , lr_retorno.cpocod 
                               , lr_param.cponom
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if 
    
    let mr_ctc69m35.atldat  = lr_retorno.data_atual 
    let mr_ctc69m35.funmat  = g_issk.funmat         
    
                                                                                      
end function  

#========================================================================   
 function ctc69m35_recupera_matricula(lr_param)                                          
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
                                                                            
                                                                            
  open c_ctc69m35_003 using  lr_param.cponom   ,                            
                             lr_retorno.cpocod                              
  whenever error continue                                                   
  fetch c_ctc69m35_003 into lr_retorno.cpodes1 ,
                            lr_retorno.cpodes2                               
  whenever error stop                                                       
                                                                                                                                       
  return lr_retorno.cpodes1,
         lr_retorno.cpodes2                                                             
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 