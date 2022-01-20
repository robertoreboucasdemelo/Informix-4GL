#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts74m00                                                   #
#Analista Resp : Roberto Melo                                               #
#                Tela de Carro reserva PSS                                  #
#...........................................................................#
#Desenvolvimento: Roberto Melo                                              #
#Liberacao      : 03/11/2011                                                #
#---------------------------------------------------------------------------#
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
#Data       Autor Fabrica  Origem     Alteracao                             #
#07-03-2013 Jorge Modena  PSI-2013-04081 Criação de dois novos campos no ban#
#                                         co para salvar celular de reservas#
#                                         de locadoras que nao possuem inte-#
#                                         gracao automatica                 #
#                                                                           #
#---------------------------------------------------------------------------#
# 25/06/2014 Josiane Almeida CT-2014-14110/IN   Tirar a chamada da função   #
#                                              cty27g00_entrada_dados       #
#                                              da transação                 #
#############################################################################
globals "/homedsa/projetos/geral/globals/figrc072.4gl"  --> 223689
globals "/homedsa/projetos/geral/globals/glct.4gl"
# globals "glct.4gl"

define d_cts74m00    record
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
    flgarantia        char(1)
 end record

 define w_cts74m00    record
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

 define m_cts74m00_prep smallint
 define m_envio    smallint
 define m_erro     smallint
 define m_cidnom   like datmlcl.cidnom
 define m_ufdcod   like datmlcl.ufdcod



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
    dpssitatu         dec (04,00)                  ,
    psscntcod         like kspmcntrsm.psscntcod
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
        itaciacod    like datrligitaaplitm.itaciacod,
        psscntcod    like kspmcntrsm.psscntcod
 end record

  define hist_cts74m00 record
         hist1  like datmservhist.c24srvdsc ,
         hist2  like datmservhist.c24srvdsc ,
         hist3  like datmservhist.c24srvdsc ,
         hist4  like datmservhist.c24srvdsc ,
         hist5  like datmservhist.c24srvdsc
  end record

  define am_motivos array[10] of record
          itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
          itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
          dialimqtd         like datkitarsrcaomtv.dialimqtd
  end record

  define d_pss record
     sindat            like datmavisrent.sindat,
     prcnum            like datmavisrent.prcnum,
     prccnddes         like datmavisrent.prccnddes,
     itaofinom         like datmavisrent.itaofinom
  end record

  define m_opcao    smallint
  define m_reenvio  smallint
  define m_qtde_motivos integer


#-------------------------#
function cts74m00_prepara()
#-------------------------#

   define l_sqlstmt  char(700)

   let l_sqlstmt = ' select cpodes ',
                   '   from iddkdominio ',
                   '  where cponom = "avialgmtv" ',
                   '    and cpocod = ? '

   prepare p_cts74m00_001 from l_sqlstmt
   declare c_cts74m00_001 cursor for p_cts74m00_001

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
   prepare p_cts74m00_002 from l_sqlstmt
   declare c_cts74m00_002 cursor
       for p_cts74m00_002

   let l_sqlstmt = 'select lcvcod      , avivclcod    , avivclvlr ,   '
                        ,' aviestcod   , avialgmtv    , avilocnom ,   '
                        ,' aviretdat   , avirethor    , aviprvent ,   '
                        ,' locsegvlr   , vclloctip    , avioccdat ,   '
                        ,' ofnnom      , dddcod       , telnum    ,   '
                        ,' cttdddcod   , ctttelnum    , avirsrgrttip, '
                        ,' slcemp      , slcsuccod    , slcmat      , '
                        ,' slccctcod   , cdtoutflg    , locrspcpfnum, '
                        ,' locrspcpfdig, lcvsinavsflg , sindat      , '
                        ,' prcnum      , prccnddes    ,itaofinom      '
                   ,' from datmavisrent '
                   ,' where atdsrvnum = ? '
                     ,' and atdsrvano = ? '

   prepare p_cts74m00_003 from l_sqlstmt
   declare c_cts74m00_003 cursor for p_cts74m00_003

   let l_sqlstmt = 'update datmavisrent set (lcvcod   , avivclcod, aviestcod   , '
                                          ,' avivclvlr, locsegvlr, avialgmtv   , '
                                          ,' avidiaqtd, avilocnom, aviretdat   , '
                                          ,' avirethor, aviprvent, avioccdat   , '
                                          ,' ofnnom   , dddcod   , telnum      , '
                                          ,' cttdddcod, ctttelnum, avirsrgrttip, '
                                          ,' slcemp   , slcsuccod, slcmat      , '
                                          ,' slccctcod, cdtoutflg, vclloctip   , '
                                          ,' locrspcpfnum, locrspcpfdig, lcvsinavsflg, '
                                          ,' smsenvdddnum, smsenvcelnum) '
                                       ,' = (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '
                                          ,' ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
                  ,' where atdsrvnum = ? '
                    ,' and atdsrvano = ? '

   prepare p_cts74m00_004 from l_sqlstmt

   let l_sqlstmt = 'insert into datmavisrent (atdsrvnum, atdsrvano, lcvcod   , avivclcod, aviestcod, '
                                           ,' avivclvlr, avialgmtv, avidiaqtd, avilocnom, aviretdat, '
                                           ,' avirethor, aviprvent, locsegvlr, vclloctip, avioccdat, '
                                           ,' ofnnom   , dddcod   , telnum   , cttdddcod, ctttelnum, '
                                           ,' avirsrgrttip, slcemp, slcsuccod, slcmat, slccctcod, '
                                           ,' cdtoutflg, locrspcpfnum, locrspcpfdig, lcvsinavsflg, '
                                           ,' sindat, prcnum, prccnddes, itaofinom, locetpcod, '
                                           ,' smsenvdddnum, smsenvcelnum )'
                                           ,' values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '
                                           ,' ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ? )'

   prepare p_cts74m00_005 from l_sqlstmt
   let l_sqlstmt = ' select cpodes ',
                   '   from datkdominio ',
                   '  where cponom = "avialgmtv_azul" ',
                   '    and cpocod = ? '

   prepare pcts74m00008 from l_sqlstmt
   declare ccts74m00008 cursor for pcts74m00008


   let l_sqlstmt = ' select count(*) ',
                   '   from datmavisrent',
                   ' where avialgmtv in ("011","012") ',
                   ' and atdsrvnum = ? ',
                   ' and atdsrvano = ? '

   prepare pcts74m00009 from l_sqlstmt
   declare ccts74m00009 cursor for pcts74m00009

   let l_sqlstmt = 'select lcvextcod,endufd,endcid ',
                   ' from datkavislocal ',
                   ' where ',
                   ' lcvcod    = ?   and ',
                   ' aviestcod = ? '

   prepare pcts74m00034 from l_sqlstmt
   declare ccts74m00034 cursor for pcts74m00034

   let l_sqlstmt = 'select lcvcod,aviestcod,aviretdat'
                   ,' , avirethor,aviprvent,avirsrgrttip, cdtoutflg,avialgmtv '
                   ,' from datmavisrent '
                   ,' where atdsrvnum = ? '
                   ,' and atdsrvano = ? '

   prepare pcts74m00035 from l_sqlstmt
   declare ccts74m00035 cursor for pcts74m00035

   let l_sqlstmt = 'select smsenvdddnum,smsenvcelnum ',
                   ' from datmrsvvcl ',
                   ' where ',
                   ' atdsrvnum = ? ',
                   ' and atdsrvano = ? '

   prepare pcts74m00036 from l_sqlstmt
   declare ccts74m00036 cursor for pcts74m00036

   let l_sqlstmt = 'insert into datrvcllocrsrcmp (atdsrvnum, atdsrvano,itarsrcaomtvcod, '
                                                 ,' rsrprvdiaqtd, rsrutidiaqtd, rsrdialimqtd,locprgflg) '
                                                 ,' values (?, ?, ?, ?, ?, ?,"N")'

   prepare p_cts74m00_037 from l_sqlstmt


   let l_sqlstmt = "select sindat,prcnum,prccnddes,itaofinom ",
                   " from datmavisrent ",
                   " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

   prepare p_cts74m00_038 from l_sqlstmt
   declare c_cts74m00_038 cursor for p_cts74m00_038

   let l_sqlstmt = "select itarsrcaomtvcod,rsrprvdiaqtd,rsrutidiaqtd",
                   " from datrvcllocrsrcmp ",
                   " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

   prepare p_cts74m00_039 from l_sqlstmt
   declare c_cts74m00_039 cursor for p_cts74m00_039


   let l_sqlstmt = "select itarsrcaomtvdes",
                   " from datkitarsrcaomtv ",
                   " where itarsrcaomtvcod = ? "

   prepare p_cts74m00_040 from l_sqlstmt
   declare c_cts74m00_040 cursor for p_cts74m00_040


   let l_sqlstmt = "  select avialgmtv     "
                  ,"    from datmavisrent  "
                  ,"   where atdsrvnum = ? "
                  ,"     and atdsrvano = ? "
   prepare p_cts74m00_041 from l_sqlstmt
   declare c_cts74m00_041 cursor for p_cts74m00_041


   let l_sqlstmt = "  delete datrvcllocrsrcmp   ",
                   "   where atdsrvnum = ?      ",
                   "     and atdsrvano = ?      "
   prepare p_cts74m00_042 from l_sqlstmt

    let l_sqlstmt = 'select smsenvdddnum,smsenvcelnum ',
                   ' from datmavisrent ',
                   ' where ',
                   ' atdsrvnum = ? ',
                   ' and atdsrvano = ? '

   prepare p_cts74m00_042A from l_sqlstmt
   declare c_cts74m00_042A cursor for p_cts74m00_042A

let l_sqlstmt =  "select orgnum, prpnum, pgtfrmcod     "
                ,"from datmpgtinf                      "
                ,"where atdsrvnum = ?                  "
                ,"and atdsrvano = ?                    "

 prepare p_cts74m00_043 from l_sqlstmt
 declare c_cts74m00_043 cursor for p_cts74m00_043

 let l_sqlstmt =  "select clinom, crtnum, bndcod,      "
                 ,"crtvlddat, cbrparqtd                "
                 ,"from datmcrdcrtinf                  "
                 ,"where orgnum = ?                    "
                 ,"and prpnum = ?                      "
                 ,"and pgtseqnum = (select             "
                 ,"max(pgtseqnum) from                 "
                 ,"datmcrdcrtinf a                     "
                 ,"where a.orgnum = ?                  "
                 ,"and prpnum = ?)                     "

 prepare p_cts74m00_044 from l_sqlstmt
 declare c_cts74m00_044 cursor for p_cts74m00_044

 let l_sqlstmt =  "select pgtfrmdes      "
                 ,"from datkpgtfrm       "
                 ,"where pgtfrmcod = ?   "

 prepare p_cts74m00_045 from l_sqlstmt
 declare c_cts74m00_045 cursor for p_cts74m00_045

 #let l_sqlstmt =  "select bnddes         "
 #                ,"from datkcrtbnd       "
 #                ,"where bndcod = ?      "

 let l_sqlstmt =  "select carbndnom       "
                 ,"from   fcokcarbnd      "
                 ,"where  carbndcod = ?   "

 prepare p_cts74m00_046 from l_sqlstmt
 declare c_cts74m00_046 cursor for p_cts74m00_046

   let m_cts74m00_prep = true

end function  #fim psi175552

#------------------------------#
 function cts74m00()
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
        lclocodesres char(01),
        psscntcod    like kspmcntrsm.psscntcod
 end record

 define ws            record
    hoje              char (10),
    vclcordes         char (12),
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    confirma          char (01),
    grvflg            smallint
 end record

 define l_resultado  smallint,
        l_mensagem   char(80),
        l_msg_opcoes char(80)


 define w_ctgtrfcod   like abbmcasco. ctgtrfcod
       ,w_histerr     smallint
       ,w_c24srvdsc   like datmservhist.c24srvdsc

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_anomod char(4)

 define lr_email record
     succod          like datrligapol.succod       # Codigo Sucursal
   ,aplnumdig       like datrligapol.aplnumdig    # Numero Apolice
   ,itmnumdig       like datrligapol.itmnumdig    # Numero do Item
   ,prporg          like datrligprp.prporg        # Origem da Proposta
   ,prpnumdig       like datrligprp.prpnumdig     # Numero da Proposta
   ,solnom          char (15)                     # Solicitante
   ,ramcod          like datrservapol.ramcod      # Codigo Ramo
   ,lignum          like datmligacao.lignum       # Numero da Ligacao
   ,c24astcod       like datkassunto.c24astcod    # Assunto da Ligacao
   ,ligcvntip       like datmligacao.ligcvntip    # Convenio Operacional
   ,atdsrvnum       like datmservico.atdsrvnum    # Numero do Servico
   ,atdsrvano       like datmservico.atdsrvano    # Ano do Servico
 end record

 define l_envio smallint

 let l_resultado  = null
 let l_mensagem   = null
 let l_msg_opcoes = null



 initialize  ws.*           to null
 initialize  slv_segurado.* to null
 initialize  slv_terceiro.* to null
 initialize  mr_geral.*     to null
 initialize  d_cts74m00.*   to null
 initialize  w_cts74m00.*   to null
 initialize  lr_email.*     to null

