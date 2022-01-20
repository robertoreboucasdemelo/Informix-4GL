#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HORAS                                           #
# Modulo        : cta13m00                                                   #
# Analista Resp.: Roberto Melo                                               #
# PSI           : 223689                                                     #
#                 Verificar status da instancias dos servidores              #
#............................................................................#
# Desenvolvimento: Amilton, META                                             #
# Liberacao      : 18/12/2008                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
# 01/07/2015 Alberto   Tarifa 04/2015                                        #
#----------------------------------------------------------------------------#
# 30/09/2015 Alberto-Fornax ST-2015-00089 Tarifa 09/2015                     #
#----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc012.4gl"

define m_prep_sql smallint
define m_hostname char(12)
      
          
define arr_aux   smallint

#--------------------------------------------------------#  
 function cta13m00_prepare()
#--------------------------------------------------------#  

  define l_sql char(1000)

  let l_sql = null


  let l_sql = "select count(clscod) from abbmclaus",
                  " where succod = ?",
                  " and aplnumdig  = ?",
                  " and itmnumdig  = ?",
                  " and dctnumseq  = ?",
                  " and clscod in ('034','035','35R','033','33R',",
                  "'046','047','46R','47R','044','44R','048','48R')"
  prepare pcta13m00002 from l_sql
  declare ccta13m00002 cursor for pcta13m00002

  let l_sql = "select count(clscod) from abbmclaus",
               " where succod = ?",
               " and aplnumdig  = ?",
               " and itmnumdig  = ?",
               " and dctnumseq  = ?",
               " and clscod in ('071','075','75R','076','76R','077')"  # PSI 239.399 Clausula 077
  prepare pcta13m00003 from l_sql
  declare ccta13m00003 cursor for pcta13m00003
  	
  let l_sql = "select count(clscod) from abbmclaus",
                  " where succod = ?",
                  " and aplnumdig  = ?",
                  " and itmnumdig  = ?",
                  " and dctnumseq  = ?",
                  " and clscod in ('044')"
  prepare pcta13m00004 from l_sql
  declare ccta13m00004 cursor for pcta13m00004
  	
  let l_sql = ' select vtgcod              '                                 
          ,  '  from abbmvtg               '                                
          ,  '  where succod    = ?        '                                 
          ,  '  and   aplnumdig = ?        '  
          ,  '  and   itmnumdig = ?        '   
          ,  '  and   dctnumseq = ?        '                                 
  prepare pcta13m00005 from l_sql                                         
  declare ccta13m00005 cursor for pcta13m00005
  	
  let l_sql = ' select count(*)         '     	
          ,  '  from datkdominio        '     	
          ,  '  where cponom = ?        '     	
          ,  '  and   cpodes = ?        '     	
  prepare pcta13m00006 from l_sql              
  declare ccta13m00006 cursor for pcta13m00006 	
  	
  let l_sql = "select count(clscod) from abbmclaus",
                  " where succod = ?",
                  " and aplnumdig  = ?",
                  " and itmnumdig  = ?",
                  " and dctnumseq  = ?",
                  " and clscod in ('33R')"
  prepare pcta13m00007 from l_sql
  declare ccta13m00007 cursor for pcta13m00007
  	
  let l_sql = "select count(clscod) from abbmclaus",
                  " where succod = ?",
                  " and aplnumdig  = ?",
                  " and itmnumdig  = ?",
                  " and dctnumseq  = ?",
                  " and clscod in ('46R')"
  prepare pcta13m00008 from l_sql
  declare ccta13m00008 cursor for pcta13m00008	
  	
 
  let m_prep_sql = true

end function

#--------------------------------------------------------#  
 function cta13m00_verifica_status(l_hostname)
#--------------------------------------------------------#  

