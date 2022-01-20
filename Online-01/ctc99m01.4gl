#############################################################################
# Nome do Modulo: ctc99m01                                         Ligia    #
#                                                                  Fornax   #
# Cadastro de parametros pra contabilizacao dos servicos           Out/2014 #
# da emprea 43 - Porto Servicos Avulsos PSI-2014-19759EV                    #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                                                                           #
#############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_pesq   record
        ramcod    like datrmdlramast.ramcod,
        rmemdlcod like datrmdlramast.rmemdlcod
 end record

#-------------------------------------------------------------
function ctc99m01_prp()
#-------------------------------------------------------------
   define l_sql char(300)

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where c24astcod = ? "
   prepare pctc99m0100 from l_sql
   declare cctc99m0100 scroll cursor with hold for pctc99m0100

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where c24astcod > ? "
	      ," order by c24astcod "
   prepare pctc99m0100p from l_sql
   declare cctc99m0100p scroll cursor with hold for pctc99m0100p

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where c24astcod < ? "
	      ," order by c24astcod desc"
   prepare pctc99m0100a from l_sql
   declare cctc99m0100a scroll cursor with hold for pctc99m0100a

   let l_sql = " select c24astcod, ramcod, rmemdlcod, cadhordat, "
              ," cadempcod, cadmatnum, atlhordatdat, atlempcod, "
              ," atlmatnum  from datrmdlramast "
	      ," where c24astcod = ? "
   prepare pctc99m0101 from l_sql
   declare cctc99m0101 cursor for pctc99m0101

    let l_sql = " select ramnom from gtakram "
	       ," where empcod = 43 "
	       ," and ramcod = ? "
   prepare pctc99m0102 from l_sql
   declare cctc99m0102 cursor for pctc99m0102

    let l_sql = " select rmemdlnom from gtakmodal "
	       ," where empcod = 43 "
	       ," and ramcod = ? "
	       ," and rmemdlcod = ? "
   prepare pctc99m0103 from l_sql
   declare cctc99m0103 cursor for pctc99m0103

   let l_sql = " select funnom from isskfunc "
              ," where empcod =  ? "
              ," and   funmat =  ? "
   prepare pctc99m0104 from l_sql
   declare cctc99m0104 cursor for pctc99m0104

   let l_sql = " insert into datrmdlramast " 
	      ,"(c24astcod, ramcod, rmemdlcod, "
              ," cadhordat, cadempcod, cadmatnum, "
              ," atlhordatdat, atlempcod, atlmatnum ) values "
	      ," (?,?,?,?,?,?,?,?,?) "
   prepare pctc99m0105 from l_sql

   let l_sql = " delete from datrmdlramast "
              ," where c24astcod = ? "
   prepare pctc99m0106 from l_sql

   let l_sql = " select c24astdes from datkassunto "
	      ," where c24astcod = ? "
   prepare pctc99m0107 from l_sql
   declare cctc99m0107 scroll cursor with hold for pctc99m0107

   let l_sql = " select * from datrctbramsrv "
	      ," where c24astcod = ? "
   prepare pctc99m0108 from l_sql
   declare cctc99m0108 cursor for pctc99m0108

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where ramcod = ? "
   prepare pctc99m0109 from l_sql
   declare cctc99m0109 cursor for pctc99m0109

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where ramcod = ? "
	      ,"   and c24astcod > ? "
	      ," order by c24astcod "
   prepare pctc99m0109p from l_sql
   declare cctc99m0109p scroll cursor with hold for pctc99m0109p

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where ramcod = ? "
	      ,"   and c24astcod < ? "
	      ," order by c24astcod desc"
   prepare pctc99m0109a from l_sql
   declare cctc99m0109a scroll cursor with hold for pctc99m0109a

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where rmemdlcod = ? "
   prepare pctc99m0110 from l_sql
   declare cctc99m0110 cursor for pctc99m0110

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where rmemdlcod = ? "
	      ,"   and c24astcod > ? "
	      ," order by c24astcod "
   prepare pctc99m0110p from l_sql
   declare cctc99m0110p scroll cursor with hold for pctc99m0110p

   let l_sql = " select c24astcod from datrmdlramast "
	      ," where rmemdlcod = ? "
	      ,"   and c24astcod < ? "
	      ," order by c24astcod desc "
   prepare pctc99m0110a from l_sql
   declare cctc99m0110a scroll cursor with hold for pctc99m0110a

   let l_sql = " update datrmdlramast set ramcod = ?," 
	      ,"                          rmemdlcod = ?, "
              ,"                          atlhordatdat = ?, "
	      ,"                          atlempcod = ?, "
	      ,"                          atlmatnum = ? "
	      ," where c24astcod = ? "
   prepare pctc99m0111 from l_sql

