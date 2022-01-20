#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty45g00                                                    #
# Objetivo.......: Registro Help Desk Itau                                     #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 24/05/2015                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint


#----------------------------------------------#
 function cty45g00_prepare()
#----------------------------------------------#

  define l_sql char(2000)

  let l_sql = " select cornom                 ",        
              "  from gcaksusep a,            ",        
              "       gcakcorr b              ",        
              " where a.corsus  = ?           ",        
              " and a.corsuspcp = b.corsuspcp "          
  prepare pcty45g00001 from l_sql
  declare ccty45g00001 cursor for pcty45g00001

  let l_sql = " select c24pbmdes    ",                         
              " from datkpbm        ",                      
              " where c24pbmcod = ? "             
   prepare pcty45g00002 from l_sql
   declare ccty45g00002 cursor for pcty45g00002

   let l_sql = " update datmligacao  ", 
               " set c24astcod = ?   ",    
               " where lignum  = ?   ",
               " and c24astcod = ?   "
   prepare pcty45g00003 from l_sql

   let l_sql = " insert into datrligsrv " , 
               "(lignum         "         ,        
               ",atdsrvnum      "         ,   
               ",atdsrvano )    "         ,      
               " values (?,?,?) "       
   prepare pcty45g00004 from l_sql
   
   let l_sql = " update datmligacao        ",
               " set (atdsrvnum,atdsrvano) ",
               " = (?,?)                   ",
               " where lignum = ?          "
   prepare pcty45g00005 from l_sql
   
   
   let l_sql = "  insert into datmsrvre (atdsrvnum      ,atdsrvano      ",
               "                        ,lclrsccod      ,orrdat         ",
               "                        ,orrhor         ,sinntzcod      ",
               "                        ,socntzcod      ,atdsrvretflg   ",
               "                        ,atdorgsrvnum   ,atdorgsrvano   ",
               "                        ,srvretmtvcod   ,sinvstnum      ",
               "                        ,sinvstano      ,espcod         ",
               "                        ,retprsmsmflg   ,lclnumseq      ",
               "                        ,rmerscseq)                     ",
               "  values (?,?,?,?,?,?,?,'N',?,?,?,?,?,?,?,?,?)          "
    prepare pcty45g00006 from l_sql  
    
    
    let l_sql = " select c24funmat   ",
                "       ,c24ligdsc   ",
                "       ,ligdat      ",
                "       ,lighorinc   ",
                "       ,c24usrtip   ",
                "       ,c24empcod   ",
                " from datmlighist   ",
                " where lignum = ?   ",
                " order by c24txtseq "
    prepare pcty45g00007 from l_sql             
    declare ccty45g00007 cursor for pcty45g00007
    	
    	
    let l_sql = "select rcuccsmtvdes      ",                                	                              	
                "from datkrcuccsmtv       ",                        	
                "where rcuccsmtvstt = 'A' ",                         	
                "and rcuccsmtvcod = ?     ",  	
                "and c24astcod    = ?     "  	
    prepare pcty45g00008 from l_sql                                                                  	
    declare ccty45g00008 cursor for pcty45g00008
    	
    let l_sql = " select 0 "                         
               ," from datrligrcuccsmtv "          
               ," where lignum     = ? "           	
               ," and rcuccsmtvcod = ? "          	
               ," and c24astcod    = ? "          	 	
    prepare pcty45g00009 from l_sql                        	
    declare ccty45g00009 cursor for pcty45g00009 
    	
    let l_sql = " insert into datrligrcuccsmtv " 
               ,"(lignum        "            	
               ," ,rcuccsmtvcod "      	
               ," ,c24astcod)   "        	
               ," values(?,?,?) "            	
    prepare pcty45g00010 from l_sql  
    
    
    let l_sql = " select count(*)      "               
               ," from datkdominio     "               
               ," where cponom =  ?    "               
               ," and   cpodes =  ?    "               
    prepare pcty45g00011 from l_sql                 
    declare ccty45g00011 cursor for pcty45g00011 
    	
    let l_sql = " select cpodes        "               
               ," from datkdominio     "               
               ," where cponom =  ?    "                            
    prepare pcty45g00012 from l_sql                
    declare ccty45g00012 cursor for pcty45g00012 	
    
    
    
    
                                   	
    	
    	
    	   
    	    
    let m_prepare = true

end function




#-------------------------------------------------#
 function cty45g00_assunto_help_desk_itau(lr_param)
#-------------------------------------------------#

define lr_param record
  c24astcod like datkassunto.c24astcod
end record

define lr_retorno record                      
  linha1     char(40),          
  linha2     char(40),          
  linha3     char(40),          
  linha4     char(40),           
  confirma   char(01)                                                  
end record


initialize lr_retorno.* to null

   if lr_param.c24astcod = "R66" or                       
      lr_param.c24astcod = "R67" then                     
                                                         
                                                                       
       if g_issk.dptsgl = "hdcorr"  then                     
          let lr_retorno.linha2 = "UTILIZAR O ASSUNTO 'RDK'."       
       else                                                  
          let lr_retorno.linha2 = "UTILIZAR O ASSUNTO 'RDT'."       
       end if                                                
                                                         
                                                         
       call cts08g01 ("A","N","",lr_retorno.linha2,"","")           
       returning lr_retorno.confirma                            

       return false
    end if

    return true


