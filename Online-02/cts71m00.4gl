#-----------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                              #
#.............................................................................#
#Sistema       : Central 24hs                                                 #
#Modulo        : cts71m00                                                     #
#Analista Resp : Roberto Reboucas                                             #
#                Tela de laudos de residencia                                 #
#.............................................................................#
#Desenvolvimento: Roberto Melo                                                #
#Liberacao      : 02/11/2011                                                  #
#-----------------------------------------------------------------------------#
#                                                                             #
#                         * * * Alteracoes * * *                              #
#                                                                             #
#Data       Autor Fabrica  Origem     Alteracao                               #
#---------- -------------- ---------- ----------------------------------------#
#06/03/2012 Celso Yamahaki CT3282/IN  Verifica se o ve�culo para retorno do   #
#                                     Servico n�o � nulo                      #
#-----------------------------------------------------------------------------#
# 01/10/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario  #
# 24/09/2013  Marcia, Intera 2013-2115 Chamada a cadastro de clientes SAPS    #
#-----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Altera��o da utiliza��o do sendmail   #
#-----------------------------------------------------------------------------#
# 25/06/2014 Josiane Almeida CT-2014-14110/IN   Tirar a chamada da fun��o     #
#                                              cty27g00_entrada_dados         #
#                                              da transa��o                   #
#-----------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Inclusao regulacao via AW      #
#-----------------------------------------------------------------------------#
# 05/dez/2014 - Marcos Souza (BizTalking)- PSI SPR-2014-28503 - Retirada dos  #
#                            campos da tela 'lclrsccod' (Locais de Risco) e   #
#                            'lclrscflg' (Atendimento Local de Risco).        #
#                            Alteracao de posicao dos campos 'socntzcod'      #
#                            (Natureza), 'espcod' (Codigo especialidade),     #
#                            'c24pbmcod' (Problema) e 'atddfttxt' (Problema   #
#                            apresentado';                                    #
#                            Retirada da abertura dos pop-ups questionando    #
#                            envio servi�o de apoio e inclusao de mais        #
#                            ocorrencias.                                     #
#                            Inclusao de rotina para captura do endereco de   #
#                            correspondencia                                  #
#-----------------------------------------------------------------------------#
#07/01/2015 BIZTalking,MMP SPR-2014-28503 (Fechamento de Servicos)            #
#                                     ->Chamar venda no input:                #
#                                       opsfa006_inclui e opsfa006_altera     #
#                                     ->Incluir venda na gravacao:            #
#                                       opsfa006_insert                       #
#-----------------------------------------------------------------------------#
#09/mar/2015 - Marcos Souza (BizTalking)- PSI SPR-2015-03912 - Atualizacao    #
#                           dt agendamento servico na venda, inclusao         #
#                           dt nascimento no input e tratamento pedido        #
#-----------------------------------------------------------------------------#
#20/mai/2015 - Marcos Souza (BizTalking)- SPR-2015-10068 - N�o permitir  a    #
#                           entrada de nome que n�o seja composto.            #
#-----------------------------------------------------------------------------#
#27/05/2015 INTERA,Marcos  SPR-2015-10068  Incluir funcao (ctrl+u) para       #
#                                          consulta das justificativas.       #
#-----------------------------------------------------------------------------#
#09/06/2015 INTERA,Marcos  SPR-2015-11582  Segregacao de rotina de abertura   #
#                                          da Venda em uma funcao, para ser   #
#                                          chamada pelos Laudos e Fila MQ.    #
#-----------------------------------------------------------------------------#
#08/jul/2015 - Marcos Souza (BizTalking)-SPR-2015-13708-Melhorias Calculo SKU #
#                         - Capturar a unidade de cobranca do SKU             #
#                         - Alteracao nas chamadas da Venda passando a data do#
#                           servico, o SKU e sua unidade de cobranca.         #
#-----------------------------------------------------------------------------#
#24/jul/2015 - Marcos Souza (BizTalking)-SPR-2015-15533-Fechamento Servs GPS  #
#                         Deslocar campo 'Prestador Local' para posicionamento#
#                         ap�s o campo 'Problema'.                            #
#-----------------------------------------------------------------------------#
#03/08/2015  - Norton Nery (BizTalking)-SPR-2015-15533-Carga variaveis para   #
#                         envio de email qdo Ocor. probl. de MQ na agenda     #
#-----------------------------------------------------------------------------#
#10/nov/2015 - Marcos Souza (BizTalking)-SPR-2015-22413-Acao Prom Black Friday#
#                         Incluir parametro "1" ("On-Line") nas chamadas das  #
#                         funcoes opsfa006_geracao() e a opsfa015_inscadped() #
#                         para indentificar o canal de venda.                 #
#-----------------------------------------------------------------------------#
#05/02/2016 - Josiane Almeida       Inclus�o de endere�o de correspondencia   #
#                                   na tecla F5                               #
#-----------------------------------------------------------------------------#
#04/04/2016 - Marcos Souza (InforSystem)-SPR-2016-03565 - Vendas e Parcerias. #
#                          Rede Apartada: pagamento direto ao Prestador       #
#                         (Identificacao no SKU)                              #
###############################################################################

globals "/homedsa/projetos/geral/globals/figrc072.4gl"  --> 223689
globals "/homedsa/projetos/geral/globals/glct.4gl"   ##-- SPR-2015-15533
globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"  # PSI-2013-07115


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

 define d_cts71m00    record
    srvnum            char (13)                    ,
    prpnumdsp         char (11)                    , #=> SPR-2014-28503
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
#-- doctxt            char (32)                    ,  #--- SPR-2015-03912-Cadastro Clientes ---
    nscdat            like datksrvcli.nscdat       ,  #--- SPR-2015-03912-Cadastro Clientes ---
    srvpedcod         like datmsrvped.srvpedcod    ,  #--- SPR-2015-03912-Cadastro Pedidos  ---
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

 define w_cts71m00    record
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

 define a_cts71m00    array[2] of record
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
    ramcod          like datrligapol.ramcod,        # Codigo do Ramo
    aplnumdig       like datrligapol.aplnumdig,    # Numero Apolice
    itmnumdig       like datrligapol.itmnumdig,    # Numero do Item
    edsnumref       like datrligapol.edsnumref,    # Numero do Endosso
    prporg          like datrligprp.prporg,        # Origem da Proposta
    prpnumdig       like datrligprp.prpnumdig,     # Numero da Proposta
    fcapacorg       like datrligpac.fcapacorg,     # Origem PAC
    fcapacnum       like datrligpac.fcapacnum,      # Numero PAC
    lignum          like datmligacao.lignum
 end record

 define m_servico_original   like datratdmltsrv.atdsrvnum
       ,m_ano_original       like datratdmltsrv.atdsrvano

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_retctb83m00 smallint
 define m_c24astcodflag like datmligacao.c24astcod  #=> SPR-2014-28503
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

 define mr_assunto record
        resultado smallint
       ,mensagem  char(100)
       ,c24astcod like datmligacao.c24astcod
       ,lignum        like datmligacao.lignum
 end record

 define m_sel     smallint # PSI-2013-07155
 define mr_grava_sugest CHAR(01) # PSI-2013-07115

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
      , m_mailpfaz     smallint
      , m_atddatprg_aux date                      #-SPR-2016-01943
      , m_atdhorprg_aux datetime hour to minute   #-SPR-2016-01943



 define cty27g00_ret  integer # psi-2012-22101/SPR-2014-28503 - MODULAR
 define m_vendaflg    smallint   #=> SPR-2014-28503
 define m_pbmonline   like datksrvcat.catcod   #- PSI SPR-2014-28503 - Venda Online

 #=> SPR-2014-28503 - NUMERO DA PROPOSTA (FORMA DE PAGAMENTO)
 define mr_prop       record
        prpnum        like datmpgtinf.prpnum,
        sqlcode       integer,
        msg           char(80)
 end record
 define mr_teclas     record
        func01        char(20),
        func02        char(20),
        func03        char(20),
        func04        char(20),
        func05        char(20),
        func06        char(20),
        func07        char(20),
        func08        char(20),
        func09        char(20),
        func10        char(20),
        func11        char(20),
        func12        char(20),
        func13        char(20),
        func14        char(20)
 end record


#-----------------------------------------------#
 function cts71m00_prepara()
#-----------------------------------------------#
 define l_sql_stmt   char(1000)

 #display "prepare "
 let l_sql_stmt = "select datmligacao.c24astcod ",
                  " from datmligacao ",
                  " where datmligacao.atdsrvnum  = ? ",
                  "  and datmligacao.atdsrvano  = ? ",
                  "  and datmligacao.lignum    <> 0 "
 prepare p_cts71m00_001 from l_sql_stmt
 declare c_cts71m00_001 cursor for p_cts71m00_001


 #=> SPR-2014-28503 - REAPROVEITAMENTO DE ACESSO NAO UTILIZADO
 let l_sql_stmt = "select c24astcod",
                  "  from datmligacao ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? ",
                  " order by lignum"
 prepare p_cts71m00_002 from l_sql_stmt
 declare c_cts71m00_002 cursor for p_cts71m00_002


  let l_sql_stmt = " select grlinf ",
                   " from igbkgeral ",
                   " where  mducod = 'C24' ",
                   " and  grlchv = 'RADIO-DEMRE' "

  prepare p_cts71m00_003 from l_sql_stmt
  declare c_cts71m00_003 cursor for p_cts71m00_003



  let l_sql_stmt = " select atdetpcod  from datmsrvacp ",
                   "  where atdsrvnum = ?  ",
                   "  and atdsrvano = ?   ",
                   "  and atdsrvseq = (select max(atdsrvseq) ",
                   "                     from datmsrvacp  ",
                   "                    where atdsrvnum = ? ",
                   "                      and atdsrvano = ? )"
  prepare p_cts71m00_004 from l_sql_stmt
  declare c_cts71m00_004 cursor for p_cts71m00_004


 let l_sql_stmt = " update datmservico set c24opemat = null " ,
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? "
 prepare p_cts71m00_005 from l_sql_stmt


 let l_sql_stmt = " select nom,cornom,corsus,atddfttxt,funmat,asitipcod,",
                  " atddat,atdhor,atdlibflg,atdlibhor,atdlibdat,atdhorpvt,",
                  " atdpvtretflg,atddatprg,atdhorprg,atdfnlflg,atdprinvlcod,",
                  " atdprscod,prslocflg,acntntqtd,ciaempcod,empcod ", #Raul, Biz
                  "  from datmservico ",
                  " where atdsrvnum = ?  " ,
                  " and atdsrvano = ? "
 prepare p_cts71m00_006 from l_sql_stmt
 declare c_cts71m00_006 cursor for p_cts71m00_006


 let l_sql_stmt = " select lclrsccod,orrdat,socntzcod,atdorgsrvnum, " ,
                  " atdorgsrvano,srvretmtvcod,espcod,retprsmsmflg   ",
                  " from datmsrvre ",
                  " where atdsrvnum = ?  ",
                  " and atdsrvano = ? "

 prepare p_cts71m00_007 from l_sql_stmt
 declare c_cts71m00_007 cursor for p_cts71m00_007


 let l_sql_stmt = " select srvretexcdes ",
                  " from datmsrvretexc ",
                  " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
 prepare p_cts71m00_008 from l_sql_stmt
 declare c_cts71m00_008 cursor for p_cts71m00_008

 let l_sql_stmt = " select srvretmtvdes ",
                  " from datksrvret ",
                  " where srvretmtvcod  = ? "
 prepare p_cts71m00_009 from l_sql_stmt
 declare c_cts71m00_009 cursor for p_cts71m00_009


 let l_sql_stmt = " select ofnnumdig ",
                  " from datmlcl ",
                  " where atdsrvano = ? ",
                  "  and atdsrvnum = ? ",
                  "  and c24endtip = ? " #--- PSI SPR-2014-28503-Endereco Correspondencia
 prepare p_cts71m00_010 from l_sql_stmt
 declare c_cts71m00_010 cursor for p_cts71m00_010

 let l_sql_stmt = " select socntzdes  ",
                  " from datksocntz ",
                  " where socntzcod = ? "
 prepare p_cts71m00_011 from l_sql_stmt
 declare c_cts71m00_011 cursor for p_cts71m00_011

 let l_sql_stmt = " select asitipabvdes ",
                  " from datkasitip ",
                  " where asitipcod = ? "
 prepare p_cts71m00_012 from l_sql_stmt
 declare c_cts71m00_012 cursor for p_cts71m00_012

 let l_sql_stmt =  " select c24solnom, ligcvntip, c24astcod ",
                   " from datmligacao ",
                   " where lignum = ? "
 prepare p_cts71m00_013 from l_sql_stmt
 declare c_cts71m00_013 cursor for p_cts71m00_013

 let l_sql_stmt = " select funnom, dptsgl ",
                  " from isskfunc ",
                  " where empcod = ? ",                               #Raul, Biz
                  "  and funmat = ? "
 prepare p_cts71m00_014 from l_sql_stmt
 declare c_cts71m00_014 cursor for p_cts71m00_014

let l_sql_stmt = "  select cpodes   ",
                 " from iddkdominio ",
                 " where cponom = 'atdprinvlcod' ",
                 "  and cpocod = ? "
prepare p_cts71m00_015 from l_sql_stmt
declare c_cts71m00_015 cursor for p_cts71m00_015


let l_sql_stmt = " select c24pbmcod ",
                 " from datrsrvpbm " ,
                 " where atdsrvnum  = ? ",
                 "  and atdsrvano   = ? ",
                 "  and c24pbminforg = 1 ",
                 "  and c24pbmseq    = 1 "

prepare p_cts71m00_016 from l_sql_stmt
declare c_cts71m00_016 cursor for p_cts71m00_016


let l_sql_stmt = " select max(atdsrvseq) from datmsrvacp ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano  = ? "

prepare p_cts71m00_017 from l_sql_stmt
declare c_cts71m00_017 cursor for p_cts71m00_017

let l_sql_stmt = " select atdetpcod  from datmsrvacp ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = ? "
prepare p_cts71m00_018 from l_sql_stmt
declare c_cts71m00_018 cursor for p_cts71m00_018

let l_sql_stmt = " update datmservico set ( nom,cornom,corsus,atddfttxt,  ",
                 " atdlibflg,atdlibhor,atdlibdat,atdhorpvt,atdpvtretflg , ",
                 " atddatprg,atdhorprg,asitipcod,atdfnlflg) ",
                 " = ( ?,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ) ",
                 "  where atdsrvnum = ?  ",
                 "  and atdsrvano = ? "

prepare p_cts71m00_019 from l_sql_stmt

let l_sql_stmt = "update datmsrvre set (lclrsccod,orrdat,socntzcod, ",
                 " espcod,srvretmtvcod,retprsmsmflg) ",
                 "  = (? ,? ,? ,? ,? ,? ) ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts71m00_020 from l_sql_stmt

let l_sql_stmt = "delete from datmsrvretexc ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts71m00_021 from l_sql_stmt

let l_sql_stmt = " insert into datmsrvretexc ( atdsrvnum,atdsrvano, ",
                 " srvretexcdes,caddat,cademp,cadmat,cadusrtip   ) ",
                 " values ( ? , ? ,? ,? ,? ,? ,? ) "
prepare p_cts71m00_022 from l_sql_stmt

let l_sql_stmt = " select asitipabvdes "
                ,"  from datkasitip "
                ,"  where asitipcod = ? "
                ,"    and asitipstt = 'A' "
prepare p_cts71m00_023 from l_sql_stmt
declare c_cts71m00_023 cursor for p_cts71m00_023

let l_sql_stmt = ' select lgdtip,lgdnom,lgdnum,   ',
                   '        brrnom,lclbrrnom,cidnom,ufdcod,',
                   '        lgdcep,lgdcepcmp,lclrefptotxt,endcmp ',
                   '   from datmlcl                 ',
                   '  where atdsrvnum = ?           ',
                   '    and atdsrvano = ?           ',
                   '    and c24endtip = 1           '
 prepare p_cts71m00_025 from l_sql_stmt
 declare c_cts71m00_025 cursor for p_cts71m00_025


let l_sql_stmt = " select cgccpfnum, cgccpfdig ",
                 " from gsakseg ",
                 " where gsakseg.segnumdig = ? "
prepare p_cts71m00_027 from l_sql_stmt
declare c_cts71m00_027 cursor for p_cts71m00_027


let l_sql_stmt = " select gsakend.endlgdtip, gsakend.endlgd,gsakend.endnum, ",
                 " gsakend.endcmp, gsakend.endbrr, gsakend.endcid, ",
                 " gsakend.endufd, gsakend.endcep,gsakend.endcepcmp ",
                 " from gsakend ",
                 " where gsakend.segnumdig = ? ",
                 " and gsakend.endfld    = '1' "

prepare p_cts71m00_028 from l_sql_stmt
declare c_cts71m00_028 cursor for p_cts71m00_028

let l_sql_stmt = " select cornom from gcaksusep, gcakcorr ",
                 " where gcaksusep.corsus = ? and ",
                 " gcakcorr.corsuspcp = gcaksusep.corsuspcp "
prepare p_cts71m00_029 from l_sql_stmt
declare c_cts71m00_029 cursor for p_cts71m00_029


let l_sql_stmt = " select natagdflg ",
              " from datksocntz ",
              " where socntzcod = ? "
prepare p_cts71m00_031 from l_sql_stmt
declare c_cts71m00_031 cursor for p_cts71m00_031

let l_sql_stmt = " select c24astcod  "
                ,"  from datmligacao "
                ,"  where lignum = ? "
prepare p_cts71m00_032 from l_sql_stmt
declare c_cts71m00_032 cursor for p_cts71m00_032

let l_sql_stmt = " select atdorgsrvnum   , atdorgsrvano ",
                 " from datmsrvre ",
                 " where datmsrvre.atdsrvnum = ? ",
                 "  and datmsrvre.atdsrvano  = ? "
prepare p_cts71m00_033 from l_sql_stmt
declare c_cts71m00_033 cursor for p_cts71m00_033

let l_sql_stmt = "select atdlibflg ",
                 " from datmservico ",
                 " where atdsrvnum = ? ",
                 " and   atdsrvano = ? "
prepare p_cts71m00_034 from l_sql_stmt
declare c_cts71m00_034 cursor for p_cts71m00_034

let l_sql_stmt = "select atddfttxt, asitipcod, nom, corsus, cornom ",
                 " from datmservico ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts71m00_035 from l_sql_stmt
declare c_cts71m00_035 cursor for p_cts71m00_035


let l_sql_stmt = "select c24solnom, ligcvntip  ",
                  " from datmligacao ",
                  " where atdsrvnum = ? ",
                  " and atdsrvano   = ? "
prepare p_cts71m00_036 from l_sql_stmt
declare c_cts71m00_036 cursor for p_cts71m00_036

let l_sql_stmt = " select lclrsccod   , atdorgsrvnum,atdorgsrvano, ",
                 " socntzcod   ,orrdat, espcod ",
                 " from datmsrvre ",
                 " where datmsrvre.atdsrvnum = ? ",
                 "  and datmsrvre.atdsrvano = ? "
prepare p_cts71m00_037 from l_sql_stmt
declare c_cts71m00_037 cursor for p_cts71m00_037

let l_sql_stmt = " select max(atdsrvseq) from datmsrvacp ",
                 " where atdsrvnum = ? and ",
                 " atdsrvano = ? and ",
                 " atdetpcod = 3               and ",
                 " pstcoddig is not null "
prepare p_cts71m00_038 from l_sql_stmt
declare c_cts71m00_038 cursor for p_cts71m00_038

let l_sql_stmt = " select pstcoddig,srrcoddig,socvclcod ",
                 " from datmsrvacp ",
                 " where atdsrvnum = ? and ",
                 "     atdsrvano =   ? and ",
                 "     atdsrvseq =   ? "
prepare p_cts71m00_039 from l_sql_stmt
declare c_cts71m00_039 cursor for p_cts71m00_039

let l_sql_stmt = " select atdvclsgl from datkveiculo ",
                 " where socvclcod = ? "
prepare p_cts71m00_040 from l_sql_stmt
declare c_cts71m00_040 cursor for p_cts71m00_040

#--- PSI SPR-2014-28503
#let l_sql_stmt = " select ofnnumdig  ",
#                 " from datmlcl ",
#                 " where atdsrvano = ? ",
#                 "  and atdsrvnum = ? ",
#                 "  and c24endtip = 1 "
#prepare p_cts71m00_041 from l_sql_stmt
#declare c_cts71m00_041 cursor for p_cts71m00_041
#

let l_sql_stmt = " select c24pbmcod     ",
                 " from datrsrvpbm      ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano    = ? ",
                 " and c24pbminforg = 1 ",
                 " and c24pbmseq    = 1 "
prepare p_cts71m00_042 from l_sql_stmt
declare c_cts71m00_042 cursor for p_cts71m00_042

let l_sql_stmt = " select socntzdes     ",
                 " from datksocntz     ",
                 " where socntzcod = ? "
prepare p_cts71m00_043 from l_sql_stmt
declare c_cts71m00_043 cursor for p_cts71m00_043


let l_sql_stmt = " select asitipabvdes  ",
                 " from datkasitip      ",
                 " where asitipcod = ?  "
prepare p_cts71m00_044 from l_sql_stmt
declare c_cts71m00_044 cursor for p_cts71m00_044

 let l_sql_stmt = ' update datmservico set '
                   ,'        prslocflg = ? '
                   ,'      , socvclcod = ? '
                   ,'      , srrcoddig = ? '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts71m00_045 from l_sql_stmt


let l_sql_stmt = ' select max(atdsrvseq) '
                   ,'   from datmsrvacp '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts71m00_046 from l_sql_stmt
declare c_cts71m00_046 cursor for p_cts71m00_046


let l_sql_stmt = ' insert into datmsrvre '
                   ,'      ( atdsrvnum   , atdsrvano, '
                   ,'        lclrsccod   , orrdat, '
                   ,'        orrhor      , socntzcod, '
                   ,'        atdsrvretflg, atdorgsrvnum, '
                   ,'        atdorgsrvano, srvretmtvcod, '
                   ,'        retprsmsmflg, espcod,  '
                   ,'        lclnumseq   , rmerscseq) '
                  , ' values (?,?,?,?,"00:00",?,"N",?,?,?,?,?,?,?) '
prepare p_cts71m00_047 from l_sql_stmt

let l_sql_stmt = ' insert into datmsrvretexc '
                   ,'      ( atdsrvnum, atdsrvano, '
                   ,'        srvretexcdes, caddat, '
                   ,'        cademp, cadmat, cadusrtip) '
                   ,' values (?,?,?,?,?,?,?) '
prepare p_cts71m00_048 from l_sql_stmt

let l_sql_stmt =  "Insert into dbscadtippgt (anosrv,",
                     "nrosrv,pgttipcodps,pgtmat,corsus,cadmat,cademp,",
                     "caddat,atlmat,atlemp,atldat,cctcod,succod,empcod,",
                     "pgtempcod) values  ",
                     "(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
prepare p_cts71m00_050 from l_sql_stmt



let l_sql_stmt = ' insert into datratdmltsrv '
                   ,'      ( atdsrvnum, atdsrvano, '
                   ,'        atdmltsrvnum, atdmltsrvano ) '
                   ,' values (?,?,?,?) '
prepare p_cts71m00_051 from l_sql_stmt

let l_sql_stmt = ' update datmservico '
                      ,' set atddatprg = ? '
                         ,' ,atdhorprg = ? '
                         ,' ,atdhorpvt = ? '
                    ,' where atdsrvnum = ? '
                      ,' and atdsrvano = ? '
prepare p_cts71m00_052 from l_sql_stmt

let l_sql_stmt = ' select lclltt,lcllgt, c24lclpdrcod ',
               ' from datmlcl ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and c24endtip = 1 '

prepare p_cts71m00_053 from l_sql_stmt
declare c_cts71m00_053 cursor for p_cts71m00_053

 ##obter viatura acionado
let l_sql_stmt = ' select pstcoddig, socvclcod, srrcoddig ',
               ' from datmsrvacp ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and atdetpcod = 3 '

prepare p_cts71m00_054 from l_sql_stmt
declare c_cts71m00_054 cursor for p_cts71m00_054

   ##obter coordenada da viatura no servico
let l_sql_stmt = ' select srrltt, srrlgt ',
                ' from datmservico ',
                ' where atdsrvnum = ? ',
                  ' and atdsrvano = ? '
prepare p_cts71m00_055 from l_sql_stmt
declare c_cts71m00_055 cursor for p_cts71m00_055

let l_sql_stmt = " select atdprscod, socvclcod, srrcoddig ",
                 " from datmservico ",
                 " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
prepare p_cts71m00_056 from l_sql_stmt
declare c_cts71m00_056 cursor for p_cts71m00_056

let l_sql_stmt = " select atdsrvnum, atdsrvano, ",
                 "  socvclcod, srrcoddig, ",
                 "  atddatprg, atdhorprg ",
                 "  from datmservico ",
                 "  where atdetpcod not in (5,6) ",
                 "  and (atddatprg >= ? ",
                 "  and  atdhorprg >  ?)",
                 "  and (atddatprg <= ? " ,
                 "  and  atdhorprg <  ? )"
prepare p_cts71m00_057 from l_sql_stmt
declare c_cts71m00_057 cursor for p_cts71m00_057

let l_sql_stmt = " select 1 ",
                 " from datmservico ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano    = ? ",
                 " and socvclcod    = ? "
prepare p_cts71m00_058 from l_sql_stmt
declare c_cts71m00_058 cursor for p_cts71m00_058

let l_sql_stmt = " select atdorgsrvnum, atdorgsrvano ",
                 " from datmsrvre ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano  = ? ",
                 " and retprsmsmflg = 'S' ",
                 " and atdorgsrvnum is not null ",
                 " and atdorgsrvano is not null "
prepare p_cts71m00_059 from l_sql_stmt
declare c_cts71m00_059 cursor for p_cts71m00_059

let l_sql_stmt = "select 1 ",
                 " from datmservico ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano  = ? ",
                 " and socvclcod = ? "
prepare p_cts71m00_060 from l_sql_stmt
declare c_cts71m00_060 cursor for p_cts71m00_060

let l_sql_stmt = ' select atdmltsrvnum, atdmltsrvano '
                   ,'   from datratdmltsrv '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts71m00_061 from l_sql_stmt
declare c_cts71m00_061 cursor for p_cts71m00_061


let l_sql_stmt = ' update datmservico '
                   ,'    set c24opemat = ? '
                   ,'  where atdsrvnum = ? '
                   ,'    and atdsrvano = ? '
prepare p_cts71m00_062 from l_sql_stmt


let l_sql_stmt = " select socacsflg, c24opemat ",
                     " from datkveiculo ",
                    " where socvclcod = ? "

prepare p_cts71m00_063 from l_sql_stmt
declare c_cts71m00_063 cursor for p_cts71m00_063

let l_sql_stmt = " select c24atvcod ",
                 " from dattfrotalocal ",
                 " where socvclcod = ? "

prepare p_cts71m00_064 from l_sql_stmt
declare c_cts71m00_064 cursor for p_cts71m00_064

let l_sql_stmt = " select count(*) ",
                 " from datkassunto ",
                 " where c24astcod = ? ",
                 " and itaasstipcod = 3 "

prepare p_cts71m00_065 from l_sql_stmt
declare c_cts71m00_065 cursor for p_cts71m00_065

#CT3282/IN
let l_sql_stmt = " select 1 ",
                 " from datmservico ",
                 " where atdsrvnum  = ? ",
                 " and atdsrvano    = ? ",
                 " and socvclcod    is null"
prepare p_cts71m00_066 from l_sql_stmt
declare c_cts71m00_066 cursor for p_cts71m00_066

 #=> SPR-2014-28503 - MELHORIA (ACESSO PELO INDICE)
 let l_sql_stmt =  " select pgtfrmcod   "
                  ,"   from datmpgtinf  "
                  ,"  where orgnum = 29 "
                  ,"    and prpnum = ?  "
 prepare p_cts71m00_067 from l_sql_stmt
 declare c_cts71m00_067 cursor for p_cts71m00_067

 let l_sql_stmt =  "select clinom, crtnum, bndcod, "
                  ,"crtvlddat, cbrparqtd           "
                  ,"from datmcrdcrtinf             "
                  ,"where orgnum = ?               "
                  ,"and prpnum = ?                 "
                  ,"and pgtseqnum = (select        "
                  ,"max(pgtseqnum) from            "
                  ,"datmcrdcrtinf a                "
                  ,"where a.orgnum = ?             "
                  ,"and prpnum = ?)                "

 prepare p_cts71m00_068 from l_sql_stmt
 declare c_cts71m00_068 cursor for p_cts71m00_068

 let l_sql_stmt =  "select pgtfrmdes      "
             ,"from datkpgtfrm       "
             ,"where pgtfrmcod = ?   "

 prepare p_cts71m00_069 from l_sql_stmt
 declare c_cts71m00_069 cursor for p_cts71m00_069

 #let l_sql_stmt =  "select bnddes         "
 #            ,"from datkcrtbnd       "
 #            ,"where bndcod = ?      "

 let l_sql_stmt =  "select carbndnom       "
                  ,"from   fcokcarbnd      "
                  ,"where  carbndcod = ?   "

 prepare p_cts71m00_070 from l_sql_stmt
 declare c_cts71m00_070 cursor for p_cts71m00_070


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql_stmt =  "select c24soltipcod "
                  ," from datmligacao lig "
                  ," where lig.atdsrvnum = ? "
                  ,"  and lig.atdsrvano  = ? "
                  ,"  and lig.lignum = (  "
                  ,"         select min(lignum) "
                  ,"           from datmligacao lim "
                  ,"          where lim.atdsrvnum = lig.atdsrvnum  "
                  ,"            and lim.atdsrvano = lig.atdsrvano )"
 prepare p_cts71m00_071 from l_sql_stmt
 declare c_cts71m00_071 cursor for p_cts71m00_071




 let l_sql_stmt = " select grlinf ",
                  " from datkgeral ",
                  " where grlchv = 'PSOAGENDAPSFAZ' "
 prepare p_cts71m00_071a from l_sql_stmt
 declare c_cts71m00_071a cursor for p_cts71m00_071a


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql_stmt = "  select 1 "
                 ," from iddkdominio "
                 ," where cponom = 'altvlrvnd' "
                 ,"  and cpocod = ? "
 prepare p_cts71m00_072 from l_sql_stmt
 declare c_cts71m00_072 cursor for p_cts71m00_072


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql_stmt = "  select 1 "
                 ," from datkdominio "
                 ," where cponom = 'altvlrvnd' "
                 ,"  and cpocod = ? "
 prepare p_cts71m00_073 from l_sql_stmt
 declare c_cts71m00_073 cursor for p_cts71m00_073


  let l_sql_stmt = " select grlinf ",
                  " from datkgeral ",
                  " where grlchv = 'PSOEMAILPFAZ' "
 prepare p_cts71m00_074 from l_sql_stmt
 declare c_cts71m00_074 cursor for p_cts71m00_074


let m_prepara_sql = true

end function

