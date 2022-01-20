#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts65m00                                                   #
#Analista Resp : Junior (FORNAX)                                            #
#...........................................................................#
#Desenvolvimento:                                                           #
#Liberacao      :   /  /                                                    #
#---------------------------------------------------------------------------#
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
#Data       Autor Fabrica  Origem     Alteracao                             #
#---------- -------------- ---------- --------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#---------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Inclusao regulacao via AW    #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
#globals "/projetos/metodologia/D0609511/junior/ct24h/glct.4gl"

 define am_param       array[10] of record          #---> Array de retorno
        socntzcod      like datmsrvre.socntzcod
       ,socntzdes      like datksocntz.socntzdes
       ,espcod         like datmsrvre.espcod
       ,espdes         like dbskesp.espdes
       ,c24pbmcod      like datkpbm.c24pbmcod
       ,atddfttxt      like datmservico.atddfttxt
 end record

 define ms             record
        prompt_key     char(01)                   ,
        retorno        smallint                   ,
        lignum         like datmligacao.lignum    ,
        atdsrvnum      like datmservico.atdsrvnum ,
        atdsrvano      like datmservico.atdsrvano ,
        codigosql      integer                    ,
        tabname        like systables.tabname     ,
        msg            char(80)                   ,
        caddat         like datmligfrm.caddat     ,
        cadhor         like datmligfrm.cadhor     ,
        cademp         like datmligfrm.cademp     ,
        cadmat         like datmligfrm.cadmat     ,
        servico        char (08)                  ,
        grlchv         like igbkgeral.grlchv      ,
        grlinf         like igbkgeral.grlinf      ,
        atdsrvseq      like datmsrvacp.atdsrvseq  ,
        atdetpcod      like datmsrvacp.atdetpcod  ,
        etpfunmat      like datmsrvacp.funmat     ,
        atdetpdat      like datmsrvacp.atdetpdat  ,
        atdetphor      like datmsrvacp.atdetphor  ,
        histerr        smallint                   ,
        socvclcod      like datmsrvacp.socvclcod
 end record

 define mr_hist   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define d_cts65m00    record
    srvnum            char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    lclrscflg         char (01)                    ,
    orrdat            like datmsrvre.orrdat        ,
    servicorg         char(13)                     ,
    socntzcod         like datmsrvre.socntzcod     ,
    socntzdes         like datksocntz.socntzdes    ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    imdsrvflg         char (01)                    ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    prslocflg         char (01)                    ,
    atdtxt            char (65)                    ,
    srvretmtvcod      like datksrvret.srvretmtvcod ,
    srvretmtvdes      like datksrvret.srvretmtvdes ,
    espcod            like datmsrvre.espcod        ,
    espdes            like dbskesp.espdes          ,
    retprsmsmflg       like datmsrvre.retprsmsmflg
 end record

 define w_cts65m00    record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    viginc            like rsdmdocto.viginc        ,
    vigfnl            like rsdmdocto.vigfnl        ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    ligcvntip         like datmligacao.ligcvntip   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24opemat         like datmservico.c24opemat   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdprscod         like datmservico.atdprscod   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    prslocflg         char (01)                    ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    clscod            like datrsocntzsrvre.clscod  ,
    socvclcod         like datmsrvacp.socvclcod    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    atzendereco       dec(1,0)                     ,
    cartao            char(21)                     ,
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define a_cts65m00    array[2] of record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig,
    emeviacod         like datmlcl.emeviacod       ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp
 end record

 define lr_dados     record
        bnfnum       like datksegsau.bnfnum,
        crtsaunum    like datksegsau.crtsaunum,
        succod       like datksegsau.succod,
        ramcod       like datksegsau.ramcod,
        aplnumdig    like datksegsau.aplnumdig,
        crtstt       like datksegsau.crtstt,
        plncod       like datksegsau.plncod,
        segnom       like datksegsau.segnom,
        cgccpfnum    like datksegsau.cgccpfnum,
        cgcord       like datksegsau.cgcord,
        cgccpfdig    like datksegsau.cgccpfdig,
        empnom       like datksegsau.empnom,
        corsus       like datksegsau.corsus,
        cornom       like datksegsau.cornom,
        cntanvdat    like datksegsau.cntanvdat,
        lgdtip       like datksegsau.lgdtip,
        lgdnom       like datksegsau.lgdnom,
        lgdnum       like datksegsau.lgdnum,
        lclbrrnom    like datksegsau.lclbrrnom,
        cidnom       like datksegsau.cidnom,
        ufdcod       like datksegsau.ufdcod,
        lclrefptotxt like datksegsau.lclrefptotxt,
        endzon       like datksegsau.endzon,
        lgdcep       like datksegsau.lgdcep,
        lgdcepcmp    like datksegsau.lgdcepcmp,
        dddcod       like datksegsau.dddcod,
        lcltelnum    like datksegsau.lcltelnum,
        lclcttnom    like datksegsau.lclcttnom,
        lclltt       like datksegsau.lclltt,
        lcllgt       like datksegsau.lcllgt,
        incdat       like datksegsau.incdat,
        excdat       like datksegsau.excdat,
        brrnom       like datksegsau.brrnom,
        c24lclpdrcod like datksegsau.c24lclpdrcod
 end record

 define mr_rsc_re    record
        lclrsccod    like rlaklocal.lclrsccod
       ,lclnumseq    like datmsrvre.lclnumseq
       ,rmerscseq    like datmsrvre.rmerscseq
       ,rmeblcdes    like rsdmbloco.rmeblcdes
 end record

define
    aux_today           char (10),
    aux_hora            char (05),
    ws_acao             char (03),
    ws_acaorigem        char (03),
    ws_tela             char (03),
    cpl_atdsrvnum       like datmservico.atdsrvnum,
    cpl_atdsrvano       like datmservico.atdsrvano,
    cpl_atdsrvorg       like datmservico.atdsrvorg,
    ws_refatdsrvnum_ini like datmservico.atdsrvnum,
    ws_refatdsrvano_ini like datmservico.atdsrvano,
    ws_cgccpfnum        like aeikcdt.cgccpfnum    ,
    ws_cgccpfdig        like aeikcdt.cgccpfdig    ,
    flgcpl              smallint,
    m_rmemdlcod         like datrsocntzsrvre.rmemdlcod,
    m_prepara_sql       smallint,
    m_erro              smallint,
    m_clscod            like datrsocntzsrvre.clscod,
    m_atdfnlflg         like datmservico.atdfnlflg,
    m_flg_aciona        char(01),
    m_criou_tabela      smallint,
    m_salva_tab         smallint,
    m_salva_mlt         smallint,
    m_data              date,
    m_hora              datetime hour to minute,
    m_veiculo_aciona    like datkveiculo.socvclcod, #PSI202363
    m_confirma_alt_prog char(1),
    m_tem_outros_srv    char(1)

 define m_wk            record
    prporg              like rsdmdocto.prporg,
    prpnumdig           like rsdmdocto.prpnumdig
 end record

 define mr_salva   record
        lgdnom     like datmlcl.lgdnom
       ,lgdnum     like datmlcl.lgdnum
       ,brrnom     like datmlcl.brrnom
       ,lclbrrnom  like datmlcl.brrnom
       ,cidnom     like datmlcl.cidnom
       ,ufdcod     like datmlcl.ufdcod
       ,lgdcep     like datmlcl.lgdcep
       ,imdsrvflg  char(01)
       ,atddatprg  like datmservico.atddatprg
       ,atdhorprg  like datmservico.atdhorprg
       ,lclltt     like datmlcl.lclltt
       ,atdlibdat  like datmservico.atdlibdat
       ,atdlibhor  like datmservico.atdlibhor
       ,c24lclpdrcod like datmlcl.c24lclpdrcod
   end record

 define m_socntzcod   like datmsrvre.socntzcod

 define m_obter_mult smallint
     ,  m_acao       char(3)
     ,  m_tela       char(03)
     ,  m_tela2      char(03)
     ,  m_resultado  smallint
     ,  m_mensagem   char(100)
     ,  m_acntntqtd  like datmservico.acntntqtd
     ,  m_srv_acionado smallint
     ,  m_alt_end      char(1)
     ,  l_cortesia      smallint

 define am_cts29g00  array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

 define mr_cts08g01  record
    linha1          char (40),
    linha2          char (40),
    linha3          char (40),
    linha4          char (40)
 end record

 define lr_aux record
    succod          like datrligapol.succod,       # Codigo Sucursal
    ramcod          like datrligapol.ramcod,       # Codigo do Ramo
    aplnumdig       like datrligapol.aplnumdig,    # Numero Apolice
    itmnumdig       like datrligapol.itmnumdig,    # Numero do Item
    edsnumref       like datrligapol.edsnumref,    # Numero do Endosso
    prporg          like datrligprp.prporg,        # Origem da Proposta
    prpnumdig       like datrligprp.prpnumdig,     # Numero da Proposta
    fcapacorg       like datrligpac.fcapacorg,     # Origem PAC
    fcapacnum       like datrligpac.fcapacnum,     # Numero PAC
    lignum          like datmligacao.lignum
 end record

 define m_servico_original   like datratdmltsrv.atdsrvnum
       ,m_ano_original       like datratdmltsrv.atdsrvano

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_retctb83m00 smallint
 define m_c24astcodflag like datmligacao.c24astcod
 define m_imdsrvflg_ant char(1)

 define ml_srvabrprsinfflg like datrgrpntz.srvabrprsinfflg

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define l_min_atdhorprg   like datmservico.atdhorprg,
        l_max_atdhorprg   like datmservico.atdhorprg

 define m_confirma char(1)
 define m_acesso_ind  smallint
 define m_atdsrvorg   like datmservico.atdsrvorg

 define m_limite_plano record
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
      
#-----------------------------------------------#
 function cts65m00_prepara()
#-----------------------------------------------#
 define l_sql_stmt   char(1000)

 let l_sql_stmt = "select datmligacao.c24astcod ",
                  " from datmligacao ",
                  " where datmligacao.atdsrvnum  = ? ",
                  "  and datmligacao.atdsrvano  = ? ",
                  "  and datmligacao.lignum    <> 0 "
 prepare p_cts65m00_001 from l_sql_stmt
 declare c_cts65m00_001 cursor for p_cts65m00_001


 let l_sql_stmt = "select c24astcod from datmligacao ",
                  " where atdsrvnum = ? ",
                  " and  atdsrvano = ? "
  prepare p_cts65m00_002 from l_sql_stmt
  declare c_cts65m00_002 cursor for p_cts65m00_002


  let l_sql_stmt = " select grlinf ",
                   " from igbkgeral ",
                   " where  mducod = 'C24' ",
                   " and  grlchv = 'RADIO-DEMRE' "

  prepare p_cts65m00_003 from l_sql_stmt
  declare c_cts65m00_003 cursor for p_cts65m00_003


  let l_sql_stmt = " select atdetpcod  from datmsrvacp ",
                   "  where atdsrvnum = ?  ",
                   "  and atdsrvano = ?   ",
                   "  and atdsrvseq = (select max(atdsrvseq) ",
                   "                     from datmsrvacp  ",
                   "                    where atdsrvnum = ? ",
                   "                      and atdsrvano = ? )"
  prepare p_cts65m00_004 from l_sql_stmt
  declare c_cts65m00_004 cursor for p_cts65m00_004


 let l_sql_stmt = " update datmservico set c24opemat = null " ,
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? "
 prepare p_cts65m00_005 from l_sql_stmt


 let l_sql_stmt = " select nom,cornom,corsus,atddfttxt,funmat,asitipcod,",
                  " atddat,atdhor,atdlibflg,atdlibhor,atdlibdat,atdhorpvt,",
                  " atdpvtretflg,atddatprg,atdhorprg,atdfnlflg,atdprinvlcod,",
                  " atdprscod,prslocflg,acntntqtd,ciaempcod,empcod   ",
                  "  from datmservico ",
                  " where atdsrvnum = ?  " ,
                  " and atdsrvano = ? "
 prepare p_cts65m00_006 from l_sql_stmt
 declare c_cts65m00_006 cursor for p_cts65m00_006


 let l_sql_stmt = " select lclrsccod,orrdat,socntzcod,atdorgsrvnum, " ,
                  " atdorgsrvano,srvretmtvcod,espcod,retprsmsmflg   ",
                  " from datmsrvre ",
                  " where atdsrvnum = ?  ",
                  " and atdsrvano = ? "

 prepare p_cts65m00_007 from l_sql_stmt
 declare c_cts65m00_007 cursor for p_cts65m00_007


 let l_sql_stmt = " select srvretexcdes ",
                  " from datmsrvretexc ",
                  " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
 prepare p_cts65m00_008 from l_sql_stmt
 declare c_cts65m00_008 cursor for p_cts65m00_008

 let l_sql_stmt = " select srvretmtvdes ",
                  " from datksrvret ",
                  " where srvretmtvcod  = ? "
 prepare p_cts65m00_009 from l_sql_stmt
 declare c_cts65m00_009 cursor for p_cts65m00_009


 let l_sql_stmt = " select ofnnumdig ",
                  " from datmlcl ",
                  " where atdsrvano = ? ",
                  "  and atdsrvnum = ? ",
                  "  and c24endtip = 1 "
 prepare p_cts65m00_010 from l_sql_stmt
 declare c_cts65m00_010 cursor for p_cts65m00_010

 let l_sql_stmt = " select socntzdes  ",
                  " from datksocntz ",
                  " where socntzcod = ? "
 prepare p_cts65m00_011 from l_sql_stmt
 declare c_cts65m00_011 cursor for p_cts65m00_011

 let l_sql_stmt = " select asitipabvdes ",
                  " from datkasitip ",
                  " where asitipcod = ? "
 prepare p_cts65m00_012 from l_sql_stmt
 declare c_cts65m00_012 cursor for p_cts65m00_012

 let l_sql_stmt =  " select c24solnom, ligcvntip, c24astcod ",
                   " from datmligacao ",
                   " where lignum = ? "
 prepare p_cts65m00_013 from l_sql_stmt
 declare c_cts65m00_013 cursor for p_cts65m00_013

 let l_sql_stmt = " select funnom, dptsgl ",
                  " from isskfunc ",
                  " where empcod = ? ",
                  "  and funmat = ? "
 prepare p_cts65m00_014 from l_sql_stmt
 declare c_cts65m00_014 cursor for p_cts65m00_014

let l_sql_stmt = "  select cpodes   ",
                 " from iddkdominio ",
                 " where cponom = 'atdprinvlcod' ",
                 "  and cpocod = ? "
prepare p_cts65m00_015 from l_sql_stmt
declare c_cts65m00_015 cursor for p_cts65m00_015


let l_sql_stmt = " select c24pbmcod ",
                 " from datrsrvpbm " ,
                 " where atdsrvnum  = ? ",
                 "  and atdsrvano   = ? ",
                 "  and c24pbminforg = 1 ",
                 "  and c24pbmseq    = 1 "

prepare p_cts65m00_016 from l_sql_stmt
declare c_cts65m00_016 cursor for p_cts65m00_016


let l_sql_stmt = " select max(atdsrvseq) from datmsrvacp ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano  = ? "

prepare p_cts65m00_017 from l_sql_stmt
declare c_cts65m00_017 cursor for p_cts65m00_017

let l_sql_stmt = " select atdetpcod  from datmsrvacp ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = ? "
prepare p_cts65m00_018 from l_sql_stmt
declare c_cts65m00_018 cursor for p_cts65m00_018

let l_sql_stmt = " update datmservico set ( nom,cornom,corsus,atddfttxt,  ",
                 " atdlibflg,atdlibhor,atdlibdat,atdhorpvt,atdpvtretflg , ",
                 " atddatprg,atdhorprg,asitipcod,atdfnlflg) ",
                 " = ( ?,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ) ",
                 "  where atdsrvnum = ?  ",
                 "  and atdsrvano = ? "

prepare p_cts65m00_019 from l_sql_stmt

let l_sql_stmt = "update datmsrvre set (lclrsccod,orrdat,socntzcod, ",
                 " espcod,srvretmtvcod,retprsmsmflg) ",
                 "  = (? ,? ,? ,? ,? ,? ) ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts65m00_020 from l_sql_stmt

let l_sql_stmt = "delete from datmsrvretexc ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts65m00_021 from l_sql_stmt

let l_sql_stmt = " insert into datmsrvretexc ( atdsrvnum,atdsrvano, ",
                 " srvretexcdes,caddat,cademp,cadmat,cadusrtip   ) ",
                 " values ( ? , ? ,? ,? ,? ,? ,? ) "
prepare p_cts65m00_022 from l_sql_stmt

let l_sql_stmt = " select asitipabvdes "
                   ,"  from datkasitip "
                   ,"  where asitipcod = ? "
                   ,"    and asitipstt = 'A' "
prepare p_cts65m00_023 from l_sql_stmt
declare c_cts65m00_023 cursor for p_cts65m00_023

let l_sql_stmt = " select max(a.atdsrvnum),                  ",
                   "        a.atdsrvano                      ",
                   "   from datmservico  a,                  ",
                   "        datrservapol b,                  ",
                   "        datmligacao  d                   ",
                   "  where b.ramcod    = ?                  ",
                   "    and b.succod    = ?                  ",
                   "    and b.aplnumdig = ?                  ",
                   "    and b.itmnumdig = ?                  ",
                   "    and a.atdsrvnum = b.atdsrvnum        ",
                   "    and a.atdsrvano = b.atdsrvano        ",
                   "    and a.atdsrvnum = d.atdsrvnum        ",
                   "    and a.atdsrvano = d.atdsrvano        ",
                   "    and d.c24astcod not in ('PE1','PE2') ",
                   "    and a.atdsrvorg = 9                  ",
                   "  group by a.atdsrvano                   ",
                   "  order by a.atdsrvano desc              "
prepare p_cts65m00_024 from l_sql_stmt
declare c_cts65m00_024 cursor for p_cts65m00_024

let l_sql_stmt = ' select lgdtip,lgdnom,lgdnum,   ',
                   '        brrnom,lclbrrnom,cidnom,ufdcod,',
                   '        lgdcep,lgdcepcmp,lclrefptotxt,endcmp ',
                   '   from datmlcl                 ',
                   '  where atdsrvnum = ?           ',
                   '    and atdsrvano = ?           ',
                   '    and c24endtip = 1           '
 prepare p_cts65m00_025 from l_sql_stmt
 declare c_cts65m00_025 cursor for p_cts65m00_025

 let l_sql_stmt = " select segnumdig  from abbmdoc ",
                  " where succod  = ? ",
                  " and aplnumdig = ? ",
                  " and itmnumdig = ? ",
                  " and dctnumseq = ? "
 prepare p_cts65m00_026 from l_sql_stmt
 declare c_cts65m00_026 cursor for p_cts65m00_026

let l_sql_stmt = " select cgccpfnum, cgccpfdig ",
                 " from gsakseg ",
                 " where gsakseg.segnumdig = ? "
prepare p_cts65m00_027 from l_sql_stmt
declare c_cts65m00_027 cursor for p_cts65m00_027


let l_sql_stmt = " select gsakend.endlgdtip, gsakend.endlgd,gsakend.endnum, ",
                 " gsakend.endcmp, gsakend.endbrr, gsakend.endcid, ",
                 " gsakend.endufd, gsakend.endcep,gsakend.endcepcmp ",
                 " from gsakend ",
                 " where gsakend.segnumdig = ? ",
                 " and gsakend.endfld    = '1' "

prepare p_cts65m00_028 from l_sql_stmt
declare c_cts65m00_028 cursor for p_cts65m00_028

let l_sql_stmt = " select cornom from gcaksusep, gcakcorr ",
                 " where gcaksusep.corsus = ? and ",
                 " gcakcorr.corsuspcp = gcaksusep.corsuspcp "
prepare p_cts65m00_029 from l_sql_stmt
declare c_cts65m00_029 cursor for p_cts65m00_029

let l_sql_stmt = " select max(a.atdsrvnum)  ",
                    "       ,a.atdsrvano       ",
                    "   from datmservico  a    ",
                    "       ,datrservapol b    ",
                    "       ,datmsrvre    c    ",
                    "       ,datmligacao  d    ",
                    "  where b.ramcod    = ?   ",
                    "    and b.succod    = ?   ",
                    "    and b.aplnumdig = ?   ",
                    "    and b.itmnumdig = ?   ",
                    "    and c.lclnumseq = ?   ",
                    "    and c.rmerscseq = ?   ",
                    "    and a.atdsrvnum = b.atdsrvnum   ",
                    "    and a.atdsrvano = b.atdsrvano   ",
                    "    and a.atdsrvnum = c.atdsrvnum   ",
                    "    and a.atdsrvano = c.atdsrvano   ",
                    "    and a.atdsrvnum = d.atdsrvnum   ",
                    "    and a.atdsrvano = d.atdsrvano   ",
                    "    and d.c24astcod not in ('PE1','PE2') ",
                    "    and a.atdsrvorg = 9        ",
                    "  group by a.atdsrvano         ",
                    "  order by a.atdsrvano desc    "
prepare p_cts65m00_030 from l_sql_stmt
declare c_cts65m00_030 cursor for p_cts65m00_030

let l_sql_stmt = " select natagdflg ",
              " from datksocntz ",
              " where socntzcod = ? "
prepare p_cts65m00_031 from l_sql_stmt
declare c_cts65m00_031 cursor for p_cts65m00_031

let l_sql_stmt = " select c24astcod  "
                ,"  from datmligacao "
                ,"  where lignum = ? "
prepare p_cts65m00_032 from l_sql_stmt
declare c_cts65m00_032 cursor for p_cts65m00_032


let l_sql_stmt = " select atdorgsrvnum   , atdorgsrvano ",
                 " from datmsrvre ",
                 " where datmsrvre.atdsrvnum = ? ",
                 "  and datmsrvre.atdsrvano  = ? "
prepare p_cts65m00_033 from l_sql_stmt
declare c_cts65m00_033 cursor for p_cts65m00_033

let l_sql_stmt = "select atdlibflg ",
                 " from datmservico ",
                 " where atdsrvnum = ? ",
                 " and   atdsrvano = ? "
prepare p_cts65m00_034 from l_sql_stmt
declare c_cts65m00_034 cursor for p_cts65m00_034

let l_sql_stmt = "select atddfttxt, asitipcod, nom, corsus, cornom ",
                 " from datmservico ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts65m00_035 from l_sql_stmt
declare c_cts65m00_035 cursor for p_cts65m00_035


let l_sql_stmt = "select c24solnom, ligcvntip  ",
                  " from datmligacao ",
                  " where atdsrvnum = ? ",
                  " and atdsrvano   = ? "
prepare p_cts65m00_036 from l_sql_stmt
declare c_cts65m00_036 cursor for p_cts65m00_036

let l_sql_stmt = " select lclrsccod   , atdorgsrvnum,atdorgsrvano, ",
                 " socntzcod   ,orrdat, espcod ",
                 " from datmsrvre ",
                 " where datmsrvre.atdsrvnum = ? ",
                 "  and datmsrvre.atdsrvano = ? "
prepare p_cts65m00_037 from l_sql_stmt
declare c_cts65m00_037 cursor for p_cts65m00_037

let l_sql_stmt = " select max(atdsrvseq) from datmsrvacp ",
                 " where atdsrvnum = ? and ",
                 " atdsrvano = ? and ",
                 " atdetpcod = 3               and ",
                 " pstcoddig is not null "
prepare p_cts65m00_038 from l_sql_stmt
declare c_cts65m00_038 cursor for p_cts65m00_038

let l_sql_stmt = " select pstcoddig,srrcoddig,socvclcod ",
                 " from datmsrvacp ",
                 " where atdsrvnum = ? and ",
                 "     atdsrvano =   ? and ",
                 "     atdsrvseq =   ? "
prepare p_cts65m00_039 from l_sql_stmt
declare c_cts65m00_039 cursor for p_cts65m00_039

let l_sql_stmt = " select ofnnumdig  ",
                 " from datmlcl ",
                 " where atdsrvano = ? ",
                 "  and atdsrvnum = ? ",
                 "  and c24endtip = 1 "
prepare p_cts65m00_041 from l_sql_stmt
declare c_cts65m00_041 cursor for p_cts65m00_041


let l_sql_stmt = " select c24pbmcod     ",
                 " from datrsrvpbm      ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano    = ? ",
                 " and c24pbminforg = 1 ",
                 " and c24pbmseq    = 1 "
prepare p_cts65m00_042 from l_sql_stmt
declare c_cts65m00_042 cursor for p_cts65m00_042

let l_sql_stmt = " select socntzdes     ",
                 " from datksocntz     ",
                 " where socntzcod = ? "
prepare p_cts65m00_043 from l_sql_stmt
declare c_cts65m00_043 cursor for p_cts65m00_043


let l_sql_stmt = " select asitipabvdes  ",
                 " from datkasitip      ",
                 " where asitipcod = ?  "
prepare p_cts65m00_044 from l_sql_stmt
declare c_cts65m00_044 cursor for p_cts65m00_044

 let l_sql_stmt = ' update datmservico set '
                   ,'        prslocflg = ? '
                   ,'      , socvclcod = ? '
                   ,'      , srrcoddig = ? '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts65m00_045 from l_sql_stmt


let l_sql_stmt = ' select max(atdsrvseq) '
                   ,'   from datmsrvacp '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts65m00_046 from l_sql_stmt
declare c_cts65m00_046 cursor for p_cts65m00_046


let l_sql_stmt = ' insert into datmsrvre '
                   ,'      ( atdsrvnum   , atdsrvano, '
                   ,'        lclrsccod   , orrdat, '
                   ,'        orrhor      , socntzcod, '
                   ,'        atdsrvretflg, atdorgsrvnum, '
                   ,'        atdorgsrvano, srvretmtvcod, '
                   ,'        retprsmsmflg, espcod,  '
                   ,'        lclnumseq   , rmerscseq) '
                  , ' values (?,?,?,?,"00:00",?,"N",?,?,?,?,?,?,?) '
prepare p_cts65m00_047 from l_sql_stmt

let l_sql_stmt = ' insert into datmsrvretexc '
                   ,'      ( atdsrvnum, atdsrvano, '
                   ,'        srvretexcdes, caddat, '
                   ,'        cademp, cadmat, cadusrtip) '
                   ,' values (?,?,?,?,?,?,?) '
prepare p_cts65m00_048 from l_sql_stmt

let l_sql_stmt = ' insert into datrservapol '
                   ,'      ( atdsrvnum, atdsrvano, '
                   ,'        succod, ramcod, aplnumdig, '
                   ,'        itmnumdig, edsnumref ) '
                   ,' values (?,?,?,?,?,?,?) '
prepare p_cts65m00_049 from l_sql_stmt

let l_sql_stmt =  "Insert into dbscadtippgt (anosrv,",
                     "nrosrv,pgttipcodps,pgtmat,corsus,cadmat,cademp,",
                     "caddat,atlmat,atlemp,atldat,cctcod,succod,empcod,",
                     "pgtempcod) values  ",
                     "(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
prepare p_cts65m00_050 from l_sql_stmt



let l_sql_stmt = ' insert into datratdmltsrv '
                   ,'      ( atdsrvnum, atdsrvano, '
                   ,'        atdmltsrvnum, atdmltsrvano ) '
                   ,' values (?,?,?,?) '
prepare p_cts65m00_051 from l_sql_stmt

let l_sql_stmt = ' update datmservico '
                      ,' set atddatprg = ? '
                         ,' ,atdhorprg = ? '
                         ,' ,atdhorpvt = ? '
                    ,' where atdsrvnum = ? '
                      ,' and atdsrvano = ? '
prepare p_cts65m00_052 from l_sql_stmt

let l_sql_stmt = ' select lclltt,lcllgt, c24lclpdrcod ',
               ' from datmlcl ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and c24endtip = 1 '

prepare p_cts65m00_053 from l_sql_stmt
declare c_cts65m00_053 cursor for p_cts65m00_053

 ##obter viatura acionado
let l_sql_stmt = ' select pstcoddig, socvclcod, srrcoddig ',
               ' from datmsrvacp ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and atdetpcod = 3 '

prepare p_cts65m00_054 from l_sql_stmt
declare c_cts65m00_054 cursor for p_cts65m00_054

   ##obter coordenada da viatura no servico
let l_sql_stmt = ' select srrltt, srrlgt ',
                ' from datmservico ',
                ' where atdsrvnum = ? ',
                  ' and atdsrvano = ? '
prepare p_cts65m00_055 from l_sql_stmt
declare c_cts65m00_055 cursor for p_cts65m00_055

