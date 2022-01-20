###############################################################################
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema       : Ct24h                                                       #
# Modulo        : ctc17m01                                                    #
# Analista Resp.: Ligia Mattge                                                #
# PSI           : 191108                                                      #
# Objetivo      : Cadastro dos departamentos da via emergencial               #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      : 18/05/2005                                                 #
#.............................................................................#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
#                                                                             #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl" 

define mr_ctc17m0101  record
   dptcod             like datmemeviadpt.dptcod
  ,dptnom             char(40)
  ,dptsit             like datmemeviadpt.dptsit
  ,dptsitdes          char(10)
  ,caddat             like datmemeviadpt.caddat 
  ,cademp             like datmemeviadpt.cademp 
  ,cadmat             like datmemeviadpt.cadmat 
  ,funnomcad          char(20)
  ,atldat             like datmemeviadpt.atldat
  ,atlmat             like datmemeviadpt.atlmat
  ,funnomatl          char(20) 
  ,atlemp             like datmemeviadpt.atlemp
end record 

define mr_ctc17m0102   record
   emeviacod           like datmemeviadpt.emeviacod   
  ,emeviades           char(20) 
end record 

define m_prep    char(01)
define m_flags   char(01)
define m_pagina  smallint 
define m_open    char(01) 

#-------------------------------------------------------------------------------
function ctc17m01_prepare() 
#-------------------------------------------------------------------------------

define l_sql    char(1000) 

   let l_sql = " insert into datmemeviadpt (dptcod    "
              ,"                           ,dptsit    "
              ,"                           ,caddat    "
              ,"                           ,cademp    "
              ,"                           ,cadmat    "
              ,"                           ,atldat    "
              ,"                           ,atlmat    "
              ,"                           ,emeviacod "
              ,"                           ,atlemp)   " 
	      ," values(?,?,?,?,?,?,?,?,?)            " 
   prepare pctc17m01001 from l_sql 

   let l_sql = " update datmemeviadpt "
	      ,"    set dptsit = ?    "
	      ,"       ,atldat = ?    "
	      ,"       ,atlemp = ?    "
	      ,"       ,atlmat = ?    "
	      ,"  where emeviacod = ? "
	      ,"    and dptcod = ?    " 
   prepare pctc17m01002 from l_sql 

   let l_sql = " delete from datmemeviadpt "
	      ,"  where emeviacod = ?      "
	      ,"    and dptcod = ?         " 
   prepare pctc17m01003 from l_sql 

   let l_sql = " select dptcod, dptsit, caddat, cademp "
	      ,"       ,cadmat, atldat, atlmat, atlemp "
	      ,"   from datmemeviadpt                  "
	      ,"  where emeviacod = ?                  "
	      ,"    and dptcod = ?                     " 
	      ," order by 1                            " 
   prepare pctc17m01004 from l_sql 
   declare cctc17m01004 scroll cursor for pctc17m01004 

   let l_sql = " select dptcod, dptsit, caddat, cademp "
	      ,"       ,cadmat, atldat, atlmat, atlemp "
	      ,"   from datmemeviadpt                  "
	      ,"  where emeviacod = ?                  "
	      ," order by 1                            " 
   prepare pctc17m01005 from l_sql 
   declare cctc17m01005 scroll cursor for pctc17m01005 

   let l_sql = " select count(*)      "
	      ,"   from datmemeviadpt "
	      ,"  where emeviacod = ? " 
   prepare pctc17m01006 from l_sql 
   declare cctc17m01006 cursor for pctc17m01006 
   
   let l_sql  = ' select 1 '
               ,'   from datmemeviadpt '
               ,'  where dptcod    = ? '
               ,'    and emeviacod = ? '
               
   prepare pctc17m01007 from l_sql                          
   declare cctc17m01007 cursor for pctc17m01007             

   let m_prep = "S" 

end function #ctc17m01_prepare 

#-------------------------------------------------------------------------------
function ctc17m01(lr_ctc17m0101)
#-------------------------------------------------------------------------------

define lr_ctc17m0101   record
   emeviacod           like datmemeviadpt.emeviacod   
  ,emeviades           char(20) 
