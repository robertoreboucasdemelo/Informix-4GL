#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Central                                           #
# Modulo.........: ctc97m04                                                   #
# Objetivo.......: Cadastro de Limites do Help Desk                           #
# Analista Resp. : Humberto Santos                                            #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 20/05/2015                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  arr_aux     integer

define mr_ctc97m04 record
      flg_uni   char(01)
     ,lim_uni   integer        
     ,lim_tel   integer
     ,lim_pre   integer
     ,atldat    date    
     ,funmat    char(20)
end record

define mr_param   record                            
     cod        integer  
   , descricao  char(60)          
end record                                          

#------------------------------------------------------------
 function ctc97m04_prepare()
#------------------------------------------------------------

define l_sql char(10000)


 let l_sql =  ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '    
 prepare p_ctc97m04_001 from l_sql
 declare c_ctc97m04_001 cursor for p_ctc97m04_001


 let l_sql =  ' update datkdominio  '    
          ,  '     set cpodes  = ?  '
          ,  '     ,   atlult  = ?  '   
          ,  '   where cpocod  = ?  '    
          ,  '     and cponom  = ?  '    
 prepare p_ctc97m04_002 from l_sql
 
 let l_sql = '   select cpodes[01,10]        '                                  	
            ,'         ,cpodes[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         ' 
 prepare p_ctc97m04_003 from l_sql
 declare c_ctc97m04_003 cursor for p_ctc97m04_003
 

 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc97m04_005 from l_sql


 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '      
          ,  '  and   cpocod = ?  '                  
 prepare p_ctc97m04_007 from l_sql
 declare c_ctc97m04_007 cursor for p_ctc97m04_007
 	
 	
let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc97m04(lr_param)
#------------------------------------------------------------

 define lr_param   record           
      cod        integer            
    , descricao  char(60)           
 end record                         

 let int_flag = false
 initialize mr_ctc97m04.*, mr_param.* to null
 
 let mr_param.cod        =  lr_param.cod        
 let mr_param.descricao  =  lr_param.descricao


 open window ctc97m04 at 6,2 with form "ctc97m04"
 attribute(form line 1) 
 
 if m_sql is null or      
    m_sql <> true then    
    call ctc97m04_prepare()   
 end if
 
 call ctc97m04_consulta()
 
 call ctc97m04_input()
 

 close window ctc97m04

 end function


#------------------------------------------------------------
 function ctc97m04_consulta()
#------------------------------------------------------------

 
 let int_flag = false

 initialize mr_ctc97m04.*  to null 
 
 
 #--------------------------------------------------------  
 # Recupera a Flag de Limite Unificado                              
 #--------------------------------------------------------  
 call ctc97m04_recupera_dados("ctc97m04_flg_uni", mr_param.cod)           
 returning mr_ctc97m04.flg_uni                              
 
 
 #--------------------------------------------------------    
 # Recupera o Limite Unificado                               
 #--------------------------------------------------------    
 call ctc97m04_recupera_dados("ctc97m04_lim_uni", mr_param.cod) 
 returning mr_ctc97m04.lim_uni 
 
 #--------------------------------------------------------
 # Recupera o Limite Telefonico                 
 #--------------------------------------------------------
 call ctc97m04_recupera_dados("ctc97m04_lim_tel", mr_param.cod)  
 returning mr_ctc97m04.lim_tel                    

 #--------------------------------------------------------
 # Recupera o Limite Presencial                   
 #--------------------------------------------------------
 call ctc97m04_recupera_dados("ctc97m04_lim_pre", mr_param.cod)  
 returning mr_ctc97m04.lim_pre                          
 
 #--------------------------------------------------------
 # Recupera Matricula                     
 #--------------------------------------------------------
 call ctc97m04_recupera_matricula("ctc97m04_mat")
 returning mr_ctc97m04.atldat,
           mr_ctc97m04.funmat
 
 display by name mr_ctc97m04.*, mr_param.*                                        
                                                                      
                                                                      
end function                                                         


