#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m02                                                   #
# Objetivo.......: Cadastro Servico X Grupo                                   #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 13/08/2013                                                 #
#.............................................................................#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m02 array[500] of record
      srvcod      like datksrv.srvcod
    , srvnom      like datksrv.srvnom
    , regsitflg   like datksrvgrp.regsitflg 
end record
 
define mr_param   record
       srvgrptipcod   like datksrvgrptip.srvgrptipcod 
     , srvgrptipnom   like datksrvgrptip.srvgrptipnom 
end record
 
define mr_ctc69m02 record
      empcod     like datksrvgrp.empcod    
     ,usrmatnum  like datksrvgrp.usrmatnum  
     ,regatldat  like datksrvgrp.regatldat
     ,funnom     like isskfunc.funnom 
     ,usrtipcod  like datksrvgrp.usrtipcod
end record

define ma_retorno array[500] of record  
     srvgrpcod  like datksrvgrp.srvgrpcod            
end record              


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc69m02_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.srvgrpcod               '
          ,  '      , a.srvcod                  '
          ,  '      , b.srvnom                  '
          ,  '      , a.regsitflg               '
          ,  '   from datksrvgrp a,             '
          ,  '        datksrv b                 '
          ,  '  where a.srvgrptipcod = ?        '    
          ,  '  and a.srvcod = b.srvcod         '     
          ,  '  order by a.regsitflg, a.srvcod  '
 prepare p_ctc69m02_001 from l_sql
 declare c_ctc69m02_001 cursor for p_ctc69m02_001
 
 let l_sql =  ' update datksrvgrp       '
           ,  '     set regsitflg = ? , '
           ,  '         usrtipcod = ? , '
           ,  '         empcod    = ? , '
           ,  '         usrmatnum = ? , '
           ,  '         regatldat = ?   '
           ,  '   where srvgrpcod = ?   '        
 prepare p_ctc69m02_002 from l_sql
 
 
 let l_sql = '   select srvgrpcod           '        	     	
            ,'   from datksrvgrp            '        	
            ,'   where srvgrptipcod =  ?    '  
            ,'   and 	 srvcod       = ?     '
 prepare p_ctc69m02_003    from l_sql                	                                 	
 declare c_ctc69m02_003 cursor for p_ctc69m02_003  
 
 
 let l_sql = '   select count(*)      '    
           , '     from datksrvgrp    '
           , '    where srvcod  = ?   ' 
           , '    and srvgrpcod = ?   '
           , '    and regsitflg = "A" '
 prepare p_ctc69m02_004 from l_sql
 declare c_ctc69m02_004 cursor for p_ctc69m02_004
 	
 
 let l_sql = '   select empcod          '                                  	
            ,'         ,usrmatnum       '                                  	
            ,'         ,regatldat       '                                  	
            ,'         ,usrtipcod       '                              	
            ,'     from datksrvgrp      '     
            ,'    where srvgrpcod  =  ? '  
 prepare p_ctc69m02_005    from l_sql                                             	
 declare c_ctc69m02_005 cursor for p_ctc69m02_005 
 	
  
 let l_sql =  ' insert into datksrvgrp  '
           ,  '   (srvgrptipcod         '          
           ,  '   ,srvcod               '
           ,  '   ,regsitflg            '   
           ,  '   ,usrtipcod            '
           ,  '   ,empcod               '
           ,  '   ,usrmatnum            '
           ,  '   ,regatldat)           '
           ,  ' values(?,?,?,?,?,?,?)   '
 prepare p_ctc69m02_006 from l_sql
 
 
 let l_sql = ' select count(*)                 '       	         	 
           , '  from datksrvgrp a    ,         '           	 
           , '       datksrvgrpesp b           '  	       	 
           , ' where a.srvgrpcod = b.srvgrpcod ' 	 
           , '   and a.srvgrptipcod = ?        '                  
           , '   and a.srvgrpcod = ?           '       	 	     	 
 prepare p_ctc69m02_007 from l_sql               	         	 
 declare c_ctc69m02_007 cursor for p_ctc69m02_007          	 
  
 
 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m02_008 from l_sql
 declare c_ctc69m02_008 cursor for p_ctc69m02_008 
 	
 
 let l_sql = ' update datksrvgrpesp     '  	
           , '  set regsitflg = "I"     '      	
           , '  where srvgrpcod in      '    	
           , ' (select srvgrpcod        '   	 	
           , '  from datksrvgrp         '  	
           , '  where srvgrptipcod = ?  '
           , '  and   srvgrpcod = ?)    '   	
 prepare p_ctc69m02_009 from l_sql  
 
 
 let l_sql = '   select count(*)      '   
           , '    from datksrvgrp     '   
           , '    where srvcod = ?    ' 
           , '    and srvgrpcod <> ?  '            
           , '    and regsitflg = "A" '       
 prepare p_ctc69m02_010 from l_sql               
 declare c_ctc69m02_010 cursor for p_ctc69m02_010
 	
 	
 let l_sql = ' select count(*)             '       	          	
          , '  from datksrvgrptip          '           			       	  	
          , '  where srvgrptipcod  = ?     ' 		          	
          , '  and srvgrptipsitflg = "A"   '       	 	  	
 prepare p_ctc69m02_011 from l_sql               	          	
 declare c_ctc69m02_011 cursor for p_ctc69m02_011  
 	
 let l_sql = ' select count(*)         '       	 	
          , '  from datksrv            ' 	
          , '  where srvcod = ?        ' 	       	
          , '  and   srvsitflg = "A"   '    	
 prepare p_ctc69m02_012 from l_sql               	 	
 declare c_ctc69m02_012 cursor for p_ctc69m02_012  	
 	
 	      	
 let m_prepare = true


