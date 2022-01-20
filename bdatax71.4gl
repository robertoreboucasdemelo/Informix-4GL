############################################################################
# Nome do Modulo: bdata071                                        Marcelo  #
#                                                                 Gilberto #
# Extracao diaria de servicos acionados                           Set/1999 #
############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 10/02/2000               Gilberto     Permitir reprocessamento de erros   #
#                                       atraves de parametro.               #
#############################################################################

 database porto

 main
    set isolation to dirty read

    call bdata071()
 end main

#---------------------------------------------------------------
 function bdata071()
#---------------------------------------------------------------

 define d_bdata071  record                  
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    lignum          like datmligacao.lignum,
    atdtip          like datmservico.atdtip,
    cnldat          like datmservico.cnldat,
    atdfnlhor       like datmservico.atdfnlhor,
    c24opemat       like datmservico.c24opemat,
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc       like dpaksocor.nomrazsoc,
    nomgrr          like dpaksocor.nomgrr,
    pestip          like dpaksocor.pestip,
    cgccpfnum       like dpaksocor.cgccpfnum, 
    cgcord          like dpaksocor.cgcord,
    cgccpfdig       like dpaksocor.cgccpfdig, 
    endufd          like dpaksocor.endufd,
    endcid          like dpaksocor.endcid,
    endbrr          like dpaksocor.endbrr,
    endcep          like dpaksocor.endcep,
    endcepcmp       like dpaksocor.endcepcmp,
    prssitdes       char (20),
    srrcoddig       like datksrr.srrcoddig,
    srrnom          like datksrr.srrnom,
    socvclcod       like datkveiculo.socvclcod,
    atdvclsgl       like datkveiculo.atdvclsgl,
    vclcoddig       like datkveiculo.vclcoddig,
    vclanofbc       like datkveiculo.vclanofbc,
    vclanomdl       like datkveiculo.vclanomdl
 end record

 define w_bdata071  record
    acmtmpdimcod    integer,
    acmfundimcod    integer,
    prsdimcod       integer,
    srrdimcod       integer,
    prsvcldimcod    integer
 end record

 define ws          record                  
    sql             char (900)                  ,
    tabnom          char (30)                   ,
    sqlcod          integer                     ,
    tempo           datetime year to second     ,
    hostname        char (20)                   ,
    rstqtd          dec  (2,0)                  ,
    rstdat          char (10)                   ,
    grlinf          like igbkgeral.grlinf       ,
    atlult          like igbkgeral.atlult       ,
    pardat          date                        ,
    auxdat          char (10)                   ,
    auxhor          datetime hour to second     ,
    prsqtd          smallint                    ,
    srrqtd          smallint                    ,
    qtdlid          integer                     ,
    qtdgrv          integer                     ,
    qtdupd          integer                     ,
    qtderr          integer                     ,
    errextflg       dec (1,0)                   ,
    prssitcod       like dpaksocor.prssitcod  
 end record
 
 define w_priveztmp dec(1,0),
        w_privezfun dec(1,0),
        w_privezprs dec(1,0),
        w_privezsrr dec(1,0),
        w_privezvcl dec(1,0)

#---------------------------------------------------------------
# Inicializacao das variaveis   
#---------------------------------------------------------------

 initialize d_bdata071.*  to null
 initialize w_bdata071.*  to null
 initialize ws.*          to null

 let w_priveztmp = true
 let w_privezfun = true
 let w_privezprs = true
 let w_privezsrr = true
 let w_privezvcl = true

#---------------------------------------------------------------
# Data parametro para extracao dos acionamentos de servicos
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
# Verifica se e' reprocessamento dos erros de extracao
#---------------------------------------------------------------

 let ws.errextflg = false

 if arg_val(2) = "ERR"  then
    let ws.errextflg = true
 end if

#---------------------------------------------------------------
# Verifica banco de dados utilizado (desenvolvimento ou producao)
#---------------------------------------------------------------

 let ws.hostname = ctr09g00_host()  
 
