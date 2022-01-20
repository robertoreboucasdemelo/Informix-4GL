#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Regras Siebel                                             #
# Modulo.........: ctc69m31                                                  #
# Objetivo.......: Consulta de Clausulas e Planos                            #
# Analista Resp. : Priscila Staingel                                         #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 28/04/2015                                                #
#............................................................................#

                                                              
globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_tela record  
   empcod  like datkplncls.empcod         , 
   empnom  like gabkemp.empnom            ,
   clscod  like datkplncls.clscod         ,  
   clsnom  char(60)                       ,  
   prfcod  like datkplncls.prfcod         , 
   desper  char(60)                       , 
   paccod  integer                        ,
   pacdes  char(60)                       ,
   obs     char(70)         
end record

define mr_label record
  label1 char(10)	,
  label2 char(10)	, 
  label3 char(10)	 
end record	


define mr_array array[500] of record
   seta         char(1)                        ,           
   plnclscod    like datkplncls.plnclscod      ,
   empcod1      like datkplncls.empcod         ,
   ramcod       like datkplncls.ramcod         ,
   clscod1      like datkplncls.clscod         ,
   prfcod1      like datkplncls.prfcod         , 
   clssitdes    char(03)                       ,
   irdclsdes    char(03)                       ,
   clsviginidat like datkplncls.clsviginidat   ,
   clsvigfimdat like datkplncls.clsvigfimdat   
end record  

define mr_rodape array[500] of record
   empnom1      like gabkemp.empnom            ,
   clsnom1      char(60)                       , 
   desper1      char(60)                       ,
   regsitdes    char(07)                       
end record 

define mr_retorno record  
   paclim        integer
 , pacuni        char(60) 
 , canal         integer
end record

define m_prepare smallint

#------------------------------------------------------#        
function  ctc69m31_prepare()
#------------------------------------------------------#        

define l_sql  char(500)
define l_join char(100) 

  let l_sql = " select a.plnclscod    ,   ", 
              "        a.empcod       ,   ",
              "        a.ramcod       ,   ",
              "        a.clscod       ,   ",
              "        a.prfcod       ,   ",
              "        a.clssitflg    ,   ",
              "        a.irdclsflg    ,   ",
              "        a.clsviginidat ,   ",
              "        a.clsvigfimdat ,   ",
              "        a.regsitflg        ",
              " from datkplncls a         ",
              " where "
              
   if mr_tela.empcod is not null then          
       let l_join = " a.empcod = ", mr_tela.empcod          
       let l_sql  = l_sql clipped, l_join                 
   end if 
   
   
   if mr_tela.clscod is not null then                                      
       
       if mr_tela.empcod is not null then      
            let l_join = " and a.clscod = '", mr_tela.clscod, "'" 
       else
       	    let l_join = " a.clscod = '", mr_tela.clscod, "'"  
       end if 
       	                         
       let l_sql  = l_sql clipped, l_join clipped                   
   end if 
   
   if mr_tela.prfcod is not null then                              
       
       if mr_tela.empcod is not null or
       	  mr_tela.clscod is not null then                              
            let l_join = " and a.prfcod = ", mr_tela.prfcod          
       else                                                        
       	    let l_join = " a.prfcod = ", mr_tela.prfcod              
       end if                                                      
       	                                                           
       let l_sql  = l_sql clipped, l_join clipped                  
   end if 
   
   
   if mr_tela.paccod is not null then                              
                                                                   
       if mr_tela.empcod is not null or                            
       	  mr_tela.clscod is not null or
       	  mr_tela.prfcod is not null then                         
            let l_join = " and a.plnclscod in (select b.plnclscod     ", 
                                               " from datksrvplncls b ",
                                               " where b.srvcod =     ", mr_tela.paccod, ")"          
       else                                                        
       	    let l_join = " a.plnclscod in (select b.plnclscod   ",                  
       	                                 " from datksrvplncls b ",                  
       	                                 " where b.srvcod =     ", mr_tela.paccod, ")"   
       	                
       end if                                                      
       	                                                                                                                                                                             
       let l_sql  = l_sql clipped, l_join clipped                             
   end if    
                                                                
   prepare pctc69m31001  from l_sql              
   declare cctc69m31001  cursor for pctc69m31001
  	
  
   let m_prepare = true    
  

