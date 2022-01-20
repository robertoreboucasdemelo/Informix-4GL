#--------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                                #
#................................................................................#
# Sistema........: Regras Siebel                                                 #
# Modulo.........: bdata012                                                      #
# Objetivo.......: Batch de Geracao de Propostas Retroativas Porto Auto          #
# Analista Resp. : R.Fornax                                                      #
# PSI            :                                                               #
#................................................................................#
# Desenvolvimento: R.Fornax                                                      #
# Liberacao      : 23/05/2016                                                    #
#--------------------------------------------------------------------------------#


database porto

globals
   define g_ismqconn smallint
end globals


define m_path_log        char(100)
define m_bdata012_prep   smallint
define m_mensagem        char(150)
define m_seq             integer
define m_commit          integer
define m_cont            integer
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
	  ini date                          ,
	  fim date                            ,
	  hour_ini datetime hour to second    ,
	  hour_fim datetime hour to second
end record


define mr_especialidade record
  srvespnum like datksrvesp.srvespnum ,
  srvespnom like datksrvesp.srvespnom ,
  regatldat like datksrvesp.regatldat
end record


define mr_processo1 record
  srvgrptipcod  like datksrvgrptip.srvgrptipcod ,
  srvgrptipnom  like datksrvgrptip.srvgrptipnom ,
  srvcod        like datksrv.srvcod             ,
  srvnom        like datksrv.srvnom             ,
  srvespcod     like datksrvgrpesp.srvespcod    ,
  srvespnom     like datksrvesp.srvespnom
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
  data_atual              char(20)                                 ,
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
  prporgpcp               like apamcapa.prporgpcp                  ,
  prpnumpcp               like apamcapa.prpnumpcp                  ,
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
  inicio     date ,
  fim        date ,
  validacao  date ,
  dias       integer  
end record




#========================================================================
main
#========================================================================

   # Funcao responsavel por preparar o programa para a execucao
   # - Prepara as instrucoes SQL
   # - Obtem os caminhos de processamento
   # - Cria o arquivo de log
   #

   initialize mr_count1.*, mr_param.* to null

   call bdata012_cria_log()

   call bdata012_exibe_inicio()

   call fun_dba_abre_banco("CT24HS")

   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata012_prep = false


   let mr_total.lidos      = 0
   let mr_total.motor      = 0
   let mr_total.relat      = 0
   let mr_total.inat       = 0   
   let mr_total.claus      = 0 
   let mr_total.proce      = 0   
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

   display "##################################"
   display " PREPARANDO... "
   display "##################################"
   call bdata012_prepare()

   
   display "##################################"
   display " RECUPERANDO QUEBRA... "
   display "##################################"
   if not bdata012_recupera_quebra() then
      exit program
   end if  


   if not bdata012_carga_full() then
      let m_mensagem = "Carga Full abortada. Verificar os dominios."
      call ERRORLOG(m_mensagem);
      display m_mensagem
   end if
     
  
   call bdata012_exibe_final()

   call bdata012_dispara_email()

#========================================================================
end main
#========================================================================

#===============================================================================
function bdata012_prepare()
#===============================================================================