let l_sql_stmt = " select atdprscod, socvclcod, srrcoddig ",
                 " from datmservico ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts65m00_056 from l_sql_stmt
declare c_cts65m00_056 cursor for p_cts65m00_056

let l_sql_stmt = " select atdsrvnum, atdsrvano, ",
                 "  socvclcod, srrcoddig, ",
                 "  atddatprg, atdhorprg ",
                 "  from datmservico ",
                 "  where atdetpcod not in (5,6) ",
                 "  and (atddatprg >= ? ",
                 "  and  atdhorprg >  ?)",
                 "  and (atddatprg <= ? " ,
                 "  and  atdhorprg <  ? )",
                 "  and atdprscod = ? "
prepare p_cts65m00_057 from l_sql_stmt
declare c_cts65m00_057 cursor for p_cts65m00_057

let l_sql_stmt = " select 1 ",
                 " from datmservico ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano    = ? ",
                 " and socvclcod    = ? "
prepare p_cts65m00_058 from l_sql_stmt
declare c_cts65m00_058 cursor for p_cts65m00_058

let l_sql_stmt = " select atdorgsrvnum, atdorgsrvano ",
                 " from datmsrvre ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano  = ? ",
                 " and retprsmsmflg = 'S' ",
                 " and atdorgsrvnum is not null ",
                 " and atdorgsrvano is not null "
prepare p_cts65m00_059 from l_sql_stmt
declare c_cts65m00_059 cursor for p_cts65m00_059

let l_sql_stmt = "select 1 ",
                 " from datmservico ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano  = ? ",
                 " and socvclcod = ? "
prepare p_cts65m00_060 from l_sql_stmt
declare c_cts65m00_060 cursor for p_cts65m00_060

let l_sql_stmt = ' select atdmltsrvnum, atdmltsrvano '
                   ,'   from datratdmltsrv '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts65m00_061 from l_sql_stmt
declare c_cts65m00_061 cursor for p_cts65m00_061


let l_sql_stmt = ' update datmservico '
                   ,'    set c24opemat = ? '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts65m00_062 from l_sql_stmt

let l_sql_stmt = " select c24atvcod ",
                 " from dattfrotalocal ",
                 " where socvclcod = ? "

prepare p_cts65m00_064 from l_sql_stmt
declare c_cts65m00_064 cursor for p_cts65m00_064

let l_sql_stmt = " select count(*) ",
                 " from datkassunto ",
                 " where c24astcod = ? ",
                 " and itaasstipcod = 3 "

prepare p_cts65m00_065 from l_sql_stmt
declare c_cts65m00_065 cursor for p_cts65m00_065


let l_sql_stmt = " select count(*) "
                ," from DATMSERVICOCMP "
                ," where atdsrvnum = ? "
                ," and atdsrvano = ? "
prepare p_cts65m00_066 from l_sql_stmt
declare c_cts65m00_066 cursor for p_cts65m00_066

let l_sql_stmt = " insert into DATMSERVICOCMP "
                ," (atdsrvnum,atdsrvano,smsenvflg) "
                ," values (?,?,?)"
prepare p_cts65m00_067 from l_sql_stmt

 let l_sql_stmt = ' select grpcod '
            ,' from datrntzasipln '
            ,' where socntzcod = ? '
            ,' and asiplncod = ? '
 prepare p_cts65m00_068 from l_sql_stmt
 declare c_cts65m00_068 cursor for p_cts65m00_068

 let l_sql_stmt = ' select launumflg  ',
                  '  from datkresitagrp ',
                  '  where  ',
                  '  grpcod = ? '
 prepare p_cts65m00_069 from l_sql_stmt
 declare c_cts65m00_069 cursor for p_cts65m00_069


 let l_sql_stmt = ' select asiplncod  ',
             '  from datkresitaasipln ',
             '  where  ',
             '  srvcod = ? '
 prepare p_cts65m00_070 from l_sql_stmt
 declare c_cts65m00_070 cursor for p_cts65m00_070

 let l_sql_stmt = " select grlinf ",
                  " from datkgeral ",
                  " where grlchv = 'PSOAGENDAWATIVA' "
 prepare p_cts65m00_071 from l_sql_stmt
 declare c_cts65m00_071 cursor for p_cts65m00_071

 let m_prepara_sql = true

end function

#--------------------------------------------------------------------
 function cts65m00()
#--------------------------------------------------------------------

 define l_atdmltsrvnum    like datratdmltsrv.atdmltsrvnum
      , l_atdmltsrvano    like datratdmltsrv.atdmltsrvano
      , l_nulo            char(01)
      , l_aux             char(50)
      , l_servico         like datmservico.atdsrvnum
      , l_ano             like datmservico.atdsrvano

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod ,
    grvflg            smallint,
    vclcoddig         like datmservico.vclcoddig,
    vcldes            like datmservico.vcldes,
    vclanomdl         like datmservico.vclanomdl,
    vcllicnum         like datmservico.vcllicnum,
    vclcordes         char (11),
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    c24astcod_ret     like datmligacao.c24astcod,
    confirma          char (01),
    atdflg            char (01),
    mesanvctr         char(10),
    flag_acesso       smallint
 end record


 define l_grlinf      like igbkgeral.grlinf
 define l_cgccpf      char(12)
 define l_chassi      char(15)

 define lr_retorno record
        erro     integer ,
        msgerro  char(300)
 end record

 define l_socacsflg     like datkveiculo.socacsflg,
        l_c24opemat     like datkveiculo.c24opemat,
        l_c24atvcod     like dattfrotalocal.c24atvcod

 initialize m_rsrchv     
          , m_altcidufd  
          , m_altdathor
          , m_operacao
          , m_agncotdat 
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant to null
          
 initialize ws.*          to null
 initialize m_socntzcod   to null
 initialize l_grlinf      to null
 initialize lr_dados.*    to null
 initialize mr_salva.*    to null
 initialize m_subbairro   to null
 initialize mr_rsc_re.*   to null
 initialize am_cts29g00   to null
 initialize a_cts65m00    to null
 initialize d_cts65m00.*  to null
 initialize w_cts65m00.*  to null
 initialize cpl_atdsrvnum to null
 initialize cpl_atdsrvano to null
 initialize cpl_atdsrvorg to null
 initialize lr_retorno.*  to null

 let g_documento.atdsrvorg = 9
 let m_c24lclpdrcod        = null
 let l_cgccpf              = null
 let m_alt_end             = "N"
 let m_obter_mult          = 0
 let m_confirma_alt_prog   = "X"
 let m_tem_outros_srv      = "N"
 let m_veiculo_aciona      = null
 let m_resultado           = null
 let m_mensagem            = null
 let m_acntntqtd           = null
 let l_atdmltsrvnum        = null
 let l_atdmltsrvano        = null
 let l_servico             = null
 let l_ano                 = null
 let m_srv_acionado        = false
 let m_servico_original    = null
 let m_ano_original        = null
 let m_imdsrvflg_ant       = null
 let m_atdfnlflg           = null
 let int_flag              = false
 let m_rmemdlcod           = 0

 if g_documento.c24astcod = "RDK" or       
    g_documento.c24astcod = "RDT" or      
    g_documento.c24astcod = "R67" or      
    g_documento.c24astcod = "R68" or
    g_documento.c24astcod = "RAR" then    
                                          
    if g_documento.crtsaunum = 0 then     
       let g_documento.crtsaunum = null   
    end if                                
 end if                                   
 
 let ws.flag_acesso = cta00m06(g_issk.dptsgl)

 if g_documento.acao is null then
    if g_documento.atdsrvnum is not null then
       let g_documento.acao = "RAD" ## indica que veio pelo Radio
    end if
 end if

 let m_criou_tabela = false

 if g_documento.acao = "INC" or
    g_documento.acao = "ALT" or
    g_documento.acao = "RAD" or
    g_documento.acao is null  then
    call cts51g00_cria_temp()
         returning m_criou_tabela
 end if

 let m_data = null
 let m_hora = null

 call cts40g03_data_hora_banco(2) returning m_data, m_hora

 let aux_hora          = m_hora
 let aux_today         = m_data
 let w_cts65m00.atddat = m_data
 let w_cts65m00.atdhor = m_hora
 let flgcpl            = 0
 let ws_acao           = g_documento.acao
 let ws_acaorigem      = g_documento.acao

 if m_prepara_sql is null or
    m_prepara_sql <> true then
    call cts65m00_prepara()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false
 
 whenever error continue
 open c_cts65m00_071
 fetch c_cts65m00_071 into m_agendaw
 
 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 
 if ws_acao is  null  or
    ws_acao <> "RET"  then
    #--------------------------------
    # Verifica se servico e'  RET
    #--------------------------------

    whenever error continue
    open c_cts65m00_001 using g_documento.atdsrvnum,
                              g_documento.atdsrvano

    whenever error stop

    foreach c_cts65m00_001 into ws.c24astcod_ret
       if ws.c24astcod_ret = "RET"  then
          let ws_acao = "RET"
       end if
       exit foreach
    end foreach
    close c_cts65m00_001

 end if

  if g_documento.atdsrvnum is not null then
     whenever error continue
      open c_cts65m00_002  using g_documento.atdsrvnum,g_documento.atdsrvano
      fetch c_cts65m00_002 into m_c24astcodflag
     whenever error stop

     close c_cts65m00_002
  else
     let m_c24astcodflag = g_documento.c24astcod
  end if


 if g_documento.acao = 'CON' and ws_acao <> "RET" then
    let ws_acao = 'CON'
 end if

 if ws_acao is not null    and ws_acao      = "RET"   then

    let ws_tela = "RET"

    message 'Aguarde, verificando procedimentos... ' attribute (reverse)

    call cts14g00(ws_acao,
                  g_documento.ramcod,
                  g_documento.succod,
                  g_documento.aplnumdig,
                  G_documento.itmnumdig,
                  '',
                  '',
                  'N',
                  '2099-12-31 23:00')
    message ''

    open window cts65m00r at 04,02 with form "cts65m00"
                         attribute(form line 1)

    display "Mtv.Ret. :" to cpltela
    display "Acionar mesmo Prestador? " to cplPrest

    if m_c24astcodflag = "R13"  then
       display "(F1)Help(F2)Serv_Or(F3)Ref(F5)Esp(F6)Hist.(F7)Impr(F9)Conclui(F10)Tip.Pgt" to msgfun
    else
       if ws.flag_acesso = 0 then
          display "(F3)Ref.  (F6)Hist." to msgfun
       else
          display "(F1)Help (F2)Serv_Or (F3)Ref (F5)Esp (F6)Hist. (F7)Impr (F9)Conclui" to msgfun
       end if
    end if

 else
    call cts29g00_obter_multiplo
         (1, g_documento.atdsrvnum, g_documento.atdsrvano)
         returning m_obter_mult, m_mensagem,
                   am_cts29g00[1].*,
                   am_cts29g00[2].*,
                   am_cts29g00[3].*,
                   am_cts29g00[4].*,
                   am_cts29g00[5].*,
                   am_cts29g00[6].*,
                   am_cts29g00[7].*,
                   am_cts29g00[8].*,
                   am_cts29g00[9].*,
                   am_cts29g00[10].*

       if m_obter_mult = 1 then
          let ws_tela = "SRV"
          open window cts65m00s at 04,02 with form "cts65m00"
                                attribute(form line 1)

          if m_c24astcodflag = "R13"  then
             display '(F1)Help(F2)RET(F3)Ref(F4)Mult(F5)Esp(F6)Hist(F7)Imp(F9)Conclui(F10)Tip.Pgt' to msgfun
          else
             if ws.flag_acesso = 0 then # acesso teleperformance
                display "(F3)Ref. (F6)Hist." to msgfun
             else
                display '(F1)Help (F2)RET (F3)Ref (F4)Mult (F5)Esp (F6)Hist (F7)Imp (F9)Conclui' to msgfun
             end if
          end if
       else
          let ws_tela = "MLT" ##abrindo tela exibindo multiplo
          open window cts65m00m at 04,02 with form "cts65m00"
                                attribute(form line 1)

        if m_c24astcodflag = "R13"  then
           display "(F1)Help(F2)RET(F3)Refer(F5)Esp(F6)Hist.(F7)Imprime(F9)Conclui(F10)Tip.Pgt" to msgfun
        else
          if ws.flag_acesso = 0 then # acesso teleperformance
             display "(F3)Ref.  (F6)Hist." to msgfun
          else
             display "(F1)Help (F2)RET (F3)Refer (F5)Esp (F6)Hist. (F7)Imprime (F9)Conclui" to msgfun
          end if
        end if
       end if
 end if

let w_cts65m00.ligcvntip  =  g_documento.ligcvntip


 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  and
    ws_acaorigem  is not null          and
    ws_acaorigem  = "RET"              then
    let cpl_atdsrvorg         = 09
    let cpl_atdsrvnum         = g_documento.atdsrvnum
    let cpl_atdsrvano         = g_documento.atdsrvano
    let ws_refatdsrvnum_ini   = g_documento.atdsrvnum
    let ws_refatdsrvano_ini   = g_documento.atdsrvano
    let g_documento.c24astcod = "RET"
    call cts65m00_copia()
    initialize g_documento.atdsrvnum,
               g_documento.atdsrvano to null
 end if

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts65m00()

    display by name d_cts65m00.srvnum thru d_cts65m00.atdtxt
    display by name d_cts65m00.c24solnom attribute (reverse)

    display by name d_cts65m00.espdes
    display by name a_cts65m00[1].lgdtxt,
                    a_cts65m00[1].lclbrrnom,
                    a_cts65m00[1].cidnom,
                    a_cts65m00[1].ufdcod,
                    a_cts65m00[1].lclrefptotxt,
                    a_cts65m00[1].endzon,
                    a_cts65m00[1].dddcod,
                    a_cts65m00[1].lcltelnum,
                    a_cts65m00[1].lclcttnom,
                    a_cts65m00[1].celteldddcod,
                    a_cts65m00[1].celtelnum,
                    a_cts65m00[1].endcmp


    if w_cts65m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"
       let m_srv_acionado = true
    else
       if g_documento.succod    is not null  and
          g_documento.ramcod    is not null  and
          g_documento.aplnumdig is not null then
          call cts03g00 (3, g_documento.ramcod    ,
                            g_documento.succod    ,
                            g_documento.aplnumdig ,
                            g_documento.itmnumdig ,
                            "",
                            g_documento.atdsrvnum ,
                            g_documento.atdsrvano )
       end if
    end if

    if d_cts65m00.srvretmtvcod is not null then
       display d_cts65m00.srvretmtvcod to srvretmtvcod
       display d_cts65m00.srvretmtvdes to srvretmtvdes
    end if

    call modifica_cts65m00() returning ws.grvflg

    ## para o porto socorro sair do laudo sem abrir o historico
    # Não abrir o historico de servico para a consulta laudo PET
    if ws_acaorigem <> "RAD" and
       g_issk.dptsgl <> 'psocor' then
       call cts40g03_data_hora_banco(2) returning m_data, m_hora
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat, m_data, m_hora)

       let g_rec_his = true
       let g_documento.acao = "ALT"

    end if
 else
    if   g_documento.succod    is not null and
         g_documento.ramcod    is not null and
         g_documento.aplnumdig is not null and
         g_documento.itmnumdig is not null then

           let d_cts65m00.doctxt = "Apolice.: ",
                                   g_documento.succod using "<<<&&",
                                   " ",g_documento.ramcod using "##&&",
                                   " ",g_documento.aplnumdig using "<<<<<<<& &"
 end if

#--------------------------------------------------------------------
# Monta CABECALHO do laudo
#--------------------------------------------------------------------

       if g_documento.ramcod = 14   then

       call cty25g01_rec_dados_itau(g_documento.itaciacod,
                         g_documento.ramcod,
                         g_documento.aplnumdig,
                         g_documento.edsnumref,
                         g_documento.itmnumdig)
            returning lr_retorno.*

          # Busca do nome do corretor
          call cty22g00_busca_nome_corretor()
               returning d_cts65m00.cornom

          let d_cts65m00.nom    = g_doc_itau[1].segnom  clipped
          let d_cts65m00.corsus = g_doc_itau[1].corsus clipped

    end if

    let d_cts65m00.c24solnom = g_documento.solnom
    let d_cts65m00.prslocflg = "N"

    display by name d_cts65m00.srvnum thru d_cts65m00.atdtxt
    display by name d_cts65m00.c24solnom attribute (reverse)


    #--------------------------------------------------------------------
    # Verifica impossibilidade de atendimento
    #--------------------------------------------------------------------
    if (g_documento.succod     is not null  and
        g_documento.ramcod     is not null  and
        g_documento.aplnumdig  is not null) then


    end if

    open c_cts65m00_003
    whenever error continue
    fetch c_cts65m00_003 into l_grlinf
    whenever error stop

    if sqlca.sqlcode <> 0 then

       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT igbkgeral :',sqlca.sqlcode,'|',sqlca.sqlerrd[2]
          clear form
          if ws_tela = "RET" then
             close window cts65m00r
          else
             if ws_tela = "SRV" then
                close window cts65m00s
             else
                close window cts65m00m
             end if
          end if

          let int_flag = false

          return
       end if
    end if

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------
    if ws_acao is not null and
       ws_acao =  "RET"    then
       # Solicitacao do (RET)orno
    else
       if  g_documento.succod    is not null  and
           g_documento.ramcod    is not null  and
           g_documento.aplnumdig is not null  then

           call cts03g00 (3, g_documento.ramcod    ,
                             g_documento.succod    ,
                             g_documento.aplnumdig ,
                             g_documento.itmnumdig ,
                              "",
                             g_documento.atdsrvnum ,
                             g_documento.atdsrvano )
       end if
    end if

    call inclui_cts65m00() returning ws.grvflg

    if ws.grvflg = true  then

       call cts40g03_data_hora_banco(2) returning m_data, m_hora
       let w_cts65m00.atddat  = m_data
       let w_cts65m00.atdhor = m_hora

       call cts10n00(w_cts65m00.atdsrvnum, w_cts65m00.atdsrvano,
                     w_cts65m00.funmat   , w_cts65m00.atddat   ,
                     w_cts65m00.atdhor)

       call cts17m03_incluir_hist(w_cts65m00.atdsrvnum, w_cts65m00.atdsrvano )
            returning m_resultado, m_mensagem

       if m_resultado <> 1 then
          error m_mensagem
       end if

       call cts17m03_envio_email(g_documento.ramcod, g_documento.c24astcod,
                                g_documento.ligcvntip, g_documento.succod,
                                g_documento.aplnumdig, g_documento.itmnumdig,
                                w_cts65m00.lignum,  w_cts65m00.atdsrvnum,
                                w_cts65m00.atdsrvano, g_documento.prporg,
                                g_documento.prpnumdig, g_documento.solnom )

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------

       whenever error continue
       open c_cts65m00_004 using w_cts65m00.atdsrvnum,
                                 w_cts65m00.atdsrvano,
                                 w_cts65m00.atdsrvnum,
                                 w_cts65m00.atdsrvano
       fetch c_cts65m00_004  into ws.atdetpcod
       whenever error stop

       if ws.atdetpcod    <> 3   and    # servico etapa concluida RE
          ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado

          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          whenever error continue
          execute p_cts65m00_005 using w_cts65m00.atdsrvnum,
                                       w_cts65m00.atdsrvano
          whenever error stop

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
            call cts00g07_apos_servdesbloqueia(w_cts65m00.atdsrvnum,w_cts65m00.atdsrvano)
          end if

          #------------------------------------------------------
          #// Desbloqueio de servicos para os laudos multiplos
          #------------------------------------------------------
          let l_nulo = null
          whenever error continue
          open c_cts65m00_061 using w_cts65m00.atdsrvnum
                                , w_cts65m00.atdsrvano
          whenever error stop
          foreach c_cts65m00_061 into l_atdmltsrvnum, l_atdmltsrvano

               whenever error continue
               execute p_cts65m00_062 using l_nulo, l_atdmltsrvnum, l_atdmltsrvano
               whenever error stop

               if sqlca.sqlcode <> 0 then
                  error "Erro (", sqlca.sqlcode, ") no desbloqueio do servico ",
                        "para laudos multiplos. AVISE A INFORMATICA!"
                  prompt "" for char ws.confirma
                  exit foreach
               else
                  call cts00g07_apos_servdesbloqueia(l_atdmltsrvnum, l_atdmltsrvano)
               end if

          end foreach
       end if
    end if
 end if

 #se prestador bloqueado
 #acionar serviço para o prestador -- independente se é INC ou ALT

 #cancelamento de um servico para um servico ainda nao acionado
  if ws_acao = 'CAN' then
     # Funcao que substituiu a "cts65m00_cancela"
     # Sera utilizada tambem para o Servico do Portal
     call ctf00m03(g_documento.atdsrvnum
                  ,g_documento.atdsrvano
                  ,m_atdfnlflg)
 end if

 if ws_tela = "RET" then
    close window cts65m00r
 else
    if ws_tela = "SRV" then
       close window cts65m00s
    else
       close window cts65m00m
    end if

 end if

end function  ###  cts65m00

#--------------------------------------------------------------------
 function consulta_cts65m00()
#--------------------------------------------------------------------

 define ws            record
    funmat            like isskfunc.funmat         ,
    funnom            char (15)                    ,
    dptsgl            like isskfunc.dptsgl         ,
    lignum            like datrligsrv.lignum       ,
    endlgdtip         like rlaklocal.endlgdtip     ,
    endlgdnom         like rlaklocal.endlgdnom     ,
    endnum            like rlaklocal.endnum        ,
    endcmp            like rlaklocal.endcmp        ,
    endbrr            like rlaklocal.endbrr        ,
    endcid            like rlaklocal.endcid        ,
    ufdcod            like rlaklocal.ufdcod        ,
    endcep            like rlaklocal.endcep        ,
    endcepcmp         like rlaklocal.endcepcmp     ,
    succod            like datrligapol.succod      ,
    ramcod            like datrligapol.ramcod      ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    edsnumref         like datrligapol.edsnumref   ,
    cogidosql         integer                      ,
    atdprscod         like datmservico.atdprscod   ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapcorg          like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    empcod            like datmservico.empcod
 end record

 define l_espsit      like dbskesp.espsit   #PSI195138
 define l_c24astcod   like datkassunto.c24astcod
 define l_cgccpf      char(12)
 define l_resultado   smallint
 define l_mensagem    char(60)
       ,l_errcod   smallint
       ,l_errmsg   char(80)

 initialize lr_aux.*      to null
 initialize mr_salva, ws  to null
 initialize l_errcod, l_errmsg to null
 
 let d_cts65m00.espcod = null
 let l_cgccpf          = null
 let l_resultado       = null
 let l_mensagem        = null

 whenever error continue
 open c_cts65m00_006 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts65m00_006 into d_cts65m00.nom      ,
                           d_cts65m00.cornom   ,
                           d_cts65m00.corsus   ,
                           d_cts65m00.atddfttxt,
                           ws.funmat           ,
                           d_cts65m00.asitipcod,
                           w_cts65m00.atddat   ,
                           w_cts65m00.atdhor   ,
                           d_cts65m00.atdlibflg,
                           w_cts65m00.atdlibhor,
                           w_cts65m00.atdlibdat,
                           w_cts65m00.atdhorpvt,
                           w_cts65m00.atdpvtretflg,
                           w_cts65m00.atddatprg,
                           w_cts65m00.atdhorprg,
                           w_cts65m00.atdfnlflg,
                           d_cts65m00.atdprinvlcod,
                           ws.atdprscod,
                           d_cts65m00.prslocflg,
                           m_acntntqtd,
                           g_documento.ciaempcod,
                           ws.empcod
whenever error stop

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if
 close c_cts65m00_006

 # PSI-2013-00440PR
 # identificar cota de agendamento ja realizado (ALT)
 call cts02m08_sel_cota(g_documento.atdsrvnum, g_documento.atdsrvano)
      returning l_errcod, l_errmsg, m_rsrchvant
 
 if l_errcod = 0
    then
    #display 'cts02m08_sel_cota ok'
 else
    #display 'cts02m08_sel_cota erro ', l_errcod
    display l_errmsg clipped
 end if

 call cts02m08_id_datahora_cota(m_rsrchvant)
      returning l_errcod, l_errmsg, m_agncotdatant, m_agncothorant
      
 if l_errcod != 0
    then
    #display 'cts02m08_id_datahora_cota(consulta) erro no ID da cota'
    display l_errmsg clipped
 end if
 # PSI-2013-00440PR
 
 let m_atdfnlflg = w_cts65m00.atdfnlflg

 whenever error continue
 open c_cts65m00_007 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts65m00_007 into d_cts65m00.lclrsccod,
                           d_cts65m00.orrdat   ,
                           d_cts65m00.socntzcod,
                           cpl_atdsrvnum,
                           cpl_atdsrvano,
                           d_cts65m00.srvretmtvcod,
                           d_cts65m00.espcod,
                           d_cts65m00.retprsmsmflg
 whenever error stop

 if sqlca.sqlcode = notfound  then
    error " Socorro Ramos Elementares nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 close c_cts65m00_007

 initialize d_cts65m00.servicorg  to null
 if cpl_atdsrvnum is not null then
    let cpl_atdsrvorg = 09
    let d_cts65m00.servicorg  = cpl_atdsrvorg using "&&",
                                "/", cpl_atdsrvnum using "&&&&&&&",
                                "-", cpl_atdsrvano using "&&"
 end if

#--------------------------------------------------------------------
# Informacoes do motivo retorno
#--------------------------------------------------------------------
 initialize d_cts65m00.srvretmtvdes to null
 if d_cts65m00.srvretmtvcod is not null then

    if d_cts65m00.srvretmtvcod = 999  then
       whenever error continue
       open c_cts65m00_008 using g_documento.atdsrvnum,
                                 g_documento.atdsrvano
       fetch c_cts65m00_008 into d_cts65m00.srvretmtvdes
       whenever error stop

    else
       whenever error continue
       open c_cts65m00_009 using d_cts65m00.srvretmtvcod
       fetch c_cts65m00_009 into d_cts65m00.srvretmtvdes
       whenever error stop
    end if

    close c_cts65m00_008
    close c_cts65m00_009


    display "Mtv.Ret. :" to cpltela
    display "Acionar mesmo Prestador? " to cplPrest
 end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            1)
                  returning a_cts65m00[1].lclidttxt   ,
                            a_cts65m00[1].lgdtip      ,
                            a_cts65m00[1].lgdnom      ,
                            a_cts65m00[1].lgdnum      ,
                            a_cts65m00[1].lclbrrnom   ,
                            a_cts65m00[1].brrnom      ,
                            a_cts65m00[1].cidnom      ,
                            a_cts65m00[1].ufdcod      ,
                            a_cts65m00[1].lclrefptotxt,
                            a_cts65m00[1].endzon      ,
                            a_cts65m00[1].lgdcep      ,
                            a_cts65m00[1].lgdcepcmp   ,
                            a_cts65m00[1].lclltt      ,
                            a_cts65m00[1].lcllgt      ,
                            a_cts65m00[1].dddcod      ,
                            a_cts65m00[1].lcltelnum   ,
                            a_cts65m00[1].lclcttnom   ,
                            a_cts65m00[1].c24lclpdrcod,
                            a_cts65m00[1].celteldddcod,
                            a_cts65m00[1].celtelnum,
                            a_cts65m00[1].endcmp   ,
                            ws.cogidosql, a_cts65m00[1].emeviacod

    whenever error continue
    open c_cts65m00_010 using g_documento.atdsrvano,
                              g_documento.atdsrvnum
    fetch c_cts65m00_010 into a_cts65m00[1].ofnnumdig
    whenever error stop

    if ws.cogidosql <> 0  then
       error " Erro (", ws.cogidosql using "<<<<<&", ") na leitura local de ocorrencia. AVISE A INFORMATICA!"
              return
    end if

    let a_cts65m00[1].lgdtxt = a_cts65m00[1].lgdtip clipped, " ",
                               a_cts65m00[1].lgdnom clipped, " ",
                               a_cts65m00[1].lgdnum using "<<<<#"


    let d_cts65m00.socntzdes = "*** NAO CADASTRADA ***"

 whenever error continue
 open c_cts65m00_011 using d_cts65m00.socntzcod
 fetch c_cts65m00_011 into d_cts65m00.socntzdes
 whenever error stop

 # busca descricao especialidade
 let d_cts65m00.espdes = null
 if d_cts65m00.espcod is not null then

    #como so quero buscar a descricao, nao importando a situacao da
    # especialidade (ativo ou nao), passo null para a funcao

    let l_espsit = null
    call cts31g00_descricao_esp(d_cts65m00.espcod, l_espsit)
         returning d_cts65m00.espdes

    if d_cts65m00.espdes is null then
       error "Descricao nao encontrada para especialidade."
    end if
 end if

 let d_cts65m00.asitipabvdes = "NAO PREV"

 whenever error continue

 open c_cts65m00_012 using d_cts65m00.asitipcod
 fetch c_cts65m00_012 into d_cts65m00.asitipabvdes

 whenever error stop

 close c_cts65m00_012

