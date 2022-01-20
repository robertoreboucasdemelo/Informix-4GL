#############################################################################
# Nome do Modulo: bdbsa200                                         Wagner   #
#                                                                           #
# Cria OP e envia (via e-mail) aos prestadores - RE                Jan/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 16/07/2002  PSI 15620-5  Wagner       Adaptacao funcao de pesquisa precos #
#                                       para servicos RE.                   #
#---------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Aumentar pesquisa para 180dias ant. #
#                                                                           #
#---------------------------------------------------------------------------#
# 17/03/2004  PSI-193946   M. Hashiguti Habilitar geracao de OPs de serv. c/#
#                                       acertos de valores efetuados pelo   #
#                                       portal de negocios - Prest. On-Line #
#                                       OSF-33677                           #
#---------------------------------------------------------------------------#
# 02/04/2004  Cesar Lucca               O programa passa comparar o conteudo#
#             CT197475                  do campo Outras Cias (ws.outciatxt) #
#                                       com as constantes "Internet Auto"   #
#                                       e "Internet Auto e RE", sendo que   #
#                                       ele vai inicializar as variaveis com#
#                                       nulo e passar para o proximo        #
#                                       registro caso a comparacao seja     #
#                                       diferente a uma das constantes .    #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# 06/12/2004 Helio (Meta)      PSI188220  Alteracoes diversas               #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                        #
#                                                                           #
# Data       Autor Fabrica         PSI    Alteracoes                        #
# ---------- --------------------- ------ ----------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco#
#...........................................................................#
# 26/12/2005 Cristiane Silva              Alterar de 180 para 365 dias a    #
#                                         pesquisa de serviços              #
#...........................................................................#
# 07/03/2006 Cristiane e Lucas PSI198005  Enviar ao Portal de Negócios      #
#                                         servicos com eventos 1, 31 e 34   #
#...........................................................................#
# 12/06/2006 Cristiane Silva   PSI201022  Enviar ao Portal de Negocios      #
#                                         servicos de retorno               #
#...........................................................................#
# 14/02/2007 Fabiano, Meta    AS 130087   Migracao para a versao 7.32       #
#                                                                           #
#...........................................................................#
# 25/07/2007 Cristiane Silva  PSI207233   Serviços com débito em ccusto.    #
#...........................................................................#
# 08/08/2007 Sergio Burini    PSI 211001  Inclusão de Adicional Noturno,    #
#                                         Feriado e Domingo                 #
# 20/09/2007 Ligia Mattge     PSI 211982  Desprezar servicos da Portoseg (40)
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
# 13/07/2009  PSI 198404  Fabio Costa   Gravar sucursal do prestador na OP, #
#                                       executar como 4GC                   #
# 31/05/2010  CT 782696   Fabio Costa   Gravar empresa do item na OP        #
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                        de mais de duas casas decimais.    #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn #
#############################################################################

database porto

define ws_incdat       date
define ws_fnldat       date
define ws_socfatentdat date
define ws_socfatpgtdat date
define ws_entrega      date
define ws_crnpgtcod    decimal(2,0)
define ws_countfor     smallint
define ws_flgdiabom    smallint

define m_path          char(100) # PSI 185035

define m_res           smallint,
       m_msg           char(70),
       m_opgems        integer ,
       m_proc          integer ,
       m_empcod        like dbsmopg.empcod

main

  call fun_dba_abre_banco("CT24HS")

  set isolation to dirty read

  initialize ws_incdat      , ws_fnldat      , ws_socfatentdat,
             ws_socfatpgtdat, ws_entrega     , ws_crnpgtcod   ,
             ws_countfor    , ws_flgdiabom   , m_path         ,
             m_res          , m_msg          , m_opgems       ,
             m_proc         , m_empcod  to null

  # PSI 185035 - Inicio
  let m_path = f_path("DBS","LOG")

  if m_path is null then
     let m_path = "."
  end if

  let m_path = m_path clipped,"/bdbsa200.log"
  call startlog(m_path)

  let m_path = f_path("DBS","ARQUIVO")

  if m_path is null then
     let m_path = "."
  end if
  # PSI 185035 - Final

  call bdbsa200()

  display ""
  display ""
  display "------------------------------------------------------------"
  display " RESUMO BDBSA200:  "
  display " OPs emitidas....: ", m_opgems using "######&&"
  display "------------------------------------------------------------"

end main