define l_sql char(10000)

   let l_sql = ' select count(*)           '
             , '   from datkplncls         '
             , '  where empcod =  ?        '
             , '  and   ramcod =  ?        '
             , '  and   clscod =  ?        '
             , '  and   prfcod =  ?        '
             , '  and   plnclscod <>  ?    '     
             , '  and   clsvigfimdat <= ?  '           
   prepare p_bdata012_001 from l_sql
   declare c_bdata012_001 cursor for p_bdata012_001
   
   let l_sql = ' select count(*)        '
            ,  '  from datksrvesp       '
            ,  '  where srvespnum   = ? '
   prepare p_bdata012_002 from l_sql
   declare c_bdata012_002 cursor for p_bdata012_002
   	
   let l_sql = ' select plnclscod          '
             , '   from datkplncls         '
             , '  where empcod =  ?        '
             , '  and   ramcod =  ?        '
             , '  and   clscod =  ?        '
             , '  and   prfcod =  ?        '
             , '  and   plnclscod <>  ?    '     
             , '  and   clsvigfimdat <= ?  '           
   prepare p_bdata012_003 from l_sql
   declare c_bdata012_003 cursor for p_bdata012_003
   
   let l_sql =  '  select count(*)       '
               ,'  from datmbnfcrgico    '
               ,'  where empcod  = ?     '
               ,'  and dcttipcod = 888   '
               ,'  and idvprporgcod = ?  '
               ,'  and idvprpdignum = ?  '
               ,'  and incvigdat = ?     '       
   prepare p_bdata012_004 from l_sql
   declare c_bdata012_004 cursor with hold for p_bdata012_004            
               
              
   let l_sql = ' select  a.viginc    ,              '
               ,'        a.vigfnl    ,              '
               ,'        b.prporgpcp ,              '
               ,'        b.prpnumpcp ,              '
               ,'        b.prporgidv ,              '
               ,'        b.prpnumidv                '
               ,' from apamcapa a,                  '
               ,'      apbmitem  b                  '
               ,' where a.prporgpcp = b.prporgpcp   '
               ,'   and a.prpnumpcp = b.prpnumpcp   '
               ,'   and a.viginc = ?                '
               ,'   and a.aplnumdig is null         '
               ,' group by 1,2,3,4,5,6              '
               ,' order by 1,2,3,4,5,6              '
   prepare p_bdata012_005 from l_sql
   declare c_bdata012_005 cursor with hold for p_bdata012_005
   
   let l_sql = ' select min(dctnumseq) '
              ,' from abbmdoc          '
              ,' where succod    = ?	  '
              ,'   and aplnumdig = ?	  '
              ,'   and itmnumdig = ?	  '
   prepare p_bdata012_006 from l_sql
   declare c_bdata012_006 cursor with hold for p_bdata012_006
   
   let l_sql = ' select edsnumdig            '
              ,' from abamdoc                '
              ,' where abamdoc.succod    = ? '
              ,' and   abamdoc.aplnumdig = ? '
              ,' and   abamdoc.dctnumseq = ? '
   prepare p_bdata012_007 from l_sql
   declare c_bdata012_007 cursor with hold for p_bdata012_007
    
   let l_sql =  '  select segnumdig,    '
               ,'       clalclcod       '
               ,'  from  apbmitem       '
               ,'  where prporgpcp =  ? '
               ,'  and   prpnumpcp =  ? '
               ,'  and   prporgidv =  ? '
               ,'  and   prpnumidv =  ? '
   prepare p_bdata012_008 from l_sql
   declare c_bdata012_008 cursor for p_bdata012_008
   
   let l_sql =  ' select cbtcod    ,    '
               ,'        ctgtrfcod ,    '
               ,'        clcdat         '
               ,' from apbmcasco        '
               ,' where  prporgpcp =  ? '
               ,'  and   prpnumpcp =  ? '
               ,'  and   prporgidv =  ? '
               ,'  and   prpnumidv =  ? '
   
   prepare p_bdata012_009 from l_sql
   declare c_bdata012_009 cursor with hold for p_bdata012_009
   
   let l_sql =  ' select clscod       '
               ,' from apbmclaus      '
               ,' where  prporgpcp =  ? '
               ,'  and   prpnumpcp =  ? '
               ,'  and   prporgidv =  ? '
               ,'  and   prpnumidv =  ? '
   prepare p_bdata012_010 from l_sql
   declare c_bdata012_010 cursor with hold for p_bdata012_010
   
   let l_sql = ' select plnclscod,         '
             , '        clsviginidat       ' 
             , '   from datkplncls         '
             , '  where empcod =  ?        '
             , '  and   ramcod =  ?        '
             , '  and   clscod =  ?        '
             , '  and   prfcod =  ?        '
             , '  and   clsviginidat <=  ? '
             , '  and   clsvigfimdat >=  ? '
             , '  and   regsitflg = "A"    '
   prepare p_bdata012_011 from l_sql
   declare c_bdata012_011 cursor for p_bdata012_011
   
   let l_sql = ' select a.srvcod                 ,   '
              ,'        a.srvplnclscod           ,   '
              ,'        b.clscod                 ,   '
              ,'        b.clsnom                 ,   '
              ,'        b.clssitflg                  '
              ,' from datksrvplncls a,               '
              ,'      datkplncls b                   '
              ,' where b.plnclscod  = a.plnclscod    '
              ,' and   a.plnclscod  = ?              '
   prepare p_bdata012_012 from l_sql
   declare c_bdata012_012 cursor with hold for p_bdata012_012
   
   let l_sql = ' select empnom     '
              ,' from gabkemp      '
              ,' where empcod = ? 	'
   prepare p_bdata012_013 from l_sql
   declare c_bdata012_013 cursor for p_bdata012_013
   
   let l_sql = ' select count(*)         '
              ,' from datkcbtcss         '
              ,' where srvclscod   =  ?  '
              ,' and   cbtcod      =  ?  '
   prepare p_bdata012_014 from l_sql
   declare c_bdata012_014 cursor for p_bdata012_014
   
   let l_sql = ' select count(*)        '
              ,' from datktrfctgcss     '
              ,' where srvclscod   =  ? '
              ,' and   trfctgcod   =  ? '
   prepare p_bdata012_015 from l_sql
   declare c_bdata012_015 cursor for p_bdata012_015
   
   let l_sql = ' select lclclartccod       '
              ,' from datklclclartc        '
              ,' where srvclscod    =  ?   '
              ,' and   lclclacod    =  ?   '
   prepare p_bdata012_016 from l_sql
   declare c_bdata012_016 cursor for p_bdata012_016
   
   let l_sql = ' select count(*)             '
              ,' from datkrtcece a ,         '
              ,'      glakcid    b   	       '
              ,' where a.cidcod = b.cidcod   '
              ,' and   a.lclclartccod =  ?   '
              ,' and   b.cidnom   	  =  ?   '
              ,' and   b.ufdcod       =  ?   '
   prepare p_bdata012_017 from l_sql
   declare c_bdata012_017 cursor for p_bdata012_017
   
   let l_sql = ' select endcid ,      '
              ,'        endufd        '
              ,' from gsakend         '
              ,' where segnumdig =  ? '
              ,' and   endfld    =  1 '
   prepare p_bdata012_018 from l_sql
   declare c_bdata012_018 cursor for p_bdata012_018
   
   let l_sql =  ' update datkplncls     '
             ,  ' set irdclsflg = "S"   '
             ,  ' where plnclscod = ?   '
   prepare p_bdata012_019 from l_sql
   
   let l_sql = ' select cpodes        '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
              ,' and   cpocod =  ?    '
   prepare p_bdata012_020 from l_sql
   declare c_bdata012_020 cursor for p_bdata012_020
   
   let l_sql =  ' update datkdominio    '
              , ' set   cpodes =  ?     '
              , ' where cponom =  ?     '
              , ' and   cpocod =  ?     '
   prepare p_bdata012_021 from l_sql
   
   let l_sql = 'select nscdat,        ',
               '       segsex,        ',
               '       pestip,        ',
               '       cgccpfnum,     ',
               '       cgcord   ,     ',
               '       cgccpfdig      ',
               ' from gsakseg         ',
               ' where segnumdig  = ? '
   prepare p_bdata012_022 from l_sql
   declare c_bdata012_022 cursor for p_bdata012_022
   
   let l_sql = ' select vcluso      '
    				   ,' from apbmveic      '
              ,' where  prporgpcp =  ? '
      				 ,'  and   prpnumpcp =  ? '
      				 ,'  and   prporgidv =  ? '
       	  	 ,'  and   prpnumidv =  ? '
   prepare p_bdata012_023 from l_sql
   declare c_bdata012_023 cursor for p_bdata012_023
   
   let l_sql = 'select imsvlr        '
    				   ,' from abbmcasco      '
              ,' where succod    = ? '
      				 ,'   and aplnumdig = ? '
      				 ,'   and itmnumdig = ? '
       	  	 ,'   and dctnumseq = ? '
   prepare p_bdata012_024 from l_sql
   declare c_bdata012_024 cursor for p_bdata012_024
   
   let l_sql = 'select rspdat           '
    				   ,' from apbmquestionario  '
              ,' where  prporgpcp =  ? '
      				 ,'  and   prpnumpcp =  ? '
      				 ,'  and   prporgidv =  ? '
       	  	 ,'  and   prpnumidv =  ? '
       	  	 ,'   and qstcod    = 2    '
   prepare p_bdata012_025 from l_sql
   declare c_bdata012_025 cursor for p_bdata012_025
   
   let l_sql = 'select rspcod           '
    				   ,' from apbmquestionario  '
              ,' where  prporgpcp =  ? '
      				 ,'  and   prpnumpcp =  ? '
      				 ,'  and   prporgidv =  ? '
       	  	 ,'  and   prpnumidv =  ? '
       	  	 ,'   and qstcod    = 120  '
   prepare p_bdata012_026 from l_sql
   declare c_bdata012_026 cursor for p_bdata012_026
   
   let l_sql = ' select cpodes        '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
   prepare p_bdata012_027 from l_sql
   declare c_bdata012_027 cursor for p_bdata012_027
   
   let l_sql = ' select count(*)        '
               ,' from datkdominio     '
               ,' where cponom =  ?    '
   prepare p_bdata012_028 from l_sql
   declare c_bdata012_028 cursor for p_bdata012_028
   
   let l_sql = " insert into datmbnfcrgmov             "
              ," (                                     "
              ,"   empcod,prdcod,dcttipcod             "
              ,"  ,succod,ramcod,apldignum             "
              ,"  ,idvprporgcod,idvprpdignum           "
              ,"  ,itmdignum,pestipcod                 "
              ,"  ,cpjcpfnum,cpjordnum,cpjcpfdignum    "
              ,"  ,pctcod,incvigdat,fnlvigdat          "
              ,"  ,bnfgrcdat,dctclscod                 "
              ,"  ,dctedsnum,pcmflg )                  "
              ," values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,? "
              ,"  ,?,?,?,?,?)                          "
   prepare p_bdata012_029 from l_sql
   
   let l_sql = ' insert into datmbnfcrgico             '
              ,'( empcod,dcttipcod,succod               '
              ,' ,ramcod,apldignum,itmdignum            '
              ,' ,dctseqnum,idvprporgcod                '
              ,' ,idvprpdignum,pcpprporgcod             '
              ,' ,pcpprpdignum,dctemsdat                '
              ,' ,incvigdat,fnlvigdat                   '
              ,' ,cpjcpfnum,cpjordnum                   '
              ,' ,cpjcpfdignum,dctclscod                '
              ,' ,dctclsclcdat,pestipcod                '
              ,' ,segnscdat,pcpcdtnscdat                '
              ,' ,pcpcdtsexcod,pcpcdtiddnum             '
              ,' ,segprfcod,clsplncod                   '
              ,' ,dctsrvcod,cbtcod                      '
              ,' ,ctgcod,lclclacod                      '
              ,' ,segcidnom,segestsglnom                '
              ,' ,icomtvdes,icodat)                     '
              ,' values (?,?,?,?,?,?,?,?,?,?,?,?,?,?    '
              ,'  ,?,?,?,?,?,?,?,?,?,?,?,?,?            '
              ,'  ,?,?,?,?,?,?,?  )                     '
   prepare p_bdata012_030 from l_sql
   
    let l_sql = ' select cpodes[8,12]     '  
              ,' from datkdominio        '             
              ,' where cponom =  ?       '                
              ,' and   cpodes[1,2] =  ?  '
              ,' and   cpodes[4,6] =  ?  '             
   prepare p_bdata012_031  from l_sql                
   declare c_bdata012_031  cursor for p_bdata012_031
   	
   let l_sql = ' select count(*)          '
              ,' from datmbnfcrgico       '
              ,' where empcod =  ?        '
              ,' and   dcttipcod =  ?     '
              ,' and   idvprporgcod =  ?  '
              ,' and   idvprpdignum =  ?  ' 
              ,' and   pcpprporgcod =  ?  '
              ,' and   pcpprpdignum =  ?  '
              ,' and   incvigdat    =  ?  '              
   prepare p_bdata012_032 from l_sql
   declare c_bdata012_032 cursor for p_bdata012_032
   	
   let l_sql = ' select count(*)         '
              ,' from datmbnfcrgmov      '
              ,' where empcod =  ?       '
              ,' and   dcttipcod =  ?    '
              ,' and   idvprporgcod =  ? '
              ,' and   idvprpdignum =  ? ' 
              ,' and   pctcod       =  ? '
              ,' and   dctclscod    =  ? '
              ,' and   pcmflg in ("S","N") '                                   
   prepare p_bdata012_033 from l_sql
   declare c_bdata012_033 cursor for p_bdata012_033 	
   	
   let l_sql = ' select count(*)         '
              ,' from datmbnfcrgmov      '
              ,' where empcod =  ?       '
              ,' and   dcttipcod =  ?    '
              ,' and   idvprporgcod =  ? '
              ,' and   idvprpdignum =  ? ' 
              ,' and   pctcod       =  ? '
              ,' and   dctclscod    =  ? '
              ,' and   pcmflg in ("R","E") '                                   
   prepare p_bdata012_034 from l_sql
   declare c_bdata012_034 cursor for p_bdata012_034 	 	 	
   
   
   let m_bdata012_prep = true

