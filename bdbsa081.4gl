#############################################################################
# Nome do Modulo: BDBSA081                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Cria OP e envia (via e-mail) aos prestadores (AUTO)             Dez/1999  #
#############################################################################
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
#                                       para Chaveiro e Serviço de Taxi     #
#---------------------------------------------------------------------------#
#                          * * *  ALTERACOES  * * *                         #
# Data        Autor Fabrica    Alteracao                           PSI      #
# 17/06/2003  Alexandre Farias Data inicial do proces. de serviços 174904   #
#                                                                           #
# 22/10/2003  Teresinha S.     Identificar o tipo do veiculo       170585   #
#             OSF 25143                                                     #
#                                                                           #
# 02/04/2004  Paula            Inibir a linha 'let ws_incdat = "01/10/2001" #
#             CT197181                                                      #
#                                                                           #
# 02/04/2004  Cesar Lucca      O programa passa comparar o conteudo do      #
#             CT197475         campo Outras Cias (ws.outciatxt) com as      #
#                              constantes "Internet Auto" e "Internet Auto  #
#                              e RE", sendo que ele vai inicializar as      #
#                              variaveis com nulo e passar para o proximo   #
#                              registro caso a comparacao seja igual a uma  #
#                              das constantes.                              #
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
# 03/12/2004 Helio (Meta)      PSI188220  Alteracoes diversas               #
#...........................................................................#
# 22/08/2005 Cristiane Silva   PSI 194573 Alterar descritivo de 30 minutos  #
#                                         para 20 minutos                   #
#---------------------------------------------------------------------------#
# 09/09/2005 Andrei, Meta      PSI 193925 Criar consistencia ws.atdetphor>= #
#                                         '20:00' or <= '06:00' na funcao   #
#                                         bdbsa081()                        #
#...........................................................................#
# 26/12/2005 Cristiane Silva              Alterar de 180 para 365 dias a    #
#                                         pesquisa de serviços              #
#...........................................................................#
# 07/06/2006 Cristiane e Lucas  PSI198005 Enviar ao Portal de Negócios      #
#                                         servicos com eventos 1, 31 e 34   #
#...........................................................................#
# 23/06/2006 Priscila           PSI197858 Adaptar programa para versao 4gc  #
#                                         devido ao envio de SMS (gera mq)  #
#...........................................................................#
# 19/07/2007 Burini             CT7074503 Serviços com eventos <> 0 não     #
#                                         serão mais emitidos com OP 0      #
#...........................................................................#
# 25/07/2007 Cristiane Silva    PSI207233 Serviços com débito em ccusto.    #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini         Fases da OP - Registro Responsavel#
# 30/06/2009  PSI 198404   Fabio Costa    Sucursal do prestador na OP       #
# 08/10/2009  PSI 247790   Burini         Adequação de tabelas              #
# 31/05/2010  CT 782696    Fabio Costa    Gravar empresa do item na OP      #
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                        de mais de duas casas decimais.    #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn #
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
define ws_flglog       smallint
define ws_linlog       char(300)
define ws_nometxt      char(30)
define ws_run          char(400)
define m_res           smallint,
       m_msg           char(70),
       m_empcod        like dbsmopg.empcod

define m_path          char(100)

main

   call fun_dba_abre_banco("CT24HS")

   set isolation to dirty read

   initialize  ws_incdat      , ws_fnldat      , ws_socfatentdat,
               ws_socfatpgtdat, ws_entrega     , ws_crnpgtcod   ,
               ws_countfor    , ws_flgdiabom   , ws_flglog      ,
               ws_linlog      , ws_nometxt     , ws_run         ,
               m_res          , m_msg          , m_path         ,
               m_empcod   to null

   # PSI 185035 - Inicio
   let m_path = f_path("DBS","LOG")
   if m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped,"/bdbsa081.log"

   call startlog(m_path)
   # PSI 185035 - Final

   call bdbsa081_prepare()

   call bdbsa081()

   ## TEMPORARIO ATE TODOS PRESTADORES ESTAREM NA INTERNET
end main

#---------------------------
function bdbsa081_prepare()
#---------------------------

 define l_sql char(600)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_sql  =  null

 ## let l_sql  = "select atdetpcod, atdetphor    ",
 ##              "  from datmsrvacp   ",
 ##              " where atdsrvnum = ?",
 ##              "   and atdsrvano = ?",
 ##              "   and atdsrvseq = (select max(atdsrvseq)",
 ##                                  "  from datmsrvacp    ",
 ##                                  " where atdsrvnum = ? ",
 ##                                  "   and atdsrvano = ?)"
 ##
 ## prepare pbdbsa081004 from l_sql
 ## declare cbdbsa081004 cursor for pbdbsa081004

 let l_sql = " select c24fsecod ",
               " from datmsrvanlhst ",
              " where atdsrvnum = ? ",
                " and atdsrvano = ? ",
                " and c24evtcod = ? ",
                " and srvanlhstseq = 1 "

 prepare pbdbsa081005 from l_sql
 declare cbdbsa081005 cursor for pbdbsa081005
 let l_sql = " select nrosrv, anosrv, pgttipcodps, empcod, succod, cctcod ",
              " from dbscadtippgt ",
             " where nrosrv = ? ",
               " and anosrv = ? "

 prepare pbdbsa081021 from l_sql
 declare cbdbsa081021 cursor for pbdbsa081021


 let l_sql = " select atdsrvnum, atdsrvano, cctcod ",
                        " from dbsmcctrat ",
                        " where atdsrvnum = ? ",
                        " and atdsrvano = ? "

 prepare pbdbsa081022 from l_sql
 declare cbdbsa081022 cursor for pbdbsa081022

end function



#---------------------------------------------------------------
 function bdbsa081()
