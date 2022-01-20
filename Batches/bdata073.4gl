################################################################################
# Nome do Modulo: bdata073                                            Marcelo  #
#                                                                     Gilberto #
# Extracao diaria de pagamentos                                       Set/1999 #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 22/05/2000  PSI 10666-6  Wagner       ADENDO incluir gravacao favorecido.    #
#------------------------------------------------------------------------------#
# 19/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.      #
#------------------------------------------------------------------------------#
# 05/03/2002  CORREIO EDU  Raji         Adaptacao pagamento srv. RE.           #
#------------------------------------------------------------------------------#
# 16/04/2002  PSI 15190-4  Raji         Inclusao do custo acertado do srv.     #
#------------------------------------------------------------------------------#
# 02/05/2006  PSI 200328  Cleucio       Altera origem Data Pagamento           #
################################################################################
#                  * * *  A L T E R A C O E S  * * *                           #
#                                                                              #
# Data       Autor Fabrica         PSI    Alteracoes                           #
# ---------- --------------------- ------ -------------------------------------#
# 10/09/2005 Helio (Meta)       Melhorias incluida funcao fun_dba_abre_banco.  #
# ---------- --------------------- ------ -------------------------------------#
# 16/11/2006 Alberto Rodrigues     205206 implementado leitura campo ciaempcod #
#                                         para desprezar qdo for Azul Segur.   #
#------------------------------------------------------------------------------#
# 19/05/2007 Alberto Rodrigues     207446 Desprezar serviços SAF-Assist.Funeral#
#                                         atdsrvorg(origem)18                  #
#------------------------------------------------------------------------------#
# 31/08/2007 Roberto Melo                 implementado leitura campo ciaempcod #
#                                         para desprezar qdo for PortoSeg.     #
#                                                                              #
################################################################################

 database porto

 main
   call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read

    call bdata073()
 end main

#---------------------------------------------------------------
 function bdata073()
#---------------------------------------------------------------

 define d_bdata073  record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    lignum          like datmligacao.lignum,
    atdsrvorg       like datmservico.atdsrvorg,
    pstcoddig       like dbsmopg.pstcoddig,
    socopgnum       like dbsmopg.socopgnum,
    socopgitmvlr    like dbsmopgitm.socopgitmvlr,
    socfatpgtdat    like dbsmopg.socfatpgtdat,               # PSI 200328
    socopgfashor    like dbsmopgfas.socopgfashor,
    funmat          like dbsmopgfas.funmat,
    socopgfavnom    like dbsmopgfav.socopgfavnom,
    pestip          like dbsmopgfav.pestip,
    cgccpfnum       like dbsmopgfav.cgccpfnum,
    cgcord          like dbsmopgfav.cgcord,
    cgccpfdig       like dbsmopgfav.cgccpfdig,
    funmatcst       like datmpreacp.cadmat,
    srvinccst       like datmpreacp.srvinccst,
    ciaempcod       like datmligacao.ciaempcod
 end record

 define w_bdata073  record
    pgttmpdimcod    integer,
    pgtfundimcod    integer,
    favdimcod       integer,
    cstfundimcod    integer
 end record

 define ws          record
    sql             char (900)              ,
    tabnom          char (30)               ,
    sqlcod          integer                 ,
    tempo           datetime year to second ,
    hostname        char (20)               ,
    rstqtd          dec  (2,0)              ,
    rstdat          char (10)               ,
    pstcoddig       like dpaksocor.pstcoddig,
    grlinf          like igbkgeral.grlinf   ,
    atlult          like igbkgeral.atlult   ,
    pardat          date                    ,
    auxdat          char (10)               ,
    auxhor          datetime hour to second ,
    qtdlid          integer                 ,
    qtd_saude       integer                 ,
    qtd_azul        integer                 ,
    qtd_portoseg    integer                 ,
    qtd_pss         integer                 ,
    qtdgrv          integer                 ,
    qtderr          integer
 end record

 define w_priveztmp dec(1,0),
        w_privezfun dec(1,0),
        w_privezfav dec(1,0)

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdata073.*  to null
 initialize w_bdata073.*  to null
 initialize ws.*          to null

 let w_priveztmp = true
 let w_privezfun = true
 let w_privezfav = true

#---------------------------------------------------------------
# Data parametro para extracao dos pagamentos de servicos
#---------------------------------------------------------------

 let ws.auxdat = arg_val(1)

 if ws.auxdat is null  or
    ws.auxdat =  "  "  then
    if time >= "20:00"  and
       time <= "23:59"  then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
    if ws.auxdat > today       or
       length(ws.auxdat) < 10  then
       display "*** ERRO NO PARAMETRO: ", ws.auxdat, " - DATA INVALIDA! ***"
       exit program (1)
    end if
 end if

 let ws.pardat = ws.auxdat

 let ws.auxdat = today
 let ws.auxhor = current hour to second

