#############################################################################
# Nome do Modulo: bdbsr032                                         Marcelo  #
#                                                                  Gilberto #
# Relacao de processos para apuracao e analise                     Nov/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 17/02/2000  PSI 10079-0  Gilberto     Substituir tipo de solicitante pelo #
#                                       novo campo criado (c24soltipcod).   #
# --------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

 database porto

 define g_funapol         record
    resultado             char (01)     ,
    dctnumseq             decimal(04,00),
    vclsitatu             decimal(04,00),
    autsitatu             decimal(04,00),
    dmtsitatu             decimal(04,00),
    dpssitatu             decimal(04,00),
    appsitatu             decimal(04,00),
    vidsitatu             decimal(04,00)
 end record

 define g_traco       char(133)

 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd
 define m_path        char(100)                 # Marcio Meta - PSI185035
 
 main 
 
    call fun_dba_abre_banco("CT24HS") 

    let m_path = f_path("DBS","LOG")             # Marcio Meta - PSI185035
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr032.log"

    call startlog(m_path)
    call bdbsr032()
 end main

#---------------------------------------------------------------
 function bdbsr032()
#---------------------------------------------------------------

 define d_bdbsr032    record
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (40)                 ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    succod            like datrligapol.succod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig
 end record

 define ws            record
    data_aux          char (10)                 ,
    data_de           date                      ,
    data_ate          date                      ,
    segnumdig         like gsakseg.segnumdig    ,
    c24funmat         like datmligacao.c24funmat,
    c24soltipcod      like datmligacao.c24soltipcod,
    ligdat            like datmligacao.ligdat   ,
    dirfisnom         like ibpkdirlog.dirfisnom ,
    pathrel01         char (60)
 end record

 define sql_select    char (250)


 let g_traco  = "------------------------------------------------------------------------------------------------------------------------------------"
 initialize d_bdbsr032.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# MONTA PERIODO MENSAL
