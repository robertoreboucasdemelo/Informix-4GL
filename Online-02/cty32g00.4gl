#------------------------------------------------------------------------------#           
# Porto Seguro Cia Seguros Gerais                                              #           
#..............................................................................#           
# Sistema........: Central 24 Horas                                            #           
# Modulo.........: cty32g00                                                    #           
# Objetivo.......: Tarifa de Dezembro 2013 - Verifica se o Veiculo e Blindado  #           
# Analista Resp. : Moises Gabel                                                #           
# PSI            :                                                             #           
#..............................................................................#           
# Desenvolvimento: R.Fornax                                                    #           
# Liberacao      : 30/12/2013                                                  #           
#..............................................................................#           
                                                                                           
                                                                                           
globals "/homedsa/projetos/geral/globals/glct.4gl"                                        
                                                           
database porto                                                                             
                                                                                           
define m_prepare smallint    

#----------------------------------------------#                                                                  
 function cty32g00_prepare()                        
#----------------------------------------------#    
                                                    
  define l_sql char(500)                            
                                                    
  let l_sql = "select succod    ,    ",             
              "       aplnumdig ,    ",             
              "       itmnumdig ,    ", 
              "       dctnumseq ,    ",
              "       imsvlr         ",          
              " from abbmbli         ",             
              " where succod  = ?    ",
              " and aplnumdig = ?    ",
              " and itmnumdig = ?    ",
              " and dctnumseq = ?    "
                            
  prepare pcty32g00001  from l_sql                  
  declare ccty32g00001  cursor for pcty32g00001 
  	 	
  let m_prepare = true          
                                
end function 


----------------------------------------------#                                                                  
function cty32g00_verifblindagem()
----------------------------------------------#  

define lr_retorno record                         
   succod       like abbmbli.succod 
  ,aplnumdig    like abbmbli.aplnumdig           
  ,itmnumdig    like abbmbli.itmnumdig           
  ,dctnumseq    like abbmbli.dctnumseq           
  ,imsvlr	      like abbmbli.imsvlr                    
end record                                      	                                                                                             
		                                                                                   
   if m_prepare is null or
        m_prepare <> true then
        call cty32g00_prepare()
   end if
   
   initialize lr_retorno.* to null	                                                                                     
	
	open ccty32g00001 using g_documento.succod                                                                                     
        	               ,g_documento.aplnumdig                                                                                  
        	               ,g_documento.itmnumdig        	                                                                         
        	               ,g_funapol.autsitatu                                                                                    
	whenever error continue                                                                                                        
	                                                                                                                                                                                                                                                             
	fetch ccty32g00001 into lr_retorno.succod                                                                                      
                         ,lr_retorno.aplnumdig                                                                                      
                         ,lr_retorno.itmnumdig                                                                                      
                         ,lr_retorno.dctnumseq                                                                                      
                         ,lr_retorno.imsvlr                                                                                         
	whenever error stop                                                                                                            
	
	if sqlca.sqlcode = 0 then		                                                                                                                 
		return true		                                                                                                               
	else                                                                                                                           
		if sqlca.sqlcode = notfound then			                                                                                       
		              
			return false                                                                                                               
		else				                                                                                                                 
			error 'Erro SELECT ccty32g00001/ ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2                                         
               		error 'cty32g00 / cty32g00() / ',lr_retorno.succod                                                             
                                            ,' / ',lr_retorno.aplnumdig                                                            
                                            ,' / ',lr_retorno.dctnumseq                                                            
                                            ,' / ',lr_retorno.itmnumdig sleep 2                                                    
		end if                                                                                                                       
	end if	                                                                                                                       
end function                                                                                                                     