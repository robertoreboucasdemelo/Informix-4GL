#############################################################################
# Nome do Modulo: CTS00M02                                         Pedro    #
#                                                                  Marcelo  #
# Conclusao do Servico                                             Dez/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 24/01/2001  PSI 12018-7  Wagner       Inclusao da funcao que envia a      #
#                                       referencia do endereco por Teletrim #
#---------------------------------------------------------------------------#
# 12/02/2001  PSI 12537-7  Wagner       Inclusao do acesso a funcao que     #
#                                       envia servico p/viaturas RE.        #
#---------------------------------------------------------------------------#
# 23/04/2001  PSI 12955-0  Marcus       Inclusao da funcao de calculo de pre#
#                                       visao automatica para Socorrista    #
#---------------------------------------------------------------------------#
# 08/05/2001  PSI 13241-1  Marcus       Campo Previsao e Distancia          #
#---------------------------------------------------------------------------#
# 05/07/2001  PSI 11153-8  Raji         Acionamento JIT origem 15           #
#---------------------------------------------------------------------------#
# 04/09/2001  PSI 13622-0  Marcus       Conclusao pela Internet             #
#---------------------------------------------------------------------------#
# 19/03/2002  PSI 15001-0  Marcus       Acionamento via Mapa para servicos  #
#                                       sem coordenadas                     #
#---------------------------------------------------------------------------#
# 18/05/2002  PSI 15456-3  Wagner       Alteracao para envio mdt viaturas RE#
#---------------------------------------------------------------------------#
# 30/08/2002  PSI 14179-8  Ruiz         Acionamento sinstro transportes.    #
#---------------------------------------------------------------------------#
# 09/09/2002  PSI 15918-2  Wagner       Acionamento RET                     #
#---------------------------------------------------------------------------#
# 09/12/2002  PSI 16393-3  Wagner       Alteracao nos limites dos servicos  #
#---------------------------------------------------------------------------#
# 17/12/2002  CORREIO      Wagner       Acionar teletrim bases litoral      #
#---------------------------------------------------------------------------#
# 24/03/2003  OSF1512-1    Paula(Fabrica) Habilitar o envio de pager/mdt p/ #
#             PSI 16996-0                 serviços JIT                      #
#...........................................................................#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 18/09/2003  OSF26522     Marcelo(Meta) Alterar para que somente servicos  #
#             PSI178381                  JIT e viatura sem MDT/WVT instalado#
#                                        envie mensagem via pager           #
#---------------------------------------------------------------------------#
# 15/10/2003 Gustavo, Meta     PSI168912  Atualizar o tipo de envio quando  #
#                              OSF27537   o campo d_cts00m02.envtipcod nao  #
#                                         for nulo.                         #
#---------------------------------------------------------------------------#
# 21/10/2003  OSF25143     Teresinha S.   Padronizar a entrada do tipo de   #
#             PSI 170585                  veiculo para os servicos de taxi  #
#---------------------------------------------------------------------------#
# 21/11/2003 Gustavo, Meta     PSI179345  Se existir demanda ativa, devera  #
#                              OSF028851  abrir esta tela com as informacoes#
#                                         ja preenchidas e digitar somente  #
#                                         o tipo de envio.                  #
#---------------------------------------------------------------------------#
# 03/02/2004 Mariana, Fabrica  OSF 31682  Inclusao da funcao cta11m00 p/    #
#                                         etapa 38 (recusado)               #
#                                                                           #
# ---------- ----------------- ---------- -----------------------------------#
# 01/09/2004 Robson, Meta      PSI186406  Alterada chamada a cts10g04_max_seq#
#----------------------------------------------------------------------------#
# 06/11/2004 Farias, EME       CH4095228  Calcula distancia no acionamento   #
#                                         d_cts00m02.atdetpcod = 4           #
#----------------------------------------------------------------------------#
# 11/01/2005 Helio (Meta)      PSI190250  Ajustes Gerais                     #
#----------------------------------------------------------------------------#
# 18/05/2005 Adriano, Meta     PSI191108  Imcluir o campo emeviacod no record#
#                                         a_cts00m02 na funcao cts00m02()    #
#----------------------------------------------------------------------------#
# 06/06/2005 James, Meta       PSI189790  Chamar ctx04g00_local_completo p/  #
#                                         comparar com o endereco do outro   #
#                                         servico encontrado.                #
#----------------------------------------------------------------------------#
# 14/06/2005 Andrei, Meta      PSI189790  Chamar funcao cts29g00_obter_qtd_  #
#                                         multiplo. Alterar chamada de       #
#                                         cts08g01                           #
#----------------------------------------------------------------------------#
# 15/09/2005 Andrei, Meta      AS87408    Incluir chamada da funcao cts01g01_#
#                                         setetapa                           #
#----------------------------------------------------------------------------#
# 26/10/2005 Priscila          PSI195138  Copiar dados do prestador no       #
#                                         retorno, apenas qdo foi solicitado #
#                                         mesmo prestador                    #
#----------------------------------------------------------------------------#
# 17/02/2006 Tiago Solda, Meta PSI196878  Alteracao nas informacoes de assis-#
#                                         tencia a passageiros               #
#----------------------------------------------------------------------------#
# 02/05/2006 Priscila          PSI198714  Enviar SMS ao segurado no momento  #
#                                         do acionamento                     #
#----------------------------------------------------------------------------#
# 09/06/2006 Cristiane Silva   PSI201022  Permitir acionamento de prestador  #
#                                         diferente do prestador original em #
#                                         casos de retorno - RE              #
#----------------------------------------------------------------------------#
# 10/11/2006 Priscila Staingel AS         Chamar funcao para acessar         #
#                                         datrcidsed                         #
# 14/02/2007 Ligia Mattge                 Chamar cta00m08_ver_contingencia   #
#----------------------------------------------------------------------------#
# 15/05/2007 Eduardo Vieira   PSI208744   Tipo de Envio de Serviços - Rádio  #
#----------------------------------------------------------------------------#
# 20/04/2007 Fabiano Santos   PSI208094   Chamar ctb00g10_verifica_prest     #
#----------------------------------------------------------------------------#
# 03/07/2007 Burini          Isabel     Buscar o ultimo prestador da ultima  #
#                                       sequencia de retorno, ao inves de    #
#                                       buscar o prestador da origem         #
#----------------------------------------------------------------------------#
# 18/07/2008 Andre Pinto     Chamado    Liberacao do campo 'atdvclsgl' quando#
#      txivlr tiver algum valor             #
#----------------------------------------------------------------------------#
# 12/09/2008 Andre Pinto    PSI221635   Retirada da função regulador e passado#
#                                       para o modulo ctc59m03               #
#----------------------------------------------------------------------------#
# 05/04/2009 Adriano Santos PSI240540   Inclusao dos campos referentes a     #
#                                       ultima msg para o prest              #
#----------------------------------------------------------------------------#
# 18/05/2009 Adriano Santos PSI241407   Inclusao do atalho F4 para o posicio-#
#                                       namento da viatura no servico        #
# 27/04/2010 Adriano Santos PSI242853   Trata acionamento quando prestador   #
#                                       esta na etapa liberado e aciona srv  #
#                                       PSS pela internet mesmo prs offline  #
#                                                                            #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca              #
#----------------------------------------------------------------------------#


globals  "/homedsa/projetos/geral/globals/glct.4gl"



define  m_cts00m02_prep  smallint,     ### PSI168912
        m_cts00m02_prep2 smallint,
        m_atdfnlflg     like datmservico.atdfnlflg,
        m_descricao     char(50),
        m_servico       char(15),
        m_mensagem      char(2000),
        m_rota          char(32000),
        m_hostname      like ibpkdbspace.srvnom

  define am_cts29g00  array[10] of record
         atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano like datratdmltsrv.atdmltsrvano,
         socntzdes    like datksocntz.socntzdes,
         espdes            like dbskesp.espdes,
         atddfttxt    like datmservico.atddfttxt
  end record

###
### Inicio PSI168912
###
#------------------------------#
 function cts00m02_prepare()
#------------------------------#

 define l_sql_stmt  char(800)

 ### Inicio
 let l_sql_stmt =  "  select max(atdsrvseq) "
                  ,"    from datmsrvacp     "
                  ,"   where atdsrvnum = ?  "
                  ,"     and atdsrvano = ?  "

 prepare p_cts00m02_001 from l_sql_stmt
 declare c_cts00m02_001 cursor for p_cts00m02_001
 ### Fim


 ### Inicio
 let l_sql_stmt =   "   update datmsrvacp      "
                   ,"      set envtipcod = ?  "
                   ,"    where atdsrvnum  = ?  "
                   ,"      and atdsrvano  = ?  "
                   ,"      and atdsrvseq  = ?  "

 prepare p_cts00m02_002 from l_sql_stmt
 ### Fim

 ### Inicio
 let l_sql_stmt =   "   update datmservico     "
                   ,"      set (socvclcod,     "
                   ,"           srrcoddig,     "
                   ,"           srrltt,        "
                   ,"           srrlgt)   =    "
                   ,"          (?,?,?,?)       "
                   ,"    where atdsrvnum  = ?  "
                   ,"      and atdsrvano  = ?  "

 prepare p_cts00m02_003 from l_sql_stmt
 ### Fim

 let l_sql_stmt = "update datmsrvacp  ",
                  "   set srvrcumtvcod = ? ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? ",
                  "   and atdsrvseq = ? "

 prepare p_cts00m02_004 from l_sql_stmt

 let l_sql_stmt = " update datmservico set ",
                        " (socvclcod, ",
                         " srrcoddig, ",
                         " srrltt, ",
                         " srrlgt, ",
                         " atdprvdat) = ",
                        " (null, ",
                         " null, ",
                         " null, ",
                         " null, ",
                         " null) ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "

 prepare p_cts00m02_005 from l_sql_stmt

 let l_sql_stmt = " select atdprscod, ",
                         " atdmotnom, ",
                         " atdvclsgl, ",
                         " atdfnlflg, ",
                         " c24opemat, ",
                         " cnldat, ",
                         " atdfnlhor, ",
                         " c24nomctt, ",
                         " atdpvtretflg, ",
                         " atdsrvorg, ",
                         " asitipcod, ",
                         " atdcstvlr, ",
                         " atddat, ",
                         " atddatprg, ",
                         " sindat, ",
                         " sinhor, ",
                         " socvclcod, ",
                         " srrcoddig, ",
                         " atdprvdat, ",
                         " srrltt, ",
                         " srrlgt, ",
                         " prslocflg, ",
                         " txivlr, ",
                         " ciaempcod ",
                    " from datmservico a, ",
                         " outer datmservicocmp b, ",
                         " outer datmassistpassag c ",
                   " where a.atdsrvnum = ? ",
                     " and a.atdsrvano = ? ",
                     " and b.atdsrvnum = a.atdsrvnum ",
                     " and b.atdsrvano = a.atdsrvano ",
                     " and c.atdsrvnum = a.atdsrvnum ",
                     " and c.atdsrvano = a.atdsrvano "

 prepare p_cts00m02_006 from l_sql_stmt
 declare c_cts00m02_002 cursor for p_cts00m02_006

 let l_sql_stmt = " select atdsrvnum ",
                    " from datmligacao ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? ",
                     " and c24astcod = 'CAN' "

 prepare p_cts00m02_007 from l_sql_stmt
 declare c_cts00m02_003 cursor for p_cts00m02_007

 let l_sql_stmt = " select aerciacod ",
                    " from datmtrppsgaer ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and vooopc = ? "

 prepare p_cts00m02_008 from l_sql_stmt
 declare c_cts00m02_004 cursor for p_cts00m02_008

 let m_cts00m02_prep = true

 let l_sql_stmt =  "  select max(atdsrvseq) "
                  ,"    from datmsrvacp     "
                  ,"   where atdsrvnum = ?  "
                  ,"     and atdsrvano = ?  "

 prepare p_cts00m02_009 from l_sql_stmt
 declare c_cts00m02_005 cursor for p_cts00m02_009

 let l_sql_stmt =  "  select funmat, empcod, envtipcod "
                  ,"    from datmsrvacp     "
                  ,"   where atdsrvnum = ?  "
                  ,"     and atdsrvano = ?  "
                  ,"     and atdsrvseq = ?  "

 prepare p_cts00m02_010 from l_sql_stmt
 declare c_cts00m02_006 cursor for p_cts00m02_010

 let l_sql_stmt = " select atdfnlflg, ",
                         " acnsttflg, ",
                         " atdlibflg ",
                    " from datmservico ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "

  prepare p_cts00m02_011 from l_sql_stmt
  declare c_cts00m02_007 cursor for p_cts00m02_011

## Pegar servico jah enviado via fax - PSI208744

 let l_sql_stmt = " select faxsiscod ",
                    " from datmfax ",
                    " where faxch1 = ? "

  prepare p_cts00m02_012 from l_sql_stmt
  declare c_cts00m02_008 cursor for p_cts00m02_012



 let l_sql_stmt =   "select envtipcod ",
                     "from datmsrvacp ",
                     "where atdsrvnum = ? ",
                     "and   atdsrvano = ? ",
                     "and atdsrvseq = ( select max(atdsrvseq) ",
                     "from datmsrvacp ",
                     "where atdsrvnum = ? ",
                     "and atdsrvano = ?) "

  prepare p_cts00m02_013 from l_sql_stmt
  declare c_cts00m02_009 cursor for p_cts00m02_013


  let l_sql_stmt = "select count(*) ",
                   " from iddkdominio ",
                   " where cponom = 'acessotfp' ",
                   " and cpodes = ? "
  prepare p_cts00m02_014 from l_sql_stmt
  declare c_cts00m02_010 cursor for p_cts00m02_014

  let l_sql_stmt =  ' select mdtbotprgseq, v.mdtcod, v.socvclcod              '
                   ,'   from datmmdtmvt m, datkveiculo v                      '
                   ,'  where m.mdtcod = v.mdtcod                              '
                   ,'    and mdtmvtseq in (select max(mdtmvtseq)              '
                   ,'                        from datmmdtmvt m2               '
                   ,'                       where m2.atdsrvnum = ?            '
                   ,'                         and m2.atdsrvano = ?            '
                   ,'                         and m2.mdtmvttipcod = 2         '
                   ,'                         and m2.mdtbotprgseq in (1,2,3,14)) '
  prepare p_cts00m02_015 from l_sql_stmt
  declare c_cts00m02_011 cursor for p_cts00m02_015

  let l_sql_stmt =  ' select mdtmvtseq, caddat, cadhor, lclltt, lcllgt   '
                   ,'   from datmmdtmvt                                  '
                   ,'  where mdtmvtseq in (select max(mdtmvtseq)         '
                   ,'                        from datmmdtmvt             '
                   ,'                       where mdtcod = ? )           '
  prepare p_cts00m02_016 from l_sql_stmt
  declare c_cts00m02_012 cursor for p_cts00m02_016

  let l_sql_stmt =  '   select lclltt, lcllgt,      '
                   ,'          ufdcod, c24lclpdrcod '
                   ,'     from datmlcl              '
                   ,'    where atdsrvnum = ?        '
                   ,'      and atdsrvano = ?        '
                   ,'      and c24endtip = 1        '
  prepare p_cts00m02_017 from l_sql_stmt
  declare c_cts00m02_013 cursor for p_cts00m02_017

  let l_sql_stmt =  'select 1                                           '
                   ,'  from datmmdtmsg m                                '
                   ,'      ,datmmdtlog l                                '
                   ,'      ,datmmdtmsgtxt t                             '
                   ,' where m.mdtcod    = ?                             '
                   ,'   and m.mdtmsgnum = l.mdtmsgnum                   '
                   ,'   and m.mdtmsgnum = t.mdtmsgnum                   '
                   ,'   and l.atldat  = ?                               ' # today
                   ,'   and l.atlhor >= ? - 5 units minute              ' # extend(current, hour to minute)
                   ,'   and t.mdtmsgtxt like "%posicionamento."         '
  prepare p_cts00m02_018 from l_sql_stmt
  declare c_cts00m02_014 cursor for p_cts00m02_018

  let l_sql_stmt =  '   select atdvclsgl     '
                   ,'     from datkveiculo   '
                   ,'    where socvclcod = ? '
  prepare p_cts00m02_019 from l_sql_stmt
  declare c_cts00m02_015 cursor for p_cts00m02_019

  let l_sql_stmt =  ' select mdtmvtseq, caddat, cadhor, lclltt, lcllgt  '
                   ,'   from datmmdtmvt                                 '
                   ,'  where mdtmvtseq in (select max(mdtmvtseq)        '
                   ,'                        from datmmdtmvt            '
                   ,'                       where mdtcod = ?            '
                   ,'                         and mdtmvtseq < ? )       '
  prepare p_cts00m02_020 from l_sql_stmt
  declare c_cts00m02_016 cursor for p_cts00m02_020

  let l_sql_stmt =  '   select 1 '
                   ,'     from datkdominio '
                   ,'    where cponom = ? '
                   ,'      and cpodes = ? '
  prepare p_cts00m02_025 from l_sql_stmt
  declare c_cts00m02_025 cursor for p_cts00m02_025


##
 end function

#--------------------------------------------------------------------
 function cts00m02_prepare2()
#--------------------------------------------------------------------

    define l_sql_stmt  char(800)

    let l_sql_stmt = "select b.sinntzgrpcod            ",
                     "  from sstmstpavs a, ssttntzgrp b",
                     " where a.sinntzcod = b.sinntzcod ",
                     "   and b.sinramgrp = 2           ",
                     "   and sinavsnum   = ?           "

    prepare p_cts00m02_021 from l_sql_stmt
    declare c_cts00m02_017 cursor for p_cts00m02_021

    let m_cts00m02_prep2 = true

 end function

#--------------------------------------------------------------------
 function cts00m02(param)
