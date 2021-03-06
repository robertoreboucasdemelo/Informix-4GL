#############################################################################
# Nome do Modulo: CTS02M00                                            Pedro #
#                                                                   Marcelo #
# Laudo - Remocoes                                                 Dez/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta- #
#                                       bela DATMSERVICO.                   #
#---------------------------------------------------------------------------#
# 20/10/1998  PSI 6955-8   Gilberto     Retirar aviso que informa sobre     #
#                                       informacoes complementares no       #
#                                       historico (funcao CTS11G00).        #
#---------------------------------------------------------------------------#
# 17/11/1998  PSI 6467-0   Gilberto     Gravar codigo do veiculo atendido.  #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Gravar dados referentes a digitacao #
#                                       via formulario.                     #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 18/12/1998  PSI 6478-5   Gilberto     Inclusao da chamada da funcao de    #
#                                       cabecalho (CTS05G02) para atendi-   #
#                                       mento Porto Card VISA.              #
#---------------------------------------------------------------------------#
# 19/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 16/06/1999  PSI 8111-6   Wagner       Incluir tecla funcao (F9)Copia laudo#
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8533-2   Wagner       Incluir acesso ao modulo cts14g00   #
#                                       para mensagens Cidade e UF.         #
#---------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 27/08/1999               Gilberto     Ampliacao da faixa final (limite)   #
#                                       de 449999 para 469999.              #
#---------------------------------------------------------------------------#
# 09/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03#
#                                       e padroniza gravacao do historico.  #
#---------------------------------------------------------------------------#
# 23/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do   #
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
# 28/01/2000  PSI 10203-2  Wagner       Gravar atdvcltip = 3 para solicit.  #
#                                       de guincho para caminhao.           #
#---------------------------------------------------------------------------#
# 07/02/2000  PSI 10206-7  Wagner       Manutencao no campo nivel prioridade#
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO      #
#                                       via funcao                          #
#                                       Exclusao da coluna atdtip           #
#                                       Verificacao na vistoria previa exis-#
#                                       tencia do acessorio 2518            #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 31/08/2000  PSI 11459-6  Wagner       Incluir acionamento do servico apos #
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
# 16/02/2001  PSI 11254-2  Ruiz         Consulta ao Condutor do veiculo     #
#---------------------------------------------------------------------------#
# 04/03/2001  PSI 12768-0  Wagner       Incluir nr.dias parametro cts16g00  #
#---------------------------------------------------------------------------#
# 10/09/2001  PSI 13893-2  Wagner       Laudo emergencial - Colocar campo   #
#                                       formulario s/n como primeiro.       #
#---------------------------------------------------------------------------#
# 27/11/2001  PSI 14177-1  Ruiz         Altera a chamada da funcao cts11m02 #
#                                       para o ramo transporte(78).         #
#---------------------------------------------------------------------------#
# 03/01/2002  CORREIO      Wagner       Incluir dptsgl psocor na pesquisa.  #
#---------------------------------------------------------------------------#
# 26/03/2002  PSI 15426-1  Ruiz         Alerta para veiculo blindado.       #
#---------------------------------------------------------------------------#
# 03/07/2002  PSI 15590-0  Wagner       Inclusao msg convenio/assuntos.     #
#---------------------------------------------------------------------------#
# 25/07/2002  PSI 15655-8  Ruiz         Alerta qdo oficina estiver cortada. #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 06/03/2003  Helio        Ruiz   PSI.170275     Buscar campo asiofndigflg  #
#                                 OSF.19968                                 #
#############################################################################
#                                                                           #
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem      Alteracao                          #
# ----------  -------------- --------- -----------------------------------  #
# 18/09/2003  Meta,Bruno     PSI175552 Inibir chamada da funcao ctx17g00.   #
#                            OSF26077                                       #
#                                                                           #
# 19/11/2003  Meta,Ivone     PSI179345 controle da abertura da janela de    #
#                            OSF28851                       alerta          #
#                                                                           #
# 08/04/2005  James, Meta    PSI191671 inicializar o atdlibflg e passar     #
#                                      para o proximo campo                 #
#                                                                           #
# 18/05/2005  Solda, Meta    PSI191108 implementar codigo da via(emeviacod) #
#                                      g_documento.lclocodesres             #
#                                                                           #
# 06/06/2005  Julianna,Meta  PSI192007 Inicializacao da variavel            #
#                                                                           #
# 02/08/2005  JUNIOR  ,Meta  PSI192015 Alteracoes diversas                  #
#                                                                           #
# 24/08/2005  James, Meta    PSI192015 Inibir a chamada das funcoes ctc61m02#
#---------------------------------------------------------------------------#
# 04/05/2006  Priscila       PSI198714 Gerar laudo de apoio quando local/   #
#                                      cond veiculo e subsolo ou chave cod  #
#---------------------------------------------------------------------------#
# 17/05/2006  Priscila       PSI198714 Inclusao da opcao F4 para visualizar #
#                                      laudo de apoio                       #
#---------------------------------------------------------------------------#
# 29/08/2006  Priscila       PSI202363 Acerto passagem parametros ctc59m02  #
# 21/09/2006  Ligia Mattge   PSI202720 Passando ult.campo nulo no cts16g00  #
# 11/12/2006  Ligia Mattge   CT6121350 Chamada do cts40g12 apos os updates  #
#---------------------------------------------------------------------------#
# 18/12/2006  Cristiane Silva CT471704 Envio de FAX para oficina credencia- #
#				       ada e e-mail ao Porto Socorro no                         #
#				       momento do acionamento do prestador.                     #
# 28/12/2006  Ligia Mattge             Implementacao de m_c24lclpdrcod e    #
#                                      chamada de cts02m00_valida_indexacao #
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 14/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 22/05/2007 Ligia Mattge  PSI208892 Charmar cts46g00                       #
#---------------------------------------------------------------------------#
# 07/04/2008 Luiz Araujo   PSI216445 Inclusao de envio de email com         #
#                                    informacoes da oficina escolhida       #
#---------------------------------------------------------------------------#
#                                                                           #
# 07/07/2008 Andre Oliveira        Altera��o da chamada da fun��o           #
#                                  cts00m02_regulador para                  #
#                                  ctc59m03_regulador                       #
#---------------------------------------------------------------------------#
#                                                                           #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#
# 13/08/2009 Sergio Burini     PSI 244236 Inclus�o do Sub-Dairro            #
#---------------------------------------------------------------------------#
# 04/01/2009 Amilton, Meta                Projeto sucursal smallint         #
#---------------------------------------------------------------------------#
# 05/04/2012 Ivan, BRQ  PSI-2011-22603 Projeto alteracao cadastro de destino#
#---------------------------------------------------------------------------#
# 26/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#---------------------------------------------------------------------------#
# 10/12/2013  Rodolfo   PSI-2013-      Inlcusao da nova regulacao via AW    #
#             Massini   12097PR                                             #
#---------------------------------------------------------------------------#
# 11/08/2014 Fabio, Fornax PSI2013-00440 Adequacoes para regulacao AW       #
#---------------------------------------------------------------------------#
 globals "/homedsa/projetos/geral/globals/glct.4gl"
 globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

 define m_mensagem           char(1000)
 define m_acesso_ind         smallint
 define m_atdsrgorg          like datmservico.atdsrvorg
 define m_flag               char(100)
 define m_premium            integer    
 define mr_atdsrvorg         integer   
 define m_asitipcod          integer 
 define m_atdsrvnum_premium  like datmservico.atdsrvnum       
 define m_atdsrvano_premium  like datmservico.atdsrvano       
     

 define d_cts02m00    record
    servico           char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like gcaksusep.corsus        ,
    cornom            like gcakcorr.cornom         ,
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
    refatdsrvtxt      char (12)                    ,
    refatdsrvorg      like datmservico.atdsrvorg   ,
    refatdsrvnum      like datmservico.atdsrvnum   ,
    refatdsrvano      like datmservico.atdsrvano   ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    sinvitflg         like datmservicocmp.sinvitflg,
    bocflg            like datmservicocmp.bocflg   ,
    dstflg            char (01)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    imdsrvflg         char (01)                    ,
    prsloccab         char (11)                    ,
    prslocflg         char (01)                    ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    frmflg            char (01)                    ,
    atdtxt            char (48)                    ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor
 end record

 define w_cts02m00    record
    vcllibflg         like datmservicocmp.vcllibflg,
    bocflg            like datmservicocmp.bocflg   ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    vclcorcod         like datmservico.vclcorcod   ,
    vclcordes         char (11)                    ,
    sinvitflg         like datmservicocmp.sinvitflg,
    roddantxt         like datmservicocmp.roddantxt,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    sindat            like datmservicocmp.sindat   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    ultlignum         like datmligacao.lignum      ,
    lignum            like datrligsrv.lignum       ,
    vclcamtip         like datmservicocmp.vclcamtip,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgflg         like datmservicocmp.vclcrgflg,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    atdlibflg         like datmservico.atdlibflg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    data              like datmservico.atddat      ,
    hora              like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    c24opemat         like datmservico.c24opemat   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdprscod         like datmservico.atdprscod   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    ctgtrfcod         like abbmcasco.ctgtrfcod     ,
    atdvcltip         like datmservico.atdvcltip   ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    socvclcod         like datmservico.socvclcod   ,
    asiofndigflg      like datkasitip.asiofndigflg ,
    vclcndlclflg      like datkasitip.vclcndlclflg ,
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define w_hist record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define a_cts02m00    array[3] of record
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
 
 define a_cts02m00_bkp  array[3] of record
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
 
 define m_hist_cts02m00_bkp   record
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
        ws_cgccpfdig  like aeikcdt.cgccpfdig

 define m_prep_sql    smallint      #psi179345  ivone
 define tip_mvt       char(01)

 define m_aciona        char(01)    #PSI198714
 define m_outrolaudo    smallint    #PSI198714
 define m_srv_acionado  smallint    #PSI198714
 define m_c24lclpdrcod  like datmlcl.c24lclpdrcod
 define m_imdsrvflg_ant char(1)
 define m_multiplo        char(1)
 define l_atdsrvnum_mult  like datmservico.atdsrvnum
 define l_atdsrvano_mult  like datmservico.atdsrvano
 define m_mdtcod					like datmmdtmsg.mdtcod
 define m_pstcoddig       like dpaksocor.pstcoddig
 define m_socvclcod       like datkveiculo.socvclcod
 define m_srrcoddig       like datksrr.srrcoddig
 define l_vclcordes			  char(20)

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_atdsrvorg  like datmservico.atdsrvorg

 define am_param   record
      c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
     ,c24pbmgrpdes  like datkpbmgrp.c24pbmgrpdes
     ,c24pbmcod     like datkpbm.c24pbmcod
     ,atddfttxt     like datkpbm.c24pbmdes
     ,asitipcod     like datmservico.asitipcod
 end record

 define m_nome          char(100)
 define m_telefone      char(11)
 define m_mensagem1      like datmlighist.c24ligdsc
 define aux_times       char(11)
 define m_data1          date
 define m_hora          like datmservico.atdhor
 define m_verifica      smallint
 define m_lignum        like datmligacao.lignum
 define m_aux_atdsrvnum       like datmservico.atdsrvnum
 define m_aux_atdsrvano       like datmservico.atdsrvano
 define m_aux_codigosql       integer
 define m_aux_msg             char(80)
 define m_ret         smallint
 define m_mensg       char(50)
 define m_grava_hist  smallint
 define l_msgaltend	 char(1500)
 define l_texto      char(200)
 define l_dtalt      date
 define l_hralt	   datetime hour to minute
 define l_lgdtxtcl   char(80)
 define l_ciaempnom  char(50)
 define l_codrtgps   smallint
 define l_msgrtgps   char(100)
 
 define m_flagaux_bo  char(1)
 define m_flagbo      char(100)
 define m_BO          char(100)
 define m_cidade      char(100)
 define m_estado      char(100)
 ##inicio - 179345 (ivone)

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

#--------------------------------------------------------------------
function cts02m00_prepara()
#--------------------------------------------------------------------
   define l_sql  char(500)

   
   #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
   
   let     l_sql  =  null

   let l_sql = " select grlinf ",
                 " from igbkgeral ",
                " where  mducod = 'C24' ",
                  " and  grlchv = 'RADIO-DEMAU' "

   prepare p_cts02m00_001 from l_sql
   declare c_cts02m00_001 cursor for p_cts02m00_001

   #PSI 198714 - buscar locais condicao veiculo do servico
   let l_sql = "select vclcndlclcod "
              ," from datrcndlclsrv "
              ," where atdsrvnum = ? "
              ,"   and atdsrvano = ? "
   prepare p_cts02m00_002 from l_sql
   declare c_cts02m00_002 cursor with hold for p_cts02m00_002

   let l_sql = " select atdfnlflg, ",
                      " acnsttflg, ",
                      " atdlibflg ",
                 " from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "

   prepare p_cts02m00_003 from l_sql
   declare c_cts02m00_003 cursor for p_cts02m00_003

   let l_sql = " update datmservico set c24opemat = null",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? "
   prepare p_cts02m00_004 from l_sql
   
   let l_sql = " select asitipcod ",
              " from datkpbm ",
             " where c24pbmcod = ? "
   prepare pcts02m00007 from l_sql
   declare ccts02m00007 cursor for pcts02m00007

   let l_sql =  "select atdetpcod                          "
               ,"  from datmsrvacp                         "
               ," where atdsrvnum = ?                      "
               ,"   and atdsrvano = ?                      "
               ,"   and atdsrvseq = (select max(atdsrvseq) "
               ,"                      from datmsrvacp     "
               ,"                     where atdsrvnum = ?  "
               ,"                       and atdsrvano = ?) "

   prepare pcts02m00008 from l_sql
   declare ccts02m00008 cursor for pcts02m00008
   
   #-----------------------------------
    -->Verifica se Ligacao ja tem Motivo
   #-----------------------------------
   let l_sql = " select 0 "
              ,"   from datrligrcuccsmtv "
              ,"  where lignum       = ? "
              ,"    and rcuccsmtvcod = ? "
              ,"    and c24astcod    = ? "
   prepare pcts02m00009 from l_sql
   declare ccts02m00009 cursor for pcts02m00009
   
   #--------------------------------
    -->Relaciona Motivo com a Ligacao
   #--------------------------------
   let l_sql = " insert into datrligrcuccsmtv (lignum       "
              ,"                              ,rcuccsmtvcod "
              ,"                              ,c24astcod)   "
              ,"                        values(?,?,?)       "
   prepare pcts02m00010 from l_sql
 
   #----------------------------
   --->Busca Descricao do Motivo
   #----------------------------
   let l_sql = " select rcuccsmtvdes       "
              ,"   from datkrcuccsmtv      "
              ,"  where rcuccsmtvstt = 'A' "
              ,"    and rcuccsmtvcod = ?   "
              ,"    and c24astcod    = ?   "
   prepare pcts02m00011 from l_sql
   declare ccts02m00010 cursor for pcts02m00011
   
   let l_sql = " select grlinf ",
               " from datkgeral ",
               " where grlchv = 'PSOAGENDAWATIVA' "
   prepare pcts02m00012 from l_sql
   declare ccts02m00012 cursor for pcts02m00012
  
   let m_prep_sql = true

end function
##fim - 179345 (ivone)

#--------------------------------------------------------------------
function cts02m00()
#--------------------------------------------------------------------

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod,
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    confirma          char (01),
    grvflg            smallint,
    imsvlr            like abbmcasco.imsvlr
 end record

 define l_grlinf      like igbkgeral.grlinf  #psi179345  ivone

 define l_data         date,
        l_hora2        datetime hour to minute

 define l_erro         smallint,
        l_acesso       smallint

#--------------------------------#

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_grlinf       =  null


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  ws.*  to  null

  let g_documento.atdsrvorg = 4
#--------------------------------#

 initialize m_rsrchv     
          , m_altcidufd  
          , m_altdathor
          , m_operacao
          , m_agncotdat 
          , m_agncothor
          , m_rsrchvant to null
          
 let m_outrolaudo         = 0
 let m_c24lclpdrcod       = null
 let m_srv_acionado       = false
 let m_premium            = false 
 let mr_atdsrvorg         = null
 let m_asitipcod          = null   
 let m_atdsrvnum_premium  = null   
 let m_atdsrvano_premium  = null   
 
 initialize f4.* to null

 let m_imdsrvflg_ant = null
 initialize m_subbairro to null

 initialize ws.*  to null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let int_flag      = false
 let aux_today     = l_data
 let aux_hora      = l_hora2
 let aux_ano       = aux_today[9,10]

 ##inicio - 179345 (ivone)
 if m_prep_sql is null or
    m_prep_sql <> true  then
      call cts02m00_prepara()
 end if
 ##fim - 179345 (ivone)

 # PSI-2013-00440PR
 let m_agendaw = false
 
 whenever error continue
 open ccts02m00012
 fetch ccts02m00012 into m_agendaw
 
 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 
 open window cts02m00 at 04,02 with form "cts02m00"
                      attribute(form line 1)

 if g_documento.atdsrvnum is null then
    display "(F1)Help,(F3)Ref,(F5)Espelho,(F6)Hist,(F7)Funcoes,(F8)Dest,(F9)Copia" to msgfun
 else
    display "(F1)Help(F3)Ref(F4)Apoio(F5)Esp(F6)Hist(F7)Func(F8)Dest(F9)Conclui(F2)Jit" to msgfun
 end if

 initialize d_cts02m00.*,
            w_cts02m00.*,
            aux_libant  ,
            cpl_atdsrvnum,
            cpl_atdsrvano,
            cpl_atdsrvorg  to null

 initialize a_cts02m00, a_cts02m00_bkp, m_hist_cts02m00_bkp to null

#--------------------------------------------------------------------
# Identificacao do CONVENIO
#--------------------------------------------------------------------

 let w_cts02m00.ligcvntip = g_documento.ligcvntip

 select cpodes into d_cts02m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts02m00.ligcvntip

 if g_documento.atdsrvnum is not null then
    call consulta_cts02m00()

    call cts02m00_display()

    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then
       call f_funapol_ultima_situacao
          (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
               returning g_funapol.*
       let ws.imsvlr = 0
       select imsvlr
            into ws.imsvlr
            from abbmbli
           where succod    = g_documento.succod    and
                 aplnumdig = g_documento.aplnumdig and
                 itmnumdig = g_documento.itmnumdig and
                 dctnumseq = g_funapol.autsitatu
       if ws.imsvlr > 0 then
          let ws.confirma = cts08g01 ("A","N","",
                                      "  VEICULO BLINDADO  ",
                                      "","")
       end if
    end if

    display by name a_cts02m00[1].lgdtxt,
                    a_cts02m00[1].lclbrrnom,
                    a_cts02m00[1].cidnom,
                    a_cts02m00[1].ufdcod,
                    a_cts02m00[1].lclrefptotxt,
                    a_cts02m00[1].endzon,
                    a_cts02m00[1].dddcod,
                    a_cts02m00[1].lcltelnum,
                    a_cts02m00[1].lclcttnom,
                    a_cts02m00[1].celteldddcod,
                    a_cts02m00[1].celtelnum,
                    a_cts02m00[1].endcmp

    if d_cts02m00.atdlibflg = "N"   then
       display by name d_cts02m00.atdlibdat attribute (invisible)
       display by name d_cts02m00.atdlibhor attribute (invisible)
    end if

    if d_cts02m00.refasstxt is not null  then
       display by name d_cts02m00.refasstxt attribute (reverse)
    end if

    if w_cts02m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    else
       if g_documento.aplnumdig  is not null   or
          d_cts02m00.vcllicnum   is not null   then
          call cts03g00 (1, g_documento.ramcod    ,
                            g_documento.succod    ,
                            g_documento.aplnumdig ,
                            g_documento.itmnumdig ,
                            d_cts02m00.vcllicnum  ,
                            g_documento.atdsrvnum ,
                            g_documento.atdsrvano )
       end if
    end if

    let ws.grvflg = modifica_cts02m00()

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null and
       g_documento.acao <> "INC"    then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today  ,aux_hora)
       let g_rec_his = true
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then
       let d_cts02m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto sucursal
                                        " ", g_documento.ramcod    using "&&&&",
                                        " ", g_documento.aplnumdig using "<<<<<<<& &"

       if g_documento.c24astcod <> "G13"  and
          g_documento.c24astcod <> "G02"  then
          call cts05g00 (g_documento.succod   ,
                         g_documento.ramcod   ,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig)
               returning d_cts02m00.nom      ,
                         d_cts02m00.corsus   ,
                         d_cts02m00.cornom   ,
                         d_cts02m00.cvnnom   ,
                         d_cts02m00.vclcoddig,
                         d_cts02m00.vcldes   ,
                         d_cts02m00.vclanomdl,
                         d_cts02m00.vcllicnum,
                         ws.vclchsinc        ,
                         ws.vclchsfnl        ,
                         d_cts02m00.vclcordes

          call cts02m01_caminhao(g_documento.succod   ,
                                 g_documento.aplnumdig,
                                 g_documento.itmnumdig,
                                 g_funapol.autsitatu)
                       returning d_cts02m00.camflg,
                                 w_cts02m00.ctgtrfcod
       end if
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts02m00.doctxt = "Cartao..: ", g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts02m00.nom      ,
                      d_cts02m00.corsus   ,
                      d_cts02m00.cornom   ,
                      d_cts02m00.cvnnom   ,
                      d_cts02m00.vclcoddig,
                      d_cts02m00.vcldes   ,
                      d_cts02m00.vclanomdl,
                      d_cts02m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts02m00.vclcordes
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

       call figrc072_setTratarIsolamento()        --> 223689
       call cts05g04 (g_documento.prporg  ,
                      g_documento.prpnumdig )
            returning d_cts02m00.nom      ,
                      d_cts02m00.corsus   ,
                      d_cts02m00.cornom   ,
                      d_cts02m00.cvnnom   ,
                      d_cts02m00.vclcoddig,
                      d_cts02m00.vcldes   ,
                      d_cts02m00.vclanomdl,
                      d_cts02m00.vcllicnum,
                      d_cts02m00.vclcordes
        if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Fun��o cts05g04 indisponivel no momento! Avise a Informatica !" sleep 2
            close window cts02m00
            let int_flag = false
            return
         end if    --> 223689

       let d_cts02m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                        " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    let d_cts02m00.prsloccab   = "Prs.Local.:"
    let d_cts02m00.prslocflg   = "N"

    let d_cts02m00.c24astcod   = g_documento.c24astcod
    let d_cts02m00.c24solnom   = g_documento.solnom

    let d_cts02m00.c24astdes = c24geral8( d_cts02m00.c24astcod )

    if d_cts02m00.c24astcod  = "G13"  or
       g_documento.c24astcod = "G02"  then
       let d_cts02m00.refatdsrvtxt = "Serv. Ref.:"
       display "/" at  09,67
       display "-" at  09,75
    end if

    call cts02m00_display()

        #inicio psi179345  ivone
    open c_cts02m00_001
    whenever error continue
    fetch c_cts02m00_001  into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT igbkgeral :',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
          error 'ctm02m00()/ mducod = C24 e grlchv = RADIO-DEMAU ' sleep 2
          clear form
          close window cts02m00
          let int_flag = false
          return
       end if
    end if
#fim psi179345 ivone


    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------
    if (g_documento.succod    is not null   and
        g_documento.ramcod    is not null   and
        g_documento.aplnumdig is not null)  or
       (d_cts02m00.vcllicnum  is not null)  then
       call cts03g00 (1, g_documento.ramcod    ,
                         g_documento.succod    ,
                         g_documento.aplnumdig ,
                         g_documento.itmnumdig ,
                         d_cts02m00.vcllicnum  ,
                         g_documento.atdsrvnum ,
                         g_documento.atdsrvano )
    end if

    ## PSI 208892
    call cts46g00("", g_issk.funmat, aux_today, aux_hora,
                  g_documento.c24astcod, "", g_issk.usrtip, g_issk.empcod,
                  g_documento.succod, g_documento.aplnumdig,
                  g_documento.itmnumdig, g_documento.ramcod,
                  g_documento.edsnumref)

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    let ws.grvflg = inclui_cts02m00()

    if ws.grvflg = true  then

       ## PSI 208892
       call cts46g00_grava(aux_atdsrvnum, aux_atdsrvano, g_issk.funmat,
                           aux_today, aux_hora,
                           g_documento.c24astcod, g_issk.usrtip, g_issk.empcod)

       call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts02m00.funmat,
                     w_cts02m00.data      , w_cts02m00.hora)
       if m_multiplo = 'S' then
          call cts10g02_historico_multiplo(l_atdsrvnum_mult,
                                         l_atdsrvano_mult,
                                         aux_atdsrvnum,
                                         aux_atdsrvano,
                                         w_cts02m00.funmat,
                                         w_cts02m00.data,
                                         w_cts02m00.hora)
       end if

       #-----------------------------------------------
       # Envia msg convenio/assunto se houver
       #-----------------------------------------------
# PSI 175552 - Inicio
#       call ctx17g00_assist(g_documento.ligcvntip,
#                            g_documento.c24astcod,
#                            aux_atdsrvnum        ,
#                            aux_atdsrvano        ,
#                            g_documento.lignum   ,
#                            g_documento.succod   ,
#                            g_documento.ramcod   ,
#                            g_documento.aplnumdig,
#                            g_documento.itmnumdig,
#                            g_documento.prporg   ,
#                            g_documento.prpnumdig,
#                            ws_cgccpfnum         ,
#                            ws_cgccpfdig         )
# PSI 175552 - Final
       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if d_cts02m00.imdsrvflg =  "S"     and        # servico imediato
          d_cts02m00.atdlibflg =  "S"     and        # servico liberado
          d_cts02m00.prslocflg =  "N"     and        # prestador no local
          d_cts02m00.frmflg    =  "N"     and        # formulario
          m_aciona =  'N'                 then       # servico nao acionado auto
          call cta00m06_acionamento(g_issk.dptsgl)
              returning l_acesso

       if g_documento.c24astcod <> 'M15' and
          g_documento.c24astcod <> 'M20' and
          g_documento.c24astcod <> 'M23' and
          g_documento.c24astcod <> 'M33' then
          if l_acesso = true then
             let ws.confirma = cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")

                if ws.confirma  =  "S"   then
                   call cts00m02(aux_atdsrvnum, aux_atdsrvano, 1 )
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
 
 #---------------------------------------------------- 
 # Dispara E-mail Atendimento Premium                  
 #---------------------------------------------------- 
 
 if cty31g00_valida_atd_premium()  and   
    d_cts02m00.c24astcod = "G10"   then   
   
     call cty31g00_dispara_email(m_atdsrvnum_premium   , 
                                 m_atdsrvano_premium   ,
                                 g_documento.succod    ,
                                 g_documento.ramcod    ,
                                 g_documento.aplnumdig ,
                                 g_documento.itmnumdig )
 end if
 
 
 
 
 
 
 
 
 
 

 #12/05/06 - Priscila
 #Apaga tabela temporaria da datkvclcndlcl
 # no mommento da exibicao dos itens de local/condicao veiculo estava incorreto
 # poruq enao estava apagando a tabela temporaria
 call ctc61m02_criatmp(2,
                       aux_atdsrvnum,
                       aux_atdsrvano )
      returning l_erro

 clear form

 close window cts02m00