end function

#-------------------------------------------------------------
 function ctc99m01()
#-------------------------------------------------------------

 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize lr_ctc99m01.*  to null
 initialize mr_pesq.*  to null

 call ctc99m01_prp()

 open window ctc99m01 at 04,02 with form "ctc99m01"

 menu "AssuntoxRamo"

 command key ("S") "Seleciona"
                   "Pesquisa parametros para contabilizacao da empresa 43"
          initialize lr_ctc99m01.*  to null
          initialize mr_pesq.*  to null
	  display by name  lr_ctc99m01.*
          call ctc99m01_input("C",lr_ctc99m01.*)  returning lr_ctc99m01.*
          if lr_ctc99m01.c24astcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum parametro selecionado"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximos parametros para contabilizacao da empresa 43"
          message ""
          if lr_ctc99m01.c24astcod is not null then
             call ctc99m01_proximo(lr_ctc99m01.c24astcod, lr_ctc99m01.*)
                  returning lr_ctc99m01.*
          else
             error " Nao ha' nenhum parametro nesta direcao"
             next option "Seleciona"
          end if

 command key ("T") "anTerior"
                  "Mostra parametros para contabilizacao da empresa 43 anterior"
          message ""
          if lr_ctc99m01.c24astcod is not null then
             call ctc99m01_anterior(lr_ctc99m01.c24astcod, lr_ctc99m01.*)
                  returning lr_ctc99m01.*
          else
             error " Nao ha' nenhum parametro nesta direcao"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui parametros para contabilizacao da empresa 43"
          message ""
          call ctc99m01_inclui()
          next option "Seleciona"

 command key ("A") "Altera"
                   "Altera parametros para contabilizacao da empresa 43"
          message ""
                    
          if lr_ctc99m01.c24astcod is not null then
             call ctc99m01_altera(lr_ctc99m01.*)
          else
             error " Nenhum parametro selecionado"
             next option "Seleciona"
          end if          


 command key ("R") "Remove"
                  "Remove parametros para contabilizacao da empresa 43"
         message ""
         if lr_ctc99m01.c24astcod  is not null then
	    open cctc99m0108 using lr_ctc99m01.c24astcod
	    fetch cctc99m0108
	    if sqlca.sqlcode <> notfound then
	       error "Existem servicos vinculados a esse assunto. Exclusao nao permitida"
            else
              call ctc99m01_remove(lr_ctc99m01.c24astcod)
            end if
            next option "Seleciona"
         else
            error " Nenhuma parametro selecionado"
            next option "Seleciona"
         end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc99m01

 end function  ###  ctc99m01

#------------------------------------------------------------
 function ctc99m01_proximo(lr_param, lr_ctc99m01)
