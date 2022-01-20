###############################################################################
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema       : Ct24h                                                       #
# Modulo        : ctb73m00                                                    #
# Analista Resp.: Carlos Zyon                                                 #
# PSI           : 188603                                                      #
# Objetivo      : Cadastro de indicadores de performance                      #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      :                                                            #
#.............................................................................#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
# 22/03/2012                           Formato MAC Para UNIX                  #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl" 

define mr_ctb73m0001   record
   prfindcod           like dpakprfind.prfindcod 
  ,prfinddes           like dpakprfind.prfinddes 
  ,prfindcrtcod        like dpakprfind.prfindcrtcod
  ,criterio            char(15)
  ,bnfvlr              like dpakprfind.bnfvlr
  ,prfindstt           like dpakprfind.prfindstt 
  ,situacao            char(10) 
  ,caddat              like dpakprfind.caddat 
  ,cadhor              like dpakprfind.cadhor 
  ,cadusrtip           like dpakprfind.cadusrtip 
  ,cademp              like dpakprfind.cademp 
  ,cadmat              like dpakprfind.cadmat
  ,atldat              like dpakprfind.atldat 
  ,atlhor              like dpakprfind.atlhor 
  ,atlusrtip           like dpakprfind.atlusrtip 
  ,atlemp              like dpakprfind.atlemp 
  ,atlmat              like dpakprfind.atlmat 
end record 

define m_prep        char(01)
define m_flags       char(01) 

#------------------------------------------------------------------------------
function ctb73m00_prepare()
#------------------------------------------------------------------------------

define l_sql   char(1000)

   let l_sql = " select prfindcod     "
	      ,"   from dpakprfind    " 
	      ,"  where prfindcod = ? " 
   prepare pctb73m00001 from l_sql
   declare cctb73m00001 cursor for pctb73m00001 

   let l_sql = " insert into dpakprfind(prfindcod      "
              ,"                       ,prfinddes      "
              ,"                       ,prfindcrtcod   "
              ,"                       ,bnfvlr         "
              ,"                       ,prfindstt      "
              ,"                       ,caddat         "
              ,"                       ,cadhor         "
              ,"                       ,cadusrtip      "
              ,"                       ,cademp         "
              ,"                       ,cadmat         "
              ,"                       ,atldat         "
              ,"                       ,atlhor         "
              ,"                       ,atlusrtip      "
              ,"                       ,atlemp         "
              ,"                       ,atlmat)        "
	      ," values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare pctb73m00002 from l_sql

   let l_sql = " update dpakprfind       "
	      ,"    set prfinddes = ?    "
	      ,"       ,prfindcrtcod = ? " 
	      ,"       ,bnfvlr = ?       "
	      ,"       ,prfindstt = ?    "
	      ,"       ,atldat = ?       "
	      ,"       ,atlhor = ?       "
	      ,"       ,atlusrtip = ?    "
	      ,"       ,atlemp = ?       "
	      ,"       ,atlmat = ?       " 
	      ,"  where prfindcod = ?    " 
   prepare pctb73m00003 from l_sql

   let l_sql = " select prfindcod,prfinddes,prfindcrtcod,bnfvlr,prfindstt "
	      ,"       ,caddat,cadhor,cadusrtip,cademp,cadmat,atldat,atlhor "
	      ,"       ,atlusrtip,atlemp,atlmat                             " 
	      ,"   from dpakprfind    " 
	      ,"  where prfindcod = ? " 
	      ,"  order by 1          " 
   prepare pctb73m00004 from l_sql
   declare cctb73m00004 scroll cursor for pctb73m00004 

   let l_sql = " select prfindcod,prfinddes,prfindcrtcod,bnfvlr,prfindstt "
	      ,"       ,caddat,cadhor,cadusrtip,cademp,cadmat,atldat,atlhor "
	      ,"       ,atlusrtip,atlemp,atlmat                             " 
	      ,"   from dpakprfind    " 
	      ,"  order by 1 " 
   prepare pctb73m00005 from l_sql
   declare cctb73m00005 scroll cursor for pctb73m00005 

   let m_prep = "S" 

end function #ctb73m00_prepare 

