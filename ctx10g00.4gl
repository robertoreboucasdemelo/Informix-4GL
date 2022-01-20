#############################################################################
# Nome do Modulo: CTX10G00                                         Wagner   #
#                                                                           #
# Modulo verifica reservas validas 1-liber e ou 4-concluidas       Jan/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 12/09/2002  PSI 14582-3  Wagner       Criacao da funcao qtde de reservas  #
#                                       ctx10g00_qtdres.                    #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################

 database porto

# TESTE DE FUNCIONAMENTO
# define ws_flg  smallint
# main
#    call ctx10g00_qtdres(1, 19060013, 19)
#        returning ws_flg
#    display " --> ",ws_flg
# end main

#--------------------------------------------------------------------------
 function ctx10g00(param)
# Verifica se ha reservas 1-liber ou 4-concluidas com mesma data (sinistro)
#---------------------------------------------------------------------------

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
    avialgmtv      like datmavisrent.avialgmtv
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
 declare c_ctx10g00 cursor for
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

 foreach c_ctx10g00  into ws.c24astcod, ws.atdsrvnum,
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

    if ws.avioccdat = param.avioccdat then
       return true
    end if

 end foreach

 return false

end function


#---------------------------------------------------------------
 function ctx10g00_qtdres(param)
# Funcao retorna qtde de reservas efetuadas e validas por apolice
#---------------------------------------------------------------

 define param      record
    succod         like datrligapol.succod,
    aplnumdig      like datrligapol.aplnumdig,
    itmnumdig      like datrligapol.itmnumdig
 end record

 define ws         record
    comando        char (400),
    c24astcod      like datkassunto.c24astcod,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    atdetpcod      like datmsrvacp.atdetpcod,
    contares       integer
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
 prepare sel_datmsrvQ from ws.comando
 declare c_datmsrvQ   cursor for sel_datmsrvQ

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_ctx10g00_qtd cursor for
  select datmligacao.c24astcod , datmligacao.atdsrvnum ,
         datmligacao.atdsrvano
    from datrligapol,  datmligacao, datmavisrent
   where datrligapol.succod       = param.succod
     and datrligapol.ramcod       in (31,531)
     and datrligapol.aplnumdig    = param.aplnumdig
     and datrligapol.itmnumdig    = param.itmnumdig
     and datmligacao.lignum       = datrligapol.lignum
     and datmavisrent.atdsrvnum   = datmligacao.atdsrvnum
     and datmavisrent.atdsrvano   = datmligacao.atdsrvano

 let ws.contares = 0

 foreach c_ctx10g00_qtd  into ws.c24astcod, ws.atdsrvnum, ws.atdsrvano

    if ws.c24astcod <> "H10"  then
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvQ using ws.atdsrvnum ,ws.atdsrvano
    fetch c_datmsrvQ into  ws.atdetpcod
    close c_datmsrvQ

    if ws.atdetpcod =  1  or
       ws.atdetpcod =  4  then
       # somente servicos com etapas 1-lib ou 4-concl.
       let ws.contares = ws.contares + 1
    end if

 end foreach

 return ws.contares

end function
