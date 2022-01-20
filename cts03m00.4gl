###############################################################################
# Nome do Modulo: CTS03M00                                              Pedro #
#                                                                     Marcelo #
# Laudo - D.A.F. / Porto Socorro                                     Jan/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Incluir o campo SERV.PARTICULAR? na   #
#                                       tela do laudo.                        #
#-----------------------------------------------------------------------------#
# 08/10/1998  PSI 6955-8   Gilberto     Retirar aviso que informa sobre       #
#                                       informacoes complementares no         #
#                                       historico (funcao CTS11G00).          #
#-----------------------------------------------------------------------------#
# 20/10/1998  PSI 6954-0   Gilberto     Incluir aviso que alerta para nao     #
#                                       acionar veiculo da frota Porto para   #
#                                       execucao de servicos particulares.    #
#-----------------------------------------------------------------------------#
# 17/11/1998  PSI 6467-0   Gilberto     Gravar codigo do veiculo atendido.    #
#-----------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Gravar dados referentes a digitacao   #
#                                       via formulario.                       #
#-----------------------------------------------------------------------------#
# 03/12/1998               Gilberto     Alteracao da faixa de numeracao       #
#                                       para 900000 a 999999.                 #
#-----------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de     #
#                                       cabecalho (CTS05G00), inclusao do     #
#                                       parametro RAMO.                       #
#-----------------------------------------------------------------------------#
# 17/12/1998  PSI 6478-5   Gilberto     Inclusao da chamada da funcao de      #
#                                       cabecalho (CTS05G02) para atendi-     #
#                                       mento Porto Card VISA.                #
#-----------------------------------------------------------------------------#
# 10/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-    #
#                                       reco atraves do guia postal.          #
#-----------------------------------------------------------------------------#
# 26/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti-   #
#                                       ma etapa do servico.                  #
#-----------------------------------------------------------------------------#
# 16/06/1999  PSI 8111-6   Wagner       Incluir tecla funcao (F9)Copia laudo  #
#-----------------------------------------------------------------------------#
# 20/07/1999  PSI 8533-2   Wagner       Incluir acesso ao modulo cts14g00     #
#                                       para mensagens Cidade e UF.           #
#-----------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a     #
#                                       serem excluidos.                      #
#-----------------------------------------------------------------------------#
# 31/08/1999               Gilberto     Extensao da faixa de numeracao de     #
#                                       175000~349999 para 900000~999999.     #
#-----------------------------------------------------------------------------#
# 10/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03  #
#                                       e padroniza gravacao do historico.    #
#-----------------------------------------------------------------------------#
# 23/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do     #
#                                       historico.(Inclusao)                  #
#-----------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga-   #
#                                       cao (CTS10G00) para gravar as tabe-   #
#                                       las de relacionamento.                #
#-----------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.             #
#-----------------------------------------------------------------------------#
# 25/11/1999               Gilberto     Inclusao de validacao do ano do       #
#                                       veiculo.                              #
#-----------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de    #
#                                       ligacoes x propostas.                 #
#-----------------------------------------------------------------------------#
# 28/01/2000  PSI 10203-2  Wagner       Gravar atdvcltip = 3 para solicit.    #
#                                       de guincho para caminhao.             #
#-----------------------------------------------------------------------------#
# 07/02/2000  PSI 10206-7  Wagner       Manutencao campo nivel de prioridade  #
#-----------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de        #
#                                       solicitante.                          #
#-----------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO        #
#                                       via funcao                            #
#-----------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03           #
#-----------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg   #
#                                       Exibicao do atdsrvnum (dec 10,0)      #
#-----------------------------------------------------------------------------#
# 28/08/2000  Arnaldo      Ruiz         o assunto "E12" devera ser tratado    #
#                                       como origem 01                        #
#-----------------------------------------------------------------------------#
# 31/08/2000  PSI 11459-6  Wagner       Incluir acionamento do servico apos   #
#                                       retorno do historico p/atendentes.    #
#-----------------------------------------------------------------------------#
# 25/09/2000  PSI 11253-4  Ruiz         Grava oficina na datmlcl para o       #
#                                       relatorio bdata080.                   #
#-----------------------------------------------------------------------------#
# 29/11/2000               Raji         Inclusao do paramentro codigo da      #
#                                       oficina destino para laudos           #
#-----------------------------------------------------------------------------#
# 08/12/2000  PSI 11549-5  Raji         Inclusao do codigo do problema /      #
#                                       defeito.                              #
#-----------------------------------------------------------------------------#
# 14/02/2001               Raji         Atalho p/ visualizacao Pto Referecia  #
#-----------------------------------------------------------------------------#
# 16/02/2001  PSI 11254-2  Ruiz         Consulta o Condutor do Veiculo        #
#-----------------------------------------------------------------------------#
# 23/02/2001  PSI 12463-0  Raji         Inclusao de DATA/HORA ocorrencia para #
#                                       ast. E12 p/ atend. criterios infochuva#
#-----------------------------------------------------------------------------#
# 04/04/2001  PSI 12768-0  Wagner       Inclusao do nr.dias no parametro da   #
#                                       chanada do modulo cts16g00            #
#-----------------------------------------------------------------------------#
# 10/09/2001  PSI 13893-2  Wagner       Laudo emergencial - Colocar campo     #
#                                       formulario s/n como primeiro.         #
#-----------------------------------------------------------------------------#
# 19/10/2001  Correio      Ruiz         inibir o campo srvprlflg(serv.partic. #
#-----------------------------------------------------------------------------#
# 27/12/2001  PSI 14099-6  Ruiz         Trata clausula 096.                   #
#-----------------------------------------------------------------------------#
# 07/02/2002  PSI 13239-0  Marcus       Calculo distancias QTH-QTI            #
#-----------------------------------------------------------------------------#
# 01/03/2002  CORREIO      Wagner       Incluir dptsgl psocor na pesquisa.    #
#-----------------------------------------------------------------------------#
# 26/03/2002  PSI 15426-1  Ruiz         Alerta para veiculo blindado.         #
#-----------------------------------------------------------------------------#
# 03/07/2002  PSI 15590-0  Wagner       Inclusao msg convenio/assuntos.       #
#-----------------------------------------------------------------------------#
# 25/07/2002  PSI 15655-8  Ruiz         Alerta qdo oficina estiver cortada.   #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 #
#-----------------------------------------------------------------------------#
# 04/06/2003  Helio        Ruiz   PSI.170275     Busca do campo asiofndigflg  #
#                                 OSF.19968                                   #
###############################################################################
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------  #
# 18/09/2003  Meta,Bruno     PSI175552 Inibir funcao ctx17g00.                #
#                            OSF26077                                         #
# ----------  -------------- --------- -------------------------------------  #
# 14/11/2003  Meta,Paulo     PSI179345 Usar o atributo grlinf para controlar  #
#                            OSF28851  se janela "confirma o acionamento do   #
#                                      servico" deve ou nao ser aberta        #
# ----------  -------------- --------- -------------------------------------  #
# 08/04/2005  James, Meta    PSI191671 inicializar o atdlibflg e passar para  #
#                                      o proximo campo                        #
# ----------  -------------- --------- -------------------------------------  #
# 18/05/2005  Solda, Meta    PSI191108 implementar o codigo da via(emeviacod) #
# ----------  -------------- --------- -------------------------------------  #
# 02/08/2005  Junior, Meta   PSI192015 Alteracoes diversas                    #
# ----------  -------------- --------- -------------------------------------  #
# 24/08/2005  James, Meta    PSI192015 Inibir a chamada das funcoes ctc61m02  #
# ----------  -------------- --------- -------------------------------------  #
# 01/02/2006  Priscila       Zeladoria Buscar data e hora do banco de dados   #
# ----------  -------------- --------- -------------------------------------  #
# 04/05/2006  Priscila       PSI198714 Gerar laudo de apoio quando local/cond #
#                                      veiculo e subsolo ou chave codificada  #
# ----------  -------------- --------- -------------------------------------  #
# 17/05/2006  Priscila       PSI198714 Inclusao da opcao F4 para visualizar   #
#                                      laudo de apoio                         #
#---------------------------------------------------------------------------  #
# 29/08/2006  Priscila       PSI202363 Acerto passagem parametros ctc59m02    #
# 11/12/2006  Ligia Mattge   CT6121350 Chamada do cts40g12 apos os updates    #
# 28/12/2006  Ligia Mattge             Implementacao de m_c24lclpdrcod e      #
#                                      chamada de cts02m00_valida_indexacao   #
#---------------------------------------------------------------------------  #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# ---------- ------------- --------- -----------------------------------------#
# 14/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32              #
#-----------------------------------------------------------------------------#
# 07/07/2008 Andre Oliveira          Alteracao da chamada da funcao           #
#                                    cts00m02_regulador para                  #
#                                    ctc59m03_regulador                       #
# 01/10/2008 Amilton, Meta 223689    Incluir tratamento de erro com a         #
#                                    global                                   #
#-----------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650 Nao utilizar a 1 posicao do assunto     #
#                                     como sendo o agrupamento, buscar cod    #
#                                     agrupamento.                            #
#-----------------------------------------------------------------------------#
# 10/02/2009 Carla Rampazzo    230650 Para alguns assuntos S10/S90 (ver lista #
#                                     em iddkdominio) sugerir utilizar o CAPS #
#                                     e mostrar lista de CAPS por distancia   #
#                                     se segurado recusar obrigar a informar o#
#                                     motivo da recusa                        #
#-----------------------------------------------------------------------------#
# 23/03/2009 Carla Rampazzo    238643 Retornar nome fantasia do CAPS          #
#                                     Pedir confirmacao do CAPS conforme KM   #
# 13/08/2009 Sergio Burini     244236 Inclusão do Sub-Dairro                  #
#-----------------------------------------------------------------------------#
# 04/01/2010 Amilton, Meta            Projeto sucursal smallint               #
#-----------------------------------------------------------------------------#
# 21/10/2010 Alberto Rodrigues        Correcao de ^M                          #
# 28/03/2012 Sergio Burini  PSI-2010-01968/PB                                 #
#-----------------------------------------------------------------------------#
# 29/05/2012 Johnny Alves             Correcao na apresentacao do atendente   #
#            BizTalking               no campo "Atd./Lib" para empresa 44     #
#-----------------------------------------------------------------------------#
# 10/09/2012 Fornax-Hamilton PSI-2012-16039/EV - Controle/Restricao de        #
#                       problemas para servico S40 - Clausulas 044 44R 048 48R#
#-----------------------------------------------------------------------------#
# 10/12/2013 Rodolfo   PSI-2013-         Inlcusao da nova regulacao via AW    #
#            Massini   12097PR                                                #
#-----------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Adaptacao regulacao via AW     #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

  define d_cts03m00    record
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
    sinhor            like datmservicocmp.sinhor
 end record

 define w_cts03m00    record
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
 
 define a_cts03m00    array[3] of record
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
 
 define a_cts03m00_bkp array[1] of record
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
 
 define m_hist_cts03m00_bkp   record
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

 define arr_aux            smallint
 define w_retorno          smallint
 define l_atdsrvnum_mult   like datmservico.atdsrvnum
 define l_atdsrvano_mult   like datmservico.atdsrvano
 define m_ciaempcod_slv    like datmligacao.ciaempcod
 define m_cappstcod        like avgkcappst.cappstcod

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

 define m_prep_sql    smallint ### PSI179345

 define m_aciona              char(01)    #PSI198714
 define m_outrolaudo          smallint    #PSI198714
 define m_srv_acionado        smallint  #PSI198714
 define m_c24lclpdrcod        like datmlcl.c24lclpdrcod
 define m_retctb83m00         smallint #PSI207233
 define m_imdsrvflg_ant       char(1)
 define m_lclbrrnom           char(65)
 define m_multiplo            char(1)   
 define m_premium             integer
 define m_atdsrvorg           integer 
 define m_asitipcod           integer
 define m_atdsrvnum_premium   like datmservico.atdsrvnum
 define m_atdsrvano_premium   like datmservico.atdsrvano
 define m_mdtcod		          like datmmdtmsg.mdtcod
 define m_pstcoddig           like dpaksocor.pstcoddig
 define m_socvclcod           like datkveiculo.socvclcod
 define m_srrcoddig           like datksrr.srrcoddig
 define l_vclcordes	          char(20)
 define m_ret                 smallint
 define m_mensg               char(50)
 define l_msgaltend	          char(1500)
 define l_texto 		          char(200)
 define l_dtalt		            date
 define l_hralt		            datetime hour to minute
 define l_lgdtxtcl	          char(80)
 define l_ciaempnom           char(50)
 define l_codrtgps            smallint
 define l_msgrtgps            char(100)

 define l_cappstcod  like avgkcappst.cappstcod
       ,l_stt        smallint

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_acesso_ind  smallint
       ,m_grava_hist  smallint

 define am_param   record
       c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
      ,c24pbmgrpdes  like datkpbmgrp.c24pbmgrpdes
      ,c24pbmcod     like datkpbm.c24pbmcod
      ,atddfttxt     like datkpbm.c24pbmdes
      ,asitipcod     like datmservico.asitipcod
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
function cts03m00_prepare()
#--------------------------#

 define l_sql    char(500)

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts03m00_001 from l_sql
 declare c_cts03m00_001 cursor for p_cts03m00_001

 #PSI 198714 - buscar locais condicao veiculo do servico
 let l_sql = "select vclcndlclcod "
            ," from datrcndlclsrv "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
 prepare p_cts03m00_002 from l_sql
 declare c_cts03m00_002 cursor with hold for p_cts03m00_002

 let l_sql = " select c24astcod from datmligacao ",
 	     " where atdsrvnum = ? ",
 	     " and atdsrvano = ? "
 prepare p_cts03m00_003 from l_sql
 declare c_cts03m00_003 cursor for p_cts03m00_003


 let l_sql = " select asitipcod ",
               " from datkpbm ",
              " where c24pbmcod = ? "
 prepare p_cts03m00_004 from l_sql
 declare c_cts03m00_004 cursor for p_cts03m00_004
 let l_sql = " update datmservico set c24opemat = null",
             " where atdsrvnum = ? ",
             " and atdsrvano = ? "
 prepare pcts03m00010 from l_sql
 let l_sql = " select funnom     "                 #Johnny,Biz
            ,"       ,dptsgl     "
            ,"   from isskfunc   "
            ,"  where empcod = ? "
            ,"    and funmat = ? "
 prepare p_cts30m00_005 from l_sql
 declare c_cts03m00_005 cursor for p_cts30m00_005

 let l_sql =  "select atdetpcod                          "
             ,"  from datmsrvacp                         "
             ," where atdsrvnum = ?                      "
             ,"   and atdsrvano = ?                      "
             ,"   and atdsrvseq = (select max(atdsrvseq) "
             ,"                      from datmsrvacp     "
             ,"                     where atdsrvnum = ?  "
             ,"                       and atdsrvano = ?) "

 prepare p_cts03m00_006 from l_sql
 declare c_cts03m00_006 cursor for p_cts03m00_006

 let l_sql = " select count(*)                     ",
 	     "   from dbsmopgitm itm,              ",
 	     "        dbsmopg op                   ",
 	     "  where itm.socopgnum = op.socopgnum ",
 	     "    and itm.atdsrvnum = ?            ",
 	     "    and itm.atdsrvano = ?            ",
 	     "    and op.socopgsitcod <> 8         "

 prepare p_cts03m00_007 from l_sql
 declare c_cts03m00_007 cursor for p_cts03m00_007

 let l_sql = " select clscod from abbmclaus ",
             " where ",
             " succod = ? ",
             " and aplnumdig = ? ",
             " and itmnumdig = ? ",
             " and dctnumseq = ? ",
             " and clscod in ('034','033','035','044','44R','046','46R','47R','047','048','48R') "
 prepare pcts03m00006 from l_sql
 declare ccts03m00006 cursor with hold for pcts03m00006
 let l_sql = ' select count(*) '
            ,' from datrservapol a, datmservico b, datmligacao c '
            ,' where a.ramcod    = ? '
            ,' and a.succod    = ? '
            ,' and a.aplnumdig = ? '
            ,' and a.itmnumdig = ? '
            ,' and a.atdsrvnum = b.atdsrvnum '
            ,' and a.atdsrvano = b.atdsrvano '
            ,' and a.atdsrvnum = c.atdsrvnum '
            ,' and a.atdsrvano = c.atdsrvano '
            ,' and c.c24astcod = "S10" '
            ,' and b.atdetpcod in (1,3,4) '
            ,' and b.asitipcod in (4,50)'
 prepare pcts03m00007 from l_sql
 declare ccts03m00007 cursor for pcts03m00007
 let l_sql = ' select count(*) '
            ,' from datrservapol a, datmservico b, datmligacao c '
            ,' where a.ramcod    = ? '
            ,' and a.succod    = ? '
            ,' and a.aplnumdig = ? '
            ,' and a.itmnumdig = ? '
            ,' and a.atdsrvnum = b.atdsrvnum '
            ,' and a.atdsrvano = b.atdsrvano '
            ,' and a.atdsrvnum = c.atdsrvnum '
            ,' and a.atdsrvano = c.atdsrvano '
            ,' and c.c24astcod = "S10" '
            ,' and b.atdetpcod in (1,3,4) '
            ,' and b.asitipcod not in (4,50)'
 prepare pcts03m00008 from l_sql
 declare ccts03m00008 cursor for pcts03m00008
 
 let l_sql = ' select count(*) '
           ,' from datrservapol a, datmservico b, '
           ,' datmligacao c ,datrsrvpbm d, datkpbm e'
           ,' where a.ramcod    = ? '
           ,' and a.succod    = ? '
           ,' and a.aplnumdig = ? '
           ,' and a.itmnumdig = ? '
           ,' and a.atdsrvnum = b.atdsrvnum '
           ,' and a.atdsrvano = b.atdsrvano '
           ,' and a.atdsrvnum = c.atdsrvnum '
           ,' and a.atdsrvano = c.atdsrvano '
           ,' and a.atdsrvnum = d.atdsrvnum '
           ,' and a.atdsrvano = d.atdsrvano '
           ,' and d.c24pbmcod = e.c24pbmcod '
           ,' and c.c24astcod = "S85" '
           ,' and b.atdetpcod in (1,3,4) '
           ,' and e.c24pbmgrpcod = 116 '
 prepare pcts03m00009 from l_sql
 declare ccts03m00009 cursor for pcts03m00009
 
 let l_sql = ' select count(*) '
           ,' from datrservapol a, datmservico b, '
           ,' datmligacao c ,datrsrvpbm d, datkpbm e'
           ,' where a.ramcod    = ? '
           ,' and a.succod    = ? '
           ,' and a.aplnumdig = ? '
           ,' and a.itmnumdig = ? '
           ,' and a.atdsrvnum = b.atdsrvnum '
           ,' and a.atdsrvano = b.atdsrvano '
           ,' and a.atdsrvnum = c.atdsrvnum '
           ,' and a.atdsrvano = c.atdsrvano '
           ,' and a.atdsrvnum = d.atdsrvnum '
           ,' and a.atdsrvano = d.atdsrvano '
           ,' and d.c24pbmcod = e.c24pbmcod '
           ,' and c.c24astcod = "S85" '
           ,' and b.atdetpcod in (1,3,4) '
           ,' and e.c24pbmgrpcod = 131 '
 prepare pcts03m00011 from l_sql
 declare ccts03m00010 cursor for pcts03m00011
 
 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAWATIVA' "
 prepare pcts03m00012 from l_sql
 declare ccts03m00012 cursor for pcts03m00012
 
 let l_sql = "select mpacidcod ",                
             " from datkmpacid ",               
            " where cidnom = ? ",               
              " and ufdcod = ? "                
prepare pcts03m00013 from l_sql               
declare ccts03m00013 cursor for pcts03m00013


 let m_prep_sql = true

end function

