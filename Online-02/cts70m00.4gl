#---------------------------------------------------------------------------  #
#Porto Seguro Cia Seguros Gerais                                              #
#...........................................................................  #
#Sistema       : Central 24hs                                                 #
#Modulo        : cts70m00                                                     #
#Analista Resp : Roberto Reboucas                                             #
#                Tela de Guincho para o PSS                                   #
#.............................................................................#
#Desenvolvimento: Roberto Reboucas                                            #
#Liberacao      : 01/11/2011                                                  #
#-----------------------------------------------------------------------------#
#                                                                             #
#                         * * * Alteracoes * * *                              #
#                                                                             #
#Data       Autor Fabrica  Origem     Alteracao                               #
#---------- -------------- ---------- ----------------------------------------#
#29/03/2012 Ivan, BRQ  PSI-2011-22603 Projeto alteracao cadastro de destino   #
#24/09/2013 Marcia, Intera  2013-2115 Chamada a cadastro de clientes SAPS     #
#10/12/2013 Rodolfo    PSI-2013-      Inlcusao da nova regulacao via AW       #
#           Massini    12097PR                                                #
#-----------------------------------------------------------------------------#
# 11/08/2014 Fabio, Fornax PSI2013-00440 Adequacoes para regulacao AW         #
#-----------------------------------------------------------------------------#
#05/dez/2014 - Marcos Souza (Biztalking) PSI SPR-2014-28503 - Retirada da     #
#                           abertura dos pop-ups questionando envio serviço   #
#                           de apoio.                                         #
#                           Inclusao de rotina para captura do endereco de    #
#                           correspondencia.                                  #
#-----------------------------------------------------------------------------#
#12/jan/2015 - Marcos Souza (Biztalking) PSI SPR-2014-28503 - Chamar módulo   #
#                           de venda de servicos nas rotinas de inclusao      #
#                          (opsfa006_inclui), alteracao (opsfa006_altera) e   #
#                           de gravacao opsfa006_insert.                      #
#-----------------------------------------------------------------------------#
#22/01/2015 - Marcos Souza (Biztalking) PSI SPR-2014-28503 - Alteração na     #
#                          de Forma de Pagamento                              #
#-----------------------------------------------------------------------------#
#09/mar/2015 - Marcos Souza (BizTalking)- PSI SPR-2015-03912 - Atualizacao    #
#                           dt agendamento servico na venda, inclusao         #
#                           dt nascimento no input e tratamento pedido        #
#-----------------------------------------------------------------------------#
#20/mai/2015 - Marcos Souza (BizTalking)- SPR-2015-10068 - Não permitir  a    #
#                           entrada de nome que não seja composto.            #
#-----------------------------------------------------------------------------#
#09/jun/2015 - Marcos Souza (BizTalking)- SPR-2015-11582                      #
#                         - Ajuste na rotina de inclusao do laudo, da         #
#                           chamada da Funcao Unica para Geracao da Venda     #
#                          (opsfa006_geracao() em substituindo as chamadas:   #
#                             - opsfa014_inscadcli() - clientes               #
#                             - opsfa006_insert() - venda                     #
#                             - opsfa005_insere_etapa() - etapa               #
#                             - opsfa015_inscadped() - pedido                 #
#                         - Retirada da tela os campos:                       #
#                             - Formulário(S/N) (frmflg)                      #
#                             - Data e hora Sinistro (sindat / sinhor)        #
#                             - Em Residencia(S/N) (atdrsdflg)                #
#                             - Ha vitimas(S/N) (sinvitflg)                   #
#                             - Dados do BO (bocflg / bocnum / bocemi)        #
#                             - Desapoio                                      #
#                             - Refasstxt                                     #
#-----------------------------------------------------------------------------#
#02/jul/2015 - Marcos Souza (BizTalking)-SPR-2015-13708-Melhorias Calculo SKU #
#                         - Capturar a unidade de cobranca do SKU             #
#                         - Alteracao nas chamadas da Venda passando a data do#
#                           servico, o SKU e sua unidade de cobranca.         #
#-----------------------------------------------------------------------------#
#29/jul/2015 - Marcos Souza (BizTalking)-SPR-2015-15533-Fechamento Servs GPS  #
#                         Deslocar campo 'Prestador Local' para posicionamento#
#                         após o campo 'Motivo Solicitacao'.                  #
#-----------------------------------------------------------------------------#
#10/nov/2015 - Marcos Souza (BizTalking)-SPR-2015-22413-Acao Prom Black Friday#
#                         Incluir parametro "1" ("On-Line") nas chamadas das  #
#                         funcoes opsfa006_geracao() e a opsfa015_inscadped() #
#                         para indentificar o canal de venda.                 #
#-----------------------------------------------------------------------------#
#04/04/2016 - Marcos Souza (InforSystem)-SPR-2016-03565 - Vendas e Parcerias. #
#                          Rede Apartada: pagamento direto ao Prestador       #
#                         (Identificacao no SKU)                              #
###############################################################################


globals "/homedsa/projetos/geral/globals/figrc072.4gl"  --> 223689
globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"  # PSI-2013-07115

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

 define d_cts70m00    record
    servico           char (13)                    ,
    prpnumdsp         char (11)                    ,  #--- SPR-2014-28503-Forma Pagto
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
#-- doctxt            char (32)                    ,  #--- SPR-2015-03912-Cadastro Clientes
    nscdat            like datksrvcli.nscdat ,        #--- SPR-2015-03912-Cadastro Clientes
    srvpedcod         like datmsrvped.srvpedcod    ,  #--- SPR-2015-03912-Cadastro Pedidos
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
    camflg            char (01)                    ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
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
    atdtxt            char (48)                    ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
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
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        edsnumref    like datrligapol.edsnumref,
        fcapacorg    like datrligpac.fcapacorg,
        fcapacnum    like datrligpac.fcapacnum,
        psscntcod    like kspmcntrsm.psscntcod ,
        acao         char(03),
        c24astcod    like datkassunto.c24astcod,
        solnom       char(15),
        atdsrvorg    like datmservico.atdsrvorg,
        lignum       like datmligacao.lignum,
        soltip       char(01),
        c24soltipcod like datmligacao.c24soltipcod,
        lclocodesres char(01),
        itaciacod    like datrligitaaplitm.itaciacod
 end record

 define w_cts70m00    record
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
 define a_cts70m00    array[3] of record
    atdsrvano         like datmservico.atdsrvano
   ,atdsrvnum         like datmservico.atdsrvnum
   ,c24endtip         like datmlcl.c24endtip
   ,operacao          char (01)
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
 define a_cts70m00_bkp    array[3] of record
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
 define m_hist_cts70m00_bkp record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define f4            record
    acao              char(3),
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define mr_teclas record   #--->>> PSI SPR-2014-28503
    funcao_1          char(20)
   ,funcao_2          char(20)
   ,funcao_3          char(20)
   ,funcao_4          char(20)
   ,funcao_5          char(20)
   ,funcao_6          char(20)
   ,funcao_7          char(20)
   ,funcao_8          char(20)
   ,funcao_9          char(20)
   ,funcao_10         char(20)
   ,funcao_11         char(20)
   ,funcao_12         char(20)
   ,funcao_13         char(20)
   ,funcao_14         char(20)
 end record

 define arr_aux       smallint
 define w_retorno     smallint
 define m_acesso_ind  smallint
 define m_grava_hist  smallint
 define mr_grava_sugest char(01) # PSI-2013-07115

  define m_mdtcod		  like datmmdtmsg.mdtcod
 define m_pstcoddig   like dpaksocor.pstcoddig
 define m_socvclcod   like datkveiculo.socvclcod
 define m_srrcoddig   like datksrr.srrcoddig
 define l_vclcordes		char(20)
 define l_msgaltend	  char(1500)
 define l_texto 		  char(200)
 define l_dtalt			  date
 define l_hralt		    datetime hour to minute
 define l_lgdtxtcl	  char(80)
 define l_ciaempnom   char(50)
 define l_codrtgps    smallint
 define l_msgrtgps    char(100)

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

 define mr_prop       record    #--- SPR-2014-28503 - Numero Proposta (Forma Pagto)
        prpnum        like datmpgtinf.prpnum,
        sqlcode       integer,
        msg           char(80)
 end record

 define m_sel           smallint   # PSI-2013-07115
 define cty27g00_ret    integer    # psi-2012-22101/SPR-2014-28503 - MODULAR
 define m_vendaflg      smallint   #- SPR-2014-28503-Venda Servicos
 define m_c24astcodflag like datmligacao.c24astcod  #- SPR-2014-28503-Forma Pgto
 define m_pbmonline     like datksrvcat.catcod   #- PSI SPR-2014-28503 - Venda Online

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
      , m_atddatprg_aux date                      #-SPR-2016-01943
      , m_atdhorprg_aux datetime hour to minute   #-SPR-2016-01943

 #--------------------------#
 function cts70m00_prepare()
 #--------------------------#

 define l_sql    char(500)

 let     l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts70m00_001 from l_sql
 declare c_cts70m00_001 cursor for p_cts70m00_001


 let l_sql = " select asitipcod ",
            " from datkpbm ",
           " where c24pbmcod = ? "
 prepare pcts70m00003 from l_sql
 declare ccts70m00003 cursor for pcts70m00003


 let l_sql = " update datmservico set c24opemat = null",
             " where atdsrvnum = ? ",
             " and atdsrvano = ? "
 prepare pcts70m00004 from l_sql

 let l_sql = "select count(*) from datkdominio "  ,
             " where cponom = ? "                 ,
             " and   cpodes = ? "
 prepare pcts70m00005 from l_sql
 declare ccts70m00005 cursor for pcts70m00005

 let l_sql =  "select atdetpcod                          "
             ,"  from datmsrvacp                         "
             ," where atdsrvnum = ?                      "
             ,"   and atdsrvano = ?                      "
             ,"   and atdsrvseq = (select max(atdsrvseq) "
             ,"                      from datmsrvacp     "
             ,"                     where atdsrvnum = ?  "
             ,"                       and atdsrvano = ?) "

 prepare pcts70m00006 from l_sql
 declare ccts70m00006 cursor for pcts70m00006

#--- SPR-2014-28503 - Melhoria - Ajuste para pesquisa pelo indice
  let l_sql =  "select pgtfrmcod   "
             ,"  from datmpgtinf   "
             ," where orgnum = 29  "
             ,"   and prpnum = ?   "

 prepare pcts70m00007 from l_sql
 declare ccts70m00007 cursor for pcts70m00007

 let l_sql =  "select clinom, crtnum, bndcod,      "
             ,"crtvlddat, cbrparqtd                "
             ,"from datmcrdcrtinf                  "
             ,"where orgnum = ?                    "
             ,"and prpnum = ?                      "
             ,"and pgtseqnum = (select             "
             ,"max(pgtseqnum) from                 "
             ,"datmcrdcrtinf a                     "
             ,"where a.orgnum = ?                  "
             ,"and prpnum = ?)                     "

 prepare pcts70m00008 from l_sql
 declare ccts70m00008 cursor for pcts70m00008

 let l_sql =  "select pgtfrmdes      "
             ,"from datkpgtfrm       "
             ,"where pgtfrmcod = ?   "

 prepare pcts70m00009 from l_sql
 declare ccts70m00009 cursor for pcts70m00009

 #let l_sql =  "select bnddes         "
 #            ,"from datkcrtbnd       "
 #            ,"where bndcod = ?      "

 let l_sql =  "select carbndnom       "
             ,"from   fcokcarbnd      "
             ,"where  carbndcod = ?   "

 prepare pcts70m00010 from l_sql
 declare ccts70m00010 cursor for pcts70m00010


 #--- SPR-2014-28503 - Forma Pagamento
 let l_sql = "select c24astcod     "
            ,"  from datmligacao   "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
            ," order by lignum     "
 prepare pcts70m00011 from l_sql
 declare ccts70m00011 cursor for pcts70m00011

 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAPSFAZ' "
 prepare pcts70m00011a from l_sql
 declare ccts70m00011a cursor for pcts70m00011a


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql =  "select c24soltipcod "
             ," from datmligacao lig "
             ," where lig.atdsrvnum = ? "
             ,"  and lig.atdsrvano  = ? "
             ,"  and lig.lignum = (  "
             ,"         select min(lignum) "
             ,"           from datmligacao lim "
             ,"          where lim.atdsrvnum = lig.atdsrvnum  "
             ,"            and lim.atdsrvano = lig.atdsrvano )"
 prepare pcts70m00012 from l_sql
 declare ccts70m00012 cursor for pcts70m00012


#--- PSI SPR-2014-28503-Venda Online
 let l_sql = "  select 1 "
            ," from iddkdominio "
            ," where cponom = 'altvlrvnd' "
            ,"  and cpocod = ? "
 prepare pcts70m00013 from l_sql
 declare ccts70m00013 cursor for pcts70m00013


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql = "  select 1 "
            ," from datkdominio "
            ," where cponom = 'altvlrvnd' "
            ,"  and cpocod = ? "
 prepare pcts70m00014 from l_sql
 declare ccts70m00014 cursor for pcts70m00014

 let l_sql = " select grlinf "
            ,"   from datkgeral "
            ,"  where grlchv = 'PFAZROTAATIVA'"

 prepare p_cts70m00015 from l_sql
 declare c_cts70m00015 cursor for p_cts70m00015


 let m_prep_sql = true

 end function

#--------------------------------------------------------------------
 function cts70m00()
#--------------------------------------------------------------------

 define lr_parametro record
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        ligcvntip    like datmligacao.ligcvntip,
        psscntcod    like kspmcntrsm.psscntcod ,
        acao         char(03),
        c24astcod    like datkassunto.c24astcod,
        solnom       char(15),
        atdsrvorg    like datmservico.atdsrvorg,
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
          , m_rsrchvant 
          , m_atddatprg_aux           #-SPR-2016-01943
          , m_atdhorprg_aux to null   #-SPR-2016-01943


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
 let lr_parametro.psscntcod        = g_pss.psscntcod
 let lr_parametro.acao             = g_documento.acao
 let lr_parametro.c24astcod        = g_documento.c24astcod
 let lr_parametro.solnom           = g_documento.solnom
 let lr_parametro.atdsrvorg        = g_documento.atdsrvorg
 let lr_parametro.lignum           = g_documento.lignum
 let lr_parametro.soltip           = g_documento.soltip
 let lr_parametro.c24soltipcod     = g_documento.c24soltipcod
 let lr_parametro.lclocodesres     = g_documento.lclocodesres

 let mr_geral.atdsrvnum    = lr_parametro.atdsrvnum
 let mr_geral.atdsrvano    = lr_parametro.atdsrvano
 let mr_geral.ligcvntip    = lr_parametro.ligcvntip
 let mr_geral.psscntcod    = lr_parametro.psscntcod
 let mr_geral.acao         = lr_parametro.acao
 let mr_geral.c24astcod    = lr_parametro.c24astcod
 let mr_geral.solnom       = lr_parametro.solnom
 let mr_geral.atdsrvorg    = lr_parametro.atdsrvorg
 let mr_geral.lignum       = lr_parametro.lignum
 let mr_geral.soltip       = lr_parametro.soltip
 let mr_geral.c24soltipcod = lr_parametro.c24soltipcod
 let mr_geral.lclocodesres = lr_parametro.lclocodesres

 let m_outrolaudo = 0
 let m_srv_acionado = false
 initialize f4.* to null
 initialize mr_teclas.* to null  #--->>> PSI SPR-2014-28503

 call cts40g03_data_hora_banco(2)
      returning l_data,
                l_hora2

 let int_flag  = false
 let aux_today = l_data
 let aux_hora  = l_hora2
 let aux_ano   = aux_today[9,10]

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts70m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false

 whenever error continue
 open ccts70m00011a
 fetch ccts70m00011a into m_agendaw

 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 open window cts70m00 at 04,02 with form "cts70m00"
    attribute(form line 1)

 display "PSS AUTO" to msg_azul attribute(reverse)

 if mr_geral.atdsrvnum is null then
    let mr_teclas.funcao_1  =" <F1> Help          "
    let mr_teclas.funcao_2  =" <F3> Referencia    "
    let mr_teclas.funcao_3  =" <F5> Venda/F.Pgto  "
    let mr_teclas.funcao_4  =" <F6> Historico     "
    let mr_teclas.funcao_5  =" <F7> Funcoes       "
    let mr_teclas.funcao_6  =" <F8> Destino       "
    let mr_teclas.funcao_7  =" <F9> Copia         "
    let mr_teclas.funcao_8  =" <Ctrl+E> Email     "

    display "Teclas (F3)Referencia (F6)Historico (F9)Copia (Ctrl+F) Todas Funcoes" to msgfun
 else  #--- SPR-2014-28503 - Define teclas de funcao
    let mr_teclas.funcao_1  =" <F1> Help          "
    let mr_teclas.funcao_2  =" <F3> Referencia    "
    let mr_teclas.funcao_3  =" <F4> Apoio         "
    let mr_teclas.funcao_4  =" <F5> Venda/F.Pgto  "
    let mr_teclas.funcao_5  =" <F6> Historico     "
    let mr_teclas.funcao_6  =" <F7> Funcoes       "
    let mr_teclas.funcao_7  =" <F8> Destino       "
    let mr_teclas.funcao_8  =" <F9> Conclui       "
    let mr_teclas.funcao_9  =" <Ctrl+E> Email     "
    let mr_teclas.funcao_10 =" <Ctrl+T> Etapa     "
    let mr_teclas.funcao_11 =" <Ctrl+O> Correspond"
    let mr_teclas.funcao_12 =" <Ctrl+U> Justificat"

    display "Teclas (F3)Referencia (F6)Historico (F9)Conclui (Ctrl+F) Todas Funcoes" to msgfun
 end if

 initialize d_cts70m00.*,
            w_cts70m00.*,
            aux_libant  ,
            cpl_atdsrvnum,
            cpl_atdsrvano,
            cpl_atdsrvorg,
            m_hist_cts70m00_bkp,
            a_cts70m00_bkp to null

 for l_i = 1 to 3
    let a_cts70m00[l_i].operacao     = null
    let a_cts70m00[l_i].lclidttxt    = null
    let a_cts70m00[l_i].lgdtxt       = null
    let a_cts70m00[l_i].lgdtip       = null
    let a_cts70m00[l_i].lgdnom       = null
    let a_cts70m00[l_i].lgdnum       = null
    let a_cts70m00[l_i].brrnom       = null
    let a_cts70m00[l_i].lclbrrnom    = null
    let a_cts70m00[l_i].endzon       = null
    let a_cts70m00[l_i].cidnom       = null
    let a_cts70m00[l_i].ufdcod       = null
    let a_cts70m00[l_i].lgdcep       = null
    let a_cts70m00[l_i].lgdcepcmp    = null
    let a_cts70m00[l_i].lclltt       = null
    let a_cts70m00[l_i].lcllgt       = null
    let a_cts70m00[l_i].dddcod       = null
    let a_cts70m00[l_i].lcltelnum    = null
    let a_cts70m00[l_i].lclcttnom    = null
    let a_cts70m00[l_i].lclrefptotxt = null
    let a_cts70m00[l_i].c24lclpdrcod = null
    let a_cts70m00[l_i].ofnnumdig    = null
    let a_cts70m00[l_i].emeviacod    = null
    let a_cts70m00[l_i].celteldddcod = null
    let a_cts70m00[l_i].celtelnum    = null
    let a_cts70m00[l_i].endcmp       = null
 end for

 let w_cts70m00.ligcvntip  =  mr_geral.ligcvntip

 if g_documento.atdsrvnum is null then
    if cts70m00_assunto_assistencia(mr_geral.c24astcod) then

       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO DE ASSISTENCIA
       call cts70m00_display_assistencia(lr_parametro.c24astcod
                                        ,d_cts70m00.c24astdes
                                        ,d_cts70m00.c24pbmcod
                                        ,d_cts70m00.atddfttxt)
    else
       if cts70m00_assunto_transferencia(mr_geral.c24astcod) then

         # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO DE LEVA E TRAZ
         call cts70m00_display_assistencia(lr_parametro.c24astcod
                                          ,d_cts70m00.c24astdes
                                          ,d_cts70m00.c24pbmcod
                                          ,d_cts70m00.atddfttxt)
       else
         # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO DE COLISAO
         call cts70m00_display_colisao(lr_parametro.c24astcod,
                                       d_cts70m00.c24astdes)
       end if
    end if
 end if

 if mr_geral.atdsrvnum is not null then
    call cts70m00_consulta()

    let d_cts70m00.prsloccab = "Prs.Local:" #- SPR-2015-15533-Fechamento Srv GPS

    #--- SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
    if g_documento.prpnum is null then
       let d_cts70m00.prpnumdsp = " "
    else
       let d_cts70m00.prpnumdsp = "29/", g_documento.prpnum using "&&&&&&&&"
    end if

    if cts70m00_assunto_assistencia(mr_geral.c24astcod) then

       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO DE ASSISTENCIA
       call cts70m00_display_assistencia(lr_parametro.c24astcod,
                                         d_cts70m00.c24astdes,
                                         d_cts70m00.c24pbmcod,
                                         d_cts70m00.atddfttxt)
    else
       # -> EXIBE OS CAMPOS NECESSARIOS AO LAUDO COLISAO
       call cts70m00_display_colisao(lr_parametro.c24astcod,
                                     d_cts70m00.c24astdes)
    end if

    let d_cts70m00.asitipabvdes = "NAO PREV"

    select asitipabvdes
      into d_cts70m00.asitipabvdes
      from datkasitip
     where asitipcod = d_cts70m00.asitipcod

    display by name d_cts70m00.servico thru d_cts70m00.srvprlflg #---   SPR-2015-11582 - Retirada de campo da tela

    display by name d_cts70m00.atdtxt
    display by name d_cts70m00.atdlibdat
    display by name d_cts70m00.atdlibhor
    display by name d_cts70m00.c24solnom attribute (reverse)

    if mr_geral.psscntcod is not null  then

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

    display by name a_cts70m00[1].lgdtxt,
                    a_cts70m00[1].lclbrrnom,
                    a_cts70m00[1].cidnom,
                    a_cts70m00[1].ufdcod,
                    a_cts70m00[1].lclrefptotxt,
                    a_cts70m00[1].endzon,
                    a_cts70m00[1].dddcod,
                    a_cts70m00[1].lcltelnum,
                    a_cts70m00[1].lclcttnom,
                    a_cts70m00[1].celteldddcod,
                    a_cts70m00[1].celtelnum,
                    a_cts70m00[1].endcmp





    if d_cts70m00.atdlibflg = "N"   then
       display by name d_cts70m00.atdlibdat attribute (invisible)
       display by name d_cts70m00.atdlibhor attribute (invisible)
    end if

    if w_cts70m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    else
       if mr_geral.psscntcod  is not null      or
          d_cts70m00.vcllicnum   is not null   then
          call cts03g00 (1, ""                   ,
                            ""                   ,
                            ""                   ,
                            ""                   ,
                            d_cts70m00.vcllicnum ,
                            mr_geral.atdsrvnum   ,
                            mr_geral.atdsrvano)
       end if
       if d_cts70m00.srvprlflg = "S"  then
          let ws.confirma = cts08g01( "A","N","", "SERVICO PARTICULAR NAO DEVE SER" ,
                                      "PASSADO PARA FROTA PORTO SEGURO !","")
       end if
    end if

    let ws.grvflg = cts70m00_modifica()

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
    if g_pss.psscntcod is not null then

       # Busca do nome do corretor
       call cty22g00_busca_nome_corretor()
            returning d_cts70m00.cornom

       let l_anomod = g_doc_itau[1].autmodano

       let d_cts70m00.nom       = g_doc_itau[1].segnom clipped
       let d_cts70m00.corsus    = g_doc_itau[1].corsus clipped
       let d_cts70m00.vclcoddig = g_doc_itau[1].porvclcod clipped
       let d_cts70m00.vclanomdl = l_anomod
       let d_cts70m00.vcllicnum = g_doc_itau[1].autplcnum clipped
       let d_cts70m00.vcldes    =  g_doc_itau[1].autfbrnom clipped , "-",
                                   g_doc_itau[1].autlnhnom clipped, " - "  ,
                                   g_doc_itau[1].autmodnom clipped
       let d_cts70m00.vclcordes =  g_doc_itau[1].autcornom
    end if

    # -> COR DO VEICULO
    select cpodes
      into d_cts70m00.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = w_cts70m00.vclcorcod


    call cts02m01_ctgtrfcod(w_cts70m00.ctgtrfcod)
         returning d_cts70m00.camflg

    let d_cts70m00.prsloccab = "Prs.Local:"
    let d_cts70m00.prslocflg = "N"
    let d_cts70m00.c24astcod = mr_geral.c24astcod
    let d_cts70m00.c24solnom = mr_geral.solnom
    let d_cts70m00.c24astdes = c24geral8(d_cts70m00.c24astcod)

    display by name d_cts70m00.servico thru d_cts70m00.srvprlflg #- SPR-2015-11582

    display by name d_cts70m00.atdtxt
    display by name d_cts70m00.atdlibdat
    display by name d_cts70m00.atdlibhor
    display by name d_cts70m00.c24solnom attribute (reverse)

    open c_cts70m00_001

    whenever error continue
    fetch c_cts70m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts70m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts70m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window cts70m00
          return
       end if
    end if

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------

    if  mr_geral.psscntcod     is not null or
        d_cts70m00.vcllicnum   is not null then
       call cts03g00 (1, ""                   ,
                         ""                   ,
                         ""                   ,
                         ""                   ,
                         d_cts70m00.vcllicnum ,
                         mr_geral.atdsrvnum,
                         mr_geral.atdsrvano)
    end if

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    let ws.grvflg = cts70m00_inclui()

    if ws.grvflg = true  then
       call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts70m00.funmat,
                     w_cts70m00.data      , w_cts70m00.hora)

       if m_multiplo = 'S' then
          call cts10g02_historico_multiplo(l_atdsrvnum_mult,
                                           l_atdsrvano_mult,
                                           aux_atdsrvnum,
                                           aux_atdsrvano,
                                           w_cts70m00.funmat,
                                           w_cts70m00.data,
                                           w_cts70m00.hora)
       end if

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

 close window cts70m00

