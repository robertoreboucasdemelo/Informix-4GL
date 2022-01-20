############################################################################
# Nome de Modulo: CTB04M11                                        Wagner   #
#                                                                          #
# Exibe totais (qtde/valor) por tipo de servico RE                Dez/2001 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 23/01/2003  Gustavo, Meta  PSI182133 Calcular os impostos PIS, COFINS e  #
#                            OSF´30449 CSLL.                               #
#--------------------------------------------------------------------------#
# 30/05/2007  Eduardo Vieira PSI207233    Debito por centro de custo       #
############################################################################

database porto

###
### Inicio PSI182133 - Gustavo
###

define  m_prep_sql   smallint

#-------------------------#
 function ctb04m11_prep()
#-------------------------#
 define l_sql      char(300)

 ### Inicio
 let l_sql =  "  select soctrbbasvlr,"
             ,"       socirfvlr,"
             ,"       socissvlr,"
             ,"       insretvlr,"
             ,"       pisretvlr,"
             ,"       cofretvlr,"
             ,"       cslretvlr"
             ,"  from dbsmopgtrb"
             ," where socopgnum = ?"

 prepare pctb04m11001 from l_sql
 declare cctb04m11001 cursor for pctb04m11001
 ### Fim

let l_sql = " select sum(dscvlr) from dbsropgdsc where socopgnum = ? "
 prepare pctb04m11002 from l_sql
 declare cctb04m11002 cursor for pctb04m11002

let l_sql = "select socfattotvlr from dbsmopg where socopgnum = ? "
prepare pctb04m11003 from l_sql
declare cctb04m11003 cursor for pctb04m11003

let l_sql = "select socopgdscvlr from dbsmopg where socopgnum = ? "
prepare pctb04m11004 from l_sql
declare cctb04m11004 cursor for pctb04m11004

 let m_prep_sql = true

 end function
###
### Final PSI182133 - Gustavo
###

#--------------------------------------------------------------------
 function ctb04m11(param)
#--------------------------------------------------------------------

  define param       record
     socopgnum       like dbsmopgitm.socopgnum
  end record

  define ws          record
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     atdsrvorg       like datmservico.atdsrvorg,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     socopgdsccst    like dbsmopgcst.socopgitmcst,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     socopgsitcod    like dbsmopg.socopgsitcod,
     trbflg          smallint,
     dscvlr          dec(15,5),
     socfattotvlr    like dbsmopg.socfattotvlr
  end record

  define d_ctb04m11  record
     totvlr          dec (15,5),
     impvlr          dec (15,5),
     dscvlr          dec (15,5),
     liqvlr          dec (15,5),
     difvlr          char (15),
     basvlr          like dbsmopgtrb.soctrbbasvlr,
     irfvlr          like dbsmopgtrb.socirfvlr,
     issvlr          like dbsmopgtrb.socissvlr,
     inssvlr         like dbsmopgtrb.insretvlr,
     pisretvlr       like dbsmopgtrb.pisretvlr,  ###
     cofretvlr       like dbsmopgtrb.cofretvlr,  ### PSI182133
     cslretvlr       like dbsmopgtrb.cslretvlr   ###
  end record

  define a_ctb04m11  array[04] of record
     srvtipdes       like datksrvtip.srvtipdes,
     acmqtd          dec(6,0),
     acmvlr          dec(15,5),
     atdsrvorg       like datmservico.atdsrvorg
  end record

  define arr_aux     smallint
  define scr_aux     smallint

  define sql         char (100)

  define l_desconto decimal(15,2)

  ### PSI182133
  if m_prep_sql is null or
     m_prep_sql <> true then
     call ctb04m11_prep()
  end if

  open window w_ctb04m11 at 08,02 with form "ctb04m11"
       attribute(form line first)

  initialize a_ctb04m11   to null
  initialize d_ctb04m11.* to null
  initialize ws.*         to null
  let l_desconto = 0.00

  let ws.socfattotvlr = 0.00

  let sql = "select srvtipdes     ",
            "  from datksrvtip    ",
            " where atdsrvorg = ? "
  prepare sel_datksrvtip from sql
  declare c_datksrvtip cursor for sel_datksrvtip

  let a_ctb04m11[1].atdsrvorg   =  9
  let a_ctb04m11[2].atdsrvorg   = 13
  for arr_aux = 1  to  4
    if arr_aux <= 2  then
       open  c_datksrvtip using a_ctb04m11[arr_aux].atdsrvorg
       fetch c_datksrvtip into  a_ctb04m11[arr_aux].srvtipdes
       close c_datksrvtip
    end if
    let a_ctb04m11[arr_aux].acmqtd = 00
    let a_ctb04m11[arr_aux].acmvlr = 00.00
  end for

  #------------------------------------------------------
  # TOTAIS
  #------------------------------------------------------
  initialize a_ctb04m11[03].srvtipdes  to null
  initialize a_ctb04m11[03].acmqtd     to null
  initialize a_ctb04m11[03].acmvlr     to null

  let a_ctb04m11[04].srvtipdes = "TOTAL"

  #------------------------------------------------------
  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #------------------------------------------------------
  message " Aguarde, pesquisando... "  attribute(reverse)

  select socopgdscvlr,
         socopgsitcod
    into d_ctb04m11.dscvlr,
         ws.socopgsitcod
    from dbsmopg
   where socopgnum = param.socopgnum