#--------------------------------------------------------------------
 function cts71m00()
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
          , m_rsrchvant 
          , m_atddatprg_aux            #-SPR-2016-01943
          , m_atdhorprg_aux  to null   #-SPR-2016-01943

 initialize ws.*          to null
 initialize m_socntzcod   to null
 initialize l_grlinf      to null
 initialize lr_dados.*    to null
 initialize mr_salva.*    to null
 initialize m_subbairro   to null
 initialize mr_rsc_re.*   to null
 initialize am_cts29g00   to null
 initialize a_cts71m00    to null
 initialize d_cts71m00.*  to null
 initialize w_cts71m00.*  to null
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

 #display "entrei cts71m00"
 let ws.flag_acesso = cta00m06(g_issk.dptsgl)

 if g_documento.acao is null then
    if g_documento.atdsrvnum is not null then
       let g_documento.acao = "RAD" ## indica que veio pelo Radio
    end if
 end if

 #display "teste 952 "
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

 #display "teste 966 "
 call cts40g03_data_hora_banco(2) returning m_data, m_hora

 let aux_hora          = m_hora
 let aux_today         = m_data
 let w_cts71m00.atddat = m_data
 let w_cts71m00.atdhor = m_hora
 let flgcpl            = 0
 let ws_acao           = g_documento.acao
 let ws_acaorigem      = g_documento.acao

 #display "teste 977"
 if m_prepara_sql is null or
    m_prepara_sql <> true then
    call cts71m00_prepara()
 end if

  # PSI-2013-00440PR
 let m_agendaw = false

 whenever error continue
 open c_cts71m00_071a
 fetch c_cts71m00_071a into m_agendaw

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
    open c_cts71m00_001 using g_documento.atdsrvnum,
                              g_documento.atdsrvano

    whenever error stop

    foreach c_cts71m00_001 into ws.c24astcod_ret
       if ws.c24astcod_ret = "RET"  then
          let ws_acao = "RET"
       end if
       exit foreach
    end foreach
    close c_cts71m00_001
 end if

 if g_documento.acao = 'CON' and ws_acao <> "RET" then
    let ws_acao = 'CON'
 end if

 #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
 initialize mr_teclas.* to null

 if ws_acao is not null    and ws_acao      = "RET"   then
    let ws_tela = "RET"

    message 'Aguarde, verificando procedimentos... ' attribute (reverse)

    call cts14g00(ws_acao,
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  'N',
                  '2099-12-31 23:00')
    message ''

    open window cts71m00r at 04,02 with form "cts71m00"
                         attribute(form line 1)

    #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
    display "(F3)Referencia (F6)Historico (F9)Conclui  (CTRL+F)Todas as Funcoes"
            to msgfun

    #=> SPR-2014-28503 - CAMPO 'tit' DEIXA DE EXISTIR
{
    if g_documento.ciaempcod <> 40 then
       display "PORTO SOCORRO RAMOS ELEMENTARES" to tit
    end if
}

    display "Mtv.Ret. :" to cpltela
    display "Acionar mesmo Prestador? " to cplPrest

    if ws.flag_acesso = 0 then
       #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
       let mr_teclas.func01 = "<F3> Referencia"
       let mr_teclas.func02 = "<F6> Historico"
    else
       #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
       let mr_teclas.func01 = "<F1> Help"
       let mr_teclas.func02 = "<F2> Servico Origin"
       let mr_teclas.func03 = "<F3> Referencia"
       let mr_teclas.func04 = "<F5> Venda/F.Pag"
       let mr_teclas.func05 = "<F6> Historico"
       let mr_teclas.func06 = "<F7> Impressao"
       let mr_teclas.func07 = "<F9> Conclui"
       let mr_teclas.func08 = "<CTRL+T> Etapa"
       let mr_teclas.func09 = "<CTRL+E> E-mail"
       let mr_teclas.func10 = "<CTRL+O> Correspond"
       let mr_teclas.func11 = "<CTRL+U> Justificat"  #=> SPR-2015-10068
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
          open window cts71m00s at 04,02 with form "cts71m00"
                                attribute(form line 1)

          #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
    display "(F3)Referencia (F6)Historico (F9)Conclui  (CTRL+F)Todas as Funcoes"
                  to msgfun

             if ws.flag_acesso = 0 then # acesso teleperformance
                #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
                let mr_teclas.func01 = "<F3> Referencia"
                let mr_teclas.func02 = "<F6> Historico"
             else
                #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
                let mr_teclas.func01 = "<F1> Help"
                let mr_teclas.func02 = "<F2> Retorno"
                let mr_teclas.func03 = "<F3> Referencia"
                let mr_teclas.func04 = "<F4> Multiplo"
                let mr_teclas.func05 = "<F5> Venda/F.Pag"
                let mr_teclas.func06 = "<F6> Historico"
                let mr_teclas.func07 = "<F7> Impressao"
                let mr_teclas.func08 = "<F9> Conclui"
                let mr_teclas.func09 = "<CTRL+T> Etapa"
                let mr_teclas.func10 = "<CTRL+E> E-mail"
                let mr_teclas.func11 = "<CTRL+O> Correspond"
                let mr_teclas.func12 = "<CTRL+U> Justificat"  #=> SPR-2015-10068
             end if
       else
          let ws_tela = "MLT" ##abrindo tela exibindo multiplo
          open window cts71m00m at 04,02 with form "cts71m00"
                                attribute(form line 1)

          #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
    display "(F3)Referencia (F6)Historico (F9)Conclui  (CTRL+F)Todas as Funcoes"
                  to msgfun

             if ws.flag_acesso = 0 then # acesso teleperformance
                #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
                let mr_teclas.func01 = "<F3> Referencia"
                let mr_teclas.func02 = "<F6> Historico"
             else
                #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
                let mr_teclas.func01 = "<F1> Help"
                let mr_teclas.func02 = "<F2> Retorno"
                let mr_teclas.func03 = "<F3> Referencia"
                let mr_teclas.func04 = "<F5> Venda/F.Pag"
                let mr_teclas.func05 = "<F6> Historico"
                let mr_teclas.func06 = "<F7> Impressao"
                let mr_teclas.func07 = "<F9> Conclui"
                let mr_teclas.func08 = "<CTRL+T> Etapa"
                let mr_teclas.func09 = "<CTRL+E> E-mail"
                let mr_teclas.func10 = "<CTRL+O> Correspond"
                let mr_teclas.func11 = "<CTRL+U> Justificat"  #=> SPR-2015-10068
             end if
      end if
 end if

let w_cts71m00.ligcvntip  =  g_documento.ligcvntip

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
    call cts71m00_copia()
    initialize g_documento.atdsrvnum,
               g_documento.atdsrvano to null
 end if

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then

    call consulta_cts71m00()

    display by name d_cts71m00.srvnum     #- PSI SPR-2014-28503
    display by name d_cts71m00.prpnumdsp  #- PSI SPR-2014-28503
    display by name d_cts71m00.c24solnom
    display by name d_cts71m00.nom
    display by name d_cts71m00.nscdat	    #- SPR-2015-03912-Cadastro Clientes
    display by name d_cts71m00.srvpedcod  #- SPR-2015-03912-Cadastro Pedidos
    display by name d_cts71m00.corsus
    display by name d_cts71m00.cornom
    display by name d_cts71m00.orrdat
    display by name d_cts71m00.servicorg
    display by name d_cts71m00.socntzcod
    display by name d_cts71m00.socntzdes
    display by name d_cts71m00.c24pbmcod
    display by name d_cts71m00.atddfttxt
    display by name d_cts71m00.asitipcod
    display by name d_cts71m00.asitipabvdes
    display by name d_cts71m00.imdsrvflg
    display by name d_cts71m00.atdprinvlcod
    display by name d_cts71m00.atdprinvldes
    display by name d_cts71m00.atdlibflg
    display by name d_cts71m00.prslocflg
    display by name d_cts71m00.atdtxt
    display by name d_cts71m00.srvretmtvcod
    display by name d_cts71m00.srvretmtvdes
    display by name d_cts71m00.espcod
    display by name d_cts71m00.espdes
    display by name d_cts71m00.retprsmsmflg

    display by name d_cts71m00.c24solnom attribute (reverse)

    display by name d_cts71m00.espdes
    display by name a_cts71m00[1].lgdtxt,
                    a_cts71m00[1].lclbrrnom,
                    a_cts71m00[1].cidnom,
                    a_cts71m00[1].ufdcod,
                    a_cts71m00[1].lclrefptotxt,
                    a_cts71m00[1].endzon,
                    a_cts71m00[1].dddcod,
                    a_cts71m00[1].lcltelnum,
                    a_cts71m00[1].lclcttnom,
                    a_cts71m00[1].celteldddcod,
                    a_cts71m00[1].celtelnum,
                    a_cts71m00[1].endcmp


    if w_cts71m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"
       let m_srv_acionado = true
    else
       if g_pss.psscntcod is not null  then

           call cts03g00 (3, "",
                             "",
                             "",
                             "",
                             "",
                             g_documento.atdsrvnum ,
                             g_documento.atdsrvano )
       end if
    end if

    if d_cts71m00.srvretmtvcod is not null then
       display d_cts71m00.srvretmtvcod to srvretmtvcod
       display d_cts71m00.srvretmtvdes to srvretmtvdes
    end if

    call modifica_cts71m00() returning ws.grvflg

    ## para o porto socorro sair do laudo sem abrir o historico
    # N�o abrir o historico de servico para a consulta laudo PET
    if ws_acaorigem <> "RAD" and
       g_issk.dptsgl <> 'psocor' then
       call cts40g03_data_hora_banco(2) returning m_data, m_hora
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat, m_data, m_hora)

       let g_rec_his = true
       let g_documento.acao = "ALT"

    end if
 else

#--- SPR-2015-03912-Cadastro Clientes ---
#    if  g_pss.psscntcod  is not null then
#        let d_cts71m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
#    end if

#--------------------------------------------------------------------
# Monta CABECALHO do laudo
#--------------------------------------------------------------------

    let d_cts71m00.c24solnom = g_documento.solnom
    let d_cts71m00.prslocflg = "N"

    display by name d_cts71m00.srvnum    #- PSI SPR-2014-28503
    display by name d_cts71m00.prpnumdsp #- PSI SPR-2014-28503
    display by name d_cts71m00.c24solnom
    display by name d_cts71m00.nom
#--  display by name d_cts71m00.doctxt   #- SPR-2015-03912-Cadastro Clientes
    display by name d_cts71m00.nscdat	   #- SPR-2015-03912-Cadastro Clientes
    display by name d_cts71m00.srvpedcod #- SPR-2015-03912-Cadastro Pedidos
    display by name d_cts71m00.corsus
    display by name d_cts71m00.cornom
    display by name d_cts71m00.orrdat
    display by name d_cts71m00.servicorg
    display by name d_cts71m00.socntzcod
    display by name d_cts71m00.socntzdes
    display by name d_cts71m00.c24pbmcod
    display by name d_cts71m00.atddfttxt
    display by name d_cts71m00.asitipcod
    display by name d_cts71m00.asitipabvdes
    display by name d_cts71m00.imdsrvflg
    display by name d_cts71m00.atdprinvlcod
    display by name d_cts71m00.atdprinvldes
    display by name d_cts71m00.atdlibflg
    display by name d_cts71m00.prslocflg
    display by name d_cts71m00.atdtxt
    display by name d_cts71m00.srvretmtvcod
    display by name d_cts71m00.srvretmtvdes
    display by name d_cts71m00.espcod
    display by name d_cts71m00.espdes
    display by name d_cts71m00.retprsmsmflg

    display by name d_cts71m00.c24solnom attribute (reverse)



    open c_cts71m00_003
    whenever error continue
    fetch c_cts71m00_003 into l_grlinf
    whenever error stop

    if sqlca.sqlcode <> 0 then

       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT igbkgeral :',sqlca.sqlcode,'|',sqlca.sqlerrd[2]
          clear form
          if ws_tela = "RET" then
             close window cts71m00r
          else
             if ws_tela = "SRV" then
                close window cts71m00s
             else
                close window cts71m00m
             end if
          end if

          let int_flag = false

          return
       end if
    end if

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para o contrato
    #--------------------------------------------------------------------
    if ws_acao is not null and
       ws_acao =  "RET"    then
       # Solicitacao do (RET)orno
    else
       if  g_pss.psscntcod  is not null  then

           call cts03g00 (3, "" ,
                             "" ,
                             "" ,
                             "" ,
                             "" ,
                             g_documento.atdsrvnum ,
                             g_documento.atdsrvano )
       end if
    end if

    call inclui_cts71m00() returning ws.grvflg

    if ws.grvflg = true  then

       call cts40g03_data_hora_banco(2) returning m_data, m_hora
       let w_cts71m00.atddat  = m_data
       let w_cts71m00.atdhor = m_hora

       call cts10n00(w_cts71m00.atdsrvnum, w_cts71m00.atdsrvano,
                     w_cts71m00.funmat   , w_cts71m00.atddat   ,
                     w_cts71m00.atdhor)

       call cts17m03_incluir_hist(w_cts71m00.atdsrvnum, w_cts71m00.atdsrvano )
            returning m_resultado, m_mensagem

       if m_resultado <> 1 then
          error m_mensagem
       end if

       call cts17m03_envio_email("",
                                 g_documento.c24astcod,
                                 g_documento.ligcvntip,
                                 "",
                                 "",
                                 "",
                                 w_cts71m00.lignum,
                                 w_cts71m00.atdsrvnum,
                                 w_cts71m00.atdsrvano,
                                 "",
                                 "",
                                 g_documento.solnom )

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------

       whenever error continue
       open c_cts71m00_004 using w_cts71m00.atdsrvnum,
                                 w_cts71m00.atdsrvano,
                                 w_cts71m00.atdsrvnum,
                                 w_cts71m00.atdsrvano
       fetch c_cts71m00_004  into ws.atdetpcod
       whenever error stop

       if ws.atdetpcod    <> 3   and    # servico etapa concluida RE
          ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado

          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          whenever error continue
          execute p_cts71m00_005 using w_cts71m00.atdsrvnum,
                                       w_cts71m00.atdsrvano
          whenever error stop

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
            call cts00g07_apos_servdesbloqueia(w_cts71m00.atdsrvnum,w_cts71m00.atdsrvano)
          end if

          #------------------------------------------------------
          #// Desbloqueio de servicos para os laudos multiplos
          #------------------------------------------------------
          let l_nulo = null
          whenever error continue
          open c_cts71m00_061 using w_cts71m00.atdsrvnum
                                , w_cts71m00.atdsrvano
          whenever error stop
          foreach c_cts71m00_061 into l_atdmltsrvnum, l_atdmltsrvano

               whenever error continue
               execute p_cts71m00_062 using l_nulo, l_atdmltsrvnum, l_atdmltsrvano
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
 #acionar servi�o para o prestador -- independente se � INC ou ALT

 if m_veiculo_aciona is not null then

    whenever error continue
    open c_cts71m00_063 using m_veiculo_aciona
    fetch c_cts71m00_063 into l_socacsflg
                           ,l_c24opemat
    whenever error stop
    close c_cts71m00_063

    whenever error continue
    open c_cts71m00_064 using m_veiculo_aciona
    fetch c_cts71m00_064 into l_c24atvcod
    whenever error stop

    close c_cts71m00_064


    if l_socacsflg = 1      and  # Verifica se o veiculo esta bloqueado pelo acn imd do laudo
       l_c24opemat = 999997 and
       l_c24atvcod = 'QRV'  then

        if g_documento.acao is null then
           let l_servico = w_cts71m00.atdsrvnum
           let l_ano =  w_cts71m00.atdsrvano
        else

           if m_confirma_alt_prog = "S" then
              let l_servico = m_servico_original ## para acionar os multiplos
              let l_ano = m_ano_original
           else
              let l_servico = g_documento.atdsrvnum
              let l_ano = g_documento.atdsrvano
           end if

        end if

        call cts41g01_acionaServicoImediato(m_veiculo_aciona, l_servico, l_ano)
             returning m_resultado

        call cts40g06_desb_veic(m_veiculo_aciona,999997)
             returning m_resultado
        let m_veiculo_aciona = null

        ## p/acompanhar os casos em que aciona viatura fora da distancia limite
        call cts71m00_ac(l_servico, l_ano)

    else
        call cts40g06_desb_veic(m_veiculo_aciona,999997)
             returning m_resultado
        let m_veiculo_aciona = null
    end if

 end if

 #cancelamento de um servico para um servico ainda nao acionado
  if ws_acao = 'CAN' then
     # Funcao que substituiu a "cts71m00_cancela"
     # Sera utilizada tambem para o Servico do Portal
     call ctf00m03(g_documento.atdsrvnum
                  ,g_documento.atdsrvano
                  ,m_atdfnlflg)
 end if

 if ws_tela = "RET" then
    close window cts71m00r
 else
    if ws_tela = "SRV" then
       close window cts71m00s
    else
       close window cts71m00m
    end if

 end if

end function  ###  cts71m00

#--------------------------------------------------------------------
 function consulta_cts71m00()
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
    empcod            like datmservico.empcod                         #Raul, Biz
 end record


 #--- SPR-2015-03912-Cadastro Clientes ---
 define lr_retcli  record
    coderro        smallint
   ,msgerro        char(80)
   ,clinom         like datksrvcli.clinom
   ,nscdat         like datksrvcli.nscdat
 end record

 #--- SPR-2015-03912-Cadastro Pedidos ---
 define lr_retped  record
    coderro        smallint
   ,msgerro        char(80)
   ,srvpedcod      like datmsrvped.srvpedcod
 end record


 define l_espsit      like dbskesp.espsit   #PSI195138
 define l_c24astcod   like datkassunto.c24astcod
 define l_cgccpf      char(12)
 define l_resultado   smallint
 define l_mensagem    char(60)
 define l_c24endtip   like datmlcl.c24endtip #--- PSI SPR-2014-28503-Endereco correspondencia
 define promptX       char(1)

 define l_errcod   smallint
       ,l_errmsg   char(80)

 initialize l_errcod, l_errmsg to null
 initialize lr_aux.*      to null
 initialize mr_salva, ws  to null

 let d_cts71m00.espcod = null
 let l_cgccpf          = null
 let l_resultado       = null
 let l_mensagem        = null
 let l_c24endtip       = null


 whenever error continue
 open c_cts71m00_006 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts71m00_006 into d_cts71m00.nom      ,
                           d_cts71m00.cornom   ,
                           d_cts71m00.corsus   ,
                           d_cts71m00.atddfttxt,
                           ws.funmat           ,
                           d_cts71m00.asitipcod,
                           w_cts71m00.atddat   ,
                           w_cts71m00.atdhor   ,
                           d_cts71m00.atdlibflg,
                           w_cts71m00.atdlibhor,
                           w_cts71m00.atdlibdat,
                           w_cts71m00.atdhorpvt,
                           w_cts71m00.atdpvtretflg,
                           w_cts71m00.atddatprg,
                           w_cts71m00.atdhorprg,
                           w_cts71m00.atdfnlflg,
                           d_cts71m00.atdprinvlcod,
                           ws.atdprscod,
                           d_cts71m00.prslocflg,
                           m_acntntqtd,
                           g_documento.ciaempcod,
                           ws.empcod                                  #Raul, Biz
whenever error stop

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if
 close c_cts71m00_006


 let m_atddatprg_aux = w_cts71m00.atddatprg #-SPR-2016-01943
 let m_atdhorprg_aux = w_cts71m00.atdhorprg #-SPR-2016-01943

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



 let m_atdfnlflg = w_cts71m00.atdfnlflg

 whenever error continue
 open c_cts71m00_007 using  g_documento.atdsrvnum,
                            g_documento.atdsrvano
 fetch c_cts71m00_007 into d_cts71m00.lclrsccod,
                           d_cts71m00.orrdat   ,
                           d_cts71m00.socntzcod,
                           cpl_atdsrvnum,
                           cpl_atdsrvano,
                           d_cts71m00.srvretmtvcod,
                           d_cts71m00.espcod,
                           d_cts71m00.retprsmsmflg
 whenever error stop

 if sqlca.sqlcode = notfound  then
    error " Socorro Ramos Elementares nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 close c_cts71m00_007

 initialize d_cts71m00.servicorg  to null
 if cpl_atdsrvnum is not null then
    let cpl_atdsrvorg = 09
    let d_cts71m00.servicorg  = cpl_atdsrvorg using "&&",
                                "/", cpl_atdsrvnum using "&&&&&&&",
                                "-", cpl_atdsrvano using "&&"
 end if

#--------------------------------------------------------------------
# Informacoes do motivo retorno
#--------------------------------------------------------------------
 initialize d_cts71m00.srvretmtvdes to null
 if d_cts71m00.srvretmtvcod is not null then

    if d_cts71m00.srvretmtvcod = 999  then
       whenever error continue
       open c_cts71m00_008 using g_documento.atdsrvnum,
                                 g_documento.atdsrvano
       fetch c_cts71m00_008 into d_cts71m00.srvretmtvdes
       whenever error stop

    else
       whenever error continue
       open c_cts71m00_009 using d_cts71m00.srvretmtvcod
       fetch c_cts71m00_009 into d_cts71m00.srvretmtvdes
       whenever error stop
    end if

    close c_cts71m00_008
    close c_cts71m00_009


    display "Mtv.Ret. :" to cpltela
    display "Acionar mesmo Prestador? " to cplPrest
 end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            1)
                  returning a_cts71m00[1].lclidttxt   ,
                            a_cts71m00[1].lgdtip      ,
                            a_cts71m00[1].lgdnom      ,
                            a_cts71m00[1].lgdnum      ,
                            a_cts71m00[1].lclbrrnom   ,
                            a_cts71m00[1].brrnom      ,
                            a_cts71m00[1].cidnom      ,
                            a_cts71m00[1].ufdcod      ,
                            a_cts71m00[1].lclrefptotxt,
                            a_cts71m00[1].endzon      ,
                            a_cts71m00[1].lgdcep      ,
                            a_cts71m00[1].lgdcepcmp   ,
                            a_cts71m00[1].lclltt      ,
                            a_cts71m00[1].lcllgt      ,
                            a_cts71m00[1].dddcod      ,
                            a_cts71m00[1].lcltelnum   ,
                            a_cts71m00[1].lclcttnom   ,
                            a_cts71m00[1].c24lclpdrcod,
                            a_cts71m00[1].celteldddcod,
                            a_cts71m00[1].celtelnum,
                            a_cts71m00[1].endcmp   ,
                            ws.cogidosql, a_cts71m00[1].emeviacod


    whenever error continue
    let l_c24endtip = 1    #--- PSI SPR-2014-28503-endereco correspondencia

    open c_cts71m00_010 using g_documento.atdsrvano,
                              g_documento.atdsrvnum,
                              l_c24endtip
    fetch c_cts71m00_010 into a_cts71m00[1].ofnnumdig
    whenever error stop

    if ws.cogidosql <> 0  then
       error " Erro (", ws.cogidosql using "<<<<<&", ") na leitura local de ocorrencia. AVISE A INFORMATICA!"
              return
    end if

    let a_cts71m00[1].lgdtxt = a_cts71m00[1].lgdtip clipped, " ",
                               a_cts71m00[1].lgdnom clipped, " ",
                               a_cts71m00[1].lgdnum using "<<<<#"


#--->>> PSI SPR-2014-28503 - Endereco de correspondencia
#--------------------------------------------------------------------
# Informacoes do local da correspondencia
#--------------------------------------------------------------------
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            7)
                  returning a_cts71m00[2].lclidttxt   ,
                            a_cts71m00[2].lgdtip      ,
                            a_cts71m00[2].lgdnom      ,
                            a_cts71m00[2].lgdnum      ,
                            a_cts71m00[2].lclbrrnom   ,
                            a_cts71m00[2].brrnom      ,
                            a_cts71m00[2].cidnom      ,
                            a_cts71m00[2].ufdcod      ,
                            a_cts71m00[2].lclrefptotxt,
                            a_cts71m00[2].endzon      ,
                            a_cts71m00[2].lgdcep      ,
                            a_cts71m00[2].lgdcepcmp   ,
                            a_cts71m00[2].lclltt      ,
                            a_cts71m00[2].lcllgt      ,
                            a_cts71m00[2].dddcod      ,
                            a_cts71m00[2].lcltelnum   ,
                            a_cts71m00[2].lclcttnom   ,
                            a_cts71m00[2].c24lclpdrcod,
                            a_cts71m00[2].celteldddcod,
                            a_cts71m00[2].celtelnum,
                            a_cts71m00[2].endcmp   ,
                            ws.cogidosql, a_cts71m00[2].emeviacod

    let a_cts71m00[2].lgdtxt = a_cts71m00[2].lgdtip clipped, " ",
                               a_cts71m00[2].lgdnom clipped, " ",
                               a_cts71m00[2].lgdnum using "<<<<#"
#---<<< PSI SPR-2014-28503 - Endereco de correspondencia


 let d_cts71m00.socntzdes = "*** NAO CADASTRADA ***"

 whenever error continue
 open c_cts71m00_011 using d_cts71m00.socntzcod
 fetch c_cts71m00_011 into d_cts71m00.socntzdes
 whenever error stop

 # busca descricao especialidade
 let d_cts71m00.espdes = null
 if d_cts71m00.espcod is not null then

    #como so quero buscar a descricao, nao importando a situacao da
    # especialidade (ativo ou nao), passo null para a funcao

    let l_espsit = null
    call cts31g00_descricao_esp(d_cts71m00.espcod, l_espsit)
         returning d_cts71m00.espdes

    if d_cts71m00.espdes is null then
       error "Descricao nao encontrada para especialidade."
    end if
 end if

 let d_cts71m00.asitipabvdes = "NAO PREV"

 whenever error continue

 open c_cts71m00_012 using d_cts71m00.asitipcod
 fetch c_cts71m00_012 into d_cts71m00.asitipabvdes

 whenever error stop

 close c_cts71m00_012

#--------------------------------------------------------------------
# Identificacao do SOLICITANTE/CONVENIO
#--------------------------------------------------------------------

 let w_cts71m00.lignum =
     cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)


 call cts20g01_docto(w_cts71m00.lignum)
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

 call cts20g01_docto_tot(w_cts71m00.lignum)
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

#--- SPR-2015-03912-Cadastro Clientes ---
# if g_pss.psscntcod    is not null  then
#    let d_cts71m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
# end if


#--------------------------------------------------------------------
# Informacoes do cliente --- SPR-2015-03912-Cadastro Clientes ---
#--------------------------------------------------------------------
 call opsfa014_conscadcli(g_documento.cgccpfnum,
                          g_documento.cgcord,
                          g_documento.cgccpfdig)
                returning lr_retcli.coderro
                         ,lr_retcli.msgerro
                         ,lr_retcli.clinom
                         ,lr_retcli.nscdat

 if lr_retcli.coderro = false then
    let lr_retcli.nscdat = null
    let lr_retcli.clinom = null
    error lr_retcli.msgerro clipped
    prompt "Erro ao Carregar Cadastro de Clientes  - Avise Inform�tica " for char promptX
 end if

 let d_cts71m00.nscdat = lr_retcli.nscdat
 #--- SPR-2015-03912-Cadastro Clientes ---

 #--------------------------------------------------------------------
 # Informacoes do pedido #--- SPR-2015-03912-Cadastro Pedidos ---
 #--------------------------------------------------------------------

 call opsfa015_conscadped(g_documento.atdsrvnum,
                          g_documento.atdsrvano)
      returning lr_retped.coderro
               ,lr_retped.msgerro
               ,lr_retped.srvpedcod

 if lr_retped.coderro = false then
    if lr_retped.msgerro is null or
    	 lr_retped.msgerro = " " then
       error "NAO HA PEDIDO CADASTRADO PARA ESTE SERVICO"
    else
       let lr_retped.srvpedcod = null
       error lr_retped.msgerro clipped
       prompt "Erro ao Consultar Pedido  - Avise Inform�tica " for char promptX
    end if
 end if

 let d_cts71m00.srvpedcod = lr_retped.srvpedcod
 #--- SPR-2015-03912-Cadastro Pedidos ---


 #===========================================================================
 #Ler assunto, pois qdo entro pelo radio nao tenho nenhum assunto selecionado
 #===========================================================================
 whenever error continue

 open c_cts71m00_013 using w_cts71m00.lignum
 fetch c_cts71m00_013 into d_cts71m00.c24solnom,
                           w_cts71m00.ligcvntip,
                           l_c24astcod

 whenever error stop

 close c_cts71m00_013
 #===========================================================================
 #caso seja RET nao substituo o assunto, pois o cts40g12 tem tratamento
 #especifico para retorno e nao posso enviar o assunto original
 #===========================================================================

 if g_documento.acao <> "RET" then
    if  g_documento.c24astcod is null  then
        let g_documento.c24astcod = l_c24astcod
    end if
 end if


 let g_documento.solnom = d_cts71m00.c24solnom

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"


 whenever error continue

 open c_cts71m00_014 using ws.empcod,                                 #Raul, Biz
                           ws.funmat
 fetch c_cts71m00_014 into ws.funnom, ws.dptsgl

 whenever error stop

 close c_cts71m00_014



 let d_cts71m00.atdtxt = w_cts71m00.atddat           , " ",
                         w_cts71m00.atdhor           , " ",
                         upshift(ws.dptsgl)   clipped, " ",
                         ws.funmat  using "&&&&&&"   , " ",
                         upshift(ws.funnom)   clipped, " ",
                         w_cts71m00.atdlibdat        , " ",
                         w_cts71m00.atdlibhor

 if w_cts71m00.atdhorpvt is not null  or
    w_cts71m00.atdhorpvt  = "00:00"   then
    let d_cts71m00.imdsrvflg = "S"
 end if

 if w_cts71m00.atddatprg is not null  then
    let d_cts71m00.imdsrvflg = "N"
 end if

 let w_cts71m00.atdlibflg = d_cts71m00.atdlibflg

 if d_cts71m00.atdlibflg = "N"  then
    let w_cts71m00.atdlibdat = w_cts71m00.atddat
    let w_cts71m00.atdlibhor = w_cts71m00.atdhor
 end if

 let d_cts71m00.srvnum = g_documento.atdsrvorg using "&&",
                    "/", g_documento.atdsrvnum using "&&&&&&&",
                    "-", g_documento.atdsrvano using "&&"

 #=> SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
 if g_documento.prpnum is null then
    let d_cts71m00.prpnumdsp = " "
 else
    let d_cts71m00.prpnumdsp = "29/", g_documento.prpnum using "&&&&&&&&"
 end if

 whenever error continue
 open c_cts71m00_015 using d_cts71m00.atdprinvlcod
 fetch c_cts71m00_015 into d_cts71m00.atdprinvldes
 whenever error stop
 close c_cts71m00_015

 whenever error continue
 open c_cts71m00_016 using g_documento.atdsrvnum,
                           g_documento.atdsrvano

 fetch c_cts71m00_016 into d_cts71m00.c24pbmcod

 whenever error stop

 close c_cts71m00_016


 let mr_salva.lgdnom    = a_cts71m00[1].lgdnom
 let mr_salva.lgdnum    = a_cts71m00[1].lgdnum
 let mr_salva.brrnom    = a_cts71m00[1].brrnom
 let mr_salva.lclbrrnom = a_cts71m00[1].lclbrrnom
 let mr_salva.cidnom    = a_cts71m00[1].cidnom
 let mr_salva.ufdcod    = a_cts71m00[1].ufdcod
 let mr_salva.lgdcep    = a_cts71m00[1].lgdcep
 let mr_salva.lclltt    = a_cts71m00[1].lclltt
 let mr_salva.imdsrvflg = d_cts71m00.imdsrvflg
 let mr_salva.atddatprg = w_cts71m00.atddatprg
 let mr_salva.atdhorprg = w_cts71m00.atdhorprg
 let mr_salva.atdlibdat = w_cts71m00.atdlibdat
 let mr_salva.atdlibhor = w_cts71m00.atdlibhor
 let mr_salva.c24lclpdrcod = a_cts71m00[1].c24lclpdrcod

whenever error continue
 open c_cts71m00_017 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts71m00_017 into ms.atdsrvseq
whenever error stop
close c_cts71m00_017


whenever error continue
 open c_cts71m00_018 using g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           ms.atdsrvseq
 fetch c_cts71m00_018 into ms.atdetpcod
whenever error stop
close c_cts71m00_018

 let m_c24lclpdrcod = a_cts71m00[1].c24lclpdrcod

 let m_subbairro[1].lclbrrnom = a_cts71m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts71m00[1].brrnom,
                                a_cts71m00[1].lclbrrnom)
      returning a_cts71m00[1].lclbrrnom

end function

#--------------------------------------------------------------------
 function modifica_cts71m00()
