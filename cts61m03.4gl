#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts61m03                                                   #
#Analista Resp : Humberto Benedito                                          #
#                Quantidade de Servicos Empresarial Itau                    #
#...........................................................................#
#Desenvolvimento: R.Fornax                                                  #
#Liberacao      : 17/04/2015  PJ                                            #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_cts61m03_prep smallint

#--------------------------#
function cts61m03_prepare()
#--------------------------#
 
 define l_sql char(600)

 let l_sql = "select a.atdsrvnum ,    "
            ,"       a.atdsrvano      "
            ,"from datmservico a,     "
            ,"     datmligacao b,     "
            ,"     datrligitaaplitm d "
            ,"where a.atdsrvnum  = b.atdsrvnum "
            ,"and a.atdsrvano    = b.atdsrvano "
            ,"and b.lignum       = d.lignum    "
            ,"and d.itaciacod    = ?           "
            ,"and d.itaramcod    = ?           "
            ,"and d.itaaplnum    = ?           "
            ,"and b.c24astcod    = ?           "
 prepare p_cts61m03_001 from l_sql
 declare c_cts61m03_001 cursor for p_cts61m03_001
 	
 
 let l_sql = "select a.atdsrvnum ,"
            ,"       a.atdsrvano "
            ,"from datmservico a, "
            ,"     datmligacao b, "
            ,"     datrligitaaplitm d "
            ,"where a.atdsrvnum = b.atdsrvnum "
            ,"and a.atdsrvano = b.atdsrvano "
            ,"and b.lignum    = d.lignum "
            ,"and d.itaciacod = ? "
            ,"and d.itaramcod = ? "
            ,"and d.itaaplnum = ? "
            ,"and b.c24astcod not in ('CON','ALT','CAN','RET','IND','REC')"
 prepare p_cts61m03_002 from l_sql
 declare c_cts61m03_002 cursor for p_cts61m03_002	
 	
 	
 let l_sql = " select count(*)     "                    
            ," from datkpbmgrp a,  "
            ,"      datkpbm    b,  "
            ,"      datrsrvpbm c   "                  
            ," where a.c24pbmgrpcod = b.c24pbmgrpcod "
            ," and   b.c24pbmcod    = c.c24pbmcod    "
            ," and   c.atdsrvnum    = ?   "               
            ," and   c.atdsrvano    = ?   "                
            ," and   a.c24pbmgrpcod = ?   "                	                                                    	
 prepare p_cts61m03_003 from l_sql                  	
 declare c_cts61m03_003 cursor for p_cts61m03_003  	
 	
 let l_sql = " select count(*)     "                    
            ," from datmservico    "                
            ," where atdsrvnum  = ?   "               
            ," and   atdsrvano  = ?   "                
            ," and   asitipcod  = ?   "                	                                                    	
 prepare p_cts61m03_004 from l_sql                  	
 declare c_cts61m03_004 cursor for p_cts61m03_004  		
 	
 	
 let l_sql = " select count(*)        "                  	
            ," from datmassistpassag  "                  	
            ," where atdsrvnum  = ?   "               	
            ," and   atdsrvano  = ?   "               	
            ," and   asimtvcod  = ?   "               	
 prepare p_cts61m03_005 from l_sql                  		
 declare c_cts61m03_005 cursor for p_cts61m03_005  			

 let m_cts61m03_prep = true

end function


