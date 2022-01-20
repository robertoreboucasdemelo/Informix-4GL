###########################################################################
# Nome do Modulo: ctc95m00                            Anderson Doblinski  #
#                                                                         #
# Cadastro de Login Azul                                         Jan/2012 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"

	 define m_prep     smallint

   define a_ctc95m00 record
       azlsinlgicod  like   datkpsgfunmatadoaz.azlsinlgicod
      ,psgusrtipcod  like   datkpsgfunmatadoaz.psgusrtipcod
      ,psgempcod     like   datkpsgfunmatadoaz.psgempcod
      ,psgmatcod     like   datkpsgfunmatadoaz.psgmatcod
      ,rspfunnom     like   isskfunc.funnom
      ,atoflg        like   datkpsgfunmatadoaz.atoflg
      ,atlusrtipcod  like   datkpsgfunmatadoaz.atlusrtipcod
      ,atlempcod     like   datkpsgfunmatadoaz.atlempcod
      ,atlmatcod     like   datkpsgfunmatadoaz.atlmatcod
      ,atldat        like   datkpsgfunmatadoaz.atldat 
      ,atlfunnom     like   isskfunc.funnom 
   end record
   
   define teste      char(1)

#===============================================================================
 function ctc95m00_prepare()
#===============================================================================

	define l_sql char(5000)
	
	let l_sql = "INSERT INTO datkpsgfunmatadoaz ",
						  " (azlsinlgicod, psgusrtipcod, psgempcod, psgmatcod, atoflg, atlusrtipcod, ",
						  " atlempcod, atlmatcod, atldat) ",
						  " VALUES (?, ?, ?, ?, ?, ?, ?, ?, today) "
	prepare p_ctc95m00_001 from l_sql
	
	let l_sql = "UPDATE datkpsgfunmatadoaz ",
						"SET psgusrtipcod    =   ? ",
						"   ,psgempcod       =   ? ",
						"   ,psgmatcod       =   ? ",
						"   ,atoflg          =   ? ",
						"   ,atlusrtipcod    =   ? ",
						"   ,atlempcod       =   ? ",
						"   ,atlmatcod       =   ? ",
						"   ,atldat          =   today ",
						"WHERE azlsinlgicod  =   ? "
	prepare p_ctc95m00_002 from l_sql
	
	let l_sql = "SELECT  azlsinlgicod   ,psgusrtipcod   ,psgempcod      ,psgmatcod ",
               "      ,C.funnom       ,atoflg         ,atldat         ,B.funnom ",
               "FROM datkpsgfunmatadoaz A ",
               "LEFT JOIN isskfunc B ",
               "   ON A.atlusrtipcod = B.usrtip ",
               "  AND A.atlempcod    = B.empcod ",
               "  AND A.atlmatcod    = B.funmat ",
               "LEFT JOIN isskfunc C ",
               "   ON A.psgusrtipcod = C.usrtip ",
               "  AND A.psgempcod = C.empcod ",
               "  AND A.psgmatcod = C.funmat ",
               "WHERE azlsinlgicod = ? "
   prepare p_ctc95m00_003 from l_sql
   declare c_ctc95m00_003 cursor for p_ctc95m00_003
   
   let l_sql = "SELECT min(azlsinlgicod)  "
           , "  FROM datkpsgfunmatadoaz   "
           , "  WHERE azlsinlgicod  >  ? "
  prepare p_ctc95m00_004 from l_sql
  declare c_ctc95m00_004 cursor for p_ctc95m00_004
 
  let l_sql = " SELECT max(azlsinlgicod)  "
           ,"   FROM datkpsgfunmatadoaz   "
           , "  WHERE azlsinlgicod  <  ? "
  prepare p_ctc95m00_005 from l_sql
  declare c_ctc95m00_005 cursor for p_ctc95m00_005
  
  let l_sql = "SELECT funnom    ",
               "FROM isskfunc    ",
               "WHERE usrtip = ? ",
               "AND   empcod = ? ",
               "AND   funmat = ? "
   prepare p_ctc95m00_006 from l_sql
   declare c_ctc95m00_006 cursor for p_ctc95m00_006	
   
   let l_sql = "SELECT azlsinlgicod  "
           ,"   FROM datkpsgfunmatadoaz   "
           , "  WHERE azlsinlgicod  =  ? "
  prepare p_ctc95m00_007 from l_sql
  declare c_ctc95m00_007 cursor for p_ctc95m00_007
  
   let l_sql = "SELECT  azlsinlgicod   ,psgusrtipcod   ,psgempcod      ,psgmatcod ",
               "       ,C.funnom       ,atoflg         ,atldat         ,B.funnom ",
              "   FROM datkpsgfunmatadoaz  A ",
              " LEFT JOIN isskfunc B ",
              "   ON A.atlusrtipcod = B.usrtip ",
              "  AND A.atlempcod    = B.empcod ",
              "  AND A.atlmatcod    = B.funmat ",
              "LEFT JOIN isskfunc C ",
              "   ON A.psgusrtipcod = C.usrtip ",
              "  AND A.psgempcod = C.empcod ",
              "  AND A.psgmatcod = C.funmat ",
              "  WHERE psgempcod     =  ?   ",
              "  AND   psgmatcod     =  ?   "
  prepare p_ctc95m00_008 from l_sql
  declare c_ctc95m00_008 cursor for p_ctc95m00_008
  