#--------------------------------------------------------------------
# Identificacao do SOLICITANTE/CONVENIO
#--------------------------------------------------------------------

 let w_cts65m00.lignum =
     cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts65m00.lignum)
      returning g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum ,
                g_documento.itaciacod

 call cts20g01_docto_tot(w_cts65m00.lignum)
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


 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts65m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&", #"&&", Projeto succod
                                     " ", g_documento.ramcod    using "##&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 #===========================================================================
 #Ler assunto, pois qdo entro pelo radio nao tenho nenhum assunto selecionado
 #===========================================================================
 whenever error continue

 open c_cts65m00_013 using w_cts65m00.lignum
 fetch c_cts65m00_013 into d_cts65m00.c24solnom,
                           w_cts65m00.ligcvntip,
                           l_c24astcod

 whenever error stop

 close c_cts65m00_013
 #===========================================================================
 #caso seja RET nao substituo o assunto, pois o cts40g12 tem tratamento
 #especifico para retorno e nao posso enviar o assunto original
 #===========================================================================

 if g_documento.acao <> "RET" then
    if  g_documento.c24astcod is null  then
        let g_documento.c24astcod = l_c24astcod
    end if
 end if


 let g_documento.solnom = d_cts65m00.c24solnom

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"


 whenever error continue

 open c_cts65m00_014 using ws.empcod,ws.funmat
 fetch c_cts65m00_014 into ws.funnom, ws.dptsgl

 whenever error stop

 close c_cts65m00_014



 let d_cts65m00.atdtxt = w_cts65m00.atddat           , " ",
                         w_cts65m00.atdhor           , " ",
                         upshift(ws.dptsgl)   clipped, " ",
                         ws.funmat  using "&&&&&&"   , " ",
                         upshift(ws.funnom)   clipped, " ",
                         w_cts65m00.atdlibdat        , " ",
                         w_cts65m00.atdlibhor

 if w_cts65m00.atdhorpvt is not null  or
    w_cts65m00.atdhorpvt  = "00:00"   then
    let d_cts65m00.imdsrvflg = "S"
 end if

 if w_cts65m00.atddatprg is not null  then
    let d_cts65m00.imdsrvflg = "N"
 end if

 let w_cts65m00.atdlibflg = d_cts65m00.atdlibflg

 if d_cts65m00.atdlibflg = "N"  then
    let w_cts65m00.atdlibdat = w_cts65m00.atddat
    let w_cts65m00.atdlibhor = w_cts65m00.atdhor
 end if

 let d_cts65m00.srvnum = g_documento.atdsrvorg using "&&",
                    "/", g_documento.atdsrvnum using "&&&&&&&",
                    "-", g_documento.atdsrvano using "&&"

 whenever error continue
 open c_cts65m00_015 using d_cts65m00.atdprinvlcod
 fetch c_cts65m00_015 into d_cts65m00.atdprinvldes
 whenever error stop
 close c_cts65m00_015

 whenever error continue
 open c_cts65m00_016 using g_documento.atdsrvnum,
                           g_documento.atdsrvano

 fetch c_cts65m00_016 into d_cts65m00.c24pbmcod

 whenever error stop

 close c_cts65m00_016


 let mr_salva.lgdnom    = a_cts65m00[1].lgdnom
 let mr_salva.lgdnum    = a_cts65m00[1].lgdnum
 let mr_salva.brrnom    = a_cts65m00[1].brrnom
 let mr_salva.lclbrrnom = a_cts65m00[1].lclbrrnom
 let mr_salva.cidnom    = a_cts65m00[1].cidnom
 let mr_salva.ufdcod    = a_cts65m00[1].ufdcod
 let mr_salva.lgdcep    = a_cts65m00[1].lgdcep
 let mr_salva.lclltt    = a_cts65m00[1].lclltt
 let mr_salva.imdsrvflg = d_cts65m00.imdsrvflg
 let mr_salva.atddatprg = w_cts65m00.atddatprg
 let mr_salva.atdhorprg = w_cts65m00.atdhorprg
 let mr_salva.atdlibdat = w_cts65m00.atdlibdat
 let mr_salva.atdlibhor = w_cts65m00.atdlibhor
 let mr_salva.c24lclpdrcod = a_cts65m00[1].c24lclpdrcod

whenever error continue
 open c_cts65m00_017 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts65m00_017 into ms.atdsrvseq
whenever error stop
close c_cts65m00_017


whenever error continue
 open c_cts65m00_018 using g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           ms.atdsrvseq
 fetch c_cts65m00_018 into ms.atdetpcod
whenever error stop
close c_cts65m00_018

 let m_c24lclpdrcod = a_cts65m00[1].c24lclpdrcod

 let m_subbairro[1].lclbrrnom = a_cts65m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts65m00[1].brrnom,
                                a_cts65m00[1].lclbrrnom)
      returning a_cts65m00[1].lclbrrnom

end function

#--------------------------------------------------------------------
 function modifica_cts65m00()
#--------------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    cogidosql        integer,
    tabname          like systables.tabname
 end record

 define hist_cts65m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define lr_retorno             record
         resultado              smallint,
         mensagem               char(100)
   end record

 define prompt_key    char (01)
 define l_contador    smallint,
        l_atdsrvseq like datmsrvacp.atdsrvseq
       ,l_errcod   smallint
       ,l_errmsg   char(80)
       
 initialize l_errcod, l_errmsg  to null
 
 let l_contador  = null
 let prompt_key  =  null
 let l_atdsrvseq =  null

 initialize  lr_retorno.*  to  null
 initialize  ws.*  to  null
 initialize  hist_cts65m00.*  to  null
 initialize ws.*  to null

 call input_cts65m00() returning hist_cts65m00.*

 if g_documento.acao = "CON" then
    let int_flag = false
    return false
 end if

 if m_srv_acionado = true then
    let int_flag = false
    return true
 end if

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts65m00      to null
    initialize d_cts65m00.*    to null
    initialize w_cts65m00.*    to null
    clear form
    return false
 end if

 if a_cts65m00[1].lclltt is null or
    a_cts65m00[1].lclltt = 0 or
    a_cts65m00[1].lcllgt is null or
    a_cts65m00[1].lcllgt = 0 then
    let m_atdfnlflg = "N"
 end if

 #display 'cts65m00 - Modificar atendimento'
 
 whenever error continue

 begin work

 if m_imdsrvflg_ant <> d_cts65m00.imdsrvflg and
    g_documento.acao = "ALT" then

    call cts40g03_data_hora_banco(2) returning m_data, m_hora

    let w_cts65m00.atdlibdat = m_data
    let w_cts65m00.atdlibhor = m_hora

    call cts10g04_max_seq(g_documento.atdsrvnum, g_documento.atdsrvano, 1)
         returning lr_retorno.*, l_atdsrvseq

    if lr_retorno.resultado <> 1 then
       error lr_retorno.mensagem
    else
       #==============================================================
       # atualiza a data de liberacao apos indexacao - datmsrvacp
       #==============================================================
       call cts10g04_atu_hor(g_documento.atdsrvnum, g_documento.atdsrvano,
                             l_atdsrvseq, m_hora)
            returning lr_retorno.*

       if lr_retorno.resultado <> 1 then
          error lr_retorno.mensagem
       end if

    end if
 end if

 whenever error continue
 execute p_cts65m00_019 using  d_cts65m00.nom,
                               d_cts65m00.cornom,
                               d_cts65m00.corsus,
                               d_cts65m00.atddfttxt,
                               d_cts65m00.atdlibflg,
                               w_cts65m00.atdlibhor,
                               w_cts65m00.atdlibdat,
                               w_cts65m00.atdhorpvt,
                               w_cts65m00.atdpvtretflg,
                               w_cts65m00.atddatprg,
                               w_cts65m00.atdhorprg,
                               d_cts65m00.asitipcod,
                               m_atdfnlflg,
                               g_documento.atdsrvnum,
                               g_documento.atdsrvano


 whenever error stop

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if


 #------------------------------------------------------------------------------
 # Modifica problemas do servico
 #------------------------------------------------------------------------------
   call ctx09g02_altera(g_documento.atdsrvnum ,
                        g_documento.atdsrvano ,
                        1                   , # sequencia
                        1                   , # Org. informacao 1-Segurado 2-Pst
                        d_cts65m00.c24pbmcod,
                        d_cts65m00.atddfttxt,
                        ""                  ) # Codigo prestador
        returning ws.cogidosql, ws.tabname

   if ws.cogidosql <> 0 then
      error "ctx09g02_altera", ws.cogidosql, ws.tabname
      rollback work
      prompt "" for char prompt_key
      return false
   end if

 whenever error continue
 execute p_cts65m00_020 using d_cts65m00.lclrsccod
                              ,d_cts65m00.orrdat
                              ,d_cts65m00.socntzcod
                              ,d_cts65m00.espcod
                              ,d_cts65m00.srvretmtvcod
                              ,d_cts65m00.retprsmsmflg
                              ,g_documento.atdsrvnum
                              ,g_documento.atdsrvano

 whenever error stop

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 #--------------------------
 # Trata arquivo msg retorno
 #--------------------------
 # prepare
 whenever error continue
 execute p_cts65m00_021 using g_documento.atdsrvnum,
                              g_documento.atdsrvano
 whenever error stop


 if d_cts65m00.srvretmtvcod is not null  and
    d_cts65m00.srvretmtvcod  =  999      then

     whenever error continue
     execute p_cts65m00_022 using g_documento.atdsrvnum
                                 ,g_documento.atdsrvano
                                 ,d_cts65m00.srvretmtvdes
                                 ,m_data
                                 ,g_issk.empcod
                                 ,g_issk.funmat
                                 ,g_issk.usrtip
    whenever error stop

    if sqlca.sqlcode <> 0 then
       error " Erro (", sqlca.sqlcode, "). AVISE A INFORMATICA (1)!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if

 if a_cts65m00[1].operacao is null  then
    let a_cts65m00[1].operacao = "M"
 end if

 let a_cts65m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

 call cts06g07_local(a_cts65m00[1].operacao,
                     g_documento.atdsrvnum,
                     g_documento.atdsrvano,
                     1,
                     a_cts65m00[1].lclidttxt,
                     a_cts65m00[1].lgdtip,
                     a_cts65m00[1].lgdnom,
                     a_cts65m00[1].lgdnum,
                     a_cts65m00[1].lclbrrnom,
                     a_cts65m00[1].brrnom,
                     a_cts65m00[1].cidnom,
                     a_cts65m00[1].ufdcod,
                     a_cts65m00[1].lclrefptotxt,
                     a_cts65m00[1].endzon,
                     a_cts65m00[1].lgdcep,
                     a_cts65m00[1].lgdcepcmp,
                     a_cts65m00[1].lclltt,
                     a_cts65m00[1].lcllgt,
                     a_cts65m00[1].dddcod,
                     a_cts65m00[1].lcltelnum,
                     a_cts65m00[1].lclcttnom,
                     a_cts65m00[1].c24lclpdrcod,
                     a_cts65m00[1].ofnnumdig,
                     a_cts65m00[1].emeviacod,
                     a_cts65m00[1].celteldddcod,
                     a_cts65m00[1].celtelnum,
                     a_cts65m00[1].endcmp)
           returning ws.cogidosql

 if ws.cogidosql is null   or
    ws.cogidosql <> 0      then
    error " Erro (", ws.cogidosql, ") no local. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 if w_cts65m00.atdlibflg <> d_cts65m00.atdlibflg  then
    if d_cts65m00.atdlibflg = "S"  then
       let w_cts65m00.atdetpcod = 1
    else
       let w_cts65m00.atdetpcod = 2
    end if

    call cts10g04_insere_etapa (g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                w_cts65m00.atdetpcod ,
                                ""                   ,
                                ""                   ,
                                ""                   ,
                                ""                   )
         returning ws.cogidosql

    if ws.cogidosql <> 0  then
       error " Erro (", ws.cogidosql, ") na etapa. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if

 whenever error stop

    #valida novamente se servico vai para acionamento automático
    #-----------------------------------------------
    # Aciona Servico automaticamente
    #-----------------------------------------------


    if (g_documento.acao = "RET" and d_cts65m00.retprsmsmflg = 'N') or
       m_veiculo_aciona is not null then
       #e retorno  and deseja outro prestador? OU nao tem veiculo pronto para atender?
       #servico nao sera acionado automaticamente
    else
       ## Se alterou o endereco, altear nos multiplos tambem
       call cts65m00_alt_end(m_obter_mult
                            ,m_servico_original
                            ,m_ano_original)
             returning m_resultado
                      ,m_mensagem

       #chamar funcao que verifica se acionamento pode ser feito
       # verifica se servico para cidade e internet ou GPS e se esta ativo
       #retorna true para acionamento e false para nao acionamento

       if cts34g00_acion_auto (g_documento.atdsrvorg,
                               a_cts65m00[1].cidnom,
                               a_cts65m00[1].ufdcod) then

          #funcao cts34g00_acion_auto verificou que parametrizacao para origem
          # do servico esta OK
          #chamar funcao para validar regras gerais se um servico sera acionado
          # automaticamente ou nao e atualizar datmservico

          if not cts40g12_regras_aciona_auto (
                               g_documento.atdsrvorg,
                               g_documento.c24astcod,
                               "",
                               a_cts65m00[1].lclltt,
                               a_cts65m00[1].lcllgt,
                               d_cts65m00.prslocflg,
                               "N",#d_cts65m00.frmflg,
                               g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               g_documento.acao,
                               "",
                               "") then
             #servico nao pode ser acionado automaticamente
          end if
       end if
    end if

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(w_cts65m00.atdsrvnum,
                             w_cts65m00.atdsrvano)

 # PSI-2013-00440PR
 if m_agendaw = true 
    then
    if m_operacao = 1  # ALT, gerou nova cota, baixa
       then
       display 'Baixar cota atual na alteracao: ', m_rsrchv clipped
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
 
 return true

end function  ###  modifica_cts65m00


#-------------------------------------------------------------------------------
 function inclui_cts65m00()
#-------------------------------------------------------------------------------

 define ws          record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        cogidosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                   ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        servico         char (08)                  ,
        grlchv          like igbkgeral.grlchv      ,
        grlinf          like igbkgeral.grlinf      ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        atdetpcod      like datmsrvacp.atdetpcod  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint                   ,
        socvclcod         like datmsrvacp.socvclcod
 end record

 define hist_cts65m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define l_resultado      smallint
      , l_mensagem       char(100)
      , l_lignum         like datmligacao.lignum
      , l_atdsrvnum_mul  like datmservico.atdsrvnum
      , l_atdsrvano_mul  like datmservico.atdsrvano
      , l_lignum_mul     like datmligacao.lignum
      , l_for            smallint
      , l_confirma       char(1)
      , l_count          integer
      , l_txtsrv         char (15)
      , l_reserva_ativa  smallint # Flag para idenitficar se reserva esta ativa
      , l_errcod         smallint
      , l_errmsg         char(80)
       
 initialize l_errcod, l_errmsg to null
 initialize l_txtsrv, l_reserva_ativa to null
 initialize  ws.*  to  null
 initialize  hist_cts65m00.*  to  null
 
 let l_confirma = "N"
 let l_count = 0

 #display 'cts65m00 - Incluir atendimento'

 while true
   initialize ws.*  to null
   initialize am_param to null

   let g_documento.acao = "INC"

   if ws_acao = "RET" then
      let d_cts65m00.retprsmsmflg = "S"
   end if

   call input_cts65m00() returning hist_cts65m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize d_cts65m00.*    to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts65m00.atddat is null  then

       call cts40g03_data_hora_banco(2) returning m_data, m_hora
       let w_cts65m00.atddat    = m_data
       let w_cts65m00.atdhor    = m_hora
   end if

   if  w_cts65m00.funmat is null  then
       let w_cts65m00.funmat    = g_issk.funmat
   end if

   initialize ws.caddat to null
   initialize ws.cadhor to null
   initialize ws.cademp to null
   initialize ws.cadmat to null

   let ms.* = ws.*
   let mr_hist.* = hist_cts65m00.*

   if  w_cts65m00.atdfnlflg is null  then
       let w_cts65m00.atdfnlflg = "N"
       let w_cts65m00.c24opemat = g_issk.funmat
   end if

   call cts65m00_grava_dados(d_cts65m00.socntzcod,
                             d_cts65m00.espcod,
                             d_cts65m00.c24pbmcod,
                             d_cts65m00.atddfttxt, '', '')
        returning l_resultado, l_mensagem, ws.atdsrvnum,
                  ws.atdsrvano, l_lignum

  if l_resultado <> 1 then
     error l_mensagem
  else
     for l_for = 1 to 10
         if am_param[l_for].socntzcod is null then
            exit for
         end if
         call cts65m00_grava_dados(am_param[l_for].socntzcod,
                                   am_param[l_for].espcod,
                                   am_param[l_for].c24pbmcod,
                                   am_param[l_for].atddfttxt,
                                   ws.atdsrvnum,
                                   ws.atdsrvano)
              returning l_resultado, l_mensagem, l_atdsrvnum_mul,
                        l_atdsrvano_mul, l_lignum_mul

         if l_resultado <> 1 then
            error l_mensagem
            exit for
         end if
     end for

     # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao 
     #                    ainda ativa e fazer a baixa da chave no AW
     let l_txtsrv = "SRV ", ws.atdsrvnum, "-", ws.atdsrvano
      
     if m_agendaw = true 
        then
        if m_operacao = 1  # obteve chave de regulacao 
           then
           if l_resultado = 1  # sucesso na gravacao do servico
              then
              call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa
           
              if l_reserva_ativa = true 
                 then
                 #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW'
                 call ctd41g00_baixar_agenda(m_rsrchv, ws.atdsrvano, ws.atdsrvnum)
                      returning l_errcod, l_errmsg
              else
                 #display "Chave de regulacao inativa, selecione agenda novamente"
                 error "Chave de regulacao inativa, selecione agenda novamente"
                 
                 let m_operacao = 0 
                 
                 # obter a chave de regulacao no AW
                 call cts02m08(w_cts65m00.atdfnlflg,
                               d_cts65m00.imdsrvflg,
                               m_altcidufd,
                               d_cts65m00.prslocflg,
                               w_cts65m00.atdhorpvt,
                               w_cts65m00.atddatprg,
                               w_cts65m00.atdhorprg,
                               w_cts65m00.atdpvtretflg,
                               m_rsrchv,
                               m_operacao,
                               "",
                               a_cts65m00[1].cidnom,
                               a_cts65m00[1].ufdcod,
                               "",   # codigo de assistencia, nao existe no Ct24h
                               "",   # codigo do veiculo, somente Auto
                               "",   # categoria tarifaria, somente Auto
                               d_cts65m00.imdsrvflg,
                               a_cts65m00[1].c24lclpdrcod,
                               a_cts65m00[1].lclltt,
                               a_cts65m00[1].lcllgt,
                               g_documento.ciaempcod,
                               g_documento.atdsrvorg,
                               d_cts65m00.asitipcod,
                               d_cts65m00.socntzcod, # natureza  
                               d_cts65m00.espcod)    # sub-natureza 
                     returning w_cts65m00.atdhorpvt,
                               w_cts65m00.atddatprg,
                               w_cts65m00.atdhorprg,
                               w_cts65m00.atdpvtretflg,
                               d_cts65m00.imdsrvflg,
                               m_rsrchv,
                               m_operacao,
                               m_altdathor
                                  
                 display by name d_cts65m00.imdsrvflg
                 
                 if m_operacao = 1
                    then
                    #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW - apos nova chave'
                    call ctd41g00_baixar_agenda(m_rsrchv, ws.atdsrvano, ws.atdsrvnum)
                         returning l_errcod, l_errmsg
                 end if
              end if
              
              if l_errcod = 0
                  then
                  call cts02m08_ins_cota(m_rsrchv, ws.atdsrvnum, ws.atdsrvano)
                       returning l_errcod, l_errmsg
                       
                  if l_errcod = 0
                     then
                     #display 'cts02m08_ins_cota gravou com sucesso'
                  else
                     #display 'cts02m08_ins_cota erro ', l_errcod
                     display l_errmsg clipped
                  end if
               else
                  display 'cts65m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
               end if
               
            else
               #display l_txtsrv clipped, ' erro na inclusao, liberar agenda'
               
               call cts02m08_id_datahora_cota(m_rsrchv)
                    returning l_errcod, l_errmsg, m_agncotdat, m_agncothor
                    
               if l_errcod != 0
                  then
                  #display 'ctd41g00_liberar_agenda NAO acionado, erro no ID da cota'
                  display l_errmsg clipped
               end if
               
               call ctd41g00_liberar_agenda(ws.atdsrvano, ws.atdsrvnum
                                          , m_agncotdat, m_agncothor)
           end if
        end if
     end if
     # PSI-2013-00440PR
     
     let g_documento.lignum = l_lignum
     let w_cts65m00.atdsrvnum = ws.atdsrvnum
     let w_cts65m00.atdsrvano = ws.atdsrvano

     let d_cts65m00.srvnum = g_documento.atdsrvorg using "&&",
                             "/", w_cts65m00.atdsrvnum using "&&&&&&&",
                             "-", w_cts65m00.atdsrvano using "&&"

     display by name d_cts65m00.srvnum  attribute (reverse)
     error  " Verifique o numero do servico e tecle ENTER!"
     prompt "" for char ws.prompt_key
     error " Inclusao efetuada com sucesso!"

     let ws.retorno = true

     # Verifica se deseja o envio de SMS
     let l_confirma = "N"
     let l_confirma = cts08g01_confirma("A",
                               "F",
                               "CLIENTE DESEJA RECEBER A CONFIRMACAO",
                               " DO ACIONAMENTO, VIA SMS ?",
                               "",
                               "")

     #======================================
     # Grava flag de envio de email
     #======================================
     whenever error continue
     open c_cts65m00_066 using w_cts65m00.atdsrvnum,
                               w_cts65m00.atdsrvano
     fetch c_cts65m00_066 into l_count
     whenever error stop

     if l_count > 0 then
        call cts10g02_atualiza_flg_email(w_cts65m00.atdsrvnum,
                                         w_cts65m00.atdsrvano,
                                         l_confirma)
             returning l_resultado
                      ,l_mensagem

        if l_resultado <> 0 then
           error l_mensagem
        end if
     else
         whenever error continue
         execute p_cts65m00_067 using w_cts65m00.atdsrvnum,
                                      w_cts65m00.atdsrvano,
                                      l_confirma
         whenever error stop
     end if

     exit while
  end if

 end while

 return ws.retorno

end function  ###  inclui_cts65m00