end function  ###  cts70m00

#--------------------------------------------------------------------
 function cts70m00_consulta()
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
    sqlcode        integer                   ,
    psscntcod      like kspmcntrsm.psscntcod
 end record

 define promptX   char (01)
 define l_tipolaudo   smallint

 define l_confirma char(1)
       ,l_errcod   smallint
       ,l_errmsg   char(80)

#--- SPR-2015-03912-Cadastro Clientes
 define lr_retcli  record
    coderro        smallint
   ,msgerro        char(80)
   ,clinom         like datksrvcli.clinom
   ,nscdat         like datksrvcli.nscdat
 end record

#--- SPR-2015-03912-Cadastro Pedidos
 define lr_retped  record
    coderro        smallint
   ,msgerro        char(80)
   ,srvpedcod      like datmsrvped.srvpedcod
 end record


 #--------------------------------------------------------------------
 # Dados do servico
 #--------------------------------------------------------------------

        let     promptX  =  null

        initialize  ws.*  to  null
        initialize  lr_retped to null  #--- SPR-2015-03912-Cadastro Pedidos   aqui
        initialize  lr_retcli to null  #--- SPR-2015-03912-Cadastro Clientes  aqui

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
        atddfttxt   ,             #- SPR-2015-11582-Retirada de campo da tela (atende em residencia)
        atdfnlflg   , srvprlflg   ,
        atdvcltip   , atdprinvlcod,
        ciaempcod   ,
        prslocflg   #- SPR-2015-15533-Fechamento Servs GPS
   into d_cts70m00.atdsrvorg
       ,d_cts70m00.nom
       ,d_cts70m00.vclcoddig
       ,d_cts70m00.vcldes
       ,d_cts70m00.vclanomdl
       ,d_cts70m00.vcllicnum
       ,d_cts70m00.corsus
       ,d_cts70m00.cornom
       ,ws.vclcorcod
       ,ws.funmat
       ,ws.empcod
       ,w_cts70m00.atddat
       ,w_cts70m00.atdhor
       ,d_cts70m00.atdlibflg
       ,d_cts70m00.atdlibhor
       ,d_cts70m00.atdlibdat
       ,w_cts70m00.atdhorpvt
       ,w_cts70m00.atdpvtretflg
       ,w_cts70m00.atddatprg
       ,w_cts70m00.atdhorprg
       ,d_cts70m00.asitipcod
       ,d_cts70m00.atddfttxt
       ,w_cts70m00.atdfnlflg
       ,d_cts70m00.srvprlflg
       ,w_cts70m00.atdvcltip
       ,d_cts70m00.atdprinvlcod
       ,g_documento.ciaempcod
       ,d_cts70m00.prslocflg  #- SPR-2015-15533-Fechamento Servs GPS
   from datmservico
  where atdsrvnum = mr_geral.atdsrvnum and
        atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    prompt "" for char promptX
    return
 end if

 let mr_geral.atdsrvorg = d_cts70m00.atdsrvorg
 let m_atddatprg_aux    = w_cts70m00.atddatprg ##-SPR-2016-01943
 let m_atdhorprg_aux    = w_cts70m00.atdhorprg ##-SPR-2016-01943

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
               returning a_cts70m00[1].lclidttxt
                        ,a_cts70m00[1].lgdtip
                        ,a_cts70m00[1].lgdnom
                        ,a_cts70m00[1].lgdnum
                        ,a_cts70m00[1].lclbrrnom
                        ,a_cts70m00[1].brrnom
                        ,a_cts70m00[1].cidnom
                        ,a_cts70m00[1].ufdcod
                        ,a_cts70m00[1].lclrefptotxt
                        ,a_cts70m00[1].endzon
                        ,a_cts70m00[1].lgdcep
                        ,a_cts70m00[1].lgdcepcmp
                        ,a_cts70m00[1].lclltt
                        ,a_cts70m00[1].lcllgt
                        ,a_cts70m00[1].dddcod
                        ,a_cts70m00[1].lcltelnum
                        ,a_cts70m00[1].lclcttnom
                        ,a_cts70m00[1].c24lclpdrcod
                        ,a_cts70m00[1].celteldddcod
                        ,a_cts70m00[1].celtelnum
                        ,a_cts70m00[1].endcmp
                        ,ws.sqlcode
                        ,a_cts70m00[1].emeviacod

 let m_subbairro[1].lclbrrnom = a_cts70m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts70m00[1].brrnom,
                                a_cts70m00[1].lclbrrnom)
      returning a_cts70m00[1].lclbrrnom

 select ofnnumdig into a_cts70m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = mr_geral.atdsrvano
    and atdsrvnum = mr_geral.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    prompt "" for char promptX
    return
 end if

 let a_cts70m00[1].lgdtxt = a_cts70m00[1].lgdtip clipped, " ",
                            a_cts70m00[1].lgdnom clipped, " ",
                            a_cts70m00[1].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(mr_geral.atdsrvnum,
                         mr_geral.atdsrvano,
                         2)
               returning a_cts70m00[2].lclidttxt
                        ,a_cts70m00[2].lgdtip
                        ,a_cts70m00[2].lgdnom
                        ,a_cts70m00[2].lgdnum
                        ,a_cts70m00[2].lclbrrnom
                        ,a_cts70m00[2].brrnom
                        ,a_cts70m00[2].cidnom
                        ,a_cts70m00[2].ufdcod
                        ,a_cts70m00[2].lclrefptotxt
                        ,a_cts70m00[2].endzon
                        ,a_cts70m00[2].lgdcep
                        ,a_cts70m00[2].lgdcepcmp
                        ,a_cts70m00[2].lclltt
                        ,a_cts70m00[2].lcllgt
                        ,a_cts70m00[2].dddcod
                        ,a_cts70m00[2].lcltelnum
                        ,a_cts70m00[2].lclcttnom
                        ,a_cts70m00[2].c24lclpdrcod
                        ,a_cts70m00[2].celteldddcod
                        ,a_cts70m00[2].celtelnum
                        ,a_cts70m00[2].endcmp
                        ,ws.sqlcode
                        ,a_cts70m00[2].emeviacod


 let m_subbairro[2].lclbrrnom = a_cts70m00[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts70m00[2].brrnom,
                                a_cts70m00[2].lclbrrnom)
      returning a_cts70m00[2].lclbrrnom

 select ofnnumdig into a_cts70m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = mr_geral.atdsrvano
    and atdsrvnum = mr_geral.atdsrvnum
    and c24endtip = 2

 if ws.sqlcode = notfound   then
    let d_cts70m00.dstflg = "N"
 else
    if ws.sqlcode = 0   then
       let d_cts70m00.dstflg = "S"
    else
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       prompt "" for char promptX
       return
    end if
 end if

 let a_cts70m00[2].lgdtxt = a_cts70m00[2].lgdtip clipped, " ",
                            a_cts70m00[2].lgdnom clipped, " ",
                            a_cts70m00[2].lgdnum using "<<<<#"


 #--->>>  Endereco correspondencia - PSI SPR-2014-28503
 #--------------------------------------------------------------------
 # Informacoes do local da correspondencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(mr_geral.atdsrvnum,
                         mr_geral.atdsrvano,
                         7)
               returning a_cts70m00[3].lclidttxt
                        ,a_cts70m00[3].lgdtip
                        ,a_cts70m00[3].lgdnom
                        ,a_cts70m00[3].lgdnum
                        ,a_cts70m00[3].lclbrrnom
                        ,a_cts70m00[3].brrnom
                        ,a_cts70m00[3].cidnom
                        ,a_cts70m00[3].ufdcod
                        ,a_cts70m00[3].lclrefptotxt
                        ,a_cts70m00[3].endzon
                        ,a_cts70m00[3].lgdcep
                        ,a_cts70m00[3].lgdcepcmp
                        ,a_cts70m00[3].lclltt
                        ,a_cts70m00[3].lcllgt
                        ,a_cts70m00[3].dddcod
                        ,a_cts70m00[3].lcltelnum
                        ,a_cts70m00[3].lclcttnom
                        ,a_cts70m00[3].c24lclpdrcod
                        ,a_cts70m00[3].celteldddcod
                        ,a_cts70m00[3].celtelnum
                        ,a_cts70m00[3].endcmp
                        ,ws.sqlcode
                        ,a_cts70m00[3].emeviacod

 let m_subbairro[3].lclbrrnom = a_cts70m00[3].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts70m00[3].brrnom,
                                a_cts70m00[3].lclbrrnom)
      returning a_cts70m00[3].lclbrrnom

 let a_cts70m00[3].lgdtxt = a_cts70m00[3].lgdtip clipped, " ",
                            a_cts70m00[3].lgdnom clipped, " ",
                            a_cts70m00[3].lgdnum using "<<<<#"

#--->>>  Endereco correspondencia - PSI SPR-2014-28503

 #--------------------------------------------------------------------
 # Dados complementares do servico
 #--------------------------------------------------------------------
 select rmcacpflg
       ,vclcamtip
       ,vclcrcdsc
       ,vclcrgflg
       ,vclcrgpso
       ,vcllibflg
   into d_cts70m00.rmcacpflg
       ,w_cts70m00.vclcamtip
       ,w_cts70m00.vclcrcdsc
       ,w_cts70m00.vclcrgflg
       ,w_cts70m00.vclcrgpso
       ,d_cts70m00.vcllibflg
   from datmservicocmp
  where atdsrvnum = mr_geral.atdsrvnum and
        atdsrvano = mr_geral.atdsrvano

 let w_cts70m00.lignum = cts20g00_servico(mr_geral.atdsrvnum, mr_geral.atdsrvano)

  call cts20g01_docto(w_cts70m00.lignum)
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

  call cts20g01_docto_tot(w_cts70m00.lignum)
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

 let mr_geral.psscntcod = g_pss.psscntcod

#--- SPR-2015-03912-Cadastro Clientes ---
# if mr_geral.psscntcod is not null  then
##    let d_cts70m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
## end if

 #--------------------------------------------------------------------
 # Informacoes do cliente #--- SPR-2015-03912-Cadastro Clientes
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
    error lr_retcli.msgerro clipped
    prompt "Erro ao Carregar Cadastro de Clientes  - Avise Informática " for char promptX
 end if

 let d_cts70m00.nscdat = lr_retcli.nscdat
 #--- SPR-2015-03912-Cadastro Clientes ---

 #--------------------------------------------------------------------
 # Informacoes do pedido -- SPR-2015-03912-Cadastro Pedidos
 #--------------------------------------------------------------------
 call opsfa015_conscadped(mr_geral.atdsrvnum,
                          mr_geral.atdsrvano)
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
        prompt "Erro ao Consultar Pedido  - Avise Informática " for char promptX
     end if
 end if

 let d_cts70m00.srvpedcod = lr_retped.srvpedcod
 #--- SPR-2015-03912-Cadastro Pedidos ---

#--------------------------------------------------------------------
# Dados da LIGACAO
#--------------------------------------------------------------------

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts70m00.c24astcod,
        w_cts70m00.ligcvntip,
        d_cts70m00.c24solnom
   from datmligacao
  where lignum = w_cts70m00.lignum

 let mr_geral.c24astcod = d_cts70m00.c24astcod

 select cpodes into d_cts70m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip" and
        cpocod = w_cts70m00.ligcvntip

 #--------------------------------------------------------------------
 # Descricao do ASSUNTO
 #--------------------------------------------------------------------
 let d_cts70m00.c24astdes = c24geral8(d_cts70m00.c24astcod)

 let d_cts70m00.servico = mr_geral.atdsrvorg using "&&",
                     "/", mr_geral.atdsrvnum using "&&&&&&&",
                     "-", mr_geral.atdsrvano using "&&"

 select cpodes
   into d_cts70m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod
    and funmat = ws.funmat

 let d_cts70m00.atdtxt = w_cts70m00.atddat        clipped, " ",
                         w_cts70m00.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)

 if w_cts70m00.atdhorpvt is not null  or
    w_cts70m00.atdhorpvt =  "00:00"   then
    let d_cts70m00.imdsrvflg = "S"
 end if

 if w_cts70m00.atddatprg is not null  then
    let d_cts70m00.imdsrvflg = "N"
 end if

 if w_cts70m00.vclcamtip is not null  and
    w_cts70m00.vclcamtip <>  " "      then
    let d_cts70m00.camflg = "S"
 else
    if w_cts70m00.vclcrgflg is not null  and
       w_cts70m00.vclcrgflg <>  " "      then
       let d_cts70m00.camflg = "S"
    else
       let d_cts70m00.camflg = "N"
    end if
 end if

 let aux_libant = d_cts70m00.atdlibflg

 if d_cts70m00.atdlibflg      = "N" then
    let d_cts70m00.atdlibdat  = w_cts70m00.atddat
    let d_cts70m00.atdlibhor  = w_cts70m00.atdhor
 end if

 select cpodes
   into d_cts70m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts70m00.atdprinvlcod

 select c24pbmcod
   into d_cts70m00.c24pbmcod
   from datrsrvpbm
  where atdsrvnum    = mr_geral.atdsrvnum
    and atdsrvano    = mr_geral.atdsrvano
    and c24pbminforg = 1
    and c24pbmseq    = 1

  #verificar se é ou se tem laudo de apoio

  if mr_geral.c24astcod <> 'PSP' then

     call cts10g00_verifica_multiplo(w_cts70m00.lignum)
          returning mr_retorno.*

     if mr_retorno.erro = 1 then
        call cts08g01("A","N",""," EXISTE UMA SOLICITACAO DE APOIO "," PARA ESSE SERVICO !","")
             returning l_confirma
     end if
  end if

  let m_c24lclpdrcod = a_cts70m00[1].c24lclpdrcod

end function  ###  cts70m00_consulta


#--------------------------------------------------------------------
 function cts70m00_modifica()
#--------------------------------------------------------------------

 define ws           record
    tabname          like systables.tabname     ,
    sqlcode          integer,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor
 end record

 define hist_cts70m00 record
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

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_c24endtip like datmlcl.c24endtip,   #--->>>  Endereco correspondencia - PSI SPR-2014-28503
        l_pestipcod char(1),                  #--- SPR-2015-03912-Cadastro Clientes ---
        l_srvpedcod like datmsrvped.srvpedcod #--- SPR-2015-03912-Cadastro Pedidos ---
       ,l_errcod   smallint
       ,l_errmsg   char(80)
 define lr_retorno       record
        coderro          smallint,
        msgerro          char(80)
 end record


 define lr_opsfa023    record
        retorno        smallint
       ,mensagem       char(100)
 end record

 define r_retorno_sku   record   #- SPR-2015-13708-Melhorias Calculo SKU
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg  #- SPR-2016-03565
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record
 define l_erro          char(1) #- SPR-2015-13708-Melhorias Calculo SKU

 initialize l_errcod, l_errmsg  to null

 initialize ws.*  to  null
 initialize hist_cts70m00.*  to  null
 initialize lr_cts10g02.*  to  null
 initialize lr_retorno to null
 initialize l_pestipcod to null     #- SPR-2015-03912-Cadastro Clientes
 initialize l_srvpedcod to null     #- SPR-2015-03912-Cadastro Pedidos
 initialize l_erro to null          #- SPR-2015-13708-Melhorias Calculo SKU
 initialize r_retorno_sku.* to null #- SPR-2015-13708-Melhorias Calculo SKU
 initialize lr_opsfa023.*   to null

 let m_pbmonline  = null #--- PSI SPR-2014-28503 - Venda Online
 let promptX      = null

#--- SPR-2014-28503 - Verifica se ha 'VENDA' associada (Forma Pagto)
 if not opsfa006_ha_venda(g_documento.atdsrvnum,
                          g_documento.atdsrvano) then
    if sqlca.sqlcode < 0 then
       prompt "" for char promptX
       return false
    end if
    let m_vendaflg = false

    #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
    call opsfa001_conskupbr(d_cts70m00.c24pbmcod
                           ,w_cts70m00.atddat)
         returning r_retorno_sku.catcod
                  ,r_retorno_sku.pgtfrmcod
                  ,r_retorno_sku.srvprsflg    #- SPR-2016-03565
                  ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                  ,r_retorno_sku.msg_erro

    if cts70m00_verifica_solicitante() then   #- SPR-2014-28503-Venda online
       #-- Indica que se trata de e_commerce
       let m_pbmonline = r_retorno_sku.catcod #- SPR-2015-13708-Melhorias Calculo SKU
       let m_vendaflg = false
    else
       #- Indica que não se trata de e_commerce. Enviar null no SKU (m_pbmonline)
       if sqlca.sqlcode < 0 then
          prompt "" for char promptX
          return false
       end if
       let m_pbmonline = null
       let m_vendaflg = false
    end if
 else
    let m_vendaflg = true
 end if

#--- SPR-2014-28503 - VERIFICA SE ASSUNTO PERMITE VENDA (Forma Pagto)
 whenever error continue
 open ccts70m00011 using g_documento.atdsrvnum,
                         g_documento.atdsrvano

 fetch ccts70m00011 into m_c24astcodflag

 whenever error stop

 if sqlca.sqlcode <> 0 then
    error "Erro ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
          " AO ACESSAR 'datmligacao'!!!"
    prompt "" for char promptX
    return false
 end if

 let cty27g00_ret = cty27g00_consiste_ast(m_c24astcodflag)
#--- SPR-2014-28503 - VERIFICA SE ASSUNTO PERMITE VENDA/F.PAGTO

 call cts70m00_input() returning hist_cts70m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts70m00      to null
    initialize d_cts70m00.*    to null
    initialize w_cts70m00.*    to null
    clear form
    return false
 end if