#--------------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    cogidosql        integer,
    tabname          like systables.tabname
 end record

 define hist_cts71m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

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

 define lr_retorno             record
         resultado              smallint,
         mensagem               char(100)
   end record

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

 define r_retorno_sku   record   #- SPR-2015-13708-Melhorias Calculo SKU
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg  #- SPR-2016-03565
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record

 define lr_opsfa023    record
        retorno        smallint
       ,mensagem       char(100)
 end record 


 define prompt_key    char (01)
 define l_contador    smallint,
        l_atdsrvseq like datmsrvacp.atdsrvseq
       ,l_errcod   smallint
       ,l_errmsg   char(80)
 define l_c24endtip like datmlcl.c24endtip
 define l_srvpedcod like datmsrvped.srvpedcod #--- SPR-2015-03912-Cad Pedidos --
 initialize l_errcod, l_errmsg  to null

 let l_contador  = null
 let prompt_key  = null
 let l_atdsrvseq = null
 let l_c24endtip = null  #--- PSI SPR-2014-28503-Endereco correspondencia
 let m_pbmonline = null  #--- PSI SPR-2014-28503 - Venda Online
 let l_srvpedcod = null  #--- SPR-2015-03912-Cadastro de Pedidos ---

 initialize  r_retorno_sku to null #- SPR-2015-13708-Melhorias Calculo SKU
 initialize  lr_retorno.*  to  null
 initialize  ws.*          to  null
 initialize  hist_cts71m00.*  to  null
 initialize ws.*  to null
 initialize lr_opsfa023.* to null

 let l_dadosPagamento = true
 let m_pbmonline = null  #--- PSI SPR-2014-28503 - Venda online

 #=> SPR-2014-28503 - VER SE POSSUI 'VENDA' ASSOCIADA
 if not opsfa006_ha_venda(g_documento.atdsrvnum,
                          g_documento.atdsrvano) then
    if sqlca.sqlcode < 0 then
       prompt "" for char prompt_key
       return false
    end if

    #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
    call opsfa001_conskupbr(d_cts71m00.c24pbmcod
                           ,w_cts71m00.atddat)
         returning r_retorno_sku.catcod
                  ,r_retorno_sku.pgtfrmcod
                  ,r_retorno_sku.srvprsflg #- SPR-2016-03565
                  ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                  ,r_retorno_sku.msg_erro

    if cts71m00_verifica_solicitante() then   #--- PSI SPR-2014-28503-Venda online
       #-- Indica que se trata de e_commerce
       let m_pbmonline = r_retorno_sku.catcod #- SPR-2015-13708-Melhorias Calculo SKU
       let m_vendaflg = false
    else
    	 #- Indica que n�o se trata de e_commerce. Enviar null no SKU (m_pbmonline)
       if sqlca.sqlcode < 0 then
          prompt "" for char prompt_key
          return false
       end if
       let m_vendaflg = false
    end if
 else
    let m_vendaflg = true
 end if

 #=> SPR-2014-28503 - VERIFICA SE ASSUNTO PERMITE VENDA/F.PAGTO
 whenever error continue
 open c_cts71m00_002 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts71m00_002 into m_c24astcodflag
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
          " AO ACESSAR 'datmligacao'!!!"
    prompt "" for char prompt_key
    return false
 end if
 let cty27g00_ret = cty27g00_consiste_ast(m_c24astcodflag)

 call input_cts71m00() returning hist_cts71m00.*

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
    initialize a_cts71m00      to null
    initialize d_cts71m00.*    to null
    initialize w_cts71m00.*    to null
    clear form
    return false
 end if

 if a_cts71m00[1].lclltt is null or
    a_cts71m00[1].lclltt = 0 or
    a_cts71m00[1].lcllgt is null or
    a_cts71m00[1].lcllgt = 0 then
    let m_atdfnlflg = "N"
 end if

 whenever error continue

 begin work

 if m_imdsrvflg_ant <> d_cts71m00.imdsrvflg and
    g_documento.acao = "ALT" then

    call cts40g03_data_hora_banco(2) returning m_data, m_hora

    let w_cts71m00.atdlibdat = m_data
    let w_cts71m00.atdlibhor = m_hora

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
 execute p_cts71m00_019 using  d_cts71m00.nom,
                               d_cts71m00.cornom,
                               d_cts71m00.corsus,
                               d_cts71m00.atddfttxt,
                               d_cts71m00.atdlibflg,
                               w_cts71m00.atdlibhor,
                               w_cts71m00.atdlibdat,
                               w_cts71m00.atdhorpvt,
                               w_cts71m00.atdpvtretflg,
                               w_cts71m00.atddatprg,
                               w_cts71m00.atdhorprg,
                               d_cts71m00.asitipcod,
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
                        d_cts71m00.c24pbmcod,
                        d_cts71m00.atddfttxt,
                        ""                  ) # Codigo prestador
        returning ws.cogidosql, ws.tabname

   if ws.cogidosql <> 0 then
      error "ctx09g02_altera", ws.cogidosql, ws.tabname
      rollback work
      prompt "" for char prompt_key
      return false
   end if

 whenever error continue
 execute p_cts71m00_020 using d_cts71m00.lclrsccod
                              ,d_cts71m00.orrdat
                              ,d_cts71m00.socntzcod
                              ,d_cts71m00.espcod
                              ,d_cts71m00.srvretmtvcod
                              ,d_cts71m00.retprsmsmflg
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
 execute p_cts71m00_021 using g_documento.atdsrvnum,
                              g_documento.atdsrvano
 whenever error stop


 if d_cts71m00.srvretmtvcod is not null  and
    d_cts71m00.srvretmtvcod  =  999      then

     whenever error continue
     execute p_cts71m00_022 using g_documento.atdsrvnum
                                 ,g_documento.atdsrvano
                                 ,d_cts71m00.srvretmtvdes
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

 if a_cts71m00[1].operacao is null  then
    let a_cts71m00[1].operacao = "M"
 end if

 let a_cts71m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

 call cts06g07_local(a_cts71m00[1].operacao,
                     g_documento.atdsrvnum,
                     g_documento.atdsrvano,
                     1,
                     a_cts71m00[1].lclidttxt,
                     a_cts71m00[1].lgdtip,
                     a_cts71m00[1].lgdnom,
                     a_cts71m00[1].lgdnum,
                     a_cts71m00[1].lclbrrnom,
                     a_cts71m00[1].brrnom,
                     a_cts71m00[1].cidnom,
                     a_cts71m00[1].ufdcod,
                     a_cts71m00[1].lclrefptotxt,
                     a_cts71m00[1].endzon,
                     a_cts71m00[1].lgdcep,
                     a_cts71m00[1].lgdcepcmp,
                     a_cts71m00[1].lclltt,
                     a_cts71m00[1].lcllgt,
                     a_cts71m00[1].dddcod,
                     a_cts71m00[1].lcltelnum,
                     a_cts71m00[1].lclcttnom,
                     a_cts71m00[1].c24lclpdrcod,
                     a_cts71m00[1].ofnnumdig,
                     a_cts71m00[1].emeviacod,
                     a_cts71m00[1].celteldddcod,
                     a_cts71m00[1].celtelnum,
                     a_cts71m00[1].endcmp)
           returning ws.cogidosql

 if ws.cogidosql is null   or
    ws.cogidosql <> 0      then
    error " Erro (", ws.cogidosql, ") no local. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

#----------------------------- #--->>> PSI SPR-2014-28503 - Endereco de corresp.
# Atualiza locais de correspondencia
#-----------------------------

 if a_cts71m00[2].operacao is null  then
    whenever error continue
    let l_c24endtip = 7

    open c_cts71m00_010 using g_documento.atdsrvano,
                              g_documento.atdsrvnum,
                              l_c24endtip
    fetch c_cts71m00_010 into a_cts71m00[2].ofnnumdig

    whenever error stop
    if sqlca.sqlcode = 0  then
       let a_cts71m00[2].operacao = "M"
    else
       if sqlca.sqlcode = 100 then
          let a_cts71m00[2].operacao = "I"
       else
          error " Erro (", ws.cogidosql using "<<<<<&", ") na leitura local de ocorrencia(upd). AVISE A INFORMATICA!"
          return
       end if
    end if
 end if

 let a_cts71m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

 call cts06g07_local(a_cts71m00[2].operacao,
                     g_documento.atdsrvnum,
                     g_documento.atdsrvano,
                     7, #--- Tp Endereco correspondencia
                     a_cts71m00[2].lclidttxt,
                     a_cts71m00[2].lgdtip,
                     a_cts71m00[2].lgdnom,
                     a_cts71m00[2].lgdnum,
                     a_cts71m00[2].lclbrrnom,
                     a_cts71m00[2].brrnom,
                     a_cts71m00[2].cidnom,
                     a_cts71m00[2].ufdcod,
                     a_cts71m00[2].lclrefptotxt,
                     a_cts71m00[2].endzon,
                     a_cts71m00[2].lgdcep,
                     a_cts71m00[2].lgdcepcmp,
                     a_cts71m00[2].lclltt,
                     a_cts71m00[2].lcllgt,
                     a_cts71m00[2].dddcod,
                     a_cts71m00[2].lcltelnum,
                     a_cts71m00[2].lclcttnom,
                     a_cts71m00[2].c24lclpdrcod,
                     a_cts71m00[2].ofnnumdig,
                     a_cts71m00[2].emeviacod,
                     a_cts71m00[2].celteldddcod,
                     a_cts71m00[2].celtelnum,
                     a_cts71m00[2].endcmp)
           returning ws.cogidosql

 if ws.cogidosql is null   or
    ws.cogidosql <> 0      then
    error " Erro (", ws.cogidosql, ") no local de correspondencia. ",
          "AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if
