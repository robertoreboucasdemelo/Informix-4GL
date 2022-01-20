#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m28                                                   # 
# Objetivo.......: Cadastro Natureza X Bloco                                  # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 01/04/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m28 array[500] of record
      socntzcod     like datksocntz.socntzcod            
    , socntzdes     like datksocntz.socntzdes             
    , datini       date        
    , datfim        date        
end record
 
define mr_param   record
     codper     smallint,                    
     desper     char(60),                    
     c24astcod  like  datkassunto.c24astcod, 
     c24astdes  like  datkassunto.c24astdes,
     blocod     integer                    , 
     blodes     char(60)                           
end record
 
define mr_ctc53m28 record
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
 function ctc53m28_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpocod,                '
         ,  '          cpodes[01,10],         '
         ,  '          cpodes[12,21]          '    
         ,  '  from datkdominio               '     
         ,  '  where cponom = ?               '     
         ,  '  order by cpocod                '     
 prepare p_ctc53m28_001 from l_sql
 declare c_ctc53m28_001 cursor for p_ctc53m28_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc53m28_002 from l_sql
 declare c_ctc53m28_002 cursor for p_ctc53m28_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[01,10]    = ? , '  
           ,  '         cpodes[12,21]    = ? , ' 
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '    
           ,  ' and   cpocod = ?               '                 
 prepare p_ctc53m28_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m28_004 from l_sql 	
  
  
 let l_sql = '   select atlult[01,10]        '                                  	
            ,'         ,atlult[12,18]        '                                  	                         	
            ,'    from datkdominio           '     
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '  
 prepare p_ctc53m28_005    from l_sql                                             	
 declare c_ctc53m28_005 cursor for p_ctc53m28_005  
 	
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         ' 
            ,'    and   cpocod  =  ?         '                             	                            	
 prepare p_ctc53m28_006 from l_sql
 
 
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
 prepare p_ctc53m28_007 from l_sql
 declare c_ctc53m28_007 cursor for p_ctc53m28_007
 
 	
 let m_prepare = true


end function

#===============================================================================
 function ctc53m28(lr_param)
#===============================================================================
 
define lr_param record
    codper     smallint,  
    desper     char(60),   
    c24astcod  like  datkassunto.c24astcod, 
    c24astdes  like  datkassunto.c24astdes, 
    blocod     integer                    ,
    blodes     char(60)
end record
 
define lr_retorno record
    flag       smallint                     ,
    cont       integer                      ,
    datini     date                         ,
    datfim     date                         ,
    confirma   char(01) 
