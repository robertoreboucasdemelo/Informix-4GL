###############################################################################
# Nome do Modulo: bdata021                                           Marcelo  #
#                                                                    Gilberto #
# Atualizacao das ligacoes apuradas na reclamacao                    Out/1999 #
###############################################################################
#.............................................................................#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica    Origem    Alteracao                            #
# ----------  --------------   --------- -------------------------------------#
# 10/09/2005  James, Meta      Melhorias Melhorias de performance             #
#-----------------------------------------------------------------------------#
# 16/11/2006 Alberto Rodrigues 205206    implementado leitura campo ciaempcod #
#                                        para desprezar qdo for Azul Segur.   #
#                                                                             #
# 31/08/2007 Roberto Melo                implementado leitura campo ciaempcod #
#                                        para desprezar qdo for PortoSeg.     #
#                                                                             #
###############################################################################

 database porto

 main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    call bdata021()
 end main

#---------------------------------------------------------------
 function bdata021()
#---------------------------------------------------------------

 define d_bdata021  record
    lignum          like datmligacao.lignum,
    c24astcod       like datkassunto.c24astcod,
    c24astdimcod    integer,
    ciaempcod       like datmligacao.ciaempcod
 end record

 define w_bdata021  record
    c24astdimcod    integer
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    tempo           datetime year to second,
    hostname        char (20),
    pardat          date,
    auxdat          char (10),
    auxhor          datetime hour to second,
    qtdlid          integer,
    qtdgrv          integer,
    qtderr          integer,
    privezast       dec(1,0),
    c24atrflg       like datkassunto.c24atrflg,
    c24jstflg       like datkassunto.c24jstflg
 end record

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdata021.*  to null
 initialize w_bdata021.*  to null
 initialize ws.*          to null

 let ws.privezast = true

#---------------------------------------------------------------
# Data parametro para extracao das ligacoes
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
# Definicao dos comandos SQL
#---------------------------------------------------------------

 let ws.sql = "select distinct(lignum)",
              "  from datmsitrecl     ",
              " where rclrlzdat = ?   "
 prepare sel_datmsitrecl from ws.sql
 declare c_datmsitrecl cursor with hold for sel_datmsitrecl

 let ws.sql = "select c24astcod , ciaempcod ",
              "  from datmligacao",
              " where lignum = ? "
 prepare sel_datmligacao from ws.sql
 declare c_datmligacao cursor with hold for sel_datmligacao

 let ws.sql = "select c24astdimcod ",
              "  from dmct24h@", ws.hostname clipped, ":dagkligfat",
              " where lignum = ?"
 prepare sel_dagkligfat from ws.sql
 declare c_dagkligfat cursor with hold for sel_dagkligfat

 let ws.sql = "update dmct24h@", ws.hostname clipped, ":dagkligfat",
              "   set (c24astdimcod) = (?) where lignum = ? "
 prepare upd_dagkligfat from ws.sql

 let ws.sql = "insert into work:datmexterro",
              "       (lignum, tabnom, sqlcod, fascod, atldat, atlhor,ligflg)",
              "values (?, ?, ?, 1, today, current, 'S')              "
 prepare ins_datmexterr from ws.sql

#---------------------------------------------------------------
# FASE 1: Atualizacao das reclamacoes re-codificadas
#---------------------------------------------------------------

 let ws.qtdlid = 0
 let ws.qtdgrv = 0
 let ws.qtderr = 0

 let ws.tempo = current year to second

 display ws.tempo, ": Iniciando atualizacao das reclamacoes em ", ws.pardat, "..."

 open    c_datmsitrecl using ws.pardat
 foreach c_datmsitrecl into  d_bdata021.lignum

    let ws.qtdlid = ws.qtdlid + 1

    open  c_datmligacao using d_bdata021.lignum
    fetch c_datmligacao into  d_bdata021.c24astcod,d_bdata021.ciaempcod
    close c_datmligacao

 if d_bdata021.ciaempcod = 35 or
    d_bdata021.ciaempcod = 40 or
    d_bdata021.ciaempcod = 43 or 
    d_bdata021.ciaempcod = 27 or ## PSI Empresa 27 
    d_bdata021.ciaempcod = 84 then 
    continue foreach
 end if


#---------------------------------------------------------------
# Gravacao da dimensao ASSUNTO
#---------------------------------------------------------------
    select c24atrflg,
           c24jstflg
           into ws.c24atrflg,
                ws.c24jstflg
      from datkassunto
     where c24astcod = d_bdata021.c24astcod

    call ctr09g00_assunto(d_bdata021.c24astcod,
                          "",
                          ws.c24atrflg,
                          ws.c24jstflg,
                          ws.privezast)
                returning w_bdata021.c24astdimcod,
                          ws.tabnom, ws.sqlcod,
                          ws.privezast

    if ws.sqlcod <> 0  then
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata021.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

    open  c_dagkligfat using d_bdata021.lignum
    fetch c_dagkligfat into  d_bdata021.c24astdimcod

    if d_bdata021.c24astdimcod = w_bdata021.c24astdimcod  then
       continue foreach
    end if

#---------------------------------------------------------------
# Atualizacao do fato LIGACAO
#---------------------------------------------------------------

    whenever error continue
    execute upd_dagkligfat using w_bdata021.c24astdimcod,
                                 d_bdata021.lignum
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       else
          let ws.tabnom = "dagkligfat"
       end if
       let ws.sqlcod = sqlca.sqlcode
       let ws.qtderr = ws.qtderr + 1
       execute ins_datmexterr using d_bdata021.lignum, ws.tabnom, ws.sqlcod
       continue foreach
    end if

    let ws.qtdgrv = ws.qtdgrv + 1

    initialize d_bdata021.*  to null
    initialize w_bdata021.*  to null

 end foreach

 display "                     Resumo: Ligacoes Lidas ...... ", ws.qtdlid
 display "                             Ligacoes Gravadas ... ", ws.qtdgrv
 display "                             Erros Encontrados ... ", ws.qtderr

 let ws.tempo = current year to second

 display ws.tempo, ": Atualizacao das reclamacoes em ", ws.pardat, " encerrada!\n"

end function  ###  bdata021