#---<<< PSI SPR-2014-28503 - Endereco de correspondencia

 if w_cts71m00.atdlibflg <> d_cts71m00.atdlibflg  then
    if d_cts71m00.atdlibflg = "S"  then
       let w_cts71m00.atdetpcod = 1
    else
       let w_cts71m00.atdetpcod = 2
    end if

    call cts10g04_insere_etapa (g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                w_cts71m00.atdetpcod ,
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

 #--- SPR-2015-03912-Cadastro de Clientes --- #=> SPR-2015-11582 - S/TIP.PESSOA
 call opsfa014_inscadcli(g_documento.cgccpfnum
                        ,g_documento.cgcord
                        ,g_documento.cgccpfdig
                        ,d_cts71m00.nom
                        ,d_cts71m00.nscdat
                        ,"")
      returning lr_retorno.resultado
               ,lr_retorno.mensagem
 if lr_retorno.resultado = false then
    rollback work
    error lr_retorno.mensagem clipped
    prompt "ERRO NA ATUALIZACAO CADASTRO CLIENTE. AVISE INFORMATICA"
           for char prompt_key
    return false
 end if
 #--- SPR-2015-03912-Cadastro de Clientes ---

 #--- SPR-2015-03912-Atualiza Pedido ---
 if m_vendaflg or
    m_pbmonline is not null then  #- PSI SPR-2014-28503 - Venda Online

    #--- SPR-2015-03912-Inclui Pedido ---
    call opsfa015_inscadped(g_documento.cgccpfnum
                           ,g_documento.cgcord
                           ,g_documento.cgccpfdig
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,"1") #--- Online - SPR-2015-22413)
         returning lr_retorno.resultado
                  ,lr_retorno.mensagem
                  ,l_srvpedcod
    if lr_retorno.resultado = false then
       rollback work
       error lr_retorno.mensagem clipped
       prompt "ERRO NA ATUALIZACAO DO PEDIDO. AVISE INFORMATICA"
              for char prompt_key
       return false
    end if
 end if
 #--- SPR-2015-03912-Atualiza Pedido ---

 whenever error stop
 #CT-2014-14110/IN
     #---------------------------------------------
     # Grava Formas de Pagamento psi-2012-22101
     #---------------------------------------------

     #let cty27g00_ret = 0
     #
     #call cty27g00_consiste_ast(g_documento.c24astcod)
     #     returning cty27g00_ret
     #if cty27g00_ret = 1 then
     #
     #   call cty27g00_entrada_dados(g_documento.prpnum,
     #                               g_documento.atdsrvnum,
     #                               g_documento.atdsrvano)
     #   let g_documento.prpnum_flg = ""
     #end if
  #fim CT-2014-14110/IN

    #valida novamente se servico vai para acionamento autom�tico
    #-----------------------------------------------
    # Aciona Servico automaticamente
    #-----------------------------------------------

    if (g_documento.acao = "RET" and d_cts71m00.retprsmsmflg = 'N') or
       m_veiculo_aciona is not null then
       #e retorno  and deseja outro prestador? OU nao tem veiculo pronto para atender?
       #servico nao sera acionado automaticamente
    else
       ## Se alterou o endereco, altear nos multiplos tambem
       call cts71m00_alt_end(m_obter_mult
                            ,m_servico_original
                            ,m_ano_original)
             returning m_resultado
                      ,m_mensagem

       #chamar funcao que verifica se acionamento pode ser feito
       # verifica se servico para cidade e internet ou GPS e se esta ativo
       #retorna true para acionamento e false para nao acionamento

       if cts34g00_acion_auto (g_documento.atdsrvorg,
                               a_cts71m00[1].cidnom,
                               a_cts71m00[1].ufdcod) then

          #funcao cts34g00_acion_auto verificou que parametrizacao para origem
          # do servico esta OK
          #chamar funcao para validar regras gerais se um servico sera acionado
          # automaticamente ou nao e atualizar datmservico

          if not cts40g12_regras_aciona_auto (
                               g_documento.atdsrvorg,
                               g_documento.c24astcod,
                               "",
                               a_cts71m00[1].lclltt,
                               a_cts71m00[1].lcllgt,
                               d_cts71m00.prslocflg,
                               "N",#d_cts71m00.frmflg,
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


 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

 #=> SPR-2014-28503 - GRAVACAO DA FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
{
    #---------------------------------------------
    # Grava Formas de Pagamento CT-2014-14110/IN
    #---------------------------------------------
    let cty27g00_ret = 0
    call cty27g00_consiste_ast(g_documento.c24astcod)
        returning cty27g00_ret
    if cty27g00_ret = 1 then
      call cty27g00_entrada_dados(g_documento.prpnum,
                                  g_documento.atdsrvnum,
                                  g_documento.atdsrvano)
      let g_documento.prpnum_flg = ""
    end if
}

   if (m_atddatprg_aux <> w_cts71m00.atddatprg  or
       m_atdhorprg_aux <> w_cts71m00.atdhorprg) then
      call opsfa023_emailposvenda(g_documento.atdsrvnum,
                                  g_documento.atdsrvano)
            returning lr_opsfa023.retorno,    
                      lr_opsfa023.mensagem   
                    
      if lr_opsfa023.retorno = false then                       
         error lr_opsfa023.mensagem clipped                     
      end if     
    end if 

 #---> Data de Fechamento - PSI SPR-2015-03912   ---
 call opsfa006_atualdtfecha(g_documento.atdsrvnum
                           ,g_documento.atdsrvano)
      returning lr_retorno.*
 if lr_retorno.resultado = false then
    error lr_retorno.mensagem clipped
    prompt "ERRO AO ATUALIZAR DATA ATENDIMENTO NA VENDA. AVISE INFORMATICA"
           for prompt_key
    return false
 end if

 # PSI-2013-00440PR
 if m_agendaw = true
    then
    ##-- SPR-2015-15533 - Inicio
    let g_documento.c24pbmcod    = d_cts71m00.c24pbmcod
    let g_documento.atddfttxt    = d_cts71m00.atddfttxt clipped
    let g_documento.socntzcod    = d_cts71m00.socntzcod
    let g_documento.socntzdes    = d_cts71m00.socntzdes clipped
    ##-- SPR-2015-15533 - Fim

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



 return true

end function  ###  modifica_cts71m00

#-------------------------------------------------------------------------------
 function cts71m00_verifica_solicitante() #--- PSI SPR-2014-28503 - Venda online
#-------------------------------------------------------------------------------
 define l_c24soltipcod  like datmligacao.c24soltipcod

 open c_cts71m00_071 using g_documento.atdsrvnum
                          ,g_documento.atdsrvano

 whenever error continue
 #--- datmligacao - captura solicitante
 fetch c_cts71m00_071 into l_c24soltipcod

 whenever error stop
  if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       error 'Erro SELECT c_cts71m00_071: ' ,sqlca.sqlcode,' / ',
             sqlca.sqlerrd[2] sleep 2
       return false
    end if
    let l_c24soltipcod = null
 end if


 open c_cts71m00_072 using l_c24soltipcod

 whenever error continue
 #--- iddkdominio - verifica venda online
 fetch c_cts71m00_072

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       error 'Erro SELECT c_cts71m00_072: ' ,sqlca.sqlcode,' / ',
             sqlca.sqlerrd[2] sleep 2
       return false
    else  #--- notfound iddkdominio
       open c_cts71m00_073 using l_c24soltipcod

       whenever error continue
       #--- datkdominio - verifica venda online
       fetch c_cts71m00_073

       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             error 'Erro SELECT c_cts71m00_073: ' ,sqlca.sqlcode,' / ',
                   sqlca.sqlerrd[2] sleep 2
             return false
          end if
       end if
    end if
 end if

 return true

end function
#-------------------------------------------------------------------------------
 function inclui_cts71m00()
#-------------------------------------------------------------------------------

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

 ###PSI-2012-22101
 define lr_frm_pagamento record
        crtnum                like datmcrdcrtinf.crtnum,
        crtnumPainel          char(4)
 end record

 define l_ret1      smallint,
        l_msg1      char(60)

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

 define hist_cts71m00   record
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

 define lr_retcrip record
        coderro         smallint
       ,msgerro         char(10000)
       ,pcapticrpcod    like fcomcaraut.pcapticrpcod
 end record

 define l_txtsrv        char (15)
      , l_reserva_ativa smallint # Flag para idenitficar se reserva esta ativa
      , l_errcod         smallint
      , l_errmsg         char(80)

 initialize  ws.*             to  null
 initialize  hist_cts71m00.*  to  null

 initialize l_ret1, l_msg1 to null

 initialize l_ind, l_dadosPagamento, l_cartaoCripto, l_count to null
 initialize lr_frm_pagamento.* to null
 initialize lr_pagamento.* to null
 initialize lr_cartao.*    to null

 let l_confirma = "N"

 let l_dadosPagamento = true

 #=> SPR-2014-28503 - VERIFICA SE ASSUNTO PERMITE VENDA/F.PAGTO

 let cty27g00_ret = cty27g00_consiste_ast(g_documento.c24astcod)
 if cty27g00_ret = 1 then
    let m_vendaflg = true
 else
    let m_vendaflg = false
 end if

 while true
   initialize ws.*  to null
   initialize am_param to null

   let g_documento.acao = "INC"

   if ws_acao = "RET" then
      let d_cts71m00.retprsmsmflg = "S"
   end if

   call input_cts71m00() returning hist_cts71m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize d_cts71m00.*    to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts71m00.atddat is null  then

       call cts40g03_data_hora_banco(2) returning m_data, m_hora
       let w_cts71m00.atddat    = m_data
       let w_cts71m00.atdhor    = m_hora
   end if

   if  w_cts71m00.funmat is null  then
       let w_cts71m00.funmat    = g_issk.funmat
   end if

   initialize ws.caddat to null
   initialize ws.cadhor to null
   initialize ws.cademp to null
   initialize ws.cadmat to null
   initialize l_resultado to null
   let ms.* = ws.*
   let mr_hist.* = hist_cts71m00.*

   if  w_cts71m00.atdfnlflg is null  then
       let w_cts71m00.atdfnlflg = "N"
       let w_cts71m00.c24opemat = g_issk.funmat
   end if

   call cts71m00_grava_dados(d_cts71m00.socntzcod,
                             d_cts71m00.espcod,
                             d_cts71m00.c24pbmcod,
                             d_cts71m00.atddfttxt, '', '')
        returning l_resultado, l_mensagem, ws.atdsrvnum,
                  ws.atdsrvano, l_lignum

  if l_resultado <> 1 then
     error l_mensagem
  else
     for l_for = 1 to 10
         if am_param[l_for].socntzcod is null then
            exit for
         end if
         call cts71m00_grava_dados(am_param[l_for].socntzcod,
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

     let g_documento.lignum   = l_lignum
     let w_cts71m00.atdsrvnum = ws.atdsrvnum
     let w_cts71m00.atdsrvano = ws.atdsrvano

          # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao
     #                    ainda ativa e fazer a baixa da chave no AW
     let l_txtsrv = "SRV ", w_cts71m00.atdsrvnum, "-", w_cts71m00.atdsrvano

     if m_agendaw = true
        then
        if m_operacao = 1  # obteve chave de regulacao
           then
           ##-- SPR-2015-15533 - Inicio
           let g_documento.c24pbmcod    = d_cts71m00.c24pbmcod
           let g_documento.atddfttxt    = d_cts71m00.atddfttxt clipped
           let g_documento.socntzcod    = d_cts71m00.socntzcod
           let g_documento.socntzdes    = d_cts71m00.socntzdes clipped

           ##-- SPR-2015-15533 - Fim

           if l_resultado = 1  # sucesso na gravacao do servico
              then
              call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa

              if l_reserva_ativa = true
                 then
                 #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW'
                 call ctd41g00_baixar_agenda(m_rsrchv, w_cts71m00.atdsrvano, w_cts71m00.atdsrvnum)
                      returning l_errcod, l_errmsg
              else
               #display "Chave de regulacao inativa, selecione agenda novamente"
                 error "Chave de regulacao inativa, selecione agenda novamente"

                 let m_operacao = 0
                 # obter a chave de regulacao no AW
                #display 'entrada'
                #DISPLAY 'g_documento.atdsrvorg :',g_documento.atdsrvorg
                #DISPLAY 'd_cts71m00.asitipcod  :',d_cts71m00.asitipcod
                #DISPLAY 'd_cts71m00.socntzcod  :',d_cts71m00.socntzcod
                #DISPLAY 'd_cts71m00.espcod     :',d_cts71m00.espcod

                #display '---------------------------------------------'

                 call cts02m08(w_cts71m00.atdfnlflg,
                               d_cts71m00.imdsrvflg,
                               m_altcidufd,
                               d_cts71m00.prslocflg,
                               w_cts71m00.atdhorpvt,
                               w_cts71m00.atddatprg,
                               w_cts71m00.atdhorprg,
                               w_cts71m00.atdpvtretflg,
                               m_rsrchv,
                               m_operacao,
                               "",
                               a_cts71m00[1].cidnom,
                               a_cts71m00[1].ufdcod,
                               "",  # codigo de assistencia, nao existe no Ct24h
                               "",   # codigo do veiculo, somente Auto
                               "",   # categoria tarifaria, somente Auto
                               d_cts71m00.imdsrvflg,
                               a_cts71m00[1].c24lclpdrcod,
                               a_cts71m00[1].lclltt,
                               a_cts71m00[1].lcllgt,
                               g_documento.ciaempcod,
                               g_documento.atdsrvorg,
                               d_cts71m00.asitipcod,
                               d_cts71m00.socntzcod, # natureza
                               d_cts71m00.espcod)    # sub-natureza
                     returning w_cts71m00.atdhorpvt,
                               w_cts71m00.atddatprg,
                               w_cts71m00.atdhorprg,
                               w_cts71m00.atdpvtretflg,
                               d_cts71m00.imdsrvflg,
                               m_rsrchv,
                               m_operacao,
                               m_altdathor
                 if m_operacao = 1
                    then
                    #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW - apos nova chave'
                    call ctd41g00_baixar_agenda(m_rsrchv, w_cts71m00.atdsrvano ,w_cts71m00.atdsrvnum)
                         returning l_errcod, l_errmsg
                 end if
              end if

              if l_errcod = 0
                 then
                 call cts02m08_ins_cota(m_rsrchv, w_cts71m00.atdsrvnum, w_cts71m00.atdsrvano)
                      returning l_errcod, l_errmsg

                 if l_errcod = 0
                    then
                    #display 'cts02m08_ins_cota gravou com sucesso'
                 else
                    #display 'cts02m08_ins_cota erro ', l_errcod
                    display l_errmsg clipped
                 end if
              else
                 display 'cts71m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
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

              call ctd41g00_liberar_agenda(w_cts71m00.atdsrvano, w_cts71m00.atdsrvnum
                                         , m_agncotdat, m_agncothor)
           end if
        end if
     end if
     # PSI-2013-00440PR


     let d_cts71m00.srvnum = g_documento.atdsrvorg using "&&",
                             "/", w_cts71m00.atdsrvnum using "&&&&&&&",
                             "-", w_cts71m00.atdsrvano using "&&"
     display by name d_cts71m00.srvnum  attribute (reverse)

     #=> SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
     if mr_prop.prpnum is null then
        let d_cts71m00.prpnumdsp = " "
     else
        let d_cts71m00.prpnumdsp = "29/", mr_prop.prpnum using "&&&&&&&&"
     end if
     display by name d_cts71m00.prpnumdsp attribute (reverse)

     #=> SPR-2015-11582 - EXIBE NUMERO DO PEDIDO
     display by name d_cts71m00.srvpedcod

     error  " Verifique o numero do servico, da proposta e tecle ENTER!"
     prompt "" for char ws.prompt_key

     error " Inclusao efetuada com sucesso!"
     let ws.retorno = true

 #=> SPR-2014-28503 - GRAVACAO DA FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
{
     #---------------------------------------------
     # Grava Formas de Pagamento psi-2012-22101
     #---------------------------------------------
     let cty27g00_ret = 0
     call cty27g00_consiste_ast(g_documento.c24astcod)
          returning cty27g00_ret
     if cty27g00_ret = 1 then
        call cty27g00_entrada_dados(g_documento.prpnum,
                                    w_cts71m00.atdsrvnum,
                                    w_cts71m00.atdsrvano)
        let g_documento.prpnum_flg = ""
     end if
}

     # Aqui -------------------------------------------------------------
     #--------------------------------------------------------------------------
     # Grava HISTORICO do servico - Informa��es pagamento
     #--------------------------------------------------------------------------
     let lr_pagamento.orgnum = 29              #=> SPR-2014-28503 - MELHORIA
     let lr_pagamento.prpnum = mr_prop.prpnum  #=> SPR-2014-28503 - MELHORIA
     whenever error continue
     open c_cts71m00_067 using mr_prop.prpnum  #=> SPR-2014-28503 - MELHORIA
     fetch c_cts71m00_067 into lr_pagamento.pgtfrmcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           error 'Erro SELECT c_cts71m00_067: ' ,sqlca.sqlcode,' / ',
                 sqlca.sqlerrd[2]
           sleep 2
        end if
        let l_dadosPagamento= false
     end if

     if l_dadosPagamento = true then
	  open c_cts71m00_069 using lr_pagamento.pgtfrmcod

	  whenever error continue
	  fetch c_cts71m00_069 into lr_pagamento.pgtfrmdes

	  whenever error stop
	  if sqlca.sqlcode <> 0 then
	     error 'Erro SELECT c_cts71m00_069: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	     let l_dadosPagamento= false
	  end if

     end if

     if lr_pagamento.pgtfrmcod = 1 and
        l_dadosPagamento = true then
	     open c_cts71m00_068 using lr_pagamento.orgnum,
	  			       lr_pagamento.prpnum,
                                       lr_pagamento.orgnum,
                                       lr_pagamento.prpnum

	     whenever error continue
	     fetch c_cts71m00_068 into lr_cartao.clinom,
	     			       lr_cartao.crtnum,
	  			       lr_cartao.bndcod,
	  			       lr_cartao.crtvlddat,
	  			       lr_cartao.cbrparqtd
	     whenever error stop
	     if sqlca.sqlcode <> 0 then
	        error 'Erro SELECT c_cts71m00_068: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	        let l_dadosPagamento= false
	     end if

             ########Decriptografar cart�o e pegar apenas �ltimos 4 digitos
             # Descriptografa o numero do cartao
             initialize lr_retcrip.* to null
             call ffctc890("D",lr_cartao.crtnum  )
                  returning lr_retcrip.*

             let lr_frm_pagamento.crtnumPainel = lr_retcrip.pcapticrpcod[13,16]
             let l_cartaoCripto = lr_frm_pagamento.crtnumPainel
             let lr_frm_pagamento.crtnum = "Numero Cartao: ",lr_frm_pagamento.crtnumPainel

	     if l_dadosPagamento = true then
		     open c_cts71m00_070 using lr_cartao.bndcod

		     whenever error continue
		     fetch c_cts71m00_070 into lr_cartao.bnddes

		     whenever error stop
		     if sqlca.sqlcode <> 0 then
		        error 'Erro SELECT c_cts71m00_070: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
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
	      let la_historico[5].descricao = 'BANDEIRA CART�O: ',lr_cartao.bnddes clipped
	      let la_historico[6].descricao = 'VALIDADE CART�O: ', lr_cartao.crtvlddat
	      let la_historico[7].descricao = 'QUANTIDADE PARCELAS: ',lr_cartao.cbrparqtd
  	   end if

  	   for l_ind = 1 to l_count
  		call ctd07g01_ins_datmservhist(w_cts71m00.atdsrvnum,
                               		       w_cts71m00.atdsrvano,
  					       g_issk.funmat,
  					       la_historico[l_ind].descricao,
  					       w_cts71m00.atddat,
                                               w_cts71m00.atdhor,
                                               g_issk.empcod,
                                               g_issk.usrtip)
                returning l_ret1,
                          l_msg1
                if l_ret1 <> 1  then
                   error l_msg1, " - cts71m00 - AVISE A INFORMATICA!" sleep 3
                   exit for
                end if

  	   end for

     end if


     # Aqui -------------------------------------------------------------


     ##---------------------------------------------
     ## Grava Formas de Pagamento psi-2012-22101
     ##---------------------------------------------
     #call cty27g00_consiste_ast(g_documento.c24astcod)
     #     returning cty27g00_ret
     #
     #if cty27g00_ret = 1 then
     #   call cty27g00_grv_srv(g_documento.prpnum,
     #                         w_cts71m00.atdsrvnum,
     #                         w_cts71m00.atdsrvano)
     #        returning cty27g00_ret
     #   if cty27g00_ret = 1 then
     #      error " Inclusao efetuada com sucesso!"
     #   else
     #      error " Problemas na atualizacao da Forma de Pagamento!"
     #      prompt "" for char ws.prompt_key
     #   end if
     #end if
     ## psi-2012-22101

     # Envio de SMS
     let l_confirma = "S"

     #======================================
     # Grava flag de envio de email
     #======================================

     call cts10g02_atualiza_flg_email(w_cts71m00.atdsrvnum,
                                      w_cts71m00.atdsrvano,
                                      l_confirma)
          returning l_resultado
                   ,l_mensagem

     if l_resultado <> 0 then
        error l_mensagem
     end if

     exit while
  end if

 end while

 return ws.retorno

end function  ###  inclui_cts71m00

#--------------------------------------------------------------------
function input_cts71m00()
#--------------------------------------------------------------------

   define l_confirma char(1)

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

   define dS_cts71m00   record
      srvnum            char (13)                    ,
      prpnumdsp         char (11)                    , #=> SPR-2014-28503
      c24solnom         like datmligacao.c24solnom   ,
      nom               like datmservico.nom         ,
#--   doctxt            char (32)                    ,  #--- SPR-2015-03912-Cadastro Clientes ---
      nscdat            like datksrvcli.nscdat ,        #--- SPR-2015-03912-Cadastro Clientes ---
      srvpedcod         like datmsrvped.srvpedcod    ,  #--- SPR-2015-03912-Cadastro Pedidos  ---
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

   define wS_cts71m00   record
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
      atzendereco       dec(1,0),
      cartao            char(21),
      atdrsdflg         like datmservico.atdrsdflg
   end record

   define aS_cts71m00   record
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

   define hist_cts71m00 record
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

   define l_vendaflg      smallint                #=> SPR-2014-28503
   define l_prompt_key    char(1)                 #--->>> SPR-2014-28503
   define l_c24endtip     like datmlcl.c24endtip  #--- PSI SPR-2014-28503-Endereco correspondencia
   define lr_retorno record
          resultado smallint
         ,mensagem  char(60)
   end record


   #--- SPR-2015-03912-Cadastro Clientes ---
   define lr_retcli     record
          coderro        smallint
         ,msgerro        char(80)
         ,clinom         like datksrvcli.clinom
         ,nscdat         like datksrvcli.nscdat
   end record


   define lvalidaretorno  record
      noprazoflg   char(1),
      mensagem1    char(40),
      mensagem2    char(40)
   end record

  define r_retorno_sku   record   #- SPR-2015-13708-Melhorias Calculo SKU
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg  #- SPR-2016-03565
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record

   define l_idade     integer  #--- SPR-2015-03912-Cadastro Clientes ---

   define l_c24opemat like datmservico.c24opemat

   define l_atdetpcod like datmsrvacp.atdetpcod

   define l_atdlibflg like datmservico.atdlibflg

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
   initialize  dS_cts71m00.*  to  null
   initialize  wS_cts71m00.*  to  null
   initialize  aS_cts71m00.*  to  null
   initialize  hist_cts71m00.*  to  null
   initialize  m_wk.* to null
   initialize lr_email.* to null
   initialize l_confirma to null
   initialize lr_retcli.* to null     #- SPR-2015-03912-Cadastro Clientes
   initialize r_retorno_sku.* to null #- SPR-2015-13708-Melhorias Calculo SKU

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
   let ws.lclcttnom            = a_cts71m00[1].lclcttnom
   let ws.lclrscflg            = d_cts71m00.lclrscflg
   let d_cts71m00.atdprinvlcod = 2  # SEMPRE 2-NORMAL
   let d_cts71m00.atdprinvldes = "NAO EXISTE"
   let m_veiculo_aciona        = null
   let ml_srvabrprsinfflg      = "N"
   let l_natagdflg = null
   let l_c24endtip = null  #--- PSI SPR-2014-28503-Endereco correspondencia
   let l_idade = 0         #--- SPR-2015-03912-Cadastro Clientes ---

   whenever error continue

   open c_cts71m00_015 using d_cts71m00.atdprinvlcod
   fetch c_cts71m00_015 into d_cts71m00.atdprinvldes

   whenever error stop


   #//Fixar 6 - RE no asitipcod
   let d_cts71m00.asitipcod = 6

   open c_cts71m00_023 using d_cts71m00.asitipcod
   whenever error continue
   fetch c_cts71m00_023 into d_cts71m00.asitipabvdes
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> 100 then
         error 'Erro de SQL c_cts71m00_103 ',sqlca.sqlcode,'/'
         return hist_cts71m00.*
      else
         let d_cts71m00.asitipabvdes = null
      end if
   end if

   let l_obter_qrv = true

   display by name d_cts71m00.atdprinvlcod
   display by name d_cts71m00.atdprinvldes
   display by name d_cts71m00.asitipcod
   display by name d_cts71m00.asitipabvdes

   # INICIO PSI-2013-7115
   # display 'cts71m00'
   # display 'dados da global do laudo:'
   # display 'ga_dct               : ', ga_dct
   # display 'g_documento.acao     : ', g_documento.acao
   # display 'g_documento.atdsrvorg: ', g_documento.atdsrvorg
   # display 'g_documento.atdsrvnum: ', g_documento.atdsrvnum
   # display 'g_documento.atdsrvano: ', g_documento.atdsrvano
   # display 'g_documento.cgccpfnum: ', g_documento.cgccpfnum
   # display 'g_documento.cgcord   : ', g_documento.cgcord
   # display 'g_documento.cgccpfdig: ', g_documento.cgccpfdig
   # display 'g_documento.ligcvntip: ', g_documento.ligcvntip
   # display 'g_documento.succod   : ', g_documento.succod
   # display 'g_documento.ramcod   : ', g_documento.ramcod
   # display 'g_documento.aplnumdig: ', g_documento.aplnumdig
   # display 'g_documento.itmnumdig: ', g_documento.itmnumdig
   # display 'g_documento.edsnumref: ', g_documento.edsnumref


   if upshift(g_documento.acao) = "INC" and  (ga_dct > 0 and ga_dct is not null)
      then
      call cts08g01("A","S","","EXISTEM DADOS DO CLIENTE NA BASE","DESEJA UTILIZAR ?","")
      returning ws.confirma

      let  mr_grava_sugest = 'N'

      if ws.confirma = "S" then
         call ctc68m00_dados_tela() returning m_sel

         if m_sel is not null and m_sel > 0
            then
            let a_cts71m00[1].lclcttnom    = ga_dados_saps[m_sel].segnom
            let a_cts71m00[1].lgdtip       = ga_dados_saps[m_sel].lgdtip
            let a_cts71m00[1].lgdnom       = ga_dados_saps[m_sel].lgdnom
            let a_cts71m00[1].lgdtxt       = ga_dados_saps[m_sel].lgdtxt
            let a_cts71m00[1].lgdnum       = ga_dados_saps[m_sel].lgdnum
            let a_cts71m00[1].lclbrrnom    = ga_dados_saps[m_sel].brrnom
            let a_cts71m00[1].cidnom       = ga_dados_saps[m_sel].cidnom
            let a_cts71m00[1].ufdcod       = ga_dados_saps[m_sel].ufdcod
            let a_cts71m00[1].endcmp       = ga_dados_saps[m_sel].endcmp
            let a_cts71m00[1].lclrefptotxt = ga_dados_saps[m_sel].lclrefptotxt
            let a_cts71m00[1].lgdcep       = ga_dados_saps[m_sel].lgdcep
            let a_cts71m00[1].lgdcepcmp    = ga_dados_saps[m_sel].lgdcepcmp
            let a_cts71m00[1].celteldddcod = ga_dados_saps[m_sel].celteldddcod
            let a_cts71m00[1].celtelnum    = ga_dados_saps[m_sel].celtelnum
            let a_cts71m00[1].dddcod       = ga_dados_saps[m_sel].dddcod
            let a_cts71m00[1].lcltelnum    = ga_dados_saps[m_sel].lcltelnum

            let d_cts71m00.nom             = ga_dados_saps[m_sel].segnom
            let d_cts71m00.corsus          = ga_dados_saps[m_sel].corsus
            let d_cts71m00.cornom          = ga_dados_saps[m_sel].cornom

            display by name d_cts71m00.nom          #--- PSI SPR-2014-28503
#---         display by name d_cts71m00.doctxt      #--- SPR-2015-03912-Cadastro Clientes ---
            display by name d_cts71m00.nscdat       #--- SPR-2015-03912-Cadastro Clientes ---
            display by name d_cts71m00.srvpedcod    #--- SPR-2015-03912-Cadastro Pedidos ---
            display by name d_cts71m00.corsus
            display by name d_cts71m00.cornom
            display by name d_cts71m00.orrdat
            display by name d_cts71m00.servicorg
            display by name d_cts71m00.socntzcod
            display by name d_cts71m00.socntzdes
            display by name d_cts71m00.c24pbmcod
            display by name d_cts71m00.atddfttxt
            display by name d_cts71m00.asitipcod
            display by name d_cts71m00.asitipabvdes
            display by name d_cts71m00.imdsrvflg
            display by name d_cts71m00.atdprinvlcod
            display by name d_cts71m00.atdprinvldes
            display by name d_cts71m00.atdlibflg
            display by name d_cts71m00.prslocflg
            display by name d_cts71m00.atdtxt
            display by name d_cts71m00.srvretmtvcod
            display by name d_cts71m00.srvretmtvdes
            display by name d_cts71m00.espcod
            display by name d_cts71m00.espdes
            display by name d_cts71m00.retprsmsmflg

#----

            display by name a_cts71m00[1].lclcttnom,
                            a_cts71m00[1].lgdtxt,
                            a_cts71m00[1].lclbrrnom,
                            a_cts71m00[1].cidnom,
                            a_cts71m00[1].ufdcod,
                            a_cts71m00[1].endcmp,
                            a_cts71m00[1].lclrefptotxt,
                            a_cts71m00[1].celteldddcod,
                            a_cts71m00[1].celtelnum,
                            a_cts71m00[1].dddcod,
                            a_cts71m00[1].lcltelnum

            let  mr_grava_sugest = 'S'

            # display 'cts71m00: DADOS ENVIADOS PARA O LAUDO'
            # display 'Index: ', m_sel
            # display 'a_cts71m00[1].lclcttnom   ' , a_cts71m00[1].lclcttnom
            # display 'a_cts71m00[1].lgdtip      ' , a_cts71m00[1].lgdtip
            # display 'a_cts71m00[1].lgdnom      ' , a_cts71m00[1].lgdnom
            # display 'a_cts71m00[1].lgdtxt      ' , a_cts71m00[1].lgdtxt
            # display 'a_cts71m00[1].lgdnum      ' , a_cts71m00[1].lgdnum
            # display 'a_cts71m00[1].lclbrrnom   ' , a_cts71m00[1].lclbrrnom
            # display 'a_cts71m00[1].cidnom      ' , a_cts71m00[1].cidnom
            # display 'a_cts71m00[1].ufdcod      ' , a_cts71m00[1].ufdcod
            # display 'a_cts71m00[1].endcmp      ' , a_cts71m00[1].endcmp
            # display 'a_cts71m00[1].lclrefptotxt' , a_cts71m00[1].lclrefptotxt
            # display 'a_cts71m00[1].lgdcep      ' , a_cts71m00[1].lgdcep
            # display 'a_cts71m00[1].lgdcepcmp   ' , a_cts71m00[1].lgdcepcmp
            # display 'a_cts71m00[1].celteldddcod' , a_cts71m00[1].celteldddcod
            # display 'a_cts71m00[1].celtelnum   ' , a_cts71m00[1].celtelnum
            # display 'a_cts71m00[1].dddcod      ' , a_cts71m00[1].dddcod
            # display 'a_cts71m00[1].lcltelnum   ' , a_cts71m00[1].lcltelnum
            # display 'd_cts71m00.nom            ' , d_cts71m00.nom
            # display 'd_cts71m00.corsus         ' , d_cts71m00.corsus
            # display 'd_cts71m00.cornom         ' , d_cts71m00.cornom

         end if
      end if
   end if
   #FIM PSI-2013-01775

   let l_vendaflg = m_vendaflg         #=> SPR-2014-28503

   # PSI-2013-00440PR
   if g_documento.acao = "INC"
      then
      let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
   else
      let m_operacao = 5  # na consulta considera liberado para nao regular novamente
      #display 'consulta, considerar cota ja regulada'
   end if

   # situacao original do servico
   let m_imdsrvflg = d_cts71m00.imdsrvflg
   let m_cidnom = a_cts71m00[1].cidnom
   let m_ufdcod = a_cts71m00[1].ufdcod
   # PSI-2013-00440PR





   input by name d_cts71m00.nom      , #- PSI SPR-2014-28503
                 d_cts71m00.nscdat   , #- SPR-2015-03912-Cadastro clientes
                 d_cts71m00.srvpedcod, #- SPR-2015-03912-Cadastro Pedidos
                 d_cts71m00.corsus   ,
                 d_cts71m00.cornom   ,
                 d_cts71m00.socntzcod,
                 d_cts71m00.espcod,
                 d_cts71m00.c24pbmcod,
                 d_cts71m00.prslocflg, #- SPR-2015-15533-Fechamento Servicos GPS
                 d_cts71m00.atddfttxt,
                 ws.lclcttnom        ,
                 d_cts71m00.orrdat   ,
                 d_cts71m00.srvretmtvcod,
                 d_cts71m00.srvretmtvdes,
                 d_cts71m00.retprsmsmflg,
                 d_cts71m00.atdlibflg,
                 d_cts71m00.imdsrvflg   without defaults

   before field nom
          if ws_acao is not null and
             ws_acao =  "RET"    then
             next field lclcttnom
          end if

          #--- SPR-2015-03912-Cadastro Clientes ---
          if g_documento.acao = "INC" then
             call opsfa014_conscadcli(g_documento.cgccpfnum,
                                      g_documento.cgcord,
                                      g_documento.cgccpfdig)
                            returning lr_retcli.coderro
                                     ,lr_retcli.msgerro
                                     ,lr_retcli.clinom
                                     ,lr_retcli.nscdat
             if lr_retcli.coderro = false then
                let lr_retcli.nscdat = null
                let lr_retcli.clinom = null
                error lr_retcli.msgerro clipped
                prompt "Erro ao Consultar Cadastro de Clientes - Avise ",
                       "Inform�tica " for char l_prompt_key
             end if
             if lr_retcli.clinom is not null then
                let d_cts71m00.nom    = lr_retcli.clinom
                let d_cts71m00.nscdat = lr_retcli.nscdat
             end if
          end if

          display by name d_cts71m00.nscdat
          display by name d_cts71m00.nom attribute (reverse)
          #--- SPR-2015-03912-Cadastro Clientes ---

   after  field nom
          display by name d_cts71m00.nom

          if d_cts71m00.nom is null  or
             d_cts71m00.nom =  "  "  then
             error " Nome deve ser informado!"
             next field nom
          end if

          #--- PSI SPR-2015-10068 - Consistir nome composto
          if cts71m00_consiste_nome() = "N" then
             error " Nome tem que ser Composto " sleep 2
             next field nom
          end if

          if w_cts71m00.atdfnlflg = "S"      or
             (ws_acaorigem is not null and ws_acaorigem = "CON") then

             if w_cts71m00.atdfnlflg = "S"  then
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
             if m_agendaw = false then  # regulacao antiga
                call cts02m03(w_cts71m00.atdfnlflg, d_cts71m00.imdsrvflg,
                              w_cts71m00.atdhorpvt, w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg, w_cts71m00.atdpvtretflg)
                    returning w_cts71m00.atdhorpvt, w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg, w_cts71m00.atdpvtretflg
	           else
                call cts02m08(w_cts71m00.atdfnlflg,
                              d_cts71m00.imdsrvflg,
                              m_altcidufd,
                              d_cts71m00.prslocflg,
                              w_cts71m00.atdhorpvt,
                              w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg,
                              w_cts71m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts71m00[1].cidnom,
                              a_cts71m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              "",   # codigo do veiculo, somente Auto
                              "",   # categoria tarifaria, somente Auto
                              d_cts71m00.imdsrvflg,
                              a_cts71m00[1].c24lclpdrcod,
                              a_cts71m00[1].lclltt,
                              a_cts71m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts71m00.asitipcod,
                              d_cts71m00.socntzcod, # natureza
                              d_cts71m00.espcod)    # sub-natureza
                    returning w_cts71m00.atdhorpvt,
                              w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg,
                              w_cts71m00.atdpvtretflg,
                              d_cts71m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             # FIM PSI-2013-00440PR
             let int_flag = true
             exit input
          end if

   #--- SPR-2015-03912-Cadastro Clientes ---
   before field nscdat
          display by name d_cts71m00.nscdat attribute (reverse)

   after field nscdat
          display by name d_cts71m00.nscdat

          if (d_cts71m00.nscdat is null or
              d_cts71m00.nscdat = " ") and
              lr_retcli.nscdat is not null then
             let d_cts71m00.nscdat = lr_retcli.nscdat
             error "Data de Nascimento ja Cadastrada nao pode ser Removida"
             next field nscdat
          end if

          if d_cts71m00.nscdat is not null then
             if d_cts71m00.nscdat >= today then
                error "Data de Nascimento Nao pode ser > Data Atual"
                next field nscdat
             end if

             let l_idade = year(today) - year(d_cts71m00.nscdat)

             if l_idade > 110 then
                error "Data de Nascimento Invalida. Maior 110 anos"
                next field nscdat
             end if
          end if
   #--- SPR-2015-03912-Cadastro Clientes ---


   before field corsus

          initialize ws_cgccpfnum, ws_cgccpfdig to null

          if cpl_atdsrvnum is null then

             if g_documento.atdsrvnum is null  and
                g_documento.atdsrvano is null  then

                if g_pss.psscntcod is not null then

                   if l_atdsrvnum is not null then

                      open c_cts71m00_025 using l_atdsrvnum,
                                                l_atdsrvano
                      whenever error continue
                      fetch c_cts71m00_025 into a_cts71m00[1].lgdtip,
                                              a_cts71m00[1].lgdnom,
                                              a_cts71m00[1].lgdnum,
                                              a_cts71m00[1].brrnom,
                                              a_cts71m00[1].lclbrrnom,
                                              a_cts71m00[1].cidnom,
                                              a_cts71m00[1].ufdcod,
                                              a_cts71m00[1].lgdcep,
                                              a_cts71m00[1].lgdcepcmp,
                                              a_cts71m00[1].lclrefptotxt,
                                              a_cts71m00[1].endcmp
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
                      if a_cts71m00[1].endcmp is null or
                         a_cts71m00[1].endcmp = " " then
                         call cts06g03_busca_complemento_apolice()
                              returning a_cts71m00[1].endcmp
                      end if

                   end if
                end if

                let a_cts71m00[1].lgdtxt = a_cts71m00[1].lgdtip clipped, " ",
                                           a_cts71m00[1].lgdnom clipped, " ",
                                           a_cts71m00[1].lgdnum using "<<<<#"

                display by name a_cts71m00[1].lgdtxt,
                                a_cts71m00[1].lclbrrnom,
                                a_cts71m00[1].cidnom,
                                a_cts71m00[1].ufdcod,
                                a_cts71m00[1].lclrefptotxt,
                                a_cts71m00[1].endzon,
                                a_cts71m00[1].dddcod,
                                a_cts71m00[1].lcltelnum,
                                a_cts71m00[1].lclcttnom,
                                a_cts71m00[1].endcmp

                let l_lgdtxt    = a_cts71m00[1].lgdtxt
                let l_lclbrrnom = a_cts71m00[1].lclbrrnom
                let l_cidnom    = a_cts71m00[1].cidnom
                let l_ufdcod    = a_cts71m00[1].ufdcod
             end if
          end if
          display by name d_cts71m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts71m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts71m00.corsus is not null  then
                whenever error continue

                open c_cts71m00_029 using d_cts71m00.corsus
                fetch c_cts71m00_029 into d_cts71m00.cornom

                whenever error stop

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts71m00.cornom
                   next field socntzcod   #--- PSI SPR-2014-28503
                end if
             end if
          end if

   before field cornom
          display by name d_cts71m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts71m00.cornom

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
                next field socntzcod   #--- PSI SPR-2014-28503
             end if
          end if


   before field socntzcod
          display by name d_cts71m00.socntzcod attribute (reverse)
          let l_natureza = d_cts71m00.socntzcod

          if flgcpl = 1  then   #--- PSI SPR-2014-28503
             let flgcpl = 0
             next field orrdat
          end if

          if g_documento.acao = "ALT" then   #- PSI SPR-2014-28503
             display by name d_cts71m00.socntzcod
             display by name d_cts71m00.espcod
             display by name d_cts71m00.c24pbmcod
             display by name d_cts71m00.atddfttxt
             display by name d_cts71m00.prslocflg  #- SPR-2015-15533

             #=> SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA
             if d_cts71m00.c24pbmcod = 999 then  #=> MENOS PARA '999'
                let m_vendaflg = false
             end if
             if m_vendaflg       or
                cty27g00_ret = 1 then  #=> PERMITE F.PAGTO (SEM VENDA=CONSULTA)

                #- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
                call opsfa001_conskupbr(d_cts71m00.c24pbmcod
                                       ,w_cts71m00.atddat)
                     returning r_retorno_sku.catcod
                              ,r_retorno_sku.pgtfrmcod
                              ,r_retorno_sku.srvprsflg   #- SPR-2016-03565
                              ,r_retorno_sku.codigo_erro #- 0=Ok/<> 0=sqlca.sqlcode
                              ,r_retorno_sku.msg_erro

                if r_retorno_sku.codigo_erro = -284 then
                   error "Existe mais de um SKU ativo para este problema!!!"
                   let r_retorno_sku.catcod = null
                   let r_retorno_sku.pgtfrmcod = null
                else
                   if r_retorno_sku.codigo_erro = 100 then  #--- Verifica NotFound
                      error "Nao existe SKU ativo para este problema!!!"
                      let r_retorno_sku.catcod = null
                      let r_retorno_sku.pgtfrmcod = null
                   else
                      if r_retorno_sku.codigo_erro < 0 then
                   	     let int_flag = true
                         error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                               " AO ACESSAR CADASTRO DE SKU 'datksrvcat'!!!" sleep 5
                         exit input
                      end if
                   end if
                end if

                if not opsfa006_altera(g_documento.atdsrvnum
                                      ,g_documento.atdsrvano
                                      ,g_documento.prpnum
                                      ,m_pbmonline             #- SPR-2014-28503
                                      ,0 #- Distancia Ocorr X Destino - SPR-2015-13708
                                      ,w_cts71m00.atddat       #- SPR-2015-13708
                                      ,d_cts71m00.prslocflg    #- SPR-2015-15533
                                      ,d_cts71m00.nom          #- SPR-2015-11582
                                      ,d_cts71m00.nscdat) then #- SPR-2015-11582
                   #- SPR 2015-13708 - Melhorias Calculo SKU
                   next field corsus  #--- Ocorreu erro
                end if
             end if

             let m_acesso_ind = false        #---- PSI SPR-2014-28503
             let m_atdsrvorg = 13
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
             returning m_acesso_ind

             if m_acesso_ind = false then
                call cts06g03(1,
                              13,
                              w_cts71m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts71m00[1].lclidttxt,
                              a_cts71m00[1].cidnom,
                              a_cts71m00[1].ufdcod,
                              a_cts71m00[1].brrnom,
                              a_cts71m00[1].lclbrrnom,
                              a_cts71m00[1].endzon,
                              a_cts71m00[1].lgdtip,
                              a_cts71m00[1].lgdnom,
                              a_cts71m00[1].lgdnum,
                              a_cts71m00[1].lgdcep,
                              a_cts71m00[1].lgdcepcmp,
                              a_cts71m00[1].lclltt,
                              a_cts71m00[1].lcllgt,
                              a_cts71m00[1].lclrefptotxt,
                              a_cts71m00[1].lclcttnom,
                              a_cts71m00[1].dddcod,
                              a_cts71m00[1].lcltelnum,
                              a_cts71m00[1].c24lclpdrcod,
                              a_cts71m00[1].ofnnumdig,
                              a_cts71m00[1].celteldddcod,
                              a_cts71m00[1].celtelnum,
                              a_cts71m00[1].endcmp,
                              hist_cts71m00.*, a_cts71m00[1].emeviacod)
                    returning a_cts71m00[1].lclidttxt,
                              a_cts71m00[1].cidnom,
                              a_cts71m00[1].ufdcod,
                              a_cts71m00[1].brrnom,
                              a_cts71m00[1].lclbrrnom,
                              a_cts71m00[1].endzon,
                              a_cts71m00[1].lgdtip,
                              a_cts71m00[1].lgdnom,
                              a_cts71m00[1].lgdnum,
                              a_cts71m00[1].lgdcep,
                              a_cts71m00[1].lgdcepcmp,
                              a_cts71m00[1].lclltt,
                              a_cts71m00[1].lcllgt,
                              a_cts71m00[1].lclrefptotxt,
                              a_cts71m00[1].lclcttnom,
                              a_cts71m00[1].dddcod,
                              a_cts71m00[1].lcltelnum,
                              a_cts71m00[1].c24lclpdrcod,
                              a_cts71m00[1].ofnnumdig,
                              a_cts71m00[1].celteldddcod,
                              a_cts71m00[1].celtelnum,
                              a_cts71m00[1].endcmp,
                              ws.retflg,
                              hist_cts71m00.*, a_cts71m00[1].emeviacod
                              #display "ws.retflg = ",ws.retflg

                if ws.retflg = "N" then
                   error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos!" sleep 3
                   next field c24pbmcod
                end if

                #--->>> Endereco de correspondencia - PSI SPR-2014-28503
                call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                              "O MESMO DE OCORRENCIA?",l_linha3, l_linha4)
                    returning l_resultado

                if l_resultado = "S" then #- Endereco corresp - SPR-2014-28503
                   let a_cts71m00[2].lclidttxt    = a_cts71m00[1].lclidttxt
                   let a_cts71m00[2].cidnom       = a_cts71m00[1].cidnom
                   let a_cts71m00[2].ufdcod       = a_cts71m00[1].ufdcod
                   let a_cts71m00[2].brrnom       = a_cts71m00[1].brrnom
                   let a_cts71m00[2].lclbrrnom    = a_cts71m00[1].lclbrrnom
                   let a_cts71m00[2].endzon       = a_cts71m00[1].endzon
                   let a_cts71m00[2].lgdtip       = a_cts71m00[1].lgdtip
                   let a_cts71m00[2].lgdnom       = a_cts71m00[1].lgdnom
                   let a_cts71m00[2].lgdnum       = a_cts71m00[1].lgdnum
                   let a_cts71m00[2].lgdcep       = a_cts71m00[1].lgdcep
                   let a_cts71m00[2].lgdcepcmp    = a_cts71m00[1].lgdcepcmp
                   let a_cts71m00[2].lclltt       = a_cts71m00[1].lclltt
                   let a_cts71m00[2].lcllgt       = a_cts71m00[1].lcllgt
                   let a_cts71m00[2].lclrefptotxt = a_cts71m00[1].lclrefptotxt
                   let a_cts71m00[2].lclcttnom    = a_cts71m00[1].lclcttnom
                   let a_cts71m00[2].dddcod       = a_cts71m00[1].dddcod
                   let a_cts71m00[2].lcltelnum    = a_cts71m00[1].lcltelnum
                   let a_cts71m00[2].c24lclpdrcod = a_cts71m00[1].c24lclpdrcod
                   let a_cts71m00[2].ofnnumdig    = a_cts71m00[1].ofnnumdig
                   let a_cts71m00[2].celteldddcod = a_cts71m00[1].celteldddcod
                   let a_cts71m00[2].celtelnum    = a_cts71m00[1].celtelnum
                   let a_cts71m00[2].endcmp       = a_cts71m00[1].endcmp
                else
                   call cts06g03(7,
                                 13,
                                 w_cts71m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts71m00[2].lclidttxt,
                                 a_cts71m00[2].cidnom,
                                 a_cts71m00[2].ufdcod,
                                 a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom,
                                 a_cts71m00[2].endzon,
                                 a_cts71m00[2].lgdtip,
                                 a_cts71m00[2].lgdnom,
                                 a_cts71m00[2].lgdnum,
                                 a_cts71m00[2].lgdcep,
                                 a_cts71m00[2].lgdcepcmp,
                                 a_cts71m00[2].lclltt,
                                 a_cts71m00[2].lcllgt,
                                 a_cts71m00[2].lclrefptotxt,
                                 a_cts71m00[2].lclcttnom,
                                 a_cts71m00[2].dddcod,
                                 a_cts71m00[2].lcltelnum,
                                 a_cts71m00[2].c24lclpdrcod,
                                 a_cts71m00[2].ofnnumdig,
                                 a_cts71m00[2].celteldddcod,
                                 a_cts71m00[2].celtelnum,
                                 a_cts71m00[2].endcmp,
                                 hist_cts71m00.*, a_cts71m00[2].emeviacod)
                       returning a_cts71m00[2].lclidttxt,
                                 a_cts71m00[2].cidnom,
                                 a_cts71m00[2].ufdcod,
                                 a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom,
                                 a_cts71m00[2].endzon,
                                 a_cts71m00[2].lgdtip,
                                 a_cts71m00[2].lgdnom,
                                 a_cts71m00[2].lgdnum,
                                 a_cts71m00[2].lgdcep,
                                 a_cts71m00[2].lgdcepcmp,
                                 a_cts71m00[2].lclltt,
                                 a_cts71m00[2].lcllgt,
                                 a_cts71m00[2].lclrefptotxt,
                                 a_cts71m00[2].lclcttnom,
                                 a_cts71m00[2].dddcod,
                                 a_cts71m00[2].lcltelnum,
                                 a_cts71m00[2].c24lclpdrcod,
                                 a_cts71m00[2].ofnnumdig,
                                 a_cts71m00[2].celteldddcod,
                                 a_cts71m00[2].celtelnum,
                                 a_cts71m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts71m00.*, a_cts71m00[2].emeviacod
                                 #display "ws.retflg = ",ws.retflg
                end if   #---<<<  Endereco de correspondencia - SPR-2014-28503
             else
                call cts06g11(1,
                              13,
                              w_cts71m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts71m00[1].lclidttxt,
                              a_cts71m00[1].cidnom,
                              a_cts71m00[1].ufdcod,
                              a_cts71m00[1].brrnom,
                              a_cts71m00[1].lclbrrnom,
                              a_cts71m00[1].endzon,
                              a_cts71m00[1].lgdtip,
                              a_cts71m00[1].lgdnom,
                              a_cts71m00[1].lgdnum,
                              a_cts71m00[1].lgdcep,
                              a_cts71m00[1].lgdcepcmp,
                              a_cts71m00[1].lclltt,
                              a_cts71m00[1].lcllgt,
                              a_cts71m00[1].lclrefptotxt,
                              a_cts71m00[1].lclcttnom,
                              a_cts71m00[1].dddcod,
                              a_cts71m00[1].lcltelnum,
                              a_cts71m00[1].c24lclpdrcod,
                              a_cts71m00[1].ofnnumdig,
                              a_cts71m00[1].celteldddcod,
                              a_cts71m00[1].celtelnum,
                              a_cts71m00[1].endcmp,
                              hist_cts71m00.*, a_cts71m00[1].emeviacod)
                    returning a_cts71m00[1].lclidttxt,
                              a_cts71m00[1].cidnom,
                              a_cts71m00[1].ufdcod,
                              a_cts71m00[1].brrnom,
                              a_cts71m00[1].lclbrrnom,
                              a_cts71m00[1].endzon,
                              a_cts71m00[1].lgdtip,
                              a_cts71m00[1].lgdnom,
                              a_cts71m00[1].lgdnum,
                              a_cts71m00[1].lgdcep,
                              a_cts71m00[1].lgdcepcmp,
                              a_cts71m00[1].lclltt,
                              a_cts71m00[1].lcllgt,
                              a_cts71m00[1].lclrefptotxt,
                              a_cts71m00[1].lclcttnom,
                              a_cts71m00[1].dddcod,
                              a_cts71m00[1].lcltelnum,
                              a_cts71m00[1].c24lclpdrcod,
                              a_cts71m00[1].ofnnumdig,
                              a_cts71m00[1].celteldddcod,
                              a_cts71m00[1].celtelnum,
                              a_cts71m00[1].endcmp,
                              ws.retflg,
                              hist_cts71m00.*, a_cts71m00[1].emeviacod
                              #display "ws.retflg = ",ws.retflg

                if ws.retflg = "N" then
                   error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos!" sleep 3
                   next field corsus
                end if

                #--->>> Endereco de correspondencia - PSI SPR-2014-28503
                call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                              "O MESMO DE OCORRENCIA?",l_linha3, l_linha4)
                    returning l_resultado

                if l_resultado = "S" then   #---- PSI SPR-2014-28503
                   let a_cts71m00[2].lclidttxt    = a_cts71m00[1].lclidttxt
                   let a_cts71m00[2].cidnom       = a_cts71m00[1].cidnom
                   let a_cts71m00[2].ufdcod       = a_cts71m00[1].ufdcod
                   let a_cts71m00[2].brrnom       = a_cts71m00[1].brrnom
                   let a_cts71m00[2].lclbrrnom    = a_cts71m00[1].lclbrrnom
                   let a_cts71m00[2].endzon       = a_cts71m00[1].endzon
                   let a_cts71m00[2].lgdtip       = a_cts71m00[1].lgdtip
                   let a_cts71m00[2].lgdnom       = a_cts71m00[1].lgdnom
                   let a_cts71m00[2].lgdnum       = a_cts71m00[1].lgdnum
                   let a_cts71m00[2].lgdcep       = a_cts71m00[1].lgdcep
                   let a_cts71m00[2].lgdcepcmp    = a_cts71m00[1].lgdcepcmp
                   let a_cts71m00[2].lclltt       = a_cts71m00[1].lclltt
                   let a_cts71m00[2].lcllgt       = a_cts71m00[1].lcllgt
                   let a_cts71m00[2].lclrefptotxt = a_cts71m00[1].lclrefptotxt
                   let a_cts71m00[2].lclcttnom    = a_cts71m00[1].lclcttnom
                   let a_cts71m00[2].dddcod       = a_cts71m00[1].dddcod
                   let a_cts71m00[2].lcltelnum    = a_cts71m00[1].lcltelnum
                   let a_cts71m00[2].c24lclpdrcod = a_cts71m00[1].c24lclpdrcod
                   let a_cts71m00[2].ofnnumdig    = a_cts71m00[1].ofnnumdig
                   let a_cts71m00[2].celteldddcod = a_cts71m00[1].celteldddcod
                   let a_cts71m00[2].celtelnum    = a_cts71m00[1].celtelnum
                   let a_cts71m00[2].endcmp       = a_cts71m00[1].endcmp
                else
                   call cts06g11(7,
                                 13,
                                 w_cts71m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts71m00[2].lclidttxt,
                                 a_cts71m00[2].cidnom,
                                 a_cts71m00[2].ufdcod,
                                 a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom,
                                 a_cts71m00[2].endzon,
                                 a_cts71m00[2].lgdtip,
                                 a_cts71m00[2].lgdnom,
                                 a_cts71m00[2].lgdnum,
                                 a_cts71m00[2].lgdcep,
                                 a_cts71m00[2].lgdcepcmp,
                                 a_cts71m00[2].lclltt,
                                 a_cts71m00[2].lcllgt,
                                 a_cts71m00[2].lclrefptotxt,
                                 a_cts71m00[2].lclcttnom,
                                 a_cts71m00[2].dddcod,
                                 a_cts71m00[2].lcltelnum,
                                 a_cts71m00[2].c24lclpdrcod,
                                 a_cts71m00[2].ofnnumdig,
                                 a_cts71m00[2].celteldddcod,
                                 a_cts71m00[2].celtelnum,
                                 a_cts71m00[2].endcmp,
                                 hist_cts71m00.*, a_cts71m00[2].emeviacod)
                       returning a_cts71m00[2].lclidttxt,
                                 a_cts71m00[2].cidnom,
                                 a_cts71m00[2].ufdcod,
                                 a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom,
                                 a_cts71m00[2].endzon,
                                 a_cts71m00[2].lgdtip,
                                 a_cts71m00[2].lgdnom,
                                 a_cts71m00[2].lgdnum,
                                 a_cts71m00[2].lgdcep,
                                 a_cts71m00[2].lgdcepcmp,
                                 a_cts71m00[2].lclltt,
                                 a_cts71m00[2].lcllgt,
                                 a_cts71m00[2].lclrefptotxt,
                                 a_cts71m00[2].lclcttnom,
                                 a_cts71m00[2].dddcod,
                                 a_cts71m00[2].lcltelnum,
                                 a_cts71m00[2].c24lclpdrcod,
                                 a_cts71m00[2].ofnnumdig,
                                 a_cts71m00[2].celteldddcod,
                                 a_cts71m00[2].celtelnum,
                                 a_cts71m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts71m00.*, a_cts71m00[2].emeviacod
                                 #display "ws.retflg = ",ws.retflg
                end if    #---<<<  Endereco de corresp - PSI SPR-2014-28503
             end if

             let m_subbairro[1].lclbrrnom = a_cts71m00[1].lclbrrnom

             call cts06g10_monta_brr_subbrr(a_cts71m00[1].brrnom,
                                            a_cts71m00[1].lclbrrnom)
                  returning a_cts71m00[1].lclbrrnom

             let a_cts71m00[1].lgdtxt = a_cts71m00[1].lgdtip clipped, " ",
                                        a_cts71m00[1].lgdnom clipped, " ",
                                        a_cts71m00[1].lgdnum using "<<<<#"


             if l_lgdcep <> a_cts71m00[1].lgdcep or
                l_lgdcepcmp <> a_cts71m00[1].lgdcepcmp then

                call cts08g01("A","S","CONFIRME ALTERACAO DE ENDERECO PARA",
                              "ENVIO DE ASSISTENCIA A RESIDENCIA?",l_linha3,
                              l_linha4)
                     returning l_resultado

                if l_resultado = "N" then
                   let a_cts71m00[1].lgdtxt    = l_lgdtxt
                   let a_cts71m00[1].lclbrrnom = l_lclbrrnom
                   let a_cts71m00[1].cidnom    = l_cidnom
                   let a_cts71m00[1].ufdcod    = l_ufdcod
                end if
             end if

             display by name a_cts71m00[1].lgdtxt
             display by name a_cts71m00[1].lclbrrnom
             display by name a_cts71m00[1].endzon
             display by name a_cts71m00[1].cidnom
             display by name a_cts71m00[1].ufdcod
             display by name a_cts71m00[1].lclrefptotxt
             display by name a_cts71m00[1].lclcttnom
             display by name a_cts71m00[1].dddcod
             display by name a_cts71m00[1].lcltelnum
             display by name a_cts71m00[1].celteldddcod
             display by name a_cts71m00[1].celtelnum
             display by name a_cts71m00[1].endcmp

             display a_cts71m00[1].lclcttnom to lclcttnom  #---- PSI SPR-2014-28503

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field corsus
             end if

             if g_documento.atdsrvnum is not null and
                g_documento.atdsrvano is not null then
                next field srvretmtvcod
             end if
          end if


   after  field socntzcod
          display by name d_cts71m00.socntzcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field corsus
          end if

          if d_cts71m00.socntzcod is null  or
             d_cts71m00.socntzcod <> l_natureza then

             if d_cts71m00.socntzcod <> l_natureza then
                error "Codigo de natureza n�o pode ser modificada !"
                next field socntzcod
             else
                error " Codigo de natureza deve ser informada!"
             end if
             let l_null = null

               # Busca Cortesia
                 call cts71m00_assunto_cortesia()
                      returning l_cortesia

               if l_cortesia = false and
                  g_pss.psscntcod is not null then

                  call cto00m08_natureza_pss(1,g_documento.c24astcod,
                                             d_cts71m00.socntzcod   )
                  returning d_cts71m00.socntzcod

               else
                  call cts17m06_popup_natureza
                       (l_null,
                        g_documento.c24astcod,
                        l_null,
                        l_null,
                        l_null,
                        l_null,
                        l_null,
                        l_null,
                        l_null)
                        returning d_cts71m00.socntzcod, l_clscod
               end if


             if d_cts71m00.socntzcod is null then
                 next field  socntzcod
              end if
          end if

           call ctc16m03_inf_natureza(d_cts71m00.socntzcod,'A')
                returning l_status, l_mensagem, d_cts71m00.socntzdes, l_codigo


          if l_status <> 1 then
             initialize d_cts71m00.socntzcod to null
             error "Codigo de natureza invalido!"
             next field socntzcod
          else
             display by name d_cts71m00.socntzcod
             display by name d_cts71m00.socntzdes
          end if

          if cts17m06_assunto_natureza(g_documento.c24astcod,
                                       d_cts71m00.socntzcod) = 1 then
             next field socntzcod
          end if

          # Solicita��o do Felix Bastiani alerta ao segurado 08/03/2010
          if  d_cts71m00.socntzcod  = 185 then

             call cts08g01("I","N",
                           "INFORME AO CLIENTE A NECESSIDADE ",
                           " DA CAIXA D'AGUA ESTAR VAZIA E O LOCAL ",
                           " SER DE FACIL ACESSO, COM ESPACO PARA ",
                           " O PRESTADOR EXECUTAR O SERVICO.")
                 returning ws.confirma

           end if


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
            let d_cts71m00.espcod = 1
            display by name d_cts71m00.espcod attribute (reverse)
         else
            next field c24pbmcod
         end if

   after field espcod
         display by name d_cts71m00.espcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field socntzcod
         end if

         #espcod nao � obrigatorio entao apenas exibir
         #a lista de especialidade

         if d_cts71m00.espcod is null then
            call cts31g00_lista_especialidade()
                 returning ws.confirma,
                           d_cts71m00.espcod,
                           d_cts71m00.espdes
            if ws.confirma = 3 then
                error "Problemas ao listar especialidades"
            end if
         else

            # Buscar descricao apenas para especialidade ativa
            call cts31g00_descricao_esp(d_cts71m00.espcod, "A")
                 returning d_cts71m00.espdes

            if d_cts71m00.espdes is null then
               #codigo especialidade invalido
               error "Codigo de especialidade invalido."
               next field espcod
            end if
         end if

         display by name d_cts71m00.espcod
         display by name d_cts71m00.espdes


   before field c24pbmcod
         display by name d_cts71m00.c24pbmcod attribute (reverse)

   after field c24pbmcod
         display by name d_cts71m00.c24pbmcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then

            let d_cts71m00.c24pbmcod = null
            let d_cts71m00.atddfttxt = null

            display by name d_cts71m00.c24pbmcod
            display by name d_cts71m00.atddfttxt

            if d_cts71m00.espcod is not null then
               next field espcod
            else
               next field socntzcod
            end if
         end if

         call cts17m07_problema(""
                              ,g_documento.c24astcod
                              ,g_documento.atdsrvorg
                              ,d_cts71m00.c24pbmcod
                              ,d_cts71m00.socntzcod
                              ,l_clscod
                              ,w_cts71m00.clscod
                              ,""
                              ,""
                              ,"" )
                     returning l_status
                              ,l_mensagem
                              ,d_cts71m00.c24pbmcod
                              ,d_cts71m00.atddfttxt

         if l_status <> 1 then
            error l_mensagem
            next field c24pbmcod
         end if

         display by name d_cts71m00.c24pbmcod
         display by name d_cts71m00.atddfttxt

         if g_documento.atdsrvnum is not null and
            g_documento.atdsrvano is not null then
            next field srvretmtvcod
         end if


   #- SPR-2015-15533-Fechamento Servicos por GPS ->>>
   before field prslocflg
         #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
         call opsfa001_conskupbr(d_cts71m00.c24pbmcod
                                ,w_cts71m00.atddat)
              returning r_retorno_sku.catcod
                       ,r_retorno_sku.pgtfrmcod
                       ,r_retorno_sku.srvprsflg  #- SPR-2016-03565
                       ,r_retorno_sku.codigo_erro # 0=Ok, <> 0=sqlca.sqlcode
                       ,r_retorno_sku.msg_erro

        if r_retorno_sku.srvprsflg = "S" then  #- SPR-2016-03565
        	 let d_cts71m00.prslocflg = "N"
        end if
        
        display by name d_cts71m00.prslocflg attribute (reverse)
        	
   after  field prslocflg
         let l_obter_qrv = true
         display by name d_cts71m00.prslocflg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field c24pbmcod
         end if

         if ((d_cts71m00.prslocflg  is null)  or
             (d_cts71m00.prslocflg  <> "S"    and
            d_cts71m00.prslocflg    <> "N"))  then
            error " Prestador no local: (S)im ou (N)ao!"
            next field prslocflg
         end if

         if d_cts71m00.prslocflg = "S"   then
            if r_retorno_sku.srvprsflg = "S" then  #- SPR-2016-03565
               error "SKU Rede Apartada - Prestador no Local Nao Permitido" #- SPR-2016-03565
               next field prslocflg
            end if

            if w_cts71m00.atdprscod is null then
               call ctn24c01()
                 returning w_cts71m00.atdprscod,
                           w_cts71m00.srrcoddig,
                           ws.atdvclsgl ,
                           w_cts71m00.socvclcod

               if w_cts71m00.atdprscod  is null   then
                  error " Faltam dados para prestador no local!"
                  next field prslocflg
               end if
            end if

            let w_cts71m00.atdlibhor = w_cts71m00.atdhor
            let w_cts71m00.atdlibdat = w_cts71m00.atddat

            call cts40g03_data_hora_banco(2) returning m_data, m_hora

            let w_cts71m00.cnldat    = m_data
            let w_cts71m00.atdfnlhor = m_hora

            let w_cts71m00.c24opemat = g_issk.funmat
            let w_cts71m00.atdfnlflg = "S"
            let w_cts71m00.atdetpcod =  3
            let d_cts71m00.imdsrvflg = "S"
            display by name d_cts71m00.imdsrvflg
            let w_cts71m00.atdhorpvt = "00:00"
         else
            initialize w_cts71m00.funmat   ,
                       w_cts71m00.cnldat   ,
                       w_cts71m00.atdfnlhor,
                       w_cts71m00.c24opemat,
                       w_cts71m00.atdfnlflg,
                       w_cts71m00.atdetpcod,
                       w_cts71m00.atdprscod,
                       w_cts71m00.c24nomctt  to null
         end if

         #=> SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA
         if d_cts71m00.c24pbmcod = 999 then  #=> MENOS PARA '999'
            let m_vendaflg = false
         else
            let m_vendaflg = l_vendaflg
            if g_documento.acao = 'INC' and
               m_vendaflg               then

               #-- SPR-2015-13708-Melhorias Calculo SKU
               if not opsfa006_inclui(r_retorno_sku.catcod
                                     ,0  #- Distancia Ocorrencia X Destino
                                     ,d_cts71m00.prslocflg) then #- SPR-2015-15533
                  next field c24pbmcod
               end if
            end if
         end if

         if g_documento.acao = 'INC' and d_cts71m00.c24pbmcod <> 999
            and  (ws_acao is null or ws_acao <> "RET" ) then

            if fgl_lastkey() <> fgl_keyval("up") and
               fgl_lastkey() <> fgl_keyval("left") then

               #--- PSI SPR-2014-28503 - Inibir a abertura do pop-up
               #if cts08g01("C","S",' ',"INCLUIR MAIS OCORRENCIAS ?",'','')
               #    = 'S' then
               #   call cts17m03_laudo_multiplo("",
               #                                "",
               #                                "",
               #                                "",
               #                                g_documento.c24astcod,
               #                                w_cts71m00.clscod,
               #                                l_clscod,
               #                                "",
               #                                "",
               #                                "",
               #                                d_cts71m00.socntzcod,
               #                                l_codigo,
               #                                "",
               #                                "",
               #                                am_param[1].*,
               #                                am_param[2].*,
               #                                am_param[3].*,
               #                                am_param[4].*,
               #                                am_param[5].*,
               #                                am_param[6].*,
               #                                am_param[7].*,
               #                                am_param[8].*,
               #                                am_param[9].*,
               #                                am_param[10].* )
               #        returning am_param[1].*  ,am_param[2].*  ,am_param[3].*
               #                 ,am_param[4].*  ,am_param[5].*  ,am_param[6].*
               #                 ,am_param[7].*  ,am_param[8].*  ,am_param[9].*
               #                 ,am_param[10].*
               #end if
            else
               display by name d_cts71m00.c24pbmcod
               next field socntzcod
            end if
         end if

         let m_acesso_ind = false    #---- PSI SPR-2014-28503
         let m_atdsrvorg = 13
         call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
         returning m_acesso_ind

         if m_acesso_ind = false then
            call cts06g03(1,
                          13,
                          w_cts71m00.ligcvntip,
                          aux_today,
                          aux_hora,
                          a_cts71m00[1].lclidttxt,
                          a_cts71m00[1].cidnom,
                          a_cts71m00[1].ufdcod,
                          a_cts71m00[1].brrnom,
                          a_cts71m00[1].lclbrrnom,
                          a_cts71m00[1].endzon,
                          a_cts71m00[1].lgdtip,
                          a_cts71m00[1].lgdnom,
                          a_cts71m00[1].lgdnum,
                          a_cts71m00[1].lgdcep,
                          a_cts71m00[1].lgdcepcmp,
                          a_cts71m00[1].lclltt,
                          a_cts71m00[1].lcllgt,
                          a_cts71m00[1].lclrefptotxt,
                          a_cts71m00[1].lclcttnom,
                          a_cts71m00[1].dddcod,
                          a_cts71m00[1].lcltelnum,
                          a_cts71m00[1].c24lclpdrcod,
                          a_cts71m00[1].ofnnumdig,
                          a_cts71m00[1].celteldddcod,
                          a_cts71m00[1].celtelnum,
                          a_cts71m00[1].endcmp,
                          hist_cts71m00.*, a_cts71m00[1].emeviacod)
                returning a_cts71m00[1].lclidttxt,
                          a_cts71m00[1].cidnom,
                          a_cts71m00[1].ufdcod,
                          a_cts71m00[1].brrnom,
                          a_cts71m00[1].lclbrrnom,
                          a_cts71m00[1].endzon,
                          a_cts71m00[1].lgdtip,
                          a_cts71m00[1].lgdnom,
                          a_cts71m00[1].lgdnum,
                          a_cts71m00[1].lgdcep,
                          a_cts71m00[1].lgdcepcmp,
                          a_cts71m00[1].lclltt,
                          a_cts71m00[1].lcllgt,
                          a_cts71m00[1].lclrefptotxt,
                          a_cts71m00[1].lclcttnom,
                          a_cts71m00[1].dddcod,
                          a_cts71m00[1].lcltelnum,
                          a_cts71m00[1].c24lclpdrcod,
                          a_cts71m00[1].ofnnumdig,
                          a_cts71m00[1].celteldddcod,
                          a_cts71m00[1].celtelnum,
                          a_cts71m00[1].endcmp,
                          ws.retflg,
                          hist_cts71m00.*, a_cts71m00[1].emeviacod
                          #display "ws.retflg = ",ws.retflg

            if ws.retflg = "N" then
               error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos!" sleep 3
               next field c24pbmcod
            end if

            #--->>> Endereco de correspondencia - PSI SPR-2014-28503
            call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                          "O MESMO DE OCORRENCIA?",l_linha3, l_linha4)
                returning l_resultado

            if l_resultado = "S" then   #--- PSI SPR-2014-28503
               let a_cts71m00[2].lclidttxt    = a_cts71m00[1].lclidttxt
               let a_cts71m00[2].cidnom       = a_cts71m00[1].cidnom
               let a_cts71m00[2].ufdcod       = a_cts71m00[1].ufdcod
               let a_cts71m00[2].brrnom       = a_cts71m00[1].brrnom
               let a_cts71m00[2].lclbrrnom    = a_cts71m00[1].lclbrrnom
               let a_cts71m00[2].endzon       = a_cts71m00[1].endzon
               let a_cts71m00[2].lgdtip       = a_cts71m00[1].lgdtip
               let a_cts71m00[2].lgdnom       = a_cts71m00[1].lgdnom
               let a_cts71m00[2].lgdnum       = a_cts71m00[1].lgdnum
               let a_cts71m00[2].lgdcep       = a_cts71m00[1].lgdcep
               let a_cts71m00[2].lgdcepcmp    = a_cts71m00[1].lgdcepcmp
               let a_cts71m00[2].lclltt       = a_cts71m00[1].lclltt
               let a_cts71m00[2].lcllgt       = a_cts71m00[1].lcllgt
               let a_cts71m00[2].lclrefptotxt = a_cts71m00[1].lclrefptotxt
               let a_cts71m00[2].lclcttnom    = a_cts71m00[1].lclcttnom
               let a_cts71m00[2].dddcod       = a_cts71m00[1].dddcod
               let a_cts71m00[2].lcltelnum    = a_cts71m00[1].lcltelnum
               let a_cts71m00[2].c24lclpdrcod = a_cts71m00[1].c24lclpdrcod
               let a_cts71m00[2].ofnnumdig    = a_cts71m00[1].ofnnumdig
               let a_cts71m00[2].celteldddcod = a_cts71m00[1].celteldddcod
               let a_cts71m00[2].celtelnum    = a_cts71m00[1].celtelnum
               let a_cts71m00[2].endcmp       = a_cts71m00[1].endcmp
            else
               call cts06g11(7,
                             13,
                             w_cts71m00.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts71m00[2].lclidttxt,
                             a_cts71m00[2].cidnom,
                             a_cts71m00[2].ufdcod,
                             a_cts71m00[2].brrnom,
                             a_cts71m00[2].lclbrrnom,
                             a_cts71m00[2].endzon,
                             a_cts71m00[2].lgdtip,
                             a_cts71m00[2].lgdnom,
                             a_cts71m00[2].lgdnum,
                             a_cts71m00[2].lgdcep,
                             a_cts71m00[2].lgdcepcmp,
                             a_cts71m00[2].lclltt,
                             a_cts71m00[2].lcllgt,
                             a_cts71m00[2].lclrefptotxt,
                             a_cts71m00[2].lclcttnom,
                             a_cts71m00[2].dddcod,
                             a_cts71m00[2].lcltelnum,
                             a_cts71m00[2].c24lclpdrcod,
                             a_cts71m00[2].ofnnumdig,
                             a_cts71m00[2].celteldddcod,
                             a_cts71m00[2].celtelnum,
                             a_cts71m00[2].endcmp,
                             hist_cts71m00.*, a_cts71m00[2].emeviacod)
                   returning a_cts71m00[2].lclidttxt,
                             a_cts71m00[2].cidnom,
                             a_cts71m00[2].ufdcod,
                             a_cts71m00[2].brrnom,
                             a_cts71m00[2].lclbrrnom,
                             a_cts71m00[2].endzon,
                             a_cts71m00[2].lgdtip,
                             a_cts71m00[2].lgdnom,
                             a_cts71m00[2].lgdnum,
                             a_cts71m00[2].lgdcep,
                             a_cts71m00[2].lgdcepcmp,
                             a_cts71m00[2].lclltt,
                             a_cts71m00[2].lcllgt,
                             a_cts71m00[2].lclrefptotxt,
                             a_cts71m00[2].lclcttnom,
                             a_cts71m00[2].dddcod,
                             a_cts71m00[2].lcltelnum,
                             a_cts71m00[2].c24lclpdrcod,
                             a_cts71m00[2].ofnnumdig,
                             a_cts71m00[2].celteldddcod,
                             a_cts71m00[2].celtelnum,
                             a_cts71m00[2].endcmp,
                             ws.retflg,
                             hist_cts71m00.*, a_cts71m00[2].emeviacod
                             #display "ws.retflg = ",ws.retflg
            end if   #---<<< Endereco de corresp - PSI SPR-2014-28503
         else
            call cts06g11(1,
                          13,
                          w_cts71m00.ligcvntip,
                          aux_today,
                          aux_hora,
                          a_cts71m00[1].lclidttxt,
                          a_cts71m00[1].cidnom,
                          a_cts71m00[1].ufdcod,
                          a_cts71m00[1].brrnom,
                          a_cts71m00[1].lclbrrnom,
                          a_cts71m00[1].endzon,
                          a_cts71m00[1].lgdtip,
                          a_cts71m00[1].lgdnom,
                          a_cts71m00[1].lgdnum,
                          a_cts71m00[1].lgdcep,
                          a_cts71m00[1].lgdcepcmp,
                          a_cts71m00[1].lclltt,
                          a_cts71m00[1].lcllgt,
                          a_cts71m00[1].lclrefptotxt,
                          a_cts71m00[1].lclcttnom,
                          a_cts71m00[1].dddcod,
                          a_cts71m00[1].lcltelnum,
                          a_cts71m00[1].c24lclpdrcod,
                          a_cts71m00[1].ofnnumdig,
                          a_cts71m00[1].celteldddcod,
                          a_cts71m00[1].celtelnum,
                          a_cts71m00[1].endcmp,
                          hist_cts71m00.*, a_cts71m00[1].emeviacod)
                returning a_cts71m00[1].lclidttxt,
                          a_cts71m00[1].cidnom,
                          a_cts71m00[1].ufdcod,
                          a_cts71m00[1].brrnom,
                          a_cts71m00[1].lclbrrnom,
                          a_cts71m00[1].endzon,
                          a_cts71m00[1].lgdtip,
                          a_cts71m00[1].lgdnom,
                          a_cts71m00[1].lgdnum,
                          a_cts71m00[1].lgdcep,
                          a_cts71m00[1].lgdcepcmp,
                          a_cts71m00[1].lclltt,
                          a_cts71m00[1].lcllgt,
                          a_cts71m00[1].lclrefptotxt,
                          a_cts71m00[1].lclcttnom,
                          a_cts71m00[1].dddcod,
                          a_cts71m00[1].lcltelnum,
                          a_cts71m00[1].c24lclpdrcod,
                          a_cts71m00[1].ofnnumdig,
                          a_cts71m00[1].celteldddcod,
                          a_cts71m00[1].celtelnum,
                          a_cts71m00[1].endcmp,
                          ws.retflg,
                          hist_cts71m00.*, a_cts71m00[1].emeviacod
                          #display "ws.retflg = ",ws.retflg

            if ws.retflg = "N" then
               error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos!" sleep 3
               next field c24pbmcod
            end if

            #--->>> Endereco de correspondencia - PSI SPR-2014-28503
            call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                          "O MESMO DE OCORRENCIA?",l_linha3, l_linha4)
                returning l_resultado

            if l_resultado = "S" then   #---- PSI SPR-2014-28503
               let a_cts71m00[2].lclidttxt    = a_cts71m00[1].lclidttxt
               let a_cts71m00[2].cidnom       = a_cts71m00[1].cidnom
               let a_cts71m00[2].ufdcod       = a_cts71m00[1].ufdcod
               let a_cts71m00[2].brrnom       = a_cts71m00[1].brrnom
               let a_cts71m00[2].lclbrrnom    = a_cts71m00[1].lclbrrnom
               let a_cts71m00[2].endzon       = a_cts71m00[1].endzon
               let a_cts71m00[2].lgdtip       = a_cts71m00[1].lgdtip
               let a_cts71m00[2].lgdnom       = a_cts71m00[1].lgdnom
               let a_cts71m00[2].lgdnum       = a_cts71m00[1].lgdnum
               let a_cts71m00[2].lgdcep       = a_cts71m00[1].lgdcep
               let a_cts71m00[2].lgdcepcmp    = a_cts71m00[1].lgdcepcmp
               let a_cts71m00[2].lclltt       = a_cts71m00[1].lclltt
               let a_cts71m00[2].lcllgt       = a_cts71m00[1].lcllgt
               let a_cts71m00[2].lclrefptotxt = a_cts71m00[1].lclrefptotxt
               let a_cts71m00[2].lclcttnom    = a_cts71m00[1].lclcttnom
               let a_cts71m00[2].dddcod       = a_cts71m00[1].dddcod
               let a_cts71m00[2].lcltelnum    = a_cts71m00[1].lcltelnum
               let a_cts71m00[2].c24lclpdrcod = a_cts71m00[1].c24lclpdrcod
               let a_cts71m00[2].ofnnumdig    = a_cts71m00[1].ofnnumdig
               let a_cts71m00[2].celteldddcod = a_cts71m00[1].celteldddcod
               let a_cts71m00[2].celtelnum    = a_cts71m00[1].celtelnum
               let a_cts71m00[2].endcmp       = a_cts71m00[1].endcmp
            else
               call cts06g11(7,
                             13,
                             w_cts71m00.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts71m00[2].lclidttxt,
                             a_cts71m00[2].cidnom,
                             a_cts71m00[2].ufdcod,
                             a_cts71m00[2].brrnom,
                             a_cts71m00[2].lclbrrnom,
                             a_cts71m00[2].endzon,
                             a_cts71m00[2].lgdtip,
                             a_cts71m00[2].lgdnom,
                             a_cts71m00[2].lgdnum,
                             a_cts71m00[2].lgdcep,
                             a_cts71m00[2].lgdcepcmp,
                             a_cts71m00[2].lclltt,
                             a_cts71m00[2].lcllgt,
                             a_cts71m00[2].lclrefptotxt,
                             a_cts71m00[2].lclcttnom,
                             a_cts71m00[2].dddcod,
                             a_cts71m00[2].lcltelnum,
                             a_cts71m00[2].c24lclpdrcod,
                             a_cts71m00[2].ofnnumdig,
                             a_cts71m00[2].celteldddcod,
                             a_cts71m00[2].celtelnum,
                             a_cts71m00[2].endcmp,
                             hist_cts71m00.*, a_cts71m00[2].emeviacod)
                   returning a_cts71m00[2].lclidttxt,
                             a_cts71m00[2].cidnom,
                             a_cts71m00[2].ufdcod,
                             a_cts71m00[2].brrnom,
                             a_cts71m00[2].lclbrrnom,
                             a_cts71m00[2].endzon,
                             a_cts71m00[2].lgdtip,
                             a_cts71m00[2].lgdnom,
                             a_cts71m00[2].lgdnum,
                             a_cts71m00[2].lgdcep,
                             a_cts71m00[2].lgdcepcmp,
                             a_cts71m00[2].lclltt,
                             a_cts71m00[2].lcllgt,
                             a_cts71m00[2].lclrefptotxt,
                             a_cts71m00[2].lclcttnom,
                             a_cts71m00[2].dddcod,
                             a_cts71m00[2].lcltelnum,
                             a_cts71m00[2].c24lclpdrcod,
                             a_cts71m00[2].ofnnumdig,
                             a_cts71m00[2].celteldddcod,
                             a_cts71m00[2].celtelnum,
                             a_cts71m00[2].endcmp,
                             ws.retflg,
                             hist_cts71m00.*, a_cts71m00[2].emeviacod
            end if    #---<<< Endereco de corresp - PSI SPR-2014-28503
         end if

         let m_subbairro[1].lclbrrnom = a_cts71m00[1].lclbrrnom

         call cts06g10_monta_brr_subbrr(a_cts71m00[1].brrnom,
                                        a_cts71m00[1].lclbrrnom)
              returning a_cts71m00[1].lclbrrnom

         let a_cts71m00[1].lgdtxt = a_cts71m00[1].lgdtip clipped, " ",
                                    a_cts71m00[1].lgdnom clipped, " ",
                                    a_cts71m00[1].lgdnum using "<<<<#"

         #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
         let m_subbairro[2].lclbrrnom = a_cts71m00[2].lclbrrnom

         call cts06g10_monta_brr_subbrr(a_cts71m00[2].brrnom,
                                        a_cts71m00[2].lclbrrnom)
              returning a_cts71m00[2].lclbrrnom

         let a_cts71m00[2].lgdtxt = a_cts71m00[2].lgdtip clipped, " ",
                                    a_cts71m00[2].lgdnom clipped, " ",
                                    a_cts71m00[2].lgdnum using "<<<<#"

         if l_lgdcep <> a_cts71m00[1].lgdcep or
            l_lgdcepcmp <> a_cts71m00[1].lgdcepcmp then

            call cts08g01("A","S","CONFIRME ALTERACAO DE ENDERECO PARA",
                          "ENVIO DE ASSISTENCIA A RESIDENCIA?",l_linha3,
                          l_linha4)
                 returning l_resultado

            if l_resultado = "N" then
               let a_cts71m00[1].lgdtxt    = l_lgdtxt
               let a_cts71m00[1].lclbrrnom = l_lclbrrnom
               let a_cts71m00[1].cidnom    = l_cidnom
               let a_cts71m00[1].ufdcod    = l_ufdcod
            end if
         end if


         display by name a_cts71m00[1].lgdtxt
         display by name a_cts71m00[1].lclbrrnom
         display by name a_cts71m00[1].endzon
         display by name a_cts71m00[1].cidnom
         display by name a_cts71m00[1].ufdcod
         display by name a_cts71m00[1].lclrefptotxt
         display by name a_cts71m00[1].lclcttnom
         display by name a_cts71m00[1].dddcod
         display by name a_cts71m00[1].lcltelnum
         display by name a_cts71m00[1].celteldddcod
         display by name a_cts71m00[1].celtelnum
         display by name a_cts71m00[1].endcmp

         if ws.retflg = "N"  then
           error " Dados referentes ao local incorretos ou nao preenchidos!"
            next field c24pbmcod
         end if
         #- SPR-2015-15533-Fechamento Servicos por GPS -<<<

   before field atddfttxt  #---- PSI SPR-2014-28503
          display a_cts71m00[1].lclcttnom to lclcttnom  #---- PSI SPR-2014-28503
          display by name d_cts71m00.atddfttxt attribute (reverse)

          if d_cts71m00.c24pbmcod <> 999 then
             next field orrdat  #---- PSI SPR-2014-28503
          end if

   after  field atddfttxt
          display by name d_cts71m00.atddfttxt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts71m00.atddfttxt  is null   then
                error " Problema apresentado deve ser informado!"
                next field atddfttxt
             end if

             if g_documento.acao = 'INC' and
               (ws_acao is null or ws_acao <> "RET" ) then

               if  fgl_lastkey() <> fgl_keyval("up") and
                   fgl_lastkey() <> fgl_keyval("left") then

                 #--- PSI SPR-2014-28503 - Inibir a abertura do popup
                 #  if cts08g01("C","S",' ',"INCLUIR MAIS OCORRENCIAS ?",'','')
                 #      = 'S' then
                 #      call cts17m03_laudo_multiplo("",
                 #                                   "",
                 #                                   "",
                 #                                   "",
                 #                                   g_documento.c24astcod,
                 #                                   w_cts71m00.clscod,
                 #                                   l_clscod,
                 #                                   "",
                 #                                   "",
                 #                                   "",
                 #                                   d_cts71m00.socntzcod,
                 #                                   l_codigo,
                 #                                   "",
                 #                                   "",
                 #                                   am_param[1].*,
                 #                                   am_param[2].*,
                 #                                   am_param[3].*,
                 #                                   am_param[4].*,
                 #                                   am_param[5].*,
                 #                                   am_param[6].*,
                 #                                   am_param[7].*,
                 #                                   am_param[8].*,
                 #                                   am_param[9].*,
                 #                                   am_param[10].* )
                 #        returning am_param[1].*  ,am_param[2].*  ,am_param[3].*
                 #                 ,am_param[4].*  ,am_param[5].*  ,am_param[6].*
                 #                 ,am_param[7].*  ,am_param[8].*  ,am_param[9].*
                 #                 ,am_param[10].*
                 #  end if
             else
                 display by name d_cts71m00.c24pbmcod
                 next field socntzcod
             end if

          end if
          end if


   before field lclcttnom
          let ws.lclcttnom = a_cts71m00[1].lclcttnom
          display by name ws.lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name ws.lclcttnom

          if w_cts71m00.atdfnlflg = "S"  or
            (ws_acaorigem is not null and ws_acaorigem = "CON") then

             if w_cts71m00.atdfnlflg = "S"  then

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
                call cts02m03(w_cts71m00.atdfnlflg, d_cts71m00.imdsrvflg,
                              w_cts71m00.atdhorpvt, w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg, w_cts71m00.atdpvtretflg)
                    returning w_cts71m00.atdhorpvt, w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg, w_cts71m00.atdpvtretflg
             else
  	            ##-- SPR-2015-15533 - Inicio
                #display 'entrada'
                #DISPLAY 'g_documento.atdsrvorg :',g_documento.atdsrvorg
                #DISPLAY 'd_cts71m00.asitipcod  :',d_cts71m00.asitipcod
                #DISPLAY 'd_cts71m00.socntzcod  :',d_cts71m00.socntzcod
                #DISPLAY 'd_cts71m00.espcod     :',d_cts71m00.espcod

                #display '---------------------------------------------'
                let g_documento.c24pbmcod    = d_cts71m00.c24pbmcod
                let g_documento.atddfttxt    = d_cts71m00.atddfttxt clipped
                let g_documento.socntzcod    = d_cts71m00.socntzcod
                let g_documento.socntzdes    = d_cts71m00.socntzdes clipped
                ##-- SPR-2015-15533 - Fim

                call cts02m08(w_cts71m00.atdfnlflg,
                              d_cts71m00.imdsrvflg,
                              m_altcidufd,
                              d_cts71m00.prslocflg,
                              w_cts71m00.atdhorpvt,
                              w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg,
                              w_cts71m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts71m00[1].cidnom,
                              a_cts71m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              "",   # codigo do veiculo, somente Auto
                              "",   # categoria tarifaria, somente Auto
                              d_cts71m00.imdsrvflg,
                              a_cts71m00[1].c24lclpdrcod,
                              a_cts71m00[1].lclltt,
                              a_cts71m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts71m00.asitipcod,
                              d_cts71m00.socntzcod, # natureza
                              d_cts71m00.espcod)    # sub-natureza
                    returning w_cts71m00.atdhorpvt,
                              w_cts71m00.atddatprg,
                              w_cts71m00.atdhorprg,
                              w_cts71m00.atdpvtretflg,
                              d_cts71m00.imdsrvflg,
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
          let a_cts71m00[1].lclcttnom = ws.lclcttnom

   before field orrdat
          display by name d_cts71m00.orrdat attribute (reverse)

   after  field orrdat
          display by name d_cts71m00.orrdat

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts71m00.orrdat is null        then
                error " Data da ocorrencia deve ser informada!"
                next field orrdat
             end if

             if d_cts71m00.orrdat > m_data   then
                error " Data da ocorrencia nao deve ser maior que hoje!"
                next field orrdat
             end if

             if d_cts71m00.orrdat < m_data - 180 units day  then
                error " Data da ocorrencia nao deve ser anterior a SEIS meses!"
                next field orrdat
             end if

             if d_cts71m00.orrdat < w_cts71m00.viginc  or
                d_cts71m00.orrdat > w_cts71m00.vigfnl  then
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
                next field socntzcod   #--- PSI SPR-2014-28503
             end if
          end if


    before field srvretmtvcod
        display a_cts71m00[1].lclcttnom to lclcttnom  #---- PSI SPR-2014-28503

        if ws_acao is not null and
           ws_acao =  "RET"    then
           # Solicitacao do (RET)orno
        else
           next field atdlibflg
        end if

        display by name d_cts71m00.srvretmtvcod attribute (reverse)

    after  field srvretmtvcod
        display by name d_cts71m00.srvretmtvcod

        if fgl_lastkey() =  fgl_keyval("up")   or
           fgl_lastkey() =  fgl_keyval("left") then
           next field orrdat
        end if

        if d_cts71m00.srvretmtvcod  is null  or
           d_cts71m00.srvretmtvcod  =  0     then
           call ctb24m01() returning d_cts71m00.srvretmtvcod
           next field srvretmtvcod
        else
           if d_cts71m00.srvretmtvcod <> 999 then

              whenever error continue
              open c_cts71m00_009 using d_cts71m00.srvretmtvcod
              fetch c_cts71m00_009 into d_cts71m00.srvretmtvdes
              whenever error stop

              close c_cts71m00_009

              if sqlca.sqlcode = notfound then
                 error " Codigo do motivo nao existe!"
                 call ctb24m01() returning d_cts71m00.srvretmtvcod
                 next field srvretmtvcod
              end if

              display by name d_cts71m00.srvretmtvdes

              # Verifica prazo para abertura de servico de retorno
              call cts17m01_valida_prazo_retorno(cpl_atdsrvnum, cpl_atdsrvano, d_cts71m00.srvretmtvcod)
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

        display by name d_cts71m00.srvretmtvdes

   before field srvretmtvdes
          display by name d_cts71m00.srvretmtvdes
          if d_cts71m00.srvretmtvcod <> 999 then
             next field atdlibflg
          end if
          display by name d_cts71m00.srvretmtvdes attribute (reverse)

   after  field srvretmtvdes
          display by name d_cts71m00.srvretmtvdes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts71m00.srvretmtvdes  is null   then
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
        display by name d_cts71m00.retprsmsmflg attribute (reverse)

    after  field retprsmsmflg
        display by name d_cts71m00.retprsmsmflg

        if fgl_lastkey() =  fgl_keyval("up")   or
           fgl_lastkey() =  fgl_keyval("left") then
           next field srvretmtvcod
        end if

        if  d_cts71m00.retprsmsmflg <> 'S' and
            d_cts71m00.retprsmsmflg <> 'N' then
              error " Informar se deseja mesmo prestador no retorno "
              next field retprsmsmflg
        end if


   before field atdlibflg
          ##-- inicializar o atdlibflg e passar para o proximo campo

          if d_cts71m00.atdlibflg is null then

             let d_cts71m00.atdlibflg = "S"
             display by name d_cts71m00.atdlibflg
             ##-- inicializar data e hora

             call cts40g03_data_hora_banco(2) returning m_data, m_hora
             let w_cts71m00.atdlibhor = m_hora
             let w_cts71m00.atdlibdat = m_data
             next field imdsrvflg #- SPR-2015-15533-Fechamento Servicos por GPS
          end if

          display by name d_cts71m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts71m00.atdfnlflg  =  "S"       then
             next field imdsrvflg # exit input
          end if


   after  field atdlibflg
          let l_obter_qrv = true
          display by name d_cts71m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up") or
             fgl_lastkey() = fgl_keyval("left") then
             if g_documento.acao = 'INC' then
                next field c24pbmcod
             else
                next field socntzcod   #--- PSI SPR-2014-28503
             end if
          end if

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then


             if d_cts71m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts71m00.atdlibflg <> "S"  and
                d_cts71m00.atdlibflg <> "N"  then
                error " Envio liberado deve ser (S)im ou (N)ao!"
                next field atdlibflg
             end if

             let ws.atdlibflg = d_cts71m00.atdlibflg
             display by name d_cts71m00.atdlibflg

             if w_cts71m00.atdlibflg is null  then
                if ws.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2) returning m_data, m_hora
                   let w_cts71m00.atdlibdat = m_data
                   let w_cts71m00.atdlibhor = m_hora

                else
                   let d_cts71m00.atdlibflg = "N"
                   display by name d_cts71m00.atdlibflg
                   initialize w_cts71m00.atdlibhor to null
                   initialize w_cts71m00.atdlibdat to null
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


                if w_cts71m00.atdlibflg = "S"  then
                   if ws.atdlibflg = "S" then
                      next field imdsrvflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg

                      let d_cts71m00.atdlibflg = "N"
                      display by name d_cts71m00.atdlibflg

                      initialize w_cts71m00.atdlibhor to null
                      initialize w_cts71m00.atdlibdat to null

                      error " Liberacao cancelada!" sleep 1
                      next field imdsrvflg
                   end if
                else
                   if w_cts71m00.atdlibflg = "N"   then
                      if ws.atdlibflg = "N" then
                         next field imdsrvflg
                      else
                         call cts40g03_data_hora_banco(2)
                              returning m_data, m_hora

                         let w_cts71m00.atdlibdat = m_data
                         let w_cts71m00.atdlibhor = m_hora

                         next field imdsrvflg
                      end if
                   end if
                end if
             end if
          else
             if ws_acao is not null and
                ws_acao =  "RET"    then
                if d_cts71m00.srvretmtvcod <> 999 then
                   next field srvretmtvcod
                else
                   next field srvretmtvdes
                end if
             else
                next field srvretmtvcod
             end if
          end if

   before field imdsrvflg
          # Se a flag natagdflg = "S" nao abre agenda e
          # coloca o imdsrvflg como "S"

          whenever error continue
          open c_cts71m00_031 using d_cts71m00.socntzcod
          fetch c_cts71m00_031 into l_natagdflg
          whenever error stop
          close  c_cts71m00_031

          if l_natagdflg = "S" then

               let d_cts71m00.imdsrvflg = "S"
                display by name d_cts71m00.imdsrvflg


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
          let m_imdsrvflg_ant = d_cts71m00.imdsrvflg
          call cts71m00_verifica_endereco() returning l_flag

          display by name d_cts71m00.imdsrvflg attribute (reverse)

          if ml_srvabrprsinfflg    is null or
             ml_srvabrprsinfflg    = " "   then
             let l_data = null
             let l_hora = null
          else

             let l_data = aux_today
             let aux_hora = aux_hora[1,3], "00"
             let l_hora = aux_hora
          end if



          #  Retorno nao entra no acn imd pelo laudo

          if (l_obter_qrv = true or d_cts71m00.imdsrvflg = "S")
                and d_cts71m00.atdlibflg  = "S"
                and d_cts71m00.servicorg  is null then

                call cts71m00_imdsrvflg(a_cts71m00[1].lclltt,
                                        a_cts71m00[1].lcllgt,
                                        g_documento.acao,
                                        g_documento.atdsrvorg,
                                        d_cts71m00.socntzcod,
                                        d_cts71m00.espcod,
                                        a_cts71m00[1].cidnom,
                                        a_cts71m00[1].ufdcod,
                                        l_data,
                                        l_hora,
                                        a_cts71m00[1].c24lclpdrcod)
                     returning d_cts71m00.imdsrvflg,
                               m_veiculo_aciona,
                               l_cotadisponivel,
                               w_cts71m00.atddatprg,
                               w_cts71m00.atdhorprg,
                               l_mpacidcod

             let l_imdsrvflg = d_cts71m00.imdsrvflg
          else
             let w_cts71m00.atddatprg = l_data
             let w_cts71m00.atdhorprg = l_hora
          end if

    after field imdsrvflg
          display by name d_cts71m00.imdsrvflg

          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts71m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if

          if (m_cidnom != a_cts71m00[1].cidnom) or
             (m_ufdcod != a_cts71m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts71m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if

          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts71m00.imdsrvflg
          end if

          if m_cidnom is null then
             let m_cidnom = a_cts71m00[1].cidnom
          end if

          if m_ufdcod is null then
             let m_ufdcod = a_cts71m00[1].ufdcod
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

          if d_cts71m00.imdsrvflg <> "S"    and
             d_cts71m00.imdsrvflg <> "N"    then

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

             let w_cts71m00.atdprscod = l_pstcoddig

          end if

          if m_veiculo_aciona is null and
             l_imdsrvflg = "N" and
             d_cts71m00.imdsrvflg = "S" and  m_alt_end = "N"  and
             l_cotadisponivel = false then
             error "Nao e possivel registrar servico imediato" sleep 1
             let l_obter_qrv = false
             let d_cts71m00.imdsrvflg = "S"
             next field imdsrvflg
          end if

          ## Se obteve data/hora programada mas mudou a flag p/imediato
          ## manter como programado.
          if w_cts71m00.atddatprg is not null and
             w_cts71m00.atdhorprg is not null and
             l_imdsrvflg = "N" and
             d_cts71m00.imdsrvflg = "S" then
             let d_cts71m00.imdsrvflg = "N"
          end if

          if l_cotadisponivel = true and d_cts71m00.imdsrvflg = "S" then
             let w_cts71m00.atddatprg = null
             let w_cts71m00.atdhorprg = null
          end if

          if (g_documento.acao = "ALT" or g_documento.acao = "RAD") and
             d_cts71m00.imdsrvflg = "S" then
             let w_cts71m00.atddatprg = null
             let w_cts71m00.atdhorprg = null
          end if

	        if (ws_acao = "RET") then
             let w_cts71m00.atdhorprg = null
          end if

          # Considerado que todas as regras de negocio sobre a questao da regulacao
          # sao tratadas do lado do AW, mantendo no laudo somente a chamada ao servico
          if m_agendaw = true
             then
             # obter a chave de regulacao no AW
	            ##-- SPR-2015-15533 - Inicio
                #display 'entrada'
                #DISPLAY 'g_documento.atdsrvorg :',g_documento.atdsrvorg
                #DISPLAY 'd_cts71m00.asitipcod  :',d_cts71m00.asitipcod
                #DISPLAY 'd_cts71m00.socntzcod  :',d_cts71m00.socntzcod
                #DISPLAY 'd_cts71m00.espcod     :',d_cts71m00.espcod
                #display '---------------------------------------------'

             let g_documento.c24pbmcod    = d_cts71m00.c24pbmcod
             let g_documento.atddfttxt    = d_cts71m00.atddfttxt clipped
             let g_documento.socntzcod    = d_cts71m00.socntzcod
             let g_documento.socntzdes    = d_cts71m00.socntzdes clipped
             ##-- SPR-2015-15533 - Fim

             call cts02m08(w_cts71m00.atdfnlflg,
                           d_cts71m00.imdsrvflg,
                           m_altcidufd,
                           d_cts71m00.prslocflg,
                           w_cts71m00.atdhorpvt,
                           w_cts71m00.atddatprg,
                           w_cts71m00.atdhorprg,
                           w_cts71m00.atdpvtretflg,
                           m_rsrchv,
                           m_operacao,
                           "",
                           a_cts71m00[1].cidnom,
                           a_cts71m00[1].ufdcod,
                           "",   # codigo de assistencia, nao existe no Ct24h
                           "",   # codigo do veiculo, somente Auto
                           "",   # categoria tarifaria, somente Auto
                           d_cts71m00.imdsrvflg,
                           a_cts71m00[1].c24lclpdrcod,
                           a_cts71m00[1].lclltt,
                           a_cts71m00[1].lcllgt,
                           g_documento.ciaempcod,
                           g_documento.atdsrvorg,
                           d_cts71m00.asitipcod,
                           d_cts71m00.socntzcod, # natureza
                           d_cts71m00.espcod)    # sub-natureza
                 returning w_cts71m00.atdhorpvt,
                           w_cts71m00.atddatprg,
                           w_cts71m00.atdhorprg,
                           w_cts71m00.atdpvtretflg,
                           d_cts71m00.imdsrvflg,
                           m_rsrchv,
                           m_operacao,
                           m_altdathor
             display by name d_cts71m00.imdsrvflg

             if int_flag
                then
                let int_flag = false
                next field imdsrvflg
             end if

          else  # regula��o antiga
          while true

             if d_cts71m00.imdsrvflg = "N"  and
                g_documento.acao <> "ALT"   and
                g_documento.acao <> "RAD"  then

                let w_cts71m00.atdhorprg = null
                let w_cts71m00.atddatprg = null

                call ctc59m03 ( a_cts71m00[1].cidnom,
                                a_cts71m00[1].ufdcod,
                                g_documento.atdsrvorg,
                                d_cts71m00.socntzcod,
                                aux_today,
                                aux_hora)
                     returning  w_cts71m00.atddatprg,
                                w_cts71m00.atdhorprg

                if w_cts71m00.atddatprg is null then
                   if w_cts71m00.atdhorprg is null then
                      error "Cota n�o disponivel"
                      sleep 3
                      next field imdsrvflg
                   else
                      let w_cts71m00.atdhorprg = null
                   end if
                end if
             end if


             call cts02m03(w_cts71m00.atdfnlflg, d_cts71m00.imdsrvflg,
                           w_cts71m00.atdhorpvt, w_cts71m00.atddatprg,
                           w_cts71m00.atdhorprg, w_cts71m00.atdpvtretflg)
                 returning w_cts71m00.atdhorpvt, l_data,
                           l_hora, w_cts71m00.atdpvtretflg

             if d_cts71m00.imdsrvflg = "S"  then
                 if w_cts71m00.atdhorpvt is null        then
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

             if w_cts71m00.atddatprg is null or
                l_data <> w_cts71m00.atddatprg or
                l_hora <> w_cts71m00.atdhorprg then

                ## se a data/hora programa for <> da agenda
                let w_horac = l_hora
                let w_horac = w_horac[1,2]
                let w_horaprg = w_horac

                let w_horac = aux_hora
                let w_horac = w_horac[1,2]
                let w_horaatu = w_horac

                #caso seja um servico programado e a hora informada
                #seja menor do que 1 hora da hora atual - exibe agenda

                ###if w_cts71m00.atddatprg  = aux_today and
                if l_data  = aux_today and
                  (w_horaprg - w_horaatu) < 1 and
                   ml_srvabrprsinfflg = "N" then   ## PSS

                   if cpl_atdsrvnum        is not null and
                      cpl_atdsrvano        is not null and
                      d_cts71m00.retprsmsmflg = 'S'    then
                       error "Para servico programado o horario deve ser maior que 1 hrs da hora atual"
                   else

                       let w_cts71m00.atdhorprg = null
                       call ctc59m03 ( a_cts71m00[1].cidnom,
                                       a_cts71m00[1].ufdcod,
                                       g_documento.atdsrvorg,
                                       d_cts71m00.socntzcod,
                                       aux_today,
                                       aux_hora)
                            returning  w_cts71m00.atddatprg,
                                       w_cts71m00.atdhorprg
                   end if
                   continue while
                else
                   # verificar se tem cota para data/hora informada

                   if cpl_atdsrvnum        is not null and
                      cpl_atdsrvano        is not null and
                      d_cts71m00.servicorg is not null and
                      d_cts71m00.retprsmsmflg = 'S'    then

                       if l_data is not null and
                          l_hora is not null then

                           # Verifica se viatura do atendimento original esta ocupada 2 horas antes
                           # ou 2 horas depois do agendamento do retorno
                           call cts71m00_verifica_retorno(g_documento.atdsrvnum
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
                               let w_cts71m00.atddatprg = l_data
                               let w_cts71m00.atdhorprg = l_hora
                           end if
                       end if
                   else

                       let l_tem_cota = false
                       call ctc59m03_quota_imediato
                            (l_mpacidcod, g_documento.atdsrvorg,
                             d_cts71m00.socntzcod, l_data, l_hora)
                             returning l_tem_cota

                       if l_tem_cota = false and m_tem_outros_srv = "N" then

                          call ctc59m03 (a_cts71m00[1].cidnom,
                                         a_cts71m00[1].ufdcod,
                                         g_documento.atdsrvorg,
                                         d_cts71m00.socntzcod,
                                         aux_today, aux_hora)
                               returning w_cts71m00.atddatprg,
                                         w_cts71m00.atdhorprg
                          continue while
                       else
                          let w_cts71m00.atddatprg = l_data
                          let w_cts71m00.atdhorprg = l_hora
                       end if
                   end if
                end if

             else
                let w_cts71m00.atddatprg = l_data
                let w_cts71m00.atdhorprg = l_hora
             end if

             exit while

          end while
          end if
          # FIM PSI-2013-00440PR

          call cts40g03_data_hora_banco(2)
               returning l_data_2, l_hora_2
          if (w_cts71m00.atddatprg is not null or w_cts71m00.atddatprg = " ") and
             (w_cts71m00.atdhorprg is not null or w_cts71m00.atdhorprg = " ") then
               if w_cts71m00.atddatprg < l_data_2   then
                  let w_cts71m00.atddatprg = null
                  let w_cts71m00.atdhorprg = null

                  next field atdlibflg
               else
                   if w_cts71m00.atddatprg = l_data_2 and
                      w_cts71m00.atdhorprg < l_hora_2  then
                      let w_cts71m00.atddatprg = null
                      let w_cts71m00.atdhorprg = null

                      next field atdlibflg
                   end if
               end if
          end if
          if w_cts71m00.atddatprg is not null and
             w_cts71m00.atdhorprg is not null and
             d_cts71m00.servicorg is not null and
             d_cts71m00.retprsmsmflg = 'S'    then

             # Verifica se viatura do atendimento original esta ocupada 2 horas antes
             # ou 2 horas depois do agendamento do retorno
             call cts71m00_verifica_retorno(g_documento.atdsrvnum
                                           ,g_documento.atdsrvano
                                           ,cpl_atdsrvnum
                                           ,cpl_atdsrvano
                                           ,w_cts71m00.atddatprg
                                           ,w_cts71m00.atdhorprg
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
                 let w_cts71m00.atddatprg = null
                 let w_cts71m00.atdhorprg = null
                 next field atdlibflg
              end if
          end if
          let d_cts71m00.atdprinvlcod  = 2

          whenever error continue
          open c_cts71m00_015 using d_cts71m00.atdprinvlcod
          fetch c_cts71m00_015 into d_cts71m00.atdprinvldes
          whenever error stop
          close c_cts71m00_015


          display by name d_cts71m00.atdprinvlcod
          display by name d_cts71m00.atdprinvldes

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
          call cts71m00_cotas( m_veiculo_aciona,
                               l_cotadisponivel,
                               d_cts71m00.imdsrvflg,
                               w_cts71m00.atddatprg,
                               w_cts71m00.atdhorprg,
                               g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               "",
                               "",
                               "",
                               "",
                               g_documento.atdsrvorg,
                               d_cts71m00.socntzcod)
          end if

          ########## SE ESTIVER ALTERANDO SRV ORIGINAL/MULTIPLO ####
          if m_confirma_alt_prog = 'S' then

             #Atualizar a programacao
             call cts71m00_alt_prog(g_documento.atdsrvnum
                                    ,g_documento.atdsrvano
                                    ,m_obter_mult
                                    ,w_cts71m00.atddatprg
                                    ,w_cts71m00.atdhorprg
                                    ,w_cts71m00.atdhorpvt
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

      # Se interrompeu laudo, mas est� com prestador bloqueado
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then

         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
            = "S"  then
             if m_veiculo_aciona is not null then
                call cts40g06_desb_veic(m_veiculo_aciona,999997)
                     returning l_resultado
                let m_veiculo_aciona = null
            end if

            call opsfa006_inicializa() #--- SPR-2014-28503-Incializa variaveis
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

   on key (control-f) #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
      call opsfa009(mr_teclas.*)

   on key (F1)
      if w_cts71m00.lignum is not null then

         #-- Acessa a tabela datmligacao --#

         whenever error continue
         open c_cts71m00_032 using w_cts71m00.lignum
         fetch c_cts71m00_032 into g_documento.c24astcod
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "Erro ao acessar a tabela datmligacao, erro: "
                    ,sqlca.sqlcode
         end if
         close  c_cts71m00_032
      end if

      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F2)
      # Checa se existe tela de servico remocao ja aberta
      whenever error continue
      if ws_tela = "RET" then
         open window cts71m00s at 04,02 with form "cts71m00"
                              attribute(form line 1)
      else
         open window cts71m00r at 04,02 with form "cts71m00"
                              attribute(form line 1)
      end if
      if status = 0     then
         let erros_chk = "N"
         if ws_tela = "RET" then
            close window cts71m00s
         else
            close window cts71m00r
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
            open c_cts71m00_033 using g_documento.atdsrvnum,
                                      g_documento.atdsrvano
            fetch c_cts71m00_033 into ws.refatdsrvnum, ws.refatdsrvano
            whenever error stop
            close c_cts71m00_033

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
            let dS_cts71m00.*    = d_cts71m00.*
            let wS_cts71m00.*    = w_cts71m00.*
            let aS_cts71m00.*    = a_cts71m00[1].*
            let cplS_atdsrvnum   = cpl_atdsrvnum
            let cplS_atdsrvano   = cpl_atdsrvano
            let cplS_atdsrvorg   = cpl_atdsrvorg

            let g_documento.atdsrvnum = ws.refatdsrvnum
            let g_documento.atdsrvano = ws.refatdsrvano

            call cts04g00('cts71m00') returning ws.retflg

            let g_documento.c24astcod = l_c24astcod_slv
            let g_documento.acao      = ws.acaoslv
            let ws_acaorigem          = ws.acaorislv
            let g_documento.atdsrvnum = ws.auxatdsrvnum
            let g_documento.atdsrvano = ws.auxatdsrvano
            let ws_acao               = "RET"
            let ws_tela               = "RET"
            let d_cts71m00.*          = dS_cts71m00.*
            let w_cts71m00.*          = wS_cts71m00.*
            let a_cts71m00[1].*       = aS_cts71m00.*
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
               let dS_cts71m00.*    = d_cts71m00.*
               let wS_cts71m00.*    = w_cts71m00.*
               let aS_cts71m00.*    = a_cts71m00[1].*
               let cplS_atdsrvnum   = cpl_atdsrvnum
               let cplS_atdsrvano   = cpl_atdsrvano
               let cplS_atdsrvorg   = cpl_atdsrvorg

               let g_documento.atdsrvnum = ws.refatdsrvnum
               let g_documento.atdsrvano = ws.refatdsrvano

               call cts04g00('cts71m00') returning ws.retflg

               let g_documento.acao      = ws.acaoslv
               let g_documento.atdsrvnum = ws.auxatdsrvnum
               let g_documento.atdsrvano = ws.auxatdsrvano
               let ws_acao               = ws_acaorigem
               let ws_tela               = "SRV"
               let d_cts71m00.*          = dS_cts71m00.*
               let w_cts71m00.*          = wS_cts71m00.*
               let a_cts71m00[1].*       = aS_cts71m00.*
               let cpl_atdsrvnum         = cplS_atdsrvnum
               let cpl_atdsrvano         = cplS_atdsrvano
               let cpl_atdsrvorg         = cplS_atdsrvorg
            end if
         end if
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)


   #=> SPR-2014-28503 - INIBINDO TRATAMENTO DE F4 (SERVICOS MULTIPLOS)
{
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

         if w_cts71m00.atdfnlflg ="S" then
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

         call consulta_cts71m00()

         display by name d_cts71m00.atdprinvlcod   #--- PSI SPR-2014-28503
         display by name d_cts71m00.atdprinvldes
         display by name d_cts71m00.asitipcod
         display by name d_cts71m00.nom
         display by name d_cts71m00.corsus
         display by name d_cts71m00.cornom
         display by name ws.lclcttnom
         display by name d_cts71m00.orrdat
         display by name d_cts71m00.socntzcod
         display by name d_cts71m00.espcod
         display by name d_cts71m00.espdes
         display by name d_cts71m00.c24pbmcod
         display by name d_cts71m00.atddfttxt
         display by name d_cts71m00.srvretmtvcod
         display by name d_cts71m00.srvretmtvdes
         display by name d_cts71m00.atdlibflg
         display by name d_cts71m00.prslocflg
         display by name d_cts71m00.imdsrvflg
      end if

      let g_documento.acao = m_acao
      let ws_acao = m_acao
      let m_obter_mult = m_salva_mlt
      call cts51g00_cria_temp()
           returning m_criou_tabela
}
   on key (F5)
      if g_documento.acao = "INC" then
         error "Funcionalidade Indisponivel no momento da Inclusao!" sleep 3
      else
      #josiane - grava endere�o correspondencia
         #=> SPR-2014-28503 - FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
         if m_vendaflg       or
            cty27g00_ret = 1 then  #=> PERMITE F.PAGTO (SEM VENDA=CONSULTA)


              #--->>> Endereco de correspondencia - PSI SPR-2014-28503
                whenever error continue
                 select 1 from datmlcl
                  where atdsrvnum = g_documento.atdsrvnum
                    and atdsrvano = g_documento.atdsrvano
                    and c24endtip = 7
              whenever error stop
              if sqlca.sqlcode = 100 then


                call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                              "O MESMO DE OCORRENCIA?",l_linha3, l_linha4)
                    returning l_resultado

                if l_resultado = "S" then #- Endereco corresp - SPR-2014-28503
                   let a_cts71m00[2].lclidttxt    = a_cts71m00[1].lclidttxt
                   let a_cts71m00[2].cidnom       = a_cts71m00[1].cidnom
                   let a_cts71m00[2].ufdcod       = a_cts71m00[1].ufdcod
                   let a_cts71m00[2].brrnom       = a_cts71m00[1].brrnom
                   let a_cts71m00[2].lclbrrnom    = a_cts71m00[1].lclbrrnom
                   let a_cts71m00[2].endzon       = a_cts71m00[1].endzon
                   let a_cts71m00[2].lgdtip       = a_cts71m00[1].lgdtip
                   let a_cts71m00[2].lgdnom       = a_cts71m00[1].lgdnom
                   let a_cts71m00[2].lgdnum       = a_cts71m00[1].lgdnum
                   let a_cts71m00[2].lgdcep       = a_cts71m00[1].lgdcep
                   let a_cts71m00[2].lgdcepcmp    = a_cts71m00[1].lgdcepcmp
                   let a_cts71m00[2].lclltt       = a_cts71m00[1].lclltt
                   let a_cts71m00[2].lcllgt       = a_cts71m00[1].lcllgt
                   let a_cts71m00[2].lclrefptotxt = a_cts71m00[1].lclrefptotxt
                   let a_cts71m00[2].lclcttnom    = a_cts71m00[1].lclcttnom
                   let a_cts71m00[2].dddcod       = a_cts71m00[1].dddcod
                   let a_cts71m00[2].lcltelnum    = a_cts71m00[1].lcltelnum
                   let a_cts71m00[2].c24lclpdrcod = a_cts71m00[1].c24lclpdrcod
                   let a_cts71m00[2].ofnnumdig    = a_cts71m00[1].ofnnumdig
                   let a_cts71m00[2].celteldddcod = a_cts71m00[1].celteldddcod
                   let a_cts71m00[2].celtelnum    = a_cts71m00[1].celtelnum
                   let a_cts71m00[2].endcmp       = a_cts71m00[1].endcmp
                else
                   call cts06g03(7,
                                 13,
                                 w_cts71m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts71m00[2].lclidttxt,
                                 a_cts71m00[2].cidnom,
                                 a_cts71m00[2].ufdcod,
                                 a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom,
                                 a_cts71m00[2].endzon,
                                 a_cts71m00[2].lgdtip,
                                 a_cts71m00[2].lgdnom,
                                 a_cts71m00[2].lgdnum,
                                 a_cts71m00[2].lgdcep,
                                 a_cts71m00[2].lgdcepcmp,
                                 a_cts71m00[2].lclltt,
                                 a_cts71m00[2].lcllgt,
                                 a_cts71m00[2].lclrefptotxt,
                                 a_cts71m00[2].lclcttnom,
                                 a_cts71m00[2].dddcod,
                                 a_cts71m00[2].lcltelnum,
                                 a_cts71m00[2].c24lclpdrcod,
                                 a_cts71m00[2].ofnnumdig,
                                 a_cts71m00[2].celteldddcod,
                                 a_cts71m00[2].celtelnum,
                                 a_cts71m00[2].endcmp,
                                 hist_cts71m00.*, a_cts71m00[2].emeviacod)
                       returning a_cts71m00[2].lclidttxt,
                                 a_cts71m00[2].cidnom,
                                 a_cts71m00[2].ufdcod,
                                 a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom,
                                 a_cts71m00[2].endzon,
                                 a_cts71m00[2].lgdtip,
                                 a_cts71m00[2].lgdnom,
                                 a_cts71m00[2].lgdnum,
                                 a_cts71m00[2].lgdcep,
                                 a_cts71m00[2].lgdcepcmp,
                                 a_cts71m00[2].lclltt,
                                 a_cts71m00[2].lcllgt,
                                 a_cts71m00[2].lclrefptotxt,
                                 a_cts71m00[2].lclcttnom,
                                 a_cts71m00[2].dddcod,
                                 a_cts71m00[2].lcltelnum,
                                 a_cts71m00[2].c24lclpdrcod,
                                 a_cts71m00[2].ofnnumdig,
                                 a_cts71m00[2].celteldddcod,
                                 a_cts71m00[2].celtelnum,
                                 a_cts71m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts71m00.*, a_cts71m00[2].emeviacod
                                 #display "ws.retflg = ",ws.retflg
                end if   #---<<<  Endereco de correspondencia - SPR-2014-28503



                #-----------------------------------
                # Grava locais de correspondencia
                #-----------------------------------
               begin work

                  if a_cts71m00[2].operacao is null then
                     let a_cts71m00[2].operacao = "I"
                  end if

                  let a_cts71m00[2].lclbrrnom = m_subbairro[2].lclbrrnom


                  let ms.codigosql = cts06g07_local( a_cts71m00[2].operacao    ,
                                                   g_documento.atdsrvnum      ,
                                                   g_documento.atdsrvano      ,
                                                   7,    #--- Tp Endereco correspondencia
                                                   a_cts71m00[2].lclidttxt   ,
                                                   a_cts71m00[2].lgdtip      ,
                                                   a_cts71m00[2].lgdnom      ,
                                                   a_cts71m00[2].lgdnum      ,
                                                   a_cts71m00[2].lclbrrnom   ,
                                                   a_cts71m00[2].brrnom      ,
                                                   a_cts71m00[2].cidnom      ,
                                                   a_cts71m00[2].ufdcod      ,
                                                   a_cts71m00[2].lclrefptotxt,
                                                   a_cts71m00[2].endzon      ,
                                                   a_cts71m00[2].lgdcep      ,
                                                   a_cts71m00[2].lgdcepcmp   ,
                                                   a_cts71m00[2].lclltt      ,
                                                   a_cts71m00[2].lcllgt      ,
                                                   a_cts71m00[2].dddcod      ,
                                                   a_cts71m00[2].lcltelnum   ,
                                                   a_cts71m00[2].lclcttnom   ,
                                                   a_cts71m00[2].c24lclpdrcod,
                                                   a_cts71m00[2].ofnnumdig,
                                                   a_cts71m00[2].emeviacod   ,
                                                   a_cts71m00[2].celteldddcod,
                                                   a_cts71m00[2].celtelnum   ,
                                                   a_cts71m00[2].endcmp )


               commit work
            end if
            #fim josiane - grava endere�o correspondencia




            if not opsfa006_altera(g_documento.atdsrvnum
                                  ,g_documento.atdsrvano
                                  ,g_documento.prpnum
                                  ,m_pbmonline             #- SPR-2014-28503
                                  ,0  #- Distancia Ocorr X Destino - SPR-2015-13708
                                  ,w_cts71m00.atddat       #- SPR-2015-13708
                                  ,d_cts71m00.prslocflg    #- SPR-2015-15533
                                  ,d_cts71m00.nom          #- SPR-2015-11582
                                  ,d_cts71m00.nscdat) then #- SPR-2015-11582
               #- SPR 2015-13708 - Melhorias Calculo SKU
               let int_flag = true
               exit input
            end if
         else
            error "Nao possui Venda/F.Pagto associados..."
         end if
      end if

   on key (F6)
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         call cts10m02(hist_cts71m00.*) returning hist_cts71m00.*
      else
         call cts40g03_data_hora_banco(2) returning m_data, m_hora
         let aux_today = m_data
         let aux_hora = m_hora
         let ws.acaoslv = g_documento.acao      #=> SPR-2014-28503 - CORRECAO
         let g_documento.acao = null

         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat, aux_today, aux_hora)

         ###let g_documento.acao = ws_acaorigem #=> SPR-2014-28503 - CORRECAO
         let g_documento.acao = ws.acaoslv      #=> SPR-2014-28503 - CORRECAO

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
         open c_cts71m00_034 using g_documento.atdsrvnum,
                                   g_documento.atdsrvano
         fetch c_cts71m00_034 into l_atdlibflg
         whenever error stop
         close c_cts71m00_034

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

               call consulta_cts71m00()

               display by name d_cts71m00.atdprinvlcod  #--- PSI SPR-2014-28503
               display by name d_cts71m00.atdprinvldes
               display by name d_cts71m00.asitipcod
               display by name d_cts71m00.nom
               display by name d_cts71m00.corsus
               display by name d_cts71m00.cornom
               display by name ws.lclcttnom
               display by name d_cts71m00.orrdat
               display by name d_cts71m00.socntzcod
               display by name d_cts71m00.espcod
               display by name d_cts71m00.espdes
               display by name d_cts71m00.c24pbmcod
               display by name d_cts71m00.atddfttxt
               display by name d_cts71m00.srvretmtvcod
               display by name d_cts71m00.srvretmtvdes
               display by name d_cts71m00.atdlibflg
               display by name d_cts71m00.prslocflg
               display by name d_cts71m00.imdsrvflg
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if
         end if
      end if

   #=> SPR-2014-28503 - ACIONA A TELA DE MUDANCA DE ETAPA
   on key (control-t)
      if g_documento.atdsrvnum is null or
         g_documento.acao = "INC"      then
         error "Funcao nao disponivel na inclusao!"
         continue input
      end if
      if not m_vendaflg then
         error "Nao existe VENDA associada a este Laudo..."
         continue input
      end if
      if not opsfa005_etapas(g_documento.atdsrvnum,
                             g_documento.atdsrvano) then
         error "ERRO AO ALTERAR ETAPA DA VENDA. ACIONE A INFORMATICA!"
         continue input
      end if

   on key (control-e)

     let lr_email.ramcod    = g_documento.ramcod
     let lr_email.c24astcod = g_documento.c24astcod
     let lr_email.ligcvntip = g_documento.ligcvntip
     let lr_email.lignum    = w_cts71m00.lignum #g_documento.lignum
     let lr_email.atdsrvnum = g_documento.atdsrvnum
     let lr_email.atdsrvano = g_documento.atdsrvano
     let lr_email.solnom    = g_documento.solnom

     call figrc072_setTratarIsolamento() -- > psi 223689

     call cts30m00(lr_email.ramcod   , lr_email.c24astcod,
                   lr_email.ligcvntip, lr_email.succod,
                   lr_email.aplnumdig, lr_email.itmnumdig,
                   lr_email.lignum   , lr_email.atdsrvnum,
                   lr_email.atdsrvano, lr_email.prporg,
                   lr_email.prpnumdig, lr_email.solnom)
          returning l_envio
          if g_isoAuto.sqlCodErr <> 0 then
             error "Fun��o cts30m00 insdisponivel no momento ! Avise a Informatica !" sleep 2
             return
          else
             error "E-mail enviado com sucesso."
          end if


    on key (control-o)  #--->>>  Endereco correspondencia - PSI SPR-2014-28503
       if g_documento.atdsrvnum is null or
          g_documento.acao = "INC"      then
          error "Funcao nao disponivel na inclusao!"
          continue input
       end if

       if m_pbmonline is not null then  #- PSI SPR-2014-28503 - Venda Online
          error "FUNCAO NAO DISPONIVEL - VENDA ONLINE NAO CONCLUIDA" sleep 2
          continue input
       end if

       # Informacoes do cliente --- SPR-2015-03912-Cadastro Clientes ---
       call opsfa014_conscadcli(g_documento.cgccpfnum,
                                g_documento.cgcord,
                                g_documento.cgccpfdig)
                      returning lr_retcli.coderro
                               ,lr_retcli.msgerro
                               ,lr_retcli.clinom
                               ,lr_retcli.nscdat
       if lr_retcli.coderro = true then
          if (lr_retcli.clinom is null or lr_retcli.clinom = " ") and
             (lr_retcli.nscdat is null or lr_retcli.nscdat = " ") then
             error "ALTERACAO NAO PERMITIDA - PROCESSO DA VENDA ONLINE NAO ",
                   "FOI CONCLUIDO"
             sleep 2
             continue input
          end if
       end if
       # --- SPR-2015-03912-Cadastro Clientes ---

       let l_c24endtip = 7

       #--------------------------------------------------------------------
       # Informacoes do local da correspondencia
       #--------------------------------------------------------------------
       call ctx04g00_local_gps(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               l_c24endtip)
                     returning a_cts71m00[2].lclidttxt
                              ,a_cts71m00[2].lgdtip
                              ,a_cts71m00[2].lgdnom
                              ,a_cts71m00[2].lgdnum
                              ,a_cts71m00[2].lclbrrnom
                              ,a_cts71m00[2].brrnom
                              ,a_cts71m00[2].cidnom
                              ,a_cts71m00[2].ufdcod
                              ,a_cts71m00[2].lclrefptotxt
                              ,a_cts71m00[2].endzon
                              ,a_cts71m00[2].lgdcep
                              ,a_cts71m00[2].lgdcepcmp
                              ,a_cts71m00[2].lclltt
                              ,a_cts71m00[2].lcllgt
                              ,a_cts71m00[2].dddcod
                              ,a_cts71m00[2].lcltelnum
                              ,a_cts71m00[2].lclcttnom
                              ,a_cts71m00[2].c24lclpdrcod
                              ,a_cts71m00[2].celteldddcod
                              ,a_cts71m00[2].celtelnum
                              ,a_cts71m00[2].endcmp
                              ,ws.cogidosql
                              ,a_cts71m00[2].emeviacod

       let m_subbairro[2].lclbrrnom = a_cts71m00[2].lclbrrnom

       call cts06g10_monta_brr_subbrr(a_cts71m00[2].brrnom,
                                      a_cts71m00[2].lclbrrnom)
            returning a_cts71m00[2].lclbrrnom

       let a_cts71m00[2].lgdtxt = a_cts71m00[2].lgdtip clipped, " ",
                                  a_cts71m00[2].lgdnom clipped, " ",
                                  a_cts71m00[2].lgdnum using "<<<<#"

       #--->>>  Endereco correspondencia - PSI SPR-2014-28503
       let m_acesso_ind = false
       call cta00m06_acesso_indexacao_aut(g_documento.atdsrvorg)
            returning m_acesso_ind

       if m_acesso_ind = false then
          call cts06g03(l_c24endtip
                       ,g_documento.atdsrvorg
                       ,g_documento.ligcvntip
                       ,aux_today
                       ,aux_hora
                       ,a_cts71m00[2].lclidttxt
                       ,a_cts71m00[2].cidnom
                       ,a_cts71m00[2].ufdcod
                       ,a_cts71m00[2].brrnom
                       ,a_cts71m00[2].lclbrrnom
                       ,a_cts71m00[2].endzon
                       ,a_cts71m00[2].lgdtip
                       ,a_cts71m00[2].lgdnom
                       ,a_cts71m00[2].lgdnum
                       ,a_cts71m00[2].lgdcep
                       ,a_cts71m00[2].lgdcepcmp
                       ,a_cts71m00[2].lclltt
                       ,a_cts71m00[2].lcllgt
                       ,a_cts71m00[2].lclrefptotxt
                       ,a_cts71m00[2].lclcttnom
                       ,a_cts71m00[2].dddcod
                       ,a_cts71m00[2].lcltelnum
                       ,a_cts71m00[2].c24lclpdrcod
                       ,a_cts71m00[2].ofnnumdig
                       ,a_cts71m00[2].celteldddcod
                       ,a_cts71m00[2].celtelnum
                       ,a_cts71m00[2].endcmp
                       ,hist_cts71m00.*
                       ,a_cts71m00[2].emeviacod )
             returning  a_cts71m00[2].lclidttxt
                       ,a_cts71m00[2].cidnom
                       ,a_cts71m00[2].ufdcod
                       ,a_cts71m00[2].brrnom
                       ,a_cts71m00[2].lclbrrnom
                       ,a_cts71m00[2].endzon
                       ,a_cts71m00[2].lgdtip
                       ,a_cts71m00[2].lgdnom
                       ,a_cts71m00[2].lgdnum
                       ,a_cts71m00[2].lgdcep
                       ,a_cts71m00[2].lgdcepcmp
                       ,a_cts71m00[2].lclltt
                       ,a_cts71m00[2].lcllgt
                       ,a_cts71m00[2].lclrefptotxt
                       ,a_cts71m00[2].lclcttnom
                       ,a_cts71m00[2].dddcod
                       ,a_cts71m00[2].lcltelnum
                       ,a_cts71m00[2].c24lclpdrcod
                       ,a_cts71m00[2].ofnnumdig
                       ,a_cts71m00[2].celteldddcod
                       ,a_cts71m00[2].celtelnum
                       ,a_cts71m00[2].endcmp
                       ,ws.retflg
                       ,hist_cts71m00.*
                       ,a_cts71m00[2].emeviacod
       else
          call cts06g11(l_c24endtip
                       ,g_documento.atdsrvorg
                       ,g_documento.ligcvntip
                       ,aux_today
                       ,aux_hora
                       ,a_cts71m00[2].lclidttxt
                       ,a_cts71m00[2].cidnom
                       ,a_cts71m00[2].ufdcod
                       ,a_cts71m00[2].brrnom
                       ,a_cts71m00[2].lclbrrnom
                       ,a_cts71m00[2].endzon
                       ,a_cts71m00[2].lgdtip
                       ,a_cts71m00[2].lgdnom
                       ,a_cts71m00[2].lgdnum
                       ,a_cts71m00[2].lgdcep
                       ,a_cts71m00[2].lgdcepcmp
                       ,a_cts71m00[2].lclltt
                       ,a_cts71m00[2].lcllgt
                       ,a_cts71m00[2].lclrefptotxt
                       ,a_cts71m00[2].lclcttnom
                       ,a_cts71m00[2].dddcod
                       ,a_cts71m00[2].lcltelnum
                       ,a_cts71m00[2].c24lclpdrcod
                       ,a_cts71m00[2].ofnnumdig
                       ,a_cts71m00[2].celteldddcod
                       ,a_cts71m00[2].celtelnum
                       ,a_cts71m00[2].endcmp
                       ,hist_cts71m00.*
                       ,a_cts71m00[2].emeviacod )
              returning a_cts71m00[2].lclidttxt
                       ,a_cts71m00[2].cidnom
                       ,a_cts71m00[2].ufdcod
                       ,a_cts71m00[2].brrnom
                       ,a_cts71m00[2].lclbrrnom
                       ,a_cts71m00[2].endzon
                       ,a_cts71m00[2].lgdtip
                       ,a_cts71m00[2].lgdnom
                       ,a_cts71m00[2].lgdnum
                       ,a_cts71m00[2].lgdcep
                       ,a_cts71m00[2].lgdcepcmp
                       ,a_cts71m00[2].lclltt
                       ,a_cts71m00[2].lcllgt
                       ,a_cts71m00[2].lclrefptotxt
                       ,a_cts71m00[2].lclcttnom
                       ,a_cts71m00[2].dddcod
                       ,a_cts71m00[2].lcltelnum
                       ,a_cts71m00[2].c24lclpdrcod
                       ,a_cts71m00[2].ofnnumdig
                       ,a_cts71m00[2].celteldddcod
                       ,a_cts71m00[2].celtelnum
                       ,a_cts71m00[2].endcmp
                       ,ws.retflg
                       ,hist_cts71m00.*
                       ,a_cts71m00[2].emeviacod
          end if    #---<<<  Endereco de correspondencia - PSI SPR-2014-28503

          if ws.retflg = "N" then
             error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3
             continue input
          end if

          whenever error continue

          open c_cts71m00_010 using g_documento.atdsrvano,
                                    g_documento.atdsrvnum,
                                    l_c24endtip
          fetch c_cts71m00_010 into a_cts71m00[2].ofnnumdig

          whenever error stop
          if sqlca.sqlcode = 0  then
             let a_cts71m00[2].operacao = "M"
          else
             if sqlca.sqlcode = 100 then
                let a_cts71m00[2].operacao = "I"
             else
                error " Erro (", ws.cogidosql using "<<<<<&", ") na leitura local de ocorrencia(upd). AVISE A INFORMATICA!"
                return
             end if
          end if

          let a_cts71m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

          begin work

          let ws.cogidosql = cts06g07_local(a_cts71m00[2].operacao
                                         ,g_documento.atdsrvnum
                                         ,g_documento.atdsrvano
                                         ,l_c24endtip   #--- Tp Endereco correspondencia
                                         ,a_cts71m00[2].lclidttxt
                                         ,a_cts71m00[2].lgdtip
                                         ,a_cts71m00[2].lgdnom
                                         ,a_cts71m00[2].lgdnum
                                         ,a_cts71m00[2].lclbrrnom
                                         ,a_cts71m00[2].brrnom
                                         ,a_cts71m00[2].cidnom
                                         ,a_cts71m00[2].ufdcod
                                         ,a_cts71m00[2].lclrefptotxt
                                         ,a_cts71m00[2].endzon
                                         ,a_cts71m00[2].lgdcep
                                         ,a_cts71m00[2].lgdcepcmp
                                         ,a_cts71m00[2].lclltt
                                         ,a_cts71m00[2].lcllgt
                                         ,a_cts71m00[2].dddcod
                                         ,a_cts71m00[2].lcltelnum
                                         ,a_cts71m00[2].lclcttnom
                                         ,a_cts71m00[2].c24lclpdrcod
                                         ,a_cts71m00[2].ofnnumdig
                                         ,a_cts71m00[2].emeviacod
                                         ,a_cts71m00[2].celteldddcod
                                         ,a_cts71m00[2].celtelnum
                                         ,a_cts71m00[2].endcmp) # Amilton

          if ws.cogidosql is null   or
             ws.cogidosql <> 0      then
                   error " Erro (", ws.cogidosql, ") na alteracao do local de correspondencia. AVISE A INFORMATICA!"
             rollback work
             prompt "" for char l_prompt_key
             return false
          end if

          #--- SPR-2015-03912-Atualiza Pedido ---
          call opsfa015_inscadped(g_documento.cgccpfnum
                                 ,g_documento.cgcord
                                 ,g_documento.cgccpfdig
                                 ,g_documento.atdsrvnum
                                 ,g_documento.atdsrvano
                                 ,"1") #--- Online - SPR-2015-22413
              returning lr_retorno.resultado
                       ,lr_retorno.mensagem
                       ,d_cts71m00.srvpedcod
          if lr_retorno.resultado = false then
             rollback work
             let int_flag = true
             error lr_retorno.mensagem clipped
             prompt "ERRO NA ATUALIZACAO DO PEDIDO. AVISE INFORMATICA"
                    for char l_prompt_key
             exit input
          end if
          display by name d_cts71m00.srvpedcod
          #--- SPR-2015-03912-Atualiza Pedido ---

          commit work

          error "Endereco de correspondencia alterado com sucesso " sleep 2

          #---<<<  Endereco de correspondencia - PSI SPR-2014-28503

   #=> SPR-2014-10068 - CONSULTA A JUSTIFICATIVAS
   on key (control-u)
      if g_documento.atdsrvnum is null or
         g_documento.acao = "INC"      then
         error "Funcao nao disponivel na inclusao!"
         continue input
      end if
      call opsfa003_consulta_justificativa(g_documento.atdsrvnum,
                                           g_documento.atdsrvano)

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts71m00.* to null
 end if