end function  ###  cts02m00

#--------------------------------------------------------------------
function consulta_cts02m00()
#--------------------------------------------------------------------

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    vclcorcod         like datmservico.vclcorcod,
    funmat            like datmservico.funmat   ,
    funnom            like isskfunc.funnom       ,
    dptsgl            like isskfunc.dptsgl       ,
    codigosql         integer,
    succod            like datrservapol.succod   ,
    ramcod            like datrservapol.ramcod   ,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    edsnumref         like datrservapol.edsnumref,
    prporg            like datrligprp.prporg,
    prpnumdig         like datrligprp.prpnumdig,
    fcapcorg          like datrligpac.fcapacorg,
    fcapacnum         like datrligpac.fcapacnum,
    empcod            like datmservico.empcod                         #Raul, Biz
 end record

 define l_tipolaudo   smallint      #PSI198714
 
 define lr_retorno record
       coderro    smallint
      ,mensagem   char(100)
 end record
 
 define l_confirma char(1)
       ,l_errcod   smallint
       ,l_errmsg   char(80)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null
        initialize lr_retorno.* to null
        let l_confirma = null

 initialize l_errcod, l_errmsg to null
         
 select nom      ,
        vclcoddig,
        vcldes   ,
        vclanomdl,
        vcllicnum,
        corsus   ,
        cornom   ,
        vclcorcod,
        funmat   ,
        atddat   ,
        atdhor   ,
        atdlibflg,
        atdlibhor,
        atdlibdat,
        atdhorpvt,
        atdpvtretflg,
        atddatprg,
        atdhorprg,
        atdfnlflg,
        asitipcod,
        atdvcltip,
        atdprinvlcod,
        prslocflg,
        ciaempcod,
        empcod   ,           #Raul, Biz
        prslocflg
   into d_cts02m00.nom      ,
        d_cts02m00.vclcoddig,
        d_cts02m00.vcldes   ,
        d_cts02m00.vclanomdl,
        d_cts02m00.vcllicnum,
        d_cts02m00.corsus   ,
        d_cts02m00.cornom   ,
        ws.vclcorcod        ,
        ws.funmat           ,
        w_cts02m00.atddat   ,
        w_cts02m00.atdhor   ,
        d_cts02m00.atdlibflg,
        d_cts02m00.atdlibhor,
        d_cts02m00.atdlibdat,
        w_cts02m00.atdhorpvt,
        w_cts02m00.atdpvtretflg,
        w_cts02m00.atddatprg,
        w_cts02m00.atdhorprg,
        w_cts02m00.atdfnlflg,
        d_cts02m00.asitipcod,
        w_cts02m00.atdvcltip,
        d_cts02m00.atdprinvlcod,
        d_cts02m00.prslocflg,
        g_documento.ciaempcod,
        ws.empcod   ,   #Raul, Biz
        d_cts02m00.prslocflg
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 # PSI-2013-00440PR
 # identificar cota de agendamento ja realizado (ALT)
 call cts02m08_sel_cota(g_documento.atdsrvnum, g_documento.atdsrvano)
      returning l_errcod, l_errmsg, m_rsrchvant
 
 #if l_errcod = 0
 #   then
 #   #display 'cts02m08_sel_cota ok'
 #else
 #   display 'cts02m08_sel_cota erro ', l_errcod
 #   display l_errmsg clipped
 #end if

 call cts02m08_id_datahora_cota(m_rsrchvant)
      returning l_errcod, l_errmsg, m_agncotdatant, m_agncothorant
      
 #if l_errcod != 0
 #   then
 #   #display 'cts02m08_id_datahora_cota(consulta) erro no ID da cota'
 #   #display l_errmsg clipped
 #end if
 # PSI-2013-00440PR
 
 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts02m00[1].lclidttxt
                        ,a_cts02m00[1].lgdtip
                        ,a_cts02m00[1].lgdnom
                        ,a_cts02m00[1].lgdnum
                        ,a_cts02m00[1].lclbrrnom
                        ,a_cts02m00[1].brrnom
                        ,a_cts02m00[1].cidnom
                        ,a_cts02m00[1].ufdcod
                        ,a_cts02m00[1].lclrefptotxt
                        ,a_cts02m00[1].endzon
                        ,a_cts02m00[1].lgdcep
                        ,a_cts02m00[1].lgdcepcmp
                        ,a_cts02m00[1].lclltt
                        ,a_cts02m00[1].lcllgt
                        ,a_cts02m00[1].dddcod
                        ,a_cts02m00[1].lcltelnum
                        ,a_cts02m00[1].lclcttnom
                        ,a_cts02m00[1].c24lclpdrcod
                        ,a_cts02m00[1].celteldddcod
                        ,a_cts02m00[1].celtelnum
                        ,a_cts02m00[1].endcmp
                        ,ws.codigosql
                        ,a_cts02m00[1].emeviacod
 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts02m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts02m00[1].brrnom,
                                a_cts02m00[1].lclbrrnom)
      returning a_cts02m00[1].lclbrrnom
 select ofnnumdig into a_cts02m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts02m00[1].lgdtxt = a_cts02m00[1].lgdtip clipped, " ",
                            a_cts02m00[1].lgdnom clipped, " ",
                            a_cts02m00[1].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         2)
               returning a_cts02m00[2].lclidttxt
                        ,a_cts02m00[2].lgdtip
                        ,a_cts02m00[2].lgdnom
                        ,a_cts02m00[2].lgdnum
                        ,a_cts02m00[2].lclbrrnom
                        ,a_cts02m00[2].brrnom
                        ,a_cts02m00[2].cidnom
                        ,a_cts02m00[2].ufdcod
                        ,a_cts02m00[2].lclrefptotxt
                        ,a_cts02m00[2].endzon
                        ,a_cts02m00[2].lgdcep
                        ,a_cts02m00[2].lgdcepcmp
                        ,a_cts02m00[2].lclltt
                        ,a_cts02m00[2].lcllgt
                        ,a_cts02m00[2].dddcod
                        ,a_cts02m00[2].lcltelnum
                        ,a_cts02m00[2].lclcttnom
                        ,a_cts02m00[2].c24lclpdrcod
                        ,a_cts02m00[2].celteldddcod
                        ,a_cts02m00[2].celtelnum
                        ,a_cts02m00[2].endcmp
                        ,ws.codigosql
                        ,a_cts02m00[2].emeviacod
 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[2].lclbrrnom = a_cts02m00[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts02m00[2].brrnom,
                                a_cts02m00[2].lclbrrnom)
      returning a_cts02m00[2].lclbrrnom

 select ofnnumdig into a_cts02m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 2

 if ws.codigosql = notfound   then
    let d_cts02m00.dstflg = "N"
 else
    if ws.codigosql = 0   then
       let d_cts02m00.dstflg = "S"
    else
       error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

 let a_cts02m00[2].lgdtxt = a_cts02m00[2].lgdtip clipped, " ",
                            a_cts02m00[2].lgdnom clipped, " ",
                            a_cts02m00[2].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Dados complementares do servico
#--------------------------------------------------------------------

 select sinvitflg,
        roddantxt,
        rmcacpflg,
        sindat   ,
        sinhor   ,
        vclcamtip,
        vclcrcdsc,
        vclcrgflg,
        vclcrgpso,
        bocflg   ,
        bocnum   ,
        bocemi   ,
        vcllibflg
   into w_cts02m00.sinvitflg,
        w_cts02m00.roddantxt,
        w_cts02m00.rmcacpflg,
        w_cts02m00.sindat   ,
        d_cts02m00.sinhor   ,
        w_cts02m00.vclcamtip,
        w_cts02m00.vclcrcdsc,
        w_cts02m00.vclcrgflg,
        w_cts02m00.vclcrgpso,
        w_cts02m00.bocflg   ,
        w_cts02m00.bocnum   ,
        w_cts02m00.bocemi   ,
        w_cts02m00.vcllibflg
   from datmservicocmp
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 let d_cts02m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into d_cts02m00.asitipabvdes
   from datkasitip
  where asitipcod = d_cts02m00.asitipcod

#--------------------------------------------------------------------
# Verifica se ha' ASSISTENCIA A PASSAGEIROS relacionada
#--------------------------------------------------------------------

 declare ccts02m00002  cursor for
    select atdsrvnum, atdsrvano
      from datmassistpassag
     where refatdsrvnum = g_documento.atdsrvnum  and
           refatdsrvano = g_documento.atdsrvano
     order by atdsrvnum, atdsrvano

 foreach ccts02m00002 into ws.atdsrvnum,
                       ws.atdsrvano
 end foreach

 if ws.atdsrvnum is null  or
    ws.atdsrvano is null  then
    initialize d_cts02m00.refasstxt to null
 else
    let d_cts02m00.refasstxt = "ASSIST.PASSAG. ",
                               F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,07),
                          "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,02)
 end if

#--------------------------------------------------------------------
# Obtem documento do servico
#--------------------------------------------------------------------

 let w_cts02m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts02m00.lignum)
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
    let d_cts02m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto sucursal
                                     " ", g_documento.ramcod    using "&&&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts02m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

#--------------------------------------------------------------------
# Dados da ligacao
#--------------------------------------------------------------------

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts02m00.c24astcod,
        w_cts02m00.ligcvntip,
        d_cts02m00.c24solnom
   from datmligacao
  where lignum  =  w_cts02m00.lignum

 let g_documento.c24astcod = d_cts02m00.c24astcod

 select lignum
   from datmligfrm
  where lignum = w_cts02m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts02m00.frmflg = "N"
 else
    let d_cts02m00.frmflg = "S"
 end if

 select cpodes
   into d_cts02m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts02m00.ligcvntip

#--------------------------------------------------------------------
# Descricao do ASSUNTO
#--------------------------------------------------------------------

 let d_cts02m00.c24astdes = c24geral8( d_cts02m00.c24astcod )

#--------------------------------------------------------------------
# Obtem COR DO VEICULO
#--------------------------------------------------------------------

 select cpodes
   into d_cts02m00.vclcordes
   from iddkdominio
  where cponom    = "vclcorcod"  and
        cpocod    = ws.vclcorcod

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 let d_cts02m00.atdtxt = w_cts02m00.atddat        clipped, " ",
                         w_cts02m00.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)

 if w_cts02m00.atdhorpvt is not null  or
    w_cts02m00.atdhorpvt  = "00:00"   then
    let d_cts02m00.imdsrvflg = "S"
 end if

 if w_cts02m00.atddatprg is not null  then
    let d_cts02m00.imdsrvflg = "N"
 end if

 if w_cts02m00.vclcamtip is not null  and
    w_cts02m00.vclcamtip <>  " "      then
    let d_cts02m00.camflg = "S"
 else
    if w_cts02m00.vclcrgflg is not null  and
       w_cts02m00.vclcrgflg <>  " "      then
       let d_cts02m00.camflg = "S"
    else
       let d_cts02m00.camflg = "N"
    end if
 end if

 let aux_libant = d_cts02m00.atdlibflg

 if d_cts02m00.atdlibflg = "N"  then
    let d_cts02m00.atdlibdat = w_cts02m00.atddat
    let d_cts02m00.atdlibhor = w_cts02m00.atdhor
 end if

 let d_cts02m00.sinvitflg    = w_cts02m00.sinvitflg
 let d_cts02m00.bocflg       = w_cts02m00.bocflg
 let d_cts02m00.roddantxt    = w_cts02m00.roddantxt
 let d_cts02m00.rmcacpflg    = w_cts02m00.rmcacpflg
 let d_cts02m00.sindat       = w_cts02m00.sindat

 let d_cts02m00.servico = g_documento.atdsrvorg using "&&",
                          "/", g_documento.atdsrvnum using "&&&&&&&",
                          "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts02m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts02m00.atdprinvlcod


  #verificar se � ou se tem laudo de apoio
  call cts37g00_existeServicoApoio(g_documento.atdsrvnum, g_documento.atdsrvano)
       returning l_tipolaudo
  if l_tipolaudo <> 1 then
     if l_tipolaudo = 2 then
        let d_cts02m00.desapoio = "SERVICO TEM APOIO"
     else
        if l_tipolaudo = 3 then
           let d_cts02m00.desapoio = "SERVICO DE APOIO"
        end if
     end if
     display by name d_cts02m00.desapoio attribute (reverse)
  end if
  if g_documento.c24astcod <> 'SAP' then
     call cts10g00_verifica_multiplo(w_cts02m00.lignum)
          returning lr_retorno.*
     if lr_retorno.coderro = 1 then
        call cts08g01("A","N",""," EXISTE UMA SOLICITACAO DE APOIO"," PARA ESSE SERVICO !","")
             returning l_confirma
     end if
  end if

  let m_c24lclpdrcod = a_cts02m00[1].c24lclpdrcod

end function  ###  consulta_cts02m00

#--------------------------------------------------------------------
 function modifica_cts02m00()
#--------------------------------------------------------------------

 define ws           record
    codigosql        integer,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor
 end record

 DEFINE hist_cts02m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define lr_cts10g02   record
        tabname       char(20),
        errcod        smallint
 end record

 define prompt_key    char (01),
        l_mensagem    char(100)

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_atdsrvseq like datmsrvacp.atdsrvseq
       ,l_errcod    smallint
       ,l_errmsg    char(80)
       
 define l_atdfnlflg  like datmservico.atdfnlflg

 define lr_retorno             record
         resultado              smallint,
         mensagem               char(100)
 end record
 
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null
        let     l_mensagem  =  null
        let     l_atdsrvseq =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts02m00.*  to  null

        initialize  lr_cts10g02.*  to  null
        initialize  lr_retorno.*  to  null

        let     prompt_key  =  null

        initialize  ws.*  to  null

        initialize  hist_cts02m00.*  to  null

 initialize ws.*  to null
 initialize l_errcod, l_errmsg  to null
  
 call input_cts02m00() returning hist_cts02m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize d_cts02m00.*    to null
    initialize a_cts02m00      to null
    initialize w_cts02m00.*    to null
    clear form
    return false
 end if

 whenever error continue

#--------------------------------------------------------------------
# Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO
#--------------------------------------------------------------------
 if g_documento.ramcod = 31   or
    g_documento.ramcod = 531  then
    let w_cts02m00.atdvcltip = cts02m00_cambio( g_documento.succod   ,
                                                g_documento.aplnumdig,
                                                g_documento.itmnumdig )

 end if

#--------------------------------------------------------------------
# Verifica solicitacao de guincho para caminhao
#--------------------------------------------------------------------
 if d_cts02m00.asitipcod = 1  or       ###  Guincho
    d_cts02m00.asitipcod = 3  then     ###  Guincho/Tecnico
    if d_cts02m00.camflg = "S"  then
       let w_cts02m00.atdvcltip = 3
    end if
 end if

 #display 'cts02m00 - Modificar atendimento'
 
 begin work

 if m_imdsrvflg_ant <> d_cts02m00.imdsrvflg and
    g_documento.acao = "ALT" then

    call cts40g03_data_hora_banco(2) returning l_data, l_hora2

    let d_cts02m00.atdlibdat = l_data
    let d_cts02m00.atdlibhor = l_hora2

    call cts10g04_max_seq(g_documento.atdsrvnum, g_documento.atdsrvano, 1)
         returning lr_retorno.*, l_atdsrvseq

    if lr_retorno.resultado <> 1 then
       error lr_retorno.mensagem
    else
       ## atualiza a data de liberacao apos indexacao - datmsrvacp
       call cts10g04_atu_hor(g_documento.atdsrvnum, g_documento.atdsrvano,
                             l_atdsrvseq, l_hora2)
            returning lr_retorno.*

       if lr_retorno.resultado <> 1 then
          error lr_retorno.mensagem
       end if

    end if
 end if

 update datmservico set ( nom,
                          corsus,
                          cornom,
                          vclcoddig,
                          vcldes,
                          vclanomdl,
                          vcllicnum,
                          vclcorcod,
                          atdlibflg,
                          atdlibhor,
                          atdlibdat,
                          atdhorpvt,
                          atddatprg,
                          atdhorprg,
                          atdpvtretflg,
                          asitipcod,
                          atdvcltip,
                          atdprinvlcod,
                          prslocflg)
                      = ( d_cts02m00.nom      ,
                          d_cts02m00.corsus   ,
                          d_cts02m00.cornom   ,
                          d_cts02m00.vclcoddig,
                          d_cts02m00.vcldes   ,
                          d_cts02m00.vclanomdl,
                          d_cts02m00.vcllicnum,
                          w_cts02m00.vclcorcod,
                          d_cts02m00.atdlibflg,
                          d_cts02m00.atdlibhor,
                          d_cts02m00.atdlibdat,
                          w_cts02m00.atdhorpvt,
                          w_cts02m00.atddatprg,
                          w_cts02m00.atdhorprg,
                          w_cts02m00.atdpvtretflg,
                          d_cts02m00.asitipcod,
                          w_cts02m00.atdvcltip,
                          d_cts02m00.atdprinvlcod,
                          d_cts02m00.prslocflg)
                    where atdsrvnum = g_documento.atdsrvnum and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 if g_documento.acao is null then
