#############################################################################
# Nome do Modulo: CTS09M00                                            Pedro #
#                                                                   Marcelo #
# Laudo - Replace                                                  Mar/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta- #
#                                       bela DATMSERVICO.                   # 
#---------------------------------------------------------------------------#
# 20/10/1998  PSI 6955-8   Gilberto     Retirar aviso que informa sobre     #
#                                       informacoes complementares no       #
#                                       historico (funcao CTS11G00).        #
#---------------------------------------------------------------------------#
# 18/11/1998  PSI 6467-0   Gilberto     Gravar codigo do veiculo atendido.  #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Gravar dados referentes a digitacao #
#                                       via formulario.                     #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 17/12/1998  PSI 6478-5   Gilberto     Inclusao da chamada da funcao de    #
#                                       cabecalho (CTS05G02) para atendi-   #
#                                       mento Porto Card VISA.              #
#---------------------------------------------------------------------------#
# 23/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8533-2   Wagner       Incluir acesso ao modulo cts14g00   #
#                                       para mensagens Cidade e UF.         #
#---------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 14/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03#
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
# 01/02/2000  PSI 10203-2  Gilberto     Gravar atdvcltip = 3 para solicita- #
#                                       cao de guincho para caminhao.       #
#---------------------------------------------------------------------------#
# 08/02/2000  PSI 10206-7  Wagner       Manutencao nivel prioridade servico.#
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
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
# 29/11/2000               Raji         Inclusao do paramentro codigo da    #
#                                       oficina destino para laudos         #
#---------------------------------------------------------------------------#
# 01/03/2002  Correio      Wagner       Incluir dptsgl psocor na pesquisa.  #
#---------------------------------------------------------------------------#
# 26/07/2002  PSI 15758-9  Ruiz         eliminar a confirmacao de servico   #
#                                       liberado(cts02m06).                 #
#---------------------------------------------------------------------------#
# 10/10/2002  PSI 16258-2  Wagner       Incluir acesso a funcao informativo #
#                                       convenio ctx17g00.                  #
#---------------------------------------------------------------------------#
# 22/01/2003 PSI 167916    Ruiz         Fabrica de Software, Teresinha Silva#
#                                       Inclusao da pop_up de congeneres    #
#                                       PSI: 167916 - OSF 12351             #
#---------------------------------------------------------------------------#
# 03/06/2003 PSI 170275    Ruiz         Fabrica de Software, Helio          #
#            OSF 19968                  Busca o campo asiofndigflg          #
# ------------------------------------------------------------------------- #
#                                                                           #
#                      * * * Alteracoes * * *                               #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 18/09/2003  Meta,Gustavo   PSI175552 Inibir a chamada da funcao           #
#                            OSF026077 ctx17g00_assist.                     #
# ------------------------------------------------------------------------- #
# 17/11/2003  Meta,Paulo     PSI179345 Testar o atributo grlinf para abrir  #
#                            OSF28851  ou nao a janela de acionamento do    #
#                                      servico                              #
#---------------------------------------------------------------------------#
# 19/05/2005 Robson,Meta     PSI191108  Implementacao do Codigo da Via      #
#                                       (emeviacod).                        #
#---------------------------------------------------------------------------#
# 02/08/2005  Helio (Meta)  PSI 192015 Alteracoes diversas.                 #
#---------------------------------------------------------------------------#
# 24/08/2005  James, Meta    PSI192015 Inibir a chamada das funcoes ctc61m02#
#---------------------------------------------------------------------------#
# 24/04/2006  Priscila       PSI198714 Acionar servico automaticamente      #
#---------------------------------------------------------------------------#
# 04/05/2006  Priscila       PSI198714 Gerar laudo de apoio quando local/   #
#                                      cond veiculo e subsolo ou chave cod  #
#---------------------------------------------------------------------------#
# 17/05/2006  Priscila       PSI198714 Inclusao da opcao F4 para visualizar #
#                                      laudo de apoio                       #
# 11/12/2006  Ligia Mattge   CT6121350 Chamada do cts40g12 apos os updates  #
# 28/12/2006  Ligia Mattge             Implementacao de m_c24lclpdrcod e    #
#                                      chamada de cts02m00_valida_indexacao #
#---------------------------------------------------------------------------#
# 14/02/2007  Saulo,Meta     AS130087  Migracao para a versao 7.32          #
#---------------------------------------------------------------------------#
# 07/07/2008 Andre Oliveira 		  AlteraþÒo da chamada da funþÒo    #
#  		   	    		  cts00m02_regulador para	    #
#					  ctc59m03_regulador		    #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
# 13/08/2009 Sergio Burini     PSI 244236 Inclusão do Sub-Dairro            #
#---------------------------------------------------------------------------#
# 05/04/2012 Ivan, BRQ  PSI-2011-22603 Projeto alteracao cadastro de destino#
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
# 28/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#---------------------------------------------------------------------------#
# 10/12/2013  Rodolfo   PSI-2013-      Inlcusao da nova regulacao via AW    #
#             Massini   12097PR                                             #
#---------------------------------------------------------------------------#
# 11/08/2014 Fabio, Fornax PSI2013-00440 Adequacoes para regulacao AW       #
#---------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

 define d_cts09m00    record
    servico           char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (27)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cvnnom            char (19)                    ,
    vclcoddig         like datmservico.vclcoddig   ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcordes         char (11)                    ,
    c24astcod         like datkassunto.c24astcod   ,
    c24astdes         like datkassunto.c24astdes   ,
    desapoio          char (17)                    ,
    camflg            char (01)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    dstflg            char (01)                    ,
    imdsrvflg         char (01)                    ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    frmflg            char (01)                    ,
    atdtxt            char (48)                    ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor
 end record

 define w_cts09m00    record
    lignum            like datrligsrv.lignum       ,
    c24astcod         like datmligacao.c24astcod   ,
    c24astdes         like datkassunto.c24astdes   ,
    vcllibflg         like datmservicocmp.vcllibflg,
    vclcorcod         like datmservico.vclcorcod   ,
    vclcordes         char (11)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    ultlignum         char (10)                    ,
    vclcamtip         like datmservicocmp.vclcamtip,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgflg         like datmservicocmp.vclcrgflg,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    atdlibflg         like datmservico.atdlibflg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atdfnlflg         like datmservico.atdfnlflg   ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    ligcvntip         like datmligacao.ligcvntip   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24opemat         like datmservico.c24opemat   ,
    atdprscod         like datmservico.atdprscod   ,
    data              like datmservico.atddat      ,
    hora              like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    ctgtrfcod         like abbmcasco.ctgtrfcod     ,
    atdvcltip         like datmservico.atdvcltip   ,
    asiofndigflg      like datkasitip.asiofndigflg ,  #OSF 19968
    vclcndlclflg      like datkasitip.vclcndlclflg ,
    atdrsdflg         like datmservico.atdrsdflg,
    socvclcod					like datkveiculo.socvclcod
 end record
 define w_hist record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
     hist5             like datmservhist.c24srvdsc
 end record

 define a_cts09m00    array[3] of record
    operacao          char (01)                    ,
    lclidttxt         char (40)                    ,
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
    ofnnumdig         like sgokofi.ofnnumdig       ,
    emeviacod         like datmlcl.emeviacod       ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.lcltelnum       ,
    endcmp            like datmlcl.endcmp
 end record
 define a_cts09m00_bkp   array[3] of record
    operacao          char (01)                    ,
    lclidttxt         char (40)                    ,
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
    ofnnumdig         like sgokofi.ofnnumdig       ,
    emeviacod         like datmlcl.emeviacod       ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.lcltelnum       ,
    endcmp            like datmlcl.endcmp
 end record
 
 define m_hist_cts09m00_bkp      record
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

 define w_retorno     smallint
 define arr_aux       smallint
 define l_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint,
        m_grava_hist  smallint

 # - Fabrica de Software, Teresinha Silva OSF 12351 - #
 # - Data: 22/01/2003                               - #

 define m_sgdirbcod   like datmservicocmp.sgdirbcod
 define m_sgdnom      like gcckcong.sgdnom
 define m_atdsrvorg   like datmservico.atdsrvorg

 define aux_libant    like datmservico.atdlibflg,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano,
        aux_libhor    char (05)                 ,
        aux_today     char (10)                 ,
        aux_hora      char (05)                 ,
        aux_ano       char (02)

 define m_prep_sql    smallint ### PSI179345

 define m_aciona     char(01)    #PSI198714
 define m_outrolaudo smallint    #PSI198714
 define m_srv_acionado smallint    #PSI198714
 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

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
      
 ###
 ### Inicio PSI179345 - Paulo
 ###
 #--------------------------#
 function cts09m00_prepare()
 #--------------------------#

 define l_sql    char(500)

 ### Inicio
 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts09m00_001 from l_sql
 declare c_cts09m00_001 cursor for p_cts09m00_001
 ### Fim

 #PSI 198714 - buscar locais condicao veiculo do servico
 let l_sql = "select vclcndlclcod "
            ," from datrcndlclsrv "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
 prepare p_cts09m00_002 from l_sql
 declare c_cts09m00_002 cursor with hold for p_cts09m00_002

 let l_sql =  "select atdetpcod                          "
             ,"  from datmsrvacp                         "
             ," where atdsrvnum = ?                      "
             ,"   and atdsrvano = ?                      "
             ,"   and atdsrvseq = (select max(atdsrvseq) "
             ,"                      from datmsrvacp     "
             ,"                     where atdsrvnum = ?  "
             ,"                       and atdsrvano = ?) "

 prepare p_cts09m00_004 from l_sql
 declare c_cts09m00_004 cursor for p_cts09m00_004
 
 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAWATIVA' "
 prepare p_cts09m00_005 from l_sql
 declare c_cts09m00_005 cursor for p_cts09m00_005

 let m_prep_sql = true

 end function
 ###
 ### Final PSI179345 - Paulo
 ###

#--------------------------------------------------------------------
 function cts09m00()
#--------------------------------------------------------------------

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod,
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    confirma          char (01),
    grvflg            smallint,
    imsvlr            like abbmcasco.imsvlr
 end record

 define l_grlinf	      like igbkgeral.grlinf

 define l_data          date,
        l_hora2         datetime hour to minute

 define l_erro          smallint
 define l_acesso        smallint

 initialize  ws.*  to  null

 initialize m_rsrchv     
          , m_altcidufd  
          , m_altdathor
          , m_operacao
          , m_agncotdat 
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant to null
          
  let g_documento.atdsrvorg = 7