let  lr_parametro.atdsrvnum    = g_documento.atdsrvnum
let  lr_parametro.atdsrvano    = g_documento.atdsrvano
let  lr_parametro.ligcvntip    = g_documento.ligcvntip
let  lr_parametro.succod       = g_documento.succod
let  lr_parametro.ramcod       = g_documento.ramcod
let  lr_parametro.aplnumdig    = g_documento.aplnumdig
let  lr_parametro.itmnumdig    = g_documento.itmnumdig
let  lr_parametro.acao         = g_documento.acao
let  lr_parametro.prporg       = g_documento.prporg
let  lr_parametro.prpnumdig    = g_documento.prpnumdig
let  lr_parametro.c24astcod    = g_documento.c24astcod
let  lr_parametro.solnom       = g_documento.solnom
let  lr_parametro.atdsrvorg    = g_documento.atdsrvorg
let  lr_parametro.edsnumref    = g_documento.edsnumref
let  lr_parametro.fcapacorg    = g_documento.fcapacorg
let  lr_parametro.fcapacnum    = g_documento.fcapacnum
let  lr_parametro.lignum       = g_documento.lignum
let  lr_parametro.soltip       = g_documento.soltip
let  lr_parametro.c24soltipcod = g_documento.c24soltipcod
let  lr_parametro.lclocodesres = g_documento.lclocodesres
let  lr_parametro.psscntcod    = g_pss.psscntcod


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
 let mr_geral.psscntcod    = lr_parametro.psscntcod
 let m_reenvio             = false

 let int_flag   = false

 if m_cts74m00_prep is null or
    m_cts74m00_prep <> true then
    call cts74m00_prepara()
 end if

 open window w_cts74m00 at 04,02 with form "cts74m00"
    attribute(form line 1)

 display "PSS AUTO" to msg_pss attribute(reverse)

    let l_msg_opcoes =
    "(F1)Help(F3)Dep/Fun(F4)Func(F5)FPgt(F6)Hist(F7)Fax(F8)Ret(F9)Conc(Ctrl+e)Email"

 display l_msg_opcoes to msg_opcoes

  call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
 let ws.hoje           = l_data
 let w_cts74m00.ano    = ws.hoje[9,10]
 let w_cts74m00.atddat = l_data
 let w_cts74m00.atdhor = l_hora2
 let g_documento.atdsrvorg = 8


 let d_cts74m00.frmflg = "N"

 let d_cts74m00.c24astcod = mr_geral.c24astcod

  if mr_geral.atdsrvnum is not null then

     if g_documento.acao = "CAN" then
        let m_reenvio = true
     end if

     call cts74m00_consulta()

     if m_erro then
        let int_flag = false
        error "Erro ao chamar a funcao cts74m00_consulta()" sleep 2
        close window w_cts74m00
        return
     end if

     display by name d_cts74m00. servico    ,
                    d_cts74m00.c24solnom   ,
                    d_cts74m00.nom         ,
                    d_cts74m00.doctxt      ,
                    d_cts74m00.corsus      ,
                    d_cts74m00.cornom      ,
                    d_cts74m00.vclcoddig   ,
                    d_cts74m00.vcldes      ,
                    d_cts74m00.vclanomdl   ,
                    d_cts74m00.vcllicnum   ,
                    d_cts74m00.vclloctip   ,
                    d_cts74m00.vcllocdes   ,
                    d_cts74m00.c24astcod   ,
                    d_cts74m00.c24astdes   ,
                    d_cts74m00.avilocnom   ,
                    d_cts74m00.avialgmtv   ,
                    d_cts74m00.avimtvdes   ,
                    d_cts74m00.lcvcod      ,
                    d_cts74m00.lcvnom      ,
                    d_cts74m00.lcvextcod   ,
                    d_cts74m00.aviestnom   ,
                    d_cts74m00.cdtoutflg   ,
                    d_cts74m00.cdtsegtaxvlr,
                    d_cts74m00.avivclcod   ,
                    d_cts74m00.avivclgrp   ,
                    d_cts74m00.avivcldes   ,
                    d_cts74m00.vcldiavlr   ,
                    d_cts74m00.frqvlr      ,
                    d_cts74m00.isnvlr      ,
                    d_cts74m00.rduvlr      ,
                    d_cts74m00.cndtxt      ,
                    d_cts74m00.prgtxt      ,
                    d_cts74m00.frmflg      ,
                    d_cts74m00.aviproflg   ,
                    d_cts74m00.cttdddcod   ,
                    d_cts74m00.ctttelnum   ,
                    d_cts74m00.atdlibflg   ,
                    d_cts74m00.atdlibtxt   ,
                    d_cts74m00.locrspcpfnum,
                    d_cts74m00.locrspcpfdig,
                    d_cts74m00.smsenvdddnum,
                    d_cts74m00.smsenvcelnum,
                    d_cts74m00.garantia,
                    d_cts74m00.flgarantia


    display by name d_cts74m00.c24solnom attribute (reverse)

    if d_cts74m00.prgtxt is not null  then
       display by name d_cts74m00.prgtxt  attribute (reverse)
    end if

    if w_cts74m00.atdfnlflg = "S"  then
       error " ATENCAO! Servico ja' acionado!"
    end if



    call cts74m00_modifica() returning ws.grvflg

    if ws.grvflg = false  then
       initialize mr_geral.acao to null
       close window w_cts74m00
       let int_flag = false
       return
    end if

  end if

     if g_pss.psscntcod    is not null  then
        let d_cts74m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
     end if

     let   d_cts74m00.garantia = 'Garantia:'

    display by name d_cts74m00. servico
                    ,d_cts74m00.c24solnom
                    ,d_cts74m00.nom
                    ,d_cts74m00.doctxt
                    ,d_cts74m00.corsus
                    ,d_cts74m00.cornom
                    ,d_cts74m00.vclcoddig
                    ,d_cts74m00.vcldes
                    ,d_cts74m00.vclanomdl
                    ,d_cts74m00.vcllicnum
                    ,d_cts74m00.vclloctip
                    ,d_cts74m00.vcllocdes
                    ,d_cts74m00.c24astcod
                    ,d_cts74m00.c24astdes
                    ,d_cts74m00.avilocnom
                    ,d_cts74m00.avialgmtv
                    ,d_cts74m00.avimtvdes
                    ,d_cts74m00.lcvcod
                    ,d_cts74m00.lcvnom
                    ,d_cts74m00.lcvextcod
                    ,d_cts74m00.aviestnom
                    ,d_cts74m00.cdtoutflg
                    ,d_cts74m00.cdtsegtaxvlr
                    ,d_cts74m00.avivclcod
                    ,d_cts74m00.avivclgrp
                    ,d_cts74m00.avivcldes
                    ,d_cts74m00.vcldiavlr
                    ,d_cts74m00.frqvlr
                    ,d_cts74m00.isnvlr
                    ,d_cts74m00.rduvlr
                    ,d_cts74m00.cndtxt
                    ,d_cts74m00.prgtxt
                    ,d_cts74m00.frmflg
                    ,d_cts74m00.aviproflg
                    ,d_cts74m00.cttdddcod
                    ,d_cts74m00.ctttelnum
                    ,d_cts74m00.atdlibflg
                    ,d_cts74m00.atdlibtxt
                    ,d_cts74m00.locrspcpfnum
                    ,d_cts74m00.locrspcpfdig
                    ,d_cts74m00.smsenvdddnum
                    ,d_cts74m00.smsenvcelnum
                    ,d_cts74m00.garantia
                    ,d_cts74m00.flgarantia

    display by name d_cts74m00.c24solnom attribute (reverse)

    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2


    if mr_geral.acao is not null and
       mr_geral.acao <> 'SIN' and
       mr_geral.atdsrvnum is not null then
       call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                     g_issk.funmat, l_data, l_hora2)
       let g_rec_his = true
    end if

    if mr_geral.atdsrvnum is not null and
       d_cts74m00.lcvcod     is not null and
       d_cts74m00.aviestcod  is not null and
       d_cts74m00.atdlibflg  <> "N"      then

       call cts15m01(mr_geral.atdsrvnum
                    ,mr_geral.atdsrvano
                    ,d_cts74m00.lcvcod
                    ,d_cts74m00.aviestcod
                    ,d_cts74m00.avialgmtv)
    end if


    if g_pss.psscntcod    is not null  then
       let d_cts74m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
    end if

    let d_cts74m00.c24astcod   = mr_geral.c24astcod
    let d_cts74m00.c24solnom   = mr_geral.solnom

    call c24geral8(d_cts74m00.c24astcod) returning d_cts74m00.c24astdes

    display by name d_cts74m00. servico    ,
                    d_cts74m00.c24solnom   ,
                    d_cts74m00.nom         ,
                    d_cts74m00.doctxt      ,
                    d_cts74m00.corsus      ,
                    d_cts74m00.cornom      ,
                    d_cts74m00.vclcoddig   ,
                    d_cts74m00.vcldes      ,
                    d_cts74m00.vclanomdl   ,
                    d_cts74m00.vcllicnum   ,
                    d_cts74m00.vclloctip   ,
                    d_cts74m00.vcllocdes   ,
                    d_cts74m00.c24astcod   ,
                    d_cts74m00.c24astdes   ,
                    d_cts74m00.avilocnom   ,
                    d_cts74m00.avialgmtv   ,
                    d_cts74m00.avimtvdes   ,
                    d_cts74m00.lcvcod      ,
                    d_cts74m00.lcvnom      ,
                    d_cts74m00.lcvextcod   ,
                    d_cts74m00.aviestnom   ,
                    d_cts74m00.cdtoutflg   ,
                    d_cts74m00.cdtsegtaxvlr,
                    d_cts74m00.avivclcod   ,
                    d_cts74m00.avivclgrp   ,
                    d_cts74m00.avivcldes   ,
                    d_cts74m00.vcldiavlr   ,
                    d_cts74m00.frqvlr      ,
                    d_cts74m00.isnvlr      ,
                    d_cts74m00.rduvlr      ,
                    d_cts74m00.cndtxt      ,
                    d_cts74m00.prgtxt      ,
                    d_cts74m00.frmflg      ,
                    d_cts74m00.aviproflg   ,
                    d_cts74m00.cttdddcod   ,
                    d_cts74m00.ctttelnum   ,
                    d_cts74m00.atdlibflg   ,
                    d_cts74m00.atdlibtxt   ,
                    d_cts74m00.locrspcpfnum,
                    d_cts74m00.locrspcpfdig,
                    d_cts74m00.smsenvdddnum,
                    d_cts74m00.smsenvcelnum,
                    d_cts74m00.garantia,
                    d_cts74m00.flgarantia



    display by name d_cts74m00.c24solnom attribute (reverse)

    let ws.grvflg = cts74m00_inclui()

    if ws.grvflg = true  then
       call cts10n00(w_cts74m00.atdsrvnum, w_cts74m00.atdsrvano,
                     w_cts74m00.funmat   , w_cts74m00.atddat   ,
                     w_cts74m00.atdhor)

       call cts74m00_acionamento(w_cts74m00.atdsrvnum, w_cts74m00.atdsrvano
                                ,d_cts74m00.lcvcod, d_cts74m00.aviestcod,0,'')

       #-----------------------------------------------
       # Desbloqueio do servico
       #-----------------------------------------------
       if w_cts74m00.atdfnlflg = "N"  then
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts74m00.atdsrvnum
                             and atdsrvano = w_cts74m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts74m00.atdsrvnum,w_cts74m00.atdsrvano)
          end if
       end if
    end if

 close window w_cts74m00
 let int_flag = false

end function

#--------------------------------------------------------------------
 function cts74m00_consulta()
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
   into d_cts74m00.nom      ,
        d_cts74m00.vclcoddig, d_cts74m00.vcldes   ,
        d_cts74m00.vclanomdl, d_cts74m00.vcllicnum,
        d_cts74m00.corsus   , d_cts74m00.cornom   ,
        w_cts74m00.funmat   , w_cts74m00.empcod   ,
        ws.atddat           , ws.atdhor           ,
        w_cts74m00.atdfnlflg, d_cts74m00.atdlibflg,
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

 open c_cts74m00_003 using mr_geral.atdsrvnum
                          ,mr_geral.atdsrvano

 whenever error continue
 fetch c_cts74m00_003 into d_cts74m00.lcvcod      , d_cts74m00.avivclcod, d_cts74m00.avivclvlr
                        ,d_cts74m00.aviestcod   , d_cts74m00.avialgmtv, d_cts74m00.avilocnom
                        ,w_cts74m00.aviretdat   , w_cts74m00.avirethor, w_cts74m00.aviprvent
                        ,d_cts74m00.locsegvlr   , d_cts74m00.vclloctip, w_cts74m00.avioccdat
                        ,w_cts74m00.ofnnom      , w_cts74m00.ofndddcod, w_cts74m00.ofntelnum
                        ,d_cts74m00.cttdddcod   , d_cts74m00.ctttelnum, ws_avirsrgrttip
                        ,w_cts74m00.slcemp      , w_cts74m00.slcsuccod, w_cts74m00.slcmat
                        ,w_cts74m00.slccctcod   , d_cts74m00.cdtoutflg, d_cts74m00.locrspcpfnum
                        ,d_cts74m00.locrspcpfdig, d_cts74m00.lcvsinavsflg,d_pss.sindat
                        ,d_pss.prcnum,d_pss.prccnddes,d_pss.itaofinom
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
    else
       error 'Erro SELECT c_cts74m00_003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'cts74m00 / cts74m00_consulta() / ',mr_geral.atdsrvnum,' / '
                                                ,mr_geral.atdsrvano sleep 1
    end if
    let m_erro = true
    return
 end if

 if d_cts74m00.cdtoutflg is null then
    let d_cts74m00.cdtoutflg = "N"
 end if

 let m_opcao = ws_avirsrgrttip
 case ws_avirsrgrttip

       when 1

        let d_cts74m00.cauchqflg = "N"
        let d_cts74m00.garantia = 'Cartao de Credito'
        let d_cts74m00.flgarantia = "S"

       when 2
          let d_cts74m00.cauchqflg = "S"
          let d_cts74m00.flgarantia = "S"
          let d_cts74m00.garantia = 'Cheque Caucao'

       when 3
          let d_cts74m00.cauchqflg = "N"
          let d_cts74m00.flgarantia = "S"
          let d_cts74m00.garantia = 'Isencao de Garantia'
end case

whenever error continue

open c_cts74m00_040 using d_cts74m00.avialgmtv
fetch c_cts74m00_040 into d_cts74m00.avimtvdes

whenever error stop








 case d_cts74m00.vclloctip
    when 1    let d_cts74m00.vcllocdes = "SEGURADO"
    when 2    let d_cts74m00.vcllocdes = "CORRETOR"
    when 3    let d_cts74m00.vcllocdes = "DEPTOS. "
    when 4    let d_cts74m00.vcllocdes = "FUNC.   "
    otherwise let d_cts74m00.vcllocdes = "NAO PREV"
 end case

 if d_cts74m00.locsegvlr  is null    then
    let d_cts74m00.locsegvlr = 0.00
 end if
 let d_cts74m00.vcldiavlr = d_cts74m00.avivclvlr + d_cts74m00.locsegvlr