#---------------------------------------------------------------
# Verifica banco de dados utilizado (desenvolvimento ou producao)
#---------------------------------------------------------------

 let ws.hostname = ctr09g00_host()

#---------------------------------------------------------------
# Verifica necessidade de 're-start' do programa
#---------------------------------------------------------------

 select grlinf, atlult
   into ws.grlinf, ws.atlult
   from igbkgeral
  where mducod = "C24"  and
        grlchv = "DATAMART-PAGTO"

 if sqlca.sqlcode < 0  then
    display "Erro (", sqlca.sqlcode using "<<<<<<", ") na leitura dos parametros (IGBKGERAL)!"
    exit program (1)
 else
    if sqlca.sqlcode = notfound  then
       let ws.pstcoddig = 000000
       let ws.atlult = today, " ", ws.auxhor
       let ws.grlinf = ws.pardat
       let ws.grlinf = ws.grlinf clipped, "00", ws.pstcoddig using "&&&&&&"

       insert into igbkgeral
              (mducod, grlchv, grlinf, atlult)
       values ("C24","DATAMART-PAGTO", ws.grlinf, ws.atlult)

       if sqlca.sqlcode <> 0  then
          display "Erro (", sqlca.sqlcode using "<<<<<<", ") na gravacao dos parametros (IGBKGERAL)!"
          exit program (1)
       end if
    else
       let ws.rstdat    = ws.grlinf[01,10]
       let ws.rstqtd    = ws.grlinf[12,13] clipped + 1
       let ws.pstcoddig = ws.grlinf[14,19]

       if ws.rstdat is null  then
          display "Erro na recuperacao da data parametro!"
          exit program (1)
       end if

       let ws.pardat = ws.rstdat

       let ws.grlinf = ws.pardat
       let ws.grlinf = ws.grlinf clipped, " ", ws.rstqtd using "&&", ws.pstcoddig using "&&&&&&"
       let ws.atlult = today, " ", ws.auxhor

       display ""
       display "                      ATENCAO! Rotina de RE-START acionada (", ws.rstqtd using "<<", "a. vez) ..."
       display "                      Data de extracao..: ", ws.pardat
       display "                      Prestador Servicos: ", ws.pstcoddig
       display "                      Ultimo acionamento: ", ws.atlult
       display ""

       update igbkgeral
          set (grlinf, atlult)
            = (ws.grlinf, ws.atlult)
        where mducod = "C24"  and
              grlchv = "DATAMART-PAGTO"

       if sqlca.sqlcode <> 0  then
          display "Erro (", sqlca.sqlcode using "<<<<<<", ") na atualizacao dos parametros (IGBKGERAL)!"
          exit program (1)
       end if
    end if
 end if

#---------------------------------------------------------------
# Definicao dos comandos SQL
#---------------------------------------------------------------

 let ws.sql = "select dbsmopg.pstcoddig      ,",
              "       dbsmopg.socopgnum      ,",
              "       dbsmopgitm.socopgitmvlr,",
              "       dbsmopgitm.atdsrvnum   ,",
              "       dbsmopgitm.atdsrvano   ,",
              "       dbsmopg.socfatpgtdat    ",             # PSI 200328
              "  from dbsmopg, dbsmopgitm     ",
              " where dbsmopg.socfatpgtdat = ?",
              "   and dbsmopg.pstcoddig   >= ?",
              "   and dbsmopg.socopgsitcod = 7",
              "   and dbsmopgitm.socopgnum = dbsmopg.socopgnum"
 prepare sel_dbsmopg from ws.sql
 declare c_dbsmopg cursor with hold for sel_dbsmopg

 let ws.sql = "select socopgfashor,    ",                     #PSI 200328
              "       funmat           ",
              "  from dbsmopgfas       ",
              " where socopgnum    = ? ",
              "   and socopgfascod = 4 "
 prepare sel_dbsmopgfas from ws.sql
 declare c_dbsmopgfas cursor with hold for sel_dbsmopgfas

 let ws.sql = "select atdsrvorg,     ",
              "       atdcstvlr,     ",
              "       ciaempcod      ",
              "  from datmservico    ",
              " where atdsrvnum = ?  ",
              "   and atdsrvano = ?  "
 prepare sel_datmservico from ws.sql
 declare c_datmservico cursor with hold for sel_datmservico

 let ws.sql = "select srvinccst,    ",
              "       cadmat        ",
              "  from datmpreacp    ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
 prepare sel_datmpreacp from ws.sql
 declare c_datmpreacp cursor with hold for sel_datmpreacp

 let ws.sql = "select socopgfavnom,    ",
              "       pestip,          ",
              "       cgccpfnum,       ",
              "       cgcord,          ",
              "       cgccpfdig        ",
              "  from dbsmopgfav       ",
              " where socopgnum    = ? "
 prepare sel_dbsmopgfav from ws.sql
 declare c_dbsmopgfav cursor with hold for sel_dbsmopgfav

 let ws.sql = "update dmct24h@", ws.hostname clipped, ":dagksrvfat",
              "   set (socopgnum   , atdcstvlr   , pgttmpdimcod,  ",
              "        pgtfundimcod, favdimcod   , srvinccst   ,  ",
              "        cstfundimcod) = (?, ?, ?, ?, ?, ?, ?) ",
              " where atdsrvnum = ? and atdsrvano = ?             "
 prepare upd_dagksrvfat from ws.sql

 let ws.sql = "insert into work:datmexterro",
              "       (lignum, tabnom, sqlcod, fascod, atldat, atlhor,ligflg)",
              "values (?, ?, ?, 4, today, current, 'S')              "
 prepare ins_datmexterr from ws.sql

