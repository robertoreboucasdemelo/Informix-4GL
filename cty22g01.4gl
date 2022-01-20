#----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                            # 
#............................................................................# 
# Sistema........: Auto e RE - Itau Seguros                                  # 
# Modulo.........: cty22g01                                                  # 
# Objetivo.......: Recuperar E-mail Itau                                     # 
# Analista Resp. : Roberto Melo                                              # 
# PSI            :                                                           # 
#............................................................................# 
# Desenvolvimento: Roberto Melo                                              # 
# Liberacao      : 08/05/2011                                                # 
#............................................................................# 

database porto                                       
                                                     
globals "/homedsa/projetos/geral/globals/glct.4gl"  

#-----------------------------------------                                                                             
function cty22g01_email()                                                                                             
#-----------------------------------------                                                                            
                                                                                                                      
define lr_retorno  record                                                                                             
  maides      like gsakendmai.maides ,                                                                                
  ok          char(1)                ,                                                                                
  confirma    char(1)                ,                                                                                
  erro        integer                ,                                                                                
  msg         char(50)                                                                                                
end record                                                                                                            
                                                                                                                      
                                                                                                                      
 initialize lr_retorno.* to null                                                                                      
                                                                                                                      
                                                                                                                      
   open window cty22g01  at 10,7 with form "cty22g01"                                                               
        attribute (border,form line 1)                                                                                
                                                                                                                      
   input by name lr_retorno.maides without defaults                                                                   
                                                                                                                      
     before field maides                                                                                              
        display by name lr_retorno.maides attribute (reverse)                                                         
                                                                                                                      
         if g_documento.ciaempcod = 84 then                                                                           
            let lr_retorno.maides =  g_doc_itau[1].segmaiend                                                          
         end if                                                                                                       
                                                                                                                      
     after  field maides                                                                                              
        display by name lr_retorno.maides                                                                             
                                                                                                                      
            let lr_retorno.ok = "n"                                                                                   
                                                                                                                      
            call cty17g00_ssgtmail(lr_retorno.maides)                                                                 
                 returning lr_retorno.ok                                                                              
                                                                                                                      
            if downshift(lr_retorno.ok) = "n" then                                                                    
               error "E-mail Invalido."                                                                               
               next field maides                                                                                      
            end if                                                                                                    
                                                                                                                      
            if lr_retorno.maides is not null then                                                                     
                                                                                                                      
                 let lr_retorno.confirma = cts08g01('C','S','','CONFIRMA INCLUSAO DO E-MAIL ITAU' ,'','')                  
                                                                                                                      
               if upshift(lr_retorno.confirma) <> "S"  then                                                           
                  continue input                                                                                      
               end if                                                                                                 
                                                                                                                      
            end if                                                                                                    
                                                                                                                      
                                                                                                                      
     on key (f17,control-c,interrupt)                                                                                 
                                                                                                                      
            if lr_retorno.maides is null then                                                                         
                                                                                                                      
               let lr_retorno.confirma = cts08g01('C','S','', 'E-MAIL NAO INCLUSO' ,'DESEJA SAIR SEM INCLUIR?','')    
                                                                                                                      
               if lr_retorno.confirma = "N" then                                                                      
                  next field maides                                                                                   
               end if                                                                                                 
                                                                                                                      
            end if                                                                                                    
                                                                                                                      
            let int_flag = true                                                                                       
            exit input                                                                                                
                                                                                                                      
   end input                                                                                                          
                                                                                                                      
   close window cty22g01                                                                                             
                                                                                                                      
   return lr_retorno.maides                                                                                           
                                                                                                                      
end function                                                                                                          