#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc91m36                                                   # 
# Objetivo.......: Cadastro Segmento X Motivo de Hospedagem                   # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 27/10/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc91m36 array[500] of record
      asimtvcod  like  datkasimtv.asimtvcod           
    , asimtvdes  like  datkasimtv.asimtvdes              
end record
 
define mr_param   record
    itaclisgmcod  smallint,   
    itaclisgmdes  char(60)     
end record
 
define mr_ctc91m36 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)    
     ,cpocod          like datkdominio.cpocod  
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc91m36_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpodes                  '
          ,  '  from datkdominio               '  
          ,  '  where cponom = ?               '  
          ,  '  order by cpodes                '
 prepare p_ctc91m36_001 from l_sql
 declare c_ctc91m36_001 cursor for p_ctc91m36_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpodes = ?               '
 prepare p_ctc91m36_002 from l_sql
 declare c_ctc91m36_002 cursor for p_ctc91m36_002

  
let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc91m36_004 from l_sql 	
  
 
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes  =  ?         ' 
 prepare p_ctc91m36_005    from l_sql                                             	
 declare c_ctc91m36_005 cursor for p_ctc91m36_005  
 	
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpodes  =  ?         '                             	                            	
 prepare p_ctc91m36_006 from l_sql  
 
 
 let l_sql = '   select max(cpocod)     '                
            ,'   from datkdominio       '    
            ,'   where cponom  =  ?     '                
 prepare p_ctc91m36_007    from l_sql             
 declare c_ctc91m36_007 cursor for p_ctc91m36_007 
 	
 
 	
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         '                      	                            	  	                 	
 prepare p_ctc91m36_009 from l_sql                	
 

 let m_prepare = true


end function

#===============================================================================
 function ctc91m36(lr_param)
#===============================================================================
 
define lr_param record
  itaclisgmcod         smallint,   
  itaclisgmdes         char(60)       
end record
 
define lr_retorno record
    flag                 smallint                               ,
    cont                 integer                                ,
    confirma             char(01) 
