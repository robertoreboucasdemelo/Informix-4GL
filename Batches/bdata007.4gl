#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: bdata007                                                   #
# Objetivo.......: Batch de Geracao do Arquivo Para o Siebel Azul             #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 16/03/2015                                                 #
#-----------------------------------------------------------------------------#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica  Origem     Alteracao                              #
# ---------- -------------- ---------- ---------------------------------------#
# 08/05/2015 Marcos Goes               Modificacao do mecanismo de loop da    #
#                                      carga diaria para considerar sequencias#
#                                      anteriores.                            #
#.............................................................................#
# 10/09/2015 Alberto                   Correção do Path de log                #  
#.............................................................................#


database porto

globals
   define g_ismqconn smallint
end globals


define m_path_log        char(100)
define m_tipo            integer
define m_bdata007_prep   smallint
define m_mensagem        char(150)
define m_seq             integer
define m_cont            integer
define m_commit          integer
define m_first           integer
define m_quebra          integer
define m_acesso          integer
define m_flag            integer
define m_gravou          smallint
define m_inativou        smallint
define m_msg_mail        char(10000)

define mr_count1 record
   lidos    integer,
   motor    integer,
   relat    integer,
   inat     integer,
   claus    integer,
   cober    integer,
   categ    integer,
   cidad    integer,
   apoli    integer,
   cpf      integer,
   claus2   integer,
   des_clau integer,
   proce    integer      
end record

define mr_total record
   lidos    integer,
   motor    integer,
   relat    integer,
   inat     integer,
   claus    integer,
   cober    integer,
   categ    integer,
   cidad    integer,
   apoli    integer,
   cpf      integer,
   claus2   integer,
   des_clau integer,
   proce    integer   
end record

define mr_param record
	  ini                date                       ,
	  fim                date                       ,
	  hour_ini           datetime hour to second    ,
	  hour_fim           datetime hour to second    ,
	  azlaplcod_primeiro like datkazlapl.azlaplcod  ,
	  azlaplcod_ultimo   like datkazlapl.azlaplcod
end record


define mr_especialidade record
  srvespnum like datksrvesp.srvespnum ,
  srvespnom like datksrvesp.srvespnom ,
  regatldat like datksrvesp.regatldat
end record


define mr_processo1 record
  azlaplcod  like datkazlapl.azlaplcod ,
  doc_handle integer                   ,
  endlgdtip  like gsakend.endlgdtip    ,
  endlgd     like gsakend.endlgd       ,
  endnum     like gsakend.endnum       ,
  endbrr     like gsakend.endbrr       ,
  endcmp     like gsakend.endcmp       ,
  cep        char(10)
end record


define mr_processo2 record
  succod                  like abbmdoc.succod                      ,
  aplnumdig               like abbmdoc.aplnumdig                   ,
  itmnumdig               like abbmdoc.itmnumdig                   ,
  edsnumref               like abamdoc.edsnumdig                   ,
  segnumdig               like abbmdoc.segnumdig                   ,
  clalclcod               like abbmdoc.clalclcod                   ,
  cbtcod                  like abbmcasco.cbtcod                    ,
  ctgtrfcod               like abbmcasco.ctgtrfcod                 ,
  clcdat                  like abbmcasco.clcdat                    ,
  clscod                  like abbmclaus.clscod                    ,
  empcod                  like datkplncls.empcod                   ,
  ramcod                  like datkplncls.ramcod                   ,
  plnclscod               like datkplncls.plnclscod                ,
  srvgrptipcod            like datksrvgrptip.srvgrptipcod          ,
  srvgrptipnom            like datksrvgrptip.srvgrptipnom          ,
  srvcod                  like datksrv.srvcod                      ,
  srvnom                  like datksrv.srvnom                      ,
  srvplnclsevnlimvlr      like datksrvplncls.srvplnclsevnlimvlr    ,
  srvplnclsevnlimundnom   like datksrvplncls.srvplnclsevnlimundnom ,
  srvespnum               like datksrvesp.srvespnum                ,
  srvespnom               like datksrvesp.srvespnom                ,
  clssrvesplimvlr         like datkclssrvesp.clssrvesplimvlr       ,
  clssrvesplimundnom      like datkclssrvesp.clssrvesplimundnom    ,
  undsrvcusvlr            like datkclssrvesp.undsrvcusvlr          ,
  undsrvcusundnom         like datkclssrvesp.undsrvcusundnom       ,
  empnom                  like gabkemp.empnom                      ,
  srvplnclscod            like datksrvplncls.srvplnclscod          ,
  lclclartccod            like datklclclartc.lclclartccod          ,
  endcid                  like gsakend.endcid                      ,
  endufd                  like gsakend.endufd                      ,
  emsdat                  like abamapol.emsdat                     ,
  codcls                  like datkplncls.clscod                   ,
  clsnom                  like datkplncls.clsnom                   ,
  clssitflg               like datkplncls.clssitflg                ,
  codprod                 smallint                                 ,
  nscdat                  like gsakseg.nscdat                      ,
  segsex                  like gsakseg.segsex                      ,
  pestip                  like gsakseg.pestip                      ,
  viginc                  like abamapol.viginc                     ,
  vigfnl                  like abamapol.vigfnl                     ,
  vcluso                  like abbmveic.vcluso                     ,
  rspdat                  like abbmquestionario.rspdat             ,
  rspcod                  like abbmquestionario.rspcod             ,
  perfil                  integer                                  ,
  imsvlr                  like abbmcasco.imsvlr                    ,
  prporgidv               like abbmdoc.prporgidv                   ,
  prpnumidv               like abbmdoc.prpnumidv                   ,
  cgccpfnum               like gsakseg.cgccpfnum                   ,
  cgcord                  like gsakseg.cgcord                      ,
  cgccpfdig               like gsakseg.cgccpfdig                   ,
  data_atual              char(20)                 ,
  data_canc               datetime year to minute                  ,
  documento               char(30)                                 ,
  doc_prop                char(30)                                 ,
  codtipdoc               smallint                                 ,
  pcmflg                  char(1)                                  ,
  data_calculo            date                                     ,
  flag_endosso            char(01)                                 ,
  erro                    integer                                  ,
  clausula                like abbmclaus.clscod                    ,
  data_ger                datetime year to second                  ,
  clsviginidat            like datkplncls.clsviginidat
end record

define mr_processo3 record
  plnclscod               like datkplncls.plnclscod                ,
  srvcod                  like datksrv.srvcod                      ,
  srvplnclscod            like datksrvplncls.srvplnclscod          ,
  lclclartccod            like datklclclartc.lclclartccod          ,
  codcls                  like datkplncls.clscod                   ,
  clsnom                  like datkplncls.clsnom                   ,
  clssitflg               like datkplncls.clssitflg                ,
  pcmflg                  char(1)                                  
end record