#   call ctc61m02(g_documento.atdsrvnum,
#                 g_documento.atdsrvano,
#                 "A")
    let g_documento.acao = "CON"
 end if

 call cts10g02_grava_loccnd(g_documento.atdsrvnum,
                            g_documento.atdsrvano)
      returning lr_cts10g02.*

 if lr_cts10g02.errcod <> 0 then
    error " Erro (", lr_cts10g02.errcod, ") na gravacao da",
          " tabela ", lr_cts10g02.tabname clipped, ". AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmservicocmp set ( vclcamtip,
                             vclcrcdsc,
                             vclcrgflg,
                             vclcrgpso,
                             sinvitflg,
                             bocflg   ,
                             bocnum   ,
                             bocemi   ,
                             vcllibflg,
                             roddantxt,
                             rmcacpflg,
                             sindat   ,
                             sinhor   )
                         = ( w_cts02m00.vclcamtip,
                             w_cts02m00.vclcrcdsc,
                             w_cts02m00.vclcrgflg,
                             w_cts02m00.vclcrgpso,
                             d_cts02m00.sinvitflg,
                             d_cts02m00.bocflg,
                             w_cts02m00.bocnum,
                             w_cts02m00.bocemi,
                             w_cts02m00.vcllibflg,
                             d_cts02m00.roddantxt,
                             d_cts02m00.rmcacpflg,
                             d_cts02m00.sindat,
                             d_cts02m00.sinhor)
                       where atdsrvnum = g_documento.atdsrvnum and
                             atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao do complemento do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
  end if

 for arr_aux = 1 to 2
    if a_cts02m00[arr_aux].operacao is null  then
       let a_cts02m00[arr_aux].operacao = "M"
    end if
    if  (arr_aux = 1 and d_cts02m00.frmflg = "N") or arr_aux = 2 then
        let a_cts02m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    end if

    let ws.codigosql = cts06g07_local( a_cts02m00[arr_aux].operacao
                                    ,g_documento.atdsrvnum
                                    ,g_documento.atdsrvano
                                    ,arr_aux
                                    ,a_cts02m00[arr_aux].lclidttxt
                                    ,a_cts02m00[arr_aux].lgdtip
                                    ,a_cts02m00[arr_aux].lgdnom
                                    ,a_cts02m00[arr_aux].lgdnum
                                    ,a_cts02m00[arr_aux].lclbrrnom
                                    ,a_cts02m00[arr_aux].brrnom
                                    ,a_cts02m00[arr_aux].cidnom
                                    ,a_cts02m00[arr_aux].ufdcod
                                    ,a_cts02m00[arr_aux].lclrefptotxt
                                    ,a_cts02m00[arr_aux].endzon
                                    ,a_cts02m00[arr_aux].lgdcep
                                    ,a_cts02m00[arr_aux].lgdcepcmp
                                    ,a_cts02m00[arr_aux].lclltt
                                    ,a_cts02m00[arr_aux].lcllgt
                                    ,a_cts02m00[arr_aux].dddcod
                                    ,a_cts02m00[arr_aux].lcltelnum
                                    ,a_cts02m00[arr_aux].lclcttnom
                                    ,a_cts02m00[arr_aux].c24lclpdrcod
                                    ,a_cts02m00[arr_aux].ofnnumdig
                                    ,a_cts02m00[arr_aux].emeviacod
                                    ,a_cts02m00[arr_aux].celteldddcod
                                    ,a_cts02m00[arr_aux].celtelnum
                                    ,a_cts02m00[arr_aux].endcmp)

    if ws.codigosql is null   or
       ws.codigosql <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.codigosql, ") na alteracao do local de ocorrencia. AVISE A INFORMATICA!"
       else
          error " Erro (", ws.codigosql, ") na alteracao do local de destino. AVISE A INFORMATICA!"
       end if
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if aux_libant <> d_cts02m00.atdlibflg  then
    if d_cts02m00.atdlibflg = "S"  then
       let w_cts02m00.atdetpcod = 1
       let ws.atdetpdat = d_cts02m00.atdlibdat
       let ws.atdetphor = d_cts02m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let w_cts02m00.atdetpcod = 2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    let w_retorno = cts10g04_insere_etapa( g_documento.atdsrvnum,
                                           g_documento.atdsrvano,
                                           w_cts02m00.atdetpcod,
                                           w_cts02m00.atdprscod,
                                           " ",
                                           " ",
                                           " " )

    if w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento. AVISE A INFORMATICA!"
       prompt "" for char prompt_key
       rollback work
       return false
    end if
 end if

 whenever error stop

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum, g_documento.atdsrvano)

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
    call cts02m00_grava_historico()
 end if

  #-----------------------------------------------
  # Aciona Servico automaticamente
  #-----------------------------------------------
  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  #Alteracao projeto cadastro de destino
  if w_cts02m00.atdfnlflg = "S"  then

     if cts34g00_acion_auto (g_documento.atdsrvorg,
                             a_cts02m00[1].cidnom,
                             a_cts02m00[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
        if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                            g_documento.c24astcod,
                                            d_cts02m00.asitipcod,
                                            a_cts02m00[1].lclltt,
                                            a_cts02m00[1].lcllgt,
                                            d_cts02m00.prslocflg,
                                            d_cts02m00.frmflg,
                                            g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            " ",
                                            d_cts02m00.vclcoddig,
                                            d_cts02m00.camflg) then
           #servico nao pode ser acionado automaticamente
           #display "Servico acionado manual"
        else
           let m_aciona = 'S'
           #display "Servico foi para acionamento automatico!!"
        end if

     end if

  end if

  ###call cts02m00_valida_indexacao(g_documento.atdsrvnum,
  ###                               g_documento.atdsrvano,
  ###                               m_c24lclpdrcod,
  ###                               a_cts02m00[1].c24lclpdrcod)

  return true

end function  ###  modifica_cts02m00()

#-------------------------------------------------------------------------------
 function inclui_cts02m00()
#-------------------------------------------------------------------------------
 define hist_cts02m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define ws              record
        resposta        char(01)                   ,
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
        vclatmflg       like abbmveic.vclatmflg    ,
        vclcoddig       like abbmveic.vclcoddig    ,
        vstnumdig       like abbmveic.vstnumdig    ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq,
        ofnnumdig	      like sgokofi.ofnnumdig,
        ofncrdflg       like sgokofi.ofncrdflg
 end record

 define l_data       date,
        l_hora2      datetime hour to minute,
        l_ret        smallint,
        l_mensagem   char(60),
        l_atdsrvnum  like datmservico.atdsrvnum,
        l_atdsrvano  like datmservico.atdsrvano,
        l_atdsrvorg  like datmservico.atdsrvorg,
        l_txtsrv     char (15),
        l_reserva_ativa smallint # Flag para idenitficar se reserva esta ativa
       ,l_errcod        smallint
       ,l_errmsg        char(80)

 define lr_clausula record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
 end record
 
         
 define l_vclcndlclcod   like datrcndlclsrv.vclcndlclcod
 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  hist_cts02m00.*  to  null

        initialize  ws.*  to  null
        initialize  lr_clausula.* to  null

        let l_atdsrvnum = null
        let l_atdsrvano = null
        let l_atdsrvorg = null
        let l_txtsrv    = null
        
 initialize l_reserva_ativa, l_errcod, l_errmsg  to null
 
 #display 'cts02m00 - Incluir atendimento'

 while true

   initialize ws.*  to null

   let g_documento.acao = "INC"

   call input_cts02m00() returning hist_cts02m00.*

   if  int_flag  then
       let int_flag = false
       initialize d_cts02m00.*    to null
       initialize w_cts02m00.*    to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if w_cts02m00.data is null  then
      let w_cts02m00.data   = aux_today
      let w_cts02m00.hora   = aux_hora
      let w_cts02m00.funmat = g_issk.funmat
   end if


   if  d_cts02m00.frmflg = "S"  then
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

   if  w_cts02m00.atdfnlflg is null  then
       let w_cts02m00.atdfnlflg = "N"
       let w_cts02m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if


   #------------------------------------------------------------------------------
   # Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO
   #------------------------------------------------------------------------------
   if  g_documento.ramcod = 31    or
       g_documento.ramcod = 531  then
       let w_cts02m00.atdvcltip = cts02m00_cambio( g_documento.succod   ,
                                                   g_documento.aplnumdig,
                                                   g_documento.itmnumdig )

   end if

   #------------------------------------------------------------------------------
   # Verifica solicitacao de guincho para caminhao
   #------------------------------------------------------------------------------
   if  d_cts02m00.asitipcod = 1  or       ###  Guincho
       d_cts02m00.asitipcod = 3  then     ###  Guincho/Tecnico
       if  d_cts02m00.camflg = "S"  then
           let w_cts02m00.atdvcltip = 3
       end if
   end if
   
   #===================================================
   # Chama funcao para gravar dados
   #===================================================
  
   call cts02m00_grava_dados(ws.*,hist_cts02m00.*)
        returning l_ret, l_mensagem, aux_atdsrvnum,
                  aux_atdsrvano
   if l_ret <> 1 then
       error l_mensagem
    else
    	
    	  
    	  #----------------------------------------------------    
    	  # Carrega Atendimento Premium                            
    	  #----------------------------------------------------    
    	  
    	  if cty31g00_valida_atd_premium()   and 
   	  	   g_documento.c24astcod = "G10"   then
        
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
           end if 
           
           if l_ret = 0 then    
              commit work              
           else                  
              rollback work      
           end if                
           
           
           let g_documento.c24astcod = 'JIT'
           let mr_atdsrvorg          = g_documento.atdsrvorg  
           let m_asitipcod           = d_cts02m00.asitipcod 
           let g_documento.atdsrvorg = 15 
           let m_premium             = true  
           let d_cts02m00.asitipcod  = 98
           
           call cts02m00_grava_dados(ws.*,hist_cts02m00.*)                        
           returning l_ret           , 
                     l_mensagem      , 
                     l_atdsrvnum_mult,                  
                     l_atdsrvano_mult                                                   
         
           
           if l_ret <> 1 then                                                     
              error l_mensagem                                                    
           end if  
          
           let m_atdsrvnum_premium   = l_atdsrvnum_mult    
           let m_atdsrvano_premium   = l_atdsrvano_mult   
           let g_documento.atdsrvorg = mr_atdsrvorg
           let d_cts02m00.asitipcod  = m_asitipcod                                                               
           
       end if
    	
    	
       if m_multiplo = 'S' then
         call cts02m00_desbloqueia_servico(aux_atdsrvnum,aux_atdsrvano)
         let l_atdsrvnum = aux_atdsrvnum
         let l_atdsrvano = aux_atdsrvano
         let l_atdsrvorg = g_documento.atdsrvorg
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
         let g_documento.c24astcod = 'SAP'
         let g_documento.atdsrvorg = 1
         let d_cts02m00.asitipcod = am_param.asitipcod
  
  
         call cts02m00_grava_dados(ws.*,hist_cts02m00.*)
            returning l_ret, l_mensagem, l_atdsrvnum_mult,
                l_atdsrvano_mult
         if l_ret <> 1 then
            error l_mensagem
         end if
         call cts02m00_desbloqueia_servico(aux_atdsrvnum,aux_atdsrvano)
         let aux_atdsrvnum = l_atdsrvnum
         let aux_atdsrvano = l_atdsrvano
         let g_documento.atdsrvorg = l_atdsrvorg
       end if
   end if
   
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
               call cts02m08(w_cts02m00.atdfnlflg,
                             d_cts02m00.imdsrvflg,
                             m_altcidufd,
                             d_cts02m00.prslocflg,
                             w_cts02m00.atdhorpvt,
                             w_cts02m00.atddatprg,
                             w_cts02m00.atdhorprg,
                             w_cts02m00.atdpvtretflg,
                             m_rsrchv,
                             m_operacao,
                             "",
                             a_cts02m00[1].cidnom,
                             a_cts02m00[1].ufdcod,
                             "",   # codigo de assistencia, nao existe no Ct24h
                             d_cts02m00.vclcoddig,
                             w_cts02m00.ctgtrfcod,
                             d_cts02m00.imdsrvflg,
                             a_cts02m00[1].c24lclpdrcod,
                             a_cts02m00[1].lclltt,
                             a_cts02m00[1].lcllgt,
                             g_documento.ciaempcod,
                             g_documento.atdsrvorg,
                             d_cts02m00.asitipcod,
                             "",   # natureza somente RE
                             "")   # sub-natureza somente RE
                   returning w_cts02m00.atdhorpvt,
                             w_cts02m00.atddatprg,
                             w_cts02m00.atdhorprg,
                             w_cts02m00.atdpvtretflg,
                             d_cts02m00.imdsrvflg,
                             m_rsrchv,
                             m_operacao,
                             m_altdathor
                                
               display by name d_cts02m00.imdsrvflg
               
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
               #   #display 'cts02m08_ins_cota gravou com sucesso'
               #else
               #   display 'cts02m08_ins_cota erro ', l_errcod
               #   display l_errmsg clipped
               #end if
            else
               #display 'cts02m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
            end if
         else
            #display l_txtsrv clipped, ' erro na inclusao, liberar agenda'
            
            call cts02m08_id_datahora_cota(m_rsrchv)
                 returning l_errcod, l_errmsg, m_agncotdat, m_agncothor
                 
            if l_errcod != 0
               then
               display 'ctd41g00_liberar_agenda NAO acionado, erro no ID da cota'
               display l_errmsg clipped
            end if
            
            call ctd41g00_liberar_agenda(aux_atdsrvano, aux_atdsrvnum,
                                         m_agncotdat, m_agncothor)
         end if
      end if
   end if
   # PSI-2013-00440PR
   
   #------------------------------------------------------------------------------
   # Exibe o numero do servico
   #------------------------------------------------------------------------------
   let d_cts02m00.servico = g_documento.atdsrvorg using "&&",
                            "/", aux_atdsrvnum using "&&&&&&&",
                            "-", aux_atdsrvano using "&&"
   display d_cts02m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.resposta

   error " Inclusao efetuada com sucesso!"
   
   #CT471704 - inicio
	#--------------------------------------------------------------------
 	# Envia Fax para oficinas credenciadas para orgem de servico 4
 	#--------------------------------------------------------------------
 	if g_documento.atdsrvorg = 4 and d_cts02m00.prslocflg = "S" and w_cts02m00.atdetpcod = 4 then
         	let ws.ofnnumdig = NULL
    		select ofnnumdig
           	into ws.ofnnumdig
      		from datmlcl
     		where atdsrvnum = aux_atdsrvnum
       		and atdsrvano = aux_atdsrvano
       		and c24endtip = 2
    		if ws.ofnnumdig is not NULL then
       			select ofncrdflg
              		into ws.ofncrdflg
         		from sgokofi
        		where ofnnumdig = ws.ofnnumdig
       			if ws.ofncrdflg = "S" then
          			call cts00m24(aux_atdsrvnum, aux_atdsrvano, ws.ofnnumdig, "F")
       			end if
    		end if
 	end if
 	#CT471704 - fim

   let ws.retorno = true

   exit while
 end while
 
 return ws.retorno

end function  ###  inclui_cts02m00

#--------------------------------------------------------------------
 function input_cts02m00()
#--------------------------------------------------------------------
   ### PSI216445 - Inicio ###
   define l_segurado record
      segnumdig like gsakendmai.segnumdig, # Numero e digito do segurado
      email_segurado like gsakendmai.maides # Email do segurado
   end record

   define l_oficina record
      ofnnumdig like sgokofi.ofnnumdig, # Numero e digito da oficina
      nomrazsoc like gkpkpos.nomrazsoc, # Razao Social
      nomgrr like gkpkpos.nomgrr, # Nome de Guerra (ou Nome Fantasia)
      endlgd like gkpkpos.endlgd, # Endereco
      endbrr like gkpkpos.endbrr, # Bairro
      endcep like gkpkpos.endcep, # Cep
      endcepcmp like gkpkpos.endcepcmp, # Complemento do Cep
      dddcod like gkpkpos.dddcod, # DDD da Regiao
      telnum1 like gkpkpos.telnum1, # Telefone
      endufd like gkpkpos.endufd, # Estado
      endcid like gkpkpos.endcid, # Cidade
      ofnblqtip like sgokofi.ofnblqtip, # Tipo de bloqueio da Oficina
      ofnbrrcod like sgokofi.ofnbrrcod, # Codigo do Bairro
      succod like sgokofi.succod, # Codigo da Sucursal
      ofnrgicod like sgokofi.ofnrgicod, # Codigo da Regiao da Oficina
      regiao like gkpkbairro.ofcbrrdes, # Bairro
      situacao char (36) # Situacao da Oficina
   end record

   define l_email record
      sistorig_ char (20), # Sistema de origem do e-mail
      sender_ like gsakendmai.maides, # Quem esta enviando (e-mail)
      from_ like gsakendmai.maides, # Quem esta enviando (identificacao do rementente)
      to_ like gsakendmai.maides, # Para quem esta sendo enviado o e-mail (e-mail)
      replayto_ like gsakendmai.maides, # Para quem sera retornada uma mensagem de resposta
      assunto_ char (100), # Assunto do e-mail
      mensagem_ char (2000), # Mensagem do e-mail
      sistema_ char (20) # Sistem de origem do e-mail
   end record

   define l_informacoes_oficina char (1) # Guarda a informacao de que as informacoes
                                         # da oficina foram encontradas (S) ou nao (N)

   define l_resposta_envio char (100) # Pode ser uma mensagem de sucesso ou nao.

   define l_aux2 char (50)
   ### PSI216445 - Fim ###

   define l_resposta char (1)

   define hist_cts02m00 record
      hist1 like datmservhist.c24srvdsc,
      hist2 like datmservhist.c24srvdsc,
      hist3 like datmservhist.c24srvdsc,
      hist4 like datmservhist.c24srvdsc,
      hist5 like datmservhist.c24srvdsc
   end record

   define ws record
      refatdsrvorg like datmservico.atdsrvorg,
      dddcod like gsakend.dddcod,
      teltxt like gsakend.teltxt,
      retflg char (01),
      prpflg char (01),
      senhaok char (01),
      blqnivcod like datkblq.blqnivcod,
      vcllicant like datmservico.vcllicnum,
      endcep like glaklgd.lgdcep,
      endcepcmp like glaklgd.lgdcepcmp,
      confirma char (01),
      dtparam char (16),
      codigosql integer,
      resp char (01),
      linha1 char (62),
      linha2 char (62),
      linha3 char (62),
      linha4 char (62),
      auxatdsrvorg like datmservico.atdsrvorg,
      auxatdsrvnum like datmservico.atdsrvnum,
      auxatdsrvano like datmservico.atdsrvano,
      jitatdsrvnum like datmsrvjit.refatdsrvnum,
      jitatdsrvano like datmsrvjit.refatdsrvano,
      opcao smallint,
      opcaodes char(20),
      ofnstt like sgokofi.ofnstt,
      rglflg smallint,
      ofnnumdig like sgokofi.ofnnumdig,
      ofncrdflg like sgokofi.ofncrdflg
   end record

   define prompt_key char (01)
   define erros_chk char (01)
   define l_tmp_flg smallint
   define l_count integer
   define l_salva_nom like datmservico.nom
   define l_vclcoddig_contingencia like datmservico.vclcoddig
   define l_data date, l_hora2 datetime hour to minute
   define l_tipolaudo smallint, #PSI198714
          l_atdsrvnum like datmservico.atdsrvnum,
          l_atdsrvano like datmservico.atdsrvano,
          l_aux smallint,
          l_msg char(70),
          l_atdfnlflg like datmservico.atdfnlflg,
          l_acnsttflg like datmservico.acnsttflg,
          l_atdlibflg like datmservico.atdlibflg,
          l_acesso     smallint,
          l_confirma   char(1),
          l_c24astcod  like datkassunto.c24astcod,
          l_null       char(1),
          l_mensagem   char(300),
          l_erro       smallint,
          l_atdetpcod    like datmsrvacp.atdetpcod,
          l_status       smallint,
          l_flag_limite char(1)
         ,l_errcod       smallint
         ,l_errmsg       char(80)
          
   initialize m_cidnom
             ,m_ufdcod
             ,m_operacao
             ,m_altcidufd
             ,m_imdsrvflg
   to null

   initialize l_errcod, l_errmsg to null 
   
   ### PSI216445 - Inicio ###
   initialize l_segurado.* to null
   initialize l_oficina.* to null
   initialize l_email.* to null
   let l_informacoes_oficina = null
   let l_resposta_envio = null
   let l_aux2 = null
   let l_null = null
   let l_mensagem = null
   let l_erro = false
   ### PSI216445 - Fim ###

   let m_verifica = 0

   #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
   let prompt_key  = null
   let erros_chk   = null
   let l_salva_nom = null
   let l_tmp_flg   = null
   let l_vclcoddig_contingencia  =  null
   let l_msg = null
   let l_atdfnlflg = null
   let l_acnsttflg = null
   let l_atdlibflg = null
   let l_acesso    = null
   let l_atdetpcod = null
   let l_status    = null
   #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   initialize hist_cts02m00.* to null
   initialize ws.* to null

   let prompt_key = null
   let erros_chk = null

   initialize hist_cts02m00.* to null
   initialize ws.* to null
   initialize ws.* to null

   let m_grava_hist = false

   call cts40g03_data_hora_banco(2) returning l_data, l_hora2

   let ws.dtparam = l_data using "yyyy-mm-dd"
   let ws.dtparam[12,16] = l_hora2
   let ws.vcllicant = d_cts02m00.vcllicnum
   let l_vclcoddig_contingencia = d_cts02m00.vclcoddig
   let l_salva_nom = d_cts02m00.nom
   
   # PSI-2013-00440PR
   if g_documento.acao = "INC"
      then
      let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
   else
      let m_operacao = 5  # na consulta considera liberado para nao regular novamente
      #display 'consulta, considerar cota ja regulada'
   end if
   
   # situacao original do servico
   let m_imdsrvflg = d_cts02m00.imdsrvflg
   let m_cidnom = a_cts02m00[1].cidnom
   let m_ufdcod = a_cts02m00[1].ufdcod
   # PSI-2013-00440PR
   
   
   #display 'entrada do input, var null ou carregada na consulta'
   #display 'd_cts02m00.imdsrvflg :', d_cts02m00.imdsrvflg
   #display 'a_cts02m00[1].cidnom :', a_cts02m00[1].cidnom
   #display 'a_cts02m00[1].ufdcod :', a_cts02m00[1].ufdcod
   #display 'g_documento.acao     :', g_documento.acao
   #display 'm_operacao           :', m_operacao
   #display 'm_agncotdatant       :', m_agncotdatant
   #display 'm_agncothorant       :', m_agncothorant
   
   
   input by name d_cts02m00.nom, d_cts02m00.corsus, d_cts02m00.cornom,
                 d_cts02m00.vclcoddig, d_cts02m00.vclanomdl, d_cts02m00.vcllicnum,
                 d_cts02m00.vclcordes, d_cts02m00.frmflg, d_cts02m00.camflg,
                 d_cts02m00.refatdsrvorg, d_cts02m00.refatdsrvnum,
                 d_cts02m00.refatdsrvano, a_cts02m00[1].lgdtxt, a_cts02m00[1].lclbrrnom,
                 a_cts02m00[1].cidnom, a_cts02m00[1].ufdcod, a_cts02m00[1].lclrefptotxt,
                 a_cts02m00[1].endzon, a_cts02m00[1].dddcod, a_cts02m00[1].lcltelnum,
                 a_cts02m00[1].lclcttnom, d_cts02m00.sindat, d_cts02m00.sinhor,
                 ## d_cts02m00.roddantxt,
                 d_cts02m00.sinvitflg, d_cts02m00.bocflg, d_cts02m00.asitipcod,
                 d_cts02m00.dstflg, d_cts02m00.rmcacpflg, d_cts02m00.atdprinvlcod,
                 d_cts02m00.prslocflg, d_cts02m00.atdlibflg,
                 d_cts02m00.imdsrvflg without defaults

   before field nom
          display by name d_cts02m00.nom        attribute (reverse)

          if g_documento.atdsrvnum   is not null   and
             g_documento.atdsrvano   is not null   and
             d_cts02m00.camflg       =  "S"        and
             (w_cts02m00.atdfnlflg    =  "N" or w_cts02m00.atdfnlflg = "A") then
             if d_cts02m00.frmflg = "S" then
                initialize w_cts02m00.vclcamtip to null
                initialize w_cts02m00.vclcrcdsc to null
                initialize w_cts02m00.vclcrgflg to null
                initialize w_cts02m00.vclcrgpso to null
             else
                call cts02m01(w_cts02m00.ctgtrfcod,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              w_cts02m00.vclcrgflg ,
                              w_cts02m00.vclcrgpso ,
                              w_cts02m00.vclcamtip ,
                              w_cts02m00.vclcrcdsc )
                    returning w_cts02m00.vclcrgflg ,
                              w_cts02m00.vclcrgpso ,
                              w_cts02m00.vclcamtip ,
                              w_cts02m00.vclcrcdsc
             end if
          end if


   after  field nom
          display by name d_cts02m00.nom

          if g_documento.acao = "CON" then
             error " Servico sendo consultado, nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                  returning ws.confirma
                  
             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03("S"                 ,
                              d_cts02m00.imdsrvflg,
                              w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg)
                    returning w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg
             else
                call cts02m08("S"                 ,
                              d_cts02m00.imdsrvflg,
                              m_altcidufd,
                              d_cts02m00.prslocflg,
                              w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts02m00[1].cidnom,
                              a_cts02m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts02m00.vclcoddig,
                              w_cts02m00.ctgtrfcod,
                              d_cts02m00.imdsrvflg,
                              a_cts02m00[1].c24lclpdrcod,
                              a_cts02m00[1].lclltt,
                              a_cts02m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts02m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg,
                              d_cts02m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             next field nom
          end if

          if d_cts02m00.nom is null or
             d_cts02m00.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if

          if w_cts02m00.atdfnlflg = "S"  then

             # ---> SALVA O NOME DO SEGURADO
             let d_cts02m00.nom = l_salva_nom
             display by name d_cts02m00.nom

             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             let ws.confirma = cts08g01( "A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                         " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                             "E INFORME AO  ** CONTROLE DE TRAFEGO **")
          
             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts02m00.atdfnlflg,
                              d_cts02m00.imdsrvflg,
                              w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg)
                    returning w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg
             else
                call cts02m08(w_cts02m00.atdfnlflg,
                              d_cts02m00.imdsrvflg,
                              m_altcidufd,
                              d_cts02m00.prslocflg,
                              w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts02m00[1].cidnom,
                              a_cts02m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts02m00.vclcoddig,
                              w_cts02m00.ctgtrfcod,
                              d_cts02m00.imdsrvflg,
                              a_cts02m00[1].c24lclpdrcod,
                              a_cts02m00[1].lclltt,
                              a_cts02m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts02m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg,
                              d_cts02m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)

             if d_cts02m00.frmflg = "S" then
                call cts11g00(w_cts02m00.lignum)
                let int_flag = true
             end if
             exit input

          end if

   before field corsus
          display by name d_cts02m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts02m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.corsus is not null  then
                select cornom
                  into d_cts02m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts02m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts02m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts02m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts02m00.cornom

   before field vclcoddig
          display by name d_cts02m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts02m00.vclcoddig

          # se outro processo nao obteve cat. tarifaria, obter
          if w_cts02m00.ctgtrfcod is null
             then
             # laudo auto obter cod categoria tarifaria
             call cts02m08_sel_ctgtrfcod(d_cts02m00.vclcoddig)   
                  returning l_errcod, l_errmsg, w_cts02m00.ctgtrfcod
          end if
        
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts02m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts02m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts02m00.vclcoddig is null  or
                d_cts02m00.vclcoddig =  0     then
                let d_cts02m00.vclcoddig = agguvcl()
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts02m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             let d_cts02m00.vcldes = cts15g00( d_cts02m00.vclcoddig )

             display by name d_cts02m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts02m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts02m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.vclanomdl is null or
                d_cts02m00.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts02m00.vclcoddig, d_cts02m00.vclanomdl) = false  then
                   error " Veiculo nao consta como fabricado em ", d_cts02m00.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts02m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts02m00.vcllicnum

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vclanomdl
        end if

        if not srp1415(d_cts02m00.vcllicnum)  then
           error " Placa invalida!"
           next field vcllicnum
        end if

        #---------------------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if g_documento.aplnumdig   is null       and
           d_cts02m00.vcllicnum    is not null   then

           if d_cts02m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.senhaok  to null

              call cts13g00(d_cts02m00.c24astcod,
                            "", "", "", "",
                            d_cts02m00.vcllicnum,
                            "", "", "")
                   returning ws.blqnivcod, ws.senhaok

              if ws.blqnivcod  =  3   then
                 error " Bloqueio cadastrado nao permite atendimento para este assunto/apolice!"
                 next field vcllicnum
              end if

              if ws.blqnivcod  =  2     and
                 ws.senhaok    =  "n"   then
                 error " Bloqueio necessita de permissao para atendimento!"
                 next field vcllicnum
              end if
           end if

           #-----------------------------------------------------------------
           # Verifica se ja' houve solicitacao de servico para apolice
           #-----------------------------------------------------------------
           call cts03g00 (1, g_documento.ramcod    ,
                             g_documento.succod    ,
                             g_documento.aplnumdig ,
                             g_documento.itmnumdig ,
                             d_cts02m00.vcllicnum  ,
                             g_documento.atdsrvnum ,
                             g_documento.atdsrvano )
        end if

   before field vclcordes
          display by name d_cts02m00.vclcordes  attribute (reverse)

   after  field vclcordes
          display by name d_cts02m00.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.vclcordes  is not null then
                let w_cts02m00.vclcordes = d_cts02m00.vclcordes[2,9]

                select cpocod into w_cts02m00.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts02m00.vclcordes

                if sqlca.sqlcode = notfound    then
                   error " Cor fora do padrao!"
                   call c24geral4()
                        returning w_cts02m00.vclcorcod, d_cts02m00.vclcordes

                   if w_cts02m00.vclcorcod  is null   then
                      error " Cor do veiculo deve ser informado!"
                      next field vclcordes
                   else
                      display by name d_cts02m00.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts02m00.vclcorcod, d_cts02m00.vclcordes

                if w_cts02m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts02m00.vclcordes
                end if
             end if
          end if
          let d_cts02m00.frmflg = "N"
          display by name d_cts02m00.frmflg
          next field camflg

   before field frmflg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             let d_cts02m00.frmflg = "N"
             display by name d_cts02m00.frmflg attribute (reverse)
          else
             next field camflg
          end if

   after  field frmflg
          display by name d_cts02m00.frmflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.frmflg = "S" then
                call cts02m05(4) returning w_cts02m00.data     ,
                                           w_cts02m00.hora     ,
                                           w_cts02m00.funmat   ,
                                           w_cts02m00.cnldat   ,
                                           w_cts02m00.atdfnlhor,
                                           w_cts02m00.c24opemat,
                                           w_cts02m00.atdprscod
                if w_cts02m00.hora      is null  or
                   w_cts02m00.data      is null  or
                   w_cts02m00.funmat    is null  or
                   w_cts02m00.cnldat    is null  or
                   w_cts02m00.atdfnlhor is null  or
                   w_cts02m00.c24opemat is null  or
                   w_cts02m00.atdprscod is null  then
                   error " Faltam dados para entrada via formulario!"
                   next field frmflg
                end if
                let d_cts02m00.atdlibhor = w_cts02m00.hora
                let d_cts02m00.atdlibdat = w_cts02m00.data
                let w_cts02m00.atdfnlflg = "S"
                let w_cts02m00.atdetpcod =  4
                let d_cts02m00.imdsrvflg    = "S"
                let w_cts02m00.atdhorpvt    = "00:00"
                let w_cts02m00.atdpvtretflg = "N"
                let d_cts02m00.atdprinvlcod =  2
                let d_cts02m00.prslocflg    = "N"
                let d_cts02m00.atdlibflg    = "S"
                display by name d_cts02m00.imdsrvflg
                display by name d_cts02m00.atdprinvlcod
                display by name d_cts02m00.prslocflg
             else
                if d_cts02m00.prslocflg = "N"   then
                   initialize w_cts02m00.hora     ,
                              w_cts02m00.data     ,
                              w_cts02m00.funmat   ,
                              w_cts02m00.cnldat   ,
                              w_cts02m00.atdfnlhor,
                              w_cts02m00.c24opemat,
                              w_cts02m00.atdfnlflg,
                              w_cts02m00.atdetpcod,
                              w_cts02m00.atdprscod to null
                end if
             end if
          end if

   before field camflg
          display by name d_cts02m00.camflg attribute (reverse)

   after  field camflg
          display by name d_cts02m00.camflg
          let g_documento.lclocodesres = "N"

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts02m00.camflg  is null)  or
                 (d_cts02m00.camflg  <>  "S"   and
                  d_cts02m00.camflg  <>  "N")) then
                error " Informacao sobre caminhao/utilitario invalida!"
                next field camflg
             end if

             if d_cts02m00.frmflg = "S" then
                initialize w_cts02m00.vclcamtip to null
                initialize w_cts02m00.vclcrcdsc to null
                initialize w_cts02m00.vclcrgflg to null
                initialize w_cts02m00.vclcrgpso to null
                next field refatdsrvorg
             end if

             if d_cts02m00.camflg = "S"  then
                call cts02m01(w_cts02m00.ctgtrfcod,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              w_cts02m00.vclcrgflg ,
                              w_cts02m00.vclcrgpso ,
                              w_cts02m00.vclcamtip ,
                              w_cts02m00.vclcrcdsc )
                    returning w_cts02m00.vclcrgflg ,
                              w_cts02m00.vclcrgpso ,
                              w_cts02m00.vclcamtip ,
                              w_cts02m00.vclcrcdsc

                if w_cts02m00.vclcamtip  is null   and
                   w_cts02m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                   next field camflg
                end if
             else
                initialize w_cts02m00.vclcamtip to null
                initialize w_cts02m00.vclcrcdsc to null
                initialize w_cts02m00.vclcrgflg to null
                initialize w_cts02m00.vclcrgpso to null
             end if

             if (g_documento.atdsrvnum is not null   and
                 g_documento.atdsrvano is not null)  or
                (d_cts02m00.c24astcod <> "G13"       and
                 d_cts02m00.c24astcod <> "G02" )  then
                let a_cts02m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

                let m_acesso_ind = false
                let m_atdsrvorg = 4
                call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                     returning m_acesso_ind
                if m_acesso_ind = false then
                    call cts06g03( 1
                                  ,m_atdsrvorg
                                  ,w_cts02m00.ligcvntip
                                  ,aux_today
                                  ,aux_hora
                                  ,a_cts02m00[1].lclidttxt
                                  ,a_cts02m00[1].cidnom
                                  ,a_cts02m00[1].ufdcod
                                  ,a_cts02m00[1].brrnom
                                  ,a_cts02m00[1].lclbrrnom
                                  ,a_cts02m00[1].endzon
                                  ,a_cts02m00[1].lgdtip
                                  ,a_cts02m00[1].lgdnom
                                  ,a_cts02m00[1].lgdnum
                                  ,a_cts02m00[1].lgdcep
                                  ,a_cts02m00[1].lgdcepcmp
                                  ,a_cts02m00[1].lclltt
                                  ,a_cts02m00[1].lcllgt
                                  ,a_cts02m00[1].lclrefptotxt
                                  ,a_cts02m00[1].lclcttnom
                                  ,a_cts02m00[1].dddcod
                                  ,a_cts02m00[1].lcltelnum
                                  ,a_cts02m00[1].c24lclpdrcod
                                  ,a_cts02m00[1].ofnnumdig
                                  ,a_cts02m00[1].celteldddcod
                                  ,a_cts02m00[1].celtelnum
                                  ,a_cts02m00[1].endcmp
                                  ,hist_cts02m00.*
                                  ,a_cts02m00[1].emeviacod )
                        returning a_cts02m00[1].lclidttxt
                                 ,a_cts02m00[1].cidnom
                                 ,a_cts02m00[1].ufdcod
                                 ,a_cts02m00[1].brrnom
                                 ,a_cts02m00[1].lclbrrnom
                                 ,a_cts02m00[1].endzon
                                 ,a_cts02m00[1].lgdtip
                                 ,a_cts02m00[1].lgdnom
                                 ,a_cts02m00[1].lgdnum
                                 ,a_cts02m00[1].lgdcep
                                 ,a_cts02m00[1].lgdcepcmp
                                 ,a_cts02m00[1].lclltt
                                 ,a_cts02m00[1].lcllgt
                                 ,a_cts02m00[1].lclrefptotxt
                                 ,a_cts02m00[1].lclcttnom
                                 ,a_cts02m00[1].dddcod
                                 ,a_cts02m00[1].lcltelnum
                                 ,a_cts02m00[1].c24lclpdrcod
                                 ,a_cts02m00[1].ofnnumdig
                                 ,a_cts02m00[1].celteldddcod
                                 ,a_cts02m00[1].celtelnum
                                 ,a_cts02m00[1].endcmp
                                 ,ws.retflg
                                 ,hist_cts02m00.*
                                 ,a_cts02m00[1].emeviacod
                else
                   call cts06g11( 1
                                 ,m_atdsrvorg
                                 ,w_cts02m00.ligcvntip
                                 ,aux_today
                                 ,aux_hora
                                 ,a_cts02m00[1].lclidttxt
                                 ,a_cts02m00[1].cidnom
                                 ,a_cts02m00[1].ufdcod
                                 ,a_cts02m00[1].brrnom
                                 ,a_cts02m00[1].lclbrrnom
                                 ,a_cts02m00[1].endzon
                                 ,a_cts02m00[1].lgdtip
                                 ,a_cts02m00[1].lgdnom
                                 ,a_cts02m00[1].lgdnum
                                 ,a_cts02m00[1].lgdcep
                                 ,a_cts02m00[1].lgdcepcmp
                                 ,a_cts02m00[1].lclltt
                                 ,a_cts02m00[1].lcllgt
                                 ,a_cts02m00[1].lclrefptotxt
                                 ,a_cts02m00[1].lclcttnom
                                 ,a_cts02m00[1].dddcod
                                 ,a_cts02m00[1].lcltelnum
                                 ,a_cts02m00[1].c24lclpdrcod
                                 ,a_cts02m00[1].ofnnumdig
                                 ,a_cts02m00[1].celteldddcod
                                 ,a_cts02m00[1].celtelnum
                                 ,a_cts02m00[1].endcmp
                                 ,hist_cts02m00.*
                                 ,a_cts02m00[1].emeviacod )
                        returning a_cts02m00[1].lclidttxt
                                 ,a_cts02m00[1].cidnom
                                 ,a_cts02m00[1].ufdcod
                                 ,a_cts02m00[1].brrnom
                                 ,a_cts02m00[1].lclbrrnom
                                 ,a_cts02m00[1].endzon
                                 ,a_cts02m00[1].lgdtip
                                 ,a_cts02m00[1].lgdnom
                                 ,a_cts02m00[1].lgdnum
                                 ,a_cts02m00[1].lgdcep
                                 ,a_cts02m00[1].lgdcepcmp
                                 ,a_cts02m00[1].lclltt
                                 ,a_cts02m00[1].lcllgt
                                 ,a_cts02m00[1].lclrefptotxt
                                 ,a_cts02m00[1].lclcttnom
                                 ,a_cts02m00[1].dddcod
                                 ,a_cts02m00[1].lcltelnum
                                 ,a_cts02m00[1].c24lclpdrcod
                                 ,a_cts02m00[1].ofnnumdig
                                 ,a_cts02m00[1].celteldddcod
                                 ,a_cts02m00[1].celtelnum
                                 ,a_cts02m00[1].endcmp
                                 ,ws.retflg
                                 ,hist_cts02m00.*
                                 ,a_cts02m00[1].emeviacod
                end if
                #------------------------------------------------------------------------------
                # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
                #------------------------------------------------------------------------------
                if g_documento.lclocodesres = "S" then
                   let w_cts02m00.atdrsdflg = "S"
                else
                   let w_cts02m00.atdrsdflg = "N"
                end if
                # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                let m_subbairro[1].lclbrrnom = a_cts02m00[1].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts02m00[1].brrnom,
                                               a_cts02m00[1].lclbrrnom)
                     returning a_cts02m00[1].lclbrrnom

                let a_cts02m00[1].lgdtxt = a_cts02m00[1].lgdtip clipped, " ",
                                           a_cts02m00[1].lgdnom clipped, " ",
                                           a_cts02m00[1].lgdnum using "<<<<#"

                if a_cts02m00[1].cidnom is not null and
                   a_cts02m00[1].ufdcod is not null then
                    call cts14g00 (d_cts02m00.c24astcod,
                                   "","","","",
                                   a_cts02m00[1].cidnom,
                                   a_cts02m00[1].ufdcod,
                                   "S",
                                   ws.dtparam)
                end if
                display by name a_cts02m00[1].lgdtxt
                display by name a_cts02m00[1].lclbrrnom
                display by name a_cts02m00[1].endzon
                display by name a_cts02m00[1].cidnom
                display by name a_cts02m00[1].ufdcod
                display by name a_cts02m00[1].lclrefptotxt
                display by name a_cts02m00[1].lclcttnom
                display by name a_cts02m00[1].dddcod
                display by name a_cts02m00[1].lcltelnum
                display by name a_cts02m00[1].celteldddcod
                display by name a_cts02m00[1].celtelnum
                display by name a_cts02m00[1].endcmp

                if a_cts02m00[1].ufdcod = "EX" then
                  let  ws.retflg = "S"
                end if

                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos ou nao preenchidos!"
                   next field camflg
                end if
             end if
          end if

   before field refatdsrvorg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  and
             (d_cts02m00.c24astcod = "G13"  or
              d_cts02m00.c24astcod = "G02") then
             display by name d_cts02m00.refatdsrvorg attribute (reverse)
          else
             display by name d_cts02m00.refatdsrvorg
             display by name d_cts02m00.refatdsrvnum
             display by name d_cts02m00.refatdsrvano
             next field lgdtxt
          end if

   after  field refatdsrvorg
          display by name d_cts02m00.refatdsrvorg

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field camflg
          end if

