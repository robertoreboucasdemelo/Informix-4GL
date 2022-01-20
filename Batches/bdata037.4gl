#############################################################################
# Nome do Modulo: BDATA037                                         Marcelo  #
#                                                                  Gilberto #
# Gravacao das ligacoes a serem removidas                          Abr/1997 #
#############################################################################
#                                                                           #
#   datmligacao    datrligapol    agbmlimpa    datmlimplig (banco WORK)     #
#                                                                           #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/06/1999  ** ERRO **   Gilberto     Substituir tipo da variavel QTD de  #
#                                       SMALLINT para INTEGER.              #
#---------------------------------------------------------------------------#
# 28/06/1999               Gilberto     Incluir displays para exibicao da   #
#                                       quantidade de registros.            #
#---------------------------------------------------------------------------#
# 13/07/1999               Gilberto     Otimizar rotina de re-start         #
#---------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                        #
#############################################################################
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica    Origem    Alteracao                          #
# ----------  --------------   --------- -----------------------------------#
# 10/09/2005  James, Meta      Melhorias Melhorias de performance           #
#---------------------------------------------------------------------------#
# 16/11/2006 Alberto Rodrigues 205206  implementado leitura campo ciaempcod #
#                                      para desprezar qdo for Azul Segur.   #
#                                                                           #
# 31/08/2007 Roberto Melo              implementado leitura campo ciaempcod #
#                                      para desprezar qdo for PortoSeg.     #
#                                                                           #
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto  #
#                                      como sendo o agrupamento, buscar cod #
#                                      agrupamento.                         #
#############################################################################



 database porto

 define qtdgrv    integer
 define qtddoc    integer
 define qtddat    integer
 define qtdlig    integer
 define qtdapl    integer

 main
    set isolation to dirty read
    call bdata037()
 end main

#---------------------------------------------------------------
 function bdata037()
#---------------------------------------------------------------

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 let qtdgrv = 0
 let qtddoc = 0
 let qtddat = 0
 let qtdlig = 0
 let qtdapl = 0

#---------------------------------------------------------------
# Cria tabela no banco WORK
#---------------------------------------------------------------
 call fun_dba_abre_banco("CT24HS")

# close database
 database work

 call DB_create()

 select count(*) into qtdgrv
   from work:datmlimplig

 close database
 database porto

 call bdata037_prepare()

#---------------------------------------------------------------
# Processamento
#---------------------------------------------------------------

 call bdata037_doc()
 call bdata037_dat()

#---------------------------------------------------------------
# Cria indice para tabela DATMLIMPLIG - banco WORK
#---------------------------------------------------------------

 close database
 database work

 call DB_index()

 call bdata037_resumo(3,"")

 end function  ###  bdata037

#---------------------------------------------------------------
 function bdata037_prepare()
#---------------------------------------------------------------

 define ws          record
    sql             char (500)
 end record

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------

 let ws.sql = "select succod, aplnumdig,",
              "       atldat, aplexcflg ",
              "  from agbmlimpa         ",
              " where atldat    >= ?    ",
              "   and succod    >= ?    ",
              "   and aplnumdig >= ?    "
 prepare sel_agbmlimpa from ws.sql
 declare c_agbmlimpa cursor with hold for sel_agbmlimpa

 let ws.sql = "select datmligacao.lignum             ",
              "  from datrligapol, datmligacao       ",
              " where datrligapol.succod    = ?  and ",
              "       datrligapol.ramcod in (31,531) and ",
              "       datrligapol.aplnumdig = ?  and ",
              "       datmligacao.lignum    = datrligapol.lignum"
 prepare sel_lig_apol from ws.sql
 declare c_lig_apol cursor with hold for sel_lig_apol

 #PSI 230650
 #let ws.sql = "select lignum, ligdat, c24astcod, ciaempcod ",
 #             "  from datmligacao   ",
 #             " where ligdat <= ?   "
 let ws.sql = "select lignum, ligdat, a.c24astcod, ciaempcod, c24astagp ",
              "  from datmligacao a, datkassunto b  ",
              " where ligdat <= ?   ",
              "   and a.c24astcod = b.c24astcod "
 prepare sel_datmligacao from ws.sql
 declare c_datmligacao cursor with hold for sel_datmligacao
 #PSI 230650 - fim

 let ws.sql = "select ramcod      ",
              "  from datrligapol ",
              " where lignum = ?  "
 prepare sel_datrligapol from ws.sql
 declare c_datrligapol cursor with hold for sel_datrligapol

 let ws.sql = "update igbkgeral ",
              "   set (grlinf, atlult) = (?,?)",
              " where mducod = 'C24'",
              "   and grlchv = ?"
 prepare upd_igbkgeral from ws.sql

 let ws.sql = "select ligexcflg       ",
              "  from work:datmlimplig",
              " where lignum = ?"
 prepare sel_datmlimplig from ws.sql
 declare c_datmlimplig cursor with hold for sel_datmlimplig

 let ws.sql = "insert into work:datmlimplig ",
              "  (lignum, ligexcflg, atldat, atlhor)",
              "  values (?,'N',?,?)"
 prepare ins_datmlimplig from ws.sql