#--------------------------------------------------------------------
function cts03m00()
#--------------------------------------------------------------------

 define ws         record
    atdetpcod      like datmsrvacp.atdetpcod,
    vclchsinc      like abbmveic.vclchsinc,
    vclchsfnl      like abbmveic.vclchsfnl,
    confirma       char (01)              ,
    grvflg         smallint,
    c24srvdsc      like datmservhist.c24srvdsc,
    histerr        smallint,
    imsvlr         like abbmcasco.imsvlr,
    c24astcod	   like datmligacao.c24astcod
 end record

 define l_grlinf   like igbkgeral.grlinf
 define l_acesso   smallint

 define l_data     date,
        l_hora2    datetime hour to minute

 define l_erro       smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_grlinf  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null
        initialize  ws.*  to  null

        initialize l_cappstcod , l_stt  to null
        
 initialize m_rsrchv     
          , m_altcidufd  
          , m_altdathor 
          , m_operacao
          , m_agncotdat 
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant to null

 let m_outrolaudo         = 0
 let m_srv_acionado       = false
 let m_premium            = false
 let m_atdsrvorg          = null  
 let m_asitipcod          = null
 let m_atdsrvnum_premium  = null
 let m_atdsrvano_premium  = null 
 
 initialize f4.* to null
 
 let m_imdsrvflg_ant = null
 
 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
      
 let int_flag       = false
 let aux_today      = l_data
 let aux_hora       = l_hora2
 let aux_ano        = aux_today[9,10]
 let m_c24lclpdrcod = null
 
 initialize m_subbairro to null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts03m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false
 
 whenever error continue
 open ccts03m00012
 fetch ccts03m00012 into m_agendaw
 
 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 
 open window cts03m00 at 04,02 with form "cts03m00"
                      attribute(form line 1)

 if g_documento.atdsrvnum is null then
    display "(F1)Help,(F3)Refer,(F5)Espelho,(F6)Hist,(F7)Funcoes,(F8)Destino,(F9)Copia" to msgfun
 else
    open c_cts03m00_003 using g_documento.atdsrvnum, g_documento.atdsrvano
    fetch c_cts03m00_003 into ws.c24astcod
    close c_cts03m00_003
    if ws.c24astcod = "S11" or
    ws.c24astcod = "S14" or
    ws.c24astcod = "S53" or
    ws.c24astcod = "S64" then
    	display "(F1)Help(F3)Ref(F4)Apoio(F5)Esp(F6)Hist(F7)Func(F8)Dest(F9)Conc(F10)TipPgt" to msgfun
    else
    	display "(F1)Help(F3)Refer(F4)Apoio(F5)Espelho(F6)Hist(F7)Funcoes(F8)Dest(F9)Conclui" to msgfun
    end if
 end if

 initialize d_cts03m00.*,
            w_cts03m00.*,
            aux_libant  ,
            cpl_atdsrvnum,
            cpl_atdsrvano,
            cpl_atdsrvorg to null

 initialize a_cts03m00, a_cts03m00_bkp, m_hist_cts03m00_bkp  to null

 let w_cts03m00.ligcvntip  =  g_documento.ligcvntip

 select cpodes
   into d_cts03m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip" and
        cpocod = w_cts03m00.ligcvntip

 if g_documento.atdsrvnum is not null then

    call consulta_cts03m00()

    let d_cts03m00.asitipabvdes = "NAO PREV"

    select asitipabvdes
      into d_cts03m00.asitipabvdes
      from datkasitip
     where asitipcod = d_cts03m00.asitipcod

    display by name d_cts03m00.*
    display by name d_cts03m00.c24solnom attribute (reverse)
    display by name d_cts03m00.cvnnom    attribute (reverse)
    if d_cts03m00.desapoio is not null then
       display by name d_cts03m00.desapoio attribute (reverse)
    end if


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
          let ws.confirma = cts08g01 ( "A","N","",
                                       "  VEICULO BLINDADO  ",
                                       "","")
       end if
    end if

    display by name a_cts03m00[1].lgdtxt,
                    a_cts03m00[1].lclbrrnom,
                    a_cts03m00[1].cidnom,
                    a_cts03m00[1].ufdcod,
                    a_cts03m00[1].lclrefptotxt,
                    a_cts03m00[1].endzon,
                    a_cts03m00[1].dddcod,
                    a_cts03m00[1].lcltelnum,
                    a_cts03m00[1].lclcttnom,
                    a_cts03m00[1].celteldddcod,
                    a_cts03m00[1].celtelnum,
                    a_cts03m00[1].endcmp

    if d_cts03m00.atdlibflg = "N"   then
       display by name d_cts03m00.atdlibdat attribute (invisible)
       display by name d_cts03m00.atdlibhor attribute (invisible)
    end if

    if d_cts03m00.refasstxt is not null  then
       display by name d_cts03m00.refasstxt attribute (reverse)
    end if

    if w_cts03m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    else
       if g_documento.aplnumdig  is not null   or
          d_cts03m00.vcllicnum   is not null   then
          call cts03g00 (1, g_documento.ramcod   ,
                            g_documento.succod   ,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            d_cts03m00.vcllicnum ,
                            g_documento.atdsrvnum,
                            g_documento.atdsrvano)
       end if
       if d_cts03m00.srvprlflg = "S"  then
          let ws.confirma = cts08g01( "A","N","", "SERVICO PARTICULAR NAO DEVE SER" ,
                                      "PASSADO PARA FROTA PORTO SEGURO !","")
       end if
    end if

    let ws.grvflg = modifica_cts03m00()

    if ws.grvflg = false  then
       initialize g_documento.acao  to null
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
       let d_cts03m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                        " ", g_documento.ramcod    using "&&&&",
                                        " ", g_documento.aplnumdig using "<<<<<<<& &"

       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)
            returning d_cts03m00.nom      ,
                      d_cts03m00.corsus   ,
                      d_cts03m00.cornom   ,
                      d_cts03m00.cvnnom   ,
                      d_cts03m00.vclcoddig,
                      d_cts03m00.vcldes   ,
                      d_cts03m00.vclanomdl,
                      d_cts03m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts03m00.vclcordes

       call cts02m01_caminhao(g_documento.succod   ,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig,
                              g_funapol.autsitatu)
                    returning d_cts03m00.camflg,
                              w_cts03m00.ctgtrfcod
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

       call figrc072_setTratarIsolamento()        --> 223689
       call cts05g04 (g_documento.prporg   ,
                       g_documento.prpnumdig)
             returning d_cts03m00.nom      ,
                       d_cts03m00.corsus   ,
                       d_cts03m00.cornom   ,
                       d_cts03m00.cvnnom   ,
                       d_cts03m00.vclcoddig,
                       d_cts03m00.vcldes   ,
                       d_cts03m00.vclanomdl,
                       d_cts03m00.vcllicnum,
                       d_cts03m00.vclcordes
       if g_isoAuto.sqlCodErr <> 0 then --> 223689
          error "Função cts05g04 indisponivel no momento! Avise a Informatica !" sleep 2
          close window cts03m00
          return
       end if    --> 223689

       let d_cts03m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                        " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts03m00.doctxt = "Cartao..: ", g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts03m00.nom      ,
                      d_cts03m00.corsus   ,
                      d_cts03m00.cornom   ,
                      d_cts03m00.cvnnom   ,
                      d_cts03m00.vclcoddig,
                      d_cts03m00.vcldes   ,
                      d_cts03m00.vclanomdl,
                      d_cts03m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts03m00.vclcordes
    end if

    let d_cts03m00.prsloccab = "Prs.Local.:"
    let d_cts03m00.prslocflg = "N"

    let d_cts03m00.c24astcod = g_documento.c24astcod
    let d_cts03m00.c24solnom = g_documento.solnom

    let d_cts03m00.c24astdes = c24geral8(d_cts03m00.c24astcod)

    display by name d_cts03m00.*
    display by name d_cts03m00.c24solnom attribute (reverse)
    display by name d_cts03m00.cvnnom    attribute (reverse)
    if d_cts03m00.desapoio is not null then
       display by name d_cts03m00.desapoio attribute (reverse)
    end if

    ###
    ### Inicio PSI179345 - Paulo
    ###

    open c_cts03m00_001

    whenever error continue
    fetch c_cts03m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts03m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts03m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window cts03m00
          return
       end if
    end if
    ###
    ### Final PSI179345 - Paulo
    ###

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------
    if (g_documento.succod     is not null   and
        g_documento.ramcod     is not null   and
        g_documento.aplnumdig  is not null)  or
       (d_cts03m00.vcllicnum   is not null)  then
       call cts03g00 (1, g_documento.ramcod   ,
                         g_documento.succod   ,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig,
                         d_cts03m00.vcllicnum ,
                         g_documento.atdsrvnum,
                         g_documento.atdsrvano)
    end if

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    let ws.grvflg = inclui_cts03m00()

    if ws.grvflg = true  then
       if g_documento.flgIS096 is not null then # grava historico da clausula
          case g_documento.flgIS096             # 096 no servico.
            when "S"
             let ws.c24srvdsc = "096 = Valor da Cobertura FOI ultrapassado."
            when "N"
             let ws.c24srvdsc = "096 = Valor da Cobertura NAO FOI ultrapassado."
            when "P"
             let ws.c24srvdsc = "096 = Problemas no acesso a apolice ou outros."
          end case
          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          let ws.histerr = cts10g02_historico( aux_atdsrvnum, aux_atdsrvano,
                                               l_data        , l_hora2      ,
                                               g_issk.funmat, ws.c24srvdsc,"","","","")

          if ws.histerr <> 0  then
             error " Erro (", ws.histerr, ") na gravacao do historico",
                   " clausula 096. AVISE INFORMATICA"
             prompt "" for char ws.confirma
          end if
          initialize g_documento.flgIS096 to null
       end if

       -------------[ SUSEP DE LICITACAO - ROSANA 10/10/06 ]------------
       if d_cts03m00.corsus[1,2] = "LI"  and
          d_cts03m00.c24astcod   = "S11" then
          let ws.c24srvdsc =
                  "** ANTENCAO, SUSEP DE LICITACAO, DEBITAR C.C. 13138 **"
          let ws.histerr = cts10g02_historico
                          (aux_atdsrvnum, aux_atdsrvano,
                           w_cts03m00.data,w_cts03m00.hora,
                           g_issk.funmat, ws.c24srvdsc,"","","","")
          if ws.histerr <> 0  then
             error " Erro (", ws.histerr, ") na gravacao do historico",
                   " susep Licitacao. AVISE INFORMATICA"
             prompt "" for char ws.confirma
          end if
       end if
       
       call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts03m00.funmat,
                     w_cts03m00.data      , w_cts03m00.hora)
       if m_multiplo = 'S' then
          call cts10g02_historico_multiplo(l_atdsrvnum_mult,
                                         l_atdsrvano_mult,
                                         aux_atdsrvnum,
                                         aux_atdsrvano,
                                         w_cts03m00.funmat,
                                         w_cts03m00.data,
                                         w_cts03m00.hora)
       end if
       
       
       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if d_cts03m00.imdsrvflg =  "S"     and        # servico imediato
          d_cts03m00.atdlibflg =  "S"     and        # servico liberado
          d_cts03m00.prslocflg =  "N"     and        # prestador no local
          d_cts03m00.frmflg    =  "N"     and       # formulario
          m_aciona =  'N'                 then       # servico nao acionado auto

          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
        if g_documento.c24astcod <> 'M15' and
           g_documento.c24astcod <> 'M20' and
           g_documento.c24astcod <> 'M23' and
           g_documento.c24astcod <> 'M33'then
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
 
 if cty31g00_valida_atd_premium()   and           
    d_cts03m00.c24astcod = "S10"   then          
     
     
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

 close window cts03m00

end function  ###  cts03m00


#--------------------------------------------------------------------
 function consulta_cts03m00()
#--------------------------------------------------------------------

 define ws         record
    atdsrvorg      like datmservico.atdsrvorg,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    vclcorcod      like datmservico.vclcorcod,
    funmat         like datmservico.funmat   ,
    funnom         like isskfunc.funnom      ,
    dptsgl         like isskfunc.dptsgl      ,
    codigosql      integer,
    succod         like datrservapol.succod   ,
    ramcod         like datrservapol.ramcod   ,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    edsnumref      like datrservapol.edsnumref,
    prporg         like datrligprp.prporg,
    prpnumdig      like datrligprp.prpnumdig,
    fcapcorg       like datrligpac.fcapacorg,
    fcapacnum      like datrligpac.fcapacnum,
    empcod         like datmservico.empcod
 end record

 define prompt_key   char (01)
 define l_tipolaudo  smallint      #PSI198714
 
 define lr_retorno record
       coderro    smallint
      ,mensagem   char(100)
 end record
 
 define l_confirma char(1)
       ,l_errcod   smallint
       ,l_errmsg   char(80)

 #--------------------------------------------------------------------
 # Dados do servico
 #--------------------------------------------------------------------


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        let     prompt_key  =  null

        initialize  ws.*  to  null
        initialize lr_retorno.* to null

 initialize l_errcod, l_errmsg to null

 select atdsrvorg   ,
        nom         , vclcoddig   ,
        vcldes      , vclanomdl   ,
        vcllicnum   , corsus      ,
        cornom      , vclcorcod   ,
        funmat      ,
        atddat      , atdhor      ,
        atdlibflg   , atdlibhor   ,
        atdlibdat   , atdhorpvt   ,
        atdpvtretflg, atddatprg   ,
        atdhorprg   , asitipcod   ,
        atdrsdflg   , atddfttxt   ,
        atdfnlflg   , srvprlflg   ,
        atdvcltip   , atdprinvlcod,
        ciaempcod   , prslocflg
   into d_cts03m00.atdsrvorg,
        d_cts03m00.nom      ,
        d_cts03m00.vclcoddig,
        d_cts03m00.vcldes   ,
        d_cts03m00.vclanomdl,
        d_cts03m00.vcllicnum,
        d_cts03m00.corsus   ,
        d_cts03m00.cornom   ,
        ws.vclcorcod        ,
        ws.funmat           ,
        w_cts03m00.atddat   ,
        w_cts03m00.atdhor   ,
        d_cts03m00.atdlibflg,
        d_cts03m00.atdlibhor,
        d_cts03m00.atdlibdat,
        w_cts03m00.atdhorpvt,
        w_cts03m00.atdpvtretflg,
        w_cts03m00.atddatprg,
        w_cts03m00.atdhorprg,
        d_cts03m00.asitipcod,
        d_cts03m00.atdrsdflg,
        d_cts03m00.atddfttxt,
        w_cts03m00.atdfnlflg,
        d_cts03m00.srvprlflg,
        w_cts03m00.atdvcltip,
        d_cts03m00.atdprinvlcod,
        g_documento.ciaempcod,
        d_cts03m00.prslocflg
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    prompt "" for char prompt_key
    return
 end if

 #---------------------------------------------------#
   let g_documento.atdsrvorg = d_cts03m00.atdsrvorg
 #---------------------------------------------------#

 # PSI-2013-00440PR
 # identificar cota de agendamento ja realizado (ALT)
 call cts02m08_sel_cota(g_documento.atdsrvnum, g_documento.atdsrvano)
      returning l_errcod, l_errmsg, m_rsrchvant
 
 #if l_errcod = 0
 #   then
 #   #display 'cts02m08_sel_cota ok'
 #else
 #   #display 'cts02m08_sel_cota erro ', l_errcod
 #   display l_errmsg clipped
 #end if

 call cts02m08_id_datahora_cota(m_rsrchvant)
      returning l_errcod, l_errmsg, m_agncotdatant, m_agncothorant
      
 #if l_errcod != 0
 #   then
 #   #display 'cts02m08_id_datahora_cota(consulta) erro no ID da cota'
 #   display l_errmsg clipped
 #end if
 # PSI-2013-00440PR
 
 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts03m00[1].lclidttxt
                        ,a_cts03m00[1].lgdtip
                        ,a_cts03m00[1].lgdnom
                        ,a_cts03m00[1].lgdnum
                        ,a_cts03m00[1].lclbrrnom
                        ,a_cts03m00[1].brrnom
                        ,a_cts03m00[1].cidnom
                        ,a_cts03m00[1].ufdcod
                        ,a_cts03m00[1].lclrefptotxt
                        ,a_cts03m00[1].endzon
                        ,a_cts03m00[1].lgdcep
                        ,a_cts03m00[1].lgdcepcmp
                        ,a_cts03m00[1].lclltt
                        ,a_cts03m00[1].lcllgt
                        ,a_cts03m00[1].dddcod
                        ,a_cts03m00[1].lcltelnum
                        ,a_cts03m00[1].lclcttnom
                        ,a_cts03m00[1].c24lclpdrcod
                        ,a_cts03m00[1].celteldddcod
                        ,a_cts03m00[1].celtelnum
                        ,a_cts03m00[1].endcmp
                        ,ws.codigosql
                        ,a_cts03m00[1].emeviacod

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts03m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts03m00[1].brrnom,
                                a_cts03m00[1].lclbrrnom)
      returning a_cts03m00[1].lclbrrnom

 select ofnnumdig into a_cts03m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    prompt "" for char prompt_key
    return
 end if

 let a_cts03m00[1].lgdtxt = a_cts03m00[1].lgdtip clipped, " ",
                            a_cts03m00[1].lgdnom clipped, " ",
                            a_cts03m00[1].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         2)
               returning a_cts03m00[2].lclidttxt
                        ,a_cts03m00[2].lgdtip
                        ,a_cts03m00[2].lgdnom
                        ,a_cts03m00[2].lgdnum
                        ,a_cts03m00[2].lclbrrnom
                        ,a_cts03m00[2].brrnom
                        ,a_cts03m00[2].cidnom
                        ,a_cts03m00[2].ufdcod
                        ,a_cts03m00[2].lclrefptotxt
                        ,a_cts03m00[2].endzon
                        ,a_cts03m00[2].lgdcep
                        ,a_cts03m00[2].lgdcepcmp
                        ,a_cts03m00[2].lclltt
                        ,a_cts03m00[2].lcllgt
                        ,a_cts03m00[2].dddcod
                        ,a_cts03m00[2].lcltelnum
                        ,a_cts03m00[2].lclcttnom
                        ,a_cts03m00[2].c24lclpdrcod
                        ,a_cts03m00[2].celteldddcod
                        ,a_cts03m00[2].celtelnum
                        ,a_cts03m00[2].endcmp
                        ,ws.codigosql
                        ,a_cts03m00[2].emeviacod

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[2].lclbrrnom = a_cts03m00[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts03m00[2].brrnom,
                                a_cts03m00[2].lclbrrnom)
      returning a_cts03m00[2].lclbrrnom

 select ofnnumdig into a_cts03m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 2

 if ws.codigosql = notfound   then
    let d_cts03m00.dstflg = "N"
 else
    if ws.codigosql = 0   then
       let d_cts03m00.dstflg = "S"
    else
       error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       prompt "" for char prompt_key
       return
    end if
 end if

 let a_cts03m00[2].lgdtxt = a_cts03m00[2].lgdtip clipped, " ",
                            a_cts03m00[2].lgdnom clipped, " ",
                            a_cts03m00[2].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Dados complementares do servico
 #--------------------------------------------------------------------
 select rmcacpflg, vclcamtip,
        vclcrcdsc, vclcrgflg,
        vclcrgpso, sindat   ,
        sinhor
   into d_cts03m00.rmcacpflg,
        w_cts03m00.vclcamtip,
        w_cts03m00.vclcrcdsc,
        w_cts03m00.vclcrgflg,
        w_cts03m00.vclcrgpso,
        d_cts03m00.sindat   ,
        d_cts03m00.sinhor
   from datmservicocmp
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 #--------------------------------------------------------------------
 # Verifica se socorro tem ASSISTENCIA A PASSAGEIRO relacionada.
 #--------------------------------------------------------------------
 declare ccts03m00002  cursor for
    select datmservico.atdsrvorg     ,
           datmassistpassag.atdsrvnum,
           datmassistpassag.atdsrvano
      from DATMASSISTPASSAG,
           DATMSERVICO
     where datmassistpassag.refatdsrvnum = g_documento.atdsrvnum
       and datmassistpassag.refatdsrvano = g_documento.atdsrvano
       and datmservico.atdsrvnum = datmassistpassag.atdsrvnum
       and datmservico.atdsrvano = datmassistpassag.atdsrvano
     order by atdsrvnum, atdsrvano

 foreach ccts03m00002 into ws.atdsrvorg,
                       ws.atdsrvnum,
                       ws.atdsrvano
 end foreach

 if ws.atdsrvnum is null  or
    ws.atdsrvano is null  then
    initialize d_cts03m00.refasstxt to null
 else
    let d_cts03m00.refasstxt = "ASS.PASSAG. ", ws.atdsrvorg using "&&",
                                          "/", ws.atdsrvnum using "&&&&&&&",
                                          "-", ws.atdsrvano using "&&"
 end if

 let w_cts03m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts03m00.lignum)
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
    let d_cts03m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto Succod
                                     " ", g_documento.ramcod    using "&&&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts03m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if
 # CARREGA TODAS AS GLOBAIS
 call cts20g01_docto_tot(w_cts03m00.lignum)
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


#--------------------------------------------------------------------
# Dados da LIGACAO
#--------------------------------------------------------------------

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts03m00.c24astcod,
        w_cts03m00.ligcvntip,
        d_cts03m00.c24solnom
   from datmligacao
  where lignum = w_cts03m00.lignum

 let g_documento.c24astcod = d_cts03m00.c24astcod

 select lignum
   from datmligfrm
  where lignum = w_cts03m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts03m00.frmflg = "N"
 else
    let d_cts03m00.frmflg = "S"
 end if

 select cpodes into d_cts03m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip" and
        cpocod = w_cts03m00.ligcvntip

 #--------------------------------------------------------------------
 # Descricao do ASSUNTO
 #--------------------------------------------------------------------
 let d_cts03m00.c24astdes = c24geral8(d_cts03m00.c24astcod)

 let d_cts03m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts03m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod

 select empcod
   into ws.empcod
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum
    and atdsrvano = g_documento.atdsrvano

 let ws.funnom = "** NAO CADASTRADO **"

# select funnom, dptsgl                              #Johnny,Biz
#   into ws.funnom, ws.dptsgl
#   from isskfunc
#  where empcod = 1
#    and funmat = ws.funmat
 open c_cts03m00_005 using ws.empcod             #Johnny,Biz
                          ,ws.funmat
 whenever error continue
 fetch c_cts03m00_005 into ws.funnom
                          ,ws.dptsgl
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Problemas ao acesso do cursor c_cts03m00_005.Erro.:"
          ,sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 1
 end if                                              #Johnny,Biz

 let d_cts03m00.atdtxt = w_cts03m00.atddat        clipped, " ",
                         w_cts03m00.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)

 if w_cts03m00.atdhorpvt is not null  or
    w_cts03m00.atdhorpvt =  "00:00"   then
    let d_cts03m00.imdsrvflg = "S"
 end if

 if w_cts03m00.atddatprg is not null  then
    let d_cts03m00.imdsrvflg = "N"
 end if

 if w_cts03m00.vclcamtip is not null  and
    w_cts03m00.vclcamtip <>  " "      then
    let d_cts03m00.camflg = "S"
 else
    if w_cts03m00.vclcrgflg is not null  and
       w_cts03m00.vclcrgflg <>  " "      then
       let d_cts03m00.camflg = "S"
    else
       let d_cts03m00.camflg = "N"
    end if
 end if

 let aux_libant = d_cts03m00.atdlibflg

 if d_cts03m00.atdlibflg      = "N" then
    let d_cts03m00.atdlibdat  = w_cts03m00.atddat
    let d_cts03m00.atdlibhor  = w_cts03m00.atdhor
 end if

 select cpodes
   into d_cts03m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts03m00.atdprinvlcod

 select c24pbmcod
   into d_cts03m00.c24pbmcod
   from datrsrvpbm
  where atdsrvnum    = g_documento.atdsrvnum
    and atdsrvano    = g_documento.atdsrvano
    and c24pbminforg = 1
    and c24pbmseq    = 1

  #verificar se é ou se tem laudo de apoio
  call cts37g00_existeServicoApoio(g_documento.atdsrvnum, g_documento.atdsrvano)
       returning l_tipolaudo
  if l_tipolaudo <> 1 then
     if l_tipolaudo = 2 then
        let d_cts03m00.desapoio = "SERVICO TEM APOIO"
     else
        if l_tipolaudo = 3 then
           let d_cts03m00.desapoio = "SERVICO DE APOIO"
        end if
     end if
  end if
  if g_documento.c24astcod <> 'SAP' then
     call cts10g00_verifica_multiplo(w_cts03m00.lignum)
          returning lr_retorno.*
     if lr_retorno.coderro = 1 then
        call cts08g01("A","N",""," EXISTE UMA SOLICITACAO DE APOIO"," PARA ESTE SERVICO !","")
             returning l_confirma
     end if
  end if

  let m_c24lclpdrcod = a_cts03m00[1].c24lclpdrcod

end function  ###  consulta_cts03m00


#--------------------------------------------------------------------
 function modifica_cts03m00()
#--------------------------------------------------------------------

 define ws           record
    tabname          like systables.tabname     ,
    codigosql        integer,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor
 end record

 define hist_cts03m00 record
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

 define lr_retorno             record
       resultado              smallint,
       mensagem               char(100)
 end record

 define prompt_key char (01)

 define l_data     date,
        l_hora2    datetime hour to minute,
        l_atdsrvseq like datmsrvacp.atdsrvseq
       ,l_errcod   smallint
       ,l_errmsg   char(80)
       
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null
        initialize  lr_retorno.*  to  null

        initialize  hist_cts03m00.*  to  null

        initialize  lr_cts10g02.*  to  null

        let     prompt_key  =  null
        let     l_atdsrvseq =  null

        initialize  ws.*  to  null

        initialize  hist_cts03m00.*  to  null

 initialize ws.*  to null

 initialize l_errcod, l_errmsg  to null
 
 call input_cts03m00() returning hist_cts03m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts03m00      to null
    initialize d_cts03m00.*    to null
    initialize w_cts03m00.*    to null
    clear form
    return false
 end if

#--------------------------------------------------------------------
# Verifica solicitacao de guincho para caminhao
#--------------------------------------------------------------------
 if d_cts03m00.asitipcod = 1  or       ###  Guincho
    d_cts03m00.asitipcod = 3  then     ###  Guincho/Tecnico
    if d_cts03m00.camflg = "S"  then
       let w_cts03m00.atdvcltip = 3
    end if
 end if

 #display 'cts03m00 - Modificar atendimento'
 
 #whenever error continue

 begin work

 if m_imdsrvflg_ant <> d_cts03m00.imdsrvflg and
    g_documento.acao = "ALT" then

    call cts40g03_data_hora_banco(2) returning l_data, l_hora2

    let d_cts03m00.atdlibdat = l_data
    let d_cts03m00.atdlibhor = l_hora2

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
                      = ( d_cts03m00.nom,
                          d_cts03m00.corsus,
                          d_cts03m00.cornom,
                          d_cts03m00.vclcoddig,
                          d_cts03m00.vcldes,
                          d_cts03m00.vclanomdl,
                          d_cts03m00.vcllicnum,
                          w_cts03m00.vclcorcod,
                          d_cts03m00.atdrsdflg,
                          d_cts03m00.atdlibflg,
                          d_cts03m00.atdlibhor,
                          d_cts03m00.atdlibdat,
                          w_cts03m00.atdhorpvt,
                          w_cts03m00.atddatprg,
                          w_cts03m00.atdhorprg,
                          d_cts03m00.asitipcod,
                          d_cts03m00.srvprlflg,
                          w_cts03m00.atdpvtretflg,
                          w_cts03m00.atdvcltip,
                          d_cts03m00.atdprinvlcod,
                          d_cts03m00.prslocflg   )
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano

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
                        d_cts03m00.c24pbmcod,
                        d_cts03m00.atddfttxt,
                        ""                  ) # Codigo prestador
        returning ws.codigosql,
                  ws.tabname
   if ws.codigosql <> 0 then
      error "ctx09g02_altera", ws.codigosql, ws.tabname
      rollback work
      prompt "" for char prompt_key
      return false
   end if

   if g_documento.acao is null then
