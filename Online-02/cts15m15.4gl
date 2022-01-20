#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS15M15                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 205.206 - AZUL SEGUROS                                     #
#                  LAUDO - RESERVA DE LOCACAO DE VEICULOS (ASSUNTO KA1).      #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 26/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
# 30/10/2009 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Livre Escolha: 58E-05dias / 58F-10dias#
#                                                      58G-15dias / 58H-30dias#
#-----------------------------------------------------------------------------#
# 04/01/2010 Amilton                    Projeto sucursal smallint             #
#-----------------------------------------------------------------------------#
# 05/02/2010 Carla Rampazzo PSI 253596  Tratar nova Clausula:                 #
#                                       37C : Assist.24h - Assit.Gratuita     #
#-----------------------------------------------------------------------------#
# 15/07/2010 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Referenciada : 58I -  7 dias          #
#                                                      58J - 15 dias          #
#                                                      58K - 15 dias          #
#                                                                             #
#                                       Livre Escolha: 58L -  7 dias          #
#                                                      58M - 15 dias          #
#                                                      58N - 15 dias          #
#-----------------------------------------------------------------------------#
# 24/01/2012 Anderson Doblinski         Criando um novo motivo, motivo 18.    #
#-----------------------------------------------------------------------------#
#07-03-2013 Jorge Modena  PSI-2013-04081 Criação de dois novos campos no ban  #
#                                         co para salvar celular de reservas  #
#                                         de locadoras que nao possuem inte-  #
#                                         gracao automatica                   #
#                                                                             #
#---------- -------------- ---------- ----------------------------------------#

#------------------------------------------------------------------------#
#                       OBSERVACOES IMPORTANTES                          #
#------------------------------------------------------------------------#
# ESTE MODULO E UMA COPIA DO CTS15M00.                                   #
# APESAR DE SER UM FONTE NOVO, O NOME DAS VARIAVAIES ESTA FORA DO        #
# PADRAO. A MAIORIA DOS ACESSOS NAO ESTA PREPARADO NA FUNCAO PREPARE.    #
# EM RAZAO DO CURTO ESPACO DE TEMPO PARA ENTREGAR ESTE PROJETO DA AZUL,  #
# VAMOS LIBERAR EM PRODUCAO DESTA MANEIRA.                               #
# FUTURAMENTE VAMOS COLOCAR ESTE MODULO NO PADRAO DE CODIFICACAO.        #
#                                                                        #
# ASS: LUCAS SCHEID                                                      #
#------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

define d_cts15m15    record
    servico           char (13)                        ,
    c24solnom         like datmligacao.c24solnom       ,
    nom               like datmservico.nom             ,
    doctxt            char (32)                        ,
    corsus            like datmservico.corsus          ,
    cornom            like datmservico.cornom          ,
    cvnnom            char (19)                        ,
    vclcoddig         like datmservico.vclcoddig       ,
    vcldes            like datmservico.vcldes          ,
    vclanomdl         like datmservico.vclanomdl       ,
    vcllicnum         like datmservico.vcllicnum       ,
    vclloctip         like datmavisrent.vclloctip      ,
    vcllocdes         char (08)                        ,
    c24astcod         like datkassunto.c24astcod       ,
    c24astdes         char (72)                        ,
    avilocnom         like datmavisrent.avilocnom      ,
    cdtoutflg         like datmavisrent.cdtoutflg      ,
    cdtsegtaxvlr      like datklocadora.cdtsegtaxvlr   ,
    avialgmtv         like datmavisrent.avialgmtv      ,
    avimtvdes         char (16)                        ,
    lcvsinavsflg      like datmavisrent.lcvsinavsflg   ,
    lcvcod            like datklocadora.lcvcod         ,
    lcvnom            like datklocadora.lcvnom         ,
    lcvextcod         like datkavislocal.lcvextcod     ,
    aviestnom         like datkavislocal.aviestnom     ,
    aviestcod         like datmavisrent.aviestcod      ,
    avivclcod         like datkavisveic.avivclcod      ,
    avivclgrp         like datkavisveic.avivclgrp      ,
    avivcldes         char (65)                        ,
    vcldiavlr         like datmavisrent.avivclvlr      ,
    avivclvlr         like datmavisrent.avivclvlr      ,
    locsegvlr         like datmavisrent.locsegvlr      ,
    frqvlr            like datkavisveic.frqvlr         ,
    isnvlr            like datkavisveic.isnvlr         ,
    rduvlr            like datkavisveic.rduvlr         ,
    cndtxt            char (20)                        ,
    prgtxt            char (11)                        ,
    frmflg            char (01)                        ,
    aviproflg         char (01)                        ,
    cttdddcod         like datmavisrent.cttdddcod      ,
    ctttelnum         like datmavisrent.ctttelnum      ,
    atdlibflg         like datmservico.atdlibflg       ,
    atdlibtxt         char (65)                        ,
    cauchqflg         like datkavislocal.cauchqflg     ,
    locrspcpfnum      like datmavisrent.locrspcpfnum   ,
    locrspcpfdig      like datmavisrent.locrspcpfdig   ,
    atdsrvnum         like datmservico.atdsrvnum       ,
    atdsrvano         like datmservico.atdsrvano       ,
    dtentvcl          date                             ,
    smsenvdddnum      like datmrsvvcl.smsenvdddnum     ,
    smsenvcelnum      like datmrsvvcl.smsenvcelnum     ,
    garantia          char(20),
    flgarantia        char(1),
    acntip            like datklocadora.acntip
 end record
define m_cts15ant    record
    servico           char (13)                        ,
    c24solnom         like datmligacao.c24solnom       ,
    nom               like datmservico.nom             ,
    doctxt            char (32)                        ,
    corsus            like datmservico.corsus          ,
    cornom            like datmservico.cornom          ,
    cvnnom            char (19)                        ,
    vclcoddig         like datmservico.vclcoddig       ,
    vcldes            like datmservico.vcldes          ,
    vclanomdl         like datmservico.vclanomdl       ,
    vcllicnum         like datmservico.vcllicnum       ,
    vclloctip         like datmavisrent.vclloctip      ,
    vcllocdes         char (08)                        ,
    c24astcod         like datkassunto.c24astcod       ,
    c24astdes         char (72)                        ,
    avilocnom         like datmavisrent.avilocnom      ,
    cdtoutflg         like datmavisrent.cdtoutflg      ,
    cdtsegtaxvlr      like datklocadora.cdtsegtaxvlr   ,
    avialgmtv         like datmavisrent.avialgmtv      ,
    avimtvdes         char (16)                        ,
    lcvsinavsflg      like datmavisrent.lcvsinavsflg   ,
    lcvcod            like datklocadora.lcvcod         ,
    lcvnom            like datklocadora.lcvnom         ,
    lcvextcod         like datkavislocal.lcvextcod     ,
    aviestnom         like datkavislocal.aviestnom     ,
    aviestcod         like datmavisrent.aviestcod      ,
    avivclcod         like datkavisveic.avivclcod      ,
    avivclgrp         like datkavisveic.avivclgrp      ,
    avivcldes         char (65)                        ,
    vcldiavlr         like datmavisrent.avivclvlr      ,
    avivclvlr         like datmavisrent.avivclvlr      ,
    locsegvlr         like datmavisrent.locsegvlr      ,
    frqvlr            like datkavisveic.frqvlr         ,
    isnvlr            like datkavisveic.isnvlr         ,
    rduvlr            like datkavisveic.rduvlr         ,
    cndtxt            char (20)                        ,
    prgtxt            char (11)                        ,
    frmflg            char (01)                        ,
    aviproflg         char (01)                        ,
    cttdddcod         like datmavisrent.cttdddcod      ,
    ctttelnum         like datmavisrent.ctttelnum      ,
    atdlibflg         like datmservico.atdlibflg       ,
    atdlibtxt         char (65)                        ,
    cauchqflg         like datkavislocal.cauchqflg     ,
    locrspcpfnum      like datmavisrent.locrspcpfnum   ,
    locrspcpfdig      like datmavisrent.locrspcpfdig   ,
    atdsrvnum         like datmservico.atdsrvnum       ,
    atdsrvano         like datmservico.atdsrvano       ,
    dtentvcl          date                             ,
    smsenvdddnum      like datmrsvvcl.smsenvdddnum     ,
    smsenvcelnum      like datmrsvvcl.smsenvcelnum     ,
    garantia          char(20),
    flgarantia        char(1),
    acntip            like datklocadora.acntip
 end record

 define w_cts15m15    record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    cnldat            like datmservico.cnldat      ,
    c24opemat         like datmservico.c24opemat   ,
    clscod            like abbmclaus.clscod        ,
    clsflg            smallint                     ,
    sldqtd            smallint                     ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    empcod            like datmservico.empcod      ,
    avidiaqtd         like datmavisrent.avidiaqtd  ,
    aviretdat         like datmavisrent.aviretdat  ,
    avirethor         like datmavisrent.avirethor  ,
    aviprvent         like datmavisrent.aviprvent  ,
    avioccdat         like datmavisrent.avioccdat  ,
    ofnnom            like datmavisrent.ofnnom     ,
    ofndddcod         like datmavisrent.dddcod     ,
    ofntelnum         like datmavisrent.telnum     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    datasaldo         date                         ,
    slcemp            like datmavisrent.slcemp     ,
    slcsuccod         like datmavisrent.slcsuccod  ,
    slcmat            like datmavisrent.slcmat     ,
    slccctcod         like datmavisrent.slccctcod  ,
    locrspcpfnum      like datmavisrent.locrspcpfnum,
    locrspcpfdig      like datmavisrent.locrspcpfdig,
    procan            CHAR(01),
    aviprodiaqtd      LIKE datmprorrog.aviprodiaqtd,
    temcls            smallint                     ,
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define w_titulo                 like dammtrx.c24msgtit,
        w_lintexto               like dammtrxtxt.c24trxtxt

 define m_clcdat     like abbmcasco.clcdat
       ,m_cts08g01   char(01)
       ,m_histerr    smallint

 define m_prep_sql smallint
 define m_prep     smallint
 define m_envio    smallint
 define m_erro     smallint
 define m_cidnom   like datmlcl.cidnom
 define m_ufdcod   like datmlcl.ufdcod
 define m_erro_msg char(70)
 define m_cct      integer
 define m_prorrog  smallint

 define slv_segurado  record
    succod            like datrligapol.succod      ,
    ramcod            like gtakram.ramcod          ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    edsnumref         like datrligapol.edsnumref   ,
    lignum            like datmligacao.lignum      ,
    c24soltipcod      like datmligacao.c24soltipcod,
    solnom            char (15)                    ,
    c24astcod         like datkassunto.c24astcod   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapacorg         like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    dctnumseq         dec (04,00)                  ,
    vclsitatu         dec (04,00)                  ,
    autsitatu         dec (04,00)                  ,
    dmtsitatu         dec (04,00)                  ,
    dpssitatu         dec (04,00)
 end record

 define slv_terceiro  record
    succod            like datrligapol.succod      ,
    ramcod            like gtakram.ramcod          ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    edsnumref         like datrligapol.edsnumref   ,
    lignum            like datmligacao.lignum      ,
    c24soltipcod      like datmligacao.c24soltipcod,
    solnom            char (15)                    ,
    c24astcod         like datkassunto.c24astcod   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapacorg         like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    dctnumseq         dec (04,00)                  ,
    vclsitatu         dec (04,00)                  ,
    autsitatu         dec (04,00)                  ,
    dmtsitatu         dec (04,00)                  ,
    dpssitatu         dec (04,00)
 end record

 define mr_geral     record
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        ligcvntip    like datmligacao.ligcvntip,
        succod       like datrligapol.succod,
        ramcod       like datrservapol.ramcod,
        aplnumdig    like datrligapol.aplnumdig,
        itmnumdig    like datrligapol.itmnumdig,
        acao         char(03),
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        c24astcod    like datkassunto.c24astcod,
        solnom       char(15),
        atdsrvorg    like datmservico.atdsrvorg,
        edsnumref    like datrligapol.edsnumref,
        fcapacorg    like datrligpac.fcapacorg,
        fcapacnum    like datrligpac.fcapacnum,
        lignum       like datmligacao.lignum,
        soltip       char(01),
        c24soltipcod like datmligacao.c24soltipcod,
        lclocodesres char(01),
        itaciacod    like datrligitaaplitm.itaciacod
 end record

 define mr_corretor record
        corsus      char(06),
        cornom      char(60),
        dddcod      char(05),
        teltxt      char(30),
        dddfax      char(05),
        factxt      char(30),
        maides      char(100)
 end record

 define mr_segurado record
        nome        char(60),
        cgccpf      char(11),
        pessoa      char(01),
        dddfone     char(04),
        numfone     char(15),
        email       char(100)
 end record

 define mr_veiculo  record
        codigo      char(10),
        marca       char(30),
        tipo        char(30),
        modelo      char(30),
        chassi      char(20),
        placa       char(07),
        anofab      char(04),
        anomod      char(04),
        catgtar     char(10),
        automatico  char(03)
 end record

  define hist_cts15m15 record
         hist1  like datmservhist.c24srvdsc ,
         hist2  like datmservhist.c24srvdsc ,
         hist3  like datmservhist.c24srvdsc ,
         hist4  like datmservhist.c24srvdsc ,
         hist5  like datmservhist.c24srvdsc
  end record

  define l_handle integer
  define m_opcao    smallint
  define m_reenvio  smallint
  define m_flag_alt  smallint

  define m_ctd07g05       record
          empcod           like datmsrvacp.empcod
         ,funmat           like datmsrvacp.funmat
         ,atdetpcod        like datmsrvacp.atdetpcod
         ,pstcoddig        like datmsrvacp.pstcoddig
         ,srrcoddig        like datmsrvacp.srrcoddig
   end record
 define m_f7 smallint
   define m_reserva record
        erro        smallint,
        rsvlclcod   like datmrsvvcl.rsvlclcod ,
        loccntcod   like datmrsvvcl.loccntcod,
        rsvsttcod   like datmrsvvcl.rsvsttcod
 end record
   define m_ctd31 record
          sqlcode smallint,
          mens    char(80),
          rsvlclcod   like datmrsvvcl.rsvlclcod
   end record

#-------------------------#
function cts15m15_prepara()
#-------------------------#

   define l_sqlstmt  char(700)

   let l_sqlstmt = ' select cpodes ',
                   '   from iddkdominio ',
                   '  where cponom = "avialgmtv" ',
                   '    and cpocod = ? '

   prepare p_cts15m15_001 from l_sqlstmt
   declare c_cts15m15_001 cursor for p_cts15m15_001

   let l_sqlstmt = " select b.atdsrvnum ,b.atdsrvano     "
                  ,"   from datrservapol a,datmservico b "
                  ,"       ,datmligacao c                "
                  ,"  where a.succod = ?                 "
                  ,"    and a.ramcod in (31,531)         "
                  ,"    and a.aplnumdig = ?              "
                  ,"    and a.itmnumdig = ?              "
                  ,"    and a.edsnumref >= 0             "
                  ,"    and b.atdsrvnum = a.atdsrvnum    "
                  ,"    and b.atdsrvano = a.atdsrvano    "
                  ,"    and b.atddat between ? and ?     "
                  ,"    and b.atdsrvorg   = 8            "
                  ,"    and b.atdsrvnum   = c.atdsrvnum  "
                  ,"    and b.atdsrvano   = c.atdsrvano  "
                  ,"    and c.c24astcod   = 'KA1'        "
   prepare p_cts15m15_002 from l_sqlstmt
   declare c_cts15m15_002 cursor
       for p_cts15m15_002

   let l_sqlstmt = 'select lcvcod      , avivclcod    , avivclvlr ,   '
                        ,' aviestcod   , avialgmtv    , avilocnom ,   '
                        ,' aviretdat   , avirethor    , aviprvent ,   '
                        ,' locsegvlr   , vclloctip    , avioccdat ,   '
                        ,' ofnnom      , dddcod       , telnum    ,   '
                        ,' cttdddcod   , ctttelnum    , avirsrgrttip, '
                        ,' slcemp      , slcsuccod    , slcmat      , '
                        ,' slccctcod   , cdtoutflg    , locrspcpfnum, '
                        ,' locrspcpfdig, lcvsinavsflg '
                   ,' from datmavisrent '
                   ,' where atdsrvnum = ? '
                     ,' and atdsrvano = ? '

   prepare p_cts15m15_003 from l_sqlstmt
   declare c_cts15m15_003 cursor for p_cts15m15_003

   let l_sqlstmt = 'update datmavisrent set (lcvcod   , avivclcod, aviestcod   , '
                                          ,' avivclvlr, locsegvlr, avialgmtv   , '
                                          ,' avidiaqtd, avilocnom, aviretdat   , '
                                          ,' avirethor, aviprvent, avioccdat   , '
                                          ,' ofnnom   , dddcod   , telnum      , '
                                          ,' cttdddcod, ctttelnum, avirsrgrttip, '
                                          ,' slcemp   , slcsuccod, slcmat      , '
                                          ,' slccctcod, cdtoutflg, vclloctip   , '
                                          ,' locrspcpfnum, locrspcpfdig, lcvsinavsflg, '
                                          ,' smsenvdddnum, smsenvcelnum ) '
                                       ,' = (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '
                                          ,' ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
                  ,' where atdsrvnum = ? '
                    ,' and atdsrvano = ? '

   prepare p_cts15m15_004 from l_sqlstmt

   let l_sqlstmt = 'insert into datmavisrent (atdsrvnum, atdsrvano, lcvcod   , avivclcod, aviestcod, '
                                           ,' avivclvlr, avialgmtv, avidiaqtd, avilocnom, aviretdat, '
                                           ,' avirethor, aviprvent, locsegvlr, vclloctip, avioccdat, '
                                           ,' ofnnom   , dddcod   , telnum   , cttdddcod, ctttelnum, '
                                           ,' avirsrgrttip, slcemp, slcsuccod, slcmat, slccctcod, '
                                           ,' cdtoutflg, locrspcpfnum, locrspcpfdig, lcvsinavsflg, '
                                           ,' smsenvdddnum, smsenvcelnum  ) '
                                   ,' values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '
                                           ,' ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '

   prepare p_cts15m15_005 from l_sqlstmt
   let l_sqlstmt = ' select cpodes ',
                   '   from datkdominio ',
                   '  where cponom = "avialgmtv_azul" ',
                   '    and cpocod = ? '

   prepare pcts15m15008 from l_sqlstmt
   declare ccts15m15008 cursor for pcts15m15008


   let l_sqlstmt = ' select count(*) ',
                   '   from datmavisrent',
                   ' where avialgmtv in ("011","012") ',
                   ' and atdsrvnum = ? ',
                   ' and atdsrvano = ? '

   prepare pcts15m15009 from l_sqlstmt
   declare ccts15m15009 cursor for pcts15m15009

   let l_sqlstmt = 'select lcvextcod,endufd,endcid ',
                   ' from datkavislocal ',
                   ' where ',
                   ' lcvcod    = ?   and ',
                   ' aviestcod = ? '

   prepare pcts15m15034 from l_sqlstmt
   declare ccts15m15034 cursor for pcts15m15034
   let l_sqlstmt = 'select smsenvdddnum,smsenvcelnum ',
                   ' from datmrsvvcl ',
                   ' where ',
                   ' atdsrvnum = ? ',
                   ' and atdsrvano = ? '

   prepare pcts15m15035 from l_sqlstmt
   declare ccts15m15035 cursor for pcts15m15035
   let l_sqlstmt = 'select lcvextcod,endufd,endcid ',
                   ' from datkavislocal ',
                   ' where ',
                   ' lcvcod    = ?   and ',
                   ' aviestcod = ? '
   prepare pcts15m15036 from l_sqlstmt
   declare ccts15m15036 cursor for pcts15m15036
   let l_sqlstmt = 'select lcvcod,aviestcod,aviretdat'
                   ,' , avirethor,aviprvent,avirsrgrttip, cdtoutflg,avialgmtv '
                   ,' from datmavisrent '
                   ,' where atdsrvnum = ? '
                   ,' and atdsrvano = ? '

   prepare pcts15m15037 from l_sqlstmt
   declare ccts15m15037 cursor for pcts15m15037

   let l_sqlstmt = ' select sum(diaqtd) from datmrsrsrvrsm ',
                   ' where atdsrvnum = ? ',
                   ' and atdsrvano =  ? ',
                   ' and empcod > 0 ',
                   ' and aviproseq in (select aviproseq from datmprorrog',
                                      ' where atdsrvnum = ? ',
                                      ' and atdsrvano = ? ',
                                      ' and aviprostt = ?) '
   prepare pcts15m15040 from l_sqlstmt
   declare ccts15m15040 cursor for pcts15m15040
    let l_sqlstmt = 'select aviretdat,avirethor from datmavisrent ',
                   ' where atdsrvnum = ? ',
                   'and atdsrvano =  ? '
    prepare pcts15m15041 from l_sqlstmt
    declare ccts15m15041 cursor for pcts15m15041

    let l_sqlstmt = 'select smsenvdddnum,smsenvcelnum  from datmavisrent ',
                   ' where atdsrvnum = ? ',
                   'and atdsrvano =  ? '
    prepare pcts15m15042 from l_sqlstmt
    declare ccts15m15042 cursor for pcts15m15042
   let m_prep_sql = true

end function  #fim psi175552

#------------------------------#
 function cts15m15(lr_parametro)
