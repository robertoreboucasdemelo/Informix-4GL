#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Regras Siebel                                              # 
# Modulo.........: ctc69m21                                                   # 
# Objetivo.......: Cadastro Pacote X Clausula/Plano                           # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 09/04/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m21 array[500] of record
      paccod                   integer           
    , pacnom                   char(60)            
    , limite                   integer
    , unilim                   smallint
    , srvplnclsevnlimundnom    like  datksrvplncls.srvplnclsevnlimundnom
    , srvplnclscod             like  datksrvplncls.srvplnclscod    
end record
 
define mr_param   record
       plnclscod  like datkplncls.plnclscod
     , clscod     like datkplncls.clscod   
     , clsnom     like datkplncls.clsnom   
end record
 
define mr_ctc69m21 record
      empcod          like  datksrvplncls.empcod    
     ,usrmatnum       like  datksrvplncls.usrmatnum  
     ,regatldat       like  datksrvplncls.regatldat
     ,funnom          like  isskfunc.funnom 
     ,usrtipcod       like  datksrvplncls.usrtipcod 
end record

define ma_retorno array[500] of record      
     paccod           integer         
end record                               


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc69m21_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select a.srvplnclscod                     '
          ,  '      , a.srvcod                           '
          ,  '      , b.srvnom                           '
          ,  '      , c.srvnom                           '
          ,  '      , a.limite                           '
          ,  '      , d.cpocod                           '
          ,  '      , a.srvplnclsevnlimundnom            '
          ,  '   from datksrvplncls a,                   '  
          ,  '        datksrvgrp b   ,                   ' 
          ,  '        datksrv   c    ,                   '  
          ,  '        datkdominio d                      '
          ,  '  where a.srvcod = b.srvgrpcod             '  
          ,  '  and   b.srvcod = c.srvcod                '         
          ,  '  and   a.srvplnclsevnlimundnom = d.cpodes '
          ,  '  and   a.plnclscod = ?                    '
          ,  '  and   d.cponom = "unid_siebel"           '  
          ,  '  order by b.srvcod                        '
 prepare p_ctc69m21_001 from l_sql
 declare c_ctc69m21_001 cursor for p_ctc69m21_001
 	
 let l_sql = ' select count(*)               '
          ,  '   from datksrvplncls  a,      '
          ,  '        datksrvgrp b           ' 
          ,  '  where a.srvcod = b.srvgrpcod '  
          ,  '  and   b.srvcod = ?           '         
          ,  '  and   a.plnclscod = ?        '
 prepare p_ctc69m21_002 from l_sql
 declare c_ctc69m21_002 cursor for p_ctc69m21_002

 let l_sql =  ' update datksrvplncls                '
           ,  '     set limite    = ? , '  
           ,  '         srvplnclsevnlimundnom = ? , ' 
           ,  '         usrtipcod             = ? , '
           ,  '         empcod                = ? , '
           ,  '         usrmatnum             = ? , '
           ,  '         regatldat             = ?   '
           ,  '   where srvplnclscod =  ?           '        
 prepare p_ctc69m21_003 from l_sql
  
 let l_sql =  ' insert into datksrvplncls   '
           ,  '   (plnclscod                '          
           ,  '   ,srvcod                   '
           ,  '   ,limite                   '
           ,  '   ,srvplnclsevnlimundnom    '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?,?,?)     '
 prepare p_ctc69m21_004 from l_sql 	
  
 
 let l_sql = '   select empcod              '                                  	
            ,'         ,usrmatnum           '                                  	
            ,'         ,regatldat           '                                  	
            ,'         ,usrtipcod           '                            	
            ,'    from datksrvplncls        '     
            ,'    where srvplnclscod  =  ?  '  
 prepare p_ctc69m21_005    from l_sql                                             	
 declare c_ctc69m21_005 cursor for p_ctc69m21_005  
 	
 let l_sql = '  delete datksrvplncls      '                               	
         ,  '   where srvplnclscod  =  ?  '                             	                            	
 prepare p_ctc69m21_006 from l_sql  
 
 
 let l_sql = '   select srvplnclscod    '                
            ,'   from datksrvplncls     '    
            ,'   where plnclscod =  ?   ' 
            ,'   and   srvcod    =  ?   '                  
 prepare p_ctc69m21_007    from l_sql             
 declare c_ctc69m21_007 cursor for p_ctc69m21_007 
 	
 	 
 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m21_008 from l_sql
 declare c_ctc69m21_008 cursor for p_ctc69m21_008 
 	
 	
 let l_sql =  '    delete datkclssrvesp     '        	     	
             ,'     where srvplnclscod = ?  '       	                 	
 prepare p_ctc69m21_009 from l_sql                	
 
 	
 let l_sql =  '    delete datkcbtcss  '   
             ,'     where srvclscod = ?      '  		
 prepare p_ctc69m21_010 from l_sql                	
 	
 	 
 let l_sql =  '    delete datktrfctgcss  '   	
             ,'     where srvclscod = ?  '  
 prepare p_ctc69m21_011 from l_sql                
 
 		
 let l_sql =  '    delete datklclclartc  '  
             ,'     where srvclscod = ?  ' 
 prepare p_ctc69m21_012 from l_sql               	
 
 
 let l_sql = ' delete datkrtcece       '  	     	  
           , ' where lclclartccod in   '    	  
           , '(select lclclartccod     '   	 	  
           , ' from datklclclartc      '  	  
           , ' where srvclscod = ?)    '          
 prepare p_ctc69m21_013 from l_sql                	
 	
 let m_prepare = true


