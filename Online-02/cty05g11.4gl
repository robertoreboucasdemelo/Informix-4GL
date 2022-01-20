#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty05g11                                                    #
# Objetivo.......: Extrato Limites Help Desk Itau                              #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 20/05/2015                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint


define mr_param record
      descanso     integer
     ,texto        char(60)          
     ,lim_uni      integer        
     ,lim_tel      integer
     ,lim_pre      integer
     ,qtd_tel      integer
     ,qtd_pre      integer
     ,limite_msg   char(60)
     ,lim_uni_msg  char(60)
end record

define mr_retorno record
     flg_uni    char(01),
     saldo_uni  integer ,
     saldo_tel  integer ,
     saldo_pre  integer  
end record





#----------------------------------------------#
 function cty05g11(lr_param)
#----------------------------------------------#

define lr_param record
	 itaciacod    like datmitaapl.itaciacod       ,    
	 itaramcod    like datmitaapl.itaramcod       ,    
	 itaaplnum    like datmitaapl.itaaplnum       ,    
	 itaaplitmnum like datmitaaplitm.itaaplitmnum      
end record

define lr_retorno record
    atende smallint
end record

initialize lr_retorno.*, mr_param.* to null

    
     call cty05g11_input(lr_param.itaciacod    , 
                         lr_param.itaramcod    , 
                         lr_param.itaaplnum    , 
                         lr_param.itaaplitmnum )
     returning lr_retorno.atende                    
                         
     return lr_retorno.atende                     
                         
                         
end function





#----------------------------------------------#
 function cty05g11_input(lr_param)
#----------------------------------------------#

define lr_param record                                
	 itaciacod    like datmitaapl.itaciacod       ,     
	 itaramcod    like datmitaapl.itaramcod       ,     
	 itaaplnum    like datmitaapl.itaaplnum       ,     
	 itaaplitmnum like datmitaaplitm.itaaplitmnum       
end record   

define lr_retorno record                                          
   atende smallint
end record

     open window cty05g11 at 07,17 with form "cty05g11" 
     attribute (form line 1, border)                    

     call cty05g11_recupera_limite()
     
     call cty05g11_recupera_utilizado(lr_param.itaciacod    ,      
                                      lr_param.itaramcod    , 
                                      lr_param.itaaplnum    , 
                                      lr_param.itaaplitmnum ) 
     
     call cty05g11_valida_atendimento()
     returning lr_retorno.atende
     
            
     
     
     
     display by name  mr_param.lim_uni      ,            
                      mr_param.lim_tel      ,      
                      mr_param.lim_pre      ,      
                      mr_param.qtd_tel      ,      
                      mr_param.qtd_pre      ,
                      mr_param.limite_msg   ,
                      mr_param.lim_uni_msg  
     
     display by name mr_param.texto attribute (reverse)  
                                                 

     input by name mr_param.descanso without defaults


     #-----------------------------------------------------------------------------------
     # BEFORE FIELD
     #-----------------------------------------------------------------------------------

           before field descanso
              display by name mr_param.descanso

     #-----------------------------------------------------------------------------------
     # AFTER FIELD
     #-----------------------------------------------------------------------------------

           after field descanso
              display by name mr_param.descanso

    

     on key(f17, interrupt,control-c)
        let int_flag = false
        exit input


     end input

     close window cty05g11
     
     return lr_retorno.atende

end function



#----------------------------------------------#
 function cty05g11_recupera_utilizado(lr_param)
#----------------------------------------------#

define lr_param record 
	 itaciacod    like datmitaapl.itaciacod       ,    
	 itaramcod    like datmitaapl.itaramcod       ,    
	 itaaplnum    like datmitaapl.itaaplnum       ,    
	 itaaplitmnum like datmitaaplitm.itaaplitmnum      
end record


define lr_retorno record
	 utilizado  integer ,
	 c24astcod  like datkassunto.c24astcod
end record

initialize lr_retorno.* to null


       let lr_retorno.c24astcod = "R66"      
       
       
       #--------------------------------------------------------         
       # Recupera a Quantidade de Servicos Utilizados R66                   
      #--------------------------------------------------------         
       call cts61m03_qtd_servico_assunto(lr_param.itaciacod          ,   
                                         lr_param.itaramcod          ,   
                                         lr_param.itaaplnum          ,   
                                         lr_param.itaaplitmnum       ,   
                                         ""                          ,   
                                         lr_retorno.c24astcod        )   
       returning mr_param.qtd_tel 
       
       let lr_retorno.c24astcod = "R67" 
       
       #--------------------------------------------------------         
       # Recupera a Quantidade de Servicos Utilizados R67                   
       #--------------------------------------------------------         
       call cts61m03_qtd_servico_assunto(lr_param.itaciacod          ,   
                                         lr_param.itaramcod          ,   
                                         lr_param.itaaplnum          ,   
                                         lr_param.itaaplitmnum       ,   
                                         ""                          ,   
                                         lr_retorno.c24astcod        )   
       returning mr_param.qtd_pre                                                               
     
     
      

