############################################################################### 
# Nome do Modulo: ctc00m02c                                Robson Ruas        # 
#                                                                             # 
#  Pop up Aviso De Alteracao SAP                           02/2013            # 
############################################################################### 
# Alteracoes:                                                                 # 
#                                                                             # 
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             # 
#-----------------------------------------------------------------------------# 

function ctc00m02c()                                         
                                                                           
define lr_tela record                                                      
    abc char(1)                                                            
end record                                                                 
                                                                           
    open window w_ctc00m02c at 04,15 with form "ctc00m02c"                 
                                                                           
    input lr_tela.* without defaults from abc                              
                                                                           
       before field abc                                                    
          error ''                                                         
                                                                           
       after field abc                                                     
          if fgl_lastkey() <> fgl_keyval("F8") then                        
             error "Por favor confirme com a tecla 'F8' "                  
             sleep 3                                                       
             next field abc                                                
          end if                                                           
                                                                           
          on key (f8)                                                      
             exit input                                                    
                                                                           
          on key (interrupt)                                               
             error "Por favor confirme com a tecla 'F8' "                  
             sleep 3                                                       
             next field abc                                                
                                                                           
    end input                                                              
                                                                           
 close window w_ctc00m02c                                                  
                                                                           
end function                                                               