#===============================================================================
end function # Fim da ctc95m00_prepare
#===============================================================================

#===============================================================================
 function ctc95m00()
#===============================================================================

	let int_flag = false
  initialize a_ctc95m00.* to null
  
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
   #  let g_issk.funmat = 13896
   #  let g_issk.empcod = 1
   #  let g_issk.usrtip = 'F'
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
  
  if m_prep = false or
     m_prep is null then
     call ctc95m00_prepare()
   end if
  
  open window w_ctc95m00 at 4,2 with form "ctc95m00"
  
  menu "Func. Azul"

      command key ("S") "Seleciona"
                        "Pesquisa funcionario conforme criterios"
         call ctc95m00_seleciona()
         if a_ctc95m00.azlsinlgicod is not null  then
            next option "Proximo"
         else
            next option "Seleciona"
         end if
         message " (F17)Abandona"


      command key ("P") "Proximo"
                        "Mostra o proximo funcionario"
         call ctc95m00_proximo()
         message " (F17)Abandona"

      command key ("A") "Anterior"
                        "Mostra o funcionario anterior"
         call ctc95m00_anterior()
         message " (F17)Abandona"

			{command key ("B") "Busca"
                        "Busca um funcionario determinado"
                        message " (F17)Abandona      (F8)Seleciona Login Azul"
         call ctc93m01()
         returning a_ctc95m00.azlsinlgicod
                        
         call ctc95m00_busca()
         if a_ctc95m00.azlsinlgicod is not null  then
            next option "Modifica"
         else
            error " Nenhum Funcionario selecionado!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"}
         

      command key ("M") "Modifica"
                        "Modifica o funcionario selecionado"
         if not (a_ctc95m00.azlsinlgicod is null or a_ctc95m00.azlsinlgicod = " ") then
            call ctc95m00_input("c")
         else
            error "Nenhum funcionario selecionado!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"


      command key ("I") "Inclui"
                        "Inclui um funcionaro"
         message " (F17)Abandona"
         initialize a_ctc95m00.* to null
         display by name a_ctc95m00.azlsinlgicod
                        ,a_ctc95m00.psgusrtipcod
                        ,a_ctc95m00.psgempcod
                        ,a_ctc95m00.psgmatcod
                        ,a_ctc95m00.rspfunnom
                        ,a_ctc95m00.atoflg
                        ,a_ctc95m00.atldat
                        ,a_ctc95m00.atlfunnom
         call ctc95m00_input("i")
         next option "Modifica"



      command key (interrupt,E) "Encerra"
                                "Retorna ao menu anterior"
         exit menu

   end menu
  
  close window w_ctc95m00