define  mr_inconsistencia  record
  succod                  like abbmdoc.succod                      ,
  aplnumdig               like abbmdoc.aplnumdig                   ,
  itmnumdig               like abbmdoc.itmnumdig                   ,
  dctnumseq               like abbmdoc.itmnumdig                   ,
  emsdat                  like abamapol.emsdat                     ,
  viginc                  like abamapol.viginc                     ,
  vigfnl                  like abamapol.vigfnl                     ,
  cgccpfnum               like gsakseg.cgccpfnum                   ,
  cgcord                  like gsakseg.cgcord                      ,
  cgccpfdig               like gsakseg.cgccpfdig                   ,
  clscod                  like abbmclaus.clscod                    ,
  clcdat                  like abbmcasco.clcdat                    ,
  plnclscod               like datkplncls.plnclscod                ,
  srvcod                  like datksrvplncls.srvplnclscod          ,
  cbtcod                  like abbmcasco.cbtcod                    ,
  ctgtrfcod               like abbmcasco.ctgtrfcod                 ,
  clalclcod               like abbmdoc.clalclcod                   ,
  endcid                  like gsakend.endcid                      ,
  endufd                  like gsakend.endufd                      ,
  mtvinc                  char(60)                                 ,
  perfil                  integer                                  ,
  pestip                  like gsakseg.pestip                      ,
  nscdat                  like gsakseg.nscdat                      ,
  rspdat                  like abbmquestionario.rspdat             ,
  rspcod                  like abbmquestionario.rspcod             ,
  doctipcod               smallint                                 ,
  prporgidv               like abbmdoc.prporgidv                   ,
  prpnumidv               like abbmdoc.prpnumidv                   ,
  idade                   smallint                                 ,
  prporgpcp               like apamcapa.prporgpcp                  ,
  prpnumpcp               like apamcapa.prpnumpcp                  ,
  dtger                   date                                     ,
  empcod                  smallint                                 ,
  ramcod                  decimal(5,0)
end record

define mr_funapol  record
   resultado       char(01),
   dctnumseq       decimal(04,00),
   vclsitatu       decimal(04,00),
   autsitatu       decimal(04,00),
   dmtsitatu       decimal(04,00),
   dpssitatu       decimal(04,00),
   appsitatu       decimal(04,00),
   vidsitatu       decimal(04,00)
end record

define mr_data record
  inicio date ,
  fim    date
end record




#========================================================================
main
#========================================================================

   # Funcao responsavel por preparar o programa para a execucao
   # - Prepara as instrucoes SQL
   # - Obtem os caminhos de processamento
   # - Cria o arquivo de log

   initialize mr_count1.*, mr_param.* to null

   let mr_total.lidos      = 0
   let mr_total.motor      = 0
   let mr_total.relat      = 0  
   let mr_total.proce      = 0    
   let mr_total.inat       = 0
   let mr_total.claus      = 0
   let mr_total.cober      = 0
   let mr_total.categ      = 0
   let mr_total.cidad      = 0
   let mr_total.apoli      = 0
   let mr_total.cpf        = 0
   let mr_total.claus2     = 0
   let mr_total.des_clau   = 0
   let m_gravou            = false
   let m_inativou          = false
   let m_commit            = 0
   let m_msg_mail          = ""

   call bdata007_cria_log()

   call bdata007_exibe_inicio()

   call fun_dba_abre_banco("CT24HS")

   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata007_prep = false

   display "##################################"
   display " PREPARANDO... "
   display "##################################"
   call bdata007_prepare()

   display "##################################"
   display " RECUPERANDO QUEBRA... "
   display "##################################"
   if not bdata007_recupera_quebra() then
      exit program
   end if

   ##################
   ### CARGA FULL ###
   ##################
   if bdata007_valida_carga() then

      if not bdata007_carga_full() then
         let m_mensagem = "Carga Full abortada. Verificar os dominios."
         call ERRORLOG(m_mensagem);
         display m_mensagem
      end if
      call bdata007_atualiza_full()
   end if

   ####################
   ### CARGA DIARIA ###
   ####################
   if not bdata007_carga_diaria() then
      exit program
   end if

   call bdata007_exibe_final()

   call bdata007_dispara_email()

#========================================================================
end main
#========================================================================

#===============================================================================
function bdata007_prepare()
#===============================================================================