end function

#---------------------------------------------------------------------------
function cty45g00_rdk(lr_param)
#---------------------------------------------------------------------------

define lr_param  record
   lignum     like datmligacao.lignum   ,
   c24solnom  like datmligacao.c24solnom
end record

define lr_retorno record
     erro            smallint                    ,   
     msg             char(300)                   ,
     clscod          like datrsrvcls.clscod      ,
     atddat          like datmservico.atddat     ,
     atdhor          like datmservico.atdhor     ,
     atdsrvnum       like datmservico.atdsrvnum  ,
     atdsrvano       like datmservico.atdsrvano  ,
     atdlibhor       like datmservico.atdlibhor  ,
     atdlibdat       like datmservico.atdlibdat  ,
     confirma        char(01)                    ,
     data            date                        ,
     hora            datetime hour to minute     ,               
     tabname         char(20)                    ,
     sqlcode         integer                     ,
     lignum          like datmligacao.lignum     ,
     c24astcod       like datkassunto.c24astcod  ,
     prompt          char(01)                    ,
     cornom          like gcakcorr.cornom        ,
     c24pbmcod       like datkpbm.c24pbmcod      ,
     c24pbmdes       like datkpbm.c24pbmdes      ,
     socntzcod       like datksocntz.socntzcod   ,
     ret             smallint                    ,
     mensagem        char(50)                    ,
     nulo            char(01)