#         if  d_cts02m00.refatdsrvorg is null  then
           if  g_documento.succod    is not null  or
               g_documento.aplnumdig is not null  then
               call cts11m02( g_documento.succod   ,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig,
                              4                    , # atdsrvorg-remocao
                              g_documento.ramcod   )
                    returning d_cts02m00.refatdsrvorg,
                              d_cts02m00.refatdsrvnum,
                              d_cts02m00.refatdsrvano

               display by name d_cts02m00.refatdsrvorg
               display by name d_cts02m00.refatdsrvnum
               display by name d_cts02m00.refatdsrvano

#              if  d_cts02m00.refatdsrvnum is null  and
#                  d_cts02m00.refatdsrvano is null  then

                   let a_cts02m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
                   let m_acesso_ind = false
                   let m_atdsrvorg = 2
                   call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                        returning m_acesso_ind
                   if m_acesso_ind = false then
                       call cts06g03(1
                                    ,m_atdsrvorg
                                    ,w_cts02m00.ligcvntip
                                    ,aux_today
                                    ,aux_hora
                                    ,a_cts02m00[1].lclidttxt
                                    ,a_cts02m00[1].cidnom
                                    ,a_cts02m00[1].ufdcod
                                    ,a_cts02m00[1].brrnom
                                    ,a_cts02m00[1].lclbrrnom
                                    ,a_cts02m00[1].endzon
                                    ,a_cts02m00[1].lgdtip
                                    ,a_cts02m00[1].lgdnom
                                    ,a_cts02m00[1].lgdnum
                                    ,a_cts02m00[1].lgdcep
                                    ,a_cts02m00[1].lgdcepcmp
                                    ,a_cts02m00[1].lclltt
                                    ,a_cts02m00[1].lcllgt
                                    ,a_cts02m00[1].lclrefptotxt
                                    ,a_cts02m00[1].lclcttnom
                                    ,a_cts02m00[1].dddcod
                                    ,a_cts02m00[1].lcltelnum
                                    ,a_cts02m00[1].c24lclpdrcod
                                    ,a_cts02m00[1].ofnnumdig
                                    ,a_cts02m00[1].celteldddcod
                                    ,a_cts02m00[1].celtelnum
                                    ,a_cts02m00[1].endcmp
                                    ,hist_cts02m00.*
                                    ,a_cts02m00[1].emeviacod )
                           returning a_cts02m00[1].lclidttxt
                                    ,a_cts02m00[1].cidnom
                                    ,a_cts02m00[1].ufdcod
                                    ,a_cts02m00[1].brrnom
                                    ,a_cts02m00[1].lclbrrnom
                                    ,a_cts02m00[1].endzon
                                    ,a_cts02m00[1].lgdtip
                                    ,a_cts02m00[1].lgdnom
                                    ,a_cts02m00[1].lgdnum
                                    ,a_cts02m00[1].lgdcep
                                    ,a_cts02m00[1].lgdcepcmp
                                    ,a_cts02m00[1].lclltt
                                    ,a_cts02m00[1].lcllgt
                                    ,a_cts02m00[1].lclrefptotxt
                                    ,a_cts02m00[1].lclcttnom
                                    ,a_cts02m00[1].dddcod
                                    ,a_cts02m00[1].lcltelnum
                                    ,a_cts02m00[1].c24lclpdrcod
                                    ,a_cts02m00[1].ofnnumdig
                                    ,a_cts02m00[1].celteldddcod
                                    ,a_cts02m00[1].celtelnum
                                    ,a_cts02m00[1].endcmp
                                    ,ws.retflg
                                    ,hist_cts02m00.*
                                    ,a_cts02m00[1].emeviacod
                    else
                       call cts06g11(1
                                    ,m_atdsrvorg
                                    ,w_cts02m00.ligcvntip
                                    ,aux_today
                                    ,aux_hora
                                    ,a_cts02m00[1].lclidttxt
                                    ,a_cts02m00[1].cidnom
                                    ,a_cts02m00[1].ufdcod
                                    ,a_cts02m00[1].brrnom
                                    ,a_cts02m00[1].lclbrrnom
                                    ,a_cts02m00[1].endzon
                                    ,a_cts02m00[1].lgdtip
                                    ,a_cts02m00[1].lgdnom
                                    ,a_cts02m00[1].lgdnum
                                    ,a_cts02m00[1].lgdcep
                                    ,a_cts02m00[1].lgdcepcmp
                                    ,a_cts02m00[1].lclltt
                                    ,a_cts02m00[1].lcllgt
                                    ,a_cts02m00[1].lclrefptotxt
                                    ,a_cts02m00[1].lclcttnom
                                    ,a_cts02m00[1].dddcod
                                    ,a_cts02m00[1].lcltelnum
                                    ,a_cts02m00[1].c24lclpdrcod
                                    ,a_cts02m00[1].ofnnumdig
                                    ,a_cts02m00[1].celteldddcod
                                    ,a_cts02m00[1].celtelnum
                                    ,a_cts02m00[1].endcmp
                                    ,hist_cts02m00.*
                                    ,a_cts02m00[1].emeviacod )
                           returning a_cts02m00[1].lclidttxt
                                    ,a_cts02m00[1].cidnom
                                    ,a_cts02m00[1].ufdcod
                                    ,a_cts02m00[1].brrnom
                                    ,a_cts02m00[1].lclbrrnom
                                    ,a_cts02m00[1].endzon
                                    ,a_cts02m00[1].lgdtip
                                    ,a_cts02m00[1].lgdnom
                                    ,a_cts02m00[1].lgdnum
                                    ,a_cts02m00[1].lgdcep
                                    ,a_cts02m00[1].lgdcepcmp
                                    ,a_cts02m00[1].lclltt
                                    ,a_cts02m00[1].lcllgt
                                    ,a_cts02m00[1].lclrefptotxt
                                    ,a_cts02m00[1].lclcttnom
                                    ,a_cts02m00[1].dddcod
                                    ,a_cts02m00[1].lcltelnum
                                    ,a_cts02m00[1].c24lclpdrcod
                                    ,a_cts02m00[1].ofnnumdig
                                    ,a_cts02m00[1].celteldddcod
                                    ,a_cts02m00[1].celtelnum
                                    ,a_cts02m00[1].endcmp
                                    ,ws.retflg
                                    ,hist_cts02m00.*
                                    ,a_cts02m00[1].emeviacod
                    end if
                   if g_documento.lclocodesres = "S" then
                      let w_cts02m00.atdrsdflg = "S"
                   else
                      let w_cts02m00.atdrsdflg = "N"
                   end if
                   # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                   let m_subbairro[1].lclbrrnom = a_cts02m00[1].lclbrrnom
                   call cts06g10_monta_brr_subbrr(a_cts02m00[1].brrnom,
                                                  a_cts02m00[1].lclbrrnom)
                        returning a_cts02m00[1].lclbrrnom

                   let a_cts02m00[1].lgdtxt = a_cts02m00[1].lgdtip clipped, " ",
                                              a_cts02m00[1].lgdnom clipped, " ",
                                              a_cts02m00[1].lgdnum using "<<<<#"

                   if a_cts02m00[1].cidnom is not null and
                      a_cts02m00[1].ufdcod is not null then
                      call cts14g00( d_cts02m00.c24astcod,
                                     "","","","",
                                     a_cts02m00[1].cidnom,
                                     a_cts02m00[1].ufdcod,
                                     "S",
                                     ws.dtparam)
                   end if

                   display by name a_cts02m00[1].lgdtxt
                   display by name a_cts02m00[1].lclbrrnom
                   display by name a_cts02m00[1].endzon
                   display by name a_cts02m00[1].cidnom
                   display by name a_cts02m00[1].ufdcod
                   display by name a_cts02m00[1].lclrefptotxt
                   display by name a_cts02m00[1].lclcttnom
                   display by name a_cts02m00[1].dddcod
                   display by name a_cts02m00[1].lcltelnum
                   display by name a_cts02m00[1].celteldddcod
                   display by name a_cts02m00[1].celtelnum
                   display by name a_cts02m00[1].endcmp

									 if a_cts02m00[1].ufdcod = "EX" then
			                let ws.retflg = "S"
			             end if

                   if  ws.retflg = "N"  then
                       error " Dados referentes ao local incorretos",
                             " ou nao preenchidos!"
                       next field refatdsrvorg
                   else
                       next field sindat
                   end if
#              end if
           else
               initialize d_cts02m00.refatdsrvnum to null
               initialize d_cts02m00.refatdsrvano to null
               display by name d_cts02m00.refatdsrvnum
               display by name d_cts02m00.refatdsrvano
           end if
#         end if

   before field refatdsrvnum
          display by name d_cts02m00.refatdsrvnum attribute (reverse)

   after  field refatdsrvnum
          display by name d_cts02m00.refatdsrvnum

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field refatdsrvorg
          end if

          if d_cts02m00.refatdsrvorg is not null  and
             d_cts02m00.refatdsrvnum is null      then
             error " Numero do servico de referencia nao informado!"
             next field refatdsrvnum
          end if

   before field refatdsrvano
          display by name d_cts02m00.refatdsrvano attribute (reverse)

   after  field refatdsrvano
          display by name d_cts02m00.refatdsrvano

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field refatdsrvnum
          end if

          if d_cts02m00.refatdsrvnum is not null  and
             d_cts02m00.refatdsrvano is null      then
             error " Ano do servico de referencia nao informado!"
             next field refatdsrvano
          end if

          if (d_cts02m00.refatdsrvorg is not null  and
             d_cts02m00.refatdsrvnum is not null  and
             d_cts02m00.refatdsrvano is not null)  or
             (d_cts02m00.c24astcod = "G13"         or
              d_cts02m00.c24astcod = "G02"      )  then
             select atdsrvorg
               into ws.refatdsrvorg
               from DATMSERVICO
                    where atdsrvnum = d_cts02m00.refatdsrvnum
                      and atdsrvano = d_cts02m00.refatdsrvano

             if  ws.refatdsrvorg <> d_cts02m00.refatdsrvorg  then
                 error " Origem do numero de servico invalido.",
                       " A origem deve ser ", ws.refatdsrvorg using "&&"
                 next field refatdsrvorg
             end if

             call ctx04g00_local_gps (d_cts02m00.refatdsrvnum,
                                      d_cts02m00.refatdsrvano,
                                      1)
                            returning a_cts02m00[1].lclidttxt
                                     ,a_cts02m00[1].lgdtip
                                     ,a_cts02m00[1].lgdnom
                                     ,a_cts02m00[1].lgdnum
                                     ,a_cts02m00[1].lclbrrnom
                                     ,a_cts02m00[1].brrnom
                                     ,a_cts02m00[1].cidnom
                                     ,a_cts02m00[1].ufdcod
                                     ,a_cts02m00[1].lclrefptotxt
                                     ,a_cts02m00[1].endzon
                                     ,a_cts02m00[1].lgdcep
                                     ,a_cts02m00[1].lgdcepcmp
                                     ,a_cts02m00[1].lclltt
                                     ,a_cts02m00[1].lcllgt
                                     ,a_cts02m00[1].dddcod
                                     ,a_cts02m00[1].lcltelnum
                                     ,a_cts02m00[1].lclcttnom
                                     ,a_cts02m00[1].c24lclpdrcod
                                     ,a_cts02m00[1].celteldddcod
                                     ,a_cts02m00[1].celtelnum
                                     ,a_cts02m00[1].endcmp
                                     ,ws.codigosql
                                     ,a_cts02m00[1].emeviacod

             if ws.codigosql <> 0  then
                error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                next field refatdsrvorg
             end if

             select ofnnumdig into a_cts02m00[1].ofnnumdig
               from datmlcl
              where atdsrvano = g_documento.atdsrvano
                and atdsrvnum = g_documento.atdsrvnum
                and c24endtip = 1

             let a_cts02m00[1].lgdtxt = a_cts02m00[1].lgdtip clipped, " ",
                                        a_cts02m00[1].lgdnom clipped, " ",
                                        a_cts02m00[1].lgdnum using "<<<<#"

             if g_documento.succod    is not null  and
                g_documento.ramcod    is not null  and
                g_documento.aplnumdig is not null  and
                g_documento.itmnumdig is not null  then
                select atdsrvnum, atdsrvano
                  from datrservapol
                 where atdsrvnum = d_cts02m00.refatdsrvnum  and
                       atdsrvano = d_cts02m00.refatdsrvano  and
                       succod    = g_documento.succod       and
                       ramcod    = g_documento.ramcod       and
                       aplnumdig = g_documento.aplnumdig    and
                       itmnumdig = g_documento.itmnumdig

                if sqlca.sqlcode = notfound  then
                   error " Servico de referencia nao pertence ao documento informado!"
                   next field refatdsrvorg
                end if
             end if

             display by name a_cts02m00[1].lgdtxt
             display by name a_cts02m00[1].lclbrrnom
             display by name a_cts02m00[1].endzon
             display by name a_cts02m00[1].cidnom
             display by name a_cts02m00[1].ufdcod
             display by name a_cts02m00[1].lclrefptotxt
             display by name a_cts02m00[1].lclcttnom
             display by name a_cts02m00[1].dddcod
             display by name a_cts02m00[1].lcltelnum
             display by name a_cts02m00[1].celteldddcod
             display by name a_cts02m00[1].celtelnum
             display by name a_cts02m00[1].endcmp

             if d_cts02m00.frmflg = "S" then