#--------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    flg_origem       smallint   # flag indicando qdo o acionamento e via
                                # atendente. 1=atendente, 0=radio, 2=Outros
 end record

 define d_cts00m02   record
    cnldat           like datmservico.cnldat,
    atdfnlhor        char (05),
    operador         like isskfunc.funnom,
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetpdes        like datketapa.atdetpdes,
    retorno          char (20),
    envio            char (08),
    atdprscod        like dpaksocor.pstcoddig,
    prsloc           char(8),
    nomgrr           like dpaksocor.nomgrr,
    cidufdprs        char (48),
    dddcod           like dpaksocor.dddcod,
    teltxt           like dpaksocor.teltxt,
    c24nomctt        like datmservico.c24nomctt,
    atdvclsgl        char(10), ###like datmservico.atdvclsgl,
    socvclcod        like datmservico.socvclcod,
    socvcldes        char (50),
    srrcoddig        like datmservico.srrcoddig,
    srrabvnom        like datksrr.srrabvnom,
    atdcstvlr        like datmservico.atdcstvlr,
    pasasivcldes     like datmtrptaxi.pasasivcldes,
    atdprvdat        like datmservico.atdprvdat,
    dstqtd           dec (8,4),
    envtipcod        dec  (1,0),
    atdimpcod        like datktrximp.atdimpcod,
    atdimpsit        like datktrximp.atdimpsit,
    impsitdes        char (13),
    mdtcod           like datkveiculo.mdtcod,
    srrltt           like datmservico.srrltt,
    srrlgt           like datmservico.srrlgt,
    txivlr           like datmassistpassag.txivlr,
    mdtmsgsttdes     char (26),
    atldat           like datmmdtlog.atldat,
    atlhor           like datmmdtlog.atlhor,
    rcbpor           char (6)
 end record

 define salva        record
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetptipcod     like datketapa.atdetptipcod,
    atdprscod        like dpaksocor.pstcoddig,
    srrcoddig        like datmservico.srrcoddig,
    atdvclsgl        like datmservico.atdvclsgl,
    cnldat           like datmservico.cnldat,
    socvclcod        like datkveiculo.socvclcod
 end record

 define ws           record
    endcidprs        like dpaksocor.endcid,
    endufdprs        like dpaksocor.endufd,
    faxnum           like dpaksocor.faxnum,
    lignum           like datmligacao.lignum,
    prssitcod        like dpaksocor.prssitcod,
    c24opemat        like datmservico.c24opemat,
    atdfnlhor        like datmservico.atdfnlhor,
    atdfnlflg        like datmservico.atdfnlflg,
    atdlibflg        like datmservico.atdlibflg,
    atdsrvorg        like datmservico.atdsrvorg,
    asitipcod        like datmservico.asitipcod,
    atdpvtretflg     like datmservico.atdpvtretflg,
    atdsrvretflg     like datmsrvre.atdsrvretflg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    socopgnum        like dbsmopg.socopgnum,
    pstcoddig        like dpaksocor.pstcoddig,
    atdcstvlr        like datmservico.atdcstvlr,
    maxcstvlr        like datmservico.atdcstvlr,
    c24atvcod        like dattfrotalocal.c24atvcod,
    atividade        like dattfrotalocal.c24atvcod,
    atddat           like datmservico.atddat,
    atddatprg        like datmservico.atddatprg,
    sindat           like datmservicocmp.sindat,
    sinhor           like datmservicocmp.sinhor,
    hpddiapvsqtd     like datmhosped.hpddiapvsqtd,
    vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod,
    ufdcod           like datmfrtpos.ufdcod,
    cidnom           like datmfrtpos.cidnom,
    brrnom           like datmfrtpos.brrnom,
    endzon           like datmfrtpos.endzon,
    socoprsitcod     like datkveiculo.socoprsitcod,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetptipcod     like datketapa.atdetptipcod,
    atdetppndflg     like datketapa.atdetppndflg,
    vclcoddig        like datkveiculo.vclcoddig,
    voocnxseq        like datmtrppsgaer.voocnxseq,
    srrcoddig        like datksrr.srrcoddig,
    srrstt           like datksrr.srrstt,
    mpacrglgdflg     like datkmpacid.mpacrglgdflg,
    gpsacngrpcod     like datkmpacid.gpsacngrpcod,
    transmite        smallint,
    fax              smallint,
    grvetpflg        smallint,
    grupo            smallint,
    sqlcode          integer,
    dataatu          date,
    alerta           char (40),
    confirma         char (01),
    retflg           char (01),
    operacao         char (01),
    vclctrposqtd     dec  (4,0),
    horaatu          char (05),
    horaatu1         datetime hour to second,
    erroflg          char (01),
    hst              char (01),
    flag_cts00m20    char (01),
    flagf7           char (01),
    flagf8           char (01),
    flagf9           char (01),
    ofnnumdig        like datmlcl.ofnnumdig,
    ofncrdflg        like sgokofi.ofncrdflg,
    mpacidcod        like dpaksocor.mpacidcod,
    atdetpseq        like datmsrvint.atdetpseq,
    intsrvrcbflg     like dpaksocor.intsrvrcbflg,
    atdetpcod        like datmsrvint.atdetpcod,
    etpmtvcod        like datksrvintmtv.etpmtvcod,
    etpmtvdes        like datksrvintmtv.etpmtvdes,
    result           integer,
    flagret          integer,
    c24astcod_ret    like datmligacao.c24astcod,
    atdorgsrvnum     like datmsrvre.atdorgsrvnum,
    atdorgsrvano     like datmsrvre.atdorgsrvano,
    pstcoddig_ori    like datmsrvacp.pstcoddig,
    srrcoddig_ori    like datmsrvacp.srrcoddig,
    socvclcod_ori    like datmsrvacp.socvclcod,
    atdvclsgl_ori    like datkveiculo.atdvclsgl,
    prslocflg        char(1),
    sinavsramcod     like sstmstpavs.sinavsramcod,
    sinavsano        like sstmstpavs.sinavsano,
    sinavsnum        like sstmstpavs.sinavsnum,
    sintraprstip     like sstkprest.sintraprstip,
    sinntzgrpcod     like ssttntzgrp.sinntzgrpcod,
    pgrnum           like datkveiculo.pgrnum,
    count            integer,
    prsdftant        char(1),
    atmacnflg        like datkassunto.atmacnflg,
    c24astcod        like datmligacao.c24astcod,
    c24funmat        like datmligacao.c24funmat,
    c24empcod        like datmligacao.c24empcod,
    ciaempcod        like datmligacao.ciaempcod,
    mdtbotprgseq_msg like datmmdtmvt.mdtbotprgseq,
    mdtcod_msg       like datmmdtmvt.mdtcod,
    mdtmvtseq_msg    like datmmdtmvt.mdtmvtseq,
    socvclcod_msg    like datkveiculo.socvclcod,
    atdvclsgl_msg    like datkveiculo.atdvclsgl,
    caddat_msg       like datmmdtmvt.caddat,
    cadhor_msg       like datmmdtmvt.cadhor,
    lclltt_msg       like datmmdtmvt.lclltt,
    lcllgt_msg       like datmmdtmvt.lcllgt,
    tmp_msg          interval hour(06) to minute,
    tipo_msg         smallint,
    lclltt_srv       like datmlcl.lclltt,
    lcllgt_srv       like datmlcl.lcllgt,
    ufdcod_srv       like datmlcl.ufdcod,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    atdhorpvt        like datmservico.atdhorpvt,
    atdhor           like datmservico.atdhor,
    atldat           like datmmdtlog.atldat,
    atlhor           like datmmdtlog.atlhor,
    c24opeempcod     like datmservico.c24opeempcod
 end record

 define a_cts00m02   array[3] of record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (65),
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    brrnom           like datmlcl.brrnom,
    lclbrrnom        like datmlcl.lclbrrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    lclltt           like datmlcl.lclltt,
    lcllgt           like datmlcl.lcllgt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    emeviacod        like datmlcl.emeviacod,
    ofnnumdig        like sgokofi.ofnnumdig,
    celteldddcod     like datmlcl.celteldddcod,
    celtelnum        like datmlcl.celtelnum,
    endcmp           like datmlcl.endcmp
 end record

 define a_voo        array[3] of record
    trpaerempnom     like datmtrppsgaer.trpaerempnom,
    trpaervoonum     like datmtrppsgaer.trpaervoonum,
    trpaerptanum     like datmtrppsgaer.trpaerptanum,
    trpaerlzdnum     like datmtrppsgaer.trpaerlzdnum,
    arpembcod        like datmtrppsgaer.arpembcod,
    trpaersaidat     like datmtrppsgaer.trpaersaidat,
    trpaersaihor     like datmtrppsgaer.trpaersaihor,
    arpchecod        like datmtrppsgaer.arpchecod,
    trpaerchedat     like datmtrppsgaer.trpaerchedat,
    trpaerchehor     like datmtrppsgaer.trpaerchehor
 end record

 define lr_cty28g00  record
   senha             char(04),
   coderro           smallint,
   msgerro           char(40)
 end record

 define l_cidsedcod    like datrcidsed.cidsedcod # PSI 205850
 define l_srvrcumtvcod like datksrvrcumtv.srvrcumtvcod
 define l_seq          integer
 define arr_aux      smallint
 define prompt_key   char (01)
 define ins_etapa    integer
 define ins_tempo_distancia integer
 define l_descveiculo char(07) --> OSF 25143
 define l_atdsrvseq  integer    ### PSI168912
 define l_demanda    smallint   ### PSI179345
       ,l_grlinf     smallint   ### PSI179345
       ,l_chave      char(11)   ### PSI179345
       ,l_erro       smallint   ### PSI179345
       ,l_aux        char(06)   ### PSI179345
       ,l_nullo      smallint #PSI186406 -Robson
       ,l_resultado  smallint #PSI186406 -Robson
       ,l_mensagem   char(60) #PSI186406 -Robson
       ,l_cmd        char(500)
       ,l_quantidade smallint
       ,l_flag_f8_f9 smallint
       ,l_atualiza_todos char(001)
       ,l_acao           char(001)
       ,l_aerciacod     like datmtrppsgaer.aerciacod
       ,l_vooopc        like datmtrppsgaer.vooopc
       ,l_retorno       smallint
       ,l_aerpsgrsrflg  like datkciaaer.aerpsgrsrflg
       ,l_aerpsgemsflg  like datkciaaer.aerpsgemsflg
       ,l_intsrvrcbflg  like dpaksocor.intsrvrcbflg
       ,l_contingencia  smallint
       ,l_acionamentoWEB smallint
       ,l_atznum        like datmsrvorc.atznum
       ,l_permissao     integer
       ,l_prest_conect  smallint
       ,l_atdvclsgl     like datkveiculo.atdvclsgl
       ,l_txttiptrx     char(10)
       ,l_auxqtd        smallint
       ,l_sincronizaAW  smallint

 define l_mens       record
        msg          char(200)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(100)
       ,cc           char(100)
 end record

 define l_atdsrvnum_original    like datmservico.atdsrvnum,
        l_atdsrvano_original    like datmservico.atdsrvano,
        l_contador              smallint,
        l_conta                 smallint,
        l_tipo_msg              smallint,
        l_sair                  smallint,
        l_c24astcod             like datmligacao.c24astcod,
        l_retprsmsmflg          like datmsrvre.retprsmsmflg, #PSI195138
        l_atdsrvnum_desassociar like datmservico.atdsrvnum,
        l_atdsrvano_desassociar like datmservico.atdsrvano

 define l_celdddcod_veic  like datkveiculo.celdddcod,
        l_celtelnum_veic  like datkveiculo.celtelnum,
        l_celdddcod_soco  like datksrr.celdddcod,
        l_celtelnum_soco  like datksrr.celtelnum,
        l_atdfnlflg       like datmservico.atdfnlflg,
        l_acnsttflg       like datmservico.acnsttflg,
        l_atdlibflg       like datmservico.atdlibflg,
        l_atdsrvnum       like datmservico.atdsrvnum,
        l_atdsrvano       like datmservico.atdsrvano,
        l_mdtcod          like datkveiculo.mdtcod   ,
        l_conf            smallint

 define srvano char(10)    ## PSI208744
 define faxsiscod char(2)
 define envio char(50)
 define envtipcodflg smallint
 define l_sql char(200)
 define l_status smallint
 define l_temp_lim interval hour(06) to minute
 define l_count smallint
 define l_lignum char(10)
 define l_senha  char(04)     
 define l_trava_f9 smallint

 define l_retposacnweb record
     srvidxflg char(1),
     recatddes char(50),
     srrnom    char(40),
     gpsatldat date,
     gpsatlhor datetime hour to second,
     recatdsgl char(3),
     lgdnom    char(50),
     lgdnum    integer,
     brrnom    char(30),
     cidnom    char(40),
     ufdsgl    char(2),
     lttnum    decimal(8,6),
     lgtnum    decimal(9,6),
     dstrot    integer,
     dstret    integer,
     tmprot    integer,
     telnumtxt char(20),
     nxtidt    char(20),
     nxtnumtxt char(20)
 end record

 let l_temp_lim = '0:05' # tempo limite do ultimo sinal valido (F4)

 let l_atdsrvnum = null
 let l_atdsrvano = null
 let l_atdfnlflg = null
 let l_acnsttflg = null
 let l_atdlibflg = null
 let l_atznum    = null
 let l_permissao = null

 if  g_setexplain = 1 then
     call cts01g01_setetapa("cts00m02 - Acionando/Cancelando servico")
 end if

 let m_atdfnlflg = null
 let l_atdsrvnum_original = null
 let l_atdsrvano_original = null
 let l_contador           = null
 let l_celdddcod_veic = null
 let l_celtelnum_veic = null
 let l_celdddcod_soco = null
 let l_celtelnum_soco = null
 let l_quantidade = 0
 let l_flag_f8_f9 = 0
 let m_descricao = null
 let l_contingencia = null
 let l_acionamentoWEB = null

        let     l_descveiculo  = null
        let     arr_aux  =  null
        let     prompt_key  =  null
        let     ins_etapa  =  null
        let     l_mdtcod  =  null

 initialize d_cts00m02, ws, salva, a_voo, a_cts00m02, am_cts29g00 to null

 let l_nullo     = null #PSI186406 -Robson
 let l_resultado = null #PSI186406 -Robson
 let l_mensagem  = null #PSI186406 -Robson

 let int_flag        = false
 let l_erro          = false
 call cts40g03_data_hora_banco(2)
        returning ws.dataatu,
                  ws.horaatu
 call cts40g03_data_hora_banco(1)
       returning ws.dataatu,
                 ws.horaatu1
 #let ws.dataatu      = today
 #let ws.horaatu      = current hour to minute
 #let ws.horaatu1     = current hour to second

 let ws.vclctrposqtd = 0
 let l_atualiza_todos = 'N'
 let m_rota = ""
 let l_prest_conect  = false

 let m_hostname   = fun_dba_servidor("SINIS")


 if param.atdsrvnum  is null   or
    param.atdsrvano  is null   then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
   #close window cts00m02
    return
 end if

 ### Inicio PSI168912
 if m_cts00m02_prep is null or
    m_cts00m02_prep <> true then
    call cts00m02_prepare()
 end if
 ### Final PSI168912

   if  g_issk.dptsgl = "c24tpf"    or
       g_issk.dptsgl = "devist"    or
       g_issk.dptsgl = "tectra"    then

        open  c_cts00m02_010 using g_issk.funmat
        fetch c_cts00m02_010 into l_permissao
        close c_cts00m02_010

        if l_permissao > 0 then
           let param.flg_origem = 0
        end if

   end if



 #--------------------------------------------------------------------
 # Verifica se servico ja' foi concluido
 #--------------------------------------------------------------------
  open c_cts00m02_002 using param.atdsrvnum, param.atdsrvano
  whenever error continue
  fetch c_cts00m02_002 into d_cts00m02.atdprscod,
                          d_cts00m02.srrabvnom,
                          d_cts00m02.atdvclsgl,
                          ws.atdfnlflg,
                          ws.c24opemat,
                          d_cts00m02.cnldat,
                          d_cts00m02.atdfnlhor,
                          d_cts00m02.c24nomctt,
                          ws.atdpvtretflg,
                          ws.atdsrvorg,
                          ws.asitipcod,
                          ws.atdcstvlr,
                          ws.atddat,
                          ws.atddatprg,
                          ws.sindat,
                          ws.sinhor,
                          d_cts00m02.socvclcod,
                          d_cts00m02.srrcoddig,
                          d_cts00m02.atdprvdat,
                          d_cts00m02.srrltt,
                          d_cts00m02.srrlgt,
                          ws.prslocflg,
                          d_cts00m02.txivlr,
                          ws.ciaempcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error "Servico nao encontrado. AVISE A INFORMATICA!" sleep 2
     else
        error "Erro SELECT c_cts00m02_002 ", sqlca.sqlcode, " | ", sqlca.sqlerrd[2] sleep 2
        error "cts00m02() | ", param.atdsrvnum, " | ", param.atdsrvano  sleep 2
     end if
     return
  end if

 let m_atdfnlflg = ws.atdfnlflg

 if ws.prslocflg = "S" then
    let d_cts00m02.prsloc = "NO LOCAL"
 end if

 let l_demanda = false

 if g_documento.atdprscod is not null and
    g_documento.socvclcod is not null and
    g_documento.srrcoddig is not null and
    g_documento.atdprscod > 0         and
    g_documento.socvclcod > 0         and
    g_documento.srrcoddig > 0         then
    let l_demanda = true   ##--> ATIVA
    call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
         returning ws.atdetpcod
    if ws.atdetpcod = 5 or
       ws.atdetpcod = 6 then
       initialize g_documento.dstqtd    to null
    end if
 end if

## PSI 179345 - Final

 #--------------------------------
 # Verifica se servico e'  RET
 #--------------------------------
 declare c_cts00m02_018 cursor for
 select datmligacao.c24astcod
   from datmligacao
  where datmligacao.atdsrvnum  = param.atdsrvnum
    and datmligacao.atdsrvano  = param.atdsrvano
    and datmligacao.lignum    <> 0
 foreach c_cts00m02_018 into ws.c24astcod_ret

    if ws.c24astcod_ret = "RET"  then
       let ws.flagret = 1

       #PSI208094 - inicio
       #Busca o prestador do servico anterior
       call cts10g04_busca_prest_ant(param.atdsrvnum,
                                     param.atdsrvano)
            returning ws.pstcoddig_ori,
                      ws.srrcoddig_ori,
                      ws.socvclcod_ori
       #PSI208094 - fim

       if ws.socvclcod_ori is not null then
          select atdvclsgl into ws.atdvclsgl_ori
            from datkveiculo
           where socvclcod  =  ws.socvclcod_ori
       end if
    end if

    exit foreach
 end foreach


  #apenas para servicos de origem RE
  if ws.atdsrvorg = 9 then
     #--OBTER SERVICO ORIGINAL SE O SERVICO VINDO DO PARAMETRO FOR MULTIPLO-- #
     call cts29g00_consistir_multiplo(param.atdsrvnum, param.atdsrvano)
          returning l_resultado,
                    l_mensagem,
                    l_atdsrvnum_original,
                    l_atdsrvano_original

     if l_resultado = 3 then
        error l_mensagem sleep 2
        return
     end if

     # --O SERVICO DO PARAMETRO NAO E MULTIPLO, ENTAO E ORIGINAL-- #
     # --OBTER OS SERVICOS MULTIPLOS DO ORIGINAL-- #
     if l_resultado = 2 then

        call cts29g00_obter_multiplo(1, param.atdsrvnum, param.atdsrvano)
             returning l_resultado,
                       l_mensagem,
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

        if l_resultado = 3 then
           error l_mensagem sleep 2
           return
        end if

        if l_resultado = 2 then
           # --NAO TEMOS SERVICOS MULTIPLOS PARA O SERVICO DO PARAMETRO-- #
           # --O <RECORD>.R_CTS29G00 FICARA NULO--- #
           initialize am_cts29g00 to null
        else
           let l_atdsrvnum_original = param.atdsrvnum
           let l_atdsrvano_original = param.atdsrvano
        end if

     end if
  end if

  if l_atdsrvnum_original is null then
     open window cts00m02 at 08,04 with form "cts00m02"
                             attribute (form line 1, border, comment line last - 1)
  else
     open window w_cts00m02t at 08,04 with form "cts00m02"
                                attribute (form line 1, border, comment line last - 1)
  end if

## PSI179345 - Inicio

 if l_demanda = true then
    message " (F3)Idx (F4)Pos.Prest (F6)Etapas"
 else
    if param.flg_origem <> 2 then    # for radio/atendente
       if ws.atdsrvorg = 16 then  # Sinistro Transportes
          message " (F3)Idx (F4)Pos.Prest (F6)Etapas, (F7)Prest"
       else
          if ws.flagret = 1 then
             message "(F3)Idx (F4)Pos.Pst (F5)Rota (F6)Etp (F7)Pst (F8)Frt (F9)GPS (F10)Org (F2)LMT"
          else
             message "(F3)Idx (F4)Pos.Prest (F5)Rota (F6)Etp (F7)Prest (F8)Frt (F9)GPS (F2)LMT"
          end if
       end if
    else
       message " (F3)Idx (F4)Pos.Prest (F6)Etapas"
    end if
 end if

## PSI179345 - Final

 if ws.atdsrvorg =  2   and
    ws.asitipcod =  5   then
    select pasasivcldes
      into d_cts00m02.pasasivcldes
      from datmtrptaxi
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano

    --> Fabrica de Software - Teresinha Silva - OSF 25143
    if d_cts00m02.pasasivcldes = 'P' then
       let l_descveiculo       = 'Passeio'
    end if
    if d_cts00m02.pasasivcldes = 'V' then
       let l_descveiculo       = 'Van'
    end if

 end if

    if param.flg_origem <> 2 then              # for radio/atendente
       if l_demanda = true then   ### PSI179345
          message " (F3)Idx (F4)Pos.Prest (F6)Etapas"
       else
          message " (F3)Idx (F4)Pos.Prest (F5)Rota (F6)Etp (F7)Prest (F8)Frt (F9)GPS (F2)LMT"
       end if
    else
       message " (F3)Idx (F4)Pos.Prest (F6)Etapas"
    end if
 #end if

 #--------------------------------------------------------------------
 # Informacoes especificas de assistencia a passageiros - hospedagem
 #--------------------------------------------------------------------
 if ws.atdsrvorg =  3   then
    if param.flg_origem <> 2 then            # for radio/atendente
       if l_demanda = true then   ### PSI179345
          message " (F3)Idx (F4)Pos.Prest (F6)Etapas"
       else
          message "(F3)Idx (F4)Pos.Prest (F5)Hosp (F6)Etp (F7)Prest (F8)Frota (F9)GPS (F2)LMT"
       end if
    else
      message " (F3)Idx (F4)Pos.Prest (F6)Etapas"
    end if
 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         1)
               returning a_cts00m02[1].lclidttxt   ,
                         a_cts00m02[1].lgdtip      ,
                         a_cts00m02[1].lgdnom      ,
                         a_cts00m02[1].lgdnum      ,
                         a_cts00m02[1].lclbrrnom   ,
                         a_cts00m02[1].brrnom      ,
                         a_cts00m02[1].cidnom      ,
                         a_cts00m02[1].ufdcod      ,
                         a_cts00m02[1].lclrefptotxt,
                         a_cts00m02[1].endzon      ,
                         a_cts00m02[1].lgdcep      ,
                         a_cts00m02[1].lgdcepcmp   ,
                         a_cts00m02[1].lclltt      ,
                         a_cts00m02[1].lcllgt      ,
                         a_cts00m02[1].dddcod      ,
                         a_cts00m02[1].lcltelnum   ,
                         a_cts00m02[1].lclcttnom   ,
                         a_cts00m02[1].c24lclpdrcod,
                         a_cts00m02[1].celteldddcod,
                         a_cts00m02[1].celtelnum,
                         a_cts00m02[1].endcmp,
                         ws.sqlcode, a_cts00m02[1].emeviacod

 select ofnnumdig into a_cts00m02[1].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    if l_atdsrvnum_original is null then
       close window cts00m02
    else
       close window w_cts00m02t
    end if
    return
 end if
 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         2)
               returning a_cts00m02[2].lclidttxt   ,
                         a_cts00m02[2].lgdtip      ,
                         a_cts00m02[2].lgdnom      ,
                         a_cts00m02[2].lgdnum      ,
                         a_cts00m02[2].lclbrrnom   ,
                         a_cts00m02[2].brrnom      ,
                         a_cts00m02[2].cidnom      ,
                         a_cts00m02[2].ufdcod      ,
                         a_cts00m02[2].lclrefptotxt,
                         a_cts00m02[2].endzon      ,
                         a_cts00m02[2].lgdcep      ,
                         a_cts00m02[2].lgdcepcmp   ,
                         a_cts00m02[2].lclltt      ,
                         a_cts00m02[2].lcllgt      ,
                         a_cts00m02[2].dddcod      ,
                         a_cts00m02[2].lcltelnum   ,
                         a_cts00m02[2].lclcttnom   ,
                         a_cts00m02[2].c24lclpdrcod,
                         a_cts00m02[2].celteldddcod,
                         a_cts00m02[2].celtelnum,
                         a_cts00m02[2].endcmp,
                         ws.sqlcode, a_cts00m02[2].emeviacod

 whenever error continue
 select ofnnumdig into a_cts00m02[2].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 2
 whenever error stop
 if ws.sqlcode < 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
    if l_atdsrvnum_original is null then
       close window cts00m02
    else
       close window w_cts00m02t
    end if
    return
 end if

## PSI 179345 - Inicio

 if l_demanda = true and
    g_documento.dstqtd is not null then
    let d_cts00m02.atdprscod = g_documento.atdprscod
    let d_cts00m02.socvclcod = g_documento.socvclcod
    let d_cts00m02.srrcoddig = g_documento.srrcoddig
    let l_aux = g_documento.prvcalc
    let d_cts00m02.atdprvdat = l_aux
    let d_cts00m02.dstqtd    = g_documento.dstqtd
    let d_cts00m02.srrltt    = g_documento.lclltt
    let d_cts00m02.srrlgt    = g_documento.lcllgt
    let salva.socvclcod      = g_documento.socvclcod
 end if

## PSI 179345 - Final

 #--------------------------------------------------------------------
 # Informacoes sobre veiculo/operador de radio
 #--------------------------------------------------------------------
 if d_cts00m02.socvclcod  is not null   then
    select atdvclsgl,
           vclcoddig
      into d_cts00m02.atdvclsgl,
           ws.vclcoddig
      from datkveiculo
     where socvclcod  =  d_cts00m02.socvclcod

    if sqlca.sqlcode  =  notfound  then
       error " Veiculo nao encontrado. AVISE A INFORMATICA!"
       if l_atdsrvnum_original is null then
          close window cts00m02
       else
          close window w_cts00m02t
       end if
       return
    end if

    call cts15g00 (ws.vclcoddig)  returning d_cts00m02.socvcldes
 end if

 open c_cts00m02_005 using  param.atdsrvnum, param.atdsrvano
 fetch c_cts00m02_005 into ws.atdsrvseq
 close c_cts00m02_005

 open c_cts00m02_006 using  param.atdsrvnum, param.atdsrvano, ws.atdsrvseq
 fetch c_cts00m02_006 into ws.c24opemat, ws.c24opeempcod, d_cts00m02.envtipcod
 close c_cts00m02_006
 if d_cts00m02.envtipcod = 0 then
 	  initialize d_cts00m02.envtipcod to null
 end if

 if ws.c24opemat is not null  then
    if ws.c24opemat   = 999999 then
       let d_cts00m02.operador = "PROCESSO AUTOMATICO"
    else

       let d_cts00m02.operador = "**NAO CADASTRADO**"
       if ws.c24opeempcod is null or
          ws.c24opeempcod = 0 then
          let ws.c24opeempcod = 1
       end if

       select funnom
         into d_cts00m02.operador
         from isskfunc
        where empcod = ws.c24opeempcod
          and funmat = ws.c24opemat

       let d_cts00m02.operador = upshift(d_cts00m02.operador)

    end if
 end if


  # BUSCA O CEL DO VEICULO
  call cts00m03_cel_veiculo(d_cts00m02.socvclcod)
       returning l_celdddcod_veic, l_celtelnum_veic, l_mdtcod

  # BUSCA O CEL DO SOCORRISTA
  call cts00m03_cel_socorr(d_cts00m02.srrcoddig)
       returning l_celdddcod_soco, l_celtelnum_soco

  display l_celdddcod_veic to celdddcod_veic
  display l_celtelnum_veic to celtelnum_veic
  display l_celdddcod_soco to celdddcod_soco
  display l_celtelnum_soco to celtelnum_soco

 #--------------------------------------------------------------------
 # Informacoes do socorrista
 #--------------------------------------------------------------------
 if d_cts00m02.srrcoddig  is not null   then
    if ws.atdsrvorg = 16  then  # sinistro transportes
       select sinprsnom
         into d_cts00m02.srrabvnom
         from sstkprest
        where sinprscod  =  d_cts00m02.srrcoddig
    else
        select srrabvnom
          into d_cts00m02.srrabvnom
          from datksrr
         where srrcoddig  =  d_cts00m02.srrcoddig
    end if
 end if


 #--------------------------------------------------------------------
 # Informacoes etapa
 #--------------------------------------------------------------------

