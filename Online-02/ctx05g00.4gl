#############################################################################
# Nome do Modulo: ctx05g00                                         Marcelo  #
#                                                                  Gilberto #
# Retorna custo total de utilizacoes das clausulas 034/035         Jun/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#############################################################################

 database porto

#------------------------------------------------------------------
 function ctx05g00(param)
#------------------------------------------------------------------

 define param      record
    succod         like datrservapol.succod,
    ramcod         like datrservapol.ramcod,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    clcdatinc      date,
    clcdatfnl      date,
    privez         smallint
 end record

 define d_ctx05g00 record
    totsrvqtd      dec (03,0),
    totsrvvlr      dec (15,5)
 end record



	initialize  d_ctx05g00.*  to  null

 set isolation to dirty read

 initialize d_ctx05g00.*  to null

 if param.succod    is null  or
    param.ramcod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return d_ctx05g00.totsrvqtd, d_ctx05g00.totsrvvlr, param.privez
 end if

 if param.clcdatinc is null  then
    return d_ctx05g00.totsrvqtd, d_ctx05g00.totsrvvlr, param.privez
 end if

 if param.clcdatfnl is null  then
    let param.clcdatfnl = today
 end if

 if param.privez = true  then
    call ctx05g00_prepare()
    let param.privez = false
 end if

 call ctx05g00_select(param.succod   ,
                      param.ramcod   ,
                      param.aplnumdig,
                      param.itmnumdig,
                      param.clcdatinc,
                      param.clcdatfnl)
            returning d_ctx05g00.totsrvqtd,
                      d_ctx05g00.totsrvvlr

 return d_ctx05g00.totsrvqtd, d_ctx05g00.totsrvvlr, param.privez

end function  ###  ctx05g00

#------------------------------------------------------------------
 function ctx05g00_prepare()
#------------------------------------------------------------------

 define ws         record
    sql            char (900)
 end record



	initialize  ws.*  to  null

 let ws.sql = "select datmservico.atdsrvnum,   ",
              "       datmservico.atdsrvano,   ",
              "       datmservico.atddat   ,   ",
              "       datmservico.pgtdat   ,   ",
              "       datmservico.atdsrvorg,   ",
              "       datmservico.atdcstvlr    ",
              "  from datrservapol, datmservico",
              " where datrservapol.succod     =  ?                       and",
              "       datrservapol.ramcod     =  ?                       and",
              "       datrservapol.aplnumdig  =  ?                       and",
              "       datrservapol.itmnumdig  =  ?                       and",
              "       datmservico.atdsrvnum   = datrservapol.atdsrvnum   and",
              "       datmservico.atdsrvano   = datrservapol.atdsrvano      "
 prepare sel_datrservapol from ws.sql
 declare c_datrservapol cursor with hold for sel_datrservapol

end function  ###  ctx05g00_prepare


#------------------------------------------------------------------
 function ctx05g00_select(param)
#------------------------------------------------------------------

 define param      record
    succod         like datrservapol.succod,
    ramcod         like datrservapol.ramcod,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    clcdatinc      date,
    clcdatfnl      date
 end record

 define ws         record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    atddat         like datmservico.atddat,
    pgtdat         like datmservico.atddat,
    atdsrvorg      like datmservico.atdsrvorg,
    atdcstvlr      like datmservico.atdcstvlr,
    socopgsitcod   like dbsmopg.socopgsitcod,
    totsrvqtd      dec (03,0),
    totsrvvlr      dec (15,5)
 end record




	initialize  ws.*  to  null

 initialize ws.*     to null

 let ws.totsrvqtd = 0
 let ws.totsrvvlr = 0.00

 open    c_datrservapol  using  param.succod,
                                param.ramcod,
                                param.aplnumdig,
                                param.itmnumdig
 foreach c_datrservapol  into   ws.atdsrvnum,
                                ws.atdsrvano,
                                ws.atddat,
                                ws.pgtdat,
                                ws.atdsrvorg,
                                ws.atdcstvlr

    if ws.atddat < param.clcdatinc  then
       continue foreach
    end if

    if ws.atddat > param.clcdatfnl  then
       continue foreach
    end if

    if ws.atdsrvorg <>  4   and   ###  Remocao por Sinistro
       ws.atdsrvorg <>  1   and   ###  Socorro
       ws.atdsrvorg <>  5   and   ###  R.P.T.
       ws.atdsrvorg <>  7   and   ###  Replace
       ws.atdsrvorg <>  2   and   ###  Assistencia a passageiros Transporte
       ws.atdsrvorg <>  3   then  ###  Assistencia a passageiros Hospedagem
       continue foreach
    end if

    if ws.atdcstvlr is null  then
       continue foreach
    end if

    if ws.pgtdat is not null  then
       let ws.totsrvqtd = ws.totsrvqtd + 1
       let ws.totsrvvlr = ws.totsrvvlr + ws.atdcstvlr
    else
       continue foreach
    end if
 end foreach

 return ws.totsrvqtd, ws.totsrvvlr

end function  ###  ctx05g00_select
