###############################################################################
# Nome do Modulo: ctc80m00                                     Cristiane Silva#
#                                                                             #
# Cadastro de Tipos de Desconto                                      Jun/2006 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
# 02/05/2016  Ligia Mattge    SPR-2016-02269 Projeto Controle de Descontos 
#-----------------------------------------------------------------------------#
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define  wresp   char(01)


#-----------------#
function ctc80m00()
#-----------------#

define ctc80m00  record
           dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           coddesp      integer, 
           ccusto       char(08),
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
end record

define k_ctc80m00    record
         dsctipcod     like dbsktipdsc.dsctipcod
end record

define m_prep_sql smallint
define m_contador smallint
define l_sucesso     smallint

let l_sucesso = true


if not get_niv_mod(g_issk.prgsgl, "ctc80m00") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
end if

let int_flag = false

initialize ctc80m00.*   to  null

open window ctc80m00 at 4,2 with form "ctc80m00"
#     attributes(form line 1, border)

menu "DESCONTOS"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui"
          end if

          show option "Encerra"

          command "Seleciona" "Pesquisa tipos de desconto"
          message ""
            call seleciona_ctc80m00() returning k_ctc80m00.*, ctc80m00.*
            if k_ctc80m00.dsctipcod is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhuma tipo de desconto selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo tipo de desconto selecionado"
            message ""
            if k_ctc80m00.dsctipcod is not null then
               call proximo_ctc80m00(k_ctc80m00.*)
                    returning k_ctc80m00.*, ctc80m00.*
            else
               error " Nenhum tipo de desconto nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra tipo de desconto anterior selecionado"
            message ""
            if k_ctc80m00.dsctipcod is not null then
               call anterior_ctc80m00(k_ctc80m00.*)
                    returning k_ctc80m00.*, ctc80m00.*
            else
               error " Nenhuma tipo de desconto nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica tipo de desconto corrente selecionado"
            message ""
            if k_ctc80m00.dsctipcod is not null then
               call modifica_ctc80m00(k_ctc80m00.*, ctc80m00.*)
                    returning k_ctc80m00.*
               next option "Seleciona"
            else
               error " Nenhuma tipo de desconto selecionada!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui tipo de desconto"
            message ""
            call inclui_ctc80m00()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu

   end menu

   close window ctc80m00

end function

#----------------------------#
function seleciona_ctc80m00()
#----------------------------#

define  ctc80m00     record
         dsctipcod    like dbsktipdsc.dsctipcod,
         dsctipdes    like dbsktipdsc.dsctipdes,
         dsctipsit    like dbsktipdsc.dsctipsit,
         coddesp      integer, 
         ccusto       char(08),
         caddat	      like dbsktipdsc.caddat,
         cadmat	      like dbsktipdsc.cadmat,
   	 cadfunnom    like isskfunc.funnom,
         atldat	      like dbsktipdsc.atldat,
         atlmat	      like dbsktipdsc.atlmat,
         funnom       like isskfunc.funnom
end record

define k_ctc80m00     record
         dsctipcod      like dbsktipdsc.dsctipcod
end record

define ws             record
         funmat         like isskfunc.funmat,
         cadfunmat      like isskfunc.funmat
end record

define l_sql char(500)

clear form
let int_flag = false
initialize ws.*         to null
initialize  ctc80m00.*  to null
let l_sql = null