#========================================================================
end function
#========================================================================

#========================================================================
function bdata012_cria_log()
#========================================================================

   define l_path char(200)

   let l_path = null
   let l_path = f_path("DAT","LOG")

   if l_path is null or
      l_path = " " then
      let l_path = "."
   end if

   let l_path = m_path_log clipped, "bdata012.log"

   call startlog(l_path)

#========================================================================
end function
#========================================================================


#========================================================================
function bdata012_carrega_beneficio()
#========================================================================

define lr_retorno record
	 cont          integer  ,
	 grava         smallint ,
	 aplnumdig_ant like abbmdoc.aplnumdig,
	 prporgpcp_ant like apbmitem.prporgpcp,
	 prpnumpcp_ant like apbmitem.prpnumidv,
	 prporgidv_ant like apbmitem.prporgidv,
	 prpnumidv_ant like apbmitem.prpnumidv
end record

define l_data date
define l_hora datetime hour to second

initialize mr_processo2.* to null
initialize mr_processo3.* to null
initialize mr_inconsistencia.* to null

let l_data = null
let l_hora = null

let mr_processo2.empcod       = 1
let mr_processo2.ramcod       = 531
let mr_processo2.codprod      = 01
let mr_processo2.codtipdoc    = 2
let mr_processo2.pcmflg       = 'S'
let mr_processo2.edsnumref    = 0
let lr_retorno.cont           = 0
let lr_retorno.grava          = false
let lr_retorno.aplnumdig_ant  = 0
let lr_retorno.prporgpcp_ant  = 0
let lr_retorno.prpnumpcp_ant  = 0
let lr_retorno.prporgidv_ant  = 0
let lr_retorno.prpnumidv_ant  = 0
let mr_count1.lidos           = 0
let mr_count1.motor           = 0
let mr_count1.relat           = 0
let mr_count1.inat            = 0
let mr_count1.proce           = 0   
let mr_count1.claus           = 0
let mr_count1.cober           = 0
let mr_count1.categ           = 0
let mr_count1.cidad           = 0
let mr_count1.apoli           = 0
let mr_count1.cpf             = 0
let mr_count1.claus2          = 0
let mr_count1.des_clau        = 0
let mr_inconsistencia.empcod    = 1
let mr_inconsistencia.doctipcod = 1
let mr_inconsistencia.dtger     = today

     begin work;



    #--------------------------------------------------------
    # Recupera o Nome da Empresa
    #--------------------------------------------------------

     open c_bdata012_013 using mr_processo2.empcod

     whenever error continue
     fetch c_bdata012_013 into mr_processo2.empnom
     whenever error stop

    #--------------------------------------------------------
    # Recupera os Dados da proposta
    #--------------------------------------------------------

    open c_bdata012_005 using mr_data.fim   
                    
    foreach c_bdata012_005 into mr_processo2.viginc
    	                        , mr_processo2.vigfnl
  	                          , mr_processo2.prporgpcp
                              , mr_processo2.prpnumpcp
                              , mr_processo2.prporgidv
                              , mr_processo2.prpnumidv

			 
			 if bdata012_ja_carregado() then
			 	  continue foreach
			 end if
    
       let mr_inconsistencia.emsdat    = mr_processo2.viginc
       let mr_inconsistencia.viginc    = mr_processo2.viginc
       let mr_inconsistencia.vigfnl    = mr_processo2.vigfnl
       let mr_inconsistencia.succod    = mr_processo2.succod
       let mr_inconsistencia.aplnumdig = mr_processo2.aplnumdig
       let mr_inconsistencia.itmnumdig = mr_processo2.itmnumdig
       let mr_inconsistencia.prporgidv = mr_processo2.prporgidv
       let mr_inconsistencia.prpnumidv = mr_processo2.prpnumidv
       let mr_count1.apoli = mr_count1.apoli + 1
       let mr_total.apoli  = mr_total.apoli + 1
       
        #------------------------------------------------------  
        # Grava Apolice Processada                               
        #------------------------------------------------------  
        call bdata012_grava_apolice_processada()          


        #------------------------------------------------------
        # Recupera Numero do Segurado e Classe de Localizacao
        #------------------------------------------------------




        open c_bdata012_008 using mr_processo2.prporgpcp ,
                                  mr_processo2.prpnumpcp ,
                                  mr_processo2.prporgidv ,
                                  mr_processo2.prpnumidv
        whenever error continue
        fetch c_bdata012_008 into mr_processo2.segnumdig ,
                                  mr_processo2.clalclcod
        whenever error stop
        let mr_inconsistencia.clalclcod = mr_processo2.clalclcod
        #------------------------------------------------------
        # Recupera Cidade do Segurado
        #------------------------------------------------------

        open c_bdata012_018 using mr_processo2.segnumdig

        whenever error continue
        fetch c_bdata012_018 into mr_processo2.endcid ,
                                  mr_processo2.endufd
        whenever error stop
        let mr_inconsistencia.endcid = mr_processo2.endcid
        let mr_inconsistencia.endufd = mr_processo2.endufd
        #------------------------------------------------------
        # Recupera Cobertura, Categoria e Data de Calculo
        #------------------------------------------------------

        open c_bdata012_009 using mr_processo2.prporgpcp ,
                                  mr_processo2.prpnumpcp ,
                                  mr_processo2.prporgidv ,
                                  mr_processo2.prpnumpcp
        whenever error continue
        fetch c_bdata012_009 into mr_processo2.cbtcod    ,
                                  mr_processo2.ctgtrfcod ,
                                  mr_processo2.clcdat
        whenever error stop
        let mr_inconsistencia.cbtcod =  mr_processo2.cbtcod
        let mr_inconsistencia.ctgtrfcod = mr_processo2.ctgtrfcod
        let mr_inconsistencia.clcdat = mr_processo2.clcdat
        #-----------------------------------------------------------
        # Recupera os Dados do Segurado
        #-----------------------------------------------------------

        open c_bdata012_022 using mr_processo2.segnumdig

        whenever error continue
        fetch c_bdata012_022 into mr_processo2.nscdat     ,
                                  mr_processo2.segsex     ,
                                  mr_processo2.pestip     ,
                                  mr_processo2.cgccpfnum  ,
                                  mr_processo2.cgcord     ,
                                  mr_processo2.cgccpfdig
        whenever error stop

        close c_bdata012_022
        if mr_processo2.pestip <> "F"  or
           mr_processo2.pestip <> "J"  or
           mr_processo2.pestip is null then
           if mr_processo2.cgcord = 0 or
              mr_processo2.cgcord is null then
              let mr_processo2.pestip = 'F'
           else
              let mr_processo2.pestip = 'J'
           end if
        end if
        
        if mr_processo2.cgcord is null then
           if mr_processo2.pestip = 'F' then
              let mr_processo2.cgcord = 0
           end if
        end if 
        
        let mr_inconsistencia.cgccpfnum  = mr_processo2.cgccpfnum
        let mr_inconsistencia.cgcord     = mr_processo2.cgcord
        let mr_inconsistencia.cgccpfdig  = mr_processo2.cgccpfdig
        let mr_inconsistencia.pestip     = mr_processo2.pestip
        let mr_inconsistencia.nscdat     = mr_processo2.nscdat

        if mr_processo2.cgccpfnum is null then
           let mr_inconsistencia.mtvinc = 'CPF/CNPJ não localizado na tabela gsakseg'
           call bdata012_grava_inconsistencia()
           let mr_count1.cpf = mr_count1.cpf + 1
           let mr_total.cpf  = mr_total.cpf + 1
           continue foreach
        end if


        #-----------------------------------------------------------
        # Recupera Se o Veiculo e 0KM
        #-----------------------------------------------------------

        open c_bdata012_023  using mr_processo2.prporgpcp ,
                                   mr_processo2.prpnumpcp ,
                                   mr_processo2.prporgidv ,
                                   mr_processo2.prpnumidv
        whenever error continue
        fetch c_bdata012_023 into mr_processo2.vcluso

        whenever error stop

        close c_bdata012_023


        #-----------------------------------------------------------
        # Recupera a Importancia Segurada
        #-----------------------------------------------------------

        open c_bdata012_024  using mr_processo2.succod    ,
                                   mr_processo2.aplnumdig ,
                                   mr_processo2.itmnumdig ,
                                   mr_funapol.autsitatu
        whenever error continue
        fetch c_bdata012_024 into mr_processo2.imsvlr

        whenever error stop


        close c_bdata012_024
        
        #-----------------------------------------------------------
        # Recupera a Data de Nascimento do Principal Condutor
        #-----------------------------------------------------------

        open c_bdata012_025 using mr_processo2.prporgpcp ,
                                  mr_processo2.prpnumpcp ,
                                  mr_processo2.prporgidv ,
                                  mr_processo2.prpnumidv
        whenever error continue
        fetch c_bdata012_025 into mr_processo2.rspdat

        whenever error stop

        let mr_inconsistencia.rspdat =  mr_processo2.rspdat

        close c_bdata012_025

        #-----------------------------------------------------------
        # Recupera o Sexo do Principal Condutor
        #-----------------------------------------------------------

        open c_bdata012_026  using mr_processo2.prporgpcp ,
                                   mr_processo2.prpnumpcp ,
                                   mr_processo2.prporgidv ,
                                   mr_processo2.prpnumidv
        whenever error continue
        fetch c_bdata012_026  into mr_processo2.rspcod

        whenever error stop


        close c_bdata012_026

        let mr_inconsistencia.rspcod =  mr_processo2.rspcod


        #--------------------------------------------------------
        # Recupera os Dados da Clausula
        #--------------------------------------------------------


        open c_bdata012_010 using mr_processo2.prporgpcp ,
                                  mr_processo2.prpnumpcp ,
                                  mr_processo2.prporgidv ,
                                  mr_processo2.prpnumidv

        foreach c_bdata012_010 into mr_processo2.clscod

        	   let mr_count1.lidos = mr_count1.lidos + 1
        	   let mr_total.lidos  = mr_total.lidos + 1

        	   if ( mr_processo2.prporgpcp <> lr_retorno.prporgpcp_ant and
        	        mr_processo2.prpnumpcp <> lr_retorno.prpnumpcp_ant) and
        	       ( mr_processo2.prporgidv <> lr_retorno.prporgidv_ant and
        	         mr_processo2.prpnumpcp <> lr_retorno.prpnumpcp_ant) then

        	   	  let mr_count1.claus2 = mr_count1.claus2 + 1
        	      let mr_total.claus2  = mr_total.claus2 + 1
        	   end if

        	   let lr_retorno.prporgpcp_ant = mr_processo2.prporgpcp
        	   let lr_retorno.prpnumpcp_ant = mr_processo2.prpnumpcp
        	   let lr_retorno.prporgidv_ant = mr_processo2.prporgidv
        	   let lr_retorno.prpnumidv_ant = mr_processo2.prpnumidv

        	   #--------------------------------------------------------
        	   # Verifica Clausula Duplicada
        	   #--------------------------------------------------------

        	   if mr_processo2.clscod = "034" or
        	      mr_processo2.clscod = "071" or
        	      mr_processo2.clscod = "077" then
        	      	if cta13m00_verifica_clausula(mr_processo2.succod     ,
                                                mr_processo2.aplnumdig  ,
                                                mr_processo2.itmnumdig  ,
                                                mr_funapol.dctnumseq    ,
                                                mr_processo2.clscod     ) then
     								 let mr_inconsistencia.mtvinc = 'Clausula de socorro Duplicada'
     								 call bdata012_grava_inconsistencia()
     								 continue foreach
  							  end if
        	   end if
        	   if not bdata012_valida_geracao_claus(mr_processo2.clscod) then
        	      let m_mensagem = "Clausula ",mr_processo2.clscod, " Não está cadastrado no dominio "
        	      call errorlog(m_mensagem)
        	      continue foreach
        	   end if

        	   call bdata012_calcula_perfil(mr_processo2.nscdat    ,
                                          mr_processo2.segsex    ,
                                          mr_processo2.pestip    ,
                                          mr_processo2.viginc    ,
                                          mr_processo2.vcluso    ,
                                          mr_processo2.rspdat    ,
                                          mr_processo2.rspcod    ,
                                          mr_processo2.clscod    , 
                                          mr_processo2.ctgtrfcod ,                                           
                                          mr_processo2.imsvlr    ,                                           
                                          mr_processo2.clcdat    )
             returning mr_processo2.perfil

             #--------------------------------------------------------
             # Regra 1 - Verifica se a Clausula Existe no Motor
             #--------------------------------------------------------
             open c_bdata012_011 using   mr_processo2.empcod ,
                                         mr_processo2.ramcod ,
                                         mr_processo2.clscod ,
                                         mr_processo2.perfil ,
                                         mr_processo2.clcdat ,
                                         mr_processo2.clcdat
             whenever error continue
             fetch c_bdata012_011 into   mr_processo2.plnclscod,
                                         mr_processo2.clsviginidat
             whenever error stop
             
             let mr_inconsistencia.clscod    = mr_processo2.clscod
             let mr_inconsistencia.perfil    = mr_processo2.perfil
             let mr_inconsistencia.plnclscod = mr_processo2.plnclscod
             let mr_inconsistencia.clcdat    = mr_processo2.clcdat
             
             if sqlca.sqlcode = notfound  then

                if   mr_processo2.clscod = '033' or
                     mr_processo2.clscod = '034' or
                     mr_processo2.clscod = '035' or
                     mr_processo2.clscod = '044' or
                     mr_processo2.clscod = '046' or
                     mr_processo2.clscod = '047' or
                     mr_processo2.clscod = '048' or
                     mr_processo2.clscod = '34R' or
                     mr_processo2.clscod = '33R' or
                     mr_processo2.clscod = '35R' or
                     mr_processo2.clscod = '44R' or
                     mr_processo2.clscod = '46R' or
                     mr_processo2.clscod = '48R' then
                     let m_mensagem = "Empresa.......: ", mr_processo2.empcod
                     call errorlog(m_mensagem)
                   
                     let m_mensagem ="Ramo..........: ", mr_processo2.ramcod
                     call errorlog(m_mensagem)
                    
                     let m_mensagem ="Clausula......: ", mr_processo2.clscod
                     call errorlog(m_mensagem)
                    
                     let m_mensagem ="Perfil........: ", mr_processo2.perfil
                     call errorlog(m_mensagem)
                     
                     let m_mensagem ="Data Clausula.: ", mr_processo2.clcdat
                     call errorlog(m_mensagem)
                     
                     let m_mensagem ="Origem......: ", mr_processo2.prporgidv
                     call errorlog(m_mensagem)
                     
                     let m_mensagem ="Prosposta.......: ", mr_processo2.prpnumidv
                     call errorlog(m_mensagem)
                    
               end if

                  let mr_inconsistencia.mtvinc = 'Não localizado plano para essa clausula '
                  call bdata012_grava_inconsistencia()


                  let mr_count1.claus = mr_count1.claus + 1
                  let mr_total.claus  = mr_total.claus + 1

                  continue foreach
             end if
             
             #--------------------------------------------------------
             # Verifica Processo de Inativacao     
             #--------------------------------------------------------
            
             if bdata012_acessa_inativacao() then
                if bdata012_regra_anterior() then   
                   call bdata012_carrega_inativacao()
                end if
             end if


             #--------------------------------------------------------
             # Recupera os Dados do Motor de Regras
             #--------------------------------------------------------

             open c_bdata012_012 using mr_processo2.plnclscod

             foreach c_bdata012_012 into mr_processo2.srvcod                 ,
                                         mr_processo2.srvplnclscod           ,
                                         mr_processo2.codcls                 ,
                                         mr_processo2.clsnom                 ,
                                         mr_processo2.clssitflg


                   let mr_count1.motor = mr_count1.motor + 1
                   let mr_total.motor  = mr_total.motor + 1

                   #------------------------------------------------------
                   # Regra 2 - Verifica Se Tem Cobertura
                   #------------------------------------------------------

                   let mr_inconsistencia.srvcod = mr_processo2.srvcod
                   open c_bdata012_014 using mr_processo2.srvplnclscod ,
                                             mr_processo2.cbtcod

                   whenever error continue
                   fetch c_bdata012_014 into lr_retorno.cont
                   whenever error stop

                   if lr_retorno.cont = 0 then
                      let mr_inconsistencia.mtvinc = 'Cobertura não cadastrado no plano'
                      call bdata012_grava_inconsistencia()
                      let mr_count1.cober = mr_count1.cober + 1
                      let mr_total.cober  = mr_total.cober + 1
                      continue foreach
                   end if



                   #------------------------------------------------------
                   # Regra 3 - Verifica Se Tem Categoria
                   #------------------------------------------------------

                   open c_bdata012_015 using mr_processo2.srvplnclscod ,
                                             mr_processo2.ctgtrfcod

                   whenever error continue
                   fetch c_bdata012_015 into lr_retorno.cont
                   whenever error stop

                   if lr_retorno.cont = 0 then
                      let mr_inconsistencia.mtvinc = 'Categoria Tarifaria não cadastrada para o serviço'
                      call bdata012_grava_inconsistencia()
                      let mr_count1.categ = mr_count1.categ + 1
                      let mr_total.categ  = mr_total.categ + 1
                      continue foreach
                   end if


                   #------------------------------------------------------
                   # Regra 4 - Verifica Se Tem Restricao por Classe
                   #------------------------------------------------------

                   open c_bdata012_016 using mr_processo2.srvplnclscod ,
                                             mr_processo2.clalclcod

                   whenever error continue
                   fetch c_bdata012_016 into mr_processo2.lclclartccod
                   whenever error stop

                   if sqlca.sqlcode <> notfound then


                        #------------------------------------------------------
                        # Regra 5 - Verifica Se a Cidade tem Permissao
                        #------------------------------------------------------

                        open c_bdata012_017 using mr_processo2.lclclartccod ,
                                                  mr_processo2.endcid       ,
                                                  mr_processo2.endufd

                        whenever error continue
                        fetch c_bdata012_017 into lr_retorno.cont
                        whenever error stop

                        if lr_retorno.cont = 0 then
                           let mr_inconsistencia.mtvinc = 'Cidade não cadastrada para o serviço'
                           call bdata012_grava_inconsistencia()
                           let mr_count1.cidad = mr_count1.cidad + 1
                           let mr_total.cidad  = mr_total.cidad + 1
                           continue foreach
                        end if

                   end if

                   if mr_processo2.itmnumdig is null then
                     let mr_processo2.itmnumdig = 0
                   end if


                   let l_data = today
                   let l_hora = current

                   let mr_processo2.data_atual = l_data , " " , l_hora
                   
                   #------------------------------------------------------              
                   # Verifica Se o Beneficio Ja foi Carregado                                
                   #------------------------------------------------------              
                   
                   if bdata012_valida_beneficio_processado() then
                     	let mr_count1.proce = mr_count1.proce + 1
                   	  let mr_total.proce  = mr_total.proce + 1
							      	continue foreach
                   end if  
                   
                   #------------------------------------------------------
                   # Grava o Beneficio                                    
                   #------------------------------------------------------
                 
                   call bdata012_grava_beneficio()
                   returning m_gravou
                    
                   if m_gravou then
                      let mr_count1.relat = mr_count1.relat + 1
                      let mr_total.relat  = mr_total.relat + 1
                      let lr_retorno.grava = true
                   end if
                   if m_commit > m_quebra then
                      commit work;
                      begin work;
                      let m_commit = 1
                   else
                       let m_commit = m_commit + 1
                   end if
                    
             end foreach
             
        end foreach



    end foreach

    call bdata012_exibe_dados_parciais()

    commit work;