#---------------------------------------------------------------
# Limpeza RAMOS ELEMENTARES desabilitada temporariamente
#---------------------------------------------------------------
#let ws.sql = "select sgrorg, sgrnumdig ",
#             "  from rsamseguro        ",
#             " where succod    = ?  and",
#             "       ramcod    = ?  and",
#             "       aplnumdig = ?     "
#
#prepare sel_rsamseguro from ws.sql
#declare c_rsamseguro cursor with hold for sel_rsamseguro

end function  ###  bdata037_prepare

#---------------------------------------------------------------
 function bdata037_doc()
#---------------------------------------------------------------

 define d_bdata037  record
    lignum          like datmligacao.lignum    ,
    succod          like datrligapol.succod    ,
    aplnumdig       like datrligapol.aplnumdig ,
    atldat          like agbmlimpa.atldat
 end record

 define ws          record
    restart         smallint                   ,
    ramcod          like datrligapol.ramcod    ,
    atldat          like agbmlimpa.atldat      ,
    succod          like agbmlimpa.succod      ,
    aplnumdig       like agbmlimpa.aplnumdig   ,
    qtdrst          dec (2,0)                  ,
    ibkupdflg       dec (1,0)                  ,
    grlchv          like igbkgeral.grlchv      ,
    grlinf          like igbkgeral.grlinf      ,
    atlult          like igbkgeral.atlult      ,
    aplexcflg       like agbmlimpa.aplexcflg
 end record

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdata037.*  to null
 initialize ws.*          to null

 let ws.grlchv    = "LIMP_CT24HS_DOC"
 let ws.ibkupdflg = false

#---------------------------------------------------------------
# Verifica necessidade de 're-start' do programa
#---------------------------------------------------------------

 select grlinf, atlult
   into ws.grlinf, ws.atlult
   from igbkgeral
  where mducod = "C24"  and
        grlchv = ws.grlchv

 if sqlca.sqlcode < 0  then
    display "Erro (", sqlca.sqlcode, ") na leitura dos parametros (IGBKGERAL)!"
    exit program (1)
 else
    if sqlca.sqlcode = notfound  then   ###  Se nao existir, cria controle
       let ws.restart = false

       let ws.qtdrst    = 00
       let ws.succod    = 00
       let ws.aplnumdig = 000000000
       let ws.atldat    = "01/01/1950"

       let ws.grlinf = ws.atldat, ws.succod using "&&", ws.aplnumdig using "&&&&&&&&&", ws.qtdrst using "&&"

       call bdata037_igbk("I",ws.grlchv,ws.grlinf)
    else
       let ws.atldat    = ws.grlinf[01,10]
       let ws.succod    = ws.grlinf[11,12]
       let ws.aplnumdig = ws.grlinf[13,21]

       if ws.grlinf[22,23] = "OK"  then
          let ws.restart = false
          let ws.qtdrst  = 00
       else
          let ws.restart = true
          let ws.qtdrst = ws.grlinf[22,23]

          let ws.qtdrst = ws.qtdrst + 1

          display "-------------------------------------------------------------------------"
          display "            ATENCAO! Rotina de RE-START acionada (", ws.qtdrst using "<<", "a. vez) ..."
          display "            Ultimo acionamento: ", ws.atlult
          display "-------------------------------------------------------------------doct--"
       end if

       let ws.grlinf = ws.atldat, ws.succod using "&&", ws.aplnumdig using "&&&&&&&&&", ws.qtdrst using "&&"

       call bdata037_igbk("M", ws.grlchv, ws.grlinf)
    end if
 end if

