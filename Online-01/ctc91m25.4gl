#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Itau                                              # 
# Modulo.........: ctc91m25                                                   # 
# Objetivo.......: Cadastro Garantia X Motivo                                 # 
# Analista Resp. : Moises Gabel                                               # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 29/07/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc91m25 array[500] of record     
      itarsrcaomtvcod    like datrmtvrsrcaogrt.itarsrcaomtvcod          
    , itarsrcaomtvdes    like datkitarsrcaomtv.itarsrcaomtvdes            
    , rsrcaoatdvigdat    like datrmtvrsrcaogrt.rsrcaoatdvigdat        
end record
 
define mr_param   record
     rsrcaogrtcod     like datrmtvrsrcaogrt.rsrcaogrtcod ,                   
     itarsrcaogrtdes  like datkitarsrcaogar.itarsrcaogrtdes
end record
 
define mr_ctc91m25 record                       
      atlempcod       like datrmtvrsrcaogrt.atlempcod 
     ,atlmatnum       like datrmtvrsrcaogrt.atlmatnum
     ,atldat          like datrmtvrsrcaogrt.atldat   
     ,funnom          like isskfunc.funnom      
     ,atlusrtipcod    like datrmtvrsrcaogrt.atlusrtipcod
     ,msg             char(80)
end record                                      


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc91m25_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select a.itarsrcaomtvcod           '
          ,  '      , b.itarsrcaomtvdes           '
          ,  '      , a.rsrcaoatdvigdat           '       
          ,  '   from datrmtvrsrcaogrt a,         '
          ,  '        datkitarsrcaomtv b          '    
          ,  '  where a.itarsrcaomtvcod  = b.itarsrcaomtvcod  '         
          ,  '  and   a.rsrcaogrtcod = ?          '
          ,  '  order by a.itarsrcaomtvcod        '
 prepare p_ctc91m25_001 from l_sql
 declare c_ctc91m25_001 cursor for p_ctc91m25_001
 	
 let l_sql = ' select count(*)           '
          ,  '  from datrmtvrsrcaogrt    '
          ,  '  where itarsrcaomtvcod   = ? '         
          ,  '  and   rsrcaogrtcod      = ? '
 prepare p_ctc91m25_002 from l_sql
 declare c_ctc91m25_002 cursor for p_ctc91m25_002
 	
 let l_sql =  ' update datrmtvrsrcaogrt           '
           ,  '     set rsrcaoatdvigdat    = ? ,  '  
           ,  '         atldat    = ? ,           ' 
           ,  '         atlmatnum = ?             '
           ,  '  where itarsrcaomtvcod   = ?      '         
           ,  '  and   rsrcaogrtcod      = ?      '                         
 prepare p_ctc91m25_003 from l_sql
   
 let l_sql =  ' insert into datrmtvrsrcaogrt   '
           ,  '   (rsrcaogrtcod                '          
           ,  '   ,itarsrcaomtvcod             '
           ,  '   ,rsrcaoatdvigdat             '
           ,  '   ,atlusrtipcod                '
           ,  '   ,atlempcod                   '
           ,  '   ,atlmatnum                   '
           ,  '   ,atldat)                     '
           ,  ' values(?,?,?,?,?,?,?)          '
 prepare p_ctc91m25_004 from l_sql 	
  
 
 let l_sql = '   select atlempcod              '                                  	
            ,'         ,atlmatnum              '                                  	
            ,'         ,atldat                 '                                  	
            ,'         ,atlusrtipcod           '                            	
            ,'     from datrmtvrsrcaogrt       '     
            ,'    where rsrcaogrtcod  =  ?     ' 
            ,'    and   itarsrcaomtvcod = ?    '
 prepare p_ctc91m25_005    from l_sql                                             	
 declare c_ctc91m25_005 cursor for p_ctc91m25_005                                 	
    
  
 let l_sql = '  delete datrmtvrsrcaogrt     '   
            ,'  where  rsrcaogrtcod = ?     ' 
            ,'  and itarsrcaomtvcod = ?     '   
 prepare p_ctc91m25_006 from l_sql  	  
        

 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc91m25_008 from l_sql
 declare c_ctc91m25_008 cursor for p_ctc91m25_008
 	
 
 
 let m_prepare = true


