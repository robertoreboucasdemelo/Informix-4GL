#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty43g00                                                    #
# Objetivo.......: Upgrade Frota                                               #
# Analista Resp. : R.Fornax                                                    #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 17/11/2015                                                  #
#..............................................................................#
# 02/12/2015     : Roberto Melo   Frota 
#------------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint
define m_acesso  smallint

#----------------------------------------------#
 function cty43g00_prepare()
#----------------------------------------------#

  define l_sql char(500)
  
  let l_sql = ' select count(*)      '               
             ,' from datkdominio     '               
             ,' where cponom =  ?    '               
             ,' and   cpodes =  ?    '               
  prepare p_cty43g00_001 from l_sql                  
  declare c_cty43g00_001 cursor for p_cty43g00_001
  	
  let l_sql = ' select cpodes        '               
             ,' from datkdominio     '               
             ,' where cponom =  ?    '                            
  prepare p_cty43g00_002 from l_sql                  
  declare c_cty43g00_002 cursor for p_cty43g00_002		
  	
  		
  let m_prepare = true

end function

#-------------------------------------------------#                  
 function cty43g00_verifica_plano_frota(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  itaasiplncod     like datkitaasipln.itaasiplncod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty43g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty43g00_plano"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Plano Permite Frota                             
    #--------------------------------------------------------        
                                                                     
    open c_cty43g00_001  using  lr_retorno.chave  ,                  
                                lr_param.itaasiplncod                
    whenever error continue                                          
    fetch c_cty43g00_001 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function   

#-------------------------------------------------#                  
 function cty43g00_verifica_veiculo_frota(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  vcltipcod     like datkitavcltip.vcltipcod                           
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty43g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty43g00_veic"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Tipo de Veiculo e Frota                             
    #--------------------------------------------------------        
                                                                     
    open c_cty43g00_001  using  lr_retorno.chave  ,                  
                                lr_param.vcltipcod                 
    whenever error continue                                          
    fetch c_cty43g00_001 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function 

#-------------------------------------------------#                  
 function cty43g00_verifica_produto_frota(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  itaprdcod     like datkitaprd.itaprdcod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty43g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty43g00_prod"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Produto Permite Frota                             
    #--------------------------------------------------------        
                                                                     
    open c_cty43g00_001  using  lr_retorno.chave  ,                  
                                lr_param.itaprdcod                
    whenever error continue                                          
    fetch c_cty43g00_001 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function   

#-------------------------------------------------#                  
 function cty43g00_verifica_data_frota(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  itaaplvigincdat     like datmitaapl.itaaplvigincdat                   
end record                                                           
                                                                     
define lr_retorno record                                             
  data       date,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty43g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty43g00_data"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica a Data de Corte do  Frota                             
    #--------------------------------------------------------        
                                                                     
    open c_cty43g00_002  using  lr_retorno.chave                   
                                       
    whenever error continue                                          
    fetch c_cty43g00_002 into lr_retorno.data                       
    whenever error stop                                              
                                                                     
    if lr_param.itaaplvigincdat >=  lr_retorno.data   then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function   

#-------------------------------------------------#                               
  function cty43g00_valida_upgrade_frota(lr_param)                                   
#-------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 itaasiplncod     like datkitaasipln.itaasiplncod         ,
 	 vcltipcod        like datkitavcltip.vcltipcod            ,
 	 itaprdcod        like datkitaprd.itaprdcod               ,                                                
   itaaplvigincdat  like datmitaapl.itaaplvigincdat                             
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty43g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty43g00_verifica_plano_frota(lr_param.itaasiplncod)      and
 	  cty43g00_verifica_veiculo_frota(lr_param.vcltipcod)       and
 	  cty43g00_verifica_produto_frota(lr_param.itaprdcod)       and
 	  cty43g00_verifica_data_frota(lr_param.itaaplvigincdat)    then                              
        return true                                                             
 else                                                                             
        return false         
 end if                                                                  
                                                                                   
                                                                                   
 end function 
 
#----------------------------------------------------#                               
 function cty43g00_restringe_upgrade_frota(lr_param)                                   
#----------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 c24astcod        like datkassunto.c24astcod              ,
 	 vcltipcod        like datkitavcltip.vcltipcod            ,                                               
   itaaplvigincdat  like datmitaapl.itaaplvigincdat                             
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty43g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty43g00_verifica_assunto_frota(lr_param.c24astcod)       and
 	  cty43g00_restringe_veiculo_frota(lr_param.vcltipcod)      and
 	  cty43g00_verifica_data_frota(lr_param.itaaplvigincdat)    then                              
        return true                                                             
 else                                                                             
        return false         
 end if                                                                  
                                                                                   
                                                                                   
 end function 
 
 #-------------------------------------------------#                  
 function cty43g00_verifica_assunto_frota(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  c24astcod     like datkassunto.c24astcod                           
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty43g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty43g00_ass"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Assunto e Frota                             
    #--------------------------------------------------------        
                                                                     
    open c_cty43g00_001  using  lr_retorno.chave  ,                  
                                lr_param.c24astcod                 
    whenever error continue                                          
    fetch c_cty43g00_001 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function

#-------------------------------------------------#                  
 function cty43g00_restringe_veiculo_frota(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  vcltipcod     like datkitavcltip.vcltipcod                           
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty43g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty43g00_rest"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Tipo de Veiculo Tem Restricao                            
    #--------------------------------------------------------        
                                                                     
    open c_cty43g00_001  using  lr_retorno.chave  ,                  
                                lr_param.vcltipcod                 
    whenever error continue                                          
    fetch c_cty43g00_001 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function


#----------------------------------------------------#                               
 function cty43g00_acesso_upgrade_frota(lr_param)                                   
#----------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 c24astcod        like datkassunto.c24astcod              ,
 	 itaprdcod        like datkitaprd.itaprdcod               , 
 	 itaasiplncod     like datkitaasipln.itaasiplncod         ,                              
 	 vcltipcod        like datkitavcltip.vcltipcod            ,                                               
   itaaplvigincdat  like datmitaapl.itaaplvigincdat                             
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty43g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty43g00_verifica_assunto_frota(lr_param.c24astcod)       and
 	  cty43g00_verifica_produto_frota(lr_param.itaprdcod)       and
 	  cty43g00_verifica_plano_frota(lr_param.itaasiplncod)      and
 	  cty43g00_verifica_veiculo_frota(lr_param.vcltipcod)       and
 	  cty43g00_verifica_data_frota(lr_param.itaaplvigincdat)    then                              
        return true                                                             
 else                                                                             
        return false         
 end if                                                                  
                                                                                   
                                                                                   
 end function                                                                                                                      