#--------------------------------#

 let m_outrolaudo = 0
 let m_srv_acionado = false
 let m_c24lclpdrcod = null
 initialize m_subbairro to null

 initialize f4.* to null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2

 let m_sgdirbcod   = null
 let m_sgdnom      = null
 let int_flag      = false
 let aux_today     = l_data
 let aux_hora      = l_hora2
 let aux_ano       = aux_today[9,10]

 initialize d_cts09m00.*  to null
 initialize w_cts09m00.*  to null
 initialize ws.*          to null
 initialize aux_libant    to null

 initialize a_cts09m00          to null
 initialize a_cts09m00_bkp      to null
 initialize m_hist_cts09m00_bkp to null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts09m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false
 
 whenever error continue
 open c_cts09m00_005
 fetch c_cts09m00_005 into m_agendaw
 
 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 
 open window cts09m00 at 04,02 with form "cts09m00"
                      attribute(form line 1)

 if g_documento.atdsrvnum is null then
    display "(F1)Help,(F3)Refer,(F5)Espelho,(F6)Hist,(F7)Funcoes,(F8)Destino,(F9)Conclui" to msgfun
 else
    display "(F1)Help(F3)Refer(F4)Apoio(F5)Espelho(F6)Hist(F7)Funcoes(F8)Dest(F9)Conclui" to msgfun
 end if

 let w_cts09m00.ligcvntip  =  g_documento.ligcvntip

 select cpodes
   into d_cts09m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts09m00.ligcvntip

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts09m00()

    call cts09m00_display()

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
          call cts08g01 ("A","N","",
                         "  VEICULO BLINDADO  ",
                         "","") returning ws.confirma
       end if
    end if
    display by name a_cts09m00[1].lclidttxt,
                    a_cts09m00[1].lgdtxt,
                    a_cts09m00[1].lclbrrnom,
                    a_cts09m00[1].cidnom,
                    a_cts09m00[1].ufdcod,
                    a_cts09m00[1].lclrefptotxt,
                    a_cts09m00[1].endzon,
                    a_cts09m00[1].dddcod,
                    a_cts09m00[1].lcltelnum,
                    a_cts09m00[1].lclcttnom,
                    a_cts09m00[1].celteldddcod,
                    a_cts09m00[1].celtelnum,
                    a_cts09m00[1].endcmp

    if d_cts09m00.atdlibflg = "N"   then
       display by name d_cts09m00.atdlibdat attribute (invisible)
       display by name d_cts09m00.atdlibhor attribute (invisible)
    end if

    if w_cts09m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    end if

    call modifica_cts09m00() returning ws.grvflg

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
    if g_documento.succod    is not null and
       g_documento.ramcod    is not null and
       g_documento.aplnumdig is not null then
       let d_cts09m00.doctxt = "Apolice.: ", g_documento.succod  using "&&",
                                        " ", g_documento.ramcod  using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"

       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)
            returning d_cts09m00.nom      ,
                      d_cts09m00.corsus   ,
                      d_cts09m00.cornom   ,
                      d_cts09m00.cvnnom   ,
                      d_cts09m00.vclcoddig,
                      d_cts09m00.vcldes   ,
                      d_cts09m00.vclanomdl,
                      d_cts09m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts09m00.vclcordes

       call cts02m01_caminhao(g_documento.succod   ,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig,
                              g_funapol.autsitatu)
            returning d_cts09m00.camflg, w_cts09m00.ctgtrfcod
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

       call figrc072_setTratarIsolamento()        --> 223689

       call cts05g04 (g_documento.prporg   ,
                      g_documento.prpnumdig)
            returning d_cts09m00.nom      ,
                      d_cts09m00.corsus   ,
                      d_cts09m00.cornom   ,
                      d_cts09m00.cvnnom   ,
                      d_cts09m00.vclcoddig,
                      d_cts09m00.vcldes   ,
                      d_cts09m00.vclanomdl,
                      d_cts09m00.vcllicnum,
                      d_cts09m00.vclcordes

       if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Função cts05g04  indisponivel no momento! Avise a Informatica !" sleep 2
            let int_flag = false
            clear form
            close window cts09m00
            return
       end if    --> 223689



       let d_cts09m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                  " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts09m00.doctxt = "Cartao..: ", g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts09m00.nom      ,
                      d_cts09m00.corsus   ,
                      d_cts09m00.cornom   ,
                      d_cts09m00.cvnnom   ,
                      d_cts09m00.vclcoddig,
                      d_cts09m00.vcldes   ,
                      d_cts09m00.vclanomdl,
                      d_cts09m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts09m00.vclcordes
    end if

    let d_cts09m00.c24astcod   = g_documento.c24astcod
    let d_cts09m00.c24solnom   = g_documento.solnom

    call c24geral8(d_cts09m00.c24astcod) returning d_cts09m00.c24astdes

    # - Fabrica de Software - Teresinha Silva - #
    # - OSF 12351 - Data: 22/01/3003          - #
    while true
        call cts09m00a()
            returning m_sgdnom,m_sgdirbcod
        if m_sgdirbcod is null then
           error "E necessario selecionar uma Congenere"
        else
           if g_documento.aplnumdig is null then # laudo em branco
              let d_cts09m00.cvnnom     = m_sgdnom
              if m_sgdirbcod <> 5886 then
                 let g_documento.atdsrvorg = 17
              end if
           else
              if m_sgdirbcod  <> 5886 then
                 let d_cts09m00.cvnnom     = m_sgdnom
                 let g_documento.atdsrvorg = 17
              else
                 let m_sgdirbcod = null
              end if
             #if g_documento.ligcvntip <> 0 then  #convenio apolice dif. porto
             #   if m_sgdirbcod        <> 5886 then # congenere porto
             #      let d_cts09m00.cvnnom     = m_sgdnom
             #      let g_documento.atdsrvorg = 17
             #   else
             #      let m_sgdirbcod = null
             #   end if
             #else
             #   if m_sgdirbcod        <> 5886 then
             #      let d_cts09m00.cvnnom     = m_sgdnom
             #      let g_documento.atdsrvorg = 17
             #   else
             #      let m_sgdirbcod = null
             #   end if
             #end if
           end if
           exit while
        end if
    end while

    call cts09m00_display()

    ###
    ### Inicio PSI179345 - Paulo
    ###

    open c_cts09m00_001

    whenever error continue
    fetch c_cts09m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts09m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts09m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window cts09m00
          return
       end if
    end if
    ###
    ### Final PSI179345 - Paulo
    ###

    call inclui_cts09m00() returning ws.grvflg

    if ws.grvflg = true  then
       call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts09m00.funmat,
                     w_cts09m00.data      , w_cts09m00.hora)


       ### PSI175552 / OSF26077
       ####-----------------------------------------------
       #### Envia msg convenio/assunto se houver
       ####-----------------------------------------------
       ###call ctx17g00_assist(g_documento.ligcvntip,
       ###                     g_documento.c24astcod,
       ###                     aux_atdsrvnum        ,
       ###                     aux_atdsrvano        ,
       ###                     g_documento.lignum   ,
       ###                     g_documento.succod   ,
       ###                     g_documento.ramcod   ,
       ###                     g_documento.aplnumdig,
       ###                     g_documento.itmnumdig,
       ###                     g_documento.prporg   ,
       ###                     g_documento.prpnumdig,
       ###                     "",""                )


       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if d_cts09m00.imdsrvflg =  "S"     and        # servico imediato
          d_cts09m00.atdlibflg =  "S"     and        # servico liberado
          d_cts09m00.frmflg    =  "N"     and        # formulario
          m_aciona =  "N"                 then       # servico nao acionado auto
                                                     #PSI198714
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso

          if l_acesso = true then
             call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                  returning ws.confirma

             if ws.confirma  =  "S"   then
                call cts00m02(aux_atdsrvnum, aux_atdsrvano, 1 )
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
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(aux_atdsrvnum,aux_atdsrvano)
          end if
       end if
    end if
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

 close window cts09m00

end function  ###  cts09m00

#--------------------------------------------------------------------
 function consulta_cts09m00()
#--------------------------------------------------------------------

 define ws            record
    vclcorcod         like datmservico.vclcorcod,
    funmat            like datmservico.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
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

 define  l_sgdirbcod  like datmservicocmp.sgdirbcod
 define  l_sgdnom     like gcckcong.sgdnom
 
 define l_tipolaudo   smallint      #PSI198714
       ,l_errcod   smallint
       ,l_errmsg   char(80)

	let	l_sgdirbcod  =  null
	let	l_sgdnom  =  null

	initialize  ws.*  to  null

 let l_sgdirbcod  = null
 let l_sgdnom     = null

 initialize ws.*  to null
 let m_atdsrvorg = null
 initialize l_errcod, l_errmsg to null
 
 select nom      ,
        atdsrvorg,       # OSF 12351
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
        asitipcod,
        atdfnlflg,
        atdvcltip,
        atdprinvlcod,
        ciaempcod,
        empcod                                                        #Raul, Biz
   into d_cts09m00.nom      ,
        m_atdsrvorg         ,   # OSF 12351
        d_cts09m00.vclcoddig,
        d_cts09m00.vcldes   ,
        d_cts09m00.vclanomdl,
        d_cts09m00.vcllicnum,
        d_cts09m00.corsus   ,
        d_cts09m00.cornom   ,
        ws.vclcorcod        ,
        ws.funmat           ,
        w_cts09m00.atddat   ,
        w_cts09m00.atdhor   ,
        d_cts09m00.atdlibflg,
        d_cts09m00.atdlibhor,
        d_cts09m00.atdlibdat,
        w_cts09m00.atdhorpvt,
        w_cts09m00.atdpvtretflg,
        w_cts09m00.atddatprg,
        w_cts09m00.atdhorprg,
        d_cts09m00.asitipcod,
        w_cts09m00.atdfnlflg,
        w_cts09m00.atdvcltip,
        d_cts09m00.atdprinvlcod,
        g_documento.ciaempcod,
        ws.empcod                                                     #Raul, Biz
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 let g_documento.atdsrvorg = m_atdsrvorg   # OSF 12351

 if sqlca.sqlcode = notfound then
    error "Servico nao encontrado. AVISE A INFORMATICA!"
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
               returning a_cts09m00[1].lclidttxt   ,
                         a_cts09m00[1].lgdtip      ,
                         a_cts09m00[1].lgdnom      ,
                         a_cts09m00[1].lgdnum      ,
                         a_cts09m00[1].lclbrrnom   ,
                         a_cts09m00[1].brrnom      ,
                         a_cts09m00[1].cidnom      ,
                         a_cts09m00[1].ufdcod      ,
                         a_cts09m00[1].lclrefptotxt,
                         a_cts09m00[1].endzon      ,
                         a_cts09m00[1].lgdcep      ,
                         a_cts09m00[1].lgdcepcmp   ,
                         a_cts09m00[1].lclltt      ,
                         a_cts09m00[1].lcllgt      ,
                         a_cts09m00[1].dddcod      ,
                         a_cts09m00[1].lcltelnum   ,
                         a_cts09m00[1].lclcttnom   ,
                         a_cts09m00[1].c24lclpdrcod,
                         a_cts09m00[1].celteldddcod,
                         a_cts09m00[1].celtelnum   ,
                         a_cts09m00[1].endcmp      ,
                         ws.codigosql              ,
                         a_cts09m00[1].emeviacod

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts09m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts09m00[1].brrnom,
                                a_cts09m00[1].lclbrrnom)
      returning a_cts09m00[1].lclbrrnom

 select ofnnumdig into a_cts09m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if


 let a_cts09m00[1].lgdtxt = a_cts09m00[1].lgdtip clipped, " ",
                            a_cts09m00[1].lgdnom clipped, " ",
                            a_cts09m00[1].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         2)
               returning a_cts09m00[2].lclidttxt   ,
                         a_cts09m00[2].lgdtip      ,
                         a_cts09m00[2].lgdnom      ,
                         a_cts09m00[2].lgdnum      ,
                         a_cts09m00[2].lclbrrnom   ,
                         a_cts09m00[2].brrnom      ,
                         a_cts09m00[2].cidnom      ,
                         a_cts09m00[2].ufdcod      ,
                         a_cts09m00[2].lclrefptotxt,
                         a_cts09m00[2].endzon      ,
                         a_cts09m00[2].lgdcep      ,
                         a_cts09m00[2].lgdcepcmp   ,
                         a_cts09m00[2].lclltt      ,
                         a_cts09m00[2].lcllgt      ,
                         a_cts09m00[2].dddcod      ,
                         a_cts09m00[2].lcltelnum   ,
                         a_cts09m00[2].lclcttnom   ,
                         a_cts09m00[2].c24lclpdrcod,
                         a_cts09m00[2].celteldddcod,
                         a_cts09m00[2].celtelnum   ,
                         a_cts09m00[2].endcmp      ,
                         ws.codigosql              ,
                         a_cts09m00[2].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[2].lclbrrnom = a_cts09m00[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts09m00[2].brrnom,
                                a_cts09m00[2].lclbrrnom)
      returning a_cts09m00[2].lclbrrnom

 select ofnnumdig into a_cts09m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 2

 if ws.codigosql = notfound   then
    let d_cts09m00.dstflg = "N"
 else
    if ws.codigosql = 0   then
       let d_cts09m00.dstflg = "S"
    else
       error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

 let a_cts09m00[2].lgdtxt = a_cts09m00[2].lgdtip clipped, " ",
                            a_cts09m00[2].lgdnom clipped, " ",
                            a_cts09m00[2].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Dados complementares do servico
#--------------------------------------------------------------------
 select roddantxt,
        sgdirbcod,             # OSF 12351
        vclcamtip,
        vclcrcdsc,
        vclcrgflg,
        vclcrgpso
   into w_cts09m00.roddantxt,
        l_sgdirbcod         ,  # OSF 12351
        w_cts09m00.vclcamtip,
        w_cts09m00.vclcrcdsc,
        w_cts09m00.vclcrgflg,
        w_cts09m00.vclcrgpso
   from datmservicocmp
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 let w_cts09m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts09m00.lignum)
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
    let d_cts09m00.doctxt = "Apolice.: ", g_documento.succod  using "&&",
                                     " ", g_documento.ramcod  using "&&&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then

    let d_cts09m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 select c24astcod,
        ligcvntip,
        c24solnom
   into w_cts09m00.c24astcod,
        w_cts09m00.ligcvntip,
        d_cts09m00.c24solnom
   from datmligacao
  where lignum = w_cts09m00.lignum

 let g_documento.c24astcod = w_cts09m00.c24astcod

 select lignum
   from datmligfrm
  where lignum = w_cts09m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts09m00.frmflg = "N"
 else
    let d_cts09m00.frmflg = "S"
 end if

 select cpodes
   into d_cts09m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip" and
        cpocod = w_cts09m00.ligcvntip

 # - Fabrica de Software - Teresinha Silva - #
 # - OSF 12351 - Data: 22/01/3003          - #
 if l_sgdirbcod is not null then
    select sgdnom
      into l_sgdnom
      from gcckcong
     where sgdirbcod = l_sgdirbcod
        if sqlca.sqlcode < 0 then
           error 'Erro -',  sqlca.sqlcode, 'ao acessar a tabela GCCKCONG '
        else
           let d_cts09m00.cvnnom = l_sgdnom[1,19]
        end if
 end if
 # - Fim manutencao  OSF 12351             - #

 call c24geral8(w_cts09m00.c24astcod) returning w_cts09m00.c24astdes

 let d_cts09m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 let d_cts09m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into d_cts09m00.asitipabvdes
   from datkasitip
  where asitipcod = d_cts09m00.asitipcod

 select cpodes
   into d_cts09m00.vclcordes
   from iddkdominio
  where cponom  =  "vclcorcod"  and
        cpocod  =  ws.vclcorcod

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 let d_cts09m00.atdtxt = w_cts09m00.atddat        clipped, " ",
                         w_cts09m00.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)

 if w_cts09m00.atdhorpvt is not null  or
    w_cts09m00.atdhorpvt =  "00:00"   then
    let d_cts09m00.imdsrvflg = "S"
 end if

 if w_cts09m00.atddatprg is not null  then
    let d_cts09m00.imdsrvflg = "N"
 end if

 if w_cts09m00.vclcamtip is not null  and
    w_cts09m00.vclcamtip <>  " "      then
    let d_cts09m00.camflg = "S"
 else
    if w_cts09m00.vclcrgflg is not null  and
       w_cts09m00.vclcrgflg <>  " "      then
       let d_cts09m00.camflg = "S"
    else
       let d_cts09m00.camflg = "N"
    end if
 end if

 let aux_libant = d_cts09m00.atdlibflg

 if d_cts09m00.atdlibflg  =  "N" then
    let d_cts09m00.atdlibdat = w_cts09m00.atddat
    let d_cts09m00.atdlibhor = w_cts09m00.atdhor
 end if

 let d_cts09m00.c24astcod    = w_cts09m00.c24astcod
 let d_cts09m00.c24astdes    = w_cts09m00.c24astdes
 let d_cts09m00.roddantxt    = w_cts09m00.roddantxt

 select cpodes
   into d_cts09m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts09m00.atdprinvlcod

  #verificar se é ou se tem laudo de apoio
  call cts37g00_existeServicoApoio(g_documento.atdsrvnum, g_documento.atdsrvano)
       returning l_tipolaudo
  if l_tipolaudo <> 1 then
     if l_tipolaudo = 2 then
        let d_cts09m00.desapoio = "SERVICO TEM APOIO"
     else
        if l_tipolaudo = 3 then
           let d_cts09m00.desapoio = "SERVICO DE APOIO"
        end if
     end if
     display by name d_cts09m00.desapoio attribute (reverse)
  end if

  let m_c24lclpdrcod = a_cts09m00[1].c24lclpdrcod