define l_hostname  char(12)
define l_result smallint
define l_msg    char(100)
define l_sql    char(300)

 let m_hostname = l_hostname
 let l_result = 0
 let l_msg = null

 if  not figrc012_sitename("cta13m00","","") then
          display "ERRO NO SITENAME !"
    end if


 if l_hostname is not null then

      whenever error continue
      let l_sql = "select 1 from ",m_hostname, "Dual "

      prepare pcta13m00001 from l_sql
      declare ccta13m00001 cursor for pcta13m00001
      whenever error stop


      if sqlca.sqlcode <> 0 then
         let l_result = 0
         let l_msg = "Problemas de Conexao com o banco ",m_hostname , "!"
         return l_result,l_msg
      end if

      whenever error continue
      open ccta13m00001
      fetch ccta13m00001 into l_result
      whenever error stop


      if sqlca.sqlcode <> 0 then
         let l_result = 0
         let l_msg = "Problemas de Conexao com o banco ",l_hostname , "!"
         return l_result,l_msg
      else
         let l_result = 1
         return l_result,l_msg
      end if

 end if

 if not g_outFigrc012.Is_Teste then
    call cta13m00_verifica_instancias()
    returning l_result,l_msg
 else
   let l_result = 1
   return l_result,l_msg
 end if

return l_result,l_msg

end function

#--------------------------------------------------------#  
 function cta13m00_verifica_instancias()
#--------------------------------------------------------#  


  define l_retorno smallint
  define l_msg     char(100)

   let l_retorno = 0
   let l_msg = null

   whenever error continue
   select 1 into l_retorno from porto@u18:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u18 !"
      return l_retorno,l_msg
   end if
   whenever error continue
   select 1 into l_retorno from porto@u41:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u41 !"
      return l_retorno,l_msg
   end if
   whenever error continue
   select 1 into l_retorno from porto@u37:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u37 !"
      return l_retorno,l_msg
   end if
   whenever error continue
   select 1 into l_retorno from porto@u32:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u32 !"
      return l_retorno,l_msg
   end if
   whenever error continue
   select 1 into l_retorno from porto@u15:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u15 !"
      return l_retorno,l_msg
   end if


   whenever error continue
   select 1 into l_retorno from porto@u01:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u01 !"
      return l_retorno,l_msg
   end if

 return l_retorno,l_msg


end function

#--------------------------------------------------------#  
 function cta13m00_verifica_clausula(lr_param)
#--------------------------------------------------------#  


    define lr_param record
        succod       like abbmclaus.succod,
        aplnumdig    like abbmclaus.aplnumdig,
        itmnumdig    like abbmclaus.itmnumdig,
        dctnumseq    like abbmclaus.dctnumseq,
        clscod       like abbmclaus.clscod
    end record

    define l_count   integer

    let l_count = 0

    if m_prep_sql = false or
         m_prep_sql is null then
         call cta13m00_prepare()
    end if

     if lr_param.clscod = "034" then

        open ccta13m00002 using  lr_param.succod,
                                 lr_param.aplnumdig,
                                 lr_param.itmnumdig,
                                 lr_param.dctnumseq
        fetch ccta13m00002 into l_count

        if l_count > 1 then
           return true
        else
           return false
        end if
     end if

     if lr_param.clscod = "071" or
        lr_param.clscod = "077" then # PSI 239.399 Clausula 077

        open ccta13m00003 using  lr_param.succod,
                                 lr_param.aplnumdig,
                                 lr_param.itmnumdig,
                                 lr_param.dctnumseq
        fetch ccta13m00003 into l_count

        if l_count > 1 then
           return true
        else
           return false
        end if
     end if

return false


end function

#--------------------------------------------------------#  
 function cta13m00_verifica_instancias_u37()
#--------------------------------------------------------#  

  define l_retorno smallint
  define l_msg     char(100)

   let l_retorno = 0
   let l_msg = null


   whenever error continue
   select 1 into l_retorno from porto@u37:dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_retorno = 0
      let l_msg = " Problemas de conexao no banco u37 !"
      return l_retorno,l_msg
   end if


 return l_retorno,l_msg


end function

#--------------------------------------------------------#  
 function cta13m00_verifica_clausula_044(lr_param)
#--------------------------------------------------------#  