#------------------------------------------------------------------------------
function ctb73m00()
#------------------------------------------------------------------------------
#base ctc70m02 

   initialize mr_ctb73m0001 to null 

   if m_prep is null or
      m_prep = ""    then
      call ctb73m00_prepare()
   end if 

   open window w_ctb73m00 at 4,2 with form "ctb73m00"
      attribute(prompt line last, comment line last) 

      menu "INDIC_PERF"

	 command key("S") "Seleciona" "Seleciona Indicador de Performance"
	    clear form
            let m_flags = "N" 
	    call ctb73m00_seleciona()
	    if m_flags <> "S" then
	       next option "Proximo" 
	    end if

	 command key("P") "Proximo" "Mostra Proximo Indicador de Performance"
	    if mr_ctb73m0001.prfindcod is null then
	       error "Selecione o registro !"
	       next option "Seleciona" 
	    else
	       if m_flags <> "S" then
		  call ctb73m00_pagina(1) 
	       else
		  error "Nao existem registros nesta direcao!!"
		  next option "Seleciona" 
	       end if 
	    end if 

	 command key ("A") "Anterior" "Mostra Indicador de Performance Anterior"
	    if mr_ctb73m0001.prfindcod is null then
	       error "Selecione o registro !"
	       next option "Seleciona" 
	    else
	       if m_flags <> "S" then
		  call ctb73m00_pagina(-1) 
	       else
		  error "Nao existem registros nesta direcao!!"
		  next option "Seleciona" 
	       end if 
	    end if 

	 command key ("M") "Modifica" "Modifica registro selecionado"
	    if mr_ctb73m0001.prfindcod is null then
	       error "Selecione o registro !"
	       next option "Seleciona" 
	    else
	       call ctb73m00_input("M") 
	    end if 

         command key ("I") "Inclui" "Inclui novo Indicador de Performance" 
	    call ctb73m00_input("I") 

	 command key (interrupt,"E") "Encerra" "Retorna ao menu anterior " 
	    exit menu 

      end menu 

   close window w_ctb73m00 

end function #ctb73m00 

#------------------------------------------------------------------------------
function ctb73m00_input(l_acao) 
#------------------------------------------------------------------------------

