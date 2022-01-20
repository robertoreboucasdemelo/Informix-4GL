#***************************************************************************#
# Nome do Modulo: bdbsa181                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Cria OP e envia (via e-mail) aos prestadores                     Dez/1999 #
#***************************************************************************#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/10/2000  PSI 10426-4  WAGNER       Verifica se servico contem mais de  #
#                                       uma analise para o servico.         #
#---------------------------------------------------------------------------#
# 04/05/2000  PSI 10698-4  WAGNER       Incluir bloqueio para analise dos   #
#                                       servicos com REC (Reclamacoes)      #
#---------------------------------------------------------------------------#
# 30/06/2000  CORREIO      WAGNER       Conforme correio Eduardo Oriente    #
#                                       enviar e-mail para Leandro Silva.   #
#---------------------------------------------------------------------------#
# 14/07/2000  CORREIO      WAGNER       Conforme correio Eduardo Oriente    #
#                                       enviar e-mail para LuisFernando Melo#
#---------------------------------------------------------------------------#
# 27/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 08/08/2000  AS 21520     Wagner       Inclusao da origem do servico nos   #
#                                       arquivos textos gerados.            #
#---------------------------------------------------------------------------#
# 10/08/2000  CORREIO      WAGNER       Enviar e-mail p/ Eduardo Oriente    #
#                                       como copia de seguranca.            #
#---------------------------------------------------------------------------#
# 05/12/2000  CORREIO      WAGNER       Conforme correio Eduardo Oriente    #
#                                       enviar e-mail para Leandro Silva.   #
#                                       e retirar do Eduardo Oriente.       #
#---------------------------------------------------------------------------#
# 03/05/2001  CORREIO      WAGNER       Conforme correio Luis Fernando      #
#                                       enviar e-mail para Neusa Santos e   #
#                                       retirar do Luis Fernando.           #
#---------------------------------------------------------------------------#
# 22/05/2001  CORREIO      WAGNER       Conforme correio alterar o range de #
#                                       pesquisa de 90 para 365 dias.       #
#---------------------------------------------------------------------------#
# 06/06/2001  CORREIO      WAGNER       Conforme correio Leandro Silva      #
#                                       enviar e-mail para Celia Ribeiro e  #
#                                       retirar da Neusa Santos.            #
#---------------------------------------------------------------------------#
# 26/06/2001  CORREIO      WAGNER       Valores acertados nao deverao ser   #
#                                       novamente calculados.               #
#---------------------------------------------------------------------------#
# 08/08/2001  CORREIO      WAGNER       Conforme correio Leandro Silva      #
#                                       enviar e-mail para Neusa Santos  e  #
#                                       retirar da Celia Ribeiro.           #
#---------------------------------------------------------------------------#
# 09/08/2001  CORREIO      WAGNER       Conforme correio alterar o range de #
#                                       pesquisa de 365 p/ 210  dias.       #
#---------------------------------------------------------------------------#
# 29/08/2001  PSI 13063-0  WAGNER       QRU p/caminhao - verificar equipam. #
#                                       do veiculo do socorro.              #
#---------------------------------------------------------------------------#
# 03/09/2001  Correio      WAGNER       Caso nao haja tebala calcular valor #
#                                       fixo de R$ 1,99                     #
#---------------------------------------------------------------------------#
# 17/10/2001  PSI 14064-3  Wagner       Tratamento do retorno da funcao     #
#                                       ctb00g00 cancod = 4 e 5.            #
#---------------------------------------------------------------------------#
# 05/11/2001  Correio      Wagner       Sr.Eduardo solicitou desabilitar    #
#                                       servicos com REC (Reclamacoes).     #
#---------------------------------------------------------------------------#
# 24/01/2002  VERIFICACAO  Wagner       Criar arquivo de log para validar   #
#                                       insert tabela temporaria.           #
#---------------------------------------------------------------------------#
# 18/04/2002  PSI 15169-6  Wagner       Alteracao data pgto + 8 e primeiro  #
#                                       dia util posterior.                 #
#                                       Captacao arquivo OP primeiro dia    #
#                                       util anterior.                      #
#---------------------------------------------------------------------------#
# 22/01/2003  Correio      Zyon         Oriente solicitou novos valores     #
#                                       para Chaveiro e Servico de Taxi     #
# 22/10/2003  Teresinha S.              Identificar o tipo do veiculo       #
#                                       PSI  170585    OSF 25143            #
#                                       para Chaveiro e Servico de Taxi     #
# 02/04/2004  Cesar Lucca               O programa passa comparar o conteudo#
#             CT197475                  do campo Outras Cias (ws.outciatxt) #
#                                       com as constantes "Internet Auto"   #
#                                       e "Internet Auto e RE", sendo que   #
#                                       ele vai inicializar as variaveis com#
#                                       nulo e passar para o proximo        #
#                                       registro caso a comparacao seja     #
#                                       diferente a uma das constantes.     #
#---------------------------------------------------------------------------#
# 07/04/2004  Adriana          Inclusao para considerar primeiro o valor    #
#             CT 197475        acertado                                     #
#---------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 28/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# 03/12/2004 Mariana, Meta     PSI188220  Gerar op´s automaticas dos servi  #
#                                         cos web                           #
# 21/03/2005 Pietro - Meta     PSI188751  Criacao Funcao prepare() e        #
#                                         altaracoes na funcao bdbsa181 c/  #
#                                         cursores criados e alterados na   #
#                                         funcao prepare()                  #
#...........................................................................#
# 22/08/2005 Cristiane Silva   PSI 194573 Alterar descritivo de 30 minutos  #
#                                         para 20 minutos                   #
#...........................................................................#
# 09/07/2005 Tiago Solda, Meta PSI193925  Tratamento do horario de aciona-  #
#                                         mento do servico                  #
#...........................................................................#
# 26/12/2005 Cristiane Silva              Alterar de 180 para 365 dias a    #
#                                         pesquisa de servicos              #
#...........................................................................#
# 07/03/2006 Cristiane e Lucas PSI198005  Enviar ao Portal de Negócios      #
#                                         servicos com eventos 1, 31 e 34   #
#...........................................................................#
# 27/07/2006 Priscila Staingel PSI197858  Adicionar servicos de Ass.Hospedag#
#                                         atdsrvorg = 3                     #
#...........................................................................#
# 25/08/2006 Cristiane Silva  PSI197858   Adicionar servicos de Passagem    #
#                                         aérea, atdsrvorg = 2              #
#...........................................................................#
# 25/07/2007 Cristiane Silva  PSI207233   Serviços com débito em ccusto.    #
#...........................................................................#
# 09/01/2008 Sergio Burini                Problema no acerto de Servicos de #
#                                         meia-saida                        #
# 30/06/2009 Fabio Costa      PSI 198404  Sucursal do prestador na OP       #
# 08/10/2009  PSI 247790   Burini         Adequação de tabelas              #
# 31/05/2010  CT 782696    Fabio Costa    Gravar empresa do item na OP      #
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
define ws_flglog       smallint
define ws_linlog       char(300)
define ws_nometxt      char(30)
define ws_run          char(400)
define m_path          char(100)
define m_res           smallint,
       m_msg           char(70),
       m_empcod        like dbsmopg.empcod

main

   call fun_dba_abre_banco("CT24HS")

   set isolation to dirty read

   initialize ws_incdat      , ws_fnldat      , ws_socfatentdat,
              ws_socfatpgtdat, ws_entrega     , ws_crnpgtcod   ,
              ws_countfor    , ws_flgdiabom   , ws_flglog      ,
              ws_linlog      , ws_nometxt     , ws_run         ,
              m_path         , m_res          , m_msg          ,
              m_empcod  to null

   # PSI 185035 - Inicio
   let m_path = f_path("DBS","LOG")

   if m_path is null then
      let m_path = "."
   end if

   let m_path = m_path clipped,"/bdbsa181.log"

   call startlog(m_path)

   let m_path = f_path("DBS","ARQUIVO")
   if m_path is null then
      let m_path = "."
   end if
   #PSI 185035 - Final

   call bdbsa181_prepare()

   call bdbsa181()

   display "Termino bdbsa181"

end main

