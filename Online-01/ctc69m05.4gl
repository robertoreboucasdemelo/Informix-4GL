#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Regras Siebel                                              # 
# Modulo.........: ctc69m05                                                   # 
# Objetivo.......: Cadastro Servico X Especialidade                           # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 16/08/2013                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m05 array[500] of record
      srvespcod  like datksrvgrpesp.srvespcod
    , srvespnom  like datksrvesp.srvespnom
    , regsitflg  like datksrvgrpesp.regsitflg
end record
 
define mr_param   record
       srvgrpcod      like datksrvgrp.srvgrpcod
     , srvgrptipcod   like datksrvgrptip.srvgrptipcod 
     , srvgrptipnom   like datksrvgrptip.srvgrptipnom 
     , srvcod         like datksrv.srvcod
     , srvnom         like datksrv.srvnom
end record
 
define mr_ctc69m05 record
      empcod           like datksrvgrpesp.empcod   
     ,usrmatnum        like datksrvgrpesp.usrmatnum
     ,regatldat        like datksrvgrpesp.regatldat
     ,funnom           like isskfunc.funnom 
     ,usrtipcod        like datksrvgrpesp.usrtipcod 
end record

define ma_retorno array[500] of record  
     srvgrpespcod  like datksrvgrpesp.srvgrpespcod           
end record                               


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc69m05_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.srvgrpespcod               '
          ,  '      , a.srvespcod                  '
          ,  '      , b.srvespnom                  '
          ,  '      , a.regsitflg                  '
          ,  '   from datksrvgrpesp a,             '  
          ,  '        datksrvesp b                 '  
          ,  '  where a.srvespcod = b.srvespnum    '         
          ,  '   and  a.srvgrpcod = ?              '
          ,  '  order by a.regsitflg, a.srvespcod  '
 prepare p_ctc69m05_001 from l_sql
 declare c_ctc69m05_001 cursor for p_ctc69m05_001
 	
 let l_sql = ' select count(*)         '
          ,  '  from datksrvgrpesp     '
          ,  '  where srvespcod = ?    '         
          ,  '   and  srvgrpcod = ?    '
 prepare p_ctc69m05_002 from l_sql
 declare c_ctc69m05_002 cursor for p_ctc69m05_002
 
 let l_sql = ' update datksrvgrpesp       '
           ,  '     set regsitflg = ? ,   '
           ,  '         usrtipcod = ? ,   '
           ,  '         empcod    = ? ,   '
           ,  '         usrmatnum = ? ,   '
           ,  '         regatldat = ?     '
           ,  '   where srvgrpespcod =  ? '        
 prepare p_ctc69m05_003 from l_sql
  
 let l_sql =  ' insert into datksrvgrpesp   '
           ,  '   (srvgrpcod                '          
           ,  '   ,srvespcod                '
           ,  '   ,regsitflg                '   
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?,?)       '
 prepare p_ctc69m05_004 from l_sql 	
  
 
 let l_sql = '   select empcod             '                                  	
            ,'         ,usrmatnum          '                                  	
            ,'         ,regatldat          '                                  	
            ,'         ,usrtipcod          '                            	
            ,'     from datksrvgrpesp      '     
            ,'    where srvgrpespcod  =  ? '  
 prepare p_ctc69m05_005    from l_sql                                             	
 declare c_ctc69m05_005 cursor for p_ctc69m05_005                                 	
    
  
 
 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m05_008 from l_sql
 declare c_ctc69m05_008 cursor for p_ctc69m05_008
 	
 
  let l_sql = ' select count(*)         '       	         	 
           , '  from datksrvgrp         '           	 	       	 
           , ' where srvgrpcod = ?      ' 	 
           , '   and regsitflg = "A"    '       	 	     	 
  prepare p_ctc69m05_009 from l_sql               	         	 
  declare c_ctc69m05_009 cursor for p_ctc69m05_009 	
 	 
 
 let m_prepare = true


end function

#===============================================================================
 function ctc69m05(lr_param)