#--------------------------------------------------------------------
function input_cts65m00()
#--------------------------------------------------------------------

 define l_status       smallint
      , l_mensagem     char(100)
      , l_null         char(01)
      , l_tela         char(03)
      , l_tela2        char(03)
      , l_flag         char(1)
      , l_altdatahora  char(1)
      , l_lgdcep       like datmlcl.lgdcep
      , l_lgdcepcmp    like datmlcl.lgdcepcmp
      , l_imdsrvflg    char(01)
      , l_cotadisponivel smallint      #PSI202363
      , l_tem_cota       smallint
      , l_chama_cts02m03 smallint
      , l_situacao_gps   smallint
      , l_data           like datmservico.atddatprg
      , l_hora           like datmservico.atdhorprg
      , l_data_2         like datmservico.atddatprg
      , l_hora_2         like datmservico.atdhorprg
      , l_confirma       char(1)
      , l_grpcod         like datkresitagrp.grpcod
      , l_laudo          char(1)

 define m_asiplncod like datkresitaasipln.asiplncod

 define ws            record
    lclflg            smallint,
    retflg            char (01),
    prpflg            char (01),
    lclrscflg         char (01),
    atdlibflg         like datmservico.atdlibflg,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    datacarencia      like rsdmdocto.viginc,
    diascarencia      smallint,
    endcmp            like rlaklocal.endcmp        ,
    linha             char (40),
    confirma          char (01),
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    cogidosql         integer,
    segnumdig         like abbmdoc.segnumdig,
    auxatdsrvnum      like datmservico.atdsrvnum,
    auxatdsrvano      like datmservico.atdsrvano,
    refatdsrvnum      like datmservico.atdsrvnum,
    refatdsrvano      like datmservico.atdsrvano,
    acaoslv           char (03),
    acaorislv         char (03),
    lclcttnom         like datmlcl.lclcttnom,
    rglflg            smallint,
    regulador         char(1),
    horasespera       interval hour(06) to minute,
    srvrglcod         like datksocntz.socntzgrpcod,
    regatddat         like datmservico.atddat,
    regatdhor         like datmservico.atdhor,
    regsocntzcod      like datmsrvre.socntzcod,
    regatdsrvnum      like datmservico.atdsrvnum,
    regatdsrvano      like datmservico.atdsrvano,
    regsocntzgrpcod   like datksocntz.socntzgrpcod,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    socvclcod         like datmservico.socvclcod,
    atdlibdat         like datmservico.atdlibdat,
    atdlibhor         like datmservico.atdlibhor,
    atddatprg         like datmservico.atddatprg,
    atdhorprg         like datmservico.atdhorprg,
    abater_cota       char(1),
    reservar_cota     char(1),
    verclscod         smallint
 end record

 define w_data_cota   like datmservico.atddatprg,
        w_hora_cota   like datmservico.atdhorprg,
        w_hora_cotac  char(10),
        w_etapa       like datmsrvacp.atdetpcod,
        w_horac       char(10),
        w_horaprg, w_horaatu integer,
        w_data_ant    like datmservico.atddatprg,
        w_hora_ant    like datmservico.atdhorprg

 define dS_cts65m00   record
    srvnum            char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    lclrscflg         char (01)                    ,
    orrdat            like datmsrvre.orrdat        ,
    servicorg         char(13)                     ,
    socntzcod         like datmsrvre.socntzcod     ,
    socntzdes         like datksocntz.socntzdes    ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    imdsrvflg         char (01)                    ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    prslocflg         char (01)                    ,
    atdtxt            char (65)                    ,
    srvretmtvcod      like datksrvret.srvretmtvcod ,
    srvretmtvdes      like datksrvret.srvretmtvdes ,
    espcod            like datmsrvre.espcod        ,
    espdes            like dbskesp.espdes          ,
    retprsmsmflg       like datmsrvre.retprsmsmflg
 end record

 define wS_cts65m00   record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    viginc            like rsdmdocto.viginc        ,
    vigfnl            like rsdmdocto.vigfnl        ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    ligcvntip         like datmligacao.ligcvntip   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24opemat         like datmservico.c24opemat   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdprscod         like datmservico.atdprscod   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    prslocflg         char (01)                    ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    clscod            like datrsocntzsrvre.clscod  ,
    SOcvclcod         like datmsrvacp.socvclcod    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    atzendereco       dec(1,0),
    cartao            char(21),
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define aS_cts65m00   record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig,
    emeviacod         like datmlcl.emeviacod       ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp
 end record

 define hist_cts65m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define lr_agd_p  record
     min_atddatprg        like datmservico.atddatprg,
     min_atdhorprg        like datmservico.atdhorprg,
     max_atddatprg        like datmservico.atddatprg,
     max_atdhorprg        like datmservico.atdhorprg
 end record

 define arr_aux         smallint,
        aux_num         char(03),
        l_aux           like datmsrvre.socntzcod,
        l_aux_24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod,
        l_result        smallint,
        l_resultado     char(01),
        erros_chk       char (01),
        cplS_atdsrvnum  like datmservico.atdsrvnum,
        cplS_atdsrvano  like datmservico.atdsrvano,
        cplS_atdsrvorg  like datmservico.atdsrvorg,
        l_atdsrvnum     like datmservico.atdsrvnum,
        l_atdsrvano     like datmservico.atdsrvano,
        l_lgdtxt        char (65)                 ,
        l_lclbrrnom     like datmlcl.lclbrrnom    ,
        l_cidnom        like datmlcl.cidnom       ,
        l_ufdcod        like datmlcl.ufdcod       ,
        l_linha3        char (40)                 ,
        l_linha4        char (40),
        l_c24astcod_slv like datmligacao.c24astcod,
        l_gpsacngrpcod  like datkmpacid.gpsacngrpcod,
        l_mpacidcod     like datkmpacid.mpacidcod,
        l_obter_qrv     smallint                 ,
        aux_lgdcep      char(8)                  ,
        l_natagdflg     char(1)                  ,
        l_contador      smallint                 ,
        l_cortesia      smallint                 ,
        l_natureza      like datmsrvre.socntzcod ,
        l_natureza_ant  like datmsrvre.socntzcod

 define l_par           smallint
 define l_clscod        like datrsocntzsrvre.clscod
 define l_acesso        smallint

 define l_codigo like datksocntz.socntzgrpcod

 define l_pstcoddig like datmsrvacp.pstcoddig

 define lr_retorno record
        resultado smallint
       ,mensagem  char(60)
 end record

 define lvalidaretorno  record
    noprazoflg   char(1),
    mensagem1    char(40),
    mensagem2    char(40)
 end record

 define l_c24opemat like datmservico.c24opemat

 define l_atdetpcod like datmsrvacp.atdetpcod

 define l_atdlibflg like datmservico.atdlibflg

 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
 to null

 #==========================================================
 # inicializando as Variaveis
 #==========================================================
 initialize l_c24opemat   to null
 initialize lr_retorno    to null
 initialize lvalidaretorno to null
 initialize l_atdetpcod   to null
 initialize lr_agd_p      to null
 initialize mr_cts08g01.* to null
 initialize  ws.*  to  null
 initialize  dS_cts65m00.*  to  null
 initialize  wS_cts65m00.*  to  null
 initialize  aS_cts65m00.*  to  null
 initialize  hist_cts65m00.*  to  null
 initialize  m_wk.* to null

 let l_pstcoddig             = null
 let l_c24astcod_slv         = null
 let l_lgdtxt                = null
 let l_lclbrrnom             = null
 let l_cidnom                = null
 let l_ufdcod                = null
 let l_linha3                = "                       "
 let l_linha4                = "                       "
 let l_resultado             = "S"
 let l_lgdcep                = null
 let l_lgdcepcmp             = null
 let l_flag                  = null
 let aux_lgdcep              = null
 let arr_aux                 =  null
 let aux_num                 =  null
 let erros_chk               =  null
 let cplS_atdsrvnum          =  null
 let cplS_atdsrvano          =  null
 let cplS_atdsrvorg          =  null
 let l_data                  = null
 let l_hora                  = null
 let l_par                   = 1
 let w_data_ant              = null
 let w_hora_ant              = null
 let l_tem_cota              = false
 let ws.lclcttnom            = a_cts65m00[1].lclcttnom
 let ws.lclrscflg            = d_cts65m00.lclrscflg
 let d_cts65m00.atdprinvlcod = 2  # SEMPRE 2-NORMAL
 let d_cts65m00.atdprinvldes = "NAO EXISTE"
 let m_veiculo_aciona        = null
 let ml_srvabrprsinfflg      = "N"
 let l_natagdflg = null

 whenever error continue
 
 open c_cts65m00_015 using d_cts65m00.atdprinvlcod
 fetch c_cts65m00_015 into d_cts65m00.atdprinvldes
 
 whenever error stop


 #//Fixar 6 - RE no asitipcod
 let d_cts65m00.asitipcod = 6

 open c_cts65m00_023 using d_cts65m00.asitipcod
 whenever error continue
 fetch c_cts65m00_023 into d_cts65m00.asitipabvdes
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       error 'Erro de SQL c_cts65m00_103 ',sqlca.sqlcode,'/'
       return hist_cts65m00.*
    else
       let d_cts65m00.asitipabvdes = null
    end if
 end if

 let l_obter_qrv = true

 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if
 
 # situacao original do servico
 let m_imdsrvflg = d_cts65m00.imdsrvflg
 let m_cidnom = a_cts65m00[1].cidnom
 let m_ufdcod = a_cts65m00[1].ufdcod
 # PSI-2013-00440PR
 
 
 #display 'entrada do input, var null ou carregada na consulta'
 #display 'd_cts65m00.imdsrvflg :', d_cts65m00.imdsrvflg
 #display 'a_cts65m00[1].cidnom :', a_cts65m00[1].cidnom
 #display 'a_cts65m00[1].ufdcod :', a_cts65m00[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant
 
 display by name d_cts65m00.atdprinvlcod
 display by name d_cts65m00.atdprinvldes
 display by name d_cts65m00.asitipcod

 input by name d_cts65m00.nom      ,
               d_cts65m00.corsus   ,
               d_cts65m00.cornom   ,
               d_cts65m00.lclrsccod,
               d_cts65m00.lclrscflg,
               ws.lclcttnom        ,
               d_cts65m00.orrdat   ,
               d_cts65m00.socntzcod,
               d_cts65m00.espcod,
               d_cts65m00.c24pbmcod,
               d_cts65m00.atddfttxt,
               d_cts65m00.srvretmtvcod,
               d_cts65m00.srvretmtvdes,
               d_cts65m00.retprsmsmflg,
               d_cts65m00.atdlibflg,
               d_cts65m00.prslocflg,
               #d_cts65m00.frmflg,
               d_cts65m00.imdsrvflg   without defaults

   before field nom
          if ws_acao is not null and
             ws_acao =  "RET"    then
             next field lclcttnom
          end if
          display by name d_cts65m00.nom        attribute (reverse)

   after  field nom
          display by name d_cts65m00.nom

          if d_cts65m00.nom is null  or
             d_cts65m00.nom =  "  "  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if w_cts65m00.atdfnlflg = "S"      or
             (ws_acaorigem is not null and ws_acaorigem = "CON") then

             if w_cts65m00.atdfnlflg = "S"  then

                error " Servico ja' acionado nao pode ser alterado!"
                let m_srv_acionado = true
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma
             else
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
             end if

             # INICIO PSI-2013-00440PR
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts65m00.atdfnlflg, d_cts65m00.imdsrvflg,
                              w_cts65m00.atdhorpvt, w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg, w_cts65m00.atdpvtretflg)
                    returning w_cts65m00.atdhorpvt, w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg, w_cts65m00.atdpvtretflg
	          else
                call cts02m08(w_cts65m00.atdfnlflg,
                              d_cts65m00.imdsrvflg,
                              m_altcidufd,
                              d_cts65m00.prslocflg,
                              w_cts65m00.atdhorpvt,
                              w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg,
                              w_cts65m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts65m00[1].cidnom,
                              a_cts65m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              "",   # codigo do veiculo, somente Auto
                              "",   # categoria tarifaria, somente Auto
                              d_cts65m00.imdsrvflg,
                              a_cts65m00[1].c24lclpdrcod,
                              a_cts65m00[1].lclltt,
                              a_cts65m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts65m00.asitipcod,
                              d_cts65m00.socntzcod, # natureza  
                              d_cts65m00.espcod)    # sub-natureza 
                    returning w_cts65m00.atdhorpvt,
                              w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg,
                              w_cts65m00.atdpvtretflg,
                              d_cts65m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             # FIM PSI-2013-00440PR
             
             let int_flag = true
             exit input
          end if


   before field corsus
          # Acessar endereco para ramo 31
          initialize ws_cgccpfnum, ws_cgccpfdig to null

          if cpl_atdsrvnum is null then

             if g_documento.atdsrvnum is null  and
                g_documento.atdsrvano is null  and
                g_documento.ramcod    =  14    then

                if g_documento.succod    is not null  and
                   g_documento.aplnumdig is not null  and
                   g_documento.itmnumdig is not null  then

                   if l_atdsrvnum is not null then

                      open c_cts65m00_025 using l_atdsrvnum,
                                                l_atdsrvano
                      whenever error continue
                      fetch c_cts65m00_025 into a_cts65m00[1].lgdtip,
                                              a_cts65m00[1].lgdnom,
                                              a_cts65m00[1].lgdnum,
                                              a_cts65m00[1].brrnom,
                                              a_cts65m00[1].lclbrrnom,
                                              a_cts65m00[1].cidnom,
                                              a_cts65m00[1].ufdcod,
                                              a_cts65m00[1].lgdcep,
                                              a_cts65m00[1].lgdcepcmp,
                                              a_cts65m00[1].lclrefptotxt,
                                              a_cts65m00[1].endcmp
                      whenever error stop

                      if sqlca.sqlcode <> 0 then
                        if sqlca.sqlcode = 100 then
                           error 'Endereco do ultimo servico nao cadastrado '
                        else
                           error 'Problemas em datmlcl, ',sqlca.sqlcode
                           let int_flag = true
                           exit input
                        end if
                      end if
                      if a_cts65m00[1].endcmp is null or
                         a_cts65m00[1].endcmp = " " then
                         call cts06g03_busca_complemento_apolice()
                              returning a_cts65m00[1].endcmp
                      end if
                   else
                      call f_funapol_ultima_situacao (g_documento.succod,
                                                      g_documento.aplnumdig,
                                                      g_documento.itmnumdig)
                           returning g_funapol.*

                      whenever error continue
                      open c_cts65m00_026 using g_documento.succod
                                               ,g_documento.aplnumdig
                                               ,g_documento.itmnumdig
                                               ,g_funapol.dctnumseq
                      fetch c_cts65m00_026 into ws.segnumdig

                      whenever error stop


                      if sqlca.sqlcode = 0   then
                         #--------------------------------------------
                         # Dados do cgc/cpf segurado
                         #--------------------------------------------
                         whenever error continue

                         open c_cts65m00_027 using ws.segnumdig
                         fetch c_cts65m00_027 into ws_cgccpfnum, ws_cgccpfdig

                         whenever error stop

                         whenever error continue

                         open c_cts65m00_028 using ws.segnumdig
                         fetch c_cts65m00_028 into a_cts65m00[1].lgdtip
                                                  ,a_cts65m00[1].lgdnom
                                                  ,a_cts65m00[1].lgdnum
                                                  ,a_cts65m00[1].endcmp
                                                  ,a_cts65m00[1].lclbrrnom
                                                  ,a_cts65m00[1].cidnom
                                                  ,a_cts65m00[1].ufdcod
                                                  ,a_cts65m00[1].lgdcep
                                                  ,a_cts65m00[1].lgdcepcmp

                         whenever error stop
                      end if
                   end if
                end if

                let a_cts65m00[1].lgdtxt = a_cts65m00[1].lgdtip clipped, " ",
                                           a_cts65m00[1].lgdnom clipped, " ",
                                           a_cts65m00[1].lgdnum using "<<<<#"

                display by name a_cts65m00[1].lgdtxt,
                                a_cts65m00[1].lclbrrnom,
                                a_cts65m00[1].cidnom,
                                a_cts65m00[1].ufdcod,
                                a_cts65m00[1].lclrefptotxt,
                                a_cts65m00[1].endzon,
                                a_cts65m00[1].dddcod,
                                a_cts65m00[1].lcltelnum,
                                a_cts65m00[1].lclcttnom,
                                a_cts65m00[1].endcmp

                let l_lgdtxt    = a_cts65m00[1].lgdtxt
                let l_lclbrrnom = a_cts65m00[1].lclbrrnom
                let l_cidnom    = a_cts65m00[1].cidnom
                let l_ufdcod    = a_cts65m00[1].ufdcod
             end if
          end if
          display by name d_cts65m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts65m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts65m00.corsus is not null  then
                whenever error continue

                open c_cts65m00_029 using d_cts65m00.corsus
                fetch c_cts65m00_029 into d_cts65m00.cornom

                whenever error stop

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts65m00.cornom
                   next field lclrsccod
                end if
             end if
          end if

   before field cornom
          display by name d_cts65m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts65m00.cornom

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
                next field lclrsccod
             end if
          end if

   before field lclrsccod
          if flgcpl = 1  then
             let flgcpl = 0
             next field orrdat
          end if

          if g_documento.succod    is null  or
             g_documento.ramcod    is null  or
             g_documento.ramcod    =  14    or
             g_documento.aplnumdig is null  or
             g_documento.crtsaunum is not null then

             let d_cts65m00.lclrscflg = "N"
             display by name d_cts65m00.lclrscflg
             next field lclrscflg

          else
             display by name d_cts65m00.lclrsccod  attribute (reverse)
          end if

   after  field lclrsccod
          display by name d_cts65m00.lclrsccod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts65m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts65m00.lclrsccod is null  then

                let d_cts65m00.lclrsccod = mr_rsc_re.lclrsccod

                error " Alteracao do Local de Risco nao permitida."

                display by name d_cts65m00.lclrsccod
                next field lclrsccod

             else
                if d_cts65m00.lclrsccod <> mr_rsc_re.lclrsccod then

                   let d_cts65m00.lclrsccod = mr_rsc_re.lclrsccod

                   error " Alteracao do Local de Risco nao permitida."

                   display by name d_cts65m00.lclrsccod
                   next field lclrsccod
                end if

                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then

                      # pesquisa ultimo servico da apolice
                      open c_cts65m00_030 using g_documento.ramcod
                                             ,g_documento.succod
                                             ,g_documento.aplnumdig
                                             ,g_documento.itmnumdig
                                             ,g_documento.lclnumseq
                                             ,g_documento.rmerscseq
                      whenever error continue
                      fetch c_cts65m00_030 into l_atdsrvnum, l_atdsrvano
                      whenever error stop
                      close c_cts65m00_030


                      if l_atdsrvnum is not null then

                         ---[ busca o endereco do servico ]---
                         open c_cts65m00_025 using l_atdsrvnum,
                                                 l_atdsrvano
                         whenever error continue
                         fetch c_cts65m00_025 into a_cts65m00[1].lgdtip,
                                                 a_cts65m00[1].lgdnom,
                                                 a_cts65m00[1].lgdnum,
                                                 a_cts65m00[1].brrnom,
                                                 a_cts65m00[1].lclbrrnom,
                                                 a_cts65m00[1].cidnom,
                                                 a_cts65m00[1].ufdcod,
                                                 a_cts65m00[1].lgdcep,
                                                 a_cts65m00[1].lgdcepcmp,
                                                 a_cts65m00[1].lclrefptotxt,
                                                 a_cts65m00[1].endcmp
                         whenever error stop
                      end if
                      let a_cts65m00[1].lgdtxt =
                          a_cts65m00[1].lgdtip clipped, " ",
                          a_cts65m00[1].lgdnom clipped, " ",
                          a_cts65m00[1].lgdnum using "<<<<#"
               end if
             end if
          end if

          display by name a_cts65m00[1].lgdtxt,
                          a_cts65m00[1].lclbrrnom,
                          a_cts65m00[1].cidnom,
                          a_cts65m00[1].ufdcod,
                          a_cts65m00[1].lclrefptotxt,
                          a_cts65m00[1].endzon,
                          a_cts65m00[1].dddcod,
                          a_cts65m00[1].lcltelnum,
                          a_cts65m00[1].lclcttnom

     #Priscila - 12/12/05 - correcao - qdo nao aceitava novo endereco para
     # uma apolice RE, o endereco inicial estava desaparecendo
            let l_lgdtxt    = a_cts65m00[1].lgdtxt
            let l_lclbrrnom = a_cts65m00[1].lclbrrnom
            let l_cidnom    = a_cts65m00[1].cidnom
            let l_ufdcod    = a_cts65m00[1].ufdcod

   before field lclrscflg
          if g_documento.atdsrvnum is null      and
             g_documento.atdsrvano is null      and
             d_cts65m00.lclrsccod  is not null  then
             let d_cts65m00.lclrscflg = "S"
          end if

          display by name d_cts65m00.lclrscflg  attribute (reverse)

   after  field lclrscflg
          display by name d_cts65m00.lclrscflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts65m00.lclrscflg is null  then
                error " Atendimento no local de risco deve ser informado!"
                next field lclrscflg
             else
                if d_cts65m00.lclrscflg <> "S"  and
                   d_cts65m00.lclrscflg <> "N"  then
                  error "Atendimento no local de risco deve ser (S)im ou (N)ao!"
                   next field lclrscflg
                end if
             end if

             if d_cts65m00.lclrscflg = "S"  then

                display by name a_cts65m00[1].lgdtxt,
                                a_cts65m00[1].lclbrrnom,
                                a_cts65m00[1].cidnom,
                                a_cts65m00[1].ufdcod,
                                a_cts65m00[1].lclrefptotxt,
                                a_cts65m00[1].endzon,
                                a_cts65m00[1].dddcod,
                                a_cts65m00[1].lcltelnum,
                                a_cts65m00[1].lclcttnom
             end if

             let l_lgdcep = a_cts65m00[1].lgdcep
             let l_lgdcepcmp = a_cts65m00[1].lgdcepcmp

             let a_cts65m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

             let m_acesso_ind = false
             let m_atdsrvorg = 13
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
             returning m_acesso_ind

             if m_acesso_ind = false then
                 call cts06g03(1,
                               13,
                               w_cts65m00.ligcvntip,
                               aux_today,
                               aux_hora,
                               a_cts65m00[1].lclidttxt,
                               a_cts65m00[1].cidnom,
                               a_cts65m00[1].ufdcod,
                               a_cts65m00[1].brrnom,
                               a_cts65m00[1].lclbrrnom,
                               a_cts65m00[1].endzon,
                               a_cts65m00[1].lgdtip,
                               a_cts65m00[1].lgdnom,
                               a_cts65m00[1].lgdnum,
                               a_cts65m00[1].lgdcep,
                               a_cts65m00[1].lgdcepcmp,
                               a_cts65m00[1].lclltt,
                               a_cts65m00[1].lcllgt,
                               a_cts65m00[1].lclrefptotxt,
                               a_cts65m00[1].lclcttnom,
                               a_cts65m00[1].dddcod,
                               a_cts65m00[1].lcltelnum,
                               a_cts65m00[1].c24lclpdrcod,
                               a_cts65m00[1].ofnnumdig,
                               a_cts65m00[1].celteldddcod,
                               a_cts65m00[1].celtelnum,
                               a_cts65m00[1].endcmp,
                               hist_cts65m00.*, a_cts65m00[1].emeviacod)
                     returning a_cts65m00[1].lclidttxt,
                               a_cts65m00[1].cidnom,
                               a_cts65m00[1].ufdcod,
                               a_cts65m00[1].brrnom,
                               a_cts65m00[1].lclbrrnom,
                               a_cts65m00[1].endzon,
                               a_cts65m00[1].lgdtip,
                               a_cts65m00[1].lgdnom,
                               a_cts65m00[1].lgdnum,
                               a_cts65m00[1].lgdcep,
                               a_cts65m00[1].lgdcepcmp,
                               a_cts65m00[1].lclltt,
                               a_cts65m00[1].lcllgt,
                               a_cts65m00[1].lclrefptotxt,
                               a_cts65m00[1].lclcttnom,
                               a_cts65m00[1].dddcod,
                               a_cts65m00[1].lcltelnum,
                               a_cts65m00[1].c24lclpdrcod,
                               a_cts65m00[1].ofnnumdig,
                               a_cts65m00[1].celteldddcod,
                               a_cts65m00[1].celtelnum,
                               a_cts65m00[1].endcmp,
                               ws.retflg,
                               hist_cts65m00.*, a_cts65m00[1].emeviacod
             else
                 call cts06g11(1,
                               13,
                               w_cts65m00.ligcvntip,
                               aux_today,
                               aux_hora,
                               a_cts65m00[1].lclidttxt,
                               a_cts65m00[1].cidnom,
                               a_cts65m00[1].ufdcod,
                               a_cts65m00[1].brrnom,
                               a_cts65m00[1].lclbrrnom,
                               a_cts65m00[1].endzon,
                               a_cts65m00[1].lgdtip,
                               a_cts65m00[1].lgdnom,
                               a_cts65m00[1].lgdnum,
                               a_cts65m00[1].lgdcep,
                               a_cts65m00[1].lgdcepcmp,
                               a_cts65m00[1].lclltt,
                               a_cts65m00[1].lcllgt,
                               a_cts65m00[1].lclrefptotxt,
                               a_cts65m00[1].lclcttnom,
                               a_cts65m00[1].dddcod,
                               a_cts65m00[1].lcltelnum,
                               a_cts65m00[1].c24lclpdrcod,
                               a_cts65m00[1].ofnnumdig,
                               a_cts65m00[1].celteldddcod,
                               a_cts65m00[1].celtelnum,
                               a_cts65m00[1].endcmp,
                               hist_cts65m00.*, a_cts65m00[1].emeviacod)
                     returning a_cts65m00[1].lclidttxt,
                               a_cts65m00[1].cidnom,
                               a_cts65m00[1].ufdcod,
                               a_cts65m00[1].brrnom,
                               a_cts65m00[1].lclbrrnom,
                               a_cts65m00[1].endzon,
                               a_cts65m00[1].lgdtip,
                               a_cts65m00[1].lgdnom,
                               a_cts65m00[1].lgdnum,
                               a_cts65m00[1].lgdcep,
                               a_cts65m00[1].lgdcepcmp,
                               a_cts65m00[1].lclltt,
                               a_cts65m00[1].lcllgt,
                               a_cts65m00[1].lclrefptotxt,
                               a_cts65m00[1].lclcttnom,
                               a_cts65m00[1].dddcod,
                               a_cts65m00[1].lcltelnum,
                               a_cts65m00[1].c24lclpdrcod,
                               a_cts65m00[1].ofnnumdig,
                               a_cts65m00[1].celteldddcod,
                               a_cts65m00[1].celtelnum,
                               a_cts65m00[1].endcmp,
                               ws.retflg,
                               hist_cts65m00.*, a_cts65m00[1].emeviacod

             end if

             let m_subbairro[1].lclbrrnom = a_cts65m00[1].lclbrrnom

             call cts06g10_monta_brr_subbrr(a_cts65m00[1].brrnom,
                                            a_cts65m00[1].lclbrrnom)
                  returning a_cts65m00[1].lclbrrnom

             let a_cts65m00[1].lgdtxt = a_cts65m00[1].lgdtip clipped, " ",
                                        a_cts65m00[1].lgdnom clipped, " ",
                                        a_cts65m00[1].lgdnum using "<<<<#"


             if l_lgdcep <> a_cts65m00[1].lgdcep or
                l_lgdcepcmp <> a_cts65m00[1].lgdcepcmp then

                call cts08g01("A","S","CONFIRME ALTERACAO DE ENDERECO PARA",
                              "ENVIO DE ASSISTENCIA A RESIDENCIA?",l_linha3,
                              l_linha4)
                     returning l_resultado

                if l_resultado = "N" then
                   let a_cts65m00[1].lgdtxt    = l_lgdtxt
                   let a_cts65m00[1].lclbrrnom = l_lclbrrnom
                   let a_cts65m00[1].cidnom    = l_cidnom
                   let a_cts65m00[1].ufdcod    = l_ufdcod
                end if
             end if

             display by name a_cts65m00[1].lgdtxt
             display by name a_cts65m00[1].lclbrrnom
             display by name a_cts65m00[1].endzon
             display by name a_cts65m00[1].cidnom
             display by name a_cts65m00[1].ufdcod
             display by name a_cts65m00[1].lclrefptotxt
             display by name a_cts65m00[1].lclcttnom
             display by name a_cts65m00[1].dddcod
             display by name a_cts65m00[1].lcltelnum
             display by name a_cts65m00[1].celteldddcod
             display by name a_cts65m00[1].celtelnum
             display by name a_cts65m00[1].endcmp

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field lclrscflg
             end if

             if g_documento.atdsrvnum is not null and
                g_documento.atdsrvano is not null then
                next field srvretmtvcod
             end if

             next field orrdat
          end if

   before field lclcttnom
          let ws.lclcttnom = a_cts65m00[1].lclcttnom
          display by name ws.lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name ws.lclcttnom

          if w_cts65m00.atdfnlflg = "S"  or
            (ws_acaorigem is not null and ws_acaorigem = "CON") then

             if w_cts65m00.atdfnlflg = "S"  then

                error " Servico ja' acionado nao pode ser alterado!"
                let m_srv_acionado = true
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma
             else
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
             end if

             # INICIO PSI-2013-00440PR
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts65m00.atdfnlflg, d_cts65m00.imdsrvflg,
                              w_cts65m00.atdhorpvt, w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg, w_cts65m00.atdpvtretflg)
                    returning w_cts65m00.atdhorpvt, w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg, w_cts65m00.atdpvtretflg
	          else
                call cts02m08(w_cts65m00.atdfnlflg,
                              d_cts65m00.imdsrvflg,
                              m_altcidufd,
                              d_cts65m00.prslocflg,
                              w_cts65m00.atdhorpvt,
                              w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg,
                              w_cts65m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts65m00[1].cidnom,
                              a_cts65m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              "",   # codigo do veiculo, somente Auto
                              "",   # categoria tarifaria, somente Auto
                              d_cts65m00.imdsrvflg,
                              a_cts65m00[1].c24lclpdrcod,
                              a_cts65m00[1].lclltt,
                              a_cts65m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts65m00.asitipcod,
                              d_cts65m00.socntzcod, # natureza  
                              d_cts65m00.espcod)    # sub-natureza 
                    returning w_cts65m00.atdhorpvt,
                              w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg,
                              w_cts65m00.atdpvtretflg,
                              d_cts65m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             # FIM PSI-2013-00440PR
             
             let int_flag = true
             exit input
          end if

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if ws_acao is not null and
                ws_acao =  "RET"    then
                next field lclcttnom
             end if
          end if
          
          let a_cts65m00[1].lclcttnom = ws.lclcttnom

   before field orrdat
          display by name d_cts65m00.orrdat attribute (reverse)

   after  field orrdat
          display by name d_cts65m00.orrdat

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts65m00.orrdat is null        then
                error " Data da ocorrencia deve ser informada!"
                next field orrdat
             end if

             if d_cts65m00.orrdat > m_data   then
                error " Data da ocorrencia nao deve ser maior que hoje!"
                next field orrdat
             end if

             if d_cts65m00.orrdat < m_data - 180 units day  then
                error " Data da ocorrencia nao deve ser anterior a SEIS meses!"
                next field orrdat
             end if

             if d_cts65m00.orrdat < w_cts65m00.viginc  or
                d_cts65m00.orrdat > w_cts65m00.vigfnl  then
                error " Data da ocorrencia esta' fora da vigencia da apolice!"
                call cts08g01("A","N","","DATA DA OCORRENCIA ESTA' FORA",
                                         "DA VIGENCIA DA APOLICE !", "")
                     returning ws.confirma
             end if
          else
             if ws_acao is not null and
                ws_acao =  "RET"    then
                next field lclcttnom
             else
                next field lclrscflg
             end if
          end if


   before field socntzcod
          display by name d_cts65m00.socntzcod attribute (reverse)

         #Busca Cortesia
           call cts65m00_assunto_cortesia()
                 returning l_cortesia


           if g_documento.c24astcod <> 'RET' and
             (g_documento.acao <> "ALT" or
              g_documento.acao <> "CON" ) then

               if l_cortesia = false and
                  g_documento.aplnumdig is not null then
                     call cts12g05(g_doc_itau[1].itaasisrvcod,'N',d_cts65m00.socntzcod)
                          returning d_cts65m00.socntzcod
               else
                  
                  if g_documento.c24astcod = 'R68' or
                  	 g_documento.c24astcod = 'RAR' then 
                  	  call cts12g05(g_doc_itau[1].itaasisrvcod,'N',d_cts65m00.socntzcod) 
                  	  returning d_cts65m00.socntzcod                                               
                  else
                      call cts17m06_popup_natureza
                           (g_documento.aplnumdig, g_documento.c24astcod,
                            g_documento.ramcod, l_null,
                            m_rmemdlcod, m_wk.prporg, m_wk.prpnumdig,l_null,
                            g_documento.crtsaunum)
                            returning d_cts65m00.socntzcod, l_clscod 
                  end if           
               end if
           end if

   after  field socntzcod
          display by name d_cts65m00.socntzcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field orrdat
          end if

          if d_cts65m00.socntzcod is null then
                error " Codigo de natureza deve ser informada!"
                next field socntzcod
          end if

          call ctc16m03_inf_natureza(d_cts65m00.socntzcod,'A')
               returning l_status, l_mensagem, d_cts65m00.socntzdes, l_codigo

          display by name d_cts65m00.socntzcod
          display by name d_cts65m00.socntzdes


    # Acionamento automatico - selecionar especialidade do servico
    before field espcod
          #So ativar especialidade qdo grupo de servico = 1 (linha branca)
          if l_codigo <> 1 then
              next field c24pbmcod
          end if

          #caso nao tenha especialidade cadastrada - pular o campo
          call cts31g00_qtde_especialidade("A")
               returning ws.confirma

          if ws.confirma <> 0 then
             #E obrigatorio ter 1 especialidade cadastrada(1 - GERAL)
             # que deve ser a padrao, se nao tiver teremos problemas com
             # cadastro de socorrista. Para selecionar qq outra especialidade
             # informar branco no codigo que ira abrir a tela de pop up, caso
             # tenha mais de um registro
             let d_cts65m00.espcod = 1
             display by name d_cts65m00.espcod attribute (reverse)
          else
             next field c24pbmcod
          end if

    after field espcod
          display by name d_cts65m00.espcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field socntzcod
          end if

          #espcod nao é obrigatorio entao apenas exibir
          #a lista de especialidade

          if d_cts65m00.espcod is null then

             call cts31g00_lista_especialidade()
                  returning ws.confirma,
                            d_cts65m00.espcod,
                            d_cts65m00.espdes
             if ws.confirma = 3 then
                 error "Problemas ao listar especialidades"
             end if

          else

             # Buscar descricao apenas para especialidade ativa
             call cts31g00_descricao_esp(d_cts65m00.espcod, "A")
                  returning d_cts65m00.espdes

             if d_cts65m00.espdes is null then
                #codigo especialidade invalido
                error "Codigo de especialidade invalido."
                next field espcod
             end if

          end if

          display by name d_cts65m00.espcod
          display by name d_cts65m00.espdes

    before field c24pbmcod
        display by name d_cts65m00.c24pbmcod attribute (reverse)

    after  field c24pbmcod
        display by name d_cts65m00.c24pbmcod

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then

           let d_cts65m00.c24pbmcod = null
           let d_cts65m00.atddfttxt = null

           display by name d_cts65m00.c24pbmcod
           display by name d_cts65m00.atddfttxt

           if d_cts65m00.espcod is not null then
              next field espcod
           else
              next field socntzcod
           end if
        end if
           call cts17m07_problema(g_documento.aplnumdig
                                 ,g_documento.c24astcod
                                 ,g_documento.atdsrvorg
                                 ,d_cts65m00.c24pbmcod
                                 ,d_cts65m00.socntzcod
                                 ,l_clscod
                                 ,w_cts65m00.clscod
                                 ,m_rmemdlcod
                                 ,g_documento.ramcod
                                 ,g_documento.crtsaunum )
                        returning l_status
                                 ,l_mensagem
                                 ,d_cts65m00.c24pbmcod
                                 ,d_cts65m00.atddfttxt

        if l_status <> 1 then
           error l_mensagem
           next field c24pbmcod
        end if

        display by name d_cts65m00.c24pbmcod
        display by name d_cts65m00.atddfttxt

         if g_documento.acao = 'INC' and d_cts65m00.c24pbmcod <> 999
            and  (ws_acao is null or ws_acao <> "RET" ) then

             if  fgl_lastkey() <> fgl_keyval("up") and
                 fgl_lastkey() <> fgl_keyval("left") then

                   whenever error continue
                   open c_cts65m00_070 using g_doc_itau[1].itaasisrvcod
                   fetch c_cts65m00_070 into m_asiplncod
                   whenever error stop

                   whenever error continue
                     open c_cts65m00_068 using d_cts65m00.socntzcod,m_asiplncod
                     fetch c_cts65m00_068 into l_grpcod
                   whenever error stop

                   whenever error continue
                     open c_cts65m00_069 using l_grpcod
                     fetch c_cts65m00_069 into l_laudo
                   whenever error stop

                if l_laudo = "S" then
                   
                   if g_documento.c24astcod = "R67" or                         
                   	  g_documento.c24astcod = "R68" or
                   	  g_documento.c24astcod = "RAR" then                       
                   	 	let l_confirma = "N"                                    
                   else	 	                                                    
                      call cts08g01("A"                                 ,
                                    "S"                                 ,
                                    "ESTA NATUREZA FAZ PARTE "          ,
                                    "DE PACOTE SERVICOS"                ,
                                    "DESEJA SOLICITAR OUTROS SERVICOS"  ,
                                    "DESSE PACOTE")
                      returning l_confirma   
                   end if

                else
                   if g_documento.c24astcod = "R67" or                          
                   	  g_documento.c24astcod = "R68" or
                   	  g_documento.c24astcod = "RAR" then    
                   	  	                   
                      let l_confirma = "N"                                      
                   else                	                                       
                      call cts08g01("C","S",' ',"INCLUIR MAIS OCORRENCIAS ?",'','')
                      returning l_confirma
                   end if
                end if


                   if l_confirma = "S" then
                      call cts17m03_laudo_multiplo(g_documento.ramcod,
                                                   g_documento.succod,
                                                   g_documento.aplnumdig,
                                                   g_documento.itmnumdig,
                                                   g_documento.c24astcod,
                                                   w_cts65m00.clscod,
                                                   l_clscod, m_rmemdlcod,
                                                   m_wk.prporg, m_wk.prpnumdig,
                                                   d_cts65m00.socntzcod,
                                                   l_codigo,
                                                   g_documento.bnfnum,
                                                   g_documento.crtsaunum,
                                                   am_param[1].*,
                                                   am_param[2].*,
                                                   am_param[3].*,
                                                   am_param[4].*,
                                                   am_param[5].*,
                                                   am_param[6].*,
                                                   am_param[7].*,
                                                   am_param[8].*,
                                                   am_param[9].*,
                                                   am_param[10].* )
                           returning am_param[1].*  ,am_param[2].*  ,am_param[3].*
                                    ,am_param[4].*  ,am_param[5].*  ,am_param[6].*
                                    ,am_param[7].*  ,am_param[8].*  ,am_param[9].*
                                    ,am_param[10].*
                   end if


             else
                 display by name d_cts65m00.c24pbmcod
                 next field socntzcod
             end if

          end if

   before field atddfttxt
          display by name d_cts65m00.atddfttxt attribute (reverse)
          if d_cts65m00.c24pbmcod <> 999 then
             next field srvretmtvcod
          end if

   after  field atddfttxt
          display by name d_cts65m00.atddfttxt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts65m00.atddfttxt  is null   then
                error " Problema apresentado deve ser informado!"
                next field atddfttxt
             end if

             if g_documento.acao = 'INC' and
               (ws_acao is null or ws_acao <> "RET" ) then

               if  fgl_lastkey() <> fgl_keyval("up") and
                   fgl_lastkey() <> fgl_keyval("left") then

                   whenever error continue
                   open c_cts65m00_070 using g_doc_itau[1].itaasisrvcod
                   fetch c_cts65m00_070 into m_asiplncod
                   whenever error stop

                   whenever error continue
                     open c_cts65m00_068 using d_cts65m00.socntzcod
                     fetch c_cts65m00_068 into l_grpcod
                   whenever error stop

                   whenever error continue
                     open c_cts65m00_069 using l_grpcod
                     fetch c_cts65m00_069 into l_laudo
                   whenever error stop

                if l_laudo = "S" then
                    if g_documento.c24astcod = "R67" or     
                    	 g_documento.c24astcod = "R68" or
                       g_documento.c24astcod = "RAR" then 
                    	 	let l_confirma = "N"
                    else	 	     
                        call cts08g01("A"                                 ,     
                                      "S"                                 ,     
                                      "ESTA NATUREZA FAZ PARTE "          ,     
                                      "DE PACOTE SERVICOS"                ,     
                                      "DESEJA SOLICITAR OUTROS SERVICOS"  ,     
                                      "DESSE PACOTE")                           
                        returning l_confirma    
                    end if                                
                else
                   
                   if g_documento.c24astcod = "R67" or
                   	  g_documento.c24astcod = "R68" or 
                   	  g_documento.c24astcod = "RAR" then
                      let l_confirma = "N"
                   else                	
                      call cts08g01("C","S",' ',"INCLUIR MAIS OCORRENCIAS ?",'','')
                      returning l_confirma
                   end if
                end if


                   if l_confirma = "S" then
                       call cts17m03_laudo_multiplo(g_documento.ramcod,
                                                 g_documento.succod,
                                                 g_documento.aplnumdig,
                                                 g_documento.itmnumdig,
                                                 g_documento.c24astcod,
                                                 w_cts65m00.clscod,
                                                 l_clscod,
                                                 m_rmemdlcod,
                                                 m_wk.prporg,
                                                 m_wk.prpnumdig,
                                                 d_cts65m00.socntzcod,
                                                 l_codigo,
                                                 g_documento.bnfnum,
                                                 g_documento.crtsaunum,
                                                 am_param[1].*,
                                                 am_param[2].*,
                                                 am_param[3].*,
                                                 am_param[4].*,
                                                 am_param[5].*,
                                                 am_param[6].*,
                                                 am_param[7].*,
                                                 am_param[8].*,
                                                 am_param[9].*,
                                                 am_param[10].* )
                         returning am_param[1].*  ,am_param[2].*  ,am_param[3].*
                                  ,am_param[4].*  ,am_param[5].*  ,am_param[6].*
                                  ,am_param[7].*  ,am_param[8].*  ,am_param[9].*
                                  ,am_param[10].*
                 end if
             else
                 display by name d_cts65m00.c24pbmcod
                 next field socntzcod
             end if

          end if
          end if

    before field srvretmtvcod

        if ws_acao is not null and
           ws_acao =  "RET"    then
           # Solicitacao do (RET)orno
        else
           next field atdlibflg
        end if

        display by name d_cts65m00.srvretmtvcod attribute (reverse)

    after  field srvretmtvcod
        display by name d_cts65m00.srvretmtvcod

        if fgl_lastkey() =  fgl_keyval("up")   or
           fgl_lastkey() =  fgl_keyval("left") then
           next field orrdat
        end if

        if d_cts65m00.srvretmtvcod  is null  or
           d_cts65m00.srvretmtvcod  =  0     then
           call ctb24m01() returning d_cts65m00.srvretmtvcod
           next field srvretmtvcod
        else
           if d_cts65m00.srvretmtvcod <> 999 then

              whenever error continue
              open c_cts65m00_009 using d_cts65m00.srvretmtvcod
              fetch c_cts65m00_009 into d_cts65m00.srvretmtvdes
              whenever error stop

              close c_cts65m00_009

              if sqlca.sqlcode = notfound then
                 error " Codigo do motivo nao existe!"
                 call ctb24m01() returning d_cts65m00.srvretmtvcod
                 next field srvretmtvcod
              end if

              display by name d_cts65m00.srvretmtvdes

              # Verifica prazo para abertura de servico de retorno
              call cts17m01_valida_prazo_retorno(cpl_atdsrvnum, cpl_atdsrvano, d_cts65m00.srvretmtvcod)
                   returning lvalidaretorno.noprazoflg,
                   		       lvalidaretorno.mensagem1,
                   		       lvalidaretorno.mensagem2

              if lvalidaretorno.noprazoflg = 'N' then
                 call cts08g01("A","N","SERVICO DE RETORNO NAO PODE SER ABERTO",
                                       " ",
                                       lvalidaretorno.mensagem1,
                                       lvalidaretorno.mensagem2)
                              returning ws.confirma
                 next field srvretmtvcod
              end if

              next field retprsmsmflg

           end if

        end if

        display by name d_cts65m00.srvretmtvdes

   before field srvretmtvdes
          display by name d_cts65m00.srvretmtvdes
          if d_cts65m00.srvretmtvcod <> 999 then
             next field atdlibflg
          end if
          display by name d_cts65m00.srvretmtvdes attribute (reverse)

   after  field srvretmtvdes
          display by name d_cts65m00.srvretmtvdes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts65m00.srvretmtvdes  is null   then
                error " Motivo apresentado deve ser informado!"
                next field srvretmtvdes
             end if

          end if

   # Acionamento automatico - informar se mesmo prestador
   before field retprsmsmflg
        if ws_acao is not null and
           ws_acao =  "RET"    then
           # Solicitacao do (RET)orno
        else
           next field atdlibflg
        end if
        display by name d_cts65m00.retprsmsmflg attribute (reverse)

    after  field retprsmsmflg
        display by name d_cts65m00.retprsmsmflg

        if fgl_lastkey() =  fgl_keyval("up")   or
           fgl_lastkey() =  fgl_keyval("left") then
           next field srvretmtvcod
        end if

        if  d_cts65m00.retprsmsmflg <> 'S' and
            d_cts65m00.retprsmsmflg <> 'N' then
              error " Informar se deseja mesmo prestador no retorno "
              next field retprsmsmflg
        end if


   before field atdlibflg
          ##-- inicializar o atdlibflg e passar para o proximo campo

          if d_cts65m00.atdlibflg is null then

             let d_cts65m00.atdlibflg = "S"
             display by name d_cts65m00.atdlibflg
             ##-- inicializar data e hora

             call cts40g03_data_hora_banco(2) returning m_data, m_hora
             let w_cts65m00.atdlibhor = m_hora
             let w_cts65m00.atdlibdat = m_data

             next field prslocflg
          end if

          display by name d_cts65m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts65m00.atdfnlflg  =  "S"       then
             next field imdsrvflg # exit input
          end if


   after  field atdlibflg
          let l_obter_qrv = true
          display by name d_cts65m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up") or
             fgl_lastkey() = fgl_keyval("left") then
             if g_documento.acao = 'INC' then
                next field c24pbmcod
             else
                next field lclrscflg
             end if
          end if

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then


             if d_cts65m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts65m00.atdlibflg <> "S"  and
                d_cts65m00.atdlibflg <> "N"  then
                error " Envio liberado deve ser (S)im ou (N)ao!"
                next field atdlibflg
             end if

             let ws.atdlibflg = d_cts65m00.atdlibflg
             display by name d_cts65m00.atdlibflg

             if w_cts65m00.atdlibflg is null  then
                if ws.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2) returning m_data, m_hora
                   let w_cts65m00.atdlibdat = m_data
                   let w_cts65m00.atdlibhor = m_hora

                else
                   let d_cts65m00.atdlibflg = "N"
                   display by name d_cts65m00.atdlibflg
                   initialize w_cts65m00.atdlibhor to null
                   initialize w_cts65m00.atdlibdat to null
                end if
             else

                select atdfnlflg
                  from datmservico
                 where atdsrvnum = g_documento.atdsrvnum  and
                       atdsrvano = g_documento.atdsrvano  and
                       atdfnlflg in ("N", "A")

                if sqlca.sqlcode = notfound  then
                   error " Servico ja' acionado nao pode ser alterado!"
                   let m_srv_acionado = true

                   call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                 " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                 "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                        returning ws.confirma
                   next field atdlibflg
                end if


                if w_cts65m00.atdlibflg = "S"  then
                   if ws.atdlibflg = "S" then
                      next field imdsrvflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg

                      let d_cts65m00.atdlibflg = "N"
                      display by name d_cts65m00.atdlibflg

                      initialize w_cts65m00.atdlibhor to null
                      initialize w_cts65m00.atdlibdat to null

                      error " Liberacao cancelada!" sleep 1
                      next field imdsrvflg
                   end if
                else
                   if w_cts65m00.atdlibflg = "N"   then
                      if ws.atdlibflg = "N" then
                         next field imdsrvflg
                      else
                         call cts40g03_data_hora_banco(2)
                              returning m_data, m_hora

                         let w_cts65m00.atdlibdat = m_data
                         let w_cts65m00.atdlibhor = m_hora

                         next field imdsrvflg
                      end if
                   end if
                end if
             end if
          else
             if ws_acao is not null and
                ws_acao =  "RET"    then
                if d_cts65m00.srvretmtvcod <> 999 then
                   next field srvretmtvcod
                else
                   next field srvretmtvdes
                end if
             else
                next field srvretmtvcod
             end if
          end if

   before field prslocflg
          display by name d_cts65m00.prslocflg attribute (reverse)

   after  field prslocflg
          let l_obter_qrv = true
          display by name d_cts65m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdlibflg
          end if

          if ((d_cts65m00.prslocflg  is null)  or
              (d_cts65m00.prslocflg  <> "S"    and
             d_cts65m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts65m00.prslocflg = "S"   then
             if w_cts65m00.atdprscod is null then
                call ctn24c01()
                  returning w_cts65m00.atdprscod,
                            w_cts65m00.srrcoddig,
                            ws.atdvclsgl ,
                            w_cts65m00.socvclcod

                if w_cts65m00.atdprscod  is null   then
                   error " Faltam dados para prestador no local!"
                   next field prslocflg
                end if
             end if

             let w_cts65m00.atdlibhor = w_cts65m00.atdhor
             let w_cts65m00.atdlibdat = w_cts65m00.atddat

             call cts40g03_data_hora_banco(2) returning m_data, m_hora

             let w_cts65m00.cnldat    = m_data
             let w_cts65m00.atdfnlhor = m_hora

             let w_cts65m00.c24opemat = g_issk.funmat
             let w_cts65m00.atdfnlflg = "S"
             let w_cts65m00.atdetpcod =  3
             let d_cts65m00.imdsrvflg = "S"
             display by name d_cts65m00.imdsrvflg
             let w_cts65m00.atdhorpvt = "00:00"
             exit input
          else
                initialize w_cts65m00.funmat   ,
                           w_cts65m00.cnldat   ,
                           w_cts65m00.atdfnlhor,
                           w_cts65m00.c24opemat,
                           w_cts65m00.atdfnlflg,
                           w_cts65m00.atdetpcod,
                           w_cts65m00.atdprscod,
                           w_cts65m00.c24nomctt  to null

             next field imdsrvflg
          end if

   before field imdsrvflg

          # Se a flag natagdflg = "S" nao abre agenda e
          # coloca o imdsrvflg como "S"

          whenever error continue
          open c_cts65m00_031 using d_cts65m00.socntzcod
          fetch c_cts65m00_031 into l_natagdflg
          whenever error stop
          close  c_cts65m00_031

          if l_natagdflg = "S" then

             let d_cts65m00.imdsrvflg = "S"
             display by name d_cts65m00.imdsrvflg

             call cts08g01_6l('C','S'
                            ,''
                            ,'SOLICITAR AO SEGURADO QUE AGUARDE'
                            ,'CONTATO DO PRESTADOR EM ATE 2H PARA'
                            ,'AGENDAMENTO DESTE SERVICO.'
                            ,'**SEGURADO ESTA CIENTE?**'
                            ,'')
             returning l_resultado

             if l_resultado = "S" then
                exit input
             else
                  #next field frmflg
             end if

          end if

          ## verifica se alterou endereco m_alt_end
          let m_imdsrvflg_ant = d_cts65m00.imdsrvflg
          call cts65m00_verifica_endereco() returning l_flag

          display by name d_cts65m00.imdsrvflg attribute (reverse)

          if g_documento.ciaempcod = 43    and
             ml_srvabrprsinfflg    = "S"   then
             let l_data = null
             let l_hora = null
             let d_cts65m00.imdsrvflg = "N"
          else
             if g_documento.ciaempcod = 43    and
               (ml_srvabrprsinfflg    = "N"   or
                ml_srvabrprsinfflg    is null or
                ml_srvabrprsinfflg    = " " ) then
                let l_data = null
                let l_hora = null
             else

                let l_data = aux_today
                let aux_hora = aux_hora[1,3], "00"
                let l_hora = aux_hora
             end if
          end if


          #  Retorno nao entra no acn imd pelo laudo

          if (l_obter_qrv = true or d_cts65m00.imdsrvflg = "S")
                and d_cts65m00.atdlibflg  = "S"
                and d_cts65m00.servicorg  is null then

                call cts65m00_imdsrvflg(a_cts65m00[1].lclltt,
                                        a_cts65m00[1].lcllgt,
                                        g_documento.acao,
                                        g_documento.atdsrvorg,
                                        d_cts65m00.socntzcod,
                                        d_cts65m00.espcod,
                                        a_cts65m00[1].cidnom,
                                        a_cts65m00[1].ufdcod,
                                        l_data,
                                        l_hora,
                                        a_cts65m00[1].c24lclpdrcod)
                     returning d_cts65m00.imdsrvflg,
                               m_veiculo_aciona,
                               l_cotadisponivel,
                               w_cts65m00.atddatprg,
                               w_cts65m00.atdhorprg,
                               l_mpacidcod

             let l_imdsrvflg = d_cts65m00.imdsrvflg
          else
             let w_cts65m00.atddatprg = l_data
             let w_cts65m00.atdhorprg = l_hora
          end if

    after field imdsrvflg
          display by name d_cts65m00.imdsrvflg

          if g_documento.ciaempcod = 43    and
             ml_srvabrprsinfflg    = "S"   then
             let d_cts65m00.imdsrvflg = "N"
          end if

          # PSI-2013-00440PR
          display by name d_cts65m00.imdsrvflg
          
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts65m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if
          
          if (m_cidnom != a_cts65m00[1].cidnom) or
             (m_ufdcod != a_cts65m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts65m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if
          
          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts65m00.imdsrvflg
          end if
          
          if m_cidnom is null then
             let m_cidnom = a_cts65m00[1].cidnom
          end if
          
          if m_ufdcod is null then
             let m_ufdcod = a_cts65m00[1].ufdcod
          end if
          
          # Envia a chave antiga no input quando alteracao. 
          # Se for a situacao INC, regulou, voltou para o laudo (CTRL+C) e regulou  
          # novamente manda a mesma pra ver se ainda e valida
          if g_documento.acao = "ALT"
             then
             let m_rsrchv = m_rsrchvant
          end if
          # PSI-2013-00440PR
          
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then

             if m_veiculo_aciona is not null then
                call cts40g06_desb_veic(m_veiculo_aciona,999997)
                     returning l_resultado
                let m_veiculo_aciona = null
             end if

             next field prslocflg
          end if

          if d_cts65m00.imdsrvflg <> "S"    and
             d_cts65m00.imdsrvflg <> "N"    then

             error " Servico imediato deve ser (S)im ou (N)ao!"

             if m_veiculo_aciona is not null then
                call cts40g06_desb_veic(m_veiculo_aciona,999997)
                     returning l_resultado
                let m_veiculo_aciona = null
             end if

             next field prslocflg
          end if

          if ml_srvabrprsinfflg = "S" then
             let l_pstcoddig = null
             call ctn24c00()
             returning l_pstcoddig

             if l_pstcoddig is null then
                error "Prestador deve ser selecionado ! " sleep 1
                next field imdsrvflg
             end if

             let w_cts65m00.atdprscod = l_pstcoddig

          end if

          if m_veiculo_aciona is null and
             l_imdsrvflg = "N" and
             d_cts65m00.imdsrvflg = "S" and  m_alt_end = "N"  and
             l_cotadisponivel = false then
             error "Nao e possivel registrar servico imediato" sleep 1
             let l_obter_qrv = false
             let d_cts65m00.imdsrvflg = "S"
             next field imdsrvflg
          end if

          ## Se obteve data/hora programada mas mudou a flag p/imediato
          ## manter como programado.
          if w_cts65m00.atddatprg is not null and
             w_cts65m00.atdhorprg is not null and
             l_imdsrvflg = "N" and
             d_cts65m00.imdsrvflg = "S" then
             let d_cts65m00.imdsrvflg = "N"
          end if

          if l_cotadisponivel = true and d_cts65m00.imdsrvflg = "S" then
             let w_cts65m00.atddatprg = null
             let w_cts65m00.atdhorprg = null
          end if

          if (g_documento.acao = "ALT" or g_documento.acao = "RAD") and
             d_cts65m00.imdsrvflg = "S" then
             let w_cts65m00.atddatprg = null
             let w_cts65m00.atdhorprg = null
          end if

          if (ws_acao = "RET") then
             let w_cts65m00.atdhorprg = null
          end if

          # INICIO PSI-2013-00440PR
          # Considerado que todas as regras de negocio sobre a questao da regulacao
          # sao tratadas do lado do AW, mantendo no laudo somente a chamada ao servico
          if m_agendaw = true
             then
             # obter a chave de regulacao no AW
             call cts02m08(w_cts65m00.atdfnlflg,
                           d_cts65m00.imdsrvflg,
                           m_altcidufd,
                           d_cts65m00.prslocflg,
                           w_cts65m00.atdhorpvt,
                           w_cts65m00.atddatprg,
                           w_cts65m00.atdhorprg,
                           w_cts65m00.atdpvtretflg,
                           m_rsrchv,
                           m_operacao,
                           "",
                           a_cts65m00[1].cidnom,
                           a_cts65m00[1].ufdcod,
                           "",   # codigo de assistencia, nao existe no Ct24h
                           "",   # codigo do veiculo, somente Auto
                           "",   # categoria tarifaria, somente Auto
                           d_cts65m00.imdsrvflg,
                           a_cts65m00[1].c24lclpdrcod,
                           a_cts65m00[1].lclltt,
                           a_cts65m00[1].lcllgt,
                           g_documento.ciaempcod,
                           g_documento.atdsrvorg,
                           d_cts65m00.asitipcod,
                           d_cts65m00.socntzcod, # natureza  
                           d_cts65m00.espcod)    # sub-natureza 
                 returning w_cts65m00.atdhorpvt,
                           w_cts65m00.atddatprg,
                           w_cts65m00.atdhorprg,
                           w_cts65m00.atdpvtretflg,
                           d_cts65m00.imdsrvflg,
                           m_rsrchv,
                           m_operacao,
                           m_altdathor
          
             display by name d_cts65m00.imdsrvflg
                 
             if int_flag
                then
                let int_flag = false
                next field imdsrvflg
             end if
             
          else  # regulação antiga
          
             while true
             
                call cts02m03(w_cts65m00.atdfnlflg, d_cts65m00.imdsrvflg,
                              w_cts65m00.atdhorpvt, w_cts65m00.atddatprg,
                              w_cts65m00.atdhorprg, w_cts65m00.atdpvtretflg)
                    returning w_cts65m00.atdhorpvt, l_data,
                              l_hora, w_cts65m00.atdpvtretflg
                
                if d_cts65m00.imdsrvflg = "S"  then
                    if w_cts65m00.atdhorpvt is null        then
                       error " Previsao de horas nao informada para",
                             " servico imediato!" sleep 1
                       let l_obter_qrv = false
   
                       if m_veiculo_aciona is not null then
                          call cts40g06_desb_veic(m_veiculo_aciona,999997)
                               returning l_resultado
                          let m_veiculo_aciona = null
                       end if
   
                       next field imdsrvflg
                    end if
                else
                    if m_veiculo_aciona is not null then
                       call cts40g06_desb_veic(m_veiculo_aciona,999997)
                            returning l_resultado
                       let m_veiculo_aciona = null
                    end if
   
                   if l_data is null or l_data  = " "   or
                      l_hora is null then
                      error " Faltam dados para servico programado!"
                      let l_obter_qrv = false
                      next field prslocflg
                   end if
   
                end if
   
                if w_cts65m00.atddatprg is null or
                   l_data <> w_cts65m00.atddatprg or
                   l_hora <> w_cts65m00.atdhorprg then
   
                   ## se a data/hora programa for <> da agenda
                   let w_horac = l_hora
                   let w_horac = w_horac[1,2]
                   let w_horaprg = w_horac
   
                   let w_horac = aux_hora
                   let w_horac = w_horac[1,2]
                   let w_horaatu = w_horac
   
                   #caso seja um servico programado e a hora informada
                   #seja menor do que 3 horas da hora atual - exibe agenda
   
                   ###if w_cts65m00.atddatprg  = aux_today and
                   if l_data  = aux_today and
                     (w_horaprg - w_horaatu) < 3 and
                      ml_srvabrprsinfflg = "N" then   ## PSS
   
                      if cpl_atdsrvnum        is not null and
                         cpl_atdsrvano        is not null and
                         d_cts65m00.retprsmsmflg = 'S'    then
                          error "Para servico programado o horario deve ser maior que 3 hrs da hora atual"
                      else
                          let w_cts65m00.atdhorprg = null
                          call ctc59m03 ( a_cts65m00[1].cidnom,
                                          a_cts65m00[1].ufdcod,
                                          g_documento.atdsrvorg,
                                          d_cts65m00.socntzcod,
                                          aux_today,
                                          aux_hora)
                               returning  w_cts65m00.atddatprg,
                                          w_cts65m00.atdhorprg
                      end if
                      continue while
                   else
                      # verificar se tem cota para data/hora informada
   
                      if cpl_atdsrvnum        is not null and
                         cpl_atdsrvano        is not null and
                         d_cts65m00.servicorg is not null and
                         d_cts65m00.retprsmsmflg = 'S'    then
   
                          if l_data is not null and
                             l_hora is not null then
   
                              # Verifica se viatura do atendimento original esta ocupada 2 horas antes
                              # ou 2 horas depois do agendamento do retorno
                              call cts65m00_verifica_retorno(g_documento.atdsrvnum
                                                            ,g_documento.atdsrvano
                                                            ,cpl_atdsrvnum
                                                            ,cpl_atdsrvano
                                                            ,l_data
                                                            ,l_hora
                                                            ,1)
                                  returning  l_contador
                                            ,lr_agd_p.min_atddatprg
                                            ,lr_agd_p.min_atdhorprg
                                            ,lr_agd_p.max_atddatprg
                                            ,lr_agd_p.max_atdhorprg
   
                              if l_contador > 0 then
                                 let mr_cts08g01.linha1 = 'Prestador do retorno esta com agenda'
                                 let mr_cts08g01.linha2 = 'ocupada para o horario '
                                 let mr_cts08g01.linha3 = lr_agd_p.min_atddatprg,' ', lr_agd_p.min_atdhorprg, ' a '
                                                         ,lr_agd_p.max_atddatprg,' ', lr_agd_p.max_atdhorprg
                                 let mr_cts08g01.linha4 = 'Favor escolher outro horario'
   
                                 call cts08g01('A', 'N'
                                               ,mr_cts08g01.linha1
                                               ,mr_cts08g01.linha2
                                               ,mr_cts08g01.linha3
                                               ,mr_cts08g01.linha4)
                                      returning m_confirma
                                 continue while
                              else
                                  let w_cts65m00.atddatprg = l_data
                                  let w_cts65m00.atdhorprg = l_hora
                              end if
                          end if
                      else
                          let l_tem_cota = false
                          call ctc59m03_quota_imediato
                               (l_mpacidcod, g_documento.atdsrvorg,
                                d_cts65m00.socntzcod, l_data, l_hora)
                                returning l_tem_cota
   
                          if l_tem_cota = false and m_tem_outros_srv = "N" then
                             call ctc59m03 (a_cts65m00[1].cidnom,
                                            a_cts65m00[1].ufdcod,
                                            g_documento.atdsrvorg,
                                            d_cts65m00.socntzcod,
                                            aux_today, aux_hora)
                                  returning w_cts65m00.atddatprg,
                                            w_cts65m00.atdhorprg
                             continue while
                          else
                             let w_cts65m00.atddatprg = l_data
                             let w_cts65m00.atdhorprg = l_hora
                          end if
                      end if
                   end if
   
                else
                   let w_cts65m00.atddatprg = l_data
                   let w_cts65m00.atdhorprg = l_hora
                end if
   
                exit while
   
             end while
          end if
          # FIM PSI-2013-00440PR

          call cts40g03_data_hora_banco(2)
               returning l_data_2, l_hora_2
          if (w_cts65m00.atddatprg is not null or w_cts65m00.atddatprg = " ") and
             (w_cts65m00.atdhorprg is not null or w_cts65m00.atdhorprg = " ") then
               if w_cts65m00.atddatprg < l_data_2   then
                  let w_cts65m00.atddatprg = null
                  let w_cts65m00.atdhorprg = null

                  next field atdlibflg
               else
                   if w_cts65m00.atddatprg = l_data_2 and
                      w_cts65m00.atdhorprg < l_hora_2  then
                      let w_cts65m00.atddatprg = null
                      let w_cts65m00.atdhorprg = null

                      next field atdlibflg
                   end if
               end if
          end if
          
          if w_cts65m00.atddatprg is not null and
             w_cts65m00.atdhorprg is not null and
             d_cts65m00.servicorg is not null and
             d_cts65m00.retprsmsmflg = 'S'    then

             # Verifica se viatura do atendimento original esta ocupada 2 horas antes
             # ou 2 horas depois do agendamento do retorno
             call cts65m00_verifica_retorno(g_documento.atdsrvnum
                                           ,g_documento.atdsrvano
                                           ,cpl_atdsrvnum
                                           ,cpl_atdsrvano
                                           ,w_cts65m00.atddatprg
                                           ,w_cts65m00.atdhorprg
                                           ,1)
                  returning  l_contador
                            ,lr_agd_p.min_atddatprg
                            ,lr_agd_p.min_atdhorprg
                            ,lr_agd_p.max_atddatprg
                            ,lr_agd_p.max_atdhorprg

              if l_contador > 0 then
                 let mr_cts08g01.linha1 = 'Prestador do retorno esta com agenda'
                 let mr_cts08g01.linha2 = 'ocupada para o horario '
                 let mr_cts08g01.linha3 = lr_agd_p.min_atddatprg,' ', lr_agd_p.min_atdhorprg, ' a '
                                         ,lr_agd_p.max_atddatprg,' ', lr_agd_p.max_atdhorprg
                 let mr_cts08g01.linha4 = 'Favor escolher outro horario'

                 call cts08g01('A', 'N'
                               ,mr_cts08g01.linha1
                               ,mr_cts08g01.linha2
                               ,mr_cts08g01.linha3
                               ,mr_cts08g01.linha4)
                      returning m_confirma
                 let w_cts65m00.atddatprg = null
                 let w_cts65m00.atdhorprg = null
                 next field atdlibflg
              end if
          end if
          let d_cts65m00.atdprinvlcod  = 2

          whenever error continue
          open c_cts65m00_015 using d_cts65m00.atdprinvlcod
          fetch c_cts65m00_015 into d_cts65m00.atdprinvldes
          whenever error stop
          close c_cts65m00_015


          display by name d_cts65m00.atdprinvlcod
          display by name d_cts65m00.atdprinvldes

          ########## TRATAR QUANDO TEM SERVICOS MULTIPLOS ##########

          if g_documento.acao = "ALT" or g_documento.acao = "RAD" then

             if m_obter_mult <> 1 then
                call cts29g00_consistir_multiplo(g_documento.atdsrvnum
                                                ,g_documento.atdsrvano)
                   returning l_resultado
                            ,l_mensagem
                            ,m_servico_original
                            ,m_ano_original

                if l_resultado = 3 then
                   error l_mensagem
                   next field imdsrvflg sleep 1
                end if
             end if

             if m_obter_mult = 1 then
                let m_servico_original = g_documento.atdsrvnum
                let m_ano_original = g_documento.atdsrvano
             end if

             ########## SE ESTIVER ALTERANDO SRV ORIGINAL/MULTIPLO, PERGUNTAR

             if (m_servico_original is not null) or
                (m_obter_mult = 1) then
                let m_confirma_alt_prog =
                    cts08g01('C' ,'S' ,'' ,'EXISTEM LAUDOS MULTIPLOS'
                            ,'CONFIRMA A ALTERACAO EM TODOS?' ,'')
             end if

          end if
          
          # PSI-2013-00440PR
          if m_agendaw = false
             then
             call cts65m00_cotas( m_veiculo_aciona,
                                  l_cotadisponivel,
                                  d_cts65m00.imdsrvflg,
                                  w_cts65m00.atddatprg,
                                  w_cts65m00.atdhorprg,
                                  g_documento.atdsrvnum,
                                  g_documento.atdsrvano,
                                  g_documento.ramcod,
                                  g_documento.succod,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig,
                                  g_documento.atdsrvorg,
                                  d_cts65m00.socntzcod)
          end if
          # PSI-2013-00440PR
          
          ########## SE ESTIVER ALTERANDO SRV ORIGINAL/MULTIPLO ####
          if m_confirma_alt_prog = 'S' then

             #Atualizar a programacao
             call cts65m00_alt_prog(g_documento.atdsrvnum
                                    ,g_documento.atdsrvano
                                    ,m_obter_mult
                                    ,w_cts65m00.atddatprg
                                    ,w_cts65m00.atdhorprg
                                    ,w_cts65m00.atdhorpvt
                                    ,m_servico_original
                                    ,m_ano_original)
                  returning l_resultado
                          ,l_mensagem

             # PSI-2013-00440PR
             if m_agendaw = false
                then
                if l_resultado = 1 then
                  #abater cota - buscando data/hora/natureza pelo servico
                  let ws.rglflg = ctc59m03_regulador(g_documento.atdsrvnum
                                                    ,g_documento.atdsrvano)
                end if
             end if
          end if

          #Remover o multiplo se nao alterar a programacao de todos
          if (g_documento.acao = "ALT" or g_documento.acao = "RAD") and
              m_confirma_alt_prog = 'N' then

             call cts29g00_remover_multiplo(g_documento.atdsrvnum
                                           ,g_documento.atdsrvano)
                  returning l_resultado ,l_mensagem

             if l_resultado = 3 then
                error l_mensagem sleep 1
                next field imdsrvflg
             end if

          end if

      on key (interrupt)

      # Se interrompeu laudo, mas está com prestador bloqueado
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then

         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
            = "S"  then
             if m_veiculo_aciona is not null then
                call cts40g06_desb_veic(m_veiculo_aciona,999997)
                     returning l_resultado
                let m_veiculo_aciona = null
            end if 
            
            if g_documento.c24astcod = "R67" or                              
               g_documento.c24astcod = "R68" or 
               g_documento.c24astcod = "RAR" then                            
               
               #------------------------------------------------------                                                              
               # Para Help Desk Deve Ficar Registrado Historico       
               #------------------------------------------------------
                   
               call cty45g00_abandono_rdk(6,m_data
                                           ,m_hora   
                                           ,w_cts65m00.atddat
                                           ,w_cts65m00.atdhor) 
            end if                                                           

            let int_flag = true
            exit input
         end if
      else

         if m_veiculo_aciona is not null then
            call cts40g06_desb_veic(m_veiculo_aciona,999997)
                 returning l_resultado
            let m_veiculo_aciona = null
         end if

         let g_documento.acao = "CON"

         exit input
      end if

   on key (F1)
      if w_cts65m00.lignum is not null then

         #-- Acessa a tabela datmligacao --#

         whenever error continue
         open c_cts65m00_032 using w_cts65m00.lignum
         fetch c_cts65m00_032 into g_documento.c24astcod
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "Erro ao acessar a tabela datmligacao, erro: "
                    ,sqlca.sqlcode
         end if
         close  c_cts65m00_032
      end if

      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F2)
      # Checa se existe tela de servico remocao ja aberta
      whenever error continue
      if ws_tela = "RET" then
         open window cts65m00s at 04,02 with form "cts65m00"
                              attribute(form line 1)
      else
         open window cts65m00r at 04,02 with form "cts65m00"
                              attribute(form line 1)
      end if
      if status = 0     then
         let erros_chk = "N"
         if ws_tela = "RET" then
            close window cts65m00s
         else
            close window cts65m00r
         end if
      else
         let erros_chk = "S"
      end if
      whenever error stop

      if erros_chk = "N"  then

         if ws_acao is not null and
            ws_acao =  "RET"    then

            # Servico (RET)orno
            whenever error continue
            open c_cts65m00_033 using g_documento.atdsrvnum,
                                      g_documento.atdsrvano
            fetch c_cts65m00_033 into ws.refatdsrvnum, ws.refatdsrvano
            whenever error stop
            close c_cts65m00_033

            if sqlca.sqlcode = notfound then
               let ws.refatdsrvnum = ws_refatdsrvnum_ini
               let ws.refatdsrvano = ws_refatdsrvano_ini
            end if

            let ws.acaoslv       = g_documento.acao
            let ws.acaorislv     = ws_acaorigem
            let g_documento.acao = "CON"
            let l_c24astcod_slv  = g_documento.c24astcod
            let ws.auxatdsrvnum  = g_documento.atdsrvnum
            let ws.auxatdsrvano  = g_documento.atdsrvano
            let dS_cts65m00.*    = d_cts65m00.*
            let wS_cts65m00.*    = w_cts65m00.*
            let aS_cts65m00.*    = a_cts65m00[1].*
            let cplS_atdsrvnum   = cpl_atdsrvnum
            let cplS_atdsrvano   = cpl_atdsrvano
            let cplS_atdsrvorg   = cpl_atdsrvorg

            let g_documento.atdsrvnum = ws.refatdsrvnum
            let g_documento.atdsrvano = ws.refatdsrvano

            call cts04g00('cts65m00') returning ws.retflg

            let g_documento.c24astcod = l_c24astcod_slv
            let g_documento.acao      = ws.acaoslv
            let ws_acaorigem          = ws.acaorislv
            let g_documento.atdsrvnum = ws.auxatdsrvnum
            let g_documento.atdsrvano = ws.auxatdsrvano
            let ws_acao               = "RET"
            let ws_tela               = "RET"
            let d_cts65m00.*          = dS_cts65m00.*
            let w_cts65m00.*          = wS_cts65m00.*
            let a_cts65m00[1].*       = aS_cts65m00.*
            let cpl_atdsrvnum         = cplS_atdsrvnum
            let cpl_atdsrvano         = cplS_atdsrvano
            let cpl_atdsrvorg         = cplS_atdsrvorg
         else
            call cts17m01 (g_documento.atdsrvnum, g_documento.atdsrvano)
                 returning ws.refatdsrvnum, ws.refatdsrvano

            if ws.refatdsrvnum is not null and
               ws.refatdsrvano is not null then

               let ws.acaoslv       = g_documento.acao
               let g_documento.acao = "CON"
               let ws.auxatdsrvnum  = g_documento.atdsrvnum
               let ws.auxatdsrvano  = g_documento.atdsrvano
               let dS_cts65m00.*    = d_cts65m00.*
               let wS_cts65m00.*    = w_cts65m00.*
               let aS_cts65m00.*    = a_cts65m00[1].*
               let cplS_atdsrvnum   = cpl_atdsrvnum
               let cplS_atdsrvano   = cpl_atdsrvano
               let cplS_atdsrvorg   = cpl_atdsrvorg

               let g_documento.atdsrvnum = ws.refatdsrvnum
               let g_documento.atdsrvano = ws.refatdsrvano

               call cts04g00('cts65m00') returning ws.retflg

               let g_documento.acao      = ws.acaoslv
               let g_documento.atdsrvnum = ws.auxatdsrvnum
               let g_documento.atdsrvano = ws.auxatdsrvano
               let ws_acao               = ws_acaorigem
               let ws_tela               = "SRV"
               let d_cts65m00.*          = dS_cts65m00.*
               let w_cts65m00.*          = wS_cts65m00.*
               let a_cts65m00[1].*       = aS_cts65m00.*
               let cpl_atdsrvnum         = cplS_atdsrvnum
               let cpl_atdsrvano         = cplS_atdsrvano
               let cpl_atdsrvorg         = cplS_atdsrvorg
            end if
         end if
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

   on key (f4)

      call cts29g00_obter_multiplo
           (1, g_documento.atdsrvnum, g_documento.atdsrvano)
            returning m_obter_mult, m_mensagem,
                      am_cts29g00[1].*,
                      am_cts29g00[2].*,
                      am_cts29g00[3].*,
                      am_cts29g00[4].*,
                      am_cts29g00[5].*,
                      am_cts29g00[6].*,
                      am_cts29g00[7].*,
                      am_cts29g00[8].*,
                      am_cts29g00[9].*,
                      am_cts29g00[10].*

      let m_acao = ws_acao
      let m_salva_tab = m_criou_tabela
      let m_salva_mlt = m_obter_mult

      if m_obter_mult = 1 then

         let l_atdsrvnum = g_documento.atdsrvnum
         let l_atdsrvano = g_documento.atdsrvano
         let l_tela = ws_tela

         if w_cts65m00.atdfnlflg ="S" then
            let ws_acao = "CON"
         end if

         call cts17m08_consultar_multiplos(l_atdsrvnum
                                          ,l_atdsrvano
                                          ,ws_acao)

         let ws_acao = m_acao
         let ws_tela = l_tela
         let ws_acaorigem = m_acao
         let g_documento.atdsrvnum = l_atdsrvnum
         let g_documento.atdsrvano = l_atdsrvano

         call consulta_cts65m00()

         display by name d_cts65m00.atdprinvlcod
         display by name d_cts65m00.atdprinvldes
         display by name d_cts65m00.asitipcod
         display by name d_cts65m00.nom
         display by name d_cts65m00.corsus
         display by name d_cts65m00.cornom
         display by name d_cts65m00.lclrsccod
         display by name d_cts65m00.lclrscflg
         display by name ws.lclcttnom
         display by name d_cts65m00.orrdat
         display by name d_cts65m00.socntzcod
         display by name d_cts65m00.espcod
         display by name d_cts65m00.espdes
         display by name d_cts65m00.c24pbmcod
         display by name d_cts65m00.atddfttxt
         display by name d_cts65m00.srvretmtvcod
         display by name d_cts65m00.srvretmtvdes
         display by name d_cts65m00.atdlibflg
         display by name d_cts65m00.prslocflg
         display by name d_cts65m00.imdsrvflg
      end if

      let g_documento.acao = m_acao
      let ws_acao = m_acao
      let m_obter_mult = m_salva_mlt
      call cts51g00_cria_temp()
           returning m_criou_tabela

   on key (F5)


      let g_monitor.horaini = current
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

      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         call cts10m02(hist_cts65m00.*) returning hist_cts65m00.*
      else
         call cts40g03_data_hora_banco(2) returning m_data, m_hora
         let aux_today = m_data
         let aux_hora = m_hora
         let g_documento.acao = null

         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat, aux_today, aux_hora)

         let g_documento.acao = ws_acaorigem

      end if

   on key (F7)
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         error " Impressao somente com preenchimento do servico!"
      else
         call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
      end if

   on key (F9)

      if g_documento.atdsrvnum is not null  and
         g_documento.atdsrvano is not null  then

         whenever error continue
         open c_cts65m00_034 using g_documento.atdsrvnum,
                                   g_documento.atdsrvano
         fetch c_cts65m00_034 into l_atdlibflg
         whenever error stop
         close c_cts65m00_034

         if l_atdlibflg = "N" then
            error " Servico nao liberado!"
         else

            call cta00m06_acionamento(g_issk.dptsgl)
            returning l_acesso

            if l_acesso = true then

               let l_atdsrvnum = g_documento.atdsrvnum
               let l_atdsrvano = g_documento.atdsrvano
               let l_tela2 = ws_tela

               call cts00m02(g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             0 )

               let g_documento.atdsrvnum = l_atdsrvnum
               let g_documento.atdsrvano = l_atdsrvano
               let ws_tela = l_tela2

               call consulta_cts65m00()

               display by name d_cts65m00.atdprinvlcod
               display by name d_cts65m00.atdprinvldes
               display by name d_cts65m00.asitipcod
               display by name d_cts65m00.nom
               display by name d_cts65m00.corsus
               display by name d_cts65m00.cornom
               display by name d_cts65m00.lclrsccod
               display by name d_cts65m00.lclrscflg
               display by name ws.lclcttnom
               display by name d_cts65m00.orrdat
               display by name d_cts65m00.socntzcod
               display by name d_cts65m00.espcod
               display by name d_cts65m00.espdes
               display by name d_cts65m00.c24pbmcod
               display by name d_cts65m00.atddfttxt
               display by name d_cts65m00.srvretmtvcod
               display by name d_cts65m00.srvretmtvdes
               display by name d_cts65m00.atdlibflg
               display by name d_cts65m00.prslocflg
               display by name d_cts65m00.imdsrvflg
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if
         end if
      end if

      on key (f10)
         if g_documento.atdsrvnum is not null then
            if g_documento.c24astcod = "R13" then
                call ctb83m00()
                    returning m_retctb83m00
            else
               error "Esse assunto nao possui tipo de pagamento"
            end if
         else
            error "Tipo de pagamento somente com servico aberto"
         end if

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts65m00.* to null
 end if

return hist_cts65m00.*

end function  ###  input_cts65m00

#-------------------------------------------------------------------------------
 function cts65m00_copia()
#-------------------------------------------------------------------------------
 define ws            record
    endlgdtip         like rlaklocal.endlgdtip     ,
    endlgdnom         like rlaklocal.endlgdnom     ,
    endnum            like rlaklocal.endnum        ,
    endcmp            like rlaklocal.endcmp        ,
    endbrr            like rlaklocal.endbrr        ,
    endcid            like rlaklocal.endcid        ,
    ufdcod            like rlaklocal.ufdcod        ,
    endcep            like rlaklocal.endcep        ,
    endcepcmp         like rlaklocal.endcepcmp     ,
    atdorgsrvnum      like datmsrvre.atdorgsrvnum,
    atdorgsrvano      like datmsrvre.atdorgsrvano,
    confirma          char (01),
    c24solnom_cp      like datmligacao.c24solnom   ,
    ligcvntip_cp      like datmligacao.ligcvntip   ,
    nom_cp            like datmservico.nom         ,
    corsus_cp         like datmservico.corsus      ,
    cornom_cp         like datmservico.cornom      ,
    cvnnom_cp         char (20)                    ,
    cogidosql         integer     ,
    atdsrvseq         like datmsrvacp.atdsrvseq  ,
    socvclcod         like datmsrvacp.socvclcod    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    pstcoddig         like datmservico.atdprscod  ,
    atdvclsgl         like datmsrvacp.atdvclsgl
 end record

 define l_espsit   like dbskesp.espsit
 define l_resultado smallint
 define l_mensagem  char(60)

 let l_resultado = null
 let l_mensagem  = null

 #------------------------------------------------
 # Acessa servico
 #------------------------------------------------
  initialize  ws.*  to  null

  whenever error continue
  open c_cts65m00_035 using g_documento.atdsrvnum,
                            g_documento.atdsrvano
  fetch c_cts65m00_035 into d_cts65m00.atddfttxt,
                            d_cts65m00.asitipcod,
                            ws.nom_cp,
                            ws.corsus_cp,
                            ws.cornom_cp

  whenever error stop

  if d_cts65m00.nom is null then
     let d_cts65m00.nom  =  ws.nom_cp
  end if

  if d_cts65m00.corsus is null then
     let d_cts65m00.corsus  =  ws.corsus_cp
     let d_cts65m00.cornom  =  ws.cornom_cp
  end if

 #------------------------------------------------
 # Acessa ligacao
 #------------------------------------------------
  whenever error continue
  open c_cts65m00_036 using g_documento.atdsrvnum,
                            g_documento.atdsrvano


  foreach c_cts65m00_036 into ws.c24solnom_cp, ws.ligcvntip_cp
     exit foreach
  end foreach
  whenever error stop
  close c_cts65m00_036

  if g_documento.ligcvntip is null and
     ws.ligcvntip_cp is not null   then

     let g_documento.ligcvntip = ws.ligcvntip_cp
     let w_cts65m00.ligcvntip  = g_documento.ligcvntip

     end if

 #------------------------------------------------
 # Acessa dados do RE
 #------------------------------------------------


  whenever error continue
  open c_cts65m00_037 using cpl_atdsrvnum,
                            cpl_atdsrvano
  fetch c_cts65m00_037 into d_cts65m00.lclrsccod
                            ,ws.atdorgsrvnum
                            ,ws.atdorgsrvano
                            ,d_cts65m00.socntzcod
                            ,d_cts65m00.orrdat
                            ,d_cts65m00.espcod
  whenever error stop
  close c_cts65m00_037

  if ws.atdorgsrvnum is null  or
     ws_acaorigem    = "RET"  then
     let ws.atdorgsrvnum = cpl_atdsrvnum
     let ws.atdorgsrvano = cpl_atdsrvano
  end if

  let cpl_atdsrvnum = ws.atdorgsrvnum
  let cpl_atdsrvano = ws.atdorgsrvano

    whenever error continue
    open c_cts65m00_038 using ws.atdorgsrvnum,
                              ws.atdorgsrvano
    fetch c_cts65m00_038 into ws.atdsrvseq

    let w_cts65m00.atdprscod = ws.pstcoddig
    let w_cts65m00.srrcoddig = ws.srrcoddig
    let w_cts65m00.socvclcod = ws.socvclcod

  call ctx04g00_local_gps(cpl_atdsrvnum, cpl_atdsrvano, 1)
                returning a_cts65m00[1].lclidttxt   ,
                          a_cts65m00[1].lgdtip      ,
                          a_cts65m00[1].lgdnom      ,
                          a_cts65m00[1].lgdnum      ,
                          a_cts65m00[1].lclbrrnom   ,
                          a_cts65m00[1].brrnom      ,
                          a_cts65m00[1].cidnom      ,
                          a_cts65m00[1].ufdcod      ,
                          a_cts65m00[1].lclrefptotxt,
                          a_cts65m00[1].endzon      ,
                          a_cts65m00[1].lgdcep      ,
                          a_cts65m00[1].lgdcepcmp   ,
                          a_cts65m00[1].lclltt      ,
                          a_cts65m00[1].lcllgt      ,
                          a_cts65m00[1].dddcod      ,
                          a_cts65m00[1].lcltelnum   ,
                          a_cts65m00[1].lclcttnom   ,
                          a_cts65m00[1].c24lclpdrcod,
                          a_cts65m00[1].celteldddcod,
                          a_cts65m00[1].celtelnum,
                          a_cts65m00[1].endcmp,
                          ws.cogidosql, a_cts65m00[1].emeviacod

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts65m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts65m00[1].brrnom,
                                a_cts65m00[1].lclbrrnom)
      returning a_cts65m00[1].lclbrrnom

  if ws.cogidosql <> 0  then
     error " Erro (", ws.cogidosql using "<<<<<&", "). AVISE A INFORMATICA!"
     prompt "" for char ws.confirma
  end if


  whenever error continue
  open c_cts65m00_041 using g_documento.atdsrvano,
                            g_documento.atdsrvnum
  fetch c_cts65m00_041 into a_cts65m00[1].ofnnumdig
  whenever error stop

  let a_cts65m00[1].lgdtxt = a_cts65m00[1].lgdtip clipped, " ",
                             a_cts65m00[1].lgdnom clipped, " ",
                             a_cts65m00[1].lgdnum using "<<<<#"


  let d_cts65m00.lclrscflg = "N"


  initialize d_cts65m00.servicorg  to null
  if cpl_atdsrvnum is not null then
     let cpl_atdsrvorg         = 09
     let d_cts65m00.servicorg  = cpl_atdsrvorg using "&&",
                                 "/", cpl_atdsrvnum using "&&&&&&&",
                                 "-", cpl_atdsrvano using "&&"
  end if

  #------------------------------------------
  # Acessa problema servico
  #------------------------------------------

  whenever error continue
  open c_cts65m00_042 using g_documento.atdsrvnum,
                            g_documento.atdsrvano
  fetch c_cts65m00_042 into d_cts65m00.c24pbmcod
  whenever error stop

  #------------------------------------------
  # Acessa descricao natureza
  #------------------------------------------
  let d_cts65m00.socntzdes = "*** NAO CADASTRADA ***"

  whenever error continue
  open c_cts65m00_043 using d_cts65m00.socntzcod
  fetch c_cts65m00_043 into d_cts65m00.socntzdes
  whenever error stop


  #------------------------------------------
  # Acessa descricao especialidade
  #------------------------------------------
  let d_cts65m00.espdes = null
  if d_cts65m00.espcod is not null then

      let d_cts65m00.espdes = "*** NAO CADASTRADA ***"
      #como nao importa a situacao da especialidade (ativa ou nao) vou buscar
      # apenas a descricao, entao vou passar null
      let l_espsit = null

      call cts31g00_descricao_esp(d_cts65m00.espcod, l_espsit)
           returning d_cts65m00.espdes

      if d_cts65m00.espdes is null then
         error "Descricao nao encontrada para especialidade."
      end if

  end if

  #------------------------------------------
  # Acessa descricao tipo servico
  #------------------------------------------
  let d_cts65m00.asitipabvdes = "NAO PREV"

  whenever error continue
  open c_cts65m00_044 using d_cts65m00.asitipcod
  fetch c_cts65m00_044 into d_cts65m00.asitipabvdes
  whenever error stop
 
   # PSI 244589 - Inclusão de Sub-Bairro - Burini
   let m_subbairro[1].lclbrrnom = a_cts65m00[1].lclbrrnom

   call cts06g10_monta_brr_subbrr(a_cts65m00[1].brrnom,
                                  a_cts65m00[1].lclbrrnom)
        returning a_cts65m00[1].lclbrrnom

   display by name d_cts65m00.srvnum thru d_cts65m00.atdtxt,
                   a_cts65m00[1].lgdtxt,
                   a_cts65m00[1].lclbrrnom,
                   a_cts65m00[1].endzon,
                   a_cts65m00[1].cidnom,
                   a_cts65m00[1].ufdcod,
                   a_cts65m00[1].lclrefptotxt,
                   a_cts65m00[1].lclcttnom,
                   a_cts65m00[1].dddcod,
                   a_cts65m00[1].lcltelnum,
                   a_cts65m00[1].celteldddcod,
                   a_cts65m00[1].celtelnum,
                   a_cts65m00[1].endcmp

  let flgcpl = 1

