#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: bdata013                                                   #
# Objetivo.......: Batch de Geracao de Apolices Retroativas Itau Auto         #
# Analista Resp. : R.Fornax                                                   #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 20/05/2016                                                 #
#-----------------------------------------------------------------------------#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
   define g_ismqconn smallint
end globals


define m_path_log        char(100)
define m_bdata013_prep   smallint
define m_mensagem        char(150)
define m_commit          integer
define m_quebra          integer
define m_gravou          smallint
define m_inativou        smallint  
define m_msg_mail        char(10000)

define mr_count1 record
   lidos    integer,
   motor    integer,
   relat    integer,
   inat     integer, 
   claus    integer,
   categ    integer,
   apoli    integer,
   proce    integer  
end record

define mr_total record
   lidos    integer,
   motor    integer,
   relat    integer,
   inat     integer, 
   claus    integer,
   categ    integer,
   apoli    integer,
   proce    integer  
end record

define mr_param record
    ini date                            ,
    fim date                            ,
    hour_ini datetime hour to second    ,
    hour_fim datetime hour to second
end record

define mr_processo2 record 
	itaciacod               like datmitaaplitm.itaciacod             ,
  succod                  like abbmdoc.succod                      ,
  aplnumdig               like abbmdoc.aplnumdig                   ,
  itmnumdig               like abbmdoc.itmnumdig                   ,
  edsnumref               like abamdoc.edsnumdig                   ,
  ctgtrfcod               like abbmcasco.ctgtrfcod                 ,
  clscod                  like abbmclaus.clscod                    ,
  empcod                  like datkplncls.empcod                   ,
  ramcod                  like datkplncls.ramcod                   ,
  plnclscod               like datkplncls.plnclscod                ,
  srvcod                  like datksrv.srvcod                      ,
  empnom                  like gabkemp.empnom                      ,
  srvplnclscod            like datksrvplncls.srvplnclscod          ,
  endcid                  like gsakend.endcid                      ,
  endufd                  like gsakend.endufd                      ,
  emsdat                  like abamapol.emsdat                     ,
  codcls                  like datkplncls.clscod                   ,
  clsnom                  like datkplncls.clsnom                   ,
  clssitflg               like datkplncls.clssitflg                ,
  codprod                 smallint                                 ,
  nscdat                  like gsakseg.nscdat                      ,
  pestip                  like datmitaapl.pestipcod                ,
  viginc                  like datmitaapl.itaaplvigincdat          ,
  vigfnl                  like datmitaapl.itaaplvigfnldat          ,
  rspdat                  like abbmquestionario.rspdat             ,
  rspcod                  like abbmquestionario.rspcod             ,
  perfil                  integer                                  ,
  cgccpfnum               like datmitaapl.segcgccpfnum             ,
  cgcord                  like datmitaapl.segcgcordnum             ,
  cgccpfdig               like datmitaapl.segcgccpfdig             ,
  codtipdoc               smallint                                 ,
  prporgidv               like abbmdoc.prporgidv                   ,
  prpnumidv               like abbmdoc.prpnumidv                   ,
  pcmflg                  char(1)                                  ,
  erro                    integer                                  ,
  data_ger                datetime year to second                  ,
  porvclcod               like datmitaaplitm.porvclcod             ,
  ctotipcod               char(1)                                  ,
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
	itaciacod               like datmitaaplitm.itaciacod             ,   
  succod                  like abbmdoc.succod                      ,
  aplnumdig               like abbmdoc.aplnumdig                   ,
  itmnumdig               like abbmdoc.itmnumdig                   ,
  dctnumseq               like abbmdoc.itmnumdig                   ,
  emsdat                  like abamapol.emsdat                     ,
  viginc                  like datmitaapl.itaaplvigincdat          ,   
  vigfnl                  like datmitaapl.itaaplvigfnldat          ,   
  cgccpfnum               like datmitaapl.segcgccpfnum             , 
  cgcord                  like datmitaapl.segcgcordnum             , 
  cgccpfdig               like datmitaapl.segcgccpfdig             , 
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
  pestip                  like datmitaapl.pestipcod                ,  
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
  empcod                  like datkplncls.empcod                   ,
  ramcod                  like datkplncls.ramcod                   
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

   call bdata013_cria_log()

   call bdata013_exibe_inicio()

   call fun_dba_abre_banco("CT24HS")

   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata013_prep = false
   
   let mr_total.lidos      = 0
   let mr_total.motor      = 0
   let mr_total.relat      = 0
   let mr_total.inat       = 0  
   let mr_total.claus      = 0
   let mr_total.categ      = 0
   let mr_total.apoli      = 0  
   let mr_total.proce      = 0       
   let m_gravou            = false
   let m_inativou          = false 
   let m_commit            = 0
   let m_msg_mail          = ""

   display "##################################"
   display " PREPARANDO... "
   display "##################################"
   call bdata013_prepare()


   display "##################################"
   display " RECUPERANDO QUEBRA... "
   display "##################################"
   if not bdata013_recupera_quebra() then
      exit program
   end if  


   
   
    if not bdata013_carga_full() then
       let m_mensagem = "Carga Full Abortada. Verificar os Dominios."
       call ERRORLOG(m_mensagem);
       display m_mensagem
    end if
    
   
     
  
   call bdata013_exibe_final()

   call bdata013_dispara_email()

#========================================================================
end main
#========================================================================

#===============================================================================
function bdata013_prepare()
#===============================================================================