end function

#===============================================================================
 function ctc91m25(lr_param)
#===============================================================================
 
define lr_param record
    rsrcaogrtcod     like datrmtvrsrcaogrt.rsrcaogrtcod ,     
    itarsrcaogrtdes  like datkitarsrcaogar.itarsrcaogrtdes 
end record
 
define lr_retorno record
    flag             smallint                                ,
    cont             integer                                 ,
    rsrcaoatdvigdat  like datrmtvrsrcaogrt.rsrcaoatdvigdat   ,
    confirma         char(01) 
end record
 
 let mr_param.rsrcaogrtcod     = lr_param.rsrcaogrtcod   
 let mr_param.itarsrcaogrtdes  = lr_param.itarsrcaogrtdes   

 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc91m25[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc91m25.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc91m25_prepare()
 end if
    
 
 open window w_ctc91m25 at 6,2 with form 'ctc91m25'
 attribute(form line first, message line last,comment line last - 1, border)
 
 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui '  
   
  display by name mr_param.rsrcaogrtcod   
                , mr_param.itarsrcaogrtdes   
                
 
  #--------------------------------------------------------
  # Recupera os Dados do Motivo         
  #-------------------------------------------------------- 
  
  open c_ctc91m25_001  using  mr_param.rsrcaogrtcod                                            
  foreach c_ctc91m25_001 into ma_ctc91m25[arr_aux].itarsrcaomtvcod,
  	                          ma_ctc91m25[arr_aux].itarsrcaomtvdes,                       
                              ma_ctc91m25[arr_aux].rsrcaoatdvigdat                                                                                       
                                                                                  
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

 input array ma_ctc91m25 without defaults from s_ctc91m25.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc91m25[arr_aux].itarsrcaomtvcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc91m25[arr_aux] to null
                  
         display ma_ctc91m25[arr_aux].itarsrcaomtvcod  to s_ctc91m25[scr_aux].itarsrcaomtvcod 
         display ma_ctc91m25[arr_aux].itarsrcaomtvdes  to s_ctc91m25[scr_aux].itarsrcaomtvdes
         display ma_ctc91m25[arr_aux].rsrcaoatdvigdat  to s_ctc91m25[scr_aux].rsrcaoatdvigdat                         

              
      #---------------------------------------------
       before field itarsrcaomtvcod
      #---------------------------------------------
        
        if ma_ctc91m25[arr_aux].itarsrcaomtvcod is null then                                                   
           display ma_ctc91m25[arr_aux].itarsrcaomtvcod to s_ctc91m25[scr_aux].itarsrcaomtvcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc91m25[arr_aux].* to s_ctc91m25[scr_aux].* attribute(reverse)                       
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Motivo          
        	 #--------------------------------------------------------
        	
           call ctc91m25_dados_alteracao(mr_param.rsrcaogrtcod,ma_ctc91m25[arr_aux].itarsrcaomtvcod) 
        end if 
      
      #---------------------------------------------
       after field itarsrcaomtvcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc91m25[arr_aux].itarsrcaomtvcod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Motivo          
        		 #--------------------------------------------------------
        		 
        		 call ctc91m24_popup(1)
        		 returning ma_ctc91m25[arr_aux].itarsrcaomtvcod 
        		         , ma_ctc91m25[arr_aux].itarsrcaomtvdes
        		 
        		 if ma_ctc91m25[arr_aux].itarsrcaomtvcod is null then 
        		    next field itarsrcaomtvcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Motivo       
        		#--------------------------------------------------------
        		
        		call ctc91m24_recupera_descricao(1,ma_ctc91m25[arr_aux].itarsrcaomtvcod)
        		returning ma_ctc91m25[arr_aux].itarsrcaomtvdes   
        		
        		if ma_ctc91m25[arr_aux].itarsrcaomtvdes is null then      
        		   next field itarsrcaomtvcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se o Motivo Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc91m25_002 using ma_ctc91m25[arr_aux].itarsrcaomtvcod,
                                    mr_param.rsrcaogrtcod
                                                                                    
          whenever error continue                                                
          fetch c_ctc91m25_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Motivo ja Cadastrado Para Esta Garantia!!" 
             next field itarsrcaomtvcod 
          end if 
          
          display ma_ctc91m25[arr_aux].itarsrcaomtvcod to s_ctc91m25[scr_aux].itarsrcaomtvcod 
          display ma_ctc91m25[arr_aux].itarsrcaomtvdes to s_ctc91m25[scr_aux].itarsrcaomtvdes                                                                
                              
           
        else          
        	display ma_ctc91m25[arr_aux].* to s_ctc91m25[scr_aux].*                                                     
        end if
        
    
     #---------------------------------------------                                             
      before field rsrcaoatdvigdat                                                                       
     #---------------------------------------------                                             
         
         if m_operacao = 'i' then
             let ma_ctc91m25[arr_aux].rsrcaoatdvigdat = today
         end if         
        
         display ma_ctc91m25[arr_aux].rsrcaoatdvigdat   to s_ctc91m25[scr_aux].rsrcaoatdvigdat   attribute(reverse) 
         let lr_retorno.rsrcaoatdvigdat = ma_ctc91m25[arr_aux].rsrcaoatdvigdat  
                                                                                              
     #---------------------------------------------                                                 
      after  field rsrcaoatdvigdat                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field itarsrcaomtvcod                                                            
         end if 
         
         if ma_ctc91m25[arr_aux].rsrcaoatdvigdat    is null   then                    
            error "Por Favor Informe a Data!"           
            next field rsrcaoatdvigdat                                         
         end if                                             
         
               
         if m_operacao <> 'i' then 
                        
            if ma_ctc91m25[arr_aux].rsrcaoatdvigdat  <> lr_retorno.rsrcaoatdvigdat  then 	             	                                                                                           
                  
                  #--------------------------------------------------------
                  # Atualiza o Motivo          
                  #--------------------------------------------------------
                  
                  call ctc91m25_altera()
                  next field itarsrcaomtvcod                  
            end if
                       
            let m_operacao = ' '                           
         else
            
            #-------------------------------------------------------- 
            # Inclui Motivo                  
            #-------------------------------------------------------- 
            call ctc91m25_inclui()    
            
            next field itarsrcaomtvcod            
         end if
         
         display ma_ctc91m25[arr_aux].itarsrcaomtvcod  to s_ctc91m25[scr_aux].itarsrcaomtvcod
         display ma_ctc91m25[arr_aux].itarsrcaomtvdes  to s_ctc91m25[scr_aux].itarsrcaomtvdes
         display ma_ctc91m25[arr_aux].rsrcaoatdvigdat  to s_ctc91m25[scr_aux].rsrcaoatdvigdat   
        
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc91m25[arr_aux].itarsrcaomtvcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
        
            #-------------------------------------------------------- 
            # Exclui Associacao Garantia X Motivo                  
            #-------------------------------------------------------- 
            
            if not ctc91m25_delete(ma_ctc91m25[arr_aux].itarsrcaomtvcod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if   
           
      
            next field itarsrcaomtvcod
                                                                   	
         end if
         
         
      
  end input
  
 close window w_ctc91m25
 
 if lr_retorno.flag = 1 then
    call ctc91m25(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------                                                                                            
 function ctc91m25_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	rsrcaogrtcod     smallint,  
	itarsrcaomtvcod  smallint  
end record
                                                                                                    
                                                                                      
   initialize mr_ctc91m25.* to null                                                    
                                                                                      
                                                               
   open c_ctc91m25_005 using lr_param.rsrcaogrtcod,
                             lr_param.itarsrcaomtvcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc91m25_005 into  mr_ctc91m25.atlempcod                                         
                             ,mr_ctc91m25.atlmatnum                                         
                             ,mr_ctc91m25.atldat                      
                             ,mr_ctc91m25.atlusrtipcod                                            
   whenever error stop  
                                                                                                                                         
   call ctc91m25_func(mr_ctc91m25.atlmatnum  , mr_ctc91m25.atlempcod, mr_ctc91m25.atlusrtipcod )   
   returning mr_ctc91m25.funnom                                                                                                                                           
                                                                                                                                  
   display by name  mr_ctc91m25.atldat                                                                                
                   ,mr_ctc91m25.funnom                                                                                                                                            
                                                                                      

end function                                                                          
              

#==============================================                                                
 function ctc91m25_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		itarsrcaomtvcod    smallint   
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE MOTIVO ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc91m25_006 using mr_param.rsrcaogrtcod,
                                     lr_param.itarsrcaomtvcod                                               
                                                                                                                                                     
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
 function ctc91m25_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc91m25_003 using ma_ctc91m25[arr_aux].rsrcaoatdvigdat
                               , lr_retorno.data_atual          
                               , lr_retorno.funmat                                                    
                               , ma_ctc91m25[arr_aux].itarsrcaomtvcod
                               , mr_param.rsrcaogrtcod     
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Motivo!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if   
    
    let m_operacao = ' '            
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc91m25_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date     
end record	  

initialize lr_retorno.* to null 

   let lr_retorno.data_atual = today                                     

   whenever error continue                                               
   execute p_ctc91m25_004 using mr_param.rsrcaogrtcod                
                              , ma_ctc91m25[arr_aux].itarsrcaomtvcod 
                              , ma_ctc91m25[arr_aux].rsrcaoatdvigdat     
                              , g_issk.usrtip                            
                              , g_issk.empcod                            
                              , g_issk.funmat                             
                              , lr_retorno.data_atual                                   
                                                                          
   whenever error continue                                                
   if sqlca.sqlcode = 0 then                                              
      error 'Dados Incluidos com Sucesso!'                                                      
      let m_operacao = ' '                                               
   else                                                                   
      error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'          
   end if 
    
    
                              
                                                                                      
end function 

#---------------------------------------------------------                                                   
 function ctc91m25_func(lr_param)                                
#---------------------------------------------------------      
                                                                
 define lr_param  record                                        
    funmat       like isskfunc.funmat,                          
    empcod       like isskfunc.empcod,                          
    atlusrtipcod like isskfunc.usrtip                           
 end record                                                     
                                                                
 define lr_retorno            record                            
    funnom    like isskfunc.funnom                              
 end record                                                     
                                                                
if m_prepare is null or                                         
  m_prepare <> true then                                        
  call ctc91m25_prepare()                                       
end if                                                          
                                                                
 initialize lr_retorno.*    to null                             
                                                                
   if lr_param.empcod is null or                                
      lr_param.empcod = " " then                                
                                                                
      let lr_param.empcod = 1                                   
                                                                
   end if                                                       
                                                                
                                                                
   #--------------------------------------------------------    
   # Recupera os Dados do Funcionario                           
   #--------------------------------------------------------    
                                                                
                                                                
   open c_ctc91m25_008 using lr_param.empcod ,                  
                             lr_param.funmat ,                  
                             lr_param.atlusrtipcod                 
   whenever error continue                                      
   fetch c_ctc91m25_008 into lr_retorno.funnom                  
   whenever error stop                                          
                                                                
 return lr_retorno.funnom                                       
                                                                
 end function                                                   
                                                                
                                                                