#               if g_documento.atdsrvnum is null  and
#                  g_documento.atdsrvano is null  then
#                  let ws.confirma = cts08g01("Q","N","LOCAL ONDE VEICULO SE ENCONTRA",
#                                             "E' DE DIFICIL ACESSO ?",
#                                             "GARAGEM, SUBSOLO, ESTACIONAMENTO",
#                                             "REGISTRE INFORMACAO NO HISTORICO")
#               end if
                next field lgdtxt
             end if

             let a_cts02m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
             let m_acesso_ind = false
             let m_atdsrvorg = 4
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind
             if m_acesso_ind = false then
                 call cts06g03(1
                              ,m_atdsrvorg
                              ,w_cts02m00.ligcvntip
                              ,aux_today
                              ,aux_hora
                              ,a_cts02m00[1].lclidttxt
                              ,a_cts02m00[1].cidnom
                              ,a_cts02m00[1].ufdcod
                              ,a_cts02m00[1].brrnom
                              ,a_cts02m00[1].lclbrrnom
                              ,a_cts02m00[1].endzon
                              ,a_cts02m00[1].lgdtip
                              ,a_cts02m00[1].lgdnom
                              ,a_cts02m00[1].lgdnum
                              ,a_cts02m00[1].lgdcep
                              ,a_cts02m00[1].lgdcepcmp
                              ,a_cts02m00[1].lclltt
                              ,a_cts02m00[1].lcllgt
                              ,a_cts02m00[1].lclrefptotxt
                              ,a_cts02m00[1].lclcttnom
                              ,a_cts02m00[1].dddcod
                              ,a_cts02m00[1].lcltelnum
                              ,a_cts02m00[1].c24lclpdrcod
                              ,a_cts02m00[1].ofnnumdig
                              ,a_cts02m00[1].celteldddcod
                              ,a_cts02m00[1].celtelnum
                              ,a_cts02m00[1].endcmp
                              ,hist_cts02m00.*
                              ,a_cts02m00[1].emeviacod )
                     returning a_cts02m00[1].lclidttxt
                              ,a_cts02m00[1].cidnom
                              ,a_cts02m00[1].ufdcod
                              ,a_cts02m00[1].brrnom
                              ,a_cts02m00[1].lclbrrnom
                              ,a_cts02m00[1].endzon
                              ,a_cts02m00[1].lgdtip
                              ,a_cts02m00[1].lgdnom
                              ,a_cts02m00[1].lgdnum
                              ,a_cts02m00[1].lgdcep
                              ,a_cts02m00[1].lgdcepcmp
                              ,a_cts02m00[1].lclltt
                              ,a_cts02m00[1].lcllgt
                              ,a_cts02m00[1].lclrefptotxt
                              ,a_cts02m00[1].lclcttnom
                              ,a_cts02m00[1].dddcod
                              ,a_cts02m00[1].lcltelnum
                              ,a_cts02m00[1].c24lclpdrcod
                              ,a_cts02m00[1].ofnnumdig
                              ,a_cts02m00[1].celteldddcod
                              ,a_cts02m00[1].celtelnum
                              ,a_cts02m00[1].endcmp
                              ,ws.retflg
                              ,hist_cts02m00.*
                              ,a_cts02m00[1].emeviacod
             else
                 call cts06g11(1
                              ,m_atdsrvorg
                              ,w_cts02m00.ligcvntip
                              ,aux_today
                              ,aux_hora
                              ,a_cts02m00[1].lclidttxt
                              ,a_cts02m00[1].cidnom
                              ,a_cts02m00[1].ufdcod
                              ,a_cts02m00[1].brrnom
                              ,a_cts02m00[1].lclbrrnom
                              ,a_cts02m00[1].endzon
                              ,a_cts02m00[1].lgdtip
                              ,a_cts02m00[1].lgdnom
                              ,a_cts02m00[1].lgdnum
                              ,a_cts02m00[1].lgdcep
                              ,a_cts02m00[1].lgdcepcmp
                              ,a_cts02m00[1].lclltt
                              ,a_cts02m00[1].lcllgt
                              ,a_cts02m00[1].lclrefptotxt
                              ,a_cts02m00[1].lclcttnom
                              ,a_cts02m00[1].dddcod
                              ,a_cts02m00[1].lcltelnum
                              ,a_cts02m00[1].c24lclpdrcod
                              ,a_cts02m00[1].ofnnumdig
                              ,a_cts02m00[1].celteldddcod
                              ,a_cts02m00[1].celtelnum
                              ,a_cts02m00[1].endcmp
                              ,hist_cts02m00.*
                              ,a_cts02m00[1].emeviacod )
                     returning a_cts02m00[1].lclidttxt
                              ,a_cts02m00[1].cidnom
                              ,a_cts02m00[1].ufdcod
                              ,a_cts02m00[1].brrnom
                              ,a_cts02m00[1].lclbrrnom
                              ,a_cts02m00[1].endzon
                              ,a_cts02m00[1].lgdtip
                              ,a_cts02m00[1].lgdnom
                              ,a_cts02m00[1].lgdnum
                              ,a_cts02m00[1].lgdcep
                              ,a_cts02m00[1].lgdcepcmp
                              ,a_cts02m00[1].lclltt
                              ,a_cts02m00[1].lcllgt
                              ,a_cts02m00[1].lclrefptotxt
                              ,a_cts02m00[1].lclcttnom
                              ,a_cts02m00[1].dddcod
                              ,a_cts02m00[1].lcltelnum
                              ,a_cts02m00[1].c24lclpdrcod
                              ,a_cts02m00[1].ofnnumdig
                              ,a_cts02m00[1].celteldddcod
                              ,a_cts02m00[1].celtelnum
                              ,a_cts02m00[1].endcmp
                              ,ws.retflg
                              ,hist_cts02m00.*
                              ,a_cts02m00[1].emeviacod
             end if
             # PSI 244589 - Inclus�o de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts02m00[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts02m00[1].brrnom,
                                            a_cts02m00[1].lclbrrnom)
                  returning a_cts02m00[1].lclbrrnom

             let a_cts02m00[1].lgdtxt = a_cts02m00[1].lgdtip clipped, " ",
                                        a_cts02m00[1].lgdnom clipped, " ",
                                        a_cts02m00[1].lgdnum using "<<<<#"


             if a_cts02m00[1].cidnom is not null and
                a_cts02m00[1].ufdcod is not null then
                call cts14g00 (d_cts02m00.c24astcod,
                               "","","","",
                               a_cts02m00[1].cidnom,
                               a_cts02m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts02m00[1].lgdtxt
             display by name a_cts02m00[1].lclbrrnom
             display by name a_cts02m00[1].endzon
             display by name a_cts02m00[1].cidnom
             display by name a_cts02m00[1].ufdcod
             display by name a_cts02m00[1].lclrefptotxt
             display by name a_cts02m00[1].lclcttnom
             display by name a_cts02m00[1].dddcod
             display by name a_cts02m00[1].lcltelnum
             display by name a_cts02m00[1].celteldddcod
             display by name a_cts02m00[1].celtelnum
             display by name a_cts02m00[1].endcmp
#Humberto
						 if a_cts02m00[1].ufdcod = "EX" then
			             let ws.retflg = "S"
			       end if

             if ws.retflg = "N"  then
                error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field refatdsrvorg
             end if

             if g_documento.atdsrvnum is null  and
                g_documento.atdsrvano is null  then
                let ws.confirma = cts08g01("Q","N","LOCAL ONDE VEICULO SE ENCONTRA",
                                           "E' DE DIFICIL ACESSO ?",
                                           "GARAGEM, SUBSOLO, ESTACIONAMENTO",
                                           "REGISTRE INFORMACAO NO HISTORICO")
             end if
          end if

   before field lgdtxt
          if d_cts02m00.frmflg = "N" then
             next field sindat
          end if
          display by name a_cts02m00[1].lgdtxt attribute (reverse)

   after  field lgdtxt
          display by name a_cts02m00[1].lgdtxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
#            if g_documento.atdsrvnum is null  and
#               g_documento.atdsrvano is null  and
#               d_cts02m00.c24astcod = "G13"   then
#               next field refatdsrvorg
#            else
                next field camflg
#            end if
          end if
          if a_cts02m00[1].lgdtxt is null then
             error " Endereco deve ser informado!"
             next field lgdtxt
          end if

   before field lclbrrnom
          display by name a_cts02m00[1].lclbrrnom attribute (reverse)

   after  field lclbrrnom
          display by name a_cts02m00[1].lclbrrnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lgdtxt
          end if
          if a_cts02m00[1].lclbrrnom is null then
             error " Bairro deve ser informado!"
             next field lclbrrnom
          end if

   before field cidnom
          display by name a_cts02m00[1].cidnom attribute (reverse)

   after  field cidnom
          display by name a_cts02m00[1].cidnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclbrrnom
          end if
          if a_cts02m00[1].cidnom is null then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

   before field ufdcod
          display by name a_cts02m00[1].ufdcod attribute (reverse)

   after  field ufdcod
          display by name a_cts02m00[1].ufdcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cidnom
          end if
          if a_cts02m00[1].ufdcod is null then
             error " U.F. deve ser informada!"
             next field ufdcod
          end if

          # Verifica Cidade/UF
          select count(*) into l_count
            from glakcid
           where cidnom = a_cts02m00[1].cidnom
             and ufdcod = a_cts02m00[1].ufdcod

           if l_count = 0 then
              error " Cidade/UF nao estao corretos!"
              next field ufdcod
           end if

   before field lclrefptotxt
          display by name a_cts02m00[1].lclrefptotxt attribute (reverse)

   after  field lclrefptotxt
          display by name a_cts02m00[1].lclrefptotxt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ufdcod
          end if

   before field endzon
          display by name a_cts02m00[1].endzon attribute (reverse)

   after  field endzon
          display by name a_cts02m00[1].endzon

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclrefptotxt
          end if
          if a_cts02m00[1].ufdcod  = "SP" then
             if a_cts02m00[1].endzon <> "NO" and
                a_cts02m00[1].endzon <> "SU" and
                a_cts02m00[1].endzon <> "LE" and
                a_cts02m00[1].endzon <> "OE" and
                a_cts02m00[1].endzon <> "CE" then
                error " Para a Capital favor informar zona NO/SU/LE/OE/CE!"
                next field endzon
             end if
          end if

   before field dddcod
          display by name a_cts02m00[1].dddcod attribute (reverse)

   after  field dddcod
          display by name a_cts02m00[1].dddcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field endzon
          end if

   before field lcltelnum
          display by name a_cts02m00[1].lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name a_cts02m00[1].lcltelnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field dddcod
          end if

   before field lclcttnom
          if d_cts02m00.frmflg = "N" then
#            if g_documento.atdsrvnum is null  and
#               g_documento.atdsrvano is null  and
#               d_cts02m00.c24astcod = "G13"   then
#               next field refatdsrvorg
#            else
                next field camflg
#            end if
          end if
          display by name a_cts02m00[1].lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name a_cts02m00[1].lclcttnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lcltelnum
          end if
          if d_cts02m00.frmflg = "S" then
             let a_cts02m00[1].lgdnom       = a_cts02m00[1].lgdtxt
             let a_cts02m00[1].c24lclpdrcod = 1   # Fora do padrao
          end if

   before field sindat
          display by name d_cts02m00.sindat attribute (reverse)
          if d_cts02m00.c24astcod = "L10" then
             let ws.confirma = cts08g01 ( "A","N","",
                                          "INFORME A DATA E HORA DA LOCALIZACAO  DO",
                                          "VEICULO E NO HISTORICO A DATA E HORA  DO",
                                          "FURTO/ROUBO.")
          end if

   after  field sindat
          display by name d_cts02m00.sindat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lclcttnom
          else
             if d_cts02m00.sindat is null  then
                error " Data do sinistro deve ser informada!"
                next field sindat
             end if

             ##if d_cts02m00.sindat < today - 366 units day  then
             if d_cts02m00.sindat < l_data - 366 units day  then
                let ws.confirma = cts08g01("A","N","","DATA DO SINISTRO INFORMADA E'","ANTERIOR A  1 (UM) ANO !","")
                next field sindat
             end if

             ##if d_cts02m00.sindat > today   then
             if d_cts02m00.sindat > l_data   then
                error " Data do sinistro nao deve ser maior que hoje!"
                next field sindat
             end if
          end if

   before field sinhor
          display by name d_cts02m00.sinhor attribute (reverse)

   after  field sinhor
          display by name d_cts02m00.sinhor

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts02m00.sinhor is null  then
                error " Hora do sinistro deve ser informada!"
                next field sinhor
             end if

             #if d_cts02m00.sindat =  today     and
             if d_cts02m00.sindat =  l_data    and
                d_cts02m00.sinhor <> "00:00"   and
                d_cts02m00.sinhor >  aux_hora  then
                error " Hora do sinistro nao deve ser maior que hora atual!"
                next field sinhor
             end if
          end if

###before field roddantxt
###       if d_cts02m00.frmflg = "S" then
###          let d_cts02m00.roddantxt = "N"
###       end if
###       display by name d_cts02m00.roddantxt attribute (reverse)
###
###after  field roddantxt
###       display by name d_cts02m00.roddantxt
###
###       if fgl_lastkey() <> fgl_keyval("up")   and
###          fgl_lastkey() <> fgl_keyval("left") then
###          if d_cts02m00.roddantxt is null     or
###             d_cts02m00.roddantxt =  " "      then
###             error " Se rodas foram danificadas deve ser informado!"
###             next field roddantxt
###          end if
###       end if

   before field sinvitflg
          if d_cts02m00.frmflg = "S" then
             let d_cts02m00.sinvitflg = "N"
          end if
          display by name d_cts02m00.sinvitflg attribute (reverse)

   after  field sinvitflg
          display by name d_cts02m00.sinvitflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.sinvitflg is null     then
                error " Informe se ha' ou nao vitimas!"
                next field sinvitflg
             end if

             if d_cts02m00.sinvitflg <> "S"      and
                d_cts02m00.sinvitflg <> "N"      then
                error " Ha' vitimas: (S)im ou (N)ao!"
                next field sinvitflg
             end if
          end if

   before field bocflg
          if d_cts02m00.frmflg = "S" then
             let d_cts02m00.bocflg = "N"
          end if
          display by name d_cts02m00.bocflg attribute (reverse)

   after  field bocflg
          display by name d_cts02m00.bocflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.bocflg is null        then
                error " Dados sobre boletim de ocorrencia devem ser informados!"
                next field bocflg
             end if

             if d_cts02m00.bocflg <> "S"         and
                d_cts02m00.bocflg <> "N"         and
                d_cts02m00.bocflg <> "P"         then
                error " Fez B.O.?: (S)im ou (N)ao, (P)esquisa delegacias!"
                next field bocflg
             end if

             if d_cts02m00.bocflg =  "P"         then
                error " Pesquisa Distrito Policial/Batalhoes via CEP!"

                call ctn00c02("SP","SAO PAULO"," "," ")
                     returning ws.endcep, ws.endcepcmp

                if ws.endcep is null then
                   error " Nenhum cep foi selecionado!"
                else
                   call ctn03c01(ws.endcep)
                end if

                next field bocflg
             end if

             if d_cts02m00.bocflg = "S"  then
                call cts02m02(w_cts02m00.bocnum, w_cts02m00.bocemi, w_cts02m00.vcllibflg)
                    returning w_cts02m00.bocnum, w_cts02m00.bocemi, w_cts02m00.vcllibflg

                #Grava no historico :
                let m_flagaux_bo = 'S'

                if g_documento.c24astcod = 'L10' then
                   let m_flagbo = 'Boletim De Ocorrencia: ' , d_cts02m00.bocflg

                   if w_cts02m00.bocnum is null or w_cts02m00.bocnum = ' '   then
                      let m_BO     = 'Numero Do B.O........: ' , 'NAO INFORMADO!'
                   else
                      let m_BO     = 'Numero Do B.O........: ' , w_cts02m00.bocnum
                   end if

                end if

             else
                initialize w_cts02m00.bocnum    to null
                initialize w_cts02m00.bocemi    to null
                initialize w_cts02m00.vcllibflg to null

                let m_flagaux_bo = 'N'

                 if g_documento.c24astcod = 'L10' then
                 # helder 15/03/2011

                   # verifica Cidade de Ocorrencia
                    let m_cidade = 'Cidade...............: ' , a_cts02m00[1].cidnom clipped
                    let m_cidade =  m_cidade clipped
                    let m_estado = 'Estado...............: ' , a_cts02m00[1].ufdcod clipped
                    let m_estado =  m_estado clipped

                    let m_verifica = cta00m06_jit_cidades(a_cts02m00[1].cidnom, a_cts02m00[1].ufdcod)

                    if m_verifica = 1 then

                       #flag
                        if cts08g01("A","S","OFERECA O SERVICO DE JIT PARA "
                                           ,"REALIZACAO DO BOLETIM DE OCORRENCIA."
                                           ,"O SERVICO FOI ACEITO ?"
                                           ,"") = "S"  then
                          let m_flag = 'SIM ACEITOU O BENEF�CIO JIT'
                        else
                          let m_flag = 'NAO ACEITOU O BENEF�CIO JIT'
                        end if

                       # nome e tel
                        call cta02m13_captura_nome_tel()
                             returning m_nome, m_telefone

                       # motivo
                        call ctc26m01()
                             returning g_documento.rcuccsmtvcod

                       # grava flag, nome e tel no historico
                        #let m_mensagem1 = ' ',m_flag clipped,' - ',m_nome clipped,' - ',m_telefone clipped

                       call cts40g03_data_hora_banco(1)
                         returning m_data1, m_hora

                       let m_flagbo = 'Boletim de Ocorrencia: ' , d_cts02m00.bocflg

                       #enviara o email apos a funcao 'grava_dados'

                    end if
                 end if
             end if
          end if



   before field asitipcod
          display by name d_cts02m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts02m00.asitipcod

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts02m00.asitipcod is null  then
                let d_cts02m00.asitipcod = ctn25c00(4)
                call cty26g00_srv_auto(g_documento.ramcod  ## JUNIOR (FORNAX)
				      ,g_documento.succod
				      ,g_documento.aplnumdig
				      ,g_documento.itmnumdig
				      ,g_documento.c24astcod
				      ,d_cts02m00.asitipcod)
			     returning l_flag_limite
	        if l_flag_limite = "S" then
                   let l_confirma = cts08g01('A'  ,'S','' ,'CONSULTE A COORDENACAO, ','PARA ENVIO DE ATENDIMENTO. '  ,'')
		   next field asitipcod
                end if
          end if

                if d_cts02m00.asitipcod is not null  then
                   select asitipabvdes, asiofndigflg, vclcndlclflg
                     into d_cts02m00.asitipabvdes
                         ,w_cts02m00.asiofndigflg
                         ,w_cts02m00.vclcndlclflg
                     from datkasitip
                    where asitipcod = d_cts02m00.asitipcod  and
                          asitipstt = "A"
                   if sqlca.sqlcode <> 0 then
                      error "Falha ao acessar DATKASITIP. Erro: ", sqlca.sqlcode
                      next field asitipcod
                   end if

                   if d_cts02m00.asitipcod = 1 and
                      w_cts02m00.asiofndigflg = "S" then
                      let d_cts02m00.dstflg = "S"
                      display by name d_cts02m00.dstflg
                   end if

                   display by name d_cts02m00.asitipcod
                   display by name d_cts02m00.asitipabvdes

                   if w_cts02m00.vclcndlclflg = "S" then
                      if g_documento.acao = "CON" then
                         let tip_mvt = "A"
                      else
                         let tip_mvt = "M"
                      end if
                      call ctc61m02(g_documento.atdsrvnum,
                                    g_documento.atdsrvano,
                                    tip_mvt)
                      let m_multiplo = false
                       call cta00m06_assistencia_multiplo(d_cts02m00.asitipcod)
                            returning l_confirma
                       if l_confirma = true and
                          g_documento.c24astcod <> 'SAP' and
                          g_documento.c24astcod <> 'M15' and
							            g_documento.c24astcod <> 'M20' and
							            g_documento.c24astcod <> 'M23' and
							            g_documento.c24astcod <> 'M33' then
                          call cts08g01("C","S",' ',"DESEJA ENVIAR SERVICO DE APOIO ?",'','')
                               returning m_multiplo
                            if m_multiplo = "S" then
                                   # Guardada a variavel de assunto anterior
                                   # devido o filtro de grupo de problema
                                   let l_c24astcod = g_documento.c24astcod
                                   let g_documento.c24astcod = 'SAP'
                                   while true
                                   call ctc48m02(l_null) returning am_param.c24pbmgrpcod,
                                                                   am_param.c24pbmgrpdes
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
                                      open ccts02m00007 using am_param.c24pbmcod
                                      fetch ccts02m00007 into am_param.asitipcod
                                   whenever error stop
                                   if sqlca.sqlcode <> 0 then
                                       let l_mensagem = 'Erro < ',sqlca.sqlcode,' > ao buscar tipo de assist�ncia < ',am_param.c24pbmcod,' >'
                                       call errorlog(l_mensagem)
                                   end if
                            end if
                       end if
                      next field dstflg
                   else
                      let l_tmp_flg = ctc61m02_criatmp(2,
                                                       g_documento.atdsrvnum,
                                                       g_documento.atdsrvano)
                      if l_tmp_flg = 1 then
                         error "Problemas com temporaria! <Avise a Informatica>."
                      end if
                   end if
                else
                   next field asitipcod
                end if
             else
                select asitipabvdes, asiofndigflg, vclcndlclflg
                  into d_cts02m00.asitipabvdes
                      ,w_cts02m00.asiofndigflg
                      ,w_cts02m00.vclcndlclflg
                  from datkasitip
                 where asitipcod = d_cts02m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   let d_cts02m00.asitipcod = ctn25c00(4)
                   next field asitipcod
                else
                   display by name d_cts02m00.asitipcod
                end if

                if d_cts02m00.asitipcod = 1 and
                   w_cts02m00.asiofndigflg = "S" then
                   let d_cts02m00.dstflg = "S"
                   display by name d_cts02m00.dstflg
                end if

                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = g_documento.atdsrvorg
                   and asitipcod = d_cts02m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada",
                         " para este servico!"
                   next field asitipcod
                end if
             end if

             if w_cts02m00.vclcndlclflg = "S" then
                if g_documento.acao = "CON" then
                   let tip_mvt = "A"
                else
                   let tip_mvt = "M"
                end if
                call ctc61m02(g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              tip_mvt)
                let m_multiplo = false
                       call cta00m06_assistencia_multiplo(d_cts02m00.asitipcod)
                            returning l_confirma
                       if l_confirma = true and
                          g_documento.c24astcod <> 'SAP' and
                          g_documento.c24astcod <> 'M15' and
							            g_documento.c24astcod <> 'M20' and
							            g_documento.c24astcod <> 'M23' and
							            g_documento.c24astcod <> 'M33' then
                          call cts08g01("C","S",' ',"DESEJA ENVIAR SERVICO DE APOIO ?",'','')
                               returning m_multiplo
                            if m_multiplo = "S" then
                                   # Guardada a variavel de assunto anterior
                                   # devido o filtro de grupo de problema
                                   let l_c24astcod = g_documento.c24astcod
                                   let g_documento.c24astcod = 'SAP'
                                   while true
                                   call ctc48m02(l_null) returning am_param.c24pbmgrpcod,
                                                                               am_param.c24pbmgrpdes
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
                                      open ccts02m00007 using am_param.c24pbmcod
                                      fetch ccts02m00007 into am_param.asitipcod
                                   whenever error stop
                                   if sqlca.sqlcode <> 0 then
                                       let l_mensagem = 'Erro < ',sqlca.sqlcode,' > ao buscar tipo de assist�ncia < ',am_param.c24pbmcod,' >'
                                       call errorlog(l_mensagem)
                                   end if
                            end if
                       end if
             else
                let l_tmp_flg = ctc61m02_criatmp(2,
                                                 g_documento.atdsrvnum,
                                                 g_documento.atdsrvano)
                if l_tmp_flg = 1 then
                   error "Problemas com temporaria! <Avise a Informatica>."
                end if
             end if
             display by name d_cts02m00.asitipabvdes

   before field dstflg
          if d_cts02m00.frmflg = "S" then
             let d_cts02m00.dstflg = "N"
          end if
          if d_cts02m00.asitipcod = 3 then
             let d_cts02m00.dstflg = 'S'
          end if
          display by name d_cts02m00.dstflg attribute (reverse)

   after  field dstflg
          display by name d_cts02m00.dstflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.dstflg is null    then
                error " Local de destino deve ser informado!"
                next field dstflg
             end if
             if d_cts02m00.asitipcod = 3 and
                d_cts02m00.dstflg = "N" then
                error " Local de destino deve ser informado!"
                next field dstflg
             end if

             if d_cts02m00.dstflg <> "S"     and
                d_cts02m00.dstflg <> "N"     then
                error " Existe destino: (S)im ou (N)ao!"
                next field dstflg
             end if
             initialize w_hist.* to null
             if d_cts02m00.dstflg = "S"  then
                let a_cts02m00[3].* = a_cts02m00[2].*
#               error a_cts02m00[3].lclltt , " - ", a_cts02m00[3].lcllgt
                let a_cts02m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                let m_acesso_ind = false
                let m_atdsrvorg = 4
                call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                     returning m_acesso_ind


										if (g_documento.c24astcod = 'M15' or
						           g_documento.c24astcod = 'M20' or
						           g_documento.c24astcod = 'M23' or
						           g_documento.c24astcod = 'M33')then
													call cts08g01("C","S",""," DESTINO SER� O BRASIL ? ","", "")
													   returning l_resposta
											 if l_resposta = "S" then
												  let a_cts02m00[2].ufdcod = ""
												  let a_cts02m00[2].lclidttxt = "BRASIL"
		             		   end if
                     end if

                if m_acesso_ind = false then
                   call cts06g03(2
                                ,m_atdsrvorg
                                ,w_cts02m00.ligcvntip
                                ,aux_today
                                ,aux_hora
                                ,a_cts02m00[2].lclidttxt
                                ,a_cts02m00[2].cidnom
                                ,a_cts02m00[2].ufdcod
                                ,a_cts02m00[2].brrnom
                                ,a_cts02m00[2].lclbrrnom
                                ,a_cts02m00[2].endzon
                                ,a_cts02m00[2].lgdtip
                                ,a_cts02m00[2].lgdnom
                                ,a_cts02m00[2].lgdnum
                                ,a_cts02m00[2].lgdcep
                                ,a_cts02m00[2].lgdcepcmp
                                ,a_cts02m00[2].lclltt
                                ,a_cts02m00[2].lcllgt
                                ,a_cts02m00[2].lclrefptotxt
                                ,a_cts02m00[2].lclcttnom
                                ,a_cts02m00[2].dddcod
                                ,a_cts02m00[2].lcltelnum
                                ,a_cts02m00[2].c24lclpdrcod
                                ,a_cts02m00[2].ofnnumdig
                                ,a_cts02m00[2].celteldddcod
                                ,a_cts02m00[2].celtelnum
                                ,a_cts02m00[2].endcmp
                                ,hist_cts02m00.*
                                ,a_cts02m00[2].emeviacod)
                       returning a_cts02m00[2].lclidttxt
                                ,a_cts02m00[2].cidnom
                                ,a_cts02m00[2].ufdcod
                                ,a_cts02m00[2].brrnom
                                ,a_cts02m00[2].lclbrrnom
                                ,a_cts02m00[2].endzon
                                ,a_cts02m00[2].lgdtip
                                ,a_cts02m00[2].lgdnom
                                ,a_cts02m00[2].lgdnum
                                ,a_cts02m00[2].lgdcep
                                ,a_cts02m00[2].lgdcepcmp
                                ,a_cts02m00[2].lclltt
                                ,a_cts02m00[2].lcllgt
                                ,a_cts02m00[2].lclrefptotxt
                                ,a_cts02m00[2].lclcttnom
                                ,a_cts02m00[2].dddcod
                                ,a_cts02m00[2].lcltelnum
                                ,a_cts02m00[2].c24lclpdrcod
                                ,a_cts02m00[2].ofnnumdig
                                ,a_cts02m00[2].celteldddcod
                                ,a_cts02m00[2].celtelnum
                                ,a_cts02m00[2].endcmp
                                ,ws.retflg
                                ,hist_cts02m00.*
                                ,a_cts02m00[2].emeviacod
                 else
                   call cts06g11(2
                                ,m_atdsrvorg
                                ,w_cts02m00.ligcvntip
                                ,aux_today
                                ,aux_hora
                                ,a_cts02m00[2].lclidttxt
                                ,a_cts02m00[2].cidnom
                                ,a_cts02m00[2].ufdcod
                                ,a_cts02m00[2].brrnom
                                ,a_cts02m00[2].lclbrrnom
                                ,a_cts02m00[2].endzon
                                ,a_cts02m00[2].lgdtip
                                ,a_cts02m00[2].lgdnom
                                ,a_cts02m00[2].lgdnum
                                ,a_cts02m00[2].lgdcep
                                ,a_cts02m00[2].lgdcepcmp
                                ,a_cts02m00[2].lclltt
                                ,a_cts02m00[2].lcllgt
                                ,a_cts02m00[2].lclrefptotxt
                                ,a_cts02m00[2].lclcttnom
                                ,a_cts02m00[2].dddcod
                                ,a_cts02m00[2].lcltelnum
                                ,a_cts02m00[2].c24lclpdrcod
                                ,a_cts02m00[2].ofnnumdig
                                ,a_cts02m00[2].celteldddcod
                                ,a_cts02m00[2].celtelnum
                                ,a_cts02m00[2].endcmp
                                ,hist_cts02m00.*
                                ,a_cts02m00[2].emeviacod)
                       returning a_cts02m00[2].lclidttxt
                                ,a_cts02m00[2].cidnom
                                ,a_cts02m00[2].ufdcod
                                ,a_cts02m00[2].brrnom
                                ,a_cts02m00[2].lclbrrnom
                                ,a_cts02m00[2].endzon
                                ,a_cts02m00[2].lgdtip
                                ,a_cts02m00[2].lgdnom
                                ,a_cts02m00[2].lgdnum
                                ,a_cts02m00[2].lgdcep
                                ,a_cts02m00[2].lgdcepcmp
                                ,a_cts02m00[2].lclltt
                                ,a_cts02m00[2].lcllgt
                                ,a_cts02m00[2].lclrefptotxt
                                ,a_cts02m00[2].lclcttnom
                                ,a_cts02m00[2].dddcod
                                ,a_cts02m00[2].lcltelnum
                                ,a_cts02m00[2].c24lclpdrcod
                                ,a_cts02m00[2].ofnnumdig
                                ,a_cts02m00[2].celteldddcod
                                ,a_cts02m00[2].celtelnum
                                ,a_cts02m00[2].endcmp
                                ,ws.retflg
                                ,hist_cts02m00.*
                                ,a_cts02m00[2].emeviacod
                 end if

                # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                let m_subbairro[2].lclbrrnom = a_cts02m00[2].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts02m00[2].brrnom,
                                               a_cts02m00[2].lclbrrnom)
                     returning a_cts02m00[2].lclbrrnom

                ### PSI216445 - Inicio ###
                let l_oficina.ofnnumdig = a_cts02m00[2].ofnnumdig
                ### PSI216445 - Fim ###

                let a_cts02m00[2].lgdtxt = a_cts02m00[2].lgdtip clipped, " ",
                                           a_cts02m00[2].lgdnom clipped, " ",
                                           a_cts02m00[2].lgdnum using "<<<<#"