#---------------------------------------------------------------

 define d_bdbsa081   record
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
    vlr_bloqueio     decimal(2,0),
    vlrprm           like dbsmopgitm.socopgitmvlr,
    opsrvdias        smallint
 end record

 define l_pasasivcldes  like datmtrptaxi.pasasivcldes

 define l_retorno   smallint # PSI 185035

 define l_inicio    like datkgeral.grlchv
 define l_final     like datkgeral.grlchv
 define l_lixo      char(50)
 define l_valor     like dbsmopgitm.socopgitmvlr
 define l_data      char(12)

 define l_soccstcod like dbstgtfcst.soccstcod,
        l_c24fsecod like datmsrvanlhst.c24fsecod

 define l_arq     char(30),
        l_param   char(03)

 define lr_erro record
     err    smallint,
     msgerr char(100)
 end record

 #--------------------------------------------------------------------
 # Inicializacao das variaveis
 #--------------------------------------------------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_pasasivcldes  =  null
        let     l_retorno  =  null
        let     l_inicio  =  null
        let     l_final  =  null
        let     l_lixo  =  null
        let     l_valor  =  null
        let     l_data  =  null
        let     l_soccstcod  =  null
        let     l_c24fsecod  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_bdbsa081.*  to  null

        initialize  ws.*  to  null

 initialize d_bdbsa081.*  to null
 initialize ws.*          to null

 let m_res = null
 let m_msg = null

 let l_c24fsecod = null
 let ws_flglog = 0
 let l_pasasivcldes       = null
 #--------------------------------------------------------------------
 # Preparando SQL PRESTADOR
 #--------------------------------------------------------------------
 let ws.comando  = "select maides,crnpgtcod,pestip,qldgracod,outciatxt ",
                   "  from dpaksocor     ",
                   " where pstcoddig = ? "

 prepare pbdbsa081014 from ws.comando
 declare cbdbsa081014 cursor for pbdbsa081014

 #--------------------------------------------------------------------
 # Preparando SQL SITUACAO CRONOGRAMA
 #--------------------------------------------------------------------
 let ws.comando  = "select crnpgtstt     ",
                   "  from dbsmcrnpgt    ",
                   " where crnpgtcod = ? "

 prepare pbdbsa081015 from ws.comando
 declare cbdbsa081015 cursor for pbdbsa081015

 #--------------------------------------------------------------------
 # Preparando SQL VALIDACAO DATA ENTREGA
 #--------------------------------------------------------------------
 let ws.comando  = "select crnpgtetgdat  ",
                   "  from dbsmcrnpgtetg ",
                   " where crnpgtcod    = ? ",
                   "   and crnpgtetgdat = ? "

 prepare pbdbsa081006 from ws.comando
 declare cbdbsa081006 cursor for pbdbsa081006

 #--------------------------------------------------------------------
 # Preparando SQL ITENS OP
 #--------------------------------------------------------------------
 let ws.comando  = "select dbsmopg.socopgnum     ",
                   "  from dbsmopgitm, dbsmopg    ",
                   " where dbsmopgitm.atdsrvnum = ? ",
                   "   and dbsmopgitm.atdsrvano = ? ",
                   "   and dbsmopg.socopgnum    = dbsmopgitm.socopgnum ",
                   "   and dbsmopg.socopgsitcod <> 8 "

 prepare pbdbsa081007 from ws.comando
 declare cbdbsa081007 cursor for pbdbsa081007

 #--------------------------------------------------------------------
 # Preparando SQL VEICULO/RADIO
 #--------------------------------------------------------------------
 let ws.comando  = "select pstcoddig             ",
                   "  from datkveiculo           ",
                   " where pstcoddig     =   ?   ",
                   "   and socctrposflg  =  'S'  ",
                   "   and socoprsitcod  in (1,2)"

 prepare pbdbsa081008 from ws.comando
 declare cbdbsa081008 cursor for pbdbsa081008

 #--------------------------------------------------------------------
 # Preparando SQL EVENTO DE ANALISE
 #--------------------------------------------------------------------
 let ws.comando  = "select c24evtrdzdes    ",
                   "  from datkevt         ",
                   " where c24evtcod  =  ? "

 prepare pbdbsa081009 from ws.comando
 declare cbdbsa081009 cursor for pbdbsa081009

 #--------------------------------------------------------------------
 # Preparando SQL FASE DE ANALISE
 #--------------------------------------------------------------------
 let ws.comando  = "select c24fsedes     ",
                   "  from datkfse       ",
                   " where c24fsecod = ? "

 prepare pbdbsa081010 from ws.comando
 declare cbdbsa081010 cursor for pbdbsa081010

 #--------------------------------------------------------------------
 # Preparando SQL SIGLA VEICULO
 #--------------------------------------------------------------------
 let ws.comando  = "select atdvclsgl, vclcoddig ",
                   "  from datkveiculo   ",
                   " where socvclcod = ? "

 prepare pbdbsa081011 from ws.comando
 declare cbdbsa081011 cursor for pbdbsa081011

 #--------------------------------------------------------------------
 # Preparando SQL TIPO DE SERVICO
 #--------------------------------------------------------------------
 let ws.comando  = "select srvtipabvdes ",
                   "  from datksrvtip   ",
                   " where atdsrvorg = ? "

 prepare pbdbsa081012 from ws.comando
 declare cbdbsa081012 cursor for pbdbsa081012

 #--------------------------------------------------------------------
 # Preparando SQL para verificacao de REC (Reclamacoes)
 #--------------------------------------------------------------------
 let ws.comando  = "select count(*)          ",
                   "  from datmligacao       ",
                   " where atdsrvnum = ?     ",
                   "   and atdsrvano = ?     ",
                   "   and lignum    <> 0    ",
                   "   and c24astcod = 'REC' "

 prepare pbdbsa081013 from ws.comando
 declare cbdbsa081013 cursor for pbdbsa081013

 # -- Fabrica de Software - Teresinha Silva - OSF 25143
 let ws.comando  = "  select pasasivcldes "
                 , "    from datmtrptaxi  "
                 , "   where atdsrvnum = ?"
                ,  "     and atdsrvano = ?"
 prepare pbdbsa081001 from ws.comando
 declare cbdbsa081001 cursor for pbdbsa081001
 # -- OSF 25143 -- #

 let ws.comando  = "  select grlinf, "
                 , "         grlchv "
                 , "    from datkgeral  "
                 , "   where grlchv >= ? "
                 , "     and grlchv <= ? "
                 , "    order by grlchv desc "
 prepare pbdbsa081002 from ws.comando
 declare cbdbsa081002 cursor for pbdbsa081002


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
 declare cbdbsa081016 cursor for
  select dbsmcrnpgtetg.crnpgtcod
    from dbsmcrnpgtetg
   where dbsmcrnpgtetg.crnpgtetgdat = ws_fnldat

 foreach cbdbsa081016 into ws_crnpgtcod
    insert into tbtemp_for
                select pstcoddig
                  from dpaksocor
                 where crnpgtcod = ws_crnpgtcod
 end foreach

 #PSI 188220
 #------------------------------------------------------
 # Verifica se há algum cronograma na data
 #------------------------------------------------------
 select count(*)
   into ws_countfor
   from tbtemp_for

 if ws_countfor is null or
    ws_countfor = 0     then
     display "Nao ha prestadores com cronograma nesta data ", ws_fnldat
     exit program
 end if

 let ws_socfatentdat = ws_fnldat  # DATA ENTREGA DO PRESTADOR

 let ws_socfatpgtdat = dias_uteis(ws_socfatentdat, 7, "", "S", "S")

 let m_path = f_path("DBS","ARQUIVO")
 if m_path is null then
    let m_path = "."
 end if

 let l_arq = m_path clipped ,"/bdbsa081.txt"

 #--------------------------------------------------------------------
 # Cursor principal - Servicos executados por prestadores
 #--------------------------------------------------------------------
 ##let ws_incdat = "01/10/2002" #--> a pedido da PSI:174904

 declare  cbdbsa081017  cursor with hold for
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
        and datmservico.atdsrvorg in ( 1, 2, 4, 5, 6, 7, 17 )
        and pgtdat is null
        and datmservico.atdetpcod in (4, 5)

 #PSI 197858 - bdbsa081 agora deve ser executado como 4gc (devido as funcoes
 # que enviam SMS necessitarem do MQ) so que 4gc nao aceita que o report nao
 # tenha destino, entao foi criado o l_arq que ira criar um report vazio
 start report bdbsa081_rel to l_arq

 foreach cbdbsa081017 into d_bdbsa081.atdsrvnum, d_bdbsa081.atdsrvano,
                            d_bdbsa081.atdsrvorg, d_bdbsa081.atddat   ,
                            d_bdbsa081.atdhor   , d_bdbsa081.asitipcod,
                            d_bdbsa081.atdprscod, ws.srvprlflg        ,
                            ws.cnldat           , ws.atdfnlhor        ,
                            d_bdbsa081.vclcoddig, d_bdbsa081.vcldes   ,
                            d_bdbsa081.vcllicnum, d_bdbsa081.atdvclsgl,
                            ws.pgtdat           , ws.socvclcod        ,
                            ws.atdcstvlr        , ws.prslocflg        ,
                            ws.atdprvdat        , d_bdbsa081.ciaempcod,
                            ws.atdetpcod

    #CT: 570311
    if ws.atdcstvlr is null then
        let ws.atdcstvlr = 0
    end if
    let d_bdbsa081.c24evtcod = 0

    ### A ETAPA FOI INCLUIDA NO SELECT PRINCIPAL (DATMSERVICO)
    ####------------------------------------------------------------
    #### VERIFICA ETAPA DO SERVICO
    ####------------------------------------------------------------
    ### open cbdbsa081004 using d_bdbsa081.atdsrvnum
    ###                        ,d_bdbsa081.atdsrvano
    ###                        ,d_bdbsa081.atdsrvnum
    ###                        ,d_bdbsa081.atdsrvano
    ### whenever error continue
    ### fetch cbdbsa081004 into ws.atdetpcod
    ###                        ,ws.atdetphor
    ### whenever error stop
    ###
    ### if sqlca.sqlcode <> 0 then
    ###    if sqlca.sqlcode = notfound then
    ###       let ws.atdetpcod = null
    ###       let ws.atdetphor = null
    ###    else
    ###       display 'Erro SELECT cbdbsa081004 / ',sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]
    ###       display 'BDBSA081 / bdbsa081() / ',d_bdbsa081.atdsrvnum, ' / '
    ###                                         ,d_bdbsa081.atdsrvano, ' / '
    ###                                         ,d_bdbsa081.atdsrvnum, ' / '
    ###                                         ,d_bdbsa081.atdsrvano
    ###       exit program(1)
    ###    end if
    ### end if
    ###
    ### if ws.atdetpcod    <> 4   and    # servico etapa concluida
    ###    ws.atdetpcod    <> 5   then   # servico etapa cancelado
    ###    initialize d_bdbsa081.* , ws.*  to null
    ###    continue foreach
    ### end if

    ### CONDICAO INCLUIDA NO SELECT PRINCIPAL (DATMSERVICO)
    ### #------------------------------------------------------------
    ### # VERIFICA DATA PAGAMENTO DO SERVICO
    ### #------------------------------------------------------------
    ### if ws.pgtdat is not null  then
    ###    initialize d_bdbsa081.* , ws.*  to null
    ###    continue foreach
    ### end if

    #------------------------------------------------------------
    # VERIFICA SERVICO PARTICULAR = PAGO PELO CLIENTE
    #------------------------------------------------------------
    if ws.srvprlflg = "S"  then
       initialize d_bdbsa081.* , ws.*  to null
       continue foreach
    end if

    #------------------------------------------------------------
    # VERIFICA SE SERVICO TEM REC - RECLAMACAO
    #------------------------------------------------------------
    let ws.srvrec = 0
    open  cbdbsa081013 using d_bdbsa081.atdsrvnum, d_bdbsa081.atdsrvano
    fetch cbdbsa081013 into  ws.srvrec
    close cbdbsa081013

    #### DESABILITADO CONFORME CORREIO 05/11/2001 EDU. #
    #   if ws.srvrec > 0 then
    #      ### RETER P/ANALISE SERVICO COM RECLAMACAO
    #      call ctb00g01_anlsrv( 12,
    #                            "",
    #                            d_bdbsa081.atdsrvnum,
    #                            d_bdbsa081.atdsrvano,
    #                            999999 )
    #   end if
    ####################################################

    open  cbdbsa081014 using d_bdbsa081.atdprscod
    fetch cbdbsa081014 into  d_bdbsa081.maides,
                            d_bdbsa081.crnpgtcod,
                            d_bdbsa081.pestip,
                            #d_bdbsa081.soctrfcod,
                            ws.qldgracod,
                            ws.outciatxt
    close cbdbsa081014

    ### VERIFICA SE PRESTADOR TEM FLAG PAGAMENTO INTERNET
    #-- CT 197475
    ### if ws.outciatxt = "PGTO INTERNET" then
    ###    initialize d_bdbsa081.* , ws.*  to null
    ###    continue foreach
    ### end if
    if ws.outciatxt = "INTERNET AUTO"
    or ws.outciatxt = "INTERNET AUTO E RE" then
       initialize d_bdbsa081.* , ws.*  to null
       continue foreach
    end if
    #--

    #------------------------------------------------------------
    # VERIFICA NOVO FLAG PRESTADOR NO LOCAL
    #------------------------------------------------------------
    if ws.prslocflg is not null and
       ws.prslocflg = "S"       then
       ### RETER P/ANALISE PRESTADOR NO LOCAL
       if ws.qldgracod   =  1 then  # padrao porto
          call ctb00g01_anlsrv(32,
                               "",
                               d_bdbsa081.atdsrvnum,
                               d_bdbsa081.atdsrvano,
                               999999 )
       else
          call ctb00g01_anlsrv(5,
                               "",
                               d_bdbsa081.atdsrvnum,
                               d_bdbsa081.atdsrvano,
                               999999 )
       end if
    end if

    #------------------------------------------------------------
    # VERIFICA PRESTADOR
    #------------------------------------------------------------
    if d_bdbsa081.atdprscod is null or
       d_bdbsa081.atdprscod = 6     then
       if ws.atdetpcod  =  4  then   # servico concluido
          ### RETER P/ANALISE SERVICO SEM PRESTADOR
          call ctb00g01_anlsrv( 6,
                                "",
                                d_bdbsa081.atdsrvnum,
                                d_bdbsa081.atdsrvano,
                                999999 )
       end if
       initialize d_bdbsa081.* , ws.*  to null
       continue foreach
    else
       if d_bdbsa081.atdprscod = 5  then
          if ws.atdetpcod  =  4  then   # servico concluido
             ### RETER P/ANALISE PRESTADOR NO LOCAL
             call ctb00g01_anlsrv( 5,
                                   "",
                                   d_bdbsa081.atdsrvnum,
                                   d_bdbsa081.atdsrvano,
                                   999999 )
          end if
          initialize d_bdbsa081.* , ws.*  to null
          continue foreach
       end if

       #open  cbdbsa081004 using d_bdbsa081.atdprscod
       #fetch cbdbsa081004 into  d_bdbsa081.maides,
       #                        d_bdbsa081.crnpgtcod,
       #                        d_bdbsa081.pestip,
       #                        d_bdbsa081.soctrfcod
       #close cbdbsa081004

       ### VERIFICAR SE PRESTADOR E' PESSOA JURIDICA
       if d_bdbsa081.pestip is null then
          initialize d_bdbsa081.* , ws.*  to null
          continue foreach
       end if

       ### VERIFICA SE PRESTADOR ESTA CONTIDO NA TABELA DE GERACAO
       select pstcoddig
         from tbtemp_for
        where pstcoddig =  d_bdbsa081.atdprscod

       if sqlca.sqlcode <> 0 then
          initialize d_bdbsa081.* , ws.*  to null
          continue foreach
       end if

    end if

    #------------------------------------------------------------
    # VERIFICA SERVICO
    #------------------------------------------------------------
    ### VERIFICA SE ORIGEM SERVICO 2=TRANSPORTE E' PARA 5 = TAXI
    if d_bdbsa081.atdsrvorg =  2  then
       if d_bdbsa081.asitipcod <> 5 then   # TAXI
          initialize d_bdbsa081.* , ws.*  to null
          continue foreach
       end if
    end if

    ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
    initialize ws.socopgnum to null
    open  cbdbsa081007 using d_bdbsa081.atdsrvnum, d_bdbsa081.atdsrvano
    fetch cbdbsa081007 into  ws.socopgnum
    close cbdbsa081007

    if ws.socopgnum is not null  then   # servico encontrado
       initialize d_bdbsa081.* , ws.*  to null
       continue foreach
    end if

    ### VERIFICA SERVICO COM ETAPA CANCELADO
    if ws.atdetpcod =  5  then   # servico etapa cancelado
       ######Busca colocada em comentario por solicitacao do Orlando
       ######referente a PSI210790 em 25/07/2007

       ######open  cbdbsa081008 using  d_bdbsa081.atdprscod
       ######fetch cbdbsa081008 into   ws.pstcoddig
       ######if sqlca.sqlcode  =  notfound   then
       ######   initialize d_bdbsa081.* , ws.*  to null
       ######   continue foreach
       ######end if
       ######close  cbdbsa081008

       call ctb00g00(d_bdbsa081.atdsrvnum,
                     d_bdbsa081.atdsrvano,
                     ws.cnldat,
                     ws.atdfnlhor)
           returning ws.canpgtcod, ws.difcanhor

       case ws.canpgtcod
          when  1
            # GRAVAR P/ ANALISE O.S. CANCELADA, APOS 20 MINUTOS - PSI 194573
            # CASO ESPECIAL VALORIZAR FIXO R$ 30,00
            # verificar tempo do cancelamento X previsao
            if ws.difcanhor > ws.atdprvdat then
               # cancelamento apos a previsao
               let d_bdbsa081.c24evtcod = 38
            else
               # cancelamento na previsao
               let d_bdbsa081.c24evtcod = 03
            end if
            call ctb00g01_anlsrv( d_bdbsa081.c24evtcod,
                                  "",
                                  d_bdbsa081.atdsrvnum,
                                  d_bdbsa081.atdsrvano,
                                  999999 )
          when  2
            # RETER P/ ANALISE O.S. CANCELADA, APOS 20 MINUTOS - PSI 194573
            let d_bdbsa081.c24evtcod = 2
            call ctb00g01_anlsrv( d_bdbsa081.c24evtcod,
                                  "",
                                  d_bdbsa081.atdsrvnum,
                                  d_bdbsa081.atdsrvano,
                                  999999 )
          when  4
            # GRAVAR P/ ANALISE O.S. CANCELADA, APOS 10 MINUTOS
            # CASO ESPECIAL VALORIZAR FIXO R$ 30,00

            # verificar tempo do cancelamento X previsao
            if ws.difcanhor > ws.atdprvdat then
               # cancelamento apos a previsao
               let d_bdbsa081.c24evtcod = 36
            else
               # cancelamento na previsao
               let d_bdbsa081.c24evtcod = 19
            end if
            call ctb00g01_anlsrv( d_bdbsa081.c24evtcod,
                                  "",
                                  d_bdbsa081.atdsrvnum,
                                  d_bdbsa081.atdsrvano,
                                  999999 )
          when  5
            # RETER P/ANALISE  O.S. CANCELADA ANTES DE 10 MINUTOS
            let d_bdbsa081.c24evtcod = 18
            call ctb00g01_anlsrv( d_bdbsa081.c24evtcod,
                                  "",
                                  d_bdbsa081.atdsrvnum,
                                  d_bdbsa081.atdsrvano,
                                  999999 )

          otherwise
            initialize d_bdbsa081.* , ws.*  to null
            continue foreach
       end case
    end if


    ### VERIFICA ULTIMA ANALISE
    initialize ws.c24evtcod, ws.caddat, ws.c24fsecod  to null

    declare cbdbsa081018 cursor for
     select c24evtcod, caddat
       from datmsrvanlhst
      where atdsrvnum    = d_bdbsa081.atdsrvnum
        and atdsrvano    = d_bdbsa081.atdsrvano
        and c24evtcod    <> 0
        and srvanlhstseq =  1

    let ws.flganl = 0   # analise do servico
    let ws.vlr_bloqueio = 0.00

    foreach cbdbsa081018 into ws.c24evtcod, ws.caddat

       select c24fsecod
         into ws.c24fsecod
         from datmsrvanlhst
        where atdsrvnum    = d_bdbsa081.atdsrvnum
          and atdsrvano    = d_bdbsa081.atdsrvano
          and c24evtcod    = ws.c24evtcod
          and srvanlhstseq = (select max(srvanlhstseq)
                                from datmsrvanlhst
                               where atdsrvnum = d_bdbsa081.atdsrvnum
                                 and atdsrvano = d_bdbsa081.atdsrvano
                                 and c24evtcod = ws.c24evtcod)

       #PSI 198005 - Inicio
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
          if ws.c24evtcod = 1 or ws.c24evtcod = 31  or ws.c24evtcod = 32 or ws.c24evtcod = 34 then
                let ws.vlr_bloqueio = 1.00
          end if
          continue foreach
       end if
       #PSI 198005 - Fim

    end foreach

    if ws.flganl = 0   then
       let d_bdbsa081.c24evtcod = 0
    else
       # ALTERACAO BURINI - CT 7074503
       continue foreach
       #let d_bdbsa081.c24evtcod = ws.c24evtcod_svl
       #let d_bdbsa081.c24fsecod = ws.c24fsecod_svl
    end if

    ### VERIFICA SIGLA  E COD.VEICULO ACIONADO
    initialize d_bdbsa081.atdvclsgl, ws.vclcoddig_acn to null
    open  cbdbsa081011 using ws.socvclcod
    fetch cbdbsa081011 into  d_bdbsa081.atdvclsgl, ws.vclcoddig_acn
    close cbdbsa081011

    let l_data = d_bdbsa081.atddat

    #-----------------------------------------------
    # APURA VALOR DO SERVICO
    #-----------------------------------------------
    if d_bdbsa081.c24evtcod is null  or    # APENAS SERVICOS SEM BLOQUEIO
       d_bdbsa081.c24evtcod = 0      then

       if ws.atdcstvlr is not null and
          ws.atdcstvlr <> 0        then
          let d_bdbsa081.socopgitmvlr = ws.atdcstvlr # valor acertado
       else
          ### BUSCA NUMERO DA TABELA(VIGENCIA) P/ O SERVICO
          initialize d_bdbsa081.soctrfvignum, lr_erro.* to null

          call ctc00m15_rettrfvig(d_bdbsa081.atdprscod,
                                  d_bdbsa081.ciaempcod,
                                  d_bdbsa081.atdsrvorg,
                                  d_bdbsa081.asitipcod,
                                  d_bdbsa081.atddat)
               returning d_bdbsa081.soctrfcod,
                         d_bdbsa081.soctrfvignum,
                         lr_erro.*

          if lr_erro.err = notfound then
             let l_inicio = "PSOTNVG00000000"
             let l_final = "PSOTNVG",l_data[7,10] clipped,
                                     l_data[4,5] clipped,
                                     l_data[1,2]
             let l_valor = null

             open cbdbsa081002 using l_inicio,
                                     l_final
             whenever error continue
             fetch cbdbsa081002 into l_valor,
                                     l_lixo
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> 100 then
                   display "Erro de SQL - cbdbsa081002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
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
             let d_bdbsa081.socopgitmvlr = l_valor  # Tabela nao vigente

          else

             call ctc00m15_retsocgtfcod(d_bdbsa081.vclcoddig)
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
             if ctx15g01_verif_adic(d_bdbsa081.atdsrvnum, d_bdbsa081.atdsrvano) then
                let l_soccstcod = 2   # Faixa 2 VALOR COM ADICIONAL
             else
                let l_soccstcod = 1   # Faixa 1 VALOR SEM ADICIONAL
             end if

             #display 'd_bdbsa081.soctrfvignum = ', d_bdbsa081.soctrfvignum
             #display 'ws.socgtfcod            = ', ws.socgtfcod
             #display 'l_soccstcod             = ', l_soccstcod

             call ctc00m15_retvlrvig(d_bdbsa081.soctrfvignum,
                                     ws.socgtfcod,
                                     l_soccstcod)
                  returning d_bdbsa081.socopgitmvlr, lr_erro.*

             if lr_erro.err <> 0 then
                if lr_erro.err = notfound then
                   let d_bdbsa081.socopgitmvlr = null
                else
                   display lr_erro.msgerr
                   display 'BDBSA081 / bdbsa081() / ',d_bdbsa081.soctrfvignum, ' / '
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

             call ctd00g00_vlrprmpgm(d_bdbsa081.atdsrvnum,
                                     d_bdbsa081.atdsrvano,
                                     l_param)
                  returning ws.vlrprm,
                            lr_erro.err

             let d_bdbsa081.socopgitmvlr = ctd00g00_compvlr(d_bdbsa081.socopgitmvlr, ws.vlrprm)

             if d_bdbsa081.socopgitmvlr is null then
                 let l_inicio = "PSOTNEN00000000"
                 let l_final = "PSOTNEN",l_data[7,10] clipped,
                                         l_data[4,5] clipped,
                                         l_data[1,2]
                 let l_valor = null

                 open cbdbsa081002 using l_inicio,
                                         l_final
                 whenever error continue
                 fetch cbdbsa081002 into l_valor,
                                         l_lixo
                 whenever error stop
                 if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode <> 100 then
                       display "Erro de SQL - cbdbsa081002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
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
                 let d_bdbsa081.socopgitmvlr = l_valor
             end if
          end if
       end if

       ### SERVICO CANCELADO
       if ws.atdetpcod = 5 and ws.atdcstvlr <> 0 then
          let d_bdbsa081.socopgitmvlr = d_bdbsa081.socopgitmvlr / 2
          #CT: 570311
          let d_bdbsa081.socopgitmvlr = d_bdbsa081.socopgitmvlr using "###########&.&&"
       end if
    end if

    if ws.vlr_bloqueio > 0 then
        let d_bdbsa081.socopgitmvlr = ws.vlr_bloqueio
    end if

    ### VERIFICA TIPO DE SERVICO
    let d_bdbsa081.srvtipabvdes = "NAO ENCONTRADO"
    open  cbdbsa081012 using d_bdbsa081.atdsrvorg
    fetch cbdbsa081012 into  d_bdbsa081.srvtipabvdes
    close cbdbsa081012

    let d_bdbsa081.quebra = d_bdbsa081.atdprscod + d_bdbsa081.ciaempcod

    output to report bdbsa081_rel( d_bdbsa081.* )

    initialize d_bdbsa081.* , ws.*  to null

 end foreach

 finish report bdbsa081_rel

 if ws_flglog <> 0 then
    #------------------------------------------------------------------
    # E-MAIL log
    #------------------------------------------------------------------
    let ws_nometxt   = m_path clipped,"/LOGOP", today using "ddmmyy" , ".txt"
    unload to ws_nometxt select * from tblog

    # PSI 185035 - Inicio
    let ws_run = "LOGOP de ",today, "' "
    let l_retorno = ctx22g00_envia_email("BDBSA081",
                                         ws_run,
                                         ws_nometxt)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro ao envia email(ctx21g00)-",ws_nometxt
       else
          display "Nao ha email cadastrado para o modulo BDBSA081 "
       end if
    end if
    # PSI 185035 - Final

    #let ws_run =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
    #              " -s 'LOGOP de ",today, "' ",
    #              "agostinho_wagner/spaulo_info_sistemas@u55 < ",
    #              ws_nometxt clipped
    #run ws_run
 end if