return hist_cts71m00.*

end function  ###  input_cts71m00

#-------------------------------------------------------------------------------
 function cts71m00_copia()
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

 define l_c24endtip   like datmlcl.c24endtip
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
  open c_cts71m00_035 using g_documento.atdsrvnum,
                            g_documento.atdsrvano
  fetch c_cts71m00_035 into d_cts71m00.atddfttxt,
                            d_cts71m00.asitipcod,
                            ws.nom_cp,
                            ws.corsus_cp,
                            ws.cornom_cp

  whenever error stop

  if d_cts71m00.nom is null then
     let d_cts71m00.nom  =  ws.nom_cp
  end if

  if d_cts71m00.corsus is null then
     let d_cts71m00.corsus  =  ws.corsus_cp
     let d_cts71m00.cornom  =  ws.cornom_cp
  end if

 #------------------------------------------------
 # Acessa ligacao
 #------------------------------------------------
  whenever error continue
  open c_cts71m00_036 using g_documento.atdsrvnum,
                            g_documento.atdsrvano


  foreach c_cts71m00_036 into ws.c24solnom_cp, ws.ligcvntip_cp
     exit foreach
  end foreach
  whenever error stop
  close c_cts71m00_036

  if g_documento.ligcvntip is null and
     ws.ligcvntip_cp is not null   then

     let g_documento.ligcvntip = ws.ligcvntip_cp
     let w_cts71m00.ligcvntip  = g_documento.ligcvntip

     end if

 #------------------------------------------------
 # Acessa dados do RE
 #------------------------------------------------


  whenever error continue
  open c_cts71m00_037 using cpl_atdsrvnum,
                            cpl_atdsrvano
  fetch c_cts71m00_037 into d_cts71m00.lclrsccod
                            ,ws.atdorgsrvnum
                            ,ws.atdorgsrvano
                            ,d_cts71m00.socntzcod
                            ,d_cts71m00.orrdat
                            ,d_cts71m00.espcod
  whenever error stop
  close c_cts71m00_037

  if ws.atdorgsrvnum is null  or
     ws_acaorigem    = "RET"  then
     let ws.atdorgsrvnum = cpl_atdsrvnum
     let ws.atdorgsrvano = cpl_atdsrvano
  end if

  let cpl_atdsrvnum = ws.atdorgsrvnum
  let cpl_atdsrvano = ws.atdorgsrvano

    whenever error continue
    open c_cts71m00_038 using ws.atdorgsrvnum,
                              ws.atdorgsrvano
    fetch c_cts71m00_038 into ws.atdsrvseq

    whenever error stop

    if sqlca.sqlcode = 0 then

       whenever error continue
       open c_cts71m00_039 using ws.atdorgsrvnum
                                ,ws.atdorgsrvano
                                ,ws.atdsrvseq
       fetch c_cts71m00_039 into ws.pstcoddig,ws.srrcoddig,ws.socvclcod

       whenever error stop

       if ws.socvclcod is not null then

          whenever error continue
          open c_cts71m00_040 using ws.socvclcod
          fetch c_cts71m00_040 into ws.atdvclsgl
          whenever error stop
          close c_cts71m00_040

       end if
    else
       initialize ws.pstcoddig, ws.srrcoddig, ws.socvclcod to null
       return
    end if

    let w_cts71m00.atdprscod = ws.pstcoddig
    let w_cts71m00.srrcoddig = ws.srrcoddig
    let w_cts71m00.socvclcod = ws.socvclcod

  call ctx04g00_local_gps(cpl_atdsrvnum, cpl_atdsrvano, 1)
                returning a_cts71m00[1].lclidttxt   ,
                          a_cts71m00[1].lgdtip      ,
                          a_cts71m00[1].lgdnom      ,
                          a_cts71m00[1].lgdnum      ,
                          a_cts71m00[1].lclbrrnom   ,
                          a_cts71m00[1].brrnom      ,
                          a_cts71m00[1].cidnom      ,
                          a_cts71m00[1].ufdcod      ,
                          a_cts71m00[1].lclrefptotxt,
                          a_cts71m00[1].endzon      ,
                          a_cts71m00[1].lgdcep      ,
                          a_cts71m00[1].lgdcepcmp   ,
                          a_cts71m00[1].lclltt      ,
                          a_cts71m00[1].lcllgt      ,
                          a_cts71m00[1].dddcod      ,
                          a_cts71m00[1].lcltelnum   ,
                          a_cts71m00[1].lclcttnom   ,
                          a_cts71m00[1].c24lclpdrcod,
                          a_cts71m00[1].celteldddcod,
                          a_cts71m00[1].celtelnum,
                          a_cts71m00[1].endcmp,
                          ws.cogidosql, a_cts71m00[1].emeviacod

 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts71m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts71m00[1].brrnom,
                                a_cts71m00[1].lclbrrnom)
      returning a_cts71m00[1].lclbrrnom

  if ws.cogidosql <> 0  then
     error " Erro (", ws.cogidosql using "<<<<<&", "). AVISE A INFORMATICA!"
     prompt "" for char ws.confirma
  end if

  let l_c24endtip = 1
  whenever error continue
  open c_cts71m00_010 using g_documento.atdsrvano,
                            g_documento.atdsrvnum,
                            l_c24endtip
  fetch c_cts71m00_010 into a_cts71m00[1].ofnnumdig
  whenever error stop

  let a_cts71m00[1].lgdtxt = a_cts71m00[1].lgdtip clipped, " ",
                             a_cts71m00[1].lgdnom clipped, " ",
                             a_cts71m00[1].lgdnum using "<<<<#"