end function 

#------------------------------------------------------#                      
 function ctc69m31()                                                          
#------------------------------------------------------#                      
                                                                              
                                                                                                                                                                                                                          
                                                                              
   open window ctc69m31 at 6,2 with form "ctc69m31"
   attribute(form line 1)                           
                                                                                      
   call ctc69m31_input()                                               
                                                                                                                                                            
   close window ctc69m31                                                      
                                                                              
   let int_flag = false                                                       
                                                                              
 end function                                                                 
                                                                              
#------------------------------------------------------#                                                
function ctc69m31_input()                                                                              
#------------------------------------------------------#                                               
                                                                                                       
   initialize mr_tela.*, mr_retorno.*, mr_label.* to null                                                   
                                                                                                       
   let mr_tela.obs = "                  (F17)Abandona, (F8)Seleciona"             
                                                                                                                                                                                                             
   let int_flag = false

   input by name   mr_tela.empcod
                 , mr_tela.clscod
                 , mr_tela.prfcod
                 , mr_tela.paccod without defaults
    
   
      
   #---------------------------------------------
    before field empcod
   #---------------------------------------------
   				 call ctc69m31_carrega_label()   
   				 
           display by name mr_tela.empcod  attribute (reverse)
           
   #---------------------------------------------
    after  field empcod
   #--------------------------------------------- 	
           display by name mr_tela.empcod


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field empcod
           end if

           if mr_tela.empcod   is not null   then
           	
           	 #--------------------------------------------------------
           	 # Recupera a Descricao da Empresa
           	 #--------------------------------------------------------

           	 call ctc69m04_recupera_descricao(2,mr_tela.empcod)
           	 returning mr_tela.empnom
           	
           	 if mr_tela.empnom is null then           	

                  #--------------------------------------------------------
                  # Abre a Popup da Empresa
                  #--------------------------------------------------------
                  
                  call ctc69m04_popup(2)
                  returning mr_tela.empcod
                          , mr_tela.empnom   
              
             end if  

           end if
           
           
           call ctc69m31_carrega_label() 
           
           display by name mr_tela.empcod
           display by name mr_tela.empnom
           
    
   #--------------------------------------------- 
    before field clscod
   #---------------------------------------------
       display by name mr_tela.clscod   attribute (reverse)

   #--------------------------------------------- 
    after  field clscod
   #--------------------------------------------- 	
       display by name mr_tela.clscod


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field empcod
       end if

       if mr_tela.clscod   is not null   then
       	
       	  #--------------------------------------------------------
       	  # Recupera a Descricao da Clausula
       	  #--------------------------------------------------------

       	  if mr_tela.empcod = 1 then  
       	  
       	     call ctc69m04_recupera_descricao(17,mr_tela.clscod)
             returning mr_tela.clsnom
          
          end if
          
          if mr_tela.empcod = 35 then                                                     
                                                                                             
             call ctc69m04_recupera_descricao(16,mr_tela.clscod)   
             returning mr_tela.clsnom                                                    
                                                                                             
          end if
          
          if mr_tela.empcod = 84 then                              
                                                                   
             call ctc69m04_recupera_descricao(21,mr_tela.clscod)   
             returning mr_tela.clsnom                              
                                                                   
          end if                                                   
                                                                                       

        	if mr_tela.clsnom  is null then
        		
               #--------------------------------------------------------
               # Abre o Popup da Clausula
               #--------------------------------------------------------
               
               if mr_tela.empcod = 1 then 
                             
                   call ctc69m04_popup(17)
                   returning mr_tela.clscod
        	         	       ,mr_tela.clsnom
        	     
               end if 
               
               if mr_tela.empcod = 35 then                         
                                                                      
                   call ctc69m04_popup(16)       
                   returning mr_tela.clscod                       
                   	        ,mr_tela.clsnom                       
                                                                      
               end if        
               
               
               if mr_tela.empcod = 84 then                         
                                                                      
                   call ctc69m04_popup(21)       
                   returning mr_tela.clscod                       
                   	        ,mr_tela.clsnom                       
                                                                      
               end if                                
        	  
        	end if

       end if

       display by name mr_tela.clscod
       display by name mr_tela.clsnom 
     
   #---------------------------------------------
    before field prfcod
   #---------------------------------------------
           display by name mr_tela.prfcod attribute (reverse)
    
   #--------------------------------------------- 
    after  field prfcod
   #--------------------------------------------- 	
           display by name mr_tela.prfcod
           
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field clscod
           end if
           
           if mr_tela.prfcod   is not null   then
           	
           	  if mr_tela.empcod is null then 
           	     error "Para Consultar via Pacote e Necessario o Codigo da Empresa!"
           	     next field prfcod
           	  end if
           	  
           	  #--------------------------------------------------------
           	  # Recupera a Descricao do Segmento
           	  #--------------------------------------------------------
           	  call ctc69m04_recupera_descricao(8,mr_tela.prfcod)
           	  returning mr_tela.desper
           	  
           	  if mr_tela.desper is null then
        
                  #--------------------------------------------------------
                  # Abre a Popup do Segmento
                  #--------------------------------------------------------
                  call ctc69m04_popup(8)
                  returning mr_tela.prfcod
                          , mr_tela.desper
              
              end if
           	 
           end if
           
           display by name mr_tela.prfcod
           display by name mr_tela.desper 
           
     
      #---------------------------------------------
       before field paccod
      #---------------------------------------------
				   display by name mr_tela.paccod attribute (reverse)
   

      #---------------------------------------------
       after field paccod
      #---------------------------------------------


        	if mr_tela.paccod is not null then

             if mr_tela.empcod is null then
                error "Por Favor Informe a Empresa!"      
                next field empcod                           
             end if
             
             message "Aguarde Pesquisando....."
             
             if not ctc69m07_pesquisa_xml(mr_tela.empcod,"","") then
 	              error "Erro ao Consultar os Pacotes!!"
 	              next field paccod
             end if 
             
             message ""  
             
             #--------------------------------------------------------
        		 # Recupera a Descricao do Pacote
        		 #--------------------------------------------------------
             
        		 call ctc69m03_recupera_descricao(mr_tela.paccod)
        		 returning mr_tela.pacdes
        		         ,mr_retorno.paclim
        		         ,mr_retorno.pacuni
        		 
        		 if mr_tela.pacdes is null then
        		 	
                #--------------------------------------------------------            		 	  
                # Abre o Popup do Pacote                                             		 	  
                #--------------------------------------------------------            		 	  
                                                                                     		 	  
                call ctc69m03_popup()                                                		 	
                returning mr_tela.paccod                                		 	
                        , mr_tela.pacdes                                		 	
                        , mr_retorno.paclim                                		 	
                        , mr_retorno.pacuni                                		 	
        		 	     		    
        		 end if
             
    
          end if      
           
          display by name mr_tela.paccod    
          display by name mr_tela.pacdes 
          
          if mr_tela.empcod is null and 
          	 mr_tela.clscod is null and
             mr_tela.prfcod is null and
             mr_tela.paccod is null then
              error "Por Favor Informe Pelo Menos uma Chave de Consulta!"
              next field empcod
          else 
          	 call ctc69m31_consulta_array()
          end if
             
                                                        
                                                                                                       
     on key (interrupt)                                                                                
         exit input                                                                                    
                                                                                                       
                                                                                                       
   end input                                                                                           
                                                                                                       