#------------------------------#

 define lr_parametro record
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        ligcvntip    like datmligacao.ligcvntip,
        succod       like datrligapol.succod,
        ramcod       like datrservapol.ramcod,
        aplnumdig    like datrligapol.aplnumdig,
        itmnumdig    like datrligapol.itmnumdig,
        acao         char(03),
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        c24astcod    like datkassunto.c24astcod,
        solnom       char(15),
        atdsrvorg    like datmservico.atdsrvorg,
        edsnumref    like datrligapol.edsnumref,
        fcapacorg    like datrligpac.fcapacorg,
        fcapacnum    like datrligpac.fcapacnum,
        lignum       like datmligacao.lignum,
        soltip       char(01),
        c24soltipcod like datmligacao.c24soltipcod,
        lclocodesres char(01)
 end record

 define ws            record
    hoje              char (10),
    vclcordes         char (12),
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    confirma          char (01),
    grvflg            smallint
 end record

 define l_azlaplcod  integer,
        l_resultado  smallint,
        l_mensagem   char(80),
        l_msg_opcoes char(80),
        l_doc_handle integer

 define w_ctgtrfcod   like abbmcasco. ctgtrfcod
       ,w_histerr     smallint
       ,w_c24srvdsc   like datmservhist.c24srvdsc

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_f7        char(10),
        l_fs        char(80),
        l_acao_ant  char(3)

 let l_azlaplcod  = null
 let l_resultado  = null
 let l_mensagem   = null
 let l_doc_handle = null
 let l_msg_opcoes = null
 let l_handle     = null
 let l_f7 = null
 let l_fs = null
 let m_erro_msg = null

 initialize  ws.*           to null
 initialize  slv_segurado.* to null
 initialize  slv_terceiro.* to null
 initialize  mr_geral.*     to null
 initialize  mr_corretor.*  to null
 initialize  mr_segurado.*  to null
 initialize  mr_veiculo.*   to null
 initialize  d_cts15m15.*   to null
 initialize  w_cts15m15.*   to null
 initialize  ws.*           to null
 initialize  m_reserva.*    to null
 initialize  m_ctd31.*      to null
 initialize m_cts15ant.*    to null
 let l_acao_ant = g_documento.acao

 let mr_geral.atdsrvnum    = lr_parametro.atdsrvnum
 let mr_geral.atdsrvano    = lr_parametro.atdsrvano
 let mr_geral.ligcvntip    = lr_parametro.ligcvntip
 let mr_geral.succod       = lr_parametro.succod
 let mr_geral.ramcod       = lr_parametro.ramcod
 let mr_geral.aplnumdig    = lr_parametro.aplnumdig
 let mr_geral.itmnumdig    = lr_parametro.itmnumdig
 let mr_geral.acao         = lr_parametro.acao
 let mr_geral.prporg       = lr_parametro.prporg
 let mr_geral.prpnumdig    = lr_parametro.prpnumdig
 let mr_geral.c24astcod    = lr_parametro.c24astcod
 let mr_geral.solnom       = lr_parametro.solnom
 let mr_geral.atdsrvorg    = lr_parametro.atdsrvorg
 let mr_geral.edsnumref    = lr_parametro.edsnumref
 let mr_geral.fcapacorg    = lr_parametro.fcapacorg
 let mr_geral.fcapacnum    = lr_parametro.fcapacnum
 let mr_geral.lignum       = lr_parametro.lignum
 let mr_geral.soltip       = lr_parametro.soltip
 let mr_geral.c24soltipcod = lr_parametro.c24soltipcod
 let mr_geral.lclocodesres = lr_parametro.lclocodesres
 let m_reenvio             = false
 let m_prorrog             = false

 let int_flag   = false

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts15m15_prepara()
 end if

 open window w_cts15m15 at 04,02 with form "cts15m15"
    attribute(form line 1,message line last -1)

 display "Azul Seguros" to msg_azul attribute(reverse)

 if mr_geral.acao = 'SIN' then
    let l_msg_opcoes =
   " (F5) Espelho (F6) Historico"
 else
    let m_f7 = false
    let l_f7 = '(F7)Fax'
    if d_cts15m15.acntip = 3 then
       let l_f7 = '(F7)OnLine'
    end if
    let l_fs = '(F1)Help(F3)Dep/Fun(F4)Dados Loc(F5)Espelho(F6)Hist', l_f7 clipped, '(F8)Retira(F9)Conclui'
    let l_msg_opcoes = l_fs
    #message l_fs
 end if

 display l_msg_opcoes to msg_opcoes

  call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
 let ws.hoje           = l_data
 let w_cts15m15.ano    = ws.hoje[9,10]
 let w_cts15m15.atddat = l_data
 let w_cts15m15.atdhor = l_hora2
 let g_documento.atdsrvorg = 8
 let m_flag_alt  = false

#--------------------------------------------------------------------
# Nome do convenio
#--------------------------------------------------------------------

 select cpodes
   into d_cts15m15.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = mr_geral.ligcvntip

 let d_cts15m15.frmflg = "N"

 let d_cts15m15.c24astcod = mr_geral.c24astcod

  if lr_parametro.aplnumdig is not null then
     # -> BUSCA O CODIGO DA APOLICE
     call ctd02g01_azlaplcod(lr_parametro.succod,
                             lr_parametro.ramcod,
                             lr_parametro.aplnumdig,
                             lr_parametro.itmnumdig,
                             lr_parametro.edsnumref)

          returning l_resultado,
                    l_mensagem,
                    l_azlaplcod

     if l_resultado <> 1 then
        error l_mensagem
        sleep 4
        return
     end if

     # -> BUSCA OS DADOS DO XML DA APOLICE
     let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)
     let l_handle     = l_doc_handle

     if l_doc_handle is null then
        error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
        return
     end if

  end if

  if mr_geral.atdsrvnum is not null then

     if g_documento.acao = "CAN" then
        let m_reenvio = true
     end if

     call cts15m15_consulta()

     if m_erro then
        let int_flag = false
        error "Erro ao chamar a funcao cts15m15_consulta()" sleep 2
        close window w_cts15m15
        return
     end if

     display by name d_cts15m15. servico    ,
                    d_cts15m15.c24solnom   ,
                    d_cts15m15.nom         ,
                    d_cts15m15.doctxt      ,
                    d_cts15m15.corsus      ,
                    d_cts15m15.cornom      ,
                    d_cts15m15.vclcoddig   ,
                    d_cts15m15.vcldes      ,
                    d_cts15m15.vclanomdl   ,
                    d_cts15m15.vcllicnum   ,
                    d_cts15m15.vclloctip   ,
                    d_cts15m15.vcllocdes   ,
                    d_cts15m15.c24astcod   ,
                    d_cts15m15.c24astdes   ,
                    d_cts15m15.avilocnom   ,
                    d_cts15m15.avialgmtv   ,
                    d_cts15m15.avimtvdes   ,
                    d_cts15m15.lcvcod      ,
                    d_cts15m15.lcvnom      ,
                    d_cts15m15.lcvextcod   ,
                    d_cts15m15.aviestnom   ,
                    d_cts15m15.cdtoutflg   ,
                    d_cts15m15.cdtsegtaxvlr,
                    d_cts15m15.avivclcod   ,
                    d_cts15m15.avivclgrp   ,
                    d_cts15m15.avivcldes   ,
                    d_cts15m15.vcldiavlr   ,
                    d_cts15m15.frqvlr      ,
                    d_cts15m15.isnvlr      ,
                    d_cts15m15.rduvlr      ,
                    d_cts15m15.cndtxt      ,
                    d_cts15m15.prgtxt      ,
                    d_cts15m15.frmflg      ,
                    d_cts15m15.aviproflg   ,
                    d_cts15m15.cttdddcod   ,
                    d_cts15m15.ctttelnum   ,
                    d_cts15m15.atdlibflg   ,
                    d_cts15m15.atdlibtxt   ,
                    #d_cts15m15.cauchqflg   ,
                    d_cts15m15.locrspcpfnum,
                    d_cts15m15.locrspcpfdig,
                    d_cts15m15.smsenvdddnum,
                    d_cts15m15.smsenvcelnum,
                    d_cts15m15.garantia,
                    d_cts15m15.flgarantia


    display by name d_cts15m15.c24solnom attribute (reverse)

    if d_cts15m15.prgtxt is not null  then
       display by name d_cts15m15.prgtxt  attribute (reverse)
    end if

    if w_cts15m15.atdfnlflg = "S"  then
       error " ATENCAO! Servico ja' acionado!"
    end if

    let l_acao_ant = g_documento.acao
    call cts15m15_modifica() returning ws.grvflg

    if ws.grvflg = false  then
       initialize mr_geral.acao to null
       close window w_cts15m15
       let int_flag = false
       return
    end if
    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2
    if g_documento.acao is not null and
       g_documento.acao <> 'SIN'    then
       call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                     g_issk.funmat, l_data, l_hora2)
       if g_documento.acao is null then
          let g_documento.acao = l_acao_ant
       end if
       let g_rec_his = true
    end if
    if mr_geral.atdsrvnum is not null and
       d_cts15m15.lcvcod     is not null and
       d_cts15m15.aviestcod  is not null and
       d_cts15m15.atdlibflg  <> "N"      then
       call cts15m01(mr_geral.atdsrvnum
                    ,mr_geral.atdsrvano
                    ,d_cts15m15.lcvcod
                    ,d_cts15m15.aviestcod
                    ,d_cts15m15.avialgmtv)
    end if

  else

    if l_doc_handle is not null then
       # -> BUSCA OS DADOS DO XML DA APOLICE
       let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

       # -> BUSCA OS DADOS DO CORRETOR
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "CORRETOR")
       returning mr_corretor.corsus,
                 mr_corretor.cornom,
                 mr_corretor.dddcod,
                 mr_corretor.teltxt,
                 mr_corretor.dddfax,
                 mr_corretor.factxt,
                 mr_corretor.maides

       let d_cts15m15.corsus = mr_corretor.corsus
       let d_cts15m15.cornom = mr_corretor.cornom

       # -> DADOS DO SEGURADO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "SEGURADO")
            returning mr_segurado.nome,
                      mr_segurado.cgccpf,
                      mr_segurado.pessoa,
                      mr_segurado.dddfone,
                      mr_segurado.numfone,
                      mr_segurado.email

       # -> DADOS DO VEICULO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "VEICULO")
            returning mr_veiculo.codigo,
                      mr_veiculo.marca,
                      mr_veiculo.tipo,
                      mr_veiculo.modelo,
                      mr_veiculo.chassi,
                      mr_veiculo.placa,
                      mr_veiculo.anofab,
                      mr_veiculo.anomod,
                      mr_veiculo.catgtar,
                      mr_veiculo.automatico

    let d_cts15m15.nom          = mr_segurado.nome

    let d_cts15m15.corsus       = mr_corretor.corsus
    let d_cts15m15.cornom       = mr_corretor.cornom
    let d_cts15m15.vclcoddig    = mr_veiculo.codigo
    let d_cts15m15.vcldes       = cts15g00(d_cts15m15.vclcoddig)

    let d_cts15m15.vclanomdl    = mr_veiculo.anomod
    let d_cts15m15.vcllicnum    = mr_veiculo.placa

    end if

    let d_cts15m15.c24astdes    = c24geral8(lr_parametro.c24astcod)

     if mr_geral.succod    is not null  and
        mr_geral.ramcod    is not null  and
        mr_geral.aplnumdig is not null  then
        let d_cts15m15.doctxt = "Apolice.: ",
                                 mr_geral.succod    using "<<<&&",
                            " ", mr_geral.ramcod    using "##&&",
                            " ", mr_geral.aplnumdig using "<<<<<<<<&"
     end if

     let   d_cts15m15.garantia = 'Garantia:'

    display by name d_cts15m15. servico
                    ,d_cts15m15.c24solnom
                    ,d_cts15m15.nom
                    ,d_cts15m15.doctxt
                    ,d_cts15m15.corsus
                    ,d_cts15m15.cornom
                    ,d_cts15m15.vclcoddig
                    ,d_cts15m15.vcldes
                    ,d_cts15m15.vclanomdl
                    ,d_cts15m15.vcllicnum
                    ,d_cts15m15.vclloctip
                    ,d_cts15m15.vcllocdes
                    ,d_cts15m15.c24astcod
                    ,d_cts15m15.c24astdes
                    ,d_cts15m15.avilocnom
                    ,d_cts15m15.avialgmtv
                    ,d_cts15m15.avimtvdes
                    ,d_cts15m15.lcvcod
                    ,d_cts15m15.lcvnom
                    ,d_cts15m15.lcvextcod
                    ,d_cts15m15.aviestnom
                    ,d_cts15m15.cdtoutflg
                    ,d_cts15m15.cdtsegtaxvlr
                    ,d_cts15m15.avivclcod
                    ,d_cts15m15.avivclgrp
                    ,d_cts15m15.avivcldes
                    ,d_cts15m15.vcldiavlr
                    ,d_cts15m15.frqvlr
                    ,d_cts15m15.isnvlr
                    ,d_cts15m15.rduvlr
                    ,d_cts15m15.cndtxt
                    ,d_cts15m15.prgtxt
                    ,d_cts15m15.frmflg
                    ,d_cts15m15.aviproflg
                    ,d_cts15m15.cttdddcod
                    ,d_cts15m15.ctttelnum
                    ,d_cts15m15.atdlibflg
                    ,d_cts15m15.atdlibtxt
                    #,d_cts15m15.cauchqflg
                    ,d_cts15m15.locrspcpfnum
                    ,d_cts15m15.locrspcpfdig
                    ,d_cts15m15.smsenvdddnum
                    ,d_cts15m15.smsenvcelnum
                    ,d_cts15m15.garantia
                    ,d_cts15m15.flgarantia

    display by name d_cts15m15.c24solnom attribute (reverse)


    if mr_geral.succod    is not null  and
       mr_geral.ramcod    is not null  and
       mr_geral.aplnumdig is not null  then
       let d_cts15m15.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",
                                        " ", mr_geral.ramcod    using "##&&",
                                        " ", mr_geral.aplnumdig using "<<<<<<<<&"
    end if

    let d_cts15m15.c24astcod   = mr_geral.c24astcod
    let d_cts15m15.c24solnom   = mr_geral.solnom

    call c24geral8(d_cts15m15.c24astcod) returning d_cts15m15.c24astdes

    display by name d_cts15m15. servico    ,
                    d_cts15m15.c24solnom   ,
                    d_cts15m15.nom         ,
                    d_cts15m15.doctxt      ,
                    d_cts15m15.corsus      ,
                    d_cts15m15.cornom      ,
                    d_cts15m15.vclcoddig   ,
                    d_cts15m15.vcldes      ,
                    d_cts15m15.vclanomdl   ,
                    d_cts15m15.vcllicnum   ,
                    d_cts15m15.vclloctip   ,
                    d_cts15m15.vcllocdes   ,
                    d_cts15m15.c24astcod   ,
                    d_cts15m15.c24astdes   ,
                    d_cts15m15.avilocnom   ,
                    d_cts15m15.avialgmtv   ,
                    d_cts15m15.avimtvdes   ,
                    d_cts15m15.lcvcod      ,
                    d_cts15m15.lcvnom      ,
                    d_cts15m15.lcvextcod   ,
                    d_cts15m15.aviestnom   ,
                    d_cts15m15.cdtoutflg   ,
                    d_cts15m15.cdtsegtaxvlr,
                    d_cts15m15.avivclcod   ,
                    d_cts15m15.avivclgrp   ,
                    d_cts15m15.avivcldes   ,
                    d_cts15m15.vcldiavlr   ,
                    d_cts15m15.frqvlr      ,
                    d_cts15m15.isnvlr      ,
                    d_cts15m15.rduvlr      ,
                    d_cts15m15.cndtxt      ,
                    d_cts15m15.prgtxt      ,
                    d_cts15m15.frmflg      ,
                    d_cts15m15.aviproflg   ,
                    d_cts15m15.cttdddcod   ,
                    d_cts15m15.ctttelnum   ,
                    d_cts15m15.atdlibflg   ,
                    d_cts15m15.atdlibtxt   ,
                    #d_cts15m15.cauchqflg   ,
                    d_cts15m15.locrspcpfnum,
                    d_cts15m15.locrspcpfdig,
                    d_cts15m15.smsenvdddnum,
                    d_cts15m15.smsenvcelnum,
                    d_cts15m15.garantia,
                    d_cts15m15.flgarantia



    display by name d_cts15m15.c24solnom attribute (reverse)

    let ws.grvflg = cts15m15_inclui()

    if ws.grvflg = true  then
       call cts10n00(w_cts15m15.atdsrvnum, w_cts15m15.atdsrvano,
                     w_cts15m15.funmat   , w_cts15m15.atddat   ,
                     w_cts15m15.atdhor)

          #-----------------------------------------------
          # Desbloqueio do servico
          #-----------------------------------------------
          if w_cts15m15.atdfnlflg = "N"  then
             update datmservico set c24opemat = null
                              where atdsrvnum = w_cts15m15.atdsrvnum
                                and atdsrvano = w_cts15m15.atdsrvano

             if sqlca.sqlcode <> 0  then
                error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
                prompt "" for char ws.confirma
             else
               call cts00g07_apos_servdesbloqueia(w_cts15m15.atdsrvnum,w_cts15m15.atdsrvano)
             end if
          end if
        end if
    end if
 if w_cts15m15.atdsrvnum is null then
    let w_cts15m15.atdsrvnum = g_documento.atdsrvnum
    let w_cts15m15.atdsrvano = g_documento.atdsrvano
 end if
 if m_flag_alt = true then
    call cts15m15_acionamento(w_cts15m15.atdsrvnum, w_cts15m15.atdsrvano
                             ,d_cts15m15.lcvcod, d_cts15m15.aviestcod,0,'',
                              w_cts15m15.procan)
 end if
 
   call cts00g07_apos_grvlaudo(w_cts15m15.atdsrvnum,
                               w_cts15m15.atdsrvano)

 close window w_cts15m15
 let int_flag = false

end function

#--------------------------------------------------------------------
 function cts15m15_consulta()
#--------------------------------------------------------------------

 define ws           record
    avivclmdl        like datkavisveic.avivclmdl ,
    avivcldes        char (65)                   ,
    funnom           char (15)                   ,
    dptsgl           like isskfunc.dptsgl        ,
    ligcvntip        like datmligacao.ligcvntip  ,
    atddat           like datmservico.atddat     ,
    atdhor           like datmservico.atdhor     ,
    atdlibdat        like datmservico.atdlibdat  ,
    atdlibhor        like datmservico.atdlibhor  ,
    viginc           like abbmclaus.viginc       ,
    vigfnl           like abbmclaus.vigfnl       ,
    atdsrvorg        like datmservico.atdsrvorg  ,
    succod            like datrservapol.succod   ,
    ramcod            like datrservapol.ramcod   ,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    edsnumref         like datrservapol.edsnumref,
    prporg            like datrligprp.prporg,
    prpnumdig         like datrligprp.prpnumdig,
    fcapcorg          like datrligpac.fcapacorg,
    fcapacnum         like datrligpac.fcapacnum
 end record

 define lr_ret        record
        erro          smallint,
        msg           char(80)
 end record

 define ws_avirsrgrttip dec(1,0)

        let     ws_avirsrgrttip  =  null

        initialize  ws.*  to  null

 initialize ws.*  to null

 select nom      ,
        vclcoddig, vcldes   ,
        vclanomdl, vcllicnum,
        corsus   , cornom   ,
        funmat   , empcod   ,
        atddat   , atdhor   ,
        atdfnlflg, atdlibflg,
        atdlibdat, atdlibhor,
        atdsrvorg, ciaempcod
   into d_cts15m15.nom      ,
        d_cts15m15.vclcoddig, d_cts15m15.vcldes   ,
        d_cts15m15.vclanomdl, d_cts15m15.vcllicnum,
        d_cts15m15.corsus   , d_cts15m15.cornom   ,
        w_cts15m15.funmat   , w_cts15m15.empcod   ,
        ws.atddat           , ws.atdhor           ,
        w_cts15m15.atdfnlflg, d_cts15m15.atdlibflg,
        ws.atdlibdat        , ws.atdlibhor        ,
        ws.atdsrvorg, g_documento.ciaempcod
   from datmservico
  where atdsrvnum = mr_geral.atdsrvnum  and
        atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao foi encontrado. AVISE A INFORMATICA !"
    return
 end if

 let m_reenvio = true

 open c_cts15m15_003 using mr_geral.atdsrvnum
                        ,mr_geral.atdsrvano

 whenever error continue
 fetch c_cts15m15_003 into d_cts15m15.lcvcod      , d_cts15m15.avivclcod, d_cts15m15.avivclvlr
                        ,d_cts15m15.aviestcod   , d_cts15m15.avialgmtv, d_cts15m15.avilocnom
                        ,w_cts15m15.aviretdat   , w_cts15m15.avirethor, w_cts15m15.aviprvent
                        ,d_cts15m15.locsegvlr   , d_cts15m15.vclloctip, w_cts15m15.avioccdat
                        ,w_cts15m15.ofnnom      , w_cts15m15.ofndddcod, w_cts15m15.ofntelnum
                        ,d_cts15m15.cttdddcod   , d_cts15m15.ctttelnum, ws_avirsrgrttip
                        ,w_cts15m15.slcemp      , w_cts15m15.slcsuccod, w_cts15m15.slcmat
                        ,w_cts15m15.slccctcod   , d_cts15m15.cdtoutflg, d_cts15m15.locrspcpfnum
                        ,d_cts15m15.locrspcpfdig, d_cts15m15.lcvsinavsflg
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
    else
       error 'Erro SELECT c_cts15m15_003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'cts15m15 / cts15m15_consulta() / ',mr_geral.atdsrvnum,' / '
                                                ,mr_geral.atdsrvano sleep 1
    end if
    let m_erro = true
    return
 end if

 if d_cts15m15.cdtoutflg is null then
    let d_cts15m15.cdtoutflg = "N"
 end if

 let m_opcao = ws_avirsrgrttip
 case ws_avirsrgrttip

       when 1

        let d_cts15m15.cauchqflg = "N"
        let d_cts15m15.garantia = 'Cartao de Credito'
        let d_cts15m15.flgarantia = "S"

       when 2
          let d_cts15m15.cauchqflg = "S"
          let d_cts15m15.flgarantia = "S"
          let d_cts15m15.garantia = 'Cheque Caucao'

       when 3
          let d_cts15m15.cauchqflg = "N"
          let d_cts15m15.flgarantia = "S"
          let d_cts15m15.garantia = 'Isencao de Garantia'
end case






 case d_cts15m15.vclloctip
    when 1    let d_cts15m15.vcllocdes = "SEGURADO"
    when 2    let d_cts15m15.vcllocdes = "CORRETOR"
    when 3    let d_cts15m15.vcllocdes = "DEPTOS. "
    when 4    let d_cts15m15.vcllocdes = "FUNC.   "
    otherwise let d_cts15m15.vcllocdes = "NAO PREV"
 end case

 if d_cts15m15.locsegvlr  is null    then
    let d_cts15m15.locsegvlr = 0.00
 end if
 let d_cts15m15.vcldiavlr = d_cts15m15.avivclvlr + d_cts15m15.locsegvlr