end record
 
   initialize lr_retorno.* to null
   
   if m_prepare is null or
      m_prepare <> true then
       call cty45g00_prepare()
   end if
     
 
   let lr_retorno.ret = 0
   
   if not cty05g11_atendimento_unificado() then
   	
   	   if cty05g11_atendimento_telefonico() and 
   	      cty05g11_atendimento_presencial() then
   	      	
   	      #---------------------------------------                        
   	      # Alerta para Direcionar o Atendimento                          
   	      #---------------------------------------                        	
   	                                                                      	
   	      call cts08g01 ("A","S","","SOLUCIONADO POR TELEFONE?","","")    
   	      returning lr_retorno.confirma                                   
   	   
   	   else
   	       if not cty05g11_atendimento_telefonico() then
   	          let lr_retorno.confirma = "N"
   	       else
   	       	  let lr_retorno.confirma = "S" 
   	       end if 
   	   end if  	  
   	   
   else
   	  
      #---------------------------------------                          	   
      # Alerta para Direcionar o Atendimento                            	   
      #---------------------------------------                          	
                                                                        	
      call cts08g01 ("A","S","","SOLUCIONADO POR TELEFONE?","","")      	
      returning lr_retorno.confirma 
                                          
   end if	 

   call cts40g03_data_hora_banco(2)
   returning lr_retorno.data, lr_retorno.hora

   let lr_retorno.atddat    = lr_retorno.data
   let lr_retorno.atdhor    = lr_retorno.hora
   let lr_retorno.atdlibhor = lr_retorno.hora
   let lr_retorno.atdlibdat = lr_retorno.data  
   
   if g_documento.c24astcod = "R78" or 
   	  g_documento.c24astcod = "RAR" then
   	   let lr_retorno.confirma = "S"   
   end if

   #-------------------------
   # Atendimento Telefonico
   #-------------------------
   
   if lr_retorno.confirma = "S" then

  
      #------------------------------
      # Recupera o Nome do Corretor
      #------------------------------
      
      open ccty45g00001 using g_doc_itau[1].corsus
      whenever error continue                                    
      fetch ccty45g00001 into lr_retorno.cornom
      whenever error stop            
           
      if sqlca.sqlcode <> 0  then                   
         let lr_retorno.cornom = "Corretor nao Cadastrado"  
      end if                                                
      
 
      begin work

      if g_documento.c24astcod = "RDK" then
         let lr_retorno.c24astcod = "R66"
      else
      	  if g_documento.c24astcod = "RAR" then
      	  	  let lr_retorno.c24astcod = g_documento.c24astcod
      	  else	  
              let lr_retorno.c24astcod = "R78"
          end if
      end if


      #-----------------------------------------------------
      # Altera Assunto de RDK para R66 ou de R68 para R78
      #----------------------------------------------------- 
      
      whenever error continue                           
      execute pcty45g00003 using lr_retorno.c24astcod     
                               , lr_param.lignum    
                               , g_documento.c24astcod           
      whenever error stop                           
      

      if sqlca.sqlcode <> 0 then
         error "Problemas na Atualizacao do Codigo RDK ou R68." sleep 3
      end if

      let g_documento.c24astcod =  lr_retorno.c24astcod


      #----------------------------------------
      # Recupera Numero do Servico
      #----------------------------------------
      
      call cts10g03_numeracao(0,"9")
      returning lr_retorno.lignum
               ,lr_retorno.atdsrvnum
               ,lr_retorno.atdsrvano
               ,lr_retorno.sqlcode
               ,lr_retorno.msg

      if lr_retorno.sqlcode = 0 then
         commit work
      else
         let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg

         call ctx13g00(lr_retorno.sqlcode,"DATKGERAL",lr_retorno.msg)

         rollback work

         prompt "" for lr_retorno.prompt

         let lr_retorno.ret      = lr_retorno.sqlcode
         let lr_retorno.mensagem = lr_retorno.msg
	      
	       return  lr_retorno.ret      , 
	               lr_retorno.mensagem
      
      end if 
     

      #-------------------------------------------------
      # Seleciona Natureza e Problema
      #-------------------------------------------------
      call cty45g00_seleciona_natureza()
      returning lr_retorno.c24pbmcod
               ,lr_retorno.c24pbmdes
               ,lr_retorno.socntzcod
      
      
         

      begin work
      
      #---------------------------------------------
      # Gera Servico para R66 ou R78
      #---------------------------------------------
      
      call cts10g02_grava_servico(lr_retorno.atdsrvnum       # atdsrvnum
                                 ,lr_retorno.atdsrvano       # atdsrvano
                                 ,g_documento.soltip         # atdsoltip
                                 ,lr_param.c24solnom         # c24solnom
                                 ,""                         # vclcorcod
                                 ,g_issk.funmat              # funmat
                                 ,"N"                        # atdlibflg
                                 ,lr_retorno.atdlibhor       # atdlibhor
                                 ,lr_retorno.atdlibdat       # atdlibdat
                                 ,lr_retorno.atddat          # atddat
                                 ,lr_retorno.atdhor          # atdhor
                                 ,""                         # atdlclflg
                                 ,""                         # atdhorpvt
                                 ,""                         # atddatprg
                                 ,""                         # atdhorprg
                                 ,"9"                        # atdtip
                                 ,""                         # atdmotnom
                                 ,""                         # atdvclsgl
                                 ,10573                      # ardprscod
                                 ,""                         # atdcstvlr
                                 ,"S"                        # atdfnlflg
                                 ,lr_retorno.atdhor          # atdfnlhor
                                 ,"S"                        # atdrsdflg
                                 ,"HELP DESK CASA-TELEFONICO"# atddfttxt
                                 ,""                         # atddoctxt
                                 ,g_issk.funmat              # c24opemat
                                 ,""                         # nom
                                 ,""                         # vcldes
                                 ,""                         # vclanomdl
                                 ,""                         # vcllicnum
                                 ,g_documento.corsus         # corsus
                                 ,lr_retorno.cornom          # cornom
                                 ,""                         # cnldat
                                 ,""                         # pgtdat
                                 ,""                         # c24nomctt
                                 ,"N"                        # atdpvtretflg
                                 ,""                         # atdvcltip
                                 ,6   ---> Assitencia Resid  # asitipcod
                                 ,""                         # socvclcod
                                 ,""                         # vclcoddig
                                 ,"N"                        # srvprlflg
                                 ,""                         # srrcoddig
                                 ,2                          # atdprinvlcod
                                 ,9 )                        # atdsrvorg
                        returning lr_retorno.tabname
                                 ,lr_retorno.sqlcode

      
      if lr_retorno.sqlcode <> 0 then
         let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg

         call ctx13g00(lr_retorno.sqlcode,"datmservico",lr_retorno.msg)

         rollback work

         prompt "" for lr_retorno.prompt

         let lr_retorno.ret      = lr_retorno.sqlcode
         let lr_retorno.mensagem = lr_retorno.msg
	      
	       return  lr_retorno.ret       , 
	               lr_retorno.mensagem
      
      end if


      #---------------------------------
      # Relaciona Servico com Ligacao
      #---------------------------------
      
      if lr_retorno.atdsrvnum is not null and
         lr_retorno.atdsrvano is not null then

         whenever error continue                               
         execute pcty45g00004 using lr_param.lignum            
                                  , lr_retorno.atdsrvnum      
                                  , lr_retorno.atdsrvano       
         whenever error stop
         
         if lr_retorno.sqlcode <> 0 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datrligsrv",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
         end if                                   
           
        
         #-----------------------------------
         # Atualiza Servico na Datmligacao
         #-----------------------------------
         
         whenever error continue                              
         execute pcty45g00005 using lr_retorno.atdsrvnum      
                                  , lr_retorno.atdsrvano
                                  , lr_param.lignum      
         whenever error stop                                  
         
         if lr_retorno.sqlcode <> 0 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datmligacao",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
         end if                                   

      end if


      #------------------------------------------------
      # Insere Servico X RE (Residencia Emergencial)
      #------------------------------------------------ 
      
      whenever error continue                           
      execute pcty45g00006 using lr_retorno.atdsrvnum   
                               , lr_retorno.atdsrvano   
                               , g_rsc_re.lclrsccod 
                               , lr_retorno.atddat 
                               , lr_retorno.atdhor
                               , lr_retorno.nulo   
                               , lr_retorno.socntzcod
                               , lr_retorno.nulo
                               , lr_retorno.nulo
                               , lr_retorno.nulo
                               , lr_retorno.nulo
                               , lr_retorno.nulo
                               , lr_retorno.nulo
                               , lr_retorno.nulo
                               , g_documento.lclnumseq
                               , g_documento.rmerscseq      
      whenever error stop                               
      
      if lr_retorno.sqlcode <> 0 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datmsrvre",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
       end if                                   


      #-----------------------------
      # Insere Apolice x Servicos
      #-----------------------------
      if g_documento.aplnumdig is not null and
         g_documento.aplnumdig <> 0        then
        
         if g_documento.edsnumref is null then   
            let g_documento.edsnumref = 0        
         end if  
                                         
         call cts10g02_grava_servico_apolice(lr_retorno.atdsrvnum
                                            ,lr_retorno.atdsrvano
                                            ,g_documento.succod
                                            ,g_documento.ramcod
                                            ,g_documento.aplnumdig
                                            ,g_documento.itmnumdig
                                            ,g_documento.edsnumref)
                                   returning lr_retorno.tabname
                                            ,lr_retorno.sqlcode

         if lr_retorno.sqlcode <> 0 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datrservapol",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
          end if                                   
      end if


      #-----------------------------
      # Grava Problema do Servico
      #-----------------------------
      
      call ctx09g02_inclui(lr_retorno.atdsrvnum
                          ,lr_retorno.atdsrvano
                          ,1   
                          ,lr_retorno.c24pbmcod
                          ,lr_retorno.c24pbmdes
                          ,"") 
      returning lr_retorno.sqlcode
               ,lr_retorno.tabname
               
      if lr_retorno.sqlcode <> 0 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datrsrvpbm",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
      end if                                            


      #----------------------------------
      # Grava Etapas do Acompanhamento
      #----------------------------------
      
      call cts10g04_insere_etapa(lr_retorno.atdsrvnum
                                ,lr_retorno.atdsrvano
                                ,"4"  
                                ,10573
                                ,""
                                ,""
                                ,"")
      returning lr_retorno.sqlcode

      
      if lr_retorno.sqlcode <> 0 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datmsrvacp",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
      end if                                            


      #--------------------------------------------------------
      # Replica Historico da Ligacao para o Historico Servico
      #--------------------------------------------------------
      call cty45g00_replica_historico_telefonico(lr_param.lignum
                                                ,lr_retorno.atdsrvnum
                                                ,lr_retorno.atdsrvano)
      returning lr_retorno.ret  ,   
                lr_retorno.mensagem      
      
      if lr_retorno.ret <> 1 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datmservhst",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
      end if                                             
    

      commit work
      
      #--------------------------------------------
      # Ponto de Acesso Apos a Gravacao do Laudo
      #--------------------------------------------
      call cts00g07_apos_grvlaudo(lr_retorno.atdsrvnum
                                 ,lr_retorno.atdsrvano)

   
   else

      #------------------------- 
      # Atendimento Presencial   
      #------------------------- 
      
      
      #-----------------------------------------------------
      # Replica Historico da Ligacao para Historico Servico
      #-----------------------------------------------------
      
      call cty45g00_replica_historico_presencial(lr_param.lignum          
                                                ,lr_retorno.atddat    
                                                ,lr_retorno.atdhor) 
      returning lr_retorno.ret                                                  
               ,lr_retorno.mensagem 

      if lr_retorno.ret <> 1 then
             
             let lr_retorno.msg = "cty45g00 - ",lr_retorno.msg
             
             call ctx13g00(lr_retorno.sqlcode,"datmservhst",lr_retorno.msg)
             
             rollback work
             
             prompt "" for lr_retorno.prompt
             
             let lr_retorno.ret      = lr_retorno.sqlcode
             let lr_retorno.mensagem = lr_retorno.msg
	           
	           return  lr_retorno.ret       , 
	                   lr_retorno.mensagem
      
      else                                                              
         commit work                                                    
         error " O motivo da visita foi gravado no historico. "         
      end if                                             


   end if

   return  lr_retorno.ret       ,     
           lr_retorno.mensagem        
   