#---------------------------------------------------------------
# Leitura das apolices removidas
#---------------------------------------------------------------

 begin work

 open    c_agbmlimpa using ws.atldat, ws.succod, ws.aplnumdig
 foreach c_agbmlimpa into  d_bdata037.succod   ,
                           d_bdata037.aplnumdig,
                           d_bdata037.atldat   ,
                           ws.aplexcflg

    let qtdapl = qtdapl + 1

    if d_bdata037.atldat <> ws.atldat  then
       let ws.atldat    = d_bdata037.atldat
       let ws.succod    = d_bdata037.succod
       let ws.aplnumdig = d_bdata037.aplnumdig

       let ws.ibkupdflg   = true
    end if

    if qtdlig >= 10000  then
       commit work
       begin work

       let ws.ibkupdflg = true
       let qtddoc = qtddoc + qtdlig
       let qtdlig = 0

       call bdata037_resumo(1,"")
    end if

    if ws.ibkupdflg = true  then
       let ws.grlinf = ws.atldat, ws.succod using "&&", ws.aplnumdig using "&&&&&&&&&", ws.qtdrst using "&&"

       call bdata037_igbk("M", ws.grlchv, ws.grlinf)

       let ws.ibkupdflg = false
    end if

#---------------------------------------------------------------
# Verifica se apolice ja' foi removida
#---------------------------------------------------------------
    if ws.aplexcflg = "n"  then
       continue foreach
    end if

    open    c_lig_apol using d_bdata037.succod   ,
                             d_bdata037.aplnumdig
    foreach c_lig_apol into  d_bdata037.lignum

       let qtdlig = qtdlig + 1

#---------------------------------------------------------------
# Verifica se ligacao ja' foi gravada em caso de re-start
#---------------------------------------------------------------

       if ws.restart = true  then
          if bdata037_grav(d_bdata037.lignum) is not null  then
             continue foreach
          end if
       end if

#---------------------------------------------------------------
# Grava tabela WORK com ligacoes a serem removidas
#---------------------------------------------------------------

       call bdata037_work(d_bdata037.lignum)

       let qtdgrv = qtdgrv + 1
    end foreach
 end foreach

 commit work

#---------------------------------------------------------------
# Atualiza flag de re-start. Processamento OK!
#---------------------------------------------------------------
 let ws.atldat    = d_bdata037.atldat
 let ws.succod    = d_bdata037.succod
 let ws.aplnumdig = d_bdata037.aplnumdig
 let ws.grlinf = ws.atldat, ws.succod using "&&", ws.aplnumdig using "&&&&&&&&&", "OK"

 let qtddoc = qtddoc + qtdlig
 let qtdlig = 0

 call bdata037_resumo(1,"")

 call bdata037_igbk("M", ws.grlchv, ws.grlinf)

end function  ###  bdata037_doc

#---------------------------------------------------------------
 function bdata037_dat()
#---------------------------------------------------------------

 define d_bdata037  record
    lignum          like datmligacao.lignum    ,
    ligdat          like datmligacao.ligdat    ,
    ciaempcod          like datmligacao.ciaempcod
 end record

 define ws          record
    ramcod          like datrligapol.ramcod    ,
    pardat          date                       ,
    pardat1         date                       ,
    auxano          char (04)                  ,
    auxdat          char (10)                  ,
    qtdrst          dec (2,0)                  ,
    grlchv          like igbkgeral.grlchv      ,
    grlinf          like igbkgeral.grlinf      ,
    atlult          like igbkgeral.atlult      ,
    restart         smallint                   ,
    tempo           datetime year to second    ,
    c24astcod       like datmligacao.c24astcod ,
    c24astagp       like datkassunto.c24astagp
 end record

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdata037.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# Data parametro para remocao de ligacoes sem documento
#---------------------------------------------------------------

 let ws.auxdat = today
 let ws.auxano = current year to year
 let ws.auxano = ws.auxano - 1

 let ws.auxdat = "01/", ws.auxdat[4,5], "/", ws.auxano
 let ws.pardat = ws.auxdat

 # --> DATA PARA REMOCAO DOS ASSUNTOS X, W, SUG E Z00
 # --> IMPLEMENTACAO REALIZADA DIA 18/01/2006
 let ws.pardat1 = (ws.pardat - 4 units year)