#---------------------------------------------------------------
function bdbsa200()
#---------------------------------------------------------------

  define d_bdbsa200   record
     quebra           integer                     ,
     ciaempcod        like datmservico.ciaempcod  ,
     atdsrvnum        like datmservico.atdsrvnum  ,
     atdsrvano        like datmservico.atdsrvano  ,
     atdsrvorg        like datmservico.atdsrvorg  ,
     atddat           like datmservico.atddat     ,
     atdhor           like datmservico.atdhor     ,
     asitipcod        like datmservico.asitipcod  ,
     atdprscod        like datmservico.atdprscod  ,
     vclcoddig        like datmservico.vclcoddig  ,
     local_ori        char (50)                   ,
     atdvclsgl        like datmservico.atdvclsgl  ,
     maides           like dpaksocor.maides       ,
     crnpgtcod        like dpaksocor.crnpgtcod    ,
     c24evtcod        like datmsrvanlhst.c24evtcod,
     c24fsecod        like datmsrvanlhst.c24fsecod,
     soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum,
     socopgitmvlr     like dbsmopgitm.socopgitmvlr,
     pestip           like dpaksocor.pestip       ,
     soctrfcod        like dpaksocor.soctrfcod    ,
     socntzdes        like datksocntz.socntzdes
  end record

  define ws           record
     auxdat           char (10)                   ,
     pgtdat           like datmservico.pgtdat     ,
     srvprlflg        like datmservico.srvprlflg  ,
     cnldat           like datmservico.cnldat     ,
     atdfnlhor        like datmservico.atdfnlhor  ,
     socvclcod        like datmservico.socvclcod  ,
     atdetpcod        like datmsrvacp.atdetpcod   ,
     c24evtcod        like datmsrvanlhst.c24evtcod,
     c24evtcod_svl    like datmsrvanlhst.c24evtcod,
     c24fsecod        like datmsrvanlhst.c24fsecod,
     c24fsecod_svl    like datmsrvanlhst.c24fsecod,
     caddat           like datmsrvanlhst.caddat   ,
     caddat_svl       like datmsrvanlhst.caddat   ,
     pstcoddig        like datkveiculo.pstcoddig  ,
     crnpgtstt        like dbsmcrnpgt.crnpgtstt   ,
     crnpgtetgdat     like dbsmcrnpgtetg.crnpgtetgdat,
     socopgnum        like dbsmopgitm.socopgnum   ,
     socgtfcod        like dbstgtfcst.socgtfcod   ,
     socgtfcod_acn    like dbstgtfcst.socgtfcod   ,
     vclcoddig_acn    like datmservico.vclcoddig  ,
     canpgtcod        decimal (1,0)               ,
     difcanhor        datetime hour to minute     ,
     comando          char (400)                  ,
     nrdia            integer                     ,
     erro             char (01)                   ,
     flganl           integer                     ,
     diasem           smallint                    ,
     srvrec           smallint                    ,
     atdcstvlr        like datmservico.atdcstvlr  ,
     prslocflg        like datmservico.prslocflg  ,
     socntzcod        like datmsrvre.socntzcod    ,
     vlrsugerido      like dbsksrvrmeprc.srvrmevlr,
     vlrmaximo        like dbsksrvrmeprc.srvrmevlr,
     vlrdiferenc      like dbsksrvrmeprc.srvrmedifvlr,
     vlrmltdesc       like dbsksrvrmeprc.srvrmedscmltvlr,
     nrsrvs           smallint,
     flgtab           smallint,
     lgdtip           like datmlcl.lgdtip,
     lgdnom           like datmlcl.lgdnom,
     lgdnum           like datmlcl.lgdnum,
     brrnom           like datmlcl.brrnom,
     cidnom           like datmlcl.cidnom,
     ufdcod           like datmlcl.ufdcod,
     c24astcod_ret    like datmligacao.c24astcod,
     qldgracod        like dpaksocor.qldgracod,
     outciatxt        like dpaksocor.outciatxt,
     crnpgtcod        like dpaksocor.crnpgtcod,
     vlr_bloqueio     decimal(2,0),
     atdprscodorg     like datmservico.atdprscod,
     srvrmedifvlr     like dbsksrvrmeprc.srvrmedifvlr,
     pstcoddig_ant    like datmsrvacp.pstcoddig,
     srrcoddig_ant    like datmsrvacp.srrcoddig,
     socvclcod_ant    like datmsrvacp.socvclcod,
     opsrvdias        smallint
  end record

  define lr_ctc20m09     record
         coderro         integer,                  ## Cod.erro ret.0=OK/<>0 Error
         msgerro         char(100),                ## Mensagem erro retorno
         pstprmvlr       like dpampstprm.pstprmvlr
  end record

  define l_socadccstqtd  smallint
  define l_c24fsecod     like datmsrvanlhst.c24fsecod
  define l_arq           char(50)
  define l_c24txtseq     like datmservhist.c24txtseq
  define l_msgbonif      char(300)

  #--------------------------------------------------------------------
  # Inicializacao das variaveis
  #--------------------------------------------------------------------
  let m_res = null
  let m_msg = null
  let l_c24fsecod = null
  initialize d_bdbsa200.*   to null
  initialize ws.*           to null
  initialize lr_ctc20m09.*  to null
  initialize l_socadccstqtd to null
  initialize l_c24txtseq    to null
  initialize l_msgbonif     to null


  #--------------------------------------------------------------------
  # Preparando SQL PRESTADOR
  #--------------------------------------------------------------------
  let ws.comando  = "select maides,crnpgtcod,pestip,soctrfcod,qldgracod,outciatxt ",
                    "  from dpaksocor     ",
                    " where pstcoddig = ? "
  prepare sel_dpaksocor from ws.comando
  declare c_dpaksocor cursor for sel_dpaksocor

  ### #--------------------------------------------------------------------
  ### # Preparando SQL ETAPAS
  ### #--------------------------------------------------------------------
  ### let ws.comando  = "select atdetpcod    ",
  ###                   "  from datmsrvacp   ",
  ###                   " where atdsrvnum = ?",
  ###                   "   and atdsrvano = ?",
  ###                   "   and atdsrvseq = (select max(atdsrvseq)",
  ###                                       "  from datmsrvacp    ",
  ###                                       " where atdsrvnum = ? ",
  ###                                       "   and atdsrvano = ?)"
  ### prepare sel_datmsrvacp from ws.comando
  ### declare c_datmsrvacp cursor for sel_datmsrvacp

  #--------------------------------------------------------------------
  # Preparando SQL ITENS OP
  #--------------------------------------------------------------------
  let ws.comando  = "select dbsmopg.socopgnum     ",
                    "  from dbsmopgitm, dbsmopg    ",
                    " where dbsmopgitm.atdsrvnum = ? ",
                    "   and dbsmopgitm.atdsrvano = ? ",
                    "   and dbsmopg.socopgnum    = dbsmopgitm.socopgnum ",
                    "   and dbsmopg.socopgsitcod <> 8 "
  prepare sel_dbsmopgitm from ws.comando
  declare c_dbsmopgitm cursor for sel_dbsmopgitm

  #--------------------------------------------------------------------
  # Preparando SQL EVENTO DE ANALISE
  #--------------------------------------------------------------------
  let ws.comando  = "select c24evtrdzdes    ",
                    "  from datkevt         ",
                    " where c24evtcod  =  ? "
  prepare sel_datkevt from ws.comando
  declare c_datkevt cursor for sel_datkevt

  #--------------------------------------------------------------------
  # Preparando SQL FASE DE ANALISE
  #--------------------------------------------------------------------
  let ws.comando  = "select c24fsedes     ",
                    "  from datkfse       ",
                    " where c24fsecod = ? "
  prepare sel_datkfse from ws.comando
  declare c_datkfse cursor for sel_datkfse

  #--------------------------------------------------------------------
  # Preparando SQL SIGLA VEICULO
  #--------------------------------------------------------------------
  let ws.comando  = "select atdvclsgl, vclcoddig ",
                    "  from datkveiculo   ",
                    " where socvclcod = ? "
  prepare sel_datkveiculo from ws.comando
  declare c_datkveiculo cursor for sel_datkveiculo

  #--------------------------------------------------------------------
  # Preparando SQL para local origem RE
  #--------------------------------------------------------------------
  let ws.comando  = "select lgdtip, lgdnom, lgdnum, ",
                    "       brrnom, cidnom, ufdcod  ",
                    "  from datmlcl                 ",
                    " where datmlcl.atdsrvnum = ?   ",
                    "   and datmlcl.atdsrvano = ?   ",
                    "   and datmlcl.c24endtip = 1   "
  prepare sel_datmlcl from ws.comando
  declare c_datmlcl cursor for sel_datmlcl

  #--------------------------------------------------------------------
  # Preparando SQL para natureza RE
  #--------------------------------------------------------------------
  let ws.comando  = "select socntzdes ",
                    "  from datksocntz ",
                    " where socntzcod = ? "
  prepare sel_datksocntz from ws.comando
  declare c_datksocntz cursor for sel_datksocntz

  #--------------------------------------------------------------------
  # Preparando SQL para verificar se novo (RET)orno
  #--------------------------------------------------------------------
  let ws.comando  = "select datmligacao.c24astcod ",
                    "  from datmligacao ",
                    " where datmligacao.atdsrvnum = ? ",
                    "   and datmligacao.atdsrvano = ? ",
                    "   and datmligacao.lignum <> 0  "
  prepare sel_datmligacao from ws.comando
  declare c_datmligacao cursor for sel_datmligacao

  let ws.comando = " select c24fsecod ",
                     " from datmsrvanlhst ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? ",
                      " and c24evtcod = ? ",
                      " and srvanlhstseq = 1 "
  prepare pbdbsa200001 from ws.comando
  declare cbdbsa200001 cursor for pbdbsa200001

  #---------------------------------------------------------------------
  #  Identificando prestador do servico de origem
  #---------------------------------------------------------------------
  let ws.comando = " select nrosrv, anosrv, pgttipcodps, empcod, succod, cctcod ",
               " from dbscadtippgt ",
              " where nrosrv = ? ",
                " and anosrv = ? "
  prepare pbdbsa200021 from ws.comando
  declare cbdbsa200021 cursor for pbdbsa200021

  let ws.comando = " select atdsrvnum, atdsrvano, cctcod ",
             " from dbsmcctrat ",
             " where atdsrvnum = ? ",
             " and atdsrvano = ? "
  prepare pbdbsa200022 from ws.comando
  declare cbdbsa200022 cursor for pbdbsa200022

  #--------------------------------------------------------------------
  # Cria tabelas temporarias auxiliares
  #--------------------------------------------------------------------
  create temp table tbtemp_op
    (socopgnum        decimal (8,0),
     socopgitmnum     decimal (4,0),
     socntzdes        char (30),
     atdsrvorg        smallint,
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0),
     atddat           date ,
     atdhor           char (05),
     atdvclsgl        char (03),
     local_ori        char (50),
     portofx          decimal (2,0),
     portovlr         decimal (15,5),
     prestfx          decimal (2,0),
     prestvlr         decimal (15,5),
     adicivlr         decimal (15,5),
     kmexeqtd         decimal (15,5),
     kmexevlr         decimal (15,5),
     pedagvlr         decimal (15,5),
     matervlr         decimal (15,5),
     visitvlr         decimal (15,5),
     socopgitmvlr     decimal (15,5)) with no log

  create temp table tbtemp_ap
    (atdsrvorg        smallint,
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0),
     socntzdes        char (30),
     atddat           date ,
     atdhor           char (05),
     atdvclsgl        char (03),
     local_ori        char (50),
     c24evtrdzdes     char (25),
     c24fsedes        char (25)) with no log

  create temp table tbtemp_for
    (pstcoddig        decimal (6,0)) with no log

  let m_opgems = 0

  #--------------------------------------------------------------------
  # Deficao das datas parametro
  #--------------------------------------------------------------------
  let ws.auxdat = arg_val(1)

  if ws.auxdat is null or  ws.auxdat =  "  " then
     let ws.auxdat = today
  else
     if ws.auxdat > today or length(ws.auxdat) < 10  then
        display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***"
        exit program
     end if
  end if

  select grlinf into ws.opsrvdias
    from datkgeral
   where grlchv = "PSOOPSRVDIAS"

  if sqlca.sqlcode <> 0 then
     let ws.opsrvdias = 180
  end if

  let ws_fnldat = ws.auxdat
  let ws_incdat = ws_fnldat - ws.opsrvdias units day

  display " Busca servicos a partir de ", ws_incdat, " (", ws.opsrvdias using "<<<&", " dias)"

  #------------------------------------------------------
  # Pesquisa todos os codigos de cronograma em funcao da data
  #------------------------------------------------------
  declare c_cronograma cursor for
   select dbsmcrnpgtetg.crnpgtcod
     from dbsmcrnpgtetg
    where dbsmcrnpgtetg.crnpgtetgdat = ws_fnldat

  foreach c_cronograma into ws_crnpgtcod
     insert into tbtemp_for
                 select pstcoddig
                   from dpaksocor
                  where crnpgtcod = ws_crnpgtcod
  end foreach

  let ws_socfatentdat = ws_fnldat  # DATA ENTREGA DO PRESTADOR
  let ws_socfatpgtdat = dias_uteis(ws_socfatentdat, 7, "", "S", "S") #PSI 188220

  #--------------------------------------------------------------------
  # Cursor principal - Servicos executados por prestadores
  #--------------------------------------------------------------------
  declare  c_datmservico  cursor with hold for
     select datmservico.atdsrvnum  , datmservico.atdsrvano  ,
            datmservico.atdsrvorg  , datmservico.atddat     ,
            datmservico.atdhor     , datmservico.asitipcod  ,
            datmservico.atdprscod  , datmservico.srvprlflg  ,
            datmservico.cnldat     , datmservico.atdfnlhor  ,
            datmservico.vclcoddig  , datmservico.atdvclsgl  ,
            datmservico.pgtdat     , datmservico.socvclcod  ,
            datmservico.atdcstvlr  , datmservico.prslocflg,
            datmservico.ciaempcod  , datmservico.atdetpcod
       from datmservico
      where datmservico.atddat between  ws_incdat  and  ws_fnldat
        and datmservico.atdsrvorg in ( 9 )
        and pgtdat is null
        and datmservico.atdetpcod in (3, 10)

  let l_arq = m_path clipped ,"/bdbsa200.txt"

  start report bdbsa200_rel to l_arq

  foreach c_datmservico into d_bdbsa200.atdsrvnum, d_bdbsa200.atdsrvano,
                             d_bdbsa200.atdsrvorg, d_bdbsa200.atddat   ,
                             d_bdbsa200.atdhor   , d_bdbsa200.asitipcod,
                             d_bdbsa200.atdprscod, ws.srvprlflg        ,
                             ws.cnldat           , ws.atdfnlhor        ,
                             d_bdbsa200.vclcoddig, d_bdbsa200.atdvclsgl,
                             ws.pgtdat           , ws.socvclcod        ,
                             ws.atdcstvlr        , ws.prslocflg,
                             d_bdbsa200.ciaempcod, ws.atdetpcod

     display ""
     display "Inicio analise - Servico: ",
             d_bdbsa200.atdsrvnum, "/", d_bdbsa200.atdsrvano

     if d_bdbsa200.ciaempcod = 40 then
        display "Empresa 40"
        continue foreach
     end if

     let d_bdbsa200.c24evtcod = 0

     #PSI201022 - Inicio
     if ws.atdetpcod = 10 then
        #Busca o prestador do servico anterior
        call cts10g04_busca_prest_ant(d_bdbsa200.atdsrvnum,
                                      d_bdbsa200.atdsrvano)
             returning ws.pstcoddig_ant,
                       ws.srrcoddig_ant,
                       ws.socvclcod_ant

        if d_bdbsa200.atdprscod = ws.pstcoddig_ant then
           display "Retorno do mesmo prestador: ", d_bdbsa200.atdprscod
           initialize d_bdbsa200.* , ws.*  to null
           continue foreach
        end if
     end if
     #PSI201022 - Fim

     #------------------------------------------------------------
     # VERIFICA SERVICO PARTICULAR = PAGO PELO CLIENTE
     #------------------------------------------------------------
     if ws.srvprlflg = "S"  then
        initialize d_bdbsa200.* , ws.*  to null
        continue foreach
     end if

     open  c_dpaksocor using d_bdbsa200.atdprscod
     fetch c_dpaksocor into  d_bdbsa200.maides,
                             d_bdbsa200.crnpgtcod,
                             d_bdbsa200.pestip,
                             d_bdbsa200.soctrfcod,
                             ws.qldgracod,
                             ws.outciatxt
     close c_dpaksocor

     ### VERIFICA SE PRESTADOR TEM CRONOGRAMA DE PAGAMENTO
     if d_bdbsa200.crnpgtcod < 1 then
        initialize d_bdbsa200.* , ws.*  to null
        display "Prestador sem cronograma de Pagamento"
        continue foreach
     end if

     if  ws.outciatxt <> "INTERNET RE"
     and ws.outciatxt <> "INTERNET AUTO E RE" then
         initialize d_bdbsa200.* , ws.*    to null
         display "Texto Outras Companhias <> AUTO e RE"
         continue foreach
     end if

     #------------------------------------------------------------
     # VERIFICA NOVO FLAG PRESTADOR NO LOCAL
     #------------------------------------------------------------
     if ws.prslocflg is not null and
        ws.prslocflg = "S"       then
        ### RETER P/ANALISE PRESTADOR NO LOCAL
        if ws.qldgracod = 1 then  # padrao porto
           call ctb00g01_anlsrv( 31,
                                 "",
                                 d_bdbsa200.atdsrvnum,
                                 d_bdbsa200.atdsrvano,
                                 999999 )
        else
           call ctb00g01_anlsrv( 34,
                                 "",
                                 d_bdbsa200.atdsrvnum,
                                 d_bdbsa200.atdsrvano,
                                 999999 )
        end if
     end if
     #------------------------------------------------------------
     # VERIFICA PRESTADOR
     #------------------------------------------------------------
     if d_bdbsa200.atdprscod is null or
        d_bdbsa200.atdprscod = 6     then
        if ws.atdetpcod  =  3  then   # servico concluido
           ### RETER P/ANALISE SERVICO SEM PRESTADOR
           call ctb00g01_anlsrv( 6,
                                 "",
                                 d_bdbsa200.atdsrvnum,
                                 d_bdbsa200.atdsrvano,
                                 999999 )
        end if
        initialize d_bdbsa200.* , ws.*  to null
        display "Prestador eh nulo ou cod 6"
        continue foreach
     else
        if d_bdbsa200.atdprscod = 5  then
           if ws.atdetpcod  =  3  then   # servico concluido
              ### RETER P/ANALISE PRESTADOR NO LOCAL
              call ctb00g01_anlsrv( 5,
                                    "",
                                    d_bdbsa200.atdsrvnum,
                                    d_bdbsa200.atdsrvano,
                                    999999 )
           end if
           initialize d_bdbsa200.* , ws.*  to null
           display "Cod prestador eh 5"
           continue foreach
        end if

        ### VERIFICAR SE PRESTADOR E' PESSOA JURIDICA
        if d_bdbsa200.pestip is null then
           initialize d_bdbsa200.* , ws.*  to null
           display "Prestador com tipo de pessoa nulo"
           continue foreach
        end if
     end if

     #------------------------------------------------------------
     # VERIFICA SERVICO
     #------------------------------------------------------------
     ### VERIFICA SE SERVICO JA' EXISTE EM ANALISE
     select *
       from dbsmsrvacr
      where atdsrvnum = d_bdbsa200.atdsrvnum
        and atdsrvano = d_bdbsa200.atdsrvano

     if sqlca.sqlcode = 0 then
        initialize d_bdbsa200.* , ws.*  to null
        display "Servico ja esta em analise"
        continue foreach
     end if

     ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
     initialize ws.socopgnum to null
     open  c_dbsmopgitm using d_bdbsa200.atdsrvnum, d_bdbsa200.atdsrvano
     fetch c_dbsmopgitm into  ws.socopgnum
     close c_dbsmopgitm

     if ws.socopgnum is not null  then   # servico encontrado
        initialize d_bdbsa200.* , ws.*  to null
        display "Servico esta na OP: ", ws.socopgnum
        continue foreach
     end if

     ### VERIFICA SE SERVICO JA' EXISTE EM ANALISE
     select *
       from dbsmsrvacr
      where atdsrvnum = d_bdbsa200.atdsrvnum
        and atdsrvano = d_bdbsa200.atdsrvano

     if sqlca.sqlcode = 0 then
        display "Servixco em Analise: ", d_bdbsa200.atdsrvnum, "/", d_bdbsa200.atdsrvano
        initialize d_bdbsa200.* , ws.*  to null
        continue foreach
     end if

     ### VERIFICA ULTIMA ANALISE
     initialize ws.c24evtcod, ws.caddat, ws.c24fsecod  to null

     declare c_datmsrvanlhst cursor for
     select c24evtcod, caddat
       from datmsrvanlhst
      where atdsrvnum    = d_bdbsa200.atdsrvnum
        and atdsrvano    = d_bdbsa200.atdsrvano
        and c24evtcod    <> 0
        and srvanlhstseq =  1

     let ws.flganl = 0   # analise do servico
     let ws.vlr_bloqueio = 0.00

     foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

        select c24fsecod
          into ws.c24fsecod
          from datmsrvanlhst
         where atdsrvnum    = d_bdbsa200.atdsrvnum
           and atdsrvano    = d_bdbsa200.atdsrvano
           and c24evtcod    = ws.c24evtcod
           and srvanlhstseq = (select max(srvanlhstseq)
                                 from datmsrvanlhst
                                where atdsrvnum = d_bdbsa200.atdsrvnum
                                  and atdsrvano = d_bdbsa200.atdsrvano
                                  and c24evtcod = ws.c24evtcod)
        #PSI 198005 - inicio
        if ws.c24fsecod <> 2  and        # 2- ok analisado e pago
           ws.c24fsecod <> 4  then       # 4- nao procede
           if ws.flganl = 0 then
              let ws.flganl = 1
              let ws.c24evtcod_svl = ws.c24evtcod
              let ws.c24fsecod_svl = ws.c24fsecod
              let ws.caddat_svl    = ws.caddat
           else
              if ws.caddat > ws.caddat_svl then
                 let ws.c24evtcod_svl = ws.c24evtcod
                 let ws.c24fsecod_svl = ws.c24fsecod
                 let ws.caddat_svl    = ws.caddat
              end if
           end if
        else
           if ws.c24evtcod = 1 or ws.c24evtcod = 31 or ws.c24evtcod = 34 then
              let ws.vlr_bloqueio = 1.00
           end if
           display "Cod da fase do servico eh 2 ou 4"
           continue foreach
        end if
        #PSI 198005 - fim
     end foreach

     if ws.flganl = 0   then
        let d_bdbsa200.c24evtcod = 0
     else
        let d_bdbsa200.c24evtcod = ws.c24evtcod_svl
        let d_bdbsa200.c24fsecod = ws.c24fsecod_svl
     end if

     ### VERIFICA SIGLA  E COD.VEICULO ACIONADO
     initialize d_bdbsa200.atdvclsgl, ws.vclcoddig_acn to null
     open  c_datkveiculo using ws.socvclcod
     fetch c_datkveiculo into  d_bdbsa200.atdvclsgl, ws.vclcoddig_acn
     close c_datkveiculo

     whenever error continue

     #-----------------------------------------------
     # APURA VALOR DO SERVICO
     #-----------------------------------------------
     if d_bdbsa200.c24evtcod is null  or
        d_bdbsa200.c24evtcod = 0      then
        if ws.atdcstvlr is not null and
           ws.atdcstvlr <> 0        then
           let d_bdbsa200.socopgitmvlr = ws.atdcstvlr # valor acertado
        else
           #----------------------------------
           # Valor sugerido para o servico
           #----------------------------------
           call ctx15g00_vlrre(d_bdbsa200.atdsrvnum, d_bdbsa200.atdsrvano)
                     returning ws.socntzcod, ws.vlrsugerido,
                               ws.vlrmaximo, ws.vlrdiferenc,
                               ws.vlrmltdesc,ws.nrsrvs, ws.flgtab

           let d_bdbsa200.socopgitmvlr = ws.vlrsugerido
        end if

       if ws.vlr_bloqueio > 0 then
    	   let d_bdbsa200.socopgitmvlr = ws.vlr_bloqueio
       end if

       if ws.atdetpcod = 10 then
    	   let d_bdbsa200.socopgitmvlr = 0.01
        end if
     end if

     whenever error stop

     ### VERIFICA ENDERECO DO SERVICO
     let d_bdbsa200.local_ori = "NAO ENCONTRADO"
     initialize ws.lgdtip, ws.lgdnom, ws.lgdnum,
                ws.brrnom, ws.cidnom, ws.ufdcod to null
     open  c_datmlcl using d_bdbsa200.atdsrvnum, d_bdbsa200.atdsrvano
     fetch c_datmlcl into  ws.lgdtip, ws.lgdnom, ws.lgdnum,
                           ws.brrnom, ws.cidnom, ws.ufdcod

     if sqlca.sqlcode = 0 then
        let d_bdbsa200.local_ori = ws.lgdtip clipped," ",
                                   ws.lgdnom clipped," ",
                                   ws.lgdnum
     end if
     close c_datmlcl

     ### VERIFICA NOME NATUREZA SERVICO
     let d_bdbsa200.socntzdes = "NAO ENCONTRADO"
     open  c_datksocntz using ws.socntzcod
     fetch c_datksocntz into  d_bdbsa200.socntzdes
     close c_datksocntz

     if d_bdbsa200.c24evtcod is not null  and
        d_bdbsa200.c24evtcod <> 0         then
        let d_bdbsa200.quebra = d_bdbsa200.atdprscod + d_bdbsa200.ciaempcod
        output to report bdbsa200_rel( d_bdbsa200.* )
     else

        let d_bdbsa200.socopgitmvlr = d_bdbsa200.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

        insert into dbsmsrvacr ( atdsrvnum,
                                 atdsrvano,
                                 caddat,
                                 cadhor,
                                 pstcoddig,
                                 prsokaflg,
                                 prsokadat,
                                 prsokahor,
                                 anlokaflg,
                                 anlokadat,
                                 anlokahor,
                                 autokaflg,
                                 autokadat,
                                 autokahor,
                                 socsrvvlracrsit,
                                 socsrvprbcod,
                                 incvlr,
                                 fnlvlr )
                        values ( d_bdbsa200.atdsrvnum,
                                 d_bdbsa200.atdsrvano,
                                 today,
                                 current,
                                 d_bdbsa200.atdprscod,
                                 "N",
                                 today,
                                 current,
                                 "N",
                                 today,
                                 current,
                                 "N",
                                 today,
                                 current,
                                 "A",
                                 0,
                                 d_bdbsa200.socopgitmvlr,
                                 0 )

        if sqlca.sqlcode = 0 then
           #verifica se serviço possui bonificacao
           call ctc20m09_valor_bonificacao(d_bdbsa200.atdsrvnum,
                                          d_bdbsa200.atdsrvano)
                returning lr_ctc20m09.*

           #lr_ctc20m09.coderro = 0 --> Existe Bonificacao e está OK
           #lr_ctc20m09.coderro = 1 --> Existe Bonificacao porém teve alguma penalidade
           #lr_ctc20m09.coderro = 2 --> Nao Existe Bonificacao para servico

           display "Mensagem: ", lr_ctc20m09.msgerro clipped
           display "lr_ctc20m09.coderro: ", lr_ctc20m09.coderro
           display "Valor: ", lr_ctc20m09.pstprmvlr

           if lr_ctc20m09.coderro = 2 then
              display lr_ctc20m09.msgerro
           else
              if lr_ctc20m09.coderro = 0 then
                 if lr_ctc20m09.pstprmvlr = 0 then
                    let l_socadccstqtd  = 0
                 else
                    let l_socadccstqtd  = 1
                 end if
              else
                 let l_socadccstqtd  = 0
              end if

             display "Qtde: ", l_socadccstqtd

              whenever error continue
              insert into dbsmsrvcst(atdsrvnum,
                                     atdsrvano,
                                     soccstcod,
                                     socadccstvlr,
                                     socadccstqtd)
                     values(d_bdbsa200.atdsrvnum,
                            d_bdbsa200.atdsrvano,
                            23, ## PREMIO RE
                            lr_ctc20m09.pstprmvlr,
                            l_socadccstqtd)


              ## deu problema tenta mais uma vez e loga o que tentou gravar
              if sqlca.sqlcode <> 0 then

                 display "Servico ", d_bdbsa200.atdsrvnum, " - ", d_bdbsa200.atdsrvano
                 display "Valor ",  lr_ctc20m09.pstprmvlr
                 display "Quantidade",  lr_ctc20m09.pstprmvlr

                 insert into dbsmsrvcst(atdsrvnum,
                                        atdsrvano,
                                        soccstcod,
                                        socadccstvlr,
                                        socadccstqtd)
                        values(d_bdbsa200.atdsrvnum,
                               d_bdbsa200.atdsrvano,
                               23, ## PREMIO RE
                               lr_ctc20m09.pstprmvlr,
                               l_socadccstqtd)

                 if sqlca.sqlcode <> 0 then
                    display 'Erro Insert dbsmsrvcst: ', sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
                 end if
              end if
           end if

            select max(c24txtseq)
              into l_c24txtseq
              from datmservhist
             where atdsrvnum = d_bdbsa200.atdsrvnum
               and atdsrvano = d_bdbsa200.atdsrvano

            if l_c24txtseq > 0 then
               let l_c24txtseq = l_c24txtseq + 1
            else
               let l_c24txtseq = 1
            end if

            if lr_ctc20m09.pstprmvlr > 0 and l_socadccstqtd > 0 then
               let l_msgbonif = "Servico bonificado no valor de RS "
               let l_msgbonif = l_msgbonif clipped, lr_ctc20m09.pstprmvlr
            else
               let l_msgbonif = "Srv sem bonificacao. Motivo: "
               let l_msgbonif = l_msgbonif clipped, lr_ctc20m09.msgerro clipped
            end if

           insert into datmservhist(atdsrvnum
                                   ,c24txtseq
                                   ,atdsrvano
                                   ,c24funmat
                                   ,c24srvdsc
                                   ,ligdat
                                   ,lighorinc
                                   ,c24empcod
                                   ,c24usrtip)
                            values (d_bdbsa200.atdsrvnum
                                   ,l_c24txtseq
                                   ,d_bdbsa200.atdsrvano
                                   ,999999
                                   ,l_msgbonif
                                   ,today
                                   ,current
                                   ,1
                                   ,'F')

                    if sqlca.sqlcode <> 0 then
                       display "Erro insert datmservhist ", sqlca.sqlcode
                    end if

                 display "Resumo Bonificacao ", l_msgbonif clipped

           whenever error stop
        end if
     end if

     initialize d_bdbsa200.*, ws.*, l_socadccstqtd, lr_ctc20m09.* to null

  end foreach

  #--------------------------------------------------------------------
  # Cursor principal - Servicos ajustados pelos prestadores
  #--------------------------------------------------------------------

  #PSI 188220
  #------------------------------------------------------
  # Verifica se há algum cronograma na data
  #------------------------------------------------------
  whenever error continue
  select count(*)
  into ws_countfor
  from tbtemp_for
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode < 0 then
        display "Erro no SELECT da tabela tbtemp_for.",sqlca.sqlcode
               ,"/",sqlca.sqlerrd[2]
        exit program(1)
     end if
     if sqlca.sqlcode = 100 then
        let ws_countfor = 0
     end if
  end if

  if ws_countfor is null or
     ws_countfor = 0     then
      display "Nao ha prestadores com cronograma nesta data ", ws_fnldat
      exit program
  end if

  declare  c_srvact  cursor with hold for
     select datmservico.atdsrvnum  , datmservico.atdsrvano  ,
            datmservico.atdsrvorg  , datmservico.atddat     ,
            datmservico.atdhor     , datmservico.asitipcod  ,
            datmservico.atdprscod  , datmservico.srvprlflg  ,
            datmservico.cnldat     , datmservico.atdfnlhor  ,
            datmservico.vclcoddig  , datmservico.atdvclsgl  ,
            datmservico.pgtdat     , datmservico.socvclcod  ,
            datmservico.atdcstvlr  , datmservico.prslocflg  ,
            dbsmsrvacr.incvlr      , datmservico.ciaempcod
       from datmservico, dbsmsrvacr
      where datmservico.atddat between  ws_incdat  and  ws_fnldat
        and datmservico.atdsrvorg = 9
        and datmservico.atdsrvnum = dbsmsrvacr.atdsrvnum
        and datmservico.atdsrvano = dbsmsrvacr.atdsrvano
        and dbsmsrvacr.prsokaflg = "S"
        and dbsmsrvacr.anlokaflg = "S"

  foreach c_srvact into d_bdbsa200.atdsrvnum, d_bdbsa200.atdsrvano,
                        d_bdbsa200.atdsrvorg, d_bdbsa200.atddat   ,
                        d_bdbsa200.atdhor   , d_bdbsa200.asitipcod,
                        d_bdbsa200.atdprscod, ws.srvprlflg        ,
                        ws.cnldat           , ws.atdfnlhor        ,
                        d_bdbsa200.vclcoddig, d_bdbsa200.atdvclsgl,
                        ws.pgtdat           , ws.socvclcod        ,
                        ws.atdcstvlr        , ws.prslocflg        ,
                        d_bdbsa200.socopgitmvlr, d_bdbsa200.ciaempcod

     if d_bdbsa200.ciaempcod = 40 then
         display "Empresa 40"
         continue foreach
     end if

     ### VERIFICA SE PRESTADOR ESTA CONTIDO NA TABELA DE GERACAO
     select pstcoddig
       from tbtemp_for
      where pstcoddig =  d_bdbsa200.atdprscod

     if sqlca.sqlcode <> 0 then
        initialize d_bdbsa200.* , ws.*  to null
        display "Prestador nao esta contido na tabela de geracao"
        continue foreach
     end if

     #---- OSF-33677 - inicio ----#
     ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
     initialize ws.socopgnum to null
     open  c_dbsmopgitm using d_bdbsa200.atdsrvnum, d_bdbsa200.atdsrvano
     fetch c_dbsmopgitm into  ws.socopgnum
     close c_dbsmopgitm

     if ws.socopgnum is not null  then   # servico encontrado
        initialize d_bdbsa200.* , ws.*  to null
        display "Ja existe OP"
        continue foreach
     end if
     #---- OSF-33677 - fim ----#

     # ---------------------------------------------- #
     # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
     # ---------------------------------------------- #
     call ctb00g01_srvanl( d_bdbsa200.atdsrvnum
                          ,d_bdbsa200.atdsrvano
                          ,"N" )
         returning  ws.flganl
                   ,ws.c24evtcod
                   ,ws.c24fsecod

     if ws.flganl > 0 then
        initialize d_bdbsa200.* , ws.*  to null
        display "Servico com fase de analise"
        continue foreach
     end if

     let d_bdbsa200.quebra = d_bdbsa200.atdprscod + d_bdbsa200.ciaempcod
     output to report bdbsa200_rel( d_bdbsa200.* )

     display ""
     initialize d_bdbsa200.* , ws.*  to null

  end foreach

  finish report bdbsa200_rel