## PSI 179345 - Inicio

 call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
      returning d_cts00m02.atdetpcod

 let  salva.atdetpcod      = d_cts00m02.atdetpcod
 let  d_cts00m02.atdetpdes = "NAO CADASTRADA"

 call cts10g05_desc_etapa(2,d_cts00m02.atdetpcod)
      returning ws.result, d_cts00m02.atdetpdes,
                ws.atdetptipcod, ws.atdetppndflg

 if ws.atdetppndflg = "S"  then
    let ws.atdfnlflg = "N"
 else
    let ws.atdfnlflg = "S"
 end if

 if l_demanda = true  then
    let ws.flagf9 = "S"
    if g_documento.dstqtd is not null then
       if  ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
           let d_cts00m02.atdetpcod = 3
       else
           let d_cts00m02.atdetpcod = 4
       end if
    end if
 end if

 ####### PSI 211982 - Pegasus - 05/10/07 #############################

 if ws.ciaempcod = 40 then
    call cts10g06_assunto_servico(param.atdsrvnum
                                 ,param.atdsrvano)
         returning l_resultado
                  ,l_mensagem
                  ,ws.c24astcod
                  ,ws.c24funmat
                  ,ws.c24empcod

    call cts25g00_dados_assunto(4,ws.c24astcod)
         returning l_resultado
                  ,l_mensagem
                  ,ws.atmacnflg

    if ws.atmacnflg = 'N' then

       if d_cts00m02.atdetpcod = 1 then ## liberado
          let d_cts00m02.atdetpcod = 7  ## em orcamento
          let ws.atdfnlflg = "N"
       else
          if d_cts00m02.atdetpcod = 48 then ## orcado
             let d_cts00m02.atdetpcod = 3   ## acionado/exe
             let ws.flagf7  = "S"
             let ws.atdfnlflg = "N"
          else
             if d_cts00m02.atdetpcod = 3 then ## acionado/exe
                let d_cts00m02.atdetpcod = 8   ## concluido
                let ws.flagf7  = "S"
                let ws.atdfnlflg = "S"
             end if
          end if
       end if

       call cts10g05_desc_etapa(2,d_cts00m02.atdetpcod)
            returning ws.result, d_cts00m02.atdetpdes,
                      ws.atdetptipcod, ws.atdetppndflg

       if d_cts00m02.atdetpcod = 3  then
          ## informa/grava nr.da autorizacao no orcamento
          call ctd09g00_sol_nr_atz(param.atdsrvnum, param.atdsrvano)
       end if
    end if
 end if

 ######################################################################

 #--------------------------------------------------------------------
 # Informacoes do prestador
 #--------------------------------------------------------------------
 if d_cts00m02.atdprscod  is not null   then

    # BUSCA O CEL DO VEICULO
    call cts00m03_cel_veiculo(d_cts00m02.socvclcod)
         returning l_celdddcod_veic, l_celtelnum_veic, l_mdtcod

    # BUSCA O CEL DO SOCORRISTA
    call cts00m03_cel_socorr(d_cts00m02.srrcoddig)
         returning l_celdddcod_soco, l_celtelnum_soco

    display l_celdddcod_veic to celdddcod_veic
    display l_celtelnum_veic to celtelnum_veic
    display l_celdddcod_soco to celdddcod_soco
    display l_celtelnum_soco to celtelnum_soco

    if ws.atdsrvorg = 16 then # sinistro transportes
       select sinprsnom,
              dddcod,
              telnum,
              endcid,
              endufd,
              faxnum
         into d_cts00m02.nomgrr,
              d_cts00m02.dddcod,
              d_cts00m02.teltxt,
              ws.endcidprs,
              ws.endufdprs,
              ws.faxnum
         from sstkprest
        where sinprscod = d_cts00m02.atdprscod
    else

       select nomgrr,
              dddcod,
              teltxt,
              endcid,
              endufd,
              faxnum,
              intsrvrcbflg
         into d_cts00m02.nomgrr,
              d_cts00m02.dddcod,
              d_cts00m02.teltxt,
              ws.endcidprs,
              ws.endufdprs,
              ws.faxnum,
              ws.intsrvrcbflg
            from dpaksocor
           where pstcoddig = d_cts00m02.atdprscod
    end if
    let d_cts00m02.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs
 end if

 #--------------------------------------------------------------------
 # Calcula distancia no acionamento
 #--------------------------------------------------------------------
 if d_cts00m02.atdetpcod = 3 or
    d_cts00m02.atdetpcod = 4 or
    d_cts00m02.atdetpcod = 5 or
    d_cts00m02.atdetpcod = 11 then
    if d_cts00m02.srrltt is not null and d_cts00m02.srrlgt is not null and
      a_cts00m02[1].lclltt is not null and a_cts00m02[1].lcllgt is not null then

      # -> VERIFICA SE A ROTA ESTA ATIVA
      if ctx25g05_rota_ativa() then
         call cts00m02_dist(d_cts00m02.srrltt,
                            d_cts00m02.srrlgt,
                            a_cts00m02[1].lclltt,
                            a_cts00m02[1].lcllgt)

           returning d_cts00m02.dstqtd,
                     m_rota
       else
          call cts18g00(d_cts00m02.srrltt,d_cts00m02.srrlgt,
                        a_cts00m02[1].lclltt,a_cts00m02[1].lcllgt)
               returning d_cts00m02.dstqtd
       end if
    else
       if d_cts00m02.srrcoddig is null then
          if ws.atdsrvorg = 16 then
             select cidcod into ws.mpacidcod
               from sstkprest
               where sinprscod = d_cts00m02.atdprscod
          else
             select mpacidcod into ws.mpacidcod
               from dpaksocor
               where pstcoddig = d_cts00m02.atdprscod
          end if
          call cts23g00_inf_cidade(3,ws.mpacidcod,"","")
               returning ws.result,
                         d_cts00m02.srrltt,
                         d_cts00m02.srrlgt

             call cts18g00(d_cts00m02.srrltt,d_cts00m02.srrlgt,
                           a_cts00m02[1].lclltt,a_cts00m02[1].lcllgt)
                  returning d_cts00m02.dstqtd
           #end if
       end if
    end if
 end if

 #--------------------------------------------------------------------
 # Salva conteudo dos campos
 #--------------------------------------------------------------------
 let salva.atdetptipcod  =  ws.atdetptipcod
 let salva.atdprscod     =  d_cts00m02.atdprscod
 let salva.srrcoddig     =  d_cts00m02.srrcoddig
 let salva.atdvclsgl     =  d_cts00m02.atdvclsgl

 #--------------------------------------------------------------------
 # Verifica se o AcionamentoWeb esta ativo e se a origem do servico faz parte do AcionamentoWeb
 #--------------------------------------------------------------------
 if ctx34g00_ver_acionamentoWEB(2) and ctx34g00_origem(param.atdsrvnum,param.atdsrvano) then
    let l_acionamentoWEB = true
 else
    let l_acionamentoWEB = false
 end if

 #--------------------------------------------------------------------
 # SITUACAO DA TRANSMISSAO
 #--------------------------------------------------------------------
 if l_acionamentoWEB and (d_cts00m02.atdetpcod = 3 or
                          d_cts00m02.atdetpcod = 4 or
                          d_cts00m02.atdetpcod = 5 or
                          d_cts00m02.atdetpcod = 10) then
    call ctx34g02_situacao_transmissao(param.atdsrvnum, param.atdsrvano, ws.atdsrvseq)
         returning l_resultado,
                   l_mensagem,
                   d_cts00m02.mdtmsgsttdes,
                   d_cts00m02.atldat,
                   d_cts00m02.atlhor,
                   d_cts00m02.rcbpor
 else
    call ctn43c00_alt_msg(param.atdsrvnum, param.atdsrvano)
         returning d_cts00m02.mdtmsgsttdes,
                   d_cts00m02.atldat      ,
                   d_cts00m02.atlhor      ,
                   d_cts00m02.rcbpor
 end if
 if d_cts00m02.mdtmsgsttdes is null then
    let d_cts00m02.mdtmsgsttdes = null
    let d_cts00m02.atldat       = null
    let d_cts00m02.atlhor       = null
    let d_cts00m02.rcbpor       = null
 end if


 display by name d_cts00m02.cnldat, d_cts00m02.atdfnlhor,
                 d_cts00m02.operador , d_cts00m02.atdetpcod,
                 d_cts00m02.atdetpdes, d_cts00m02.retorno  ,
                 d_cts00m02.envio    , d_cts00m02.atdprscod,
                 d_cts00m02.prsloc   , d_cts00m02.nomgrr   ,
                 d_cts00m02.cidufdprs, d_cts00m02.dddcod   ,
                 d_cts00m02.teltxt   , d_cts00m02.c24nomctt,
                 d_cts00m02.atdvclsgl, d_cts00m02.srrcoddig,
                 d_cts00m02.srrabvnom, d_cts00m02.atdcstvlr,
                 d_cts00m02.pasasivcldes, d_cts00m02.atdprvdat ,
                 d_cts00m02.dstqtd      , d_cts00m02.envtipcod ,
                 d_cts00m02.mdtmsgsttdes, d_cts00m02.atldat    ,
                 d_cts00m02.atlhor      , d_cts00m02.rcbpor

 display by name l_descveiculo --> OSF 25143

 if ws.atdpvtretflg = "S"  then
    display "RETORNAR AO SEGURADO" to retorno attribute(reverse)
 end if

 #--------------------------------------------------------------------
 # Verifica se ja' houve algum  tipo de envio para o servico
 #--------------------------------------------------------------------
 initialize d_cts00m02.envio  to null
 call cts00m02_envio(param.atdsrvnum,
                     param.atdsrvano,
                     d_cts00m02.atdprscod)
      returning d_cts00m02.envio

 if d_cts00m02.envio  is not null   then
    display by name d_cts00m02.envio  attribute(reverse)
 end if

 # --SE O SERVICO E MULTIPLO, VERIFICAR COM O SERVICO ORIGINAL-- #
 if d_cts00m02.envio is null then

    if l_atdsrvnum_original is not null then
       let d_cts00m02.envio = cts00m02_envio(l_atdsrvnum_original,
                                             l_atdsrvano_original,
                                             d_cts00m02.atdprscod)
    end if
 end if

 if d_cts00m02.envio is not null then
    display by name d_cts00m02.envio attribute(reverse)
 end if

 if ws.atdsrvorg =  2   or
    ws.atdsrvorg =  3   then
    display "Valor....:"  to valor
    let d_cts00m02.atdcstvlr = ws.atdcstvlr
    if ws.asitipcod =  5   then
       display "Veiculo..:"  to veiculo
    end if
    if d_cts00m02.txivlr is not null and
       d_cts00m02.txivlr <> 0 then
       display "Valor Est: " to titulo
       let d_cts00m02.atdvclsgl = d_cts00m02.txivlr using "###&.&&"
       display d_cts00m02.atdvclsgl to atdvclsgl
    else
       display 'Veiculo..:' to titulo
       display d_cts00m02.atdvclsgl to atdvclsgl
       let m_descricao = d_cts00m02.socvclcod, " ", d_cts00m02.socvcldes
       display m_descricao to socvcldes
    end if
 else
    display 'Veiculo..:' to titulo
    display d_cts00m02.atdvclsgl to atdvclsgl
    let m_descricao = d_cts00m02.socvclcod, " ", d_cts00m02.socvcldes
    display m_descricao to socvcldes

    initialize d_cts00m02.atdcstvlr     to null
    initialize d_cts00m02.pasasivcldes  to null
    display by name d_cts00m02.atdcstvlr
    display by name d_cts00m02.pasasivcldes
 end if

 #--------------------------------------------------------------------
 # Digita dados para conclusao
 #--------------------------------------------------------------------
 if d_cts00m02.atdetpcod = 1 and
    ws.flagret           = 1 then
    let d_cts00m02.atdprscod = ws.pstcoddig_ori
    let d_cts00m02.srrcoddig = ws.srrcoddig_ori
    select dpaksocor.nomgrr, dpaksocor.dddcod,
           dpaksocor.teltxt, dpaksocor.endcid,
           dpaksocor.endufd
      into d_cts00m02.nomgrr, d_cts00m02.dddcod,
           d_cts00m02.teltxt, ws.endcidprs,
           ws.endufdprs
      from dpaksocor
     where pstcoddig = d_cts00m02.atdprscod

     let d_cts00m02.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs

     display d_cts00m02.nomgrr     to  nomgrr
     display d_cts00m02.cidufdprs  to  cidufdprs
     display d_cts00m02.dddcod     to  dddcod
     display d_cts00m02.teltxt     to  teltxt

     display d_cts00m02.prsloc     to  prsloc   attribute (reverse)
 end if

 call cta00m08_ver_contingencia(3)
      returning l_contingencia

 # TRAVA ACIONAMENTO INFORMIX F9
 let l_trava_f9 = 0
 select count(*) into l_trava_f9 from datkgeral where grlchv = 'PSOF9ATIVO'
 if l_trava_f9 > 0 then
    # NAO PERMITE ACIONAMENTO NO INFORMIX CASO:
    #  AW ESTEJA ATIVO
    #  A ORIGEM DO SERVICO FOR MIGRADA PARA O AW
    #  USUARIO NAO ESTIJA NA LISTA DE EXCECAO
    if param.flg_origem <> 2 and
    	  ctx34g00_NovoAcionamento() and
    	  ctx34g00_origem(param.atdsrvnum, param.atdsrvano) and
    	  (not cts00m02_verifica_acesso_acionamento(ws.atdsrvorg))
    	   then
    	
    	  let param.flg_origem = 2 # TRAVA ACIONAMENTO
    	  error "NAO E POSSIVEL ALTERAR AS INFORMACOES DE CONCLUSAO DO SERVICO. UTILIZE O AW."
       #prompt "Pressione qualquer tecla para continuar." for char prompt_key
      
    end if
 end if

 input by name d_cts00m02.atdetpcod,
               d_cts00m02.atdprscod,
               d_cts00m02.c24nomctt,
               d_cts00m02.atdvclsgl,
               d_cts00m02.srrcoddig,
               d_cts00m02.atdprvdat,
               d_cts00m02.pasasivcldes,
               d_cts00m02.envtipcod  without defaults

   before input
      let l_atdvclsgl = null

   before field atdetpcod
      if param.flg_origem = 2 then        # Nao for radio/atendente
         next field envtipcod
      end if

      if (ws.atdsrvorg = 02   or
          ws.atdsrvorg = 03)  and
          ws.asitipcod <> 5 and ## Se nao for taxi
          salva.atdetpcod = 1 and
          l_intsrvrcbflg = '1' then
         let d_cts00m02.atdetpcod = 43
      end if
      display by name d_cts00m02.atdetpcod attribute (reverse)

   after field atdetpcod
      display by name d_cts00m02.atdetpcod

      ##-- Para origem 9 ou 13, chamar cts08g01 --##
      if (ws.atdsrvorg  =  9 or ws.atdsrvorg  =  13) and
          ws.flagret    =  1 then
         if d_cts00m02.atdetpcod <>  1 and  #  1-LIBERADO
            d_cts00m02.atdetpcod <>  5 and  #  5-CANCELADO
            d_cts00m02.atdetpcod <>  6 and  #  6-EXCLUIDO
            d_cts00m02.atdetpcod <> 10 then # 10-RETORNO
            call cts08g01("A","N","","ETAPA NAO PERMITIDA PARA RETORNO",
                                  "DE SERVICO!","")
                 returning ws.confirma
            next field atdetpcod
         end if
      end if
      ---[nao permitir etapa 10 para servicos originais - Judite 24/05/07]---
      if (ws.atdsrvorg = 9 or ws.atdsrvorg = 13) and
          ws.flagret is null                     and  # nao e retorno
          d_cts00m02.atdetpcod = 10              then # etapa de retorno
          call cts08g01 ("A","N","",
                         "ETAPA NAO VALIDA PARA SERVICO ORIGINAL",
                         "","") returning ws.confirma
          next field atdetpcod
      end if
      --------------------------------------------------------[ruiz 24/05/07]--
         if ws.atdsrvorg <> 16 then # sinistro transportes
            select dbsmopg.socopgnum
              into ws.socopgnum
              from dbsmopgitm, dbsmopg
             where dbsmopgitm.atdsrvnum = param.atdsrvnum  and
                   dbsmopgitm.atdsrvano = param.atdsrvano  and
                   dbsmopg.socopgnum    = dbsmopgitm.socopgnum   and
                   dbsmopg.socopgsitcod <> 8
            if sqlca.sqlcode = 0  then
               error " Servico nao deve ser alterado! Servico pago pela OP ",
                       ws.socopgnum using "<<<<<<<<<&", "!"
               let d_cts00m02.atdetpcod = salva.atdetpcod
               next field atdetpcod
            end if
         end if

      if d_cts00m02.atdetpcod is null   then
         error " Etapa deve ser informada!"
         call ctn26c00(ws.atdsrvorg) returning d_cts00m02.atdetpcod
         next field atdetpcod

      else

         #Chamado 7111430
         select atdetpcod
           from datrsrvetp
          where atdsrvorg    = ws.atdsrvorg
            and atdetpcod    = d_cts00m02.atdetpcod
            and atdsrvetpstt = "A"
         if sqlca.sqlcode = notfound  then
            error "Etapa não pertence a esse tipo de serviço ou etapa inexistente "
            let d_cts00m02.atdetpcod = salva.atdetpcod
            next field atdetpcod
         end if

         if d_cts00m02.atdetpcod = 2  then
            error " Etapa nao pode ser informada na conclusao!"
            let d_cts00m02.atdetpcod = salva.atdetpcod
            next field atdetpcod
         end if

         call cts10g05_desc_etapa(2,d_cts00m02.atdetpcod)
                        returning ws.result,
                                  d_cts00m02.atdetpdes,
                                  ws.atdetptipcod,
                                  ws.atdetppndflg
         if ws.result = 100 then
            error " Etapa nao cadastrada! Informe novamente."
            call ctn26c00(ws.atdsrvorg) returning d_cts00m02.atdetpcod
            next field atdetpcod
         end if

         if ws.atdetppndflg = "S"  then
            let ws.atdfnlflg = "N"
         else
            let ws.atdfnlflg = "S"
         end if

         if d_cts00m02.atdetpcod = 7 then  # psi 211982
            let ws.atdfnlflg = "N"
         end if

         select atdetpcod
           from datrsrvetp
          where atdsrvorg    = ws.atdsrvorg
            and atdetpcod = d_cts00m02.atdetpcod
            and atdsrvetpstt = "A"

         if sqlca.sqlcode = notfound  then
            error " Etapa nao pertence a este tipo de servico!"
            call ctn26c00(ws.atdsrvorg) returning d_cts00m02.atdetpcod
            next field atdetpcod
         end if
      end if

      display by name d_cts00m02.atdetpdes

      if d_cts00m02.atdetpcod  = 14 then  ## Cotado
         if ws.atdsrvorg    =  2   and
            ws.asitipcod = 10   then

            let l_aerciacod = null
            let l_vooopc = null

            call cts11m09_voo(param.atdsrvnum ,param.atdsrvano)
                 returning l_aerciacod, l_vooopc

            call ctc10g00_dados_cia(2 ,l_aerciacod)
                 returning l_retorno ,l_mensagem, l_mensagem
                          ,l_aerpsgrsrflg ,l_aerpsgemsflg

            call cts00m02_ciaaerea(param.atdsrvnum,param.atdsrvano,l_vooopc)
                 returning l_aerpsgrsrflg ,l_aerpsgemsflg

            if l_aerpsgrsrflg = 'S' and l_aerpsgemsflg = 'S' then
               call cts08g02("A","S","", "",
                             "RESERVAR OU EMITIR A PASSAGEM ?", "")
                    returning ws.confirma

               if ws.confirma matches "[Rr]" then
                  let d_cts00m02.atdetpcod = 45
               else
                  let d_cts00m02.atdetpcod = 44
               end if
            else
               if l_aerpsgrsrflg = 'S' then
                  let d_cts00m02.atdetpcod = 45
               end if

               if l_aerpsgemsflg = 'S' then
                  let d_cts00m02.atdetpcod = 44
               end if
            end if
         end if

         if ws.atdsrvorg =  3   then ## Hospedagem
            call cts22m01_iniciar(param.atdsrvnum
                                 ,param.atdsrvano
                                 ,g_documento.acao)
            let d_cts00m02.atdetpcod = 45
         end if

         call cts10g05_desc_etapa(2,d_cts00m02.atdetpcod)
              returning ws.result, d_cts00m02.atdetpdes,
                       ws.atdetptipcod, ws.atdetppndflg

         if ws.atdetppndflg = "S"  then
            let ws.atdfnlflg = "N"
         else
            let ws.atdfnlflg = "S"
         end if

         display by name d_cts00m02.atdetpcod, d_cts00m02.atdetpdes

      end if

      # --VERIFICA OS SERVICOS MULTIPLOS PARA ACIONAMENTO/CANCELAMENTO-- #
      # apenas para servico de RE

      if ws.atdsrvorg = 9 then

         if (am_cts29g00[1].atdmltsrvnum is not null or
             l_atdsrvnum_original is not null)  and
           (d_cts00m02.atdetpcod = 3 or
            d_cts00m02.atdetpcod = 4 or
            d_cts00m02.atdetpcod = 5 or
            d_cts00m02.atdetpcod = 7 or
            d_cts00m02.atdetpcod = 8 or
            d_cts00m02.atdetpcod = 1) then

            # --EXIBIR ALERTA AO ATENDENTE-- #

            case d_cts00m02.atdetpcod
              when 1  # --LIBERADO
                  let l_atualiza_todos = cts08g01("A","F","",
                                                  "EXISTEM LAUDOS MULTIPLOS, CONFIRME",
                                                  "A LIBERACAO DE TODOS ","")
              when 3  # --ACIONAMENTO
                  let l_atualiza_todos = cts08g01("A","F","",
                                                  "EXISTEM LAUDOS MULTIPLOS, CONFIRME",
                                                  "O ACIONAMENTO DE TODOS ","")
            	when 5  # --CANCELAMENTO
                  let l_atualiza_todos = cts08g01("A","F","",
                                                  "EXISTEM LAUDOS MULTIPLOS, CONFIRME",
                                                  "O CANCELAMENTO DE TODOS ","")
              when 7  # --ORCAMENTO
                  let l_atualiza_todos = cts08g01("A","F","",
                                                  "EXISTEM LAUDOS MULTIPLOS, CONFIRME",
                                                  "O ORCAMENTO DE TODOS ","")
              when 8  # --EXECUCAO
                  let l_atualiza_todos = cts08g01("A","F","",
                                                  "EXISTEM LAUDOS MULTIPLOS, CONFIRME",
                                                  "A EXECUCAO DE TODOS ","")
            end case

            if l_atualiza_todos = "S" then
               let param.atdsrvnum = l_atdsrvnum_original
               let param.atdsrvano = l_atdsrvano_original

               call cts29g00_obter_multiplo(1, l_atdsrvnum_original, l_atdsrvano_original)
                    returning l_resultado,
                              l_mensagem,
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


              # --VERIFICA A EXISTENCIA DE LIGACAO DE COMPLEMENTO PARA OS MULTIPLOS-- #
               for l_contador = 1 to 10
                  if am_cts29g00[l_contador].atdmltsrvnum is not null then
                     call cts20g00_lig_compl(am_cts29g00[l_contador].atdmltsrvnum,
                                             am_cts29g00[l_contador].atdmltsrvano)
                            returning l_resultado,
                                      l_mensagem,
                                      l_c24astcod
                     if l_resultado = 1 then
                        exit for
                     end if
                  end if
               end for
               if l_resultado = 1 then
                  let ws.confirma = cts08g01("A","S","",
                                             "EXISTEM LIGACOES DE CANCELAMENTO OU",
                                             "ALTERACAO, DESEJA VISUALIZAR ?","")
                  if ws.confirma = "S" then
                     if d_cts00m02.atdetpcod = 5  then ##ligia
                        let l_acao = ""
                     else
                        let l_acao = "RAD"
                     end if

                     if l_atdsrvnum_original is not null then
                        call cts17m08_consultar_multiplos
                             (l_atdsrvnum_original, l_atdsrvano_original,l_acao)
                     else
                        call cts17m08_consultar_multiplos
                             (param.atdsrvnum, param.atdsrvano, l_acao) #ligia
                     end if

                  end if
               end if
            else

               ## Desfazer as alteracoes no multiplos feitas no f8/f9
               if d_cts00m02.atdetpcod = 3  then

                  let l_flag_f8_f9 = 0
                  if ws.flagf8 = "S" then
                     let l_flag_f8_f9 = 1
                  end if
                  if ws.flagf9 = "S" then
                     let l_flag_f8_f9 = 2
                  end if

                  ## atualizar o prestador/veiculo para os multiplos
                  for l_contador = 1 to 10
                     if am_cts29g00[l_contador].atdmltsrvnum is not null then
                        call cts10g09_registrar_prestador
                             (l_flag_f8_f9, am_cts29g00[l_contador].atdmltsrvnum,
                              am_cts29g00[l_contador].atdmltsrvano,
                              "","","","","")
                              returning l_resultado, l_mensagem

                        if l_resultado <> 1 then
                           exit for
                        end if
                     end if
                  end for
               end if

               call cts17m08_consultar_multiplos(param.atdsrvnum, param.atdsrvano, "RAD")
            end if
         end if
      end if

      if d_cts00m02.atdetpcod = 38  then  #---> Recusado
         call cta11m00(ws.atdsrvorg, param.atdsrvnum, param.atdsrvano
                      ,ws.pstcoddig,'N') returning l_srvrcumtvcod

         if l_srvrcumtvcod is null then
            error "Informe o motivo de recusa!"
            next field atdetpcod
         end if
      end if
      #BURINI if ((ws.atdsrvorg = 2 and          #se e servico assistencia passageiro
      #BURINI     ws.asitipcod <> 5) or
      #BURINI     ws.atdsrvorg = 3 ) and        # se nao for taxi
      #BURINI    salva.atdetpcod <> 4 and
      #BURINI    d_cts00m02.atdetpcod = 4 then     # e está sendo acionado nesse momento
      #BURINI      call cts00m15(param.atdsrvnum, param.atdsrvano)
      #BURINI      exit input
      #BURINI end if

      if not (((ws.atdsrvorg = 2 and ws.asitipcod <> 5) or ws.atdsrvorg = 3) and
         salva.atdetpcod >= 39 and d_cts00m02.atdetpcod = 4 )then
         if  d_cts00m02.atdetpcod = 3  or  # acionamento RE
             d_cts00m02.atdetpcod = 4  or
             d_cts00m02.atdetpcod = 5  or
             d_cts00m02.atdetpcod = 7  or  # psi 211982
             d_cts00m02.atdetpcod = 38 then
             if salva.atdetpcod =  3  or
                salva.atdetpcod =  4  then

                if d_cts00m02.atdetpcod <> 5 then
                   error "Servico Ja Acionado!"
                end if

                #Busca informacoes necessarias
                select pstcoddig,
                       socvclcod,
                       socoprsitcod,
                       atdimpcod,
                       mdtcod,
                       vclcoddig,
                       pgrnum
                into ws.pstcoddig,
                     d_cts00m02.socvclcod,
                     ws.socoprsitcod,
                     d_cts00m02.atdimpcod,
                     d_cts00m02.mdtcod,
                     ws.vclcoddig,
                     ws.pgrnum
                from datkveiculo
                where atdvclsgl  =  d_cts00m02.atdvclsgl

                if d_cts00m02.atdprvdat is null and
                   d_cts00m02.srrcoddig is null then
                   next field atdprvdat
                else
                   next field envtipcod
                end if
             end if
             if ws.flagf7            is null and
                ws.flagf8            is null and
                ws.flagf9            is null then

                if  d_cts00m02.atdprscod is null and # PSI 242853 PSS sem prestado na etapa liberada
                    ws.pstcoddig is null and d_cts00m02.atdetpcod <> 5 then
                    if ws.atdsrvorg = 16 then  # sinistro transportes
                       error "Selecionar Prestador pressionando F7"
                       next field atdetpcod
                    end if
                    error "Selecionar Viatura/Prestador pressionando F7, F8 ou F9"
                    next field atdetpcod
                end if
             end if
         else
            if d_cts00m02.atdetpcod = 1 and
              (salva.atdetpcod =  3  or
               salva.atdetpcod =  4)  then
               error "Servico Ja Acionado"
               let d_cts00m02.atdetpcod = salva.atdetpcod
               next field atdetpcod
            end if
            initialize ws.flagf7,ws.flagf8,ws.flagf9  to null
         end if
      end if

      if ws.atdsrvorg <> 10 and (d_cts00m02.atdetpcod = 5 or (d_cts00m02.atdetpcod = 1 and salva.atdetpcod <> 1)) then

      	 if d_cts00m02.atdetpcod = 1 and salva.atdetpcod <> 1 then

      	 	  initialize d_cts00m02.atdprscod,
                       d_cts00m02.nomgrr   ,
                       d_cts00m02.cidufdprs,
                       d_cts00m02.dddcod   ,
                       d_cts00m02.teltxt   ,
                       d_cts00m02.c24nomctt,
                       d_cts00m02.atdvclsgl,
                       d_cts00m02.srrcoddig,
                       d_cts00m02.socvclcod,
                       d_cts00m02.srrabvnom,
                       d_cts00m02.pasasivcldes,
                       d_cts00m02.atdprvdat,
                       d_cts00m02.dstqtd,
                       l_celdddcod_veic,
                       l_celtelnum_veic,
                       l_celdddcod_soco,
                       l_celtelnum_soco,
                       d_cts00m02.socvcldes   to null

            let d_cts00m02.envtipcod = 0

            display by name d_cts00m02.atdprscod,
                            d_cts00m02.nomgrr   ,
                            d_cts00m02.cidufdprs,
                            d_cts00m02.dddcod   ,
                            d_cts00m02.teltxt   ,
                            d_cts00m02.c24nomctt,
                            d_cts00m02.atdvclsgl,
                            d_cts00m02.srrcoddig,
                            d_cts00m02.srrabvnom,
                            d_cts00m02.pasasivcldes,
                            d_cts00m02.atdprvdat,
                            d_cts00m02.dstqtd   ,
                            d_cts00m02.envtipcod

            display l_celdddcod_veic to celdddcod_veic
            display l_celtelnum_veic to celtelnum_veic
            display l_celdddcod_soco to celdddcod_soco
            display l_celtelnum_soco to celtelnum_soco
            display d_cts00m02.socvcldes to socvcldes
      	 end if

         next field envtipcod
      end if

      if  d_cts00m02.atdvclsgl is not null then
          let l_atdvclsgl = d_cts00m02.atdvclsgl
      end if

   before field atdprscod
      display by name d_cts00m02.atdprscod attribute (reverse)

   after field atdprscod
      display by name d_cts00m02.atdprscod

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field atdetpcod
      end if

      ##-- Para origem 9 ou 13, chamar cts08g01 --##
      if (ws.atdsrvorg = 9 or ws.atdsrvorg = 13) and
         ws.flagret           =  1 and
         d_cts00m02.atdetpcod <> 5 then
         if d_cts00m02.atdprscod <> ws.pstcoddig_ori then
             call cts08g01("C","F","","PRESTADOR SELECIONADO DIFERENTE DO PRESTADOR",
                                  "DO ULTIMO ATENDIMENTO. DESEJA PROSSEGUIR?", "")
                 returning ws.confirma
             if ws.confirma = "S" then
                let ws.prsdftant = "S"
             else
                let ws.prsdftant = "N"
                next field atdetpcod
             end if
         end if
      end if