#========================================================================
end function
#========================================================================

#========================================================================
function bdata012_exibe_inicio()
#========================================================================
define l_data  date,
       l_hora  datetime hour to second

let l_data            = today
let l_hora            = current
let mr_param.ini      = today
let mr_param.hour_ini = current

   display " "
   display "-----------------------------------------------------------"
   display " INICIO bdata012 - CARGA DE PROPOSTA PARA BASE DE BENEFICIO"
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
function bdata012_exibe_final()
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
function bdata012_valida_geracao_claus(lr_param)
#========================================================================

define lr_param  record
       clscod  like abbmclaus.clscod
end record
define l_count integer
define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null
let lr_retorno.cponom = "bdata004_claus"
let l_count = 0
  open c_bdata012_028 using  lr_retorno.cponom
  whenever error continue
  fetch c_bdata012_028 into l_count
  whenever error stop
  if l_count > 0 then
     open c_bdata012_027 using  lr_retorno.cponom
     whenever error continue
     foreach c_bdata012_027 into lr_retorno.cpodes
     whenever error stop
        if lr_retorno.cpodes =  lr_param.clscod  then
           exit foreach
        end if
     end foreach
  else
    return true
  end if
  if lr_retorno.cpodes =  lr_param.clscod  then
     return true
  end if
  return false


