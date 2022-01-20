#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty46g00                                                    #
# Objetivo.......: Registro Help Desk Itau                                     #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 24/05/2015                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint


#----------------------------------------------#
 function cty46g00_prepare()
#----------------------------------------------#

  define l_sql char(2000)
    
  let l_sql = " select count(*)      "               
             ," from datkdominio     "               
             ," where cponom =  ?    "               
             ," and   cpodes =  ?    "               
  prepare pcty46g00011 from l_sql                 
  declare ccty46g00011 cursor for pcty46g00011 
  	
  let l_sql = " select cpodes        "               
             ," from datkdominio     "               
             ," where cponom =  ?    "                            
  prepare pcty46g00012 from l_sql                
  declare ccty46g00012 cursor for pcty46g00012 	
    
    	   
  let m_prepare = true

end function



#-------------------------------------------------------#                  
 function cty46g00_verifica_data_marrom(lr_param)                    
#-------------------------------------------------------#                  
                                                                     
define lr_param record                                               
  incvigdat     like datmresitaapl.incvigdat                   
end record                                                           
                                                                     
define lr_retorno record                                             
  data       date,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty46g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_data"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica a Data de Corte do Linha Marrom                              
    #--------------------------------------------------------        
                                                                     
    open ccty46g00012  using  lr_retorno.chave                   
                                       
    whenever error continue                                          
    fetch ccty46g00012 into lr_retorno.data                       
    whenever error stop                                              
                                                                     
    if lr_param.incvigdat >=  lr_retorno.data   then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function 

#-------------------------------------------------#                  
 function cty46g00_verifica_plano_marrom(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  srvcod     like datmresitaaplitm.srvcod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty46g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_plano"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Plano Bloqueia Linha Marrom                             
    #--------------------------------------------------------        
                                                                     
    open ccty46g00011  using  lr_retorno.chave  ,                  
                                lr_param.srvcod                
    whenever error continue                                          
    fetch ccty46g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function

#----------------------------------------------------#                  
 function cty46g00_verifica_produto_marrom(lr_param)                    
#----------------------------------------------------#                  
                                                                     
define lr_param record                                               
  prdcod     like datmresitaaplitm.prdcod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty46g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_prod"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Produto Bloqueia Linha Marrom                             
    #--------------------------------------------------------        
                                                                     
    open ccty46g00011  using  lr_retorno.chave  ,                  
                              lr_param.prdcod                
    whenever error continue                                          
    fetch ccty46g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function  

#----------------------------------------------------#                  
 function cty46g00_verifica_grupo_marrom(lr_param)                    
#----------------------------------------------------#                  
                                                                     
define lr_param record                                               
  grpcod       like datkresitagrp.grpcod                    
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty46g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_grp"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Produto Bloqueia Linha Marrom                             
    #--------------------------------------------------------        
                                                                     
    open ccty46g00011  using  lr_retorno.chave  ,                  
                              lr_param.grpcod                
    whenever error continue                                          
    fetch ccty46g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function    


#----------------------------------------------------#                               
 function cty46g00_bloqueia_linha_marrom(lr_param)                                   
#----------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 grpcod           like datkresitagrp.grpcod        ,
 	 prdcod           like datmresitaaplitm.prdcod     ,
 	 srvcod           like datmresitaaplitm.srvcod     ,                                                                       
   incvigdat        like datmresitaapl.incvigdat                                
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty46g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty46g00_verifica_grupo_marrom(lr_param.grpcod)       and 
 	  cty46g00_verifica_produto_marrom(lr_param.prdcod)     and
 	  cty46g00_verifica_plano_marrom(lr_param.srvcod)       and
 	  cty46g00_verifica_data_marrom(lr_param.incvigdat)     then                              
        return true                                                             
 else                                                                             
        return false         
 end if                                                                  
                                                                                   
                                                                                   
end function
                                                                    