#---------------------------------------------------------------
# Verifica necessidade de 're-start' do programa
#---------------------------------------------------------------

 let ws.grlchv = "LIMP_CT24HS_DAT"

 select grlinf, atlult
   into ws.grlinf, ws.atlult
   from igbkgeral
  where mducod = "C24"  and
        grlchv = ws.grlchv

 if sqlca.sqlcode < 0  then
    display "Erro (", sqlca.sqlcode, ") na leitura dos parametros (IGBKGERAL)!"
    exit program (1)
 else
    if sqlca.sqlcode = notfound  then
       let ws.restart = false

       let ws.qtdrst = 00
       let ws.grlinf = ws.pardat, ws.qtdrst using "&&"

       call bdata037_igbk("I", ws.grlchv, ws.grlinf)
    else
       let ws.restart = true
       let ws.pardat  = ws.grlinf[01,10]
       let ws.qtdrst  = ws.grlinf[11,12]

       let ws.qtdrst = ws.qtdrst + 1

       display "-------------------------------------------------------------------------"
       display "            ATENCAO! Rotina de RE-START acionada (", ws.qtdrst using "<<", "a. vez) ..."
       display "            Ultimo acionamento: ", ws.atlult
       display "-------------------------------------------------------------------data--\n"

       let ws.grlinf = ws.pardat, ws.qtdrst using "&&"

       call bdata037_igbk("M", ws.grlchv, ws.grlinf)
    end if
 end if

#---------------------------------------------------------------
# Leitura das ligacoes sem documento informado
#---------------------------------------------------------------

 begin work

 open    c_datmligacao using ws.pardat
 foreach c_datmligacao into  d_bdata037.lignum,
                             d_bdata037.ligdat,
                             ws.c24astcod,
                             d_bdata037.ciaempcod,
                             ws.c24astagp

    if d_bdata037.ciaempcod = 35 or
       d_bdata037.ciaempcod = 40 or
       d_bdata037.ciaempcod = 43 or 
       d_bdata037.ciaempcod = 84 or
       d_bdata037.ciaempcod = 27 then ## PSI Empresa 27
       continue foreach
    end if

    let qtdlig = qtdlig + 1

    if d_bdata037.ligdat <> ws.pardat  then
       let ws.pardat = d_bdata037.ligdat

       let ws.grlinf = ws.pardat, ws.qtdrst using "&&"

       call bdata037_igbk("M", ws.grlchv, ws.grlinf)
    end if

    if qtdlig >= 10000  then
       commit work
       begin work

       let qtddat = qtddat + qtdlig
       let qtdlig = 0

       call bdata037_resumo(2,ws.pardat)
    end if

    #if ws.c24astcod[1,1] = "X"   or
    #   ws.c24astcod[1,1] = "W"   or
    if ws.c24astagp      = "X"   or
       ws.c24astagp      = "W"   or
       ws.c24astcod      = "ISU" or
       ws.c24astcod      = "I99" or
       ws.c24astcod      = "I98" or  
       ws.c24astcod      = "P24" or 
       ws.c24astcod      = "P25" or 
       ws.c24astcod      = "SUG" or
       ws.c24astcod      = "Z00" then
       # --> ESTAS LIGACOES NAO SERAO REMOVIDAS DURANTE 5 ANOS A PARTIR
       # --> DA DATA DA LIGACAO, POIS FAZEM PARTE DA INTERFACE COM O SAC
       # --> IMPLEMENTACAO REALIZADA NO DIA 18/01/2006 (PATRICIA FOGACA/SILMARA)

       if d_bdata037.ligdat > ws.pardat1 then
          continue foreach
       end if

    end if

    open  c_datrligapol using d_bdata037.lignum
    fetch c_datrligapol into  ws.ramcod
    if sqlca.sqlcode = 0  then
#---------------------------------------------------------------
# Limpeza RAMOS ELEMENTARES desabilitada temporariamente
#---------------------------------------------------------------
# Se for RAMOS ELEMENTARES, verifica se apolice existe
#---------------------------------------------------------------
#      if ws.ramcod <> 31  and
#         ws.ramcod <> 531 then
#         open  c_rsamseguro using d_bdata037.succod   ,
#                                  ws.ramcod           ,
#                                  d_bdata037.aplnumdig
#         fetch c_rsamseguro
#         if sqlca.sqlcode = notfound  then
#         else
#            continue foreach
#         end if
#         close c_rsamseguro
#      end if
#   else
#---------------------------------------------------------------
       continue foreach
    end if
    close c_datrligapol

#---------------------------------------------------------------
# Verifica se ligacao ja' foi gravada em caso de re-start
#---------------------------------------------------------------

    if ws.restart = true  then
       if bdata037_grav(d_bdata037.lignum) is not null  then
          continue foreach
       end if
    end if

#---------------------------------------------------------------
# Grava tabela WORK com ligacoes a serem removidas
#---------------------------------------------------------------

    call bdata037_work(d_bdata037.lignum)

    let qtdgrv = qtdgrv + 1
 end foreach

 commit work

 let qtddat = qtddat + qtdlig

 call bdata037_resumo(2, ws.pardat)