#------------------------------------------------------------

 define lr_param         record
        c24astcod        like datrmdlramast.c24astcod
 end record

 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 define l_c24astcod like datrmdlramast.c24astcod
 let l_c24astcod = null
 let int_flag = false

 if mr_pesq.ramcod is not null then
    open cctc99m0109p using mr_pesq.ramcod, lr_param.c24astcod
    fetch cctc99m0109p into  l_c24astcod
 else if mr_pesq.rmemdlcod is not null then
         open cctc99m0110p using mr_pesq.rmemdlcod,  lr_param.c24astcod
         fetch cctc99m0110p into  l_c24astcod
      else
         open cctc99m0100p using lr_param.c24astcod
         fetch cctc99m0100p into  l_c24astcod
      end if
 end if

 if sqlca.sqlcode <> notfound then
    let lr_ctc99m01.c24astcod = l_c24astcod
    call ctc99m01_ler(lr_ctc99m01.c24astcod)
         returning lr_ctc99m01.*

    if lr_ctc99m01.c24astcod is not null  then
       display by name lr_ctc99m01.*
    else
       error " Nao ha' nenhum parametro nesta direcao."
       let lr_ctc99m01.c24astcod = lr_param.c24astcod
    end if
 else
    error " Nao ha' nenhum parametro nesta direcao.."
    let lr_ctc99m01.c24astcod = lr_param.c24astcod
 end if

 return lr_ctc99m01.*

 end function  ###  ctc99m01_proximo

#------------------------------------------------------------
 function ctc99m01_anterior(lr_param, lr_ctc99m01)
#------------------------------------------------------------
 define lr_param         record
        c24astcod        like datrmdlramast.c24astcod
 end record

 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 define l_c24astcod like datrmdlramast.c24astcod
 let l_c24astcod = null
 let int_flag = false

 if mr_pesq.ramcod is not null then
    open cctc99m0109a using mr_pesq.ramcod, lr_param.c24astcod
    fetch cctc99m0109a into  l_c24astcod
 else if mr_pesq.rmemdlcod is not null then
         open cctc99m0110a using mr_pesq.rmemdlcod,  lr_param.c24astcod
         fetch cctc99m0110a into  l_c24astcod
      else
         open cctc99m0100a using lr_param.c24astcod
         fetch cctc99m0100a into  l_c24astcod
      end if
 end if

 if sqlca.sqlcode <> notfound then
    let lr_ctc99m01.c24astcod = l_c24astcod
    call ctc99m01_ler(lr_ctc99m01.c24astcod)
         returning lr_ctc99m01.*

    if lr_ctc99m01.c24astcod  is not null   then
       display by name lr_ctc99m01.*
    else
       error " Nao ha' nenhum parametro nesta direcao."
       let lr_ctc99m01.c24astcod = lr_param.c24astcod
    end if
 else
    error " Nao ha' nenhum parametro nesta direcao.."
    let lr_ctc99m01.c24astcod = lr_param.c24astcod
 end if

 return lr_ctc99m01.*

 end function  ###  ctc99m01_anterior

#------------------------------------------------------------
 function ctc99m01_inclui()
#------------------------------------------------------------

 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 define prompt_key    char (01)

 initialize lr_ctc99m01.*   to null
 display by name lr_ctc99m01.*

 call ctc99m01_input("I", lr_ctc99m01.*) returning lr_ctc99m01.*

 if int_flag  then
    let int_flag = false
    initialize lr_ctc99m01.*  to null
    display by name lr_ctc99m01.*
    error " Operacao cancelada!"
    return
 end if

 whenever error continue

 let lr_ctc99m01.cadhordat    = current
 let lr_ctc99m01.cadempcod    = g_issk.empcod
 let lr_ctc99m01.cadmatnum    = g_issk.funmat

 let lr_ctc99m01.atlhordatdat = current
 let lr_ctc99m01.atlempcod    = g_issk.empcod
 let lr_ctc99m01.atlmatnum    = g_issk.funmat

 execute pctc99m0105 using lr_ctc99m01.c24astcod,
                           lr_ctc99m01.ramcod,
                           lr_ctc99m01.rmemdlcod,
                           lr_ctc99m01.cadhordat,
                           lr_ctc99m01.cadempcod,
                           lr_ctc99m01.cadmatnum,
                           lr_ctc99m01.atlhordatdat,
                           lr_ctc99m01.atlempcod,
                           lr_ctc99m01.atlmatnum

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao dos parametros"
    return
 end if

 whenever error stop

 call ctc99m01_func(g_issk.empcod, g_issk.funmat)
      returning lr_ctc99m01.cadfunnom

 call ctc99m01_func(g_issk.empcod, g_issk.funmat)
      returning lr_ctc99m01.atlfunnom

 display by name lr_ctc99m01.*

 display by name lr_ctc99m01.c24astcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize lr_ctc99m01.*  to null
 display by name lr_ctc99m01.*

 end function  ###  ctc99m01_inclui