#--->>> PSI SPR-2014-28503 - Endereco de correspondencia
#--------------------------------------------------------------------
# Informacoes do local da correspondencia
#--------------------------------------------------------------------
  call ctx04g00_local_gps(cpl_atdsrvnum, cpl_atdsrvano, 7)
                returning a_cts71m00[2].lclidttxt   ,
                          a_cts71m00[2].lgdtip      ,
                          a_cts71m00[2].lgdnom      ,
                          a_cts71m00[2].lgdnum      ,
                          a_cts71m00[2].lclbrrnom   ,
                          a_cts71m00[2].brrnom      ,
                          a_cts71m00[2].cidnom      ,
                          a_cts71m00[2].ufdcod      ,
                          a_cts71m00[2].lclrefptotxt,
                          a_cts71m00[2].endzon      ,
                          a_cts71m00[2].lgdcep      ,
                          a_cts71m00[2].lgdcepcmp   ,
                          a_cts71m00[2].lclltt      ,
                          a_cts71m00[2].lcllgt      ,
                          a_cts71m00[2].dddcod      ,
                          a_cts71m00[2].lcltelnum   ,
                          a_cts71m00[2].lclcttnom   ,
                          a_cts71m00[2].c24lclpdrcod,
                          a_cts71m00[2].celteldddcod,
                          a_cts71m00[2].celtelnum,
                          a_cts71m00[2].endcmp,
                          ws.cogidosql, a_cts71m00[2].emeviacod

  if ws.cogidosql <> 0  then
     error "Endereco Correspondencia N�o Encontrado. Assumindo Endereco de Ocorrencia "
     # Informacoes do local da ocorrencia
     call ctx04g00_local_gps(cpl_atdsrvnum, cpl_atdsrvano, 1)
                   returning a_cts71m00[2].lclidttxt   ,
                             a_cts71m00[2].lgdtip      ,
                             a_cts71m00[2].lgdnom      ,
                             a_cts71m00[2].lgdnum      ,
                             a_cts71m00[2].lclbrrnom   ,
                             a_cts71m00[2].brrnom      ,
                             a_cts71m00[2].cidnom      ,
                             a_cts71m00[2].ufdcod      ,
                             a_cts71m00[2].lclrefptotxt,
                             a_cts71m00[2].endzon      ,
                             a_cts71m00[2].lgdcep      ,
                             a_cts71m00[2].lgdcepcmp   ,
                             a_cts71m00[2].lclltt      ,
                             a_cts71m00[2].lcllgt      ,
                             a_cts71m00[2].dddcod      ,
                             a_cts71m00[2].lcltelnum   ,
                             a_cts71m00[2].lclcttnom   ,
                             a_cts71m00[2].c24lclpdrcod,
                             a_cts71m00[2].celteldddcod,
                             a_cts71m00[2].celtelnum,
                             a_cts71m00[2].endcmp,
                             ws.cogidosql, a_cts71m00[2].emeviacod

     if ws.cogidosql <> 0  then
        error " Erro (", ws.cogidosql using "<<<<<&", ") copia endereco correspondencia. AVISE A INFORMATICA!"
        prompt "" for char ws.confirma
     end if
  end if

  # PSI 244589 - Inclus�o de Sub-Bairro - Burini
  let m_subbairro[2].lclbrrnom = a_cts71m00[2].lclbrrnom

  call cts06g10_monta_brr_subbrr(a_cts71m00[2].brrnom,
                                 a_cts71m00[2].lclbrrnom)
       returning a_cts71m00[2].lclbrrnom

  let a_cts71m00[2].lgdtxt = a_cts71m00[2].lgdtip clipped, " ",
                             a_cts71m00[2].lgdnom clipped, " ",
                             a_cts71m00[2].lgdnum using "<<<<#"