end function #  bdbsa081

#---------------------------------------------------------------------------
 function  bdbsa081_log(wr_linlog)
#---------------------------------------------------------------------------
 define wr_linlog char(300)



 if ws_flglog = 0 then
    let ws_flglog = 1
    create temp table tblog (linlog char(300)) with no log
 end if
 insert into tblog values (wr_linlog)

end function #  bdbsa081_log

#---------------------------------------------------------------------------
 report bdbsa081_rel(r_bdbsa081)
#---------------------------------------------------------------------------

 define r_bdbsa081   record
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
    count            integer
 end record

 define ws_fase      integer

 define l_atdsrvnum     like dbscadtippgt.nrosrv
 define l_atdsrvano     like dbscadtippgt.anosrv
 define l_pgttipcodps   like dbscadtippgt.pgttipcodps
 define l_empcod        like dbscadtippgt.empcod
 define l_succod        like dbscadtippgt.succod
 define l_cctcod        like dbscadtippgt.cctcod
 define l_retorno       smallint
 define l_mensagem      char(60)
 define l_data          char(20)

 define m_atdsrvnum     like dbsmcctrat.atdsrvnum
 define m_atdsrvano     like dbsmcctrat.atdsrvano

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 order by  r_bdbsa081.ciaempcod,
           r_bdbsa081.atdprscod,
           r_bdbsa081.quebra,
           r_bdbsa081.srvtipabvdes,
           r_bdbsa081.c24evtcod,
           r_bdbsa081.atdsrvnum,
           r_bdbsa081.atdsrvano


 format

    before group of r_bdbsa081.quebra    ### atdprscod
       delete from tbtemp_op
       delete from tbtemp_ap

       # definir empresa da OP, empresa do primeiro item
       if m_empcod is null or m_empcod != r_bdbsa081.ciaempcod
          then
          let m_empcod = r_bdbsa081.ciaempcod
       end if

       begin work
       let ws.transacao = 1
          if r_bdbsa081.c24evtcod is not null  and
             r_bdbsa081.c24evtcod <> 0         then
             let ws.socopgnum = 0
          else
             select max(socopgnum)
               into ws.socopgnum
               from dbsmopg
              where pstcoddig     =  r_bdbsa081.atdprscod
                and socopgsitcod  =  7
                and soctip        =  1   # P.Socorro

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
             let ws.time         = time
             let ws.hora         = ws.time[1,5]
             let ws.socfatitmqtd = 0
             let ws.socfattotvlr = 0

             #PSI 197858 Priscila - Para testes!!!
             #ha uma falha no programa que sempre le a ultima OP para
             # prestador e utiliza esse dados para a insercao da proxima
             # so que ha prestadores q nunca tiveram OP geradas e nao ha
             # tratamento para isto
             #if ws.cgccpfnum is null or ws.cgccpfnum = "" then
             #   let ws.cgccpfnum = '2235449'
             #   let ws.cgccpfdig = '64'
             #   let ws.socopgfavnom_fav = 'para teste bdbsa081'
             #   let ws.socpgtopccod_fav = 1
             #   let ws.pestip_fav = 'J'
             #   let ws.cgccpfnum_fav = '2235449'
             #   let ws.cgccpfdig_fav = '64'
             #end if

             call ctd12g00_dados_pst(3, r_bdbsa081.atdprscod)
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
                                  r_bdbsa081.atdprscod,
                                  ws.segnumdig        ,
                                  ws.corsus           ,
                                  ws_socfatentdat     ,
                                  ws_socfatpgtdat     ,
                                  ws.socfatitmqtd     ,   # qtd.itens
                                  null                ,   # qtd.relatorio
                                  ws.socfattotvlr     ,   # vlr total
                                  m_empcod ,
                                  ws.cctcod,
                                  r_bdbsa081.pestip   ,
                                  ws.cgccpfnum        ,
                                  ws.cgcord           ,
                                  ws.cgccpfdig        ,
                                  9                   ,   # automatica OK!
                                  today               ,
                                  999999              ,   # matricula
                                  r_bdbsa081.soctrfcod,
                                  ws.succod,
                                  ws.socpgtdoctip,
                                  ws_socfatentdat     ,
                                  ws.pgtdstcod        ,
                                  2                   ,   # geracao automatica
                                  1                   )   # tipo OP

             if sqlca.sqlcode  <>  0   then
                #display "ws.socopgnum: ", ws.socopgnum,
                #"r_bdbsa081.atdprscod: ", r_bdbsa081.atdprscod,
                #"ws_socfatentdat: ", ws_socfatentdat,
                #"ws_socfatpgtdat: ", ws_socfatpgtdat,
                #"ws.socfatitmqtd: ", ws.socfatitmqtd,
                #"ws.socfattotvlr: ", ws.socfattotvlr,
                #"r_bdbsa081.pestip: ", r_bdbsa081.pestip,
                #"ws.cgccpfnum: ", ws.cgccpfnum,
                #"ws.cgccpfdig: ", ws.cgccpfdig
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

          end if
          whenever error stop


    after group of r_bdbsa081.quebra    ### atdprscod
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
       let ws_nometxt   = m_path clipped,"/OPAUTO", r_bdbsa081.atdprscod using "&&&&&&" , ".txt"
       select count(*)
         into ws.count
         from tbtemp_op

       if ws.count is not null and
          ws.count > 0         then
          declare cbdbsa081019 cursor for
           select * from tbtemp_op
            order by socopgitmnum

	    let l_data = current
	    display "Inicou Criacao de OP: " , l_data
       start report rel_tempop to ws_nometxt

       foreach cbdbsa081019 into  r_tempop.*
          output to report rel_tempop( r_tempop.* )
       end foreach

       finish report rel_tempop
       let l_data = current
	    display "Inicou Criacao de OP: ", l_data

          call ctb11m17(ws.socopgnum,r_bdbsa081.atdprscod,"E","B")
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
       # let ws_run =  "uuencode ",ws_nometxt clipped," ",ws_nometxt clipped,
       #               " | mailx -s 'OP-PRESTADOR ",
       #               r_bdbsa081.atdprscod using "#&&&&&",
       #               " de ",ws_socfatentdat, "' ",
       #               r_bdbsa081.maides clipped
       # run ws_run

       # PSI 185035 - Inicio
       let ws_run = "OP AUTO PRESTADOR", r_bdbsa081.atdprscod using "#&&&&&"
       let l_retorno = ctx22g00_envia_email("BDBSA081",
                                            ws_run,
                                            ws_nometxt)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao envia email(ctx21g00)-",ws_nometxt
          else
             display "Nao ha email cadastrado para o modulo BDBSA081 "
          end if
       end if
       # PSI 185035 - Final

       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'OP-PRESTADOR ",
       #              r_bdbsa081.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "santos_neusa/spaulo_psocorro_controles@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'OP-PRESTADOR ",
       #              r_bdbsa081.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "silva_leandro/spaulo_psocorro_pagamentos@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------
       ### Verifica conteudo temporaria - AP
       let ws_nometxt = m_path clipped,"/APAUTO", r_bdbsa081.atdprscod using "&&&&&&" , ".txt"
       select count(*)
         into ws.count
         from tbtemp_ap

       if ws.count is not null and
          ws.count > 0         then
          declare cbdbsa081020 cursor for
           select * from tbtemp_ap
            order by srvtipabvdes, atdsrvnum

	       let l_data = current
	       display "Inicou envio de OP para prestador: ", l_data
          start report rel_tempap to ws_nometxt

          foreach cbdbsa081020 into  r_tempap.*
             output to report rel_tempap( r_tempap.* )
          end foreach

          finish report rel_tempap
          let l_data = current
          display "Finalizou envio de OP para prestador: ", l_data
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
       #                  r_bdbsa081.atdprscod using "#&&&&&",
       #                  " de ",ws_socfatentdat, "' ",
       #                  r_bdbsa081.maides clipped
       #    run ws_run

       # PSI 185035 - Inicio
       let ws_run = "AP AUTO PRESTADOR", r_bdbsa081.atdprscod using "#&&&&&"
       let l_retorno = ctx22g00_envia_email("BDBSA081",
                                            ws_run,
                                            ws_nometxt)
       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display "Erro ao envia email(ctx21g00)-",ws_nometxt
          else
             display "Nao ha email cadastrado para o modulo BDBSA081 "
          end if
       end if
       # PSI 185035 - Final


       #------------------------------------------------------------------
       # E-MAIL PORTO SOCORRO
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'AP-PRESTADOR ",
       #              r_bdbsa081.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "santos_neusa/spaulo_psocorro_controles@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       #------------------------------------------------------------------
       # E-MAIL SEGURANCA
       #------------------------------------------------------------------
       #let ws_run =  "mailx -s 'AP-PRESTADOR ",
       #              r_bdbsa081.atdprscod using "#&&&&&",
       #              " de ",ws_socfatentdat, "' ",
       #              "silva_leandro/spaulo_psocorro_pagamentos@u23 < ",
       #              ws_nometxt clipped
       #run ws_run

       #------------------------------------------------------------------
       # SALVA
       #------------------------------------------------------------------
       whenever error stop


    on every row
       if r_bdbsa081.c24fsecod is not null and
          r_bdbsa081.c24fsecod <> 2        and
          r_bdbsa081.c24fsecod <> 4 then

          initialize ws.c24evtrdzdes to null
          open  cbdbsa081009 using r_bdbsa081.c24evtcod
          fetch cbdbsa081009 into  ws.c24evtrdzdes
          close cbdbsa081009

          initialize ws.c24fsedes to null
          open  cbdbsa081010 using r_bdbsa081.c24fsecod
          fetch cbdbsa081010 into  ws.c24fsedes
          close cbdbsa081010

          insert into tbtemp_ap
                         values ( r_bdbsa081.atdsrvorg,
                                  r_bdbsa081.atdsrvnum,
                                  r_bdbsa081.atdsrvano,
                                  r_bdbsa081.srvtipabvdes,
                                  r_bdbsa081.atddat,
                                  r_bdbsa081.atdhor,
                                  r_bdbsa081.atdvclsgl,
                                  r_bdbsa081.vcldes,
                                  r_bdbsa081.vcllicnum,
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

          let r_bdbsa081.socopgitmvlr = r_bdbsa081.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

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
                                  r_bdbsa081.atdsrvnum,
                                  r_bdbsa081.atdsrvano,
                                  r_bdbsa081.socopgitmvlr,
                                  1 ,
                                  999999,
                                  "N" )

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGITM!"
             rollback work
             exit program (1)
          end if

          let ws.socfatitmqtd = ws.socfatitmqtd + 1
          let ws.socfattotvlr = ws.socfattotvlr + r_bdbsa081.socopgitmvlr
          open cbdbsa081021 using r_bdbsa081.atdsrvnum,
                                r_bdbsa081.atdsrvano
          fetch  cbdbsa081021 into l_atdsrvnum,
                                l_atdsrvano,
                                l_pgttipcodps,
                                l_empcod,
                                l_succod,
                                l_cctcod
          close cbdbsa081021


          if l_pgttipcodps = 3 then

                whenever error continue
                        open cbdbsa081022 using l_atdsrvnum,
                                                l_atdsrvano
                        fetch  cbdbsa081022 into m_atdsrvnum,
                                                 m_atdsrvano
                whenever error stop
                        if sqlca.sqlcode <> 0 then
                                display "Erro selecao dbsmcctrat"
                        end if

                        if m_atdsrvnum is null or m_atdsrvnum = 0 then

                                whenever error continue

                                let r_bdbsa081.socopgitmvlr = r_bdbsa081.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

                                        insert into dbsmcctrat values (l_atdsrvnum,
                                                                        l_atdsrvano,
                                                                        l_empcod,
                                                                        l_succod,
                                                                        l_cctcod,
                                                                        r_bdbsa081.socopgitmvlr)
                                whenever error stop
                                        if sqlca.sqlcode <> 0 then
                                                display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMCCTRAT"
                                                rollback work
                                                exit program (1)
                                        end if
                        end if
          end if

          whenever error continue

          let r_bdbsa081.socopgitmvlr = r_bdbsa081.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

          insert into tbtemp_op
                         values ( ws.socopgnum,
                                  ws.socopgitmnum,
                                  r_bdbsa081.srvtipabvdes,
                                  r_bdbsa081.atdsrvorg,
                                  r_bdbsa081.atdsrvnum,
                                  r_bdbsa081.atdsrvano,
                                  r_bdbsa081.atddat,
                                  r_bdbsa081.atdhor,
                                  r_bdbsa081.atdvclsgl,
                                  r_bdbsa081.vcldes,
                                  r_bdbsa081.vcllicnum,
                                  1,
                                  r_bdbsa081.socopgitmvlr)

          if sqlca.sqlcode  <>  0   then
             #WWWX      display "Erro (",sqlca.sqlcode,") inclusao tabela TEMPORARIA OK!"
             #WWWX      rollback work
             #WWWX      exit program (1)
             let ws_linlog = "tbtemp_op|",
                              sqlca.sqlcode,"|",
                              ws.socopgnum,"|",
                              ws.socopgitmnum,"|",
                              r_bdbsa081.srvtipabvdes clipped,"|",
                              r_bdbsa081.atdsrvorg,"|",
                              r_bdbsa081.atdsrvnum,"|",
                              r_bdbsa081.atdsrvano,"|",
                              r_bdbsa081.atddat,"|",
                              r_bdbsa081.atdhor,"|",
                              r_bdbsa081.atdvclsgl,"|",
                              r_bdbsa081.vcldes clipped,"|",
                              r_bdbsa081.vcllicnum,"|",
                              r_bdbsa081.socopgitmvlr,"|"
             call bdbsa081_log(ws_linlog)
          end if
       end if
       whenever error stop

    on last row
       if ws.transacao = 1 then
          commit work
       end if

 end report    ###  bdbsa081_rel


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