#               error a_cts02m00[3].lclltt , " - ", a_cts02m00[3].lcllgt, " -", a_cts02m00[2].lclltt , " - ", a_cts02m00[2].lcllgt
                if a_cts02m00[2].lclltt <> a_cts02m00[3].lclltt or
                   a_cts02m00[2].lcllgt <> a_cts02m00[3].lcllgt or
                   (a_cts02m00[3].lclltt is null                and
                    a_cts02m00[2].lclltt is not null)           or
                   (a_cts02m00[3].lcllgt is null                and
                    a_cts02m00[2].lcllgt is not null) then

                  if g_documento.c24astcod <> 'M15' and
					           g_documento.c24astcod <> 'M20' and
					           g_documento.c24astcod <> 'M23' and
					           g_documento.c24astcod <> 'M33' then
	                   call cts00m33(1,
	                                 a_cts02m00[1].lclltt,
	                                 a_cts02m00[1].lcllgt,
	                                 a_cts02m00[2].lclltt,
	                                 a_cts02m00[2].lcllgt)
                  end if
                end if
                if a_cts02m00[2].cidnom is not null and
                   a_cts02m00[2].ufdcod is not null then
                   call cts14g00 (d_cts02m00.c24astcod,
                                  "","","","",
                                  a_cts02m00[2].cidnom,
                                  a_cts02m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if
  #Humberto
                if a_cts02m00[1].ufdcod = "EX" then
			              let ws.retflg = "S"
			          end if

                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos ou ",
                         "nao preenchidos!"
                   next field dstflg
                end if
                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then
                   let a_cts02m00[2].operacao = "I"
                else
                   select c24lclpdrcod
                     from datmlcl
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano  and
                          c24endtip = 2
                   if sqlca.sqlcode = notfound  then
                      let a_cts02m00[2].operacao = "I"
                   else
                      let a_cts02m00[2].operacao = "M"
                   end if
                end if
                if a_cts02m00[2].ofnnumdig is not null then
                   select ofnstt
                       into ws.ofnstt
                       from sgokofi
                      where ofnnumdig = a_cts02m00[2].ofnnumdig
                   if ws.ofnstt = "C" then
                      # digita o motivo
                      let w_hist.hist1 = "OF CORT MOTIVO:"
                      call cts10m02 (w_hist.*) returning w_hist.*
                   end if
                end if
             else
                if d_cts02m00.asitipcod    = 1   and
                   w_cts02m00.asiofndigflg = "S" then
                   error "Destino e Obrigatorio"
                   next field dstflg
                end if
                initialize a_cts02m00[2].*  to null
                let a_cts02m00[2].operacao = "D"
             end if
          end if

   before field rmcacpflg
          if d_cts02m00.frmflg = "S" then
             let d_cts02m00.rmcacpflg = "N"
          end if
          display by name d_cts02m00.rmcacpflg attribute (reverse)

   after  field rmcacpflg
          display by name d_cts02m00.rmcacpflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.rmcacpflg  is null   then
                error " Acompanha remocao deve ser informado!"
                next field rmcacpflg
             end if

             if d_cts02m00.rmcacpflg <> "S"      and
                d_cts02m00.rmcacpflg <> "N"      then
                error " Acompanha remocao invalida!"
                next field rmcacpflg
             end if
          end if

   before field atdprinvlcod
          if d_cts02m00.frmflg = 'S' then
             if fgl_lastkey() <> fgl_keyval("up") or
                fgl_lastkey() <> fgl_keyval("left") then
                next field imdsrvflg
             end if
          end if
          display by name d_cts02m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts02m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts02m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts02m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts02m00.atdprinvldes

          else
             next field rmcacpflg
          end if

   before field prslocflg
          if g_documento.atdsrvnum  is not null   or
             g_documento.atdsrvano  is not null   then
             ## initialize d_cts02m00.prslocflg  to null
             let d_cts02m00.prslocflg = "N"
             next field atdlibflg
          end if

          display by name d_cts02m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts02m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if ((d_cts02m00.prslocflg  is null)  or
              (d_cts02m00.prslocflg  <> "S"    and
             d_cts02m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts02m00.prslocflg = "S"   then
             call ctn24c01()
                  returning w_cts02m00.atdprscod, w_cts02m00.srrcoddig,
                            w_cts02m00.atdvclsgl, w_cts02m00.socvclcod

             if w_cts02m00.atdprscod  is null then
                error " Faltam dados para prestador no local!"
                next field prslocflg
             end if

             let d_cts02m00.atdlibhor = w_cts02m00.hora
             let d_cts02m00.atdlibdat = w_cts02m00.data
             call cts40g03_data_hora_banco(2)
                  returning l_data, l_hora2
             let w_cts02m00.cnldat    = l_data
             let w_cts02m00.atdfnlhor = l_hora2
             let w_cts02m00.c24opemat = g_issk.funmat
             let w_cts02m00.atdfnlflg = "S"
             let w_cts02m00.atdetpcod =  4
             let d_cts02m00.imdsrvflg = "S"
             let w_cts02m00.atdhorpvt = "00:00"

          else
             initialize w_cts02m00.funmat   ,
                        w_cts02m00.cnldat   ,
                        w_cts02m00.atdfnlhor,
                        w_cts02m00.c24opemat,
                        w_cts02m00.atdfnlflg,
                        w_cts02m00.atdetpcod,
                        w_cts02m00.atdprscod,
                        w_cts02m00.c24nomctt  to null
          end if


   before field atdlibflg
          ##-- inicializar o atdlibflg e passar para o proximo campo
          if d_cts02m00.atdlibflg is null then
             let d_cts02m00.atdlibflg = "S"
             display by name d_cts02m00.atdlibflg
             ##-- inicializar data e hora
             if aux_libant is null then
                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                let aux_libhor           = l_hora2
                let d_cts02m00.atdlibhor = aux_libhor
                let d_cts02m00.atdlibdat = l_data
             end if
             next field imdsrvflg
          end if
          display by name d_cts02m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts02m00.atdfnlflg   = "S"       then
             next field imdsrvflg
          end if

   after  field atdlibflg
          display by name d_cts02m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts02m00.atdlibflg <> "S"  and
                d_cts02m00.atdlibflg <> "N"  then
                error " Envio liberado invalido!"
                next field atdlibflg
             end if

             if d_cts02m00.atdlibflg = "N"  and
                d_cts02m00.frmflg    = "S"  then
                error " Nao e' possivel registrar servico nao liberado",
                      " via formulario!"
                next field atdlibflg
             end if

             if d_cts02m00.atdlibflg = "N"  and
                d_cts02m00.prslocflg = "S"  then
                error " Servico com prestador no local deve ser liberado!"
                next field atdlibflg
             end if

             let w_cts02m00.atdlibflg = d_cts02m00.atdlibflg
             display by name d_cts02m00.atdlibflg

             if aux_libant is null  then
                if w_cts02m00.atdlibflg  =  "S"  then
                   call cts40g03_data_hora_banco(2)
                       returning l_data, l_hora2
                   let aux_libhor           = l_hora2
                   let d_cts02m00.atdlibhor = aux_libhor
                   let d_cts02m00.atdlibdat = l_data
                else
                   let d_cts02m00.atdlibflg = "N"
                   display by name d_cts02m00.atdlibflg
                   initialize d_cts02m00.atdlibhor to null
                   initialize d_cts02m00.atdlibdat to null
                end if
             else
                select atdfnlflg
                  from datmservico
                 where atdsrvnum = g_documento.atdsrvnum  and
                       atdsrvano = g_documento.atdsrvano  and
                       atdfnlflg in ("N","A")

                if sqlca.sqlcode = notfound  then
                   error " Servico ja' concluido nao pode ser alterado!"
                   let m_srv_acionado = true
                   let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                              " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                              "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                   next field atdlibflg
                end if

                if aux_libant = "S"   then
                   if w_cts02m00.atdlibflg = "S" then
                      next field imdsrvflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts02m00.atdlibflg = "N"
                      display by name d_cts02m00.atdlibflg
                      initialize d_cts02m00.atdlibhor to null
                      initialize d_cts02m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      let int_flag = false
                      next field imdsrvflg
                   end if
                else
                   if aux_libant = "N"   then
                      if w_cts02m00.atdlibflg = "N" then
                         next field imdsrvflg
                      else
                         call cts40g03_data_hora_banco(2)
                              returning l_data, l_hora2
                         let aux_libhor           = l_hora2
                         let d_cts02m00.atdlibhor = aux_libhor
                         let d_cts02m00.atdlibdat = l_data
                         next field imdsrvflg
                      end if
                   end if
                end if
             end if
          else
             next field rmcacpflg
          end if

   before field imdsrvflg
          let m_imdsrvflg_ant = d_cts02m00.imdsrvflg
          display by name d_cts02m00.imdsrvflg attribute (reverse)
          
   after  field imdsrvflg
          display by name d_cts02m00.imdsrvflg

          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts02m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if
          
          if (m_cidnom != a_cts02m00[1].cidnom) or
             (m_ufdcod != a_cts02m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts02m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if
          
          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts02m00.imdsrvflg
          end if
          
          if m_cidnom is null then
             let m_cidnom = a_cts02m00[1].cidnom
          end if
          
          if m_ufdcod is null then
             let m_ufdcod = a_cts02m00[1].ufdcod
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
             if d_cts02m00.imdsrvflg is null   or
                d_cts02m00.imdsrvflg =  " "    then
                error " Informacoes sobre servico imediato deve ser informado!"
                next field imdsrvflg
             end if

             if d_cts02m00.imdsrvflg <> "S"    and
                d_cts02m00.imdsrvflg <> "N"    then
                error " Servico imediato: (S)im ou (N)ao!"
                next field imdsrvflg
             end if
             
             # PSI-2013-00440PR
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts02m00.atdfnlflg,
                              d_cts02m00.imdsrvflg,
                              w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg)
                    returning w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg
             else
                # obter a chave de regulacao no AW.
                call cts02m08(w_cts02m00.atdfnlflg,
                              d_cts02m00.imdsrvflg,
                              m_altcidufd,
                              d_cts02m00.prslocflg,
                              w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts02m00[1].cidnom,
                              a_cts02m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts02m00.vclcoddig,
                              w_cts02m00.ctgtrfcod,
                              d_cts02m00.imdsrvflg,
                              a_cts02m00[1].c24lclpdrcod,
                              a_cts02m00[1].lclltt,
                              a_cts02m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts02m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts02m00.atdhorpvt,
                              w_cts02m00.atddatprg,
                              w_cts02m00.atdhorprg,
                              w_cts02m00.atdpvtretflg,
                              d_cts02m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor

                #display 'CTS02M00 RETORNO DE REGULACAO INCLUSAO: '
                #display 'm_altcidufd            : ', m_altcidufd
                #display 'm_agendaw              : ', m_agendaw  
                #display 'w_cts02m00.atdhorpvt   : ', w_cts02m00.atdhorpvt
                #display 'w_cts02m00.atddatprg   : ', w_cts02m00.atddatprg
                #display 'w_cts02m00.atdhorprg   : ', w_cts02m00.atdhorprg
                #display 'w_cts02m00.atdpvtretflg: ', w_cts02m00.atdpvtretflg
                #display 'm_rsrchv               : ', m_rsrchv
                #display 'm_operacao             : ', m_operacao
                #display 'm_altdathor            : ', m_altdathor            
                                
                display by name d_cts02m00.imdsrvflg
                
                if int_flag
                   then
                   let int_flag = false
                   next field imdsrvflg
                   #display 'int_flag do laudo'
                end if
             end if
             
             if d_cts02m00.imdsrvflg = "S"     then
                if w_cts02m00.atdhorpvt is null        then
                   error " Previsao de horas nao informada para servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts02m00.atddatprg   is null        or
                   w_cts02m00.atddatprg        = " "     or
                   w_cts02m00.atdhorprg   is null        then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts02m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts02m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts02m00.atdprinvlcod

                    display by name d_cts02m00.atdprinvlcod
                    display by name d_cts02m00.atdprinvldes

                end if
             end if

             ### PSI216445 - Inicio ###
             # Codigos de assuntos - sinistros com envio de guincho
             # G10 = colisao sem envolvimento de terceiros
             # G11 = colisao terceiro culpado
             # G12 = colisao terceito vitima
             # G13 = colisao com envio de guincho para terceiro vitima
             # G15 = colisao entre segurados
             # G21 = colisao sem definicao de culpa
             if (g_documento.c24astcod = "G10" or g_documento.c24astcod = "G11" or
                g_documento.c24astcod = "G12" or g_documento.c24astcod = "G13"  or
                g_documento.c24astcod = "G15" or g_documento.c24astcod = "G21"  or
                g_documento.c24astcod = "G02") then
          
                # Se for segurado, busca o e-mail
                if (g_documento.c24soltipcod = 1) then
                   whenever error continue
          
                   select segnumdig
                   into l_segurado.segnumdig
                   from abbmdoc
                   where abbmdoc.succod = g_documento.succod and
                         abbmdoc.aplnumdig = g_documento.aplnumdig and
                         abbmdoc.itmnumdig = g_documento.itmnumdig and
                         abbmdoc.dctnumseq = g_funapol.dctnumseq
          
                   if sqlca.sqlcode <> 0 then
                      error "Numero e digito do segurado nao encontrados - Erro: ", sqlca.sqlcode
                      sleep 3
                   else
                      select maides
                      into l_segurado.email_segurado
                      from gsakendmai
                      where segnumdig = l_segurado.segnumdig
          
                      if sqlca.sqlcode <> 0 then
                         error "E-mail do segurado nao encontrado - Erro: ", sqlca.sqlcode
                         sleep 3
                      end if
                   end if
          
                   whenever error stop
                end if # Fim da busca por e-mail de segurado
          
                # Busca as informacoes da oficina escolhida
                whenever error continue
          
                select a.nomrazsoc, # Razao Social
                       a.nomgrr, # Nome de Guerra (ou Nome Fantasia)
                       a.endlgd, # Endereco
                       a.endbrr, # Bairro
                       a.endcep, # Cep
                       a.endcepcmp, # Complemento do Cep
                       a.dddcod, # DDD da Regiao
                       a.telnum1, # Telefone
                       a.endufd, # Estado
                       a.endcid, # Cidade
                       b.ofnblqtip, # Situacao da Oficina
                       b.ofnbrrcod, # Codigo do bairro
                       b.succod, # Codigo da sucursal
                       b.ofnrgicod # Codigo da regiao
                into l_oficina.nomrazsoc, l_oficina.nomgrr, l_oficina.endlgd,
                     l_oficina.endbrr, l_oficina.endcep, l_oficina.endcepcmp,
                     l_oficina.dddcod, l_oficina.telnum1, l_oficina.endufd,
                     l_oficina.endcid, l_oficina.ofnblqtip, l_oficina.ofnbrrcod,
                     l_oficina.succod, l_oficina.ofnrgicod
                from gkpkpos a, sgokofi b
                where pstcoddig = ofnnumdig and ofnnumdig = l_oficina.ofnnumdig
          
                if sqlca.sqlcode <> 0 then
                   error "Informacoes da oficina ", l_oficina.ofnnumdig clipped,
                         " nao encontradas - Erro ", sqlca.sqlcode
                   sleep 3
                   let l_informacoes_oficina = "N"
                else
                   let l_informacoes_oficina = "S"
          
                   if l_oficina.ofnblqtip = 1 then
                      let l_oficina.situacao = "*** OFICINA LOTADA NESTE MOMENTO ***"
                   end if
          
                   if l_oficina.ofnblqtip is null then
                      let l_oficina.situacao = "ATIVA"
                   end if
          
                   select ofcbrrdes
                   into l_oficina.regiao
                   from gkpkbairro
                   where ofnbrrcod = l_oficina.ofnbrrcod and ofnrgicod = l_oficina.ofnrgicod
                         and succod = l_oficina.succod
          
                   if (sqlca.sqlcode <> 0) then
                      let l_oficina.regiao = ""
                   end if
                end if
          
                whenever error stop
          
                if (l_informacoes_oficina = "S") then
                   initialize l_email.* to null
          
                   let l_aux2 = "Oficina: ", l_oficina.nomgrr clipped
                   let l_segurado.email_segurado = fsgoa007e_confirmacao_email ("        Envio das Informa��es da Oficina Escolhida",
                       l_aux2, l_segurado.email_segurado)
          
                   let l_email.sistorig_ = "cts02m00"
                   let l_email.sender_ = "info.oficinas@portoseguro.com.br"
                   let l_email.from_  = "info.oficinas@portoseguro.com.br"
                   let l_email.to_ = l_segurado.email_segurado clipped
                   let l_email.replayto_ = l_segurado.email_segurado clipped
                   let l_email.assunto_ = "Informa��es de Endere�o da oficina"
                   let l_email.mensagem_ = "Dados da oficina escolhida:\n\n"
          
                   if (l_oficina.nomgrr is not null) then
                      let l_email.mensagem_ = l_email.mensagem_ clipped, "Oficina: ", l_oficina.nomgrr clipped, "\n"
                   else
                      let l_email.mensagem_ = l_email.mensagem_ clipped, "Oficina: ", l_oficina.nomrazsoc clipped, "\n"
                   end if
          
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Endereco: ", l_oficina.endlgd clipped, "\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Bairro: ",  l_oficina.endbrr clipped, "\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Regiao: ", l_oficina.regiao clipped, "\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Cep: ", l_oficina.endcep clipped, "-", l_oficina.endcepcmp clipped, "\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, l_oficina.endcid clipped, " - ", l_oficina.endufd clipped, "\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Telefone: (", l_oficina.dddcod clipped, ") ", l_oficina.telnum1 clipped, "\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Situa��o: ", l_oficina.situacao clipped, "\n\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Atenciosamente,\n\n"
                   let l_email.mensagem_ = l_email.mensagem_ clipped, "Porto Seguro"
                   let l_email.sistema_ = "cts02m00"
          
                   # Envia e-mail com as informacoes para o solicitante.
                   if (l_segurado.email_segurado is not null) then
                      let l_resposta_envio = fsgoa007e_enviar_email_mq (l_email.sistorig_ clipped, l_email.sender_ clipped,
                                             l_email.from_ clipped, l_email.to_ clipped,
                                             l_email.replayto_ clipped, l_email.assunto_ clipped,
                                             l_email.mensagem_ clipped, l_email.sistema_ clipped)
                      error l_resposta_envio
                      sleep 3
                   else
                      error "Envio cancelado!"
                      sleep 3
                   end if
                end if
             end if # Fim dos codigos de assuntos
             ### PSI216445 - Fim ###
       
             # PSI-2013-00440PR
             if m_agendaw = false   # regulacao antiga
                then
                ### REGULADOR
                #### CHAMA REGULADOR ####
                if d_cts02m00.prslocflg <> "S"   then
                   if d_cts02m00.imdsrvflg = "S"  then
                      let ws.rglflg = ctc59m02 ( a_cts02m00[1].cidnom,
                                                 a_cts02m00[1].ufdcod,
                                                 g_documento.atdsrvorg,
                                                 d_cts02m00.asitipcod,
                                                 aux_today,
                                                 aux_hora,
                                                 false)          #PSI202363
                   else
                      let ws.rglflg = ctc59m02( a_cts02m00[1].cidnom,
                                                a_cts02m00[1].ufdcod,
                                                g_documento.atdsrvorg,
                                                d_cts02m00.asitipcod,
                                                w_cts02m00.atddatprg,
                                                w_cts02m00.atdhorprg,
                                                false)           #PSI202363
                   end if
                   if ws.rglflg <> 0 then
                      let d_cts02m00.imdsrvflg = "N"
                      call ctc59m03 ( a_cts02m00[1].cidnom,
                                      a_cts02m00[1].ufdcod,
                                      g_documento.atdsrvorg,
                                      d_cts02m00.asitipcod,
                                      aux_today,
                                      aux_hora)
                           returning  w_cts02m00.atddatprg,
                                      w_cts02m00.atdhorprg
                      next field imdsrvflg
                   end if
                   if g_documento.atdsrvnum is not null  and
                      g_documento.atdsrvano is not null  then
   
                      # Para abater regulador
                      let ws.rglflg = ctc59m03_regulador( g_documento.atdsrvnum,
                                                          g_documento.atdsrvano)
                   end if
                end if
             end if  # PSI-2013-00440PR
          else  # fgl_keyval
             if d_cts02m00.frmflg = 'S' then
                next field asitipcod
             end if
          end if

   on key (interrupt)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         let ws.confirma = cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")

         if ws.confirma  =  "S"   then
            let l_tmp_flg = ctc61m02_criatmp(2,
                                             g_documento.atdsrvnum,
                                             g_documento.atdsrvano)
            if l_tmp_flg = 1 then
               error "Problemas na tabela temporaria!"
            end if

            let int_flag = true
            exit input
         end if
      else
         if m_outrolaudo = 1 then   #se estava sendo exibido um segundo laudo
            let m_outrolaudo = 0    #prepara dados para voltar ao laudo principal
            let g_documento.acao = f4.acao
            let g_documento.atdsrvnum = f4.atdsrvnum
            let g_documento.atdsrvano = f4.atdsrvano
            initialize f4.* to null
            call consulta_cts02m00()
            call cts02m00_display()

            call cts02m00_ver_uso(l_atdsrvnum,l_atdsrvano,1)
                 returning l_msg
         else
            exit input
         end if
      end if

   on key (F1)
      if d_cts02m00.c24astcod is not null then
         call ctc58m00_vis(d_cts02m00.c24astcod)
      end if

   on key (F2)
      if g_documento.atdsrvnum is not null  and
         g_documento.atdsrvano is not null  then

         ###################################################
         # Checa se existe tela servico JIT ja aberta
         ###################################################
         whenever error continue
            open window cts26m00 at 04,02 with form "cts26m00"
                                attribute(form line 1)
            if status = 0     then
               let erros_chk = "N"
               close window cts26m00
            else
               let erros_chk = "S"
            end if
         whenever error stop

         if erros_chk = "N"  then
         select atdsrvnum,
                atdsrvano
           into ws.jitatdsrvnum,
                ws.jitatdsrvano
           from datmsrvjit
          where refatdsrvnum = g_documento.atdsrvnum
            and refatdsrvano = g_documento.atdsrvano

         if sqlca.sqlcode = 0 then

            let ws.auxatdsrvnum = g_documento.atdsrvnum
            let ws.auxatdsrvano = g_documento.atdsrvano
            let ws.auxatdsrvorg = g_documento.atdsrvorg

            let g_documento.atdsrvnum = ws.jitatdsrvnum
            let g_documento.atdsrvano = ws.jitatdsrvano

            let ws.retflg = cts04g00('cts02m00')

            let g_documento.atdsrvnum = ws.auxatdsrvnum
            let g_documento.atdsrvano = ws.auxatdsrvano
            let g_documento.atdsrvorg = ws.auxatdsrvorg

         else
             error "Remocao sem servico de JIT !"

         end if
         end if
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

   on key (F4)
      if m_outrolaudo = 1 or
         g_documento.acao <> "CON" then
         error "Nao e possivel visualizar outros laudos no momento."
      else
         #verificar se laudo � um laudo de apoio ou se laudo tem servicos de apoio
         call cts37g00_existeServicoApoio(g_documento.atdsrvnum, g_documento.atdsrvano)
              returning l_tipolaudo
         if l_tipolaudo <> 1 then
            if l_tipolaudo = 2 then  #servico tem servicos de apoio
               #listar laudos de apoio e selecionar 1 deles
               call cts37g00_buscaServicoApoio(2, g_documento.atdsrvnum, g_documento.atdsrvano)
                    returning l_atdsrvnum, l_atdsrvano
            end if
            if l_tipolaudo = 3 then  #servico e um servico de apoio
               #buscar numero ano servico laudo original
               call cts37g00_buscaServicoOriginal(g_documento.atdsrvnum, g_documento.atdsrvano)
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
                   #salva informa��es laudo original
                   let f4.acao = g_documento.acao
                   let f4.atdsrvnum = g_documento.atdsrvnum
                   let f4.atdsrvano = g_documento.atdsrvano
                   #atualiza informacoes para novo laudo
                   let g_documento.acao = "CON"
                   let g_documento.atdsrvnum = l_atdsrvnum
                   let g_documento.atdsrvano = l_atdsrvano
                   #chama funcao consulta para novo laudo
                   let m_outrolaudo = 1
                   call consulta_cts02m00()
                   call cts02m00_display()
               end if

            end if
         else
            error "Servico nao ligado a servicos de apoio"
         end if
      end if


   on key (F5)
{
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         if g_documento.ramcod = 31    or
            g_documento.ramcod = 531  then
            call cta01m00()
         else
            call cta01m20()
         end if
      else
         if g_documento.prporg    is not null  and
            g_documento.prpnumdig is not null  then
            let ws.prpflg = opacc149(g_documento.prporg, g_documento.prpnumdig)
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
      if g_documento.atdsrvnum is null  then
         call cts10m02 (hist_cts02m00.*) returning hist_cts02m00.*
#        error " Acesso ao historico somente c/ cadastramento do servico!"
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat        , aux_today  ,aux_hora)
      end if

   on key (F7)
      call ctx14g00("Funcoes","Impressao|Condutor|Caminhao|Distancia|Veiculo")
           returning ws.opcao,
                     ws.opcaodes
      case ws.opcao
         when 1  ### Impressao
            if g_documento.atdsrvnum is null  then
               error " Impressao somente com cadastramento do servico!"
            else
               call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
            end if

         when 2  ### Condutor
            if g_documento.succod    is not null  and
               g_documento.ramcod    is not null  and
               g_documento.aplnumdig is not null  then
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
                     if g_documento.cndslcflg = "S"  then
                        call cta07m00(g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig, "I")
                     else
                        call cta07m00(g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig, "C")
                     end if
                  else
                     call cta07m00(g_documento.succod,
                                   g_documento.aplnumdig,
                                   g_documento.itmnumdig, "C")
                  end if
               else
                   error "Docto nao possui clausula 18 !"
               end if
            else
               error "Condutor so' com Documento localizado!"
            end if

         when 3  ### Caminhao
            if d_cts02m00.camflg = "S"  then
               call cts02m01(w_cts02m00.ctgtrfcod,
                             g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             w_cts02m00.vclcrgflg ,
                             w_cts02m00.vclcrgpso ,
                             w_cts02m00.vclcamtip ,
                             w_cts02m00.vclcrcdsc )
                   returning w_cts02m00.vclcrgflg ,
                             w_cts02m00.vclcrgpso ,
                             w_cts02m00.vclcamtip ,
                             w_cts02m00.vclcrcdsc

                if w_cts02m00.vclcamtip  is null   and
                   w_cts02m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                end if
            end if
          when 4   #### Distancia QTH-QTI
             call cts00m33(1,
                           a_cts02m00[1].lclltt,
                           a_cts02m00[1].lcllgt,
                           a_cts02m00[2].lclltt,
                           a_cts02m00[2].lcllgt)

          when 5   #### Apresentar Locais e as condicoes do veiculo
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
                call ctc61m02(g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              "A")

                let l_tmp_flg = ctc61m02_criatmp(2,
                                                 g_documento.atdsrvnum,
                                                 g_documento.atdsrvano)

                if l_tmp_flg = 1 then
                   error "Problemas com temporaria! <Avise a Informatica> "
                end if
             end if

      end case

   on key (F8)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts02m00.dstflg = "N"  then
            error " Nao foi informado destino para este servico!"
         else
            let a_cts02m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
            let m_acesso_ind = false
            let m_atdsrvorg = 4
            call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                 returning m_acesso_ind

            #Projeto alteracao cadastro de destino
            if g_documento.acao = "ALT" then

               call cts02m00_bkp_info_dest(1, hist_cts02m00.*)
                  returning hist_cts02m00.*

            end if

            if m_acesso_ind = false then
               call cts06g03(2
                            ,m_atdsrvorg
                            ,w_cts02m00.ligcvntip
                            ,aux_today
                            ,aux_hora
                            ,a_cts02m00[2].lclidttxt
                            ,a_cts02m00[2].cidnom
                            ,a_cts02m00[2].ufdcod
                            ,a_cts02m00[2].brrnom
                            ,a_cts02m00[2].lclbrrnom
                            ,a_cts02m00[2].endzon
                            ,a_cts02m00[2].lgdtip
                            ,a_cts02m00[2].lgdnom
                            ,a_cts02m00[2].lgdnum
                            ,a_cts02m00[2].lgdcep
                            ,a_cts02m00[2].lgdcepcmp
                            ,a_cts02m00[2].lclltt
                            ,a_cts02m00[2].lcllgt
                            ,a_cts02m00[2].lclrefptotxt
                            ,a_cts02m00[2].lclcttnom
                            ,a_cts02m00[2].dddcod
                            ,a_cts02m00[2].lcltelnum
                            ,a_cts02m00[2].c24lclpdrcod
                            ,a_cts02m00[2].ofnnumdig
                            ,a_cts02m00[2].celteldddcod
                            ,a_cts02m00[2].celtelnum
                            ,a_cts02m00[2].endcmp
                            ,hist_cts02m00.*
                            ,a_cts02m00[2].emeviacod )
                   returning a_cts02m00[2].lclidttxt
                            ,a_cts02m00[2].cidnom
                            ,a_cts02m00[2].ufdcod
                            ,a_cts02m00[2].brrnom
                            ,a_cts02m00[2].lclbrrnom
                            ,a_cts02m00[2].endzon
                            ,a_cts02m00[2].lgdtip
                            ,a_cts02m00[2].lgdnom
                            ,a_cts02m00[2].lgdnum
                            ,a_cts02m00[2].lgdcep
                            ,a_cts02m00[2].lgdcepcmp
                            ,a_cts02m00[2].lclltt
                            ,a_cts02m00[2].lcllgt
                            ,a_cts02m00[2].lclrefptotxt
                            ,a_cts02m00[2].lclcttnom
                            ,a_cts02m00[2].dddcod
                            ,a_cts02m00[2].lcltelnum
                            ,a_cts02m00[2].c24lclpdrcod
                            ,a_cts02m00[2].ofnnumdig
                            ,a_cts02m00[2].celteldddcod
                            ,a_cts02m00[2].celtelnum
                            ,a_cts02m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts02m00.*
                            ,a_cts02m00[2].emeviacod
            else
               call cts06g11(2
                            ,m_atdsrvorg
                            ,w_cts02m00.ligcvntip
                            ,aux_today
                            ,aux_hora
                            ,a_cts02m00[2].lclidttxt
                            ,a_cts02m00[2].cidnom
                            ,a_cts02m00[2].ufdcod
                            ,a_cts02m00[2].brrnom
                            ,a_cts02m00[2].lclbrrnom
                            ,a_cts02m00[2].endzon
                            ,a_cts02m00[2].lgdtip
                            ,a_cts02m00[2].lgdnom
                            ,a_cts02m00[2].lgdnum
                            ,a_cts02m00[2].lgdcep
                            ,a_cts02m00[2].lgdcepcmp
                            ,a_cts02m00[2].lclltt
                            ,a_cts02m00[2].lcllgt
                            ,a_cts02m00[2].lclrefptotxt
                            ,a_cts02m00[2].lclcttnom
                            ,a_cts02m00[2].dddcod
                            ,a_cts02m00[2].lcltelnum
                            ,a_cts02m00[2].c24lclpdrcod
                            ,a_cts02m00[2].ofnnumdig
                            ,a_cts02m00[2].celteldddcod
                            ,a_cts02m00[2].celtelnum
                            ,a_cts02m00[2].endcmp
                            ,hist_cts02m00.*
                            ,a_cts02m00[2].emeviacod )
                   returning a_cts02m00[2].lclidttxt
                            ,a_cts02m00[2].cidnom
                            ,a_cts02m00[2].ufdcod
                            ,a_cts02m00[2].brrnom
                            ,a_cts02m00[2].lclbrrnom
                            ,a_cts02m00[2].endzon
                            ,a_cts02m00[2].lgdtip
                            ,a_cts02m00[2].lgdnom
                            ,a_cts02m00[2].lgdnum
                            ,a_cts02m00[2].lgdcep
                            ,a_cts02m00[2].lgdcepcmp
                            ,a_cts02m00[2].lclltt
                            ,a_cts02m00[2].lcllgt
                            ,a_cts02m00[2].lclrefptotxt
                            ,a_cts02m00[2].lclcttnom
                            ,a_cts02m00[2].dddcod
                            ,a_cts02m00[2].lcltelnum
                            ,a_cts02m00[2].c24lclpdrcod
                            ,a_cts02m00[2].ofnnumdig
                            ,a_cts02m00[2].celteldddcod
                            ,a_cts02m00[2].celtelnum
                            ,a_cts02m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts02m00.*
                            ,a_cts02m00[2].emeviacod
               end if

               #Projeto alteracao cadastro de destino
               let m_grava_hist = false

               if g_documento.acao = "ALT" then

                  call cts02m00_verifica_tipo_atendim()
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
                           call cts02m00_verifica_op_ativa()
                              returning l_status

                           if l_status then

                              # ---> SALVA O NOME DO SEGURADO
                              let d_cts02m00.nom = l_salva_nom
                              display by name d_cts02m00.nom

                              error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                              error " Servico ja' acionado nao pode ser alterado!"
                              let m_srv_acionado = true
                              let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                         " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                         "E INFORME AO  ** CONTROLE DE TRAFEGO **")

                              ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                              if m_agendaw = false   # regulacao antiga
                                 then
                                 call cts02m03(w_cts02m00.atdfnlflg,
                                               d_cts02m00.imdsrvflg,
                                               w_cts02m00.atdhorpvt,
                                               w_cts02m00.atddatprg,
                                               w_cts02m00.atdhorprg,
                                               w_cts02m00.atdpvtretflg)
                                     returning w_cts02m00.atdhorpvt,
                                               w_cts02m00.atddatprg,
                                               w_cts02m00.atdhorprg,
                                             w_cts02m00.atdpvtretflg
                              else
                                 call cts02m08(w_cts02m00.atdfnlflg,
                                               d_cts02m00.imdsrvflg,
                                               m_altcidufd,
                                               d_cts02m00.prslocflg,
                                               w_cts02m00.atdhorpvt,
                                               w_cts02m00.atddatprg,
                                               w_cts02m00.atdhorprg,
                                               w_cts02m00.atdpvtretflg,
                                               m_rsrchvant,
                                               m_operacao,
                                               "",
                                               a_cts02m00[1].cidnom,
                                               a_cts02m00[1].ufdcod,
                                               "",   # codigo de assistencia, nao existe no Ct24h
                                               d_cts02m00.vclcoddig,
                                               w_cts02m00.ctgtrfcod,
                                               d_cts02m00.imdsrvflg,
                                               a_cts02m00[1].c24lclpdrcod,
                                               a_cts02m00[1].lclltt,
                                               a_cts02m00[1].lcllgt,
                                               g_documento.ciaempcod,
                                               g_documento.atdsrvorg,
                                               d_cts02m00.asitipcod,
                                               "",   # natureza somente RE
                                               "")   # sub-natureza somente RE
                                     returning w_cts02m00.atdhorpvt,
                                               w_cts02m00.atddatprg,
                                               w_cts02m00.atdhorprg,
                                               w_cts02m00.atdpvtretflg,
                                               d_cts02m00.imdsrvflg,
                                               m_rsrchv,
                                               m_operacao,
                                               m_altdathor
                              end if  
                              ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)              
                              
                              if d_cts02m00.frmflg = "S" then
                                 call cts11g00(w_cts02m00.lignum)
                                 let int_flag = true
                              end if

                              call cts02m00_bkp_info_dest(2, hist_cts02m00.*)
                                 returning hist_cts02m00.*

                              exit input

                           else

                              let m_grava_hist   = true
                              let m_srv_acionado = false

                              let m_subbairro[2].lclbrrnom = a_cts02m00[2].lclbrrnom
                              call cts06g10_monta_brr_subbrr(a_cts02m00[2].brrnom,
                                                             a_cts02m00[2].lclbrrnom)
                                 returning a_cts02m00[2].lclbrrnom

                              let a_cts02m00[2].lgdtxt = a_cts02m00[2].lgdtip clipped, " ",
                                                         a_cts02m00[2].lgdnom clipped, " ",
                                                         a_cts02m00[2].lgdnum using "<<<<#"

                              if a_cts02m00[2].lclltt <> a_cts02m00[3].lclltt or
                                 a_cts02m00[2].lcllgt <> a_cts02m00[3].lcllgt or
                                 (a_cts02m00[3].lclltt is null                and
                                  a_cts02m00[2].lclltt is not null)           or
                                 (a_cts02m00[3].lcllgt is null                and
                                  a_cts02m00[2].lcllgt is not null)           then

                                 if g_documento.c24astcod <> 'M15' and
                                    g_documento.c24astcod <> 'M20' and
                                    g_documento.c24astcod <> 'M23' and
                                    g_documento.c24astcod <> 'M33' then
	                            call cts00m33(1,
	                                          a_cts02m00[1].lclltt,
	                                          a_cts02m00[1].lcllgt,
	                                          a_cts02m00[2].lclltt,
	                                          a_cts02m00[2].lcllgt)
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
                               if w_cts02m00.socvclcod is null then
                                  select socvclcod
                                    into w_cts02m00.socvclcod
                                    from datmsrvacp acp
                                   where acp.atdsrvnum = g_documento.atdsrvnum
                                     and acp.atdsrvano = g_documento.atdsrvano
                                     and acp.atdsrvseq = (select max(atdsrvseq)
                                                            from datmsrvacp acp1
                                                           where acp1.atdsrvnum = acp.atdsrvnum
                                                             and acp1.atdsrvano = acp.atdsrvano)
                               end if

                               #display 'w_cts02m00.socvclcod ', w_cts02m00.socvclcod

                                    select mdtcod
                                    into m_mdtcod
                                    from datkveiculo
                                    where socvclcod = w_cts02m00.socvclcod

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
                                    and cpocod = w_cts02m00.vclcorcod

                                    select empnom
                                    into l_ciaempnom
                                    from gabkemp
                                    where empcod  = g_documento.ciaempcod


                                    whenever error stop

                                    let l_dtalt = today
                                    let l_hralt = current
                                    let l_lgdtxtcl = a_cts02m00[2].lgdtip clipped, " ",
                                                     a_cts02m00[2].lgdnom clipped, " ",
                                                     a_cts02m00[2].lgdnum using "<<<<#", " ",
                                                     a_cts02m00[2].endcmp clipped


                                    let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                                  l_ciaempnom clipped,
                                                  '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             		  	    let l_msgaltend = l_texto clipped
                                      ," QRU: ", m_atdsrvorg using "&&"
                                           ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                           ,"-", g_documento.atdsrvano using "&&"
                                      ," QTR: ", l_dtalt, " ", l_hralt
                                      ," QNC: ", d_cts02m00.nom             clipped, " "
                                               , d_cts02m00.vcldes          clipped, " "
                                               , d_cts02m00.vclanomdl       clipped, " "
                                      ," QNR: ", d_cts02m00.vcllicnum       clipped, " "
                                               , l_vclcordes       clipped, " "
                                      ," QTI: ", a_cts02m00[2].lclidttxt       clipped, " - "
                                               , l_lgdtxtcl                 clipped, " - "
                                               , a_cts02m00[2].brrnom          clipped, " - "
                                               , a_cts02m00[2].cidnom          clipped, " - "
                                               , a_cts02m00[2].ufdcod          clipped, " "
                                      ," Ref: ", a_cts02m00[2].lclrefptotxt    clipped, " "
                                     ," Resp: ", a_cts02m00[2].lclcttnom       clipped, " "
                                     ," Tel: (", a_cts02m00[2].dddcod          clipped, ") "
                                               , a_cts02m00[2].lcltelnum       clipped, " "
                                    ," Acomp: ", d_cts02m00.rmcacpflg          clipped, "#"


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

                           call cts02m00_bkp_info_dest(2, hist_cts02m00.*)
                              returning hist_cts02m00.*

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

               if a_cts02m00[2].cidnom is not null and
                  a_cts02m00[2].ufdcod is not null then
                  call cts14g00 (d_cts02m00.c24astcod,
                                 "","","","",
                                 a_cts02m00[2].cidnom,
                                 a_cts02m00[2].ufdcod,
                                 "S",
                                 ws.dtparam)
               end if

         end if
      end if

   on key (F9)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         if cpl_atdsrvnum is not null  or
            cpl_atdsrvano is not null  then
            error " Servico ja' selecionado para copia!"
         else
            call cts16g00 (g_documento.succod   ,
                           g_documento.ramcod   ,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig,
                           4                    ,  # atdsrvorg (REMOCAO)
                           d_cts02m00.vcllicnum ,
                           7, "")  # nr dias p/pesquisa
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
                             returning a_cts02m00[1].lclidttxt
                                      ,a_cts02m00[1].lgdtip
                                      ,a_cts02m00[1].lgdnom
                                      ,a_cts02m00[1].lgdnum
                                      ,a_cts02m00[1].lclbrrnom
                                      ,a_cts02m00[1].brrnom
                                      ,a_cts02m00[1].cidnom
                                      ,a_cts02m00[1].ufdcod
                                      ,a_cts02m00[1].lclrefptotxt
                                      ,a_cts02m00[1].endzon
                                      ,a_cts02m00[1].lgdcep
                                      ,a_cts02m00[1].lgdcepcmp
                                      ,a_cts02m00[1].lclltt
                                      ,a_cts02m00[1].lcllgt
                                      ,a_cts02m00[1].dddcod
                                      ,a_cts02m00[1].lcltelnum
                                      ,a_cts02m00[1].lclcttnom
                                      ,a_cts02m00[1].c24lclpdrcod
                                      ,a_cts02m00[1].celteldddcod
                                      ,a_cts02m00[1].celtelnum
                                      ,a_cts02m00[1].endcmp
                                      ,ws.codigosql
                                      ,a_cts02m00[1].emeviacod

               if ws.codigosql <> 0  then
                  error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                  prompt "" for char prompt_key
                  initialize hist_cts02m00.*  to null
                  return hist_cts02m00.*
               end if

               select ofnnumdig into a_cts02m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = g_documento.atdsrvano
                  and atdsrvnum = g_documento.atdsrvnum
                  and c24endtip = 1

               let a_cts02m00[1].lgdtxt = a_cts02m00[1].lgdtip clipped, " ",
                                          a_cts02m00[1].lgdnom clipped, " ",
                                          a_cts02m00[1].lgdnum using "<<<<#"

               #-----------------------------------------------------------
               # Informacoes do local de destino
               #-----------------------------------------------------------
               call ctx04g00_local_gps(cpl_atdsrvnum,
                                       cpl_atdsrvano,
                                       2)
                             returning a_cts02m00[2].lclidttxt
                                      ,a_cts02m00[2].lgdtip
                                      ,a_cts02m00[2].lgdnom
                                      ,a_cts02m00[2].lgdnum
                                      ,a_cts02m00[2].lclbrrnom
                                      ,a_cts02m00[2].brrnom
                                      ,a_cts02m00[2].cidnom
                                      ,a_cts02m00[2].ufdcod
                                      ,a_cts02m00[2].lclrefptotxt
                                      ,a_cts02m00[2].endzon
                                      ,a_cts02m00[2].lgdcep
                                      ,a_cts02m00[2].lgdcepcmp
                                      ,a_cts02m00[2].lclltt
                                      ,a_cts02m00[2].lcllgt
                                      ,a_cts02m00[2].dddcod
                                      ,a_cts02m00[2].lcltelnum
                                      ,a_cts02m00[2].lclcttnom
                                      ,a_cts02m00[2].c24lclpdrcod
                                      ,a_cts02m00[2].celteldddcod
                                      ,a_cts02m00[2].celtelnum
                                      ,a_cts02m00[2].endcmp
                                      ,ws.codigosql
                                      ,a_cts02m00[2].emeviacod


               select ofnnumdig into a_cts02m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = g_documento.atdsrvano
                  and atdsrvnum = g_documento.atdsrvnum
                  and c24endtip = 1

               if ws.codigosql = notfound   then
                  let d_cts02m00.dstflg = "N"
               else
                  if ws.codigosql = 0   then
                     let d_cts02m00.dstflg = "S"
                  else
                     error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
                     prompt "" for char prompt_key
                     initialize hist_cts02m00.*  to null
                     return hist_cts02m00.*
                  end if
               end if

               let a_cts02m00[2].lgdtxt = a_cts02m00[2].lgdtip clipped, " ",
                                          a_cts02m00[2].lgdnom clipped, " ",
                                          a_cts02m00[2].lgdnum using "<<<<#"

               call cts16g00_atendimento(cpl_atdsrvnum, cpl_atdsrvano)
                               returning d_cts02m00.nom,
                                         w_cts02m00.vclcorcod,
                                         d_cts02m00.vclcordes

               if cpl_atdsrvorg = 4 then
                  call cts16g00_complemento(cpl_atdsrvnum, cpl_atdsrvano)
                                  returning w_cts02m00.sinvitflg,
                                            w_cts02m00.bocnum,
                                            w_cts02m00.bocemi,
                                            w_cts02m00.vcllibflg,
                                            w_cts02m00.roddantxt,
                                            w_cts02m00.sindat,
                                            d_cts02m00.sinhor

                  let d_cts02m00.sinvitflg = w_cts02m00.sinvitflg
                  let d_cts02m00.roddantxt = w_cts02m00.roddantxt
                  let d_cts02m00.sindat    = w_cts02m00.sindat
               end if

               call cts02m00_display()

               display by name a_cts02m00[1].lgdtxt
               display by name a_cts02m00[1].lclbrrnom
               display by name a_cts02m00[1].endzon
               display by name a_cts02m00[1].cidnom
               display by name a_cts02m00[1].ufdcod
               display by name a_cts02m00[1].lclrefptotxt
               display by name a_cts02m00[1].lclcttnom
               display by name a_cts02m00[1].dddcod
               display by name a_cts02m00[1].lcltelnum
               display by name a_cts02m00[1].celteldddcod
               display by name a_cts02m00[1].celtelnum
               display by name a_cts02m00[1].endcmp
            end if
         end if
      else
         if d_cts02m00.atdlibflg = "N"   then
            error " Servico nao liberado!"
         else
             call cta00m06_acionamento(g_issk.dptsgl)
                 returning l_acesso
            if l_acesso = true then
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if

            open c_cts02m00_003 using g_documento.atdsrvnum,
                                    g_documento.atdsrvano

            fetch c_cts02m00_003 into l_atdfnlflg,
                                    l_acnsttflg,
                                    l_atdlibflg
            close c_cts02m00_003

            let m_mensagem = "CTS02M00 - Apos voltar f9: ",
                              g_documento.atdsrvnum, "-",
                              g_documento.atdsrvano,
                             "|atdfnlflg: ", l_atdfnlflg,
                             "|acnsttflg: ", l_acnsttflg,
                             "|atdlibflg: ", l_atdlibflg  clipped
            call errorlog(m_mensagem)
         end if
      end if

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts02m00.* to null
 end if

return hist_cts02m00.*

end function  ###  input_cts02m00


#---------------------------------------------------------------
 function cts02m00_cambio(param)
#---------------------------------------------------------------

 define param        record
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig
 end record

 define ws           record
    atdvcltip        like datmservico.atdvcltip,
    vclatmflg        like abbmveic.vclatmflg   ,
    vclchsfnl        like avlmveic.vclchsfnl   ,
    vcllicnum        like avlmveic.vcllicnum   ,
    vclcoddig        like avlmveic.vclcoddig   ,
    vstnumdig        like avlmlaudo.vstnumdig  ,
    vstdat           like avlmlaudo.vstdat     ,
    vsthor           like avlmlaudo.vsthor
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  ws.*  to  null

 initialize ws.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return ws.atdvcltip
 end if

#---------------------------------------------------------------
# Obtem a ULTIMA SITUACAO do veiculo
#---------------------------------------------------------------

 call f_funapol_ultima_situacao
      (param.succod, param.aplnumdig, param.itmnumdig)
      returning g_funapol.*

#---------------------------------------------------------------
# Verifica se veiculo possui CAMBIO AUTOMATICO/HIDRAMATICO
#---------------------------------------------------------------

 select vclatmflg   , vclcoddig,
        vcllicnum   , vclchsfnl
   into ws.vclatmflg, ws.vclcoddig,
        ws.vcllicnum, ws.vclchsfnl
   from abbmveic
  where succod    = param.succod     and
        aplnumdig = param.aplnumdig  and
        itmnumdig = param.itmnumdig  and
        dctnumseq = g_funapol.vclsitatu

 if ws.vclatmflg = "S"  then
    let ws.atdvcltip = 1
    return ws.atdvcltip
 end if

#---------------------------------------------------------------
# Obtem o ULTIMO NUMERO DE VISTORIA atraves da Vistoria Previa
#---------------------------------------------------------------

 initialize ws.vstnumdig to null

 if ( ws.vclchsfnl is null or ws.vclchsfnl = " " ) and
    ( ws.vcllicnum is null or ws.vcllicnum = " " ) then
    return ws.atdvcltip
 else
    declare c_cts02m00_004 cursor for
       select avlmlaudo.vstdat ,
              avlmlaudo.vsthor ,
              avlmlaudo.vstnumdig
         from avlmveic, avlmlaudo
        where avlmveic.vclchsfnl  = ws.vclchsfnl       and
              avlmveic.vcllicnum  = ws.vcllicnum       and
              avlmveic.vclcoddig  = ws.vclcoddig       and
              avlmlaudo.vstnumdig = avlmveic.vstnumdig and
              (vstldostt = 0 or vstldostt is null)
        order by 1 desc, 2 desc

    foreach c_cts02m00_004 into ws.vstdat, ws.vsthor, ws.vstnumdig
        exit foreach
    end foreach
 end if

 if ws.vstnumdig = 0  or  ws.vstnumdig is null  then
    initialize ws.atdvcltip to null
 else
#---------------------------------------------------------------
# Verifica nos ACESSORIOS da V.P. se existe cambio hidramatico
#---------------------------------------------------------------
    select vstnumdig from avlmaces
     where vstnumdig = ws.vstnumdig and
           asstip    = 1            and
           asscoddig = 175

    if sqlca.sqlcode <> 0  then
       select vstnumdig from avlmaces
        where vstnumdig = ws.vstnumdig and
              asstip    = 1            and
              asscoddig = 2518

       if sqlca.sqlcode <> 0  then
          initialize ws.atdvcltip to null
       else
          let ws.atdvcltip = 1
       end if
    end if
 end if

 return ws.atdvcltip

end function  ###  cts02m00_cambio

#--------------------------#
function cts02m00_display()
#--------------------------#

    display by name d_cts02m00.servico
    display by name d_cts02m00.c24solnom attribute (reverse)
    display by name d_cts02m00.nom
    display by name d_cts02m00.doctxt
    display by name d_cts02m00.corsus
    display by name d_cts02m00.cornom
    display by name d_cts02m00.cvnnom    attribute (reverse)
    display by name d_cts02m00.vclcoddig
    display by name d_cts02m00.vcldes
    display by name d_cts02m00.vclanomdl
    display by name d_cts02m00.vcllicnum
    display by name d_cts02m00.vclcordes
    display by name d_cts02m00.c24astcod
    display by name d_cts02m00.c24astdes
    display by name d_cts02m00.refasstxt
    display by name d_cts02m00.camflg
    display by name d_cts02m00.refatdsrvtxt
    display by name d_cts02m00.refatdsrvorg
    display by name d_cts02m00.refatdsrvnum
    display by name d_cts02m00.refatdsrvano
    display by name d_cts02m00.sindat
    display by name d_cts02m00.sinhor
    display by name d_cts02m00.sinvitflg
    display by name d_cts02m00.bocflg
    display by name d_cts02m00.dstflg
    display by name d_cts02m00.asitipcod
    display by name d_cts02m00.asitipabvdes
    display by name d_cts02m00.rmcacpflg
    display by name d_cts02m00.imdsrvflg
    display by name d_cts02m00.prsloccab
    display by name d_cts02m00.prslocflg
    display by name d_cts02m00.atdprinvlcod
    display by name d_cts02m00.atdprinvldes
    display by name d_cts02m00.atdlibflg
    display by name d_cts02m00.frmflg
    display by name d_cts02m00.atdtxt
    display by name d_cts02m00.atdlibdat
    display by name d_cts02m00.atdlibhor

end function

function cts02m00_ver_uso(l_atdsrvnum, l_atdsrvano, l_flag)

   define l_atdsrvnum     like datmservico.atdsrvnum,
          l_atdsrvano     like datmservico.atdsrvano,
          l_resultado     smallint,
          l_mensagem      char(50),
          l_c24opemat     like datmservico.c24opemat,
          l_funnom        like isskfunc.funnom,
          l_flag          smallint

   call cts10g06_dados_servicos(8,l_atdsrvnum,l_atdsrvano)
        returning l_resultado, l_mensagem, l_c24opemat

   let l_resultado = null
   let l_mensagem = null
   let l_funnom = null

   if l_flag = 0 then
      if l_c24opemat is not null then

         call cty08g00_nome_func(1,l_c24opemat, "F")
              returning l_resultado,l_mensagem, l_funnom

         let l_mensagem = 'Servico sendo acionado por ', l_funnom
      else
         update datmservico set c24opemat = g_issk.funmat
                          where atdsrvnum = l_atdsrvnum
                            and atdsrvano = l_atdsrvano
          call cts00g07_apos_servbloqueia(l_atdsrvnum,l_atdsrvano)
      end if
   else
      update datmservico set c24opemat = null
                       where atdsrvnum = l_atdsrvnum
                         and atdsrvano = l_atdsrvano
      call cts00g07_apos_servdesbloqueia(l_atdsrvnum,l_atdsrvano)
   end if

   return l_mensagem

end function

#-------------------------------------------------
 function cts02m00_grava_dados(ws,hist_cts02m00)
#-------------------------------------------------

 define ws              record
        resposta        char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                   ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        vclatmflg       like abbmveic.vclatmflg    ,
        vclcoddig       like abbmveic.vclcoddig    ,
        vstnumdig       like abbmveic.vstnumdig    ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq,
    	ofnnumdig	      like sgokofi.ofnnumdig,
    	ofncrdflg         like sgokofi.ofncrdflg
 end record


 define hist_cts02m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define lr_ret        record
    retorno           smallint
   ,mensagem          char(100)
   ,atdsrvnum         like datmservico.atdsrvnum
   ,atdsrvano         like datmservico.atdsrvano
 end record
 define lr_clausula record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
 end record
 define l_detalhe char(60)
 define l_cont    smallint
 initialize lr_ret.* to null
 initialize  lr_clausula.* to  null
 let l_detalhe = null
 let l_cont = 0


 #------------------------------------------------------------------------------
 # Busca clausula
 #------------------------------------------------------------------------------

  if g_documento.ramcod = 531 then
     call cty05g00_clausula_assunto(g_documento.c24astcod)
          returning lr_clausula.*
  end if

 while true
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "1" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS02M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.resposta
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum = ws.lignum
   let aux_atdsrvnum      = ws.atdsrvnum
   let aux_atdsrvano      = ws.atdsrvano


 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts02m00.data         ,
                           w_cts02m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts02m00.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           aux_atdsrvnum           ,
                           aux_atdsrvano           ,
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
                           ws.caddat,  ws.cadhor   ,
                           ws.cademp,  ws.cadmat    )
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.resposta
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                w_cts02m00.vclcorcod,
                                w_cts02m00.funmat   ,
                                d_cts02m00.atdlibflg,
                                d_cts02m00.atdlibhor,
                                d_cts02m00.atdlibdat,
                                w_cts02m00.data     ,     # atddat
                                w_cts02m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts02m00.atdhorpvt,
                                w_cts02m00.atddatprg,
                                w_cts02m00.atdhorprg,
                                "1"                 ,     # atdtip
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts02m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts02m00.atdfnlflg,
                                w_cts02m00.atdfnlhor,
                                w_cts02m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts02m00.c24opemat,
                                d_cts02m00.nom      ,
                                d_cts02m00.vcldes   ,
                                d_cts02m00.vclanomdl,
                                d_cts02m00.vcllicnum,
                                d_cts02m00.corsus   ,
                                d_cts02m00.cornom   ,
                                w_cts02m00.cnldat   ,
                                ""                  ,     # pgtdat
                                w_cts02m00.c24nomctt,
                                w_cts02m00.atdpvtretflg,
                                w_cts02m00.atdvcltip,
                                d_cts02m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts02m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts02m00.atdprinvlcod,
                                g_documento.atdsrvorg)    # atdsrvorg
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.resposta
       let ws.retorno = false
       exit while
   end if

   call cts10g02_grava_loccnd(aux_atdsrvnum
                             ,aux_atdsrvano)
        returning ws.tabname, ws.codigosql

     if ws.codigosql <> 0 then
        error "ERRO (", ws.codigosql ,") na gravacao da ", ws.tabname
        rollback work
        prompt "" for char ws.resposta
        let ws.retorno = false
        exit while
     end if

  #------------------------------------------------------------------------------
  # Insere Clausula X Servicos
  #------------------------------------------------------------------------------
  if lr_clausula.clscod is not null then
      call cts10g02_grava_servico_clausula(aux_atdsrvnum
                                          ,aux_atdsrvano
                                          ,g_documento.ramcod
                                          ,lr_clausula.clscod)
           returning ws.tabname,
                     ws.codigosql
      if  ws.codigosql  <>  0  then
          error " Erro (", ws.codigosql, ") na gravacao da",
                " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.resposta
          let ws.retorno = false
          exit while
      end if
   end if


   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if d_cts02m00.prslocflg = "S" then
      update datmservico set prslocflg = d_cts02m00.prslocflg,
                             socvclcod = w_cts02m00.socvclcod,
                             srrcoddig = w_cts02m00.srrcoddig
       where datmservico.atdsrvnum = aux_atdsrvnum
         and datmservico.atdsrvano = aux_atdsrvano
   end if
   if m_multiplo = "S" then
      #------------------------------------------------------------------------------
      # Grava problemas do servico
      #------------------------------------------------------------------------------
      call ctx09g02_inclui(aux_atdsrvnum       ,
                           aux_atdsrvano       ,
                           1                   , # Org. informacao 1-Segurado 2-Pst
                           am_param.c24pbmcod,
                           am_param.atddfttxt,
                           ""                  ) # Codigo prestador
           returning ws.codigosql,
                     ws.tabname
      if  ws.codigosql  <>  0  then
          error "ctx09g02_inclui", ws.codigosql, ws.tabname
          rollback work
          prompt "" for char ws.resposta
          let ws.retorno = false
          exit while
      end if
    end if

 #------------------------------------------------------------------------------
 # Grava complemento do servico
 #------------------------------------------------------------------------------
   insert into DATMSERVICOCMP ( atdsrvnum ,
                                atdsrvano ,
                                vclcamtip ,
                                vclcrcdsc ,
                                vclcrgflg ,
                                vclcrgpso ,
                                sinvitflg ,
                                bocflg    ,
                                bocnum    ,
                                bocemi    ,
                                vcllibflg ,
                                roddantxt ,
                                rmcacpflg ,
                                sindat    ,
                                sinhor     )
                       values ( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                w_cts02m00.vclcamtip,
                                w_cts02m00.vclcrcdsc,
                                w_cts02m00.vclcrgflg,
                                w_cts02m00.vclcrgpso,
                                d_cts02m00.sinvitflg,
                                d_cts02m00.bocflg   ,
                                w_cts02m00.bocnum   ,
                                w_cts02m00.bocemi   ,
                                w_cts02m00.vcllibflg,
                                d_cts02m00.roddantxt,
                                d_cts02m00.rmcacpflg,
                                d_cts02m00.sindat   ,
                                d_cts02m00.sinhor    )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.resposta
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 2
       if  a_cts02m00[arr_aux].operacao is null  then
           let a_cts02m00[arr_aux].operacao = "I"
       end if
       if g_documento.c24astcod = "SAP" and
          m_multiplo = 'S'              and
          arr_aux = 2                   then
          exit for
       end if
    if  (arr_aux = 1 and d_cts02m00.frmflg = "N") or arr_aux = 2 then
        let a_cts02m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    end if

       let ws.codigosql = cts06g07_local( a_cts02m00[arr_aux].operacao
                                       ,aux_atdsrvnum
                                       ,aux_atdsrvano
                                       ,arr_aux
                                       ,a_cts02m00[arr_aux].lclidttxt
                                       ,a_cts02m00[arr_aux].lgdtip
                                       ,a_cts02m00[arr_aux].lgdnom
                                       ,a_cts02m00[arr_aux].lgdnum
                                       ,a_cts02m00[arr_aux].lclbrrnom
                                       ,a_cts02m00[arr_aux].brrnom
                                       ,a_cts02m00[arr_aux].cidnom
                                       ,a_cts02m00[arr_aux].ufdcod
                                       ,a_cts02m00[arr_aux].lclrefptotxt
                                       ,a_cts02m00[arr_aux].endzon
                                       ,a_cts02m00[arr_aux].lgdcep
                                       ,a_cts02m00[arr_aux].lgdcepcmp
                                       ,a_cts02m00[arr_aux].lclltt
                                       ,a_cts02m00[arr_aux].lcllgt
                                       ,a_cts02m00[arr_aux].dddcod
                                       ,a_cts02m00[arr_aux].lcltelnum
                                       ,a_cts02m00[arr_aux].lclcttnom
                                       ,a_cts02m00[arr_aux].c24lclpdrcod
                                       ,a_cts02m00[arr_aux].ofnnumdig
                                       ,a_cts02m00[arr_aux].emeviacod
                                       ,a_cts02m00[arr_aux].celteldddcod
                                       ,a_cts02m00[arr_aux].celtelnum
                                       ,a_cts02m00[arr_aux].endcmp)

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
           prompt "" for char ws.resposta
           let ws.retorno = false
           exit while
       end if
   end for
   
   if m_multiplo = "N"   and
   	  m_premium  = false then 
      call cts06g03_inclui_hstidx(aux_atdsrvnum,
                                  aux_atdsrvano)
   end if
 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  w_cts02m00.atdetpcod is null  then
       if  d_cts02m00.atdlibflg = "S"  then
           let w_cts02m00.atdetpcod = 1
           let ws.etpfunmat = w_cts02m00.funmat
           let ws.atdetpdat = d_cts02m00.atdlibdat
           let ws.atdetphor = d_cts02m00.atdlibhor
       else
           let w_cts02m00.atdetpcod = 2
           let ws.etpfunmat = w_cts02m00.funmat
           let ws.atdetpdat = w_cts02m00.data
           let ws.atdetphor = w_cts02m00.hora
       end if
   else
      let w_retorno = cts10g04_insere_etapa(aux_atdsrvnum,
                                            aux_atdsrvano,
                                            1,
                                            w_cts02m00.atdprscod ,
                                            " ",
                                            " ",
                                            w_cts02m00.srrcoddig )

       if  w_retorno <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.resposta
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts02m00.cnldat
       let ws.atdetphor = w_cts02m00.atdfnlhor
       let ws.etpfunmat = w_cts02m00.c24opemat
   end if

   let w_retorno = cts10g04_insere_etapa(aux_atdsrvnum,
                                         aux_atdsrvano,
                                         w_cts02m00.atdetpcod,
                                         w_cts02m00.atdprscod,
                                         " ",
                                         w_cts02m00.socvclcod ,
                                         w_cts02m00.srrcoddig)

   if  w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.resposta
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if  g_documento.aplnumdig is not null  and
       g_documento.aplnumdig <> 0        then

       call cts10g02_grava_servico_apolice(aux_atdsrvnum        ,
                                           aux_atdsrvano        ,
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
           prompt "" for char ws.resposta
           let ws.retorno = false
           exit while
       end if
       if g_documento.cndslcflg = "S"  then
          select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                 into ws.cdtnom,ws.cgccpfnum,ws.cgccpfdig
                 from tmpcondutor

          let ws.cdtseq = grava_condutor( g_documento.succod,g_documento.aplnumdig,
                                          g_documento.itmnumdig,ws.cdtnom,ws.cgccpfnum,
                                          ws.cgccpfdig,"D","CENTRAL24H" )

          let ws_cgccpfnum = ws.cgccpfnum
          let ws_cgccpfdig = ws.cgccpfdig
               # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
          insert into datrsrvcnd
                    (atdsrvnum,
                     atdsrvano,
                     succod   ,
                     aplnumdig,
                     itmnumdig,
                     vclcndseq)
             values (aux_atdsrvnum        ,
                     aux_atdsrvano        ,
                     g_documento.succod   ,
                     g_documento.aplnumdig,
                     g_documento.itmnumdig,
                     ws.cdtseq             )
          if  sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na gravacao do",
                    " relacionamento servico x condutor. AVISE A INFORMATICA!"
              rollback work
              prompt "" for char ws.resposta
              let ws.retorno = false
              exit while
         end if
       end if
   end if

 #------------------------------------------------------------------------------
 # Interface SINISTRO - indicacao de oficinas credenciadas
 #------------------------------------------------------------------------------
   if  a_cts02m00[2].ofnnumdig is not null  then
       call figrc072_setTratarIsolamento()
       let ws.codigosql = fsgoa005_ct24hs( a_cts02m00[2].ofnnumdig ,
                                         1                    ,
                                         w_cts02m00.data      ,
                                         w_cts02m00.hora      ,
                                         g_documento.aplnumdig,
                                         d_cts02m00.vcllicnum ,
                                         "", "", "", "", ""   ,
                                         g_issk.empcod        ,
                                         w_cts02m00.funmat,"N","N","N","N")

       if  ws.codigosql <> 0  then
           error " Erro (", sqlca.sqlcode, ") na indicacao da",
                 " oficina credenciada! Tecle <ENTER>"
           prompt "" for char ws.resposta
       end if
   end if

   commit work

   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)
 

 let g_documento.lignum = ws.lignum
 #-----------------------------------------------
  # Aciona Servico automaticamente
  #-----------------------------------------------
  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts02m00[1].cidnom,
                          a_cts02m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         d_cts02m00.asitipcod,
                                         a_cts02m00[1].lclltt,
                                         a_cts02m00[1].lcllgt,
                                         d_cts02m00.prslocflg,
                                         d_cts02m00.frmflg,
                                         aux_atdsrvnum,
                                         aux_atdsrvano,
                                         " ",
                                         d_cts02m00.vclcoddig,
                                         d_cts02m00.camflg) then
     else
        let m_aciona = 'S'
     end if
  end if
 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   if w_hist.hist1 is not null then   # registra o motivo da escolha oficina
      let ws.histerr = cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                                           w_cts02m00.data  , w_cts02m00.hora,
                                           w_cts02m00.funmat, w_hist.* )

   end if
   let ws.histerr = cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                                        w_cts02m00.data  , w_cts02m00.hora,
                                        w_cts02m00.funmat, hist_cts02m00.* )

   let lr_ret.retorno = 1
   let lr_ret.mensagem = ' '
   let lr_ret.atdsrvnum = aux_atdsrvnum
   let lr_ret.atdsrvano = aux_atdsrvano
     exit while
  end while

  #------------------------------------------------------------------------------
  #  GRAVA HISTORICO DE LOCALIZACAO
  #------------------------------------------------------------------------------
    if m_verifica = 1 and
       g_documento.c24astcod = 'L10' then

     #gravar no historico

      let m_flag = m_flag clipped

         call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava m_cidade
                                        lr_ret.atdsrvano,
                                        g_issk.funmat,
                                        m_cidade,
                                        m_data1,
                                        m_hora,
                                        g_issk.empcod,
                                        g_issk.usrtip)
                    returning m_ret,
                              m_mensg

         call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava m_estado
                                        lr_ret.atdsrvano,
                                        g_issk.funmat,
                                        m_estado,
                                        m_data1,
                                        m_hora,
                                        g_issk.empcod,
                                        g_issk.usrtip)
                    returning m_ret,
                              m_mensg


         call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava m_flagbo
                                        lr_ret.atdsrvano,
                                        g_issk.funmat,
                                        m_flagbo,
                                        m_data1,
                                        m_hora,
                                        g_issk.empcod,
                                        g_issk.usrtip)
                    returning m_ret,
                              m_mensg

         if m_flagaux_bo = 'S' then

            call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava numero BO m_BO
                                           lr_ret.atdsrvano,
                                           g_issk.funmat,
                                           m_BO,
                                           m_data1,
                                           m_hora,
                                           g_issk.empcod,
                                           g_issk.usrtip)
                       returning m_ret,
                                 m_mensg
         else

            call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava m_flag
                                     lr_ret.atdsrvano,
                                     g_issk.funmat,
                                     m_flag,
                                     m_data1,
                                     m_hora,
                                     g_issk.empcod,
                                     g_issk.usrtip)
            returning m_ret,
                      m_mensg

            call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava m_nome
                                         lr_ret.atdsrvano,
                                         g_issk.funmat,
                                         m_nome,
                                         m_data1,
                                         m_hora,
                                         g_issk.empcod,
                                         g_issk.usrtip)
            returning m_ret,
                      m_mensg

            call ctd07g01_ins_datmservhist(lr_ret.atdsrvnum,    #grava m_telefone
                                          lr_ret.atdsrvano,
                                         g_issk.funmat,
                                         m_telefone,
                                         m_data1,
                                         m_hora,
                                        g_issk.empcod,
                                        g_issk.usrtip)
            returning m_ret,
                      m_mensg

     #envia email
            call cta02m13_enviaEmail_localizacao(g_documento.lignum
                                               , d_cts02m00.vcllicnum
                                               , m_telefone
                                               , m_nome
                                               , d_cts02m00.c24astcod
                                               , lr_ret.atdsrvnum
                                               , lr_ret.atdsrvano
                                               , m_flag)
       end if
   end if