end record 

   initialize mr_ctc17m0101 to null 

   let mr_ctc17m0102.emeviacod = lr_ctc17m0101.emeviacod
   let mr_ctc17m0102.emeviades = lr_ctc17m0101.emeviades 

   if m_prep is null or m_prep <> "S" then
      call ctc17m01_prepare()
   end if 

   open window w_ctc17m01 at 04,02 with form "ctc17m01"
      attribute(prompt line last, comment line last)

      display by name mr_ctc17m0102.emeviacod 
      display by name mr_ctc17m0102.emeviades 

      menu "DEPARTAMENTO"

	 command key("I") "Incluir" "Inclui departamento para a via"
	    clear form
	    display by name mr_ctc17m0102.emeviacod
	    display by name mr_ctc17m0102.emeviades 
	    call ctc17m01_incluir() 

	 command key("S") "Selecionar" "Seleciona um departamento"
	    clear form
	    display by name mr_ctc17m0102.emeviacod
	    display by name mr_ctc17m0102.emeviades 
	    let m_flags = "N"
	    call ctc17m01_selecionar() 
	    if m_flags <> "S" then
	       next option "Proximo" 
	    end if 

	 command key("P") "Proximo" "Exibe o proximo departamento"
	    if mr_ctc17m0101.dptcod is not null then
	       if m_flags <> "S" then
		  call ctc17m01_pagina(1) 
	       else
		  error "Nao existem registros nesta direcao!!"
		  next option "Selecionar" 
	       end if 
	    else
	       error "Departamento deve ser selecionado" 
	       next option "Selecionar" 
	    end if 

	 command key("A") "Anterior" "Exibe o departamento anterior"
	    if mr_ctc17m0101.dptcod is not null then
	       if m_flags <> "S" then
		  call ctc17m01_pagina(-1) 
	       else
		  error "Nao existem registros nesta direcao!!"
		  next option "Selecionar" 
	       end if 
	    else
	       error "Departamento deve ser selecionado" 
	       next option "Selecionar" 
	    end if 

	 command key("M") "Modificar" "Modifica o departamento"
	    if mr_ctc17m0101.dptcod is not null then 
	       call ctc17m01_modificar() 
	    else
	       error "Departamento deve ser selecionado"
	       next option "Selecionar" 
	    end if 

	 command key("E") "Excluir" "Exclui o departamento"
	    if mr_ctc17m0101.dptcod is not null then 
	       call ctc17m01_excluir() 
	    else
	       error "Departamento deve ser selecionado"
	    end if 
	    next option "Selecionar" 

	 command key("N") "eNcerrar" "Volta ao menu anterior"
	    exit menu 

      end menu 

   let int_flag = false 
   close window w_ctc17m01 

end function #ctc17m01 

#-------------------------------------------------------------------------------
function ctc17m01_incluir()
#-------------------------------------------------------------------------------

define l_incluir   char(01) 
define l_today     date
define l_result    smallint 
define l_msg       char(80)

   let l_today = today 
   let l_result = 0 
   let l_msg = "" 

   initialize mr_ctc17m0101 to null
   
   let l_incluir = ctc17m01_input("I") 

   if l_incluir = "S" then
      whenever error continue
	 execute pctc17m01001 using mr_ctc17m0101.dptcod
				   ,mr_ctc17m0101.dptsit
				   ,l_today
				   ,g_issk.empcod
				   ,g_issk.funmat
				   ,l_today
				   ,g_issk.funmat
				   ,mr_ctc17m0102.emeviacod 
				   ,g_issk.empcod 
      whenever error stop 
      if sqlca.sqlcode <> 0 then
	 error "Erro ",sqlca.sqlcode," na inclusao de datmemeviadpt."  sleep 2 
	 return 
      else
	 error "Inclusao efetuada com sucesso" 
      end if 
      
      call cty08g00_nome_func(g_issk.empcod
		  	     ,g_issk.funmat,"F") 
         returning l_result, l_msg, mr_ctc17m0101.funnomcad 
         
      if l_result <> 1 then
         error l_msg 
      end if 
      
      let mr_ctc17m0101.caddat = l_today 

      display by name mr_ctc17m0101.caddat
      display by name mr_ctc17m0101.funnomcad 
      display mr_ctc17m0101.caddat    to atldat
      display mr_ctc17m0101.funnomcad to funnomatl
   end if 

end function #ctc17m01_incluir 

#-------------------------------------------------------------------------------
function ctc17m01_modificar()
#-------------------------------------------------------------------------------