define l_sql char(10000)


 let l_sql =  ' SELECT a.azlaplcod          '
             ,'       ,a.succod             '
             ,'       ,a.aplnumdig          '
             ,'       ,a.itmnumdig          '
             ,'       ,a.ramcod             '
             ,'       ,a.edsnumdig          '
             ,'       ,a.prporg             '
             ,'       ,a.prpnumdig          '
             ,'       ,a.pestip             '
             ,'       ,a.cgccpfnum          '
             ,'       ,a.cgcord             '
             ,'       ,a.cgccpfdig          '
             ,' FROM datkazlapl a           '
             ,' WHERE azlaplcod BETWEEN ? AND ? '
             ,' AND a.edsnumdig in (SELECT max(edsnumdig)           '
             ,'                     FROM  datkazlapl b              '
             ,'                     WHERE a.succod    = b.succod    '
             ,'                     and   a.aplnumdig = b.aplnumdig '
             ,'                     and   a.itmnumdig = b.itmnumdig '
             ,'                     and   a.ramcod    = b.ramcod)   '
             ,' ORDER BY azlaplcod '
 prepare p_bdata007_001 from l_sql
 declare c_bdata007_001 cursor with hold for p_bdata007_001
 	
 	let l_sql = '  select count(*)                   '
            , '  from datkplncls                   '
            , '  where empcod =  ?                 '
            , '  and   ramcod =  ?                 '
            , '  and   clscod =  ?                 '
            , '  and   prfcod =  ?                 '
            , '  and   plnclscod <>  ?             ' 
            , '  and   clsvigfimdat <= ?           '                   
  prepare p_bdata007_002 from l_sql
  declare c_bdata007_002 cursor for p_bdata007_002
  	
  let l_sql = '  select plnclscod                  '
            , '  from datkplncls                   '
            , '  where empcod =  ?                 '
            , '  and   ramcod =  ?                 '
            , '  and   clscod =  ?                 '
            , '  and   prfcod =  ?                 '
            , '  and   plnclscod <>  ?             ' 
            , '  and   clsvigfimdat <= ?           '                   
  prepare p_bdata007_003 from l_sql
  declare c_bdata007_003 cursor for p_bdata007_003
  	
  let l_sql = ' select a.srvcod                 ,   '
             ,'        a.srvplnclscod           ,   '
             ,'        b.clscod                 ,   '
             ,'        b.clsnom                 ,   '
             ,'        b.clssitflg                  '
             ,' from datksrvplncls a,               '
             ,'      datkplncls b                   '
             ,' where b.plnclscod  = a.plnclscod    '
             ,' and   a.plnclscod  = ?              '
  prepare p_bdata007_004 from l_sql
  declare c_bdata007_004 cursor with hold for p_bdata007_004
  	
  let l_sql = ' select count(*)      '
              ,' from datmbnfcrgmov   '
              ,' where empcod =  ?    '
              ,' and   dcttipcod =  ? '
              ,' and   succod =  ?    '
              ,' and   ramcod =  ?    ' 
              ,' and   apldignum =  ? '
              ,' and   itmdignum =  ? '
              ,' and   dctedsnum =  ? '
              ,' and   pctcod    =  ? ' 
              ,' and   dctclscod =  ? '
              ,' and   pcmflg in ("S","N") '                    
   prepare p_bdata007_005 from l_sql
   declare c_bdata007_005 cursor for p_bdata007_005 
   	
   let l_sql = ' select count(*)      '
              ,' from datmbnfcrgmov   '
              ,' where empcod =  ?    '
              ,' and   dcttipcod =  ? '
              ,' and   succod =  ?    '
              ,' and   ramcod =  ?    ' 
              ,' and   apldignum =  ? '
              ,' and   itmdignum =  ? '
              ,' and   dctedsnum =  ? '
              ,' and   pctcod    =  ? ' 
              ,' and   dctclscod =  ? '
              ,' and   pcmflg in ("R","E") '                    
   prepare p_bdata007_006 from l_sql
   declare c_bdata007_006 cursor for p_bdata007_006 		


  let l_sql = ' select plnclscod ,        '      
            , '        clsviginidat       '
            , '   from datkplncls         '
            , '  where empcod =  ?        '
            , '  and   ramcod =  ?        '
            , '  and   clscod =  ?        '
            , '  and   prfcod =  ?        '
            , '  and   clsviginidat <=  ? '
            , '  and   clsvigfimdat >=  ? '
            , '  and   regsitflg = "A"    '
  prepare p_bdata007_011 from l_sql
  declare c_bdata007_011 cursor for p_bdata007_011

  let l_sql = ' select a.srvcod                 ,   '
             ,'        a.srvplnclscod           ,   '
             ,'        b.clscod                 ,   '
             ,'        b.clsnom                 ,   '
             ,'        b.clssitflg                  '
             ,' from datksrvplncls a,               '
             ,'      datkplncls b                   '
             ,' where b.plnclscod  = a.plnclscod    '
             ,' and   a.plnclscod  = ?              '
  prepare p_bdata007_012 from l_sql
  declare c_bdata007_012 cursor with hold for p_bdata007_012

  let l_sql = ' select empnom     '
             ,' from gabkemp      '
             ,' where empcod = ? 	'
  prepare p_bdata007_013 from l_sql
  declare c_bdata007_013 cursor for p_bdata007_013

  let l_sql = ' select count(*)        '
             ,' from datktrfctgcss     '
             ,' where srvclscod   =  ? '
             ,' and   trfctgcod   =  ? '
  prepare p_bdata007_015 from l_sql
  declare c_bdata007_015 cursor for p_bdata007_015

  let l_sql = ' select lclclartccod       '
             ,' from datklclclartc        '
             ,' where srvclscod    =  ?   '
             ,' and   lclclacod    =  ?   '
  prepare p_bdata007_016 from l_sql
  declare c_bdata007_016 cursor for p_bdata007_016

  let l_sql = ' select count(*)              '
             ,' from datkrtcece a ,          '
             ,'      glakcid    b   	       '
             ,' where a.cidcod = b.cidcod    '
             ,' and   a.lclclartccod =  ?    '
             ,' and   b.cidnom   	   =  ?    '
             ,' and   b.ufdcod       =  ?    '
  prepare p_bdata007_017 from l_sql
  declare c_bdata007_017 cursor for p_bdata007_017

  let l_sql =  ' update datkplncls     '
            ,  ' set irdclsflg = "S"   '
            ,  ' where plnclscod = ?   '
  prepare p_bdata007_019 from l_sql

  let l_sql = ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '
  prepare p_bdata007_020 from l_sql
  declare c_bdata007_020 cursor for p_bdata007_020

  let l_sql =  ' update datkdominio    '
             , ' set   cpodes =  ?     '
             , ' where cponom =  ?     '
             , ' and   cpocod =  ?     '
  prepare p_bdata007_021 from l_sql

  let l_sql = ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
  prepare p_bdata007_027 from l_sql
  declare c_bdata007_027 cursor for p_bdata007_027

  let l_sql = ' select count(*)        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
  prepare p_bdata007_028 from l_sql
  declare c_bdata007_028 cursor for p_bdata007_028

  let l_sql = ' insert into datmbnfcrgmov  '
             ,' ( empcod       '
             ,'  ,prdcod       '
             ,'  ,dcttipcod    '
             ,'  ,succod       '
             ,'  ,ramcod       '
             ,'  ,apldignum    '
             ,'  ,idvprporgcod '
             ,'  ,idvprpdignum '
             ,'  ,itmdignum    '
             ,'  ,pestipcod    '
             ,'  ,cpjcpfnum    '
             ,'  ,cpjordnum    '
             ,'  ,cpjcpfdignum '
             ,'  ,pctcod       '
             ,'  ,incvigdat    '
             ,'  ,fnlvigdat    '
             ,'  ,bnfgrcdat    '
             ,'  ,dctclscod    '
             ,'  ,dctedsnum    '
             ,'  ,pcmflg   )   '
             ,'  values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,? '
             ,'  ,?,?,?,?,?)                           '
   prepare p_bdata007_029 from l_sql

   let l_sql = ' insert into datmbnfcrgico '
             ,' (empcod         '
             ,' ,dcttipcod      '
             ,' ,succod         '
             ,' ,ramcod         '
             ,' ,apldignum      '
             ,' ,itmdignum      '
             ,' ,dctseqnum      '
             ,' ,idvprporgcod   '
             ,' ,idvprpdignum   '
             ,' ,pcpprporgcod   '
             ,' ,pcpprpdignum   '
             ,' ,dctemsdat      '
             ,' ,incvigdat      '
             ,' ,fnlvigdat      '
             ,' ,cpjcpfnum      '
             ,' ,cpjordnum      '
             ,' ,cpjcpfdignum   '
             ,' ,dctclscod      '
             ,' ,dctclsclcdat   '
             ,' ,pestipcod      '
             ,' ,segnscdat      '
             ,' ,pcpcdtnscdat   '
             ,' ,pcpcdtsexcod   '
             ,' ,pcpcdtiddnum   '
             ,' ,segprfcod      '
             ,' ,clsplncod      '
             ,' ,dctsrvcod      '
             ,' ,cbtcod         '
             ,' ,ctgcod         '
             ,' ,lclclacod      '
             ,' ,segcidnom      '
             ,' ,segestsglnom   '
             ,' ,icomtvdes      '
             ,' ,icodat)        '
             ,' values (?,?,?,?,?,?,?,?,?,?,?,?,?,?    '
             ,'  ,?,?,?,?,?,?,?,?,?,?,?,?,?            '
             ,'  ,?,?,?,?,?,?,?  )                     '
  prepare p_bdata007_030 from l_sql

  let l_sql = ' select max(azlaplcod)     '
            , '  from datkazlapl          '
  prepare p_bdata007_031 from l_sql
  declare c_bdata007_031 cursor for p_bdata007_031

  let l_sql = ' select cpodes[5,5]    '
           ,  '   from datkdominio    '
           ,  '  where cponom = ?     '
           ,  '  and cpodes[1,3] = ?  '
  prepare p_bdata007_032 from l_sql
  declare c_bdata007_032 cursor for p_bdata007_032


  let m_bdata007_prep = true

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_cria_log()
#========================================================================

   define l_path char(200)

   let l_path = null
   let l_path = f_path("DAT","LOG")

   if l_path is null or
      l_path = " " then
      let l_path = "."
   end if

   let l_path = m_path_log clipped, "bdata007.log"

   call startlog(l_path)

#========================================================================
end function
#========================================================================


#========================================================================
function bdata007_exibe_inicio()
#========================================================================
define l_data  date,
       l_hora  datetime hour to second