#-----------------------------------------------#
function cts61m03_qtd_servico_assunto(lr_entrada)
#-----------------------------------------------#
 
 define lr_entrada record
    itaciacod    like datmitaapl.itaciacod
   ,itaramcod    like datmitaapl.itaramcod
   ,itaaplnum    like datmitaapl.itaaplnum
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum
   ,itaasiplncod like datkitaasipln.itaasiplncod 
   ,c24astcod    like datkassunto.c24astcod     
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_cts61m03_prep is null or
    m_cts61m03_prep <> true then
    call cts61m03_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null

    
    #--------------------------------------------------------------- 
    # Obtem os Servicos dos Atendimentos Realizados Pela Apolice     
    #--------------------------------------------------------------- 
       
    if lr_entrada.itaaplnum is not null then

                    
           open c_cts61m03_001 using lr_entrada.itaciacod
                                    ,lr_entrada.itaramcod
                                    ,lr_entrada.itaaplnum
                                    ,lr_entrada.c24astcod
                     
           foreach c_cts61m03_001 into lr_servico.atdsrvnum,
           	                           lr_servico.atdsrvano
                    
                 
                 #---------------------------------------------
                 # Consiste Servicos      
                 #---------------------------------------------
                 
                 call cts61m03_consiste_servico_assunto(lr_servico.atdsrvnum,
                                                        lr_servico.atdsrvano,
                                                        lr_entrada.c24astcod)
                 returning l_resultado
           
           
                 if l_resultado = 1 then
                    let l_qtd  = l_qtd + 1
                 else
                    if l_resultado = 3 then
                       error l_mensagem sleep 2
                       exit foreach
                    end if
                 end if
           
           end foreach
           
           close c_cts61m03_001
     	     
    end if

 return l_qtd

end function


#-----------------------------------------------------#
function cts61m03_consiste_servico_assunto(lr_entrada)
#-----------------------------------------------------#

define lr_entrada record
   atdsrvnum like datmservico.atdsrvnum
  ,atdsrvano like datmservico.atdsrvano
  ,c24astcod like datkassunto.c24astcod   
end record

define l_resultado smallint
      ,l_mensagem  char(60)
      ,l_atdetpcod like datmsrvacp.atdetpcod
      ,l_qtde    integer

initialize l_resultado to  null
initialize l_mensagem  to  null
initialize l_atdetpcod to  null

 if not m_cts61m03_prep then
    call cts61m03_prepare()
 end if

 #-------------------------------------------------------- 
 # Obtem a Ultima Etapa do Servico                         
 #-------------------------------------------------------- 
 
 let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                        ,lr_entrada.atdsrvano)

 #-------------------------------------
 # Help Desk Itau    
 #-------------------------------------
 if lr_entrada.c24astcod = "R66" then 
 	  
 	  if l_atdetpcod = 1   or 
 	  	 l_atdetpcod = 2   or 
       l_atdetpcod = 3   or
       l_atdetpcod = 4   then
         let l_resultado = 1
    else
         let l_resultado = 0
    end if
 
 else   
 
    #--------------------------------------------------------
    # Considera Somente Servicos Liberados(1) e Acionados(3)                         
    #--------------------------------------------------------
    
    if l_atdetpcod = 1   or
       l_atdetpcod = 3   then
         let l_resultado = 1
    else
         let l_resultado = 0
    end if    
 
  end if

 return l_resultado

end function

#---------------------------------------------------#
function cts61m03_qtd_servico_problema(lr_entrada)
#---------------------------------------------------#
 
 define lr_entrada record
    itaciacod    like datmitaapl.itaciacod
   ,itaramcod    like datmitaapl.itaramcod
   ,itaaplnum    like datmitaapl.itaaplnum
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum
   ,itaasiplncod like datkitaasipln.itaasiplncod 
   ,c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod    
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_cts61m03_prep is null or
    m_cts61m03_prep <> true then
    call cts61m03_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null
     
         
    #---------------------------------------------------------------
    # Obtem os Servicos dos Atendimentos Realizados Pela Apolice 
    #---------------------------------------------------------------
     
    if lr_entrada.itaaplnum is not null then

                    
           open c_cts61m03_002 using lr_entrada.itaciacod
                                    ,lr_entrada.itaramcod
                                    ,lr_entrada.itaaplnum
                                   
                     
           foreach c_cts61m03_002 into lr_servico.atdsrvnum,
           	                           lr_servico.atdsrvano
                    
                 
                 #---------------------------------------------    
                 # Consiste Servicos                               
                 #---------------------------------------------    
                 
                 call cts61m03_consiste_servico_problema(lr_servico.atdsrvnum,
                                                         lr_servico.atdsrvano,
                                                         lr_entrada.c24pbmgrpcod)
                 returning l_resultado
           
           
                 if l_resultado = 1 then
                    let l_qtd  = l_qtd + 1
                 else
                    if l_resultado = 3 then
                       error l_mensagem sleep 2
                       exit foreach
                    end if
                 end if
           
           end foreach
           
           close c_cts61m03_002
     	     
    end if

 return l_qtd