end function

#===============================================================================
 function ctc69m21(lr_param)
#===============================================================================
 
define lr_param record
    plnclscod   like datkplncls.plnclscod ,   
    clscod      like datkplncls.clscod    ,   
    clsnom      like datkplncls.clsnom       
end record
 
define lr_retorno record
    flag                 smallint                               ,
    cont                 integer                                ,
    pacnom               char(60)                               ,
    limite               integer                                ,
    unilim               smallint                               ,
    confirma             char(01) 
end record
 
 let mr_param.plnclscod   = lr_param.plnclscod
 let mr_param.clscod      = lr_param.clscod
 let mr_param.clsnom      = lr_param.clsnom  
 
 for  arr_aux  =  1  to  500                  
    initialize  ma_ctc69m21[arr_aux].*, ma_retorno[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc69m21.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m21_prepare()
 end if
    
 
 
 open window w_ctc69m21 at 6,2 with form 'ctc69m21'
 attribute(form line 1)
  
 message '(F17)Abandona,(F1)Inclui,(F2)Exclui,(F6)Espec,(F7)Classe,(F8)Cober,(F9)Categ' 
   
  display by name mr_param.plnclscod
                , mr_param.clscod 
                , mr_param.clsnom   
  
 
  #--------------------------------------------------------
  # Recupera os Dados do Pacote X Clausula           
  #-------------------------------------------------------- 
  
  open c_ctc69m21_001  using  mr_param.plnclscod 
  foreach c_ctc69m21_001 into ma_ctc69m21[arr_aux].srvplnclscod 
  	                        , ma_retorno[arr_aux].paccod
  	                        , ma_ctc69m21[arr_aux].paccod
                            , ma_ctc69m21[arr_aux].pacnom 
                            , ma_ctc69m21[arr_aux].limite
                            , ma_ctc69m21[arr_aux].unilim
                            , ma_ctc69m21[arr_aux].srvplnclsevnlimundnom 
       

       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Pacotes!"
          exit foreach
       end if
       
  end foreach 
  
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 
 let m_operacao = " " 
  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m21 without defaults from s_ctc69m21.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m21[arr_aux].paccod is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         
         initialize  ma_ctc69m21[arr_aux] to null
                  
         display ma_ctc69m21[arr_aux].paccod                to s_ctc69m21[scr_aux].paccod 
         display ma_ctc69m21[arr_aux].limite    to s_ctc69m21[scr_aux].limite 
         display ma_ctc69m21[arr_aux].unilim                to s_ctc69m21[scr_aux].unilim 
         display ma_ctc69m21[arr_aux].srvplnclsevnlimundnom to s_ctc69m21[scr_aux].srvplnclsevnlimundnom                         

              
      #---------------------------------------------
       before field paccod
      #---------------------------------------------
        
        if ma_ctc69m21[arr_aux].paccod is null then                                                   
           display ma_ctc69m21[arr_aux].paccod to s_ctc69m21[scr_aux].paccod attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          display ma_ctc69m21[arr_aux].* to s_ctc69m21[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m21[scr_aux].srvplnclscod                             
        end if                                                                                               
                      
        
        if m_operacao <> 'i' then    
        	
        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Pacote X Clausula          
        	 #--------------------------------------------------------
        	
           call ctc69m21_dados_alteracao(ma_ctc69m21[arr_aux].srvplnclscod) 
        end if 
      
      #---------------------------------------------
       after field paccod                   
      #---------------------------------------------
      
        if m_operacao = 'i' then
        	
        	if ma_ctc69m21[arr_aux].paccod is null then
        		 
        		 
        		 #--------------------------------------------------------
        		 # Abre o Popup do Pacote          
        		 #--------------------------------------------------------
        		 
        		 call ctc69m04_popup_3(10)
        		 returning ma_ctc69m21[arr_aux].paccod 
        		         , ma_ctc69m21[arr_aux].pacnom
        		         , ma_retorno[arr_aux].paccod  
        		 
        		 if ma_ctc69m21[arr_aux].paccod is null then 
        		    next field paccod 
        		 end if
        	else
        		
        		#--------------------------------------------------------
        		# Recupera a Descricao do Pacote         
        		#--------------------------------------------------------
        		
        		call ctc69m04_recupera_descricao_3(10,ma_ctc69m21[arr_aux].paccod)
        		returning ma_retorno[arr_aux].paccod ,
        		          ma_ctc69m21[arr_aux].pacnom   
        		
        		if ma_ctc69m21[arr_aux].pacnom is null then      
        		   next field paccod                             
        		end if                                                        
        		
          end if 
          
          
          #--------------------------------------------------------
          # Valida Se a Associacao Clausula X Pacote Ja Existe           
          #--------------------------------------------------------
          
          open c_ctc69m21_002 using ma_ctc69m21[arr_aux].paccod ,           
                                    mr_param.plnclscod          
          whenever error continue                                                
          fetch c_ctc69m21_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Associacao ja Cadastrada!" 
             next field paccod 
          end if 
          
          display ma_ctc69m21[arr_aux].paccod to s_ctc69m21[scr_aux].paccod 
          display ma_ctc69m21[arr_aux].pacnom to s_ctc69m21[scr_aux].pacnom                                                                
                              
           
        else          
        	display ma_ctc69m21[arr_aux].* to s_ctc69m21[scr_aux].*                                                     
        end if
        
     #---------------------------------------------
      before field limite 
     #---------------------------------------------                                         
         display ma_ctc69m21[arr_aux].limite  to s_ctc69m21[scr_aux].limite  attribute(reverse)
         let lr_retorno.limite = ma_ctc69m21[arr_aux].limite 
                                                                  
     #--------------------------------------------- 
      after  field limite                                            
     #---------------------------------------------
                                                                                           
                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                
            fgl_lastkey() = fgl_keyval ("left")   then              
               next field paccod                                    
         end if                                                     
                                                                    
         if ma_ctc69m21[arr_aux].limite    is null   then                    
            error "Por Favor Informe o Limite por Evento!"           
            next field limite                                         
         end if 
         
     #---------------------------------------------                                             
      before field unilim                                                                       
     #---------------------------------------------                                             
         display ma_ctc69m21[arr_aux].unilim   to s_ctc69m21[scr_aux].unilim   attribute(reverse) 
         let lr_retorno.unilim = ma_ctc69m21[arr_aux].unilim   
                                                                                              
     #---------------------------------------------                                                 
      after  field unilim                                                                            
     #---------------------------------------------                                                 
                                                                                                    
                                                                                                    
         if fgl_lastkey() = fgl_keyval ("up")     or                                                
            fgl_lastkey() = fgl_keyval ("left")   then                                              
               next field limite                                                             
         end if 
         
         if ma_ctc69m21[arr_aux].unilim is null then                          
         	                                                                           
         	 #--------------------------------------------------------
         	 # Abre a Popup dos Limites           
         	 #--------------------------------------------------------
         	 
         	 call ctc69m04_popup(5)                                                    
         	 returning ma_ctc69m21[arr_aux].unilim                              
         	         , ma_ctc69m21[arr_aux].srvplnclsevnlimundnom                                
         	                                                                           
         	 if ma_ctc69m21[arr_aux].unilim is null then                        
         	    next field unilim                                               
         	 end if                                                                    
         
         else 
         	
         	#--------------------------------------------------------
         	# Recupera a Descricao dos Limites           
         	#--------------------------------------------------------                                                                       
         	
         	call ctc69m04_recupera_descricao(5,ma_ctc69m21[arr_aux].unilim)     
         	returning ma_ctc69m21[arr_aux].srvplnclsevnlimundnom                                 
         	                                                                                                                                                               
         	if ma_ctc69m21[arr_aux].srvplnclsevnlimundnom is null then                                                                                                                      
         	   next field unilim                                                                                          
         	end if                                                                                                               
         	                                                                                                                      
         end if  
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m21[arr_aux].limite  <> lr_retorno.limite  or
               ma_ctc69m21[arr_aux].unilim  <> lr_retorno.unilim  then 	             	                                                                                           
                  
                  #--------------------------------------------------------
                  # Atualiza Associacao Pacote X Clausula          
                  #--------------------------------------------------------
                  
                  call ctc69m21_altera()
                  next field paccod                  
            end if
                       
            let m_operacao = ' '                           
         else
            
            #-------------------------------------------------------- 
            # Inclui Associacao Pacote X Clausula                  
            #-------------------------------------------------------- 
            call ctc69m21_inclui()  
           
            #-------------------------------------------------------- 
            # Recupera Serial da Associacao Pacote X Clausula                  
            #--------------------------------------------------------          
            call ctc69m21_recupera_chave()        
            
            next field paccod            
         end if
         
         display ma_ctc69m21[arr_aux].paccod                 to s_ctc69m21[scr_aux].paccod
         display ma_ctc69m21[arr_aux].pacnom                 to s_ctc69m21[scr_aux].pacnom 
         display ma_ctc69m21[arr_aux].limite                 to s_ctc69m21[scr_aux].limite
         display ma_ctc69m21[arr_aux].unilim                 to s_ctc69m21[scr_aux].unilim
         display ma_ctc69m21[arr_aux].srvplnclsevnlimundnom  to s_ctc69m21[scr_aux].srvplnclsevnlimundnom
         
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m21[arr_aux].srvplnclscod  is null   then                    	
            continue input                                                  	
         else                                                               	
            
            #-------------------------------------------------------------- 
            # Valida Se a Associacao Pacote X Clausula Pode Ser Excluida                  
            #-------------------------------------------------------------- 
            
            if ctc69m06_valida_exclusao() then        
                
                #-------------------------------------------------------- 
                # Exclui Associacao Pacote X Clausula                  
                #-------------------------------------------------------- 
                
                if not ctc69m21_delete(ma_ctc69m21[arr_aux].srvplnclscod) then       	
                    let lr_retorno.flag = 1                                              	
                    exit input                                                  	
                end if   
            else
            	  let lr_retorno.flag = 1   
            	  exit input                
            end if
            
            next field paccod
                                                                   	
         end if                     
      
      
        
      #---------------------------------------------                  	
       on key (F6)                                                    	
      #---------------------------------------------                  	
                                                                      	
          if ma_ctc69m21[arr_aux].paccod is not null then      	
                                                                      	
              call ctc69m08(ma_ctc69m21[arr_aux].srvplnclscod  ,
                            mr_param.clscod                    ,      	
                            mr_param.clsnom                    ,      	
                            ma_ctc69m21[arr_aux].paccod        ,      	
                            ma_ctc69m21[arr_aux].pacnom        ,
                            ma_retorno[arr_aux].paccod )      	        	
          end if
          
      
      #---------------------------------------------                  	
       on key (F7)                                                    	
      #---------------------------------------------                  	
                                                                      	
          if ma_ctc69m21[arr_aux].paccod is not null then      	
                                                                      	
              call ctc69m11(mr_param.plnclscod                  ,
                            ma_ctc69m21[arr_aux].srvplnclscod   ,
                            mr_param.clscod                     ,      	
                            mr_param.clsnom                     ,      	
                            ma_ctc69m21[arr_aux].paccod         ,      	
                            ma_ctc69m21[arr_aux].pacnom   )      	        	
          end if    
      
      
      #---------------------------------------------                  	
       on key (F8)                                                    	
      #---------------------------------------------                  	
                                                                      	
          if ma_ctc69m21[arr_aux].paccod is not null then      	
                                                                      	
              call ctc69m09(mr_param.plnclscod                  ,
                            ma_ctc69m21[arr_aux].srvplnclscod   ,
                            mr_param.clscod                     ,      	
                            mr_param.clsnom                     ,      	
                            ma_ctc69m21[arr_aux].paccod         ,      	
                            ma_ctc69m21[arr_aux].pacnom   )      	        	
          end if    
          
      #---------------------------------------------                  	
       on key (F9)                                                    	
      #---------------------------------------------                  	
                                                                      	
          if ma_ctc69m21[arr_aux].paccod is not null then      	
                                                                      	
              call ctc69m10(mr_param.plnclscod                  ,   
                            ma_ctc69m21[arr_aux].srvplnclscod   ,
                            mr_param.clscod                     ,      	
                            mr_param.clsnom                     ,      	
                            ma_ctc69m21[arr_aux].paccod         ,      	
                            ma_ctc69m21[arr_aux].pacnom   )      	        	
          end if
          
         	
         	
       
      
          
  end input
  
 close window w_ctc69m21
 
 if lr_retorno.flag = 1 then
    call ctc69m21(mr_param.*)
 end if
 
 
end function


#---------------------------------------------------------
 function ctc69m21_func(lr_param)
#---------------------------------------------------------

 define lr_param    record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno  record
    funnom   like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m21_prepare()
end if
 
 initialize lr_retorno.*    to null

   if lr_param.empcod is null or 
      lr_param.empcod = " " then
      
      let lr_param.empcod = 1 
   
   end if 
 
  
   #-------------------------------------------------------- 
   # Recupera os Dados do Pacote X Clausula                  
   #-------------------------------------------------------- 
    
   open c_ctc69m21_008 using lr_param.empcod , 
                             lr_param.funmat ,                       
                             lr_param.usrtipcod
   whenever error continue                            
   fetch c_ctc69m21_008 into lr_retorno.funnom
   whenever error stop
 
 return lr_retorno.funnom

 end function
 

#---------------------------------------------------------                                                                                            
 function ctc69m21_dados_alteracao(lr_param)                                             
#---------------------------------------------------------                                       

define lr_param record
	srvplnclscod like  datksrvplncls.srvplnclscod
end record
                                                                                                    
                                                                                      
   initialize mr_ctc69m21.* to null                                                    
                                                                                      
                                                               
   open c_ctc69m21_005 using lr_param.srvplnclscod                                                  
      
   whenever error continue                                                 
   fetch c_ctc69m21_005 into  mr_ctc69m21.empcod                                       
                             ,mr_ctc69m21.usrmatnum                                       
                             ,mr_ctc69m21.regatldat                                       
                             ,mr_ctc69m21.usrtipcod                                        
                                                                                      
   whenever error stop  
                                                                                              
   call ctc69m21_func(mr_ctc69m21.usrmatnum, mr_ctc69m21.empcod, mr_ctc69m21.usrtipcod)               
   returning mr_ctc69m21.funnom                                                  
                                                                                 
   display by name  mr_ctc69m21.regatldat                                           
                   ,mr_ctc69m21.funnom                                           
                                                                                      
end function                                                                          
              

#==============================================                                                
 function ctc69m21_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
		srvplnclscod like  datksrvplncls.srvplnclscod    
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE Pacote ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        begin work
        
        whenever error continue                                                                
        execute p_ctc69m21_006 using lr_param.srvplnclscod                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Pacote!'   
           rollback work
           return false                                                                                                                                               
        end if 
        
        
        if not ctc69m21_remove_associacao(lr_param.srvplnclscod) then
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
 function ctc69m21_altera()                                             
#---------------------------------------------------------                                       

    whenever error continue 
    execute p_ctc69m21_003 using ma_ctc69m21[arr_aux].limite
                               , ma_ctc69m21[arr_aux].srvplnclsevnlimundnom
                               , g_issk.usrtip         
                               , g_issk.empcod 
                               , g_issk.funmat         
                               , 'today'                                                  
                               , ma_ctc69m21[arr_aux].srvplnclscod
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao da Associacao!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if   
    
    let m_operacao = ' '            
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc69m21_inclui()                                             
#---------------------------------------------------------                                       

    whenever error continue
    execute p_ctc69m21_004 using mr_param.plnclscod  
                               , ma_retorno[arr_aux].paccod
                               , ma_ctc69m21[arr_aux].limite
                               , ma_ctc69m21[arr_aux].srvplnclsevnlimundnom
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
 function ctc69m21_recupera_chave()                                                                                                                                       
#---------------------------------------------------------                                                                                                        
                                                                                
    open c_ctc69m21_007 using mr_param.plnclscod,                           
                              ma_retorno[arr_aux].paccod                                    
    whenever error continue                                       
    fetch c_ctc69m21_007 into  ma_ctc69m21[arr_aux].srvplnclscod                                                             
    whenever error stop 
    
    if sqlca.sqlcode <> 0 then                                     
       error 'Erro (',sqlca.sqlcode,') ao Recuperar a Chave!'                                                                
    end if                                                                                                                                            
                              
end function

#==============================================                                                                                                 
 function ctc69m21_remove_associacao(lr_param)                                         
#==============================================                             
                                                                            
define lr_param record                                                      
		srvplnclscod like  datksrvplncls.srvplnclscod                                                   
end record                                                                  
                                                                                                                                                                                                                                                 
   whenever error continue                                             
   execute p_ctc69m21_009 using lr_param.srvplnclscod                   
                                                                       
   whenever error stop                                                 
   if sqlca.sqlcode <> 0 then                                          
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Especialidade!'           
      return false                                                     
   end if                                                              
   
   whenever error continue                                          
   execute p_ctc69m21_010 using lr_param.srvplnclscod                
                                                                    
   whenever error stop                                              
   if sqlca.sqlcode <> 0 then                                       
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cobertura!'  
      return false                                                  
   end if                                                           
   
   whenever error continue                                         
   execute p_ctc69m21_011 using lr_param.srvplnclscod               
                                                                   
   whenever error stop                                             
   if sqlca.sqlcode <> 0 then                                      
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Categoria!'     
      return false                                                 
   end if                                                          
   
   
   whenever error continue                                         
   execute p_ctc69m21_013 using lr_param.srvplnclscod               
   whenever error stop                                             
   if sqlca.sqlcode <> 0 then                                                                                  
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cidade!'        
      return false                                                 
   end if                                                          
   
     
   whenever error continue                                         
   execute p_ctc69m21_012 using lr_param.srvplnclscod               
                                                                   
   whenever error stop                                             
   if sqlca.sqlcode <> 0 then                                      
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Classe!'     
      return false                                                 
   end if                                                            
   
   return true                                                         
                                                       
                                                                                                                                  
end function                                                                
                                                                            