end function

#===============================================================================
 function ctc69m02(lr_param)
#===============================================================================
 
define lr_param record
    srvgrptipcod  like datksrvgrptip.srvgrptipcod, 
    srvgrptipnom  like datksrvgrptip.srvgrptipnom 
end record
 
define lr_retorno record
    flag          smallint                  ,
    cont          integer                   ,
    srvnom        like datksrv.srvnom       , 
    regsitflg     like datksrvgrp.regsitflg ,
    confirma      char(01) 
end record
 
 let mr_param.srvgrptipcod = lr_param.srvgrptipcod
 let mr_param.srvgrptipnom = lr_param.srvgrptipnom
 
 initialize mr_ctc69m02.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m02_prepare()
 end if
    
 
 
 open window w_ctc69m02 at 6,2 with form 'ctc69m02'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui, (F9)Associar Especialidade'
   
  display by name mr_param.srvgrptipcod
                , mr_param.srvgrptipnom
  
  
  #--------------------------------------------------------
  # Seleciona os Dados de Associacao do Servico X Grupo                 
  #--------------------------------------------------------
  
  open c_ctc69m02_001  using mr_param.srvgrptipcod
  foreach c_ctc69m02_001 into ma_retorno[arr_aux].srvgrpcod
  	                        , ma_ctc69m02[arr_aux].srvcod
                            , ma_ctc69m02[arr_aux].srvnom
                            , ma_ctc69m02[arr_aux].regsitflg

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Servicos!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m02 without defaults from s_ctc69m02.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m02[arr_aux].srvcod is null then
               let m_operacao = 'i'           
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m02[arr_aux] to null
                  
         display ma_ctc69m02[arr_aux].srvnom  to s_ctc69m02[scr_aux].srvnom                 
         display ma_ctc69m02[arr_aux].regsitflg to s_ctc69m02[scr_aux].regsitflg              

              
      #---------------------------------------------
       before field srvcod
      #---------------------------------------------
        
        if ma_ctc69m02[arr_aux].srvcod is null then                                                           
           display ma_ctc69m02[arr_aux].srvcod to s_ctc69m02[scr_aux].srvcod attribute(reverse)  
           let m_operacao = 'i'                                                                                            
        else                                                                                                               
          display ma_ctc69m02[arr_aux].* to s_ctc69m02[scr_aux].* attribute(reverse)                                       
        end if                                                                                                             
                                                                                                                           
                                                                                                                           
        if m_operacao <> 'i' then                                                                                          
           call ctc69m02_dados_alteracao(ma_retorno[arr_aux].srvgrpcod)                                                  
        end if                                                                                                             
                                                                                                                           
      #---------------------------------------------
       after field srvcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc69m02[arr_aux].srvcod is null then
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup de Servico                  
        		 #--------------------------------------------------------
        		
        		 call ctc69m04_popup(4)
        		 returning ma_ctc69m02[arr_aux].srvcod 
        		         , ma_ctc69m02[arr_aux].srvnom  
        		 
        		 if ma_ctc69m02[arr_aux].srvcod is null then 
        		    next field srvcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera o Nome do Servico                  
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao(4,ma_ctc69m02[arr_aux].srvcod)
        		returning ma_ctc69m02[arr_aux].srvnom   
        		
        		if ma_ctc69m02[arr_aux].srvnom is null then      
        		   next field srvcod                             
        		end if                                                        
        		
          end if 
          
          #--------------------------------------------------------
          # Valida se o Servico Ja Foi Cadastrado                 
          #--------------------------------------------------------
          
          open c_ctc69m02_004 using ma_ctc69m02[arr_aux].srvcod,
                                    ma_retorno[arr_aux].srvgrpcod                                                      
          whenever error continue                                                
          fetch c_ctc69m02_004 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Servico ja Cadastrado!" 
             next field srvcod 
          end if 
          
          display ma_ctc69m02[arr_aux].srvcod to s_ctc69m02[scr_aux].srvcod 
          display ma_ctc69m02[arr_aux].srvnom to s_ctc69m02[scr_aux].srvnom                                                                
                              
           
        else          
        	display ma_ctc69m02[arr_aux].* to s_ctc69m02[scr_aux].*                                                     
        end if
        
         
      #---------------------------------------------
       before field regsitflg
      #---------------------------------------------
       
         display ma_ctc69m02[arr_aux].regsitflg to s_ctc69m02[scr_aux].regsitflg attribute(reverse)  
         let lr_retorno.regsitflg = ma_ctc69m02[arr_aux].regsitflg
         
                               
     
      #---------------------------------------------
       after field regsitflg
      #---------------------------------------------
         
          if m_operacao = 'i' then         
              if fgl_lastkey() = fgl_keyval ("up")     or           
                 fgl_lastkey() = fgl_keyval ("left")   then 
                    next field srvnom          
              end if                
          end if                              
        
       
         if ma_ctc69m02[arr_aux].regsitflg is null  or 
         	  (ma_ctc69m02[arr_aux].regsitflg <> "A"  and       
         	   ma_ctc69m02[arr_aux].regsitflg <> "I") then      
         	     error "Por Favor Digite 'A' ou 'I' " 	
               next field regsitflg                
         end if                                       
         
         
         if ma_ctc69m02[arr_aux].regsitflg = "A" then
         	 
         	 #--------------------------------------------------------
         	 # Valida Se o Servico Esta Ativo em Outro Grupo                
         	 #--------------------------------------------------------
         	 
         	 if not ctc69m02_valida() then
         	 	  next field regsitflg
         	 end if	          
         end if
         
        
         if ma_ctc69m02[arr_aux].regsitflg = "A" then
            	
            	#--------------------------------------------------------
            	# Ativa o Servico X Grupo                 
            	#--------------------------------------------------------
            	
            	if not ctc69m02_ativacao(mr_param.srvgrptipcod           ,
            		                       ma_ctc69m02[arr_aux].srvcod) then
            		  
            		  let ma_ctc69m02[arr_aux].regsitflg = lr_retorno.regsitflg     
            		  
            		  next field regsitflg
            	
            	end if	                        	
         end if  	
         
                 
         if m_operacao <> 'i' then 
                              
            if ma_ctc69m02[arr_aux].regsitflg <> lr_retorno.regsitflg then 
            	   
            	   if ma_ctc69m02[arr_aux].regsitflg = "I" then
            	       
            	       #--------------------------------------------------------
            	       # Inativa o Servico X Grupo               
            	       #--------------------------------------------------------
            	       
            	       if not ctc69m02_inativacao(mr_param.srvgrptipcod,
            	                                  ma_retorno[arr_aux].srvgrpcod) then
            	          next field srvcod
            	       end if                              	
            	   end if
            	   
            	   #--------------------------------------------------------
            	   # Atualiza o Servico X Grupo             
            	   #--------------------------------------------------------
            	            	   
            	   call ctc69m02_altera()
            	   next field srvcod 
            end if
            
            let m_operacao = ' '  
                             
         else
           
              let lr_retorno.confirma = cts08g01("C","S","",      
                                                 "DESEJA INCLUIR",
                                                 "O SERVICO?",  
                                                 "")              
                                                                  
              if lr_retorno.confirma = "N" then                   
              	  next field regsitflg      
              else
              	 
              	 #--------------------------------------------------------
              	 # Inclui o Servico X Grupo                 
              	 #--------------------------------------------------------
              	 
              	 call ctc69m02_inclui() 
              	 
              	 #--------------------------------------------------------
              	 # Recupera a Chave Serial do Servico X Grupo                   
              	 #--------------------------------------------------------
              	 
              	 call ctc69m02_recupera_chave()  
              	 
              	 next field srvcod            	  
              end if	                           
                    
         end if
         
           
         display ma_ctc69m02[arr_aux].srvcod    to s_ctc69m02[scr_aux].srvcod
         display ma_ctc69m02[arr_aux].srvnom    to s_ctc69m02[scr_aux].srvnom  
         display ma_ctc69m02[arr_aux].regsitflg to s_ctc69m02[scr_aux].regsitflg

             
      
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
       
        
        #--------------------------------------------- 
         on key (F9)                                   
        #--------------------------------------------- 
            
            if ma_ctc69m02[arr_aux].srvcod is not null then         
                      
                call ctc69m05(ma_retorno[arr_aux].srvgrpcod ,
                              mr_param.srvgrptipcod         ,
                              mr_param.srvgrptipnom         ,
                              ma_ctc69m02[arr_aux].srvcod   ,
                              ma_ctc69m02[arr_aux].srvnom   )     
           
           end if  
  end input
  
 close window w_ctc69m02
 
 if lr_retorno.flag = 1 then
    call ctc69m02(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------
 function ctc69m02_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno  record
    funnom    like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m02_prepare()
end if
 
 initialize lr_retorno.*    to null

   if lr_param.empcod is null or 
      lr_param.empcod = " " then
      
      let lr_param.empcod = 1 
   
   end if 
 
   #--------------------------------------------------------
   # Recupera o Nome do Funcionario                  
   #--------------------------------------------------------
   
   open c_ctc69m02_008 using lr_param.empcod , 
                             lr_param.funmat ,                       
                             lr_param.usrtipcod
   whenever error continue                            
   fetch c_ctc69m02_008 into lr_retorno.funnom
   whenever error stop
 
 return lr_retorno.funnom

 end function
 

#---------------------------------------------------------                                                                                            
 function ctc69m02_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	srvgrpcod like datksrvgrp.srvgrpcod
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m02.* to null                                                    
                                                                                      
   #--------------------------------------------------------                                                            
   # Recupera os Dados do Servico X Grupo                 
   #--------------------------------------------------------
     
   open c_ctc69m02_005 using lr_param.srvgrpcod                                                   
      
   whenever error continue                                                 
   fetch c_ctc69m02_005 into  mr_ctc69m02.empcod                                       
                             ,mr_ctc69m02.usrmatnum                                       
                             ,mr_ctc69m02.regatldat                                       
                             ,mr_ctc69m02.usrtipcod
                                                                         
                                                                                      
   whenever error stop  
                                                                                                  
   call ctc69m02_func(mr_ctc69m02.usrmatnum, mr_ctc69m02.empcod, mr_ctc69m02.usrtipcod)               
   returning mr_ctc69m02.funnom                                                  
                                                                                 
   display by name  mr_ctc69m02.regatldat                                           
                   ,mr_ctc69m02.funnom                                           
                                                                                      
end function      

#---------------------------------------------------------                                                                                            
 function ctc69m02_altera()                                             
#---------------------------------------------------------                                       

     whenever error continue 
     execute p_ctc69m02_002 using ma_ctc69m02[arr_aux].regsitflg
                                , g_issk.usrtip        
                                , g_issk.empcod 
                                , g_issk.funmat         
                                , 'today'                                                  
                                , ma_retorno[arr_aux].srvgrpcod 
     whenever error continue 
     
     if sqlca.sqlcode <> 0 then
         error 'ERRO(',sqlca.sqlcode,') na Alteracao do Servico!'       
     else
     	  error 'Dados Alterados com Sucesso!' 
     end if 
     
     let m_operacao = ' '             
                                                                                      
end function

#---------------------------------------------------------                                                                                            
 function ctc69m02_inclui()                                             
#---------------------------------------------------------                                       

      whenever error continue                                         
      execute p_ctc69m02_006 using mr_param.srvgrptipcod               
                                 , ma_ctc69m02[arr_aux].srvcod 
                                 , ma_ctc69m02[arr_aux].regsitflg       
                                 , g_issk.usrtip                     
                                 , g_issk.empcod                      
                                 , g_issk.funmat                      
                                 , 'today'                            
                                                                              
      whenever error continue                                         
      if sqlca.sqlcode = 0 then                                       
         error 'Dados Incluidos com Sucesso!'                         
                                                                      
         let m_operacao = ' '                                         
                                                                      
      else                                                            
         error 'ERRO(',sqlca.sqlcode,') na Insercao do Servico!'      
      end if                                                          
                                                                                                                                                            
end function   
                                                                       
#---------------------------------------------------------                
 function ctc69m02_recupera_chave()                                       
#---------------------------------------------------------                
                                                                          
    open c_ctc69m02_003 using mr_param.srvgrptipcod,                  
                              ma_ctc69m02[arr_aux].srvcod    
    whenever error continue                                               
    fetch c_ctc69m02_003 into  ma_retorno[arr_aux].srvgrpcod           
    whenever error stop                                                   
                                                                          
                                                                          
end function  

#---------------------------------------------------------                                                                                                 
 function ctc69m02_inativacao(lr_param)                                                                                                                                                                           
#---------------------------------------------------------                                                                                                                  
                                                                                      
define lr_param     record                                                            
   srvgrptipcod  like datksrvgrptip.srvgrptipcod ,
   srvgrpcod     like datksrvgrp.srvgrpcod                                                           
end record                                                                            
                                                                                      
define lr_retorno  record                                                             
   cont1    integer ,                                                                                                                                  
   confirma char(01),                                                                 
   msg1     char(40),                                                                 
   msg2     char(40),                                                                 
   msg3     char(40),                                                                 
   msg4     char(40)                                                                   
end record                                                                            
                                                                                      
initialize lr_retorno.* to null                                                       
                                                                                      
                                                                                                                                     
        open c_ctc69m02_007 using lr_param.srvgrptipcod,
                                  lr_param.srvgrpcod                                
        whenever error continue                                                       
        fetch c_ctc69m02_007 into  lr_retorno.cont1                                   
        whenever error stop                                                           
                                                                                      
        if lr_retorno.cont1 > 0 then                                                  
                                                                                      
           let lr_retorno.msg1 = "SERA INATIVADO "                                    
           let lr_retorno.msg2 = lr_retorno.cont1 using '<<<<' ," ESPECIALIDADES "              
           let lr_retorno.msg3 = "CONFIRMA? "                                         
                                                                                      
           let lr_retorno.confirma = cts08g01("C","S",                                
                                              lr_retorno.msg1,                        
                                              lr_retorno.msg2,                        
                                              lr_retorno.msg3,                        
                                              lr_retorno.msg4)                        
                                                                                      
           if lr_retorno.confirma = "S" then                                          
           	  call ctc69m02_atualiza_inativacao(lr_param.srvgrptipcod,
           	                                    lr_param.srvgrpcod)          	      
           else 
           	  return false
           end if	                                                                    
                                                                                      
       end if 
       
       return true                                                                        
                                                                                      
end function 

#---------------------------------------------------------                                                                                                      
 function ctc69m02_atualiza_inativacao(lr_param)                                       
#---------------------------------------------------------                             
                                                                                       
define lr_param record                                                             
   srvgrptipcod     like datksrvgrptip.srvgrptipcod ,
   srvgrpcod        like datksrvgrp.srvgrpcod                                                   
end record                                                                             
                                                                                       
 begin work                                                                            
                                                                                       
                                                                                       
 whenever error continue                                                               
 execute p_ctc69m02_009 using  lr_param.srvgrptipcod,
                               lr_param.srvgrpcod                                    
 whenever error stop                                                                   
                                                                                       
 if sqlca.sqlcode <>  0  then                                                          
    error " Erro (",sqlca.sqlcode,") na Alteracao da Situacao das Especialidades!"           
    rollback work                                                                      
    return                                                                             
 end if                                                                                
                                                                                       
                                                                                       
 error "Dados Inativados com Sucesso!"                                                 
 commit work                                                                           
                                                                                       
end function  

#---------------------------------------------------------                                                                                              
 function ctc69m02_valida()                                            
#---------------------------------------------------------                     
                                                                               
define lr_retorno     record   
   cont integer  
end record

let lr_retorno.cont = 0                       
    
     open c_ctc69m02_010 using ma_ctc69m02[arr_aux].srvcod,   
                               ma_retorno[arr_aux].srvgrpcod    
     whenever error continue                                         
     fetch c_ctc69m02_010 into lr_retorno.cont                       
     whenever error stop                                             
                                                                     
     if lr_retorno.cont >  0   then                                  
        error " Servico ja Cadastrado em Outro Grupo!"                              
        return false                                                
     end if                                                                      
                
     
     return true           
                
                                                                                                                                                           
end function   

#---------------------------------------------------------                                                                                                 
 function ctc69m02_ativacao(lr_param)                                                      
#---------------------------------------------------------                                 
                                                                                           
define lr_param     record                                                                                                                   
   srvgrptipcod  like datksrvgrptip.srvgrptipcod   ,
   srvcod        like datksrv.srvcod                                                            
end record                                                                                 
                                                                                           
define lr_retorno  record                                                                  
   cont1    integer ,
   cont2    integer                                                                        
end record                                                                                 
                                                                                           
initialize lr_retorno.* to null                                                            
                                                                                           
let lr_retorno.cont1 = 0  
let lr_retorno.cont2 = 0                                                                   
                                                                                           
        
        
        #--------------------------------------------------------
        # Valida Se o Grupo Esta Ativo                 
        #--------------------------------------------------------
                
          
        open c_ctc69m02_011 using lr_param.srvgrptipcod                                                                                             
        whenever error continue                                                            
        fetch c_ctc69m02_011 into  lr_retorno.cont1                                         
        whenever error stop                                                                
                                                                                           
                                                                                           
        if lr_retorno.cont1 = 0 then                                                                                                                                   
        	 error "Acao Proibida, Por Favor Ative o Grupo do Servico Primeiro!"        
        	 return false                                                                    
        end if
        
        
        #--------------------------------------------------------
        # Valida Se o Servico Esta Ativo                           
        #--------------------------------------------------------
        
        open c_ctc69m02_012 using lr_param.srvcod    
                                                                                                                             
        whenever error continue                                                            
        fetch c_ctc69m02_012 into  lr_retorno.cont2                                         
        whenever error stop                                                                
                                                                                           
                                                                                           
        if lr_retorno.cont2 > 0 then                                                        
        	 return true                                                                     
        else                                                                               
        	 error "Acao Proibida, Por Favor Ative o Servico Primeiro!"        
        	 return false                                                                    
        end if                        
        
                                                                                                 
end function                                                                               
                                                                                           