display "pegando a situacao, desconto...:", d_ctb04m11.dscvlr, ws.socopgsitcod

display "retorno sqlca..:", sqlca.sqlcode

  if sqlca.sqlcode <> 0  then
     error " Erro (", sqlca.sqlcode, ") na localizacao da ordem de pagamento. AVISE A INFORMATICA!"
     close window w_ctb04m11
     return
  end if

  ### Inicio PSI182133 - Gustavo
  open cctb04m11001 using  param.socopgnum
  whenever error continue
  fetch cctb04m11001 into d_ctb04m11.basvlr,
                          d_ctb04m11.irfvlr,
                          d_ctb04m11.issvlr,
                          d_ctb04m11.inssvlr,
                          d_ctb04m11.pisretvlr,
                          d_ctb04m11.cofretvlr,
                          d_ctb04m11.cslretvlr

display "retorno do cursor 001...:", d_ctb04m11.basvlr,
                          d_ctb04m11.irfvlr,
                          d_ctb04m11.issvlr,
                          d_ctb04m11.inssvlr,
                          d_ctb04m11.pisretvlr,
                          d_ctb04m11.cofretvlr,
                          d_ctb04m11.cslretvlr
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let ws.trbflg = false
     else
        error 'Erro SELECT cctb04m11001:' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 3
        error ' CTB04M11/ ctb04m11()/ ', param.socopgnum   sleep 2
        close window w_ctb04m11
        let int_flag = false
        return
     end if
  else
     let ws.trbflg = true
  end if
  ### Final PSI182133

display "retorno sqlca cursor 001..:", sqlca.sqlcode

  declare c_ctb04m11  cursor for
    select dbsmopgitm.atdsrvnum   , dbsmopgitm.atdsrvano ,
           dbsmopgitm.socopgitmvlr, datmservico.atdsrvorg,
           sum(dbsmopgcst.socopgitmcst)
      from dbsmopgitm, datmservico, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum           and
           datmservico.atdsrvnum   = dbsmopgitm.atdsrvnum      and
           datmservico.atdsrvano   = dbsmopgitm.atdsrvano      and
           dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
           dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

     group by dbsmopgitm.atdsrvnum   , dbsmopgitm.atdsrvano,
              dbsmopgitm.socopgitmvlr, datmservico.atdsrvorg

  foreach c_ctb04m11 into ws.atdsrvnum,
                          ws.atdsrvano,
                          ws.socopgtotvlr,
                          ws.atdsrvorg,
                          ws.socopgitmcst