input by name k_ctc80m00.dsctipcod

      before field dsctipcod
          display by name k_ctc80m00.dsctipcod attribute (reverse)

          if k_ctc80m00.dsctipcod is null then
             let k_ctc80m00.dsctipcod = 0
          end if

      after  field dsctipcod
          display by name k_ctc80m00.dsctipcod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc80m00.*   to null
      initialize k_ctc80m00.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctc80m00.*, ctc80m00.*
   end if

   if k_ctc80m00.dsctipcod  =  0 then
      select min (dbsktipdsc.dsctipcod)
        into  k_ctc80m00.dsctipcod
        from  dbsktipdsc
       where  dbsktipdsc.dsctipcod > k_ctc80m00.dsctipcod

      display by name k_ctc80m00.dsctipcod
   end if

   select  dsctipcod   ,
           dsctipdes   ,
           dsctipsit   ,
           caddat      ,
           cadmat	,
           atldat      ,
           atlmat
     into  ctc80m00.dsctipcod   ,
           ctc80m00.dsctipdes   ,
           ctc80m00.dsctipsit,
           ctc80m00.caddat      ,
           ws.cadfunmat         ,
           ctc80m00.atldat      ,
           ws.funmat
     from  dbsktipdsc
    where  dbsktipdsc.dsctipcod = k_ctc80m00.dsctipcod

   if sqlca.sqlcode = 0   then

   let l_sql = 	" select funnom ",
               	" from isskfunc ",
       		" where isskfunc.funmat = ? ",
       		" and isskfunc.empcod = ? ",
       		" and isskfunc.usrtip = ? "
   prepare pctc80m00001 from l_sql
   declare cctc80m00001 cursor for pctc80m00001

   open cctc80m00001 using ws.cadfunmat, g_issk.empcod, g_issk.usrtip
   fetch cctc80m00001 into ctc80m00.cadfunnom

   close cctc80m00001

   open cctc80m00001 using ws.funmat, g_issk.empcod, g_issk.usrtip
   fetch cctc80m00001 into ctc80m00.funnom

   close cctc80m00001

   #fornax marco/2016

   let l_sql = 	" select cpodes[1,4], cpodes[6,13] ",
               	" from datkdominio ",
       		" where cponom = 'CTC81M00' ",
       		"   and cpocod = ? "

   prepare pctc80m00005 from l_sql
   declare cctc80m00005 cursor for pctc80m00005

   let ctc80m00.coddesp = null
   let ctc80m00.ccusto  = null
   open cctc80m00005 using k_ctc80m00.dsctipcod
   fetch cctc80m00005 into ctc80m00.coddesp, ctc80m00.ccusto
   close cctc80m00005

   # relaciona o codigo despesa contabil ao tipo de desconto
   let l_sql = 	" insert into datkdominio (cponom, cpocod, cpodes) ",
       		" values ('CTC81M00',?,?) "
   prepare pctc80m00006 from l_sql

   let l_sql = " update datkdominio set cpodes = ? ",
               "  where cponom  = 'CTC81M00' ",
	       "    and cpocod = ? "
   prepare pctc80m00007 from l_sql




       display by name  ctc80m00.dsctipcod,
         		ctc80m00.dsctipdes,
         		ctc80m00.dsctipsit,
         		ctc80m00.coddesp,
         		ctc80m00.ccusto,
         		ctc80m00.caddat,
         	   	ctc80m00.cadfunnom,
         		ctc80m00.atldat,
                        ctc80m00.funnom
   else
      error " Tipo de desconto nao cadastrado!"
      initialize ctc80m00.*    to null
      initialize k_ctc80m00.*  to null
   end if

   return k_ctc80m00.*, ctc80m00.*

end function