#---------------------------------------------------------------
# FASE 1: Extracao dos servicos pagos
#---------------------------------------------------------------

 let ws.qtdlid    = 0
 let ws.qtdgrv    = 0
 let ws.qtderr    = 0

 let ws.qtd_saude     = 0
 let ws.qtd_azul      = 0
 let ws.qtd_portoseg  = 0
 let ws.qtd_pss       = 0

 let ws.tempo = current year to second

 display ws.tempo, ": Iniciando extracao dos servicos pagos em ", ws.pardat, "..."

 open    c_dbsmopg using ws.pardat, ws.pstcoddig
 foreach c_dbsmopg into  d_bdata073.pstcoddig,
                         d_bdata073.socopgnum,
                         d_bdata073.socopgitmvlr,
                         d_bdata073.atdsrvnum,
                         d_bdata073.atdsrvano,
                         d_bdata073.socfatpgtdat                  # PSI 200328

    open  c_datmservico using d_bdata073.atdsrvnum,
                              d_bdata073.atdsrvano
    fetch c_datmservico into  d_bdata073.atdsrvorg,
                              d_bdata073.socopgitmvlr,  # Busca Vlr. no Srv.
                              d_bdata073.ciaempcod

    if d_bdata073.atdsrvorg  = 10   or
       d_bdata073.atdsrvorg  = 11   or
       d_bdata073.atdsrvorg  = 12   or
       d_bdata073.atdsrvorg  =  8   or
       d_bdata073.atdsrvorg  = 18   then
       continue foreach
    end if

    let ws.qtdlid = ws.qtdlid + 1

    --------[ desprezar servicos do saude - 10/10/06 - ruiz R5289 ]-----
    select atdsrvnum
        from datrsrvsau
       where atdsrvnum = d_bdata073.atdsrvnum
         and atdsrvano = d_bdata073.atdsrvano
    if sqlca.sqlcode = 0 then
       let ws.qtd_saude = ws.qtd_saude + 1
       continue foreach
    end if
    ---------------------------------------------------------------------

    if d_bdata073.ciaempcod = 35 then
       let ws.qtd_azul = ws.qtd_azul + 1
       continue foreach
    end if

    if d_bdata073.ciaempcod = 40 then
       let ws.qtd_portoseg = ws.qtd_portoseg + 1
       continue foreach
    end if

    if d_bdata073.ciaempcod = 27 then
       let ws.qtd_pss = ws.qtd_pss + 1
       continue foreach
    end if

    close c_datmservico

    let d_bdata073.srvinccst = 0
    let d_bdata073.funmatcst = 0
    open  c_datmpreacp using d_bdata073.atdsrvnum,
                             d_bdata073.atdsrvano
    fetch c_datmpreacp into  d_bdata073.srvinccst,
                             d_bdata073.funmatcst
    close c_datmpreacp

    let d_bdata073.lignum = cts20g00_servico(d_bdata073.atdsrvnum, d_bdata073.atdsrvano)

    open  c_dbsmopgfas using d_bdata073.socopgnum
    fetch c_dbsmopgfas into  d_bdata073.socopgfashor,      # PSI 200328
                             d_bdata073.funmat
    close c_dbsmopgfas

    open  c_dbsmopgfav using d_bdata073.socopgnum
    fetch c_dbsmopgfav into  d_bdata073.socopgfavnom,
                             d_bdata073.pestip,
                             d_bdata073.cgccpfnum,
                             d_bdata073.cgcord,
                             d_bdata073.cgccpfdig
    close c_dbsmopgfav


    begin work

