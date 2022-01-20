###############################################################################
# Nome do Modulo: bdbsr009                                        Marcelo     #
#                                                                 Gilberto    #
# Relatorio de servicos concluidos por operador (fora tempo pad.) Out/1997    #
# Relatorio de distribuicao dos servicos por operador/prestador               #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
#-----------------------------------------------------------------------------#
# 14/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
###########################################################################   #
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
# ---------- --------------------- ------ ------------------------------------#
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################

 database porto

 define ws_data        date
 define ws_traco144    char(144)
 define ws_traco132    char(132)
 define ws_traco080    char(080)
 define ws_email       char(500)

 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd

 define m_path         char(100)

 main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr009.log"

    call startlog(m_path)
    # PSI 185035 - Final


    call bdbsr009()
 end main

#---------------------------------------------------------------
 function bdbsr009()
#---------------------------------------------------------------

 define d_bdbsr009    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg,
    atdtiptmp         smallint,
    atdlibdat         like datmservico.atdlibdat,
    atdlibhor         like datmservico.atdlibhor,
    atddatprg         like datmservico.atddatprg,
    atdhorprg         like datmservico.atdhorprg,
    cnldat            like datmservico.cnldat,
    atdfnlhor         like datmservico.atdfnlhor,
    c24opemat         like datmservico.c24opemat,
    atdprscod         like datmservico.atdprscod,
    dias              smallint,
    tempo             interval hour(06) to minute
 end record

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod,
    auxdat            char (10),
    atdfnlflg         like datmservico.atdfnlflg,
    imprime           smallint,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02         char (60)
 end record

 define sql_select    char(250)

 define l_retorno     smallint

#---------------------------------------------------------------
# Inicializacao das variaveis / Preparacao dos comandos SQL
#---------------------------------------------------------------
 initialize d_bdbsr009.*  to null
 initialize ws.*          to null

 let ws_traco144  = "------------------------------------------------------------------------------------------------------------------------------------------------"

 let ws_traco132  = "------------------------------------------------------------------------------------------------------------------------------------"

 let ws_traco080  = "--------------------------------------------------------------------------------"

 let sql_select = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"

 prepare sel_datmsrvacp from sql_select
 declare c_datmsrvacp cursor for sel_datmsrvacp