end function  ###  consulta_cts09m00

#--------------------------------------------------------------------
 function modifica_cts09m00()
#--------------------------------------------------------------------

 define hist_cts09m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    sqlcode          integer
 end record

 define prompt_key   char (01)

 define lr_cts10g02  record
        tabname      char(20),
        errcod       smallint
 end record

 define l_data   date,
        l_hora2  datetime hour to minute
       ,l_errcod   smallint
       ,l_errmsg   char(80)
       
 initialize l_errcod, l_errmsg  to null
 
	let	prompt_key  =  null

	initialize  hist_cts09m00.*  to  null

	initialize  ws.*  to  null

 initialize ws.*  to null

 call input_cts09m00() returning hist_cts09m00.*

 if m_srv_acionado = true then
    return true
 end if

 if g_documento.acao = "CON" then
    return false
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts09m00    to null
    initialize d_cts09m00.*  to null
    initialize w_cts09m00.*  to null
    clear form
    return false
 end if

#--------------------------------------------------------------------
# Verifica solicitacao de guincho para caminhao
#--------------------------------------------------------------------
 if d_cts09m00.asitipcod = 1  or       ###  Guincho
    d_cts09m00.asitipcod = 3  then     ###  Guincho/Tecnico
    if d_cts09m00.camflg = "S"  then
       let w_cts09m00.atdvcltip = 3
    end if
 end if

 #display 'cts09m00 - Modificar atendimento'
 
 whenever error continue

 begin work

 update datmservico set  (nom      ,
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
                          atdpvtretflg,
                          atddatprg,
                          atdhorprg,
                          asitipcod,
                          atdvcltip,
                          atdprinvlcod)
                      =  (d_cts09m00.nom,
                          d_cts09m00.corsus,
                          d_cts09m00.cornom,
                          d_cts09m00.vclcoddig,
                          d_cts09m00.vcldes,
                          d_cts09m00.vclanomdl,
                          d_cts09m00.vcllicnum,
                          w_cts09m00.vclcorcod,
                          d_cts09m00.atdlibflg,
                          d_cts09m00.atdlibhor,
                          d_cts09m00.atdlibdat,
                          w_cts09m00.atdhorpvt,
                          w_cts09m00.atdpvtretflg,
                          w_cts09m00.atddatprg,
                          w_cts09m00.atdhorprg,
                          d_cts09m00.asitipcod,
                          w_cts09m00.atdvcltip,
                          d_cts09m00.atdprinvlcod)
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

 update datmservicocmp set (vclcamtip,
                            vclcrcdsc,
                            vclcrgflg,
                            vclcrgpso,
                            roddantxt)
                        =  (w_cts09m00.vclcamtip,
                            w_cts09m00.vclcrcdsc,
                            w_cts09m00.vclcrgflg,
                            w_cts09m00.vclcrgpso,
                            d_cts09m00.roddantxt)
                      where atdsrvnum = g_documento.atdsrvnum and
                            atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0 then
   error " Erro (", sqlca.sqlcode, ") na alteracao dos dados complementares do servico. AVISE A INFORMATICA!"
   rollback work
   prompt "" for char prompt_key
   return false
 end if

 for arr_aux = 1 to 2
    if a_cts09m00[arr_aux].operacao is null  then
       let a_cts09m00[arr_aux].operacao = "M"
    end if

    let a_cts09m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    let ws.sqlcode = cts06g07_local(a_cts09m00[arr_aux].operacao,
                                    g_documento.atdsrvnum,
                                    g_documento.atdsrvano,
                                    arr_aux,
                                    a_cts09m00[arr_aux].lclidttxt,
                                    a_cts09m00[arr_aux].lgdtip,
                                    a_cts09m00[arr_aux].lgdnom,
                                    a_cts09m00[arr_aux].lgdnum,
                                    a_cts09m00[arr_aux].lclbrrnom,
                                    a_cts09m00[arr_aux].brrnom,
                                    a_cts09m00[arr_aux].cidnom,
                                    a_cts09m00[arr_aux].ufdcod,
                                    a_cts09m00[arr_aux].lclrefptotxt,
                                    a_cts09m00[arr_aux].endzon,
                                    a_cts09m00[arr_aux].lgdcep,
                                    a_cts09m00[arr_aux].lgdcepcmp,
                                    a_cts09m00[arr_aux].lclltt,
                                    a_cts09m00[arr_aux].lcllgt,
                                    a_cts09m00[arr_aux].dddcod,
                                    a_cts09m00[arr_aux].lcltelnum,
                                    a_cts09m00[arr_aux].lclcttnom,
                                    a_cts09m00[arr_aux].c24lclpdrcod,
                                    a_cts09m00[arr_aux].ofnnumdig,
                                    a_cts09m00[arr_aux].emeviacod,
                                    a_cts09m00[arr_aux].celteldddcod,
                                    a_cts09m00[arr_aux].celtelnum,
                                    a_cts09m00[arr_aux].endcmp)

    if ws.sqlcode is null   or
       ws.sqlcode <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.sqlcode, ") na alteracao do local de ocorrencia. AVISE A INFORMATICA!"
       else
          error " Erro (", ws.sqlcode, ") na alteracao do local de destino. AVISE A INFORMATICA!"
       end if
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if aux_libant <> d_cts09m00.atdlibflg  then
    if d_cts09m00.atdlibflg = "S"  then
       let w_cts09m00.atdetpcod = 1
       let ws.atdetpdat = d_cts09m00.atdlibdat
       let ws.atdetphor = d_cts09m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let w_cts09m00.atdetpcod = 2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts09m00.atdetpcod,
                               " ",
                               " ",
                               " ",
                               " ")returning w_retorno

    if w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento. AVISE A INFORMATICA!"
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
    call cts09m00_grava_historico()
 end if

 whenever error stop

 #-----------------------------------------------
 # Aciona Servico automaticamente
 #-----------------------------------------------
 #PSI198714 - Acionar servico automaticamente
 #chamar funcao que verifica se acionamento pode ser feito
 # verifica se servico para cidade e internet ou GPS e se esta ativo
 #retorna true para acionamento e false para nao acionamento
 let m_aciona = 'N'

 #Alteracao projeto cadastro de destino
 if w_cts09m00.atdfnlflg <> "S"  then

    if cts34g00_acion_auto (g_documento.atdsrvorg,
                            a_cts09m00[1].cidnom,
                            a_cts09m00[1].ufdcod) then
         #funcao cts34g00_acion_auto verificou que parametrizacao para origem
         # do servico esta OK
         #chamar funcao para validar regras gerais se um servico sera acionado
         # automaticamente ou nao e atualizar datmservico
         if not cts40g12_regras_aciona_auto (
                              g_documento.atdsrvorg,
                              g_documento.c24astcod,
                              d_cts09m00.asitipcod,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              "",
                              d_cts09m00.frmflg,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              "",
                              d_cts09m00.vclcoddig,
                              d_cts09m00.camflg) then
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
 ###                               a_cts09m00[1].c24lclpdrcod)

 return true

end function  ###  modifica_cts09m00()


#-------------------------------------------------------------------------------
 function inclui_cts09m00()
#-------------------------------------------------------------------------------

 define hist_cts09m00   record
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
        msg             char(80)                ,

        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint
 end record

 define l_data     date,
        l_hora2    datetime hour to minute

 define l_vclcndlclcod   like datrcndlclsrv.vclcndlclcod,
        l_txtsrv         char (15),
        l_reserva_ativa  smallint # Flag para idenitficar se reserva esta ativa
       ,l_errcod        smallint
       ,l_errmsg        char(80)
       
 initialize l_errcod, l_errmsg to null
 
	initialize  hist_cts09m00.*  to  null

	initialize  ws.*  to  null
   let l_txtsrv = null
  
 initialize l_reserva_ativa to null
 
 #display 'cts09m00 - Incluir atendimento'
 
 while true
   initialize ws.*  to null

   let g_documento.acao = "INC"

   call input_cts09m00() returning hist_cts09m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize d_cts09m00.*   to null
       initialize w_cts09m00.*   to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts09m00.data is null  then
       let w_cts09m00.data   = aux_today
       let w_cts09m00.hora   = aux_hora
       let w_cts09m00.funmat = g_issk.funmat
   end if

   if  d_cts09m00.frmflg = "S"  then
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

   if  w_cts09m00.atdfnlflg is null  then
       let w_cts09m00.atdfnlflg = "N"
       let w_cts09m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

 #------------------------------------------------------------------------------
 # Verifica solicitacao de guincho para caminhao
 #------------------------------------------------------------------------------
   if  d_cts09m00.asitipcod = 1  or       ###  Guincho
       d_cts09m00.asitipcod = 3  then     ###  Guincho/Tecnico
       if  d_cts09m00.camflg = "S"  then
           let w_cts09m00.atdvcltip = 3
       end if
   end if

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "8" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS09M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
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
                           w_cts09m00.data         ,
                           w_cts09m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           d_cts09m00.c24astcod    ,
                           w_cts09m00.funmat       ,
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
                           ws.cademp,  ws.cadmat )
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
                                w_cts09m00.vclcorcod,
                                w_cts09m00.funmat   ,
                                d_cts09m00.atdlibflg,
                                d_cts09m00.atdlibhor,
                                d_cts09m00.atdlibdat,
                                w_cts09m00.data     ,     # atddat
                                w_cts09m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts09m00.atdhorpvt,
                                w_cts09m00.atddatprg,
                                w_cts09m00.atdhorprg,
                                "8"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts09m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts09m00.atdfnlflg,
                                w_cts09m00.atdfnlhor,
                                w_cts09m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts09m00.c24opemat,
                                d_cts09m00.nom      ,
                                d_cts09m00.vcldes   ,
                                d_cts09m00.vclanomdl,
                                d_cts09m00.vcllicnum,
                                d_cts09m00.corsus   ,
                                d_cts09m00.cornom   ,
                                w_cts09m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts09m00.atdpvtretflg,
                                w_cts09m00.atdvcltip,
                                d_cts09m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts09m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts09m00.atdprinvlcod,
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

   #Chama funcao para gravar o Local / Condicoes do veiculo passando
   # o numero do servico
   call cts10g02_grava_loccnd(aux_atdsrvnum,
                              aux_atdsrvano)
        returning ws.tabname,
                  ws.codigosql

   if ws.codigosql <> 0 then
      error "Erro ",ws.codigosql, " na gravacao da tabela ",ws.tabname
           ," . AVISE A INFORMATICA!"
      rollback work
      prompt "" for char ws.prompt_key
      let ws.retorno = false
      exit while
   end if

 #------------------------------------------------------------------------------
 # Grava complemento do servico
 #------------------------------------------------------------------------------
   insert into DATMSERVICOCMP ( atdsrvnum,
                                sgdirbcod,              # - OSF 12351 -#
                                atdsrvano,
                                roddantxt,
                                vclcamtip,
                                vclcrcdsc,
                                vclcrgflg,
                                vclcrgpso)
                       values ( aux_atdsrvnum       ,
                                m_sgdirbcod         ,   # - OSF 12351 -#
                                aux_atdsrvano       ,
                                d_cts09m00.roddantxt,
                                w_cts09m00.vclcamtip,
                                w_cts09m00.vclcrcdsc,
                                w_cts09m00.vclcrgflg,
                                w_cts09m00.vclcrgpso )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 2
       if  a_cts09m00[arr_aux].operacao is null  then
           let a_cts09m00[arr_aux].operacao = "I"
       end if
       let a_cts09m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       let ws.codigosql = cts06g07_local( a_cts09m00[arr_aux].operacao    ,
                                        aux_atdsrvnum                   ,
                                        aux_atdsrvano                   ,
                                        arr_aux                         ,
                                        a_cts09m00[arr_aux].lclidttxt   ,
                                        a_cts09m00[arr_aux].lgdtip      ,
                                        a_cts09m00[arr_aux].lgdnom      ,
                                        a_cts09m00[arr_aux].lgdnum      ,
                                        a_cts09m00[arr_aux].lclbrrnom   ,
                                        a_cts09m00[arr_aux].brrnom      ,
                                        a_cts09m00[arr_aux].cidnom      ,
                                        a_cts09m00[arr_aux].ufdcod      ,
                                        a_cts09m00[arr_aux].lclrefptotxt,
                                        a_cts09m00[arr_aux].endzon      ,
                                        a_cts09m00[arr_aux].lgdcep      ,
                                        a_cts09m00[arr_aux].lgdcepcmp   ,
                                        a_cts09m00[arr_aux].lclltt      ,
                                        a_cts09m00[arr_aux].lcllgt      ,
                                        a_cts09m00[arr_aux].dddcod      ,
                                        a_cts09m00[arr_aux].lcltelnum   ,
                                        a_cts09m00[arr_aux].lclcttnom   ,
                                        a_cts09m00[arr_aux].c24lclpdrcod,
                                        a_cts09m00[arr_aux].ofnnumdig   ,
                                        a_cts09m00[arr_aux].emeviacod   ,
                                        a_cts09m00[arr_aux].celteldddcod,
                                        a_cts09m00[arr_aux].celtelnum,
                                        a_cts09m00[arr_aux].endcmp)

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
   call cts10g04_insere_etapa(aux_atdsrvnum    ,
                              aux_atdsrvano    ,
                              1,
                              w_cts09m00.atdprscod,
                              " ",
                              " ",
                              " ") returning w_retorno


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
   if  g_documento.aplnumdig is not null  and
       g_documento.aplnumdig <> 0         then
       call cts10g02_grava_servico_apolice(aux_atdsrvnum         ,
                                           aux_atdsrvano         ,
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
   end if

   commit work

   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)


 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   if w_hist.hist1 is not null then   # registra o motivo da escolha oficina
      call cts10g02_historico(aux_atdsrvnum    , aux_atdsrvano  ,
                              w_cts09m00.data  , w_cts09m00.hora,
                              g_issk.funmat, w_hist.* )
           returning ws.histerr
   end if
   call cts10g02_historico( aux_atdsrvnum  ,
                            aux_atdsrvano  ,
                            w_cts09m00.data,
                            w_cts09m00.hora,
                            g_issk.funmat  ,
                            hist_cts09m00.* )
        returning ws.histerr

