#############################################################################
# Nome do Modulo: CTS11M00                                         Marcelo  #
#                                                                  Gilberto #
# Laudo para assistencia a passageiros - transporte                Nov/1996 #
#############################################################################
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                                                                           #
# 20/10/1998  PSI 6955-8   Gilberto     Retirar aviso que informa sobre     #
#                                       informacoes complementares no       #
#                                       historico (funcao CTS11G00).        #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 17/12/1998  PSI 6478-5   Gilberto     Inclusao da chamada da funcao de    #
#                                       cabecalho (CTS05G02) para atendi-   #
#                                       mento Porto Card VISA.              #
#---------------------------------------------------------------------------#
# 24/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 15/04/1999  PSI 7547-7   Gilberto     Adaptacao do laudo para utilizacao  #
#                                       com diversos tipos de assistencia   #
#                                       referentes ao transporte de passa-  #
#                                       geiros (passagem aerea, translado   #
#                                       de corpos, remocao hospitar, taxi). #
#---------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 10/06/1999  PSI 7547-7   Gilberto     Permitir digitacao de historico du- #
#                                       rante a inclusao do servico.        #
#---------------------------------------------------------------------------#
# 12/07/1999  CI  1012-0   Gilberto     Retirar critica que impede preen-   #
#                                       chimento do laudo quando domicilio  #
#                                       e ocorrencia forem os mesmos.       #
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8533-2   Wagner       Incluir acesso ao modulo cts14g00   #
#                                       para mensagens Cidade e UF.         #
#---------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 27/08/1999               Gilberto     Ampliacao da faixa final (limite)   #
#                                       de 169999 para 174999.              #
#---------------------------------------------------------------------------#
# 09/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03#
#                                       e padroniza gravacao do historico.  #
#---------------------------------------------------------------------------#
# 24/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do   #
#                                       historico.(Inclusao)                #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.           #
#---------------------------------------------------------------------------#
# 25/11/1999               Gilberto     Inclusao de validacao do ano do     #
#                                       veiculo.                            #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 04/02/2000  PSI 10206-7  Wagner       Incluir manutencao no campo nivel   #
#                                       prioridade atendimento.             #
#---------------------------------------------------------------------------#
# 09/03/2000  PSI 10246-6  Wagner       Limite cobertura para tipo assist.  #
#                                       16 - Rodoviario.                    #
#---------------------------------------------------------------------------#
# 16/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO      #
#                                       via funcao                          #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 01/09/2000  PSI 11459-6  Wagner       Incluir acionamento do servico apos #
#                                       retorno do historico p/atendentes.  #
#---------------------------------------------------------------------------#
# 25/09/2000  PSI 11253-4  Ruiz         Grava oficina na datmlcl para o     #
#                                       relatorio bdata080.                 #
#---------------------------------------------------------------------------#
# 29/11/2000               Raji         Inclusao do paramentro codigo da    #
#                                       oficina destino para laudos         #
#---------------------------------------------------------------------------#
# 14/02/2001               Raji         Atalho p/ visualizacao Pto Referecia#
#---------------------------------------------------------------------------#
# 16/02/2001  Psi 11254-2  Ruiz         Consulta o Condutor do Veiculo      #
#---------------------------------------------------------------------------#
# 10/10/2001  PSI 14063-5  Wagner       Liberacao clausula 35A igual 035    #
#---------------------------------------------------------------------------#
# 23/11/2001  PSI 14177-1  Ruiz         Permitir a assintencia p/ ramo 78   #
#                                       transporte.                         #
#---------------------------------------------------------------------------#
# 01/03/2002  Correio      Wagner       Incluir dptsgl psocor na pesquisa.  #
#---------------------------------------------------------------------------#
# 26/03/2002  AS           Ruiz         Enviar e-mail para todos os tipos   #
#                                       de S23.                             #
#---------------------------------------------------------------------------#
# 03/07/2002  PSI 15590-0  Wagner       Inclusao msg convenio/assuntos.     #
#---------------------------------------------------------------------------#
# 26/07/2002  PSI 15758-9  Ruiz         eliminar a confirmacao de servico   #
#                                       liberado(cts02m06).                 #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Carlos Ruiz                      OSF : 12718            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 27/12/2002       #
#  Objetivo       : Alterar Valor maximo para cobertura                     #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#                                                                           #
#                      * * * Alteracoes * * *                               #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 17/09/2003  Meta,Jefferson PSI175552 Inibir a chamada da funcao ctx17g00  #
#                            OSF26077  Inibicao das linhas 1689-1792        #
# ----------  -------------- --------- -------------------------------------#
# 17/11/2003  Meta,Paulo     PSI179345 Usar o atributo grlinf para controlar#
#                            OSF28851  se janela "confirma o acionamento do #
#                                      servico" deve ou nao ser aberta      #
# ------------------------------------------------------------------------- #
# 19/05/2005  Adriano, Meta  PSI191108 criado campo emeviacod               #
# ------------------------------------------------------------------------- #
# 07/03/2006  Priscila       Zeladoria Buscar data e hora do banco de dados #
# 11/12/2006  Ligia Mattge   CT6121350 Chamada do cts40g12 apos os updates  #
# 28/12/2006  Ligia Mattge             Implementacao de m_c24lclpdrcod e    #
#                                      chamada de cts02m00_valida_indexacao #
# ------------------------------------------------------------------------- #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
# 13/08/2009 Sergio Burini     PSI 244236 Inclus�o do Sub-Dairro            #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                      Projeto sucursal smallint         #
#############################################################################
# 28/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#---------------------------------------------------------------------------#
# 30/03/2012 Ivan, BRQ     PSI-2011-22603 Projeto alteracao cadastro de     #
#                                         destino.                          #
#---------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Inclusao regulacao via AW    #
#---------------------------------------------------------------------------#
# 10/122014  Alice-Fornax    CT-93387 - RDM 46951                           #
#############################################################################
# 25/03/2015 ST-2015-00006  Alberto/Roberto                                 #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

 define d_cts11m00   record
    servico          char (13)                         ,
    c24solnom        like datmligacao.c24solnom        ,
    nom              like datmservico.nom              ,
    doctxt           char (32)                         ,
    corsus           like datmservico.corsus           ,
    cornom           like datmservico.cornom           ,
    cvnnom           char (19)                         ,
    vclcoddig        like datmservico.vclcoddig        ,
    vcldes           like datmservico.vcldes           ,
    vclanomdl        like datmservico.vclanomdl        ,
    vcllicnum        like datmservico.vcllicnum        ,
    vclcordes        char (11)                         ,
    asitipcod        like datmservico.asitipcod        ,
    asitipabvdes     like datkasitip.asitipabvdes      ,
    asimtvcod        like datkasimtv.asimtvcod         ,
    asimtvdes        like datkasimtv.asimtvdes         ,
    refatdsrvorg     like datmservico.atdsrvorg        ,
    refatdsrvnum     like datmassistpassag.refatdsrvnum,
    refatdsrvano     like datmassistpassag.refatdsrvano,
    bagflg           like datmassistpassag.bagflg      ,
    dstlcl           like datmlcl.lclidttxt            ,
    dstlgdtxt        char (65)                         ,
    dstbrrnom        like datmlcl.lclbrrnom            ,
    dstcidnom        like datmlcl.cidnom               ,
    dstufdcod        like datmlcl.ufdcod               ,
    imdsrvflg        char (01)                         ,
    atdprinvlcod     like datmservico.atdprinvlcod     ,
    atdprinvldes     char (06)                         ,
    atdlibflg        like datmservico.atdlibflg        ,
    prsloccab        char (11)                         ,
    prslocflg        char (01)                         ,
    frmflg           char (01)                         ,
    atdtxt           char (48)                         ,
    atdlibdat        like datmservico.atdlibdat        ,
    atdlibhor        like datmservico.atdlibhor
 end record

 define w_cts11m00   record
    atdsrvnum        like datmservico.atdsrvnum   ,
    atdsrvano        like datmservico.atdsrvano   ,
    vclcorcod        like datmservico.vclcorcod   ,
    lignum           like datrligsrv.lignum       ,
    atdhorpvt        like datmservico.atdhorpvt   ,
    atdpvtretflg     like datmservico.atdpvtretflg,
    atddatprg        like datmservico.atddatprg   ,
    atdhorprg        like datmservico.atdhorprg   ,
    atdlibflg        like datmservico.atdlibflg   ,
    antlibflg        like datmservico.atdlibflg   ,
    atdlibdat        like datmservico.atdlibdat   ,
    atdlibhor        like datmservico.atdlibhor   ,
    atddat           like datmservico.atddat      ,
    atdhor           like datmservico.atdhor      ,
    cnldat           like datmservico.cnldat      ,
    atdfnlhor        like datmservico.atdfnlhor   ,
    atdfnlflg        like datmservico.atdfnlflg   ,
    atdetpcod        like datmsrvacp.atdetpcod    ,
    atdprscod        like datmservico.atdprscod   ,
    c24opemat        like datmservico.c24opemat   ,
    c24nomctt        like datmservico.c24nomctt   ,
    atdcstvlr        like datmservico.atdcstvlr   ,
    ligcvntip        like datmligacao.ligcvntip   ,
    data             like datmservico.atddat      ,
    hora             like datmservico.atdhor      ,
    funmat           like datmservico.funmat      ,
    trppfrdat        like datmassistpassag.trppfrdat,
    trppfrhor        like datmassistpassag.trppfrhor,
    atddmccidnom     like datmassistpassag.atddmccidnom,
    atddmcufdcod     like datmassistpassag.atddmcufdcod,
    atdocrcidnom     like datmlcl.cidnom,
    atdocrufdcod     like datmlcl.ufdcod,
    atddstcidnom     like datmassistpassag.atddstcidnom,
    atddstufdcod     like datmassistpassag.atddstufdcod,
    operacao         char (01),
    atdvclsgl        like datmsrvacp.atdvclsgl,
    srrcoddig        like datmsrvacp.srrcoddig,
    socvclcod        like datmservico.socvclcod,
    atdrsdflg        like datmservico.atdrsdflg
 end record

 define a_cts11m00   array[3] of record
    operacao         char (01)                    ,
    lclidttxt        like datmlcl.lclidttxt       ,
    lgdtxt           char (65)                    ,
    lgdtip           like datmlcl.lgdtip          ,
    lgdnom           like datmlcl.lgdnom          ,
    lgdnum           like datmlcl.lgdnum          ,
    brrnom           like datmlcl.brrnom          ,
    lclbrrnom        like datmlcl.lclbrrnom       ,
    endzon           like datmlcl.endzon          ,
    cidnom           like datmlcl.cidnom          ,
    ufdcod           like datmlcl.ufdcod          ,
    lgdcep           like datmlcl.lgdcep          ,
    lgdcepcmp        like datmlcl.lgdcepcmp       ,
    lclltt           like datmlcl.lclltt          ,
    lcllgt           like datmlcl.lcllgt          ,
    dddcod           like datmlcl.dddcod          ,
    lcltelnum        like datmlcl.lcltelnum       ,
    lclcttnom        like datmlcl.lclcttnom       ,
    lclrefptotxt     like datmlcl.lclrefptotxt    ,
    c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
    ofnnumdig        like sgokofi.ofnnumdig       ,
    emeviacod        like datmlcl.emeviacod       ,
    celteldddcod     like datmlcl.celteldddcod    ,
    celtelnum        like datmlcl.celtelnum       ,
    endcmp           like datmlcl.endcmp
 end record

 define a_cts11m00_bkp   array[3] of record
    operacao         char (01)                    ,
    lclidttxt        like datmlcl.lclidttxt       ,
    lgdtxt           char (65)                    ,
    lgdtip           like datmlcl.lgdtip          ,
    lgdnom           like datmlcl.lgdnom          ,
    lgdnum           like datmlcl.lgdnum          ,
    brrnom           like datmlcl.brrnom          ,
    lclbrrnom        like datmlcl.lclbrrnom       ,
    endzon           like datmlcl.endzon          ,
    cidnom           like datmlcl.cidnom          ,
    ufdcod           like datmlcl.ufdcod          ,
    lgdcep           like datmlcl.lgdcep          ,
    lgdcepcmp        like datmlcl.lgdcepcmp       ,
    lclltt           like datmlcl.lclltt          ,
    lcllgt           like datmlcl.lcllgt          ,
    dddcod           like datmlcl.dddcod          ,
    lcltelnum        like datmlcl.lcltelnum       ,
    lclcttnom        like datmlcl.lclcttnom       ,
    lclrefptotxt     like datmlcl.lclrefptotxt    ,
    c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
    ofnnumdig        like sgokofi.ofnnumdig       ,
    emeviacod        like datmlcl.emeviacod       ,
    celteldddcod     like datmlcl.celteldddcod    ,
    celtelnum        like datmlcl.celtelnum       ,
    endcmp           like datmlcl.endcmp
 end record

  define m_hist_cts11m00_bkp record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define arr_aux      smallint
 define w_retorno    smallint
 define l_clscod     like datrsrvcls.clscod

 define a_passag     array[15] of record
    pasnom           like datmpassageiro.pasnom,
     pasidd           like datmpassageiro.pasidd
 end record

 define l_resposta char (1)
 define m_sql      char (300)

 define aux_today     char (10)                 ,
        aux_hora      char (05)                 ,
        aux_ano       char (02)                 ,
        ws_cgccpfnum  like aeikcdt.cgccpfnum    ,
        ws_cgccpfdig  like aeikcdt.cgccpfdig

 define m_prep_sql    smallint ### PSI179345
 define m_aciona     char(01)    #PSI198714
 define m_srv_acionado smallint  #PSI198714
 define m_c24lclpdrcod like datmlcl.c24lclpdrcod
 define m_clscod like abbmclaus.clscod --varani
 define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint,
        m_grava_hist  smallint
 define m_mdtcod		like datmmdtmsg.mdtcod
 define m_pstcoddig     like dpaksocor.pstcoddig
 define m_socvclcod     like datkveiculo.socvclcod
 define m_srrcoddig     like datksrr.srrcoddig
 define l_vclcordes		char(20)
 define l_msgaltend	char(1500)
 define l_texto 		  char(200)
 define l_dtalt			date
 define l_hralt		  datetime hour to minute
 define l_lgdtxtcl	  char(80)
 define l_ciaempnom  char(50)
 define l_codrtgps   smallint
 define l_msgrtgps   char(100)

 define m_retctb83m00   smallint ##PSI207233
 define m_c24astcodflag like datmligacao.c24astcod #--PSI207233

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 # PSI-2013-00440PR
 define m_rsrchv       char(25)   # Chave de reserva regulacao
      , m_rsrchvant    char(25)   # Chave de reserva regulacao, anterior a situacao atual(A
      , m_altcidufd    smallint   # Alterou info de cidade/UF (true / false)
      , m_altdathor    smallint   # Alterou data/hora (true / false)
      , m_operacao     smallint
      , m_cidnom       like datmlcl.cidnom        # Nome cidade originalmente informada no servico
      , m_ufdcod       like datmlcl.ufdcod        # Codigo UF originalmente informado no servico
      , m_agncotdat    date                       # Data da cota atual AW (slot)
      , m_agncothor    datetime hour to second    # Hora da cota atual AW (slot)
      , m_agncotdatant date                       # Data da cota atual AW (slot)
      , m_agncothorant datetime hour to second    # Hora da cota atual AW (slot)
      , m_imdsrvflg    char(01)                   # Auxiliar para flag servico imediato
      , m_agendaw      smallint
      , m_ctgtrfcod    decimal(6,0)
 ###
 ### Inicio PSI179345 - Paulo
 ###
 #--------------------------#
 function cts11m00_prepare()
 #--------------------------#

 define l_sql    char(500)

 ### Inicio

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts11m00_001 from l_sql
 declare c_cts11m00_001 cursor for p_cts11m00_001
 ### Fim

 let l_sql = "select c24astcod from datmligacao ",
             " where atdsrvnum = ? ",
             " and  atdsrvano = ? "
 prepare p_cts11m00_002 from l_sql
 declare c_cts11m00_002 cursor for p_cts11m00_002

 let l_sql =  "select atdetpcod                          "
             ,"  from datmsrvacp                         "
             ," where atdsrvnum = ?                      "
             ,"   and atdsrvano = ?                      "
             ,"   and atdsrvseq = (select max(atdsrvseq) "
             ,"                      from datmsrvacp     "
             ,"                     where atdsrvnum = ?  "
             ,"                       and atdsrvano = ?) "

 prepare p_cts11m00_004 from l_sql
 declare c_cts11m00_004 cursor for p_cts11m00_004

 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAWATIVA' "
 prepare p_cts11m00_005 from l_sql
 declare c_cts11m00_005 cursor for p_cts11m00_005

  let l_sql = ' select clscod        ',
              '   from abbmclaus     ',
              '  where succod    = ? ',
              '    and aplnumdig = ? ',
              '    and itmnumdig = ? ',
              '    and dctnumseq = ? ',
              '    and clscod   in ("033","33R","035","055","35A","35R","044", ',
              '                     "046","047","44R","46R","47R","048","48R") ' #circular 310   --> varani
 prepare p_cts11m00_006 from l_sql
 declare c_cts11m00_006 cursor for p_cts11m00_006


 let m_prep_sql = true

 end function
 ###
 ### Final PSI179345 - Paulo
 ###

#---------------------------------------------------------------
 function cts11m00()
#---------------------------------------------------------------

 define ws           record
    atdetpcod        like datmsrvacp.atdetpcod,
    vclchsinc        like abbmveic.vclchsinc,
    vclchsfnl        like abbmveic.vclchsfnl,
    confirma         char (01),
    grvflg           smallint,
    asitipcod        like datmservico.asitipcod,
    histerr          smallint
 end record

 define x  char (01)

 define l_grlinf            like igbkgeral.grlinf

 define l_data         date,
        l_hora2        datetime hour to minute,
        l_acesso       smallint

 define l_clscod_old   like abbmclaus.clscod

#--------------------------------#


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     x  =  null
        let     l_grlinf  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        let     x  =  null

        initialize  ws.*  to  null

  let g_documento.atdsrvorg = 2
#--------------------------------#

 initialize m_rsrchv
          , m_altcidufd
          , m_altdathor
          , m_operacao
          , m_agncotdat
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant to null

 let int_flag   = false
 let m_srv_acionado = false
 let m_c24lclpdrcod = null
 initialize m_subbairro to null
 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let aux_today  = l_data
 let aux_hora   = l_hora2
 let aux_ano    = aux_today[9,10]

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts11m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false

 whenever error continue
 open c_cts11m00_005
 fetch c_cts11m00_005 into m_agendaw

 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR

 #--PSI207233
  open c_cts11m00_002  using g_documento.atdsrvnum,g_documento.atdsrvano
     fetch c_cts11m00_002 into m_c24astcodflag
  close c_cts11m00_002
#--PSI207233

 open window cts11m00 at 04,02 with form "cts11m00"
                      attribute(form line 1)
 if g_documento.atdsrvnum is not null then
    select asitipcod
         into ws.asitipcod
         from datmservico
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano
    ##PSI207233
    if  m_c24astcodflag = "S11"  or
        m_c24astcodflag = "S14"  or
        m_c24astcodflag = "S53"  or
        m_c24astcodflag = "S64"  then
            if ws.asitipcod = 10 then
               display "(F2)TipPgt(F3)Ref(F4)Cond(F5)Esp(F6)His(F7)Fun(F8)Dat(F9)Conclui(F10)Passag" to msgfun
            else
               display "(F1)Help(F2)TipPgt(F3)Ref(F4)Cond(F5)Esp(F6)His(F7)Fun(F9)Conclui(F10)Passag" to msgfun
            end if
    else
            if ws.asitipcod = 10 then
               display "(F3)Refer(F4)Condutor(F5)Espel(F6)Hist(F7)Fun(F8)Data(F9)Conclui(F10)Passag" to msgfun
            else
               display "(F1)Help(F3)Refer(F4)Condutor(F5)Espel(F6)Hist(F7)Fun(F9)Conclui(F10)Passag" to msgfun
            end if
    end if
##PSI207233
 else
    display "(F1)Help(F3)Ref(F4)Cond(F5)Esp(F6)His(F7)Fun(F9)Conclui(F10)Passag" to msgfun
 end if


 display "/" at 8,15
 display "-" at 8,23

 initialize d_cts11m00.* to null
 initialize w_cts11m00.* to null
 initialize ws.*         to null

 initialize a_cts11m00, a_cts11m00_bkp, m_hist_cts11m00_bkp to null
 initialize a_passag     to null

 let w_cts11m00.ligcvntip = g_documento.ligcvntip

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 select cpodes into d_cts11m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts11m00.ligcvntip

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts11m00()

    display by name d_cts11m00.*
    display by name d_cts11m00.c24solnom attribute (reverse)
    display by name d_cts11m00.cvnnom    attribute (reverse)
    display by name a_cts11m00[1].lgdtxt,
                    a_cts11m00[1].lclbrrnom,
                    a_cts11m00[1].cidnom,
                    a_cts11m00[1].ufdcod,
                    a_cts11m00[1].lclrefptotxt,
                    a_cts11m00[1].endzon,
                    a_cts11m00[1].dddcod,
                    a_cts11m00[1].lcltelnum,
                    a_cts11m00[1].lclcttnom,
                    a_cts11m00[1].celteldddcod,
                    a_cts11m00[1].celtelnum,
                    a_cts11m00[1].endcmp

    if d_cts11m00.atdlibflg = "N"   then
       display by name d_cts11m00.atdlibdat attribute (invisible)
       display by name d_cts11m00.atdlibhor attribute (invisible)
    end if

    if w_cts11m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    end if

    call modifica_cts11m00() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today, aux_hora )
       let g_rec_his = true
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then