end function

#-------------------------------------------------#
 function cty45g00_seleciona_natureza()
#-------------------------------------------------#

define lr_retorno record                           
  socntzcod   like datksocntz.socntzcod  ,       
  status      smallint                   ,       
  mensagem    char(100)                  ,       
  c24pbmcod   like datkpbm.c24pbmcod     ,       
  c24pbmdes   like datkpbm.c24pbmdes     ,       
  atddfttxt   like datmservico.atddfttxt ,       
  cont        smallint                   ,       
  confirma    char(01)                                                                  
end record


initialize lr_retorno.* to null

   let lr_retorno.cont = 0 
   
   while lr_retorno.cont = 0
   	
   	   #-------------------------------
   	   # Seleciona Natureza              
   	   #-------------------------------   
   	  
   	   call cts12g05(g_doc_itau[1].itaasisrvcod,'N',lr_retorno.socntzcod)  
       returning lr_retorno.socntzcod                                 
      
       if lr_retorno.socntzcod is not null and
       	  lr_retorno.socntzcod <> 0        then      
      
          #-------------------------------                              
          # Seleciona Problema                             
          #-------------------------------                              
          
          call cts17m07_problema(g_documento.aplnumdig                  
                                ,g_documento.c24astcod                  
                                ,9                         
                                ,""                        
                                ,lr_retorno.socntzcod                            
                                ,""                          
                                ,""                          
                                ,0                            
                                ,g_documento.ramcod                     
                                ,g_documento.crtsaunum)                 
           returning lr_retorno.status                               
                    ,lr_retorno.mensagem                             
                    ,lr_retorno.c24pbmcod                            
                    ,lr_retorno.atddfttxt 
                    
                    
           #------------------------------------------ 
           # Verifica se Foi Selecionado um Problema             
           #------------------------------------------ 
           
           if lr_retorno.c24pbmcod is not null and                                      
              lr_retorno.c24pbmcod <> 0        then                                                                                                                  
                 let lr_retorno.cont = 1                                                   
           else                                                                
                                                                                                         
                 call cts08g01 ("A","N", ""                                       
                               ,""                                                
                               ,"INFORME A NATUREZA E O PROBLEMA."                
                               ,"")                                               
                 returning lr_retorno.confirma                                         
                                                                               
           end if                                                                                                       
       end if
   end while
   
   #-----------------------------------
   # Recupera a Descricao do Problema
   #-----------------------------------
         
   
   open ccty45g00002 using lr_retorno.c24pbmcod  
   whenever error continue                                  
   fetch ccty45g00002 into lr_retorno.c24pbmdes            
   whenever error stop  
   
   if sqlca.sqlcode <> 0  then                   
      let lr_retorno.c24pbmdes = "Problema Não Localizado"  
   end if                                                
                                                        
                                                        
   return lr_retorno.c24pbmcod                                   
         ,lr_retorno.c24pbmdes                                   
         ,lr_retorno.socntzcod                                   

   