#---<<< PSI SPR-2014-28503 - Endereco de correspondencia

  let d_cts71m00.lclrscflg = "N"

  initialize d_cts71m00.servicorg  to null
  if cpl_atdsrvnum is not null then
     let cpl_atdsrvorg         = 09
     let d_cts71m00.servicorg  = cpl_atdsrvorg using "&&",
                                 "/", cpl_atdsrvnum using "&&&&&&&",
                                 "-", cpl_atdsrvano using "&&"
  end if

  #------------------------------------------
  # Acessa problema servico
  #------------------------------------------

  whenever error continue
  open c_cts71m00_042 using g_documento.atdsrvnum,
                            g_documento.atdsrvano
  fetch c_cts71m00_042 into d_cts71m00.c24pbmcod
  whenever error stop

  #------------------------------------------
  # Acessa descricao natureza
  #------------------------------------------
  let d_cts71m00.socntzdes = "*** NAO CADASTRADA ***"

  whenever error continue
  open c_cts71m00_043 using d_cts71m00.socntzcod
  fetch c_cts71m00_043 into d_cts71m00.socntzdes
  whenever error stop


  #------------------------------------------
  # Acessa descricao especialidade
  #------------------------------------------
  let d_cts71m00.espdes = null
  if d_cts71m00.espcod is not null then

      let d_cts71m00.espdes = "*** NAO CADASTRADA ***"
      #como nao importa a situacao da especialidade (ativa ou nao) vou buscar
      # apenas a descricao, entao vou passar null
      let l_espsit = null

      call cts31g00_descricao_esp(d_cts71m00.espcod, l_espsit)
           returning d_cts71m00.espdes

      if d_cts71m00.espdes is null then
         error "Descricao nao encontrada para especialidade."
      end if

  end if

  #------------------------------------------
  # Acessa descricao tipo servico
  #------------------------------------------
  let d_cts71m00.asitipabvdes = "NAO PREV"

  whenever error continue
  open c_cts71m00_044 using d_cts71m00.asitipcod
  fetch c_cts71m00_044 into d_cts71m00.asitipabvdes
  whenever error stop

   # PSI 244589 - Inclus�o de Sub-Bairro - Burini
   let m_subbairro[1].lclbrrnom = a_cts71m00[1].lclbrrnom

   call cts06g10_monta_brr_subbrr(a_cts71m00[1].brrnom,
                                  a_cts71m00[1].lclbrrnom)
        returning a_cts71m00[1].lclbrrnom

   display by name d_cts71m00.srvnum    #--- PSI SPR-2014-28503
   display by name d_cts71m00.prpnumdsp #--- PSI SPR-2014-28503
   display by name d_cts71m00.c24solnom
   display by name d_cts71m00.nom
#---   display by name d_cts71m00.doctxt #--- SPR-2015-03912-Cadastro Clientes ---
   display by name d_cts71m00.nscdat     #--- SPR-2015-03912-Cadastro Clientes ---
   display by name d_cts71m00.srvpedcod  #--- SPR-2015-03912-Cadastro Pedidos  ---
   display by name d_cts71m00.corsus
   display by name d_cts71m00.cornom
   display by name d_cts71m00.orrdat
   display by name d_cts71m00.servicorg
   display by name d_cts71m00.socntzcod
   display by name d_cts71m00.socntzdes
   display by name d_cts71m00.c24pbmcod
   display by name d_cts71m00.atddfttxt
   display by name d_cts71m00.asitipcod
   display by name d_cts71m00.asitipabvdes
   display by name d_cts71m00.imdsrvflg
   display by name d_cts71m00.atdprinvlcod
   display by name d_cts71m00.atdprinvldes
   display by name d_cts71m00.atdlibflg
   display by name d_cts71m00.prslocflg
   display by name d_cts71m00.atdtxt
   display by name d_cts71m00.srvretmtvcod
   display by name d_cts71m00.srvretmtvdes
   display by name d_cts71m00.espcod
   display by name d_cts71m00.espdes
   display by name d_cts71m00.retprsmsmflg
#----
   display by name a_cts71m00[1].lgdtxt,
                   a_cts71m00[1].lclbrrnom,
                   a_cts71m00[1].endzon,
                   a_cts71m00[1].cidnom,
                   a_cts71m00[1].ufdcod,
                   a_cts71m00[1].lclrefptotxt,
                   a_cts71m00[1].lclcttnom,
                   a_cts71m00[1].dddcod,
                   a_cts71m00[1].lcltelnum,
                   a_cts71m00[1].celteldddcod,
                   a_cts71m00[1].celtelnum,
                   a_cts71m00[1].endcmp

  let flgcpl = 1

end function  ###  cts71m00_copia