end record
 
 let mr_param.codper     = lr_param.codper   
 let mr_param.desper     = lr_param.desper   
 let mr_param.c24astcod  = lr_param.c24astcod
 let mr_param.c24astdes  = lr_param.c24astdes 
 let mr_param.blocod     = lr_param.blocod 
 let mr_param.blodes     = lr_param.blodes 
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc53m28[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc53m28.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m28_prepare()
 end if
    
 let m_chave = ctc53m28_monta_chave(mr_param.codper, mr_param.c24astcod, mr_param.blocod)
 
 open window w_ctc53m28 at 6,2 with form 'ctc53m28'
 attribute(form line 1)
  
 let mr_ctc53m28.msg =  '                    (F17)Abandona,(F1)Inclui,(F2)Exclui' 
   
  display by name mr_param.codper   
                , mr_param.desper   
                , mr_param.c24astcod
                , mr_param.c24astdes 
                , mr_param.blocod 
                , mr_param.blodes 
                , mr_ctc53m28.msg  
 
  #--------------------------------------------------------
  # Recupera os Dados do Bloco X Natureza           
  #-------------------------------------------------------- 
  
  open c_ctc53m28_001  using  m_chave                                             
  foreach c_ctc53m28_001 into ma_ctc53m28[arr_aux].socntzcod,
  	                          ma_ctc53m28[arr_aux].datini  ,                       
                              ma_ctc53m28[arr_aux].datfim                                                      
       #--------------------------------------------------------                  
       # Recupera a Descricao da Natureza                                          
       #--------------------------------------------------------                  
                                                                                  
       call ctc69m04_recupera_descricao(10,ma_ctc53m28[arr_aux].socntzcod)       
       returning ma_ctc53m28[arr_aux].socntzdes                                     
                                                                                  
       let arr_aux = arr_aux + 1                                                  
                                                                                  
       if arr_aux > 500 then                                                      
          error " Limite Excedido! Foram Encontrados Mais de 500 Naturezas!"       
          exit foreach                                                            
       end if                                                                     
                                                                                  
  end foreach                                                                     
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc53m28 without defaults from s_ctc53m28.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m28[arr_aux].socntzcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc53m28[arr_aux] to null
                  
         display ma_ctc53m28[arr_aux].socntzcod  to s_ctc53m28[scr_aux].socntzcod 
         display ma_ctc53m28[arr_aux].socntzdes  to s_ctc53m28[scr_aux].socntzdes
         display ma_ctc53m28[arr_aux].datini     to s_ctc53m28[scr_aux].datini  
         display ma_ctc53m28[arr_aux].datfim     to s_ctc53m28[scr_aux].datfim                         

              
      #---------------------------------------------
       before field socntzcod
      #---------------------------------------------
        
        if ma_ctc53m28[arr_aux].socntzcod is null then                                                   
           display ma_ctc53m28[arr_aux].socntzcod to s_ctc53m28[scr_aux].socntzcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc53m28[arr_aux].* to s_ctc53m28[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Bloco X Natureza          
        	 #--------------------------------------------------------
        	
           call ctc53m28_dados_alteracao(ma_ctc53m28[arr_aux].socntzcod) 
        end if 
      
      #---------------------------------------------
       after field socntzcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc53m28[arr_aux].socntzcod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Servico          
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup(10)
        		 returning ma_ctc53m28[arr_aux].socntzcod 
        		         , ma_ctc53m28[arr_aux].socntzdes
        		 
        		 if ma_ctc53m28[arr_aux].socntzcod is null then 
        		    next field socntzcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Servico         
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao(10,ma_ctc53m28[arr_aux].socntzcod)
        		returning ma_ctc53m28[arr_aux].socntzdes   
        		
        		if ma_ctc53m28[arr_aux].socntzdes is null then      
        		   next field socntzcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Bloco X Natureza Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc53m28_002 using m_chave,
                                    ma_ctc53m28[arr_aux].socntzcod                                                
          whenever error continue                                                
          fetch c_ctc53m28_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Natureza ja Cadastrada Para Este Bloco!!" 
             next field socntzcod 
          end if 
          
          display ma_ctc53m28[arr_aux].socntzcod to s_ctc53m28[scr_aux].socntzcod 
          display ma_ctc53m28[arr_aux].socntzdes to s_ctc53m28[scr_aux].socntzdes                                                                
                              
           
        else          
        	display ma_ctc53m28[arr_aux].* to s_ctc53m28[scr_aux].*                                                     
        end if
        
     #---------------------------------------------
      before field datini 
     #---------------------------------------------                                         
         display ma_ctc53m28[arr_aux].datini  to s_ctc53m28[scr_aux].datini  attribute(reverse)
         let lr_retorno.datini = ma_ctc53m28[arr_aux].datini
                                                                  
     #--------------------------------------------- 
      after  field datini                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field socntzcod                                    
         end if                                                     
                                                                    
         if ma_ctc53m28[arr_aux].datini    is null   then                    
            error "Por Favor Informe a Data Inicial!"           
            next field datini                                         
         end if 
         
     #---------------------------------------------                                             
      before field datfim                                                                       
     #---------------------------------------------                                             
         display ma_ctc53m28[arr_aux].datfim   to s_ctc53m28[scr_aux].datfim   attribute(reverse) 
         let lr_retorno.datfim = ma_ctc53m28[arr_aux].datfim  
                                                                                              
     #---------------------------------------------                                                 
      after  field datfim                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field datini                                                            
         end if 
         
         if ma_ctc53m28[arr_aux].datfim    is null   then                    
            error "Por Favor Informe a Data Final!"           
            next field datfim                                         
         end if 
         
         if ma_ctc53m28[arr_aux].datfim < ma_ctc53m28[arr_aux].datini then        
            error "Data Inicial Nao Pode ser Maior que a Data Final!"              
            next field datfim                                    
         end if                                                  
         
               
         if m_operacao <> 'i' then 
                        
            if ma_ctc53m28[arr_aux].datini  <> lr_retorno.datini  or
               ma_ctc53m28[arr_aux].datfim  <> lr_retorno.datfim  then 	             	                                                                                           
                  
                  #--------------------------------------------------------
                  # Atualiza Associacao Bloco X Natureza          
                  #--------------------------------------------------------
                  
                  call ctc53m28_altera()
                  next field socntzcod                  
            end if
                       
            let m_operacao = ' '                           
         else
            
            #-------------------------------------------------------- 
            # Inclui Associacao Natureza X Bloco                  
            #-------------------------------------------------------- 
            call ctc53m28_inclui()    
            
            next field socntzcod            
         end if
         
         display ma_ctc53m28[arr_aux].socntzcod  to s_ctc53m28[scr_aux].socntzcod
         display ma_ctc53m28[arr_aux].socntzdes  to s_ctc53m28[scr_aux].socntzdes
         display ma_ctc53m28[arr_aux].datini     to s_ctc53m28[scr_aux].datini  
         display ma_ctc53m28[arr_aux].datfim     to s_ctc53m28[scr_aux].datfim   
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m28[arr_aux].socntzcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            #-------------------------------------------------------- 
            # Exclui Associacao Bloco X Natureza                  
            #-------------------------------------------------------- 
            
            if not ctc53m28_delete(ma_ctc53m28[arr_aux].socntzcod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
           
      
            next field socntzcod
                                                                   	
         end if
         
         
      
  end input
  
 close window w_ctc53m28
 
 if lr_retorno.flag = 1 then
    call ctc53m28(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc53m28_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	socntzcod     like datksocntz.socntzcod  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc53m28.* to null                                                    
                                                                                      
                                                               
   open c_ctc53m28_005 using m_chave,
                             lr_param.socntzcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc53m28_005 into  mr_ctc53m28.atldat                                       
                             ,mr_ctc53m28.funmat                                       
                                                             
                                                                                      
   whenever error stop  
                                                                                                                                        
                                                                                
   display by name  mr_ctc53m28.atldat                                           
                   ,mr_ctc53m28.funmat                                   
                                                                                         
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc53m28_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		socntzcod     like datksocntz.socntzcod     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE NATUREZA ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc53m28_006 using m_chave,
                                     lr_param.socntzcod                                               
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Natureza!'   
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
 function ctc53m28_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc53m28_003 using ma_ctc53m28[arr_aux].datini
                               , ma_ctc53m28[arr_aux].datfim
                               , lr_retorno.data_atual          
                               , lr_retorno.funmat         
                               , m_chave                                                
                               , ma_ctc53m28[arr_aux].socntzcod
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao da Natureza!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if   
    
    let m_operacao = ' '            
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc53m28_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    let lr_retorno.cpodes = ma_ctc53m28[arr_aux].datini clipped , "|", ma_ctc53m28[arr_aux].datfim clipped                       

    whenever error continue
    execute p_ctc53m28_004 using ma_ctc53m28[arr_aux].socntzcod   
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult
                               
    whenever error continue
    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'             
       let m_operacao = ' '                                                                                                                            
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Natureza!'
    end if                    
                                                                                      
end function 

#===============================================================================     
 function ctc53m28_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    codper     smallint                    ,                                           
    c24astcod  like  datkassunto.c24astcod ,
    blocod     integer   
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "PF_BLO_", lr_param.codper using "&&", "_" , lr_param.c24astcod clipped, "_", lr_param.blocod  using "&&&"  

 return lr_retorno.chave 
 
end function

#---------------------------------------------------------                                            
 function ctc53m28_valida_exclusao(lr_param)                                                                                               
#--------------------------------------------------------- 

define lr_param record                      
    codper     smallint                     ,                                           
    c24astcod  like  datkassunto.c24astcod  ,
    blocod     integer    
end record
                                                                              
                                                              
define lr_retorno record                                      
	cont integer                                                
end record                                                    
                                                              
if m_prepare is null or                                       
    m_prepare <> true then                                    
    call ctc53m28_prepare()                                   
end if                                                        
                                                              
   initialize lr_retorno.* to null                            
                                                              
   let m_chave = ctc53m28_monta_chave(lr_param.codper, lr_param.c24astcod, lr_param.blocod)                       
                                                              
   open c_ctc53m28_007 using m_chave                         
                                                                                                        
   whenever error continue                                    
   fetch c_ctc53m28_007 into  lr_retorno.cont                 
   whenever error stop                                        
                                                              
   if lr_retorno.cont > 0 then                                
      return false                                           
   else                                                       
   	  return true                                            
   end if                                                     
                                                              
end function                                                  
