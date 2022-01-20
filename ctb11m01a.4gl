############################################################################### 
# Nome do Modulo: ctb11m01a                                Robson Ruas        # 
#                                                                             # 
#  Pop up Aviso De Alteracao SAP                           02/2013            # 
############################################################################### 
# Alteracoes:                                                                 # 
#                                                                             # 
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             # 
#-----------------------------------------------------------------------------# 
database porto 
function ctb11m01a(l_socopgnum)                                               
                                                                                               
define lr_tela record                                                                          
   finsispgtordnum char(16)                                                                      
end record    

define l_socopgnum   like dbsmopg.socopgnum    
define lr_ret        integer 
                                                

 let lr_ret = 0 

  initialize lr_tela.* to null
                                                                                               
   open window w_ctb11m01a at 04,15 with form "ctb11m01a"                                      
                                                                                               
   input lr_tela.* without defaults from finsispgtordnum                                       
                                                                                               
      before field finsispgtordnum

        display by name lr_tela.finsispgtordnum attribute (reverse)                           
                                                                                               
      after field finsispgtordnum                                                              
         display by name lr_tela.finsispgtordnum                                               
                                                                                               
         if fgl_lastkey() = fgl_keyval("F8") then                                              
            if lr_tela.finsispgtordnum is null or                                              
               lr_tela.finsispgtordnum = " "   then                                            
               error 'Antes de gravar, preencha o numero da OP SAP'                            
               sleep 2                                                                         
               next field finsispgtordnum                                                      
            end if
         end if                                                                                
         
         if fgl_lastkey() <> fgl_keyval("F8") then                                              
            if lr_tela.finsispgtordnum is not null then
               error 'Tecle F8 para grava o numero SAP'                            
               sleep 2                                                                         
               next field finsispgtordnum                                                      
            end if                                                                             
         end if                               
         
         if lr_tela.finsispgtordnum is null then 
           error 'Tecle Ctrl+c para Sair' 
           sleep 2                                  
           next field finsispgtordnum               
         end if 
                                                                                               
         on key (f8)      

            whenever error continue
            update dbsmopg                                                                     
               set finsispgtordnum = lr_tela.finsispgtordnum                                   
             where socopgnum       = l_socopgnum                                               
            whenever error stop                                                                
            if sqlca.sqlcode <> 0 then                                                         
               error 'Erro ',  sqlca.sqlcode, ' ao atualizar o numero da OP SAP'               
               sleep 2                                                                         
               next field finsispgtordnum                                                      
            else 
               error "Numero SAP atualizado com sucesso "
               sleep 2
               let lr_ret = 1 
            end if                                                                             
            
          on key (interrupt)                                                                    
             exit input                                                                         
                                                                                               
   end input                                                                                   
                                                                                               
close window w_ctb11m01a  

  return  lr_ret                                                                    
                                                                                               
end function                                                                                   

















