define l_atualizar   char(01) 
define l_today       date
define l_result    smallint 
define l_msg       char(80) 

   let l_today = today 

   let l_atualizar = ctc17m01_input("M") 

   if l_atualizar = "S" then
      whenever error continue
	 execute pctc17m01002 using mr_ctc17m0101.dptsit
				   ,l_today
				   ,g_issk.empcod
				   ,g_issk.funmat
				   ,mr_ctc17m0102.emeviacod 
				   ,mr_ctc17m0101.dptcod  
      whenever error stop 
      if sqlca.sqlcode = 0 then
         error 'Alteracao efetuada com sucesso ' 
         call cty08g00_nome_func(g_issk.empcod                 
                      	        ,g_issk.funmat,"F")              
            returning l_result, l_msg, mr_ctc17m0101.funnomatl 
            
         display l_today to atldat           
         display by name mr_ctc17m0101.funnomatl 
      else
	 if sqlca.sqlcode < 0 then
	    error "Erro ",sqlca.sqlcode," na atualizacao de datmemeviadpt."  sleep 2
	 end if 
      end if 
   end if 

end function #ctc17m01_modificar 

#-------------------------------------------------------------------------------
function ctc17m01_excluir() 
#-------------------------------------------------------------------------------

define l_resp     char(01) 

   prompt "Confirma a exclusao S/N ?"
      for l_resp

   if l_resp = "s" or
      l_resp = "S" then
      whenever error continue
	 execute pctc17m01003 using mr_ctc17m0102.emeviacod
				   ,mr_ctc17m0101.dptcod  
      whenever error stop 
      if sqlca.sqlcode <> 0 then
	 if sqlca.sqlcode < 0 then
	    error "Erro ",sqlca.sqlcode," na exclusao de datmemeviadpt." 
	    sleep 2
	 end if 
      else
	 clear form
	 display by name mr_ctc17m0102.emeviacod
	 display by name mr_ctc17m0102.emeviades 
	 initialize mr_ctc17m0101 to null
      end if 
   end if 

end function #ctc17m01_excluir 

#-------------------------------------------------------------------------------
function ctc17m01_pagina(l_indice)
#-------------------------------------------------------------------------------

define l_indice  smallint 
define l_result  smallint
define l_msg     char(80)

   let l_result = 0
   let l_msg = "" 

      whenever error continue
         fetch relative l_indice cctc17m01005 into mr_ctc17m0101.dptcod
			                          ,mr_ctc17m0101.dptsit
		                                  ,mr_ctc17m0101.caddat 
				                  ,mr_ctc17m0101.cademp
				                  ,mr_ctc17m0101.cadmat
				                  ,mr_ctc17m0101.atldat
				                  ,mr_ctc17m0101.atlmat 
				                  ,mr_ctc17m0101.atlemp 
      whenever error stop 
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro ",sqlca.sqlcode," em datmemeviadpt" 
	    sleep 2 
         end if 
         if sqlca.sqlcode = 100 then
	    error "Nao existem mais registros nessa direcao" 
         end if 
      end if 

   display by name mr_ctc17m0101.dptcod
   display by name mr_ctc17m0101.dptsit
   display by name mr_ctc17m0101.caddat
   display by name mr_ctc17m0101.atldat 

   case mr_ctc17m0101.dptsit
      when "A"
         let mr_ctc17m0101.dptsitdes = "Ativo" 
      when "C"
         let mr_ctc17m0101.dptsitdes = "Cancelado" 
   end case 

   display by name mr_ctc17m0101.dptsitdes 

   call cty08g00_descricao_depto(mr_ctc17m0101.dptcod)
      returning l_result, l_msg, mr_ctc17m0101.dptnom 
 
   if l_result <> 1 then
      error l_msg 
      sleep 2 
   end if 

   display by name mr_ctc17m0101.dptnom 

   let l_result = 0
   let l_msg = "" 
   call cty08g00_nome_func(mr_ctc17m0101.cademp
		  	  ,mr_ctc17m0101.cadmat,"F") 
      returning l_result, l_msg, mr_ctc17m0101.funnomcad 
         
   if l_result <> 1 then
      error l_msg 
      sleep 2
   end if 

   let l_result = 0
   let l_msg = "" 
   call cty08g00_nome_func(mr_ctc17m0101.atlemp
			  ,mr_ctc17m0101.atlmat,"F") 
      returning l_result, l_msg, mr_ctc17m0101.funnomatl 
        
   if l_result <> 1 then
      error l_msg 
      sleep 2
   end if 
  
   display by name mr_ctc17m0101.funnomcad
   display by name mr_ctc17m0101.funnomatl 
         
end function #ctc17m01_pagina 

#-------------------------------------------------------------------------------
function ctc17m01_selecionar()
#-------------------------------------------------------------------------------