end function


#------------------------------------------------------#                                                                                            
function ctc69m31_consulta_array()                          
#------------------------------------------------------# 

define arr_aux integer
define scr_aux integer 

  for  arr_aux  =  1  to  500                         
    initialize  mr_array[arr_aux].*, mr_rodape[arr_aux].* to  null     
 end  for
	
	call ctc69m31_carrega_dados()
	                                            

  options insert   key F40
  options delete   key F35
  options next     key F30
  options previous key F25
  
  display by name mr_tela.obs	         
  
  call set_count(arr_aux)
  
  input array mr_array without defaults from s_ctc69m31.*

     before field seta                                                   
        
        let arr_aux = arr_curr() 
        let scr_aux = scr_line()     
        
        display mr_array[arr_aux].* to s_ctc69m31[scr_aux].* attribute(reverse)
                                                                                                                      
        display by name mr_rodape[arr_aux].regsitdes                              
        display by name mr_rodape[arr_aux].empnom1
        display by name mr_rodape[arr_aux].clsnom1   
        display by name mr_rodape[arr_aux].desper1                                   
                                                                         
    
                                                                        
    after field seta                                                    
    
		  if  fgl_lastkey() <> fgl_keyval("up")   and                        
         fgl_lastkey() <> fgl_keyval("left") then                       
              if mr_array[arr_aux + 1 ].plnclscod is null then          
                    next field seta                                     
              end if                                                    
     end if

      display mr_array[arr_aux].* to s_ctc69m31[scr_aux].* 
    
     on key (interrupt)        
         exit input 
         	
     on key (f8)    
     	 
     	  if mr_array[arr_aux].plnclscod is not null then
     	  
     	     if mr_array[arr_aux].empcod1 = 1 then
     	     	   let mr_retorno.canal = 1
     	     end if 
     	     
     	     if mr_array[arr_aux].empcod1 = 35 then
     	     	   let mr_retorno.canal = 2
     	     end if
     	     
     	     if mr_array[arr_aux].empcod1 = 84 then
     	     	   
     	     	   if mr_array[arr_aux].ramcod = 31 then
     	     	       let mr_retorno.canal = 3
     	     	   end if
     	     	   
     	     	   if mr_array[arr_aux].ramcod = 531 then
     	     	       let mr_retorno.canal = 4
     	     	   end if
     	     	   
     	     	   if mr_array[arr_aux].ramcod = 14 then
     	     	       let mr_retorno.canal = 5
     	     	   end if
     	     	       	     	   
     	     end if 
     	     
     	     
     	     
     	     
     	     call ctc69m07(mr_array[arr_aux].plnclscod     ,        	 
                         mr_array[arr_aux].clscod1       ,     
                         mr_rodape[arr_aux].clsnom1      ,     
     		                 mr_array[arr_aux].empcod1       ,     
                         mr_array[arr_aux].ramcod        ,
                         mr_retorno.canal                )   
        
        end if    	
         	                                                                   

  end input

