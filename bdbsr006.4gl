#############################################################################
# Nome do Modulo: bdbsr006                                         Marcelo  #
#                                                                  Gilberto #
# Relatorio diario de total de servicos por prestador              Mai/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 26/05/1998  PSI 3049-0   Gilberto     Relatorio bdbsr006-B inibido.       #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Nao contabilizar servicos atendidos #
#                                       como particular (srvprlflg = "S")   #
#---------------------------------------------------------------------------#
# 06/04/1999  PSI 5591-3   Gilberto     Utilizacao dos campos padronizados  #
#                                       atraves do guia postal.             #
#---------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 13/04/2000               Ruiz         Relatorio truncando.                #
# 20/04/2000                                                                #
#---------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# ---------- --------------------- ------ ------------------------------------#
# 05/10/2006 Priscila              202720 comentado parate fonte nao utilizada#
###############################################################################

 database porto

 define g_duplo80     char(080)
 define g_traco80     char(080)
 define g_traco145    char(145)
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd

 define wsgdata    char(010)

 define m_path      char(100)

 main
    call fun_dba_abre_banco("CT24HS") 

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr006.log"

    call startlog(m_path)
    # PSI 185035 - Final
        
    call bdbsr006()
 end main

#---------------------------------------------------------------
 function bdbsr006()
#---------------------------------------------------------------

 define d_bdbsr006    record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod
 end record

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod  ,
    atdetppndflg      like datketapa.atdetppndflg,
    atdfnlflg         like datmservico.atdfnlflg ,
    vlrtabflg         like dpaksocor.vlrtabflg   ,
    srvprlflg         like datmservico.srvprlflg ,
    dirfisnom         like ibpkdirlog.dirfisnom  ,
    pathrel01         char (60)
 end record

 define sql_select    char(300)

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdbsr006.*  to null
 initialize ws.*          to null

 let g_duplo80  = "================================================================================"
 let g_traco80  = "--------------------------------------------------------------------------------"
 let g_traco145 = "-------------------------------------------------------------------------------------------------------------------------------------------------"

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------

# let sql_select = " select succod, aplnumdig, itmnumdig ",
#                  "   from datrservapol   ",
#                  "  where atdsrvnum = ?  ",
#                  "    and atdsrvano = ?  "
#
# prepare sel_servapol from sql_select
# declare c_servapol cursor for sel_servapol


# let sql_select = "select atdsrvorg, "         ,
#                         "refatdsrvnum, "      ,
#                         "refatdsrvano "       ,
#                    "from DATMASSISTPASSAG a, ",
#                         "DATMSERVICO b "      ,
#                         "where a.atdsrvnum = ? "             ,
#                           "and a.atdsrvano = ? "             ,
#                           "and b.atdsrvnum = a.refatdsrvnum ",
#                           "and b.atdsrvano = a.refatdsrvano "
#
# prepare sel_assistenc from sql_select
# declare c_assistenc cursor for sel_assistenc


 let sql_select = "select nomgrr, endcid, vlrtabflg " ,
                  "  from dpaksocor                 " ,
                  " where pstcoddig = ?             "

 prepare sel_dpaksocor from sql_select
 declare c_dpaksocor cursor for sel_dpaksocor

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
# Data para execucao
#---------------------------------------------------------------

 let wsgdata = arg_val(1)

 if wsgdata is null  or
    wsgdata =  "  "  then
    if time  >= "17:00"   and
       time  <= "23:59"   then
       let wsgdata = today
    else
       let wsgdata = today - 1
    end if
 else
#   if wsgdata >= today      or
    if length(wsgdata) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws.dirfisnom
      
 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS00601"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS00601")
      returning  ws_cctcod,
		 ws_relviaqtd

 #---------------------------------------------------------------
 # Inicio da leitura principal
 #---------------------------------------------------------------
 declare c_bdbsr006 cursor for
    select datmservico.atdsrvnum ,
           datmservico.atdsrvano ,
           datmservico.atdprscod ,
           datmservico.atdsrvorg ,
           datmservico.atdfnlflg ,
           datmservico.asitipcod ,
           datmservico.srvprlflg
      from datmservico
     where datmservico.cnldat  =  wsgdata

 start report  rep_prssrv  to  ws.pathrel01
 start report  rep_totais  to  ws.pathrel01