define l_acao          char(01) 
define l_erro          smallint

   if l_acao = "I" then
      initialize mr_ctb73m0001.* to null 
   end if 

   display by name mr_ctb73m0001.* 

   input by name mr_ctb73m0001.* without defaults
      
      #Codigo 
      before field prfindcod
	 if l_acao = "M" then
	    next field prfinddes 
	 end if 
	 display by name mr_ctb73m0001.prfindcod
	    attribute(reverse)

      after field prfindcod
	 display by name mr_ctb73m0001.prfindcod 
	 if l_acao = "I" then
	    if mr_ctb73m0001.prfindcod is null then
	       error "Informe o codigo do indicador de performance" 
	       next field prfindcod 
	    end if 
	    whenever error continue
	       open cctb73m00001 using mr_ctb73m0001.prfindcod 
	       fetch cctb73m00001 into mr_ctb73m0001.prfindcod 
	    whenever error stop 
	    if sqlca.sqlcode <> 0 then
	       if sqlca.sqlcode < 0 then
		  error "Erro no SELECT cctb73m00001", sqlca.sqlcode, "/"
		       ,sqlca.sqlerrd[2]
		  sleep 3
		  error "ctb73m00_input()",mr_ctb73m0001.prfindcod 
                  let l_erro = true
		  exit input 
	       end if 
	    else
	       error "Codigo ja existe!"
	       next field prfindcod 
	    end if
	    close cctb73m00001 
	 end if 

      #Descricao
      before field prfinddes
	 display by name mr_ctb73m0001.prfinddes
	    attribute(reverse)  

      after field prfinddes
	 display by name mr_ctb73m0001.prfinddes 
	 if fgl_lastkey() = fgl_keyval("up")   or
	    fgl_lastkey() = fgl_keyval("left") then
	    next field prfindcod
         end if 
	 if mr_ctb73m0001.prfinddes is null or
	    mr_ctb73m0001.prfinddes = " "   then
	    error "Informe a descricao do indicador"
	    next field prfinddes 
         end if 

      #Criterio
      before field prfindcrtcod
	 display by name mr_ctb73m0001.prfindcrtcod
	    attribute(reverse) 

      after field prfindcrtcod 
	 display by name mr_ctb73m0001.prfindcrtcod
	 if fgl_lastkey() = fgl_keyval("up")   or
	    fgl_lastkey() = fgl_keyval("left") then
	    next field prfinddes
         end if 
	 if mr_ctb73m0001.prfindcrtcod is null or
	    mr_ctb73m0001.prfindcrtcod = " "   then
	    error "Informe o criterio"
	    next field prfindcrtcod 
	 end if 
	 if mr_ctb73m0001.prfindcrtcod <> "C" and
	    mr_ctb73m0001.prfindcrtcod <> "B" then
	    error "Informe C para Classificatorio ou B para Bonificacao!"
	    let mr_ctb73m0001.prfindcrtcod = ""
	    display by name mr_ctb73m0001.prfindcrtcod 
	    next field prfindcrtcod 
         end if 

	 case mr_ctb73m0001.prfindcrtcod
            when "C"
               let mr_ctb73m0001.criterio = "Classificatorio" 
	    when "B" 
               let mr_ctb73m0001.criterio = "Bonificacao" 
	 end case 

	 display by name mr_ctb73m0001.criterio 
	 next field bnfvlr 

      #Valor 
      before field bnfvlr
	 display by name mr_ctb73m0001.bnfvlr
	    attribute(reverse)

      after field bnfvlr
	 display by name mr_ctb73m0001.bnfvlr
	 if fgl_lastkey() = fgl_keyval("up")   or
	    fgl_lastkey() = fgl_keyval("left") then
	    next field prfindcrtcod
         end if 
         if mr_ctb73m0001.bnfvlr is null then
	    error "Informe o valor do indicador!"
	    next field bnfvlr 
	 end if 
       
      #Situacao 
      before field prfindstt
	 display by name mr_ctb73m0001.prfindstt
	    attribute(reverse) 

      after field prfindstt  
	 display by name mr_ctb73m0001.prfindstt
	 if fgl_lastkey() = fgl_keyval("up")   or
	    fgl_lastkey() = fgl_keyval("left") then
	    next field bnfvlr
         end if 
	 if mr_ctb73m0001.prfindstt is null or
	    mr_ctb73m0001.prfindstt = " "   then
	    error "Informe a situacao!" 
	    next field prfindstt 
         end if 
	 if mr_ctb73m0001.prfindstt <> "A" and
	    mr_ctb73m0001.prfindstt <> "C" then
	    error "Informe A para Ativo ou C para Cancelado!" 
	    let mr_ctb73m0001.prfindstt = ""
	    display by name mr_ctb73m0001.prfindstt
	    next field prfindstt 
         end if 

	 case mr_ctb73m0001.prfindstt
	    when "A"
	       let mr_ctb73m0001.situacao = "Ativo" 
	    when "C"
	       let mr_ctb73m0001.situacao = "Cancelado" 
	 end case 

	 display by name mr_ctb73m0001.situacao 

	 let mr_ctb73m0001.atldat = today
	 let mr_ctb73m0001.atlhor = current 
	 let mr_ctb73m0001.atlusrtip = g_issk.usrtip
	 let mr_ctb73m0001.atlemp = g_issk.empcod
	 let mr_ctb73m0001.atlmat = g_issk.funmat

         if l_acao = "I" then
            let mr_ctb73m0001.caddat = today
            let mr_ctb73m0001.cadhor = current 
            let mr_ctb73m0001.cadusrtip = g_issk.usrtip
            let mr_ctb73m0001.cademp = g_issk.empcod
            let mr_ctb73m0001.cadmat = g_issk.funmat 
            call ctb73m00_inclui()
         else
            call ctb73m00_modifica()
         end if

	 display by name mr_ctb73m0001.caddat
	 display by name mr_ctb73m0001.cadhor 
	 display by name mr_ctb73m0001.atlhor
	 display by name mr_ctb73m0001.cadusrtip
	 display by name mr_ctb73m0001.cademp
	 display by name mr_ctb73m0001.cadmat
	 display by name mr_ctb73m0001.atldat
	 display by name mr_ctb73m0001.atlusrtip
	 display by name mr_ctb73m0001.atlemp
	 display by name mr_ctb73m0001.atlmat 

      before field situacao  
	 exit input 

      on key (interrupt,control-c,f17)
         let int_flag = true
         initialize mr_ctb73m0001 to null
         clear form
         exit input 
   end input 

   if l_erro = false   and
      int_flag = false then 
   end if

