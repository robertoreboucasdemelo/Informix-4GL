#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m11                                                   # 
# Objetivo.......: Cadastro Motivo X Tipo de Assistencia                      # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 04/04/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m11 array[500] of record
      asimtvcod     like datkasimtv.asimtvcod            
    , asimtvdes     like datkasimtv.asimtvdes             
    , limite        integer
    , atende        char(01)   
end record
 
define mr_param   record
     codper     smallint,                    
     desper     char(60),                    
     c24astcod  like datkassunto.c24astcod, 
     c24astdes  like datkassunto.c24astdes,
     clscod     like aackcls.clscod       ,  
     clsdes     like aackcls.clsdes       ,
     asitipcod  like datkasitip.asitipcod ,
     asitipdes  like datkasitip.asitipdes            
end record
 
define mr_ctc53m11 record
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
 function ctc53m11_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod,         ' 
         ,  '          cpodes[01,01],  '
         ,  '          cpodes[03,06]   '          
         ,  '  from datkdominio        '     
         ,  '  where cponom = ?        '     
         ,  '  order by cpocod         '     
 prepare p_ctc53m11_001 from l_sql
 declare c_ctc53m11_001 cursor for p_ctc53m11_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc53m11_002 from l_sql
 declare c_ctc53m11_002 cursor for p_ctc53m11_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[01,01]    = ? , ' 
           ,  '         cpodes[03,06]    = ? , '
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '    
           ,  ' and   cpocod = ?               '                 
 prepare p_ctc53m11_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m11_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc53m11_005    from l_sql                                             	
 declare c_ctc53m11_005 cursor for p_ctc53m11_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc53m11_006 from l_sql 
 
 
 let l_sql = ' select count(*)                '  
          ,  ' from datkdominio               '  
          ,  ' where cponom = ?               '  
 prepare p_ctc53m11_007 from l_sql               
 declare c_ctc53m11_007 cursor for p_ctc53m11_007

 
 let m_prepare = true


end function

#===============================================================================
 function ctc53m11(lr_param)
#===============================================================================
 
define lr_param record
    codper     smallint                   ,  
    desper     char(60)                   ,   
    c24astcod  like datkassunto.c24astcod , 
    c24astdes  like datkassunto.c24astdes ,
    clscod     like aackcls.clscod        ,
    clsdes     like aackcls.clsdes        ,
    asitipcod  like datkasitip.asitipcod  ,
    asitipdes  like datkasitip.asitipdes      
end record
 
define lr_retorno record
    flag       smallint                     ,
    cont       integer                      ,
    limite     integer                      ,
    atende     char(01)                     ,   
    confirma   char(01) 
