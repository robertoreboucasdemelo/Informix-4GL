#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Ct24h                                                      #
# Modulo         : wdatc038.4gl                                               #
#                  Valida e atualiza sessao                                   #
# Analista Resp. : Carlos Pessoto                                             #
# PSI            : 163759 -                                                   #
# OSF            : 5289   -                                                   #
#.............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                      #
# Liberacao      : 26/06/2003                                                 #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 23/08/2006 Cristiane Silva   PSI197858  Visualizar Descontos da OP.         #
###############################################################################
database porto

main

    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    call wdatc038()
end main
-------------------------------------------------------------------------------
function wdatc038()
-------------------------------------------------------------------------------
 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10)
 end record

 define ws          record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)  
 end record

 define	l_dbsmopg	record
	socopgnum	like dbsmopg.socopgnum,
	socopgsitcod	like dbsmopg.socopgsitcod,
	socfatentdat	like dbsmopg.socfatentdat,
	socfatpgtdat	like dbsmopg.socfatpgtdat,
	socemsnfsdat	like dbsmopg.socemsnfsdat,
	socfatitmqtd	like dbsmopg.socfatitmqtd,
	dsctot		dec(15,05), #=> PSI.197858
	socfattotvlr	like dbsmopg.socfattotvlr,
	dsctipdes	like dbsktipdsc.dsctipdes,
	dscvlr		like dbsropgdsc.dscvlr,
	vlrpago         dec(15,05), #=> PSI.197858
	ciaempcod       like datmservico.ciaempcod,
	empresa         char(15)
 end	record

 define	l_tmp		smallint,
	l_tmpcar	char(10),
	l_href		char(500),
	l_pdataini	date,
	l_pdatafnl	date,
	l_psituacao	smallint,
        l_sql           char(1000),
        l_aux_sit       char(10),
        erro            smallint,
        mens            char(100)

 initialize param.* to null
 initialize ws.* to null
 initialize l_dbsmopg.* to null
 initialize l_tmp to null
 initialize l_tmpcar	 to null
 initialize l_href		 to null
 initialize l_pdataini	 to null
 initialize l_pdatafnl	 to null
 initialize l_psituacao	 to null
 initialize l_sql            to null
 initialize l_aux_sit        to null
 initialize erro             to null
 initialize mens             to null

 let l_sql = "select b.ciaempcod",
              " from dbsmopgitm a, datmservico b",
             " where a.socopgnum = ? ",
             "   and a.atdsrvnum = b.atdsrvnum",
             "   and a.atdsrvano = b.atdsrvano"
 prepare sel_wdatc038   from   l_sql
 declare c_wdatc038 cursor for sel_wdatc038

 let param.usrtip    = arg_val(1)
 let param.webusrcod = arg_val(2)
 let param.sesnum    = arg_val(3)
 let param.macsissgl = arg_val(4)
 let l_pdataini      = arg_val(5)
 let l_pdatafnl      = arg_val(6)
 let l_psituacao     = arg_val(7)

 set isolation to dirty read

 --[ Valida Sessao ]--
 call wdatc002(param.*)
      returning ws.*

 if ws.statusprc then
      display "ERRO@@Por quest\365es de seguran\347a seu tempo de<BR> ",
              "permanência nesta página atingiu seu limite ",
              "máximo.@@LOGIN"
      exit program(0)
 end if


 display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@",
               "Ordens de pagamento@@@@"
 display "PADRAO@@10@@10@@23@@0@@B@@C@@M@@4@@3@@2@@10%@@Nr. OP@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Situa\347\343o@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Dt Entrega@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Dt Pagto@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Dt Emi NF@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Qtd Servs@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Valor total@@@@",
                                "B@@C@@M@@4@@3@@2@@10%@@Descontos@@@@", #=> PSI.197858
                                "B@@C@@M@@4@@3@@2@@10%@@Valor Pago@@@@", #=> PSI.197858
                                "B@@C@@M@@4@@3@@2@@10%@@Empresa@@@@"

 display "PADRAO@@6@@1@@B@@C@@0@@2@@100%@@Ordens de pagamento@@@@"

 display "PADRAO@@6@@10@@B@@C@@0@@1@@10%@@Nr. OP@@@@",
                        "B@@C@@0@@1@@10%@@Situação@@@@",
                        "B@@C@@0@@1@@10%@@Dt Entrega@@@@",
                        "B@@C@@0@@1@@10%@@Dt Pagto@@@@",
                        "B@@C@@0@@1@@10%@@Dt Emi NF@@@@",
                        "B@@C@@0@@1@@10%@@Qtd Servs@@@@",
                        "B@@C@@0@@1@@10%@@Valor total@@@@",
                        "B@@C@@0@@1@@10%@@Descontos@@@@", #=> PSI.197858
                        "B@@C@@0@@1@@10%@@Valor Pago@@@@", #=> PSI.197858
                        "B@@C@@0@@1@@10%@@Empresa@@@@"

  if l_psituacao = 3 then
     let l_aux_sit = "7"
  end if
  if l_psituacao = 2 then
     let l_aux_sit = "6,9"
  end if
  if l_psituacao = 1 then
     let l_aux_sit = "6,7,9"
  end if

  let l_sql = "select socopgnum   , socopgsitcod, socfatentdat, socfatpgtdat, ",
              "       socemsnfsdat, socfatitmqtd, socfattotvlr                ",
              "  from dbsmopg                                                 ",
              " where pstcoddig = ",ws.webprscod ,
              "   and socfatentdat >= '", l_pdataini,"'",
              "   and socfatentdat <= '", l_pdatafnl,"'",
              "   and socopgsitcod in (",l_aux_sit clipped,")"
  prepare swdatc038001 from l_sql
  declare cwdatc038001 cursor for swdatc038001


 let l_tmp = false
 foreach cwdatc038001 into 	l_dbsmopg.socopgnum,
				l_dbsmopg.socopgsitcod,
				l_dbsmopg.socfatentdat,
				l_dbsmopg.socfatpgtdat,
				l_dbsmopg.socemsnfsdat,
				l_dbsmopg.socfatitmqtd,
				l_dbsmopg.socfattotvlr

         let l_tmp = true

         open c_wdatc038 using l_dbsmopg.socopgnum
         fetch c_wdatc038 into l_dbsmopg.ciaempcod
         close c_wdatc038
         
         call cty14g00_empresa (1, l_dbsmopg.ciaempcod)
              returning erro,
                        mens,
                        l_dbsmopg.empresa

         case l_dbsmopg.socopgsitcod
              when 6
                  let l_tmpcar = "A FATURAR"
              when 7
                  let l_tmpcar = "PAGA"
              when 9
                  let l_tmpcar = "A FATURAR"
              otherwise
                  let l_tmpcar = l_dbsmopg.socopgsitcod
         end case

	 let l_sql = "select sum(dsc.dscvlr) from dbsropgdsc dsc, dbsmopg opg ",
	 	     " where dsc.socopgnum = opg.socopgnum ",
	 	     " and dsc.socopgnum = ? ",
	 	     " and opg.socopgsitcod = 7 "
	 prepare swdatc038002 from l_sql
	 declare cwdatc038002 cursor for swdatc038002
	 open cwdatc038002 using l_dbsmopg.socopgnum
	 fetch cwdatc038002 into l_dbsmopg.dsctot
	 close cwdatc038002

	 if l_dbsmopg.dsctot = 0 or l_dbsmopg.dsctot is null then
	 	let l_dbsmopg.vlrpago = l_dbsmopg.socfattotvlr
	 else
	 	let l_dbsmopg.vlrpago = l_dbsmopg.socfattotvlr - l_dbsmopg.dsctot
	 end if

	 if l_dbsmopg.socopgsitcod <> 7 then
	 	let l_dbsmopg.vlrpago = null
	 end if

	 let l_href = "wdatc039.pl?sesnum=",
         param.sesnum using "<<<<<<<<&",
         "&webusrcod=",
         param.webusrcod clipped ,
         "&usrtip=",
         param.usrtip ,
         "&macsissgl=",
         param.macsissgl ,
         "&numop=",
         l_dbsmopg.socopgnum using "<<<<<<<&",
         "&situacao=",
         l_tmpcar clipped,
         "&dataent=",
         l_dbsmopg.socfatentdat using "dd/mm/yyyy",
         "&datapgt=",
         l_dbsmopg.socfatpgtdat using "dd/mm/yyyy",
         "&datanfs=",
         l_dbsmopg.socemsnfsdat using "dd/mm/yyyy",
         "&qtdserv=",
         l_dbsmopg.socfatitmqtd using "<<<<<&",
         "&vlrtot=",
         l_dbsmopg.socfattotvlr using "<<<<<<<&.&&",
         "&dsctot=",
         l_dbsmopg.dsctot using "<<<<<<<&.&&",
         "&vlrpago=",
         l_dbsmopg.vlrpago using "<<<<<<<&.&&",
         "&dataini=", l_pdataini,
         "&datafnl=", l_pdatafnl,
         "&situacao_slv=", l_dbsmopg.socopgsitcod,
         "&empresa=", l_dbsmopg.empresa clipped

	display "PADRAO@@6@@10@@N@@C@@1@@1@@10%@@",
        l_dbsmopg.socopgnum using "<<<<<<<&",
        "@@", l_href clipped, "@@",
        "N@@C@@1@@0@@10%@@", l_tmpcar clipped, "@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.socfatentdat using "dd/mm/yyyy","@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.socfatpgtdat using "dd/mm/yyyy","@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.socemsnfsdat using "dd/mm/yyyy","@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.socfatitmqtd using "<<<<<&","@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.socfattotvlr using "<<<<<<<&.&&", "@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.dsctot using "<<<<<<<&.&&","@@@@",
        "N@@C@@1@@0@@10%@@",
        l_dbsmopg.vlrpago
        using "<<<<<<<&.&&", "@@@@",
        "N@@C@@1@@0@@10%@@", l_dbsmopg.empresa clipped, "@@@@"
        

	display "PADRAO@@10@@10@@23@@0@@N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.socopgnum using "<<<<<<<&", "@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_tmpcar clipped,"@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.socfatentdat using "dd/mm/yyyy","@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.socfatpgtdat using "dd/mm/yyyy","@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.socemsnfsdat using "dd/mm/yyyy","@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.socfatitmqtd using "<<<<<&","@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.socfattotvlr
         using "<<<<<<<&.&&", "@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.dsctot using "<<<<<<<&.&&","@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.vlrpago using "<<<<<<<&.&&","@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@",
         l_dbsmopg.empresa clipped,"@@@@",
         "N@@C@@M@@4@@3@@0@@10%@@"


 end foreach

 if not l_tmp then
    display "ERRO@@Não foram encontrados registros em nosso banco de dados.@@BACK"
 end if

 --[ Atualiza sessao ]--
 if wdatc003(param.*, ws.*) then
      display "ERRO@@Não foi possivel atualizar a sessão.@@LOGIN"
      exit program(0)
 end if

end function
