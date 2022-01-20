#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc91m28                                                   # 
# Objetivo.......: Menu de Alertas                                            # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 27/10/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"


#=============================                                                                                  
 function ctc91m28(lr_param)                                                                                   
#=============================

define lr_param record            
  itaclisgmcod         smallint,  
  itaclisgmdes         char(60)   
end record                        
                                                                                                                                                                                                                                                                                                                                                                                                             
                                                                                             
   open window WIN_ALERTA at 04,02 with 20 rows, 78 columns                                                                                                                                                                                                                                                                  
   
   call ctc91m28_menu(lr_param.itaclisgmcod,
                      lr_param.itaclisgmdes)
  
   close window WIN_ALERTA                                                                         
                                                                                             
end function                                                                                     

#=========================                                                
 function ctc91m28_menu(lr_param)                                                 
#========================= 

define lr_param record                
  itaclisgmcod         smallint,      
  itaclisgmdes         char(60)       
end record                            

                                                                                                                       
 menu "TIPO DE ALERTAS: "                                                        
      before menu                                                          
      show option "Assunto"                                                                                       
      show option "Problema"  
      show option "Assistencia"  
      show option "Motivo"                                                                                                 
      show option "Encerra"                                                
                                                                           
      command key ("A") "Assunto"                                                   
                         call ctc91m29(lr_param.itaclisgmcod,
                                       lr_param.itaclisgmdes)                                  
                                                                           
      command key ("P") "Problema"                             
                         call ctc91m34(lr_param.itaclisgmcod,  
                                       lr_param.itaclisgmdes)  
      
      
      command key ("T") "Assistencia"                                                      
                         call ctc91m33(lr_param.itaclisgmcod, 
                                       lr_param.itaclisgmdes) 
                                                           
                                                                           
      command key ("M") "Motivo"                                                                   
                         call ctc91m36(lr_param.itaclisgmcod,
                                       lr_param.itaclisgmdes)                                  
                                                                                                 
                                                                           
      command key (interrupt,E) "Encerra"                                  
             "Fim de servico"                                              
             exit menu                                                     
                                                                           
  end menu                                                                 
                                                                           
                                                                           
end function                                                               