let l_data            = today
let l_hora            = current
let mr_param.ini      = today
let mr_param.hour_ini = current

   display " "
   display "-----------------------------------------------------------"
   display " INICIO bdata007 - CARGA APOLICES AZUL PARA BASE BENEFICIO"
   display "-----------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let m_mensagem = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(m_mensagem)


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_exibe_final()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second


   let l_data            = today
   let l_hora            = current
   let mr_param.fim      = today
   let mr_param.hour_fim = current

   display " "
   display " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   let m_mensagem = " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   call errorlog(m_mensagem)
   call errorlog("------------------------------------------------------")

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_atualiza_full()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_full"
let lr_retorno.cpocod = 1
let lr_retorno.cpodes = "N"

   whenever error continue
   execute p_bdata007_021 using lr_retorno.cpodes,
                                lr_retorno.cponom,
                                lr_retorno.cpocod
   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DA DATA! '
      call ERRORLOG(m_mensagem);
      display m_mensagem
   end if


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_atualiza_exportado()
#========================================================================

   whenever error continue
   execute p_bdata007_019 using mr_processo2.plnclscod

   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DA FLAG EXPORTADO! ', mr_especialidade.srvespnum
      call ERRORLOG(m_mensagem);
      display m_mensagem
   end if


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_exibe_dados_parciais()
#========================================================================

   let mr_count1.des_clau = (mr_count1.apoli - mr_count1.claus2)

   display " "
   display "-----------------------------------------------------------"
   display " DADOS PARCIAIS - DATA ", mr_data.inicio
   display "-----------------------------------------------------------"
   display " "
   display " DADOS LIDOS APOLICE..............: ", mr_count1.apoli
   display " DADOS DESPREZADOS CPF/CNPJ.......: ", mr_count1.cpf
   display " DADOS LIDOS MOTOR CLAUSULA.......: ", mr_count1.lidos
   display " DADOS DESPREZADOS MOTOR CLAUSULA.: ", mr_count1.claus
   display " DADOS BENEFICIOS JA CARREGADOS...: ", mr_count1.proce    
   display " DADOS LIDOS MOTOR DE REGRAS......: ", mr_count1.motor
   display " DADOS DESPREZADOS COBERTURA......: ", mr_count1.cober
   display " DADOS DESPREZADOS CATEGORIA......: ", mr_count1.categ
   display " DADOS DESPREZADOS CIDADE.........: ", mr_count1.cidad
   display " DADOS INATIVADOS.................: ", mr_count1.inat
   display " DADOS GRAVADOS NA TABELA.........: ", mr_count1.relat


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_exibe_dados_totais()
#========================================================================

   let mr_total.des_clau = (mr_total.apoli - mr_total.claus2)

   display " "
   display "-----------------------------------------------------------"
   display " DADOS TOTAIS "
   display "-----------------------------------------------------------"
   display " "
   display " TOTAIS LIDOS APOLICE..............: ", mr_total.apoli
   display " TOTAIS DESPREZADOS CPF/CNPJ.......: ", mr_total.cpf
   display " TOTAIS LIDOS MOTOR CLAUSULA.......: ", mr_total.lidos
   display " TOTAIS DESPREZADOS MOTOR CLAUSULA.: ", mr_total.claus
   display " TOTAIS BENEFICIOS JA CARREGADOS...: ", mr_total.proce
   display " TOTAIS LIDOS MOTOR DE REGRAS......: ", mr_total.motor
   display " TOTAIS DESPREZADOS COBERTURA......: ", mr_total.cober
   display " TOTAIS DESPREZADOS CATEGORIA......: ", mr_total.categ
   display " TOTAIS DESPREZADOS CIDADE.........: ", mr_total.cidad
   display " TOTAIS INATIVADOS.................: ", mr_total.inat
   display " TOTAIS GRAVADOS NA TABELA.........: ", mr_total.relat


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_recupera_quebra()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_quebra"
let lr_retorno.cpocod = 1


  open c_bdata007_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata007_020 into m_quebra
  whenever error stop

  if m_quebra =  ""   or
  	 m_quebra is null or
  	 m_quebra =  0    then
     return false
  end if

  return true


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_dispara_email()
#========================================================================

define lr_mail      record
       de           char(500)   # De
      ,para         char(5000)  # Para
      ,cc           char(500)   # cc
      ,cco          char(500)   # cco
      ,assunto      char(500)   # Assunto do e-mail
      ,mensagem     char(32766) # Nome do Anexo
      ,id_remetente char(20)
      ,tipo         char(4)     #
  end  record

define l_erro  smallint
define msg_erro char(500)
initialize lr_mail.* to null


    let lr_mail.de      = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para    = bdata007_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""

    let lr_mail.assunto = "Carga Base Beneficios - AZUL"

    let lr_mail.mensagem  = bdata007_monta_mensagem()
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"

    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro



#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_recupera_email()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes,
	email   char(32766)            ,
	flag    smallint
end record

initialize lr_retorno.* to null

let lr_retorno.flag = true

let lr_retorno.cponom = "bdata007_email"


  open c_bdata007_027 using  lr_retorno.cponom
  foreach c_bdata007_027 into lr_retorno.cpodes

    if lr_retorno.flag then
      let lr_retorno.email = lr_retorno.cpodes clipped
      let lr_retorno.flag  = false
    else
      let lr_retorno.email = lr_retorno.email clipped, ";", lr_retorno.cpodes clipped
    end if


  end foreach


  return lr_retorno.email


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_monta_mensagem()
#========================================================================


define lr_retorno record
	mensagem  char(30000)
end record

initialize lr_retorno.* to null


          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          let lr_retorno.mensagem = "<PRE><P><B>",
                                    " INICIO DO PROCESSAMENTO............: " , mr_param.ini, " - ", mr_param.hour_ini , "<br>",
                                    " FINAL DO PROCESSAMENTO.............: " , mr_param.fim, " - ", mr_param.hour_fim , "</B></P>",
                                    "<P>", m_msg_mail clipped, "</P><br><P>",
                                    " TOTAIS LIDOS APOLICE...............: " , mr_total.apoli     , "<br>" ,
                                    " TOTAIS DESPREZADOS CPF/CNPJ........: " , mr_total.cpf       , "<br>" ,
                                    " TOTAIS LIDOS MOTOR CLAUSULA........: " , mr_total.lidos     , "<br>" ,
                                    " TOTAIS BENEFICIOS JA CARREGADOS....: " , mr_total.proce     , "<br>" , 
                                    " TOTAIS DESPREZADOS MOTOR CLAUSULA..: " , mr_total.claus     , "<br>" ,
                                    " TOTAIS LIDOS MOTOR DE REGRAS.......: " , mr_total.motor     , "<br>" ,
                                    " TOTAIS DESPREZADOS COBERTURA.......: " , mr_total.cober     , "<br>" ,
                                    " TOTAIS DESPREZADOS CATEGORIA.......: " , mr_total.categ     , "<br>" ,
                                    " TOTAIS DESPREZADOS CIDADE..........: " , mr_total.cidad     , "<br>" ,
                                    " TOTAIS INATIVADOS..................: " , mr_total.inat      , "<br>" ,
                                    " TOTAIS GRAVADOS NO RELATORIO.......: " , mr_total.relat     , "<br></P></PRE>"

          return lr_retorno.mensagem

#========================================================================
end function
#========================================================================
#========================================================================
function bdata007_grava_inconsistencia()
#========================================================================
define lr_retorno record
	status  char(3000)
end record

