#-----------------------------------------------------------------------------#  
# Porto Seguro Cia Seguros Gerais                                             #  
#.............................................................................#  
# Sistema........: Central Itau                                               #  
# Modulo.........: cts56m00                                                   #  
# Objetivo.......: Funcao Para Carregar os Enderecos Indexados da Porto       #  
# Analista Resp. : Carlos Ruiz                                                #  
# PSI            :                                                            #  
#.............................................................................#  
# Desenvolvimento: R.Fornax                                                   #  
# Liberacao      : 29/12/2014                                                 #  
#.............................................................................#  
                                                                                 
                                                                                 
database porto                                                                   
                                                                                 
globals "/homedsa/projetos/geral/globals/glct.4gl"      

#========================================================================                                  
 function cts56m00_grava_endereco_porto_re(lr_param)                                  
#========================================================================         
                                                                                  
define lr_param record                                                            
	lclrsccod     like rlaklocal.lclrsccod  ,                                                                  
	lclltt        like datmlcl.lclltt       ,                                       
	lcllgt        like datmlcl.lcllgt                                                                                      
end record                                                                        
                                                                                  
define lr_retorno record                                                          
	erro integer , 
	msg  char(50)                                                                  
end record                                                                        
                                                                                  
initialize lr_retorno.* to null                                                   
                                                                                                                                                 
                                                                                  
  if lr_param.lclrsccod is not null then                                          
                                                                                                         
     if g_indexado.endnum1 = g_indexado.endnum2 and                           
        g_indexado.endcid1 = g_indexado.endcid2 then                          
                                                                              
        #--------------------------------------------------------             
        # Inclui o Endereco Indexado                                          
        #--------------------------------------------------------             
                                                                              
        call framc215_insere_lat_long(lr_param.lclrsccod                                          
                                     ,lr_param.lclltt                         
                                     ,lr_param.lcllgt)                  
        returning lr_retorno.erro,
                  lr_retorno.msg                                             
                                                                              
     end if                                                                   
                                                                                                                                                                                                                                      
   end if                                                                          
                                                                                  
#========================================================================         
end function                                                                      
#========================================================================     

#========================================================================   
 function cts56m00_acessa_endereco_porto_re(lr_param)                        
#========================================================================   
                                                                            
define lr_param record                                                      
	lclrsccod     like rlaklocal.lclrsccod  ,                                 
	lclltt        like datmlcl.lclltt       ,                                 
	lcllgt        like datmlcl.lcllgt                                         
end record                                                                  
                                                                                                                     
                                                                                                                                                       
  if lr_param.lclrsccod is not null and 
  	 lr_param.lclrsccod <> 0        and 
     lr_param.lclltt    is not null and 	 
     lr_param.lcllgt 	  is not null then
  	 
  	  return true  
                                                                            
   end if                                                                   
                 
   return false
                                                                            
#========================================================================   
end function                                                                
#========================================================================   

#========================================================================   
 function cts56m00_acessa_endereco_porto_auto(lr_param)                        
#========================================================================   
                                                                            
define lr_param record                                                      
	segnumdig  like abbmdoc.segnumdig                                                                     
end record 

define lr_retorno record                                                          
	erro     integer              , 
	msg      char(50)             ,
	lclltt   like datmlcl.lclltt  ,                                 
	lcllgt   like datmlcl.lcllgt  ,                 
	score    integer               
end record                                                                        
                                                                                  
initialize lr_retorno.* to null                                                                  
                                                                                                              
                                                                            
  if lr_param.segnumdig is not null and 
  	 lr_param.segnumdig <> 0        then 
 
  	  call fgseg002_consultarLatLongSegurado(lr_param.segnumdig,1)
  	  returning lr_retorno.erro   ,  
  	            lr_retorno.msg    ,
  	            lr_retorno.lclltt ,
  	            lr_retorno.lcllgt ,
  	            lr_retorno.score 
  	  
  	  if lr_retorno.lclltt is not null and 
  	  	 lr_retorno.lcllgt is not null then 
  	     return true
  	  end if 
                                                                            
   end if                                                                   
                 
   return false
                                                                            
#========================================================================   
end function                                                                
#======================================================================== 

#========================================================================   
 function cts56m00_recupera_latlong_porto_auto(lr_param)                   
#======================================================================== 
                                                                          
define lr_param record                                                    
	segnumdig  like abbmdoc.segnumdig                                       
end record                                                                
                                                                          
define lr_retorno record                                                  
	erro     integer              ,                                         
	msg      char(50)             ,                                         
	lclltt   like datmlcl.lclltt  ,                                         
	lcllgt   like datmlcl.lcllgt  ,                                         
	score    integer                                                        
end record                                                                
                                                                          
initialize lr_retorno.* to null                                           
                                                                          
                                                                          
  if lr_param.segnumdig is not null and                                   
  	 lr_param.segnumdig <> 0        then                                  
                                                                          
  	  call fgseg002_consultarLatLongSegurado(lr_param.segnumdig,1)        
  	  returning lr_retorno.erro   ,                                       
  	            lr_retorno.msg    ,                                        
  	            lr_retorno.lclltt ,                                        
  	            lr_retorno.lcllgt ,                                        
  	            lr_retorno.score                                           
  	                                                                                                                                                
   end if                                                                                            
                                                                                                 
    return  lr_retorno.lclltt,                                                                              
            lr_retorno.lcllgt     
                                                                                	                                                             
#======================================================================== 
end function                                                              
#========================================================================

#========================================================================     
 function cts56m00_grava_endereco_porto_auto(lr_param)                         
#========================================================================    
                                                                             
define lr_param record                                                       
	segnumdig  like abbmdoc.segnumdig    ,                                  
	lclltt     like datmlcl.lclltt       ,                                  
	lcllgt     like datmlcl.lcllgt                                          
end record                                                                   
                                                                             
define lr_retorno record                                                     
	erro integer ,                                                             
	msg  char(50)                                                              
end record                                                                   
                                                                             
initialize lr_retorno.* to null                                              
                                                                             
                                                                             
  if lr_param.segnumdig is not null then                                     
                                                                             
     if g_indexado.endnum1 = g_indexado.endnum2 and                          
        g_indexado.endcid1 = g_indexado.endcid2 then                         
                                                                             
        #--------------------------------------------------------            
        # Inclui o Endereco Indexado                                         
        #--------------------------------------------------------            
                                                                             
        call fgseg002_gravarLatLongSegurado(lr_param.segnumdig,                     
                                            1                 ,       
                                            lr_param.lclltt   ,
                                            lr_param.lcllgt   ,
                                            1                 ,
                                            g_issk.funmat)                       
        returning lr_retorno.erro,                                           
                  lr_retorno.msg                                             
                                                                             
     end if                                                                  
                                                                             
   end if                                                                    
                                                                             
#========================================================================    
end function                                                                 
#========================================================================    