end function

#------------------------------------------------------#   
function ctc69m31_carrega_dados()                            
#------------------------------------------------------#   

define lr_retorno record                      
   plnclscod    like datkplncls.plnclscod      ,         
   empcod       like datkplncls.empcod         ,         
   ramcod       like datkplncls.ramcod         ,         
   clscod       like datkplncls.clscod         ,         
   prfcod       like datkplncls.prfcod         ,         
   clssitflg    like datkplncls.clssitflg      ,         
   irdclsflg    like datkplncls.irdclsflg      ,         
   clsviginidat like datkplncls.clsviginidat   ,         
   clsvigfimdat like datkplncls.clsvigfimdat   ,
   regsitflg    like datkplncls.regsitflg      
end record                                               
                                                             
define arr_aux integer  

    let arr_aux = 0

    initialize lr_retorno.* to null

    call ctc69m31_prepare()
   
    open cctc69m31001                                     
                                                                                     
    foreach cctc69m31001 into lr_retorno.plnclscod    ,     
    	                        lr_retorno.empcod       ,     
    	                        lr_retorno.ramcod       ,     
    	                        lr_retorno.clscod       ,     
    	                        lr_retorno.prfcod       ,     
    	                        lr_retorno.clssitflg    ,     
    	                        lr_retorno.irdclsflg    ,     
    	                        lr_retorno.clsviginidat ,     
    	                        lr_retorno.clsvigfimdat ,     
    	                        lr_retorno.regsitflg                                                                                
                                                                                     
      let arr_aux = arr_aux + 1                                                      
                                                                                     
      let mr_array[arr_aux].plnclscod    = lr_retorno.plnclscod                        
      let mr_array[arr_aux].empcod1      = lr_retorno.empcod     
      let mr_array[arr_aux].ramcod       = lr_retorno.ramcod                       
      let mr_array[arr_aux].clscod1      = lr_retorno.clscod     
      let mr_array[arr_aux].prfcod1      = lr_retorno.prfcod                                                                                 
      let mr_array[arr_aux].clsviginidat = lr_retorno.clsviginidat  
      let mr_array[arr_aux].clsvigfimdat = lr_retorno.clsvigfimdat 
      
      if lr_retorno.clssitflg = "S" then       
          let mr_array[arr_aux].clssitdes = "SIM"
      else
      	  let mr_array[arr_aux].clssitdes = "NAO"
      end if
      
      if lr_retorno.irdclsflg = "S" then            
          let mr_array[arr_aux].irdclsdes = "SIM"   
      else                                          
      	  let mr_array[arr_aux].irdclsdes = "NAO"   
      end if 
      
      if lr_retorno.regsitflg = "A" then           
          let mr_rodape[arr_aux].regsitdes = "ATIVO"   
      else                                          
      	  let mr_rodape[arr_aux].regsitdes = "INATIVO"   
      end if     
      
      
      #--------------------------------------------------------   
      # Recupera a Descricao da Empresa                           
      #--------------------------------------------------------   
                                                                  
      call ctc69m04_recupera_descricao(2,lr_retorno.empcod)          
      returning mr_rodape[arr_aux].empnom1 
      
          
      #--------------------------------------------------------          
      # Recupera a Descricao da Clausula                                 
      #--------------------------------------------------------          
                                                                         
      if lr_retorno.empcod = 1 then                                         
                                                                         
         call ctc69m04_recupera_descricao(17,lr_retorno.clscod)             
         returning mr_rodape[arr_aux].clsnom1                                         
                                                                         
      end if                                                             
                                                                         
      if lr_retorno.empcod = 35 then                                        
                                                                         
         call ctc69m04_recupera_descricao(16,lr_retorno.clscod)             
         returning mr_rodape[arr_aux].clsnom1                                         
                                                                         
      end if
      
      
      if lr_retorno.empcod = 1 then
      
          #-------------------------------------------------------- 
          # Recupera a Descricao do Segmento                        
          #-------------------------------------------------------- 
          call ctc69m04_recupera_descricao(8,lr_retorno.prfcod)        
          returning mr_rodape[arr_aux].desper1                                  
      
      end if                                                                           
                                                                                
    end foreach                                                                  


end function

#------------------------------------------------------#
function ctc69m31_carrega_label()
#------------------------------------------------------#
  
  
  if mr_tela.empcod = 84 then
     
      let mr_label.label1 = "Plano...:"
      let mr_label.label2 = "Plan."
  	  let mr_label.label3 = "Plano...:"
  
  else
  	  
  	  let mr_label.label1 = "Clausula:"  
  		let mr_label.label2 = "Clau."      
      let mr_label.label3 = "Clausula:"  
  
  end if 
  
  display by name  mr_label.label1
  display by name  mr_label.label2
  display by name  mr_label.label3
  

end function