#------------------------------------------------------------
 function ctc99m01_altera(lr_ctc99m01)
#------------------------------------------------------------

 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 define prompt_key    char (01)

 display by name lr_ctc99m01.*

 call ctc99m01_input("A", lr_ctc99m01.*) returning lr_ctc99m01.*

 if int_flag  then
    let int_flag = false
    initialize lr_ctc99m01.*  to null
    display by name lr_ctc99m01.*
    error " Operacao cancelada!"
    return
 end if

 whenever error continue

 let lr_ctc99m01.atlhordatdat = current
 let lr_ctc99m01.atlempcod    = g_issk.empcod
 let lr_ctc99m01.atlmatnum    = g_issk.funmat

 execute pctc99m0111 using lr_ctc99m01.ramcod,
                           lr_ctc99m01.rmemdlcod,
                           lr_ctc99m01.atlhordatdat,
                           lr_ctc99m01.atlempcod,
                           lr_ctc99m01.atlmatnum,
                           lr_ctc99m01.c24astcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos parametros"
    return
 end if

 whenever error stop

 call ctc99m01_func(g_issk.empcod, g_issk.funmat)
      returning lr_ctc99m01.atlfunnom

 display by name lr_ctc99m01.*

 display by name lr_ctc99m01.c24astcod attribute (reverse)
 error " Alteracao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize lr_ctc99m01.*  to null
 display by name lr_ctc99m01.*

 end function  ###  ctc99m01_altera

#------------------------------------------------------------
 function ctc99m01_remove(param)
#------------------------------------------------------------

 define param         record
    c24astcod         like datrmdlramast.c24astcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela a exclusao da parametrizacao"
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui a parametrizacao"

       whenever error continue
       execute pctc99m0106 using param.c24astcod
       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na exclusao"
       else
          error " Exclusao efetuada com sucesso"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc99m01_remove

#--------------------------------------------------------------------
 function ctc99m01_input(p_oper, lr_ctc99m01)