#PSI201022 - fim

      if d_cts00m02.atdetpcod >= 3  and
         d_cts00m02.atdetpcod <= 4  then
         if d_cts00m02.atdprscod is null  then
            error " Codigo do prestador deve ser informado!"
            next field atdprscod
         end if
      else
         if ws.atdetptipcod = 1  then  ### Servico nao acionado
            if d_cts00m02.atdprscod  is not null   then
               error " Prestador nao deve ser informado para",
                     " servico nao acionado!"
               next field atdprscod
            end if
         end if
      end if

      # BUSCA O CEL DO VEICULO
      call cts00m03_cel_veiculo(d_cts00m02.socvclcod)
           returning l_celdddcod_veic, l_celtelnum_veic, l_mdtcod

      # BUSCA O CEL DO SOCORRISTA
      call cts00m03_cel_socorr(d_cts00m02.srrcoddig)
           returning l_celdddcod_soco, l_celtelnum_soco

      display l_celdddcod_veic to celdddcod_veic
      display l_celtelnum_veic to celtelnum_veic
      display l_celdddcod_soco to celdddcod_soco
      display l_celtelnum_soco to celtelnum_soco

      #--------------------------------------------------------------------
      # Busca/verifica situacao do cadastro de prestadores
      #--------------------------------------------------------------------
      if d_cts00m02.atdprscod is not null   then
         if ws.atdsrvorg <> 16 then
            select dpaksocor.nomgrr,
                   dpaksocor.dddcod,
                   dpaksocor.teltxt,
                   dpaksocor.endcid,
                   dpaksocor.endufd,
                   dpaksocor.prssitcod,
                   dpaksocor.faxnum,
                   dpaksocor.intsrvrcbflg
              into d_cts00m02.nomgrr,
                   d_cts00m02.dddcod,
                   d_cts00m02.teltxt,
                   ws.endcidprs,
                   ws.endufdprs,
                   ws.prssitcod,
                   ws.faxnum,
                   ws.intsrvrcbflg
              from dpaksocor
             where pstcoddig = d_cts00m02.atdprscod
         else
            select sstkprest.sinprsnom,
                   sstkprest.dddcod,
                   sstkprest.telnum,
                   sstkprest.endcid,
                   sstkprest.endufd,
                   sstkprest.prssrvstt,
                   sstkprest.faxnum
              into d_cts00m02.nomgrr,
                   d_cts00m02.dddcod,
                   d_cts00m02.teltxt,
                   ws.endcidprs,
                   ws.endufdprs,
                   ws.prssitcod,
                   ws.faxnum
              from sstkprest
             where sinprscod = d_cts00m02.atdprscod
         end if
         if sqlca.sqlcode  =  notfound   then
            error " Prestador nao cadastrado!"
            next field atdprscod
         end if

         let d_cts00m02.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs

         if ws.prssitcod  <>  "A"   then
            display d_cts00m02.nomgrr     to nomgrr
            display d_cts00m02.cidufdprs  to cidufdprs
            display d_cts00m02.dddcod     to dddcod
            display d_cts00m02.teltxt     to teltxt

            case ws.prssitcod
               when "C" error " Prestador com cadastro cancelado!"
               when "P" error " Prestador com cadastro em proposta!"
               when "B" error " Prestador com cadastro bloqueado!"
            end case
            next field atdprscod
         end if
      else

         let l_celdddcod_veic = null
         let l_celtelnum_veic = null
         let l_celdddcod_soco = null
         let l_celtelnum_soco = null

         display l_celdddcod_veic to celdddcod_veic
         display l_celtelnum_veic to celtelnum_veic
         display l_celdddcod_soco to celdddcod_soco
         display l_celtelnum_soco to celtelnum_soco

         initialize d_cts00m02.nomgrr    , d_cts00m02.dddcod,
                    d_cts00m02.teltxt    , d_cts00m02.cidufdprs,
                    d_cts00m02.c24nomctt , d_cts00m02.atdvclsgl,
                    d_cts00m02.srrcoddig , d_cts00m02.srrabvnom,
                    d_cts00m02.atdcstvlr , d_cts00m02.pasasivcldes,
                    d_cts00m02.socvclcod , d_cts00m02.socvcldes,
                    ws.endcidprs         , ws.endufdprs,
                    d_cts00m02.txivlr to null

         display by name d_cts00m02.nomgrr,
                         d_cts00m02.cidufdprs,
                         d_cts00m02.dddcod,
                         d_cts00m02.teltxt,
                         d_cts00m02.c24nomctt,
                         d_cts00m02.atdvclsgl,
                         d_cts00m02.srrcoddig,
                         d_cts00m02.srrabvnom,
                         d_cts00m02.atdcstvlr,
                         d_cts00m02.pasasivcldes
      end if

      #--------------------------------------------------------------------
      # Verifica se a liberacao do servico nao foi cancelada
      #--------------------------------------------------------------------
      select atdlibflg
        into ws.atdlibflg
        from datmservico
       where atdsrvnum  =  param.atdsrvnum  and
             atdsrvano  =  param.atdsrvano

      if ws.atdlibflg         = "N"  and
         d_cts00m02.atdetpcod >= 3   and
         d_cts00m02.atdetpcod <= 4   then
         error " Servico nao liberado nao pode ser acionado!"
         next field atdetpcod
      end if

      display d_cts00m02.nomgrr     to  nomgrr
      display d_cts00m02.cidufdprs  to  cidufdprs
      display d_cts00m02.dddcod     to  dddcod
      display d_cts00m02.teltxt     to  teltxt
      display d_cts00m02.prsloc     to  prsloc   attribute (reverse)

      if ws.atdsrvorg = 16 then

         # BUSCA O CEL DO VEICULO
         call cts00m03_cel_veiculo(d_cts00m02.socvclcod)
              returning l_celdddcod_veic, l_celtelnum_veic, l_mdtcod

         # BUSCA O CEL DO SOCORRISTA
         call cts00m03_cel_socorr(d_cts00m02.srrcoddig)
              returning l_celdddcod_soco, l_celtelnum_soco

         display l_celdddcod_veic to celdddcod_veic
         display l_celtelnum_veic to celtelnum_veic
         display l_celdddcod_soco to celdddcod_soco
         display l_celtelnum_soco to celtelnum_soco

         display d_cts00m02.c24nomctt to nomgrr
         display d_cts00m02.srrabvnom to nomgrr
         display d_cts00m02.atdprvdat to atdprvdat
         display d_cts00m02.dstqtd    to dstqtd
      end if

   before field c24nomctt
      display by name d_cts00m02.c24nomctt attribute (reverse)

   after field c24nomctt
      display by name d_cts00m02.c24nomctt

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field atdprscod
      end if

       #if ws.atdsrvorg  =   2    and     #--> Assist. Passageiro TAXI
       #   ws.asitipcod  =   5    then    #--> Hospedagem
       #   next field srrcoddig
       #else
          if (ws.atdsrvorg  =   2 and ws.asitipcod  <>   5) or      #--> Assist. Passageiro
             ws.atdsrvorg  =   3 or      #--> Hospedagem
             ws.atdsrvorg  =  16 then    #--> Sinistro Transportes
             next field envtipcod
          end if
       #end if

   before field atdvclsgl

      if d_cts00m02.atdvclsgl is not null then
         display by name d_cts00m02.atdvclsgl attribute (reverse)
      else
         if (ws.atdsrvorg  = 2 and ws.asitipcod <> 5) or ws.atdsrvorg  = 3 then
            next field srrcoddig
         end if
      end if

  after field atdvclsgl
      display by name d_cts00m02.atdvclsgl

      if fgl_lastkey()  =  fgl_keyval("up")   or
         fgl_lastkey()  =  fgl_keyval("left") then
         next field c24nomctt
      end if

      if  d_cts00m02.txivlr is null then #Valor do serviço de taxi do portal.

       if d_cts00m02.atdvclsgl is not null  and
          ws.atdetptipcod = 1               then
          error " Sigla do veiculo nao deve ser informada para",
                " servico nao acionado!"
          next field atdvclsgl
       end if

       if  l_atdvclsgl is not null and l_atdvclsgl <> " " and
           d_cts00m02.atdvclsgl <> l_atdvclsgl  and
           (d_cts00m02.atdetpcod <> 1 and d_cts00m02.atdetpcod <> 5 and d_cts00m02.atdetpcod <> 10) then
           error "Veiculo informado nao pode ser alterado. (1)"
           let d_cts00m02.atdvclsgl = l_atdvclsgl
           next field atdvclsgl
       end if

       #--------------------------------------------------------------------
       # Verifica se para o prestador deve ser informado veiculo
       #--------------------------------------------------------------------
       initialize ws.vclctrposqtd       to null
       initialize d_cts00m02.socvclcod  to null
       initialize d_cts00m02.socvcldes  to null
       initialize d_cts00m02.mdtcod     to null
       initialize d_cts00m02.atdimpcod  to null
       initialize ws.pstcoddig          to null
       initialize ws.c24atvcod          to null
       initialize ws.atdsrvnum          to null
       initialize ws.atdsrvano          to null
       initialize ws.vcldtbgrpcod       to null
       initialize ws.socoprsitcod       to null
       initialize ws.vclcoddig          to null
       initialize ws.srrcoddig          to null

       let m_descricao = d_cts00m02.socvclcod, ' ', d_cts00m02.socvcldes
       display m_descricao to socvcldes

       select count(*)
         into ws.vclctrposqtd
         from datkveiculo
        where pstcoddig    = d_cts00m02.atdprscod
          and socctrposflg = "S"
          and socoprsitcod =  1

       if ws.vclctrposqtd = 0 then    #--> Prestador sem veiculo controlado
          #if d_cts00m02.atdvclsgl  is not null   then
          #   error " Para este prestador nao deve ser informado veiculo!"
          #   next field atdvclsgl
          #end if
          next field srrcoddig
       end if

       #-----------------------------------------------------------------
       # Nao e' necessario informar sigla do veiculo para RPT
       #-----------------------------------------------------------------

              #if d_cts00m02.atdvclsgl  is null then
       #   if d_cts00m02.atdprscod  =  1   or     # Frota Porto Seguro
       #      d_cts00m02.atdprscod  =  4   or     # Sucursal Rio de Janeiro
       #      d_cts00m02.atdprscod  =  8   or     # Sucursal Salvador
       #      ws.atdsrvorg          <>  5  then   # R.P.T.
       #      error " Sigla do veiculo deve ser informada!"
       #      next field atdvclsgl
       #   end if
       #else
       if  d_cts00m02.atdvclsgl is not null and d_cts00m02.atdvclsgl <> " " then

                 #-------------------------------------------------------------
          # Busca/verifica os dados do veiculo
          #-------------------------------------------------------------

          select pstcoddig,
                 socvclcod,
                 socoprsitcod,
                 atdimpcod,
                 mdtcod,
                 vclcoddig,
                 pgrnum
            into ws.pstcoddig,
                 d_cts00m02.socvclcod,
                 ws.socoprsitcod,
                 d_cts00m02.atdimpcod,
                 d_cts00m02.mdtcod,
                 ws.vclcoddig,
                 ws.pgrnum
            from datkveiculo
           where atdvclsgl  =  d_cts00m02.atdvclsgl

          if sqlca.sqlcode  =  notfound   then
             error " Sigla do veiculo nao cadastrada!"
             next field atdvclsgl
          end if

          if salva.socvclcod <> 0   and   # veic selecionado na cts00m20 (ruiz)
             salva.socvclcod is not null then
             if salva.socvclcod <> d_cts00m02.socvclcod  then
                error "Veiculo diferente do Selecionado"
                next field atdvclsgl
             end if
          end if

          call cts15g00 (ws.vclcoddig)  returning d_cts00m02.socvcldes

          let m_descricao = d_cts00m02.socvclcod, ' ', d_cts00m02.socvcldes
          display m_descricao to socvcldes

          if d_cts00m02.atdprscod <> ws.pstcoddig    then
             error " Veiculo nao esta vinculado ao prestador informado!"
             next field atdvclsgl
          end if

          if ws.socoprsitcod  <>  1   then
             error " Veiculo bloqueado/cancelado!"
             next field atdvclsgl
          end if

          #---------------------------------------------------------------
          # Verifica se o veiculo esta em servico (Exceto V.Previa)
          #---------------------------------------------------------------
          select atdsrvnum,
                 atdsrvano,
                 c24atvcod,
                 vcldtbgrpcod,
                 srrcoddig
            into ws.atdsrvnum,
                 ws.atdsrvano,
                 ws.c24atvcod,
                 ws.vcldtbgrpcod,
                 ws.srrcoddig
            from dattfrotalocal
           where dattfrotalocal.socvclcod = d_cts00m02.socvclcod

          if sqlca.sqlcode  =  notfound   then
             error " Posicao da frota nao encontrada!"
             next field atdvclsgl
          end if

          if salva.atdetpcod       >=  1   and     #--> Liberado
             salva.atdetpcod       <=  2   and     #--> Nao liberado
             d_cts00m02.atdetpcod  >=  3   and     #--> Conclui/Acompanha
             d_cts00m02.atdetpcod  <=  4   then    #--> Conclui

      ### REGRA RETIRADA A PEDIDO DO LUIS 28/09/2009
             ###if ws.atdsrvorg       =   15  and
             ###   ws.vcldtbgrpcod    <>  7   then
             ###      error " Veiculo nao e do Grupo JIT!"
             ###      next field atdvclsgl
             ###end if

             if ws.atdsrvorg  <>   10    then

                if ws.c24atvcod  <>  "QRV"   then
                   if (param.atdsrvnum  <>  ws.atdsrvnum   and
                       param.atdsrvnum  <>  ws.atdsrvano)       or
                      (ws.atdsrvnum     is null   or
                       ws.atdsrvnum     is null)                then
                      error " Veiculo nao esta' em QRV!"
                      next field atdvclsgl
                   end if
                else
                   if ws.srrcoddig  is null   then
                      error " Veiculo nao possui socorrista informado!"
                      next field atdvclsgl
                   end if
                   let d_cts00m02.srrcoddig  =  ws.srrcoddig
                   display by name d_cts00m02.srrcoddig
                end if
             else
                let d_cts00m02.srrcoddig  =  ws.srrcoddig
                display by name d_cts00m02.srrcoddig
             end if
          end if
       else

       if  l_atdvclsgl is not null and l_atdvclsgl <> " " and
           d_cts00m02.atdvclsgl <> l_atdvclsgl  and
           (d_cts00m02.atdetpcod <> 1 and d_cts00m02.atdetpcod <> 5 and d_cts00m02.atdetpcod <> 10) then
           error "Veiculo informado nao pode ser alterado. (2)"
           let d_cts00m02.atdvclsgl = l_atdvclsgl
           next field atdvclsgl
       end if

                 if  l_atdvclsgl is null or l_atdvclsgl = " " then
                     if  ws.vclctrposqtd > 0 then
                         call cts08g01("A","I","ATENCAO",
                                               "ESTE PRESTADOR POSSUI GPS NA FROTA",
                                               "PRIORIZE O ACIONAMENTO POR GPS.",
                                               "DESEJA ACIONAR SEM VIATURA MESMO ASSIM?")
                              returning ws.confirma

                         if  ws.confirma = 'S' then
                             let d_cts00m02.srrcoddig = ""
                             let d_cts00m02.srrabvnom = ""
                             let l_celdddcod_veic = ""
                             let l_celtelnum_veic = ""
                             let l_celdddcod_soco = ""
                             let l_celtelnum_soco = ""

                             display by name d_cts00m02.srrcoddig
                             display by name d_cts00m02.srrabvnom
                             display l_celdddcod_veic to celdddcod_veic
                             display l_celtelnum_veic to celtelnum_veic
                             display l_celdddcod_soco to celdddcod_soco
                             display l_celtelnum_soco to celtelnum_soco

                             next field atdprvdat
                         else
                             let ws.grupo = 2

                             let ws.atividade = "QRV"

                             if ws.atdsrvorg  =  10  then
                                let ws.grupo = 10
                                initialize ws.atividade to  null
                             end if

                             if ws.atdsrvorg  =  15  then
                                let ws.grupo = 7
                             end if

                             call cts00m03( 1,
                                            ws.grupo,
                                            ws.atividade,
                                            d_cts00m02.atdprscod,
                                            "",
                                            "",
                                            param.atdsrvnum,
                                            param.atdsrvano)
                                  returning d_cts00m02.atdprscod,
                                            d_cts00m02.atdvclsgl,
                                            d_cts00m02.srrcoddig,
                                            salva.socvclcod,
                                            ws.flag_cts00m20

                             if ws.atdsrvorg <> 16 then
                                select dpaksocor.nomgrr,
                                       dpaksocor.dddcod,
                                       dpaksocor.teltxt,
                                       dpaksocor.endcid,
                                       dpaksocor.endufd,
                                       dpaksocor.prssitcod,
                                       dpaksocor.faxnum,
                                       dpaksocor.intsrvrcbflg
                                  into d_cts00m02.nomgrr,
                                       d_cts00m02.dddcod,
                                       d_cts00m02.teltxt,
                                       ws.endcidprs,
                                       ws.endufdprs,
                                       ws.prssitcod,
                                       ws.faxnum,
                                       ws.intsrvrcbflg
                                  from dpaksocor
                                 where pstcoddig = d_cts00m02.atdprscod
                             else
                                select sstkprest.sinprsnom,
                                       sstkprest.dddcod,
                                       sstkprest.telnum,
                                       sstkprest.endcid,
                                       sstkprest.endufd,
                                       sstkprest.prssrvstt,
                                       sstkprest.faxnum
                                  into d_cts00m02.nomgrr,
                                       d_cts00m02.dddcod,
                                       d_cts00m02.teltxt,
                                       ws.endcidprs,
                                       ws.endufdprs,
                                       ws.prssitcod,
                                       ws.faxnum
                                  from sstkprest
                                 where sinprscod = d_cts00m02.atdprscod
                             end if

                             display by name d_cts00m02.nomgrr
                             display by name d_cts00m02.atdvclsgl
                             display by name d_cts00m02.srrcoddig

                             next field atdvclsgl
                  end if
                     end if
                 else
                     if  d_cts00m02.atdetpcod <> 1 and
                         d_cts00m02.atdetpcod <> 5 and
                         d_cts00m02.atdetpcod <> 10 then
                  error "Veiculo informado nao pode ser alterado. (3)"
                  let d_cts00m02.atdvclsgl = l_atdvclsgl
                  next field atdvclsgl
              end if
                 end if
            end if
 end if

   before field srrcoddig
      display by name d_cts00m02.srrcoddig attribute (reverse)

   after field srrcoddig
      display by name d_cts00m02.srrcoddig

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         if ws.atdsrvorg =  2   or
            ws.atdsrvorg =  3   or
            ws.atdsrvorg =  16  then  # sinistro transportes
            next field c24nomctt
         end if
         next field atdvclsgl
      end if

      if  d_cts00m02.atdvclsgl is not null then
          if d_cts00m02.srrcoddig  is not null   and
             ws.atdetptipcod       =  1          then
             error " Socorrista nao deve ser informado para servico nao acionado!"
             next field srrcoddig
          end if

          #-----------------------------------------------------------------
          # Verifica se para o prestador deve ser informado socorrista
          #-----------------------------------------------------------------
          initialize d_cts00m02.srrabvnom  to null
          initialize ws.pstcoddig          to null
          initialize ws.srrstt             to null

          select count(*)
            into ws.vclctrposqtd
            from datkveiculo
           where pstcoddig    = d_cts00m02.atdprscod
             and socctrposflg = "S"
             and socoprsitcod =  1

          if ws.vclctrposqtd  =  0   then    #--> Prestador sem vcl controlado
             if d_cts00m02.srrcoddig  is not null   then
                error " Para este prestador nao deve ser informado socorrista!"
                next field srrcoddig
             end if
             next field atdprvdat
          end if
          if d_cts00m02.srrcoddig  is null   then
             if ws.atdsrvorg  =  10    or    #--> Vistoria Previa
                #ws.atdsrvorg  =  5     or    #--> Sinistro Transportes
                ws.atdsrvorg  =  16    then  #--> R.P.T.
                next field envtipcod
             end if
             error " Socorrista deve ser informado!"
             call ctn45c00(d_cts00m02.atdprscod, "")
                  returning d_cts00m02.srrcoddig
             next field srrcoddig
          end if
          select srrabvnom,
                 srrstt
            into d_cts00m02.srrabvnom,
              ws.srrstt
            from datksrr
           where srrcoddig  =  d_cts00m02.srrcoddig
          if sqlca.sqlcode  =  notfound   then
             error " Socorrista nao cadastrado!"
             call ctn45c00(d_cts00m02.atdprscod, "")
                  returning d_cts00m02.srrcoddig
             next field srrcoddig
          end if

          display by name d_cts00m02.srrabvnom

          #BURINI
          #if  ws.atdsrvorg = 2 and ws.asitipcod = 5 then
          #    select socvclcod
          #      into d_cts00m02.socvclcod
          #      from datkveiculo
          #     where atdvclsgl  =  d_cts00m02.atdvclsgl
          #end if

          # BUSCA O CEL DO VEICULO
          call cts00m03_cel_veiculo(d_cts00m02.socvclcod)
               returning l_celdddcod_veic, l_celtelnum_veic, l_mdtcod

          # BUSCA O CEL DO SOCORRISTA
          call cts00m03_cel_socorr(d_cts00m02.srrcoddig)
               returning l_celdddcod_soco, l_celtelnum_soco

          display l_celdddcod_veic to celdddcod_veic
          display l_celtelnum_veic to celtelnum_veic
          display l_celdddcod_soco to celdddcod_soco
          display l_celtelnum_soco to celtelnum_soco

           if ws.srrstt  <>  1   then
              error " Socorrista bloqueado/cancelado!"
              next field srrcoddig
           end if

           declare c_datrsrrpst  cursor for
             select pstcoddig, vigfnl
               from datrsrrpst
              where srrcoddig  =  d_cts00m02.srrcoddig
              order by vigfnl desc

           open  c_datrsrrpst
           fetch c_datrsrrpst  into  ws.pstcoddig
           close c_datrsrrpst

           if ws.pstcoddig  is null   then
              error " Socorrista nao possui vinculo com nenhum prestador!"
              next field srrcoddig
           end if

           if d_cts00m02.atdprscod  <>  ws.pstcoddig   then
              error " Socorrista nao esta vinculado ao prestador informado!"
              next field srrcoddig
           end if
       else
           let d_cts00m02.srrcoddig = ""
           display by name d_cts00m02.srrcoddig
       end if

       next field atdprvdat

   before field atdprvdat
      display by name d_cts00m02.atdprvdat
      display by name d_cts00m02.dstqtd
      if d_cts00m02.atdprvdat is not null then
         next field envtipcod
      else
          #if  d_cts00m02.atdvclsgl is not null then

              # ---> VEICULO COM SIGLA

              # --ASSUMIR 20 MINUTOS DE PREVISAO PARA O SOCORRISTA QUANDO NAO
              # --TEM CALCULO AUTOMATICO PELO SISTEMA DEVIDO A FALTA DE INDEXACAO
              # --DO ENDERECO POR MAPA - PSI 197092 - CONTROLE DE FROTA
              # PSI 205850

              select  min(s.cidsedcod)
              into    l_cidsedcod
              from    glakcid g , outer datrcidsed s
              where   g.cidcod = s.cidcod
              and     g.ufdcod = a_cts00m02[1].ufdcod
              and     g.cidnom = a_cts00m02[1].cidnom

              if l_cidsedcod = 7043 then
                  # Rio de Janeiro
                  let d_cts00m02.atdprvdat = "00:40"
              else
                  # Outras cidades
                  let d_cts00m02.atdprvdat = "00:20"
              end if
              # FIM PSI 205850
          #end if
      end if

  after field atdprvdat
      display by name d_cts00m02.atdprvdat
      if fgl_lastkey() = fgl_keyval("up") or
         fgl_lastkey() = fgl_keyval("left") then
         let d_cts00m02.atdprvdat = null
         next field srrcoddig
      end if
      if ws.atdsrvorg = 2 and #--> Assist. Passageiro TAXI
         ws.asitipcod = 5 then
         next field pasasivcldes
      else
         next field envtipcod
      end if

   before field pasasivcldes
      display by name d_cts00m02.pasasivcldes attribute (reverse)

   after field pasasivcldes
      --> Fabrica de Software - Teresinha Silva - OSF 25143
      if ws.atdsrvorg =  2   and
         ws.asitipcod =  5   then
         display by name l_descveiculo   attribute (reverse)
         if d_cts00m02.pasasivcldes is null then
            error 'Informe (P)Passeio ou (V)Van'
            next field pasasivcldes
         end if
         if d_cts00m02.pasasivcldes is not null and
            d_cts00m02.pasasivcldes <> 'P'      and
            d_cts00m02.pasasivcldes <> 'V'      then
            error 'Informe (P)Passeio ou (V)Van'
            next field pasasivcldes
         end if
         if d_cts00m02.pasasivcldes = 'P' then
            let l_descveiculo = 'Passeio'
         else
            let l_descveiculo = 'Van'
         end if
         display by name l_descveiculo
      end if
      # -- OSF 25143 -- #

      display by name d_cts00m02.pasasivcldes

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field srrcoddig
      end if

      if d_cts00m02.atdetpcod    >= 3     and
         d_cts00m02.atdetpcod    <= 4     and
         d_cts00m02.pasasivcldes is null  then
        error " Para envio de taxi e' necessario informar descricao do veiculo!"
         next field pasasivcldes
      end if

   before field envtipcod
      display by name d_cts00m02.envtipcod attribute (reverse)

   after field envtipcod
      if param.flg_origem = 2 then            # Nao for radio/atendente
         exit input
      end if

      display by name d_cts00m02.envtipcod

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         if salva.atdetpcod = 3 or
            salva.atdetpcod = 4 then
            next field envtipcod
         end if
         if ws.atdsrvorg = 2 or
            ws.atdsrvorg = 3 then
            #if ws.asitipcod = 5 then
            #   next field pasasivcldes
            #else
               next field atdprvdat
            #end if
         else
            if ws.atdsrvorg = 16 then
               next field c24nomctt
            end if
            next field srrcoddig
         end if

      end if

      #-----------------------------------------------------------------
      # Na conclusao exige informar tipo de envio
      #-----------------------------------------------------------------
      if (salva.atdetptipcod  =   1 or d_cts00m02.atdetpcod = 43 or
          d_cts00m02.atdetpcod = 14 or d_cts00m02.atdetpcod = 44 or
          d_cts00m02.atdetpcod = 45 or d_cts00m02.atdetpcod = 5  or
          d_cts00m02.atdetpcod = 3  or d_cts00m02.atdetpcod = 7)   and
         ws.atdetptipcod     <> 1   then

         if (d_cts00m02.envtipcod  is null)  or
            (d_cts00m02.envtipcod  <>  0     and
             d_cts00m02.envtipcod  <>  1     and
             d_cts00m02.envtipcod  <>  2)     then
            #d_cts00m02.envtipcod  <>  3)    then PSI208744
            error " Tipo envio: (0)Telefone, (1)GPS, (2)Internet! " #(3) Fax
            next field envtipcod
         end if
      end if

      if d_cts00m02.envtipcod  =  1   or
         d_cts00m02.envtipcod  =  2   then
        #d_cts00m02.envtipcod  =  3 then PSI208744
         if d_cts00m02.atdprscod is null then
            error " Prestador nao informado! Nao e' possivel a transmissao!"
            next field envtipcod
         end if
      end if

      #--------------------------------------------------------------------
      # GPS / MDT / Pager(Impressao Remota)
      #--------------------------------------------------------------------
      if d_cts00m02.envtipcod  =  1  then

         if ws.atdsrvorg =  4    or
            ws.atdsrvorg =  6    or
            ws.atdsrvorg =  1    or
            ws.atdsrvorg =  10   or
            ws.atdsrvorg =  5    or
            ws.atdsrvorg =  7    or
            ws.atdsrvorg =  17   or   # repalce - congenere
            ws.atdsrvorg =  9    or
            ws.atdsrvorg =  13   or
            ws.atdsrvorg =  3    or
           (ws.atdsrvorg =  2    and  (ws.asitipcod = 10  or ws.asitipcod = 5)) or
            ws.atdsrvorg =  15   and
            d_cts00m02.atdvclsgl is not null then
         else
            error " Transmissao para: Remocao, DAF, Socorro, VP, RPT, Replace, JIT!"
            next field envtipcod
         end if

         if ws.atdsrvorg =  4    or
            ws.atdsrvorg =  6    or
            ws.atdsrvorg =  1    or
            ws.atdsrvorg =  10   or
            ws.atdsrvorg =  5    or
            ws.atdsrvorg =  7    or
            ws.atdsrvorg =  17   or
            ws.atdsrvorg =  9    or
            ws.atdsrvorg =  13   or
            ws.atdsrvorg =  15   then
            #PSI201022 - inicio
            if d_cts00m02.atdetpcod <> 3    ### Servico acionado ou cancelado
            and d_cts00m02.atdetpcod <> 4
            and d_cts00m02.atdetpcod <> 5
            and d_cts00m02.atdetpcod <> 10  then
            #PSI201022 - fim
               error " Servico nao concluido! Nao e' possivel",
                     " realizar a transmissao!"
               next field envtipcod
            end if
         end if
         if ws.atdsrvorg         =  10  and
            d_cts00m02.atdetpcod =  5   then
            error " Servico cancelado! Nao e' possivel realizar a transmissao!"
            next field envtipcod
         end if

         if ws.atdsrvorg  =   3   or
            (ws.atdsrvorg  =   2 and ws.asitipcod <> 5) then
            let ws.transmite  =  TRUE
            exit input
         end if

         if d_cts00m02.atdvclsgl is null then
            error " Sigla veiculo nao informada! Nao e' possivel a transmissao!"
            next field envtipcod
         end if

         if d_cts00m02.socvclcod  is null   then
            error " Codigo do veiculo nao encontrado!"
            next field envtipcod
         end if

         if (d_cts00m02.atdimpcod  is null and
             d_cts00m02.mdtcod     is null     ) and
            (ws.atdsrvorg = 15 and ws.pgrnum is null) then
            let ws.alerta = "VEICULO ", d_cts00m02.atdvclsgl clipped," NAO POSSUI"
            call cts08g01("A","N",ws.alerta, "PAGER/MDT INSTALADO",
                             "","FAVOR TRANSMITIR O SERVICO VIA VOZ !")
                 returning ws.confirma
            next field envtipcod
         end if

         if d_cts00m02.atdimpcod  is not null   then
            select atdimpsit
              into d_cts00m02.atdimpsit
              from datktrximp
             where atdimpcod = d_cts00m02.atdimpcod

            if d_cts00m02.atdimpsit  <>  0   then
               select cpodes into d_cts00m02.impsitdes
                 from iddkdominio
                where cponom = "atdimpsit" and
                      cpocod = d_cts00m02.atdimpsit

               let ws.alerta = " ENCONTRA ", d_cts00m02.impsitdes clipped, "."
               call cts08g01("A","N","NAO E' POSSIVEL REALIZAR A TRANSMISSAO",
                                  "NESTE MOMENTO, POIS O PAGER SE", ws.alerta,
                                  "FAVOR TRANSMITIR O SERVICO VIA VOZ !")
                    returning ws.confirma
               next field envtipcod
            end if
            let ws.transmite  =  TRUE
         end if

         if ws.atdsrvorg = 15 and
            ws.pgrnum is not null then
            let ws.transmite = TRUE
         end if

         if d_cts00m02.mdtcod  is not null   then
            call cts00g03_checa_mdt(1, d_cts00m02.socvclcod)
                 returning ws.erroflg

            if ws.erroflg  =  "S"   then
               next field envtipcod
            end if

            call cts00g03_checa_mdt_msg(param.atdsrvnum,
                                        param.atdsrvano)
                 returning ws.erroflg

            if ws.erroflg  =  "S"   then
               next field envtipcod
            end if

            let ws.transmite  =  TRUE
         end if

      else

         #--------------------------------------------------------------------
         # Envio de FAX (envtipcod =3) -- PSI208744
         #--------------------------------------------------------------------
         if d_cts00m02.envtipcod  =  3  then

            if ws.atdsrvorg <>   4     and
               ws.atdsrvorg <>   6     and
               ws.atdsrvorg <>   1     and
               ws.atdsrvorg <>   5     and
               ws.atdsrvorg <>   7     and
               ws.atdsrvorg <>   17    and
               ws.atdsrvorg <>   9     and
               ws.atdsrvorg <>   13    and
               ws.atdsrvorg <>   3     and
               ws.atdsrvorg <>   2     and
               ws.atdsrvorg <>   18    then
               error " Fax para: Remocao,DAF,Socorro,RPT,Replace,Assist.Passag.,Funeral!"
               next field envtipcod
            end if

            if d_cts00m02.atdetpcod  <=  3   and
               d_cts00m02.atdetpcod  >=  4   then
               error " Servico nao acionado! Nao e' possivel realizar o envio!"
               next field envtipcod
            end if

            if d_cts00m02.atdprscod  <  7   then
               if d_cts00m02.atdprscod  <>  1   and   #--> Sucursal Sao Paulo
                  d_cts00m02.atdprscod  <>  5   and   #--> Prestador no local
                  d_cts00m02.atdprscod  <>  4   then  #--> Sucursal Rio de Janeiro
                  error " Nao deve ser enviado fax para este prestador!"
                  next field envtipcod
               end if
            end if

            if ws.faxnum is null and
               d_cts00m02.atdprscod  <>  5   then   #--> Prestador no local
               error " Prestador nao possui numero de fax cadastrado!"
               next field envtipcod
            end if

            #---------------------------------------------------------------
            # Redireciona servico para o tipo de acionamento especifico
            #---------------------------------------------------------------
            call cts10g01_trx_fax (param.atdsrvnum,
                                   param.atdsrvano,
                                   1,
                                   "PS")
                 returning ws.erroflg

            if ws.erroflg  =  "S"   then
               next field envtipcod
            end if
            let ws.fax = TRUE

         else  --PSI208744 -> Acabou o envio via fax

            #----------------------------------------
            # Envio pela Internet
            #----------------------------------------
            if d_cts00m02.envtipcod  =  2  then
               if ws.intsrvrcbflg = "0" or ws.intsrvrcbflg is NULL then #PSI208744
                  error 'Prestador nao cadastrado para receber serv pela Internet'
                  next field envtipcod
               end if
               if salva.atdetpcod <> d_cts00m02.atdetpcod then
                  # --OBTER SEQUENCIA/ETAPA DO SERVICO PARA INTERNET-- #
                  call cts33g00_inf_internet(param.atdsrvnum,
                                             param.atdsrvano)
                       returning l_resultado,
                                 l_mensagem,
                                 ws.atdetpseq,
                                 ws.atdetpcod

                  if l_resultado = 3 then
                     error l_mensagem sleep 2
                     next field envtipcod
                  end if

                  if d_cts00m02.atdetpcod = 04 or
                     d_cts00m02.atdetpcod = 03 or #RE
                     d_cts00m02.atdetpcod = 07 or #Em Orc.
                     d_cts00m02.atdetpcod = 10 or
                     d_cts00m02.atdetpcod = 13 or
                     d_cts00m02.atdetpcod = 43 or
                     d_cts00m02.atdetpcod = 44 or
                     d_cts00m02.atdetpcod = 45 then
                     let ws.atdetpcod = "0"
                     let ws.etpmtvcod = 0
                  else
                     let ws.atdetpcod = "3"
                     call cts00m28()
                           returning ws.etpmtvcod,  # pop_up motivos
                                     ws.etpmtvdes
                     end if

                     ## AUTO/RE
                     if ws.atdsrvorg = 1 or ws.atdsrvorg = 4 or
                        ws.atdsrvorg = 5 or ws.atdsrvorg = 6 or
                        ws.atdsrvorg = 7 or ws.atdsrvorg = 17 or
                        ws.atdsrvorg = 9 then
                        let l_resultado =
                            fissc101_prestador_sessao_ativa(d_cts00m02.atdprscod
                                                           ,'PSRONLINE')
                     end if

                     ## ASSIT. PASSAGEIRO/HOSPEDAGEM
                     if ws.atdsrvorg = 2 or ws.atdsrvorg = 3 then
                        if ws.asitipcod = 5 then
                           if d_cts00m02.envtipcod <> 1 then  ## Taxi
                              let l_resultado = fissc101_prestador_sessao_ativa(d_cts00m02.atdprscod
                                                                               ,'PSRONLINE')
                           else
                              let ws.transmite  =  true
                           end if
                     else
                        let l_resultado = fissc101_prestador_sessao_ativa(d_cts00m02.atdprscod
                                                                         ,'AGTONLINE')
                     end if

                  end if

                  if not l_resultado then
                     # and ws.ciaempcod <> 43 then
                     let l_prest_conect  = false
                     error 'Prestador nao conectado no Portal de Negocios.'
                     next field envtipcod
                  else
                     let l_prest_conect = true
                  end if

               else
                  # etapa igual
                  ##   PSI208744
                  let srvano = param.atdsrvnum  using "&&&&&&&&",
                               param.atdsrvano  using "&&"

                  open c_cts00m02_008 using srvano
                  fetch c_cts00m02_008 into faxsiscod
                  if sqlca.sqlcode = 100 then
                     open c_cts00m02_009 using param.atdsrvnum,
                                               param.atdsrvano,
                                               param.atdsrvnum,
                                               param.atdsrvano
                     fetch c_cts00m02_009 into envtipcodflg
                     if envtipcodflg = 0 then
                        let envio = "SERVICO JA' ACIONADO/CANCELADO POR TELEFONE !"
                     else
                        if envtipcodflg = 1 then
                           let envio = "SERVICO JA' ACIONADO/CANCELADO POR GPS !"
                        else
                           if envtipcodflg = 2 then
                              let envio = "SERVICO JA' ACIONADO/CANCELADO PELA INTERNET !"
                           else
                              let envio = "ENVIAR SERV POR FAX OU GPS !"
                           end if
                        end if
                     end if
                  else
                     let envio="SERVICO JA' ACIONADO/CANCELADO POR FAX !"
                  end if

                  ## PSI208744 fim

                  if ws.atdetptipcod = 3 then
                     # error "SERVICO JA' ACIONADO/CANCELADO PELA INTERNET !"
                     error envio
                     next field envtipcod
                  else
                     #error "ACOMPANHAMENTO DE SERVICO JA' ENVIADO PELA INTERNET !"
                     error envio
                     next field envtipcod
                  end if
               end if

               if ws.atdsrvorg <>   9     and
                  ws.atdsrvorg <>   13    and
                  (ws.atdsrvorg <> 2 and ws.asitipcod <> 5) then
                  # Nao e' servico RE
               else
                  #---------------------------------------------
                  # Envia mensagem teletrim para servicos RE
                  #---------------------------------------------
                  if d_cts00m02.socvclcod is not null then
                     call cts00g04_msgsrv(param.atdsrvnum,
                                          param.atdsrvano,
                                          d_cts00m02.socvclcod,
                                          d_cts00m02.atdetpcod,
                                          d_cts00m02.atdprscod,
                                          "SRV","O")
                  end if
               end if
            end if -- tipo 2
         end if -- Termina if do tipo de envio 3
      end if--Termina if do tipo de envio 1 PSI208744

      open c_cts00m02_009 using param.atdsrvnum, # CT687529
                                param.atdsrvano,
                                param.atdsrvnum,
                                param.atdsrvano

      fetch c_cts00m02_009 into envtipcodflg

      if (salva.atdetpcod = 3 or salva.atdetpcod = 4) and
         (d_cts00m02.atdetpcod <> 04 and
          d_cts00m02.atdetpcod <> 03 and #RE
          d_cts00m02.atdetpcod <> 07 and #Em Orc.
          d_cts00m02.atdetpcod <> 10 and
          d_cts00m02.atdetpcod <> 13 and
          d_cts00m02.atdetpcod <> 43 and
          d_cts00m02.atdetpcod <> 44 and
          d_cts00m02.atdetpcod <> 45) and
         (envtipcodflg = 2 and d_cts00m02.envtipcod <> 2) then

          call cts33g00_inf_internet(param.atdsrvnum,
                                     param.atdsrvano)

                 returning l_resultado,
                           l_mensagem,
                           ws.atdetpseq,
                           ws.atdetpcod
          if ws.atdetpcod <> 3 then
             call cts00m28() returning ws.etpmtvcod,  # pop_up motivos
                                       ws.etpmtvdes
             let ws.atdetpcod = 3
             let l_prest_conect = true
             let d_cts00m02.envtipcod = 2
          end if
      end if

      if l_demanda = true then
         # --ATUALIZAR O PRESTADOR NO SERVICO COM DEMANDA-- #
         call cts10g09_registrar_prestador(1,
                                           param.atdsrvnum,
                                           param.atdsrvano,
                                           d_cts00m02.socvclcod,
                                           d_cts00m02.srrcoddig,
                                           d_cts00m02.srrltt,
                                           d_cts00m02.srrlgt,
                                           "")

              returning l_resultado, l_mensagem

         if l_resultado <> 1 then
            error l_mensagem sleep 2
            let l_erro = true
            exit input
         end if

         # --CHAMAR NOVAMENTE, POIS PODE HAVER ALTERACOES NO MULTIPLO ATE ESTE PONTO-- #
         #apenas para servico RE
         if ws.atdsrvorg = 9 then

            call cts29g00_obter_multiplo(2, l_atdsrvnum_original, l_atdsrvano_original)
                 returning l_resultado,
                           l_mensagem,
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

            # --ATUALIZAR O PRESTADOR NO SERVICO MULTIPLO COM DEMANDA-- #
            if  l_atualiza_todos = 'S' then

                for l_contador = 1 to 10

                   if am_cts29g00[l_contador].atdmltsrvnum is not null then

                      call cts10g09_registrar_prestador(1,
                                                        am_cts29g00[l_contador].atdmltsrvnum,
                                                        am_cts29g00[l_contador].atdmltsrvano,
                                                        d_cts00m02.socvclcod,
                                                        d_cts00m02.srrcoddig,
                                                        d_cts00m02.srrltt,
                                                        d_cts00m02.srrlgt,
                                                        "")

                            returning l_resultado, l_mensagem

                      if l_resultado <> 1 then
                         exit for
                      end if

                   end if

                end for
            end if

            if l_resultado = 3 then
               error l_mensagem sleep 2
               let l_erro = true
               exit input
            end if
         end if

      else ## da demanda

         if ws.atdsrvorg = 9 then   #apenas para servicos de RE
            call cts29g00_obter_qtd_multiplo(param.atdsrvnum, param.atdsrvano)
                 returning  l_resultado, l_mensagem, l_quantidade

            if l_resultado =3  then
               error l_mensagem
               next field envtipcod
            end if

            if l_atualiza_todos = "N" and l_quantidade > 0 then
               call cts29g00_remover_multiplo(param.atdsrvnum, param.atdsrvano)
                    returning l_resultado, l_mensagem

               if l_resultado = 3 then
                  error l_mensagem
                  next field envtipcod
               else
                  # para acionar/cancelar somente o original
                  initialize am_cts29g00 to null
               end if
            end if
         end if
      end if

   on key (interrupt)
      if param.flg_origem = 1  then
         call cts08g01("A","S","","","DESEJA ABANDONAR O ACIONAMENTO ?","")
              returning ws.confirma
         if ws.confirma = "S"   then
            let int_flag = true
            exit input
         else
            let int_flag = false
            continue input
         end if
      else
         exit input
      end if

   #--------------------------------------------------------------------
   # Pesquisa coordenadas do serviço
   #--------------------------------------------------------------------
   on key (F3)
      if l_demanda = true then
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
          if param.flg_origem <> 2 then            # for radio/atendente
             call cts00m02_coordenadas(param.atdsrvnum,
                                       param.atdsrvano)
          end if
      end if
   #--------------------------------------------------------------------
   # Exibe Posicionamento da Viatura no Servico
   #--------------------------------------------------------------------
   on key (F4) # PSI 241407 - Adriano

      if l_demanda = true then
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
         if param.flg_origem <> 2 then            # for radio/atendente

            if l_acionamentoWEB then

               error "Consultando situacao do veículo acionado. Aguarde..."
               call ctx34g02_andamento(param.atdsrvnum, param.atdsrvano)
                    returning l_retposacnweb.*

               if l_retposacnweb.recatddes is not null then
                  if l_retposacnweb.srvidxflg <> 'S' then
                     error "Posicao indisponivel. Servico Nao Indexado." sleep 2
                  else
                     if l_retposacnweb.recatdsgl = "QRU" then
                        error "Posicao indisponivel. Socorrista nao deu QRU_REC" sleep 2
                     else
                       call cts00m02_min(l_retposacnweb.gpsatldat, l_retposacnweb.gpsatlhor)
                             returning ws.tmp_msg

                       if ws.tmp_msg <= l_temp_lim then
                          # EXIBE POPUP COM POSICAO
                          call cts08g06_acnweb(l_retposacnweb.srvidxflg,
                                               l_retposacnweb.recatddes,
                                               l_retposacnweb.srrnom   ,
                                               l_retposacnweb.gpsatldat,
                                               l_retposacnweb.gpsatlhor,
                                               l_retposacnweb.recatdsgl,
                                               l_retposacnweb.lgdnom   ,
                                               l_retposacnweb.lgdnum   ,
                                               l_retposacnweb.brrnom   ,
                                               l_retposacnweb.cidnom   ,
                                               l_retposacnweb.ufdsgl   ,
                                               l_retposacnweb.lttnum   ,
                                               l_retposacnweb.lgtnum   ,
                                               l_retposacnweb.dstrot   ,
                                               l_retposacnweb.dstret   ,
                                               l_retposacnweb.tmprot   ,
                                               l_retposacnweb.telnumtxt,
                                               l_retposacnweb.nxtidt   ,
                                               l_retposacnweb.nxtnumtxt)
                       else
                          error "Posicao indisponivel. Sem sinal atualizado." sleep 2
                       end if

                     end if
                  end if
               else
                  if salva.atdetpcod = 3  or
                     salva.atdetpcod = 4  or
                     salva.atdetpcod = 10 then # Acionado
                     error "Posicao indisponivel. Servico ja executado." sleep 2
                  else
                     error "Posicao indisponivel. Nenhum prestador foi acionado" sleep 2
                  end if
               end if

               error ""

            else  # AcionamentoWeb DESATIVADO
               open  c_cts00m02_011 using param.atdsrvnum, param.atdsrvano
               fetch c_cts00m02_011 into ws.mdtbotprgseq_msg
                                      ,ws.mdtcod_msg
                                      ,ws.socvclcod_msg

               if sqlca.sqlcode = 0 then
                   if ws.mdtbotprgseq_msg = 3 then # FIM

                       open  c_cts00m02_015 using ws.socvclcod_msg
                       fetch c_cts00m02_015 into ws.atdvclsgl_msg

                       call ctn44c00(2, ws.atdvclsgl_msg, "")

                   else
                       open  c_cts00m02_012 using ws.mdtcod_msg
                       fetch c_cts00m02_012 into  ws.mdtmvtseq_msg
                                               ,ws.caddat_msg
                                               ,ws.cadhor_msg
                                               ,ws.lclltt_msg
                                               ,ws.lcllgt_msg

                       if sqlca.sqlcode = 0 then
                           let l_count = 0
                           while (ws.lclltt_msg is null or ws.lclltt_msg = 0  or
                                  ws.lcllgt_msg is null or ws.lcllgt_msg = 0) and
                                 (l_count < 10)
                                open  c_cts00m02_016 using ws.mdtcod_msg
                                                        ,ws.mdtmvtseq_msg
                                fetch c_cts00m02_016 into  ws.mdtmvtseq_msg
                                                        ,ws.caddat_msg
                                                        ,ws.cadhor_msg
                                                        ,ws.lclltt_msg
                                                        ,ws.lcllgt_msg
                                let l_count = l_count + 1
                           end while
                           if (ws.lclltt_msg is null or ws.lclltt_msg = 0  or
                               ws.lcllgt_msg is null or ws.lcllgt_msg = 0) then
                              error 'Sinal do MDT ', ws.mdtcod_msg,' nao encontrado' sleep 2
                              next field atdetpcod
                           end if
                       else
                           if sqlca.sqlcode = 100 then
                               error 'Sinal do MDT ', ws.mdtcod_msg,' nao encontrado' sleep 2
                               next field atdetpcod
                           else
                               error "Erro (ccts00m02032): ", sqlca.sqlcode, " na busca do ultimo sinal do mdt ", ws.mdtcod_msg sleep 2
                               next field atdetpcod
                           end if
                       end if

                       call cts00m02_min(ws.caddat_msg, ws.cadhor_msg)
                            returning ws.tmp_msg

                       let ws.tipo_msg = 1
                       if ws.tmp_msg <= l_temp_lim then
                           let ws.tipo_msg = 2
                           if ws.mdtbotprgseq_msg = 1 then # QRU RECEB

                               call cts40g03_data_hora_banco(2)
                               returning ws.atldat,
                                         ws.atlhor

                               open  c_cts00m02_014 using ws.mdtcod_msg
                                                       ,ws.atldat
                                                       ,ws.atlhor
                               fetch c_cts00m02_014 into  l_status

                               if sqlca.sqlcode = 100 then
                                   select atdhorpvt, atdhor
                                   into ws.atdhorpvt, ws.atdhor
                                   from datmservico
                                   where atdsrvnum = param.atdsrvnum
                                     and atdsrvano = param.atdsrvano

                                  if cts00m02_prazo(ws.atdhor, ws.atdhorpvt) then # NO PRAZO
                                       let ws.tipo_msg = 3
                                   else # ATRASADO
                                       let ws.tipo_msg = 4
                                   end if
                               else
                                  if sqlca.sqlcode <> 0 then
                                      error "Erro: ", sqlca.sqlcode, " na busca de mesnsagem do prazo de atendimento" sleep 2
                                      next field atdetpcod
                                  end if
                               end if
                           end if
                       end if
                       open  c_cts00m02_013 using  param.atdsrvnum
                                                ,param.atdsrvano # Local de Origem
                       fetch c_cts00m02_013 into  ws.lclltt_srv
                                               ,ws.lcllgt_srv
                                               ,ws.ufdcod_srv
                                               ,ws.c24lclpdrcod

                       if sqlca.sqlcode = notfound or ws.c24lclpdrcod <> 3 then # nao indexado
                           let ws.lclltt_srv = null
                           let ws.lcllgt_srv = null
                           let ws.ufdcod_srv = null
                       end if
                       close  c_cts00m02_012

                       call cts08g06(param.atdsrvnum
                                    ,param.atdsrvano
                                    ,ws.lclltt_srv
                                    ,ws.lcllgt_srv
                                    ,ws.ufdcod_srv
                                    ,ws.socvclcod_msg
                                    ,ws.lclltt_msg
                                    ,ws.lcllgt_msg
                                    ,ws.tmp_msg
                                    ,ws.tipo_msg)
                   end if
               else
                   if salva.atdetpcod = 3  or
                      salva.atdetpcod = 4  or
                      salva.atdetpcod = 10 then # Acionado
                       error "Posicao indisponivel. Socorrista nao deu QRU_REC" sleep 2
                   else
                       error "Posicao indisponivel. Nenhum socorrista foi acionado" sleep 2
                   end if
               end if

            end if
         end if
      end if

   on key (F5)

      let l_mensagem = null
      if l_demanda = true then   ### PSI179345 - Gustavo
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
         if ws.atdsrvorg <> 2 and ws.atdsrvorg <> 3 then
            #error " Funcao nao disponivel!"
            call ctx25g03_percurso(m_rota)
         else
            if ws.atdsrvorg    =  2   and
               ws.asitipcod = 10   then

               let l_aerciacod = null
               let l_vooopc = null

               call cts11m09_voo(param.atdsrvnum ,param.atdsrvano)
                    returning l_aerciacod, l_vooopc

               if l_aerciacod is not null then

                  call ctc10g00_dados_cia(2 ,l_aerciacod)
                       returning l_retorno ,l_mensagem, l_mensagem
                                ,l_aerpsgrsrflg ,l_aerpsgemsflg

                  call cts00m02_ciaaerea(param.atdsrvnum,param.atdsrvano,
                                         l_vooopc)
                       returning l_aerpsgrsrflg ,l_aerpsgemsflg

                  if l_aerpsgrsrflg = 'S' and l_aerpsgemsflg = 'S' then
                     call cts08g02("A","S","", "",
                                   "RESERVAR OU EMITIR A PASSAGEM ?", "")
                          returning ws.confirma

                     if ws.confirma matches "[Rr]" then
                        let d_cts00m02.atdetpcod = 45
                     else
                        let d_cts00m02.atdetpcod = 44
                     end if
                  else
                     if l_aerpsgrsrflg = 'S' then
                        let d_cts00m02.atdetpcod = 45
                     end if

                     if l_aerpsgemsflg = 'S' then
                        let d_cts00m02.atdetpcod = 44
                     end if
                  end if

                  display by name d_cts00m02.atdetpcod
               end if
            end if

            if ws.atdsrvorg =  3 then
               call cts22m01_iniciar(param.atdsrvnum
                                    ,param.atdsrvano
                                    ,g_documento.acao)
            end if
         end if
      end if

   #--------------------------------------------------------------------
   # Exibe Etapas
   #--------------------------------------------------------------------
   on key (F6)

      open window w_branco at 04,02 with 04 rows,78 columns
      call cts00m11(param.atdsrvnum, param.atdsrvano)
      close window w_branco

   #--------------------------------------------------------------------
   # Pesquisa Prestador
   #--------------------------------------------------------------------
   on key (F7)

      if g_setexplain = 1 then
         call cts01g01_setetapa("cts00m02 - Acionando com F7")
      end if

      if (g_documento.acao = "CON" or g_documento.acao = "REC") and
          m_atdfnlflg = "A" then
          call cts08g01("A", "N", "","SERVICO EM PROCESSO DE " ,
                                    "ACIONAMENTO AUTOMATICO ", "")
                 returning l_resultado
          next field atdetpcod
      end if

      if l_demanda = true then   ### PSI179345
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
         if param.flg_origem <> 2 then            # for radio/atendente
            initialize ws.flagf7, ws.flagf8, ws.flagf9  to null
            if salva.atdetpcod = 1 then
               if salva.socvclcod is not null then
                  call cts00m02_desbloq( param.atdsrvnum,
                                         param.atdsrvano,
                                         salva.socvclcod )
                              returning  ws.sqlcode

                  if ws.sqlcode <> 0 then
                     prompt "" for char prompt_key
                     if l_atdsrvnum_original is null then
                        close window cts00m02
                     else
                        close window w_cts00m02t
                     end if
                     return
                  end if
                  whenever error stop
               end if
               initialize d_cts00m02.atdvclsgl,
                          d_cts00m02.srrcoddig,
                          salva.socvclcod      to  null
            end if
            if salva.atdetpcod = 4 or salva.atdetpcod = 3 then
               error "Servico ja acionado"
               next field atdetpcod
            end if
            if a_cts00m02[1].lclltt is null or
               a_cts00m02[1].lcllgt is null then
               call cts23g00_inf_cidade(3,
                                        "",
                                        a_cts00m02[1].cidnom,
                                        a_cts00m02[1].ufdcod)
                   returning ws.result,
                             a_cts00m02[1].lclltt,
                             a_cts00m02[1].lcllgt
            end if
            if ws.atdsrvorg = 16 then
               call cts28m02(a_cts00m02[1].lclltt,
                             a_cts00m02[1].lcllgt)
                   returning d_cts00m02.atdprscod,
                             d_cts00m02.dstqtd
               let d_cts00m02.srrcoddig = d_cts00m02.atdprscod
               let ws.flagf7 = "S"
            else
               call ctn01n00(a_cts00m02[1].ufdcod, a_cts00m02[1].cidnom,
                             a_cts00m02[1].brrnom, a_cts00m02[1].lgdnom,
                             a_cts00m02[1].lclltt, a_cts00m02[1].lcllgt,
                             param.atdsrvnum     , param.atdsrvano     )
                   returning d_cts00m02.atdprscod
               if d_cts00m02.atdprscod is not null then
                  let ws.flagf7 = "S"
                  select mpacidcod, intsrvrcbflg
                  into ws.mpacidcod, l_intsrvrcbflg
                   from dpaksocor
                   where pstcoddig = d_cts00m02.atdprscod
                  call cts23g00_inf_cidade(3,ws.mpacidcod,"","")
                       returning ws.result,
                                 d_cts00m02.srrltt,
                                 d_cts00m02.srrlgt

                     call cts18g00(d_cts00m02.srrltt,d_cts00m02.srrlgt,
                                   a_cts00m02[1].lclltt,a_cts00m02[1].lcllgt)
                          returning d_cts00m02.dstqtd
                  #end if
               end if
            end if

            call cta00m08_ver_contingencia(3)
                 returning l_contingencia

            if l_contingencia then
               next field atdetpcod
            end if
         end if
      end if

   #--------------------------------------------------------------------
   # Consulta posicao da frota
   #--------------------------------------------------------------------
   on key (F8)
      if g_setexplain = 1 then
         call cts01g01_setetapa("cts00m02 - Acionando com F8")
      end if

      if (g_documento.acao = "CON" or g_documento.acao = "REC") and
          m_atdfnlflg = "A" then
          call cts08g01("A", "N", "","SERVICO EM PROCESSO DE " ,
                                    "ACIONAMENTO AUTOMATICO ", "")
                 returning l_resultado
          next field atdetpcod
      end if

      if l_demanda = true then   ### PSI179345 - Gustavo
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
         if param.flg_origem <> 2 then            # for radio/atendente
            initialize ws.flagf7, ws.flagf8, ws.flagf9  to null
            if salva.atdetpcod = 1 then
               if salva.socvclcod is not null then
                  call cts00m02_desbloq( param.atdsrvnum,
                                         param.atdsrvano,
                                         salva.socvclcod )
                              returning  ws.sqlcode
                  if ws.sqlcode <> 0 then
                     prompt "" for char prompt_key
                     if l_atdsrvnum_original is null then
                        close window cts00m02
                     else
                        close window w_cts00m02t
                     end if
                     return
                  end if
                  whenever error stop
               end if
               initialize salva.socvclcod      to  null
            end if
            if salva.atdetpcod = 4 then
               error "Servico ja acionado"
               next field atdetpcod
            end if
            if ws.atdetptipcod = 1  then
               let ws.grupo = 2
               let ws.atividade = "QRV"
               if ws.atdsrvorg  =  10  then
                  let ws.grupo = 10
                  initialize ws.atividade to  null
               end if
               if ws.atdsrvorg  =  15  then
                  let ws.grupo = 7
               end if
               call cts00m03( 1, ws.grupo, ws.atividade, ws.pstcoddig_ori,
                              ""              ,  ws.srrcoddig_ori,
                              param.atdsrvnum, param.atdsrvano)
                   returning d_cts00m02.atdprscod,
                             d_cts00m02.atdvclsgl,
                             d_cts00m02.srrcoddig,
                             salva.socvclcod,
                             ws.flag_cts00m20
               if d_cts00m02.atdprscod is not null then
                  let ws.flagf8 = "S"
               end if
               display by name d_cts00m02.atdprscod,
                               d_cts00m02.atdvclsgl,
                               d_cts00m02.srrcoddig

               ##if ws.atdsrvorg  =  9 and
               #-- Para origem 9 ou 13, letar etapa = Retorno --##
               if (ws.atdsrvorg = 9 or ws.atdsrvorg = 13) and
                  ws.flagret    =  1 then
                  let d_cts00m02.atdetpcod = 10
               end if

            else
               error " Servico ja' concluido!"
            end if

            call cta00m08_ver_contingencia(3)
                 returning l_contingencia

            if l_contingencia then
               next field atdetpcod
            end if

         end if
      end if

   #--------------------------------------------------------------------
   # Localiza veiculo mais proximo pelo GPS
   #--------------------------------------------------------------------
   on key (F9)
      if g_setexplain = 1 then
         call cts01g01_setetapa("cts00m02 - Acionando com F9")
      end if

      if (g_documento.acao = "CON" or g_documento.acao = "REC") and
          m_atdfnlflg = "A" then
          call cts08g01("A", "N", "","SERVICO EM PROCESSO DE " ,
                                    "ACIONAMENTO AUTOMATICO ", "")
                 returning l_resultado
          next field atdetpcod
      end if

      if l_demanda = true then   ### PSI179345 - Gustavo
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
         if param.flg_origem <> 2 then            # for radio/atendente
            initialize ws.flagf7, ws.flagf8, ws.flagf9  to null
            select gpsacngrpcod
                 into  ws.gpsacngrpcod
                 from datkmpacid
               where cidnom = a_cts00m02[1].cidnom
                 and ufdcod = a_cts00m02[1].ufdcod
            if ws.gpsacngrpcod <> 0  then
               if salva.atdetpcod = 1 then
                  if salva.socvclcod is not null then
                     call cts00m02_desbloq( param.atdsrvnum,
                                            param.atdsrvano,
                                            salva.socvclcod )
                                 returning  ws.sqlcode

                     if ws.sqlcode <> 0 then
                        prompt "" for char prompt_key
                        if l_atdsrvnum_original is null then
                           close window cts00m02
                        else
                           close window w_cts00m02t
                        end if
                        return
                     end if
                     whenever error stop
                  end if
                  initialize salva.socvclcod      to  null
               end if
               if salva.atdetpcod = 4 then
                  error "Servico ja acionado"
                  next field atdetpcod
               end if
               if ws.atdetptipcod = 1  then
                  # Verifica ambiente de ROTERIZACAO
                  if ctx25g05_rota_ativa() then
                     call ctx25g04(param.atdsrvnum,
                                   param.atdsrvano,
                                   ws.gpsacngrpcod,
                                   "")
                          returning d_cts00m02.atdprscod,
                                    d_cts00m02.atdvclsgl,
                                    d_cts00m02.srrcoddig,
                                    salva.socvclcod,
                                    d_cts00m02.atdprvdat,
                                    d_cts00m02.dstqtd,
                                    ws.flag_cts00m20
                  else
                     call cts00m20(param.atdsrvnum,
                                   param.atdsrvano,
                                   ws.gpsacngrpcod,
                                   "") ### PSI179345
                          returning d_cts00m02.atdprscod,
                                    d_cts00m02.atdvclsgl,
                                    d_cts00m02.srrcoddig,
                                    salva.socvclcod,
                                    d_cts00m02.atdprvdat,
                                    d_cts00m02.dstqtd,
                                    ws.flag_cts00m20
                  end if

                  if d_cts00m02.atdprscod is not null then
                     let ws.flagf9 = "S"
                  end if

                  display by name d_cts00m02.atdprscod,
                                  d_cts00m02.atdvclsgl,
                                  d_cts00m02.srrcoddig,
                                  d_cts00m02.dstqtd
               else
                  error " Servico ja' concluido!"
               end if

           else
               error "Cidade sem guinchos acionados por GPS ! Utilize a opcao F7 "
           end if

           call cta00m08_ver_contingencia(3)
                returning l_contingencia

           if l_contingencia then
              next field atdetpcod
           end if

         end if
      end if

   #--------------------------------------------------------------------
   # Pesquisa conclusao servico original
   #--------------------------------------------------------------------
   on key (F10)
      if l_demanda = true then   ### PSI179345 - Gustavo
         error 'Funcao nao disponivel, demanda ativa' sleep 1
      else
         if param.flg_origem <> 2 then            # for radio/atendente
            if ws.flagret = 1              and
               ws.atdorgsrvnum is not null and
               ws.atdorgsrvano is not null then
               call cts00m34(ws.atdorgsrvnum, ws.atdorgsrvano)
            end if
         end if
      end if

   #--------------------------------------------------------------------
   # Pesquisa senha seguranca cliente
   #--------------------------------------------------------------------
   on key (F1)

      #verifica se serviço possui mecanismo de seguranca
      if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum,param.atdsrvano, ws.ciaempcod) then
         #verifica se está no horário de exibicao da senha
         if cty28g00_exibe_endereco_senha(param.atdsrvnum,param.atdsrvano) then
            #verifica senha
            call cty28g00_consulta_senha(param.atdsrvnum,
                                         param.atdsrvano)

            returning lr_cty28g00.*

            if lr_cty28g00.coderro <> 0 then
               call cts08g01("A", "N", ""," NAO FOI POSSIVEL CONSULTAR " ,"SENHA DE SEGURANCA " , "")
                 returning l_resultado
            else
               call cts08g01("A", "N", "","SENHA DE SEGURANCA " ,
                          lr_cty28g00.senha, "")
                 returning l_resultado
            end if
         else
             call cts08g01("A", "N", "","NAO ESTA NO PERIODO DE EXIBIR SENHA" ,"", "")
                 returning l_resultado
         end if
      else
         call cts08g01("A", "N", "","PARAMETRO ORIGEM/EMPRESA NAO CADASTRADA" ,"", "")
         returning l_resultado
      end if

   #--------------------------------------------------------------------
   # Limite valor referencia(M.O.) e Pecas
   #--------------------------------------------------------------------
   on key (F2)
        if param.flg_origem <> 2  then            # for radio/atendente
               call cts00m02_limite_itau(param.atdsrvnum,param.atdsrvano)
        else
           error "Funcao disponivel apenas para a C.O." sleep 2
        end if

 end input

 if d_cts00m02.atdetpcod = 3 and l_atualiza_todos = "S" and ws.ciaempcod = 40 then  ## PSI 211982

    ## obtem o nr da autorizacao
    call ctd09g00_sel_orc(3, param.atdsrvnum, param.atdsrvano)
         returning l_resultado, l_mensagem, l_atznum

    ## atualiza o nr da autorizacao nos multiplos
    for l_contador = 1 to 10
       if am_cts29g00[l_contador].atdmltsrvnum is not null then
          call ctd09g00_atu_atznum
               (am_cts29g00[l_contador].atdmltsrvnum,
                am_cts29g00[l_contador].atdmltsrvano,
                l_atznum)
                returning l_resultado, l_mensagem

          if l_resultado <> 1 then
             error l_mensagem sleep 1
             exit for
          end if
       end if
    end for

 end if

 ### Inicio PSI179345
 if l_erro = true then
    let int_flag = false
    if l_atdsrvnum_original is null then
       close window cts00m02
    else
       close window w_cts00m02t
    end if
    return
 end if
 ### Final PSI179345

 if int_flag   then
    if ws.flag_cts00m20 = 1 then
       call cts00m02_desbloq( param.atdsrvnum,
                              param.atdsrvano,
                              salva.socvclcod )
                   returning  ws.sqlcode

       if ws.sqlcode <> 0 then
          prompt "" for char prompt_key
          if l_atdsrvnum_original is null then
             close window cts00m02
          else
             close window w_cts00m02t
          end if
          return
       end if
       whenever error stop
    end if
    if l_atdsrvnum_original is null then
       close window cts00m02
    else
       close window w_cts00m02t
    end if
    let int_flag = false
    return
 end if

 #--------------------------------------------------------------------
 # Atualiza base de dados
 #--------------------------------------------------------------------

 if g_setexplain = 1 then
    call cts01g01_setetapa("cts00m02 - Atualizando Base")
 end if

 if ws.atdetptipcod = 1  then
    initialize d_cts00m02.cnldat  to null
 else
    if d_cts00m02.atdetpcod = salva.atdetpcod  then
       let d_cts00m02.cnldat = salva.cnldat
    else
       let d_cts00m02.cnldat = today
    end if
 end if


 let m_servico  = param.atdsrvnum, "-",
                  param.atdsrvano
 let m_mensagem = null

 whenever error continue
 begin work

    #--------------------------------------
    # Desbloqueia viatura
    #--------------------------------------
    if salva.socvclcod is not null and
       salva.socvclcod <> 0        then
       update datkveiculo
          set socacsflg = "0"
        where socvclcod = salva.socvclcod

       if sqlca.sqlcode <> 0 then
          error "Erro UPDATE datkveiculo /", sqlca.sqlcode, "/",
                 sqlca.sqlerrd[2] sleep 10
          error "FAVOR AVISAR IMEDIATAMENTE A INFORMATICA !!!" sleep 10
       end if

       initialize salva.socvclcod to null
    end if

    if l_prest_conect = true then ############ ligia 31/03/08 ###############

       # --ATUALIZAR ENVIO PARA INTERNET-- #
       if l_acionamentoWEB then
          call ctx34g02_conclusao_servico(param.atdsrvnum,
                                          param.atdsrvano,
                                          d_cts00m02.atdetpcod,
                                          d_cts00m02.atdprscod,
                                          d_cts00m02.socvclcod,
                                          d_cts00m02.srrcoddig,
                                          'INTERNET',
                                          g_issk.usrtip,
                                          g_issk.empcod,
                                          g_issk.funmat,
                                          l_atualiza_todos)
                returning l_resultado,
                          l_mensagem

          if l_resultado <> 0 then
             rollback work
             error l_mensagem sleep 2
             prompt "" for char prompt_key

             if l_atdsrvnum_original is null then
                close window cts00m02
             else
                close window w_cts00m02t
             end if

             let int_flag = false
             return
          end if

       else
          call cts33g00_registrar_para_internet(param.atdsrvano,
                                                param.atdsrvnum,
                                                ws.atdetpseq,
                                                ws.atdetpcod,
                                                d_cts00m02.atdprscod,
                                                g_issk.usrtip,
                                                g_issk.empcod,
                                                g_issk.funmat,
                                                ws.etpmtvcod)
                returning l_resultado,
                          l_mensagem

          if l_resultado <> 1 then
             rollback work
             error l_mensagem sleep 2
             prompt "" for char prompt_key

             if l_atdsrvnum_original is null then
                close window cts00m02
             else
                close window w_cts00m02t
             end if

             let int_flag = false
             return
          end if

       end if

       if (d_cts00m02.atdetpcod = 4 or
           d_cts00m02.atdetpcod = 3 or
           d_cts00m02.atdetpcod = 7 or
           d_cts00m02.atdetpcod = 10) or
          ((ws.atdsrvorg = 2 or
            ws.atdsrvorg = 3) and
           (d_cts00m02.atdetpcod = 13 or
            d_cts00m02.atdetpcod = 43 or
            d_cts00m02.atdetpcod = 44 or
            d_cts00m02.atdetpcod = 45)) then
          error "SERVICO ENVIADO PELA INTERNET !"
       else
          error "SERVICO CANCELADO E ENVIADO CAN PELA INTERNET !"
       end if

    end if ####################### fim - ligia 31/03/08 ###################

  if l_atualiza_todos = 'S' then
  	initialize l_atdsrvnum_desassociar to null
  	initialize l_atdsrvano_desassociar to null
  else
  	let l_atdsrvnum_desassociar = l_atdsrvnum_original
  	let l_atdsrvano_desassociar = l_atdsrvano_original
  end if

  # --ATUALIZAR DADOS DO SERVICO-- #
  call cts10g09_alt_dados_servico(ws.atdetptipcod,
                                  salva.atdetptipcod,
                                  param.atdsrvnum,
                                  param.atdsrvano,
                                  d_cts00m02.atdprscod,
                                  d_cts00m02.socvclcod,
                                  d_cts00m02.srrcoddig,
                                  d_cts00m02.c24nomctt,
                                  ws.atdcstvlr,
                                  ws.atdfnlflg,
                                  d_cts00m02.atdprvdat,
                                  ws.horaatu,
                                  g_issk.funmat,
                                  ws.dataatu,
                                  d_cts00m02.atdvclsgl,
                                  l_atdsrvnum_desassociar,
                                  l_atdsrvano_desassociar,
                                  d_cts00m02.atdetpcod)

       returning l_resultado, l_mensagem

  if l_resultado <> 1 then
     rollback work
     error l_mensagem sleep 10
     prompt "" for char prompt_key

     if l_atdsrvnum_original is null then
        close window cts00m02
     else
        close window w_cts00m02t
     end if
     let int_flag = false
     return
  end if

  # --CHAMAR NOVAMENTE, POIS PODE HAVER ALTERACOES NO MULTIPLO ATE ESTE PONTO-- #
  #apenas se servico RE
  if ws.atdsrvorg = 9 then

     let l_sair = false

     # --ATUALIZAR DADOS DO SERVICO MULTIPLO-- #

     if  l_atualiza_todos = 'S' then

         call cts29g00_obter_multiplo(1, l_atdsrvnum_original, l_atdsrvano_original)
              returning l_resultado, l_mensagem,
                        am_cts29g00[1].*, am_cts29g00[2].*,
                        am_cts29g00[3].*, am_cts29g00[4].*,
                        am_cts29g00[5].*, am_cts29g00[6].*,
                        am_cts29g00[7].*, am_cts29g00[8].*,
                        am_cts29g00[9].*, am_cts29g00[10].*

         for l_contador = 1 to 10
            if am_cts29g00[l_contador].atdmltsrvnum is not null then

             	 initialize l_atdsrvnum_desassociar to null
  	           initialize l_atdsrvano_desassociar to null
               call cts10g09_alt_dados_servico(ws.atdetptipcod,
                                               salva.atdetptipcod,
                                               am_cts29g00[l_contador].atdmltsrvnum,
                                               am_cts29g00[l_contador].atdmltsrvano,
                                               d_cts00m02.atdprscod,
                                               d_cts00m02.socvclcod,
                                               d_cts00m02.srrcoddig,
                                               d_cts00m02.c24nomctt,
                                               ws.atdcstvlr,
                                               ws.atdfnlflg,
                                               d_cts00m02.atdprvdat,
                                               ws.horaatu,
                                               g_issk.funmat,
                                               ws.dataatu,
                                               d_cts00m02.atdvclsgl,
                                               l_atdsrvnum_desassociar,
                                               l_atdsrvano_desassociar,
                                               d_cts00m02.atdetpcod)

                    returning l_resultado, l_mensagem

               if l_resultado <> 1 then
                  let l_sair = true
                  exit for
               end if

            end if

         end for
     end if

     if l_sair then
        rollback work
        error l_mensagem sleep 10
        prompt "" for char prompt_key
        if l_atdsrvnum_original is null then
           close window cts00m02
        else
           close window w_cts00m02t
        end if
        let int_flag = false
        return
     end if
  end if

    if ws.atdsrvorg =  2   and
       ws.asitipcod =  5   then
       call cts00m02_assist_pass(param.atdsrvnum,
                                 param.atdsrvano,
                                 d_cts00m02.pasasivcldes,
                                 d_cts00m02.txivlr)

                       returning ws.sqlcode

       if ws.sqlcode <> 0  then
          rollback work
          error " Erro (", ws.sqlcode,
                  ") na atualizacao da assistencia a passageiro.",
                  " AVISE A INFORMATICA!" sleep 10
          prompt "" for char prompt_key
          if l_atdsrvnum_original is null then
             close window cts00m02
          else
             close window w_cts00m02t
          end if
          return
       end if
    end if

    #-------------------------------------------------------------------
    # Grava etapa de acompanhamento
    #-------------------------------------------------------------------
    let ws.grvetpflg = false

    #--------------------------------------------------------------------
    # Verifica se SITUACAO foi alterada
    #--------------------------------------------------------------------
    if salva.atdetpcod <> d_cts00m02.atdetpcod  then
       let ws.grvetpflg = true
    end if

    #-------------------------------------------------------------------
    # Verifica se PRESTADOR foi alterado
    #-------------------------------------------------------------------
    if salva.atdprscod is null  then
       if d_cts00m02.atdprscod is null  then
       else
          let ws.grvetpflg = true
       end if
    else
       if d_cts00m02.atdprscod is null  then
          let ws.grvetpflg = true
       else
          if salva.atdprscod <> d_cts00m02.atdprscod  then
             let ws.grvetpflg = true
          end if
       end if
    end if

    #-------------------------------------------------------------------
    # Verifica se VEICULO foi alterado
    #-------------------------------------------------------------------
    if salva.atdvclsgl is null  then
       if d_cts00m02.atdvclsgl is null  then
       else
          let ws.grvetpflg = true
       end if
    else
       if d_cts00m02.atdvclsgl is null  then
          let ws.grvetpflg = true
       else
          if salva.atdvclsgl <> d_cts00m02.atdvclsgl  then
             let ws.grvetpflg = true
          end if
       end if
    end if

    #-------------------------------------------------------------------
    # Verifica se SOCORRISTA foi alterado
    #-------------------------------------------------------------------
    if salva.srrcoddig is null  then
       if d_cts00m02.srrcoddig is null  then
       else
          let ws.grvetpflg = true
       end if
    else
       if d_cts00m02.srrcoddig is null  then
          let ws.grvetpflg = true
       else
          if salva.srrcoddig <> d_cts00m02.srrcoddig  then
             let ws.grvetpflg = true
          end if
       end if
    end if

    if ws.grvetpflg = true then

    	if (not l_acionamentoWEB or not (d_cts00m02.atdetpcod = 3 or
                                       d_cts00m02.atdetpcod = 4 or
                                      (d_cts00m02.atdetpcod = 5 and salva.atdetpcod <> 1) or
                                       d_cts00m02.atdetpcod = 10)) then
         let l_sincronizaAW = 1
      else
         let l_sincronizaAW = 0
      end if

      call cts10g04_insere_etapa_sincronismo(param.atdsrvnum     ,
                                             param.atdsrvano     ,
                                             d_cts00m02.atdetpcod,
                                             d_cts00m02.atdprscod,
                                             d_cts00m02.c24nomctt,
                                             d_cts00m02.socvclcod,
                                             d_cts00m02.srrcoddig,
                                             l_sincronizaAW)
          returning ins_etapa

      if ins_etapa <> 0  then
         rollback work
         error " Erro (", ins_etapa,
               ") na gravacao da etapa de acompanhamento sincronismo.",
               " AVISE A INFORMATICA!" sleep 10
         prompt "" for char prompt_key
         if l_atdsrvnum_original is null then
            close window cts00m02
         else
            close window w_cts00m02t
         end if
         return
      end if


       ####PSI 214558
       let     ins_tempo_distancia  =  null
       if d_cts00m02.atdetpcod = 3 or d_cts00m02.atdetpcod = 4 then
          call cts10g04_tempo_distancia(param.atdsrvnum,
                                        param.atdsrvano,
                                        d_cts00m02.atdetpcod,
                                        d_cts00m02.dstqtd)
               returning ins_tempo_distancia

          if ins_tempo_distancia <> 0 then
             rollback work
             error " Erro (", ins_tempo_distancia,
                   ") na gravacao da etapa de acompanhamento tempo distancia.",
                   " AVISE A INFORMATICA!" sleep 10
             prompt "" for char prompt_key
             if l_atdsrvnum_original is null then
                close window cts00m02
             else
                close window w_cts00m02t
            end if
            return
         end if

       end if
       ####
       let l_sair = false

       if  l_atualiza_todos = 'S' then

           # --INSERIR ETAPA PARA SERVICO MULTIPLO-- #
           for l_contador = 1 to 10

              if am_cts29g00[l_contador].atdmltsrvnum is not null then
              	
                 let ins_etapa = cts10g04_insere_etapa_sincronismo(am_cts29g00[l_contador].atdmltsrvnum,
                                                                   am_cts29g00[l_contador].atdmltsrvano,
                                                                   d_cts00m02.atdetpcod,
                                                                   d_cts00m02.atdprscod,
                                                                   d_cts00m02.c24nomctt,
                                                                   d_cts00m02.socvclcod,
                                                                   d_cts00m02.srrcoddig,
                                                                   l_sincronizaAW)
                 if ins_etapa <> 0 then
                 	  display "ins_etapa: ", ins_etapa
                 	  display "am_cts29g00[l_contador].atdmltsrvnum: ", am_cts29g00[l_contador].atdmltsrvnum
                 	  display "am_cts29g00[l_contador].atdmltsrvano: ", am_cts29g00[l_contador].atdmltsrvano
                    display "d_cts00m02.atdetpcod: ", d_cts00m02.atdetpcod
                    display "d_cts00m02.atdprscod: ", d_cts00m02.atdprscod
                    display "d_cts00m02.c24nomctt: ", d_cts00m02.c24nomctt
                    display "d_cts00m02.socvclcod: ", d_cts00m02.socvclcod
                    display "d_cts00m02.srrcoddig: ", d_cts00m02.srrcoddig
                    display "l_sincronizaAW      : ", l_sincronizaAW      
                 	  
                    let l_sair = true
                    exit for
                 end if

                 ####PSI 214558
                 let     ins_tempo_distancia  =  null
                 if d_cts00m02.atdetpcod = 3 or d_cts00m02.atdetpcod = 4 then
                    call cts10g04_tempo_distancia(am_cts29g00[l_contador].atdmltsrvnum,
                                                  am_cts29g00[l_contador].atdmltsrvano,
                                                  d_cts00m02.atdetpcod,
                                                  d_cts00m02.dstqtd)
                      returning ins_tempo_distancia

                      if ins_tempo_distancia <> 0 then
                         let l_sair = true
                         exit for
                      end if

                 end if
                 ####
              end if
           end for
       end if

       if l_sair then
          rollback work
          error "Erro (", ins_etapa, "-", ins_tempo_distancia,
                ") na gravacao da etapa de acompanhamento. ",
                " AVISE A INFORMATICA!" sleep 10
          prompt "" for char prompt_key
          if l_atdsrvnum_original is null then
             close window cts00m02
          else
             close window w_cts00m02t
          end if
          let int_flag = false
          return
       end if

       if d_cts00m02.atdetpcod = 38 then

          # --GRAVAR O MOTIVO DA RECUSA PARA SERVICO RECUSADO-- #
          call cts10g04_atualiza_dados(param.atdsrvnum,
                                       param.atdsrvano,
                                       l_srvrcumtvcod,
                                       "")

               returning l_resultado,
                         l_mensagem

          if l_resultado <> 1 then
             rollback work
             error l_mensagem sleep 10
             error "FAVOR AVISAR A INFORMATICA !!! " sleep 10
             prompt "" for char prompt_key
             if l_atdsrvnum_original is null then
             else
                close window w_cts00m02t
             end if
             return
          end if


          # --GRAVAR O MOTIVO DA RECUSA PARA SERVICO MULTIPLO-- #
          for l_contador = 1 to 10
             if am_cts29g00[l_contador].atdmltsrvnum is not null then

                call cts10g04_atualiza_dados(am_cts29g00[l_contador].atdmltsrvnum,
                                             am_cts29g00[l_contador].atdmltsrvano,
                                             l_srvrcumtvcod,
                                             "")

                     returning l_resultado, l_mensagem

                if l_resultado <> 1 then

                   let l_sair = true

                   exit for

                end if

             end if

          end for

          if l_sair then
             rollback work
             error l_mensagem sleep 10
             prompt "" for char prompt_key
             if l_atdsrvnum_original is null then
                close window cts00m02
             else
                close window w_cts00m02t
             end if
             let int_flag = false
             return
          end if

       end if

       if d_cts00m02.envtipcod is not null then

          # --ATUALIZAR O TIPO DE ENVIO PARA O SERVICO-- #
          call cts10g04_atualiza_dados(param.atdsrvnum,
                                       param.atdsrvano,
                                       "",
                                       d_cts00m02.envtipcod)

               returning l_resultado,
                         l_mensagem

          if l_resultado <> 1 then
             rollback work
             error l_mensagem sleep 10
             if l_atdsrvnum_original is null then
                close window cts00m02
             else
                close window w_cts00m02t
             end if
             let int_flag = false
             return
          end if

          let l_sair = false

          # --ATUALIZAR O TIPO DE ENVIO PARA O SERVICO MULTIPLO-- #
          for l_contador = 1 to 10

             if am_cts29g00[l_contador].atdmltsrvnum is not null then

                call cts10g04_atualiza_dados(am_cts29g00[l_contador].atdmltsrvnum,
                                             am_cts29g00[l_contador].atdmltsrvano,
                                             "",
                                             d_cts00m02.envtipcod)

                      returning l_resultado,
                                l_mensagem

                if l_resultado <> 1 then

                   let l_sair = true

                   exit for

                end if

             end if

          end for

          if l_sair then
             rollback work
             error l_mensagem sleep 10
             if l_atdsrvnum_original is null then
                close window cts00m02
             else
                close window w_cts00m02t
             end if
             let int_flag = false
             return
          end if

       end if

    end if

   #--------------------------------------------------------------------
   # Grava servico na fila de transmissao/fax, Pager ou MDT
   #--------------------------------------------------------------------
   if ws.transmite = true then
      if (not l_acionamentoWEB) then
         if (ws.atdsrvorg =  2   and ws.asitipcod <> 5) or
            ws.atdsrvorg =  3   then
            if cts11m07(param.atdsrvnum, param.atdsrvano)  then
               error " Acionamento efetuado! " sleep 2
            else
               rollback work
               error " Acionamento NAO efetuado! " sleep 10

               prompt "" for char prompt_key
               if l_atdsrvnum_original is null then
                  close window cts00m02
               else
                  close window w_cts00m02t
               end if
               return
            end if
         else
            if ws.atdsrvorg = 15 and
               d_cts00m02.mdtcod is null then  #Marcelo - psi178381
               call cts00g04_msgjit(param.atdsrvnum, param.atdsrvano)
            else

               if d_cts00m02.atdimpcod  is not null   then
                  call cts00g01_fila(param.atdsrvnum, param.atdsrvano,1)
               end if
               if  d_cts00m02.mdtcod  is not null   then

                   #---------------------------------------------
                   # Envio da referencia do endereco via Teletrim
                   #---------------------------------------------
                   call cts00g04_msgsrv(param.atdsrvnum,
                                        param.atdsrvano,
                                        d_cts00m02.socvclcod,
                                        " ",
                                        " ",
                                        "SRV","O")  #PSI 190250

                   call cts00g02_env_msg_mdt(1, param.atdsrvnum,
                                               param.atdsrvano,
                                               "",
                                               d_cts00m02.socvclcod)
                       returning ws.erroflg

                   if ws.erroflg  =  "S"   then
                      rollback work
                      error "Erro ao chamar a funcao cts00g02_env_msg_mdt() " sleep 4
                      error "AVISE A INFORMATICA !!!" sleep 4
                      prompt "" for char prompt_key
                      if l_atdsrvnum_original is null then
                         close window cts00m02
                      else
                         close window w_cts00m02t
                      end if
                      return
                   end if
               end if
            end if

         end if
      end if
   end if

   #--------------------------------------------------------------------
   # Grava posicao da frota (para veiculos controlados pelo radio)
   #--------------------------------------------------------------------
   if ws.vclctrposqtd  >  0             and
      d_cts00m02.atdvclsgl is not null  and
      not l_acionamentoWEB then

      #------------------------------------------------------------------
      # Na conclusao "carrega" dados do servico p/ posicao da frota
      #------------------------------------------------------------------

      if salva.atdetptipcod =  1  and
         ws.atdetptipcod    <> 1  then
         call cts33g01_posfrota ( d_cts00m02.socvclcod,
                                  "N",
                                  a_cts00m02[1].ufdcod,
                                  a_cts00m02[1].cidnom,
                                  a_cts00m02[1].lclbrrnom,
                                  a_cts00m02[1].endzon,
                                  a_cts00m02[1].lclltt,
                                  a_cts00m02[1].lcllgt,
                                  a_cts00m02[2].ufdcod,
                                  a_cts00m02[2].cidnom,
                                  a_cts00m02[2].lclbrrnom,
                                  a_cts00m02[2].endzon,
                                  a_cts00m02[2].lclltt,
                                  a_cts00m02[2].lcllgt,
                                  ws.dataatu,
                                  ws.horaatu,
                                  "QRU",
                                  param.atdsrvnum,
                                  param.atdsrvano )
                        returning ws.sqlcode

         if ws.sqlcode <> 0  then
            rollback work
            error " Erro (", ws.sqlcode,
            ") na atualizacao da posicao da frota. ",
            " AVISE A INFORMATICA!" sleep 10
            prompt "" for char prompt_key
            if l_atdsrvnum_original is null then
               close window cts00m02
            else
               close window w_cts00m02t
            end if
            return
         end if
      end if

      #------------------------------------------------------------------
      # No cancelamento "pega" nova posicao, coloca veiculo c/ prioridade
      #------------------------------------------------------------------
      if salva.atdetpcod     >= 3  and
         salva.atdetpcod     <= 4  and
         d_cts00m02.atdetpcod = 5  then

         if ws.atdsrvorg =  4   or
            ws.atdsrvorg =  6   or
            ws.atdsrvorg =  1   or
            ws.atdsrvorg =  5   or
            ws.atdsrvorg =  7   or
            ws.atdsrvorg =  17  or    # replace-congenere
            ws.atdsrvorg =  2   then
            call cts33g01_posfrota ( d_cts00m02.socvclcod,
                                     "S",
                                     ws.ufdcod,
                                     ws.cidnom,
                                     ws.brrnom,
                                     ws.endzon,
                                     "",
                                     "",
                                     "",
                                     "",
                                     "",
                                     "",
                                     "",
                                     "",
                                     ws.dataatu,
                                     ws.horaatu,
                                     "QRV",
                                     "",
                                     "" )
                           returning ws.sqlcode

            if ws.sqlcode <> 0  then
               rollback work
               error " Erro (", ws.sqlcode,
                     ") na atualizacao da posicao da frota. ",
                     " AVISE A INFORMATICA !!! " sleep 10
               prompt "" for char prompt_key
               if l_atdsrvnum_original is null then
                  close window cts00m02
               else
                  close window w_cts00m02t
               end if
               return
            end if
         end if
      end if
   end if

  if salva.atdetpcod <> d_cts00m02.atdetpcod and
     d_cts00m02.atdetpcod = 5 then

        open c_cts00m02_003 using param.atdsrvnum, param.atdsrvano

        whenever error continue
        fetch c_cts00m02_003
        whenever error stop

        if sqlca.sqlcode <> 0 and
           sqlca.sqlcode <> notfound then
           rollback work
           error "Erro: ", sqlca.sqlcode, ", no cursor c_cts00m02_003 !" sleep 10
           if l_atdsrvnum_original is null then
              close window cts00m02
           else
              close window w_cts00m02t
           end if
           let int_flag = false
           return
        end if

        #PSI 202363
        #se ja existe ligacao de cancelamento ou
        # se ligacao de cancelamento esta sendo registrada nesse momento

        if sqlca.sqlcode = 0 or g_documento.acao = "CAN" then
           let ws.sqlcode = ctc59m03_regulador(param.atdsrvnum, param.atdsrvano)

           if ws.sqlcode <> 0  then
              rollback work
              error " Erro (", ws.sqlcode, ") no ajuste do regulador.",
                    " AVISE A INFORMATICA!" sleep 10
              prompt "" for char prompt_key
              if l_atdsrvnum_original is null then
                 close window cts00m02
              else
                 close window w_cts00m02t
              end if
              let int_flag = false
              return
           end if

        end if

  end if

   if ws.atdsrvorg = 16  then  # Sinistro de transporte

      # Alta Disponibilidade - Roberto

      if m_cts00m02_prep2 is null or
         m_cts00m02_prep2 <> true then
         call cts00m02_prepare2()
      end if

      if d_cts00m02.atdprscod is not null then
         whenever error continue
         let l_sql = " update porto@",m_hostname clipped , ":sstkprest",
                     " set prssrvultdat = ?",
                     "     ,prssrvulthor = ? ",
                     " where sinprscod = ?  "
           prepare pcts00m02030 from l_sql
           execute pcts00m02030 using ws.dataatu,
                                      ws.horaatu1,
                                      d_cts00m02.atdprscod
         whenever error stop
         if sqlca.sqlcode <> 0  then
            rollback work
            error " Erro (", sqlca.sqlcode, ") na tabela SSTKPREST,",
                  " AVISE A INFORMATICA!" sleep 10
            prompt "" for char prompt_key
            if l_atdsrvnum_original is null then
               close window cts00m02
            else
               close window w_cts00m02t
            end if
            return
         end if
         --------------[ obter o aviso e o ano ]-------------
         select sinavsnum,sinavsano
                into ws.sinavsnum,ws.sinavsano
                from datrligtrp
               where atdsrvnum = g_documento.atdsrvnum
                 and atdsrvano = g_documento.atdsrvano
         --------------[ obter o ramo ]-----------------------
         select sinavsramcod
                into ws.sinavsramcod
                from sstmstpavs
               where sinavsnum = ws.sinavsnum
         --------------[ obter tipo do prestador ]--------------

         open c_cts00m02_017 using ws.sinavsnum
         fetch c_cts00m02_017 into ws.sinntzgrpcod


         if sqlca.sqlcode <> 0 then
            let ws.sintraprstip = "Z"
         else
            case ws.sinntzgrpcod
               when 1 let ws.sintraprstip = "E"
               when 2 let ws.sintraprstip = "V"
               when 3 let ws.sintraprstip = "E"
            end case
         end if
         -------------[ grava tabela ]--------------
         insert into sstmsinprs
               (sinavsramcod,
                sinavsano,
                sinavsnum,
                sinprsseq,
                stpprstip,
                sinprscod,
                atldat,
                atlhor,
                atlmat,
                atlemp,
                atlusrtip)
          values
               (ws.sinavsramcod,
                ws.sinavsano,
                ws.sinavsnum,
                0,
                ws.sintraprstip,
                d_cts00m02.atdprscod,
                today,
                current,
                g_issk.funmat,
                g_issk.empcod,
                g_issk.usrtip)

         if sqlca.sqlcode <> 0  then
            rollback work
            error " Erro (", sqlca.sqlcode, ") na tabela SSTMSINPRS,",
                  " AVISE A INFORMATICA!" sleep 10
            prompt "" for char prompt_key
            if l_atdsrvnum_original is null then
               close window cts00m02
            else
               close window w_cts00m02t
            end if
            return
         end if
      end if
   end if


 #--------------------------------------------------------------------
 # Grava informacoes sobre retorno do prestador p/ execucao do servico
 #--------------------------------------------------------------------
 if (ws.atdsrvorg = 13  or ws.atdsrvorg =  9 )  then

    select atdsrvretflg,
           atdorgsrvnum,
           atdorgsrvano
      into ws.atdsrvretflg,
           ws.atdorgsrvnum,
           ws.atdorgsrvano
      from datmsrvre
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano

    if (d_cts00m02.atdetpcod >= 3  and d_cts00m02.atdetpcod <= 4 or
        d_cts00m02.atdetpcod  = 10)                              and
       (salva.atdetpcod      >= 3  and salva.atdetpcod      <= 4 or
        salva.atdetpcod       = 10)                              then

       if ws.atdsrvretflg = "S"  then
          call cts00m18(param.atdsrvnum, param.atdsrvano)
       end if
    end if

    #PSI208094 - inicio
    #PSI201022
    #Consistir servico anterior quando o prestador do retorno atual for diferente
    if  ws.prsdftant = "S" then
        call ctb00g10_verif_serv(ws.atdorgsrvnum,
                                 ws.atdorgsrvano,
                                 param.atdsrvnum,
                                 param.atdsrvano)
    end if
    #PSI201022
    #PSI208094 - fim

 end if

 ## Realiza a conclusão no AcionamentoWeb
 if l_acionamentoWEB and (d_cts00m02.atdetpcod = 3 or
                          d_cts00m02.atdetpcod = 4 or
                          (d_cts00m02.atdetpcod = 5  and salva.atdetpcod <> 1) or
                          d_cts00m02.atdetpcod = 10) then

    if ws.grvetpflg = true then
       case d_cts00m02.envtipcod
           when 0  # VOZ
                 call ctx34g02_conclusao_servico(param.atdsrvnum,
                                                 param.atdsrvano,
                                                 d_cts00m02.atdetpcod,
                                                 d_cts00m02.atdprscod,
                                                 d_cts00m02.socvclcod,
                                                 d_cts00m02.srrcoddig,
                                                 'VOZ',
                                                 g_issk.usrtip,
                                                 g_issk.empcod,
                                                 g_issk.funmat,
                                                 l_atualiza_todos)
                      returning l_resultado,
                                l_mensagem

                 error l_mensagem sleep 2
                 if l_resultado <> 0 then
                    rollback work
                    # Apaga dados da conclusao do servico
                    call cts10g09_registrar_prestador(l_flag_f8_f9,
                                                      param.atdsrvnum,
                                                      param.atdsrvano,
                                                      "","","","","")
                         returning l_resultado, l_mensagem

                    prompt "" for char prompt_key
                    if l_atdsrvnum_original is null then
                       close window cts00m02
                    else
                       close window w_cts00m02t
                    end if
                    let int_flag = false
                    return
                 end if
                 error ""

           when 1  # GPS
              if ws.transmite = true  then
                 call ctx34g02_conclusao_servico(param.atdsrvnum,
                                                 param.atdsrvano,
                                                 d_cts00m02.atdetpcod,
                                                 d_cts00m02.atdprscod,
                                                 d_cts00m02.socvclcod,
                                                 d_cts00m02.srrcoddig,
                                                 'GPS',
                                                 g_issk.usrtip,
                                                 g_issk.empcod,
                                                 g_issk.funmat,
                                                 l_atualiza_todos)
                      returning l_resultado,
                                l_mensagem

                 error l_mensagem sleep 2
                 if l_resultado <> 0 then
                    rollback work
                    # Apaga dados da conclusao do servico
                    call cts10g09_registrar_prestador(l_flag_f8_f9,
                                                      param.atdsrvnum,
                                                      param.atdsrvano,
                                                      "","","","","")
                         returning l_resultado, l_mensagem

                    prompt "" for char prompt_key
                    if l_atdsrvnum_original is null then
                       close window cts00m02
                    else
                       close window w_cts00m02t
                    end if
                    let int_flag = false
                    return
                 end if
                 error ""

              end if

           when 2  # INTERNET
              # Acionamento ja realizado apos input

           when 3  # FAX
              if ws.fax  = true then
                 call ctx34g02_conclusao_servico(param.atdsrvnum,
                                                 param.atdsrvano,
                                                 d_cts00m02.atdetpcod,
                                                 d_cts00m02.atdprscod,
                                                 d_cts00m02.socvclcod,
                                                 d_cts00m02.srrcoddig,
                                                 'FAX',
                                                 g_issk.usrtip,
                                                 g_issk.empcod,
                                                 g_issk.funmat,
                                                 l_atualiza_todos)
                      returning l_resultado,
                                l_mensagem

                 error l_mensagem sleep 2
                 if l_resultado <> 0 then
                    rollback work
                    # Apaga dados da conclusao do servico
                    call cts10g09_registrar_prestador(l_flag_f8_f9,
                                                      param.atdsrvnum,
                                                      param.atdsrvano,
                                                      "","","","","")
                         returning l_resultado, l_mensagem

                    prompt "" for char prompt_key
                    if l_atdsrvnum_original is null then
                       close window cts00m02
                    else
                       close window w_cts00m02t
                    end if
                    let int_flag = false
                    return
                 end if
                 error ""
              end if
       end case
    else
       ## REENVIA TRANSMISSAO AW
       let l_txttiptrx = null
       case d_cts00m02.envtipcod
          when 0  # VOZ
             let l_txttiptrx = 'VOZ'
          when 1  # GPS
             let l_txttiptrx = 'GPS'
          when 2  # INTERNET
             let l_txttiptrx = 'INTERNET'
          when 3  # FAX
             let l_txttiptrx = 'FAX'
       end case
       call ctx34g02_reenviar_conclusao(param.atdsrvnum,
                                        param.atdsrvano,
                                        ws.atdsrvseq,
                                        l_txttiptrx,
                                        g_issk.usrtip,
                                        g_issk.empcod,
                                        g_issk.funmat)
            returning l_resultado,
                      l_mensagem

       error l_mensagem sleep 2
       if l_resultado <> 0 then
          prompt "" for char prompt_key
       end if
       error ""

    end if
 end if

 commit work
 whenever error stop

 #--------------------------------------------------------------------
 # Se servico foi desconcluido, tira da fila de transmissao
 #--------------------------------------------------------------------
 if ws.atdetptipcod    =  1    and
    salva.atdetptipcod <> 1    and
    ws.atdsrvorg       <>  2   then
    call cts00g01_remove(param.atdsrvnum, param.atdsrvano,5)
 end if

 #--------------------------------------------------------------------
 # Grava informacoes sobre retorno ao segurado no historico
 #--------------------------------------------------------------------
 if ws.atdpvtretflg = "S"  then
    if ws.atdsrvorg =  4   or
       ws.atdsrvorg =  6   or
       ws.atdsrvorg =  1   or
       ws.atdsrvorg =  9   or
       ws.atdsrvorg =  13  then
       if salva.atdetpcod      <> 3  and   ### Etapa anterior diferente de
          salva.atdetpcod      <> 4  and   ### etapa de acionamento, com
          d_cts00m02.atdetpcod >= 3  and   ### etapa de acionamento atual
          d_cts00m02.atdetpcod <= 4  then
          call cts00m15(param.atdsrvnum, param.atdsrvano)
       end if
    end if
 end if


 if ws.fax  = true and (not l_acionamentoWEB)  then
    call cts00m14(param.atdsrvnum, param.atdsrvano,
                  d_cts00m02.atdprscod , "F")
 end if

 #--------------------------------------------------------------------
 # Envia Fax para oficinas credenciadas para orgem de servico 4
 #--------------------------------------------------------------------
 if ws.atdsrvorg = 4 then
    let ws.ofnnumdig = NULL
    select ofnnumdig
           into ws.ofnnumdig
      from datmlcl
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
       and c24endtip = 2
    if ws.ofnnumdig is not NULL then
       select ofncrdflg
              into ws.ofncrdflg
         from sgokofi
        where ofnnumdig = ws.ofnnumdig

       if ws.ofncrdflg = "S" then
          call cts00m24(param.atdsrvnum, param.atdsrvano, ws.ofnnumdig, "F")
       end if
    end if
 end if

 if l_atdsrvnum_original is null then
    close window cts00m02
 else
    close window w_cts00m02t
 end if

 let int_flag = false

 call cta00m08_ver_contingencia(2)
      returning l_contingencia

 if g_setexplain = 1 then
    call cts01g01_setetapa("cts00m02 - Fim Atualizacao Base")
 end if