end function

#--------------------------------------------------------------------
function cty45g00_replica_historico_telefonico(lr_param)
#-------------------------------------------------------------------

define lr_param  record
       lignum      like datmligacao.lignum     ,
       atdsrvnum   like datmservhist.atdsrvnum ,
       atdsrvano   like datmservhist.atdsrvano
end record

define lr_retorno record
       c24funmat     like datmlighist.c24funmat
      ,c24ligdsc     like datmlighist.c24ligdsc
      ,ligdat        like datmlighist.ligdat
      ,lighorinc     like datmlighist.lighorinc
      ,c24usrtip     like datmlighist.c24usrtip
      ,c24empcod     like datmlighist.c24empcod  
      ,tabname       char(20)  
      ,sqlcode       integer
      ,ret           smallint  
      ,mensagem      char(50)         
end record

   if m_prepare is null or       
      m_prepare <> true then     
       call cty45g00_prepare()   
   end if  
                         
   initialize lr_retorno.* to null

   #------------------------------------------------------------------
   # Recupera o Historico da Ligacao 
   #------------------------------------------------------------------
   
   open ccty45g00007 using lr_param.lignum       
   whenever error continue       
   
   foreach ccty45g00007 into lr_retorno.c24funmat
                            ,lr_retorno.c24ligdsc
                            ,lr_retorno.ligdat
                            ,lr_retorno.lighorinc
                            ,lr_retorno.c24usrtip
                            ,lr_retorno.c24empcod

      whenever error stop
      
 
      if sqlca.sqlcode <> 0   and
         sqlca.sqlcode <> 100 then
         error " Erro em ccty45g00007. Avise a informatica."
      end if


      if lr_retorno.c24ligdsc is not null then
      	
         #-------------------------------------
	       # Registra Historico para o Servico
         #-------------------------------------
         call ctd07g01_ins_datmservhist(lr_param.atdsrvnum
                                       ,lr_param.atdsrvano
                                       ,lr_retorno.c24funmat
                                       ,lr_retorno.c24ligdsc
                                       ,lr_retorno.ligdat
                                       ,lr_retorno.lighorinc
                                       ,lr_retorno.c24empcod
                                       ,lr_retorno.c24usrtip )
         returning lr_retorno.ret 
                  ,lr_retorno.mensagem
                  display "lr_retorno.ret      ", lr_retorno.ret         
                  display "lr_retorno.mensagem ", lr_retorno.mensagem
      end if

   end foreach 
   
   
   return  lr_retorno.ret       ,  
           lr_retorno.mensagem     
   
   

end function

#--------------------------------------------------------------------
function cty45g00_replica_historico_presencial(lr_param)
#--------------------------------------------------------------------

define lr_param  record
   lignum   like datmligacao.lignum
  ,data     date
  ,hora     datetime hour to minute
end record


define lr_retorno record
   texto1      char(70)
  ,texto2      char(70) 
  ,cont        smallint 
  ,texto       char(70)     
  ,c24astcod   like datkassunto.c24astcod 
  ,ret         smallint      
  ,mensagem    char(50)       