#---------------------------------------------------------------
# Verifica se apolice tem clausula 35, 55 ou 35A se nao for cortesia
#---------------------------------------------------------------
       if g_documento.c24astcod <> "S93"  and
          g_documento.c24astcod <> "S53"  then
          call f_funapol_ultima_situacao (g_documento.succod,
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig)
            returning g_funapol.*

          if g_documento.ramcod <> 78   and  # socorro a transporte
             g_documento.ramcod <> 171  then # socorro a transporte

             whenever error continue
             open c_cts11m00_006 using g_documento.succod,
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig,
                                          g_funapol.dctnumseq

             foreach c_cts11m00_006 into m_clscod
             whenever error stop
                if sqlca.sqlcode = notfound  then
                   call cts08g01("A","N","NAO E' POSSIVEL REALIZAR A ASSISTENCIA!",
                                     " ","CLAUSULA ASSISTENCIA 24 HORAS COMPLETA",
                                         "NAO FOI CONTRATADA PARA ESTA APOLICE!")
                        returning ws.confirma
                   close window cts11m00
                   return
                end if

                if m_clscod = "033" then
                   let l_clscod_old = m_clscod
                end if

                if l_clscod_old = "033" and m_clscod = "035" then
                   let m_clscod = "033"
                end if
             end foreach
          end if
       end if

       let d_cts11m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                        " ", g_documento.ramcod    using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"

       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)

            returning d_cts11m00.nom      ,
                      d_cts11m00.corsus   ,
                      d_cts11m00.cornom   ,
                      d_cts11m00.cvnnom   ,
                      d_cts11m00.vclcoddig,
                      d_cts11m00.vcldes   ,
                      d_cts11m00.vclanomdl,
                      d_cts11m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts11m00.vclcordes
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then


       call figrc072_setTratarIsolamento()        --> 223689

       call cts05g04 (g_documento.prporg   ,
               g_documento.prpnumdig)
       returning d_cts11m00.nom      ,
                 d_cts11m00.corsus   ,
                 d_cts11m00.cornom   ,
                 d_cts11m00.cvnnom   ,
                 d_cts11m00.vclcoddig,
                 d_cts11m00.vcldes   ,
                 d_cts11m00.vclanomdl,
                 d_cts11m00.vcllicnum,
                 d_cts11m00.vclcordes
       if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Fun��o cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
            let int_flag = false
            clear form
            close window cts11m00
            return
       end if    --> 223689


       let d_cts11m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                        " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts11m00.doctxt = "Cartao..: ", g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts11m00.nom      ,
                      d_cts11m00.corsus   ,
                      d_cts11m00.cornom   ,
                      d_cts11m00.cvnnom   ,
                      d_cts11m00.vclcoddig,
                      d_cts11m00.vcldes   ,
                      d_cts11m00.vclanomdl,
                      d_cts11m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts11m00.vclcordes
    end if

    let d_cts11m00.prsloccab = "Prs.Local.:"
    let d_cts11m00.prslocflg = "N"

    let d_cts11m00.c24solnom   = g_documento.solnom

    display by name d_cts11m00.*
    display by name d_cts11m00.c24solnom attribute (reverse)
    display by name d_cts11m00.cvnnom    attribute (reverse)

    ###
    ### Inicio PSI179345 - Paulo
    ###

    open c_cts11m00_001

    whenever error continue
    fetch c_cts11m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts11m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts11m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window cts11m00
          return
       end if
    end if
    ###
    ### Final PSI179345 - Paulo
    ###

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call inclui_cts11m00() returning ws.grvflg

    if ws.grvflg = true  then
       -------------[ SUSEP DE LICITACAO - ROSANA 10/10/06 ]------------
       if d_cts11m00.corsus[1,2]  = "LI"   and
          g_documento.c24astcod   = "S53"  then
          call cts10g02_historico( w_cts11m00.atdsrvnum,
                                   w_cts11m00.atdsrvano,
                                   aux_today           ,
                                   aux_hora            ,
                                   g_issk.funmat       ,
               "** ANTENCAO, SUSEP DE LICITACAO, DEBITAR C.C. 13138 **",
                                   "","","","")
               returning ws.histerr
       end if
       ------------------------------------------------------------------
       call cts10n00(w_cts11m00.atdsrvnum, w_cts11m00.atdsrvano,
                     g_issk.funmat       , aux_today, aux_hora )

       #------------------------------------------------
       # Envia msg convenio/assunto se houver
       #------------------------------------------------
       {call ctx17g00_assist(g_documento.ligcvntip, ####psi175552####
                            g_documento.c24astcod,
                            w_cts11m00.atdsrvnum ,
                            w_cts11m00.atdsrvano ,
                            g_documento.lignum   ,
                            g_documento.succod   ,
                            g_documento.ramcod   ,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg   ,
                            g_documento.prpnumdig,
                            ws_cgccpfnum         ,
                            ws_cgccpfdig         )} ####psi175552 fim####

       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------

       if d_cts11m00.imdsrvflg =  "S"     and        # servico imediato
          d_cts11m00.atdlibflg =  "S"     and        # servico liberado
          d_cts11m00.prslocflg =  "N"     and        # prestador no local
          d_cts11m00.frmflg    =  "N"     and        # formulario
          m_aciona = 'N'                  then       # servico nao acionado auto
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
        if g_documento.c24astcod <> 'M15' and
           g_documento.c24astcod <> 'M20' and
           g_documento.c24astcod <> 'M23' and
           g_documento.c24astcod <> 'M33'then
          if l_acesso = true then
             call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                  returning ws.confirma

             if ws.confirma  =  "S"   then
                call cts00m02(w_cts11m00.atdsrvnum, w_cts11m00.atdsrvano, 1 )
             end if
          end if
       end if
      end if
       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = w_cts11m00.atdsrvnum
          and atdsrvano = w_cts11m00.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = w_cts11m00.atdsrvnum
                              and atdsrvano = w_cts11m00.atdsrvano)

       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts11m00.atdsrvnum
                             and atdsrvano = w_cts11m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts11m00.atdsrvnum,w_cts11m00.atdsrvano)
          end if
       end if
    end if
 end if

 clear form
 close window cts11m00

end function  ###  cts11m00

#---------------------------------------------------------------
 function consulta_cts11m00()
#---------------------------------------------------------------

 define ws           record
    passeq           like datmpassageiro.passeq,
    funmat           like isskfunc.funmat,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl,
    codigosql        integer,
    succod           like datrservapol.succod   ,
    ramcod           like datrservapol.ramcod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapcorg         like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum,
    empcod            like datmservico.empcod                         #Raul, Biz
 end record

 define l_errcod   smallint
       ,l_errmsg   char(80)

 initialize l_errcod, l_errmsg to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 initialize ws.*  to null

 select nom         ,
        vclcoddig   ,
        vcldes      ,
        vclanomdl   ,
        vcllicnum   ,
        corsus      ,
        cornom      ,
        vclcorcod   ,
        funmat      ,
        atddat      ,
        atdhor      ,
        atdlibflg   ,
        atdlibhor   ,
        atdlibdat   ,
        atdhorpvt   ,
        atdpvtretflg,
        atddatprg   ,
        atdhorprg   ,
        atdfnlflg   ,
        asitipcod   ,
        atdcstvlr   ,
        atdprinvlcod,
        ciaempcod ,
        empcod  ,            #Raul, Biz
        prslocflg
   into d_cts11m00.nom      ,
        d_cts11m00.vclcoddig,
        d_cts11m00.vcldes   ,
        d_cts11m00.vclanomdl,
        d_cts11m00.vcllicnum,
        d_cts11m00.corsus   ,
        d_cts11m00.cornom   ,
        w_cts11m00.vclcorcod,
        ws.funmat           ,
        w_cts11m00.atddat   ,
        w_cts11m00.atdhor   ,
        d_cts11m00.atdlibflg,
        d_cts11m00.atdlibhor,
        d_cts11m00.atdlibdat,
        w_cts11m00.atdhorpvt,
        w_cts11m00.atdpvtretflg,
        w_cts11m00.atddatprg,
        w_cts11m00.atdhorprg,
        w_cts11m00.atdfnlflg,
        d_cts11m00.asitipcod,
        w_cts11m00.atdcstvlr,
        d_cts11m00.atdprinvlcod,
        g_documento.ciaempcod,
        ws.empcod   ,   #Raul, Biz
        d_cts11m00.prslocflg
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = NOTFOUND then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 # PSI-2013-00440PR
 # identificar cota de agendamento ja realizado (ALT)
 call cts02m08_sel_cota(g_documento.atdsrvnum, g_documento.atdsrvano)
      returning l_errcod, l_errmsg, m_rsrchvant

 #if l_errcod = 0
 #   then
 #   display 'cts02m08_sel_cota ok'
 #else
 #   display 'cts02m08_sel_cota erro ', l_errcod
 #   display l_errmsg clipped
 #end if

 call cts02m08_id_datahora_cota(m_rsrchvant)
      returning l_errcod, l_errmsg, m_agncotdatant, m_agncothorant

 #if l_errcod != 0
 #   then
 #   display 'cts02m08_id_datahora_cota(consulta) erro no ID da cota'
 #   display l_errmsg clipped
 #end if
 # PSI-2013-00440PR

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts11m00[1].lclidttxt   ,
                         a_cts11m00[1].lgdtip      ,
                         a_cts11m00[1].lgdnom      ,
                         a_cts11m00[1].lgdnum      ,
                         a_cts11m00[1].lclbrrnom   ,
                         a_cts11m00[1].brrnom      ,
                         a_cts11m00[1].cidnom      ,
                         a_cts11m00[1].ufdcod      ,
                         a_cts11m00[1].lclrefptotxt,
                         a_cts11m00[1].endzon      ,
                         a_cts11m00[1].lgdcep      ,
                         a_cts11m00[1].lgdcepcmp   ,
                         a_cts11m00[1].lclltt      ,
                         a_cts11m00[1].lcllgt      ,
                         a_cts11m00[1].dddcod      ,
                         a_cts11m00[1].lcltelnum   ,
                         a_cts11m00[1].lclcttnom   ,
                         a_cts11m00[1].c24lclpdrcod,
                         a_cts11m00[1].celteldddcod,
                         a_cts11m00[1].celtelnum   ,
                         a_cts11m00[1].endcmp      ,
                         ws.codigosql,a_cts11m00[1].emeviacod

 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts11m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts11m00[1].brrnom,
                                a_cts11m00[1].lclbrrnom)
      returning a_cts11m00[1].lclbrrnom

 select ofnnumdig into a_cts11m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts11m00[1].lgdtxt = a_cts11m00[1].lgdtip clipped, " ",
                            a_cts11m00[1].lgdnom clipped, " ",
                            a_cts11m00[1].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Informacoes do local de destino
#--------------------------------------------------------------------
 if d_cts11m00.asitipcod <> 10  then  ###  Passagem Aerea
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            2)
                  returning a_cts11m00[2].lclidttxt   ,
                            a_cts11m00[2].lgdtip      ,
                            a_cts11m00[2].lgdnom      ,
                            a_cts11m00[2].lgdnum      ,
                            a_cts11m00[2].lclbrrnom   ,
                            a_cts11m00[2].brrnom      ,
                            a_cts11m00[2].cidnom      ,
                            a_cts11m00[2].ufdcod      ,
                            a_cts11m00[2].lclrefptotxt,
                            a_cts11m00[2].endzon      ,
                            a_cts11m00[2].lgdcep      ,
                            a_cts11m00[2].lgdcepcmp   ,
                            a_cts11m00[2].lclltt      ,
                            a_cts11m00[2].lcllgt      ,
                            a_cts11m00[2].dddcod      ,
                            a_cts11m00[2].lcltelnum   ,
                            a_cts11m00[2].lclcttnom   ,
                            a_cts11m00[2].c24lclpdrcod,
                            a_cts11m00[2].celteldddcod,
                            a_cts11m00[2].celtelnum   ,
                            a_cts11m00[2].endcmp     ,
                            ws.codigosql, a_cts11m00[2].emeviacod

 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[2].lclbrrnom = a_cts11m00[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts11m00[2].brrnom,
                                a_cts11m00[2].lclbrrnom)
      returning a_cts11m00[2].lclbrrnom

 select ofnnumdig into a_cts11m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 2

    if ws.codigosql = 0  then
       let a_cts11m00[2].lgdtxt = a_cts11m00[2].lgdtip clipped, " ",
                                  a_cts11m00[2].lgdnom clipped, " ",
                                  a_cts11m00[2].lgdnum using "<<<<#"

       let d_cts11m00.dstlcl    = a_cts11m00[2].lclidttxt
       let d_cts11m00.dstlgdtxt = a_cts11m00[2].lgdtxt
       let d_cts11m00.dstbrrnom = a_cts11m00[2].lclbrrnom
       let d_cts11m00.dstcidnom = a_cts11m00[2].cidnom
       let d_cts11m00.dstufdcod = a_cts11m00[2].ufdcod
    else
       error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

 let d_cts11m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into d_cts11m00.asitipabvdes
   from datkasitip
  where asitipcod = d_cts11m00.asitipcod

#---------------------------------------------------------------
# Obtencao dos dados da assistencia a passageiros
#---------------------------------------------------------------

 select refatdsrvnum, refatdsrvano,
        bagflg      , asimtvcod   ,
        atddmccidnom, atddmcufdcod,
        atddstcidnom, atddstufdcod,
        trppfrdat   , trppfrhor   ,
        atdsrvorg
   into d_cts11m00.refatdsrvnum   ,
        d_cts11m00.refatdsrvano   ,
        d_cts11m00.bagflg         ,
        d_cts11m00.asimtvcod      ,
        w_cts11m00.atddmccidnom   ,
        w_cts11m00.atddmcufdcod   ,
        w_cts11m00.atddstcidnom   ,
        w_cts11m00.atddstufdcod   ,
        w_cts11m00.trppfrdat      ,
        w_cts11m00.trppfrhor      ,
        d_cts11m00.refatdsrvorg
   from datmassistpassag, outer datmservico
  where datmassistpassag.atdsrvnum = g_documento.atdsrvnum  and
        datmassistpassag.atdsrvano = g_documento.atdsrvano  and
        datmservico.atdsrvnum = datmassistpassag.refatdsrvnum  and
        datmservico.atdsrvano = datmassistpassag.refatdsrvano

 if d_cts11m00.asitipcod = 10  then  ###  Passagem Aerea
    let d_cts11m00.dstcidnom = w_cts11m00.atddstcidnom
    let d_cts11m00.dstufdcod = w_cts11m00.atddstufdcod
 end if

#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------

 let d_cts11m00.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into d_cts11m00.asimtvdes
   from datkasimtv
  where asimtvcod = d_cts11m00.asimtvcod

#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 declare c_cts11m00_003 cursor for
    select pasnom, pasidd, passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
     order by passeq

 let arr_aux = 1

 foreach c_cts11m00_003 into a_passag[arr_aux].pasnom,
                               a_passag[arr_aux].pasidd,
                               ws.passeq
    let arr_aux = arr_aux + 1

    if arr_aux > 15  then
       exit foreach
    end if
 end foreach

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 let w_cts11m00.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                          g_documento.atdsrvano)

 call cts20g01_docto(w_cts11m00.lignum)
      returning g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum,
                g_documento.itaciacod

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts11m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                     " ", g_documento.ramcod    using "&&&&",
                                  " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts11m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                   " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 select ligcvntip,
        c24solnom, c24astcod
   into w_cts11m00.ligcvntip,
        d_cts11m00.c24solnom, g_documento.c24astcod
   from datmligacao
  where lignum = w_cts11m00.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts11m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts11m00.frmflg = "N"
 else
    let d_cts11m00.frmflg = "S"
 end if

 select cpodes into d_cts11m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts11m00.ligcvntip

 let d_cts11m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

#---------------------------------------------------------------
# Identificacao do ATENDENTE
#---------------------------------------------------------------

 let ws.funnom = "*** NAO CADASTRADO ***"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 let d_cts11m00.atdtxt = w_cts11m00.atddat         clipped, " ",
                         w_cts11m00.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

#---------------------------------------------------------------
# Descricao da COR do veiculo
#---------------------------------------------------------------

 select cpodes
   into d_cts11m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = w_cts11m00.vclcorcod

 if w_cts11m00.atdhorpvt is not null  or
    w_cts11m00.atdhorpvt =  "00:00"   then
    let d_cts11m00.imdsrvflg = "S"
 end if

 if w_cts11m00.atddatprg is not null   then
    let d_cts11m00.imdsrvflg = "N"
 end if

 if d_cts11m00.atdlibflg = "N"  then
    let d_cts11m00.atdlibdat = w_cts11m00.atddat
    let d_cts11m00.atdlibhor = w_cts11m00.atdhor
 end if

 let w_cts11m00.antlibflg = d_cts11m00.atdlibflg

 let d_cts11m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts11m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts11m00.atdprinvlcod

 let m_c24lclpdrcod = a_cts11m00[1].c24lclpdrcod

end function  ###  consulta_cts11m00