end function  ###  cts65m00_copia

#=========================================================
 function cts65m00_grava_dados(lr_param)
#=========================================================

 define lr_param      record
     socntzcod        like datmsrvre.socntzcod
    ,espcod           like datmsrvre.espcod
    ,c24pbmcod        like datkpbm.c24pbmcod
    ,atddfttxt        like datmservico.atddfttxt
    ,atdsrvnum        like datmservico.atdsrvnum
    ,atdsrvano        like datmservico.atdsrvano
 end record

 define lr_ret        record
    retorno           smallint
   ,mensagem          char(100)
   ,atdsrvnum         like datmservico.atdsrvnum
   ,atdsrvano         like datmservico.atdsrvano
   ,lignum            like datmligacao.lignum
 end record

 define l_lignum      like datmligacao.lignum
      , l_sqlcode     smallint
      , l_msg         char(100)
      , l_prompt      char(01)
      , l_atdsrvnum   like datmservico.atdsrvnum
      , l_atdsrvano   like datmservico.atdsrvano
      , l_ciaempcod_slv like datmligacao.ciaempcod
      , l_tipo_nro    smallint

 define l_confirma     char(01)
      , l_mensagem     char (100)
      , l_ret          smallint
      , l_conta_corrente smallint



 initialize lr_ret.* to null
 let l_confirma = null
 let l_conta_corrente = false
 let l_tipo_nro       = null

 call cts40g03_data_hora_banco(2) returning m_data, m_hora

 let w_cts65m00.atddat  = m_data
 let w_cts65m00.atdhor  = m_hora
 let w_cts65m00.atdlibhor = m_hora
 let w_cts65m00.atdlibdat = m_data
 let w_cts65m00.atdfnlhor    = m_hora

 begin work

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------

 if g_documento.lclocodesres = "S" then
    let w_cts65m00.atdrsdflg = "S"
 else
    let w_cts65m00.atdrsdflg = "N"
 end if
 
 #--------------------------------------------------------------------
 # Se Assunto R67 ou R68 Nao Gera Numero Ligacao                                                           
 #--------------------------------------------------------------------
 
 if g_documento.c24astcod = "R67" or                                           
    g_documento.c24astcod = "R68" then                                        
    let l_tipo_nro = 0 #---> So Nro Servico                                    
 else                                                                          
    let l_tipo_nro = 2 #---> Nro Servico e Nro Ligacao                         
 end if                                                                        
 

 # Busca numeracao ligacao / servico
   call cts10g03_numeracao(l_tipo_nro,"9")
        returning l_lignum, l_atdsrvnum,
                  l_atdsrvano, l_sqlcode,
                  l_msg

   if l_sqlcode = 0  then
      commit work
   else
      let l_msg = "cts65m00 - ",l_msg
      call ctx13g00(l_sqlcode,"DATKGERAL",l_msg)
      rollback work
      prompt "" for l_prompt
      let lr_ret.retorno = l_sqlcode
      let lr_ret.mensagem = l_msg
      return lr_ret.*
   end if

   let w_cts65m00.atdsrvnum  = l_atdsrvnum
   let w_cts65m00.atdsrvano  = l_atdsrvano
   
   
   if g_documento.c24astcod = "R67" or                    
      g_documento.c24astcod = "R68" then                  
                                                          
      let l_lignum = g_documento.lignum                   
                                                          
      begin work
      
      #------------------------------------------------------------
      # Nao Gera Ligacao Pois Pega a Ligacao ja Aberta no RDK
      #------------------------------------------------------------
      
      call cty45g00_registra_ligacao_rdk(g_documento.lignum  ,                                         
                                         w_cts65m00.atdsrvnum,                    
                                         w_cts65m00.atdsrvano)
      returning lr_ret.retorno,
                lr_ret.mensagem 
      
      if lr_ret.retorno <> 0 then      	
      	 rollback work                  
      	 prompt "" for ms.prompt_key    
      	 return lr_ret.*                
      end if	                                   
                                         
                                         
   else
   
      let g_documento.lignum  = l_lignum
      
      #---------------------------------
      # Grava dados da ligacao / servico
      #---------------------------------
      
      # Verifica se deve mudar a empresa do serviço aberto no cartao
      let l_ciaempcod_slv = g_documento.ciaempcod
      
         begin work
      
      call cts10g00_ligacao ( g_documento.lignum      ,
                              w_cts65m00.atddat       ,
                              w_cts65m00.atdhor       ,
                              g_documento.c24soltipcod,
                              g_documento.solnom      ,
                              g_documento.c24astcod   ,
                              w_cts65m00.funmat       ,
                              g_documento.ligcvntip   ,
                              g_c24paxnum             ,
                              l_atdsrvnum      ,
                              l_atdsrvano      ,
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
                              ms.caddat,  ms.cadhor   ,
                              ms.cademp,  ms.cadmat   )
           returning ms.tabname, ms.codigosql
      
      if ms.codigosql <> 0 then
         let lr_ret.mensagem = " Erro (",ms.codigosql,") na gravacao da",
                               " tabela ",ms.tabname clipped,". AVISE A INFORMATICA!"
         let lr_ret.retorno = ms.codigosql
         error lr_ret.mensagem sleep 1
         rollback work
         prompt "" for ms.prompt_key
         return lr_ret.*
     end if
   
   end if
   
   call cts10g02_grava_servico( w_cts65m00.atdsrvnum,
                                w_cts65m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                d_cts65m00.c24solnom,     # c24solnom
                                ""                  ,     # vclcorcod
                                w_cts65m00.funmat   ,
                                d_cts65m00.atdlibflg,
                                w_cts65m00.atdlibhor,
                                w_cts65m00.atdlibdat,
                                w_cts65m00.atddat   ,
                                w_cts65m00.atdhor   ,
                                ""                  ,     # atdlclflg
                                w_cts65m00.atdhorpvt,
                                w_cts65m00.atddatprg,
                                w_cts65m00.atdhorprg,
                                "9"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts65m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts65m00.atdfnlflg,
                                w_cts65m00.atdfnlhor,
                                w_cts65m00.atdrsdflg,
                                lr_param.atddfttxt,
                                ""                  ,     # atddoctxt
                                w_cts65m00.c24opemat,
                                d_cts65m00.nom      ,
                                ""                  ,     # vcldes
                                ""                  ,     # vclanomdl
                                ""                  ,     # vcllicnum
                                d_cts65m00.corsus   ,
                                d_cts65m00.cornom   ,
                                w_cts65m00.cnldat   ,
                                ""                  ,     # pgtdat
                                w_cts65m00.c24nomctt,
                                w_cts65m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                d_cts65m00.asitipcod,
                                ""                  ,     # socvclcod
                                ""                  ,     # vclcoddig
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts65m00.atdprinvlcod,
                                g_documento.atdsrvorg   ) # ATDSRVORG
        returning ms.tabname, ms.codigosql

   if ms.codigosql  <>  0 then
      let lr_ret.mensagem = " Erro (",ms.codigosql,") na gravacao da ",
                            "tabela ",ms.tabname clipped,". AVISE A INFORMATICA"
      let lr_ret.retorno = ms.codigosql
      error lr_ret.mensagem sleep 1
      rollback work
      prompt "" for ms.prompt_key
      return lr_ret.*
   end if

   if d_cts65m00.prslocflg = "S" then
      whenever error continue
      execute p_cts65m00_045 using d_cts65m00.prslocflg
                               , w_cts65m00.socvclcod
                               , w_cts65m00.srrcoddig
                               , w_cts65m00.atdsrvnum
                               , w_cts65m00.atdsrvano
      whenever error stop
      if sqlca.sqlcode  <>  0 then
         let lr_ret.mensagem = " Erro (",sqlca.sqlcode,") na gravacao da",
                               " tabela datmservico. AVISE A INFORMATICA!"
         let lr_ret.retorno = sqlca.sqlcode
         error lr_ret.mensagem sleep 1
         rollback work
         prompt "" for ms.prompt_key
         return lr_ret.*
      end if
    end if

 #---------------------------
 # Grava problemas do servico
 #---------------------------
    call ctx09g02_inclui(w_cts65m00.atdsrvnum,
                         w_cts65m00.atdsrvano,
                         1               , # Org. informacao 1-Segurado 2-Pst
                         lr_param.c24pbmcod,
                         lr_param.atddfttxt,
                         ""                  ) # Codigo prestador
         returning ms.codigosql, ms.tabname

   if ms.codigosql <> 0 then
      let lr_ret.mensagem = " Erro (",sqlca.sqlcode,") na gravacao de",
                            " problemas do servico. AVISE A INFORMATICA!"
      let lr_ret.retorno = ms.codigosql
      error lr_ret.mensagem sleep 1
      rollback work
      prompt "" for ms.prompt_key
      return lr_ret.*
   end if

 #---------------------------
 # Grava locais de ocorrencia
 #---------------------------
   if a_cts65m00[1].operacao is null then
      let a_cts65m00[1].operacao = "I"
   end if

   let a_cts65m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

   let ms.codigosql = cts06g07_local( a_cts65m00[1].operacao    ,
                                    w_cts65m00.atdsrvnum      ,
                                    w_cts65m00.atdsrvano      ,
                                    1                         ,
                                    a_cts65m00[1].lclidttxt   ,
                                    a_cts65m00[1].lgdtip      ,
                                    a_cts65m00[1].lgdnom      ,
                                    a_cts65m00[1].lgdnum      ,
                                    a_cts65m00[1].lclbrrnom   ,
                                    a_cts65m00[1].brrnom      ,
                                    a_cts65m00[1].cidnom      ,
                                    a_cts65m00[1].ufdcod      ,
                                    a_cts65m00[1].lclrefptotxt,
                                    a_cts65m00[1].endzon      ,
                                    a_cts65m00[1].lgdcep      ,
                                    a_cts65m00[1].lgdcepcmp   ,
                                    a_cts65m00[1].lclltt      ,
                                    a_cts65m00[1].lcllgt      ,
                                    a_cts65m00[1].dddcod      ,
                                    a_cts65m00[1].lcltelnum   ,
                                    a_cts65m00[1].lclcttnom   ,
                                    a_cts65m00[1].c24lclpdrcod,
                                    a_cts65m00[1].ofnnumdig,
                                    a_cts65m00[1].emeviacod   ,
                                    a_cts65m00[1].celteldddcod,
                                    a_cts65m00[1].celtelnum   ,
                                    a_cts65m00[1].endcmp )

   if ms.codigosql is null or
      ms.codigosql <> 0 then
      let lr_ret.mensagem = " Erro (",ms.codigosql,") na gravacao do",
                            " local de ocorrencia. AVISE A INFORMATICA!"
      let lr_ret.retorno = ms.codigosql
      error lr_ret.mensagem sleep 1
      rollback work
      prompt "" for ms.prompt_key
      return lr_ret.*
   end if


 #-------------------------------
 # Grava etapas do acompanhamento
 #-------------------------------
   open  c_cts65m00_046 using l_atdsrvnum, l_atdsrvano
   whenever error continue
   fetch c_cts65m00_046 into ms.atdsrvseq
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_ret.mensagem = " Erro (",sqlca.sqlcode,") na selecao da",
                            " tabela datmsrvacp. AVISE A INFORMATICA!"
      let lr_ret.retorno = sqlca.sqlcode
      error lr_ret.mensagem sleep 1
      rollback work
      prompt "" for ms.prompt_key
      return lr_ret.*
   end if

   if ms.atdsrvseq is null then
      let ms.atdsrvseq = 0
   end if

   if w_cts65m00.atdetpcod is null then
      if d_cts65m00.atdlibflg = "S" then
         let w_cts65m00.atdetpcod = 1
         let ms.etpfunmat = w_cts65m00.funmat
         let ms.atdetpdat = w_cts65m00.atdlibdat
         let ms.atdetphor = w_cts65m00.atdlibhor
      else
         let w_cts65m00.atdetpcod = 2
         let ms.etpfunmat = w_cts65m00.funmat
         let ms.atdetpdat = w_cts65m00.atddat
         let ms.atdetphor = w_cts65m00.atdhor
      end if
   else

      call cts10g04_insere_etapa(w_cts65m00.atdsrvnum,
                                 w_cts65m00.atdsrvano,
                                 1,
                                 "",
                                 "",
                                 "",
                                 "")
           returning ms.codigosql

      whenever error stop
      if ms.codigosql <> 0 then
         let lr_ret.mensagem = " Erro (", ms.codigosql, ") na gravacao da",
                               " etapa de acompanhamento (1)"
         let lr_ret.retorno = ms.codigosql
         error lr_ret.mensagem sleep 1
         rollback work
         prompt "" for ms.prompt_key
         return lr_ret.*
      end if
      let ms.atdetpdat = w_cts65m00.cnldat
      let ms.atdetphor = w_cts65m00.atdfnlhor
      let ms.etpfunmat = w_cts65m00.c24opemat
  end if

  call cts10g04_insere_etapa(l_atdsrvnum,
                             l_atdsrvano,
                             w_cts65m00.atdetpcod,
                             w_cts65m00.atdprscod,
                             w_cts65m00.c24nomctt,
                             w_cts65m00.socvclcod,
                             w_cts65m00.srrcoddig)
       returning ms.codigosql

  if ms.codigosql <>  0 then
     let lr_ret.mensagem = " Erro (", ms.codigosql, ") na gravacao da",
                          " etapa de acompanhamento (2). AVISE A INFORMATICA!"
     let lr_ret.retorno = ms.codigosql
     error lr_ret.mensagem sleep 1
     rollback work
     prompt "" for ms.prompt_key
     return lr_ret.*
  end if

  if d_cts65m00.prslocflg = "N" then
     let w_cts65m00.atdetpcod = null
  end if

 #-----------------
 # Grava servico RE
 #-----------------
  if ws_acao is null or ws_acao = " " or ws_acao <> "RET" then
     let cpl_atdsrvnum = null
     let cpl_atdsrvano = null
  end if

  if lr_param.socntzcod < 0 then
     let lr_ret.mensagem = " Erro no codigo da natureza ( ",
                             lr_param.socntzcod , " )",
                           " AVISE A INFORMATICA!"
     let lr_ret.retorno = sqlca.sqlcode
     error lr_ret.mensagem sleep 1
     rollback work
     prompt "" for ms.prompt_key
     return lr_ret.*
  end if

  whenever error continue
  execute p_cts65m00_047 using l_atdsrvnum             , l_atdsrvano,
                             d_cts65m00.lclrsccod    , d_cts65m00.orrdat,
                             lr_param.socntzcod      , cpl_atdsrvnum,
                             cpl_atdsrvano           , d_cts65m00.srvretmtvcod,
                             d_cts65m00.retprsmsmflg , lr_param.espcod,
                             g_documento.lclnumseq   , g_documento.rmerscseq
  whenever error stop
  if sqlca.sqlcode <>  0 then
     let lr_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                           " servico RE. AVISE A INFORMATICA!"
     let lr_ret.retorno = sqlca.sqlcode
     error lr_ret.mensagem sleep 1
     rollback work
     prompt "" for ms.prompt_key
     return lr_ret.*
  end if

  if d_cts65m00.srvretmtvcod is not null and
     d_cts65m00.srvretmtvcod  =  999 then
     whenever error continue

     execute p_cts65m00_048 using l_atdsrvnum, l_atdsrvano,
                                d_cts65m00.srvretmtvdes, m_data,
                                g_issk.empcod,
                                g_issk.funmat, g_issk.usrtip
     whenever error stop
     if sqlca.sqlcode <>  0 then
        let lr_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                              " Mto.Retorno RE. AVISE A INFORMATICA!"
        let lr_ret.retorno = sqlca.sqlcode
        error lr_ret.mensagem sleep 1
        rollback work
        prompt "" for ms.prompt_key
        return lr_ret.*
     end if
  end if

 #---------------------------------------
 # Grava relacionamento servico / apolice
 #---------------------------------------
   if g_documento.succod is not null and
      g_documento.ramcod is not null and
      g_documento.aplnumdig is not null and
      g_documento.crtsaunum is null     then # psi 202720-saude
      if g_documento.edsnumref is null then
         let g_documento.edsnumref = 0
      end if
      whenever error continue
      execute p_cts65m00_049 using l_atdsrvnum, l_atdsrvano,
                                 g_documento.succod, g_documento.ramcod,
                                 g_documento.aplnumdig, g_documento.itmnumdig,
                                 g_documento.edsnumref
      whenever error stop
      if sqlca.sqlcode <>  0 then
         let lr_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                               " relacionamento servico x apolice"
         let lr_ret.retorno = sqlca.sqlcode
         error lr_ret.mensagem sleep 1
         rollback work
         prompt "" for ms.prompt_key
         return lr_ret.*
      end if
   end if

  #-------------------------------
  # Aciona Servico automaticamente
  #-------------------------------

  if (ws_acao = "RET" and d_cts65m00.retprsmsmflg = 'N') or
     m_veiculo_aciona is not null then
     # e retorno? and deseja outro prestador? OU tem veiculo pronto
     # para servico imediato
     # servico nao sera acionado automaticamente
  else
     #chamar funcao que verifica se acionamento pode ser feito
     # verifica se servico para cidade e internet ou GPS e se esta ativo
     #retorna true para acionamento e false para nao acionamento

     if cts34g00_acion_auto (g_documento.atdsrvorg,
                             a_cts65m00[1].cidnom,
                             a_cts65m00[1].ufdcod) then

        #funcao cts34g00_acion_auto verificou que parametrizacao para origem
        # do servico esta OK
        #chamar funcao para validar regras gerais se um servico sera acionado
        # automaticamente ou nao e atualizar datmservico


        if not cts40g12_regras_aciona_auto (
                             g_documento.atdsrvorg,
                             g_documento.c24astcod,
                             "",
                             a_cts65m00[1].lclltt,
                             a_cts65m00[1].lcllgt,
                             d_cts65m00.prslocflg,
                             "N",#d_cts65m00.frmflg,
                             w_cts65m00.atdsrvnum,
                             w_cts65m00.atdsrvano,
                             ws_acao,
                             "",
                             "") then

           #servico nao pode ser acionado automaticamente
        end if
     end if
  end if

  #Gravar relacionamento do servico principal com os servicos multiplos
  if lr_param.atdsrvnum is not null then
     whenever error continue

     execute p_cts65m00_051 using lr_param.atdsrvnum, lr_param.atdsrvano
                              , l_atdsrvnum,  l_atdsrvano
     whenever error stop

     if sqlca.sqlcode <>  0 then
        let lr_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao da",
                              " tabela datratdmltsrv. AVISE A INFORMATICA!"
        let lr_ret.retorno = sqlca.sqlcode
        error lr_ret.mensagem sleep 1
        rollback work
        prompt "" for ms.prompt_key
        return lr_ret.*
     end if
  end if

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(w_cts65m00.atdsrvnum,
                             w_cts65m00.atdsrvano)

 #---------------------------------------------------------------
 # Insere inf. de pagamentos na tabela dbscadtippgt
 #---------------------------------------------------------------
    if g_documento.c24astcod = "R13" then

         let g_cc.anosrv = w_cts65m00.atdsrvano
         let g_cc.nrosrv = w_cts65m00.atdsrvnum

         whenever error continue
         execute p_cts65m00_050 using g_cc.anosrv,
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
                                      g_cc.pgtempcod
        whenever error stop

       if sqlca.sqlcode <> 0 then
          error "Erro ao inserir na tabela dbscadtippgt, AVISE A INFORMATICA"
          call errorlog("Erro ao inserir na tabela dbscadtippgt, AVISE A INFORMATICA" )
       end if

    end if

 # Verifica se deve retornar a empresa do serviço aberto no cartao
 if g_documento.ciaempcod <> l_ciaempcod_slv then
    let g_documento.ciaempcod = l_ciaempcod_slv
 end if
 
 
 #--------------------------------------------------------          
 # Replica Historico da Ligacao para o Historico Servico            
 #--------------------------------------------------------          
 call cty45g00_replica_historico_telefonico(g_documento.lignum         
                                           ,w_cts65m00.atdsrvnum    
                                           ,w_cts65m00.atdsrvano)   
 returning lr_ret.retorno  ,                                        
           lr_ret.mensagem
           
 
  if lr_ret.retorno <>  1 then                                                   
     let lr_ret.mensagem = " Erro (", lr_ret.retorno, ") na replicacao do",      
              " historico da ligacao p/ servico. AVISE A INFORMATICA!"          
                                                                                                                       
     error lr_ret.mensagem sleep 1                                                                                                                 
     prompt "" for ms.prompt_key                                                          
     return lr_ret.*                                                                      
  end if                                                                                  
           

 #---------------------------
 # Grava HISTORICO do servico
 #---------------------------

   let ms.histerr = cts10g02_historico( l_atdsrvnum,
                                        l_atdsrvano,
                                        w_cts65m00.atddat,
                                        w_cts65m00.atdhor,
                                        w_cts65m00.funmat,
                                        mr_hist.*   )

  let lr_ret.retorno = 1
  let lr_ret.mensagem = ' '
  let lr_ret.atdsrvnum = l_atdsrvnum
  let lr_ret.atdsrvano = l_atdsrvano
  let lr_ret.lignum = l_lignum

 return lr_ret.*