#------------------------------------------------------------
function proximo_ctc80m00(k_ctc80m00)
#------------------------------------------------------------

   define  k_ctc80m00    record
           dsctipcod     like dbsktipdsc.dsctipcod
   end record

   define  ctc80m00     record
         dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           coddesp      integer,
           ccusto       char(08),
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record

   define l_sql char(500)

   initialize ws.*         to null
   initialize ctc80m00.*   to null
   let l_sql = null

   select min (dbsktipdsc.dsctipcod)
     into ctc80m00.dsctipcod
     from dbsktipdsc
    where dbsktipdsc.dsctipcod > k_ctc80m00.dsctipcod

   if  ctc80m00.dsctipcod  is not null   then
       let k_ctc80m00.dsctipcod = ctc80m00.dsctipcod

       select  dsctipcod   ,
           dsctipdes   ,
           dsctipsit   ,
           caddat      ,
           cadmat   ,
           atldat      ,
           atlmat
     into  ctc80m00.dsctipcod   ,
           ctc80m00.dsctipdes   ,
           ctc80m00.dsctipsit,
           ctc80m00.caddat      ,
           ws.cadfunmat         ,
           ctc80m00.atldat      ,
           ws.funmat
     from  dbsktipdsc
    where  dbsktipdsc.dsctipcod = k_ctc80m00.dsctipcod

       if sqlca.sqlcode = 0   then
		let l_sql = 	" select funnom ",
               			" from isskfunc ",
       				" where isskfunc.funmat = ? ",
       				" and isskfunc.empcod = ? ",
       				" and isskfunc.usrtip = ? "
   	        prepare pctc80m00002 from l_sql
   		declare cctc80m00002 cursor for pctc80m00002
   		open cctc80m00002 using ws.cadfunmat, g_issk.empcod, g_issk.usrtip
   		fetch cctc80m00002 into ctc80m00.cadfunnom

   		close cctc80m00002

   		open cctc80m00002 using ws.funmat, g_issk.empcod, g_issk.usrtip
   		fetch cctc80m00002 into ctc80m00.funnom

   		close cctc80m00002

                # fornax marco/2016
                let ctc80m00.coddesp = null
                let ctc80m00.ccusto = null
                open cctc80m00005 using k_ctc80m00.dsctipcod
                fetch cctc80m00005 into ctc80m00.coddesp, ctc80m00.ccusto
                close cctc80m00005

		display by name  ctc80m00.dsctipcod,
         			ctc80m00.dsctipdes,
         			ctc80m00.dsctipsit,
         			ctc80m00.coddesp,
         			ctc80m00.ccusto,
         			ctc80m00.caddat,
         	   		ctc80m00.cadfunnom,
         			ctc80m00.atldat,
                        	ctc80m00.funnom
       else
          	error " Nao ha' tipo de desconto nesta direcao!"
          	initialize ctc80m00.*    to null
          	initialize k_ctc80m00.*  to null
       end if
   else
      error " Nao ha' tipo de desconto nesta direcao!"
      initialize ctc80m00.*    to null
      initialize k_ctc80m00.*  to null
   end if

   return k_ctc80m00.*, ctc80m00.*

end function

