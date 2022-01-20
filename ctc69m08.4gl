#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Regras Siebel                                              # 
# Modulo.........: ctc69m08                                                   # 
# Objetivo.......: Cadastro Servico X Clausula/Plano X Especialidade          # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 21/08/2013                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m08 array[500] of record
      srvespcod               like datkclssrvesp.srvespcod
    , srvespnom               like datksrvesp.srvespnom
    , clssrvesplimvlr         like datkclssrvesp.clssrvesplimvlr
    , codlim                  smallint
    , clssrvesplimundnom      like datkclssrvesp.clssrvesplimundnom 
    , undsrvcusvlr            like datkclssrvesp.undsrvcusvlr
    , codcus                  smallint 
    , undsrvcusundnom         like datkclssrvesp.undsrvcusundnom
    , clssrvespcod            like datkclssrvesp.clssrvespcod 
end record
 
define mr_param   record
       srvplnclscod    like datkclssrvesp.srvplnclscod
     , clscod          like datkplncls.clscod
     , clsnom          char(60)    
     , srvcod          like datksrv.srvcod   
     , srvnom          like datksrv.srvnom 
     , srvgrpcod       like datksrvplncls.srvcod
end record
 
define mr_ctc69m08 record
      empcod           like datkclssrvesp.empcod      
     ,usrmatnum        like datkclssrvesp.usrmatnum   
     ,regatldat        like datkclssrvesp.regatldat
     ,funnom           like isskfunc.funnom 
     ,usrtipcod        like datkclssrvesp.usrtipcod 
end record

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc69m08_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select a.clssrvespcod                  '
          ,  '      , a.srvespcod                     '
          ,  '      , b.srvespnom                     '
          ,  '      , a.clssrvesplimvlr               '
          ,  '      , c.cpocod                        '
          ,  '      , a.clssrvesplimundnom            ' 
          ,  '      , a.undsrvcusvlr                  ' 
          ,  '      , d.cpocod                        ' 
          ,  '      , a.undsrvcusundnom               ' 
          ,  '   from datkclssrvesp a,                '  
          ,  '        datksrvesp  b,                  '  
          ,  '        datkdominio c,                  '
          ,  '        datkdominio d                   '  
          ,  '  where a.srvespcod = b.srvespnum       '         
          ,  '  and   a.clssrvesplimundnom = c.cpodes ' 
          ,  '  and   a.undsrvcusundnom    = d.cpodes '    
          ,  '  and   a.srvplnclscod = ?              '
          ,  '  and   c.cponom = "unid_siebel"        ' 
          ,  '  and   d.cponom = "unid_siebel"        ' 
          ,  '  order by  a.srvespcod                 '
 prepare p_ctc69m08_001 from l_sql
 declare c_ctc69m08_001 cursor for p_ctc69m08_001
 	
 let l_sql = ' select count(*)         '
          ,  ' from datkclssrvesp      ' 
          ,  ' where srvespcod = ?     '         
          ,  ' and  srvplnclscod = ?   '
 prepare p_ctc69m08_002 from l_sql
 declare c_ctc69m08_002 cursor for p_ctc69m08_002
       
 let l_sql = '  update datkclssrvesp             '
           ,  '     set clssrvesplimvlr    = ? , '  
           ,  '         clssrvesplimundnom = ? , ' 
           ,  '         undsrvcusvlr       = ? , '
           ,  '         undsrvcusundnom    = ? , '               
           ,  '         usrtipcod          = ? , '                      
           ,  '         empcod             = ? , '                      
           ,  '         usrmatnum          = ? , '
           ,  '         regatldat          = ?   '
           ,  '   where clssrvespcod       = ? '        
 prepare p_ctc69m08_003 from l_sql
  
 let l_sql =  ' insert into datkclssrvesp   '
           ,  '   (srvplnclscod             '          
           ,  '   ,srvespcod                '
           ,  '   ,clssrvesplimvlr          '
           ,  '   ,clssrvesplimundnom       '
           ,  '   ,undsrvcusvlr             '   
           ,  '   ,undsrvcusundnom          '    
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?,?,?,?,?) '
 prepare p_ctc69m08_004 from l_sql 	
  
 
 let l_sql = '   select empcod                '                                  	
            ,'         ,usrmatnum             '                                  	
            ,'         ,regatldat             '                                  	
            ,'         ,usrtipcod             '                            	
            ,'     from datkclssrvesp         '     
            ,'    where clssrvespcod     =  ? '  
 prepare p_ctc69m08_005    from l_sql                                             	
 declare c_ctc69m08_005 cursor for p_ctc69m08_005
 	
 
 let l_sql = '   select clssrvespcod       '        	     	
            ,'   from datkclssrvesp        '        	
            ,'   where srvplnclscod  = ?   '  
            ,'   and 	 srvespcod     = ?   '
 prepare p_ctc69m08_006    from l_sql                	                                 	
 declare c_ctc69m08_006 cursor for p_ctc69m08_006  
 	
 
 let l_sql = '   delete datkclssrvesp      '        	     	
            ,'   where clssrvespcod   =  ? '  
 prepare p_ctc69m08_007    from l_sql                	                                 	 
 	
 
 let l_sql =  '    select funnom       '
             ,'      from isskfunc     '
             ,'     where empcod = ?   '
             ,'       and funmat = ?   '
             ,'       and usrtip = ?   '
 prepare p_ctc69m08_008 from l_sql
 declare c_ctc69m08_008 cursor for p_ctc69m08_008
 
 
 let m_prepare = true