define l_sql char(10000)

   
   let l_sql =  ' select b.itaciacod          '
               ,'       ,a.succod             '
               ,'       ,b.itaaplnum          '
               ,'       ,b.itaaplitmnum       ' 
               ,'       ,b.itaramcod          '
               ,'       ,b.aplseqnum          '
               ,'       ,a.pestipcod          '     
               ,'       ,a.segcgccpfnum       '
               ,'       ,a.segcgcordnum       '
               ,'       ,a.segcgccpfdig       '
               ,'       ,a.itaaplvigincdat    '
               ,'       ,a.itaaplvigfnldat    '
               ,'       ,b.asiincdat          ' 
               ,'       ,a.segcidnom          '
               ,'       ,a.segufdsgl          '
               ,'       ,b.porvclcod          '
               ,' from datmitaapl a  ,        '       
               ,'      datmitaaplitm b        '       
               ,' where a.itaciacod  = b.itaciacod '            
               ,' and   a.itaramcod  = b.itaramcod '            
               ,' and   a.itaaplnum  = b.itaaplnum '            
               ,' and   a.aplseqnum  = b.aplseqnum '            
               ,' and   a.itaaplvigincdat  = ?           '            
               ,' and   a.aplseqnum  =(select max(c.aplseqnum)' 
               ,' from datmitaapl c                           ' 
               ,' where a.itaciacod = c.itaciacod             ' 
               ,' and   a.itaramcod = c.itaramcod             ' 
               ,' and   a.itaaplnum = c.itaaplnum)            ' 
               ,' and   not exists                            '
               ,' (select * from datmbnfcrgico d              '
               ,'  where d.empcod  = ?                        '
               ,'  and d.dcttipcod = 999                      '
               ,'  and d.apldignum = a.itaaplnum              '
               ,'  and d.itmdignum = b.itaaplitmnum           '
               ,'  and d.dctseqnum = b.aplseqnum              '
               ,'  and d.ramcod = a.itaramcod                 '
               ,'  and d.incvigdat = ?)                       '            
               ,' order by a.itaaplvigfnldat desc             '            
   prepare p_bdata013_001 from l_sql
   declare c_bdata013_001 cursor with hold for p_bdata013_001


   
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
   prepare p_bdata013_002 from l_sql
   declare c_bdata013_002 cursor for p_bdata013_002
   
   let l_sql = ' select a.srvcod                 ,   '
              ,'        a.srvplnclscod           ,   '
              ,'        b.clscod                 ,   '
              ,'        b.clsnom                 ,   '
              ,'        b.clssitflg                  '
              ,' from datksrvplncls a,               '
              ,'      datkplncls b                   '
              ,' where b.plnclscod  = a.plnclscod    '
              ,' and   a.plnclscod  = ?              '
   prepare p_bdata013_003 from l_sql
   declare c_bdata013_003 cursor with hold for p_bdata013_003
   
   let l_sql = ' select empnom     '
              ,' from gabkemp      '
              ,' where empcod = ?   '
   prepare p_bdata013_004 from l_sql
   declare c_bdata013_004 cursor for p_bdata013_004
   
   
   let l_sql = ' select count(*)        '
              ,' from datktrfctgcss     '
              ,' where srvclscod   =  ? '
              ,' and   trfctgcod   =  ? '
   prepare p_bdata013_005 from l_sql
   declare c_bdata013_005 cursor for p_bdata013_005
   

   let l_sql =  ' update datkplncls     '
             ,  ' set irdclsflg = "S"   '
             ,  ' where plnclscod = ?   '
   prepare p_bdata013_006 from l_sql
   
   let l_sql = ' select cpodes        '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
              ,' and   cpocod =  ?    '
   prepare p_bdata013_007 from l_sql
   declare c_bdata013_007 cursor for p_bdata013_007
   
   
   let l_sql =  ' update datkdominio    '
              , ' set   cpodes =  ?     '
              , ' where cponom =  ?     '
              , ' and   cpocod =  ?     '
   prepare p_bdata013_008 from l_sql
   
 
   let l_sql = ' select cpodes        '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
   prepare p_bdata013_009 from l_sql
   declare c_bdata013_009 cursor for p_bdata013_009
   
   
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
             ,'  ,ctotipcod    '
             ,'  ,pcmflg   )   '
             ,'  values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,? '
             ,'  ,?,?,?,?,?,?)                         '
   prepare p_bdata013_010 from l_sql   
   
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
  prepare p_bdata013_011 from l_sql
  
  let l_sql = 'select a.itaciacod  , ',
              '  a.itaramcod       , ',
              '  a.itaaplnum       , ',
              '  a.aplseqnum       , ',
              '  a.itaprpnum       , ',
              '  a.itaaplvigincdat , ',
              '  a.itaaplvigfnldat , ',
              '  a.segnom          , ',
              '  a.pestipcod       , ',
              '  a.segcgccpfnum    , ',
              '  a.segcgcordnum    , ',
              '  a.segcgccpfdig    , ',
              '  a.itaprdcod       , ',
              '  b.itasgrplncod    , ',
              '  b.itaempasicod    , ',
              '  b.itaasisrvcod    , ',
              '  a.itacliscocod    , ',
              '  b.itarsrcaosrvcod , ',
              '  b.itaclisgmcod    , ',
              '  b.itaaplcanmtvcod , ',
              '  b.rsrcaogrtcod    , ',
              '  b.asiincdat       , ',
              '  a.corsus          , ',
              '  a.seglgdnom       , ',
              '  a.seglgdnum       , ',
              '  a.segendcmpdes    , ',
              '  a.segbrrnom       , ',
              '  a.segcidnom       , ',
              '  a.segufdsgl       , ',
              '  a.segcepnum       , ',
              '  a.segcepcmpnum    , ',
              '  a.segresteldddnum , ',
              '  a.segrestelnum    , ',
              '  a.adniclhordat    , ',
              '  a.itaasiarqvrsnum , ',
              '  a.pcsseqnum       , ',
              '  b.ubbcod          , ',
              '  a.succod          , ',
              '  a.vipsegflg       , ',
              '  a.segmaiend       , ',
              '  b.itaaplitmnum    , ',
              '  b.itaaplitmsttcod , ',
              '  b.autchsnum       , ',
              '  b.autplcnum       , ',
              '  b.autfbrnom       , ',
              '  b.autlnhnom       , ',
              '  b.autmodnom       , ',
              '  b.itavclcrgtipcod , ',
              '  b.autfbrano       , ',
              '  b.autmodano       , ',
              '  b.autcornom       , ',
              '  b.autpintipdes    , ',
              '  b.okmflg          , ',
              '  b.impautflg       , ',
              '  b.casfrqvlr       , ',
              '  b.rsclclcepnum    , ',
              '  b.rcslclcepcmpnum , ',
              '  b.porvclcod       , ',
              '  a.frtmdlcod       , ',
              '  a.vndcnlcod       , ',
              '  b.vcltipcod       , ',
              '  b.bldflg            ',
              ' from datmitaapl a  , ',
              '      datmitaaplitm b ',
              ' where a.itaciacod = b.itaciacod  ',
              ' and   a.itaramcod = b.itaramcod  ',
              ' and   a.itaaplnum = b.itaaplnum  ',
              ' and   a.aplseqnum = b.aplseqnum  ',
              ' and   a.itaciacod     = ? ',
              ' and   a.itaramcod     = ? ',
              ' and   a.itaaplnum     = ? ',
              ' and   a.aplseqnum     = ? ',
              ' and   b.itaaplitmnum  = ? '
   prepare p_bdata013_012 from l_sql                
   declare c_bdata013_012 cursor for p_bdata013_012
   	
   let l_sql = ' select  itacbtcod,    ' ,
               '         itaasiplncod  ' ,
               ' from datkitacbtintrgr ' ,
               ' where itaasisrvcod     = ?     ' ,
               ' and   rsrcaogrtcod     = ?     ' ,
               ' and   itarsrcaosrvcod  = ?     ' ,
               ' and   ubbcod           = ?     '
   prepare p_bdata013_013 from l_sql               
   declare c_bdata013_013 cursor for p_bdata013_013
   	
   let l_sql = ' select cpodes[8,12]     '  
              ,' from datkdominio        '             
              ,' where cponom =  ?       '                
              ,' and   cpodes[1,2] =  ?  '
              ,' and   cpodes[4,6] =  ?  '             
   prepare p_bdata013_014 from l_sql                
   declare c_bdata013_014 cursor for p_bdata013_014 
   	
   let l_sql = ' select count(*)      '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
              ,' and   cpodes =  ?    '
   prepare p_bdata013_015 from l_sql
   declare c_bdata013_015 cursor for p_bdata013_015	
   	
   
   let l_sql = ' select cpodes                       '  
              ,' from datkdominio                    '             
              ,' where cponom matches "IT_ASS_PRD_*" '                
              ,' and   cpocod =  ?                   '            
   prepare p_bdata013_016 from l_sql                
   declare c_bdata013_016 cursor for p_bdata013_016 	
   	
   	
   let l_sql = ' select count(*)      '
              ,' from datmbnfcrgico   '
              ,' where empcod =  ?    '
              ,' and   dcttipcod =  ? '
              ,' and   succod =  ?    '
              ,' and   ramcod =  ?    ' 
              ,' and   apldignum =  ? '
              ,' and   itmdignum =  ? '
              ,' and   dctseqnum =  ? '
              ,' and   incvigdat =  ? '              
   prepare p_bdata013_017 from l_sql
   declare c_bdata013_017 cursor for p_bdata013_017
   	
   let l_sql = ' select count(*)           '
             , '   from datkplncls         '
             , '  where empcod =  ?        '
             , '  and   ramcod =  ?        '
             , '  and   clscod =  ?        '
             , '  and   prfcod =  ?        '
             , '  and   plnclscod <>  ?    '     
             , '  and   clsvigfimdat <= ?  '           
   prepare p_bdata013_018 from l_sql
   declare c_bdata013_018 cursor for p_bdata013_018
   	
   
   let l_sql = ' select plnclscod          '
             , '   from datkplncls         '
             , '  where empcod =  ?        '
             , '  and   ramcod =  ?        '
             , '  and   clscod =  ?        '
             , '  and   prfcod =  ?        '
             , '  and   plnclscod <>  ?    '     
             , '  and   clsvigfimdat <= ?  '           
   prepare p_bdata013_019 from l_sql
   declare c_bdata013_019 cursor for p_bdata013_019
   	
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
   prepare p_bdata013_020 from l_sql
   declare c_bdata013_020 cursor for p_bdata013_020
   	
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
   prepare p_bdata013_021 from l_sql
   declare c_bdata013_021 cursor for p_bdata013_021	
   	

   let m_bdata013_prep = true

