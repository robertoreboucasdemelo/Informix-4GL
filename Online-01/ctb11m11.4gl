############################################################################
# Nome de Modulo: CTB11M11                                        Gilberto #
#                                                                 Marcelo  #
# Exibe totais (qtde/valor) por tipo de servico                   Abr/1997 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 29/03/2000  PSI 10264-4  Wagner       Display totalizadores (H)ospedagem #
#--------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.  #
#--------------------------------------------------------------------------#
# 11/04/2001  PSI 12759-0  Wagner       Display do total das diferencas.   #
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 23/01/2003  Gustavo, Meta  PSI182133 Calcular os impostos PIS, COFINS e  #
#                            OSF 30449 CSLL.                               #
#--------------------------------------------------------------------------#
# 13/05/2011  Celso Yamahaki           Adicionar Linha de Assistencia Fune-#
#                                      raria                               #
############################################################################

database porto

###
### Inicio PSI182133 - Gustavo
###

define  m_prep_sql   smallint

#-------------------------#
 function ctb11m11_prep()
#-------------------------#
 define l_sql      char(500)

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

 prepare pctb11m11001 from l_sql
 declare cctb11m11001 cursor for pctb11m11001
 ### Fim

 let l_sql = " select sum(dscvlr) from dbsropgdsc where socopgnum = ? "
 prepare pctb11m11002 from l_sql
 declare cctb11m11002 cursor for pctb11m11002

 let m_prep_sql = true

 end function
###
### Final PSI182133 - Gustavo
###

