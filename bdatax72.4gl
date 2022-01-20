############################################################################
# Nome do Modulo: bdata072                                        Marcelo  #
#                                                                 Gilberto #
# Extracao diaria de etapas                                       Set/1999 #
############################################################################

 database porto

 main
    set isolation to dirty read

    call bdata072()
 end main

#---------------------------------------------------------------
 function bdata072()
#---------------------------------------------------------------

 define d_bdata072  record                  
    atdsrvnum       like datmsrvacp.atdsrvnum,
    atdsrvano       like datmsrvacp.atdsrvano,
    lignum          like datmligacao.lignum,
    atdtip          like datmservico.atdtip,
    atdetpcod       like datmsrvacp.atdetpcod,
    atdetpdes       like datketapa.atdetpdes, 
    pstcoddig       like datmsrvacp.pstcoddig,
    srrcoddig       like datksrr.srrcoddig,
    srrnom          like datksrr.srrnom,
    socvclcod       like datkveiculo.socvclcod,
    atdvclsgl       like datkveiculo.atdvclsgl,
    vclcoddig       like datkveiculo.vclcoddig,
    vclanofbc       like datkveiculo.vclanofbc,
    vclanomdl       like datkveiculo.vclanomdl
 end record

 define w_bdata072  record
    prsdimcod       integer,
    srrdimcod       integer,
    prsvcldimcod    integer
 end record

 define ws          record                  
    sql             char (900)               ,
    tabnom          char (30)                ,
    sqlcod          integer                  ,
    tempo           datetime year to second  ,
    hostname        char (20)                ,
    rstqtd          dec  (2,0)               ,
    rstdat          char (10)                ,
    grlinf          like igbkgeral.grlinf    ,
    atlult          like igbkgeral.atlult    ,
    pardat          date                     ,
    auxdat          char (10)                ,
    auxhor          datetime hour to second  ,
    qtdlid          integer                  ,
    qtdgrv          integer                  ,
    qtderr          integer
 end record
 
 define w_privezprs dec(1,0),
        w_privezsrr dec(1,0),
        w_privezvcl dec(1,0)

#---------------------------------------------------------------
# Inicializacao das variaveis   
#---------------------------------------------------------------

 initialize d_bdata072.*  to null
 initialize w_bdata072.*  to null
 initialize ws.*          to null

 let w_privezprs = true
 let w_privezsrr = true
 let w_privezvcl = true

#---------------------------------------------------------------
# Data parametro para extracao das etapas de servicos
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
       display "*** ERRO NO PARAMETRO: ", ws.auxdat clipped, " - DATA INVALIDA! ***"
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
        grlchv = "1999MART-ETAPA"
 
 if sqlca.sqlcode < 0  then
    display "Erro (", sqlca.sqlcode using "<<<<<<", ") na leitura dos parametros (IGBKGERAL)!"
    exit program (1)
 else
    if sqlca.sqlcode = notfound  then
       let ws.atlult = today, " ", ws.auxhor
       let ws.grlinf = ws.pardat
       let ws.grlinf = ws.grlinf clipped, "00"
 
       insert into igbkgeral
              (mducod, grlchv, grlinf, atlult)
       values ("C24","1999MART-ETAPA", ws.grlinf, ws.atlult)
 
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
       let ws.grlinf = ws.grlinf clipped, " ", ws.rstqtd using "&&"
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
              grlchv = "1999MART-ETAPA" 
 
       if sqlca.sqlcode <> 0  then
          display "Erro (", sqlca.sqlcode using "<<<<<<", ") na atualizacao dos parametros (IGBKGERAL)!"
          exit program (1) 
       end if
    end if
 end if
 
#---------------------------------------------------------------
# Criacao de tabelas temporarias
#---------------------------------------------------------------

 create temp table t_datketapa  (atdetpcod       smallint,
                                 atdetpdes       char(15))  with no log
 if sqlca.sqlcode <> 0  then
    display "Erro (", sqlca.sqlcode using "<<<<<<", ") na criacao da tabela temporaria T_DATKETAPA!"
    exit program (1) 
 end if

 create index    idx_datketapa   on t_datketapa(atdetpcod)
 if sqlca.sqlcode <> 0  then
    display "Erro (", sqlca.sqlcode using "<<<<<<", ") na criacao do indice temporario T_DATKETAPA!"
    exit program (1) 
 end if

