# -------------------------------------------------------------------------#
# Nome do Modulo: bdbsr063                                        Marcelo  #
#                                                                 Gilberto #
#                                                                 Wagner   #
# Relacao semanal reservas por (sinis./benef.) s/processo aberto  Fev/1999 #
# -------------------------------------------------------------------------#
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 30/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas #
#                                       para verificacao do servico.       #
#--------------------------------------------------------------------------#
# 14/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo      #
#                                       atdsrvnum de 6 p/ 10.              #
#                                       Troca do campo atdtip p/ atdsrvorg.#
# -------------------------------------------------------------------------#
# 16/03/2004 OSF 33367     Teresinha S. alteracao do cursor c_bdbsr063     #
# -------------------------------------------------------------------------#
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
# 16/11/2006 Alberto Rodrigues    205206  implementado leitura campo ciaempcod#
#                                        para desprezar qdo for Azul Segur.   #
###############################################################################

 database porto

 define ws_datade     date
 define ws_dataate    date
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd

 define g_traco       char(134)
 define m_path        char(100)

 main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr063.log"

    call startlog(m_path)
    # PSI 185035 - Final

    call bdbsr063()
 end main


#---------------------------------------------------------------
 function bdbsr063()
#---------------------------------------------------------------

 define d_bdbsr063    record
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    atddat            like datmservico.atddat     ,
    succod            like datrservapol.succod    ,
    ramcod            like datrservapol.ramcod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    avioccdat         like datmavisrent.avioccdat ,
    ciaempcod         like datmservico.ciaempcod
 end record

 define ws            record
    comando           char(300)                    ,
    auxdat            char (10)                    ,
    data              date                         ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    ramcod            like datrservapol.ramcod     ,
    sinano            like ssamsin.sinano          ,
    sinnum            like ssamsin.sinnum          ,
    privez            char(1)                      ,
    dirfisnom         like ibpkdirlog.dirfisnom    ,
    pathrel01         char (60)
 end record


#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdbsr063.*  to null
 initialize ws.*          to null

 let ws.privez = "S"
 let g_traco   = "------------------------------------------------------------------------------------------------------------------------------------"


#--------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------

 let ws.comando = "select segnumdig",
                  "  from abbmdoc",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? "
 prepare sel_abbmdoc  from ws.comando
 declare c_abbmdoc  cursor for sel_abbmdoc

 let ws.comando = "select segnom ",
                  "  from gsakseg",
                  " where segnumdig = ? "
 prepare sel_gsakseg  from ws.comando
 declare c_gsakseg  cursor for sel_gsakseg

 let ws.comando = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"

 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

#--------------------------------------------------------------------
# Define data parametro
#--------------------------------------------------------------------
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
 let ws.data  = ws.auxdat


#---------------------------------------------------------------
# Define periodo semanal
#---------------------------------------------------------------
 let ws_datade  = ws.data - 13 units day
 let ws_dataate = ws.data - 7  units day


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS06301"


#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS06301")
      returning  ws_cctcod,
         	 ws_relviaqtd


#---------------------------------------------------------------
# Cursor principal
#---------------------------------------------------------------

 declare  c_bdbsr063  cursor for
    select datmservico.atdsrvnum , datmservico.atdsrvano ,
           datmservico.atdsrvorg ,
           datmservico.atddat    , datrservapol.succod   ,
           datrservapol.ramcod   , datrservapol.aplnumdig,
           datrservapol.itmnumdig, datmavisrent.avioccdat,
           datmservico.ciaempcod
      from datmservico, datrservapol, datmavisrent
     where datmservico.atddat      between ws_datade and ws_dataate
       and datmservico.atdsrvorg   =  8   # reserva
  #    and datmservico.atdfnlflg   = "C"
       and datmservico.atdfnlflg   = "S"
       and datrservapol.atdsrvnum  = datmservico.atdsrvnum
       and datrservapol.atdsrvano  = datmservico.atdsrvano
       and datmavisrent.atdsrvnum  = datmservico.atdsrvnum
       and datmavisrent.atdsrvano  = datmservico.atdsrvano
  #    and datmavisrent.avialgmtv  in (1,3) -- OSF 33367
       and datmavisrent.avialgmtv  in (1,3, 6)

 start report  rep_semproc  to  ws.pathrel01

 foreach c_bdbsr063  into  d_bdbsr063.atdsrvnum , d_bdbsr063.atdsrvano ,
                           d_bdbsr063.atdsrvorg ,
                           d_bdbsr063.atddat    , d_bdbsr063.succod   ,
                           d_bdbsr063.ramcod    , d_bdbsr063.aplnumdig,
                           d_bdbsr063.itmnumdig , d_bdbsr063.avioccdat,
                           d_bdbsr063.ciaempcod

    if d_bdbsr063.ciaempcod = 35  or       
       d_bdbsr063.ciaempcod = 40  or       
       d_bdbsr063.ciaempcod = 43  or 
       d_bdbsr063.ciaempcod = 27  then # PSI 247936 Empresas 27    
       continue foreach            
    end if                         

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using d_bdbsr063.atdsrvnum, d_bdbsr063.atdsrvano,
                             d_bdbsr063.atdsrvnum, d_bdbsr063.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod <> 4      then   # somente servicos etapa concluida
       continue foreach
    end if