#--------------------------------------------------------------------
 function ctc97m04_input()
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

 input by name  mr_ctc97m04.flg_uni
 	             ,mr_ctc97m04.lim_uni           
 	             ,mr_ctc97m04.lim_tel             
 	             ,mr_ctc97m04.lim_pre without defaults 
 	              
    before field flg_uni
           display by name mr_ctc97m04.flg_uni attribute (reverse)

    after  field flg_uni
           display by name mr_ctc97m04.flg_uni


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field flg_uni
           end if
           
                     
           if  mr_ctc97m04.flg_uni   is null or               
           	  (mr_ctc97m04.flg_uni  <> "S"   and             
           	   mr_ctc97m04.flg_uni  <> "N")  then            
                 error "Por Favor Informe <S> ou <N>!!"       
                 next field flg_uni                               
           end if                           

   
    before field lim_uni
           display by name mr_ctc97m04.lim_uni attribute (reverse)

    after  field lim_uni
           display by name mr_ctc97m04.lim_uni


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field lim_uni
           end if
           
           if mr_ctc97m04.lim_uni is null then
           	  error "Limite Unificado nao Pode ser Nulo!"
           	  next field lim_uni 
           end if
           
    
    before field lim_tel
           display by name mr_ctc97m04.lim_tel attribute (reverse)

    after  field lim_tel
           display by name mr_ctc97m04.lim_tel


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field lim_uni
           end if   
           
           if mr_ctc97m04.lim_tel is null then              
           	  error "Limite Telefonico nao Pode ser Nulo!"   
           	  next field lim_tel                           
           end if                                           
    
     before field lim_pre                                             
            display by name mr_ctc97m04.lim_pre attribute (reverse)    
                                                                         
     after  field lim_pre                                              
            display by name mr_ctc97m04.lim_pre                        
                                                                         
                                                                         
            if fgl_lastkey() = fgl_keyval ("up")     or                  
               fgl_lastkey() = fgl_keyval ("left")   then                
                  next field lim_pre                                   
            end if 
            
            
            if mr_ctc97m04.lim_pre is null then               
            	  error "Limite Presencial nao Pode ser Nulo!"   
            	  next field lim_pre                                                                                  
            end if                                                                                                         
                    
            call ctc97m04_grava_dados()
                      
            display by name mr_ctc97m04.*
           
            
       
    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize mr_ctc97m04.*  to null
 end if
 
 prompt "Digite CTRL<C> para Sair" for char lr_retorno.confirma


 end function


#========================================================================   
 function ctc97m04_recupera_dados(lr_param)                                          
#======================================================================== 

define lr_param record                  
	cponom  like datkdominio.cponom, 
	cod     integer                                         
end record         
                                                                                                   
define lr_retorno record                                                                                            
	cpocod  like datkdominio.cpocod,                                          
	cpodes  like datkdominio.cpodes                                           
end record                                                                  
                                                                            
initialize lr_retorno.* to null                                             
                                                                                                                                                              
  if m_sql is null or      
     m_sql <> true then    
      call ctc97m04_prepare()
  end if                                                                           
                                                                            
  open c_ctc97m04_001 using  lr_param.cponom   ,                            
                             lr_param.cod                              
  whenever error continue                                                   
  fetch c_ctc97m04_001 into lr_retorno.cpodes                               
  whenever error stop                                                       
                                                                                                                                       
  return lr_retorno.cpodes                                                              
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 

#========================================================================   
 function ctc97m04_valida_dados(lr_param)                                
#========================================================================  
                                                                           
define lr_param record                                                     
	cponom  like datkdominio.cponom                                          
end record                                                                 
                                                                           
define lr_retorno record                                                   
	cpocod  like datkdominio.cpocod,                                         
	cont    integer                                          
end record                                                                 
                                                                           
initialize lr_retorno.* to null                                            
                                                                                                                             
let lr_retorno.cont   = 0                                                                           
                                                                           
  open c_ctc97m04_007 using  lr_param.cponom   ,                           
                             mr_param.cod                             
  whenever error continue                                                  
  fetch c_ctc97m04_007 into lr_retorno.cont                         
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
 function ctc97m04_grava_dados()                                