end function


#-----------------------------------------------------#
function cts61m03_consiste_servico_problema(lr_entrada)
#-----------------------------------------------------#

define lr_entrada record
   atdsrvnum    like datmservico.atdsrvnum
  ,atdsrvano    like datmservico.atdsrvano
  ,c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod  
end record

define l_resultado smallint
      ,l_mensagem  char(60)
      ,l_atdetpcod like datmsrvacp.atdetpcod
      ,l_qtde    integer

initialize l_resultado to  null
initialize l_mensagem  to  null
initialize l_atdetpcod to  null

 if not m_cts61m03_prep then
    call cts61m03_prepare()
 end if

 #-------------------------------------------------------- 
 # Obtem a Ultima Etapa do Servico           
 #-------------------------------------------------------- 
 
 let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                        ,lr_entrada.atdsrvano)

 #--------------------------------------------------------
 # Considera Somente Servicos Liberados(1) e Acionados(3) 
 #-------------------------------------------------------- 
 
 if l_atdetpcod = 1   or
    l_atdetpcod = 3   then
      let l_resultado = 1
 else
      let l_resultado = 0
 end if
 
 
 if l_resultado = 1 then                                      
   
    
    #--------------------------------------------------------
    # Verifica Se Atendimento Tem Problema Relacionado 
    #--------------------------------------------------------
    
    whenever error continue                                   
    open c_cts61m03_003 using lr_entrada.atdsrvnum,           
                              lr_entrada.atdsrvano,           
                              lr_entrada.c24pbmgrpcod           
    fetch c_cts61m03_003 into l_qtde                          
    whenever error stop                                       
                                                                             
    if l_qtde = 0 then                                        
       let l_resultado = 0                                    
    else                                                      
       let l_resultado = 1                                    
    end if                                                    
    
    close c_cts61m03_003                                      
 end if                                                       
 
 return l_resultado

end function

#---------------------------------------------------#
function cts61m03_qtd_servico_assistencia(lr_entrada)
#---------------------------------------------------#
 
 define lr_entrada record
    itaciacod    like datmitaapl.itaciacod
   ,itaramcod    like datmitaapl.itaramcod
   ,itaaplnum    like datmitaapl.itaaplnum
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum
   ,itaasiplncod like datkitaasipln.itaasiplncod 
   ,asitipcod    like datmservico.asitipcod   
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_cts61m03_prep is null or
    m_cts61m03_prep <> true then
    call cts61m03_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null

     display "lr_entrada.itaciacod ", lr_entrada.itaciacod  
     display "lr_entrada.itaramcod ", lr_entrada.itaramcod 
     display "lr_entrada.itaaplnum ", lr_entrada.itaaplnum 
    
    #---------------------------------------------------------------
    # Obtem os Servicos dos Atendimentos Realizados Pela Apolice 
    #---------------------------------------------------------------
     
    if lr_entrada.itaaplnum is not null then

                    
           open c_cts61m03_002 using lr_entrada.itaciacod
                                    ,lr_entrada.itaramcod
                                    ,lr_entrada.itaaplnum
                                   
                     
           foreach c_cts61m03_002 into lr_servico.atdsrvnum,
           	                           lr_servico.atdsrvano
                    
                 display "lr_servico.atdsrvnum ", lr_servico.atdsrvnum
                 display "lr_servico.atdsrvano ", lr_servico.atdsrvano
                 
                 
                 #---------------------------------------------    
                 # Consiste Servicos                               
                 #---------------------------------------------    
                 
                 call cts61m03_consiste_servico_assistencia(lr_servico.atdsrvnum,
                                                            lr_servico.atdsrvano,
                                                            lr_entrada.asitipcod)
                 returning l_resultado
           
           
                 if l_resultado = 1 then
                    let l_qtd  = l_qtd + 1
                 else
                    if l_resultado = 3 then
                       error l_mensagem sleep 2
                       exit foreach
                    end if
                 end if
           
           end foreach
           
           close c_cts61m03_002
     	     
    end if

 return l_qtd