#========================================================================
end function
#========================================================================

#========================================================================
function bdata012_recupera_dias()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata004_retro"
let lr_retorno.cpocod = 1


  open c_bdata012_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata012_020 into lr_retorno.cpodes
  whenever error stop
 
  if lr_retorno.cpodes is not null  then
     let mr_data.dias =  lr_retorno.cpodes
  end if
  

#========================================================================
end function
#========================================================================

#========================================================================
function bdata012_recupera_data_validacao()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata012_data"
let lr_retorno.cpocod = 1


  open c_bdata012_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata012_020 into lr_retorno.cpodes
  whenever error stop
 
  if lr_retorno.cpodes is not null  then
     let mr_data.validacao =  lr_retorno.cpodes
  else
  	 let mr_data.validacao = today - 365
  end if
  

#========================================================================
end function
#========================================================================


#========================================================================
function bdata012_recupera_data_inicio()
#========================================================================

  call bdata012_recupera_dias()
  
  if mr_data.dias is null or
  	 mr_data.dias = ""    then
  	 	 let mr_data.inicio = today - 365
  else
  	   let mr_data.inicio = today - mr_data.dias
  end if 

#========================================================================
end function
#========================================================================


#========================================================================
function bdata012_recupera_data_fim()
#========================================================================

   let mr_data.fim =  today - 1
   