end function #ctb73m00_input 

#------------------------------------------------------------------------------
function ctb73m00_inclui() 
#------------------------------------------------------------------------------


   whenever error continue
      execute pctb73m00002 using mr_ctb73m0001.prfindcod
			        ,mr_ctb73m0001.prfinddes 
			        ,mr_ctb73m0001.prfindcrtcod 
			        ,mr_ctb73m0001.bnfvlr 
			        ,mr_ctb73m0001.prfindstt 
			        ,mr_ctb73m0001.caddat 
			        ,mr_ctb73m0001.cadhor
			        ,mr_ctb73m0001.cadusrtip 
			        ,mr_ctb73m0001.cademp 
			        ,mr_ctb73m0001.cadmat 
			        ,mr_ctb73m0001.atldat 
			        ,mr_ctb73m0001.atlhor 
			        ,mr_ctb73m0001.atlusrtip 
			        ,mr_ctb73m0001.atlemp 
			        ,mr_ctb73m0001.atlmat 
   whenever error stop 
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
         error "Erro no INSERT pctb73m00002",sqlca.sqlcode
	      ,"/",sqlca.sqlerrd[2]
         sleep 3
         error "ctb73m00_input()",mr_ctb73m0001.prfindcod,"/"
	      ,mr_ctb73m0001.prfinddes,"/"
	      ,mr_ctb73m0001.prfindcrtcod,"/"
	      ,mr_ctb73m0001.bnfvlr,"/"
              ,mr_ctb73m0001.prfindstt,"/"
	      ,mr_ctb73m0001.caddat,"/"
	      ,mr_ctb73m0001.cadhor,"/"
	      ,mr_ctb73m0001.cadusrtip,"/"
	      ,mr_ctb73m0001.cademp,"/"
	      ,mr_ctb73m0001.cadmat,"/" 
	      ,mr_ctb73m0001.atldat,"/"
	      ,mr_ctb73m0001.atlhor,"/"
	      ,mr_ctb73m0001.atlusrtip,"/"
	      ,mr_ctb73m0001.atlemp,"/"
	      ,mr_ctb73m0001.atlmat,"/" 
	 return  
      end if 
   else
      error "Registro incluido com sucesso!" 
   end if 

end function #ctb73m00_inclui

#------------------------------------------------------------------------------
function ctb73m00_modifica() 
#------------------------------------------------------------------------------

   whenever error continue
      execute pctb73m00003 using mr_ctb73m0001.prfinddes
				,mr_ctb73m0001.prfindcrtcod
				,mr_ctb73m0001.bnfvlr
				,mr_ctb73m0001.prfindstt
				,mr_ctb73m0001.atldat
				,mr_ctb73m0001.atlhor
				,mr_ctb73m0001.atlusrtip
				,mr_ctb73m0001.atlemp
				,mr_ctb73m0001.atlmat
				,mr_ctb73m0001.prfindcod 
   whenever error stop 
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
	 error "Erro no UPDATE pctb73m00003",sqlca.sqlcode
	      ,"/",sqlca.sqlerrd[2] 
	 sleep 3
         error "ctb73m00_input()",mr_ctb73m0001.prfindcod,"/"
	      ,mr_ctb73m0001.prfinddes,"/"
	      ,mr_ctb73m0001.prfindcrtcod,"/"
	      ,mr_ctb73m0001.bnfvlr,"/"
              ,mr_ctb73m0001.prfindstt,"/"
	      ,mr_ctb73m0001.atldat,"/"
	      ,mr_ctb73m0001.atlhor,"/"
	      ,mr_ctb73m0001.atlusrtip,"/"
	      ,mr_ctb73m0001.atlemp,"/"
	      ,mr_ctb73m0001.atlmat,"/" 
	      ,mr_ctb73m0001.prfindcod 
	 return  
      end if 
   else
      error "Registro modificado com sucesso!" 
   end if 