#---------------------------------------------------------------
# Gravacao da dimensao TEMPO
#---------------------------------------------------------------

    call ctr09g00_tempo(d_bdata073.socfatpgtdat,           # PSI 200328
                        "00:00",
                        w_priveztmp)
              returning w_bdata073.pgttmpdimcod,
                        ws.tabnom, ws.sqlcod,
                        w_priveztmp

    if ws.sqlcod <> 0  then
       rollback work
       if d_bdata073.lignum is not null then
          let ws.qtderr = ws.qtderr + 1
          let ws.tabnom = '073-', ws.tabnom clipped
          execute ins_datmexterr using d_bdata073.lignum, ws.tabnom, ws.sqlcod
       end if
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao FUNCIONARIO
#---------------------------------------------------------------

    call ctr09g00_func(1,
                       d_bdata073.funmat,
                       w_privezfun)
             returning w_bdata073.pgtfundimcod,
                       ws.tabnom, ws.sqlcod,
                       w_privezfun

    if ws.sqlcod <> 0  then
       rollback work
       if d_bdata073.lignum is not null then
          let ws.qtderr = ws.qtderr + 1
          let ws.tabnom = '073-', ws.tabnom clipped
          execute ins_datmexterr using d_bdata073.lignum, ws.tabnom, ws.sqlcod
       end if
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao FUNCIONARIO ACERTO DE VALOR SERVICO
#---------------------------------------------------------------
    if d_bdata073.funmatcst > 0 then
       call ctr09g00_func(1,
                          d_bdata073.funmatcst,
                          w_privezfun)
                returning w_bdata073.cstfundimcod,
                          ws.tabnom, ws.sqlcod,
                          w_privezfun

       if ws.sqlcod <> 0  then
          rollback work
          if d_bdata073.lignum is not null then
            let ws.qtderr = ws.qtderr + 1
            let ws.tabnom = '073-', ws.tabnom clipped
            execute ins_datmexterr using d_bdata073.lignum, ws.tabnom, ws.sqlcod
          end if
          continue foreach
       end if
    else
       let w_bdata073.cstfundimcod = 0
    end if

#---------------------------------------------------------------
# Gravacao da dimensao FAVORECIDO
#---------------------------------------------------------------

    call ctr09g00_favorecido(d_bdata073.pstcoddig,
                             d_bdata073.socopgfavnom,
                             d_bdata073.pestip,
                             d_bdata073.cgccpfnum,
                             d_bdata073.cgcord,
                             d_bdata073.cgccpfdig,
                             w_privezfav)
                   returning w_bdata073.favdimcod,
                             ws.tabnom, ws.sqlcod,
                             w_privezfav

    if ws.sqlcod <> 0  then
       rollback work
       if d_bdata073.lignum is not null then
          let ws.qtderr = ws.qtderr + 1
          let ws.tabnom = '073-', ws.tabnom clipped
          execute ins_datmexterr using d_bdata073.lignum, ws.tabnom, ws.sqlcod
       end if
       continue foreach
    end if

#---------------------------------------------------------------
# Atualizacao do fato SERVICO
#---------------------------------------------------------------

    whenever error continue
    execute upd_dagksrvfat using d_bdata073.socopgnum,
                                 d_bdata073.socopgitmvlr,
                                 w_bdata073.pgttmpdimcod,
                                 w_bdata073.pgtfundimcod,
                                 w_bdata073.favdimcod,
                                 d_bdata073.srvinccst,
                                 w_bdata073.cstfundimcod,
                                 d_bdata073.atdsrvnum,
                                 d_bdata073.atdsrvano
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       else
          let ws.tabnom = "dagksrvfat"
       end if
       let ws.sqlcod = sqlca.sqlcode
       rollback work
       if d_bdata073.lignum is not null then
          let ws.qtderr = ws.qtderr + 1
          let ws.tabnom = '073-', ws.tabnom clipped
          execute ins_datmexterr using d_bdata073.lignum, ws.tabnom, ws.sqlcod
       end if
       continue foreach
    end if

    commit work

    let ws.qtdgrv = ws.qtdgrv + 1

    initialize w_bdata073.*  to null
    initialize w_bdata073.*  to null

 end foreach

 display "                     Resumo: Lidos ............... ", ws.qtdlid
 display "                             Desprezados Saude.... ", ws.qtd_saude
 display "                             Desprezados Azul..... ", ws.qtd_azul
 display "                             Desprezados PortoSeg. ", ws.qtd_portoseg
 display "                             Desprezados PSS...... ", ws.qtd_pss
 display "                             Gravados ............ ", ws.qtdgrv
 display "                             Erros Encontrados ... ", ws.qtderr

#---------------------------------------------------------------
# Remove flag de re-start. Processamento concluido!
#---------------------------------------------------------------

 delete from igbkgeral
  where mducod = "C24"  and
        grlchv = "DATAMART-PAGTO"

 let ws.tempo = current year to second

 display ws.tempo, ": Extracao dos servicos pagos em ", ws.pardat, " encerrada!\n"

end function  ###  bdata073