#========================================================================
end function
#========================================================================


#========================================================================
function bdata013_cria_log()
#========================================================================

   define l_path char(200)

   let l_path = null
   let l_path = f_path("DAT","LOG")

   if l_path is null or
      l_path = " " then
      let l_path = "."
   end if

   let l_path = m_path_log clipped, "bdata013.log"

   call startlog(l_path)

#========================================================================
end function
#========================================================================




#========================================================================
function bdata013_carrega_beneficio()
#========================================================================

define lr_retorno record
   cont           integer                   ,
   grava          smallint                  ,
   aplnumdig_ant  like abbmdoc.aplnumdig    ,
   resultado      smallint                  ,
   mensagem       char(50)
end record

define l_data date
define l_hora datetime hour to second

initialize mr_processo2.* to null
initialize mr_processo3.* to null
initialize mr_inconsistencia.* to null
initialize lr_retorno.* to null

let l_data = null
let l_hora = null

let mr_processo2.empcod         = 84
let mr_processo2.codtipdoc      = 1
let mr_processo2.pcmflg         = 'S'
let lr_retorno.cont             = 0
let lr_retorno.grava            = false
let lr_retorno.aplnumdig_ant    = 0
let mr_count1.lidos             = 0
let mr_count1.motor             = 0
let mr_count1.relat             = 0
let mr_count1.inat              = 0 
let mr_count1.claus             = 0
let mr_count1.categ             = 0
let mr_count1.apoli             = 0  
let mr_count1.proce             = 0 
let mr_processo2.perfil         = 0
let mr_inconsistencia.empcod    = 84
let mr_inconsistencia.doctipcod = 1
let mr_inconsistencia.dtger     = today
let mr_inconsistencia.prporgidv = 0
let mr_inconsistencia.prpnumidv = 0
let mr_processo2.prporgidv      = 0
let mr_processo2.prpnumidv      = 0


     
     begin work;


     #display "Query 1"
    #--------------------------------------------------------
    # Recupera o Nome da Empresa
    #--------------------------------------------------------

     open c_bdata013_004 using mr_processo2.empcod

     whenever error continue
     fetch c_bdata013_004 into mr_processo2.empnom
     whenever error stop

    #display "Query 2"
    #--------------------------------------------------------
    # Recupera os Dados da Apolice
    #--------------------------------------------------------
    open c_bdata013_001 using mr_data.fim         ,
                              mr_processo2.empcod ,
                              mr_data.fim
  
    foreach c_bdata013_001 into mr_processo2.itaciacod
                              , mr_processo2.succod
                              , mr_processo2.aplnumdig 
                              , mr_processo2.itmnumdig
                              , mr_processo2.ramcod
                              , mr_processo2.edsnumref 
                              , mr_processo2.pestip 
                              , mr_processo2.cgccpfnum
                              , mr_processo2.cgcord   
                              , mr_processo2.cgccpfdig
                              , mr_processo2.viginc 
                              , mr_processo2.vigfnl
                              , mr_processo2.emsdat
                              , mr_processo2.endcid
                              , mr_processo2.endufd
                              , mr_processo2.porvclcod 

       let mr_inconsistencia.itaciacod = mr_processo2.itaciacod       
       let mr_inconsistencia.succod    = mr_processo2.succod 
       let mr_inconsistencia.ramcod    = mr_processo2.ramcod 
       let mr_inconsistencia.aplnumdig = mr_processo2.aplnumdig
       let mr_inconsistencia.itmnumdig = mr_processo2.itmnumdig 
       let mr_inconsistencia.viginc    = mr_processo2.viginc  
       let mr_inconsistencia.vigfnl    = mr_processo2.vigfnl   
       let mr_inconsistencia.emsdat    = mr_processo2.emsdat 
       let mr_inconsistencia.pestip    = mr_processo2.pestip        
       let mr_inconsistencia.cgccpfnum = mr_processo2.cgccpfnum 
       let mr_inconsistencia.cgcord    = mr_processo2.cgcord    
       let mr_inconsistencia.cgccpfdig = mr_processo2.cgccpfdig 
       let mr_inconsistencia.endcid    = mr_processo2.endcid
       let mr_inconsistencia.endufd    = mr_processo2.endufd
      
       
       let mr_count1.apoli = mr_count1.apoli + 1
       let mr_total.apoli  = mr_total.apoli + 1 
       
       #------------------------------------------------------ 
       # Grava Apolice Processada                        
       #------------------------------------------------------ 
       call bdata013_grava_apolice_processada()

       #display "Query 3"
       #------------------------------------------------------
       # Recupera Categoria Tarifaria
       #------------------------------------------------------

       call cty05g03_pesq_catgtf(mr_processo2.porvclcod,
                                 mr_processo2.viginc   ) 
       returning lr_retorno.resultado   ,    
                 lr_retorno.mensagem    ,    
                 mr_processo2.ctgtrfcod
      
       let mr_inconsistencia.ctgtrfcod = mr_processo2.ctgtrfcod
      
			
       let mr_count1.lidos = mr_count1.lidos + 1
       let mr_total.lidos  = mr_total.lidos + 1

       let lr_retorno.aplnumdig_ant = mr_processo2.aplnumdig

       
       #display "Query 4"                                     
       #------------------------------------------------------
       # Recupera o Plano da Apolice Itau                         
       #------------------------------------------------------
       call bdata013_rec_dados_itau(mr_processo2.itaciacod,
                                    mr_processo2.ramcod   ,
                                    mr_processo2.aplnumdig,
                                    mr_processo2.edsnumref,
                                    mr_processo2.itmnumdig)
       returning lr_retorno.resultado, 
                 lr_retorno.mensagem  
       
       let mr_processo2.clscod = g_doc_itau[1].itaasiplncod  
			
			
			 #------------------------------------------------------ 
			 # Recupera o Tipo de Contabilizacao A-police I-tem                     
			 #------------------------------------------------------ 
			 if bdata013_verifica_empresarial(mr_processo2.clscod) then		 
			    let mr_processo2.ctotipcod = "A"
			 else
			 	  let mr_processo2.ctotipcod = "I"
			 end if
			 
			 #------------------------------------------------------  
			 # Recupera o Codigo do Produto       
			 #------------------------------------------------------  
			 let mr_processo2.codprod = bdata013_recupera_produto(mr_processo2.ramcod,mr_processo2.empcod)
			 
			 
			 #------------------------------------------------------  
			 # Recupera o Codigo do Grupo do Produto       
			 #------------------------------------------------------  
			 			 
			 let mr_processo2.perfil =  bdata013_recupera_grupo_produto()
			 
			 		 
       #display "Query 5"
       #--------------------------------------------------------
       # Regra 1 - Verifica se o Plano Existe no Motor
       #--------------------------------------------------------

       open c_bdata013_002 using   mr_processo2.empcod ,
                                   mr_processo2.ramcod ,
                                   mr_processo2.clscod ,
                                   mr_processo2.perfil ,
                                   mr_processo2.viginc ,
                                   mr_processo2.viginc  
       whenever error continue
       fetch c_bdata013_002 into   mr_processo2.plnclscod,
                                   mr_processo2.clsviginidat
       whenever error stop

       let mr_inconsistencia.clscod    = mr_processo2.clscod
       let mr_inconsistencia.plnclscod = mr_processo2.plnclscod
      
       if sqlca.sqlcode = notfound  then

            let m_mensagem = "Empresa.......: ", mr_processo2.empcod
            call errorlog(m_mensagem)
            
            let m_mensagem ="Ramo..........: ", mr_processo2.ramcod
            call errorlog(m_mensagem)
            
            let m_mensagem ="Plano.........: ", mr_processo2.clscod
            call errorlog(m_mensagem)
           
            let m_mensagem ="Sucursal......: ", mr_processo2.succod
            call errorlog(m_mensagem)
           
            let m_mensagem ="Apolice.......: ", mr_processo2.aplnumdig
            call errorlog(m_mensagem)
            
            let m_mensagem ="Item..........: ", mr_processo2.itmnumdig
            call errorlog(m_mensagem)
            
       

            let mr_inconsistencia.mtvinc = 'N�o Localizado Registro para esse Plano '
            call bdata013_grava_inconsistencia()
            let mr_count1.claus = mr_count1.claus + 1
            let mr_total.claus  = mr_total.claus + 1

            continue foreach
       end if
       
       #--------------------------------------------------------
       # Verifica Processo de Inativacao     
       #--------------------------------------------------------
       
       if bdata013_acessa_inativacao() then
          if bdata013_regra_anterior() then
             call bdata013_carrega_inativacao()
          end if
       end if

       #display "Query 6"
       #--------------------------------------------------------
       # Recupera os Dados do Motor de Regras
       #--------------------------------------------------------

       open c_bdata013_003 using mr_processo2.plnclscod

       foreach c_bdata013_003 into mr_processo2.srvcod                 ,
                                   mr_processo2.srvplnclscod           ,
                                   mr_processo2.codcls                 ,
                                   mr_processo2.clsnom                 ,
                                   mr_processo2.clssitflg

             let mr_count1.motor = mr_count1.motor + 1
             let mr_total.motor  = mr_total.motor + 1

             let mr_inconsistencia.srvcod = mr_processo2.srvcod
            

             #display "Query 7"
             #------------------------------------------------------
             # Regra 2 - Verifica Se Tem Categoria
             #------------------------------------------------------

             open c_bdata013_005 using mr_processo2.srvplnclscod ,
                                       mr_processo2.ctgtrfcod

             whenever error continue
             fetch c_bdata013_005 into lr_retorno.cont
             whenever error stop
           
             if lr_retorno.cont = 0 then
                let mr_inconsistencia.mtvinc = 'Categoria Tarifaria n�o cadastrada para o servi�o'
                call bdata013_grava_inconsistencia()
                let mr_count1.categ = mr_count1.categ + 1
                let mr_total.categ  = mr_total.categ + 1
                continue foreach
             end if
             
             #------------------------------------------------------              
             # Verifica Se o Beneficio Ja foi Carregado                                
             #------------------------------------------------------              
             
             if bdata013_valida_beneficio_processado() then
               	let mr_count1.proce = mr_count1.proce + 1
             	  let mr_total.proce  = mr_total.proce + 1
								continue foreach
             end if
             
             #------------------------------------------------------    
             # Grava o Beneficio                                        
             #------------------------------------------------------    
                         
             call bdata013_grava_beneficio()
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

    call bdata013_exibe_dados_parciais()

    commit work;