end function

#-----------------------------------
function cts65m00_alt_prog(lr_input)
#-----------------------------------
 define lr_input record
        atdsrvnum        like datmservico.atdsrvnum
       ,atdsrvano        like datmservico.atdsrvano
       ,obter_mult       smallint
       ,atddatprg        like datmservico.atddatprg
       ,atdhorprg        like datmservico.atdhorprg
       ,atdhorpvt        like datmservico.atdhorpvt
       ,servico_original like datmservico.atdsrvnum
       ,ano_original     like datmservico.atdsrvano
 end record

 define lr_output record
        resultado      smallint
       ,mensagem       char(100)
 end record

 define l_i            smallint

   initialize lr_output.* to null
   let lr_output.resultado = 1

   if lr_input.obter_mult = 1 then
      for l_i = 1 to 10
         if am_cts29g00[l_i].atdmltsrvnum is not null then
            whenever error continue
            execute p_cts65m00_052 using lr_input.atddatprg
                                      ,lr_input.atdhorprg
                                      ,lr_input.atdhorpvt
                                      ,am_cts29g00[l_i].atdmltsrvnum
                                      ,am_cts29g00[l_i].atdmltsrvano
            whenever error stop
            if sqlca.sqlcode <> 0 then
               let lr_output.resultado = 2
               let lr_output.mensagem = ' Erro (', sqlca.sqlcode, ') na atualizacao dos servicos.'
               exit for
            else
              call cts00g07_apos_grvlaudo(am_cts29g00[l_i].atdmltsrvnum,am_cts29g00[l_i].atdmltsrvano)
            end if
         end if
      end for

      if lr_output.resultado = 2 then
         return lr_output.*
      end if
   else
      call cts29g00_obter_multiplo(1
                                  ,lr_input.servico_original
                                  ,lr_input.ano_original)
         returning lr_output.resultado
                  ,lr_output.mensagem
                  ,am_cts29g00[01].*
                  ,am_cts29g00[02].*
                  ,am_cts29g00[03].*
                  ,am_cts29g00[04].*
                  ,am_cts29g00[05].*
                  ,am_cts29g00[06].*
                  ,am_cts29g00[07].*
                  ,am_cts29g00[08].*
                  ,am_cts29g00[09].*
                  ,am_cts29g00[10].*

      for l_i = 1 to 10
         if am_cts29g00[l_i].atdmltsrvnum <> lr_input.atdsrvnum then
            whenever error continue
            execute p_cts65m00_052 using lr_input.atddatprg
                                      ,lr_input.atdhorprg
                                      ,lr_input.atdhorpvt
                                      ,am_cts29g00[l_i].atdmltsrvnum
                                      ,am_cts29g00[l_i].atdmltsrvano
            whenever error stop
            if sqlca.sqlcode <> 0 then
               let lr_output.resultado = 2
               let lr_output.mensagem = ' Erro (', sqlca.sqlcode, ') na atualizacao dos servicos.'
               exit for
            else
               call cts00g07_apos_grvlaudo(am_cts29g00[l_i].atdmltsrvnum,am_cts29g00[l_i].atdmltsrvano)
            end if
         end if
      end for

      if lr_output.resultado = 2 then
         return lr_output.*
      end if

      whenever error continue
      execute p_cts65m00_052 using lr_input.atddatprg
                                ,lr_input.atdhorprg
                                ,lr_input.atdhorpvt
                                ,lr_input.servico_original
                                ,lr_input.ano_original
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let lr_output.resultado = 2
         let lr_output.mensagem = ' Erro (', sqlca.sqlcode, ') na atualizacao dos servicos.'
      else
        call cts00g07_apos_grvlaudo(lr_input.servico_original,lr_input.ano_original)
      end if
   end if

   if lr_output.resultado <> 2 then
      let lr_output.resultado = 1
      let lr_output.mensagem = null
   end if

   return lr_output.*

