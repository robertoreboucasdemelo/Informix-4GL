#----------------------------------------------------------------------------#   
# Porto Seguro Cia Seguros Gerais                                            #   
#............................................................................#   
# Sistema........: Central 24hs - Itau                                       #   
# Modulo.........: ctc96m05                                                  #   
# Objetivo.......: Lista de produtos                                         #   
# Analista Resp. : Amilton Pinto                                             #   
# PSI            :                                                           #   
#............................................................................#   
# Desenvolvimento: Amilton Pinto                                             #   
# Liberacao      : 01/07/2012                                                #   
#............................................................................#   
database porto                                                                           
                                                                                 
define m_ctc96m09_prep  smallint     



#------------------------------------------------------------------------------  
function ctc96m09_prepare()                                                      
#------------------------------------------------------------------------------  

define l_sql char(200)

  let l_sql = "select grpcod,   " ,
              "       desnom   " ,
              " from datkresitagrp " ,
              " order by grpcod "                      
  prepare p_ctc96m09_001  from l_sql                 
  declare c_ctc96m09_001  cursor for p_ctc96m09_001  
  
  
  let m_ctc96m09_prep = true 

end function   


#--------------------------------------------------------------------------
function ctc96m09()
#--------------------------------------------------------------------------

   define lr_retorno       record
          grpcod  like datkresitagrp.grpcod  
         ,desnom  like datkresitagrp.desnom         
   end record
   
   define t_ctc96m09    array[500] of record           
         grpcod   like datkresitagrp.grpcod  
        ,desnom   like datkresitagrp.desnom
   end record 
      
   
   define l_index     integer                     
         ,l_qtde      smallint
         ,arr_aux     integer
                   
   let l_qtde     = 0
   let arr_aux    = 0        
                  
   
   # inicializando array tela de naturezas
   for l_index  =  1  to  500
       initialize  t_ctc96m09[l_index].* to  null       
   end for 
   
   
   if m_ctc96m09_prep is null or                                                          
      m_ctc96m09_prep <> true then                                                        
      
      call ctc96m09_prepare()                                                             
   end if                                                                                 
                                                                                          
   let l_index = 1                                                                     
                                                                                       
   open c_ctc96m09_001                                                                 
                                                                                       
   foreach c_ctc96m09_001 into t_ctc96m09[l_index].grpcod,                    
                               t_ctc96m09[l_index].desnom                    
                               
                                                                                                                                                                              
   let l_index = l_index + 1                                                           
                                                                                       
   end foreach                                                                         

   
   #--------------
   # Abre a tela 
   #--------------
   open window w_ctc96m09 at 07,4 with form "ctc96m09"
              attribute(form line 1, border)                    
                                                            
   let int_flag = false                                    
                                                            
   message "  (F8)Seleciona "
     
   call set_count(l_index)

   display array t_ctc96m09 to s_ctc96m09.* 
              
      on key (F8)                  
         
         
         let arr_aux = arr_curr()                                                          
             
             let lr_retorno.grpcod = t_ctc96m09[arr_aux].grpcod
             let lr_retorno.desnom = t_ctc96m09[arr_aux].desnom                          

             
            exit display   
               
      on key (interrupt,control-c,f17)                
            error "ESCOLHA UM GRUPO COM (F8)Seleciona"
            #exit display                             
         
   end display    
   
   close window  w_ctc96m09
      
   let int_flag = false  
   
   return lr_retorno.*
   
end function 
  
