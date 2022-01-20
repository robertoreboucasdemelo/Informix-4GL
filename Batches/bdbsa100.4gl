#############################################################################
# Nome do Modulo: BDBSA100                                         Wagner   #
#                                                                           #
# Cria OP e envia (via e-mail) aos prestadores - RE                Jan/2002 #
#############################################################################
#                                                                           #
#                          * * *  ALTERACOES  * * *                         #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 16/07/2002  PSI 15620-5  Wagner       Adaptacao funcao de pesquisa precos #
#                                       para servicos RE.                   #
#---------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Aumentar pesquisa para 180dias ant. #
#---------------------------------------------------------------------------#
# Data        Autor Fabrica    Alteracao                           PSI      #
# 17/06/2003  Alexandre Farias Data inicial do proces. de serviços 174904   #
#                                                                           #
# 17/03/2004  Marcio Hashiguti Habilitar a geracao de OPs de       183946   #
#                              servicos RE c/ acertos de val.               #
#                              efetuados pelo Portal de negocios            #
#                              - Prestador On-Line - OSF-33677              #
#                                                                           #
# 02/04/2004 Paula Romanini    Inibir a linha 'let ws_incdat = "01/10/2002"'#
# CT197181                                                                  #
#                                                                           #
# 02/04/2004  Cesar Lucca      O programa passa comparar o conteudo do      #
#             CT197475         campo Outras Cias (ws.outciatxt) com as      #
#                              constantes "Internet Auto" e "Internet Auto  #
#                              e RE", sendo que ele vai inicializar as      #
#                              variaveis com nulo e passar para o proximo   #
#                              registro caso a comparacao seja igual a uma  #
#                              das constantes.                              #
#                                                                           #
# Adriana CT:197475           Alteracao m_run para char(30)                 #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# 03/12/2004 Helio (Meta)      PSI188220  Alteracoes diversas               #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                        #
#                                                                           #
# Data       Autor Fabrica         PSI    Alteracoes                        #
# ---------- --------------------- ------ ----------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco#
#...........................................................................#
# 26/12/2005 Cristiane Silva              Alterar de 180 para 365 dias a    #
#                                         pesquisa de servicos              #
#...........................................................................#
# 07/03/2006 Cristiane e Lucas PSI198005  Enviar ao Portal de Negócios      #
#                                         servicos com eventos 1, 31 e 34   #
#...........................................................................#
# 27/06/2006 Priscila          PSI197858  Adaptar programa para versao 4gc  #
#                                         devido ao envio de SMS (geramq)   #
#...........................................................................#
# 14/02/2007 Fabiano, Meta     AS 130087   Migracao para a versao 7.32      #
#...........................................................................#
# 25/07/2007 Cristiane Silva   PSI207233  Serviços com débito em ccusto.    #
#...........................................................................#
# 08/08/2007 Sergio Burini    PSI 211001  Inclusão de Adicional Noturno,    #
#                                         Feriado e Domingo                 #
# 20/09/2007 Ligia Mattge     PSI 211982  Desprezar servicos da Portoseg (40)
# 30/06/2009 Fabio Costa      PSI 198404  Sucursal do prestador na OP       #
# 31/05/2010 Fabio Costa       CT 782696  Gravar empresa do item na OP      #
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                        de mais de duas casas decimais.    #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define ws_incdat       date
define ws_fnldat       date
define ws_socfatentdat date
define ws_socfatpgtdat date
define ws_entrega      date
define ws_crnpgtcod    decimal(2,0)
define ws_countfor     smallint
define ws_flgdiabom    smallint
define m_run           char(30)  #CT 197475

define m_path          char(100) # PSI 185035

define m_res           smallint,
       m_msg           char(70),
       m_empcod        like dbsmopg.empcod

main

   call fun_dba_abre_banco("CT24HS")

   initialize ws_incdat      , ws_fnldat      , ws_socfatentdat,
              ws_socfatpgtdat, ws_entrega     , ws_crnpgtcod   ,
              ws_countfor    , ws_flgdiabom   , m_run          ,
              m_path         , m_res          , m_msg          ,
              m_empcod  to null

   set isolation to dirty read

   # PSI 185035 - Inicio
   let m_path = f_path("DBS","LOG")

   if m_path is null then
      let m_path = "."
   end if

   let m_path = m_path clipped,"/bdbsa100.log"

   call startlog(m_path)
   # PSI 185035 - Final

   call bdbsa100()

end main