### if ws.histerr  = 0  then
### initialize g_documento.acao  to null
###  end if

   #-----------------------------------------------
   # Aciona Servico automaticamente
   #-----------------------------------------------
   #PSI198714 - Acionar servico automaticamente
   #chamar funcao que verifica se acionamento pode ser feito
   # verifica se servico para cidade e internet ou GPS e se esta ativo
   #retorna true para acionamento e false para nao acionamento
   let m_aciona = 'N'
   if cts34g00_acion_auto (g_documento.atdsrvorg,
                           a_cts09m00[1].cidnom,
                           a_cts09m00[1].ufdcod) then
        #funcao cts34g00_acion_auto verificou que parametrizacao para origem
        # do servico esta OK
        #chamar funcao para validar regras gerais se um servico sera acionado
        # automaticamente ou nao e atualizar datmservico
        if not cts40g12_regras_aciona_auto (
                             g_documento.atdsrvorg,
                             g_documento.c24astcod,
                             d_cts09m00.asitipcod,
                             a_cts09m00[1].lclltt,
                             a_cts09m00[1].lcllgt,
                             "",
                             d_cts09m00.frmflg,
                             aux_atdsrvnum,
                             aux_atdsrvano,
                             "",
                             d_cts09m00.vclcoddig,
                             d_cts09m00.camflg) then
           #servico nao pode ser acionado automaticamente
           #display "Servico acionado manual"
        else
           let m_aciona = 'S'
           #display "Servico foi para acionamento automatico!!"
        end if
   end if

   #------------------------------------------------------------------------------
   # Gera laudo servico de apoio
   #------------------------------------------------------------------------------
   # PSI198714
   # Buscar locais condição veiculo para o servico
   #open c_cts09m00_002 using aux_atdsrvnum, aux_atdsrvano
   #foreach c_cts09m00_002 into l_vclcndlclcod
   #if l_vclcndlclcod = 6 or    #SUBSOLO
   #l_vclcndlclcod = 13 or   #"VEICULO TRANCADO"
   #l_vclcndlclcod = 14 then #OU "QUEBRA/PERDA CHAVE CODIFICADA"
   #call cts36m00(g_documento.lignum, aux_atdsrvnum, aux_atdsrvano, l_vclcndlclcod, "")
   #end if
   #end foreach

   #-----------------------------------------------------------------------------
   # Gera laudo servico de apoio
   #-----------------------------------------------------------------------------
   
   # --> VERIFICA AS REGRAS E GERA OS SERVICOS DE APOIO
   # inibido em 31/10/06 Conforme solicitacao da Silmara.
   # call cts40g19_gera_apoio(aux_atdsrvnum,
   #                          aux_atdsrvano,
   #                          g_documento.lignum,
   #                          d_cts09m00.asitipcod)
   
   let ws.retorno = true
   
   # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao 
   #                    ainda ativa e fazer a baixa da chave no AW
   let l_txtsrv = "SRV ", aux_atdsrvnum, "-", aux_atdsrvano
   
   if m_agendaw = true 
      then
      if m_operacao = 1  # obteve chave de regulacao 
         then
         if ws.retorno = true  # sucesso na gravacao do servico
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
               call cts02m08(w_cts09m00.atdfnlflg,
                             d_cts09m00.imdsrvflg,
                             m_altcidufd,
                             '',
                             w_cts09m00.atdhorpvt,
                             w_cts09m00.atddatprg,
                             w_cts09m00.atdhorprg,
                             w_cts09m00.atdpvtretflg,
                             m_rsrchv,
                             m_operacao,
                             "",
                             a_cts09m00[1].cidnom,
                             a_cts09m00[1].ufdcod,
                             "",   # codigo de assistencia, nao existe no Ct24h
                             d_cts09m00.vclcoddig,
                             w_cts09m00.ctgtrfcod,
                             d_cts09m00.imdsrvflg,
                             a_cts09m00[1].c24lclpdrcod,
                             a_cts09m00[1].lclltt,
                             a_cts09m00[1].lcllgt,
                             g_documento.ciaempcod,
                             g_documento.atdsrvorg,
                             d_cts09m00.asitipcod,
                             "",   # natureza somente RE
                             "")   # sub-natureza somente RE
                   returning w_cts09m00.atdhorpvt,
                             w_cts09m00.atddatprg,
                             w_cts09m00.atdhorprg,
                             w_cts09m00.atdpvtretflg,
                             d_cts09m00.imdsrvflg,
                             m_rsrchv,
                             m_operacao,
                             m_altdathor
                                
               display by name d_cts09m00.imdsrvflg
               
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
               #display 'cts09m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
            end if
            
         else
            #display l_txtsrv clipped, ' erro na inclusao, liberar agenda'
            
            call cts02m08_id_datahora_cota(m_rsrchv)
                 returning l_errcod, l_errmsg, m_agncotdat, m_agncothor
                 
            if l_errcod != 0
               then
            #   display 'ctd41g00_liberar_agenda NAO acionado, erro no ID da cota'
               display l_errmsg clipped
            end if
            
            call ctd41g00_liberar_agenda(aux_atdsrvano, aux_atdsrvnum
                                       , m_agncotdat, m_agncothor)
         end if
      end if
   end if
   # PSI-2013-00440PR
   
   #------------------------------------------------------------------------------
   # Exibe o numero do servico
   #------------------------------------------------------------------------------
   let d_cts09m00.servico = g_documento.atdsrvorg using "&&",
                       "/", aux_atdsrvnum using "&&&&&&&",
                       "-", aux_atdsrvano using "&&"
   display d_cts09m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso!"

   exit while
 end while
 
 return ws.retorno

end function  ###  inclui_cts09m00

#--------------------------------------------------------------------
 function input_cts09m00()
#--------------------------------------------------------------------

 define hist_cts09m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    dtparam           char (16),
    retflg            char (01),
    prpflg            char (01),
    confirma          char (01),
    opcao             smallint,
    opcaodes          char(20),
    ofnstt            like sgokofi.ofnstt ,
    rglflg            smallint
 end record

 define l_tmpflg      smallint
 define l_tipmvt       char(01)
 define l_data        date,
        l_hora2       datetime hour to minute

   define l_tipolaudo   smallint,      #PSI198714
          l_atdsrvnum   like datmservico.atdsrvnum,
          l_atdsrvano   like datmservico.atdsrvano,
          l_aux         smallint        ,
          l_msg         char(50),
          l_flag_limite char(01),
          l_acesso      smallint,
          l_atdetpcod   like datmsrvacp.atdetpcod,
          l_status      smallint
         ,l_errcod      smallint
         ,l_errmsg      char(80)
       
 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
 to null

 initialize l_errcod, l_errmsg to null 
 
	initialize  hist_cts09m00.*  to  null

	initialize  ws.*  to  null

 initialize ws.*  to null

 let l_tmpflg = 0
 let l_tipmvt = ""
 let l_msg = null
 let l_atdetpcod  = null
 let l_status     = null
 let m_grava_hist = false
 
 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if
 
 # situacao original do servico
 let m_imdsrvflg = d_cts09m00.imdsrvflg
 let m_cidnom = a_cts09m00[1].cidnom
 let m_ufdcod = a_cts09m00[1].ufdcod
 # PSI-2013-00440PR
 
 
 #display 'entrada do input, var null ou carregada na consulta'
 #display 'd_cts09m00.imdsrvflg :', d_cts09m00.imdsrvflg
 #display 'a_cts09m00[1].cidnom :', a_cts09m00[1].cidnom
 #display 'a_cts09m00[1].ufdcod :', a_cts09m00[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let ws.dtparam        = l_data using "yyyy-mm-dd"
 let ws.dtparam[12,16] = l_hora2

 input by name d_cts09m00.nom        ,
               d_cts09m00.corsus     ,
               d_cts09m00.cornom     ,
               d_cts09m00.vclcoddig  ,
               d_cts09m00.vclanomdl  ,
               d_cts09m00.vcllicnum  ,
               d_cts09m00.vclcordes  ,
               d_cts09m00.camflg     ,