end function #  bdbsa200


#---------------------------------------------------------------------------
report bdbsa200_rel(r_bdbsa200)
#---------------------------------------------------------------------------

 define r_bdbsa200   record
    quebra           integer                     ,
    ciaempcod        like datmservico.ciaempcod  ,
    atdsrvnum        like datmservico.atdsrvnum  ,
    atdsrvano        like datmservico.atdsrvano  ,
    atdsrvorg        like datmservico.atdsrvorg  ,
    atddat           like datmservico.atddat     ,
    atdhor           like datmservico.atdhor     ,
    asitipcod        like datmservico.asitipcod  ,
    atdprscod        like datmservico.atdprscod  ,
    vclcoddig        like datmservico.vclcoddig  ,
    local_ori        char (50)                   ,
    atdvclsgl        like datmservico.atdvclsgl  ,
    maides           like dpaksocor.maides       ,
    crnpgtcod        like dpaksocor.crnpgtcod    ,
    c24evtcod        like datmsrvanlhst.c24evtcod,
    c24fsecod        like datmsrvanlhst.c24fsecod,
    soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum,
    socopgitmvlr     like dbsmopgitm.socopgitmvlr,
    pestip           like dpaksocor.pestip       ,
    soctrfcod        like dpaksocor.soctrfcod    ,
    socntzdes        like datksocntz.socntzdes
 end record

 define r_tempop     record
    socopgnum        decimal (8,0),
    socopgitmnum     decimal (4,0),
    socntzdes        char (30),
    atdsrvorg        smallint,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0),
    atddat           date ,
    atdhor           char (05),
    atdvclsgl        char (03),
    local_ori        char (50),
    portofx          decimal (2,0),
    portovlr         decimal (15,5),
    prestfx          decimal (2,0),
    prestvlr         decimal (15,5),
    adicivlr         decimal (15,5),
    kmexeqtd         decimal (15,5),
    kmexevlr         decimal (15,5),
    pedagvlr         decimal (15,5),
    matervlr         decimal (15,5),
    visitvlr         decimal (15,5),
    socopgitmvlr     decimal (15,5)
 end record

 define r_tempap     record
    atdsrvorg        smallint      ,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0) ,
    socntzdes        char (30)     ,
    atddat           date          ,
    atdhor           char (05)     ,
    atdvclsgl        char (03)     ,
    local_ori        char (50)     ,
    c24evtrdzdes     char (25)     ,
    c24fsedes        char (25)
 end record

 define ws           record
    socopgnum        like dbsmopg.socopgnum      ,
    segnumdig        like dbsmopg.segnumdig      ,
    corsus           like dbsmopg.corsus         ,
    socfatitmqtd     like dbsmopg.socfatitmqtd   ,
    socfattotvlr     like dbsmopg.socfattotvlr   ,
    empcod           like dbsmopg.empcod         ,
    cctcod           like dbsmopg.cctcod         ,
    cgccpfnum        like dbsmopg.cgccpfnum      ,
    cgcord           like dbsmopg.cgcord         ,
    cgccpfdig        like dbsmopg.cgccpfdig      ,
    succod           like dbsmopg.succod         ,
    socpgtdoctip     like dbsmopg.socpgtdoctip   ,
    pgtdstcod        like dbsmopg.pgtdstcod      ,
    socopgfavnom_fav like dbsmopgfav.socopgfavnom,
    socpgtopccod_fav like dbsmopgfav.socpgtopccod,
    pestip_fav       like dbsmopgfav.pestip      ,
    cgccpfnum_fav    like dbsmopgfav.cgccpfnum   ,
    cgcord_fav       like dbsmopgfav.cgcord      ,
    cgccpfdig_fav    like dbsmopgfav.cgccpfdig   ,
    bcoctatip_fav    like dbsmopgfav.bcoctatip   ,
    bcocod_fav       like dbsmopgfav.bcocod      ,
    bcoagnnum_fav    like dbsmopgfav.bcoagnnum   ,
    bcoagndig_fav    like dbsmopgfav.bcoagndig   ,
    bcoctanum_fav    like dbsmopgfav.bcoctanum   ,
    bcoctadig_fav    like dbsmopgfav.bcoctadig   ,
    socopgitmnum     like dbsmopgitm.socopgitmnum,
    c24evtrdzdes     like datkevt.c24evtrdzdes   ,
    c24fsedes        like datkfse.c24fsedes      ,
    transacao        decimal (1,0)               ,
    tempo             char (08)                  ,
    hora             char (05)                   ,
    nometxt          char (100)                  ,
    nometxtsv        char (20)                   ,
    rodar              char (500)                ,
    contador            integer                  ,
    soccstcod        like dbsmsrvcst.soccstcod   ,
    socadccstvlr     like dbsmsrvcst.socadccstvlr,
    socadccstqtd     like dbsmsrvcst.socadccstqtd,
    pestip           like dbsmopg.pestip         , #OSF-33677
    srvrmedifvlr      like dbsksrvrmeprc.srvrmedifvlr
 end record

 define ws_fase      integer

 define l_retorno    smallint  # PSI 185035
 define l_param      char(200) # PSI 185035
 define l_mensagem   char(050)
 define l_atdsrvnum	like dbscadtippgt.nrosrv
 define l_atdsrvano 	like dbscadtippgt.anosrv
 define l_pgttipcodps	like dbscadtippgt.pgttipcodps
 define l_empcod	like dbscadtippgt.empcod
 define l_succod	like dbscadtippgt.succod
 define l_cctcod	like dbscadtippgt.cctcod
 define l_data 		char(30)
 define m_atdsrvnum	like dbsmcctrat.atdsrvnum
 define m_atdsrvano 	like dbsmcctrat.atdsrvano

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 order by  r_bdbsa200.ciaempcod,
           r_bdbsa200.atdprscod,
           r_bdbsa200.quebra,
           r_bdbsa200.c24evtcod,
           r_bdbsa200.atdsrvnum,
           r_bdbsa200.atdsrvano


 format

    before group of r_bdbsa200.quebra    ### atdprscod
       delete from tbtemp_op
       delete from tbtemp_ap

       # definir empresa da OP, empresa do primeiro item
       if m_empcod is null or m_empcod != r_bdbsa200.ciaempcod
          then
          let m_empcod = r_bdbsa200.ciaempcod
       end if

       begin work
       let ws.transacao = 1
       if r_bdbsa200.c24evtcod is not null  and
          r_bdbsa200.c24evtcod <> 0         then
          let ws.socopgnum = 0
       else
          select max(socopgnum)
            into ws.socopgnum
            from dbsmopg
           where pstcoddig     =  r_bdbsa200.atdprscod
             and socopgsitcod  =  7

          select segnumdig   ,    corsus      ,    empcod      ,
                 cctcod      ,    cgccpfnum   ,    cgcord      ,
                 cgccpfdig   ,    succod      ,    socpgtdoctip,
                 pgtdstcod   ,    pestip                     #OSF-33677
            into ws.segnumdig   , ws.corsus      , ws.empcod      ,
                 ws.cctcod      , ws.cgccpfnum   , ws.cgcord      ,
                 ws.cgccpfdig   , ws.succod      , ws.socpgtdoctip,
                 ws.pgtdstcod   ,ws.pestip                   #OSF-33677
            from dbsmopg
           where socopgnum   = ws.socopgnum

          select socopgfavnom, socpgtopccod, pestip   ,
                 cgccpfnum   , cgcord      , cgccpfdig,
                 bcoctatip   , bcocod      , bcoagnnum,
                 bcoagndig   , bcoctanum   , bcoctadig
            into ws.socopgfavnom_fav, ws.socpgtopccod_fav, ws.pestip_fav   ,
                 ws.cgccpfnum_fav   , ws.cgcord_fav      , ws.cgccpfdig_fav,
                 ws.bcoctatip_fav   , ws.bcocod_fav      , ws.bcoagnnum_fav,
                 ws.bcoagndig_fav   , ws.bcoctanum_fav   , ws.bcoctadig_fav
            from dbsmopgfav
           where socopgnum   = ws.socopgnum

          select max(socopgnum)
               into ws.socopgnum
            from dbsmopg
           where socopgnum > 0

          if ws.socopgnum is null   then
             let ws.socopgnum = 0
          end if

          let ws.socopgnum    = ws.socopgnum + 1
          let ws.tempo         = time
          let ws.hora         = ws.tempo[1,5]
          let ws.socfatitmqtd = 0
          let ws.socfattotvlr = 0

          call ctd12g00_dados_pst(3, r_bdbsa200.atdprscod)
               returning m_res, m_msg, ws.succod

          whenever error continue

          # empresa da OP do primeiro item nao disponivel, assume a da OP anterior
          if m_empcod is null
             then
             let m_empcod = ws.empcod
          end if

          let ws.socfattotvlr = ws.socfattotvlr using "&&&&&&&&&&&&&&&.&&"

          insert into dbsmopg (socopgnum,
                               pstcoddig,
                               segnumdig,
                               corsus,
                               socfatentdat,
                               socfatpgtdat,
                               socfatitmqtd,
                               socfatrelqtd,
                               socfattotvlr,
                               empcod,
                               cctcod,
                               pestip,
                               cgccpfnum,
                               cgcord,
                               cgccpfdig,
                               socopgsitcod,
                               atldat,
                               funmat,
                               soctrfcod,
                               succod,
                               socpgtdoctip,
                               socemsnfsdat,
                               pgtdstcod,
                               socopgorgcod,
                               soctip)
                      values  (ws.socopgnum,
                               r_bdbsa200.atdprscod,
                               ws.segnumdig        ,
                               ws.corsus           ,
                               ws_socfatentdat     ,
                               ws_socfatpgtdat     ,
                               ws.socfatitmqtd     ,   # qtd.itens
                               null                ,   # qtd.relatorio
                               ws.socfattotvlr     ,   # vlr total
                               m_empcod            ,
                               ws.cctcod           ,
                               ws.pestip           ,   # OSF-33677
                               ws.cgccpfnum        ,
                               ws.cgcord           ,
                               ws.cgccpfdig        ,
                               9                   ,   # automatica OK!
                               today               ,
                               999999              ,   # matricula
                               r_bdbsa200.soctrfcod,
                               ws.succod           ,
                               ws.socpgtdoctip     ,
                               ws_socfatpgtdat     ,
                               ws.pgtdstcod        ,
                               2                   ,   # geracao automatica
                               3                   )   # tipo OP = 3-RE

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPG!"
             rollback work
             exit program (1)
          end if

          insert into dbsmopgfav (socopgnum,
                                  socopgfavnom,
                                  socpgtopccod,
                                  pestip,
                                  cgccpfnum,
                                  cgcord,
                                  cgccpfdig,
                                  bcoctatip,
                                  bcocod,
                                  bcoagnnum,
                                  bcoagndig,
                                  bcoctanum,
                                  bcoctadig)
                         values  (ws.socopgnum,
                                  ws.socopgfavnom_fav,
                                  ws.socpgtopccod_fav,
                                  ws.pestip_fav,
                                  ws.cgccpfnum_fav,
                                  ws.cgcord_fav,
                                  ws.cgccpfdig_fav,
                                  ws.bcoctatip_fav,
                                  ws.bcocod_fav,
                                  ws.bcoagnnum_fav,
                                  ws.bcoagndig_fav,
                                  ws.bcoctanum_fav,
                                  ws.bcoctadig_fav)

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGFAV!"
             rollback work
             exit program (1)
          end if

          # PSI 211074 - BURINI
          call cts50g00_insere_etapa_auto(ws.socopgnum,999999)
               returning l_retorno,
                         l_mensagem

          if l_retorno  <>  1   then
             display l_mensagem
             rollback work
             exit program (1)
          end if

          #for ws_fase = 1 to 3
          #   insert into dbsmopgfas (socopgnum,
          #                           socopgfascod,
          #                           socopgfasdat,
          #                           socopgfashor,
          #                           funmat)
          #                  values  (ws.socopgnum,
          #                           ws_fase,     # protoc./analise/digit.
          #                           today,
          #                           ws.hora,
          #                           999999         )
          #
          #   if sqlca.sqlcode  <>  0   then
          #      display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGFAS!"
          #      rollback work
          #      exit program (1)
          #   end if
          #end for

       end if
       whenever error stop


    after group of r_bdbsa200.quebra    ### atdprscod
       if ws.socopgnum is not null and
          ws.socopgnum <> 0        then
          update dbsmopg set (socfatitmqtd, socfattotvlr )
                          =  (ws.socfatitmqtd, ws.socfattotvlr )
                 where  socopgnum = ws.socopgnum
       end if

       commit work
       let ws.transacao = 0
       let m_opgems = m_opgems + 1

       whenever error continue

       ### Verifica e envia conteudo tabela temporaria - OP
       let ws.nometxt   = m_path clipped,"/OPRE", r_bdbsa200.atdprscod using "&&&&&&" , ".txt" # PSI 185035
       let ws.nometxtsv = m_path clipped,"/OPRE", r_bdbsa200.atdprscod using "&&&&&&" , ".txt"
       select count(*)
         into ws.contador
         from tbtemp_op

       if ws.contador is not null and
          ws.contador > 0         then
          declare c_tempop cursor for
           select * from tbtemp_op
            order by socopgitmnum

          let l_data = current
          display "Iniciou criacao de OP: ", l_data

          display 'ws.nometxt: ', ws.nometxt

          start report rel_tempop to ws.nometxt

          output to report rel_tempop( 1, r_tempop.* )

          foreach c_tempop into  r_tempop.*
             output to report rel_tempop( 2, r_tempop.* )
          end foreach

          finish report rel_tempop
          let l_data = current
          display "Finalizou criacao de OP: ", l_data
       else
          initialize ws.rodar  to null
          let ws.rodar = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                       " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                        ws.nometxt clipped
          run ws.rodar
       end if

       # PSI 185035 - Inicio
       let l_param = "OP RE WEB PRESTADOR ",r_bdbsa200.atdprscod using '#&&&&&'," de ",ws_socfatentdat
       let l_retorno = ctx22g00_envia_email("BDBSA200",
                                            l_param,
                                            ws.nometxt)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao enviar email(ctx22g00) - ",ws.nometxt
          else
             display "Nao ha email cadastrado para o modulo - BDBSA200 "
          end if
       end if
       # PSI 185035 - Final

       #------------------------------------------------------------------
       # E-MAIL PRESTADOR
       #------------------------------------------------------------------
       #let ws.rodar =  "uuencode ",ws.nometxt clipped," ",ws.nometxt clipped,
       #              " | mailx -s 'OP-PRESTADOR ",
       #              r_bdbsa200.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              r_bdbsa200.maides clipped
       #run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "oriente_eduardo/spaulo_psocorro_controles@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "noberto_marcelo/spaulo_psocorro_qualidade@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "paiva_ricardo/spaulo_psocorro_controles@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "veiga_jefferson/spaulo_psocorro_qualidade@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "silva_joseaparecido/spaulo_psocorro_qualidade@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "jahchan_raji/spaulo_info_sistemas@u55 < ",
       #             ws.nometxt clipped
       #run ws.rodar

       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------
       #WWWX  let ws.rodar =  "cp ", ws.nometxt clipped,
       #WWWX                 " /adat/",ws.nometxtsv clipped
       #WWWX  run ws.rodar
       #WWWX  let ws.rodar =  "rm ", ws.nometxt clipped
       #WWWX  run ws.run

       ### Verifica conteudo temporaria - AP
       let ws.nometxt   = m_path clipped,"/APRE", r_bdbsa200.atdprscod using "&&&&&&" , ".txt" # PSI 185035
       let ws.nometxtsv = m_path clipped,"/APRE", r_bdbsa200.atdprscod using "&&&&&&" , ".txt" # PSI 185035
       select count(*)
         into ws.contador
         from tbtemp_ap

       if ws.contador is not null and
          ws.contador > 0         then
          declare c_tempap cursor for
           select * from tbtemp_ap
            order by atdsrvnum

          let l_data = current
          display "Iniciou envio de OP para Prestador: ", l_data

          start report rel_tempap to ws.nometxt

          output to report rel_tempap( 1, r_tempap.* )

          foreach c_tempap into  r_tempap.*
             output to report rel_tempap( 2, r_tempap.* )
          end foreach

          finish report rel_tempap
          let l_data = current
          display "Finalizou envio de OP para Prestador: ", l_data
       else
          initialize ws.rodar  to null
          let ws.rodar = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                       " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                        ws.nometxt clipped
          run ws.rodar
       end if

       # PSI 185035 - Inicio
       let l_param = "AP RE WEB PRESTADOR ",r_bdbsa200.atdprscod using '#&&&&&'," de ",ws_socfatentdat
       let l_retorno = ctx22g00_envia_email("BDBSA200",
                                            l_param,
                                            ws.nometxt)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao enviar email(ctx22g00) - ",ws.nometxt
          else
             display "Nao ha email cadastrado para o modulo BDBSA200 "
          end if
       end if
       # PSI 185035 - Final

       #------------------------------------------------------------------
       # E-MAIL PRESTADOR
       #------------------------------------------------------------------
       # let ws.rodar =  "uuencode ",ws.nometxt clipped," ",ws.nometxt clipped,
       #               " | mailx -s 'AP-PRESTADOR ",
       #               r_bdbsa200.atdprscod using "#&&&&&",
       #               " de ",ws_socfatentdat, "' ",
       #               r_bdbsa200.maides clipped
       # run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "oriente_eduardo/spaulo_psocorro_controles@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "noberto_marcelo/spaulo_psocorro_qualidade@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "paiva_ricardo/spaulo_psocorro_controles@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "veiga_jefferson/spaulo_psocorro_qualidade@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "silva_joseaparecido/spaulo_psocorro_qualidade@u23 < ",
       #             ws.nometxt clipped
       #raji run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa200.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "jahchan_raji/spaulo_info_sistemas@u55 < ",
       #             ws.nometxt clipped
       #run ws.rodar

       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------
       #WWWX  let ws.rodar =  "cp ", ws.nometxt clipped,
       #WWWX                 " /adat/",ws.nometxtsv clipped
       #WWWX  run ws.rodar
       #WWWX  let ws.rodar =  "rm ", ws.nometxt clipped
       #WWWX  run ws.rodar

       whenever error stop


    on every row
       if r_bdbsa200.c24fsecod is not null and
          r_bdbsa200.c24fsecod <> 2        and
          r_bdbsa200.c24fsecod <> 4  then

          initialize ws.c24evtrdzdes to null
          open  c_datkevt using r_bdbsa200.c24evtcod
          fetch c_datkevt into  ws.c24evtrdzdes
          close c_datkevt

          initialize ws.c24fsedes to null
          open  c_datkfse using r_bdbsa200.c24fsecod
          fetch c_datkfse into  ws.c24fsedes
          close c_datkfse

          insert into tbtemp_ap
                         values ( r_bdbsa200.atdsrvorg,
                                  r_bdbsa200.atdsrvnum,
                                  r_bdbsa200.atdsrvano,
                                  r_bdbsa200.socntzdes,
                                  r_bdbsa200.atddat,
                                  r_bdbsa200.atdhor,
                                  r_bdbsa200.atdvclsgl,
                                  r_bdbsa200.local_ori,
                                  ws.c24evtrdzdes,
                                  ws.c24fsedes)

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela TEMPORARIA OK!"
             rollback work
             exit program (1)
          end if

       else
          select max(socopgitmnum)
            into ws.socopgitmnum
            from dbsmopgitm
           where socopgnum = ws.socopgnum

          if ws.socopgitmnum   is null   then
             let ws.socopgitmnum = 0
          end if
          let ws.socopgitmnum = ws.socopgitmnum + 1

          if r_bdbsa200.socopgitmvlr is null then     #OSF-33677
             let r_bdbsa200.socopgitmvlr = 00.00
          end if

          let r_bdbsa200.socopgitmvlr = r_bdbsa200.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

          display "--------------------------"
          display "dbsmopgitm"
          display "socopgnum: ", ws.socopgnum
          display "socopgitmnum: ", ws.socopgitmnum
          display "atdsrvnum: ", r_bdbsa200.atdsrvnum
          display "atdsrvano: ", r_bdbsa200.atdsrvano
          display "--------------------------"

          insert into dbsmopgitm (socopgnum,
                                  socopgitmnum,
                                  atdsrvnum,
                                  atdsrvano,
                                  socopgitmvlr,
                                  vlrfxacod,
                                  funmat,
                                  socconlibflg)
                          values (ws.socopgnum,
                                  ws.socopgitmnum,
                                  r_bdbsa200.atdsrvnum,
                                  r_bdbsa200.atdsrvano,
                                  r_bdbsa200.socopgitmvlr,
                                  2 ,
                                  999999,
                                  "N" )

          let ws.socfattotvlr = ws.socfattotvlr + r_bdbsa200.socopgitmvlr

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGITM!"
             rollback work
             exit program (1)
          end if

          declare c_dbsmsrvcst cursor for
             select soccstcod,
                    socadccstvlr,
                    socadccstqtd
               from dbsmsrvcst
              where atdsrvnum = r_bdbsa200.atdsrvnum
                and atdsrvano = r_bdbsa200.atdsrvano

          foreach c_dbsmsrvcst into ws.soccstcod,
                                    ws.socadccstvlr,
                                    ws.socadccstqtd

             let ws.socadccstvlr = ws.socadccstvlr using "&&&&&&&&&&&&&&&.&&"
             let ws.socadccstqtd = ws.socadccstqtd using "&&&&&&&&"


             display "--------------------------"
             display "dbsmopgcst"
             display "socopgnum: ", ws.socopgnum
             display "socopgitmnum: ", ws.socopgitmnum
             display "atdsrvnum: ", r_bdbsa200.atdsrvnum
             display "atdsrvano: ", r_bdbsa200.atdsrvano
             display "--------------------------"

             insert into dbsmopgcst (socopgnum,
                                     socopgitmnum,
                                     atdsrvnum,
                                     atdsrvano,
                                     soccstcod,
                                     socopgitmcst,
                                     cstqtd)
                             values (ws.socopgnum,
                                     ws.socopgitmnum,
                                     r_bdbsa200.atdsrvnum,
                                     r_bdbsa200.atdsrvano,
                                     ws.soccstcod,
                                     ws.socadccstvlr,
                                     ws.socadccstqtd )

             let ws.socfattotvlr = ws.socfattotvlr + ws.socadccstvlr

             if sqlca.sqlcode  <>  0   then
                display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGCST!"
                display "Erro: ", r_bdbsa200.atdsrvnum, "/",r_bdbsa200.atdsrvano
                rollback work
                exit program (1)
             end if

          end foreach

          let ws.socfatitmqtd = ws.socfatitmqtd + 1
          open cbdbsa200021 using r_bdbsa200.atdsrvnum,
               			r_bdbsa200.atdsrvano
          fetch  cbdbsa200021 into l_atdsrvnum,
          			l_atdsrvano,
          			l_pgttipcodps,
          			l_empcod,
          			l_succod,
          			l_cctcod
          close cbdbsa200021

          if l_pgttipcodps = 3 then
             let m_atdsrvnum = null
             let m_atdsrvano = null
             whenever error continue
             open cbdbsa200022 using l_atdsrvnum, l_atdsrvano
             fetch  cbdbsa200022 into m_atdsrvnum, m_atdsrvano
             whenever error stop

             if sqlca.sqlcode <> 0 then
          			   display "Erro selecao dbsmcctrat"
             end if

             if m_atdsrvnum is null or m_atdsrvnum = 0 then
                whenever error continue

                let r_bdbsa200.socopgitmvlr = r_bdbsa200.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

                insert into dbsmcctrat values (r_bdbsa200.atdsrvnum,
                                               r_bdbsa200.atdsrvano,
                                               l_empcod,
                                               l_succod,
                                               l_cctcod,
                                               r_bdbsa200.socopgitmvlr)
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMCCTRAT"
                   rollback work
                   exit program (1)
                end if
             end if
          end if

          whenever error continue

          let r_bdbsa200.socopgitmvlr = r_bdbsa200.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

          insert into tbtemp_op
                         values ( ws.socopgnum,
                                  ws.socopgitmnum,
                                  r_bdbsa200.socntzdes,
                                  r_bdbsa200.atdsrvorg,
                                  r_bdbsa200.atdsrvnum,
                                  r_bdbsa200.atdsrvano,
                                  r_bdbsa200.atddat,
                                  r_bdbsa200.atdhor,
                                  r_bdbsa200.atdvclsgl,
                                  r_bdbsa200.local_ori,
                                  0,
                                  r_bdbsa200.socopgitmvlr,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  r_bdbsa200.socopgitmvlr)

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela TEMPORARIA OK!"
             rollback work
             exit program (1)
          end if
       end if
       whenever error stop

    on last row
       if ws.transacao = 1 then
          commit work
          let m_opgems = m_opgems + 1
       end if