#===============================================================================
end function  # Fim da ctc95m00
#===============================================================================

#===============================================================================
 function ctc95m00_proximo()
#===============================================================================

	define l_cod like datkpsgfunmatadoaz.azlsinlgicod

	let int_flag = false
	
	if a_ctc95m00.azlsinlgicod = " " or
     a_ctc95m00.azlsinlgicod is null then
     let a_ctc95m00.azlsinlgicod = 0
  end if
  
  let l_cod = a_ctc95m00.azlsinlgicod
  
  whenever error continue
  	 open c_ctc95m00_004 using a_ctc95m00.azlsinlgicod
  	 fetch c_ctc95m00_004 into a_ctc95m00.azlsinlgicod
  	 close c_ctc95m00_004
  whenever error continue
  call ctc95m00_preencher()
  
  if a_ctc95m00.azlsinlgicod is null or	
     a_ctc95m00.azlsinlgicod = " " then
     let a_ctc95m00.azlsinlgicod = l_cod
     call ctc95m00_preencher()
     error " Nao existe funcionario nesta direcao!"
  end if

#===============================================================================
 end function  # Fim da funcao ctc95m00_proximo
#===============================================================================

#===============================================================================
 function ctc95m00_anterior()
#===============================================================================
 
	define l_cod like datkpsgfunmatadoaz.azlsinlgicod

	let int_flag = false
	
	if a_ctc95m00.azlsinlgicod = " " or
     a_ctc95m00.azlsinlgicod is null then
     let a_ctc95m00.azlsinlgicod = 0
  end if
  
  let l_cod = a_ctc95m00.azlsinlgicod
  
  whenever error continue
  	 open c_ctc95m00_005 using a_ctc95m00.azlsinlgicod
  	 fetch c_ctc95m00_005 into a_ctc95m00.azlsinlgicod
  	 close c_ctc95m00_005
  whenever error stop
  call ctc95m00_preencher()
  
  if a_ctc95m00.azlsinlgicod is null or		
     a_ctc95m00.azlsinlgicod = " " then
     let a_ctc95m00.azlsinlgicod = l_cod
     call ctc95m00_preencher()
     error " Nao existe funcionario nesta direcao!"
  end if 
 
#===============================================================================
 end function  # Fim da funcao ctc95m00_anterior
#===============================================================================

#===============================================================================
 function ctc95m00_seleciona()