#start report  rep_taxi    to  "bdbsr006b.rel"

 foreach c_bdbsr006  into  d_bdbsr006.atdsrvnum,
                           d_bdbsr006.atdsrvano,
                           d_bdbsr006.atdprscod,
                           d_bdbsr006.atdsrvorg,
                           ws.atdfnlflg        ,
                           d_bdbsr006.asitipcod,
                           ws.srvprlflg

    if d_bdbsr006.atdprscod is null or    ###  Nao contem codigo de prestador.
       d_bdbsr006.atdprscod =  0    or    ###  Codigo de Prestador e' zero.
       d_bdbsr006.atdprscod = "2"   or    ###  Servico Cancelado
       d_bdbsr006.atdsrvorg = 10    or    ###  Vistoria Previa Domiciliar
       d_bdbsr006.atdsrvorg = 11    or    ###  Aviso Furto/Roubo
       d_bdbsr006.atdsrvorg = 12    or    ###  Servico de Apoio
       d_bdbsr006.atdsrvorg = 8     then  ###  Reserva Carro Extra
       continue foreach
    end if

#------------------------------------------------------------
# Verifica etapa dos servicos
#------------------------------------------------------------
  # if ws.atdfnlflg is null  or
  #    ws.atdfnlflg = "E"    or
  #    ws.atdfnlflg = "L"    then
  #    continue foreach
  # end if

    if ws.srvprlflg = "S"  then
       continue foreach
    end if

    if ws.atdfnlflg = "N"  then
       continue foreach
    end if

    open  c_datmsrvacp using d_bdbsr006.atdsrvnum, d_bdbsr006.atdsrvano,
                             d_bdbsr006.atdsrvnum, d_bdbsr006.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp


    if ws.atdetpcod = 5  or     ###  Servico CANCELADO
       ws.atdetpcod = 6  then   ###  Servico EXCLUIDO
       continue foreach
    end if

    if d_bdbsr006.atdsrvorg = 2  or
       d_bdbsr006.atdsrvorg = 3  then
#      output to report rep_taxi ( wsgdata, d_bdbsr006.atdsrvorg,
#                                           d_bdbsr006.atdsrvnum,
#                                           d_bdbsr006.atdsrvano,
#                                           d_bdbsr006.atdprscod)
       continue foreach
    end if

#---------------------------------------------------------------
# Dados do prestador
#---------------------------------------------------------------

    let d_bdbsr006.nomgrr = "*** NAO CADASTRADO ***"
    let d_bdbsr006.endcid = "*** NAO CADASTRADO ***"

    open  c_dpaksocor using d_bdbsr006.atdprscod
    fetch c_dpaksocor into  d_bdbsr006.nomgrr    ,
                            d_bdbsr006.endcid    ,
                            ws.vlrtabflg
    close c_dpaksocor

    if d_bdbsr006.atdprscod = 1  or
       d_bdbsr006.atdprscod = 4  or
       d_bdbsr006.atdprscod = 8  then
       let d_bdbsr006.atdprstip = 1     ###  Frota Porto Seguro
    else
       if ws.vlrtabflg = "S" then
          let d_bdbsr006.atdprstip = 2  ###  Tabela
       else
          let d_bdbsr006.atdprstip = 3  ###  Outros
       end if
    end if

    output to report rep_prssrv(d_bdbsr006.*)

 end foreach

 finish report rep_prssrv
 finish report rep_totais
#finish report rep_taxi

end function  ###  bdbsr006

#---------------------------------------------------------------------------
 report rep_prssrv(par_bdbsr006)