#---------------------------------------------------------------
 function modifica_cts11m00()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    codigosql        integer
 end record

 define hist_cts11m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key   char (01)

 define l_data    date,
        l_hora2   datetime hour to minute
       ,l_errcod   smallint
       ,l_errmsg   char(80)

 initialize l_errcod, l_errmsg  to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts11m00.*  to  null

        let     prompt_key  =  null

        initialize  ws.*  to  null

        initialize  hist_cts11m00.*  to  null

 initialize ws.*  to null

 call input_cts11m00() returning hist_cts11m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts11m00      to null
    initialize a_passag        to null
    initialize d_cts11m00.*    to null
    initialize w_cts11m00.*    to null
    initialize hist_cts11m00.* to null
    clear form
    return false
 end if

 #display 'cts11m00 - Modificar atendimento'

 whenever error continue

 begin work

 update datmservico set ( nom           ,
                          corsus        ,
                          cornom        ,
                          vclcoddig     ,
                          vcldes        ,
                          vclanomdl     ,
                          vcllicnum     ,
                          vclcorcod     ,
                          atdlibflg     ,
                          atdlibdat     ,
                          atdlibhor     ,
                          atdhorpvt     ,
                          atddatprg     ,
                          atdhorprg     ,
                          atdpvtretflg  ,
                          asitipcod     ,
                          atdprinvlcod  ,
                          prslocflg)
                      = ( d_cts11m00.nom,
                          d_cts11m00.corsus,
                          d_cts11m00.cornom,
                          d_cts11m00.vclcoddig,
                          d_cts11m00.vcldes,
                          d_cts11m00.vclanomdl,
                          d_cts11m00.vcllicnum,
                          w_cts11m00.vclcorcod,
                          d_cts11m00.atdlibflg,
                          d_cts11m00.atdlibdat,
                          d_cts11m00.atdlibhor,
                          w_cts11m00.atdhorpvt,
                          w_cts11m00.atddatprg,
                          w_cts11m00.atdhorprg,
                          w_cts11m00.atdpvtretflg,
                          d_cts11m00.asitipcod,
                          d_cts11m00.atdprinvlcod,
                          d_cts11m00.prslocflg)
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do servico.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmassistpassag set ( bagflg       ,
                               refatdsrvnum ,
                               refatdsrvano ,
                               asimtvcod    ,
                               atddmccidnom ,
                               atddmcufdcod ,
                               atddstcidnom ,
                               atddstufdcod ,
                               trppfrdat    ,
                               trppfrhor    )
                           = ( d_cts11m00.bagflg      ,
                               d_cts11m00.refatdsrvnum,
                               d_cts11m00.refatdsrvano,
                               d_cts11m00.asimtvcod   ,
                               w_cts11m00.atddmccidnom,
                               w_cts11m00.atddmcufdcod,
                               w_cts11m00.atddstcidnom,
                               w_cts11m00.atddstufdcod,
                               w_cts11m00.trppfrdat,
                               w_cts11m00.trppfrhor)
                         where atdsrvnum = g_documento.atdsrvnum  and
                               atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da assistencia.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 delete from datmpassageiro
  where atdsrvnum = g_documento.atdsrvnum
    and atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na substituicao da relacao de",
          " passageiros. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 15
    if a_passag[arr_aux].pasnom is null  or
       a_passag[arr_aux].pasidd is null  then
       exit for
    end if

    initialize ws.passeq to null

    select max(passeq)
      into ws.passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum  and
           atdsrvano = g_documento.atdsrvano

    if sqlca.sqlcode < 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do ultimo passageiro.",
             " AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if

    if ws.passeq is null  then
       let ws.passeq = 0
    end if

    let ws.passeq = ws.passeq + 1

    insert into datmpassageiro (atdsrvnum,
                                atdsrvano,
                                passeq,
                                pasnom,
                                pasidd)
                        values (g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                ws.passeq,
                                a_passag[arr_aux].pasnom,
                                a_passag[arr_aux].pasidd)

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao do ",
               arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 for arr_aux = 1 to 2
    if a_cts11m00[arr_aux].operacao is null  then
       let a_cts11m00[arr_aux].operacao = "M"
    end if

    if d_cts11m00.asitipcod = 10  and  arr_aux = 2   then
       exit for
    end if

    let a_cts11m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    call cts06g07_local(a_cts11m00[arr_aux].operacao,
                        g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        arr_aux,
                        a_cts11m00[arr_aux].lclidttxt,
                        a_cts11m00[arr_aux].lgdtip,
                        a_cts11m00[arr_aux].lgdnom,
                        a_cts11m00[arr_aux].lgdnum,
                        a_cts11m00[arr_aux].lclbrrnom,
                        a_cts11m00[arr_aux].brrnom,
                        a_cts11m00[arr_aux].cidnom,
                        a_cts11m00[arr_aux].ufdcod,
                        a_cts11m00[arr_aux].lclrefptotxt,
                        a_cts11m00[arr_aux].endzon,
                        a_cts11m00[arr_aux].lgdcep,
                        a_cts11m00[arr_aux].lgdcepcmp,
                        a_cts11m00[arr_aux].lclltt,
                        a_cts11m00[arr_aux].lcllgt,
                        a_cts11m00[arr_aux].dddcod,
                        a_cts11m00[arr_aux].lcltelnum,
                        a_cts11m00[arr_aux].lclcttnom,
                        a_cts11m00[arr_aux].c24lclpdrcod,
                        a_cts11m00[arr_aux].ofnnumdig,
                        a_cts11m00[arr_aux].emeviacod,
                        a_cts11m00[arr_aux].celteldddcod,
                        a_cts11m00[arr_aux].celtelnum,
                        a_cts11m00[arr_aux].endcmp)
              returning ws.codigosql

    if ws.codigosql is null   or
       ws.codigosql <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.codigosql, ") na alteracao do local de",
                " ocorrencia. AVISE A INFORMATICA!"
       else
          error " Erro (", ws.codigosql, ") na alteracao do local de",
                " destino. AVISE A INFORMATICA!"
       end if
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if w_cts11m00.antlibflg <> d_cts11m00.atdlibflg  then
    if d_cts11m00.atdlibflg = "S"  then
       let w_cts11m00.atdetpcod = 1
       let ws.atdetpdat = d_cts11m00.atdlibdat
       let ws.atdetphor = d_cts11m00.atdlibhor
    else
       let w_cts11m00.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts11m00.atdetpcod,
                               w_cts11m00.atdprscod,
                               " " ,
                               " ",
                               w_cts11m00.srrcoddig) returning w_retorno

    if w_retorno <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de",
             " acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

 #Projeto alteracao cadastro de destino
 if m_grava_hist then
    call cts11m00_grava_historico()
 end if

 whenever error stop

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  #Alteracao projeto cadastro de destino
  if w_cts11m00.atdfnlflg <> "S" then

     if cts34g00_acion_auto (g_documento.atdsrvorg,
                             a_cts11m00[1].cidnom,
                             a_cts11m00[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
        if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                            g_documento.c24astcod,
                                            d_cts11m00.asitipcod,
                                            a_cts11m00[1].lclltt,
                                            a_cts11m00[1].lcllgt,
                                            d_cts11m00.prslocflg,
                                            d_cts11m00.frmflg,
                                            g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            " ",
                                            "",
                                            "") then
           #servico nao pode ser acionado automaticamente
           #display "Servico acionado manual"
        else
           let m_aciona = 'S'
           #display "Servico foi para acionamento automatico!!"
        end if
     else
        error "Problemas com parametros de acionamento: ",
                             g_documento.atdsrvorg, "/",
                             a_cts11m00[1].cidnom, "/",
                             a_cts11m00[1].ufdcod sleep 4
     end if

  end if

 ###call cts02m00_valida_indexacao(g_documento.atdsrvnum,
 ###                                g_documento.atdsrvano,
 ###                                m_c24lclpdrcod,
 ###                                a_cts11m00[1].c24lclpdrcod)

 # PSI-2013-00440PR
 if m_agendaw = true
    then
    if m_operacao = 1  # ALT, gerou nova cota, baixa
       then

       call ctd41g00_baixar_agenda(m_rsrchv
                                 , g_documento.atdsrvano
                                 , g_documento.atdsrvnum)
            returning l_errcod, l_errmsg
    end if

    # so libera a anterior se baixou a nova
    if l_errcod = 0
       then
       call cts02m08_upd_cota(m_rsrchv, m_rsrchvant, g_documento.atdsrvnum
                            , g_documento.atdsrvano)

       # ALT, gerou nova cota e baixou, libera
       # Liberou sem regulacao e chave anterior existe, libera
       if (m_operacao = 1 or m_operacao = 2)
          then

          call ctd41g00_liberar_agenda(g_documento.atdsrvano
                                      ,g_documento.atdsrvnum
                                      ,m_agncotdatant
                                      ,m_agncothorant)
       end if
    end if
 end if
 # PSI-2013-00440PR

 return true

end function  ###  modifica_cts11m00


#-------------------------------------------------------------------------------
 function inclui_cts11m00()
#-------------------------------------------------------------------------------

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        passeq          like datmpassageiro.passeq ,
        ano             char (02)                  ,
        hoje            char (10)                  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        c24trxnum       like dammtrx.c24trxnum     ,  # Msg pager/email
        lintxt          like dammtrxtxt.c24trxtxt  ,
        titulo          like dammtrx.c24msgtit
 end record

 define hist_cts11m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define lr_clausula record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
 end record

 define l_data       date,
        l_hora2      datetime hour to minute
      , l_txtsrv         char (15)
      , l_reserva_ativa  smallint # Flag para idenitficar se reserva esta ativa
      , l_errcod         smallint
      , l_errmsg         char(80)

 initialize l_errcod, l_errmsg to null
 initialize  l_txtsrv, l_reserva_ativa to null
 initialize  ws.*  to  null
 initialize  hist_cts11m00.*  to  null
 initialize  lr_clausula.*  to  null

 while true
   initialize ws.*  to null

   let g_documento.acao    = "INC"
   let w_cts11m00.operacao = "i"

   call input_cts11m00() returning hist_cts11m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts11m00      to null
       initialize a_passag        to null
       initialize d_cts11m00.*    to null
       initialize w_cts11m00.*    to null
       initialize hist_cts11m00.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts11m00.data is null  then
       let w_cts11m00.data   = aux_today
       let w_cts11m00.hora   = aux_hora
       let w_cts11m00.funmat = g_issk.funmat
   end if

   if  d_cts11m00.frmflg = "S"  then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let ws.caddat = l_data
       let ws.cadhor = l_hora2
       let ws.cademp = g_issk.empcod
       let ws.cadmat = g_issk.funmat
   else
       initialize ws.caddat to null
       initialize ws.cadhor to null
       initialize ws.cademp to null
       initialize ws.cadmat to null
   end if

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let ws.hoje  = l_data
   let ws.ano    = ws.hoje[9,10]


   if  w_cts11m00.atdfnlflg is null  then
       let w_cts11m00.atdfnlflg = "N"
       let w_cts11m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

 #------------------------------------------------------------------------------
 # Busca clausula
 #------------------------------------------------------------------------------

  if g_documento.ramcod = 531 then
     call cty05g00_clausula_assunto(g_documento.c24astcod)
          returning lr_clausula.*
  end if

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "P" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS11M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum   = ws.lignum
   let w_cts11m00.atdsrvnum = ws.atdsrvnum
   let w_cts11m00.atdsrvano = ws.atdsrvano


 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts11m00.data         ,
                           w_cts11m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts11m00.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","","",""             ,
                           g_documento.succod      ,
                           g_documento.ramcod      ,
                           g_documento.aplnumdig   ,
                           g_documento.itmnumdig   ,
                           g_documento.edsnumref   ,
                           g_documento.prporg      ,
                           g_documento.prpnumdig   ,
                           g_documento.fcapacorg   ,
                           g_documento.fcapacnum   ,
                           "","","",""             ,
                           ws.caddat               ,
                           ws.cadhor               ,
                           ws.cademp               ,
                           ws.cadmat                )
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( w_cts11m00.atdsrvnum,
                                w_cts11m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24soltip
                                w_cts11m00.vclcorcod,
                                w_cts11m00.funmat   ,
                                d_cts11m00.atdlibflg,
                                d_cts11m00.atdlibhor,
                                d_cts11m00.atdlibdat,
                                w_cts11m00.data     ,     # atddat
                                w_cts11m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts11m00.atdhorpvt,
                                w_cts11m00.atddatprg,
                                w_cts11m00.atdhorprg,
                                "P"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts11m00.atdprscod,
                                w_cts11m00.atdcstvlr,
                                w_cts11m00.atdfnlflg,
                                w_cts11m00.atdfnlhor,
                                w_cts11m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts11m00.c24opemat,
                                d_cts11m00.nom      ,
                                d_cts11m00.vcldes   ,
                                d_cts11m00.vclanomdl,
                                d_cts11m00.vcllicnum,
                                d_cts11m00.corsus   ,
                                d_cts11m00.cornom   ,
                                w_cts11m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts11m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                d_cts11m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts11m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts11m00.atdprinvlcod,
                                g_documento.atdsrvorg   ) # ATDSRVORG
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if d_cts11m00.prslocflg = "S" then
      update datmservico set prslocflg = d_cts11m00.prslocflg,
                             socvclcod = w_cts11m00.socvclcod,
                             srrcoddig = w_cts11m00.srrcoddig
       where datmservico.atdsrvnum = w_cts11m00.atdsrvnum
         and datmservico.atdsrvano = w_cts11m00.atdsrvano
   end if
 #------------------------------------------------------------------------------
 # Insere Clausula X Servicos
 #------------------------------------------------------------------------------
   if lr_clausula.clscod is not null then
       call cts10g02_grava_servico_clausula(w_cts11m00.atdsrvnum
                                           ,w_cts11m00.atdsrvano
                                           ,g_documento.ramcod
                                           ,lr_clausula.clscod)
            returning ws.tabname,
                      ws.codigosql
       if  ws.codigosql  <>  0  then
           error " Erro (", ws.codigosql, ") na gravacao da",
                 " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
    end if


 #------------------------------------------------------------------------------
 # Gravacao dos dados da ASSISTENCIA A PASSAGEIROS
 #------------------------------------------------------------------------------
   insert into DATMASSISTPASSAG ( atdsrvnum    ,
                                  atdsrvano    ,
                                  bagflg       ,
                                  refatdsrvnum ,
                                  refatdsrvano ,
                                  asimtvcod    ,
                                  atddmccidnom ,
                                  atddmcufdcod ,
                                  atddstcidnom ,
                                  atddstufdcod ,
                                  trppfrdat    ,
                                  trppfrhor     )
                         values ( w_cts11m00.atdsrvnum   ,
                                  w_cts11m00.atdsrvano   ,
                                  d_cts11m00.bagflg      ,
                                  d_cts11m00.refatdsrvnum,
                                  d_cts11m00.refatdsrvano,
                                  d_cts11m00.asimtvcod   ,
                                  w_cts11m00.atddmccidnom,
                                  w_cts11m00.atddmcufdcod,
                                  w_cts11m00.atddstcidnom,
                                  w_cts11m00.atddstufdcod,
                                  w_cts11m00.trppfrdat   ,
                                  w_cts11m00.trppfrhor    )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao dos",
             " dados da assistencia. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


   for arr_aux = 1 to 15
       if  a_passag[arr_aux].pasnom is null  or
           a_passag[arr_aux].pasidd is null  then
           exit for
       end if

       initialize ws.passeq to null

       select max(passeq)
         into ws.passeq
         from DATMPASSAGEIRO
              where atdsrvnum = w_cts11m00.atdsrvnum
                and atdsrvano = w_cts11m00.atdsrvano

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na selecao do",
                 " ultimo passageiro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

       if  ws.passeq is null  then
           let ws.passeq = 0
       end if

       let ws.passeq = ws.passeq + 1

       insert into DATMPASSAGEIRO( atdsrvnum,
                                   atdsrvano,
                                   passeq   ,
                                   pasnom   ,
                                   pasidd    )
                           values( w_cts11m00.atdsrvnum    ,
                                   w_cts11m00.atdsrvano    ,
                                   ws.passeq               ,
                                   a_passag[arr_aux].pasnom,
                                   a_passag[arr_aux].pasidd )

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 2
       if  a_cts11m00[arr_aux].operacao is null  then
           let a_cts11m00[arr_aux].operacao = "I"
       end if

       if  d_cts11m00.asitipcod = 10  and  arr_aux = 2   then
           exit for
       end if
       let a_cts11m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       call cts06g07_local( a_cts11m00[arr_aux].operacao    ,
                            w_cts11m00.atdsrvnum            ,
                            w_cts11m00.atdsrvano            ,
                            arr_aux                         ,
                            a_cts11m00[arr_aux].lclidttxt   ,
                            a_cts11m00[arr_aux].lgdtip      ,
                            a_cts11m00[arr_aux].lgdnom      ,
                            a_cts11m00[arr_aux].lgdnum      ,
                            a_cts11m00[arr_aux].lclbrrnom   ,
                            a_cts11m00[arr_aux].brrnom      ,
                            a_cts11m00[arr_aux].cidnom      ,
                            a_cts11m00[arr_aux].ufdcod      ,
                            a_cts11m00[arr_aux].lclrefptotxt,
                            a_cts11m00[arr_aux].endzon      ,
                            a_cts11m00[arr_aux].lgdcep      ,
                            a_cts11m00[arr_aux].lgdcepcmp   ,
                            a_cts11m00[arr_aux].lclltt      ,
                            a_cts11m00[arr_aux].lcllgt      ,
                            a_cts11m00[arr_aux].dddcod      ,
                            a_cts11m00[arr_aux].lcltelnum   ,
                            a_cts11m00[arr_aux].lclcttnom   ,
                            a_cts11m00[arr_aux].c24lclpdrcod,
                            a_cts11m00[arr_aux].ofnnumdig,
                            a_cts11m00[arr_aux].emeviacod,
                            a_cts11m00[arr_aux].celteldddcod,
                            a_cts11m00[arr_aux].celtelnum,
                            a_cts11m00[arr_aux].endcmp)
            returning ws.codigosql

       if  ws.codigosql is null  or
           ws.codigosql <> 0     then
           if  arr_aux = 1  then
               error " Erro (", ws.codigosql, ") na gravacao do",
                     " local de ocorrencia. AVISE A INFORMATICA!"
           else
               error " Erro (", ws.codigosql, ") na gravacao do",
                     " local de destino. AVISE A INFORMATICA!"
           end if
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  w_cts11m00.atdetpcod is null  then
       if  d_cts11m00.atdlibflg = "S"  then
           let w_cts11m00.atdetpcod = 1
           let ws.etpfunmat = w_cts11m00.funmat
           let ws.atdetpdat = d_cts11m00.atdlibdat
           let ws.atdetphor = d_cts11m00.atdlibhor
       else
           let w_cts11m00.atdetpcod = 2
           let ws.etpfunmat = w_cts11m00.funmat
           let ws.atdetpdat = w_cts11m00.data
           let ws.atdetphor = w_cts11m00.hora
       end if
   else
      call cts10g04_insere_etapa(w_cts11m00.atdsrvnum,
                                 w_cts11m00.atdsrvano,
                                 1,
                                 w_cts11m00.atdprscod,
                                 " ",
                                 " ",
                                 w_cts11m00.srrcoddig )returning w_retorno

       if  w_retorno <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts11m00.cnldat
       let ws.atdetphor = w_cts11m00.atdfnlhor
       let ws.etpfunmat = w_cts11m00.c24opemat
   end if


   call cts10g04_insere_etapa(w_cts11m00.atdsrvnum,
                              w_cts11m00.atdsrvano,
                              w_cts11m00.atdetpcod,
                              w_cts11m00.atdprscod,
                              " ",
                              " ",
                              w_cts11m00.srrcoddig )returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if g_documento.succod    is not null  and
      g_documento.ramcod    is not null  and
      g_documento.aplnumdig is not null  then
      call cts10g02_grava_servico_apolice(w_cts11m00.atdsrvnum         ,
                                          w_cts11m00.atdsrvano         ,
                                          g_documento.succod   ,
                                          g_documento.ramcod   ,
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig,
                                          g_documento.edsnumref)
      returning ws.tabname,
                ws.codigosql
      if  ws.codigosql <> 0  then
          error " Erro (", ws.codigosql, ") na gravacao do",
                " relacionamento servico x apolice. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.prompt_key
          let ws.retorno = false
          exit while
      end if
      if g_documento.cndslcflg = "S"  then
         select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                into ws.cdtnom,ws.cgccpfnum,ws.cgccpfdig
                from tmpcondutor
         call grava_condutor(g_documento.succod,g_documento.aplnumdig,
                             g_documento.itmnumdig,ws.cdtnom,ws.cgccpfnum,
                             ws.cgccpfdig,"D","CENTRAL24H") returning ws.cdtseq
         let ws_cgccpfnum  = ws.cgccpfnum
         let ws_cgccpfdig  = ws.cgccpfdig
              # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
         insert into datrsrvcnd
                   (atdsrvnum,
                    atdsrvano,
                    succod   ,
                    aplnumdig,
                    itmnumdig,
                    vclcndseq)
            values (w_cts11m00.atdsrvnum ,
                    w_cts11m00.atdsrvano ,
                    g_documento.succod   ,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    ws.cdtseq             )
         if  sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na gravacao do",
                   " relacionamento servico x condutor. AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.prompt_key
             let ws.retorno = false
             exit while
        end if
      end if
   else
      # este registro indica um atendimento sem documento
      if g_documento.ramcod is not null then
         call cts10g02_grava_servico_apolice(w_cts11m00.atdsrvnum         ,
                                             w_cts11m00.atdsrvano         ,
                                             0   ,
                                             g_documento.ramcod   ,
                                             0,
                                             0,
                                             0)
       returning ws.tabname,
                 ws.codigosql

        if  ws.codigosql <> 0  then
            error " Erro (", ws.codigosql, ") na gravacao do",
                  " relac. servico x apolice-atd s/docto. AVISE A INFORMATICA!"
            rollback work
            prompt "" for char ws.prompt_key
            let ws.retorno = false
            exit while
        end if
      end if
   end if

   commit work
   if cty39g00_grava() then
   	 call cty39g00_inclui(w_cts11m00.atdsrvnum,
   	                      w_cts11m00.atdsrvano,
   	                      1)
   end if

   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(w_cts11m00.atdsrvnum,
                               w_cts11m00.atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( w_cts11m00.atdsrvnum,
                            w_cts11m00.atdsrvano,
                            w_cts11m00.data     ,
                            w_cts11m00.hora     ,
                            w_cts11m00.funmat   ,
                            hist_cts11m00.*      )
        returning ws.histerr

### if ws.histerr  = 0  then
### initialize g_documento.acao  to null
### end if


 #------------------------------------------------------------------------------
 # Envia e-mail e pager para assistencia 10 - Aviao
 #------------------------------------------------------------------------------
#if d_cts11m00.asitipcod = 10 then
    {whenever error continue ####psi175552####
    let ws.titulo = "AVISO_S23-",d_cts11m00.asitipabvdes clipped
    call ctx14g00_msg( 9999,
                       g_documento.lignum,
                       w_cts11m00.atdsrvnum,
                       w_cts11m00.atdsrvano,
                       ws.titulo ) #"AVISO_S23_AVIAO")
         returning ws.c24trxnum
    -------------------[ solicitacao da miriam - 25/07/03 ]----------------
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_ivan/spaulo_ct24hs_teleatendimento@u55",
                          "Ivan",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_lilian/spaulo_ct24hs_teleatendimento@u55",
                          "Lilian",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_maiara/spaulo_ct24hs_teleatendimento@u55",
                          "Maiara",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_roseli/spaulo_ct24hs_teleatendimento@u55",
                          "Roseli",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_willian/spaulo_ct24hs_teleatendimento@u55",
                          "Willian",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_henrique/spaulo_ct24hs_teleatendimento@u55",
                          "Henrique",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "macieira_carla/spaulo_ct24hs_teleatendimento@u55",
                          "Carla",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "menzani_murilo/spaulo_ct24hs_teleatendimento@u55",
                          "Murilo",
                          1) # 1-email
    -------------------------------------------------------------------------
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_michael/spaulo_ct24hs_teleatendimento@u55",
                          "Michael",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_ivens/spaulo_ct24hs_teleatendimento@u55",
                          "Ivens",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "correia_lucio/spaulo_psocorro_comercial@u23",
                          "Lucio Correia",
                          1) # 1-email

    -------------[ PAGER'S ]------------------
    call ctx14g00_msgdst( ws.c24trxnum,
                          "2048",
                          "pager",
                          2) # 2-pager
    call ctx14g00_msgdst( ws.c24trxnum,
                          "5994",
                          "pager",
                          2) # 2-pager
    call ctx14g00_msgdst( ws.c24trxnum,
                          "5981",
                          "pager",
                          2) # 2-pager
    -------------------------------------------
    let ws.lintxt = "Servico: ", g_documento.atdsrvorg using "&&",
                                 "/", w_cts11m00.atdsrvnum using "&&&&&&&",
                                 "-", w_cts11m00.atdsrvano using "&&"
    call ctx14g00_msgtxt( ws.c24trxnum,
                          ws.lintxt)
    let ws.lintxt = "Segurado: ", d_cts11m00.nom
    call ctx14g00_msgtxt( ws.c24trxnum,
                          ws.lintxt)
    let ws.lintxt = "Atendimento: ", w_cts11m00.data,
                    " AS ", w_cts11m00.hora
    call ctx14g00_msgtxt( ws.c24trxnum,
                          ws.lintxt)
    if g_documento.ramcod     is not null  and
       g_documento.succod     is not null  and
       g_documento.aplnumdig  is not null  then
       let ws.lintxt = "Suc: ", g_documento.succod    using "&&",
                    "  Ramo: ", g_documento.ramcod    using "&&&&",
                    "  Apl.: ", g_documento.aplnumdig using "<<<<<<<# #"
       if g_documento.itmnumdig is not null  and
          g_documento.itmnumdig <>  0        then
          let ws.lintxt = ws.lintxt clipped,
                         "  Item: ", g_documento.itmnumdig using "<<<<<# #"
       end if
       let ws.lintxt = ws.lintxt clipped,
                      " End: ", g_documento.edsnumref using "<<<<<<<<&"
       call ctx14g00_msgtxt( ws.c24trxnum,
                             ws.lintxt)
    end if
    update dammtrx
       set c24msgtrxstt = 9   # STATUS DE ENVIO
    where c24trxnum = ws.c24trxnum

 ## call ctx14g00_msgok(ws.c24trxnum )
    call ctx14g00_envia(ws.c24trxnum,"")
    whenever error stop} ####psi175552 fim####