display "valor item...:", ws.socopgitmcst

     if ws.socopgitmcst  is not null   then
        let ws.socopgtotvlr = ws.socopgtotvlr + ws.socopgitmcst
     end if

display "origem....:", ws.atdsrvorg

     case ws.atdsrvorg
        when  9
           let a_ctb04m11[1].acmqtd = a_ctb04m11[1].acmqtd + 1
           let a_ctb04m11[1].acmvlr = a_ctb04m11[1].acmvlr + ws.socopgtotvlr
        when  13
           let a_ctb04m11[2].acmqtd = a_ctb04m11[2].acmqtd + 1
           let a_ctb04m11[2].acmvlr = a_ctb04m11[2].acmvlr + ws.socopgtotvlr
     end case

     #------------------------------------------------------
     # TOTAIS DA O.P.
     #------------------------------------------------------
     let a_ctb04m11[04].acmqtd = a_ctb04m11[04].acmqtd + 1
     let a_ctb04m11[04].acmvlr = a_ctb04m11[04].acmvlr + ws.socopgtotvlr

  end foreach
 whenever error continue
  	open cctb04m11002 using param.socopgnum
  	fetch cctb04m11002 into ws.dscvlr
display "identificando total de desconto...:", ws.dscvlr
display "retorno sqlca do desconto...:", sqlca.sqlcode

  whenever error stop
  	if sqlca.sqlcode = notfound or ws.dscvlr is null or ws.dscvlr = 0.00 then
  		whenever error continue
  			open cctb04m11004 using param.socopgnum
  			fetch cctb04m11004 into l_desconto
display "retorno do desconto da OP...:",   l_desconto
  		whenever error stop
  			if sqlca.sqlcode <> 0 then
  				error " Erro (", sqlca.sqlcode, ") na localizacao do valor da OP. AVISE A INFORMATICA!"
     				return
			end if
		close cctb04m11004

  		if l_desconto is not null or l_desconto > 0.00 then
  			let ws.dscvlr = l_desconto
  		else
  			let ws.dscvlr = 0.00
  		end if
  	else
  		let d_ctb04m11.dscvlr = ws.dscvlr
  	end if

display "A descontar...:", ws.dscvlr

  if d_ctb04m11.dscvlr is null  then
     let d_ctb04m11.dscvlr = 0.00
  end if

  if d_ctb04m11.irfvlr is null  then
     let d_ctb04m11.irfvlr = 0.00
  else
     let d_ctb04m11.irfvlr = d_ctb04m11.irfvlr * -1
  end if

  if d_ctb04m11.issvlr is null  then
     let d_ctb04m11.issvlr = 0.00
  else
     let d_ctb04m11.issvlr = d_ctb04m11.issvlr * -1
  end if

  if d_ctb04m11.inssvlr is null  then
     let d_ctb04m11.inssvlr = 0.00
  else
     let d_ctb04m11.inssvlr = d_ctb04m11.inssvlr * -1
  end if

  ### Inicio PSI182133 - Gustavo
  if d_ctb04m11.pisretvlr is null then
     let d_ctb04m11.pisretvlr = 0.00
  else
     let d_ctb04m11.pisretvlr = (d_ctb04m11.pisretvlr * -1)
  end if

  if d_ctb04m11.cofretvlr is null then
     let d_ctb04m11.cofretvlr = 0.00
  else
     let d_ctb04m11.cofretvlr = (d_ctb04m11.cofretvlr * -1)
  end if

  if d_ctb04m11.cslretvlr is null then
     let d_ctb04m11.cslretvlr = 0.00
  else
     let d_ctb04m11.cslretvlr = (d_ctb04m11.cslretvlr * -1)
  end if
  ### Final PSI182133

  let d_ctb04m11.impvlr = d_ctb04m11.irfvlr    +
                          d_ctb04m11.issvlr    +
                          d_ctb04m11.inssvlr   +
                          d_ctb04m11.cofretvlr +  ### PSI182133 - Gustavo
                          d_ctb04m11.pisretvlr +  ###
                          d_ctb04m11.cslretvlr    ###


