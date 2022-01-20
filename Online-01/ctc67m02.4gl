#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: HISTORICO DE CLIENTES I -  SCCI -  CENTRAL 24H             #
# MODULO.........: ctc67m02  - HISTORICO                                    #
# ANALISTA RESP..: Fabio Costa / Guilherme Rosa                               #
# PSI/OSF........: PSi-2013-07173 - Consulta de Clientes I                    #
#                  Manter Historico do cadastto de clientes I                 #
# ........................................................................... #
# DESENVOLVIMENTO: MARCIA FRANZON - INTERA                         15/07/2013 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define d_ctc67m02 record
    regaltdat        like datmipecliacp.regaltdat,
    regalthrr        like datmipecliacp.regalthrr,
    usrmatnum        like datmipecliacp.usrmatnum,
    empcod           like datmipecliacp.empcod,
    usrtipcod        like datmipecliacp.usrtipcod,
    cliacptxt        like datmipecliacp.cliacptxt 
 end record
 
 define a_linha  array[1000] of record
    cliacptxt          char(70)
 end record
 
 
 define m_prep_sql       smallint

#----------------------------------------------
function ctc67m02_prepare()
#----------------------------------------------
 define l_sql    char(5000)
 
 let l_sql = "select regaltdat, regalthrr,usrmatnum, empcod  "
	    ," ,usrtipcod, cliacptxt ,txtlinnum              "
            ," from datmipecliacp                 "
            ," where ipeclinum = ?             "
            ," order by regaltdat desc,  txtlinnum  " 
 prepare pctc67m02001 from l_sql
 declare cctc67m02001 cursor for pctc67m02001      
 
 let l_sql = "select funnom "
            ," from isskfunc "
            ," where funmat = ? " 
            ,"   and empcod = ? "
            ,"   and usrtip = ? "     
 prepare pctc67m02002 from l_sql
 declare cctc67m02002 cursor for pctc67m02002   

  let l_sql = "insert into datmipecliacp (ipeclinum, regaltdat , "
             ," regalthrr,txtlinnum,cliacptxt,usrtipcod,empcod,usrmatnum)"
             ," values(?,?,?,?,?,?,?,?) "
 prepare pctc67m02003 from l_sql
 
 let l_sql = "select max(txtlinnum) "
            ," from datmipecliacp      "
            ," where ipeclinum = ?  "
 prepare pctc67m02004 from l_sql
 declare cctc67m02004 cursor for pctc67m02004      
 
 let m_prep_sql = true

end function


#---------------------------------------------------------------
 function ctc67m02(k_ctc67m02)
#---------------------------------------------------------------

 define k_ctc67m02 record
        ipeclinum    like datmipecliacp.ipeclinum
       ,cpfcpjnum    like datkipecli.cpfcpjnum
       ,cpjfilnum    like datkipecli.cpjfilnum
       ,cpfcpjdig    like datkipecli.cpfcpjdig
 end record

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc67m02_prepare()
   end if

 #abre janela
 open window w_ctc67m02 at 04,02 with form "ctc67m03"
   attributes(form line 1, message line last - 1)

 #exibe codigo do cliente na tela
 
 display k_ctc67m02.cpfcpjnum    to cpfcpjnum
 display k_ctc67m02.cpjfilnum    to cpjfilnum
 display k_ctc67m02.cpfcpjdig    to cpfcpjdig
 
 #menu
 menu "HISTORICO"
      before menu
	 hide option all
         IF get_niv_mod(g_issk.prgsgl , 'ctc67m00') THEN
	    if g_issk.acsnivcod >= g_issk.acsnivcns then
	       show option "Consulta"
            end if
	    if g_issk.acsnivcod >= g_issk.acsnivatl then
	       show option "Implementa", "Consulta"
   	    end if
	 END IF
											 show option "Encerra"

      command "Implementa"
              "Insere um novo item de historico para o cliente selecionado"
              call ctc67m02_implementa(k_ctc67m02.*)
      
      command "Consulta"
              "Consulta historico do cliente selecionado"
              call ctc67m02_consulta(k_ctc67m02.*)
      
      command key (interrupt,E) "Encerra"
              "Retorna ao menu anterior"
              exit menu
      
 end menu

 close window w_ctc67m02

end function       
 