##             d_cts09m00.roddantxt  ,
               d_cts09m00.asitipcod  ,
               d_cts09m00.dstflg     ,
               d_cts09m00.imdsrvflg  ,
               d_cts09m00.atdprinvlcod,
               d_cts09m00.atdlibflg  ,
               d_cts09m00.frmflg
       without defaults

   before field nom
          display by name d_cts09m00.nom        attribute (reverse)

          if g_documento.atdsrvnum   is not null   and
             g_documento.atdsrvano   is not null   and
             d_cts09m00.camflg       =  "S"    and
             (w_cts09m00.atdfnlflg    =  "N"   or     #PSI198714
              w_cts09m00.atdfnlflg    =  "A"      )then
             call cts02m01(w_cts09m00.ctgtrfcod,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           w_cts09m00.vclcrgflg, w_cts09m00.vclcrgpso,
                           w_cts09m00.vclcamtip, w_cts09m00.vclcrcdsc)
                 returning w_cts09m00.vclcrgflg, w_cts09m00.vclcrgpso,
                           w_cts09m00.vclcamtip, w_cts09m00.vclcrcdsc
          end if



   after  field nom
          display by name d_cts09m00.nom

          if g_documento.acao = "CON" then
             error " Servico sendo consultado, nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                  returning ws.confirma
             
             ### INICIO PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03("S"                 ,
                              d_cts09m00.imdsrvflg,
                              w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg)
                    returning w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg
             else
                call cts02m08("S"                 ,
                              d_cts09m00.imdsrvflg,
                              m_altcidufd,
                              '',
                              w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg,
                              m_rsrchvant,
                              m_operacao,
                              "",
                              a_cts09m00[1].cidnom,
                              a_cts09m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts09m00.vclcoddig,
                              w_cts09m00.ctgtrfcod,
                              d_cts09m00.imdsrvflg,
                              a_cts09m00[1].c24lclpdrcod,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts09m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg,
                              d_cts09m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
                              
             end if
             ### FIM PSI-2013-12097PR - RODOLFO MASSINI (F0113761)
             next field nom
          end if

          if d_cts09m00.nom is null or
             d_cts09m00.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if

          if w_cts09m00.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                   "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                  returning ws.confirma

             next field frmflg
          end if

   before field corsus
          display by name d_cts09m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts09m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.corsus is not null  then
                select cornom
                  into d_cts09m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts09m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts09m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts09m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts09m00.cornom

   before field vclcoddig
          display by name d_cts09m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts09m00.vclcoddig
          
          # se outro processo nao obteve cat. tarifaria, obter
          if w_cts09m00.ctgtrfcod is null
             then
             # laudo auto obter cod categoria tarifaria
             call cts02m08_sel_ctgtrfcod(d_cts09m00.vclcoddig)   
                  returning l_errcod, l_errmsg, w_cts09m00.ctgtrfcod
          end if
          
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts09m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else
             if d_cts09m00.vclcoddig is null  or
                d_cts09m00.vclcoddig =  0     then
                call agguvcl() returning d_cts09m00.vclcoddig
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts09m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cts15g00(d_cts09m00.vclcoddig)
                 returning d_cts09m00.vcldes

             display by name d_cts09m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts09m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts09m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.vclanomdl is null or
                d_cts09m00.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts09m00.vclcoddig, d_cts09m00.vclanomdl) = false  then
                   error " Veiculo nao consta como fabricado em ", d_cts09m00.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts09m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts09m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts09m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

   before field vclcordes
          display by name d_cts09m00.vclcordes attribute (reverse)

   after  field vclcordes
          display by name d_cts09m00.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.vclcordes is not null and
                d_cts09m00.vclcordes <> "  "     then
                let w_cts09m00.vclcordes = d_cts09m00.vclcordes[2,9]

                select cpocod
                  into w_cts09m00.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts09m00.vclcordes

                if status = notfound    then
                   error " Cor fora do padrao!"
                   call c24geral4() returning w_cts09m00.vclcorcod,
                                              d_cts09m00.vclcordes

                   if w_cts09m00.vclcorcod  is null   then
                      initialize d_cts09m00.vclcordes to null
                   else
                      display by name d_cts09m00.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts09m00.vclcorcod, d_cts09m00.vclcordes

                if w_cts09m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field  vclcordes
                else
                   display by name d_cts09m00.vclcordes
                end if
             end if
          end if

   before field camflg
          display by name d_cts09m00.camflg attribute (reverse)

   after  field camflg
          display by name d_cts09m00.camflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts09m00.camflg  is null)  or
                 (d_cts09m00.camflg  <>  "S"   and
                  d_cts09m00.camflg  <>  "N")) then
                error " Informacao sobre caminhao/utilitario invalida!"
                next field camflg
             end if

             if d_cts09m00.camflg = "S"  then
                call cts02m01(w_cts09m00.ctgtrfcod,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              w_cts09m00.vclcrgflg, w_cts09m00.vclcrgpso,
                              w_cts09m00.vclcamtip, w_cts09m00.vclcrcdsc)
                    returning w_cts09m00.vclcrgflg, w_cts09m00.vclcrgpso,
                              w_cts09m00.vclcamtip, w_cts09m00.vclcrcdsc

                if w_cts09m00.vclcamtip  is null   and
                   w_cts09m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                   next field camflg
                end if
             else
                initialize w_cts09m00.vclcamtip to null
                initialize w_cts09m00.vclcrcdsc to null
                initialize w_cts09m00.vclcrgflg to null
                initialize w_cts09m00.vclcrgpso to null
             end if

             let a_cts09m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
             let m_acesso_ind = false
             let l_atdsrvorg = 7
             call cta00m06_acesso_indexacao_aut(l_atdsrvorg)
                  returning m_acesso_ind
             if m_acesso_ind = false then
                call cts06g03(1,
                              l_atdsrvorg,
                              w_cts09m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts09m00[1].lclidttxt,
                              a_cts09m00[1].cidnom,
                              a_cts09m00[1].ufdcod,
                              a_cts09m00[1].brrnom,
                              a_cts09m00[1].lclbrrnom,
                              a_cts09m00[1].endzon,
                              a_cts09m00[1].lgdtip,
                              a_cts09m00[1].lgdnom,
                              a_cts09m00[1].lgdnum,
                              a_cts09m00[1].lgdcep,
                              a_cts09m00[1].lgdcepcmp,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              a_cts09m00[1].lclrefptotxt,
                              a_cts09m00[1].lclcttnom,
                              a_cts09m00[1].dddcod,
                              a_cts09m00[1].lcltelnum,
                              a_cts09m00[1].c24lclpdrcod,
                              a_cts09m00[1].ofnnumdig,
                              a_cts09m00[1].celteldddcod,
                              a_cts09m00[1].celtelnum,
                              a_cts09m00[1].endcmp,
                              hist_cts09m00.*,
                              a_cts09m00[1].emeviacod)
                    returning a_cts09m00[1].lclidttxt,
                              a_cts09m00[1].cidnom,
                              a_cts09m00[1].ufdcod,
                              a_cts09m00[1].brrnom,
                              a_cts09m00[1].lclbrrnom,
                              a_cts09m00[1].endzon,
                              a_cts09m00[1].lgdtip,
                              a_cts09m00[1].lgdnom,
                              a_cts09m00[1].lgdnum,
                              a_cts09m00[1].lgdcep,
                              a_cts09m00[1].lgdcepcmp,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              a_cts09m00[1].lclrefptotxt,
                              a_cts09m00[1].lclcttnom,
                              a_cts09m00[1].dddcod,
                              a_cts09m00[1].lcltelnum,
                              a_cts09m00[1].c24lclpdrcod,
                              a_cts09m00[1].ofnnumdig,
                              a_cts09m00[1].celteldddcod   ,
                              a_cts09m00[1].celtelnum,
                              a_cts09m00[1].endcmp,
                              ws.retflg,
                              hist_cts09m00.*,
                              a_cts09m00[1].emeviacod
             else
                call cts06g11(1,
                              l_atdsrvorg,
                              w_cts09m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts09m00[1].lclidttxt,
                              a_cts09m00[1].cidnom,
                              a_cts09m00[1].ufdcod,
                              a_cts09m00[1].brrnom,
                              a_cts09m00[1].lclbrrnom,
                              a_cts09m00[1].endzon,
                              a_cts09m00[1].lgdtip,
                              a_cts09m00[1].lgdnom,
                              a_cts09m00[1].lgdnum,
                              a_cts09m00[1].lgdcep,
                              a_cts09m00[1].lgdcepcmp,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              a_cts09m00[1].lclrefptotxt,
                              a_cts09m00[1].lclcttnom,
                              a_cts09m00[1].dddcod,
                              a_cts09m00[1].lcltelnum,
                              a_cts09m00[1].c24lclpdrcod,
                              a_cts09m00[1].ofnnumdig,
                              a_cts09m00[1].celteldddcod,
                              a_cts09m00[1].celtelnum,
                              a_cts09m00[1].endcmp,
                              hist_cts09m00.*,
                              a_cts09m00[1].emeviacod)
                    returning a_cts09m00[1].lclidttxt,
                              a_cts09m00[1].cidnom,
                              a_cts09m00[1].ufdcod,
                              a_cts09m00[1].brrnom,
                              a_cts09m00[1].lclbrrnom,
                              a_cts09m00[1].endzon,
                              a_cts09m00[1].lgdtip,
                              a_cts09m00[1].lgdnom,
                              a_cts09m00[1].lgdnum,
                              a_cts09m00[1].lgdcep,
                              a_cts09m00[1].lgdcepcmp,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              a_cts09m00[1].lclrefptotxt,
                              a_cts09m00[1].lclcttnom,
                              a_cts09m00[1].dddcod,
                              a_cts09m00[1].lcltelnum,
                              a_cts09m00[1].c24lclpdrcod,
                              a_cts09m00[1].ofnnumdig,
                              a_cts09m00[1].celteldddcod   ,
                              a_cts09m00[1].celtelnum,
                              a_cts09m00[1].endcmp,
                              ws.retflg,
                              hist_cts09m00.*,
                              a_cts09m00[1].emeviacod
             end if
             #------------------------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #------------------------------------------------------------------------------
             if g_documento.lclocodesres = "S" then
                let w_cts09m00.atdrsdflg = "S"
             else
                let w_cts09m00.atdrsdflg = "N"
             end if
             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts09m00[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts09m00[1].brrnom,
                                            a_cts09m00[1].lclbrrnom)
                  returning a_cts09m00[1].lclbrrnom

             let a_cts09m00[1].lgdtxt = a_cts09m00[1].lgdtip clipped, " ",
                                        a_cts09m00[1].lgdnom clipped, " ",
                                        a_cts09m00[1].lgdnum using "<<<<#"


             if a_cts09m00[1].cidnom is not null and
                a_cts09m00[1].ufdcod is not null then
                call cts14g00 (d_cts09m00.c24astcod,
                               "","","","",
                               a_cts09m00[1].cidnom,
                               a_cts09m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts09m00[1].lgdtxt
             display by name a_cts09m00[1].lclbrrnom
             display by name a_cts09m00[1].endzon
             display by name a_cts09m00[1].cidnom
             display by name a_cts09m00[1].ufdcod
             display by name a_cts09m00[1].lclrefptotxt
             display by name a_cts09m00[1].lclcttnom
             display by name a_cts09m00[1].dddcod
             display by name a_cts09m00[1].lcltelnum
             display by name a_cts09m00[1].celteldddcod
             display by name a_cts09m00[1].celtelnum
             display by name a_cts09m00[1].endcmp

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field camflg
             end if
          end if

#  before field roddantxt
#         display by name d_cts09m00.roddantxt attribute (reverse)
#
#  after  field roddantxt
#         display by name d_cts09m00.roddantxt
#
#         if fgl_lastkey() <> fgl_keyval("up")   and
#            fgl_lastkey() <> fgl_keyval("left") then
#            if d_cts09m00.roddantxt is null  or
#               d_cts09m00.roddantxt =  " "   then
#               error " Se rodas foram danificadas deve ser informado!"
#               next field roddantxt
#            end if
#         end if

   before field asitipcod
          display by name d_cts09m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts09m00.asitipcod

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts09m00.asitipcod is null  then
                call ctn25c00(7) returning d_cts09m00.asitipcod

                if d_cts09m00.asitipcod is not null  then
                   select asitipabvdes, asiofndigflg, vclcndlclflg  #OSF 19968
                     into d_cts09m00.asitipabvdes
                         ,w_cts09m00.asiofndigflg
                         ,w_cts09m00.vclcndlclflg
                     from datkasitip
                    where asitipcod = d_cts09m00.asitipcod  and
                          asitipstt = "A"

                   if sqlca.sqlcode <> 0 then
                      error "Falha ao acessar DATKASITIP. Erro: ", sqlca.sqlcode
                      next field asitipcod
                   end if

                   if d_cts09m00.asitipcod = 1 and       #OSF 19968
                      w_cts09m00.asiofndigflg = "S" then
                      let d_cts09m00.dstflg = "S"
                      display by name d_cts09m00.dstflg
                   end if

                   display by name d_cts09m00.asitipcod
                   display by name d_cts09m00.asitipabvdes

                   #Se tipo de Assistencia possui Alerta Importante
                   #e se PARA Consulta, tipo Movto sera "C", Senao,
                   #sera "M"-Modifica
                   if w_cts09m00.vclcndlclflg = "S" then
                      if g_documento.acao = "CON" then
                         let l_tipmvt = "A"
                      else
                         let l_tipmvt = "M"
                      end if

                      #Chama tela para selecionar locais e condicoes do
                      #veiculo
                      call ctc61m02(g_documento.atdsrvnum
                                   ,g_documento.atdsrvano
                                   ,l_tipmvt)

                   else
                      #Se nao possui alerta Importante no Tipo de assistencia
                      #destroi a tabela temporaria. Se houver problema,
                      #apresentar mensagem de erro
                      let l_tmpflg = ctc61m02_criatmp(2
                                                     ,g_documento.atdsrvnum
                                                     ,g_documento.atdsrvano)
                      if l_tmpflg = 1 then
                         display "Problemas com temporaria! "
                                ,"<Avise a Informatica> "
                      end if
                   end if
                   next field dstflg
                else
                   next field asitipcod
                end if
             else
                #Senao PARA nulo Tipo de Assistencia nula
                #Leitura do  campo Alerta importante para Tipo de
                #Assistencia
                select asitipabvdes, asiofndigflg, vclcndlclflg   #OSF 19968
                  into d_cts09m00.asitipabvdes
                      ,w_cts09m00.asiofndigflg
                      ,w_cts09m00.vclcndlclflg
                  from datkasitip
                 where asitipcod = d_cts09m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   call ctn25c00(7) returning d_cts09m00.asitipcod
                   next field asitipcod
                else
                   display by name d_cts09m00.asitipcod
                end if

                if d_cts09m00.asitipcod = 1 and       #OSF 19968
                   w_cts09m00.asiofndigflg = "S" then
                   let d_cts09m00.dstflg = "S"
                   display by name d_cts09m00.dstflg
                end if

                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = g_documento.atdsrvorg
                   and asitipcod = d_cts09m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada para este servico!"
                   next field asitipcod
                end if

                #Se Tipo de Assistencia possui Alerta Importante
                #e se PARA Consulta, tipo Movto sera "C", Senao,
                #sera "M"-Modifica
                if w_cts09m00.vclcndlclflg = "S" then
                   if g_documento.acao = "CON" then
                      let l_tipmvt = "A"
                   else
                      let l_tipmvt = "M"
                   end if

                   call ctc61m02(g_documento.atdsrvnum
                                ,g_documento.atdsrvano
                                ,l_tipmvt)

                else
                   #Se nao possui alerta Importante no Tipo de assistencia
                   #destroi a tabela temporaria. Se houver problema,
                   #apresentar mensagem de erro
                   let l_tmpflg = ctc61m02_criatmp(2
                                                  ,g_documento.atdsrvnum
                                                  ,g_documento.atdsrvano)
                   if l_tmpflg = 1 then
                      error "Problemas com tabela temporaria! "
                   end if
                end if
             end if

             display by name d_cts09m00.asitipabvdes
	     call cty26g00_srv_auto(g_documento.ramcod  ## JUNIOR (FORNAX)
				   ,g_documento.succod
                                   ,g_documento.aplnumdig
			           ,g_documento.itmnumdig
			           ,g_documento.c24astcod
			           ,d_cts09m00.asitipcod)
		  returning l_flag_limite
             if l_flag_limite = "S" then
	        let ws.confirma = cts08g01('A'  ,'S','' ,
					  'CONSULTE A COORDENACAO, ',
					  'PARA ENVIO DE ATENDIMENTO. '  ,'')
		next field asitipcod
	     end if
          end if

   before field dstflg
          let d_cts09m00.dstflg = "S"
          display by name d_cts09m00.dstflg attribute (reverse)

   after  field dstflg
          display by name d_cts09m00.dstflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.dstflg is null  or
                d_cts09m00.dstflg =  " "   then
                error " Destino deve ser informado!"
                next field dstflg
             end if

             if d_cts09m00.dstflg <> "S"  and
                d_cts09m00.dstflg <> "N"  then
                error " Existe destino: (S)im ou (N)ao"
                next field dstflg
             end if

             initialize w_hist.* to null
             if d_cts09m00.dstflg = "S"  then
                let a_cts09m00[3].* = a_cts09m00[2].*
                let a_cts09m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                let m_acesso_ind = false
                let l_atdsrvorg = 7
                call cta00m06_acesso_indexacao_aut(l_atdsrvorg)
                     returning m_acesso_ind

               if m_acesso_ind = false then
                  call cts06g03(2,
                                l_atdsrvorg,
                                w_cts09m00.ligcvntip,
                                aux_today,
                                aux_hora,
                                a_cts09m00[2].lclidttxt,
                                a_cts09m00[2].cidnom,
                                a_cts09m00[2].ufdcod,
                                a_cts09m00[2].brrnom,
                                a_cts09m00[2].lclbrrnom,
                                a_cts09m00[2].endzon,
                                a_cts09m00[2].lgdtip,
                                a_cts09m00[2].lgdnom,
                                a_cts09m00[2].lgdnum,
                                a_cts09m00[2].lgdcep,
                                a_cts09m00[2].lgdcepcmp,
                                a_cts09m00[2].lclltt,
                                a_cts09m00[2].lcllgt,
                                a_cts09m00[2].lclrefptotxt,
                                a_cts09m00[2].lclcttnom,
                                a_cts09m00[2].dddcod,
                                a_cts09m00[2].lcltelnum,
                                a_cts09m00[2].c24lclpdrcod,
                                a_cts09m00[2].ofnnumdig,
                                a_cts09m00[2].celteldddcod   ,
                                a_cts09m00[2].celtelnum,
                                a_cts09m00[2].endcmp,
                                hist_cts09m00.*,
                                a_cts09m00[2].emeviacod)
                      returning a_cts09m00[2].lclidttxt,
                                a_cts09m00[2].cidnom,
                                a_cts09m00[2].ufdcod,
                                a_cts09m00[2].brrnom,
                                a_cts09m00[2].lclbrrnom,
                                a_cts09m00[2].endzon,
                                a_cts09m00[2].lgdtip,
                                a_cts09m00[2].lgdnom,
                                a_cts09m00[2].lgdnum,
                                a_cts09m00[2].lgdcep,
                                a_cts09m00[2].lgdcepcmp,
                                a_cts09m00[2].lclltt,
                                a_cts09m00[2].lcllgt,
                                a_cts09m00[2].lclrefptotxt,
                                a_cts09m00[2].lclcttnom,
                                a_cts09m00[2].dddcod,
                                a_cts09m00[2].lcltelnum,
                                a_cts09m00[2].c24lclpdrcod,
                                a_cts09m00[2].ofnnumdig,
                                a_cts09m00[2].celteldddcod   ,
                                a_cts09m00[2].celtelnum,
                                a_cts09m00[2].endcmp,
                                ws.retflg,
                                hist_cts09m00.*,
                                a_cts09m00[2].emeviacod
               else
                  call cts06g11(2,
                                l_atdsrvorg,
                                w_cts09m00.ligcvntip,
                                aux_today,
                                aux_hora,
                                a_cts09m00[2].lclidttxt,
                                a_cts09m00[2].cidnom,
                                a_cts09m00[2].ufdcod,
                                a_cts09m00[2].brrnom,
                                a_cts09m00[2].lclbrrnom,
                                a_cts09m00[2].endzon,
                                a_cts09m00[2].lgdtip,
                                a_cts09m00[2].lgdnom,
                                a_cts09m00[2].lgdnum,
                                a_cts09m00[2].lgdcep,
                                a_cts09m00[2].lgdcepcmp,
                                a_cts09m00[2].lclltt,
                                a_cts09m00[2].lcllgt,
                                a_cts09m00[2].lclrefptotxt,
                                a_cts09m00[2].lclcttnom,
                                a_cts09m00[2].dddcod,
                                a_cts09m00[2].lcltelnum,
                                a_cts09m00[2].c24lclpdrcod,
                                a_cts09m00[2].ofnnumdig,
                                a_cts09m00[2].celteldddcod   ,
                                a_cts09m00[2].celtelnum,
                                a_cts09m00[2].endcmp,
                                hist_cts09m00.*,
                                a_cts09m00[2].emeviacod)
                      returning a_cts09m00[2].lclidttxt,
                                a_cts09m00[2].cidnom,
                                a_cts09m00[2].ufdcod,
                                a_cts09m00[2].brrnom,
                                a_cts09m00[2].lclbrrnom,
                                a_cts09m00[2].endzon,
                                a_cts09m00[2].lgdtip,
                                a_cts09m00[2].lgdnom,
                                a_cts09m00[2].lgdnum,
                                a_cts09m00[2].lgdcep,
                                a_cts09m00[2].lgdcepcmp,
                                a_cts09m00[2].lclltt,
                                a_cts09m00[2].lcllgt,
                                a_cts09m00[2].lclrefptotxt,
                                a_cts09m00[2].lclcttnom,
                                a_cts09m00[2].dddcod,
                                a_cts09m00[2].lcltelnum,
                                a_cts09m00[2].c24lclpdrcod,
                                a_cts09m00[2].ofnnumdig,
                                a_cts09m00[2].celteldddcod   ,
                                a_cts09m00[2].celtelnum,
                                a_cts09m00[2].endcmp,
                                ws.retflg,
                                hist_cts09m00.*,
                                a_cts09m00[2].emeviacod
               end if

                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_subbairro[2].lclbrrnom = a_cts09m00[2].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts09m00[2].brrnom,
                                               a_cts09m00[2].lclbrrnom)
                     returning a_cts09m00[2].lclbrrnom
                let a_cts09m00[2].lgdtxt = a_cts09m00[2].lgdtip clipped, " ",
                                           a_cts09m00[2].lgdnom clipped, " ",
                                           a_cts09m00[2].lgdnum using "<<<<#"
                if a_cts09m00[2].lclltt <> a_cts09m00[3].lclltt or
                   a_cts09m00[2].lcllgt <> a_cts09m00[3].lcllgt or
                   (a_cts09m00[3].lclltt is null and a_cts09m00[2].lclltt is not  null) or
                   (a_cts09m00[3].lcllgt is null and a_cts09m00[2].lcllgt is not null) then
                   call cts00m33(1,
                                 a_cts09m00[1].lclltt,
                                 a_cts09m00[1].lcllgt,
                                 a_cts09m00[2].lclltt,
                                 a_cts09m00[2].lcllgt)
                end if
                if a_cts09m00[2].cidnom is not null and
                   a_cts09m00[2].ufdcod is not null then
                   call cts14g00 (d_cts09m00.c24astcod,
                                  "","","","",
                                  a_cts09m00[2].cidnom,
                                  a_cts09m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if
                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos",
                         " ou nao preenchidos!"
                   next field dstflg
                end if
                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then
                   let a_cts09m00[2].operacao = "I"
                else
                   select c24lclpdrcod
                     from datmlcl
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano  and
                          c24endtip = 2
                   if sqlca.sqlcode = notfound  then
                      let a_cts09m00[2].operacao = "I"
                   else
                      let a_cts09m00[2].operacao = "M"
                   end if
                end if
                if a_cts09m00[2].ofnnumdig is not null then
                   select ofnstt
                       into ws.ofnstt
                       from sgokofi
                      where ofnnumdig = a_cts09m00[2].ofnnumdig
                   if ws.ofnstt = "C" then
                      # digita o motivo
                      let w_hist.hist1 = "OF CORT MOTIVO:"
                      call cts10m02 (w_hist.*) returning w_hist.*
                   end if
                end if
             else
                if d_cts09m00.asitipcod    = 1   and
                   w_cts09m00.asiofndigflg = "S" then
                   error "Destino e Obrigatorio"
                   next field dstflg
                end if
                initialize a_cts09m00[2].*  to null
                let a_cts09m00[2].operacao = "D"
             end if
          end if

   before field imdsrvflg
          display by name d_cts09m00.imdsrvflg attribute (reverse)

   after  field imdsrvflg
          display by name d_cts09m00.imdsrvflg

          # PSI-2013-00440PR
          if (m_imdsrvflg is null) or (m_imdsrvflg != d_cts09m00.imdsrvflg)
             then
             let m_rsrchv = null
             let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
          end if
          
          if (m_cidnom != a_cts09m00[1].cidnom) or
             (m_ufdcod != a_cts09m00[1].ufdcod) then
             let m_altcidufd = true
             let m_operacao = 0  # regular novamente
             #display 'cts09m00 - Elegivel para regulacao, alterou cidade/uf'
          else
             let m_altcidufd = false
          end if
          
          # na inclusao dados nulos, igualar aos digitados
          if m_imdsrvflg is null then
             let m_imdsrvflg = d_cts09m00.imdsrvflg
          end if
          
          if m_cidnom is null then
             let m_cidnom = a_cts09m00[1].cidnom
          end if
          
          if m_ufdcod is null then
             let m_ufdcod = a_cts09m00[1].ufdcod
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
             if d_cts09m00.imdsrvflg is null   or
                d_cts09m00.imdsrvflg =  " "    then
                error " Dados sobre servico imediato devem ser informados!"
                next field imdsrvflg
             end if

             if d_cts09m00.imdsrvflg <> "S"    and
                d_cts09m00.imdsrvflg <> "N"    then
                error " Servico Imediato: (S)im ou (N)ao!"
                next field imdsrvflg
             end if

             if m_agendaw = false   # regulacao antiga
                then
                call cts02m03(w_cts09m00.atdfnlflg,
                              d_cts09m00.imdsrvflg,
                              w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg)
                    returning w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg
             else
                call cts02m08(w_cts09m00.atdfnlflg,
                              d_cts09m00.imdsrvflg,
                              m_altcidufd,
                              '',
                              w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg,
                              m_rsrchv,
                              m_operacao,
                              "",
                              a_cts09m00[1].cidnom,
                              a_cts09m00[1].ufdcod,
                              "",   # codigo de assistencia, nao existe no Ct24h
                              d_cts09m00.vclcoddig,
                              w_cts09m00.ctgtrfcod,
                              d_cts09m00.imdsrvflg,
                              a_cts09m00[1].c24lclpdrcod,
                              a_cts09m00[1].lclltt,
                              a_cts09m00[1].lcllgt,
                              g_documento.ciaempcod,
                              g_documento.atdsrvorg,
                              d_cts09m00.asitipcod,
                              "",   # natureza somente RE
                              "")   # sub-natureza somente RE
                    returning w_cts09m00.atdhorpvt,
                              w_cts09m00.atddatprg,
                              w_cts09m00.atdhorprg,
                              w_cts09m00.atdpvtretflg,
                              d_cts09m00.imdsrvflg,
                              m_rsrchv,
                              m_operacao,
                              m_altdathor
                              
                display by name d_cts09m00.imdsrvflg
                 
                if int_flag
                   then
                   let int_flag = false
                   next field imdsrvflg
                end if
             end if
             
             if d_cts09m00.imdsrvflg = "S"  then
                if w_cts09m00.atdhorpvt is null  then
                   error " Previsao de horas nao informada para servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts09m00.atddatprg is null  or
                   w_cts09m00.atddatprg  = " "   then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts09m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts09m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts09m00.atdprinvlcod

                    display by name d_cts09m00.atdprinvlcod
                    display by name d_cts09m00.atdprinvldes

                end if
             end if
          end if
          
          # PSI-2013-00440PR
          if m_agendaw = false   # regulacao antiga
             then

             #Rob
             #### CHAMA REGULADOR ####
             if d_cts09m00.imdsrvflg = "S"  then
                let ws.rglflg = ctc59m02 ( a_cts09m00[1].cidnom,
                                           a_cts09m00[1].ufdcod,
                                           g_documento.atdsrvorg,
                                           d_cts09m00.asitipcod,
                                           aux_today,
                                           aux_hora,
                                           false)
             else
                let ws.rglflg = ctc59m02 ( a_cts09m00[1].cidnom,
                                           a_cts09m00[1].ufdcod,
                                           g_documento.atdsrvorg,
                                           d_cts09m00.asitipcod,
                                           w_cts09m00.atddatprg,
                                           w_cts09m00.atdhorprg,
                                           false )
             end if
   
             if ws.rglflg <> 0 then
   
                let d_cts09m00.imdsrvflg = "N"
                call ctc59m03 ( a_cts09m00[1].cidnom,
                                a_cts09m00[1].ufdcod,
                                g_documento.atdsrvorg,
                                d_cts09m00.asitipcod,
                                aux_today,
                                aux_hora)
                     returning  w_cts09m00.atddatprg,
                                w_cts09m00.atdhorprg
                next field imdsrvflg
             end if
   
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
   
                # Para abater regulador
                let ws.rglflg = ctc59m03_regulador(g_documento.atdsrvnum,
                                                   g_documento.atdsrvano)
             end if
          end if  # PSI-2013-00440PR

          next field atdlibflg

   before field atdprinvlcod
          display by name d_cts09m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts09m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts09m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts09m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts09m00.atdprinvldes

          end if

   before field atdlibflg
          display by name d_cts09m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts09m00.atdfnlflg   = "S"       then
             exit input
          end if

          if d_cts09m00.atdlibflg is null  and
             g_documento.c24soltipcod = 1  then   # Tipo Solic = Segurado
           # call cts09g00(g_documento.ramcod   ,  # psi 141003
           #               g_documento.succod   ,
           #               g_documento.aplnumdig,
           #               g_documento.itmnumdig,
           #               true)
           #     returning ws.dddcod, ws.teltxt
          end if

   after  field atdlibflg
          display by name d_cts09m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts09m00.atdlibflg <> "S"  and
                d_cts09m00.atdlibflg <> "N"  then
                error " Envio liberado invalido!"
                next field atdlibflg
             end if

            #call cts02m06() returning w_cts09m00.atdlibflg
            #let d_cts09m00.atdlibflg = w_cts09m00.atdlibflg

             let w_cts09m00.atdlibflg = d_cts09m00.atdlibflg
             display by name d_cts09m00.atdlibflg

             if aux_libant is null  then
                if w_cts09m00.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2)
                        returning l_data, l_hora2
                   let aux_libhor           = l_hora2
                   let d_cts09m00.atdlibhor = aux_libhor
                   let d_cts09m00.atdlibdat = l_data
                else
                   let d_cts09m00.atdlibflg = "N"
                   display by name d_cts09m00.atdlibflg
                   initialize d_cts09m00.atdlibhor to null
                   initialize d_cts09m00.atdlibdat to null
                end if
             else
                select atdfnlflg
                  from datmservico
                 where atdsrvnum = g_documento.atdsrvnum  and
                       atdsrvano = g_documento.atdsrvano  and
                       atdfnlflg in ("N","A")      #PSI198714

                if sqlca.sqlcode = notfound  then
                   error " Servico ja' acionado nao pode ser alterado!"
                   let m_srv_acionado = true
                   call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                     " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                         "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                        returning ws.confirma
                   next field atdlibflg
                end if

                if aux_libant = "S"   then
                   if w_cts09m00.atdlibflg = "S" then
                      exit input
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts09m00.atdlibflg = "N"
                      display by name d_cts09m00.atdlibflg
                      initialize d_cts09m00.atdlibhor to null
                      initialize d_cts09m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      exit input
                   end if
                else
                   if aux_libant = "N"   then
                      if w_cts09m00.atdlibflg = "N" then
                         exit input
                      else
                         call cts40g03_data_hora_banco(2)
                              returning l_data, l_hora2
                         let aux_libhor           = l_hora2
                         let d_cts09m00.atdlibhor = aux_libhor
                         let d_cts09m00.atdlibdat = l_data
                         exit input
                      end if
                   end if
                end if
             end if
          end if

   before field frmflg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             let d_cts09m00.frmflg = "N"
             display by name d_cts09m00.frmflg attribute (reverse)
          else
             if w_cts09m00.atdfnlflg = "S"  then
                call cts11g00(w_cts09m00.lignum)
                let int_flag = true
             end if

             exit input
          end if

   after  field frmflg
          display by name d_cts09m00.frmflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts09m00.frmflg = "S" then
                if d_cts09m00.atdlibflg = "N"  then
                   error " Nao e' possivel registrar servico nao liberado via formulario!"
                   next field atdlibflg
                end if

                call cts02m05(7) returning w_cts09m00.data,
                                           w_cts09m00.hora,
                                           w_cts09m00.funmat,
                                           w_cts09m00.cnldat,
                                           w_cts09m00.atdfnlhor,
                                           w_cts09m00.c24opemat,
                                           w_cts09m00.atdprscod

                if w_cts09m00.hora      is null  or
                   w_cts09m00.data      is null  or
                   w_cts09m00.funmat    is null  or
                   w_cts09m00.cnldat    is null  or
                   w_cts09m00.atdfnlhor is null  or
                   w_cts09m00.c24opemat is null  or
                   w_cts09m00.atdprscod is null  then
                   error " Faltam dados para entrada via formulario!"
                   next field frmflg
                end if

                let d_cts09m00.atdlibhor = w_cts09m00.hora
                let d_cts09m00.atdlibdat = w_cts09m00.data
                let w_cts09m00.atdfnlflg = "S"
                let w_cts09m00.atdetpcod =  4
             else
                initialize w_cts09m00.hora     ,
                           w_cts09m00.data     ,
                           w_cts09m00.funmat   ,
                           w_cts09m00.cnldat   ,
                           w_cts09m00.atdfnlhor,
                           w_cts09m00.c24opemat,
                           w_cts09m00.atdfnlflg,
                           w_cts09m00.atdetpcod,
                           w_cts09m00.atdprscod to null
             end if
          end if

   on key (interrupt)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
              returning ws.confirma

         if ws.confirma  =  "S"   then
            #Se abandonar Laudo, chamar funcao para remover
            #tabela temporaria, tratando o erro se houver
            let l_tmpflg = ctc61m02_criatmp(2
                                           ,g_documento.atdsrvnum
                                           ,g_documento.atdsrvano)
            if l_tmpflg = 1 then
               error "Problemas com tabela temporaria!"
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
            call consulta_cts09m00()
            call cts09m00_display()
            call cts02m00_ver_uso(l_atdsrvnum,l_atdsrvano,1)
                 returning l_msg
         else
            exit input
         end if
      end if

   on key (F1)
      if d_cts09m00.c24astcod is not null then
         call ctc58m00_vis(d_cts09m00.c24astcod)
      end if

   on key (F3)     #PS - OSF 19968
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
                  call consulta_cts09m00()
                  #exibe informações no laudo
                  call cts09m00_display()
               end if
            end if
         else
            error "Servico nao ligado a servicos de apoio" sleep 2
         end if
      end if


   on key (F5)
    {  if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         if g_documento.ramcod =  31  or
            g_documento.ramcod = 531  then
            call cta01m00()
         else
            call cta01m20()
         end if
      else
         if g_documento.prporg    is not null  and
            g_documento.prpnumdig is not null  then
            call opacc149(g_documento.prporg, g_documento.prpnumdig) returning ws.prpflg
         else
            if g_documento.pcacarnum is not null  and
               g_documento.pcaprpitm is not null  then
               call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
            else
               error " Espelho so' com documento localizado!"
            end if
         end if
      end if }
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
      if g_documento.atdsrvnum is null or
         g_documento.atdsrvano is null then
         call cts10m02 (hist_cts09m00.*)  returning hist_cts09m00.*
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat        , aux_today  ,aux_hora)
      end if

   on key (F7)
      call ctx14g00("Funcoes","Impressao|Caminhao|Distancia|Veiculo")
           returning ws.opcao,
                     ws.opcaodes
      case ws.opcao
         when 1  ### Impressao
            if g_documento.atdsrvnum is null then
               error " Impressao somente com cadastramento do servico!"
            else
               call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
            end if

         when 2  ### Caminhao
            if d_cts09m00.camflg = "S"  then
               call cts02m01(w_cts09m00.ctgtrfcod,
                             g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             w_cts09m00.vclcrgflg, w_cts09m00.vclcrgpso,
                             w_cts09m00.vclcamtip, w_cts09m00.vclcrcdsc)
                   returning w_cts09m00.vclcrgflg, w_cts09m00.vclcrgpso,
                             w_cts09m00.vclcamtip, w_cts09m00.vclcrcdsc

               if w_cts09m00.vclcamtip  is null   and
                  w_cts09m00.vclcrgflg  is null   then
                  error " Faltam informacoes sobre caminhao/utilitario!"
               end if
            end if

          when 3   #### Distancia QTH-QTI
             call cts00m33(1,
                           a_cts09m00[1].lclltt,
                           a_cts09m00[1].lcllgt,
                           a_cts09m00[2].lclltt,
                           a_cts09m00[2].lcllgt)

          when 4   #### Apresentar Locais e as condicoes do veiculo
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
                call ctc61m02(g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              "A")

                let l_tmpflg = ctc61m02_criatmp(2,
                                                g_documento.atdsrvnum,
                                                g_documento.atdsrvano)

                if l_tmpflg = 1 then
                   error "Problemas com temporaria! <Avise a Informatica> "
                end if
             end if

      end case

   on key (F8)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts09m00.dstflg = "N"  then
            error " Nao foi informado destino para este servico!"
         else
            let a_cts09m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
            let m_acesso_ind = false
            let l_atdsrvorg = 7
            call cta00m06_acesso_indexacao_aut(l_atdsrvorg)
                 returning m_acesso_ind

            #Projeto alteracao cadastro de destino
            if g_documento.acao = "ALT" then

               call cts09m00_bkp_info_dest(1, hist_cts09m00.*)
                  returning hist_cts09m00.*

            end if

            if m_acesso_ind = false then
               call cts06g03(2,
                             l_atdsrvorg,
                             w_cts09m00.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts09m00[2].lclidttxt,
                             a_cts09m00[2].cidnom,
                             a_cts09m00[2].ufdcod,
                             a_cts09m00[2].brrnom,
                             a_cts09m00[2].lclbrrnom,
                             a_cts09m00[2].endzon,
                             a_cts09m00[2].lgdtip,
                             a_cts09m00[2].lgdnom,
                             a_cts09m00[2].lgdnum,
                             a_cts09m00[2].lgdcep,
                             a_cts09m00[2].lgdcepcmp,
                             a_cts09m00[2].lclltt,
                             a_cts09m00[2].lcllgt,
                             a_cts09m00[2].lclrefptotxt,
                             a_cts09m00[2].lclcttnom,
                             a_cts09m00[2].dddcod,
                             a_cts09m00[2].lcltelnum,
                             a_cts09m00[2].c24lclpdrcod,
                             a_cts09m00[2].ofnnumdig,
                             a_cts09m00[2].celteldddcod   ,
                             a_cts09m00[2].celtelnum,
                             a_cts09m00[2].endcmp,
                             hist_cts09m00.*,
                             a_cts09m00[2].emeviacod)
                   returning a_cts09m00[2].lclidttxt,
                             a_cts09m00[2].cidnom,
                             a_cts09m00[2].ufdcod,
                             a_cts09m00[2].brrnom,
                             a_cts09m00[2].lclbrrnom,
                             a_cts09m00[2].endzon,
                             a_cts09m00[2].lgdtip,
                             a_cts09m00[2].lgdnom,
                             a_cts09m00[2].lgdnum,
                             a_cts09m00[2].lgdcep,
                             a_cts09m00[2].lgdcepcmp,
                             a_cts09m00[2].lclltt,
                             a_cts09m00[2].lcllgt,
                             a_cts09m00[2].lclrefptotxt,
                             a_cts09m00[2].lclcttnom,
                             a_cts09m00[2].dddcod,
                             a_cts09m00[2].lcltelnum,
                             a_cts09m00[2].c24lclpdrcod,
                             a_cts09m00[2].ofnnumdig,
                             a_cts09m00[2].celteldddcod   ,
                             a_cts09m00[2].celtelnum,
                             a_cts09m00[2].endcmp,
                             ws.retflg,
                             hist_cts09m00.*,
                             a_cts09m00[2].emeviacod
            else
               call cts06g11(2,
                             l_atdsrvorg,
                             w_cts09m00.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts09m00[2].lclidttxt,
                             a_cts09m00[2].cidnom,
                             a_cts09m00[2].ufdcod,
                             a_cts09m00[2].brrnom,
                             a_cts09m00[2].lclbrrnom,
                             a_cts09m00[2].endzon,
                             a_cts09m00[2].lgdtip,
                             a_cts09m00[2].lgdnom,
                             a_cts09m00[2].lgdnum,
                             a_cts09m00[2].lgdcep,
                             a_cts09m00[2].lgdcepcmp,
                             a_cts09m00[2].lclltt,
                             a_cts09m00[2].lcllgt,
                             a_cts09m00[2].lclrefptotxt,
                             a_cts09m00[2].lclcttnom,
                             a_cts09m00[2].dddcod,
                             a_cts09m00[2].lcltelnum,
                             a_cts09m00[2].c24lclpdrcod,
                             a_cts09m00[2].ofnnumdig,
                             a_cts09m00[2].celteldddcod   ,
                             a_cts09m00[2].celtelnum,
                             a_cts09m00[2].endcmp,
                             hist_cts09m00.*,
                             a_cts09m00[2].emeviacod)
                   returning a_cts09m00[2].lclidttxt,
                             a_cts09m00[2].cidnom,
                             a_cts09m00[2].ufdcod,
                             a_cts09m00[2].brrnom,
                             a_cts09m00[2].lclbrrnom,
                             a_cts09m00[2].endzon,
                             a_cts09m00[2].lgdtip,
                             a_cts09m00[2].lgdnom,
                             a_cts09m00[2].lgdnum,
                             a_cts09m00[2].lgdcep,
                             a_cts09m00[2].lgdcepcmp,
                             a_cts09m00[2].lclltt,
                             a_cts09m00[2].lcllgt,
                             a_cts09m00[2].lclrefptotxt,
                             a_cts09m00[2].lclcttnom,
                             a_cts09m00[2].dddcod,
                             a_cts09m00[2].lcltelnum,
                             a_cts09m00[2].c24lclpdrcod,
                             a_cts09m00[2].ofnnumdig,
                             a_cts09m00[2].celteldddcod   ,
                             a_cts09m00[2].celtelnum,
                             a_cts09m00[2].endcmp,
                             ws.retflg,
                             hist_cts09m00.*,
                             a_cts09m00[2].emeviacod
            end if

            #Projeto alteracao cadastro de destino
            let m_grava_hist = false

            if g_documento.acao = "ALT" then

               call cts09m00_verifica_tipo_atendim()
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
                        call cts09m00_verifica_op_ativa()
                           returning l_status

                        if l_status then

                           error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                           error " Servico ja' acionado nao pode ser alterado!"
                           let m_srv_acionado = true
                           call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                             " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                 "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                                returning ws.confirma

                           call cts09m00_bkp_info_dest(2, hist_cts09m00.*)
                              returning hist_cts09m00.*

                           next field frmflg

                        else

                           let m_grava_hist   = true
                           let m_srv_acionado = false

                           let m_subbairro[2].lclbrrnom = a_cts09m00[2].lclbrrnom
                           call cts06g10_monta_brr_subbrr(a_cts09m00[2].brrnom,
                                                          a_cts09m00[2].lclbrrnom)
                              returning a_cts09m00[2].lclbrrnom

                           let a_cts09m00[2].lgdtxt = a_cts09m00[2].lgdtip clipped, " ",
                                                      a_cts09m00[2].lgdnom clipped, " ",
                                                      a_cts09m00[2].lgdnum using "<<<<#"

                           if a_cts09m00[2].lclltt <> a_cts09m00[3].lclltt or
                              a_cts09m00[2].lcllgt <> a_cts09m00[3].lcllgt or
                              (a_cts09m00[3].lclltt is null and a_cts09m00[2].lclltt is not  null) or
                              (a_cts09m00[3].lcllgt is null and a_cts09m00[2].lcllgt is not null) then

                              call cts00m33(1,
                                            a_cts09m00[1].lclltt,
                                            a_cts09m00[1].lcllgt,
                                            a_cts09m00[2].lclltt,
                                            a_cts09m00[2].lcllgt)
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
                               if w_cts09m00.socvclcod is null then
                                  select socvclcod 
                                    into w_cts09m00.socvclcod
                                    from datmsrvacp acp 
                                   where acp.atdsrvnum = g_documento.atdsrvnum
                                     and acp.atdsrvano = g_documento.atdsrvano
                                     and acp.atdsrvseq = (select max(atdsrvseq)
                                                            from datmsrvacp acp1
                                                           where acp1.atdsrvnum = acp.atdsrvnum
                                                             and acp1.atdsrvano = acp.atdsrvano)
                               end if    
                               
                         #      display 'w_cts09m00.socvclcod ', w_cts09m00.socvclcod 

                                    select mdtcod
                                    into m_mdtcod
                                    from datkveiculo
                                    where socvclcod = w_cts09m00.socvclcod

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
                                    and cpocod = w_cts09m00.vclcorcod

                                    select empnom
                                    into l_ciaempnom
                                    from gabkemp
                                    where empcod  = g_documento.ciaempcod


                                    whenever error stop

                                    let l_dtalt = today
                                    let l_hralt = current
                                    let l_lgdtxtcl = a_cts09m00[2].lgdtip clipped, " ",
                                                     a_cts09m00[2].lgdnom clipped, " ",
                                                     a_cts09m00[2].lgdnum using "<<<<#", " ",
                                                     a_cts09m00[2].endcmp clipped


                                    let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                                  l_ciaempnom clipped,
                                                  '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             		  	    let l_msgaltend = l_texto clipped
                                      ," QRU: ", m_atdsrvorg using "&&"
                                           ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                           ,"-", g_documento.atdsrvano using "&&"
                                      ," QTR: ", l_dtalt, " ", l_hralt
                                      ," QNC: ", d_cts09m00.nom             clipped, " "
                                               , d_cts09m00.vcldes          clipped, " "
                                               , d_cts09m00.vclanomdl       clipped, " "
                                      ," QNR: ", d_cts09m00.vcllicnum       clipped, " "
                                               , l_vclcordes       clipped, " "
                                      ," QTI: ", a_cts09m00[2].lclidttxt       clipped, " - "
                                               , l_lgdtxtcl                 clipped, " - "
                                               , a_cts09m00[2].brrnom          clipped, " - "
                                               , a_cts09m00[2].cidnom          clipped, " - "
                                               , a_cts09m00[2].ufdcod          clipped, " "
                                      ," Ref: ", a_cts09m00[2].lclrefptotxt    clipped, " "
                                     ," Resp: ", a_cts09m00[2].lclcttnom       clipped, " "
                                     ," Tel: (", a_cts09m00[2].dddcod          clipped, ") "
                                               , a_cts09m00[2].lcltelnum       clipped, " "
          #                         ," Acomp: ", d_cts09m00.rmcacpflg          clipped, "#"


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

                        call cts09m00_bkp_info_dest(2, hist_cts09m00.*)
                           returning hist_cts09m00.*

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

            let m_subbairro[2].lclbrrnom = a_cts09m00[2].lclbrrnom

            if a_cts09m00[2].cidnom is not null and
               a_cts09m00[2].ufdcod is not null then
               call cts14g00 (d_cts09m00.c24astcod,
                              "","","","",
                              a_cts09m00[2].cidnom,
                              a_cts09m00[2].ufdcod,
                              "S",
                              ws.dtparam)
            end if

         end if
      end if

   on key (F9)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts09m00.atdlibflg = "N"  then
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

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts09m00.* to null
 end if

 return hist_cts09m00.*