end function

#===============================================================================
 function ctc69m08(lr_param)
#===============================================================================
 
define lr_param record
    srvplnclscod  like datkclssrvesp.srvplnclscod,  
    clscod        like datkplncls.clscod         ,  
    clsnom        char(60)                       ,  
    srvcod        like datksrv.srvcod            ,
    srvnom        like datksrv.srvnom            ,
    srvgrpcod     like datksrvplncls.srvcod     
end record
 
define lr_retorno record
    flag                smallint                           ,
    cont                integer                            ,
    srvespnom           like datksrvesp.srvespnom          ,
    clssrvesplimvlr     like datkclssrvesp.clssrvesplimvlr ,
    codlim              smallint                           , 
    undsrvcusvlr        like datkclssrvesp.undsrvcusvlr    ,
    codcus              smallint                           , 
    undsrvcusundnom     like datkclssrvesp.undsrvcusundnom ,
    confirma            char(01) 
end record
 
 let mr_param.srvplnclscod  = lr_param.srvplnclscod
 let mr_param.clscod        = lr_param.clscod
 let mr_param.clsnom        = lr_param.clsnom  
 let mr_param.srvcod        = lr_param.srvcod   
 let mr_param.srvnom        = lr_param.srvnom    
 let mr_param.srvgrpcod     = lr_param.srvgrpcod
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc69m08[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc69m08.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m08_prepare()
 end if
    
 
 
 open window w_ctc69m08 at 6,2 with form 'ctc69m08'
 attribute(form line 1)
  
 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui'
   
  display by name mr_param.clscod 
                , mr_param.clsnom
                , mr_param.srvcod
                , mr_param.srvnom     
  
 
  #--------------------------------------------------------
  # Recupera os Dados da Especialidade X Clausula                    
  #--------------------------------------------------------
  
  
  open c_ctc69m08_001  using  mr_param.srvplnclscod 
  foreach c_ctc69m08_001 into ma_ctc69m08[arr_aux].clssrvespcod
  	                        , ma_ctc69m08[arr_aux].srvespcod
                            , ma_ctc69m08[arr_aux].srvespnom 
                            , ma_ctc69m08[arr_aux].clssrvesplimvlr
                            , ma_ctc69m08[arr_aux].codlim
                            , ma_ctc69m08[arr_aux].clssrvesplimundnom  
                            , ma_ctc69m08[arr_aux].undsrvcusvlr  
                            , ma_ctc69m08[arr_aux].codcus  
                            , ma_ctc69m08[arr_aux].undsrvcusundnom          
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontradas Mais de 500 Especialidades!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m08 without defaults from s_ctc69m08.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m08[arr_aux].srvespcod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m08[arr_aux] to null
                  
         display ma_ctc69m08[arr_aux].srvespcod           to s_ctc69m08[scr_aux].srvespcod 
         display ma_ctc69m08[arr_aux].clssrvesplimvlr     to s_ctc69m08[scr_aux].clssrvesplimvlr 
         display ma_ctc69m08[arr_aux].codlim              to s_ctc69m08[scr_aux].codlim 
         display ma_ctc69m08[arr_aux].clssrvesplimundnom  to s_ctc69m08[scr_aux].clssrvesplimundnom   
         display ma_ctc69m08[arr_aux].undsrvcusvlr        to s_ctc69m08[scr_aux].undsrvcusvlr  
         display ma_ctc69m08[arr_aux].codcus              to s_ctc69m08[scr_aux].codcus  
         display ma_ctc69m08[arr_aux].undsrvcusundnom     to s_ctc69m08[scr_aux].undsrvcusundnom                                     

              
      #---------------------------------------------
       before field srvespcod
      #---------------------------------------------
        
        if ma_ctc69m08[arr_aux].srvespcod is null then                                                   
           display ma_ctc69m08[arr_aux].srvespcod to s_ctc69m08[scr_aux].srvespcod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc69m08[arr_aux].* to s_ctc69m08[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m08[scr_aux].clssrvespcod                            
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then
           call ctc69m08_dados_alteracao(ma_ctc69m08[arr_aux].clssrvespcod) 
        end if 
      
      #---------------------------------------------
       after field srvespcod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc69m08[arr_aux].srvespcod is null then
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup da Especialidade                    
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup_2(8,mr_param.srvgrpcod)
        		 returning ma_ctc69m08[arr_aux].srvespcod 
        		         , ma_ctc69m08[arr_aux].srvespnom  
        		 
        		 if ma_ctc69m08[arr_aux].srvespcod is null then 
        		    next field srvespcod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao da Especialidade                
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao_2(8,mr_param.srvgrpcod,
        		                                   ma_ctc69m08[arr_aux].srvespcod)
        		returning ma_ctc69m08[arr_aux].srvespnom   
        		
        		if ma_ctc69m08[arr_aux].srvespnom is null then      
        		   next field srvespcod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida se a Especialidade Ja Foi Criada                    
          #--------------------------------------------------------
          
          open c_ctc69m08_002 using ma_ctc69m08[arr_aux].srvespcod ,           
                                    mr_param.srvplnclscod          
          whenever error continue                                                
          fetch c_ctc69m08_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Associacao ja Cadastrada!" 
             next field srvespcod 
          end if 
          
          display ma_ctc69m08[arr_aux].srvespcod to s_ctc69m08[scr_aux].srvespcod 
          display ma_ctc69m08[arr_aux].srvespnom to s_ctc69m08[scr_aux].srvespnom                                                                
                              
           
        else          
        	display ma_ctc69m08[arr_aux].* to s_ctc69m08[scr_aux].*                                                     
        end if
        
     #---------------------------------------------
      before field clssrvesplimvlr 
     #---------------------------------------------                                         
         display ma_ctc69m08[arr_aux].clssrvesplimvlr  to s_ctc69m08[scr_aux].clssrvesplimvlr  attribute(reverse)
         let lr_retorno.clssrvesplimvlr = ma_ctc69m08[arr_aux].clssrvesplimvlr 
                                                                  
     #--------------------------------------------- 
      after  field clssrvesplimvlr                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field srvespcod                                    
         end if                                                     
                                                                    
         if ma_ctc69m08[arr_aux].clssrvesplimvlr    is null   then                    
            error "Por Favor Informe o Limite por Evento!"           
            next field clssrvesplimvlr                                         
         end if 
         
     #---------------------------------------------                                             
      before field codlim                                                                       
     #---------------------------------------------                                             
         display ma_ctc69m08[arr_aux].codlim   to s_ctc69m08[scr_aux].codlim   attribute(reverse) 
         let lr_retorno.codlim = ma_ctc69m08[arr_aux].codlim   
                                                                                              
     #---------------------------------------------                                                 
      after  field codlim                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field clssrvesplimvlr                                                             
         end if 
         
         if ma_ctc69m08[arr_aux].codlim is null then                          
         	                                                                           
         	 #--------------------------------------------------------
         	 # Abre o Popup do Limite                  
         	 #--------------------------------------------------------
         	 
         	 call ctc69m04_popup(5)                                                    
         	 returning ma_ctc69m08[arr_aux].codlim                              
         	         , ma_ctc69m08[arr_aux].clssrvesplimundnom                                
         	                                                                           
         	 if ma_ctc69m08[arr_aux].codlim is null then                        
         	    next field codlim                                               
         	 end if                                                                    
         else                                                                        
         	
         	#-------------------------------------------------------- 
         	# Recupera a Descricao do Limite                                  
         	#-------------------------------------------------------- 
         	        	
         	call ctc69m04_recupera_descricao(5,ma_ctc69m08[arr_aux].codlim)     
         	returning ma_ctc69m08[arr_aux].clssrvesplimundnom                                 
         	                                                                                                                                                               
         	if ma_ctc69m08[arr_aux].clssrvesplimundnom is null then                                                                                                                      
         	   next field codlim                                                                                          
         	end if                                                                                                               
         	                                                                                                                      
         end if   
         
         display ma_ctc69m08[arr_aux].codlim to s_ctc69m08[scr_aux].codlim                                                                                                             
         display ma_ctc69m08[arr_aux].clssrvesplimundnom to s_ctc69m08[scr_aux].clssrvesplimundnom                                                    
       
      
     #--------------------------------------------- 
      after  field undsrvcusvlr                                           
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field codlim                                  
         end if                                                     
                                                                    
         if ma_ctc69m08[arr_aux].undsrvcusvlr   is null   then                    
            error "Por Favor Informe o Valor do undsrvcusvlrUnitario!"           
            next field undsrvcusvlr                                        
         end if 
         
     #---------------------------------------------                                             
      before field undsrvcusvlr                                                                     
     #---------------------------------------------                                             
         display ma_ctc69m08[arr_aux].undsrvcusvlr  to s_ctc69m08[scr_aux].undsrvcusvlr attribute(reverse) 
         let lr_retorno.undsrvcusvlr= ma_ctc69m08[arr_aux].undsrvcusvlr  
                                                                                              
     #---------------------------------------------                                                 
      after  field codcus                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field undsrvcusvlr                                                          
         end if 
         
         if ma_ctc69m08[arr_aux].codcus  is null then                          
         	                                                                           
         	 #-------------------------------------------------------- 
         	 # Abre o Popup do Limite                                  
         	 #--------------------------------------------------------         	 
         	 
         	 call ctc69m04_popup(5)                                                    
         	 returning ma_ctc69m08[arr_aux].codcus                             
         	         , ma_ctc69m08[arr_aux].undsrvcusundnom                                
         	                                                                           
         	 if ma_ctc69m08[arr_aux].codcus is null then                        
         	    next field codcus                                              
         	 end if                                                                    
         else                                                                        
         	
         	#-------------------------------------------------------- 
         	# Recupera a Descricao do Limite                                  
         	#-------------------------------------------------------- 
         	
         	call ctc69m04_recupera_descricao(5,ma_ctc69m08[arr_aux].codcus)     
         	returning ma_ctc69m08[arr_aux].undsrvcusundnom                                 
         	                                                                                                                                                               
         	if ma_ctc69m08[arr_aux].undsrvcusundnom is null then                                                                                                                      
         	   next field codlim                                                                                          
         	end if                                                                                                               
         	                                                                                                                      
         end if   
         
         display ma_ctc69m08[arr_aux].codcus          to s_ctc69m08[scr_aux].codcus                                                                                                             
         display ma_ctc69m08[arr_aux].undsrvcusundnom to s_ctc69m08[scr_aux].undsrvcusundnom  
          
                  
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m08[arr_aux].clssrvesplimvlr  <> lr_retorno.clssrvesplimvlr  or
               ma_ctc69m08[arr_aux].codlim           <> lr_retorno.codlim           or
               ma_ctc69m08[arr_aux].undsrvcusvlr     <> lr_retorno.undsrvcusvlr     or 
            	 ma_ctc69m08[arr_aux].codcus           <> lr_retorno.codcus           or
               ma_ctc69m08[arr_aux].undsrvcusundnom  <> lr_retorno.undsrvcusundnom  then 	             	
               	 
               	 #--------------------------------------------------------
               	 # Atualiza a Especialidade X Clausula                         
               	 #--------------------------------------------------------
               	 
               	 call ctc69m08_altera()
               	 next field srvespcod            	                                                                                                                    
            end if
                       
            let m_operacao = ' '                           
         else
            
            #--------------------------------------------------------  
            # Inclui a Especialidade X Clausula                      
            #--------------------------------------------------------              
            call ctc69m08_inclui()
            
            #--------------------------------------------------------  
            # Recupera a Serial da Especialidade X Clausula                      
            #--------------------------------------------------------  
            call ctc69m08_recupera_chave() 
            
            next field srvespcod                             
         end if
         
           
         display ma_ctc69m08[arr_aux].srvespcod            to s_ctc69m08[scr_aux].srvespcod
         display ma_ctc69m08[arr_aux].srvespnom            to s_ctc69m08[scr_aux].srvespnom 
         display ma_ctc69m08[arr_aux].clssrvesplimvlr      to s_ctc69m08[scr_aux].clssrvesplimvlr
         display ma_ctc69m08[arr_aux].codlim               to s_ctc69m08[scr_aux].codlim
         display ma_ctc69m08[arr_aux].clssrvesplimundnom   to s_ctc69m08[scr_aux].clssrvesplimundnom 
         display ma_ctc69m08[arr_aux].undsrvcusvlr         to s_ctc69m08[scr_aux].undsrvcusvlr  
         display ma_ctc69m08[arr_aux].codcus               to s_ctc69m08[scr_aux].codcus  
         display ma_ctc69m08[arr_aux].undsrvcusundnom      to s_ctc69m08[scr_aux].undsrvcusundnom         

             
      
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                           	
       before delete                                                           	
      #---------------------------------------------                           	
         if ma_ctc69m08[arr_aux].clssrvespcod  is null   then                    	
            continue input                                                     	
         else                                                                  	
            
             #-----------------------------------------------------------------  
             # Valida Se Associacao Especialidade X Clausula Pode Ser Excluida                      
             #-----------------------------------------------------------------  
            
            if ctc69m06_valida_exclusao() then   
               
               
                #--------------------------------------------------------  
                # Exclui a Especialidade X Clausula                      
                #--------------------------------------------------------  
               
               if not ctc69m08_delete(ma_ctc69m08[arr_aux].clssrvespcod) then       	
                   let lr_retorno.flag = 1                                        	
                   exit input                                                     	
               end if                                                             	
            else
            	 let lr_retorno.flag = 1 
            	 exit input              
            end if                                                                   	
            
            next field srvespcod                                          	
                                                                   	           	
         end if                                                              
      
          
  end input
  
 close window w_ctc69m08
 
 if lr_retorno.flag = 1 then
    call ctc69m08(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------
 function ctc69m08_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno  record
    funnom            like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m08_prepare()
end if
 
 initialize lr_retorno.*    to null

   if lr_param.empcod is null or 
      lr_param.empcod = " " then
      
      let lr_param.empcod = 1 
   
   end if 
 
  
   #--------------------------------------------------------  
   # Recupera os Dados do Funcionario                      
   #--------------------------------------------------------  
   
   open c_ctc69m08_008 using lr_param.empcod , 
                             lr_param.funmat ,                       
                             lr_param.usrtipcod
   whenever error continue                            
   fetch c_ctc69m08_008 into lr_retorno.funnom
   whenever error stop
 
 return lr_retorno.funnom

 end function
 

#---------------------------------------------------------                                                                                            
 function ctc69m08_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	clssrvespcod integer
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m08.* to null                                                    
                                                                                      
                                                               
   open c_ctc69m08_005 using lr_param.clssrvespcod                                                 
      
   whenever error continue                                                 
   fetch c_ctc69m08_005 into  mr_ctc69m08.empcod                                       
                             ,mr_ctc69m08.usrmatnum                                       
                             ,mr_ctc69m08.regatldat                                       
                             ,mr_ctc69m08.usrtipcod                                        
                                                                                      
   whenever error stop  
      
                                                                                                   
   call ctc69m08_func(mr_ctc69m08.usrmatnum, mr_ctc69m08.empcod, mr_ctc69m08.usrtipcod)               
   returning mr_ctc69m08.funnom                                                  
                                                                                 
   display by name  mr_ctc69m08.regatldat                                           
                   ,mr_ctc69m08.funnom                                           
                                                                                      
end function

#---------------------------------------------------------                                                                                                      
 function ctc69m08_altera()                                                                                                                                
#---------------------------------------------------------                            
                                                                                                                                                                                                                                                   
   whenever error continue 
   execute p_ctc69m08_003 using ma_ctc69m08[arr_aux].clssrvesplimvlr
                              , ma_ctc69m08[arr_aux].clssrvesplimundnom
                              , ma_ctc69m08[arr_aux].undsrvcusvlr
                              , ma_ctc69m08[arr_aux].undsrvcusundnom
                              , g_issk.usrtip         
                              , g_issk.empcod 
                              , g_issk.funmat         
                              , 'today'                                                  
                              , ma_ctc69m08[arr_aux].clssrvespcod
   whenever error continue 
   
   if sqlca.sqlcode <> 0 then
       error 'ERRO(',sqlca.sqlcode,') na Alteracao da Associacao!'       
   else
   	  error 'Dados Alterados com Sucesso!' 
   end if                                                                                    
   
   let m_operacao = ' '                                
                                                                                      
end function 

#---------------------------------------------------------                                                                                                     
 function ctc69m08_inclui()                                          
#---------------------------------------------------------                            
                                                                                      
   whenever error continue
   execute p_ctc69m08_004 using mr_param.srvplnclscod  
                              , ma_ctc69m08[arr_aux].srvespcod
                              , ma_ctc69m08[arr_aux].clssrvesplimvlr
                              , ma_ctc69m08[arr_aux].clssrvesplimundnom
                              , ma_ctc69m08[arr_aux].undsrvcusvlr
                              , ma_ctc69m08[arr_aux].undsrvcusundnom
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
 function ctc69m08_recupera_chave()                               
#---------------------------------------------------------        
                                                                  
    open c_ctc69m08_006 using mr_param.srvplnclscod ,                   
                              ma_ctc69m08[arr_aux].srvespcod
    whenever error continue                                       
    fetch c_ctc69m08_006 into  ma_ctc69m08[arr_aux].clssrvespcod    
    whenever error stop                                           
                                                                  
                                                                                                   
end function 

#==============================================                                                
 function ctc69m08_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		clssrvespcod  integer      
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DA ESPECIALIDADE ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc69m08_007 using lr_param.clssrvespcod                                                     
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Especialidade!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function                                                      