define l_result     smallint 
define l_msg        char(80) 

   let l_result = 0
   let l_msg = "" 
                 
   initialize mr_ctc17m0101.* to null 
   
   input by name mr_ctc17m0101.dptcod without defaults 
      before field dptcod 
	 display by name mr_ctc17m0101.dptcod
	    attribute(reverse) 

      after field dptcod
	 display by name mr_ctc17m0101.dptcod 

	 if mr_ctc17m0101.dptcod is not null then
	    whenever error continue
	       open cctc17m01004 using mr_ctc17m0102.emeviacod
				      ,mr_ctc17m0101.dptcod 
	       fetch cctc17m01004 into mr_ctc17m0101.dptcod
				      ,mr_ctc17m0101.dptsit
				      ,mr_ctc17m0101.caddat 
				      ,mr_ctc17m0101.cademp
				      ,mr_ctc17m0101.cadmat
				      ,mr_ctc17m0101.atldat
				      ,mr_ctc17m0101.atlmat 
				      ,mr_ctc17m0101.atlemp 
	    whenever error stop 
	    if sqlca.sqlcode <> 0 then
	       if sqlca.sqlcode < 0 then
		  error "Erro ",sqlca.sqlcode," em datmemeviadpt" 
	       end if 
	       if sqlca.sqlcode = 100 then
	          initialize mr_ctc17m0101.* to null 
		  error "Departamento nao cadastrado para esta via." 
		  display by name mr_ctc17m0101.dptcod
		  display by name mr_ctc17m0101.dptsit
		  display by name mr_ctc17m0101.caddat
		  display by name mr_ctc17m0101.atldat
		  next field dptcod
	       end if 
	    end if 
	    let m_open = "S" 
	 else
	    whenever error continue
	       open cctc17m01005 using mr_ctc17m0102.emeviacod
	       fetch cctc17m01005 into mr_ctc17m0101.dptcod
				      ,mr_ctc17m0101.dptsit
				      ,mr_ctc17m0101.caddat 
				      ,mr_ctc17m0101.cademp
				      ,mr_ctc17m0101.cadmat
				      ,mr_ctc17m0101.atldat
				      ,mr_ctc17m0101.atlmat 
				      ,mr_ctc17m0101.atlemp 
	    whenever error stop 
	    if sqlca.sqlcode <> 0 then
	       if sqlca.sqlcode < 0 then
		  error "Erro ",sqlca.sqlcode," em datmemeviadpt" 
	       end if 
	       if sqlca.sqlcode = 100 then
	          initialize mr_ctc17m0101.* to null 
		  error "Departamento nao cadastrado para esta via." 
		  display by name mr_ctc17m0101.dptcod
		  display by name mr_ctc17m0101.dptsit
		  display by name mr_ctc17m0101.caddat
		  display by name mr_ctc17m0101.atldat
		  next field dptcod
	       end if 
	    end if 
	 end if 

	 display by name mr_ctc17m0101.dptcod
	 display by name mr_ctc17m0101.dptsit
	 display by name mr_ctc17m0101.caddat
	 display by name mr_ctc17m0101.atldat 

	 case mr_ctc17m0101.dptsit
	    when "A"
	       let mr_ctc17m0101.dptsitdes = "Ativo" 
	    when "C"
	       let mr_ctc17m0101.dptsitdes = "Cancelado" 
	 end case 

	 display by name mr_ctc17m0101.dptsitdes 

	 call cty08g00_descricao_depto(mr_ctc17m0101.dptcod)
	    returning l_result, l_msg, mr_ctc17m0101.dptnom 
	 
	 if l_result <> 1 then
	    error l_msg 
	    sleep 2 
	 end if 

	 display by name mr_ctc17m0101.dptnom 

	 let l_result = 0
	 let l_msg = "" 
	 call cty08g00_nome_func(mr_ctc17m0101.cademp
				,mr_ctc17m0101.cadmat,"F") 
            returning l_result, l_msg, mr_ctc17m0101.funnomcad 
         
	 if l_result <> 1 then
	    error l_msg 
	    sleep 2 
	 end if 

	 let l_result = 0
	 let l_msg = "" 
	 call cty08g00_nome_func(mr_ctc17m0101.atlemp
				,mr_ctc17m0101.atlmat,"F") 
            returning l_result, l_msg, mr_ctc17m0101.funnomatl 
         
	 if l_result <> 1 then
	    error l_msg 
	    sleep 2 
	 end if 

	 display by name mr_ctc17m0101.funnomcad
	 display by name mr_ctc17m0101.funnomatl 
         
	 exit input 
   end input 

end function #ctc17m01_selecionar 

#-------------------------------------------------------------------------------
function ctc17m01_qtd_depto(l_emeviacod) 
#-------------------------------------------------------------------------------
#Obter a quantidade de departamentos cadastrados para a via 

