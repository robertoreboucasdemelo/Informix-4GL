#############################################################################
# Nome do Modulo: CTX10G01                                         Wagner   #
#                                                                           #
# Funcao verifica e retorna o valor da reserva                     Jul/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################

 database porto

# TESTE DE FUNCIONAMENTO
# define ws_valor   dec(15,5)
# main
#    call ctx10g01(1, 19050107, 19, "28/06/2001")
#        returning ws_valor
#    display " --> ",ws_valor
# end main

#---------------------------------------------------------------
 function ctx10g01(param)
#---------------------------------------------------------------

 define param      record
    succod         like datrligapol.succod,
    aplnumdig      like datrligapol.aplnumdig,
    itmnumdig      like datrligapol.itmnumdig,
    avioccdat      like datmavisrent.avioccdat
 end record

 define ws         record
    comando        char (400),
    c24astcod      like datkassunto.c24astcod,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    avioccdat      like datmavisrent.avioccdat,
    atdetpcod      like datmsrvacp.atdetpcod,
    avialgmtv      like datmavisrent.avialgmtv,
    socopgitmvlr   like dbsmopgitm.socopgitmvlr
 end record



	initialize  ws.*  to  null

 set isolation to dirty read

 initialize ws.*          to null

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
 let ws.socopgitmvlr = 0
 declare c_ctx10g01 cursor for
  select datmligacao.c24astcod , datmligacao.atdsrvnum ,
         datmligacao.atdsrvano , datmavisrent.avioccdat,
         datmavisrent.avialgmtv
    from datrligapol,  datmligacao, datmavisrent
   where datrligapol.succod       = param.succod
     and datrligapol.ramcod       in (31,531)
     and datrligapol.aplnumdig    = param.aplnumdig
     and datrligapol.itmnumdig    = param.itmnumdig
     and datmligacao.lignum       = datrligapol.lignum
     and datmavisrent.atdsrvnum   = datmligacao.atdsrvnum
     and datmavisrent.atdsrvano   = datmligacao.atdsrvano

 foreach c_ctx10g01  into ws.c24astcod, ws.atdsrvnum,
                          ws.atdsrvano, ws.avioccdat,
                          ws.avialgmtv

    if ws.c24astcod <> "H10"  then
       continue foreach
    end if

    if ws.avialgmtv <> 3      then     # Benef.Oficinas
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using ws.atdsrvnum ,ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod =  1  or
       ws.atdetpcod =  4  then
       # somente servicos com etapas 1-lib ou 4-concl.
    else
       continue foreach
    end if

    if param.avioccdat is not null    and
       param.avioccdat = ws.avioccdat then
       declare c_reservas cursor for
        select dbsmopgitm.socopgitmvlr
          from dbsmopgitm, dbsmopg
         where dbsmopgitm.atdsrvnum = ws.atdsrvnum
           and dbsmopgitm.atdsrvano = ws.atdsrvano
           and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
           and dbsmopg.socopgsitcod <> 8
       let ws.socopgitmvlr = 0
       foreach c_reservas into ws.socopgitmvlr
          exit foreach
       end foreach
    end if

    if ws.socopgitmvlr is not null and
       ws.socopgitmvlr <> 0        then
       exit foreach
    end if

 end foreach

 return ws.socopgitmvlr

end function