#     call ctc61m02(g_documento.atdsrvnum,
#                   g_documento.atdsrvano,
#                   "A")
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

 update datmservicocmp
    set ( rmcacpflg ,
          vclcamtip ,
          vclcrcdsc ,
          vclcrgflg ,
          vclcrgpso ,
          sindat    ,
          sinhor )
      = ( d_cts03m00.rmcacpflg,
          w_cts03m00.vclcamtip,
          w_cts03m00.vclcrcdsc,
          w_cts03m00.vclcrgflg,
          w_cts03m00.vclcrgpso,
          d_cts03m00.sindat   ,
          d_cts03m00.sinhor )
    where atdsrvnum = g_documento.atdsrvnum  and
          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos complementos do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 2
    if a_cts03m00[arr_aux].operacao is null  then
       let a_cts03m00[arr_aux].operacao = "M"
    end if

    if  (arr_aux = 1 and d_cts03m00.frmflg = "N") or arr_aux = 2 then
        let a_cts03m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    end if

    let ws.codigosql = cts06g07_local(a_cts03m00[arr_aux].operacao
                                     ,g_documento.atdsrvnum
                                     ,g_documento.atdsrvano
                                     ,arr_aux
                                     ,a_cts03m00[arr_aux].lclidttxt
                                     ,a_cts03m00[arr_aux].lgdtip
                                     ,a_cts03m00[arr_aux].lgdnom
                                     ,a_cts03m00[arr_aux].lgdnum
                                     ,a_cts03m00[arr_aux].lclbrrnom
                                     ,a_cts03m00[arr_aux].brrnom
                                     ,a_cts03m00[arr_aux].cidnom
                                     ,a_cts03m00[arr_aux].ufdcod
                                     ,a_cts03m00[arr_aux].lclrefptotxt
                                     ,a_cts03m00[arr_aux].endzon
                                     ,a_cts03m00[arr_aux].lgdcep
                                     ,a_cts03m00[arr_aux].lgdcepcmp
                                     ,a_cts03m00[arr_aux].lclltt
                                     ,a_cts03m00[arr_aux].lcllgt
                                     ,a_cts03m00[arr_aux].dddcod
                                     ,a_cts03m00[arr_aux].lcltelnum
                                     ,a_cts03m00[arr_aux].lclcttnom
                                     ,a_cts03m00[arr_aux].c24lclpdrcod
                                     ,a_cts03m00[arr_aux].ofnnumdig
                                     ,a_cts03m00[arr_aux].emeviacod
                                     ,a_cts03m00[arr_aux].celteldddcod
                                     ,a_cts03m00[arr_aux].celtelnum
                                     ,a_cts03m00[arr_aux].endcmp)

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

 if aux_libant <> d_cts03m00.atdlibflg  then
    if d_cts03m00.atdlibflg = "S"  then
       let w_cts03m00.atdetpcod = 1
       let ws.atdetpdat = d_cts03m00.atdlibdat
       let ws.atdetphor = d_cts03m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let w_cts03m00.atdetpcod = 2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    let w_retorno = cts10g04_insere_etapa(g_documento.atdsrvnum,
                                          g_documento.atdsrvano,
                                          w_cts03m00.atdetpcod,
                                          w_cts03m00.atdprscod,
                                          " ",
                                          " ",
                                          w_cts03m00.srrcoddig)

    if w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if

 end if

 #whenever error stop
 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

 #display 'cts03m00 - Variaveis antes de confirmar a alteracao de reserva:'
 #display 'm_altcidufd: ', m_altcidufd
 #display 'm_altdathor: ', m_altdathor
 #display 'm_operacao : ', m_operacao 
 #display 'm_altdathor: ', m_altdathor
 #display 'm_imdsrvflg: ', m_imdsrvflg
 
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
    call cts03m00_grava_historico()
 end if
 
 #-----------------------------------------------
 # Aciona Servico automaticamente
 #-----------------------------------------------
 # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  #Alteracao projeto cadastro de destino
  if w_cts03m00.atdfnlflg <> "S"  then

     if cts34g00_acion_auto (d_cts03m00.atdsrvorg,
                             a_cts03m00[1].cidnom,
                             a_cts03m00[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO

        if not cts40g12_regras_aciona_auto (d_cts03m00.atdsrvorg,
                                            g_documento.c24astcod,
                                            d_cts03m00.asitipcod,
                                            a_cts03m00[1].lclltt,
                                            a_cts03m00[1].lcllgt,
                                            d_cts03m00.prslocflg,
                                            d_cts03m00.frmflg,
                                            g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            " ",
                                            d_cts03m00.vclcoddig,
                                            d_cts03m00.camflg) then
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
  ###                               a_cts03m00[1].c24lclpdrcod)

  return true

end function  ###  modifica_cts03m00

#-------------------------------------------------------------------------------
function inclui_cts03m00()
#-------------------------------------------------------------------------------

 define hist_cts03m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                   ,

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
        cdtseq          like aeikcdt.cdtseq        ,
        c24astagp       like datkassunto.c24astagp        #psi230650
 end record

 define lr_clausula record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
 end record
 
 define  l_data          date
        ,l_hora2         datetime hour to minute
        ,l_vclcndlclcod  like datrcndlclsrv.vclcndlclcod
        ,l_ret           smallint
        ,l_mensagem      char(60)
        ,l_ciaempcod_slv like datmligacao.ciaempcod
        ,l_confirma      char(1)
        ,l_erro          smallint
        ,l_msg           char(200)
        ,l_atdsrvnum     like datmservico.atdsrvnum
        ,l_atdsrvano     like datmservico.atdsrvano
        ,l_txtsrv        char (15)
        ,l_reserva_ativa smallint # Flag para idenitficar se reserva esta ativa
        ,l_errcod        smallint
        ,l_errmsg        char(80)
       
        
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  hist_cts03m00.*  to  null

        initialize  ws.*  to  null

        initialize  hist_cts03m00.*  to  null

        initialize  ws.*  to  null

        initialize  ws_mtvcaps to  null
        initialize  lr_clausula.* to  null

        let l_atdsrvnum = null
        let l_atdsrvano = null
        let l_txtsrv = null

 initialize l_reserva_ativa, l_errcod,l_errmsg  to null
 
 #display 'cts03m00 - Incluir atendimento'
        
 while true

   initialize ws.*  to null

   #PSI 230650
   select c24astagp into ws.c24astagp
          from datkassunto
          where c24astcod = d_cts03m00.c24astcod

   #if  d_cts03m00.c24astcod[1,1] = "S" or
   if  ws.c24astagp = "S" or                       #psi230650
       d_cts03m00.c24astcod      = "E12"  then     # novo codigo do assunto
       let d_cts03m00.atdsrvorg = 1     # Socorro  # devera entar como Porto
       let ws.atdtip = "3"                         # Socorro.  29/08/2000.
   else
       let d_cts03m00.atdsrvorg = 6     # DAF
       let ws.atdtip = "2"
   end if

   let g_documento.atdsrvorg = d_cts03m00.atdsrvorg
   let g_documento.acao = "INC"
   let ws_mtvcaps       = 0 ---> Campo utilizado para gravar o motivo da
                            ---> recusa em levar o veiculo para CAPS p/
                            ---> assunto S10/S90 (ver lista em iddkdominio)

   call input_cts03m00() returning hist_cts03m00.*

   ###initialize ws.c24txtseq to null
   ###initialize ws.vclatmflg to null

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts03m00      to null
       initialize d_cts03m00.*    to null
       initialize w_cts03m00.*    to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts03m00.data is null  then
       let w_cts03m00.data   = aux_today
       let w_cts03m00.hora   = aux_hora
       let w_cts03m00.funmat = g_issk.funmat
   end if

   if  d_cts03m00.frmflg = "S"  then
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

   if  w_cts03m00.atdfnlflg is null  then
       let w_cts03m00.atdfnlflg = "N"
       let w_cts03m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if


 #------------------------------------------------------------------------------
 # Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO
 #------------------------------------------------------------------------------
   if  g_documento.ramcod = 31    or
       g_documento.ramcod = 531  then
       let ws.vclatmflg = cts02m00_cambio(g_documento.succod   ,
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig )
   end if


 #------------------------------------------------------------------------------
 # Quando o guincho nao for pequeno, atribui a flag de cambio
 # automatico ( 1->tem / null->nao tem ) (?????)
 #------------------------------------------------------------------------------
   if  w_cts03m00.atdvcltip <> 2  then
       let w_cts03m00.atdvcltip = ws.vclatmflg
   end if


 #------------------------------------------------------------------------------
 # Verifica solicitacao de guincho para caminhao
 #------------------------------------------------------------------------------
   if  d_cts03m00.asitipcod = 1  or       ###  Guincho
       d_cts03m00.asitipcod = 3  then     ###  Guincho/Tecnico
       if  d_cts03m00.camflg = "S"  then
           let w_cts03m00.atdvcltip = 3
       end if
   end if

 #===================================================
 # Chama funcao para gravar dados
 #===================================================
   call cts03m00_grava_dados(ws.*,hist_cts03m00.*)
        returning l_ret, l_mensagem, aux_atdsrvnum,
                  aux_atdsrvano
   if l_ret <> 1 then
       error l_mensagem
   else
   	    
   	  
   	  #----------------------------------------------------
   	  # Carrega Atendimento Premium                        
   	  #----------------------------------------------------
   	  
   	  if cty31g00_valida_atd_premium()   and 
   	  	 g_documento.c24astcod = "S10"   then
         
          let l_erro = null                                                           
          let l_msg  = null                                                           
                                                                                      
          begin work                                                                  
                                                                                      
          if (g_documento.lignum is not null and                                      
              g_documento.lignum <> 0)       then                                     
              if (g_documento.atdnum is not null and                                  
                  g_documento.atdnum <> 0 ) then                                      
                                                                                      
                  call ctd25g00_insere_atendimento(g_documento.atdnum                 
                                                  ,g_documento.lignum)                
                       returning l_erro                                               
                                ,l_msg                                                
              end if                                                                  
          end if 
          
          if l_erro = 0 then    
             commit work              
          else                  
             rollback work      
          end if                
          
          
          let g_documento.c24astcod = 'JIT'
          let m_atdsrvorg           = g_documento.atdsrvorg 
          let m_asitipcod           = d_cts03m00.asitipcod
          let g_documento.atdsrvorg = 15 
          let m_premium             = true  
          let d_cts03m00.asitipcod  = 98    
         
          call cts03m00_grava_dados(ws.*,hist_cts03m00.*)                        
          returning l_ret           , 
                    l_mensagem      , 
                    l_atdsrvnum_mult,                  
                    l_atdsrvano_mult                                                   
        
          
          if l_ret <> 1 then                                                     
             error l_mensagem                                                    
          end if 
          
          let  m_atdsrvnum_premium   = l_atdsrvnum_mult           
          let  m_atdsrvano_premium   = l_atdsrvano_mult                                   
          let  g_documento.atdsrvorg = m_atdsrvorg  
          let d_cts03m00.asitipcod   = m_asitipcod                                                               
          
      end if
      
      
   	
      if m_multiplo = 'S' then
         call cts03m00_desbloqueia_servico(aux_atdsrvnum,aux_atdsrvano)
         let l_atdsrvnum = aux_atdsrvnum
         let l_atdsrvano = aux_atdsrvano
         if ((g_documento.lignum is not null and
                 g_documento.lignum <> 0)       or
                (g_lignum_dcr       is not null and
                 g_lignum_dcr       <> 0))      and
               g_documento.atdnum is not null and
               g_documento.atdnum <> 0        then
               for i = 1 to 3
  
                  let l_erro = null
                  let l_msg  = null
  
                  begin work
  
                  if (g_documento.lignum is not null and
                      g_documento.lignum <> 0)       then
                      if (g_documento.atdnum is not null and
                          g_documento.atdnum <> 0 ) then
  
                          call ctd25g00_insere_atendimento(g_documento.atdnum
                                                          ,g_documento.lignum)
                               returning l_erro
                                        ,l_msg
                      end if
                  else
                      if (g_documento.atdnum is not null and
                          g_documento.atdnum <> 0 )      and
                         (g_lignum_dcr is not null       and
                          g_lignum_dcr <>       0)       then
  
                          call ctd25g00_insere_atendimento(g_documento.atdnum
                                                          ,g_lignum_dcr)
                               returning l_erro
                                        ,l_msg
                      end if
                  end if
  
                  if l_erro = 0 then
                     commit work
                     exit for
                  else
                     rollback work
                  end if
               end for
            end if
         let g_documento.c24astcod = 'SAP'
         let d_cts03m00.c24pbmcod = am_param.c24pbmcod
         let d_cts03m00.atddfttxt = am_param.atddfttxt
         let d_cts03m00.asitipcod = am_param.asitipcod
  
         call cts03m00_grava_dados(ws.*,hist_cts03m00.*)
            returning l_ret, l_mensagem, l_atdsrvnum_mult,
                l_atdsrvano_mult
         if l_ret <> 1 then
            error l_mensagem
         end if
         call cts03m00_desbloqueia_servico(aux_atdsrvnum,aux_atdsrvano)
         let aux_atdsrvnum = l_atdsrvnum
         let aux_atdsrvano = l_atdsrvano
       end if 
       
   end if
   
   # Verifica se deve retornar a empresa do serviço aberto no cartao
   if g_documento.ciaempcod <> m_ciaempcod_slv then
      let g_documento.ciaempcod = m_ciaempcod_slv
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
               #display "Chave de regulacao inativa, regular novamente"
               error "Chave de regulacao inativa, selecione agenda novamente"
               
               let m_operacao = 0 
               
               # obter a chave de regulacao no AW
               call cts02m08(w_cts03m00.atdfnlflg,
                             d_cts03m00.imdsrvflg,
                             m_altcidufd,
                             d_cts03m00.prslocflg,
                             w_cts03m00.atdhorpvt,
                             w_cts03m00.atddatprg,
                             w_cts03m00.atdhorprg,
                             w_cts03m00.atdpvtretflg,
                             m_rsrchv,
                             m_operacao,
                             "",
                             a_cts03m00[1].cidnom,
                             a_cts03m00[1].ufdcod,
                             "",   # codigo de assistencia, nao existe no Ct24h
                             d_cts03m00.vclcoddig,
                             w_cts03m00.ctgtrfcod,
                             d_cts03m00.imdsrvflg,
                             a_cts03m00[1].c24lclpdrcod,
                             a_cts03m00[1].lclltt,
                             a_cts03m00[1].lcllgt,
                             g_documento.ciaempcod,
                             d_cts03m00.atdsrvorg,
                             d_cts03m00.asitipcod,
                             "",   # natureza somente RE
                             "")   # sub-natureza somente RE
                   returning w_cts03m00.atdhorpvt,
                             w_cts03m00.atddatprg,
                             w_cts03m00.atdhorprg,
                             w_cts03m00.atdpvtretflg,
                             d_cts03m00.imdsrvflg,
                             m_rsrchv,
                             m_operacao,
                             m_altdathor
                                
               display by name d_cts03m00.imdsrvflg
               
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
               #   #display 'cts02m08_ins_cota erro ', l_errcod
               #   display l_errmsg clipped
               #end if
            else
               #display 'cts03m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
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
   if (g_documento.c24astcod = 'M15' or
      g_documento.c24astcod = 'M20' or
      g_documento.c24astcod = 'M23' or
      g_documento.c24astcod = 'M33') then
     let d_cts03m00.atdsrvorg = g_documento.atdsrvorg
   end if
   
   let d_cts03m00.servico = d_cts03m00.atdsrvorg using "&&",
                            "/", aux_atdsrvnum   using "&&&&&&&",
                            "-", aux_atdsrvano   using "&&"
   display d_cts03m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER! "
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso! "
   let ws.retorno = true

   exit while
 end while
 
 return ws.retorno

end function  ###  inclui_cts03m00

#--------------------------------------------------------------------
function input_cts03m00()
#--------------------------------------------------------------------

 define hist_cts03m00 record
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
    codigosql         integer,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    opcao             smallint,
    opcaodes          char(20),
    ofnstt            like sgokofi.ofnstt,
    rglflg            smallint,
    cidnom            char(40),
    erro              char(11),
    codpais           char(40),
    despais           smallint
 end record

 define prompt_key    char (01)
 define tip_mvt       char (01)
 define tmp_flg       smallint
 define l_acesso      smallint
 define l_vclcoddig_contingencia like datmservico.vclcoddig

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_salva_nom like datmservico.nom

 define l_tipolaudo    smallint,      #PSI198714
        l_atdsrvnum    like datmservico.atdsrvnum,
        l_atdsrvano    like datmservico.atdsrvano,
        l_aux          smallint,
        l_flag_limite  char(1),
        l_msg          char(50),
        l_msg1         char (50),
        l_msg2         char (50),
        l_msg3         char (50),
        l_cidcod       decimal(8,0),
        l_endlgdcmp    like avgmcappstend.endlgdcmp,
        l_lim_km       decimal (8,3)
       ,l_gchvclinchor like avgmcappsthor.gchvclinchor
       ,l_gchvcfnlhor  like avgmcappsthor.gchvcfnlhor
       ,l_confirma     char(1)
       ,l_c24astcod    like datkassunto.c24astcod
       ,l_mensagem     char(300)
       ,l_erro         smallint
       ,l_atdetpcod    like datmsrvacp.atdetpcod
       ,l_status       smallint
       ,l_resposta      char(1)
       ,l_limite       char(1)
       ,l_limite_km    smallint
       ,l_flag_atende  char(01)
       ,l_lgdnom       like datmlcl.lgdnom
       ,l_errcod       smallint
       ,l_errmsg       char(80)
       
 define l_cty26g01_retorno record
        cod_erro           char(40),
        clscod             like datrsrvcls.clscod,
        data_calculo       date    ,
        flag_endosso       char(01)
 end record
 
 define l_cty26g00_retorno record
        autimsvlr          like abbmcasco.imsvlr
 end record
 
 define l_mpacidcod     like datkmpacid.mpacidcod
 
 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
 to null
 
 initialize l_errcod, l_errmsg to null     
       
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
        let     prompt_key  =  null
        let     tip_mvt     =  null
        let     tmp_flg     =  null
        let     l_vclcoddig_contingencia  =  null
        let     l_msg       =  null
        let     l_lim_km    =  0
        let     l_gchvclinchor = null
        let     l_gchvcfnlhor  = null
        let     l_c24astcod = null
        let     l_mensagem = null
        let     l_atdetpcod = null
        let     l_status = null
        let     l_limite_km   = null
        let     l_flag_atende = null 
        let     l_lgdnom = null 
        let     l_mpacidcod  = null      

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  hist_cts03m00.*  to  null

        initialize  ws.*  to  null
        initialize am_param to null

 let     prompt_key  =  null
 let     l_resposta = "N"
 initialize  hist_cts03m00.*  to  null
 let l_limite = null

 initialize  ws.*  to  null

 initialize ws.*  to null

 let m_grava_hist = false
 let m_cappstcod  = null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
      
 let ws.dtparam        = l_data using "yyyy-mm-dd"
 let ws.dtparam[12,16] = l_hora2

 let ws.vcllicant          = d_cts03m00.vcllicnum
 let d_cts03m00.srvprlflg  =  "N"

 let l_vclcoddig_contingencia = d_cts03m00.vclcoddig
 let l_salva_nom              = d_cts03m00.nom
 
 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if
 
 # situacao original do servico
 let m_imdsrvflg = d_cts03m00.imdsrvflg
 let m_cidnom = a_cts03m00[1].cidnom
 let m_ufdcod = a_cts03m00[1].ufdcod
 # PSI-2013-00440PR
 
 
 #display 'entrada do input, var null ou carregada na consulta'
 #display 'd_cts03m00.imdsrvflg :', d_cts03m00.imdsrvflg
 #display 'a_cts03m00[1].cidnom :', a_cts03m00[1].cidnom
 #display 'a_cts03m00[1].ufdcod :', a_cts03m00[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant
 #display 'w_cts03m00.ctgtrfcod :', w_cts03m00.ctgtrfcod
 

 input by name d_cts03m00.nom         ,
               d_cts03m00.corsus      ,
               d_cts03m00.cornom      ,
               d_cts03m00.vclcoddig   ,
               d_cts03m00.vclanomdl   ,
               d_cts03m00.vcllicnum   ,
               d_cts03m00.vclcordes   ,
               d_cts03m00.frmflg      ,
               d_cts03m00.camflg      ,
               d_cts03m00.c24pbmcod   ,
               d_cts03m00.atddfttxt   ,
               a_cts03m00[1].lgdtxt   ,
               a_cts03m00[1].lclbrrnom,
               a_cts03m00[1].cidnom   ,
               a_cts03m00[1].ufdcod   ,
               a_cts03m00[1].lclrefptotxt,
               a_cts03m00[1].endzon   ,
               a_cts03m00[1].dddcod   ,
               a_cts03m00[1].lcltelnum,
               a_cts03m00[1].lclcttnom,
               d_cts03m00.sindat      ,
               d_cts03m00.sinhor      ,
               d_cts03m00.atdrsdflg   ,
               d_cts03m00.asitipcod   ,
               d_cts03m00.dstflg      ,
               d_cts03m00.rmcacpflg   ,
               d_cts03m00.atdprinvlcod,
               d_cts03m00.prslocflg   ,
             # d_cts03m00.srvprlflg   ,
               d_cts03m00.atdlibflg   ,
               d_cts03m00.imdsrvflg
        without defaults

   before field nom
          display by name d_cts03m00.nom        attribute (reverse)

          if g_documento.atdsrvnum   is not null   and
             g_documento.atdsrvano   is not null   and
             d_cts03m00.camflg       =  "S"        and
             (w_cts03m00.atdfnlflg    =  "N" or w_cts03m00.atdfnlflg = "A") then
             call cts02m01(w_cts03m00.ctgtrfcod,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           w_cts03m00.vclcrgflg, w_cts03m00.vclcrgpso,
                           w_cts03m00.vclcamtip, w_cts03m00.vclcrcdsc)
                 returning w_cts03m00.vclcrgflg, w_cts03m00.vclcrgpso,
                           w_cts03m00.vclcamtip, w_cts03m00.vclcrcdsc
          end if


   after  field nom
          display by name d_cts03m00.nom

          if g_documento.acao = "CON" then
             error " Servico sendo consultado, nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                  returning ws.confirma
             
             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then   
                
                if g_cidcod is null or g_cidcod = 0 then
                    open  ccts03m00013 using m_cidnom
                                            ,m_ufdcod
                    fetch ccts03m00013  into l_mpacidcod
                    close ccts03m00013
                    
                    if l_mpacidcod is not null and l_mpacidcod <> 0  then                                        
                        call cts06g03_carrega_glo(1,g_documento.atdsrvorg,l_mpacidcod, '')
                    end if
                 end if  
                
                call cts02m03("S"                 ,
                              d_cts03m00.imdsrvflg,
                              w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg)
                    returning w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg
             else
                # selecionada consulta, somente obter os dados para mostrar 
                call cts02m08("S"                 ,
                              d_cts03m00.imdsrvflg,
                              m_altcidufd,
                              d_cts03m00.prslocflg,
                              w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts03m00[1].cidnom,
                              a_cts03m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts03m00.vclcoddig,
                              w_cts03m00.ctgtrfcod,
                              d_cts03m00.imdsrvflg,
                              a_cts03m00[1].c24lclpdrcod,
                              a_cts03m00[1].lclltt,
                              a_cts03m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts03m00.atdsrvorg,
                              d_cts03m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg,
                              d_cts03m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             next field nom
          end if

          if d_cts03m00.nom is null or
             d_cts03m00.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if

          # servico ja acionado, somente obter os dados para mostrar
          if w_cts03m00.atdfnlflg = "S"  then

             # ---> SALVA O NOME DO SEGURADO
             let d_cts03m00.nom = l_salva_nom
             display by name d_cts03m00.nom

             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                        " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                        "E INFORME AO  ** CONTROLE DE TRAFEGO **")
             
             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then        
                
                if g_cidcod is null or g_cidcod = 0 then
                    open  ccts03m00013 using m_cidnom
                                            ,m_ufdcod
                    fetch ccts03m00013  into l_mpacidcod
                    close ccts03m00013
                    
                    if l_mpacidcod is not null and l_mpacidcod <> 0  then                                        
                        call cts06g03_carrega_glo(1,g_documento.atdsrvorg,l_mpacidcod, '')
                    end if
                 end if                
                
                call cts02m03("S",
                              d_cts03m00.imdsrvflg,
                              w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg)
                    returning w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg
	          else
                call cts02m08("S",
                              d_cts03m00.imdsrvflg,
                              m_altcidufd,
                              d_cts03m00.prslocflg,
                              w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts03m00[1].cidnom,
                              a_cts03m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts03m00.vclcoddig,
                              w_cts03m00.ctgtrfcod,
                              d_cts03m00.imdsrvflg,
                              a_cts03m00[1].c24lclpdrcod,
                              a_cts03m00[1].lclltt,
                              a_cts03m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts03m00.atdsrvorg,
                              d_cts03m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg,
                              d_cts03m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             
             if d_cts03m00.frmflg = "S" then
                call cts11g00(w_cts03m00.lignum)
                let int_flag = true
             end if
             
             exit input
          end if

   before field corsus
          display by name d_cts03m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts03m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.corsus is not null  then
                select cornom
                  into d_cts03m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts03m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts03m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts03m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts03m00.cornom

   before field vclcoddig
          display by name d_cts03m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts03m00.vclcoddig

          # se outro processo nao obteve cat. tarifaria, obter
          if w_cts03m00.ctgtrfcod is null
             then
             # laudo auto obter cod categoria tarifaria
             call cts02m08_sel_ctgtrfcod(d_cts03m00.vclcoddig)
                  returning l_errcod, l_errmsg, w_cts03m00.ctgtrfcod
          end if
          
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts03m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts03m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts03m00.vclcoddig is null  or
                d_cts03m00.vclcoddig =  0     then
                let d_cts03m00.vclcoddig = agguvcl()
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts03m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             let d_cts03m00.vcldes = cts15g00(d_cts03m00.vclcoddig)

             display by name d_cts03m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts03m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts03m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.vclanomdl is null or
                d_cts03m00.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts03m00.vclcoddig, d_cts03m00.vclanomdl) = false  then
                   error " Veiculo nao consta como fabricado em ", d_cts03m00.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts03m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts03m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts03m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

        #------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------
        if g_documento.aplnumdig   is null      and
           d_cts03m00.vcllicnum    is not null  then

           if d_cts03m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.senhaok  to null

              call cts13g00(d_cts03m00.c24astcod,
                            "", "", "", "",
                            d_cts03m00.vcllicnum,
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

           #---------------------------------------------------------------
           # Verifica se ja' houve solicitacao de servico para apolice
           #---------------------------------------------------------------
           call cts03g00 (1, g_documento.ramcod   ,
                             g_documento.succod   ,
                             g_documento.aplnumdig,
                             g_documento.itmnumdig,
                             d_cts03m00.vcllicnum ,
                             g_documento.atdsrvnum,
                             g_documento.atdsrvano)
        end if

   before field vclcordes
          display by name d_cts03m00.vclcordes  attribute (reverse)

   after  field vclcordes
          display by name d_cts03m00.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.vclcordes is not null then
                let w_cts03m00.vclcordes = d_cts03m00.vclcordes[2,9]

                select cpocod into  w_cts03m00.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts03m00.vclcordes

                if sqlca.sqlcode = notfound  then
                   error " Cor fora do padrao!"
                   call c24geral4()
                        returning w_cts03m00.vclcorcod, d_cts03m00.vclcordes

                   if w_cts03m00.vclcorcod  is null   then
                      error " Cor do veiculo deve ser informado!"
                      next field vclcordes
                   else
                      display by name d_cts03m00.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts03m00.vclcorcod, d_cts03m00.vclcordes

                if w_cts03m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts03m00.vclcordes
                end if
             end if
             let d_cts03m00.frmflg = "N"
             display by name d_cts03m00.frmflg
             next field camflg
          end if

   before field frmflg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             let d_cts03m00.frmflg = "N"
             display by name d_cts03m00.frmflg attribute (reverse)
          else
             next field camflg
          end if

   after  field frmflg
          display by name d_cts03m00.frmflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.frmflg = "S"  then

                call cts02m05(6) returning w_cts03m00.data     ,
                                           w_cts03m00.hora     ,
                                           w_cts03m00.funmat   ,
                                           w_cts03m00.cnldat   ,
                                           w_cts03m00.atdfnlhor,
                                           w_cts03m00.c24opemat,
                                           w_cts03m00.atdprscod

                if w_cts03m00.hora      is null  or
                   w_cts03m00.data      is null  or
                   w_cts03m00.funmat    is null  or
                   w_cts03m00.cnldat    is null  or
                   w_cts03m00.atdfnlhor is null  or
                   w_cts03m00.c24opemat is null  or
                   w_cts03m00.atdprscod is null  then
                   error " Faltam dados para entrada via formulario!"
                   next field frmflg
                end if

                let d_cts03m00.atdlibhor = w_cts03m00.hora
                let d_cts03m00.atdlibdat = w_cts03m00.data
                let w_cts03m00.atdfnlflg = "S"
                let w_cts03m00.atdetpcod =  4
                let d_cts03m00.imdsrvflg    = "S"
                let w_cts03m00.atdhorpvt    = "00:00"
                let w_cts03m00.atdpvtretflg = "N"
                let d_cts03m00.atdprinvlcod =  2
                let d_cts03m00.atdlibflg    = 'S'
                display by name d_cts03m00.imdsrvflg
                display by name d_cts03m00.atdprinvlcod
             else
                if d_cts03m00.prslocflg  =  "N"   then
                   initialize w_cts03m00.hora,
                              w_cts03m00.data,
                              w_cts03m00.funmat   ,
                              w_cts03m00.cnldat   ,
                              w_cts03m00.atdfnlhor,
                              w_cts03m00.c24opemat,
                              w_cts03m00.atdfnlflg,
                              w_cts03m00.atdetpcod,
                              w_cts03m00.atdprscod to null
                end if
             end if
          end if
   before field camflg
          display by name d_cts03m00.camflg attribute (reverse)

   after  field camflg
          display by name d_cts03m00.camflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts03m00.camflg  is null)  or
                 (d_cts03m00.camflg  <>  "S"   and
                  d_cts03m00.camflg  <>  "N")) then
                error " Informacao sobre caminhao/utilitario invalida!"
                next field camflg
             end if

             if d_cts03m00.frmflg = "S"  then
                initialize w_cts03m00.vclcamtip to null
                initialize w_cts03m00.vclcrcdsc to null
                initialize w_cts03m00.vclcrgflg to null
                initialize w_cts03m00.vclcrgpso to null
                next field c24pbmcod
             end if

             if d_cts03m00.camflg = "S"  then
                call cts02m01(w_cts03m00.ctgtrfcod,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              w_cts03m00.vclcrgflg, w_cts03m00.vclcrgpso,
                              w_cts03m00.vclcamtip, w_cts03m00.vclcrcdsc)
                    returning w_cts03m00.vclcrgflg, w_cts03m00.vclcrgpso,
                              w_cts03m00.vclcamtip, w_cts03m00.vclcrcdsc

                if w_cts03m00.vclcamtip  is null   and
                   w_cts03m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                   next field camflg
                end if
             else
                initialize w_cts03m00.vclcamtip to null
                initialize w_cts03m00.vclcrcdsc to null
                initialize w_cts03m00.vclcrgflg to null
                initialize w_cts03m00.vclcrgpso to null
             end if
          end if

    before field c24pbmcod
        display by name d_cts03m00.c24pbmcod attribute (reverse)
        if d_cts03m00.c24astcod = 'SLV' or
           d_cts03m00.c24astcod = 'SLT' then
           call cts00m42_recupera_problema(d_cts03m00.c24astcod)
           returning ws.c24pbmgrpcod       ,
                     ws.c24pbmgrpdes       ,
                     d_cts03m00.c24pbmcod  ,
                     d_cts03m00.atddfttxt
           display by name d_cts03m00.c24pbmcod
        end if
        #call cts00m42_recupera_problema(d_cts03m00.c24astcod)
        #returning ws.c24pbmgrpcod       ,
        #          ws.c24pbmgrpdes       ,
        #          d_cts03m00.c24pbmcod  ,
        #          d_cts03m00.atddfttxt

    after  field c24pbmcod
        display by name d_cts03m00.c24pbmcod

        #--> PSI-2012-16039/EV - Inicio
        #------------------------------
        #if d_cts03m00.c24pbmcod = 998 or
        #   d_cts03m00.c24pbmcod = 999 then
        #   call cty26g01_clausula(g_documento.succod   ,
        #                          g_documento.aplnumdig,
        #                          g_documento.itmnumdig)
        #      returning l_cty26g01_retorno.cod_erro    ,
        #                l_cty26g01_retorno.clscod      ,
        #                l_cty26g01_retorno.data_calculo,
        #                l_cty26g01_retorno.flag_endosso
        #end if
        #if d_cts03m00.c24pbmcod   = 839 then
        #   call cty26g00_ims_veic(g_documento.succod   ,
        #                          g_documento.aplnumdig,
        #                          g_documento.itmnumdig)
        #      returning l_cty26g00_retorno.autimsvlr
        #
        #   if l_cty26g00_retorno.autimsvlr <= 110000  and
        #      l_cty26g01_retorno.clscod    <> '044'  then
        #      error 'Problema nao autorizado para a clausula da apolice '
        #      next field c24pbmcod
        #   end if
        #end if
        #if (d_cts03m00.c24pbmcod      = 839 or
        #    d_cts03m00.c24pbmcod      = 445 or
        #    d_cts03m00.c24pbmcod      = 413) and
        #    l_cty26g01_retorno.clscod <> '044' then
        #   error 'Problema nao autorizado para a clausula desta apolice'
        #   next field c24pbmcod
        #end if
        #--> PSI-2012-16039/EV - Final
        #-----------------------------
        if d_cts03m00.c24astcod = 'SLV' or
           d_cts03m00.c24astcod = 'SLT' then
           call cts00m42_recupera_problema(d_cts03m00.c24astcod)
           returning ws.c24pbmgrpcod       ,
                     ws.c24pbmgrpdes       ,
                     d_cts03m00.c24pbmcod  ,
                     d_cts03m00.atddfttxt
           display by name d_cts03m00.c24pbmcod
           display by name d_cts03m00.atddfttxt
        end if
        if d_cts03m00.c24pbmcod  is null  or
           d_cts03m00.c24pbmcod  =  0     then
           if d_cts03m00.c24astcod = 'K02' then
              let d_cts03m00.atdsrvorg = 1
           end if
           call ctc48m02(d_cts03m00.atdsrvorg) returning ws.c24pbmgrpcod,
                                                         ws.c24pbmgrpdes
           if ws.c24pbmgrpcod  is null  then
              error " Codigo de problema deve ser informado!"
              next field c24pbmcod
           else
               if d_cts03m00.c24astcod = 'S85' then
                  call cts03m00_limite_s85(ws.c24pbmgrpcod)
                       returning l_limite
                  if l_limite = true then
                     call cts08g01('A' ,'S'
                                  ,'LIMITE ESGOTADO. '
                                  ,'CONSULTE A COORDENACAO, '
                                  ,'PARA ENVIO DE ATENDIMENTO . '
                                  ,'' )
                                    returning ws.confirma
                  next field c24pbmcod
                  end if
               end if
               call ctc48m01(ws.c24pbmgrpcod,"")
                               returning d_cts03m00.c24pbmcod,
                                         d_cts03m00.atddfttxt
               if d_cts03m00.c24pbmcod is null  then
                  error " Codigo de problema deve ser informado!"
                  next field c24pbmcod
               else
               	  call cts00m42_valida_problema(d_cts03m00.c24astcod,
               	                                d_cts03m00.c24pbmcod,
               	                                d_cts03m00.atddfttxt)
               	  returning d_cts03m00.c24pbmcod,
               	            d_cts03m00.atddfttxt
               end if
           end if
        else
           #if d_cts03m00.c24pbmcod <> 999 then
              call cts00m42_valida_problema(d_cts03m00.c24astcod,
                                            d_cts03m00.c24pbmcod,
                                            d_cts03m00.atddfttxt)
              returning d_cts03m00.c24pbmcod,
                        d_cts03m00.atddfttxt
               if cty31g00_valida_clausula() then
               	      if not cty34g00_valida_problema(d_cts03m00.c24astcod,d_cts03m00.c24pbmcod) then
               	         error " Codigo de Problema Invalido!"
               	         next field c24pbmcod
               	      end if
               end if
              
               select c24pbmdes, c24pbmgrpcod 
               into d_cts03m00.atddfttxt, ws.c24pbmgrpcod 
               from datkpbm
               where c24pbmcod = d_cts03m00.c24pbmcod
              
              if status = notfound then
                 error " Codigo de problema invalido !"
                 if d_cts03m00.c24astcod = 'K02' then
                    let d_cts03m00.atdsrvorg = 1
                 end if
                 call ctc48m02(d_cts03m00.atdsrvorg) returning ws.c24pbmgrpcod,
                                                               ws.c24pbmgrpdes
                 if ws.c24pbmgrpcod  is null  then
                    error " Codigo de problema deve ser informado!"
                    next field c24pbmcod
                 else
                     call ctc48m01(ws.c24pbmgrpcod,"")
                                     returning d_cts03m00.c24pbmcod,
                                               d_cts03m00.atddfttxt
                     if d_cts03m00.c24pbmcod is null  then
                        error " Codigo de problema deve ser informado!"
                        next field c24pbmcod
                     end if
                 end if
              end if
           #end if
        end if

        open c_cts03m00_004 using d_cts03m00.c24pbmcod
        fetch c_cts03m00_004 into d_cts03m00.asitipcod

        let d_cts03m00.asitipabvdes = ""

        select asitipabvdes, asiofndigflg, vclcndlclflg
          into d_cts03m00.asitipabvdes
          from datkasitip
         where asitipcod = d_cts03m00.asitipcod
           and asitipstt = "A"

        display by name d_cts03m00.asitipcod,
                        d_cts03m00.asitipabvdes

        display by name d_cts03m00.c24pbmcod
        display by name d_cts03m00.atddfttxt

   before field atddfttxt
          display by name d_cts03m00.atddfttxt   attribute (reverse)
          if d_cts03m00.c24pbmcod <> 999 then
             next field lgdtxt
          end if

   after  field atddfttxt
          display by name d_cts03m00.atddfttxt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.atddfttxt is null  then
                error " Problema ou defeito deve ser informado!"
                next field atddfttxt
             end if
          end if

   before field lgdtxt
          if d_cts03m00.frmflg = "S"  then
             display by name a_cts03m00[1].lgdtxt attribute (reverse)
          else
             if d_cts03m00.c24astcod = "SLT" then
                ---> So sugere o CAPS se estiver incluindo Laudo
                if g_documento.acao = "INC" then
                   whenever error continue
                   ---> Verifica se Assuntos estao ligados ao CAPS
                   select cponom
                     from iddkdominio
                    where cponom = "c24astcod_caps"
                   and cpodes =  d_cts03m00.c24astcod
                   whenever error stop
                   if sqlca.sqlcode <> notfound  then
                         --> Verifica se ha Postos Caps que atendem o Servico
                         call oavpc071_consultadisponibilidadepostoscaps(
                                       w_cts03m00.ctgtrfcod
                                      ,ws.c24pbmgrpcod)
                              returning l_stt
                         --> Encontrou Posto que Atende o Servico desejado
                         if l_stt <> 0 then

                            initialize l_stt to null
                            let l_lim_km = 50 ---> Fora da Residencia
                            ---> Mostrar Relacao dos postos CAPS
                            call oavpc071_retornapostoscaps(w_cts03m00.ctgtrfcod
                                                           ,ws.c24pbmgrpcod
                                                           ,a_cts03m00[1].lclltt
                                                           ,a_cts03m00[1].lcllgt
                                                           ,l_lim_km
                                                           ,d_cts03m00.c24astcod)
                                 returning l_cappstcod
                                          ,l_stt
                                          ,a_cts03m00[1].lgdtip
                                          ,a_cts03m00[1].lgdnom
                                          ,a_cts03m00[1].lgdnum
                                          ,a_cts03m00[1].brrnom
                                          ,a_cts03m00[1].cidnom
                                          ,a_cts03m00[1].ufdcod
                                          ,l_cidcod
                                          ,a_cts03m00[1].lgdcep
                                          ,a_cts03m00[1].lgdcepcmp
                                          ,l_endlgdcmp
                                          ,a_cts03m00[1].lclltt
                                          ,a_cts03m00[1].lcllgt
                                          ,a_cts03m00[1].lclcttnom
                                          ,a_cts03m00[1].dddcod
                                          ,a_cts03m00[1].lcltelnum
                                          ,l_gchvclinchor
                                          ,l_gchvcfnlhor
                                          ,a_cts03m00[1].lclidttxt
                            let m_cappstcod = l_cappstcod
                            let ws.retflg   = "S"
                            let a_cts03m00[1].c24lclpdrcod = 3
                         end if
                   end if
                end if
             else
                let g_documento.lclocodesres = "N"

                let a_cts03m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
                let m_acesso_ind = false
                call cta00m06_acesso_indexacao_aut(d_cts03m00.atdsrvorg)
                     returning m_acesso_ind
                if m_acesso_ind = false then
                   call cts06g03(1
                                ,d_cts03m00.atdsrvorg
                                ,w_cts03m00.ligcvntip
                                ,aux_today
                                ,aux_hora
                                ,a_cts03m00[1].lclidttxt
                                ,a_cts03m00[1].cidnom
                                ,a_cts03m00[1].ufdcod
                                ,a_cts03m00[1].brrnom
                                ,a_cts03m00[1].lclbrrnom
                                ,a_cts03m00[1].endzon
                                ,a_cts03m00[1].lgdtip
                                ,a_cts03m00[1].lgdnom
                                ,a_cts03m00[1].lgdnum
                                ,a_cts03m00[1].lgdcep
                                ,a_cts03m00[1].lgdcepcmp
                                ,a_cts03m00[1].lclltt
                                ,a_cts03m00[1].lcllgt
                                ,a_cts03m00[1].lclrefptotxt
                                ,a_cts03m00[1].lclcttnom
                                ,a_cts03m00[1].dddcod
                                ,a_cts03m00[1].lcltelnum
                                ,a_cts03m00[1].c24lclpdrcod
                                ,a_cts03m00[1].ofnnumdig
                                ,a_cts03m00[1].celteldddcod
                                ,a_cts03m00[1].celtelnum
                                ,a_cts03m00[1].endcmp
                                ,hist_cts03m00.*
                                ,a_cts03m00[1].emeviacod )
                       returning a_cts03m00[1].lclidttxt
                                ,a_cts03m00[1].cidnom
                                ,a_cts03m00[1].ufdcod
                                ,a_cts03m00[1].brrnom
                                ,a_cts03m00[1].lclbrrnom
                                ,a_cts03m00[1].endzon
                                ,a_cts03m00[1].lgdtip
                                ,a_cts03m00[1].lgdnom
                                ,a_cts03m00[1].lgdnum
                                ,a_cts03m00[1].lgdcep
                                ,a_cts03m00[1].lgdcepcmp
                                ,a_cts03m00[1].lclltt
                                ,a_cts03m00[1].lcllgt
                                ,a_cts03m00[1].lclrefptotxt
                                ,a_cts03m00[1].lclcttnom
                                ,a_cts03m00[1].dddcod
                                ,a_cts03m00[1].lcltelnum
                                ,a_cts03m00[1].c24lclpdrcod
                                ,a_cts03m00[1].ofnnumdig
                                ,a_cts03m00[1].celteldddcod
                                ,a_cts03m00[1].celtelnum
                                ,a_cts03m00[1].endcmp
                                ,ws.retflg
                                ,hist_cts03m00.*
                                ,a_cts03m00[1].emeviacod
                else
                   call cts06g11(1
                                ,d_cts03m00.atdsrvorg
                                ,w_cts03m00.ligcvntip
                                ,aux_today
                                ,aux_hora
                                ,a_cts03m00[1].lclidttxt
                                ,a_cts03m00[1].cidnom
                                ,a_cts03m00[1].ufdcod
                                ,a_cts03m00[1].brrnom
                                ,a_cts03m00[1].lclbrrnom
                                ,a_cts03m00[1].endzon
                                ,a_cts03m00[1].lgdtip
                                ,a_cts03m00[1].lgdnom
                                ,a_cts03m00[1].lgdnum
                                ,a_cts03m00[1].lgdcep
                                ,a_cts03m00[1].lgdcepcmp
                                ,a_cts03m00[1].lclltt
                                ,a_cts03m00[1].lcllgt
                                ,a_cts03m00[1].lclrefptotxt
                                ,a_cts03m00[1].lclcttnom
                                ,a_cts03m00[1].dddcod
                                ,a_cts03m00[1].lcltelnum
                                ,a_cts03m00[1].c24lclpdrcod
                                ,a_cts03m00[1].ofnnumdig
                                ,a_cts03m00[1].celteldddcod
                                ,a_cts03m00[1].celtelnum
                                ,a_cts03m00[1].endcmp
                                ,hist_cts03m00.*
                                ,a_cts03m00[1].emeviacod )
                       returning a_cts03m00[1].lclidttxt
                                ,a_cts03m00[1].cidnom
                                ,a_cts03m00[1].ufdcod
                                ,a_cts03m00[1].brrnom
                                ,a_cts03m00[1].lclbrrnom
                                ,a_cts03m00[1].endzon
                                ,a_cts03m00[1].lgdtip
                                ,a_cts03m00[1].lgdnom
                                ,a_cts03m00[1].lgdnum
                                ,a_cts03m00[1].lgdcep
                                ,a_cts03m00[1].lgdcepcmp
                                ,a_cts03m00[1].lclltt
                                ,a_cts03m00[1].lcllgt
                                ,a_cts03m00[1].lclrefptotxt
                                ,a_cts03m00[1].lclcttnom
                                ,a_cts03m00[1].dddcod
                                ,a_cts03m00[1].lcltelnum
                                ,a_cts03m00[1].c24lclpdrcod
                                ,a_cts03m00[1].ofnnumdig
                                ,a_cts03m00[1].celteldddcod
                                ,a_cts03m00[1].celtelnum
                                ,a_cts03m00[1].endcmp
                                ,ws.retflg
                                ,hist_cts03m00.*
                                ,a_cts03m00[1].emeviacod
                end if
             end if
             #------------------------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #------------------------------------------------------------------------------
             if g_documento.lclocodesres = "S" then
                let d_cts03m00.atdrsdflg = "S"
             else
                let d_cts03m00.atdrsdflg = "N"
             end if
             
             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts03m00[1].lclbrrnom
             
             call cts06g10_monta_brr_subbrr(a_cts03m00[1].brrnom,
                                            a_cts03m00[1].lclbrrnom)
                  returning a_cts03m00[1].lclbrrnom

             let a_cts03m00[1].lgdtxt = a_cts03m00[1].lgdtip clipped, " ",
                                        a_cts03m00[1].lgdnom clipped, " ",
                                        a_cts03m00[1].lgdnum using "<<<<#"

             if a_cts03m00[1].cidnom is not null and
                a_cts03m00[1].ufdcod is not null then
                call cts14g00 (d_cts03m00.c24astcod,
                               "","","","",
                               a_cts03m00[1].cidnom,
                               a_cts03m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts03m00[1].lgdtxt
             display by name a_cts03m00[1].lclbrrnom
             display by name a_cts03m00[1].endzon
             display by name a_cts03m00[1].cidnom
             display by name a_cts03m00[1].ufdcod
             display by name a_cts03m00[1].lclrefptotxt
             display by name a_cts03m00[1].lclcttnom
             display by name a_cts03m00[1].dddcod
             display by name a_cts03m00[1].lcltelnum
             display by name a_cts03m00[1].celteldddcod
             display by name a_cts03m00[1].celtelnum
             display by name a_cts03m00[1].endcmp

             if a_cts03m00[1].ufdcod = "EX" then
                let ws.retflg = "S"
             end if

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!"
                if d_cts03m00.c24pbmcod <> 999 then
                   next field c24pbmcod
                else
                   next field atddfttxt
                end if
             else
                next field sindat
             end if
          end if

   after  field lgdtxt
          display by name a_cts03m00[1].lgdtxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts03m00.c24pbmcod <> 999 then
                next field c24pbmcod
             else
                next field atddfttxt
             end if
          end if
          if a_cts03m00[1].lgdtxt is null then
             error " Endereco deve ser informado!"
             next field lgdtxt
          end if

   before field lclbrrnom
          display by name a_cts03m00[1].lclbrrnom attribute (reverse)

   after  field lclbrrnom
          display by name a_cts03m00[1].lclbrrnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lgdtxt
          end if
          if a_cts03m00[1].lclbrrnom is null then
             error " Bairro deve ser informado!"
             next field lclbrrnom
          end if

   before field cidnom
          display by name a_cts03m00[1].cidnom attribute (reverse)
          
   after  field cidnom
          display by name a_cts03m00[1].cidnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclbrrnom
          end if
          if a_cts03m00[1].cidnom is null then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

   before field ufdcod
          display by name a_cts03m00[1].ufdcod attribute (reverse)

   after  field ufdcod
          display by name a_cts03m00[1].ufdcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cidnom
          end if
          if a_cts03m00[1].ufdcod is null then
             error " U.F. deve ser informada!"
             next field ufdcod
          end if

          # Verifica Cidade/UF
          select cidcod
            from glakcid
           where cidnom = a_cts03m00[1].cidnom
             and ufdcod = a_cts03m00[1].ufdcod

           if sqlca.sqlcode = notfound then
              error " Cidade/UF nao estao corretos!"
              next field ufdcod
           end if

   before field lclrefptotxt
          display by name a_cts03m00[1].lclrefptotxt attribute (reverse)

   after  field lclrefptotxt
          display by name a_cts03m00[1].lclrefptotxt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ufdcod
          end if

   before field endzon
          display by name a_cts03m00[1].endzon attribute (reverse)

   after  field endzon
          display by name a_cts03m00[1].endzon

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclrefptotxt
          end if
          if a_cts03m00[1].ufdcod  = "SP" then
             if a_cts03m00[1].endzon <> "NO" and
                a_cts03m00[1].endzon <> "SU" and
                a_cts03m00[1].endzon <> "LE" and
                a_cts03m00[1].endzon <> "OE" and
                a_cts03m00[1].endzon <> "CE" then
                error " Para a Capital favor informar zona NO/SU/LE/OE/CE!"
                next field endzon
             end if
          end if

   before field dddcod
          display by name a_cts03m00[1].dddcod attribute (reverse)

   after  field dddcod
          display by name a_cts03m00[1].dddcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field endzon
          end if

   before field lcltelnum
          display by name a_cts03m00[1].lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name a_cts03m00[1].lcltelnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field dddcod
          end if

   before field lclcttnom
          if d_cts03m00.frmflg = "N" then
             if d_cts03m00.c24pbmcod <> 999 then
                next field c24pbmcod
             else
                next field atddfttxt
             end if
          end if
          display by name a_cts03m00[1].lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name a_cts03m00[1].lclcttnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lcltelnum
          end if
          if d_cts03m00.frmflg = "S" then
             let a_cts03m00[1].lgdnom       = a_cts03m00[1].lgdtxt
             let a_cts03m00[1].c24lclpdrcod = 1   # Fora do padrao
          end if

   before field sindat
          if d_cts03m00.c24astcod <> "E12" then
              next field atdrsdflg
          end if
          display by name d_cts03m00.sindat attribute (reverse)

   after  field sindat
          display by name d_cts03m00.sindat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lclcttnom
          else
             if d_cts03m00.sindat is null  then
                error " Data do sinistro deve ser informada!"
                next field sindat
             end if

             ##if d_cts03m00.sindat < today - 366 units day  then
             if d_cts03m00.sindat < l_data - 366 units day  then
                let ws.confirma = cts08g01("A","N","","DATA DO SINISTRO INFORMADA E'","ANTERIOR A  1 (UM) ANO !","")
                next field sindat
             end if

             ##if d_cts03m00.sindat > today   then
             if d_cts03m00.sindat > l_data   then
                error " Data do sinistro nao deve ser maior que hoje!"
                next field sindat
             end if
          end if

   before field sinhor
          if d_cts03m00.c24astcod <> "E12" then
              next field atdrsdflg
          end if
          display by name d_cts03m00.sinhor attribute (reverse)

   after  field sinhor
          display by name d_cts03m00.sinhor

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts03m00.sinhor is null  then
                error " Hora do sinistro deve ser informada!"
                next field sinhor
             end if

             ##if d_cts03m00.sindat =  today     and
             if d_cts03m00.sindat =  l_data     and
                d_cts03m00.sinhor <> "00:00"   and
                d_cts03m00.sinhor >  aux_hora  then
                error " Hora do sinistro nao deve ser maior que hora atual!"
                next field sinhor
             end if
          end if

   before field atdrsdflg
          if d_cts03m00.frmflg = "S" then
             let d_cts03m00.atdrsdflg = "N"
          end if
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts03m00.c24astcod <> "E12" then
                next field lclcttnom
             else
                next field sinhor
             end if
          end if
          display by name d_cts03m00.atdrsdflg
          next field asitipcod

   before field asitipcod
          display by name d_cts03m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts03m00.asitipcod

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts03m00.asitipcod is null  then
                let d_cts03m00.asitipcod = ctn25c00(d_cts03m00.atdsrvorg)

                if d_cts03m00.asitipcod is not null  then
                   select asitipabvdes, asiofndigflg, vclcndlclflg
                     into d_cts03m00.asitipabvdes
                         ,w_cts03m00.asiofndigflg
                         ,w_cts03m00.vclcndlclflg
                     from datkasitip
                    where asitipcod = d_cts03m00.asitipcod  and
                          asitipstt = "A"

                   if d_cts03m00.asitipcod = 1 and       #OSF 19968
                      w_cts03m00.asiofndigflg = "S" then
                      let d_cts03m00.dstflg = "S"
                      display by name d_cts03m00.dstflg
                   end if

                   display by name d_cts03m00.asitipcod
                   display by name d_cts03m00.asitipabvdes

                   if cty31g00_valida_clausula() and
                   	  g_nova.perfil <> 2         then

                       #-----------------------------------------------------------
                       # Recupera o Limite de Kilometragem
                       #-----------------------------------------------------------

                       call cty31g00_valida_km(d_cts03m00.c24astcod ,
                                               g_nova.clscod        ,
                                               g_nova.perfil        ,
                                               d_cts03m00.asitipcod ,
                                               "")
                       returning l_limite_km,
                                 l_flag_atende

                   end if



                   if g_documento.aplnumdig is not null then
                       call cts03m00_limite_cls46(g_documento.ramcod,
                                                  g_documento.succod,
                                                  g_documento.aplnumdig,
                                                  g_documento.itmnumdig,
                                                  g_documento.edsnumref,
                                                  d_cts03m00.asitipcod,
                                                  d_cts03m00.c24astcod )
                            returning l_limite
                       if l_limite then
                          call cts08g01('A' ,'S'
                                       ,'LIMITE ESGOTADO. '
                                       ,'CONSULTE A COORDENACAO, '
                                       ,'PARA ENVIO DE ATENDIMENTO . '
                                       ,'' )
                                        returning ws.confirma
                          next field asitipcod
                       end if
                   end if
                   if w_cts03m00.vclcndlclflg = "S" then
                      if g_documento.acao = "CON" then
                         let tip_mvt = "A"
                      else
                         let tip_mvt = "M"
                      end if
                      call ctc61m02(g_documento.atdsrvnum,
                                    g_documento.atdsrvano,
                                    tip_mvt)
                       let m_multiplo = false
                       call cta00m06_assistencia_multiplo(d_cts03m00.asitipcod)
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
                                      if d_cts03m00.c24astcod = 'K02' then
                                         let d_cts03m00.atdsrvorg = 1
                                      end if
                                      call ctc48m02(d_cts03m00.atdsrvorg) returning am_param.c24pbmgrpcod,
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
                                      open c_cts03m00_004 using am_param.c24pbmcod
                                      fetch c_cts03m00_004 into am_param.asitipcod
                                   whenever error stop
                                   if sqlca.sqlcode <> 0 then
                                       let l_mensagem = 'Erro < ',sqlca.sqlcode,' > ao buscar tipo de assistência < ',am_param.c24pbmcod,' >'
                                       call errorlog(l_mensagem)
                                   end if
                            end if
                       end if
                   else
                      call ctc61m02_criatmp(2, g_documento.atdsrvnum,
                                            g_documento.atdsrvano)
                           returning tmp_flg

                      if tmp_flg = 1 then
                         display "Problemas com temporaria! <Avise a Informatica>"
                      end if
                   end if

                   #Retirado a pedido da Ana paula debastiani
                   #if (d_cts03m00.asitipcod =  1       or
                   #    d_cts03m00.asitipcod =  3    )  and
                   #   (d_cts03m00.atdrsdflg = "S"   )  and
                   #   (g_documento.atdsrvnum is null)  then
                   #   while true
                   #      let w_cts03m00.atdvcltip = cts03m02( w_cts03m00.atdvcltip )
                   #
                   #      if w_cts03m00.atdvcltip is null  then
                   #         error " Tipo do guincho nao informado!"
                   #      else
                   #         if w_cts03m00.atdvcltip = 1  then
                   #            initialize w_cts03m00.atdvcltip to null
                   #         end if
                   #         exit while
                   #      end if
                   #   end while
                   #else
                   #   initialize w_cts03m00.atdvcltip to null
                   #end if

                #if g_documento.aplnumdig is not null then
                #
                #   display "Entrei"
                #   call cts03m00_limite_cls46(g_documento.ramcod,
                #                              g_documento.succod,
                #                              g_documento.aplnumdig,
                #                              g_documento.itmnumdig,
                #                              g_documento.edsnumref,
                #                              d_cts03m00.asitipcod,
                #                              d_cts03m00.c24astcod )
                #        returning l_limite
                #
                #   if l_limite then
                #      call cts08g01('A' ,'S'
                #                   ,'LIMITE ESGOTADO. '
                #                   ,'CONSULTE A COORDENACAO, '
                #                   ,'PARA ENVIO DE ATENDIMENTO. '
                #                   ,'' )
                #                    returning ws.confirma
                #      next field asitipcod
                #   end if
                #end if
                   if d_cts03m00.asitipcod =  2   or    ###  Tecnico
                      d_cts03m00.asitipcod =  4   or    ###  Chaveiro
                      d_cts03m00.asitipcod =  8   then  ###  Chaveiro/Disp.
                      let d_cts03m00.dstflg    = "N"
                      let d_cts03m00.rmcacpflg = "N"
                      initialize a_cts03m00[2].*  to null
                      let a_cts03m00[2].operacao = "D"
                      display by name d_cts03m00.dstflg, d_cts03m00.rmcacpflg
		                  #call cty26g00_srv_auto(g_documento.ramcod
				              #                      ,g_documento.succod
		         	        #                      ,g_documento.aplnumdig
				              #                      ,g_documento.itmnumdig
				              #                      ,g_documento.c24astcod
		       	          #                      ,d_cts03m00.asitipcod)
		                  #returning l_flag_limite
                      #
		                  #if l_flag_limite = "S" then
		                  #   let l_confirma =
		                  #       cts08g01('A'  ,'S','' ,'CONSULTE A COORDENACAO',
				              #    'PARA ENVIO DE ATENDIMENTO. '  ,'')
		                  #   next field asitipcod
		                  #end if
                      next field atdprinvlcod
                   end if
                   next field dstflg
                else
                   next field asitipcod
                end if
             else
                select asitipabvdes, asiofndigflg, vclcndlclflg
                  into d_cts03m00.asitipabvdes
                      ,w_cts03m00.asiofndigflg
                      ,w_cts03m00.vclcndlclflg
                  from datkasitip
                 where asitipcod = d_cts03m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   let d_cts03m00.asitipcod = ctn25c00(d_cts03m00.atdsrvorg)
                   next field asitipcod
                else
                   display by name d_cts03m00.asitipcod
                   display by name d_cts03m00.asitipabvdes
                end if

                if d_cts03m00.asitipcod = 1 and       #OSF 19968
                   w_cts03m00.asiofndigflg = "S" then
                   let d_cts03m00.dstflg = "S"
                   display by name d_cts03m00.dstflg
                end if

                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = d_cts03m00.atdsrvorg
                   and asitipcod = d_cts03m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada para este servico!"
                   next field asitipcod
                end if


                if cty31g00_valida_clausula() and
                	 g_nova.perfil <> 2         then

                    #-----------------------------------------------------------
                    # Recupera o Limite de Kilometragem
                    #-----------------------------------------------------------

                    call cty31g00_valida_km(d_cts03m00.c24astcod ,
                                            g_nova.clscod        ,
                                            g_nova.perfil        ,
                                            d_cts03m00.asitipcod ,
                                            "")
                    returning l_limite_km,
                              l_flag_atende

                end if


                if g_documento.aplnumdig is not null then
                    call cts03m00_limite_cls46(g_documento.ramcod,
                                               g_documento.succod,
                                               g_documento.aplnumdig,
                                               g_documento.itmnumdig,
                                               g_documento.edsnumref,
                                               d_cts03m00.asitipcod,
                                               d_cts03m00.c24astcod )
                         returning l_limite
                    if l_limite then
                       call cts08g01('A' ,'S'
                                    ,'LIMITE ESGOTADO. '
                                    ,'CONSULTE A COORDENACAO, '
                                    ,'PARA ENVIO DE ATENDIMENTO . '
                                    ,'' )
                                     returning ws.confirma
                       next field asitipcod
                    end if
                 end if

                if w_cts03m00.vclcndlclflg = "S" then
                   if g_documento.acao = "CON" then
                      let tip_mvt = "A"
                   else
                      let tip_mvt = "M"
                   end if
                   call ctc61m02(g_documento.atdsrvnum,
                                 g_documento.atdsrvano,
                                 tip_mvt)
                   let m_multiplo = false
                       call cta00m06_assistencia_multiplo(d_cts03m00.asitipcod)
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
                                         if d_cts03m00.c24astcod = 'K02' then
                                            let d_cts03m00.atdsrvorg = 1
                                         end if
                                         
                                         call ctc48m02(d_cts03m00.atdsrvorg) returning am_param.c24pbmgrpcod,
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
                                      open c_cts03m00_004 using am_param.c24pbmcod
                                      fetch c_cts03m00_004 into am_param.asitipcod
                                   whenever error stop
                                   if sqlca.sqlcode <> 0 then
                                       call errorlog("cts03m00")
                                       let l_mensagem = 'Erro < ',sqlca.sqlcode,' > ao buscar tipo de assistência < ',am_param.c24pbmcod,' >'
                                       call errorlog(l_mensagem)
                                   end if
                            end if
                       end if
                else
                   call ctc61m02_criatmp(2, g_documento.atdsrvnum,
                                         g_documento.atdsrvano)
                        returning tmp_flg

                   if tmp_flg = 1 then
                      display "Problemas com temporaria! <Avise a Informatica>."
                   end if
                end if

                # Retirado a pedido da Ana Paula Debastiani
                #if (d_cts03m00.asitipcod =  1       or
                #    d_cts03m00.asitipcod =  3    )  and
                #   (d_cts03m00.atdrsdflg = "S"   )  and
                #   (g_documento.atdsrvnum is null)  then
                #   while true
                #      let w_cts03m00.atdvcltip = cts03m02(w_cts03m00.atdvcltip)
                #
                #      if w_cts03m00.atdvcltip is null  then
                #         error " Tipo do guincho nao informado!"
                #      else
                #         if w_cts03m00.atdvcltip = 1  then
                #            initialize w_cts03m00.atdvcltip to null
                #         end if
                #         exit while
                #      end if
                #   end while
                #else
                #   initialize w_cts03m00.atdvcltip to null
                #end if

                #if g_documento.aplnumdig is not null then
                #   display "3354"
                #   call cts03m00_limite_cls46(g_documento.ramcod,
                #                              g_documento.succod,
                #                              g_documento.aplnumdig,
                #                              g_documento.itmnumdig,
                #                              g_documento.edsnumref,
                #                              d_cts03m00.asitipcod,
                #                              d_cts03m00.c24astcod )
                #        returning l_limite
                #
                #   if l_limite then
                #      call cts08g01('A' ,'S'
                #                   ,'LIMITE ESGOTADO. '
                #                   ,'CONSULTE A COORDENACAO, '
                #                   ,'PARA ENVIO DE ATENDIMENTO. '
                #                   ,'' )
                #                    returning ws.confirma
                #      next field asitipcod
                #   end if
                #end if
                if d_cts03m00.asitipcod =  2   or    ###  Tecnico
                   d_cts03m00.asitipcod =  4   or    ###  Chaveiro
                   d_cts03m00.asitipcod =  8   or    ###  Chaveiro/Disp.
                   d_cts03m00.asitipcod =  61  then  ###  Tecnico II
                   let d_cts03m00.dstflg    = "N"
                   let d_cts03m00.rmcacpflg = "N"
                   initialize a_cts03m00[2].*  to null
                   let a_cts03m00[2].operacao = "D"
                   display by name d_cts03m00.dstflg, d_cts03m00.rmcacpflg
		   #call cty26g00_srv_auto(g_documento.ramcod  ## JUNIOR (FORNAX)
				#      ,g_documento.succod
		   #      	      ,g_documento.aplnumdig
				#      ,g_documento.itmnumdig
				#      ,g_documento.c24astcod
		   #    	              ,d_cts03m00.asitipcod)
		   #     returning l_flag_limite
       #
		   #if l_flag_limite = "S" then
		   #   let l_confirma =
		   #       cts08g01('A'  ,'S','' ,'CONSULTE A COORDENACAO',
				#   'PARA ENVIO DE ATENDIMENTO. '  ,'')
		   #   next field asitipcod
		   #end if
                   next field atdprinvlcod
                end if
             end if
             display by name d_cts03m00.asitipabvdes
          end if
                if g_documento.aplnumdig is not null then
                   call cts03m00_limite_cls46(g_documento.ramcod,
                                              g_documento.succod,
                                              g_documento.aplnumdig,
                                              g_documento.itmnumdig,
                                              g_documento.edsnumref,
                                              d_cts03m00.asitipcod,
                                              d_cts03m00.c24astcod )
                        returning l_limite
                   if l_limite then
                      call cts08g01('A' ,'S'
                                   ,'LIMITE ESGOTADO. '
                                   ,'CONSULTE A COORDENACAO, '
                                   ,'PARA ENVIO DE ATENDIMENTO 1. '
                                   ,'' )
                                    returning ws.confirma
                      next field asitipcod
                   end if
                end if
		#call cty26g00_srv_auto(g_documento.ramcod  ## JUNIOR (FORNAX)
		#		      ,g_documento.succod
		#         	      ,g_documento.aplnumdig
		#		      ,g_documento.itmnumdig
		#		      ,g_documento.c24astcod
		#       	              ,d_cts03m00.asitipcod)
		#     returning l_flag_limite
    #
		#if l_flag_limite = "S" then
		#   let l_confirma =
		#       cts08g01('A'  ,'S','' ,'CONSULTE A COORDENACAO',
		#		'PARA ENVIO DE ATENDIMENTO. '  ,'')
		#   next field asitipcod
		#end if

   before field dstflg
          if d_cts03m00.frmflg = "S" then
             let d_cts03m00.dstflg = "N"
          end if
          if d_cts03m00.asitipcod = 3 then
             let d_cts03m00.dstflg = 'S'
          end if
          display by name d_cts03m00.dstflg attribute (reverse)

   after  field dstflg
          display by name d_cts03m00.dstflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.dstflg is null    then
                error " Destino deve ser informado!"
                next field dstflg
             end if

             if d_cts03m00.dstflg <> "S"   and
                d_cts03m00.dstflg <> "N"   then
                error " Existe destino: (S)im ou (N)ao"
                next field dstflg
             end if
             if d_cts03m00.asitipcod = 3 and
                d_cts03m00.dstflg = "N" then
                error "Destino deve ser informado!"
                next field dstflg
             end if

             initialize w_hist.* to null

             if d_cts03m00.dstflg = "S"  then

                ---> So sugere o CAPS se estiver incluindo Laudo
                if g_documento.acao = "INC" then

                   ---> Verifica se Assuntos estao ligados ao CAPS
                   select cponom
                     from iddkdominio
                    where cponom = "c24astcod_caps"
                   and cpodes =  d_cts03m00.c24astcod

                   if sqlca.sqlcode <> notfound  then

                      ---> Verifica Tipo de Assistencia
                      if d_cts03m00.asitipcod = 1 or   ---> Guincho
                         d_cts03m00.asitipcod = 3 then ---> Guincho/Tecnico
                            
                         if d_cts03m00.c24astcod <> "SLT"      and 
                         	  not cty31g00_valida_atd_premium()  then
                            
                             ---> Verifica se ha Postos Caps que atendem o Servico
                             call oavpc071_consultadisponibilidadepostoscaps(
                                           w_cts03m00.ctgtrfcod
                                          ,ws.c24pbmgrpcod)
                                  returning l_stt
		                         ---> Encontrou Posto que Atende o Servico desejado
                             if l_stt <> 0 then

                                initialize l_stt to null

                                ---> Define Limite de Km p/solicitar confirmacao
                                ---> ao selecionar o CAPS, conforme local do Veiculo

                                if d_cts03m00.atdrsdflg = "S" then
                                   let l_lim_km = 7  ---> Em Residencia
                                else
                                   let l_lim_km = 50 ---> Fora da Residencia
                                end if

                                ---> Mostrar Relacao dos postos CAPS
                                call oavpc071_retornapostoscaps(
                                                               w_cts03m00.ctgtrfcod
                                                              ,ws.c24pbmgrpcod
                                                              ,a_cts03m00[1].lclltt
                                                              ,a_cts03m00[1].lcllgt
                                                              ,l_lim_km
                                                              ,d_cts03m00.c24astcod)
                                     returning l_cappstcod
                                              ,l_stt
                                              ,a_cts03m00[2].lgdtip
                                              ,a_cts03m00[2].lgdnom
                                              ,a_cts03m00[2].lgdnum
                                              ,a_cts03m00[2].brrnom
                                              ,a_cts03m00[2].cidnom
                                              ,a_cts03m00[2].ufdcod
                                              ,l_cidcod
                                              ,a_cts03m00[2].lgdcep
                                              ,a_cts03m00[2].lgdcepcmp
                                              ,l_endlgdcmp
                                              ,a_cts03m00[2].lclltt
                                              ,a_cts03m00[2].lcllgt
                                              ,a_cts03m00[2].lclcttnom
                                              ,a_cts03m00[2].dddcod
                                              ,a_cts03m00[2].lcltelnum
                                              ,l_gchvclinchor
                                              ,l_gchvcfnlhor
                                              ,a_cts03m00[2].lclidttxt

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
                                         let l_msg = d_cts03m00.c24astcod
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
                                
                                let l_lgdnom    = a_cts03m00[2].lgdnom
                                let m_cappstcod = l_cappstcod  
                                   
                                if cty31g00_valida_clausula() then
                                    #-----------------------------------------------------------
                                    # Calcula o Limite de Kilometragem
                                    #-----------------------------------------------------------
                                     call cts00m33_calckm("",
                                                          a_cts03m00[1].lclltt,
                                                          a_cts03m00[1].lcllgt,
                                                          a_cts03m00[2].lclltt,
                                                          a_cts03m00[2].lcllgt,
                                                          l_limite_km         )
                                end if
                             end if
                         end if
                      end if
                   end if
                end if

                   if (g_documento.c24astcod = 'M15' or
						           g_documento.c24astcod = 'M20' or
						           g_documento.c24astcod = 'M23' or
						           g_documento.c24astcod = 'M33') then
													call cts08g01("C","S",""," DESTINO SERÁ O BRASIL ? ","", "")
													   returning l_resposta

											 if l_resposta = "S" then
												  let a_cts03m00[2].ufdcod = ""
												  let a_cts03m00[2].lclidttxt = "BRASIL"
		             		   end if
             		   end if
                let a_cts03m00[3].* = a_cts03m00[2].*

                let a_cts03m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                let m_acesso_ind = false
                call cta00m06_acesso_indexacao_aut(d_cts03m00.atdsrvorg)
                     returning m_acesso_ind

                if d_cts03m00.c24astcod = "SLV" and
                   m_cappstcod is not null      then
                   let ws.retflg = "S"
                   let a_cts03m00[2].c24lclpdrcod = 3
                else
                    if m_acesso_ind = false then
                       #let d_cts03m00.atdsrvorg = null
								    	 #let a_cts03m00[1].ufdcod = ""
								    	 #let a_cts03m00[1].lclidttxt = ""
                       call cts06g03(2
                                    ,d_cts03m00.atdsrvorg
                                    ,w_cts03m00.ligcvntip
                                    ,aux_today
                                    ,aux_hora
                                    ,a_cts03m00[2].lclidttxt
                                    ,a_cts03m00[2].cidnom
                                    ,a_cts03m00[2].ufdcod
                                    ,a_cts03m00[2].brrnom
                                    ,a_cts03m00[2].lclbrrnom
                                    ,a_cts03m00[2].endzon
                                    ,a_cts03m00[2].lgdtip
                                    ,a_cts03m00[2].lgdnom
                                    ,a_cts03m00[2].lgdnum
                                    ,a_cts03m00[2].lgdcep
                                    ,a_cts03m00[2].lgdcepcmp
                                    ,a_cts03m00[2].lclltt
                                    ,a_cts03m00[2].lcllgt
                                    ,a_cts03m00[2].lclrefptotxt
                                    ,a_cts03m00[2].lclcttnom
                                    ,a_cts03m00[2].dddcod
                                    ,a_cts03m00[2].lcltelnum
                                    ,a_cts03m00[2].c24lclpdrcod
                                    ,a_cts03m00[2].ofnnumdig
                                    ,a_cts03m00[2].celteldddcod
                                    ,a_cts03m00[2].celtelnum
                                    ,a_cts03m00[2].endcmp
                                    ,hist_cts03m00.*
                                    ,a_cts03m00[2].emeviacod )
                           returning a_cts03m00[2].lclidttxt
                                    ,a_cts03m00[2].cidnom
                                    ,a_cts03m00[2].ufdcod
                                    ,a_cts03m00[2].brrnom
                                    ,a_cts03m00[2].lclbrrnom
                                    ,a_cts03m00[2].endzon
                                    ,a_cts03m00[2].lgdtip
                                    ,a_cts03m00[2].lgdnom
                                    ,a_cts03m00[2].lgdnum
                                    ,a_cts03m00[2].lgdcep
                                    ,a_cts03m00[2].lgdcepcmp
                                    ,a_cts03m00[2].lclltt
                                    ,a_cts03m00[2].lcllgt
                                    ,a_cts03m00[2].lclrefptotxt
                                    ,a_cts03m00[2].lclcttnom
                                    ,a_cts03m00[2].dddcod
                                    ,a_cts03m00[2].lcltelnum
                                    ,a_cts03m00[2].c24lclpdrcod
                                    ,a_cts03m00[2].ofnnumdig
                                    ,a_cts03m00[2].celteldddcod
                                    ,a_cts03m00[2].celtelnum
                                    ,a_cts03m00[2].endcmp
                                    ,ws.retflg
                                    ,hist_cts03m00.*
                                    ,a_cts03m00[2].emeviacod
                    else

                       call cts06g11(2
                                    ,d_cts03m00.atdsrvorg
                                    ,w_cts03m00.ligcvntip
                                    ,aux_today
                                    ,aux_hora
                                    ,a_cts03m00[2].lclidttxt
                                    ,a_cts03m00[2].cidnom
                                    ,a_cts03m00[2].ufdcod
                                    ,a_cts03m00[2].brrnom
                                    ,a_cts03m00[2].lclbrrnom
                                    ,a_cts03m00[2].endzon
                                    ,a_cts03m00[2].lgdtip
                                    ,a_cts03m00[2].lgdnom
                                    ,a_cts03m00[2].lgdnum
                                    ,a_cts03m00[2].lgdcep
                                    ,a_cts03m00[2].lgdcepcmp
                                    ,a_cts03m00[2].lclltt
                                    ,a_cts03m00[2].lcllgt
                                    ,a_cts03m00[2].lclrefptotxt
                                    ,a_cts03m00[2].lclcttnom
                                    ,a_cts03m00[2].dddcod
                                    ,a_cts03m00[2].lcltelnum
                                    ,a_cts03m00[2].c24lclpdrcod
                                    ,a_cts03m00[2].ofnnumdig
                                    ,a_cts03m00[2].celteldddcod
                                    ,a_cts03m00[2].celtelnum
                                    ,a_cts03m00[2].endcmp
                                    ,hist_cts03m00.*
                                    ,a_cts03m00[2].emeviacod )
                           returning a_cts03m00[2].lclidttxt
                                    ,a_cts03m00[2].cidnom
                                    ,a_cts03m00[2].ufdcod
                                    ,a_cts03m00[2].brrnom
                                    ,a_cts03m00[2].lclbrrnom
                                    ,a_cts03m00[2].endzon
                                    ,a_cts03m00[2].lgdtip
                                    ,a_cts03m00[2].lgdnom
                                    ,a_cts03m00[2].lgdnum
                                    ,a_cts03m00[2].lgdcep
                                    ,a_cts03m00[2].lgdcepcmp
                                    ,a_cts03m00[2].lclltt
                                    ,a_cts03m00[2].lcllgt
                                    ,a_cts03m00[2].lclrefptotxt
                                    ,a_cts03m00[2].lclcttnom
                                    ,a_cts03m00[2].dddcod
                                    ,a_cts03m00[2].lcltelnum
                                    ,a_cts03m00[2].c24lclpdrcod
                                    ,a_cts03m00[2].ofnnumdig
                                    ,a_cts03m00[2].celteldddcod
                                    ,a_cts03m00[2].celtelnum
                                    ,a_cts03m00[2].endcmp
                                    ,ws.retflg
                                    ,hist_cts03m00.*
                                    ,a_cts03m00[2].emeviacod
                    end if
                end if
                
                if m_cappstcod is not null then              	 	               	 	                 	           	 
                	   if l_lgdnom <> a_cts03m00[2].lgdnom then 
                	         let m_cappstcod = null
                	   end if               
                end if 	
                
                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_subbairro[2].lclbrrnom = a_cts03m00[2].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts03m00[2].brrnom,
                                               a_cts03m00[2].lclbrrnom)
                     returning a_cts03m00[2].lclbrrnom
                let a_cts03m00[2].lgdtxt = a_cts03m00[2].lgdtip clipped, " ",
                                           a_cts03m00[2].lgdnom clipped, " ",
                                           a_cts03m00[2].lgdnum using "<<<<#"
                if a_cts03m00[2].lclltt <> a_cts03m00[3].lclltt or
                   a_cts03m00[2].lcllgt <> a_cts03m00[3].lcllgt or
                   (a_cts03m00[3].lclltt is null and a_cts03m00[2].lclltt is not null) or
                   (a_cts03m00[3].lcllgt is null and a_cts03m00[2].lcllgt is not null) then

                   if (g_documento.c24astcod <> 'M15' and
					             g_documento.c24astcod <> 'M20' and
					             g_documento.c24astcod <> 'M23' and
					             g_documento.c24astcod <> 'M33') then
                       call cts00m33(1,
                                     a_cts03m00[1].lclltt,
                                     a_cts03m00[1].lcllgt,
                                     a_cts03m00[2].lclltt,
                                     a_cts03m00[2].lcllgt)
                    end if
                    if cty31g00_valida_clausula() then

                        #-----------------------------------------------------------
                        # Calcula o Limite de Kilometragem
                        #-----------------------------------------------------------

                         call cts00m33_calckm("",
                                              a_cts03m00[1].lclltt,
                                              a_cts03m00[1].lcllgt,
                                              a_cts03m00[2].lclltt,
                                              a_cts03m00[2].lcllgt,
                                              l_limite_km         )

                    end if


                end if
                if a_cts03m00[2].cidnom is not null and
                   a_cts03m00[2].ufdcod is not null then
                   call cts14g00 (d_cts03m00.c24astcod,
                                  "","","","",
                                  a_cts03m00[2].cidnom,
                                  a_cts03m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if
                 if a_cts03m00[1].ufdcod = "EX" then
		                let ws.retflg = "S"
		             end if
                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos",
                         " ou nao preenchidos!"
                   next field dstflg
                end if

                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then
                   let a_cts03m00[2].operacao = "I"
                else
                   select c24lclpdrcod
                     from datmlcl
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano  and
                          c24endtip = 2
                   if sqlca.sqlcode = notfound  then
                      let a_cts03m00[2].operacao = "I"
                   else
                      let a_cts03m00[2].operacao = "M"
                   end if
                end if

                if a_cts03m00[2].ofnnumdig is not null then
                   select ofnstt
                       into ws.ofnstt
                       from sgokofi
                      where ofnnumdig = a_cts03m00[2].ofnnumdig
                   if ws.ofnstt = "C" then
                      # digita o motivo
                      let w_hist.hist1 = "OF CORT MOTIVO:"
                      call cts10m02 (w_hist.*) returning w_hist.*
                   end if
                end if
             else
                if d_cts03m00.asitipcod    = 1   and
                   w_cts03m00.asiofndigflg = "S" then
                   error "Destino e Obrigatorio"
                   next field dstflg
                end if
                initialize a_cts03m00[2].*  to null
                let a_cts03m00[2].operacao = "D"
             end if
          end if

   before field rmcacpflg
          if d_cts03m00.frmflg = "S" then
             let d_cts03m00.rmcacpflg = "N"
          end if
          display by name d_cts03m00.rmcacpflg attribute (reverse)

   after  field rmcacpflg
          display by name d_cts03m00.rmcacpflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.rmcacpflg  is null   then
                error " Acompanha remocao deve ser informado!"
                next field rmcacpflg
             end if

             if d_cts03m00.rmcacpflg <> "S"      and
                d_cts03m00.rmcacpflg <> "N"      then
                error " Acompanha remocao deve ser (S)im ou (N)ao!"
                next field rmcacpflg
             end if
          end if

   before field atdprinvlcod
          if d_cts03m00.frmflg = "S" then
             if fgl_lastkey() <> fgl_keyval("up")   or
                fgl_lastkey() <> fgl_keyval("left") then
                next field imdsrvflg
             end if
          end if
          display by name d_cts03m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts03m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts03m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts03m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts03m00.atdprinvldes

          else
             if d_cts03m00.frmflg = "S" then
                next field rmcacpflg
             end if
          end if

   before field prslocflg
          if g_documento.atdsrvnum is not null  or
             g_documento.atdsrvano is not null  then
             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                initialize d_cts03m00.prslocflg  to null
                next field atdprinvlcod
             else
                initialize d_cts03m00.prslocflg  to null
              # next field srvprlflg
                next field atdlibflg
             end if
          else
             if d_cts03m00.imdsrvflg = "N"    then
                initialize w_cts03m00.c24nomctt  to null
                let d_cts03m00.prslocflg = "N"
                display by name d_cts03m00.prslocflg
              # next field srvprlflg
                next field atdlibflg
             end if
          end if

          display by name d_cts03m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts03m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if ((d_cts03m00.prslocflg  is null)  or
              (d_cts03m00.prslocflg  <> "S"    and
             d_cts03m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts03m00.prslocflg = "S"   then
             call ctn24c01()
                  returning w_cts03m00.atdprscod, w_cts03m00.srrcoddig,
                            w_cts03m00.atdvclsgl, w_cts03m00.socvclcod

             if w_cts03m00.atdprscod  is null then
                error " Faltam dados para prestador no local!"
                next field prslocflg
             end if

             let d_cts03m00.atdlibhor = w_cts03m00.hora
             let d_cts03m00.atdlibdat = w_cts03m00.data
             let w_cts03m00.atdfnlflg = "S"
             let w_cts03m00.atdetpcod =  4
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             let w_cts03m00.cnldat    = l_data
             let w_cts03m00.atdfnlhor = l_hora2
             let w_cts03m00.c24opemat = g_issk.funmat
             let w_cts03m00.atdhorpvt = "00:00"
             let d_cts03m00.imdsrvflg = "S"
          else
             initialize w_cts03m00.funmat   ,
                        w_cts03m00.cnldat   ,
                        w_cts03m00.atdfnlhor,
                        w_cts03m00.c24opemat,
                        w_cts03m00.atdfnlflg,
                        w_cts03m00.atdetpcod,
                        w_cts03m00.atdprscod,
                        w_cts03m00.c24nomctt  to null
          end if

          #  before field srvprlflg
          #         if d_cts03m00.srvprlflg is null  then
          #            let d_cts03m00.srvprlflg = "N"
          #         end if
          #         display by name d_cts03m00.srvprlflg attribute (reverse)
          
          #  after  field srvprlflg
          #         display by name d_cts03m00.srvprlflg
          #         if fgl_lastkey() = fgl_keyval("up")    or
          #            fgl_lastkey() = fgl_keyval("left")  then
          #            next field atdprinvlcod
          #         else
          #            if d_cts03m00.srvprlflg is null  then
          #               error " Servico particular deve ser informado!"
          #               next field srvprlflg
          #            else
          #               if d_cts03m00.srvprlflg <> "S"  and
          #                  d_cts03m00.srvprlflg <> "N"  then
          #                  error " Servico particular deve ser (S)im ou (N)ao!"
          #                  next field srvprlflg
          #               end if
          #
          #               if d_cts03m00.srvprlflg = "S"  then
          #                  call cts08g01("I","S","","SERVICO PARTICULAR: TODAS AS",
          #                                    "DESPESAS SAO POR CONTA DO SEGURADO!","")
          #                       returning ws.confirma
          #
          #                  if ws.confirma = "N"  then
          #                     error " Servico particular nao confirmado!"
          #                     next field srvprlflg
          #                  end if
          #               end if
          #            end if
          #         end if

   before field atdlibflg
          ##-- inicializar o atdlibflg e passar para o proximo campo
          if d_cts03m00.atdlibflg is null then
             let d_cts03m00.atdlibflg = "S"

             if aux_libant is null  then
                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                let aux_libhor           = l_hora2
                let d_cts03m00.atdlibhor = aux_libhor
                let d_cts03m00.atdlibdat = l_data
             end if

             display by name d_cts03m00.atdlibflg
             next field imdsrvflg
          end if

          display by name d_cts03m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             g_documento.atdsrvano is not null  and
             w_cts03m00.atdfnlflg  =  "S"       then
             exit input
          end if

          if d_cts03m00.atdlibflg is null  and
             g_documento.c24soltipcod  = 1   then   # Tipo solic = Segurado
            #call cts09g00(g_documento.ramcod   ,   # psi 141003
            #              g_documento.succod   ,
            #              g_documento.aplnumdig,
            #              g_documento.itmnumdig,
            #              true)
            #    returning ws.dddcod, ws.teltxt
          end if

   after  field atdlibflg
          display by name d_cts03m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts03m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts03m00.atdlibflg <> "S"  and
                d_cts03m00.atdlibflg <> "N"  then
                error " Envio liberado invalido!"
                next field atdlibflg
             end if

             if d_cts03m00.atdlibflg = "N"  and
                d_cts03m00.prslocflg = "S"  then
                error " Servico com prestador no local deve ser liberado!"
                next field atdlibflg
             end if

            #call cts02m06() returning w_cts03m00.atdlibflg
            #if w_cts03m00.atdlibflg  is null  then
            #   next field atdlibflg
            #end if
            #let d_cts03m00.atdlibflg = w_cts03m00.atdlibflg

             let w_cts03m00.atdlibflg = d_cts03m00.atdlibflg
             display by name d_cts03m00.atdlibflg

             if aux_libant is null  then
                if w_cts03m00.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2)
                       returning l_data, l_hora2
                   let aux_libhor           = l_hora2
                   let d_cts03m00.atdlibhor = aux_libhor
                   let d_cts03m00.atdlibdat = l_data
                else
                   let d_cts03m00.atdlibflg = "N"
                   display by name d_cts03m00.atdlibflg
                   initialize d_cts03m00.atdlibhor to null
                   initialize d_cts03m00.atdlibdat to null
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
                                             " E INFORME AO  ** CONTROLE DE TRAFEGO **")
                   next field atdlibflg
                end if

                if aux_libant = "S"  then
                   if w_cts03m00.atdlibflg = "S"  then
                      next field imdsrvflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts03m00.atdlibflg = "N"
                      display by name d_cts03m00.atdlibflg
                      initialize d_cts03m00.atdlibhor to null
                      initialize d_cts03m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      next field imdsrvflg
                   end if
                else
                   if aux_libant = "N"  then
                      if w_cts03m00.atdlibflg = "N"  then
                         next field imdsrvflg
                      else
                         call cts40g03_data_hora_banco(2)
                             returning l_data, l_hora2
                         let aux_libhor           = l_hora2
                         let d_cts03m00.atdlibhor = aux_libhor
                         let d_cts03m00.atdlibdat = l_data
                         next field imdsrvflg
                      end if
                   end if
                end if
             end if
          else
             next field rmcacpflg
          end if

   before field imdsrvflg
          let m_imdsrvflg_ant = d_cts03m00.imdsrvflg
          display by name d_cts03m00.imdsrvflg attribute (reverse)
          
   after  field imdsrvflg
          display by name d_cts03m00.imdsrvflg
          
          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts03m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if
          
          if (m_cidnom != a_cts03m00[1].cidnom) or
             (m_ufdcod != a_cts03m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts03m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if
          
          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts03m00.imdsrvflg
          end if
          
          if m_cidnom is null then
             let m_cidnom = a_cts03m00[1].cidnom
          end if
          
          if m_ufdcod is null then
             let m_ufdcod = a_cts03m00[1].ufdcod
          end if
          
          # Envia a chave antiga no input quando alteracao. 
          # Se for a situacao INC, regulou, voltou para o laudo (CTRL+C) e regulou  
          # novamente manda a mesma pra ver se ainda e valida
          if g_documento.acao = "ALT"
             then
             let m_rsrchv = m_rsrchvant
          end if
          # PSI-2013-00440PR
          
          #display 'VALORES EM after field imdsrvflg'
          #display 'm_cidnom            : ', m_cidnom            
          #display 'm_ufdcod            : ', m_ufdcod            
          #display 'a_cts03m00[1].cidnom: ', a_cts03m00[1].cidnom
          #display 'a_cts03m00[1].ufdcod: ', a_cts03m00[1].ufdcod
          #display 'm_imdsrvflg         : ', m_imdsrvflg 
          #display 'd_cts03m00.imdsrvflg: ', d_cts03m00.imdsrvflg
          #display 'm_operacao          : ', m_operacao
          #display 'm_altcidufd         : ', m_altcidufd
          
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             
             if d_cts03m00.imdsrvflg is null   or
                d_cts03m00.imdsrvflg =  " "    then
                error " Informacoes sobre servico imediato deve ser informado!"
                next field imdsrvflg
             end if

             if d_cts03m00.imdsrvflg <> "S"    and
                d_cts03m00.imdsrvflg <> "N"    then
                error " Servico imediato: (S)im ou (N)ao!"
                next field imdsrvflg
             end if

             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false then  # regulacao antiga
                
                if g_cidcod is null or g_cidcod = 0 then
                    open  ccts03m00013 using m_cidnom
                                            ,m_ufdcod
                    fetch ccts03m00013  into l_mpacidcod
                    close ccts03m00013
                    
                    if l_mpacidcod is not null and l_mpacidcod <> 0  then                                        
                        call cts06g03_carrega_glo(1,g_documento.atdsrvorg,l_mpacidcod, '')
                    end if
                 end if                
                
                call cts02m03(w_cts03m00.atdfnlflg,
                              d_cts03m00.imdsrvflg,
                              w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg)
                    returning w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg
	          else
	             # obter a chave de regulacao no AW.
                call cts02m08(w_cts03m00.atdfnlflg,
                              d_cts03m00.imdsrvflg,
                              m_altcidufd,
                              d_cts03m00.prslocflg,
                              w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts03m00[1].cidnom,
                              a_cts03m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts03m00.vclcoddig,
                              w_cts03m00.ctgtrfcod,
                              d_cts03m00.imdsrvflg,
                              a_cts03m00[1].c24lclpdrcod,
                              a_cts03m00[1].lclltt,
                              a_cts03m00[1].lcllgt,
                              g_documento.ciaempcod,
                              d_cts03m00.atdsrvorg,
                              d_cts03m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts03m00.atdhorpvt,
                              w_cts03m00.atddatprg,
                              w_cts03m00.atdhorprg,
                              w_cts03m00.atdpvtretflg,
                              d_cts03m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
               
                display by name d_cts03m00.imdsrvflg
                
                #display 'RETORNO 02M08 INCLUI:'
                #display 'w_cts03m00.atdhorpvt   : ', w_cts03m00.atdhorpvt
                #display 'w_cts03m00.atddatprg   : ', w_cts03m00.atddatprg
                #display 'w_cts03m00.atdhorprg   : ', w_cts03m00.atdhorprg
                #display 'w_cts03m00.atdpvtretflg: ', w_cts03m00.atdpvtretflg
                #display 'd_cts03m00.imdsrvflg   : ', d_cts03m00.imdsrvflg
                #display 'm_rsrchv               : ', m_rsrchv
                #display 'm_operacao             : ', m_operacao
                #display 'm_altdathor            : ', m_altdathor  
                
                if int_flag
                   then
                   let int_flag = false
                   next field imdsrvflg
                   #display 'int_flag do laudo'
                end if
                
             end if
             
             if d_cts03m00.imdsrvflg = "S"  then
                if w_cts03m00.atdhorpvt is null  then
                   error " Horas previstas nao informadas para servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts03m00.atddatprg is null  or
                   w_cts03m00.atddatprg  = " "   or
                   w_cts03m00.atdhorprg is null  then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts03m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts03m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts03m00.atdprinvlcod

                    display by name d_cts03m00.atdprinvlcod
                    display by name d_cts03m00.atdprinvldes
                end if
             end if
          else
             if d_cts03m00.asitipcod = 2  or
                d_cts03m00.asitipcod = 4  or
                d_cts03m00.frmflg    = "S" then
                next field asitipcod
             end if
          end if

          # PSI-2013-00440PR
          if m_agendaw = false   # regulacao antiga
             then
             ### REGULADOR
             if d_cts03m00.prslocflg <> "S"   then
                #### CHAMA REGULADOR ####
                if d_cts03m00.imdsrvflg = "S"  then
                   let ws.rglflg = ctc59m02 ( a_cts03m00[1].cidnom,
                                              a_cts03m00[1].ufdcod,
                                              d_cts03m00.atdsrvorg,
                                              d_cts03m00.asitipcod,
                                              aux_today,
                                              aux_hora,
                                              false)        #PSI202363
                else
                   let ws.rglflg = ctc59m02 ( a_cts03m00[1].cidnom,
                                              a_cts03m00[1].ufdcod,
                                              d_cts03m00.atdsrvorg,
                                              d_cts03m00.asitipcod,
                                              w_cts03m00.atddatprg,
                                              w_cts03m00.atdhorprg,
                                              false )        #PSI202363
                end if
                if ws.rglflg <> 0 then
                   let d_cts03m00.imdsrvflg = "N"
                   call ctc59m03 ( a_cts03m00[1].cidnom,
                                   a_cts03m00[1].ufdcod,
                                   d_cts03m00.atdsrvorg,
                                   d_cts03m00.asitipcod,
                                   aux_today,
                                   aux_hora)
                        returning  w_cts03m00.atddatprg,
                                   w_cts03m00.atdhorprg
                   next field imdsrvflg
                end if
                if g_documento.atdsrvnum is not null  and
                   g_documento.atdsrvano is not null  then
   
                   # Para abater regulador
                   let ws.rglflg = ctc59m03_regulador(g_documento.atdsrvnum,
                                           g_documento.atdsrvano)
                end if
             end if
          end if  # PSI-2013-00440PR
          
   on key (interrupt)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         let ws.confirma = cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")

         if ws.confirma  =  "S"   then
            call ctc61m02_criatmp(2, g_documento.atdsrvnum
                                 ,g_documento.atdsrvano)
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
            let g_documento.atdsrvnum = f4.atdsrvnum
            let g_documento.atdsrvano = f4.atdsrvano
            initialize f4.* to null
            call consulta_cts03m00()
            display by name d_cts03m00.*
            display by name d_cts03m00.c24solnom attribute (reverse)
            display by name d_cts03m00.cvnnom    attribute (reverse)
            if d_cts03m00.desapoio is not null then
               display by name d_cts03m00.desapoio attribute (reverse)
            end if
            call cts02m00_ver_uso(l_atdsrvnum,l_atdsrvano,1)
                 returning l_msg
         else
            exit input
         end if
      end if

   on key (F1)
      if d_cts03m00.c24astcod is not null then
         call ctc58m00_vis(d_cts03m00.c24astcod)
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

   on key (F4)
      if m_outrolaudo = 1 or
         g_documento.acao <> "CON" then
         error "Nao e possivel visualizar outros laudos no momento."
      else
         #verificar se laudo é um laudo de apoio ou se laudo tem servicos de apoio
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

                  #salva informações laudo original
                  let f4.acao = g_documento.acao
                  let f4.atdsrvnum = g_documento.atdsrvnum
                  let f4.atdsrvano = g_documento.atdsrvano
                  #atualiza informacoes para novo laudo
                  let g_documento.acao = "CON"
                  let g_documento.atdsrvnum = l_atdsrvnum
                  let g_documento.atdsrvano = l_atdsrvano
                  #chama funcao consulta para novo laudo
                  let m_outrolaudo = 1
                  call consulta_cts03m00()
                  display by name d_cts03m00.*
                  display by name d_cts03m00.c24solnom attribute (reverse)
                  display by name d_cts03m00.cvnnom    attribute (reverse)
                  if d_cts03m00.desapoio is not null then
                     display by name d_cts03m00.desapoio attribute (reverse)
                  end if
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
            let ws.prpflg = opacc149( g_documento.prporg, g_documento.prpnumdig )
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
      if g_documento.atdsrvnum is null then
         call cts10m02 (hist_cts03m00.*) returning hist_cts03m00.*
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
            if g_documento.atdsrvnum is null then
               error " Impressao somente com cadastramento do servico!"
            else
               call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
            end if

         when 2  ### Condutor
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
                     if g_documento.cndslcflg = "S" then
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
            if d_cts03m00.camflg = "S"  then
               call cts02m01(w_cts03m00.ctgtrfcod,
                             g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             w_cts03m00.vclcrgflg, w_cts03m00.vclcrgpso,
                             w_cts03m00.vclcamtip, w_cts03m00.vclcrcdsc)
                   returning w_cts03m00.vclcrgflg, w_cts03m00.vclcrgpso,
                             w_cts03m00.vclcamtip, w_cts03m00.vclcrcdsc

               if w_cts03m00.vclcamtip  is null   and
                  w_cts03m00.vclcrgflg  is null   then
                  error " Faltam informacoes sobre caminhao/utilitario!"
               end if
            end if
         when 4   #### Distancia QTH-QTI
                if (g_documento.c24astcod <> 'M15' and
					          g_documento.c24astcod <> 'M20' and
					          g_documento.c24astcod <> 'M23' and
					          g_documento.c24astcod <> 'M33') then
	                 call cts00m33(1,
	                               a_cts03m00[1].lclltt,
	                               a_cts03m00[1].lcllgt,
	                               a_cts03m00[2].lclltt,
	                               a_cts03m00[2].lcllgt)
                end if
         when 5   #### Apresentar Locais e as condicoes do veiculo
            if g_documento.atdsrvnum is not null  and
               g_documento.atdsrvano is not null  then
               call ctc61m02(g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             "A")

               let tmp_flg = ctc61m02_criatmp(2,
                                              g_documento.atdsrvnum,
                                              g_documento.atdsrvano)

               if tmp_flg = 1 then
                  error "Problemas com temporaria! <Avise a Informatica> "
               end if
            end if

      end case

   on key (F8)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts03m00.dstflg = "N"  then
            error " Nao foi informado destino para este servico!"
         else
            let a_cts03m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
            let m_acesso_ind = false
            call cta00m06_acesso_indexacao_aut(d_cts03m00.atdsrvorg)
                 returning m_acesso_ind

            #Projeto alteracao cadastro de destino
            if g_documento.acao = "ALT" then

               call cts03m00_bkp_info_dest(1, hist_cts03m00.*)
                  returning hist_cts03m00.*

            end if

            if m_acesso_ind = false then
               call cts06g03(2
                            ,d_cts03m00.atdsrvorg
                            ,w_cts03m00.ligcvntip
                            ,aux_today
                            ,aux_hora
                            ,a_cts03m00[2].lclidttxt
                            ,a_cts03m00[2].cidnom
                            ,a_cts03m00[2].ufdcod
                            ,a_cts03m00[2].brrnom
                            ,a_cts03m00[2].lclbrrnom
                            ,a_cts03m00[2].endzon
                            ,a_cts03m00[2].lgdtip
                            ,a_cts03m00[2].lgdnom
                            ,a_cts03m00[2].lgdnum
                            ,a_cts03m00[2].lgdcep
                            ,a_cts03m00[2].lgdcepcmp
                            ,a_cts03m00[2].lclltt
                            ,a_cts03m00[2].lcllgt
                            ,a_cts03m00[2].lclrefptotxt
                            ,a_cts03m00[2].lclcttnom
                            ,a_cts03m00[2].dddcod
                            ,a_cts03m00[2].lcltelnum
                            ,a_cts03m00[2].c24lclpdrcod
                            ,a_cts03m00[2].ofnnumdig
                            ,a_cts03m00[2].celteldddcod
                            ,a_cts03m00[2].celtelnum
                            ,a_cts03m00[2].endcmp
                            ,hist_cts03m00.*
                            ,a_cts03m00[2].emeviacod )
                   returning a_cts03m00[2].lclidttxt
                            ,a_cts03m00[2].cidnom
                            ,a_cts03m00[2].ufdcod
                            ,a_cts03m00[2].brrnom
                            ,a_cts03m00[2].lclbrrnom
                            ,a_cts03m00[2].endzon
                            ,a_cts03m00[2].lgdtip
                            ,a_cts03m00[2].lgdnom
                            ,a_cts03m00[2].lgdnum
                            ,a_cts03m00[2].lgdcep
                            ,a_cts03m00[2].lgdcepcmp
                            ,a_cts03m00[2].lclltt
                            ,a_cts03m00[2].lcllgt
                            ,a_cts03m00[2].lclrefptotxt
                            ,a_cts03m00[2].lclcttnom
                            ,a_cts03m00[2].dddcod
                            ,a_cts03m00[2].lcltelnum
                            ,a_cts03m00[2].c24lclpdrcod
                            ,a_cts03m00[2].ofnnumdig
                            ,a_cts03m00[2].celteldddcod
                            ,a_cts03m00[2].celtelnum
                            ,a_cts03m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts03m00.*
                            ,a_cts03m00[2].emeviacod
            else

               call cts06g11(2
                            ,d_cts03m00.atdsrvorg
                            ,w_cts03m00.ligcvntip
                            ,aux_today
                            ,aux_hora
                            ,a_cts03m00[2].lclidttxt
                            ,a_cts03m00[2].cidnom
                            ,a_cts03m00[2].ufdcod
                            ,a_cts03m00[2].brrnom
                            ,a_cts03m00[2].lclbrrnom
                            ,a_cts03m00[2].endzon
                            ,a_cts03m00[2].lgdtip
                            ,a_cts03m00[2].lgdnom
                            ,a_cts03m00[2].lgdnum
                            ,a_cts03m00[2].lgdcep
                            ,a_cts03m00[2].lgdcepcmp
                            ,a_cts03m00[2].lclltt
                            ,a_cts03m00[2].lcllgt
                            ,a_cts03m00[2].lclrefptotxt
                            ,a_cts03m00[2].lclcttnom
                            ,a_cts03m00[2].dddcod
                            ,a_cts03m00[2].lcltelnum
                            ,a_cts03m00[2].c24lclpdrcod
                            ,a_cts03m00[2].ofnnumdig
                            ,a_cts03m00[2].celteldddcod
                            ,a_cts03m00[2].celtelnum
                            ,a_cts03m00[2].endcmp
                            ,hist_cts03m00.*
                            ,a_cts03m00[2].emeviacod )
                   returning a_cts03m00[2].lclidttxt
                            ,a_cts03m00[2].cidnom
                            ,a_cts03m00[2].ufdcod
                            ,a_cts03m00[2].brrnom
                            ,a_cts03m00[2].lclbrrnom
                            ,a_cts03m00[2].endzon
                            ,a_cts03m00[2].lgdtip
                            ,a_cts03m00[2].lgdnom
                            ,a_cts03m00[2].lgdnum
                            ,a_cts03m00[2].lgdcep
                            ,a_cts03m00[2].lgdcepcmp
                            ,a_cts03m00[2].lclltt
                            ,a_cts03m00[2].lcllgt
                            ,a_cts03m00[2].lclrefptotxt
                            ,a_cts03m00[2].lclcttnom
                            ,a_cts03m00[2].dddcod
                            ,a_cts03m00[2].lcltelnum
                            ,a_cts03m00[2].c24lclpdrcod
                            ,a_cts03m00[2].ofnnumdig
                            ,a_cts03m00[2].celteldddcod
                            ,a_cts03m00[2].celtelnum
                            ,a_cts03m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts03m00.*
                            ,a_cts03m00[2].emeviacod

            end if

            #Projeto alteracao cadastro de destino
            let m_grava_hist = false

            if g_documento.acao = "ALT" then

               call cts03m00_verifica_tipo_atendim()
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
                        call cts03m00_verifica_op_ativa()
                             returning l_status

                        if l_status then

                           # ---> SALVA O NOME DO SEGURADO
                           let d_cts03m00.nom = l_salva_nom
                           display by name d_cts03m00.nom

                           error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) 

                           error " Servico ja' acionado nao pode ser alterado!"
                           let m_srv_acionado = true
                           let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                      " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")

                           ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                           if m_agendaw = false   # regulacao antiga
                              then
                              call cts02m03(w_cts03m00.atdfnlflg,
                                            d_cts03m00.imdsrvflg,
                                            w_cts03m00.atdhorpvt,
                                            w_cts03m00.atddatprg,
                                            w_cts03m00.atdhorprg,
                                            w_cts03m00.atdpvtretflg)
                                  returning w_cts03m00.atdhorpvt,
                                            w_cts03m00.atddatprg,
                                            w_cts03m00.atdhorprg,
                                            w_cts03m00.atdpvtretflg
                           else
                              call cts02m08(w_cts03m00.atdfnlflg,
                                            d_cts03m00.imdsrvflg,
                                            m_altcidufd,
                                            d_cts03m00.prslocflg,
                                            w_cts03m00.atdhorpvt,
                                            w_cts03m00.atddatprg,
                                            w_cts03m00.atdhorprg,
                                            w_cts03m00.atdpvtretflg,
                                            m_rsrchvant,
                                            m_operacao,
                                            "",
                                            a_cts03m00[1].cidnom,
                                            a_cts03m00[1].ufdcod,
                                            "",   # codigo de assistencia, nao existe no Ct24h
                                            d_cts03m00.vclcoddig,
                                            w_cts03m00.ctgtrfcod,
                                            d_cts03m00.imdsrvflg,
                                            a_cts03m00[1].c24lclpdrcod,
                                            a_cts03m00[1].lclltt,
                                            a_cts03m00[1].lcllgt,
                                            g_documento.ciaempcod,
                                            d_cts03m00.atdsrvorg,
                                            d_cts03m00.asitipcod,
                                            "",   # natureza somente RE
                                            "")   # sub-natureza somente RE
                                  returning w_cts03m00.atdhorpvt,
                                            w_cts03m00.atddatprg,
                                            w_cts03m00.atdhorprg,
                                            w_cts03m00.atdpvtretflg,
                                            d_cts03m00.imdsrvflg,
                                            m_rsrchv,
                                            m_operacao,
                                            m_altdathor
                           end if
                           display by name d_cts03m00.imdsrvflg
                           ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
                           
                           if d_cts03m00.frmflg = "S" then
                              call cts11g00(w_cts03m00.lignum)
                              let int_flag = true
                           end if

                           call cts03m00_bkp_info_dest(2, hist_cts03m00.*)
                              returning hist_cts03m00.*

                           exit input

                        else

                           let m_grava_hist   = true
                           let m_srv_acionado = false

                           let m_subbairro[2].lclbrrnom = a_cts03m00[2].lclbrrnom
                           call cts06g10_monta_brr_subbrr(a_cts03m00[2].brrnom,
                                                          a_cts03m00[2].lclbrrnom)
                                returning a_cts03m00[2].lclbrrnom
                           let a_cts03m00[2].lgdtxt = a_cts03m00[2].lgdtip clipped, " ",
                                                      a_cts03m00[2].lgdnom clipped, " ",
                                                      a_cts03m00[2].lgdnum using "<<<<#"
                           if a_cts03m00[2].lclltt <> a_cts03m00[3].lclltt or
                              a_cts03m00[2].lcllgt <> a_cts03m00[3].lcllgt or
                              (a_cts03m00[3].lclltt is null and a_cts03m00[2].lclltt is not null) or
                              (a_cts03m00[3].lcllgt is null and a_cts03m00[2].lcllgt is not null) then
                                 call cts00m33(1,
                                               a_cts03m00[1].lclltt,
                                               a_cts03m00[1].lcllgt,
                                               a_cts03m00[2].lclltt,
                                               a_cts03m00[2].lcllgt)
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
                                 if w_cts03m00.socvclcod is null then
                                    select socvclcod
                                      into w_cts03m00.socvclcod
                                      from datmsrvacp acp
                                     where acp.atdsrvnum = g_documento.atdsrvnum
                                       and acp.atdsrvano = g_documento.atdsrvano
                                       and acp.atdsrvseq = (select max(atdsrvseq)
                                                              from datmsrvacp acp1
                                                             where acp1.atdsrvnum = acp.atdsrvnum
                                                               and acp1.atdsrvano = acp.atdsrvano)
                                 end if
  
                                 #       display 'w_cts03m00.socvclcod ', w_cts03m00.socvclcod

                                 select mdtcod
                                 into m_mdtcod
                                 from datkveiculo
                                 where socvclcod = w_cts03m00.socvclcod

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
                                 and cpocod = w_cts03m00.vclcorcod

                                 select empnom
                                 into l_ciaempnom
                                 from gabkemp
                                 where empcod  = g_documento.ciaempcod

                                 whenever error stop

                                 let l_dtalt = today
                                 let l_hralt = current
                                 let l_lgdtxtcl = a_cts03m00[2].lgdtip clipped, " ",
                                                  a_cts03m00[2].lgdnom clipped, " ",
                                                  a_cts03m00[2].lgdnum using "<<<<#", " ",
                                                  a_cts03m00[2].endcmp clipped
 
 
                                 let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                     l_ciaempnom clipped, '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '
 
                                 let l_msgaltend = l_texto clipped
                                     ," QRU: ", d_cts03m00.atdsrvorg using "&&"
                                          ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                          ,"-", g_documento.atdsrvano using "&&"
                                     ," QTR: ", l_dtalt, " ", l_hralt
                                     ," QNC: ", d_cts03m00.nom             clipped, " "
                                              , d_cts03m00.vcldes          clipped, " "
                                              , d_cts03m00.vclanomdl       clipped, " "
                                     ," QNR: ", d_cts03m00.vcllicnum       clipped, " "
                                              , l_vclcordes       clipped, " "
                                     ," QTI: ", a_cts03m00[2].lclidttxt       clipped, " - "
                                              , l_lgdtxtcl                 clipped, " - "
                                              , a_cts03m00[2].brrnom          clipped, " - "
                                              , a_cts03m00[2].cidnom          clipped, " - "
                                              , a_cts03m00[2].ufdcod          clipped, " "
                                     ," Ref: ", a_cts03m00[2].lclrefptotxt    clipped, " "
                                    ," Resp: ", a_cts03m00[2].lclcttnom       clipped, " "
                                    ," Tel: (", a_cts03m00[2].dddcod          clipped, ") "
                                              , a_cts03m00[2].lcltelnum       clipped, " "
                                   ," Acomp: ", d_cts03m00.rmcacpflg          clipped, "#"

                                   
                                   #           display 'm_pstcoddig: ',m_pstcoddig
                                   #           display 'm_socvclcod: ',m_socvclcod
                                   #           display 'm_srrcoddig: ',m_srrcoddig
                                   #           display 'l_msgaltend: ',l_msgaltend

                                   call ctx34g02_enviar_msg_gps(m_pstcoddig,
                                                                m_socvclcod,
                                                                m_srrcoddig,
                                                                l_msgaltend)
                                         returning l_msgrtgps, l_codrtgps

                                   if l_codrtgps = 0 then
                                      display "Mensagem Enviada com Sucesso ao GPS do Prestador"
                                   else
                                      display "Mensagem não enviada. Erro: ", l_codrtgps,
                                          " - ", l_msgrtgps clipped
                                   end if
                              end if
                           end if
                           ###Moreira-Envia-QRU-GPS

                           exit input

                        end if
                     else
                        call cts03m00_bkp_info_dest(2, hist_cts03m00.*)
                           returning hist_cts03m00.*

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

            if  a_cts03m00[2].cidnom is not null and
                a_cts03m00[2].ufdcod is not null then
                call cts14g00 (d_cts03m00.c24astcod,
                               "","","","",
                               a_cts03m00[2].cidnom,
                               a_cts03m00[2].ufdcod,
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
                           d_cts03m00.vcllicnum ,
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
                             returning a_cts03m00[1].lclidttxt
                                      ,a_cts03m00[1].lgdtip
                                      ,a_cts03m00[1].lgdnom
                                      ,a_cts03m00[1].lgdnum
                                      ,a_cts03m00[1].lclbrrnom
                                      ,a_cts03m00[1].brrnom
                                      ,a_cts03m00[1].cidnom
                                      ,a_cts03m00[1].ufdcod
                                      ,a_cts03m00[1].lclrefptotxt
                                      ,a_cts03m00[1].endzon
                                      ,a_cts03m00[1].lgdcep
                                      ,a_cts03m00[1].lgdcepcmp
                                      ,a_cts03m00[1].lclltt
                                      ,a_cts03m00[1].lcllgt
                                      ,a_cts03m00[1].dddcod
                                      ,a_cts03m00[1].lcltelnum
                                      ,a_cts03m00[1].lclcttnom
                                      ,a_cts03m00[1].c24lclpdrcod
                                      ,a_cts03m00[1].celteldddcod
                                      ,a_cts03m00[1].celtelnum     # Amilton
                                      ,a_cts03m00[1].endcmp
                                      ,ws.codigosql
                                      ,a_cts03m00[1].emeviacod

               select ofnnumdig into a_cts03m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = cpl_atdsrvano
                  and atdsrvnum = cpl_atdsrvnum
                  and c24endtip = 1

               if ws.codigosql <> 0  then
                  error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                  prompt "" for char prompt_key
                  initialize hist_cts03m00.* to null
                  return hist_cts03m00.*
               end if

               let a_cts03m00[1].lgdtxt = a_cts03m00[1].lgdtip clipped, " ",
                                          a_cts03m00[1].lgdnom clipped, " ",
                                          a_cts03m00[1].lgdnum using "<<<<#"

               #-----------------------------------------------------------
               # Informacoes do local de destino
               #-----------------------------------------------------------
               call ctx04g00_local_gps(cpl_atdsrvnum,
                                       cpl_atdsrvano,
                                       2)
                             returning a_cts03m00[2].lclidttxt
                                      ,a_cts03m00[2].lgdtip
                                      ,a_cts03m00[2].lgdnom
                                      ,a_cts03m00[2].lgdnum
                                      ,a_cts03m00[2].lclbrrnom
                                      ,a_cts03m00[2].brrnom
                                      ,a_cts03m00[2].cidnom
                                      ,a_cts03m00[2].ufdcod
                                      ,a_cts03m00[2].lclrefptotxt
                                      ,a_cts03m00[2].endzon
                                      ,a_cts03m00[2].lgdcep
                                      ,a_cts03m00[2].lgdcepcmp
                                      ,a_cts03m00[2].lclltt
                                      ,a_cts03m00[2].lcllgt
                                      ,a_cts03m00[2].dddcod
                                      ,a_cts03m00[2].lcltelnum
                                      ,a_cts03m00[2].lclcttnom
                                      ,a_cts03m00[2].c24lclpdrcod
                                      ,a_cts03m00[2].celteldddcod
                                      ,a_cts03m00[2].celtelnum     # Amilton
                                      ,a_cts03m00[2].endcmp
                                      ,ws.codigosql
                                      ,a_cts03m00[2].emeviacod

               select ofnnumdig into a_cts03m00[2].ofnnumdig
                 from datmlcl
                where atdsrvano = cpl_atdsrvano
                  and atdsrvnum = cpl_atdsrvnum
                  and c24endtip = 2

               if ws.codigosql = notfound   then
                  let d_cts03m00.dstflg = "N"
               else
                  if ws.codigosql = 0   then
                     let d_cts03m00.dstflg = "S"
                  else
                     error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
                     prompt "" for char prompt_key
                     initialize hist_cts03m00.* to null
                     return hist_cts03m00.*
                  end if
               end if

               let a_cts03m00[2].lgdtxt = a_cts03m00[2].lgdtip clipped, " ",
                                          a_cts03m00[2].lgdnom clipped, " ",
                                          a_cts03m00[2].lgdnum using "<<<<#"

               call cts16g00_atendimento(cpl_atdsrvnum, cpl_atdsrvano)
                               returning d_cts03m00.nom,
                                         w_cts03m00.vclcorcod,
                                         d_cts03m00.vclcordes

               display by name d_cts03m00.*
               display by name a_cts03m00[1].lgdtxt
               display by name a_cts03m00[1].lclbrrnom
               display by name a_cts03m00[1].endzon
               display by name a_cts03m00[1].cidnom
               display by name a_cts03m00[1].ufdcod
               display by name a_cts03m00[1].lclrefptotxt
               display by name a_cts03m00[1].lclcttnom
               display by name a_cts03m00[1].dddcod
               display by name a_cts03m00[1].lcltelnum
               display by name a_cts03m00[1].celteldddcod
               display by name a_cts03m00[1].celtelnum
               display by name a_cts03m00[1].endcmp
            end if
         end if
      else
         if d_cts03m00.atdlibflg = "N" then
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

##PSI207233
   on key (f10)
      #display "g_documento.c24astcod -> ", g_documento.c24astcod
      if g_documento.atdsrvnum is not null then
         if g_documento.c24astcod = "S11"  or
            g_documento.c24astcod = "S14"  or
            g_documento.c24astcod = "S53"  or
            g_documento.c24astcod = "S64"  or
            g_documento.c24astcod = "SUC"  then
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
    initialize hist_cts03m00.* to null
 end if

return hist_cts03m00.*

end function  ###  input_cts03m00

#--------------------------------------------------------------------------
function cts03m00_grava_dados(ws,hist_cts03m00)
#--------------------------------------------------------------------------
  define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
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
        cdtseq          like aeikcdt.cdtseq        ,
        c24astagp       like datkassunto.c24astagp        #psi230650
 end record

 define lr_ret        record
    retorno           smallint
   ,mensagem          char(100)
   ,atdsrvnum         like datmservico.atdsrvnum
   ,atdsrvano         like datmservico.atdsrvano
 end record

 define hist_cts03m00   record
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


  initialize lr_ret.* to null
  initialize  lr_clausula.* to  null

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

   call cts10g03_numeracao( 2, ws.atdtip )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS03M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum = ws.lignum
   let aux_atdsrvnum      = ws.atdsrvnum
   let aux_atdsrvano      = ws.atdsrvano
    
 
 # Verifica se deve mudar a empresa do serviço aberto no cartao
 let m_ciaempcod_slv = g_documento.ciaempcod
 if g_documento.ciaempcod = 40 and ctb85g02_asi_cartao_pss(d_cts03m00.asitipcod) then
    let g_documento.ciaempcod = 43 # PSS
 end if
 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   #display "4412 - g_documento.c24astcod = ",g_documento.c24astcod
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts03m00.data         ,
                           w_cts03m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts03m00.funmat       ,
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
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   call cts10g02_grava_servico( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                w_cts03m00.vclcorcod,
                                w_cts03m00.funmat   ,
                                d_cts03m00.atdlibflg,
                                d_cts03m00.atdlibhor,
                                d_cts03m00.atdlibdat,
                                w_cts03m00.data     ,     # atddat
                                w_cts03m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts03m00.atdhorpvt,
                                w_cts03m00.atddatprg,
                                w_cts03m00.atdhorprg,
                                ws.atdtip           ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts03m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts03m00.atdfnlflg,
                                w_cts03m00.atdfnlhor,
                                d_cts03m00.atdrsdflg,
                                d_cts03m00.atddfttxt,
                                ""                  ,     # atddoctxt
                                w_cts03m00.c24opemat,
                                d_cts03m00.nom      ,
                                d_cts03m00.vcldes   ,
                                d_cts03m00.vclanomdl,
                                d_cts03m00.vcllicnum,
                                d_cts03m00.corsus   ,
                                d_cts03m00.cornom   ,
                                w_cts03m00.cnldat   ,
                                ""                  ,     # pgtdat
                                w_cts03m00.c24nomctt,
                                w_cts03m00.atdpvtretflg,
                                w_cts03m00.atdvcltip,
                                d_cts03m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts03m00.vclcoddig,
                                d_cts03m00.srvprlflg,
                                ""                  ,     # srrcoddig
                                d_cts03m00.atdprinvlcod,
                                d_cts03m00.atdsrvorg    ) # ATDSRVORG
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

   call cts10g02_grava_loccnd(aux_atdsrvnum
                          ,aux_atdsrvano)
     returning ws.tabname, ws.codigosql

    if ws.codigosql <> 0 then
       display "ERRO (", ws.codigosql ,") na gravacao da ", ws.tabname
       rollback work
       prompt "" for char ws.prompt_key
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
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
    end if

 #------------------------------------------------------------------------------
 # Insere Motivo de Recusa ao CAPS nos servicos de Guincho ## PSI
 #------------------------------------------------------------------------------
 if ws_mtvcaps is not null and
    ws_mtvcaps <> 0        then

    --> Verifica se ja existe o mesmo motivo para a ligacao
    select lignum
      from datrligrcuccsmtv
     where lignum       = g_documento.lignum
       and rcuccsmtvcod = ws_mtvcaps
       and c24astcod    = g_documento.c24astcod

    if sqlca.sqlcode <> 0 then

       insert into datrligrcuccsmtv (lignum
                                    ,rcuccsmtvcod
                                    ,c24astcod)
                             values (g_documento.lignum
                                    ,ws_mtvcaps
                                    ,g_documento.c24astcod)

       if sqlca.sqlcode <> 0 then
          error " Erro (", sqlca.sqlcode, ") na gravacao do",
                " Motivo de Recusa do CAPS. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.prompt_key
          let ws.retorno = false
          exit while
       end if
    end if
 end if


 #------------------------------------------------------------------------------
 # Insere inf. de pagamentos na tabela dbscadtippgt  ## PSI207233
 #------------------------------------------------------------------------------
    if d_cts03m00.c24astcod = "S11"  or
       d_cts03m00.c24astcod = "S14"  or
       d_cts03m00.c24astcod = "S53"  or
       d_cts03m00.c24astcod = "S64"  then

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
            prompt "" for char ws.prompt_key
            let ws.retorno = false
            exit while
        end if
    end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if d_cts03m00.prslocflg = "S" then
      update datmservico set prslocflg = d_cts03m00.prslocflg,
                             socvclcod = w_cts03m00.socvclcod,
                             srrcoddig = w_cts03m00.srrcoddig
       where datmservico.atdsrvnum = aux_atdsrvnum
         and datmservico.atdsrvano = aux_atdsrvano

   end if

 #------------------------------------------------------------------------------
 # Grava problemas do servico
 #------------------------------------------------------------------------------
   call ctx09g02_inclui(aux_atdsrvnum       ,
                        aux_atdsrvano       ,
                        1                   , # Org. informacao 1-Segurado 2-Pst
                        d_cts03m00.c24pbmcod,
                        d_cts03m00.atddfttxt,
                        ""                  ) # Codigo prestador
        returning ws.codigosql,
                  ws.tabname
   if  ws.codigosql  <>  0  then
       error "ctx09g02_inclui", ws.codigosql, ws.tabname
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # GUINCHO PEQUENO e possui CAMBIO HIDRAMATICO, grava no historico do servico
 #------------------------------------------------------------------------------
   if  w_cts03m00.atdvcltip = 2  then
       if  ws.vclatmflg = 1  then

           call ctd07g01_ins_datmservhist(aux_atdsrvnum,
                                          aux_atdsrvano,
                                          g_issk.funmat,
                                          "VEICULO COM CAMBIO HIDRAMATICO/AUTOMATICO",
                                          w_cts03m00.data,
                                          w_cts03m00.hora,
                                          g_issk.empcod,
                                          g_issk.usrtip)

                returning lr_ret.retorno,
                          lr_ret.mensagem

           if  lr_ret.retorno  <>  1  then
               error lr_ret.mensagem, " - CTS03M00 - AVISE A INFORMATICA!"
               rollback work
               prompt "" for char ws.prompt_key
               let ws.retorno = false
               exit while
           end if
       end if
   end if


 #------------------------------------------------------------------------------
 # Grava complemento do servico
 #------------------------------------------------------------------------------
   insert into DATMSERVICOCMP ( atdsrvnum ,
                                atdsrvano ,
                                rmcacpflg ,
                                vclcamtip ,
                                vclcrcdsc ,
                                vclcrgflg ,
                                vclcrgpso ,
                                sindat    ,
                                sinhor )
               values ( aux_atdsrvnum       ,
                        aux_atdsrvano       ,
                        d_cts03m00.rmcacpflg,
                        w_cts03m00.vclcamtip,
                        w_cts03m00.vclcrcdsc,
                        w_cts03m00.vclcrgflg,
                        w_cts03m00.vclcrgpso,
                        d_cts03m00.sindat   ,
                        d_cts03m00.sinhor )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
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
       if  a_cts03m00[arr_aux].operacao is null  then
           let a_cts03m00[arr_aux].operacao = "I"
       end if
       if g_documento.c24astcod = "SAP" and
          m_multiplo = 'S'              and
          arr_aux = 2                   then
          exit for
       end if
       if  (arr_aux = 1 and d_cts03m00.frmflg = "N") or arr_aux = 2 then
           let a_cts03m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
       end if
       let ws.codigosql = cts06g07_local( a_cts03m00[arr_aux].operacao
                                       ,aux_atdsrvnum
                                       ,aux_atdsrvano
                                       ,arr_aux
                                       ,a_cts03m00[arr_aux].lclidttxt
                                       ,a_cts03m00[arr_aux].lgdtip
                                       ,a_cts03m00[arr_aux].lgdnom
                                       ,a_cts03m00[arr_aux].lgdnum
                                       ,a_cts03m00[arr_aux].lclbrrnom
                                       ,a_cts03m00[arr_aux].brrnom
                                       ,a_cts03m00[arr_aux].cidnom
                                       ,a_cts03m00[arr_aux].ufdcod
                                       ,a_cts03m00[arr_aux].lclrefptotxt
                                       ,a_cts03m00[arr_aux].endzon
                                       ,a_cts03m00[arr_aux].lgdcep
                                       ,a_cts03m00[arr_aux].lgdcepcmp
                                       ,a_cts03m00[arr_aux].lclltt
                                       ,a_cts03m00[arr_aux].lcllgt
                                       ,a_cts03m00[arr_aux].dddcod
                                       ,a_cts03m00[arr_aux].lcltelnum
                                       ,a_cts03m00[arr_aux].lclcttnom
                                       ,a_cts03m00[arr_aux].c24lclpdrcod
                                       ,a_cts03m00[arr_aux].ofnnumdig
                                       ,a_cts03m00[arr_aux].emeviacod
                                       ,a_cts03m00[arr_aux].celteldddcod
                                       ,a_cts03m00[arr_aux].celtelnum
                                       ,a_cts03m00[arr_aux].endcmp)

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
   
   if d_cts03m00.frmflg <> "S"                  and
      (m_multiplo = 0 or m_multiplo is null)    and
      (m_premium  = false)                      then
       call cts06g03_inclui_hstidx(aux_atdsrvnum,
                                   aux_atdsrvano)
   end if
 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  w_cts03m00.atdetpcod is null  then
       if  d_cts03m00.atdlibflg = "S"  then
           let w_cts03m00.atdetpcod = 1
           let ws.etpfunmat = w_cts03m00.funmat
           let ws.atdetpdat = d_cts03m00.atdlibdat
           let ws.atdetphor = d_cts03m00.atdlibhor
       else
           let w_cts03m00.atdetpcod = 2
           let ws.etpfunmat = w_cts03m00.funmat
           let ws.atdetpdat = w_cts03m00.data
           let ws.atdetphor = w_cts03m00.hora
       end if
   else
      let w_retorno = cts10g04_insere_etapa( aux_atdsrvnum    ,
                                             aux_atdsrvano    ,
                                             1,
                                             " ",
                                             " ",
                                             " ",
                                             w_cts03m00.srrcoddig )

       if  w_retorno <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts03m00.cnldat
       let ws.atdetphor = w_cts03m00.atdfnlhor
       let ws.etpfunmat = w_cts03m00.c24opemat
   end if

   let w_retorno = cts10g04_insere_etapa( aux_atdsrvnum,
                                          aux_atdsrvano,
                                          w_cts03m00.atdetpcod,
                                          w_cts03m00.atdprscod,
                                          w_cts03m00.c24nomctt,
                                          w_cts03m00.socvclcod,
                                          w_cts03m00.srrcoddig )

   if w_retorno <>  0  then
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
   if  g_documento.aplnumdig is not null  and
       g_documento.aplnumdig <> 0         then
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
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
       if g_documento.cndslcflg = "S"  then
          select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                 into ws.cdtnom,ws.cgccpfnum,ws.cgccpfdig
                 from tmpcondutor
          let ws.cdtseq = grava_condutor(g_documento.succod,g_documento.aplnumdig,
                                         g_documento.itmnumdig,ws.cdtnom,ws.cgccpfnum,
                                         ws.cgccpfdig,"D","CENTRAL24H")
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
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
         end if
       end if
   else
       if g_documento.ramcod = 78   or   # transportes laudo em branco
          g_documento.ramcod = 171  or   # transportes laudo em branco
          g_documento.ramcod = 195  then # Garantia estendidad modalidade 0

          insert into DATRSERVAPOL ( atdsrvnum,
                                     atdsrvano,
                                     succod   ,
                                     ramcod   ,
                                     aplnumdig,
                                     itmnumdig,
                                     edsnumref  )
                            values ( aux_atdsrvnum     ,
                                     aux_atdsrvano     ,
                                     0                 ,
                                     g_documento.ramcod,
                                     0                 ,
                                     0                 ,
                                     0                  )

          if  sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na gravacao da",
                    " tabela datrservapol-ramo 78. AVISE A INFORMATICA!"
              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
          end if
       end if
   end if

   commit work
   # War Room
   #===============================================
   # Ponto de acesso apos a gravacao do laudo
   #===============================================
      call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                                  aux_atdsrvano)

   #-----------------------------------------------
   # Aciona Servico automaticamente
   #-----------------------------------------------
   let m_aciona = 'N'
 
   if cts34g00_acion_auto (g_documento.atdsrvorg,
                           a_cts03m00[1].cidnom,
                           a_cts03m00[1].ufdcod) then
      if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                          g_documento.c24astcod,
                                          d_cts03m00.asitipcod,
                                          a_cts03m00[1].lclltt,
                                          a_cts03m00[1].lcllgt,
                                          d_cts03m00.prslocflg,
                                          d_cts03m00.frmflg,
                                          aux_atdsrvnum,
                                          aux_atdsrvano,
                                          " ",
                                          d_cts03m00.vclcoddig,
                                          d_cts03m00.camflg) then
      else
         let m_aciona = 'S'
      end if
   end if
 
   #------------------------------------------------------------------------------
   # Grava HISTORICO do servico
   #------------------------------------------------------------------------------
   if w_hist.hist1 is not null then   # registra o motivo da escolha oficina
      let ws.histerr = cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                                           w_cts03m00.data  , w_cts03m00.hora,
                                           w_cts03m00.funmat, w_hist.* )
   end if
   let ws.histerr = cts10g02_historico( aux_atdsrvnum    ,
                                        aux_atdsrvano    ,
                                        w_cts03m00.data  ,
                                       #current          ,
                                        w_cts03m00.hora  ,
                                        w_cts03m00.funmat,
                                        hist_cts03m00.*   )

   let lr_ret.retorno = 1
   let lr_ret.mensagem = ' '
   let lr_ret.atdsrvnum = aux_atdsrvnum
   let lr_ret.atdsrvano = aux_atdsrvano
   exit while
   
  end while
  
  return lr_ret.*
  
end function

#--------------------------------------------------------------------------
function cts03m00_desbloqueia_servico(lr_param)
#--------------------------------------------------------------------------
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
      call cts03m00_prepare()
   end if
   whenever error continue
      execute pcts03m00010 using lr_param.atdsrvnum,
                                 lr_param.atdsrvano
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let lr_retorno.coderro = sqlca.sqlcode
         let lr_retorno.mens = "Erro <",lr_retorno.coderro ," > no desbloqueio do servico. AVISE A INFORMATICA!"
         call errorlog(lr_param.atdsrvnum)
         call errorlog(lr_retorno.mens)
         error lr_retorno.mens
      else
        let lr_retorno.coderro = sqlca.sqlcode
        let lr_retorno.mens = "Erro <",lr_retorno.coderro ,"no desbloqueio do servico. AVISE A INFORMATICA!"
        call errorlog(lr_retorno.mens)
        call errorlog(lr_param.atdsrvnum)
        error lr_retorno.mens
      end if
   else
      call cts00g07_apos_servdesbloqueia(lr_param.atdsrvnum,lr_param.atdsrvano)
   end if
end function

#--------------------------------------------------------#
 function cts03m00_bkp_info_dest(l_tipo, hist_cts03m00)
#--------------------------------------------------------#
  define hist_cts03m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts03m00_bkp      to null
     initialize m_hist_cts03m00_bkp to null

     let a_cts03m00_bkp[1].lclidttxt    = a_cts03m00[2].lclidttxt
     let a_cts03m00_bkp[1].cidnom       = a_cts03m00[2].cidnom
     let a_cts03m00_bkp[1].ufdcod       = a_cts03m00[2].ufdcod
     let a_cts03m00_bkp[1].brrnom       = a_cts03m00[2].brrnom
     let a_cts03m00_bkp[1].lclbrrnom    = a_cts03m00[2].lclbrrnom
     let a_cts03m00_bkp[1].endzon       = a_cts03m00[2].endzon
     let a_cts03m00_bkp[1].lgdtip       = a_cts03m00[2].lgdtip
     let a_cts03m00_bkp[1].lgdnom       = a_cts03m00[2].lgdnom
     let a_cts03m00_bkp[1].lgdnum       = a_cts03m00[2].lgdnum
     let a_cts03m00_bkp[1].lgdcep       = a_cts03m00[2].lgdcep
     let a_cts03m00_bkp[1].lgdcepcmp    = a_cts03m00[2].lgdcepcmp
     let a_cts03m00_bkp[1].lclltt       = a_cts03m00[2].lclltt
     let a_cts03m00_bkp[1].lcllgt       = a_cts03m00[2].lcllgt
     let a_cts03m00_bkp[1].lclrefptotxt = a_cts03m00[2].lclrefptotxt
     let a_cts03m00_bkp[1].lclcttnom    = a_cts03m00[2].lclcttnom
     let a_cts03m00_bkp[1].dddcod       = a_cts03m00[2].dddcod
     let a_cts03m00_bkp[1].lcltelnum    = a_cts03m00[2].lcltelnum
     let a_cts03m00_bkp[1].c24lclpdrcod = a_cts03m00[2].c24lclpdrcod
     let a_cts03m00_bkp[1].ofnnumdig    = a_cts03m00[2].ofnnumdig
     let a_cts03m00_bkp[1].celteldddcod = a_cts03m00[2].celteldddcod
     let a_cts03m00_bkp[1].celtelnum    = a_cts03m00[2].celtelnum
     let a_cts03m00_bkp[1].endcmp       = a_cts03m00[2].endcmp
     let m_hist_cts03m00_bkp.hist1      = hist_cts03m00.hist1
     let m_hist_cts03m00_bkp.hist2      = hist_cts03m00.hist2
     let m_hist_cts03m00_bkp.hist3      = hist_cts03m00.hist3
     let m_hist_cts03m00_bkp.hist4      = hist_cts03m00.hist4
     let m_hist_cts03m00_bkp.hist5      = hist_cts03m00.hist5
     let a_cts03m00_bkp[1].emeviacod    = a_cts03m00[2].emeviacod

     return hist_cts03m00.*

  else

     let a_cts03m00[2].lclidttxt    = a_cts03m00_bkp[1].lclidttxt
     let a_cts03m00[2].cidnom       = a_cts03m00_bkp[1].cidnom
     let a_cts03m00[2].ufdcod       = a_cts03m00_bkp[1].ufdcod
     let a_cts03m00[2].brrnom       = a_cts03m00_bkp[1].brrnom
     let a_cts03m00[2].lclbrrnom    = a_cts03m00_bkp[1].lclbrrnom
     let a_cts03m00[2].endzon       = a_cts03m00_bkp[1].endzon
     let a_cts03m00[2].lgdtip       = a_cts03m00_bkp[1].lgdtip
     let a_cts03m00[2].lgdnom       = a_cts03m00_bkp[1].lgdnom
     let a_cts03m00[2].lgdnum       = a_cts03m00_bkp[1].lgdnum
     let a_cts03m00[2].lgdcep       = a_cts03m00_bkp[1].lgdcep
     let a_cts03m00[2].lgdcepcmp    = a_cts03m00_bkp[1].lgdcepcmp
     let a_cts03m00[2].lclltt       = a_cts03m00_bkp[1].lclltt
     let a_cts03m00[2].lcllgt       = a_cts03m00_bkp[1].lcllgt
     let a_cts03m00[2].lclrefptotxt = a_cts03m00_bkp[1].lclrefptotxt
     let a_cts03m00[2].lclcttnom    = a_cts03m00_bkp[1].lclcttnom
     let a_cts03m00[2].dddcod       = a_cts03m00_bkp[1].dddcod
     let a_cts03m00[2].lcltelnum    = a_cts03m00_bkp[1].lcltelnum
     let a_cts03m00[2].c24lclpdrcod = a_cts03m00_bkp[1].c24lclpdrcod
     let a_cts03m00[2].ofnnumdig    = a_cts03m00_bkp[1].ofnnumdig
     let a_cts03m00[2].celteldddcod = a_cts03m00_bkp[1].celteldddcod
     let a_cts03m00[2].celtelnum    = a_cts03m00_bkp[1].celtelnum
     let a_cts03m00[2].endcmp       = a_cts03m00_bkp[1].endcmp
     let hist_cts03m00.hist1        = m_hist_cts03m00_bkp.hist1
     let hist_cts03m00.hist2        = m_hist_cts03m00_bkp.hist2
     let hist_cts03m00.hist3        = m_hist_cts03m00_bkp.hist3
     let hist_cts03m00.hist4        = m_hist_cts03m00_bkp.hist4
     let hist_cts03m00.hist5        = m_hist_cts03m00_bkp.hist5
     let a_cts03m00[2].emeviacod    = a_cts03m00_bkp[1].emeviacod

     return hist_cts03m00.*

  end if

end function

#-----------------------------------------#
 function cts03m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open c_cts03m00_006 using g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano

  whenever error continue
  fetch c_cts03m00_006 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT c_cts03m00_006: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts03m00() / C24 / cts03m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts03m00_verifica_op_ativa()
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
 function cts03m00_grava_historico()
#-----------------------------------------#
  define la_cts03m00       array[12] of record
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

  define l_ind             smallint
        ,l_data            date
        ,l_hora            datetime hour to minute
        ,l_dstqtd          decimal(8,4)
        ,l_status          smallint

  initialize la_cts03m00   to null
  initialize lr_de         to null
  initialize lr_para       to null
  initialize lr_ret        to null

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

  let la_cts03m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts03m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts03m00[03].descricao = "."
  let la_cts03m00[04].descricao = "DE:"
  let la_cts03m00[05].descricao = "CEP: ", a_cts03m00_bkp[1].lgdcep clipped," - ",a_cts03m00_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts03m00_bkp[1].cidnom clipped," UF: ",a_cts03m00_bkp[1].ufdcod clipped
  let la_cts03m00[06].descricao = "Logradouro: ",a_cts03m00_bkp[1].lgdtip clipped," ",a_cts03m00_bkp[1].lgdnom clipped," "
                                                ,a_cts03m00_bkp[1].lgdnum clipped," ",a_cts03m00_bkp[1].brrnom
  let la_cts03m00[07].descricao = "."
  let la_cts03m00[08].descricao = "PARA:"
  let la_cts03m00[09].descricao = "CEP: ", a_cts03m00[2].lgdcep clipped," - ", a_cts03m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts03m00[2].cidnom clipped," UF: ",a_cts03m00[2].ufdcod  clipped
  let la_cts03m00[10].descricao = "Logradouro: ",a_cts03m00[2].lgdtip clipped," ",a_cts03m00[2].lgdnom clipped," "
                                                ,a_cts03m00[2].lgdnum clipped," ",a_cts03m00[2].brrnom
  let la_cts03m00[11].descricao = "."
  let la_cts03m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts03m00[l_ind].descricao
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
  let lr_de.lgdcep    = a_cts03m00_bkp[1].lgdcep clipped,"-",a_cts03m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts03m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts03m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts03m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts03m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts03m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts03m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts03m00[2].lgdcep clipped,"-", a_cts03m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts03m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts03m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts03m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts03m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts03m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts03m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function
function cts03m00_limite_cls46(lr_param)
define lr_param record
       ramcod    like datrservapol.ramcod
      ,succod    like datrservapol.succod
      ,aplnumdig like datrservapol.aplnumdig
      ,itmnumdig like datrservapol.itmnumdig
      ,edsnumref like datrservapol.edsnumref
      ,asitipcod like datmservico.asitipcod
      ,c24astcod like datmligacao.c24astcod
end record
define lr_retorno record
       erro      smallint
      ,limite    char(1)
      ,msg       char(200)
end record
define l_qtde,
       l_asitipcod like datmservico.asitipcod,
       l_clscod like abbmclaus.clscod
let l_qtde = 0
let l_asitipcod = null
let l_clscod = null
let lr_retorno.limite = null
      call f_funapol_ultima_situacao
                 (g_documento.succod, g_documento.aplnumdig,
                  g_documento.itmnumdig)
                  returning g_funapol.*
            if g_funapol.dctnumseq is null  then
               select min(dctnumseq)
                 into g_funapol.dctnumseq
                 from abbmdoc
                where succod    = g_documento.succod
                  and aplnumdig = g_documento.aplnumdig
                  and itmnumdig = g_documento.itmnumdig
            end if
          open ccts03m00006 using g_documento.succod
                                 ,g_documento.aplnumdig
                                 ,g_documento.itmnumdig
                                 ,g_funapol.dctnumseq
          whenever error continue
          foreach ccts03m00006 into l_clscod
            if l_clscod = "034" or
               l_clscod = "071" or
               l_clscod = "077" then
              if cta13m00_verifica_clausula(g_documento.succod ,
                                            g_documento.aplnumdig,
                                            g_documento.itmnumdig,
                                            g_funapol.dctnumseq ,
                                            l_clscod) then
               continue foreach
              end if
            end if
          end foreach
          whenever error stop
     if (l_clscod = '46R' or
         l_clscod = '44R' or
         l_clscod = '48R') and
        (lr_param.asitipcod = 4  or
        lr_param.asitipcod = 50) then
        open  ccts03m00007 using g_documento.ramcod,
                                 g_documento.succod ,
                                 g_documento.aplnumdig,
                                 g_documento.itmnumdig
        fetch ccts03m00007 into l_qtde,l_asitipcod
            if l_qtde >= 3 then
               let lr_retorno.limite = true
            end if
     else
         if l_clscod = '46R' or
            l_clscod = '44R' or
            l_clscod = '48R' then
            open  ccts03m00008 using g_documento.ramcod,
                                     g_documento.succod ,
                                     g_documento.aplnumdig,
                                     g_documento.itmnumdig
          fetch ccts03m00008 into l_qtde
            if l_qtde >= 3 then
               let lr_retorno.limite = true
            end if
         else
             let lr_retorno.limite = false
         end if
     end if
   return lr_retorno.limite
end function
function cts03m00_limite_s85(lr_param)
define lr_param record
      c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
end record
define lr_retorno record
       erro      smallint
      ,limite    char(1)
      ,msg       char(200)
end record
define l_qtde,
       l_clscod like abbmclaus.clscod,
       l_limite smallint
let l_qtde = 0
let l_clscod = null
let lr_retorno.limite = null
let l_limite = 0
      call f_funapol_ultima_situacao
                 (g_documento.succod, g_documento.aplnumdig,
                  g_documento.itmnumdig)
                  returning g_funapol.*
            if g_funapol.dctnumseq is null  then
               select min(dctnumseq)
                 into g_funapol.dctnumseq
                 from abbmdoc
                where succod    = g_documento.succod
                  and aplnumdig = g_documento.aplnumdig
                  and itmnumdig = g_documento.itmnumdig
            end if
          open ccts03m00006 using g_documento.succod
                                 ,g_documento.aplnumdig
                                 ,g_documento.itmnumdig
                                 ,g_funapol.dctnumseq
          whenever error continue
          foreach ccts03m00006 into l_clscod
            if l_clscod = "034" or
               l_clscod = "071" or
               l_clscod = "077" then
              if cta13m00_verifica_clausula(g_documento.succod ,
                                            g_documento.aplnumdig,
                                            g_documento.itmnumdig,
                                            g_funapol.dctnumseq ,
                                            l_clscod) then
               continue foreach
              end if
            end if
          end foreach
          whenever error stop
     if lr_param.c24pbmgrpcod = 116 then
        open  ccts03m00009 using g_documento.ramcod,
                                 g_documento.succod ,
                                 g_documento.aplnumdig,
                                 g_documento.itmnumdig
        fetch ccts03m00009 into l_qtde
        call cta00m06_buscalimite(l_clscod,lr_param.c24pbmgrpcod)
             returning l_limite
            if l_qtde >= l_limite then
               let lr_retorno.limite = true
            end if
     else 
      if lr_param.c24pbmgrpcod = 131 then
       open  ccts03m00010 using g_documento.ramcod,
                                g_documento.succod ,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig
          fetch ccts03m00010 into l_qtde
          call cta00m06_buscalimite(l_clscod,lr_param.c24pbmgrpcod)
               returning l_limite
            if l_qtde >= l_limite then
               let lr_retorno.limite = true
            end if
         else
             let lr_retorno.limite = false
         end if
     end if
   return lr_retorno.limite
end function