#========================================================================
end function
#========================================================================


#========================================================================
function bdata012_carga_full()
#========================================================================
   display "##################################"
   display " CARREGANDO PROPOSTAS FULL... "
   display "##################################"

   initialize mr_data.* to null
   call bdata012_recupera_data_inicio()
   call bdata012_recupera_data_fim() 
   call bdata012_recupera_data_validacao() 
        
  
   
   let m_mensagem = " CARGA PROPOSTAS FULL...............: ", mr_data.inicio, " - ", mr_data.fim
   call bdata012_monta_mensagem2(m_mensagem)
  
   while mr_data.inicio <= mr_data.fim
   	
   	  if mr_data.fim < mr_data.validacao then   	 
      	 let mr_data.fim = mr_data.fim - 1 units day  
      	 continue while
      end if
   	
      display ""
      display "======================================="
      display "PROCESSANDO DATA...", mr_data.fim
      display "======================================="

      call bdata012_carrega_beneficio()
         
      let mr_data.fim = mr_data.fim - 1 units day
      
      if not bdata012_valida_dia_hora() then
         exit while
      end if
      
     
   end while
   
   call bdata012_exibe_dados_totais()
   
   return true

#========================================================================
end function
#========================================================================





#========================================================================
function bdata012_calcula_perfil(lr_param)
#========================================================================

define lr_param record
  nscdat    like gsakseg.nscdat          ,
  segsex    like gsakseg.segsex          ,
  pestip    like gsakseg.pestip          ,
  viginc    like abamapol.viginc         ,
  vcluso    like abbmveic.vcluso         ,
  rspdat    like abbmquestionario.rspdat ,
  rspcod    like abbmquestionario.rspcod ,
  clscod    like abbmclaus.clscod        ,
  ctgtrfcod like abbmcasco.ctgtrfcod     ,
  imsvlr    like abbmcasco.imsvlr        , 
  dt_cal    date
end record

define lr_retorno record
  idade  integer  ,
  perfil smallint ,
  dias   dec(10,2)
end record

#-----------------------------------------------------------     
# Segmento 0 = Sem Perfil                                        
# Segmento 1 = Tradicional (25 a 59 anos)                        
# Segmento 2 = Jovem (Menor de 25 anos)                          
# Segmento 3 = Senior ( Maior de 59 anos)                        
# Segmento 4 = Mulher (Sexo: F)                                  
# Segmento 5 = Taxi                                              
# Segmento 6 = Caminhao                                          
# Segmento 7 = Moto                                              
# Segmento 8 = Auto Premium                                      
# Segmento 9 = Juridica                                          
#-----------------------------------------------------------     