#========================================================================
end function
#========================================================================

#========================================================================
function bdata013_exibe_inicio()
#========================================================================
define l_data  date,
       l_hora  datetime hour to second

let l_data            = today
let l_hora            = current
let mr_param.ini      = today
let mr_param.hour_ini = current

   display " "
   display "-------------------------------------------------------------------------"
   display " INICIO bdata013 - CARGA RETROATIVA ITAU AUTO PARA BASE DE BENEFICIO"
   display "-------------------------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let m_mensagem = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(m_mensagem)


#========================================================================
end function
#========================================================================

#========================================================================
function bdata013_exibe_final()
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
function bdata013_recupera_dias()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata008_retro"
let lr_retorno.cpocod = 1


  open c_bdata013_007 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata013_007 into lr_retorno.cpodes
  whenever error stop
 
  if lr_retorno.cpodes is not null  then
     let mr_data.dias =  lr_retorno.cpodes
  end if
  

#========================================================================
end function
#========================================================================


#========================================================================
function bdata013_recupera_data_inicio()
#========================================================================

  call bdata013_recupera_dias()
  
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
function bdata013_recupera_data_fim()
#========================================================================

   let mr_data.fim =  today - 2
   
#========================================================================
end function
#========================================================================

#========================================================================
function bdata013_recupera_data_validacao()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata013_data"
let lr_retorno.cpocod = 1


  open c_bdata013_007 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata013_007 into lr_retorno.cpodes
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
function bdata013_carga_full()
#========================================================================

   display "##################################"
   display " CARREGANDO APOLICES FULL... "
   display "##################################"

   initialize mr_data.* to null
   
   call bdata013_recupera_data_inicio()
   call bdata013_recupera_data_fim()  
   call bdata013_recupera_data_validacao()
        
  
  
   let m_mensagem = " CARGA APOLICES RETROATIVO..........: ", mr_data.inicio, " - ", mr_data.fim   
   call bdata013_monta_mensagem2(m_mensagem)


   while mr_data.inicio <= mr_data.fim

      if mr_data.fim < mr_data.validacao then   	 
      	 let mr_data.fim = mr_data.fim - 1 units day  
      	 continue while
      end if
      
      display ""
      display "======================================="
      display "PROCESSANDO DATA...", mr_data.fim
      display "======================================="

      call bdata013_carrega_beneficio()
         
      let mr_data.fim = mr_data.fim - 1 units day
      
      if not bdata013_valida_dia_hora() then
         exit while
      end if
     
   end while
   
   call bdata013_exibe_dados_totais()
   
   return true