end function  ###--  cts00m02


#--------------------------------------------------------------------
 function cts00m02_envio(param)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdprscod         like datmservico.atdprscod
 end record

 define ws2           record
    envio             char (08),
    faxch1            like datmfax.faxch1,
    faxchx            char (10),
    atdtrxnum         like datmtrxfila.atdtrxnum,
    mdtmsgnum         like datmmdtsrv.mdtmsgnum,
    faxenvdat         like datmfax.faxenvdat,
    interenvdat       like datmsrvint.caddat
 end record




        initialize  ws2.*  to  null

 initialize ws2.*  to null

 declare c_cts00m02_019 cursor for
   select caddat
     from datmsrvint
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
      and pstcoddig = param.atdprscod

 foreach c_cts00m02_019 into ws2.interenvdat
   exit foreach
 end foreach

 if ws2.interenvdat is not null then
    let ws2.envio = "INTERNET"
    return ws2.envio
 end if

 declare c_cts00m02_020  cursor for
   select atdtrxnum
     from datmtrxfila
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano

 foreach c_cts00m02_020  into  ws2.atdtrxnum
   exit foreach
 end foreach

 if ws2.atdtrxnum  is not null   then
    let ws2.envio = "PAGER"
    return ws2.envio
 end if

 declare c_cts00m02_021  cursor for
   select mdtmsgnum
     from datmmdtsrv
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano

 foreach c_cts00m02_021  into  ws2.mdtmsgnum
   exit foreach
 end foreach

 if ws2.mdtmsgnum  is not null   then
    let ws2.envio = " MDT "
    return ws2.envio
 end if

 let ws2.faxchx = param.atdsrvnum  using "&&&&&&&&",
                  param.atdsrvano  using "&&"
 let ws2.faxch1 = ws2.faxchx

 declare c_cts00m02_022  cursor for
   select faxenvdat
     from datmfax
    where faxsiscod = "CT"
      and faxsubcod = "PS"
      and faxch1    = ws2.faxch1

 foreach c_cts00m02_022  into  ws2.faxenvdat
   exit foreach
 end foreach

 if ws2.faxenvdat  is not null   then
    let ws2.envio = " FAX"
 end if

 return ws2.envio

 end function  ###--  cts00m02_envio