end record
   
   if m_prepare is null or       
      m_prepare <> true then     
       call cty45g00_prepare()   
   end if    
                       
   initialize lr_retorno.* to null

   open window cty45g00a at 12,05 with form "cta15m00a"
   attribute (form line 1, border)

   input by name lr_retorno.texto1
                ,lr_retorno.texto2


      before field texto1
         display by name lr_retorno.texto1 attribute (reverse)

      after field texto1
         display by name lr_retorno.texto1

         if lr_retorno.texto1 is null or
            lr_retorno.texto1 =  " "  then
            error " Informe o motivo da visita. "
            next field texto1
         end if


      before field texto2
         display by name lr_retorno.texto2 attribute (reverse)

      after field texto2
         display by name lr_retorno.texto2

      on key (interrupt)

         if lr_retorno.texto1 is null or
            lr_retorno.texto1 =  " "  then
            error " O motivo da visita deve ser informado. "
            next field texto1
         end if
         
         exit input
    
    end input


    begin work
    
    if g_documento.c24astcod = "RDK" then
       
       #----------------------------------
       # Altera Assunto para R67
       #----------------------------------
  
       let lr_retorno.c24astcod = "R67" 
                                                                
       whenever error continue                                  
       execute pcty45g00003 using lr_retorno.c24astcod          
                                , lr_param.lignum               
                                , g_documento.c24astcod         
       whenever error stop                                      
       
       if sqlca.sqlcode <> 0 then
          error "Problemas na Atualizacao do Codigo RDK para R67.", sqlca.sqlcode sleep 3
       end if
       
       let g_documento.c24astcod = "R67"
    
    end if
    
    #--------------------------------------------
    # Registra no Historico o Motivo da Visita
    #--------------------------------------------
    
    for lr_retorno.cont = 1 to 3

       if lr_retorno.cont = 1 then
          let lr_retorno.texto = "Mensagem para Prestador: "
       else
          
          if lr_retorno.cont = 2 then
             let lr_retorno.texto = lr_retorno.texto1
          else
             
             if lr_retorno.texto2 is null or
                lr_retorno.texto2 =  " "  then
                let lr_retorno.texto2 = "."
             end if
             
             let lr_retorno.texto = lr_retorno.texto2
          
          end if
       end if

       #--------------------------------------------
       # Insere no Historico 
       #--------------------------------------------
       
       call ctd06g01_ins_datmlighist(lr_param.lignum
                                    ,g_issk.funmat
                                    ,lr_retorno.texto
                                    ,lr_param.data
                                    ,lr_param.hora
                                    ,g_issk.usrtip
                                    ,g_issk.empcod)
       returning lr_retorno.ret  
                ,lr_retorno.mensagem

    end for

    close window cty45g00a
    
    return  lr_retorno.ret      
           ,lr_retorno.mensagem

end function

#--------------------------------------------------------------------           
function cty45g00_registra_ligacao_rdk(lr_param)                        
#-------------------------------------------------------------------            
                                                                                
define lr_param  record                                                         
       lignum      like datmligacao.lignum     ,                                
       atdsrvnum   like datmservhist.atdsrvnum ,                                
       atdsrvano   like datmservhist.atdsrvano                                  
end record                                                                      
                                                                                
define lr_retorno record                                                                            
       ret           smallint                                                   
      ,mensagem      char(50)                                                   
end record                                                                      
                                                                                
   initialize lr_retorno.* to null                                              
                                                                                
   #---------------------------------     
   # Relaciona Servico com Ligacao   
   #---------------------------------
   
   whenever error continue                                   
   execute pcty45g00004 using lr_param.lignum                
                            , lr_param.atdsrvnum           
                            , lr_param.atdsrvano           
   whenever error stop                                       
        
                                   
   if sqlca.sqlcode <> 0 then                                                      
      
      let lr_retorno.mensagem = " Erro (",sqlca.sqlcode,") na gravacao do",            
                                " servico x ligacao. AVISE A INFORMATICA!"             
      
      let lr_retorno.ret = sqlca.sqlcode                                           
      
      error lr_retorno.mensagem sleep 1                                                
                                                                                    
      return lr_retorno.ret      ,
             lr_retorno.mensagem                                                             
   end if                                                                          
                                                                                     
   
   #-----------------------------------                
   # Atualiza Servico na Datmligacao                   
   #-----------------------------------                
                                                       
   whenever error continue                             
   execute pcty45g00005 using lr_param.atdsrvnum     
                            , lr_param.atdsrvano     
                            , lr_param.lignum          
   whenever error stop                                 
                    
   if sqlca.sqlcode <> 0 then                                                      
      
      let lr_retorno.mensagem = " Erro (",sqlca.sqlcode,") na atualizacao do",         
                                " servico na ligacao. AVISE A INFORMATICA!"            
     
      let lr_retorno.ret = sqlca.sqlcode                                           
      
      error lr_retorno.mensagem sleep 1                                                
                                                  
      return lr_retorno.ret      , 
             lr_retorno.mensagem   
                                                  
                                                                   
   end if                                                                          
         
                                                                                                                                                               
   return  lr_retorno.ret       ,                                               
           lr_retorno.mensagem                                                  
                                                                                                                                                                                                                                           