#--------------------------------------------------------------------
# Veiculo / Loja
#--------------------------------------------------------------------

 initialize ws.avivclmdl, ws.avivcldes  to null

 select avivclmdl, avivcldes, avivclgrp,
        frqvlr, isnvlr, rduvlr                  #PSI 198390
   into ws.avivclmdl,
        ws.avivcldes,
        d_cts15m15.avivclgrp,
        d_cts15m15.frqvlr,                      #PSI 198390
        d_cts15m15.isnvlr,                      #PSI 198390
        d_cts15m15.rduvlr                       #PSI 198390
   from datkavisveic
  where lcvcod    = d_cts15m15.lcvcod     and
        avivclcod = d_cts15m15.avivclcod

 if sqlca.sqlcode = NOTFOUND   then
    let d_cts15m15.avivcldes = "VEICULO/DISCRIMINACAO NAO ENCONTRADOS"
 else
    if ws.avivcldes is not null  then
       let ws.avivcldes = "(", ws.avivcldes clipped, ")"
    end if
    let d_cts15m15.avivcldes = ws.avivclmdl clipped, " ",
                               ws.avivcldes clipped
 end if

 select lcvnom, cdtsegtaxvlr, acntip
   into d_cts15m15.lcvnom, d_cts15m15.cdtsegtaxvlr, d_cts15m15.acntip
   from datklocadora
  where lcvcod = d_cts15m15.lcvcod

 if sqlca.sqlcode = notfound then
    error " Dados da LOCADORA nao encontrados. AVISE A INFORMATICA!"
    return
 else
    if sqlca.sqlcode < 0 then
       error " Erro (", sqlca.sqlcode, ") na localizacao dos dados da LOCADORA. AVISE A INFORMATICA!"
       return
    end if
 end if

 #PSI 198390 - caso nao tenha 2 condutor nao exibir valor da taxa
 if d_cts15m15.cdtoutflg = 'N' then
    let d_cts15m15.cdtsegtaxvlr = null
 end if

 select lcvextcod, aviestnom
   into d_cts15m15.lcvextcod,
        d_cts15m15.aviestnom
   from datkavislocal
  where lcvcod    = d_cts15m15.lcvcod    and
        aviestcod = d_cts15m15.aviestcod

 if sqlca.sqlcode = NOTFOUND then
    error " Dados da LOJA nao encontrados. AVISE A INFORMATICA!" sleep 2
    return
 else
    if sqlca.sqlcode < 0 then
       error " Erro (", sqlca.sqlcode, ") na localizacao dos dados",
             " da LOJA. AVISE A INFORMATICA! " sleep 2
       return
    end if
 end if

#--------------------------------------------------------------------
# Dados da ligacao / convenio
#--------------------------------------------------------------------

 let w_cts15m15.lignum = cts20g00_servico(mr_geral.atdsrvnum, mr_geral.atdsrvano)

 call cts20g01_docto(w_cts15m15.lignum)
      returning mr_geral.succod,
                mr_geral.ramcod,
                mr_geral.aplnumdig,
                mr_geral.itmnumdig,
                mr_geral.edsnumref,
                mr_geral.prporg,
                mr_geral.prpnumdig,
                mr_geral.fcapacorg,
                mr_geral.fcapacnum,
                mr_geral.itaciacod

 if mr_geral.succod    is not null  and
    mr_geral.ramcod    is not null  and
    mr_geral.aplnumdig is not null  then
    let d_cts15m15.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",
                                     " ", mr_geral.ramcod    using "##&&",
                                     " ", mr_geral.aplnumdig using "<<<<<<<<&"
    let g_documento.ramcod = mr_geral.ramcod
 end if
 let g_documento.succod       = mr_geral.succod
 let g_documento.ramcod       = mr_geral.ramcod
 let g_documento.aplnumdig    = mr_geral.aplnumdig
 let g_documento.itmnumdig    = mr_geral.itmnumdig

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts15m15.c24astcod,
        ws.ligcvntip        ,
        d_cts15m15.c24solnom
   from datmligacao
  where lignum = w_cts15m15.lignum

 let mr_geral.ligcvntip = ws.ligcvntip

 select lignum
   from datmligfrm
  where lignum = w_cts15m15.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts15m15.frmflg = "N"
 else
    let d_cts15m15.frmflg = "S"
 end if

 select cpodes
   into d_cts15m15.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = ws.ligcvntip

 let d_cts15m15.c24astdes = c24geral8(d_cts15m15.c24astcod)

 let d_cts15m15.servico = F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                     "/", F_FUNDIGIT_INTTOSTR(mr_geral.atdsrvnum,7),
                     "-", F_FUNDIGIT_INTTOSTR(mr_geral.atdsrvano,2)

#--------------------------------------------------------------------
# Verifica existencia de prorrogacoes
#--------------------------------------------------------------------
 declare c_cts15m15_004 cursor for
    select atdsrvnum, atdsrvano
      from datmprorrog
     where atdsrvnum = mr_geral.atdsrvnum  and
           atdsrvano = mr_geral.atdsrvano

 open  c_cts15m15_004
 fetch c_cts15m15_004

 if sqlca.sqlcode = 0   then
    let d_cts15m15.prgtxt    = "PRORROGACAO"
    let d_cts15m15.aviproflg = "S"
 else
    initialize d_cts15m15.prgtxt to null
    let d_cts15m15.aviproflg = "N"
 end if
 close c_cts15m15_004

 let ws.funnom = "*** NAO CADASTRADO! ***"
 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = w_cts15m15.empcod
    and funmat = w_cts15m15.funmat

 let d_cts15m15.atdlibtxt = ws.atddat                         clipped, " " ,
                            ws.atdhor                         clipped, " " ,
                            upshift(ws.dptsgl)                clipped, " " ,
                            w_cts15m15.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)                clipped, "  ",
                            ws.atdlibdat                      clipped, "  ",
                            ws.atdlibhor

 let w_cts15m15.datasaldo = w_cts15m15.atddat

 if d_cts15m15.avialgmtv = 1 then  #psi175552
     let w_cts15m15.datasaldo = w_cts15m15.avioccdat
 end if

 open c_cts15m15_001 using d_cts15m15.avialgmtv

 whenever error continue
 fetch c_cts15m15_001 into d_cts15m15.avimtvdes
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let d_cts15m15.avimtvdes = null
    else
       error 'Erro SELECT iddkdominio:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
       let m_erro = true
       return
    end if
 end if  # fim psi175552
 if d_cts15m15.avialgmtv = 3 then
    let d_cts15m15.avimtvdes = "BENEFICIO"
 end if

 display by name d_cts15m15.avimtvdes

 if mr_geral.succod    is not null   and
    mr_geral.aplnumdig is not null   and
    mr_geral.itmnumdig is not null   then
    call cts44g01_claus_azul(mr_geral.succod,
                             mr_geral.ramcod,
                             mr_geral.aplnumdig,
                             mr_geral.itmnumdig)
                   returning w_cts15m15.temcls,w_cts15m15.clscod

 end if

 call cts15m15_condicoes()

 #==============================================================
 # Carrega celular da reserva
 #==============================================================
 if d_cts15m15.acntip == 3 then
	 if g_documento.atdsrvnum is not null then
	    whenever error stop
	    open ccts15m15035 using g_documento.atdsrvnum,g_documento.atdsrvano
	    fetch ccts15m15035 into d_cts15m15.smsenvdddnum,
	                            d_cts15m15.smsenvcelnum
	    whenever error continue
	 end if
 else
 	 if g_documento.atdsrvnum is not null then
	    whenever error stop
	    open ccts15m15042 using g_documento.atdsrvnum,g_documento.atdsrvano
	    fetch ccts15m15042 into d_cts15m15.smsenvdddnum,
	                            d_cts15m15.smsenvcelnum
	    whenever error continue
	 end if
 end if



end function  ###  cts15m15_consulta

#--------------------------------------------------------------------
 function cts15m15_modifica()
#--------------------------------------------------------------------

 define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        atdsrvorg       like datmservico.atdsrvorg ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        segnumdig       like abbmdoc.segnumdig     ,
        funnom          like isskfunc.funnom       ,
        dptsgl          like isskfunc.dptsgl       ,
        c24trxnum       like dammtrx.c24trxnum     ,
        lintxt          like dammtrxtxt.c24trxtxt  ,
        hora            char (05)                  ,
        titulo          char (40),
        confirma        char (1)
 end record

 define prompt_key       char (01)
 define ws_avirsrgrttip  dec (1,0)
 define ws_avialgmtv     like datmavisrent.avialgmtv
 define ws_sqlcode       integer
 define ws_msgsin        char (70)
 define ws_msgerr        char (300)
 DEFINE l_funnom         LIKE isskfunc.funnom,
        l_dptsgl         LIKE isskfunc.dptsgl
       ,l_result         smallint
       ,l_msg            char(080)

 define l_atdetpcod         like datmsrvacp.atdetpcod,
        l_atdfnlflg         like datmservico.atdfnlflg
 define l_data         date,
        l_hora2        datetime hour to minute

        let     prompt_key  =  null
        let     ws_avirsrgrttip  =  null
        let     ws_avialgmtv  =  null
        let     ws_sqlcode  =  null
        let     ws_msgsin  =  null
        let     ws_msgerr  =  null
        let     l_funnom  =  null
        let     l_dptsgl  =  null

        let l_atdetpcod = null
        let l_atdfnlflg = null
        initialize  ws.*  to  null

 let ws_avialgmtv = d_cts15m15.avialgmtv   # SALVA MOTIVO ANTERIOR

 let m_erro_msg = null
 if d_cts15m15.acntip = 3 then
    ############ ligia - Fornax - 17/05/11 #################################
    initialize m_ctd31.* to null
    call ctd31g00_ver_solicitacao(g_documento.atdsrvnum,
                                  g_documento.atdsrvano)
         returning m_ctd31.*
    if m_ctd31.sqlcode <> 0 and m_ctd31.sqlcode <> 100 then
       let m_erro_msg = m_ctd31.mens
    end if
 initialize  m_reserva.*    to null
 call ctd31g00_ver_reserva(2, g_documento.atdsrvnum,
                           g_documento.atdsrvano)
 returning m_reserva.erro, m_reserva.rsvsttcod, m_reserva.loccntcod
 if g_documento.acao = "ALT" then #or
    #g_documento.acao is null then
  call cts08g01("C","S","", "DESEJA REALIZAR UMA PRORROGACAO ?", "","")
       returning ws.confirma
  if ws.confirma = "N" then
     if g_documento.atdsrvnum is null then
        error " Consulta as informacoes de retirada somente apos digitacao do servico!"
     else
        call cts15m04("A", d_cts15m15.avialgmtv,
                      d_cts15m15.aviestcod, w_cts15m15.aviretdat,
                      w_cts15m15.avirethor, w_cts15m15.aviprvent,
                      d_cts15m15.lcvcod   , "" #ws.endcep
                    , d_cts15m15.dtentvcl)
            returning w_cts15m15.aviretdat, w_cts15m15.avirethor,
                      w_cts15m15.aviprvent, m_cct, m_cct, m_cct
     end if
  else
       initialize  m_reserva.*    to null
       call ctd31g00_ver_reserva(2, g_documento.atdsrvnum,
                                 g_documento.atdsrvano)
            returning m_reserva.erro, m_reserva.rsvsttcod, m_reserva.loccntcod
       if m_erro_msg is null and g_documento.acao = "ALT" then
          #if (m_reserva.erro = 0 and m_reserva.loccntcod is not null) or
          #    m_reserva.erro = 1 then
             #call cts08g01("C","S","", "DESEJA ALTERAR OU REALIZAR","UMA PRORROGACAO ?",
             #"")
             #      returning ws.confirma
             if  m_reserva.loccntcod is null then
                 call cts15m15_verifica_data_retirada()
                      returning ws.confirma
             else
                let ws.confirma = "S"
             end if
          if ws.confirma = "S" then
                call cts15m05(g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              d_cts15m15.lcvcod,
                              d_cts15m15.aviestcod ,
                              "", ## não eh usado no cts15m05
                              d_cts15m15.avialgmtv ,
                              d_cts15m15.dtentvcl,
                              d_cts15m15.avivclgrp,
                              d_cts15m15.lcvsinavsflg)
                     returning w_cts15m15.procan,
                               w_cts15m15.aviprodiaqtd
          else
             #error 'Veiculo ainda nao retirado pelo segurado'
             call cts08g01("A","N","", "VEICULO AINDA NÃO FOI RETIRADO.","", "")
                    returning ws.confirma
             call cts15m04("A", d_cts15m15.avialgmtv,
                            d_cts15m15.aviestcod, w_cts15m15.aviretdat,
                            w_cts15m15.avirethor, w_cts15m15.aviprvent,
                            d_cts15m15.lcvcod   , "" #ws.endcep
                          , d_cts15m15.dtentvcl)
                  returning w_cts15m15.aviretdat, w_cts15m15.avirethor,
                            w_cts15m15.aviprvent, m_cct, m_cct, m_cct
          end if
       end if
  end if
 end if
 if g_documento.acao = "CAN" and m_reserva.loccntcod is not null then
    call cts08g01("A","N","","CANCELAMENTO NAO PERMITIDO.",
                  "VEICULO ENTREGUE AO CLIENTE","")
 else
    if m_erro_msg is null and g_documento.acao = "CAN" then
       call cts08g01("C","S","", "CONFIRMA O CANCELAMENTO DA RESERVA ?", "","")
             returning ws.confirma
       if ws.confirma = "S" then
          call cts10g04_ultima_etapa(g_documento.atdsrvnum,
                                     g_documento.atdsrvano)
                        returning l_atdetpcod
          if d_cts15m15.acntip <> 3 and l_atdetpcod =  4 then ## reserva acionada
             let l_atdetpcod = 1
             let l_atdfnlflg = "N"
          else
             let l_atdetpcod = 5
             let l_atdfnlflg = "S"
          end if
          initialize m_ctd07g05.* to null
          call ctd07g05_ult_acn (2,g_documento.atdsrvnum,g_documento.atdsrvano)
                returning m_ctd07g05.*
          call cts10g04_insere_etapa(g_documento.atdsrvnum,
                                     g_documento.atdsrvano,
                                     l_atdetpcod, m_ctd07g05.pstcoddig,
                                     "", "", m_ctd07g05.srrcoddig)
               returning l_result
          if  l_result  <>  0  then
              error " Erro (", l_result, ") na etapa do serviço.",
                    "AVISE A INFORMATICA!"
          else
             call ctd07g00_upd_atdfnlflg(g_documento.atdsrvnum,
                                         g_documento.atdsrvano, l_atdfnlflg)
                  returning l_result
             if l_result <> 0 then
                error "Erro (", l_result, ") na atualizacao do serviço.",
                    "AVISE A INFORMATICA!"
             else
               call cts15m15_acionamento(g_documento.atdsrvnum,
                                         g_documento.atdsrvano,
                                         d_cts15m15.lcvcod,
                                         d_cts15m15.aviestcod,0,'',
                                         w_cts15m15.procan)
               return false
                end if
             end if
          else
                error 'Motivo de cancelamento nao selecionado'
          end if
       end if
    end if ###########ligia - 17/05/11
 end if
 call cts15m15_input()

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    initialize d_cts15m15.*    to null
    initialize w_cts15m15.*    to null
    clear form
    return false
 end if

 let ws_avirsrgrttip = m_opcao






 whenever error continue

 BEGIN WORK

  update datmservico set (nom      , corsus   , cornom   , vclcoddig,
                          vcldes   , vclanomdl, vcllicnum)
                       = (d_cts15m15.nom      , d_cts15m15.corsus   ,
                          d_cts15m15.cornom   , d_cts15m15.vclcoddig,
                          d_cts15m15.vcldes   , d_cts15m15.vclanomdl,
                          d_cts15m15.vcllicnum)
                    where atdsrvnum = mr_geral.atdsrvnum and
                          atdsrvano = mr_geral.atdsrvano

  if sqlca.sqlcode <> 0 then
     error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA! "
     rollback work
     prompt "" for char prompt_key
     return false
  end if

   if w_cts15m15.avioccdat is null then
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      let w_cts15m15.avioccdat = l_data
   end if

  whenever error continue
  execute p_cts15m15_004 using d_cts15m15.lcvcod   , d_cts15m15.avivclcod, d_cts15m15.aviestcod
                            ,d_cts15m15.avivclvlr, d_cts15m15.locsegvlr, d_cts15m15.avialgmtv
                            ,w_cts15m15.avidiaqtd, d_cts15m15.avilocnom, w_cts15m15.aviretdat
                            ,w_cts15m15.avirethor, w_cts15m15.aviprvent, w_cts15m15.avioccdat
                            ,w_cts15m15.ofnnom   , w_cts15m15.ofndddcod, w_cts15m15.ofntelnum
                            ,d_cts15m15.cttdddcod, d_cts15m15.ctttelnum, ws_avirsrgrttip
                            ,w_cts15m15.slcemp   , w_cts15m15.slcsuccod, w_cts15m15.slcmat
                            ,w_cts15m15.slccctcod, d_cts15m15.cdtoutflg, d_cts15m15.vclloctip
                            ,d_cts15m15.locrspcpfnum, d_cts15m15.locrspcpfdig
                            ,d_cts15m15.lcvsinavsflg, d_cts15m15.smsenvdddnum, d_cts15m15.smsenvcelnum
                            ,mr_geral.atdsrvnum, mr_geral.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro UPDATE p_cts15m15_004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
     error 'cts15m15 / cts15m15_modifica() / ',d_cts15m15.lcvcod   ,' / ', d_cts15m15.avivclcod,' / '
                                              ,d_cts15m15.aviestcod,' / ', d_cts15m15.avivclvlr,' / '
                                              ,d_cts15m15.locsegvlr,' / ', d_cts15m15.avialgmtv,' / '
                                              ,w_cts15m15.avidiaqtd,' / ', d_cts15m15.avilocnom,' / '
                                              ,w_cts15m15.aviretdat,' / ', w_cts15m15.avirethor,' / '
                                              ,w_cts15m15.aviprvent,' / ', w_cts15m15.avioccdat,' / '
                                              ,w_cts15m15.ofnnom   ,' / ', w_cts15m15.ofndddcod,' / '
                                              ,w_cts15m15.ofntelnum,' / ', d_cts15m15.cttdddcod,' / '
                                              ,d_cts15m15.ctttelnum,' / ', ws_avirsrgrttip     ,' / '
                                              ,w_cts15m15.slcemp   ,' / ', w_cts15m15.slcsuccod,' / '
                                              ,w_cts15m15.slcmat   ,' / ', w_cts15m15.slccctcod,' / '
                                              ,d_cts15m15.cdtoutflg,' / ', d_cts15m15.vclloctip,' / '
                                              ,d_cts15m15.locrspcpfnum,' / ', d_cts15m15.locrspcpfdig,' / '
                                              ,d_cts15m15.lcvsinavsflg,' / ', d_cts15m15.smsenvdddnum, '/ '
                                              ,d_cts15m15.smsenvcelnum,' / ', mr_geral.atdsrvnum,' / '
                                              ,mr_geral.atdsrvano  sleep 1
     rollback work
     return false
  end if

  whenever error stop
  let m_histerr = cts10g02_historico( mr_geral.atdsrvnum,
                                      mr_geral.atdsrvano,
                                      l_data,
                                      l_hora2,
                                      g_issk.funmat,
                                      hist_cts15m15.*   )

  commit work
  # Ponto de acesso apos a gravacao do laudo
  call cts00g07_apos_grvlaudo(mr_geral.atdsrvnum,
                              mr_geral.atdsrvano)

  return true

end function

#-------------------------------------------------------------------------------
 function cts15m15_inclui()