end function  ###  input_cts09m00


#-----------------------------------------------------------------------------#
function cts09m00a()
#-----------------------------------------------------------------------------#

   define l_cts09m00a array[500]of record
      sgdnom      char(40)
    , sgdirbcod   decimal(4,0)
   end record

   define l_i    integer

   -- [ INICIALIZAR VARIAVEL ] --

	define	w_pf1	integer

	let	l_i  =  null

	for	w_pf1  =  1  to  500
		initialize  l_cts09m00a[w_pf1].*  to  null
	end	for

   for l_i = 2 to 500
   initialize l_cts09m00a[1].* to null
       let l_cts09m00a[l_i].* = l_cts09m00a[1].*
   end for


   # Somente Porto e Azul Seguros Conforme pedido da Judite Esteves 13/03/2009

   declare c_cts09m00_003 cursor for
   select unique(a.sgdirbcod)
        , b.sgdnom
     from srpmsgdapl a
        , gcckcong   b
    where a.sgdirbcod = b.sgdirbcod
    and a.sgdirbcod = 5355
    order by sgdnom

   let l_i   = 1
   let l_cts09m00a[l_i].sgdirbcod = 01
   let l_cts09m00a[l_i].sgdnom    = "PORTO SEGURO"
   let l_i = l_i + 1

   foreach c_cts09m00_003 into l_cts09m00a[l_i].sgdirbcod
                         , l_cts09m00a[l_i].sgdnom
       let l_i = l_i + 1

       if l_i > 500 then
          error "ARRAY SUPEROU O NUMERO DE LINHAS RESERVADAS! "
          exit foreach
       end if

   end foreach

   call set_count(l_i - 1)

   if l_i = 1 then
      error 'nAO HA CONGENERES'
      sleep 03
      return "",""
   else
      open window w_cts09m00a at 5,20 with form 'cts09m00a'
         attribute (border,form line first)

         display array l_cts09m00a to s_cts09m00a.*
            on key(f8)
               let l_i = arr_curr()
               if l_cts09m00a[l_i].sgdirbcod = 1 then
                  let l_cts09m00a[l_i].sgdirbcod = 5886  # porto seguro
               end if
               exit display

            on key(interrupt,f17,control-c)
               exit display

         end display

         if int_flag = true then
            let int_flag = false
            close window w_cts09m00a
            return "", ""
         end if

      close window w_cts09m00a
   end if

   return l_cts09m00a[l_i].sgdnom
        , l_cts09m00a[l_i].sgdirbcod