end function                                                                    
             
#--------------------------------------------------------------
function cty45g00_abandono_rdk(lr_param)
#--------------------------------------------------------------

define lr_param  record
   rcuccsmtvcod like datrligrcuccsmtv.rcuccsmtvcod , 
   data         date                               ,
   hora         datetime hour to minute            ,
   atddat       like datmservico.atddat            ,
   atdhor       like datmservico.atdhor
end record

define lr_retorno record
    ret       smallint                  
   ,mensagem  char(50)                  
   ,motivo    char(50)                  
   ,texto     char(60)                  
   ,cont      smallint                  
   ,data      date                      
   ,hora      datetime hour to minute 
   ,c24astcod like datkassunto.c24astcod      
end record

   initialize lr_retorno.* to null

   let lr_retorno.hora = lr_param.hora
   let lr_retorno.data = lr_param.data

   let lr_retorno.c24astcod = "R51"
   
   #-----------------------------------------
   # Altera Assunto de R67 ou R68 para R51
   #-----------------------------------------     
   
   whenever error continue                                
   execute pcty45g00003 using lr_retorno.c24astcod        
                            , g_documento.lignum               
                            , g_documento.c24astcod       
   whenever error stop                                    
                                                          
   if sqlca.sqlcode <> 0 then
      error "Problemas na Atualizacao do Codigo R67/R68 p/ R51." sleep 3
   end if

   let g_documento.c24astcod = "R51"
   let g_documento.acao      = "XXX"

   #----------------------------
   # Busca Descricao do Motivo
   #----------------------------
 
   open ccty45g00008 using lr_param.rcuccsmtvcod ,
                           g_documento.c24astcod    
   whenever error continue                                    
   fetch ccty45g00008 into lr_retorno.motivo
   whenever error stop            
   
   

   #-----------------------------------
   # Verifica se Ligacao ja tem Motivo
   #-----------------------------------
   
   open  ccty45g00009 using g_documento.lignum
                           ,lr_param.rcuccsmtvcod
                           ,g_documento.c24astcod
   fetch ccty45g00009

   #------------------------
   # Se Nao Achou Registro
   #------------------------
   if sqlca.sqlcode = 100 then

      #-------------------------------- 
      # Relaciona Motivo com a Ligacao  
      #-------------------------------- 
      
      whenever error continue        
         execute pcty45g00010 using g_documento.lignum
                                   ,lr_param.rcuccsmtvcod
                                   ,g_documento.c24astcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error " Erro (",sqlca.sqlcode,") na inclusao da",
               " tabela datrligrcuccsmtv (1). AVISE A INFORMATICA!" sleep 1
      end if
   end if


   #---------------------------------
   # Chama Historico para Registro
   #---------------------------------
   call cta03n00(g_documento.lignum
                ,g_issk.funmat
                ,lr_retorno.data
                ,lr_retorno.hora)


   #------------------------------------------------
   # Grava Automaticamente o Motivo 6 no Historico
   #------------------------------------------------
   
   for lr_retorno.cont = 1 to 2

       if lr_retorno.cont = 1 then
          let lr_retorno.texto = "Motivo de Abandono do Laudo: "
       else
          let lr_retorno.texto = lr_retorno.motivo
       end if

       call ctd06g01_ins_datmlighist(g_documento.lignum
                                    ,g_issk.funmat
                                    ,lr_retorno.texto
                                    ,lr_param.atddat
                                    ,lr_param.atdhor
                                    ,g_issk.usrtip
                                    ,g_issk.empcod)
       returning lr_retorno.ret  
                ,lr_retorno.mensagem
   
   end for


end function

#-------------------------------------------------------#                  
 function cty45g00_verifica_data_marrom(lr_param)                    
#-------------------------------------------------------#                  
                                                                     
define lr_param record                                               
  incvigdat     like datmresitaapl.incvigdat                   
end record                                                           
                                                                     
define lr_retorno record                                             
  data       date,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_data"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica a Data de Corte do Linha Marrom                              
    #--------------------------------------------------------        
                                                                     
    open ccty45g00012  using  lr_retorno.chave                   
                                       
    whenever error continue                                          
    fetch ccty45g00012 into lr_retorno.data                       
    whenever error stop                                              
                                                                     
    if lr_param.incvigdat >=  lr_retorno.data   then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function 