#---------------------------------------------------------------------------

 define par_bdbsr006  record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod
 end record

 define r_bdbsr006    record
    rem               dec (06,0)                 ,
    soc               dec (06,0)                 ,
    gui               dec (06,0)                 ,
    tec               dec (06,0)                 ,
    amb               dec (06,0)                 ,
    cha               dec (06,0)                 ,
    daf               dec (06,0)                 ,
    rpt               dec (06,0)                 ,
    rep               dec (06,0)                 ,
    sre               dec (06,0)                 ,
    grl               dec (06,0)
 end record

   output
      left   margin  000
      right  margin  001
      top    margin  000
      bottom margin  000
      page   length  080

   order by  par_bdbsr006.atdprstip,
             par_bdbsr006.atdprscod

   format

      before group of par_bdbsr006.atdprscod
             let r_bdbsr006.rem      = 0
             let r_bdbsr006.soc      = 0
             let r_bdbsr006.gui      = 0
             let r_bdbsr006.tec      = 0
             let r_bdbsr006.amb      = 0
             let r_bdbsr006.cha      = 0
             let r_bdbsr006.daf      = 0
             let r_bdbsr006.rpt      = 0
             let r_bdbsr006.rep      = 0
             let r_bdbsr006.sre      = 0
             let r_bdbsr006.grl      = 0

      after  group of par_bdbsr006.atdprscod

             output to report rep_totais(par_bdbsr006.*, r_bdbsr006.*)

      on every row
             case par_bdbsr006.atdsrvorg
                  when 4          # Remocoes
                       let r_bdbsr006.rem = r_bdbsr006.rem + 1
                  when 6          # D.A.F.
                       let r_bdbsr006.daf = r_bdbsr006.daf + 1
                  when 1          # Porto Socorro
                       let r_bdbsr006.soc = r_bdbsr006.soc + 1

                       case par_bdbsr006.asitipcod
                            when  1      # Guincho
                                 let r_bdbsr006.gui = r_bdbsr006.gui + 1
                            when  2      # Tecnico
                                 let r_bdbsr006.tec = r_bdbsr006.tec + 1
                            when  3      # Ambos
                                 let r_bdbsr006.amb = r_bdbsr006.amb + 1
                            when  4      # Chaveiro
                                 let r_bdbsr006.cha = r_bdbsr006.cha + 1
                            when  8      # Chaveiro/Dispositivo
                                 let r_bdbsr006.cha = r_bdbsr006.cha + 1
                       end case

                  when 5          # RPT
                       let r_bdbsr006.rpt = r_bdbsr006.rpt + 1
                  when 7          # Replace
                       let r_bdbsr006.rep = r_bdbsr006.rep + 1
                  when 9          # Socorro R.E.
                       let r_bdbsr006.sre = r_bdbsr006.sre + 1
                  when 13         # Sinistro R.E.
                       let r_bdbsr006.sre = r_bdbsr006.sre + 1
             end case
             let r_bdbsr006.grl = r_bdbsr006.grl + 1

end report  ###  rep_prssrv


#---------------------------------------------------------------------------
 report rep_totais(r_bdbsr006)
