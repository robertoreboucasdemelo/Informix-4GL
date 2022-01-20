#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts60m00                                                   #
#Analista Resp : Roberto Reboucas                                           #
#                Tela de Guincho para a apolices Itau                       #
#...........................................................................#
#Desenvolvimento: Amilton Pinto                                             #
#Liberacao      : 25/01/2011                                                #
#---------------------------------------------------------------------------#
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
#Data       Autor Fabrica  Origem     Alteracao                             #
#---------- -------------- ---------- --------------------------------------#
#27/03/2012 Ivan, BRQ  PSI-2011-22603 Projeto alteracao cadastro de destino #
#---------------------------------------------------------------------------#
# 16/06/2013 Humberto Santos                                                #
#                                            Inclusao dos assuntos KVB/IVB  #
#---------------------------------------------------------------------------#
#10/12/2013  Rodolfo   PSI-2013-      Inlcusao da nova regulacao via AW     #
#            Massini   12097PR                                              #
#---------------------------------------------------------------------------#
# 11/08/2014 Fabio, Fornax PSI2013-00440 Adequacoes para regulacao AW       #
#---------------------------------------------------------------------------#
# 13/05/2014 RobertoFornax            PJ                                    #
#---------------------------------------------------------------------------#
# 06/05/2016 Alberto Chamado 1018771                                        #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_segurado record
        nome        char(60),
        cgccpf      char(20),
        pessoa      char(01),
        dddfone     char(04),
        numfone     char(15),
        email       char(100)
 end record

 define mr_corretor record
        susep       char(06),
        nome        char(50),
        dddfone     char(04),
        numfone     char(15),
        dddfax      char(04),
        numfax      char(15),
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

 define mr_is       record
        casco       decimal(10,5),
        blindagem   decimal(10,5),
        dm          decimal(10,5),
        dp          decimal(10,5),
        morte       decimal(10,5),
        invalidez   decimal(10,5),
        dmh         decimal(10,5),
        franquia    decimal(10,5)
 end record

 define d_cts60m00    record
    servico           char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    cornom            like datmservico.cornom      ,
    corsus            like datmservico.corsus      ,
    cvnnom            char (19)                    ,
    vclcoddig         like datmservico.vclcoddig   ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcordes         char (11)                    ,
    c24astcod         like datkassunto.c24astcod   ,
    c24astdes         char (45)                    ,
    refasstxt         char (24)                    ,
    desapoio          char (17)                    ,
    camflg            char (01)                    ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    dstflg            char (01)                    ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    imdsrvflg         char (01)                    ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    prsloccab         char (11)                    ,
    prslocflg         char (01)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    srvprlflg         like datmservico.srvprlflg   ,
    frmflg            char (01)                    ,
    atdtxt            char (48)                    ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    sinvitflg         like datmservicocmp.sinvitflg,
    bocflg            like datmservicocmp.bocflg   ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    vcllibflg         like datmservicocmp.vcllibflg
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

 define w_cts60m00    record
    atdvcltip         like datmservico.atdvcltip   ,
    vclcorcod         like datmservico.vclcorcod   ,
    vclcordes         char (11)                    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    lignum            like datrligsrv.lignum       ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    data              like datmservico.atddat      ,
    hora              like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    c24opemat         like datmservico.c24opemat   ,
    atdprscod         like datmservico.atdprscod   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    vclcamtip         like datmservicocmp.vclcamtip,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgflg         like datmservicocmp.vclcrgflg,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    ctgtrfcod         like abbmcasco.ctgtrfcod     ,
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    socvclcod         like datmservico.socvclcod   ,
    asiofndigflg      like datkasitip.asiofndigflg ,
    vclcndlclflg      like datkasitip.vclcndlclflg
 end record

 define w_hist record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define a_cts60m00    array[3] of record
    operacao          char (01)
   ,lclidttxt         like datmlcl.lclidttxt
   ,lgdtxt            char (65)
   ,lgdtip            like datmlcl.lgdtip
   ,lgdnom            like datmlcl.lgdnom
   ,lgdnum            like datmlcl.lgdnum
   ,brrnom            like datmlcl.brrnom
   ,lclbrrnom         like datmlcl.lclbrrnom
   ,endzon            like datmlcl.endzon
   ,cidnom            like datmlcl.cidnom
   ,ufdcod            like datmlcl.ufdcod
   ,lgdcep            like datmlcl.lgdcep
   ,lgdcepcmp         like datmlcl.lgdcepcmp
   ,lclltt            like datmlcl.lclltt
   ,lcllgt            like datmlcl.lcllgt
   ,dddcod            like datmlcl.dddcod
   ,lcltelnum         like datmlcl.lcltelnum
   ,lclcttnom         like datmlcl.lclcttnom
   ,lclrefptotxt      like datmlcl.lclrefptotxt
   ,c24lclpdrcod      like datmlcl.c24lclpdrcod
   ,ofnnumdig         like sgokofi.ofnnumdig
   ,emeviacod         like datmemeviadpt.emeviacod
   ,celteldddcod      like datmlcl.celteldddcod
   ,celtelnum         like datmlcl.celtelnum
   ,endcmp            like datmlcl.endcmp
 end record

  define a_cts60m00_bkp array[1] of record
    operacao          char (01)
   ,lclidttxt         like datmlcl.lclidttxt
   ,lgdtxt            char (65)
   ,lgdtip            like datmlcl.lgdtip
   ,lgdnom            like datmlcl.lgdnom
   ,lgdnum            like datmlcl.lgdnum
   ,brrnom            like datmlcl.brrnom
   ,lclbrrnom         like datmlcl.lclbrrnom
   ,endzon            like datmlcl.endzon
   ,cidnom            like datmlcl.cidnom
   ,ufdcod            like datmlcl.ufdcod
   ,lgdcep            like datmlcl.lgdcep
   ,lgdcepcmp         like datmlcl.lgdcepcmp
   ,lclltt            like datmlcl.lclltt
   ,lcllgt            like datmlcl.lcllgt
   ,dddcod            like datmlcl.dddcod
   ,lcltelnum         like datmlcl.lcltelnum
   ,lclcttnom         like datmlcl.lclcttnom
   ,lclrefptotxt      like datmlcl.lclrefptotxt
   ,c24lclpdrcod      like datmlcl.c24lclpdrcod
   ,ofnnumdig         like sgokofi.ofnnumdig
   ,emeviacod         like datmemeviadpt.emeviacod
   ,celteldddcod      like datmlcl.celteldddcod
   ,celtelnum         like datmlcl.lcltelnum
   ,endcmp            like datmlcl.endcmp
 end record

 define m_hist_cts60m00_bkp   record
        hist1         like datmservhist.c24srvdsc,
        hist2         like datmservhist.c24srvdsc,
        hist3         like datmservhist.c24srvdsc,
        hist4         like datmservhist.c24srvdsc,
        hist5         like datmservhist.c24srvdsc
 end record

 define f4            record
    acao              char(3),
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define arr_aux       smallint
 define w_retorno     smallint
 define m_acesso_ind  smallint
 define m_grava_hist  smallint
 define m_cappstcod   like avgkcappst.cappstcod

 define aux_libant    like datmservico.atdlibflg,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano,
        aux_libhor    char (05)                 ,
        aux_today     char (10)                 ,
        aux_hora      char (05)                 ,
        aux_ano       char (02)                 ,
        cpl_atdsrvnum like datmservico.atdsrvnum,
        cpl_atdsrvano like datmservico.atdsrvano,
        cpl_atdsrvorg like datmservico.atdsrvorg,
        ws_cgccpfnum  like aeikcdt.cgccpfnum    ,
        ws_cgccpfdig  like aeikcdt.cgccpfdig    ,
        ws_mtvcaps    smallint
       ,ws_desc_1     char(40)
       ,ws_desc_2     char(40)
       ,ws_clscod     like aackcls.clscod

 define m_prep_sql    smallint

 define m_aciona        char(01)
 define m_outrolaudo    smallint
 define m_srv_acionado  smallint
 define m_c24lclpdrcod  like datmlcl.c24lclpdrcod
 define m_multiplo    char(1)
 define l_atdsrvnum_mult   like datmservico.atdsrvnum
 define l_atdsrvano_mult   like datmservico.atdsrvano
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

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define l_cappstcod  like avgkcappst.cappstcod
       ,l_stt        smallint
       ,l_handle     integer

 define am_param   record
       c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
      ,c24pbmgrpdes  like datkpbmgrp.c24pbmgrpdes
      ,c24pbmcod     like datkpbm.c24pbmcod
      ,atddfttxt     like datkpbm.c24pbmdes
      ,asitipcod     like datmservico.asitipcod
 end record

 define mr_retorno record
       erro    smallint
      ,mens    char(100)
 end record

 define m_limites_plano record
   pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
   socqlmqtd     like datkitaasipln.socqlmqtd    ,
   erro          integer                         ,
   mensagem      char(50)
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

 #--------------------------#
 function cts60m00_prepare()
 #--------------------------#

 define l_sql    char(500)

 let     l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts60m00_001 from l_sql
 declare c_cts60m00_001 cursor for p_cts60m00_001

 let l_sql = " select asitipcod ",
            " from datkpbm ",
           " where c24pbmcod = ? "
 prepare pcts60m00003 from l_sql
 declare ccts60m00003 cursor for pcts60m00003


 let l_sql = " update datmservico set c24opemat = null",
             " where atdsrvnum = ? ",
             " and atdsrvano = ? "
 prepare pcts60m00004 from l_sql

 let l_sql =  "select atdetpcod                          "
             ,"  from datmsrvacp                         "
             ," where atdsrvnum = ?                      "
             ,"   and atdsrvano = ?                      "
             ,"   and atdsrvseq = (select max(atdsrvseq) "
             ,"                      from datmsrvacp     "
             ,"                     where atdsrvnum = ?  "
             ,"                       and atdsrvano = ?) "

 prepare pcts60m00005 from l_sql
 declare ccts60m00005 cursor for pcts60m00005

 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAWATIVA' "
 prepare pcts60m00006 from l_sql
 declare ccts60m00006 cursor for pcts60m00006

 let m_prep_sql = true

 end function

#--------------------------------------------------------------------
 function cts60m00()
#--------------------------------------------------------------------

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

 define ws         record
    atdetpcod       like datmsrvacp.atdetpcod,
    vclchsinc       like abbmveic.vclchsinc,
    vclchsfnl       like abbmveic.vclchsfnl,
    confirma        char (01)              ,
    grvflg          smallint,
    c24srvdsc       like datmservhist.c24srvdsc,
    histerr         smallint,
    imsvlr          like abbmcasco.imsvlr,
    itaasiplntipcod like datritaasiplnast.itaasiplntipcod
 end record

 define l_grlinf   like igbkgeral.grlinf
 define l_chassi char(15),
        l_anomod char(4)

 define lr_retorno record
        resultado smallint,
        mensagem  char(500)
 end record

 define l_data       date,
        l_hora2      datetime hour to minute,
        l_vclcorcod  like datmservico.vclcorcod,
        l_resultado  smallint,
        l_mensagem   char(80),
        l_acesso     smallint

 define l_erro     smallint,
        l_i        smallint

 initialize m_rsrchv
          , m_altcidufd
          , m_altdathor
          , m_operacao
          , m_agncotdat
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant to null

 let l_grlinf     = null
 let l_vclcorcod  = null
 let l_resultado  = null
 let l_mensagem   = null
 let l_i          = null
 let ws_desc_1    = null
 let ws_desc_2    = null
 let ws_clscod    = null
 let l_chassi        = null
 let l_anomod        = null

 initialize mr_veiculo.* to null
 initialize mr_segurado.* to null
 initialize mr_corretor.* to null
 initialize mr_is.* to null
 initialize l_cappstcod , l_stt to null
 initialize m_subbairro to null
 initialize lr_retorno.* to null


 initialize  ws.*  to  null
 initialize mr_geral.* to null

 let m_c24lclpdrcod = null

 let lr_parametro.atdsrvnum        = g_documento.atdsrvnum
 let lr_parametro.atdsrvano        = g_documento.atdsrvano
 let lr_parametro.ligcvntip        = g_documento.ligcvntip
 let lr_parametro.succod           = g_documento.succod
 let lr_parametro.ramcod           = g_documento.ramcod
 let lr_parametro.aplnumdig        = g_documento.aplnumdig
 let lr_parametro.itmnumdig        = g_documento.itmnumdig
 let lr_parametro.acao             = g_documento.acao
 let lr_parametro.prporg           = g_documento.prporg
 let lr_parametro.prpnumdig        = g_documento.prpnumdig
 let lr_parametro.c24astcod        = g_documento.c24astcod
 let lr_parametro.solnom           = g_documento.solnom
 let lr_parametro.atdsrvorg        = g_documento.atdsrvorg
 let lr_parametro.edsnumref        = g_documento.edsnumref
 let lr_parametro.fcapacorg        = g_documento.fcapacorg
 let lr_parametro.fcapacnum        = g_documento.fcapacnum
 let lr_parametro.lignum           = g_documento.lignum
 let lr_parametro.soltip           = g_documento.soltip
 let lr_parametro.c24soltipcod     = g_documento.c24soltipcod
 let lr_parametro.lclocodesres     = g_documento.lclocodesres

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

 let m_outrolaudo = 0
 let m_srv_acionado = false
 initialize f4.* to null

 call cts40g03_data_hora_banco(2)
      returning l_data,
                l_hora2

 let int_flag  = false
 let aux_today = l_data
 let aux_hora  = l_hora2
 let aux_ano   = aux_today[9,10]

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts60m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false

 whenever error continue
 open ccts60m00006
 fetch ccts60m00006 into m_agendaw

 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR

 open window cts60m00 at 04,02 with form "cts60m00"
    attribute(form line 1)

 display "ITAU AUTO" to msg_azul attribute(reverse)

 if mr_geral.atdsrvnum is null then
    display
    "(F1)Help (F3)Refer (F5)Espelho (F6)Hist (F7)Funcoes (F8)Destino (F9)Copia"
    to msgfun
 else
    display
    "(F1)Help(F3)Refer(F4)Apoio(F5)Espelho(F6)Hist(F7)Funcoes(F8)Dest(F9)Conclui"
    to msgfun
 end if

 initialize d_cts60m00.*,
            w_cts60m00.*,
            aux_libant  ,
            cpl_atdsrvnum,
            cpl_atdsrvano,
            cpl_atdsrvorg,
            a_cts60m00_bkp,
            m_hist_cts60m00_bkp to null

 for l_i = 1 to 3
    let a_cts60m00[l_i].operacao     = null
    let a_cts60m00[l_i].lclidttxt    = null
    let a_cts60m00[l_i].lgdtxt       = null
    let a_cts60m00[l_i].lgdtip       = null
    let a_cts60m00[l_i].lgdnom       = null
    let a_cts60m00[l_i].lgdnum       = null
    let a_cts60m00[l_i].brrnom       = null
    let a_cts60m00[l_i].lclbrrnom    = null
    let a_cts60m00[l_i].endzon       = null
    let a_cts60m00[l_i].cidnom       = null
    let a_cts60m00[l_i].ufdcod       = null
    let a_cts60m00[l_i].lgdcep       = null
    let a_cts60m00[l_i].lgdcepcmp    = null
    let a_cts60m00[l_i].lclltt       = null
    let a_cts60m00[l_i].lcllgt       = null
    let a_cts60m00[l_i].dddcod       = null
    let a_cts60m00[l_i].lcltelnum    = null
    let a_cts60m00[l_i].lclcttnom    = null
    let a_cts60m00[l_i].lclrefptotxt = null
    let a_cts60m00[l_i].c24lclpdrcod = null
    let a_cts60m00[l_i].ofnnumdig    = null
    let a_cts60m00[l_i].emeviacod    = null
    let a_cts60m00[l_i].celteldddcod = null
    let a_cts60m00[l_i].celtelnum    = null
    let a_cts60m00[l_i].endcmp       = null


 end for

 let w_cts60m00.ligcvntip  =  mr_geral.ligcvntip

 if g_documento.aplnumdig is not null then

    call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
               returning m_limites_plano.pansoclmtqtd,
                         m_limites_plano.socqlmqtd,
                         m_limites_plano.erro,
                         m_limites_plano.mensagem

 end if


 if g_documento.atdsrvnum is null then
    if mr_geral.c24astcod = "I30" or
       mr_geral.c24astcod = "I31" or
       mr_geral.c24astcod = "I32" or
       mr_geral.c24astcod = "IR2" or
       mr_geral.c24astcod = "IAP" or
       mr_geral.c24astcod = "IAC" or
       mr_geral.c24astcod = "IVB" then # CRIADO PELO YURI P.SOCORRO
       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO I30 - Assistencia
       call cts60m00_display_I30(lr_parametro.c24astcod,
                                 d_cts60m00.c24astdes,
                                 d_cts60m00.c24pbmcod,
                                 d_cts60m00.atddfttxt,
                                 d_cts60m00.atdrsdflg)
    else # -> ASSUNTO I03
       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO I03
       call cts60m00_display_I03(lr_parametro.c24astcod,
                                 d_cts60m00.c24astdes,
                                 d_cts60m00.sinvitflg,
                                 d_cts60m00.bocflg)
    end if
 end if

 if mr_geral.atdsrvnum is not null then

    call cts60m00_consulta()

    if mr_geral.c24astcod = "I30" or
       mr_geral.c24astcod = "I31" or
       mr_geral.c24astcod = "I32" or
       mr_geral.c24astcod = "IR2" or
       mr_geral.c24astcod = "IAP" or
       mr_geral.c24astcod = "IAC" or
       mr_geral.c24astcod = "IVB" then # CRIADO PELO YURI P.SOCORRO

       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO I30
       call cts60m00_display_I30(lr_parametro.c24astcod,
                                 d_cts60m00.c24astdes,
                                 d_cts60m00.c24pbmcod,
                                 d_cts60m00.atddfttxt,
                                 d_cts60m00.atdrsdflg)
    else
       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO I03
       call cts60m00_display_I03(lr_parametro.c24astcod,
                                 d_cts60m00.c24astdes,
                                 d_cts60m00.sinvitflg,
                                 d_cts60m00.bocflg)
    end if

    let d_cts60m00.asitipabvdes = "NAO PREV"

    select asitipabvdes
      into d_cts60m00.asitipabvdes
      from datkasitip
     where asitipcod = d_cts60m00.asitipcod

    display by name d_cts60m00.servico thru d_cts60m00.bocflg
    display by name d_cts60m00.c24solnom attribute (reverse)
    if d_cts60m00.desapoio is not null then
       display by name d_cts60m00.desapoio attribute (reverse)
    end if

    if mr_geral.succod    is not null  and
       mr_geral.ramcod    is not null  and
       mr_geral.aplnumdig is not null  then

       if mr_is.blindagem <> 0 then
          # -> EXIBE ALERTA DE VEICULO BLINDADO
           let ws.confirma = cts08g01("A",
                                      "N",
                                      "",
                                      "  VEICULO BLINDADO  ",
                                      "",
                                      "")
       end if

    end if

    display by name a_cts60m00[1].lgdtxt,
                    a_cts60m00[1].lclbrrnom,
                    a_cts60m00[1].cidnom,
                    a_cts60m00[1].ufdcod,
                    a_cts60m00[1].lclrefptotxt,
                    a_cts60m00[1].endzon,
                    a_cts60m00[1].dddcod,
                    a_cts60m00[1].lcltelnum,
                    a_cts60m00[1].lclcttnom,
                    a_cts60m00[1].celteldddcod,
                    a_cts60m00[1].celtelnum,
                    a_cts60m00[1].endcmp





    if d_cts60m00.atdlibflg = "N"   then
       display by name d_cts60m00.atdlibdat attribute (invisible)
       display by name d_cts60m00.atdlibhor attribute (invisible)
    end if

    if d_cts60m00.refasstxt is not null  then
       display by name d_cts60m00.refasstxt attribute (reverse)
    end if

    if w_cts60m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    else
       if mr_geral.aplnumdig  is not null   or
          d_cts60m00.vcllicnum   is not null   then
          call cts03g00 (1, mr_geral.ramcod   ,
                            mr_geral.succod   ,
                            mr_geral.aplnumdig,
                            mr_geral.itmnumdig,
                            d_cts60m00.vcllicnum ,
                            mr_geral.atdsrvnum,
                            mr_geral.atdsrvano)
       end if
       if d_cts60m00.srvprlflg = "S"  then
          let ws.confirma = cts08g01( "A","N","", "SERVICO PARTICULAR NAO DEVE SER" ,
                                      "PASSADO PARA FROTA PORTO SEGURO !","")
       end if
    end if

    let ws.grvflg = cts60m00_modifica()

    if ws.grvflg = false  then
       initialize g_documento.acao  to null
    end if

    if g_documento.acao is not null and
       g_documento.acao <> "INC"    then
       call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                     g_issk.funmat        , aux_today  ,aux_hora)
       let g_rec_his = true
    end if
 else

      # Verifica se o Assunto e do Tipo Terceiro

      call cty22g00_recupera_tipo_assunto(mr_geral.c24astcod)
      returning lr_retorno.resultado,
                lr_retorno.mensagem ,
                ws.itaasiplntipcod

      if g_documento.aplnumdig is not null and
         ws.itaasiplntipcod <> 8           then

       # Busca do nome do corretor
       call cty22g00_busca_nome_corretor()
            returning d_cts60m00.cornom

       let l_anomod = g_doc_itau[1].autmodano

       let d_cts60m00.nom       = g_doc_itau[1].segnom clipped
       let d_cts60m00.corsus    = g_doc_itau[1].corsus clipped
       let d_cts60m00.vclcoddig = g_doc_itau[1].porvclcod clipped
       let d_cts60m00.vclanomdl = l_anomod
       let d_cts60m00.vcllicnum = g_doc_itau[1].autplcnum clipped
       #let w_cts60m00.ctgtrfcod = null
       let d_cts60m00.vcldes    =  g_doc_itau[1].autfbrnom clipped , "-",
                                   g_doc_itau[1].autlnhnom clipped, " - "  ,
                                   g_doc_itau[1].autmodnom clipped
       let d_cts60m00.vclcordes =  g_doc_itau[1].autcornom
    end if

    # -> DESCRICAO DO VEICULO
    #let d_cts60m00.vcldes = cts15g00(d_cts60m00.vclcoddig)

    # -> COR DO VEICULO
    select cpodes
      into d_cts60m00.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = w_cts60m00.vclcorcod



    call cts02m01_ctgtrfcod(w_cts60m00.ctgtrfcod)
         returning d_cts60m00.camflg




    if mr_geral.succod    is not null  and
       mr_geral.ramcod    is not null  and
       mr_geral.aplnumdig is not null  then
       let d_cts60m00.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",
                                        " ", mr_geral.ramcod    using "&&&&",
                                        " ", mr_geral.aplnumdig using "<<<<<<<<&"
    end if

    let d_cts60m00.prsloccab = "Prs.Local.:"
    let d_cts60m00.prslocflg = "N"

    let d_cts60m00.c24astcod = mr_geral.c24astcod
    let d_cts60m00.c24solnom = mr_geral.solnom

    let d_cts60m00.c24astdes = c24geral8(d_cts60m00.c24astcod)

    display by name d_cts60m00.servico thru d_cts60m00.bocflg
    display by name d_cts60m00.c24solnom attribute (reverse)

    if d_cts60m00.desapoio is not null then
       display by name d_cts60m00.desapoio attribute (reverse)
    end if

    open c_cts60m00_001

    whenever error continue
    fetch c_cts60m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts60m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts60m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window cts60m00
          return
       end if
    end if

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------

    if (mr_geral.succod     is not null   and
        mr_geral.ramcod     is not null   and
        mr_geral.aplnumdig  is not null)  or
       (d_cts60m00.vcllicnum   is not null)  then
       call cts03g00 (1, mr_geral.ramcod   ,
                         mr_geral.succod   ,
                         mr_geral.aplnumdig,
                         mr_geral.itmnumdig,
                         d_cts60m00.vcllicnum ,
                         mr_geral.atdsrvnum,
                         mr_geral.atdsrvano)
    end if

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    let ws.grvflg = cts60m00_inclui()

    if ws.grvflg = true  then
       call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts60m00.funmat,
                     w_cts60m00.data      , w_cts60m00.hora)

       if m_multiplo = 'S' then
          call cts10g02_historico_multiplo(l_atdsrvnum_mult,
                                           l_atdsrvano_mult,
                                           aux_atdsrvnum,
                                           aux_atdsrvano,
                                           w_cts60m00.funmat,
                                           w_cts60m00.data,
                                           w_cts60m00.hora)
       end if



       ##-----------------------------------------------
       ## Verifica Acionamento servico pelo atendente
       ##-----------------------------------------------
       #if d_cts60m00.imdsrvflg =  "S"     and        # servico imediato
       #   d_cts60m00.atdlibflg =  "S"     and        # servico liberado
       #   d_cts60m00.prslocflg =  "N"     and        # prestador no local
       #   d_cts60m00.frmflg    =  "N"     and       # formulario
       #   m_aciona =  'N'                 then       # servico nao acionado auto
       #
       #   call cta00m06_acionamento(g_issk.dptsgl)
       #   returning l_acesso
       #
       #   if l_acesso = true then
       #
       #         let ws.confirma = cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
       #
       #         if ws.confirma  =  "S"   then
       #            call cts00m02(aux_atdsrvnum, aux_atdsrvano, 1 )
       #         end if
       #
       #   end if
       #end if

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = aux_atdsrvnum
          and atdsrvano = aux_atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = aux_atdsrvnum
                              and atdsrvano = aux_atdsrvano)

       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          update datmservico set c24opemat = null
                           where atdsrvnum = aux_atdsrvnum
                             and atdsrvano = aux_atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(aux_atdsrvnum,aux_atdsrvano)
          end if
       end if
    end if
 end if


 #Apaga tabela temporaria da datkvclcndlcl
 # no mommento da exibicao dos itens de local/condicao veiculo estava incorreto
 # poruq enao estava apagando a tabela temporaria
 call ctc61m02_criatmp(2,
                       aux_atdsrvnum,
                       aux_atdsrvano )
      returning l_erro

 clear form

 close window cts60m00