if d_ctb04m11.totvlr is null or d_ctb04m11.totvlr = 0.00 then
  	whenever error continue
  		open cctb04m11003 using param.socopgnum
  		fetch cctb04m11003 into ws.socfattotvlr
display "Total da OP....:",   	ws.socfattotvlr

  	whenever error stop
  		if sqlca.sqlcode <> 0 then
  			error " Erro (", sqlca.sqlcode, ") na localizacao do valor da OP. AVISE A INFORMATICA!"
     			close window w_ctb04m11
     			return
  		end if

  	let d_ctb04m11.totvlr = ws.socfattotvlr
  	close cctb04m11003
end if

  let d_ctb04m11.liqvlr = a_ctb04m11[04].acmvlr - d_ctb04m11.dscvlr

  if d_ctb04m11.liqvlr is null or d_ctb04m11.liqvlr = 0.00 then
  	let d_ctb04m11.liqvlr = d_ctb04m11.totvlr
  end if

    if d_ctb04m11.impvlr is not null and d_ctb04m11.impvlr > 0.00 then
	let d_ctb04m11.liqvlr = d_ctb04m11.liqvlr + d_ctb04m11.impvlr
  end if

  let d_ctb04m11.liqvlr = d_ctb04m11.totvlr +
                          d_ctb04m11.impvlr -
                          d_ctb04m11.dscvlr

display "valor liquido da OP...:", d_ctb04m11.liqvlr

display "fara acesso direto ao custo da op"
  select sum(socopgitmcst)
    into ws.socopgdsccst
    from dbsmopgcst
   where dbsmopgcst.socopgnum    = param.socopgnum
     and dbsmopgcst.soccstcod    = 07

display "custo da OP..:", ws.socopgdsccst

  initialize d_ctb04m11.difvlr to null
  if ws.socopgdsccst is not null  and
     ws.socopgdsccst <> 0         then
     let d_ctb04m11.difvlr = "Dif.:", ws.socopgdsccst using "###,###.##"
  end if

  display by name d_ctb04m11.*

  if ws.trbflg = false  then
     display "**********" at 02,67 ###
     display "**********" at 03,67 #
     display "**********" at 04,67 #
     display "**********" at 05,67 # PSI182133
     display "**********" at 03,43 #
     display "**********" at 04,43 #
     display "**********" at 05,43 ###
  else
     if ws.socopgsitcod  <  7   then
        display "NAO TRIBUT" at 02,67 ###
        display "NAO TRIBUT" at 03,67 #
        display "NAO TRIBUT" at 04,67 #
        display "NAO TRIBUT" at 05,67 # PSI182133
        display "NAO TRIBUT" at 03,43 #
        display "NAO TRIBUT" at 04,43 #
        display "NAO TRIBUT" at 05,43 ###
     end if
  end if

  call set_count(04)
  message "(F17)Abandona,(F3)Prox.Pag,(F4)Pag.Ant,(F8)Selec.,(F7)Descontos,(F9)Por C.C."

  display array a_ctb04m11 to s_ctb04m11.*
     on key (interrupt,control-c)
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        if a_ctb04m11[arr_aux].acmqtd  is not null   and
           a_ctb04m11[arr_aux].acmqtd  >  00         and
           arr_aux                     <  03         then
           call ctb11m10(param.socopgnum, a_ctb04m11[arr_aux].atdsrvorg)
        end if

         on key (F7)
     	call ctc81m00(param.socopgnum)
##PSI207233
     on key (F9)
     	call ctb84m00(param.socopgnum,3)
##PSI207233--fim

  end display

  let int_flag = false
  close c_ctb04m11
  clear form
  close window w_ctb04m11

end function  ###  ctb04m11