#---------------------------------------------------------------
# Remove flag de re-start. Processamento OK!
#---------------------------------------------------------------

 delete from igbkgeral
  where mducod = 'C24'  and
        grlchv = ws.grlchv

end function  ###  bdata037_dat

#---------------------------------------------------------------
 function bdata037_work(param)
#---------------------------------------------------------------

 define param       record
    lignum          like datmligacao.lignum
 end record

 define ws          record
    atldat          date                       ,
    atlhor          datetime hour to second
 end record

 let ws.atldat = today
 let ws.atlhor = current

 execute ins_datmlimplig using param.lignum, ws.atldat, ws.atlhor

 if sqlca.sqlcode  <>  0   then
    display "Erro (",sqlca.sqlcode,") na gravacao da tabela DATMLIMPLIG!"
    exit program (1)
 end if

end function  ###  bdata037_work

#---------------------------------------------------------------
 function bdata037_grav(param)
#---------------------------------------------------------------

 define param       record
    lignum          like datmligacao.lignum
 end record

 define ws          record
    ligexcflg       char (01)
 end record

 initialize ws.ligexcflg to null

 open  c_datmlimplig using param.lignum
 fetch c_datmlimplig into  ws.ligexcflg
 close c_datmlimplig

 return ws.ligexcflg

end function  ###  bdata037_grav

#---------------------------------------------------------------
 function bdata037_igbk(param)
#---------------------------------------------------------------

 define param       record
    operac          char (01),
    grlchv          like igbkgeral.grlchv,
    grlinf          like igbkgeral.grlinf
 end record

 define ws          record
    atlult          like igbkgeral.atlult,
    auxhor          datetime hour to second
 end record

 let ws.auxhor = current hour to second
 let ws.atlult = today, " ", ws.auxhor

 if param.operac = "I"  then
    insert into igbkgeral
           (mducod, grlchv, grlinf, atlult)
    values ("C24",param.grlchv,param.grlinf,ws.atlult)
 else
    execute upd_igbkgeral using param.grlinf, ws.atlult, param.grlchv
 end if

 if sqlca.sqlcode <> 0  then
    display "Erro (", sqlca.sqlcode, ") na atualizacao dos parametros (IGBKGERAL)!"
    exit program (1)
 end if

end function  ###  bdata037_igbk

#---------------------------------------------------------------
 function bdata037_resumo(param)
#---------------------------------------------------------------

 define param       record
    partip          char (01),
    pardat          date
 end record

 define ws          record
    tempo           datetime year to second
 end record

 let ws.tempo = current year to second

 display "\n-------------------------------------------------------------------------"

 if param.partip = 1  then
    display "  SITUACAO PARCIAL EM ", ws.tempo
    display "      Documentos lidos......: ", qtdapl
    display "      Ligacoes processadas..: ", qtddoc
    display "      Ligacoes gravadas.....: ", qtdgrv
    display "------------------------------------------------------------------docto--"
 else
    if param.partip = 2  then
       display "  SITUACAO PARCIAL EM ", ws.tempo
       display "      Data parametro........:  ", param.pardat
       display "      Ligacoes processadas..: ", qtddat
       display "      Ligacoes gravadas.....: ", qtdgrv
       display "-------------------------------------------------------------------data--"
    else
       display "              TERMINO DO PROCESSAMENTO - SITUACAO FINAL                    \n"
       display "      Ligacoes gravadas.....: ", qtdgrv
       display "      Ligacoes com documento: ", qtddoc
       display "      Ligacoes sem documento: ", qtddat
       display "------------------------------------------------------------------final--"
    end if
 end if

end function  ###  bdata037_resumo

#---------------------------------------------------------------
 function DB_create()
#---------------------------------------------------------------

 whenever error continue

 create table datmlimplig ( lignum       dec(10,0) not null,
                            ligexcflg    char(001) not null,
                            atldat       date not null,
                            atlhor       datetime hour to minute not null)

 if sqlca.sqlcode <> 0     and
    sqlca.sqlcode <> -310  then
    display "*** ERRO (",sqlca.sqlcode,") na criacao da tabela DATMLIMPLIG! ***"
    exit program (1)
 end if

 whenever error stop

end function  ###  DB_create

#---------------------------------------------------------------
 function DB_index()
#---------------------------------------------------------------

 whenever error continue

 create unique index ndx_lignum on datmlimplig (lignum)

 if sqlca.sqlcode <> 0     and
    sqlca.sqlcode <> -316  then
    display "*** ERRO (", sqlca.sqlcode, ") na criacao do indice! ***"
    exit program (1)
 end if

 whenever error stop

end function  ###  DB_index