#------------------------------------------------------------
function anterior_ctc80m00(k_ctc80m00)
#------------------------------------------------------------

   define  k_ctc80m00    record
           dsctipcod     like dbsktipdsc.dsctipcod
   end record

   define  ctc80m00     record
         dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           coddesp      integer,
           ccusto       char(08),
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record

   define l_sql char(500)

   let int_flag = false
   initialize ws.*        to null
   initialize ctc80m00.*  to null
   let l_sql = null

   select max (dbsktipdsc.dsctipcod)
     into ctc80m00.dsctipcod
     from dbsktipdsc
    where dbsktipdsc.dsctipcod < k_ctc80m00.dsctipcod

   if  ctc80m00.dsctipcod  is  not  null  then
       let k_ctc80m00.dsctipcod = ctc80m00.dsctipcod

      select  dsctipcod   ,
           dsctipdes   ,
           dsctipsit   ,
           caddat      ,
           cadmat   ,
           atldat      ,
           atlmat
      into  ctc80m00.dsctipcod   ,
            ctc80m00.dsctipdes   ,
            ctc80m00.dsctipsit,
            ctc80m00.caddat      ,
            ws.cadfunmat         ,
            ctc80m00.atldat      ,
            ws.funmat
      from  dbsktipdsc
      where  dbsktipdsc.dsctipcod = k_ctc80m00.dsctipcod

       if sqlca.sqlcode = 0   then
		let l_sql = 	" select funnom ",
               			" from isskfunc ",
       				" where isskfunc.funmat = ? ",
       				" and isskfunc.empcod = ? ",
       				" and isskfunc.usrtip = ? "
   		prepare pctc80m00003 from l_sql
   		declare cctc80m00003 cursor for pctc80m00003

   		open cctc80m00003 using ws.cadfunmat, g_issk.empcod, g_issk.usrtip
   		fetch cctc80m00003 into ctc80m00.cadfunnom

   		close cctc80m00003

		open cctc80m00003 using ws.funmat, g_issk.empcod, g_issk.usrtip
   		fetch cctc80m00003 into ctc80m00.funnom

   		close cctc80m00003

                # fornax marco/2016
                let ctc80m00.coddesp = null
                let ctc80m00.ccusto = null
                open cctc80m00005 using k_ctc80m00.dsctipcod
                fetch cctc80m00005 into ctc80m00.coddesp, ctc80m00.ccusto
                close cctc80m00005


		display by name  ctc80m00.dsctipcod,
         			ctc80m00.dsctipdes,
         			ctc80m00.dsctipsit,
         			ctc80m00.coddesp,
         			ctc80m00.ccusto,
         			ctc80m00.caddat,
         	   		ctc80m00.cadfunnom,
         			ctc80m00.atldat,
                        	ctc80m00.funnom
       else
          error " Nao ha' tipo de desconto nesta direcao!"
          initialize ctc80m00.*    to null
          initialize k_ctc80m00.*  to null
       end if
   else
      error " Nao ha' tipo de desconto nesta direcao!"
      initialize ctc80m00.*    to null
      initialize k_ctc80m00.*  to null
   end if

   return k_ctc80m00.*, ctc80m00.*

end function

#------------------------------------------------------------
function modifica_ctc80m00(k_ctc80m00, ctc80m00)
#------------------------------------------------------------

   define  k_ctc80m00    record
           dsctipcod     like dbsktipdsc.dsctipcod
   end record

   define  ctc80m00     record
           dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           coddesp      integer,
           ccusto       char(08),
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record
 
   define l_campo char(20)

   call input_ctc80m00("a", k_ctc80m00.* , ctc80m00.*) returning ctc80m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc80m00.*  to null
      error " Operacao cancelada!"
      clear form
      return k_ctc80m00.*
   end if


   whenever error continue

   let ctc80m00.atldat = today

   select cadmat into ctc80m00.cadmat
   from dbsktipdsc where dsctipcod = k_ctc80m00.dsctipcod


   begin work
      update dbsktipdsc set  (dsctipdes   ,
                              dsctipsit   ,
                              caddat	  ,
                              cademp	  ,
                              cadusrtip	  ,
                              cadmat	  ,
                              atldat      ,
                              atlemp	  ,
                              atlusrtip	  ,
                              atlmat
                              )
                           = (ctc80m00.dsctipdes   ,
                              ctc80m00.dsctipsit   ,
                              ctc80m00.caddat      ,
                              g_issk.empcod      ,
                              "F"	  ,
                              ctc80m00.cadmat	  ,
                              ctc80m00.atldat     ,
                              g_issk.empcod  ,
                              "F"	  ,
                              g_issk.funmat
                              )
             where dbsktipdsc.dsctipcod  =  k_ctc80m00.dsctipcod

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao do tipo de desconto!"
         rollback work
         initialize ctc80m00.*   to null
         initialize k_ctc80m00.* to null
         return k_ctc80m00.*
      else

         let l_campo = ctc80m00.coddesp using "####"," ", ctc80m00.ccusto

	 open cctc80m00005 using ctc80m00.dsctipcod
	 fetch cctc80m00005

	 if sqlca.sqlcode = notfound then
            execute pctc80m00006 using ctc80m00.dsctipcod, l_campo
	 else
            execute pctc80m00007 using l_campo, ctc80m00.dsctipcod
	 end if

         if sqlca.sqlcode <>  0   then
            error " Erro (",sqlca.sqlcode,") em pctc80m0000"
            rollback work
            return
         else   
            error " Alteracao efetuada com sucesso!"
         end if
      end if

   commit work

   whenever error stop

   clear form
   message ""
   return k_ctc80m00.*