#--------------------------------------------------------------------
# Veiculo / Loja
#--------------------------------------------------------------------

 initialize ws.avivclmdl, ws.avivcldes  to null

 select avivclmdl, avivcldes, avivclgrp,
        frqvlr, isnvlr, rduvlr                  #PSI 198390
   into ws.avivclmdl,
        ws.avivcldes,
        d_cts74m00.avivclgrp,
        d_cts74m00.frqvlr,                      #PSI 198390
        d_cts74m00.isnvlr,                      #PSI 198390
        d_cts74m00.rduvlr                       #PSI 198390
   from datkavisveic
  where lcvcod    = d_cts74m00.lcvcod     and
        avivclcod = d_cts74m00.avivclcod

 if sqlca.sqlcode = NOTFOUND   then
    let d_cts74m00.avivcldes = "VEICULO/DISCRIMINACAO NAO ENCONTRADOS"
 else
    if ws.avivcldes is not null  then
       let ws.avivcldes = "(", ws.avivcldes clipped, ")"
    end if
    let d_cts74m00.avivcldes = ws.avivclmdl clipped, " ",
                               ws.avivcldes clipped
 end if

 select lcvnom, cdtsegtaxvlr
   into d_cts74m00.lcvnom, d_cts74m00.cdtsegtaxvlr
   from datklocadora
  where lcvcod = d_cts74m00.lcvcod

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
 if d_cts74m00.cdtoutflg = 'N' then
    let d_cts74m00.cdtsegtaxvlr = null
 end if

 select lcvextcod, aviestnom
   into d_cts74m00.lcvextcod,
        d_cts74m00.aviestnom
   from datkavislocal
  where lcvcod    = d_cts74m00.lcvcod    and
        aviestcod = d_cts74m00.aviestcod

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

 let w_cts74m00.lignum = cts20g00_servico(mr_geral.atdsrvnum, mr_geral.atdsrvano)

 call cts20g01_docto(w_cts74m00.lignum)
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

 call cts20g01_docto_tot(w_cts74m00.lignum)
      returning g_documento.ligcvntip,
                g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum,
                g_documento.bnfnum,
                g_documento.crtsaunum,
                g_ppt.cmnnumdig,
                g_documento.corsus,
                g_documento.dddcod,
                g_documento.ctttel,
                g_documento.funmat,
                g_documento.cgccpfnum,
                g_documento.cgcord,
                g_documento.cgccpfdig,
                g_crtdvgflg,
                g_pss.ligdcttip,
                g_pss.ligdctnum,
                g_pss.dctitm,
                g_pss.psscntcod,
                g_cgccpf.ligdcttip,
                g_cgccpf.ligdctnum,
                g_documento.itaciacod


 if g_pss.psscntcod    is not null  then

    let d_cts74m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"

 end if



 select c24astcod, ligcvntip,
        c24solnom
   into d_cts74m00.c24astcod,
        ws.ligcvntip        ,
        d_cts74m00.c24solnom
   from datmligacao
  where lignum = w_cts74m00.lignum

 #let mr_geral.ligcvntip = ws.ligcvntip

 select lignum
   from datmligfrm
  where lignum = w_cts74m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts74m00.frmflg = "N"
 else
    let d_cts74m00.frmflg = "S"
 end if

 let d_cts74m00.c24astdes = c24geral8(d_cts74m00.c24astcod)

 let d_cts74m00.servico = F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                     "/", F_FUNDIGIT_INTTOSTR(mr_geral.atdsrvnum,7),
                     "-", F_FUNDIGIT_INTTOSTR(mr_geral.atdsrvano,2)

#--------------------------------------------------------------------
# Verifica existencia de prorrogacoes
#--------------------------------------------------------------------
 declare c_cts74m00_004 cursor for
    select atdsrvnum, atdsrvano
      from datmprorrog
     where atdsrvnum = mr_geral.atdsrvnum  and
           atdsrvano = mr_geral.atdsrvano

 open  c_cts74m00_004
 fetch c_cts74m00_004

 if sqlca.sqlcode = 0   then
    let d_cts74m00.prgtxt    = "PRORROGACAO"
    let d_cts74m00.aviproflg = "S"
 else
    initialize d_cts74m00.prgtxt to null
    let d_cts74m00.aviproflg = "N"
 end if
 close c_cts74m00_004

 let ws.funnom = "*** NAO CADASTRADO! ***"
 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = w_cts74m00.empcod
    and funmat = w_cts74m00.funmat

 let d_cts74m00.atdlibtxt = ws.atddat                         clipped, " " ,
                            ws.atdhor                         clipped, " " ,
                            upshift(ws.dptsgl)                clipped, " " ,
                            w_cts74m00.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)                clipped, "  ",
                            ws.atdlibdat                      clipped, "  ",
                            ws.atdlibhor

 let w_cts74m00.datasaldo = w_cts74m00.atddat


 display by name d_cts74m00.avimtvdes


 let w_cts74m00.avidiaqtd = 0

 #==============================================================
 # Carrega celular da reserva
 #==============================================================
 if d_cts74m00.lcvcod == 2 then
	 if g_documento.atdsrvnum is not null then
	    whenever error stop
	    open ccts74m00036 using g_documento.atdsrvnum,g_documento.atdsrvano
	    fetch ccts74m00036 into d_cts74m00.smsenvdddnum,
	                            d_cts74m00.smsenvcelnum
	    whenever error continue
	 end if
 else
        if g_documento.atdsrvnum is not null then
            whenever error stop
	    open c_cts74m00_042A using g_documento.atdsrvnum,g_documento.atdsrvano
	    fetch c_cts74m00_042A into d_cts74m00.smsenvdddnum,
	                            d_cts74m00.smsenvcelnum
            whenever error continue
        end if
 end if

end function  ###  cts74m00_consulta

#--------------------------------------------------------------------
 function cts74m00_modifica()
#--------------------------------------------------------------------

 define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                   ,
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

 define prompt_key       char (01)
 define ws_avirsrgrttip  dec (1,0)
 define ws_avialgmtv     like datmavisrent.avialgmtv
 define ws_sqlcode       integer
 define ws_msgsin        char (70)
 define ws_msgerr        char (300)
 define l_mtv_principal  like datmavisrent.avialgmtv  #recebe mtv principal cadastrado
 define l_diff           smallint                     #flag de comparacao (true->diferente)

 DEFINE l_funnom         LIKE isskfunc.funnom,
        l_dptsgl         LIKE isskfunc.dptsgl
       ,l_result         smallint
       ,l_msg            char(080)

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

        initialize  ws.*  to  null

 let ws_avialgmtv = d_cts74m00.avialgmtv

 call cts74m00_input()

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    initialize d_cts74m00.*    to null
    initialize w_cts74m00.*    to null
    clear form
    return false
 end if

 let ws_avirsrgrttip = m_opcao


 whenever error continue

 begin work

  update datmservico set (nom      , corsus   , cornom   , vclcoddig,
                          vcldes   , vclanomdl, vcllicnum)
                       = (d_cts74m00.nom      , d_cts74m00.corsus   ,
                          d_cts74m00.cornom   , d_cts74m00.vclcoddig,
                          d_cts74m00.vcldes   , d_cts74m00.vclanomdl,
                          d_cts74m00.vcllicnum)
                    where atdsrvnum = mr_geral.atdsrvnum and
                          atdsrvano = mr_geral.atdsrvano

  if sqlca.sqlcode <> 0 then
     error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA! "
     rollback work
     prompt "" for char prompt_key
     return false
  end if

   if w_cts74m00.avioccdat is null then
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      let w_cts74m00.avioccdat = l_data
   end if

  # Verifica se motivo principal foi alterado

  let l_diff = false

  whenever error continue
    open c_cts74m00_041 using mr_geral.atdsrvnum
                            , mr_geral.atdsrvano
    fetch c_cts74m00_041 into l_mtv_principal
  whenever error stop

  if l_mtv_principal <> d_cts74m00.avialgmtv then
      # Deleta motivos complementares

      whenever error continue
        execute p_cts74m00_042 using mr_geral.atdsrvnum
                                   , mr_geral.atdsrvano
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro (',sqlca.sqlcode,') na limpeza de motivos (datrvcllocrsrcmp)'
      end if

      let l_diff = true
  end if
  whenever error continue
  execute p_cts74m00_004 using d_cts74m00.lcvcod   , d_cts74m00.avivclcod, d_cts74m00.aviestcod
                            ,d_cts74m00.avivclvlr, d_cts74m00.locsegvlr, d_cts74m00.avialgmtv
                            ,w_cts74m00.avidiaqtd, d_cts74m00.avilocnom, w_cts74m00.aviretdat
                            ,w_cts74m00.avirethor, w_cts74m00.aviprvent, w_cts74m00.avioccdat
                            ,w_cts74m00.ofnnom   , w_cts74m00.ofndddcod, w_cts74m00.ofntelnum
                            ,d_cts74m00.cttdddcod, d_cts74m00.ctttelnum, ws_avirsrgrttip
                            ,w_cts74m00.slcemp   , w_cts74m00.slcsuccod, w_cts74m00.slcmat
                            ,w_cts74m00.slccctcod, d_cts74m00.cdtoutflg, d_cts74m00.vclloctip
                            ,d_cts74m00.locrspcpfnum, d_cts74m00.locrspcpfdig
                            ,d_cts74m00.lcvsinavsflg, mr_geral.atdsrvnum, mr_geral.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro UPDATE p_cts74m00_004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
     error 'cts74m00 / cts74m00_modifica() / ',d_cts74m00.lcvcod   ,' / ', d_cts74m00.avivclcod,' / '
                                              ,d_cts74m00.aviestcod,' / ', d_cts74m00.avivclvlr,' / '
                                              ,d_cts74m00.locsegvlr,' / ', d_cts74m00.avialgmtv,' / '
                                              ,w_cts74m00.avidiaqtd,' / ', d_cts74m00.avilocnom,' / '
                                              ,w_cts74m00.aviretdat,' / ', w_cts74m00.avirethor,' / '
                                              ,w_cts74m00.aviprvent,' / ', w_cts74m00.avioccdat,' / '
                                              ,w_cts74m00.ofnnom   ,' / ', w_cts74m00.ofndddcod,' / '
                                              ,w_cts74m00.ofntelnum,' / ', d_cts74m00.cttdddcod,' / '
                                              ,d_cts74m00.ctttelnum,' / ', ws_avirsrgrttip     ,' / '
                                              ,w_cts74m00.slcemp   ,' / ', w_cts74m00.slcsuccod,' / '
                                              ,w_cts74m00.slcmat   ,' / ', w_cts74m00.slccctcod,' / '
                                              ,d_cts74m00.cdtoutflg,' / ', d_cts74m00.vclloctip,' / '
                                              ,d_cts74m00.locrspcpfnum,' / ', d_cts74m00.locrspcpfdig,' / '
                                              ,d_cts74m00.smsenvdddnum, ' / ', d_cts74m00.smsenvcelnum,' / '
                                              ,d_cts74m00.lcvsinavsflg,' / ', mr_geral.atdsrvnum,' / '
                                              ,mr_geral.atdsrvano  sleep 1
     rollback work
     return false
  end if
  if l_diff then
     call cts74m00_inclui_motivos_complementares(mr_geral.atdsrvnum, mr_geral.atdsrvano)
  end if

  whenever error stop
  let m_histerr = cts10g02_historico( mr_geral.atdsrvnum,
                                      mr_geral.atdsrvano,
                                      l_data,
                                      l_hora2,
                                      g_issk.funmat,
                                      hist_cts74m00.*   )

  commit work
  # Ponto de acesso apos a gravacao do laudo
  call cts00g07_apos_grvlaudo(mr_geral.atdsrvnum,
                              mr_geral.atdsrvano)

  return true

end function

#-------------------------------------------------------------------------------
 function cts74m00_inclui()
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