#-------------------------------------------------#                  
 function cty45g00_verifica_plano_marrom(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  srvcod     like datmresitaaplitm.srvcod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_plano"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Plano Bloqueia Linha Marrom                             
    #--------------------------------------------------------        
                                                                     
    open ccty45g00011  using  lr_retorno.chave  ,                  
                                lr_param.srvcod                
    whenever error continue                                          
    fetch ccty45g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function

#----------------------------------------------------#                  
 function cty45g00_verifica_produto_marrom(lr_param)                    
#----------------------------------------------------#                  
                                                                     
define lr_param record                                               
  prdcod     like datmresitaaplitm.prdcod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_prod"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Produto Bloqueia Linha Marrom                             
    #--------------------------------------------------------        
                                                                     
    open ccty45g00011  using  lr_retorno.chave  ,                  
                                lr_param.prdcod                
    whenever error continue                                          
    fetch ccty45g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function   

#----------------------------------------------------#                  
 function cty45g00_verifica_assunto_marrom(lr_param)                    
#----------------------------------------------------#                  
                                                                     
define lr_param record                                               
  c24astcod     like datkassunto.c24astcod                           
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_ass"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Assunto e Linha Marrom                             
    #--------------------------------------------------------        
                                                                     
    open ccty45g00011  using  lr_retorno.chave  ,                  
                                lr_param.c24astcod                 
    whenever error continue                                          
    fetch ccty45g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function

#----------------------------------------------------#                               
 function cty45g00_bloqueia_linha_marrom(lr_param)                                   
#----------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 c24astcod        like datkassunto.c24astcod       ,
 	 prdcod           like datmresitaaplitm.prdcod     ,
 	 srvcod           like datmresitaaplitm.srvcod     ,                                                                       
   incvigdat        like datmresitaapl.incvigdat                             
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty45g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty45g00_verifica_assunto_marrom(lr_param.c24astcod) and
 	  cty45g00_verifica_produto_marrom(lr_param.prdcod)    and
 	  cty45g00_verifica_plano_marrom(lr_param.srvcod)      and
 	  cty45g00_verifica_data_marrom(lr_param.incvigdat)    then                              
        return true                                                             
 else                                                                             
        return false         
 end if                                                                  
                                                                                   
                                                                                   
end function  

#----------------------------------------------------#                               
 function cty45g00_bloqueia_extrato_marrom(lr_param)                                   
#----------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 prdcod           like datmresitaaplitm.prdcod     ,
 	 srvcod           like datmresitaaplitm.srvcod     ,                                                                       
   incvigdat        like datmresitaapl.incvigdat                             
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty45g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty45g00_verifica_produto_marrom(lr_param.prdcod)    and
 	  cty45g00_verifica_plano_marrom(lr_param.srvcod)      and
 	  cty45g00_verifica_data_marrom(lr_param.incvigdat)    then                              
        return true                                                             
 else                                                                             
        return false         
 end if                                                                  
                                                                                   
                                                                                   
end function

#----------------------------------------------------#                  
 function cty45g00_verifica_assunto_help(lr_param)                    
#----------------------------------------------------#                  
                                                                     
define lr_param record                                               
  c24astcod     like datkassunto.c24astcod                           
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_ass1"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Assunto e Help Desk                           
    #--------------------------------------------------------        
                                                                     
    open ccty45g00011  using  lr_retorno.chave  ,                  
                               lr_param.c24astcod                 
    whenever error continue                                          
    fetch ccty45g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function

#-------------------------------------------------------#                  
 function cty45g00_verifica_data_help(lr_param)                    
#-------------------------------------------------------#                  
                                                                     
define lr_param record                                               
  incvigdat     like datmresitaapl.incvigdat                   
end record                                                           
                                                                     
define lr_retorno record                                             
  data       date,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_data1"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica a Data de Corte do Help Desk                              
    #--------------------------------------------------------        
                                                                     
    open ccty45g00012  using  lr_retorno.chave                   
                                       
    whenever error continue                                          
    fetch ccty45g00012 into lr_retorno.data                       
    whenever error stop                                              
                                                                     
    if lr_param.incvigdat >=  lr_retorno.data   then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function 

#----------------------------------------------------#                  
 function cty45g00_verifica_produto_help(lr_param)                    
#----------------------------------------------------#                  
                                                                     
define lr_param record                                               
  prdcod     like datmresitaaplitm.prdcod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record    

if m_prepare is null or
   m_prepare <> true then
   call cty45g00_prepare()
end if


                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty45g00_prod1"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Produto tem Help Desk                             
    #--------------------------------------------------------        
                                                                     
    open ccty45g00011  using  lr_retorno.chave  ,                  
                              lr_param.prdcod                
    whenever error continue                                          
    fetch ccty45g00011 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function 

#----------------------------------------------------#                               
 function cty45g00_acessa_help_desk(lr_param)                                   
#----------------------------------------------------#                               
                                                                                   
 define lr_param record     
 	 c24astcod        like datkassunto.c24astcod       ,
 	 prdcod           like datmresitaaplitm.prdcod     ,                                                                      
   incvigdat        like datmresitaapl.incvigdat                             
 end record                                                                        
                                                                                   
                                                                                                                                        
 if m_prepare is null or                                                           
    m_prepare <> true then                                                         
    call cty45g00_prepare()                                                        
 end if                                                                            
                                                                                   
                                                                                   
                                                                                                                                                                                                                                                                                                       
 if cty45g00_verifica_assunto_help(lr_param.c24astcod) then
 	
 	  if cty45g00_verifica_produto_help(lr_param.prdcod)    and
 	     cty45g00_verifica_data_help(lr_param.incvigdat)    then                              
        return true                                                             
    else                                                                             
        return false         
    end if
 
 end if
 
 return true                                                                  
                                                                                   
                                                                                   
end function    
                                                                    