end function


#---------------------------------------------------------#
function cts61m03_consiste_servico_assistencia(lr_entrada)
#---------------------------------------------------------#

define lr_entrada record
   atdsrvnum    like datmservico.atdsrvnum
  ,atdsrvano    like datmservico.atdsrvano
  ,asitipcod    like datmservico.asitipcod     
end record

define l_resultado smallint
      ,l_mensagem  char(60)
      ,l_atdetpcod like datmsrvacp.atdetpcod
      ,l_qtde    integer

initialize l_resultado to  null
initialize l_mensagem  to  null
initialize l_atdetpcod to  null

 if not m_cts61m03_prep then
    call cts61m03_prepare()
 end if

 #-------------------------------------------------------- 
 # Obtem a Ultima Etapa do Servico           
 #-------------------------------------------------------- 
 
 let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                        ,lr_entrada.atdsrvano)

 #--------------------------------------------------------
 # Considera Somente Servicos Liberados(1) e Acionados(3) 
 #-------------------------------------------------------- 
 
 if l_atdetpcod = 1   or
    l_atdetpcod = 3   then
      let l_resultado = 1
 else
      let l_resultado = 0
 end if
 
 
 if l_resultado = 1 then                                      
   
    
    #--------------------------------------------------------
    # Verifica Se Atendimento Tem Assistencia Relacionado 
    #--------------------------------------------------------
    
    whenever error continue                                   
    open c_cts61m03_004 using lr_entrada.atdsrvnum,           
                              lr_entrada.atdsrvano,           
                              lr_entrada.asitipcod            
    fetch c_cts61m03_004 into l_qtde                          
    whenever error stop                                       
                                                                                    
    if l_qtde = 0 then                                        
       let l_resultado = 0                                    
    else                                                      
       let l_resultado = 1                                    
    end if                                                    
    
    close c_cts61m03_004                                      
 end if                                                       
 
 return l_resultado

end function  

#---------------------------------------------------#                                                   
function cts61m03_qtd_servico_motivo(lr_entrada)                                                   
#---------------------------------------------------#                                                   
                                                                                                        
 define lr_entrada record                                                                               
    itaciacod    like datmitaapl.itaciacod                                                              
   ,itaramcod    like datmitaapl.itaramcod                                                              
   ,itaaplnum    like datmitaapl.itaaplnum                                                              
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum                                                        
   ,itaasiplncod like datkitaasipln.itaasiplncod                                                        
   ,asimtvcod    like datkasimtv.asimtvcod                                                                   
 end record                                                                                             
                                                                                                        
 define lr_servico record                                                                               
    atdsrvnum like datrservapol.atdsrvnum                                                               
   ,atdsrvano like datrservapol.atdsrvano                                                               
 end record                                                                                             
                                                                                                        
 define l_qtd integer                                                                                   
       ,l_resultado smallint                                                                            
       ,l_mensagem  char(60)                                                                            
                                                                                                        
 if m_cts61m03_prep is null or                                                                          
    m_cts61m03_prep <> true then                                                                        
    call cts61m03_prepare()                                                                             
 end if                                                                                                 
                                                                                                        
 initialize lr_servico to null                                                                          
                                                                                                        
 let l_qtd       = 0                                                                                    
 let l_resultado = null                                                                                 
 let l_mensagem  = null                                                                                 
                                                                                                        
                                                                                                        
    #---------------------------------------------------------------                                    
    # Obtem os Servicos dos Atendimentos Realizados Pela Apolice                                        
    #---------------------------------------------------------------                                    
                                                                                                        
    if lr_entrada.itaaplnum is not null then                                                            
                                                                                                        
                                                                                                        
           open c_cts61m03_002 using lr_entrada.itaciacod                                               
                                    ,lr_entrada.itaramcod                                               
                                    ,lr_entrada.itaaplnum                                               
                                                                                                        
                                                                                                        
           foreach c_cts61m03_002 into lr_servico.atdsrvnum,                                            
           	                           lr_servico.atdsrvano                                             
                                                                                                        
                 #---------------------------------------------                                         
                 # Consiste Servicos                                                                    
                 #---------------------------------------------                                         
                                                                                                        
                 call cts61m03_consiste_servico_motivo(lr_servico.atdsrvnum,                          
                                                       lr_servico.atdsrvano,                          
                                                       lr_entrada.asimtvcod)                          
                 returning l_resultado                                                                  
                                                                                                        
                                                                                                        
                 if l_resultado = 1 then                                                                
                    let l_qtd  = l_qtd + 1                                                              
                 else                                                                                   
                    if l_resultado = 3 then                                                             
                       error l_mensagem sleep 2                                                         
                       exit foreach                                                                     
                    end if                                                                              
                 end if                                                                                 
                                                                                                        
           end foreach                                                                                  
                                                                                                        
           close c_cts61m03_002                                                                         
     	                                                                                                  
    end if                                                                                              
                                                                                                        
 return l_qtd                                                                                           
                                                                                                        