#-------------------------------------------------------------------------------

 define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        atdsrvorg       like datmservico.atdsrvorg ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        segnumdig       like abbmdoc.segnumdig     ,
        funnom          like isskfunc.funnom       ,
        dptsgl          like isskfunc.dptsgl       ,
        c24trxnum       like dammtrx.c24trxnum     ,
        lintxt          like dammtrxtxt.c24trxtxt  ,
        hora            char (05)                  ,
        titulo          char (40)
 end record

 define ws_avirsrgrttip    dec(1,0)
 define ws_msgerr          char (300)
 define ws_msgsin          char (70)

 define w_retorno          smallint
       ,l_result           smallint
       ,l_msg              char(080)


 define l_data         date,
        l_hora2        datetime hour to minute

        let     ws_avirsrgrttip  =  null
        let     ws_msgerr  =  null
        let     ws_msgsin  =  null
        let     w_retorno  =  null

        initialize  ws.*  to  null

 while true
   let d_cts15m15.aviproflg = "N"
   let mr_geral.acao = "INC"
   let g_documento.acao = "INC"

   initialize  w_cts15m15.locrspcpfnum, w_cts15m15.locrspcpfdig to null

   call cts15m15_input()

   if  int_flag  then
       let int_flag  = false
       initialize d_cts15m15.*     to null
       initialize w_cts15m15.*     to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts15m15.atdfnlflg = "N"  then
       let w_cts15m15.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

   if  w_cts15m15.atddat is null  then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let w_cts15m15.atddat = l_data
       let w_cts15m15.atdhor = l_hora2
   end if

   if  w_cts15m15.funmat is null  then
       let w_cts15m15.funmat = g_issk.funmat
   end if

   if  d_cts15m15.frmflg = "S"  then
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

   #-------------------------------------------------------------
   # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
   #-------------------------------------------------------------

   if g_documento.lclocodesres = "S" then
      let w_cts15m15.atdrsdflg = "S"
   else
      let w_cts15m15.atdrsdflg = "N"
   end if


 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "R" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlcode  ,
                  ws.msg

   if  ws.sqlcode = 0  then
       commit work
   else
       let ws.msg = "cts15m15 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let mr_geral.lignum       = ws.lignum
   let g_documento.lignum    = ws.lignum
   let w_cts15m15.atdsrvnum  = ws.atdsrvnum
   let w_cts15m15.atdsrvano  = ws.atdsrvano
   let ws.atdsrvorg          = 08 #==> Remocao

 #------------------------------------------------------------------------------
 # Grava dados da ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( mr_geral.lignum      ,
                           w_cts15m15.atddat       ,
                           w_cts15m15.atdhor       ,
                           mr_geral.c24soltipcod,
                           mr_geral.solnom      ,
                           mr_geral.c24astcod   ,
                           w_cts15m15.funmat       ,
                           mr_geral.ligcvntip   ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","", "",""            ,
                           mr_geral.succod      ,
                           mr_geral.ramcod      ,
                           mr_geral.aplnumdig   ,
                           mr_geral.itmnumdig   ,
                           mr_geral.edsnumref   ,
                           mr_geral.prporg      ,
                           mr_geral.prpnumdig   ,
                           mr_geral.fcapacorg   ,
                           mr_geral.fcapacnum   ,
                           "","","",""             ,
                           ws.caddat,  ws.cadhor   ,
                           ws.cademp,  ws.cadmat    )
        returning ws.tabname,
                  ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( w_cts15m15.atdsrvnum,
                                w_cts15m15.atdsrvano,
                                mr_geral.soltip  ,     # atdsoltip
                                mr_geral.solnom  ,     # c24solnom
                                ""                  ,     # vclcorcod
                                w_cts15m15.funmat   ,
                                d_cts15m15.atdlibflg,
                                w_cts15m15.atdhor   ,     # atdlibhor
                                w_cts15m15.atddat   ,     # atdlibdat
                                w_cts15m15.atddat   ,     # atddat
                                w_cts15m15.atdhor   ,     # atdhor
                                ""                  ,     # atdlclflg
                                ""                  ,     # atdhorpvt
                                ""                  ,     # atddatprg
                                ""                  ,     # atdhorprg
                                "R"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                ""                  ,     # atdprscod
                                ""                  ,     # atdcstvlr
                                w_cts15m15.atdfnlflg,
                                w_cts15m15.atdfnlhor,
                                w_cts15m15.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts15m15.c24opemat,
                                d_cts15m15.nom      ,
                                d_cts15m15.vcldes   ,
                                d_cts15m15.vclanomdl,
                                d_cts15m15.vcllicnum,
                                d_cts15m15.corsus   ,
                                d_cts15m15.cornom   ,
                                w_cts15m15.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                ""                  ,     # atdpvtretflg
                                ""                  ,     # atdvcltip
                                ""                  ,     # asitipcod
                                ""                  ,     # socvclcod
                                d_cts15m15.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                2                   ,     # atdprinvlcod
                                8                       ) # ATDSRVORG
      returning ws.tabname,
                ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava locacao
 #------------------------------------------------------------------------------


   let ws_avirsrgrttip = m_opcao






   if w_cts15m15.avioccdat is null then
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      let w_cts15m15.avioccdat = l_data
   end if

   whenever error continue
   execute p_cts15m15_005 using ws.atdsrvnum , ws.atdsrvano , d_cts15m15.lcvcod
                             ,d_cts15m15.avivclcod, d_cts15m15.aviestcod, d_cts15m15.avivclvlr
                             ,d_cts15m15.avialgmtv   , w_cts15m15.avidiaqtd, d_cts15m15.avilocnom
                             ,w_cts15m15.aviretdat   , w_cts15m15.avirethor, w_cts15m15.aviprvent
                             ,d_cts15m15.locsegvlr   , d_cts15m15.vclloctip, w_cts15m15.avioccdat
                             ,w_cts15m15.ofnnom      , w_cts15m15.ofndddcod, w_cts15m15.ofntelnum
                             ,d_cts15m15.cttdddcod   , d_cts15m15.ctttelnum, ws_avirsrgrttip
                             ,w_cts15m15.slcemp      , w_cts15m15.slcsuccod, w_cts15m15.slcmat
                             ,w_cts15m15.slccctcod   , d_cts15m15.cdtoutflg, d_cts15m15.locrspcpfnum
                             ,d_cts15m15.locrspcpfdig, d_cts15m15.lcvsinavsflg, d_cts15m15.smsenvdddnum
                             ,d_cts15m15.smsenvcelnum
   whenever error stop
   if  sqlca.sqlcode  <>  0  then
       error 'Erro INSERT p_cts15m15_005 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'cts15m15 / cts15m15_inclui() / ',ws.atdsrvnum        ,' / ', ws.atdsrvano        ,' / '
                                              ,d_cts15m15.lcvcod   ,' / ', d_cts15m15.avivclcod,' / '
                                              ,d_cts15m15.aviestcod,' / ', d_cts15m15.avivclvlr,' / '
                                              ,d_cts15m15.avialgmtv,' / ', w_cts15m15.avidiaqtd,' / '
                                              ,d_cts15m15.avilocnom,' / ', w_cts15m15.aviretdat,' / '
                                              ,w_cts15m15.avirethor,' / ', w_cts15m15.aviprvent,' / '
                                              ,d_cts15m15.locsegvlr,' / ', d_cts15m15.vclloctip,' / '
                                              ,w_cts15m15.avioccdat,' / ', w_cts15m15.ofnnom   ,' / '
                                              ,w_cts15m15.ofndddcod,' / ', w_cts15m15.ofntelnum,' / '
                                              ,d_cts15m15.cttdddcod,' / ', d_cts15m15.ctttelnum,' / '
                                              ,ws_avirsrgrttip     ,' / ', w_cts15m15.slcemp   ,' / '
                                              ,w_cts15m15.slcsuccod,' / ', w_cts15m15.slcmat   ,' / '
                                              ,w_cts15m15.slccctcod,' / ', d_cts15m15.cdtoutflg,' / '
                                              ,d_cts15m15.locrspcpfnum,' / ',d_cts15m15.locrspcpfdig,' / '
                                              ,d_cts15m15.lcvsinavsflg, '/ ',d_cts15m15.smsenvdddnum, ' / '
                                              ,d_cts15m15.smsenvdddnum   sleep 1
       rollback work
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
  if  w_cts15m15.atdetpcod is null  then
       let w_cts15m15.atdetpcod = 1
       let ws.etpfunmat = w_cts15m15.funmat
       let ws.atdetpdat = w_cts15m15.atddat
       let ws.atdetphor = w_cts15m15.atdhor
  end if

  call cts10g04_insere_etapa( ws.atdsrvnum        ,
                              ws.atdsrvano        ,
                              w_cts15m15.atdetpcod,
                              d_cts15m15.lcvcod   ,
                              " ",
                              " ",
                              d_cts15m15.aviestcod) returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if



 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if  mr_geral.aplnumdig is not null  and
       mr_geral.aplnumdig <> 0         then
       call cts10g02_grava_servico_apolice(ws.atdsrvnum      ,
                                           ws.atdsrvano      ,
                                           mr_geral.succod   ,
                                           mr_geral.ramcod   ,
                                           mr_geral.aplnumdig,
                                           mr_geral.itmnumdig,
                                           mr_geral.edsnumref)
            returning ws.tabname,
                      ws.sqlcode
       if  ws.sqlcode <> 0  then
           error " Erro (", ws.sqlcode, ") na gravacao do",
                 " relacionamento servico x apolice. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end if

   #PSI-2013-04081 Não será gravado mais celular no histórico
   #if d_cts15m15.lcvcod <> 2 then
   #
   #   let l_msg = " Telefone Celular.: ",d_cts15m15.smsenvdddnum ," - " ,
   #                 d_cts15m15.smsenvcelnum
   #
   #
   #   call ctd07g01_ins_datmservhist(ws.atdsrvnum  ,
   #                                  ws.atdsrvano  ,
   #                                  g_issk.funmat,
   #                                  l_msg,
   #                                  l_data,
   #                                  l_hora2,
   #                                  g_issk.empcod,
   #                                  g_issk.usrtip)
   #         returning w_retorno,
   #                   l_msg
   #    if w_retorno <> 1  then
   #          error l_msg, " - CTS15m15 - AVISE A INFORMATICA!"
	#     end if
   #end if




   #------------------------------------------------------------------------------
   # Grava HISTORICO do servico
   #------------------------------------------------------------------------------
   let m_histerr = cts10g02_historico( ws.atdsrvnum     ,
                                        ws.atdsrvano     ,
                                        w_cts15m15.atddat,
                                        w_cts15m15.atdhor,
                                        g_issk.funmat,
                                        hist_cts15m15.*   )

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(ws.atdsrvnum,
                               ws.atdsrvano)

 #------------------------------------------------------------------------------
 # Exibe o numero do Servico
 #------------------------------------------------------------------------------

   let d_cts15m15.servico =      F_FUNDIGIT_INTTOSTR(ws.atdsrvorg, 2),
                            "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum, 7),
                            "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano, 2)
   display d_cts15m15.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true
   let m_flag_alt = true

   exit while
 end while

 return ws.retorno

end function

#--------------------------------------------------------------------
 function cts15m15_input()