#===============================================================================
	define l_flg_ok char(1)

	let int_flag = false

  initialize a_ctc95m00.* to null
  display by name a_ctc95m00.azlsinlgicod
                 ,a_ctc95m00.psgusrtipcod
                 ,a_ctc95m00.psgempcod
                 ,a_ctc95m00.psgmatcod
                 ,a_ctc95m00.rspfunnom
                 ,a_ctc95m00.atoflg
                 ,a_ctc95m00.atldat
                 ,a_ctc95m00.atlfunnom

  input by name a_ctc95m00.azlsinlgicod 
               ,a_ctc95m00.psgempcod
               ,a_ctc95m00.psgmatcod
                without defaults
  
  	#--------------------
     before field azlsinlgicod
    #--------------------
     display by name a_ctc95m00.azlsinlgicod attribute(reverse)
     
    #--------------------
     after field azlsinlgicod
    #--------------------     
     display by name a_ctc95m00.azlsinlgicod attribute(normal)
     
     if a_ctc95m00.azlsinlgicod is not null then
        call ctc95m00_preencher()
        
        if a_ctc95m00.azlsinlgicod = " "   or
           a_ctc95m00.psgusrtipcod is null or 
           a_ctc95m00.psgusrtipcod = " "   then
						
					 let a_ctc95m00.azlsinlgicod = " "	
					
           call cts08g01("A", "N",
                         " ",
                         "FUNCIONARIO NAO ENCONTRADO",
                         "DIGITE UM CODIGO VALIDO.",
                         " ")
           returning l_flg_ok

           initialize a_ctc95m00.* to null
           display by name a_ctc95m00.azlsinlgicod
                          ,a_ctc95m00.psgusrtipcod
                          ,a_ctc95m00.psgempcod
                          ,a_ctc95m00.psgmatcod
                          ,a_ctc95m00.rspfunnom
                          ,a_ctc95m00.atoflg
                          ,a_ctc95m00.atldat
                          ,a_ctc95m00.atlfunnom
           exit input           
        else 
           exit input
        end if
     
     end if
     
    #--------------------
     before field psgempcod
    #--------------------
      display by name a_ctc95m00.psgempcod attribute(reverse)
    
    #--------------------
     after field psgempcod
    #--------------------
      display by name a_ctc95m00.psgempcod attribute(normal)
      
    #--------------------
     before field psgmatcod
    #--------------------
      display by name a_ctc95m00.psgmatcod attribute(reverse)
    
    #--------------------
     after field psgmatcod
    #--------------------
      display by name a_ctc95m00.psgmatcod attribute(normal)
      
      if a_ctc95m00.psgempcod is not null and
         a_ctc95m00.psgmatcod is null then
         error "Preenchimento obrigatorio da matricula"
         next field psgmatcod
      end if   
      
      if a_ctc95m00.psgmatcod is null then  
         next field azlsinlgicod
      end if 
      
      if a_ctc95m00.psgmatcod is not null then
         call ctc95m00_preencher()
        
         if a_ctc95m00.psgmatcod = " "   or
            a_ctc95m00.psgusrtipcod is null or 
            a_ctc95m00.psgusrtipcod = " "   then
						
					  let a_ctc95m00.psgmatcod = " "	
					  let a_ctc95m00.psgempcod = " "	
					
            call cts08g01("A", "N",
                          " ",
                          "FUNCIONARIO NAO ENCONTRADO",
                          "DIGITE UM CODIGO VALIDO.",
                          " ")
                 returning l_flg_ok

            initialize a_ctc95m00.* to null
            display by name a_ctc95m00.azlsinlgicod
                           ,a_ctc95m00.psgusrtipcod
                           ,a_ctc95m00.psgempcod
                           ,a_ctc95m00.psgmatcod
                           ,a_ctc95m00.rspfunnom
                           ,a_ctc95m00.atoflg
                           ,a_ctc95m00.atldat
                           ,a_ctc95m00.atlfunnom
            exit input           
         else 
            exit input
         end if
     
      end if
     
     #--------------------
      on key (interrupt)
     #--------------------
         exit input

   end input
   
   if int_flag  then
      let int_flag = false
      initialize a_ctc95m00.* to null
      display by name a_ctc95m00.azlsinlgicod
                     ,a_ctc95m00.psgusrtipcod
                     ,a_ctc95m00.psgempcod
                     ,a_ctc95m00.psgmatcod
                     ,a_ctc95m00.rspfunnom
                     ,a_ctc95m00.atoflg
                     ,a_ctc95m00.atldat
                     ,a_ctc95m00.atlfunnom
      error " Operacao cancelada!"
   end if
   
#===============================================================================
 end function  # Fim da funcao ctc95m00_seleciona
#===============================================================================

#===============================================================================
 function ctc95m00_input(lr_param)