#end if

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts11m00[1].cidnom,
                          a_cts11m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     #display "parametros acionamento ok!"
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         d_cts11m00.asitipcod,
                                         a_cts11m00[1].lclltt,
                                         a_cts11m00[1].lcllgt,
                                         d_cts11m00.prslocflg,
                                         d_cts11m00.frmflg,
                                         w_cts11m00.atdsrvnum,
                                         w_cts11m00.atdsrvano,
                                         " ",
                                         "",
                                         "") then
        #servico nao pode ser acionado automaticamente
        #display "Servico acionado manual"
     else
        let m_aciona = 'S'
        #display "Servico foi para acionamento automatico!!"
     end if
  else
     error "Problemas com parametros de acionamento: ",
                          g_documento.atdsrvorg, "/",
                          a_cts11m00[1].cidnom, "/",
                          a_cts11m00[1].ufdcod sleep 4
  end if

 #------------------------------------------------------------------------------
 # Insere inf. de pagamentos na tabela dbscadtippgt PSI207233
 #------------------------------------------------------------------------------
    if g_documento.c24astcod = "S11"  or
       g_documento.c24astcod = "S14"  or
       g_documento.c24astcod = "S53"  or
       g_documento.c24astcod = "S64"  then

         let g_cc.anosrv = w_cts11m00.atdsrvano
         let g_cc.nrosrv = w_cts11m00.atdsrvnum


         Insert into dbscadtippgt (anosrv,
                                   nrosrv,
                                   pgttipcodps,
                                   pgtmat,
                                   corsus,
                                   cadmat,
                                   cademp,
                                   caddat,
                                   atlmat,
                                   atlemp,
                                   atldat,
                                   cctcod,
                                   succod,
                                   empcod,
                                   pgtempcod)

                 values           (g_cc.anosrv,
                                   g_cc.nrosrv,
                                   g_cc.pgttipcodps,
                                   g_cc.pgtmat,
                                   g_cc.corsus,
                                   g_cc.cadmat,
                                   g_cc.cademp,
                                   g_cc.caddat,
                                   g_cc.atlmat,
                                   g_cc.atlemp,
                                   g_cc.atldat,
                                   g_cc.cctcod,
                                   g_cc.succod,
                                   g_cc.cademp,
                                   g_cc.pgtempcod)

    end if

    # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao
    #                    ainda ativa e fazer a baixa da chave no AW
    let l_txtsrv = "SRV ", w_cts11m00.atdsrvnum, "-", w_cts11m00.atdsrvano

    if m_agendaw = true
       then
       if m_operacao = 1  # obteve chave de regulacao
          then
          if ws.codigosql = 0  # sucesso na gravacao do servico
             then
             call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa

             if l_reserva_ativa = true
                then

                call ctd41g00_baixar_agenda(m_rsrchv, w_cts11m00.atdsrvano, w_cts11m00.atdsrvnum)
                     returning l_errcod, l_errmsg
             else

                error "Chave de regulacao inativa, selecione agenda novamente"

                let m_operacao = 0

                # obter a chave de regulacao no AW
                call cts02m08(w_cts11m00.atdfnlflg,
                              d_cts11m00.imdsrvflg,
                              m_altcidufd,
                              d_cts11m00.prslocflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts11m00[1].cidnom,
                              a_cts11m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts11m00.vclcoddig,
                              m_ctgtrfcod,
                              d_cts11m00.imdsrvflg,
                              a_cts11m00[1].c24lclpdrcod,
                              a_cts11m00[1].lclltt,
                              a_cts11m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts11m00.asitipcod,
                              "",   # natureza nao tem, identifica pelo asitipcod
                              "")   # sub-natureza nao tem, identifica pelo asitipcod
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              d_cts11m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor

                display by name d_cts11m00.imdsrvflg

                if m_operacao = 1
                   then

                   call ctd41g00_baixar_agenda(m_rsrchv, w_cts11m00.atdsrvano ,w_cts11m00.atdsrvnum)
                        returning l_errcod, l_errmsg
                end if
             end if

             if l_errcod = 0
                then
                call cts02m08_ins_cota(m_rsrchv, w_cts11m00.atdsrvnum, w_cts11m00.atdsrvano)
                     returning l_errcod, l_errmsg

             else
                #display 'cts11m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
             end if

          else
             #display l_txtsrv clipped, ' erro na inclusao, liberar agenda'

             call cts02m08_id_datahora_cota(m_rsrchv)
                  returning l_errcod, l_errmsg, m_agncotdat, m_agncothor

             #if l_errcod != 0
             #   then
             #   display 'ctd41g00_liberar_agenda NAO acionado, erro no ID da cota'
             #   display l_errmsg clipped
             #end if

             call ctd41g00_liberar_agenda(w_cts11m00.atdsrvano, w_cts11m00.atdsrvnum
                                        , m_agncotdat, m_agncothor)
          end if
       end if
    end if
    # PSI-2013-00440PR

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------

   let d_cts11m00.servico = g_documento.atdsrvorg using "&&",
                            "/", w_cts11m00.atdsrvnum using "&&&&&&&",
                            "-", w_cts11m00.atdsrvano using "&&"
   display by name d_cts11m00.servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function  ###  inclui_cts11m00

#---------------------------------------------------------------
 function input_cts11m00()