#--------------------------------------------------------------------

 define p_oper char(1)
 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 define l_res smallint
 define l_sql char(200)

 let int_flag = false

 input by name lr_ctc99m01.c24astcod, lr_ctc99m01.ramcod, lr_ctc99m01.rmemdlcod
 without defaults

    before field c24astcod

	   if p_oper = "A" then
	      next field ramcod
           end if

           display by name lr_ctc99m01.c24astcod attribute (reverse)

    after  field c24astcod
           display by name lr_ctc99m01.c24astcod

           if p_oper = "I" and lr_ctc99m01.c24astcod is null  then
	      let l_sql = " select c24astcod, c24astdes from datkassunto ",
		          " where c24aststt = 'A' and c24astcod != '0' ",
			  " order by 1 "
	      call ofgrc001_popup(08, 13, 'ESCOLHA O ASSUNTO',
	                          'Codigo', 'Descricao', 'A', l_sql, '', 'D')
	           returning l_res, lr_ctc99m01.c24astcod, lr_ctc99m01.c24astdes
           else
	      let lr_ctc99m01.c24astdes = ""
	      open cctc99m0107 using lr_ctc99m01.c24astcod
	      fetch cctc99m0107 into lr_ctc99m01.c24astdes
           end if

           display by name lr_ctc99m01.c24astcod
           display by name lr_ctc99m01.c24astdes

           if p_oper = "I" then
              if lr_ctc99m01.c24astdes is null  then
                 error "Informe um codigo de assunto valido"
                 next field c24astcod
              end if
   
	      open cctc99m0100 using lr_ctc99m01.c24astcod
	      fetch cctc99m0100
   
	      if sqlca.sqlcode <> notfound then
	         error 'Parametrizacao ja cadastrada para este assunto'
	         next field c24astcod
              end if
           else if lr_ctc99m01.c24astcod is not null then
		   exit input
                end if
           end if

    before field ramcod
           display by name lr_ctc99m01.ramcod attribute (reverse)

    after  field ramcod
           display by name lr_ctc99m01.ramcod
	   if fgl_lastkey() = fgl_keyval("up")   or
	      fgl_lastkey() = fgl_keyval("left") then
	      if p_oper = "A" then
	         next field ramcod
              else
	         next field c24astcod
              end if
           end if

           if p_oper <> "C" and lr_ctc99m01.ramcod is null then
	      let l_sql = " select ramcod, ramnom from gtakram "
		         ," where empcod = 43 "
			 ," order by 2 "
	      call ofgrc001_popup(08, 13, 'ESCOLHA O RAMO',
	                          'Codigo', 'Descricao', 'A', l_sql, '', 'D')
	           returning l_res, lr_ctc99m01.ramcod, lr_ctc99m01.ramdes
           else
	     let lr_ctc99m01.ramdes = ""
	     open cctc99m0102 using lr_ctc99m01.ramcod
	     fetch cctc99m0102 into lr_ctc99m01.ramdes
           end if

           display by name lr_ctc99m01.ramcod
           display by name lr_ctc99m01.ramdes

           if p_oper <> "C" then
              if lr_ctc99m01.ramdes is null  then
                 error "Informe o codigo do ramo"
                 next field ramcod
              end if
           end if

	   if lr_ctc99m01.ramcod is not null then
	      let mr_pesq.ramcod = lr_ctc99m01.ramcod  
           end if

    before field rmemdlcod
           display by name lr_ctc99m01.rmemdlcod attribute (reverse)

    after  field rmemdlcod
           display by name lr_ctc99m01.rmemdlcod

	   if fgl_lastkey() = fgl_keyval("up")   or
	      fgl_lastkey() = fgl_keyval("left") then
	      next field ramcod
           end if

           if p_oper <> "C" and lr_ctc99m01.rmemdlcod is null  then
	      let l_sql = " select rmemdlcod, rmemdlnom from gtakmodal "
		         ," where empcod = 43 "
		         ,"   and ramcod = ", lr_ctc99m01.ramcod
			 ," order by 2 "
	      call ofgrc001_popup(08, 13, 'ESCOLHA A MODALIDADE',
	                          'Codigo', 'Descricao', 'A', l_sql, '', 'D')
	           returning l_res, lr_ctc99m01.rmemdlcod, lr_ctc99m01.rmemdlcoddes
           else
	      let lr_ctc99m01.rmemdlcoddes = ""
	      open cctc99m0103 using lr_ctc99m01.ramcod, lr_ctc99m01.rmemdlcod
	      fetch cctc99m0103 into lr_ctc99m01.rmemdlcoddes
           end if

           display by name lr_ctc99m01.rmemdlcod
           display by name lr_ctc99m01.rmemdlcoddes

           if p_oper <> "C" then
              if lr_ctc99m01.rmemdlcoddes is null then
                 error "Informe o codigo da modalidade"
                 next field rmemdlcod
              end if
           end if

	   if lr_ctc99m01.rmemdlcod is not null then
	      let mr_pesq.rmemdlcod = lr_ctc99m01.rmemdlcod  
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize lr_ctc99m01.*  to null
    initialize mr_pesq.*  to null
    return lr_ctc99m01.*
 end if

 if p_oper = "C" then

    if lr_ctc99m01.ramcod is not null then
       open cctc99m0109 using lr_ctc99m01.ramcod 
       fetch cctc99m0109 into lr_ctc99m01.c24astcod 
    else if lr_ctc99m01.rmemdlcod is not null then
            open cctc99m0110 using lr_ctc99m01.rmemdlcod 
            fetch cctc99m0110 into lr_ctc99m01.c24astcod 
         else if lr_ctc99m01.c24astcod is null then
		 let lr_ctc99m01.c24astcod = '000'
		 open cctc99m0100p using lr_ctc99m01.c24astcod 
		 fetch cctc99m0100p into lr_ctc99m01.c24astcod
              end if
         end if
    end if

    call ctc99m01_ler(lr_ctc99m01.c24astcod)
         returning lr_ctc99m01.*
   
    if lr_ctc99m01.c24astcod  is not null   then
       display by name  lr_ctc99m01.*
    else
       error " Etapa nao cadastrada!"
       initialize lr_ctc99m01.*    to null
    end if
   
 end if

 return lr_ctc99m01.*

 end function  ###  ctc99m01_input