#===============================================================================

	define l_cod like datkpsgfunmatadoaz.azlsinlgicod

	define lr_param record
      operacao char(1)
  end record
   
  define l_operacao char(1)
  
  if lr_param.operacao = " " or
     lr_param.operacao is null then
     let l_operacao = "c"
  else
     let l_operacao = lr_param.operacao
  end if

	input by name a_ctc95m00.azlsinlgicod
							 ,a_ctc95m00.atoflg 
               ,a_ctc95m00.psgusrtipcod
               ,a_ctc95m00.psgempcod
               ,a_ctc95m00.psgmatcod
               ,teste
  without defaults
	
		#--------------------
   	 before field azlsinlgicod
  	#--------------------
  	 if l_operacao = "c" then
        next field next
     else
        display by name a_ctc95m00.azlsinlgicod attribute(reverse)
     end if
     
    #--------------------
   	 after field azlsinlgicod
  	#--------------------
  		if a_ctc95m00.azlsinlgicod is null or
  		   a_ctc95m00.azlsinlgicod = " " then
  		   error "Preenchimento obrigatorio do Codigo"
  		   next field azlsinlgicod
  	  end if
  		display by name a_ctc95m00.azlsinlgicod attribute(normal)
  		
  		open c_ctc95m00_007 using a_ctc95m00.azlsinlgicod
  		fetch c_ctc95m00_007 into l_cod
  		
  		if(l_cod = a_ctc95m00.azlsinlgicod) then
  			let a_ctc95m00.azlsinlgicod = " "
  			error "Codigo ja existente"
  			next field azlsinlgicod
  		end if
  		
    #--------------------
   	 before field atoflg 
  	#--------------------
  		display by name a_ctc95m00.atoflg  attribute(reverse)
  		
  	#--------------------
   	 after field atoflg 
  	#--------------------
  		if fgl_lastkey() <> fgl_keyval("up") and     
         fgl_lastkey() <> fgl_keyval("left") then
  			 if a_ctc95m00.atoflg is null or
            a_ctc95m00.atoflg = " " then
            error " Preenchimento obrigatorio se o Funcionario Ativo ou nao."
            next field atoflg 
         end if
      end if
      
      if a_ctc95m00.atoflg <> "S" and a_ctc95m00.atoflg <> "N" then               
         error " Preencha apenas S ou N."
         let a_ctc95m00.atoflg = " "
         next field atoflg
      end if
      
      display by name a_ctc95m00.atoflg  attribute(normal)
  		
  	#--------------------
   	 before field psgusrtipcod
  	#--------------------
  		display by name a_ctc95m00.psgusrtipcod attribute(reverse)
  		
  	#--------------------
   	 after field psgusrtipcod
  	#--------------------
  	  if fgl_lastkey() <> fgl_keyval("up") and     
         fgl_lastkey() <> fgl_keyval("left") then
  		   if a_ctc95m00.psgusrtipcod is null or
            a_ctc95m00.psgusrtipcod = " " then
            error " Preenchimento obrigatorio do Tipo de Usuario do Responsavel."
            next field psgusrtipcod
         end if
      end if
      display by name a_ctc95m00.psgusrtipcod attribute(normal)
      
    #--------------------
   	 before field psgempcod
  	#--------------------
  		display by name a_ctc95m00.psgempcod attribute(reverse)
  		
  	#--------------------
   	 after field psgempcod
  	#--------------------
  	  if fgl_lastkey() <> fgl_keyval("up") and     
         fgl_lastkey() <> fgl_keyval("left") then
  		   if a_ctc95m00.psgempcod is null or
            a_ctc95m00.psgempcod = " " then
            error " Preenchimento obrigatorio do Codigo da Empresa."
            next field psgempcod
         end if
      end if
      display by name a_ctc95m00.psgempcod attribute(normal)
      
    #--------------------
   	 before field psgmatcod 
  	#--------------------
  		display by name a_ctc95m00.psgmatcod  attribute(reverse)
  		
  	#--------------------
   	 after field psgmatcod 
  	#--------------------
  	  if fgl_lastkey() <> fgl_keyval("up") and     
         fgl_lastkey() <> fgl_keyval("left") then
  		   if a_ctc95m00.psgmatcod is null or
            a_ctc95m00.psgmatcod = " " then
            error " Preenchimento obrigatorio Matricula do Funcionario."
            next field C 
         end if
      end if
      display by name a_ctc95m00.psgmatcod  attribute(normal)
      
      whenever error continue
      open c_ctc95m00_006 using a_ctc95m00.psgusrtipcod
                               ,a_ctc95m00.psgempcod
                               ,a_ctc95m00.psgmatcod
      fetch c_ctc95m00_006 into a_ctc95m00.rspfunnom
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
       	 let a_ctc95m00.psgmatcod = " "
       	 let a_ctc95m00.rspfunnom = " "
       	 display by name a_ctc95m00.psgmatcod
       	                ,a_ctc95m00.rspfunnom
         error "Coloque uma Matricula Valida"
         next field psgmatcod
      end if
      
      display by name a_ctc95m00.rspfunnom
      
    #--------------------
   	 before field teste 
  	#--------------------
  		display by name teste  attribute(reverse)
  		
    #--------------------
   	 after field teste 
  	#--------------------
  		let teste = " "
  		display by name teste  attribute(normal)
  		
      if fgl_lastkey() <> fgl_keyval("up") and     
         fgl_lastkey() <> fgl_keyval("left") then
    	 	 if l_operacao = "c" then
            if ctc95m00_modificar() then
               let int_flag = true
            end if
            exit input
         else
            if ctc95m00_incluir() then
               let int_flag = true
            end if
            exit input
         end if
      end if
           
  	#--------------------
     on key (interrupt, control-c)
    #--------------------
     initialize a_ctc95m00.* to null
     display by name a_ctc95m00.azlsinlgicod
                    ,a_ctc95m00.psgusrtipcod
                    ,a_ctc95m00.psgempcod
                    ,a_ctc95m00.psgmatcod
                    ,a_ctc95m00.rspfunnom
                    ,a_ctc95m00.atoflg
                    ,a_ctc95m00.atldat
                    ,a_ctc95m00.atlfunnom
     let int_flag = true
     exit input

  end input
  		   
  let int_flag = false