#---------------------------------------------------------------
function ctc67m02_consulta(k_consulta)
#---------------------------------------------------------------
   define k_consulta   record
	  ipeclinum   like datmipecliacp.ipeclinum
         ,cpfcpjnum   like datkipecli.cpfcpjnum
         ,cpjfilnum   like datkipecli.cpjfilnum
         ,cpfcpjdig   like datkipecli.cpfcpjdig
   end record
   
   define l_data_antes       like datmipecliacp.regaltdat
   define l_usrmatnum_antes  like datmipecliacp.usrmatnum
   define l_txtlinnum        like datmipecliacp.txtlinnum
   define l_aux_linha        smallint
   define l_aux              smallint
   define l_nome             like isskfunc.funnom
   
   let l_data_antes      = null
   let l_usrmatnum_antes = null
   let l_aux_linha       = 0
   let l_aux             = 0
   let l_nome            = null
   
   initialize  d_ctc67m02.*  to  null
   initialize  a_linha         to  null
 
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc67m02_prepare()
   end if
   
   open cctc67m02001 using k_consulta.ipeclinum
   foreach cctc67m02001 into d_ctc67m02.regaltdat, 
			     d_ctc67m02.regalthrr,
                             d_ctc67m02.usrmatnum, 
                             d_ctc67m02.empcod, 
                             d_ctc67m02.usrtipcod,
                             d_ctc67m02.cliacptxt,
                             l_txtlinnum
         if l_data_antes is null or             #caso seja o 1º registro lido
            l_data_antes <> d_ctc67m02.regaltdat or  #ou seja um outro registro (outra data)
            l_usrmatnum_antes <> d_ctc67m02.usrmatnum then  #ou seja mesma data mas com outra matricula
            let l_aux_linha = l_aux_linha + 1
            let a_linha[l_aux_linha].cliacptxt = ""
            #encontrou registros de outra data
            open cctc67m02002 using d_ctc67m02.usrmatnum, 
                                      d_ctc67m02.empcod,
                                      d_ctc67m02.usrtipcod
            fetch cctc67m02002 into l_nome                  
            let a_linha[l_aux_linha].cliacptxt = "Em: ", d_ctc67m02.regaltdat,
                                             " Por: ", l_nome
            let l_aux_linha = l_aux_linha + 1
         end if   
         let a_linha[l_aux_linha].cliacptxt = d_ctc67m02.cliacptxt
         let l_aux_linha                = l_aux_linha + 1
         let l_data_antes               = d_ctc67m02.regaltdat
         let l_usrmatnum_antes   = d_ctc67m02.usrmatnum
         initialize d_ctc67m02.* to null
         if l_aux_linha > 1000 then
            error "Historico estourou o permitido em tela"
            exit foreach
         end if
   end foreach

   call set_count(l_aux_linha)
   
   display array a_linha to s_ctc67m03.*

      on key(f17,esc,interrupt,control-c)
         exit display

   end display

end function


#---------------------------------------------------------------
function ctc67m02_implementa(k_impl)
#---------------------------------------------------------------
   define k_impl record
	  ipeclinum    like datmipecliacp.ipeclinum
         ,cpfcpjnum    like datkipecli.cpfcpjnum
         ,cpjfilnum    like datkipecli.cpjfilnum
         ,cpfcpjdig    like datkipecli.cpfcpjdig
 end record
   
   define arr_aux   smallint,
          scr_aux   smallint,
          l_txtlinnum   like datmipecliacp.txtlinnum
          
   define l_hora datetime hour to minute    
   
   let arr_aux = null
   let scr_aux = null
   let l_txtlinnum = 0
   initialize  d_ctc67m02.*  to  null
   initialize  a_linha  to  null
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc67m02_prepare()
   end if   
   
       #--------------
   #carrega dados fixos
       let d_ctc67m02.regaltdat = date 
       let l_hora  = current
       let d_ctc67m02.usrmatnum = g_issk.funmat
       let d_ctc67m02.empcod    = g_issk.empcod
       let d_ctc67m02.usrtipcod = g_issk.usrtip

       input array a_linha without defaults from s_ctc67m03.*
          before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
       
          before field cliacptxt
             display a_linha[arr_aux].cliacptxt to
                     s_ctc67m03[scr_aux].cliacptxt attribute (reverse)
       
          after field cliacptxt
             display a_linha[arr_aux].cliacptxt to
                     s_ctc67m03[scr_aux].cliacptxt
       
             if fgl_lastkey() = fgl_keyval("left")  or
                fgl_lastkey() = fgl_keyval("up")    then
                error " Alteracoes e/ou correcoes nao sao permitidas!"
                next field cliacptxt
             else
                if a_linha[arr_aux].cliacptxt is null  or
                   a_linha[arr_aux].cliacptxt =  "  "  then
                   error " Complemento deve ser informado!"
                   next field cliacptxt
                end if
             end if
       
       
          after row
             if a_linha[arr_aux].cliacptxt is null  or
                a_linha[arr_aux].cliacptxt =  "  "  then
                display "complemento não foi digitado"
                next field cliacptxt
             else
                #Buscar ultimo item de histórico cadastrado para o cliente
                open cctc67m02004 using k_impl.ipeclinum 
                fetch cctc67m02004 into l_txtlinnum
                
                if l_txtlinnum is null or
                   l_txtlinnum = 0 then
                   let l_txtlinnum = 1
                else
                   let l_txtlinnum = l_txtlinnum + 1
                end if

                let d_ctc67m02.cliacptxt = a_linha[arr_aux].cliacptxt

                     let d_ctc67m02.regaltdat = today
		     let d_ctc67m02.regalthrr = current 
	
                # Grava HISTORICO do servico  
		whenever error continue
                execute pctc67m02003 using k_impl.ipeclinum,
                                           d_ctc67m02.regaltdat,
                                           d_ctc67m02.regalthrr,
                                           l_txtlinnum,
                                           d_ctc67m02.cliacptxt,
                                           d_ctc67m02.usrtipcod,
                                           d_ctc67m02.empcod,
                                           d_ctc67m02.usrmatnum
                whenever error stop
                if sqlca.sqlcode <> 0  then
                    error "Erro (", sqlca.sqlcode, ") na inclusao do historico. ",
                          "Favor re-digitar a linha."
                    next field cliacptxt
                end if
             end if   

          on key (accept,esc,interrupt,control-c)
             exit input

       end input
       
   
end function