end function

#----------------------------------------------#
 function cty05g11_recupera_limite()
#----------------------------------------------#

  
     #--------------------------------------------------------          
     # Recupera a Flag de Limite Unificado                      
     #--------------------------------------------------------  
     call ctc97m04_recupera_dados("ctc97m04_flg_uni",g_doc_itau[1].itaasisrvcod)           
     returning mr_retorno.flg_uni
     
     if mr_retorno.flg_uni = "S" then
     	  
     	  let mr_param.lim_uni_msg = "LIMITE UNICO PARA AMBOS"	
     	  
     	  #--------------------------------------------------------   
     	  # Recupera o Limite Unificado                               
     	  #--------------------------------------------------------   
     	  call ctc97m04_recupera_dados("ctc97m04_lim_uni",g_doc_itau[1].itaasisrvcod)            
     	  returning mr_param.lim_uni                               
     	      	  
     	  
     else
     	  
     	  let mr_param.limite_msg  = "Limite"
     	  
     	  #-------------------------------------------------------- 
     	  # Recupera o Limite Telefonico                            
     	  #-------------------------------------------------------- 
     	  call ctc97m04_recupera_dados("ctc97m04_lim_tel",g_doc_itau[1].itaasisrvcod)          
     	  returning mr_param.lim_tel                             
     	                                                            
     	  #-------------------------------------------------------- 
     	  # Recupera o Limite Presencial                            
     	  #-------------------------------------------------------- 
     	  call ctc97m04_recupera_dados("ctc97m04_lim_pre",g_doc_itau[1].itaasisrvcod)          
     	  returning mr_param.lim_pre                             
     	      	   
     end if


end function

#----------------------------------------------#                                                 
 function cty05g11_valida_atendimento()                                                             
#----------------------------------------------#

define lr_retorno record
	 esgotado smallint
end record	

   let lr_retorno.esgotado = false                                           
               
   let mr_retorno.saldo_uni = 0                                                                                               
   let mr_retorno.saldo_tel = 0                                                                                             
   let mr_retorno.saldo_pre = 0         
              
             
   if mr_retorno.flg_uni = "S" then                        
      let mr_retorno.saldo_uni = (mr_param.lim_uni - (mr_param.qtd_tel + mr_param.qtd_pre) )  
      
      if mr_retorno.saldo_uni < 1 then 
      	 let lr_retorno.esgotado = true
      end if               
   else
   	  let mr_retorno.saldo_tel = mr_param.lim_tel - mr_param.qtd_tel
   	  let mr_retorno.saldo_pre = mr_param.lim_pre - mr_param.qtd_pre  
   	  
   	  if mr_retorno.saldo_tel < 1 and
   	  	 mr_retorno.saldo_pre < 1 then     
   	  	 let lr_retorno.esgotado = true    
   	  end if                               
   end if           
              
              
   if lr_retorno.esgotado then            
          let mr_param.texto = "               LIMITES ESGOTADOS                "  
          return false      
   end if           
              
   let mr_param.texto = "              LIMITES DISPONIVEIS                "              
              
   return true            
                                                                                                             
                                                                                                 
end function 

#----------------------------------------------#                                                                                      
 function cty05g11_atendimento_unificado()                                                                                                               
#----------------------------------------------# 

   if mr_retorno.flg_uni = "S" then
   	  return true
   else
   	  return false
   end if
 
end function   

#----------------------------------------------#             
 function cty05g11_atendimento_telefonico()                   
#----------------------------------------------#             
                                                             
   if mr_retorno.saldo_tel < 1 then                      
   	  return false                                            
   else                                                      
   	  return true                                           
   end if                                                    
                                                             
end function   

#----------------------------------------------#                                                       
 function cty05g11_atendimento_presencial()              
#----------------------------------------------#         
                                                         
   if mr_retorno.saldo_pre < 1 then                      
   	  return false                                       
   else                                                  
   	  return true                                        
   end if                                                
                                                         
end function                                             