#---------------------------------------------------------------
# Carga das tabelas temporarias
#---------------------------------------------------------------

 insert into t_datketapa 
    select atdetpcod, atdetpdes from datketapa 

 if sqlca.sqlcode <> 0  then
    display "Erro (", sqlca.sqlcode using "<<<<<<", ") na carga da tabela temporaria T_DATKETAPA!"
    exit program (1) 
 end if

#---------------------------------------------------------------
# Definicao dos comandos SQL    
#---------------------------------------------------------------

 let ws.sql = "select atdsrvnum, ",
              "       atdsrvano  ",
              "  from datmsrvacp ",
              " where atdetpdat = ?",
              " group by atdsrvnum, atdsrvano"
 prepare sel_bdata072 from ws.sql
 declare c_bdata072 cursor with hold for sel_bdata072

 let ws.sql = "select atdetpcod, pstcoddig,",
              "       socvclcod, srrcoddig ",
              "  from datmsrvacp           ",
              " where atdsrvnum = ?        ",
              "   and atdsrvano = ?        ",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                 "   from datmsrvacp    ",
                                 "  where atdsrvnum = ? ",
                                 "    and atdsrvano = ? ",
                                 "    and atdetpdat = ?)"
 prepare sel_datmsrvacp from ws.sql
 declare c_datmsrvacp cursor with hold for sel_datmsrvacp
 
 let ws.sql = "select vclcoddig, atdvclsgl,",
              "       vclanofbc, vclanomdl ",
              "  from datkveiculo          ",
              " where socvclcod = ?        "
 prepare sel_datkveiculo from ws.sql
 declare c_datkveiculo cursor with hold for sel_datkveiculo

 let ws.sql = "select atdtip        ",
              "  from datmservico   ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
 prepare sel_datmservico from ws.sql
 declare c_datmservico cursor with hold for sel_datmservico

 let ws.sql = "select atdetpdes    ",
              "  from t_datketapa  ",
              " where atdetpcod = ?"
 prepare sel_datketapa  from ws.sql
 declare c_datketapa  cursor with hold for sel_datketapa  

 let ws.sql = "update dmct24h@", ws.hostname clipped, ":dagksrvfat",
              "   set (atdetpcod   , atdetpdes   , prsdimcod   ,  ",
              "        prsvcldimcod, socvclcod   , atdvclsgl   ,  ",
              "        srrdimcod   ) = (?, ?, ?, ?, ?, ?, ?)      ",
              " where atdsrvnum = ? and atdsrvano = ?             "
 prepare upd_dagksrvfat from ws.sql

 let ws.sql = "insert into work:datmexterro",
              "       (lignum, tabnom, sqlcod, fascod, atldat, atlhor,ligflg)",
              "values (?, ?, ?, 3, today, current, 'S')              "
 prepare ins_datmexterr from ws.sql

#---------------------------------------------------------------
# FASE 1: Extracao das etapas
#---------------------------------------------------------------

 let ws.qtdlid = 0
 let ws.qtdgrv = 0
 let ws.qtderr = 0

 let ws.tempo = current year to second

 display ws.tempo, ": Iniciando extracao das etapas em ", ws.pardat, "..."

 open    c_bdata072 using ws.pardat
 foreach c_bdata072 into  d_bdata072.atdsrvnum,
                          d_bdata072.atdsrvano

     open  c_datmservico using d_bdata072.atdsrvnum,
                               d_bdata072.atdsrvano
     fetch c_datmservico into  d_bdata072.atdtip

     if d_bdata072.atdtip = "4"  or
        d_bdata072.atdtip = "5"  or
        d_bdata072.atdtip = "6"  or
        d_bdata072.atdtip = "R"  then
        continue foreach
     end if

     close c_datmservico

     let d_bdata072.lignum = cts20g00_servico(d_bdata072.atdsrvnum, d_bdata072.atdsrvano)

     let ws.qtdlid = ws.qtdlid + 1

     open  c_datmsrvacp using d_bdata072.atdsrvnum,
                              d_bdata072.atdsrvano,
                              d_bdata072.atdsrvnum,
                              d_bdata072.atdsrvano,
                              ws.pardat
     fetch c_datmsrvacp into  d_bdata072.atdetpcod,
                              d_bdata072.pstcoddig,
                              d_bdata072.socvclcod,
                              d_bdata072.srrcoddig
    close c_datmsrvacp

    open  c_datketapa using d_bdata072.atdetpcod
    fetch c_datketapa into  d_bdata072.atdetpdes
    close c_datketapa

    begin work