#===============================================================================
 end function  # Fim da funcao ctc95m00_input
#===============================================================================

#===============================================================================
 function ctc95m00_preencher()
#===============================================================================

  if a_ctc95m00.azlsinlgicod is not null then

	   whenever error continue
	   open c_ctc95m00_003 using a_ctc95m00.azlsinlgicod
	   fetch c_ctc95m00_003 into a_ctc95m00.azlsinlgicod
													    ,a_ctc95m00.psgusrtipcod
                              ,a_ctc95m00.psgempcod
                              ,a_ctc95m00.psgmatcod
                              ,a_ctc95m00.rspfunnom
                              ,a_ctc95m00.atoflg
                              ,a_ctc95m00.atldat
                              ,a_ctc95m00.atlfunnom
     close c_ctc95m00_003
     whenever error stop
  
     if sqlca.sqlcode <> 0 then
  			let a_ctc95m00.azlsinlgicod = " "
     end if
  
  else
  
      whenever error continue
      open c_ctc95m00_008 using a_ctc95m00.psgempcod
                               ,a_ctc95m00.psgmatcod
      fetch c_ctc95m00_008 into a_ctc95m00.azlsinlgicod
													     ,a_ctc95m00.psgusrtipcod
                               ,a_ctc95m00.psgempcod
                               ,a_ctc95m00.psgmatcod
                               ,a_ctc95m00.rspfunnom
                               ,a_ctc95m00.atoflg
                               ,a_ctc95m00.atldat
                               ,a_ctc95m00.atlfunnom                         
      close c_ctc95m00_008
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
  			let a_ctc95m00.psgempcod = " "
        let a_ctc95m00.psgmatcod = " "
      end if
  
  end if
 
  display by name a_ctc95m00.azlsinlgicod
                 ,a_ctc95m00.psgusrtipcod
                 ,a_ctc95m00.psgempcod
                 ,a_ctc95m00.psgmatcod
                 ,a_ctc95m00.rspfunnom
                 ,a_ctc95m00.atoflg
                 ,a_ctc95m00.atldat
                 ,a_ctc95m00.atlfunnom
  