#---------------------------------------------------------------

 define ws           record
    succod           like datrservapol.succod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    segnumdig        like gsakend.segnumdig,
    refatdsrvorg     like datmservico.atdsrvorg,
    dddcod           like gsakend.dddcod,
    teltxt           like gsakend.teltxt,
    vclcordes        char (11),
    blqnivcod        like datkblq.blqnivcod,
    vcllicant        like datmservico.vcllicnum,
    maxcstvlr        like datmservico.atdcstvlr,
    msgcstvlr        char (40),
    snhflg           char (01),
    retflg           char (01),
    prpflg           char (01),
    confirma         char (01),
    dtparam          char (16),
    codigosql        integer,
    opcao            dec (1,0),
    opcaodes         char(20),
    codpais          char(11),
    despais          char(40),
    erro             smallint
 end record

 define hist_cts11m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define l_vclcoddig_contingencia like datmservico.vclcoddig

 define l_data        date,
        l_hora2       datetime hour to minute

 define l_sem_uso  char(01)
 define l_mens_vlr char (35)
 define l_acesso   smallint
 define l_qtde_atd integer
 define l_qtde_ag  integer
 define l_confirma char(01)
 define l_atdetpcod    like datmsrvacp.atdetpcod
 define l_status       smallint
 define l_atdsrvorg    like datmservico.atdsrvorg
 define l_flag_limite char(01)
 define l_limite_ut   smallint
 define l_limite_km   smallint
 define l_flag_atende char(01)

 define l_errcod   smallint
       ,l_errmsg   char(80)

 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
           ,m_ctgtrfcod
 to null

 initialize l_errcod, l_errmsg to null

 let l_sem_uso = null
 let l_atdetpcod   = null
 let l_status      = null
 let m_grava_hist  = false
 let l_atdsrvorg   = null
 let l_flag_limite = null
 let l_limite_ut   = null
 let l_limite_km   = null
 let l_flag_atende = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vclcoddig_contingencia  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts11m00.*  to  null

 initialize  ws.*  to  null

 initialize  hist_cts11m00.*  to  null

 initialize ws.*  to null
 initialize l_qtde_atd, l_confirma, l_clscod, l_qtde_ag  to null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let ws.dtparam        = l_data using "yyyy-mm-dd"
 let ws.dtparam[12,16] = l_hora2

 let ws.vcllicant      = d_cts11m00.vcllicnum

 let l_vclcoddig_contingencia = d_cts11m00.vclcoddig

 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if

 # situacao original do servico
 let m_imdsrvflg = d_cts11m00.imdsrvflg
 let m_cidnom = a_cts11m00[1].cidnom
 let m_ufdcod = a_cts11m00[1].ufdcod
 # PSI-2013-00440PR


 #display 'entrada do input, var null ou carregada na consulta'
 #display 'd_cts11m00.imdsrvflg :', d_cts11m00.imdsrvflg
 #display 'a_cts11m00[1].cidnom :', a_cts11m00[1].cidnom
 #display 'a_cts11m00[1].ufdcod :', a_cts11m00[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant

 input by name d_cts11m00.nom         ,
               d_cts11m00.corsus      ,
               d_cts11m00.cornom      ,
               d_cts11m00.vclcoddig   ,
               d_cts11m00.vclanomdl   ,
               d_cts11m00.vcllicnum   ,
               d_cts11m00.vclcordes   ,
               d_cts11m00.asitipcod   ,
               d_cts11m00.asimtvcod   ,
               d_cts11m00.refatdsrvorg,
               d_cts11m00.refatdsrvnum,
               d_cts11m00.refatdsrvano,
               d_cts11m00.bagflg      ,
               d_cts11m00.imdsrvflg   ,
               d_cts11m00.atdprinvlcod,
               d_cts11m00.atdlibflg   ,
               d_cts11m00.prslocflg   ,
               d_cts11m00.frmflg      without defaults

   before field nom
          display by name d_cts11m00.nom        attribute (reverse)

   after  field nom
          display by name d_cts11m00.nom

          if g_documento.acao = "CON" then
             error " Servico sendo consultado, nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                  returning ws.confirma

             # INICIO PSI-2013-00440PR
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03("S"                 ,
                              d_cts11m00.imdsrvflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg)
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg
	          else
                call cts02m08("S"                 ,
                              d_cts11m00.imdsrvflg,
                              m_altcidufd,
                              d_cts11m00.prslocflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts11m00[1].cidnom,
                              a_cts11m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts11m00.vclcoddig,
                              m_ctgtrfcod,
                              d_cts11m00.imdsrvflg,
                              a_cts11m00[1].c24lclpdrcod,
                              a_cts11m00[1].lclltt,
                              a_cts11m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts11m00.asitipcod,
                              "",   # natureza nao tem, identifica pelo asitipcod
                              "")   # sub-natureza nao tem, identifica pelo asitipcod
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              d_cts11m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             # FIM PSI-2013-00440PR

             next field nom
          end if

          if d_cts11m00.nom is null  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             if g_documento.succod    is not null  and
                g_documento.aplnumdig is not null  and
                g_documento.itmnumdig is not null  and
                w_cts11m00.atddmccidnom is null    and
                w_cts11m00.atddmcufdcod is null    then
                call f_funapol_ultima_situacao (g_documento.succod,
                                                g_documento.aplnumdig,
                                                g_documento.itmnumdig)
                                      returning g_funapol.*
                select segnumdig
                  into ws.segnumdig
                  from abbmdoc
                 where succod    = g_documento.succod     and
                       aplnumdig = g_documento.aplnumdig  and
                       itmnumdig = g_documento.itmnumdig  and
                       dctnumseq = g_funapol.dctnumseq

                select endcid, endufd
                  into w_cts11m00.atddmccidnom,
                       w_cts11m00.atddmcufdcod
                  from gsakend
                 where segnumdig = ws.segnumdig  and
                       endfld    = "1"
             end if

             { if g_documento.c24astcod <> 'M15' and
                       g_documento.c24astcod <> 'M20' and
                       g_documento.c24astcod <> 'M23' and
                       g_documento.c24astcod <> 'M33' then }
             call cts11m06(w_cts11m00.atddmccidnom,
                           w_cts11m00.atddmcufdcod,
                           w_cts11m00.atdocrcidnom,
                           w_cts11m00.atdocrufdcod,
                           w_cts11m00.atddstcidnom,
                           w_cts11m00.atddstufdcod)
                 returning w_cts11m00.atddmccidnom,
                           w_cts11m00.atddmcufdcod,
                           w_cts11m00.atdocrcidnom,
                           w_cts11m00.atdocrufdcod,
                           w_cts11m00.atddstcidnom,
                           w_cts11m00.atddstufdcod

             if w_cts11m00.atddmccidnom is null  or
                w_cts11m00.atddmcufdcod is null  or
                w_cts11m00.atdocrcidnom is null  or
                w_cts11m00.atdocrufdcod is null  or
                w_cts11m00.atddstcidnom is null  or
                w_cts11m00.atddstufdcod is null  then
                error " Localidades devem ser informadas para confirmacao",
                      " do direito de utilizacao!"
                next field nom
             end if
             { end if}

             if w_cts11m00.atddmccidnom = w_cts11m00.atdocrcidnom  and
                w_cts11m00.atddmcufdcod = w_cts11m00.atdocrufdcod  then
             #   error " Nao e' possivel a utilizacao da clausula de",
             #         " assistencia aos passageiros! "
                call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                              "A LOCAL DE DOMICILIO!","") returning ws.confirma
                if ws.confirma = "N"  then
                   next field nom
                end if
             end if

             let a_cts11m00[1].cidnom = w_cts11m00.atdocrcidnom
             let a_cts11m00[1].ufdcod = w_cts11m00.atdocrufdcod

             if d_cts11m00.asitipcod <> 10  then  ###  Passagem Aerea
                let a_cts11m00[2].cidnom = w_cts11m00.atddstcidnom
                let a_cts11m00[2].ufdcod = w_cts11m00.atddstufdcod
             end if
          end if

          if w_cts11m00.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                           " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                           "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                  returning ws.confirma

             # INICIO PSI-2013-00440PR
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts11m00.atdfnlflg,
                              d_cts11m00.imdsrvflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg)
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg
	          else
                call cts02m08(w_cts11m00.atdfnlflg,
                              d_cts11m00.imdsrvflg,
                              m_altcidufd,
                              d_cts11m00.prslocflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts11m00[1].cidnom,
                              a_cts11m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts11m00.vclcoddig,
                              m_ctgtrfcod,
                              d_cts11m00.imdsrvflg,
                              a_cts11m00[1].c24lclpdrcod,
                              a_cts11m00[1].lclltt,
                              a_cts11m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts11m00.asitipcod,
                              "",   # natureza nao tem, identifica pelo asitipcod
                              "")   # sub-natureza nao tem, identifica pelo asitipcod
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              d_cts11m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             # FIM PSI-2013-00440PR

             #next field nom
             next field frmflg
          end if

   before field corsus
          display by name d_cts11m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts11m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts11m00.corsus is not null  then
                select cornom
                  into d_cts11m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts11m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts11m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts11m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts11m00.cornom

   before field vclcoddig
          display by name d_cts11m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts11m00.vclcoddig

          # se outro processo nao obteve cat. tarifaria, obter
          if m_ctgtrfcod is null
             then
             # laudo auto obter cod categoria tarifaria
             call cts02m08_sel_ctgtrfcod(d_cts11m00.vclcoddig)
                  returning l_errcod, l_errmsg, m_ctgtrfcod
          end if

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts11m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts11m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts11m00.vclcoddig is null  or
                d_cts11m00.vclcoddig =  0     then
                call agguvcl() returning d_cts11m00.vclcoddig
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts11m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cts15g00(d_cts11m00.vclcoddig)
                 returning d_cts11m00.vcldes

             display by name d_cts11m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts11m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts11m00.vclanomdl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclcoddig
          end if

          if d_cts11m00.vclanomdl is null then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts11m00.vclcoddig,d_cts11m00.vclanomdl)=false  then
                error " Veiculo nao consta como fabricado em ",
                        d_cts11m00.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts11m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts11m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts11m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

        #---------------------------------------------------------------------
        # Chama verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if g_documento.aplnumdig   is null       and
           d_cts11m00.vcllicnum    is not null   then

           if d_cts11m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.snhflg to null

              call cts13g00(g_documento.c24astcod,
                            "", "", "", "",
                            d_cts11m00.vcllicnum,
                            "", "", "")
                  returning ws.blqnivcod, ws.snhflg

              if ws.blqnivcod  =  3   then
                 error " Bloqueio cadastrado nao permite atendimento para",
                       " este assunto/apolice!"
                 next field vcllicnum
              end if

              if ws.blqnivcod  =  2     and
                 ws.snhflg     =  "n"   then
                 error " Bloqueio necessita de permissao para atendimento!"
                 next field vcllicnum
              end if
           end if
        end if

   before field vclcordes
          display by name d_cts11m00.vclcordes attribute (reverse)

   after  field vclcordes
          display by name d_cts11m00.vclcordes

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vcllicnum
          end if

          if d_cts11m00.vclcordes is not null then
             let ws.vclcordes = d_cts11m00.vclcordes[2,9]

             select cpocod into w_cts11m00.vclcorcod
               from iddkdominio
              where cponom      = "vclcorcod"  and
                    cpodes[2,9] = ws.vclcordes

             if sqlca.sqlcode = notfound  then
                error " Cor fora do padrao!"
                call c24geral4()
                     returning w_cts11m00.vclcorcod, d_cts11m00.vclcordes

                if w_cts11m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informada!"
                   next field vclcordes
                else
                   display by name d_cts11m00.vclcordes
                end if
             end if
          else
             call c24geral4()
                  returning w_cts11m00.vclcorcod, d_cts11m00.vclcordes

             if w_cts11m00.vclcorcod  is null   then
                error " Cor do veiculo deve ser informada!"
                next field  vclcordes
             else
                display by name d_cts11m00.vclcordes
             end if
          end if

          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             call cts40g03_data_hora_banco(2)
                  returning l_data, l_hora2
             call cts11m04(g_documento.succod   , g_documento.aplnumdig,
                           g_documento.itmnumdig, l_data,g_documento.ramcod)
          else
             call cts11m04(g_documento.succod   , g_documento.aplnumdig,
                           g_documento.itmnumdig, w_cts11m00.atddat,
                           g_documento.ramcod)

             next field asimtvcod
          end if

   before field asitipcod
          display by name d_cts11m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts11m00.asitipcod

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if g_documento.c24astcod = "SDF" then
             	  let d_cts11m00.asitipcod = 5
             	  select asitipabvdes
             	    into d_cts11m00.asitipabvdes
             	    from datkasitip
                 where asitipcod = d_cts11m00.asitipcod  and
                       asitipstt = "A"
                 display by name d_cts11m00.asitipcod
                 display by name d_cts11m00.asitipabvdes
                 next field asimtvcod
             end if
             if d_cts11m00.asitipcod is null  then
                call ctn25c00(2) returning d_cts11m00.asitipcod

                if d_cts11m00.asitipcod is not null  then
                   select asitipabvdes
                     into d_cts11m00.asitipabvdes
                     from datkasitip
                    where asitipcod = d_cts11m00.asitipcod  and
                          asitipstt = "A"

                   display by name d_cts11m00.asitipcod
                   display by name d_cts11m00.asitipabvdes
                   next field asimtvcod
                else
                   next field asitipcod
                end if
             else
                select asitipabvdes
                  into d_cts11m00.asitipabvdes
                  from datkasitip
                 where asitipcod = d_cts11m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   call ctn25c00(2) returning d_cts11m00.asitipcod
                   next field asitipcod
                else
                   display by name d_cts11m00.asitipcod
                end if

                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = g_documento.atdsrvorg
                   and asitipcod = d_cts11m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada para",
                         " este servico!"
                   next field asitipcod
                end if
             end if
             display by name d_cts11m00.asitipabvdes
          end if

   before field asimtvcod
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts11m00.asitipcod = 11  then  ###  Remocao Hospitalar
                # o cara j� morreu nao precisa de diagnostico. Bia 28/07/06
             ## d_cts11m00.asitipcod = 12  then  ###  Traslado de Corpos
                call cts08g01("I","N",
                              "SOLICITE:ENVIO DE FAX C/ DIAGNOSTICO DO ",
                              " PACIENTE, FAX DA CARTA DO MEDICO COM   ",
                              "ASSINATURA E CRM E O TIPO DE AMBULANCIA.",
                              "   REGISTRE TAMBEM MOTIVO DA REMOCAO!   ")
                    returning ws.confirma
             end if
          end if

          display by name d_cts11m00.asimtvcod attribute (reverse)

   after  field asimtvcod
          display by name d_cts11m00.asimtvcod


          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts11m00.asimtvcod is null  then
                call cts11m03(d_cts11m00.asitipcod)
                     returning d_cts11m00.asimtvcod
                if d_cts11m00.asimtvcod is null then
                   next field asimtvcod
                else
                	 select asimtvdes --descricao
                	   into d_cts11m00.asimtvdes
                	   from datkasimtv
                	  where asimtvcod = d_cts11m00.asimtvcod  and
                	        asimtvsit = "A"
                	  display by name d_cts11m00.asimtvcod
                	  display by name d_cts11m00.asimtvdes
                end if
             else
                 if d_cts11m00.asimtvcod is not null  then
                   select asimtvdes --descricao
                     into d_cts11m00.asimtvdes
                     from datkasimtv
                    where asimtvcod = d_cts11m00.asimtvcod  and
                          asimtvsit = "A"
                 end if
                  --
                 display by name d_cts11m00.asimtvcod
                 display by name d_cts11m00.asimtvdes

                if sqlca.sqlcode = notfound  then
                   error " Motivo invalido!"
                   call cts11m03(d_cts11m00.asitipcod)
                       returning d_cts11m00.asimtvcod
                   next field asimtvcod
                else
                   display by name d_cts11m00.asimtvcod
                   display by name d_cts11m00.asimtvdes
                end if

                select asimtvcod
                  from datrmtvasitip
                where asitipcod = d_cts11m00.asitipcod
                   and asimtvcod = d_cts11m00.asimtvcod

                if sqlca.sqlcode = notfound  then
                   error " Motivo nao pode ser informado para este tipo",
                         " de assistencia!"
                   next field asimtvcod
                end if

             end if
             if not cty31g00_nova_regra_clausula(g_documento.c24astcod) then
                  if d_cts11m00.asimtvcod = 10 and m_clscod <> "047" then
                     call cts08g01("A","N","ESTA ASSIST�NCIA SOMENTE ",
                                           "COM A CLAUSULA 047 CONTRATADA",
                                           "",
                                           "")
                                   returning ws.confirma
                     next field asimtvcod
                  end if
             end if

          display by name d_cts11m00.asimtvcod
          display by name d_cts11m00.asimtvdes
          if cty31g00_valida_clausula() and
          	 g_nova.perfil <> 2         then
              #-----------------------------------------------------------
              # Recupera o Limite de Kilometragem
              #-----------------------------------------------------------
              call cty31g00_valida_km(g_documento.c24astcod ,
                                      g_nova.clscod         ,
                                      g_nova.perfil         ,
                                      d_cts11m00.asitipcod  ,
                                      d_cts11m00.asimtvcod)
              returning l_limite_km,
                        l_flag_atende
              if l_flag_atende = "N" then
                  next field asimtvcod
              end if
               if g_documento.c24astcod = "S81" then
                  let l_qtde_atd = 0
                  let l_qtde_ag  = 0
                  #-----------------------------------------------------------
                  # Recupera o Limite de Utilizacao
                  #-----------------------------------------------------------
                  call cty31g00_valida_limite(g_documento.c24astcod,
                                              g_nova.clscod        ,
                                              g_nova.perfil        ,
                                              "")
                  returning l_limite_ut
                  #-----------------------------------------------------------
                  # Recupera A Quantidade de Atendimentos por Motivo
                  #-----------------------------------------------------------
                  call cty26g01_qtd_servico_mtv(g_documento.ramcod
                                               ,g_documento.succod
                                               ,g_documento.aplnumdig
                                               ,g_documento.itmnumdig
			                                         ,'' ,''
			                                         ,g_nova.dt_cal
			                                         ,g_documento.c24astcod
                                               ,d_cts11m00.asitipcod
                                               ,d_cts11m00.asimtvcod)
                  returning l_qtde_atd
                  #-----------------------------------------------------------
                  # Obter a Quantidade de Atendimentos Agregados
                  #-----------------------------------------------------------
                  let l_qtde_ag = cty31g00_calcula_agregacao (g_documento.ramcod      ,
                                                              g_documento.succod      ,
                                                              g_documento.aplnumdig   ,
                                                              g_documento.itmnumdig   ,
                                                              g_documento.c24astcod   ,
                                                              g_nova.dt_cal           )
                  let l_qtde_atd = l_qtde_atd + l_qtde_ag
                  if l_qtde_atd >= l_limite_ut then
                      call cts08g01("A","N","",  "CONSULTE A COORDENACAO ", "PARA ENVIO DE ATENDIMENTO ","")
                      returning ws.confirma
                      next field asimtvcod
             		  end if
               end if
          else

                        --varani1904
               call cty26g00_srv_pass(g_documento.ramcod    ## JUNIOR (FORNAX)
	                             ,g_documento.succod
	                             ,g_documento.aplnumdig
	                             ,g_documento.itmnumdig
	                             ,g_documento.c24astcod
	                             ,d_cts11m00.asitipcod
                                     ,d_cts11m00.asimtvcod)
                      returning l_flag_limite, l_clscod
               if l_flag_limite = "S" then
                  call cts08g01("A","N","",
					     		   "LIMITE JA UTILIZADO PARA O MOTIVO",
				                                "CONTINUE O ATENDIMENTO ATRAVES",
					     		   "DO CODIGO DE CORTESIA - S93")
				                       returning ws.confirma
				                  next field asimtvcod
	             end if
               if (l_clscod <> '044' and
				          l_clscod <> '44R' and
				          l_clscod <> '048' and
				          l_clscod <> '48R') or
				          l_clscod is null then
		               call cts45g00_limites_cob(1
		                                          ,l_sem_uso
		                                          ,l_sem_uso
		                                          ,g_documento.succod
		                                          ,g_documento.aplnumdig
		                                          ,g_documento.itmnumdig
		                                          ,d_cts11m00.asitipcod
		                                          ,g_documento.ramcod
		                                          ,d_cts11m00.asimtvcod
		                                          ,w_cts11m00.ligcvntip
		                                          ,l_sem_uso)
		                    returning ws.maxcstvlr

		               let l_mens_vlr = "LIMITE DE R$ ",ws.maxcstvlr using "<,<<<.<<"," PARA "

		               if ws.maxcstvlr > 0 then
		                  if d_cts11m00.asimtvcod = 3 then
		                   call cts08g01("A","N","",
		                                 l_mens_vlr,
		                                 "RECUPERACAO DE VEICULO","")
		                       returning ws.confirma
		                  else
		                     if d_cts11m00.asimtvcod = 10     and
				                    g_documento.c24astcod = "S23" and
				                    g_documento.ciaempcod = 1     then
				                    let l_qtde_atd = 0
		                                    call cts11m00_mtv_cls46_47(g_documento.ciaempcod,
		                                                               d_cts11m00.asimtvcod)
				                    returning l_qtde_atd
				                 else
				                    let l_qtde_atd = 0
				                 end if
		                                 if l_qtde_atd = 1 then
		                                    let l_confirma = cts08g01('A'
				                                             ,'N'
		                                                 ,''
		                                                 ,'LIMITE EXCEDIDO PARA A ASSISTENCIA DE, '
				                 			                      ,'TAXI AMIGO'
		                                                 ,'')
		                                    next field asimtvcod
				                             end if
		                           if d_cts11m00.asimtvcod = 10 and m_clscod = "047" then
		                              call cts08g01("A","N","ESTA ASSIST�NCIA DEVE SER REALIZADA",
		                                                    "APENAS DENTRO DO MUNICIPIO DE RESIDENCIA",
		                                                    "E EST� LIMITADO A 50 KM.",
		                                                    "")
		                                         returning ws.confirma
		                           else
		                           	   if d_cts11m00.asimtvcod = 12     and
		                           	   	  m_clscod = "047"              and
		                           	   	  g_documento.c24astcod = "S23" then
		                                    call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO ",
		                                                  "AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL ", "CLASSE ECONOMICA, IDA E VOLTA.")
		                                    returning ws.confirma
		                           	   else
		                                   let ws.msgcstvlr = "AO VALOR MAXIMO DE R$ ",
		                                             ws.maxcstvlr using "<<<,<<<,<<&.&&"
		                                   call cts08g01("A","N","","LIMITE DE COBERTURA RESTRITO",
		                                              ws.msgcstvlr,"")
		                                              returning ws.confirma
		                               end if
		                           end if
		                  end if
		               else
		                    if ws.maxcstvlr = 0 then
		                        call cts08g01("A","N","",
		                                  "LIMITE DE COBERTURA RESTRITO",
		                                  "AO VALOR DE UMA PASSAGEM",
		                                  "AEREA NA CLASSE ECONOMICA!")
		                           returning ws.confirma
		                    end if
		               end if

		                   if ws.maxcstvlr = -1 then --controle de mensagem
		                      call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
		                          returning ws.confirma
		                   end if



		                  {if param.asimtvcod = 4  then   -- Outras Situacoes  --linha 2615
		                              call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
		                              returning ws.confirma
		                  end if}

		               next field refatdsrvorg
		           else
		                   if g_documento.atdsrvnum is not null  and
		                      g_documento.atdsrvano is not null  then
		                      next field vclcordes
		                   end if
               end if
          end if
      end if
   before field refatdsrvorg
          display by name d_cts11m00.refatdsrvorg attribute (reverse)

   after  field refatdsrvorg
          display by name d_cts11m00.refatdsrvorg

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field asimtvcod
          end if

          if  d_cts11m00.refatdsrvorg is null  then
           if  g_documento.succod    is not null  and
               g_documento.aplnumdig is not null  then
               call cts11m02 ( g_documento.succod,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig, "",
                               g_documento.ramcod)
                     returning d_cts11m00.refatdsrvorg,
                               d_cts11m00.refatdsrvnum,
                               d_cts11m00.refatdsrvano
               display by name d_cts11m00.refatdsrvorg
               display by name d_cts11m00.refatdsrvnum
               display by name d_cts11m00.refatdsrvano

               if  d_cts11m00.refatdsrvnum is null  and
                   d_cts11m00.refatdsrvano is null  then
                   let a_cts11m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

                   let m_acesso_ind = false
                   let m_atdsrvorg = 2
                   call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                        returning m_acesso_ind

                   if m_acesso_ind = false then
                      call cts06g03(1,
                                    m_atdsrvorg,
                                    w_cts11m00.ligcvntip,
                                    aux_today,
                                    aux_hora,
                                    a_cts11m00[1].lclidttxt,
                                    a_cts11m00[1].cidnom,
                                    a_cts11m00[1].ufdcod,
                                    a_cts11m00[1].brrnom,
                                    a_cts11m00[1].lclbrrnom,
                                    a_cts11m00[1].endzon,
                                    a_cts11m00[1].lgdtip,
                                    a_cts11m00[1].lgdnom,
                                    a_cts11m00[1].lgdnum,
                                    a_cts11m00[1].lgdcep,
                                    a_cts11m00[1].lgdcepcmp,
                                    a_cts11m00[1].lclltt,
                                    a_cts11m00[1].lcllgt,
                                    a_cts11m00[1].lclrefptotxt,
                                    a_cts11m00[1].lclcttnom,
                                    a_cts11m00[1].dddcod,
                                    a_cts11m00[1].lcltelnum,
                                    a_cts11m00[1].c24lclpdrcod,
                                    a_cts11m00[1].ofnnumdig,
                                    a_cts11m00[1].celteldddcod,
                                    a_cts11m00[1].celtelnum,
                                    a_cts11m00[1].endcmp,
                                    hist_cts11m00.*, a_cts11m00[1].emeviacod)
                          returning a_cts11m00[1].lclidttxt,
                                    a_cts11m00[1].cidnom,
                                    a_cts11m00[1].ufdcod,
                                    a_cts11m00[1].brrnom,
                                    a_cts11m00[1].lclbrrnom,
                                    a_cts11m00[1].endzon,
                                    a_cts11m00[1].lgdtip,
                                    a_cts11m00[1].lgdnom,
                                    a_cts11m00[1].lgdnum,
                                    a_cts11m00[1].lgdcep,
                                    a_cts11m00[1].lgdcepcmp,
                                    a_cts11m00[1].lclltt,
                                    a_cts11m00[1].lcllgt,
                                    a_cts11m00[1].lclrefptotxt,
                                    a_cts11m00[1].lclcttnom,
                                    a_cts11m00[1].dddcod,
                                    a_cts11m00[1].lcltelnum,
                                    a_cts11m00[1].c24lclpdrcod,
                                    a_cts11m00[1].ofnnumdig,
                                    a_cts11m00[1].celteldddcod,
                                    a_cts11m00[1].celtelnum,
                                    a_cts11m00[1].endcmp,
                                    ws.retflg,
                                    hist_cts11m00.*, a_cts11m00[1].emeviacod
                   else
                      call cts06g11(1,
                                    m_atdsrvorg,
                                    w_cts11m00.ligcvntip,
                                    aux_today,
                                    aux_hora,
                                    a_cts11m00[1].lclidttxt,
                                    a_cts11m00[1].cidnom,
                                    a_cts11m00[1].ufdcod,
                                    a_cts11m00[1].brrnom,
                                    a_cts11m00[1].lclbrrnom,
                                    a_cts11m00[1].endzon,
                                    a_cts11m00[1].lgdtip,
                                    a_cts11m00[1].lgdnom,
                                    a_cts11m00[1].lgdnum,
                                    a_cts11m00[1].lgdcep,
                                    a_cts11m00[1].lgdcepcmp,
                                    a_cts11m00[1].lclltt,
                                    a_cts11m00[1].lcllgt,
                                    a_cts11m00[1].lclrefptotxt,
                                    a_cts11m00[1].lclcttnom,
                                    a_cts11m00[1].dddcod,
                                    a_cts11m00[1].lcltelnum,
                                    a_cts11m00[1].c24lclpdrcod,
                                    a_cts11m00[1].ofnnumdig,
                                    a_cts11m00[1].celteldddcod,
                                    a_cts11m00[1].celtelnum,
                                    a_cts11m00[1].endcmp,
                                    hist_cts11m00.*, a_cts11m00[1].emeviacod)
                          returning a_cts11m00[1].lclidttxt,
                                    a_cts11m00[1].cidnom,
                                    a_cts11m00[1].ufdcod,
                                    a_cts11m00[1].brrnom,
                                    a_cts11m00[1].lclbrrnom,
                                    a_cts11m00[1].endzon,
                                    a_cts11m00[1].lgdtip,
                                    a_cts11m00[1].lgdnom,
                                    a_cts11m00[1].lgdnum,
                                    a_cts11m00[1].lgdcep,
                                    a_cts11m00[1].lgdcepcmp,
                                    a_cts11m00[1].lclltt,
                                    a_cts11m00[1].lcllgt,
                                    a_cts11m00[1].lclrefptotxt,
                                    a_cts11m00[1].lclcttnom,
                                    a_cts11m00[1].dddcod,
                                    a_cts11m00[1].lcltelnum,
                                    a_cts11m00[1].c24lclpdrcod,
                                    a_cts11m00[1].ofnnumdig,
                                    a_cts11m00[1].celteldddcod,
                                    a_cts11m00[1].celtelnum,
                                    a_cts11m00[1].endcmp,
                                    ws.retflg,
                                    hist_cts11m00.*, a_cts11m00[1].emeviacod
                   end if
                   #------------------------------------------------------------------------------
                   # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
                   #------------------------------------------------------------------------------
                   if g_documento.lclocodesres = "S" then
                      let w_cts11m00.atdrsdflg = "S"
                   else
                      let w_cts11m00.atdrsdflg = "N"
                   end if
                   # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                   let m_subbairro[1].lclbrrnom = a_cts11m00[1].lclbrrnom
                   call cts06g10_monta_brr_subbrr(a_cts11m00[1].brrnom,
                                                  a_cts11m00[1].lclbrrnom)
                        returning a_cts11m00[1].lclbrrnom

                   let a_cts11m00[1].lgdtxt = a_cts11m00[1].lgdtip clipped, " ",
                                              a_cts11m00[1].lgdnom clipped, " ",
                                              a_cts11m00[1].lgdnum using "<<<<#"

                   if a_cts11m00[1].cidnom is not null and
                      a_cts11m00[1].ufdcod is not null then
                      call cts14g00 ( g_documento.c24astcod,
                                      "","","","",
                                      a_cts11m00[1].cidnom,
                                      a_cts11m00[1].ufdcod,
                                      "S",
                                      ws.dtparam )
                   end if

                   display by name a_cts11m00[1].lgdtxt
                   display by name a_cts11m00[1].lclbrrnom
                   display by name a_cts11m00[1].endzon
                   display by name a_cts11m00[1].cidnom
                   display by name a_cts11m00[1].ufdcod
                   display by name a_cts11m00[1].lclrefptotxt
                   display by name a_cts11m00[1].lclcttnom
                   display by name a_cts11m00[1].dddcod
                   display by name a_cts11m00[1].lcltelnum
                   display by name a_cts11m00[1].celteldddcod
                   display by name a_cts11m00[1].celtelnum
                   display by name a_cts11m00[1].endcmp

                   let w_cts11m00.atdocrcidnom = a_cts11m00[1].cidnom
                   let w_cts11m00.atdocrufdcod = a_cts11m00[1].ufdcod

                   if  w_cts11m00.atddmccidnom = w_cts11m00.atdocrcidnom  and
                       w_cts11m00.atddmcufdcod = w_cts11m00.atdocrufdcod  then
                  #    error " Nao e' possivel a utilizacao da clausula",
                  #          " de assistencia aos passageiros! "
                       call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                     "A LOCAL DE DOMICILIO!","")
                            returning ws.confirma
                       if  ws.confirma = "N"  then
                           next field refatdsrvorg
                       end if
                   end if

                   if a_cts11m00[1].ufdcod = 'EX' then
                      let ws.retflg = "S"
                   end if

                   if  ws.retflg = "N"  then
                       error " Dados referentes ao local incorretos",
                             " ou nao preenchidos!"
                       next field refatdsrvorg
                   else
                       next field bagflg
                   end if
               end if
           else
               initialize d_cts11m00.refatdsrvnum,
                          d_cts11m00.refatdsrvano to null
               display by name d_cts11m00.refatdsrvnum,
                               d_cts11m00.refatdsrvano
           end if
          end if

          if  d_cts11m00.refatdsrvorg <> 4   and   # Remocao
              d_cts11m00.refatdsrvorg <> 6   and   # DAF
              d_cts11m00.refatdsrvorg <> 1   and   # Socorro
              d_cts11m00.refatdsrvorg <> 2   then  # Transporte
              error " Origem do servico de referencia deve",
                    " ser um SOCORRO ou REMOCAO!"
              next field refatdsrvorg
          end if


   before field refatdsrvnum
          display by name d_cts11m00.refatdsrvnum attribute (reverse)

   after  field refatdsrvnum
          display by name d_cts11m00.refatdsrvnum

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field refatdsrvorg
          end if

          if d_cts11m00.refatdsrvorg is not null  and
             d_cts11m00.refatdsrvnum is null      then
             error " Numero do servico de referencia nao informado!"
             next field refatdsrvnum
          end if

   before field refatdsrvano
          display by name d_cts11m00.refatdsrvano attribute (reverse)

   after  field refatdsrvano
          display by name d_cts11m00.refatdsrvano

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field refatdsrvnum
          end if

          if  d_cts11m00.refatdsrvnum is not null  then
           if  d_cts11m00.refatdsrvano is not null  then
               if  g_documento.succod    is not null  and
                   g_documento.ramcod    is not null  and
                   g_documento.aplnumdig is not null  then
                   select succod   ,
                          aplnumdig,
                          itmnumdig
                     into ws.succod   ,
                          ws.aplnumdig,
                          ws.itmnumdig
                     from DATRSERVAPOL
                          where atdsrvnum = d_cts11m00.refatdsrvnum
                            and atdsrvano = d_cts11m00.refatdsrvano

                   if  sqlca.sqlcode <> notfound  then
                    if  ws.succod    <> g_documento.succod     or
                        ws.aplnumdig <> g_documento.aplnumdig  or
                        ws.itmnumdig <> g_documento.itmnumdig  then
                        error " Servico original nao pertence a esta apolice! "
                        next field refatdsrvorg
                    end if
                   end if
               end if
           else
               error " Ano do servico original nao informado!"
               next field refatdsrvano
           end if
          end if

          if  g_documento.atdsrvnum   is     null  and
              g_documento.atdsrvano   is     null  and
              d_cts11m00.refatdsrvorg is not null  and
              d_cts11m00.refatdsrvnum is not null  and
              d_cts11m00.refatdsrvano is not null  then
              select atdsrvorg
                into ws.refatdsrvorg
                from DATMSERVICO
                     where atdsrvnum = d_cts11m00.refatdsrvnum
                       and atdsrvano = d_cts11m00.refatdsrvano

              if  ws.refatdsrvorg <> d_cts11m00.refatdsrvorg  then
                  error " Origem do numero de servico invalido.",
                        " A origem deve ser ", ws.refatdsrvorg using "&&"
                  next field refatdsrvorg
              end if

              call ctx04g00_local_gps( d_cts11m00.refatdsrvnum,
                                       d_cts11m00.refatdsrvano,
                                       1                       )
                             returning a_cts11m00[1].lclidttxt   ,
                                       a_cts11m00[1].lgdtip      ,
                                       a_cts11m00[1].lgdnom      ,
                                       a_cts11m00[1].lgdnum      ,
                                       a_cts11m00[1].lclbrrnom   ,
                                       a_cts11m00[1].brrnom      ,
                                       a_cts11m00[1].cidnom      ,
                                       a_cts11m00[1].ufdcod      ,
                                       a_cts11m00[1].lclrefptotxt,
                                       a_cts11m00[1].endzon      ,
                                       a_cts11m00[1].lgdcep      ,
                                       a_cts11m00[1].lgdcepcmp   ,
                                       a_cts11m00[1].lclltt      ,
                                       a_cts11m00[1].lcllgt      ,
                                       a_cts11m00[1].dddcod      ,
                                       a_cts11m00[1].lcltelnum   ,
                                       a_cts11m00[1].lclcttnom   ,
                                       a_cts11m00[1].c24lclpdrcod,
                                       a_cts11m00[1].celteldddcod,
                                       a_cts11m00[1].celtelnum   ,
                                       a_cts11m00[1].endcmp,
                                       ws.codigosql, a_cts11m00[1].emeviacod
              # PSI 244589 - Inclus�o de Sub-Bairro - Burini
              let m_subbairro[1].lclbrrnom = a_cts11m00[1].lclbrrnom
              call cts06g10_monta_brr_subbrr(a_cts11m00[1].brrnom,
                                             a_cts11m00[1].lclbrrnom)
                   returning a_cts11m00[1].lclbrrnom

              select ofnnumdig into a_cts11m00[1].ofnnumdig
                from datmlcl
               where atdsrvano = g_documento.atdsrvano
                 and atdsrvnum = g_documento.atdsrvnum
                 and c24endtip = 1

              if  ws.codigosql <> 0  then
                  error " Erro (", ws.codigosql using "<<<<<&", ") na leitura",
                        " do local de ocorrencia. AVISE A INFORMATICA!"
                  next field refatdsrvorg
              end if

              let a_cts11m00[1].lgdtxt = a_cts11m00[1].lgdtip clipped, " ",
                                         a_cts11m00[1].lgdnom clipped, " ",
                                         a_cts11m00[1].lgdnum using "<<<<#"

              display by name a_cts11m00[1].lgdtxt,
                              a_cts11m00[1].lclbrrnom,
                              a_cts11m00[1].cidnom,
                              a_cts11m00[1].ufdcod,
                              a_cts11m00[1].lclrefptotxt,
                              a_cts11m00[1].endzon,
                              a_cts11m00[1].dddcod,
                              a_cts11m00[1].lcltelnum,
                              a_cts11m00[1].lclcttnom,
                              a_cts11m00[1].celteldddcod,
                              a_cts11m00[1].celtelnum,
                              a_cts11m00[1].endcmp
          end if

          let a_cts11m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

          let m_acesso_ind = false
          let m_atdsrvorg = 2
          call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
               returning m_acesso_ind
          if m_acesso_ind = false then
             call cts06g03(1,
                           m_atdsrvorg,
                           w_cts11m00.ligcvntip,
                           aux_today,
                           aux_hora,
                           a_cts11m00[1].lclidttxt,
                           a_cts11m00[1].cidnom,
                           a_cts11m00[1].ufdcod,
                           a_cts11m00[1].brrnom,
                           a_cts11m00[1].lclbrrnom,
                           a_cts11m00[1].endzon,
                           a_cts11m00[1].lgdtip,
                           a_cts11m00[1].lgdnom,
                           a_cts11m00[1].lgdnum,
                           a_cts11m00[1].lgdcep,
                           a_cts11m00[1].lgdcepcmp,
                           a_cts11m00[1].lclltt,
                           a_cts11m00[1].lcllgt,
                           a_cts11m00[1].lclrefptotxt,
                           a_cts11m00[1].lclcttnom,
                           a_cts11m00[1].dddcod,
                           a_cts11m00[1].lcltelnum,
                           a_cts11m00[1].c24lclpdrcod,
                           a_cts11m00[1].ofnnumdig,
                           a_cts11m00[1].celteldddcod,
                           a_cts11m00[1].celtelnum,
                           a_cts11m00[1].endcmp,
                           hist_cts11m00.*, a_cts11m00[1].emeviacod)
                 returning a_cts11m00[1].lclidttxt,
                           a_cts11m00[1].cidnom,
                           a_cts11m00[1].ufdcod,
                           a_cts11m00[1].brrnom,
                           a_cts11m00[1].lclbrrnom,
                           a_cts11m00[1].endzon,
                           a_cts11m00[1].lgdtip,
                           a_cts11m00[1].lgdnom,
                           a_cts11m00[1].lgdnum,
                           a_cts11m00[1].lgdcep,
                           a_cts11m00[1].lgdcepcmp,
                           a_cts11m00[1].lclltt,
                           a_cts11m00[1].lcllgt,
                           a_cts11m00[1].lclrefptotxt,
                           a_cts11m00[1].lclcttnom,
                           a_cts11m00[1].dddcod,
                           a_cts11m00[1].lcltelnum,
                           a_cts11m00[1].c24lclpdrcod,
                           a_cts11m00[1].ofnnumdig,
                           a_cts11m00[1].celteldddcod,
                           a_cts11m00[1].celtelnum,
                           a_cts11m00[1].endcmp,
                           ws.retflg,
                           hist_cts11m00.*, a_cts11m00[1].emeviacod
          else
             call cts06g11(1,
                           m_atdsrvorg,
                           w_cts11m00.ligcvntip,
                           aux_today,
                           aux_hora,
                           a_cts11m00[1].lclidttxt,
                           a_cts11m00[1].cidnom,
                           a_cts11m00[1].ufdcod,
                           a_cts11m00[1].brrnom,
                           a_cts11m00[1].lclbrrnom,
                           a_cts11m00[1].endzon,
                           a_cts11m00[1].lgdtip,
                           a_cts11m00[1].lgdnom,
                           a_cts11m00[1].lgdnum,
                           a_cts11m00[1].lgdcep,
                           a_cts11m00[1].lgdcepcmp,
                           a_cts11m00[1].lclltt,
                           a_cts11m00[1].lcllgt,
                           a_cts11m00[1].lclrefptotxt,
                           a_cts11m00[1].lclcttnom,
                           a_cts11m00[1].dddcod,
                           a_cts11m00[1].lcltelnum,
                           a_cts11m00[1].c24lclpdrcod,
                           a_cts11m00[1].ofnnumdig,
                           a_cts11m00[1].celteldddcod,
                           a_cts11m00[1].celtelnum,
                           a_cts11m00[1].endcmp,
                           hist_cts11m00.*, a_cts11m00[1].emeviacod)
                 returning a_cts11m00[1].lclidttxt,
                           a_cts11m00[1].cidnom,
                           a_cts11m00[1].ufdcod,
                           a_cts11m00[1].brrnom,
                           a_cts11m00[1].lclbrrnom,
                           a_cts11m00[1].endzon,
                           a_cts11m00[1].lgdtip,
                           a_cts11m00[1].lgdnom,
                           a_cts11m00[1].lgdnum,
                           a_cts11m00[1].lgdcep,
                           a_cts11m00[1].lgdcepcmp,
                           a_cts11m00[1].lclltt,
                           a_cts11m00[1].lcllgt,
                           a_cts11m00[1].lclrefptotxt,
                           a_cts11m00[1].lclcttnom,
                           a_cts11m00[1].dddcod,
                           a_cts11m00[1].lcltelnum,
                           a_cts11m00[1].c24lclpdrcod,
                           a_cts11m00[1].ofnnumdig,
                           a_cts11m00[1].celteldddcod,
                           a_cts11m00[1].celtelnum,
                           a_cts11m00[1].endcmp,
                           ws.retflg,
                           hist_cts11m00.*, a_cts11m00[1].emeviacod
          end if
          #------------------------------------------------------------------------------
          # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
          #------------------------------------------------------------------------------
          if g_documento.lclocodesres = "S" then
             let w_cts11m00.atdrsdflg = "S"
          else
             let w_cts11m00.atdrsdflg = "N"
          end if
          # PSI 244589 - Inclus�o de Sub-Bairro - Burini
          let m_subbairro[1].lclbrrnom = a_cts11m00[1].lclbrrnom
          call cts06g10_monta_brr_subbrr(a_cts11m00[1].brrnom,
                                         a_cts11m00[1].lclbrrnom)
               returning a_cts11m00[1].lclbrrnom

          let a_cts11m00[1].lgdtxt = a_cts11m00[1].lgdtip clipped, " ",
                                     a_cts11m00[1].lgdnom clipped, " ",
                                     a_cts11m00[1].lgdnum using "<<<<#"

          if a_cts11m00[1].cidnom is not null and
             a_cts11m00[1].ufdcod is not null then
             call cts14g00 (g_documento.c24astcod,
                            "","","","",
                            a_cts11m00[1].cidnom,
                            a_cts11m00[1].ufdcod,
                            "S",
                            ws.dtparam)
          end if

          display by name a_cts11m00[1].lgdtxt
          display by name a_cts11m00[1].lclbrrnom
          display by name a_cts11m00[1].endzon
          display by name a_cts11m00[1].cidnom
          display by name a_cts11m00[1].ufdcod
          display by name a_cts11m00[1].lclrefptotxt
          display by name a_cts11m00[1].lclcttnom
          display by name a_cts11m00[1].dddcod
          display by name a_cts11m00[1].lcltelnum
          display by name a_cts11m00[1].celteldddcod
          display by name a_cts11m00[1].celtelnum
          display by name a_cts11m00[1].endcmp

          let w_cts11m00.atdocrcidnom = a_cts11m00[1].cidnom
          let w_cts11m00.atdocrufdcod = a_cts11m00[1].ufdcod

          if  w_cts11m00.atddmccidnom = w_cts11m00.atdocrcidnom  and
              w_cts11m00.atddmcufdcod = w_cts11m00.atdocrufdcod  then
         #    error " Nao e' possivel a utilizacao da clausula",
         #          " de assistencia aos passageiros! "
              call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                            "A LOCAL DE DOMICILIO!","") returning ws.confirma
              if  ws.confirma = "N"  then
                  next field refatdsrvorg
              end if
          end if

					if a_cts11m00[1].ufdcod = "EX" then
					   let  ws.retflg = "S"
          end if

          if  ws.retflg = "N"  then
              error " Dados referentes ao local incorretos ou nao preenchidos!"
              next field refatdsrvorg
          end if

  before field bagflg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  and
             d_cts11m00.asitipcod  <> 5     then
             let d_cts11m00.bagflg = "N"
          end if

          display by name d_cts11m00.bagflg    attribute (reverse)

   after  field bagflg
          display by name d_cts11m00.bagflg

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts11m00.bagflg is null  then
                error " Bagagem deve ser informada!"
                next field bagflg
             else
                if d_cts11m00.bagflg <> "S"  and
                   d_cts11m00.bagflg <> "N"  then
                   error " Informe (S)im ou (N)ao!"
                   next field bagflg
                end if
             end if

             if d_cts11m00.bagflg = "S"  then
                call cts08g01("Q","N","QUAL A QUANTIDADE E VOLUME",
                              "DE BAGAGEM ?","",
                              "REGISTRE INFORMACAO NO HISTORICO")
                     returning ws.confirma
             end if


             if d_cts11m00.asitipcod = 10  then  ###  Passagem Aerea
                display by name d_cts11m00.dstcidnom
                display by name d_cts11m00.dstufdcod
             else
                let a_cts11m00[3].* = a_cts11m00[2].*
                let a_cts11m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                let m_acesso_ind = false
                let m_atdsrvorg = 2
                call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                     returning m_acesso_ind

                 if d_cts11m00.asitipcod <> 10 then
									  if (g_documento.c24astcod = 'M15' or
						            g_documento.c24astcod = 'M20' or
						            g_documento.c24astcod = 'M23' or
						            g_documento.c24astcod = 'M33') then
													call cts08g01("C","S",""," DESTINO SER� O BRASIL ? ","", "")
													   returning l_resposta

											  if l_resposta = "S" then
												  let a_cts11m00[2].ufdcod = ""
												  let a_cts11m00[2].lclidttxt = "BRASIL"
					             	else
					             	    let m_sql = "select cpocod "
						                                 ,",cpodes "
						                             ,"from datkdominio "
						                            ,"where cponom = 'paises_mercosul' "
						                         ,"order by cpodes "
											      call ofgrc001_popup(10,10,"PAISES - MERCOSUL","CODIGO","DESCRICAO",
					                                       'N',m_sql,
					                                       "",'D')
					                            returning ws.erro,
														           ws.codpais,
														           ws.despais

												     {call merc001()
																 returning ws.erro,
																           ws.codpais,
																           ws.despais		}
															let a_cts11m00[2].cidnom = ws.despais
															let a_cts11m00[2].ufdcod = "EX"
						            end if
						        end if
                 end if

               if m_acesso_ind = false then
                  call cts06g03(2,
                                m_atdsrvorg,
                                w_cts11m00.ligcvntip,
                                aux_today,
                                aux_hora,
                                a_cts11m00[2].lclidttxt,
                                a_cts11m00[2].cidnom,
                                a_cts11m00[2].ufdcod,
                                a_cts11m00[2].brrnom,
                                a_cts11m00[2].lclbrrnom,
                                a_cts11m00[2].endzon,
                                a_cts11m00[2].lgdtip,
                                a_cts11m00[2].lgdnom,
                                a_cts11m00[2].lgdnum,
                                a_cts11m00[2].lgdcep,
                                a_cts11m00[2].lgdcepcmp,
                                a_cts11m00[2].lclltt,
                                a_cts11m00[2].lcllgt,
                                a_cts11m00[2].lclrefptotxt,
                                a_cts11m00[2].lclcttnom,
                                a_cts11m00[2].dddcod,
                                a_cts11m00[2].lcltelnum,
                                a_cts11m00[2].c24lclpdrcod,
                                a_cts11m00[2].ofnnumdig,
                                a_cts11m00[2].celteldddcod,
                                a_cts11m00[2].celtelnum,
                                a_cts11m00[2].endcmp,
                                hist_cts11m00.*, a_cts11m00[2].emeviacod)
                      returning a_cts11m00[2].lclidttxt,
                                a_cts11m00[2].cidnom,
                                a_cts11m00[2].ufdcod,
                                a_cts11m00[2].brrnom,
                                a_cts11m00[2].lclbrrnom,
                                a_cts11m00[2].endzon,
                                a_cts11m00[2].lgdtip,
                                a_cts11m00[2].lgdnom,
                                a_cts11m00[2].lgdnum,
                                a_cts11m00[2].lgdcep,
                                a_cts11m00[2].lgdcepcmp,
                                a_cts11m00[2].lclltt,
                                a_cts11m00[2].lcllgt,
                                a_cts11m00[2].lclrefptotxt,
                                a_cts11m00[2].lclcttnom,
                                a_cts11m00[2].dddcod,
                                a_cts11m00[2].lcltelnum,
                                a_cts11m00[2].c24lclpdrcod,
                                a_cts11m00[2].ofnnumdig,
                                a_cts11m00[2].celteldddcod,
                                a_cts11m00[2].celtelnum,
                                a_cts11m00[2].endcmp,
                                ws.retflg,
                                hist_cts11m00.*, a_cts11m00[2].emeviacod
                else

                  call cts06g11(2,
                                m_atdsrvorg,
                                w_cts11m00.ligcvntip,
                                aux_today,
                                aux_hora,
                                a_cts11m00[2].lclidttxt,
                                a_cts11m00[2].cidnom,
                                a_cts11m00[2].ufdcod,
                                a_cts11m00[2].brrnom,
                                a_cts11m00[2].lclbrrnom,
                                a_cts11m00[2].endzon,
                                a_cts11m00[2].lgdtip,
                                a_cts11m00[2].lgdnom,
                                a_cts11m00[2].lgdnum,
                                a_cts11m00[2].lgdcep,
                                a_cts11m00[2].lgdcepcmp,
                                a_cts11m00[2].lclltt,
                                a_cts11m00[2].lcllgt,
                                a_cts11m00[2].lclrefptotxt,
                                a_cts11m00[2].lclcttnom,
                                a_cts11m00[2].dddcod,
                                a_cts11m00[2].lcltelnum,
                                a_cts11m00[2].c24lclpdrcod,
                                a_cts11m00[2].ofnnumdig,
                                a_cts11m00[2].celteldddcod,
                                a_cts11m00[2].celtelnum,
                                a_cts11m00[2].endcmp,
                                hist_cts11m00.*, a_cts11m00[2].emeviacod)
                      returning a_cts11m00[2].lclidttxt,
                                a_cts11m00[2].cidnom,
                                a_cts11m00[2].ufdcod,
                                a_cts11m00[2].brrnom,
                                a_cts11m00[2].lclbrrnom,
                                a_cts11m00[2].endzon,
                                a_cts11m00[2].lgdtip,
                                a_cts11m00[2].lgdnom,
                                a_cts11m00[2].lgdnum,
                                a_cts11m00[2].lgdcep,
                                a_cts11m00[2].lgdcepcmp,
                                a_cts11m00[2].lclltt,
                                a_cts11m00[2].lcllgt,
                                a_cts11m00[2].lclrefptotxt,
                                a_cts11m00[2].lclcttnom,
                                a_cts11m00[2].dddcod,
                                a_cts11m00[2].lcltelnum,
                                a_cts11m00[2].c24lclpdrcod,
                                a_cts11m00[2].ofnnumdig,
                                a_cts11m00[2].celteldddcod,
                                a_cts11m00[2].celtelnum,
                                a_cts11m00[2].endcmp,
                                ws.retflg,
                                hist_cts11m00.*, a_cts11m00[2].emeviacod

                end if

                # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                let m_subbairro[2].lclbrrnom = a_cts11m00[2].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts11m00[2].brrnom,
                                               a_cts11m00[2].lclbrrnom)
                     returning a_cts11m00[2].lclbrrnom

                let a_cts11m00[2].lgdtxt = a_cts11m00[2].lgdtip clipped, " ",
                                           a_cts11m00[2].lgdnom clipped, " ",
                                           a_cts11m00[2].lgdnum using "<<<<#"

                let d_cts11m00.dstlcl    = a_cts11m00[2].lclidttxt
                let d_cts11m00.dstlgdtxt = a_cts11m00[2].lgdtxt
                let d_cts11m00.dstbrrnom = a_cts11m00[2].lclbrrnom
                let d_cts11m00.dstcidnom = a_cts11m00[2].cidnom
                let d_cts11m00.dstufdcod = a_cts11m00[2].ufdcod

                if a_cts11m00[2].lclltt <> a_cts11m00[3].lclltt or
                   a_cts11m00[2].lcllgt <> a_cts11m00[3].lcllgt or
                   (a_cts11m00[3].lclltt is null and a_cts11m00[2].lclltt is not null) or
                   (a_cts11m00[3].lcllgt is null and a_cts11m00[2].lcllgt is not null) then


								if g_documento.c24astcod <> 'M15' and
				           g_documento.c24astcod <> 'M20' and
				           g_documento.c24astcod <> 'M23' and
				           g_documento.c24astcod <> 'M33' then
                   call cts00m33(1,
                                 a_cts11m00[1].lclltt,
                                 a_cts11m00[1].lcllgt,
                                 a_cts11m00[2].lclltt,
                                 a_cts11m00[2].lcllgt)
                   if cty31g00_valida_clausula() then
                       #----------------------------------------------------------
                       # Calcula o Limite de Kilometragem
                       #----------------------------------------------------------
                        call cts00m33_calckm("",
                                             a_cts11m00[1].lclltt,
                                             a_cts11m00[1].lcllgt,
                                             a_cts11m00[2].lclltt,
                                             a_cts11m00[2].lcllgt,
                                             l_limite_km         )
                   end if
                 end if
                end if

                if a_cts11m00[2].cidnom is not null and
                   a_cts11m00[2].ufdcod is not null then
                   call cts14g00 (g_documento.c24astcod,
                                  "","","","",
                                  a_cts11m00[2].cidnom,
                                  a_cts11m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if

                display by name d_cts11m00.dstlcl   ,
                                d_cts11m00.dstlgdtxt,
                                d_cts11m00.dstbrrnom,
                                d_cts11m00.dstcidnom,
                                d_cts11m00.dstufdcod

                  if a_cts11m00[2].ufdcod = "EX" then
			              let ws.retflg = "S"
			          end if


                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos ou nao",
                         " preenchidos!"
                   next field bagflg
                end if
             end if
          end if

          error " Informe a relacao de passageiros!"
          call cts11m01 (a_passag[01].*,
                         a_passag[02].*,
                         a_passag[03].*,
                         a_passag[04].*,
                         a_passag[05].*,
                         a_passag[06].*,
                         a_passag[07].*,
                         a_passag[08].*,
                         a_passag[09].*,
                         a_passag[10].*,
                         a_passag[11].*,
                         a_passag[12].*,
                         a_passag[13].*,
                         a_passag[14].*,
                         a_passag[15].*)
               returning a_passag[01].*,
                         a_passag[02].*,
                         a_passag[03].*,
                         a_passag[04].*,
                         a_passag[05].*,
                         a_passag[06].*,
                         a_passag[07].*,
                         a_passag[08].*,
                         a_passag[09].*,
                         a_passag[10].*,
                         a_passag[11].*,
                         a_passag[12].*,
                         a_passag[13].*,
                         a_passag[14].*,
                         a_passag[15].*

   before field imdsrvflg
          if d_cts11m00.asitipcod <> 5  then
             let d_cts11m00.imdsrvflg    = "S"
             let w_cts11m00.atdpvtretflg = "S"
             let w_cts11m00.atdhorpvt    = "00:00"
             let d_cts11m00.atdprinvlcod = 2
             select cpodes
               into d_cts11m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts11m00.atdprinvlcod

             initialize w_cts11m00.atddatprg to null
             initialize w_cts11m00.atdhorprg to null

             display by name d_cts11m00.imdsrvflg
             display by name d_cts11m00.atdprinvlcod
             display by name d_cts11m00.atdprinvldes

             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field bagflg
             else
                next field atdlibflg
             end if
          else
             display by name d_cts11m00.imdsrvflg  attribute (reverse)
          end if
          if cty39g00_programado() then
          	  let d_cts11m00.imdsrvflg    = "N"
          	  display by name d_cts11m00.imdsrvflg
          end if

   after  field imdsrvflg
          display by name d_cts11m00.imdsrvflg

          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts11m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if

          if (m_cidnom != a_cts11m00[1].cidnom) or
             (m_ufdcod != a_cts11m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente

             let m_cidnom = a_cts11m00[1].cidnom
             let m_ufdcod = a_cts11m00[1].ufdcod

             #display 'cts11m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if

          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts11m00.imdsrvflg
          end if

          if m_cidnom is null then
             let m_cidnom = a_cts11m00[1].cidnom
          end if

          if m_ufdcod is null then
             let m_ufdcod = a_cts11m00[1].ufdcod
          end if

          # Envia a chave antiga no input quando alteracao.
          # Se for a situacao INC, regulou, voltou para o laudo (CTRL+C) e regulou
          # novamente manda a mesma pra ver se ainda e valida
          if g_documento.acao = "ALT"
             then
             let m_rsrchv = m_rsrchvant
          end if
          # PSI-2013-00440PR

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts11m00.imdsrvflg is null   then
                error " Servico imediato e' item obrigatorio!"
                next field imdsrvflg
             else
                if d_cts11m00.imdsrvflg <> "S"  and
                   d_cts11m00.imdsrvflg <> "N"  then
                   error " Informe (S)im ou (N)ao!"
                   next field imdsrvflg
                end if
             end if
             if cty39g00_programado() then
          	    let d_cts11m00.imdsrvflg    = "N"
          	    display by name d_cts11m00.imdsrvflg
             end if
             # INICIO PSI-2013-00440PR
             # Considerado que todas as regras de negocio sobre a questao da regulacao
             # sao tratadas do lado do AW, mantendo no laudo somente a chamada ao servico
             if m_agendaw = true
                then
                # obter a chave de regulacao no AW.
                call cts02m08(w_cts11m00.atdfnlflg,
                              d_cts11m00.imdsrvflg,
                              m_altcidufd,
                              d_cts11m00.prslocflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts11m00[1].cidnom,
                              a_cts11m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts11m00.vclcoddig,
                              m_ctgtrfcod,
                              d_cts11m00.imdsrvflg,
                              a_cts11m00[1].c24lclpdrcod,
                              a_cts11m00[1].lclltt,
                              a_cts11m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts11m00.asitipcod,
                              "",   # natureza nao tem, identifica pelo asitipcod
                              "")   # sub-natureza nao tem, identifica pelo asitipcod
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg,
                              d_cts11m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor

                display by name d_cts11m00.imdsrvflg

                if int_flag
                   then
                   let int_flag = false
                   next field imdsrvflg
                end if
                if cty39g00_programado() then
                	 if not cty39g00_verifica_diaria(w_cts11m00.atddatprg) then
                	    next field imdsrvflg
                	 end if
                end if

             else  # regula��o antiga

                call cts02m03(w_cts11m00.atdfnlflg,
                              d_cts11m00.imdsrvflg,
                              w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg)
                    returning w_cts11m00.atdhorpvt,
                              w_cts11m00.atddatprg,
                              w_cts11m00.atdhorprg,
                              w_cts11m00.atdpvtretflg
             end if

             if d_cts11m00.imdsrvflg = "S"  then
                if w_cts11m00.atdhorpvt is null  then
                   error " Previsao (em horas) nao informada para servico",
                         " imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts11m00.atddatprg   is null        or
                   w_cts11m00.atdhorprg   is null        then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts11m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts11m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts11m00.atdprinvlcod

                    display by name d_cts11m00.atdprinvlcod
                    display by name d_cts11m00.atdprinvldes

                    next field atdlibflg
                end if
             end if
          end if

   before field atdprinvlcod
          display by name d_cts11m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts11m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts11m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts11m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts11m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal",
                      " ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts11m00.atdprinvldes

          end if

   before field atdlibflg
          display by name d_cts11m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts11m00.atdfnlflg  =  "S"       then
             exit input
          end if

          if d_cts11m00.atdlibflg is null   and
             g_documento.c24soltipcod = 1  then  # Tipo Solic = Segurado
           # call cts09g00(g_documento.ramcod   ,  # psi 141003
           #               g_documento.succod   ,
           #               g_documento.aplnumdig,
           #               g_documento.itmnumdig,
           #               true)
           #     returning ws.dddcod, ws.teltxt
          end if

   after  field atdlibflg
          display by name d_cts11m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if d_cts11m00.atdlibflg is null then
             error " Envio liberado deve ser informado!"
             next field atdlibflg
          end if

          if d_cts11m00.atdlibflg <> "S"  and
             d_cts11m00.atdlibflg <> "N"  then
             error " Informe (S)im ou (N)ao!"
             next field atdlibflg
          end if

         #call cts02m06() returning w_cts11m00.atdlibflg
          let w_cts11m00.atdlibflg = d_cts11m00.atdlibflg

          if w_cts11m00.atdlibflg is null   then
             next field atdlibflg
          end if

         #let d_cts11m00.atdlibflg = w_cts11m00.atdlibflg
          display by name d_cts11m00.atdlibflg


          if d_cts11m00.asitipcod = 10  then
             call cts11m08(w_cts11m00.trppfrdat,
                           w_cts11m00.trppfrhor)
                 returning w_cts11m00.trppfrdat,
                           w_cts11m00.trppfrhor

             if w_cts11m00.trppfrdat is null  then
                call cts08g01("C","S","","NAO FOI PREENCHIDO NENHUMA",
                              "PREFERENCIA DE VIAGEM!","")
                     returning ws.confirma
                if ws.confirma = "N"  then
                   next field atdlibflg
                end if
             end if
          end if

          if w_cts11m00.antlibflg is null  then
             if w_cts11m00.atdlibflg = "S"  then
                call cts40g03_data_hora_banco(2)
                    returning l_data, l_hora2
                let d_cts11m00.atdlibhor = l_hora2
                let d_cts11m00.atdlibdat = l_data
             else
                let d_cts11m00.atdlibflg = "N"
                display by name d_cts11m00.atdlibflg
                initialize d_cts11m00.atdlibhor to null
                initialize d_cts11m00.atdlibdat to null
             end if
          else
             select atdfnlflg
               from datmservico
              where atdsrvnum = g_documento.atdsrvnum  and
                    atdsrvano = g_documento.atdsrvano  and
                    atdfnlflg in ("N","A")

             if sqlca.sqlcode = notfound  then
                error " Servico ja' acionado nao pode ser alterado!"
                let m_srv_acionado = true
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma
                next field atdlibflg
             end if

             if w_cts11m00.antlibflg = "S"  then
                if w_cts11m00.atdlibflg = "S"  then
                   exit input
                else
                   error " A liberacao do servico nao pode ser cancelada!"
                   next field atdlibflg
                   let d_cts11m00.atdlibflg = "N"
                   display by name d_cts11m00.atdlibflg
                   initialize d_cts11m00.atdlibhor to null
                   initialize d_cts11m00.atdlibdat to null
                   error " Liberacao do servico cancelada!"
                   sleep 1
                   exit input
                end if
             else
                if w_cts11m00.antlibflg = "N"  then
                   if w_cts11m00.atdlibflg = "N"  then
                      exit input
                   else
                      call cts40g03_data_hora_banco(2)
                           returning l_data, l_hora2
                      let d_cts11m00.atdlibhor = l_hora2
                      let d_cts11m00.atdlibdat = l_data
                      exit input
                   end if
                end if
             end if
          end if

   before field prslocflg
          if g_documento.atdsrvnum  is not null   or
             g_documento.atdsrvano  is not null   then
             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field atdlibflg
             else
                let d_cts11m00.prslocflg = "N"
                next field frmflg
             end if
          end if

          if d_cts11m00.asitipcod = 10  then   ###  Passagem Aerea
             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field atdlibflg
             else
                initialize d_cts11m00.prslocflg  to null
                next field frmflg
             end if
          end if

          if d_cts11m00.imdsrvflg   = "N"         then
             initialize w_cts11m00.c24nomctt  to null
             let d_cts11m00.prslocflg = "N"
             display by name d_cts11m00.prslocflg
             next field frmflg
          end if

          display by name d_cts11m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts11m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdlibflg
          end if

          if ((d_cts11m00.prslocflg  is null)  or
              (d_cts11m00.prslocflg  <> "S"    and
             d_cts11m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts11m00.prslocflg = "S"   then
             call ctn24c01()
                  returning w_cts11m00.atdprscod, w_cts11m00.srrcoddig,
                            w_cts11m00.atdvclsgl, w_cts11m00.socvclcod

             if w_cts11m00.atdprscod  is null then
                error " Faltam dados para prestador no local!"
                next field prslocflg
             end if

             let d_cts11m00.atdlibhor = aux_hora
             let d_cts11m00.atdlibdat = aux_today
             let w_cts11m00.atdfnlflg = "S"
             let w_cts11m00.atdetpcod =  4
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             let w_cts11m00.cnldat    = l_data
             let w_cts11m00.atdfnlhor = l_hora2
             let w_cts11m00.c24opemat = g_issk.funmat

             let d_cts11m00.frmflg    = "N"
             display by name d_cts11m00.frmflg
             exit input
          else
             initialize w_cts11m00.funmat   ,
                        w_cts11m00.cnldat   ,
                        w_cts11m00.atdfnlhor,
                        w_cts11m00.c24opemat,
                        w_cts11m00.atdfnlflg,
                        w_cts11m00.atdetpcod,
                        w_cts11m00.atdprscod,
                        w_cts11m00.atdcstvlr,
                        w_cts11m00.c24nomctt  to null
          end if

   before field frmflg
          if w_cts11m00.operacao = "i"  then
             let d_cts11m00.frmflg = "N"
             display by name d_cts11m00.frmflg attribute (reverse)
          else
             if w_cts11m00.atdfnlflg = "S"  then
                call cts11g00(w_cts11m00.lignum)
                let int_flag = true
             end if

             exit input
          end if

   after  field frmflg
          display by name d_cts11m00.frmflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field prslocflg
          end if

          if d_cts11m00.frmflg = "S"  then
             if d_cts11m00.atdlibflg = "N"  then
                error " Nao e' possivel registrar servico nao liberado",
                      " via formulario!"
                next field atdlibflg
             end if

             call cts02m05(2) returning w_cts11m00.data,
                                        w_cts11m00.hora,
                                        w_cts11m00.funmat,
                                        w_cts11m00.cnldat,
                                        w_cts11m00.atdfnlhor,
                                        w_cts11m00.c24opemat,
                                        w_cts11m00.atdprscod

             if w_cts11m00.hora      is null or
                w_cts11m00.data      is null or
                w_cts11m00.funmat    is null or
                w_cts11m00.cnldat    is null or
                w_cts11m00.atdfnlhor is null or
                w_cts11m00.c24opemat is null or
                w_cts11m00.atdprscod is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let d_cts11m00.atdlibhor = w_cts11m00.hora
             let d_cts11m00.atdlibdat = w_cts11m00.data
             let w_cts11m00.atdfnlflg = "S"
             let w_cts11m00.atdetpcod =  4
          else
             if d_cts11m00.prslocflg  = "N" then
                initialize w_cts11m00.hora     ,
                           w_cts11m00.data     ,
                           w_cts11m00.funmat   ,
                           w_cts11m00.cnldat   ,
                           w_cts11m00.atdfnlhor,
                           w_cts11m00.c24opemat,
                           w_cts11m00.atdfnlflg,
                           w_cts11m00.atdetpcod,
                           w_cts11m00.atdcstvlr,
                           w_cts11m00.atdprscod to null
             end if
          end if

          while true
             if a_passag[01].pasnom is null  or
                a_passag[01].pasidd is null  then
                error " Informe a relacao de passageiros!"
                call cts11m01 (a_passag[01].*,
                               a_passag[02].*,
                               a_passag[03].*,
                               a_passag[04].*,
                               a_passag[05].*,
                               a_passag[06].*,
                               a_passag[07].*,
                               a_passag[08].*,
                               a_passag[09].*,
                               a_passag[10].*,
                               a_passag[11].*,
                               a_passag[12].*,
                               a_passag[13].*,
                               a_passag[14].*,
                               a_passag[15].*)
                     returning a_passag[01].*,
                               a_passag[02].*,
                               a_passag[03].*,
                               a_passag[04].*,
                               a_passag[05].*,
                               a_passag[06].*,
                               a_passag[07].*,
                               a_passag[08].*,
                               a_passag[09].*,
                               a_passag[10].*,
                               a_passag[11].*,
                               a_passag[12].*,
                               a_passag[13].*,
                               a_passag[14].*,
                               a_passag[15].*
             else
                exit while
             end if
          end while

          if d_cts11m00.asimtvcod = 3  then
             while true
                for arr_aux = 1 to 15
                   if a_passag[arr_aux].pasnom is null  or
                      a_passag[arr_aux].pasidd is null  then
                      exit for
                   end if
                end for

                if arr_aux > 1  then
                   call cts08g01("A","S","","PARA RECUPERACAO DE VEICULO, SO'",
                                 "E' PERMITIDO UM UNICO PASSAGEIRO!","")
                        returning ws.confirma
                   if ws.confirma = "S"  then
                      exit while
                   else
                      call cts11m01 (a_passag[01].*,
                                     a_passag[02].*,
                                     a_passag[03].*,
                                     a_passag[04].*,
                                     a_passag[05].*,
                                     a_passag[06].*,
                                     a_passag[07].*,
                                     a_passag[08].*,
                                     a_passag[09].*,
                                     a_passag[10].*,
                                     a_passag[11].*,
                                     a_passag[12].*,
                                     a_passag[13].*,
                                     a_passag[14].*,
                                     a_passag[15].*)
                           returning a_passag[01].*,
                                     a_passag[02].*,
                                     a_passag[03].*,
                                     a_passag[04].*,
                                     a_passag[05].*,
                                     a_passag[06].*,
                                     a_passag[07].*,
                                     a_passag[08].*,
                                     a_passag[09].*,
                                     a_passag[10].*,
                                     a_passag[11].*,
                                     a_passag[12].*,
                                     a_passag[13].*,
                                     a_passag[14].*,
                                     a_passag[15].*
                   end if
                end if
             end while
          end if

   on key (interrupt)
      if g_documento.atdsrvnum  is null   then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?",
                     "","") = "S"  then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F4)
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         call f_funapol_ultima_situacao
           (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
            returning g_funapol.*
         select clscod
             from abbmclaus
            where succod    = g_documento.succod  and
                  aplnumdig = g_documento.aplnumdig and
                  itmnumdig = g_documento.itmnumdig and
                  dctnumseq = g_funapol.dctnumseq and
                  clscod    = "018"
         if sqlca.sqlcode  = 0  then
            if g_documento.atdsrvnum is null  or
               g_documento.atdsrvano is null  then
               if g_documento.cndslcflg   =  "S"  then
                  call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                                g_documento.itmnumdig, "I")
               else
                  call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                                g_documento.itmnumdig, "C")
               end if
            else
               call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                             g_documento.itmnumdig, "C")
            end if
        else
            error "Docto nao possui clausula 18 !"
        end if
      else
        error "Condutor so' com Documento localizado!"
      end if

   on key (F5)
{
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         if g_documento.ramcod = 31    or
            g_documento.ramcod = 531   then
            call cta01m00()
         else
            call cta01m20()
         end if
      else
         if g_documento.prporg    is not null  and
            g_documento.prpnumdig is not null  then
            call opacc149(g_documento.prporg, g_documento.prpnumdig)
                 returning ws.prpflg
         else
            if g_documento.pcacarnum is not null  and
               g_documento.pcaprpitm is not null  then
               call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
            else
               error " Espelho so' com documento localizado!"
            end if
         end if
      end if
}
      let g_monitor.horaini = current ## Flexvision
      call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

   on key (F6)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts10m02 (hist_cts11m00.*) returning hist_cts11m00.*
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat, w_cts11m00.data, w_cts11m00.hora)
      end if

   on key (F7)
      call ctx14g00("Funcoes","Impressao|Distancia|Destino")
           returning ws.opcao,
                     ws.opcaodes
      case ws.opcao
         when 1  ### Impressao
            if g_documento.atdsrvnum is null  or
            g_documento.atdsrvano is null  then
               error " Impressao somente com cadastramento do servico!"
            else
               call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
            end if

          when 2   #### Distancia QTH-QTI
             call cts00m33(1,
                           a_cts11m00[1].lclltt,
                           a_cts11m00[1].lcllgt,
                           a_cts11m00[2].lclltt,
                           a_cts11m00[2].lcllgt)

          when 3   #### Destino

             if g_documento.atdsrvnum is null  or
                g_documento.atdsrvano is null  then
                error " Servico nao cadastrado!"
             else
                let a_cts11m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                let m_acesso_ind = false
                let l_atdsrvorg = 7
                call cta00m06_acesso_indexacao_aut(l_atdsrvorg)
                     returning m_acesso_ind

                #Projeto alteracao cadastro de destino
                if g_documento.acao = "ALT" then

                   call cts11m00_bkp_info_dest(1, hist_cts11m00.*)
                      returning hist_cts11m00.*

                end if

                if m_acesso_ind = false then
                   call cts06g03(2,
                                 l_atdsrvorg,
                                 w_cts11m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts11m00[2].lclidttxt,
                                 a_cts11m00[2].cidnom,
                                 a_cts11m00[2].ufdcod,
                                 a_cts11m00[2].brrnom,
                                 a_cts11m00[2].lclbrrnom,
                                 a_cts11m00[2].endzon,
                                 a_cts11m00[2].lgdtip,
                                 a_cts11m00[2].lgdnom,
                                 a_cts11m00[2].lgdnum,
                                 a_cts11m00[2].lgdcep,
                                 a_cts11m00[2].lgdcepcmp,
                                 a_cts11m00[2].lclltt,
                                 a_cts11m00[2].lcllgt,
                                 a_cts11m00[2].lclrefptotxt,
                                 a_cts11m00[2].lclcttnom,
                                 a_cts11m00[2].dddcod,
                                 a_cts11m00[2].lcltelnum,
                                 a_cts11m00[2].c24lclpdrcod,
                                 a_cts11m00[2].ofnnumdig,
                                 a_cts11m00[2].celteldddcod   ,
                                 a_cts11m00[2].celtelnum,
                                 a_cts11m00[2].endcmp,
                                 hist_cts11m00.*,
                                 a_cts11m00[2].emeviacod)
                       returning a_cts11m00[2].lclidttxt,
                                 a_cts11m00[2].cidnom,
                                 a_cts11m00[2].ufdcod,
                                 a_cts11m00[2].brrnom,
                                 a_cts11m00[2].lclbrrnom,
                                 a_cts11m00[2].endzon,
                                 a_cts11m00[2].lgdtip,
                                 a_cts11m00[2].lgdnom,
                                 a_cts11m00[2].lgdnum,
                                 a_cts11m00[2].lgdcep,
                                 a_cts11m00[2].lgdcepcmp,
                                 a_cts11m00[2].lclltt,
                                 a_cts11m00[2].lcllgt,
                                 a_cts11m00[2].lclrefptotxt,
                                 a_cts11m00[2].lclcttnom,
                                 a_cts11m00[2].dddcod,
                                 a_cts11m00[2].lcltelnum,
                                 a_cts11m00[2].c24lclpdrcod,
                                 a_cts11m00[2].ofnnumdig,
                                 a_cts11m00[2].celteldddcod   ,
                                 a_cts11m00[2].celtelnum,
                                 a_cts11m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts11m00.*,
                                 a_cts11m00[2].emeviacod
                else
                   call cts06g11(2,
                                 l_atdsrvorg,
                                 w_cts11m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts11m00[2].lclidttxt,
                                 a_cts11m00[2].cidnom,
                                 a_cts11m00[2].ufdcod,
                                 a_cts11m00[2].brrnom,
                                 a_cts11m00[2].lclbrrnom,
                                 a_cts11m00[2].endzon,
                                 a_cts11m00[2].lgdtip,
                                 a_cts11m00[2].lgdnom,
                                 a_cts11m00[2].lgdnum,
                                 a_cts11m00[2].lgdcep,
                                 a_cts11m00[2].lgdcepcmp,
                                 a_cts11m00[2].lclltt,
                                 a_cts11m00[2].lcllgt,
                                 a_cts11m00[2].lclrefptotxt,
                                 a_cts11m00[2].lclcttnom,
                                 a_cts11m00[2].dddcod,
                                 a_cts11m00[2].lcltelnum,
                                 a_cts11m00[2].c24lclpdrcod,
                                 a_cts11m00[2].ofnnumdig,
                                 a_cts11m00[2].celteldddcod   ,
                                 a_cts11m00[2].celtelnum,
                                 a_cts11m00[2].endcmp,
                                 hist_cts11m00.*,
                                 a_cts11m00[2].emeviacod)
                       returning a_cts11m00[2].lclidttxt,
                                 a_cts11m00[2].cidnom,
                                 a_cts11m00[2].ufdcod,
                                 a_cts11m00[2].brrnom,
                                 a_cts11m00[2].lclbrrnom,
                                 a_cts11m00[2].endzon,
                                 a_cts11m00[2].lgdtip,
                                 a_cts11m00[2].lgdnom,
                                 a_cts11m00[2].lgdnum,
                                 a_cts11m00[2].lgdcep,
                                 a_cts11m00[2].lgdcepcmp,
                                 a_cts11m00[2].lclltt,
                                 a_cts11m00[2].lcllgt,
                                 a_cts11m00[2].lclrefptotxt,
                                 a_cts11m00[2].lclcttnom,
                                 a_cts11m00[2].dddcod,
                                 a_cts11m00[2].lcltelnum,
                                 a_cts11m00[2].c24lclpdrcod,
                                 a_cts11m00[2].ofnnumdig,
                                 a_cts11m00[2].celteldddcod   ,
                                 a_cts11m00[2].celtelnum,
                                 a_cts11m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts11m00.*,
                                 a_cts11m00[2].emeviacod
                end if

                #Projeto alteracao cadastro de destino
                let m_grava_hist = false

                if g_documento.acao = "ALT" then

                   call cts11m00_verifica_tipo_atendim()
                      returning l_status, l_atdetpcod

                   if l_status = 0 then

                      if l_atdetpcod = 4 then

                         let ws.confirma = null
                         while ws.confirma = " " or
                               ws.confirma  is null

                               call cts08g01("C","S",""
                                            ,"ALTERAR ENDERECO DE DESTINO? "
                                            ,"","")
                                  returning ws.confirma
                         end while

                         if ws.confirma = "S" then

                            let l_status = null
                            call cts11m00_verifica_op_ativa()
                               returning l_status

                            if l_status then

                               error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                               error " Servico ja' acionado nao pode ser alterado!"
                               let m_srv_acionado = true
                               call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                             " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                             "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                                    returning ws.confirma

                               # INICIO PSI-2013-00440PR
                               if m_agendaw = false   # regulacao antiga
                                  then
                                  call cts02m03(w_cts11m00.atdfnlflg,
                                                d_cts11m00.imdsrvflg,
                                                w_cts11m00.atdhorpvt,
                                                w_cts11m00.atddatprg,
                                                w_cts11m00.atdhorprg,
                                                w_cts11m00.atdpvtretflg)
                                      returning w_cts11m00.atdhorpvt,
                                                w_cts11m00.atddatprg,
                                                w_cts11m00.atdhorprg,
                                                w_cts11m00.atdpvtretflg
			                      else
                                  call cts02m08(w_cts11m00.atdfnlflg,
                                                d_cts11m00.imdsrvflg,
                                                m_altcidufd,
                                                d_cts11m00.prslocflg,
                                                w_cts11m00.atdhorpvt,
                                                w_cts11m00.atddatprg,
                                                w_cts11m00.atdhorprg,
                                                w_cts11m00.atdpvtretflg,
                                                m_rsrchvant,
                                                m_operacao,
                                                "",
                                                a_cts11m00[1].cidnom,
                                                a_cts11m00[1].ufdcod,
                                                "",   # codigo de assistencia, nao existe no Ct24h
                                                d_cts11m00.vclcoddig,
                                                m_ctgtrfcod,
                                                d_cts11m00.imdsrvflg,
                                                a_cts11m00[1].c24lclpdrcod,
                                                a_cts11m00[1].lclltt,
                                                a_cts11m00[1].lcllgt,
                                                g_documento.ciaempcod,
                                                g_documento.atdsrvorg,
                                                d_cts11m00.asitipcod,
                                                "",   # natureza nao tem, identifica pelo asitipcod
                                                "")   # sub-natureza nao tem, identifica pelo asitipcod
                                      returning w_cts11m00.atdhorpvt,
                                                w_cts11m00.atddatprg,
                                                w_cts11m00.atdhorprg,
                                                w_cts11m00.atdpvtretflg,
                                                d_cts11m00.imdsrvflg,
                                                m_rsrchv,
                                                m_operacao,
                                                m_altdathor

                                  display by name d_cts11m00.imdsrvflg
                               end if

                               call cts11m00_bkp_info_dest(2, hist_cts11m00.*)
                                  returning hist_cts11m00.*

                               next field frmflg

                            else

                               let m_grava_hist   = true
                               let m_srv_acionado = false

                               let m_subbairro[2].lclbrrnom = a_cts11m00[2].lclbrrnom
                               call cts06g10_monta_brr_subbrr(a_cts11m00[2].brrnom,
                                                              a_cts11m00[2].lclbrrnom)
                                  returning a_cts11m00[2].lclbrrnom

                               let a_cts11m00[2].lgdtxt = a_cts11m00[2].lgdtip clipped, " ",
                                                          a_cts11m00[2].lgdnom clipped, " ",
                                                          a_cts11m00[2].lgdnum using "<<<<#"

                               let d_cts11m00.dstlcl    = a_cts11m00[2].lclidttxt
                               let d_cts11m00.dstlgdtxt = a_cts11m00[2].lgdtxt
                               let d_cts11m00.dstbrrnom = a_cts11m00[2].lclbrrnom
                               let d_cts11m00.dstcidnom = a_cts11m00[2].cidnom
                               let d_cts11m00.dstufdcod = a_cts11m00[2].ufdcod

                               if a_cts11m00[2].lclltt <> a_cts11m00[3].lclltt or
                                  a_cts11m00[2].lcllgt <> a_cts11m00[3].lcllgt or
                                  (a_cts11m00[3].lclltt is null and a_cts11m00[2].lclltt is not null) or
                                  (a_cts11m00[3].lcllgt is null and a_cts11m00[2].lcllgt is not null) then

                                  if g_documento.c24astcod <> 'M15' and
                                     g_documento.c24astcod <> 'M20' and
                                     g_documento.c24astcod <> 'M23' and
                                     g_documento.c24astcod <> 'M33' then
                                     call cts00m33(1,
                                                   a_cts11m00[1].lclltt,
                                                   a_cts11m00[1].lcllgt,
                                                   a_cts11m00[2].lclltt,
                                                   a_cts11m00[2].lcllgt)
                                     if cty31g00_valida_clausula() then
                                         #----------------------------------------------------------
                                         # Calcula o Limite de Kilometragem
                                         #----------------------------------------------------------
                                          call cts00m33_calckm("",
                                                               a_cts11m00[1].lclltt,
                                                               a_cts11m00[1].lcllgt,
                                                               a_cts11m00[2].lclltt,
                                                               a_cts11m00[2].lcllgt,
                                                               l_limite_km         )
                                     end if
                                  end if
                               end if



							                ###Moreira-Envia-QRU-GPS

                              initialize  m_mdtcod, m_pstcoddig,
                                          m_socvclcod, m_srrcoddig,
                                          l_msgaltend, l_texto,
                                          l_dtalt, l_hralt,
                                          l_vclcordes, l_lgdtxtcl,
                                          l_ciaempnom, l_msgrtgps,
                                          l_codrtgps  to  null

                              if m_grava_hist = true then
                                 if ctx34g00_ver_acionamentoWEB(2) then

                               whenever error continue
                               if w_cts11m00.socvclcod is null then
                                  select socvclcod
                                    into w_cts11m00.socvclcod
                                    from datmsrvacp acp
                                   where acp.atdsrvnum = g_documento.atdsrvnum
                                     and acp.atdsrvano = g_documento.atdsrvano
                                     and acp.atdsrvseq = (select max(atdsrvseq)
                                                            from datmsrvacp acp1
                                                           where acp1.atdsrvnum = acp.atdsrvnum
                                                             and acp1.atdsrvano = acp.atdsrvano)
                               end if

                               #display 'w_cts11m00.socvclcod ', w_cts11m00.socvclcod

                                    select mdtcod
                                    into m_mdtcod
                                    from datkveiculo
                                    where socvclcod = w_cts11m00.socvclcod

                                    select datkveiculo.pstcoddig,
                                           datkveiculo.socvclcod,
                                           dattfrotalocal.srrcoddig
                                    into m_pstcoddig, m_socvclcod, m_srrcoddig
                                    from datkveiculo, dattfrotalocal
                                    where dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                    and datkveiculo.mdtcod = m_mdtcod

                                    select cpodes
                                    into l_vclcordes
                                    from iddkdominio
                                    where cponom = "vclcorcod"
                                    and cpocod = w_cts11m00.vclcorcod

                                    select empnom
                                    into l_ciaempnom
                                    from gabkemp
                                    where empcod  = g_documento.ciaempcod


                                    whenever error stop

                                    let l_dtalt = today
                                    let l_hralt = current
                                    let l_lgdtxtcl = a_cts11m00[2].lgdtip clipped, " ",
                                                     a_cts11m00[2].lgdnom clipped, " ",
                                                     a_cts11m00[2].lgdnum using "<<<<#", " ",
                                                     a_cts11m00[2].endcmp clipped


                                    let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                                  l_ciaempnom clipped,
                                                  '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             		  	    let l_msgaltend = l_texto clipped
                                      ," QRU: ", m_atdsrvorg using "&&"
                                           ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                           ,"-", g_documento.atdsrvano using "&&"
                                      ," QTR: ", l_dtalt, " ", l_hralt
                                      ," QNC: ", d_cts11m00.nom             clipped, " "
                                               , d_cts11m00.vcldes          clipped, " "
                                               , d_cts11m00.vclanomdl       clipped, " "
                                      ," QNR: ", d_cts11m00.vcllicnum       clipped, " "
                                               , l_vclcordes       clipped, " "
                                      ," QTI: ", a_cts11m00[2].lclidttxt       clipped, " - "
                                               , l_lgdtxtcl                 clipped, " - "
                                               , a_cts11m00[2].brrnom          clipped, " - "
                                               , a_cts11m00[2].cidnom          clipped, " - "
                                               , a_cts11m00[2].ufdcod          clipped, " "
                                      ," Ref: ", a_cts11m00[2].lclrefptotxt    clipped, " "
                                     ," Resp: ", a_cts11m00[2].lclcttnom       clipped, " "
                                     ," Tel: (", a_cts11m00[2].dddcod          clipped, ") "
                                               , a_cts11m00[2].lcltelnum       clipped, " "
          #                          ," Acomp: ", d_cts11m00.rmcacpflg          clipped, "#"


                                     #display "m_pstcoddig: ", m_pstcoddig
                                     #display "m_socvclcod: ", m_socvclcod
                                     #display "m_srrcoddig: ", m_srrcoddig
                                     #display "l_msgaltend: ", l_msgaltend
                                     #display "l_codrtgps : ", l_codrtgps

                                    call ctx34g02_enviar_msg_gps(m_pstcoddig,
                                                                 m_socvclcod,
                                                                 m_srrcoddig,
                                                                 l_msgaltend)
                                           returning l_msgrtgps, l_codrtgps

                                     if l_codrtgps = 0 then
                                        display "Mensagem Enviada com Sucesso ao GPS do Prestador"
                                     else
                                        display "Mensagem nao enviada. Erro: ", l_codrtgps,
                                                " - ", l_msgrtgps clipped
                                     end if
                                 end if
                              end if
                             ###Moreira-Envia-QRU-GPS







                               exit input

                            end if
                         else

                            call cts11m00_bkp_info_dest(2, hist_cts11m00.*)
                               returning hist_cts11m00.*

                            let m_srv_acionado = true

                         end if
                      else
                         let m_srv_acionado = false
                      end if

                   else
                      error 'Erro ao buscar tipo de atendimento'
                      let m_srv_acionado = true
                   end if

                   if a_cts11m00[2].cidnom is not null and
                      a_cts11m00[2].ufdcod is not null then
                      call cts14g00 (g_documento.c24astcod,
                                     "","","","",
                                     a_cts11m00[2].cidnom,
                                     a_cts11m00[2].ufdcod,
                                     "S",
                                     ws.dtparam)
                   end if
                   #Fim Projeto alteracao cadastro de destino

                end if
             end if

      end case

   on key (F8)
      if d_cts11m00.asitipcod = 10 then
         call cts11m08(w_cts11m00.trppfrdat,
                       w_cts11m00.trppfrhor)
             returning w_cts11m00.trppfrdat,
                       w_cts11m00.trppfrhor
      end if

   on key (F9)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts11m00.atdlibflg = "N"   then
            error " Servico nao liberado!"
         else
            call cta00m06_acionamento(g_issk.dptsgl)
            returning l_acesso
            if l_acesso = true then
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if
         end if
      end if

   on key (F10)
      call cts11m01 (a_passag[01].*,
                     a_passag[02].*,
                     a_passag[03].*,
                     a_passag[04].*,
                     a_passag[05].*,
                     a_passag[06].*,
                     a_passag[07].*,
                     a_passag[08].*,
                     a_passag[09].*,
                     a_passag[10].*,
                     a_passag[11].*,
                     a_passag[12].*,
                     a_passag[13].*,
                     a_passag[14].*,
                     a_passag[15].*)
           returning a_passag[01].*,
                     a_passag[02].*,
                     a_passag[03].*,
                     a_passag[04].*,
                     a_passag[05].*,
                     a_passag[06].*,
                     a_passag[07].*,
                     a_passag[08].*,
                     a_passag[09].*,
                     a_passag[10].*,
                     a_passag[11].*,
                     a_passag[12].*,
                     a_passag[13].*,
                     a_passag[14].*,
                     a_passag[15].*

   on key(F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

##PSI207233
   on key (F2)
       if g_documento.atdsrvnum is not null then
           if m_c24astcodflag = "S11"  or
              m_c24astcodflag = "S14"  or
              m_c24astcodflag = "S53"  or
              m_c24astcodflag = "S64"  or
              m_c24astcodflag = "SUC"  then
               call ctb83m00()
                   returning m_retctb83m00
           else
              error "Esse assunto nao possui tipo de pagamento"
           end if
       end if
##PSI207233

 end input

 if int_flag then
    error " Operacao cancelada!"
 end if

 return hist_cts11m00.*

end function  ###  input_cts11m00
#------------------------------------------
function cts11m00_mtv_cls46_47(l_param)
#------------------------------------------
 define l_param record
        ciaempcod like datmservico.ciaempcod,
        asimtvcod like datkasimtv.asimtvcod
 end record
 define l_qtde integer
 let l_qtde = 0
 select count(*)
   into l_qtde
   from datmligacao a,
        datrligapol b,
        datmassistpassag c,
        datmservico e
 where  a.lignum    = b.lignum
 and    a.atdsrvnum = c.atdsrvnum
 and    a.atdsrvano = c.atdsrvano
 and    a.atdsrvnum = e.atdsrvnum
 and    a.atdsrvano = e.atdsrvano
 and    a.c24astcod = g_documento.c24astcod
 and    c.asimtvcod = l_param.asimtvcod
 and    e.ciaempcod = l_param.ciaempcod
 and    b.succod    = g_documento.succod
 and    b.aplnumdig = g_documento.aplnumdig
 and    b.itmnumdig = g_documento.itmnumdig
 and    b.ramcod    = g_documento.ramcod
 and    e.atdetpcod <> 5
 return l_qtde
end function

#--------------------------------------------------------#
 function cts11m00_bkp_info_dest(l_tipo, hist_cts11m00)
#--------------------------------------------------------#
  define hist_cts11m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts11m00_bkp      to null
     initialize m_hist_cts11m00_bkp to null

     let a_cts11m00_bkp[1].lclidttxt    = a_cts11m00[2].lclidttxt
     let a_cts11m00_bkp[1].cidnom       = a_cts11m00[2].cidnom
     let a_cts11m00_bkp[1].ufdcod       = a_cts11m00[2].ufdcod
     let a_cts11m00_bkp[1].brrnom       = a_cts11m00[2].brrnom
     let a_cts11m00_bkp[1].lclbrrnom    = a_cts11m00[2].lclbrrnom
     let a_cts11m00_bkp[1].endzon       = a_cts11m00[2].endzon
     let a_cts11m00_bkp[1].lgdtip       = a_cts11m00[2].lgdtip
     let a_cts11m00_bkp[1].lgdnom       = a_cts11m00[2].lgdnom
     let a_cts11m00_bkp[1].lgdnum       = a_cts11m00[2].lgdnum
     let a_cts11m00_bkp[1].lgdcep       = a_cts11m00[2].lgdcep
     let a_cts11m00_bkp[1].lgdcepcmp    = a_cts11m00[2].lgdcepcmp
     let a_cts11m00_bkp[1].lclltt       = a_cts11m00[2].lclltt
     let a_cts11m00_bkp[1].lcllgt       = a_cts11m00[2].lcllgt
     let a_cts11m00_bkp[1].lclrefptotxt = a_cts11m00[2].lclrefptotxt
     let a_cts11m00_bkp[1].lclcttnom    = a_cts11m00[2].lclcttnom
     let a_cts11m00_bkp[1].dddcod       = a_cts11m00[2].dddcod
     let a_cts11m00_bkp[1].lcltelnum    = a_cts11m00[2].lcltelnum
     let a_cts11m00_bkp[1].c24lclpdrcod = a_cts11m00[2].c24lclpdrcod
     let a_cts11m00_bkp[1].ofnnumdig    = a_cts11m00[2].ofnnumdig
     let a_cts11m00_bkp[1].celteldddcod = a_cts11m00[2].celteldddcod
     let a_cts11m00_bkp[1].celtelnum    = a_cts11m00[2].celtelnum
     let a_cts11m00_bkp[1].endcmp       = a_cts11m00[2].endcmp
     let m_hist_cts11m00_bkp.hist1      = hist_cts11m00.hist1
     let m_hist_cts11m00_bkp.hist2      = hist_cts11m00.hist2
     let m_hist_cts11m00_bkp.hist3      = hist_cts11m00.hist3
     let m_hist_cts11m00_bkp.hist4      = hist_cts11m00.hist4
     let m_hist_cts11m00_bkp.hist5      = hist_cts11m00.hist5
     let a_cts11m00_bkp[1].emeviacod    = a_cts11m00[2].emeviacod

     return hist_cts11m00.*

  else

     let a_cts11m00[2].lclidttxt    = a_cts11m00_bkp[1].lclidttxt
     let a_cts11m00[2].cidnom       = a_cts11m00_bkp[1].cidnom
     let a_cts11m00[2].ufdcod       = a_cts11m00_bkp[1].ufdcod
     let a_cts11m00[2].brrnom       = a_cts11m00_bkp[1].brrnom
     let a_cts11m00[2].lclbrrnom    = a_cts11m00_bkp[1].lclbrrnom
     let a_cts11m00[2].endzon       = a_cts11m00_bkp[1].endzon
     let a_cts11m00[2].lgdtip       = a_cts11m00_bkp[1].lgdtip
     let a_cts11m00[2].lgdnom       = a_cts11m00_bkp[1].lgdnom
     let a_cts11m00[2].lgdnum       = a_cts11m00_bkp[1].lgdnum
     let a_cts11m00[2].lgdcep       = a_cts11m00_bkp[1].lgdcep
     let a_cts11m00[2].lgdcepcmp    = a_cts11m00_bkp[1].lgdcepcmp
     let a_cts11m00[2].lclltt       = a_cts11m00_bkp[1].lclltt
     let a_cts11m00[2].lcllgt       = a_cts11m00_bkp[1].lcllgt
     let a_cts11m00[2].lclrefptotxt = a_cts11m00_bkp[1].lclrefptotxt
     let a_cts11m00[2].lclcttnom    = a_cts11m00_bkp[1].lclcttnom
     let a_cts11m00[2].dddcod       = a_cts11m00_bkp[1].dddcod
     let a_cts11m00[2].lcltelnum    = a_cts11m00_bkp[1].lcltelnum
     let a_cts11m00[2].c24lclpdrcod = a_cts11m00_bkp[1].c24lclpdrcod
     let a_cts11m00[2].ofnnumdig    = a_cts11m00_bkp[1].ofnnumdig
     let a_cts11m00[2].celteldddcod = a_cts11m00_bkp[1].celteldddcod
     let a_cts11m00[2].celtelnum    = a_cts11m00_bkp[1].celtelnum
     let a_cts11m00[2].endcmp       = a_cts11m00_bkp[1].endcmp
     let hist_cts11m00.hist1        = m_hist_cts11m00_bkp.hist1
     let hist_cts11m00.hist2        = m_hist_cts11m00_bkp.hist2
     let hist_cts11m00.hist3        = m_hist_cts11m00_bkp.hist3
     let hist_cts11m00.hist4        = m_hist_cts11m00_bkp.hist4
     let hist_cts11m00.hist5        = m_hist_cts11m00_bkp.hist5
     let a_cts11m00[2].emeviacod    = a_cts11m00_bkp[1].emeviacod

     return hist_cts11m00.*

  end if

end function

#-----------------------------------------#
 function cts11m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open c_cts11m00_004 using g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano

  whenever error continue
  fetch c_cts11m00_004 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT c_cts11m00_004: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts11m00() / C24 / cts11m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts11m00_verifica_op_ativa()
#-----------------------------------------#
  define lr_ret        record
         sttop         smallint
        ,errcod        smallint
        ,errdes        char(150)
  end record

  initialize lr_ret to null

  call ctb30m00_permite_alt_end_dst(g_documento.atdsrvano
                                   ,g_documento.atdsrvnum)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
     return true
  end if

  if lr_ret.sttop then
     return true
  end if

  return false

end function

#-----------------------------------------#
 function cts11m00_grava_historico()
#-----------------------------------------#
  define la_cts11m00       array[12] of record
         descricao         char (70)
  end record

  define lr_de             record
         atdsrvnum         like datmlcl.atdsrvnum
        ,atdsrvano         like datmlcl.atdsrvano
        ,lgdcep            char(9)
        ,cidnom            like datmlcl.cidnom
        ,ufdcod            like datmlcl.ufdcod
        ,lgdtip            like datmlcl.lgdtip
        ,lgdnom            like datmlcl.lgdnom
        ,lgdnum            like datmlcl.lgdnum
        ,brrnom            like datmlcl.brrnom
   end record

  define lr_para          record
         atdsrvnum        like datmlcl.atdsrvnum
        ,atdsrvano        like datmlcl.atdsrvano
        ,lgdcep           char(9)
        ,cidnom           like datmlcl.cidnom
        ,ufdcod           like datmlcl.ufdcod
        ,lgdtip           like datmlcl.lgdtip
        ,lgdnom           like datmlcl.lgdnom
        ,lgdnum           like datmlcl.lgdnum
        ,brrnom           like datmlcl.brrnom
  end record

  define lr_ret           record
         errcod           smallint   #Cod. Erro
        ,errdes           char(150)  #Descricao Erro
  end record

  define l_ind            smallint
        ,l_data           date
        ,l_hora           datetime hour to minute
        ,l_dstqtd         decimal(8,4)
        ,l_status         smallint

  initialize la_cts11m00  to null
  initialize lr_de        to null
  initialize lr_para      to null
  initialize lr_ret       to null

  let l_ind    = null
  let l_data   = null
  let l_hora   = null
  let l_dstqtd = null
  let l_status = null

  #busca a distancia entre os pontos
  whenever error continue
  select dstqtd
    into l_dstqtd
    from tmp_distancia
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_dstqtd = 0
  end if

  let la_cts11m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts11m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts11m00[03].descricao = "."
  let la_cts11m00[04].descricao = "DE:"
  let la_cts11m00[05].descricao = "CEP: ", a_cts11m00_bkp[1].lgdcep clipped," - ",a_cts11m00_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts11m00_bkp[1].cidnom clipped," UF: ",a_cts11m00_bkp[1].ufdcod clipped
  let la_cts11m00[06].descricao = "Logradouro: ",a_cts11m00_bkp[1].lgdtip clipped," ",a_cts11m00_bkp[1].lgdnom clipped," "
                                                ,a_cts11m00_bkp[1].lgdnum clipped," ",a_cts11m00_bkp[1].brrnom
  let la_cts11m00[07].descricao = "."
  let la_cts11m00[08].descricao = "PARA:"
  let la_cts11m00[09].descricao = "CEP: ", a_cts11m00[2].lgdcep clipped," - ", a_cts11m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts11m00[2].cidnom clipped," UF: ",a_cts11m00[2].ufdcod  clipped
  let la_cts11m00[10].descricao = "Logradouro: ",a_cts11m00[2].lgdtip clipped," ",a_cts11m00[2].lgdnom clipped," "
                                                ,a_cts11m00[2].lgdnum clipped," ",a_cts11m00[2].brrnom
  let la_cts11m00[11].descricao = "."
  let la_cts11m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts11m00[l_ind].descricao
                            ,"","","","")
        returning l_status

     if l_status <> 0  then
        error "Erro (" , l_status, ") na inclusao do historico De/Para. " sleep 3
        error "Historico podera ser gravado com problemas." sleep 3
     end if

  end for

  #Chama funcao porto socorro que envia email do comunicado de alteracao
  let lr_de.atdsrvnum = g_documento.atdsrvnum
  let lr_de.atdsrvano = g_documento.atdsrvano
  let lr_de.lgdcep    = a_cts11m00_bkp[1].lgdcep clipped,"-",a_cts11m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts11m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts11m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts11m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts11m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts11m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts11m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts11m00[2].lgdcep clipped,"-", a_cts11m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts11m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts11m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts11m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts11m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts11m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts11m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function