#--------------------------------------------------------------------
 function cts00m02_assist_pass(param)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    pasasivcldes      like datmtrptaxi.pasasivcldes,
    txivlr            like datmassistpassag.txivlr
 end record



 whenever error continue

 select pasasivcldes
   from datmtrptaxi
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 if sqlca.sqlcode = 0  then
    update datmtrptaxi set
       pasasivcldes = param.pasasivcldes
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano

    update datmassistpassag set
       txivlr = param.txivlr
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
 else
    insert into datmtrptaxi (atdsrvnum,
                             atdsrvano,
                             pasasivcldes)
                     values (param.atdsrvnum,
                             param.atdsrvano,
                             param.pasasivcldes)
 end if

 whenever error stop

 return sqlca.sqlcode

 end function  ###--  cts00m02_assist_pass

#-------------------------------------
 function cts00m02_desbloq(param2)
#-------------------------------------

 define param2     record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    socvclcod      like datkveiculo.socvclcod
 end record

 define l_contador smallint,
        l_sair     smallint

 let l_sair = false

 whenever error continue
    update datmservico
       set (socvclcod,
            srrcoddig,
            srrltt   ,
            srrlgt   ,
            atdprvdat)  =
            (null,
             null,
             null,
             null,
             null)
     where atdsrvnum  =  param2.atdsrvnum
       and atdsrvano  =  param2.atdsrvano

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na atz.  do servico. AVISE A INFORMATICA!"
       return sqlca.sqlcode
    end if

    if param2.socvclcod is not null and
       param2.socvclcod <> 0        then
       update datkveiculo
          set socacsflg   = "0"
        where socvclcod = param2.socvclcod

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na atz.  do veiculo. AVISE A INFORMATICA!"
          return sqlca.sqlcode
       end if
    end if

    # --ATUALIZAR O SERVICO MULTIPLO-- #
    for l_contador = 1 to 10

       if am_cts29g00[l_contador].atdmltsrvnum is not null then

          whenever error continue
          execute p_cts00m02_005 using am_cts29g00[l_contador].atdmltsrvnum,
                                     am_cts29g00[l_contador].atdmltsrvano
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error "Erro UPDATE p_cts00m02_005 ", sqlca.sqlcode, " | ", sqlca.sqlerrd[2] sleep 2
             error "cts00m02_desbloq() | ", am_cts29g00[l_contador].atdmltsrvnum, " | ",
                                            am_cts29g00[l_contador].atdmltsrvano sleep 2
             let l_sair = true
             exit for
          end if

       end if

    end for

    if l_sair then
       return 1
    end if

 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(param2.atdsrvnum,
                             param2.atdsrvano)

 return 0

