#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Regras Siebel                                              # 
# Modulo.........: ctc53m00                                                   # 
# Objetivo.......: Menu do Segmento                                           # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 31/03/2014                                                 # 
#.............................................................................# 


 database porto

#-----------------------------------------------------------
 function ctc53m00()
#-----------------------------------------------------------

   open window w_ctc53m00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc53m00--" at 3,1

   menu "SEGMENTO"

      command key ("C") "Cadastro"
                        "Manutencao dos Cadastros"
        call ctc53m00_cadastro()
        
      command key ("R") "Regras"                   
                        "Manutencao da Regras"  
        call ctc53m00_regra()                          
      
      

      command key (interrupt,E) "Encerra"
                        "Retorna ao Menu Anterior"
        exit menu
   end menu

   close window w_ctc53m00

   let int_flag = false

end function   

#-----------------------------------------------------------  
 function ctc53m00_cadastro()                                          
#-----------------------------------------------------------  

 menu "CADASTROS: "                    
      before menu                      
      show option "Parametros" 
      show option "Segmento_Auto"          
      show option "Segmento_Central"             
      show option "Motivos"                
      show option "Encerra"            
      
      command key ("P") "Parametros"
                        "Manutencao dos Parametros"
                         call ctc53m02()
                         
      command key ("A") "Segmento_Auto"
                        "Manutencao dos Segmentos do Auto"
                         call ctc53m31()                       
                         
      command key ("S") "Segmento_Central"
                        "Manutencao dos Segmentos da Central"
                         call ctc53m01()    
                         
      command key ("M") "Motivos"
                        "Manutencao dos Motivos"
                         call ctc53m03()          
      
      command key ("B") "Blocos"
                        "Manutencao dos Motivos"
                         call ctc53m25() 
                         
      command key ("1") "Fluxo 1"
                        "Clausulas do Fluxo 1"
                         call ctc53m23()   
      
      command key ("2") "Fluxo 2"
                        "Clausulas do Fluxo 1"
                         call ctc53m24()   
           
      command key (interrupt,E) "Encerra" 
             "Fim de servico"
             exit menu 
      
 end menu

end function

#-----------------------------------------------------------  
 function ctc53m00_regra()                                          
#-----------------------------------------------------------  

 menu "REGRAS: "                    
      before menu                      
      show option "Assuntos do Segmento"          
      show option "Funcao"             
      show option "Restricao"                
      show option "Encerra"            
      
      command key ("A") "Assuntos do Segmento"
                        "Manutencao de Assuntos do Segmento"
                         call ctc53m04()
                         
      command key ("F") "Funcao"
                        "Manutencao das Teclas de Funcoes"
                         call ctc53m00_funcao()     
                         
      command key ("R") "Restricao"
                        "Manutencao dos Assuntos com Restricao"
                         call ctc53m16()     
      
      
      command key (interrupt,E) "Encerra" 
             "Fim de servico"
             exit menu 
      
 end menu

end function

#-----------------------------------------------------------  
 function ctc53m00_funcao()                                          
#-----------------------------------------------------------  

 menu "FUNCAO: "                    
      before menu                      
      show option "Natureza"          
      show option "Limite"             
      show option "KM"
      show option "Diaria" 
      show option "Bloco"  
      show option "Problema"                
      show option "Encerra"            
      
      command key ("N") "Natureza"
                        "Assuntos Liberados para a Funcao Natureza"
                         call ctc53m18()
                         
      command key ("L") "Limite"
                        "Assuntos Liberados para a Funcao Limite"
                         call ctc53m19()    
                         
      command key ("K") "KM"
                        "Assuntos Liberados para a Funcao KM"
                         call ctc53m20()     
                         
      
      command key ("D") "Diaria"
                        "Assuntos Liberados para a Funcao Diaria"
                         call ctc53m21()   
                         
      command key ("B") "Bloco"
                        "Assuntos Liberados para a Funcao Bloco"
                         call ctc53m26()  
                         
      command key ("P") "Problema"
                        "Assuntos Liberados para a Funcao Problema"
                         call ctc53m29()        
                                                                                   
      
                         
      command key (interrupt,E) "Encerra" 
             "Fim de servico"
             exit menu 
      
 end menu

end function

