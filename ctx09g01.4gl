#############################################################################
# Nome do Modulo: CTX09G01                                         Raji     #
# Funcao de utilizacao das Clausulas 034 e 035                     NOV/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 11/09/2006  Ruiz                PSI            tarifa mes 10/2006         #
#                                                apurar todos os servicos   #
#                                                prestados a residencia do  #
#                                                segurado durante a vigencia#
#                                                da apolice.                #
#---------------------------------------------------------------------------#
 database porto

# TESTE DE FUNCIONAMENTO
 #main
 #
 # define d_ctx09g01_main record
 #    atddat         like datmservico.atddat,
 #    atdhor         like datmservico.atdhor,
 #    atdsrvnum      like datmservico.atdsrvnum,
 #    atdsrvano      like datmservico.atdsrvano,
 #    endnom         char (60),
 #    brrnom         like datmlcl.brrnom,
 #    cidnom         like datmlcl.cidnom,
 #    ufdcod         like datmlcl.ufdcod,
 #    c24astcod      like datkassunto.c24astcod,
 #    c24astdes      like datkassunto.c24astdes
 # end record
 #
 # let d_ctx09g01_main.atdsrvnum = 0
 # while d_ctx09g01_main.atdsrvnum is not NULL
 #   call ctx09g01(1,
 #                 19025064,
 #                 19,
 #                 d_ctx09g01_main.atddat,
 #                 d_ctx09g01_main.atdsrvnum,
 #                 d_ctx09g01_main.atdsrvano)
 #        returning
 #            d_ctx09g01_main.*
 #
 #    display d_ctx09g01_main.*
 # end while
 #
 #end main

#---------------------------------------------------------------
 function ctx09g01(param)
#---------------------------------------------------------------

 define param      record
    succod         like datrligapol.succod,
    aplnumdig      like datrligapol.aplnumdig,
    itmnumdig      like datrligapol.itmnumdig,
    atddat         like datmservico.atddat,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano
 end record

 define d_ctx09g01 record
    atddat         like datmservico.atddat,
    atdhor         like datmservico.atdhor,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    endnom         char (60),
    brrnom         like datmlcl.brrnom,
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    c24astcod      like datkassunto.c24astcod,
    c24astdes      like datkassunto.c24astdes
 end record

 define ws         record
    comando        char (400),
    dataini        date,
    socopgnum      like dbsmopgitm.socopgnum,
    socopgsitcod   like dbsmopg.socopgsitcod,
    atdetpcod      like datmsrvacp.atdetpcod,
    pgmflag        smallint,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    lgdnum         like datmlcl.lgdnum
 end record



	initialize  d_ctx09g01.*  to  null

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
 # Preparando SQL numero do pagamento
 #---------------------------------------------------------------
 let ws.comando  = "select socopgnum     ",
                   "  from dbsmopgitm    ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
 prepare sel_dbsmopgitm from ws.comando
 declare c_dbsmopgitm cursor for sel_dbsmopgitm

 #---------------------------------------------------------------
 # Preparando SQL pagamento situacao
 #---------------------------------------------------------------
 let ws.comando  = "select socopgsitcod  ",
                   "  from dbsmopg       ",
                   " where socopgnum = ? "
 prepare sel_dbsmopg from ws.comando
 declare c_dbsmopg cursor for sel_dbsmopg

 #---------------------------------------------------------------
 # Preparando SQL descricao dos assunto
 #---------------------------------------------------------------
 let ws.comando  = "select c24astdes     ",
                   "  from datkassunto   ",
                   " where c24astcod = ? "
 prepare sel_datkassunto from ws.comando
 declare c_datkassunto cursor for sel_datkassunto


 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 let ws.dataini  = today - 1 units year
 if param.atdsrvnum is NULL then
    let param.atdsrvnum = 0
 end if
 if param.atdsrvano is NULL then
    let param.atdsrvano = 0
 end if
 if param.atddat is NULL then
    let param.atddat = ws.dataini
 end if

 declare c_ctx09g01 cursor for
    select datmservico.atddat
         , datmservico.atdhor
         , datmservico.atdsrvnum
         , datmservico.atdsrvano
         , datmligacao.c24astcod
      from datrservapol, datmservico, datmligacao
     where datrservapol.aplnumdig =  param.aplnumdig
       and datrservapol.succod    =  param.succod
       and datrservapol.ramcod    in (31,531)
       and datrservapol.itmnumdig =  param.itmnumdig
       and datrservapol.atdsrvnum >  param.atdsrvnum
       and datrservapol.atdsrvano >= param.atdsrvano
       and datmservico.atddat     >= param.atddat
       and datmligacao.c24astcod  >= "S00"
       and datmligacao.c24astcod  <= "SZZ"
  #### and datmligacao.c24astcod  not in ("S60","S62","S63","S90","S93")

       and datrservapol.atdsrvnum = datmservico.atdsrvnum
       and datrservapol.atdsrvano = datmservico.atdsrvano
       and datmligacao.atdsrvnum  = datmservico.atdsrvnum
       and datmligacao.atdsrvano  = datmservico.atdsrvano
       and datmservico.atddat     >  ws.dataini
     order by 1,2

 foreach c_ctx09g01  into d_ctx09g01.atddat
                         ,d_ctx09g01.atdhor
                         ,d_ctx09g01.atdsrvnum
                         ,d_ctx09g01.atdsrvano
                         ,d_ctx09g01.c24astcod

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using d_ctx09g01.atdsrvnum
                            ,d_ctx09g01.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod = 4      then   # somente servicos etapa concluida
       #continue foreach
    end if


    #------------------------------------------------------------
    # Verifica pagamento dos servicos
    #------------------------------------------------------------
    let ws.pgmflag = 0
    open  c_dbsmopgitm using d_ctx09g01.atdsrvnum
                            ,d_ctx09g01.atdsrvano
    foreach c_dbsmopgitm into  ws.socopgnum
        open  c_dbsmopg using ws.socopgnum
        fetch c_dbsmopg into  ws.socopgsitcod
           if ws.socopgsitcod = 6 or
              ws.socopgsitcod = 7 then
              # OP JA' PAGA
              let ws.pgmflag = 1
           end if
        close c_dbsmopg
    end foreach
    if ws.pgmflag = 0 then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Busca servico -> Local
    #---------------------------------------------------------------
    select lgdtip,
           lgdnom,
           lgdnum,
           brrnom,
           cidnom,
           ufdcod  into
           ws.lgdtip,
           ws.lgdnom,
           ws.lgdnum,
           d_ctx09g01.brrnom,
           d_ctx09g01.cidnom,
           d_ctx09g01.ufdcod
      from datmlcl
     where atdsrvnum = d_ctx09g01.atdsrvnum
       and atdsrvano = d_ctx09g01.atdsrvano
       and c24endtip = 1
    let d_ctx09g01.endnom = ws.lgdtip clipped, " "  ,
                            ws.lgdnom clipped, ", " ,
                            ws.lgdnum clipped

    open  c_datkassunto using d_ctx09g01.c24astcod
    fetch c_datkassunto into  d_ctx09g01.c24astdes
    close c_datkassunto

    # Retorna servico
    return d_ctx09g01.atddat
          ,d_ctx09g01.atdhor
          ,d_ctx09g01.atdsrvnum
          ,d_ctx09g01.atdsrvano
          ,d_ctx09g01.endnom
          ,d_ctx09g01.brrnom
          ,d_ctx09g01.cidnom
          ,d_ctx09g01.ufdcod
          ,d_ctx09g01.c24astcod
          ,d_ctx09g01.c24astdes

 end foreach
 return "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
end function