end report    ###  bdbsa200_rel


#---------------------------------------------------------------------------
 report rel_tempop( ws_flgcab, r_tempop)
#---------------------------------------------------------------------------

 define ws_flgcab    smallint

 define r_tempop     record
    socopgnum        decimal (8,0),
    socopgitmnum     decimal (4,0),
    socntzdes        char (30),
    atdsrvorg        smallint,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0),
    atddat           date ,
    atdhor           char (05),
    atdvclsgl        char (03),
    local_ori        char (50),
    portofx          decimal (2,0),
    portovlr         decimal (15,5),
    prestfx          decimal (2,0),
    prestvlr         decimal (15,5),
    adicivlr         decimal (15,5),
    kmexeqtd         decimal (15,5),
    kmexevlr         decimal (15,5),
    pedagvlr         decimal (15,5),
    matervlr         decimal (15,5),
    visitvlr         decimal (15,5),
    socopgitmvlr     decimal (15,5)
 end record

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
        if ws_flgcab = 1 then
           print column 001, "Nro_OP|Item_OP|Natureza|Origem|Nro_Servico|",
                             "Ano_Servico|Data|Hora|Viatura|Endereco|Fx_Porto|",
                             "Vlr_Porto|Fx_Prestador|Vlr_Prestador|Adicionais|",
                             "Km_Exced|Vlr_Exced|Pedagio|Materiais|Visita|",
                             "Vlr_Total|",
                             ascii(13)
        else
           print column 001, r_tempop.socopgnum     using "<<<<<<<#", "|",
                             r_tempop.socopgitmnum  using "<<<#",     "|",
                             r_tempop.socntzdes     clipped,          "|",
                             r_tempop.atdsrvorg     using "&&",       "|",
                             r_tempop.atdsrvnum     using "&&&&&&&",  "|",
                             r_tempop.atdsrvano     using "&&",       "|",
                             r_tempop.atddat,                         "|",
                             r_tempop.atdhor,                         "|",
                             r_tempop.atdvclsgl     clipped,          "|",
                             r_tempop.local_ori     clipped,          "|",
                                                                      "|",
                             r_tempop.socopgitmvlr  using "######.##","|",
                             "||||||||",
                             r_tempop.socopgitmvlr  using "######.##","|",
                             ascii(13)
        end if

 end report    ### rel_tempop