end function #ctb73m00_modifica

#------------------------------------------------------------------------------
function ctb73m00_seleciona()
#------------------------------------------------------------------------------

   clear form

   let int_flag = false

   initialize mr_ctb73m0001 to null

   input by name mr_ctb73m0001.prfindcod without defaults 

      before field prfindcod
	 display by name mr_ctb73m0001.prfindcod
	    attribute(reverse) 

      after field prfindcod
	 display by name mr_ctb73m0001.prfindcod

	 if mr_ctb73m0001.prfindcod is not null then 
            let m_flags = "S" 
	    whenever error continue
	       open cctb73m00004 using mr_ctb73m0001.prfindcod
	       fetch cctb73m00004 into mr_ctb73m0001.prfindcod
				      ,mr_ctb73m0001.prfinddes 
				      ,mr_ctb73m0001.prfindcrtcod 
				      ,mr_ctb73m0001.bnfvlr 
				      ,mr_ctb73m0001.prfindstt 
				      ,mr_ctb73m0001.caddat 
				      ,mr_ctb73m0001.cadhor   
				      ,mr_ctb73m0001.cadusrtip 
				      ,mr_ctb73m0001.cademp 
				      ,mr_ctb73m0001.cadmat 
				      ,mr_ctb73m0001.atldat 
				      ,mr_ctb73m0001.atlhor  
				      ,mr_ctb73m0001.atlusrtip 
				      ,mr_ctb73m0001.atlemp 
				      ,mr_ctb73m0001.atlmat 
	    whenever error stop 
	    if sqlca.sqlcode <> 0 then 
	       if sqlca.sqlcode < 0 then
	          error "Erro no SELECT cctb73m00004.",sqlca.sqlcode
		       ,"/",sqlca.sqlerrd[2] 
	          sleep 3
	          error "ctb73m00_seleciona()",mr_ctb73m0001.prfindcod
	          let int_flag = true
	          exit input 
	       end if
	       if sqlca.sqlcode = 100 then
	          error "Indicador nao encontrado com este codigo"
	          let mr_ctb73m0001.prfindcod = 0
	          display by name mr_ctb73m0001.prfindcod
	          next field prfindcod 
	       end if 
	    end if 
	    close cctb73m00004 
         else
	    whenever error continue
	       open cctb73m00005 
	       fetch first cctb73m00005 into mr_ctb73m0001.prfindcod
				            ,mr_ctb73m0001.prfinddes 
				            ,mr_ctb73m0001.prfindcrtcod 
				            ,mr_ctb73m0001.bnfvlr 
				            ,mr_ctb73m0001.prfindstt 
				            ,mr_ctb73m0001.caddat 
				            ,mr_ctb73m0001.cadhor   
				            ,mr_ctb73m0001.cadusrtip 
				            ,mr_ctb73m0001.cademp 
				            ,mr_ctb73m0001.cadmat 
				            ,mr_ctb73m0001.atldat 
				            ,mr_ctb73m0001.atlhor  
				            ,mr_ctb73m0001.atlusrtip 
				            ,mr_ctb73m0001.atlemp 
				            ,mr_ctb73m0001.atlmat 
	    whenever error stop 
	    if sqlca.sqlcode <> 0 then 
	       if sqlca.sqlcode < 0 then
	          error "Erro no SELECT cctb73m00004.",sqlca.sqlcode
		       ,"/",sqlca.sqlerrd[2] 
	          sleep 3
	          error "ctb73m00_seleciona()",mr_ctb73m0001.prfindcod
	          let int_flag = true
	          exit input 
	       end if
	       if sqlca.sqlcode = 100 then
	          error "Nenum indicador cadastrado"
	          let mr_ctb73m0001.prfindcod = 0
	          display by name mr_ctb73m0001.prfindcod
	          next field prfindcod 
	       end if 
	    end if 
	 end if

	 case mr_ctb73m0001.prfindcrtcod
            when "C"
               let mr_ctb73m0001.criterio = "Classificatorio" 
	    when "B" 
               let mr_ctb73m0001.criterio = "Bonificacao" 
	 end case 

	 case mr_ctb73m0001.prfindstt
	    when "A"
	       let mr_ctb73m0001.situacao = "Ativo" 
	    when "C"
	       let mr_ctb73m0001.situacao = "Cancelado" 
	 end case 

	 on key(interrupt,control-c,f17)
	    let int_flag = true
	    exit input 

   end input

   let int_flag = false

   display by name mr_ctb73m0001.prfindcod
   display by name mr_ctb73m0001.prfinddes
   display by name mr_ctb73m0001.prfindcrtcod
   display by name mr_ctb73m0001.criterio 
   display by name mr_ctb73m0001.bnfvlr
   display by name mr_ctb73m0001.prfindstt
   display by name mr_ctb73m0001.situacao 
   display by name mr_ctb73m0001.caddat
   display by name mr_ctb73m0001.cadhor 
   display by name mr_ctb73m0001.atlhor 
   display by name mr_ctb73m0001.cadusrtip
   display by name mr_ctb73m0001.cademp
   display by name mr_ctb73m0001.cadmat
   display by name mr_ctb73m0001.atldat
   display by name mr_ctb73m0001.atlusrtip
   display by name mr_ctb73m0001.atlemp
   display by name mr_ctb73m0001.atlmat

   #open cctb73m00005 