#--------------------------------------------------------------------
# Verifica solicitacao de guincho para caminhao
#--------------------------------------------------------------------
 if d_cts70m00.asitipcod = 1  or       ###  Guincho
    d_cts70m00.asitipcod = 3  then     ###  Guincho/Tecnico
    if d_cts70m00.camflg = "S"  then
       let w_cts70m00.atdvcltip = 3
    end if
 end if


 begin work

 update datmservico set ( nom      ,
                          corsus   ,
                          cornom   ,
                          vclcoddig,
                          vcldes   ,
                          vclanomdl,
                          vcllicnum,
                          vclcorcod,
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
                      = ( d_cts70m00.nom,
                          d_cts70m00.corsus,
                          d_cts70m00.cornom,
                          d_cts70m00.vclcoddig,
                          d_cts70m00.vcldes,
                          d_cts70m00.vclanomdl,
                          d_cts70m00.vcllicnum,
                          w_cts70m00.vclcorcod,
                          d_cts70m00.atdlibflg,
                          d_cts70m00.atdlibhor,
                          d_cts70m00.atdlibdat,
                          w_cts70m00.atdhorpvt,
                          w_cts70m00.atddatprg,
                          w_cts70m00.atdhorprg,
                          d_cts70m00.asitipcod,
                          d_cts70m00.srvprlflg,
                          w_cts70m00.atdpvtretflg,
                          w_cts70m00.atdvcltip,
                          d_cts70m00.atdprinvlcod,
                          d_cts70m00.prslocflg   )
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
   if d_cts70m00.atdsrvorg = 1 then  # Laudo de Assistência
      call ctx09g02_altera(mr_geral.atdsrvnum ,
                           mr_geral.atdsrvano ,
                           1                  , # sequencia
                           1                  , # Org. informacao 1-Segurado 2-Pst
                           d_cts70m00.c24pbmcod,
                           d_cts70m00.atddfttxt,
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
    set ( rmcacpflg
         ,vclcamtip
         ,vclcrcdsc
         ,vclcrgflg
         ,vclcrgpso
         ,vcllibflg)
      = ( d_cts70m00.rmcacpflg
         ,w_cts70m00.vclcamtip
         ,w_cts70m00.vclcrcdsc
         ,w_cts70m00.vclcrgflg
         ,w_cts70m00.vclcrgpso
         ,d_cts70m00.vcllibflg)
    where atdsrvnum = mr_geral.atdsrvnum  and
          atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos complementos do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char promptX
    return false
 end if

 call opsfa014_inscadcli(g_documento.cgccpfnum
                        ,g_documento.cgcord
                        ,g_documento.cgccpfdig
                        ,d_cts70m00.nom
                        ,d_cts70m00.nscdat
                        ,"")
      returning lr_retorno.coderro
               ,lr_retorno.msgerro

 if lr_retorno.coderro = false then
    rollback work
    error lr_retorno.msgerro clipped
    prompt "ERRO NA ATUALIZACAO CADASTRO CLIENTE. AVISE INFORMATICA" for char promptX
    return false
 end if
 #--- SPR-2015-03912-Cadastro de Clientes ---


 #=> SPR-2014-28503 - ATUALIZA OS DADOS DA VENDA
 if m_vendaflg or
    m_pbmonline is not null then  #- PSI SPR-2014-28503 - Venda Online
    #--- SPR-2015-03912-Inclui Pedido ---
    call opsfa015_inscadped(g_documento.cgccpfnum
                           ,g_documento.cgcord
                           ,g_documento.cgccpfdig
                           ,mr_geral.atdsrvnum
                           ,mr_geral.atdsrvano
                           ,"1") #--- Online - SPR-2015-22413
         returning lr_retorno.coderro
                  ,lr_retorno.msgerro
                  ,l_srvpedcod

    if lr_retorno.coderro = false then
       rollback work
       error lr_retorno.msgerro  clipped
       prompt "ERRO NA ATUALIZACAO DO PEDIDO. AVISE INFORMATICA" for char promptX
       return false
    end if   #--- SPR-2015-03912-Atualiza Pedido
 end if
#---<<<  SPR-2014-28503 - Atualiza dados da venda de servico

 #- SPR 2015-13708 - Melhorias Calculo SKU
 #--- Grava enderecos de (1)Ocorrencia (2)Destino (7)Correspondencia
 let l_erro = "N"
 let l_erro = cts70m00_grava_endereco (mr_geral.atdsrvnum
                                      ,mr_geral.atdsrvano)

 if l_erro = "S" then
    rollback work
    prompt "" for char promptX
    return false
 end if

 if aux_libant <> d_cts70m00.atdlibflg  then
    if d_cts70m00.atdlibflg = "S"  then
       let w_cts70m00.atdetpcod = 1
       let ws.atdetpdat = d_cts70m00.atdlibdat
       let ws.atdetphor = d_cts70m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let w_cts70m00.atdetpcod = 2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    let w_retorno = cts10g04_insere_etapa(mr_geral.atdsrvnum,
                                          mr_geral.atdsrvano,
                                          w_cts70m00.atdetpcod,
                                          w_cts70m00.atdprscod,
                                          " ",
                                          " ",
                                          w_cts70m00.srrcoddig)

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
  if w_cts70m00.atdfnlflg <> "S" then

     if cts34g00_acion_auto (d_cts70m00.atdsrvorg,
                             a_cts70m00[1].cidnom,
                             a_cts70m00[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO

        if not cts40g12_regras_aciona_auto (d_cts70m00.atdsrvorg
                                           ,mr_geral.c24astcod
                                           ,d_cts70m00.asitipcod
                                           ,a_cts70m00[1].lclltt
                                           ,a_cts70m00[1].lcllgt
                                           ,d_cts70m00.prslocflg
                                           ,"N"  #---   SPR-2015-11582 - Retirada de campo da tela (formulario)
                                           ,mr_geral.atdsrvnum
                                           ,mr_geral.atdsrvano
                                           ," "
                                           ,d_cts70m00.vclcoddig
                                           ,d_cts70m00.camflg) then
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
 
 #-SPR-2016-01943 - Inicio
 if (m_atddatprg_aux <> w_cts70m00.atddatprg  or
     m_atdhorprg_aux <> w_cts70m00.atdhorprg) then
     call opsfa023_emailposvenda(mr_geral.atdsrvnum,
                                 mr_geral.atdsrvano)
            returning lr_opsfa023.retorno,
                      lr_opsfa023.mensagem

      if lr_opsfa023.retorno = false then
         error lr_opsfa023.mensagem clipped
      end if
    end if
 #-SPR-2016-01943

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

 #---> Data de Fechamento - PSI SPR-2015-03912  ---
 call opsfa006_atualdtfecha(mr_geral.atdsrvnum
                           ,mr_geral.atdsrvano )
      returning lr_retorno.*

 if lr_retorno.coderro = false then
    error lr_retorno.msgerro clipped
    prompt "ERRO AO ATUALIZAR DATA ATENDIMENTO NA VENDA. AVISE INFORMATICA" for promptX
    return false
 end if

 #Projeto alteracao cadastro de destino
 if m_grava_hist then
    call cts70m00_grava_historico()
 end if

 return true

end function

#-------------------------------------------------------------------------------
 function cts70m00_verifica_solicitante() #--- PSI SPR-2014-28503 - Venda online
#-------------------------------------------------------------------------------
 define l_c24soltipcod  like datmligacao.c24soltipcod

 open ccts70m00012 using mr_geral.atdsrvnum
                        ,mr_geral.atdsrvano

 whenever error continue
 #--- datmligacao - captura solicitante
 fetch ccts70m00012 into l_c24soltipcod

 whenever error stop
  if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       error 'Erro SELECT ccts70m00012: ' ,sqlca.sqlcode,' / ',
             sqlca.sqlerrd[2] sleep 2
       return false
    end if
    let l_c24soltipcod = null
 end if

 #--- iddkdominio - verifica venda online
 open ccts70m00013 using l_c24soltipcod

 whenever error continue
 fetch ccts70m00013

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       error 'Erro SELECT ccts70m00013: ' ,sqlca.sqlcode,' / ',
             sqlca.sqlerrd[2] sleep 2
       return false
    else  #--- notfound iddkdominio
       open ccts70m00014 using l_c24soltipcod

       whenever error continue
       #--- datkdominio - verifica venda online
       fetch ccts70m00014

       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             error 'Erro SELECT ccts70m00014: ' ,sqlca.sqlcode,' / ',
                   sqlca.sqlerrd[2] sleep 2
             return false
          else
          	 return false
          end if
       end if
    end if
 end if

 return true

end function

#-------------------------------------------------------------------------------
 function cts70m00_inclui()
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


  define hist_cts70m00   record
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

        initialize hist_cts70m00.* to null

        let l_cambio_auto = null
        let l_doc_handle  = null
        let l_atdsrvnum   = null
        let l_atdsrvano   = null

	let l_txtsrv      = null

 initialize l_reserva_ativa to null

#--- PSI SPR-2014-28503 - VERIFICA SE ASSUNTO PERMITE VENDA (Forma Pagto)
 let cty27g00_ret = cty27g00_consiste_ast(g_documento.c24astcod)
 if cty27g00_ret = 1 then
    let m_vendaflg = true
 else
    let m_vendaflg = false
 end if

 while true
   initialize ws.*  to null

   if cts70m00_assunto_assistencia(d_cts70m00.c24astcod) then

       let d_cts70m00.atdsrvorg = 1     # Laudo de Assistência
       let g_documento.atdsrvorg = 1
       let ws.atdtip = "3"
   else

      if cts70m00_assunto_transferencia(d_cts70m00.c24astcod) then

       let d_cts70m00.atdsrvorg = 6  # Laudo de Transferencia (Leva e Traz)
       let g_documento.atdsrvorg = 6
       let ws.atdtip = "2"

      else

       let d_cts70m00.atdsrvorg = 4  # Laudo de sinistro
       let g_documento.atdsrvorg = 4
       let ws.atdtip = "1"

      end if
   end if

   let g_documento.acao = "INC"
   let ws_mtvcaps       = 0 ---> Campo utilizado para gravar o motivo da
                            ---> recusa em levar o veiculo para CAPS p/

   call cts70m00_input()
        returning hist_cts70m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts70m00      to null
       initialize d_cts70m00.*    to null
       initialize w_cts70m00.*    to null
       error " Operacao cancelada!" sleep 2
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts70m00.data is null  then
       let w_cts70m00.data   = aux_today
       let w_cts70m00.hora   = aux_hora
       let w_cts70m00.funmat = g_issk.funmat
   end if

   initialize ws.caddat to null
   initialize ws.cadhor to null
   initialize ws.cademp to null
   initialize ws.cadmat to null

   if  w_cts70m00.atdfnlflg is null  then
       let w_cts70m00.atdfnlflg = "N"
       let w_cts70m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
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
 if  w_cts70m00.atdvcltip <> 2  then
     let w_cts70m00.atdvcltip = ws.vclatmflg
 end if

 #------------------------------------------------------------------------------
 # Verifica solicitacao de guincho para caminhao
 #------------------------------------------------------------------------------
   if  d_cts70m00.asitipcod = 1  or       ###  Guincho
       d_cts70m00.asitipcod = 3  then     ###  Guincho/Tecnico
       if  d_cts70m00.camflg = "S"  then
           let w_cts70m00.atdvcltip = 3
       end if
   end if

 call cts70m00_grava_dados(ws.*,hist_cts70m00.*)
      returning l_ret
               ,l_mensagem
               ,aux_atdsrvnum
               ,aux_atdsrvano

 if l_ret <> 1 then
     error l_mensagem
  else
     if m_multiplo = 'S' then
       call cts70m00_desbloqueia_servico(aux_atdsrvnum,aux_atdsrvano)

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


       let mr_geral.c24astcod = 'PSP'
       let d_cts70m00.c24pbmcod = am_param.c24pbmcod
       let d_cts70m00.atddfttxt = am_param.atddfttxt
       let d_cts70m00.asitipcod = am_param.asitipcod
       let d_cts70m00.atdsrvorg = 1

       call cts70m00_grava_dados(ws.*,hist_cts70m00.*)
          returning l_ret, l_mensagem, l_atdsrvnum_mult,
              l_atdsrvano_mult

       if l_ret <> 1 then
          error l_mensagem
       end if

       call cts70m00_desbloqueia_servico(l_atdsrvnum_mult,l_atdsrvano_mult)

       let aux_atdsrvnum = l_atdsrvnum
       let aux_atdsrvano = l_atdsrvano
     end if
 end if

 call cts70m00_desbloqueia_servico(l_atdsrvnum_mult,l_atdsrvano_mult)

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
               call cts02m08(w_cts70m00.atdfnlflg,
                             d_cts70m00.imdsrvflg,
                             m_altcidufd,
                             d_cts70m00.prslocflg,
                             w_cts70m00.atdhorpvt,
                             w_cts70m00.atddatprg,
                             w_cts70m00.atdhorprg,
                             w_cts70m00.atdpvtretflg,
                             m_rsrchv,
                             m_operacao,
                             "",
                             a_cts70m00[1].cidnom,
                             a_cts70m00[1].ufdcod,
                             "",   # codigo de assistencia, nao existe no Ct24h
                             d_cts70m00.vclcoddig,
                             w_cts70m00.ctgtrfcod,
                             d_cts70m00.imdsrvflg,
                             a_cts70m00[1].c24lclpdrcod,
                             a_cts70m00[1].lclltt,
                             a_cts70m00[1].lcllgt,
                             g_documento.ciaempcod,
                             g_documento.atdsrvorg,
                             d_cts70m00.asitipcod,
                             "",   # natureza somente RE
                             "")   # sub-natureza somente RE
                   returning w_cts70m00.atdhorpvt,
                             w_cts70m00.atddatprg,
                             w_cts70m00.atdhorprg,
                             w_cts70m00.atdpvtretflg,
                             d_cts70m00.imdsrvflg,
                             m_rsrchv,
                             m_operacao,
                             m_altdathor

               display by name d_cts70m00.imdsrvflg

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
               #display 'cts70m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
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
   let d_cts70m00.servico = d_cts70m00.atdsrvorg using "&&",
                            "/", aux_atdsrvnum   using "&&&&&&&",
                            "-", aux_atdsrvano   using "&&"
   display d_cts70m00.servico to servico attribute (reverse)

#--->>> Forma de Pagamento
   #--- SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
   if mr_prop.prpnum is null then
      let d_cts70m00.prpnumdsp = " "
   else
      let d_cts70m00.prpnumdsp = "29/", mr_prop.prpnum using "&&&&&&&&"
   end if
   display by name d_cts70m00.prpnumdsp attribute (reverse)
#---<<< Forma de Pagamento

   error  " Verifique o numero do servico e tecle ENTER! "
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso! "
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function

#--------------------------------------------------------------------
function cts70m00_input()
#--------------------------------------------------------------------
   define hist_cts70m00 record
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
#        ,l_erro_srv         char(1) #- SPR-2014-28503-Inibir abertura do pop-up
         ,l_atdetpcod    like datmsrvacp.atdetpcod
         ,l_status       smallint
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

   #--- SPR-2015-03912-Cadastro Clientes ---
   define lr_retcli     record
          coderro        smallint
         ,msgerro        char(80)
         ,clinom         like datksrvcli.clinom
         ,nscdat         like datksrvcli.nscdat
   end record


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

   define r_retorno_sku   record   #--- SPR-2015-13708-Melhorias Calculo SKU
          catcod          like datksrvcat.catcod
         ,pgtfrmcod       like datksrvcat.pgtfrmcod
         ,srvprsflg       like datmsrvcathst.srvprsflg  #- SPR-2016-03565
         ,codigo_erro     smallint
         ,msg_erro        char(80)
   end record

   define l_envio         smallint
   define l_lclltt        like datmlcl.lclltt #- SPR-2014-28503-End correspondencia
   define l_lcllgt        like datmlcl.lcllgt #- SPR-2014-28503-End correspondencia
   define l_vendaflg      smallint            #- SPR-2014-28503-Forma Pagamento
   define l_idade         integer             #- SPR-2015-03912-Cadastro Clientes
   define l_srvpedcod     like datmsrvped.srvpedcod #- SPR-2015-03912-Cadastro Pedidos
   define l_c24endtip     like datmlcl.c24endtip #- SPR-2015-13708-Melhorias Calculo SKU
   define l_tempo         decimal(6,1)   #- SPR-2015-13708-Melhorias Calculo SKU
   define l_rota_final    char(32000)    #- SPR-2015-13708-Melhorias Calculo SKU
   define l_distancia     dec(8,2)       #- SPR-2015-13708-Melhorias Calculo SKU
   define l_erro          char(1)        #- SPR-2015-13708-Melhorias Calculo SKU
   define l_tp_rota_pfaz  char(7)        #- SPR-2015-13708-Melhorias Calculo SKU

   initialize m_cidnom
             ,m_ufdcod
             ,m_operacao
             ,m_imdsrvflg  to null

   initialize r_retorno_sku.* to null #- SPR-2015-13708-Melhorias Calculo SKU
   initialize l_erro to null          #- SPR-2015-13708-Melhorias Calculo SKU
   initialize l_tp_rota_pfaz to null     #- SPR-2015-13708-Melhorias Calculo SKU
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
   let     l_srvpedcod = null    #--- SPR-2015-03912-Cadastro Pedidos
   let     l_distancia = 0       #--- SPR-2015-13708-Melhorias Calculo SKU

   initialize lr_ctn00c02.* to null
   initialize hist_cts70m00.*  to  null
   initialize  ws.*  to  null

   let     promptX  =  null

   initialize  hist_cts70m00.*  to  null
   initialize  ws.*  to  null
   initialize ws.*  to null
   initialize l_confirma to null
   initialize lr_email.* to null
   initialize lr_retcli.* to null #- SPR-2015-03912-Cadastro Clientes

   let l_idade = 0                #- SPR-2015-03912-Cadastro Clientes

   let m_grava_hist = false

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
   let ws.dtparam        = l_data using "yyyy-mm-dd"
   let ws.dtparam[12,16] = l_hora2

   let ws.vcllicant          = d_cts70m00.vcllicnum
   let d_cts70m00.srvprlflg  =  "N"

   let l_vclcoddig_contingencia = d_cts70m00.vclcoddig
   let l_salva_nom              = d_cts70m00.nom

  # INICIO PSI-2013-7115
  if upshift(g_documento.acao) = "INC" and  (ga_dct > 0 and ga_dct is not null)
     then
     call cts08g01("A","S","","EXISTEM DADOS DO CLIENTE NA BASE","DESEJA UTILIZAR ?","")
          returning ws.confirma

      let  mr_grava_sugest = 'N'

      if ws.confirma = "S"   then
         call ctc68m00_dados_tela() returning m_sel

         if m_sel is not null and m_sel > 0
            then
            let a_cts70m00[1].lclcttnom    = ga_dados_saps[m_sel].segnom
            let a_cts70m00[1].lgdtip       = ga_dados_saps[m_sel].lgdtip
            let a_cts70m00[1].lgdnom       = ga_dados_saps[m_sel].lgdnom
            let a_cts70m00[1].lgdtxt       = ga_dados_saps[m_sel].lgdtxt
            let a_cts70m00[1].lgdnum       = ga_dados_saps[m_sel].lgdnum
            let a_cts70m00[1].lclbrrnom    = ga_dados_saps[m_sel].brrnom
            let a_cts70m00[1].cidnom       = ga_dados_saps[m_sel].cidnom
            let a_cts70m00[1].ufdcod       = ga_dados_saps[m_sel].ufdcod
            let a_cts70m00[1].endcmp       = ga_dados_saps[m_sel].endcmp
            let a_cts70m00[1].lclrefptotxt = ga_dados_saps[m_sel].lclrefptotxt
            let a_cts70m00[1].lgdcep       = ga_dados_saps[m_sel].lgdcep
            let a_cts70m00[1].lgdcepcmp    = ga_dados_saps[m_sel].lgdcepcmp
            let a_cts70m00[1].celteldddcod = ga_dados_saps[m_sel].celteldddcod
            let a_cts70m00[1].celtelnum    = ga_dados_saps[m_sel].celtelnum
            let a_cts70m00[1].dddcod       = ga_dados_saps[m_sel].dddcod
            let a_cts70m00[1].lcltelnum    = ga_dados_saps[m_sel].lcltelnum
            let d_cts70m00.nom             = ga_dados_saps[m_sel].segnom
            let d_cts70m00.corsus          = ga_dados_saps[m_sel].corsus
            let d_cts70m00.cornom          = ga_dados_saps[m_sel].cornom
            let d_cts70m00.vcllicnum       = ga_dados_saps[m_sel].vcllicnum
            let d_cts70m00.vclcoddig       = ga_dados_saps[m_sel].vclcoddig
            let d_cts70m00.vclanomdl       = ga_dados_saps[m_sel].vclanomdl
            let d_cts70m00.vclcordes       = ga_dados_saps[m_sel].vclcordes
            let d_cts70m00.vcldes          = ga_dados_saps[m_sel].vcldes

            display by name d_cts70m00.servico thru d_cts70m00.srvprlflg #---   SPR-2015-11582 - Retirada de campo da tela

            display by name d_cts70m00.atdtxt
            display by name d_cts70m00.atdlibdat
            display by name d_cts70m00.atdlibhor

            display by name a_cts70m00[1].lclcttnom
            display by name a_cts70m00[1].lgdtxt
            display by name a_cts70m00[1].lclbrrnom
            display by name a_cts70m00[1].cidnom
            display by name a_cts70m00[1].ufdcod
            display by name a_cts70m00[1].endcmp
            display by name a_cts70m00[1].lclrefptotxt
            display by name a_cts70m00[1].celteldddcod
            display by name a_cts70m00[1].celtelnum
            display by name a_cts70m00[1].dddcod
            display by name a_cts70m00[1].lcltelnum

            let  mr_grava_sugest = 'S'
         end if
      end if
   end if
   #FIM PSI-2013-01775

   let l_vendaflg = m_vendaflg       #--- PSI SPR-2014-28503-Forma Pagamento

   # PSI-2013-00440PR
   if g_documento.acao = "INC"
      then
      let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
   else
      let m_operacao = 5  # na consulta considera liberado para nao regular novamente
      #display 'consulta, considerar cota ja regulada'
   end if

   # situacao original do servico
   let m_imdsrvflg = d_cts70m00.imdsrvflg
   let m_cidnom = a_cts70m00[1].cidnom
   let m_ufdcod = a_cts70m00[1].ufdcod
   # PSI-2013-00440PR

   input by name d_cts70m00.nom
                ,d_cts70m00.nscdat       #--- SPR-2015-03912-Cadastro Clientes
                ,d_cts70m00.corsus
                ,d_cts70m00.cornom
                ,d_cts70m00.vclcoddig
                ,d_cts70m00.vclanomdl
                ,d_cts70m00.vcllicnum
                ,d_cts70m00.vclcordes
                ,d_cts70m00.camflg
                ,d_cts70m00.c24pbmcod
                ,d_cts70m00.prslocflg   #- SPR-2015-15533-Fechamento Servs GPS
                ,d_cts70m00.atddfttxt
                ,a_cts70m00[1].lgdtxt
                ,a_cts70m00[1].lclbrrnom
                ,a_cts70m00[1].cidnom
                ,a_cts70m00[1].ufdcod
                ,a_cts70m00[1].lclrefptotxt
                ,a_cts70m00[1].endzon
                ,a_cts70m00[1].dddcod
                ,a_cts70m00[1].lcltelnum
                ,a_cts70m00[1].lclcttnom
#---            ,d_cts70m00.asitipcod    #- SPR-2015-13708-Melhorias Calculo SKU
                ,d_cts70m00.dstflg
                ,d_cts70m00.rmcacpflg
                ,d_cts70m00.atdprinvlcod
                ,d_cts70m00.atdlibflg
                ,d_cts70m00.imdsrvflg
          without defaults


   before field nom
          display by name d_cts70m00.nom        attribute (reverse)

          if mr_geral.atdsrvnum   is not null   and
             mr_geral.atdsrvano   is not null   and
             d_cts70m00.camflg       =  "S"        and
             (w_cts70m00.atdfnlflg    =  "N" or w_cts70m00.atdfnlflg = "A") then
             call cts02m01(w_cts70m00.ctgtrfcod,
                           mr_geral.atdsrvnum,
                           mr_geral.atdsrvano,
                           w_cts70m00.vclcrgflg, w_cts70m00.vclcrgpso,
                           w_cts70m00.vclcamtip, w_cts70m00.vclcrcdsc)
                 returning w_cts70m00.vclcrgflg, w_cts70m00.vclcrgpso,
                           w_cts70m00.vclcamtip, w_cts70m00.vclcrcdsc
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
                prompt "Erro ao Consultar Cadastro de Clientes - Avise Informática " for char promptX
             end if

             if lr_retcli.clinom is not null then
                let d_cts70m00.nom    = lr_retcli.clinom
                let d_cts70m00.nscdat = lr_retcli.nscdat
             end if
          end if

          display by name d_cts70m00.nscdat
          display by name d_cts70m00.nom attribute (reverse)
          #--- SPR-2015-03912-Cadastro Clientes ---

   after field nom
          display by name d_cts70m00.nom

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                if m_agendaw = false   # regulacao antiga
                   then
                call cts02m03("S"                 ,
                              d_cts70m00.imdsrvflg,
                              w_cts70m00.atdhorpvt,
                              w_cts70m00.atddatprg,
                              w_cts70m00.atdhorprg,
                              w_cts70m00.atdpvtretflg)
                    returning w_cts70m00.atdhorpvt,
                              w_cts70m00.atddatprg,
                              w_cts70m00.atdhorprg,
                              w_cts70m00.atdpvtretflg
                else
                   call cts02m08("S"                 ,
                                 d_cts70m00.imdsrvflg,
                                 m_altcidufd,
                                 d_cts70m00.prslocflg,
                                 w_cts70m00.atdhorpvt,
                                 w_cts70m00.atddatprg,
                                 w_cts70m00.atdhorprg,
                                 w_cts70m00.atdpvtretflg,
                                 m_rsrchvant,
                                 m_operacao,
                                 "",
                                 a_cts70m00[1].cidnom,
                                 a_cts70m00[1].ufdcod,
                                 "",   # codigo de assistencia, nao existe no Ct24h
                                 d_cts70m00.vclcoddig,
                                 w_cts70m00.ctgtrfcod,
                                 d_cts70m00.imdsrvflg,
                                 a_cts70m00[1].c24lclpdrcod,
                                 a_cts70m00[1].lclltt,
                                 a_cts70m00[1].lcllgt,
                                 g_documento.ciaempcod,
                                 d_cts70m00.atdsrvorg,
                                 d_cts70m00.asitipcod,
                                 "",   # natureza somente RE
                                 "")   # sub-natureza nao existe
                       returning w_cts70m00.atdhorpvt,
                                 w_cts70m00.atddatprg,
                                 w_cts70m00.atdhorprg,
                                 w_cts70m00.atdpvtretflg,
                                 d_cts70m00.imdsrvflg,
                                 m_rsrchv,
                                 m_operacao,
                                 m_altdathor
                end if
                ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                next field nom
          end if


          if d_cts70m00.nom is null or
             d_cts70m00.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if

          #--- PSI SPR-2015-10068 - Consistir nome composto
          if cts70m00_consiste_nome() = "N" then
             error " Nome tem que ser Composto " sleep 2
             next field nom
          end if

          if w_cts70m00.atdfnlflg = "S"  then

              # ---> SALVA O NOME DO SEGURADO
             let d_cts70m00.nom = l_salva_nom
             display by name d_cts70m00.nom

             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                        " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                        "E INFORME AO  ** CONTROLE DE TRAFEGO **")

             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
             call cts02m03(w_cts70m00.atdfnlflg,
                           d_cts70m00.imdsrvflg,
                           w_cts70m00.atdhorpvt,
                           w_cts70m00.atddatprg,
                           w_cts70m00.atdhorprg,
                           w_cts70m00.atdpvtretflg)
                 returning w_cts70m00.atdhorpvt,
                           w_cts70m00.atddatprg,
                           w_cts70m00.atdhorprg,
                           w_cts70m00.atdpvtretflg
	          else
                call cts02m08(w_cts70m00.atdfnlflg,
                              d_cts70m00.imdsrvflg,
                              m_altcidufd,
                              d_cts70m00.prslocflg,
                              w_cts70m00.atdhorpvt,
                              w_cts70m00.atddatprg,
                              w_cts70m00.atdhorprg,
                              w_cts70m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts70m00[1].cidnom,
                              a_cts70m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts70m00.vclcoddig,
                              w_cts70m00.ctgtrfcod,
                              d_cts70m00.imdsrvflg,
                              a_cts70m00[1].c24lclpdrcod,
                              a_cts70m00[1].lclltt,
                              a_cts70m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts70m00.atdsrvorg,
                              d_cts70m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza nao existe
                    returning w_cts70m00.atdhorpvt,
                              w_cts70m00.atddatprg,
                              w_cts70m00.atdhorprg,
                              w_cts70m00.atdpvtretflg,
                              d_cts70m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)

             exit input
          end if

   before field nscdat     #--- SPR-2015-03912-Cadastro Clientes ---
          display by name d_cts70m00.nscdat attribute (reverse)

   after field nscdat
          display by name d_cts70m00.nscdat

          if (d_cts70m00.nscdat is null or
              d_cts70m00.nscdat = " ") and
              lr_retcli.nscdat is not null then
             let d_cts70m00.nscdat = lr_retcli.nscdat
             error "Data de Nascimento ja Cadastrada nao pode ser Removida"
             next field nscdat
          end if

          if d_cts70m00.nscdat is not null then
             if d_cts70m00.nscdat >= today then
                error "Data de Nascimento Nao pode ser > Data Atual"
                next field nscdat
             end if

             let l_idade = year(today) - year(d_cts70m00.nscdat)

             if l_idade > 110 then
                error "Data de Nascimento Invalida. Maior 110 anos"
                next field nscdat
             end if
          end if
      #--- SPR-2015-03912-Cadastro Clientes ---

   before field corsus
          display by name d_cts70m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts70m00.corsus

   before field cornom
          display by name d_cts70m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts70m00.cornom

   before field vclcoddig
          display by name d_cts70m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts70m00.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts70m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else
             if d_cts70m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts70m00.vclcoddig is null  or
                d_cts70m00.vclcoddig =  0     then
                let d_cts70m00.vclcoddig = agguvcl()
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts70m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cty05g03_pesq_catgtf(d_cts70m00.vclcoddig,
                                       l_data)
             returning lr_retorno.resultado,
                       lr_retorno.mensagem,
                       w_cts70m00.ctgtrfcod


             call cts02m01_ctgtrfcod(w_cts70m00.ctgtrfcod)
                  returning d_cts70m00.camflg


             let d_cts70m00.vcldes = cts15g00(d_cts70m00.vclcoddig)

             display by name d_cts70m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts70m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts70m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts70m00.vclanomdl is null or
                d_cts70m00.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts70m00.vclcoddig, d_cts70m00.vclanomdl) = false  then
                   error " Veiculo nao consta como fabricado em ", d_cts70m00.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts70m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts70m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts70m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

        #------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------
        if mr_geral.psscntcod   is null      and
           d_cts70m00.vcllicnum    is not null  then

           if d_cts70m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.senhaok  to null

              call cts13g00(d_cts70m00.c24astcod,
                            "", "", "", "",
                            d_cts70m00.vcllicnum,
                            "", "", "")
                   returning ws.blqnivcod, ws.senhaok
           end if

           #---------------------------------------------------------------
           # Verifica se ja' houve solicitacao de servico para apolice
           #---------------------------------------------------------------
           call cts03g00 (1, "",
                             "",
                             "",
                             "",
                             d_cts70m00.vcllicnum ,
                             mr_geral.atdsrvnum,
                             mr_geral.atdsrvano)
        end if

   before field vclcordes
          display by name d_cts70m00.vclcordes  attribute (reverse)

   after  field vclcordes
          display by name d_cts70m00.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts70m00.vclcordes is not null then
                let w_cts70m00.vclcordes = d_cts70m00.vclcordes[2,9]

                select cpocod into  w_cts70m00.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts70m00.vclcordes

                if sqlca.sqlcode = notfound  then
                   error " Cor fora do padrao!"
                   call c24geral4()
                        returning w_cts70m00.vclcorcod, d_cts70m00.vclcordes

                   if w_cts70m00.vclcorcod  is null   then
                      error " Cor do veiculo deve ser informado!"
                      next field vclcordes
                   else
                      display by name d_cts70m00.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts70m00.vclcorcod, d_cts70m00.vclcordes

                if w_cts70m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts70m00.vclcordes
                end if
             end if
          end if

   before field camflg
          display by name d_cts70m00.camflg attribute (reverse)

   after  field camflg
          display by name d_cts70m00.camflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts70m00.camflg  is null)  or
                 (d_cts70m00.camflg  <>  "S"   and
                  d_cts70m00.camflg  <>  "N")) then
                error " Informacao sobre caminhao/utilitario invalida!"
                next field camflg
             end if

             if d_cts70m00.camflg = "S"  then
                call cts02m01(w_cts70m00.ctgtrfcod,
                              mr_geral.atdsrvnum,
                              mr_geral.atdsrvano,
                              w_cts70m00.vclcrgflg, w_cts70m00.vclcrgpso,
                              w_cts70m00.vclcamtip, w_cts70m00.vclcrcdsc)
                    returning w_cts70m00.vclcrgflg, w_cts70m00.vclcrgpso,
                              w_cts70m00.vclcamtip, w_cts70m00.vclcrcdsc

                if w_cts70m00.vclcamtip  is null   and
                   w_cts70m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                   next field camflg
                end if
             else
                initialize w_cts70m00.vclcamtip to null
                initialize w_cts70m00.vclcrcdsc to null
                initialize w_cts70m00.vclcrgflg to null
                initialize w_cts70m00.vclcrgpso to null
             end if

             #--- SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA  (Forma Pagto)
             if g_documento.acao = 'ALT' then
                if d_cts70m00.c24pbmcod = 999 then  #=> MENOS PARA '999'
                   let m_vendaflg = false
                end if
                if m_vendaflg       or
                   cty27g00_ret = 1 then #- PERMITE F.PAGTO (SEM VENDA=CONSULTA) (Forma Pagto)

                   #- SPR-2015-13708-Melhorias Calculo SKU
                   #-- Consulta SKU por Problema
                   call opsfa001_conskupbr(d_cts70m00.c24pbmcod
                                          ,w_cts70m00.atddat)
                        returning r_retorno_sku.catcod
                                 ,r_retorno_sku.pgtfrmcod
                                 ,r_retorno_sku.srvprsflg  #- SPR-2016-03565
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

                   #- Se unidade do SKU for Km solicita enderecos antes da venda e calcula distancia - SPR-2015-13708
                   if r_retorno_sku.pgtfrmcod = 3 then #- 3 = Quilometro

	                 	  #- Informa Endereco - SPR-2015-13708-Melhorias Calculo SKU
	                 	  let l_c24endtip = 1  #- Endereco de ocorrencia
                      call cts70m00_informa_endereco(l_c24endtip
                                                    ,hist_cts70m00.*)
	                 	       returning ws.retflg
                                    ,hist_cts70m00.*

                      if ws.retflg = "N" then
                         error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3

                         if g_documento.atdsrvorg = 1 then
                            next field c24pbmcod
                         else
                            next field camflg
                         end if
                      end if

                      #- Informa Endereco - SPR-2015-13708-Melhorias Calculo SKU
                      let l_c24endtip = 2  #- Endereco de destino
                      call cts70m00_informa_endereco(l_c24endtip
                                                    ,hist_cts70m00.*)
	                 	      returning ws.retflg
                                    ,hist_cts70m00.*

                      if ws.retflg = "N" then
                         error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3

                         if g_documento.atdsrvorg = 1 then
                            next field c24pbmcod
                         else
                            next field camflg
                         end if
                      end if

                      let m_subbairro[2].lclbrrnom = a_cts70m00[2].lclbrrnom

                      call cts06g10_monta_brr_subbrr(a_cts70m00[2].brrnom,
                                                     a_cts70m00[2].lclbrrnom)
                           returning a_cts70m00[2].lclbrrnom

                      let a_cts70m00[2].lgdtxt = a_cts70m00[2].lgdtip clipped, " ",
                                                 a_cts70m00[2].lgdnom clipped, " ",
                                                 a_cts70m00[2].lgdnum using "<<<<#"

                      if a_cts70m00[2].lclltt <> l_lclltt or
                         a_cts70m00[2].lcllgt <> l_lcllgt or
                         (l_lclltt is null      and
                          a_cts70m00[2].lclltt is not null) or
                         (l_lcllgt is null      and
                          a_cts70m00[2].lcllgt is not null) then

                         # Verifica Kilometragem
                         if g_pss.psscntcod is not null then
                            call cts00m33_calckm("",
                            a_cts70m00[1].lclltt,
                            a_cts70m00[1].lcllgt,
                            a_cts70m00[2].lclltt,
                            a_cts70m00[2].lcllgt,
                            m_limites_plano.socqlmqtd)
                         end if
                      end if

                      if a_cts70m00[2].cidnom is not null and
                         a_cts70m00[2].ufdcod is not null then
                         call cts14g00 (d_cts70m00.c24astcod,
                                        "","","","",
                                        a_cts70m00[2].cidnom,
                                        a_cts70m00[2].ufdcod,
                                        "S",
                                        ws.dtparam)
                      end if

                      if mr_geral.atdsrvnum is null  and
                         mr_geral.atdsrvano is null  then
                         let a_cts70m00[2].operacao = "I"
                      else
                         select c24lclpdrcod
                           from datmlcl
                          where atdsrvnum = mr_geral.atdsrvnum
                            and atdsrvano = mr_geral.atdsrvano
                            and c24endtip = 2

                         if sqlca.sqlcode = notfound  then
                            let a_cts70m00[2].operacao = "I"
                         else
                            let a_cts70m00[2].operacao = "M"
                         end if
                      end if

                      if a_cts70m00[2].ofnnumdig is not null then
                         #prepare
                         select ofnstt
                             into ws.ofnstt
                             from sgokofi
                            where ofnnumdig = a_cts70m00[2].ofnnumdig

                         if ws.ofnstt = "C" then
                            # digita o motivo
                            let w_hist.hist1 = "OF CORT MOTIVO:"
                            call cts10m02 (w_hist.*) returning w_hist.*
                         end if
                      end if

                      #-- captura o tipo de rota Porto Faz
                      open c_cts70m00015

                      whenever error continue
                      fetch c_cts70m00015 into l_tp_rota_pfaz

                      whenever error stop
                      if sqlca.sqlcode = 100 then  #--- Verifica NotFound
                         error "Nao existe Rota Cadastrada para Porto Faz !!!" sleep 2
                         next field c24pbmcod
                      else
                         if r_retorno_sku.codigo_erro < 0 then
                      	     let int_flag = true
                            error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                                  " AO ACESSAR ROTA PORTO FAZ 'iddkdominio'!!!" sleep 5
                            exit input
                         end if
                      end if

                      #-- Calcula distancida Ocorrencia X Destino - SPR-2015-13708
                      call ctx25g02(a_cts70m00[01].lclltt  #- Ocorrencia
                                   ,a_cts70m00[01].lcllgt  #- Ocorrencia
                                   ,a_cts70m00[02].lclltt  #- Destino
                                   ,a_cts70m00[02].lcllgt  #- Destino
                                   ,l_tp_rota_pfaz         #- Tipo rota
                                   ,1)                     #- Gera Percurso
                          returning l_distancia
                                   ,l_tempo
                                   ,l_rota_final
                   end if

                   if not opsfa006_altera(g_documento.atdsrvnum
                                         ,g_documento.atdsrvano
                                         ,g_documento.prpnum
                                         ,m_pbmonline          #- SPR-2014-28503
                                         ,l_distancia          #- SPR-2015-13708
                                         ,w_cts70m00.atddat    #- SPR-2015-13708
                                         ,d_cts70m00.prslocflg #- SPR-2015-15533
                                         ,d_cts70m00.nom       #- SPR-2015-11582
                                         ,d_cts70m00.nscdat) then #- SPR-2015-11582
                      #- SPR 2015-13708 - Melhorias Calculo SKU
                      #-  O begin work e o rollback estah dentro do opsfa006
                      next field camflg  #--- Ocorreu erro
                   else
                      if r_retorno_sku.pgtfrmcod  = 3 then
                         #- SPR 2015-13708 - Melhorias Calculo SKU
                         #--- Grava enderecos de (1)Ocorrencia (2)Destino (7)Corresp
                         let l_erro = cts70m00_grava_endereco(g_documento.atdsrvnum
                                                             ,g_documento.atdsrvano)
                         if l_erro = "S" then
                            rollback work
                            let int_flag = true
                            prompt "" for char promptX
                            exit input
                         else
                         	  #- SPR 2015-13708 - Melhorias Calculo SKU
                         	  #-- O begin work estah dentro opsfa006
                         	  error "Venda e Enderecos Ocorrencia e Destino Atualizados" sleep 2
                         	  commit work
                         end if
                      end if
                   end if
                end if
             end if
          end if
          #-<<<  PSI SPR-2014-28503 - Inclusao Venda de Servicos

    before field c24pbmcod
        #- SPR-2015-15533-Fechamento Servs GPS
        if mr_geral.atdsrvnum is not null  or
           mr_geral.atdsrvano is not null  then
           if fgl_lastkey() = fgl_keyval("up")    or
              fgl_lastkey() = fgl_keyval("left")  then
              next field camflg
          end if
        end if

        if not cts70m00_assunto_assistencia(mr_geral.c24astcod) and
           not cts70m00_assunto_transferencia(mr_geral.c24astcod) then
           next field lgdtxt
        end if
        display by name d_cts70m00.c24pbmcod attribute (reverse)

        if g_documento.acao = 'ALT' then  --- SPR-2014-28503 - Inclusao Venda de Servicos
           display by name d_cts70m00.c24pbmcod #- SPR-2015-15533
           display by name d_cts70m00.atddfttxt #- SPR-2015-15533
           display by name d_cts70m00.prsloccab #- SPR-2015-15533
           display by name d_cts70m00.prslocflg #- SPR-2015-15533
           next field atddfttxt
        end if

    after  field c24pbmcod
        display by name d_cts70m00.c24pbmcod

        if d_cts70m00.c24pbmcod  is null  or
           d_cts70m00.c24pbmcod  =  0     then

           call ctc48m02(d_cts70m00.atdsrvorg) returning ws.c24pbmgrpcod,
                                                         ws.c24pbmgrpdes
           if ws.c24pbmgrpcod  is null  then
              error " Codigo de problema deve ser informado!"
              next field c24pbmcod
           else
              call ctc48m01(ws.c24pbmgrpcod,"")
                   returning d_cts70m00.c24pbmcod,
                             d_cts70m00.atddfttxt
              if d_cts70m00.c24pbmcod is null  then
                 error " Codigo de problema deve ser informado!"
                 next field c24pbmcod
              end if
           end if
        else
           if d_cts70m00.c24pbmcod <> 999 then
              select c24pbmdes into d_cts70m00.atddfttxt
                from datkpbm
               where c24pbmcod = d_cts70m00.c24pbmcod
              if status = notfound then
                 error " Codigo de problema invalido !"
                 call ctc48m02(d_cts70m00.atdsrvorg) returning ws.c24pbmgrpcod,
                                                               ws.c24pbmgrpdes
                 if ws.c24pbmgrpcod  is null  then
                    error " Codigo de problema deve ser informado!"
                    next field c24pbmcod
                 else
                    call ctc48m01(ws.c24pbmgrpcod,"")
                                    returning d_cts70m00.c24pbmcod,
                                              d_cts70m00.atddfttxt
                    if d_cts70m00.c24pbmcod is null  then
                       error " Codigo de problema deve ser informado!"
                       next field c24pbmcod
                    end if
                 end if
              end if
           end if
        end if

        display by name d_cts70m00.c24pbmcod
        display by name d_cts70m00.atddfttxt

        #- Trecho de codigo transferido da entrada do campo dstflg --->>>
        #-- SPR-2015-13708-Melhorias Calculo SKU
        open ccts70m00003 using d_cts70m00.c24pbmcod
        fetch ccts70m00003 into d_cts70m00.asitipcod

        let d_cts70m00.asitipabvdes = ""

        select asitipabvdes, asiofndigflg
          into d_cts70m00.asitipabvdes, w_cts70m00.asiofndigflg
          from datkasitip
         where asitipcod = d_cts70m00.asitipcod
           and asitipstt = "A"

        display by name d_cts70m00.asitipcod
        display by name d_cts70m00.asitipabvdes

        #->>> SPR-2015-15533-Fechamento Servs GPS
        #-  SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA (Forma Pagto)
        if d_cts70m00.c24pbmcod = 999 then  #=> MENOS PARA '999'
           let m_vendaflg = false
        else
           let m_vendaflg = l_vendaflg
           if g_documento.acao = 'INC' and
              m_vendaflg               then

              # Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
              call opsfa001_conskupbr(d_cts70m00.c24pbmcod
                                     ,l_data)
                   returning r_retorno_sku.catcod
                            ,r_retorno_sku.pgtfrmcod
                            , r_retorno_sku.srvprsflg   #- SPR-2016-03565
                            ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                            ,r_retorno_sku.msg_erro

              if r_retorno_sku.codigo_erro = -284 then
                 error "Existe mais de um SKU ativo para este problema!!!" sleep 2
                 next field c24pbmcod
              else
                 if r_retorno_sku.codigo_erro = 100 then  #--- Verifica NotFound
                    error "Nao existe SKU ativo para este problema!!!" sleep 2
                    next field c24pbmcod
                 else
                    if r_retorno_sku.codigo_erro < 0 then
                 	     let int_flag = true
                       error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                             " AO ACESSAR CADASTRO DE SKU 'datksrvcat'!!!" sleep 5
                       exit input
                    end if
                 end if
              end if
           end if
        end if
        #-<<< SPR-2015-15533-Fechamento Servs GPS

   #->>> SPR-2015-15533-Fechamento Servs GPS
   before field prslocflg
          if mr_geral.atdsrvnum is not null  or
             mr_geral.atdsrvano is not null  then
             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                initialize d_cts70m00.prslocflg  to null
                next field c24pbmcod
             else
                initialize d_cts70m00.prslocflg  to null
                next field atddfttxt
             end if
          else
          	 if r_retorno_sku.srvprsflg = "S" then  #- SPR-2016-03565
                let d_cts70m00.prslocflg = "N"      #- SPR-2016-03565
             end if

             if d_cts70m00.imdsrvflg = "N"    then
                initialize w_cts70m00.c24nomctt  to null
                let d_cts70m00.prslocflg = "N"
                display by name d_cts70m00.prslocflg
             end if
          end if

          display by name d_cts70m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts70m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24pbmcod
          end if

          if ((d_cts70m00.prslocflg  is null)  or
              (d_cts70m00.prslocflg  <> "S"    and
             d_cts70m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts70m00.prslocflg = "S"   then
          	 if r_retorno_sku.srvprsflg = "S" then  #- SPR-2016-03565
                error "SKU Rede Apartada - Prestador no Local Nao Permitido" #- SPR-2016-03565
                next field prslocflg #- SPR-2016-03565
             end if

             call ctn24c01()
                  returning w_cts70m00.atdprscod, w_cts70m00.srrcoddig,
                            w_cts70m00.atdvclsgl, w_cts70m00.socvclcod

             if w_cts70m00.atdprscod  is null then
                error " Faltam dados para prestador no local!"
                next field prslocflg
             end if

             let d_cts70m00.atdlibhor = w_cts70m00.hora
             let d_cts70m00.atdlibdat = w_cts70m00.data
             let w_cts70m00.atdfnlflg = "S"
             let w_cts70m00.atdetpcod =  4
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             let w_cts70m00.cnldat    = l_data
             let w_cts70m00.atdfnlhor = l_hora2
             let w_cts70m00.c24opemat = g_issk.funmat
             let w_cts70m00.atdhorpvt = "00:00"
             let d_cts70m00.imdsrvflg = "S"
          else
             initialize w_cts70m00.funmat   ,
                        w_cts70m00.cnldat   ,
                        w_cts70m00.atdfnlhor,
                        w_cts70m00.c24opemat,
                        w_cts70m00.atdfnlflg,
                        w_cts70m00.atdetpcod,
                        w_cts70m00.atdprscod,
                        w_cts70m00.c24nomctt  to null
          end if
          #-<<< SPR-2015-15533-Fechamento Servs GPS

          #->>> SPR-2015-15533-Fechamento Servs GPS
          #- SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA(Forma Pagto)
          if d_cts70m00.c24pbmcod = 999 then  #=> MENOS PARA '999'
             let m_vendaflg = false
          else
             let m_vendaflg = l_vendaflg
             if g_documento.acao = 'INC' and
                m_vendaflg               then
                #->>> SPR-2015-13708-Melhorias Calculo SKU
                if d_cts70m00.asitipcod = 2 or    ###  Tecnico
                   d_cts70m00.asitipcod = 4 or    ###  Chaveiro
                   d_cts70m00.asitipcod = 8 then  ###  Chaveiro/Disp.
                   initialize a_cts70m00[2].* to null
                   let a_cts70m00[2].operacao = "D"
                   let d_cts70m00.dstflg    = "N"
                   let d_cts70m00.rmcacpflg = "N"
                   display by name d_cts70m00.dstflg
                   display by name d_cts70m00.rmcacpflg

                   display by name d_cts70m00.asitipcod
                   display by name d_cts70m00.asitipabvdes
                else
                   #- Se unidade SKU for Km solicita enderecos antes da venda e calcula distancia
                   if r_retorno_sku.pgtfrmcod = 3 then #- 3 = Quilometro
	                 	  #--- Informa Endereco de Ocorrencia - SPR-2015-13708
	                 	  let l_c24endtip = 1  #- Endereco de ocorrencia
                      call cts70m00_informa_endereco(l_c24endtip
                                                    ,hist_cts70m00.*)
	                 	      returning ws.retflg
                                    ,hist_cts70m00.*

                      if ws.retflg = "N" then
                         error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3

                         if g_documento.atdsrvorg = 1 then
                            next field prslocflg
                         else
                            next field camflg
                         end if
                      end if

                      #--- Informa Endereco de Destino
                      let l_c24endtip = 2  #- Endereco de destino
                      call cts70m00_informa_endereco(l_c24endtip
                                                    ,hist_cts70m00.*)
	                 	      returning ws.retflg
                                    ,hist_cts70m00.*

                      if ws.retflg = "N" then
                         error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3

                         if g_documento.atdsrvorg = 1 then
                            next field prslocflg
                         else
                            next field camflg
                         end if
                      end if

                      let m_subbairro[2].lclbrrnom = a_cts70m00[2].lclbrrnom

                      call cts06g10_monta_brr_subbrr(a_cts70m00[2].brrnom,
                                                     a_cts70m00[2].lclbrrnom)
                           returning a_cts70m00[2].lclbrrnom

                      let a_cts70m00[2].lgdtxt = a_cts70m00[2].lgdtip clipped," ",
                                                 a_cts70m00[2].lgdnom clipped," ",
                                                 a_cts70m00[2].lgdnum using "<<<<#"

                      #->>> trecho de codigo tranferido dstflg-SPR-2015-13708
                      if a_cts70m00[2].lclltt <> l_lclltt or
                         a_cts70m00[2].lcllgt <> l_lcllgt or
                         (l_lclltt is null      and
                          a_cts70m00[2].lclltt is not null) or
                         (l_lcllgt is null      and
                          a_cts70m00[2].lcllgt is not null) then

                         # Verifica Kilometragem
                           if g_pss.psscntcod is not null then
                              call cts00m33_calckm("",
                              a_cts70m00[1].lclltt,
                              a_cts70m00[1].lcllgt,
                              a_cts70m00[2].lclltt,
                              a_cts70m00[2].lcllgt,
                              m_limites_plano.socqlmqtd)
                           end if
                      end if

                      if a_cts70m00[2].cidnom is not null and
                         a_cts70m00[2].ufdcod is not null then
                         call cts14g00 (d_cts70m00.c24astcod,
                                        "","","","",
                                        a_cts70m00[2].cidnom,
                                        a_cts70m00[2].ufdcod,
                                        "S",
                                        ws.dtparam)
                      end if

                      if mr_geral.atdsrvnum is null  and
                         mr_geral.atdsrvano is null  then
                         let a_cts70m00[2].operacao = "I"
                      else
                         select c24lclpdrcod
                           from datmlcl
                          where atdsrvnum = mr_geral.atdsrvnum  and
                                atdsrvano = mr_geral.atdsrvano  and
                                c24endtip = 2

                         if sqlca.sqlcode = notfound  then
                            let a_cts70m00[2].operacao = "I"
                         else
                            let a_cts70m00[2].operacao = "M"
                         end if
                      end if

                      if a_cts70m00[2].ofnnumdig is not null then
                         #prepare
                         select ofnstt
                             into ws.ofnstt
                             from sgokofi
                            where ofnnumdig = a_cts70m00[2].ofnnumdig

                         if ws.ofnstt = "C" then
                            # digita o motivo
                            let w_hist.hist1 = "OF CORT MOTIVO:"
                            call cts10m02 (w_hist.*) returning w_hist.*
                         end if
                         #-<<< trecho de codigo tranferido dstflg-SPR-2015-13708
                      end if

                      let d_cts70m00.dstflg    = "S"
                      display by name d_cts70m00.dstflg

                      #-- Calcula distancia da Ocorrencia X Destino
                      call ctx25g02(a_cts70m00[01].lclltt  #- Ocorrencia
                                   ,a_cts70m00[01].lcllgt  #- Ocorrencia
                                   ,a_cts70m00[02].lclltt  #- Destino
                                   ,a_cts70m00[02].lcllgt  #- Destino
                                   ,1                      #- Tipo rota
                                   ,1)                     #- Gera Percurso
                          returning l_distancia
                                   ,l_tempo
                                   ,l_rota_final
                   end if
                end if
                #-<<< SPR-2015-13708-Melhorias Calculo SKU

                if not opsfa006_inclui(r_retorno_sku.catcod #-- SPR-2015-13708
                                     ,l_distancia
                                     ,d_cts70m00.prslocflg) then #- SPR-2015-15533
                   next field prslocflg
                end if
             end if
          end if
          #-<<< SPR-2015-15533-Fechamento Servs GPS


   before field atddfttxt
         if g_documento.atdsrvorg = 1 then
            next field lgdtxt
         end if

          display by name d_cts70m00.atddfttxt   attribute (reverse)
          if d_cts70m00.c24pbmcod <> 999 then
          	 display by name d_cts70m00.atddfttxt
             next field lgdtxt
          end if

   after  field atddfttxt
          display by name d_cts70m00.atddfttxt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts70m00.atddfttxt is null  then
                error " Problema ou defeito deve ser informado!"
                next field atddfttxt
             end if
          end if


   before field lgdtxt
          let mr_geral.lclocodesres    = "N"
          let g_documento.lclocodesres = "N"

          #-- SPR-2015-13708-Melhorias Calculo SKU
          if r_retorno_sku.pgtfrmcod is not null and
             r_retorno_sku.pgtfrmcod <> 3 then   #- 3 = Quilometro

    	       let l_c24endtip = 1  #- Endereco de ocorrencia
             call cts70m00_informa_endereco(l_c24endtip
                                           ,hist_cts70m00.*)
   	              returning ws.retflg
                           ,hist_cts70m00.*

             if ws.retflg = "N" then
                error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..."
                sleep 3

                if g_documento.atdsrvorg = 1 then
                   next field c24pbmcod
                else
                   next field camflg
                end if
             end if
          end if

          #--->>> Endereco de correspondencia - PSI SPR-2014-28503
          call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA "
                       ,"O MESMO DE OCORRENCIA?","", "")
              returning ws.confirma

          if ws.confirma = "S" then   #--- Endereco correspondencia - PSI SPR-2014-28503
          	 let l_c24endtip = 7      #- Endereco de Correspondencia
             let a_cts70m00[3].atdsrvano     = g_documento.atdsrvano
             let a_cts70m00[3].atdsrvnum     = g_documento.atdsrvnum
             let a_cts70m00[3].c24endtip     = l_c24endtip

             let a_cts70m00[3].lclidttxt     = a_cts70m00[1].lclidttxt
             let a_cts70m00[3].cidnom        = a_cts70m00[1].cidnom
             let a_cts70m00[3].ufdcod        = a_cts70m00[1].ufdcod
             let a_cts70m00[3].brrnom        = a_cts70m00[1].brrnom
             let a_cts70m00[3].lclbrrnom     = a_cts70m00[1].lclbrrnom
             let a_cts70m00[3].endzon        = a_cts70m00[1].endzon
             let a_cts70m00[3].lgdtip        = a_cts70m00[1].lgdtip
             let a_cts70m00[3].lgdnom        = a_cts70m00[1].lgdnom
             let a_cts70m00[3].lgdnum        = a_cts70m00[1].lgdnum
             let a_cts70m00[3].lgdcep        = a_cts70m00[1].lgdcep
             let a_cts70m00[3].lgdcepcmp     = a_cts70m00[1].lgdcepcmp
             let a_cts70m00[3].lclltt        = a_cts70m00[1].lclltt
             let a_cts70m00[3].lcllgt        = a_cts70m00[1].lcllgt
             let a_cts70m00[3].lclrefptotxt  = a_cts70m00[1].lclrefptotxt
             let a_cts70m00[3].lclcttnom     = a_cts70m00[1].lclcttnom
             let a_cts70m00[3].dddcod        = a_cts70m00[1].dddcod
             let a_cts70m00[3].lcltelnum     = a_cts70m00[1].lcltelnum
             let a_cts70m00[3].c24lclpdrcod  = a_cts70m00[1].c24lclpdrcod
             let a_cts70m00[3].ofnnumdig     = a_cts70m00[1].ofnnumdig
             let a_cts70m00[3].celteldddcod  = a_cts70m00[1].celteldddcod
             let a_cts70m00[3].celtelnum     = a_cts70m00[1].celtelnum
             let a_cts70m00[3].endcmp        = a_cts70m00[1].endcmp

             let a_cts70m00[1].lgdtxt = a_cts70m00[1].lgdtip clipped, " ",
                                        a_cts70m00[1].lgdnom clipped, " ",
                                        a_cts70m00[1].lgdnum using "<<<<#"

             display by name a_cts70m00[1].lgdtxt
             display by name a_cts70m00[1].lclbrrnom
             display by name a_cts70m00[1].endzon
             display by name a_cts70m00[1].cidnom
             display by name a_cts70m00[1].ufdcod
             display by name a_cts70m00[1].lclrefptotxt
             display by name a_cts70m00[1].lclcttnom
             display by name a_cts70m00[1].dddcod
             display by name a_cts70m00[1].lcltelnum
             display by name a_cts70m00[1].celteldddcod
             display by name a_cts70m00[1].celtelnum
             display by name a_cts70m00[1].endcmp

          #- next field asitipcod #-- SPR-2015-11582 - Alterado campo p/ noentry
             next field dstflg
          end if

          #-- SPR-2015-13708-Melhorias Calculo SKU
	        let l_c24endtip = 7  #- Endereco de Correspondencia
          call cts70m00_informa_endereco(l_c24endtip
                                        ,hist_cts70m00.*)
	             returning ws.retflg
                        ,hist_cts70m00.*

          if ws.retflg = "N" then
             error " Dados referentes ao local de correspondencia incorretos ou nao preenchidos!"
             sleep 3

             if g_documento.atdsrvorg = 1 then
                next field c24pbmcod
             else
                next field camflg
             end if
          end if

          #--------------------------------------------------------------
          # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
          #--------------------------------------------------------------

          let m_subbairro[1].lclbrrnom = a_cts70m00[1].lclbrrnom

          call cts06g10_monta_brr_subbrr(a_cts70m00[1].brrnom,
                                         a_cts70m00[1].lclbrrnom)
               returning a_cts70m00[1].lclbrrnom

          let a_cts70m00[1].lgdtxt = a_cts70m00[1].lgdtip clipped, " ",
                                     a_cts70m00[1].lgdnom clipped, " ",
                                     a_cts70m00[1].lgdnum using "<<<<#"


          if a_cts70m00[1].cidnom is not null and
             a_cts70m00[1].ufdcod is not null then
             call cts14g00 (d_cts70m00.c24astcod,
                            "","","","",
                            a_cts70m00[1].cidnom,
                            a_cts70m00[1].ufdcod,
                            "S",
                            ws.dtparam)
          end if

          display by name a_cts70m00[1].lgdtxt
          display by name a_cts70m00[1].lclbrrnom
          display by name a_cts70m00[1].endzon
          display by name a_cts70m00[1].cidnom
          display by name a_cts70m00[1].ufdcod
          display by name a_cts70m00[1].lclrefptotxt
          display by name a_cts70m00[1].lclcttnom
          display by name a_cts70m00[1].dddcod
          display by name a_cts70m00[1].lcltelnum
          display by name a_cts70m00[1].celteldddcod
          display by name a_cts70m00[1].celtelnum
          display by name a_cts70m00[1].endcmp

       #- next field asitipcod  #- SPR-2015-11582 - Alterado campo p/ noentry
          next field dstflg


   after  field lgdtxt
          display by name a_cts70m00[1].lgdtxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts70m00.c24pbmcod <> 999 then
                next field c24pbmcod
             else
                next field atddfttxt
             end if
          end if
          if a_cts70m00[1].lgdtxt is null then
             error " Endereco deve ser informado!"
             next field lgdtxt
          end if

   before field lclbrrnom
          display by name a_cts70m00[1].lclbrrnom attribute (reverse)

   after  field lclbrrnom
          display by name a_cts70m00[1].lclbrrnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lgdtxt
          end if
          if a_cts70m00[1].lclbrrnom is null then
             error " Bairro deve ser informado!"
             next field lclbrrnom
          end if

   before field cidnom
          display by name a_cts70m00[1].cidnom attribute (reverse)

   after  field cidnom
          display by name a_cts70m00[1].cidnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclbrrnom
          end if
          if a_cts70m00[1].cidnom is null then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

   before field ufdcod
          display by name a_cts70m00[1].ufdcod attribute (reverse)

   after  field ufdcod
          display by name a_cts70m00[1].ufdcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cidnom
          end if
          if a_cts70m00[1].ufdcod is null then
             error " U.F. deve ser informada!"
             next field ufdcod
          end if

          # Verifica Cidade/UF
          select cidcod
            from glakcid
           where cidnom = a_cts70m00[1].cidnom
             and ufdcod = a_cts70m00[1].ufdcod

           if sqlca.sqlcode = notfound then
              error " Cidade/UF nao estao corretos!"
              next field ufdcod
           end if

   before field lclrefptotxt
          display by name a_cts70m00[1].lclrefptotxt attribute (reverse)

   after  field lclrefptotxt
          display by name a_cts70m00[1].lclrefptotxt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ufdcod
          end if

   before field endzon
          display by name a_cts70m00[1].endzon attribute (reverse)

   after  field endzon
          display by name a_cts70m00[1].endzon

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclrefptotxt
          end if
          if a_cts70m00[1].ufdcod  = "SP" then
             if a_cts70m00[1].endzon <> "NO" and
                a_cts70m00[1].endzon <> "SU" and
                a_cts70m00[1].endzon <> "LE" and
                a_cts70m00[1].endzon <> "OE" and
                a_cts70m00[1].endzon <> "CE" then
                error " Para a Capital favor informar zona NO/SU/LE/OE/CE!"
                next field endzon
             end if
          end if

   before field dddcod
          display by name a_cts70m00[1].dddcod attribute (reverse)

   after  field dddcod
          display by name a_cts70m00[1].dddcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field endzon
          end if

   before field lcltelnum
          display by name a_cts70m00[1].lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name a_cts70m00[1].lcltelnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field dddcod
          end if

   before field lclcttnom
          if d_cts70m00.c24pbmcod <> 999 then
             next field c24pbmcod
          else
             next field atddfttxt
          end if
          display by name a_cts70m00[1].lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name a_cts70m00[1].lclcttnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lcltelnum
          end if

   before field dstflg
   	      let d_cts70m00.dstflg = 'N'
          if d_cts70m00.asitipcod = 3 then
             let d_cts70m00.dstflg = 'S'
          end if
          display by name d_cts70m00.dstflg attribute (reverse)

   after  field dstflg
          display by name d_cts70m00.dstflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             #-- SPR-2015-13708-Melhorias Calculo SKU
             if d_cts70m00.asitipcod <> 2 and   ###  Tecnico
                d_cts70m00.asitipcod <> 4 and   ###  Chaveiro
                d_cts70m00.asitipcod <> 8 then  ###  Chaveiro/Disp.

                if r_retorno_sku.pgtfrmcod = 3 then  #- 3 = Quilometro
                   let d_cts70m00.dstflg    = "S"
                   display by name d_cts70m00.dstflg attribute (reverse)
                   next field atdprinvlcod
                end if
             end if
             #-- SPR-2015-13708-Melhorias Calculo SKU

             if d_cts70m00.dstflg is null    then
                error " Destino deve ser informado!"
                next field dstflg
             end if

             if d_cts70m00.dstflg <> "S"   and
                d_cts70m00.dstflg <> "N"   then
                error " Existe destino: (S)im ou (N)ao"
                next field dstflg
             end if

             if d_cts70m00.asitipcod = 3 and
                d_cts70m00.dstflg = "N" then
                error " Local de destino deve ser informado!"
                next field dstflg
             end if

             initialize w_hist.* to null

             if d_cts70m00.dstflg = "S"  then
                ---> So sugere o CAPS se estiver incluindo Laudo
                if g_documento.atdsrvorg = 1 then      #------ <<<<<<<<<<<<<<<
                   if g_documento.acao = "INC" then
                      ---> Verifica se Assuntos estao ligados ao CAPS
                      # Prepare
                      select cponom
                        from iddkdominio
                       where cponom = "c24astcod_caps"
                         and cpodes =  mr_geral.c24astcod

                      if sqlca.sqlcode <> notfound  then

                         ---> Verifica Tipo de Assistencia
                         if d_cts70m00.asitipcod = 1 or   ---> Guincho
                            d_cts70m00.asitipcod = 3 then ---> Guincho/Tecnico

                            ---> Verifica se ha Postos Caps que atendem o Servico
                            call oavpc071_consultadisponibilidadepostoscaps(
                                      w_cts70m00.ctgtrfcod
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

                               let l_lim_km = 50 ---> Fora da Residencia

                               ---> Mostrar Relacao dos postos CAPS
                               call oavpc071_retornapostoscaps(
                                                              w_cts70m00.ctgtrfcod
                                                             ,ws.c24pbmgrpcod
                                                             ,a_cts70m00[1].lclltt
                                                             ,a_cts70m00[1].lcllgt
                                                             ,l_lim_km
                                                             ,d_cts70m00.c24astcod)
                                    returning l_cappstcod
                                             ,l_stt
                                            ,a_cts70m00[2].lgdtip
                                            ,a_cts70m00[2].lgdnom
                                            ,a_cts70m00[2].lgdnum
                                            ,a_cts70m00[2].brrnom
                                            ,a_cts70m00[2].cidnom
                                            ,a_cts70m00[2].ufdcod
                                            ,l_cidcod
                                            ,a_cts70m00[2].lgdcep
                                            ,a_cts70m00[2].lgdcepcmp
                                            ,l_endlgdcmp
                                            ,a_cts70m00[2].lclltt
                                            ,a_cts70m00[2].lcllgt
                                            ,a_cts70m00[2].lclcttnom
                                            ,a_cts70m00[2].dddcod
                                            ,a_cts70m00[2].lcltelnum
                                            ,l_gchvclinchor
                                            ,l_gchvcfnlhor
                                            ,a_cts70m00[2].lclidttxt

                               ---> Nao escolheu nenhum CAPS
                               if l_cappstcod is null or
                                  l_cappstcod =  0    then

                                  let ws.confirma = cts08g01("A","N",""
                                                 ," JUSTIFIQUE O MOTIVO PELA NAO "
                                                 ," ACEITACAO DO CAPS ", "")

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
                end if                                   #------ <<<<<<<<<<<<<<<

                let l_lclltt = a_cts70m00[2].lclltt   #--- - PSI SPR-2014-28503
                let l_lcllgt = a_cts70m00[2].lcllgt   #--- - PSI SPR-2014-28503

                let a_cts70m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

                #- SPR-2015-13708-Melhorias Calculo SKU
	            	let l_c24endtip = 2  #- Endereco de destino
                call cts70m00_informa_endereco(l_c24endtip
                                              ,hist_cts70m00.*)
	            	     returning ws.retflg
                              ,hist_cts70m00.*

                if ws.retflg = "N" then
                   error " Dados referentes ao local de destino incorretos ou nao preenchidos..."
                   sleep 3
                   next field dstflg
                end if

                let m_subbairro[2].lclbrrnom = a_cts70m00[2].lclbrrnom

                call cts06g10_monta_brr_subbrr(a_cts70m00[2].brrnom,
                                               a_cts70m00[2].lclbrrnom)
                     returning a_cts70m00[2].lclbrrnom

                let a_cts70m00[2].lgdtxt = a_cts70m00[2].lgdtip clipped, " ",
                                           a_cts70m00[2].lgdnom clipped, " ",
                                           a_cts70m00[2].lgdnum using "<<<<#"

                if a_cts70m00[2].lclltt <> l_lclltt or          #--- <<<<<<<<<<<
                   a_cts70m00[2].lcllgt <> l_lcllgt or
                   (l_lclltt is null      and
                    a_cts70m00[2].lclltt is not null) or
                   (l_lcllgt is null      and
                    a_cts70m00[2].lcllgt is not null) then

                   # Verifica Kilometragem
                     if g_pss.psscntcod is not null then
                        call cts00m33_calckm("",
                        a_cts70m00[1].lclltt,
                        a_cts70m00[1].lcllgt,
                        a_cts70m00[2].lclltt,
                        a_cts70m00[2].lcllgt,
                        m_limites_plano.socqlmqtd)
                     end if
                end if

                if a_cts70m00[2].cidnom is not null and
                   a_cts70m00[2].ufdcod is not null then
                   call cts14g00 (d_cts70m00.c24astcod,
                                  "","","","",
                                  a_cts70m00[2].cidnom,
                                  a_cts70m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if
                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos",
                         " ou nao preenchidos!"
                   next field dstflg
                end if
                if mr_geral.atdsrvnum is null  and
                   mr_geral.atdsrvano is null  then
                   let a_cts70m00[2].operacao = "I"
                else
                   select c24lclpdrcod
                     from datmlcl
                    where atdsrvnum = mr_geral.atdsrvnum  and
                          atdsrvano = mr_geral.atdsrvano  and
                          c24endtip = 2
                   if sqlca.sqlcode = notfound  then
                      let a_cts70m00[2].operacao = "I"
                   else
                      let a_cts70m00[2].operacao = "M"
                   end if
                end if
                if a_cts70m00[2].ofnnumdig is not null then
                   #prepare
                   select ofnstt
                       into ws.ofnstt
                       from sgokofi
                      where ofnnumdig = a_cts70m00[2].ofnnumdig
                   if ws.ofnstt = "C" then
                      # digita o motivo
                      let w_hist.hist1 = "OF CORT MOTIVO:"
                      call cts10m02 (w_hist.*) returning w_hist.*
                   end if
                end if
             else
                if d_cts70m00.asitipcod    = 1   and
                   w_cts70m00.asiofndigflg = "S" then
                   error "Destino e Obrigatorio"
                   next field dstflg
                end if
                initialize a_cts70m00[2].*  to null
                let a_cts70m00[2].operacao = "D"
             end if
          end if                                               #--- <<<<<<<<<<<

   before field rmcacpflg
          display by name d_cts70m00.rmcacpflg attribute (reverse)

   after  field rmcacpflg
          display by name d_cts70m00.rmcacpflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts70m00.rmcacpflg  is null   then
                error " Acompanha remocao deve ser informado!"
                next field rmcacpflg
             end if

             if d_cts70m00.rmcacpflg <> "S"      and
                d_cts70m00.rmcacpflg <> "N"      then
                error " Acompanha remocao deve ser (S)im ou (N)ao!"
                next field rmcacpflg
             end if
          end if

   before field atdprinvlcod
          let d_cts70m00.atdprinvlcod = 2
          display by name d_cts70m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts70m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts70m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             # Prepare
             select cpodes
               into d_cts70m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts70m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts70m00.atdprinvldes
          end if


   before field atdlibflg
          ##-- inicializar o atdlibflg e passar para o proximo campo
          if d_cts70m00.atdlibflg is null then
             let d_cts70m00.atdlibflg = "S"

             if aux_libant is null  then
                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                let aux_libhor           = l_hora2
                let d_cts70m00.atdlibhor = aux_libhor
                let d_cts70m00.atdlibdat = l_data
             end if

             display by name d_cts70m00.atdlibflg
             next field imdsrvflg
          end if

          display by name d_cts70m00.atdlibflg attribute (reverse)

          if mr_geral.atdsrvnum is not null  and
             mr_geral.atdsrvano is not null  and
             w_cts70m00.atdfnlflg  =  "S"       then
             exit input
          end if

          if d_cts70m00.atdlibflg is null  and
             mr_geral.c24soltipcod  = 1   then   # Tipo solic = Segurado

          end if

   after  field atdlibflg
          display by name d_cts70m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts70m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts70m00.atdlibflg <> "S"  and
                d_cts70m00.atdlibflg <> "N"  then
                error " Envio liberado invalido!"
                next field atdlibflg
             end if

             if d_cts70m00.atdlibflg = "N"  and
                d_cts70m00.prslocflg = "S"  then
                error " Servico com prestador no local deve ser liberado!"
                next field atdlibflg
             end if

             let w_cts70m00.atdlibflg = d_cts70m00.atdlibflg
             display by name d_cts70m00.atdlibflg

             if aux_libant is null  then
                if w_cts70m00.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2)
                       returning l_data, l_hora2
                   let aux_libhor           = l_hora2
                   let d_cts70m00.atdlibhor = aux_libhor
                   let d_cts70m00.atdlibdat = l_data
                else
                   let d_cts70m00.atdlibflg = "N"
                   display by name d_cts70m00.atdlibflg
                   initialize d_cts70m00.atdlibhor to null
                   initialize d_cts70m00.atdlibdat to null
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
                   if w_cts70m00.atdlibflg = "S"  then
                      next field imdsrvflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts70m00.atdlibflg = "N"
                      display by name d_cts70m00.atdlibflg
                      initialize d_cts70m00.atdlibhor to null
                      initialize d_cts70m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      next field imdsrvflg
                   end if
                else
                   if aux_libant = "N"  then
                      if w_cts70m00.atdlibflg = "N"  then
                         next field imdsrvflg
                      else
                         call cts40g03_data_hora_banco(2)
                             returning l_data, l_hora2
                         let aux_libhor           = l_hora2
                         let d_cts70m00.atdlibhor = aux_libhor
                         let d_cts70m00.atdlibdat = l_data
                         next field imdsrvflg
                      end if
                   end if
                end if
             end if
          else
             next field rmcacpflg
          end if

   before field imdsrvflg
          display by name d_cts70m00.imdsrvflg attribute (reverse)

   after  field imdsrvflg
          display by name d_cts70m00.imdsrvflg

          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts70m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if

          if (m_cidnom != a_cts70m00[1].cidnom) or
             (m_ufdcod != a_cts70m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts70m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if

          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts70m00.imdsrvflg
          end if

          if m_cidnom is null then
             let m_cidnom = a_cts70m00[1].cidnom
          end if

          if m_ufdcod is null then
             let m_ufdcod = a_cts70m00[1].ufdcod
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
             if d_cts70m00.imdsrvflg is null   or
                d_cts70m00.imdsrvflg =  " "    then
                error " Informacoes sobre servico imediato deve ser informado!"
                next field imdsrvflg
             end if

             if d_cts70m00.imdsrvflg <> "S"    and
                d_cts70m00.imdsrvflg <> "N"    then
                error " Servico imediato: (S)im ou (N)ao!"
                next field imdsrvflg
             end if

             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
             call cts02m03(w_cts70m00.atdfnlflg,
                           d_cts70m00.imdsrvflg,
                           w_cts70m00.atdhorpvt,
                           w_cts70m00.atddatprg,
                           w_cts70m00.atdhorprg,
                           w_cts70m00.atdpvtretflg)
                 returning w_cts70m00.atdhorpvt,
                           w_cts70m00.atddatprg,
                           w_cts70m00.atdhorprg,
                           w_cts70m00.atdpvtretflg
             else
                call cts02m08(w_cts70m00.atdfnlflg,
                              d_cts70m00.imdsrvflg,
                              m_altcidufd,
                              d_cts70m00.prslocflg,
                              w_cts70m00.atdhorpvt,
                              w_cts70m00.atddatprg,
                              w_cts70m00.atdhorprg,
                              w_cts70m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts70m00[1].cidnom,
                              a_cts70m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts70m00.vclcoddig,
                              w_cts70m00.ctgtrfcod,
                              d_cts70m00.imdsrvflg,
                              a_cts70m00[1].c24lclpdrcod,
                              a_cts70m00[1].lclltt,
                              a_cts70m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts70m00.atdsrvorg,
                              d_cts70m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza nao existe
                    returning w_cts70m00.atdhorpvt,
                              w_cts70m00.atddatprg,
                              w_cts70m00.atdhorprg,
                              w_cts70m00.atdpvtretflg,
                              d_cts70m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor

                display by name d_cts70m00.imdsrvflg

                if int_flag
                   then
                   let int_flag = false
                   next field imdsrvflg
                end if
             end if

             if d_cts70m00.imdsrvflg = "S"  then
                if w_cts70m00.atdhorpvt is null  then
                   error " Horas previstas nao informadas para servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts70m00.atddatprg is null  or
                   w_cts70m00.atddatprg  = " "   or
                   w_cts70m00.atdhorprg is null  then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts70m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts70m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts70m00.atdprinvlcod

                    display by name d_cts70m00.atdprinvlcod
                    display by name d_cts70m00.atdprinvldes
                end if
             end if
          else
             if d_cts70m00.asitipcod = 2  or
                d_cts70m00.asitipcod = 4  then
             end if
          end if
          # PSI-2013-00440PR
          if m_agendaw = false   # regulacao antiga
             then
             ### REGULADOR
             if d_cts70m00.prslocflg <> "S"   then
                #### CHAMA REGULADOR ####
                if d_cts70m00.imdsrvflg = "S"  then
                   let ws.rglflg = ctc59m02 ( a_cts70m00[1].cidnom,
                                              a_cts70m00[1].ufdcod,
                                              d_cts70m00.atdsrvorg,
                                              d_cts70m00.asitipcod,
                                              aux_today,
                                              aux_hora,
                                              false)
                else
                   let ws.rglflg = ctc59m02 ( a_cts70m00[1].cidnom,
                                              a_cts70m00[1].ufdcod,
                                              d_cts70m00.atdsrvorg,
                                              d_cts70m00.asitipcod,
                                              w_cts70m00.atddatprg,
                                              w_cts70m00.atdhorprg,
                                              false )
                end if
                if ws.rglflg <> 0 then
                   let d_cts70m00.imdsrvflg = "N"
                   call ctc59m03 ( a_cts70m00[1].cidnom,
                                   a_cts70m00[1].ufdcod,
                                   d_cts70m00.atdsrvorg,
                                   d_cts70m00.asitipcod,
                                   aux_today,
                                   aux_hora)
                        returning  w_cts70m00.atddatprg,
                                   w_cts70m00.atdhorprg
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
            call opsfa006_inicializa() #--- PSI SPR-2014-28503-Incializa variaveis VENDA (OPSFA006) # <<<---

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

            call cts70m00_consulta()

            #- SPR-2015-11582 - Retirada de campo da tela
            display by name d_cts70m00.servico thru d_cts70m00.srvprlflg

            display by name d_cts70m00.atdtxt
            display by name d_cts70m00.atdlibdat
            display by name d_cts70m00.atdlibhor
            display by name d_cts70m00.c24solnom attribute (reverse)

            call cts02m00_ver_uso(l_atdsrvnum,l_atdsrvano,1)
                 returning l_msg
         else
            exit input
         end if
      end if


   on key (F1)
      if d_cts70m00.c24astcod is not null then
         call ctc58m00_vis(d_cts70m00.c24astcod)
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
                  call cts70m00_consulta()

                  display by name d_cts70m00.servico thru d_cts70m00.srvprlflg #---   SPR-2015-11582 - Retirada de campo da tela

                  display by name d_cts70m00.atdtxt
                  display by name d_cts70m00.atdlibdat
                  display by name d_cts70m00.atdlibhor
                  display by name d_cts70m00.c24solnom attribute (reverse)
               end if
            end if
         else
            error "Servico nao ligado a servicos de apoio"
         end if
      end if


   on key (F5)
      #--- PSI SPR-2014-28503 - FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
      if g_documento.acao = "INC" then
         error "Funcionalidade Indisponivel no momento da Inclusao!" sleep 3
      else
         #--- SPR-2014-28503-FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
         if m_vendaflg or
            cty27g00_ret = 1 then  #--- SPR-2014-28503-PERMITE F.PAGTO (SEM VENDA=CONSULTA)

            #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
            call opsfa001_conskupbr(d_cts70m00.c24pbmcod
                                   ,w_cts70m00.atddat)
                 returning r_retorno_sku.catcod
                          ,r_retorno_sku.pgtfrmcod
                          ,r_retorno_sku.srvprsflg  #- SPR-2016-03565
                          ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                          ,r_retorno_sku.msg_erro

            if r_retorno_sku.codigo_erro = -284 then
               error "Existe mais de um SKU ativo para este problema!!!"
               let r_retorno_sku.catcod = null
            else
               if r_retorno_sku.codigo_erro = 100 then  #--- Verifica NotFound
                  error "Nao existe SKU ativo para este problema!!!"
                  let r_retorno_sku.catcod = null
               else
                  if r_retorno_sku.codigo_erro < 0 then
                     error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                           " AO ACESSAR CADASTRO DE SKU 'datksrvcat'!!!" sleep 5
               	     let int_flag = true
                     exit input
                  end if
               end if
            end if

            if r_retorno_sku.pgtfrmcod  = 3 then
               if a_cts70m00_bkp[1].lclltt <> a_cts70m00[2].lclltt and
                  a_cts70m00_bkp[1].lcllgt <> a_cts70m00[2].lcllgt then
                  call cts70m00_bkp_info_dest(2, hist_cts70m00.*)
                       returning hist_cts70m00.*
               end if

               #-- Calcula distancida Ocorrencia X Destino - SPR-2015-13708
               call ctx25g02(a_cts70m00[01].lclltt  #- Ocorrencia
                            ,a_cts70m00[01].lcllgt  #- Ocorrencia
                            ,a_cts70m00[02].lclltt  #- Destino
                            ,a_cts70m00[02].lcllgt  #- Destino
                            ,1                      #- Tipo rota
                            ,1)                     #- Gera Percurso
                   returning l_distancia
                            ,l_tempo
                            ,l_rota_final
            end if

            if l_distancia is null or
            	 l_distancia = " " then
            	 let l_distancia = 0
            end if



         #josiane - grava endereço correspondencia

              #--->>> Endereco de correspondencia - PSI SPR-2014-28503
              whenever error continue
                 select 1 from datmlcl
                  where atdsrvnum = g_documento.atdsrvnum
                    and atdsrvano = g_documento.atdsrvano
                    and c24endtip = 7
              whenever error stop
              if sqlca.sqlcode = 100 then
                call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                              "O MESMO DE OCORRENCIA?","", "")
                    returning ws.confirma

                if ws.confirma = "S" then #- Endereco corresp - SPR-2014-28503
                   let a_cts70m00[3].lclidttxt    = a_cts70m00[1].lclidttxt
                   let a_cts70m00[3].cidnom       = a_cts70m00[1].cidnom
                   let a_cts70m00[3].ufdcod       = a_cts70m00[1].ufdcod
                   let a_cts70m00[3].brrnom       = a_cts70m00[1].brrnom
                   let a_cts70m00[3].lclbrrnom    = a_cts70m00[1].lclbrrnom
                   let a_cts70m00[3].endzon       = a_cts70m00[1].endzon
                   let a_cts70m00[3].lgdtip       = a_cts70m00[1].lgdtip
                   let a_cts70m00[3].lgdnom       = a_cts70m00[1].lgdnom
                   let a_cts70m00[3].lgdnum       = a_cts70m00[1].lgdnum
                   let a_cts70m00[3].lgdcep       = a_cts70m00[1].lgdcep
                   let a_cts70m00[3].lgdcepcmp    = a_cts70m00[1].lgdcepcmp
                   let a_cts70m00[3].lclltt       = a_cts70m00[1].lclltt
                   let a_cts70m00[3].lcllgt       = a_cts70m00[1].lcllgt
                   let a_cts70m00[3].lclrefptotxt = a_cts70m00[1].lclrefptotxt
                   let a_cts70m00[3].lclcttnom    = a_cts70m00[1].lclcttnom
                   let a_cts70m00[3].dddcod       = a_cts70m00[1].dddcod
                   let a_cts70m00[3].lcltelnum    = a_cts70m00[1].lcltelnum
                   let a_cts70m00[3].c24lclpdrcod = a_cts70m00[1].c24lclpdrcod
                   let a_cts70m00[3].ofnnumdig    = a_cts70m00[1].ofnnumdig
                   let a_cts70m00[3].celteldddcod = a_cts70m00[1].celteldddcod
                   let a_cts70m00[3].celtelnum    = a_cts70m00[1].celtelnum
                   let a_cts70m00[3].endcmp       = a_cts70m00[1].endcmp
                else
                   call cts06g03(7,
                                 13,
                                 w_cts70m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts70m00[3].lclidttxt,
                                 a_cts70m00[3].cidnom,
                                 a_cts70m00[3].ufdcod,
                                 a_cts70m00[3].brrnom,
                                 a_cts70m00[3].lclbrrnom,
                                 a_cts70m00[3].endzon,
                                 a_cts70m00[3].lgdtip,
                                 a_cts70m00[3].lgdnom,
                                 a_cts70m00[3].lgdnum,
                                 a_cts70m00[3].lgdcep,
                                 a_cts70m00[3].lgdcepcmp,
                                 a_cts70m00[3].lclltt,
                                 a_cts70m00[3].lcllgt,
                                 a_cts70m00[3].lclrefptotxt,
                                 a_cts70m00[3].lclcttnom,
                                 a_cts70m00[3].dddcod,
                                 a_cts70m00[3].lcltelnum,
                                 a_cts70m00[3].c24lclpdrcod,
                                 a_cts70m00[3].ofnnumdig,
                                 a_cts70m00[3].celteldddcod,
                                 a_cts70m00[3].celtelnum,
                                 a_cts70m00[3].endcmp,
                                 hist_cts70m00.*, a_cts70m00[3].emeviacod)
                       returning a_cts70m00[3].lclidttxt,
                                 a_cts70m00[3].cidnom,
                                 a_cts70m00[3].ufdcod,
                                 a_cts70m00[3].brrnom,
                                 a_cts70m00[3].lclbrrnom,
                                 a_cts70m00[3].endzon,
                                 a_cts70m00[3].lgdtip,
                                 a_cts70m00[3].lgdnom,
                                 a_cts70m00[3].lgdnum,
                                 a_cts70m00[3].lgdcep,
                                 a_cts70m00[3].lgdcepcmp,
                                 a_cts70m00[3].lclltt,
                                 a_cts70m00[3].lcllgt,
                                 a_cts70m00[3].lclrefptotxt,
                                 a_cts70m00[3].lclcttnom,
                                 a_cts70m00[3].dddcod,
                                 a_cts70m00[3].lcltelnum,
                                 a_cts70m00[3].c24lclpdrcod,
                                 a_cts70m00[3].ofnnumdig,
                                 a_cts70m00[3].celteldddcod,
                                 a_cts70m00[3].celtelnum,
                                 a_cts70m00[3].endcmp,
                                 ws.retflg,
                                 hist_cts70m00.*, a_cts70m00[3].emeviacod
                                 #display "ws.retflg = ",ws.retflg
                end if   #---<<<  Endereco de correspondencia - SPR-2014-28503



                #-----------------------------------
                # Grava locais de correspondencia
                #-----------------------------------
               begin work

                  if a_cts70m00[3].operacao is null then
                     let a_cts70m00[3].operacao = "I"
                  end if

                  let a_cts70m00[3].lclbrrnom = m_subbairro[3].lclbrrnom


                  let ws.sqlcode = cts06g07_local( a_cts70m00[3].operacao    ,
                                                   g_documento.atdsrvnum      ,
                                                   g_documento.atdsrvano      ,
                                                   7,    #--- Tp Endereco correspondencia
                                                   a_cts70m00[3].lclidttxt   ,
                                                   a_cts70m00[3].lgdtip      ,
                                                   a_cts70m00[3].lgdnom      ,
                                                   a_cts70m00[3].lgdnum      ,
                                                   a_cts70m00[3].lclbrrnom   ,
                                                   a_cts70m00[3].brrnom      ,
                                                   a_cts70m00[3].cidnom      ,
                                                   a_cts70m00[3].ufdcod      ,
                                                   a_cts70m00[3].lclrefptotxt,
                                                   a_cts70m00[3].endzon      ,
                                                   a_cts70m00[3].lgdcep      ,
                                                   a_cts70m00[3].lgdcepcmp   ,
                                                   a_cts70m00[3].lclltt      ,
                                                   a_cts70m00[3].lcllgt      ,
                                                   a_cts70m00[3].dddcod      ,
                                                   a_cts70m00[3].lcltelnum   ,
                                                   a_cts70m00[3].lclcttnom   ,
                                                   a_cts70m00[3].c24lclpdrcod,
                                                   a_cts70m00[3].ofnnumdig,
                                                   a_cts70m00[3].emeviacod   ,
                                                   a_cts70m00[3].celteldddcod,
                                                   a_cts70m00[3].celtelnum   ,
                                                   a_cts70m00[3].endcmp )


               commit work
            end if
            #fim josiane - grava endereço correspondencia


            if not opsfa006_altera(g_documento.atdsrvnum
                                  ,g_documento.atdsrvano
                                  ,g_documento.prpnum
                                  ,m_pbmonline          #- PSI SPR-2014-28503-Venda Online
                                  ,l_distancia          #- SPR-2015-13708
                                  ,w_cts70m00.atddat    #- SPR-2015-13708
                                  ,d_cts70m00.prslocflg #- SPR-2015-15533
                                  ,d_cts70m00.nom       #- SPR-2015-11582
                                  ,d_cts70m00.nscdat) then  #- SPR-2015-11582
               let int_flag = true
               exit input
            else
               if r_retorno_sku.pgtfrmcod  = 3 then
                  #- SPR 2015-13708 - Melhorias Calculo SKU
                  #--- Grava enderecos de (1)Ocorrencia (2)Destino (7)Corresp
                  let l_erro = cts70m00_grava_endereco(g_documento.atdsrvnum
                                                      ,g_documento.atdsrvano)
                  if l_erro = "S" then
                     rollback work
                     let int_flag = true
                     prompt "" for char promptX
                     exit input
                  else
                  	  #- SPR 2015-13708 - Melhorias Calculo SKU
                  	  #-- O begin work estah dentro opsfa006
                  	  error "Venda e Enderecos Ocorrencia e Destino Atualizados"
                  	  sleep 2
                  	  commit work
                  end if
               end if
            end if
         else
            error "Nao possui Venda/F.Pagto associados..."
         end if
      end if


   on key (F6)
      if mr_geral.atdsrvnum is null then
         call cts10m02 (hist_cts70m00.*) returning hist_cts70m00.*
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
            if d_cts70m00.camflg = "S"  then
               call cts02m01(w_cts70m00.ctgtrfcod,
                             mr_geral.atdsrvnum,
                             mr_geral.atdsrvano,
                             w_cts70m00.vclcrgflg, w_cts70m00.vclcrgpso,
                             w_cts70m00.vclcamtip, w_cts70m00.vclcrcdsc)
                   returning w_cts70m00.vclcrgflg, w_cts70m00.vclcrgpso,
                             w_cts70m00.vclcamtip, w_cts70m00.vclcrcdsc

               if w_cts70m00.vclcamtip  is null   and
                  w_cts70m00.vclcrgflg  is null   then
                  error " Faltam informacoes sobre caminhao/utilitario!"
               end if
            end if
         when 3   #### Distancia QTH-QTI
                 call cts70m00_calckm("C")

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
         if d_cts70m00.dstflg = "N"  then
            error " Nao foi informado destino para este servico!"
         else
            let a_cts70m00[2].lclbrrnom = m_subbairro[2].lclbrrnom

            let m_acesso_ind = false
            call cta00m06_acesso_indexacao_aut(d_cts70m00.atdsrvorg)
                 returning m_acesso_ind

            #Projeto alteracao cadastro de destino

            call cts70m00_bkp_info_dest(1, hist_cts70m00.*)
               returning hist_cts70m00.*

            #- SPR-2015-13708-Melhorias Calculo SKU
	          let l_c24endtip = 2  #- Endereco de destino
            call cts70m00_informa_endereco(l_c24endtip
                                          ,hist_cts70m00.*)
	               returning ws.retflg
                          ,hist_cts70m00.*

            if ws.retflg = "N" then
               error " Dados referentes ao local de destino incorretos ou nao preenchidos..."
               sleep 3
               next field dstflg
            end if

            #Projeto alteracao cadastro de destino
            let m_grava_hist = false

            if g_documento.acao = "ALT" then
               call cts70m00_verifica_tipo_atendim()
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
                        call cts70m00_verifica_op_ativa()
                           returning l_status

                        if l_status then

                           # ---> SALVA O NOME DO SEGURADO
                           let d_cts70m00.nom = l_salva_nom
                           display by name d_cts70m00.nom

                           error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                           error " Servico ja' acionado nao pode ser alterado!"
                           let m_srv_acionado = true
                           let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                      " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                           ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                           if m_agendaw = false then  # regulacao antiga
                              call cts02m03(w_cts70m00.atdfnlflg,
                                           d_cts70m00.imdsrvflg,
                                           w_cts70m00.atdhorpvt,
                                           w_cts70m00.atddatprg,
                                           w_cts70m00.atdhorprg,
                                           w_cts70m00.atdpvtretflg)
                                 returning w_cts70m00.atdhorpvt,
                                           w_cts70m00.atddatprg,
                                           w_cts70m00.atdhorprg,
                                           w_cts70m00.atdpvtretflg
                           else
                              call cts02m08(w_cts70m00.atdfnlflg,
                                            d_cts70m00.imdsrvflg,
                                            m_altcidufd,
                                            d_cts70m00.prslocflg,
                                            w_cts70m00.atdhorpvt,
                                            w_cts70m00.atddatprg,
                                            w_cts70m00.atdhorprg,
                                            w_cts70m00.atdpvtretflg,
                                            m_rsrchvant,
                                            m_operacao,
                                            "",
                                            a_cts70m00[1].cidnom,
                                            a_cts70m00[1].ufdcod,
                                            "",   # codigo de assistencia, nao existe no Ct24h
                                            d_cts70m00.vclcoddig,
                                            w_cts70m00.ctgtrfcod,
                                            d_cts70m00.imdsrvflg,
                                            a_cts70m00[1].c24lclpdrcod,
                                            a_cts70m00[1].lclltt,
                                            a_cts70m00[1].lcllgt,
                                            g_documento.ciaempcod,
                                            d_cts70m00.atdsrvorg,
                                            d_cts70m00.asitipcod,
                                            "",   # natureza somente RE
                                            "")   # sub-natureza nao existe
                                  returning w_cts70m00.atdhorpvt,
                                            w_cts70m00.atddatprg,
                                            w_cts70m00.atdhorprg,
                                            w_cts70m00.atdpvtretflg,
                                            d_cts70m00.imdsrvflg,
                                            m_rsrchv,
                                            m_operacao,
                                            m_altdathor
                           end if
                           ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)

                           call cts70m00_bkp_info_dest(2, hist_cts70m00.*)
                              returning hist_cts70m00.*

                           exit input

                        else
                           let m_grava_hist   = true
                           let m_srv_acionado = false

                           let m_subbairro[2].lclbrrnom = a_cts70m00[2].lclbrrnom
                           call cts06g10_monta_brr_subbrr(a_cts70m00[2].brrnom,
                                                          a_cts70m00[2].lclbrrnom)
                                returning a_cts70m00[2].lclbrrnom

                           let a_cts70m00[2].lgdtxt = a_cts70m00[2].lgdtip clipped, " ",
                                                      a_cts70m00[2].lgdnom clipped, " ",
                                                      a_cts70m00[2].lgdnum using "<<<<#"

                           if a_cts70m00[2].lclltt <> l_lclltt or
                              a_cts70m00[2].lcllgt <> l_lcllgt or
                              (l_lclltt is null                and
                               a_cts70m00[2].lclltt is not null)           or
                              (l_lcllgt is null                and
                               a_cts70m00[2].lcllgt is not null)           then

                              #Verifica Kilometragem
                              if g_pss.psscntcod is not null then
                                 call cts00m33_calckm("",
                                                      a_cts70m00[1].lclltt,
                                                      a_cts70m00[1].lcllgt,
                                                      a_cts70m00[2].lclltt,
                                                      a_cts70m00[2].lcllgt,
                                                      m_limites_plano.socqlmqtd)
                              end if
                           end if

						   						 ###Moreira-Envia-QRU-GPS

                           initialize m_mdtcod, m_pstcoddig,
                                      m_socvclcod, m_srrcoddig,
                                      l_msgaltend, l_texto,
                                      l_dtalt, l_hralt,
                                      l_vclcordes, l_lgdtxtcl,
                                      l_ciaempnom, l_msgrtgps,
                                      l_codrtgps  to  null

                           if m_grava_hist = true then
                              if ctx34g00_ver_acionamentoWEB(2) then

                                 whenever error continue
                                 if m_socvclcod is null then
                                    select socvclcod
                                      into m_socvclcod
                                      from datmsrvacp acp
                                     where acp.atdsrvnum = g_documento.atdsrvnum
                                       and acp.atdsrvano = g_documento.atdsrvano
                                       and acp.atdsrvseq = (select max(atdsrvseq)
                                                              from datmsrvacp acp1
                                                             where acp1.atdsrvnum = acp.atdsrvnum
                                                               and acp1.atdsrvano = acp.atdsrvano)
                                 end if

                                 select mdtcod
                                   into m_mdtcod
                                   from datkveiculo
                                  where socvclcod = m_socvclcod

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
                                    and cpocod = w_cts70m00.vclcorcod

                                 select empnom
                                   into l_ciaempnom
                                   from gabkemp
                                  where empcod  = g_documento.ciaempcod

                                 whenever error stop

                                 let l_dtalt = today
                                 let l_hralt = current
                                 let l_lgdtxtcl = a_cts70m00[2].lgdtip clipped, " ",
                                                  a_cts70m00[2].lgdnom clipped, " ",
                                                  a_cts70m00[2].lgdnum using "<<<<#", " ",
                                                  a_cts70m00[2].endcmp clipped

                                  let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                              l_ciaempnom clipped,
                                              '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             	       let l_msgaltend = l_texto clipped
                                     ," QRU: ",d_cts70m00.atdsrvorg using "&&"
                                          ,"/",mr_geral.atdsrvnum using "&&&&&&&"
                                          ,"-",mr_geral.atdsrvano using "&&"
                                     ," QTR: ",l_dtalt, " ", l_hralt
                                     ," QNC: ",d_cts70m00.nom       clipped, " "
                                              ,d_cts70m00.vcldes    clipped, " "
                                              ,d_cts70m00.vclanomdl clipped, " "
                                     ," QNR: ",d_cts70m00.vcllicnum clipped, " "
                                              ,l_vclcordes          clipped, " "
                                     ," QTI: ",a_cts70m00[2].lclidttxt clipped, " - "
                                              ,l_lgdtxtcl           clipped, " - "
                                              ,a_cts70m00[2].brrnom clipped, " - "
                                              ,a_cts70m00[2].cidnom clipped, " - "
                                              ,a_cts70m00[2].ufdcod clipped, " "
                                     ," Ref: ",a_cts70m00[2].lclrefptotxt clipped, " "
                                     ," Resp: ",a_cts70m00[2].lclcttnom clipped, " "
                                     ," Tel: (",a_cts70m00[2].dddcod    clipped, ") "
                                               ,a_cts70m00[2].lcltelnum clipped, " "
                                     ," Acomp: ", d_cts70m00.rmcacpflg  clipped, "#"

                                 #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
                                 call opsfa001_conskupbr(d_cts70m00.c24pbmcod
                                                        ,w_cts70m00.atddat)
                                      returning r_retorno_sku.catcod
                                               ,r_retorno_sku.pgtfrmcod
                                               ,r_retorno_sku.srvprsflg  #- SPR-2016-03565
                                               ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                                               ,r_retorno_sku.msg_erro

                                 if r_retorno_sku.codigo_erro = -284 then
                                    error "Existe mais de um SKU ativo para este problema!!!"
                                    let r_retorno_sku.catcod = null
                                 else
                                    if r_retorno_sku.codigo_erro = 100 then  #--- Verifica NotFound
                                       error "Nao existe SKU ativo para este problema!!!"
                                       let r_retorno_sku.catcod = null
                                    else
                                       if r_retorno_sku.codigo_erro < 0 then
                                          error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                                                " AO ACESSAR CADASTRO DE SKU 'datksrvcat'!!!" sleep 5
                                   	      let int_flag = true
                                          exit input
                                       end if
                                    end if
                                 end if

                                 if r_retorno_sku.catcod is not null and
                                    r_retorno_sku.pgtfrmcod  = 3 then
                                    #-- Calcula distancida Ocorrencia X Destino - SPR-2015-13708
                                    call ctx25g02(a_cts70m00[01].lclltt  #- Ocorrencia
                                                 ,a_cts70m00[01].lcllgt  #- Ocorrencia
                                                 ,a_cts70m00[02].lclltt  #- Destino
                                                 ,a_cts70m00[02].lcllgt  #- Destino
                                                 ,1                      #- Tipo rota
                                                 ,1)                     #- Gera Percurso
                                        returning l_distancia
                                                 ,l_tempo
                                                 ,l_rota_final

                                    if not opsfa006_altera(g_documento.atdsrvnum
                                                          ,g_documento.atdsrvano
                                                          ,g_documento.prpnum
                                                          ,m_pbmonline   #- PSI SPR-2014-28503-Venda Online
                                                          ,l_distancia   #- SPR-2015-13708
                                                          ,w_cts70m00.atddat #- SPR-2015-13708
                                                          ,d_cts70m00.prslocflg #- SPR-2015-15533
                                                          ,d_cts70m00.nom    #- SPR-2015-11582
                                                          ,d_cts70m00.nscdat) then  #- SPR-2015-11582

                                       let int_flag = true
                                       exit input
                                    else
                                       #- SPR 2015-13708 - Melhorias Calculo SKU
                                       #--- Grava enderecos de (1)Ocorrencia (2)Destino (7)Corresp
                                       let l_erro = cts70m00_grava_endereco(g_documento.atdsrvnum
                                                                           ,g_documento.atdsrvano)

                                       if l_erro = "S" then
                                          rollback work
                                          let int_flag = true
                                          prompt "" for char promptX
                                          exit input
                                       else
                                          # Se r_retorno_sku.pgtfrmcod  = 3
                                          # O begin work e o rollback ficará dentro do opsfa006
                                       	  error "Venda e Endereco de Destino foram Atualizados " sleep 2
                                       	  commit work
                                       end if
                                    end if
                                 end if

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

                        call cts70m00_bkp_info_dest(2, hist_cts70m00.*)
                           returning hist_cts70m00.*

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

            if a_cts70m00[2].cidnom is not null and
               a_cts70m00[2].ufdcod is not null then
               call cts14g00 (d_cts70m00.c24astcod,
                              "","","","",
                              a_cts70m00[2].cidnom,
                              a_cts70m00[2].ufdcod,
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
            call cts16g00 ("",
                           "",
                           "",
                           "",
                           4                    ,  # atdsrvorg (REMOCAO)
                           d_cts70m00.vcllicnum ,
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
                             returning a_cts70m00[1].lclidttxt
                                      ,a_cts70m00[1].lgdtip
                                      ,a_cts70m00[1].lgdnom
                                      ,a_cts70m00[1].lgdnum
                                      ,a_cts70m00[1].lclbrrnom
                                      ,a_cts70m00[1].brrnom
                                      ,a_cts70m00[1].cidnom
                                      ,a_cts70m00[1].ufdcod
                                      ,a_cts70m00[1].lclrefptotxt
                                      ,a_cts70m00[1].endzon
                                      ,a_cts70m00[1].lgdcep
                                      ,a_cts70m00[1].lgdcepcmp
                                      ,a_cts70m00[1].lclltt
                                      ,a_cts70m00[1].lcllgt
                                      ,a_cts70m00[1].dddcod
                                      ,a_cts70m00[1].lcltelnum
                                      ,a_cts70m00[1].lclcttnom
                                      ,a_cts70m00[1].c24lclpdrcod
                                      ,a_cts70m00[1].celteldddcod
                                      ,a_cts70m00[1].celtelnum # Amilton
                                      ,a_cts70m00[1].endcmp
                                      ,ws.sqlcode
                                      ,a_cts70m00[1].emeviacod

               select ofnnumdig into a_cts70m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = cpl_atdsrvano
                  and atdsrvnum = cpl_atdsrvnum
                  and c24endtip = 1

               if ws.sqlcode <> 0  then
                  error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                  prompt "" for char promptX
                  initialize hist_cts70m00.* to null
                  return hist_cts70m00.*
               end if

               let a_cts70m00[1].lgdtxt = a_cts70m00[1].lgdtip clipped, " ",
                                          a_cts70m00[1].lgdnom clipped, " ",
                                          a_cts70m00[1].lgdnum using "<<<<#"

               #-----------------------------------------------------------
               # Informacoes do local de destino
               #-----------------------------------------------------------
               call ctx04g00_local_gps(cpl_atdsrvnum,
                                       cpl_atdsrvano,
                                       2)
                             returning a_cts70m00[2].lclidttxt
                                      ,a_cts70m00[2].lgdtip
                                      ,a_cts70m00[2].lgdnom
                                      ,a_cts70m00[2].lgdnum
                                      ,a_cts70m00[2].lclbrrnom
                                      ,a_cts70m00[2].brrnom
                                      ,a_cts70m00[2].cidnom
                                      ,a_cts70m00[2].ufdcod
                                      ,a_cts70m00[2].lclrefptotxt
                                      ,a_cts70m00[2].endzon
                                      ,a_cts70m00[2].lgdcep
                                      ,a_cts70m00[2].lgdcepcmp
                                      ,a_cts70m00[2].lclltt
                                      ,a_cts70m00[2].lcllgt
                                      ,a_cts70m00[2].dddcod
                                      ,a_cts70m00[2].lcltelnum
                                      ,a_cts70m00[2].lclcttnom
                                      ,a_cts70m00[2].c24lclpdrcod
                                      ,a_cts70m00[2].celteldddcod
                                      ,a_cts70m00[2].celtelnum
                                      ,a_cts70m00[2].endcmp
                                      ,ws.sqlcode
                                      ,a_cts70m00[2].emeviacod

               # Prepare
               select ofnnumdig into a_cts70m00[2].ofnnumdig
                 from datmlcl
                where atdsrvano = cpl_atdsrvano
                  and atdsrvnum = cpl_atdsrvnum
                  and c24endtip = 2

               if ws.sqlcode = notfound   then
                  let d_cts70m00.dstflg = "N"
               else
                  if ws.sqlcode = 0   then
                     let d_cts70m00.dstflg = "S"
                  else
                     error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
                     prompt "" for char promptX
                     initialize hist_cts70m00.* to null
                     return hist_cts70m00.*
                  end if
               end if

               let a_cts70m00[2].lgdtxt = a_cts70m00[2].lgdtip clipped, " ",
                                          a_cts70m00[2].lgdnom clipped, " ",
                                          a_cts70m00[2].lgdnum using "<<<<#"

               call cts16g00_atendimento(cpl_atdsrvnum, cpl_atdsrvano)
                               returning d_cts70m00.nom,
                                         w_cts70m00.vclcorcod,
                                         d_cts70m00.vclcordes

               display by name d_cts70m00.servico thru d_cts70m00.srvprlflg #---   SPR-2015-11582 - Retirada de campo da tela

               display by name d_cts70m00.atdtxt
               display by name d_cts70m00.atdlibdat
               display by name d_cts70m00.atdlibhor

               display by name a_cts70m00[1].lgdtxt
               display by name a_cts70m00[1].lclbrrnom
               display by name a_cts70m00[1].endzon
               display by name a_cts70m00[1].cidnom
               display by name a_cts70m00[1].ufdcod
               display by name a_cts70m00[1].lclrefptotxt
               display by name a_cts70m00[1].lclcttnom
               display by name a_cts70m00[1].dddcod
               display by name a_cts70m00[1].lcltelnum
               display by name a_cts70m00[1].celteldddcod
               display by name a_cts70m00[1].celtelnum
               display by name a_cts70m00[1].endcmp

            end if
         end if
      else
         if d_cts70m00.atdlibflg = "N" then
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


   on key (control-t)  #--- SPR-2014-28503 - ACIONA A TELA DE MUDANCA DE ETAPA
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


   on key (control-f)  #--- SPR-2014-28503 - Aciona tela de funções
       call opsfa009(mr_teclas.*)


   on key (control-e)
     let lr_email.c24astcod = g_documento.c24astcod
     let lr_email.ligcvntip = g_documento.ligcvntip
     let lr_email.lignum    = w_cts70m00.lignum # g_documento.lignum
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

    on key (control-u)   #--->>>  Consulta Justificativas-SPR-2015-10068
       if g_documento.atdsrvnum is null or
          g_documento.acao = "INC"      then
          error "Funcao nao disponivel na inclusao!"
          continue input
       end if

       call opsfa003_consulta_justificativa(g_documento.atdsrvnum,
                                            g_documento.atdsrvano)

    on key (control-o)   #--->>>  Endereco correspondencia - PSI SPR-2014-28503
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
             error "ALTERACAO NAO PERMITIDA - PROCESSO DA VENDA ONLINE NAO FOI CONCLUIDO" sleep 2
             continue input
          end if
       end if
       # --- SPR-2015-03912-Cadastro Clientes ---

       #--------------------------------------------------------------------
       # Informacoes do local da correspondencia
       #--------------------------------------------------------------------
       call ctx04g00_local_gps(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               7)
                     returning a_cts70m00[3].lclidttxt
                              ,a_cts70m00[3].lgdtip
                              ,a_cts70m00[3].lgdnom
                              ,a_cts70m00[3].lgdnum
                              ,a_cts70m00[3].lclbrrnom
                              ,a_cts70m00[3].brrnom
                              ,a_cts70m00[3].cidnom
                              ,a_cts70m00[3].ufdcod
                              ,a_cts70m00[3].lclrefptotxt
                              ,a_cts70m00[3].endzon
                              ,a_cts70m00[3].lgdcep
                              ,a_cts70m00[3].lgdcepcmp
                              ,a_cts70m00[3].lclltt
                              ,a_cts70m00[3].lcllgt
                              ,a_cts70m00[3].dddcod
                              ,a_cts70m00[3].lcltelnum
                              ,a_cts70m00[3].lclcttnom
                              ,a_cts70m00[3].c24lclpdrcod
                              ,a_cts70m00[3].celteldddcod
                              ,a_cts70m00[3].celtelnum
                              ,a_cts70m00[3].endcmp
                              ,ws.sqlcode
                              ,a_cts70m00[3].emeviacod

       let m_subbairro[3].lclbrrnom = a_cts70m00[3].lclbrrnom

       call cts06g10_monta_brr_subbrr(a_cts70m00[3].brrnom,
                                      a_cts70m00[3].lclbrrnom)
            returning a_cts70m00[3].lclbrrnom

       let a_cts70m00[3].lgdtxt = a_cts70m00[3].lgdtip clipped, " ",
                                  a_cts70m00[3].lgdnom clipped, " ",
                                  a_cts70m00[3].lgdnum using "<<<<#"

       #-- SPR-2015-13708-Melhorias Calculo SKU
	     let l_c24endtip = 7  #- Endereco de correspondencia
       call cts70m00_informa_endereco(l_c24endtip
                                     ,hist_cts70m00.*)
	          returning ws.retflg
                     ,hist_cts70m00.*

          if ws.retflg = "N" then
             error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3
             continue input
          end if

          #- SPR 2015-13708 - Melhorias Calculo SKU
          #--- Grava enderecos de (1)Ocorrencia (2)Destino (7)Correspondencia
          let l_erro = "N"
          let l_erro = cts70m00_grava_endereco(g_documento.atdsrvnum
                                              ,g_documento.atdsrvano)

          if l_erro = "S" then
             rollback work
             let int_flag = true
             prompt "" for char promptX
             exit input
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
                                 ,l_srvpedcod

          if lr_retorno.resultado = false then
             rollback work
             let int_flag = true
             error lr_retorno.mensagem clipped
             prompt "ERRO AO ATUALIZAR O PEDIDO. AVISE INFORMATICA" for char promptX
             exit input
          end if

          let d_cts70m00.srvpedcod = l_srvpedcod
          display by name d_cts70m00.srvpedcod #- SPR-2015-03912-Atualiza Pedido

          commit work

          error "Endereco de correspondencia alterado com sucesso " sleep 2
          #---<<<  Endereco de correspondencia - PSI SPR-2014-28503

 end input

 if int_flag then
    error " Operacao cancelada!"
    initialize hist_cts70m00.* to null
 end if

return hist_cts70m00.*

end function

#--------------------------------------------------#
function cts70m00_display_assistencia(lr_parametro)
#--------------------------------------------------#

  define lr_parametro record
         c24astcod    like datmligacao.c24astcod
        ,c24astdes    like datkassunto.c24astdes
        ,c24pbmcod    like datrsrvpbm.c24pbmcod
        ,atddfttxt    like datmservico.atddfttxt
  end record

#--- PSI SPR-2014-28503 - Tirar o titulo do cabecalho (Forma Pagto)
#--- display "LAUDO - PORTO SOCORRO" to titulo

  display lr_parametro.c24astcod to c24astcod
  display lr_parametro.c24astdes to c24astdes

  display "Problema.:"          to problema
  display lr_parametro.c24pbmcod to c24pbmcod
  display lr_parametro.atddfttxt to atddfttxt

end function

#----------------------------------------------#
function cts70m00_display_colisao(lr_parametro)
#----------------------------------------------#

  define lr_parametro record
         c24astcod    like datmligacao.c24astcod
        ,c24astdes    like datkassunto.c24astdes
  end record

#--- PSI SPR-2014-28503 - Forma Pagto
#--- display "  LAUDO DE SERVICO - REMOCAO  " to titulo

  display lr_parametro.c24astcod to c24astcod
  display lr_parametro.c24astdes to c24astdes

  display "" to problema
  display "" to c24pbmcod
  display "" to atddfttxt

end function


#--------------------------------#
 function cts70m00_calckm(param)
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

  if mr_geral.psscntcod is not null then
      if ctx25g05_rota_ativa() then
        let  l_tipo_rota = ctx25g05_tipo_rota()
        call ctx25g02(a_cts70m00[1].lclltt,
                      a_cts70m00[1].lcllgt,
                      a_cts70m00[2].lclltt,
                      a_cts70m00[2].lcllgt,
                      l_tipo_rota,
                      0)

             returning l_dstqtd,
                       l_tempo,
                       l_rota_final
     else
        call cts18g00(a_cts70m00[1].lclltt,
                      a_cts70m00[1].lcllgt,
                      a_cts70m00[2].lclltt,
                      a_cts70m00[2].lcllgt)

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

#- SPR-2015-13708-Melhorias Calculo SKU
#--------------------------------------------------------------------
function cts70m00_informa_endereco(l_c24endtip, lr_hist_cts70m00)
#--------------------------------------------------------------------
 define l_c24endtip   like datmlcl.c24endtip
 define lr_hist_cts70m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define l_ind         smallint
 define l_retflg      char (01)

 if l_c24endtip = 7 then #-- c24endtip - 1 = Endereco de ocorrencia
 	  let l_ind = 3                      # 2 = Endereco de destino
 else                                  # 7 = Endereco de correspondencia
 	  let l_ind = l_c24endtip
 end if

 let a_cts70m00[l_ind].c24endtip = l_c24endtip
 let a_cts70m00[l_ind].lclbrrnom = m_subbairro[l_ind].lclbrrnom

 let m_acesso_ind = false
 call cta00m06_acesso_indexacao_aut(d_cts70m00.atdsrvorg)
      returning m_acesso_ind

 if m_acesso_ind = false then
    call cts06g03(l_c24endtip
                 ,d_cts70m00.atdsrvorg
                 ,w_cts70m00.ligcvntip
                 ,aux_today
                 ,aux_hora
                 ,a_cts70m00[l_ind].lclidttxt
                 ,a_cts70m00[l_ind].cidnom
                 ,a_cts70m00[l_ind].ufdcod
                 ,a_cts70m00[l_ind].brrnom
                 ,a_cts70m00[l_ind].lclbrrnom
                 ,a_cts70m00[l_ind].endzon
                 ,a_cts70m00[l_ind].lgdtip
                 ,a_cts70m00[l_ind].lgdnom
                 ,a_cts70m00[l_ind].lgdnum
                 ,a_cts70m00[l_ind].lgdcep
                 ,a_cts70m00[l_ind].lgdcepcmp
                 ,a_cts70m00[l_ind].lclltt
                 ,a_cts70m00[l_ind].lcllgt
                 ,a_cts70m00[l_ind].lclrefptotxt
                 ,a_cts70m00[l_ind].lclcttnom
                 ,a_cts70m00[l_ind].dddcod
                 ,a_cts70m00[l_ind].lcltelnum
                 ,a_cts70m00[l_ind].c24lclpdrcod
                 ,a_cts70m00[l_ind].ofnnumdig
                 ,a_cts70m00[l_ind].celteldddcod
                 ,a_cts70m00[l_ind].celtelnum
                 ,a_cts70m00[l_ind].endcmp
                 ,lr_hist_cts70m00.*
                 ,a_cts70m00[l_ind].emeviacod )
        returning a_cts70m00[l_ind].lclidttxt
                 ,a_cts70m00[l_ind].cidnom
                 ,a_cts70m00[l_ind].ufdcod
                 ,a_cts70m00[l_ind].brrnom
                 ,a_cts70m00[l_ind].lclbrrnom
                 ,a_cts70m00[l_ind].endzon
                 ,a_cts70m00[l_ind].lgdtip
                 ,a_cts70m00[l_ind].lgdnom
                 ,a_cts70m00[l_ind].lgdnum
                 ,a_cts70m00[l_ind].lgdcep
                 ,a_cts70m00[l_ind].lgdcepcmp
                 ,a_cts70m00[l_ind].lclltt
                 ,a_cts70m00[l_ind].lcllgt
                 ,a_cts70m00[l_ind].lclrefptotxt
                 ,a_cts70m00[l_ind].lclcttnom
                 ,a_cts70m00[l_ind].dddcod
                 ,a_cts70m00[l_ind].lcltelnum
                 ,a_cts70m00[l_ind].c24lclpdrcod
                 ,a_cts70m00[l_ind].ofnnumdig
                 ,a_cts70m00[l_ind].celteldddcod
                 ,a_cts70m00[l_ind].celtelnum
                 ,a_cts70m00[l_ind].endcmp
                 ,l_retflg
                 ,lr_hist_cts70m00.*
                 ,a_cts70m00[l_ind].emeviacod
 else
    call cts06g11(l_c24endtip
                 ,d_cts70m00.atdsrvorg
                 ,w_cts70m00.ligcvntip
                 ,aux_today
                 ,aux_hora
                 ,a_cts70m00[l_ind].lclidttxt
                 ,a_cts70m00[l_ind].cidnom
                 ,a_cts70m00[l_ind].ufdcod
                 ,a_cts70m00[l_ind].brrnom
                 ,a_cts70m00[l_ind].lclbrrnom
                 ,a_cts70m00[l_ind].endzon
                 ,a_cts70m00[l_ind].lgdtip
                 ,a_cts70m00[l_ind].lgdnom
                 ,a_cts70m00[l_ind].lgdnum
                 ,a_cts70m00[l_ind].lgdcep
                 ,a_cts70m00[l_ind].lgdcepcmp
                 ,a_cts70m00[l_ind].lclltt
                 ,a_cts70m00[l_ind].lcllgt
                 ,a_cts70m00[l_ind].lclrefptotxt
                 ,a_cts70m00[l_ind].lclcttnom
                 ,a_cts70m00[l_ind].dddcod
                 ,a_cts70m00[l_ind].lcltelnum
                 ,a_cts70m00[l_ind].c24lclpdrcod
                 ,a_cts70m00[l_ind].ofnnumdig
                 ,a_cts70m00[l_ind].celteldddcod
                 ,a_cts70m00[l_ind].celtelnum
                 ,a_cts70m00[l_ind].endcmp
                 ,lr_hist_cts70m00.*
                 ,a_cts70m00[l_ind].emeviacod )
      returning   a_cts70m00[l_ind].lclidttxt
                 ,a_cts70m00[l_ind].cidnom
                 ,a_cts70m00[l_ind].ufdcod
                 ,a_cts70m00[l_ind].brrnom
                 ,a_cts70m00[l_ind].lclbrrnom
                 ,a_cts70m00[l_ind].endzon
                 ,a_cts70m00[l_ind].lgdtip
                 ,a_cts70m00[l_ind].lgdnom
                 ,a_cts70m00[l_ind].lgdnum
                 ,a_cts70m00[l_ind].lgdcep
                 ,a_cts70m00[l_ind].lgdcepcmp
                 ,a_cts70m00[l_ind].lclltt
                 ,a_cts70m00[l_ind].lcllgt
                 ,a_cts70m00[l_ind].lclrefptotxt
                 ,a_cts70m00[l_ind].lclcttnom
                 ,a_cts70m00[l_ind].dddcod
                 ,a_cts70m00[l_ind].lcltelnum
                 ,a_cts70m00[l_ind].c24lclpdrcod
                 ,a_cts70m00[l_ind].ofnnumdig
                 ,a_cts70m00[l_ind].celteldddcod
                 ,a_cts70m00[l_ind].celtelnum
                 ,a_cts70m00[l_ind].endcmp
                 ,l_retflg
                 ,lr_hist_cts70m00.*
                 ,a_cts70m00[l_ind].emeviacod
 end if

 return l_retflg
       ,lr_hist_cts70m00.*

end function   #--- cts70m00_informa_endereco()

#- SPR-2015-13708-Melhorias Calculo SKU
#-----------------------------------------------------------------------------
function cts70m00_grava_endereco(lr_param)
#-----------------------------------------------------------------------------
   define lr_param       record
          atdsrvnum      like datmservico.atdsrvnum
         ,atdsrvano      like datmservico.atdsrvano
   end record

 define l_sqlcode       integer
 define l_erro          char(1)
 define l_arr_aux       smallint
 define l_ind           smallint

 let l_ind = 0
 let l_erro = "N"

 #------------------------------------------------------------------------------
 # Grava enderecos de (1) ocorrencia  / (2) destino / (3) correspondencia
 #------------------------------------------------------------------------------
   let l_ind = 3

   for arr_aux = 1 to l_ind
      if a_cts70m00[arr_aux].c24endtip is null or
      	(a_cts70m00[arr_aux].c24endtip <> 1 and
      	 a_cts70m00[arr_aux].c24endtip <> 2 and
      	 a_cts70m00[arr_aux].c24endtip <> 7) then
         continue for
      end if

      if  a_cts70m00[arr_aux].operacao is null  then
          let a_cts70m00[arr_aux].operacao = "I"
      end if

      if g_documento.c24astcod = "PSP" and
         m_multiplo = 'S'              then
         exit for
      end if

      select 1
       from datmlcl
      where atdsrvano = lr_param.atdsrvano
        and atdsrvnum = lr_param.atdsrvnum
        and c24endtip = a_cts70m00[arr_aux].c24endtip

      whenever error stop
      if sqlca.sqlcode = 0  then
         let a_cts70m00[arr_aux].operacao = "M"
      else
         if sqlca.sqlcode = 100 then
            let a_cts70m00[arr_aux].operacao = "I"
         else
            error " Erro (", sqlca.sqlcode using "<<<<<&", ") na leitura do local"
                 ," - Tipo Endereco = ", a_cts70m00[arr_aux].c24endtip
                 ,". AVISE A INFORMATICA!" sleep 5
            let l_erro = "S"
            exit for
         end if
      end if

      let a_cts70m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

      let l_sqlcode = cts06g07_local(a_cts70m00[arr_aux].operacao
                                    ,lr_param.atdsrvnum
                                    ,lr_param.atdsrvano
                                    ,a_cts70m00[arr_aux].c24endtip
                                    ,a_cts70m00[arr_aux].lclidttxt
                                    ,a_cts70m00[arr_aux].lgdtip
                                    ,a_cts70m00[arr_aux].lgdnom
                                    ,a_cts70m00[arr_aux].lgdnum
                                    ,a_cts70m00[arr_aux].lclbrrnom
                                    ,a_cts70m00[arr_aux].brrnom
                                    ,a_cts70m00[arr_aux].cidnom
                                    ,a_cts70m00[arr_aux].ufdcod
                                    ,a_cts70m00[arr_aux].lclrefptotxt
                                    ,a_cts70m00[arr_aux].endzon
                                    ,a_cts70m00[arr_aux].lgdcep
                                    ,a_cts70m00[arr_aux].lgdcepcmp
                                    ,a_cts70m00[arr_aux].lclltt
                                    ,a_cts70m00[arr_aux].lcllgt
                                    ,a_cts70m00[arr_aux].dddcod
                                    ,a_cts70m00[arr_aux].lcltelnum
                                    ,a_cts70m00[arr_aux].lclcttnom
                                    ,a_cts70m00[arr_aux].c24lclpdrcod
                                    ,a_cts70m00[arr_aux].ofnnumdig
                                    ,a_cts70m00[arr_aux].emeviacod
                                    ,a_cts70m00[arr_aux].celteldddcod
                                    ,a_cts70m00[arr_aux].celtelnum
                                    ,a_cts70m00[arr_aux].endcmp) # Amilton

      if l_sqlcode is null  or
         l_sqlcode <> 0     then
         let l_erro = "S"
         if arr_aux = 1  then
            error " Erro (", l_sqlcode, ") na gravacao do",
                  " local de ocorrencia. AVISE A INFORMATICA!" sleep 5
            let l_erro = "S"
            exit for
         else
         	  if arr_aux = 2  then
               error " Erro (", l_sqlcode, ") na gravacao do",
                     " local de destino. AVISE A INFORMATICA!" sleep 5
               let l_erro = "S"
               exit for
            else   #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
               error " Erro (", l_sqlcode, ") na gravacao do",
                     " local de correspondencia. AVISE A INFORMATICA!" sleep 5
               let l_erro = "S"
               exit for
            end if
         end if
      end if
   end for

 return l_erro

end function   #--- cts70m00_grava_endereco()

#--------------------------------------------------------------------
function cts70m00_grava_dados(ws,hist_cts70m00)
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


 define hist_cts70m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define l_dadosPagamento smallint
 define l_cartaoCripto   dec(4,0)
 define l_count          dec(1,0)

 define lr_pagamento record
 	orgnum		like datmpgtinf.orgnum,
 	prpnum		like datmpgtinf.prpnum,
 	pgtfrmcod	like datmpgtinf.pgtfrmcod,
 	pgtfrmdes	like datkpgtfrm.pgtfrmdes
 end record

 ###PSI-2012-22101
 define lr_frm_pagamento record
        crtnum                like datmcrdcrtinf.crtnum,
        crtnumPainel          char(4)
 end record

 define lr_cartao record
 	clinom		like datmcrdcrtinf.clinom,
 	crtnum		like datmcrdcrtinf.crtnum,
 	bndcod		like datmcrdcrtinf.bndcod,
 	crtvlddat	like datmcrdcrtinf.crtvlddat,
 	cbrparqtd	like datmcrdcrtinf.cbrparqtd,
 	bnddes		like fcokcarbnd.carbndnom
 end record

 define la_historico   array[7] of record
         descricao     char (70)
 end record

 define lr_retcrip record
        coderro        smallint
       ,msgerro        char(10000)
       ,pcapticrpcod   like fcomcaraut.pcapticrpcod
 end record

 #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda
 define lr_numped  record
        coderro        smallint
       ,msgerro        char(80)
       ,srvpedcod      like datmsrvped.srvpedcod
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

 define l_ind          smallint
 define l_pestipcod    char(1)                   #--- SPR-2015-03912-Cadastro Clientes ---
 define l_ret          smallint
       ,l_mensagem     char(60)
       ,l_c24endtip    like datmlcl.c24endtip    #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
       ,l_erro         char(1)   #- SPR 2015-13708 - Melhorias Calculo SKU

 initialize l_erro to null       #- SPR 2015-13708 - Melhorias Calculo SKU
 initialize lr_ret.* to null
 initialize cty27g00_ret to null
 initialize lr_numped.* to null  #--- SPR-2015-11582
 initialize lr_opsfa023.* to null
 initialize lr_retorno_sku.* to null  #- SPR-2016-03565
 let l_pestipcod = null          #--- SPR-2015-03912-Cadastro de Clientes ---
 let l_ret = null
 let l_mensagem = null
 let l_dadosPagamento = true

 if mr_geral.c24astcod = 'PSP' and
      m_multiplo = "S" then
      let w_cts70m00.atdprscod = null
      let w_cts70m00.c24nomctt = null
      let w_cts70m00.socvclcod = null
      let w_cts70m00.srrcoddig = null
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
       let ws.msg = "cts70m00 - ",ws.msg
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

#--- PSI SPR-2014-28503 - GERA NUMERO DA PROPOSTA (FORMA DE PAGAMENTO)
   if m_vendaflg then
      begin work
      call cty27g00_numprp()
           returning mr_prop.*
      if mr_prop.sqlcode <> 0 then
         let ws.msg = "cts70m00(numprp) - ", mr_prop.msg clipped
         call ctx13g00(mr_prop.sqlcode,"DATKGERAL(numprp)",mr_prop.msg)
         rollback work
         prompt "" for ws.promptX
         let lr_ret.retorno = mr_prop.sqlcode
         let lr_ret.mensagem = mr_prop.msg
         return lr_ret.*
      end if
      commit work
   else
      initialize mr_prop.* to null
   end if
#---

   #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda
   begin work
   call opsfa015_geranumped()
        returning lr_numped.coderro
                 ,lr_numped.msgerro
                 ,lr_numped.srvpedcod

   if lr_numped.coderro = false then
      let ws.msg = "cts70m00(geranumped) - ", lr_numped.msgerro clipped
      call ctx13g00("","DATKGERAL(numped)",lr_numped.msgerro)
      rollback work
      prompt "" for ws.promptX
      let lr_ret.retorno = lr_numped.coderro
      let lr_ret.mensagem = lr_numped.msgerro
      return lr_ret.*
   end if

   commit work

   #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda

 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( mr_geral.lignum         ,
                           w_cts70m00.data         ,
                           w_cts70m00.hora         ,
                           mr_geral.c24soltipcod   ,
                           mr_geral.solnom         ,
                           mr_geral.c24astcod      ,
                           w_cts70m00.funmat       ,
                           mr_geral.ligcvntip      ,
                           g_c24paxnum             ,
                           aux_atdsrvnum           ,
                           aux_atdsrvano           ,
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

   call cts10g02_grava_servico( aux_atdsrvnum
                               ,aux_atdsrvano
                               ,mr_geral.soltip          # atdsoltip
                               ,mr_geral.solnom          # c24solnom
                               ,w_cts70m00.vclcorcod
                               ,w_cts70m00.funmat
                               ,d_cts70m00.atdlibflg
                               ,d_cts70m00.atdlibhor
                               ,d_cts70m00.atdlibdat
                               ,w_cts70m00.data          # atddat
                               ,w_cts70m00.hora          # atdhor
                               ,""                       # atdlclflg
                               ,w_cts70m00.atdhorpvt
                               ,w_cts70m00.atddatprg
                               ,w_cts70m00.atdhorprg
                               ,ws.atdtip                # ATDTIP
                               ,""                       # atdmotnom
                               ,""                       # atdvclsgl
                               ,w_cts70m00.atdprscod
                               ,""                       # atdcstvlr
                               ,w_cts70m00.atdfnlflg
                               ,w_cts70m00.atdfnlhor
                               ,""  #---   SPR-2015-11582 - Retirada de campo da tela
                               ,d_cts70m00.atddfttxt
                               ,""                       # atddoctxt
                               ,w_cts70m00.c24opemat
                               ,d_cts70m00.nom
                               ,d_cts70m00.vcldes
                               ,d_cts70m00.vclanomdl
                               ,d_cts70m00.vcllicnum
                               ,d_cts70m00.corsus
                               ,d_cts70m00.cornom
                               ,w_cts70m00.cnldat
                               ,""                       # pgtdat
                               ,w_cts70m00.c24nomctt
                               ,w_cts70m00.atdpvtretflg
                               ,w_cts70m00.atdvcltip
                               ,d_cts70m00.asitipcod
                               ,""                       # socvclcod
                               ,d_cts70m00.vclcoddig
                               ,d_cts70m00.srvprlflg
                               ,""                       # srrcoddig
                               ,d_cts70m00.atdprinvlcod
                               ,d_cts70m00.atdsrvorg    ) # ATDSRVORG
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

   call opsfa006_geracao(aux_atdsrvnum
                        ,aux_atdsrvano
                        ,mr_prop.prpnum
                        ,lr_numped.srvpedcod
                        ,d_cts70m00.nom
                        ,d_cts70m00.nscdat
                        ,""           #---  Email
                        ,false        #---  Atualiza Data Fechamento
                        ,m_vendaflg   #---  Cria Venda
                        ,"1")         #---  Online - SPR-2015-22413
        returning lr_ret.retorno
                 ,lr_ret.mensagem

   if lr_ret.retorno = false then
      rollback work
      error "ERRO NA GERACAO DA VENDA - ",lr_ret.mensagem clipped
      prompt "" for char ws.promptX
      let ws.retorno = false
      exit while
   end if

   let d_cts70m00.srvpedcod = lr_numped.srvpedcod
   display by name d_cts70m00.srvpedcod
   #--- SPR-2015-03912-Inclui Pedido ---

#--- SPR-2015-11582-SMS Pesquisa de Satisfação

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
                                      ,c24astcod)
                               values (g_documento.lignum
                                      ,ws_mtvcaps
                                      ,mr_geral.c24astcod,
                                      0)
         whenever error stop
         if ws.sqlcode  <>  0  then
            error " Erro (", sqlca.sqlcode, ") na gravacao do",
                  " Motivo de Recusa do CAPS ou Car. AVISE A INFORMATICA!"
            rollback work
            prompt "" for char ws.promptX
            let ws.retorno = false

            exit while
         end if

      end if
   end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
#- if d_cts70m00.prslocflg = "S" then  #- SPR-2015-15533-Fechamento Srv GPS
      update datmservico set prslocflg = d_cts70m00.prslocflg,
                             socvclcod = w_cts70m00.socvclcod,
                             srrcoddig = w_cts70m00.srrcoddig
       where datmservico.atdsrvnum = aux_atdsrvnum
         and datmservico.atdsrvano = aux_atdsrvano
#- end if

 #------------------------------------------------------------------------------
 # Grava problemas do servico
 #------------------------------------------------------------------------------
{  SPR-2015-06510 - RETIRADA DA CONDICAO PARA GRAVACAO DO PROBLEMA...
   if d_cts70m00.atdsrvorg = 1 then  # Laudo de Assistência
}
      call ctx09g02_inclui(aux_atdsrvnum,
                           aux_atdsrvano,
                           1, # Org. informacao 1-Segurado 2-Pst
                           d_cts70m00.c24pbmcod,
                           d_cts70m00.atddfttxt,
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
###   end if
 #------------------------------------------------------------------------------
 # GUINCHO PEQUENO e possui CAMBIO HIDRAMATICO, grava no historico do servico
 #------------------------------------------------------------------------------
   if  w_cts70m00.atdvcltip = 2  then
       if  ws.vclatmflg = 1  then

           call ctd07g01_ins_datmservhist(aux_atdsrvnum,
                                          aux_atdsrvano,
                                          g_issk.funmat,
                                          "VEICULO COM CAMBIO HIDRAMATICO/AUTOMATICO",
                                          w_cts70m00.data,
                                          w_cts70m00.hora,
                                          g_issk.empcod,
                                          g_issk.usrtip)
                returning l_ret,
                          l_mensagem

           if  l_ret  <>  1  then
               error l_mensagem, " - cts70m00 - AVISE A INFORMATICA!"
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
                                             ,d_cts70m00.rmcacpflg
                                             ,w_cts70m00.vclcamtip
                                             ,w_cts70m00.vclcrcdsc
                                             ,w_cts70m00.vclcrgflg
                                             ,w_cts70m00.vclcrgpso
                                             ,""   #---  d_cts70m00.sindat   #---   SPR-2015-11582 - Retirada de campo da tela
                                             ,""   #---  d_cts70m00.sinhor
                                             ,""   #---  d_cts70m00.sinvitflg
                                             ,""   #---  d_cts70m00.bocflg
                                             ,""   #---  d_cts70m00.bocnum
                                             ,""   #---  d_cts70m00.bocemi
                                             ,d_cts70m00.vcllibflg)
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


 #------------------------------------------------------------------------------
 # Grava enderecos de (1) ocorrencia  / (2) destino / (3) correspondencia
 #------------------------------------------------------------------------------

   #- SPR 2015-13708 - Melhorias Calculo SKU
   #--- Grava enderecos (1)Ocorrencia/(2)Destino/(7)Correspondencia
   let l_erro = "N"
   let l_erro = cts70m00_grava_endereco(aux_atdsrvnum
                                       ,aux_atdsrvano)

   if l_erro = "S" then
      rollback work
      prompt "" for char ws.promptX
      let ws.retorno = false
      exit while
   end if

 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if mr_geral.c24astcod = 'PSP' and
      m_multiplo = "S" then
      let w_cts70m00.atdprscod = null
      let w_cts70m00.c24nomctt = null
      let w_cts70m00.socvclcod = null
      let w_cts70m00.srrcoddig = null
   end if

   if  w_cts70m00.atdetpcod is null  then
       if  d_cts70m00.atdlibflg = "S"  then
           let w_cts70m00.atdetpcod = 1
           let ws.etpfunmat = w_cts70m00.funmat
           let ws.atdetpdat = d_cts70m00.atdlibdat
           let ws.atdetphor = d_cts70m00.atdlibhor
       else
           let w_cts70m00.atdetpcod = 2
           let ws.etpfunmat = w_cts70m00.funmat
           let ws.atdetpdat = w_cts70m00.data
           let ws.atdetphor = w_cts70m00.hora
       end if
   else
      let w_retorno = cts10g04_insere_etapa( aux_atdsrvnum    ,
                                             aux_atdsrvano    ,
                                             1,
                                             " ",
                                             " ",
                                             " ",
                                             w_cts70m00.srrcoddig )

       if  w_retorno <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts70m00.cnldat
       let ws.atdetphor = w_cts70m00.atdfnlhor
       let ws.etpfunmat = w_cts70m00.c24opemat
   end if

   let w_retorno = cts10g04_insere_etapa( aux_atdsrvnum,
                                          aux_atdsrvano,
                                          w_cts70m00.atdetpcod,
                                          w_cts70m00.atdprscod,
                                          w_cts70m00.c24nomctt,
                                          w_cts70m00.socvclcod,
                                          w_cts70m00.srrcoddig )

   if w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   commit work    #=> SPR-2014-28503 - CORRECAO: ATUALIZACOES FORA DA TRANSACAO

   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)

 #---> Data de Fechamento - PSI SPR-2015-03912  ---
 call opsfa006_atualdtfecha(aux_atdsrvnum
                           ,aux_atdsrvano )
      returning lr_ret.retorno
               ,lr_ret.mensagem

 if lr_ret.retorno = false then
      error "ERRO AO ATUALIZAR DATA ATENDIMENTO SERVICO. ",lr_ret.mensagem clipped
      prompt "" for ws.promptX
      return false
 end if
 #---> Data de Fechamento - PSI SPR-2015-03912 ---

 #---> Envio de Email  ---
 if g_documento.acao = "INC" then
    call opsfa023_emailposvenda(aux_atdsrvnum
                               ,aux_atdsrvano)
          returning lr_opsfa023.retorno,
                    lr_opsfa023.mensagem

    if lr_opsfa023.retorno = false then
       error lr_opsfa023.mensagem clipped
    end if
 end if
 #---> Envio de Email  ---
 
 #- SPR-2016-01943
 #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
 call opsfa001_conskupbr(d_cts70m00.c24pbmcod
                        ,today)
      returning lr_retorno_sku.catcod
               ,lr_retorno_sku.pgtfrmcod
               ,lr_retorno_sku.srvprsflg
               ,lr_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
               ,lr_retorno_sku.msg_erro

 if lr_retorno_sku.srvprsflg = "S" or  
    lr_retorno_sku.srvprsflg = "s" then
    call opsfa023_posvnd_prest(aux_atdsrvnum
                               ,aux_atdsrvano)
          returning lr_opsfa023.retorno,
                    lr_opsfa023.mensagem

    if lr_opsfa023.retorno = false then
       error lr_opsfa023.mensagem clipped
    end if	
 end if
 #- SPR-2016-01943
 		
 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   if w_hist.hist1 is not null then   # registra o motivo da escolha oficina
      let ws.histerr = cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                                           w_cts70m00.data  , w_cts70m00.hora,
                                           w_cts70m00.funmat, w_hist.* )
   end if
   let ws.histerr = cts10g02_historico( aux_atdsrvnum    ,
                                        aux_atdsrvano    ,
                                        w_cts70m00.data  ,
                                        w_cts70m00.hora  ,
                                        w_cts70m00.funmat,
                                        hist_cts70m00.*   )
   # INICIO PSI-2013-07115
   #------------------------------------------------------------------------------
   # Grava sugestao de cadastro
   #------------------------------------------------------------------------------

   if mr_grava_sugest  = 'S' then
      call ctc68m00_grava_sugest(aux_atdsrvnum,
                                 aux_atdsrvano,
                                 d_cts70m00.asitipcod,
                                 g_issk.usrtip,
                                 g_issk.empcod,
                                 g_issk.funmat)
       let mr_grava_sugest = 'N'
   end if

   #FIM PSI-2013-07115

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico - Informações pagamento
 #------------------------------------------------------------------------------


     #--------------------------------------------------------------------------
     # Grava HISTORICO do servico - Informações pagamento
     #--------------------------------------------------------------------------
     let lr_pagamento.orgnum = 29              #--- SPR-2014-28503 - MELHORIA
     let lr_pagamento.prpnum = mr_prop.prpnum  #--- SPR-2014-28503 - MELHORIA

     whenever error continue

     open ccts70m00007 using mr_prop.prpnum  #--- PSI SPR-2014-28503 - MELHORIA

     fetch ccts70m00007 into lr_pagamento.pgtfrmcod

     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           error 'Erro SELECT ccts70m00007: ' ,sqlca.sqlcode,' / ',
                                               sqlca.sqlerrd[2] sleep 2
        end if
        let l_dadosPagamento= false
     end if

  if l_dadosPagamento = true then
	  open ccts70m00009 using lr_pagamento.pgtfrmcod

	  whenever error continue
	  fetch ccts70m00009 into lr_pagamento.pgtfrmdes

	  whenever error stop
	  if sqlca.sqlcode <> 0 then
	     error 'Erro SELECT ccts70m00009: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	     let l_dadosPagamento= false
	  end if

  end if

  if lr_pagamento.pgtfrmcod = 1 and
     l_dadosPagamento = true then
	  open ccts70m00008 using lr_pagamento.orgnum,
	  			  lr_pagamento.prpnum,
                                  lr_pagamento.orgnum,
	                          lr_pagamento.prpnum
	  whenever error continue
	  fetch ccts70m00008 into lr_cartao.clinom,
	  			  lr_cartao.crtnum,
	  			  lr_cartao.bndcod,
	  			  lr_cartao.crtvlddat,
	  			  lr_cartao.cbrparqtd
	  whenever error stop
	  if sqlca.sqlcode <> 0 then
	     error 'Erro SELECT ccts70m00008: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
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
		  open ccts70m00010 using lr_cartao.bndcod

		  whenever error continue
		  fetch ccts70m00010 into lr_cartao.bnddes

		  whenever error stop
		  if sqlca.sqlcode <> 0 then
		     error 'Erro SELECT ccts70m00010: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
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
  	    call ctd07g01_ins_datmservhist(aux_atdsrvnum, #g_documento.atdsrvnum,
                                           aux_atdsrvano, #g_documento.atdsrvano,
                                           g_issk.funmat,
                                           la_historico[l_ind].descricao,
                                           w_cts70m00.data,
                                           w_cts70m00.hora,
                                           g_issk.empcod,
                                           g_issk.usrtip)
            returning l_ret,
                      l_mensagem

            if  l_ret  <>  1  then
                error l_mensagem, " - cts70m00 - AVISE A INFORMATICA!" sleep 2
#---            rollback work
                let ws.retorno = false
                exit for
            end if
  	end for

  end if

   #-----------------------------------------------
   # Aciona Servico automaticamente
   #-----------------------------------------------
 # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  if cts34g00_acion_auto (d_cts70m00.atdsrvorg,
                          a_cts70m00[1].cidnom,
                          a_cts70m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO


     if not cts40g12_regras_aciona_auto (d_cts70m00.atdsrvorg
                                        ,mr_geral.c24astcod
                                        ,d_cts70m00.asitipcod
                                        ,a_cts70m00[1].lclltt
                                        ,a_cts70m00[1].lcllgt
                                        ,d_cts70m00.prslocflg
                                        ,"N"  #--- SPR-2015-11582 - Retirada de campo da tela (d_cts70m00.frmflg)
                                        ,aux_atdsrvnum
                                        ,aux_atdsrvano
                                        ," "
                                        ,d_cts70m00.vclcoddig
                                        ,d_cts70m00.camflg) then
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

#--- PSI SPR-2015-10068 - Consistir nome composto
#--------------------------------------------------------------------
function cts70m00_consiste_nome()
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
 let l_tam = length(d_cts70m00.nom)

 for l_ind = 1 to l_tam
    if d_cts70m00.nom[l_ind,l_ind] = " " or
       d_cts70m00.nom[l_ind,l_ind] is null then
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

end function #--- cts70m00_consiste_nome()

#--------------------------------------------------------------------
function cts70m00_desbloqueia_servico(lr_param)
#--------------------------------------------------------------------

define lr_param record
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano
end record


   initialize mr_retorno.* to null

   if m_prep_sql is null or
      m_prep_sql = false then
      call cts70m00_prepare()
   end if

   whenever error continue
      execute pcts70m00004 using lr_param.atdsrvnum,
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

#--------------------------------------------------------------------
function cts70m00_assunto_assistencia(lr_param)
#--------------------------------------------------------------------

define lr_param record
    c24astcod like datkassunto.c24astcod
end record

define lr_retorno record
   qtd    integer                 ,
   cponom like datkdominio.cponom
end record


 initialize lr_retorno.* to null

 let lr_retorno.qtd = 0
 let lr_retorno.cponom = "assunto_pss_ass"

 if m_prep_sql is null or
    m_prep_sql = false then
    call cts70m00_prepare()
 end if

 whenever error continue
    open  ccts70m00005 using lr_retorno.cponom,
                             lr_param.c24astcod
    fetch ccts70m00005 into  lr_retorno.qtd
 whenever error stop

 if lr_retorno.qtd = 0 then
    return false
 else
    return true
 end if

end function

#--------------------------------------------------------------------
function cts70m00_assunto_transferencia(lr_param)
#--------------------------------------------------------------------

define lr_param record
    c24astcod like datkassunto.c24astcod
end record

define lr_retorno record
   qtd    integer                 ,
   cponom like datkdominio.cponom
end record


 initialize lr_retorno.* to null

 let lr_retorno.qtd = 0
 let lr_retorno.cponom = "assunto_pss_tra"

 if m_prep_sql is null or
    m_prep_sql = false then
    call cts70m00_prepare()
 end if

 whenever error continue
    open  ccts70m00005 using lr_retorno.cponom,
                             lr_param.c24astcod
    fetch ccts70m00005 into  lr_retorno.qtd
 whenever error stop

 if lr_retorno.qtd = 0 then
    return false
 else
    return true
 end if

end function

#--------------------------------------------------------#
 function cts70m00_bkp_info_dest(l_tipo, hist_cts70m00)
#--------------------------------------------------------#
  define hist_cts70m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts70m00_bkp      to null
     initialize m_hist_cts70m00_bkp to null

     let a_cts70m00_bkp[1].lclidttxt    = a_cts70m00[2].lclidttxt
     let a_cts70m00_bkp[1].cidnom       = a_cts70m00[2].cidnom
     let a_cts70m00_bkp[1].ufdcod       = a_cts70m00[2].ufdcod
     let a_cts70m00_bkp[1].brrnom       = a_cts70m00[2].brrnom
     let a_cts70m00_bkp[1].lclbrrnom    = a_cts70m00[2].lclbrrnom
     let a_cts70m00_bkp[1].endzon       = a_cts70m00[2].endzon
     let a_cts70m00_bkp[1].lgdtip       = a_cts70m00[2].lgdtip
     let a_cts70m00_bkp[1].lgdnom       = a_cts70m00[2].lgdnom
     let a_cts70m00_bkp[1].lgdnum       = a_cts70m00[2].lgdnum
     let a_cts70m00_bkp[1].lgdcep       = a_cts70m00[2].lgdcep
     let a_cts70m00_bkp[1].lgdcepcmp    = a_cts70m00[2].lgdcepcmp
     let a_cts70m00_bkp[1].lclltt       = a_cts70m00[2].lclltt
     let a_cts70m00_bkp[1].lcllgt       = a_cts70m00[2].lcllgt
     let a_cts70m00_bkp[1].lclrefptotxt = a_cts70m00[2].lclrefptotxt
     let a_cts70m00_bkp[1].lclcttnom    = a_cts70m00[2].lclcttnom
     let a_cts70m00_bkp[1].dddcod       = a_cts70m00[2].dddcod
     let a_cts70m00_bkp[1].lcltelnum    = a_cts70m00[2].lcltelnum
     let a_cts70m00_bkp[1].c24lclpdrcod = a_cts70m00[2].c24lclpdrcod
     let a_cts70m00_bkp[1].ofnnumdig    = a_cts70m00[2].ofnnumdig
     let a_cts70m00_bkp[1].celteldddcod = a_cts70m00[2].celteldddcod
     let a_cts70m00_bkp[1].celtelnum    = a_cts70m00[2].celtelnum
     let a_cts70m00_bkp[1].endcmp       = a_cts70m00[2].endcmp
     let m_hist_cts70m00_bkp.hist1      = hist_cts70m00.hist1
     let m_hist_cts70m00_bkp.hist2      = hist_cts70m00.hist2
     let m_hist_cts70m00_bkp.hist3      = hist_cts70m00.hist3
     let m_hist_cts70m00_bkp.hist4      = hist_cts70m00.hist4
     let m_hist_cts70m00_bkp.hist5      = hist_cts70m00.hist5
     let a_cts70m00_bkp[1].emeviacod    = a_cts70m00[2].emeviacod

     return hist_cts70m00.*

  else

     let a_cts70m00[2].lclidttxt    = a_cts70m00_bkp[1].lclidttxt
     let a_cts70m00[2].cidnom       = a_cts70m00_bkp[1].cidnom
     let a_cts70m00[2].ufdcod       = a_cts70m00_bkp[1].ufdcod
     let a_cts70m00[2].brrnom       = a_cts70m00_bkp[1].brrnom
     let a_cts70m00[2].lclbrrnom    = a_cts70m00_bkp[1].lclbrrnom
     let a_cts70m00[2].endzon       = a_cts70m00_bkp[1].endzon
     let a_cts70m00[2].lgdtip       = a_cts70m00_bkp[1].lgdtip
     let a_cts70m00[2].lgdnom       = a_cts70m00_bkp[1].lgdnom
     let a_cts70m00[2].lgdnum       = a_cts70m00_bkp[1].lgdnum
     let a_cts70m00[2].lgdcep       = a_cts70m00_bkp[1].lgdcep
     let a_cts70m00[2].lgdcepcmp    = a_cts70m00_bkp[1].lgdcepcmp
     let a_cts70m00[2].lclltt       = a_cts70m00_bkp[1].lclltt
     let a_cts70m00[2].lcllgt       = a_cts70m00_bkp[1].lcllgt
     let a_cts70m00[2].lclrefptotxt = a_cts70m00_bkp[1].lclrefptotxt
     let a_cts70m00[2].lclcttnom    = a_cts70m00_bkp[1].lclcttnom
     let a_cts70m00[2].dddcod       = a_cts70m00_bkp[1].dddcod
     let a_cts70m00[2].lcltelnum    = a_cts70m00_bkp[1].lcltelnum
     let a_cts70m00[2].c24lclpdrcod = a_cts70m00_bkp[1].c24lclpdrcod
     let a_cts70m00[2].ofnnumdig    = a_cts70m00_bkp[1].ofnnumdig
     let a_cts70m00[2].celteldddcod = a_cts70m00_bkp[1].celteldddcod
     let a_cts70m00[2].celtelnum    = a_cts70m00_bkp[1].celtelnum
     let a_cts70m00[2].endcmp       = a_cts70m00_bkp[1].endcmp
     let hist_cts70m00.hist1        = m_hist_cts70m00_bkp.hist1
     let hist_cts70m00.hist2        = m_hist_cts70m00_bkp.hist2
     let hist_cts70m00.hist3        = m_hist_cts70m00_bkp.hist3
     let hist_cts70m00.hist4        = m_hist_cts70m00_bkp.hist4
     let hist_cts70m00.hist5        = m_hist_cts70m00_bkp.hist5
     let a_cts70m00[2].emeviacod    = a_cts70m00_bkp[1].emeviacod

     return hist_cts70m00.*

  end if

end function

#-----------------------------------------#
 function cts70m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open ccts70m00006 using g_documento.atdsrvnum
                         ,g_documento.atdsrvano
                         ,g_documento.atdsrvnum
                         ,g_documento.atdsrvano

  whenever error continue
  fetch ccts70m00006 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT ccts70m00006: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts70m00() / C24 / cts70m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts70m00_verifica_op_ativa()
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
 function cts70m00_grava_historico()
#-----------------------------------------#
  define la_cts70m00       array[12] of record
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

  initialize la_cts70m00  to null
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

  let la_cts70m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts70m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts70m00[03].descricao = "."
  let la_cts70m00[04].descricao = "DE:"
  let la_cts70m00[05].descricao = "CEP: ", a_cts70m00_bkp[1].lgdcep clipped," - ",a_cts70m00_bkp[1].lgdcepcmp using "<<<<<" clipped,
                                  " Cidade: ",a_cts70m00_bkp[1].cidnom clipped," UF: ",a_cts70m00_bkp[1].ufdcod clipped
  let la_cts70m00[06].descricao = "Logradouro: ",a_cts70m00_bkp[1].lgdtip clipped," ",a_cts70m00_bkp[1].lgdnom clipped," "
                                                ,a_cts70m00_bkp[1].lgdnum clipped," ",a_cts70m00_bkp[1].brrnom
  let la_cts70m00[07].descricao = "."
  let la_cts70m00[08].descricao = "PARA:"
  let la_cts70m00[09].descricao = "CEP: ", a_cts70m00[2].lgdcep clipped," - ", a_cts70m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts70m00[2].cidnom clipped," UF: ",a_cts70m00[2].ufdcod  clipped
  let la_cts70m00[10].descricao = "Logradouro: ",a_cts70m00[2].lgdtip clipped," ",a_cts70m00[2].lgdnom clipped," "
                                                ,a_cts70m00[2].lgdnum clipped," ",a_cts70m00[2].brrnom
  let la_cts70m00[11].descricao = "."
  let la_cts70m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts70m00[l_ind].descricao
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
  let lr_de.lgdcep    = a_cts70m00_bkp[1].lgdcep clipped,"-",a_cts70m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts70m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts70m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts70m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts70m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts70m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts70m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts70m00[2].lgdcep clipped,"-", a_cts70m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts70m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts70m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts70m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts70m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts70m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts70m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function

#--- SPR-2014-28503 - Verifica se há venda de servico associado