#---------------------------------------------------------------
# Definicao da data-parametro
#---------------------------------------------------------------

 let ws.auxdat = arg_val(1)

 if ws.auxdat is null       or
    ws.auxdat =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
    if ws.auxdat > today       or
       length(ws.auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_data = ws.auxdat

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws.dirfisnom

  if ws.dirfisnom is null then
     let ws.dirfisnom = "."
  end if

 let ws.pathrel01  = ws.dirfisnom clipped, "/RDBS00901"
 let ws.pathrel02  = ws.dirfisnom clipped, "/RDBS00902"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS00901")
      returning  ws_cctcod01,
         ws_relviaqtd01

 call fgerc010("RDBS00902")
      returning  ws_cctcod02,
                 ws_relviaqtd02

 #---------------------------------------------------------------
 # Ler todas as ligacoes de reclamacao do mes
 #---------------------------------------------------------------
 start report  rep_padrao  to  ws.pathrel01
 start report  rep_distri  to  ws.pathrel02

 declare  c_bdbsr009  cursor for
    select atdsrvnum,
           atdsrvano,
           atdsrvorg,
           atdlibdat,
           atdlibhor,
           atddatprg,
           atdhorprg,
           cnldat,
           atdfnlhor,
           c24opemat,
           atdprscod,
           atdfnlflg
      from datmservico
     where cnldat  =  ws_data         and
           atdsrvorg  in (4, 6, 1, 5, 7, 17, 9, 13, 2, 3) and
           atdfnlflg  in ("", "S")

 foreach c_bdbsr009  into  d_bdbsr009.atdsrvnum,
                           d_bdbsr009.atdsrvano,
                           d_bdbsr009.atdsrvorg,
                           d_bdbsr009.atdlibdat,
                           d_bdbsr009.atdlibhor,
                           d_bdbsr009.atddatprg,
                           d_bdbsr009.atdhorprg,
                           d_bdbsr009.cnldat,
                           d_bdbsr009.atdfnlhor,
                           d_bdbsr009.c24opemat,
                           d_bdbsr009.atdprscod,
                           ws.atdfnlflg

#------------------------------------------------------------
# Verifica etapa dos servicos
#------------------------------------------------------------
#   if ws.atdfnlflg  is null  or
#      ws.atdfnlflg  <> "C"   then
#      continue foreach
#   end if

    #if ws.atdfnlflg = "N"  then
    #   continue foreach
    #end if

    if d_bdbsr009.atdlibdat  is null  or
       d_bdbsr009.atdlibhor  is null  or
       d_bdbsr009.atdfnlhor  is null  then
       continue foreach
    end if

    open  c_datmsrvacp using d_bdbsr009.atdsrvnum, d_bdbsr009.atdsrvano,
                             d_bdbsr009.atdsrvnum, d_bdbsr009.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if d_bdbsr009.atdsrvorg =  13  or
       d_bdbsr009.atdsrvorg =   9  then
       if ws.atdetpcod >= 4  and
          ws.atdetpcod <= 7  then
          continue foreach
       end if
    else
       if ws.atdetpcod <> 4  then
          continue foreach
       end if
    end if

    let d_bdbsr009.atdtiptmp  =  1
    if d_bdbsr009.atddatprg  is not null   and
       d_bdbsr009.atdhorprg  is not null   then
       let d_bdbsr009.atdtiptmp  =  2
    end if

    #---------------------------------------------------------------
    # Verifica se servico esta fora do Tempo Padrao
    #---------------------------------------------------------------
    if d_bdbsr009.atdtiptmp  =  1   then   #--> Servico Imediato
       call bdbsr009_tempo (d_bdbsr009.atdlibdat, d_bdbsr009.atdlibhor,
                            d_bdbsr009.cnldat, d_bdbsr009.atdfnlhor)
            returning  d_bdbsr009.dias, d_bdbsr009.tempo
    else
       if d_bdbsr009.atdtiptmp  =  2   then   #--> Servico Programado
          call bdbsr009_tempo (d_bdbsr009.atddatprg, d_bdbsr009.atdhorprg,
                               d_bdbsr009.cnldat, d_bdbsr009.atdfnlhor)
               returning  d_bdbsr009.dias, d_bdbsr009.tempo
       end if
    end if

    let ws.imprime = 0
    if d_bdbsr009.atdtiptmp  =  1   then
       if d_bdbsr009.dias    >  0       or   #--> Atraso
          d_bdbsr009.tempo   >  "00:10" then #--> Atraso #arnaldo 7/8/02 10m.
         #d_bdbsr009.tempo   >  "00:03" then #--> Atraso
          let ws.imprime = 1
       end if
    else
       if d_bdbsr009.atdtiptmp  =   2   then
          if ((d_bdbsr009.dias    <>  0          or     #--> Atraso
               d_bdbsr009.tempo    >  "00:00"    or     #--> Atraso
               d_bdbsr009.tempo    <  "-02:00")  or     #--> Muita antecedencia
              (d_bdbsr009.tempo    <  "00:00"    and    #--> Sem prazo prestador
               d_bdbsr009.tempo    >  "-01:00")) then   #--> Sem prazo prestador
             let ws.imprime = 1
          end if
       end if
    end if

    output to report rep_distri(d_bdbsr009.*)

    if ws.imprime = 1   then
       output to report rep_padrao(d_bdbsr009.*)
    end if

 end foreach

 finish report  rep_distri
 finish report  rep_padrao

 let ws_email = "Relatorio_dos_Servicos_por_operador "
 let l_retorno = ctx22g00_envia_email("BDBSR009",
                                      ws_email,
                                      ws.pathrel02)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
        display "Erro ao  enviar email(ctx21g00)-",ws.pathrel02
    else
        display "Nao ha email cadastrado para o modulo BDBSR009"
    end if
 end if

 let ws_email = "Servicos_concluidos_fora_tempo_padrao"
 let l_retorno = ctx22g00_envia_email("BDBSR009",
                                      ws_email,
                                      ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
        display "Erro ao  enviar email(ctx21g00)-",ws.pathrel01
    else
        display "Nao ha email cadastrado para o modulo BDBSR009"
    end if
 end if

 close c_bdbsr009

end function  ###  bdbsr009


#---------------------------------------------------------------------------
 report rep_padrao(r_bdbsr009)
#---------------------------------------------------------------------------

 define r_bdbsr009    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg,
    atdtiptmp         smallint,
    atdlibdat         like datmservico.atdlibdat,
    atdlibhor         like datmservico.atdlibhor,
    atddatprg         like datmservico.atddatprg,
    atdhorprg         like datmservico.atdhorprg,
    cnldat            like datmservico.cnldat,
    atdfnlhor         like datmservico.atdfnlhor,
    c24opemat         like datmservico.c24opemat,
    atdprscod         like datmservico.atdprscod,
    dias              smallint,
    tempo             interval hour(06) to minute
 end record

 define ws2           record
    comando           char(400),
    totqtdgrl         dec(6,0),
    totqtdtip         dec(6,0),
    totqtdope         dec(6,0),
    tmptipdes         char(10),
    srvinchor         char(06),
    srvfnlhor         char(06),
    funnom            like isskfunc.funnom,
    litdat            char(04),
    padrao            char(15)
 end record


 output
      left   margin  000
      right  margin  144
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr009.atdtiptmp,
             r_bdbsr009.c24opemat,
             r_bdbsr009.cnldat,
             r_bdbsr009.atdfnlhor

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS00901 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS CONCLUIDOS POR OPERADOR"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
            print ascii(12)

            let ws2.totqtdgrl = 0
            let ws2.totqtdtip = 0
            let ws2.totqtdope = 0

            case  r_bdbsr009.atdtiptmp
                  when  1   let ws2.tmptipdes = "IMEDIATO"
                           #let ws2.padrao    = " ATE 00:03"
                            let ws2.padrao    = " ATE 00:10"
                  when  2   let ws2.tmptipdes = "PROGRAMADO"
                            let ws2.padrao    = "-02:00 A -01:00"
                  otherwise let ws2.tmptipdes = "N/PREVISTO"
            end case

            let ws2.comando = " select funnom ",
                              "  from isskfunc ",
                              " where funmat = ? "

            prepare sel_isskfunc  from ws2.comando
            declare c_isskfunc  cursor for sel_isskfunc

            let ws2.comando = "select min(atdfnlhor) ",
                              "  from datmservico ",
                              " where cnldat = ? " ,
                              "   and atdsrvorg in (4, 6, 1, 5, 7, 17, 9, 13, 2) ",
                              "   and c24opemat = ? ",
                              "   and atdfnlflg in ('', 'S') "

            prepare sel_srvmin  from ws2.comando
            declare c_srvmin  cursor for sel_srvmin

            let ws2.comando = "select max(atdfnlhor) ",
                              "  from datmservico ",
                              " where cnldat = ? " ,
                              "   and atdsrvorg in (4, 6, 1, 5, 7, 17, 9, 13, 2)",
                              "   and c24opemat = ? ",
                              "   and atdfnlflg in ('', 'S') "

            prepare sel_srvmax  from ws2.comando
            declare c_srvmax  cursor for sel_srvmax

         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 112, "RDBS009-01",
               column 126, "PAGINA : "  , pageno using "##,###,##&"
         print column 027, "SERVICOS CONCLUIDOS POR OPERADOR (FORA DO TEMPO PADRAO)  EM: ", ws_data,
               column 126, "DATA   : "  , today
         print column 126, "HORA   :   ", time
         skip 2 lines

         print column 001, "TIPO DE SERVICO: ", ws2.tmptipdes,
               column 032, "(SINISTRO, P.SOCORRO, DAF, RPT, REPLACE, ASS.PASSAGEIROS, R.E.)",
               column 100, "TEMPO PADRAO: ", ws2.padrao
         print column 001, ws_traco144

         print column 001, "MATRICULA",
               column 015, "NOME",
               column 050, "SERVICO",
               column 061, "---- LIBERACAO ----",
               column 084, "--- PROGRAMACAO ---",
               column 106, "---- CONCLUSAO ----",
               column 130, "DIAS",
               column 140, "HORAS"
         print column 001, ws_traco144

         skip 1 line

      before group of r_bdbsr009.c24opemat
         let ws2.totqtdope = 0
         let ws2.funnom = "* FUNCIONARIO NAO CADASTRADO *"

         open  c_isskfunc  using  r_bdbsr009.c24opemat
         fetch c_isskfunc  into   ws2.funnom
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura do nome do funcionario"
         end if
         close c_isskfunc

         print column 004, r_bdbsr009.c24opemat  using "####&&",
               column 015, upshift(ws2.funnom);

      after group of r_bdbsr009.c24opemat
         initialize ws2.srvinchor  to null
         initialize ws2.srvfnlhor  to null

         open  c_srvmin  using  ws_data,
                                r_bdbsr009.c24opemat
         fetch c_srvmin  into   ws2.srvinchor
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura hora inicial operador "
         end if
         close c_srvmin

         open  c_srvmax  using  ws_data,
                                r_bdbsr009.c24opemat
         fetch c_srvmax  into   ws2.srvfnlhor
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura hora final operador "
         end if
         close c_srvmax

         need 3 lines
         print column 001, ws_traco144
         print column 001, "TOTAL DO OPERADOR: ",
               column 027, ws2.totqtdope  using "####&&",
               column 048, "HORA INICIAL: ", ws2.srvinchor,
               column 074, "HORA FINAL: ",   ws2.srvfnlhor
         print column 001, ws_traco144
         skip 2 lines

      before group of r_bdbsr009.atdtiptmp
         case  r_bdbsr009.atdtiptmp
               when  1   let ws2.tmptipdes = "IMEDIATO"
                        #let ws2.padrao    = " ATE 00:03"
                         let ws2.padrao    = " ATE 00:10"
               when  2   let ws2.tmptipdes = "PROGRAMADO"
                         let ws2.padrao    = "-02:00 A -01:00"
               otherwise let ws2.tmptipdes = "N/PREVISTO"
         end case

         let ws2.totqtdtip = 0
         let ws2.totqtdope = 0

         skip to top of page

      after  group of r_bdbsr009.atdtiptmp
         need 4 lines
         skip 1 lines
         print column 001, ws_traco144
         print column 001, "TOTAL DO TIPO DE SERVICO: ",
               column 027, ws2.totqtdtip  using "####&&"
         print column 001, ws_traco144

      on every row
         if r_bdbsr009.atddatprg  is not null   then
            let ws2.litdat = " AS "
         else
            initialize ws2.litdat  to null
         end if

         print column 044, r_bdbsr009.atdsrvorg  using "&&", "/",
                           r_bdbsr009.atdsrvnum  using "&&&&&&&", "-",
                           r_bdbsr009.atdsrvano  using "&&",
               column 061, r_bdbsr009.atdlibdat, " AS ",
                           r_bdbsr009.atdlibhor,
               column 084, r_bdbsr009.atddatprg, ws2.litdat,
                           r_bdbsr009.atdhorprg,
               column 106, r_bdbsr009.cnldat,    " AS ",
                           r_bdbsr009.atdfnlhor,
               column 131, r_bdbsr009.dias  using "##&",  " ",
                           r_bdbsr009.tempo

         let ws2.totqtdgrl = ws2.totqtdgrl + 1
         let ws2.totqtdtip = ws2.totqtdtip + 1
         let ws2.totqtdope = ws2.totqtdope + 1

      on last row
         need 5 lines
         skip 2 lines
         print column 001, ws_traco144
         print column 001, "TOTAL GERAL: ",
               column 027, ws2.totqtdgrl  using "####&&"
         print column 001, ws_traco144

         print "$FIMREL$"

end report  ##3  rep_padrao


#---------------------------------------------------------------------------
 report rep_distri(r_bdbsr009)
#---------------------------------------------------------------------------

 define r_bdbsr009    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg,
    atdtiptmp         smallint,
    atdlibdat         like datmservico.atdlibdat,
    atdlibhor         like datmservico.atdlibhor,
    atddatprg         like datmservico.atddatprg,
    atdhorprg         like datmservico.atdhorprg,
    cnldat            like datmservico.cnldat,
    atdfnlhor         like datmservico.atdfnlhor,
    c24opemat         like datmservico.c24opemat,
    atdprscod         like datmservico.atdprscod,
    dias              smallint,
    tempo             interval hour(06) to minute
 end record

 define ws3           record
    funnom            like isskfunc.funnom,
    c24opemat         like datmservico.c24opemat,
    nomgrr            like dpaksocor.nomgrr,
    comando           char(400),
    totgrlqtd         dec(6,0),
    totopeqtd         dec(6,0),
    totprsqtd         dec(6,0)
 end record


 output
      left   margin  000
     #right  margin  144
      right  margin  080
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr009.c24opemat,
             r_bdbsr009.atdprscod

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS00902 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - DISTRIBUICAO DOS SERVICOS POR PRESTADOR"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
            print ascii(12)

            let ws3.totgrlqtd = 0
            let ws3.totprsqtd = 0
            let ws3.totopeqtd = 0

            let ws3.comando = "select funnom",
                              "  from isskfunc",
                              " where funmat = ? "
            prepare sel_isskfunc3 from ws3.comando
            declare c_isskfunc3 cursor for sel_isskfunc3

            let ws3.comando = "select nomgrr",
                              "  from dpaksocor",
                              " where pstcoddig = ?"
            prepare sel_dpaksocor  from ws3.comando
            declare c_dpaksocor  cursor for sel_dpaksocor

         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 047, "RDBS009-02",
               column 063, "PAGINA: "  , pageno using "##,###,##&"
         print column 001, "DISTRIBUICAO DOS SERVICOS CONCLUIDOS POR OPERADOR EM ", ws_data,

               column 065, "DATA: "  , today
         print column 065, "HORA:   ", time
         skip 2 lines

         print column 001, "MATRICULA",
               column 013, "NOME",
               column 038, "CODIGO",
               column 047, "PRESTADOR",
               column 071, "QUANTIDADE"

         print column 001, ws_traco080
         skip 1 line

      before group of r_bdbsr009.c24opemat
         let ws3.totopeqtd = 0

         open  c_isskfunc3 using  r_bdbsr009.c24opemat
         fetch c_isskfunc3 into   ws3.funnom
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura do nome do funcionario"
         end if
         close c_isskfunc3

         print column 004, r_bdbsr009.c24opemat  using "####&&",
               column 013, upshift(ws3.funnom);

      after group of r_bdbsr009.c24opemat
         print column 075, "------"
         print column 075, ws3.totopeqtd   using "####&&"
         skip 2 lines

      before group of r_bdbsr009.atdprscod
         let ws3.totprsqtd = 0

         open  c_dpaksocor  using  r_bdbsr009.atdprscod
         fetch c_dpaksocor  into   ws3.nomgrr
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura nome guerra prestador"
         end if
         close c_dpaksocor

      after group of r_bdbsr009.atdprscod
         print column 038, r_bdbsr009.atdprscod  using "####&&",
               column 047, upshift(ws3.nomgrr),
               column 075, ws3.totprsqtd         using "####&&"

      on every row
         let ws3.totgrlqtd = ws3.totgrlqtd + 1
         let ws3.totopeqtd = ws3.totopeqtd + 1
         let ws3.totprsqtd = ws3.totprsqtd + 1

      on last row
         need 5 lines
         skip 2 lines
         print column 001, ws_traco080
         print column 001, "TOTAL GERAL: ",
               column 020, ws3.totgrlqtd  using "####&&"
         print column 001, ws_traco080

         print "$FIMREL$"

end report  ###  rep_distri


#-----------------------------------------------------------
 function bdbsr009_tempo(param3)
#-----------------------------------------------------------

 define param3       record
    srvincdat        date,
    srvinchor        char(05),
    srvfnldat        date,
    srvfnlhor        char(05)
 end record

 define ws4          record
    incdat           date,
    fnldat           date,
    resdat           integer,
    chrhor           char(07),
    inchor           interval hour(05) to minute,
    fnlhor           interval hour(05) to minute,
    reshor           interval hour(06) to minute,
    dias             integer,
    fator            smallint
 end record


 let ws4.fator  = 1

 if param3.srvfnldat < param3.srvincdat  then
    let ws4.incdat = param3.srvfnldat
    let ws4.inchor = param3.srvfnlhor

    let ws4.fnldat = param3.srvincdat
    let ws4.fnlhor = param3.srvinchor
    let ws4.fator  = ws4.fator * -1
 else
    let ws4.incdat = param3.srvincdat
    let ws4.inchor = param3.srvinchor

    let ws4.fnldat = param3.srvfnldat
    let ws4.fnlhor = param3.srvfnlhor
 end if

 let ws4.resdat = (ws4.fnldat - ws4.incdat) * 24
 let ws4.reshor = (ws4.fnlhor - ws4.inchor)

 let ws4.chrhor = ws4.resdat using "###&" , ":00"
 let ws4.reshor = ws4.reshor + ws4.chrhor

 for ws4.dias = 0 to 30
     if ws4.reshor < "24:00"  then
        exit for
     end if
     let ws4.reshor = ws4.reshor - "24:00"
 end for

 let ws4.dias   = ws4.dias   * ws4.fator
 let ws4.reshor = ws4.reshor * ws4.fator

 return ws4.dias, ws4.reshor


end function  ###  bdbsr009_tempo