define lr_param record
    succod       like abbmclaus.succod,
    aplnumdig    like abbmclaus.aplnumdig,
    itmnumdig    like abbmclaus.itmnumdig,
    dctnumseq    like abbmclaus.dctnumseq,
    clscod       like abbmclaus.clscod
end record

    define l_count   integer
    
    let l_count = 0
    
    if m_prep_sql = false or
         m_prep_sql is null then
         call cta13m00_prepare()
    end if
    
     if lr_param.clscod = "034" then
       
        open ccta13m00004 using  lr_param.succod,
                                 lr_param.aplnumdig,
                                 lr_param.itmnumdig,
                                 lr_param.dctnumseq
        fetch ccta13m00004 into l_count
        
        if l_count > 0 then
           return true
        else
           return false
        end if
     
     end if
     
     return false
     
end function





#----------------------------------------------# 
 function cta13m00_beneficio(lr_param)    
#----------------------------------------------# 

define lr_param record
  succod     like abbmvtg.succod     ,     	
	aplnumdig  like abbmvtg.aplnumdig  ,
  itmnumdig  like abbmvtg.itmnumdig  ,
  dctnumseq  like abbmvtg.dctnumseq  ,
  canal      integer  
end record

define lr_retorno record       
	 vtgcod   like abbmvtg.vtgcod,
	 confirma char(01)           ,
   alerta1  char(75)           ,     	 
   alerta2  char(75)      	       