define l_emeviacod    like datmemeviadpt.emeviacod 
define l_qtd          smallint 
define l_result       smallint
define l_msg          char(80)

   let l_qtd = 0 
   let l_result = 1
   let l_msg = "" 

   if m_prep is null or
      m_prep = ""    then
      call ctc17m01_prepare()
   end if 

   whenever error continue
      open cctc17m01006 using l_emeviacod
      fetch cctc17m01006 into l_qtd 
   whenever error stop 
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
	 let l_result = 3
	 let l_msg = "Erro ",sqlca.sqlcode," em datmemeviadpt"  
      end if
      if sqlca.sqlcode = 100 then
	 let l_result = 2
	 let l_msg = "Nao existem departamentos cadastrados para a via." 
      end if 
      let l_qtd = 0 
   end if 
   close cctc17m01006 

   return l_result, l_msg, l_qtd 

end function #ctc17m01_qtd_depto 

#-------------------------------------------------------------------------------
function ctc17m01_input(l_acao) 
#-------------------------------------------------------------------------------

define l_acao     char(01) 
define l_erro     smallint 
define l_result   smallint
define l_msg      char(80) 
define l_ret      char(01) 

   let l_erro = 0 
   let l_result = 0
   let l_msg = "" 
   let l_ret = "S" 

   input by name mr_ctc17m0101.dptcod
		,mr_ctc17m0101.dptsit   without defaults 
      
      before field dptcod 
	 if l_acao <> "I" then
	    next field dptsit
         end if 
	 display by name mr_ctc17m0101.dptcod
	    attribute(reverse) 
      
      after field dptcod
	 display by name mr_ctc17m0101.dptcod
                
         if mr_ctc17m0101.dptcod is null then
	    call cty09g00_popup_isskdepto() 
	       returning l_erro
			,mr_ctc17m0101.dptcod
			,mr_ctc17m0101.dptnom 
	    if l_erro <> 1 then
	       error "Departamento nao selecionado"
	       next field dptcod 
	    else
	       display by name mr_ctc17m0101.dptnom 
	    end if 
	 else
	    call cty08g00_descricao_depto(mr_ctc17m0101.dptcod)
	       returning l_result
			,l_msg
			,mr_ctc17m0101.dptnom 
	    if l_result <> 1 then
	       error l_msg 
	       next field dptcod
	    else
	       display by name mr_ctc17m0101.dptnom 
	    end if 
	 end if 
	 
	 if l_acao = "I" then
	    open cctc17m01007 using mr_ctc17m0101.dptcod
	                           ,mr_ctc17m0102.emeviacod
	    
	    whenever error continue
            fetch cctc17m01007 
            whenever error stop
            
            if sqlca.sqlcode = 0 then 
               error 'Departamento ja cadastrado'          
               next field dptcod
            else
               if sqlca.sqlcode <> 100 then 
                  error 'Erro SELECT cctc17m01007:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] 
                  next field dptcod
               end if 
            end if  
         end if    

      before field dptsit
	 display by name mr_ctc17m0101.dptsit
	    attribute(reverse) 

      after field dptsit
	display by name mr_ctc17m0101.dptsit

	if (mr_ctc17m0101.dptsit <> "A" and
	   mr_ctc17m0101.dptsit <> "C") or
	   mr_ctc17m0101.dptsit is null or
	   mr_ctc17m0101.dptsit = ""    then
	   error "Situacao somente A - Ativa ou C - Cancelada" 
	   next field dptsit 
	end if 
	
	case mr_ctc17m0101.dptsit
	   when "A"
	      let mr_ctc17m0101.dptsitdes = "Ativo" 
	   when "C"
	      let mr_ctc17m0101.dptsitdes = "Cancelado" 
	end case 
	
	display by name mr_ctc17m0101.dptsitdes

      on key(control-c,interrupt,f17)
	 let l_ret = "N" 
	 exit input 
   end input 

   if l_ret = 'N' then
      initialize mr_ctc17m0101.* to null 
      display by name mr_ctc17m0101.dptcod  
      display by name mr_ctc17m0101.dptnom  
      display by name mr_ctc17m0101.dptsit
      display by name mr_ctc17m0101.dptsitdes
      display by name mr_ctc17m0101.caddat 
      display by name mr_ctc17m0101.funnomcad
      display by name mr_ctc17m0101.atldat  
      display by name mr_ctc17m0101.funnomatl
   end if 
   
   return l_ret 

end function #ctc17m01_input 