#========================================================================
end function
#========================================================================


#========================================================================
function bdata013_exibe_dados_parciais()
#========================================================================

   display " "
   display "-----------------------------------------------------------"
   display " DADOS PARCIAIS - DATA ", mr_data.fim
   display "-----------------------------------------------------------"
   display " "
   display " DADOS LIDOS APOLICE..............: ", mr_count1.apoli
   display " DADOS LIDOS MOTOR PLANO..........: ", mr_count1.lidos
   display " DADOS DESPREZADOS MOTOR PLANO....: ", mr_count1.claus
   display " DADOS BENEFICIOS JA CARREGADOS...: ", mr_count1.proce     
   display " DADOS LIDOS MOTOR DE REGRAS......: ", mr_count1.motor
   display " DADOS DESPREZADOS CATEGORIA......: ", mr_count1.categ
   display " DADOS INATIVADOS.................: ", mr_count1.inat 
   display " DADOS GRAVADOS NA TABELA.........: ", mr_count1.relat


#========================================================================
end function
#========================================================================

#========================================================================
function bdata013_exibe_dados_totais()
#========================================================================


   display " "
   display "-----------------------------------------------------------"
   display " DADOS TOTAIS "
   display "-----------------------------------------------------------"
   display " "
   display " TOTAIS LIDOS APOLICE..............: ", mr_total.apoli
   display " TOTAIS LIDOS MOTOR PLANO..........: ", mr_total.lidos
   display " TOTAIS DESPREZADOS MOTOR PLANO....: ", mr_total.claus  
   display " TOTAIS BENEFICIOS JA CARREGADOS...: ", mr_total.proce  
   display " TOTAIS LIDOS MOTOR DE REGRAS......: ", mr_total.motor
   display " TOTAIS DESPREZADOS CATEGORIA......: ", mr_total.categ
   display " TOTAIS INATIVADOS.................: ", mr_total.inat
   display " TOTAIS GRAVADOS NA TABELA.........: ", mr_total.relat