#---------------------------------------------------------------
# Gravacao da dimensao PRESTADOR DE SERVICOS
#---------------------------------------------------------------

    call ctr09g00_prestador(d_bdata072.pstcoddig,
                            w_privezprs)
                  returning w_bdata072.prsdimcod,
                            ws.tabnom, ws.sqlcod,
                            w_privezprs

    if ws.sqlcod <> 0  then
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata072.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao SOCORRISTA
#---------------------------------------------------------------

    call ctr09g00_socorrista(d_bdata072.srrcoddig,
                             d_bdata072.srrnom,
                             w_privezsrr)
                   returning w_bdata072.srrdimcod,
                             ws.tabnom, ws.sqlcod,
                             w_privezsrr

    if ws.sqlcod <> 0  then
       rollback work
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata072.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

#---------------------------------------------------------------
# Gravacao da dimensao VEICULO PRESTADOR
#---------------------------------------------------------------

    if d_bdata072.socvclcod is null  then
       let w_bdata072.prsvcldimcod = 0
    else
       open  c_datkveiculo using d_bdata072.socvclcod
       fetch c_datkveiculo into  d_bdata072.vclcoddig,
                                 d_bdata072.atdvclsgl,
                                 d_bdata072.vclanofbc,
                                 d_bdata072.vclanomdl 
       close c_datkveiculo

       call ctr09g00_veiculo(d_bdata072.vclcoddig,
                             w_privezvcl)
                   returning w_bdata072.prsvcldimcod,
                             ws.tabnom, ws.sqlcod,
                             w_privezvcl

       if ws.sqlcod <> 0  then
          rollback work
          let ws.qtderr = ws.qtderr + 1
          execute ins_datmexterr using d_bdata072.lignum, ws.tabnom, ws.sqlcod
          continue foreach
       end if
    end if

#---------------------------------------------------------------
# Atualizacao do fato SERVICO 
#---------------------------------------------------------------

    whenever error continue
    execute upd_dagksrvfat using d_bdata072.atdetpcod,
                                 d_bdata072.atdetpdes,
                                 w_bdata072.prsdimcod,
                                 w_bdata072.prsvcldimcod,
                                 d_bdata072.socvclcod,
                                 d_bdata072.atdvclsgl,
                                 w_bdata072.srrdimcod,
                                 d_bdata072.atdsrvnum,
                                 d_bdata072.atdsrvano 
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
       execute ins_datmexterr using d_bdata072.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

    commit work

    let ws.qtdgrv = ws.qtdgrv + 1

    initialize w_bdata072.*  to null
    initialize w_bdata072.*  to null

 end foreach

 display "                     Resumo: Lidos ............... ", ws.qtdlid
 display "                             Gravados ............ ", ws.qtdgrv
 display "                             Erros Encontrados ... ", ws.qtderr

#---------------------------------------------------------------
# Remove flag de re-start. Processamento concluido!
#---------------------------------------------------------------

 delete from igbkgeral 
  where mducod = "C24"  and
        grlchv = "1999MART-ETAPA"
 
 let ws.tempo = current year to second

 display ws.tempo, ": Extracao das etapas em ", ws.pardat, " encerrada!\n"

end function  ###  bdata072