define lr_pagamento record
 	orgnum		like datmpgtinf.orgnum,
 	prpnum		like datmpgtinf.prpnum,
 	pgtfrmcod	like datmpgtinf.pgtfrmcod,
 	pgtfrmdes	like datkpgtfrm.pgtfrmdes
 end record

 define lr_cartao record
 	clinom		like datmcrdcrtinf.clinom,
 	crtnum		like datmcrdcrtinf.crtnum,
 	bndcod		like datmcrdcrtinf.bndcod,
 	crtvlddat	like datmcrdcrtinf.crtvlddat,
 	cbrparqtd	like datmcrdcrtinf.cbrparqtd,
 	bnddes		like fcokcarbnd.carbndnom
 end record

 define la_historico       array[7] of record
         descricao         char (70)
 end record

 define l_ind            smallint
 define l_dadosPagamento smallint
 define l_cartaoCripto   dec(4,0)
 define l_count          dec(1,0)

 define w_retorno          smallint
       ,l_result           smallint
       ,l_msg              char(080)


 define l_data         date,
        l_hora2        datetime hour to minute,
        l_sql          char(500), # Amilton
        l_index        integer,    # Amilton
        l_saldo        integer,    # amilton
        l_dias_utiliz  integer,    # amilton
        l_dias_prev    integer    # amilton

 define cty27g00_ret integer # psi-2012-22101

 define lr_retcrip record
        coderro         smallint
       ,msgerro         char(10000)
       ,pcapticrpcod    like fcomcaraut.pcapticrpcod
 end record

 ###PSI-2012-22101
 define lr_frm_pagamento record
        crtnum                like datmcrdcrtinf.crtnum,
        crtnumPainel          char(4)
 end record

        let     ws_avirsrgrttip  =  null
        let     ws_msgerr  =  null
        let     ws_msgsin  =  null
        let     w_retorno  =  null

        initialize  ws.*, cty27g00_ret  to  null
 let l_dadosPagamento = true
 while true
   let d_cts74m00.aviproflg = "N"
   let mr_geral.acao = "INC"

   initialize  w_cts74m00.locrspcpfnum, w_cts74m00.locrspcpfdig to null

   call cts74m00_input()

   if  int_flag  then
       let int_flag  = false
       initialize d_cts74m00.*     to null
       initialize w_cts74m00.*     to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   let w_cts74m00.avidiaqtd = 0

   if  w_cts74m00.atdfnlflg = "N"  then
       let w_cts74m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

   if  w_cts74m00.atddat is null  then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let w_cts74m00.atddat = l_data
       let w_cts74m00.atdhor = l_hora2
   end if

   if  w_cts74m00.funmat is null  then
       let w_cts74m00.funmat = g_issk.funmat
   end if

   if  d_cts74m00.frmflg = "S"  then
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
      let w_cts74m00.atdrsdflg = "S"
   else
      let w_cts74m00.atdrsdflg = "N"
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
       let ws.msg = "cts74m00 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let mr_geral.lignum       = ws.lignum
   let g_documento.lignum    = ws.lignum
   let w_cts74m00.atdsrvnum  = ws.atdsrvnum
   let w_cts74m00.atdsrvano  = ws.atdsrvano
   let ws.atdsrvorg          = 08 #==> Remocao

 #------------------------------------------------------------------------------
 # Grava dados da ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( mr_geral.lignum         ,
                           w_cts74m00.atddat       ,
                           w_cts74m00.atdhor       ,
                           mr_geral.c24soltipcod   ,
                           mr_geral.solnom         ,
                           mr_geral.c24astcod      ,
                           w_cts74m00.funmat       ,
                           mr_geral.ligcvntip      ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","", "",""            ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
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


   call cts10g02_grava_servico( w_cts74m00.atdsrvnum,
                                w_cts74m00.atdsrvano,
                                mr_geral.soltip  ,     # atdsoltip
                                mr_geral.solnom  ,     # c24solnom
                                ""                  ,     # vclcorcod
                                w_cts74m00.funmat   ,
                                d_cts74m00.atdlibflg,
                                w_cts74m00.atdhor   ,     # atdlibhor
                                w_cts74m00.atddat   ,     # atdlibdat
                                w_cts74m00.atddat   ,     # atddat
                                w_cts74m00.atdhor   ,     # atdhor
                                ""                  ,     # atdlclflg
                                ""                  ,     # atdhorpvt
                                ""                  ,     # atddatprg
                                ""                  ,     # atdhorprg
                                "R"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                ""                  ,     # atdprscod
                                ""                  ,     # atdcstvlr
                                w_cts74m00.atdfnlflg,
                                w_cts74m00.atdfnlhor,
                                w_cts74m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts74m00.c24opemat,
                                d_cts74m00.nom      ,
                                d_cts74m00.vcldes   ,
                                d_cts74m00.vclanomdl,
                                d_cts74m00.vcllicnum,
                                d_cts74m00.corsus   ,
                                d_cts74m00.cornom   ,
                                w_cts74m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                ""                  ,     # atdpvtretflg
                                ""                  ,     # atdvcltip
                                ""                  ,     # asitipcod
                                ""                  ,     # socvclcod
                                d_cts74m00.vclcoddig,
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

   if w_cts74m00.avioccdat is null then
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      let w_cts74m00.avioccdat = l_data
   end if



   whenever error continue
   execute p_cts74m00_005 using ws.atdsrvnum , ws.atdsrvano , d_cts74m00.lcvcod
                             ,d_cts74m00.avivclcod, d_cts74m00.aviestcod, d_cts74m00.avivclvlr
                             ,d_cts74m00.avialgmtv   , w_cts74m00.avidiaqtd, d_cts74m00.avilocnom
                             ,w_cts74m00.aviretdat   , w_cts74m00.avirethor, w_cts74m00.aviprvent
                             ,d_cts74m00.locsegvlr   , d_cts74m00.vclloctip, w_cts74m00.avioccdat
                             ,w_cts74m00.ofnnom      , w_cts74m00.ofndddcod, w_cts74m00.ofntelnum
                             ,d_cts74m00.cttdddcod   , d_cts74m00.ctttelnum, ws_avirsrgrttip
                             ,w_cts74m00.slcemp      , w_cts74m00.slcsuccod, w_cts74m00.slcmat
                             ,w_cts74m00.slccctcod   , d_cts74m00.cdtoutflg, d_cts74m00.locrspcpfnum
                             ,d_cts74m00.locrspcpfdig, d_cts74m00.lcvsinavsflg,d_pss.sindat
                             ,d_pss.prcnum,d_pss.prccnddes,d_pss.itaofinom, d_cts74m00.smsenvdddnum
                             ,d_cts74m00.smsenvcelnum
   whenever error stop
   if  sqlca.sqlcode  <>  0  then
       error 'Erro INSERT p_cts74m00_005 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       display 'cts74m00 / cts74m00_inclui() / ',ws.atdsrvnum        ,' / ', ws.atdsrvano        ,' / '
                                              ,d_cts74m00.lcvcod   ,' / ', d_cts74m00.avivclcod,' / '
                                              ,d_cts74m00.aviestcod,' / ', d_cts74m00.avivclvlr,' / '
                                              ,d_cts74m00.avialgmtv,' / ', w_cts74m00.avidiaqtd,' / '
                                              ,d_cts74m00.avilocnom,' / ', w_cts74m00.aviretdat,' / '
                                              ,w_cts74m00.avirethor,' / ', w_cts74m00.aviprvent,' / '
                                              ,d_cts74m00.locsegvlr,' / ', d_cts74m00.vclloctip,' / '
                                              ,w_cts74m00.avioccdat,' / ', w_cts74m00.ofnnom   ,' / '
                                              ,w_cts74m00.ofndddcod,' / ', w_cts74m00.ofntelnum,' / '
                                              ,d_cts74m00.cttdddcod,' / ', d_cts74m00.ctttelnum,' / '
                                              ,ws_avirsrgrttip     ,' / ', w_cts74m00.slcemp   ,' / '
                                              ,w_cts74m00.slcsuccod,' / ', w_cts74m00.slcmat   ,' / '
                                              ,w_cts74m00.slccctcod,' / ', d_cts74m00.cdtoutflg,' / '
                                              ,d_cts74m00.locrspcpfnum,' / ',d_cts74m00.locrspcpfdig,' / '
                                              ,d_cts74m00.lcvsinavsflg,' / ',d_cts74m00.smsenvdddnum,' / '
                                              ,d_cts74m00.smsenvcelnum   sleep 1
       rollback work
       let ws.retorno = false
       exit while
   end if

   call cts74m00_inclui_motivos_complementares(ws.atdsrvnum , ws.atdsrvano)




 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
  if  w_cts74m00.atdetpcod is null  then
       let w_cts74m00.atdetpcod = 1
       let ws.etpfunmat = w_cts74m00.funmat
       let ws.atdetpdat = w_cts74m00.atddat
       let ws.atdetphor = w_cts74m00.atdhor
  end if

  call cts10g04_insere_etapa( ws.atdsrvnum        ,
                              ws.atdsrvano        ,
                              w_cts74m00.atdetpcod,
                              d_cts74m00.lcvcod   ,
                              " ",
                              " ",
                              d_cts74m00.aviestcod) returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   #PSI-2013-04081 Não será gravado mais celular no histórico
   #if d_cts74m00.lcvcod <> 2 then
   #
   #   let l_msg = " Telefone Celular.: ",d_cts74m00.smsenvdddnum ," - " ,
   #                 d_cts74m00.smsenvcelnum
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
   #          error l_msg, " - cts74m00 - AVISE A INFORMATICA!"
	#     end if
   #end if
   
   #CT-2014-14110/IN 
   ##---------------------------------------------
   ## Grava Formas de Pagamento psi-2012-22101
   ##---------------------------------------------
   #let cty27g00_ret = 0
   #call cty27g00_consiste_ast(d_cts74m00.c24astcod)
   #     returning cty27g00_ret
   #if cty27g00_ret = 1 then
   #   call cty27g00_entrada_dados(g_documento.prpnum,
   #                               ws.atdsrvnum,
   #                               ws.atdsrvano)
   #   let g_documento.prpnum_flg = ""
   #end if
   #
   ##------------------------------------------------------------------------------
   ## Grava HISTORICO do servico
   ##------------------------------------------------------------------------------
   #let m_histerr = cts10g02_historico( ws.atdsrvnum     ,
   #                                     ws.atdsrvano     ,
   #                                     w_cts74m00.atddat,
   #                                     w_cts74m00.atdhor,
   #                                     g_issk.funmat,
   #                                     hist_cts74m00.*   )
   #fim CT-2014-14110/IN 
   commit work

   #CT-2014-14110/IN 
   #---------------------------------------------
   # Grava Formas de Pagamento psi-2012-22101
   #---------------------------------------------
   let cty27g00_ret = 0
   call cty27g00_consiste_ast(d_cts74m00.c24astcod)
        returning cty27g00_ret
   if cty27g00_ret = 1 then
      call cty27g00_entrada_dados(g_documento.prpnum,
                                  ws.atdsrvnum,
                                  ws.atdsrvano)
      let g_documento.prpnum_flg = ""
   end if

   #------------------------------------------------------------------------------
   # Grava HISTORICO do servico
   #------------------------------------------------------------------------------
   let m_histerr = cts10g02_historico( ws.atdsrvnum     ,
                                        ws.atdsrvano     ,
                                        w_cts74m00.atddat,
                                        w_cts74m00.atdhor,
                                        g_issk.funmat,
                                        hist_cts74m00.*   )
   #fim CT-2014-14110/IN 


 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico - Informações pagamento
 #------------------------------------------------------------------------------
     open c_cts74m00_043 using ws.atdsrvnum,
  			       ws.atdsrvano

     whenever error continue
     fetch c_cts74m00_043 into lr_pagamento.orgnum,
  	  		       lr_pagamento.prpnum,
  			       lr_pagamento.pgtfrmcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'Erro SELECT c_cts74m00_043: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
        let l_dadosPagamento= false
     end if

     if l_dadosPagamento = true then
	  open c_cts74m00_045 using lr_pagamento.pgtfrmcod

	  whenever error continue
	  fetch c_cts74m00_045 into lr_pagamento.pgtfrmdes

	  whenever error stop
	  if sqlca.sqlcode <> 0 then
	     error 'Erro SELECT c_cts74m00_045: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	     let l_dadosPagamento= false
	  end if

     end if

     if lr_pagamento.pgtfrmcod = 1 and
        l_dadosPagamento = true then
	     open c_cts74m00_044 using lr_pagamento.orgnum,
	  			       lr_pagamento.prpnum,
	                               lr_pagamento.orgnum,
	                               lr_pagamento.prpnum
	     whenever error continue
	     fetch c_cts74m00_044 into lr_cartao.clinom,
	     			       lr_cartao.crtnum,
	  			       lr_cartao.bndcod,
	  			       lr_cartao.crtvlddat,
	  			       lr_cartao.cbrparqtd
	     whenever error stop
	     if sqlca.sqlcode <> 0 then
	        error 'Erro SELECT c_cts74m00_044: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	        let l_dadosPagamento= false
	     end if

             ########Decriptografar cartão e pegar apenas últimos 4 digitos
             # Descriptografa o numero do cartao
             initialize lr_retcrip.* to null
             call ffctc890("D",lr_cartao.crtnum  )
                  returning lr_retcrip.*

             let lr_frm_pagamento.crtnumPainel = lr_retcrip.pcapticrpcod[13,16]
             let l_cartaoCripto = lr_frm_pagamento.crtnumPainel
             let lr_frm_pagamento.crtnum = "Numero Cartao: ",lr_frm_pagamento.crtnumPainel

	     if l_dadosPagamento = true then
		     open c_cts74m00_046 using lr_cartao.bndcod

		     whenever error continue
		     fetch c_cts74m00_046 into lr_cartao.bnddes

		     whenever error stop
		     if sqlca.sqlcode <> 0 then
		        error 'Erro SELECT c_cts74m00_046: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
		        let l_dadosPagamento= false
	  	     end if
  	     end if

     end if

     if l_dadosPagamento = true then
  	let l_count = 2
  	let la_historico[1].descricao = 'PROPOSTA: ', lr_pagamento.orgnum using '####',"-",lr_pagamento.prpnum using '########'
  	let la_historico[2].descricao = 'FORMA PAGAMENTO: ',lr_pagamento.pgtfrmdes clipped

  	if lr_pagamento.pgtfrmcod = 1 then
	   let l_count = 7
	   let la_historico[3].descricao = 'NOME CLIENTE: ', lr_cartao.clinom clipped
	   let la_historico[4].descricao = 'NUMERO CARTAO: XXXX-XXXX-XXXX-',l_cartaoCripto using '####'
	   let la_historico[5].descricao = 'BANDEIRA CARTÃO: ',lr_cartao.bnddes clipped
	   let la_historico[6].descricao = 'VALIDADE CARTÃO: ', lr_cartao.crtvlddat
	   let la_historico[7].descricao = 'QUANTIDADE PARCELAS: ',lr_cartao.cbrparqtd
  	end if

        for l_ind = 1 to l_count
  	    call ctd07g01_ins_datmservhist(ws.atdsrvnum, #g_documento.atdsrvnum,
                                           ws.atdsrvano, #g_documento.atdsrvano,
  	    	                           g_issk.funmat,
  	    	                           la_historico[l_ind].descricao,
  	    	                           w_cts74m00.atddat,
                                           w_cts74m00.atdhor,
                                           g_issk.empcod,
                                           g_issk.usrtip)
            returning w_retorno,
                      l_msg
            if w_retorno <> 1  then
               error l_msg, " - cts74m00 - AVISE A INFORMATICA!"
            end if
        end for
     end if

   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(ws.atdsrvnum,
                               ws.atdsrvano)

 #------------------------------------------------------------------------------
 # Exibe o numero do Servico
 #------------------------------------------------------------------------------

   let d_cts74m00.servico =      F_FUNDIGIT_INTTOSTR(ws.atdsrvorg, 2),
                            "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum, 7),
                            "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano, 2)
   display d_cts74m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function

#--------------------------------------------------------------------
 function cts74m00_input()
#--------------------------------------------------------------------

 define cty27g00_ret integer # psi-2012-22101

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
         l_tipo_ordenacao char(01),
         l_flag           smallint

  define l_cidcod      like glakcid.cidcod,
         l_msg         char(100)

  define l_data        date,
         l_hora2       datetime hour to minute,
         l_qtde        smallint,
         l_desc_1      char(40),
         l_desc_2      char(40),
         l_clscod      like aackcls.clscod,
         l_confirma    char(1),
         l_index       integer
  define l_avialgmtv_anterior like datmavisrent.avialgmtv

  define lr_email record
    succod          like datrligapol.succod       # Codigo Sucursal
   ,aplnumdig       like datrligapol.aplnumdig    # Numero Apolice
   ,itmnumdig       like datrligapol.itmnumdig    # Numero do Item
   ,prporg          like datrligprp.prporg        # Origem da Proposta
   ,prpnumdig       like datrligprp.prpnumdig     # Numero da Proposta
   ,solnom          char (15)                     # Solicitante
   ,ramcod          like datrservapol.ramcod      # Codigo Ramo
   ,lignum          like datmligacao.lignum       # Numero da Ligacao
   ,c24astcod       like datkassunto.c24astcod    # Assunto da Ligacao
   ,ligcvntip       like datmligacao.ligcvntip    # Convenio Operacional
   ,atdsrvnum       like datmservico.atdsrvnum    # Numero do Servico
   ,atdsrvano       like datmservico.atdsrvano    # Ano do Servico
 end record

 define l_envio smallint

  initialize  hist_cts74m00.*  to  null

        let  ws_atdsrvnum  =  null
        let  ws_atdsrvano  =  null
        let  ws_atdetpcod  =  null
        let  l_tipo_ordenacao = null
        let  l_cod_erro   = null
        let  l_concede_ar = false
        let  l_qtde          = 0
        let  l_flag          = false
        let  l_confirma = "N"
        let  l_index = 0


        initialize  ws.*  to  null

        initialize  ws2.*  to  null

 let ws.vcllicant = d_cts74m00.vcllicnum

 initialize ws.* to null

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



 display by name d_cts74m00.lcvnom

    if mr_geral.atdsrvnum is null  and
       mr_geral.atdsrvano is null  then
       let d_cts74m00.vclloctip = 1
    end if

    case d_cts74m00.vclloctip
       when 1  let d_cts74m00.vcllocdes = "SEGURADO"
       when 2  let d_cts74m00.vcllocdes = "CORRETOR"
       when 3  let d_cts74m00.vcllocdes = "DEPTO."
       when 4  let d_cts74m00.vcllocdes = "FUNC."
    end case
    display by name d_cts74m00.vclloctip
    display by name d_cts74m00.vcllocdes


 input by name d_cts74m00.nom      ,
               d_cts74m00.corsus   ,
               d_cts74m00.cornom   ,
               d_cts74m00.vclcoddig,
               d_cts74m00.vclanomdl,
               d_cts74m00.vcllicnum,
               d_cts74m00.avilocnom,
               d_cts74m00.locrspcpfnum,
               d_cts74m00.locrspcpfdig,
               d_cts74m00.avialgmtv,
               d_cts74m00.garantia,
               d_cts74m00.flgarantia,
               d_cts74m00.lcvcod   ,
               d_cts74m00.lcvextcod,
               d_cts74m00.cdtoutflg,
               d_cts74m00.avivclcod,
               d_cts74m00.frmflg   ,
               d_cts74m00.aviproflg,
               d_cts74m00.smsenvdddnum,
               d_cts74m00.smsenvcelnum,
               d_cts74m00.cttdddcod,
               d_cts74m00.ctttelnum,
               d_cts74m00.atdlibflg without defaults








   before field nom
          if ws.pgtflg = true  then
             call cts08g01("A","N","","","LOCACAO PAGA NAO DEVE SER ALTERADA!",
                                      "") returning ws.confirma
             next field frmflg
          end if

          if mr_geral.atdsrvnum is not null  and
             mr_geral.atdsrvano is not null  then
             if d_cts74m00.vclloctip = 2  or
                d_cts74m00.vclloctip = 3  or
                d_cts74m00.vclloctip = 4  then
                display by name d_cts74m00.nom      , d_cts74m00.corsus   ,
                                d_cts74m00.cornom   , d_cts74m00.vclcoddig,
                                d_cts74m00.vclanomdl, d_cts74m00.vcllicnum,
                                d_cts74m00.avilocnom
                if d_cts74m00.vclloctip = 4  then
                   next field locrspcpfnum
                else
                   next field avilocnom
                end if
             end if
          end if

          while true
             if d_cts74m00.vclloctip is not null  then
                exit while
             end if

             call cts15m09(ws.vclloctip,
                           d_cts74m00.corsus,
                           d_cts74m00.cornom,
                           w_cts74m00.slcemp,
                           w_cts74m00.slcsuccod,
                           w_cts74m00.slcmat,
                           w_cts74m00.slccctcod,
                           g_documento.ciaempcod)
                 returning d_cts74m00.vclloctip,
                           d_cts74m00.corsus,
                           d_cts74m00.cornom,
                           w_cts74m00.slcemp,
                           w_cts74m00.slcsuccod,
                           w_cts74m00.slcmat,
                           w_cts74m00.slccctcod,
                           g_documento.ciaempcod

             if d_cts74m00.corsus     is null and
                d_cts74m00.cornom     is null and
                w_cts74m00.slcemp     is null and
                w_cts74m00.slcsuccod  is null and
                w_cts74m00.slcmat     is null and
                w_cts74m00.slccctcod  is null then
                initialize d_cts74m00.vclloctip to null
                call cts08g01("C","S","",
                                      "ABANDONA O PREENCHIMENTO DO LAUDO ?",
                                      "","")
                     returning ws.confirma

                if ws.confirma  =  "S"   then
                   exit while
                end if
             else

                display by name d_cts74m00.vclloctip
                display by name d_cts74m00.vcllocdes
                display by name d_cts74m00.nom
                display by name d_cts74m00.avilocnom
                display by name d_cts74m00.corsus

                if d_cts74m00.vclloctip = 4 then
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
          display by name d_cts74m00.nom        attribute (reverse)

          if g_documento.acao = 'ALT' then
             call cts08g01("A","S",
                           "** Deseja Realizar uma Prorrogacao ? **",
                           "",
                           "",
                           "")
            returning l_confirma

            if l_confirma = "S"  then
               let d_cts74m00.aviproflg = "S"
               next field aviproflg
             end if
          end if



   after  field nom
          display by name d_cts74m00.nom

          ## Para sinistro, somente consulta o laudo
          if mr_geral.acao = 'CON' then
             let ws.confirma = cts08g01('A', 'N', '', 'NAO E POSSIVEL ALTERAR O LAUDO'
                                       ,'LIBERADO SOMENTE PARA CONSULTA', '')
             next field nom
          end if

          if d_cts74m00.nom is null  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if d_cts74m00.vclloctip = 2  or
             d_cts74m00.vclloctip = 3  then
             next field avilocnom
          end if

   before field corsus
          display by name d_cts74m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts74m00.corsus

   before field cornom
          display by name d_cts74m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts74m00.cornom

   before field vclcoddig
          display by name d_cts74m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts74m00.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts74m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          end if

          if d_cts74m00.vclcoddig is null  or
             d_cts74m00.vclcoddig =  0     then
             call agguvcl() returning d_cts74m00.vclcoddig
             next field vclcoddig
          end if

          let d_cts74m00.vcldes = cts15g00(d_cts74m00.vclcoddig)

          display by name d_cts74m00.vcldes

   before field vclanomdl
          display by name d_cts74m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts74m00.vclanomdl

          if d_cts74m00.vclanomdl is null  then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts74m00.vclcoddig,
                         d_cts74m00.vclanomdl) = false  then
                error " Veiculo nao consta como fabricado em ",
                        d_cts74m00.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts74m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts74m00.vcllicnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclanomdl
          end if

          if d_cts74m00.vcllicnum  is not null   then
             if not srp1415(d_cts74m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if



   before field avilocnom
          display by name d_cts74m00.avilocnom  attribute (reverse)

   after  field avilocnom

          display by name d_cts74m00.avilocnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts74m00.vclloctip = 1  then
                next field vcllicnum
             else
                if mr_geral.atdsrvnum is not null  and
                   mr_geral.atdsrvano is not null  then
                   next field avilocnom
                else
                   initialize d_cts74m00.vclloctip, d_cts74m00.vcllocdes,
                              d_cts74m00.nom      , d_cts74m00.avilocnom,
                              d_cts74m00.corsus   , d_cts74m00.vclloctip to null
                   display by name d_cts74m00.vclloctip
                   display by name d_cts74m00.vcllocdes
                   display by name d_cts74m00.nom
                   display by name d_cts74m00.avilocnom
                   display by name d_cts74m00.corsus
                   next field nom
                end if
             end if
          end if

          if d_cts74m00.avilocnom is null  then
             error " Informe o nome do usuario!"
             next field avilocnom
          end if

   before field locrspcpfnum
          if mr_geral.atdsrvnum is null  then
             call cts15m02(w_cts74m00.clscod)
                 returning ws.ok_flg, ws.cidnom, ws.ufdcod
                 let m_cidnom = ws.cidnom
                 let m_ufdcod = ws.ufdcod

             if ws.ok_flg          is null  then
                error " Criterios para locacao nao foram atendidos!"
                next field locrspcpfnum
             end if
          end if
          display by name d_cts74m00.locrspcpfnum  attribute (reverse)

   after  field locrspcpfnum

          display by name d_cts74m00.locrspcpfnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts74m00.vclloctip = 4 then
                if mr_geral.atdsrvnum is not null  and
                   mr_geral.atdsrvano is not null  then
                   next field locrspcpfnum
                else
                   initialize d_cts74m00.vclloctip, d_cts74m00.vcllocdes,
                              d_cts74m00.nom      , d_cts74m00.avilocnom,
                              d_cts74m00.corsus   , d_cts74m00.vclloctip to null
                   display by name d_cts74m00.vclloctip
                   display by name d_cts74m00.vcllocdes
                   display by name d_cts74m00.nom
                   display by name d_cts74m00.avilocnom
                   display by name d_cts74m00.corsus
                   next field nom
                end if
             else
                next field avilocnom
             end if
          end if
          if d_cts74m00.locrspcpfnum is null then
             next field avialgmtv
          end if

   before field locrspcpfdig
          display by name d_cts74m00.locrspcpfdig  attribute (reverse)

   after  field locrspcpfdig
          display by name d_cts74m00.locrspcpfdig

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field locrspcpfnum
          end if

          if d_cts74m00.locrspcpfnum is not null and
             d_cts74m00.locrspcpfdig is     null then
             error " Digito do Cpf incorreto!"
             next field locrspcpfdig
          end if

          if d_cts74m00.locrspcpfnum is not null and
             d_cts74m00.locrspcpfdig is not null then
             call F_FUNDIGIT_DIGITOCPF(d_cts74m00.locrspcpfnum)
                             returning ws.cgccpfdig

             if ws.cgccpfdig            is null           or
                d_cts74m00.locrspcpfdig <> ws.cgccpfdig   then
                error " Digito do Cpf incorreto!"
                next field locrspcpfdig
             end if
          end if

   before field avialgmtv
          display by name d_cts74m00.avialgmtv  attribute (reverse)
          let l_avialgmtv_anterior = d_cts74m00.avialgmtv

   after  field avialgmtv
          display by name d_cts74m00.avialgmtv

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts74m00.locrspcpfnum is null then
                next field locrspcpfnum
             else
                next field locrspcpfdig
             end if
          end if

          if d_cts74m00.avialgmtv is null then
             call cts74m00_popup_motivos()
                  returning d_cts74m00.avialgmtv
             display by name d_cts74m00.avialgmtv

             if d_cts74m00.avialgmtv is null then
                next field avialgmtv
             end if

          end if

          if d_cts74m00.c24astcod = "P88" or
             d_cts74m00.c24astcod = "P89" then
               if ((d_cts74m00.avialgmtv  is null) or
                   (d_cts74m00.avialgmtv  <> 1     and
                    d_cts74m00.avialgmtv  <> 2     and
                    d_cts74m00.avialgmtv  <> 3     and
                    d_cts74m00.avialgmtv  <> 4     and
                    d_cts74m00.avialgmtv  <> 5     and
                    d_cts74m00.avialgmtv  <> 8     and
                    d_cts74m00.avialgmtv  <> 9     and
                    d_cts74m00.avialgmtv  <> 0     and
                    d_cts74m00.avialgmtv  <> 13     and
                    d_cts74m00.avialgmtv  <> 14))   then

                    error "Motivo não relacionado ao assunto "
                    next field avialgmtv


               end if
          else
               if ((d_cts74m00.avialgmtv is null) or
                      (d_cts74m00.avialgmtv <> 4   and
                       d_cts74m00.avialgmtv <> 5   and
                       d_cts74m00.avialgmtv <> 6   and
                       d_cts74m00.avialgmtv <> 7)) then
                       error "Motivo não relacionado ao assunto "
                       next field avialgmtv

             end if
          end if

          if d_cts74m00.vclloctip =  1    and
             d_cts74m00.avialgmtv =  4    then
             call cts08g01("A","S","","TIPO DE RESERVA SERA TROCADA",
                                      "PARA DEPARTAMENTO ?","")
                  returning ws.confirma

             if ws.confirma  =  "S"   then

                let d_cts74m00.vclloctip = 3
                let d_cts74m00.vcllocdes = "DEPTO."

                display by name d_cts74m00.vclloctip
                display by name d_cts74m00.vcllocdes
                call cts15m08(d_cts74m00.vclloctip,
                              w_cts74m00.slcemp,
                              w_cts74m00.slcsuccod,
                              w_cts74m00.slcmat,
                              w_cts74m00.slccctcod,
                              "A" )               #--> (A)tualiza/(C)onsulta
                    returning w_cts74m00.slcemp,
                              w_cts74m00.slcsuccod,
                              w_cts74m00.slcmat,
                              w_cts74m00.slccctcod,
                              ws.nomeusu    #-> neste caso nome funcionari
             else
                next field avialgmtv
             end if

          end if

          if d_cts74m00.vclloctip =  2    and
             d_cts74m00.avialgmtv <> 5    and
             d_cts74m00.avialgmtv <> 9    then
             error " Corretores so' podem fazer locacoes (5)PARTICULAR (9)Ind.Integral!"
             next field avialgmtv
          end if

          if d_cts74m00.vclloctip =  3    and
             d_cts74m00.avialgmtv <> 4    then
             error " Reserva tipo DEPTO. so' podem fazer locacoes DEPARTAMENTOS!"
             next field avialgmtv
          end if
          if d_cts74m00.vclloctip =  4    and
             d_cts74m00.avialgmtv <> 5    then
             error " Reservas tipo FUNC. so' podem fazer locacoes PARTICULAR!"
             next field avialgmtv
          end if

          if d_cts74m00.c24astcod = "P88" or
             d_cts74m00.c24astcod = "P89" then
              open c_cts74m00_001 using d_cts74m00.avialgmtv

              whenever error continue
              fetch c_cts74m00_001 into d_cts74m00.avimtvdes
              whenever error stop

              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = 100 then
                    let d_cts74m00.avimtvdes = null
                 else
                    error 'Erro SELECT iddkdominio:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                    let m_erro = true
                    return
                 end if
              end if
          end if

          if d_cts74m00.avialgmtv = 1  or
             d_cts74m00.avialgmtv = 3  or
             d_cts74m00.avialgmtv = 6  or #osf32867 - Paula
             d_cts74m00.avialgmtv = 7  or
             d_cts74m00.avialgmtv = 8  or
             d_cts74m00.avialgmtv = 9  or
             d_cts74m00.avialgmtv = 0  or
             d_cts74m00.avialgmtv = 13 or
             d_cts74m00.avialgmtv = 14 then  ## Alberto claus 33

             if d_cts74m00.avialgmtv   <> 6 then #osf32867 - Paula

                #------- Motivo 0 Sinistro Clausula 33 P88 ------------------#
                if d_cts74m00.avialgmtv = 0 then
                         call cts08g01("A","N",
                                      "MOTIVO 0-Sinis.Claus.33.  ",
                                      "SOMENTE CONTRATADA PARA CLAUSULA 33",
                                      "SUGERIR RESERVAR POR MOTIVO 9-Ind.Integral.",
                                      "")
                         returning ws.confirma
                         next field avialgmtv
                 end if




                #---------------Motivo 8 Terceiro Segurado Porto P88 ------#
                if d_cts74m00.avialgmtv = 8 then

                   call cts08g01("A","N",
                                 "MOTIVO 8-Seg Como Terc ",
                                 "SOMENTE CONTRATADA PARA CLAUSULA 33.",
                                 "",
                                 "")
                    returning ws.confirma
                    next field avialgmtv

                end if

                if d_cts74m00.avialgmtv = 9 then

                      call cts08g01("A","N",
                                       "CLAUSULA 33R NAO CONTRATADA !",
                                       "NAO SERA POSSIVEL EFETUAR RESERVA",
                                       "POR MOTIVO 9-Ind.Integral.",
                                       "SUGERIR RESERVAR POR MOTIVO 1-SINISTRO.")
                          returning ws.confirma
                      next field avialgmtv

                end if

                if d_cts74m00.avialgmtv = 13 then

                      call cts08g01("A","N",
                                       "NAO SERA PERMITIDO PROSSEGUIR COM O  ",
                                       "MOTIVO 13- IND.INTEGRAL 30 DIAS",
                                       "APOLICE SEM CLAUSULA 33.",
                                       "")
                           returning ws.confirma
                      next field avialgmtv


                end if

                if d_cts74m00.avialgmtv = 14 then

                   call cts08g01("A","N",
                                    "NAO SERA PERMITIDO PROSSEGUIR COM O  ",
                                    "MOTIVO 14- TEMPO INDETERMINADO PERDA ",
                                    "PARCIAL. APOLICE SEM CLAUSULA 33",
                                    "")
                       returning ws.confirma
                   next field avialgmtv

                end if
             end if
          end if


          display by name d_cts74m00.avimtvdes
          display by name d_cts74m00.avialgmtv

          #--------------------------------------------------------------------
          # Locacao para DEPARTAMENTOS
          #--------------------------------------------------------------------

          if d_cts74m00.avialgmtv  =  4  or
             d_cts74m00.vclloctip  =  4  then
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
                call cts15m08(d_cts74m00.vclloctip,
                              w_cts74m00.slcemp,
                              w_cts74m00.slcsuccod,
                              w_cts74m00.slcmat,
                              w_cts74m00.slccctcod,
                              "A" )               #--> (A)tualiza/(C)onsulta
                    returning w_cts74m00.slcemp,
                              w_cts74m00.slcsuccod,
                              w_cts74m00.slcmat,
                              w_cts74m00.slccctcod,
                              ws.nomeusu    #-> neste caso nome funcionari
             end if
          end if

          if (g_documento.atdsrvnum is null   or
              g_documento.atdsrvano is null)  then

              call cts15m04("R"                  , d_cts74m00.avialgmtv,
                            ""                   , w_cts74m00.aviretdat,
                            w_cts74m00.avirethor , w_cts74m00.aviprvent,
                            ""                   , ws.endcep
                                                 , d_cts74m00.dtentvcl)
                  returning w_cts74m00.aviretdat , w_cts74m00.avirethor,
                            w_cts74m00.aviprvent  , ws.cct, ws.cct, ws.cct

              let ws.diasem = weekday(w_cts74m00.aviretdat)
          end if


   before field garantia
          display by name d_cts74m00.garantia
          next field flgarantia


   after  field garantia
          display by name d_cts74m00.garantia

   before field flgarantia

       if  g_documento.acao is null or
           g_documento.acao = 'INC' then
         let   m_opcao = null
         call cts74m00_popup_garantia()
      end if

        if d_cts74m00.garantia is null then
           let d_cts74m00.garantia = "Garantia:"
        else
           let d_cts74m00.garantia = d_cts74m00.garantia clipped , ':'
        end if


        display by name d_cts74m00.garantia
        display by name d_cts74m00.flgarantia

   after  field flgarantia
          display by name d_cts74m00.flgarantia

          if d_cts74m00.flgarantia is null or
             d_cts74m00.flgarantia = "N" then

              call cts74m00_popup_garantia()

          end if

          if d_cts74m00.garantia is null then
             let d_cts74m00.garantia = "Garantia"
          else
              let d_cts74m00.garantia = d_cts74m00.garantia clipped, ':'
          end if

          display by name d_cts74m00.garantia
          display by name d_cts74m00.flgarantia

          if m_opcao = 1 then
             let d_cts74m00.cauchqflg = "N"
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
                    let d_cts74m00.cauchqflg = "S"
                 else
                    next field flgarantia
                 end if
              end if

              if m_opcao = 3 then
                 call cts08g01_6l("A","S","",
                               "A OPCAO DE ISENCAO DE GARANTIA ",
                               "DISPENSARÁ APRESENTACAO DE CARTAO DE ",
                               "CREDITO OU CHEQUE CAUCAO SOB TOTAL",
                               "RESPONSABILIDADE DA PORTO SEGURO ",
                               "")
                       returning ws.confirma

                 if ws.confirma = "N" then
                    next field flgarantia
                 end if
              end if

          end if

          let d_cts74m00.lcvsinavsflg = 'N'



   before field lcvcod
          display by name d_cts74m00.lcvcod     attribute (reverse)

   after  field lcvcod
          display by name d_cts74m00.lcvcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
                next field flgarantia
          end if

          if d_cts74m00.lcvcod is null then
             error " Codigo da locadora deve ser informado!"

             call ctn00c02 (ws.ufdcod,ws.cidnom," "," ")
                 returning ws.endcep, ws.endcepcmp

             if ws.endcep is null  or
                ws.endcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field lcvcod
             else

               call ctn18c00("",
                             ws.endcep, ws.endcepcmp, w_cts74m00.clscod,
                             ws.diasem, 1, d_cts74m00.avialgmtv,
                             g_documento.ciaempcod)
                    returning d_cts74m00.lcvcod   ,
                              d_cts74m00.aviestcod,
                              ws.vclpsqflg

                initialize d_cts74m00.lcvextcod, d_cts74m00.aviestnom to null

                select lcvextcod, aviestnom
                  into d_cts74m00.lcvextcod,
                       d_cts74m00.aviestnom
                  from datkavislocal
                 where lcvcod    = d_cts74m00.lcvcod
                   and aviestcod = d_cts74m00.aviestcod
             end if
          end if

          select lcvnom, lcvstt, adcsgrtaxvlr, cdtsegtaxvlr
            into d_cts74m00.lcvnom,
                 ws.lcvstt,
                 ws.adcsgrtaxvlr,
                 d_cts74m00.cdtsegtaxvlr
            from datklocadora
           where lcvcod = d_cts74m00.lcvcod

          if sqlca.sqlcode <> 0  then
             error " Locadora nao cadastrada!"
             next field lcvcod
          else
             if ws.lcvstt <> "A"  then
                error " Locadora cancelada!"
                next field lcvcod
             end if
          end if

          display by name d_cts74m00.lcvnom

   before field lcvextcod
          display by name d_cts74m00.lcvextcod attribute (reverse)

   after  field lcvextcod
          display by name d_cts74m00.lcvextcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field lcvcod
          end if

          if d_cts74m00.lcvextcod is null  then
             error " Informe a loja para retirada do veiculo!"

             call ctn00c02 (ws.ufdcod,ws.cidnom," "," ")
                 returning ws.endcep, ws.endcepcmp

             if ws.endcep is null     then
                error " Nenhum criterio foi selecionado!"
             else
                 call ctn18c00(d_cts74m00.lcvcod, ws.endcep, ws.endcepcmp,
                               w_cts74m00.clscod, ws.diasem, 0, 0,
                               g_documento.ciaempcod)
                 returning ws.lcvcod, d_cts74m00.aviestcod, ws.vclpsqflg

                initialize d_cts74m00.lcvextcod, d_cts74m00.aviestnom to null

                select lcvextcod, aviestnom
                  into d_cts74m00.lcvextcod,
                       d_cts74m00.aviestnom
                  from datkavislocal
                 where lcvcod    = d_cts74m00.lcvcod
                   and aviestcod = d_cts74m00.aviestcod

             end if
             next field lcvextcod
          else
             select aviestcod   ,         aviestnom,
                    vclalglojstt,         lcvlojtip,
                    lcvregprccod,         cauchqflg,
                    prtaertaxvlr
               into d_cts74m00.aviestcod, d_cts74m00.aviestnom,
                    ws.vclalglojstt     , ws.lcvlojtip,
                    ws.lcvregprccod     , ws.cauchqflg,
                    ws.prtaertaxvlr
               from datkavislocal
              where lcvcod    = d_cts74m00.lcvcod
                and lcvextcod = d_cts74m00.lcvextcod

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
                    where datklcvsit.lcvcod     = d_cts74m00.lcvcod
                      and datklcvsit.aviestcod  = d_cts74m00.aviestcod

                   if sqlca.sqlcode = 0 then
                      if ws2.viginc <= w_cts74m00.aviretdat and
                         ws2.vigfnl >= w_cts74m00.aviretdat then
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



             if d_cts74m00.cauchqflg = "S" then
                if ws.cauchqflg = "N"    or
                   ws.cauchqflg is null  then
                   call cts08g01("I","N","","LOJA SELECIONADA NAO ACEITA",
                                         "","CHEQUE CAUCAO.")
                        returning ws.confirma
                   next field lcvextcod
                end if
             end if

             display by name d_cts74m00.aviestnom

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
              call cts15m04_valloja(d_cts74m00.avialgmtv,
                                    d_cts74m00.aviestcod,
                                    w_cts74m00.aviretdat,
                                    w_cts74m00.avirethor,
                                    w_cts74m00.aviprvent,
                                    d_cts74m00.lcvcod   ,
                                    ws.endcep   )
                  returning ws.confirma
              if ws.confirma = "N" then
                 next field lcvextcod
              end if
          end if

   before field cdtoutflg
          #PSI 198390
          #exibir alerta informando se locadora cobra taxa 2 condutor
          if d_cts74m00.cdtsegtaxvlr is not null and
             d_cts74m00.cdtsegtaxvlr > 0 then
             call cts08g01("I","N", "", "LOCADORA COBRA TAXA DIARIA DE ",
                                        "2º CONDUTOR",
                                         d_cts74m00.cdtsegtaxvlr)
                      returning ws.confirma
          end if
          display by name d_cts74m00.cdtoutflg     attribute (reverse)

   after  field cdtoutflg
          display by name d_cts74m00.cdtoutflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lcvextcod
          end if

          if d_cts74m00.cdtoutflg is null  or
            (d_cts74m00.cdtoutflg <> "S"   and
             d_cts74m00.cdtoutflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field cdtoutflg
          end if

          if d_cts74m00.cdtoutflg = "S"  then
             let ws.confirma = cts08g01("A","N","","DEVERA SER FORNECIDO A LOCADORA",
                                                   "COPIAS DO RG, CIC E HABILITACAO",
                                                   "DO(S) SEGUNDO(S) CONDUTOR(ES).")
             #exibir valor da taxa de 2 condutor da locadora
             display by name d_cts74m00.cdtsegtaxvlr
          else
             #PSI 198390
             display " " to cdtsegtaxvlr
          end if


   before field avivclcod
          display by name d_cts74m00.avivclcod  attribute (reverse)

   after  field avivclcod
          display by name d_cts74m00.avivclcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field cdtoutflg
          end if

          # ---> ORDENACAO DOS VEICULOS NORMAL
          let l_tipo_ordenacao = "N"

          let l_concede_ar = true

          if l_concede_ar then
             let l_tipo_ordenacao = "A"  # ---> ORDENA OS VEICULOS POR AR CONDICIONADO
          else
             let l_tipo_ordenacao = "N"  # ---> ORDENACAO DOS VEICULOS NORMAL
          end if

          if d_cts74m00.avivclcod  is null   or
             d_cts74m00.avivclcod  =  "  "   then
             error " Escolha veiculo de preferencia. Se nao disponivel sera reservado outro do grupo!"
             call ctn17c00(d_cts74m00.lcvcod,
                           d_cts74m00.aviestcod,
                           l_tipo_ordenacao,
                           g_documento.ciaempcod,
                           d_cts74m00.avialgmtv,
                           "")

                  returning d_cts74m00.avivclcod

             next field avivclcod

          end if

          select lcvcod   , avivclmdl,
                 avivcldes, avivclgrp,
                 avivclstt,
                 frqvlr, isnvlr, rduvlr                #PSI 198390
            into ws.lcvcod   , ws.avivclmdl,
                 ws.avivcldes, d_cts74m00.avivclgrp,
                 ws.avivclstt,
                 d_cts74m00.frqvlr,                    #PSI 198390
                 d_cts74m00.isnvlr,                    #PSI 198390
                 d_cts74m00.rduvlr                     #PSI 198390
            from datkavisveic
           where lcvcod    = d_cts74m00.lcvcod
             and avivclcod = d_cts74m00.avivclcod

          if sqlca.sqlcode = notfound  then
             error " Veiculo nao cadastrado !"
             next field avivclcod
          end if

          if d_cts74m00.lcvcod <> ws.lcvcod then
             error " Este veiculo nao esta' disponivel nesta locadora!"
             next field avivclcod
          end if

          if ws.avivclstt <> "A"  then
             error " Veiculo CANCELADO nao pode ser reservado!"
             next field avivclcod
          end if

          let d_cts74m00.avivclvlr = 0
          let d_cts74m00.locsegvlr = 0


          select lcvvcldiavlr, lcvvclsgrvlr
            into d_cts74m00.avivclvlr,
                 d_cts74m00.locsegvlr
            from datklocaldiaria
           where lcvcod       = d_cts74m00.lcvcod
             and avivclcod    = d_cts74m00.avivclcod
             and lcvlojtip    = ws.lcvlojtip
             and lcvregprccod = ws.lcvregprccod
             and w_cts74m00.aviretdat between  datklocaldiaria.viginc
             and                               datklocaldiaria.vigfnl
             and 1                    between  datklocaldiaria.fxainc
             and                               datklocaldiaria.vigfnl

          if d_cts74m00.avivclvlr is null   or
             d_cts74m00.avivclvlr  = 0      then
             error " Valor de diaria nao cadastrado! Selecione outro veiculo ou loja."
             next field lcvextcod
          end if

          let d_cts74m00.avivcldes = ws.avivclmdl clipped," (",
                                     ws.avivcldes clipped,")"
          let d_cts74m00.vcldiavlr = d_cts74m00.avivclvlr + d_cts74m00.locsegvlr



          if d_cts74m00.isnvlr is not null and
             d_cts74m00.isnvlr <> 0 then
             call cts08g01("I",
                           "N",
                           "LOCADORA OFERECE TAXA DIARIA DE ",
                           "ISENCAO NA PARTICIPACAO EM CASO ",
                           "DE SINISTRO. ",
                           d_cts74m00.isnvlr)

                   returning ws.confirma
          end if

          if d_cts74m00.rduvlr is not null and
             d_cts74m00.rduvlr <> 0 then

             call cts08g01("I",
                           "N",
                           "LOCADORA OFERECE TAXA DIARIA DE ",
                           "REDUCAO NA PARTICIPACAO EM CASO ",
                           "DE SINISTRO. ",
                           d_cts74m00.rduvlr)

                  returning ws.confirma
          end if


          display by name d_cts74m00.avivcldes
          display by name d_cts74m00.vcldiavlr
          display by name d_cts74m00.avivclgrp
          display by name d_cts74m00.frqvlr
          display by name d_cts74m00.isnvlr
          display by name d_cts74m00.rduvlr



          initialize ws.msgtxt to null

          if w_cts74m00.clsflg =  FALSE    or
             w_cts74m00.clsflg is null     then
             if d_cts74m00.locsegvlr is not null  and
                d_cts74m00.locsegvlr > 0          then
                let ws.msgtxt = "   VALOR SEGURO AO DIA: R$ ",d_cts74m00.locsegvlr using "<<<<&.&&"

                call cts08g01("I","N","TAXA DE PROTECAO NAO INCLUSO NO ",
                                      "VALOR DA DIARIA. ", "", ws.msgtxt)
                     returning ws.confirma
             else

                call cts08g01("I","N","","TAXA DE PROTECAO INCLUSO NO ",
                                         "VALOR DA DIARIA. ","")
                     returning ws.confirma

             end if
          end if

          if (d_cts74m00.avivclgrp <> "A"  and     #Veiculo nao basico
              (d_cts74m00.frqvlr = 0 or
               d_cts74m00.frqvlr is null)) then

               call cts08g01("I","N","",
                             "PARTICIPACAO OBRIGATORIA EM CASO DE ",
                             "SINISTRO ATE O LIMITE DE 10% DO VALOR ",
                             "DE MERCADO DO AUTOMOVEL LOCADO ")
                 returning ws.confirma
          end if
          # para Azul so veiculo Basico
          if (d_cts74m00.avivclgrp = "A"  and
             (d_cts74m00.frqvlr    = 0    or
              d_cts74m00.frqvlr is null)) then
             call cts08g01("I","N","",
                           "EM CASO DE SINISTRO HA UMA           ",
                           "PARTICIPACAO DE R$ 800,00","")
                  returning ws.confirma
          end if

          if d_cts74m00.cauchqflg = "S" then
             if d_cts74m00.avivclgrp = "A" or
                d_cts74m00.avivclgrp = "B" then
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

          let d_cts74m00.frmflg = "N"
          let w_cts74m00.atdfnlflg = "N"
          display by name d_cts74m00.frmflg
          next field aviproflg

   before field frmflg
          if mr_geral.atdsrvnum is null  and
             mr_geral.atdsrvano is null  then
             let d_cts74m00.frmflg = "N"
             display by name d_cts74m00.frmflg attribute (reverse)
          else
             if w_cts74m00.atdfnlflg = "S"  then
                call cts11g00(w_cts74m00.lignum)

                if ws.pgtflg = true  then
                   let int_flag = true
                   exit input
                else
                   next field aviproflg
                end if
             else
                exit input
             end if
          end if

   after  field frmflg
          display by name d_cts74m00.frmflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field avivclcod
          end if

          if d_cts74m00.frmflg is null  or
            (d_cts74m00.frmflg <> "S"   and
             d_cts74m00.frmflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field frmflg
          end if

          if d_cts74m00.frmflg = "S"  then
             call cts02m05(8) returning w_cts74m00.atddat,
                                        w_cts74m00.atdhor,
                                        w_cts74m00.funmat,
                                        w_cts74m00.cnldat,
                                        w_cts74m00.atdfnlhor,
                                        w_cts74m00.c24opemat,
                                        ws.pstcoddig

             if w_cts74m00.atddat    is null  or
                w_cts74m00.atdhor    is null  or
                w_cts74m00.funmat    is null  or
                w_cts74m00.cnldat    is null  or
                w_cts74m00.atdfnlhor is null  or
                w_cts74m00.c24opemat is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let w_cts74m00.atdfnlflg = "S"
             let w_cts74m00.atdetpcod =  4
          else
             let w_cts74m00.atdfnlflg = "N"
          end if

   before field aviproflg
          display by name d_cts74m00.aviproflg attribute (reverse)

   after  field aviproflg
          display by name d_cts74m00.aviproflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if mr_geral.atdsrvnum is null  then
                next field frmflg
             else
                next field avivclcod
             end if
          end if

          if d_cts74m00.aviproflg is null  or
            (d_cts74m00.aviproflg <> "S"   and
             d_cts74m00.aviproflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field aviproflg
          end if

           if d_cts74m00.aviproflg = "S"      and
            (g_documento.atdsrvnum is null   or
             g_documento.atdsrvano is null)  then
             error " Nao e' possivel prorrogar uma reserva nao realizada!"
             next field aviproflg
          end if

          if d_cts74m00.aviproflg = "S"  then

          let m_reenvio = true
             call cts15m05(mr_geral.atdsrvnum,
                           mr_geral.atdsrvano,
                           d_cts74m00.lcvcod,
                           d_cts74m00.aviestcod ,
                           ws.endcep        ,
                           d_cts74m00.avialgmtv ,
                           d_cts74m00.dtentvcl,
                           d_cts74m00.avivclgrp,
                           d_cts74m00.lcvsinavsflg)
             returning w_cts74m00.procan,
                       w_cts74m00.aviprodiaqtd

             if w_cts74m00.procan = "P" then
                if w_cts74m00.aviprodiaqtd is null or
                   w_cts74m00.aviprodiaqtd =  0    then
                   select aviprodiaqtd
                       into w_cts74m00.aviprodiaqtd
                       from datmprorrog
                      where atdsrvnum = mr_geral.atdsrvnum
                        and atdsrvano = mr_geral.atdsrvano
                end if
             end if
          else
             if d_cts74m00.frmflg = "S"  then
                call cts15m04("F"                 , d_cts74m00.avialgmtv,
                              d_cts74m00.aviestcod, w_cts74m00.aviretdat,
                              w_cts74m00.avirethor, w_cts74m00.aviprvent,
                              d_cts74m00.lcvcod   ,
                              ws.endcep           , d_cts74m00.dtentvcl  )
                    returning w_cts74m00.aviretdat, w_cts74m00.avirethor,
                              w_cts74m00.aviprvent, ws.cct, ws.cct, ws.cct

             end if
          end if

          if w_cts74m00.aviretdat   is null    or
             w_cts74m00.avirethor   is null    or
             w_cts74m00.aviprvent   is null    then
             error " Data/hora da retirada e dias de utilizacao devem ser informados!"
             next field aviproflg
          end if

   before field smsenvdddnum
          display by name d_cts74m00.smsenvdddnum  attribute (reverse)

   after field smsenvdddnum
          display by name d_cts74m00.smsenvdddnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field aviproflg
          end if


   before field smsenvcelnum
          display by name d_cts74m00.smsenvcelnum  attribute (reverse)

   after field smsenvcelnum
          display by name d_cts74m00.smsenvcelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left") then
             next field smsenvdddnum
          end if

          if (d_cts74m00.smsenvcelnum  is null      or
             d_cts74m00.smsenvcelnum  = "   "    ) and
             d_cts74m00.smsenvcelnum is not null   then
             error " Informe o celular para confirmacao da reserva"
             next field smsenvcelnum
          end if


   before field cttdddcod
          display by name d_cts74m00.cttdddcod  attribute (reverse)

   after  field cttdddcod
          display by name d_cts74m00.cttdddcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field smsenvcelnum
          end if

          if d_cts74m00.cttdddcod  is null    or
             d_cts74m00.cttdddcod  = "   "    then
             error " Informe o DDD do telefone para confirmacao da reserva"
             next field cttdddcod
          end if

   before field ctttelnum
          display by name d_cts74m00.ctttelnum  attribute (reverse)

   after  field ctttelnum
          display by name d_cts74m00.ctttelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left") then
             next field cttdddcod
          end if

          if d_cts74m00.ctttelnum  is null    or
             d_cts74m00.ctttelnum  = "   "    then
             error " Informe o telefone de contato para confirmacao da reserva"
             next field ctttelnum
          end if

   before field atdlibflg
          display by name d_cts74m00.atdlibflg  attribute (reverse)

   after  field atdlibflg
          display by name d_cts74m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field ctttelnum
          end if

          if ((d_cts74m00.atdlibflg  is null)  or
              (d_cts74m00.atdlibflg <> "S"     and
               d_cts74m00.atdlibflg <> "N"))   then
             error " Informacao sobre liberacao deve ser (S)im ou (N)ao!"
             next field atdlibflg
          else
             if d_cts74m00.atdlibflg = "N"  then
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
         if d_cts74m00.c24astcod is not null then
            call ctc58m00_vis(d_cts74m00.c24astcod)
         end if
      end if

   on key (F3)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if d_cts74m00.vclloctip  =  3  or
            d_cts74m00.vclloctip  =  4  then
            if mr_geral.atdsrvnum is not null  and
               mr_geral.atdsrvano is not null  then
               call cts15m08(d_cts74m00.vclloctip,
                             w_cts74m00.slcemp,
                             w_cts74m00.slcsuccod,
                             w_cts74m00.slcmat,
                             w_cts74m00.slccctcod,
                             "C" )               #--> (A)tualiza/(C)onsulta
                   returning w_cts74m00.slcemp,
                             w_cts74m00.slcsuccod,
                             w_cts74m00.slcmat,
                             w_cts74m00.slccctcod,
                             ws.nomeusu    #-> neste caso nome funcionari
            end if
         end if
      end if

   on key (F4)

      call cts74m00_opcoes()

   on key (F5)

      if g_documento.prpnum_flg = "INC" or  g_documento.prpnum_flg is null and
         g_documento.acao = "INC" then
         error "Funcionalidade Indisponivel no momento da Inclusao!" sleep 3
      else
         let cty27g00_ret = 0
         call cty27g00_consiste_ast(d_cts74m00.c24astcod)
              returning cty27g00_ret
         if cty27g00_ret = 1 then
            let l_confirma = cts08g01( "C","S","",
                                       "DESEJA ALTERAR FORMA DE PAGAMENTO ?","","")
            if l_confirma  = "S" then
               let g_documento.prpnum_flg = "ALT"
            else
               let g_documento.prpnum_flg = "CON"
            end if
            call cty27g00_entrada_dados(g_documento.prpnum,
                                        g_documento.atdsrvnum,
                                        g_documento.atdsrvano)
            let g_documento.prpnum_flg = ""
         else
            error "Funcionalidade Indisponivel Assunto!" sleep 3
         end if
      end if
     on key (F6)

      if mr_geral.atdsrvnum is null then
         call cts10m02(hist_cts74m00.*) returning hist_cts74m00.*
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

            call cts74m00_acionamento(mr_geral.atdsrvnum,
                                      mr_geral.atdsrvano,
                                      d_cts74m00.lcvcod,
                                      d_cts74m00.aviestcod,0,'')
         end if
      end if

   on key (F8)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if mr_geral.atdsrvnum is null then
            error " Consulta as informacoes de retirada somente apos digitacao do servico!"
         else
            call cts15m04("C"                 , d_cts74m00.avialgmtv,
                          d_cts74m00.aviestcod, w_cts74m00.aviretdat,
                          w_cts74m00.avirethor, w_cts74m00.aviprvent,
                          d_cts74m00.lcvcod   , ws.endcep
                        , d_cts74m00.dtentvcl)
                returning w_cts74m00.aviretdat, w_cts74m00.avirethor,
                          w_cts74m00.aviprvent, ws.cct, ws.cct, ws.cct
         end if
      end if

   on key (F9)
      if mr_geral.acao <> 'SIN' or mr_geral.acao is null then
         if mr_geral.atdsrvnum is null then
            error " Servico nao cadastrado!"
         else
           if d_cts74m00.atdlibflg = "N"   then
              error " Servico nao liberado!"
            else
              if d_cts74m00.lcvcod     is null   or
                 d_cts74m00.aviestcod  is null   then
                 error " Locadora/loja para retirada de veiculo nao informada!" sleep 2
              else
                 call cts15m01(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                               d_cts74m00.lcvcod    , d_cts74m00.aviestcod ,
                               d_cts74m00.avialgmtv )
              end if
            end if
         end if
      end if

   on key (control-e)

     let lr_email.c24astcod = g_documento.c24astcod
     let lr_email.ligcvntip = g_documento.ligcvntip
     let lr_email.lignum    = g_documento.lignum
     let lr_email.atdsrvnum = g_documento.atdsrvnum
     let lr_email.atdsrvano = g_documento.atdsrvano
     let lr_email.solnom    = g_documento.solnom
     let lr_email.ramcod    = g_documento.ramcod
     call figrc072_setTratarIsolamento() -- > psi 223689
     call cts30m00(lr_email.ramcod   , lr_email.c24astcod,
                   lr_email.ligcvntip, lr_email.succod,
                   lr_email.aplnumdig, lr_email.itmnumdig,
                   lr_email.lignum   , lr_email.atdsrvnum,
                   lr_email.atdsrvano, lr_email.prporg,
                   lr_email.prpnumdig, lr_email.solnom)
          returning l_envio
          if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
             error "Função cts30m00 insdisponivel no momento ! Avise a Informatica !" sleep 2
             return
          else
             error "E-mail enviado com sucesso."
          end if        -- > 223689
 end input

 if int_flag then
    error " Operacao cancelada!"
 end if

end function



#-----------------------------------------------------------------------------
 function cts74m00_salvaglobal(param)
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
       let slv_segurado.psscntcod     = mr_geral.psscntcod

       -------------[ mesma rotina de inicializacao do cta00m01 ]-------------
       initialize g_dctoarray         to null
       initialize mr_geral.succod     to null
       initialize mr_geral.ramcod     to null
       initialize mr_geral.aplnumdig  to null
       initialize mr_geral.itmnumdig  to null
       initialize mr_geral.edsnumref  to null
       initialize mr_geral.fcapacorg  to null
       initialize mr_geral.fcapacnum  to null
       initialize mr_geral.psscntcod  to null
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
       let mr_geral.psscntcod      = slv_segurado.psscntcod
    end if
 end function

#--------------------------------------#
 function cts74m00_acionamento(lr_param)
#--------------------------------------#

   define lr_param record
                   atdsrvnum  like datmservico.atdsrvnum
                  ,atdsrvano  like datmservico.atdsrvano
                  ,lcvcod     like datklocadora.lcvcod
                  ,aviestcod  like datmavisrent.aviestcod
                  ,atdetpcod  like datmsrvint.atdetpcod
                  ,etpmtvcod  like datksrvintmtv.etpmtvcod
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

   define l_maides like datkavislocal.maides

   define l_prestador decimal(10,0)
         ,l_retorno   smallint
         ,l_flag      smallint
         ,l_sissgl    char(10)
         ,l_etapa     like datmsrvacp.atdetpcod

   define lr_erro record
          sqlcode smallint,
          mens    char(80)
   end record


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

   if g_documento.acao = "CAN" or
      g_documento.acao = "ALT" then
      let m_reenvio = true
   end if

   #Se prestador nao esta conectado na Internet ou ele recebe por fax, enviar laudo por fax
   if l_flag = false or lr_ctc30g00.acntip = 2 then #Fax

      if lr_param.lcvcod = 2 and
         m_reenvio = false   then

          call ctx28g00_stt_listener_locadora()
               returning lr_erro.sqlcode,lr_erro.mens


          if lr_erro.sqlcode = 0 then
             # Chama webservice Localiza

             call cts74m00_webservice(lr_param.atdsrvnum, lr_param.atdsrvano)
                  returning lr_erro.sqlcode,lr_erro.mens
             if lr_erro.sqlcode <> 0 then
                error lr_erro.mens sleep 2
                call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
             else
               error "Reserva enviada com sucesso !" sleep 2
             end if
          else
            call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
          end if
      else
         call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
      end if

   else

      if g_issk.funmat = 13020 then
         call cts15m14_email(lr_param.atdsrvnum
                            ,lr_param.atdsrvano
                            ,"amiltonlourenco.pinto@correioporto" ,'T','','') #Para identificar Internet
      end if

      if (l_etapa = 5 and lr_etapa.atdetpcod > 1) or
          l_etapa = 43 or lr_ctc30g00.acntip is null then
          #Enviar o laudo da reserva para o email da loja/locadora
          call cts15m14_email(lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,l_maides ,'T','','') #Para identificar Internet
      end if

   end if

 end function

#===================================================
function cts74m00_webservice(lr_param)
#===================================================

  define lr_param record
         atdsrvnum like datmservico.atdsrvnum
        ,atdsrvano like datmservico.atdsrvano
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
         l_motivo    like datmavisrent.avialgmtv,
         l_datadvlhs char(30)



  initialize lr_datmavisrent.* to null
  initialize lr_reserva.* to null
  initialize lr_erro.* to null
  initialize lr_cts15m16.* to null

  let l_datahs   = null
  let l_datadvlhs   = null
  let l_data     = null
  let l_hor      = null

  if m_cts74m00_prep is null or
     m_cts74m00_prep = false then
     call cts74m00_prepara()
  end if


  call cts15m16(lr_param.*)
       returning lr_cts15m16.msg1,lr_cts15m16.msg2

 open ccts74m00035 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano

 whenever error continue
 fetch ccts74m00035 into lr_datmavisrent.lcvcod ,lr_datmavisrent.aviestcod   ,lr_datmavisrent.aviretdat
                         ,lr_datmavisrent.avirethor, lr_datmavisrent.aviprvent
                         ,lr_datmavisrent.avirsrgrttip, lr_datmavisrent.cdtoutflg,l_motivo
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
    else
       error 'Erro SELECT ccts74m00035 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'cts74m00 / cts74m00_webservice() / ',lr_param.atdsrvnum,' / '
                                                  ,lr_param.atdsrvano sleep 1
    end if

 end if


 open ccts74m00034 using lr_datmavisrent.lcvcod,
                         lr_datmavisrent.aviestcod
 whenever error continue
 fetch ccts74m00034 into lr_reserva.vclretagncod,
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

let l_data = lr_datmavisrent.aviretdat + lr_datmavisrent.aviprvent units day
let l_hor  = lr_datmavisrent.avirethor
let l_datadvlhs = l_data,
                  " ",
                  l_hor



 let lr_reserva.vclrethordat = l_datahs clipped
 let lr_reserva.vcldvlhordat = l_datadvlhs clipped
 let lr_reserva.vcldvlagncod = lr_reserva.vclretagncod
 let lr_reserva.vclloccdrtxt = lr_datmavisrent.cdtoutflg
 let lr_reserva.vclretagncod = lr_reserva.vclretagncod
 let lr_reserva.vcldvlufdcod = lr_reserva.vclretufdcod
 let lr_reserva.vcldvlcidnom = lr_reserva.vclretcidnom
 let lr_reserva.atzdianum    = lr_datmavisrent.aviprvent
 let lr_reserva.loccautip    = lr_datmavisrent.avirsrgrttip
 let lr_reserva.vclloccdrtxt = lr_cts15m16.msg1," ",lr_cts15m16.msg2

 if lr_datmavisrent.cdtoutflg = "S" then
    let lr_reserva.vclcdtsgnindtxt = 'PARA ESTA LOCACAO HAVERA SEGUNDO(S) CONDUTOR(ES)'
 end if

 if l_motivo = 5 then
    let  lr_reserva.atzdianum   = 0
 end if


 call ctd31g00_ins_reserva(lr_param.atdsrvnum,        # numero Servico
                           lr_param.atdsrvano,        # Ano do Servico
                           "",                        # Tipo de Envio de Confirmação
                           1,                         # Codigo status da Reserva
                           lr_reserva.atzdianum,      # numero de diarias autorizadas
                           lr_reserva.loccautip,      # Locacao isenta de caucao
                           lr_reserva.vclretagncod,   # Agencia da retirada do veiculo
                           lr_reserva.vclrethordat,   #
                           lr_reserva.vclretufdcod,   # Codigo UF de retirada do veiculo
                           lr_reserva.vclretcidnom,   # Nome Cidade de retirada do veiculo
                           lr_reserva.vcldvlagncod,   # Codigo Agencia da devolucao do veiculo
                           lr_reserva.vcldvlhordat,   # Data hora da devolucao do veiculo
                           lr_reserva.vcldvlufdcod,   # Codigo UF de devolucao do veiculo
                           lr_reserva.vcldvlcidnom,   # Nome Cidade de devolucao do veiculo
                           d_cts74m00.smsenvdddnum,   # DDD para envio de SMS
                           d_cts74m00.smsenvcelnum,   # Numero celular para envio de SMS
                           lr_reserva.envemades   ,   # Email para envio de confirmacao
                           lr_reserva.vclloccdrtxt,   # Observações da locação
                           lr_reserva.vclcdtsgnindtxt,# Nome do segundo condutor
                           g_documento.succod,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig,
                           0,
                           g_documento.ramcod,
                           g_documento.edsnumref,
                           g_documento.ciaempcod)#lr_funapol.dctnumseq) # ultima situacao da apolice
      returning lr_erro.sqlcode,lr_erro.mens

  if lr_erro.sqlcode <> 0 then
     let lr_erro.mens = "Erro <",lr_erro.sqlcode clipped,"> na função ctd31g00_ins_reserva, Avise a Informatica !"
     call errorlog(lr_erro.mens)
  end if


  return lr_erro.sqlcode,lr_erro.mens

end function

#-----------------------------------------------
function cts74m00_popup_garantia()
#-----------------------------------------------

   define lr_popup record
         titulo  char(100),
         opcoes  char(1000)
  end record


  let lr_popup.titulo = 'Garantia'

    if d_cts74m00.avialgmtv = 5 then
       let lr_popup.opcoes = "Cartao de Credito|Cheque Caucao|Isencao de Garantia"
    else
       let lr_popup.opcoes = "Cartao de Credito|Cheque Caucao"
    end if

  while true

     call ctx14g01(lr_popup.titulo,lr_popup.opcoes)
          returning m_opcao,d_cts74m00.garantia

     if m_opcao is not null and
        m_opcao <> 0 then
        exit while
     end if

  end while
  case m_opcao

    when 1

     let d_cts74m00.cauchqflg = "N"
     let d_cts74m00.flgarantia = "S"

    when 2
       let d_cts74m00.cauchqflg = "S"
       let d_cts74m00.flgarantia = "S"

    when 3
       let d_cts74m00.cauchqflg = "N"
       let d_cts74m00.flgarantia = "S"
   end case

end function

#-----------------------------------------------
function cts74m00_dados_locacao()
#-----------------------------------------------

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





   open window cts15m17 at 09,17 with form "cts15m17"
                 attribute (form line 1, border)

     display by name lr_retorno.rsvlclcod              # Localizador


      while true

      prompt "(F17)Abandona" attribute(reverse) for prompt_key


       on key (interrupt)
       close window cts15m17
       exit while

      end prompt
  end while



end function

#---------------------------------#
 function cts74m00_opcoes()
#---------------------------------#

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_zero            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,w_ret             integer


 ###  Montar popup com as opcoes


  let l_popup  = "Localizador|Sinistro|Motivos|Prorrogacao"


 let l_par1   = "FUNCOES"
 let l_nulo   = null

 while true

    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1, l_popup)
         returning l_opcao, l_descricao

    if l_opcao = 0 then
       exit while
    end if

    ### Tratamento para cada opcao

    if l_opcao =  1 then  # Localizador

       if d_cts74m00.lcvcod = 2 then
         call cts74m00_dados_locacao()
      else
         let m_cts08g01 = cts08g01("A"
                                   ,"N"
                                   ,"ESTA RESERVA FOI ENCAMINHADA VIA FAX."
                                   ,"A FUNCAO LOCALIZADOR E EXCUSIVA "
                                   ,"PARA RESERVAS ENCAMINHADAS VIA ONLINE"
                                   ,"")
      end if
    end if

    if l_opcao =  2 then  # Sinistro
       call cts74m00_dados_sinistro()
    end if

    if l_opcao =  3 then  # Motivos
       call cts74m00_motivos_reserva()
    end if

    if l_opcao = 4 then # Prorrogacao
       call cts15m05(mr_geral.atdsrvnum,
                mr_geral.atdsrvano,
                d_cts74m00.lcvcod,
                d_cts74m00.aviestcod ,
                "",
                d_cts74m00.avialgmtv ,
                d_cts74m00.dtentvcl,
                d_cts74m00.avivclgrp,
                d_cts74m00.lcvsinavsflg)
        returning w_cts74m00.procan,
                  w_cts74m00.aviprodiaqtd
     end if

 end while

end function

#-----------------------------------------------
function cts74m00_dados_sinistro()
#-----------------------------------------------

  define lr_dados record
         sindat            like datmavisrent.sindat,
         prcnum            like datmavisrent.prcnum,
         prccnddes         like datmavisrent.prccnddes,
         itaofinom         like datmavisrent.itaofinom
  end record

  define prompt_key char (01)

  if m_cts74m00_prep is null or
     m_cts74m00_prep = false then
     call cts74m00_prepara()
  end if



  initialize lr_dados.* to null

  whenever error continue
     open c_cts74m00_038 using g_documento.atdsrvnum,
                               g_documento.atdsrvano
     fetch c_cts74m00_038 into lr_dados.sindat
                              ,lr_dados.prcnum
                              ,lr_dados.prccnddes
                              ,lr_dados.itaofinom
  whenever error stop


  if lr_dados.sindat is null then
     error " Não foram localizados dados do processo PSS! "
  else
     open window cts64m02 at 07,14 with form "cts64m02"
                 attribute (form line 1, border)

          display by name  lr_dados.sindat       # Data do Sinistro
                          ,lr_dados.prcnum       # Numero do processo
                          ,lr_dados.prccnddes    # Condição do processo
                          ,lr_dados.itaofinom    # Oficina
           while true

                prompt "(F17)Abandona" attribute(reverse) for prompt_key

                 on key (interrupt)
                 close window cts64m02
                 exit while

                end prompt
            end while
  end if

end function

#-----------------------------------------------
function cts74m00_motivos_reserva()
#-----------------------------------------------

define lr_motivos record
       itarsrcaomtvcod  like datrvcllocrsrcmp.itarsrcaomtvcod
       ,rsrprvdiaqtd    like datrvcllocrsrcmp.rsrprvdiaqtd
       ,rsrutidiaqtd    like datrvcllocrsrcmp.rsrutidiaqtd
end record

define t_motivos array[10] of record
       itarsrcaomtvcod  like datrvcllocrsrcmp.itarsrcaomtvcod
      ,itarsrcaomtvdes  like datkitarsrcaomtv.itarsrcaomtvdes
      ,rsrutidiaqtd     like datrvcllocrsrcmp.rsrutidiaqtd

end record



define l_index    integer,
       totdiarias integer

for l_index = 1 to 10
    initialize t_motivos[l_index].* to null
end for

let l_index = 0
let totdiarias = 0

whenever error continue
  open c_cts74m00_039 using g_documento.atdsrvnum,
                            g_documento.atdsrvano
  foreach c_cts74m00_039 into  lr_motivos.itarsrcaomtvcod,
                               lr_motivos.rsrprvdiaqtd,
                               lr_motivos.rsrutidiaqtd

      if lr_motivos.itarsrcaomtvcod is not null then
         let l_index = l_index + 1
         let t_motivos[l_index].itarsrcaomtvcod = lr_motivos.itarsrcaomtvcod
         call cts64m10_busca_descricao(t_motivos[l_index].itarsrcaomtvcod)
              returning t_motivos[l_index].itarsrcaomtvdes
         let t_motivos[l_index].rsrutidiaqtd    = lr_motivos.rsrutidiaqtd
         let totdiarias = totdiarias +  t_motivos[l_index].rsrutidiaqtd
      end if
   end foreach

whenever error stop


   open window w_cts74m00a at 07,4 with form "cts74m00a"
              attribute(form line 1, border)

   let int_flag = false

   message "  (F17)Abandona "

   call set_count(l_index)

   display by name totdiarias

   display array t_motivos to s_cts74m00a.*

      on key (interrupt,control-c,f17)
            exit display

   end display

   close window  w_cts74m00a

   let int_flag = false

end function

#-------------------------------------------------------------------------------
 function cts74m00_inclui_motivos_complementares(l_atdsrvnum , l_atdsrvano)
#-------------------------------------------------------------------------------
define  l_saldo        integer
define  l_index        smallint
define  l_dias_utiliz  integer
define  l_dias_prev    integer
define  l_atdsrvnum    like datmservico.atdsrvnum
define  l_atdsrvano    like datmservico.atdsrvano

    let l_saldo = w_cts74m00.aviprvent
    for l_index = 1 to 10

        if am_motivos[l_index].itarsrcaomtvcod is not null then

          if l_saldo > 0 then
             call cts64m01_calcula_dias_motivo(am_motivos[l_index].itarsrcaomtvcod,
                                               am_motivos[l_index].dialimqtd,
                                               l_saldo)
               returning l_dias_utiliz
                       , l_dias_prev
                       , l_saldo

display ' l_atdsrvnum                         : ', l_atdsrvnum
display ' l_atdsrvano                         : ', l_atdsrvano
display ' am_motivos[l_index].itarsrcaomtvcod : ', am_motivos[l_index].itarsrcaomtvcod
display ' l_dias_prev                         : ', l_dias_prev
display ' l_dias_utiliz                       : ', l_dias_utiliz
display ' am_motivos[l_index].dialimqtd       : ', am_motivos[l_index].dialimqtd
display '------------------------------------------------------------'


             whenever error continue
               execute p_cts74m00_037 using l_atdsrvnum
                                          , l_atdsrvano
                                          , am_motivos[l_index].itarsrcaomtvcod
                                          , l_dias_prev
                                          , l_dias_utiliz
                                          , am_motivos[l_index].dialimqtd
             whenever error stop
          end if

        end if
    end for

end function
#-----------------------------------------------
function cts74m00_popup_motivos()
#-----------------------------------------------

   define lr_retorno record
          coderro smallint
         ,mens    char(400)
   end record

   define l_motivos char(400)
         ,l_cabec   char(60)
         ,l_opcao   like datmavisrent.avialgmtv

   let l_motivos  = null
   let l_cabec    = "Motivos"
   let l_opcao    = null



    if d_cts74m00.c24astcod = "P88" or
       d_cts74m00.c24astcod = "P89" then
         if ((d_cts74m00.avialgmtv  is null) or
             (d_cts74m00.avialgmtv  <> 1     and
              d_cts74m00.avialgmtv  <> 2     and
              d_cts74m00.avialgmtv  <> 3     and
              d_cts74m00.avialgmtv  <> 4     and
              d_cts74m00.avialgmtv  <> 5     and
              d_cts74m00.avialgmtv  <> 8     and
              d_cts74m00.avialgmtv  <> 9     and
              d_cts74m00.avialgmtv  <> 0     and
              d_cts74m00.avialgmtv  <> 13    and
              d_cts74m00.avialgmtv  <> 14    ))   then

              if d_cts74m00.c24astcod = 'P89' then
                 let l_motivos = "3 - Beneficio Oficinas|5 - Particular"
              else
                 let l_motivos = "2 - Porto Socorro|3 - Beneficio Oficinas|4 - Departamentos|5 - Particular|9 - Indenizacao Integral"
              end if


         end if
    else
       if ((d_cts74m00.avialgmtv is null) or
           (d_cts74m00.avialgmtv <> 4   and
            d_cts74m00.avialgmtv <> 5   and
            d_cts74m00.avialgmtv <> 6   and
            d_cts74m00.avialgmtv <> 7)) then
            let l_motivos = "4 - Departamentos|5 - Particular|6 - Terceiro Segurado Porto"
       end if
    end if

    call ctx14g01_carro_extra(l_cabec, l_motivos)
         returning l_opcao

return l_opcao

end function