end function


#------------------------------------------------------------
function inclui_ctc80m00()
#------------------------------------------------------------

   define  ctc80m00     record
           dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           coddesp      integer,
           ccusto       char(08),
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
   end record

   define k_ctc80m00    record
          dsctipcod        like dbsktipdsc.dsctipcod
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record

   define l_sql char(500)
   define l_campo char(20)

   clear form

   initialize ctc80m00.*   to null
   initialize k_ctc80m00.* to null
   initialize ws.*         to null
   let l_sql = null

   call input_ctc80m00("i",k_ctc80m00.*, ctc80m00.*) returning ctc80m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc80m00.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   let ctc80m00.atldat = today
   let ctc80m00.caddat = today

   declare c_ctc80m00m  cursor with hold  for
           select  max(dsctipcod)
             from  dbsktipdsc
            where  dbsktipdsc.dsctipcod > 0

   foreach c_ctc80m00m  into  ctc80m00.dsctipcod
       exit foreach
   end foreach

   if ctc80m00.dsctipcod is null   then
      let ctc80m00.dsctipcod = 0
   end if
   let ctc80m00.dsctipcod = ctc80m00.dsctipcod + 1

   whenever error continue

   begin work
      insert into dbsktipdsc (dsctipcod,
      			      dsctipdes   ,
                              dsctipsit   ,
                              caddat	  ,
                              cademp	  ,
                              cadusrtip	  ,
                              cadmat	  ,
                              atldat      ,
                              atlemp	  ,
                              atlusrtip	  ,
                              atlmat
                                    )
                            values  (ctc80m00.dsctipcod   ,
                                     ctc80m00.dsctipdes   ,
                              	     ctc80m00.dsctipsit   ,
                                     ctc80m00.caddat      ,
                                     g_issk.empcod        ,
                              	     "F"  		  ,
                              	     g_issk.funmat	  ,
                              	     today      ,
                              	     g_issk.empcod  ,
                              	     "F"	  ,
                              	     g_issk.funmat
                                     )

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na Inclusao do tipo de desconto!"
         rollback work
         return
      end if

      let l_campo = ctc80m00.coddesp using "####"," ", ctc80m00.ccusto
      execute pctc80m00006 using ctc80m00.dsctipcod, l_campo

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") em pctc80m00006"
         rollback work
         return
      end if


   commit work

   whenever error stop

   let l_sql = 	" select funnom ",
               	" from isskfunc ",
       		" where isskfunc.funmat = ? ",
       		" and isskfunc.empcod = ? ",
       		" and isskfunc.usrtip = ? "
   prepare pctc80m00004 from l_sql
   declare cctc80m00004 cursor for pctc80m00004

   open cctc80m00004 using ws.cadfunmat, g_issk.empcod, g_issk.usrtip
   fetch cctc80m00004 into ctc80m00.cadfunnom

   close cctc80m00004

   open cctc80m00004 using ws.funmat, g_issk.empcod, g_issk.usrtip
   fetch cctc80m00004 into ctc80m00.funnom

   close cctc80m00004

   # fornax marco/2016
   let ctc80m00.coddesp = null
   let ctc80m00.ccusto = null
   open cctc80m00005 using k_ctc80m00.dsctipcod
   fetch cctc80m00005 into ctc80m00.coddesp, ctc80m00.ccusto
   close cctc80m00005

   display by name  ctc80m00.dsctipcod,
	            ctc80m00.dsctipdes,
           	    ctc80m00.dsctipsit,
           	    ctc80m00.coddesp,
           	    ctc80m00.ccusto,
           	    ctc80m00.caddat,
	 	    ctc80m00.cadfunnom,
           	    ctc80m00.atldat,
                    ctc80m00.funnom

   display by name ctc80m00.dsctipcod attribute (reverse)
   error " Verifique o codigo do tipo de desconto e tecle ENTER!"
   prompt "" for char wresp
   error " Inclusao efetuada com sucesso!"

   clear form