#---------------------------------------------------------------------------
 report rel_tempap(ws_flgcab, r_tempap)
#---------------------------------------------------------------------------

 define ws_flgcab    smallint

 define r_tempap     record
    atdsrvorg        smallint      ,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0),
    socntzdes        char (30)    ,
    atddat           date         ,
    atdhor           char (05)    ,
    atdvclsgl        char (03)    ,
    local_ori        char (50)    ,
    c24evtrdzdes     char (25)    ,
    c24fsedes        char (25)
 end record

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
        if ws_flgcab = 1 then
           print column 001, "|Origem|Nro_Servico|Ano_Servico|Natureza|Data|",
                             "Hora|Viatura|Endereco|Evento|Fase|",
                             ascii(13)
        else
           print column 001, r_tempap.atdsrvorg      using "&&",       "|",
                             r_tempap.atdsrvnum      using "&&&&&&&",  "|",
                             r_tempap.atdsrvano      using "&&",       "|",
                             r_tempap.socntzdes      clipped,          "|",
                             r_tempap.atddat,                          "|",
                             r_tempap.atdhor,                          "|",
                             r_tempap.atdvclsgl      clipped,          "|",
                             r_tempap.local_ori      clipped,          "|",
                             r_tempap.c24evtrdzdes,                    "|",
                             r_tempap.c24fsedes,                       "|",
                             ascii(13)
        end if

 end report    ### rel_tempap