#--------------------------------------------------
#    Grava motivo 2� REMOCAO
#--------------------------------------------------
  if g_remocao.flag_tem > 0 then
          #-----------------------------------
          -->verifica se Ligacao ja tem Motivo
          #-----------------------------------
          open  ccts02m00009 using g_documento.lignum
                                  ,g_remocao.rcuccsmtvcod
                                  ,g_documento.c24astcod
          fetch ccts02m00009
          #------------------------
          --> Se nao achou registro
          #------------------------
          if sqlca.sqlcode = 100 then
             whenever error continue
             #--------------------------------
             -->Relaciona Motivo com a Ligacao
             #--------------------------------
             execute pcts02m00010 using g_documento.lignum
                                       ,g_remocao.rcuccsmtvcod
                                       ,g_documento.c24astcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                error " Erro (",sqlca.sqlcode,") na inclusao da ",
                      "tabela datrligrcuccsmtv (2). AVISE A INFORMATICA!"sleep 2
             end if
          end if
           open ccts02m00010 using g_remocao.rcuccsmtvcod
                                  ,g_documento.c24astcod
           fetch ccts02m00010 into g_remocao.rcuccsmtvdes
          for l_cont = 1 to 2
             if l_cont = 1 then
                let l_detalhe = "MOTIVO DE 2� REMOCAO:"
             else
                let l_detalhe = g_remocao.rcuccsmtvdes
             end if
             call ctd06g01_ins_datmlighist(g_documento.lignum
                                          ,g_issk.funmat
                                          ,l_detalhe
                                          ,m_data1
                                          ,m_data1
                                          ,g_issk.usrtip
                                          ,g_issk.empcod)
                                returning m_ret,
                                          m_mensg
             if m_ret <> 1 then
                error m_mensg
             end if
          end for
  end if
  return lr_ret.*