#=========================================================
 function cts71m00_grava_dados(lr_param)
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

 define lr_opsfa023    record
       retorno        smallint
       ,mensagem       char(100)
 end record

 #- SPR-2016-03565 - Inicio 	
 define lr_retorno_sku  record   
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record
 #- SPR-2016-03565 - Fim	

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
 initialize lr_opsfa023.* to null
 initialize lr_retorno_sku.* to null  #- SPR-2016-03565
 let l_confirma = null
 let l_conta_corrente = false
 let l_tipo_nro       = null

 call cts40g03_data_hora_banco(2) returning m_data, m_hora

 let w_cts71m00.atddat  = m_data
 let w_cts71m00.atdhor  = m_hora
 let w_cts71m00.atdlibhor = m_hora
 let w_cts71m00.atdlibdat = m_data
 let w_cts71m00.atdfnlhor    = m_hora


 begin work

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------

 if g_documento.lclocodesres = "S" then
    let w_cts71m00.atdrsdflg = "S"
 else
    let w_cts71m00.atdrsdflg = "N"
 end if

 let l_tipo_nro = 2 ---> Nro Servico e Nro Ligacao


 # Busca numeracao ligacao / servico
   call cts10g03_numeracao(l_tipo_nro,"9")
        returning l_lignum, l_atdsrvnum,
                  l_atdsrvano, l_sqlcode,
                  l_msg

   if l_sqlcode = 0  then
      commit work
   else
      let l_msg = "cts71m00 - ",l_msg
      call ctx13g00(l_sqlcode,"DATKGERAL",l_msg)
      rollback work
      prompt "" for l_prompt
      let lr_ret.retorno = l_sqlcode
      let lr_ret.mensagem = l_msg
      return lr_ret.*
   end if

   let w_cts71m00.atdsrvnum  = l_atdsrvnum
   let w_cts71m00.atdsrvano  = l_atdsrvano

   let g_documento.lignum  = l_lignum

   #=> SPR-2014-28503 - GERA NUMERO DA PROPOSTA (FORMA DE PAGAMENTO)
   if m_vendaflg then
      begin work
      call cty27g00_numprp()
           returning mr_prop.*
      if mr_prop.sqlcode <> 0 then
         let l_msg = "cts71m00(numprp) - ",mr_prop.msg clipped
         call ctx13g00(mr_prop.sqlcode,"DATKGERAL(numprp)",mr_prop.msg)
         rollback work
         prompt "" for l_prompt
         let lr_ret.retorno = mr_prop.sqlcode
         let lr_ret.mensagem = mr_prop.msg
         return lr_ret.*
      end if
      commit work

      #=> SPR-2015-11582 - GERA NUMERO DO PEDIDO
      begin work
      call opsfa015_geranumped()
           returning lr_ret.retorno
                    ,lr_ret.mensagem
                    ,d_cts71m00.srvpedcod
      if lr_ret.retorno = false then
         rollback work
         error "ERRO NA GERACAO DO NUMERO DO PEDIDO. ", lr_ret.mensagem clipped
         prompt "" for char ms.prompt_key
         return lr_ret.*
      end if
      commit work
   else
      initialize mr_prop.*,
                 d_cts71m00.srvpedcod to null  #=> SPR-2015-11582
   end if

   #---------------------------------
   # Grava dados da ligacao / servico
   #---------------------------------

   # Verifica se deve mudar a empresa do servi�o aberto no cartao
   let l_ciaempcod_slv = g_documento.ciaempcod

      begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts71m00.atddat       ,
                           w_cts71m00.atdhor       ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts71m00.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           l_atdsrvnum             ,
                           l_atdsrvano             ,
                           "","","",""             ,
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

   call cts10g02_grava_servico( w_cts71m00.atdsrvnum,
                                w_cts71m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                d_cts71m00.c24solnom,     # c24solnom
                                ""                  ,     # vclcorcod
                                w_cts71m00.funmat   ,
                                d_cts71m00.atdlibflg,
                                w_cts71m00.atdlibhor,
                                w_cts71m00.atdlibdat,
                                w_cts71m00.atddat   ,
                                w_cts71m00.atdhor   ,
                                ""                  ,     # atdlclflg
                                w_cts71m00.atdhorpvt,
                                w_cts71m00.atddatprg,
                                w_cts71m00.atdhorprg,
                                "9"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts71m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts71m00.atdfnlflg,
                                w_cts71m00.atdfnlhor,
                                w_cts71m00.atdrsdflg,
                                lr_param.atddfttxt,
                                ""                  ,     # atddoctxt  #--- SPR-2015-03912-Cadastro Clientes ---
                                w_cts71m00.c24opemat,
                                d_cts71m00.nom      ,
                                ""                  ,     # vcldes
                                ""                  ,     # vclanomdl
                                ""                  ,     # vcllicnum
                                d_cts71m00.corsus   ,
                                d_cts71m00.cornom   ,
                                w_cts71m00.cnldat   ,
                                ""                  ,     # pgtdat
                                w_cts71m00.c24nomctt,
                                w_cts71m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                d_cts71m00.asitipcod,
                                ""                  ,     # socvclcod
                                ""                  ,     # vclcoddig
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts71m00.atdprinvlcod,
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

   #=> SPR-2015-11582 - CENTRALIZAR GERACAO DA ESTRUTURA DE VENDA
   call opsfa006_geracao(w_cts71m00.atdsrvnum,
                         w_cts71m00.atdsrvano,
                         mr_prop.prpnum,
                         d_cts71m00.srvpedcod,
                         d_cts71m00.nom,
                         d_cts71m00.nscdat,
                         "",                   #=> E-MAIL
                         false,                #=> ATUALIZA DT.FECH.
                         m_vendaflg,           #=> CRIA VENDA
                         "1")                  #=> Online - SPR-2015-22413
        returning lr_ret.retorno,
                  lr_ret.mensagem
   if not lr_ret.retorno then
      rollback work
      error lr_ret.mensagem clipped
      prompt "ERRO NA GERACAO DA ESTRUTURA DE VENDA." for char ms.prompt_key
      return lr_ret.*
   end if

#- if d_cts71m00.prslocflg = "S" then  #- SPR-2015-15533-Fechamento Srv GPS
      whenever error continue
      execute p_cts71m00_045 using d_cts71m00.prslocflg
                               , w_cts71m00.socvclcod
                               , w_cts71m00.srrcoddig
                               , w_cts71m00.atdsrvnum
                               , w_cts71m00.atdsrvano
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
#-  end if

 #---------------------------
 # Grava problemas do servico
 #---------------------------
    call ctx09g02_inclui(w_cts71m00.atdsrvnum,
                         w_cts71m00.atdsrvano,
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
   if a_cts71m00[1].operacao is null then
      let a_cts71m00[1].operacao = "I"
   end if

   let a_cts71m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

   let ms.codigosql = cts06g07_local( a_cts71m00[1].operacao    ,
                                    w_cts71m00.atdsrvnum      ,
                                    w_cts71m00.atdsrvano      ,
                                    1                         ,
                                    a_cts71m00[1].lclidttxt   ,
                                    a_cts71m00[1].lgdtip      ,
                                    a_cts71m00[1].lgdnom      ,
                                    a_cts71m00[1].lgdnum      ,
                                    a_cts71m00[1].lclbrrnom   ,
                                    a_cts71m00[1].brrnom      ,
                                    a_cts71m00[1].cidnom      ,
                                    a_cts71m00[1].ufdcod      ,
                                    a_cts71m00[1].lclrefptotxt,
                                    a_cts71m00[1].endzon      ,
                                    a_cts71m00[1].lgdcep      ,
                                    a_cts71m00[1].lgdcepcmp   ,
                                    a_cts71m00[1].lclltt      ,
                                    a_cts71m00[1].lcllgt      ,
                                    a_cts71m00[1].dddcod      ,
                                    a_cts71m00[1].lcltelnum   ,
                                    a_cts71m00[1].lclcttnom   ,
                                    a_cts71m00[1].c24lclpdrcod,
                                    a_cts71m00[1].ofnnumdig,
                                    a_cts71m00[1].emeviacod   ,
                                    a_cts71m00[1].celteldddcod,
                                    a_cts71m00[1].celtelnum   ,
                                    a_cts71m00[1].endcmp )

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

 #---------------------------  #--->>> Endereco de corresp - PSI SPR-2014-28503
 # Grava locais de correspondencia
 #---------------------------

   if a_cts71m00[2].operacao is null then
      let a_cts71m00[2].operacao = "I"
   end if

   let a_cts71m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

   let ms.codigosql = cts06g07_local( a_cts71m00[2].operacao    ,
                                    w_cts71m00.atdsrvnum      ,
                                    w_cts71m00.atdsrvano      ,
                                    7,    #--- Tp Endereco correspondencia
                                    a_cts71m00[2].lclidttxt   ,
                                    a_cts71m00[2].lgdtip      ,
                                    a_cts71m00[2].lgdnom      ,
                                    a_cts71m00[2].lgdnum      ,
                                    a_cts71m00[2].lclbrrnom   ,
                                    a_cts71m00[2].brrnom      ,
                                    a_cts71m00[2].cidnom      ,
                                    a_cts71m00[2].ufdcod      ,
                                    a_cts71m00[2].lclrefptotxt,
                                    a_cts71m00[2].endzon      ,
                                    a_cts71m00[2].lgdcep      ,
                                    a_cts71m00[2].lgdcepcmp   ,
                                    a_cts71m00[2].lclltt      ,
                                    a_cts71m00[2].lcllgt      ,
                                    a_cts71m00[2].dddcod      ,
                                    a_cts71m00[2].lcltelnum   ,
                                    a_cts71m00[2].lclcttnom   ,
                                    a_cts71m00[2].c24lclpdrcod,
                                    a_cts71m00[2].ofnnumdig,
                                    a_cts71m00[2].emeviacod   ,
                                    a_cts71m00[2].celteldddcod,
                                    a_cts71m00[2].celtelnum   ,
                                    a_cts71m00[2].endcmp )

   if ms.codigosql is null or
      ms.codigosql <> 0 then
      let lr_ret.mensagem = " Erro (",ms.codigosql,") na gravacao do",
                            " local de correspondencia. AVISE A INFORMATICA!"
      let lr_ret.retorno = ms.codigosql
      error lr_ret.mensagem sleep 1
      rollback work
      prompt "" for ms.prompt_key
      return lr_ret.*
   end if

 #-------------------------------
 # Grava etapas do acompanhamento
 #-------------------------------
   open  c_cts71m00_046 using l_atdsrvnum, l_atdsrvano
   whenever error continue
   fetch c_cts71m00_046 into ms.atdsrvseq
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

   if w_cts71m00.atdetpcod is null then
      if d_cts71m00.atdlibflg = "S" then
         let w_cts71m00.atdetpcod = 1
         let ms.etpfunmat = w_cts71m00.funmat
         let ms.atdetpdat = w_cts71m00.atdlibdat
         let ms.atdetphor = w_cts71m00.atdlibhor
      else
         let w_cts71m00.atdetpcod = 2
         let ms.etpfunmat = w_cts71m00.funmat
         let ms.atdetpdat = w_cts71m00.atddat
         let ms.atdetphor = w_cts71m00.atdhor
      end if
   else

      call cts10g04_insere_etapa(w_cts71m00.atdsrvnum,
                                 w_cts71m00.atdsrvano,
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
      let ms.atdetpdat = w_cts71m00.cnldat
      let ms.atdetphor = w_cts71m00.atdfnlhor
      let ms.etpfunmat = w_cts71m00.c24opemat
  end if

  call cts10g04_insere_etapa(l_atdsrvnum,
                             l_atdsrvano,
                             w_cts71m00.atdetpcod,
                             w_cts71m00.atdprscod,
                             w_cts71m00.c24nomctt,
                             w_cts71m00.socvclcod,
                             w_cts71m00.srrcoddig)
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

  if d_cts71m00.prslocflg = "N" then
     let w_cts71m00.atdetpcod = null
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
  execute p_cts71m00_047 using l_atdsrvnum             , l_atdsrvano,
                             d_cts71m00.lclrsccod    , d_cts71m00.orrdat,
                             lr_param.socntzcod      , cpl_atdsrvnum,
                             cpl_atdsrvano           , d_cts71m00.srvretmtvcod,
                             d_cts71m00.retprsmsmflg , lr_param.espcod,
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

  if d_cts71m00.srvretmtvcod is not null and
     d_cts71m00.srvretmtvcod  =  999 then
     whenever error continue

     execute p_cts71m00_048 using l_atdsrvnum, l_atdsrvano,
                                d_cts71m00.srvretmtvdes, m_data,
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


  #-------------------------------
  # Aciona Servico automaticamente
  #-------------------------------

  if (ws_acao = "RET" and d_cts71m00.retprsmsmflg = 'N') or
     m_veiculo_aciona is not null then
     # e retorno? and deseja outro prestador? OU tem veiculo pronto
     # para servico imediato
     # servico nao sera acionado automaticamente
  else
     #chamar funcao que verifica se acionamento pode ser feito
     # verifica se servico para cidade e internet ou GPS e se esta ativo
     #retorna true para acionamento e false para nao acionamento

     if cts34g00_acion_auto (g_documento.atdsrvorg,
                             a_cts71m00[1].cidnom,
                             a_cts71m00[1].ufdcod) then

        #funcao cts34g00_acion_auto verificou que parametrizacao para origem
        # do servico esta OK
        #chamar funcao para validar regras gerais se um servico sera acionado
        # automaticamente ou nao e atualizar datmservico


        if not cts40g12_regras_aciona_auto (
                             g_documento.atdsrvorg,
                             g_documento.c24astcod,
                             "",
                             a_cts71m00[1].lclltt,
                             a_cts71m00[1].lcllgt,
                             d_cts71m00.prslocflg,
                             "N",#d_cts71m00.frmflg,
                             w_cts71m00.atdsrvnum,
                             w_cts71m00.atdsrvano,
                             ws_acao,
                             "",
                             "") then

           #servico nao pode ser acionado automaticamente
        end if
     end if
  end if

  # Verifica se deve retornar a empresa do servi�o aberto no cartao
  if g_documento.ciaempcod <> l_ciaempcod_slv then
     let g_documento.ciaempcod = l_ciaempcod_slv
  end if

  #---------------------------
  # Grava HISTORICO do servico
  #---------------------------

  let ms.histerr = cts10g02_historico( l_atdsrvnum,
                                       l_atdsrvano,
                                       w_cts71m00.atddat,
                                       w_cts71m00.atdhor,
                                       w_cts71m00.funmat,
                                       mr_hist.*   )

  #Gravar relacionamento do servico principal com os servicos multiplos
  if lr_param.atdsrvnum is not null then
     whenever error continue

     execute p_cts71m00_051 using lr_param.atdsrvnum, lr_param.atdsrvano
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

  #------------------------------------------------------------------------------
  # Grava sugestao de cadastro
  #------------------------------------------------------------------------------

  if mr_grava_sugest  = 'S' then
     # display "dados a serem gravados : "
     # display 'l_atdsrvnum = ' , l_atdsrvnum
     # display 'l_atdsrvano = ' , l_atdsrvano
     # display 'd_cts71m00.asitipcod = ' , d_cts71m00.asitipcod
     # display 'g_issk.usrtip = ' , g_issk.usrtip
     # display 'g_issk.empcod = ' , g_issk.empcod
     # display 'g_issk.funmat = ' , g_issk.funmat
     call ctc68m00_grava_sugest(l_atdsrvnum, l_atdsrvano,
                                d_cts71m00.asitipcod,
                                g_issk.usrtip,
                                g_issk.empcod,
                                g_issk.funmat)
     let mr_grava_sugest = 'N'
  end if

  #FIM PSI-2013-07115


  commit work  #=> SPR-2014-28503 - CORRECAO: ATUALIZACOES FORA DA TRANSACAO...


  # Ponto de acesso apos a gravacao do laudo
  call cts00g07_apos_grvlaudo(w_cts71m00.atdsrvnum,
                              w_cts71m00.atdsrvano)

  let lr_ret.retorno = 1
  let lr_ret.mensagem = ' '
  let lr_ret.atdsrvnum = l_atdsrvnum
  let lr_ret.atdsrvano = l_atdsrvano
  let lr_ret.lignum = l_lignum

 #---> Data de Fechamento - PSI SPR-2015-03912 ---
 call opsfa006_atualdtfecha(w_cts71m00.atdsrvnum
                           ,w_cts71m00.atdsrvano)
      returning lr_ret.retorno
               ,lr_ret.mensagem

 if lr_ret.retorno = false then
    error "ERRO AO ATUALIZAR DATA ATENDIMENTO NA VENDA. ",lr_ret.mensagem clipped
    prompt "" for ms.prompt_key
    return lr_ret.*
 end if
 #---> Data de Fechamento - PSI SPR-2015-03912 ---

 let m_mailpfaz = false

 whenever error continue
 open c_cts71m00_074
 fetch c_cts71m00_074 into m_mailpfaz

 if sqlca.sqlcode != 0
    then
    let m_mailpfaz = false
 end if
 whenever error stop
 # PSI-2013-00440PR



 #---> Envio de Email  ---
  if m_mailpfaz = true then
     if g_documento.acao = "INC" then
        call opsfa023_emailposvenda(w_cts71m00.atdsrvnum
                                   ,w_cts71m00.atdsrvano)
             returning lr_opsfa023.retorno
                      ,lr_opsfa023.mensagem

        if lr_opsfa023.retorno = false  then
           error lr_opsfa023.mensagem clipped
        end if
     end if
  end if
 #---> Envio de Email  ---
 

 #- SPR-2016-01943
 #-- Consulta SKU por Problema
 call opsfa001_conskupbr(lr_param.c24pbmcod
                        ,today)
      returning lr_retorno_sku.catcod
               ,lr_retorno_sku.pgtfrmcod
               ,lr_retorno_sku.srvprsflg
               ,lr_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
               ,lr_retorno_sku.msg_erro


 if lr_retorno_sku.srvprsflg = "S" then
    call opsfa023_posvnd_prest(w_cts71m00.atdsrvnum
                               ,w_cts71m00.atdsrvano)
          returning lr_opsfa023.retorno,
                    lr_opsfa023.mensagem

    if lr_opsfa023.retorno = false then
       error lr_opsfa023.mensagem clipped
    end if	
 end if
 #- SPR-2016-01943


 return lr_ret.*

end function

#--- PSI SPR-2015-10068 - Consistir nome composto
#--------------------------------------------------------------------
function cts71m00_consiste_nome()
#--------------------------------------------------------------------
 define l_tam     smallint
 define l_ind     smallint
 define l_nome_ok char(1)
 define l_branco  char(1)

 let l_tam = null
 let l_ind = null
 let l_nome_ok = null
 let l_branco = null

 let l_branco = "N"
 let l_nome_ok = "N"
 let l_tam = length(d_cts71m00.nom)

 for l_ind = 1 to l_tam
    if d_cts71m00.nom[l_ind,l_ind] = " " or
       d_cts71m00.nom[l_ind,l_ind] is null then
       if l_ind > 2 then
          let l_branco = "S"
       end if
    else
    	 if l_branco = "S" then
    	    let l_nome_ok = "S"
    	 end if
    end if
 end for

 return l_nome_ok

end function #--- cts71m00_consiste_nome()

#-----------------------------------
function cts71m00_alt_prog(lr_input)
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
            execute p_cts71m00_052 using lr_input.atddatprg
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
            execute p_cts71m00_052 using lr_input.atddatprg
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
      execute p_cts71m00_052 using lr_input.atddatprg
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
function cts71m00_alt_end(lr_input)
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
                            a_cts71m00[1].lclidttxt,
                            a_cts71m00[1].lgdtip,
                            a_cts71m00[1].lgdnom,
                            a_cts71m00[1].lgdnum,
                            a_cts71m00[1].lclbrrnom,
                            a_cts71m00[1].brrnom,
                            a_cts71m00[1].cidnom,
                            a_cts71m00[1].ufdcod,
                            a_cts71m00[1].lclrefptotxt,
                            a_cts71m00[1].endzon,
                            a_cts71m00[1].lgdcep,
                            a_cts71m00[1].lgdcepcmp,
                            a_cts71m00[1].lclltt,
                            a_cts71m00[1].lcllgt,
                            a_cts71m00[1].dddcod,
                            a_cts71m00[1].lcltelnum,
                            a_cts71m00[1].lclcttnom,
                            a_cts71m00[1].c24lclpdrcod,
                            a_cts71m00[1].ofnnumdig,
                            a_cts71m00[1].emeviacod,
                            a_cts71m00[1].celteldddcod,
                            a_cts71m00[1].celtelnum,
                            a_cts71m00[1].endcmp)
                  returning l_sqlcode
   end if

      for l_contador = 1 to 10
          if am_cts29g00[l_contador].atdmltsrvnum is not null then
             call cts06g07_local("M",
                            am_cts29g00[l_contador].atdmltsrvnum,
                            am_cts29g00[l_contador].atdmltsrvano,
                            1,
                            a_cts71m00[1].lclidttxt,
                            a_cts71m00[1].lgdtip,
                            a_cts71m00[1].lgdnom,
                            a_cts71m00[1].lgdnum,
                            a_cts71m00[1].lclbrrnom,
                            a_cts71m00[1].brrnom,
                            a_cts71m00[1].cidnom,
                            a_cts71m00[1].ufdcod,
                            a_cts71m00[1].lclrefptotxt,
                            a_cts71m00[1].endzon,
                            a_cts71m00[1].lgdcep,
                            a_cts71m00[1].lgdcepcmp,
                            a_cts71m00[1].lclltt,
                            a_cts71m00[1].lcllgt,
                            a_cts71m00[1].dddcod,
                            a_cts71m00[1].lcltelnum,
                            a_cts71m00[1].lclcttnom,
                            a_cts71m00[1].c24lclpdrcod,
                            a_cts71m00[1].ofnnumdig,
                            a_cts71m00[1].emeviacod,
                            a_cts71m00[1].celteldddcod,
                            a_cts71m00[1].celtelnum,
                            a_cts71m00[1].endcmp)
                  returning l_sqlcode

          end if
      end for

      return    lr_output.resultado
               ,lr_output.mensagem

end function

#--------------------------------------------------------------------
function cts71m00_imdsrvflg(lr_param)
#--------------------------------------------------------------------

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
          l_contador      smallint,
          l_ctx34g02_validaservicoimediato  char(11)

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

   if ctx34g00_NovoAcionamento() then  # AcionamentoWeb Ativo

      #obter codigo da cidade
      call cty10g00_obter_cidcod(lr_param.cidnom, lr_param.ufdcod)
           returning l_resultado, l_mensagem, lr_ret.mpacidcod

      #Evita que o programa consulte a agenda antiga!
      if m_agendaw = false then
         # Verifica a possibilidade de acionamento imediato do servico no AcionamentoWeb
         error "Aguarde, pesquisando veiculo ..."
         call ctx34g02_validaservicoimediato(lr_param.cidnom,
                                             lr_param.ufdcod,
                                             lr_ret.mpacidcod,
                                             lr_param.lclltt,
                                             lr_param.lcllgt,
                                             lr_param.c24lclpdrcod,
                                             g_documento.ciaempcod,
                                             lr_param.atdsrvorg,
                                             lr_param.socntzcod,
                                             lr_param.espcod,
                                             0,                   # NAO UTILIZADO Codigo Assistencia
                                             0,                   # NAO UTILIZADO Codigo do Veiculo
                                             0)                   # NAO UTILIZADO Valor de IS do Veiculo
              returning l_ctx34g02_validaservicoimediato
         error ""
         case l_ctx34g02_validaservicoimediato
              when 'SIM'
                 call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
                                              lr_param.socntzcod, lr_param.data,
                                              lr_param.hora)
                      returning l_pergunta,
                                lr_ret.cota_disponivel
                 let l_pergunta = "S"
                 let l_gpsacngrpcod = 1   # Cidade acionada por GPS

              when 'SEMREGRAGPS'
                 #verifica cota
                 call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
                                              lr_param.socntzcod, lr_param.data,
                                              lr_param.hora)
                      returning l_pergunta,
                                lr_ret.cota_disponivel

              when 'NAO'
                 let l_pergunta = "N"
                 let lr_ret.cota_disponivel = "N"
                 let l_gpsacngrpcod = 1   # Cidade acionada por GPS

                 call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
                                              lr_param.socntzcod, lr_param.data,
                                              lr_param.hora)
                      returning l_pergunta,
                                lr_ret.cota_disponivel
          end case
      end if

   else # AcionamentoWeb desligado

   initialize  m_parametros.* to null
   call cts40g00_obter_parametro(lr_param.atdsrvorg)
        returning m_parametros.*

   #verificar se cidade � atendida por GPS
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
                                   "",
                                   "",
                                   "",
                                   "",
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
                                   d_cts71m00.socntzcod,
                                   a_cts71m00[1].lclltt,
                                   a_cts71m00[1].lgdnom,
                                   a_cts71m00[1].lgdnum,
                                   a_cts71m00[1].brrnom,
                                   a_cts71m00[1].cidnom,
                                   a_cts71m00[1].ufdcod,
                                   a_cts71m00[1].lgdcep
                                   )

           returning l_pergunta, lr_ret.veiculo_aciona,
                     lr_ret.cota_disponivel
   else
      call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
                                   lr_param.socntzcod, lr_param.data,
                                   lr_param.hora)
           returning l_pergunta, lr_ret.cota_disponivel
   end if
   end if

   # PSI-2013-00440PR nao utilizado no agendamento AW
   if m_agendaw = false
      then
   if ((l_gpsacngrpcod > 0 and lr_ret.veiculo_aciona is null and
       lr_ret.cota_disponivel = true) or l_pergunta = "S")       and
       (ml_srvabrprsinfflg = "N" or ml_srvabrprsinfflg is null)  then

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

   ## Abre agenda, nesta situacao, somente para na abertura do servi�o(inclusao)

   if l_conf_imd = "N" then
      if mr_salva.atddatprg  is not null then
         let lr_ret.atddatprg = mr_salva.atddatprg
         let lr_ret.atdhorprg = mr_salva.atdhorprg
      end if
   end if


   return lr_ret.*

end function

#--------------------------------------------------------------------
########### TRATAMENTO PARA RESERVA DE COTAS ##############################
function cts71m00_cotas(lr_param)
#--------------------------------------------------------------------

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
   call cts71m00_verifica_endereco() returning l_reservar_cota

   if l_reservar_cota = "N" then

      ## Verifica se alterou data/hora prog ou imediato
      call cts71m00_verifica_data_hora()
           returning l_abater_cota, l_reservar_cota

      if l_abater_cota = "S" then
         call cts71m00_abater_cota()
      end if

   end if

   if l_reservar_cota = "S" then

      ## Verifica se existe outros servi�os para decidir a reserva da cota
      call cts51g00_ver_existencia_outros_srv(lr_param.atdsrvnum,
                                              lr_param.atdsrvano,
                                              "",
                                              "",
                                              "",
                                              "",
                                              l_data_cota,
                                              l_hora_cota,
                                              d_cts71m00.socntzcod,
                                              a_cts71m00[1].lclltt,
                                              a_cts71m00[1].lgdnom,
                                              a_cts71m00[1].lgdnum,
                                              a_cts71m00[1].brrnom,
                                              a_cts71m00[1].cidnom,
                                              a_cts71m00[1].ufdcod,
                                              a_cts71m00[1].lgdcep,
                                              ws_acaorigem
                                              )
           returning l_reservar_cota
   end if

   ## Reservando a cota
   if l_reservar_cota = "S" then
      call cts71m00_reservar_cota(lr_param.veiculo_aciona,
                                  lr_param.cota_disponivel,
                                  lr_param.atdsrvorg,
                                  lr_param.socntzcod,
                                  l_data_cota,
                                  l_hora_cota)
   end if

end function

#--------------------------------------------------------------------
function cts71m00_reservar_cota(lr_param)
#--------------------------------------------------------------------

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
      let l_rglflg = ctc59m02(a_cts71m00[1].cidnom
                             ,a_cts71m00[1].ufdcod
                             ,lr_param.atdsrvorg
                             ,lr_param.socntzcod
                             ,lr_param.data_cota
                             ,lr_param.hora_cota
                             ,true)
   else
      # atualiza cota utilizada para cidade/origem/natureza/data
      ## e hora informada
      let l_rglflg = ctc59m02(a_cts71m00[1].cidnom
                             ,a_cts71m00[1].ufdcod
                             ,lr_param.atdsrvorg
                             ,lr_param.socntzcod
                             ,lr_param.data_cota
                             ,lr_param.hora_cota
                             ,false)
   end if

end function

#--------------------------------------------------------------------
function cts71m00_verifica_endereco()
#--------------------------------------------------------------------

   define l_reservar   char(1)

   let l_reservar = "S"
   let m_alt_end = "N"

   ########## SE FOR UMA ALTERACAO NO SERVICO #########

   if g_documento.acao = "ALT" or
      g_documento.acao = "RAD" then

      if (((mr_salva.c24lclpdrcod <> 3 and a_cts71m00[1].c24lclpdrcod = 3)  or
           (mr_salva.c24lclpdrcod <> 4 and a_cts71m00[1].c24lclpdrcod = 4)  or # PSI 252891
           (mr_salva.c24lclpdrcod <> 5 and a_cts71m00[1].c24lclpdrcod = 5)) or
         (mr_salva.lclltt = a_cts71m00[1].lclltt)) then

         let l_reservar = "N"
         let m_alt_end = "N"
      else

         if mr_salva.lclltt <> a_cts71m00[1].lclltt or
            mr_salva.brrnom <> a_cts71m00[1].brrnom or
            mr_salva.lgdnom <> a_cts71m00[1].lgdnom or
            mr_salva.lgdnum <> a_cts71m00[1].lgdnum then
            ## alterou endereco
            let m_alt_end = "S"
         end if
      end if

   end if

   return l_reservar

end function

#--------------------------------------------------------------------
function cts71m00_abater_cota()
#--------------------------------------------------------------------

   define l_rglflg smallint

   let l_rglflg = null

   #se � consulta ou alteracao de servico
   if w_cts71m00.atdfnlflg = 'S' then
      call cts11g00(w_cts71m00.lignum)
      let int_flag = true
   end if

   #abater cota - buscando data/hora/natureza pelo servico
   let l_rglflg = ctc59m03_regulador(g_documento.atdsrvnum
                                     ,g_documento.atdsrvano)
end function

#--------------------------------------------------------------------
function cts71m00_verifica_data_hora()
#--------------------------------------------------------------------

   define l_abater_cota    char(1),
          l_reservar_cota  char(1)

   let l_abater_cota = "N"
   let l_reservar_cota = "N"

   #se alterou imediato OU se alterou data/hora programada
   if mr_salva.imdsrvflg <> d_cts71m00.imdsrvflg  or
      mr_salva.atddatprg <> w_cts71m00.atddatprg  or
      mr_salva.atdhorprg <> w_cts71m00.atdhorprg  or
      (mr_salva.atddatprg is null and w_cts71m00.atddatprg is not null) then

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

#--------------------------------------------------------------------
function cts71m00_ac(l_atdsrvnum, l_atdsrvano)
#--------------------------------------------------------------------

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
   open c_cts71m00_053 using l_atdsrvnum, l_atdsrvano
   fetch c_cts71m00_053 into l_lclltt1, l_lcllgt1, l_c24lclpdrcod
   whenever error stop
   close c_cts71m00_053

   ##obter viatura acionado
   whenever error continue
   open c_cts71m00_054 using l_atdsrvnum, l_atdsrvano
   fetch c_cts71m00_054 into  l_pstcoddig, l_socvclcod, l_srrcoddig
   whenever error stop
   close c_cts71m00_054

   ##obter coordenada da viatura no servico
   whenever error continue
   open c_cts71m00_055 using l_atdsrvnum, l_atdsrvano
   fetch c_cts71m00_055 into  l_lclltt2, l_lcllgt2
   whenever error stop
   close c_cts71m00_055

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

      let l_mens.de  = "cts71m00"
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
 function cts71m00_verifica_retorno(p_cts71m00)
#--------------------------------------------------------------
 define p_cts71m00   record
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

 let l_data_char = p_cts71m00.atddatprg
 let l_data_char = l_data_char[7,10],'-', l_data_char[4,5], '-', l_data_char[1,2]
                 , ' ', p_cts71m00.atdhorprg, ':00'
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

 if p_cts71m00.atdorgsrvnum is not null and
    p_cts71m00.atdorgsrvano is not null then

    # Busca o prestador do servico original
    whenever error continue
    open c_cts71m00_056 using p_cts71m00.atdorgsrvnum,
                              p_cts71m00.atdorgsrvano
    fetch c_cts71m00_056 into ws.atdprscod, ws.socvclcod, ws.srrcoddig
    whenever error stop

    # Foreach de atendimentos dentro do intervalo

    whenever error continue
    open c_cts71m00_057 using lr_agd_p.min_atddatprg,
                              lr_agd_p.min_atdhorprg,
                              lr_agd_p.max_atddatprg,
                              lr_agd_p.max_atdhorprg

    foreach c_cts71m00_057 into lr_ret.atdsrvnum
                               ,lr_ret.atdsrvano
                               ,lr_ret.socvclcod
                               ,lr_ret.srrcoddig
                               ,lr_ret.atddatprg
                               ,lr_ret.atdhorprg

        if p_cts71m00.atdsrvnum = lr_ret.atdsrvnum and
           p_cts71m00.atdsrvano = lr_ret.atdsrvano then
            continue foreach
        end if

        #CT3282/IN - Inicio
        if ws.socvclcod is not null then
           whenever error continue
           open c_cts71m00_058 using lr_ret.atdsrvnum,
                                     lr_ret.atdsrvano,
                                     ws.socvclcod
           fetch c_cts71m00_058 into l_status
           whenever error stop
           close c_cts71m00_058
        else
           whenever error continue
           open c_cts71m00_066 using lr_ret.atdsrvnum,
                                     lr_ret.atdsrvano
           fetch c_cts71m00_066 into l_status
           display 'fetch c_cts71m00_066 into l_status:', l_status
           whenever error stop
           close c_cts71m00_066
        end if

        if lr_ret.socvclcod is null then
           continue foreach
        end if
        #CT3282/IN - Fim

        if sqlca.sqlcode = 100 then
            whenever error continue
            open c_cts71m00_059 using lr_ret.atdsrvnum,
                                      lr_ret.atdsrvano
            fetch c_cts71m00_059 into lr_org.atdsrvnum, lr_org.atdsrvano
            whenever error stop
            close c_cts71m00_059

            if sqlca.sqlcode = 0 then
               whenever error continue
               open c_cts71m00_060 using lr_org.atdsrvnum,
                                         lr_org.atdsrvano,
                                         ws.socvclcod
               fetch c_cts71m00_060 into l_status
               whenever error stop
               close c_cts71m00_060

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

        #CT3282/IN - Inicio
        if lr_ret.socvclcod is not null then
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
        end if
        #CT3282/IN - Fim

    end foreach
    whenever error stop
    close c_cts71m00_057

    if p_cts71m00.tipo = 1 and
       l_contador > 0 then

       let l_atual_data = today
       let l_atual_hora = current

       while true
           let l_status = 0
           call cts71m00_verifica_retorno(p_cts71m00.atdsrvnum
                                         ,p_cts71m00.atdsrvano
                                         ,p_cts71m00.atdorgsrvnum
                                         ,p_cts71m00.atdorgsrvano
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
          call cts71m00_verifica_retorno(p_cts71m00.atdsrvnum
                                        ,p_cts71m00.atdsrvano
                                        ,p_cts71m00.atdorgsrvnum
                                        ,p_cts71m00.atdorgsrvano
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

end function  #  cts71m00_verifica_retorno

#--------------------------------------------------------------------
function cts71m00_assunto_cortesia()
#--------------------------------------------------------------------

define l_count integer

define lr_retorno record
       flag   smallint
end record


let lr_retorno.flag = false
let l_count = 0


if m_prepara_sql is null or
   m_prepara_sql = false then
   call cts71m00_prepara()
end if

whenever error continue
open c_cts71m00_065 using g_documento.c24astcod
fetch c_cts71m00_065 into l_count
whenever error stop

if l_count > 0 then
   let lr_retorno.flag = true
end if

return lr_retorno.flag

end function