initialize lr_retorno.* to null

   #display "INCONSISTENCIA"

   whenever error continue
   execute p_bdata007_030 using   mr_inconsistencia.empcod
                                , mr_inconsistencia.doctipcod
                                , mr_inconsistencia.succod
                                , mr_inconsistencia.ramcod
                                , mr_inconsistencia.aplnumdig
                                , mr_inconsistencia.itmnumdig
                                , mr_inconsistencia.dctnumseq
                                , mr_inconsistencia.prporgidv
                                , mr_inconsistencia.prpnumidv
                                , mr_inconsistencia.prporgpcp
                                , mr_inconsistencia.prpnumpcp
                                , mr_inconsistencia.emsdat
                                , mr_inconsistencia.viginc
                                , mr_inconsistencia.vigfnl
                                , mr_inconsistencia.cgccpfnum
                                , mr_inconsistencia.cgcord
                                , mr_inconsistencia.cgccpfdig
                                , mr_inconsistencia.clscod
                                , mr_inconsistencia.clcdat
                                , mr_inconsistencia.pestip
                                , mr_inconsistencia.nscdat
                                , mr_inconsistencia.rspdat
                                , mr_inconsistencia.rspcod
                                , mr_inconsistencia.idade
                                , mr_inconsistencia.perfil
                                , mr_inconsistencia.plnclscod
                                , mr_inconsistencia.srvcod
                                , mr_inconsistencia.cbtcod
                                , mr_inconsistencia.ctgtrfcod
                                , mr_inconsistencia.clalclcod
                                , mr_inconsistencia.endcid
                                , mr_inconsistencia.endufd
                                , mr_inconsistencia.mtvinc
                                , mr_inconsistencia.dtger
   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DAS INCONSISTENCIA! '
      call ERRORLOG(m_mensagem);
      display m_mensagem
      let lr_retorno.status = false
   else
      let lr_retorno.status = true
   end if

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_grava_beneficio()
#========================================================================
define lr_retorno record
	status  char(30000)
end record

initialize lr_retorno.* to null

let mr_processo2.data_ger = today


   whenever error continue
   execute p_bdata007_029 using mr_processo2.empcod
                              , mr_processo2.codprod
                              , mr_processo2.codtipdoc
                              , mr_processo2.succod
                              , mr_processo2.ramcod
                              , mr_processo2.aplnumdig
                              , mr_processo2.prporgidv
                              , mr_processo2.prpnumidv
                              , mr_processo2.itmnumdig
                              , mr_processo2.pestip
                              , mr_processo2.cgccpfnum
                              , mr_processo2.cgcord
                              , mr_processo2.cgccpfdig
                              , mr_processo2.srvcod
                              , mr_processo2.viginc
                              , mr_processo2.vigfnl
                              , mr_processo2.data_ger
                              , mr_processo2.codcls
                              , mr_processo2.edsnumref
                              , mr_processo2.pcmflg
   whenever error continue

   if sqlca.sqlcode <> 0 then

      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DOS BENEFICIOS! '
      let mr_inconsistencia.mtvinc = m_mensagem

      call bdata007_grava_inconsistencia()
      call ERRORLOG(m_mensagem);

      display m_mensagem
      let lr_retorno.status = false
   else
      let lr_retorno.status = true
   end if

   return lr_retorno.status

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_valida_carga()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_full"
let lr_retorno.cpocod = 1


  open c_bdata007_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata007_020 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes =  "S"  then
     return true
  end if

  return false
#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_carga_full()
#========================================================================

   display "##################################"
   display " CARREGANDO APOLICES FULL... "
   display "##################################"

   initialize mr_data.* to null

  let m_tipo = 1

  call bdata007_recupera_codigo_inicio_full()

  call bdata007_recupera_codigo_ultimo_full()

  if mr_param.azlaplcod_primeiro  is null or
  	 mr_param.azlaplcod_ultimo    is null then
  	  let m_mensagem = "Codigos Nulos!"
  	  call ERRORLOG(m_mensagem);
  	  display m_mensagem
  	  return false
  end if

  if mr_param.azlaplcod_primeiro >  mr_param.azlaplcod_ultimo then
  	  let m_mensagem = "Codigos Invalidos!"
  	  call ERRORLOG(m_mensagem);
  	  display m_mensagem
  	  return false
  end if

   let m_mensagem = " CARGA AZUL FULL (azlaplcod)........: ", mr_param.azlaplcod_primeiro, " - ", mr_param.azlaplcod_ultimo
   call bdata001_monta_mensagem2(m_mensagem)  

  call bdata007_carrega_beneficio()

  call bdata007_exibe_dados_totais()

  return true

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_carga_diaria()
#========================================================================


   display "##################################"
   display " CARREGANDO APOLICES DIARIAS... "
   display "##################################"

   initialize mr_data.* to null

  let m_tipo = 2

  call bdata007_recupera_codigo_inicio_diario()

  call bdata007_recupera_codigo_ultimo_diario()

  if mr_param.azlaplcod_primeiro  is null or
  	 mr_param.azlaplcod_ultimo    is null then
  	  let m_mensagem = "Codigos Nulos!"
  	  call ERRORLOG(m_mensagem);
  	  display m_mensagem
  	  return false
  end if

  if mr_param.azlaplcod_primeiro >  mr_param.azlaplcod_ultimo then
  	  let m_mensagem = "Codigos Invalidos!"
  	  call ERRORLOG(m_mensagem);
  	  display m_mensagem
  	  return false
  end if

   let m_mensagem = " CARGA AZUL DIARIA (azlaplcod)......: ", mr_param.azlaplcod_primeiro, " - ", mr_param.azlaplcod_ultimo
   call bdata001_monta_mensagem2(m_mensagem)

  call bdata007_carrega_beneficio()

  call bdata007_exibe_dados_totais()


  return true

#========================================================================
end function
#========================================================================


#========================================================================
function bdata007_atualiza_codigo_full()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_full_ini"
let lr_retorno.cpocod = 1

   whenever error continue
   execute p_bdata007_021 using mr_processo1.azlaplcod   ,
                                lr_retorno.cponom        ,
                                lr_retorno.cpocod
   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DO CODIGO! '
      call ERRORLOG(m_mensagem);
      display m_mensagem
   end if


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_atualiza_codigo_diario()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_dia_ini"
let lr_retorno.cpocod = 1

   whenever error continue
   execute p_bdata007_021 using mr_processo1.azlaplcod   ,
                                lr_retorno.cponom        ,
                                lr_retorno.cpocod
   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DO CODIGO! '
      call ERRORLOG(m_mensagem);
      display m_mensagem
   end if


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_carrega_beneficio()
#========================================================================

define lr_retorno record
	 cont          integer                 ,
	 grava         smallint                ,
	 aplnumdig_ant like abbmdoc.aplnumdig  ,
	 qtd           integer                 ,
	 tag           char(100)
end record

define l_data date
define l_hora datetime hour to second
define l_idx  integer

initialize mr_processo1.* to null
initialize mr_processo2.* to null
initialize mr_processo3.* to null
initialize mr_inconsistencia.* to null

let l_data         = null
let l_hora         = null
let lr_retorno.tag = null