end record 

     initialize lr_retorno.* to null

     open ccta13m00005  using lr_param.succod    ,    
                              lr_param.aplnumdig ,
                              lr_param.itmnumdig ,
                              lr_param.dctnumseq
                                  
     foreach ccta13m00005 into lr_retorno.vtgcod     
       
         #----------------------------------------------------------------
         # Verifica se a Vantagem e Veiculo com ate 2 Anos de Fabricacao      
         #----------------------------------------------------------------
         if cta13m00_valida_beneficio(1, lr_retorno.vtgcod) then   
         		
         	    case lr_param.canal
         	    	when 1
         	    	
         	    		if cta13m00_valida_beneficio_clausula(lr_param.succod    ,    
         	    		                                      lr_param.aplnumdig ,
         	    		                                      lr_param.itmnumdig ,
         	    		                                      lr_param.dctnumseq ) then 
         	    		
         	    		   call cts08g01("A", "N",                                               
         	    		                 "DESCONTO NA FRANQUIA EM OFICINA OU ",          
         	    		                 "CONCESSIONARIA REFERENCIADA ",     
         	    		                 "CONSULTE ",   
         	    		                 "F1-FUNCOES - VANTAGENS ")                      
         	    		   returning lr_retorno.confirma                                 
         	    		
         	    		
         	    		
         	    		
         	    		else
         	    		         	    		        	    
         	            call cts08g01("A", "N",
         	                          "VEICULO COM ATE 2 ANOS DE FABRICACAO ",                              
         	                          "DESCONTO NA FRANQUIA EM OFICINA OU ",         
         	                          "CONCESSIONARIA REFERENCIADA CONSULTE",
         	                          "F1-FUNCOES - VANTAGENS ")              
         	            returning lr_retorno.confirma  
         	        
         	        end if 
         	      when 2   
         	      	
         	      	 if cta13m00_valida_beneficio_clausula(lr_param.succod    ,       
         	      	                                       lr_param.aplnumdig ,       
         	      	                                       lr_param.itmnumdig ,       
         	      	                                       lr_param.dctnumseq ) then  
         	      	
         	      	     
         	      	    let lr_retorno.alerta1 = "DESCONTO NA FRANQUIA EM OFICINA OU CONCESSIONARIA REFERENCIADA" 
         	      	    let lr_retorno.alerta2 = "CONSULTE F1-FUNCOES - VANTAGENS"             
         	      	        	      	 
         	      	 else
         	      	      	      	
         	            let lr_retorno.alerta1 = "VEICULO COM ATE 2 ANOS DE FABRICACAO DESCONTO NA FRANQUIA EM OFICINA OU"                                     
         	            let lr_retorno.alerta2 = "CONCESSIONARIA REFERENCIADA CONSULTE F1-FUNCOES - VANTAGENS" 
         	         
         	         end if
         	
         	    end case
         	    
         	    exit foreach
         	                              
         end if
         
         #--------------------------------------------------------------------     
         # Verifica se a Vantagem e Veiculo com mais de 2 Anos de Fabricacao       
         #--------------------------------------------------------------------    
         if cta13m00_valida_beneficio(2, lr_retorno.vtgcod) then           
         	                                                                 
         	    case lr_param.canal
         	    	when 1        	          	    
         	        
         	        if cta13m00_valida_beneficio_clausula(lr_param.succod    ,               
         	                                              lr_param.aplnumdig ,               
         	                                              lr_param.itmnumdig ,               
         	                                              lr_param.dctnumseq ) then          
         	                                                                                 
         	           call cts08g01("A", "N",                                               
         	                         "DESCONTO NA FRANQUIA EM OFICINA OU ",                  
         	                         "CONCESSIONARIA REFERENCIADA ",                         
         	                         "CONSULTE ",                                            
         	                         "F1-FUNCOES - VANTAGENS ")                              
         	           returning lr_retorno.confirma                                         
         	                                                                                         	                                                                                 
         	        else   
         	        	                                                                  
         	            call cts08g01("A", "N",                                      
         	                          "VEICULO COM MAIS DE 2 ANOS DE FABRICACAO",       
         	                          "DESCONTO NA FRANQUIA SOMENTE EM ",         
         	                          "OFICINA REFERENCIADA CONSULTE",        
         	                          "F1-FUNCOES - VANTAGENS ")                     
         	            returning lr_retorno.confirma 
         	        end if
         	        
         	      when 2
         	        
         	        if cta13m00_valida_beneficio_clausula(lr_param.succod    ,                                    
         	                                              lr_param.aplnumdig ,                                    
         	                                              lr_param.itmnumdig ,                                    
         	                                              lr_param.dctnumseq ) then                               
         	                                                                                                      
         	                                                                                                      
         	           let lr_retorno.alerta1 = "DESCONTO NA FRANQUIA EM OFICINA OU CONCESSIONARIA REFERENCIADA"  
         	           let lr_retorno.alerta2 = "CONSULTE F1-FUNCOES - VANTAGENS"                                 
         	               	      	                                                                              
         	        else                                                                                          
         	        
         	           let lr_retorno.alerta1 = "VEICULO COM MAIS DE 2 ANOS DE FABRICACAO DESCONTO NA FRANQUIA SOMENTE EM" 
         	           let lr_retorno.alerta2 = "OFICINA REFERENCIADA CONSULTE F1-FUNCOES - VANTAGENS"                                            
         	       
         	        end if
         	    end case
         	                                                                 
         	    exit foreach                                                 
         	                                                                 
         end if                                                            
         

     end foreach
     
     return lr_retorno.alerta1,     
            lr_retorno.alerta2      
    

end function 


#--------------------------------------------------------#                                          
 function cta13m00_valida_beneficio(lr_param)              
#--------------------------------------------------------#             
                                                                                               
define lr_param record               
  tipo   smallint           ,   
  vtgcod like abbmvtg.vtgcod              
end record                             
                                                                       
define lr_retorno record                                                                                  
  chave     char(20),
  cont      integer                                                   
end record

                      
                                                                                                                                             
initialize lr_retorno.* to null 
                                       
    if lr_param.tipo = 1 then                                                                       
        let lr_retorno.chave = "cta13m00_vtgcod1"   
    end if  
    
    if lr_param.tipo = 2 then                       
        let lr_retorno.chave = "cta13m00_vtgcod2"   
    end if                                            
                                                                                                                                            
    #--------------------------------------------------------          
    # Valida Codigo de Vantagens                                       
    #--------------------------------------------------------          
                                                                                                                                               
    open ccta13m00006 using lr_retorno.chave,
                            lr_param.vtgcod                      
    whenever error continue                               
    fetch ccta13m00006 into  lr_retorno.cont            
    whenever error stop                                   
                                                          
    if lr_retorno.cont > 0 then                           
       return true                                        
    else                                                  
    	  return false                                      
    end if                                                
                                                                  
                                                                                                                          