end function

function cts02m00_desbloqueia_servico(lr_param)

   define lr_param record
          atdsrvnum like datmservico.atdsrvnum,
          atdsrvano like datmservico.atdsrvano
   end record
   define lr_retorno record
          coderro smallint,
          mens    char(300)
   end record
   initialize lr_retorno.* to null
   if m_prep_sql is null or
      m_prep_sql = false then
      call cts02m00_prepara()
   end if
   whenever error continue
      execute p_cts02m00_004 using lr_param.atdsrvnum,
                                 lr_param.atdsrvano
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let lr_retorno.coderro = sqlca.sqlcode
         let lr_retorno.mens = "Erro <",lr_retorno.coderro ," > no desbloqueio do servico. AVISE A INFORMATICA!"
         call errorlog(lr_param.atdsrvnum)
         call errorlog(lr_retorno.mens)
         error lr_retorno.mens sleep 2
      else
        let lr_retorno.coderro = sqlca.sqlcode
        let lr_retorno.mens = "Erro <",lr_retorno.coderro ,"no desbloqueio do servico. AVISE A INFORMATICA!"
        call errorlog(lr_retorno.mens)
        call errorlog(lr_param.atdsrvnum)
        error lr_retorno.mens sleep 2
      end if
   else
      call cts00g07_apos_servdesbloqueia(lr_param.atdsrvnum,lr_param.atdsrvano)
   end if
end function

#--------------------------------------------------------#
 function cts02m00_bkp_info_dest(l_tipo, hist_cts02m00)
#--------------------------------------------------------#
  define hist_cts02m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts02m00_bkp      to null
     initialize m_hist_cts02m00_bkp to null

     let a_cts02m00_bkp[1].lclidttxt    = a_cts02m00[2].lclidttxt
     let a_cts02m00_bkp[1].cidnom       = a_cts02m00[2].cidnom
     let a_cts02m00_bkp[1].ufdcod       = a_cts02m00[2].ufdcod
     let a_cts02m00_bkp[1].brrnom       = a_cts02m00[2].brrnom
     let a_cts02m00_bkp[1].lclbrrnom    = a_cts02m00[2].lclbrrnom
     let a_cts02m00_bkp[1].endzon       = a_cts02m00[2].endzon
     let a_cts02m00_bkp[1].lgdtip       = a_cts02m00[2].lgdtip
     let a_cts02m00_bkp[1].lgdnom       = a_cts02m00[2].lgdnom
     let a_cts02m00_bkp[1].lgdnum       = a_cts02m00[2].lgdnum
     let a_cts02m00_bkp[1].lgdcep       = a_cts02m00[2].lgdcep
     let a_cts02m00_bkp[1].lgdcepcmp    = a_cts02m00[2].lgdcepcmp
     let a_cts02m00_bkp[1].lclltt       = a_cts02m00[2].lclltt
     let a_cts02m00_bkp[1].lcllgt       = a_cts02m00[2].lcllgt
     let a_cts02m00_bkp[1].lclrefptotxt = a_cts02m00[2].lclrefptotxt
     let a_cts02m00_bkp[1].lclcttnom    = a_cts02m00[2].lclcttnom
     let a_cts02m00_bkp[1].dddcod       = a_cts02m00[2].dddcod
     let a_cts02m00_bkp[1].lcltelnum    = a_cts02m00[2].lcltelnum
     let a_cts02m00_bkp[1].c24lclpdrcod = a_cts02m00[2].c24lclpdrcod
     let a_cts02m00_bkp[1].ofnnumdig    = a_cts02m00[2].ofnnumdig
     let a_cts02m00_bkp[1].celteldddcod = a_cts02m00[2].celteldddcod
     let a_cts02m00_bkp[1].celtelnum    = a_cts02m00[2].celtelnum
     let a_cts02m00_bkp[1].endcmp       = a_cts02m00[2].endcmp
     let m_hist_cts02m00_bkp.hist1      = hist_cts02m00.hist1
     let m_hist_cts02m00_bkp.hist2      = hist_cts02m00.hist2
     let m_hist_cts02m00_bkp.hist3      = hist_cts02m00.hist3
     let m_hist_cts02m00_bkp.hist4      = hist_cts02m00.hist4
     let m_hist_cts02m00_bkp.hist5      = hist_cts02m00.hist5
     let a_cts02m00_bkp[1].emeviacod    = a_cts02m00[2].emeviacod

     return hist_cts02m00.*

  else

     let a_cts02m00[2].lclidttxt    = a_cts02m00_bkp[1].lclidttxt
     let a_cts02m00[2].cidnom       = a_cts02m00_bkp[1].cidnom
     let a_cts02m00[2].ufdcod       = a_cts02m00_bkp[1].ufdcod
     let a_cts02m00[2].brrnom       = a_cts02m00_bkp[1].brrnom
     let a_cts02m00[2].lclbrrnom    = a_cts02m00_bkp[1].lclbrrnom
     let a_cts02m00[2].endzon       = a_cts02m00_bkp[1].endzon
     let a_cts02m00[2].lgdtip       = a_cts02m00_bkp[1].lgdtip
     let a_cts02m00[2].lgdnom       = a_cts02m00_bkp[1].lgdnom
     let a_cts02m00[2].lgdnum       = a_cts02m00_bkp[1].lgdnum
     let a_cts02m00[2].lgdcep       = a_cts02m00_bkp[1].lgdcep
     let a_cts02m00[2].lgdcepcmp    = a_cts02m00_bkp[1].lgdcepcmp
     let a_cts02m00[2].lclltt       = a_cts02m00_bkp[1].lclltt
     let a_cts02m00[2].lcllgt       = a_cts02m00_bkp[1].lcllgt
     let a_cts02m00[2].lclrefptotxt = a_cts02m00_bkp[1].lclrefptotxt
     let a_cts02m00[2].lclcttnom    = a_cts02m00_bkp[1].lclcttnom
     let a_cts02m00[2].dddcod       = a_cts02m00_bkp[1].dddcod
     let a_cts02m00[2].lcltelnum    = a_cts02m00_bkp[1].lcltelnum
     let a_cts02m00[2].c24lclpdrcod = a_cts02m00_bkp[1].c24lclpdrcod
     let a_cts02m00[2].ofnnumdig    = a_cts02m00_bkp[1].ofnnumdig
     let a_cts02m00[2].celteldddcod = a_cts02m00_bkp[1].celteldddcod
     let a_cts02m00[2].celtelnum    = a_cts02m00_bkp[1].celtelnum
     let a_cts02m00[2].endcmp       = a_cts02m00_bkp[1].endcmp
     let hist_cts02m00.hist1        = m_hist_cts02m00_bkp.hist1
     let hist_cts02m00.hist2        = m_hist_cts02m00_bkp.hist2
     let hist_cts02m00.hist3        = m_hist_cts02m00_bkp.hist3
     let hist_cts02m00.hist4        = m_hist_cts02m00_bkp.hist4
     let hist_cts02m00.hist5        = m_hist_cts02m00_bkp.hist5
     let a_cts02m00[2].emeviacod    = a_cts02m00_bkp[1].emeviacod

     return hist_cts02m00.*

  end if

end function

#-----------------------------------------#
 function cts02m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open ccts02m00008 using g_documento.atdsrvnum
                         ,g_documento.atdsrvano
                         ,g_documento.atdsrvnum
                         ,g_documento.atdsrvano

  whenever error continue
  fetch ccts02m00008 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT ccts02m00008: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts02m00() / C24 / cts02m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts02m00_verifica_op_ativa()
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
 function cts02m00_grava_historico()
#-----------------------------------------#
  define la_cts02m00       array[12] of record
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

  initialize la_cts02m00  to null
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

  let la_cts02m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts02m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts02m00[03].descricao = "."
  let la_cts02m00[04].descricao = "DE:"
  let la_cts02m00[05].descricao = "CEP: ", a_cts02m00_bkp[1].lgdcep clipped," - ",a_cts02m00_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts02m00_bkp[1].cidnom clipped," UF: ",a_cts02m00_bkp[1].ufdcod clipped
  let la_cts02m00[06].descricao = "Logradouro: ",a_cts02m00_bkp[1].lgdtip clipped," ",a_cts02m00_bkp[1].lgdnom clipped," "
                                                ,a_cts02m00_bkp[1].lgdnum clipped," ",a_cts02m00_bkp[1].brrnom
  let la_cts02m00[07].descricao = "."
  let la_cts02m00[08].descricao = "PARA:"
  let la_cts02m00[09].descricao = "CEP: ", a_cts02m00[2].lgdcep clipped," - ", a_cts02m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts02m00[2].cidnom clipped," UF: ",a_cts02m00[2].ufdcod  clipped
  let la_cts02m00[10].descricao = "Logradouro: ",a_cts02m00[2].lgdtip clipped," ",a_cts02m00[2].lgdnom clipped," "
                                                ,a_cts02m00[2].lgdnum clipped," ",a_cts02m00[2].brrnom
  let la_cts02m00[11].descricao = "."
  let la_cts02m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts02m00[l_ind].descricao
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
  let lr_de.lgdcep    = a_cts02m00_bkp[1].lgdcep clipped,"-",a_cts02m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts02m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts02m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts02m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts02m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts02m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts02m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts02m00[2].lgdcep clipped,"-", a_cts02m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts02m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts02m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts02m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts02m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts02m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts02m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function