let mr_processo2.empcod         = 35
let mr_processo2.codprod        = 01
let mr_processo2.codtipdoc      = 1
let mr_processo2.pcmflg         = 'S'
let lr_retorno.cont             = 0
let lr_retorno.grava            = false
let lr_retorno.aplnumdig_ant    = 0
let lr_retorno.qtd              = 0
let mr_count1.lidos             = 0
let mr_count1.motor             = 0
let mr_count1.relat             = 0 
let mr_count1.proce             = 0 
let mr_count1.inat              = 0
let mr_count1.claus             = 0
let mr_count1.cober             = 0
let mr_count1.categ             = 0
let mr_count1.cidad             = 0
let mr_count1.apoli             = 0
let mr_count1.cpf               = 0
let mr_count1.claus2            = 0
let mr_count1.des_clau          = 0
let mr_processo2.perfil         = 0
let mr_inconsistencia.empcod    = 35
let mr_inconsistencia.doctipcod = 1
let mr_inconsistencia.dtger     = today

     begin work


     #display "Query 1"
    #--------------------------------------------------------
    # Recupera o Nome da Empresa
    #--------------------------------------------------------

    open c_bdata007_013 using mr_processo2.empcod

    whenever error continue
    fetch c_bdata007_013 into mr_processo2.empnom
    whenever error stop

    #display "Query 2"
    #--------------------------------------------------------
    # Recupera os Dados da Apolice
    #--------------------------------------------------------
    open c_bdata007_001 using mr_param.azlaplcod_primeiro,
                              mr_param.azlaplcod_ultimo

    foreach c_bdata007_001 into mr_processo1.azlaplcod
    	                        , mr_processo2.succod
  	                          , mr_processo2.aplnumdig
                              , mr_processo2.itmnumdig
                              , mr_processo2.ramcod
                              , mr_processo2.edsnumref
                              , mr_processo2.prporgidv
                              , mr_processo2.prpnumidv
                              , mr_processo2.pestip
                              , mr_processo2.cgccpfnum
                              , mr_processo2.cgcord
                              , mr_processo2.cgccpfdig

       let mr_processo1.doc_handle = ctd02g00_agrupaXML(mr_processo1.azlaplcod)

       #display "Query 3"
       #--------------------------------------------------------
       # Recupera a Proposta
       #--------------------------------------------------------

       call cts38m00_extrai_proposta(mr_processo1.doc_handle)
       returning mr_processo2.prporgidv,
                 mr_processo2.prpnumidv


       if mr_processo2.prporgidv is null then
       	  let mr_processo2.prporgidv = 0
       end if

       if mr_processo2.prpnumidv is null then
       	  let mr_processo2.prpnumidv = 0
       end if


       #display "Query 4"
       #--------------------------------------------------------
       # Recupera a Data de Emissao
       #--------------------------------------------------------

       call cts38m00_extrai_emissao(mr_processo1.doc_handle)
       returning mr_processo2.emsdat

       #display "Query 5"
       #--------------------------------------------------------
       # Recupera a Data de Vigencia
       #--------------------------------------------------------

       call cts38m00_extrai_vigencia(mr_processo1.doc_handle)
       returning mr_processo2.viginc,
                 mr_processo2.vigfnl


       #display "Query 6"
       #--------------------------------------------------------
       # Recupera a Classe de Localizacao
       #--------------------------------------------------------

       call cts38m00_extrai_classe_localizacao(mr_processo1.doc_handle)
       returning mr_processo2.clalclcod

       #display "Query 7"
       #--------------------------------------------------------
       # Recupera a Categoria Tarifaria
       #--------------------------------------------------------

       call cts38m00_extrai_categoria(mr_processo1.doc_handle)
       returning mr_processo2.ctgtrfcod


       #display "Query 8"
       #--------------------------------------------------------
       # Recupera Cidade do Segurado
       #--------------------------------------------------------

       if mr_processo1.doc_handle is not null then

          call cts40g02_extraiDoXML(mr_processo1.doc_handle, "SEGURADO_ENDERECO")
          returning mr_processo2.endufd    ,
                    mr_processo2.endcid    ,
                    mr_processo1.endlgdtip ,
                    mr_processo1.endlgd    ,
                    mr_processo1.endnum    ,
                    mr_processo1.endcmp    ,
                    mr_processo1.endbrr    ,
                    mr_processo1.cep
       else
          continue foreach
       end if

       let mr_inconsistencia.emsdat    = mr_processo2.emsdat
       let mr_inconsistencia.viginc    = mr_processo2.viginc
       let mr_inconsistencia.vigfnl    = mr_processo2.vigfnl
       let mr_inconsistencia.succod    = mr_processo2.succod
       let mr_inconsistencia.aplnumdig = mr_processo2.aplnumdig
       let mr_inconsistencia.itmnumdig = mr_processo2.itmnumdig
       let mr_inconsistencia.prporgidv = mr_processo2.prporgidv
       let mr_inconsistencia.prpnumidv = mr_processo2.prpnumidv
       let mr_inconsistencia.cgccpfnum = mr_processo2.cgccpfnum
       let mr_inconsistencia.cgcord    = mr_processo2.cgcord
       let mr_inconsistencia.cgccpfdig = mr_processo2.cgccpfdig
       let mr_inconsistencia.pestip    = mr_processo2.pestip
       let mr_inconsistencia.clalclcod = mr_processo2.clalclcod
       let mr_inconsistencia.cbtcod    = mr_processo2.cbtcod
       let mr_inconsistencia.ctgtrfcod = mr_processo2.ctgtrfcod
       let mr_inconsistencia.endcid    = mr_processo2.endcid
       let mr_inconsistencia.endufd    = mr_processo2.endufd
       let mr_inconsistencia.ramcod    = mr_processo2.ramcod

       let mr_count1.apoli = mr_count1.apoli + 1
       let mr_total.apoli  = mr_total.apoli + 1

       if m_tipo = 1 then
          call bdata007_atualiza_codigo_full()
       else
       	  call bdata007_atualiza_codigo_diario()
       end if

       if mr_processo2.cgccpfnum is null then
          let mr_inconsistencia.mtvinc = 'CPF/CNPJ não localizado na tabela datkazlapl'
          call bdata007_grava_inconsistencia()
          let mr_count1.cpf = mr_count1.cpf + 1
          let mr_total.cpf  = mr_total.cpf + 1
          continue foreach
       end if



       #display "Query 9"
       #--------------------------------------------------------
       # Recupera os Dados da Clausula
       #--------------------------------------------------------

       let lr_retorno.qtd = figrc011_xpath(mr_processo1.doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

       for l_idx = 1 to lr_retorno.qtd


       	   let lr_retorno.tag = "/APOLICE/CLAUSULAS/CLAUSULA[", l_idx using "<<<<&","]/CODIGO"
           let mr_processo2.clscod  = figrc011_xpath(mr_processo1.doc_handle,lr_retorno.tag)

       	   let mr_count1.lidos = mr_count1.lidos + 1
       	   let mr_total.lidos  = mr_total.lidos + 1

       	   if mr_processo2.aplnumdig <> lr_retorno.aplnumdig_ant then
       	   	  let mr_count1.claus2 = mr_count1.claus2 + 1
       	      let mr_total.claus2  = mr_total.claus2 + 1
       	   end if

       	   let lr_retorno.aplnumdig_ant = mr_processo2.aplnumdig


       	   if not bdata007_valida_geracao_claus(mr_processo2.clscod) then
       	      let m_mensagem = "Clausula ",mr_processo2.clscod, " Não está cadastrado no dominio "
       	      call errorlog(m_mensagem)
       	      continue for
       	   end if



            #display "Query 10"
            #--------------------------------------------------------
            # Regra 1 - Verifica se a Clausula Existe no Motor
            #--------------------------------------------------------

            open c_bdata007_011 using   mr_processo2.empcod ,
                                        mr_processo2.ramcod ,
                                        mr_processo2.clscod ,
                                        mr_processo2.perfil ,
                                        mr_processo2.viginc ,
                                        mr_processo2.viginc
            whenever error continue
            fetch c_bdata007_011 into   mr_processo2.plnclscod,
                                        mr_processo2.clsviginidat
            whenever error stop

            let mr_inconsistencia.clscod    = mr_processo2.clscod
            let mr_inconsistencia.perfil    = mr_processo2.perfil
            let mr_inconsistencia.plnclscod = mr_processo2.plnclscod
            let mr_inconsistencia.clcdat    = mr_processo2.clcdat

            if sqlca.sqlcode = notfound  then

            	 let mr_inconsistencia.plnclscod = null
            	 let mr_inconsistencia.srvcod    = null


               let mr_inconsistencia.mtvinc = 'Não localizado plano para essa clausula '
               call bdata007_grava_inconsistencia()
               let mr_count1.claus = mr_count1.claus + 1
               let mr_total.claus  = mr_total.claus + 1

               continue for
            end if
            
            #--------------------------------------------------------
            # Verifica Processo de Inativacao     
            #--------------------------------------------------------
            
            if bdata007_acessa_inativacao() then
               if bdata007_regra_anterior() then
                  call bdata007_carrega_inativacao()
               end if
            end if

            #display "Query 11"
            #--------------------------------------------------------
            # Recupera os Dados do Motor de Regras
            #--------------------------------------------------------

            open c_bdata007_012 using mr_processo2.plnclscod

            foreach c_bdata007_012 into mr_processo2.srvcod                 ,
                                        mr_processo2.srvplnclscod           ,
                                        mr_processo2.codcls                 ,
                                        mr_processo2.clsnom                 ,
                                        mr_processo2.clssitflg

                  let mr_count1.motor = mr_count1.motor + 1
                  let mr_total.motor  = mr_total.motor + 1


                  let mr_inconsistencia.srvcod = mr_processo2.srvcod



                  #display "Query 12"
                  #------------------------------------------------------
                  # Regra 2 - Verifica Se Tem Categoria
                  #------------------------------------------------------

                  open c_bdata007_015 using mr_processo2.srvplnclscod ,
                                            mr_processo2.ctgtrfcod

                  whenever error continue
                  fetch c_bdata007_015 into lr_retorno.cont
                  whenever error stop

                  if lr_retorno.cont = 0 then
                     let mr_inconsistencia.mtvinc = 'Categoria Tarifaria não cadastrada para o serviço'
                     call bdata007_grava_inconsistencia()
                     let mr_count1.categ = mr_count1.categ + 1
                     let mr_total.categ  = mr_total.categ + 1
                     continue foreach
                  end if

                  #display "Query 13"
                  #------------------------------------------------------
                  # Regra 3 - Verifica Se Tem Restricao por Classe
                  #------------------------------------------------------

                  open c_bdata007_016 using mr_processo2.srvplnclscod ,
                                            mr_processo2.clalclcod

                  whenever error continue
                  fetch c_bdata007_016 into mr_processo2.lclclartccod
                  whenever error stop

                  if sqlca.sqlcode <> notfound then

                       #display "Query 14"
                       #------------------------------------------------------
                       # Regra 4 - Verifica Se a Cidade tem Permissao
                       #------------------------------------------------------

                       open c_bdata007_017 using mr_processo2.lclclartccod ,
                                                 mr_processo2.endcid       ,
                                                 mr_processo2.endufd

                       whenever error continue
                       fetch c_bdata007_017 into lr_retorno.cont
                       whenever error stop

                       if lr_retorno.cont = 0 then
                          let mr_inconsistencia.mtvinc = 'Cidade não cadastrada para o serviço'
                          call bdata007_grava_inconsistencia()
                          let mr_count1.cidad = mr_count1.cidad + 1
                          let mr_total.cidad  = mr_total.cidad + 1
                          continue foreach
                       end if

                  end if

                  let l_data = today
                  let l_hora = current

                  let mr_processo2.data_atual = l_data , " " , l_hora
                  
                  
                  #------------------------------------------------------              
                  # Verifica Se o Beneficio Ja foi Carregado                                
                  #------------------------------------------------------              
                  
                  if bdata007_valida_beneficio_processado() then
                    	let mr_count1.proce = mr_count1.proce + 1
                  	  let mr_total.proce  = mr_total.proce + 1
							     	continue foreach
                  end if
                  
                  #------------------------------------------------------   
                  # Grava o Beneficio                                     
                  #------------------------------------------------------ 
                  
                  call bdata007_grava_beneficio()
                  returning m_gravou

                  if m_gravou then
                     let mr_count1.relat = mr_count1.relat + 1
                     let mr_total.relat  = mr_total.relat + 1
                     let lr_retorno.grava = true
                  end if
                  
                  
                  # contador
                  if m_commit > m_quebra then
                     commit work;
                     begin work;
                     let m_commit = 1
                  else
                      let m_commit = m_commit + 1
                  end if

            end foreach


            if lr_retorno.grava then
            	  call bdata007_atualiza_exportado()
            	  let lr_retorno.grava = false
            end if

      end for



    end foreach

    call bdata007_exibe_dados_parciais()

    commit work;

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_valida_geracao_claus(lr_param)
#========================================================================

define lr_param  record
   clscod  like abbmclaus.clscod
end record

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "claus_azul"

  open c_bdata007_032 using  lr_retorno.cponom,
                             lr_param.clscod

  whenever error continue
  fetch c_bdata007_032 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes = "S" then
     return true
  else
    return false
  end if

#========================================================================
end function
#========================================================================


#========================================================================
function bdata007_recupera_codigo_inicio_full()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_full_ini"
let lr_retorno.cpocod = 1


  open c_bdata007_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata007_020 into mr_param.azlaplcod_primeiro
  whenever error stop


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_recupera_codigo_ultimo_full()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_full_ult"
let lr_retorno.cpocod = 1


  open c_bdata007_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata007_020 into mr_param.azlaplcod_ultimo
  whenever error stop


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_recupera_codigo_inicio_diario()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_dia_ini"
let lr_retorno.cpocod = 1


  open c_bdata007_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata007_020 into mr_param.azlaplcod_primeiro
  whenever error stop


#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_recupera_codigo_ultimo_diario()
#========================================================================

  open c_bdata007_031
  whenever error continue
  fetch c_bdata007_031 into mr_param.azlaplcod_ultimo
  whenever error stop


#========================================================================
end function
#========================================================================

#========================================================================
function bdata001_monta_mensagem2(l_param)
#========================================================================

   define l_param    char(100)

   let m_msg_mail = m_msg_mail clipped, "<br>"
                    , l_param clipped

#========================================================================
end function
#========================================================================

#========================================================================
function bdata007_regra_anterior()
#========================================================================

define lr_retorno record
	cont integer
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0    

  #--------------------------------------------------------
  # Verifica se a Clausula Tem Regras Antigas
  #--------------------------------------------------------

  open c_bdata007_002 using   mr_processo2.empcod      ,
                              mr_processo2.ramcod      ,
                              mr_processo2.clscod      ,
                              mr_processo2.perfil      ,
                              mr_processo2.plnclscod   ,
                              mr_processo2.clsviginidat
  whenever error continue
  fetch c_bdata007_002 into   lr_retorno.cont                             
  whenever error stop
 
  if lr_retorno.cont > 0  then
     return true
  end if

  return false
#========================================================================
end function
#========================================================================

#======================================================================== 
function bdata007_carrega_inativacao()                                        
#======================================================================== 


define lr_retorno record
	cont integer
end record

initialize mr_processo3.* to null
initialize lr_retorno.* to null


    #--------------------------------------------------------                                                 
    # Recupera os Dados do Motor de Regras Antigo                                                                   
    #-------------------------------------------------------- 
    
    open c_bdata007_003 using mr_processo2.empcod      ,  
                              mr_processo2.ramcod      , 
                              mr_processo2.clscod      , 
                              mr_processo2.perfil      , 
                              mr_processo2.plnclscod   , 
                              mr_processo2.clsviginidat  
      
    foreach c_bdata007_003 into mr_processo3.plnclscod
                                                                                                                                                                    

         #-------------------------------------------------------- 
         # Recupera os Servicos de Cada Regra             
         #--------------------------------------------------------
         
         open c_bdata007_004 using mr_processo3.plnclscod                                                          
                                                                                                                   
         foreach c_bdata007_004 into mr_processo3.srvcod                 ,                                         
                                     mr_processo3.srvplnclscod           ,                                         
                                     mr_processo3.codcls                 ,                                         
                                     mr_processo3.clsnom                 ,                                         
                                     mr_processo3.clssitflg                                                        
                                                                                                                   
                                               
               let mr_inconsistencia.srvcod = mr_processo3.srvcod                                                  
                                                                                                                                                                                                                                                                                                                                                                                                                                   
               #------------------------------------------------------                                             
               # Verifica Se Tem Categoria                                                               
               #------------------------------------------------------                                             
                                                                                                                   
               open c_bdata007_015 using mr_processo3.srvplnclscod ,                                               
                                         mr_processo2.ctgtrfcod                                                    
                                                                                                                   
               whenever error continue                                                                             
               fetch c_bdata007_015 into lr_retorno.cont                                                           
               whenever error stop                                                                                 
                                                                                                                   
               if lr_retorno.cont = 0 then                                                                         
                  let mr_inconsistencia.mtvinc = 'Categoria Tarifaria não cadastrada para o serviço'               
                  call bdata007_grava_inconsistencia()                                                                                                            
                  continue foreach                                                                                 
               end if                                                                                              
                                                                                                                   
                                                                                            
               #------------------------------------------------------                                             
               # Verifica Se Tem Restricao por Classe                                                    
               #------------------------------------------------------                                             
                                                                                                                   
               open c_bdata007_016 using mr_processo3.srvplnclscod ,                                               
                                         mr_processo2.clalclcod                                                    
                                                                                                                   
               whenever error continue                                                                             
               fetch c_bdata007_016 into mr_processo3.lclclartccod                                                 
               whenever error stop                                                                                 
                                                                                                                   
               if sqlca.sqlcode <> notfound then                                                                   
                                                                                                                   
                                                                           
                    #------------------------------------------------------                                        
                    # Verifica Se a Cidade tem Permissao                                                 
                    #------------------------------------------------------                                        
                                                                                                                   
                    open c_bdata007_017 using mr_processo3.lclclartccod ,                                          
                                              mr_processo2.endcid       ,                                          
                                              mr_processo2.endufd                                                  
                                                                                                                   
                    whenever error continue                                                                        
                    fetch c_bdata007_017 into lr_retorno.cont                                                      
                    whenever error stop                                                                            
                                                                                                                   
                    if lr_retorno.cont = 0 then                                                                    
                       let mr_inconsistencia.mtvinc = 'Cidade não cadastrada para o serviço'                       
                       call bdata007_grava_inconsistencia()                                                                                                     
                       continue foreach                                                                            
                    end if                                                                                         
                                                                                                                   
               end if 
               
               
               #------------------------------------------------------                  
               # Verifica Se o Beneficio Ja foi Inativado                              
               #------------------------------------------------------                  
                                                                                        
               if bdata007_valida_beneficio_inativado() then                           
                 	let mr_count1.proce = mr_count1.proce + 1                            
               	  let mr_total.proce  = mr_total.proce + 1                             
                	continue foreach                                                       
               end if   
               
               
               #------------------------------------------------------                                                                    
               # Grava Inativo                                                                                                              
               #------------------------------------------------------                                                                                                                                                                                                                                                                
               
               call bdata007_grava_inativo()                                                                     
               returning m_inativou                                                                                  
                                                                                                          
               if m_inativou then                                                                                    
                  let mr_count1.inat = mr_count1.inat + 1                                                        
                  let mr_total.inat  = mr_total.inat  + 1                                                                                                                             
               end if                                                                                              
                                                                                                                   
                                                                         
         end foreach 
  
  end foreach 

#========================================================================  
end function
#========================================================================

#========================================================================
function bdata007_grava_inativo()
#========================================================================
define lr_retorno record
	status  char(30000)
end record

initialize lr_retorno.* to null

let mr_processo2.data_ger = today
let mr_processo3.pcmflg   = 'R'

   whenever error continue
   execute p_bdata007_029 using mr_processo2.empcod
                              , mr_processo2.codprod
                              , mr_processo2.codtipdoc
                              , mr_processo2.succod
                              , mr_processo2.ramcod
                              , mr_processo2.aplnumdig
                              , mr_processo2.prporgidv
                              , mr_processo2.prpnumidv
                              , mr_processo2.itmnumdig
                              , mr_processo2.pestip
                              , mr_processo2.cgccpfnum
                              , mr_processo2.cgcord
                              , mr_processo2.cgccpfdig
                              , mr_processo3.srvcod
                              , mr_processo2.viginc
                              , mr_processo2.vigfnl
                              , mr_processo2.data_ger
                              , mr_processo3.codcls
                              , mr_processo2.edsnumref
                              , mr_processo3.pcmflg
   whenever error continue

   if sqlca.sqlcode <> 0 then

      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DA INATIVACAO DOS BENEFICIOS! '
      let mr_inconsistencia.mtvinc = m_mensagem

      call bdata007_grava_inconsistencia()
      call ERRORLOG(m_mensagem);

      display m_mensagem
      let lr_retorno.status = false
   else
      let lr_retorno.status = true
   end if

   return lr_retorno.status

#========================================================================
end function
#========================================================================

#========================================================================
 function bdata007_valida_beneficio_processado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata007_005 using   mr_processo2.empcod   
                            , mr_processo2.codtipdoc
                            , mr_processo2.succod
                            , mr_processo2.ramcod
                            , mr_processo2.aplnumdig
                            , mr_processo2.itmnumdig
                            , mr_processo2.edsnumref
                            , mr_processo2.srvcod 
                            , mr_processo2.codcls                            
                          
                                      
  whenever error continue                                                   
  fetch c_bdata007_005 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#========================================================================

#========================================================================
 function bdata007_valida_beneficio_inativado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata007_006 using   mr_processo2.empcod   
                            , mr_processo2.codtipdoc
                            , mr_processo2.succod
                            , mr_processo2.ramcod
                            , mr_processo2.aplnumdig
                            , mr_processo2.itmnumdig
                            , mr_processo2.edsnumref
                            , mr_processo3.srvcod 
                            , mr_processo3.codcls                            
                          
                                      
  whenever error continue                                                   
  fetch c_bdata007_006 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#======================================================================== 

#========================================================================
function bdata007_acessa_inativacao()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata007_acessa"
let lr_retorno.cpocod = 1


  open c_bdata007_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata007_020 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes =  "S"  then
     return true
  end if
  
  return false
#========================================================================
end function
#========================================================================                                                                                                        