end function  # cts00m02_desbloq


function cts00m02_ciaaerea(param)

   define param      record
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
          vooopc     like datmtrppsgaer.vooopc
   end record

   define l_perguntar     char(1)
         ,l_retorno       smallint
         ,l_mensagem      char(60)
         ,l_aerciacod     like datkciaaer.aerciacod
         ,l_aerpsgrsrflg  like datkciaaer.aerpsgrsrflg
         ,l_aerpsgemsflg  like datkciaaer.aerpsgemsflg

   let l_perguntar = "N"

   open c_cts00m02_004 using param.atdsrvnum, param.atdsrvano, param.vooopc
   foreach c_cts00m02_004 into l_aerciacod

           let l_retorno = null
           let l_mensagem = null
           let l_aerpsgrsrflg = null
           let l_aerpsgemsflg = null

           call ctc10g00_dados_cia(2 ,l_aerciacod)
                returning l_retorno ,l_mensagem, l_mensagem
                         ,l_aerpsgrsrflg ,l_aerpsgemsflg

           if l_aerpsgrsrflg = "S" then
              let l_perguntar = "S"
           else
              let l_perguntar = "N"
           end if

   end foreach

   ## Se as cias so reservam entao perguntar reservar ou emitir ?
   if l_perguntar = "S" then
      return "S", "S"
   end if

   if l_perguntar = "N" then
      return "N", "S"
   end if