#---------------------------------------------------------------------------

 define r_bdbsr006    record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod ,
    rem               dec (6,0)                  ,
    soc               dec (6,0)                  ,
    gui               dec (6,0)                  ,
    tec               dec (6,0)                  ,
    amb               dec (6,0)                  ,
    cha               dec (6,0)                  ,
    daf               dec (6,0)                  ,
    rpt               dec (6,0)                  ,
    rep               dec (6,0)                  ,
    sre               dec (6,0)                  ,
    grl               dec (6,0)
 end record

 define a_bdbsr006    array[04] of record
    dsc               char (06)                  ,
    rem               dec (6,0)                  ,
    soc               dec (6,0)                  ,
    gui               dec (6,0)                  ,
    tec               dec (6,0)                  ,
    amb               dec (6,0)                  ,
    cha               dec (6,0)                  ,
    daf               dec (6,0)                  ,
    rpt               dec (6,0)                  ,
    rep               dec (6,0)                  ,
    sre               dec (6,0)                  ,
    grl               dec (6,0)
 end record

 define arr_aux       smallint
 define tot           smallint

 define porcent       dec (5,2)

   output
      left   margin  000
      right  margin  145
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr006.atdprstip ,
             r_bdbsr006.grl desc

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS00601 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS CONCLUIDOS POR PRESTADOR"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)

            let tot = 4

            for arr_aux = 1  to  4
               case arr_aux
                  when 1  let a_bdbsr006[arr_aux].dsc = "FROTA"
                  when 2  let a_bdbsr006[arr_aux].dsc = "TABELA"
                  when 3  let a_bdbsr006[arr_aux].dsc = "OUTROS"
                  when 4  let a_bdbsr006[arr_aux].dsc = "TODOS"
               end case

               let a_bdbsr006[arr_aux].rem = 0
               let a_bdbsr006[arr_aux].soc = 0
               let a_bdbsr006[arr_aux].gui = 0
               let a_bdbsr006[arr_aux].tec = 0
               let a_bdbsr006[arr_aux].amb = 0
               let a_bdbsr006[arr_aux].cha = 0
               let a_bdbsr006[arr_aux].daf = 0
               let a_bdbsr006[arr_aux].rpt = 0
               let a_bdbsr006[arr_aux].rep = 0
               let a_bdbsr006[arr_aux].sre = 0
               let a_bdbsr006[arr_aux].grl = 0
            end for

            let arr_aux = 1
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 112, "RDBS006-01",
               column 126, "PAGINA : "  , pageno using "##,###,#&&"
         print column 041, "SERVICOS CONCLUIDOS POR PRESTADOR EM ", wsgdata ,
               column 126, "DATA   : "  , today
         print column 126, "HORA   :   ", time
         skip 2 lines
         print column 001, "TIPO PRESTADORES: ", a_bdbsr006[arr_aux].dsc
       # skip 1 lines
         print column 001, g_traco145

         print column 001, "CODIGO"     ,
               column 009, "PRESTADOR"  ,
               column 031, "CIDADE"     ,
               column 058, "REMOCAO"    ,
               column 067, "-----------  SOCORRO  ------------",
               column 103, " D.A.F."    ,
               column 112, " R.P.T."    ,
               column 121, "REPLACE"    ,
               column 130, "   R.E."    ,
               column 139, "  TOTAL"

         print column 067, "GUINCHO"    ,
               column 076, "TECNICO"    ,
               column 085, "  AMBOS"    ,
               column 093, "CHAVEIRO"

         print column 001, g_traco145
         skip 1 line

      before group of r_bdbsr006.atdprstip
         let arr_aux = r_bdbsr006.atdprstip
         skip to top of page

      after group of r_bdbsr006.atdprstip
         skip 2 lines
         print column 001, g_traco145
         print column 001, "TOTAL DE SERVICOS:",
               column 058, a_bdbsr006[arr_aux].rem using "###,##&" ,
               column 067, a_bdbsr006[arr_aux].gui using "###,##&" ,
               column 076, a_bdbsr006[arr_aux].tec using "###,##&" ,
               column 085, a_bdbsr006[arr_aux].amb using "###,##&" ,
               column 094, a_bdbsr006[arr_aux].cha using "###,##&" ,
               column 103, a_bdbsr006[arr_aux].daf using "###,##&" ,
               column 112, a_bdbsr006[arr_aux].rpt using "###,##&" ,
               column 121, a_bdbsr006[arr_aux].rep using "###,##&" ,
               column 130, a_bdbsr006[arr_aux].sre using "###,##&" ,
               column 139, a_bdbsr006[arr_aux].grl using "###,##&"
         print column 001, g_traco145
         skip 1 line

         let a_bdbsr006[tot].rem = a_bdbsr006[tot].rem + a_bdbsr006[arr_aux].rem
         let a_bdbsr006[tot].soc = a_bdbsr006[tot].soc + a_bdbsr006[arr_aux].soc
         let a_bdbsr006[tot].gui = a_bdbsr006[tot].gui + a_bdbsr006[arr_aux].gui
         let a_bdbsr006[tot].tec = a_bdbsr006[tot].tec + a_bdbsr006[arr_aux].tec
         let a_bdbsr006[tot].amb = a_bdbsr006[tot].amb + a_bdbsr006[arr_aux].amb
         let a_bdbsr006[tot].cha = a_bdbsr006[tot].cha + a_bdbsr006[arr_aux].cha
         let a_bdbsr006[tot].daf = a_bdbsr006[tot].daf + a_bdbsr006[arr_aux].daf
         let a_bdbsr006[tot].rpt = a_bdbsr006[tot].rpt + a_bdbsr006[arr_aux].rpt
         let a_bdbsr006[tot].rep = a_bdbsr006[tot].rep + a_bdbsr006[arr_aux].rep
         let a_bdbsr006[tot].sre = a_bdbsr006[tot].sre + a_bdbsr006[arr_aux].sre
         let a_bdbsr006[tot].grl = a_bdbsr006[tot].grl + a_bdbsr006[arr_aux].grl

      on every row
         let a_bdbsr006[arr_aux].rem = a_bdbsr006[arr_aux].rem + r_bdbsr006.rem
         let a_bdbsr006[arr_aux].soc = a_bdbsr006[arr_aux].soc + r_bdbsr006.soc
         let a_bdbsr006[arr_aux].gui = a_bdbsr006[arr_aux].gui + r_bdbsr006.gui
         let a_bdbsr006[arr_aux].tec = a_bdbsr006[arr_aux].tec + r_bdbsr006.tec
         let a_bdbsr006[arr_aux].amb = a_bdbsr006[arr_aux].amb + r_bdbsr006.amb
         let a_bdbsr006[arr_aux].cha = a_bdbsr006[arr_aux].cha + r_bdbsr006.cha
         let a_bdbsr006[arr_aux].daf = a_bdbsr006[arr_aux].daf + r_bdbsr006.daf
         let a_bdbsr006[arr_aux].rpt = a_bdbsr006[arr_aux].rpt + r_bdbsr006.rpt
         let a_bdbsr006[arr_aux].rep = a_bdbsr006[arr_aux].rep + r_bdbsr006.rep
         let a_bdbsr006[arr_aux].sre = a_bdbsr006[arr_aux].sre + r_bdbsr006.sre
         let a_bdbsr006[arr_aux].grl = a_bdbsr006[arr_aux].grl + r_bdbsr006.grl

         print column 001, r_bdbsr006.atdprscod  using "&&&&&&" ,
               column 009, r_bdbsr006.nomgrr                    ,
               column 031, r_bdbsr006.endcid                    ,
               column 058, r_bdbsr006.rem        using "###,##&",
               column 067, r_bdbsr006.gui        using "###,##&",
               column 076, r_bdbsr006.tec        using "###,##&",
               column 085, r_bdbsr006.amb        using "###,##&",
               column 094, r_bdbsr006.cha        using "###,##&",
               column 103, r_bdbsr006.daf        using "###,##&",
               column 112, r_bdbsr006.rpt        using "###,##&",
               column 121, r_bdbsr006.rep        using "###,##&",
               column 130, r_bdbsr006.sre        using "###,##&",
               column 139, r_bdbsr006.grl        using "###,##&"

      on last row
         let r_bdbsr006.atdprstip = 4
         skip to top of page
         skip 5 lines

         print column 021, "============================================================================================================"
         print column 022, "PRESTADOR"  ,
               column 047, "REMOCAO"    ,
               column 057, "SOCORRO"    ,
               column 067, " D.A.F."    ,
               column 077, " R.P.T."    ,
               column 087, "REPLACE"    ,
               column 097, "   R.E."    ,
               column 107, "  TOTAL DE SERVICOS "
         print column 021, "============================================================================================================"

         for arr_aux = 1  to  tot
            if arr_aux = tot  then
               print column 021, "============================================================================================================"
            else
               let porcent = 0
               let porcent = (a_bdbsr006[arr_aux].grl / a_bdbsr006[tot].grl) * 100
            end if
            print column 022, a_bdbsr006[arr_aux].dsc                  ,
                  column 047, a_bdbsr006[arr_aux].rem  using "###,##&" ,
                  column 057, a_bdbsr006[arr_aux].soc  using "###,##&" ,
                  column 067, a_bdbsr006[arr_aux].daf  using "###,##&" ,
                  column 077, a_bdbsr006[arr_aux].rpt  using "###,##&" ,
                  column 087, a_bdbsr006[arr_aux].rep  using "###,##&" ,
                  column 097, a_bdbsr006[arr_aux].sre  using "###,##&" ,
                  column 107, a_bdbsr006[arr_aux].grl  using "###,##&" ;
            if arr_aux = tot  then
               print ""
            else
               print "  -  (" ,  porcent               using "##&.&&%" , ")"
            end if
         end for

         let porcent = 0
         let porcent = (a_bdbsr006[tot].rem / a_bdbsr006[tot].grl) * 100
         print column 047, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].soc / a_bdbsr006[tot].grl) * 100
         print column 057, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].daf / a_bdbsr006[tot].grl) * 100
         print column 067, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].rpt / a_bdbsr006[tot].grl) * 100
         print column 077, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].rep / a_bdbsr006[tot].grl) * 100
         print column 087, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].sre / a_bdbsr006[tot].grl) * 100
         print column 097, porcent     using "##&.&&%"

         skip 10 lines

         print column 021, "================================================================================================"
         print column 022, "SOCORRO"    ,
               column 047, "GUINCHO"    ,
               column 057, "TECNICO"    ,
               column 067, "  AMBOS"    ,
               column 076, "CHAVEIRO"   ,
               column 107, "  TOTAL"
         print column 021, "=============================================================================================="

         print column 022, "TOTAL: "  ,
               column 047, a_bdbsr006[tot].gui  using "###,##&" ,
               column 057, a_bdbsr006[tot].tec  using "###,##&" ,
               column 067, a_bdbsr006[tot].amb  using "###,##&" ,
               column 077, a_bdbsr006[tot].cha  using "###,##&" ,
               column 107, a_bdbsr006[tot].soc  using "###,##&"

         print column 021, "=============================================================================================="
         let porcent = 0
         let porcent = (a_bdbsr006[tot].gui / a_bdbsr006[tot].soc) * 100
         print column 047, porcent        using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].tec / a_bdbsr006[tot].soc) * 100
         print column 057, porcent        using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].amb / a_bdbsr006[tot].soc) * 100
         print column 067, porcent        using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr006[tot].cha / a_bdbsr006[tot].soc) * 100
         print column 077, porcent        using "##&.&&%"

         print "$FIMREL$"