end function #ctb73m00_seleciona 

#------------------------------------------------------------------------------
function ctb73m00_pagina(l_indice)
#------------------------------------------------------------------------------

define l_indice     integer

   whenever error continue
      fetch relative l_indice cctb73m00005 into mr_ctb73m0001.prfindcod
			         ,mr_ctb73m0001.prfinddes 
			         ,mr_ctb73m0001.prfindcrtcod 
			         ,mr_ctb73m0001.bnfvlr 
			         ,mr_ctb73m0001.prfindstt 
			         ,mr_ctb73m0001.caddat 
			         ,mr_ctb73m0001.cadhor 
			         ,mr_ctb73m0001.cadusrtip 
			         ,mr_ctb73m0001.cademp 
			         ,mr_ctb73m0001.cadmat 
			         ,mr_ctb73m0001.atldat 
			         ,mr_ctb73m0001.atlhor 
			         ,mr_ctb73m0001.atlusrtip 
			         ,mr_ctb73m0001.atlemp 
			         ,mr_ctb73m0001.atlmat 
   whenever error stop 
   if sqlca.sqlcode <> 0 then 
      if sqlca.sqlcode < 0 then
         error "Erro no SELECT cctb73m00004.",sqlca.sqlcode
	      ,"/",sqlca.sqlerrd[2] 
         sleep 3
         error "ctb73m00_seleciona()",mr_ctb73m0001.prfindcod
      end if
      if sqlca.sqlcode = 100 then
         error "Nao existem mais registros nessa direcao"
      end if 
   end if

   case mr_ctb73m0001.prfindcrtcod
      when "C"
        let mr_ctb73m0001.criterio = "Classificatorio" 
      when "B" 
        let mr_ctb73m0001.criterio = "Bonificacao" 
   end case 

   case mr_ctb73m0001.prfindstt
      when "A"
         let mr_ctb73m0001.situacao = "Ativo" 
      when "C"
         let mr_ctb73m0001.situacao = "Cancelado" 
   end case 

   display by name mr_ctb73m0001.prfindcod
   display by name mr_ctb73m0001.prfinddes
   display by name mr_ctb73m0001.prfindcrtcod
   display by name mr_ctb73m0001.criterio 
   display by name mr_ctb73m0001.bnfvlr
   display by name mr_ctb73m0001.prfindstt
   display by name mr_ctb73m0001.situacao 
   display by name mr_ctb73m0001.caddat
   display by name mr_ctb73m0001.cadhor 
   display by name mr_ctb73m0001.atlhor
   display by name mr_ctb73m0001.cadusrtip
   display by name mr_ctb73m0001.cademp
   display by name mr_ctb73m0001.cadmat
   display by name mr_ctb73m0001.atldat
   display by name mr_ctb73m0001.atlusrtip
   display by name mr_ctb73m0001.atlemp
   display by name mr_ctb73m0001.atlmat


end function #ctb73m00_pagina 