end function

#--------------------------#
function cts09m00_display()
#--------------------------#

   display by name d_cts09m00.servico
   display by name d_cts09m00.c24solnom attribute (reverse)
   display by name d_cts09m00.nom
   display by name d_cts09m00.doctxt
   display by name d_cts09m00.corsus
   display by name d_cts09m00.cornom
   display by name d_cts09m00.cvnnom    attribute (reverse)
   display by name d_cts09m00.vclcoddig
   display by name d_cts09m00.vcldes
   display by name d_cts09m00.vclanomdl
   display by name d_cts09m00.vcllicnum
   display by name d_cts09m00.vclcordes
   display by name d_cts09m00.c24astcod
   display by name d_cts09m00.c24astdes
   display by name d_cts09m00.camflg
   display by name d_cts09m00.asitipcod
   display by name d_cts09m00.asitipabvdes
   display by name d_cts09m00.dstflg
   display by name d_cts09m00.imdsrvflg
   display by name d_cts09m00.atdprinvlcod
   display by name d_cts09m00.atdprinvldes
   display by name d_cts09m00.atdlibflg
   display by name d_cts09m00.frmflg
   display by name d_cts09m00.atdtxt
   display by name d_cts09m00.atdlibdat
   display by name d_cts09m00.atdlibhor