#---------------------------------------------------------------

 let ws.data_aux = arg_val(1)

 if ws.data_aux is null       or
    ws.data_aux =  "  "       then
    let ws.data_aux = today
 else
    if ws.data_aux >= today      or
       length(ws.data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws.data_aux = "01","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_ate = ws.data_aux
 let ws.data_ate = ws.data_ate - 1 units day

 let ws.data_aux = ws.data_ate
 let ws.data_aux = "01","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_de  = ws.data_aux

#---------------------------------------------------------------
# PREPARACAO DOS SELECT'S
#---------------------------------------------------------------

let sql_select = "select funnom from isskfunc",
                 " where empcod = 1 and funmat = ?"

prepare sel_isskfunc from sql_select
declare c_isskfunc cursor for sel_isskfunc

let sql_select = "select c24soltipdes",
                 "  from datksoltip  ",
                 " where c24soltipcod = ?"
prepare sel_datksoltip from sql_select
declare c_datksoltip cursor for sel_datksoltip

let sql_select = "select segnumdig from abbmdoc",
                 " where succod    = ?  and    ",
                 "       aplnumdig = ?  and    ",
                 "       itmnumdig = ?  and    ",
                 "       dctnumseq = ?         "

prepare sel_abbmdoc  from sql_select
declare c_abbmdoc  cursor for sel_abbmdoc

let sql_select = "select segnom from gsakseg",
                 " where segnumdig = ?      "

prepare sel_gsakseg  from sql_select
declare c_gsakseg  cursor for sel_gsakseg

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                    # Marcio Meta - PSI185035
      returning ws.dirfisnom   
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if        
                                                                 
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS03201"           # Marcio Meta - PSI185035

#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS03201")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod,
		 ws_relviaqtd

#---------------------------------------------------------------
# CURSOR PRINCIPAL
#---------------------------------------------------------------

declare c_bdbsr032   cursor for
   select datmligacao.c24astcod,
          datmligacao.lignum   ,
          datmligacao.c24solnom,
          datmligacao.c24soltipcod,
          datmligacao.c24funmat,
          datmligacao.ligdat   ,
          datmligacao.lighorinc,
          datrligapol.succod   ,
          datrligapol.aplnumdig,
          datrligapol.itmnumdig
     from datmligacao, datrligapol
    where datmligacao.ligdat between ws.data_de and ws.data_ate  and
          datmligacao.c24astcod = "S22"   and
          datrligapol.lignum    = datmligacao.lignum

start report  rep_espec  to  ws.pathrel01

foreach c_bdbsr032  into  d_bdbsr032.c24astcod, d_bdbsr032.lignum   ,
                          d_bdbsr032.c24solnom, ws.c24soltipcod     ,
                          ws.c24funmat        , d_bdbsr032.ligdat   ,
                          d_bdbsr032.lighorinc, d_bdbsr032.succod   ,
                          d_bdbsr032.aplnumdig, d_bdbsr032.itmnumdig

#---------------------------------------------------------------
# Obtencao do NOME DO FUNCIONARIO
#---------------------------------------------------------------

      let d_bdbsr032.funnom = "** NAO CADASTRADO **"

      open  c_isskfunc using ws.c24funmat
      fetch c_isskfunc into  d_bdbsr032.funnom
      close c_isskfunc

      let d_bdbsr032.c24soltipdes = "** NAO CADASTRADO **"

      open  c_datksoltip using ws.c24soltipcod
      fetch c_datksoltip into  d_bdbsr032.c24soltipdes
      close c_datksoltip

#---------------------------------------------------------------
# Obtencao da ULTIMA SITUACAO da apolice
#---------------------------------------------------------------

      call f_funapol_ultima_situacao
           (d_bdbsr032.succod, d_bdbsr032.aplnumdig, d_bdbsr032.itmnumdig)
            returning  g_funapol.*

#---------------------------------------------------------------
# Obtencao do NOME DO SEGURADO
#---------------------------------------------------------------

      open  c_abbmdoc   using d_bdbsr032.succod   , d_bdbsr032.aplnumdig,
                              d_bdbsr032.itmnumdig, g_funapol.dctnumseq
      fetch c_abbmdoc   into  ws.segnumdig
      close c_abbmdoc

      open  c_gsakseg using ws.segnumdig
      fetch c_gsakseg into  d_bdbsr032.segnom
      close c_gsakseg

      output to report rep_espec(d_bdbsr032.*, ws.data_de, ws.data_ate)

end foreach

finish report  rep_espec

end function   ###  bdbsr032


#---------------------------------------------------------------------------
 report rep_espec(r_bdbsr032, data)
#---------------------------------------------------------------------------

   define r_bdbsr032    record
      c24astcod         like datmligacao.c24astcod,
      lignum            like datmligacao.lignum   ,
      c24solnom         like datmligacao.c24solnom,
      c24soltipdes      like datksoltip.c24soltipdes ,
      segnom            char (40)                 ,
      funnom            like isskfunc.funnom      ,
      ligdat            like datmligacao.ligdat   ,
      lighorinc         char (06)                 ,
      succod            like datrligapol.succod   ,
      aplnumdig         like datrligapol.aplnumdig,
      itmnumdig         like datrligapol.itmnumdig
   end record

   define data          record
      inicial           date ,
      final             date
   end record

   define r_bdbsr032h   record
      c24txtseq         like datmlighist.c24txtseq,
      c24ligdsc         like datmlighist.c24ligdsc,
      c24funmat         like datmlighist.c24funmat,
      ligdat            like datmlighist.ligdat   ,
      lighorinc         like datmlighist.lighorinc
   end record

   define ws            record
      c24astdes         char (72)                 ,
      linha             like datmlighist.c24ligdsc,
      funnom            like isskfunc.funnom      ,
      ligdat            like datmlighist.ligdat   ,
      lighorinc         like datmlighist.lighorinc
   end record

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr032.c24astcod, r_bdbsr032.segnom

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS03201 FORMNAME=BRANCO"       # Marcio Meta - PSI185035
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - PROCESSOS PARA APURACAO E ANALISE"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)

              call c24geral8 (r_bdbsr032.c24astcod) returning ws.c24astdes
           else
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, END ;"
             print ascii(12)
           end if
           print column 099, "RDBS032-01",
                 column 113, "PAGINA : ", pageno using "##,###,###"
           print column 113, "DATA   : ", today
           print column 025, "PROCESSOS PARA APURACAO E ANALISE NO PERIODO DE ", data.inicial, " A ", data.final,
                 column 113, "HORA   :   ", time
           skip 2 lines
           print column 001, "ASSUNTO: " , r_bdbsr032.c24astcod ,
                                   " - " , ws.c24astdes
           skip 1 lines
           print column 001, g_traco
           print column 001, "SEGURADO"   ,
                 column 047, "DATA"       ,
                 column 055, "HORA"       ,
                 column 064, "ATENDENTE"  ,
                 column 086, "SOLICITANTE",
                 column 104, "TIPO     "  ,
                 column 117, "DOCUMENTO"

           print column 001, g_traco
           skip 1 line

      before group of r_bdbsr032.c24astcod
           call c24geral8(r_bdbsr032.c24astcod) returning ws.c24astdes
           skip to top of page

      on every row
           print column 001, r_bdbsr032.segnom                     ,
                 column 044, r_bdbsr032.ligdat                     ,
                 column 055, r_bdbsr032.lighorinc                  ,
                 column 064, r_bdbsr032.funnom                     ,
                 column 086, r_bdbsr032.c24solnom                  ,
                 column 104, r_bdbsr032.c24soltipdes[1,10]         ,
                 column 117, r_bdbsr032.succod    using "&&"       ,
                 column 120, r_bdbsr032.aplnumdig using "&&&&&&&&&",
                 column 130, r_bdbsr032.itmnumdig using "&&&"

           declare c_bdbsr032h cursor for
             select ligdat   , lighorinc,
                    c24funmat, c24ligdsc
               from datmlighist
              where datmlighist.lignum = r_bdbsr032.lignum

           foreach c_bdbsr032h into r_bdbsr032h.ligdat   ,r_bdbsr032h.lighorinc,
                                    r_bdbsr032h.c24funmat,r_bdbsr032h.c24ligdsc

           if ws.ligdat <> r_bdbsr032h.ligdat     or
              ws.lighorinc <> r_bdbsr032h.lighorinc  then

              let ws.funnom = "** NAO CADASTRADO **"

              open  c_isskfunc using r_bdbsr032h.c24funmat
              fetch c_isskfunc into  ws.funnom
              close c_isskfunc

              let ws.linha =  "EM: "   , r_bdbsr032h.ligdat    clipped,
                              "  AS: " , r_bdbsr032h.lighorinc clipped,
                              "  POR: ", ws.funnom             clipped
              let ws.ligdat = r_bdbsr032h.ligdat
              let ws.lighorinc = r_bdbsr032h.lighorinc
              skip 1 line

              print column 044,  ws.linha
           end if

           print column 044, r_bdbsr032h.c24ligdsc

      end foreach
      skip 2 lines

      on last  row
           print "$FIMREL$"

end report