#---------------------------------------------------------------
# Verifica necessidade de 're-start' do programa
#---------------------------------------------------------------

 if ws.errextflg = false  then
    select grlinf, atlult 
      into ws.grlinf, ws.atlult
      from igbkgeral 
     where mducod = "C24"  and
           grlchv = "1999MART-ACION"
 
    if sqlca.sqlcode < 0  then
       display "Erro (", sqlca.sqlcode using "<<<<<<", ") na leitura dos parametros (IGBKGERAL)!"
       exit program (1)
    else
       if sqlca.sqlcode = notfound  then
          let ws.atlult = today, " ", ws.auxhor
          let ws.grlinf = ws.pardat
          let ws.grlinf = ws.grlinf clipped, " 0"
 
          insert into igbkgeral
                 (mducod, grlchv, grlinf, atlult)
          values ("C24","1999MART-ACION", ws.grlinf, ws.atlult)
    
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode using "<<<<<<", ") na gravacao dos parametros (IGBKGERAL)!"
             exit program (1) 
          end if
       else
          let ws.rstdat = ws.grlinf[01,10]
          let ws.rstqtd = ws.grlinf[12,13] clipped + 1
 
          if ws.rstdat is null  then
             display "Erro na recuperacao da data parametro!"
             exit program (1)
          end if

          if ws.pardat is not null  and
             ws.rstdat > ws.pardat  then
             exit program
          end if
   
          let ws.pardat = ws.rstdat
   
          let ws.grlinf = ws.pardat 
          let ws.grlinf = ws.grlinf clipped, " ", ws.rstqtd using "<<"
          let ws.atlult = today, " ", ws.auxhor
 
          display ""
          display "                      ATENCAO! Rotina de RE-START acionada (", ws.rstqtd using "<<", "a. vez) ..."
          display "                      Data de extracao..: ", ws.pardat
          display "                      Ultimo acionamento: ", ws.atlult
          display ""
 
          update igbkgeral 
             set (grlinf, atlult)
               = (ws.grlinf, ws.atlult)
           where mducod = "C24"  and
                 grlchv = "1999MART-ACION"
 
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode using "<<<<<<", ") na atualizacao dos parametros (IGBKGERAL)!"
             exit program (1) 
          end if
       end if
    end if
 end if
 