end function

#--------------------------------------------------------#
 function cts09m00_bkp_info_dest(l_tipo, hist_cts09m00)
#--------------------------------------------------------#
  define hist_cts09m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts09m00_bkp      to null
     initialize m_hist_cts09m00_bkp to null

     let a_cts09m00_bkp[1].lclidttxt    = a_cts09m00[2].lclidttxt
     let a_cts09m00_bkp[1].cidnom       = a_cts09m00[2].cidnom
     let a_cts09m00_bkp[1].ufdcod       = a_cts09m00[2].ufdcod
     let a_cts09m00_bkp[1].brrnom       = a_cts09m00[2].brrnom
     let a_cts09m00_bkp[1].lclbrrnom    = a_cts09m00[2].lclbrrnom
     let a_cts09m00_bkp[1].endzon       = a_cts09m00[2].endzon
     let a_cts09m00_bkp[1].lgdtip       = a_cts09m00[2].lgdtip
     let a_cts09m00_bkp[1].lgdnom       = a_cts09m00[2].lgdnom
     let a_cts09m00_bkp[1].lgdnum       = a_cts09m00[2].lgdnum
     let a_cts09m00_bkp[1].lgdcep       = a_cts09m00[2].lgdcep
     let a_cts09m00_bkp[1].lgdcepcmp    = a_cts09m00[2].lgdcepcmp
     let a_cts09m00_bkp[1].lclltt       = a_cts09m00[2].lclltt
     let a_cts09m00_bkp[1].lcllgt       = a_cts09m00[2].lcllgt
     let a_cts09m00_bkp[1].lclrefptotxt = a_cts09m00[2].lclrefptotxt
     let a_cts09m00_bkp[1].lclcttnom    = a_cts09m00[2].lclcttnom
     let a_cts09m00_bkp[1].dddcod       = a_cts09m00[2].dddcod
     let a_cts09m00_bkp[1].lcltelnum    = a_cts09m00[2].lcltelnum
     let a_cts09m00_bkp[1].c24lclpdrcod = a_cts09m00[2].c24lclpdrcod
     let a_cts09m00_bkp[1].ofnnumdig    = a_cts09m00[2].ofnnumdig
     let a_cts09m00_bkp[1].celteldddcod = a_cts09m00[2].celteldddcod
     let a_cts09m00_bkp[1].celtelnum    = a_cts09m00[2].celtelnum
     let a_cts09m00_bkp[1].endcmp       = a_cts09m00[2].endcmp
     let m_hist_cts09m00_bkp.hist1      = hist_cts09m00.hist1
     let m_hist_cts09m00_bkp.hist2      = hist_cts09m00.hist2
     let m_hist_cts09m00_bkp.hist3      = hist_cts09m00.hist3
     let m_hist_cts09m00_bkp.hist4      = hist_cts09m00.hist4
     let m_hist_cts09m00_bkp.hist5      = hist_cts09m00.hist5
     let a_cts09m00_bkp[1].emeviacod    = a_cts09m00[2].emeviacod

     return hist_cts09m00.*

  else

     let a_cts09m00[2].lclidttxt    = a_cts09m00_bkp[1].lclidttxt
     let a_cts09m00[2].cidnom       = a_cts09m00_bkp[1].cidnom
     let a_cts09m00[2].ufdcod       = a_cts09m00_bkp[1].ufdcod
     let a_cts09m00[2].brrnom       = a_cts09m00_bkp[1].brrnom
     let a_cts09m00[2].lclbrrnom    = a_cts09m00_bkp[1].lclbrrnom
     let a_cts09m00[2].endzon       = a_cts09m00_bkp[1].endzon
     let a_cts09m00[2].lgdtip       = a_cts09m00_bkp[1].lgdtip
     let a_cts09m00[2].lgdnom       = a_cts09m00_bkp[1].lgdnom
     let a_cts09m00[2].lgdnum       = a_cts09m00_bkp[1].lgdnum
     let a_cts09m00[2].lgdcep       = a_cts09m00_bkp[1].lgdcep
     let a_cts09m00[2].lgdcepcmp    = a_cts09m00_bkp[1].lgdcepcmp
     let a_cts09m00[2].lclltt       = a_cts09m00_bkp[1].lclltt
     let a_cts09m00[2].lcllgt       = a_cts09m00_bkp[1].lcllgt
     let a_cts09m00[2].lclrefptotxt = a_cts09m00_bkp[1].lclrefptotxt
     let a_cts09m00[2].lclcttnom    = a_cts09m00_bkp[1].lclcttnom
     let a_cts09m00[2].dddcod       = a_cts09m00_bkp[1].dddcod
     let a_cts09m00[2].lcltelnum    = a_cts09m00_bkp[1].lcltelnum
     let a_cts09m00[2].c24lclpdrcod = a_cts09m00_bkp[1].c24lclpdrcod
     let a_cts09m00[2].ofnnumdig    = a_cts09m00_bkp[1].ofnnumdig
     let a_cts09m00[2].celteldddcod = a_cts09m00_bkp[1].celteldddcod
     let a_cts09m00[2].celtelnum    = a_cts09m00_bkp[1].celtelnum
     let a_cts09m00[2].endcmp       = a_cts09m00_bkp[1].endcmp
     let hist_cts09m00.hist1        = m_hist_cts09m00_bkp.hist1
     let hist_cts09m00.hist2        = m_hist_cts09m00_bkp.hist2
     let hist_cts09m00.hist3        = m_hist_cts09m00_bkp.hist3
     let hist_cts09m00.hist4        = m_hist_cts09m00_bkp.hist4
     let hist_cts09m00.hist5        = m_hist_cts09m00_bkp.hist5
     let a_cts09m00[2].emeviacod    = a_cts09m00_bkp[1].emeviacod

     return hist_cts09m00.*

  end if

end function

#-----------------------------------------#
 function cts09m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open c_cts09m00_004 using g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano

  whenever error continue
  fetch c_cts09m00_004 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT c_cts09m00_004: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts09m00() / C24 / cts09m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts09m00_verifica_op_ativa()
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
 function cts09m00_grava_historico()
#-----------------------------------------#
  define la_cts09m00       array[12] of record
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

  initialize la_cts09m00  to null
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

  let la_cts09m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts09m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts09m00[03].descricao = "."
  let la_cts09m00[04].descricao = "DE:"
  let la_cts09m00[05].descricao = "CEP: ", a_cts09m00_bkp[1].lgdcep clipped," - ",a_cts09m00_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts09m00_bkp[1].cidnom clipped," UF: ",a_cts09m00_bkp[1].ufdcod clipped
  let la_cts09m00[06].descricao = "Logradouro: ",a_cts09m00_bkp[1].lgdtip clipped," ",a_cts09m00_bkp[1].lgdnom clipped," "
                                                ,a_cts09m00_bkp[1].lgdnum clipped," ", a_cts09m00_bkp[1].brrnom
  let la_cts09m00[07].descricao = "."
  let la_cts09m00[08].descricao = "PARA:"
  let la_cts09m00[09].descricao = "CEP: ", a_cts09m00[2].lgdcep clipped," - ", a_cts09m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts09m00[2].cidnom clipped," UF: ",a_cts09m00[2].ufdcod  clipped
  let la_cts09m00[10].descricao = "Logradouro: ",a_cts09m00[2].lgdtip clipped," ",a_cts09m00[2].lgdnom clipped," "
                                                ,a_cts09m00[2].lgdnum clipped," ",a_cts09m00[2].brrnom
  let la_cts09m00[11].descricao = "."
  let la_cts09m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts09m00[l_ind].descricao
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
  let lr_de.lgdcep    = a_cts09m00_bkp[1].lgdcep clipped,"-",a_cts09m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts09m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts09m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts09m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts09m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts09m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts09m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts09m00[2].lgdcep clipped,"-", a_cts09m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts09m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts09m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts09m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts09m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts09m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts09m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function