end record
 
 let mr_param.itaclisgmcod    = lr_param.itaclisgmcod 
 let mr_param.itaclisgmdes    = lr_param.itaclisgmdes 
 
 let m_chave = ctc91m36_monta_chave(mr_param.itaclisgmcod)
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc91m36[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc91m36.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc91m36_prepare()
 end if
    
 
 
 open window w_ctc91m36 at 6,2 with form 'ctc91m36'
 attribute(form line first, message line last,comment line last - 1, border)
  
  let mr_ctc91m36.msg  = '             (F17)Abandona, (F1)Inclui, (F2)Exclui, (F7)Alerta'
   
  display by name mr_param.itaclisgmcod
                , mr_param.itaclisgmdes
                , mr_ctc91m36.msg 
                  
  
 
  #--------------------------------------------------------
  # Recupera os Dados do Segmento X Motivo           
  #-------------------------------------------------------- 
  
  open c_ctc91m36_001  using  m_chave 
  foreach c_ctc91m36_001 into ma_ctc91m36[arr_aux].asimtvcod

       #--------------------------------------------------------
       # Recupera a Descricao do Motivo 
       #--------------------------------------------------------
       
       call ctc91m30_recupera_descricao(2,ma_ctc91m36[arr_aux].asimtvcod)
       returning ma_ctc91m36[arr_aux].asimtvdes

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Motivos!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc91m36 without defaults from s_ctc91m36.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc91m36[arr_aux].asimtvcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc91m36[arr_aux] to null
                  
         display ma_ctc91m36[arr_aux].asimtvcod   to s_ctc91m36[scr_aux].asimtvcod 
       
      #---------------------------------------------
       before field asimtvcod
      #---------------------------------------------
        
        if ma_ctc91m36[arr_aux].asimtvcod is null then                                                   
           display ma_ctc91m36[arr_aux].asimtvcod to s_ctc91m36[scr_aux].asimtvcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc91m36[arr_aux].* to s_ctc91m36[scr_aux].* attribute(reverse)                          
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Segmento X Motivo          
        	 #--------------------------------------------------------
        	
           call ctc91m36_dados_alteracao(ma_ctc91m36[arr_aux].asimtvcod) 
        end if 
      
      #---------------------------------------------
       after field asimtvcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc91m36[arr_aux].asimtvcod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Motivo        
        		 #--------------------------------------------------------
        		 
        		 call ctc91m30_popup(02)
        		 returning ma_ctc91m36[arr_aux].asimtvcod 
        		         , ma_ctc91m36[arr_aux].asimtvdes       		      
        		 
        		 if ma_ctc91m36[arr_aux].asimtvcod is null then 
        		    next field asimtvcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Motivo        
        		#--------------------------------------------------------
        		
        		call ctc91m30_recupera_descricao(2,ma_ctc91m36[arr_aux].asimtvcod)
        		returning ma_ctc91m36[arr_aux].asimtvdes  
        		
        		if ma_ctc91m36[arr_aux].asimtvdes  is null then      
        		   next field asimtvcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Segmento X Motivo Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc91m36_002 using m_chave, 
                                    ma_ctc91m36[arr_aux].asimtvcod            
                                          
          whenever error continue                                                
          fetch c_ctc91m36_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Motivo ja Cadastrado Para Esse Segmento!" 
             next field asimtvcod 
          end if 
          
          display ma_ctc91m36[arr_aux].asimtvcod to s_ctc91m36[scr_aux].asimtvcod 
          display ma_ctc91m36[arr_aux].asimtvdes to s_ctc91m36[scr_aux].asimtvdes                                                               
                              
           
        else          
        	display ma_ctc91m36[arr_aux].* to s_ctc91m36[scr_aux].*                                                     
        end if
        
         
         if m_operacao = 'i' then 
               
            #-------------------------------------------------------- 
            # Recupera Codigo da Associacao Segmento X Motivo                  
            #--------------------------------------------------------          
            call ctc91m36_recupera_chave()          
            
            #-------------------------------------------------------- 
            # Inclui Associacao Segmento X Motivo                  
            #-------------------------------------------------------- 
            call ctc91m36_inclui()  
                    
            next field asimtvcod            
         end if
         
         display ma_ctc91m36[arr_aux].asimtvcod   to s_ctc91m36[scr_aux].asimtvcod
         display ma_ctc91m36[arr_aux].asimtvdes   to s_ctc91m36[scr_aux].asimtvdes   
      
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc91m36[arr_aux].asimtvcod  is null   then                    	
            continue input                                                  	
         else                                                               	
                                             
            if ctc91m37_valida_exclusao(mr_param.itaclisgmcod, ma_ctc91m36[arr_aux].asimtvcod) then
            
                 #-------------------------------------------------------- 
                 # Exclui Associacao Segmento X Motivo                  
                 #-------------------------------------------------------- 
                 
                 if not ctc91m36_delete(ma_ctc91m36[arr_aux].asimtvcod) then       	
                     let lr_retorno.flag = 1                                              	
                     exit input                                                  	
                 end if   
                                   
                 next field asimtvcod
             else                                                                        
                  error "Alertas Cadastrados para Esse Motivo! Por Favor Exclua-os Primeiro." 
                  let lr_retorno.flag = 1                                                 
                  exit input                                                              
             end if	         
                                                                               	
         end if                     
      
      
      
      
      #---------------------------------------------                  	
       on key (F7)                                                    	
      #---------------------------------------------                  	
                                                                      	          
          
         if ma_ctc91m36[arr_aux].asimtvcod is not null then     
                                                                
             call ctc91m37(mr_param.itaclisgmcod                  ,   
                           mr_param.itaclisgmdes                  ,   
                           ma_ctc91m36[arr_aux].asimtvcod         ,   
                           ma_ctc91m36[arr_aux].asimtvdes)      
         end if                                                 
                                                
  end input
  
 close window w_ctc91m36
 
 if lr_retorno.flag = 1 then
    call ctc91m36(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc91m36_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	asimtvcod like  datkasimtv.asimtvcod
end record
                                                                                                    
                                                                                      
   initialize mr_ctc91m36.* to null                                                    
                                                                                      
                                                               
   open c_ctc91m36_005 using m_chave,
                             lr_param.asimtvcod                                                  
      
   whenever error continue                                                 
   fetch c_ctc91m36_005 into  mr_ctc91m36.atldat                                       
                             ,mr_ctc91m36.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc91m36.atldat                                           
                   ,mr_ctc91m36.funmat                                   
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc91m36_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		asimtvcod like  datkasimtv.asimtvcod    
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE MOTIVO?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc91m36_006 using m_chave,
                                     lr_param.asimtvcod                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Motivo!'   
           rollback work
           return false                                                                                                                                               
        end if 
                                                                                                                                                                      
        commit work
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function 



#---------------------------------------------------------                                                                                            
 function ctc91m36_inclui()                                             
#---------------------------------------------------------

define lr_retorno record
   data_atual date,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
   
    whenever error continue
    execute p_ctc91m36_004 using mr_ctc91m36.cpocod    
                               , ma_ctc91m36[arr_aux].asimtvcod
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if                    
                                                                                      
end function

#---------------------------------------------------------                                                                                         
 function ctc91m36_recupera_chave()                                                                                                                                       
#---------------------------------------------------------                                                                                                        
                                                                                
    open c_ctc91m36_007 using m_chave                                                           
    whenever error continue                                       
    fetch c_ctc91m36_007 into mr_ctc91m36.cpocod                                                             
    whenever error stop 
    
    if mr_ctc91m36.cpocod is null or
    	 mr_ctc91m36.cpocod = ""    or
    	 mr_ctc91m36.cpocod = 0     then    	 	
    	 	let mr_ctc91m36.cpocod = 1  
    else
    	  let mr_ctc91m36.cpocod = mr_ctc91m36.cpocod + 1
    end if	                                                                                                                                
                              
end function



#===============================================================================     
 function ctc91m36_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    itaclisgmcod     smallint                   
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "SGM_", lr_param.itaclisgmcod using "&&", "_MTV_H"

 return lr_retorno.chave 
 
end function                                                                              
                                                                            