end report  ###  rep_totais

#----------------------------------------------------------------------------#
# report rep_taxi(param_data, par_bdbsr006)
#----------------------------------------------------------------------------#
#
# define param_data   date
#
# define par_bdbsr006 record
#    atdsrvorg        like datmservico.atdsrvorg         ,
#    atdsrvnum        like datmservico.atdsrvnum         ,
#    atdsrvano        like datmservico.atdsrvano         ,
#    atdprscod        like datmservico.atdprscod
# end record
#
# define r_bdbsr006   record
#    nomgrr           like dpaksocor.nomgrr              ,
#    refatdsrvorg     like datmservico.atdsrvorg         ,
#    refatdsrvnum     like datmassistpassag.refatdsrvnum ,
#    refatdsrvano     like datmassistpassag.refatdsrvano ,
#    succod           like datrservapol.succod           ,
#    aplnumdig        like datrservapol.aplnumdig        ,
#    itmnumdig        like datrservapol.itmnumdig
# end record
#
# define ws           record
#    endcid           like dpaksocor.endcid,
#    vlrtabflg        like dpaksocor.vlrtabflg,
#    taxqtdprs        dec (06,00),
#    taxqtdgrl        dec (06,00)
# end record
#
#   output
#      left   margin  000
#      right  margin  080
#      top    margin  000
#      bottom margin  000
#      page   length  080
#
#   order by  par_bdbsr006.atdprscod
#
#   format
#      page header
#           if pageno  =  1   then
#              print "OUTPUT JOBNAME=DBS00602 FORMNAME=BRANCO"
#              print "HEADER PAGE"
#              print "       JOBNAME= CT24HS - ASSISTENCIA A PASSAGEIROS - ENVIO DE TAXI"
#              print "$DJDE$ JDL=XJ0030, JDE=XD0031, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
#              print ascii(12)
#
#              let ws.taxqtdgrl = 0
#           else
#              print "$DJDE$ C LIXOLIXO, ;"
#              print "$DJDE$ C LIXOLIXO, ;"
#              print "$DJDE$ C LIXOLIXO, ;"
#              print "$DJDE$ C LIXOLIXO, END ;"
#              print ascii(12)
#           end if
#
#           print column 048, "RDBS006-02",
#                 column 061, "PAGINA : ", pageno using "##,###,###"
#           print column 061, "DATA   : ", today
#           print column 005, "ASSISTENCIA A PASSAGEIROS - TAXI REF. A ", param_data,
#                 column 061, "HORA   :   ", time
#           skip 2 lines
#
#           print column 001, "CODIGO"    ,
#                 column 010, "PRESTADOR" ,
#                 column 031, "SERVICO"   ,
#                 column 045, "REFERENCIA",
#                 column 059, "SUCURSAL/APOLICE/ITEM"
#
#           print column 001, g_traco80
#           skip 1 line
#
#      before group of par_bdbsr006.atdprscod
#           let r_bdbsr006.nomgrr = "** NAO CADASTRADO **"
#
#           open  c_dpaksocor using par_bdbsr006.atdprscod
#           fetch c_dpaksocor into  r_bdbsr006.nomgrr,
#                                   ws.endcid        ,
#                                   ws.vlrtabflg
#           close c_dpaksocor
#
#           let ws.taxqtdprs = 0
#
#           print column 001, par_bdbsr006.atdprscod     using "&&&&&&"    ,
#                 column 010, r_bdbsr006.nomgrr                          ;
#
#      after  group of par_bdbsr006.atdprscod
#           let ws.taxqtdgrl = ws.taxqtdgrl + ws.taxqtdprs
#
#           need 5 lines
#           skip 1 lines
#           print column 001, g_traco80
#           print column 001, "TOTAL DO PRESTADOR..........: ", ws.taxqtdprs using "<<<,<<&"
#           print column 001, g_traco80
#           skip 1 lines
#
#      on every row
#           open  c_servapol  using par_bdbsr006.atdsrvnum,
#                                   par_bdbsr006.atdsrvano
#           fetch c_servapol  into  r_bdbsr006.succod   ,
#                                   r_bdbsr006.aplnumdig,
#                                   r_bdbsr006.itmnumdig
#           close c_servapol
#
#           open  c_assistenc using par_bdbsr006.atdsrvnum,
#                                   par_bdbsr006.atdsrvano
#           fetch c_assistenc into  r_bdbsr006.refatdsrvorg,
#                                   r_bdbsr006.refatdsrvnum,
#                                   r_bdbsr006.refatdsrvano
#           close c_assistenc
#
#           print column 031, par_bdbsr006.atdsrvorg     using "&&"        ,
#                        "/", par_bdbsr006.atdsrvnum     using "&&&&&&&"   ,
#                        "-", par_bdbsr006.atdsrvano     using "&&"        ;
#
#           if r_bdbsr006.refatdsrvnum is not null  then
#              print column 045, r_bdbsr006.refatdsrvorg  using "&&"      ,
#                           "/", r_bdbsr006.refatdsrvnum  using "&&&&&&&" ,
#                           "-", r_bdbsr006.refatdsrvano  using "&&"      ;
#           end if
#
#           if r_bdbsr006.aplnumdig is not null  then
#              print column 059, r_bdbsr006.succod        using "&&"        ,
#                           "/", r_bdbsr006.aplnumdig     using "&&&&&&&& &",
#                           "/", r_bdbsr006.itmnumdig     using "&&&&&& &"
#           else
#              print " "
#           end if
#
#           let ws.taxqtdprs = ws.taxqtdprs + 1
#
#      on last  row
#           need 4 lines
#           skip 1 lines
#           print column 001, g_duplo80
#           print column 001, "TOTAL GERAL.................: ", ws.taxqtdgrl using "<<<,<<&"
#           print column 001, g_duplo80
#
#           print "$FIMREL$"
#
#end report  ###  rep_taxi