end function                                                                                            
                                                                                                        
                                                                                                        
#---------------------------------------------------------#                                             
function cts61m03_consiste_servico_motivo(lr_entrada)                                              
#---------------------------------------------------------#                                             
                                                                                                        
define lr_entrada record                                                                                
   atdsrvnum    like datmservico.atdsrvnum                                                              
  ,atdsrvano    like datmservico.atdsrvano                                                              
  ,asimtvcod    like datkasimtv.asimtvcod                                                                
end record                                                                                              
                                                                                                        
define l_resultado smallint                                                                             
      ,l_mensagem  char(60)                                                                             
      ,l_atdetpcod like datmsrvacp.atdetpcod                                                            
      ,l_qtde    integer                                                                                
                                                                                                        
initialize l_resultado to  null                                                                         
initialize l_mensagem  to  null                                                                         
initialize l_atdetpcod to  null                                                                         
                                                                                                        
 if not m_cts61m03_prep then                                                                            
    call cts61m03_prepare()                                                                             
 end if                                                                                                 
                                                                                                        
 #--------------------------------------------------------                                              
 # Obtem a Ultima Etapa do Servico                                                                      
 #--------------------------------------------------------                                              
                                                                                                        
 let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum                                           
                                        ,lr_entrada.atdsrvano)                                          
                                                                                                        
 #--------------------------------------------------------                                              
 # Considera Somente Servicos Liberados(1) e Acionados(3)                                               
 #--------------------------------------------------------                                              
                                                                                                        
 if l_atdetpcod = 1   or                                                                                
    l_atdetpcod = 3   then                                                                              
      let l_resultado = 1                                                                               
 else                                                                                                   
      let l_resultado = 0                                                                               
 end if                                                                                                 
                                                                                                        
                                                                                                        
 if l_resultado = 1 then                                                                                
                                                                                                        
                                                                                                        
    #--------------------------------------------------------                                           
    # Verifica Se Atendimento Tem Motivo Relacionado                                               
    #--------------------------------------------------------                                           
                                                                                                        
    whenever error continue                                                                             
    open c_cts61m03_005 using lr_entrada.atdsrvnum,                                                     
                              lr_entrada.atdsrvano,                                                     
                              lr_entrada.asimtvcod                                                      
    fetch c_cts61m03_005 into l_qtde                                                                    
    whenever error stop                                                                                 
                                                                                                        
    if l_qtde = 0 then                                                                                  
       let l_resultado = 0                                                                              
    else                                                                                                
       let l_resultado = 1                                                                              
    end if                                                                                              
                                                                                                        
    close c_cts61m03_005                                                                                
 end if                                                                                                 
                                                                                                        
 return l_resultado                                                                                     
                                                                                                        
end function                                                                                            