end function

#-----------------------------------
function cts65m00_alt_end(lr_input)
#-----------------------------------
 define lr_input record
        obter_mult       smallint
       ,servico_original like datmservico.atdsrvnum
       ,ano_original     like datmservico.atdsrvano
 end record

 define lr_output record
        resultado      smallint
       ,mensagem       char(100)
 end record

 define l_i          smallint
 define l_contador   smallint
 define l_sqlcode    integer

   let l_contador = null
   let l_sqlcode  = null

   initialize lr_output.* to null
   let lr_output.resultado = 1

   if lr_input.obter_mult <> 1 then
      call cts29g00_consistir_multiplo(g_documento.atdsrvnum
                                      ,g_documento.atdsrvano)
           returning lr_output.resultado
                    ,lr_output.mensagem
                    ,lr_input.servico_original
                    ,lr_input.ano_original
   end if

   if lr_input.servico_original is not null then
      call cts29g00_obter_multiplo(1
                                  ,lr_input.servico_original
                                  ,lr_input.ano_original)
         returning lr_output.resultado
                  ,lr_output.mensagem
                  ,am_cts29g00[01].*
                  ,am_cts29g00[02].*
                  ,am_cts29g00[03].*
                  ,am_cts29g00[04].*
                  ,am_cts29g00[05].*
                  ,am_cts29g00[06].*
                  ,am_cts29g00[07].*
                  ,am_cts29g00[08].*
                  ,am_cts29g00[09].*
                  ,am_cts29g00[10].*

             call cts06g07_local("M",
                            lr_input.servico_original,
                            lr_input.ano_original,
                            1,
                            a_cts65m00[1].lclidttxt,
                            a_cts65m00[1].lgdtip,
                            a_cts65m00[1].lgdnom,
                            a_cts65m00[1].lgdnum,
                            a_cts65m00[1].lclbrrnom,
                            a_cts65m00[1].brrnom,
                            a_cts65m00[1].cidnom,
                            a_cts65m00[1].ufdcod,
                            a_cts65m00[1].lclrefptotxt,
                            a_cts65m00[1].endzon,
                            a_cts65m00[1].lgdcep,
                            a_cts65m00[1].lgdcepcmp,
                            a_cts65m00[1].lclltt,
                            a_cts65m00[1].lcllgt,
                            a_cts65m00[1].dddcod,
                            a_cts65m00[1].lcltelnum,
                            a_cts65m00[1].lclcttnom,
                            a_cts65m00[1].c24lclpdrcod,
                            a_cts65m00[1].ofnnumdig,
                            a_cts65m00[1].emeviacod,
                            a_cts65m00[1].celteldddcod,
                            a_cts65m00[1].celtelnum,
                            a_cts65m00[1].endcmp)
                  returning l_sqlcode
   end if

      for l_contador = 1 to 10
          if am_cts29g00[l_contador].atdmltsrvnum is not null then
             call cts06g07_local("M",
                            am_cts29g00[l_contador].atdmltsrvnum,
                            am_cts29g00[l_contador].atdmltsrvano,
                            1,
                            a_cts65m00[1].lclidttxt,
                            a_cts65m00[1].lgdtip,
                            a_cts65m00[1].lgdnom,
                            a_cts65m00[1].lgdnum,
                            a_cts65m00[1].lclbrrnom,
                            a_cts65m00[1].brrnom,
                            a_cts65m00[1].cidnom,
                            a_cts65m00[1].ufdcod,
                            a_cts65m00[1].lclrefptotxt,
                            a_cts65m00[1].endzon,
                            a_cts65m00[1].lgdcep,
                            a_cts65m00[1].lgdcepcmp,
                            a_cts65m00[1].lclltt,
                            a_cts65m00[1].lcllgt,
                            a_cts65m00[1].dddcod,
                            a_cts65m00[1].lcltelnum,
                            a_cts65m00[1].lclcttnom,
                            a_cts65m00[1].c24lclpdrcod,
                            a_cts65m00[1].ofnnumdig,
                            a_cts65m00[1].emeviacod,
                            a_cts65m00[1].celteldddcod,
                            a_cts65m00[1].celtelnum,
                            a_cts65m00[1].endcmp)
                  returning l_sqlcode

          end if
      end for

      return    lr_output.resultado
               ,lr_output.mensagem