#-------------------------#
function bdbsa181_prepare()
#-------------------------#
 define l_sql char(800)

 let l_sql = " select dpaksocor.maides, ",
                    " dpaksocor.crnpgtcod, ",
                    " dpaksocor.pestip, ",
                    #" dpaksocor.soctrfcod, ",
                    " dpaksocor.qldgracod, ",
                    " dpaksocor.outciatxt, ",
                    " dpaksocor.risprcflg ",
             " from dpaksocor ",
             " where dpaksocor.pstcoddig = ? "
 prepare pbdbsa181003 from l_sql
 declare cbdbsa181003 cursor for pbdbsa181003

 let l_sql = " select datkassunto.risprcflg, ",
                    " datmligacao.lignum ",
             " from datkassunto, datmligacao  ",
             " where datkassunto.c24astcod = datmligacao.c24astcod  ",
               " and datmligacao.atdsrvnum = ? ",
               " and datmligacao.atdsrvano = ? ",
               " and datmligacao.lignum    = (select min(lignum)",
                                            " from datmligacao ligpri ",
                                           " where ligpri.atdsrvnum = datmligacao.atdsrvnum ",
                                             " and ligpri.atdsrvano = datmligacao.atdsrvano)"
 prepare pbdbsa181004 from l_sql
 declare cbdbsa181004 cursor for pbdbsa181004

 let l_sql = " select datrservapol.succod, ",
                    " datrservapol.ramcod, ",
                    " datrservapol.aplnumdig, ",
                    " datrservapol.itmnumdig, ",
                    " datrservapol.edsnumref ",
             " from datrservapol ",
             " where datrservapol.atdsrvnum = ? ",
               " and datrservapol.atdsrvano = ? "
 prepare pbdbsa181005 from l_sql
 declare cbdbsa181005 cursor for pbdbsa181005

 let l_sql = " select dpamris.risldostt ",
             " from datrservapol, datmservico, dpamris ",
             " where datmservico.atdsrvnum  = datrservapol.atdsrvnum ",
               " and datmservico.atdsrvano  = datrservapol.atdsrvano ",
               " and dpamris.atdsrvnum      = datrservapol.atdsrvnum ",
               " and dpamris.atdsrvano      = datrservapol.atdsrvano ",
               " and datmservico.atddat    >= ? - 45 units day ", #Alterado para 45 dias - Richard 14/09/09
               " and datrservapol.succod    = ? ",
               " and datrservapol.ramcod    = ? ",
               " and datrservapol.aplnumdig = ? ",
               " and datrservapol.itmnumdig = ? ",
               " and datrservapol.edsnumref = ? "
 prepare pbdbsa181006 from l_sql
 declare cbdbsa181006 cursor for pbdbsa181006

 let l_sql = " select datrligprp.prporg, ",
                    " datrligprp.prpnumdig ",
             " from datrligprp ",
             " where datrligprp.lignum = ? "
 prepare pbdbsa181007 from l_sql
 declare cbdbsa181007 cursor for pbdbsa181007

 let l_sql = " select dpamris.risldostt ",
             " from datrligprp, ",
                  " datmligacao, ",
                  " datmservico, ",
                  " dpamris ",
             " where datmligacao.lignum     = datrligprp.lignum ",
               " and datmservico.atdsrvnum  = datmligacao.atdsrvnum ",
               " and datmservico.atdsrvano  = datmligacao.atdsrvano ",
               " and dpamris.atdsrvnum      = datmservico.atdsrvnum ",
               " and dpamris.atdsrvano      = datmservico.atdsrvano ",
               " and datmservico.atddat    >= ? - 45 units day ", #Alterado para 45 dias - Richard 14/09/09
               " and datrligprp.prporg      = ? ",
               " and datrligprp.prpnumdig   = ? "
 prepare pbdbsa181008 from l_sql
 declare cbdbsa181008 cursor for pbdbsa181008

 let l_sql = " insert into dpamris(empcod, ",
                                 " atdsrvnum, ",
                                 " atdsrvano, ",
                                 " risldostt) ",
             " values(?, ?, ?, 0) "   ## Status = Nao preenchido
 prepare pbdbsa181009 from l_sql

 let l_sql = " select c24fsecod ",
               " from datmsrvanlhst ",
              " where atdsrvnum = ? ",
                " and atdsrvano = ? ",
                " and c24evtcod = ? ",
                " and srvanlhstseq = 1 "
 prepare pbdbsa181011 from l_sql
 declare cbdbsa181011 cursor for pbdbsa181011

 let l_sql = " select nrosrv, anosrv, pgttipcodps, empcod, succod, cctcod ",
              " from dbscadtippgt ",
             " where nrosrv = ? ",
               " and anosrv = ? "
 prepare pbdbsa181021 from l_sql
 declare cbdbsa181021 cursor for pbdbsa181021

 let l_sql = " select atdsrvnum, atdsrvano, cctcod ",
                        " from dbsmcctrat ",
                        " where atdsrvnum = ? ",
                        " and atdsrvano = ? "
prepare pbdbsa181022 from l_sql
declare cbdbsa181022 cursor for pbdbsa181022

end function

#---------------------------------------------------------------
 function bdbsa181()
