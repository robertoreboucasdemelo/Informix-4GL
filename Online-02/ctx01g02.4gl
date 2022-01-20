###############################################################################
# Nome do Modulo: CTX01G02                                           Marcelo  #
#                                                                    Gilberto #
# Verifica inconsistencias para reintegracao de clausula Carro Extra Mar/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 04/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
#-----------------------------------------------------------------------------#
# 16/02/2001  PSI 10631-3  Wagner       Adaptacao acesso tabelas dbsmopgitm e #
#                                       dbsmopg para validacao pagto reserva. #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
###############################################################################

 database porto

#------------------------------------------------------------------
 function ctx01g02(param)
#------------------------------------------------------------------

 define param        record
    succod           like abbmitem.succod      ,
    aplnumdig        like abbmitem.aplnumdig   ,
    itmnumdig        like abbmitem.itmnumdig   ,
    privez           smallint
 end record

 define d_ctx01g02   record
    errcod           smallint                  ,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record




	initialize  d_ctx01g02.*  to  null

 initialize d_ctx01g02.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return d_ctx01g02.*
 end if

 if param.privez = true  then
    call ctx01g02_prepare()
 end if

 call ctx01g02_select(param.succod, param.aplnumdig, param.itmnumdig)
            returning d_ctx01g02.*

 return d_ctx01g02.*

end function  ###  ctx01g02


#------------------------------------------------------------------
 function ctx01g02_prepare()
#------------------------------------------------------------------

 define sql  char (700)


	let	sql  =  null

 let sql = "select datmavisrent.atdsrvnum,          ",
           "       datmavisrent.atdsrvano,          ",
           "       datmavisrent.avialgmtv,          ",
           "       datmservico.atdfnlflg            ",
           "  from datrservapol, datmavisrent, datmservico",
           " where datrservapol.succod    = ?    and",
           "       datrservapol.ramcod    in (31,531) and",
           "       datrservapol.aplnumdig = ?    and",
           "       datrservapol.itmnumdig = ?    and",
           "       datrservapol.atdsrvnum = datmavisrent.atdsrvnum and",
           "       datrservapol.atdsrvano = datmavisrent.atdsrvano and",
           "       datmservico.atdsrvnum  = datrservapol.atdsrvnum and",
           "       datmservico.atdsrvano  = datrservapol.atdsrvano"
 prepare sel_srvapl from sql
 declare c_srvapl cursor with hold for sel_srvapl

 let sql = "select atdsrvnum, atdsrvano",
           "  from dblmpagto           ",
           " where atdsrvnum  =  ?  and",
           "       atdsrvano  =  ?     "
 prepare sel_algpgt from sql
 declare c_algpgt cursor with hold for sel_algpgt

 let sql = "select atdetpcod    ",
           "  from datmsrvacp   ",
           " where atdsrvnum = ?",
           "   and atdsrvano = ?",
           "   and atdsrvseq = (select max(atdsrvseq)",
                               "  from datmsrvacp    ",
                               " where atdsrvnum = ? ",
                               "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from sql
 declare c_datmsrvacp cursor for sel_datmsrvacp

end function  ###  ctx01g02_prepare


#------------------------------------------------------------------
 function ctx01g02_select(param)
#------------------------------------------------------------------

 define param        record
    succod           like abbmitem.succod      ,
    aplnumdig        like abbmitem.aplnumdig   ,
    itmnumdig        like abbmitem.itmnumdig
 end record

 define ws           record
    atdsrvnum        like datmavisrent.atdsrvnum,
    atdsrvano        like datmavisrent.atdsrvano,
    avialgmtv        like datmavisrent.avialgmtv,
    atdfnlflg        like datmservico.atdfnlflg ,
    errcod           smallint                   ,
    qtdatd           smallint                   ,
    atdetpcod        like datmsrvacp.atdetpcod
 end record




	initialize  ws.*  to  null

 initialize ws.*     to null

 let ws.qtdatd = 0

 open    c_srvapl  using param.succod, param.aplnumdig, param.itmnumdig
 foreach c_srvapl  into  ws.atdsrvnum, ws.atdsrvano   ,
                         ws.avialgmtv, ws.atdfnlflg
    if ws.avialgmtv <> 1  then  ###  Motivo SINISTRO
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    #if ws.atdfnlflg is not null  and   ###  Situacao CANCELADO ou EXCLUIDO
    #   ws.atdfnlflg <> "C"       then
    #   continue foreach
    #end if
    open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod <> 1  and    ##  Etapa LIBERADA
       ws.atdetpcod <> 4  then   ##  ou ACIONADO
       continue foreach
    end if

    let ws.qtdatd = ws.qtdatd + 1

    open  c_algpgt using ws.atdsrvnum, ws.atdsrvano
    fetch c_algpgt
    if sqlca.sqlcode = notfound  then
       select dbsmopgitm.atdsrvnum
         from dbsmopgitm, dbsmopg
        where dbsmopgitm.atdsrvnum = ws.atdsrvnum
          and dbsmopgitm.atdsrvano = ws.atdsrvano
          and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
          and dbsmopg.socopgsitcod in (6,7)

       if sqlca.sqlcode = notfound  then
          exit foreach
       else
          initialize ws.atdsrvnum, ws.atdsrvano,
                     ws.avialgmtv, ws.atdfnlflg  to null
          continue foreach
       end if
    else
       initialize ws.atdsrvnum, ws.atdsrvano,
                  ws.avialgmtv, ws.atdfnlflg  to null
       continue foreach
    end if
    close c_algpgt
 end foreach

 if ws.qtdatd = 0  then
    let ws.errcod = 1
 else
    if ws.atdsrvnum is not null  and
       ws.atdsrvano is not null  then
       let ws.errcod = 2
    else
       let ws.errcod = 0
    end if
 end if

 return ws.errcod, ws.atdsrvnum, ws.atdsrvano

end function  ###  ctx01g02_select

#------------------------------------------------------------------
 function ctx01g02_erro(param)
#------------------------------------------------------------------

 define param        record
    errcod           smallint
 end record

 define ws           record
    errdes           char (50)
 end record




	initialize  ws.*  to  null

 initialize ws.*  to null

 case param.errcod
    when 0  let ws.errdes = "OK!"
    when 1  let ws.errdes = "APOLICE NAO POSSUI NENHUMA RESERVA DE CARRO EXTRA"
    when 2  let ws.errdes = "APOLICE POSSUI RESERVA NAO CONFIRMADA"
 end case

 return ws.errdes

end function  ###  ctx01g02_erro