#========================================================================  
 
 #--------------------------------------------------------                      
 # Grava Dados Flag Limite Unificado                                                 
 #--------------------------------------------------------                      
 if ctc97m04_valida_dados("ctc97m04_flg_uni") then                              
    call ctc97m04_atualiza_dados("ctc97m04_flg_uni", mr_ctc97m04.flg_uni)       
 else                                                                           
 	  call ctc97m04_inclui_dados("ctc97m04_flg_uni", mr_ctc97m04.flg_uni)         
 end if
 	                                                                        
 #--------------------------------------------------------      
 # Grava Dados Limite Unificado                          
 #--------------------------------------------------------      
 if ctc97m04_valida_dados("ctc97m04_lim_uni") then 
    call ctc97m04_atualiza_dados("ctc97m04_lim_uni", mr_ctc97m04.lim_uni)
 else
 	  call ctc97m04_inclui_dados("ctc97m04_lim_uni", mr_ctc97m04.lim_uni)
 end if	
 
 #-------------------------------------------------------- 
 # Grava Dados Limite Telefonico                 
 #-------------------------------------------------------- 
 if ctc97m04_valida_dados("ctc97m04_lim_tel") then                        
    call ctc97m04_atualiza_dados("ctc97m04_lim_tel", mr_ctc97m04.lim_tel)
 else                                                                  
 	  call ctc97m04_inclui_dados("ctc97m04_lim_tel", mr_ctc97m04.lim_tel)  
 end if	
 
                                                
 #-------------------------------------------------------- 
 # Grava Dados Limite Presencial               
 #-------------------------------------------------------- 
 if ctc97m04_valida_dados("ctc97m04_lim_pre") then                                   
    call ctc97m04_atualiza_dados("ctc97m04_lim_pre", mr_ctc97m04.lim_pre) 
 else                                                                                
 	  call ctc97m04_inclui_dados("ctc97m04_lim_pre", mr_ctc97m04.lim_pre)                             
 end if	                                                                             
  

 #-------------------------------------------------------- 
 # Grava Dados Matricula                 
 #-------------------------------------------------------- 
 if ctc97m04_valida_dados("ctc97m04_mat") then                            
    call ctc97m04_atualiza_matricula("ctc97m04_mat") 
 else                                                                       
 	  call ctc97m04_inclui_matricula("ctc97m04_mat")   
 end if	                        
 
                                                                                                                                                                                                    
#========================================================================  
end function                                                               
#========================================================================

#========================================================================                                                                                              
 function ctc97m04_inclui_dados(lr_param)                                             
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
                             

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue
    execute p_ctc97m04_005 using mr_param.cod   
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
 function ctc97m04_atualiza_dados(lr_param)                                             
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

                            

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue 
    execute p_ctc97m04_002 using lr_param.cpodes 
                               , lr_retorno.atlult                                          
                               , mr_param.cod  
                               , lr_param.cponom
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if 
                                                                                      
end function 

#========================================================================                                                                                              
 function ctc97m04_inclui_matricula(lr_param)                                             
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
                             

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = lr_retorno.atlult
   
    whenever error continue
    execute p_ctc97m04_005 using mr_param.cod   
                               , lr_retorno.cpodes
                               , lr_param.cponom
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'                                                                                                                                        
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if 
    
    let mr_ctc97m04.atldat  = lr_retorno.data_atual 
    let mr_ctc97m04.funmat  = g_issk.funmat
                       
                                                                                      
end function  

#========================================================================                                                                                              
 function ctc97m04_atualiza_matricula(lr_param)                                             
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
                          

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = lr_retorno.atlult    
   
    whenever error continue 
    execute p_ctc97m04_002 using lr_retorno.cpodes 
                               , lr_retorno.atlult                                          
                               , mr_param.cod 
                               , lr_param.cponom
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if 
    
    let mr_ctc97m04.atldat  = lr_retorno.data_atual 
    let mr_ctc97m04.funmat  = g_issk.funmat         
    
                                                                                      
end function  

#========================================================================   
 function ctc97m04_recupera_matricula(lr_param)                                          
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
                                                                                                                                                              
                                                                            
                                                                            
  open c_ctc97m04_003 using  lr_param.cponom   ,                            
                             mr_param.cod                              
  whenever error continue                                                   
  fetch c_ctc97m04_003 into lr_retorno.cpodes1 ,
                            lr_retorno.cpodes2                               
  whenever error stop                                                       
                                                                                                                                       
  return lr_retorno.cpodes1,
         lr_retorno.cpodes2                                                             
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 