#---------------------------------------------------------------
# Definicao dos comandos SQL    
#---------------------------------------------------------------

 if ws.errextflg = false  then
    let ws.sql = "select atdsrvnum, atdsrvano, ",
                 "       cnldat   , atdfnlhor, ",
                 "       c24opemat, atdprscod, ",
                 "       srrcoddig, socvclcod, ",
                 "       atdtip                ",
                 "  from datmservico           ",
                 " where atdfnlflg = 'S'  and  ",
                 "       cnldat    =  ?        "
 else
    let ws.sql = "select s.atdsrvnum,",
                 "       s.atdsrvano,",
                 "       s.cnldat   ,",
                 "       s.atdfnlhor,",
                 "       s.c24opemat,",
                 "       s.atdprscod,",
                 "       s.srrcoddig,",
                 "       s.socvclcod,",
                 "       s.atdtip    ",
                 "  from work:datmexterro  w,",
                 "       porto:datrligsrv  p,",
                 "       porto:datmservico s ",
                 " where w.atldat    =  ?         ",
                 "   and w.ligflg    = 'S'        ",
                 "   and w.fascod    =  2         ",
                 "   and w.lignum    = p.lignum   ",
                 "   and p.atdsrvnum = s.atdsrvnum",
                 "   and p.atdsrvano = s.atdsrvano"
 end if
 prepare sel_datmservico from ws.sql
 declare c_datmservico cursor with hold for sel_datmservico

 let ws.sql = "select vclcoddig, atdvclsgl,",
              "       vclanofbc, vclanomdl ",
              "  from datkveiculo          ",
              " where socvclcod = ?        "
 prepare sel_datkveiculo from ws.sql
 declare c_datkveiculo cursor with hold for sel_datkveiculo

 let ws.sql = "insert into dmct24h@", ws.hostname clipped, ":dagkprsdim",
              "       (prsdimcod, pstcoddig, nomgrr   , nomrazsoc,     ",
              "        pestip   , cgccpfnum, cgcord   , cgccpfdig,     ",
              "        endufd   , endcid   , endbrr   , endcep   ,     ",
              "        endcepcmp, prssitdes)                           ",
              "values (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)       "
 prepare ins_dagkprsdim from ws.sql

 let ws.sql = "update dmct24h@", ws.hostname clipped, ":dagkprsdim",
           "   set (nomgrr   , nomrazsoc, pestip   , cgccpfnum,",
           "        cgcord   , cgccpfdig, endufd   , endcid   ,",
           "        endbrr   , endcep   , endcepcmp, prssitdes)",
           "     = (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)        ",
           " where prsdimcod = ?                               "
 prepare upd_dagkprsdim from ws.sql

 let ws.sql = "update dmct24h@", ws.hostname clipped, ":dagksrvfat",
              "   set (acmtmpdimcod, acmfundimcod, prsdimcod   ,  ",
              "        prsvcldimcod, socvclcod   , atdvclsgl   ,  ",
              "        srrdimcod   ) = (?, ?, ?, ?, ?, ?, ?)      ",
              " where atdsrvnum = ? and atdsrvano = ?             "
 prepare upd_dagksrvfat from ws.sql

 let ws.sql = "insert into work:datmexterro",
              "       (lignum, tabnom, sqlcod, fascod, atldat, atlhor,ligflg)",
              "values (?, ?, ?, 2, today, current, 'S')              "
 prepare ins_datmexterr from ws.sql

 if ws.errextflg = true  then
    let ws.sql = "update work:datmexterro       ",
                 "   set (atldat, atlhor,ligflg)",
                 "     = (today, current, 'N')  ",
                 " where lignum = ?             ",
                 "   and fascod = 2             "
    prepare upd_datmexterr from ws.sql
 end if

#---------------------------------------------------------------
# FASE 3: Extracao dos servicos acionados 
#---------------------------------------------------------------

 let ws.qtdlid = 0
 let ws.qtdgrv = 0
 let ws.qtderr = 0

 let ws.tempo = current year to second

 if ws.errextflg = true  then
    display ws.tempo, ": Iniciando extracao dos acionamentos com erro processados em ", ws.pardat, "..."
 else
    display ws.tempo, ": Iniciando extracao dos servicos acionados em ", ws.pardat, "..."
 end if

 open    c_datmservico using ws.pardat
 foreach c_datmservico into  d_bdata071.atdsrvnum,
                             d_bdata071.atdsrvano,
                             d_bdata071.cnldat,
                             d_bdata071.atdfnlhor,
                             d_bdata071.c24opemat,
                             d_bdata071.pstcoddig,
                             d_bdata071.srrcoddig,
                             d_bdata071.socvclcod,
                             d_bdata071.atdtip

    if d_bdata071.atdtip = "4"  or
       d_bdata071.atdtip = "5"  or
       d_bdata071.atdtip = "6"  or
       d_bdata071.atdtip = "R"  then
       continue foreach
    end if

    let d_bdata071.lignum = cts20g00_servico(d_bdata071.atdsrvnum, d_bdata071.atdsrvano)
  
    let ws.qtdlid = ws.qtdlid + 1

    begin work

#---------------------------------------------------------------
# Gravacao da dimensao TEMPO
#---------------------------------------------------------------

    call ctr09g00_tempo(d_bdata071.cnldat,
                        d_bdata071.atdfnlhor,
                        w_priveztmp)
              returning w_bdata071.acmtmpdimcod,
                        ws.tabnom, ws.sqlcod,
                        w_priveztmp

    if ws.sqlcod <> 0  then
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata071.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao FUNCIONARIO
#---------------------------------------------------------------

    call ctr09g00_func(d_bdata071.c24opemat,
                       w_privezfun)
             returning w_bdata071.acmfundimcod,
                       ws.tabnom, ws.sqlcod,
                       w_privezfun

    if ws.sqlcod <> 0  then
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata071.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if
 
