#############################################################################
# Nome do Modulo: CTX09G00                                         Raji     #
# Retorna os dez ultimos servicos para apolice (SOCORRO)           Set/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

 database porto
{
 main
    define d_ctx09g00 array [10] of record
       atddat         like datmservico.atddat,
       atddfttxt      like datmservico.atddfttxt,
       execporto      char (1)
    end record
    define i smallint

   call ctx09g00(1,19020003,19,"SDR1999")
         returning
        d_ctx09g00[1].atddat, d_ctx09g00[1].atddfttxt, d_ctx09g00[1].execporto
      , d_ctx09g00[2].atddat, d_ctx09g00[2].atddfttxt, d_ctx09g00[2].execporto
      , d_ctx09g00[3].atddat, d_ctx09g00[3].atddfttxt, d_ctx09g00[3].execporto
      , d_ctx09g00[4].atddat, d_ctx09g00[4].atddfttxt, d_ctx09g00[4].execporto
      , d_ctx09g00[5].atddat, d_ctx09g00[5].atddfttxt, d_ctx09g00[5].execporto
      , d_ctx09g00[6].atddat, d_ctx09g00[6].atddfttxt, d_ctx09g00[6].execporto
      , d_ctx09g00[7].atddat, d_ctx09g00[7].atddfttxt, d_ctx09g00[7].execporto
      , d_ctx09g00[8].atddat, d_ctx09g00[8].atddfttxt, d_ctx09g00[8].execporto
      , d_ctx09g00[9].atddat, d_ctx09g00[9].atddfttxt, d_ctx09g00[9].execporto
      , d_ctx09g00[10].atddat,d_ctx09g00[10].atddfttxt,d_ctx09g00[10].execporto

 for i=1 to 10
    display d_ctx09g00[i].*
 end for
 end main
}
#---------------------------------------------------------------
 function ctx09g00(param)
#---------------------------------------------------------------

 define param      record
    succod         like datrligapol.succod,
    aplnumdig      like datrligapol.aplnumdig,
    itmnumdig      like datrligapol.itmnumdig,
    vcllicnum      like datmservico.vcllicnum
 end record

 define d_ctx09g00 array [10] of record
    atddat         like datmservico.atddat,
    atddfttxt      like datmservico.atddfttxt,
    execporto      char (1)
 end record

 define ws_arraux  smallint

 define ws         record
    comando        char (400),
    dataini        date,
    lignum         like datrligapol.lignum,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    atdetpcod      like datmsrvacp.atdetpcod,
    atddat         like datmservico.atddat,
    atddfttxt      like datmservico.atddfttxt,
    execporto      char (1)
 end record


	define	w_pf1	integer

	let	ws_arraux  =  null

	for	w_pf1  =  1  to  10
		initialize  d_ctx09g00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 set isolation to dirty read

 initialize ws.*          to null

 #---------------------------------------------------------------
 # Preparando SQL LIGACOES
 #---------------------------------------------------------------
 let ws.comando  = "select atdsrvnum        ",
                   "     , atdsrvano        ",
                   "  from datmligacao      ",
                   " where lignum    = ?    ",
                   "   and c24astcod = 'S10'"
 prepare sel_datmligacao from ws.comando
 declare c_datmligacao cursor for sel_datmligacao

 #---------------------------------------------------------------
 # Preparando SQL SERVICO
 #---------------------------------------------------------------
 let ws.dataini  = today - 1 units year
 let ws.comando  = "select atddat",
                   "     , atddfttxt",
                   "  from datmservico ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and vcllicnum = '", param.vcllicnum, "'",
                   "   and asitipcod in (1,2,3)",
                   "   and atddat > '", ws.dataini, "'"
 prepare sel_datmservico from ws.comando
 declare c_datmservico cursor for sel_datmservico

 #---------------------------------------------------------------
 # Preparando SQL ACOMPANHAMENTO DE SERVICO ultima sequencia
 #---------------------------------------------------------------
 let ws.comando  = "select a.atdetpcod  ",
                   "  from datmsrvacp a",
                   " where a.atdsrvnum = ? ",
                   "   and a.atdsrvano = ? ",
                   "   and a.atdsrvseq = (select max(b.atdsrvseq)",
                                         "  from datmsrvacp b    ",
                                         " where b.atdsrvnum = a.atdsrvnum ",
                                         "   and b.atdsrvano = a.atdsrvano )"

 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_datrligapol cursor for
         select lignum
           from datrligapol
          where succod    = param.succod
            and aplnumdig = param.aplnumdig
            and itmnumdig = param.itmnumdig
          order by lignum desc

 let ws_arraux = 1
 foreach c_datrligapol  into ws.lignum

    initialize ws.atdsrvnum   to null

    #------------------------------------------------------------
    # Verifica ligacao
    #------------------------------------------------------------
    open  c_datmligacao using ws.lignum
    fetch c_datmligacao into  ws.atdsrvnum,
                              ws.atdsrvano
    if sqlca.sqlcode = notfound then
       close c_datmligacao
       continue foreach
    end if
    close c_datmligacao
    #------------------------------------------------------------
    # Verifica servicos
    #------------------------------------------------------------
    open  c_datmservico using ws.atdsrvnum,
                              ws.atdsrvano
    fetch c_datmservico into  ws.atddat,
                              ws.atddfttxt
    if sqlca.sqlcode = notfound then
       close c_datmservico
       continue foreach
    end if
    close c_datmservico

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod = 4      then   # somente servicos etapa concluida
       let ws.execporto = "S"
    else
       let ws.execporto = "N"
    end if

    let d_ctx09g00[ws_arraux].atddat = ws.atddat
    let d_ctx09g00[ws_arraux].atddfttxt = ws.atddfttxt
    let d_ctx09g00[ws_arraux].execporto = ws.execporto

    let ws_arraux = ws_arraux + 1
    if ws_arraux > 10 then
       exit foreach
    end if
 end foreach
 return d_ctx09g00[1].atddat, d_ctx09g00[1].atddfttxt, d_ctx09g00[1].execporto
      , d_ctx09g00[2].atddat, d_ctx09g00[2].atddfttxt, d_ctx09g00[2].execporto
      , d_ctx09g00[3].atddat, d_ctx09g00[3].atddfttxt, d_ctx09g00[3].execporto
      , d_ctx09g00[4].atddat, d_ctx09g00[4].atddfttxt, d_ctx09g00[4].execporto
      , d_ctx09g00[5].atddat, d_ctx09g00[5].atddfttxt, d_ctx09g00[5].execporto
      , d_ctx09g00[6].atddat, d_ctx09g00[6].atddfttxt, d_ctx09g00[6].execporto
      , d_ctx09g00[7].atddat, d_ctx09g00[7].atddfttxt, d_ctx09g00[7].execporto
      , d_ctx09g00[8].atddat, d_ctx09g00[8].atddfttxt, d_ctx09g00[8].execporto
      , d_ctx09g00[9].atddat, d_ctx09g00[9].atddfttxt, d_ctx09g00[9].execporto
      , d_ctx09g00[10].atddat,d_ctx09g00[10].atddfttxt,d_ctx09g00[10].execporto

end function