end function

#----------------------------------#
function cts00m02_dist(lr_parametro)
#----------------------------------#

  define lr_parametro record
         lclltt_1     like datkmpalgdsgm.lclltt,
         lcllgt_1     like datkmpalgdsgm.lcllgt,
         lclltt_2     like datkmpalgdsgm.lclltt,
         lcllgt_2     like datkmpalgdsgm.lcllgt
  end record

  define l_tempo      decimal(6,1),
         l_rota_final char(32000),
         l_distancia  decimal(8,4),
         l_tipo_rota  char(07)

  let l_tempo      = null
  let l_rota_final = null
  let l_distancia  = null
  let l_tipo_rota  = null

  # -> BUSCA O TIPO DE ROTA
  let l_tipo_rota = ctx25g05_tipo_rota()

  call ctx25g02(lr_parametro.lclltt_1,
                lr_parametro.lcllgt_1,
                lr_parametro.lclltt_2,
                lr_parametro.lcllgt_2,
                l_tipo_rota,
                1)

       returning l_distancia,
                 l_tempo,
                 l_rota_final

  return l_distancia,
         l_rota_final

end function

#-----------------------------------------------------------
function cts00m02_min(lr_param)
#-----------------------------------------------------------
 define lr_param        record
    data          date,
    hora          datetime hour to minute
 end record

 define ws           record
    data_atual       date,
    hora_atual       datetime hour to minute,
    resdat           integer,
    reshor           interval hour(04) to minute,
    chrhor           char (07)
 end record

# ---> OBTER A DATA E HORA DO BANCO
call cts40g03_data_hora_banco(2)
returning ws.data_atual,
          ws.hora_atual

 let ws.resdat = (ws.data_atual - lr_param.data) * 24
 let ws.reshor = (ws.hora_atual - lr_param.hora)

 let ws.chrhor = ws.resdat using "###&" , ":00"
 let ws.reshor = ws.reshor + ws.chrhor

 return ws.reshor

end function  ###  cts00m02_min

#-----------------------------------------------------------
function cts00m02_prazo(lr_param)
#-----------------------------------------------------------
 define lr_param   record
    hora           datetime hour to minute,
    presicao       char(5)
 end record

 define ws           record
    data_atual       date,
    hora_atual       datetime hour to minute,
    retorno          smallint
 end record

 define l_hora_prevista datetime hour to minute,
        l_presicao interval hour to minute

 let l_presicao = lr_param.presicao

 let l_hora_prevista = lr_param.hora + l_presicao

 let ws.retorno = true

 # ---> OBTER A DATA E HORA DO BANCO
 call cts40g03_data_hora_banco(2)
 returning ws.data_atual,
           ws.hora_atual

 if ws.hora_atual > l_hora_prevista then # ATRASADO
     let ws.retorno = false
 end if

 return ws.retorno

end function  ###  cts00m02_prazo

#-----------------------------------------------------------
 function cts00m02_coordenadas(param)
#-----------------------------------------------------------

 define param         record
    atdsrvnum          like datmservico.atdsrvnum,
    atdsrvano          like datmservico.atdsrvano
 end record

 define ws           record
   confirma         char (01)
 end record

 define l_cts00m02    record
     lclltt            like datmlcl.lclltt,         # latitude do servico
     lcllgt            like datmlcl.lcllgt,         # longitude do servico
     c24endtip         like datmlcl.c24endtip,      # tipo de endereco se e destino ou local da ocorrencia
     srrltt            like datmservico.srrltt,     # latitude do socorrista
     srrlgt            like datmservico.srrlgt,      # longitude do socorrista
     c24lclpdrcod      like datmlcl.c24lclpdrcod    # tipo da indexação do serviço
 end record

 define param_popup   record
   linha1              char (40),
   linha2              char (40),
   linha3              char (40),
   linha4              char (40)
 end record

 define sql_socorrista char(200)
 define sql_servico    char(200)
 define l_tipo         int


 initialize l_cts00m02 , param_popup to null

 #para trazer as coodernadas do socorrista

     let sql_socorrista = 'select s.srrltt, ',
                                 's.srrlgt ',
                            'from datmservico s ',
                           'where s.atdsrvnum = ?',
                            ' and s.atdsrvano = ?'
     prepare p_cts00m02_022 from sql_socorrista

     declare c_cts00m02_023 cursor for p_cts00m02_022

     whenever error continue
           open c_cts00m02_023 using param.atdsrvnum,
                                  param.atdsrvano

           fetch c_cts00m02_023 into l_cts00m02.srrltt,
                                  l_cts00m02.srrlgt,
                                  l_cts00m02.c24lclpdrcod

          if l_cts00m02.srrltt is null or l_cts00m02.srrltt  = '' and
             l_cts00m02.srrlgt is null or l_cts00m02.srrlgt  = '' then
                 let param_popup.linha4 = "Viatura: Coordenadas não Disponiveis"
           else
            let param_popup.linha4 = "Viatura: ",l_cts00m02.srrltt,", ",l_cts00m02.srrlgt
          end if
     whenever error stop

     close c_cts00m02_023
 #fim da operacao do socorrista

 #para trazer as coodernadas do servico
     let l_cts00m02.lclltt = null
     let l_cts00m02.lcllgt = null
     let sql_servico ='select l.lclltt,',
                            ' l.lcllgt,',
                            ' l.c24lclpdrcod',
                       ' from datmlcl l',
                      ' where l.atdsrvnum = ?',
                        ' and l.atdsrvano = ?',
                        ' and l.c24endtip = ?'

     let l_tipo = 1

     prepare p_cts00m02_023 from sql_servico

     declare c_cts00m02_024 cursor for p_cts00m02_023

     whenever error continue
            open c_cts00m02_024 using param.atdsrvnum,
                                 param.atdsrvano,
                                 l_tipo     #local do servico

           fetch c_cts00m02_024 into l_cts00m02.lclltt,
                                l_cts00m02.lcllgt,
                                l_cts00m02.c24lclpdrcod

        if (l_cts00m02.lclltt is null or l_cts00m02.lclltt  = '') or
           (l_cts00m02.lcllgt is null or l_cts00m02.lcllgt  = '') then

                  let param_popup.linha2 = "QTH: Coordenadas não Disponiveis"
           else
                  let param_popup.linha2 = "QTH: ",l_cts00m02.lclltt,", ",l_cts00m02.lcllgt
           end if
      whenever error stop
      # indexação do serviço
      case l_cts00m02.c24lclpdrcod
          when 1 let param_popup.linha1 = "Indexacao: Por Cidade"
          when 2 let param_popup.linha1 = "Indexacao: Por Guia Postal"
          when 3 let param_popup.linha1 = "Indexacao: Por Rua"
          when 4 let param_popup.linha1 = "Indexacao: Por Bairro"
          when 5 let param_popup.linha1 = "Indexacao: Por Sub-Bairro"
      end case
      close c_cts00m02_024

      let l_cts00m02.lclltt = null
      let l_cts00m02.lcllgt = null
      let l_tipo = 2
      whenever error continue

            open c_cts00m02_024 using param.atdsrvnum,
                                 param.atdsrvano,
                                 l_tipo     #destino
           fetch c_cts00m02_024 into l_cts00m02.lclltt,
                                  l_cts00m02.lcllgt

        if (l_cts00m02.lclltt is null or l_cts00m02.lclltt  = '') or
           (l_cts00m02.lcllgt is null or l_cts00m02.lcllgt  = '') then
                    let param_popup.linha3 = "QTI: Coordenadas não Disponiveis"
           else
                    let param_popup.linha3 = "QTI: ",l_cts00m02.lclltt,", ",l_cts00m02.lcllgt
           end if
      whenever error stop

      close c_cts00m02_024
     # fecha destino
      call cts08g01("C","N",param_popup.linha1,
                            param_popup.linha2,
                            param_popup.linha3,
                            param_popup.linha4)
           returning ws.confirma

      if int_flag then
         let int_flag = "false"
      end if
 end function # cts00m02_coordenadas


#-----------------------------------------------------------
function cts00m02_limite_itau(param)
#-----------------------------------------------------------

define param         record
    atdsrvnum          like datmservico.atdsrvnum,
    atdsrvano          like datmservico.atdsrvano
 end record

 define l_socntzcod    like datmsrvre.socntzcod
 define l_ciaempcod    like datmservico.ciaempcod
 define l_asiplncod    like datkresitaasipln.asiplncod

 define lr_cts00m02 record
        ntzvlr    like datrntzasipln.ntzvlr   ,
        mobrefvlr like dpakpecrefvlr.mobrefvlr,
        pecmaxvlr like dpakpecrefvlr.pecmaxvlr,
        saldo     decimal(6,2),
        aux       char(1)
 end record

 define lr_cts00m02_apol record
        itaciacod     like datmresitaapl.itaciacod,
        itaramcod     like datmresitaapl.itaramcod,
        aplnum        like datmresitaapl.aplnum   ,
        aplseqnum     like datmresitaapl.aplseqnum,
        aplitmnum     like datmresitaaplitm.aplitmnum
 end record

 define lr_retorno record
        erro          integer,
        mensagem      char(50)
 end record

 initialize lr_cts00m02.* to null

  whenever error continue
     select a.socntzcod, b.ciaempcod
       into l_socntzcod, l_ciaempcod
       from datmsrvre a,
            datmservico b
      where a.atdsrvnum = b.atdsrvnum
        and a.atdsrvano = b.atdsrvano
        and a.atdsrvnum = param.atdsrvnum
        and a.atdsrvano = param.atdsrvano
  whenever error stop


  whenever error continue
     select mobrefvlr,
            pecmaxvlr
       into lr_cts00m02.mobrefvlr,
            lr_cts00m02.pecmaxvlr
       from dpakpecrefvlr
      where socntzcod = l_socntzcod
        and empcod    = l_ciaempcod
  whenever error stop

  if (lr_cts00m02.mobrefvlr is not null or lr_cts00m02.mobrefvlr <> '') and
     (lr_cts00m02.pecmaxvlr is not null or lr_cts00m02.pecmaxvlr <> '') then


     if l_ciaempcod = 84 then
        call cty25g01_rec_dados_itau(g_documento.itaciacod,
                                     g_documento.ramcod,
                                     g_documento.aplnumdig,
                                     g_documento.edsnumref,
                                     g_documento.itmnumdig)
            returning  lr_retorno.erro,
                       lr_retorno.mensagem
        whenever error continue
           select asiplncod
             into l_asiplncod
            from datkresitaasipln
            where srvcod = g_doc_itau[1].itaasisrvcod
        whenever error stop

        whenever error continue
           select ntzvlr
             into lr_cts00m02.ntzvlr
            from datrntzasipln
           where socntzcod  = l_socntzcod
             and asiplncod  = l_asiplncod
        whenever error stop
        if lr_cts00m02.ntzvlr is null or lr_cts00m02.ntzvlr = " " then
           let lr_cts00m02.saldo = 0.0
           let lr_cts00m02.ntzvlr = 0.0
        else
           let lr_cts00m02.saldo =  lr_cts00m02.ntzvlr - (lr_cts00m02.mobrefvlr + lr_cts00m02.pecmaxvlr)
        end if
     else
        let lr_cts00m02.saldo = 0.0
        let lr_cts00m02.ntzvlr = 0.0
     end if


     if lr_cts00m02.saldo <= 0 then
        error "Saldo do cliente insuficiente!"
     end if


     open window cts00m02a at 09,41 with form "cts00m02a"
                               attribute (form line 1, border, comment line last - 1)


     display by name lr_cts00m02.ntzvlr,
                     lr_cts00m02.mobrefvlr,
                     lr_cts00m02.pecmaxvlr,
                     lr_cts00m02.saldo

      input by name  lr_cts00m02.aux without defaults

     close window cts00m02a


  else
     error "Funcao nao disponivel para este servico!"
  end if

end function

#--------------------------------------------------------------#
 function cts00m02_verifica_acesso_acionamento(parametroOrigem)
#--------------------------------------------------------------#
  define parametroOrigem like datmservico.atdsrvorg
  
  define l_status smallint,
         l_chavedominio like datkdominio.cponom,
         l_chavematricula char(10)

  initialize l_status, l_chavedominio, l_chavematricula to null

  if m_cts00m02_prep is null or
     m_cts00m02_prep <> true then
     call cts00m02_prepare()
  end if

  whenever error continue
  let l_chavedominio   = 'ACN_IFX_ORIGEM_', parametroOrigem using "<<&"
  let l_chavematricula = g_issk.empcod using "<<&", ",", g_issk.funmat using "<<<<<<<<<&"
  
  open c_cts00m02_025 using l_chavedominio, l_chavematricula
  fetch c_cts00m02_025 into l_status
  if  sqlca.sqlcode = 0 then
  	  close c_cts00m02_025
      whenever error stop
      return true
  end if
  close c_cts00m02_025
  whenever error stop
  return false
 end function