#---------------------------------------------------------
 function ctc99m01_ler(param)
#---------------------------------------------------------

 define param         record
    c24astcod         like datrmdlramast.c24astcod
 end record

 define lr_ctc99m01      record
    c24astcod         like datrmdlramast.c24astcod,
    c24astdes         char(30),
    ramcod            like datrmdlramast.ramcod,
    ramdes            char(30),
    rmemdlcod         like datrmdlramast.rmemdlcod,
    rmemdlcoddes      char(30),
    cadhordat         like datrmdlramast.cadhordat,
    cadempcod         like datrmdlramast.cadempcod,
    cadmatnum         like datrmdlramast.cadmatnum,
    cadfunnom         like isskfunc.funnom,
    atlhordatdat      like datrmdlramast.atlhordatdat,
    atlempcod         like datrmdlramast.atlempcod,
    atlmatnum         like datrmdlramast.atlmatnum,
    atlfunnom         like isskfunc.funnom
 end record

 initialize lr_ctc99m01.*   to null

 open cctc99m0101 using param.c24astcod
 fetch cctc99m0101  into lr_ctc99m01.c24astcod, lr_ctc99m01.ramcod,
                         lr_ctc99m01.rmemdlcod, lr_ctc99m01.cadhordat,
                         lr_ctc99m01.cadempcod, lr_ctc99m01.cadmatnum,
                         lr_ctc99m01.atlhordatdat, lr_ctc99m01.atlempcod,
                         lr_ctc99m01.atlmatnum

 if sqlca.sqlcode = notfound  then
    error " Parametros nao encontrado"
    initialize lr_ctc99m01.*    to null
    return lr_ctc99m01.*
 else
    open cctc99m0107 using lr_ctc99m01.c24astcod
    fetch cctc99m0107 into lr_ctc99m01.c24astdes

    open cctc99m0102 using lr_ctc99m01.ramcod
    fetch cctc99m0102  into lr_ctc99m01.ramdes

    open cctc99m0103 using lr_ctc99m01.ramcod, lr_ctc99m01.rmemdlcod
    fetch cctc99m0103  into lr_ctc99m01.rmemdlcoddes

    call ctc99m01_func(lr_ctc99m01.cadempcod, lr_ctc99m01.cadmatnum)
         returning lr_ctc99m01.cadfunnom

    call ctc99m01_func(lr_ctc99m01.atlempcod, lr_ctc99m01.atlmatnum)
         returning lr_ctc99m01.atlfunnom
 end if

 return lr_ctc99m01.*

 end function  ###  ctc99m01_ler

#---------------------------------------------------------
 function ctc99m01_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.*    to null

 open cctc99m0104 using param.*
 fetch cctc99m0104 into ws.funnom

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

 end function  ###  ctc99m01_func