#===============================================================================
 end function  # Fim da funcao ctc95m00_preencher
#===============================================================================

#===============================================================================
 function ctc95m00_incluir()
#===============================================================================

	define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA INCLUSAO",
                 "DO FUNCIONARIO ?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."
      
      whenever error continue
      execute  p_ctc95m00_001 using a_ctc95m00.azlsinlgicod
                                   ,a_ctc95m00.psgusrtipcod
                                   ,a_ctc95m00.psgempcod
                                   ,a_ctc95m00.psgmatcod
                                   ,a_ctc95m00.atoflg
                                   ,g_issk.usrtip
                                   ,g_issk.empcod
                                   ,g_issk.funmat
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao incluir. Tabela <datkpsgfunmatadoaz>."
         sleep 3
         return false
      end if

      error "Inclusao realizada com sucesso."
   else
   		initialize a_ctc95m00.* to null
      display by name a_ctc95m00.azlsinlgicod
                     ,a_ctc95m00.psgusrtipcod
                     ,a_ctc95m00.psgempcod
                     ,a_ctc95m00.psgmatcod
                     ,a_ctc95m00.rspfunnom
                     ,a_ctc95m00.atoflg
                     ,a_ctc95m00.atldat
                     ,a_ctc95m00.atlfunnom
      return false
   end if

   return true
#===============================================================================
 end function # Fim da funcao ctc95m00_incluir
#===============================================================================

#===============================================================================
 function ctc95m00_modificar()
#===============================================================================

	define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA ALTERACAO",
                 "DO FUNCIONARIO SELECIONADO?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      whenever error continue
      execute p_ctc95m00_002 using a_ctc95m00.psgusrtipcod
                                  ,a_ctc95m00.psgempcod
                                  ,a_ctc95m00.psgmatcod
                                  ,a_ctc95m00.atoflg
                                  ,g_issk.usrtip
                                  ,g_issk.empcod
                                  ,g_issk.funmat
                                  ,a_ctc95m00.azlsinlgicod
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao atualizar. Tabela <datkpsgfunmatadoaz>."
         sleep 3
         return false
      end if

      error "Alteracao realizada com sucesso."
   else
   	  initialize a_ctc95m00.* to null
      display by name a_ctc95m00.azlsinlgicod
                     ,a_ctc95m00.psgusrtipcod
                     ,a_ctc95m00.psgempcod
                     ,a_ctc95m00.psgmatcod
                     ,a_ctc95m00.rspfunnom
                     ,a_ctc95m00.atoflg
                     ,a_ctc95m00.atldat
                     ,a_ctc95m00.atlfunnom
      return false
   end if

   return true
#===============================================================================
 end function  # Fim da funcao ctc95m00_modificar
#===============================================================================

#===============================================================================
 function ctc95m00_busca()
#===============================================================================
   define l_flg_ok char(1)
   define l_count  smallint

   let int_flag = false

   call ctc95m00_preencher()

   display by name a_ctc95m00.azlsinlgicod attribute(normal)

   if a_ctc95m00.azlsinlgicod = " " or
      a_ctc95m00.psgusrtipcod is null or
      a_ctc95m00.psgusrtipcod = " " then

      call cts08g01("A", "N",
                    " ",
                    "FUNCIONARIO NAO ENCONTRADO.",
                    "SELECIONE UM FUNCIONARIO VALIDO.",
                    " ")
      returning l_flg_ok

      initialize a_ctc95m00.* to null
      display by name a_ctc95m00.azlsinlgicod
                     ,a_ctc95m00.psgusrtipcod
                     ,a_ctc95m00.psgempcod
                     ,a_ctc95m00.psgmatcod
                     ,a_ctc95m00.rspfunnom
                     ,a_ctc95m00.atoflg
                     ,a_ctc95m00.atldat
                     ,a_ctc95m00.atlfunnom
      end if

#===============================================================================
 end function  # Fim da funcao ctc95m00_busca
#===============================================================================