#========================================================================
end function
#========================================================================

#========================================================================
function bdata013_recupera_quebra()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata008_quebra"
let lr_retorno.cpocod = 1


  open c_bdata013_007 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata013_007 into m_quebra
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
function bdata013_dispara_email()
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
    let lr_mail.para    = bdata013_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""

    let lr_mail.assunto = "Carga Retroativa Itau Auto"

    let lr_mail.mensagem  = bdata013_monta_mensagem()
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
function bdata013_recupera_email()
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

let lr_retorno.cponom = "bdata008_email"


  open c_bdata013_009 using  lr_retorno.cponom
  foreach c_bdata013_009 into lr_retorno.cpodes

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
function bdata013_monta_mensagem()
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
                                    " TOTAIS LIDOS MOTOR PLANO...........: " , mr_total.lidos     , "<br>" ,
                                    " TOTAIS DESPREZADOS MOTOR PLANO.....: " , mr_total.claus     , "<br>" ,
                                    " TOTAIS BENEFICIOS JA CARREGADOS....: " , mr_total.proce     , "<br>" ,                                     
                                    " TOTAIS LIDOS MOTOR DE REGRAS.......: " , mr_total.motor     , "<br>" ,
                                    " TOTAIS DESPREZADOS CATEGORIA.......: " , mr_total.categ     , "<br>" ,
                                    " TOTAIS INATIVADOS..................: " , mr_total.inat      , "<br>" , 
                                    " TOTAIS GRAVADOS NO RELATORIO.......: " , mr_total.relat     , "<br></P></PRE>"

          return lr_retorno.mensagem

#========================================================================
end function
#========================================================================
#========================================================================
function bdata013_grava_inconsistencia()
#========================================================================

define lr_retorno record
  status  char(3000)
end record

initialize lr_retorno.* to null

   whenever error continue
   execute p_bdata013_011 using   mr_inconsistencia.empcod
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
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DA INCONSISTENCIA! '
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
function bdata013_grava_beneficio()
#========================================================================

define lr_retorno record
  status  char(30000)
end record

initialize lr_retorno.* to null

  let mr_processo2.data_ger = today
   
   whenever error continue
   execute p_bdata013_010 using mr_processo2.empcod
                              , mr_processo2.codprod
                              , mr_processo2.codtipdoc
                              , mr_processo2.itaciacod
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
                              , mr_processo2.ctotipcod
                              , mr_processo2.pcmflg
   whenever error continue
   
   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DOS BENEFICIOS! '
      let mr_inconsistencia.mtvinc = m_mensagem
      call bdata013_grava_inconsistencia()
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
function bdata013_monta_mensagem2(l_param)
#========================================================================

   define l_param    char(100)

   let m_msg_mail = m_msg_mail clipped, "<br>"
                    , l_param clipped

#========================================================================
end function
#========================================================================


#------------------------------------------------------------------------------
function bdata013_rec_dados_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod       ,
   itaramcod     like datmitaapl.itaramcod       ,
   itaaplnum     like datmitaapl.itaaplnum       ,
   aplseqnum     like datmitaapl.aplseqnum       ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
   erro          integer                         ,
   mensagem      char(50)
end record

define lr_retorno_aux record
   erro          integer                         ,
   mensagem      char(50)
end record

define l_index smallint

initialize lr_retorno.* ,
           lr_retorno_aux.* to null

for  l_index  =  1  to  500
   initialize  g_doc_itau[l_index].* to  null
end  for