end record
 
 let mr_param.codper     = lr_param.codper   
 let mr_param.desper     = lr_param.desper   
 let mr_param.c24astcod  = lr_param.c24astcod
 let mr_param.c24astdes  = lr_param.c24astdes 
 let mr_param.clscod     = lr_param.clscod 
 let mr_param.clsdes     = lr_param.clsdes
 let mr_param.asitipcod  = lr_param.asitipcod 
 let mr_param.asitipdes  = lr_param.asitipdes
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc53m11[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc53m11.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m11_prepare()
 end if
    
 let m_chave = ctc53m11_monta_chave(mr_param.codper   , 
                                    mr_param.c24astcod,
                                    mr_param.clscod   ,
                                    mr_param.asitipcod)
 
 open window w_ctc53m11 at 6,2 with form 'ctc53m11'
 attribute(form line 1)
  
 let mr_ctc53m11.msg =  '           (F17)Abandona,(F1)Inclui,(F2)Exclui,(F7)Alerta' 
   
  display by name mr_param.codper   
                , mr_param.desper   
                , mr_param.c24astcod
                , mr_param.c24astdes 
                , mr_param.clscod
                , mr_param.clsdes 
                , mr_param.asitipcod 
                , mr_param.asitipdes 
                , mr_ctc53m11.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Motivo X Tipo de Assistencia          
  #-------------------------------------------------------- 
  
  open c_ctc53m11_001  using  m_chave                                             
  foreach c_ctc53m11_001 into ma_ctc53m11[arr_aux].asimtvcod   , 
  	                          ma_ctc53m11[arr_aux].atende      , 
                              ma_ctc53m11[arr_aux].limite                                                       
       
       #--------------------------------------------------------                  
       # Recupera a Descricao do Motivo de Assistencia                                        
       #--------------------------------------------------------                  
                                                                                  
       call ctc69m04_recupera_descricao(12,ma_ctc53m11[arr_aux].asimtvcod)       
       returning ma_ctc53m11[arr_aux].asimtvdes                                     
                                                                                  
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

 input array ma_ctc53m11 without defaults from s_ctc53m11.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m11[arr_aux].asimtvcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc53m11[arr_aux] to null
                  
         display ma_ctc53m11[arr_aux].asimtvcod    to s_ctc53m11[scr_aux].asimtvcod 
         display ma_ctc53m11[arr_aux].asimtvdes    to s_ctc53m11[scr_aux].asimtvdes
         display ma_ctc53m11[arr_aux].atende       to s_ctc53m11[scr_aux].atende   
         display ma_ctc53m11[arr_aux].limite       to s_ctc53m11[scr_aux].limite                       

              
      #---------------------------------------------
       before field asimtvcod
      #---------------------------------------------
        
        if ma_ctc53m11[arr_aux].asimtvcod is null then                                                   
           display ma_ctc53m11[arr_aux].asimtvcod to s_ctc53m11[scr_aux].asimtvcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc53m11[arr_aux].* to s_ctc53m11[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares da Motivo X Tipo        
        	 #--------------------------------------------------------
        	
           call ctc53m11_dados_alteracao(ma_ctc53m11[arr_aux].asimtvcod) 
        end if 
      
      #---------------------------------------------
       after field asimtvcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc53m11[arr_aux].asimtvcod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Motivo de Assistencia          
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup(12)
        		 returning ma_ctc53m11[arr_aux].asimtvcod 
        		         , ma_ctc53m11[arr_aux].asimtvdes
        		 
        		 if ma_ctc53m11[arr_aux].asimtvcod is null then 
        		    next field asimtvcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Motivo de Assistencia       
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao(12,ma_ctc53m11[arr_aux].asimtvcod)
        		returning ma_ctc53m11[arr_aux].asimtvdes   
        		
        		if ma_ctc53m11[arr_aux].asimtvdes is null then      
        		   next field asimtvcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Motivo X Tipo Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc53m11_002 using m_chave,
                                    ma_ctc53m11[arr_aux].asimtvcod                                                
          whenever error continue                                                
          fetch c_ctc53m11_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Motivo de Assistencia ja Cadastrada Para Este Tipo!!" 
             next field asimtvcod 
          end if 
          
          display ma_ctc53m11[arr_aux].asimtvcod to s_ctc53m11[scr_aux].asimtvcod 
          display ma_ctc53m11[arr_aux].asimtvdes to s_ctc53m11[scr_aux].asimtvdes                                                                
                              
           
        else          
        	display ma_ctc53m11[arr_aux].* to s_ctc53m11[scr_aux].*                                                     
        end if
        
     
         
     
     #---------------------------------------------                                             
      before field limite                                                                       
     #---------------------------------------------                                             
         display ma_ctc53m11[arr_aux].limite   to s_ctc53m11[scr_aux].limite   attribute(reverse) 
         let lr_retorno.limite = ma_ctc53m11[arr_aux].limite  
                                                                                              
     #---------------------------------------------                                                 
      after  field limite                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field asimtvcod                                                           
         end if
         
     
     #---------------------------------------------
      before field atende 
     #---------------------------------------------                                         
         display ma_ctc53m11[arr_aux].atende  to s_ctc53m11[scr_aux].atende  attribute(reverse)
         let lr_retorno.atende = ma_ctc53m11[arr_aux].atende
                                                                  
     #--------------------------------------------- 
      after  field atende                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field limite                                    
         end if                                                     
                                                                    
         if ma_ctc53m11[arr_aux].atende  is null or
         	 (ma_ctc53m11[arr_aux].atende <> "S"   and
         	  ma_ctc53m11[arr_aux].atende <> "N")  then                    
            error "Por Favor Informe <S>im ou <N>ao!"           
            next field atende                                          
         end if         
          
             
                      
         if m_operacao <> 'i' then 
                        
            if ma_ctc53m11[arr_aux].limite  <> lr_retorno.limite  or  
            	 ma_ctc53m11[arr_aux].atende  <> lr_retorno.atende  or
            	 lr_retorno.limite            is null               then

                  
                  #--------------------------------------------------------
                  # Atualiza Associacao Tipo X Motivo         
                  #--------------------------------------------------------
                  
                  call ctc53m11_altera()
                  next field asimtvcod                  
            end if
                       
            let m_operacao = ' '                           
         else
            
           
            #-------------------------------------------------------- 
            # Inclui Associacao Tipo X Motivo                  
            #-------------------------------------------------------- 
            call ctc53m11_inclui()    
            
            next field asimtvcod            
         end if
         


         display ma_ctc53m11[arr_aux].asimtvcod     to s_ctc53m11[scr_aux].asimtvcod
         display ma_ctc53m11[arr_aux].asimtvdes     to s_ctc53m11[scr_aux].asimtvdes 
         display ma_ctc53m11[arr_aux].atende        to s_ctc53m11[scr_aux].atende 
         display ma_ctc53m11[arr_aux].limite        to s_ctc53m11[scr_aux].limite  
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m11[arr_aux].asimtvcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            if ctc53m13_valida_exclusao(mr_param.codper    ,                
            	                          mr_param.c24astcod ,                
            	                          mr_param.clscod    ,                
            	                          mr_param.asitipcod ,
            	                          ma_ctc53m11[arr_aux].asimtvcod) then
            
            
                #-------------------------------------------------------- 
                # Exclui Associacao Motivo X Tipo de Assistencia                  
                #-------------------------------------------------------- 
                
                if not ctc53m11_delete(ma_ctc53m11[arr_aux].asimtvcod) then       	
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
                                                                      	
          if ma_ctc53m11[arr_aux].asimtvcod is not null then      	  
                                                                      
              call ctc53m13(mr_param.codper                  ,        
                            mr_param.desper                  ,        
                            mr_param.c24astcod               ,        
                            mr_param.c24astdes               ,        
                            mr_param.clscod                  ,        
                            mr_param.clsdes                  ,           	
                            mr_param.asitipcod               ,
                            mr_param.asitipdes               ,
                            ma_ctc53m11[arr_aux].asimtvcod   ,               	
                            ma_ctc53m11[arr_aux].asimtvdes   )        
          end if                                                           	               
            

      
  end input
  
 close window w_ctc53m11
 
 if lr_retorno.flag = 1 then
    call ctc53m11(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc53m11_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	asimtvcod     like datkasimtv.asimtvcod  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc53m11.* to null                                                    
                                                                                      
                                                               
   open c_ctc53m11_005 using m_chave,
                             lr_param.asimtvcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc53m11_005 into  mr_ctc53m11.atldat                                       
                             ,mr_ctc53m11.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc53m11.atldat                                           
                   ,mr_ctc53m11.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc53m11_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		asimtvcod     like datkasimtv.asimtvcod     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DO MOTIVO DE ASSISTENCIA ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc53m11_006 using m_chave,
                                     lr_param.asimtvcod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Limite!'   
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
 function ctc53m11_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc53m11_003 using ma_ctc53m11[arr_aux].atende
                               , ma_ctc53m11[arr_aux].limite   
                               , lr_retorno.data_atual          
                               , lr_retorno.funmat         
                               , m_chave                                                
                               , ma_ctc53m11[arr_aux].asimtvcod
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Limite!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if   
    
    let m_operacao = ' '            
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc53m11_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc53m11[arr_aux].atende,"|", ma_ctc53m11[arr_aux].limite   using "&&&&"                     

    whenever error continue
    execute p_ctc53m11_004 using ma_ctc53m11[arr_aux].asimtvcod  
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao do Limite!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc53m11_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    codper     smallint                    ,                                           
    c24astcod  like  datkassunto.c24astcod ,
    clscod     like  aackcls.clscod        ,
    asitipcod  like datkasitip.asitipcod    
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null 

 let lr_retorno.chave = "PF_MTV", lr_param.codper using "&&",
                                  lr_param.c24astcod clipped, 
                                  lr_param.clscod clipped   , 
                                  lr_param.asitipcod using "&&&"  

 return lr_retorno.chave 
 
end function

#---------------------------------------------------------                                     
 function ctc53m11_valida_exclusao(lr_param)                                                   
#---------------------------------------------------------                                     
                                                                                               
define lr_param record                                                                         
    codper     smallint                    ,                                                   
    c24astcod  like  datkassunto.c24astcod ,                                                   
    clscod     like  aackcls.clscod        ,
    asitipcod  like datkasitip.asitipcod                                                          
end record                                                                                     
                                                                                               
                                                                                               
define lr_retorno record                                                                       
	cont integer                                                                                 
end record                                                                                     
                                                                                               
if m_prepare is null or                                                                        
    m_prepare <> true then                                                                     
    call ctc53m11_prepare()                                                                    
end if                                                                                         
                                                                                               
   initialize lr_retorno.* to null                                                             
                                                                                               
   let m_chave = ctc53m11_monta_chave(lr_param.codper   , 
                                      lr_param.c24astcod, 
                                      lr_param.clscod   ,
                                      lr_param.asitipcod)    
                                                                                               
   open c_ctc53m11_007 using m_chave                                                           
                                                                                               
   whenever error continue                                                                     
   fetch c_ctc53m11_007 into  lr_retorno.cont                                                  
   whenever error stop                                                                         
                                                                                               
   if lr_retorno.cont > 0 then                                                                 
      return false                                                                             
   else                                                                                        
   	  return true                                                                              
   end if                                                                                      
                                                                                               
end function                                                                                   