end function  ###  cts60m00

#--------------------------------------------------------------------
 function cts60m00_consulta()
#--------------------------------------------------------------------

 define ws         record
    atdsrvorg      like datmservico.atdsrvorg,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    vclcorcod      like datmservico.vclcorcod,
    funmat         like datmservico.funmat   ,
    empcod         like datmservico.empcod   ,
    funnom         like isskfunc.funnom      ,
    dptsgl         like isskfunc.dptsgl      ,
    sqlcode        integer,
    succod         like datrservapol.succod   ,
    ramcod         like datrservapol.ramcod   ,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    edsnumref      like datrservapol.edsnumref,
    prporg         like datrligprp.prporg,
    prpnumdig      like datrligprp.prpnumdig,
    fcapcorg       like datrligpac.fcapacorg,
    fcapacnum      like datrligpac.fcapacnum
 end record

 define promptX   char (01)
 define l_tipolaudo   smallint

 define l_confirma char(1)
       ,l_errcod   smallint
       ,l_errmsg   char(80)

 #--------------------------------------------------------------------
 # Dados do servico
 #--------------------------------------------------------------------



        let     promptX  =  null


        initialize  ws.*  to  null

        let     promptX  =  null

        initialize  ws.*  to  null
        initialize mr_retorno.* to null
        let l_confirma = null

 initialize l_errcod, l_errmsg to null

 select atdsrvorg   ,
        nom         , vclcoddig   ,
        vcldes      , vclanomdl   ,
        vcllicnum   , corsus      ,
        cornom      , vclcorcod   ,
        funmat      , empcod      ,
        atddat      , atdhor      ,
        atdlibflg   , atdlibhor   ,
        atdlibdat   , atdhorpvt   ,
        atdpvtretflg, atddatprg   ,
        atdhorprg   , asitipcod   ,
        atdrsdflg   , atddfttxt   ,
        atdfnlflg   , srvprlflg   ,
        atdvcltip   , atdprinvlcod,
        ciaempcod   , prslocflg
   into d_cts60m00.atdsrvorg,
        d_cts60m00.nom      ,
        d_cts60m00.vclcoddig,
        d_cts60m00.vcldes   ,
        d_cts60m00.vclanomdl,
        d_cts60m00.vcllicnum,
        d_cts60m00.corsus   ,
        d_cts60m00.cornom   ,
        ws.vclcorcod        ,
        ws.funmat           ,
        ws.empcod           ,
        w_cts60m00.atddat   ,
        w_cts60m00.atdhor   ,
        d_cts60m00.atdlibflg,
        d_cts60m00.atdlibhor,
        d_cts60m00.atdlibdat,
        w_cts60m00.atdhorpvt,
        w_cts60m00.atdpvtretflg,
        w_cts60m00.atddatprg,
        w_cts60m00.atdhorprg,
        d_cts60m00.asitipcod,
        d_cts60m00.atdrsdflg,
        d_cts60m00.atddfttxt,
        w_cts60m00.atdfnlflg,
        d_cts60m00.srvprlflg,
        w_cts60m00.atdvcltip,
        d_cts60m00.atdprinvlcod,
        g_documento.ciaempcod,
        d_cts60m00.prslocflg
   from datmservico
  where atdsrvnum = mr_geral.atdsrvnum and
        atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    prompt "" for char promptX
    return
 end if

 let mr_geral.atdsrvorg = d_cts60m00.atdsrvorg

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
 call ctx04g00_local_gps(mr_geral.atdsrvnum,
                         mr_geral.atdsrvano,
                         1)
               returning a_cts60m00[1].lclidttxt
                        ,a_cts60m00[1].lgdtip
                        ,a_cts60m00[1].lgdnom
                        ,a_cts60m00[1].lgdnum
                        ,a_cts60m00[1].lclbrrnom
                        ,a_cts60m00[1].brrnom
                        ,a_cts60m00[1].cidnom
                        ,a_cts60m00[1].ufdcod
                        ,a_cts60m00[1].lclrefptotxt
                        ,a_cts60m00[1].endzon
                        ,a_cts60m00[1].lgdcep
                        ,a_cts60m00[1].lgdcepcmp
                        ,a_cts60m00[1].lclltt
                        ,a_cts60m00[1].lcllgt
                        ,a_cts60m00[1].dddcod
                        ,a_cts60m00[1].lcltelnum
                        ,a_cts60m00[1].lclcttnom
                        ,a_cts60m00[1].c24lclpdrcod
                        ,a_cts60m00[1].celteldddcod
                        ,a_cts60m00[1].celtelnum
                        ,a_cts60m00[1].endcmp
                        ,ws.sqlcode
                        ,a_cts60m00[1].emeviacod

 let m_subbairro[1].lclbrrnom = a_cts60m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts60m00[1].brrnom,
                                a_cts60m00[1].lclbrrnom)
      returning a_cts60m00[1].lclbrrnom

 select ofnnumdig into a_cts60m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = mr_geral.atdsrvano
    and atdsrvnum = mr_geral.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    prompt "" for char promptX
    return
 end if

 let a_cts60m00[1].lgdtxt = a_cts60m00[1].lgdtip clipped, " ",
                            a_cts60m00[1].lgdnom clipped, " ",
                            a_cts60m00[1].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(mr_geral.atdsrvnum,
                         mr_geral.atdsrvano,
                         2)
               returning a_cts60m00[2].lclidttxt
                        ,a_cts60m00[2].lgdtip
                        ,a_cts60m00[2].lgdnom
                        ,a_cts60m00[2].lgdnum
                        ,a_cts60m00[2].lclbrrnom
                        ,a_cts60m00[2].brrnom
                        ,a_cts60m00[2].cidnom
                        ,a_cts60m00[2].ufdcod
                        ,a_cts60m00[2].lclrefptotxt
                        ,a_cts60m00[2].endzon
                        ,a_cts60m00[2].lgdcep
                        ,a_cts60m00[2].lgdcepcmp
                        ,a_cts60m00[2].lclltt
                        ,a_cts60m00[2].lcllgt
                        ,a_cts60m00[2].dddcod
                        ,a_cts60m00[2].lcltelnum
                        ,a_cts60m00[2].lclcttnom
                        ,a_cts60m00[2].c24lclpdrcod
                        ,a_cts60m00[2].celteldddcod
                        ,a_cts60m00[2].celtelnum
                        ,a_cts60m00[2].endcmp
                        ,ws.sqlcode
                        ,a_cts60m00[2].emeviacod


 let m_subbairro[2].lclbrrnom = a_cts60m00[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts60m00[2].brrnom,
                                a_cts60m00[2].lclbrrnom)
      returning a_cts60m00[2].lclbrrnom

 select ofnnumdig into a_cts60m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = mr_geral.atdsrvano
    and atdsrvnum = mr_geral.atdsrvnum
    and c24endtip = 2

 if ws.sqlcode = notfound   then
    let d_cts60m00.dstflg = "N"
 else
    if ws.sqlcode = 0   then
       let d_cts60m00.dstflg = "S"
    else
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       prompt "" for char promptX
       return
    end if
 end if

 let a_cts60m00[2].lgdtxt = a_cts60m00[2].lgdtip clipped, " ",
                            a_cts60m00[2].lgdnom clipped, " ",
                            a_cts60m00[2].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Dados complementares do servico
 #--------------------------------------------------------------------
 select rmcacpflg, vclcamtip,
        vclcrcdsc, vclcrgflg,
        vclcrgpso, sindat   ,
        sinhor,
        sinvitflg,
        bocflg,
        bocnum,
        bocemi,
        vcllibflg
   into d_cts60m00.rmcacpflg,
        w_cts60m00.vclcamtip,
        w_cts60m00.vclcrcdsc,
        w_cts60m00.vclcrgflg,
        w_cts60m00.vclcrgpso,
        d_cts60m00.sindat   ,
        d_cts60m00.sinhor   ,
        d_cts60m00.sinvitflg,
        d_cts60m00.bocflg   ,
        d_cts60m00.bocnum   ,
        d_cts60m00.bocemi   ,
        d_cts60m00.vcllibflg
   from datmservicocmp
  where atdsrvnum = mr_geral.atdsrvnum and
        atdsrvano = mr_geral.atdsrvano

 #--------------------------------------------------------------------
 # Verifica se socorro tem ASSISTENCIA A PASSAGEIRO relacionada.
 #--------------------------------------------------------------------
 declare ccts60m00002  cursor for
    select datmservico.atdsrvorg     ,
           datmassistpassag.atdsrvnum,
           datmassistpassag.atdsrvano
      from DATMASSISTPASSAG,
           DATMSERVICO
     where datmassistpassag.refatdsrvnum = mr_geral.atdsrvnum
       and datmassistpassag.refatdsrvano = mr_geral.atdsrvano
       and datmservico.atdsrvnum = datmassistpassag.atdsrvnum
       and datmservico.atdsrvano = datmassistpassag.atdsrvano
     order by atdsrvnum, atdsrvano

 foreach ccts60m00002 into ws.atdsrvorg,
                       ws.atdsrvnum,
                       ws.atdsrvano
 end foreach

 if ws.atdsrvnum is null  or
    ws.atdsrvano is null  then
    initialize d_cts60m00.refasstxt to null
 else
    let d_cts60m00.refasstxt = "ASS.PASSAG. ", ws.atdsrvorg using "&&",
                                          "/", ws.atdsrvnum using "&&&&&&&",
                                          "-", ws.atdsrvano using "&&"
 end if

 let w_cts60m00.lignum = cts20g00_servico(mr_geral.atdsrvnum, mr_geral.atdsrvano)

 call cts20g01_docto(w_cts60m00.lignum)
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


   let g_documento.succod    = mr_geral.succod
   let g_documento.ramcod    = mr_geral.ramcod
   let g_documento.aplnumdig = mr_geral.aplnumdig
   let g_documento.itmnumdig = mr_geral.itmnumdig
   let g_documento.edsnumref = mr_geral.edsnumref
   let g_documento.prporg    = mr_geral.prporg
   let g_documento.prpnumdig = mr_geral.prpnumdig
   let g_documento.fcapacorg = mr_geral.fcapacorg
   let g_documento.fcapacnum = mr_geral.fcapacnum
   let g_documento.itaciacod = mr_geral.itaciacod


 if mr_geral.succod    is not null  and
    mr_geral.ramcod    is not null  and
    mr_geral.aplnumdig is not null  then
    let d_cts60m00.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",
                                     " ", mr_geral.ramcod    using "&&&&",
                                     " ", mr_geral.aplnumdig using "<<<<<<<<&"
 end if

#--------------------------------------------------------------------
# Dados da LIGACAO
#--------------------------------------------------------------------

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts60m00.c24astcod,
        w_cts60m00.ligcvntip,
        d_cts60m00.c24solnom
   from datmligacao
  where lignum = w_cts60m00.lignum

 let mr_geral.c24astcod = d_cts60m00.c24astcod

 select lignum
   from datmligfrm
  where lignum = w_cts60m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts60m00.frmflg = "N"
 else
    let d_cts60m00.frmflg = "S"
 end if

 select cpodes into d_cts60m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip" and
        cpocod = w_cts60m00.ligcvntip

 #--------------------------------------------------------------------
 # Descricao do ASSUNTO
 #--------------------------------------------------------------------
 let d_cts60m00.c24astdes = c24geral8(d_cts60m00.c24astcod)

 let d_cts60m00.servico = mr_geral.atdsrvorg using "&&",
                     "/", mr_geral.atdsrvnum using "&&&&&&&",
                     "-", mr_geral.atdsrvano using "&&"

 select cpodes
   into d_cts60m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod
    and funmat = ws.funmat

 let d_cts60m00.atdtxt = w_cts60m00.atddat        clipped, " ",
                         w_cts60m00.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)

 if w_cts60m00.atdhorpvt is not null  or
    w_cts60m00.atdhorpvt =  "00:00"   then
    let d_cts60m00.imdsrvflg = "S"
 end if

 if w_cts60m00.atddatprg is not null  then
    let d_cts60m00.imdsrvflg = "N"
 end if

 if w_cts60m00.vclcamtip is not null  and
    w_cts60m00.vclcamtip <>  " "      then
    let d_cts60m00.camflg = "S"
 else
    if w_cts60m00.vclcrgflg is not null  and
       w_cts60m00.vclcrgflg <>  " "      then
       let d_cts60m00.camflg = "S"
    else
       let d_cts60m00.camflg = "N"
    end if
 end if

 let aux_libant = d_cts60m00.atdlibflg

 if d_cts60m00.atdlibflg      = "N" then
    let d_cts60m00.atdlibdat  = w_cts60m00.atddat
    let d_cts60m00.atdlibhor  = w_cts60m00.atdhor
 end if

 select cpodes
   into d_cts60m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts60m00.atdprinvlcod

 select c24pbmcod
   into d_cts60m00.c24pbmcod
   from datrsrvpbm
  where atdsrvnum    = mr_geral.atdsrvnum
    and atdsrvano    = mr_geral.atdsrvano
    and c24pbminforg = 1
    and c24pbmseq    = 1

  #verificar se é ou se tem laudo de apoio

  if mr_geral.c24astcod <> 'IAP' then

     call cts10g00_verifica_multiplo(w_cts60m00.lignum)
          returning mr_retorno.*

     if mr_retorno.erro = 1 then
        call cts08g01("A","N",""," EXISTE UMA SOLICITACAO DE APOIO "," PARA ESSE SERVICO !","")
             returning l_confirma
     end if
  end if

  let m_c24lclpdrcod = a_cts60m00[1].c24lclpdrcod

end function  ###  cts60m00_consulta


#--------------------------------------------------------------------
 function cts60m00_modifica()
#--------------------------------------------------------------------

 define ws           record
    tabname          like systables.tabname     ,
    sqlcode          integer,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor
 end record

 define hist_cts60m00 record
    hist1    like datmservhist.c24srvdsc ,
    hist2    like datmservhist.c24srvdsc ,
    hist3    like datmservhist.c24srvdsc ,
    hist4    like datmservhist.c24srvdsc ,
    hist5    like datmservhist.c24srvdsc
 end record

 define lr_cts10g02   record
        tabname       char(20),
        errcod        smallint
 end record

 define promptX char (01)

 define l_data     date,
        l_hora2    datetime hour to minute
       ,l_errcod   smallint
       ,l_errmsg   char(80)

 initialize l_errcod, l_errmsg  to null

        let     promptX  =  null

        initialize  ws.*  to  null

        initialize  hist_cts60m00.*  to  null

        initialize  lr_cts10g02.*  to  null

        let     promptX  =  null

        initialize  ws.*  to  null

        initialize  hist_cts60m00.*  to  null

 initialize ws.*  to null

 call cts60m00_input() returning hist_cts60m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts60m00      to null
    initialize d_cts60m00.*    to null
    initialize w_cts60m00.*    to null
    clear form
    return false
 end if