#---------------------------------------------------------------
# Verifica se tem processo de sinistro em aberto
#---------------------------------------------------------------
    if d_bdbsr063.succod    is not null  and
       d_bdbsr063.aplnumdig is not null  and
       d_bdbsr063.itmnumdig is not null  then

       if d_bdbsr063.avioccdat is null then
          let d_bdbsr063.avioccdat = d_bdbsr063.atddat
       end if

       call osauc040_sinistro(d_bdbsr063.ramcod,      # ramo
                              d_bdbsr063.succod,      # sucursal
                              d_bdbsr063.aplnumdig,   # apolice
                              d_bdbsr063.itmnumdig,   # item
                              d_bdbsr063.avioccdat,   # dt.sinistro
                              d_bdbsr063.avioccdat,   # dt.sinistro
                              ws.privez)
                   returning  ws.ramcod,
                              ws.sinano,
                              ws.sinnum

       let ws.privez = "N"

       if ws.sinano is null and
          ws.sinnum is null then
          output to report rep_semproc(d_bdbsr063.*)
       end if

    end if

 end foreach

 finish report  rep_semproc

end function  ###  bdbsr063


#---------------------------------------------------------------------------
 report rep_semproc(r_bdbsr063)
#---------------------------------------------------------------------------

 define r_bdbsr063    record
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    atddat            like datmservico.atddat     ,
    succod            like datrservapol.succod    ,
    ramcod            like datrservapol.ramcod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    avioccdat         like datmavisrent.avioccdat ,
    ciaempcod         like datmservico.ciaempcod
 end record

 define ws_rep        record
    segnumdig         like gsakseg.segnumdig,
    segnom             char(40),
    total             integer
 end record

 define ws_funapol    record
    resultado         char (01),
    dctnumseq         decimal(04,00),
    vclsitatu         decimal(04,00),
    autsitatu         decimal(04,00),
    dmtsitatu         decimal(04,00),
    dpssitatu         decimal(04,00),
    appsitatu         decimal(04,00),
    vidsitatu         decimal(04,00)
 end record

 output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066


   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS06301 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RELACAO RESERVAS SEM PROCESSO"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)
              let ws_rep.total  = 0
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if
           print column 099, "RDBS063-01",
                 column 113, "PAGINA : ", pageno using "##,###,###"
           print column 113, "DATA   : ", today
           print column 025, "RESERVAS SEM PROCESSO EM ABERTO NO PERIODO DE ",
                             ws_datade, " A ", ws_dataate,
                 column 113, "HORA   :   ", time
           skip 2 lines

           print column 001, g_traco

           print column 015, "SERVICO "  ,
                 column 028, "DT.SOLIC." ,
                 column 042, "DT.SINIS.",
                 column 055, "SUC./APOLICE/ITEM",
                 column 078, "NOME SEGURADO"

           print column 001, g_traco
           skip 1 line

      on every row
          #---------------------------------------------------------------
          # Busca ultima situacao da apolice / Nome do segurado
          #---------------------------------------------------------------
          initialize ws_rep.segnumdig   to null
          let ws_rep.segnom = "* NOME DO SEGURADO NAO CADASTRADO *"

          initialize ws_funapol.*   to null
          call f_funapol_ultima_situacao
               (r_bdbsr063.succod, r_bdbsr063.aplnumdig, r_bdbsr063.itmnumdig)
                returning  ws_funapol.*

          open  c_abbmdoc   using r_bdbsr063.succod   , r_bdbsr063.aplnumdig,
                                  r_bdbsr063.itmnumdig, ws_funapol.dctnumseq
          fetch c_abbmdoc   into  ws_rep.segnumdig
          close c_abbmdoc

          if ws_rep.segnumdig  is not null   then
             open  c_gsakseg using ws_rep.segnumdig
             fetch c_gsakseg into  ws_rep.segnom
             close c_gsakseg
          end if

           print column 014, r_bdbsr063.atdsrvorg  using "&&"       ,
                        "/", r_bdbsr063.atdsrvnum  using "&&&&&&&"   ,
                        "-", r_bdbsr063.atdsrvano  using "&&"       ,
                 column 028, r_bdbsr063.atddat                      ,
                 column 041, r_bdbsr063.avioccdat                   ,
                 column 055, r_bdbsr063.succod     using "&&"       ,
                 column 058, r_bdbsr063.aplnumdig  using "&&&&&&&&&",
                 column 068, r_bdbsr063.itmnumdig  using "&&&&&&"   ,
                 column 078, ws_rep.segnom

           let ws_rep.total = ws_rep.total + 1

      on last  row
           skip 2 lines
           print column 001, g_traco
           print column 001, "TOTAL DE SERVICOS ",
                             ws_rep.total   using "##,##&"
           print column 001, g_traco

           print "$FIMREL$"

end report  ###  rep_semproc