let lr_retorno.erro = 0

   open c_bdata013_012 using lr_param.itaciacod    ,
                             lr_param.itaramcod    ,
                             lr_param.itaaplnum    ,
                             lr_param.aplseqnum    ,
                             lr_param.itaaplitmnum

   whenever error continue
   fetch c_bdata013_012 into g_doc_itau[1].itaciacod          ,
                             g_doc_itau[1].itaramcod          ,
                             g_doc_itau[1].itaaplnum          ,
                             g_doc_itau[1].aplseqnum          ,
                             g_doc_itau[1].itaprpnum          ,
                             g_doc_itau[1].itaaplvigincdat    ,
                             g_doc_itau[1].itaaplvigfnldat    ,
                             g_doc_itau[1].segnom             ,
                             g_doc_itau[1].pestipcod          ,
                             g_doc_itau[1].segcgccpfnum       ,
                             g_doc_itau[1].segcgcordnum       ,
                             g_doc_itau[1].segcgccpfdig       ,
                             g_doc_itau[1].itaprdcod          ,
                             g_doc_itau[1].itasgrplncod       ,
                             g_doc_itau[1].itaempasicod       ,
                             g_doc_itau[1].itaasisrvcod       ,
                             g_doc_itau[1].itacliscocod       ,
                             g_doc_itau[1].itarsrcaosrvcod    ,
                             g_doc_itau[1].itaclisgmcod       ,
                             g_doc_itau[1].itaaplcanmtvcod    ,
                             g_doc_itau[1].rsrcaogrtcod       ,
                             g_doc_itau[1].asiincdat          ,
                             g_doc_itau[1].corsus             ,
                             g_doc_itau[1].seglgdnom          ,
                             g_doc_itau[1].seglgdnum          ,
                             g_doc_itau[1].segendcmpdes       ,
                             g_doc_itau[1].segbrrnom          ,
                             g_doc_itau[1].segcidnom          ,
                             g_doc_itau[1].segufdsgl          ,
                             g_doc_itau[1].segcepnum          ,
                             g_doc_itau[1].segcepcmpnum       ,
                             g_doc_itau[1].segresteldddnum    ,
                             g_doc_itau[1].segrestelnum       ,
                             g_doc_itau[1].adniclhordat       ,
                             g_doc_itau[1].itaasiarqvrsnum    ,
                             g_doc_itau[1].pcsseqnum          ,
                             g_doc_itau[1].ubbcod             ,
                             g_doc_itau[1].succod             ,
                             g_doc_itau[1].vipsegflg          ,
                             g_doc_itau[1].segmaiend          ,
                             g_doc_itau[1].itaaplitmnum       ,
                             g_doc_itau[1].itaaplitmsttcod    ,
                             g_doc_itau[1].autchsnum          ,
                             g_doc_itau[1].autplcnum          ,
                             g_doc_itau[1].autfbrnom          ,
                             g_doc_itau[1].autlnhnom          ,
                             g_doc_itau[1].autmodnom          ,
                             g_doc_itau[1].itavclcrgtipcod    ,
                             g_doc_itau[1].autfbrano          ,
                             g_doc_itau[1].autmodano          ,
                             g_doc_itau[1].autcornom          ,
                             g_doc_itau[1].autpintipdes       ,
                             g_doc_itau[1].okmflg             ,
                             g_doc_itau[1].impautflg          ,
                             g_doc_itau[1].casfrqvlr          ,
                             g_doc_itau[1].rsclclcepnum       ,
                             g_doc_itau[1].rcslclcepcmpnum    ,
                             g_doc_itau[1].porvclcod          ,
                             g_doc_itau[1].frtmdlcod          ,
                             g_doc_itau[1].vndcnlcod          ,
                             g_doc_itau[1].vcltipcod          ,
                             g_doc_itau[1].bldflg


   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Dados do Itau nao Encontrado!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_bdata013_008 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_bdata013_012

   if lr_retorno.erro = 0 then

       # Recupera Plano e Cobertura

       call bdata013_rec_cobertura_plano(g_doc_itau[1].itaasisrvcod     ,
                                         g_doc_itau[1].rsrcaogrtcod     ,
                                         g_doc_itau[1].itarsrcaosrvcod  ,
                                         g_doc_itau[1].ubbcod           )
       returning g_doc_itau[1].itacbtcod    ,
                 g_doc_itau[1].itaasiplncod ,
                 lr_retorno_aux.erro        ,
                 lr_retorno_aux.mensagem

   end if

   return lr_retorno.erro         ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function bdata013_rec_cobertura_plano(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasisrvcod    like datkitacbtintrgr.itaasisrvcod    ,
   rsrcaogrtcod    like datkitacbtintrgr.rsrcaogrtcod    ,
   itarsrcaosrvcod like datkitacbtintrgr.itarsrcaosrvcod ,
   ubbcod          like datkitacbtintrgr.ubbcod
end record

define lr_retorno record
   itacbtcod     like datkitacbtintrgr.itacbtcod    ,
   itaasiplncod  like datkitacbtintrgr.itaasiplncod ,
   erro          integer                            ,
   mensagem      char(50)
end record


initialize lr_retorno.* to null

let lr_retorno.erro = 0

   open c_bdata013_013 using lr_param.itaasisrvcod    ,
                             lr_param.rsrcaogrtcod    ,
                             lr_param.itarsrcaosrvcod ,
                             lr_param.ubbcod

   whenever error continue
   fetch c_bdata013_013 into lr_retorno.itacbtcod     ,
                             lr_retorno.itaasiplncod
   whenever error stop

   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Plano e Cobertura Nao Cadastrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_bdata013_009 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_bdata013_013

   return lr_retorno.itacbtcod     ,
          lr_retorno.itaasiplncod  ,
          lr_retorno.erro          ,
          lr_retorno.mensagem

end function

#-------------------------------------------------#                  
 function bdata013_verifica_empresarial(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  itaasiplncod     like datkitaasipln.itaasiplncod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record                                                           
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "ctc92m01_plano"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Plano e Empresarial                              
    #--------------------------------------------------------        
                                                                     
    open c_bdata013_015  using  lr_retorno.chave  ,                  
                                lr_param.itaasiplncod                
    whenever error continue                                          
    fetch c_bdata013_015 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function   

#------------------------------------------------------------
 function bdata013_recupera_produto(lr_param)                
#------------------------------------------------------------
                                                                            
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
                                                  
                                                                                                                                                       
  open c_bdata013_014 using  lr_retorno.cponom ,                            
                             lr_param.empcod   ,
                             lr_param.ramcod                            
  whenever error continue                                                   
  fetch c_bdata013_014 into lr_retorno.procod                               
  whenever error stop                                                       
                                                                                                      
                                                                            
  return lr_retorno.procod                                                           
  
end function

#======================================================================== 
 function bdata013_valida_dia_hora()
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
 function bdata013_recupera_grupo_produto()                
#========================================================================
                                                                            

define lr_retorno record                                                                                                                               
  grpprdcod  integer                                           
end record                                                                  
                                                                            
initialize lr_retorno.* to null                                             
                                                                                                              
                                                                                                                                                                                                        
  open c_bdata013_016 using  g_doc_itau[1].itaprdcod                             
                                      
  whenever error continue                                                   
  fetch c_bdata013_016 into lr_retorno.grpprdcod                              
  whenever error stop
  
  if lr_retorno.grpprdcod is null or
  	 lr_retorno.grpprdcod = ''    then
  	 	let lr_retorno.grpprdcod = 0
  end if 	 	                                                      
                                                                                                      
                                                                            
  return lr_retorno.grpprdcod 
                                                            
#========================================================================  
end function
#========================================================================
#========================================================================
function bdata013_grava_apolice_processada()
#========================================================================

define lr_retorno record
  status      char(3000),
  doctipcod  smallint    
end record

initialize lr_retorno.* to null

   let lr_retorno.doctipcod     = 999
   let mr_inconsistencia.mtvinc = 'Apolice Processada '

   if bdata013_valida_processado() then
               
          whenever error continue
          execute p_bdata013_011 using   mr_inconsistencia.empcod
                                       , lr_retorno.doctipcod
                                       , mr_inconsistencia.succod
                                       , mr_inconsistencia.ramcod
                                       , mr_inconsistencia.aplnumdig
                                       , mr_inconsistencia.itmnumdig
                                       , mr_processo2.edsnumref
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
 function bdata013_valida_processado()                
#========================================================================

define lr_retorno record  
  qtd        integer,  
  doctipcod  smallint      
end record   

  let lr_retorno.qtd = 0  
  
  let lr_retorno.doctipcod = 999 
  
                                                                                                                               
  open c_bdata013_017 using   mr_inconsistencia.empcod   
                            , lr_retorno.doctipcod
                            , mr_inconsistencia.succod
                            , mr_inconsistencia.ramcod
                            , mr_inconsistencia.aplnumdig
                            , mr_inconsistencia.itmnumdig
                            , mr_processo2.edsnumref
                            , mr_inconsistencia.viginc
                          
                                      
  whenever error continue                                                   
  fetch c_bdata013_017 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return false
  end if 	 	                                                      
                                                                                                      
  return true                                                                          
                                                            
#========================================================================  
end function
#========================================================================

#========================================================================
 function bdata013_valida_beneficio_processado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata013_020 using   mr_processo2.empcod   
                            , mr_processo2.codtipdoc
                            , mr_processo2.itaciacod
                            , mr_processo2.ramcod
                            , mr_processo2.aplnumdig
                            , mr_processo2.itmnumdig
                            , mr_processo2.edsnumref
                            , mr_processo2.srvcod 
                            , mr_processo2.codcls                            
                          
                                      
  whenever error continue                                                   
  fetch c_bdata013_020 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#========================================================================

#========================================================================
 function bdata013_valida_beneficio_inativado()                
#========================================================================

define lr_retorno record  
  qtd  integer
end record   

  let lr_retorno.qtd = 0  
                                                                                                
  open c_bdata013_021 using   mr_processo2.empcod   
                            , mr_processo2.codtipdoc
                            , mr_processo2.itaciacod
                            , mr_processo2.ramcod
                            , mr_processo2.aplnumdig
                            , mr_processo2.itmnumdig
                            , mr_processo2.edsnumref
                            , mr_processo3.srvcod 
                            , mr_processo3.codcls                            
                          
                                      
  whenever error continue                                                   
  fetch c_bdata013_021 into lr_retorno.qtd                            
  whenever error stop
  
  if lr_retorno.qtd > 0 then
  	return true
  end if 	 	                                                      
                                                                                                      
  return false                                                                        
                                                            
#========================================================================  
end function
#========================================================================


#========================================================================
function bdata013_regra_anterior()
#========================================================================

define lr_retorno record
	cont integer
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0    

  #--------------------------------------------------------
  # Verifica se a Clausula Tem Regras Antigas
  #--------------------------------------------------------

  open c_bdata013_018 using   mr_processo2.empcod      ,              
                              mr_processo2.ramcod      ,              
                              mr_processo2.clscod      ,              
                              mr_processo2.perfil      ,              
                              mr_processo2.plnclscod   ,              
                              mr_processo2.clsviginidat                    
  whenever error continue
  fetch c_bdata013_018 into   lr_retorno.cont                             
  whenever error stop
 
  if lr_retorno.cont > 0  then
     return true
  end if

  return false
#========================================================================
end function
#========================================================================

#========================================================================                                                                                                                      
function bdata013_carrega_inativacao()                                             
#========================================================================          
                                                                                   
                                                                                   
define lr_retorno record                                                           
	cont integer                                                                     
end record                                                                         
                                                                                   
initialize mr_processo3.* to null                                                  
initialize lr_retorno.* to null   


     #--------------------------------------------------------       
     # Recupera os Dados do Motor de Regras Antigo                   
     #--------------------------------------------------------       
                                                                     
     open c_bdata013_019 using   mr_processo2.empcod      ,          
                                 mr_processo2.ramcod      ,          
                                 mr_processo2.clscod      ,          
                                 mr_processo2.perfil      ,          
                                 mr_processo2.plnclscod   ,          
                                 mr_processo2.clsviginidat           
                                                                     
     foreach c_bdata013_019 into mr_processo3.plnclscod              

           #-------------------------------------------------------- 
           # Recupera os Servicos de Cada Regra                      
           #-------------------------------------------------------- 
           
           open c_bdata013_003 using mr_processo3.plnclscod
           
           foreach c_bdata013_003 into mr_processo3.srvcod                 ,
                                       mr_processo3.srvplnclscod           ,
                                       mr_processo3.codcls                 ,
                                       mr_processo3.clsnom                 ,
                                       mr_processo3.clssitflg
           
             
                 let mr_inconsistencia.srvcod = mr_processo3.srvcod
                
           
                 #------------------------------------------------------
                 # Verifica Se Tem Categoria
                 #------------------------------------------------------
           
                 open c_bdata013_005 using mr_processo3.srvplnclscod ,
                                           mr_processo2.ctgtrfcod
           
                 whenever error continue
                 fetch c_bdata013_005 into lr_retorno.cont
                 whenever error stop
               
                 if lr_retorno.cont = 0 then
                    let mr_inconsistencia.mtvinc = 'Categoria Tarifaria n�o cadastrada para o servi�o'
                    call bdata013_grava_inconsistencia()
                    continue foreach
                 end if   
               
                 
                 #------------------------------------------------------
                 # Verifica Se o Beneficio Ja foi Carregado             
                 #------------------------------------------------------
                                                                        
                 if bdata013_valida_beneficio_inativado() then         
                   	let mr_count1.proce = mr_count1.proce + 1           
                 	  let mr_total.proce  = mr_total.proce + 1            
                 	  continue foreach                                    
                 end if 
                 
                 #------------------------------------------------------                                                                   
                 # Grava Inativo           
                 #------------------------------------------------------                              
                 
                 call bdata013_grava_inativo()                                                                     
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
function bdata013_grava_inativo()
#========================================================================

define lr_retorno record
  status  char(30000)
end record

initialize lr_retorno.* to null

let mr_processo2.data_ger = today
let mr_processo3.pcmflg   = 'R' 
   
   whenever error continue
   execute p_bdata013_010 using mr_processo2.empcod
                              , mr_processo2.codprod
                              , mr_processo2.codtipdoc
                              , mr_processo2.itaciacod
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
                              , mr_processo2.ctotipcod
                              , mr_processo3.pcmflg
   whenever error continue
   
   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DA INATIVACAO DOS BENEFICIOS! '
      let mr_inconsistencia.mtvinc = m_mensagem
      call bdata013_grava_inconsistencia()
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
function bdata013_acessa_inativacao()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata008_acessa"
let lr_retorno.cpocod = 1


  open c_bdata013_007 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata013_007 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes =  "S"  then
     return true
  end if
  
  return false
#========================================================================
end function
#========================================================================        