#--------------------------------------------------------------------
# Verifica solicitacao de guincho para caminhao
#--------------------------------------------------------------------
 if d_cts60m00.asitipcod = 1  or       ###  Guincho
    d_cts60m00.asitipcod = 3  then     ###  Guincho/Tecnico
    if d_cts60m00.camflg = "S"  then
       let w_cts60m00.atdvcltip = 3
    end if
 end if

 #display 'cts60m00 - Modificar atendimento'

 begin work

 update datmservico set ( nom      ,
                          corsus   ,
                          cornom   ,
                          vclcoddig,
                          vcldes   ,
                          vclanomdl,
                          vcllicnum,
                          vclcorcod,
                          atdrsdflg,
                          atdlibflg,
                          atdlibhor,
                          atdlibdat,
                          atdhorpvt,
                          atddatprg,
                          atdhorprg,
                          asitipcod,
                          srvprlflg,
                          atdpvtretflg,
                          atdvcltip,
                          atdprinvlcod,
                          prslocflg)
                      = ( d_cts60m00.nom,
                          d_cts60m00.corsus,
                          d_cts60m00.cornom,
                          d_cts60m00.vclcoddig,
                          d_cts60m00.vcldes,
                          d_cts60m00.vclanomdl,
                          d_cts60m00.vcllicnum,
                          w_cts60m00.vclcorcod,
                          d_cts60m00.atdrsdflg,
                          d_cts60m00.atdlibflg,
                          d_cts60m00.atdlibhor,
                          d_cts60m00.atdlibdat,
                          w_cts60m00.atdhorpvt,
                          w_cts60m00.atddatprg,
                          w_cts60m00.atdhorprg,
                          d_cts60m00.asitipcod,
                          d_cts60m00.srvprlflg,
                          w_cts60m00.atdpvtretflg,
                          w_cts60m00.atdvcltip,
                          d_cts60m00.atdprinvlcod,
                          d_cts60m00.prslocflg   )
                    where atdsrvnum = mr_geral.atdsrvnum  and
                          atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char promptX
    return false
 end if

 #------------------------------------------------------------------------------
 # Modifica problemas do servico
 #------------------------------------------------------------------------------
   if d_cts60m00.atdsrvorg = 1 then  # Laudo de Assistência
      call ctx09g02_altera(mr_geral.atdsrvnum ,
                           mr_geral.atdsrvano ,
                           1                  , # sequencia
                           1                  , # Org. informacao 1-Segurado 2-Pst
                           d_cts60m00.c24pbmcod,
                           d_cts60m00.atddfttxt,
                           ""                  ) # Codigo prestador
           returning ws.sqlcode,
                     ws.tabname
      if ws.sqlcode <> 0 then
         error "ctx09g02_altera", ws.sqlcode, ws.tabname
         rollback work
         prompt "" for char promptX
         return false
      end if
   end if

   if g_documento.acao is null then
      let g_documento.acao = "CON"
   end if

   call cts10g02_grava_loccnd(mr_geral.atdsrvnum,
                              mr_geral.atdsrvano)
        returning lr_cts10g02.*

   if lr_cts10g02.errcod <> 0 then
      error " Erro (", lr_cts10g02.errcod, ") na gravacao da",
            " tabela ", lr_cts10g02.tabname clipped, ". AVISE A INFORMATICA!"
      rollback work
      prompt "" for char promptX
      return false
   end if

 update datmservicocmp
    set ( rmcacpflg ,
          vclcamtip ,
          vclcrcdsc ,
          vclcrgflg ,
          vclcrgpso ,
          sindat    ,
          sinhor    ,
          sinvitflg,
          bocflg   ,
          bocnum   ,
          bocemi   ,
          vcllibflg)
      = ( d_cts60m00.rmcacpflg,
          w_cts60m00.vclcamtip,
          w_cts60m00.vclcrcdsc,
          w_cts60m00.vclcrgflg,
          w_cts60m00.vclcrgpso,
          d_cts60m00.sindat   ,
          d_cts60m00.sinhor   ,
          d_cts60m00.sinvitflg,
          d_cts60m00.bocflg   ,
          d_cts60m00.bocnum   ,
          d_cts60m00.bocemi   ,
          d_cts60m00.vcllibflg)
    where atdsrvnum = mr_geral.atdsrvnum  and
          atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos complementos do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char promptX
    return false
 end if

 for arr_aux = 1 to 2
    if a_cts60m00[arr_aux].operacao is null  then
       let a_cts60m00[arr_aux].operacao = "M"
    end if

    if  (arr_aux = 1 and d_cts60m00.frmflg = "N") or arr_aux = 2 then
        let a_cts60m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    end if

    let ws.sqlcode = cts06g07_local(a_cts60m00[arr_aux].operacao
                                   ,mr_geral.atdsrvnum
                                   ,mr_geral.atdsrvano
                                   ,arr_aux
                                   ,a_cts60m00[arr_aux].lclidttxt
                                   ,a_cts60m00[arr_aux].lgdtip
                                   ,a_cts60m00[arr_aux].lgdnom
                                   ,a_cts60m00[arr_aux].lgdnum
                                   ,a_cts60m00[arr_aux].lclbrrnom
                                   ,a_cts60m00[arr_aux].brrnom
                                   ,a_cts60m00[arr_aux].cidnom
                                   ,a_cts60m00[arr_aux].ufdcod
                                   ,a_cts60m00[arr_aux].lclrefptotxt
                                   ,a_cts60m00[arr_aux].endzon
                                   ,a_cts60m00[arr_aux].lgdcep
                                   ,a_cts60m00[arr_aux].lgdcepcmp
                                   ,a_cts60m00[arr_aux].lclltt
                                   ,a_cts60m00[arr_aux].lcllgt
                                   ,a_cts60m00[arr_aux].dddcod
                                   ,a_cts60m00[arr_aux].lcltelnum
                                   ,a_cts60m00[arr_aux].lclcttnom
                                   ,a_cts60m00[arr_aux].c24lclpdrcod
                                   ,a_cts60m00[arr_aux].ofnnumdig
                                   ,a_cts60m00[arr_aux].emeviacod
                                   ,a_cts60m00[arr_aux].celteldddcod
                                   ,a_cts60m00[arr_aux].celtelnum
                                   ,a_cts60m00[arr_aux].endcmp) # Amilton

    if ws.sqlcode is null   or
       ws.sqlcode <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.sqlcode, ") na alteracao do local de ocorrencia. AVISE A INFORMATICA!"
       else
          error " Erro (", ws.sqlcode, ") na alteracao do local de destino. AVISE A INFORMATICA!"
       end if
       rollback work
       prompt "" for char promptX
       return false
    end if
 end for

 if aux_libant <> d_cts60m00.atdlibflg  then
    if d_cts60m00.atdlibflg = "S"  then
       let w_cts60m00.atdetpcod = 1
       let ws.atdetpdat = d_cts60m00.atdlibdat
       let ws.atdetphor = d_cts60m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let w_cts60m00.atdetpcod = 2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    let w_retorno = cts10g04_insere_etapa(mr_geral.atdsrvnum,
                                          mr_geral.atdsrvano,
                                          w_cts60m00.atdetpcod,
                                          w_cts60m00.atdprscod,
                                          " ",
                                          " ",
                                          w_cts60m00.srrcoddig)

    if w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char promptX
       return false
    end if

 end if

   #-----------------------------------------------
   # Aciona Servico automaticamente
   #-----------------------------------------------
  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  #Alteracao projeto cadastro de destino
  if w_cts60m00.atdfnlflg <> "S" then

     if cts34g00_acion_auto (d_cts60m00.atdsrvorg,
                             a_cts60m00[1].cidnom,
                             a_cts60m00[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
        if not cts40g12_regras_aciona_auto (d_cts60m00.atdsrvorg,
                                            mr_geral.c24astcod,
                                            d_cts60m00.asitipcod,
                                            a_cts60m00[1].lclltt,
                                            a_cts60m00[1].lcllgt,
                                            d_cts60m00.prslocflg,
                                            d_cts60m00.frmflg,
                                            mr_geral.atdsrvnum,
                                            mr_geral.atdsrvano,
                                            " ",
                                            d_cts60m00.vclcoddig,
                                            d_cts60m00.camflg) then
           #servico nao pode ser acionado automaticamente
        else
           let m_aciona = 'S'
        end if
     end if

  end if

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(mr_geral.atdsrvnum,
                             mr_geral.atdsrvano)

 # PSI-2013-00440PR
 if m_agendaw = true
    then
    if m_operacao = 1  # ALT, gerou nova cota, baixa
       then
       #display 'Baixar cota atual na alteracao: ', m_rsrchv clipped
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
          #display 'Liberar cota anterior na alteracao'
          call ctd41g00_liberar_agenda(g_documento.atdsrvano
                                      ,g_documento.atdsrvnum
                                      ,m_agncotdatant
                                      ,m_agncothorant)
       end if
    end if
 end if
 # PSI-2013-00440PR

 #Projeto alteracao cadastro de destino
 if m_grava_hist then
    call cts60m00_grava_historico()
 end if

 return true

end function

#-------------------------------------------------------------------------------
 function cts60m00_inclui()
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
        atdtip          like datmservico.atdtip    ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        c24txtseq       like datmservhist.c24txtseq,
        vclatmflg       smallint                   ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq
 end record

  define hist_cts60m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define l_data         date,
        l_hora2        datetime hour to minute,
        l_cambio_auto  char(03),
        l_doc_handle   integer,
        l_confirma     char(1),
        l_atdsrvnum    like datmservico.atdsrvnum,
        l_atdsrvano    like datmservico.atdsrvano

 define l_vclcndlclcod   like datrcndlclsrv.vclcndlclcod

 define l_ret       smallint,
        l_mensagem  char(60),
        l_txtsrv    char (15),
        l_reserva_ativa smallint # Flag para idenitficar se reserva esta ativa
       ,l_errcod        smallint
       ,l_errmsg        char(80)

 initialize l_errcod, l_errmsg to null

        initialize  ws_mtvcaps  to  null

        initialize hist_cts60m00.* to null

        let l_cambio_auto = null
        let l_doc_handle  = null
        let l_atdsrvnum   = null
        let l_atdsrvano   = null
        let l_txtsrv      = null
        let l_ret         = null

 initialize l_reserva_ativa to null

 #display 'cts60m00 - Incluir atendimento'

 while true

   initialize ws.*  to null
   #display "<1868> cts60m00-> d_cts60m00.c24astcod <",d_cts60m00.c24astcod,">"
   if  d_cts60m00.c24astcod      = "I30" or
       d_cts60m00.c24astcod      = "I31" or
       d_cts60m00.c24astcod      = "I32" or
       d_cts60m00.c24astcod      = "IR2" or
       d_cts60m00.c24astcod      = "IAC" or
       d_cts60m00.c24astcod      = "IAP" or
       d_cts60m00.c24astcod      = "IVB" then # CRIADO POR YURI P.SOCORRO
       let d_cts60m00.atdsrvorg  = 1     # Laudo de Assistência
       let g_documento.atdsrvorg = 1
       let ws.atdtip = "3"
   else
       #display "<1880> cts60m00-> g_documento.atdsrvorg <",g_documento.atdsrvorg,">"   	
       if d_cts60m00.c24astcod = "IPT" then
       	  let d_cts60m00.atdsrvorg  = 5  # Laudo de sinistro
          let g_documento.atdsrvorg = 5
       else 
          let d_cts60m00.atdsrvorg  = 4  # Laudo de sinistro
          let g_documento.atdsrvorg = 4
       end if 
       let ws.atdtip = "1"
       #display "<1889> cts60m00-> g_documento.atdsrvorg <",g_documento.atdsrvorg,">" 
       #display "<1890> cts60m00-> d_cts60m00.atdsrvorg  <",d_cts60m00.atdsrvorg,">"
   end if

   let g_documento.acao = "INC"
   let ws_mtvcaps       = 0 ---> Campo utilizado para gravar o motivo da
                            ---> recusa em levar o veiculo para CAPS p/

   call cts60m00_input() returning hist_cts60m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts60m00      to null
       initialize d_cts60m00.*    to null
       initialize w_cts60m00.*    to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts60m00.data is null  then
       let w_cts60m00.data   = aux_today
       let w_cts60m00.hora   = aux_hora
       let w_cts60m00.funmat = g_issk.funmat
   end if

   if  d_cts60m00.frmflg = "S"  then
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

   if  w_cts60m00.atdfnlflg is null  then
       let w_cts60m00.atdfnlflg = "N"
       let w_cts60m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

   #----------------------------------------------------------------------------
   # Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO(NO XML DA APOLICE)
   #----------------------------------------------------------------------------
   if mr_veiculo.automatico = "SIM" then
      let ws.vclatmflg = 1
   else
      let ws.vclatmflg = null
   end if

   #------------------------------------------------------------------------------
   # Quando o guincho nao for pequeno, atribui a flag de cambio
   # automatico ( 1->tem / null->nao tem ) (?????)
   #------------------------------------------------------------------------------
   if  w_cts60m00.atdvcltip <> 2  then
       let w_cts60m00.atdvcltip = ws.vclatmflg
   end if

   #------------------------------------------------------------------------------
   # Verifica solicitacao de guincho para caminhao
   #------------------------------------------------------------------------------
   if  d_cts60m00.asitipcod = 1  or       ###  Guincho
       d_cts60m00.asitipcod = 3  then     ###  Guincho/Tecnico
       if  d_cts60m00.camflg = "S"  then
           let w_cts60m00.atdvcltip = 3
       end if
   end if

   call cts60m00_grava_dados(ws.*,hist_cts60m00.*)
        returning l_ret
                 ,l_mensagem
                 ,aux_atdsrvnum
                 ,aux_atdsrvano


   if l_ret <> 1 then
       error l_mensagem
    else
       if m_multiplo = 'S' then

         call cts60m00_desbloqueia_servico(aux_atdsrvnum,aux_atdsrvano)

         let l_atdsrvnum = aux_atdsrvnum
         let l_atdsrvano = aux_atdsrvano

         if ((g_documento.lignum is not null and
                 g_documento.lignum <> 0)       or
                (g_lignum_dcr       is not null and
                 g_lignum_dcr       <> 0))      and
               g_documento.atdnum is not null and
               g_documento.atdnum <> 0        then
               for i = 1 to 3

                  let l_ret = null
                  let l_mensagem  = null

                  begin work

                  if (g_documento.lignum is not null and
                      g_documento.lignum <> 0)       then
                      if (g_documento.atdnum is not null and
                          g_documento.atdnum <> 0 ) then

                          call ctd25g00_insere_atendimento(g_documento.atdnum
                                                          ,g_documento.lignum)
                               returning l_ret
                                        ,l_mensagem
                      end if
                  else
                      if (g_documento.atdnum is not null and
                          g_documento.atdnum <> 0 )      and
                         (g_lignum_dcr is not null       and
                          g_lignum_dcr <>       0)       then

                          call ctd25g00_insere_atendimento(g_documento.atdnum
                                                          ,g_lignum_dcr)
                               returning l_ret
                                        ,l_mensagem
                      end if
                  end if

                  if l_ret = 0 then
                     commit work
                     exit for
                  else
                     rollback work
                  end if
               end for
            end if

         let mr_geral.c24astcod = 'IAP'
         let d_cts60m00.c24pbmcod = am_param.c24pbmcod
         let d_cts60m00.atddfttxt = am_param.atddfttxt
         let d_cts60m00.asitipcod = am_param.asitipcod
         let d_cts60m00.atdsrvorg = 1

         call cts60m00_grava_dados(ws.*,hist_cts60m00.*)
            returning l_ret, l_mensagem, l_atdsrvnum_mult,
                l_atdsrvano_mult
         if l_ret <> 1 then
            error l_mensagem
         end if

         call cts60m00_desbloqueia_servico(l_atdsrvnum_mult,l_atdsrvano_mult)

         let aux_atdsrvnum = l_atdsrvnum
         let aux_atdsrvano = l_atdsrvano

       end if
   end if

   call cts60m00_desbloqueia_servico(l_atdsrvnum_mult,l_atdsrvano_mult)

   # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao
   #                    ainda ativa e fazer a baixa da chave no AW
   let l_txtsrv = "SRV ", aux_atdsrvnum, "-", aux_atdsrvano

   if m_agendaw = true
      then
      if m_operacao = 1  # obteve chave de regulacao
         then
         if l_ret = 1  # sucesso na gravacao do servico
            then
            call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa

            if l_reserva_ativa = true
               then
               #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW'
               call ctd41g00_baixar_agenda(m_rsrchv, aux_atdsrvano ,aux_atdsrvnum)
                    returning l_errcod, l_errmsg
            else
               #display "Chave de regulacao inativa, selecione agenda novamente"
               error "Chave de regulacao inativa, selecione agenda novamente"

               let m_operacao = 0

               # obter a chave de regulacao no AW
               call cts02m08(w_cts60m00.atdfnlflg,
                             d_cts60m00.imdsrvflg,
                             m_altcidufd,
                             d_cts60m00.prslocflg,
                             w_cts60m00.atdhorpvt,
                             w_cts60m00.atddatprg,
                             w_cts60m00.atdhorprg,
                             w_cts60m00.atdpvtretflg,
                             m_rsrchv,
                             m_operacao,
                             "",
                             a_cts60m00[1].cidnom,
                             a_cts60m00[1].ufdcod,
                             "",   # codigo de assistencia, nao existe no Ct24h
                             d_cts60m00.vclcoddig,
                             w_cts60m00.ctgtrfcod,
                             d_cts60m00.imdsrvflg,
                             a_cts60m00[1].c24lclpdrcod,
                             a_cts60m00[1].lclltt,
                             a_cts60m00[1].lcllgt,
                             g_documento.ciaempcod,
                             g_documento.atdsrvorg,
                             d_cts60m00.asitipcod,
                             "",   # natureza somente RE
                             "")   # sub-natureza somente RE
                   returning w_cts60m00.atdhorpvt,
                             w_cts60m00.atddatprg,
                             w_cts60m00.atdhorprg,
                             w_cts60m00.atdpvtretflg,
                             d_cts60m00.imdsrvflg,
                             m_rsrchv,
                             m_operacao,
                             m_altdathor

               display by name d_cts60m00.imdsrvflg

               if m_operacao = 1
                  then
                  #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW - apos nova chave'
                  call ctd41g00_baixar_agenda(m_rsrchv, aux_atdsrvano ,aux_atdsrvnum)
                       returning l_errcod, l_errmsg
               end if
            end if

            if l_errcod = 0
               then
               call cts02m08_ins_cota(m_rsrchv, aux_atdsrvnum, aux_atdsrvano)
                    returning l_errcod, l_errmsg

               #if l_errcod = 0
               #   then
               #   display 'cts02m08_ins_cota gravou com sucesso'
               #else
               #   display 'cts02m08_ins_cota erro ', l_errcod
               #   display l_errmsg clipped
               #end if
            else
               #display 'cts60m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
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

            call ctd41g00_liberar_agenda(aux_atdsrvano, aux_atdsrvnum
                                       , m_agncotdat, m_agncothor)
         end if
      end if
   end if
   # PSI-2013-00440PR

   #------------------------------------------------------------------------------
   # Exibe o numero do servico
   #------------------------------------------------------------------------------
   let d_cts60m00.servico = d_cts60m00.atdsrvorg using "&&",
                            "/", aux_atdsrvnum   using "&&&&&&&",
                            "-", aux_atdsrvano   using "&&"
   display d_cts60m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER! "
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso! "
   let ws.retorno = true

   # Verifica se deseja o envio de SMS
   let l_confirma = "N"

   if d_cts60m00.frmflg <> "S" and
      d_cts60m00.prslocflg <> 'S' and
      g_documento.c24astcod <> 'IR2' and
      a_cts60m00[1].celtelnum is not null then
      let l_confirma = "N"
      let l_confirma = cts08g01_confirma("A",
                                         "F ",
                                         "CLIENTE DESEJA RECEBER A CONFIRMACAO",
                                         " DO ACIONAMENTO, VIA SMS ?",
                                         "",
                                         "")
      #if l_confirma = "S" then
      #   call  ctb85g02_envia_msg(3,aux_atdsrvnum,aux_atdsrvano  )
      #        returning mr_retorno.erro
      #                 ,mr_retorno.mens
      #end if
   end if

   #======================================
   # Grava flag de envio de email
   #======================================

   call cts10g02_atualiza_flg_email(aux_atdsrvnum,
                                    aux_atdsrvano,
                                    l_confirma)
        returning mr_retorno.erro
                 ,mr_retorno.mens

   if mr_retorno.erro <> 0 then
      error mr_retorno.mens
   end if

   if g_documento.atdsrvorg = 4 then
     let l_confirma = "N"
     let l_confirma =   cts08g01_6l_confirma("A",
                                 "F",
                                 "INFORME A NECESSIDADE DO AVISO DE",
                                 "SINISTRO ATENDIMENTO ITAU SEGUROS  ",
                                 "RESOLVE TODOS OS DIAS DAS 06:00 AS 00:00",
                                 "----------------------------------------",
                                 "ACEITOU A TRANSFERENCIA ? ",
                                 "")

     if l_confirma = "S" then
         call cts60m00_grava_ligacao_itr(ws.*)
     end if
   end if

   exit while
 end while

 return ws.retorno

end function

#--------------------------------------------------------------------
 function cts60m00_input()
#--------------------------------------------------------------------

 define hist_cts60m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    retflg            char (01),
    prpflg            char (01),
    senhaok           char (01),
    confirma          char (01),
    blqnivcod         like datkblq.blqnivcod,
    vcllicant         like datmservico.vcllicnum,
    dtparam           char (16),
    sqlcode           integer,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    opcao             smallint,
    opcaodes          char(20),
    ofnstt            like sgokofi.ofnstt,
    rglflg            smallint
 end record

 define promptX    char (01)
 define tip_mvt       char (01)
 define tmp_flg       smallint
 define l_vclcoddig_contingencia like datmservico.vclcoddig

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_salva_nom like datmservico.nom

 define l_tipolaudo    smallint,
        l_atdsrvnum    like datmservico.atdsrvnum,
        l_atdsrvano    like datmservico.atdsrvano,
        l_aux          smallint,
        l_msg          char(50),
        l_msg1         char (50),
        l_msg2         char (50),
        l_msg3         char (50),
        l_limite       smallint,
        l_cidcod       decimal(8,0),
        l_endlgdcmp    like avgmcappstend.endlgdcmp
       ,l_lim_km       decimal (8,3)
       ,l_gchvclinchor like avgmcappsthor.gchvclinchor
       ,l_gchvcfnlhor  like avgmcappsthor.gchvcfnlhor
       ,l_acesso       smallint
       ,l_confirma     char(1)
       ,l_c24astcod    like datkassunto.c24astcod
       ,l_mensagem     char(300)
       ,l_nulo         char(1)
       ,l_erro         smallint
       ,l_atdetpcod    like datmsrvacp.atdetpcod
       ,l_status       smallint
       ,l_correntista smallint
       ,l_lgdnom       like datmlcl.lgdnom
       ,l_errcod       smallint
       ,l_errmsg       char(80)

 define lr_ctn00c02  record
        endcep       like glaklgd.lgdcep,
        endcepcmp    like glaklgd.lgdcepcmp
 end record

 define lr_retorno record
        resultado smallint,
        mensagem  char(500)
 end record

 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
 to null

 initialize l_errcod, l_errmsg to null

        let     promptX  =  null
        let     tip_mvt  =  null
        let     tmp_flg  =  null
        let     l_vclcoddig_contingencia  =  null
        let     l_msg  =  null
        let     l_limite  =  null
        let     l_lim_km  =  0
        let     l_gchvclinchor = null
        let     l_gchvcfnlhor  = null
        let     l_mensagem = null
        let     l_nulo = null
        let     l_atdetpcod = null
        let     l_status = null
        let     l_lgdnom = null

        initialize lr_ctn00c02.* to null
        initialize  hist_cts60m00.*  to  null

        initialize  ws.*  to  null

 let     promptX  =  null

 initialize  hist_cts60m00.*  to  null

 initialize  ws.*  to  null

 initialize ws.*  to null

 let m_grava_hist = false
 let m_cappstcod  = null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let ws.dtparam        = l_data using "yyyy-mm-dd"
 let ws.dtparam[12,16] = l_hora2

 let ws.vcllicant          = d_cts60m00.vcllicnum
 let d_cts60m00.srvprlflg  =  "N"

 let l_vclcoddig_contingencia = d_cts60m00.vclcoddig
 let l_salva_nom              = d_cts60m00.nom

 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if

 # situacao original do servico
 let m_imdsrvflg = d_cts60m00.imdsrvflg
 let m_cidnom = a_cts60m00[1].cidnom
 let m_ufdcod = a_cts60m00[1].ufdcod
 # PSI-2013-00440PR


 #display 'entrada do input, var null ou carregada na consulta'
 #display 'd_cts60m00.imdsrvflg :', d_cts60m00.imdsrvflg
 #display 'a_cts60m00[1].cidnom :', a_cts60m00[1].cidnom
 #display 'a_cts60m00[1].ufdcod :', a_cts60m00[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant

 input by name d_cts60m00.nom         ,
               d_cts60m00.corsus      ,
               d_cts60m00.cornom      ,
               d_cts60m00.vclcoddig   ,
               d_cts60m00.vclanomdl   ,
               d_cts60m00.vcllicnum   ,
               d_cts60m00.vclcordes   ,
               d_cts60m00.frmflg      ,
               d_cts60m00.camflg      ,
               d_cts60m00.c24pbmcod   ,
               d_cts60m00.atddfttxt   ,
               a_cts60m00[1].lgdtxt   ,
               a_cts60m00[1].lclbrrnom,
               a_cts60m00[1].cidnom   ,
               a_cts60m00[1].ufdcod   ,
               a_cts60m00[1].lclrefptotxt,
               a_cts60m00[1].endzon   ,
               a_cts60m00[1].dddcod   ,
               a_cts60m00[1].lcltelnum,
               a_cts60m00[1].lclcttnom,
               d_cts60m00.sindat      ,
               d_cts60m00.sinhor      ,
               d_cts60m00.atdrsdflg   ,
               d_cts60m00.sinvitflg   ,
               d_cts60m00.bocflg      ,
               d_cts60m00.asitipcod   ,
               d_cts60m00.dstflg      ,
               d_cts60m00.rmcacpflg   ,
               d_cts60m00.atdprinvlcod,
               d_cts60m00.prslocflg   ,
               d_cts60m00.atdlibflg   ,
               d_cts60m00.imdsrvflg
        without defaults


   before field nom
          display by name d_cts60m00.nom        attribute (reverse)

          if mr_geral.atdsrvnum   is not null   and
             mr_geral.atdsrvano   is not null   and
             d_cts60m00.camflg       =  "S"        and
             (w_cts60m00.atdfnlflg    =  "N" or w_cts60m00.atdfnlflg = "A") then
             call cts02m01(w_cts60m00.ctgtrfcod,
                           mr_geral.atdsrvnum,
                           mr_geral.atdsrvano,
                           w_cts60m00.vclcrgflg, w_cts60m00.vclcrgpso,
                           w_cts60m00.vclcamtip, w_cts60m00.vclcrcdsc)
                 returning w_cts60m00.vclcrgflg, w_cts60m00.vclcrgpso,
                           w_cts60m00.vclcamtip, w_cts60m00.vclcrcdsc
          end if

   after  field nom
          display by name d_cts60m00.nom


          if g_documento.acao = "CON" then
             error " Servico sendo consultado, nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                  returning ws.confirma

             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03("S"                 ,
                              d_cts60m00.imdsrvflg,
                              w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg)
                    returning w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg
             else
                call cts02m08("S"                 ,
                              d_cts60m00.imdsrvflg,
                              m_altcidufd,
                              d_cts60m00.prslocflg,
                              w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts60m00[1].cidnom,
                              a_cts60m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts60m00.vclcoddig,
                              w_cts60m00.ctgtrfcod,
                              d_cts60m00.imdsrvflg,
                              a_cts60m00[1].c24lclpdrcod,
                              a_cts60m00[1].lclltt,
                              a_cts60m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts60m00.atdsrvorg,
                              d_cts60m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg,
                              d_cts60m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             next field nom
          end if

          if d_cts60m00.nom is null or
             d_cts60m00.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if

          if w_cts60m00.atdfnlflg = "S"  then

              # ---> SALVA O NOME DO SEGURADO
             let d_cts60m00.nom = l_salva_nom
             display by name d_cts60m00.nom

             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                        " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                        "E INFORME AO  ** CONTROLE DE TRAFEGO **")

             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts60m00.atdfnlflg,
                              d_cts60m00.imdsrvflg,
                              w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg)
                    returning w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg
             else
                call cts02m08(w_cts60m00.atdfnlflg,
                              d_cts60m00.imdsrvflg,
                              m_altcidufd,
                              d_cts60m00.prslocflg,
                              w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts60m00[1].cidnom,
                              a_cts60m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts60m00.vclcoddig,
                              w_cts60m00.ctgtrfcod,
                              d_cts60m00.imdsrvflg,
                              a_cts60m00[1].c24lclpdrcod,
                              a_cts60m00[1].lclltt,
                              a_cts60m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts60m00.atdsrvorg,
                              d_cts60m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg,
                              d_cts60m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)

             if d_cts60m00.frmflg = "S" then
                call cts11g00(w_cts60m00.lignum)
                let int_flag = true
             end if
             exit input

          end if

   before field corsus
          display by name d_cts60m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts60m00.corsus

   before field cornom
          display by name d_cts60m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts60m00.cornom

   before field vclcoddig
          display by name d_cts60m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts60m00.vclcoddig

          # se outro processo nao obteve cat. tarifaria, obter
          if w_cts60m00.ctgtrfcod is null
             then
             # laudo auto obter cod categoria tarifaria
             call cts02m08_sel_ctgtrfcod(d_cts60m00.vclcoddig)
                  returning l_errcod, l_errmsg, w_cts60m00.ctgtrfcod
          end if

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts60m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts60m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts60m00.vclcoddig is null  or
                d_cts60m00.vclcoddig =  0     then
                let d_cts60m00.vclcoddig = agguvcl()
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts60m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

            if g_doc_itau[1].porvclcod is not null then
               call cty05g03_pesq_catgtf(g_doc_itau[1].porvclcod,
                                         l_data)
                    returning lr_retorno.resultado,
                              lr_retorno.mensagem,
                              w_cts60m00.ctgtrfcod
            else
               call cty05g03_pesq_catgtf(d_cts60m00.vclcoddig,
                                         l_data)
                    returning lr_retorno.resultado,
                              lr_retorno.mensagem,
                              w_cts60m00.ctgtrfcod
            end if

            call cts02m01_ctgtrfcod(w_cts60m00.ctgtrfcod)
                 returning d_cts60m00.camflg







             let d_cts60m00.vcldes = cts15g00(d_cts60m00.vclcoddig)

             display by name d_cts60m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts60m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts60m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.vclanomdl is null or
                d_cts60m00.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts60m00.vclcoddig, d_cts60m00.vclanomdl) = false  then
                   error " Veiculo nao consta como fabricado em ", d_cts60m00.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts60m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts60m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts60m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

        #------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------
        if mr_geral.aplnumdig   is null      and
           d_cts60m00.vcllicnum    is not null  then

           if d_cts60m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.senhaok  to null

              call cts13g00(d_cts60m00.c24astcod,
                            "", "", "", "",
                            d_cts60m00.vcllicnum,
                            "", "", "")
                   returning ws.blqnivcod, ws.senhaok
           end if

           #---------------------------------------------------------------
           # Verifica se ja' houve solicitacao de servico para apolice
           #---------------------------------------------------------------
           call cts03g00 (1, mr_geral.ramcod   ,
                             mr_geral.succod   ,
                             mr_geral.aplnumdig,
                             mr_geral.itmnumdig,
                             d_cts60m00.vcllicnum ,
                             mr_geral.atdsrvnum,
                             mr_geral.atdsrvano)
        end if

   before field vclcordes
          display by name d_cts60m00.vclcordes  attribute (reverse)

   after  field vclcordes
          display by name d_cts60m00.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.vclcordes is not null then
                let w_cts60m00.vclcordes = d_cts60m00.vclcordes[2,9]

                select cpocod into  w_cts60m00.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts60m00.vclcordes

                if sqlca.sqlcode = notfound  then
                   error " Cor fora do padrao!"
                   call c24geral4()
                        returning w_cts60m00.vclcorcod, d_cts60m00.vclcordes

                   if w_cts60m00.vclcorcod  is null   then
                      error " Cor do veiculo deve ser informado!"
                      next field vclcordes
                   else
                      display by name d_cts60m00.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts60m00.vclcorcod, d_cts60m00.vclcordes

                if w_cts60m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts60m00.vclcordes
                end if
             end if
             let d_cts60m00.frmflg = "N"
             display by name d_cts60m00.frmflg
             next field camflg
          end if

   before field frmflg
          if mr_geral.atdsrvnum is null  and
             mr_geral.atdsrvano is null  then
             let d_cts60m00.frmflg = "N"
             display by name d_cts60m00.frmflg attribute (reverse)
          else
             next field camflg
          end if

   after  field frmflg
          display by name d_cts60m00.frmflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.frmflg = "S"  then

                call cts02m05(6) returning w_cts60m00.data     ,
                                           w_cts60m00.hora     ,
                                           w_cts60m00.funmat   ,
                                           w_cts60m00.cnldat   ,
                                           w_cts60m00.atdfnlhor,
                                           w_cts60m00.c24opemat,
                                           w_cts60m00.atdprscod

                if w_cts60m00.hora      is null  or
                   w_cts60m00.data      is null  or
                   w_cts60m00.funmat    is null  or
                   w_cts60m00.cnldat    is null  or
                   w_cts60m00.atdfnlhor is null  or
                   w_cts60m00.c24opemat is null  or
                   w_cts60m00.atdprscod is null  then
                   error " Faltam dados para entrada via formulario!"
                   next field frmflg
                end if

                let d_cts60m00.atdlibhor = w_cts60m00.hora
                let d_cts60m00.atdlibdat = w_cts60m00.data
                let w_cts60m00.atdfnlflg = "S"
                let w_cts60m00.atdetpcod =  4
                let d_cts60m00.imdsrvflg    = "S"
                let w_cts60m00.atdhorpvt    = "00:00"
                let w_cts60m00.atdpvtretflg = "N"
                let d_cts60m00.atdprinvlcod =  2
                let d_cts60m00.atdlibflg    = 'S'
                display by name d_cts60m00.imdsrvflg
                display by name d_cts60m00.atdprinvlcod
             else
                if d_cts60m00.prslocflg  =  "N"   then
                   initialize w_cts60m00.hora,
                              w_cts60m00.data,
                              w_cts60m00.funmat   ,
                              w_cts60m00.cnldat   ,
                              w_cts60m00.atdfnlhor,
                              w_cts60m00.c24opemat,
                              w_cts60m00.atdfnlflg,
                              w_cts60m00.atdetpcod,
                              w_cts60m00.atdprscod to null
                end if
             end if
          end if
   before field camflg
          display by name d_cts60m00.camflg attribute (reverse)

   after  field camflg
          display by name d_cts60m00.camflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts60m00.camflg  is null)  or
                 (d_cts60m00.camflg  <>  "S"   and
                  d_cts60m00.camflg  <>  "N")) then
                error " Informacao sobre caminhao/utilitario invalida!"
                next field camflg
             end if

             if d_cts60m00.frmflg = "S"  then
                initialize w_cts60m00.vclcamtip to null
                initialize w_cts60m00.vclcrcdsc to null
                initialize w_cts60m00.vclcrgflg to null
                initialize w_cts60m00.vclcrgpso to null
                next field c24pbmcod
             end if

             if d_cts60m00.camflg = "S"  then
                call cts02m01(w_cts60m00.ctgtrfcod,
                              mr_geral.atdsrvnum,
                              mr_geral.atdsrvano,
                              w_cts60m00.vclcrgflg, w_cts60m00.vclcrgpso,
                              w_cts60m00.vclcamtip, w_cts60m00.vclcrcdsc)
                    returning w_cts60m00.vclcrgflg, w_cts60m00.vclcrgpso,
                              w_cts60m00.vclcamtip, w_cts60m00.vclcrcdsc

                if w_cts60m00.vclcamtip  is null   and
                   w_cts60m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                   next field camflg
                end if
             else
                initialize w_cts60m00.vclcamtip to null
                initialize w_cts60m00.vclcrcdsc to null
                initialize w_cts60m00.vclcrgflg to null
                initialize w_cts60m00.vclcrgpso to null
             end if
          end if

    before field c24pbmcod
        if mr_geral.c24astcod <> "I30" and
           mr_geral.c24astcod <> "I31" and
           mr_geral.c24astcod <> "I32" and
           mr_geral.c24astcod <> "IR2" and
           mr_geral.c24astcod <> "IAC" and
           mr_geral.c24astcod <> "IAP" and
           mr_geral.c24astcod <> "IVB" then # CRIADO POR YURI P.SOCORRO
           next field lgdtxt
        end if
        display by name d_cts60m00.c24pbmcod attribute (reverse)

    after  field c24pbmcod
        display by name d_cts60m00.c24pbmcod

        if d_cts60m00.c24pbmcod  is null  or
           d_cts60m00.c24pbmcod  =  0     then
           call ctc48m02(d_cts60m00.atdsrvorg)
                    returning ws.c24pbmgrpcod,
                              ws.c24pbmgrpdes
           if ws.c24pbmgrpcod  is null  then
              error " Codigo de problema deve ser informado!"
              next field c24pbmcod
           else
              call ctc48m01(ws.c24pbmgrpcod,"")
                   returning d_cts60m00.c24pbmcod,
                             d_cts60m00.atddfttxt
              if d_cts60m00.c24pbmcod is null  then
                 error " Codigo de problema deve ser informado!"
                 next field c24pbmcod
              end if
           end if
        else
           if d_cts60m00.c24pbmcod <> 999 then
              select c24pbmdes into d_cts60m00.atddfttxt
                from datkpbm
               where c24pbmcod = d_cts60m00.c24pbmcod
              if status = notfound then
                 error " Codigo de problema invalido !"
                 call ctc48m02(d_cts60m00.atdsrvorg) returning ws.c24pbmgrpcod,
                                                               ws.c24pbmgrpdes
                 if ws.c24pbmgrpcod  is null  then
                    error " Codigo de problema deve ser informado!"
                    next field c24pbmcod
                 else
                    call ctc48m01(ws.c24pbmgrpcod,"")
                                    returning d_cts60m00.c24pbmcod,
                                              d_cts60m00.atddfttxt
                    if d_cts60m00.c24pbmcod is null  then
                       error " Codigo de problema deve ser informado!"
                       next field c24pbmcod
                    end if
                 end if
              end if
           end if
        end if  
        
        
        #--------------------------------------------------------   
        # Valida Assunto Empresarial                                        
        #--------------------------------------------------------   
        
        if cty22g00_verifica_empresarial(g_doc_itau[1].itaasiplncod) then 
               
            #--------------------------------------------------------
            # Valida Limite por Problema                             
            #--------------------------------------------------------
            
            if not cty22g00_limite_problema_empresarial(g_doc_itau[1].itaasiplncod  ,
            	                                          ws.c24pbmgrpcod             ,         
                                                        g_documento.itaciacod       ,
                                                        mr_geral.ramcod             ,
                                                        mr_geral.aplnumdig          ,
                                                        mr_geral.itmnumdig          ) then
               next field c24pbmcod                                     
            end if
        
        end if
            
        
        #---------------------------------------------------------------
        # Alerta Novos Correntistas
        #---------------------------------------------------------------
        if g_doc_itau[1].itaasiplncod = 3 then
          if cts12g08_valida_data_limite(g_doc_itau[1].itaasiplncod   ,
                                         g_doc_itau[1].itaaplvigincdat) then
           	   call cty37g00_valida_alerta_problema(g_doc_itau[1].itaclisgmcod,
           	                                        ws.c24pbmgrpcod           )
           end if
        end if

        display by name d_cts60m00.c24pbmcod
        display by name d_cts60m00.atddfttxt

        open ccts60m00003 using d_cts60m00.c24pbmcod
        fetch ccts60m00003 into d_cts60m00.asitipcod

        let d_cts60m00.asitipabvdes = ""

        select asitipabvdes, asiofndigflg, vclcndlclflg
          into d_cts60m00.asitipabvdes
          from datkasitip
         where asitipcod = d_cts60m00.asitipcod
           and asitipstt = "A"

        display by name d_cts60m00.asitipcod,
                        d_cts60m00.asitipabvdes

        #display by name d_cts60m00.c24pbmcod
        #display by name d_cts60m00.atddfttxt






   before field atddfttxt

         if g_documento.atdsrvorg = 1 then
            next field lgdtxt
         end if

          display by name d_cts60m00.atddfttxt   attribute (reverse)
          if d_cts60m00.c24pbmcod <> 999 then
             next field lgdtxt
          end if

   after  field atddfttxt
          display by name d_cts60m00.atddfttxt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.atddfttxt is null  then
                error " Problema ou defeito deve ser informado!"
                next field atddfttxt
             end if
          end if

   before field lgdtxt
          if d_cts60m00.frmflg = "S"  then
             display by name a_cts60m00[1].lgdtxt attribute (reverse)
          else
             let mr_geral.lclocodesres    = "N"
             let g_documento.lclocodesres = "N"

             let a_cts60m00[1].lclbrrnom = m_subbairro[1].lclbrrnom


             let m_acesso_ind = false
             call cta00m06_acesso_indexacao_aut(d_cts60m00.atdsrvorg)
                  returning m_acesso_ind

             if m_acesso_ind = false then
                  call cts06g03(1
                               ,d_cts60m00.atdsrvorg
                               ,w_cts60m00.ligcvntip
                               ,aux_today
                               ,aux_hora
                               ,a_cts60m00[1].lclidttxt
                               ,a_cts60m00[1].cidnom
                               ,a_cts60m00[1].ufdcod
                               ,a_cts60m00[1].brrnom
                               ,a_cts60m00[1].lclbrrnom
                               ,a_cts60m00[1].endzon
                               ,a_cts60m00[1].lgdtip
                               ,a_cts60m00[1].lgdnom
                               ,a_cts60m00[1].lgdnum
                               ,a_cts60m00[1].lgdcep
                               ,a_cts60m00[1].lgdcepcmp
                               ,a_cts60m00[1].lclltt
                               ,a_cts60m00[1].lcllgt
                               ,a_cts60m00[1].lclrefptotxt
                               ,a_cts60m00[1].lclcttnom
                               ,a_cts60m00[1].dddcod
                               ,a_cts60m00[1].lcltelnum
                               ,a_cts60m00[1].c24lclpdrcod
                               ,a_cts60m00[1].ofnnumdig
                               ,a_cts60m00[1].celteldddcod
                               ,a_cts60m00[1].celtelnum
                               ,a_cts60m00[1].endcmp
                               ,hist_cts60m00.*
                               ,a_cts60m00[1].emeviacod )

                      returning a_cts60m00[1].lclidttxt
                               ,a_cts60m00[1].cidnom
                               ,a_cts60m00[1].ufdcod
                               ,a_cts60m00[1].brrnom
                               ,a_cts60m00[1].lclbrrnom
                               ,a_cts60m00[1].endzon
                               ,a_cts60m00[1].lgdtip
                               ,a_cts60m00[1].lgdnom
                               ,a_cts60m00[1].lgdnum
                               ,a_cts60m00[1].lgdcep
                               ,a_cts60m00[1].lgdcepcmp
                               ,a_cts60m00[1].lclltt
                               ,a_cts60m00[1].lcllgt
                               ,a_cts60m00[1].lclrefptotxt
                               ,a_cts60m00[1].lclcttnom
                               ,a_cts60m00[1].dddcod
                               ,a_cts60m00[1].lcltelnum
                               ,a_cts60m00[1].c24lclpdrcod
                               ,a_cts60m00[1].ofnnumdig
                               ,a_cts60m00[1].celteldddcod
                               ,a_cts60m00[1].celtelnum
                               ,a_cts60m00[1].endcmp
                               ,ws.retflg
                               ,hist_cts60m00.*
                               ,a_cts60m00[1].emeviacod
             else
                  call cts06g11(1
                               ,d_cts60m00.atdsrvorg
                               ,w_cts60m00.ligcvntip
                               ,aux_today
                               ,aux_hora
                               ,a_cts60m00[1].lclidttxt
                               ,a_cts60m00[1].cidnom
                               ,a_cts60m00[1].ufdcod
                               ,a_cts60m00[1].brrnom
                               ,a_cts60m00[1].lclbrrnom
                               ,a_cts60m00[1].endzon
                               ,a_cts60m00[1].lgdtip
                               ,a_cts60m00[1].lgdnom
                               ,a_cts60m00[1].lgdnum
                               ,a_cts60m00[1].lgdcep
                               ,a_cts60m00[1].lgdcepcmp
                               ,a_cts60m00[1].lclltt
                               ,a_cts60m00[1].lcllgt
                               ,a_cts60m00[1].lclrefptotxt
                               ,a_cts60m00[1].lclcttnom
                               ,a_cts60m00[1].dddcod
                               ,a_cts60m00[1].lcltelnum
                               ,a_cts60m00[1].c24lclpdrcod
                               ,a_cts60m00[1].ofnnumdig
                               ,a_cts60m00[1].celteldddcod
                               ,a_cts60m00[1].celtelnum
                               ,a_cts60m00[1].endcmp
                               ,hist_cts60m00.*
                               ,a_cts60m00[1].emeviacod )

                      returning a_cts60m00[1].lclidttxt
                               ,a_cts60m00[1].cidnom
                               ,a_cts60m00[1].ufdcod
                               ,a_cts60m00[1].brrnom
                               ,a_cts60m00[1].lclbrrnom
                               ,a_cts60m00[1].endzon
                               ,a_cts60m00[1].lgdtip
                               ,a_cts60m00[1].lgdnom
                               ,a_cts60m00[1].lgdnum
                               ,a_cts60m00[1].lgdcep
                               ,a_cts60m00[1].lgdcepcmp
                               ,a_cts60m00[1].lclltt
                               ,a_cts60m00[1].lcllgt
                               ,a_cts60m00[1].lclrefptotxt
                               ,a_cts60m00[1].lclcttnom
                               ,a_cts60m00[1].dddcod
                               ,a_cts60m00[1].lcltelnum
                               ,a_cts60m00[1].c24lclpdrcod
                               ,a_cts60m00[1].ofnnumdig
                               ,a_cts60m00[1].celteldddcod
                               ,a_cts60m00[1].celtelnum
                               ,a_cts60m00[1].endcmp
                               ,ws.retflg
                               ,hist_cts60m00.*
                               ,a_cts60m00[1].emeviacod

             end if

             
             #--------------------------------------------------------   
             # Valida Assunto Empresarial                                        
             #--------------------------------------------------------   
             
             if cty22g00_verifica_empresarial(g_doc_itau[1].itaasiplncod) then 
             
                 #--------------------------------------------------------  
                 # Valida Permissao Por Estado X Agrupamento do Problema                              
                 #--------------------------------------------------------  
                 
                 if not cty22g00_verifica_estado(ws.c24pbmgrpcod, a_cts60m00[1].ufdcod) then
                     next field c24pbmcod             
                 end if 
             
             end if
             
             
             #--------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #--------------------------------------------------------------

             if g_documento.lclocodesres = "S" then
                let d_cts60m00.atdrsdflg = "S"
             else
                let d_cts60m00.atdrsdflg = "N"
             end if


             let m_subbairro[1].lclbrrnom = a_cts60m00[1].lclbrrnom

             call cts06g10_monta_brr_subbrr(a_cts60m00[1].brrnom,
                                            a_cts60m00[1].lclbrrnom)
                  returning a_cts60m00[1].lclbrrnom

             let a_cts60m00[1].lgdtxt = a_cts60m00[1].lgdtip clipped, " ",
                                        a_cts60m00[1].lgdnom clipped, " ",
                                        a_cts60m00[1].lgdnum using "<<<<#"


             if a_cts60m00[1].cidnom is not null and
                a_cts60m00[1].ufdcod is not null then
                call cts14g00 (d_cts60m00.c24astcod,
                               "","","","",
                               a_cts60m00[1].cidnom,
                               a_cts60m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts60m00[1].lgdtxt
             display by name a_cts60m00[1].lclbrrnom
             display by name a_cts60m00[1].endzon
             display by name a_cts60m00[1].cidnom
             display by name a_cts60m00[1].ufdcod
             display by name a_cts60m00[1].lclrefptotxt
             display by name a_cts60m00[1].lclcttnom
             display by name a_cts60m00[1].dddcod
             display by name a_cts60m00[1].lcltelnum
             display by name a_cts60m00[1].celteldddcod
             display by name a_cts60m00[1].celtelnum
             display by name a_cts60m00[1].endcmp

             if a_cts60m00[1].ufdcod = "EX" then   
                let ws.retflg = "S" 
                if a_cts60m00[1].c24lclpdrcod is null then
                   let a_cts60m00[1].c24lclpdrcod = 1
                end if
             end if  

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!" sleep 3

                if g_documento.atdsrvorg = 1 then
                   next field c24pbmcod
                else
                   next field camflg
                end if
             else
                next field sindat
             end if
          end if

   after  field lgdtxt
          display by name a_cts60m00[1].lgdtxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts60m00.c24pbmcod <> 999 then
                next field c24pbmcod
             else
                next field atddfttxt
             end if
          end if
          if a_cts60m00[1].lgdtxt is null then
             error " Endereco deve ser informado!"
             next field lgdtxt
          end if

   before field lclbrrnom
          display by name a_cts60m00[1].lclbrrnom attribute (reverse)

   after  field lclbrrnom
          display by name a_cts60m00[1].lclbrrnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lgdtxt
          end if
          if a_cts60m00[1].lclbrrnom is null then
             error " Bairro deve ser informado!"
             next field lclbrrnom
          end if

   before field cidnom
          display by name a_cts60m00[1].cidnom attribute (reverse)

   after  field cidnom
          display by name a_cts60m00[1].cidnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclbrrnom
          end if
          if a_cts60m00[1].cidnom is null then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

   before field ufdcod
          display by name a_cts60m00[1].ufdcod attribute (reverse)

   after  field ufdcod
          display by name a_cts60m00[1].ufdcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cidnom
          end if
          if a_cts60m00[1].ufdcod is null then
             error " U.F. deve ser informada!"
             next field ufdcod
          end if

          # Verifica Cidade/UF
          select cidcod
            from glakcid
           where cidnom = a_cts60m00[1].cidnom
             and ufdcod = a_cts60m00[1].ufdcod

           if sqlca.sqlcode = notfound then
              error " Cidade/UF nao estao corretos!"
              next field ufdcod
           end if


   before field lclrefptotxt
          display by name a_cts60m00[1].lclrefptotxt attribute (reverse)

   after  field lclrefptotxt
          display by name a_cts60m00[1].lclrefptotxt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ufdcod
          end if

   before field endzon
          display by name a_cts60m00[1].endzon attribute (reverse)

   after  field endzon
          display by name a_cts60m00[1].endzon

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclrefptotxt
          end if
          if a_cts60m00[1].ufdcod  = "SP" then
             if a_cts60m00[1].endzon <> "NO" and
                a_cts60m00[1].endzon <> "SU" and
                a_cts60m00[1].endzon <> "LE" and
                a_cts60m00[1].endzon <> "OE" and
                a_cts60m00[1].endzon <> "CE" then
                error " Para a Capital favor informar zona NO/SU/LE/OE/CE!"
                next field endzon
             end if
          end if

   before field dddcod
          display by name a_cts60m00[1].dddcod attribute (reverse)

   after  field dddcod
          display by name a_cts60m00[1].dddcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field endzon
          end if

   before field lcltelnum
          display by name a_cts60m00[1].lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name a_cts60m00[1].lcltelnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field dddcod
          end if

   before field lclcttnom
          if d_cts60m00.frmflg = "N" then
             if d_cts60m00.c24pbmcod <> 999 then
                next field c24pbmcod
             else
                next field atddfttxt
             end if
          end if
          display by name a_cts60m00[1].lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name a_cts60m00[1].lclcttnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lcltelnum
          end if
          if d_cts60m00.frmflg = "S" then
             let a_cts60m00[1].lgdnom       = a_cts60m00[1].lgdtxt
             let a_cts60m00[1].c24lclpdrcod = 1   # Fora do padrao
          end if

   before field sindat

          if g_documento.atdsrvorg <> 4 then
             next field atdrsdflg
          end if

          display by name d_cts60m00.sindat attribute (reverse)

   after  field sindat
          display by name d_cts60m00.sindat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field camflg
          else
             if d_cts60m00.sindat is null  then
                error " Data do sinistro deve ser informada!"
                next field sindat
             end if

             if d_cts60m00.sindat > l_data   then
                error " Data do sinistro nao deve ser maior que hoje!"
                next field sindat
             end if
          end if

   before field sinhor
          display by name d_cts60m00.sinhor attribute (reverse)

   after  field sinhor
          display by name d_cts60m00.sinhor

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts60m00.sinhor is null  then
                error " Hora do sinistro deve ser informada!"
                next field sinhor
             end if

             if d_cts60m00.sindat =  l_data     and
                d_cts60m00.sinhor <> "00:00"   and
                d_cts60m00.sinhor >  aux_hora  then
                error " Hora do sinistro nao deve ser maior que hora atual!"
                next field sinhor
             end if
          end if

   before field atdrsdflg

          if g_documento.atdsrvorg = 4 then
              next field sinvitflg
          end if

          if d_cts60m00.frmflg = "S" then
             let d_cts60m00.atdrsdflg = "N"
          end if

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then

             if g_documento.atdsrvorg = 4 then
                next field sinhor
             else
                next field c24pbmcod
             end if

          end if

          display by name d_cts60m00.atdrsdflg

          next field sinvitflg

   # -> VITIMAS
   before field sinvitflg

      # -> SO INFORMA VITIMAS E BO QUANDO ASSUNTO FOR I03
      if g_documento.atdsrvorg <> 4 then
         next field asitipcod
      end if

      if d_cts60m00.frmflg = "S" then
         let d_cts60m00.sinvitflg = "N"
      end if

      display by name d_cts60m00.sinvitflg attribute(reverse)

   after field sinvitflg
      display by name d_cts60m00.sinvitflg

      if fgl_lastkey() = fgl_keyval("up")  or
         fgl_lastkey() = fgl_keyval("left") then
         next field sinhor
      end if

      if (d_cts60m00.sinvitflg <> "S" and d_cts60m00.sinvitflg <> "N") or
         (d_cts60m00.sinvitflg is null) then
         error "Ha vitimas ? Informe (S)SIM ou (N)NAO"
         next field sinvitflg
      end if

   # -> B.O.
   before field bocflg

      # -> SO INFORMA VITIMAS E BO QUANDO ASSUNTO FOR I03
      if g_documento.atdsrvorg <> 4 then
         next field asitipcod
      end if

      if d_cts60m00.frmflg = "S" then
         let d_cts60m00.bocflg = "N"
      end if

      display by name d_cts60m00.bocflg attribute(reverse)

   after field bocflg
      display by name d_cts60m00.bocflg

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field sinvitflg
      end if

      if d_cts60m00.bocflg is null then
         error "Dados sobre o boletim de ocorrencia devem ser informados !"
         next field bocflg
      end if

      if d_cts60m00.bocflg <> "S" and
         d_cts60m00.bocflg <> "N" and
         d_cts60m00.bocflg <> "P" then
         error "Fez B.O. ? (S)im, (N)ao ou (P)esquisa Delegacias"
         next field bocflg
      end if

      if d_cts60m00.bocflg = "P" then
         error "Pesquisa Distrito Policial/Batalhoes via CEP."
         call ctn00c02("SP",
                       "SAO PAULO",
                       " ",
                       " ")
              returning lr_ctn00c02.endcep,
                        lr_ctn00c02.endcepcmp

         if lr_ctn00c02.endcep is null then
            error "Nenhum cep foi selecionado!"
         else
            call ctn03c01(lr_ctn00c02.endcep)
         end if

         next field bocflg
      end if

      if d_cts60m00.bocflg = "S"  then
         call cts02m02(d_cts60m00.bocnum,
                       d_cts60m00.bocemi,
                       d_cts60m00.vcllibflg)
             returning d_cts60m00.bocnum,
                       d_cts60m00.bocemi,
                       d_cts60m00.vcllibflg
      else
         let d_cts60m00.bocnum    = null
         let d_cts60m00.bocemi    = null
         let d_cts60m00.vcllibflg = null
      end if

   before field asitipcod
          display by name d_cts60m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts60m00.asitipcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then

             if mr_geral.c24astcod = "I30" or
                mr_geral.c24astcod = "I31" or
                mr_geral.c24astcod = "I32" or
                mr_geral.c24astcod = "IR2" or
                mr_geral.c24astcod = "IAP" or
                mr_geral.c24astcod = "IAC" or
                mr_geral.c24astcod = "IVB" then # CRIADO POR YURI P.SOCORRO
                next field atdrsdflg
             else # ASSUNTO I03
                next field bocflg
             end if
          end if

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then

             if d_cts60m00.asitipcod is null  then
                let d_cts60m00.asitipcod = ctn25c00(d_cts60m00.atdsrvorg)

                if d_cts60m00.asitipcod is not null  then
                   select asitipabvdes, asiofndigflg, vclcndlclflg
                     into d_cts60m00.asitipabvdes
                         ,w_cts60m00.asiofndigflg
                         ,w_cts60m00.vclcndlclflg
                     from datkasitip
                    where asitipcod = d_cts60m00.asitipcod  and
                          asitipstt = "A"

                   if d_cts60m00.asitipcod = 1 and
                      w_cts60m00.asiofndigflg = "S" then
                      let d_cts60m00.dstflg = "S"
                      display by name d_cts60m00.dstflg
                   end if

                   display by name d_cts60m00.asitipcod
                   display by name d_cts60m00.asitipabvdes

                   if w_cts60m00.vclcndlclflg = "S" then
                      if g_documento.acao = "CON" then
                         let tip_mvt = "A"
                      else
                         let tip_mvt = "M"
                      end if
                      call ctc61m02(mr_geral.atdsrvnum,
                                    mr_geral.atdsrvano,
                                    tip_mvt)

                       # Verifica a gravação de laudo multiplo
                       let m_multiplo = false
                       call cta00m06_assistencia_multiplo(d_cts60m00.asitipcod)
                            returning l_confirma

                       if l_confirma = true and
                          mr_geral.c24astcod <> 'IAP' then

                          call cts08g01("C","S",' ',"DESEJA ENVIAR SERVICO DE APOIO ?",'','')
                               returning m_multiplo

                            if m_multiplo = "S" then
                                   # Guardada a variavel de assunto anterior
                                   # devido o filtro de grupo de problema

                                   let l_c24astcod = g_documento.c24astcod
                                   let g_documento.c24astcod = 'IAP'

                                   while true
                                         if d_cts60m00.atdsrvorg = 1 then
                                            call ctc48m02(d_cts60m00.atdsrvorg) returning am_param.c24pbmgrpcod,
                                                                                          am_param.c24pbmgrpdes
                                         else
                                            call ctc48m02(l_nulo) returning am_param.c24pbmgrpcod,
                                                                            am_param.c24pbmgrpdes
                                         end if

                                         if am_param.c24pbmgrpcod  is null  then
                                            error " Grupo de problema deve ser informado!"
                                            let l_erro = true
                                         else
                                           let l_erro = false
                                           call ctc48m01(am_param.c24pbmgrpcod,"")
                                                              returning am_param.c24pbmcod,
                                                                        am_param.atddfttxt
                                            if am_param.c24pbmcod is null  then
                                               error " Problema deve ser informado !"
                                               let l_erro = true
                                            else
                                               let l_erro = false
                                            end if
                                         end if

                                         if l_erro = false then
                                            exit while
                                         end if

                                   end while
                                   let g_documento.c24astcod = l_c24astcod
                                   whenever error continue
                                      open ccts60m00003 using am_param.c24pbmcod
                                      fetch ccts60m00003 into am_param.asitipcod
                                   whenever error stop

                                   if sqlca.sqlcode <> 0 then
                                       let l_mensagem = 'Erro < ',sqlca.sqlcode,' > ao buscar tipo de assistência < ',am_param.c24pbmcod,' >'
                                       call errorlog(l_mensagem)
                                   end if
                            end if
                       end if
                   else
                      call ctc61m02_criatmp(2, mr_geral.atdsrvnum,
                                            mr_geral.atdsrvano)
                           returning tmp_flg

                      if tmp_flg = 1 then
                         display "Problemas com temporaria! <Avise a Informatica>"
                      end if
                   end if

                      initialize w_cts60m00.atdvcltip to null


                   if d_cts60m00.asitipcod =  2   or    ###  Tecnico
                      d_cts60m00.asitipcod =  4   or    ###  Chaveiro
                      d_cts60m00.asitipcod =  8   then  ###  Chaveiro/Disp.
                      let d_cts60m00.dstflg    = "N"
                      let d_cts60m00.rmcacpflg = "N"
                      initialize a_cts60m00[2].*  to null
                      let a_cts60m00[2].operacao = "D"
                      display by name d_cts60m00.dstflg, d_cts60m00.rmcacpflg
                      next field atdprinvlcod
                   end if
                   next field dstflg
                else
                   next field asitipcod
                end if
             else
                select asitipabvdes, asiofndigflg, vclcndlclflg
                  into d_cts60m00.asitipabvdes
                      ,w_cts60m00.asiofndigflg
                      ,w_cts60m00.vclcndlclflg
                  from datkasitip
                 where asitipcod = d_cts60m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   let d_cts60m00.asitipcod = ctn25c00(d_cts60m00.atdsrvorg)
                   next field asitipcod
                else
                   display by name d_cts60m00.asitipcod
                   display by name d_cts60m00.asitipabvdes
                end if

                if d_cts60m00.asitipcod = 1 and
                   w_cts60m00.asiofndigflg = "S" then
                   let d_cts60m00.dstflg = "S"
                   display by name d_cts60m00.dstflg
                end if

                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = d_cts60m00.atdsrvorg
                   and asitipcod = d_cts60m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada para este servico!"
                   next field asitipcod
                end if

                if w_cts60m00.vclcndlclflg = "S" then
                   if g_documento.acao = "CON" then
                      let tip_mvt = "A"
                   else
                      let tip_mvt = "M"
                   end if
                   call ctc61m02(mr_geral.atdsrvnum,
                                 mr_geral.atdsrvano,
                                 tip_mvt)

                   let m_multiplo = false
                   call cta00m06_assistencia_multiplo(d_cts60m00.asitipcod)
                        returning l_confirma

                   if l_confirma = true and
                      mr_geral.c24astcod <> 'IAP' then

                      call cts08g01("C","S",' ',"DESEJA ENVIAR SERVICO DE APOIO ?",'','')
                           returning m_multiplo

                        if m_multiplo = "S" then
                               # Guardada a variavel de assunto anterior
                               # devido o filtro de grupo de problema

                               let l_c24astcod = g_documento.c24astcod
                               let g_documento.c24astcod = 'IAP'

                               while true
                                   if d_cts60m00.atdsrvorg = 1 then
                                      call ctc48m02(d_cts60m00.atdsrvorg) returning am_param.c24pbmgrpcod,
                                                                                    am_param.c24pbmgrpdes
                                   else
                                      call ctc48m02(l_nulo	) returning am_param.c24pbmgrpcod,
                                                                                    am_param.c24pbmgrpdes
                                   end if

                                   if am_param.c24pbmgrpcod  is null  then
                                      error " Grupo de problema deve ser informado!"
                                      let l_erro = true
                                   else
                                     let l_erro = false
                                     call ctc48m01(am_param.c24pbmgrpcod,"")
                                                        returning am_param.c24pbmcod,
                                                                  am_param.atddfttxt
                                      if am_param.c24pbmcod is null  then
                                         error " Problema deve ser informado !"
                                         let l_erro = true
                                      else
                                         let l_erro = false
                                      end if
                                   end if

                                   if l_erro = false then
                                      exit while
                                   end if

                               end while
                               let g_documento.c24astcod = l_c24astcod
                               whenever error continue
                                  open ccts60m00003 using am_param.c24pbmcod
                                  fetch ccts60m00003 into am_param.asitipcod
                               whenever error stop

                               if sqlca.sqlcode <> 0 then
                                   let l_mensagem = 'Erro < ',sqlca.sqlcode,' > ao buscar tipo de assistência < ',am_param.c24pbmcod,' >'
                                   call errorlog(l_mensagem)
                               end if
                        end if
                   end if
                else
                   call ctc61m02_criatmp(2, mr_geral.atdsrvnum,
                                         mr_geral.atdsrvano)
                        returning tmp_flg

                   if tmp_flg = 1 then
                      display "Problemas com temporaria! <Avise a Informatica>."
                   end if
                end if

                   initialize w_cts60m00.atdvcltip to null


                if d_cts60m00.asitipcod =  2   or    ###  Tecnico
                   d_cts60m00.asitipcod =  4   or    ###  Chaveiro
                   d_cts60m00.asitipcod =  8   then  ###  Chaveiro/Disp.
                   let d_cts60m00.dstflg    = "N"
                   let d_cts60m00.rmcacpflg = "N"
                   initialize a_cts60m00[2].*  to null
                   let a_cts60m00[2].operacao = "D"
                   display by name d_cts60m00.dstflg, d_cts60m00.rmcacpflg
                   next field atdprinvlcod
                end if
             end if
             display by name d_cts60m00.asitipabvdes
          end if

   before field dstflg
          if d_cts60m00.frmflg = "S" then
             let d_cts60m00.dstflg = "N"
          end if
          if d_cts60m00.asitipcod = 3 then
             let d_cts60m00.dstflg = 'S'
          end if
          display by name d_cts60m00.dstflg attribute (reverse)

   after  field dstflg
          display by name d_cts60m00.dstflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.dstflg is null    then
                error " Destino deve ser informado!"
                next field dstflg
             end if

             if d_cts60m00.dstflg <> "S"   and
                d_cts60m00.dstflg <> "N"   then
                error " Existe destino: (S)im ou (N)ao"
                next field dstflg
             end if

            if d_cts60m00.asitipcod = 3 and
                d_cts60m00.dstflg = "N" then
                error " Local de destino deve ser informado!"
                next field dstflg
             end if


             initialize w_hist.* to null

             if d_cts60m00.dstflg = "S"  then

                ---> So sugere o CAPS se estiver incluindo Laudo
                if g_documento.atdsrvorg = 1 then

                   if g_documento.acao = "INC" then

                      ---> Verifica se Assuntos estao ligados ao CAPS
                      # Prepare
                      select cponom
                        from iddkdominio
                       where cponom = "c24astcod_caps"
                         and cpodes =  mr_geral.c24astcod

                      if sqlca.sqlcode <> notfound  then

                         ---> Verifica Tipo de Assistencia
                         if d_cts60m00.asitipcod = 1 or   ---> Guincho
                            d_cts60m00.asitipcod = 3 then ---> Guincho/Tecnico



                            ---> Verifica se ha Postos Caps que atendem o Servico
                            call oavpc071_consultadisponibilidadepostoscaps(
                                      w_cts60m00.ctgtrfcod
                                     ,ws.c24pbmgrpcod)
                                 returning l_stt


                            ---> Encontrou Posto que Atende o Servico desejado
                            if l_stt <> 0 then
                               let ws.confirma = cts08g01("A","N",""
                                             ," INDICAR UM CAPS PARA ESTE SERVICO."
                                             ,"", "")

                               initialize l_stt to null

                               ---> Define Limite de Km p/solicitar confirmacao
                               ---> ao selecionar o CAPS, conforme local do Veiculo

                               if d_cts60m00.atdrsdflg = "S" then
                                  let l_lim_km = 7  ---> Em Residencia
                               else
                                  let l_lim_km = 50 ---> Fora da Residencia
                               end if

                               ---> Mostrar Relacao dos postos CAPS
                               call oavpc071_retornapostoscaps(w_cts60m00.ctgtrfcod
                                                              ,ws.c24pbmgrpcod
                                                              ,a_cts60m00[1].lclltt
                                                              ,a_cts60m00[1].lcllgt
                                                              ,l_lim_km
                                                              ,d_cts60m00.c24astcod )
                                    returning l_cappstcod
                                             ,l_stt
                                            ,a_cts60m00[2].lgdtip
                                            ,a_cts60m00[2].lgdnom
                                            ,a_cts60m00[2].lgdnum
                                            ,a_cts60m00[2].brrnom
                                            ,a_cts60m00[2].cidnom
                                            ,a_cts60m00[2].ufdcod
                                            ,l_cidcod
                                            ,a_cts60m00[2].lgdcep
                                            ,a_cts60m00[2].lgdcepcmp
                                            ,l_endlgdcmp
                                            ,a_cts60m00[2].lclltt
                                            ,a_cts60m00[2].lcllgt
                                            ,a_cts60m00[2].lclcttnom
                                            ,a_cts60m00[2].dddcod
                                            ,a_cts60m00[2].lcltelnum
                                            ,l_gchvclinchor
                                            ,l_gchvcfnlhor
                                            ,a_cts60m00[2].lclidttxt

                               ---> Nao escolheu nenhum CAPS
                               if l_cappstcod is null or
                                  l_cappstcod =  0    then

                                  let ws.confirma = cts08g01("A","N",""
                                                 ," JUSTIFIQUE O MOTIVO PELA NAO "
                                                 ," ACEITACAO DO CAPS ", "")

                                  while true
                                     let ws_mtvcaps = 0

                                     ---> Obriga informar motivo
                                     call ctc26m01()
                                       returning ws_mtvcaps

                                     if ws_mtvcaps = 0 then
                                       let l_msg = mr_geral.c24astcod
                                       let l_msg1 = " ASSUNTO ",l_msg clipped
                                       let l_msg2 = " NAO TEM MOTIVOS CAPS CADASTRADO "
                                       let l_msg3 = " AVISE A COORDENACAO. "
                                       call cts08g01 ("A","N","",l_msg1,l_msg2,l_msg3)
                                          returning ws.confirma
                                    continue while
                                  end if
                                     if ws_mtvcaps is null then
                                        error ' O motivo deve ser informado !'
                                        continue while
                                     end if

                                     exit while
                                  end while
                               else
                               	  let ws_mtvcaps = null
                               end if

                               let l_lgdnom    = a_cts60m00[2].lgdnom
                               let m_cappstcod = l_cappstcod
                            end if
                         end if
                      end if
                   end if
                else
                  if g_documento.acao = "INC" then

                      ---> Verifica se Assuntos estao ligados ao CAR
                      # Prepare
                      select cponom
                        from datkdominio
                       where cponom = "c24astcod_car"
                         and cpodes =  mr_geral.c24astcod

                      if sqlca.sqlcode <> notfound  then

                         ---> Verifica Tipo de Assistencia
                         if d_cts60m00.asitipcod = 1 or   ---> Guincho
                            d_cts60m00.asitipcod = 3 then ---> Guincho/Tecnico

                            call cts08g01_6l_confirma("A",
                                      "F",
                                      "",
                                      "",
                                      "",
                                      "",
                                      "ESTE VEICULO E DE PASSEIO ? ",
                                      "")
                                      returning ws.confirma

                            if ws.confirma = "S" then
                               let ws.confirma = cts08g01("A","N",
                                              " INDICAR UM CAR NO RAIO DE 40 KM",
                                              " NA AUSENCIA DO CAR INDICAR OFICINAS",
                                              " REFERENCIAS UTILIZANDO FUNCAO F8", "")

                               initialize l_stt to null

                               ---> Mostrar Relacao dos postos CAR
                               call cto00m11( a_cts60m00[1].lclltt
                                             ,a_cts60m00[1].lcllgt )

                                    returning a_cts60m00[2].lclidttxt
                                            , a_cts60m00[2].lgdtip
                                            , a_cts60m00[2].lgdnom
                                            , a_cts60m00[2].lgdnum
                                            , a_cts60m00[2].brrnom
                                            , a_cts60m00[2].cidnom
                                            , a_cts60m00[2].ufdcod
                                            , a_cts60m00[2].lgdcep
                                            , a_cts60m00[2].lgdcepcmp
                                            , l_endlgdcmp
                                            , a_cts60m00[2].lclltt
                                            , a_cts60m00[2].lcllgt
                                            , a_cts60m00[2].lclcttnom
                                            , a_cts60m00[2].dddcod
                                            , a_cts60m00[2].lcltelnum
                                            , a_cts60m00[2].lclrefptotxt
                                            , l_stt

                               ---> Nao escolheu nenhum CAR
                               if l_stt = 0 then
                                  error 'Nao escolheu nenhum C.A.R'
                                  let ws.confirma = cts08g01("A","N",""
                                                 ," JUSTIFIQUE O MOTIVO PELA NAO "
                                                 ," ACEITACAO DO CAR ", "")

                                  while true
                                     let ws_mtvcaps = 0

                                     ---> Obriga informar motivo
                                     call ctc26m01() returning ws_mtvcaps

                                     if ws_mtvcaps is null or
                                        ws_mtvcaps =  0    then
                                        error ' O motivo deve ser informado !'
                                        continue while
                                     end if

                                     exit while
                                  end while
                               end if
                            end if
                         end if
                      end if
                  end if
                end if


                let a_cts60m00[3].* = a_cts60m00[2].*

                let a_cts60m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

                let m_acesso_ind = false
                call cta00m06_acesso_indexacao_aut(d_cts60m00.atdsrvorg)
                     returning m_acesso_ind

             if m_acesso_ind = false then
                call cts06g03(2
                             ,d_cts60m00.atdsrvorg
                             ,w_cts60m00.ligcvntip
                             ,aux_today
                             ,aux_hora
                             ,a_cts60m00[2].lclidttxt
                             ,a_cts60m00[2].cidnom
                             ,a_cts60m00[2].ufdcod
                             ,a_cts60m00[2].brrnom
                             ,a_cts60m00[2].lclbrrnom
                             ,a_cts60m00[2].endzon
                             ,a_cts60m00[2].lgdtip
                             ,a_cts60m00[2].lgdnom
                             ,a_cts60m00[2].lgdnum
                             ,a_cts60m00[2].lgdcep
                             ,a_cts60m00[2].lgdcepcmp
                             ,a_cts60m00[2].lclltt
                             ,a_cts60m00[2].lcllgt
                             ,a_cts60m00[2].lclrefptotxt
                             ,a_cts60m00[2].lclcttnom
                             ,a_cts60m00[2].dddcod
                             ,a_cts60m00[2].lcltelnum
                             ,a_cts60m00[2].c24lclpdrcod
                             ,a_cts60m00[2].ofnnumdig
                             ,a_cts60m00[2].celteldddcod
                             ,a_cts60m00[2].celtelnum
                             ,a_cts60m00[2].endcmp
                             ,hist_cts60m00.*
                             ,a_cts60m00[2].emeviacod )
                    returning a_cts60m00[2].lclidttxt
                             ,a_cts60m00[2].cidnom
                             ,a_cts60m00[2].ufdcod
                             ,a_cts60m00[2].brrnom
                             ,a_cts60m00[2].lclbrrnom
                             ,a_cts60m00[2].endzon
                             ,a_cts60m00[2].lgdtip
                             ,a_cts60m00[2].lgdnom
                             ,a_cts60m00[2].lgdnum
                             ,a_cts60m00[2].lgdcep
                             ,a_cts60m00[2].lgdcepcmp
                             ,a_cts60m00[2].lclltt
                             ,a_cts60m00[2].lcllgt
                             ,a_cts60m00[2].lclrefptotxt
                             ,a_cts60m00[2].lclcttnom
                             ,a_cts60m00[2].dddcod
                             ,a_cts60m00[2].lcltelnum
                             ,a_cts60m00[2].c24lclpdrcod
                             ,a_cts60m00[2].ofnnumdig
                             ,a_cts60m00[2].celteldddcod
                             ,a_cts60m00[2].celtelnum
                             ,a_cts60m00[2].endcmp
                             ,ws.retflg
                             ,hist_cts60m00.*
                             ,a_cts60m00[2].emeviacod
             else
                   call cts06g11(2
                                ,d_cts60m00.atdsrvorg
                                ,w_cts60m00.ligcvntip
                                ,aux_today
                                ,aux_hora
                                ,a_cts60m00[2].lclidttxt
                                ,a_cts60m00[2].cidnom
                                ,a_cts60m00[2].ufdcod
                                ,a_cts60m00[2].brrnom
                                ,a_cts60m00[2].lclbrrnom
                                ,a_cts60m00[2].endzon
                                ,a_cts60m00[2].lgdtip
                                ,a_cts60m00[2].lgdnom
                                ,a_cts60m00[2].lgdnum
                                ,a_cts60m00[2].lgdcep
                                ,a_cts60m00[2].lgdcepcmp
                                ,a_cts60m00[2].lclltt
                                ,a_cts60m00[2].lcllgt
                                ,a_cts60m00[2].lclrefptotxt
                                ,a_cts60m00[2].lclcttnom
                                ,a_cts60m00[2].dddcod
                                ,a_cts60m00[2].lcltelnum
                                ,a_cts60m00[2].c24lclpdrcod
                                ,a_cts60m00[2].ofnnumdig
                                ,a_cts60m00[2].celteldddcod
                                ,a_cts60m00[2].celtelnum
                                ,a_cts60m00[2].endcmp
                                ,hist_cts60m00.*
                                ,a_cts60m00[2].emeviacod )
                       returning a_cts60m00[2].lclidttxt
                                ,a_cts60m00[2].cidnom
                                ,a_cts60m00[2].ufdcod
                                ,a_cts60m00[2].brrnom
                                ,a_cts60m00[2].lclbrrnom
                                ,a_cts60m00[2].endzon
                                ,a_cts60m00[2].lgdtip
                                ,a_cts60m00[2].lgdnom
                                ,a_cts60m00[2].lgdnum
                                ,a_cts60m00[2].lgdcep
                                ,a_cts60m00[2].lgdcepcmp
                                ,a_cts60m00[2].lclltt
                                ,a_cts60m00[2].lcllgt
                                ,a_cts60m00[2].lclrefptotxt
                                ,a_cts60m00[2].lclcttnom
                                ,a_cts60m00[2].dddcod
                                ,a_cts60m00[2].lcltelnum
                                ,a_cts60m00[2].c24lclpdrcod
                                ,a_cts60m00[2].ofnnumdig
                                ,a_cts60m00[2].celteldddcod
                                ,a_cts60m00[2].celtelnum
                                ,a_cts60m00[2].endcmp
                                ,ws.retflg
                                ,hist_cts60m00.*
                                ,a_cts60m00[2].emeviacod

             end if


                if m_cappstcod is not null then
                	   if l_lgdnom <> a_cts60m00[2].lgdnom then
                	         let m_cappstcod = null
                	   end if
                end if


                let m_subbairro[2].lclbrrnom = a_cts60m00[2].lclbrrnom

                call cts06g10_monta_brr_subbrr(a_cts60m00[2].brrnom,
                                               a_cts60m00[2].lclbrrnom)
                     returning a_cts60m00[2].lclbrrnom

                let a_cts60m00[2].lgdtxt = a_cts60m00[2].lgdtip clipped, " ",
                                           a_cts60m00[2].lgdnom clipped, " ",
                                           a_cts60m00[2].lgdnum using "<<<<#"

                if a_cts60m00[2].lclltt <> a_cts60m00[3].lclltt or
                   a_cts60m00[2].lcllgt <> a_cts60m00[3].lcllgt or
                   (a_cts60m00[3].lclltt is null      and
                    a_cts60m00[2].lclltt is not null) or
                   (a_cts60m00[3].lcllgt is null      and
                    a_cts60m00[2].lcllgt is not null) then

                   # Verifica Kilometragem
                     if g_documento.aplnumdig is not null then
                         case g_doc_itau[1].rsrcaogrtcod
                         when 1
                             let l_correntista = false
                         when 2
                              let l_correntista = false
                         when 3
                              let l_correntista = true
                         when 4
                             let l_correntista = true
                         otherwise
                             let l_correntista = false
                         end case
                        if l_correntista = false then
                             call cts00m33_calckm("",
                             a_cts60m00[1].lclltt,
                             a_cts60m00[1].lcllgt,
                             a_cts60m00[2].lclltt,
                             a_cts60m00[2].lcllgt,
                             m_limites_plano.socqlmqtd)
                        end if
                     end if
                end if

                if a_cts60m00[2].cidnom is not null and
                   a_cts60m00[2].ufdcod is not null then
                   call cts14g00 (d_cts60m00.c24astcod,
                                  "","","","",
                                  a_cts60m00[2].cidnom,
                                  a_cts60m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if

                if a_cts60m00[2].ufdcod = "EX" then
                   let ws.retflg = "S"
                   if a_cts60m00[2].c24lclpdrcod is null then
                      let a_cts60m00[2].c24lclpdrcod = 1
                   end if                   
                end if  

                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos",
                         " ou nao preenchidos!"
                   next field dstflg
                end if
                if mr_geral.atdsrvnum is null  and
                   mr_geral.atdsrvano is null  then
                   let a_cts60m00[2].operacao = "I"
                else
                   select c24lclpdrcod
                     from datmlcl
                    where atdsrvnum = mr_geral.atdsrvnum  and
                          atdsrvano = mr_geral.atdsrvano  and
                          c24endtip = 2
                   if sqlca.sqlcode = notfound  then
                      let a_cts60m00[2].operacao = "I"
                   else
                      let a_cts60m00[2].operacao = "M"
                   end if
                end if
                if a_cts60m00[2].ofnnumdig is not null then
                   #prepare
                   select ofnstt
                       into ws.ofnstt
                       from sgokofi
                      where ofnnumdig = a_cts60m00[2].ofnnumdig
                   if ws.ofnstt = "C" then
                      # digita o motivo
                      let w_hist.hist1 = "OF CORT MOTIVO:"
                      call cts10m02 (w_hist.*) returning w_hist.*
                   end if
                end if
             else
                if d_cts60m00.asitipcod    = 1   and
                   w_cts60m00.asiofndigflg = "S" then
                   error "Destino e Obrigatorio"
                   next field dstflg
                end if
                initialize a_cts60m00[2].*  to null
                let a_cts60m00[2].operacao = "D"
             end if
          end if

   before field rmcacpflg
          if d_cts60m00.frmflg = "S" then
             let d_cts60m00.rmcacpflg = "N"
          end if
          display by name d_cts60m00.rmcacpflg attribute (reverse)

   after  field rmcacpflg
          display by name d_cts60m00.rmcacpflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.rmcacpflg  is null   then
                error " Acompanha remocao deve ser informado!"
                next field rmcacpflg
             end if

             if d_cts60m00.rmcacpflg <> "S"      and
                d_cts60m00.rmcacpflg <> "N"      then
                error " Acompanha remocao deve ser (S)im ou (N)ao!"
                next field rmcacpflg
             end if
          end if

   before field atdprinvlcod
          if d_cts60m00.frmflg = "S" then
             if fgl_lastkey() <> fgl_keyval("up")   or
                fgl_lastkey() <> fgl_keyval("left") then
                next field imdsrvflg
             end if
          end if
          let d_cts60m00.atdprinvlcod = 2
          display by name d_cts60m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts60m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             # Prepare
             select cpodes
               into d_cts60m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts60m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts60m00.atdprinvldes

          else
             if d_cts60m00.frmflg = "S" then
                next field rmcacpflg
             end if
          end if

   before field prslocflg
          if mr_geral.atdsrvnum is not null  or
             mr_geral.atdsrvano is not null  then
             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                initialize d_cts60m00.prslocflg  to null
                next field atdprinvlcod
             else
                initialize d_cts60m00.prslocflg  to null
                next field atdlibflg
             end if
          else
             if d_cts60m00.imdsrvflg = "N"    then
                initialize w_cts60m00.c24nomctt  to null
                let d_cts60m00.prslocflg = "N"
                display by name d_cts60m00.prslocflg
                next field atdlibflg
             end if
          end if

          display by name d_cts60m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts60m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if ((d_cts60m00.prslocflg  is null)  or
              (d_cts60m00.prslocflg  <> "S"    and
             d_cts60m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts60m00.prslocflg = "S"   then
             call ctn24c01()
                  returning w_cts60m00.atdprscod, w_cts60m00.srrcoddig,
                            w_cts60m00.atdvclsgl, w_cts60m00.socvclcod

             if w_cts60m00.atdprscod  is null then
                error " Faltam dados para prestador no local!"
                next field prslocflg
             end if

             let d_cts60m00.atdlibhor = w_cts60m00.hora
             let d_cts60m00.atdlibdat = w_cts60m00.data
             let w_cts60m00.atdfnlflg = "S"
             let w_cts60m00.atdetpcod =  4
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             let w_cts60m00.cnldat    = l_data
             let w_cts60m00.atdfnlhor = l_hora2
             let w_cts60m00.c24opemat = g_issk.funmat
             let w_cts60m00.atdhorpvt = "00:00"
             let d_cts60m00.imdsrvflg = "S"
          else
             initialize w_cts60m00.funmat   ,
                        w_cts60m00.cnldat   ,
                        w_cts60m00.atdfnlhor,
                        w_cts60m00.c24opemat,
                        w_cts60m00.atdfnlflg,
                        w_cts60m00.atdetpcod,
                        w_cts60m00.atdprscod,
                        w_cts60m00.c24nomctt  to null
          end if

   before field atdlibflg
          ##-- inicializar o atdlibflg e passar para o proximo campo
          if d_cts60m00.atdlibflg is null then
             let d_cts60m00.atdlibflg = "S"

             if aux_libant is null  then
                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                let aux_libhor           = l_hora2
                let d_cts60m00.atdlibhor = aux_libhor
                let d_cts60m00.atdlibdat = l_data
             end if

             display by name d_cts60m00.atdlibflg
             next field imdsrvflg
          end if

          display by name d_cts60m00.atdlibflg attribute (reverse)

          if mr_geral.atdsrvnum is not null  and
             mr_geral.atdsrvano is not null  and
             w_cts60m00.atdfnlflg  =  "S"       then
             exit input
          end if

          if d_cts60m00.atdlibflg is null  and
             mr_geral.c24soltipcod  = 1   then   # Tipo solic = Segurado

          end if

   after  field atdlibflg
          display by name d_cts60m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts60m00.atdlibflg <> "S"  and
                d_cts60m00.atdlibflg <> "N"  then
                error " Envio liberado invalido!"
                next field atdlibflg
             end if

             if d_cts60m00.atdlibflg = "N"  and
                d_cts60m00.prslocflg = "S"  then
                error " Servico com prestador no local deve ser liberado!"
                next field atdlibflg
             end if

             let w_cts60m00.atdlibflg = d_cts60m00.atdlibflg
             display by name d_cts60m00.atdlibflg

             if aux_libant is null  then
                if w_cts60m00.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2)
                       returning l_data, l_hora2
                   let aux_libhor           = l_hora2
                   let d_cts60m00.atdlibhor = aux_libhor
                   let d_cts60m00.atdlibdat = l_data
                else
                   let d_cts60m00.atdlibflg = "N"
                   display by name d_cts60m00.atdlibflg
                   initialize d_cts60m00.atdlibhor to null
                   initialize d_cts60m00.atdlibdat to null
                end if
             else
                select atdfnlflg
                  from datmservico
                 where atdsrvnum = mr_geral.atdsrvnum  and
                       atdsrvano = mr_geral.atdsrvano  and
                       atdfnlflg in ("N","A")

                if sqlca.sqlcode = notfound  then
                   error " Servico ja' concluido nao pode ser alterado!"
                   let m_srv_acionado = true
                  let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                             " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                             " E INFORME AO  ** CONTROLE DE TRAFEGO **")
                   next field atdlibflg
                end if

                if aux_libant = "S"  then
                   if w_cts60m00.atdlibflg = "S"  then
                      next field imdsrvflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts60m00.atdlibflg = "N"
                      display by name d_cts60m00.atdlibflg
                      initialize d_cts60m00.atdlibhor to null
                      initialize d_cts60m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      next field imdsrvflg
                   end if
                else
                   if aux_libant = "N"  then
                      if w_cts60m00.atdlibflg = "N"  then
                         next field imdsrvflg
                      else
                         call cts40g03_data_hora_banco(2)
                             returning l_data, l_hora2
                         let aux_libhor           = l_hora2
                         let d_cts60m00.atdlibhor = aux_libhor
                         let d_cts60m00.atdlibdat = l_data
                         next field imdsrvflg
                      end if
                   end if
                end if
             end if
          else
             next field rmcacpflg
          end if

   before field imdsrvflg
          display by name d_cts60m00.imdsrvflg attribute (reverse)

   after  field imdsrvflg
          display by name d_cts60m00.imdsrvflg

          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts60m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if

          if (m_cidnom != a_cts60m00[1].cidnom) or
             (m_ufdcod != a_cts60m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts60m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if

          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts60m00.imdsrvflg
          end if

          if m_cidnom is null then
             let m_cidnom = a_cts60m00[1].cidnom
          end if

          if m_ufdcod is null then
             let m_ufdcod = a_cts60m00[1].ufdcod
          end if

          # Envia a chave antiga no input quando alteracao.
          # Se for a situacao INC, regulou, voltou para o laudo (CTRL+C) e regulou
          # novamente manda a mesma pra ver se ainda e valida
          if g_documento.acao = "ALT"
             then
             let m_rsrchv = m_rsrchvant
          end if
          # PSI-2013-00440PR

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts60m00.imdsrvflg is null   or
                d_cts60m00.imdsrvflg =  " "    then
                error " Informacoes sobre servico imediato deve ser informado!"
                next field imdsrvflg
             end if

             if d_cts60m00.imdsrvflg <> "S"    and
                d_cts60m00.imdsrvflg <> "N"    then
                error " Servico imediato: (S)im ou (N)ao!"
                next field imdsrvflg
             end if

             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts60m00.atdfnlflg,
                              d_cts60m00.imdsrvflg,
                              w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg)
                    returning w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg
             else
                call cts02m08(w_cts60m00.atdfnlflg,
                              d_cts60m00.imdsrvflg,
                              m_altcidufd,
                              d_cts60m00.prslocflg,
                              w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts60m00[1].cidnom,
                              a_cts60m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts60m00.vclcoddig,
                              w_cts60m00.ctgtrfcod,
                              d_cts60m00.imdsrvflg,
                              a_cts60m00[1].c24lclpdrcod,
                              a_cts60m00[1].lclltt,
                              a_cts60m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts60m00.atdsrvorg,
                              d_cts60m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts60m00.atdhorpvt,
                              w_cts60m00.atddatprg,
                              w_cts60m00.atdhorprg,
                              w_cts60m00.atdpvtretflg,
                              d_cts60m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor

                display by name d_cts60m00.imdsrvflg

                if int_flag
                   then
                   let int_flag = false
                   next field imdsrvflg
                end if
             end if

             if d_cts60m00.imdsrvflg = "S"  then
                if w_cts60m00.atdhorpvt is null  then
                   error " Horas previstas nao informadas para servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts60m00.atddatprg is null  or
                   w_cts60m00.atddatprg  = " "   or
                   w_cts60m00.atdhorprg is null  then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts60m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts60m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts60m00.atdprinvlcod

                    display by name d_cts60m00.atdprinvlcod
                    display by name d_cts60m00.atdprinvldes
                end if
             end if
          else
             if d_cts60m00.asitipcod = 2  or
                d_cts60m00.asitipcod = 4  or
                d_cts60m00.frmflg    = "S" then
                next field asitipcod
             end if
          end if

          # PSI-2013-00440PR
          if m_agendaw = false   # regulacao antiga
             then

             ### REGULADOR
             if d_cts60m00.prslocflg <> "S"   then
                #### CHAMA REGULADOR ####
                if d_cts60m00.imdsrvflg = "S"  then
                   let ws.rglflg = ctc59m02 ( a_cts60m00[1].cidnom,
                                              a_cts60m00[1].ufdcod,
                                              d_cts60m00.atdsrvorg,
                                              d_cts60m00.asitipcod,
                                              aux_today,
                                              aux_hora,
                                              false)
                else
                   let ws.rglflg = ctc59m02 ( a_cts60m00[1].cidnom,
                                              a_cts60m00[1].ufdcod,
                                              d_cts60m00.atdsrvorg,
                                              d_cts60m00.asitipcod,
                                              w_cts60m00.atddatprg,
                                              w_cts60m00.atdhorprg,
                                              false )
                end if
                if ws.rglflg <> 0 then
                   let d_cts60m00.imdsrvflg = "N"
                   call ctc59m03 ( a_cts60m00[1].cidnom,
                                   a_cts60m00[1].ufdcod,
                                   d_cts60m00.atdsrvorg,
                                   d_cts60m00.asitipcod,
                                   aux_today,
                                   aux_hora)
                        returning  w_cts60m00.atddatprg,
                                   w_cts60m00.atdhorprg
                   next field imdsrvflg
                end if
                if mr_geral.atdsrvnum is not null  and
                   mr_geral.atdsrvano is not null  then

                   # Para abater regulador
                   let ws.rglflg = ctc59m03_regulador(mr_geral.atdsrvnum,
                                           mr_geral.atdsrvano)
                end if
             end if
          end if  # PSI-2013-00440PR


   on key (interrupt)
      if mr_geral.atdsrvnum is null  or
         mr_geral.atdsrvano is null  then
         let ws.confirma = cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")

         if ws.confirma  =  "S"   then
            call ctc61m02_criatmp(2, mr_geral.atdsrvnum
                                 ,mr_geral.atdsrvano)
                  returning tmp_flg

            if tmp_flg = 1 then
               display "Problemas na tabela temporaria!"
            end if

            let int_flag = true
            exit input
         end if
      else
         if m_outrolaudo = 1 then   #se estava sendo exibido um segundo laudo
            let m_outrolaudo = 0    #prepara dados para voltar ao laudo principal
            let g_documento.acao = f4.acao
            let mr_geral.atdsrvnum = f4.atdsrvnum
            let mr_geral.atdsrvano = f4.atdsrvano
            initialize f4.* to null
            call cts60m00_consulta()
            display by name d_cts60m00.servico thru d_cts60m00.bocflg
            display by name d_cts60m00.c24solnom attribute (reverse)
            if d_cts60m00.desapoio is not null then
               display by name d_cts60m00.desapoio attribute (reverse)
            end if
            call cts02m00_ver_uso(l_atdsrvnum,l_atdsrvano,1)
                 returning l_msg
         else
            exit input
         end if
      end if

   on key (F1)
      if d_cts60m00.c24astcod is not null then
         call ctc58m00_vis(d_cts60m00.c24astcod)
      end if

   on key (F3)
      call cts00m23(mr_geral.atdsrvnum, mr_geral.atdsrvano)

   on key (F4)
      if m_outrolaudo = 1 or
         g_documento.acao <> "CON" then
         error "Nao e possivel visualizar outros laudos no momento."
      else
         #verificar se laudo é um laudo de apoio ou se laudo tem servicos de apoio
         call cts37g00_existeServicoApoio(mr_geral.atdsrvnum, mr_geral.atdsrvano)
              returning l_tipolaudo
         if l_tipolaudo <> 1 then
            if l_tipolaudo = 2 then  #servico tem servicos de apoio
               #listar laudos de apoio e selecionar 1 deles
               call cts37g00_buscaServicoApoio(2, mr_geral.atdsrvnum, mr_geral.atdsrvano)
                    returning l_atdsrvnum, l_atdsrvano
            end if
            if l_tipolaudo = 3 then  #servico e um servico de apoio
               #buscar numero ano servico laudo original
               call cts37g00_buscaServicoOriginal(mr_geral.atdsrvnum, mr_geral.atdsrvano)
                    returning l_aux, l_atdsrvnum, l_atdsrvano
               if l_aux = 1 then
                   error "Problemas ao buscar servico original. AVISE A INFORMATICA!"
               end if
            end if
            if l_atdsrvnum is not null and
               l_atdsrvano is not null then
               call cts02m00_ver_uso(l_atdsrvnum,l_atdsrvano,0)
                    returning l_msg

               if l_msg is not null then
                  error l_msg
               else

                  #salva informações laudo original
                  let f4.acao = g_documento.acao
                  let f4.atdsrvnum = mr_geral.atdsrvnum
                  let f4.atdsrvano = mr_geral.atdsrvano
                  #atualiza informacoes para novo laudo
                  let g_documento.acao = "CON"
                  let mr_geral.atdsrvnum = l_atdsrvnum
                  let mr_geral.atdsrvano = l_atdsrvano
                  #chama funcao consulta para novo laudo
                  let m_outrolaudo = 1
                  call cts60m00_consulta()
                  display by name d_cts60m00.servico thru d_cts60m00.bocflg
                  display by name d_cts60m00.c24solnom attribute (reverse)
                  if d_cts60m00.desapoio is not null then
                     display by name d_cts60m00.desapoio attribute (reverse)
                  end if
               end if
            end if
         else
            error "Servico nao ligado a servicos de apoio"
         end if
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
         call cts10m02 (hist_cts60m00.*) returning hist_cts60m00.*
      else
         call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                       g_issk.funmat        , aux_today  ,aux_hora)
      end if

   on key (F7)
      call ctx14g00("Funcoes","Impressao|Caminhao|Distancia|Veiculo")
           returning ws.opcao,
                     ws.opcaodes
      case ws.opcao
         when 1  ### Impressao
            if mr_geral.atdsrvnum is null then
               error " Impressao somente com cadastramento do servico!"
            else
               call ctr03m02(mr_geral.atdsrvnum,
                             mr_geral.atdsrvano)
            end if

         when 2  ### Caminhao
            if d_cts60m00.camflg = "S"  then
               call cts02m01(w_cts60m00.ctgtrfcod,
                             mr_geral.atdsrvnum,
                             mr_geral.atdsrvano,
                             w_cts60m00.vclcrgflg, w_cts60m00.vclcrgpso,
                             w_cts60m00.vclcamtip, w_cts60m00.vclcrcdsc)
                   returning w_cts60m00.vclcrgflg, w_cts60m00.vclcrgpso,
                             w_cts60m00.vclcamtip, w_cts60m00.vclcrcdsc

               if w_cts60m00.vclcamtip  is null   and
                  w_cts60m00.vclcrgflg  is null   then
                  error " Faltam informacoes sobre caminhao/utilitario!"
               end if
            end if
         when 3   #### Distancia QTH-QTI
                 call cts60m00_calckm("C")

         when 4   #### Apresentar Locais e as condicoes do veiculo
            if mr_geral.atdsrvnum is not null  and
               mr_geral.atdsrvano is not null  then
               call ctc61m02(mr_geral.atdsrvnum,
                             mr_geral.atdsrvano,
                             "A")

               let tmp_flg = ctc61m02_criatmp(2,
                                              mr_geral.atdsrvnum,
                                              mr_geral.atdsrvano)

               if tmp_flg = 1 then
                  error "Problemas com temporaria! <Avise a Informatica> "
               end if
            end if

      end case

   on key (F8)
      if mr_geral.atdsrvnum is null  or
         mr_geral.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts60m00.dstflg = "N"  then
            error " Nao foi informado destino para este servico!"
         else
            let a_cts60m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

            let m_acesso_ind = false
            call cta00m06_acesso_indexacao_aut(d_cts60m00.atdsrvorg)
                 returning m_acesso_ind

            #Projeto alteracao cadastro de destino
            if g_documento.acao = "ALT" then

               call cts60m00_bkp_info_dest(1, hist_cts60m00.*)
                  returning hist_cts60m00.*

            end if

            if m_acesso_ind = false then
               call cts06g03(2
                            ,d_cts60m00.atdsrvorg
                            ,w_cts60m00.ligcvntip
                            ,aux_today
                            ,aux_hora
                            ,a_cts60m00[2].lclidttxt
                            ,a_cts60m00[2].cidnom
                            ,a_cts60m00[2].ufdcod
                            ,a_cts60m00[2].brrnom
                            ,a_cts60m00[2].lclbrrnom
                            ,a_cts60m00[2].endzon
                            ,a_cts60m00[2].lgdtip
                            ,a_cts60m00[2].lgdnom
                            ,a_cts60m00[2].lgdnum
                            ,a_cts60m00[2].lgdcep
                            ,a_cts60m00[2].lgdcepcmp
                            ,a_cts60m00[2].lclltt
                            ,a_cts60m00[2].lcllgt
                            ,a_cts60m00[2].lclrefptotxt
                            ,a_cts60m00[2].lclcttnom
                            ,a_cts60m00[2].dddcod
                            ,a_cts60m00[2].lcltelnum
                            ,a_cts60m00[2].c24lclpdrcod
                            ,a_cts60m00[2].ofnnumdig
                            ,a_cts60m00[2].celteldddcod
                            ,a_cts60m00[2].celtelnum
                            ,a_cts60m00[2].endcmp
                            ,hist_cts60m00.*
                            ,a_cts60m00[2].emeviacod )
                   returning a_cts60m00[2].lclidttxt
                            ,a_cts60m00[2].cidnom
                            ,a_cts60m00[2].ufdcod
                            ,a_cts60m00[2].brrnom
                            ,a_cts60m00[2].lclbrrnom
                            ,a_cts60m00[2].endzon
                            ,a_cts60m00[2].lgdtip
                            ,a_cts60m00[2].lgdnom
                            ,a_cts60m00[2].lgdnum
                            ,a_cts60m00[2].lgdcep
                            ,a_cts60m00[2].lgdcepcmp
                            ,a_cts60m00[2].lclltt
                            ,a_cts60m00[2].lcllgt
                            ,a_cts60m00[2].lclrefptotxt
                            ,a_cts60m00[2].lclcttnom
                            ,a_cts60m00[2].dddcod
                            ,a_cts60m00[2].lcltelnum
                            ,a_cts60m00[2].c24lclpdrcod
                            ,a_cts60m00[2].ofnnumdig
                            ,a_cts60m00[2].celteldddcod
                            ,a_cts60m00[2].celtelnum
                            ,a_cts60m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts60m00.*
                            ,a_cts60m00[2].emeviacod
            else
               call cts06g11(2
                            ,d_cts60m00.atdsrvorg
                            ,w_cts60m00.ligcvntip
                            ,aux_today
                            ,aux_hora
                            ,a_cts60m00[2].lclidttxt
                            ,a_cts60m00[2].cidnom
                            ,a_cts60m00[2].ufdcod
                            ,a_cts60m00[2].brrnom
                            ,a_cts60m00[2].lclbrrnom
                            ,a_cts60m00[2].endzon
                            ,a_cts60m00[2].lgdtip
                            ,a_cts60m00[2].lgdnom
                            ,a_cts60m00[2].lgdnum
                            ,a_cts60m00[2].lgdcep
                            ,a_cts60m00[2].lgdcepcmp
                            ,a_cts60m00[2].lclltt
                            ,a_cts60m00[2].lcllgt
                            ,a_cts60m00[2].lclrefptotxt
                            ,a_cts60m00[2].lclcttnom
                            ,a_cts60m00[2].dddcod
                            ,a_cts60m00[2].lcltelnum
                            ,a_cts60m00[2].c24lclpdrcod
                            ,a_cts60m00[2].ofnnumdig
                            ,a_cts60m00[2].celteldddcod
                            ,a_cts60m00[2].celtelnum
                            ,a_cts60m00[2].endcmp
                            ,hist_cts60m00.*
                            ,a_cts60m00[2].emeviacod )
                   returning a_cts60m00[2].lclidttxt
                            ,a_cts60m00[2].cidnom
                            ,a_cts60m00[2].ufdcod
                            ,a_cts60m00[2].brrnom
                            ,a_cts60m00[2].lclbrrnom
                            ,a_cts60m00[2].endzon
                            ,a_cts60m00[2].lgdtip
                            ,a_cts60m00[2].lgdnom
                            ,a_cts60m00[2].lgdnum
                            ,a_cts60m00[2].lgdcep
                            ,a_cts60m00[2].lgdcepcmp
                            ,a_cts60m00[2].lclltt
                            ,a_cts60m00[2].lcllgt
                            ,a_cts60m00[2].lclrefptotxt
                            ,a_cts60m00[2].lclcttnom
                            ,a_cts60m00[2].dddcod
                            ,a_cts60m00[2].lcltelnum
                            ,a_cts60m00[2].c24lclpdrcod
                            ,a_cts60m00[2].ofnnumdig
                            ,a_cts60m00[2].celteldddcod
                            ,a_cts60m00[2].celtelnum
                            ,a_cts60m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts60m00.*
                            ,a_cts60m00[2].emeviacod
            end if

            #Projeto alteracao cadastro de destino
            let m_grava_hist = false

            if g_documento.acao = "ALT" then

               call cts60m00_verifica_tipo_atendim()
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
                        call cts60m00_verifica_op_ativa()
                           returning l_status

                        if l_status then

                           # ---> SALVA O NOME DO SEGURADO
                           let d_cts60m00.nom = l_salva_nom
                           display by name d_cts60m00.nom

                           error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                           error " Servico ja' acionado nao pode ser alterado!"
                           let m_srv_acionado = true
                           let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                      " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")

                           ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                           if m_agendaw = false   # regulacao antiga
                              then
                              call cts02m03(w_cts60m00.atdfnlflg,
                                           d_cts60m00.imdsrvflg,
                                           w_cts60m00.atdhorpvt,
                                           w_cts60m00.atddatprg,
                                           w_cts60m00.atdhorprg,
                                           w_cts60m00.atdpvtretflg)
                                 returning w_cts60m00.atdhorpvt,
                                           w_cts60m00.atddatprg,
                                           w_cts60m00.atdhorprg,
                                           w_cts60m00.atdpvtretflg
                           else
                              call cts02m08(w_cts60m00.atdfnlflg,
                                            d_cts60m00.imdsrvflg,
                                            m_altcidufd,
                                            d_cts60m00.prslocflg,
                                            w_cts60m00.atdhorpvt,
                                            w_cts60m00.atddatprg,
                                            w_cts60m00.atdhorprg,
                                            w_cts60m00.atdpvtretflg,
                                            m_rsrchvant,
                                            m_operacao,
                                            "",
                                            a_cts60m00[1].cidnom,
                                            a_cts60m00[1].ufdcod,
                                            "",   # codigo de assistencia, nao existe no Ct24h
                                            d_cts60m00.vclcoddig,
                                            w_cts60m00.ctgtrfcod,
                                            d_cts60m00.imdsrvflg,
                                            a_cts60m00[1].c24lclpdrcod,
                                            a_cts60m00[1].lclltt,
                                            a_cts60m00[1].lcllgt,
                                            g_documento.ciaempcod,
                                            d_cts60m00.atdsrvorg,
                                            d_cts60m00.asitipcod,
                                            "",   # natureza somente RE
                                            "")   # sub-natureza somente RE
                                  returning w_cts60m00.atdhorpvt,
                                            w_cts60m00.atddatprg,
                                            w_cts60m00.atdhorprg,
                                            w_cts60m00.atdpvtretflg,
                                            d_cts60m00.imdsrvflg,
                                            m_rsrchv,
                                            m_operacao,
                                            m_altdathor
                           end if
                           ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)

                           if d_cts60m00.frmflg = "S" then
                              call cts11g00(w_cts60m00.lignum)
                              let int_flag = true
                           end if

                           call cts60m00_bkp_info_dest(2, hist_cts60m00.*)
                              returning hist_cts60m00.*

                           exit input

                        else

                           let m_grava_hist   = true
                           let m_srv_acionado = false

                           let m_subbairro[2].lclbrrnom = a_cts60m00[2].lclbrrnom
                           call cts06g10_monta_brr_subbrr(a_cts60m00[2].brrnom,
                                                          a_cts60m00[2].lclbrrnom)
                                returning a_cts60m00[2].lclbrrnom

                           let a_cts60m00[2].lgdtxt = a_cts60m00[2].lgdtip clipped, " ",
                                                      a_cts60m00[2].lgdnom clipped, " ",
                                                      a_cts60m00[2].lgdnum using "<<<<#"

                           if a_cts60m00[2].lclltt <> a_cts60m00[3].lclltt or
                              a_cts60m00[2].lcllgt <> a_cts60m00[3].lcllgt or
                              (a_cts60m00[3].lclltt is null                and
                               a_cts60m00[2].lclltt is not null)           or
                              (a_cts60m00[3].lcllgt is null                and
                               a_cts60m00[2].lcllgt is not null)           then

                              #Verifica Kilometragem
                              if g_documento.aplnumdig is not null then
                                 call cts00m33_calckm("",
                                                      a_cts60m00[1].lclltt,
                                                      a_cts60m00[1].lcllgt,
                                                      a_cts60m00[2].lclltt,
                                                      a_cts60m00[2].lcllgt,
                                                      m_limites_plano.socqlmqtd)
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
                               if w_cts60m00.socvclcod is null then
                                  select socvclcod
                                    into w_cts60m00.socvclcod
                                    from datmsrvacp acp
                                   where acp.atdsrvnum = g_documento.atdsrvnum
                                     and acp.atdsrvano = g_documento.atdsrvano
                                     and acp.atdsrvseq = (select max(atdsrvseq)
                                                            from datmsrvacp acp1
                                                           where acp1.atdsrvnum = acp.atdsrvnum
                                                             and acp1.atdsrvano = acp.atdsrvano)
                               end if

                               #display 'w_cts60m00.socvclcod ', w_cts60m00.socvclcod

                                    select mdtcod
                                    into m_mdtcod
                                    from datkveiculo
                                    where socvclcod = w_cts60m00.socvclcod

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
                                    and cpocod = w_cts60m00.vclcorcod

                                    select empnom
                                    into l_ciaempnom
                                    from gabkemp
                                    where empcod  = g_documento.ciaempcod


                                    whenever error stop

                                    let l_dtalt = today
                                    let l_hralt = current
                                    let l_lgdtxtcl = a_cts60m00[2].lgdtip clipped, " ",
                                                     a_cts60m00[2].lgdnom clipped, " ",
                                                     a_cts60m00[2].lgdnum using "<<<<#", " ",
                                                     a_cts60m00[2].endcmp clipped


                                    let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                                  l_ciaempnom clipped,
                                                  '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             		  	    let l_msgaltend = l_texto clipped
                                      ," QRU: ", d_cts60m00.atdsrvorg using "&&"
                                           ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                           ,"-", g_documento.atdsrvano using "&&"
                                      ," QTR: ", l_dtalt, " ", l_hralt
                                      ," QNC: ", d_cts60m00.nom             clipped, " "
                                               , d_cts60m00.vcldes          clipped, " "
                                               , d_cts60m00.vclanomdl       clipped, " "
                                      ," QNR: ", d_cts60m00.vcllicnum       clipped, " "
                                               , l_vclcordes       clipped, " "
                                      ," QTI: ", a_cts60m00[2].lclidttxt       clipped, " - "
                                               , l_lgdtxtcl                 clipped, " - "
                                               , a_cts60m00[2].brrnom          clipped, " - "
                                               , a_cts60m00[2].cidnom          clipped, " - "
                                               , a_cts60m00[2].ufdcod          clipped, " "
                                      ," Ref: ", a_cts60m00[2].lclrefptotxt    clipped, " "
                                     ," Resp: ", a_cts60m00[2].lclcttnom       clipped, " "
                                     ," Tel: (", a_cts60m00[2].dddcod          clipped, ") "
                                               , a_cts60m00[2].lcltelnum       clipped, " "
                                    ," Acomp: ", d_cts60m00.rmcacpflg          clipped, "#"


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

                        call cts60m00_bkp_info_dest(2, hist_cts60m00.*)
                           returning hist_cts60m00.*

                        let m_srv_acionado = true

                     end if
                  else
                     let m_srv_acionado = false
                  end if

               else
                  error 'Erro ao buscar tipo de atendimento'
                  let m_srv_acionado = true
               end if

            end if
            #Fim Projeto alteracao cadastro de destino

            if a_cts60m00[2].cidnom is not null and
               a_cts60m00[2].ufdcod is not null then
               call cts14g00 (d_cts60m00.c24astcod,
                              "","","","",
                              a_cts60m00[2].cidnom,
                              a_cts60m00[2].ufdcod,
                              "S",
                              ws.dtparam)
            end if

         end if
      end if

   on key (F9)
      if mr_geral.atdsrvnum is null  or
         mr_geral.atdsrvano is null  then
         if cpl_atdsrvnum is not null  or
            cpl_atdsrvano is not null  then
            error " Servico ja' selecionado para copia!"
         else
            call cts16g00 (mr_geral.succod   ,
                           mr_geral.ramcod   ,
                           mr_geral.aplnumdig,
                           mr_geral.itmnumdig,
                           4                    ,  # atdsrvorg (REMOCAO)
                           d_cts60m00.vcllicnum ,
                           7, ""                )  # nr.dias p/pesquisa
                 returning cpl_atdsrvnum, cpl_atdsrvano, cpl_atdsrvorg

            if cpl_atdsrvorg <> 1 and
               cpl_atdsrvorg <> 2 and
               cpl_atdsrvorg <> 4 and
               cpl_atdsrvorg <> 6 then
               initialize cpl_atdsrvnum, cpl_atdsrvano to null
            end if

            #------------------------------------------------------------
            # Informacoes do local da ocorrencia
            #------------------------------------------------------------
            if cpl_atdsrvnum is not null or
               cpl_atdsrvano is not null then
               call ctx04g00_local_gps(cpl_atdsrvnum,
                                       cpl_atdsrvano,
                                       1)
                             returning a_cts60m00[1].lclidttxt
                                      ,a_cts60m00[1].lgdtip
                                      ,a_cts60m00[1].lgdnom
                                      ,a_cts60m00[1].lgdnum
                                      ,a_cts60m00[1].lclbrrnom
                                      ,a_cts60m00[1].brrnom
                                      ,a_cts60m00[1].cidnom
                                      ,a_cts60m00[1].ufdcod
                                      ,a_cts60m00[1].lclrefptotxt
                                      ,a_cts60m00[1].endzon
                                      ,a_cts60m00[1].lgdcep
                                      ,a_cts60m00[1].lgdcepcmp
                                      ,a_cts60m00[1].lclltt
                                      ,a_cts60m00[1].lcllgt
                                      ,a_cts60m00[1].dddcod
                                      ,a_cts60m00[1].lcltelnum
                                      ,a_cts60m00[1].lclcttnom
                                      ,a_cts60m00[1].c24lclpdrcod
                                      ,a_cts60m00[1].celteldddcod
                                      ,a_cts60m00[1].celtelnum # Amilton
                                      ,a_cts60m00[1].endcmp
                                      ,ws.sqlcode
                                      ,a_cts60m00[1].emeviacod

               select ofnnumdig into a_cts60m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = cpl_atdsrvano
                  and atdsrvnum = cpl_atdsrvnum
                  and c24endtip = 1

               if ws.sqlcode <> 0  then
                  error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                  prompt "" for char promptX
                  initialize hist_cts60m00.* to null
                  return hist_cts60m00.*
               end if

               let a_cts60m00[1].lgdtxt = a_cts60m00[1].lgdtip clipped, " ",
                                          a_cts60m00[1].lgdnom clipped, " ",
                                          a_cts60m00[1].lgdnum using "<<<<#"

               #-----------------------------------------------------------
               # Informacoes do local de destino
               #-----------------------------------------------------------
               call ctx04g00_local_gps(cpl_atdsrvnum,
                                       cpl_atdsrvano,
                                       2)
                             returning a_cts60m00[2].lclidttxt
                                      ,a_cts60m00[2].lgdtip
                                      ,a_cts60m00[2].lgdnom
                                      ,a_cts60m00[2].lgdnum
                                      ,a_cts60m00[2].lclbrrnom
                                      ,a_cts60m00[2].brrnom
                                      ,a_cts60m00[2].cidnom
                                      ,a_cts60m00[2].ufdcod
                                      ,a_cts60m00[2].lclrefptotxt
                                      ,a_cts60m00[2].endzon
                                      ,a_cts60m00[2].lgdcep
                                      ,a_cts60m00[2].lgdcepcmp
                                      ,a_cts60m00[2].lclltt
                                      ,a_cts60m00[2].lcllgt
                                      ,a_cts60m00[2].dddcod
                                      ,a_cts60m00[2].lcltelnum
                                      ,a_cts60m00[2].lclcttnom
                                      ,a_cts60m00[2].c24lclpdrcod
                                      ,a_cts60m00[2].celteldddcod
                                      ,a_cts60m00[2].celtelnum
                                      ,a_cts60m00[2].endcmp
                                      ,ws.sqlcode
                                      ,a_cts60m00[2].emeviacod

               # Prepare
               select ofnnumdig into a_cts60m00[2].ofnnumdig
                 from datmlcl
                where atdsrvano = cpl_atdsrvano
                  and atdsrvnum = cpl_atdsrvnum
                  and c24endtip = 2

               if ws.sqlcode = notfound   then
                  let d_cts60m00.dstflg = "N"
               else
                  if ws.sqlcode = 0   then
                     let d_cts60m00.dstflg = "S"
                  else
                     error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
                     prompt "" for char promptX
                     initialize hist_cts60m00.* to null
                     return hist_cts60m00.*
                  end if
               end if

               let a_cts60m00[2].lgdtxt = a_cts60m00[2].lgdtip clipped, " ",
                                          a_cts60m00[2].lgdnom clipped, " ",
                                          a_cts60m00[2].lgdnum using "<<<<#"

               call cts16g00_atendimento(cpl_atdsrvnum, cpl_atdsrvano)
                               returning d_cts60m00.nom,
                                         w_cts60m00.vclcorcod,
                                         d_cts60m00.vclcordes


               display by name d_cts60m00.servico thru d_cts60m00.bocflg
               display by name a_cts60m00[1].lgdtxt
               display by name a_cts60m00[1].lclbrrnom
               display by name a_cts60m00[1].endzon
               display by name a_cts60m00[1].cidnom
               display by name a_cts60m00[1].ufdcod
               display by name a_cts60m00[1].lclrefptotxt
               display by name a_cts60m00[1].lclcttnom
               display by name a_cts60m00[1].dddcod
               display by name a_cts60m00[1].lcltelnum
               display by name a_cts60m00[1].celteldddcod
               display by name a_cts60m00[1].celtelnum
               display by name a_cts60m00[1].endcmp

            end if
         end if
      else
         if d_cts60m00.atdlibflg = "N" then
            error " Servico nao liberado!"
         else
            call cta00m06_acionamento(g_issk.dptsgl)
            returning l_acesso

            if l_acesso = true then
               call cts00m02(mr_geral.atdsrvnum, mr_geral.atdsrvano, 0 )
            else
               call cts00m02(mr_geral.atdsrvnum, mr_geral.atdsrvano, 2 )
            end if

         end if
      end if

 end input

 if int_flag then
    error " Operacao cancelada!"
    initialize hist_cts60m00.* to null
 end if

return hist_cts60m00.*

end function

#-----------------------------------------#
function cts60m00_display_I30(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         c24astcod    like datmligacao.c24astcod,
         c24astdes    like datkassunto.c24astdes,
         c24pbmcod    like datrsrvpbm.c24pbmcod,
         atddfttxt    like datmservico.atddfttxt,
         atdrsdflg    like datmservico.atdrsdflg
  end record

  display "LAUDO - PORTO SOCORRO" to titulo
  display lr_parametro.c24astcod to c24astcod
  display lr_parametro.c24astdes to c24astdes

  display "Problema.:"          to problema
  display lr_parametro.c24pbmcod to c24pbmcod
  display lr_parametro.atddfttxt to atddfttxt

  display "Em Resid..:"          to em_residencia
  display lr_parametro.atdrsdflg to atdrsdflg

  display "" to vitimas
  display "" to sinvitflg

  display "" to bo
  display "" to bocflg

end function

#-----------------------------------------#
function cts60m00_display_I03(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         c24astcod    like datmligacao.c24astcod,
         c24astdes    like datkassunto.c24astdes,
         sinvitflg    like datmservicocmp.sinvitflg,
         bocflg       like datmservicocmp.bocflg
  end record

  display "  LAUDO DE SERVICO - REMOCAO  " to titulo
  display lr_parametro.c24astcod to c24astcod
  display lr_parametro.c24astdes to c24astdes

  display "" to problema
  display "" to c24pbmcod
  display "" to atddfttxt

  display "" to em_residencia
  display "" to atdrsdflg

  display "Vitimas:"             to vitimas
  display lr_parametro.sinvitflg to sinvitflg

  display "B.O:"              to bo
  display lr_parametro.bocflg to bocflg

end function


#--------------------------------#
 function cts60m00_calckm(param)
#--------------------------------#

     define param record
         flag char(01)
     end record

     define lr_km record
            kmlimite decimal (8,4),
            qtde     integer
     end record

     define l_resultado  smallint,
            l_mensagem   char(50),
            l_azlaplcod  integer,
            l_doc_handle integer,
            l_tipo_rota  char(07),
            l_dstqtd     decimal(8,4),
            l_km1        decimal(5,0),
            l_km2        decimal(5,0),
            l_dif        decimal(5,0),
            l_tempo      decimal(6,1),
            l_rota_final char(01),
            l_confirma   char(01),
            l_msg        char(40),
            l_msg2       char(40)

  if mr_geral.aplnumdig is not null then



     if ctx25g05_rota_ativa() then
        let  l_tipo_rota = ctx25g05_tipo_rota()
        call ctx25g02(a_cts60m00[1].lclltt,
                      a_cts60m00[1].lcllgt,
                      a_cts60m00[2].lclltt,
                      a_cts60m00[2].lcllgt,
                      l_tipo_rota,
                      0)

             returning l_dstqtd,
                       l_tempo,
                       l_rota_final
     else
        call cts18g00(a_cts60m00[1].lclltt,
                      a_cts60m00[1].lcllgt,
                      a_cts60m00[2].lclltt,
                      a_cts60m00[2].lcllgt)

             returning l_dstqtd
     end if

     let lr_km.kmlimite = m_limites_plano.socqlmqtd

     if  l_dstqtd > lr_km.kmlimite then
         let l_km1 = l_dstqtd
         let l_km2 = lr_km.kmlimite
         let l_dif = l_km1 - l_km2
         let l_msg = "Limite = ",l_km2 using "<<<<#",
                     " Calculado = ",l_km1 using "<<<<#"
         let l_msg2= " Diferenca Aproximada = ",l_dif  using "<<<<#"

         if param.flag is null then
            call cts08g01("A","N","LIMITE DE KM EXCEDIDO. O VALOR DEVERA" ,
                          " SER NEGOCIADO COM O PRESTADOR.",
                          l_msg, l_msg2)
                 returning l_confirma
         else
            call cts08g01("A","N","","",
                          l_msg,"")
                 returning l_confirma
         end if

     end if
  end if

 end function

function cts60m00_grava_dados(ws,hist_cts60m00)

define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        atdtip          like datmservico.atdtip    ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        c24txtseq       like datmservhist.c24txtseq,
        vclatmflg       smallint                   ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq
 end record

  define lr_ret        record
    retorno           smallint
   ,mensagem          char(100)
   ,atdsrvnum         like datmservico.atdsrvnum
   ,atdsrvano         like datmservico.atdsrvano
 end record


 define hist_cts60m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define l_ret       smallint,
        l_mensagem  char(60)




 initialize lr_ret.* to null
 initialize hist_cts60m00.* to null
 let l_ret = null
 let l_mensagem = null

 if mr_geral.c24astcod = 'IAP' and
      m_multiplo = "S" then
      let w_cts60m00.atdprscod = null
      let w_cts60m00.c24nomctt = null
      let w_cts60m00.socvclcod = null
      let w_cts60m00.srrcoddig = null
   end if

 while true

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work
   call cts10g03_numeracao( 2, ws.atdtip )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlcode  ,
                  ws.msg

   if  ws.sqlcode = 0  then
       commit work
   else
       let ws.msg = "cts60m00 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let mr_geral.lignum    = ws.lignum
   let g_documento.lignum = ws.lignum
   let aux_atdsrvnum      = ws.atdsrvnum
   let aux_atdsrvano      = ws.atdsrvano

 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( mr_geral.lignum      ,
                           w_cts60m00.data         ,
                           w_cts60m00.hora         ,
                           mr_geral.c24soltipcod,
                           mr_geral.solnom      ,
                           mr_geral.c24astcod   ,
                           w_cts60m00.funmat       ,
                           mr_geral.ligcvntip   ,
                           g_c24paxnum             ,
                           aux_atdsrvnum           ,
                           aux_atdsrvano           ,
                           "","","",""             ,
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


   call cts10g02_grava_servico( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                mr_geral.soltip  ,     # atdsoltip
                                mr_geral.solnom  ,     # c24solnom
                                w_cts60m00.vclcorcod,
                                w_cts60m00.funmat   ,
                                d_cts60m00.atdlibflg,
                                d_cts60m00.atdlibhor,
                                d_cts60m00.atdlibdat,
                                w_cts60m00.data     ,     # atddat
                                w_cts60m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts60m00.atdhorpvt,
                                w_cts60m00.atddatprg,
                                w_cts60m00.atdhorprg,
                                ws.atdtip           ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts60m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts60m00.atdfnlflg,
                                w_cts60m00.atdfnlhor,
                                d_cts60m00.atdrsdflg,
                                d_cts60m00.atddfttxt,
                                ""                  ,     # atddoctxt
                                w_cts60m00.c24opemat,
                                d_cts60m00.nom      ,
                                d_cts60m00.vcldes   ,
                                d_cts60m00.vclanomdl,
                                d_cts60m00.vcllicnum,
                                d_cts60m00.corsus   ,
                                d_cts60m00.cornom   ,
                                w_cts60m00.cnldat   ,
                                ""                  ,     # pgtdat
                                w_cts60m00.c24nomctt,
                                w_cts60m00.atdpvtretflg,
                                w_cts60m00.atdvcltip,
                                d_cts60m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts60m00.vclcoddig,
                                d_cts60m00.srvprlflg,
                                ""                  ,     # srrcoddig
                                d_cts60m00.atdprinvlcod,
                                d_cts60m00.atdsrvorg    ) # ATDSRVORG
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

   call cts10g02_grava_loccnd(aux_atdsrvnum
                          ,aux_atdsrvano)
     returning ws.tabname, ws.sqlcode

    if ws.sqlcode <> 0 then
       display "ERRO (", ws.sqlcode ,") na gravacao da ", ws.tabname
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
    end if

   #---------------------------------------------------------------------------
   # Insere Motivo de Recusa ao CAPS nos servicos de Guincho
   #---------------------------------------------------------------------------
   if ws_mtvcaps is not null and
      ws_mtvcaps <> 0        then

      ---> Verifica se ja existe o mesmo motivo para a ligacao
      select lignum
        from datrligrcuccsmtv
       where lignum       = g_documento.lignum
         and rcuccsmtvcod = ws_mtvcaps
         and c24astcod    = mr_geral.c24astcod

      if sqlca.sqlcode <> 0 then

         whenever error continue
         insert into datrligrcuccsmtv (lignum
                                      ,rcuccsmtvcod
                                      ,c24astcod
                                      ,rcuccsmtvsubcod)
                               values (g_documento.lignum
                                      ,ws_mtvcaps
                                      ,mr_geral.c24astcod,
                                      0)
         whenever error stop
         if sqlca.sqlcode  <>  0  then
            error " Erro (", sqlca.sqlcode, ") na gravacao do",
                  " Motivo de Recusa do CAPS ou Car. AVISE A INFORMATICA!"
            rollback work
            prompt "" for char ws.promptX
            let ws.retorno = false

            exit while
         end if

      end if
   end if

   #------------------------------------------------------------------------------
 # Insere inf. de pagamentos na tabela dbscadtippgt  ## PSI207233
 #------------------------------------------------------------------------------
    if d_cts60m00.c24astcod = "I31" then


         let g_cc.anosrv = aux_atdsrvano
         let g_cc.nrosrv = aux_atdsrvnum

         insert into dbscadtippgt (anosrv,
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

        if  sqlca.sqlcode  <>  0  then
            error " Erro (", sqlca.sqlcode, ") na gravacao do",
                  " tipo de pagamento. AVISE A INFORMATICA!"
            rollback work
            #prompt "" for char ws.prompt_key
            let ws.retorno = false
            exit while
        end if
    end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if d_cts60m00.prslocflg = "S" then
      update datmservico set prslocflg = d_cts60m00.prslocflg,
                             socvclcod = w_cts60m00.socvclcod,
                             srrcoddig = w_cts60m00.srrcoddig
       where datmservico.atdsrvnum = aux_atdsrvnum
         and datmservico.atdsrvano = aux_atdsrvano
   end if

 #------------------------------------------------------------------------------
 # Grava problemas do servico
 #------------------------------------------------------------------------------
   if d_cts60m00.atdsrvorg = 1 then  # Laudo de Assistência
      call ctx09g02_inclui(aux_atdsrvnum,
                           aux_atdsrvano,
                           1, # Org. informacao 1-Segurado 2-Pst
                           d_cts60m00.c24pbmcod,
                           d_cts60m00.atddfttxt,
                           ""                  ) # Codigo prestador
           returning ws.sqlcode,
                     ws.tabname
      if  ws.sqlcode  <>  0  then
          error "ctx09g02_inclui", ws.sqlcode, ws.tabname
          rollback work
          prompt "" for char ws.promptX
          let ws.retorno = false
          exit while
      end if
   end if
 #------------------------------------------------------------------------------
 # GUINCHO PEQUENO e possui CAMBIO HIDRAMATICO, grava no historico do servico
 #------------------------------------------------------------------------------
   if  w_cts60m00.atdvcltip = 2  then
       if  ws.vclatmflg = 1  then

           call ctd07g01_ins_datmservhist(aux_atdsrvnum,
                                          aux_atdsrvano,
                                          g_issk.funmat,
                                          "VEICULO COM CAMBIO HIDRAMATICO/AUTOMATICO",
                                          w_cts60m00.data,
                                          w_cts60m00.hora,
                                          g_issk.empcod,
                                          g_issk.usrtip)

                returning l_ret,
                          l_mensagem

           if  l_ret  <>  1  then
               error l_mensagem, " - cts60m00 - AVISE A INFORMATICA!"
               rollback work
               prompt "" for char ws.promptX
               let ws.retorno = false
               exit while
           end if
       end if
   end if

 #------------------------------------------------------------------------------
 # Grava complemento do servico
 #------------------------------------------------------------------------------

     call cts10g02_grava_complemento_servico(aux_atdsrvnum
                                             ,aux_atdsrvano
                                             ,d_cts60m00.rmcacpflg
                                             ,w_cts60m00.vclcamtip
                                             ,w_cts60m00.vclcrcdsc
                                             ,w_cts60m00.vclcrgflg
                                             ,w_cts60m00.vclcrgpso
                                             ,d_cts60m00.sindat
                                             ,d_cts60m00.sinhor
                                             ,d_cts60m00.sinvitflg
                                             ,d_cts60m00.bocflg
                                             ,d_cts60m00.bocnum
                                             ,d_cts60m00.bocemi
                                             ,d_cts60m00.vcllibflg)
       returning  lr_ret.retorno,
                  lr_ret.mensagem



   if  lr_ret.retorno  <>  0  then
       error " Erro (", lr_ret.retorno, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   #-----------------------------------------------------------
   # Atualiza o CAPS do Complemento
   #-----------------------------------------------------------
    if m_cappstcod is not null then
        call cts00m42_grava_complemento_caps(m_cappstcod  ,
                                             aux_atdsrvnum,
                                             aux_atdsrvano)
    end if

 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 2
       if  a_cts60m00[arr_aux].operacao is null  then
           let a_cts60m00[arr_aux].operacao = "I"
       end if

        if g_documento.c24astcod = "IAP" and
           m_multiplo = 'S'              and
           arr_aux = 2                   then
           exit for
        end if


    if  (arr_aux = 1 and d_cts60m00.frmflg = "N") or arr_aux = 2 then
        let a_cts60m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    end if

       let ws.sqlcode = cts06g07_local( a_cts60m00[arr_aux].operacao
                                       ,aux_atdsrvnum
                                       ,aux_atdsrvano
                                       ,arr_aux
                                       ,a_cts60m00[arr_aux].lclidttxt
                                       ,a_cts60m00[arr_aux].lgdtip
                                       ,a_cts60m00[arr_aux].lgdnom
                                       ,a_cts60m00[arr_aux].lgdnum
                                       ,a_cts60m00[arr_aux].lclbrrnom
                                       ,a_cts60m00[arr_aux].brrnom
                                       ,a_cts60m00[arr_aux].cidnom
                                       ,a_cts60m00[arr_aux].ufdcod
                                       ,a_cts60m00[arr_aux].lclrefptotxt
                                       ,a_cts60m00[arr_aux].endzon
                                       ,a_cts60m00[arr_aux].lgdcep
                                       ,a_cts60m00[arr_aux].lgdcepcmp
                                       ,a_cts60m00[arr_aux].lclltt
                                       ,a_cts60m00[arr_aux].lcllgt
                                       ,a_cts60m00[arr_aux].dddcod
                                       ,a_cts60m00[arr_aux].lcltelnum
                                       ,a_cts60m00[arr_aux].lclcttnom
                                       ,a_cts60m00[arr_aux].c24lclpdrcod
                                       ,a_cts60m00[arr_aux].ofnnumdig
                                       ,a_cts60m00[arr_aux].emeviacod
                                       ,a_cts60m00[arr_aux].celteldddcod
                                       ,a_cts60m00[arr_aux].celtelnum
                                       ,a_cts60m00[arr_aux].endcmp) # Amilton

       if  ws.sqlcode is null  or
           ws.sqlcode <> 0     then
           if  arr_aux = 1  then
               error " Erro (", ws.sqlcode, ") na gravacao do",
                     " local de ocorrencia. AVISE A INFORMATICA!"
           else
               error " Erro (", ws.sqlcode, ") na gravacao do",
                     " local de destino. AVISE A INFORMATICA!"
           end if
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if mr_geral.c24astcod = 'IAP' and
      m_multiplo = "S" then
      let w_cts60m00.atdprscod = null
      let w_cts60m00.c24nomctt = null
      let w_cts60m00.socvclcod = null
      let w_cts60m00.srrcoddig = null
   end if

   if  w_cts60m00.atdetpcod is null  then
       if  d_cts60m00.atdlibflg = "S"  then
           let w_cts60m00.atdetpcod = 1
           let ws.etpfunmat = w_cts60m00.funmat
           let ws.atdetpdat = d_cts60m00.atdlibdat
           let ws.atdetphor = d_cts60m00.atdlibhor
       else
           let w_cts60m00.atdetpcod = 2
           let ws.etpfunmat = w_cts60m00.funmat
           let ws.atdetpdat = w_cts60m00.data
           let ws.atdetphor = w_cts60m00.hora
       end if
   else
      let w_retorno = cts10g04_insere_etapa( aux_atdsrvnum    ,
                                             aux_atdsrvano    ,
                                             1,
                                             " ",
                                             " ",
                                             " ",
                                             w_cts60m00.srrcoddig )

       if  w_retorno <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts60m00.cnldat
       let ws.atdetphor = w_cts60m00.atdfnlhor
       let ws.etpfunmat = w_cts60m00.c24opemat
   end if

   let w_retorno = cts10g04_insere_etapa( aux_atdsrvnum,
                                          aux_atdsrvano,
                                          w_cts60m00.atdetpcod,
                                          w_cts60m00.atdprscod,
                                          w_cts60m00.c24nomctt,
                                          w_cts60m00.socvclcod,
                                          w_cts60m00.srrcoddig )

   if w_retorno <>  0  then
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

       call cts10g02_grava_servico_apolice(aux_atdsrvnum     ,
                                           aux_atdsrvano     ,
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

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)


 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   if w_hist.hist1 is not null then   # registra o motivo da escolha oficina
      let ws.histerr = cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                                           w_cts60m00.data  , w_cts60m00.hora,
                                           w_cts60m00.funmat, w_hist.* )
   end if
   let ws.histerr = cts10g02_historico( aux_atdsrvnum    ,
                                        aux_atdsrvano    ,
                                        w_cts60m00.data  ,
                                       #current          ,
                                        w_cts60m00.hora  ,
                                        w_cts60m00.funmat,
                                        hist_cts60m00.*   )

   #-----------------------------------------------
   # Aciona Servico automaticamente
   #-----------------------------------------------
 # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  if cts34g00_acion_auto (d_cts60m00.atdsrvorg,
                          a_cts60m00[1].cidnom,
                          a_cts60m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (d_cts60m00.atdsrvorg,
                                         mr_geral.c24astcod,
                                         d_cts60m00.asitipcod,
                                         a_cts60m00[1].lclltt,
                                         a_cts60m00[1].lcllgt,
                                         d_cts60m00.prslocflg,
                                         d_cts60m00.frmflg,
                                         aux_atdsrvnum,
                                         aux_atdsrvano,
                                         " ",
                                         d_cts60m00.vclcoddig,
                                         d_cts60m00.camflg) then
        #servico nao pode ser acionado automaticamente
     else
        let m_aciona = 'S'
     end if
  end if
   exit while
 end while

 let lr_ret.retorno = 1
 let lr_ret.mensagem = ' '
 let lr_ret.atdsrvnum = aux_atdsrvnum
 let lr_ret.atdsrvano = aux_atdsrvano

 return lr_ret.*



end function

function cts60m00_desbloqueia_servico(lr_param)

   define lr_param record
          atdsrvnum like datmservico.atdsrvnum,
          atdsrvano like datmservico.atdsrvano
   end record


   initialize mr_retorno.* to null

   if m_prep_sql is null or
      m_prep_sql = false then
      call cts60m00_prepare()
   end if

   whenever error continue
      execute pcts60m00004 using lr_param.atdsrvnum,
                                 lr_param.atdsrvano
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let mr_retorno.erro = sqlca.sqlcode
         let mr_retorno.mens = "Erro <",mr_retorno.erro clipped ," > no desbloqueio do servico. AVISE A INFORMATICA!"
         call errorlog(lr_param.atdsrvnum)
         call errorlog(mr_retorno.mens)
         error mr_retorno.mens sleep 2
      else
        let mr_retorno.erro = sqlca.sqlcode
        let mr_retorno.mens = "Erro <",mr_retorno.erro clipped ," > no desbloqueio do servico. AVISE A INFORMATICA!"
        call errorlog(mr_retorno.mens)
        call errorlog(lr_param.atdsrvnum)
        error mr_retorno.mens sleep 2
      end if
   else
      call cts00g07_apos_servdesbloqueia(lr_param.atdsrvnum,lr_param.atdsrvano)
   end if

end function

function cts60m00_grava_ligacao_itr(ws)

define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        atdtip          like datmservico.atdtip    ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        c24txtseq       like datmservhist.c24txtseq,
        vclatmflg       smallint                   ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq
 end record

 define l_ret       smallint,
        l_mensagem  char(60)


 let l_ret = null
 let l_mensagem = null




 while true

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work


   call cts10g03_numeracao( 2, ws.atdtip )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlcode  ,
                  ws.msg

   if  ws.sqlcode = 0  then
       commit work
   else
       let ws.msg = "cts60m00 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let mr_geral.lignum    = ws.lignum




 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( mr_geral.lignum      ,
                           w_cts60m00.data         ,
                           w_cts60m00.hora         ,
                           mr_geral.c24soltipcod,
                           mr_geral.solnom      ,
                           "ITR"   ,
                           w_cts60m00.funmat       ,
                           mr_geral.ligcvntip   ,
                           g_c24paxnum             ,
                           ""           ,
                           ""           ,
                           "","","",""             ,
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
   exit while
 end while
 commit work

   # Grava Atendimento para Ligacao
   begin work
   if (mr_geral.lignum is not null and
       mr_geral.lignum <> 0)       then
       if (g_documento.atdnum is not null and
           g_documento.atdnum <> 0 ) then
           call ctd25g00_insere_atendimento(g_documento.atdnum
                                           ,mr_geral.lignum)
                returning l_ret
                         ,l_mensagem
       end if
   end if

   if l_ret = 0 then
      commit work
   else
      rollback work
   end if



end function
#--------------------------------------------------------#
 function cts60m00_bkp_info_dest(l_tipo, hist_cts60m00)
#--------------------------------------------------------#
  define hist_cts60m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts60m00_bkp      to null
     initialize m_hist_cts60m00_bkp to null

     let a_cts60m00_bkp[1].lclidttxt    = a_cts60m00[2].lclidttxt
     let a_cts60m00_bkp[1].cidnom       = a_cts60m00[2].cidnom
     let a_cts60m00_bkp[1].ufdcod       = a_cts60m00[2].ufdcod
     let a_cts60m00_bkp[1].brrnom       = a_cts60m00[2].brrnom
     let a_cts60m00_bkp[1].lclbrrnom    = a_cts60m00[2].lclbrrnom
     let a_cts60m00_bkp[1].endzon       = a_cts60m00[2].endzon
     let a_cts60m00_bkp[1].lgdtip       = a_cts60m00[2].lgdtip
     let a_cts60m00_bkp[1].lgdnom       = a_cts60m00[2].lgdnom
     let a_cts60m00_bkp[1].lgdnum       = a_cts60m00[2].lgdnum
     let a_cts60m00_bkp[1].lgdcep       = a_cts60m00[2].lgdcep
     let a_cts60m00_bkp[1].lgdcepcmp    = a_cts60m00[2].lgdcepcmp
     let a_cts60m00_bkp[1].lclltt       = a_cts60m00[2].lclltt
     let a_cts60m00_bkp[1].lcllgt       = a_cts60m00[2].lcllgt
     let a_cts60m00_bkp[1].lclrefptotxt = a_cts60m00[2].lclrefptotxt
     let a_cts60m00_bkp[1].lclcttnom    = a_cts60m00[2].lclcttnom
     let a_cts60m00_bkp[1].dddcod       = a_cts60m00[2].dddcod
     let a_cts60m00_bkp[1].lcltelnum    = a_cts60m00[2].lcltelnum
     let a_cts60m00_bkp[1].c24lclpdrcod = a_cts60m00[2].c24lclpdrcod
     let a_cts60m00_bkp[1].ofnnumdig    = a_cts60m00[2].ofnnumdig
     let a_cts60m00_bkp[1].celteldddcod = a_cts60m00[2].celteldddcod
     let a_cts60m00_bkp[1].celtelnum    = a_cts60m00[2].celtelnum
     let a_cts60m00_bkp[1].endcmp       = a_cts60m00[2].endcmp
     let m_hist_cts60m00_bkp.hist1      = hist_cts60m00.hist1
     let m_hist_cts60m00_bkp.hist2      = hist_cts60m00.hist2
     let m_hist_cts60m00_bkp.hist3      = hist_cts60m00.hist3
     let m_hist_cts60m00_bkp.hist4      = hist_cts60m00.hist4
     let m_hist_cts60m00_bkp.hist5      = hist_cts60m00.hist5
     let a_cts60m00_bkp[1].emeviacod    = a_cts60m00[2].emeviacod

     return hist_cts60m00.*

  else

     let a_cts60m00[2].lclidttxt    = a_cts60m00_bkp[1].lclidttxt
     let a_cts60m00[2].cidnom       = a_cts60m00_bkp[1].cidnom
     let a_cts60m00[2].ufdcod       = a_cts60m00_bkp[1].ufdcod
     let a_cts60m00[2].brrnom       = a_cts60m00_bkp[1].brrnom
     let a_cts60m00[2].lclbrrnom    = a_cts60m00_bkp[1].lclbrrnom
     let a_cts60m00[2].endzon       = a_cts60m00_bkp[1].endzon
     let a_cts60m00[2].lgdtip       = a_cts60m00_bkp[1].lgdtip
     let a_cts60m00[2].lgdnom       = a_cts60m00_bkp[1].lgdnom
     let a_cts60m00[2].lgdnum       = a_cts60m00_bkp[1].lgdnum
     let a_cts60m00[2].lgdcep       = a_cts60m00_bkp[1].lgdcep
     let a_cts60m00[2].lgdcepcmp    = a_cts60m00_bkp[1].lgdcepcmp
     let a_cts60m00[2].lclltt       = a_cts60m00_bkp[1].lclltt
     let a_cts60m00[2].lcllgt       = a_cts60m00_bkp[1].lcllgt
     let a_cts60m00[2].lclrefptotxt = a_cts60m00_bkp[1].lclrefptotxt
     let a_cts60m00[2].lclcttnom    = a_cts60m00_bkp[1].lclcttnom
     let a_cts60m00[2].dddcod       = a_cts60m00_bkp[1].dddcod
     let a_cts60m00[2].lcltelnum    = a_cts60m00_bkp[1].lcltelnum
     let a_cts60m00[2].c24lclpdrcod = a_cts60m00_bkp[1].c24lclpdrcod
     let a_cts60m00[2].ofnnumdig    = a_cts60m00_bkp[1].ofnnumdig
     let a_cts60m00[2].celteldddcod = a_cts60m00_bkp[1].celteldddcod
     let a_cts60m00[2].celtelnum    = a_cts60m00_bkp[1].celtelnum
     let a_cts60m00[2].endcmp       = a_cts60m00_bkp[1].endcmp
     let hist_cts60m00.hist1        = m_hist_cts60m00_bkp.hist1
     let hist_cts60m00.hist2        = m_hist_cts60m00_bkp.hist2
     let hist_cts60m00.hist3        = m_hist_cts60m00_bkp.hist3
     let hist_cts60m00.hist4        = m_hist_cts60m00_bkp.hist4
     let hist_cts60m00.hist5        = m_hist_cts60m00_bkp.hist5
     let a_cts60m00[2].emeviacod    = a_cts60m00_bkp[1].emeviacod

     return hist_cts60m00.*

  end if

end function

#-----------------------------------------#
 function cts60m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open ccts60m00005 using g_documento.atdsrvnum
                         ,g_documento.atdsrvano
                         ,g_documento.atdsrvnum
                         ,g_documento.atdsrvano

  whenever error continue
  fetch ccts60m00005 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT ccts60m00005: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts60m00() / C24 / cts60m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts60m00_verifica_op_ativa()
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
 function cts60m00_grava_historico()
#-----------------------------------------#
  define la_cts60m00       array[12] of record
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

  initialize la_cts60m00  to null
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

  let la_cts60m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts60m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts60m00[03].descricao = "."
  let la_cts60m00[04].descricao = "DE:"
  let la_cts60m00[05].descricao = "CEP: ", a_cts60m00_bkp[1].lgdcep clipped," - ",a_cts60m00_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts60m00_bkp[1].cidnom clipped," UF: ",a_cts60m00_bkp[1].ufdcod clipped
  let la_cts60m00[06].descricao = "Logradouro: ",a_cts60m00_bkp[1].lgdtip clipped," ",a_cts60m00_bkp[1].lgdnom clipped," "
                                                ,a_cts60m00_bkp[1].lgdnum clipped," ",a_cts60m00_bkp[1].brrnom
  let la_cts60m00[07].descricao = "."
  let la_cts60m00[08].descricao = "PARA:"
  let la_cts60m00[09].descricao = "CEP: ", a_cts60m00[2].lgdcep clipped," - ", a_cts60m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts60m00[2].cidnom clipped," UF: ",a_cts60m00[2].ufdcod  clipped
  let la_cts60m00[10].descricao = "Logradouro: ",a_cts60m00[2].lgdtip clipped," ",a_cts60m00[2].lgdnom clipped," "
                                                ,a_cts60m00[2].lgdnum clipped," ",a_cts60m00[2].brrnom
  let la_cts60m00[11].descricao = "."
  let la_cts60m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts60m00[l_ind].descricao
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
  let lr_de.lgdcep    = a_cts60m00_bkp[1].lgdcep clipped,"-",a_cts60m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts60m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts60m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts60m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts60m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts60m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts60m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts60m00[2].lgdcep clipped,"-", a_cts60m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts60m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts60m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts60m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts60m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts60m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts60m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function

#---------------------------------------------------------
 function cts60m00_valida_I16(lr_param)
#---------------------------------------------------------
define lr_param  record
   rsrcaogrtcod like datkitarsrcaogar.rsrcaogrtcod     ,
   itaclisgmcod like datrclisgmasiplnntz.itaclisgmcod
end record
       if not cts12g10_verifica_correntista(lr_param.rsrcaogrtcod) then
       	    error "Assunto Liberado Somente para Correntista"
       	    return false
       end if
       return true
end function 