#---------------------------------------------------------------
# Gravacao da dimensao PRESTADOR DE SERVICOS
#---------------------------------------------------------------

    call ctr09g00_prestador(d_bdata071.pstcoddig,
                            w_privezprs)
                  returning w_bdata071.prsdimcod,
                            ws.tabnom, ws.sqlcod,
                            w_privezprs

    if ws.sqlcod <> 0  then
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata071.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao SOCORRISTA
#---------------------------------------------------------------

    call ctr09g00_socorrista(d_bdata071.srrcoddig,
                             d_bdata071.srrnom,
                             w_privezsrr)
                   returning w_bdata071.srrdimcod,
                             ws.tabnom, ws.sqlcod,
                             w_privezsrr

    if ws.sqlcod <> 0  then
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata071.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao VEICULO PRESTADOR
#---------------------------------------------------------------

    if d_bdata071.socvclcod is null  then
       let w_bdata071.prsvcldimcod = 0
       initialize d_bdata071.atdvclsgl to null
    else
       open  c_datkveiculo using d_bdata071.socvclcod
       fetch c_datkveiculo into  d_bdata071.vclcoddig,
                                 d_bdata071.atdvclsgl,
                                 d_bdata071.vclanofbc,
                                 d_bdata071.vclanomdl 
       close c_datkveiculo

       call ctr09g00_veiculo(d_bdata071.vclcoddig,
                             w_privezvcl)
                   returning w_bdata071.prsvcldimcod,
                             ws.tabnom, ws.sqlcod,
                             w_privezvcl

       if ws.sqlcod <> 0  then
          rollback work
          let ws.qtderr = ws.qtderr + 1
          execute ins_datmexterr using d_bdata071.lignum, ws.tabnom, ws.sqlcod
          continue foreach
       end if
    end if

#---------------------------------------------------------------
# Atualizacao do fato SERVICO 
#---------------------------------------------------------------

    whenever error continue
    execute upd_dagksrvfat using w_bdata071.acmtmpdimcod,
                                 w_bdata071.acmfundimcod,
                                 w_bdata071.prsdimcod,
                                 w_bdata071.prsvcldimcod,
                                 d_bdata071.socvclcod,
                                 d_bdata071.atdvclsgl,
                                 w_bdata071.srrdimcod,
                                 d_bdata071.atdsrvnum,
                                 d_bdata071.atdsrvano 
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm                          
       else
          let ws.tabnom = "dagksrvfat"
       end if 
       let ws.sqlcod = sqlca.sqlcode
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata071.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

    commit work

    if ws.errextflg = true  then
       execute upd_datmexterr using d_bdata071.lignum
    end if

    let ws.qtdgrv = ws.qtdgrv + 1

    initialize w_bdata071.*  to null
    initialize w_bdata071.*  to null

 end foreach

 display "                     Resumo: Lidos ............... ", ws.qtdlid
 display "                             Gravados ............ ", ws.qtdgrv
 display "                             Erros Encontrados ... ", ws.qtderr

#---------------------------------------------------------------
# Se estiver reprocessando erros, sai do programa  
#---------------------------------------------------------------

 if ws.errextflg = true  then
    exit program
 end if

#---------------------------------------------------------------
# Remove flag de re-start. Processamento concluido!
#---------------------------------------------------------------

 delete from igbkgeral 
  where mducod = "C24"  and
        grlchv = "1999MART-ACION"
 
 let ws.tempo = current year to second

 display ws.tempo, ": Extracao dos servicos acionados em ", ws.pardat, " encerrada!\n"

end function  ###  bdata071