#---------------------------------------------------------------
function bdbsa100()
#---------------------------------------------------------------

  define d_bdbsa100   record
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
     socntzdes        like datksocntz.socntzdes   ,
     quebra           integer
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
     vlr_bloqueio     decimal(2,0),
     ciaempcod        like datmservico.ciaempcod,
     opsrvdias        smallint
  end record

  define l_c24fsecod    like datmsrvanlhst.c24fsecod

  define m_outciatxt         like dpaksocor.outciatxt

  define l_arq      char(30)

  #--------------------------------------------------------------------
  # Inicializacao das variaveis
  #--------------------------------------------------------------------

  let	l_c24fsecod  =  null
  let	m_outciatxt  =  null
  let	l_arq  =  null

  initialize d_bdbsa100.*  to null
  initialize ws.*          to null
  let l_c24fsecod = null

  let m_res = null
  let m_msg = null

  #--------------------------------------------------------------------
  # Preparando SQL PRESTADOR
  #--------------------------------------------------------------------
  let ws.comando  = "select maides,crnpgtcod,pestip,soctrfcod,qldgracod ",
                    " ,outciatxt ",                      #OSF-33677
                    "  from dpaksocor     ",
                    " where pstcoddig = ? "
  prepare pbdbsa100001 from ws.comando
  declare cbdbsa100001 cursor for pbdbsa100001

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
  ### prepare pbdbsa100002 from ws.comando
  ### declare cbdbsa100002 cursor for pbdbsa100002

  #--------------------------------------------------------------------
  # Preparando SQL ITENS OP
  #--------------------------------------------------------------------
  let ws.comando  = "select dbsmopg.socopgnum     ",
                    "  from dbsmopgitm, dbsmopg    ",
                    " where dbsmopgitm.atdsrvnum = ? ",
                    "   and dbsmopgitm.atdsrvano = ? ",
                    "   and dbsmopg.socopgnum    = dbsmopgitm.socopgnum ",
                    "   and dbsmopg.socopgsitcod <> 8 "
  prepare pbdbsa100003 from ws.comando
  declare cbdbsa100003 cursor for pbdbsa100003

  #--------------------------------------------------------------------
  # Preparando SQL EVENTO DE ANALISE
  #--------------------------------------------------------------------
  let ws.comando  = "select c24evtrdzdes    ",
                    "  from datkevt         ",
                    " where c24evtcod  =  ? "
  prepare pbdbsa100004 from ws.comando
  declare cbdbsa100004 cursor for pbdbsa100004

  #--------------------------------------------------------------------
  # Preparando SQL FASE DE ANALISE
  #--------------------------------------------------------------------
  let ws.comando  = "select c24fsedes     ",
                    "  from datkfse       ",
                    " where c24fsecod = ? "
  prepare pbdbsa100005 from ws.comando
  declare cbdbsa100005 cursor for pbdbsa100005

  #--------------------------------------------------------------------
  # Preparando SQL SIGLA VEICULO
  #--------------------------------------------------------------------
  let ws.comando  = "select atdvclsgl, vclcoddig ",
                    "  from datkveiculo   ",
                    " where socvclcod = ? "
  prepare pbdbsa100006 from ws.comando
  declare cbdbsa100006 cursor for pbdbsa100006

  #--------------------------------------------------------------------
  # Preparando SQL para local origem RE
  #--------------------------------------------------------------------
  let ws.comando  = "select lgdtip, lgdnom, lgdnum, ",
                    "       brrnom, cidnom, ufdcod  ",
                    "  from datmlcl                 ",
                    " where datmlcl.atdsrvnum = ?   ",
                    "   and datmlcl.atdsrvano = ?   ",
                    "   and datmlcl.c24endtip = 1   "
  prepare pbdbsa100007 from ws.comando
  declare cbdbsa100007 cursor for pbdbsa100007

  #--------------------------------------------------------------------
  # Preparando SQL para natureza RE
  #--------------------------------------------------------------------
  let ws.comando  = "select socntzdes ",
                    "  from datksocntz ",
                    " where socntzcod = ? "
  prepare pbdbsa100008 from ws.comando
  declare cbdbsa100008 cursor for pbdbsa100008

  #--------------------------------------------------------------------
  # Preparando SQL para verificar se novo (RET)orno
  #--------------------------------------------------------------------
  let ws.comando  = "select datmligacao.c24astcod ",
                    "  from datmligacao ",
                    " where datmligacao.atdsrvnum = ? ",
                    "   and datmligacao.atdsrvano = ? ",
                    "   and datmligacao.lignum <> 0  "
  prepare pbdbsa100009 from ws.comando
  declare cbdbsa100009 cursor for pbdbsa100009

  let ws.comando = "select pstcoddig             ",
                   "  from dpaksocor             ",
                   " where crnpgtcod = ?         "
  prepare pbdbsa100010 from ws.comando
  declare cbdbsa100010 cursor for pbdbsa100010

  let ws.comando = " select c24fsecod ",
                     " from datmsrvanlhst ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? ",
                      " and c24evtcod = ? ",
                      " and srvanlhstseq = 1 "
  prepare pbdbsa100011 from ws.comando
  declare cbdbsa100011 cursor for pbdbsa100011

  let ws.comando = " select nrosrv, anosrv, pgttipcodps, empcod, succod, cctcod ",
               " from dbscadtippgt ",
              " where nrosrv = ? ",
                " and anosrv = ? "
  prepare pbdbsa100021 from ws.comando
  declare cbdbsa100021 cursor for pbdbsa100021

  let ws.comando = " select atdsrvnum, atdsrvano, cctcod ",
             " from dbsmcctrat ",
             " where atdsrvnum = ? ",
             " and atdsrvano = ? "
  prepare pbdbsa100022 from ws.comando
  declare cbdbsa100022 cursor for pbdbsa100022

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


  #--------------------------------------------------------------------
  # Deficao das datas parametro
  #--------------------------------------------------------------------
  let ws.auxdat = arg_val(1)

  if ws.auxdat is null       or
     ws.auxdat =  "  "       then
     let ws.auxdat = today
  else
     if ws.auxdat > today       or
        length(ws.auxdat) < 10  then
        display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
        exit program
     end if
  end if

 select grlinf into ws.opsrvdias
   from datkgeral
  where grlchv = "PSOOPSRVDIAS"
 if sqlca.sqlcode <> 0 then
    let ws.opsrvdias = 180
 end if

 let ws_fnldat       = ws.auxdat
 let ws_incdat       = ws_fnldat - ws.opsrvdias units day

 display " Busca servicos a partir de ", ws_incdat, " (", ws.opsrvdias using "<<<&", " dias)"

 display " DATA DE PROCESSAMENTO = ",ws_fnldat

  #------------------------------------------------------
  # Pesquisa todos os codigos de cronograma em funcao da data
  #------------------------------------------------------
  declare cbdbsa100012 cursor for
   select dbsmcrnpgtetg.crnpgtcod
     from dbsmcrnpgtetg
    where dbsmcrnpgtetg.crnpgtetgdat = ws_fnldat

  foreach cbdbsa100012 into ws_crnpgtcod
     display "Cronograma = ",ws_crnpgtcod
     open cbdbsa100010 using ws_crnpgtcod
     foreach cbdbsa100010 into ws.pstcoddig
        insert into tbtemp_for values (ws.pstcoddig)
     end foreach
  end foreach

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
               ,sqlca.sqlerrd[2]
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

  let ws_socfatentdat = ws_fnldat  # DATA ENTREGA DO PRESTADOR

  let ws_socfatpgtdat = dias_uteis(ws_socfatentdat, 7, "", "S", "S") #PSI 188220

  let m_path = f_path("DBS","ARQUIVO")
  if m_path is null then
     let m_path = "."
  end if

  let l_arq = m_path clipped ,"/bdbsa100.txt"

  #--------------------------------------------------------------------
  # Cursor principal - Servicos executados por prestadores
  #--------------------------------------------------------------------
  #let ws_incdat = "01/10/2002"    #--> a pedido da PSI:174904

  declare  cbdbsa100013  cursor with hold for
     select datmservico.atdsrvnum  , datmservico.atdsrvano  ,
            datmservico.atdsrvorg  , datmservico.atddat     ,
            datmservico.atdhor     , datmservico.asitipcod  ,
            datmservico.atdprscod  , datmservico.srvprlflg  ,
            datmservico.cnldat     , datmservico.atdfnlhor  ,
            datmservico.vclcoddig  , datmservico.atdvclsgl  ,
            datmservico.pgtdat     , datmservico.socvclcod  ,
            datmservico.atdcstvlr  , datmservico.prslocflg  ,
            datmservico.ciaempcod  , datmservico.atdetpcod
       from datmservico
      where datmservico.atddat between  ws_incdat  and  ws_fnldat
        and datmservico.atdsrvorg in ( 9 )
        and pgtdat is null
        and datmservico.atdetpcod in (3, 10)


  #PSI 197858 - bdbsa081 agora deve ser executado como 4gc (devido as funcoes
  # que enviam SMS necessitarem do MQ) so que 4gc nao aceita que o report nao
  # tenha destino, entao foi criado o l_arq que ira criar um report vazio
  start report bdbsa100_rel to l_arq

  foreach cbdbsa100013 into d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano,
                            d_bdbsa100.atdsrvorg, d_bdbsa100.atddat   ,
                            d_bdbsa100.atdhor   , d_bdbsa100.asitipcod,
                            d_bdbsa100.atdprscod, ws.srvprlflg        ,
                            ws.cnldat           , ws.atdfnlhor        ,
                            d_bdbsa100.vclcoddig, d_bdbsa100.atdvclsgl,
                            ws.pgtdat           , ws.socvclcod        ,
                            ws.atdcstvlr        , ws.prslocflg,
                            ws.ciaempcod        , ws.atdetpcod

     if ws.ciaempcod = 40 then
        continue foreach
     end if

     let d_bdbsa100.c24evtcod = 0

     ### A ETAPA FOI INCLUIDA NO SELECT PRINCIPAL (DATMSERVICO)
     ### #------------------------------------------------------------
     ### # VERIFICA ETAPA DO SERVICO
     ### #------------------------------------------------------------
     ### open  cbdbsa100002 using d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano,
     ###                          d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano
     ### fetch cbdbsa100002 into  ws.atdetpcod
     ### close cbdbsa100002
     ###
     ### if ws.atdetpcod    <>  3  and    # servico etapa concluida
     ###    ws.atdetpcod    <> 10  then   # servico etapa retorno
     ###    #WWWX  ws.atdetpcod    <>  5  then   # servico etapa cancelado
     ###    initialize d_bdbsa100.* , ws.*  to null
     ###    continue foreach
     ### end if

     #------------------------------------------------------------
     # VERIFICA SE O SERVICO E' O NOVO (RET)ORNO
     #------------------------------------------------------------
     open  cbdbsa100009 using d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano
     fetch cbdbsa100009 into  ws.c24astcod_ret
        if ws.c24astcod_ret = "RET"  then
           initialize d_bdbsa100.* , ws.*  to null
           continue foreach
        end if
     close cbdbsa100009

     ### CONDICAO INCLUIDA NO SELECT PRINCIPAL (DATMSERVICO)
     ### #------------------------------------------------------------
     ### # VERIFICA DATA PAGAMENTO DO SERVICO
     ### #------------------------------------------------------------
     ### if ws.pgtdat is not null  then
     ###    initialize d_bdbsa100.* , ws.*  to null
     ###    continue foreach
     ### end if

     #------------------------------------------------------------
     # VERIFICA SERVICO PARTICULAR = PAGO PELO CLIENTE
     #------------------------------------------------------------
     if ws.srvprlflg = "S"  then
        initialize d_bdbsa100.* , ws.*  to null
        continue foreach
     end if

     open  cbdbsa100001 using d_bdbsa100.atdprscod
     fetch cbdbsa100001 into d_bdbsa100.maides,
                             d_bdbsa100.crnpgtcod,
                             d_bdbsa100.pestip,
                             d_bdbsa100.soctrfcod,
                             ws.qldgracod,
                             m_outciatxt              #OSF-33677
     close cbdbsa100001

     #-- CT 197475
     ### #---- OSF-33677 ----#
     ### if m_outciatxt = 'PGTO INTERNET' then
     ###    initialize d_bdbsa100.*, ws.*, m_outciatxt to null
     ###    continue foreach
     ### end if
     ### VERIFICA SE PRESTADOR TEM FLAG PAGAMENTO INTERNET
     if m_outciatxt = "INTERNET RE" or
        m_outciatxt = "INTERNET AUTO E RE"
        then
        initialize d_bdbsa100.* , ws.*, m_outciatxt  to null
        continue foreach
     end if
     #--

     #------------------------------------------------------------
     # VERIFICA NOVO FLAG PRESTADOR NO LOCAL
     #------------------------------------------------------------
     if ws.prslocflg is not null and
        ws.prslocflg = "S"       then
        ### RETER P/ANALISE PRESTADOR NO LOCAL
        if ws.qldgracod = 1 then  # padrao porto
           call ctb00g01_anlsrv( 31,
                                 "",
                                 d_bdbsa100.atdsrvnum,
                                 d_bdbsa100.atdsrvano,
                                 999999 )
        else
           call ctb00g01_anlsrv( 34,
                                 "",
                                 d_bdbsa100.atdsrvnum,
                                 d_bdbsa100.atdsrvano,
                                 999999 )
        end if
     end if

     #------------------------------------------------------------
     # VERIFICA PRESTADOR
     #------------------------------------------------------------
     if d_bdbsa100.atdprscod is null or
        d_bdbsa100.atdprscod = 6     then
        if ws.atdetpcod  =  3  then   # servico concluido
           ### RETER P/ANALISE SERVICO SEM PRESTADOR
           call ctb00g01_anlsrv( 6,
                                 "",
                                 d_bdbsa100.atdsrvnum,
                                 d_bdbsa100.atdsrvano,
                                 999999 )
        end if
        initialize d_bdbsa100.* , ws.*  to null
        continue foreach
     else
        if d_bdbsa100.atdprscod = 5  then
           if ws.atdetpcod  =  3  then   # servico concluido
              ### RETER P/ANALISE PRESTADOR NO LOCAL
              call ctb00g01_anlsrv( 5,
                                    "",
                                    d_bdbsa100.atdsrvnum,
                                    d_bdbsa100.atdsrvano,
                                    999999 )
           end if
           initialize d_bdbsa100.* , ws.*  to null
           continue foreach
        end if

        #open  cbdbsa100001 using d_bdbsa100.atdprscod
        #fetch cbdbsa100001 into  d_bdbsa100.maides,
        #                        d_bdbsa100.crnpgtcod,
        #                        d_bdbsa100.pestip,
        #                        d_bdbsa100.soctrfcod
        #close cbdbsa100001

        ### VERIFICAR SE PRESTADOR E' PESSOA JURIDICA
        if d_bdbsa100.pestip is null then
           initialize d_bdbsa100.* , ws.*  to null
           continue foreach
        end if

        ### VERIFICA SE PRESTADOR ESTA CONTIDO NA TABELA DE GERACAO
        select pstcoddig
          from tbtemp_for
         where pstcoddig = d_bdbsa100.atdprscod

        if sqlca.sqlcode <> 0 then
           initialize d_bdbsa100.* , ws.*  to null
           continue foreach
        end if
     end if

     #------------------------------------------------------------
     # VERIFICA SERVICO
     #------------------------------------------------------------
     ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
     initialize ws.socopgnum to null
     open  cbdbsa100003 using d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano
     fetch cbdbsa100003 into  ws.socopgnum
     close cbdbsa100003

     if ws.socopgnum is not null  then   # servico encontrado
        initialize d_bdbsa100.* , ws.*  to null
        continue foreach
     end if

     ### VERIFICA SERVICO COM ETAPA CANCELADO
     #WWWif ws.atdetpcod =  5  then   # servico etapa cancelado
     #WWWend if

     ### VERIFICA ULTIMA ANALISE
     initialize ws.c24evtcod, ws.caddat, ws.c24fsecod  to null

     declare cbdbsa100014 cursor for
     select c24evtcod, caddat
       from datmsrvanlhst
      where atdsrvnum    = d_bdbsa100.atdsrvnum
        and atdsrvano    = d_bdbsa100.atdsrvano
        and c24evtcod    <> 0
        and srvanlhstseq =  1

     let ws.flganl = 0   # analise do servico
     let ws.vlr_bloqueio = 0.00

     foreach cbdbsa100014 into ws.c24evtcod, ws.caddat

        select c24fsecod
          into ws.c24fsecod
          from datmsrvanlhst
         where atdsrvnum    = d_bdbsa100.atdsrvnum
           and atdsrvano    = d_bdbsa100.atdsrvano
           and c24evtcod    = ws.c24evtcod
           and srvanlhstseq = (select max(srvanlhstseq)
                                 from datmsrvanlhst
                                where atdsrvnum = d_bdbsa100.atdsrvnum
                                  and atdsrvano = d_bdbsa100.atdsrvano
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
           if ws.c24evtcod = 1 or ws.c24evtcod = 31 or ws.c24evtcod = 34
              then
              let ws.vlr_bloqueio = 1.00
           end if
           continue foreach
        end if
        #PSI 198005 - fim
     end foreach

     if ws.flganl = 0   then
        let d_bdbsa100.c24evtcod = 0
     else
        continue foreach
     end if

     ### VERIFICA SIGLA  E COD.VEICULO ACIONADO
     initialize d_bdbsa100.atdvclsgl, ws.vclcoddig_acn to null
     open  cbdbsa100006 using ws.socvclcod
     fetch cbdbsa100006 into  d_bdbsa100.atdvclsgl, ws.vclcoddig_acn
     close cbdbsa100006

     #-----------------------------------------------
     # APURA VALOR DO SERVICO
     #-----------------------------------------------
     if d_bdbsa100.c24evtcod is null  or
        d_bdbsa100.c24evtcod = 0      then
        if ws.atdcstvlr is not null and
           ws.atdcstvlr <> 0
           then
           let d_bdbsa100.socopgitmvlr = ws.atdcstvlr # valor acertado
        else
           #----------------------------------
           # Valor sugerido para o servico
           #----------------------------------
           call ctx15g00_vlrre(d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano)
                     returning ws.socntzcod, ws.vlrsugerido,
                               ws.vlrmaximo, ws.vlrdiferenc,
                               ws.vlrmltdesc,ws.nrsrvs, ws.flgtab

           let d_bdbsa100.socopgitmvlr = ws.vlrsugerido
        end if

        #WWWelse
        #WWW   if ws.atdetpcod = 5 then
        #WWW      let d_bdbsa100.socopgitmvlr = 30.00   # valor fixo R$ 30,00
        #WWW   end if
        if ws.vlr_bloqueio > 0 then
          let d_bdbsa100.socopgitmvlr = ws.vlr_bloqueio
        end if
     end if

     ### VERIFICA ENDERECO DO SERVICO
     let d_bdbsa100.local_ori = "NAO ENCONTRADO"
     initialize ws.lgdtip, ws.lgdnom, ws.lgdnum,
                ws.brrnom, ws.cidnom, ws.ufdcod to null

     open  cbdbsa100007 using d_bdbsa100.atdsrvnum, d_bdbsa100.atdsrvano
     fetch cbdbsa100007 into ws.lgdtip, ws.lgdnom, ws.lgdnum,
                             ws.brrnom, ws.cidnom, ws.ufdcod
     if sqlca.sqlcode = 0
        then
        let d_bdbsa100.local_ori = ws.lgdtip clipped," ",
                                   ws.lgdnom clipped," ",
                                   ws.lgdnum
     end if
     close cbdbsa100007

     ### VERIFICA NOME NATUREZA SERVICO
     let d_bdbsa100.socntzdes = "NAO ENCONTRADO"
     open  cbdbsa100008 using ws.socntzcod
     fetch cbdbsa100008 into  d_bdbsa100.socntzdes
     close cbdbsa100008

     #display "Enviou para o relatorio , servico = ", d_bdbsa100.atdsrvorg,
     #                                                d_bdbsa100.atdsrvnum,
     #                                                d_bdbsa100.atdsrvano,
     #        " prestador = ",d_bdbsa100.atdprscod,
     #        " cronograma = ",d_bdbsa100.crnpgtcod

     let d_bdbsa100.quebra = d_bdbsa100.atdprscod + ws.ciaempcod

     output to report bdbsa100_rel( d_bdbsa100.*, ws.ciaempcod )

     initialize d_bdbsa100.* , ws.*  to null

  end foreach

  finish report bdbsa100_rel

end function #  bdbsa100


#---------------------------------------------------------------------------
report bdbsa100_rel(r_bdbsa100)
#---------------------------------------------------------------------------

 define r_bdbsa100   record
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
    socntzdes        like datksocntz.socntzdes   ,
    quebra           integer                     ,
    ciaempcod        like datmservico.ciaempcod
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
    socopgnum        like dbsmopg.socopgnum         ,
    segnumdig        like dbsmopg.segnumdig         ,
    corsus           like dbsmopg.corsus            ,
    socfatitmqtd     like dbsmopg.socfatitmqtd      ,
    socfattotvlr     like dbsmopg.socfattotvlr      ,
    empcod           like dbsmopg.empcod            ,
    cctcod           like dbsmopg.cctcod            ,
    cgccpfnum        like dbsmopg.cgccpfnum         ,
    cgcord           like dbsmopg.cgcord            ,
    cgccpfdig        like dbsmopg.cgccpfdig         ,
    succod           like dbsmopg.succod            ,
    socpgtdoctip     like dbsmopg.socpgtdoctip      ,
    pgtdstcod        like dbsmopg.pgtdstcod         ,
    socopgfavnom_fav like dbsmopgfav.socopgfavnom   ,
    socpgtopccod_fav like dbsmopgfav.socpgtopccod   ,
    pestip_fav       like dbsmopgfav.pestip         ,
    cgccpfnum_fav    like dbsmopgfav.cgccpfnum      ,
    cgcord_fav       like dbsmopgfav.cgcord         ,
    cgccpfdig_fav    like dbsmopgfav.cgccpfdig      ,
    bcoctatip_fav    like dbsmopgfav.bcoctatip      ,
    bcocod_fav       like dbsmopgfav.bcocod         ,
    bcoagnnum_fav    like dbsmopgfav.bcoagnnum      ,
    bcoagndig_fav    like dbsmopgfav.bcoagndig      ,
    bcoctanum_fav    like dbsmopgfav.bcoctanum      ,
    bcoctadig_fav    like dbsmopgfav.bcoctadig      ,
    socopgitmnum     like dbsmopgitm.socopgitmnum   ,
    srvrmedifvlr     like dbsksrvrmeprc.srvrmedifvlr,
    c24evtrdzdes     like datkevt.c24evtrdzdes      ,
    c24fsedes        like datkfse.c24fsedes         ,
    transacao        decimal (1,0)                  ,
    tempo            char (08)                      ,
    hora             char (05)                      ,
    nometxt          char (100)                     ,
    nometxtsv        char (20)                      ,
    rodar            char (500)                     ,
    contador         integer
 end record

 define ws_fase      integer

 define l_path01      char(100) # PSI 185035
 define l_path02      char(100) # PSI 185035
 define l_param       char(300) # PSI 185035
 define l_retorno     smallint  # PSI 185035
 define l_atdsrvnum	like dbscadtippgt.nrosrv
 define l_atdsrvano 	like dbscadtippgt.anosrv
 define l_pgttipcodps	like dbscadtippgt.pgttipcodps
 define l_empcod	like dbscadtippgt.empcod
 define l_succod	like dbscadtippgt.succod
 define l_cctcod	like dbscadtippgt.cctcod
 define l_data        char(20)

 define m_atdsrvnum	like dbsmcctrat.atdsrvnum
 define m_atdsrvano 	like dbsmcctrat.atdsrvano

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 order by  r_bdbsa100.ciaempcod,
           r_bdbsa100.atdprscod,
           r_bdbsa100.quebra   ,
           r_bdbsa100.c24evtcod,
           r_bdbsa100.atdsrvnum,
           r_bdbsa100.atdsrvano


 format

    before group of r_bdbsa100.quebra       ### atdprscod
       delete from tbtemp_op
       delete from tbtemp_ap

       # definir empresa da OP, empresa do primeiro item
       if m_empcod is null or m_empcod != r_bdbsa100.ciaempcod
          then
          let m_empcod = r_bdbsa100.ciaempcod
       end if

       begin work
       let ws.transacao = 1
          if r_bdbsa100.c24evtcod is not null  and
             r_bdbsa100.c24evtcod <> 0         then
             let ws.socopgnum = 0
          else
             select max(socopgnum)
               into ws.socopgnum
               from dbsmopg
              where pstcoddig     =  r_bdbsa100.atdprscod
                and socopgsitcod  =  7

             select segnumdig   ,    corsus      ,    empcod      ,
                    cctcod      ,    cgccpfnum   ,    cgcord      ,
                    cgccpfdig   ,    succod      ,    socpgtdoctip,
                    pgtdstcod
               into ws.segnumdig   , ws.corsus      , ws.empcod      ,
                    ws.cctcod      , ws.cgccpfnum   , ws.cgcord      ,
                    ws.cgccpfdig   , ws.succod      , ws.socpgtdoctip,
                    ws.pgtdstcod
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
             let ws.tempo        = time
             let ws.hora         = ws.tempo[1,5]
             let ws.socfatitmqtd = 0
             let ws.socfattotvlr = 0

             call ctd12g00_dados_pst(3, r_bdbsa100.atdprscod)
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
                         values  (ws.socopgnum        ,
                                  r_bdbsa100.atdprscod,
                                  ws.segnumdig        ,
                                  ws.corsus           ,
                                  ws_socfatentdat     ,
                                  ws_socfatpgtdat     ,
                                  ws.socfatitmqtd     ,   # qtd.itens
                                  null                ,   # qtd.relatorio
                                  ws.socfattotvlr     ,   # vlr total
                                  m_empcod            ,
                                  ws.cctcod           ,
                                  r_bdbsa100.pestip   ,
                                  ws.cgccpfnum        ,
                                  ws.cgcord           ,
                                  ws.cgccpfdig        ,
                                  9                   ,   # automatica OK!
                                  today               ,
                                  999999              ,   # matricula
                                  r_bdbsa100.soctrfcod,
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

             for ws_fase = 1 to 3
                insert into dbsmopgfas (socopgnum,
                                        socopgfascod,
                                        socopgfasdat,
                                        socopgfashor,
                                        funmat)
                               values  (ws.socopgnum,
                                        ws_fase,     # protoc./analise/digit.
                                        today,
                                        ws.hora,
                                        999999         )

                if sqlca.sqlcode  <>  0   then
                   display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGFAS!"
                   rollback work
                   exit program (1)
                end if
             end for

          end if
          whenever error stop


    after group of r_bdbsa100.atdprscod
       if ws.socopgnum is not null and
          ws.socopgnum <> 0        then
          update dbsmopg set (socfatitmqtd, socfattotvlr )
                          =  (ws.socfatitmqtd, ws.socfattotvlr )
                 where  socopgnum = ws.socopgnum
       end if

       commit work
       let ws.transacao = 0

       whenever error continue

       ### Verifica e envia conteudo tabela temporaria - OP

       # PSI 185035 - Inicio
       let l_path01 = f_path("DBS","ARQUIVO")
       if l_path01 is null then
          let l_path01 = "."
       end if

       let l_path02 = l_path01

       let l_path01 = l_path01 clipped,"/OPRE",r_bdbsa100.atdprscod using "&&&&&&" , ".txt"

       #let ws.nometxt   = "/adat/OP", ws_socfatentdat      using "ddmmyy" , ".txt"
       #let ws.nometxtsv = "OPRE", r_bdbsa100.atdprscod using "&&&&&&" , ".txt"
       # PSI 185035 - Final

       select count(*)
         into ws.contador
         from tbtemp_op

       if ws.contador is not null and
          ws.contador > 0         then
          declare cbdbsa100015 cursor for
          select * from tbtemp_op
          order by socopgitmnum

          let l_data = current
          display "Inicio Criação de OP: ", l_data
          start report rel_tempop to l_path01

          output to report rel_tempop( 1, r_tempop.* )

          foreach cbdbsa100015 into  r_tempop.*
             output to report rel_tempop( 2, r_tempop.* )
          end foreach

          finish report rel_tempop
          let l_data = current
          display "Finalizou Criação de OP: ", l_data

          #PSI 188220
          call ctb11m17(ws.socopgnum, r_bdbsa100.atdprscod,"E","B")
       else
          initialize ws.rodar  to null
          let ws.rodar = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                       " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                        l_path01 clipped
          run ws.rodar
       end if

       #------------------------------------------------------------------
       # E-MAIL PRESTADOR
       #------------------------------------------------------------------
       #    let ws.rodar =  "uuencode ",l_path01 clipped," ",l_path01 clipped,
       #                  " | mailx -s 'OP-PRESTADOR ",
       #                  r_bdbsa100.atdprscod using "#&&&&&",
       #                  " de ",ws_socfatentdat, "' ",
       #                  r_bdbsa100.maides clipped
       #    run ws.rodar

       # PSI 185035 - Inicio
       let l_param = "OP RE PRESTADOR ",r_bdbsa100.atdprscod using '#&&&&&'," de ",ws_socfatentdat
       let l_retorno = ctx22g00_envia_email("BDBSA100",
                                            l_param,
                                            l_path01)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao enviar Email(ctx22g00) - ",l_path01
          else
             display "Nao foi encontrado email para esse modulo - BDBSA100"
          end if
       end if
       # PSI 185035 - Final

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "oriente_eduardo/spaulo_psocorro_controles@u23 < ",
       #             l_path01 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "noberto_marcelo/spaulo_psocorro_qualidade@u23 < ",
       #             l_path01 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "paiva_ricardo/spaulo_psocorro_controles@u23 < ",
       #             l_path01 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "veiga_jefferson/spaulo_psocorro_qualidade@u23 < ",
       #             l_path01 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'OP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "silva_joseaparecido/spaulo_psocorro_qualidade@u23 < ",
       #             l_path01 clipped
       #run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #WWWX  let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #WWWX               " -s 'OP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #WWWX               " de ",ws_socfatentdat, "' ",
       #WWWX               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
       #WWWX               l_path01 clipped
       #WWWX  run ws.rodar

       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------
       #WWWX  let ws.rodar =  "cp ", l_path01 clipped,
       #WWWX                 " /adat/",ws.nometxtsv clipped
       #WWWX  run ws.rodar
       #WWWX  let ws.rodar =  "rm ", l_path01 clipped
       #WWWX  run ws.rodar


       ### Verifica conteudo temporaria - AP
       #let ws.nometxt   = "/adat/AP", ws_socfatentdat      using "ddmmyy" , ".txt"
       #let ws.nometxtsv = "APRE", r_bdbsa100.atdprscod using "&&&&&&" , ".txt"

       # PSI 185035
       let l_path02 = l_path02 clipped,"/APRE",r_bdbsa100.atdprscod using "&&&&&&" , ".txt"

       select count(*)
         into ws.contador
         from tbtemp_ap

       if ws.contador is not null and
          ws.contador > 0         then
          declare cbdbsa100016 cursor for
          select * from tbtemp_ap
          order by atdsrvnum

          let l_data = current
          display "Iniciou envio de OP para prestador: ", l_data
          start report rel_tempap to l_path02

          output to report rel_tempap( 1, r_tempap.* )

          foreach cbdbsa100016 into  r_tempap.*
             output to report rel_tempap( 2, r_tempap.* )
          end foreach

          finish report rel_tempap
          let l_data = current
          display "Finalizou envio de OP para prestador: ", l_data
       else
          initialize ws.rodar  to null
          let ws.rodar = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                       " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                        l_path02 clipped
          run ws.rodar
       end if

       # PSI 185035 - Inicio
       let l_param = "AP RE PRESTADOR ",r_bdbsa100.atdprscod using '#&&&&&'," de ",ws_socfatentdat
       let l_retorno = ctx22g00_envia_email("BDBSA100",
                                            l_param,
                                            l_path02)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao enviar email(ctx22g00) - ",l_path02
          else
             display "Nao foi encontrado email para este modulo - BDBSA100"
          end if
       end if
       # PSI 185035 - Final

       #------------------------------------------------------------------
       # E-MAIL PRESTADOR
       #------------------------------------------------------------------
       #    let ws.rodar =  "uuencode ",l_path02 clipped," ",l_path02 clipped,
       #                  " | mailx -s 'AP-PRESTADOR ",
       #                  r_bdbsa100.atdprscod using "#&&&&&",
       #                  " de ",ws_socfatentdat, "' ",
       #                  r_bdbsa100.maides clipped
       #    run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "oriente_eduardo/spaulo_psocorro_controles@u23 < ",
       #             l_path02 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "noberto_marcelo/spaulo_psocorro_qualidade@u23 < ",
       #             l_path02 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "paiva_ricardo/spaulo_psocorro_controles@u23 < ",
       #             l_path02 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "veiga_jefferson/spaulo_psocorro_qualidade@u23 < ",
       #             l_path02 clipped
       #run ws.rodar
       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #             " -s 'AP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #             " de ",ws_socfatentdat, "' ",
       #             "silva_joseaparecido/spaulo_psocorro_qualidade@u23 < ",
       #             l_path02 clipped
       #run ws.rodar

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #WWWX  let ws.rodar = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
       #WWWX               " -s 'AP-PREST. RE ", r_bdbsa100.atdprscod using "#&&&&&",
       #WWWX               " de ",ws_socfatentdat, "' ",
       #WWWX               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
       #WWWX               l_path02 clipped
       #WWWX  run ws.rodar

       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------
       #WWWX  let ws.rodar =  "cp ", l_path02 clipped,
       #WWWX                 " /adat/",ws.nometxtsv clipped
       #WWWX  run ws.rodar
       #WWWX  let ws.rodar =  "rm ", l_path02 clipped
       #WWWX  run ws.rodar

       whenever error stop


    on every row
       if r_bdbsa100.c24fsecod is not null and
          r_bdbsa100.c24fsecod <> 2        and
          r_bdbsa100.c24fsecod <> 4 then

          initialize ws.c24evtrdzdes to null
          open  cbdbsa100004 using r_bdbsa100.c24evtcod
          fetch cbdbsa100004 into  ws.c24evtrdzdes
          close cbdbsa100004

          initialize ws.c24fsedes to null
          open  cbdbsa100005 using r_bdbsa100.c24fsecod
          fetch cbdbsa100005 into  ws.c24fsedes
          close cbdbsa100005

          insert into tbtemp_ap
                         values ( r_bdbsa100.atdsrvorg,
                                  r_bdbsa100.atdsrvnum,
                                  r_bdbsa100.atdsrvano,
                                  r_bdbsa100.socntzdes,
                                  r_bdbsa100.atddat,
                                  r_bdbsa100.atdhor,
                                  r_bdbsa100.atdvclsgl,
                                  r_bdbsa100.local_ori,
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
          
          let r_bdbsa100.socopgitmvlr = r_bdbsa100.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

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
                                  r_bdbsa100.atdsrvnum,
                                  r_bdbsa100.atdsrvano,
                                  r_bdbsa100.socopgitmvlr,
                                  1 ,
                                  999999,
                                  "N" )

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGITM!"
             rollback work
             exit program (1)
          end if

          let ws.socfatitmqtd = ws.socfatitmqtd + 1
          let ws.socfattotvlr = ws.socfattotvlr + r_bdbsa100.socopgitmvlr

          open cbdbsa100021 using r_bdbsa100.atdsrvnum,
               			r_bdbsa100.atdsrvano
          fetch  cbdbsa100021 into l_atdsrvnum,
          			l_atdsrvano,
          			l_pgttipcodps,
          			l_empcod,
          			l_succod,
          			l_cctcod
          close cbdbsa100021

          if l_pgttipcodps = 3 then

             whenever error continue
                open cbdbsa100022 using l_atdsrvnum,
                         l_atdsrvano
                fetch  cbdbsa100022 into m_atdsrvnum,
                          m_atdsrvano
             whenever error stop

             if sqlca.sqlcode <> 0 then
                display "Erro selecao dbsmcctrat"
             end if

             if m_atdsrvnum is null or m_atdsrvnum = 0 then
                whenever error continue
                   
                   let r_bdbsa100.socopgitmvlr = r_bdbsa100.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"
                   
                   insert into dbsmcctrat values (l_atdsrvnum,
                            l_atdsrvano,
                            l_empcod,
                            l_succod,
                            l_cctcod,
                            r_bdbsa100.socopgitmvlr)
                whenever error stop
                   if sqlca.sqlcode <> 0 then
                      display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMCCTRAT"
                      rollback work
                         exit program (1)
                   end if
             end if
          end if

          insert into tbtemp_op
                         values ( ws.socopgnum,
                                  ws.socopgitmnum,
                                  r_bdbsa100.socntzdes,
                                  r_bdbsa100.atdsrvorg,
                                  r_bdbsa100.atdsrvnum,
                                  r_bdbsa100.atdsrvano,
                                  r_bdbsa100.atddat,
                                  r_bdbsa100.atdhor,
                                  r_bdbsa100.atdvclsgl,
                                  r_bdbsa100.local_ori,
                                  0,
                                  r_bdbsa100.socopgitmvlr,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  r_bdbsa100.socopgitmvlr)

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
       end if

 end report    ###  bdbsa100_rel


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