#---------------------------------------------------------------

 define d_bdbsa181   record
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
    vcldes           like datmservico.vcldes     ,
    vcllicnum        like datmservico.vcllicnum  ,
    atdvclsgl        like datmservico.atdvclsgl  ,
    maides           like dpaksocor.maides       ,
    crnpgtcod        like dpaksocor.crnpgtcod    ,
    c24evtcod        like datmsrvanlhst.c24evtcod,
    c24fsecod        like datmsrvanlhst.c24fsecod,
    soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum,
    socopgitmvlr     like dbsmopgitm.socopgitmvlr,
    pestip           like dpaksocor.pestip       ,
    soctrfcod        like dpaksocor.soctrfcod    ,
    srvtipabvdes     like datksrvtip.srvtipabvdes
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
    socvcltip        like datkveiculo.socvcltip  ,
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
    qldgracod        like dpaksocor.qldgracod    ,
    outciatxt        like dpaksocor.outciatxt    ,
    atdetphor        like datmsrvacp.atdetphor   ,
    atdprvdat        like datmservico.atdprvdat  ,
    crnpgtcod        like dpaksocor.crnpgtcod    ,
    opsrv            smallint,
    geraris          smallint,
    prs_risprcflg    like dpaksocor.risprcflg,
    ast_risprcflg    like datkassunto.risprcflg,
    risldostt        like dpamris.risldostt,
    lignum           like datmligacao.lignum,
    succod           like datrservapol.succod,
    ramcod           like datrservapol.ramcod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    vlr_bloqueio     decimal(2,0),
    vlrprm           like dbsmopgitm.socopgitmvlr,
    opsrvdias        smallint
 end record

 define l_pasasivcldes  like  datmtrptaxi.pasasivcldes
 define l_retorno       smallint # PSI 185035
 define l_inicio        like datkgeral.grlchv
 define l_final         like datkgeral.grlchv
 define l_lixo          char(50)
 define l_valor         like dbsmopgitm.socopgitmvlr
 define l_data          char(12)
 define l_count         integer
 define l_soccstcod     like dbstgtfcst.soccstcod
 define l_c24fsecod     like datmsrvanlhst.c24fsecod
 define l_param         char(03)
 define l_socadccstqtd  smallint
 define l_c24txtseq     like datmservhist.c24txtseq
 define l_msgbonif      char(300)

 define lr_erro record
     err    smallint,
     msgerr char(100)
 end record

 define lr_ctc20m09     record
         coderro         integer,                         ## Cod.erro ret.0=OK/<>0 Error
         msgerro         char(100),                       ## Mensagem erro retorno
         pstprmvlr       like dpampstprm.pstprmvlr
  end record

 #--------------------------------------------------------------------
 # Inicializacao das variaveis
 #--------------------------------------------------------------------
 let ws_flglog = 0
 initialize d_bdbsa181.*   to null
 initialize lr_ctc20m09.*  to null
 initialize ws.*           to null
 initialize l_c24fsecod    to null
 initialize l_pasasivcldes to null
 initialize l_retorno      to null
 initialize l_inicio       to null
 initialize l_final        to null
 initialize l_lixo         to null
 initialize l_valor        to null
 initialize l_data         to null
 initialize l_count        to null
 initialize l_soccstcod    to null
 initialize l_c24fsecod    to null
 initialize m_res          to null
 initialize m_msg          to null
 initialize l_c24txtseq    to null
 initialize l_msgbonif     to null

 #--------------------------------------------------------------------
 # Preparando SQL SITUACAO CRONOGRAMA
 #--------------------------------------------------------------------
 let ws.comando  = "select crnpgtstt     ",
                   "  from dbsmcrnpgt    ",
                   " where crnpgtcod = ? "
 prepare sel_dbsmcrnpgt from ws.comando
 declare c_dbsmcrnpgt cursor for sel_dbsmcrnpgt

 #--------------------------------------------------------------------
 # Preparando SQL VALIDACAO DATA ENTREGA
 #--------------------------------------------------------------------
 let ws.comando  = "select crnpgtetgdat  ",
                   "  from dbsmcrnpgtetg ",
                   " where crnpgtcod    = ? ",
                   "   and crnpgtetgdat = ? "
 prepare sel_dbsmcrnpgtetg from ws.comando
 declare c_dbsmcrnpgtetg cursor for sel_dbsmcrnpgtetg

 #--------------------------------------------------------------------
 # Preparando SQL ITENS OP
 #--------------------------------------------------------------------
 let ws.comando  = "select dbsmopgitm.socopgnum     ",
                   "  from dbsmopgitm, dbsmopg    ",
                   " where dbsmopgitm.atdsrvnum = ? ",
                   "   and dbsmopgitm.atdsrvano = ? ",
                   "   and dbsmopgitm.socopgnum    = dbsmopg.socopgnum ",
                   "   and dbsmopg.socopgsitcod <> 8 "
 prepare sel_dbsmopgitm from ws.comando
 declare c_dbsmopgitm cursor for sel_dbsmopgitm

 #--------------------------------------------------------------------
 # Preparando SQL VEICULO/RADIO
 #--------------------------------------------------------------------
 let ws.comando  = "select pstcoddig             ",
                   "  from datkveiculo           ",
                   " where pstcoddig     =   ?   ",
                   "   and socctrposflg  =  'S'  ",
                   "   and socoprsitcod  in (1,2)"
 prepare sel_radio from ws.comando
 declare c_radio cursor for sel_radio

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
 let ws.comando  = "select atdvclsgl, vclcoddig, socvcltip ",
                   "  from datkveiculo   ",
                   " where socvclcod = ? "
 prepare sel_datkveiculo from ws.comando
 declare c_datkveiculo cursor for sel_datkveiculo

 #--------------------------------------------------------------------
 # Preparando SQL TIPO DE SERVICO
 #--------------------------------------------------------------------
 let ws.comando  = "select srvtipabvdes ",
                   "  from datksrvtip   ",
                   " where atdsrvorg = ? "
 prepare sel_datksrvtip from ws.comando
 declare c_datksrvtip cursor for sel_datksrvtip

 #--------------------------------------------------------------------
 # Preparando SQL para verificacao de REC (Reclamacoes)
 #--------------------------------------------------------------------
 let ws.comando  = "select count(*)          ",
                   "  from datmligacao       ",
                   " where atdsrvnum = ?     ",
                   "   and atdsrvano = ?     ",
                   "   and lignum    <> 0    ",
                   "   and c24astcod = 'REC' "
 prepare sel_datmligacao from ws.comando
 declare c_datmligacao cursor for sel_datmligacao

 # -- Fabrica de Software - Teresinha Silva - OSF 25143
 let ws.comando  = "  select pasasivcldes "
                 , "    from datmtrptaxi  "
                 , "   where atdsrvnum = ?"
                ,  "     and atdsrvano = ?"
 prepare pbdbsa181001 from ws.comando
 declare cbdbsa181001 cursor for pbdbsa181001
 # -- OSF 25143 -- #

 let ws.comando  = "  select grlinf, "
                 , "         grlchv "
                 , "    from datkgeral  "
                 , "   where grlchv >= ? "
                 , "     and grlchv <= ? "
                 , "    order by grlchv desc "
 prepare pbdbsa181002 from ws.comando
 declare cbdbsa181002 cursor for pbdbsa181002

 #--------------------------------------------------------------------
 # Cria tabelas temporarias auxiliares
 #--------------------------------------------------------------------
 create temp table tbtemp_op
   (socopgnum        decimal (8,0),
    socopgitmnum     smallint     ,
    srvtipabvdes     char (10),
    atdsrvorg        smallint,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0),
    atddat           date ,
    atdhor           char (05),
    atdvclsgl        char (03),
    vcldes           char (40),
    vcllicnum        char (07),
    portofx          decimal (1,0),
    socopgitmvlr     decimal (15,5)) with no log

 create temp table tbtemp_ap
   (atdsrvorg        smallint,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0),
    srvtipabvdes     char (10),
    atddat           date ,
    atdhor           char (05),
    atdvclsgl        char (03),
    vcldes           char (40),
    vcllicnum        char (07),
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

 let ws_socfatentdat = ws_fnldat #DATA ENTREGA DO PRESTADOR
 let ws_socfatpgtdat = dias_uteis(ws_socfatentdat, 7, "", "S", "S")

 #--------------------------------------------------------------------
 # Cursor principal - Servicos executados por prestadores CARGA TABELA
 #--------------------------------------------------------------------
 declare  c_datmservico  cursor with hold for
     select datmservico.atdsrvnum  , datmservico.atdsrvano  ,
            datmservico.atdsrvorg  , datmservico.atddat     ,
            datmservico.atdhor     , datmservico.asitipcod  ,
            datmservico.atdprscod  , datmservico.srvprlflg  ,
            datmservico.cnldat     , datmservico.atdfnlhor  ,
            datmservico.vclcoddig  , datmservico.vcldes     ,
            datmservico.vcllicnum  , datmservico.atdvclsgl  ,
            datmservico.pgtdat     , datmservico.socvclcod  ,
            datmservico.atdcstvlr  , datmservico.prslocflg  ,
            datmservico.atdprvdat  , datmservico.ciaempcod  ,
            datmservico.atdetpcod
       from datmservico
      where datmservico.atddat between  ws_incdat  and  ws_fnldat
        and datmservico.atdsrvorg in ( 1, 2, 3, 4, 5, 6, 7, 17 )
        and pgtdat is null
        and datmservico.atdetpcod in (4, 5)

 start report bdbsa181_rel

 foreach c_datmservico into d_bdbsa181.atdsrvnum, d_bdbsa181.atdsrvano,
                            d_bdbsa181.atdsrvorg, d_bdbsa181.atddat   ,
                            d_bdbsa181.atdhor   , d_bdbsa181.asitipcod,
                            d_bdbsa181.atdprscod, ws.srvprlflg        ,
                            ws.cnldat           , ws.atdfnlhor        ,
                            d_bdbsa181.vclcoddig, d_bdbsa181.vcldes   ,
                            d_bdbsa181.vcllicnum, d_bdbsa181.atdvclsgl,
                            ws.pgtdat           , ws.socvclcod        ,
                            ws.atdcstvlr        , ws.prslocflg        ,
                            ws.atdprvdat        , d_bdbsa181.ciaempcod,
                            ws.atdetpcod

     display ""
     display "Inicio analise - Servico: ",
             d_bdbsa181.atdsrvnum, "/", d_bdbsa181.atdsrvano

    #CT: 570311
    if ws.atdcstvlr is null then
        let ws.atdcstvlr = 0
    end if

    let d_bdbsa181.c24evtcod = 0

    ## Flag de geracao de laudo RIS
    let ws.geraris = false

    #------------------------------------------------------------
    # VERIFICA SERVICO PARTICULAR = PAGO PELO CLIENTE
    #------------------------------------------------------------
    if ws.srvprlflg = "S"  then
       initialize d_bdbsa181.* , ws.*  to null
       display "Servico particular"
       continue foreach
    end if

    #------------------------------------------------------------
    # VERIFICA SE SERVICO TEM REC - RECLAMACAO
    #------------------------------------------------------------
    let ws.srvrec = 0
     open c_datmligacao using d_bdbsa181.atdsrvnum, d_bdbsa181.atdsrvano
    fetch c_datmligacao into  ws.srvrec
    close c_datmligacao

     open cbdbsa181003 using d_bdbsa181.atdprscod
    whenever error continue
    fetch cbdbsa181003  into d_bdbsa181.maides,
                             d_bdbsa181.crnpgtcod,
                             d_bdbsa181.pestip,
                             #d_bdbsa181.soctrfcod,
                             ws.qldgracod,
                             ws.outciatxt,
                             ws.prs_risprcflg
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          display 'Erro select cbdbsa181003: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
          display ' Funcao bdbsa181() ', d_bdbsa181.atdprscod
          exit program(1)
       end if
    end if
    close cbdbsa181003

    ### VERIFICA SE PRESTADOR TEM CRONOGRAMA DE PAGAMENTO
    if d_bdbsa181.crnpgtcod < 1 then
       initialize d_bdbsa181.* , ws.*  to null
       display "Prestador tem cronograma"
       continue foreach
    end if

    if  ws.outciatxt <> "INTERNET AUTO"
    and ws.outciatxt <> "INTERNET AUTO E RE" then
        initialize d_bdbsa181.* , ws.*  to null
        display "Texto Outras Companhias <> AUTO e RE"
        continue foreach
    end if

    #------------------------------------------------------------
    # VERIFICA NOVO FLAG PRESTADOR NO LOCAL
    #------------------------------------------------------------
    if ws.prslocflg is not null and
       ws.prslocflg = "S"       then
       ### RETER P/ANALISE PRESTADOR NO LOCAL
       if ws.qldgracod   =  1 then  # padrao porto
          call ctb00g01_anlsrv(32,
                               "",
                               d_bdbsa181.atdsrvnum,
                               d_bdbsa181.atdsrvano,
                               999999 )
       else
          call ctb00g01_anlsrv(5,
                               "",
                               d_bdbsa181.atdsrvnum,
                               d_bdbsa181.atdsrvano,
                               999999 )
       end if
    end if

    #------------------------------------------------------------
    # VERIFICA PRESTADOR
    #------------------------------------------------------------
    if d_bdbsa181.atdprscod is null or
       d_bdbsa181.atdprscod = 6     then
       if ws.atdetpcod  =  4  then   # servico concluido
          ### RETER P/ANALISE SERVICO SEM PRESTADOR
          call ctb00g01_anlsrv( 6,
                                "",
                                d_bdbsa181.atdsrvnum,
                                d_bdbsa181.atdsrvano,
                                999999 )
       end if
       initialize d_bdbsa181.* , ws.*  to null
       display "Cod prestador eh nulo ou 6"
       continue foreach
    else
       if d_bdbsa181.atdprscod = 5  then
          if ws.atdetpcod  =  4  then   # servico concluido
             ### RETER P/ANALISE PRESTADOR NO LOCAL
             call ctb00g01_anlsrv( 5,
                                   "",
                                   d_bdbsa181.atdsrvnum,
                                   d_bdbsa181.atdsrvano,
                                   999999 )
          end if
          initialize d_bdbsa181.* , ws.*  to null
          display "Cod prestador eh 5"
          continue foreach
       end if

       ### VERIFICAR SE PRESTADOR E' PESSOA JURIDICA
       if d_bdbsa181.pestip is null then
          initialize d_bdbsa181.* , ws.*  to null
          display "Tipo Pessoa Prestador eh nulo"
          continue foreach
       end if

    end if

    #------------------------------------------------------------
    # VERIFICA SERVICO
    #------------------------------------------------------------
    ### VERIFICA SE ORIGEM SERVICO 2=TRANSPORTE E' PARA 5 = TAXI
    if d_bdbsa181.atdsrvorg =  2  then
        if d_bdbsa181.asitipcod <> 5 then   # TAXI
                if d_bdbsa181.asitipcod <> 10 then #PSI197858 #Passagem Aerea
                        initialize d_bdbsa181.* , ws.*  to null
                        display "Origem 2 | Assistencia <> 5 | Etapa <> 10"
                        continue foreach
                end if
        end if
    end if

    ### VERIFICA SE SERVICO JA' EXISTE EM ANALISE
    select *
      from dbsmsrvacr
     where atdsrvnum = d_bdbsa181.atdsrvnum
       and atdsrvano = d_bdbsa181.atdsrvano
    if sqlca.sqlcode = 0 then
       initialize d_bdbsa181.* , ws.*  to null
       display "Servico ja esta em Analise"
       continue foreach
    end if

    ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
    initialize ws.socopgnum to null
    open  c_dbsmopgitm using d_bdbsa181.atdsrvnum, d_bdbsa181.atdsrvano
    fetch c_dbsmopgitm into  ws.socopgnum
    close c_dbsmopgitm

    if ws.socopgnum is not null  then   # servico encontrado
       initialize d_bdbsa181.* , ws.*  to null
       display "Servico ja esta em OP"
       continue foreach
    end if

    ### VERIFICA SERVICO COM ETAPA CANCELADO
    if ws.atdetpcod =  5  then   # servico etapa cancelado
       ### VERIFICA SE PRESTADOR TEM VEICULO CONTROLADO PELO RADIO
       open  c_radio using  d_bdbsa181.atdprscod
       fetch c_radio into   ws.pstcoddig
       if sqlca.sqlcode  =  notfound   then
          initialize d_bdbsa181.* , ws.*  to null
          display "Etapa 5 | prestador nao tem veiculo controlado pelo radio"
          continue foreach
       end if
       close  c_radio

       call ctb00g00(d_bdbsa181.atdsrvnum,
                     d_bdbsa181.atdsrvano,
                     ws.cnldat,
                     ws.atdfnlhor)
           returning ws.canpgtcod, ws.difcanhor

       case ws.canpgtcod
          when  1
            # GRAVAR P/ ANALISE O.S. CANCELADA, APOS 20 MINUTOS
            # CASO ESPECIAL VALORIZAR FIXO R$ 30,00
            # verificar tempo do cancelamento X previsao
            if ws.difcanhor > ws.atdprvdat then
               # cancelamento apos a previsao
               let d_bdbsa181.c24evtcod = 38
            else
               # cancelamento na previsao
               let d_bdbsa181.c24evtcod = 03
            end if
            call ctb00g01_anlsrv( d_bdbsa181.c24evtcod,
                                  "",
                                  d_bdbsa181.atdsrvnum,
                                  d_bdbsa181.atdsrvano,
                                  999999 )
          when  2
            # RETER P/ANALISE  O.S. CANCELADA ANTES DE 20 MINUTOS
            let d_bdbsa181.c24evtcod = 2
            call ctb00g01_anlsrv( d_bdbsa181.c24evtcod,
                                  "",
                                  d_bdbsa181.atdsrvnum,
                                  d_bdbsa181.atdsrvano,
                                  999999 )
          when  4
            # GRAVAR P/ ANALISE O.S. CANCELADA, APOS 10 MINUTOS
            # CASO ESPECIAL VALORIZAR FIXO R$ 30,00

            # verificar tempo do cancelamento X previsao
            if ws.difcanhor > ws.atdprvdat then
               # cancelamento apos a previsao
               let d_bdbsa181.c24evtcod = 36
            else
               # cancelamento na previsao
               let d_bdbsa181.c24evtcod = 19
            end if
            call ctb00g01_anlsrv( d_bdbsa181.c24evtcod,
                                  "",
                                  d_bdbsa181.atdsrvnum,
                                  d_bdbsa181.atdsrvano,
                                  999999 )
          when  5
            # RETER P/ANALISE  O.S. CANCELADA ANTES DE 10 MINUTOS
            let d_bdbsa181.c24evtcod = 18
            call ctb00g01_anlsrv( d_bdbsa181.c24evtcod,
                                  "",
                                  d_bdbsa181.atdsrvnum,
                                  d_bdbsa181.atdsrvano,
                                  999999 )

          otherwise
            initialize d_bdbsa181.* , ws.*  to null
            display "canpgtcod <> de 1,2,4,5"
            continue foreach
       end case
    end if

    ### VERIFICA ULTIMA ANALISE
    initialize ws.c24evtcod, ws.caddat, ws.c24fsecod  to null

    declare c_datmsrvanlhst cursor for
     select c24evtcod, caddat
       from datmsrvanlhst
      where atdsrvnum    = d_bdbsa181.atdsrvnum
        and atdsrvano    = d_bdbsa181.atdsrvano
        and c24evtcod    <> 0
        and srvanlhstseq =  1

    let ws.flganl = 0   # analise do servico
    let ws.vlr_bloqueio = 0.00

    foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

       select c24fsecod
         into ws.c24fsecod
         from datmsrvanlhst
        where atdsrvnum    = d_bdbsa181.atdsrvnum
          and atdsrvano    = d_bdbsa181.atdsrvano
          and c24evtcod    = ws.c24evtcod
          and srvanlhstseq = (select max(srvanlhstseq)
                                from datmsrvanlhst
                               where atdsrvnum = d_bdbsa181.atdsrvnum
                                 and atdsrvano = d_bdbsa181.atdsrvano
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
          if ws.c24evtcod = 1 or ws.c24evtcod = 31 or ws.c24evtcod = 32 or ws.c24evtcod = 34 then
                let ws.vlr_bloqueio = 1.00
          end if
          display "Servico com fase igual 2 ou 4"
          continue foreach
       end if
       #PSI 198005 - fim

    end foreach

    if ws.flganl = 0   then
       let d_bdbsa181.c24evtcod = 0
    else
       let d_bdbsa181.c24evtcod = ws.c24evtcod_svl
       let d_bdbsa181.c24fsecod = ws.c24fsecod_svl
    end if

    ### VERIFICA SIGLA  E COD.VEICULO ACIONADO
    initialize d_bdbsa181.atdvclsgl, ws.vclcoddig_acn to null
    open  c_datkveiculo using ws.socvclcod
    fetch c_datkveiculo into  d_bdbsa181.atdvclsgl, ws.vclcoddig_acn, ws.socvcltip
    close c_datkveiculo

    let l_data = d_bdbsa181.atddat

    #-----------------------------------------------
    # APURA VALOR DO SERVICO
    #-----------------------------------------------
    if d_bdbsa181.c24evtcod is null  or      # APENAS SERVICOS SEM BLOQUEIO
       d_bdbsa181.c24evtcod = 0      then

       if ws.atdcstvlr is not null and
          ws.atdcstvlr <> 0        then
          let d_bdbsa181.socopgitmvlr = ws.atdcstvlr # valor acertado
       else
          ### BUSCA NUMERO DA TABELA(VIGENCIA) P/ O SERVICO
          initialize d_bdbsa181.soctrfvignum, lr_erro.* to null

          call ctc00m15_rettrfvig(d_bdbsa181.atdprscod,
                                  d_bdbsa181.ciaempcod,
                                  d_bdbsa181.atdsrvorg,
                                  d_bdbsa181.asitipcod,
                                  d_bdbsa181.atddat)
               returning d_bdbsa181.soctrfcod,
                         d_bdbsa181.soctrfvignum,
                         lr_erro.*

          if lr_erro.err = notfound then
             let l_inicio = "PSOTNVG00000000"
             let l_final = "PSOTNVG",l_data[7,10] clipped,
                                     l_data[4,5] clipped,
                                     l_data[1,2]
             let l_valor = null

             open cbdbsa181002 using l_inicio,
                                     l_final
             whenever error continue
             fetch cbdbsa181002 into l_valor,
                                     l_lixo
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> 100 then
                   display "Erro de SQL - cbdbsa181002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
                   exit program(1)
                end if
             end if

             if sqlca.sqlcode = 100 or
                l_valor is null or
                l_valor <= 0 then
                let l_valor = 1.99
             else
                let l_valor = l_valor / 100
             end if
             let d_bdbsa181.socopgitmvlr = l_valor  # Tabela nao vigente
          else

             call ctc00m15_retsocgtfcod(d_bdbsa181.vclcoddig)
                  returning ws.socgtfcod, lr_erro.*

             if lr_erro.err <> 0 then
                #  Nao achou GRP TAR.VEIC., GRP.TAR. = Veic.passeio
                let ws.socgtfcod  = 10
             end if

             # VERIFICA GRP TAR.VEIC.ACIONADO
             if ws.vclcoddig_acn is not null then
                call ctc00m15_retsocgtfcod(ws.vclcoddig_acn)
                     returning ws.socgtfcod_acn, lr_erro.*

                if ws.socgtfcod  =  5                and
                   ws.socgtfcod  >  ws.socgtfcod_acn then
                   let ws.socgtfcod = ws.socgtfcod_acn
                   if ws.socgtfcod is null then
                      let ws.socgtfcod  = 10
                   end if
                end if
             end if

             # BURINI - ADICIONAL NOTURNO
             if ctx15g01_verif_adic(d_bdbsa181.atdsrvnum, d_bdbsa181.atdsrvano) then
                let l_soccstcod = 2
             else
                let l_soccstcod = 1
             end if

             let d_bdbsa181.socopgitmvlr = null
             call ctc00m15_retvlrvig(d_bdbsa181.soctrfvignum,
                                     ws.socgtfcod,
                                     l_soccstcod)
                  returning d_bdbsa181.socopgitmvlr, lr_erro.*

             #display "d_bdbsa181.soctrfvignum ", d_bdbsa181.soctrfvignum
             #display "ws.socgtfcod            ", ws.socgtfcod
             #display "l_soccstcod             ", l_soccstcod
             #display "d_bdbsa181.socopgitmvlr ", d_bdbsa181.socopgitmvlr

             if lr_erro.err <> 0 then
                if lr_erro.err <> notfound then
                   display lr_erro.msgerr
                   display 'BDBSA181 / bdbsa181() / ',d_bdbsa181.soctrfvignum
                                                     ,ws.socgtfcod
                                                     ,l_soccstcod
                   exit program(1)
                end if
             end if

             case l_soccstcod
                when 1
                     let l_param = "INI"
                when 2
                     let l_param = "ADC"
                otherwise
                     let l_param = ""
             end case

             call ctd00g00_vlrprmpgm(d_bdbsa181.atdsrvnum,
                                     d_bdbsa181.atdsrvano,
                                     l_param)
                  returning ws.vlrprm,
                            lr_erro.err

             let d_bdbsa181.socopgitmvlr = ctd00g00_compvlr(d_bdbsa181.socopgitmvlr, ws.vlrprm)

             ###################################################################
             #### REGRA TEMPORARIA PARA VALORIZAR SRV BIKE
             #if d_bdbsa181.atddat >= "30/04/2008" and ws.socvcltip = 8 then
             #   let d_bdbsa181.socopgitmvlr = 50.00
             #end if
             ###################################################################

             if d_bdbsa181.socopgitmvlr is null then
                let l_inicio = "PSOTNEN00000000"
                let l_final = "PSOTNEN",l_data[7,10] clipped,
                                        l_data[4,5] clipped,
                                        l_data[1,2]
                let l_valor = null

                open cbdbsa181002 using l_inicio,
                                        l_final
                whenever error continue
                fetch cbdbsa181002 into l_valor,
                                        l_lixo
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode <> 100 then
                      display "Erro de SQL - cbdbsa181002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
                      exit program(1)
                   end if
                end if

                if sqlca.sqlcode = 100 or
                   l_valor is null or
                   l_valor <= 0 then
                   let l_valor = 53.00
                else
                   let l_valor = l_valor / 100
                end if
                #  Nao achou na tab.GRP TAR., valor fixo p/Veic passeio
                let d_bdbsa181.socopgitmvlr = l_valor
             end if
          end if
       end if

       if ws.vlr_bloqueio > 0 then
           let d_bdbsa181.socopgitmvlr = ws.vlr_bloqueio
       end if

       ### SERVICO CANCELADO
       if ws.atdetpcod = 5 then
            let d_bdbsa181.socopgitmvlr = d_bdbsa181.socopgitmvlr / 2
            #CT: 570311
            let d_bdbsa181.socopgitmvlr = d_bdbsa181.socopgitmvlr using "###########&.&&"
       end if

    end if

    if d_bdbsa181.socopgitmvlr is null then
       let d_bdbsa181.socopgitmvlr = 00.00
    end if

    if d_bdbsa181.c24evtcod is not null  and
       d_bdbsa181.c24evtcod <> 0 then
       if d_bdbsa181.c24evtcod <> 1 and d_bdbsa181.c24evtcod <> 31 and d_bdbsa181.c24evtcod <> 32 and  d_bdbsa181.c24evtcod <> 34 then
                let d_bdbsa181.quebra = d_bdbsa181.atdprscod + d_bdbsa181.ciaempcod
                output to report bdbsa181_rel( d_bdbsa181.* )
       end if
    end if

    if d_bdbsa181.c24evtcod is null or
       d_bdbsa181.c24evtcod = 0 then

           let d_bdbsa181.socopgitmvlr = d_bdbsa181.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

           insert into dbsmsrvacr (atdsrvnum,
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
                           values (d_bdbsa181.atdsrvnum,
                                   d_bdbsa181.atdsrvano,
                                   today,
                                   current,
                                   d_bdbsa181.atdprscod,
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
                                   d_bdbsa181.socopgitmvlr,
                                   0 )

           if sqlca.sqlcode = 0 then
              #verifica se serviço possui bonificacao
              call ctc20m09_valor_bonificacao(d_bdbsa181.atdsrvnum,
                                             d_bdbsa181.atdsrvano)
                   returning lr_ctc20m09.*

              #lr_ctc20m09.coderro = 0 --> Existe Bonificacao e está OK
              #lr_ctc20m09.coderro = 1 --> Existe Bonificacao porém teve alguma penalidade
              #lr_ctc20m09.coderro = 2 --> Nao Existe Bonificacao para servico

              display "Mensagem: ", lr_ctc20m09.msgerro
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
                           values(d_bdbsa181.atdsrvnum,
                                  d_bdbsa181.atdsrvano,
                                  24, ## PREMIO
                                  lr_ctc20m09.pstprmvlr,
                                  l_socadccstqtd)


                    ## deu problema tenta mais uma vez e loga o que tentou gravar
                    if sqlca.sqlcode <> 0 then

                       display "Servico ", d_bdbsa181.atdsrvnum, " - ", d_bdbsa181.atdsrvano
                       display "Valor ",  lr_ctc20m09.pstprmvlr
                       display "Quantidade",  lr_ctc20m09.pstprmvlr

                       insert into dbsmsrvcst(atdsrvnum,
                                              atdsrvano,
                                              soccstcod,
                                              socadccstvlr,
                                              socadccstqtd)
                              values(d_bdbsa181.atdsrvnum,
                                     d_bdbsa181.atdsrvano,
                                     24, ## PREMIO
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
                where atdsrvnum = d_bdbsa181.atdsrvnum
                  and atdsrvano = d_bdbsa181.atdsrvano

               if l_c24txtseq > 0 then
                  let l_c24txtseq = l_c24txtseq + 1
               else
                  let l_c24txtseq = 1
               end if

               if lr_ctc20m09.pstprmvlr > 0 and l_socadccstqtd > 0 then
                  let l_msgbonif = "Srv bonificado no valor de RS "
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
                               values (d_bdbsa181.atdsrvnum
                                      ,l_c24txtseq
                                      ,d_bdbsa181.atdsrvano
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

        ## Geracao de laudo RIS
        call ctb28g00_com_ris(d_bdbsa181.atdsrvnum,
                              d_bdbsa181.atdsrvano,
                              "WEB")
             returning ws.geraris

        if ws.geraris then
           whenever error continue
           execute pbdbsa181009 using d_bdbsa181.ciaempcod,
                                      d_bdbsa181.atdsrvnum,
                                      d_bdbsa181.atdsrvano
           whenever error stop
           if sqlca.sqlcode <> 0 then
              display 'Erro INSERT pbdbsa181009: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
              display ' Funcao bdbsa181() ',d_bdbsa181.atdsrvnum, '/'
                                           ,d_bdbsa181.atdsrvano
              exit program(1)
           end if
        end if
    end if

    display ""
    initialize d_bdbsa181.* , ws.*  to null

 end foreach

 #--------------------------------------------------------------------
 # Cursor principal - Servicos ajustados pelos prestadores
 #--------------------------------------------------------------------

 let l_count =  null

 whenever error continue
 select count (*)
   into l_count
   from tbtemp_for
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       display "Erro SELECT tabela TBTEMP_FOR", sqlca.sqlcode, '/'
                                              , sqlca.sqlerrd[2]
       display "bdbsa181() "
       exit program(1)
    end if
 else
    if l_count is null or
       l_count = 0     then
       display "Nao ha prestadores com cronograma nesta data ", ws_fnldat
       exit program
    end if
 end if

 #PSI 197858 - Adicionar origem 3 (Ass.Hospedagem)
 declare  c_srvact  cursor with hold for
     select datmservico.atdsrvnum  , datmservico.atdsrvano  ,
            datmservico.atdsrvorg  , datmservico.atddat     ,
            datmservico.atdhor     , datmservico.asitipcod  ,
            datmservico.atdprscod  , datmservico.srvprlflg  ,
            datmservico.cnldat     , datmservico.atdfnlhor  ,
            datmservico.vclcoddig  , datmservico.vcldes     ,
            datmservico.vcllicnum  , datmservico.atdvclsgl  ,
            datmservico.pgtdat     , datmservico.socvclcod  ,
            datmservico.atdcstvlr  , datmservico.prslocflg  ,
            dbsmsrvacr.incvlr      , datmservico.ciaempcod
       from datmservico, dbsmsrvacr
      where datmservico.atddat between  ws_incdat  and  ws_fnldat
        and datmservico.atdsrvorg in ( 1, 2, 3, 4, 5, 6, 7, 17 )
        and datmservico.atdsrvnum = dbsmsrvacr.atdsrvnum
        and datmservico.atdsrvano = dbsmsrvacr.atdsrvano
        and dbsmsrvacr.prsokaflg = "S"
        and dbsmsrvacr.anlokaflg = "S"


 foreach c_srvact into d_bdbsa181.atdsrvnum, d_bdbsa181.atdsrvano,
                       d_bdbsa181.atdsrvorg, d_bdbsa181.atddat   ,
                       d_bdbsa181.atdhor   , d_bdbsa181.asitipcod,
                       d_bdbsa181.atdprscod, ws.srvprlflg        ,
                       ws.cnldat           , ws.atdfnlhor        ,
                       d_bdbsa181.vclcoddig, d_bdbsa181.vcldes   ,
                       d_bdbsa181.vcllicnum, d_bdbsa181.atdvclsgl,
                       ws.pgtdat           , ws.socvclcod        ,
                       ws.atdcstvlr        , ws.prslocflg        ,
                       d_bdbsa181.socopgitmvlr , d_bdbsa181.ciaempcod

    #CT: 570311
    if ws.atdcstvlr is null then
        let ws.atdcstvlr = 0
    end if
    ### VERIFICA SE PRESTADOR ESTA CONTIDO NA TABELA DE GERACAO
    select pstcoddig
      from tbtemp_for
     where pstcoddig =  d_bdbsa181.atdprscod

    if sqlca.sqlcode <> 0 then
       initialize d_bdbsa181.* , ws.*  to null
       display "Prestador nao contido na tabela geracao"
       continue foreach
    end if

    ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
    initialize ws.socopgnum to null
    open  c_dbsmopgitm using d_bdbsa181.atdsrvnum, d_bdbsa181.atdsrvano
    fetch c_dbsmopgitm into  ws.socopgnum
    close c_dbsmopgitm

    if ws.socopgnum is not null  then   # servico encontrado
       initialize d_bdbsa181.* , ws.*  to null
       display "Servico jah esta em OP"
       continue foreach
    end if

 # ---------------------------------------------- #
 # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
 # ---------------------------------------------- #

    call ctb00g01_srvanl ( d_bdbsa181.atdsrvnum
                          ,d_bdbsa181.atdsrvano
                          ,"N" )
            returning  ws.flganl
             ,ws.c24evtcod
             ,ws.c24fsecod
    if ws.flganl > 0 then
       initialize d_bdbsa181.* , ws.*  to null
       display "Ja existe fase do servico em analise"
       continue foreach
    end if

    ### VERIFICA TIPO DE SERVICO
    let d_bdbsa181.srvtipabvdes = "NAO ENCONTRADO"
    open  c_datksrvtip using d_bdbsa181.atdsrvorg
    fetch c_datksrvtip into  d_bdbsa181.srvtipabvdes
    close c_datksrvtip

    let d_bdbsa181.quebra = d_bdbsa181.atdprscod + d_bdbsa181.ciaempcod
    output to report bdbsa181_rel( d_bdbsa181.* )
 end foreach

 finish report bdbsa181_rel

 if ws_flglog <> 0 then
    #------------------------------------------------------------------
    # E-MAIL log
    #------------------------------------------------------------------
    let ws_nometxt   = m_path clipped,"/LOGOP", today using "ddmmyy" , ".txt"
    unload to ws_nometxt select * from tblog
    let ws_run = "LOGOP WEB de '",today,"' "
    let l_retorno = ctx22g00_envia_email("BDBSA181",
                                         ws_run,
                                         ws_nometxt)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro ao enviar email(ctx22g00) - ",ws_nometxt
       else
          display "Nao existe email cadastrado para este modulo - BDBSA181"
       end if
    end if

 end if

end function #  bdbsa181

#---------------------------------------------------------------------------
 function  bdbsa181_log(wr_linlog)
#---------------------------------------------------------------------------
 define wr_linlog char(300)

 if ws_flglog = 0 then
    let ws_flglog = 1
    create temp table tblog (linlog char(300)) with no log
 end if
 insert into tblog values (wr_linlog)

end function #  bdbsa181_log

#---------------------------------------------------------------------------
 report bdbsa181_rel(r_bdbsa181)
#---------------------------------------------------------------------------

 define r_bdbsa181   record
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
    vcldes           like datmservico.vcldes     ,
    vcllicnum        like datmservico.vcllicnum  ,
    atdvclsgl        like datmservico.atdvclsgl  ,
    maides           like dpaksocor.maides       ,
    crnpgtcod        like dpaksocor.crnpgtcod    ,
    c24evtcod        like datmsrvanlhst.c24evtcod,
    c24fsecod        like datmsrvanlhst.c24fsecod,
    soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum,
    socopgitmvlr     like dbsmopgitm.socopgitmvlr,
    pestip           like dpaksocor.pestip       ,
    soctrfcod        like dpaksocor.soctrfcod    ,
    srvtipabvdes     like datksrvtip.srvtipabvdes
 end record

 define r_tempop     record
    socopgnum        decimal (8,0) ,
    socopgitmnum     smallint      ,
    srvtipabvdes     char (10)     ,
    atdsrvorg        smallint      ,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0) ,
    atddat           date          ,
    atdhor           char (05)     ,
    atdvclsgl        char (03)     ,
    vcldes           char (40)     ,
    vcllicnum        char (07)     ,
    portofx          decimal (1,0) ,
    socopgitmvlr     decimal (15,5)
 end record

 define r_tempap     record
    atdsrvorg        smallint      ,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0) ,
    srvtipabvdes     char (10)     ,
    atddat           date          ,
    atdhor           char (05)     ,
    atdvclsgl        char (03)     ,
    vcldes           char (40)     ,
    vcllicnum        char (07)     ,
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
    pestip           like dbsmopg.pestip         ,
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
    time             char (08)                   ,
    hora             char (05)                   ,
    nometxtsv        char (15)                   ,
    count            integer                     ,
    soccstcod        like dbsmsrvcst.soccstcod   ,
    socadccstvlr     like dbsmsrvcst.socadccstvlr,
    socadccstqtd     like dbsmsrvcst.socadccstqtd
 end record

 define ws_fase         integer
 define l_retorno       smallint # PSI 185035
 define l_mensagem      char(50)
 define l_atdsrvnum     like dbscadtippgt.nrosrv
 define l_atdsrvano     like dbscadtippgt.anosrv
 define l_pgttipcodps   like dbscadtippgt.pgttipcodps
 define l_empcod        like dbscadtippgt.empcod
 define l_succod        like dbscadtippgt.succod
 define l_cctcod        like dbscadtippgt.cctcod
 define m_atdsrvnum     like dbsmcctrat.atdsrvnum
 define m_atdsrvano     like dbsmcctrat.atdsrvano

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 order by  r_bdbsa181.ciaempcod,
           r_bdbsa181.atdprscod,
           r_bdbsa181.quebra,
           r_bdbsa181.c24evtcod,
           r_bdbsa181.srvtipabvdes,
           r_bdbsa181.atdsrvnum,
           r_bdbsa181.atdsrvano


 format

    before group of r_bdbsa181.quebra    ### atdprscod
       delete from tbtemp_op
       delete from tbtemp_ap

       # definir empresa da OP, empresa do primeiro item
       if m_empcod is null or m_empcod != r_bdbsa181.ciaempcod
          then
          let m_empcod = r_bdbsa181.ciaempcod
       end if

       begin work
       let ws.transacao = 1
          if r_bdbsa181.c24evtcod is not null  and
             r_bdbsa181.c24evtcod <> 0         then
             let ws.socopgnum = 0
          else
             select max(socopgnum)
               into ws.socopgnum
               from dbsmopg
              where pstcoddig     =  r_bdbsa181.atdprscod
                and socopgsitcod  =  7
                and soctip        =  1   # P.Socorro

             select segnumdig   ,    corsus      ,    empcod      ,
                    cctcod      ,    cgccpfnum   ,    cgcord      ,
                    cgccpfdig   ,    succod      ,    socpgtdoctip,
                    pgtdstcod   ,    pestip
               into ws.segnumdig   , ws.corsus      , ws.empcod      ,
                    ws.cctcod      , ws.cgccpfnum   , ws.cgcord      ,
                    ws.cgccpfdig   , ws.succod      , ws.socpgtdoctip,
                    ws.pgtdstcod   , ws.pestip
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
             let ws.time         = time
             let ws.hora         = ws.time[1,5]
             let ws.socfatitmqtd = 0
             let ws.socfattotvlr = 0

             call ctd12g00_dados_pst(3, r_bdbsa181.atdprscod)
                  returning m_res, m_msg, ws.succod

             ##whenever error continue

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
                                  r_bdbsa181.atdprscod,
                                  ws.segnumdig        ,
                                  ws.corsus           ,
                                  ws_socfatentdat     ,
                                  ws_socfatpgtdat     ,
                                  ws.socfatitmqtd     ,   # qtd.itens
                                  1                   ,   # qtd.relatorio
                                  ws.socfattotvlr     ,   # vlr total
                                  m_empcod            ,
                                  ws.cctcod           ,
                                  ws.pestip           ,
                                  ws.cgccpfnum        ,
                                  ws.cgcord           ,
                                  ws.cgccpfdig        ,
                                  9                   ,   # automatica OK!
                                  today               ,
                                  999999              ,   # matricula
                                  r_bdbsa181.soctrfcod,
                                  ws.succod           ,
                                  ws.socpgtdoctip     ,
                                  ws_socfatentdat     ,
                                  ws.pgtdstcod        ,
                                  2                   ,   # geracao automatica
                                  1                   )   # tipo OP

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


    after group of r_bdbsa181.quebra    ### atdprscod
       if ws.socopgnum is not null and
          ws.socopgnum <> 0        then
          let ws.socfattotvlr = ws.socfattotvlr using "&&&&&&&&&&&&&&&.&&"
          update dbsmopg set (socfatitmqtd, socfattotvlr )
                          =  (ws.socfatitmqtd, ws.socfattotvlr )
                 where  socopgnum = ws.socopgnum
       end if

       commit work
       let ws.transacao = 0

       whenever error continue

       ### Verifica e envia conteudo tabela temporaria - OP
       let ws_nometxt   = m_path clipped,"/OPAUTO", r_bdbsa181.atdprscod using "&&&&&&" , ".txt"
       select count(*)
         into ws.count
         from tbtemp_op

       if ws.count is not null and
          ws.count > 0         then
          declare c_tempop cursor for
           select * from tbtemp_op
            order by socopgitmnum

          start report rel_tempop to ws_nometxt

          foreach c_tempop into  r_tempop.*
             output to report rel_tempop( r_tempop.* )
          end foreach

          finish report rel_tempop
       else
          initialize ws_run  to null
          let ws_run = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                       " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                        ws_nometxt clipped
          run ws_run
       end if

       #------------------------------------------------------------------
       # E-MAIL PRESTADOR
       #------------------------------------------------------------------
       #    let ws_run =  "uuencode ",ws_nometxt clipped," ",ws_nometxt clipped,
       #                  " | mailx -s 'OP-PRESTADOR ",
       #                  r_bdbsa181.atdprscod using "#&&&&&",
       #                  " de ",ws_socfatentdat, "' ",
       #                  r_bdbsa181.maides clipped
       #    run ws_run

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'OPW-PRESTADOR ",
       #              r_bdbsa181.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "santos_neusa/spaulo_psocorro_controles@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'OPW-PRESTADOR ",
       #              r_bdbsa181.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "silva_leandro/spaulo_psocorro_pagamentos@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       let ws_run = "OP AUTO WEB PRESTADOR", r_bdbsa181.atdprscod using "&&&&&&"
       let l_retorno = ctx22g00_envia_email("BDBSA181",
                                             ws_run,
                                             ws_nometxt)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao enviar email(ctx22g00) - ",ws_nometxt
          else
             display "Nao existe email cadastrado para este modulo - BDBSA181"
          end if
       end if


       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------

       ### Verifica conteudo temporaria - AP
       let ws_nometxt = m_path clipped,"/APAUTO", r_bdbsa181.atdprscod using "&&&&&&" , ".txt"
       select count(*)
         into ws.count
         from tbtemp_ap

       if ws.count is not null and
          ws.count > 0         then
          declare c_tempap cursor for
           select * from tbtemp_ap
            order by srvtipabvdes, atdsrvnum

          start report rel_tempap to ws_nometxt

          foreach c_tempap into  r_tempap.*
             output to report rel_tempap( r_tempap.* )
          end foreach

          finish report rel_tempap
       else
          initialize ws_run  to null
          let ws_run = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                       " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                        ws_nometxt clipped
          run ws_run
       end if

       #------------------------------------------------------------------
       # E-MAIL PRESTADOR
       #------------------------------------------------------------------
       #    let ws_run =  "uuencode ",ws_nometxt clipped," ",ws_nometxt clipped,
       #                  " | mailx -s 'AP-PRESTADOR ",
       #                  r_bdbsa181.atdprscod using "#&&&&&",
       #                  " de ",ws_socfatentdat, "' ",
       #                  r_bdbsa181.maides clipped
       #    run ws_run

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'APW-PRESTADOR ",
       #              r_bdbsa181.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "santos_neusa/spaulo_psocorro_controles@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'APW-PRESTADOR ",
       #              r_bdbsa181.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "silva_leandro/spaulo_psocorro_pagamentos@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       let ws_run = "AP AUTO WEB PRESTADOR", r_bdbsa181.atdprscod using "&&&&&&"
       let l_retorno = ctx22g00_envia_email("BDBSA181",
                                             ws_run,
                                             ws_nometxt)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao enviar email(ctx22g00) - ",ws_nometxt
          else
             display "Nao existe email cadastrado para este modulo - BDBSA181"
          end if
       end if

       whenever error stop


    on every row
       if r_bdbsa181.c24fsecod is not null   and
          r_bdbsa181.c24fsecod <> 2         and
          r_bdbsa181.c24fsecod <> 4  then

          initialize ws.c24evtrdzdes to null
          open  c_datkevt using r_bdbsa181.c24evtcod
          fetch c_datkevt into  ws.c24evtrdzdes
          close c_datkevt

          initialize ws.c24fsedes to null
          open  c_datkfse using r_bdbsa181.c24fsecod
          fetch c_datkfse into  ws.c24fsedes
          close c_datkfse

          insert into tbtemp_ap
                         values ( r_bdbsa181.atdsrvorg,
                                  r_bdbsa181.atdsrvnum,
                                  r_bdbsa181.atdsrvano,
                                  r_bdbsa181.srvtipabvdes,
                                  r_bdbsa181.atddat,
                                  r_bdbsa181.atdhor,
                                  r_bdbsa181.atdvclsgl,
                                  r_bdbsa181.vcldes,
                                  r_bdbsa181.vcllicnum,
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

          let r_bdbsa181.socopgitmvlr = r_bdbsa181.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

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
                                  r_bdbsa181.atdsrvnum,
                                  r_bdbsa181.atdsrvano,
                                  r_bdbsa181.socopgitmvlr,
                                  2 ,
                                  999999,
                                  "N" )

          let ws.socfattotvlr = ws.socfattotvlr + r_bdbsa181.socopgitmvlr

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
              where atdsrvnum = r_bdbsa181.atdsrvnum
                and atdsrvano = r_bdbsa181.atdsrvano

          foreach c_dbsmsrvcst into ws.soccstcod,
                                    ws.socadccstvlr,
                                    ws.socadccstqtd

             let ws.socadccstvlr = ws.socadccstvlr using "&&&&&&&&&&&&&&&.&&"
             let ws.socadccstqtd = ws.socadccstqtd using "&&&&&&&&"

             insert into dbsmopgcst (socopgnum,
                                     socopgitmnum,
                                     atdsrvnum,
                                     atdsrvano,
                                     soccstcod,
                                     socopgitmcst,
                                     cstqtd)
                             values (ws.socopgnum,
                                     ws.socopgitmnum,
                                     r_bdbsa181.atdsrvnum,
                                     r_bdbsa181.atdsrvano,
                                     ws.soccstcod,
                                     ws.socadccstvlr,
                                     ws.socadccstqtd )

             let ws.socfattotvlr = ws.socfattotvlr + ws.socadccstvlr

             if sqlca.sqlcode  <>  0   then
                display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGCST!"
                rollback work
                exit program (1)
             end if

          end foreach

          let ws.socfatitmqtd = ws.socfatitmqtd + 1


          open cbdbsa181021 using r_bdbsa181.atdsrvnum,
                                r_bdbsa181.atdsrvano
          fetch  cbdbsa181021 into l_atdsrvnum,
                                l_atdsrvano,
                                l_pgttipcodps,
                                l_empcod,
                                l_succod,
                                l_cctcod
          close cbdbsa181021

          if l_pgttipcodps = 3
             then

             let m_atdsrvnum = null
             let m_atdsrvano = null
             whenever error continue
             open cbdbsa181022 using l_atdsrvnum,
                                     l_atdsrvano
             fetch  cbdbsa181022 into m_atdsrvnum,
                                      m_atdsrvano
             whenever error stop

             if sqlca.sqlcode <> 0 then
                     display "Erro selecao dbsmcctrat"
             end if

             if m_atdsrvnum is null or m_atdsrvnum = 0
                then
                whenever error continue

                let r_bdbsa181.socopgitmvlr = r_bdbsa181.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

                insert into dbsmcctrat values (r_bdbsa181.atdsrvnum,
                                               r_bdbsa181.atdsrvano  ,
                                               l_empcod,
                                               l_succod,
                                               l_cctcod,
                                               r_bdbsa181.socopgitmvlr)
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMCCTRAT"
                   rollback work
                   exit program (1)
                end if
             end if

          end if

          whenever error continue

          let r_bdbsa181.socopgitmvlr = r_bdbsa181.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

          insert into tbtemp_op
                         values ( ws.socopgnum,
                                  ws.socopgitmnum,
                                  r_bdbsa181.srvtipabvdes,
                                  r_bdbsa181.atdsrvorg,
                                  r_bdbsa181.atdsrvnum,
                                  r_bdbsa181.atdsrvano,
                                  r_bdbsa181.atddat,
                                  r_bdbsa181.atdhor,
                                  r_bdbsa181.atdvclsgl,
                                  r_bdbsa181.vcldes,
                                  r_bdbsa181.vcllicnum,
                                  1,
                                  r_bdbsa181.socopgitmvlr)

          if sqlca.sqlcode  <>  0   then
             let ws_linlog = "tbtemp_op|",
                              sqlca.sqlcode,"|",
                              ws.socopgnum,"|",
                              ws.socopgitmnum,"|",
                              r_bdbsa181.srvtipabvdes clipped,"|",
                              r_bdbsa181.atdsrvorg,"|",
                              r_bdbsa181.atdsrvnum,"|",
                              r_bdbsa181.atdsrvano,"|",
                              r_bdbsa181.atddat,"|",
                              r_bdbsa181.atdhor,"|",
                              r_bdbsa181.atdvclsgl,"|",
                              r_bdbsa181.vcldes clipped,"|",
                              r_bdbsa181.vcllicnum,"|",
                              r_bdbsa181.socopgitmvlr,"|"
             call bdbsa181_log(ws_linlog)
          end if
       end if
       whenever error stop

    on last row
       if ws.transacao = 1 then
          commit work
       end if

 end report    ###  bdbsa181_rel


#---------------------------------------------------------------------------
 report rel_tempop(r_tempop)
#---------------------------------------------------------------------------

 define r_tempop     record
    socopgnum        decimal (8,0) ,
    socopgitmnum     smallint      ,
    srvtipabvdes     char (10)     ,
    atdsrvorg        smallint      ,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0) ,
    atddat           date          ,
    atdhor           char (05)     ,
    atdvclsgl        char (03)     ,
    vcldes           char (40)     ,
    vcllicnum        char (07)     ,
    portofx          decimal (1,0) ,
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
        print column 001, r_tempop.socopgnum      using "<<<<<<<#", "|",
                          r_tempop.socopgitmnum   using "<<<#",     "|",
                          r_tempop.srvtipabvdes,                    "|",
                          r_tempop.atdsrvorg      using "&&",       "|",
                          r_tempop.atdsrvnum      using "&&&&&&&",  "|",
                          r_tempop.atdsrvano      using "&&",       "|",
                          r_tempop.atddat,                          "|",
                          r_tempop.atdhor,                          "|",
                          r_tempop.atdvclsgl      clipped,          "|",
                          r_tempop.vcldes         clipped,          "|",
                          r_tempop.vcllicnum      clipped,          "|",
                          r_tempop.portofx        using "<<#",      "|",
                          r_tempop.socopgitmvlr   using "######.##","|",
                          "||||||||",ascii(13)


 end report    ### rel_tempop


#---------------------------------------------------------------------------
 report rel_tempap(r_tempap)
#---------------------------------------------------------------------------

 define r_tempap     record
    atdsrvorg        smallint      ,
    atdsrvnum        decimal (10,0),
    atdsrvano        decimal (2,0),
    srvtipabvdes     char (10)    ,
    atddat           date         ,
    atdhor           char (05)    ,
    atdvclsgl        char (03)    ,
    vcldes           char (40)    ,
    vcllicnum        char (07)    ,
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
        print column 001, r_tempap.atdsrvorg      using "&&",       "|",
                          r_tempap.atdsrvnum      using "&&&&&&&",  "|",
                          r_tempap.atdsrvano      using "&&",       "|",
                          r_tempap.srvtipabvdes   clipped,          "|",
                          r_tempap.atddat,                          "|",
                          r_tempap.atdhor,                          "|",
                          r_tempap.atdvclsgl      clipped,          "|",
                          r_tempap.vcldes         clipped,          "|",
                          r_tempap.vcllicnum      clipped,          "|",
                          r_tempap.c24evtrdzdes,                    "|",
                          r_tempap.c24fsedes,                       "|",
                          ascii(13)

 end report    ### rel_tempap