end function

#--------------------------------------------------------------------------
function cts65m00_imdsrvflg(lr_param)
#--------------------------------------------------------------------------
   define lr_param     record
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt,
          acao         char(3),
          atdsrvorg    like datmservico.atdsrvorg,
          socntzcod    like datmsrvre.socntzcod,
          espcod       like datmsrvre.espcod,
          cidnom       like datmlcl.cidnom,
          ufdcod       like datmlcl.ufdcod,
          data         like datmservico.atddatprg,
          hora         like datmservico.atdhorprg,
          c24lclpdrcod like datmlcl.c24lclpdrcod
   end record

   define m_parametros  record
           resultado    smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acesso
           mensagem     char(100),
           acnlmttmp    like datkatmacnprt.acnlmttmp,
           acntntlmtqtd like datkatmacnprt.acntntlmtqtd,
           netacnflg    like datkatmacnprt.netacnflg,
           atmacnprtcod like datkatmacnprt.atmacnprtcod
   end record

   define lr_ret          record
          imdsrvflg       char(1),
          veiculo_aciona  like datkveiculo.socvclcod,
          cota_disponivel char(1),
          atddatprg       like datmservico.atddatprg,
          atdhorprg       like datmservico.atdhorprg,
          mpacidcod       like datkmpacid.mpacidcod
   end record

   define lr_agd_p  record
     min_atddatprg        like datmservico.atddatprg,
     min_atdhorprg        like datmservico.atdhorprg,
     max_atddatprg        like datmservico.atddatprg,
     max_atdhorprg        like datmservico.atdhorprg
   end record

   define l_resultado     smallint,
          l_mensagem      char(40),
          l_gpsacngrpcod  like datkmpacid.gpsacngrpcod,
          l_pergunta      char(1),
          l_conf_imd      char(1),
          l_contador      smallint

   initialize  lr_ret.*      to null
   initialize  lr_agd_p.*    to null
   initialize  mr_cts08g01.* to null

   let l_resultado     = null
   let l_mensagem      = null
   let l_gpsacngrpcod  = null
   let l_pergunta      = null
   let l_conf_imd      = "N"

   if lr_param.acao = "ALT" or lr_param.acao = "RAD" then
      let lr_ret.imdsrvflg = mr_salva.imdsrvflg
   else
      let lr_ret.imdsrvflg = "N"
   end if

   let lr_ret.atddatprg = lr_param.data
   let lr_ret.atdhorprg = lr_param.hora

   initialize  m_parametros.* to null
   call cts40g00_obter_parametro(lr_param.atdsrvorg)
        returning m_parametros.*

   #verificar se cidade é atendida por GPS
   let l_gpsacngrpcod     = null
   call cts41g03_tipo_acion_cidade(lr_param.cidnom,
                                   lr_param.ufdcod,
                                   m_parametros.atmacnprtcod,
                                   lr_param.atdsrvorg)
        returning l_resultado, l_mensagem, l_gpsacngrpcod, lr_ret.mpacidcod

   if l_gpsacngrpcod > 0 then

      call cts51g00_cidade_com_GPS(lr_param.lclltt, lr_param.lcllgt,
                                   lr_ret.mpacidcod, lr_param.atdsrvorg,
                                   lr_param.socntzcod, lr_param.espcod,
                                   lr_param.data, lr_param.hora,
                                   m_parametros.atmacnprtcod,
                                   m_parametros.acnlmttmp,
                                   lr_param.c24lclpdrcod,
                                   g_documento.atdsrvnum,
                                   g_documento.atdsrvano,
                                   g_documento.ramcod,
                                   g_documento.succod,
                                   g_documento.aplnumdig,
                                   g_documento.itmnumdig,
                                   g_documento.c24astcod,
                                   g_documento.ciaempcod ,
                                   lr_param.socntzcod,
                                   lr_param.espcod,
                                   am_param[1].socntzcod,
                                   am_param[1].espcod,
                                   am_param[2].socntzcod,
                                   am_param[2].espcod,
                                   am_param[3].socntzcod,
                                   am_param[3].espcod,
                                   am_param[4].socntzcod,
                                   am_param[4].espcod,
                                   am_param[5].socntzcod,
                                   am_param[5].espcod,
                                   am_param[6].socntzcod,
                                   am_param[6].espcod,
                                   am_param[7].socntzcod,
                                   am_param[7].espcod,
                                   am_param[8].socntzcod,
                                   am_param[8].espcod,
                                   am_param[9].socntzcod,
                                   am_param[9].espcod,
                                   am_param[10].socntzcod,
                                   am_param[10].espcod,
                                   false,        #- Tipo de acesso, Nao web
                                   m_criou_tabela,#- criagco tabela temporaria
                                   aux_hora,
                                   aux_today,
                                   d_cts65m00.socntzcod,
                                   a_cts65m00[1].lclltt,
                                   a_cts65m00[1].lgdnom,
                                   a_cts65m00[1].lgdnum,
                                   a_cts65m00[1].brrnom,
                                   a_cts65m00[1].cidnom,
                                   a_cts65m00[1].ufdcod,
                                   a_cts65m00[1].lgdcep
                                   )

           returning l_pergunta, lr_ret.veiculo_aciona,
                     lr_ret.cota_disponivel
   else
      call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
                                   lr_param.socntzcod, lr_param.data,
                                   lr_param.hora)
           returning l_pergunta, lr_ret.cota_disponivel
   end if

   # PSI-2013-00440PR nao utilizado no agendamento AW
   if m_agendaw = false
      then
      if ((l_gpsacngrpcod > 0 and lr_ret.veiculo_aciona is null and
          lr_ret.cota_disponivel = true) or l_pergunta = "S")         and
          (g_documento.ciaempcod <> 43 or
          (g_documento.ciaempcod = 43  and
          (ml_srvabrprsinfflg = "N" or ml_srvabrprsinfflg is null) )) then
   
         let l_pergunta = "S"
   
         call cts08g01("C","S","","CONFIRMA SERVICO IMEDIATO ?","","")
              returning l_conf_imd
   
         if l_conf_imd = "S" then
            let lr_ret.imdsrvflg = 'S'
            let lr_ret.atddatprg = null
            let lr_ret.atdhorprg = null
         end if
      end if
   else
      #Nas alteracoes o tipo de servico deve ser mantido caso seja consulta!
      if g_documento.acao = "ALT" then
         if m_imdsrvflg_ant = "S" then
               let lr_ret.imdsrvflg = 'S'
               let lr_ret.atddatprg = null
               let lr_ret.atdhorprg = null
         else
            let lr_ret.imdsrvflg = 'N'
         end if
      else
          #FLAG para SERVICO IMEDIATO: valor DEFAULT N
          #Conforme Alinhado com RENATO BASTOS (PSO) e MOISES (C24HRS)
          let lr_ret.imdsrvflg = 'N'
          let lr_ret.atddatprg = null
          let lr_ret.atdhorprg = null
      end if
   end if

   ## Abre agenda, nesta situacao, somente para na abertura do serviço(inclusao)

   if l_conf_imd = "N" then
      if mr_salva.atddatprg  is not null then
         let lr_ret.atddatprg = mr_salva.atddatprg
         let lr_ret.atdhorprg = mr_salva.atdhorprg
      end if
   end if


   return lr_ret.*

end function


########### TRATAMENTO PARA RESERVA DE COTAS ##############################
function cts65m00_cotas(lr_param)

   define lr_param    record
          veiculo_aciona   like datkveiculo.socvclcod,
          cota_disponivel  smallint,
          imdsrvflg   char(1),
          atddatprg   like datmservico.atddatprg,
          atdhorprg   like datmservico.atdhorprg,
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano,
          ramcod      like datrservapol.ramcod,
          succod      like datrservapol.succod,
          aplnumdig   like datrservapol.aplnumdig,
          itmnumdig   like datrservapol.itmnumdig,
          atdsrvorg   like datmservico.atdsrvorg,
          socntzcod   like datmsrvre.socntzcod
   end record

   define l_abater_cota    char(1),
          l_reservar_cota  char(1),
          l_data_cota      like datmservico.atddatprg,
          l_hora_cota      like datmservico.atdhorprg,
          l_hora_cotac     char(10)

   let l_abater_cota = "S"
   let l_reservar_cota = "S"

   let l_data_cota = null
   let l_hora_cota = null
   let l_hora_cotac = null

   # se servico imediato -
   # reservar cota para hoje e o horario atual cheio

   if lr_param.imdsrvflg = "S"  then
      let l_data_cota = aux_today
      let l_hora_cotac = aux_hora
      let l_hora_cotac = l_hora_cotac[1,2], ":00"
      let l_hora_cota  = l_hora_cotac
   else
      # se servico programado -
      # reservar cota para a data e horario informados
      let l_data_cota = lr_param.atddatprg
      let l_hora_cota = lr_param.atdhorprg
   end if

   ## Verifica se alterou o endereco
   call cts65m00_verifica_endereco() returning l_reservar_cota

   if l_reservar_cota = "N" then

      ## Verifica se alterou data/hora prog ou imediato
      call cts65m00_verifica_data_hora()
           returning l_abater_cota, l_reservar_cota

      if l_abater_cota = "S" then
         call cts65m00_abater_cota()
      end if

   end if

   if l_reservar_cota = "S" then

      ## Verifica se existe outros serviços para decidir a reserva da cota
      call cts51g00_ver_existencia_outros_srv(lr_param.atdsrvnum,
                                              lr_param.atdsrvano,
                                              lr_param.ramcod,
                                              lr_param.succod,
                                              lr_param.aplnumdig,
                                              lr_param.itmnumdig,
                                              l_data_cota,
                                              l_hora_cota,
                                              d_cts65m00.socntzcod,
                                              a_cts65m00[1].lclltt,
                                              a_cts65m00[1].lgdnom,
                                              a_cts65m00[1].lgdnum,
                                              a_cts65m00[1].brrnom,
                                              a_cts65m00[1].cidnom,
                                              a_cts65m00[1].ufdcod,
                                              a_cts65m00[1].lgdcep,
                                              ws_acaorigem
                                              )
           returning l_reservar_cota
   end if

   ## Reservando a cota
   if l_reservar_cota = "S" then
      call cts65m00_reservar_cota(lr_param.veiculo_aciona,
                                  lr_param.cota_disponivel,
                                  lr_param.atdsrvorg,
                                  lr_param.socntzcod,
                                  l_data_cota,
                                  l_hora_cota)
   end if

end function


function cts65m00_reservar_cota(lr_param)

   define lr_param         record
          veiculo_aciona   like datkveiculo.socvclcod,
          cota_disponivel  smallint,
          atdsrvorg        like datmservico.atdsrvorg,
          socntzcod        like datmsrvre.socntzcod,
          data_cota        like datmservico.atddatprg,
          hora_cota        like datmservico.atdhorprg
   end record

   define l_rglflg            smallint

   # se vou reservar cota pq tem veiculo em QRV e
   # nao tinha cota disponivel

   if lr_param.veiculo_aciona is not null and
      lr_param.cota_disponivel = false then

      #atualizar cota disponivel e utilizada para
      # cidade/origem/natureza/data e hora informada
      let l_rglflg = ctc59m02(a_cts65m00[1].cidnom
                             ,a_cts65m00[1].ufdcod
                             ,lr_param.atdsrvorg
                             ,lr_param.socntzcod
                             ,lr_param.data_cota
                             ,lr_param.hora_cota
                             ,true)
   else
      # atualiza cota utilizada para cidade/origem/natureza/data
      ## e hora informada
      let l_rglflg = ctc59m02(a_cts65m00[1].cidnom
                             ,a_cts65m00[1].ufdcod
                             ,lr_param.atdsrvorg
                             ,lr_param.socntzcod
                             ,lr_param.data_cota
                             ,lr_param.hora_cota
                             ,false)
   end if

end function

function cts65m00_verifica_endereco()

   define l_reservar   char(1)

   let l_reservar = "S"
   let m_alt_end = "N"

   ########## SE FOR UMA ALTERACAO NO SERVICO #########

   if g_documento.acao = "ALT" or
      g_documento.acao = "RAD" then

      if (((mr_salva.c24lclpdrcod <> 3 and a_cts65m00[1].c24lclpdrcod = 3)  or
           (mr_salva.c24lclpdrcod <> 4 and a_cts65m00[1].c24lclpdrcod = 4)  or # PSI 252891
           (mr_salva.c24lclpdrcod <> 5 and a_cts65m00[1].c24lclpdrcod = 5)) or
         (mr_salva.lclltt = a_cts65m00[1].lclltt)) then

         let l_reservar = "N"
         let m_alt_end = "N"
      else

         if mr_salva.lclltt <> a_cts65m00[1].lclltt or
            mr_salva.brrnom <> a_cts65m00[1].brrnom or
            mr_salva.lgdnom <> a_cts65m00[1].lgdnom or
            mr_salva.lgdnum <> a_cts65m00[1].lgdnum then
            ## alterou endereco
            let m_alt_end = "S"
         end if
      end if

   end if

   return l_reservar

end function

function cts65m00_abater_cota()

   define l_rglflg smallint

   let l_rglflg = null

   #se é consulta ou alteracao de servico
   if w_cts65m00.atdfnlflg = 'S' then
      call cts11g00(w_cts65m00.lignum)
      let int_flag = true
   end if

   #abater cota - buscando data/hora/natureza pelo servico
   let l_rglflg = ctc59m03_regulador(g_documento.atdsrvnum
                                     ,g_documento.atdsrvano)
end function

function cts65m00_verifica_data_hora()

   define l_abater_cota    char(1),
          l_reservar_cota  char(1)

   let l_abater_cota = "N"
   let l_reservar_cota = "N"

   #se alterou imediato OU se alterou data/hora programada
   if mr_salva.imdsrvflg <> d_cts65m00.imdsrvflg  or
      mr_salva.atddatprg <> w_cts65m00.atddatprg  or
      mr_salva.atdhorprg <> w_cts65m00.atdhorprg  or
      (mr_salva.atddatprg is null and w_cts65m00.atddatprg is not null) then

      ## nao confirmou a alteracao em todos os multiplos
      if m_confirma_alt_prog = "N" then
         let l_abater_cota = "N"
      else
         let l_abater_cota = "S"
      end if

      let l_reservar_cota = "S"

   end if

   return l_abater_cota, l_reservar_cota

end function

function cts65m00_ac(l_atdsrvnum, l_atdsrvano)

   define l_atdsrvnum like datmservico.atdsrvnum,
          l_atdsrvano like datmservico.atdsrvano,
          l_cmd       char(1000),
          l_lclltt1   like datmlcl.lclltt,
          l_lcllgt1   like datmlcl.lcllgt,
          l_c24lclpdrcod  like datmlcl.c24lclpdrcod,
          l_lclltt2   like datmlcl.lclltt,
          l_lcllgt2   like datmlcl.lcllgt,
          l_pstcoddig like datmsrvacp.pstcoddig,
          l_socvclcod like datmsrvacp.socvclcod,
          l_srrcoddig like datmsrvacp.srrcoddig,
          l_dist      decimal(8,4),
          l_status    smallint

   define l_mens       record
        msg          char(200)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(100)
   end record

  define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)
   initialize l_mens to null
   let l_cmd = null
   let l_lclltt1   = null
   let l_lcllgt1   = null
   let l_c24lclpdrcod  = null
   let l_lclltt2   = null
   let l_lcllgt2   = null
   let l_pstcoddig = null
   let l_socvclcod = null
   let l_srrcoddig = null
   let l_dist      = null
   let l_status    = null

   ##obter coordenada do servico
   whenever error continue
   open c_cts65m00_053 using l_atdsrvnum, l_atdsrvano
   fetch c_cts65m00_053 into l_lclltt1, l_lcllgt1, l_c24lclpdrcod
   whenever error stop
   close c_cts65m00_053

   ##obter viatura acionado
   whenever error continue
   open c_cts65m00_054 using l_atdsrvnum, l_atdsrvano
   fetch c_cts65m00_054 into  l_pstcoddig, l_socvclcod, l_srrcoddig
   whenever error stop
   close c_cts65m00_054

   ##obter coordenada da viatura no servico
   whenever error continue
   open c_cts65m00_055 using l_atdsrvnum, l_atdsrvano
   fetch c_cts65m00_055 into  l_lclltt2, l_lcllgt2
   whenever error stop
   close c_cts65m00_055

   ## calcular distancia
   let l_dist = 0
   call cts18g00(l_lclltt1, l_lcllgt1, l_lclltt2, l_lcllgt2)
        returning l_dist

   ## ser for > 50, enviar email para mim.
   if l_dist > 50 then

      let l_mens.msg = "Servico : ",l_atdsrvnum,"/" , l_atdsrvano, "/",
                       "Coord: ",   l_lclltt1,"/", l_lcllgt1,"/",
                                    l_c24lclpdrcod,"/",
                       "Prestador: ", l_pstcoddig,"/", l_socvclcod,"/",
                                      l_srrcoddig,"/",
                       "Coord: ",     l_lclltt2, "/",l_lcllgt2, "/",
                       "DIST CALC: ", l_dist

      let l_mens.de  = "cts65m00"
      let l_mens.subject = "Acionamento c/problemas dist.calc."
      let l_mens.para = "amilton.pinto@correioporto"
      #PSI-2013-23297 - Inicio
      let l_mail.de = l_mens.de
      #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
      let l_mail.para =  l_mens.para
      let l_mail.cc = ""
      let l_mail.cco = ""
      let l_mail.assunto = l_mens.subject
      let l_mail.mensagem = l_mens.msg
      let l_mail.id_remetente = "CT24H"
      let l_mail.tipo = "text"

      call figrc009_mail_send1 (l_mail.*)
       returning l_coderro,msg_erro

      #PSI-2013-23297 - Fim
   end if

end function

#--------------------------------------------------------------
 function cts65m00_verifica_retorno(p_cts65m00)
#--------------------------------------------------------------
 define p_cts65m00   record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdorgsrvnum     like datmservico.atdsrvnum,
    atdorgsrvano     like datmservico.atdsrvano,
    atddatprg        like datmservico.atddatprg,
    atdhorprg        like datmservico.atdhorprg,
    tipo             smallint  # Tipo 1 Busca recursiva aumentando o intervalo
 end record                    # Tipo 2 Busca uma unica vez

 define ws           record
    atdprscod        like datmservico.atdprscod,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig
 end record

 define lr_ret       record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdprscod        like datmservico.atdprscod,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig,
    atddatprg        like datmservico.atddatprg,
    atdhorprg        like datmservico.atdhorprg
 end record

 define lr_org       record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdprscod        like datmservico.atdprscod,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig
 end record

 define lr_agd_p  record
    min_atddatprg        like datmservico.atddatprg,
    min_atdhorprg        like datmservico.atdhorprg,
    max_atddatprg        like datmservico.atddatprg,
    max_atdhorprg        like datmservico.atdhorprg
 end record

 define lr_agd_c  record
    min_atddatprg        like datmservico.atddatprg,
    min_atdhorprg        like datmservico.atdhorprg,
    max_atddatprg        like datmservico.atddatprg,
    max_atdhorprg        like datmservico.atdhorprg
 end record

 define l_ret            smallint,
        l_contador       smallint,
        l_status         smallint,
        l_primeiro       smallint,
        l_intervalo      smallint,
        l_resultado      smallint,
        l_mensagem       char(60),
        l_min_data       datetime year to second,
        l_max_data       datetime year to second,
        l_data           datetime year to second,
        l_data_2         datetime year to second,
        l_data_char      char(19),
        l_atual_data     like datmservico.atddatprg,
        l_atual_hora     like datmservico.atdhorprg

 initialize ws, lr_ret, lr_org, l_ret, lr_agd_p, lr_agd_c to null

 let l_ret = false
 let l_status = 0
 let l_contador = 0
 let l_primeiro = true

 call cta12m00_seleciona_datkgeral("PSOTMPCONRET") # Parametro de tempo do controle de retorno
            returning  l_resultado
                      ,l_mensagem
                      ,l_intervalo

 if l_resultado <> 1 or   # Caso nao exista parametro ou com valor zero
    l_intervalo <= 0 then

    return l_contador
          ,lr_agd_p.min_atddatprg
          ,lr_agd_p.min_atdhorprg
          ,lr_agd_p.max_atddatprg
          ,lr_agd_p.max_atdhorprg
 end if

 let l_data_char = p_cts65m00.atddatprg
 let l_data_char = l_data_char[7,10],'-', l_data_char[4,5], '-', l_data_char[1,2]
                 , ' ', p_cts65m00.atdhorprg, ':00'
 let l_data = l_data_char
 let l_data_2 = l_data

 let l_min_data = l_data - l_intervalo units hour # Intervalo de controle com duas horas antes
 let l_max_data = l_data + l_intervalo units hour # duas horas depois de atendimento ja agendados

 let l_data_char = l_min_data
 let lr_agd_p.min_atdhorprg = l_data_char[12,16]
 let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
 let lr_agd_p.min_atddatprg = l_data_char

 let l_data_char = l_max_data
 let lr_agd_p.max_atdhorprg = l_data_char[12,16]
 let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
 let lr_agd_p.max_atddatprg = l_data_char

 if p_cts65m00.atdorgsrvnum is not null and
    p_cts65m00.atdorgsrvano is not null then

    # Busca o prestador do servico original
    whenever error continue
    open c_cts65m00_056 using p_cts65m00.atdorgsrvnum,
                              p_cts65m00.atdorgsrvano
    fetch c_cts65m00_056 into ws.atdprscod, ws.socvclcod, ws.srrcoddig
    whenever error stop

    # Foreach de atendimentos dentro do intervalo

    whenever error continue
    open c_cts65m00_057 using lr_agd_p.min_atddatprg,
                              lr_agd_p.min_atdhorprg,
                              lr_agd_p.max_atddatprg,
                              lr_agd_p.max_atdhorprg,
                              ws.atdprscod

    foreach c_cts65m00_057 into lr_ret.atdsrvnum
                          ,lr_ret.atdsrvano
                          ,lr_ret.socvclcod
                          ,lr_ret.srrcoddig
                          ,lr_ret.atddatprg
                          ,lr_ret.atdhorprg

        if p_cts65m00.atdsrvnum = lr_ret.atdsrvnum and
           p_cts65m00.atdsrvano = lr_ret.atdsrvano then
            continue foreach
        end if

        whenever error continue
        open c_cts65m00_058 using lr_ret.atdsrvnum,
                                  lr_ret.atdsrvano,
                                  ws.socvclcod
        fetch c_cts65m00_058 into l_status
        whenever error stop
        close c_cts65m00_058

        if sqlca.sqlcode = 100 then
            whenever error continue
            open c_cts65m00_059 using lr_ret.atdsrvnum,
                                      lr_ret.atdsrvano
            fetch c_cts65m00_059 into lr_org.atdsrvnum, lr_org.atdsrvano
            whenever error stop
            close c_cts65m00_059

            if sqlca.sqlcode = 0 then
               whenever error continue
               open c_cts65m00_060 using lr_org.atdsrvnum,
                                         lr_org.atdsrvano,
                                         ws.socvclcod
               fetch c_cts65m00_060 into l_status
               whenever error stop
               close c_cts65m00_060

                if sqlca.sqlcode = 100 then
                    continue foreach
                end if
            else
                continue foreach
            end if
        end if

        if l_contador = 0 then
           let l_data_char = l_data_2
           let lr_agd_p.min_atdhorprg = l_data_char[12,16]
           let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
           let lr_agd_p.min_atddatprg = l_data_char

           let lr_agd_p.max_atdhorprg = lr_agd_p.min_atdhorprg
           let lr_agd_p.max_atddatprg = lr_agd_p.min_atddatprg
        end if

        let l_contador = l_contador + 1
        let l_data_char = lr_ret.atddatprg
        let l_data_char = l_data_char[7,10],'-', l_data_char[4,5], '-', l_data_char[1,2]
                        , ' ', lr_ret.atdhorprg, ':00'

        let l_data = l_data_char
        let l_min_data = l_data - l_intervalo units hour
        let l_max_data = l_data + l_intervalo units hour

        let l_data_char = l_min_data
        let lr_agd_c.min_atdhorprg = l_data_char[12,16]
        let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
        let lr_agd_c.min_atddatprg = l_data_char

        let l_data_char = l_max_data
        let lr_agd_c.max_atdhorprg = l_data_char[12,16]
        let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
        let lr_agd_c.max_atddatprg = l_data_char

        if lr_agd_c.min_atddatprg <= lr_agd_p.min_atddatprg and
           lr_agd_c.min_atdhorprg <  lr_agd_p.min_atdhorprg then
           let lr_agd_p.min_atddatprg = lr_agd_c.min_atddatprg
           let lr_agd_p.min_atdhorprg = lr_agd_c.min_atdhorprg
        end if
        if lr_agd_c.max_atddatprg >= lr_agd_p.max_atddatprg and
           lr_agd_c.max_atdhorprg >  lr_agd_p.max_atdhorprg then
           let lr_agd_p.max_atddatprg = lr_agd_c.max_atddatprg
           let lr_agd_p.max_atdhorprg = lr_agd_c.max_atdhorprg
        end if

    end foreach
    whenever error stop
    close c_cts65m00_057

    if p_cts65m00.tipo = 1 and
       l_contador > 0 then

       let l_atual_data = today
       let l_atual_hora = current

       while true
           let l_status = 0
           call cts65m00_verifica_retorno(p_cts65m00.atdsrvnum
                                         ,p_cts65m00.atdsrvano
                                         ,p_cts65m00.atdorgsrvnum
                                         ,p_cts65m00.atdorgsrvano
                                         ,lr_agd_p.min_atddatprg
                                         ,lr_agd_p.min_atdhorprg
                                         ,2)
               returning l_status
                        ,lr_agd_c.min_atddatprg
                        ,lr_agd_c.min_atdhorprg
                        ,lr_agd_c.max_atddatprg
                        ,lr_agd_c.max_atdhorprg
           if l_status > 0 then
               if lr_agd_c.min_atddatprg <= l_atual_data and  # Limite minimo de busca ate hora atual
                  lr_agd_c.min_atdhorprg <  l_atual_hora then
                   exit while
               end if
               if lr_agd_c.min_atddatprg <= lr_agd_p.min_atddatprg and
                  lr_agd_c.min_atdhorprg <  lr_agd_p.min_atdhorprg then
                  let lr_agd_p.min_atddatprg = lr_agd_c.min_atddatprg
                  let lr_agd_p.min_atdhorprg = lr_agd_c.min_atdhorprg
               end if
           else
              exit while
           end if
       end while
       while true
          let l_status = 0
          call cts65m00_verifica_retorno(p_cts65m00.atdsrvnum
                                        ,p_cts65m00.atdsrvano
                                        ,p_cts65m00.atdorgsrvnum
                                        ,p_cts65m00.atdorgsrvano
                                        ,lr_agd_p.max_atddatprg
                                        ,lr_agd_p.max_atdhorprg
                                        ,2)
              returning l_status
                       ,lr_agd_c.min_atddatprg
                       ,lr_agd_c.min_atdhorprg
                       ,lr_agd_c.max_atddatprg
                       ,lr_agd_c.max_atdhorprg
          if l_status > 0 then
             if lr_agd_c.max_atddatprg >= lr_agd_p.max_atddatprg and
                lr_agd_c.max_atdhorprg >  lr_agd_p.max_atdhorprg then
                let lr_agd_p.max_atddatprg = lr_agd_c.max_atddatprg
                let lr_agd_p.max_atdhorprg = lr_agd_c.max_atdhorprg
             end if
          else
              exit while
          end if
       end while
    end if
 end if

 return l_contador
       ,lr_agd_p.min_atddatprg
       ,lr_agd_p.min_atdhorprg
       ,lr_agd_p.max_atddatprg
       ,lr_agd_p.max_atdhorprg

end function  #  cts65m00_verifica_retorno

function cts65m00_assunto_cortesia()

  define l_count integer
  
  define lr_retorno record
         flag   smallint
  end record
  
  
  let lr_retorno.flag = false
  let l_count = 0
  
  
  if m_prepara_sql is null or
     m_prepara_sql = false then
     call cts65m00_prepara()
  end if
  
  whenever error continue
  open c_cts65m00_065 using g_documento.c24astcod
  fetch c_cts65m00_065 into l_count
  whenever error stop
  
  if l_count > 0 then
     let lr_retorno.flag = true
  end if
  
  return lr_retorno.flag

end function