end function


#----------------------------------------------#                                
 function cta13m00_valida_fabricacao(lr_param)                                    
#----------------------------------------------# 

define lr_param record
  succod     like abbmvtg.succod     ,     	
	aplnumdig  like abbmvtg.aplnumdig  ,
  itmnumdig  like abbmvtg.itmnumdig  ,
  dctnumseq  like abbmvtg.dctnumseq  ,
  canal      integer
end record

define lr_retorno record            
	 alerta1  char(75),
	 alerta2  char(75)   
end record  
                        
    
    initialize lr_retorno.* to null
    
    if m_prep_sql = false or       
       m_prep_sql is null then   
         call cta13m00_prepare()   
    end if                         
   
    if g_nova.dt_cal >= "01/04/2015" then
         
       call cta13m00_beneficio(lr_param.succod          
                              ,lr_param.aplnumdig     
                              ,lr_param.itmnumdig     
                              ,lr_param.dctnumseq
                              ,lr_param.canal)                    
       returning  lr_retorno.alerta1,                                                                      
                  lr_retorno.alerta2  
    
    
    end if
    
    return lr_retorno.alerta1, 
           lr_retorno.alerta2
    
                                                                         
end function 

#--------------------------------------------------------#                                                                              
 function cta13m00_valida_beneficio_clausula(lr_param)                                
#--------------------------------------------------------#                  
 
define lr_param record
    succod       like abbmclaus.succod,
    aplnumdig    like abbmclaus.aplnumdig,
    itmnumdig    like abbmclaus.itmnumdig,
    dctnumseq    like abbmclaus.dctnumseq
end record 
                                                                                                      
                                                                            
define lr_retorno record                                                    
  chave     char(20),                                                       
  cont      integer                                                         
end record                                                                  
                                                                            
                                                                            
                                                                            
initialize lr_retorno.* to null 

    
     if g_nova.dt_cal >= "01/10/2015" then 
        if cta13m00_verifica_clausula_33R(lr_param.*) or
        	 cta13m00_verifica_clausula_46R(lr_param.*) then
              return true
        end if
     end if                                    
                                                                         
     return false       
                                                                            
                                                                            
end function 


#--------------------------------------------------------#  
 function cta13m00_verifica_clausula_33R(lr_param)
#--------------------------------------------------------#  

define lr_param record
    succod       like abbmclaus.succod,
    aplnumdig    like abbmclaus.aplnumdig,
    itmnumdig    like abbmclaus.itmnumdig,
    dctnumseq    like abbmclaus.dctnumseq
end record

    define l_count   integer
    
    let l_count = 0
    
    if m_prep_sql = false or
         m_prep_sql is null then
         call cta13m00_prepare()
    end if
    
          
    open ccta13m00007 using  lr_param.succod,
                             lr_param.aplnumdig,
                             lr_param.itmnumdig,
                             lr_param.dctnumseq
    fetch ccta13m00007 into l_count
    
    if l_count > 0 then
       return true
    else
       return false
    end if
 
     
end function

#--------------------------------------------------------#  
 function cta13m00_verifica_clausula_46R(lr_param)
#--------------------------------------------------------#  

define lr_param record
    succod       like abbmclaus.succod,
    aplnumdig    like abbmclaus.aplnumdig,
    itmnumdig    like abbmclaus.itmnumdig,
    dctnumseq    like abbmclaus.dctnumseq
end record


    define l_count   integer
    
    let l_count = 0
    
    if m_prep_sql = false or
         m_prep_sql is null then
         call cta13m00_prepare()
    end if
    
          
    open ccta13m00008 using  lr_param.succod,
                             lr_param.aplnumdig,
                             lr_param.itmnumdig,
                             lr_param.dctnumseq
    fetch ccta13m00008 into l_count
    
    if l_count > 0 then
       return true
    else
       return false
    end if
 
     
end function
                                                                           