end function

#--------------------------------------------------------------------
function input_ctc80m00(operacao_aux, k_ctc80m00, ctc80m00)
#--------------------------------------------------------------------

   define  operacao_aux  char (1)

   define  k_ctc80m00    record
           dsctipcod     like dbsktipdsc.dsctipcod
   end record

   define  ctc80m00     record
           dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           coddesp      integer,
           ccusto       char(08),
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
   end record

   let int_flag = false

   input by name ctc80m00.dsctipcod,
                 ctc80m00.dsctipdes,
                 ctc80m00.dsctipsit,
                 ctc80m00.coddesp,
                 ctc80m00.ccusto without defaults

      before field dsctipcod
             next field dsctipdes
             display by name ctc80m00.dsctipcod attribute (reverse)

      after  field dsctipcod
             display by name ctc80m00.dsctipcod

      before field dsctipdes
             display by name ctc80m00.dsctipdes attribute (reverse)

      after  field dsctipdes
             display by name ctc80m00.dsctipdes

             if ctc80m00.dsctipdes  is null   then
                error " Descricao do tipo de desconto deve ser informada!"
                next field dsctipdes
             end if

      before field dsctipsit
             display by name ctc80m00.dsctipsit attribute (reverse)

      after  field dsctipsit
             display by name ctc80m00.dsctipsit

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  dsctipdes
             end if

             if ctc80m00.dsctipsit  is null   or
               (ctc80m00.dsctipsit  <> "A"    and
                ctc80m00.dsctipsit  <> "C")   then
                error " Situacao do tipo de desconto deve ser: (A)tivo ou (C)ancelado!"
                next field dsctipsit
             end if

             if operacao_aux           = "i"   and
                ctc80m00.dsctipsit  = "C"   then
                error " Nao deve ser incluido tipo de desconto com situacao (C)ancelado!"
                next field dsctipsit
             end if

      before field coddesp
             display by name ctc80m00.coddesp attribute (reverse)

      before field ccusto
             display by name ctc80m00.ccusto attribute (reverse)

      after  field coddesp
             display by name ctc80m00.coddesp

	     if ctc80m00.coddesp is null then
		error 'Informe o codigo da despesa contabil para este tipo de desconto'
		next field coddesp
	     end if

      after  field ccusto
             display by name ctc80m00.ccusto

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctc80m00.*  to null
      return ctc80m00.*
   end if

   return ctc80m00.*

end function


#---------------------------------------------------------
function sel_ctc80m00(k_ctc80m00)
#---------------------------------------------------------

   define  k_ctc80m00    record
           dsctipcod     like dbsktipdsc.dsctipcod
   end record

   define  ctc80m00     record
           dsctipcod    like dbsktipdsc.dsctipcod,
           dsctipdes    like dbsktipdsc.dsctipdes,
           dsctipsit    like dbsktipdsc.dsctipsit,
           caddat	like dbsktipdsc.caddat,
           cadmat	like dbsktipdsc.cadmat,
 	   cadfunnom    like isskfunc.funnom,
           atldat	like dbsktipdsc.atldat,
           atlmat	like dbsktipdsc.atlmat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   initialize ctc80m00.*   to null
   initialize ws.*         to null

   select  dsctipcod
     into  ctc80m00.dsctipcod
     from  dbsktipdsc
    where  dbsktipdsc.dsctipcod = k_ctc80m00.dsctipcod

   if sqlca.sqlcode = notfound   then
      error " Tipo de desconto nao cadastrado!"
      initialize ctc80m00.*    to null
      initialize k_ctc80m00.*  to null
   end if

   return ctc80m00.*

end function

                                                               