#--------------------------------------------------------------------
 function ctb11m11(param)
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

  define d_ctb11m11  record
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

  define a_ctb11m11  array[10] of record
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
     call ctb11m11_prep()
  end if

  open window w_ctb11m11 at 08,02 with form "ctb11m11"
       attribute(form line first)

  initialize a_ctb11m11   to null
  initialize d_ctb11m11.* to null
  initialize ws.*         to null
  let l_desconto = 0.00

  let sql = "select srvtipdes     ",
            "  from datksrvtip    ",
            " where atdsrvorg = ? "
  prepare sel_datksrvtip from sql
  declare c_datksrvtip cursor for sel_datksrvtip

  for arr_aux = 1  to  10
    initialize a_ctb11m11[arr_aux].atdsrvorg  to null
    initialize a_ctb11m11[arr_aux].srvtipdes  to null

    let a_ctb11m11[arr_aux].atdsrvorg = arr_aux

    if arr_aux <= 7  then
       open  c_datksrvtip using a_ctb11m11[arr_aux].atdsrvorg
       fetch c_datksrvtip into  a_ctb11m11[arr_aux].srvtipdes
       close c_datksrvtip
    end if

    let a_ctb11m11[arr_aux].acmqtd = 00
    let a_ctb11m11[arr_aux].acmvlr = 00.00
  end for
  
  #Assistencia Funeraria
  select srvtipdes 
    into a_ctb11m11[08].srvtipdes  
    from datksrvtip   
   where atdsrvorg = 18
 

  #------------------------------------------------------
  # TOTAIS
  #------------------------------------------------------
  initialize a_ctb11m11[09].srvtipdes  to null
  initialize a_ctb11m11[09].acmqtd     to null
  initialize a_ctb11m11[09].acmvlr     to null

  let a_ctb11m11[10].srvtipdes = "TOTAL"

  #------------------------------------------------------
  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #------------------------------------------------------
  message " Aguarde, pesquisando... "  attribute(reverse)

  select socopgdscvlr,
         socopgsitcod
    into d_ctb11m11.dscvlr,
         ws.socopgsitcod
    from dbsmopg
   where socopgnum = param.socopgnum
   
   if d_ctb11m11.dscvlr is null then
      let d_ctb11m11.dscvlr = 0
   end if
   
  if sqlca.sqlcode <> 0  then
     error " Erro (", sqlca.sqlcode, ") na localizacao da ordem de pagamento. AVISE A INFORMATICA!"
     close window w_ctb11m11
     return
  end if

  ### Inicio PSI182133 - Gustavo
  open cctb11m11001 using  param.socopgnum
  whenever error continue
  fetch cctb11m11001 into d_ctb11m11.basvlr,
                          d_ctb11m11.irfvlr,
                          d_ctb11m11.issvlr,
                          d_ctb11m11.inssvlr,
                          d_ctb11m11.pisretvlr,
                          d_ctb11m11.cofretvlr,
                          d_ctb11m11.cslretvlr

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let ws.trbflg = false
     else
        error 'Erro SELECT cctb11m11001:' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 3
        error ' CTB11M11/ ctb11m11()/ ', param.socopgnum   sleep 2
        close window w_ctb11m11
        let int_flag = false
        return
     end if
  else
     let ws.trbflg = true
  end if
  #Para caso existir na tabela, e virem zerados
  if d_ctb11m11.irfvlr    = 0 and    
     d_ctb11m11.issvlr    = 0 and   
     d_ctb11m11.inssvlr   = 0 and  
     d_ctb11m11.pisretvlr = 0 and
     d_ctb11m11.cofretvlr = 0 and
     d_ctb11m11.cslretvlr = 0     then
     
     let ws.trbflg = false 
  end if
     
     
  ### Final PSI182133

  declare c_ctb11m11  cursor for
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

  foreach c_ctb11m11 into ws.atdsrvnum,
                          ws.atdsrvano,
                          ws.socopgtotvlr,
                          ws.atdsrvorg,
                          ws.socopgitmcst
    
     if ws.socopgitmcst is null then
        let ws.socopgitmcst = 0
       
     end if 
     if ws.socopgitmcst  is not null   then
        let ws.socopgtotvlr = ws.socopgtotvlr + ws.socopgitmcst
     end if

     let arr_aux = ws.atdsrvorg
     
     # para servico funerario
     if ws.atdsrvorg = 18 then
        let arr_aux = 08        
     end if

     let a_ctb11m11[arr_aux].acmqtd = a_ctb11m11[arr_aux].acmqtd + 1
     let a_ctb11m11[arr_aux].acmvlr = a_ctb11m11[arr_aux].acmvlr +
                                      ws.socopgtotvlr

     #------------------------------------------------------
     # TOTAIS DA O.P.
     #------------------------------------------------------
     let a_ctb11m11[10].acmqtd = a_ctb11m11[10].acmqtd + 1
     let a_ctb11m11[10].acmvlr = a_ctb11m11[10].acmvlr + ws.socopgtotvlr

  end foreach

  whenever error continue
  	open cctb11m11002 using param.socopgnum
  	fetch cctb11m11002 into ws.dscvlr

  whenever error stop
  	if sqlca.sqlcode = notfound or ws.dscvlr = 0.00 or ws.dscvlr is null then
  			select socopgdscvlr
  			into l_desconto
  			from dbsmopg
  			where socopgnum = param.socopgnum

  			if l_desconto is not null or l_desconto > 0.00 then
  				let ws.dscvlr = l_desconto
  			else
  				let ws.dscvlr = 0.00
  			end if
  	else
  		let d_ctb11m11.dscvlr = ws.dscvlr
  	end if
 whenever error stop
  if d_ctb11m11.dscvlr is null  then
     let d_ctb11m11.dscvlr = 0.00
  end if

  if d_ctb11m11.irfvlr is null  then
     let d_ctb11m11.irfvlr = 0.00
  else
     let d_ctb11m11.irfvlr = d_ctb11m11.irfvlr * -1
  end if

  if d_ctb11m11.issvlr is null  then
     let d_ctb11m11.issvlr = 0.00
  else
     let d_ctb11m11.issvlr = d_ctb11m11.issvlr * -1
  end if

  if d_ctb11m11.inssvlr is null  then
     let d_ctb11m11.inssvlr = 0.00
  else
     let d_ctb11m11.inssvlr = d_ctb11m11.inssvlr * -1
  end if

  ### Inicio PSI182133 - Gustavo
  if d_ctb11m11.pisretvlr is null then
     let d_ctb11m11.pisretvlr = 0
  else
     let d_ctb11m11.pisretvlr = (d_ctb11m11.pisretvlr * -1)
  end if

  if d_ctb11m11.cofretvlr is null then
     let d_ctb11m11.cofretvlr = 0
  else
     let d_ctb11m11.cofretvlr = (d_ctb11m11.cofretvlr * -1)
  end if

  if d_ctb11m11.cslretvlr is null then
     let d_ctb11m11.cslretvlr = 0
  else
     let d_ctb11m11.cslretvlr = (d_ctb11m11.cslretvlr * -1)
  end if
  ### Final PSI182133


  let d_ctb11m11.impvlr = d_ctb11m11.irfvlr    +
                          d_ctb11m11.issvlr    +
                          d_ctb11m11.inssvlr   +
                          d_ctb11m11.cofretvlr +  ### PSI182133 - Gustavo
                          d_ctb11m11.pisretvlr +  ###
                          d_ctb11m11.cslretvlr    ###

  if d_ctb11m11.totvlr is null or d_ctb11m11.totvlr = 0.00 then
  	select socfattotvlr into ws.socfattotvlr
  	from dbsmopg where socopgnum = param.socopgnum

  	let d_ctb11m11.totvlr = ws.socfattotvlr
  end if

  let d_ctb11m11.liqvlr = a_ctb11m11[10].acmvlr - d_ctb11m11.dscvlr

  if d_ctb11m11.liqvlr is null or d_ctb11m11.liqvlr = 0.00 then
  	let d_ctb11m11.liqvlr = d_ctb11m11.totvlr
  end if

    if d_ctb11m11.impvlr is not null and d_ctb11m11.impvlr > 0.00 then
	let d_ctb11m11.liqvlr = d_ctb11m11.liqvlr + d_ctb11m11.impvlr
  end if

  let d_ctb11m11.liqvlr = d_ctb11m11.totvlr +
                          d_ctb11m11.impvlr -
                          d_ctb11m11.dscvlr


  select sum(socopgitmcst)
    into ws.socopgdsccst
    from dbsmopgcst
   where dbsmopgcst.socopgnum    = param.socopgnum
     and dbsmopgcst.soccstcod    = 07

  initialize d_ctb11m11.difvlr to null
  if ws.socopgdsccst is not null  and
     ws.socopgdsccst <> 0         then
     let d_ctb11m11.difvlr = "Dif.:", ws.socopgdsccst using "###,###.##"
  end if


  display by name d_ctb11m11.*

  if ws.trbflg = false  then
     display "**********" at 02,67 ###
     display "**********" at 03,67 #
     display "**********" at 04,67 #
     display "**********" at 05,67 #  PSI182133
     display "**********" at 03,43 #
     display "**********" at 04,43 #
     display "**********" at 05,43 ###
  else
     if ws.socopgsitcod  <  7   then
        display "NAO TRIBUT" at 02,67 ###
        display "NAO TRIBUT" at 03,67 #
        display "NAO TRIBUT" at 04,67 #
        display "NAO TRIBUT" at 05,67 #  PSI182133
        display "NAO TRIBUT" at 03,43 #
        display "NAO TRIBUT" at 04,43 #
        display "NAO TRIBUT" at 05,43 ###
     end if
  end if

  call set_count(10)
  message "(F17)Abandona,(F3)Prox.Pag,(F4)Pag.Ant,(F8)Seleciona,(F7)Descontos,(F9)Por CC"

  display array a_ctb11m11 to s_ctb11m11.*
     on key (interrupt,control-c)
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        if a_ctb11m11[arr_aux].acmqtd  is not null   and
           a_ctb11m11[arr_aux].acmqtd  >  00         and
           arr_aux                     <  10         then
           call ctb11m10(param.socopgnum, a_ctb11m11[arr_aux].atdsrvorg)
        end if

     on key (F7)
     	call ctc81m00(param.socopgnum)

     on key (F9)
     	call ctb84m00(param.socopgnum,1)

  end display

  let int_flag = false
  close c_ctb11m11
  clear form
  close window w_ctb11m11

end function  ###  ctb11m11