#===============================================================================
 
define lr_param record
    srvgrpcod      like datksrvgrp.srvgrpcod       ,
    srvgrptipcod   like datksrvgrptip.srvgrptipcod ,
    srvgrptipnom   like datksrvgrptip.srvgrptipnom ,
    srvcod         like datksrv.srvcod             ,
    srvnom         like datksrv.srvnom             
end record
 
define lr_retorno record
    flag            smallint                     ,
    cont            integer                      ,
    srvespnom       like datksrvesp.srvespnom    ,
    regsitflg       like datksrvgrpesp.regsitflg ,
    confirma        char(01) 
end record
 
 let mr_param.srvgrpcod     = lr_param.srvgrpcod
 let mr_param.srvgrptipcod  = lr_param.srvgrptipcod
 let mr_param.srvgrptipnom  = lr_param.srvgrptipnom  
 let mr_param.srvcod        = lr_param.srvcod
 let mr_param.srvnom        = lr_param.srvnom  
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc69m05[arr_aux].*, ma_retorno[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc69m05.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m05_prepare()
 end if
    
 
 
 open window w_ctc69m05 at 6,2 with form 'ctc69m05'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui'
   
  display by name mr_param.srvgrptipcod
                , mr_param.srvgrptipnom
                , mr_param.srvcod 
                , mr_param.srvnom   
  
 
  #--------------------------------------------------------
  # Recupera os Dados da Especialidade X Grupo Servico                     
  #--------------------------------------------------------
    
  open c_ctc69m05_001  using  mr_param.srvgrpcod 
  foreach c_ctc69m05_001 into ma_retorno[arr_aux].srvgrpespcod
  	                        , ma_ctc69m05[arr_aux].srvespcod
                            , ma_ctc69m05[arr_aux].srvespnom  
                            , ma_ctc69m05[arr_aux].regsitflg       

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Especialidades!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m05 without defaults from s_ctc69m05.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m05[arr_aux].srvespcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m05[arr_aux] to null
                  
         display ma_ctc69m05[arr_aux].srvespcod  to s_ctc69m05[scr_aux].srvespcod                 
         display ma_ctc69m05[arr_aux].regsitflg         to s_ctc69m05[scr_aux].regsitflg              

              
      #---------------------------------------------
       before field srvespcod
      #---------------------------------------------
        
        if ma_ctc69m05[arr_aux].srvespcod is null then                                                   
           display ma_ctc69m05[arr_aux].srvespcod to s_ctc69m05[scr_aux].srvespcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc69m05[arr_aux].* to s_ctc69m05[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then
           call ctc69m05_dados_alteracao(ma_retorno[arr_aux].srvgrpespcod) 
        end if 
      
      #---------------------------------------------
       after field srvespcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc69m05[arr_aux].srvespcod is null then
        		 
        		 #--------------------------------------------------------
        		 # Abre Popup da Especialidade                     
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup(1)
        		 returning ma_ctc69m05[arr_aux].srvespcod 
        		         , ma_ctc69m05[arr_aux].srvespnom  
        		 
        		 if ma_ctc69m05[arr_aux].srvespcod is null then 
        		    next field srvespcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera os Descricao da Especialidade                     
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao(1,ma_ctc69m05[arr_aux].srvespcod)
        		returning ma_ctc69m05[arr_aux].srvespnom   
        		
        		if ma_ctc69m05[arr_aux].srvespnom is null then      
        		   next field srvespcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida se a Especialidade Esta Cadastrada                     
          #--------------------------------------------------------
          
          open c_ctc69m05_002 using ma_ctc69m05[arr_aux].srvespcod ,           
                                    mr_param.srvgrpcod          
          whenever error continue                                                
          fetch c_ctc69m05_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Associacao ja Cadastrada!" 
             next field srvespcod 
          end if 
          
          display ma_ctc69m05[arr_aux].srvespcod to s_ctc69m05[scr_aux].srvespcod 
          display ma_ctc69m05[arr_aux].srvespnom to s_ctc69m05[scr_aux].srvespnom                                                                
                              
           
        else          
        	display ma_ctc69m05[arr_aux].* to s_ctc69m05[scr_aux].*                                                     
        end if 
        
       
      #---------------------------------------------
       before field regsitflg
      #---------------------------------------------
         
         display ma_ctc69m05[arr_aux].regsitflg to s_ctc69m05[scr_aux].regsitflg attribute(reverse)
         
         let lr_retorno.regsitflg = ma_ctc69m05[arr_aux].regsitflg
                       
     
      #---------------------------------------------
       after field regsitflg
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field srvespcod
         end if 
         
         
                
         if ma_ctc69m05[arr_aux].regsitflg is null  or 
         	  (ma_ctc69m05[arr_aux].regsitflg <> "A"  and       
         	   ma_ctc69m05[arr_aux].regsitflg <> "I") then      
         	     error "Por Favor Digite 'A' ou 'I' " 	
               next field regsitflg                
         end if 
         
         
         if ma_ctc69m05[arr_aux].regsitflg = "A" then
            	
            	#--------------------------------------------------------
            	# Ativa a Especialidade                     
            	#--------------------------------------------------------
            	
            	if not ctc69m05_ativacao(mr_param.srvgrpcod) then
            		  
            		  let ma_ctc69m05[arr_aux].regsitflg = lr_retorno.regsitflg     
            		  
            		  next field regsitflg
            	
            	end if	                        	
         end if  	
           
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m05[arr_aux].regsitflg <> lr_retorno.regsitflg then            	  
            	  
            	  #--------------------------------------------------------
            	  # Atualiza a Especialidade X Grupo Servico                     
            	  #--------------------------------------------------------
            	  
            	  call ctc69m05_altera()
            	  next field srvespcod                    	             	                                                                                                 
            end if
            
            let m_operacao = ' '             
                                   
         else
           
                              
            let lr_retorno.confirma = cts08g01("C","S","",                
                                               "DESEJA INCLUIR",          
                                               "A ESPECIALIDADE?",                
                                               "")                        
                                                                          
                                                                          
            if lr_retorno.confirma = "N" then                             
            	  next field regsitflg      	                             
            else
            	 
            	 #--------------------------------------------------------
            	 # Inclui a Especialidade X Grupo Servico                     
            	 #--------------------------------------------------------
            	 
            	 call ctc69m05_inclui()
            	 next field srvespcod
            end if	                                                       
           
           
         end if
         
           
         display ma_ctc69m05[arr_aux].srvespcod to s_ctc69m05[scr_aux].srvespcod
         display ma_ctc69m05[arr_aux].srvespnom to s_ctc69m05[scr_aux].srvespnom 
         display ma_ctc69m05[arr_aux].regsitflg to s_ctc69m05[scr_aux].regsitflg

             
      
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
       
      
          
  end input
  
 close window w_ctc69m05
 
 if lr_retorno.flag = 1 then
    call ctc69m05(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------
 function ctc69m05_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat      like isskfunc.funmat,
    empcod      like isskfunc.empcod,
    usrtipcod   like isskfunc.usrtip
 end record

 define lr_retorno  record
    funnom      like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m05_prepare()
end if
 
 initialize lr_retorno.*    to null

   if lr_param.empcod is null or 
      lr_param.empcod = " " then
      
      let lr_param.empcod = 1 
   
   end if 
 
  
   #--------------------------------------------------------
   # Recupera os Dados do Funcionario                  
   #--------------------------------------------------------
   
   open c_ctc69m05_008 using lr_param.empcod , 
                             lr_param.funmat ,                       
                             lr_param.usrtipcod
   whenever error continue                            
   fetch c_ctc69m05_008 into lr_retorno.funnom
   whenever error stop
 
 return lr_retorno.funnom

 end function
 

#---------------------------------------------------------                                                                                            
 function ctc69m05_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	srvgrpespcod like datksrvgrpesp.srvgrpespcod 
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m05.* to null                                                    
                                                                                      
   #--------------------------------------------------------                                                            
   # Recupera os Dados da Especialidade X Grupo Servico                    
   #--------------------------------------------------------
   
   open c_ctc69m05_005 using lr_param.srvgrpespcod                                                  
      
   whenever error continue                                                 
   fetch c_ctc69m05_005 into  mr_ctc69m05.empcod                                       
                             ,mr_ctc69m05.usrmatnum                                       
                             ,mr_ctc69m05.regatldat                                       
                             ,mr_ctc69m05.usrtipcod                                        
                                                                                      
   whenever error stop  
                                                                                       
   call ctc69m05_func(mr_ctc69m05.usrmatnum, mr_ctc69m05.empcod, mr_ctc69m05.usrtipcod)               
   returning mr_ctc69m05.funnom                                                  
                                                                                 
   display by name  mr_ctc69m05.regatldat                                           
                   ,mr_ctc69m05.funnom                                           
                                                                                      
end function  

#---------------------------------------------------------                                                                                                   
 function ctc69m05_altera()                                                                                                                               
#---------------------------------------------------------                           
                                                                                     
    whenever error continue                                               
    execute p_ctc69m05_003 using ma_ctc69m05[arr_aux].regsitflg        
                               , g_issk.usrtip                            
                               , g_issk.empcod                            
                               , g_issk.funmat                            
                               , 'today'                                  
                               , ma_retorno[arr_aux].srvgrpespcod      
    whenever error continue                                               
                                                                          
    if sqlca.sqlcode <> 0 then                                            
        error 'ERRO(',sqlca.sqlcode,') na Alteracao da Associacao!'       
    else                                                                  
    	  error 'Dados Alterados com Sucesso!'                               
    end if                                                                

    let m_operacao = ' '  
                                                                                   
end function


#---------------------------------------------------------                                                                           
 function ctc69m05_inclui()                                                                                                              
#---------------------------------------------------------  

    whenever error continue                                                   
    execute p_ctc69m05_004 using mr_param.srvgrpcod                      
                               , ma_ctc69m05[arr_aux].srvespcod     
                               , ma_ctc69m05[arr_aux].regsitflg            
                               , g_issk.usrtip                               
                               , g_issk.empcod                                
                               , g_issk.funmat                                
                               , 'today'                                      
                                                                              
    whenever error continue                                                   
    if sqlca.sqlcode = 0 then                                                 
       error 'Dados Incluidos com Sucesso!'                                   
       let m_operacao = ' '                                                   
    else                                                                      
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'             
    end if                                                                    

end function

#---------------------------------------------------------                                                     
 function ctc69m05_ativacao(lr_param)                                                                        
#---------------------------------------------------------                                                     
                                                                                                               
define lr_param     record                                                                                     
   srvgrpcod  like datksrvgrp.srvgrpcod                                                                                          
end record                                                                                                     
                                                                                                               
define lr_retorno  record                                                                                      
   cont    integer                                                                                                                                                                                                                                                
end record                                                                                                     
                                                                                                               
initialize lr_retorno.* to null 

let lr_retorno.cont = 0                                                                               
                                                                                                               
        #--------------------------------------------------------
        # Valida se o Grupo Servico Esta Ativo                    
        #--------------------------------------------------------
               
        open c_ctc69m05_009 using lr_param.srvgrpcod
                                                           
        whenever error continue                                                                                
        fetch c_ctc69m05_009 into  lr_retorno.cont                                                            
        whenever error stop                                                                                    
                                                                                                               
                                                                                                                                                                                                                         
        if lr_retorno.cont > 0 then                                                                             
        	 return true                                                                               
        else
        	 error "Acao Proibida, Por Favor Ative a Associacao do Servico Primeiro!"
        	 return false                                                                                                       
        end if                                                                                                  
                                                                                                                                                                                                           
                                                                                                               
end function                                                                                                   
                                                                                                               