initialize lr_retorno.* to null

  if lr_param.dt_cal < '01/02/2014' then
       let lr_retorno.perfil = 0
       return lr_retorno.perfil
  end if
 

   let lr_retorno.dias   = 365.25

   #--------------#
   # Tradicional  #
   #--------------#

   let lr_retorno.perfil = 1

   let lr_retorno.idade = ((lr_param.viginc - lr_param.rspdat)/lr_retorno.dias)
   let mr_inconsistencia.idade = lr_retorno.idade
   
   #------------------------------#                              
   # Valida se o Segmento e Moto  #                             
   #------------------------------#                              
                                                                
   if bdata012_valida_segmento_moto(lr_param.ctgtrfcod) then    
      let lr_retorno.perfil = 7                                 
                                                                
      return lr_retorno.perfil                                  
   end if 
   
   #------------------------------#
   # Valida se o Segmento e Taxi  #
   #------------------------------#

   if bdata012_valida_segmento_taxi(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 5

      return lr_retorno.perfil
   end if


   #----------------------------------#
   # Valida se o Segmento e Caminhao  #
   #----------------------------------#

   if bdata012_valida_segmento_caminhao(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 6

      return lr_retorno.perfil
   end if

   #----------------------------------#
   # Valida se o Segmento e Premium   #
   #----------------------------------#

   #if bdata012_valida_segmento_premium(lr_retorno.idade,
   #	                                   lr_param.imsvlr ) then
   #   let lr_retorno.perfil = 8
   #
   #   return lr_retorno.perfil
   #end if                                                      
   
   if lr_param.pestip = "F" then
      
         #----------------------------------#
      	 # Valida se o Segmento e Mulher    #
      	 #----------------------------------#

      	 if bdata012_valida_segmento_mulher(lr_retorno.idade,
      	 	                                  lr_param.rspcod ) then
      	    let lr_retorno.perfil = 4

      	    return lr_retorno.perfil
      	 end if


      	 #----------------------------------#
      	 # Valida se o Segmento e Jovem     #
      	 #----------------------------------#

      	 if bdata012_valida_segmento_jovem(lr_retorno.idade) then
      	    let lr_retorno.perfil = 2

      	    return lr_retorno.perfil
      	 end if


      	 #----------------------------------#
      	 # Valida se o Segmento e Senior    #
      	 #----------------------------------#

      	 if bdata012_valida_segmento_senior(lr_retorno.idade) then
      	    let lr_retorno.perfil = 3

      	    return lr_retorno.perfil
      	 end if
  
   end if
    
   #-------------------------------------------#
 	 # Valida se o Segmento e Pessoa Juridica    # 
 	 #-------------------------------------------#	 

 	 if lr_param.pestip = "J" then
 	 	  let lr_retorno.perfil = 9 	
 	 end if
   
   
   return lr_retorno.perfil

end function

#========================================================================
function bdata012_exibe_dados_parciais()
#========================================================================

   let mr_count1.des_clau = (mr_count1.apoli - mr_count1.claus2)

   display " "
   display "-----------------------------------------------------------"
   display " DADOS PARCIAIS - DATA ", mr_data.fim
   display "-----------------------------------------------------------"
   display " "
   display " DADOS LIDOS PROPOSTA.............: ", mr_count1.apoli
   display " DADOS DESPREZADOS CLAUSULA.......: ", mr_count1.claus2
   display " DADOS DESPREZADOS CPF/CNPJ.......: ", mr_count1.cpf
   display " DADOS LIDOS MOTOR CLAUSULA.......: ", mr_count1.lidos  
   display " DADOS BENEFICIOS JA CARREGADOS...: ", mr_count1.proce    
   display " DADOS DESPREZADOS MOTOR CLAUSULA.: ", mr_count1.claus
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
function bdata012_exibe_dados_totais()
#========================================================================

   let mr_total.des_clau = (mr_total.apoli - mr_total.claus2)

   display " "
   display "-----------------------------------------------------------"
   display " DADOS TOTAIS "
   display "-----------------------------------------------------------"
   display " "
   display " TOTAIS LIDOS PROPOSTA.............: ", mr_total.apoli
   display " TOTAIS DESPREZADOS CLAUSULA.......: ", mr_total.claus2
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
function bdata012_recupera_quebra()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata004_quebra"
let lr_retorno.cpocod = 1


  open c_bdata012_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata012_020 into m_quebra
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
function bdata012_dispara_email()
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
    let lr_mail.para    = bdata012_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""

    let lr_mail.assunto = "Carga Retroativa Porto Auto Propostas"

    let lr_mail.mensagem  = bdata012_monta_mensagem()
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
function bdata012_recupera_email()
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

let lr_retorno.cponom = "bdata004_email"


  open c_bdata012_027 using  lr_retorno.cponom
  foreach c_bdata012_027 into lr_retorno.cpodes

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
function bdata012_monta_mensagem()
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
                                    "<P>", m_msg_mail clipped, "</P><br><P>" ,
                                    " TOTAIS LIDOS PROPOSTA..............: " , mr_total.apoli     , "<br>" ,
                                    " TOTAIS BENEFICIOS JA CARREGADOS....: " , mr_total.proce     , "<br>" , 
                                    " TOTAIS DESPREZADOS CPF/CNPJ........: " , mr_total.cpf       , "<br>" ,
                                    " TOTAIS LIDOS MOTOR CLAUSULA........: " , mr_total.lidos     , "<br>" ,
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
function bdata012_grava_inconsistencia()
#========================================================================
define lr_retorno record
  status  char(3000)
end record

#define l_mensagem_longa  char(10000)  

initialize lr_retorno.* to null
   whenever error continue
   execute p_bdata012_030 using   mr_inconsistencia.empcod
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
      let m_mensagem = 'ERRO(',sqlca.sqlcode clipped ,') NA INCLUSAO DA INCONSISTENCIA! '
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
function bdata012_grava_beneficio()
#========================================================================

define lr_retorno record
  status  char(30000)
end record

initialize lr_retorno.* to null
   
   let mr_processo2.data_ger = today
   
   whenever error continue
   execute p_bdata012_029 using mr_processo2.empcod
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
      call bdata012_grava_inconsistencia()
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
function bdata012_monta_mensagem2(l_param)
#========================================================================

   define l_param    char(100)

   let m_msg_mail = m_msg_mail clipped, "<br>"
                    , l_param clipped

#========================================================================
end function
#========================================================================

#========================================================================                                       
 function bdata012_valida_segmento_moto(lr_param)                              
#========================================================================                                     
                                                                               
define lr_param record                                                         
	ctgtrfcod      like abbmcasco.ctgtrfcod                                      
end record                                                                     
                                                                               
  if lr_param.ctgtrfcod = 30 or                                                
  	 lr_param.ctgtrfcod = 31 then                                              
  	 	 return true                                                             
  end if                                                                       
                                                                               
  return false                                                                 

#========================================================================                                                                               
end function 
#========================================================================

#========================================================================                                                                                          
 function bdata012_valida_segmento_taxi(lr_param)                       
#========================================================================                      
                                                                        
define lr_param record                                                  
	ctgtrfcod      like abbmcasco.ctgtrfcod                               
end record                                                              
                                                                        
  if lr_param.ctgtrfcod = 80 or                                         
  	 lr_param.ctgtrfcod = 81 then                                       
  	 	 return true                                                      
  end if                                                                
                                                                        
  return false                                                          

#========================================================================                                                                         
end function 
#======================================================================== 

#========================================================================                                                                                  
 function bdata012_valida_segmento_caminhao(lr_param)                       
#========================================================================                       
                                                                            
define lr_param record                                                      
	ctgtrfcod      like abbmcasco.ctgtrfcod                                   
end record                                                                  
                                                                            
                                                                            
  if lr_param.ctgtrfcod = 40 or                                             
  	 lr_param.ctgtrfcod = 41 or                                             
  	 lr_param.ctgtrfcod = 42 or                                             
  	 lr_param.ctgtrfcod = 43 then                                           
  	 	 return true                                                          
  end if                                                                    
                                                                            
  return false                                                              

#========================================================================                                                                            
end function                                                                
#========================================================================                                                                             

#========================================================================                    
 function bdata012_valida_segmento_premium(lr_param)                        
#========================================================================                      
                                                                            
define lr_param record                                                      
	idade   integer               ,                                           
	imsvlr  like abbmcasco.imsvlr                                             
end record                                                                  
                                                                            
                                                                            
  if lr_param.imsvlr >= 200000.00 and                                       
  	 lr_param.idade  >= 25        and                                       
  	 lr_param.idade  <= 59        then                                      
  	 	 return true                                                          
  end if                                                                    
                                                                            
  return false                                                              

#========================================================================                                                                             
end function                                                                
#======================================================================== 
                                                                            
#========================================================================                  
 function bdata012_valida_segmento_mulher(lr_param)                         
#========================================================================                      
                                                                            
define lr_param record                                                      
	idade   integer               ,                                           
	rspcod  like abbmquestionario.rspcod                                      
end record                                                                  
                                                                            
                                                                            
  if lr_param.rspcod =  2   and                                             
  	 lr_param.idade  >= 25  and                                             
  	 lr_param.idade  <= 59  then                                            
  	 	 return true                                                          
  end if                                                                    
                                                                            
  return false                                                              

#========================================================================                                                                            
end function                                                                
#========================================================================                                                                             

#========================================================================                       
 function bdata012_valida_segmento_jovem(lr_param)                          
#========================================================================                       
                                                                            
define lr_param record                                                      
	idade   integer                                                           
end record                                                                  
                                                                            
  if lr_param.idade  >= 18  and                                             
  	 lr_param.idade  <= 24  then                                            
  	 	 return true                                                          
  end if                                                                    
                                                                            
  return false                                                              

#========================================================================                                                                             
end function                                                                
#======================================================================== 
                                                                            
#========================================================================                       
 function bdata012_valida_segmento_senior(lr_param)                         
#========================================================================              
                                                                            
define lr_param record                                                      
	idade   integer                                                           
end record                                                                  
                                                                            
  if lr_param.idade  >= 60  then                                            
  	 	 return true                                                          
  end if                                                                    
                                                                            
  return false                                                              
 
#========================================================================                                                                             
end function                                                                
#======================================================================== 

#========================================================================    
 function bdata012_recupera_produto(lr_param)                
#========================================================================    
                                                                            
define lr_param record                   
  ramcod  like datkplncls.ramcod,        
  empcod  like datkplncls.empcod                  
end record                                 

define lr_retorno record                                                    
  cponom  like datkdominio.cponom,                                                                              
  procod  integer                                           
end record                                                                  
                                                                            
initialize lr_retorno.* to null                                             
                                                                            
let lr_retorno.cponom = "ctc69m07_prod"                                     
                                                  
                                                                                                                                                       
  open c_bdata012_031 using  lr_retorno.cponom ,                            
                             lr_param.empcod   ,
                             lr_param.ramcod                            
  whenever error continue                                                   
  fetch c_bdata012_031 into lr_retorno.procod                               
  whenever error stop                                                       
                                                                                                      
                                                                            
  return lr_retorno.procod  
                                                          
#========================================================================   
end function
#======================================================================== 
#======================================================================== 
 function bdata012_valida_dia_hora()
#======================================================================== 

define lr_retorno record
	dia  integer,
	hora datetime hour to second
end record
   
  let lr_retorno.hora = current
  let lr_retorno.dia  = weekday(today)
  
  if lr_retorno.dia <> 6 and
  	 lr_retorno.dia <> 0 then
  
      if lr_retorno.hora >= '04:00:00' and
         lr_retorno.hora <= '05:00:00' then
         return false
      end if
  end if

 
  return true
#======================================================================== 
 end function
#======================================================================== 

#========================================================================
function bdata012_grava_apolice_processada()
#========================================================================

define lr_retorno record
  status      char(3000),
  doctipcod  smallint    
end record

initialize lr_retorno.* to null

   let lr_retorno.doctipcod     = 888
   let mr_inconsistencia.mtvinc = 'Proposta Processada '
   
   if bdata012_valida_processado() then

         whenever error continue
         execute p_bdata012_030 using   mr_inconsistencia.empcod
                                      , lr_retorno.doctipcod
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
            let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DO REGISTRO PROCESSADO! '
            call ERRORLOG(m_mensagem);
            display m_mensagem
            let lr_retorno.status = false
         else
            let lr_retorno.status = true
         end if 
   end if
#========================================================================
end function
#======================================================================== 

#========================================================================
 function bdata012_valida_processado()                
#========================================================================

define lr_retorno record  
  qtd        integer,  
  doctipcod  smallint      
end record   

  let lr_retorno.qtd = 0  
  
  let lr_retorno.doctipcod = 888 
  
                                                                                                                               
  open c_bdata012_032 using   mr_inconsistencia.empcod   
                            , lr_retorno.doctipcod
                            , mr_inconsistencia.prporgidv
                            , mr_inconsistencia.prpnumidv
                            , mr_inconsistencia.prporgpcp
                            , mr_inconsistencia.prpnumpcp
                            , mr_inconsistencia.viginc
                          
                                      
  whenever error continue                                                   
  fetch c_bdata012_032 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return false
  end if 	 	                                                      
                                                                                                      
  return true                                                                          
                                                            
#========================================================================  
end function
#========================================================================

#========================================================================
 function bdata012_valida_beneficio_processado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata012_033 using   mr_processo2.empcod   
                            , mr_processo2.codtipdoc  
                            , mr_processo2.prporgidv                             
                            , mr_processo2.prpnumidv                             
                            , mr_processo2.srvcod
                            , mr_processo2.codcls
                          
                                      
  whenever error continue                                                   
  fetch c_bdata012_033 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#========================================================================

#========================================================================
 function bdata012_valida_beneficio_inativado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata012_034 using   mr_processo2.empcod   
                            , mr_processo2.codtipdoc  
                            , mr_processo2.prporgidv                             
                            , mr_processo2.prpnumidv                             
                            , mr_processo3.srvcod
                            , mr_processo3.codcls
                                      
  whenever error continue                                                   
  fetch c_bdata012_034 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#========================================================================

#========================================================================
function bdata012_regra_anterior()
#========================================================================

define lr_retorno record
	cont integer
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0    

  #--------------------------------------------------------
  # Verifica se a Clausula Tem Regras Antigas
  #--------------------------------------------------------

  open c_bdata012_001 using   mr_processo2.empcod      ,              
                              mr_processo2.ramcod      ,              
                              mr_processo2.clscod      ,              
                              mr_processo2.perfil      ,              
                              mr_processo2.plnclscod   ,              
                              mr_processo2.clsviginidat                    
  whenever error continue
  fetch c_bdata012_001 into   lr_retorno.cont                             
  whenever error stop
 
  if lr_retorno.cont > 0  then
     return true
  end if

  return false
#========================================================================
end function
#========================================================================

#========================================================================                                                                                                                      
function bdata012_carrega_inativacao()                                             
#========================================================================          
                                                                                   
                                                                                   
define lr_retorno record                                                           
	cont integer                                                                     
end record                                                                         
                                                                                   
initialize mr_processo3.* to null                                                  
initialize lr_retorno.* to null    


    #--------------------------------------------------------                                                      
    # Recupera os Dados do Motor de Regras Antigo                  
    #--------------------------------------------------------      
                                                                 
    open c_bdata012_003 using   mr_processo2.empcod      ,       
                                mr_processo2.ramcod      ,       
                                mr_processo2.clscod      ,       
                                mr_processo2.perfil      ,       
                                mr_processo2.plnclscod   ,       
                                mr_processo2.clsviginidat 
                                
    foreach c_bdata012_003 into mr_processo3.plnclscod                           
                           
        #--------------------------------------------------------                                                            
        # Recupera os Servicos de Cada Regra                                                                                 
        #--------------------------------------------------------                                                            
                                                                                                                           
        open c_bdata012_012 using mr_processo3.plnclscod                                                                   
                                                                                                                           
        foreach c_bdata012_012 into mr_processo3.srvcod                 ,                                                  
                                    mr_processo3.srvplnclscod           ,                                                  
                                    mr_processo3.codcls                 ,                                                  
                                    mr_processo3.clsnom                 ,                                                  
                                    mr_processo3.clssitflg                                                                 
                                                                                                                                                                             
              #------------------------------------------------------                                                      
              # Verifica Se Tem Cobertura                                                                        
              #------------------------------------------------------                                                      
                                                                                                                           
              let mr_inconsistencia.srvcod = mr_processo3.srvcod                                                           
                                                                                                      
              open c_bdata012_014 using mr_processo3.srvplnclscod ,                                                        
                                        mr_processo2.cbtcod                                                                
                                                                                                                           
              whenever error continue                                                                                      
              fetch c_bdata012_014 into lr_retorno.cont                                                                    
              whenever error stop                                                                                          
                                                                                                                           
              if lr_retorno.cont = 0 then                                                                                  
                 let mr_inconsistencia.mtvinc = 'Cobertura não cadastrado no plano'                                        
                 call bdata012_grava_inconsistencia()                                                                                                           
                 continue foreach                                                                  
              end if                                                                               
                                                                                                   
                                                                                                   
                                                                             
              #------------------------------------------------------                              
              # Verifica Se Tem Categoria                                                
              #------------------------------------------------------                              
                                                                                                   
              open c_bdata012_015 using mr_processo3.srvplnclscod ,                                
                                        mr_processo2.ctgtrfcod                                     
                                                                                                   
              whenever error continue                                                              
              fetch c_bdata012_015 into lr_retorno.cont                                            
              whenever error stop                                                                  
                                                                                                   
              if lr_retorno.cont = 0 then                                                          
                 let mr_inconsistencia.mtvinc = 'Categoria Tarifaria não cadastrada para o serviço'
                 call bdata012_grava_inconsistencia()                                                                                
                 continue foreach                                                                  
              end if                                                                               
                                                                                                   
                                                                       
              #------------------------------------------------------                              
              # Verifica Se Tem Restricao por Classe                                     
              #------------------------------------------------------                              
                                                                                                   
              open c_bdata012_016 using mr_processo3.srvplnclscod ,                                
                                        mr_processo2.clalclcod                                     
                                                                                                   
              whenever error continue                                                              
              fetch c_bdata012_016 into mr_processo3.lclclartccod                                  
              whenever error stop                                                                  
                                                                                                   
              if sqlca.sqlcode <> notfound then                                                    
                                                                                                   
                                                                       
                   #------------------------------------------------------                         
                   # Verifica Se a Cidade tem Permissao                                  
                   #------------------------------------------------------                         
                                                                                                   
                   open c_bdata012_017 using mr_processo3.lclclartccod ,                           
                                             mr_processo2.endcid       ,                           
                                             mr_processo2.endufd                                   
                                                                                                   
                   whenever error continue                                                         
                   fetch c_bdata012_017 into lr_retorno.cont                                       
                   whenever error stop                                                             
                                                                                                   
                   if lr_retorno.cont = 0 then                                                     
                      let mr_inconsistencia.mtvinc = 'Cidade não cadastrada para o serviço'        
                      call bdata012_grava_inconsistencia()                                                                        
                      continue foreach                                                             
                   end if                                                                          
                                                                                                   
              end if     
              
              if mr_processo2.itmnumdig is null then                  
                let mr_processo2.itmnumdig = 0                        
              end if 
              
              #------------------------------------------------------              
              # Verifica Se o Beneficio Ja foi Inativado                                
              #------------------------------------------------------              
              
              if bdata012_valida_beneficio_inativado() then
                	let mr_count1.proce = mr_count1.proce + 1
              	  let mr_total.proce  = mr_total.proce + 1
							 	continue foreach
              end if  
              
              #------------------------------------------------------
              # Grava o Inativo                                    
              #------------------------------------------------------                                                                                                                           
                                                                                                    
              call bdata012_grava_inativo()                                                                     
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
function bdata012_grava_inativo()                                                           
#========================================================================                     

define lr_retorno record                                                                      
  status  char(30000)                                                                         
end record                                                                                    
                                                                                              
initialize lr_retorno.* to null                                                                                                                                    
                                                                                      
let mr_processo2.data_ger = today 
let mr_processo3.pcmflg   = 'R'                                                  
                                                                                  
   whenever error continue                                                            
   execute p_bdata012_029 using mr_processo2.empcod                           
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
      call bdata012_grava_inconsistencia()                                            
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
function bdata012_acessa_inativacao()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata004_acessa"
let lr_retorno.cpocod = 1


  open c_bdata012_020 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata012_020 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes =  "S"  then
     return true
  end if
  
  return false
#========================================================================
end function
#======================================================================== 

#========================================================================
 function bdata012_ja_carregado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata012_004 using   mr_processo2.empcod   
                            , mr_processo2.prporgidv                             
                            , mr_processo2.prpnumidv                             
                            , mr_data.fim
                                                                
  whenever error continue                                                   
  fetch c_bdata012_004 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#========================================================================                                                           