#--------------------------------------------------------------------

 define ws            record
    pgtflg            smallint                          ,
    prpflg            char (01)                         ,
    vclloctip         like datmavisrent.vclloctip       ,
    endcep            like datkavislocal.endcep         ,
    endcepcmp         like datkavislocal.endcepcmp      ,
    lcvcod            like datkavislocal.lcvcod         ,
    avivclmdl         like datkavisveic.avivclmdl       ,
    avivcldes         like datkavisveic.avivcldes       ,
    vclalglojstt      like datkavislocal.vclalglojstt   ,
    lcvlojtip         like datkavislocal.lcvlojtip      ,
    lcvregprccod      like datkavislocal.lcvregprccod   ,
    c24srvdsc         like datmservhist.c24srvdsc       ,
    vclpsqflg         smallint                          ,
    atdofnflg         smallint                          ,
    pstcoddig         like dpaksocor.pstcoddig          ,
    ok_flg            char (02)                         ,
    cartao            char (01)                         ,
    msgtxt            char (40)                         ,
    confirma          char (01)                         ,
    diasem            smallint                          ,
    lcvstt            like datklocadora.lcvstt          ,
    cauchqflg         like datkavislocal.cauchqflg      ,
    prtaertaxvlr      like datkavislocal.prtaertaxvlr   ,
    adcsgrtaxvlr      like datklocadora.adcsgrtaxvlr    ,
    avivclstt         like datkavisveic.avivclstt       ,
    viginc            like abbmclaus.viginc             ,
    vigfnl            like abbmclaus.vigfnl             ,
    sinitfcod         smallint                          ,
    sinitfdsc         char (70)                         ,
    snhflg            char (01)                         ,
    blqnivcod         like datkblq.blqnivcod            ,
    vcllicant         like datmservico.vcllicnum        ,
    cidnom            like datmlcl.cidnom               ,
    ufdcod            like datmlcl.ufdcod               ,
    frqvlr            dec (6,2)                         ,
    cct               integer                           ,
    cgccpfdig         like datmavisrent.locrspcpfdig    ,
    nomeusu           char (40)
 end record

 define ws2           record
    viginc            like datklcvsit.viginc            ,
    vigfnl            like datklcvsit.vigfnl
 end record

 define ws_atdsrvnum  like datmservico.atdsrvnum
 define ws_atdsrvano  like datmservico.atdsrvano
 define ws_atdetpcod  like datmsrvacp.atdetpcod

 #osf32867 - Paula
 define w_ret record
    segnom           like gsakseg.segnom       ,
    corsus           like datmservico.corsus   ,
    cornom           like datmservico.cornom   ,
    cvnnom           char (20)                 ,
    vclcoddig        like datmservico.vclcoddig,
    vcldes           like datmservico.vcldes   ,
    vclanomdl        like datmservico.vclanomdl,
    vcllicnum        like datmservico.vcllicnum,
    vclchsinc        like abbmveic.vclchsinc   ,
    vclchsfnl        like abbmveic.vclchsfnl   ,
    vclcordes        char (12)
 end record
 #osf32867 - Paula

  define l_viginc     date
        ,l_cts08g01   char(01)
        ,l_count      smallint
        ,l_today      date
        ,l_vcldevdat  date

  define la_pptcls    array[05] of record
         clscod       like aackcls.clscod,
         carencia     date
  end record

  define lr_dados     record
         succod       like datrligapol.succod,
         aplnumdig    like datrligapol.aplnumdig,
         autsitatu    like abbmdoc.dctnumseq,
         itmnumdig    like datrligapol.itmnumdig,
         edsnumref    like datrligapol.edsnumref
  end record

  define n_lcvcod         smallint,
         l_cod_erro       smallint,
         l_concede_ar     smallint,
         l_tipo_ordenacao char(01)

  define l_cidcod      like glakcid.cidcod,
         l_msg         char(100)

  define l_data        date,
         l_hora2       datetime hour to minute,
         l_qtde        smallint,
         l_desc_1      char(40),
         l_desc_2      char(40),
         l_clscod      like aackcls.clscod,
         l_linha1      char(40),
         l_linha2      char(40),
         l_linha3      char(40),
         l_linha4      char(40),
         l_acao        char(1)

  initialize  hist_cts15m15.*  to  null

        let  ws_atdsrvnum  =  null
        let  ws_atdsrvano  =  null
        let  ws_atdetpcod  =  null
        let  l_tipo_ordenacao = null
        let  l_cod_erro   = null
        let  l_concede_ar = false
        let  l_qtde          = 0
        let   l_linha1         = null
        let   l_linha2         = null
        let   l_linha3         = null
        let   l_linha4         = null
        let   l_acao           = null

        initialize  ws.*  to  null

        initialize  ws2.*  to  null

 let ws.vcllicant = d_cts15m15.vcllicnum

 initialize ws.* to null
 initialize m_cts15ant.*    to null

 let ws.pgtflg = false

 if mr_geral.atdsrvnum is not null  and
    mr_geral.atdsrvano is not null  then
    select atdsrvnum, atdsrvano
      from dblmpagto
     where atdsrvnum = mr_geral.atdsrvnum  and
           atdsrvano = mr_geral.atdsrvano

    if sqlca.sqlcode = 0  then
       let ws.pgtflg = true
    end if
 end if

 display by name d_cts15m15.lcvnom

 if (mr_geral.succod    is null  or
     mr_geral.ramcod    is null  or
     mr_geral.aplnumdig is null  or
     mr_geral.itmnumdig is null) and
    (mr_geral.prporg    is null  or
     mr_geral.prpnumdig is null) then
 else
    if mr_geral.atdsrvnum is null  and
       mr_geral.atdsrvano is null  then
       let d_cts15m15.vclloctip = 1
    end if
    case d_cts15m15.vclloctip
       when 1  let d_cts15m15.vcllocdes = "SEGURADO"
       when 2  let d_cts15m15.vcllocdes = "CORRETOR"
       when 3  let d_cts15m15.vcllocdes = "DEPTO."
       when 4  let d_cts15m15.vcllocdes = "FUNC."
    end case
    display by name d_cts15m15.vclloctip
    display by name d_cts15m15.vcllocdes
 end if

 let m_cts15ant.* = d_cts15m15.*
 input by name d_cts15m15.nom      ,
               d_cts15m15.corsus   ,
               d_cts15m15.cornom   ,
               d_cts15m15.vclcoddig,
               d_cts15m15.vclanomdl,
               d_cts15m15.vcllicnum,
               d_cts15m15.avilocnom,
               d_cts15m15.locrspcpfnum,
               d_cts15m15.locrspcpfdig,
               d_cts15m15.avialgmtv,
               d_cts15m15.garantia,
               d_cts15m15.flgarantia,
               #d_cts15m15.cauchqflg,
               d_cts15m15.lcvcod   ,
               d_cts15m15.lcvextcod,
               d_cts15m15.cdtoutflg,
               d_cts15m15.avivclcod,
               d_cts15m15.frmflg   ,
               d_cts15m15.aviproflg,
               d_cts15m15.smsenvdddnum,
               d_cts15m15.smsenvcelnum,
               d_cts15m15.cttdddcod,
               d_cts15m15.ctttelnum,
               d_cts15m15.atdlibflg without defaults

   before field nom
          if ws.pgtflg = true  then
             call cts08g01("A","N","","","LOCACAO PAGA NAO DEVE SER ALTERADA!",
                                      "") returning ws.confirma
             next field frmflg
          end if

          if mr_geral.atdsrvnum is not null  and
             mr_geral.atdsrvano is not null  then
             if d_cts15m15.vclloctip = 2  or
                d_cts15m15.vclloctip = 3  or
                d_cts15m15.vclloctip = 4  then
                display by name d_cts15m15.nom      , d_cts15m15.corsus   ,
                                d_cts15m15.cornom   , d_cts15m15.vclcoddig,
                                d_cts15m15.vclanomdl, d_cts15m15.vcllicnum,
                                d_cts15m15.avilocnom
                if d_cts15m15.vclloctip = 4  then
                   next field locrspcpfnum
                else
                   next field avilocnom
                end if
             end if
          end if

          while true
             if d_cts15m15.vclloctip is not null  then
                exit while
             end if

             call cts15m09(ws.vclloctip,
                           d_cts15m15.corsus,
                           d_cts15m15.cornom,
                           w_cts15m15.slcemp,
                           w_cts15m15.slcsuccod,
                           w_cts15m15.slcmat,
                           w_cts15m15.slccctcod,
                           g_documento.ciaempcod)
                 returning d_cts15m15.vclloctip,
                           d_cts15m15.corsus,
                           d_cts15m15.cornom,
                           w_cts15m15.slcemp,
                           w_cts15m15.slcsuccod,
                           w_cts15m15.slcmat,
                           w_cts15m15.slccctcod,
                           g_documento.ciaempcod

             if d_cts15m15.corsus     is null and
                d_cts15m15.cornom     is null and
                w_cts15m15.slcemp     is null and
                w_cts15m15.slcsuccod  is null and
                w_cts15m15.slcmat     is null and
                w_cts15m15.slccctcod  is null then
                initialize d_cts15m15.vclloctip to null
                call cts08g01("C","S","",
                                      "ABANDONA O PREENCHIMENTO DO LAUDO ?",
                                      "","")
                     returning ws.confirma

                if ws.confirma  =  "S"   then
                   exit while
                end if
             else
                case d_cts15m15.vclloctip
                   when 1  let d_cts15m15.vcllocdes = "SEGURADO"
                   when 2  let d_cts15m15.vcllocdes = "CORRETOR"
                   when 3  let d_cts15m15.vcllocdes = "DEPTO."
                   when 4  let d_cts15m15.vcllocdes = "FUNC."
                end case

                let d_cts15m15.nom       = d_cts15m15.cornom
                let d_cts15m15.avilocnom = d_cts15m15.cornom

                if d_cts15m15.vclloctip <> 2 then
                   initialize d_cts15m15.cornom to null
                end if

                display by name d_cts15m15.vclloctip
                display by name d_cts15m15.vcllocdes
                display by name d_cts15m15.nom
                display by name d_cts15m15.avilocnom
                display by name d_cts15m15.corsus

                if d_cts15m15.vclloctip = 4 then
                   next field locrspcpfnum
                else
                   next field nom
                end if
             end if
          end while
          if ws.confirma  =  "S"   then
             let int_flag = true
             exit input
          end if
          display by name d_cts15m15.nom        attribute (reverse)
          let m_cts15ant.nom = d_cts15m15.nom

   after  field nom
          display by name d_cts15m15.nom
           if m_erro_msg is not null  then
             error m_erro_msg
             next field nom
          end if
          if m_reserva.loccntcod is not null then
             call cts08g01("A","N","","ALTERACAO NAO PERMITIDA.",
                                      "VEICULO ENTREGUE AO CLIENTE","")
                  returning ws.confirma
             next field nom
          end if

          ## Para sinistro, somente consulta o laudo
          if mr_geral.acao = 'SIN' or
             mr_geral.acao = 'CON' then
             let ws.confirma = cts08g01('A', 'N', '', 'NAO E POSSIVEL ALTERAR O LAUDO'
                                       ,'LIBERADO SOMENTE PARA CONSULTA', '')
             next field nom
          end if

          if d_cts15m15.nom is null  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if d_cts15m15.vclloctip = 2  or
             d_cts15m15.vclloctip = 3  then
             next field avilocnom
          end if

   before field corsus
          display by name d_cts15m15.corsus     attribute (reverse)
          let m_cts15ant.corsus = d_cts15m15.corsus

   after  field corsus
          display by name d_cts15m15.corsus

   before field cornom
          display by name d_cts15m15.cornom     attribute (reverse)
          let m_cts15ant.cornom = d_cts15m15.cornom

   after  field cornom
          display by name d_cts15m15.cornom

   before field vclcoddig
          display by name d_cts15m15.vclcoddig  attribute (reverse)
          let m_cts15ant.vclcoddig = d_cts15m15.vclcoddig

   after  field vclcoddig
          display by name d_cts15m15.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts15m15.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          end if

          if d_cts15m15.vclcoddig is null  or
             d_cts15m15.vclcoddig =  0     then
             call agguvcl() returning d_cts15m15.vclcoddig
             next field vclcoddig
          end if

          let d_cts15m15.vcldes = cts15g00(d_cts15m15.vclcoddig)

          display by name d_cts15m15.vcldes

   before field vclanomdl
          display by name d_cts15m15.vclanomdl  attribute (reverse)
          display by name d_cts15m15.vclanomdl

   after  field vclanomdl
          display by name d_cts15m15.vclanomdl

          if d_cts15m15.vclanomdl is null  then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts15m15.vclcoddig,
                         d_cts15m15.vclanomdl) = false  then
                error " Veiculo nao consta como fabricado em ",
                        d_cts15m15.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts15m15.vcllicnum  attribute (reverse)
          let m_cts15ant.vcllicnum = d_cts15m15.vcllicnum

   after  field vcllicnum
          display by name d_cts15m15.vcllicnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclanomdl
          end if

          if d_cts15m15.vcllicnum  is not null   then
             if not srp1415(d_cts15m15.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

          #---------------------------------------------------------------------
          # Chama tela de verificacao de bloqueios cadastrados
          #---------------------------------------------------------------------
          if mr_geral.aplnumdig   is null       and
             d_cts15m15.vcllicnum    is not null   then

             if d_cts15m15.vcllicnum  = ws.vcllicant   then
             else
                initialize ws.snhflg  to null

                call cts13g00(d_cts15m15.c24astcod,
                              "", "", "", "",
                              d_cts15m15.vcllicnum,
                              "", "", "")
                     returning ws.blqnivcod, ws.snhflg

                if ws.blqnivcod  =  2     and
                   ws.snhflg     =  "n"   then
                   error " Bloqueio necessita de permissao para atendimento!"
                   next field vcllicnum
                end if
             end if
          end if

          #Verifica usuario X segurado
          if mr_geral.atdsrvnum    is null       then
             if mr_geral.succod    is not null   and
                mr_geral.aplnumdig is not null   and
                mr_geral.itmnumdig is not null   and
                d_cts15m15.c24astcod  = 'KA1'    then
                open window w_cts15m15b at 11,26 with 07 rows,33 columns
                     attribute(border,prompt  line last - 1)
                display "          A T E N C A O          " at 01,01 attribute (reverse)
                display "---------------------------------" at 02,01
                display "     SEGURADO SERA O USUARIO     " at 04,01
                while true
                   prompt "       (S)im ou (N)ao ? " for ws.confirma
                   if ws.confirma is not null then
                      let ws.confirma = upshift(ws.confirma)
                      if ws.confirma <>  "S"  and
                         ws.confirma <>  "N"  then
                      else
                         exit while
                      end if
                   end if
                end while
                close window w_cts15m15b
                let int_flag = false

                if ws.confirma = "S" then
                   let d_cts15m15.avilocnom =  d_cts15m15.nom
                   # -> REMOVER ESTE ACESSO FIXO QUANDO O XML ESTIVER OK
                   select cgccpfnum,
                          cgccpfdig
                    into d_cts15m15.locrspcpfnum,
                         d_cts15m15.locrspcpfdig
                    from datkazlapl
                   where succod    = mr_geral.succod
                     and ramcod    = mr_geral.ramcod
                     and aplnumdig = mr_geral.aplnumdig
                     and itmnumdig = mr_geral.itmnumdig
                     and edsnumdig = mr_geral.edsnumref
                else
                   let d_cts15m15.avilocnom    = null
                   let d_cts15m15.locrspcpfdig = null
                   let d_cts15m15.locrspcpfnum = null
                end if

                display by name d_cts15m15.avilocnom
                display by name d_cts15m15.locrspcpfnum
                display by name d_cts15m15.locrspcpfdig
             end if
          end if

   before field avilocnom
          if mr_geral.succod    is not null   and
             mr_geral.aplnumdig is not null   and
             mr_geral.itmnumdig is not null   then
             call cts44g01_claus_azul(mr_geral.succod,
                                      mr_geral.ramcod,
                                      mr_geral.aplnumdig,
                                      mr_geral.itmnumdig)
                     returning w_cts15m15.temcls,w_cts15m15.clscod
          end if

          display by name d_cts15m15.avilocnom  attribute (reverse)

   after  field avilocnom

          display by name d_cts15m15.avilocnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m15.vclloctip = 1  then
                next field vcllicnum
             else
                if mr_geral.atdsrvnum is not null  and
                   mr_geral.atdsrvano is not null  then
                   next field avilocnom
                else
                   initialize d_cts15m15.vclloctip, d_cts15m15.vcllocdes,
                              d_cts15m15.nom      , d_cts15m15.avilocnom,
                              d_cts15m15.corsus   , d_cts15m15.vclloctip to null
                   display by name d_cts15m15.vclloctip
                   display by name d_cts15m15.vcllocdes
                   display by name d_cts15m15.nom
                   display by name d_cts15m15.avilocnom
                   display by name d_cts15m15.corsus
                   next field nom
                end if
             end if
          end if

          if d_cts15m15.avilocnom is null  then
             error " Informe o nome do usuario!"
             next field avilocnom
          end if

   before field locrspcpfnum
          if mr_geral.atdsrvnum is null  then
             call cts15m02(w_cts15m15.clscod)
                 returning ws.ok_flg, ws.cidnom, ws.ufdcod
                 let m_cidnom = ws.cidnom # webservice localiza
                 let m_ufdcod = ws.ufdcod # webservice localiza

             if ws.ok_flg          is null  then
                error " Criterios para locacao nao foram atendidos!"
                next field locrspcpfnum
             end if
          end if
          display by name d_cts15m15.locrspcpfnum  attribute (reverse)
          let m_cts15ant.locrspcpfnum = d_cts15m15.locrspcpfnum

   after  field locrspcpfnum

          display by name d_cts15m15.locrspcpfnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m15.vclloctip = 4 then
                if mr_geral.atdsrvnum is not null  and
                   mr_geral.atdsrvano is not null  then
                   next field locrspcpfnum
                else
                   initialize d_cts15m15.vclloctip, d_cts15m15.vcllocdes,
                              d_cts15m15.nom      , d_cts15m15.avilocnom,
                              d_cts15m15.corsus   , d_cts15m15.vclloctip to null
                   display by name d_cts15m15.vclloctip
                   display by name d_cts15m15.vcllocdes
                   display by name d_cts15m15.nom
                   display by name d_cts15m15.avilocnom
                   display by name d_cts15m15.corsus
                   next field nom
                end if
             else
                next field avilocnom
             end if
          end if
          if d_cts15m15.locrspcpfnum is null then
             next field avialgmtv
          end if

   before field locrspcpfdig
          display by name d_cts15m15.locrspcpfdig  attribute (reverse)
          let m_cts15ant.locrspcpfdig = d_cts15m15.locrspcpfdig

   after  field locrspcpfdig
          display by name d_cts15m15.locrspcpfdig

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field locrspcpfnum
          end if

          if d_cts15m15.locrspcpfnum is not null and
             d_cts15m15.locrspcpfdig is     null then
             error " Digito do Cpf incorreto!"
             next field locrspcpfdig
          end if

          if d_cts15m15.locrspcpfnum is not null and
             d_cts15m15.locrspcpfdig is not null then
             call F_FUNDIGIT_DIGITOCPF(d_cts15m15.locrspcpfnum)
                             returning ws.cgccpfdig

             if ws.cgccpfdig            is null           or
                d_cts15m15.locrspcpfdig <> ws.cgccpfdig   then
                error " Digito do Cpf incorreto!"
                next field locrspcpfdig
             end if
          end if

   before field avialgmtv
          display by name d_cts15m15.avialgmtv  attribute (reverse)
          let m_cts15ant.avialgmtv = d_cts15m15.avialgmtv

   after  field avialgmtv
          display by name d_cts15m15.avialgmtv

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m15.locrspcpfnum is null then
                next field locrspcpfnum
             else
                next field locrspcpfdig
             end if
          end if

           if d_cts15m15.avialgmtv is null then
              call cts15m15_popup_motivos()
                   returning d_cts15m15.avialgmtv
              display by name d_cts15m15.avialgmtv

              if d_cts15m15.avialgmtv is null then
                 next field avialgmtv
              end if

           end if




          if d_cts15m15.c24astcod = "KA1" then
             if (( d_cts15m15.avialgmtv  is null ) or
                 ( d_cts15m15.avialgmtv  <> 1      and
                   d_cts15m15.avialgmtv  <> 3      and
                   d_cts15m15.avialgmtv  <> 11     and
                   d_cts15m15.avialgmtv  <> 12     and
                   d_cts15m15.avialgmtv  <> 18 ))  then
                #error " Motivos: (1)Sinistro (3)Benef P.Total (11)Liberacao Sinistro (12)Liberacao Comercial (18)Benef P.Parcial"
                next field avialgmtv
             end if
          end if

          if d_cts15m15.avialgmtv = 1 then
             --pesquisa clausulas de carro extra 58A,B,C,D,E,F,G,H,I,J,K,L,M,N
             call cts44g01_claus_azul(mr_geral.succod,
                                      mr_geral.ramcod,
                                      mr_geral.aplnumdig,
                                      mr_geral.itmnumdig)
                     returning w_cts15m15.temcls,w_cts15m15.clscod

             if w_cts15m15.temcls = false then
                call cts08g01("A","N","*****  ATENCAO  *****",
                              " ","DOCUMENTO SEM CLAUSULA CONTRATADA", " ")
                     returning ws.confirma
                let int_flag = true
                next field avialgmtv
             end if
          end if


          if d_cts15m15.c24astcod = "KA1" then
              open ccts15m15008 using d_cts15m15.avialgmtv
              whenever error continue
              fetch ccts15m15008 into d_cts15m15.avimtvdes
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = 100 then
                    let d_cts15m15.avimtvdes = null
                 else
                    error 'Erro SELECT datkdominio:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                    let m_erro = true
                    return
                 end if
              end if
          end if

          display by name d_cts15m15.avimtvdes

          if d_cts15m15.avialgmtv = 3 then ---> Beneficio
             initialize l_desc_1, l_desc_2, l_clscod  to null

             ---> Verifica se tem Clausula 37B ou 37C
             call cts11m10_clausulas(l_handle)
                           returning l_desc_1 ---> Km Taxi
                                    ,l_desc_2 ---> Limite so p/ Plus II
                                    ,l_clscod
             if l_clscod = "37B" then

                call cts08g01("A","N","",
                              "LIMITE TOTAL DAS DESPESAS: ATE R$ 90,00"
                             ,"POR DIARIA, NAO PODENDO EXCEDER 08 DIAS" , "" )
                     returning ws.confirma
             end if


             if l_clscod = "37C" then ---> Gratuita

                call cts08g01("A","N",
                              "APOLICE POSSUI CLAUSULA"
                             ,"37C - ASSISTENCIA GRATUITA."
                             ,"NAO HA COBERTURA DE CARRO EXTRA"
                             ,"GRATUITO POR INDENIZACAO INTEGRAL.")
                     returning ws.confirma

                next field avialgmtv
             end if


             if l_clscod = "37H" then ---> Gratuita

                call cts08g01("A","N",
                              "APOLICE POSSUI CLAUSULA"
                             ,"37H - ASSISTENCIA GRATUITA."
                             ,"NAO HA COBERTURA DE CARRO EXTRA"
                             ,"GRATUITO POR INDENIZACAO INTEGRAL.")
                     returning ws.confirma

                next field avialgmtv
             end if

             if l_clscod = "37D" or l_clscod = "37E" or
		          l_clscod = "37F" or l_clscod = "37G" then
		             error "Assunto nao permitido"
		             let d_cts15m15.avialgmtv = ''
		             next field avialgmtv
             end if
          end if

          if d_cts15m15.avialgmtv = 1  or
             d_cts15m15.avialgmtv = 3  or
             d_cts15m15.avialgmtv = 6  or
             d_cts15m15.avialgmtv = 9  or
             d_cts15m15.avialgmtv = 18 then

             if d_cts15m15.avialgmtv <> 6 then
               #-------------------------
               # Verifica se existe reserva para este motivo no prazo de 04 dias
               #-------------------------
                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                let l_today = l_data - 4 units day
                open c_cts15m15_002 using mr_geral.succod
                                       ,mr_geral.aplnumdig
                                       ,mr_geral.itmnumdig
                                       ,l_today, l_data
                foreach c_cts15m15_002 into ws_atdsrvnum, ws_atdsrvano
                   whenever error continue
                   open ccts15m15009 using ws_atdsrvnum, ws_atdsrvano

                   fetch ccts15m15009 into l_qtde
                   whenever error stop

                   if sqlca.sqlcode <> 0 then
                      error "Erro <", sqlca.sqlcode ,"> ao localizar reservas "
                   end if

                   if l_qtde > 0 then
                      continue foreach
                   end if

                   if mr_geral.atdsrvnum is not null    and
                      mr_geral.atdsrvnum = ws_atdsrvnum then
                      continue foreach
                   end if

                   select atdetpcod
                     into ws_atdetpcod
                     from datmsrvacp
                    where atdsrvnum = ws_atdsrvnum
                      and atdsrvano = ws_atdsrvano
                      and atdsrvseq = (select max(atdsrvseq)
                                         from datmsrvacp
                                        where atdsrvnum = ws_atdsrvnum
                                          and atdsrvano = ws_atdsrvano)

                   if ws_atdetpcod = 1 or
                      ws_atdetpcod = 4 then
                       call cts08g01("A","N","",
                                        "HA' RESERVA(S) PARA MOTIVO(S)01,03",
                                        "ATIVA, FAVOR VERIFICAR!","")
                           returning ws.confirma
                      next field avialgmtv
                   end if

                end foreach
             end if

               if d_cts15m15.avialgmtv <> 6 then
                  let slv_terceiro.succod    = null
                  let slv_terceiro.aplnumdig = null
                  let slv_terceiro.itmnumdig = null
                  let w_ret.vclchsinc        = null
                  let w_ret.vclchsfnl        = null
                  let w_ret.vcllicnum        = null
               end if

              whenever error continue
              open ccts15m15008 using d_cts15m15.avialgmtv
              fetch ccts15m15008 into d_cts15m15.avimtvdes
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = 100 then
                    let d_cts15m15.avimtvdes = null
                 else
                    error 'Erro SELECT datkdominio:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                    let m_erro = true
                    return
                 end if
              end if
             display by name d_cts15m15.avialgmtv
             display by name d_cts15m15.avimtvdes
          else
             initialize w_cts15m15.avioccdat, w_cts15m15.ofnnom   ,
                        w_cts15m15.ofndddcod, w_cts15m15.ofntelnum  to null
          end if


          if (d_cts15m15.avialgmtv = 11 or
              d_cts15m15.avialgmtv = 12) and
             (g_documento.acao <> "ALT" and
              g_documento.acao <> "CON" or
              g_documento.acao is null ) then
             call cts08g01_opcao_funcao("A","N",
                           "REGISTRE DADOS, UTILIZANDO A FUNCAO ",
                           "(F6)HISTORICO, DE QUEM ESTA AUTORIZANDO",
                           "ESTA RESERVA:",
                           "NOME/FONE/DEPARTAMENTO/AREA",
                           2)
                 returning ws.confirma,hist_cts15m15.*
          end if

          if (mr_geral.atdsrvnum is null   or
              mr_geral.atdsrvano is null)  then
              call cts15m04("R"                 , d_cts15m15.avialgmtv,
                            ""                  , w_cts15m15.aviretdat,
                            w_cts15m15.avirethor, w_cts15m15.aviprvent,
                            ""                  , ws.endcep
                                                , d_cts15m15.dtentvcl)
                  returning w_cts15m15.aviretdat, w_cts15m15.avirethor,
                            w_cts15m15.aviprvent, ws.cct, ws.cct, ws.cct

              let ws.diasem = weekday(w_cts15m15.aviretdat)
          end if

   before field garantia
          display by name d_cts15m15.garantia
          let m_cts15ant.garantia = d_cts15m15.garantia clipped, ":"
          next field flgarantia


   after  field garantia
          display by name d_cts15m15.garantia

   before field flgarantia

       if  g_documento.acao is null or
           g_documento.acao = 'INC' then
         let   m_opcao = null
         call cts15m15_popup_garantia()
      end if

        if d_cts15m15.garantia is null then
           let d_cts15m15.garantia = "Garantia:"
        else
           let d_cts15m15.garantia = d_cts15m15.garantia clipped , ':'
        end if


        display by name d_cts15m15.garantia
        display by name d_cts15m15.flgarantia
        let m_cts15ant.flgarantia = d_cts15m15.flgarantia

   after  field flgarantia
          display by name d_cts15m15.flgarantia

          if d_cts15m15.flgarantia is null or
             d_cts15m15.flgarantia = "N" then

              call cts15m15_popup_garantia()

          end if

          if d_cts15m15.garantia is null then
             let d_cts15m15.garantia = "Garantia"
          else
              let d_cts15m15.garantia = d_cts15m15.garantia clipped, ':'
          end if

          display by name d_cts15m15.garantia
          display by name d_cts15m15.flgarantia

          if m_opcao = 1 then
             let d_cts15m15.cauchqflg = "N"
                call cts08g01("I","S","","CARTAO SUJEITO A PRE-ANALISE","",
                              "COM GARANTIA DE CREDITO DE R$800,00.")
                 returning ws.confirma

                 if ws.confirma = "N" then
                    next field flgarantia
                 end if
          else
              if m_opcao = 2 then
                 call cts08g01("A","S","",
                                         "A OPCAO PARA LOCACAO DEVERA SER FEITA",
                                         "","POR INTERMEDIO DE CHEQUE CAUCAO?")
                       returning ws.confirma
                 if ws.confirma = "S" then
                    let d_cts15m15.cauchqflg = "S"
                 else
                    next field flgarantia
                 end if
              end if

              if m_opcao = 3 then
                 call cts08g01_6l("A","S","",
                               "A OPCAO DE ISENCAO DE GARANTIA ",
                               "DISPENSARÁ APRESENTACAO DE CARTAO DE ",
                               "CREDITO OU CHEQUE CAUCAO SOB TOTAL",
                               "RESPONSABILIDADE DA AZUL SEGUROS ",
                               "")
                       returning ws.confirma

                 if ws.confirma = "N" then
                    next field flgarantia
                 end if
              end if

          end if

          if (d_cts15m15.c24astcod = 'KA1' and
             (d_cts15m15.avialgmtv = 1 or d_cts15m15.avialgmtv = 5)) then
             let d_cts15m15.lcvsinavsflg = 'N'
          else
             let d_cts15m15.lcvsinavsflg = 'N'
             next field lcvcod
          end if

   before field lcvcod
          display by name d_cts15m15.lcvcod     attribute (reverse)
          let m_cts15ant.lcvcod = d_cts15m15.lcvcod
          let m_cts15ant.lcvextcod = d_cts15m15.lcvextcod

   after  field lcvcod
          display by name d_cts15m15.lcvcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if (d_cts15m15.c24astcod = 'KA1' and
                (d_cts15m15.avialgmtv = 1 or d_cts15m15.avialgmtv = 5)) then
             else
                next field flgarantia
             end if
          end if

          ##Verifica se trocou locadora
             if g_documento.acao = "ALT" and
                m_cts15ant.lcvcod <> d_cts15m15.lcvcod then
                initialize m_reserva.*  to null
                call ctd31g00_ver_reserva(1, g_documento.atdsrvnum,
                                             g_documento.atdsrvano)
                     returning m_reserva.rsvlclcod, m_reserva.rsvsttcod
                if m_reserva.rsvlclcod is not null and
                   m_reserva.rsvlclcod <> 0 and
                   m_reserva.rsvsttcod = 2 then
                   let l_linha2 = 'RESERVA COM NR LOCALIZADOR: ',
                                  m_reserva.rsvlclcod clipped
                   call cts08g01("A","N",
                                 'ALTERACAO DA LOCADORA NAO PERMITIDA.',
                                 l_linha2,
                                 'NECESSARIO CANCELAR ESTA E REALIZAR',
                                 'OUTRA NA NOVA LOCADORA ESCOLHIDA')
                          returning ws.confirma
                   let d_cts15m15.lcvcod = m_cts15ant.lcvcod
                   next field lcvcod
                end if
             end if
          if d_cts15m15.lcvcod is null then
             error " Codigo da locadora deve ser informado!"

             call ctn00c02 (ws.ufdcod,ws.cidnom," "," ")
                 returning ws.endcep, ws.endcepcmp

             if ws.endcep is null  or
                ws.endcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field lcvcod
             else

               call ctn18c00("",
                             ws.endcep, ws.endcepcmp, w_cts15m15.clscod,
                             ws.diasem, 1, d_cts15m15.avialgmtv,
                             g_documento.ciaempcod)
                    returning d_cts15m15.lcvcod   ,
                              d_cts15m15.aviestcod,
                              ws.vclpsqflg

                initialize d_cts15m15.lcvextcod, d_cts15m15.aviestnom to null

                select lcvextcod, aviestnom
                  into d_cts15m15.lcvextcod,
                       d_cts15m15.aviestnom
                  from datkavislocal
                 where lcvcod    = d_cts15m15.lcvcod
                   and aviestcod = d_cts15m15.aviestcod
             end if
          end if

          select lcvnom, lcvstt, adcsgrtaxvlr, cdtsegtaxvlr, acntip
            into d_cts15m15.lcvnom,
                 ws.lcvstt,
                 ws.adcsgrtaxvlr,
                 d_cts15m15.cdtsegtaxvlr,
                 d_cts15m15.acntip
            from datklocadora
           where lcvcod = d_cts15m15.lcvcod

          if sqlca.sqlcode <> 0  then
             error " Locadora nao cadastrada!"
             next field lcvcod
          else
             if ws.lcvstt <> "A"  then
                error " Locadora cancelada!"
                next field lcvcod
             end if
          end if

          display by name d_cts15m15.lcvnom

   before field lcvextcod
          display by name d_cts15m15.lcvextcod attribute (reverse)
          if m_cts15ant.lcvextcod is null then
             let m_cts15ant.lcvextcod = d_cts15m15.lcvextcod
          end if

   after  field lcvextcod
          display by name d_cts15m15.lcvextcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field lcvcod
          end if

          if d_cts15m15.lcvextcod is null  then
             error " Informe a loja para retirada do veiculo!"

             call ctn00c02 (ws.ufdcod,ws.cidnom," "," ")
                 returning ws.endcep, ws.endcepcmp

             if ws.endcep is null     then
                error " Nenhum criterio foi selecionado!"
             else
                 call ctn18c00(d_cts15m15.lcvcod, ws.endcep, ws.endcepcmp,
                               w_cts15m15.clscod, ws.diasem, 0, 0,
                               g_documento.ciaempcod)
                 returning ws.lcvcod, d_cts15m15.aviestcod, ws.vclpsqflg

                initialize d_cts15m15.lcvextcod, d_cts15m15.aviestnom to null

                select lcvextcod, aviestnom
                  into d_cts15m15.lcvextcod,
                       d_cts15m15.aviestnom
                  from datkavislocal
                 where lcvcod    = d_cts15m15.lcvcod
                   and aviestcod = d_cts15m15.aviestcod

             end if
             next field lcvextcod
          else
             select aviestcod   ,         aviestnom,
                    vclalglojstt,         lcvlojtip,
                    lcvregprccod,         cauchqflg,
                    prtaertaxvlr
               into d_cts15m15.aviestcod, d_cts15m15.aviestnom,
                    ws.vclalglojstt     , ws.lcvlojtip,
                    ws.lcvregprccod     , ws.cauchqflg,
                    ws.prtaertaxvlr
               from datkavislocal
              where lcvcod    = d_cts15m15.lcvcod
                and lcvextcod = d_cts15m15.lcvextcod

             if sqlca.sqlcode = notfound  then
                error " Loja nao cadastrada ou nao pertencente a esta locadora!"
                next field lcvextcod
             end if

             if ws.vclalglojstt <>  1   then
                if ws.vclalglojstt =  2   then  # <-- verifica periodo bloqueio
                   initialize ws2.*  to null
                   select viginc, vigfnl
                     into ws2.viginc, ws2.vigfnl
                     from datklcvsit
                    where datklcvsit.lcvcod     = d_cts15m15.lcvcod
                      and datklcvsit.aviestcod  = d_cts15m15.aviestcod

                   if sqlca.sqlcode = 0 then
                      if ws2.viginc <= w_cts15m15.aviretdat and
                         ws2.vigfnl >= w_cts15m15.aviretdat then
                         error " Loja bloqueada para esta data! periodo de bloqueio ",ws2.viginc," a ",ws2.vigfnl
                         next field lcvextcod
                        else
                         error " ATENCAO: Loja bloqueada para locacao ",
                               "no periodo de ",ws2.viginc," a ",ws2.vigfnl,"!"
                               sleep 2
                      end if
                   end if
                  else
                   error " Loja cancelada! Selecione outra loja."
                   next field lcvextcod
                end if
             end if

             if w_cts15m15.clscod is not null  then
                let n_lcvcod = 0
                select count(*)  into n_lcvcod
                  from datrclauslocal
                 where lcvcod    = d_cts15m15.lcvcod     and
                       aviestcod = d_cts15m15.aviestcod  and
                       ramcod    in (31,531)             and
                       clscod    = w_cts15m15.clscod

              -- CT Alberto if sqlca.sqlcode = notfound  then

                if  n_lcvcod = 0 then
                   error " Loja nao disponivel para atendimento a clausula ", w_cts15m15.clscod, "!"
                   next field lcvextcod
                end if
             end if

             if d_cts15m15.cauchqflg = "S" then
                if ws.cauchqflg = "N"    or
                   ws.cauchqflg is null  then
                   call cts08g01("I","N","","LOJA SELECIONADA NAO ACEITA",
                                         "","CHEQUE CAUCAO.")
                        returning ws.confirma
                   next field lcvextcod
                end if
             end if

             display by name d_cts15m15.aviestnom

          end if

          if ws.prtaertaxvlr is not null and
             ws.prtaertaxvlr <> 0        then
             let ws.msgtxt = "SERAO ACRESCIDOS EM ",
                              ws.prtaertaxvlr using "<<&.&&",
                             "% REFERENTE"
             call cts08g01("I","N", "OS VALORES QUE FICAREM SOB",
                                    "RESPONSABILIDADE DO SEGURADO/USUARIO",
                                     ws.msgtxt,
                                    "A TAXA AEROPORTUARIA.")
                 returning ws.confirma
          end if

          if (mr_geral.atdsrvnum is null   or
              mr_geral.atdsrvano is null)  then
              call cts15m04_valloja(d_cts15m15.avialgmtv,
                                    d_cts15m15.aviestcod,
                                    w_cts15m15.aviretdat,
                                    w_cts15m15.avirethor,
                                    w_cts15m15.aviprvent,
                                    d_cts15m15.lcvcod   ,
                                    ws.endcep   )
                  returning ws.confirma
              if ws.confirma = "N" then
                 next field lcvextcod
              end if
          end if

   before field cdtoutflg
          #PSI 198390
          #exibir alerta informando se locadora cobra taxa 2 condutor
          if d_cts15m15.cdtsegtaxvlr is not null and
             d_cts15m15.cdtsegtaxvlr > 0 then
             call cts08g01("I","N", "", "LOCADORA COBRA TAXA DIARIA DE ",
                                        "2º CONDUTOR",
                                         d_cts15m15.cdtsegtaxvlr)
                      returning ws.confirma
          end if
          display by name d_cts15m15.cdtoutflg     attribute (reverse)
          let m_cts15ant.cdtoutflg = d_cts15m15.cdtoutflg

   after  field cdtoutflg
          display by name d_cts15m15.cdtoutflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lcvextcod
          end if

          if d_cts15m15.cdtoutflg is null  or
            (d_cts15m15.cdtoutflg <> "S"   and
             d_cts15m15.cdtoutflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field cdtoutflg
          end if

          if d_cts15m15.cdtoutflg = "S"  then
             let ws.confirma = cts08g01("A","N","","DEVERA SER FORNECIDO A LOCADORA",
                                                   "COPIAS DO RG, CIC E HABILITACAO",
                                                   "DO(S) SEGUNDO(S) CONDUTOR(ES).")
             #exibir valor da taxa de 2 condutor da locadora
             display by name d_cts15m15.cdtsegtaxvlr
          else
             #PSI 198390
             display " " to cdtsegtaxvlr
          end if


   before field avivclcod
          display by name d_cts15m15.avivclcod  attribute (reverse)
          let m_cts15ant.avivclcod = d_cts15m15.avivclcod

   after  field avivclcod
          display by name d_cts15m15.avivclcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field cdtoutflg
          end if

          # ---> ORDENACAO DOS VEICULOS NORMAL
          let l_tipo_ordenacao = "N"

          if d_cts15m15.avialgmtv = 1 or
             d_cts15m15.avialgmtv = 3 or
             d_cts15m15.avialgmtv = 6 or
             d_cts15m15.avialgmtv = 9 then

             initialize lr_dados to null

             if d_cts15m15.avialgmtv = 6 then
                # ---> PASSA OS DADOS DA APOLICE DO TERCEIRO
                let lr_dados.succod    = slv_terceiro.succod
                let lr_dados.aplnumdig = slv_terceiro.aplnumdig
                let lr_dados.itmnumdig = slv_terceiro.itmnumdig
                let lr_dados.edsnumref = slv_terceiro.edsnumref
             else
                let lr_dados.succod    = mr_geral.succod
                let lr_dados.aplnumdig = mr_geral.aplnumdig
                let lr_dados.itmnumdig = mr_geral.itmnumdig
                let lr_dados.edsnumref = mr_geral.edsnumref
             end if

          end if

          let l_concede_ar = true

          if l_concede_ar then
             let l_tipo_ordenacao = "A"  # ---> ORDENA OS VEICULOS POR AR CONDICIONADO
          else
             let l_tipo_ordenacao = "N"  # ---> ORDENACAO DOS VEICULOS NORMAL
          end if

          if d_cts15m15.avivclcod  is null   or
             d_cts15m15.avivclcod  =  "  "   then
             error " Escolha veiculo de preferencia. Se nao disponivel sera reservado outro do grupo!"
             call ctn17c00(d_cts15m15.lcvcod,
                           d_cts15m15.aviestcod,
                           l_tipo_ordenacao,
                           g_documento.ciaempcod,
                           d_cts15m15.avialgmtv, #PSI 244.813 Cadastro Veiculo - Carro Extra
                           "")

                  returning d_cts15m15.avivclcod

             next field avivclcod

          end if

          select lcvcod   , avivclmdl,
                 avivcldes, avivclgrp,
                 avivclstt,
                 frqvlr, isnvlr, rduvlr                #PSI 198390
            into ws.lcvcod   , ws.avivclmdl,
                 ws.avivcldes, d_cts15m15.avivclgrp,
                 ws.avivclstt,
                 d_cts15m15.frqvlr,                    #PSI 198390
                 d_cts15m15.isnvlr,                    #PSI 198390
                 d_cts15m15.rduvlr                     #PSI 198390
            from datkavisveic
           where lcvcod    = d_cts15m15.lcvcod
             and avivclcod = d_cts15m15.avivclcod

          if sqlca.sqlcode = notfound  then
             error " Veiculo nao cadastrado !"
             next field avivclcod
          end if

          if d_cts15m15.lcvcod <> ws.lcvcod then
             error " Este veiculo nao esta' disponivel nesta locadora!"
             next field avivclcod
          end if

          if ws.avivclstt <> "A"  then
             error " Veiculo CANCELADO nao pode ser reservado!"
             next field avivclcod
          end if

          let d_cts15m15.avivclvlr = 0
          let d_cts15m15.locsegvlr = 0

          select lcvvcldiavlr, lcvvclsgrvlr
            into d_cts15m15.avivclvlr,
                 d_cts15m15.locsegvlr
            from datklocaldiaria
           where lcvcod       = d_cts15m15.lcvcod
             and avivclcod    = d_cts15m15.avivclcod
             and lcvlojtip    = ws.lcvlojtip
             and lcvregprccod = ws.lcvregprccod
             and w_cts15m15.aviretdat between  datklocaldiaria.viginc
             and                               datklocaldiaria.vigfnl
             and 1                    between  datklocaldiaria.fxainc
             and                               datklocaldiaria.vigfnl

          if d_cts15m15.avivclvlr is null   or
             d_cts15m15.avivclvlr  = 0      then
             error " Valor de diaria nao cadastrado! Selecione outro veiculo ou loja."
             next field lcvextcod
          end if

          let d_cts15m15.avivcldes = ws.avivclmdl clipped," (",
                                     ws.avivcldes clipped,")"
          let d_cts15m15.vcldiavlr = d_cts15m15.avivclvlr + d_cts15m15.locsegvlr

          if mr_geral.succod    is not null   and
             mr_geral.aplnumdig is not null   and
             mr_geral.itmnumdig is not null   then
             call cts44g01_claus_azul(mr_geral.succod,
                                      mr_geral.ramcod,
                                      mr_geral.aplnumdig,
                                      mr_geral.itmnumdig)
                     returning w_cts15m15.temcls,w_cts15m15.clscod
          end if

          call cts15m15_condicoes()

          if d_cts15m15.isnvlr is not null and
             d_cts15m15.isnvlr <> 0 then
             call cts08g01("I",
                           "N",
                           "LOCADORA OFERECE TAXA DIARIA DE ",
                           "ISENCAO NA PARTICIPACAO EM CASO ",
                           "DE SINISTRO. ",
                           d_cts15m15.isnvlr)

                   returning ws.confirma
          end if

          if d_cts15m15.rduvlr is not null and
             d_cts15m15.rduvlr <> 0 then

             call cts08g01("I",
                           "N",
                           "LOCADORA OFERECE TAXA DIARIA DE ",
                           "REDUCAO NA PARTICIPACAO EM CASO ",
                           "DE SINISTRO. ",
                           d_cts15m15.rduvlr)

                  returning ws.confirma
          end if


          display by name d_cts15m15.avivcldes
          display by name d_cts15m15.vcldiavlr
          display by name d_cts15m15.avivclgrp
          display by name d_cts15m15.frqvlr
          display by name d_cts15m15.isnvlr
          display by name d_cts15m15.rduvlr

          if w_cts15m15.clsflg  =  TRUE   then
             let ws.msgtxt = "SALDO DE DIARIAS DISPONIVEIS: ", w_cts15m15.sldqtd using "<<&"
             call cts08g01("I","N","CLAUSULA CARRO EXTRA CONTRATADA","", ws.msgtxt,"")
                 returning ws.confirma
          end if

          initialize ws.msgtxt to null

          if w_cts15m15.clsflg =  FALSE    or
             w_cts15m15.clsflg is null     then
             if d_cts15m15.locsegvlr is not null  and
                d_cts15m15.locsegvlr > 0          then
                let ws.msgtxt = "   VALOR SEGURO AO DIA: R$ ",d_cts15m15.locsegvlr using "<<<<&.&&"

                call cts08g01("I","N","TAXA DE PROTECAO NAO INCLUSO NO ",
                                      "VALOR DA DIARIA. ", "", ws.msgtxt)
                     returning ws.confirma
             else

                call cts08g01("I","N","","TAXA DE PROTECAO INCLUSO NO ",
                                         "VALOR DA DIARIA. ","")
                     returning ws.confirma

             end if
          end if

          if (d_cts15m15.avivclgrp <> "A"  and     #Veiculo nao basico
              (d_cts15m15.frqvlr = 0 or
               d_cts15m15.frqvlr is null)) then

               call cts08g01("I","N","",
                             "PARTICIPACAO OBRIGATORIA EM CASO DE ",
                             "SINISTRO ATE O LIMITE DE 10% DO VALOR ",
                             "DE MERCADO DO AUTOMOVEL LOCADO ")
                 returning ws.confirma
          end if
          # para Azul so veiculo Basico
          if (d_cts15m15.avivclgrp = "A"  and
             (d_cts15m15.frqvlr    = 0    or
              d_cts15m15.frqvlr is null)) then
             call cts08g01("I","N","",
                           "EM CASO DE SINISTRO HA UMA           ",
                           "PARTICIPACAO DE R$ 800,00","")
                  returning ws.confirma
          end if

          if d_cts15m15.cauchqflg = "S" then
             if d_cts15m15.avivclgrp = "A" or
                d_cts15m15.avivclgrp = "B" then
                call cts08g01("I","N", "",
                              "CHEQUE CAUCAO DE R$ 800.00","","")
                      returning ws.confirma
             else  # demais grupos
                call cts08g01("I","N","",
                              "VERIFICAR VALORES PARA CHEQUE CAUCAO ",
                              "COM A LOCADORA","")
                      returning ws.confirma
             end if
          end if

          let d_cts15m15.frmflg = "N"
          let w_cts15m15.atdfnlflg = "N"
          display by name d_cts15m15.frmflg
          next field aviproflg

   before field frmflg
          if mr_geral.atdsrvnum is null  and
             mr_geral.atdsrvano is null  then
             let d_cts15m15.frmflg = "N"
             display by name d_cts15m15.frmflg attribute (reverse)
             let m_cts15ant.frmflg = d_cts15m15.frmflg
          else
             if w_cts15m15.atdfnlflg = "S"  then
                call cts11g00(w_cts15m15.lignum)

                if ws.pgtflg = true  then
                   let int_flag = true
                   exit input
                else
                   let m_cts15ant.frmflg = d_cts15m15.frmflg
                   next field aviproflg
                end if
             else
                exit input
             end if
          end if

   after  field frmflg
          display by name d_cts15m15.frmflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field avivclcod
          end if

          if d_cts15m15.frmflg is null  or
            (d_cts15m15.frmflg <> "S"   and
             d_cts15m15.frmflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field frmflg
          end if

          if d_cts15m15.frmflg = "S"  then
             call cts02m05(8) returning w_cts15m15.atddat,
                                        w_cts15m15.atdhor,
                                        w_cts15m15.funmat,
                                        w_cts15m15.cnldat,
                                        w_cts15m15.atdfnlhor,
                                        w_cts15m15.c24opemat,
                                        ws.pstcoddig

             if w_cts15m15.atddat    is null  or
                w_cts15m15.atdhor    is null  or
                w_cts15m15.funmat    is null  or
                w_cts15m15.cnldat    is null  or
                w_cts15m15.atdfnlhor is null  or
                w_cts15m15.c24opemat is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let w_cts15m15.atdfnlflg = "S"
             let w_cts15m15.atdetpcod =  4
          else
             let w_cts15m15.atdfnlflg = "N"
          end if

   before field aviproflg
          display by name d_cts15m15.aviproflg attribute (reverse)
          let m_cts15ant.aviproflg = d_cts15m15.aviproflg
          if m_reserva.loccntcod is null and
             d_cts15m15.acntip = 3 and
             g_documento.acao is not null then
             next field smsenvdddnum
          end if

   after  field aviproflg
          display by name d_cts15m15.aviproflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if mr_geral.atdsrvnum is null  then
                next field frmflg
             else
                next field avivclcod
             end if
          end if

          if d_cts15m15.aviproflg is null  or
            (d_cts15m15.aviproflg <> "S"   and
             d_cts15m15.aviproflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field aviproflg
          end if

          if d_cts15m15.aviproflg = "S"  then

          let m_reenvio = true

          if d_cts15m15.avialgmtv = 11 or
             d_cts15m15.avialgmtv = 12 then
             call cts08g01_opcao_funcao("A","N",
                           "REGISTRE DADOS, UTILIZANDO A FUNCAO ",
                           "(F6)HISTORICO, DE QUEM ESTA AUTORIZANDO",
                           "ESTA RESERVA:",
                           "NOME/FONE/DEPARTAMENTO/AREA",
                           2)
                 returning ws.confirma,hist_cts15m15.*
          end if
             call cts15m05(mr_geral.atdsrvnum,
                           mr_geral.atdsrvano,
                           d_cts15m15.lcvcod,
                           d_cts15m15.aviestcod ,
                           ws.endcep        ,
                           d_cts15m15.avialgmtv ,
                           d_cts15m15.dtentvcl,
                           d_cts15m15.avivclgrp,
                           d_cts15m15.lcvsinavsflg)
             returning w_cts15m15.procan,
                       w_cts15m15.aviprodiaqtd

             if w_cts15m15.procan = "P" then
                if w_cts15m15.aviprodiaqtd is null or
                   w_cts15m15.aviprodiaqtd =  0    then
                   select aviprodiaqtd
                       into w_cts15m15.aviprodiaqtd
                       from datmprorrog
                      where atdsrvnum = mr_geral.atdsrvnum
                        and atdsrvano = mr_geral.atdsrvano
                end if
             end if
          else
             if d_cts15m15.frmflg = "S"  then
                call cts15m04("F"                 , d_cts15m15.avialgmtv,
                              d_cts15m15.aviestcod, w_cts15m15.aviretdat,
                              w_cts15m15.avirethor, w_cts15m15.aviprvent,
                              d_cts15m15.lcvcod   ,
                              ws.endcep           , d_cts15m15.dtentvcl  )
                    returning w_cts15m15.aviretdat, w_cts15m15.avirethor,
                              w_cts15m15.aviprvent, ws.cct, ws.cct, ws.cct

             end if
          end if

          if w_cts15m15.aviretdat   is null    or
             w_cts15m15.avirethor   is null    or
             w_cts15m15.aviprvent   is null    then
             error " Data/hora da retirada e dias de utilizacao devem ser informados!"
             next field aviproflg
          end if

   before field smsenvdddnum
          display by name d_cts15m15.smsenvdddnum  attribute (reverse)
          let m_cts15ant.smsenvdddnum = d_cts15m15.smsenvdddnum

   after field smsenvdddnum
          display by name d_cts15m15.smsenvdddnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
                 if m_reserva.loccntcod is null and
                    d_cts15m15.lcvcod = 2  and
                    g_documento.acao is not null then
                    next field frmflg
                 else
                    next field aviproflg
                 end if
              #end if
             #next field aviproflg
          end if


   before field smsenvcelnum
          display by name d_cts15m15.smsenvcelnum  attribute (reverse)
          let m_cts15ant.smsenvcelnum = d_cts15m15.smsenvcelnum

   after field smsenvcelnum
          display by name d_cts15m15.smsenvcelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left") then
             next field smsenvdddnum
          end if

          if (d_cts15m15.smsenvcelnum  is null      or
             d_cts15m15.smsenvcelnum  = "   "    ) and
             d_cts15m15.smsenvcelnum is not null   then
             error " Informe o celular para confirmacao da reserva"
             next field smsenvcelnum
          end if


   before field cttdddcod
          display by name d_cts15m15.cttdddcod  attribute (reverse)
          let m_cts15ant.cttdddcod = d_cts15m15.cttdddcod

   after  field cttdddcod
          display by name d_cts15m15.cttdddcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field smsenvcelnum
          end if

          if d_cts15m15.cttdddcod  is null    or
             d_cts15m15.cttdddcod  = "   "    then
             error " Informe o DDD do telefone para confirmacao da reserva"
             next field cttdddcod
          end if

   before field ctttelnum
          display by name d_cts15m15.ctttelnum  attribute (reverse)
          let m_cts15ant.ctttelnum = d_cts15m15.ctttelnum

   after  field ctttelnum
          display by name d_cts15m15.ctttelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left") then
             next field cttdddcod
          end if

          if d_cts15m15.ctttelnum  is null    or
             d_cts15m15.ctttelnum  = "   "    then
             error " Informe o telefone de contato para confirmacao da reserva"
             next field ctttelnum
          end if

   before field atdlibflg
          display by name d_cts15m15.atdlibflg  attribute (reverse)
          let m_cts15ant.atdlibflg = d_cts15m15.atdlibflg

   after  field atdlibflg
          display by name d_cts15m15.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field ctttelnum
          end if

          if ((d_cts15m15.atdlibflg  is null)  or
              (d_cts15m15.atdlibflg <> "S"     and
               d_cts15m15.atdlibflg <> "N"))   then
             error " Informacao sobre liberacao deve ser (S)im ou (N)ao!"
             next field atdlibflg
          else
             if d_cts15m15.atdlibflg = "N"  then
                error " Nao ha' possibilidade de programacao. Solicite novo contato!"
                next field atdlibflg
             end if
          end if

   on key (f17,control-c,interrupt)
      if mr_geral.atdsrvnum  is null then
         let ws.confirma =
         cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")

         if ws.confirma = "S" then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if d_cts15m15.c24astcod is not null then
            call ctc58m00_vis(d_cts15m15.c24astcod)
         end if
      end if

   on key (F3)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if d_cts15m15.vclloctip  =  3  or
            d_cts15m15.vclloctip  =  4  then
            if mr_geral.atdsrvnum is not null  and
               mr_geral.atdsrvano is not null  then
               call cts15m08(d_cts15m15.vclloctip,
                             w_cts15m15.slcemp,
                             w_cts15m15.slcsuccod,
                             w_cts15m15.slcmat,
                             w_cts15m15.slccctcod,
                             "C" )               #--> (A)tualiza/(C)onsulta
                   returning w_cts15m15.slcemp,
                             w_cts15m15.slcsuccod,
                             w_cts15m15.slcmat,
                             w_cts15m15.slccctcod,
                             ws.nomeusu    #-> neste caso nome funcionari
            end if
         end if
      end if

   on key (F4)


      if d_cts15m15.acntip = 3 then
         call cts15m15_dados_locacao()
      else
         let m_cts08g01 = cts08g01("A"
                                   ,"N"
                                   ,"ESTA RESERVA FOI ENCAMINHADA VIA FAX."
                                   ,"A FUNCAO F4-DADOS LOC E EXCUSIVA "
                                   ,"PARA RESERVAS ENCAMINHADAS VIA ONLINE"
                                   ,"")
      end if

   on key (F5)

      let g_monitor.horaini = current ## Flexvision
      call cta01m12_espelho(mr_geral.ramcod,
                            mr_geral.succod,
                            mr_geral.aplnumdig,
                            mr_geral.itmnumdig,
                            mr_geral.prporg,
                            mr_geral.prpnumdig,
                            mr_geral.fcapacorg,
                            mr_geral.fcapacnum,
                            "",  # pcacarnum
                            "",  # pcaprpitm
                            "",  # cmnnumdig,
                            "",  # crtsaunum
                            "",  # bnfnum
                            g_documento.ciaempcod)

   on key (F6)
      if mr_geral.atdsrvnum is null then
         call cts10m02(hist_cts15m15.*) returning hist_cts15m15.*
         #error " Acesso ao historico somente com cadastramento do servico!"
      else
         call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
         call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                       g_issk.funmat, l_data, l_hora2)
      end if

   on key (F7)
      let m_reenvio = true
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if mr_geral.atdsrvnum is null then
            error " Impressao somente com cadastramento do servico!"
         else
            let m_f7 = true
            call cts15m15_acionamento(mr_geral.atdsrvnum,
                                      mr_geral.atdsrvano,
                                      d_cts15m15.lcvcod,
                                      d_cts15m15.aviestcod,0,'',
                                      w_cts15m15.procan)
         end if
      end if

   on key (F8)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if mr_geral.atdsrvnum is null then
            error " Consulta as informacoes de retirada somente apos digitacao do servico!"
         else
            let l_acao = "C"
            if g_documento.acao ="ALT" then
               let l_acao = "A"
            end if
            call cts15m04(l_acao              , d_cts15m15.avialgmtv,
                          d_cts15m15.aviestcod, w_cts15m15.aviretdat,
                          w_cts15m15.avirethor, w_cts15m15.aviprvent,
                          d_cts15m15.lcvcod   , ws.endcep
                        , d_cts15m15.dtentvcl)
                returning w_cts15m15.aviretdat, w_cts15m15.avirethor,
                          w_cts15m15.aviprvent, ws.cct, ws.cct, ws.cct
         end if
      end if

   on key (F9)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if mr_geral.atdsrvnum is null then
            error " Servico nao cadastrado!"
         else
           if d_cts15m15.atdlibflg = "N"   then
              error " Servico nao liberado!"
            else
              if d_cts15m15.lcvcod     is null   or
                 d_cts15m15.aviestcod  is null   then
                 error " Locadora/loja para retirada de veiculo nao informada!" sleep 2
              else
                 call cts15m01(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                               d_cts15m15.lcvcod    , d_cts15m15.aviestcod ,
                               d_cts15m15.avialgmtv )
              end if
            end if
         end if
      end if

 end input

 if int_flag then
    error " Operacao cancelada!"
 end if

 #ligia - fornax - 01/06/2011
 if g_documento.acao = "ALT" or
    g_documento.acao is null then
    call cts15m15_ver_alt_laudo()
 end if
end function

#--------------------------------------------------------------------
 function cts15m15_condicoes()
#--------------------------------------------------------------------

 initialize d_cts15m15.cndtxt  to null
 initialize w_cts15m15.sldqtd  to null

 let w_cts15m15.clsflg    = FALSE
 let w_cts15m15.avidiaqtd = 0

 if d_cts15m15.avialgmtv = 1    and
    d_cts15m15.avivclgrp = "A"  then
    if w_cts15m15.clscod[1,2] = "58"  then
       let d_cts15m15.cndtxt = "CLAUSULA ", w_cts15m15.clscod
       let w_cts15m15.clsflg = true
       call ctx01g00_saldo_novo(mr_geral.succod   , mr_geral.aplnumdig,
                           mr_geral.itmnumdig, mr_geral.atdsrvnum,
                           mr_geral.atdsrvano, w_cts15m15.datasaldo ,
                           1, true,g_documento.ciaempcod,
                           d_cts15m15.avialgmtv,
                           d_cts15m15.c24astcod)
                 returning g_lim_diaria, w_cts15m15.sldqtd

       if w_cts15m15.sldqtd is null  then
          let w_cts15m15.sldqtd = 0
       end if
    else
       let d_cts15m15.cndtxt = "1 DIARIA GRATUITA"
       let w_cts15m15.avidiaqtd = 1
    end if
 else
 end if

 display by name d_cts15m15.cndtxt

end function

#-----------------------------------------------------------------------------
 function cts15m15_salvaglobal(param)
#-----------------------------------------------------------------------------
    define param   record
        segflg     char(01)
    end record

    if param.segflg = "S"  then
       let slv_segurado.succod        = mr_geral.succod
       let slv_segurado.ramcod        = mr_geral.ramcod
       let slv_segurado.aplnumdig     = mr_geral.aplnumdig
       let slv_segurado.itmnumdig     = mr_geral.itmnumdig
       let slv_segurado.edsnumref     = mr_geral.edsnumref
       let slv_segurado.lignum        = mr_geral.lignum
       let slv_segurado.c24soltipcod  = mr_geral.c24soltipcod
       let slv_segurado.solnom        = mr_geral.solnom
       let slv_segurado.c24astcod     = mr_geral.c24astcod
       let slv_segurado.ligcvntip     = mr_geral.ligcvntip
       let slv_segurado.prporg        = mr_geral.prporg
       let slv_segurado.prpnumdig     = mr_geral.prpnumdig
       let slv_segurado.fcapacorg     = mr_geral.fcapacorg
       let slv_segurado.fcapacnum     = mr_geral.fcapacnum

       -------------[ mesma rotina de inicializacao do cta00m01 ]-------------
       initialize g_dctoarray            to null
       initialize mr_geral.succod     to null
       initialize mr_geral.ramcod     to null
       initialize mr_geral.aplnumdig  to null
       initialize mr_geral.itmnumdig  to null
       initialize mr_geral.edsnumref  to null
       initialize mr_geral.fcapacorg  to null
       initialize mr_geral.fcapacnum  to null
    else
       let mr_geral.succod         = slv_segurado.succod
       let mr_geral.ramcod         = slv_segurado.ramcod
       let mr_geral.aplnumdig      = slv_segurado.aplnumdig
       let mr_geral.itmnumdig      = slv_segurado.itmnumdig
       let mr_geral.edsnumref      = slv_segurado.edsnumref
       let mr_geral.lignum         = slv_segurado.lignum
       let mr_geral.c24soltipcod   = slv_segurado.c24soltipcod
       let mr_geral.solnom         = slv_segurado.solnom
       let mr_geral.c24astcod      = slv_segurado.c24astcod
       let mr_geral.ligcvntip      = slv_segurado.ligcvntip
       let mr_geral.prporg         = slv_segurado.prporg
       let mr_geral.prpnumdig      = slv_segurado.prpnumdig
       let mr_geral.fcapacorg      = slv_segurado.fcapacorg
       let mr_geral.fcapacnum      = slv_segurado.fcapacnum
    end if
 end function

#-----------------------------------------#
 function cts15m15_acionamento(lr_param)
#-----------------------------------------#

   define lr_param record
                   atdsrvnum  like datmservico.atdsrvnum
                  ,atdsrvano  like datmservico.atdsrvano
                  ,lcvcod     like datklocadora.lcvcod
                  ,aviestcod  like datmavisrent.aviestcod
                  ,atdetpcod  like datmsrvint.atdetpcod
                  ,etpmtvcod  like datksrvintmtv.etpmtvcod
                  ,procan     char(1)
                  end record

   define lr_ctc30g00 record
                      resultado    smallint
                     ,mensagem     char(100)
                     ,acntip       like datklocadora.acntip
                     ,lcvresenvcod like datklocadora.lcvresenvcod
                      end record

   define lr_ctc18g00 record
                      resultado smallint
                     ,mensagem  char(100)
                      end record

   define lr_cts33g00 record
                      resultado smallint
                     ,mensagem  char(100)
                     ,atdetpseq like datmsrvint.atdetpseq
                     ,atdetpcod like datmsrvint.atdetpcod
                      end record

   define lr_retorno record
          resultado      smallint
         ,mensagem       char(60)
         ,atdsrvseq      like datmsrvacp.atdsrvseq
   end record

   define lr_etapa record
          resultado smallint
         ,mensagem  char(60)
         ,atdetpcod like datmsrvacp.atdetpcod
         ,pstcoddig like datmsrvacp.pstcoddig
         ,srrcoddig like datmsrvacp.srrcoddig
         ,socvclcod like datmsrvacp.socvclcod
   end record
   define lr_erro record
          sqlcode smallint,
          mens    char(80)
   end record

   define l_maides like datkavislocal.maides

   define l_prestador decimal(10,0)
         ,l_retorno   smallint
         ,l_flag      smallint
         ,l_sissgl    char(10)
         ,l_etapa     like datmsrvacp.atdetpcod



   initialize lr_ctc30g00 to null
   initialize lr_ctc18g00 to null
   initialize lr_cts33g00 to null
   initialize lr_retorno  to null
   initialize lr_etapa    to null
   initialize lr_erro.* to null

   let l_maides    = null
   let l_prestador = null
   let l_retorno   = null
   let l_flag      = false
   let l_etapa     = null
   let l_sissgl    = null


   #Obter o tipo de acionamento de acordo com a locadora
   call ctc30g00_dados_loca(1, lr_param.lcvcod)
      returning lr_ctc30g00.resultado
               ,lr_ctc30g00.mensagem
               ,lr_ctc30g00.acntip
               ,lr_ctc30g00.lcvresenvcod
               ,l_maides

   #Verificar se a loja/locadora esta conectada na Internet
   if lr_ctc30g00.lcvresenvcod = 1 then #Enviar para Locadora
      let l_prestador = lr_param.lcvcod
      let l_sissgl = 'LCVONLINE'
   else #enviar para loja
      #Obter o email da loja
      call ctc18g00_dados_loja(2, lr_param.lcvcod, lr_param.aviestcod)
         returning lr_ctc18g00.resultado
                  ,lr_ctc18g00.mensagem
                  ,l_maides
      let l_prestador = lr_param.aviestcod
      let l_sissgl = 'RLCONLINE'
   end if

   if lr_ctc30g00.acntip = 1 then #Internet
      call fissc101_prestador_sessao_ativa(l_prestador, l_sissgl)
           returning l_flag

      if l_flag = true then #Prestador esta conectado na internet
         #Obter sequencia/etapa do servico para internet
         call cts33g00_inf_internet(lr_param.atdsrvnum, lr_param.atdsrvano)
            returning lr_cts33g00.resultado
                     ,lr_cts33g00.mensagem
                     ,lr_cts33g00.atdetpseq
                     ,lr_cts33g00.atdetpcod

         if lr_cts33g00.resultado = 3 then
            error lr_cts33g00.mensagem
            return
         end if

         #Gravar o servico nas tabelas da Internet
         call cts33g00_registrar_para_internet(lr_param.atdsrvano
                                              ,lr_param.atdsrvnum
                                              ,lr_cts33g00.atdetpseq
                                              ,lr_param.atdetpcod
                                              ,l_prestador
                                              ,g_issk.usrtip
                                              ,g_issk.empcod
                                              ,g_issk.funmat
                                              ,lr_param.etpmtvcod)
            returning lr_cts33g00.resultado
                     ,lr_cts33g00.mensagem

         if lr_cts33g00.resultado = 2 then
            error lr_cts33g00.mensagem
            return
         end if

         #Inserir Etapa de Enviado
         if lr_param.atdetpcod = 0 then ##Aguardando
            let l_etapa = 43  #Enviado
            error "Servico enviado ao Portal de Negocios"
         else
            let l_etapa = 5   #Cancelado
            ##Obter a sequencia da etapa anterior
            call cts10g04_max_seq (lr_param.atdsrvnum , lr_param.atdsrvano ,'')
                 returning lr_retorno.*

            ##Obter a etapa anterior
            call cts10g04_ultimo_pst (lr_param.atdsrvnum ,
                                      lr_param.atdsrvano ,lr_retorno.atdsrvseq)
                 returning lr_etapa.*
         end if

         let l_retorno = cts10g04_insere_etapa(lr_param.atdsrvnum
                                              ,lr_param.atdsrvano
                                              ,l_etapa
                                              ,lr_param.lcvcod
                                              ,''
                                              ,''
                                              ,lr_param.aviestcod)

      end if
   end if

   #Se prestador nao esta conectado na Internet ou ele recebe por fax, enviar laudo por fax
   if l_flag = false or lr_ctc30g00.acntip = 2 then #Fax

      if lr_ctc30g00.acntip = 3 and
         m_prorrog = false then

          call ctx28g00_stt_listener_locadora(lr_param.lcvcod)
               returning lr_erro.sqlcode,lr_erro.mens

          if lr_erro.sqlcode = 1 then
             # Chama webservice Localiza

             call cts15m15_webservice(lr_param.atdsrvnum, lr_param.atdsrvano,
                                      g_documento.acao, lr_param.procan)
                  returning lr_erro.sqlcode,lr_erro.mens
             if lr_erro.sqlcode <> 0 then
                error lr_erro.mens
                call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
             else
               error "Solicitacao enviada com sucesso !"  sleep 1
             end if
          else
            call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
          end if
      else
         if lr_ctc30g00.acntip <> 3 or
            m_prorrog = true then
            call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
         end if

      end if

   else

      if (l_etapa = 5 and lr_etapa.atdetpcod > 1) or
          l_etapa = 43 or lr_ctc30g00.acntip is null then
          #Enviar o laudo da reserva para o email da loja/locadora
          call cts15m14_email(lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,l_maides ,'T','','' ) #Para identificar Internet
      end if

   end if

 end function

#===================================================
function cts15m15_webservice(lr_param)
#===================================================

  define lr_param record
         atdsrvnum like datmservico.atdsrvnum
        ,atdsrvano like datmservico.atdsrvano
        ,acao      char(3)
        ,procan    char(1)
  end record

  define lr_reserva record
         cnfenvcod     like datmrsvvcl.cnfenvcod    ,
         rsvsttcod     like datmrsvvcl.rsvsttcod    ,
         atzdianum     like datmrsvvcl.atzdianum    ,
         loccautip     like datmrsvvcl.loccautip ,
         vclretagncod  like datmrsvvcl.vclretagncod ,
         vclrethordat  like datmrsvvcl.vclrethordat ,
         vclretufdcod  like datmrsvvcl.vclretufdcod ,
         vclretcidnom  like datmrsvvcl.vclretcidnom ,
         vcldvlagncod  like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat  like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod  like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom  like datmrsvvcl.vcldvlcidnom ,
         smsenvdddnum  like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum  like datmrsvvcl.smsenvcelnum ,
         envemades     like datmrsvvcl.envemades    ,
         vclloccdrtxt  like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt
  end record

  define lr_datmavisrent record

         lcvcod          like datmavisrent.lcvcod
        ,aviestcod       like datmavisrent.aviestcod
        ,avirsrgrttip    like datmavisrent.avirsrgrttip
        ,aviprvent       like datmavisrent.aviprvent
        ,avirethor       like datmavisrent.avirethor
        ,aviretdat       like datmavisrent.aviretdat
        ,cdtoutflg       like datmavisrent.cdtoutflg

  end record

  define lr_erro record
        sqlcode smallint,
        mens    char(80)
  end record

  define lr_cts15m16   record
    msg1             char (50),
    msg2             char (50)
  end record

  define l_datahs    char(30),
         l_data      datetime year to day,
         l_hor       datetime hour to second,
         l_datadvlhs char(30)

  define lr_funapol   record
         resultado    char(01),
         dctnumseq    decimal(4,0),
         vclsitatu    decimal(4,0),
         autsitatu    decimal(4,0),
         dmtsitatu    decimal(4,0),
         dpssitatu    decimal(4,0),
         appsitatu    decimal(4,0),
         vidsitatu    decimal(4,0)
  end record
  define l_motivo like datmavisrent.avialgmtv
  define l_dias_atz_cia like datmprorrog.aviprodiaqtd
  define l_aviprostt    like datmprorrog.aviprostt

  initialize lr_datmavisrent.* to null
  initialize lr_reserva.* to null
  initialize lr_erro.* to null
  initialize lr_cts15m16.* to null
  initialize lr_funapol.* to null
  let l_dias_atz_cia  = 0

  let l_datahs   = null
  let l_datadvlhs   = null
  let l_data     = null
  let l_hor      = null

  if m_prep_sql is null or
     m_prep_sql = false then
     call cts15m15_prepara()
  end if

  let int_flag= false
  call f_funapol_ultima_situacao
      (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
       returning lr_funapol.*

  if m_f7 = true and
     g_documento.acao is null then
     return 1, ''
  end if
  if g_documento.acao is null or
     m_ctd31.rsvlclcod is not null then
     call cts15m16(lr_param.atdsrvnum, lr_param.atdsrvano)
          returning lr_cts15m16.msg1,lr_cts15m16.msg2
  end if
 open ccts15m15037 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano

 whenever error continue
 fetch ccts15m15037 into lr_datmavisrent.lcvcod ,lr_datmavisrent.aviestcod   ,lr_datmavisrent.aviretdat
                         ,lr_datmavisrent.avirethor, lr_datmavisrent.aviprvent
                         ,lr_datmavisrent.avirsrgrttip, lr_datmavisrent.cdtoutflg,l_motivo
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       display 'Dados da reserva nao foram encontrados ', lr_param.atdsrvnum,' / ' ,lr_param.atdsrvano
       error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
    else
       error 'Erro SELECT ccts15m15037 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'CTS15M00 / cts15m15_webservice() / ',lr_param.atdsrvnum,' / '
                                                  ,lr_param.atdsrvano sleep 1
    end if

 end if


 open ccts15m15036 using lr_datmavisrent.lcvcod,
                         lr_datmavisrent.aviestcod
 whenever error continue
 fetch ccts15m15036 into lr_reserva.vclretagncod,
                         lr_reserva.vclretufdcod,
                         lr_reserva.vclretcidnom

 whenever error stop

 if sqlca.sqlcode <> 0 then
    error 'Erro ao buscar loja '
 end if

 if m_cidnom is not null and
    m_ufdcod is not null then
    let lr_reserva.vclretufdcod = m_ufdcod
    let lr_reserva.vclretcidnom = m_cidnom
 end if


 let l_data = lr_datmavisrent.aviretdat
 let l_hor  = lr_datmavisrent.avirethor
 let l_datahs = l_data,
                " ",
                l_hor
 # Calculo da data de devolução de acordo com a atzdianum

 let l_data = lr_datmavisrent.aviretdat + lr_datmavisrent.aviprvent units day
 let l_hor  = lr_datmavisrent.avirethor
 let l_datadvlhs = l_data,
                   " ",
                   l_hor

 let lr_reserva.atzdianum    = lr_datmavisrent.aviprvent
 let lr_reserva.loccautip    = lr_datmavisrent.avirsrgrttip
 let lr_reserva.vclrethordat = l_datahs clipped
 let lr_reserva.vcldvlagncod = lr_reserva.vclretagncod
 let lr_reserva.vcldvlhordat = l_datadvlhs clipped
 let lr_reserva.vcldvlufdcod = lr_reserva.vclretufdcod
 let lr_reserva.vcldvlcidnom = lr_reserva.vclretcidnom
 let lr_reserva.smsenvdddnum = d_cts15m15.smsenvdddnum
 let lr_reserva.smsenvcelnum = d_cts15m15.smsenvcelnum
 let lr_reserva.vclloccdrtxt = lr_datmavisrent.cdtoutflg
 let lr_reserva.vclloccdrtxt = lr_cts15m16.msg1," ",lr_cts15m16.msg2

 if lr_datmavisrent.cdtoutflg = "S" then
    let lr_reserva.vclcdtsgnindtxt = 'PARA ESTA LOCACAO HAVERA SEGUNDO(S) CONDUTOR(ES)'
 end if

 # Regra criada para motivos particular ( zerar diarias autorizadas pela porto)
 if l_motivo = 5 then
    let  lr_reserva.atzdianum   = 0
 end if
 # ligia - 26/05/11

 if lr_param.acao = "ALT" or lr_param.acao = "CAN" or m_f7 = true then
    # Verifica se a reserva foi realizada via online e situacao
    call ctd31g00_ver_solicitacao(lr_param.atdsrvnum, lr_param.atdsrvano)
         returning m_ctd31.*
    if m_ctd31.rsvlclcod is not null then
       if lr_param.acao = "CAN" then
          ## cancelar reserva
          call ctd31g00_canc_rsv(lr_param.atdsrvnum
                                 ,lr_param.atdsrvano, 1
                                 ,lr_reserva.vclloccdrtxt)
               returning lr_erro.sqlcode, lr_erro.mens
       else
          if lr_param.acao = "ALT" then
                let l_aviprostt = "A"
                open ccts15m15040 using lr_param.atdsrvnum
                                       ,lr_param.atdsrvano
                                       ,lr_param.atdsrvnum
                                       ,lr_param.atdsrvano
                                       ,l_aviprostt
                whenever error continue
                let l_dias_atz_cia = 0
                fetch ccts15m15040 into l_dias_atz_cia
                close ccts15m15040
                if l_dias_atz_cia is null then
                   let l_dias_atz_cia = 0
                end if
                if l_dias_atz_cia > 0 then ##dias autorizados CIA
                      let lr_reserva.atzdianum = lr_reserva.atzdianum +
                                                 l_dias_atz_cia
                end if
             if lr_param.procan = "P" then ##se for prorrogacao
                call ctd31g00_alt_diarias(lr_param.atdsrvnum,
                                          lr_param.atdsrvano,
                                          g_lim_diaria,
                                          lr_reserva.atzdianum,
                                          ###g_data_ret,
                                          g_data_dev,
                                          lr_reserva.vclloccdrtxt)
                     returning lr_erro.sqlcode, lr_erro.mens
             else
                if lr_param.procan = "C" then ##se for cancelamentoprorrogacao
                   let l_aviprostt = "C"
                   #open ccts15m15040 using lr_param.atdsrvnum
                   #                       ,lr_param.atdsrvano
                   #                       ,lr_param.atdsrvnum
                   #                       ,lr_param.atdsrvano
                   #                       ,l_aviprostt
                   #whenever error continue
                   #let l_dias_atz_cia = 0
                   #fetch ccts15m15040 into l_dias_atz_cia
                   #close ccts15m15040
                   #if l_dias_atz_cia > 0 then ##dias autorizados CIA
                      call ctd31g00_canc_prorrog(lr_param.atdsrvnum,
                                                 lr_param.atdsrvano,
                                                 g_lim_diaria,
                                                 lr_reserva.atzdianum,
                                                 lr_reserva.vclloccdrtxt)
                            returning lr_erro.sqlcode, lr_erro.mens
                   #end if
                else ##dias autorizados USUARIO
                     ##nao enviar solicitacao
             #   end if
             #end if
                   if m_f7 = true then ## REENVIO DA RESERVA
                      # Verifica se Já Houve Reserva
                      if  ctd31g00_verifica_reenvio(lr_param.atdsrvnum,
                                                    lr_param.atdsrvano) then
                          call ctd31g00_reenvio(lr_param.atdsrvnum,
                                                lr_param.atdsrvano, 1,
                                                lr_reserva.vclloccdrtxt)
                               returning lr_erro.sqlcode, lr_erro.mens
                          if lr_erro.sqlcode <> 0 then
                             error lr_erro.mens
                          end if
                      end if
                   else ### se for alteracao no laudo
                        call ctd31g00_upd_reserva
                                (lr_param.atdsrvnum,      # numero Servico
                                 lr_param.atdsrvano,      # Ano do Servico
                                 1,                       # Codigo status da Reserva
                                 lr_reserva.atzdianum,    # numero de diarias autorizadas
                                 lr_reserva.loccautip,    # Locacao isenta de caucao
                                 lr_reserva.vclretagncod, # Agencia da retirada do veiculo
                                 lr_reserva.vclrethordat, #
                                 lr_reserva.vclretufdcod, # Codigo UF de retirada do veiculo
                                 lr_reserva.vclretcidnom, # Nome Cidade de retirada do veiculo
                                 lr_reserva.vcldvlagncod, # Codigo Agencia da devolucao do veiculo
                                 lr_reserva.vcldvlhordat, # Data hora da devolucao do veiculo
                                 lr_reserva.vcldvlufdcod, # Codigo UF de devolucao do veiculo
                                 lr_reserva.vcldvlcidnom, # Nome Cidade de devolucao do veiculo
                                 d_cts15m15.smsenvdddnum, # DDD para envio de SMS
                                 d_cts15m15.smsenvcelnum, # Numero celular para envio de SMS
                                 lr_reserva.vclloccdrtxt, # Observações da locação
                                 lr_reserva.vclcdtsgnindtxt)
                        returning lr_erro.sqlcode,lr_erro.mens
                   end if
                end if
             end if
          end if
       end if
    #else
    #   error  lr_erro.mens
    end if
 else

       call ctd31g00_ins_reserva(lr_param.atdsrvnum,      # numero Servico
                           lr_param.atdsrvano,      # Ano do Servico
                           "",                      # Tipo de Envio de Confirmação
                           1,                       # Codigo status da Reserva
                           lr_reserva.atzdianum,    # numero de diarias autorizadas
                           lr_reserva.loccautip,    # Locacao isenta de caucao
                           lr_reserva.vclretagncod, # Agencia da retirada do veiculo
                           lr_reserva.vclrethordat, #
                           lr_reserva.vclretufdcod, # Codigo UF de retirada do veiculo
                           lr_reserva.vclretcidnom, # Nome Cidade de retirada do veiculo
                           lr_reserva.vcldvlagncod, # Codigo Agencia da devolucao do veiculo
                           lr_reserva.vcldvlhordat, # Data hora da devolucao do veiculo
                           lr_reserva.vcldvlufdcod, # Codigo UF de devolucao do veiculo
                           lr_reserva.vcldvlcidnom, # Nome Cidade de devolucao do veiculo
                           d_cts15m15.smsenvdddnum, # DDD para envio de SMS
                           d_cts15m15.smsenvcelnum, # Numero celular para envio de SMS
                           lr_reserva.envemades   , # Email para envio de confirmacao
                           lr_reserva.vclloccdrtxt, # Observações da locação
                           lr_reserva.vclcdtsgnindtxt,
                           g_documento.succod,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig,
                           lr_funapol.dctnumseq,
                           g_documento.ramcod,
                           g_documento.edsnumref,
                           g_documento.ciaempcod) # Nome do segundo condutor
            returning lr_erro.sqlcode,lr_erro.mens

         if lr_erro.sqlcode <> 0 then
            call errorlog(lr_erro.mens)
            let lr_erro.mens = "Erro <",lr_erro.sqlcode clipped,"> na função ctd31g00_ins_reserva, Avise a Informatica !"
            call errorlog(lr_erro.mens)
            error lr_erro.mens
         end if
  end if

  return lr_erro.sqlcode,lr_erro.mens

#==================================================
end function
#==================================================

function cts15m15_popup_garantia()

   define lr_popup record
         titulo  char(100),
         opcoes  char(1000)
  end record


  let lr_popup.titulo = 'Garantia'

    if d_cts15m15.avialgmtv = 11 or
       d_cts15m15.avialgmtv = 12 then
       let lr_popup.opcoes = "Cartao de Credito|Cheque Caucao|Isencao de Garantia"
    else
       let lr_popup.opcoes = "Cartao de Credito|Cheque Caucao"
    end if

  while true

     call ctx14g01(lr_popup.titulo,lr_popup.opcoes)
          returning m_opcao,d_cts15m15.garantia

     if m_opcao is not null and
        m_opcao <> 0 then
        exit while
     end if

  end while
  case m_opcao

    when 1

     let d_cts15m15.cauchqflg = "N"
     let d_cts15m15.flgarantia = "S"

    when 2
       let d_cts15m15.cauchqflg = "S"
       let d_cts15m15.flgarantia = "S"

    when 3
       let d_cts15m15.cauchqflg = "N"
       let d_cts15m15.flgarantia = "S"
   end case

end function

function cts15m15_dados_locacao()

   define lr_retorno record
         atdsrvnum        like datmrsvvcl.atdsrvnum    ,
         atdsrvano        like datmrsvvcl.atdsrvano    ,
         rsvlclcod        like datmrsvvcl.rsvlclcod    ,
         loccntcod        like datmrsvvcl.loccntcod    ,
         cnfenvcod        like datmrsvvcl.cnfenvcod    ,
         rsvsttcod        like datmrsvvcl.rsvsttcod    ,
         atzdianum        like datmrsvvcl.atzdianum    ,
         loccautip        like datmrsvvcl.loccautip    ,
         vclretagncod     like datmrsvvcl.vclretagncod ,
         vclrethordat     like datmrsvvcl.vclrethordat ,
         vclretufdcod     like datmrsvvcl.vclretufdcod ,
         vclretcidnom     like datmrsvvcl.vclretcidnom ,
         vcldvlagncod     like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat     like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod     like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom     like datmrsvvcl.vcldvlcidnom ,
         intsttcrides     like datmvclrsvitf.intsttcrides ,
         smsenvdddnum     like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum     like datmrsvvcl.smsenvcelnum ,
         envemades        like datmrsvvcl.envemades    ,
         vclloccdrtxt     like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt,
         apvhordat        like datmrsvvcl.apvhordat ,
         itfsttcod        like datmvclrsvitf.itfsttcod,
         itfgrvhordat     like datmvclrsvitf.itfgrvhordat,
         data             date   ,
         hora             datetime hour to second,
         status_reserva   char(15),
         mens1            char(50),
         mens2            char(50)
   end record

  define l_aux_data       char(30)
  define l_ano char(4)
  define l_mes char(2)
  define l_dia char(2)
  define l_hora char(8)

  define lr_erro record
         sqlcode smallint,
         mens    char(80)
  end record

  define prompt_key char (01)


  initialize lr_retorno.* to null
  initialize lr_erro.* to null






     call ctd31g00_sel_reserva_solic(1
                                    ,g_documento.atdsrvnum
                                    ,g_documento.atdsrvano)
     returning  lr_erro.sqlcode
               ,lr_erro.mens
               ,lr_retorno.atdsrvnum
               ,lr_retorno.atdsrvano
               ,lr_retorno.rsvlclcod
               ,lr_retorno.loccntcod
               ,lr_retorno.cnfenvcod
               ,lr_retorno.rsvsttcod
               ,lr_retorno.atzdianum
               ,lr_retorno.loccautip
               ,lr_retorno.vclretagncod
               ,lr_retorno.vclrethordat
               ,lr_retorno.vclretufdcod
               ,lr_retorno.vclretcidnom
               ,lr_retorno.vcldvlagncod
               ,lr_retorno.vcldvlhordat
               ,lr_retorno.vcldvlufdcod
               ,lr_retorno.vcldvlcidnom
               ,lr_retorno.smsenvdddnum
               ,lr_retorno.smsenvcelnum
               ,lr_retorno.envemades
               ,lr_retorno.vclloccdrtxt
               ,lr_retorno.vclcdtsgnindtxt
               ,lr_retorno.apvhordat
               ,lr_retorno.intsttcrides
               ,lr_retorno.itfsttcod
               ,lr_retorno.itfgrvhordat


     #case lr_retorno.rsvsttcod
     #
     #  when 1
     #     let lr_retorno.status_reserva = 'Aguardando'
     #  when 2
     #     let lr_retorno.status_reserva = 'Confirmada'
     #  when 3
     #     let lr_retorno.status_reserva = 'Cancelada'
     #  when 4
     #     let lr_retorno.status_reserva = 'Negada'
     #  when 5
     #     let lr_retorno.status_reserva = 'Utilizada'
     #  when 6
     #     let lr_retorno.status_reserva = 'Divergencia'
     #  when 7
     #     let lr_retorno.status_reserva = 'ErroInterface'
     #end case
     #
     #
     #display "lr_retorno.itfgrvhordat = ",lr_retorno.itfgrvhordat
     #let l_aux_data = lr_retorno.itfgrvhordat
     #let l_ano = l_aux_data[1,4]
     #let l_mes = l_aux_data[6,7]
     #let l_dia = l_aux_data[9,10]
     #let l_hora = l_aux_data[12,20]
     #
     #let l_aux_data = l_dia,"/",l_mes,"/",l_ano
     #
     #
     #let lr_retorno.data = l_aux_data
     #let lr_retorno.hora = l_hora
     #
     #let lr_retorno.mens1 = lr_retorno.vclloccdrtxt[1,50] clipped
     #let lr_retorno.mens2 = lr_retorno.vclloccdrtxt[51,100] clipped


   open window cts15m17 at 09,17 with form "cts15m17"
                 attribute (form line 1, border)

     display by name  #lr_retorno.loccntcod              # Contrato
                     lr_retorno.rsvlclcod              # Localizador
                     #,lr_retorno.status_reserva         # Status da Reserva
                     #,lr_retorno.data                   # Data de Confirmação
                     #,lr_retorno.hora                   # Hora de Confirmação
                     #,lr_retorno.smsenvdddnum           # DDD
                     #,lr_retorno.smsenvcelnum           # Celular
                     #,lr_retorno.mens1                  # Mensagem 1
                     #,lr_retorno.mens2                  # Mensagem 2

      while true

      prompt "(F17)Abandona" attribute(reverse) for prompt_key


       on key (interrupt)
       close window cts15m17
       exit while

      end prompt
  end while



end function

#============================================
function cts15m15_verifica_saldo()
#============================================

define lr_ctx01g01 record
       clscod     like abbmclaus.clscod,
       temcls     smallint
end record

define lr_retorno record
       avioccdat  like datmavisrent.avioccdat,
       avidiaqtd  smallint
end record

 define l_data      date,
        l_hora2     datetime hour to minute


initialize lr_ctx01g01.* to null
initialize lr_retorno.* to null


call cts44g01_claus_azul(g_documento.succod,
                              531,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig)
returning lr_ctx01g01.temcls,lr_ctx01g01.clscod


     call cts40g03_data_hora_banco(2)
          returning l_data, l_hora2
     let lr_retorno.avioccdat = l_data


     call ctx01g00_saldo_novo(g_documento.succod
                                ,g_documento.aplnumdig
                                ,g_documento.itmnumdig
                                ,''
                                ,''
                                ,lr_retorno.avioccdat
                                ,1,true
                                ,35
                                ,d_cts15m15.avialgmtv
                                ,d_cts15m15.c24astcod)
    returning g_lim_diaria, lr_retorno.avidiaqtd


if lr_retorno.avidiaqtd is null or
   lr_retorno.avidiaqtd = 0 then
     case lr_ctx01g01.clscod

        when '58A'
           let lr_retorno.avidiaqtd = 5
           #   'CLAUSULA 58B - FATURAR DIARIAS P/ AZUL '
           #                   ,'SEGUROS ATE O LIMITE 5 DIARIAS '
        when '58B'
           let lr_retorno.avidiaqtd = 10
        #   'CLAUSULA 58B - FATURAR DIARIAS P/ AZUL '
        #                   ,'SEGUROS ATE O LIMITE 10 DIARIAS '
        when '58C'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58C - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58D'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58D - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        when '58E'
           let lr_retorno.avidiaqtd =  5
           #'CLAUSULA 58E FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 05 DIARIAS '
        when '58F'
           let lr_retorno.avidiaqtd =  10
           #'CLAUSULA 58F - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 10 DIARIAS '
        when '58G'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58G - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58H'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58H - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        when '58I'
           let lr_retorno.avidiaqtd =  7
           #'CLAUSULA 58I - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 07 DIARIAS '
        when '58J'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58J - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58K'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58K - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        when '58L'
           let lr_retorno.avidiaqtd =  7
           #'CLAUSULA 58L - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 07 DIARIAS '
        when '58M'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58M - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58N'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58N - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        end case
end if

return lr_retorno.avidiaqtd

end function

function cts15m15_popup_motivos()

   define lr_retorno record
          coderro smallint
         ,mens    char(400)
   end record

   define l_motivos char(400)
         ,l_cabec   char(60)
         ,l_opcao   like datmavisrent.avialgmtv
         ,l_temcls  smallint
         ,l_clscod  like abbmclaus.clscod

   let l_motivos  = null
   let l_cabec    = "Motivos"
   let l_opcao    = null



    if d_cts15m15.c24astcod = "KA1" then
      if (( d_cts15m15.avialgmtv  is null ) or
          ( d_cts15m15.avialgmtv  <> 1      and
            d_cts15m15.avialgmtv  <> 3      and
            d_cts15m15.avialgmtv  <> 11     and
            d_cts15m15.avialgmtv  <> 12     and
            d_cts15m15.avialgmtv  <> 18 ))  then

                call cts44g01_claus_azul(mr_geral.succod,
                                      mr_geral.ramcod,
                                      mr_geral.aplnumdig,
                                      mr_geral.itmnumdig)
                returning l_temcls,l_clscod


               if l_temcls = false then
                  #let l_motivos = "3 - Beneficio P.Total|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Beneficio P.Parcial"
                  let l_motivos = "11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
               else
                  #let l_motivos = "1 - Sinistro|3 - Beneficio P.Total|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
                  let l_motivos = "1 - Clausula|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
               end if

                call cts15m15_clss(mr_geral.succod,
                                   mr_geral.ramcod,
                                   mr_geral.aplnumdig,
                                   mr_geral.itmnumdig,
                                   mr_geral.edsnumref,
                                   l_temcls,
                                   l_motivos)
		    returning l_motivos
       end if
    end if

    call ctx14g01_carro_extra(l_cabec, l_motivos)
         returning l_opcao

return l_opcao
end function

#--------------------------------------------------------------------
function cts15m15_ver_alt_laudo()
#--------------------------------------------------------------------
 define a_hist     array[24] of char(100),
        l_data     date,
        l_hora     datetime hour to minute,
        l_linha    integer,
        l_erro     integer
 initialize a_hist to null
 let l_data     = null
 let l_hora     = null
 let l_linha    = 0
 let l_erro     = null
  for l_linha = 1 to 24
    initialize a_hist[l_linha] to null
 end for
 if d_cts15m15.nom <> m_cts15ant.nom then
    let a_hist[1] = "Alterado Nome Segurado de ", m_cts15ant.nom clipped,
                                        " para ", d_cts15m15.nom clipped
 end if
 if d_cts15m15.corsus <> m_cts15ant.corsus then
    let a_hist[2] = "Alterado Codigo Corretor  de ", m_cts15ant.corsus clipped,
                                           " para ", d_cts15m15.corsus clipped
 end if
 if d_cts15m15.cornom <> m_cts15ant.cornom then
    let a_hist[3] = "Alterado Nome Corretor  de ", m_cts15ant.cornom clipped,
                                         " para ", d_cts15m15.cornom clipped
 end if
 if d_cts15m15.vclcoddig <> m_cts15ant.vclcoddig then
    let a_hist[4] = "Alterado Cod Veiculo  de ", m_cts15ant.vclcoddig clipped,
                                       " para ", d_cts15m15.vclcoddig clipped
 end if
 if d_cts15m15.vclanomdl <> m_cts15ant.vclanomdl then
    let a_hist[5] = "Alterado Mod Veiculo  de ", m_cts15ant.vclanomdl clipped,
                                       " para ", d_cts15m15.vclanomdl clipped
 end if
 if d_cts15m15.vcllicnum <> m_cts15ant.vcllicnum then
    let a_hist[6] = "Alterado Placa Veiculo  de ", m_cts15ant.vcllicnum clipped,
                                         " para ", d_cts15m15.vcllicnum clipped
 end if
 if d_cts15m15.avilocnom <> m_cts15ant.avilocnom then
    let a_hist[7] = "Alterado Nome Usuario  de ", m_cts15ant.avilocnom clipped,
                                        " para ", d_cts15m15.avilocnom clipped
 end if
 if d_cts15m15.cdtoutflg <> m_cts15ant.cdtoutflg then
    let a_hist[8] = "Alterado Outro Condutor de ", m_cts15ant.cdtoutflg clipped,
                                         " para ", d_cts15m15.cdtoutflg clipped
 end if
 if d_cts15m15.avialgmtv <> m_cts15ant.avialgmtv then
    let a_hist[9] = "Alterado Motivo de ", m_cts15ant.avialgmtv clipped,
                                 " para ", d_cts15m15.avialgmtv clipped
 end if
 if d_cts15m15.lcvsinavsflg <> m_cts15ant.lcvsinavsflg then
    let a_hist[10] = "Alterado Aviso Sinistro de ",
                               m_cts15ant.lcvsinavsflg clipped,
                     " para ", d_cts15m15.lcvsinavsflg clipped
 end if
 if d_cts15m15.lcvcod <> m_cts15ant.lcvcod then
    let a_hist[11] = "Alterado Cod Locadora de ",
                               m_cts15ant.lcvcod clipped,
                     " para ", d_cts15m15.lcvcod clipped
 end if
 if d_cts15m15.lcvextcod <> m_cts15ant.lcvextcod then
    let a_hist[12] = "Alterado Cod da Loja  de ",
                               m_cts15ant.lcvextcod clipped,
                     " para ", d_cts15m15.lcvextcod clipped
 end if
 if d_cts15m15.avivclcod <> m_cts15ant.avivclcod then
    let a_hist[13] = "Alterado Cod Veiculo de ",
                               m_cts15ant.avivclcod clipped,
                     " para ", d_cts15m15.avivclcod clipped
 end if
 if d_cts15m15.frmflg <> m_cts15ant.frmflg then
    let a_hist[14] = "Alterado Entrada Formulario de ",
                               m_cts15ant.frmflg clipped,
                     " para ", d_cts15m15.frmflg clipped
 end if
 if d_cts15m15.aviproflg <> m_cts15ant.aviproflg then
    let a_hist[15] = "Alterado Prorrogacao de ",
                               m_cts15ant.aviproflg clipped,
                     " para ", d_cts15m15.aviproflg clipped
 end if
 if d_cts15m15.cttdddcod <> m_cts15ant.cttdddcod then
    let a_hist[16] = "Alterado DDD fixo de ",
                               m_cts15ant.cttdddcod clipped,
                     " para ", d_cts15m15.cttdddcod clipped
 end if
 if d_cts15m15.ctttelnum <> m_cts15ant.ctttelnum then
    let a_hist[17] = "Alterado Tel fixo de ",
                               m_cts15ant.ctttelnum clipped,
                     " para ", d_cts15m15.ctttelnum clipped
 end if
 if d_cts15m15.atdlibflg <> m_cts15ant.atdlibflg then
    let a_hist[18] = "Alterado Serv. Liberado de ",
                               m_cts15ant.atdlibflg clipped,
                     " para ", d_cts15m15.atdlibflg clipped
 end if
 if d_cts15m15.locrspcpfnum <> m_cts15ant.locrspcpfnum then
    let a_hist[19] = "Alterado CPF de ",
                               m_cts15ant.locrspcpfnum clipped,
                     " para ", d_cts15m15.locrspcpfnum clipped
 end if
 if d_cts15m15.locrspcpfdig <> m_cts15ant.locrspcpfdig then
    let a_hist[20] = "Alterado Digito CPF de ",
                               m_cts15ant.locrspcpfdig clipped,
                     " para ", d_cts15m15.locrspcpfdig clipped
 end if
 if d_cts15m15.smsenvdddnum <> m_cts15ant.smsenvdddnum or
    (d_cts15m15.smsenvdddnum is not null and
     m_cts15ant.smsenvdddnum is null) then
    let a_hist[21] = "Alterado DDD Celular de ",
                               m_cts15ant.smsenvdddnum clipped,
                     " para ", d_cts15m15.smsenvdddnum clipped
 end if
 if d_cts15m15.smsenvcelnum <> m_cts15ant.smsenvcelnum or
    (d_cts15m15.smsenvcelnum is not null and
     m_cts15ant.smsenvcelnum is null) then
    let a_hist[22] = "Alterado Tel Celular de ",
                               m_cts15ant.smsenvcelnum clipped,
                     " para ", d_cts15m15.smsenvcelnum clipped
 end if
 #if d_cts15m15.garantia <> m_cts15ant.garantia then
 #   let a_hist[23] = "Alterado Garantia de ",
 #                              m_cts15ant.garantia clipped,
 #                    " para ", d_cts15m15.garantia clipped
 #end if
 if d_cts15m15.flgarantia <> m_cts15ant.flgarantia then
    let a_hist[24] = "Alterado Indicacao Garantia de ",
                               m_cts15ant.garantia clipped,'=',
                               m_cts15ant.flgarantia clipped,
                     " para ", d_cts15m15.garantia clipped,'=',
                               d_cts15m15.flgarantia clipped
 end if
 call cts40g03_data_hora_banco(2) returning l_data, l_hora
 for l_linha = 1 to 24
     if a_hist[l_linha] is not null then
        let m_flag_alt = true
        call cts10g02_historico(g_documento.atdsrvnum
                               ,g_documento.atdsrvano
                               ,l_data
                               ,l_hora
                               ,g_issk.funmat
                               ,a_hist[l_linha]
                               ,"" ,"" ,"" ,"")
             returning l_erro
     end if
 end for
end function
function cts15m15_verifica_data_retirada()
define l_retorno char(1)
define l_data      date,
       l_hora2     datetime hour to minute,
       l_aviretdat like datmavisrent.aviretdat,
       l_avirethor like datmavisrent.avirethor
let l_retorno = 'N'
let l_aviretdat = null
let l_avirethor = null
let l_data      = null
let l_hora2     = null
call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
whenever error continue
open ccts15m15041 using g_documento.atdsrvnum,
                       g_documento.atdsrvano
fetch ccts15m15041 into l_aviretdat,l_avirethor
whenever error stop
if sqlca.sqlcode <> 0 then
   error "Erro ao Buscar dados da reserva, Avise a Informatica !"
end if
if g_issk.funmat = 13020 then
   display "l_data      = ",l_data
   display "l_hora2     = ",l_hora2
   display "l_aviretdat = ",l_aviretdat
   display "l_avirethor = ",l_avirethor
end if
if l_data > l_aviretdat then
      let l_retorno = 'S'
      let m_prorrog = true
else
  if l_data = l_aviretdat then
     if l_hora2 > l_avirethor then
        let l_retorno = 'S'
        let m_prorrog = true
     end if
  end if
end if
if g_issk.funmat = 13020 then
   display "5130 m_prorrog = ",m_prorrog
   display "5130 l_retorno = ",l_retorno
end if
return l_retorno
end function
function cts15m15_clss(lr_param)
   define lr_param record
          succod     like datrservapol.succod,
          ramcod     like datrservapol.ramcod,
          aplnumdig  like datrservapol.aplnumdig,
          itmnumdig  like datrservapol.itmnumdig,
          edsnumref  integer,
          temcls     smallint,
          motivos    char(400)
          end record
   define l_flag       smallint,
	  l_motivos    char(400),
	  l_res        integer,
	  l_msg        char(20),
	  l_doc_handle integer,
	  l_viginc     date,
	  l_vigfnl     date
   call cts42g00_doc_handle(lr_param.succod,
			    lr_param.ramcod,
		            lr_param.aplnumdig,
			    lr_param.itmnumdig,
			    lr_param.edsnumref)
	returning l_res, l_msg, l_doc_handle
   call cts38m00_extrai_vigencia(l_doc_handle)
        returning l_viginc, l_vigfnl
   let l_motivos = lr_param.motivos
   if l_viginc >= '01/06/2012' then
      call cts44g00(lr_param.succod,
                    lr_param.ramcod,
                    lr_param.aplnumdig,
	            lr_param.itmnumdig,
                    "", #  mr_geral.edsnumref,
                    "37D")
            returning l_flag
      if l_flag = true then
         if lr_param.temcls = false then
              let l_motivos = "11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           else
              let l_motivos = "1 - Clausula|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           end if
      end if
      call cts44g00(lr_param.succod,
                    lr_param.ramcod,
                    lr_param.aplnumdig,
	            lr_param.itmnumdig,
                    "", #  mr_geral.edsnumref,
                    "37E")
            returning l_flag
      if l_flag = true then
         if lr_param.temcls = false then
              let l_motivos = "11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           else
              let l_motivos = "1 - Clausula|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           end if
      end if
      call cts44g00(lr_param.succod,
                    lr_param.ramcod,
                    lr_param.aplnumdig,
	            lr_param.itmnumdig,
                    "", #  mr_geral.edsnumref,
                    "37F")
            returning l_flag
      if l_flag = true then
         if lr_param.temcls = false then
              let l_motivos = "11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           else
              let l_motivos = "1 - Clausula|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           end if
      end if
      call cts44g00(lr_param.succod,
                    lr_param.ramcod,
                    lr_param.aplnumdig,
	            lr_param.itmnumdig,
                    "", #  mr_geral.edsnumref,
                    "37G")
            returning l_flag
      if l_flag = true then
         if lr_param.temcls = false then
              let l_motivos = "11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           else
              let l_motivos = "1 - Clausula|11 - Liberacao Sinistro|12 - Liberacao Comercial|18 - Regiao Sul"
           end if
      end if
   end if
   return l_motivos
end function

