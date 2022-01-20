#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
# .............................................................................#
# Sistema       : CENTRAL 24 HS                                                #
# Modulo        : bdatm002                                                     #
# Analista Resp.: Nilo / Ruiz / Carla Rampazzo                                 #
# PSI           : 221635 - Agendamento de Servicos - Portal do Segurado        #
#                 Interface para o sistema Portal do Segurado.                 #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica   Origem     Alteracao                              #
# ---------- --------------- ---------- ---------------------------------------#
# 17/11/2009 Fabio Costa PSI246174  Incluir servico obter_servicos_disponiveis #
#                                   e incluir_servico_web                      #
#------------------------------------------------------------------------------#
# 05/01/2010 Alberto                Incluir servico OBTER_SALDO_PET            #
#            Jorge Modena                                                      #
#------------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo         Tratamento de Controles e Limites para     #
#                                   atendimentos de Help Desk                  #
#                                   (atendimento / presencial)                 #
#------------------------------------------------------------------------------#
# 25/09/2013 Samuel Rulli    XXXXXX   Ajuste para o redesenho Aviso de Sinistro#
#------------------------------------------------------------------------------#


#---> Dados para execucao...
#---> Fila- bdatm002.4gc DAATENDSEGURA4GLR

---> Obter Tipos de Servicos do Documento
#<REQUEST><SERVICO>OBTER_TIPOS_SERVICOS_DOCUMENTO</SERVICO><DOCUMENTO><APOLICE><SUCURSAL>1</SUCURSAL><RAMO>531</RAMO><APOLICE>103111103</APOLICE><ITEM>19</ITEM><ENDOSSO>0</ENDOSSO><MODALIDADE>0</MODALIDADE></APOLICE></DOCUMENTO><GRUPOTIPOSERVICO>PLANO BASICO</GRUPOTIPOSERVICO></REQUEST>

globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals "/homedsa/projetos/geral/globals/sg_glob2.4gl"
globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_servico    char(100)

define m_prep_sql   smallint

define m_msg        char(100)

#----------------------------------------------------------------------------#
function bdatm002_prepare()
#----------------------------------------------------------------------------#

# -> Query para selecionar itens da apólice AUTO

  define l_sql     char(400) 
  define l_srvnom  like ibpkdbspace.srvnom

  let l_sql = " select itmnumdig       "
             ,"  from abbmitem         "
             ,"  where succod    = ?   "
             ,"  and aplnumdig = ?     "
             ,"  and itmsttatu = 'A'   "
  prepare pbdatm002001 from l_sql
  declare cbdatm002001 cursor for pbdatm002001

  let l_sql = " select count(*)        "
             ,"  from abbmitem         "
             ,"  where succod    = ?   "
             ,"  and aplnumdig = ?     "
             ,"  and itmsttatu = 'A'   "
  prepare pbdatm002002 from l_sql
  declare cbdatm002002 cursor for pbdatm002002
  
  let l_sql = " select count(*)           "
             ," from datmligacao a        "
             ,",datrligapol b             "
             ," where a.lignum = b.lignum "
             ,"   and a.c24astcod = ?     "
             ,"   and a.c24funmat = ?     "
             ,"   and a.ligdat = ?        "
             ,"   and a.lighorinc = ?     "
             ,"   and b.succod = ?        "
             ,"   and b.ramcod = ?        "
             ,"   and b.aplnumdig = ?     "
             ,"   and b.itmnumdig = ?     "
  prepare pbdatm002003 from l_sql
  declare cbdatm002003 cursor for pbdatm002003
  
  let l_sql = " select cpodes    "
             ," from datkdominio "
             ," where cponom = ? "
  prepare pbdatm002004 from l_sql
  declare cbdatm002004 cursor with hold for pbdatm002004
  
  let l_sql = " select clscod      "
             ," from abbmclaus     "
             ," where succod = ?   "
             ," and aplnumdig = ?  "
             ," and itmnumdig = ?  "
             ," and dctnumseq = ?  "
             ," and clscod in ('033','33R','035','044','44R',",
                             " '046','46R','047','47R')"
   prepare pbdatm002005 from l_sql
   declare cbdatm002005 cursor with hold for pbdatm002005
   
  let l_sql = "select unique c24pbmdes "
            , "  from datkpbm          "
            , " where c24pbmcod = ?    "
  prepare pbdatm002006 from l_sql
  declare cbdatm002006 cursor with hold for pbdatm002006
  
    select srvnom
      into l_srvnom
      from porto:ibpkdbspace
     where dbpnom = "CT24HS" 
  
  let l_sql = "  insert into porto@ ", l_srvnom clipped , ":igbmparam         "
             ,"      values ('CTX34G00',                   "
             ,"        (select NVL(max(relpamseq),0)+1     "
             ,"           from porto@ ", l_srvnom clipped , ":igbmparam param "
             ,"          where relsgl = 'CTX34G00'),       "
             ,"          1,?)                              "
  prepare pbdatm002007 from l_sql 
  
  let m_prep_sql = true

end function


#---------------------------------------------------------------------------
function executeService(l_xml)
#---------------------------------------------------------------------------

 define l_xml        char(32000)
 define l_retorno    char(32000)
       ,l_docHandle  integer
       ,l_tree        char(100)
       ,l_treeparam   char(100)

 define param_xml     record
        succod        like datrligapol.succod     ,
        ramcod        like datrservapol.ramcod    ,
        aplnumdig     like datrligapol.aplnumdig  ,
        itmnumdig     like abbmdoc.itmnumdig      ,
        edsnumdig     like abamdoc.edsnumdig      ,
        rmemdlcod     like rsamseguro.rmemdlcod   ,
        grp_natz      char(12)                    ,
        c24astcod     like datmligacao.c24astcod  ,
        cidnom        like glakcid.cidnom         ,
        ufdcod        like glakcid.ufdcod         ,
        socntzdes     like datksocntz.socntzdes   ,
        rgldat        like datmsrvrgl.rgldat      ,
        rglhor        char(5)                     ,
        atdsrvnum     like datmservico.atdsrvnum  ,
        atdsrvano     like datmservico.atdsrvano  ,
        atdfnlflg     like datmservico.atdfnlflg  ,
        logtip        char(10)                    ,
        lognom        char(50)                    ,
        lognum        integer                     ,
        bairro        char(50)                    ,
        operacao      char (01)                   ,
        endzon        like datmlcl.endzon         ,
        lgdcep        like datmlcl.lgdcep         ,
        lgdcepcmp     like datmlcl.lgdcepcmp      ,
        dddcod        like datmlcl.dddcod         ,
        lcltelnum     like datmlcl.lcltelnum      ,
        lclcttnom     like datmlcl.lclcttnom      ,
        lclrefptotxt  like datmlcl.lclrefptotxt   ,
        data          date                        ,
        hora          datetime hour to minute     ,
        acao          char (03)                   ,
        srvretmtvcod  like datksrvret.srvretmtvcod,
        srvretmtvdes  like datksrvret.srvretmtvdes,
        retprsmsmflg  like datmsrvre.retprsmsmflg ,
        orrdat        like datmsrvre.orrdat       ,
        srvrglcod     like datmsrvrgl.srvrglcod   ,
        retorno       char(11)                    ,
        msmprest      char(03),
        filtro        smallint,
        endcmp        like datmlcl.endcmp             #P283688
 end record

 define param_xml_multiplos array[10] of record
        socntzcod      like datmsrvre.socntzcod
       ,espcod         like datmsrvre.espcod
       ,c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod
  end record


 define param_xml_servicos record
        socntzcod      like datmsrvre.socntzcod
       ,espcod         like datmsrvre.espcod
       ,socntzcod_1    like datmsrvre.socntzcod
       ,espcod_1       like datmsrvre.espcod
       ,socntzcod_2    like datmsrvre.socntzcod
       ,espcod_2       like datmsrvre.espcod
       ,socntzcod_3    like datmsrvre.socntzcod
       ,espcod_3       like datmsrvre.espcod
       ,socntzcod_4    like datmsrvre.socntzcod
       ,espcod_4       like datmsrvre.espcod
       ,socntzcod_5    like datmsrvre.socntzcod
       ,espcod_5       like datmsrvre.espcod
       ,socntzcod_6    like datmsrvre.socntzcod
       ,espcod_6       like datmsrvre.espcod
       ,socntzcod_7    like datmsrvre.socntzcod
       ,espcod_7       like datmsrvre.espcod
       ,socntzcod_8    like datmsrvre.socntzcod
       ,espcod_8       like datmsrvre.espcod
       ,socntzcod_9    like datmsrvre.socntzcod
       ,espcod_9       like datmsrvre.espcod
       ,socntzcod_10   like datmsrvre.socntzcod
       ,espcod_10      like datmsrvre.espcod
 end record

 define lr_retorno    record
        lgdtip        like datmlcl.lgdtip          ,
        lgdnom        like datmlcl.lgdnom          ,
        lgdnum        like datmlcl.lgdnum          ,
        lclbrrnom     like datmlcl.lclbrrnom       ,
        cidnom        like datmlcl.cidnom          ,
        ufdcod        like datmlcl.ufdcod          ,
        lclrefptotxt  like datmlcl.lclrefptotxt    ,
        endzon        like datmlcl.endzon          ,
        lgdcep        like datmlcl.lgdcep          ,
        lgdcepcmp     like datmlcl.lgdcepcmp       ,
        lclcttnom     like datmlcl.lclcttnom       ,
        dddcod        like datmlcl.dddcod          ,
        lcltelnum     like datmlcl.lcltelnum       ,
        orrdat        like datmsrvre.orrdat        ,
        socntzcod     like datmsrvre.socntzcod     ,
        espcod        like datmsrvre.espcod        ,
        c24pbmcod     like datkpbm.c24pbmcod
 end record

 define lr_aux        record
        lignum        like datmligacao.lignum
       ,c24astcod     like datmligacao.c24astcod
 end record

 define l_servico record
        srvnumtip     smallint                     ,
        solicdat      date                         ,
        solichor      datetime hour to second      ,
        c24soltipcod  like datksoltip.c24soltipcod ,
        c24solnom     like datmservico.c24solnom   ,
        c24astcod     like datkassunto.c24astcod   ,
        c24pbmcod     like datkpbm.c24pbmcod       ,
        c24pbmdes     like datkpbm.c24pbmdes       ,
        webpbmdes     like datkpbm.webpbmdes       ,
        sphpbmdes     like datkpbm.sphpbmdes       ,
        funmat        integer                      ,
        funemp        smallint                     ,
        c24paxnum     integer                      ,
        atdlibflg     like datmservico.atdlibflg   ,
        atdtip        like datmservico.atdtip      ,
        atdfnlflg     like datmservico.atdfnlflg   ,
        atdrsdflg     like datmservico.atdrsdflg   ,
        atdpvtretflg  like datmservico.atdpvtretflg,
        asitipcod     like datmservico.asitipcod   ,
        srvprlflg     like datmservico.srvprlflg   ,
        atdprinvlcod  like datmservico.atdprinvlcod,
        atdsrvorg     like datmservico.atdsrvorg   ,
        c24pbminforg  like datrsrvpbm.c24pbminforg ,
        pstcoddig     like dpaksocor.pstcoddig     ,
        atdetpcod     like datmservico.atdetpcod   ,
        ligcvntip     like datmligacao.ligcvntip   ,
        prslocflg     like datmservico.prslocflg   ,
        vclcamtip     like datmservicocmp.vclcamtip,
        vclcrgflg     like datmservicocmp.vclcrgflg,
        rmcacpflg     like datmservicocmp.rmcacpflg,
        frmflg        char(1)                      ,
        remrquflg     like datkpbm.remrquflg       ,
        vclcorcod     decimal(2,0)                 ,
        vcldes        like datmservico.vcldes      ,
        vclanomdl     like datmservico.vclanomdl   ,
        vcllicnum     like datmservico.vcllicnum   ,
        camflg        char(1)                      ,
        vclcoddig     like datmservico.vclcoddig   ,
        segnom        like gsaksegger.segnom       ,
        succod        like datrligapol.succod      ,    # Codigo Sucursal
        ramcod        like datrservapol.ramcod     ,    # Codigo Ramo
        aplnumdig     like datrligapol.aplnumdig   ,    # Numero Apolice
        itmnumdig     like datrligapol.itmnumdig   ,    # Numero do Item
        edsnumref     like datrligapol.edsnumref   ,    # Numero do Endosso
        corsus        like datmservico.corsus      ,
        cornom        like datmservico.cornom,
        atddatprg     like datmservico.atddatprg,
        atdhorprg     like datmservico.atdhorprg
 end record

 define l_ocorrencia record
        lclidttxt     like datmlcl.lclidttxt      ,
        lgdtip        like datmlcl.lgdtip         ,
        lgdnom        like datmlcl.lgdnom         ,
        lgdnum        like datmlcl.lgdnum         ,
        lclbrrnom     like datmlcl.lclbrrnom      ,
        brrnom        like datmlcl.brrnom         ,
        cidnom        like datmlcl.cidnom         ,
        ufdcod        like datmlcl.ufdcod         ,
        lclrefptotxt  like datmlcl.lclrefptotxt   ,
        endzon        like datmlcl.endzon         ,
        lgdcep        like datmlcl.lgdcep         ,
        lgdcepcmp     like datmlcl.lgdcepcmp      ,
        lclltt        like datmlcl.lclltt         ,
        lcllgt        like datmlcl.lcllgt         ,
        dddcod        like datmlcl.dddcod         ,
        lcltelnum     like datmlcl.lcltelnum      ,
        lclcttnom     like datmlcl.lclcttnom      ,
        c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
        ofnnumdig     decimal(6,0)                ,
        emeviacod     like datmemeviadpt.emeviacod
 end record

 define l_destino record
        lclidttxt     like datmlcl.lclidttxt      ,
        lgdtip        like datmlcl.lgdtip         ,
        lgdnom        like datmlcl.lgdnom         ,
        lgdnum        like datmlcl.lgdnum         ,
        lclbrrnom     like datmlcl.lclbrrnom      ,
        brrnom        like datmlcl.brrnom         ,
        cidnom        like datmlcl.cidnom         ,
        ufdcod        like datmlcl.ufdcod         ,
        lclrefptotxt  like datmlcl.lclrefptotxt   ,
        endzon        like datmlcl.endzon         ,
        lgdcep        like datmlcl.lgdcep         ,
        lgdcepcmp     like datmlcl.lgdcepcmp      ,
        lclltt        like datmlcl.lclltt         ,
        lcllgt        like datmlcl.lcllgt         ,
        dddcod        like datmlcl.dddcod         ,
        lcltelnum     like datmlcl.lcltelnum      ,
        lclcttnom     like datmlcl.lclcttnom      ,
        c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
        ofnnumdig     decimal(6,0)                ,
        emeviacod     like datmemeviadpt.emeviacod
 end record

 define l_servicocmp record
        vclcamtip    like datmservicocmp.vclcamtip, #TipoCaminhao
        vclcrcdsc    like datmservicocmp.vclcrcdsc, #DescricaoCarroceria
        vclcrgflg    like datmservicocmp.vclcrgflg, #FlagCaminhaoCarregtado
        vclcrgpso    like datmservicocmp.vclcrgpso, #PesoCaminhaoCarregtado
        sinvitflg    like datmservicocmp.sinvitflg, #FlagVitimasSinistro
        bocflg       like datmservicocmp.bocflg,    #FlagBoletimOcorrencia
        bocnum       like datmservicocmp.bocnum,    #NumeroBoletimOcorrencia
        bocemi       like datmservicocmp.bocemi,    #OrgaoEmissorBO
        vcllibflg    like datmservicocmp.vcllibflg, #FlagLiberacaoVeiculo
        roddantxt    like datmservicocmp.roddantxt, #RodasDanificadas
        rmcacpflg    like datmservicocmp.rmcacpflg, #FlagSeguradoAcompanhaRem
        sindat       like datmservicocmp.sindat,    #DataSinistro
        c24sintip    like datmservicocmp.c24sintip, #TipoSinistro
        c24sinhor    like datmservicocmp.c24sinhor, #HoraSinistro
        vicsnh       like datmservicocmp.vicsnh,    #SenhaAlarme
        sinhor       like datmservicocmp.sinhor,    #HoraOcorrenciaSinistro
        sgdirbcod    like datmservicocmp.sgdirbcod, #CodigoIRBSeguradorahaRem
        smsenvflg    like datmservicocmp.smsenvflg  #FlagEnvioSMS
 end record

 define l_cts55g00 record
        atdsrvnum  like datmservico.atdsrvnum ,
        atdsrvano  like datmservico.atdsrvano ,
        atdhorpvt  like datmservico.atdhorpvt
 end record

 define l_msgerro char(1000)
 define l_index      integer,
        l_qtd        integer,
        l_errcod     integer,
        l_errmsg     char(160),
        l_qtd_limite integer,
        l_envia      smallint,
        l_valido     smallint

 define lr_cty18g00     record
         resultado      integer
        ,mensagem       char(200)
        ,emsdat         like abamdoc.emsdat
        ,aplstt         like abamapol.aplstt
        ,vigfnl         like abamapol.vigfnl
        ,etpnumdig      like abamapol.etpnumdig
  end record

  define lr_xml     record
        succod      like datrligapol.succod     ,
        ramcod      like datrservapol.ramcod    ,
        aplnumdig   like datrligapol.aplnumdig  ,
        itmnumdig   like abbmdoc.itmnumdig
  end record


  define lr_ret_item record
         itmnumdig   like abbmdoc.itmnumdig,
         errcode     smallint
  end record

  define lr_serv    record
         atdetpcod  like datmservico.atdetpcod,
  	     atddatprg  like datmservico.atddatprg,
  	     atdhorprg  like datmservico.atdhorprg,
         atdsrvorg  like datmservico.atdsrvorg,
         assunto    like datmligacao.c24astcod
  end record

  define lr_altsrv   record
         asitipcod   like datmservico.asitipcod,
   	     prslocflg   like datmservico.prslocflg,
   	     frmflg      char(1),
   	     vclcoddig   like datmservico.vclcoddig,
   	     camflg      char(1)
  end record

  define l_cont_itm      integer
  define l_tamanho       integer
  define l_itmnumdig     char(10)
  define l_flg           smallint,
         l_val_oco       smallint,
         l_val_dst       smallint

  define l_bdatm002   record
     enviar           char (01)                  ,
     nomrazsoc        like gkpkpos.nomrazsoc     ,
     dddcod           like gkpkpos.dddcod        ,
     faxnum           like gkpkpos.faxnum        ,
     faxch1           like gfxmfax.faxch1        ,
     faxch2           like gfxmfax.faxch2
  end record

# Alberto
 define l_rqt record
        srvnumtip        char(40),
        solicdat         char(40),
        solichor         char(40),
        c24soltipcod     char(40),
        c24solnom        char(40),
        c24astcod        char(40),
        c24pbmcod        char(40),
        funmat           char(40),
        funemp           char(40),
        c24paxnum        char(40),
        atdlibflg        char(40),
        atdtip           char(40),
        atdfnlflg        char(40),
        atdrsdflg        char(40),
        atdpvtretflg     char(40),
        asitipcod        char(40),
        srvprlflg        char(40),
        atdprinvlcod     char(40),
        atdsrvorg        char(40),
        c24pbminforg     char(40),
        pstcoddig        char(40),
        atdetpcod        char(40),
        ligcvntip        char(40),
        prslocflg        char(40),
        rmcacpflg        char(40),
        frmflg           char(40),
        vclcorcod        char(40),
        vcldes           char(40),
        vclanomdl        char(40),
        vcllicnum        char(40),
        camflg           char(40),
        vclcoddig        char(40),
        segnom           char(40),
        succod           char(40),
        ramcod           char(40),
        aplnumdig        char(40),
        itmnumdig        char(40),
        edsnumref        char(40),
        corsus           char(40),
        cornom           char(40),
        atddatprg        char(40),
        atdhorprg        char(40),
        c24pbmdes        char(40),
        webpbmdes        char(40),
        sphpbmdes        char(40),
        remrquflg        char(40),
        oco_lclidttxt    char(40),
        oco_lgdtip       char(40),
        oco_lgdnom       char(40),
        oco_lgdnum       char(40),
        oco_lclbrrnom    char(40),
        oco_brrnom       char(40),
        oco_cidnom       char(40),
        oco_ufdcod       char(40),
        oco_lclrefptotxt char(40),
        oco_endzon       char(40),
        oco_lgdcep       char(40),
        oco_lgdcepcmp    char(40),
        oco_lclltt       char(40),
        oco_lcllgt       char(40),
        oco_dddcod       char(40),
        oco_lcltelnum    char(40),
        oco_lclcttnom    char(40),
        oco_c24lclpdrcod char(40),
        oco_ofnnumdig    char(40),
        oco_emeviacod    char(40),
        dst_lclidttxt    char(40),
        dst_lgdtip       char(40),
        dst_lgdnom       char(40),
        dst_lgdnum       char(40),
        dst_lclbrrnom    char(40),
        dst_brrnom       char(40),
        dst_cidnom       char(40),
        dst_ufdcod       char(40),
        dst_lclrefptotxt char(40),
        dst_endzon       char(40),
        dst_lgdcep       char(40),
        dst_lgdcepcmp    char(40),
        dst_lclltt       char(40),
        dst_lcllgt       char(40),
        dst_dddcod       char(40),
        dst_lcltelnum    char(40),
        dst_lclcttnom    char(40),
        dst_c24lclpdrcod char(40),
        dst_ofnnumdig    char(40),
        dst_emeviacod    char(40)
 end record
define xml_re record
  c24soltipcod like datmligacao.c24soltipcod   ,
  c24solnom    like datmligacao.c24solnom      ,
  c24astcod    like datkassunto.c24astcod      ,
  funmat       like isskfunc.funmat            ,
  usrtip       like isskusuario.usrtip         ,
  empcod       like isskusuario.empcod         ,
  funmatatd    like isskfunc.funmat            ,
  usrtipatd    like isskusuario.usrtip         ,
  empcodatd    like isskusuario.empcod         ,
  cgccpfnum    like gsakseg.cgccpfnum          ,
  cgcord       like gsakseg.cgcord             ,
  cgccpfdig    like gsakseg.cgccpfdig          ,
  pestip       like gsakseg.pestip             ,
  succod       like datrligapol.succod         ,
  ramcod       like datrservapol.ramcod        ,
  aplnumdig    like datrligapol.aplnumdig      ,
  itmnumdig    like datrligapol.itmnumdig      ,
  edsnumref    like datrligapol.edsnumref      ,
  prporg       like datrligprp.prporg          ,
  prpnumdig    like datrligprp.prpnumdig       ,
  corsus       like datmservico.corsus         ,
  dddcod       like datmpedvist.dddcod         ,
  ctttel       like datmreclam.ctttel          ,
  semdocto     char(01)                        ,
  segnom       like datmpedvist.segnom         ,
  hist1        like datmlighist.c24ligdsc      ,
	hist2        like datmlighist.c24ligdsc      ,
	hist3        like datmlighist.c24ligdsc      ,
	hist4        like datmlighist.c24ligdsc      ,
	hist5        like datmlighist.c24ligdsc      ,
	sinvstnum    like datmpedvist.sinvstnum      ,
	sinvstano    like datmpedvist.sinvstano      ,
	sindat       like datmpedvist.sindat         ,
	sinhor       like datmpedvist.sinhor         ,
	sinhst       like datmpedvist.sinhst         ,
	sinobs       like datmpedvist.sinobs         ,
	sinntzcod    like datrpedvistnatcob.sinntzcod,
	cbttip       like datrpedvistnatcob.cbttip   ,
	orcvlr       like datrpedvistnatcob.orcvlr   ,
  rglvstflg    like datmpedvist.rglvstflg      ,
  cornom       like datmpedvist.cornom         ,
  socntzcod    like datmsrvre.socntzcod        ,
  lgdtip       like datmpedvist.lgdtip         ,
  lgdnom       like datmpedvist.lgdnom         ,
  lgdnomcmp    like datmpedvist.lgdnomcmp      ,
  lgdnum       like datmpedvist.lgdnum         ,
  lclbrrnom    like datmlcl.lclbrrnom          ,
  endbrr       like datmpedvist.endbrr         ,
  endcid       like datmpedvist.endcid         ,
  endufd       like datmpedvist.endufd         ,
  endcep       like datmpedvist.endcep         ,
  endcepcmp    like datmpedvist.endcepcmp      ,
  lclcttnom    like datmpedvist.lclcttnom      ,
  endrefpto    like datmpedvist.endrefpto      ,
  endzon       like datmlcl.endzon             ,
  lclltt       like datmlcl.lclltt             ,
  lcllgt       like datmlcl.lcllgt             ,
  c24lclpdrcod like datmlcl.c24lclpdrcod       ,
  emeviacod    like datkemevia.emeviacod       ,
  endddd       like datmpedvist.endddd         ,
  teldes       like datmpedvist.teldes         ,
  celteldddcod like datmlcl.celteldddcod       ,
  celtelnum    like datmlcl.celtelnum          ,
  lclnumseq    like datmpedvist.lclnumseq      ,
  rmerscseq    like datmpedvist.rmerscseq      ,
  lclrsccod    like datmpedvist.lclrsccod      ,
  lclendflg    like datmpedvist.lclendflg      ,
  prslocflg    char (01)                       ,
  srrcoddig    like datmsrvacp.srrcoddig       ,
  atdprscod    like datmservico.atdprscod      ,
  socvclcod    like datmservico.socvclcod      ,
  srvretmtvcod like datmsrvre.srvretmtvcod     ,
  srvretmtvdes like datksrvret.srvretmtvdes    ,
  c24pbmcod    like datkpbm.c24pbmcod
end record

 initialize l_rqt.* to null

# Alberto

 initialize param_xml.*
          , param_xml_servicos.*
          , lr_retorno.*
          , lr_aux.*
          , param_xml_multiplos
          , l_servico.*
          , l_servicocmp.*
          , l_ocorrencia.*
          , lr_ret_item.*
          , l_destino.*
          , l_bdatm002.* to null

 initialize l_cts55g00.* to null
 initialize lr_serv.*, lr_altsrv.* to null

 let m_servico   = null
 let l_retorno   = null
 let l_docHandle = null
 let l_tree      = null
 let l_treeparam = null
 let l_errcod    = null
 let l_errmsg    = null
 let m_prep_sql  = null
 let l_envia     = null
 let l_valido    = null
 let l_flg = false
 let l_val_oco = false
 let l_val_oco = false

 let l_cont_itm  = 0

 if m_prep_sql is null or
    m_prep_sql <> true then
    call bdatm002_prepare()
 end if

 let m_msg = "Não foi localizada apólice Ativa! "
            ,"Indicar contato com Corretor de Seguro."

 set isolation to dirty read

 #---------------------------------
 # Inicializa a operacao de parse
 #---------------------------------
 # call figrc011_inicio_parse()

 #--------------------------
 # Efetua o parse do request
 #--------------------------
 let l_docHandle = figrc011_parse_bigchar()
 let l_docHandle = upshift(l_docHandle)

 let m_servico = figrc011_xpath(l_docHandle,"/REQUEST/SERVICO")


 call figrc011_debug_bigchar()

 let g_origem = 'WEB'

 display "---------------------------------------------------------------------"
 display " SERVICO EXECUTADO :", m_servico
 display "---------------------------------------------------------------------"
 case m_servico

      #------------------------------------------------------
      #---------------------- V46 ---------------------------
      #------------------------------------------------------
      when "CONSULTAR_AVISO"
      #------------------------------------------------------

         let xml_re.succod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/SUCURSAL")
         let xml_re.ramcod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/RAMO")
         let xml_re.aplnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE")
         let xml_re.itmnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ITEM")
         let xml_re.edsnumref     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ENDOSSO")
         let xml_re.prporg        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ORIGEMPROPOSTA")
         let xml_re.prpnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/NUMEROPROPOSTA")
         let xml_re.semdocto      = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/FLAG")
         let xml_re.corsus        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/SUSEPCORRETORATENDIMENTO")
         let xml_re.dddcod        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGODDD")
         let xml_re.ctttel        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROTELEFONE")
         let xml_re.cgccpfnum     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROCGCCPF")
         let xml_re.cgcord        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/ORDEMCGCCPF")
         let xml_re.cgccpfdig     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/DIGITOCGCCPF")
         let xml_re.pestip        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOPESSOA")
         let xml_re.funmatatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/MATRICULAATENDIMENTO")
         let xml_re.usrtipatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOUSUARIOATENDIMENTO")
         let xml_re.empcodatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGOEMPRESAATENDIMENTO")
         let xml_re.c24soltipcod  = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOTIPOSOLICITANTE")
         let xml_re.c24solnom     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMESOLICITANTE")
         let xml_re.c24astcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODOASSUNTO")
         let xml_re.funmat        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/MATRICULAATENDENTE")
         let xml_re.usrtip        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/TIPOUSUARIOATENDENTE")
         let xml_re.empcod        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOEMPRESAATENDENTE")
         let xml_re.segnom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMEDOSEGURADO")
         let xml_re.hist1         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA1")
         let xml_re.hist2         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA2")
         let xml_re.hist3         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA3")
         let xml_re.hist4         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA4")
         let xml_re.hist5         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA5")

         display "xml_re.succod       ...............:", xml_re.succod
         display "xml_re.ramcod       ...............:", xml_re.ramcod
         display "xml_re.aplnumdig    ...............:", xml_re.aplnumdig
         display "xml_re.itmnumdig    ...............:", xml_re.itmnumdig
         display "xml_re.edsnumref    ...............:", xml_re.edsnumref
         display "xml_re.prporg       ...............:", xml_re.prporg
         display "xml_re.prpnumdig    ...............:", xml_re.prpnumdig
         display "xml_re.semdocto     ...............:", xml_re.semdocto
         display "xml_re.corsus       ...............:", xml_re.corsus
         display "xml_re.dddcod       ...............:", xml_re.dddcod
         display "xml_re.ctttel       ...............:", xml_re.ctttel
         display "xml_re.cgccpfnum    ...............:", xml_re.cgccpfnum
         display "xml_re.cgcord       ...............:", xml_re.cgcord
         display "xml_re.cgccpfdig    ...............:", xml_re.cgccpfdig
         display "xml_re.pestip       ...............:", xml_re.pestip
         display "xml_re.funmatatd    ...............:", xml_re.funmatatd
         display "xml_re.usrtipatd    ...............:", xml_re.usrtipatd
         display "xml_re.empcodatd    ...............:", xml_re.empcodatd
         display "xml_re.c24soltipcod ...............:", xml_re.c24soltipcod
         display "xml_re.c24solnom    ...............:", xml_re.c24solnom
         display "xml_re.c24astcod    ...............:", xml_re.c24astcod
         display "xml_re.funmat       ...............:", xml_re.funmat
         display "xml_re.usrtip       ...............:", xml_re.usrtip
         display "xml_re.empcod       ...............:", xml_re.empcod
         display "xml_re.segnom       ...............:", xml_re.segnom
         display "xml_re.hist1        ...............:", xml_re.hist1
         display "xml_re.hist2        ...............:", xml_re.hist2
         display "xml_re.hist3        ...............:", xml_re.hist3
         display "xml_re.hist4        ...............:", xml_re.hist4
         display "xml_re.hist5        ...............:", xml_re.hist5
         display ""
         display "============================================================="
         call bdatm002_consultar_aviso_re(xml_re.c24soltipcod,
                                          xml_re.c24solnom   ,
                                          xml_re.c24astcod   ,
                                          xml_re.funmat      ,
                                          xml_re.usrtip      ,
                                          xml_re.empcod      ,
                                          xml_re.funmatatd   ,
                                          xml_re.usrtipatd   ,
                                          xml_re.empcodatd   ,
                                          xml_re.cgccpfnum   ,
                                          xml_re.cgcord      ,
                                          xml_re.cgccpfdig   ,
                                          xml_re.pestip      ,
                                          xml_re.succod      ,
                                          xml_re.ramcod      ,
                                          xml_re.aplnumdig   ,
                                          xml_re.itmnumdig   ,
                                          xml_re.edsnumref   ,
                                          xml_re.prporg      ,
                                          xml_re.prpnumdig   ,
                                          xml_re.corsus      ,
                                          xml_re.dddcod      ,
                                          xml_re.ctttel      ,
                                          xml_re.semdocto    ,
                                          xml_re.segnom      ,
                                          xml_re.hist1       ,
                                          xml_re.hist2       ,
                                          xml_re.hist3       ,
                                          xml_re.hist4       ,
                                          xml_re.hist5       )
        returning l_retorno
        return    l_retorno

      #------------------------------------------------------
      #---------------------- V12 ---------------------------
      #------------------------------------------------------
      when "INCLUIR_AVISO"
      #------------------------------------------------------

         let xml_re.succod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/SUCURSAL")
         let xml_re.ramcod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/RAMO")
         let xml_re.aplnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE")
         let xml_re.itmnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ITEM")
         let xml_re.edsnumref     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ENDOSSO")
         let xml_re.prporg        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ORIGEMPROPOSTA")
         let xml_re.prpnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/NUMEROPROPOSTA")
         let xml_re.semdocto      = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/FLAG")
         let xml_re.corsus        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/SUSEPCORRETORATENDIMENTO")
         let xml_re.dddcod        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGODDD")
         let xml_re.ctttel        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROTELEFONE")
         let xml_re.cgccpfnum     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROCGCCPF")
         let xml_re.cgcord        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/ORDEMCGCCPF")
         let xml_re.cgccpfdig     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/DIGITOCGCCPF")
         let xml_re.pestip        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOPESSOA")
         let xml_re.funmatatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/MATRICULAATENDIMENTO")
         let xml_re.usrtipatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOUSUARIOATENDIMENTO")
         let xml_re.empcodatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGOEMPRESAATENDIMENTO")
         let xml_re.c24soltipcod  = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOTIPOSOLICITANTE")
         let xml_re.c24solnom     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMESOLICITANTE")
         let xml_re.c24astcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODOASSUNTO")
         let xml_re.funmat        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/MATRICULAATENDENTE")
         let xml_re.usrtip        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/TIPOUSUARIOATENDENTE")
         let xml_re.empcod        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOEMPRESAATENDENTE")
         let xml_re.segnom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMEDOSEGURADO")
         let xml_re.sinvstnum     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/NUMEROVISTORIA")
         let xml_re.sinvstano     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/ANOVISTORIA")
         let xml_re.sindat        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/DATA")
         let xml_re.sinhor        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HORA")
         let xml_re.sinhst        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HISTORICO")
         let xml_re.sinobs        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/OBSERVACOES")
         let xml_re.sinntzcod     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/CODIGODANATUREZA")
         let xml_re.cbttip        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/TIPODECOBERTURA")
         let xml_re.orcvlr        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/VALORORCAMENTO")
         let xml_re.rglvstflg     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/FLAGREGULADORVISTORIA")
         let xml_re.cornom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMECORRETOR")
         let xml_re.lgdtip        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/TIPOLOGRADOURO")
         let xml_re.lgdnom        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NOMELOGRADOURO")
         let xml_re.lgdnomcmp     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/COMPLEMENTO")
         let xml_re.lgdnum        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMERO")
         let xml_re.lclbrrnom     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/BAIRRO")
         let xml_re.endbrr        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/SUBBAIRRO")
         let xml_re.endcid        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CIDADE")
         let xml_re.endufd        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/UF")
         let xml_re.endcep        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CEP")
         let xml_re.endcepcmp     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/COMPLEMENTOCEP")
         let xml_re.lclcttnom     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NOMEDOCONTATOLOCAL")
         let xml_re.endrefpto     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/PONTODEREFERENCIA")
         let xml_re.endzon        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/ZONA")
         let xml_re.lclltt        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/LATITUDE")
         let xml_re.lcllgt        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/LONGITUDE")
         let xml_re.c24lclpdrcod  = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGOPADRAOLOCAL")
         let xml_re.emeviacod     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODAVIAEMERGENCIAL")
         let xml_re.endddd        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODDDRESIDENCIA")
         let xml_re.teldes        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMEROTELEFONERESIDENCIA")
         let xml_re.celteldddcod  = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODDDCELULAR")
         let xml_re.celtelnum     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMEROTELEFONECELULAR")
         let xml_re.lclnumseq     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/SEQUENCIADOLOCALRISCO")
         let xml_re.rmerscseq     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/SEQUENCIARISCORE")
         let xml_re.lclrsccod     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/CODIGO")
         let xml_re.lclendflg     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/FLAGENDERECO")
         let xml_re.hist1         = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HISTORICO")   #"/REQUEST/HISTORICO/LINHA1")
         let xml_re.hist2         = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/OBSERVACOES") #"/REQUEST/HISTORICO/LINHA2")
         let xml_re.hist3         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA3")
         let xml_re.hist4         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA4")
         let xml_re.hist5         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA5")

         #___ AJUSTE PARA VALIDAR O NOME DO ATENDENTE ________________________#
	 if  xml_re.c24solnom is null then

	     display "___ENTROU NO IF DO NOME ATENDENTE___"
	     let xml_re.usrtipatd = "F"
	     let xml_re.empcodatd = 1
	     let xml_re.funmatatd = 809365
             let xml_re.c24solnom = "Novo aviso WEB" clipped
         end if

         if  xml_re.segnom is null then
	     let xml_re.segnom = "TESTE" clipped
	     let xml_re.funmat = 809365
	 end if

         display "xml_re.succod        ...............:", xml_re.succod
         display "xml_re.ramcod        ...............:", xml_re.ramcod
         display "xml_re.aplnumdig     ...............:", xml_re.aplnumdig
         display "xml_re.itmnumdig     ...............:", xml_re.itmnumdig
         display "xml_re.edsnumref     ...............:", xml_re.edsnumref
         display "xml_re.prporg        ...............:", xml_re.prporg
         display "xml_re.prpnumdig     ...............:", xml_re.prpnumdig
         display "xml_re.semdocto      ...............:", xml_re.semdocto
         display "xml_re.corsus        ...............:", xml_re.corsus
         display "xml_re.dddcod        ...............:", xml_re.dddcod
         display "xml_re.ctttel        ...............:", xml_re.ctttel
         display "xml_re.cgccpfnum     ...............:", xml_re.cgccpfnum
         display "xml_re.cgcord        ...............:", xml_re.cgcord
         display "xml_re.cgccpfdig     ...............:", xml_re.cgccpfdig
         display "xml_re.pestip        ...............:", xml_re.pestip
         display "xml_re.funmatatd     ...............:", xml_re.funmatatd
         display "xml_re.usrtipatd     ...............:", xml_re.usrtipatd
         display "xml_re.empcodatd     ...............:", xml_re.empcodatd
         display "xml_re.c24soltipcod  ...............:", xml_re.c24soltipcod
         display "xml_re.c24solnom     ...............:", xml_re.c24solnom
         display "xml_re.c24astcod     ...............:", xml_re.c24astcod
         display "xml_re.funmat        ...............:", xml_re.funmat
         display "xml_re.usrtip        ...............:", xml_re.usrtip
         display "xml_re.empcod        ...............:", xml_re.empcod
         display "xml_re.segnom        ...............:", xml_re.segnom
         display "xml_re.sinvstnum     ...............:", xml_re.sinvstnum
         display "xml_re.sinvstano     ...............:", xml_re.sinvstano
         display "xml_re.sindat        ...............:", xml_re.sindat
         display "xml_re.sinhor        ...............:", xml_re.sinhor
         display "xml_re.sinhst        ...............:", xml_re.sinhst
         display "xml_re.sinobs        ...............:", xml_re.sinobs
         display "xml_re.sinntzcod     ...............:", xml_re.sinntzcod
         display "xml_re.cbttip        ...............:", xml_re.cbttip
         display "xml_re.orcvlr        ...............:", xml_re.orcvlr
         display "xml_re.rglvstflg     ...............:", xml_re.rglvstflg
         display "xml_re.cornom        ...............:", xml_re.cornom
         display "xml_re.lgdtip        ...............:", xml_re.lgdtip
         display "xml_re.lgdnom        ...............:", xml_re.lgdnom
         display "xml_re.lgdnomcmp     ...............:", xml_re.lgdnomcmp
         display "xml_re.lgdnum        ...............:", xml_re.lgdnum
         display "xml_re.lclbrrnom     ...............:", xml_re.lclbrrnom
         display "xml_re.endbrr        ...............:", xml_re.endbrr
         display "xml_re.endcid        ...............:", xml_re.endcid
         display "xml_re.endufd        ...............:", xml_re.endufd
         display "xml_re.endcep        ...............:", xml_re.endcep
         display "xml_re.endcepcmp     ...............:", xml_re.endcepcmp
         display "xml_re.lclcttnom     ...............:", xml_re.lclcttnom
         display "xml_re.endrefpto     ...............:", xml_re.endrefpto
         display "xml_re.endzon        ...............:", xml_re.endzon
         display "xml_re.lclltt        ...............:", xml_re.lclltt
         display "xml_re.lcllgt        ...............:", xml_re.lcllgt
         display "xml_re.c24lclpdrcod  ...............:", xml_re.c24lclpdrcod
         display "xml_re.emeviacod     ...............:", xml_re.emeviacod
         display "xml_re.endddd        ...............:", xml_re.endddd
         display "xml_re.teldes        ...............:", xml_re.teldes
         display "xml_re.celteldddcod  ...............:", xml_re.celteldddcod
         display "xml_re.celtelnum     ...............:", xml_re.celtelnum
         display "xml_re.lclnumseq     ...............:", xml_re.lclnumseq
         display "xml_re.rmerscseq     ...............:", xml_re.rmerscseq
         display "xml_re.lclrsccod     ...............:", xml_re.lclrsccod
         display "xml_re.lclendflg     ...............:", xml_re.lclendflg
         display "xml_re.hist1         ...............:", xml_re.hist1
         display "xml_re.hist2         ...............:", xml_re.hist2
         display "xml_re.hist3         ...............:", xml_re.hist3
         display "xml_re.hist4         ...............:", xml_re.hist4
         display "xml_re.hist5         ...............:", xml_re.hist5
         display ""
         display "============================================================="
         call bdatm002_incluir_aviso_re(xml_re.c24soltipcod,
                                        xml_re.c24solnom   ,
                                        xml_re.c24astcod   ,
                                        xml_re.funmat      ,
                                        xml_re.usrtip      ,
                                        xml_re.empcod      ,
                                        xml_re.funmatatd   ,
                                        xml_re.usrtipatd   ,
                                        xml_re.empcodatd   ,
                                        xml_re.cgccpfnum   ,
                                        xml_re.cgcord      ,
                                        xml_re.cgccpfdig   ,
                                        xml_re.pestip      ,
                                        xml_re.succod      ,
                                        xml_re.ramcod      ,
                                        xml_re.aplnumdig   ,
                                        xml_re.itmnumdig   ,
                                        xml_re.edsnumref   ,
                                        xml_re.prporg      ,
                                        xml_re.prpnumdig   ,
                                        xml_re.corsus      ,
                                        xml_re.dddcod      ,
                                        xml_re.ctttel      ,
                                        xml_re.semdocto    ,
                                        xml_re.segnom      ,
                                        xml_re.sinvstnum   ,
                                        xml_re.sinvstano   ,
                                        xml_re.sindat      ,
                                        xml_re.sinhor      ,
                                        xml_re.sinhst      ,
                                        xml_re.sinobs      ,
                                        xml_re.sinntzcod   ,
                                        xml_re.cbttip      ,
                                        xml_re.orcvlr      ,
                                        xml_re.rglvstflg   ,
                                        xml_re.cornom      ,
                                        xml_re.lgdtip      ,
                                        xml_re.lgdnom      ,
                                        xml_re.lgdnomcmp   ,
                                        xml_re.lgdnum      ,
                                        xml_re.lclbrrnom   ,
                                        xml_re.endbrr      ,
                                        xml_re.endcid      ,
                                        xml_re.endufd      ,
                                        xml_re.endcep      ,
                                        xml_re.endcepcmp   ,
                                        xml_re.lclcttnom   ,
                                        xml_re.endrefpto   ,
                                        xml_re.endzon      ,
                                        xml_re.lclltt      ,
                                        xml_re.lcllgt      ,
                                        xml_re.c24lclpdrcod,
                                        xml_re.emeviacod   ,
                                        xml_re.endddd      ,
                                        xml_re.teldes      ,
                                        xml_re.celteldddcod,
                                        xml_re.celtelnum   ,
                                        xml_re.lclnumseq   ,
                                        xml_re.rmerscseq   ,
                                        xml_re.lclrsccod   ,
                                        xml_re.lclendflg   ,
                                        xml_re.hist1       ,
                                        xml_re.hist2       ,
                                        xml_re.hist3       ,
                                        xml_re.hist4       ,
                                        xml_re.hist5       )
        returning l_retorno
        return    l_retorno

      #------------------------------------------------------
      #---------------------- P10 ---------------------------
      #------------------------------------------------------
      when "GERAR_SERVICO_RE"
      #------------------------------------------------------

         let xml_re.succod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/SUCURSAL")
         let xml_re.ramcod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/RAMO")
         let xml_re.aplnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE")
         let xml_re.itmnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ITEM")
         let xml_re.edsnumref     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ENDOSSO")
         let xml_re.prporg        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ORIGEMPROPOSTA")
         let xml_re.prpnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/NUMEROPROPOSTA")
         let xml_re.semdocto      = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/FLAG")
         let xml_re.corsus        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/SUSEPCORRETORATENDIMENTO")
         let xml_re.dddcod        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGODDD")
         let xml_re.ctttel        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROTELEFONE")
         let xml_re.cgccpfnum     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROCGCCPF")
         let xml_re.cgcord        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/ORDEMCGCCPF")
         let xml_re.cgccpfdig     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/DIGITOCGCCPF")
         let xml_re.pestip        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOPESSOA")
         let xml_re.funmatatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/MATRICULAATENDIMENTO")
         let xml_re.usrtipatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOUSUARIOATENDIMENTO")
         let xml_re.empcodatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGOEMPRESAATENDIMENTO")
         let xml_re.c24soltipcod  = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOTIPOSOLICITANTE")
         let xml_re.c24solnom     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMESOLICITANTE")
         let xml_re.c24astcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODOASSUNTO")
         let xml_re.funmat        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/MATRICULAATENDENTE")
         let xml_re.usrtip        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/TIPOUSUARIOATENDENTE")
         let xml_re.empcod        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOEMPRESAATENDENTE")
         let xml_re.segnom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMEDOSEGURADO")
         let xml_re.sinvstnum     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/NUMEROVISTORIA")
         let xml_re.sinvstano     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/ANOVISTORIA")
         let xml_re.sindat        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/DATA")
         let xml_re.sinhor        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HORA")
         let xml_re.sinhst        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HISTORICO")
         let xml_re.sinobs        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/OBSERVACOES")
         let xml_re.sinntzcod     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/CODIGODANATUREZA")
         let xml_re.cbttip        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/TIPODECOBERTURA")
         let xml_re.orcvlr        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/VALORORCAMENTO")
         let xml_re.rglvstflg     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/FLAGREGULADORVISTORIA")
         let xml_re.cornom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMECORRETOR")
         let xml_re.socntzcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGONATUREZASOCORRO")
         let xml_re.c24pbmcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/PROBLEMA")
         let xml_re.lgdtip        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/TIPOLOGRADOURO")
         let xml_re.lgdnom        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NOMELOGRADOURO")
         let xml_re.lgdnomcmp     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/COMPLEMENTO")
         let xml_re.lgdnum        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMERO")
         let xml_re.lclbrrnom     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/BAIRRO")
         let xml_re.endbrr        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/SUBBAIRRO")
         let xml_re.endcid        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CIDADE")
         let xml_re.endufd        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/UF")
         let xml_re.endcep        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CEP")
         let xml_re.endcepcmp     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/COMPLEMENTOCEP")
         let xml_re.lclcttnom     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NOMEDOCONTATOLOCAL")
         let xml_re.endrefpto     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/PONTODEREFERENCIA")
         let xml_re.endzon        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/ZONA")
         let xml_re.lclltt        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/LATITUDE")
         let xml_re.lcllgt        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/LONGITUDE")
         let xml_re.c24lclpdrcod  = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGOPADRAOLOCAL")
         let xml_re.emeviacod     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODAVIAEMERGENCIAL")
         let xml_re.endddd        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODDDRESIDENCIA")
         let xml_re.teldes        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMEROTELEFONERESIDENCIA")
         let xml_re.celteldddcod  = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODDDCELULAR")
         let xml_re.celtelnum     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMEROTELEFONECELULAR")
         let xml_re.lclnumseq     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/SEQUENCIADOLOCALRISCO")
         let xml_re.rmerscseq     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/SEQUENCIARISCORE")
         let xml_re.lclrsccod     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/CODIGO")
         let xml_re.lclendflg     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/FLAGENDERECO")
         let xml_re.prslocflg     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/FLAGPRESTADORNOLOCAL")
         let xml_re.srrcoddig     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODIGITODOSOCORRISTA")
         let xml_re.atdprscod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODOPRESTADOR")
         let xml_re.socvclcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODOVEICULOSOCORRO")
         let xml_re.srvretmtvcod  = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOMOTIVORETORNO")
         let xml_re.srvretmtvdes  = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/DESCRICAOMOTIVORETORNO")
         let xml_re.hist2         = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HISTORICO")   # "/REQUEST/HISTORICO/LINHA2")
         let xml_re.hist3         = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/OBSERVACOES") # "/REQUEST/HISTORICO/LINHA3")
         let xml_re.hist4         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA4")
         let xml_re.hist5         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA5")

         #___ RETIRA ESPACO EM BRANCO _____________________________#
         #call bdatm002_valida_string(lr_socntzcod)
         #     returning xml_re.socntzcod
         let  l_rqt.c24pbmdes = null

         call bdatm002_de_para(xml_re.c24pbmcod)
              returning l_rqt.c24pbmdes

         display "xml_re.succod        ............:", xml_re.succod
         display "xml_re.ramcod        ............:", xml_re.ramcod
         display "xml_re.aplnumdig     ............:", xml_re.aplnumdig
         display "xml_re.itmnumdig     ............:", xml_re.itmnumdig
         display "xml_re.edsnumref     ............:", xml_re.edsnumref
         display "xml_re.prporg        ............:", xml_re.prporg
         display "xml_re.prpnumdig     ............:", xml_re.prpnumdig
         display "xml_re.semdocto      ............:", xml_re.semdocto
         display "xml_re.corsus        ............:", xml_re.corsus
         display "xml_re.dddcod        ............:", xml_re.dddcod
         display "xml_re.ctttel        ............:", xml_re.ctttel
         display "xml_re.cgccpfnum     ............:", xml_re.cgccpfnum
         display "xml_re.cgcord        ............:", xml_re.cgcord
         display "xml_re.cgccpfdig     ............:", xml_re.cgccpfdig
         display "xml_re.pestip        ............:", xml_re.pestip
         display "xml_re.funmatatd     ............:", xml_re.funmatatd
         display "xml_re.usrtipatd     ............:", xml_re.usrtipatd
         display "xml_re.empcodatd     ............:", xml_re.empcodatd
         display "xml_re.c24soltipcod  ............:", xml_re.c24soltipcod
         display "xml_re.c24solnom     ............:", xml_re.c24solnom
         display "xml_re.c24astcod     ............:", xml_re.c24astcod
         display "xml_re.funmat        ............:", xml_re.funmat
         display "xml_re.usrtip        ............:", xml_re.usrtip
         display "xml_re.empcod        ............:", xml_re.empcod
         display "xml_re.segnom        ............:", xml_re.segnom
         display "xml_re.sinvstnum     ............:", xml_re.sinvstnum
         display "xml_re.sinvstano     ............:", xml_re.sinvstano
         display "xml_re.sindat        ............:", xml_re.sindat
         display "xml_re.sinhor        ............:", xml_re.sinhor
         display "xml_re.sinhst        ............:", xml_re.sinhst
         display "xml_re.sinobs        ............:", xml_re.sinobs
         display "xml_re.sinntzcod     ............:", xml_re.sinntzcod
         display "xml_re.cbttip        ............:", xml_re.cbttip
         display "xml_re.orcvlr        ............:", xml_re.orcvlr
         display "xml_re.rglvstflg     ............:", xml_re.rglvstflg
         display "xml_re.cornom        ............:", xml_re.cornom
         display "xml_re.c24pbmcod     ............:", xml_re.c24pbmcod
         display "xml_re.lgdtip        ............:", xml_re.lgdtip
         display "xml_re.lgdnom        ............:", xml_re.lgdnom
         display "xml_re.lgdnomcmp     ............:", xml_re.lgdnomcmp
         display "xml_re.lgdnum        ............:", xml_re.lgdnum
         display "xml_re.lclbrrnom     ............:", xml_re.lclbrrnom
         display "xml_re.endbrr        ............:", xml_re.endbrr
         display "xml_re.endcid        ............:", xml_re.endcid
         display "xml_re.endufd        ............:", xml_re.endufd
         display "xml_re.endcep        ............:", xml_re.endcep
         display "xml_re.endcepcmp     ............:", xml_re.endcepcmp
         display "xml_re.lclcttnom     ............:", xml_re.lclcttnom
         display "xml_re.endrefpto     ............:", xml_re.endrefpto
         display "xml_re.endzon        ............:", xml_re.endzon
         display "xml_re.lclltt        ............:", xml_re.lclltt
         display "xml_re.lcllgt        ............:", xml_re.lcllgt
         display "xml_re.c24lclpdrcod  ............:", xml_re.c24lclpdrcod
         display "xml_re.emeviacod     ............:", xml_re.emeviacod
         display "xml_re.endddd        ............:", xml_re.endddd
         display "xml_re.teldes        ............:", xml_re.teldes
         display "xml_re.celteldddcod  ............:", xml_re.celteldddcod
         display "xml_re.celtelnum     ............:", xml_re.celtelnum
         display "xml_re.lclnumseq     ............:", xml_re.lclnumseq
         display "xml_re.rmerscseq     ............:", xml_re.rmerscseq
         display "xml_re.lclrsccod     ............:", xml_re.lclrsccod
         display "xml_re.lclendflg     ............:", xml_re.lclendflg
         display "xml_re.prslocflg     ............:", xml_re.prslocflg
         display "xml_re.srrcoddig     ............:", xml_re.srrcoddig
         display "xml_re.atdprscod     ............:", xml_re.atdprscod
         display "xml_re.socvclcod     ............:", xml_re.socvclcod
         display "xml_re.srvretmtvcod  ............:", xml_re.srvretmtvcod
         display "xml_re.srvretmtvdes  ............:", xml_re.srvretmtvdes
         display "xml_re.hist2         ............:", xml_re.hist2
         display "xml_re.hist3         ............:", xml_re.hist3
         display "xml_re.hist4         ............:", xml_re.hist4
         display "xml_re.hist5         ............:", xml_re.hist5
         display "l_rqt.c24pbmdes      ............:", l_rqt.c24pbmdes
         display ""
         display "============================================================="

         call bdatm002_gerar_servico_re(xml_re.c24soltipcod,
                                        xml_re.c24solnom   ,
                                        xml_re.c24astcod   ,
                                        xml_re.funmat      ,
                                        xml_re.usrtip      ,
                                        xml_re.empcod      ,
                                        xml_re.funmatatd   ,
                                        xml_re.usrtipatd   ,
                                        xml_re.empcodatd   ,
                                        xml_re.cgccpfnum   ,
                                        xml_re.cgcord      ,
                                        xml_re.cgccpfdig   ,
                                        xml_re.pestip      ,
                                        xml_re.succod      ,
                                        xml_re.ramcod      ,
                                        xml_re.aplnumdig   ,
                                        xml_re.itmnumdig   ,
                                        xml_re.edsnumref   ,
                                        xml_re.prporg      ,
                                        xml_re.prpnumdig   ,
                                        xml_re.corsus      ,
                                        xml_re.dddcod      ,
                                        xml_re.ctttel      ,
                                        xml_re.semdocto    ,
                                        xml_re.segnom      ,
                                        xml_re.sinvstnum   ,
                                        xml_re.sinvstano   ,
                                        xml_re.sindat      ,
                                        xml_re.sinhor      ,
                                        xml_re.sinhst      ,
                                        xml_re.sinobs      ,
                                        xml_re.sinntzcod   ,
                                        xml_re.cbttip      ,
                                        xml_re.orcvlr      ,
                                        xml_re.rglvstflg   ,
                                        xml_re.cornom      ,
                                        xml_re.socntzcod   ,
                                        xml_re.lgdtip      ,
                                        xml_re.lgdnom      ,
                                        xml_re.lgdnomcmp   ,
                                        xml_re.lgdnum      ,
                                        xml_re.lclbrrnom   ,
                                        xml_re.endbrr      ,
                                        xml_re.endcid      ,
                                        xml_re.endufd      ,
                                        xml_re.endcep      ,
                                        xml_re.endcepcmp   ,
                                        xml_re.lclcttnom   ,
                                        xml_re.endrefpto   ,
                                        xml_re.endzon      ,
                                        xml_re.lclltt      ,
                                        xml_re.lcllgt      ,
                                        xml_re.c24lclpdrcod,
                                        xml_re.emeviacod   ,
                                        xml_re.endddd      ,
                                        xml_re.teldes      ,
                                        xml_re.celteldddcod,
                                        xml_re.celtelnum   ,
                                        xml_re.lclnumseq   ,
                                        xml_re.rmerscseq   ,
                                        xml_re.hist1       ,
                                        xml_re.hist2       ,
                                        xml_re.hist3       ,
                                        xml_re.hist4       ,
                                        xml_re.hist5       ,
                                        xml_re.lclrsccod   ,
                                        xml_re.lclendflg   ,
                                        xml_re.prslocflg   ,
                                        xml_re.srrcoddig   ,
                                        xml_re.atdprscod   ,
                                        xml_re.socvclcod   ,
                                        xml_re.srvretmtvcod,
                                        xml_re.srvretmtvdes,
                                        xml_re.c24pbmcod   ,
                                        l_rqt.c24pbmdes)
        returning l_retorno
        return    l_retorno

      #------------------------------------------------------
      #---------------------- V01 ---------------------------
      #------------------------------------------------------
      when "ALTERAR_AVISO"
      #------------------------------------------------------

         let xml_re.succod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/SUCURSAL")
         let xml_re.ramcod        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/RAMO")
         let xml_re.aplnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE")
         let xml_re.itmnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ITEM")
         let xml_re.edsnumref     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ENDOSSO")
         let xml_re.prporg        = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/ORIGEMPROPOSTA")
         let xml_re.prpnumdig     = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/NUMEROPROPOSTA")
         let xml_re.semdocto      = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/FLAG")
         let xml_re.corsus        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/SUSEPCORRETORATENDIMENTO")
         let xml_re.dddcod        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGODDD")
         let xml_re.ctttel        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROTELEFONE")
         let xml_re.cgccpfnum     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/NUMEROCGCCPF")
         let xml_re.cgcord        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/ORDEMCGCCPF")
         let xml_re.cgccpfdig     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/DIGITOCGCCPF")
         let xml_re.pestip        = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOPESSOA")
         let xml_re.funmatatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/MATRICULAATENDIMENTO")
         let xml_re.usrtipatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/TIPOUSUARIOATENDIMENTO")
         let xml_re.empcodatd     = figrc011_xpath(l_docHandle,"/REQUEST/SEMDOCUMENTO/CODIGOEMPRESAATENDIMENTO")
         let xml_re.c24soltipcod  = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOTIPOSOLICITANTE")
         let xml_re.c24solnom     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMESOLICITANTE")
         let xml_re.c24astcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGODOASSUNTO")
         let xml_re.funmat        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/MATRICULAATENDENTE")
         let xml_re.usrtip        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/TIPOUSUARIOATENDENTE")
         let xml_re.empcod        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGOEMPRESAATENDENTE")
         let xml_re.segnom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMEDOSEGURADO")
         let xml_re.sinvstnum     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/NUMEROVISTORIA")
         let xml_re.sinvstano     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/ANOVISTORIA")
         let xml_re.sindat        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/DATA")
         let xml_re.sinhor        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HORA")
         let xml_re.sinhst        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/HISTORICO")
         let xml_re.sinobs        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/OBSERVACOES")
         let xml_re.sinntzcod     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/CODIGODANATUREZA")
         let xml_re.cbttip        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/TIPODECOBERTURA")
         let xml_re.orcvlr        = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/VALORORCAMENTO")
         let xml_re.rglvstflg     = figrc011_xpath(l_docHandle,"/REQUEST/SINISTRO/FLAGREGULADORVISTORIA")
         let xml_re.cornom        = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/NOMECORRETOR")
         let xml_re.socntzcod     = figrc011_xpath(l_docHandle,"/REQUEST/ATENDIMENTO/CODIGONATUREZASOCORRO")
         let xml_re.lgdtip        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/TIPOLOGRADOURO")
         let xml_re.lgdnom        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NOMELOGRADOURO")
         let xml_re.lgdnomcmp     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/COMPLEMENTO")
         let xml_re.lgdnum        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMERO")
         let xml_re.lclbrrnom     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/BAIRRO")
         let xml_re.endbrr        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/SUBBAIRRO")
         let xml_re.endcid        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CIDADE")
         let xml_re.endufd        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/UF")
         let xml_re.endcep        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CEP")
         let xml_re.endcepcmp     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/COMPLEMENTOCEP")
         let xml_re.lclcttnom     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NOMEDOCONTATOLOCAL")
         let xml_re.endrefpto     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/PONTODEREFERENCIA")
         let xml_re.endzon        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/ZONA")
         let xml_re.lclltt        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/LATITUDE")
         let xml_re.lcllgt        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/LONGITUDE")
         let xml_re.c24lclpdrcod  = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGOPADRAOLOCAL")
         let xml_re.emeviacod     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODAVIAEMERGENCIAL")
         let xml_re.endddd        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODDDRESIDENCIA")
         let xml_re.teldes        = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMEROTELEFONERESIDENCIA")
         let xml_re.celteldddcod  = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/CODIGODDDCELULAR")
         let xml_re.celtelnum     = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/NUMEROTELEFONECELULAR")
         let xml_re.lclnumseq     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/SEQUENCIADOLOCALRISCO")
         let xml_re.rmerscseq     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/SEQUENCIARISCORE")
         let xml_re.lclrsccod     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/CODIGO")
         let xml_re.lclendflg     = figrc011_xpath(l_docHandle,"/REQUEST/LOCALRISCO/FLAGENDERECO")
         let xml_re.hist1         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA1")
         let xml_re.hist2         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA2")
         let xml_re.hist3         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA3")
         let xml_re.hist4         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA4")
         let xml_re.hist5         = figrc011_xpath(l_docHandle,"/REQUEST/HISTORICO/LINHA5")

         display "xml_re.succod        ..............:", xml_re.succod
         display "xml_re.ramcod        ..............:", xml_re.ramcod
         display "xml_re.aplnumdig     ..............:", xml_re.aplnumdig
         display "xml_re.itmnumdig     ..............:", xml_re.itmnumdig
         display "xml_re.edsnumref     ..............:", xml_re.edsnumref
         display "xml_re.prporg        ..............:", xml_re.prporg
         display "xml_re.prpnumdig     ..............:", xml_re.prpnumdig
         display "xml_re.semdocto      ..............:", xml_re.semdocto
         display "xml_re.corsus        ..............:", xml_re.corsus
         display "xml_re.dddcod        ..............:", xml_re.dddcod
         display "xml_re.ctttel        ..............:", xml_re.ctttel
         display "xml_re.cgccpfnum     ..............:", xml_re.cgccpfnum
         display "xml_re.cgcord        ..............:", xml_re.cgcord
         display "xml_re.cgccpfdig     ..............:", xml_re.cgccpfdig
         display "xml_re.pestip        ..............:", xml_re.pestip
         display "xml_re.funmatatd     ..............:", xml_re.funmatatd
         display "xml_re.usrtipatd     ..............:", xml_re.usrtipatd
         display "xml_re.empcodatd     ..............:", xml_re.empcodatd
         display "xml_re.c24soltipcod  ..............:", xml_re.c24soltipcod
         display "xml_re.c24solnom     ..............:", xml_re.c24solnom
         display "xml_re.c24astcod     ..............:", xml_re.c24astcod
         display "xml_re.funmat        ..............:", xml_re.funmat
         display "xml_re.usrtip        ..............:", xml_re.usrtip
         display "xml_re.empcod        ..............:", xml_re.empcod
         display "xml_re.segnom        ..............:", xml_re.segnom
         display "xml_re.sinvstnum     ..............:", xml_re.sinvstnum
         display "xml_re.sinvstano     ..............:", xml_re.sinvstano
         display "xml_re.sindat        ..............:", xml_re.sindat
         display "xml_re.sinhor        ..............:", xml_re.sinhor
         display "xml_re.sinhst        ..............:", xml_re.sinhst
         display "xml_re.sinobs        ..............:", xml_re.sinobs
         display "xml_re.sinntzcod     ..............:", xml_re.sinntzcod
         display "xml_re.cbttip        ..............:", xml_re.cbttip
         display "xml_re.orcvlr        ..............:", xml_re.orcvlr
         display "xml_re.rglvstflg     ..............:", xml_re.rglvstflg
         display "xml_re.cornom        ..............:", xml_re.cornom
         display "xml_re.socntzcod     ..............:", xml_re.socntzcod
         display "xml_re.lgdtip        ..............:", xml_re.lgdtip
         display "xml_re.lgdnom        ..............:", xml_re.lgdnom
         display "xml_re.lgdnomcmp     ..............:", xml_re.lgdnomcmp
         display "xml_re.lgdnum        ..............:", xml_re.lgdnum
         display "xml_re.lclbrrnom     ..............:", xml_re.lclbrrnom
         display "xml_re.endbrr        ..............:", xml_re.endbrr
         display "xml_re.endcid        ..............:", xml_re.endcid
         display "xml_re.endufd        ..............:", xml_re.endufd
         display "xml_re.endcep        ..............:", xml_re.endcep
         display "xml_re.endcepcmp     ..............:", xml_re.endcepcmp
         display "xml_re.lclcttnom     ..............:", xml_re.lclcttnom
         display "xml_re.endrefpto     ..............:", xml_re.endrefpto
         display "xml_re.endzon        ..............:", xml_re.endzon
         display "xml_re.lclltt        ..............:", xml_re.lclltt
         display "xml_re.lcllgt        ..............:", xml_re.lcllgt
         display "xml_re.c24lclpdrcod  ..............:", xml_re.c24lclpdrcod
         display "xml_re.emeviacod     ..............:", xml_re.emeviacod
         display "xml_re.endddd        ..............:", xml_re.endddd
         display "xml_re.teldes        ..............:", xml_re.teldes
         display "xml_re.celteldddcod  ..............:", xml_re.celteldddcod
         display "xml_re.celtelnum     ..............:", xml_re.celtelnum
         display "xml_re.lclnumseq     ..............:", xml_re.lclnumseq
         display "xml_re.rmerscseq     ..............:", xml_re.rmerscseq
         display "xml_re.lclrsccod     ..............:", xml_re.lclrsccod
         display "xml_re.lclendflg     ..............:", xml_re.lclendflg
         display "xml_re.hist1         ..............:", xml_re.hist1
         display "xml_re.hist2         ..............:", xml_re.hist2
         display "xml_re.hist3         ..............:", xml_re.hist3
         display "xml_re.hist4         ..............:", xml_re.hist4
         display "xml_re.hist5         ..............:", xml_re.hist5
         display ""
         display "============================================================="

         call bdatm002_alterar_aviso_re(xml_re.c24soltipcod,
                                        xml_re.c24solnom   ,
                                        xml_re.c24astcod   ,
                                        xml_re.funmat      ,
                                        xml_re.usrtip      ,
                                        xml_re.empcod      ,
                                        xml_re.funmatatd   ,
                                        xml_re.usrtipatd   ,
                                        xml_re.empcodatd   ,
                                        xml_re.cgccpfnum   ,
                                        xml_re.cgcord      ,
                                        xml_re.cgccpfdig   ,
                                        xml_re.pestip      ,
                                        xml_re.succod      ,
                                        xml_re.ramcod      ,
                                        xml_re.aplnumdig   ,
                                        xml_re.itmnumdig   ,
                                        xml_re.edsnumref   ,
                                        xml_re.prporg      ,
                                        xml_re.prpnumdig   ,
                                        xml_re.corsus      ,
                                        xml_re.dddcod      ,
                                        xml_re.ctttel      ,
                                        xml_re.semdocto    ,
                                        xml_re.segnom      ,
                                        xml_re.sinvstnum   ,
                                        xml_re.sinvstano   ,
                                        xml_re.sindat      ,
                                        xml_re.sinhor      ,
                                        xml_re.sinhst      ,
                                        xml_re.sinobs      ,
                                        xml_re.sinntzcod   ,
                                        xml_re.cbttip      ,
                                        xml_re.orcvlr      ,
                                        xml_re.rglvstflg   ,
                                        xml_re.cornom      ,
                                        xml_re.socntzcod   ,
                                        xml_re.lgdtip      ,
                                        xml_re.lgdnom      ,
                                        xml_re.lgdnomcmp   ,
                                        xml_re.lgdnum      ,
                                        xml_re.lclbrrnom   ,
                                        xml_re.endbrr      ,
                                        xml_re.endcid      ,
                                        xml_re.endufd      ,
                                        xml_re.endcep      ,
                                        xml_re.endcepcmp   ,
                                        xml_re.lclcttnom   ,
                                        xml_re.endrefpto   ,
                                        xml_re.endzon      ,
                                        xml_re.lclltt      ,
                                        xml_re.lcllgt      ,
                                        xml_re.c24lclpdrcod,
                                        xml_re.emeviacod   ,
                                        xml_re.endddd      ,
                                        xml_re.teldes      ,
                                        xml_re.celteldddcod,
                                        xml_re.celtelnum   ,
                                        xml_re.lclnumseq   ,
                                        xml_re.rmerscseq   ,
                                        xml_re.lclrsccod   ,
                                        xml_re.lclendflg   ,
                                        xml_re.hist1       ,
                                        xml_re.hist2       ,
                                        xml_re.hist3       ,
                                        xml_re.hist4       ,
                                        xml_re.hist5       )
        returning l_retorno
        return    l_retorno




      #------------------------------------------------------
      when "OBTER_TIPOS_SERVICOS_DOCUMENTO"
      #------------------------------------------------------

           let param_xml.succod    = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/SUCURSAL")
           let param_xml.ramcod    = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/RAMO")
           let param_xml.aplnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/APOLICE")
           let param_xml.itmnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/ITEM")
           let param_xml.edsnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/ENDOSSO")
           let param_xml.rmemdlcod = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/MODALIDADE")
           let param_xml.grp_natz  = figrc011_xpath(l_docHandle,"/REQUEST/GRUPOTIPOSERVICO")

           let l_msgerro = null
           if param_xml.succod is null then
              let l_msgerro = 'PARAMETRO DE ENTRADA (SUCURSAL)'
           end if

           if param_xml.ramcod is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (RAMO)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (RAMO)'
              end if
           end if

           if param_xml.aplnumdig is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (APOLICE)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (APOLICE)'
              end if
           end if

           if param_xml.itmnumdig is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (ITEM)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (ITEM)'
              end if
           end if

           if param_xml.edsnumdig is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (ENDOSSO)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (ENDOSSO)'
              end if
           end if

           if param_xml.rmemdlcod is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (MODALIDADE)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (MODALIDADE)'
              end if
           end if

           if param_xml.grp_natz  is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (GRUPO TIPO SERVICO)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (GRUPO TIPO SERVICO)'
              end if
           end if

           if l_msgerro is not null then
              let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
              return ctf00m06_xmlerro(m_servico,1,l_msgerro)
           end if

           if param_xml.grp_natz = 'LINHA BRANCA' then
              let param_xml.c24astcod = 'S63'
           else
              if param_xml.grp_natz = 'PLANO BASICO' then
                 let param_xml.c24astcod = 'S60'
              else
                 let l_msgerro = "PARAMETRO DE ENTRADA (GRUPO TIPO SERVICO) NAO CADASTRADO."
                 return ctf00m06_xmlerro(m_servico,2,l_msgerro)
              end if
           end if

           let l_retorno=bdatm002_ObterTiposServicosDocumento(param_xml.succod,
                                                              param_xml.ramcod,
                                                              param_xml.aplnumdig,
                                                              param_xml.itmnumdig,
                                                              param_xml.edsnumdig,
                                                              param_xml.rmemdlcod,
                                                              param_xml.c24astcod)

      #------------------------------------------------------
      when "SERVICOS_ATENDIDOS_DOCUMENTO"
      #------------------------------------------------------

           let param_xml.succod    = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/SUCURSAL")
           let param_xml.ramcod    = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/RAMO")
           let param_xml.aplnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/NUMERO")
           let param_xml.itmnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/ITEM")

           let l_retorno = null
           let l_retorno = bdatm002_valida_apolice(param_xml.succod
                                                  ,param_xml.ramcod
                                                  ,param_xml.aplnumdig
                                                  ,param_xml.itmnumdig)

           if l_retorno is null or
              l_retorno =  ''   then
              let l_retorno =  ctf00m02(param_xml.succod   ,
                                        param_xml.ramcod   ,
                                        param_xml.aplnumdig,
                                        param_xml.itmnumdig)
           end if

      #------------------------------------------------------
      when "CANCELAR_SERVICO"
      #------------------------------------------------------

           let param_xml.atdsrvnum = figrc011_xpath(l_docHandle,"/REQUEST/IDENTIFICACAOSERVICO/NUMERO")
           let param_xml.atdsrvano = figrc011_xpath(l_docHandle,"/REQUEST/IDENTIFICACAOSERVICO/ANO")


           call bdatm002_carregaVariaveis(param_xml.atdsrvnum
	                                       ,param_xml.atdsrvano)
                returning param_xml.atdfnlflg, lr_serv.*, lr_altsrv.*


           if param_xml.atdfnlflg is null or
              param_xml.atdfnlflg =  " "  or
              (lr_serv.atdsrvorg <> 9 and
               lr_serv.atdsrvorg <> 4) then

              call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,3
                                         ,"Servico/Ano nao Cadastrado ou Nao Informado")
                   returning  l_retorno

           else

              let l_flg = 0
              call bdatm002_validar_srv(param_xml.atdsrvnum
                                       ,param_xml.atdsrvano
                                       ,lr_serv.*)
                   returning l_flg, l_msgerro

              if l_flg = 1 then
                 let l_retorno =  ctf00m03(param_xml.atdsrvnum
                                          ,param_xml.atdsrvano
                                          ,param_xml.atdfnlflg)
              else
                 let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
		  		 "<RESPONSE>",
		  		 "<SERVICE>CANCELAR_SERVICO</SERVICE>",
		  		 "<ERRO>",
		  		 "<CODIGO>2</CODIGO>",
		  		 "<DESCRICAO>", l_msgerro clipped, "</DESCRICAO>",
		  		 "</ERRO>",
		                  "</RESPONSE>"
              end if

           end if

      #------------------------------------------------------
      when "ALTERAR_ENDERECO"
      #------------------------------------------------------

           # Definição das TAGS



           let param_xml.atdsrvnum = figrc011_xpath(l_docHandle,"/REQUEST/IDENTIFICACAOSERVICO/NUMERO")
           let param_xml.atdsrvano = figrc011_xpath(l_docHandle,"/REQUEST/IDENTIFICACAOSERVICO/ANO")

           let l_ocorrencia.lclidttxt    = figrc011_xpath(l_docHandle,"/REQUEST/OCRIDENTIFICACAOLOCAL")
           let l_ocorrencia.lgdtip       = figrc011_xpath(l_docHandle,"/REQUEST/OCRTIPOLOGRADOURO")
           let l_ocorrencia.lgdnom       = figrc011_xpath(l_docHandle,"/REQUEST/OCRNOMELOGRADOURO")
           let l_ocorrencia.lgdnum       = figrc011_xpath(l_docHandle,"/REQUEST/OCRNUMEROLOGRADOURO")
           let l_ocorrencia.lclbrrnom    = figrc011_xpath(l_docHandle,"/REQUEST/OCRSUBBAIRRO")
           let l_ocorrencia.brrnom       = figrc011_xpath(l_docHandle,"/REQUEST/OCRNOMEBAIRRO")
           let l_ocorrencia.cidnom       = figrc011_xpath(l_docHandle,"/REQUEST/OCRNOMECIDADE")
           let l_ocorrencia.ufdcod       = figrc011_xpath(l_docHandle,"/REQUEST/OCRUF")
           let l_ocorrencia.lclrefptotxt = figrc011_xpath(l_docHandle,"/REQUEST/OCRPONTOREFERENCIA")
           let l_ocorrencia.endzon       = figrc011_xpath(l_docHandle,"/REQUEST/OCRZONA")
           let l_ocorrencia.lclltt       = figrc011_xpath(l_docHandle,"/REQUEST/OCRLATITUDELOCAL")
           let l_ocorrencia.lcllgt       = figrc011_xpath(l_docHandle,"/REQUEST/OCRLONGITUDELOCAL")
           let l_ocorrencia.dddcod       = figrc011_xpath(l_docHandle,"/REQUEST/OCRDDDTEL")
           let l_ocorrencia.lcltelnum    = figrc011_xpath(l_docHandle,"/REQUEST/OCRNUMEROTEL")
           let l_ocorrencia.lclcttnom    = figrc011_xpath(l_docHandle,"/REQUEST/OCRNOMECONTATO")
           let l_ocorrencia.c24lclpdrcod = figrc011_xpath(l_docHandle,"/REQUEST/OCRCODIGOPADRAOLOCAL")
           let l_ocorrencia.emeviacod    = figrc011_xpath(l_docHandle,"/REQUEST/OCRCODIGOVIAEMERGENCIAL")

           let l_destino.lclidttxt       = figrc011_xpath(l_docHandle,"/REQUEST/DESTIDENTIFICACAOLOCAL")
           let l_destino.lgdtip          = figrc011_xpath(l_docHandle,"/REQUEST/DESTTIPOLOGRADOURO")
           let l_destino.lgdnom          = figrc011_xpath(l_docHandle,"/REQUEST/DESTNOMELOGRADOURO")
           let l_destino.lclbrrnom       = figrc011_xpath(l_docHandle,"/REQUEST/DESTSUBBAIRRO")
           let l_destino.brrnom          = figrc011_xpath(l_docHandle,"/REQUEST/DESTNOMEBAIRRO")
           let l_destino.cidnom          = figrc011_xpath(l_docHandle,"/REQUEST/DESTNOMECIDADE")
           let l_destino.ufdcod          = figrc011_xpath(l_docHandle,"/REQUEST/DESTUF")
           let l_destino.lclrefptotxt    = figrc011_xpath(l_docHandle,"/REQUEST/DESTPONTOREFERENCIA")
           let l_destino.endzon          = figrc011_xpath(l_docHandle,"/REQUEST/DESTZONA")
           let l_destino.dddcod          = figrc011_xpath(l_docHandle,"/REQUEST/DESTDDDTEL")
	         let l_destino.lcltelnum       = figrc011_xpath(l_docHandle,"/REQUEST/DESTNUMEROTEL")
	         let l_destino.lclcttnom       = figrc011_xpath(l_docHandle,"/REQUEST/DESTNOMECONTATO")
	         let l_destino.ofnnumdig       = figrc011_xpath(l_docHandle,"/REQUEST/DESTNUMERODIGITOOFICINA")
           let l_destino.emeviacod       = figrc011_xpath(l_docHandle,"/REQUEST/DESTCODIGOVIAEMERGENCIAL")
           let l_destino.lclidttxt       = figrc011_xpath(l_docHandle,"/REQUEST/DESTIDENTIFICACAOLOCAL")
           let l_destino.lgdtip          = figrc011_xpath(l_docHandle,"/REQUEST/DESTTIPOLOGRADOURO")
           let l_destino.lgdnom          = figrc011_xpath(l_docHandle,"/REQUEST/DESTNOMELOGRADOURO")

           ## OPCIONAIS
           let l_destino.lgdnum          = figrc011_xpath(l_docHandle,"/REQUEST/DESTNUMEROLOGRADOURO")
           let l_destino.lclltt          = figrc011_xpath(l_docHandle,"/REQUEST/DESTLATITUDELOCAL")
           let l_destino.lcllgt          = figrc011_xpath(l_docHandle,"/REQUEST/DESTLONGITUDELOCAL")
           let l_destino.c24lclpdrcod    = figrc011_xpath(l_docHandle,"/REQUEST/DESTCODIGOPADRAOLOCAL")

           call bdatm002_carregaVariaveis(param_xml.atdsrvnum
	                                 ,param_xml.atdsrvano)
	        returning param_xml.atdfnlflg, lr_serv.*, lr_altsrv.*


	   if param_xml.atdfnlflg is null or
	      param_xml.atdfnlflg =  " "  then

	      call ctf00m06_xmlerro ("ALTERAR_ENDERECO"
	                             ,1
	                             ,"Servico/Ano nao Cadastrado ou Nao Informado")
	           returning  l_retorno
	   else
	      let l_flg = 0
	      call bdatm002_validar_srv(param_xml.atdsrvnum
	                               ,param_xml.atdsrvano
	                               ,lr_serv.*)
	           returning l_flg, l_msgerro
display 'aqui l_flg ', l_flg, ' ', l_msgerro
	      if l_flg = 1 then

	         call bdatm002_valida_enderecos(l_ocorrencia.*, l_destino.*)
	              returning l_val_oco, l_val_dst


	         call cts58g00(param_xml.atdsrvnum
		              ,param_xml.atdsrvano
		              ,lr_serv.atdsrvorg
		              ,lr_serv.assunto
                              ,lr_altsrv.*
                              ,l_val_oco
                              ,l_val_dst
                              ,l_ocorrencia.*
                              ,l_destino.*)
                      returning l_errcod, l_errmsg


		  if l_errcod is null or l_errcod != 0 then
		     # nao enviar errcod nulo como retorno
		     if l_errcod is null then
		        let l_errcod = 3
		     end if

		     display 'ERRO cts58g00: ', l_errcod, ' / ', l_errmsg clipped
		     return ctf00m06_xmlerro(m_servico, l_errcod, l_errmsg)
		  else
		     let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
		                     "<RESPONSE>",
		                     "<SERVICE>ALTERAR_ENDERECO</SERVICE>",
		                     "<ERRO>",
		                     "<CODIGO>0</CODIGO>",
		                     "<DESCRICAO></DESCRICAO>",
		                     "</ERRO>",
		                     "</RESPONSE>"
                 end if
              else
                 let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
		  		 "<RESPONSE>",
		  		 "<SERVICE>ALTERAR_ENDERECO</SERVICE>",
		  		 "<ERRO>",
		  		 "<CODIGO>2</CODIGO>",
		  		 "<DESCRICAO>", l_msgerro clipped, "</DESCRICAO>",
		  		 "</ERRO>",
		                  "</RESPONSE>"
	      end if

           end if

      #------------------------------------------------------
      when "LISTAR_AGENDA_DISPONIVEL"
      #------------------------------------------------------

           let param_xml.atdsrvnum = figrc011_xpath(l_docHandle, "/REQUEST/IDENTIFICACAOSERVICO/NUMERO")
           let param_xml.atdsrvano = figrc011_xpath(l_docHandle, "/REQUEST/IDENTIFICACAOSERVICO/ANO")
           let param_xml.cidnom    = figrc011_xpath(l_docHandle, "/REQUEST/CIDADE/NOME")
           let param_xml.ufdcod    = figrc011_xpath(l_docHandle, "/REQUEST/CIDADE/UF")
           let param_xml.socntzdes = figrc011_xpath(l_docHandle, "/REQUEST/GRUPOTIPOSERVICO")

           let l_retorno =  ctx32g00_ListarAgenda(param_xml.cidnom   ,
                                                  param_xml.ufdcod   ,
                                                  param_xml.socntzdes,
                                                  param_xml.atdsrvnum,
                                                  param_xml.atdsrvano)


      #------------------------------------------------------
      when "DISPONIBILIDADE_IMEDIATA"
      #------------------------------------------------------

         for l_index = 1 to 11

             case l_index
                  when 1

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod    = figrc011_xpath(l_docHandle,l_tree)

                  when 2
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_1 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_1    = figrc011_xpath(l_docHandle,l_tree)

                  when 3
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_2 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_2    = figrc011_xpath(l_docHandle,l_tree)

                  when 4
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_3 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_3    = figrc011_xpath(l_docHandle,l_tree)

                  when 5
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_4 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_4    = figrc011_xpath(l_docHandle,l_tree)

                  when 6
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_5 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_5    = figrc011_xpath(l_docHandle,l_tree)

                  when 7
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_6 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_6    = figrc011_xpath(l_docHandle,l_tree)

                  when 8
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_7 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_7    = figrc011_xpath(l_docHandle,l_tree)

                  when 9
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_8 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_8    = figrc011_xpath(l_docHandle,l_tree)

                  when 10
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_9 = figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_9    = figrc011_xpath(l_docHandle,l_tree)

                  when 11
                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'
                     let param_xml_servicos.socntzcod_10= figrc011_xpath(l_docHandle,l_tree)

                     let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'
                     let param_xml_servicos.espcod_10   = figrc011_xpath(l_docHandle,l_tree)
             end case

         end for

         let param_xml.logtip = figrc011_xpath(l_docHandle, "/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/TIPO")
         let param_xml.lognom = figrc011_xpath(l_docHandle, "/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/NOME")
         let param_xml.lognum = figrc011_xpath(l_docHandle, "/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/NUMERO")
         let param_xml.bairro = figrc011_xpath(l_docHandle, "/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/BAIRRO")
         let param_xml.cidnom = figrc011_xpath(l_docHandle, "/REQUEST/ENDERECO/OCORRENCIA/CIDADE/NOME")
         let param_xml.ufdcod = figrc011_xpath(l_docHandle, "/REQUEST/ENDERECO/OCORRENCIA/CIDADE/UF")

         #--- Montando xml de retorno--#
         #let l_retorno = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
         # 	'<RESPONSE>',
         #   '<SERVICO>DISPONIBILIDADE_IMEDIATA</SERVICO>',
         #   '<DISPONIVEL>SIM</DISPONIVEL>',
         #	'</RESPONSE>'
         # Comentado devido aos lock de tabela no banco u18w estamos identificando a causa raiz.
         let l_retorno = ctx32g00_DiponibilidadeImediata(param_xml_servicos.*,
                                                         param_xml.logtip,
                                                         param_xml.lognom,
                                                         param_xml.lognum,
                                                         param_xml.bairro,
                                                         param_xml.cidnom,
                                                         param_xml.ufdcod)

      #------------------------------------------------------
      when "OBTER_INFORMACAO_SERVICO"
      #------------------------------------------------------

         let param_xml.atdsrvnum = figrc011_xpath(l_docHandle, "/REQUEST/IDENTIFICACAOSERVICO/NUMERO")
         let param_xml.atdsrvano = figrc011_xpath(l_docHandle, "/REQUEST/IDENTIFICACAOSERVICO/ANO")

         let l_msgerro = null
         if param_xml.atdsrvnum is null then
           let l_msgerro = 'PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/NUMERO)'
         end if

         if param_xml.atdsrvano is null then
            if l_msgerro is not null then
             let l_msgerro = l_msgerro clipped, ', (/IDENTIFICACAOSERVICO/ANO)'
            else
              let l_msgerro ='PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/ANO)'
            end if
         end if

         if l_msgerro is not null then
            let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
            return ctf00m06_xmlerro(m_servico,1,l_msgerro)
         end if

         let l_retorno = bdatm002_obterInformacoesServico(param_xml.atdsrvnum
                                                        , param_xml.atdsrvano)


      #------------------------------------------------------
      when "REAGENDAR_SERVICO"
      #------------------------------------------------------

         let param_xml.atdsrvnum = figrc011_xpath(l_docHandle, "/REQUEST/IDENTIFICACAOSERVICO/NUMERO")
         let param_xml.atdsrvano = figrc011_xpath(l_docHandle, "/REQUEST/IDENTIFICACAOSERVICO/ANO")
         let param_xml.rgldat = figrc011_xpath(l_docHandle, "/REQUEST/DATA")
         let param_xml.rglhor = figrc011_xpath(l_docHandle, "/REQUEST/HORA")

         let l_msgerro = null
         if param_xml.atdsrvnum is null then
           let l_msgerro = 'PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/NUMERO)'
         end if

         if param_xml.atdsrvano is null then
            if l_msgerro is not null then
             let l_msgerro = l_msgerro clipped, ', (/IDENTIFICACAOSERVICO/ANO)'
            else
              let l_msgerro ='PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/ANO)'
            end if
         end if

         if param_xml.rgldat is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (DATA)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (DATA)'
            end if
         end if

         if param_xml.rglhor is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (HORA)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (HORA)'
            end if
         end if

         if l_msgerro is not null then
            let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
            return ctf00m06_xmlerro(m_servico,1,l_msgerro)
         end if

         let l_retorno = bdatm002_reagendarServico(param_xml.atdsrvnum
                                                  ,param_xml.atdsrvano
                                                  ,param_xml.rgldat
                                                  ,param_xml.rglhor)

      #-----------------------------------------------------------------------
      when "REGISTRAR_SERVICOS"
      #-----------------------------------------------------------------------

         let param_xml.succod   = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/SUCURSAL")
         let param_xml.ramcod   = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/RAMO")
         let param_xml.aplnumdig= figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/APOLICE")
         let param_xml.itmnumdig= figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/ITEM")
         let param_xml.edsnumdig= figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/ENDOSSO")
         let param_xml.rmemdlcod= figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/MODALIDADE")

         let l_qtd =  figrc011_xpath(l_docHandle,"count(/REQUEST/TIPOSERVICOS/TIPOSERVICO)")

         for l_index = 1 to l_qtd

             let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&",']/CODIGO'

             let param_xml_multiplos[l_index].socntzcod = figrc011_xpath(l_docHandle,l_tree)

             let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/PROBLEMA/CODIGO'

             let param_xml_multiplos[l_index].c24pbmgrpcod  = figrc011_xpath(l_docHandle,l_tree)

             let l_tree = '/REQUEST/TIPOSERVICOS/TIPOSERVICO[',l_index  using "<<<<&", ']/ESPECIALIDADE/CODIGO'

             let param_xml_multiplos[l_index].espcod    = figrc011_xpath(l_docHandle,l_tree)


         end for

         let param_xml.grp_natz = figrc011_xpath(l_docHandle,"/REQUEST/TIPOSERVICOS/GRUPOTIPOSERVICO")
         let param_xml.data     = figrc011_xpath(l_docHandle,"/REQUEST/HORARIO/DATA")
         let param_xml.hora     = figrc011_xpath(l_docHandle,"/REQUEST/HORARIO/HORA")
         let param_xml.logtip   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/TIPO")
         let param_xml.lognom   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/NOME")
         let param_xml.lognum   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/NUMERO")
         let param_xml.bairro   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/BAIRRO")
         let param_xml.endcmp   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/LOGRADOURO/COMPLEMENTO_END")     #P283688
         let param_xml.cidnom   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CIDADE/NOME")
         let param_xml.ufdcod   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CIDADE/UF")
         let param_xml.lclrefptotxt= figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/REFERENCIA")
         let param_xml.endzon   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/ZONA")
         let param_xml.lgdcep   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CEP/NUMERO")
         let param_xml.lgdcepcmp= figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CEP/COMPLEMENTO")
         let param_xml.lclcttnom= figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CONTATO/NOME")
         let param_xml.dddcod   = figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CONTATO/TELEFONE/DDD")
         let param_xml.lcltelnum= figrc011_xpath(l_docHandle,"/REQUEST/ENDERECO/OCORRENCIA/CONTATO/TELEFONE/NUMERO")


         initialize param_xml.acao to null
         let param_xml.srvrglcod = null

         if param_xml.grp_natz = 'LINHA BRANCA' then
            let param_xml.c24astcod = 'S63'
            let param_xml.srvrglcod =  1
         else
            if param_xml.grp_natz = 'PLANO BASICO' then
               let param_xml.c24astcod = 'S60'
               let param_xml.srvrglcod = 2
            else
               if param_xml.grp_natz = 'PE1' then
                  let param_xml.c24astcod = 'PE1'
                  let param_xml.srvrglcod = 2
               else
                   if param_xml.grp_natz = 'PE2' then
                      let param_xml.c24astcod = 'PE2'
                      let param_xml.srvrglcod = 2
                   end if
               end if


            end if
         end if

         if param_xml.c24astcod = 'PE1' or
            param_xml.c24astcod = 'PE2' then

            call bdatm002_calcula_digito_item(param_xml.itmnumdig)
            returning lr_ret_item.*

            if lr_ret_item.errcode = 0 then
               let param_xml.itmnumdig = lr_ret_item.itmnumdig
            end if
         end if


         call bdatm002_carregaVariaveisGlobais_2(param_xml.succod
                                                ,param_xml.ramcod
                                                ,param_xml.aplnumdig
                                                ,param_xml.itmnumdig
                                                ,param_xml.edsnumdig )

         let l_retorno = ctf00m04_grava_dados
	                         (param_xml.c24astcod
                                 ,param_xml.data
                                 ,param_xml.hora
                                 ,param_xml.logtip
                                 ,param_xml.lognom
                                 ,param_xml.lognum
                                 ,param_xml.bairro
                                 ,param_xml.cidnom
                                 ,param_xml.ufdcod
                                 ,param_xml.lclrefptotxt
                                 ,param_xml.endzon
                                 ,param_xml.lgdcep
                                 ,param_xml.lgdcepcmp
                                 ,param_xml.lclcttnom
                                 ,param_xml.dddcod
                                 ,param_xml.lcltelnum
                                 ,param_xml.endcmp           #P283688
                                 ,param_xml.srvrglcod
                                 ," "        # atdsrvnum  --> Retorno (inicio)
                                 ," "        # atdsrvano
                                 ,param_xml.acao          --> retorno = RET
                                 ,param_xml.srvretmtvcod
                                 ,param_xml.srvretmtvdes
                                 ,param_xml.retprsmsmflg
                                 ,param_xml.orrdat       ---> Retorno (fim)
                                 ,param_xml_multiplos[1].*
                                 ,param_xml_multiplos[2].*
                                 ,param_xml_multiplos[3].*
                                 ,param_xml_multiplos[4].*
                                 ,param_xml_multiplos[5].*
                                 ,param_xml_multiplos[6].*
                                 ,param_xml_multiplos[7].*
                                 ,param_xml_multiplos[8].*
                                 ,param_xml_multiplos[9].*
                                 ,param_xml_multiplos[10].*)


      #-----------------------------------------------------------------------
      when "REGISTRAR_RETORNO_SERVICO"
      #-----------------------------------------------------------------------
         let param_xml.atdsrvnum = figrc011_xpath(l_docHandle,"/REQUEST/IDENTIFICACAOSERVICO/NUMERO")
         let param_xml.atdsrvano = figrc011_xpath(l_docHandle,"/REQUEST/IDENTIFICACAOSERVICO/ANO")
         let param_xml.data     = figrc011_xpath(l_docHandle,"/REQUEST/DATA")
         let param_xml.hora     = figrc011_xpath(l_docHandle,"/REQUEST/HORA")
         let param_xml.retorno  = figrc011_xpath(l_docHandle,"/REQUEST/RETORNO")
         let param_xml.msmprest = figrc011_xpath(l_docHandle,"/REQUEST/MESMOPRESTADOR")

         let l_msgerro = null
         if param_xml.atdsrvnum is null then
           let l_msgerro = 'PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/NUMERO)'
         end if

         if param_xml.atdsrvano is null then
            if l_msgerro is not null then
             let l_msgerro = l_msgerro clipped, ', (/IDENTIFICACAOSERVICO/ANO)'
            else
              let l_msgerro ='PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/ANO)'
            end if
         end if

         if param_xml.data is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (DATA)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (DATA)'
            end if
         end if

         if param_xml.hora is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (HORA)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (HORA)'
            end if
         end if

         if param_xml.retorno is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (RETORNO)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (RETORNO)'
            end if
         end if

         if param_xml.msmprest is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (MESMOPRESTADOR)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (MESMOPRESTADOR)'
            end if
         end if

         if l_msgerro is not null then
            let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
            return ctf00m06_xmlerro(m_servico,1,l_msgerro)
         end if

         let g_documento.atdsrvnum = param_xml.atdsrvnum
         let g_documento.atdsrvano = param_xml.atdsrvano
         let g_documento.acao      = 'RET'
         let g_origem                 = "WEB"         # Portal do Segurado
         let g_documento.solnom       = "PORTAL WEB"
         let g_issk.funmat            = 999999
         let g_issk.empcod            = 1
         let g_issk.usrtip            = "F"
         let g_documento.ligcvntip    = 0
         let g_c24paxnum              = 0
         let g_documento.c24soltipcod = 1             # Segurado
         let g_documento.soltip       = "S"           # Segurado
         let g_documento.atdsrvorg    = 9
         let g_documento.crtsaunum    = null
         let g_documento.prporg       = null
         let g_documento.prpnumdig    = null
         let g_documento.fcapacorg    = null
         let g_documento.fcapacnum    = null

         call ctf00m01_copia()
              returning l_retorno
                       ,param_xml.logtip
                       ,param_xml.lognom
                       ,param_xml.lognum
                       ,param_xml.bairro
                       ,param_xml.cidnom
                       ,param_xml.ufdcod
                       ,param_xml.lclrefptotxt
                       ,param_xml.endzon
                       ,param_xml.lgdcep
                       ,param_xml.lgdcepcmp
                       ,param_xml.lclcttnom
                       ,param_xml.dddcod
                       ,param_xml.lcltelnum
                       ,param_xml.orrdat
                       ,param_xml_multiplos[1].socntzcod
                       ,param_xml_multiplos[1].espcod
                       ,param_xml_multiplos[1].c24pbmgrpcod

         if l_retorno is null then

            if param_xml.retorno = 'COMPLEMENTO' then
               let param_xml.srvretmtvcod = 1
               let param_xml.srvretmtvdes ='COMPLEMENTO DO ATENDIMENTO ORIGINAL'
            else
               if param_xml.retorno = 'GARANTIA' then
                  let param_xml.srvretmtvcod = 2
                  let param_xml.srvretmtvdes='PROBLEMAS NO ATENDIMENTO ORIGINAL'
               end if
            end if

            if param_xml.msmprest = 'SIM' then
               let param_xml.retprsmsmflg = 'S'
            else
               if param_xml.msmprest = 'NAO' then
                  let param_xml.retprsmsmflg = 'N'
               end if
            end if

            let lr_aux.lignum = cts20g00_servico(g_documento.atdsrvnum
                                                ,g_documento.atdsrvano)

            select c24astcod
              into lr_aux.c24astcod
              from datmligacao
             where lignum     = lr_aux.lignum
               and c24astcod in ('S60','S63')

            if lr_aux.c24astcod = 'S63' then
               let param_xml.srvrglcod =  1
            else
               if lr_aux.c24astcod = 'S60' then
                  let param_xml.srvrglcod = 2
               end if
            end if

            let l_retorno = ctf00m04_grava_dados("RET"            # c24astcod
                                                ,param_xml.data
                                                ,param_xml.hora
                                                ,param_xml.logtip
                                                ,param_xml.lognom
                                                ,param_xml.lognum
                                                ,param_xml.bairro
                                                ,param_xml.cidnom
                                                ,param_xml.ufdcod
                                                ,param_xml.lclrefptotxt
                                                ,param_xml.endzon
                                                ,param_xml.lgdcep
                                                ,param_xml.lgdcepcmp
                                                ,param_xml.lclcttnom
                                                ,param_xml.dddcod
                                                ,param_xml.lcltelnum
                                                ," "                      #P283688
                                                ,param_xml.srvrglcod
                                                ,param_xml.atdsrvnum #Retorno (inicio)
                                                ,param_xml.atdsrvano #atdsrvano
                                                ,"RET" --> param_xml.acao
                                                ,param_xml.srvretmtvcod
                                                ,param_xml.srvretmtvdes
                                                ,param_xml.retprsmsmflg
                                                ,param_xml.orrdat    #Retorno (fim)
                                                ,param_xml_multiplos[1].*
                                                ,param_xml_multiplos[2].*
                                                ,param_xml_multiplos[3].*
                                                ,param_xml_multiplos[4].*
                                                ,param_xml_multiplos[5].*
                                                ,param_xml_multiplos[6].*
                                                ,param_xml_multiplos[7].*
                                                ,param_xml_multiplos[8].*
                                                ,param_xml_multiplos[9].*
                                                ,param_xml_multiplos[10].*)
         end if


      #------------------------------------------------------
      when "OBTER_SERVICOS_DISPONIVEIS"
      #------------------------------------------------------

         let param_xml.succod    = figrc011_xpath(l_docHandle,"/REQUEST/APOLICE/SUCURSAL")
         let param_xml.ramcod    = figrc011_xpath(l_docHandle,"/REQUEST/APOLICE/RAMO")
         let param_xml.aplnumdig = figrc011_xpath(l_docHandle,"/REQUEST/APOLICE/NUMERO")
         let param_xml.itmnumdig = figrc011_xpath(l_docHandle,"/REQUEST/APOLICE/ITEM")

         initialize l_msgerro to null

         if param_xml.succod is null
            then
            if l_msgerro is not null
               then
               let l_msgerro = l_msgerro clipped ,', (SUCURSAL)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (SUCURSAL)'
            end if
         end if

         if param_xml.ramcod is null
            then
            if l_msgerro is not null
               then
               let l_msgerro = l_msgerro clipped ,', (RAMO)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (RAMO)'
            end if
         end if

         if param_xml.aplnumdig is null
            then
            if l_msgerro is not null
               then
               let l_msgerro = l_msgerro clipped ,', (NUMEROAPOLICE)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (NUMEROAPOLICE)'
            end if
         end if

         if param_xml.itmnumdig is null
            then
            if l_msgerro is not null
               then
               let l_msgerro = l_msgerro clipped ,', (ITEMAPOLICE)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (ITEMAPOLICE)'
            end if
         end if

         if l_msgerro is not null
            then
            let l_msgerro = l_msgerro clipped , ' NAO INFORMADO(S).'
            return ctf00m06_xmlerro(m_servico, 1, l_msgerro)
         end if

         let l_retorno = null

         whenever error continue
         call cts56g00_sel_pbm_smart(param_xml.ramcod   ,
                                     param_xml.succod   ,
                                     param_xml.aplnumdig,
                                     param_xml.itmnumdig)
                           returning l_errcod, l_errmsg, l_retorno
         whenever error stop

         if l_errcod is null or l_errcod != 0
            then
            return ctf00m06_xmlerro(m_servico, l_errcod, l_errmsg)
         end if


      #------------------------------------------------------
      when "INCLUIR_SERVICO_WEB"
      #------------------------------------------------------

         let l_servico.c24astcod = figrc011_xpath(l_docHandle,"/REQUEST/CODIGOASSUNTO")

         if l_servico.c24astcod is null then
            let l_servico.c24astcod = figrc011_xpath(l_docHandle,"/REQUEST/CodigoAssunto")
         end if

         call bdatm002_sinistro(l_servico.c24astcod)
              returning  l_rqt.srvnumtip
                        ,l_rqt.solicdat
                        ,l_rqt.solichor
                        ,l_rqt.c24soltipcod
                        ,l_rqt.c24solnom
                        ,l_rqt.c24astcod
                        ,l_rqt.c24pbmcod
                        ,l_rqt.funmat
                        ,l_rqt.funemp
                        ,l_rqt.c24paxnum
                        ,l_rqt.atdlibflg
                        ,l_rqt.atdtip
                        ,l_rqt.atdfnlflg
                        ,l_rqt.atdrsdflg
                        ,l_rqt.atdpvtretflg
                        ,l_rqt.asitipcod
                        ,l_rqt.srvprlflg
                        ,l_rqt.atdprinvlcod
                        ,l_rqt.atdsrvorg
                        ,l_rqt.c24pbminforg
                        ,l_rqt.pstcoddig
                        ,l_rqt.atdetpcod
                        ,l_rqt.ligcvntip
                        ,l_rqt.prslocflg
                        ,l_rqt.rmcacpflg
                        ,l_rqt.frmflg
                        ,l_rqt.vclcorcod
                        ,l_rqt.vcldes
                        ,l_rqt.vclanomdl
                        ,l_rqt.vcllicnum
                        ,l_rqt.camflg
                        ,l_rqt.vclcoddig
                        ,l_rqt.segnom
                        ,l_rqt.succod
                        ,l_rqt.ramcod
                        ,l_rqt.aplnumdig
                        ,l_rqt.itmnumdig
                        ,l_rqt.edsnumref
                        ,l_rqt.corsus
                        ,l_rqt.cornom
                        ,l_rqt.atddatprg
                        ,l_rqt.atdhorprg
                        ,l_rqt.c24pbmdes
                        ,l_rqt.webpbmdes
                        ,l_rqt.sphpbmdes
                        ,l_rqt.remrquflg
                        ,l_rqt.oco_lclidttxt
                        ,l_rqt.oco_lgdtip
                        ,l_rqt.oco_lgdnom
                        ,l_rqt.oco_lgdnum
                        ,l_rqt.oco_lclbrrnom
                        ,l_rqt.oco_brrnom
                        ,l_rqt.oco_cidnom
                        ,l_rqt.oco_ufdcod
                        ,l_rqt.oco_lclrefptotxt
                        ,l_rqt.oco_endzon
                        ,l_rqt.oco_lgdcep
                        ,l_rqt.oco_lgdcepcmp
                        ,l_rqt.oco_lclltt
                        ,l_rqt.oco_lcllgt
                        ,l_rqt.oco_dddcod
                        ,l_rqt.oco_lcltelnum
                        ,l_rqt.oco_lclcttnom
                        ,l_rqt.oco_c24lclpdrcod
                        ,l_rqt.oco_ofnnumdig
                        ,l_rqt.oco_emeviacod
                        ,l_rqt.dst_lclidttxt
                        ,l_rqt.dst_lgdtip
                        ,l_rqt.dst_lgdnom
                        ,l_rqt.dst_lgdnum
                        ,l_rqt.dst_lclbrrnom
                        ,l_rqt.dst_brrnom
                        ,l_rqt.dst_cidnom
                        ,l_rqt.dst_ufdcod
                        ,l_rqt.dst_lclrefptotxt
                        ,l_rqt.dst_endzon
                        ,l_rqt.dst_lgdcep
                        ,l_rqt.dst_lgdcepcmp
                        ,l_rqt.dst_lclltt
                        ,l_rqt.dst_lcllgt
                        ,l_rqt.dst_dddcod
                        ,l_rqt.dst_lcltelnum
                        ,l_rqt.dst_lclcttnom
                        ,l_rqt.dst_c24lclpdrcod
                        ,l_rqt.dst_ofnnumdig
                        ,l_rqt.dst_emeviacod


         let l_servico.srvnumtip       = figrc011_xpath(l_docHandle,l_rqt.srvnumtip       )
         let l_servico.solicdat        = figrc011_xpath(l_docHandle,l_rqt.solicdat        )
         let l_servico.solichor        = figrc011_xpath(l_docHandle,l_rqt.solichor        )
         let l_servico.c24soltipcod    = figrc011_xpath(l_docHandle,l_rqt.c24soltipcod    )
         let l_servico.c24solnom       = figrc011_xpath(l_docHandle,l_rqt.c24solnom       )
         let l_servico.c24astcod       = figrc011_xpath(l_docHandle,l_rqt.c24astcod       )
         let l_servico.c24pbmcod       = figrc011_xpath(l_docHandle,l_rqt.c24pbmcod       )
         let l_servico.funmat          = figrc011_xpath(l_docHandle,l_rqt.funmat          )
         let l_servico.funemp          = figrc011_xpath(l_docHandle,l_rqt.funemp          )
         let l_servico.c24paxnum       = figrc011_xpath(l_docHandle,l_rqt.c24paxnum       )
         let l_servico.atdlibflg       = figrc011_xpath(l_docHandle,l_rqt.atdlibflg       )
         let l_servico.atdtip          = figrc011_xpath(l_docHandle,l_rqt.atdtip          )
         let l_servico.atdfnlflg       = figrc011_xpath(l_docHandle,l_rqt.atdfnlflg       )
         let l_servico.atdrsdflg       = figrc011_xpath(l_docHandle,l_rqt.atdrsdflg       )
         let l_servico.atdpvtretflg    = figrc011_xpath(l_docHandle,l_rqt.atdpvtretflg    )
         let l_servico.asitipcod       = figrc011_xpath(l_docHandle,l_rqt.asitipcod       )
         let l_servico.srvprlflg       = figrc011_xpath(l_docHandle,l_rqt.srvprlflg       )
         let l_servico.atdprinvlcod    = figrc011_xpath(l_docHandle,l_rqt.atdprinvlcod    )
         let l_servico.atdsrvorg       = figrc011_xpath(l_docHandle,l_rqt.atdsrvorg       )
         let l_servico.c24pbminforg    = figrc011_xpath(l_docHandle,l_rqt.c24pbminforg    )
         let l_servico.pstcoddig       = figrc011_xpath(l_docHandle,l_rqt.pstcoddig       )
         let l_servico.atdetpcod       = figrc011_xpath(l_docHandle,l_rqt.atdetpcod       )
         let l_servico.ligcvntip       = figrc011_xpath(l_docHandle,l_rqt.ligcvntip       )
         let l_servico.prslocflg       = figrc011_xpath(l_docHandle,l_rqt.prslocflg       )
         let l_servico.rmcacpflg       = figrc011_xpath(l_docHandle,l_rqt.rmcacpflg       )
         let l_servico.frmflg          = figrc011_xpath(l_docHandle,l_rqt.frmflg          )
         let l_servico.vclcorcod       = figrc011_xpath(l_docHandle,l_rqt.vclcorcod       )
         let l_servico.vcldes          = figrc011_xpath(l_docHandle,l_rqt.vcldes          )
         let l_servico.vclanomdl       = figrc011_xpath(l_docHandle,l_rqt.vclanomdl       )
         let l_servico.vcllicnum       = figrc011_xpath(l_docHandle,l_rqt.vcllicnum       )
         let l_servico.camflg          = figrc011_xpath(l_docHandle,l_rqt.camflg          )
         let l_servico.vclcoddig       = figrc011_xpath(l_docHandle,l_rqt.vclcoddig       )
         let l_servico.segnom          = figrc011_xpath(l_docHandle,l_rqt.segnom          )
         let l_servico.succod          = figrc011_xpath(l_docHandle,l_rqt.succod          )
         let l_servico.ramcod          = figrc011_xpath(l_docHandle,l_rqt.ramcod          )
         let l_servico.aplnumdig       = figrc011_xpath(l_docHandle,l_rqt.aplnumdig       )
         let l_servico.itmnumdig       = figrc011_xpath(l_docHandle,l_rqt.itmnumdig       )
         let l_servico.edsnumref       = figrc011_xpath(l_docHandle,l_rqt.edsnumref       )
         let l_servico.corsus          = figrc011_xpath(l_docHandle,l_rqt.corsus          )
         let l_servico.cornom          = figrc011_xpath(l_docHandle,l_rqt.cornom          )
         let l_servico.atddatprg       = figrc011_xpath(l_docHandle,l_rqt.atddatprg       )
         let l_servico.atdhorprg       = figrc011_xpath(l_docHandle,l_rqt.atdhorprg       )
         let l_servico.c24pbmdes       = figrc011_xpath(l_docHandle,l_rqt.c24pbmdes       )
         let l_servico.webpbmdes       = figrc011_xpath(l_docHandle,l_rqt.webpbmdes       )
         let l_servico.sphpbmdes       = figrc011_xpath(l_docHandle,l_rqt.sphpbmdes       )
         let l_servico.remrquflg       = figrc011_xpath(l_docHandle,l_rqt.remrquflg       )
         let l_ocorrencia.lclidttxt    = figrc011_xpath(l_docHandle,l_rqt.oco_lclidttxt  )
         let l_ocorrencia.lgdtip       = figrc011_xpath(l_docHandle,l_rqt.oco_lgdtip      )
         let l_ocorrencia.lgdnom       = figrc011_xpath(l_docHandle,l_rqt.oco_lgdnom      )
         let l_ocorrencia.lgdnum       = figrc011_xpath(l_docHandle,l_rqt.oco_lgdnum      )
         let l_ocorrencia.lclbrrnom    = figrc011_xpath(l_docHandle,l_rqt.oco_lclbrrnom   )
         let l_ocorrencia.brrnom       = figrc011_xpath(l_docHandle,l_rqt.oco_brrnom      )
         let l_ocorrencia.cidnom       = figrc011_xpath(l_docHandle,l_rqt.oco_cidnom      )
         let l_ocorrencia.ufdcod       = figrc011_xpath(l_docHandle,l_rqt.oco_ufdcod      )
         let l_ocorrencia.lclrefptotxt = figrc011_xpath(l_docHandle,l_rqt.oco_lclrefptotxt)
         let l_ocorrencia.endzon       = figrc011_xpath(l_docHandle,l_rqt.oco_endzon      )
         let l_ocorrencia.lgdcep       = figrc011_xpath(l_docHandle,l_rqt.oco_lgdcep      )
         let l_ocorrencia.lgdcepcmp    = figrc011_xpath(l_docHandle,l_rqt.oco_lgdcepcmp   )
         let l_ocorrencia.lclltt       = figrc011_xpath(l_docHandle,l_rqt.oco_lclltt      )
         let l_ocorrencia.lcllgt       = figrc011_xpath(l_docHandle,l_rqt.oco_lcllgt      )
         let l_ocorrencia.dddcod       = figrc011_xpath(l_docHandle,l_rqt.oco_dddcod      )
         let l_ocorrencia.lcltelnum    = figrc011_xpath(l_docHandle,l_rqt.oco_lcltelnum   )
         let l_ocorrencia.lclcttnom    = figrc011_xpath(l_docHandle,l_rqt.oco_lclcttnom   )
         let l_ocorrencia.c24lclpdrcod = figrc011_xpath(l_docHandle,l_rqt.oco_c24lclpdrcod)
         let l_ocorrencia.ofnnumdig    = figrc011_xpath(l_docHandle,l_rqt.oco_ofnnumdig   )
         let l_ocorrencia.emeviacod    = figrc011_xpath(l_docHandle,l_rqt.oco_emeviacod   )
         let l_destino.lclidttxt       = figrc011_xpath(l_docHandle,l_rqt.dst_lclidttxt   )
         let l_destino.lgdtip          = figrc011_xpath(l_docHandle,l_rqt.dst_lgdtip      )
         let l_destino.lgdnom          = figrc011_xpath(l_docHandle,l_rqt.dst_lgdnom      )
         let l_destino.lgdnum          = figrc011_xpath(l_docHandle,l_rqt.dst_lgdnum      )
         let l_destino.lclbrrnom       = figrc011_xpath(l_docHandle,l_rqt.dst_lclbrrnom   )
         let l_destino.brrnom          = figrc011_xpath(l_docHandle,l_rqt.dst_brrnom      )
         let l_destino.cidnom          = figrc011_xpath(l_docHandle,l_rqt.dst_cidnom      )
         let l_destino.ufdcod          = figrc011_xpath(l_docHandle,l_rqt.dst_ufdcod      )
         let l_destino.lclrefptotxt    = figrc011_xpath(l_docHandle,l_rqt.dst_lclrefptotxt)
         let l_destino.endzon          = figrc011_xpath(l_docHandle,l_rqt.dst_endzon      )
         let l_destino.lgdcep          = figrc011_xpath(l_docHandle,l_rqt.dst_lgdcep      )
         let l_destino.lgdcepcmp       = figrc011_xpath(l_docHandle,l_rqt.dst_lgdcepcmp   )
         let l_destino.lclltt          = figrc011_xpath(l_docHandle,l_rqt.dst_lclltt      )
         let l_destino.lcllgt          = figrc011_xpath(l_docHandle,l_rqt.dst_lcllgt      )
         let l_destino.dddcod          = figrc011_xpath(l_docHandle,l_rqt.dst_dddcod      )
         let l_destino.lcltelnum       = figrc011_xpath(l_docHandle,l_rqt.dst_lcltelnum   )
         let l_destino.lclcttnom       = figrc011_xpath(l_docHandle,l_rqt.dst_lclcttnom   )
         let l_destino.c24lclpdrcod    = figrc011_xpath(l_docHandle,l_rqt.dst_c24lclpdrcod)
         let l_destino.ofnnumdig       = figrc011_xpath(l_docHandle,l_rqt.dst_ofnnumdig   )
         let l_destino.emeviacod       = figrc011_xpath(l_docHandle,l_rqt.dst_emeviacod   )


         #----------------------------------------------------------------

         display "l_servico.c24astcod = ",l_servico.c24astcod
         if l_servico.c24astcod = "G16" or
            l_servico.c24astcod = "G17" then
            call bdatm002_levatraz(l_docHandle)
                 returning l_servicocmp.*
            call bdatm002_consiste_servico(l_servico.c24astcod,
                                           l_servico.funmat,
                                           l_servico.solicdat,
                                           l_servico.solichor,
                                           l_servico.succod,
                                           l_servico.ramcod,
                                           l_servico.aplnumdig,
                                           l_servico.itmnumdig)
                 returning l_valido
            if l_valido = true then
               display "JÁ EXISTE UM SERVICO GRAVADO"
               let l_errcod = 268
               let l_errmsg = "JÁ EXISTE UM SERVICO GRAVADO COM ESSES DADOS"
               return ctf00m06_xmlerro(m_servico, l_errcod, l_errmsg)
            end if
         end if

         call figrc011_fim_parse()
         display 'SRV SMART: valores recebidos pelo LISTENER'

         let l_retorno = null

         call cts55g00(l_servico.*, l_ocorrencia.*, l_destino.*,l_servicocmp.*)
              returning l_errcod, l_errmsg,
                        l_cts55g00.atdsrvnum,
                        l_cts55g00.atdsrvano,
                        l_cts55g00.atdhorpvt

         if l_errcod is null or l_errcod != 0 then
            # nao enviar errcod nulo como retorno
            if l_errcod is null then
               let l_errcod = 999
            end if

            display 'ERRO cts55g00: ', l_errcod, ' / ', l_errmsg clipped

            return ctf00m06_xmlerro(m_servico, l_errcod, l_errmsg)
         else
            let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
                            "<RESPONSE>",
                            "<SERVICE>INCLUIR_SERVICO_WEB</SERVICE>",
                            "<ERRO>",
                              "<CODIGO>0</CODIGO>",
                              "<DESCRICAO></DESCRICAO>",
                            "</ERRO>",
                            "<SERVICO>",
                              "<NUMERO>"   , l_cts55g00.atdsrvnum, "</NUMERO>",
                              "<ANO>"      , l_cts55g00.atdsrvano, "</ANO>",
                              "<PREVATEND>", l_cts55g00.atdhorpvt, "</PREVATEND>",
                              "<DATASOLIC>", l_servico.solicdat  , "</DATASOLIC>",
                              "<HORASOLIC>", l_servico.solichor  , "</HORASOLIC>",
                            "</SERVICO>",
                            "</RESPONSE>"
         end if
        # Verificar com Issao.
         if l_servico.c24astcod = "G16" or
            l_servico.c24astcod = "G17" then
              call bdatm002_verifica_envio_fax()
                   returning l_envia
              display "envia = ",l_envia
              if l_envia = true then
                 display "1664 - entrei"
                 call cts00m24(l_cts55g00.atdsrvnum,
                               l_cts55g00.atdsrvano,
                               l_destino.ofnnumdig ,
                                                "F")
              end if
         end if

      #------------------------------------------------------
      when "OBTER_SALDO_PET"
      #------------------------------------------------------

           let param_xml.succod    = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/SUCURSAL")
           let param_xml.ramcod    = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/RAMO")
           let param_xml.aplnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/APOLICE")
           let param_xml.itmnumdig = figrc011_xpath(l_docHandle,"/REQUEST/DOCUMENTO/APOLICE/ITEM")
           let param_xml.grp_natz  = figrc011_xpath(l_docHandle,"/REQUEST/GRUPOTIPOSERVICO")
           let param_xml.filtro  = figrc011_xpath(l_docHandle,"/REQUEST/TIPO_FILTRO")

           let l_msgerro = null
           if param_xml.succod is null then
              let l_msgerro = 'PARAMETRO DE ENTRADA (SUCURSAL)'
           end if

           if param_xml.ramcod is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (RAMO)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (RAMO)'
              end if
           else
              call cty18g00_valida_ramo(param_xml.ramcod)
              returning lr_cty18g00.resultado, lr_cty18g00.mensagem
              if lr_cty18g00.resultado = 2 then
                    return ctf00m06_xmlerro(m_servico,2,lr_cty18g00.mensagem)

              else
                 if lr_cty18g00.resultado = 3 then
                    return ctf00m06_xmlerro(m_servico,3,lr_cty18g00.mensagem)
                 end if
              end if
           end if

           if param_xml.filtro is null then
	            if l_msgerro is not null then
		             let l_msgerro = l_msgerro clipped,', (FILTRO)'
              else
		             let l_msgerro = 'PARAMETRO DE ENTRADA (FILTRO)'
              end if
           end if

           if param_xml.aplnumdig is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (APOLICE)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (APOLICE)'
              end if
           end if

           ## -- Apenas Apólice Auto possui Item -- ##

           if param_xml.ramcod = 531      or
              param_xml.ramcod =  31      then
               if param_xml.itmnumdig is null then
                  if l_msgerro is not null then
                     let l_msgerro = l_msgerro clipped ,', (ITEM)'
                  else
                     let l_msgerro = 'PARAMETRO DE ENTRADA (ITEM)'
                  end if
               end if
           end if

           if param_xml.grp_natz  is null then
              if l_msgerro is not null then
                 let l_msgerro = l_msgerro clipped ,', (GRUPO TIPO SERVICO)'
              else
                 let l_msgerro = 'PARAMETRO DE ENTRADA (GRUPO TIPO SERVICO)'
              end if
           end if

           if l_msgerro is not null then
              let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
              return ctf00m06_xmlerro(m_servico,1,l_msgerro)
           end if

           if param_xml.grp_natz = 'PET' then
              let param_xml.c24astcod = 'PE1'
           else
              let l_msgerro = "PARAMETRO DE ENTRADA (GRUPO TIPO SERVICO) NAO CADASTRADO."
              return ctf00m06_xmlerro(m_servico,2,l_msgerro)
           end if

           #-- Se apolice informada for de AUTO chama funcao de validacao --#
           #-- Apolice de RE ja deve vir validada do sistema RE           --#

           if param_xml.ramcod = 531      or
              param_xml.ramcod =  31      then

              #if param_xml.filtro = 1 then

                ## -- Se pesquisa foi feita pelo numero de cartao sistema -- ##
                ## -- verifica se ha outros itens na apolice que possui   -- ##
                ## -- beneficio PET e retorna saldo ou mensagem critica   -- ##


                open cbdatm002002 using param_xml.succod,
                                        param_xml.aplnumdig

                fetch cbdatm002002 into l_cont_itm


                if l_cont_itm = 0 then
                   return ctf00m06_xmlerro(m_servico,2,m_msg)
                end if


                open cbdatm002001 using param_xml.succod,
                                        param_xml.aplnumdig

                foreach cbdatm002001 into param_xml.itmnumdig

                   call cty18g00_valida_apolice_AUTO(param_xml.succod,
                                                     param_xml.aplnumdig,
                                                     param_xml.itmnumdig,
                                                     param_xml.ramcod)
                   returning lr_cty18g00.resultado, lr_cty18g00.mensagem

                   if lr_cty18g00.resultado <> 2  and
                      lr_cty18g00.resultado <> 3  then
                      exit foreach
                   end if

                end foreach
                close cbdatm002001

                if lr_cty18g00.resultado = 2 then
                   return ctf00m06_xmlerro(m_servico,2,lr_cty18g00.mensagem)

                else
                  if lr_cty18g00.resultado = 3 then
                     return ctf00m06_xmlerro(m_servico,3,lr_cty18g00.mensagem)
                  end if
                end if
           end if


           call cta02m15_qtd_servico_pet(param_xml.ramcod
                                        ,param_xml.succod
                                        ,param_xml.aplnumdig
                                        ,param_xml.itmnumdig
                                        ,''         ---> prpor
                                        ,''         ---> prpnumdig
                                        ,'20100101' ---> data comeco sistema Pet
                                        ,param_xml.c24astcod
                                        ,''         ---> bnfnum
                                        )
           returning  l_qtd, lr_cty18g00.mensagem, lr_cty18g00.resultado


           if lr_cty18g00.resultado = 3 then
              return ctf00m06_xmlerro(m_servico,3,lr_cty18g00.mensagem)
           end if


           if param_xml.ramcod = 531 or
              param_xml.ramcod = 31 then
              display "Tamanho"
              let l_itmnumdig = param_xml.itmnumdig
              let l_tamanho = length(l_itmnumdig)

              display "l_tamanho = ",l_tamanho
              display "l_itmnumdig = ",l_itmnumdig

              let param_xml.itmnumdig = l_itmnumdig[1,l_tamanho -1 ]


              display "param_xml.itmnumdig = ",param_xml.itmnumdig
           end if


           #-- Verificar se limite vai ser engessado  --#
           #-- ou se vai colocar em uma tabela        --#

           call bdatm002_busca_limites_PET(param_xml.ramcod
                                          ,param_xml.succod
                                          ,param_xml.aplnumdig
                                          ,l_itmnumdig)
           returning l_qtd_limite

           let l_retorno =  "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>"
                           ,"<RESPONSE>"
                           ,"<TIPOSERVICOS>"
                           ,"<SERVICO>OBTER_SALDO_PET</SERVICO>"
                           ,"<LIMITES>"
                           ,"<LIMITE>"
                           ,"<CONTRATADO>",l_qtd_limite, "</CONTRATADO>"
                           ,"<UTILIZADO>", l_qtd, "</UTILIZADO>"
                           ,"</LIMITE>"
                           ,"</LIMITES>"
                           ,"</TIPOSERVICOS>"
                           ,"<DOCUMENTOS>"
                           ,"<APOLICE>", param_xml.aplnumdig, "</APOLICE>"
                           ,"<SUCURSAL>", param_xml.succod, "</SUCURSAL>"
                           ,"<RAMO>", param_xml.ramcod, "</RAMO>"
                           ,"<ITEM>", param_xml.itmnumdig, "</ITEM>"
                           ,"</DOCUMENTOS>"
                           ,"<MENSAGENS>"
                           ,"<MENSAGEM></MENSAGEM>"
                           ,"</MENSAGENS>"
                           ,"</RESPONSE>"

      otherwise
           let l_msgerro = "Erro na chamada do servico - ", m_servico clipped
           return ctf00m06_xmlerro(m_servico, 3, l_msgerro)

 end case

 if  m_servico !=  "INCLUIR_SERVICO_WEB" or
     m_servico is  null then
     call figrc011_fim_parse()
 end if

 display 'XML RETORNO: ' , l_retorno clipped

 return l_retorno

end function

#---------------------------------------------------------------------------
function bdatm002_ObterTiposServicosDocumento(param)
#---------------------------------------------------------------------------

  define param         record
         succod        like datrligapol.succod     ,
         ramcod        like datrservapol.ramcod    ,
         aplnumdig     like datrligapol.aplnumdig  ,
         itmnumdig     like abbmdoc.itmnumdig      ,
         edsnumdig     like abamdoc.edsnumdig      ,
         rmemdlcod     like rsamseguro.rmemdlcod   ,
         c24astcod     like datmligacao.c24astcod
  end record

  define lr_natureza   record
         ntzcod        smallint
        ,ntzdes        char(40)
        ,socntzgrpcod  smallint
        ,webntzdes     like datksocntz.webntzdes
  end record

  define lr_problema   record
         c24pbmcod     smallint
        ,c24pbmdes     char(40)
  end record

  define lr_espec      record
         espcod        like dbskesp.espcod
        ,webespdes     like dbskesp.webespdes
  end record

  define l_cod_erro   smallint
        ,l_desc_erro  char(40)
        ,l_sql        char(500)
        ,l_xml        char(32000)

  define l_aux        record
         qtd_natur    smallint
        ,qtd_prob     smallint
        ,qtd_espec    smallint
        ,qtd1         smallint
        ,qtd2         smallint
        ,qtd3         smallint
  end record

  define lr_claus     record
         clscod       like rsdmclaus.clscod
        ,plncod       like datksegsau.plncod
        ,rmemdlcod    like datrsocntzsrvre.rmemdlcod
        ,erro         smallint
        ,prporg       like rsdmdocto.prporg
        ,prpnumdig    like rsdmdocto.prpnumdig
        ,lgdtxt       char (65)
        ,brrnom       like datmlcl.brrnom
        ,cidnom       like datmlcl.cidnom
        ,ufdcod       like datmlcl.ufdcod
        ,lgdnum       like datksegsau.lgdnum
        ,lgdcep       like datksegsau.lgdcep
        ,lgdcepcmp    like datksegsau.lgdcepcmp
        ,lclrefptotxt like datksegsau.lclrefptotxt
        ,crtsaunum    like datksegsau.crtsaunum
        ,succod_g     like datrligapol.succod
        ,ramcod_g     like datrservapol.ramcod
        ,aplnumdig_g  like datrligapol.aplnumdig
        ,cmnnumdig    like pptmcmn.cmnnumdig
        ,endlgdtip    like rlaklocal.endlgdtip
        ,endlgdnom    like rlaklocal.endlgdnom
        ,endnum       like rlaklocal.endnum
        ,endbrr       like rlaklocal.endbrr
        ,endcid       like rlaklocal.endcid
        ,ufdcod_g     like rlaklocal.ufdcod
        ,endcep       like rlaklocal.endcep
        ,endcepcmp    like rlaklocal.endcepcmp
        ,endcmp       like rlaklocal.endcmp
        ,clscod_g     like aackcls.clscod
  end record

  define l_qtd_atendimento integer
        ,l_qtd_limite      integer

  initialize lr_espec.*    to null
  initialize lr_problema.* to null
  initialize lr_natureza.* to null
  initialize l_aux.* to null
  initialize lr_claus.* to null

  let l_cod_erro  = null
  let l_desc_erro = null
  let l_sql       = null
  let l_xml       = null
  let l_qtd_atendimento = null
  let l_qtd_limite      = null

  ## ATRIBUIR VALOR AS GLOBAIS
  let g_documento.ciaempcod = 1

  call ctf00m01_clausulas(param.succod
                         ,param.ramcod
                         ,param.aplnumdig
                         ,param.itmnumdig
                         ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,''
                         ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,''
                         ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'')
                returning lr_claus.*

  ## CARREGA TEMPORARIA DE NATUREZA
  whenever error continue
     delete from cts12g03_natureza
  whenever error stop

  call cts12g03(1                ---> ntztip
               ,param.c24astcod
               ,param.ramcod
               ,lr_claus.clscod
               ,param.rmemdlcod
               ,0                ---> prporg
               ,0                ---> prpnumdig
               ,0                ---> socntzgrpcod
               ,"B")
     returning l_cod_erro ,l_desc_erro

  if l_cod_erro <> 0 then
     return ctf00m06_xmlerro(m_servico,4,l_desc_erro)
  end if

  let l_cod_erro  = null
  let l_desc_erro = null

  ## CARREGA TEMPORARIA DE PROBLEMA
  whenever error continue
     delete from ctc48m04_problema
  whenever error stop

  call ctc48m04(''   ---> codagrup
               ,'')  ---> pgm
     returning l_cod_erro ,l_desc_erro

  if l_cod_erro <> 0 then
     return ctf00m06_xmlerro(m_servico,5,l_desc_erro)
  end if

  ---> PSI - 223689 - Limites do Documento.
  call bdatm002_ObterLimitesDocumento(param.succod
                                     ,param.ramcod
                                     ,param.aplnumdig
                                     ,param.edsnumdig
                                     ,param.itmnumdig
                                     ,param.c24astcod)
       returning l_qtd_atendimento
                ,l_qtd_limite

  let l_sql = " select a.ntzcod              "
             ,"       ,a.ntzdes              "
             ,"       ,a.socntzgrpcod        "
             ,"       ,b.webntzdes           "
             ,"  from cts12g03_natureza a    "
             ,"      ,datksocntz b           "
             ," where b.socntzcod = a.ntzcod "
             ,"   and b.webvslflg = 'S'      "
             ," order by a.socntzgrpcod      "
  prepare sel_natureza from l_sql
  declare c_bdatm00201 cursor for sel_natureza

  let l_sql = " select c24pbmcod         "
             ,"       ,c24pbmdes         "
             ,"       ,c24pbmgrpcod      "
             ,"   from ctc48m04_problema "
             ,"  where c24pbmgrpcod = ?  "
             ,"  order by c24pbmgrpcod   "
  prepare sel_problema from l_sql
  declare c_bdatm00202 cursor for sel_problema

  let l_sql = " select count(*)        "
             ," from ctc48m04_problema "
             ," where c24pbmgrpcod = ? "
  prepare sel_problema2 from l_sql
  declare c_bdatm00203 cursor for sel_problema2

  let l_sql = " select espcod       "
             ,"       ,webespdes    "
             ,"   from dbskesp      "
             ,"  where espsit = 'A' "
             ,"  order by espdes    "
  prepare sel_espec from l_sql
  declare c_bdatm00204 cursor for sel_espec

  let l_sql = " select count(*)    "
             ,"   from dbskesp     "
             ," where espsit = 'A' "
  prepare sel_espec2 from l_sql
  declare c_bdatm00205 cursor for sel_espec2

  let l_sql = " select count(*) "
             ," from cts12g03_natureza "
  prepare sel_natureza2 from l_sql
  declare c_bdatm00206 cursor for sel_natureza2

  ---> Verifica Qtd. de Naturezas
  open c_bdatm00206
  fetch c_bdatm00206 into l_aux.qtd_natur

  ---> Verifica Qtd. de Especialidades
  open c_bdatm00205
  fetch c_bdatm00205 into l_aux.qtd_espec

  let l_aux.qtd1 = 0

  open c_bdatm00201
  foreach c_bdatm00201 into lr_natureza.ntzcod
                           ,lr_natureza.ntzdes
                           ,lr_natureza.socntzgrpcod
                           ,lr_natureza.webntzdes

     if lr_natureza.webntzdes is null or
        lr_natureza.webntzdes = ''    then
        let lr_natureza.webntzdes = lr_natureza.ntzdes
     end if

     let l_aux.qtd1 = l_aux.qtd1 + 1

     if l_aux.qtd1 = 1 then
        let l_xml =
           "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>"
          ,"<RESPONSE>"
          ,"<SERVICO>OBTER_TIPOS_SERVICOS_DOCUMENTO</SERVICO>"
          ,"<LIMITES>"
          ,"<LIMITE>"

          if l_qtd_limite is null      and
             l_qtd_atendimento is null then

             let l_xml = l_xml clipped
             ,"<CONTRATADO>SEM LIMITE</CONTRATADO>"
             ,"<UTILIZADO></UTILIZADO>"
          else

             let l_xml = l_xml clipped
             ,"<CONTRATADO>" ,l_qtd_limite clipped ,"</CONTRATADO>"
             ,"<UTILIZADO>" ,l_qtd_atendimento clipped ,"</UTILIZADO>"
          end if

          let l_xml = l_xml clipped
          ,"<TIPO>Quantidade</TIPO>"
          ,"<TIPOSERVICOS>"
          ,"<TIPOSERVICO>"
          ,"<CODIGO>"    ,lr_natureza.ntzcod clipped ,"</CODIGO>"
          ,"<NOME>" ,lr_natureza.ntzdes clipped ,"</NOME>"
          ,"<DESCRICAO>" ,lr_natureza.webntzdes clipped ,"</DESCRICAO>"
     else
        let l_xml = l_xml clipped
          ,"</TIPOSERVICO>"
          ,"<TIPOSERVICO>"
          ,"<CODIGO>"    ,lr_natureza.ntzcod clipped ,"</CODIGO>"
          ,"<NOME>" ,lr_natureza.ntzdes clipped ,"</NOME>"
          ,"<DESCRICAO>" ,lr_natureza.webntzdes clipped ,"</DESCRICAO>"
     end if

     let l_aux.qtd3 = 0

     ---> Verifica Qtd. de Problemas
     open c_bdatm00203 using lr_natureza.socntzgrpcod
     fetch c_bdatm00203 into l_aux.qtd_prob

     let lr_problema.c24pbmcod = null
     let lr_problema.c24pbmdes = null

     open c_bdatm00202 using lr_natureza.socntzgrpcod
     foreach c_bdatm00202 into lr_problema.c24pbmcod
                              ,lr_problema.c24pbmdes

        let l_aux.qtd3 = l_aux.qtd3 + 1

        if l_aux.qtd3 = 1 then
           let l_xml = l_xml clipped
             ,"<PROBLEMAS>"
             ,"<PROBLEMA>"
             ,"<CODIGO>"    ,lr_problema.c24pbmcod clipped ,"</CODIGO>"
             ,"<DESCRICAO>" ,lr_problema.c24pbmdes clipped ,"</DESCRICAO>"
             ,"</PROBLEMA>"
        else
           let l_xml = l_xml clipped
             ,"<PROBLEMA>"
             ,"<CODIGO>"    ,lr_problema.c24pbmcod clipped ,"</CODIGO>"
             ,"<DESCRICAO>" ,lr_problema.c24pbmdes clipped ,"</DESCRICAO>"
             ,"</PROBLEMA>"
        end if

        if l_aux.qtd3 = l_aux.qtd_prob then
           let l_xml = l_xml clipped
             ,"</PROBLEMAS>"
        end if

     end foreach

     if lr_problema.c24pbmcod is null then
        let l_xml = l_xml clipped
             ,"<PROBLEMAS>"
             ,"<PROBLEMA>"
             ,"<CODIGO>999</CODIGO>"
             ,"<DESCRICAO></DESCRICAO>"
             ,"</PROBLEMA>"
             ,"</PROBLEMAS>"
     end if

     let l_aux.qtd2 = 0

     if param.c24astcod = 'S63' then
        open c_bdatm00204
        foreach c_bdatm00204 into lr_espec.espcod
                                 ,lr_espec.webespdes

           let l_aux.qtd2 = l_aux.qtd2 + 1

           if l_aux.qtd2 = 1 then
              let l_xml = l_xml clipped
                  ,"<ESPECIALIDADES>"
                  ,"<ESPECIALIDADE>"
                  ,"<CODIGO>"    ,lr_espec.espcod    clipped ,"</CODIGO>"
                  ,"<DESCRICAO>" ,lr_espec.webespdes clipped ,"</DESCRICAO>"
                  ,"</ESPECIALIDADE>"
           else
              let l_xml = l_xml clipped
                  ,"<ESPECIALIDADE>"
                  ,"<CODIGO>"    ,lr_espec.espcod    clipped ,"</CODIGO>"
                  ,"<DESCRICAO>" ,lr_espec.webespdes clipped ,"</DESCRICAO>"
                  ,"</ESPECIALIDADE>"
           end if

           if l_aux.qtd2 = l_aux.qtd_espec then
              let l_xml = l_xml clipped
                  ,"</ESPECIALIDADES>"
           end if
        end foreach
     else
        let l_xml = l_xml clipped
                  ,"<ESPECIALIDADES>"
                  ,"<ESPECIALIDADE>"
                  ,"<CODIGO></CODIGO>"
                  ,"<DESCRICAO></DESCRICAO>"
                  ,"</ESPECIALIDADE>"
                  ,"</ESPECIALIDADES>"
     end if

  end foreach

  if l_aux.qtd_natur = 0 or
     length(l_xml)   = 0 then
     return ctf00m06_xmlerro(m_servico,9999,'ATENDIMENTO NAO PREVISTO PARA O DOCUMENTO SELECIONADO, ENTRE EM CONTATO COM O SEU CORRETOR..')
  end if

  let l_xml = l_xml clipped
             ,"</TIPOSERVICO>"
             ,"</TIPOSERVICOS>"
             ,"</LIMITE>"
             ,"</LIMITES>"
             ,"</RESPONSE>"

  return l_xml

end function

#---------------------------------------------------------------------------
function bdatm002_ObterLimitesDocumento(lr_parametro)
#---------------------------------------------------------------------------

  define lr_parametro   record
         succod         like abamapol.succod
        ,ramcod		      like rsamseguro.ramcod
        ,aplnumdig	    like abamapol.aplnumdig
        ,edsnumdig      like abamdoc.edsnumdig
        ,itmnumdig	    like abbmdoc.itmnumdig
        ,c24astcod      like datmligacao.c24astcod
  end record

  define lr_retorno     record
     resultado          smallint
    ,mensagem           char(60)
  end record

  --> Controles de Atendimento - Help Desk
  define l_hdk        record
         qtd_lmt_s66  smallint            --> Limite Total (Auto/RE)
        ,qtd_utz_s66  smallint            --> Quantidade Utilizada (Auto/RE)
        ,qtd_lmt_s67  smallint            --> Limite Total (Auto/RE)
        ,qtd_utz_s67  smallint            --> Quantidade Utilizada (Auto/RE)
        ,pode_s66     char(01) -- "S"/"N" --> Se pode ou nao gerar S66
        ,pode_s67     char(01) -- "S"/"N" --> Se pode ou nao gerar S67
  end record

  define l_xml        char(5000)

  define l_clscod  char (03)
  define l_sem_uso char(01)

  define l_flag_limite     char(01)
        ,l_qtd_atendimento integer
        ,l_qtd_limite      integer
        ,l_confirma        char(01)

  initialize lr_retorno.*, l_hdk.* to null

  let l_flag_limite     = null
  let l_qtd_atendimento = null
  let l_qtd_limite      = null
  let l_confirma        = null
  let l_clscod          = null
  let l_sem_uso         = null

  let l_xml             = null

  ## ATRIBUIR VALOR AS GLOBAIS
  let g_documento.ciaempcod = 1

  call faemc144_clausula(lr_parametro.succod,
                         lr_parametro.aplnumdig,
                         lr_parametro.itmnumdig)
             returning   l_sem_uso,
                         l_clscod, -- clausula
                         l_sem_uso,
                         l_sem_uso

  if lr_parametro.c24astcod = 'S10' then
     call cty05g02_envio_socorro(lr_parametro.ramcod
                                ,lr_parametro.succod
                                ,lr_parametro.aplnumdig
                                ,lr_parametro.itmnumdig)
                       returning lr_retorno.resultado
                                ,lr_retorno.mensagem
                                ,l_flag_limite
  else

     #----------------------------------------
     --> Tratamento para Assuntos do Help Desk
     #----------------------------------------
     if lr_parametro.c24astcod = 'S66' or
        lr_parametro.c24astcod = 'S67' then

        --> Obtem Limites e Utilizacoes do Help Desk
        call cty05g07_s66_s67(lr_parametro.ramcod
                             ,lr_parametro.succod
                             ,lr_parametro.aplnumdig
                             ,lr_parametro.itmnumdig
                             ,lr_parametro.c24astcod )
                    returning l_hdk.*

        if lr_parametro.c24astcod = 'S66' then

           if l_hdk.pode_s66 = "N" then
              let l_qtd_atendimento = null
              let l_qtd_limite      = null
           else
              let l_qtd_atendimento = l_hdk.qtd_utz_s66
              let l_qtd_limite      = l_hdk.qtd_lmt_s66
           end if

        else

           if l_hdk.pode_s67 = "N" then
              let l_qtd_atendimento = null
              let l_qtd_limite      = null
           else
              let l_qtd_atendimento = l_hdk.qtd_utz_s67
              let l_qtd_limite      = l_hdk.qtd_lmt_s67
           end if
        end if
     else

        #----------------------------------
        --> Tratamento para Demais Assuntos
        #----------------------------------
        call cty05g02_serv_residencia(lr_parametro.ramcod
                                     ,lr_parametro.succod
                                     ,lr_parametro.aplnumdig
                                     ,lr_parametro.itmnumdig
                                     ,lr_parametro.c24astcod
                                     ,''  --->  bnfnum
                                     ,'') ---> crtsaunum
                            returning lr_retorno.resultado
                                     ,lr_retorno.mensagem
                                     ,l_flag_limite
                                     ,l_qtd_atendimento
                                     ,l_qtd_limite

     end if
  end if

  return l_qtd_atendimento
        ,l_qtd_limite

end function

#-------------------------------------------------------------------------------
function ctx19g00_consiste_env(l_par_cons) ## Consistir parametros obrigatórios
#-------------------------------------------------------------------------------

 define msg_erro  char(80)

 define l_par_cons record
         segnumdig     like datmsegviaend.segnumdig ,
         endlgdtip     like datmsegviaend.endlgdtip ,
         endlgd        like datmsegviaend.endlgd    ,
         endnum        like datmsegviaend.endnum    ,
         endcep        like datmsegviaend.endcep    ,
         endcepcmp     like datmsegviaend.endcepcmp ,
         endcid        like datmsegviaend.endcid    ,
         endufd        like datmsegviaend.endufd    ,
         tipo          smallint
 end record

 let msg_erro = " "

 while l_par_cons.tipo <= 8
       let l_par_cons.tipo = l_par_cons.tipo + 1

       case l_par_cons.tipo
            when 1
                if l_par_cons.segnumdig is null or
                   l_par_cons.segnumdig = " " then
                   let msg_erro = "Parametro segurado Nulo "
                end if
            when 2
                if l_par_cons.endlgdtip is null or
                   l_par_cons.endlgdtip = " " then
                   let msg_erro = "Parametro Tipo Logrdouro Nulo "
                end if
            when 3
                if l_par_cons.endlgd is null or
                   l_par_cons.endlgd = " " then
                   let msg_erro = "Parametro Logradouro Nulo "
                end if
            when 4
                if l_par_cons.endnum is null or
                   l_par_cons.endnum = " " then
                   let msg_erro = "Parametro Numero do Logradouro Nulo "
                end if
            when 5
                if l_par_cons.endcep is null or
                   l_par_cons.endcep = " " then
                   let msg_erro = "Parametro CEP Nulo "
                end if
            when 6
                if l_par_cons.endcepcmp is null or
                   l_par_cons.endcepcmp = " " then
                   let msg_erro = "Parametro Compl. CEP Nulo "
                end if
            when 7
                if l_par_cons.endcid is null or
                   l_par_cons.endcid = " " then
                   let msg_erro = "Parametro Cidade Nulo "
                end if
            when 8
                if l_par_cons.endufd is null or
                   l_par_cons.endufd = " " then
                   let msg_erro = "Parametro Estado Nulo "
                end if
            otherwise
                   let msg_erro = " "
                   let l_par_cons.tipo = 9
       end case

     if msg_erro <> " " then
        exit while
     end if
 end while

return msg_erro

end function

#-----------------------------------------------------------------------------
function bdatm002_carregaVariaveis(l_param)
#-----------------------------------------------------------------------------

   define l_param         record
          atdsrvnum       like datmservico.atdsrvnum
         ,atdsrvano       like datmservico.atdsrvano
   end record

   define l_lignum        like datmligacao.lignum
	       ,l_atdfnlflg     like datmservico.atdfnlflg

   define lr_serv     record
          atdetpcod   like datmservico.atdetpcod,
	        atddatprg   like datmservico.atddatprg,
	        atdhorprg   like datmservico.atdhorprg,
          atdsrvorg   like datmservico.atdsrvorg,
          assunto     like datmligacao.c24astcod
   end record

   define lr_altsrv   record
          asitipcod   like datmservico.asitipcod,
   	      prslocflg   like datmservico.prslocflg,
   	      frmflg      char(1),
   	      vclcoddig   like datmservico.vclcoddig,
   	      camflg      char(1)
   end record

   initialize l_lignum , l_atdfnlflg to null
   initialize lr_serv.*, lr_altsrv.* to null

   let g_origem                 = "WEB"  ---> Portal do Segurado
   let g_documento.solnom       = "PORTAL WEB"
   let g_issk.funmat            = 999999
   let g_issk.empcod            = 1
   let g_issk.usrtip            = "F"
   let lr_altsrv.frmflg         = "N"

   ---> Empresa do Documento
   select a.ciaempcod
	       ,a.atdfnlflg
         ,b.succod
         ,b.ramcod
         ,b.aplnumdig
         ,b.itmnumdig
         ,b.edsnumref
         ,a.atdetpcod
         ,a.atddatprg
         ,a.atdhorprg
         ,a.atdsrvorg
         ,a.asitipcod
	 ,a.prslocflg
	 ,a.vclcoddig
     into g_documento.ciaempcod
	 ,l_atdfnlflg
	 ,g_documento.succod
	 ,g_documento.ramcod
	 ,g_documento.aplnumdig
	 ,g_documento.itmnumdig
	 ,g_documento.edsnumref
	 ,lr_serv.atdetpcod
	 ,lr_serv.atddatprg
	 ,lr_serv.atdhorprg
	 ,lr_serv.atdsrvorg
	 ,lr_altsrv.asitipcod
	 ,lr_altsrv.prslocflg
	 ,lr_altsrv.vclcoddig
     from datmservico  a
	 ,datrservapol b
    where a.atdsrvnum = l_param.atdsrvnum
      and a.atdsrvano = l_param.atdsrvano
      and a.atdsrvnum = b.atdsrvnum
      and a.atdsrvano = b.atdsrvano

   ---> Ligacao do servico
   select min (lignum)
     into l_lignum
     from datrligsrv
    where atdsrvnum = l_param.atdsrvnum
      and atdsrvano = l_param.atdsrvano


   ---> Assunto da Ligacao
   select c24astcod
     into g_documento.c24astcod
     from datmligacao
    where lignum = l_lignum

   let lr_serv.assunto = g_documento.c24astcod

   select vclcamtip from datmservicocmp a
    where a.atdsrvnum = l_param.atdsrvnum
      and a.atdsrvano = l_param.atdsrvano

   let lr_altsrv.camflg = "N"
   if sqlca.sqlcode <> notfound then
      let lr_altsrv.camflg = "S"
   end if

   return l_atdfnlflg, lr_serv.*, lr_altsrv.*

end function

#-----------------------------------------------------------------------------
function bdatm002_carregaVariaveisGlobais_2(l_param)
#-----------------------------------------------------------------------------

   define l_param         record
          succod          like datrligapol.succod
         ,ramcod          like datrligapol.ramcod
         ,aplnumdig       like datrligapol.aplnumdig
         ,itmnumdig       like datrligapol.itmnumdig
         ,edsnumdig       like datrligapol.edsnumref
   end record

   let g_origem                 = "WEB"  ---> Portal do Segurado
   let g_documento.solnom       = "PORTAL WEB"
   let g_issk.funmat            = 999999
   let g_issk.empcod            = 1
   let g_issk.usrtip            = "F"
   let g_documento.ligcvntip    = 0
   let g_c24paxnum              = 0
   let g_documento.c24soltipcod = 1   ---> Segurado
   let g_documento.soltip       = "S" ---> Segurado
   let g_documento.atdsrvorg    = 9
   let g_documento.succod       = l_param.succod
   let g_documento.ramcod       = l_param.ramcod
   let g_documento.aplnumdig    = l_param.aplnumdig
   let g_documento.itmnumdig    = l_param.itmnumdig
   let g_documento.edsnumref    = l_param.edsnumdig
   let g_documento.crtsaunum    = null

   let g_documento.prporg       = null
   let g_documento.prpnumdig    = null
   let g_documento.fcapacorg    = null
   let g_documento.fcapacnum    = null
   let g_documento.lclnumseq    = null # Foi inicializando a variavel
   let g_documento.rmerscseq    = null # Foi inicializando a variavel


end function

#-----------------------------------------------------------------------------
function bdatm002_obterInformacoesServico(l_param)
#-----------------------------------------------------------------------------

   define l_param     record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define al_mult        array[10] of record
          atdmltsrvnum   like datratdmltsrv.atdmltsrvnum,
          atdmltsrvano   like datratdmltsrv.atdmltsrvano
   end record

   define l_nat_prob  record
          atddat      like datmservico.atddat,
          atdhor      like datmservico.atdhor,
          atddatprg   like datmservico.atddatprg,
          atdhorprg   like datmservico.atdhorprg,
          espdes      like dbskesp.espdes,
          socntzcod   like datksocntz.socntzcod,
          socntzdes   like datksocntz.socntzdes,
          c24pbmcod   like datrsrvpbm.c24pbmcod,
          c24pbmdes   like datrsrvpbm.c24pbmdes,
          webntzdes   like datksocntz.webntzdes
   end record

   define lr_retorno_copia  record
        xml_retorno         char(32000)
       ,logtip              char(10)
       ,lognom              char(50)
       ,lognum              integer
       ,bairro              char(50)
       ,cidnom              like glakcid.cidnom
       ,ufdcod              like glakcid.ufdcod
       ,lclrefptotxt        like datmlcl.lclrefptotxt
       ,endzon              like datmlcl.endzon
       ,lgdcep              like datmlcl.lgdcep
       ,lgdcepcmp           like datmlcl.lgdcepcmp
       ,lclcttnom           like datmlcl.lclcttnom
       ,dddcod              like datmlcl.dddcod
       ,lcltelnum           like datmlcl.lcltelnum
       ,orrdat              like datmsrvre.orrdat
       ,socntzcod           like datmsrvre.socntzcod
       ,espcod              like datmsrvre.espcod
       ,c24pbmcod           like datkpbm.c24pbmcod
   end record

   define l_xmlRetorno char(32000)
   define l_mensagem   char(60)
   define l_resultado  smallint
   define l_count      smallint
   define l_index      smallint
   define l_index2     smallint

   let l_xmlRetorno = null
   let l_mensagem   = null
   let l_resultado  = null
   let l_count      = null
   let l_index      = null
   let l_index2     = null

   initialize lr_retorno_copia.* to null
   initialize l_nat_prob.* to null
   initialize al_mult to null

   let l_index = 1

   let al_mult[l_index].atdmltsrvnum = l_param.atdsrvnum
   let al_mult[l_index].atdmltsrvano = l_param.atdsrvano

   let l_index = l_index + 1

   select count(*)
     into l_count
     from datratdmltsrv
    where atdsrvnum = l_param.atdsrvnum
      and atdsrvano = l_param.atdsrvano

   declare c_multiplos cursor for
   select atdmltsrvnum
         ,atdmltsrvano
     from datratdmltsrv
    where atdsrvnum = l_param.atdsrvnum
      and atdsrvano = l_param.atdsrvano

   open c_multiplos
   foreach c_multiplos into al_mult[l_index].atdmltsrvnum
                           ,al_mult[l_index].atdmltsrvano

      let l_index = l_index + 1

   end foreach

   for l_index2 = 1 to l_count + 1

      if al_mult[l_index2].atdmltsrvnum is not null then
         select atddat
               ,atdhor
               ,atddatprg
               ,atdhorprg
           into l_nat_prob.atddat
               ,l_nat_prob.atdhor
               ,l_nat_prob.atddatprg
               ,l_nat_prob.atdhorprg
           from datmservico
          where atdsrvnum = al_mult[l_index2].atdmltsrvnum
            and atdsrvano = al_mult[l_index2].atdmltsrvano

         if sqlca.sqlcode = 0 then

             select a.socntzcod,
                    b.socntzdes,
                    b.webntzdes    ---> campo novo
               into l_nat_prob.socntzcod,
                    l_nat_prob.socntzdes,
                    l_nat_prob.webntzdes
               from datmsrvre a,
                    datksocntz b
              where a.socntzcod = b.socntzcod
                and a.atdsrvnum = al_mult[l_index2].atdmltsrvnum
                and a.atdsrvano = al_mult[l_index2].atdmltsrvano

            if sqlca.sqlcode = 0 then

               let g_documento.atdsrvnum = al_mult[l_index2].atdmltsrvnum
               let g_documento.atdsrvano = al_mult[l_index2].atdmltsrvano

               call ctf00m01_copia()
                    returning lr_retorno_copia.xml_retorno
                             ,lr_retorno_copia.logtip
                             ,lr_retorno_copia.lognom
                             ,lr_retorno_copia.lognum
                             ,lr_retorno_copia.bairro
                             ,lr_retorno_copia.cidnom
                             ,lr_retorno_copia.ufdcod
                             ,lr_retorno_copia.lclrefptotxt
                             ,lr_retorno_copia.endzon
                             ,lr_retorno_copia.lgdcep
                             ,lr_retorno_copia.lgdcepcmp
                             ,lr_retorno_copia.lclcttnom
                             ,lr_retorno_copia.dddcod
                             ,lr_retorno_copia.lcltelnum
                             ,lr_retorno_copia.orrdat
                             ,lr_retorno_copia.socntzcod
                             ,lr_retorno_copia.espcod
                             ,lr_retorno_copia.c24pbmcod

               if lr_retorno_copia.xml_retorno is null then

                  if l_nat_prob.atddatprg is null and
                     l_nat_prob.atdhorprg is null then
                     let l_nat_prob.atddatprg = l_nat_prob.atddat
                     let l_nat_prob.atdhorprg = l_nat_prob.atdhor
                  end if

                  if l_nat_prob.webntzdes is null or
                     l_nat_prob.webntzdes = ''    then
                     let l_nat_prob.webntzdes = l_nat_prob.socntzdes
                  end if

                  select espdes
                    into l_nat_prob.espdes
                    from dbskesp
                   where espcod = lr_retorno_copia.espcod

                  select c24pbmcod,
                         c24pbmdes
                    into l_nat_prob.c24pbmcod,
                         l_nat_prob.c24pbmdes
                    from datrsrvpbm
                   where atdsrvnum = al_mult[l_index2].atdmltsrvnum
                     and atdsrvano = al_mult[l_index2].atdmltsrvano
               else
                  let l_xmlRetorno = lr_retorno_copia.xml_retorno
                  exit for
               end if

               if l_index2 = 1 then
                  let l_xmlRetorno = "<RESPONSE>",
                                     "<SERVICO>OBTER_INFORMACAO_SERVICO</SERVICO>",
                                     "<TIPOSERVICOS>",
                                     "<TIPOSERVICO>",
                                     "<CODIGO>",l_nat_prob.socntzcod clipped,"</CODIGO>",
                                     "<NOME>",l_nat_prob.socntzdes clipped,"</NOME>",
                                     "<DESCRICAO>",l_nat_prob.webntzdes clipped,"</DESCRICAO>",
                                     "<PROBLEMA>",
                                     "<CODIGO>",l_nat_prob.c24pbmcod clipped , "</CODIGO>",
                                     "<DESCRICAO>" , l_nat_prob.c24pbmdes clipped , "</DESCRICAO>",
                                     "</PROBLEMA>",
                                     "<ESPECIALIDADE>",
                                     "<CODIGO>" ,lr_retorno_copia.espcod clipped ,"</CODIGO>",
                                     "<DESCRICAO>" ,l_nat_prob.espdes clipped ,"</DESCRICAO>",
                                     "</ESPECIALIDADE>",
                                     "</TIPOSERVICO>"
              else
                 let l_xmlRetorno = l_xmlRetorno clipped
                                   ,"<TIPOSERVICO>"
                                   ,"<CODIGO>",l_nat_prob.socntzcod clipped,"</CODIGO>"
                                   ,"<NOME>",l_nat_prob.socntzdes clipped,"</NOME>"
                                   ,"<DESCRICAO>",l_nat_prob.webntzdes clipped,"</DESCRICAO>"
                                   ,"<PROBLEMA>"
                                   ,"<CODIGO>",l_nat_prob.c24pbmcod clipped , "</CODIGO>"
                                   ,"<DESCRICAO>" , l_nat_prob.c24pbmdes clipped , "</DESCRICAO>"
                                   ,"</PROBLEMA>"
                                   ,"<ESPECIALIDADE>"
                                   ,"<CODIGO>" ,lr_retorno_copia.espcod clipped ,"</CODIGO>"
                                   ,"<DESCRICAO>" ,l_nat_prob.espdes clipped ,"</DESCRICAO>"
                                   ,"</ESPECIALIDADE>"
                                   ,"</TIPOSERVICO>"
              end if

              if l_index2 = l_count + 1 then
                 let l_xmlRetorno = l_xmlRetorno clipped
                                   ,"</TIPOSERVICOS>"
                                   ,"<REFERENCIA>" ,lr_retorno_copia.lclrefptotxt clipped ,"</REFERENCIA>"
	                           ,"<CONTATO>"
                                   ,"<NOME>" ,lr_retorno_copia.lclcttnom clipped ,"</NOME>"
                                   ,"<TELEFONE>"
                                   ,"<DDD>" ,lr_retorno_copia.dddcod clipped ,"</DDD>"
                                   ,"<NUMERO>" ,lr_retorno_copia.lcltelnum clipped ,"</NUMERO>"
                                   ,"</TELEFONE>"
	                           ,"</CONTATO>"
                                   ,"<DATA>" ,l_nat_prob.atddatprg clipped ,"</DATA>"
                                   ,"<HORA>" ,l_nat_prob.atdhorprg clipped ,"</HORA>"
                                   ,"</RESPONSE>"
              else

              end if
            else

               call ctf00m06_xmlerro("OBTER_INFORMACAO_SERVICO"
                                     ,2
                                     ,"NATUREZA NAO CADASTRADA.")
                    returning l_xmlRetorno
            end if

         else

            call ctf00m06_xmlerro("OBTER_INFORMACAO_SERVICO"
                                  ,1
                                  ,"NENHUM REGISTRO ENCONTRADO PARA OS DADOS INFORMADOS.")
                 returning l_xmlRetorno
         end if
      end if
   end for

   return l_xmlRetorno

end function



#-----------------------------------------------------------------------------
function bdatm002_reagendarServico(l_param)
#-----------------------------------------------------------------------------

   define l_param      record
          atdsrvnum    like datmservico.atdsrvnum,
          atdsrvano    like datmservico.atdsrvano,
          data         date,
          hora         datetime hour to minute
   end record

   define ws           record
          atdsrvnum    like datmservico.atdsrvnum,
          atdsrvano    like datmservico.atdsrvano
   end record

   define l_podeAlterar smallint,
          l_msg char(100),
          l_xmlRetorno char(32000),
          l_erroWork smallint,
          l_sql char(200),
          l_atdsrvorg like datmservico.atdsrvorg,
          l_atdetpcod like datmservico.atdetpcod,
          l_relpamtxt like igbmparam.relpamtxt

   initialize ws.* to null

   let l_podeAlterar = 0
   let l_atdsrvorg = null
   let l_atdetpcod = null
   let l_msg = null
   let l_xmlRetorno = null
   let l_erroWork = null
   let l_relpamtxt = null


   #ligia - fornax - atdsrvorg
   select atdsrvorg, atdetpcod into l_atdsrvorg , l_atdetpcod
     from datmservico
    where atdsrvnum = l_param.atdsrvnum
      and atdsrvano = l_param.atdsrvano

   if sqlca.sqlcode <> notfound then
      if l_atdetpcod = 4 or l_atdetpcod = 5 then
         if l_atdetpcod = 5 then # Cancelado
            let l_msg = "Servico ja CANCELADO."
         end if

         if l_atdetpcod = 4 then
            # Se a etapa for 4 Acionado, nao permitir cancelamento/Alteração.
            let l_msg = "Servico acionado,nao permite alteracao/cancelamento"
         end if

         call ctf00m06_xmlerro("REAGENDAR_SERVICO",
                               2,
                               l_msg )
#                               "ERRO NA ATUALIZAÇÃO DO REAGENDAMENTO.")
              returning l_xmlRetorno
              let l_erroWork = true
      end if
      #begin work

      if l_atdsrvorg = 9 then

         call ctx32g00_regulador(l_param.*)
              returning l_podeAlterar
                       ,l_msg

         if l_podeAlterar <> 1 then

            call ctf00m06_xmlerro("REAGENDAR_SERVICO"
                                  ,l_podeAlterar+3
                                  ,l_msg)
                 returning l_xmlRetorno
         end if

      end if


      if l_podeAlterar <> 1 then
	      begin work
         whenever error continue

         update datmservico set
                atddatprg = l_param.data,
                atdhorprg = l_param.hora
          where atdsrvnum = l_param.atdsrvnum
            and atdsrvano = l_param.atdsrvano

         whenever error stop

         if sqlca.sqlcode <> 0 then

            call ctf00m06_xmlerro("REAGENDAR_SERVICO"
                                  ,3
                                  ,"ERRO NA ATUALIZAÇÃO DO REAGENDAMENTO.")
                 returning l_xmlRetorno

            let l_erroWork = true
         else
            let l_relpamtxt = l_param.atdsrvnum using "#######", 
                              "|", l_param.atdsrvano using "##"
 
            execute pbdatm002007 using l_relpamtxt

            if sqlca.sqlcode <> 0 then
               display "Erro no insert igbmparam: ", sqlca.sqlcode
                       ," - Servico ", l_relpamtxt clipped 
            end if


            let l_sql = "select atdmltsrvnum,",
                              " atdmltsrvano ",
                        "  from datratdmltsrv ",
                        " where atdsrvnum = ? ",
                          " and atdsrvano = ?"
            prepare sel_mltsrv  from l_sql
            declare c_bdatm00208 cursor for sel_mltsrv

            open c_bdatm00208 using l_param.atdsrvnum,
                                    l_param.atdsrvano

            if sqlca.sqlcode = 0 then

               foreach c_bdatm00208 into ws.atdsrvnum,
                                         ws.atdsrvano

                  whenever error continue

                  update datmservico
                     set atddatprg = l_param.data,
                         atdhorprg = l_param.hora
                   where atdsrvnum = ws.atdsrvnum
                     and atdsrvano = ws.atdsrvano

                  whenever error stop

                  if sqlca.sqlcode <> 0 then

                     call ctf00m06_xmlerro("REAGENDAR_SERVICO",
                                            3,
                                           "ERRO NA ATUALIZAÇÃO DO REAGENDAMENTO.")
                          returning l_xmlRetorno

                     let l_erroWork = true
                     exit foreach
                  else
                     let l_relpamtxt = ws.atdsrvnum using "#######", 
                                       "|", ws.atdsrvano using "##"
                     execute pbdatm002007 using l_relpamtxt
                    
                     if sqlca.sqlcode <> 0 then
                        display "Erro no insert igbmparam: ", sqlca.sqlcode
                                ," - Servico ", l_relpamtxt clipped 
                     end if
                  end if

               end foreach
            end if
         end if

         if l_erroWork = true then
            rollback work
         else
            commit work

            let l_xmlRetorno = "<RESPONSE>",
                               "<SERVICO>REAGENDAR_SERVICO</SERVICO>",
                               "<ALTERADO>SIM</ALTERADO>",
                               "</RESPONSE>"
         end if
      end if
   else

      call ctf00m06_xmlerro("REAGENDAR_SERVICO",
                             3,
                            "NENHUM REGISTRO ENCONTRADO PARA OS DADOS INFORMADOS.")
           returning l_xmlRetorno
   end if

   return l_xmlRetorno

end function
#--------------------------------------
function bdatm002_valida_apolice(param)
#--------------------------------------

   define param     record
          succod    like datrligapol.succod
         ,ramcod    like datrservapol.ramcod
         ,aplnumdig like datrligapol.aplnumdig
         ,itmnumdig like abbmdoc.itmnumdig
   end record

   define l_ret         record
          result        char(1)
         ,dctnumseq     like abbmdoc.dctnumseq
         ,vclsitatu     like abbmitem.vclsitatu
         ,autsitatu     like abbmitem.autsitatu
         ,dmtsitatu     like abbmitem.dmtsitatu
         ,dpssitatu     like abbmitem.dpssitatu
         ,appsitatu     like abbmitem.appsitatu
         ,vidsitatu     like abbmitem.vidsitatu
   end record

   define l_xmlRetorno  char(32000)
         ,l_ret_seg     integer

   define l_segnumdig   like gsakseg.segnumdig

   initialize l_ret.* to null

   let l_xmlRetorno = null
   let l_segnumdig  = null
   let l_ret_seg    = null

   call f_funapol_ultima_situacao(param.succod,
                                  param.aplnumdig,
                                  param.itmnumdig)
        returning l_ret.result
                 ,l_ret.dctnumseq
                 ,l_ret.vclsitatu
                 ,l_ret.autsitatu
                 ,l_ret.dmtsitatu
                 ,l_ret.dpssitatu
                 ,l_ret.appsitatu
                 ,l_ret.vidsitatu

   whenever error continue

   select segnumdig
     into l_segnumdig
     from abbmdoc
    where succod    = param.succod
      and aplnumdig = param.aplnumdig
      and itmnumdig = param.itmnumdig
      and dctnumseq = l_ret.dctnumseq

   whenever error stop

   if l_segnumdig is not null and
      l_segnumdig <> 0        then
      let l_ret_seg = osgtk1001_pesquisarSeguradoPorCodigo(l_segnumdig)

      if g_r_gsakseg.pestip is null then
         call ctf00m06_xmlerro("VALIDA_APOLICE",
                                9999,
                           "TIPO DE PESSOA DO SEGURADO ESTA NULO, ENTRE EM CONTATO COM SEU CORRETOR PARA ATUALIZACAO DO CADASTRO.")
              returning l_xmlRetorno
      else
         if g_r_gsakseg.pestip = 'J' then
            call ctf00m06_xmlerro("VALIDA_APOLICE",
                                  9999,
                                  "ATENDIMENTO NAO PREVISTO PARA O DOCUMENTO SELECIONADO, ENTRE EM CONTATO COM SEU CORRETOR.")
              returning l_xmlRetorno
         end if
      end if
   end if

   return l_xmlRetorno

end function

#-------------------------------------------------
function bdatm002_calcula_digito_item(lr_param)
#-------------------------------------------------

   define lr_param  record
          itmnumdig like abbmdoc.itmnumdig
   end record

   define lr_retorno record
          itmnumdig  like abbmdoc.itmnumdig,
          errcode    smallint
   end record

   initialize lr_retorno.* to null

   call F_FUNDIGIT_DIGITO11 (lr_param.itmnumdig)
        returning lr_retorno.itmnumdig


   if lr_retorno.itmnumdig  is null   then
        let lr_retorno.errcode = 1
        return lr_retorno.*
   else
     let lr_retorno.errcode = 0
   end if

   return lr_retorno.*

end function

#----------------------------------------
function bdatm002_levatraz(l_docHandle)
#----------------------------------------

   define l_docHandle integer

 define l_servicocmp record
        vclcamtip    like datmservicocmp.vclcamtip, #TipoCaminhao
        vclcrcdsc    like datmservicocmp.vclcrcdsc, #DescricaoCarroceria
        vclcrgflg    like datmservicocmp.vclcrgflg, #FlagCaminhaoCarregtado
        vclcrgpso    like datmservicocmp.vclcrgpso, #PesoCaminhaoCarregtado
        sinvitflg    like datmservicocmp.sinvitflg, #FlagVitimasSinistro
        bocflg       like datmservicocmp.bocflg,    #FlagBoletimOcorrencia
        bocnum       like datmservicocmp.bocnum,    #NumeroBoletimOcorrencia
        bocemi       like datmservicocmp.bocemi,    #OrgaoEmissorBO
        vcllibflg    like datmservicocmp.vcllibflg, #FlagLiberacaoVeiculo
        roddantxt    like datmservicocmp.roddantxt, #RodasDanificadas
        rmcacpflg    like datmservicocmp.rmcacpflg, #FlagSeguradoAcompanhaRem
        sindat       like datmservicocmp.sindat,    #DataSinistro
        c24sintip    like datmservicocmp.c24sintip, #TipoSinistro
        c24sinhor    like datmservicocmp.c24sinhor, #HoraSinistro
        vicsnh       like datmservicocmp.vicsnh,    #SenhaAlarme
        sinhor       like datmservicocmp.sinhor,    #HoraOcorrenciaSinistro
        sgdirbcod    like datmservicocmp.sgdirbcod, #CodigoIRBSeguradorahaRem
        smsenvflg    like datmservicocmp.smsenvflg  #FlagEnvioSMS
 end record

   initialize l_servicocmp.* to null

   #let l_servicocmp.vclcamtip = figrc011_xpath(l_docHandle,"/REQUEST/TipoCaminhao")
   #let l_servicocmp.vclcrcdsc = figrc011_xpath(l_docHandle,"/REQUEST/DescricaoCarroceria")
   #let l_servicocmp.vclcrgflg = figrc011_xpath(l_docHandle,"/REQUEST/FlagCaminhaoCarregado")
   #let l_servicocmp.vclcrgpso = figrc011_xpath(l_docHandle,"/REQUEST/PesoCaminhaoCarregado")
   #let l_servicocmp.sinvitflg = figrc011_xpath(l_docHandle,"/REQUEST/FlagVitimasSinistro")
   #let l_servicocmp.bocflg = figrc011_xpath(l_docHandle,"/REQUEST/FlagBoletimOcorrencia")
   #let l_servicocmp.bocnum = figrc011_xpath(l_docHandle,"/REQUEST/NumeroBoletimOcorrencia")
   #let l_servicocmp.bocemi = figrc011_xpath(l_docHandle,"/REQUEST/OrgaoEmissorBO")
   #let l_servicocmp.vcllibflg = figrc011_xpath(l_docHandle,"/REQUEST/FlagLiberacaoVeiculo")
   #let l_servicocmp.roddantxt = figrc011_xpath(l_docHandle,"/REQUEST/RodasDanificadas")
   #let l_servicocmp.rmcacpflg    = figrc011_xpath(l_docHandle,"/REQUEST/FlagSeguradoAcompanhaRemocao")
   #let l_servicocmp.sindat = figrc011_xpath(l_docHandle,"/REQUEST/DataSinistro")
   #let l_servicocmp.c24sintip = figrc011_xpath(l_docHandle,"/REQUEST/TipoSinistro")
   #let l_servicocmp.c24sinhor = figrc011_xpath(l_docHandle,"/REQUEST/HoraSinistro")
   #let l_servicocmp.vicsnh = figrc011_xpath(l_docHandle,"/REQUEST/SenhaAlarme")
   #let l_servicocmp.sinhor = figrc011_xpath(l_docHandle,"/REQUEST/HoraOcorrenciaSinistro")
   #let l_servicocmp.sgdirbcod = figrc011_xpath(l_docHandle,"/REQUEST/CodigoIRBSeguradorahaRem")
   #let l_servicocmp.smsenvflg = figrc011_xpath(l_docHandle,"/REQUEST/FlagEnvioSMS")
   #

   let l_servicocmp.vclcamtip = figrc011_xpath(l_docHandle,"/REQUEST/TIPOCAMINHAO")
   let l_servicocmp.vclcrcdsc = figrc011_xpath(l_docHandle,"/REQUEST/DESCRICAOCARROCERIA")
   let l_servicocmp.vclcrgflg = figrc011_xpath(l_docHandle,"/REQUEST/FLAGCAMINHAOCARREGADO")
   let l_servicocmp.vclcrgpso = figrc011_xpath(l_docHandle,"/REQUEST/PESOCAMINHAOCARREGADO")
   let l_servicocmp.sinvitflg = figrc011_xpath(l_docHandle,"/REQUEST/FLAGVITIMASSINISTRO")
   let l_servicocmp.bocflg = figrc011_xpath(l_docHandle,"/REQUEST/FLAGBOLETIMOCORRENCIA")
   let l_servicocmp.bocnum = figrc011_xpath(l_docHandle,"/REQUEST/NUMEROBOLETIMOCORRENCIA")
   let l_servicocmp.bocemi = figrc011_xpath(l_docHandle,"/REQUEST/ORGAOEMISSORBO")
   let l_servicocmp.vcllibflg = figrc011_xpath(l_docHandle,"/REQUEST/FLAGLIBERACAOVEICULO")
   let l_servicocmp.roddantxt = figrc011_xpath(l_docHandle,"/REQUEST/RODASDANIFICADAS")
   let l_servicocmp.rmcacpflg    = figrc011_xpath(l_docHandle,"/REQUEST/FLAGSEGURADOACOMPANHAREMOCAO")
   let l_servicocmp.sindat = figrc011_xpath(l_docHandle,"/REQUEST/DATASINISTRO")
   let l_servicocmp.c24sintip = figrc011_xpath(l_docHandle,"/REQUEST/TIPOSINISTRO")
   let l_servicocmp.c24sinhor = figrc011_xpath(l_docHandle,"/REQUEST/HORASINISTRO")
   let l_servicocmp.vicsnh = figrc011_xpath(l_docHandle,"/REQUEST/SENHAALARME")
   let l_servicocmp.sinhor = figrc011_xpath(l_docHandle,"/REQUEST/HORAOCORRENCIASINISTRO")
   let l_servicocmp.sgdirbcod = figrc011_xpath(l_docHandle,"/REQUEST/CODIGOIRBSEGURADORAHAREM")
   let l_servicocmp.smsenvflg = figrc011_xpath(l_docHandle,"/REQUEST/FLAGENVIOSMS")

   return l_servicocmp.*

end function

#-----------------------------------------
function bdatm002_validar_srv(lr_param)
#-----------------------------------------

   define lr_param   record
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
	  atdetpcod  like datmservico.atdetpcod,
	  atddatprg  like datmservico.atddatprg,
	  atdhorprg  like datmservico.atdhorprg,
	  atdsrvorg  like datmservico.atdsrvorg,
	  assunto    like datmligacao.c24astcod
          end record

   define l_data_atu   date,
         l_data_prg   date,
         l_hora_atu   datetime hour to minute,
         l_hora_prg   datetime hour to minute,
         l_assunto    like datkassunto.c24astcod,
         l_status     smallint,
         l_qtd_hr     interval hour to minute,
         l_msg        char(80)

   let l_data_atu = current
   let l_hora_atu = current
   let l_qtd_hr = null
   let l_msg = null

   ##Desprezar o servico que nao seja de Leva Traz
   if lr_param.assunto <> "G16" and
      lr_param.assunto <> "G17" then
      return 1, l_msg
   end if

   if lr_param.atdsrvorg = 4 then ##tratar somente servico de origem 4

      if lr_param.atdetpcod = 5 then # Cancelado
         let l_msg = "Servico ja CANCELADO."
         return 0, l_msg
      end if

      if lr_param.atdetpcod = 4 then
         # Se a etapa for 4 Acionado, nao permitir cancelamento.
         let l_msg = "Servico acionado,nao permite alteracao/cancelamento"
         return 0, l_msg
      else
      #end if

         if lr_param.atdetpcod <> 4 and lr_param.atdetpcod <> 5 then
            if lr_param.atddatprg is null and
               lr_param.atdhorprg is null then
               let l_msg = "Servico acionado como IMEDIATO nao permite alteracao/cancelamento"
               return 0, l_msg
            end if

            ##Desprezar servico nao acionado
            if lr_param.atddatprg = l_data_atu then
               let l_qtd_hr = lr_param.atdhorprg - l_hora_atu

               #if l_qtd_hr < "02:00"  then
               #  let l_msg = "Data/hora da programacao nao permite alteracao/cancelamento"
               #  return 0, l_msg
               #end if

               if l_hora_atu >= lr_param.atdhorprg then
                  let l_msg = "Data/hora da programacao nao permite alteracao/cancelamento"
                  return 0, l_msg
               end if

            end if

            #servico nao acionado
            return 1, l_msg
         end if
      end if
   else  ## nao achou o servico com origem=4
      let l_msg = "Servico invalido"
      return 0, l_msg
   end if

   return 1, l_msg

end function

#-------------------------------------------------------------
function bdatm002_valida_enderecos(l_ocorrencia, l_destino)
#-------------------------------------------------------------

	define l_ocorrencia record
		 lclidttxt     like datmlcl.lclidttxt      ,
		 lgdtip        like datmlcl.lgdtip         ,
		 lgdnom        like datmlcl.lgdnom         ,
		 lgdnum        like datmlcl.lgdnum         ,
		 lclbrrnom     like datmlcl.lclbrrnom      ,
		 brrnom        like datmlcl.brrnom         ,
		 cidnom        like datmlcl.cidnom         ,
		 ufdcod        like datmlcl.ufdcod         ,
		 lclrefptotxt  like datmlcl.lclrefptotxt   ,
		 endzon        like datmlcl.endzon         ,
		 lgdcep        like datmlcl.lgdcep         ,
		 lgdcepcmp     like datmlcl.lgdcepcmp      ,
		 lclltt        like datmlcl.lclltt         ,
		 lcllgt        like datmlcl.lcllgt         ,
		 dddcod        like datmlcl.dddcod         ,
		 lcltelnum     like datmlcl.lcltelnum      ,
		 lclcttnom     like datmlcl.lclcttnom      ,
		 c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
		 ofnnumdig     decimal(6,0)                ,
		 emeviacod     like datmemeviadpt.emeviacod
	 end record

	 define l_destino record
		 lclidttxt     like datmlcl.lclidttxt      ,
		 lgdtip        like datmlcl.lgdtip         ,
		 lgdnom        like datmlcl.lgdnom         ,
		 lgdnum        like datmlcl.lgdnum         ,
		 lclbrrnom     like datmlcl.lclbrrnom      ,
		 brrnom        like datmlcl.brrnom         ,
		 cidnom        like datmlcl.cidnom         ,
		 ufdcod        like datmlcl.ufdcod         ,
		 lclrefptotxt  like datmlcl.lclrefptotxt   ,
		 endzon        like datmlcl.endzon         ,
		 lgdcep        like datmlcl.lgdcep         ,
		 lgdcepcmp     like datmlcl.lgdcepcmp      ,
		 lclltt        like datmlcl.lclltt         ,
		 lcllgt        like datmlcl.lcllgt         ,
		 dddcod        like datmlcl.dddcod         ,
		 lcltelnum     like datmlcl.lcltelnum      ,
		 lclcttnom     like datmlcl.lclcttnom      ,
		 c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
		 ofnnumdig     decimal(6,0)                ,
		 emeviacod     like datmemeviadpt.emeviacod
	 end record

	 define l_val_oco, l_val_dst smallint

	 let l_val_oco = true
	 let l_val_dst = true

	 if l_ocorrencia.lclidttxt is null and
	    l_ocorrencia.lgdtip    is null and
	    l_ocorrencia.lgdnom    is null and
            l_ocorrencia.lgdnum    is null and
            l_ocorrencia.lclbrrnom is null and
            l_ocorrencia.brrnom    is null and
            l_ocorrencia.cidnom    is null and
            l_ocorrencia.ufdcod    is null and
            l_ocorrencia.lclrefptotxt is null and
            l_ocorrencia.endzon    is null and
            l_ocorrencia.lclltt    is null and
            l_ocorrencia.lcllgt    is null and
            l_ocorrencia.dddcod    is null and
            l_ocorrencia.lcltelnum    is null and
            l_ocorrencia.lclcttnom    is null and
            l_ocorrencia.c24lclpdrcod is null and
            l_ocorrencia.emeviacod    is null then
            let l_val_oco = false
         end if

         if l_destino.lclidttxt is null and
	    l_destino.lgdtip    is null and
	    l_destino.lgdnom    is null and
	    l_destino.lgdnum    is null and
	    l_destino.lclbrrnom is null and
	    l_destino.brrnom    is null and
	    l_destino.cidnom    is null and
	    l_destino.ufdcod    is null and
	    l_destino.lclrefptotxt is null and
	    l_destino.endzon    is null and
	    l_destino.lclltt    is null and
	    l_destino.lcllgt    is null and
	    l_destino.dddcod    is null and
	    l_destino.lcltelnum    is null and
	    l_destino.lclcttnom    is null and
	    l_destino.c24lclpdrcod is null and
	    l_destino.emeviacod    is null then
	    let l_val_dst = false
         end if

         return l_val_oco, l_val_dst

end function



#----------------------------------------------
function bdatm002_sinistro(l_param_ast)
#----------------------------------------------

 define l_param_ast like datkassunto.c24astcod

 define l_rqt record
        srvnumtip        char(40),
        solicdat         char(40),
        solichor         char(40),
        c24soltipcod     char(40),
        c24solnom        char(40),
        c24astcod        char(40),
        c24pbmcod        char(40),
        funmat           char(40),
        funemp           char(40),
        c24paxnum        char(40),
        atdlibflg        char(40),
        atdtip           char(40),
        atdfnlflg        char(40),
        atdrsdflg        char(40),
        atdpvtretflg     char(40),
        asitipcod        char(40),
        srvprlflg        char(40),
        atdprinvlcod     char(40),
        atdsrvorg        char(40),
        c24pbminforg     char(40),
        pstcoddig        char(40),
        atdetpcod        char(40),
        ligcvntip        char(40),
        prslocflg        char(40),
        rmcacpflg        char(40),
        frmflg           char(40),
        vclcorcod        char(40),
        vcldes           char(40),
        vclanomdl        char(40),
        vcllicnum        char(40),
        camflg           char(40),
        vclcoddig        char(40),
        segnom           char(40),
        succod           char(40),
        ramcod           char(40),
        aplnumdig        char(40),
        itmnumdig        char(40),
        edsnumref        char(40),
        corsus           char(40),
        cornom           char(40),
        atddatprg        char(40),
        atdhorprg        char(40),
        c24pbmdes        char(40),
        webpbmdes        char(40),
        sphpbmdes        char(40),
        remrquflg        char(40),
        oco_lclidttxt    char(40),
        oco_lgdtip       char(40),
        oco_lgdnom       char(40),
        oco_lgdnum       char(40),
        oco_lclbrrnom    char(40),
        oco_brrnom       char(40),
        oco_cidnom       char(40),
        oco_ufdcod       char(40),
        oco_lclrefptotxt char(40),
        oco_endzon       char(40),
        oco_lgdcep       char(40),
        oco_lgdcepcmp    char(40),
        oco_lclltt       char(40),
        oco_lcllgt       char(40),
        oco_dddcod       char(40),
        oco_lcltelnum    char(40),
        oco_lclcttnom    char(40),
        oco_c24lclpdrcod char(40),
        oco_ofnnumdig    char(40),
        oco_emeviacod    char(40),
        dst_lclidttxt    char(40),
        dst_lgdtip       char(40),
        dst_lgdnom       char(40),
        dst_lgdnum       char(40),
        dst_lclbrrnom    char(40),
        dst_brrnom       char(40),
        dst_cidnom       char(40),
        dst_ufdcod       char(40),
        dst_lclrefptotxt char(40),
        dst_endzon       char(40),
        dst_lgdcep       char(40),
        dst_lgdcepcmp    char(40),
        dst_lclltt       char(40),
        dst_lcllgt       char(40),
        dst_dddcod       char(40),
        dst_lcltelnum    char(40),
        dst_lclcttnom    char(40),
        dst_c24lclpdrcod char(40),
        dst_ofnnumdig    char(40),
        dst_emeviacod    char(40)
 end record

 initialize l_rqt.* to null

 if l_param_ast = "G16" or
    l_param_ast = "G17" then
    let l_rqt.srvnumtip        = "/REQUEST/TIPONUMERACAO"
    let l_rqt.solicdat         = "/REQUEST/DATASOLICITACAO"
    let l_rqt.solichor         = "/REQUEST/HORASOLICITACAO"
    let l_rqt.c24soltipcod     = "/REQUEST/TIPOSOLICITANTE"
    let l_rqt.c24solnom        = "/REQUEST/NOMESOLICITANTE"
    let l_rqt.c24astcod        = "/REQUEST/CODIGOASSUNTO"
    let l_rqt.c24pbmcod        = "/REQUEST/CODIGOPROBLEMA"
    let l_rqt.funmat           = "/REQUEST/MATRICULAOPERADOR"
    let l_rqt.funemp           = "/REQUEST/EMPRESAOPERADOR"
    let l_rqt.c24paxnum        = "/REQUEST/NUMERODAPA"
    let l_rqt.atdlibflg        = "/REQUEST/FLAGLIBERACAOSERVICO"
    let l_rqt.atdtip           = "/REQUEST/TIPOATENDIMENTO"
    let l_rqt.atdfnlflg        = "/REQUEST/FLAGFINALATENDIMENTO"
    let l_rqt.atdrsdflg        = "/REQUEST/FLAGATENDIMENTORESIDENCIAL"
    let l_rqt.atdpvtretflg     = "/REQUEST/FLAGRETORNOPREVISTO"
    let l_rqt.asitipcod        = "/REQUEST/CODIGOTIPOASSISTENCIA"
    let l_rqt.srvprlflg        = "/REQUEST/FLAGSERVICOPARTICULAR"
    let l_rqt.atdprinvlcod     = "/REQUEST/NIVELPRIORIDADEATENDIMENTO"
    let l_rqt.atdsrvorg        = "/REQUEST/ORIGEMSERVICO"
    let l_rqt.c24pbminforg     = "/REQUEST/ORIGEMINFORMACAOPROBLEMA"
    let l_rqt.pstcoddig        = "/REQUEST/CODIGOPRESTADOR"
    let l_rqt.atdetpcod        = "/REQUEST/CODIGOETAPA"
    let l_rqt.ligcvntip        = "/REQUEST/TIPOCONVENIOLIGACAO"
    let l_rqt.prslocflg        = "/REQUEST/FLAGPRESTADORNOLOCAL"
    let l_rqt.rmcacpflg        = "/REQUEST/FLAGSEGURADOACOMPANHAREMOCAO"
    let l_rqt.frmflg           = "/REQUEST/FLAGATENDIMENTOVIAFORMULARIO"
    let l_rqt.vclcorcod        = "/REQUEST/CORVEICULO"
    let l_rqt.vcldes           = "/REQUEST/DESCRICAOVEICULO"
    let l_rqt.vclanomdl        = "/REQUEST/ANOMODELO"
    let l_rqt.vcllicnum        = "/REQUEST/PLACA"
    let l_rqt.camflg           = "/REQUEST/FLAGCAMINHAOOUUTILITARIO"
    let l_rqt.vclcoddig        = "/REQUEST/CODIGOVEICULO"
    let l_rqt.segnom           = "/REQUEST/NOMECLIENTE"
    let l_rqt.succod           = "/REQUEST/CODIGOSUCURSAL"
    let l_rqt.ramcod           = "/REQUEST/CODIGORAMO"
    let l_rqt.aplnumdig        = "/REQUEST/NUMEROAPOLICE"
    let l_rqt.itmnumdig        = "/REQUEST/NUMEROITEM"
    let l_rqt.edsnumref        = "/REQUEST/NUMEROENDOSSOREFERENCIA"
    let l_rqt.corsus           = "/REQUEST/SUSEPCORRETOR"
    let l_rqt.cornom           = "/REQUEST/NOMECORRETOR"
    let l_rqt.atddatprg        = "/REQUEST/DATAPROGRAMADA"
    let l_rqt.atdhorprg        = "/REQUEST/HORAPROGRAMADA"
    let l_rqt.c24pbmdes        = "/REQUEST/DESCRICAOPROBLEMA"
    let l_rqt.webpbmdes        = "/REQUEST/DESCRICAOPROBLEMAWEB"
    let l_rqt.sphpbmdes        = "/REQUEST/DESCRICAOPROBLEMASMART"
    let l_rqt.remrquflg        = "/REQUEST/FLAGREQUERREMOCAO"
    let l_rqt.oco_lclidttxt   = "/REQUEST/OCRIDENTIFICACAOLOCAL"
    let l_rqt.oco_lgdtip       = "/REQUEST/OCRTIPOLOGRADOURO"
    let l_rqt.oco_lgdnom       = "/REQUEST/OCRNOMELOGRADOURO"
    let l_rqt.oco_lgdnum       = "/REQUEST/OCRNUMEROLOGRADOURO"
    let l_rqt.oco_lclbrrnom    = "/REQUEST/OCRSUBBAIRRO"
    let l_rqt.oco_brrnom       = "/REQUEST/OCRNOMEBAIRRO"
    let l_rqt.oco_cidnom       = "/REQUEST/OCRNOMECIDADE"
    let l_rqt.oco_ufdcod       = "/REQUEST/OCRUF"
    let l_rqt.oco_lclrefptotxt = "/REQUEST/OCRPONTOREFERENCIA"
    let l_rqt.oco_endzon       = "/REQUEST/OCRZONA"
    let l_rqt.oco_lgdcep       = "/REQUEST/OCRCEPLOGRADOURO"
    let l_rqt.oco_lgdcepcmp    = "/REQUEST/OCRCOMPLEMENTOCEP"
    let l_rqt.oco_lclltt       = "/REQUEST/OCRLATITUDELOCAL"
    let l_rqt.oco_lcllgt       = "/REQUEST/OCRLONGITUDELOCAL"
    let l_rqt.oco_dddcod       = "/REQUEST/OCRDDDTEL"
    let l_rqt.oco_lcltelnum    = "/REQUEST/OCRNUMEROTEL"
    let l_rqt.oco_lclcttnom    = "/REQUEST/OCRNOMECONTATO"
    let l_rqt.oco_c24lclpdrcod = "/REQUEST/OCRCODIGOPADRAOLOCAL"
    let l_rqt.oco_ofnnumdig    = "/REQUEST/OCRNUMERODIGITOOFICINA"
    let l_rqt.oco_emeviacod    = "/REQUEST/OCRCODIGOVIAEMERGENCIAL"
    let l_rqt.dst_lclidttxt    = "/REQUEST/DESTIDENTIFICACAOLOCAL"
    let l_rqt.dst_lgdtip       = "/REQUEST/DESTTIPOLOGRADOURO"
    let l_rqt.dst_lgdnom       = "/REQUEST/DESTNOMELOGRADOURO"
    let l_rqt.dst_lgdnum       = "/REQUEST/DESTNUMEROLOGRADOURO"
    let l_rqt.dst_lclbrrnom    = "/REQUEST/DESTSUBBAIRRO"
    let l_rqt.dst_brrnom       = "/REQUEST/DESTNOMEBAIRRO"
    let l_rqt.dst_cidnom       = "/REQUEST/DESTNOMECIDADE"
    let l_rqt.dst_ufdcod       = "/REQUEST/DESTUF"
    let l_rqt.dst_lclrefptotxt = "/REQUEST/DESTPONTOREFERENCIA"
    let l_rqt.dst_endzon       = "/REQUEST/DESTZONA"
    let l_rqt.dst_lgdcep       = "/REQUEST/DESTCEPLOGRADOURO"
    let l_rqt.dst_lgdcepcmp    = "/REQUEST/DESTCOMPLEMENTOCEP"
    let l_rqt.dst_lclltt       = "/REQUEST/DESTLATITUDELOCAL"
    let l_rqt.dst_lcllgt       = "/REQUEST/DESTLONGITUDELOCAL"
    let l_rqt.dst_dddcod       = "/REQUEST/DESTDDDTEL"
    let l_rqt.dst_lcltelnum    = "/REQUEST/DESTNUMEROTEL"
    let l_rqt.dst_lclcttnom    = "/REQUEST/DESTNOMECONTATO"
    let l_rqt.dst_c24lclpdrcod = "/REQUEST/DESTCODIGOPADRAOLOCAL"
    let l_rqt.dst_ofnnumdig    = "/REQUEST/DESTNUMERODIGITOOFICINA"
    let l_rqt.dst_emeviacod    = "/REQUEST/DESTCODIGOVIAEMERGENCIAL"
 else
    let l_rqt.srvnumtip        = "/REQUEST/TipoNumeracao"
    let l_rqt.solicdat         = "/REQUEST/DataSolicitacao"
    let l_rqt.solichor         = "/REQUEST/HoraSolicitacao"
    let l_rqt.c24soltipcod     = "/REQUEST/TipoSolicitante"
    let l_rqt.c24solnom        = "/REQUEST/NomeSolicitante"
    let l_rqt.c24astcod        = "/REQUEST/CodigoAssunto"
    let l_rqt.c24pbmcod        = "/REQUEST/CodigoProblema"
    let l_rqt.funmat           = "/REQUEST/matriculaOperador"
    let l_rqt.funemp           = "/REQUEST/empresaOperador"
    let l_rqt.c24paxnum        = "/REQUEST/numeroDaPA"
    let l_rqt.atdlibflg        = "/REQUEST/FlagLiberacaoServico"
    let l_rqt.atdtip           = "/REQUEST/TipoAtendimento"
    let l_rqt.atdfnlflg        = "/REQUEST/FlagFinalAtendimento"
    let l_rqt.atdrsdflg        = "/REQUEST/FlagAtendimentoResidencial"
    let l_rqt.atdpvtretflg     = "/REQUEST/FlagRetornoPrevisto"
    let l_rqt.asitipcod        = "/REQUEST/CodigoTipoAssistencia"
    let l_rqt.srvprlflg        = "/REQUEST/FlagServicoParticular"
    let l_rqt.atdprinvlcod     = "/REQUEST/NivelPrioridadeAtendimento"
    let l_rqt.atdsrvorg        = "/REQUEST/OrigemServico"
    let l_rqt.c24pbminforg     = "/REQUEST/OrigemInformacaoProblema"
    let l_rqt.pstcoddig        = "/REQUEST/CodigoPrestador"
    let l_rqt.atdetpcod        = "/REQUEST/CodigoEtapa"
    let l_rqt.ligcvntip        = "/REQUEST/TipoConvenioLigacao"
    let l_rqt.prslocflg        = "/REQUEST/FlagPrestadorNoLocal"
    let l_rqt.rmcacpflg        = "/REQUEST/FlagSeguradoAcompanhaRemocao"
    let l_rqt.frmflg           = "/REQUEST/FlagAtendimentoViaFormulario"
    let l_rqt.vclcorcod        = "/REQUEST/CorVeiculo"
    let l_rqt.vcldes           = "/REQUEST/DescricaoVeiculo"
    let l_rqt.vclanomdl        = "/REQUEST/AnoModelo"
    let l_rqt.vcllicnum        = "/REQUEST/Placa"
    let l_rqt.camflg           = "/REQUEST/FlagCaminhaoOuUtilitario"
    let l_rqt.vclcoddig        = "/REQUEST/CodigoVeiculo"
    let l_rqt.segnom           = "/REQUEST/NomeCliente"
    let l_rqt.succod           = "/REQUEST/CodigoSucursal"
    let l_rqt.ramcod           = "/REQUEST/CodigoRamo"
    let l_rqt.aplnumdig        = "/REQUEST/NumeroApolice"
    let l_rqt.itmnumdig        = "/REQUEST/NumeroItem"
    let l_rqt.edsnumref        = "/REQUEST/NumeroEndossoReferencia"
    let l_rqt.corsus           = "/REQUEST/SusepCorretor"
    let l_rqt.cornom           = "/REQUEST/NomeCorretor"
    let l_rqt.atddatprg        = "/REQUEST/DataProgramada"
    let l_rqt.atdhorprg        = "/REQUEST/HoraProgramada"
    let l_rqt.c24pbmdes        = "/REQUEST/DescricaoProblema"
    let l_rqt.webpbmdes        = "/REQUEST/DescricaoProblemaWeb"
    let l_rqt.sphpbmdes        = "/REQUEST/DescricaoProblemaSmart"
    let l_rqt.remrquflg        = "/REQUEST/FlagRequerRemocao"
    let l_rqt.oco_lclidttxt   = "/REQUEST/ocrIdentificacaoLocal"
    let l_rqt.oco_lgdtip       = "/REQUEST/ocrTipoLogradouro"
    let l_rqt.oco_lgdnom       = "/REQUEST/ocrNomeLogradouro"
    let l_rqt.oco_lgdnum       = "/REQUEST/ocrNumeroLogradouro"
    let l_rqt.oco_lclbrrnom    = "/REQUEST/ocrSubBairro"
    let l_rqt.oco_brrnom       = "/REQUEST/ocrNomeBairro"
    let l_rqt.oco_cidnom       = "/REQUEST/ocrNomeCidade"
    let l_rqt.oco_ufdcod       = "/REQUEST/ocrUF"
    let l_rqt.oco_lclrefptotxt = "/REQUEST/ocrPontoReferencia"
    let l_rqt.oco_endzon       = "/REQUEST/ocrZona"
    let l_rqt.oco_lgdcep       = "/REQUEST/ocrCepLogradouro"
    let l_rqt.oco_lgdcepcmp    = "/REQUEST/ocrComplementoCep"
    let l_rqt.oco_lclltt       = "/REQUEST/ocrLatitudeLocal"
    let l_rqt.oco_lcllgt       = "/REQUEST/ocrLongitudeLocal"
    let l_rqt.oco_dddcod       = "/REQUEST/ocrDddTel"
    let l_rqt.oco_lcltelnum    = "/REQUEST/ocrNumeroTel"
    let l_rqt.oco_lclcttnom    = "/REQUEST/ocrNomeContato"
    let l_rqt.oco_c24lclpdrcod = "/REQUEST/ocrCodigoPadraoLocal"
    let l_rqt.oco_ofnnumdig    = "/REQUEST/ocrNumeroDigitoOficina"
    let l_rqt.oco_emeviacod    = "/REQUEST/ocrCodigoViaEmergencial"
    let l_rqt.dst_lclidttxt    = "/REQUEST/destIdentificacaoLocal"
    let l_rqt.dst_lgdtip       = "/REQUEST/destTipoLogradouro"
    let l_rqt.dst_lgdnom       = "/REQUEST/destNomeLogradouro"
    let l_rqt.dst_lgdnum       = "/REQUEST/destNumeroLogradouro"
    let l_rqt.dst_lclbrrnom    = "/REQUEST/destSubBairro"
    let l_rqt.dst_brrnom       = "/REQUEST/destNomeBairro"
    let l_rqt.dst_cidnom       = "/REQUEST/destNomeCidade"
    let l_rqt.dst_ufdcod       = "/REQUEST/destUF"
    let l_rqt.dst_lclrefptotxt = "/REQUEST/destPontoReferencia"
    let l_rqt.dst_endzon       = "/REQUEST/destZona"
    let l_rqt.dst_lgdcep       = "/REQUEST/destCepLogradouro"
    let l_rqt.dst_lgdcepcmp    = "/REQUEST/destComplementoCep"
    let l_rqt.dst_lclltt       = "/REQUEST/destLatitudeLocal"
    let l_rqt.dst_lcllgt       = "/REQUEST/destLongitudeLocal"
    let l_rqt.dst_dddcod       = "/REQUEST/destDddTel"
    let l_rqt.dst_lcltelnum    = "/REQUEST/destNumeroTel"
    let l_rqt.dst_lclcttnom    = "/REQUEST/destNomeContato"
    let l_rqt.dst_c24lclpdrcod = "/REQUEST/destCodigoPadraoLocal"
    let l_rqt.dst_ofnnumdig    = "/REQUEST/destNumeroDigitoOficina"
    let l_rqt.dst_emeviacod    = "/REQUEST/destCodigoViaEmergencial"
 end if

 return  l_rqt.srvnumtip
        ,l_rqt.solicdat
        ,l_rqt.solichor
        ,l_rqt.c24soltipcod
        ,l_rqt.c24solnom
        ,l_rqt.c24astcod
        ,l_rqt.c24pbmcod
        ,l_rqt.funmat
        ,l_rqt.funemp
        ,l_rqt.c24paxnum
        ,l_rqt.atdlibflg
        ,l_rqt.atdtip
        ,l_rqt.atdfnlflg
        ,l_rqt.atdrsdflg
        ,l_rqt.atdpvtretflg
        ,l_rqt.asitipcod
        ,l_rqt.srvprlflg
        ,l_rqt.atdprinvlcod
        ,l_rqt.atdsrvorg
        ,l_rqt.c24pbminforg
        ,l_rqt.pstcoddig
        ,l_rqt.atdetpcod
        ,l_rqt.ligcvntip
        ,l_rqt.prslocflg
        ,l_rqt.rmcacpflg
        ,l_rqt.frmflg
        ,l_rqt.vclcorcod
        ,l_rqt.vcldes
        ,l_rqt.vclanomdl
        ,l_rqt.vcllicnum
        ,l_rqt.camflg
        ,l_rqt.vclcoddig
        ,l_rqt.segnom
        ,l_rqt.succod
        ,l_rqt.ramcod
        ,l_rqt.aplnumdig
        ,l_rqt.itmnumdig
        ,l_rqt.edsnumref
        ,l_rqt.corsus
        ,l_rqt.cornom
        ,l_rqt.atddatprg
        ,l_rqt.atdhorprg
        ,l_rqt.c24pbmdes
        ,l_rqt.webpbmdes
        ,l_rqt.sphpbmdes
        ,l_rqt.remrquflg
        ,l_rqt.oco_lclidttxt
        ,l_rqt.oco_lgdtip
        ,l_rqt.oco_lgdnom
        ,l_rqt.oco_lgdnum
        ,l_rqt.oco_lclbrrnom
        ,l_rqt.oco_brrnom
        ,l_rqt.oco_cidnom
        ,l_rqt.oco_ufdcod
        ,l_rqt.oco_lclrefptotxt
        ,l_rqt.oco_endzon
        ,l_rqt.oco_lgdcep
        ,l_rqt.oco_lgdcepcmp
        ,l_rqt.oco_lclltt
        ,l_rqt.oco_lcllgt
        ,l_rqt.oco_dddcod
        ,l_rqt.oco_lcltelnum
        ,l_rqt.oco_lclcttnom
        ,l_rqt.oco_c24lclpdrcod
        ,l_rqt.oco_ofnnumdig
        ,l_rqt.oco_emeviacod
        ,l_rqt.dst_lclidttxt
        ,l_rqt.dst_lgdtip
        ,l_rqt.dst_lgdnom
        ,l_rqt.dst_lgdnum
        ,l_rqt.dst_lclbrrnom
        ,l_rqt.dst_brrnom
        ,l_rqt.dst_cidnom
        ,l_rqt.dst_ufdcod
        ,l_rqt.dst_lclrefptotxt
        ,l_rqt.dst_endzon
        ,l_rqt.dst_lgdcep
        ,l_rqt.dst_lgdcepcmp
        ,l_rqt.dst_lclltt
        ,l_rqt.dst_lcllgt
        ,l_rqt.dst_dddcod
        ,l_rqt.dst_lcltelnum
        ,l_rqt.dst_lclcttnom
        ,l_rqt.dst_c24lclpdrcod
        ,l_rqt.dst_ofnnumdig
        ,l_rqt.dst_emeviacod

end function
#----------------------------------------------
function bdatm002_consiste_servico(lr_param)
#----------------------------------------------
define lr_param record
       c24astcod  like datkassunto.c24astcod
       ,funmat    integer
       ,solicdat  date
       ,solichor  datetime hour to second
       ,succod    like datrligapol.succod
       ,ramcod    like datrligapol.ramcod
       ,aplnumdig like datrligapol.aplnumdig
       ,itmnumdig like datrligapol.itmnumdig
end record
define l_retorno smallint,
       l_count   smallint,
       l_data    char(5),
       l_data2   char(20)
if m_prep_sql <> true and
   m_prep_sql is null then
   call bdatm002_prepare()
end if
let l_data2 = lr_param.solichor
let l_data = l_data2[1,5]
display "l_data = ",l_data
open cbdatm002003 using lr_param.c24astcod,
                        lr_param.funmat,
                        lr_param.solicdat,
                        l_data,
                        lr_param.succod,
                        lr_param.ramcod,
                        lr_param.aplnumdig,
                        lr_param.itmnumdig
whenever error continue
fetch cbdatm002003 into l_count
whenever error stop
if l_count > 0 then
   let l_retorno = true
end if
return l_retorno
end function
#----------------------------------------
function bdatm002_verifica_envio_fax()
#----------------------------------------
   define l_retorno smallint,
          l_chave   char(20),
          l_cpodes  char(1)
   let l_retorno = 0
   let l_chave = 'envio_fax'
   let l_cpodes = null
 if m_prep_sql is null or
    m_prep_sql <> true then
    call bdatm002_prepare()
 end if
  open cbdatm002004 using l_chave
  whenever error continue
  fetch cbdatm002004 into l_cpodes
  whenever error stop
  if sqlca.sqlcode <> 0 then
     display sqlca.sqlcode
     display "Erro na busca da chave de dominio"
  end if
  if l_cpodes = "S" then
     let l_retorno = 1
  end if
  return l_retorno
end function
#----------------------------------------------
function bdatm002_busca_limites_PET(lr_param)
#----------------------------------------------
define lr_param record
       ramcod     like datrligapol.ramcod
      ,succod     like datrligapol.succod
      ,aplnumdig  like datrligapol.aplnumdig
      ,itmnumdig  like datrligapol.itmnumdig
end record
define l_clscod like abbmclaus.clscod
define l_limite integer
let l_clscod = null
let l_limite = 0
 if m_prep_sql is null or
    m_prep_sql <> true then
    call bdatm002_prepare()
 end if
   call f_funapol_ultima_situacao
              (lr_param.succod, lr_param.aplnumdig,
               lr_param.itmnumdig)
               returning g_funapol.*
   if g_funapol.dctnumseq is null or
      g_funapol.dctnumseq = " " then
      select min(dctnumseq)
        into g_funapol.dctnumseq
        from abbmdoc
       where succod    = lr_param.succod
         and aplnumdig = lr_param.aplnumdig
         and itmnumdig = lr_param.itmnumdig
   end if
   open cbdatm002005 using lr_param.succod
                          ,lr_param.aplnumdig
                          ,lr_param.itmnumdig
                          ,g_funapol.dctnumseq
    #whenever error continue
    foreach cbdatm002005 into l_clscod
      display "lr_datrsrvcls.clscod = ",l_clscod
      if l_clscod = "034" or
         l_clscod = "071" or
         l_clscod = "077" then
        if cta13m00_verifica_clausula(lr_param.succod ,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig,
                                      g_funapol.dctnumseq ,
                                      l_clscod) then
         continue foreach
        end if
      end if
   end foreach
   #whenever error stop
  display "l_clscod = ",l_clscod
  case l_clscod
      when '035'
        let l_limite = 1
      when '033'
        let l_limite = 2
      when '33R'
        let l_limite = 2
      when '044'
        let l_limite = 2
      when '44R'
        let l_limite = 2
      when '047'
        let l_limite = 2
      when '47R'
        let l_limite = 2
      otherwise
        let l_limite = 3
  end case
return l_limite
end function
#----------------------------------------------
function bdatm002_consultar_aviso_re(lr_param)
#----------------------------------------------

define lr_param record
  c24soltipcod like datmligacao.c24soltipcod   ,
  c24solnom    like datmligacao.c24solnom      ,
  c24astcod    like datkassunto.c24astcod      ,
  funmat       like isskfunc.funmat            ,
  usrtip       like isskusuario.usrtip         ,
  empcod       like isskusuario.empcod         ,
  funmatatd    like isskfunc.funmat            ,
  usrtipatd    like isskusuario.usrtip         ,
  empcodatd    like isskusuario.empcod         ,
  cgccpfnum    like gsakseg.cgccpfnum          ,
  cgcord       like gsakseg.cgcord             ,
  cgccpfdig    like gsakseg.cgccpfdig          ,
  pestip       like gsakseg.pestip             ,
  succod       like datrligapol.succod         ,
  ramcod       like datrservapol.ramcod        ,
  aplnumdig    like datrligapol.aplnumdig      ,
  itmnumdig    like datrligapol.itmnumdig      ,
  edsnumref    like datrligapol.edsnumref      ,
  prporg       like datrligprp.prporg          ,
  prpnumdig    like datrligprp.prpnumdig       ,
  corsus       like datmservico.corsus         ,
  dddcod       like datmpedvist.dddcod         ,
  ctttel       like datmreclam.ctttel          ,
  semdocto     char(01)                        ,
  segnom       like datmpedvist.segnom         ,
  hist1        like datmlighist.c24ligdsc      ,
	hist2        like datmlighist.c24ligdsc      ,
	hist3        like datmlighist.c24ligdsc      ,
	hist4        like datmlighist.c24ligdsc      ,
	hist5        like datmlighist.c24ligdsc
end record

define lr_retorno record
	 codigosql    integer                      ,
   msg          char(80)                     ,
   service      char(20)                     ,
   nulo         char(1)                      ,
   sinramgrp    like gtakram.sinramgrp       ,
   data         date                         ,
   hora         datetime hour to minute      ,
   tabname      like systables.tabname       ,
   c24soltip    like datmligacao.c24soltip   ,
   c24soltipdes like datksoltip.c24soltipdes ,
   lignum       like datmligacao.lignum      ,
   atdsrvnum    like datmservico.atdsrvnum   ,
   atdsrvano    like datmservico.atdsrvano   ,
   atdnum       like datratdlig.atdnum       ,
   ligcvntip    like datmligacao.ligcvntip   ,
   sinvstnum    like datmpedvist.sinvstnum   ,
   sinvstano    like datmpedvist.sinvstano
end record

define lr_historico array[5] of record
  linha like datmlighist.c24ligdsc
end record

define l_cont smallint

for	l_cont  =  1  to  5
	initialize  lr_historico[l_cont].*  to  null
end	for


initialize lr_retorno.*  ,
           g_documento.* ,
           g_issk.* to null

 let lr_retorno.service    = "CONSULTAR_AVISO"
 let lr_retorno.ligcvntip  = 0
 let lr_retorno.sinvstnum  = 0
 let lr_retorno.sinvstano  = "00"
 let lr_historico[1].linha = lr_param.hist1
 let lr_historico[2].linha = lr_param.hist2
 let lr_historico[3].linha = lr_param.hist3
 let lr_historico[4].linha = lr_param.hist4
 let lr_historico[5].linha = lr_param.hist5
 let g_issk.funmat         = lr_param.funmat
 let g_issk.empcod         = lr_param.empcod
 let g_issk.usrtip         = lr_param.usrtip

 display "---------------------------------------------------------------------"
 display " 	                       SERVICO V46                             "
 display "---------------------------------------------------------------------"

 #--------------------------------------------
 # Valida Dados do Documento
 #--------------------------------------------
 call cts10g14_valida_documento(lr_param.semdocto    ,
                                lr_param.succod      ,
                                lr_param.ramcod      ,
                                lr_param.aplnumdig   ,
                                lr_param.prporg      ,
                                lr_param.prpnumdig   ,
                                lr_param.corsus      ,
                                lr_param.dddcod      ,
                                lr_param.ctttel      ,
                                lr_param.funmatatd   ,
                                lr_param.usrtipatd   ,
                                lr_param.empcodatd   ,
                                lr_param.cgccpfnum   ,
                                lr_param.cgcord      ,
                                lr_param.cgccpfdig   ,
                                lr_retorno.sinvstnum ,
                                lr_retorno.sinvstano )
  returning  lr_retorno.codigosql,
             lr_retorno.msg


  if lr_retorno.codigosql <> 0 then
       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)
  end if


 #--------------------------------------------
 # Busca numeracao
 #--------------------------------------------
  begin work

  call cts10g03_numeracao( 1, "" )
         returning lr_retorno.lignum     ,
                   lr_retorno.atdsrvnum  ,
                   lr_retorno.atdsrvano  ,
                   lr_retorno.codigosql,
                   lr_retorno.msg

  if  lr_retorno.codigosql = 0  then
      commit work
  else
      rollback work
      return cts10g14_xmlerro( lr_retorno.service
                              ,lr_retorno.codigosql
                              ,lr_retorno.msg)

  end if

  begin work

  #--------------------------------------------
  # Gera Atendimento
  #--------------------------------------------

  call ctd24g00_ins_atd(lr_retorno.nulo
                       ,1
                       ,lr_param.c24solnom
                       ,lr_retorno.nulo
                       ,lr_param.c24soltipcod
                       ,lr_param.ramcod
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.corsus
                       ,lr_param.succod
                       ,lr_param.aplnumdig
                       ,lr_param.itmnumdig
                       ,lr_retorno.nulo
                       ,lr_param.segnom
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.prporg
                       ,lr_param.prpnumdig
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.semdocto
                       ,"N"
                       ,"N"
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,""
                       ,lr_param.pestip
                       ,lr_param.cgccpfnum
                       ,lr_param.cgcord
                       ,lr_param.cgccpfdig
                       ,lr_param.corsus
                       ,lr_param.funmatatd
                       ,lr_param.empcodatd
                       ,lr_param.dddcod
                       ,lr_param.ctttel
                       ,lr_param.funmat
                       ,lr_param.empcod
                       ,lr_param.usrtip
                       ,lr_retorno.ligcvntip)
     returning lr_retorno.atdnum
              ,lr_retorno.codigosql
              ,lr_retorno.msg
     display "RETORNO ctd24g00_ins_atd....:", lr_retorno.msg
     display "RETORNO ctd24g00_ins_atd....:", lr_retorno.codigosql

     if lr_retorno.codigosql <> 0 then
          rollback work
          return cts10g14_xmlerro( lr_retorno.service
                                  ,lr_retorno.codigosql
                                  ,lr_retorno.msg)

     end if


  #--------------------------------------------
  # Gera Ligacao X Atendimento
  #--------------------------------------------

  call ctd25g00_insere_atendimento(lr_retorno.atdnum
                                  ,lr_retorno.lignum)
  returning lr_retorno.tabname,
            lr_retorno.codigosql


  if lr_retorno.codigosql <> 0 then

       rollback work
       let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)


  end if


  #--------------------------------------------
  # Recupera o Grupo do Ramo
  #--------------------------------------------

  if lr_param.ramcod is not null then

    call cts10g14_recupera_grupo_ramo(1, lr_param.ramcod)
    returning lr_retorno.sinramgrp,
              lr_retorno.codigosql,
              lr_retorno.msg

    if lr_retorno.codigosql <> 0 then

         rollback work
         return cts10g14_xmlerro( lr_retorno.service
                                 ,lr_retorno.codigosql
                                 ,lr_retorno.msg)

    end if

  end if

  #--------------------------------------------
  # Recupera Data e Hora do Banco
  #--------------------------------------------

  call cts40g03_data_hora_banco(2)
  returning lr_retorno.data,
            lr_retorno.hora


  #--------------------------------------------
  # Grava a Ligacao
  #--------------------------------------------

   call cts10g00_ligacao ( lr_retorno.lignum      ,
                           lr_retorno.data        ,
                           lr_retorno.hora        ,
                           lr_param.c24soltipcod  ,
                           lr_param.c24solnom     ,
                           lr_param.c24astcod     ,
                           lr_param.funmat        ,
                           lr_retorno.ligcvntip   ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_param.succod        ,
                           lr_param.ramcod        ,
                           lr_param.aplnumdig     ,
                           lr_param.itmnumdig     ,
                           lr_param.edsnumref     ,
                           lr_param.prporg        ,
                           lr_param.prpnumdig     ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        )
                 returning lr_retorno.tabname,
                           lr_retorno.codigosql


                 if lr_retorno.codigosql <> 0 then

                      rollback work
                      let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

                      return cts10g14_xmlerro( lr_retorno.service
                                              ,lr_retorno.codigosql
                                              ,lr_retorno.msg)

                 end if


  #--------------------------------------------
  # Grava Historico da Ligacao
  #--------------------------------------------

   for	l_cont  =  1  to  5

    if lr_historico[l_cont].linha is not null then

         call ctd06g01_ins_datmlighist(lr_retorno.lignum             ,
                                       lr_param.funmat               ,
                                       lr_historico[l_cont].linha    ,
                                       lr_retorno.data               ,
                                       lr_retorno.hora               ,
                                       lr_param.usrtip               ,
                                       lr_param.empcod)
         returning lr_retorno.codigosql,
                   lr_retorno.msg

         if lr_retorno.codigosql <> 1 then

              rollback work
              return cts10g14_xmlerro( lr_retorno.service
                                      ,lr_retorno.codigosql
                                      ,lr_retorno.msg)

         end if
     end if
   end for

   commit work
   let lr_retorno.msg = "V46 GERADO COM SUCESSO "

   return cts10g14_sucesso_msg1( lr_retorno.service
                                ,lr_retorno.msg
                                ,lr_retorno.lignum
                                ,lr_retorno.atdnum)



end function

#----------------------------------------------
function bdatm002_incluir_aviso_re(lr_param)
#----------------------------------------------

define lr_param record
  c24soltipcod like datmligacao.c24soltipcod   ,
  c24solnom    like datmligacao.c24solnom      ,
  c24astcod    like datkassunto.c24astcod      ,
  funmat       like isskfunc.funmat            ,
  usrtip       like isskusuario.usrtip         ,
  empcod       like isskusuario.empcod         ,
  funmatatd    like isskfunc.funmat            ,
  usrtipatd    like isskusuario.usrtip         ,
  empcodatd    like isskusuario.empcod         ,
  cgccpfnum    like gsakseg.cgccpfnum          ,
  cgcord       like gsakseg.cgcord             ,
  cgccpfdig    like gsakseg.cgccpfdig          ,
  pestip       like gsakseg.pestip             ,
  succod       like datrligapol.succod         ,
  ramcod       like datrservapol.ramcod        ,
  aplnumdig    like datrligapol.aplnumdig      ,
  itmnumdig    like datrligapol.itmnumdig      ,
  edsnumref    like datrligapol.edsnumref      ,
  prporg       like datrligprp.prporg          ,
  prpnumdig    like datrligprp.prpnumdig       ,
  corsus       like datmservico.corsus         ,
  dddcod       like datmpedvist.dddcod         ,
  ctttel       like datmreclam.ctttel          ,
  semdocto     char(01)                        ,
  segnom       like datmpedvist.segnom         ,
  sinvstnum    like datmpedvist.sinvstnum      ,
  sinvstano    like datmpedvist.sinvstano      ,
  sindat       like datmpedvist.sindat         ,
  sinhor       like datmpedvist.sinhor         ,
  sinhst       like datmpedvist.sinhst         ,
  sinobs       like datmpedvist.sinobs         ,
  sinntzcod    like datrpedvistnatcob.sinntzcod,
  cbttip       like datrpedvistnatcob.cbttip   ,
  orcvlr       like datrpedvistnatcob.orcvlr   ,
  rglvstflg    like datmpedvist.rglvstflg      ,
  cornom       like datmpedvist.cornom         ,
  lgdtip       like datmpedvist.lgdtip         ,
  lgdnom       like datmpedvist.lgdnom         ,
  lgdnomcmp    like datmpedvist.lgdnomcmp      ,
  lgdnum       like datmpedvist.lgdnum         ,
  lclbrrnom    like datmlcl.lclbrrnom          ,
  endbrr       like datmpedvist.endbrr         ,
  endcid       like datmpedvist.endcid         ,
  endufd       like datmpedvist.endufd         ,
  endcep       like datmpedvist.endcep         ,
  endcepcmp    like datmpedvist.endcepcmp      ,
  lclcttnom    like datmpedvist.lclcttnom      ,
  endrefpto    like datmpedvist.endrefpto      ,
  endzon       like datmlcl.endzon             ,
  lclltt       like datmlcl.lclltt             ,
  lcllgt       like datmlcl.lcllgt             ,
  c24lclpdrcod like datmlcl.c24lclpdrcod       ,
  emeviacod    like datkemevia.emeviacod       ,
  endddd       like datmpedvist.endddd         ,
  teldes       like datmpedvist.teldes         ,
  celteldddcod like datmlcl.celteldddcod       ,
  celtelnum    like datmlcl.celtelnum          ,
  lclnumseq    like datmpedvist.lclnumseq      ,
  rmerscseq    like datmpedvist.rmerscseq      ,
  lclrsccod    like datmpedvist.lclrsccod      ,
  lclendflg    like datmpedvist.lclendflg      ,
  hist1        like datmlighist.c24ligdsc      ,
  hist2        like datmlighist.c24ligdsc      ,
  hist3        like datmlighist.c24ligdsc      ,
  hist4        like datmlighist.c24ligdsc      ,
  hist5        like datmlighist.c24ligdsc
end record

define lr_retorno record
	 codigosql    integer                      ,
   msg          char(80)                     ,
   service      char(20)                     ,
   nulo         char(1)                      ,
   sinramgrp    like gtakram.sinramgrp       ,
   data         date                         ,
   hora         datetime hour to minute      ,
   tabname      like systables.tabname       ,
   c24soltip    like datmligacao.c24soltip   ,
   c24soltipdes like datksoltip.c24soltipdes ,
   lignum       like datmligacao.lignum      ,
   atdsrvnum    like datmservico.atdsrvnum   ,
   atdsrvano    like datmservico.atdsrvano   ,
   hora_atual   datetime hour to minute      ,
   atdnum       like datratdlig.atdnum       ,
   ligcvntip    like datmligacao.ligcvntip
end record


 initialize lr_retorno.*  ,
           g_documento.* ,
           g_issk.* to null


 let lr_retorno.service   = "INCLUIR_AVISO"
 let lr_retorno.ligcvntip = 0
 let g_issk.funmat        = lr_param.funmat
 let g_issk.empcod        = lr_param.empcod
 let g_issk.usrtip        = lr_param.usrtip

 display "---------------------------------------------------------------------"
 display " 	                       SERVICO V12                             "
 display "---------------------------------------------------------------------"

 #--------------------------------------------
 # Valida Dados do Documento
 #--------------------------------------------

 call cts10g14_valida_documento(lr_param.semdocto  ,
                                lr_param.succod    ,
                                lr_param.ramcod    ,
                                lr_param.aplnumdig ,
                                lr_param.prporg    ,
                                lr_param.prpnumdig ,
                                lr_param.corsus    ,
                                lr_param.dddcod    ,
                                lr_param.ctttel    ,
                                lr_param.funmatatd ,
                                lr_param.usrtipatd ,
                                lr_param.empcodatd ,
                                lr_param.cgccpfnum ,
                                lr_param.cgcord    ,
                                lr_param.cgccpfdig ,
                                lr_param.sinvstnum ,
                                lr_param.sinvstano )
  returning  lr_retorno.codigosql,
             lr_retorno.msg


  if lr_retorno.codigosql <> 0 then
       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)

  end if


 #--------------------------------------------
 # Busca Numeracao
 #--------------------------------------------
  begin work

  call cts10g03_numeracao( 1, "" )
         returning lr_retorno.lignum     ,
                   lr_retorno.atdsrvnum  ,
                   lr_retorno.atdsrvano  ,
                   lr_retorno.codigosql,
                   lr_retorno.msg

  if  lr_retorno.codigosql = 0  then
      commit work
  else
      rollback work
      return cts10g14_xmlerro( lr_retorno.service
                              ,lr_retorno.codigosql
                              ,lr_retorno.msg)

  end if

  begin work

  #--------------------------------------------
  # Gera Atendimento
  #--------------------------------------------

  call ctd24g00_ins_atd(lr_retorno.nulo
                       ,1
                       ,lr_param.c24solnom
                       ,lr_retorno.nulo
                       ,lr_param.c24soltipcod
                       ,lr_param.ramcod
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.corsus
                       ,lr_param.succod
                       ,lr_param.aplnumdig
                       ,lr_param.itmnumdig
                       ,lr_retorno.nulo
                       ,lr_param.segnom
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.prporg
                       ,lr_param.prpnumdig
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.semdocto
                       ,"N"
                       ,"N"
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.sinvstnum
                       ,lr_param.sinvstano
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.pestip
                       ,lr_param.cgccpfnum
                       ,lr_param.cgcord
                       ,lr_param.cgccpfdig
                       ,lr_param.corsus
                       ,lr_param.funmatatd
                       ,lr_param.empcodatd
                       ,lr_param.dddcod
                       ,lr_param.ctttel
                       ,lr_param.funmat
                       ,lr_param.empcod
                       ,lr_param.usrtip
                       ,lr_retorno.ligcvntip)
     returning lr_retorno.atdnum
              ,lr_retorno.codigosql
              ,lr_retorno.msg

     if lr_retorno.codigosql <> 0 then

          rollback work
          return cts10g14_xmlerro( lr_retorno.service
                                  ,lr_retorno.codigosql
                                  ,lr_retorno.msg)

     end if


  #--------------------------------------------
  # Gera Ligacao X Atendimento
  #--------------------------------------------

  call ctd25g00_insere_atendimento(lr_retorno.atdnum
                                  ,lr_retorno.lignum)
  returning lr_retorno.tabname,
            lr_retorno.codigosql


  if lr_retorno.codigosql <> 0 then

       rollback work
       let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)


  end if

  #--------------------------------------------
  # Recupera o Grupo do Ramo
  #--------------------------------------------

  if lr_param.ramcod is not null then

    call cts10g14_recupera_grupo_ramo(1, lr_param.ramcod)
    returning lr_retorno.sinramgrp,
              lr_retorno.codigosql,
              lr_retorno.msg

    if lr_retorno.codigosql <> 0 then

         rollback work
         return cts10g14_xmlerro( lr_retorno.service
                                 ,lr_retorno.codigosql
                                 ,lr_retorno.msg)
    end if

  end if

  #--------------------------------------------
  # Recupera Data e Hora do Banco
  #--------------------------------------------

  call cts40g03_data_hora_banco(2)
  returning lr_retorno.data,
            lr_retorno.hora


  #--------------------------------------------
  # Grava a Ligacao
  #--------------------------------------------

   call cts10g00_ligacao ( lr_retorno.lignum      ,
                           lr_retorno.data        ,
                           lr_retorno.hora        ,
                           lr_param.c24soltipcod  ,
                           lr_param.c24solnom     ,
                           lr_param.c24astcod     ,
                           lr_param.funmat        ,
                           lr_retorno.ligcvntip   ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_param.sinvstnum     ,
                           lr_param.sinvstano     ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_param.succod        ,
                           lr_param.ramcod        ,
                           lr_param.aplnumdig     ,
                           lr_param.itmnumdig     ,
                           lr_param.edsnumref     ,
                           lr_param.prporg        ,
                           lr_param.prpnumdig     ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        )
                 returning lr_retorno.tabname,
                           lr_retorno.codigosql


                 if lr_retorno.codigosql <> 0 then

                      rollback work
                      let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

                      return cts10g14_xmlerro( lr_retorno.service
                                              ,lr_retorno.codigosql
                                              ,lr_retorno.msg)

                 end if


   #--------------------------------------------
   # Recupera o Tipo de Solicitante
   #--------------------------------------------

    call cto00m00_nome_solicitante(lr_param.c24soltipcod,"")
    returning lr_retorno.codigosql    ,
              lr_retorno.msg          ,
              lr_retorno.c24soltipdes

    if lr_param.c24soltipcod < 3 then
       let lr_retorno.c24soltip = lr_retorno.c24soltipdes[1,1]
    else
       let lr_retorno.c24soltip = "O"
    end if


   #--------------------------------------------
   # Grava o Pedido da Vistoria
   #--------------------------------------------

   call cts10g14_inclui_pedido_vistoria( lr_param.sinvstnum     ,
                                         lr_param.sinvstano     ,
                                         lr_param.c24solnom     ,
                                         lr_retorno.c24soltip   ,
                                         lr_param.c24soltipcod  ,
                                         lr_param.sindat        ,
                                         lr_param.sinhor        ,
                                         lr_param.segnom        ,
                                         lr_param.cornom        ,
                                         lr_param.endddd        ,
                                         lr_param.teldes        ,
                                         lr_param.funmat        ,
                                         0                      ,
                                         lr_param.lclrsccod     ,
                                         lr_param.lclendflg     ,
                                         lr_param.lgdtip        ,
                                         lr_param.lgdnom        ,
                                         lr_param.lgdnum        ,
                                         lr_param.endufd        ,
                                         lr_param.lgdnomcmp     ,
                                         lr_param.endbrr        ,
                                         lr_param.endcid        ,
                                         lr_param.endcep        ,
                                         lr_param.endcepcmp     ,
                                         lr_param.endddd        ,
                                         lr_param.teldes        ,
                                         lr_param.lclcttnom     ,
                                         lr_param.endrefpto     ,
                                         lr_param.sinhst        ,
                                         lr_param.sinobs        ,
                                         2                      ,
                                         lr_retorno.data        ,
                                         lr_retorno.hora        ,
                                         lr_param.rglvstflg     ,
                                         lr_retorno.sinramgrp   ,
                                         lr_param.lclnumseq     ,
                                         lr_param.rmerscseq     )
      returning lr_retorno.codigosql,
                lr_retorno.msg


      if lr_retorno.codigosql <> 0 then

           rollback work
           return cts10g14_xmlerro( lr_retorno.service
                                   ,lr_retorno.codigosql
                                   ,lr_retorno.msg)

      end if


    #--------------------------------------------
    # Grava Cobertura X Natureza
    #--------------------------------------------

     call cts10g14_inclui_cobertura_natureza(lr_param.sinvstnum   ,
                                             lr_param.sinvstano   ,
                                             lr_param.cbttip      ,
                                             lr_retorno.sinramgrp ,
                                             lr_param.sinntzcod   ,
                                             lr_param.orcvlr    )
     returning lr_retorno.codigosql,
               lr_retorno.msg


     if lr_retorno.codigosql <> 0 then

          rollback work
          return  cts10g14_xmlerro( lr_retorno.service
                                   ,lr_retorno.codigosql
                                   ,lr_retorno.msg)

     end if


     #--------------------------------------------
     # Grava Local de Ocorrencia
     #--------------------------------------------

     call cts06g07_local("I"                   ,
                         lr_param.sinvstnum    ,
                         lr_param.sinvstano    ,
                         1                     ,
                         lr_retorno.nulo       ,
                         lr_param.lgdtip       ,
                         lr_param.lgdnom       ,
                         lr_param.lgdnum       ,
                         lr_param.lclbrrnom    ,
                         lr_param.endbrr       ,
                         lr_param.endcid       ,
                         lr_param.endufd       ,
                         lr_param.endrefpto    ,
                         lr_param.endzon       ,
                         lr_param.endcep       ,
                         lr_param.endcepcmp    ,
                         lr_param.lclltt       ,
                         lr_param.lcllgt       ,
                         lr_param.endddd       ,
                         lr_param.teldes       ,
                         lr_param.lclcttnom    ,
                         lr_param.c24lclpdrcod ,
                         lr_retorno.nulo       ,
                         lr_param.emeviacod    ,
                         lr_param.celteldddcod ,
                         lr_param.celtelnum    ,
                         lr_param.lgdnomcmp)
     returning lr_retorno.codigosql

     if lr_retorno.codigosql <> 0 then

          rollback work
          let lr_retorno.msg = "ERRO AO INSERIR O LOCAL DE OCORRENCIA"

          return cts10g14_xmlerro( lr_retorno.service
                                  ,lr_retorno.codigosql
                                  ,lr_retorno.msg)
     end if


     commit work
     let lr_retorno.msg = "V12 GERADO COM SUCESSO "

     return cts10g14_sucesso_msg1 ( lr_retorno.service
                                   ,lr_retorno.msg
                                   ,lr_retorno.lignum
                                   ,lr_retorno.atdnum)



end function

#----------------------------------------------
function bdatm002_gerar_servico_re(lr_param)
#----------------------------------------------
define lr_param record
  c24soltipcod like datmligacao.c24soltipcod   ,
  c24solnom    like datmligacao.c24solnom      ,
  c24astcod    like datkassunto.c24astcod      ,
  funmat       like isskfunc.funmat            ,
  usrtip       like isskusuario.usrtip         ,
  empcod       like isskusuario.empcod         ,
  funmatatd    like isskfunc.funmat            ,
  usrtipatd    like isskusuario.usrtip         ,
  empcodatd    like isskusuario.empcod         ,
  cgccpfnum    like gsakseg.cgccpfnum          ,
  cgcord       like gsakseg.cgcord             ,
  cgccpfdig    like gsakseg.cgccpfdig          ,
  pestip       like gsakseg.pestip             ,
  succod       like datrligapol.succod         ,
  ramcod       like datrservapol.ramcod        ,
  aplnumdig    like datrligapol.aplnumdig      ,
  itmnumdig    like datrligapol.itmnumdig      ,
  edsnumref    like datrligapol.edsnumref      ,
  prporg       like datrligprp.prporg          ,
  prpnumdig    like datrligprp.prpnumdig       ,
  corsus       like datmservico.corsus         ,
  dddcod       like datmpedvist.dddcod         ,
  ctttel       like datmreclam.ctttel          ,
  semdocto     char(01)                        ,
  segnom       like datmpedvist.segnom         ,
  sinvstnum    like datmpedvist.sinvstnum      ,
  sinvstano    like datmpedvist.sinvstano      ,
  sindat       like datmpedvist.sindat         ,
  sinhor       like datmpedvist.sinhor         ,
  sinhst       like datmpedvist.sinhst         ,
  sinobs       like datmpedvist.sinobs         ,
  sinntzcod    like datrpedvistnatcob.sinntzcod,
  cbttip       like datrpedvistnatcob.cbttip   ,
  orcvlr       like datrpedvistnatcob.orcvlr   ,
  rglvstflg    like datmpedvist.rglvstflg      ,
  cornom       like datmpedvist.cornom         ,
  socntzcod    like datmsrvre.socntzcod        ,
  lgdtip       like datmpedvist.lgdtip         ,
  lgdnom       like datmpedvist.lgdnom         ,
  lgdnomcmp    like datmpedvist.lgdnomcmp      ,
  lgdnum       like datmpedvist.lgdnum         ,
  lclbrrnom    like datmlcl.lclbrrnom          ,
  endbrr       like datmpedvist.endbrr         ,
  endcid       like datmpedvist.endcid         ,
  endufd       like datmpedvist.endufd         ,
  endcep       like datmpedvist.endcep         ,
  endcepcmp    like datmpedvist.endcepcmp      ,
  lclcttnom    like datmpedvist.lclcttnom      ,
  endrefpto    like datmpedvist.endrefpto      ,
  endzon       like datmlcl.endzon             ,
  lclltt       like datmlcl.lclltt             ,
  lcllgt       like datmlcl.lcllgt             ,
  c24lclpdrcod like datmlcl.c24lclpdrcod       ,
  emeviacod    like datkemevia.emeviacod       ,
  endddd       like datmpedvist.endddd         ,
  teldes       like datmpedvist.teldes         ,
  celteldddcod like datmlcl.celteldddcod       ,
  celtelnum    like datmlcl.celtelnum          ,
  lclnumseq    like datmpedvist.lclnumseq      ,
  rmerscseq    like datmpedvist.rmerscseq      ,
  hist1        like datmservhist.c24srvdsc     ,
  hist2        like datmservhist.c24srvdsc     ,
  hist3        like datmservhist.c24srvdsc     ,
  hist4        like datmservhist.c24srvdsc     ,
  hist5        like datmservhist.c24srvdsc     ,
  lclrsccod    like datmpedvist.lclrsccod      ,
  lclendflg    like datmpedvist.lclendflg      ,
  prslocflg    char (01)                       ,
  srrcoddig    like datmsrvacp.srrcoddig       ,
  atdprscod    like datmservico.atdprscod      ,
  socvclcod    like datmservico.socvclcod      ,
  srvretmtvcod like datmsrvre.srvretmtvcod     ,
  srvretmtvdes like datksrvret.srvretmtvdes    ,
  c24pbmcod    like datkpbm.c24pbmcod          ,
  c24pbmdes    like datkpbm.c24pbmdes
end record


 define lr_retorno record
 	  codigosql    integer                      ,
    msg          char(80)                     ,
    service      char(20)                     ,
    nulo         char(1)                      ,
    data         date                         ,
    hora         datetime hour to minute      ,
    hora_atual   datetime hour to minute      ,
    tabname      like systables.tabname       ,
    sinramgrp    like gtakram.sinramgrp       ,
    c24soltip    like datmligacao.c24soltip   ,
    c24soltipdes like datksoltip.c24soltipdes ,
    lignum       like datmligacao.lignum      ,
    atdsrvorg    like datksrvtip.atdsrvorg    ,
    atdsrvnum    like datmservico.atdsrvnum   ,
	  atdsrvano    like datmservico.atdsrvano   ,
	  atdnum       like datratdlig.atdnum       ,
    srvnum       char (13)                    ,
    atddat       like datmservico.atddat      ,
    atdhor       like datmservico.atdhor      ,
    frmflg       char (01)                    ,
    atdfnlflg    like datmservico.atdfnlflg   ,
    acao_origem  char(03)                     ,
    operacao     char (01)                    ,
    lgdtxt       char (65)                    ,
    ofnnumdig    like sgokofi.ofnnumdig       ,
    atdetpcod    like datmsrvacp.atdetpcod    ,
	  atdlibflg    like datmservico.atdlibflg   ,
    cnldat       like datmservico.cnldat      ,
	  atdfnlhor    like datmservico.atdfnlhor   ,
	  c24opemat    like datmservico.c24opemat   ,
	  imdsrvflg    char (01)                    ,
	  atdlibhor    like datmservico.atdlibhor   ,
	  atdlibdat    like datmservico.atdlibdat   ,
	  atdhorpvt    like datmservico.atdhorpvt   ,
	  atdhorprg    like datmservico.atdhorprg   ,
	  atddatprg    like datmservico.atddatprg   ,
	  atdpvtretflg like datmservico.atdpvtretflg,
	  asitipcod    like datmservico.asitipcod   ,
	  atdprinvlcod like datmservico.atdprinvlcod,
	  c24nomctt    like datmservico.c24nomctt   ,
	  orrdat       like datmsrvre.orrdat        ,
	  orrhor       like datmsrvre.orrhor        ,
	  atdorgsrvnum like datmsrvre.atdorgsrvnum  ,
	  atdorgsrvano like datmsrvre.atdorgsrvano  ,
	  atddfttxt    like datmservico.atddfttxt   ,
	  nom          like datmservico.nom         ,
	  ligcvntip    like datmligacao.ligcvntip
 end record

 define lr_c24srvdsc   like datmservhist.c24srvdsc
      , l_ret          smallint
      , l_mensagem     char(50)
      , lr_hora        datetime hour to second

 initialize lr_retorno.*  ,
            g_documento.* ,
            g_issk.* to null


    let lr_retorno.service    = "GERAR_SERVICO_RE"
    let lr_retorno.ligcvntip  = 0
    let g_documento.ligcvntip = 0
    let g_issk.funmat         = lr_param.funmat
    let g_issk.empcod         = lr_param.empcod
    let g_issk.usrtip         = lr_param.usrtip
    let lr_c24srvdsc          = null
    let lr_hora               = current

 display "---------------------------------------------------------------------"
 display " 	                       SERVICO P10                             "
 display "---------------------------------------------------------------------"

    #--------------------------------------------
    # Valida Dados do Documento
    #--------------------------------------------
    call cts10g14_valida_documento(lr_param.semdocto  ,
                                   lr_param.succod    ,
                                   lr_param.ramcod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.prporg    ,
                                   lr_param.prpnumdig ,
                                   lr_param.corsus    ,
                                   lr_param.dddcod    ,
                                   lr_param.ctttel    ,
                                   lr_param.funmatatd ,
                                   lr_param.usrtipatd ,
                                   lr_param.empcodatd ,
                                   lr_param.cgccpfnum ,
                                   lr_param.cgcord    ,
                                   lr_param.cgccpfdig ,
                                   lr_param.sinvstnum ,
                                   lr_param.sinvstano )
     returning  lr_retorno.codigosql,
                lr_retorno.msg


     if lr_retorno.codigosql <> 0 then
          return cts10g14_xmlerro( lr_retorno.service
                                  ,lr_retorno.codigosql
                                  ,lr_retorno.msg)
     end if



     #--------------------------------------------
     # Gera Atendimento
     #--------------------------------------------
     call ctd24g00_ins_atd(lr_retorno.nulo
                          ,1
                          ,lr_param.c24solnom
                          ,lr_retorno.nulo
                          ,lr_param.c24soltipcod
                          ,lr_param.ramcod
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_param.corsus
                          ,lr_param.succod
                          ,lr_param.aplnumdig
                          ,lr_param.itmnumdig
                          ,lr_retorno.nulo
                          ,lr_param.segnom
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_param.prporg
                          ,lr_param.prpnumdig
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_param.semdocto
                          ,"N"
                          ,"N"
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,lr_retorno.nulo
                          ,""
                          ,lr_param.pestip
                          ,lr_param.cgccpfnum
                          ,lr_param.cgcord
                          ,lr_param.cgccpfdig
                          ,lr_param.corsus
                          ,lr_param.funmatatd
                          ,lr_param.empcodatd
                          ,lr_param.dddcod
                          ,lr_param.ctttel
                          ,lr_param.funmat
                          ,lr_param.empcod
                          ,lr_param.usrtip
                          ,lr_retorno.ligcvntip)
        returning lr_retorno.atdnum
                 ,lr_retorno.codigosql
                 ,lr_retorno.msg

        if lr_retorno.codigosql <> 0 then

             return cts10g14_xmlerro( lr_retorno.service
                                     ,lr_retorno.codigosql
                                     ,lr_retorno.msg)

        end if



     #--------------------------------------------
     # Recupera Data e Hora do Banco
     #--------------------------------------------
     call cts40g03_data_hora_banco(2)
     returning lr_retorno.data,
               lr_retorno.hora


     #--------------------------------------------
     # Recupera o Tipo de Solicitante
     #--------------------------------------------
      call cto00m00_nome_solicitante(lr_param.c24soltipcod,"")
      returning lr_retorno.codigosql    ,
                lr_retorno.msg          ,
                lr_retorno.c24soltipdes

      if lr_param.c24soltipcod < 3 then
         let g_documento.soltip = lr_retorno.c24soltipdes[1,1]
      else
         let g_documento.soltip = "O"
      end if

    #--------------------------------------------------------------------
    # Carga das Variaveis para a Geracao do Servico Automaticamente P10
    #-------------------------------------------------------------------
     let lr_retorno.nom           = lr_param.segnom
     let g_documento.solnom       = lr_param.c24solnom
     let g_documento.c24soltipcod = lr_param.c24soltipcod
     let g_documento.lclnumseq    = lr_param.lclnumseq
     let g_documento.rmerscseq    = lr_param.rmerscseq
     let g_documento.ciaempcod    = 1
     let g_documento.itmnumdig    = lr_param.itmnumdig
     let g_documento.edsnumref    = lr_param.edsnumref
     let lr_retorno.atdfnlflg     = "N"
     let lr_retorno.atdsrvorg     = 9
     let lr_retorno.operacao      = "I"
     let lr_retorno.atdlibflg     = "S"
     let lr_retorno.asitipcod     = 6
     let lr_retorno.atdprinvlcod  = 2
     let lr_retorno.atddat        = lr_retorno.data
     let lr_retorno.atdhor        = lr_retorno.hora
     let lr_retorno.operacao      = "I"
     let lr_retorno.ofnnumdig     = lr_retorno.nulo
     let lr_retorno.atdlibhor     = lr_retorno.hora
     let lr_retorno.atdlibdat     = lr_retorno.data
     let lr_param.sinntzcod       = 5
     let lr_retorno.atdpvtretflg  = "N"
     let lr_retorno.atdetpcod     = lr_retorno.nulo
     let lr_retorno.atddfttxt     = lr_param.c24pbmdes
     let lr_param.hist1           = 'GERACAO AUTOMATICA DE P10. REFERENTE AO SINISTRO: ' ,
                                     lr_param.sinvstnum,'/',lr_param.sinvstano


    #--------------------------------------------------------------------
    # Verifica Regras de Servico Imediato ou Programado
    #-------------------------------------------------------------------

     let lr_retorno.hora_atual = current

     if lr_retorno.hora_atual >= "09:00" and
        lr_retorno.hora_atual <= "18:00" then

        let lr_retorno.imdsrvflg = "S"
        let lr_retorno.atdhorpvt = "02:00"

     else

        let lr_retorno.imdsrvflg    = "N"

        if lr_retorno.hora_atual >= "06:00" and
           lr_retorno.hora_atual <  "09:00" then

           call dias_uteis(lr_retorno.data,0,"","S","N")
           returning lr_retorno.atddatprg

           if lr_retorno.atddatprg = lr_retorno.data then
              let lr_retorno.atdhorprg = lr_retorno.hora_atual + 3 units hour
           else
              let lr_retorno.atdhorprg = "09:00"
           end if

        else

           if lr_retorno.hora_atual > "18:00" then

              call dias_uteis(lr_retorno.data,+1,"","S","N")
              returning lr_retorno.atddatprg

              let lr_retorno.atdhorprg = "09:00"

           else

              call dias_uteis(lr_retorno.data,0,"","S","N")
              returning lr_retorno.atddatprg

              let lr_retorno.atdhorprg = "09:00"

           end if
        end if
     end if


     #--------------------------------------------------------------------
     # Gera Servico Automaticamente P10
     #-------------------------------------------------------------------
     display "<5649> bdatm002_gerar_servico_re -> Gera Servico Automaticamente P10 ... "
     display "<5650> bdatm002_gerar_servico_re ->ctf00m08_gera_p10 ... ", lr_param.c24astcod

     display "<6001> lr_param.sinntzcod: ", lr_param.sinntzcod
     display "<6002> lr_param.socntzcod: ", lr_param.socntzcod

     call ctf00m08_gera_p10(lr_param.c24astcod       ,
                            lr_retorno.atdsrvorg     ,
                            lr_retorno.atdsrvnum     ,
                            lr_retorno.atdsrvano     ,
                            lr_retorno.srvnum        ,
                            lr_retorno.atddat        ,
                            lr_retorno.atdhor        ,
                            lr_param.funmat          ,
                            lr_retorno.frmflg        ,
                            lr_retorno.atdfnlflg     ,
                            lr_retorno.acao_origem   ,
                            lr_param.prslocflg       ,
                            lr_retorno.operacao      ,
                            lr_retorno.nulo          ,
                            lr_retorno.lgdtxt        ,
                            lr_param.lgdtip          ,
                            lr_param.lgdnom          ,
                            lr_param.lgdnum          ,
                            lr_param.endbrr          ,
                            lr_param.lclbrrnom       ,
                            lr_param.endzon          ,
                            lr_param.endcid          ,
                            lr_param.endufd          ,
                            lr_param.endcep          ,
                            lr_param.endcepcmp       ,
                            lr_param.lclltt          ,
                            lr_param.lcllgt          ,
                            lr_param.endddd          ,
                            lr_param.teldes          ,
                            lr_param.lclcttnom       ,
                            lr_param.endrefpto       ,
                            lr_param.c24lclpdrcod    ,
                            lr_retorno.ofnnumdig     ,
                            lr_param.emeviacod       ,
                            lr_param.celteldddcod    ,
                            lr_param.celtelnum       ,
                            lr_param.lgdnomcmp       ,
                            lr_retorno.atdetpcod     ,
                            lr_retorno.atdlibflg     ,
                            lr_param.srrcoddig       ,
                            lr_retorno.cnldat        ,
                            lr_retorno.atdfnlhor     ,
                            lr_retorno.c24opemat     ,
                            lr_param.atdprscod       ,
                            lr_retorno.c24nomctt     ,
                            lr_param.lclrsccod       ,
                            lr_param.sindat          ,
                            lr_param.sinhor          ,
                            lr_param.sinntzcod       ,
                            lr_param.socntzcod       ,
                            lr_param.lclnumseq       ,
                            lr_param.rmerscseq       ,
                            lr_param.sinvstnum       ,
                            lr_param.sinvstano       ,
                            lr_retorno.atdorgsrvnum  ,
                            lr_retorno.atdorgsrvano  ,
                            lr_param.srvretmtvcod    ,
                            lr_param.srvretmtvdes    ,
                            lr_param.c24pbmcod       ,
                            lr_retorno.atddfttxt     ,
                            lr_retorno.nom           ,
                            lr_param.corsus          ,
                            lr_param.cornom          ,
                            lr_retorno.asitipcod     ,
                            lr_retorno.atdprinvlcod  ,
                            lr_retorno.imdsrvflg     ,
                            lr_retorno.atdlibhor     ,
                            lr_retorno.atdlibdat     ,
                            lr_retorno.atdhorpvt     ,
                            lr_retorno.atdhorprg     ,
                            lr_retorno.atddatprg     ,
                            lr_retorno.atdpvtretflg  ,
                            lr_param.socvclcod       ,
                            lr_param.hist1           ,
                            lr_param.hist2           ,
                            lr_param.hist3           ,
                            lr_param.hist4           ,
                            lr_param.hist5         )
       returning lr_retorno.codigosql     ,
                 lr_param.c24astcod       ,
                 lr_retorno.atdsrvorg     ,
                 lr_retorno.atdsrvnum     ,
                 lr_retorno.atdsrvano     ,
                 lr_retorno.srvnum        ,
                 lr_retorno.atddat        ,
                 lr_retorno.atdhor        ,
                 lr_param.funmat          ,
                 lr_retorno.frmflg        ,
                 lr_retorno.atdfnlflg     ,
                 lr_retorno.acao_origem   ,
                 lr_param.prslocflg       ,
                 lr_retorno.operacao      ,
                 lr_retorno.nulo          ,
                 lr_retorno.lgdtxt        ,
                 lr_param.lgdtip          ,
                 lr_param.lgdnom          ,
                 lr_param.lgdnum          ,
                 lr_param.endbrr          ,
                 lr_param.lclbrrnom       ,
                 lr_param.endzon          ,
                 lr_param.endcid          ,
                 lr_param.endufd          ,
                 lr_param.endcep          ,
                 lr_param.endcepcmp       ,
                 lr_param.lclltt          ,
                 lr_param.lcllgt          ,
                 lr_param.endddd          ,
                 lr_param.teldes          ,
                 lr_param.lclcttnom       ,
                 lr_param.endrefpto       ,
                 lr_param.c24lclpdrcod    ,
                 lr_retorno.ofnnumdig     ,
                 lr_param.emeviacod       ,
                 lr_param.celteldddcod    ,
                 lr_param.celtelnum       ,
                 lr_param.lgdnomcmp       ,
                 lr_retorno.atdetpcod     ,
                 lr_retorno.atdlibflg     ,
                 lr_param.srrcoddig       ,
                 lr_retorno.cnldat        ,
                 lr_retorno.atdfnlhor     ,
                 lr_retorno.c24opemat     ,
                 lr_param.atdprscod       ,
                 lr_retorno.c24nomctt     ,
                 lr_param.lclrsccod       ,
                 lr_param.sindat          ,
                 lr_param.sinhor          ,
                 lr_param.sinntzcod       ,
                 lr_param.socntzcod       ,
                 lr_param.lclnumseq       ,
                 lr_param.rmerscseq       ,
                 lr_param.sinvstnum       ,
                 lr_param.sinvstano       ,
                 lr_retorno.atdorgsrvnum  ,
                 lr_retorno.atdorgsrvano  ,
                 lr_param.srvretmtvcod    ,
                 lr_param.srvretmtvdes    ,
                 lr_param.c24pbmcod     ,
                 lr_retorno.atddfttxt     ,
                 lr_retorno.nom           ,
                 lr_param.corsus          ,
                 lr_param.cornom          ,
                 lr_retorno.asitipcod     ,
                 lr_retorno.atdprinvlcod  ,
                 lr_retorno.imdsrvflg     ,
                 lr_retorno.atdlibhor     ,
                 lr_retorno.atdlibdat     ,
                 lr_retorno.atdhorpvt     ,
                 lr_retorno.atdhorprg     ,
                 lr_retorno.atddatprg     ,
                 lr_retorno.atdpvtretflg  ,
                 lr_param.socvclcod

       let lr_c24srvdsc =  lr_param.hist2
       display"-------------------------------------------------------------"
       display" ------------------- TESTE DATMSERVHIST ---------------------"
       display"lr_retorno.atddat........:",lr_retorno.atddat
       display"lr_hora..................:",lr_hora
       display"-------------------------------------------------------------"

       call ctd07g01_ins_datmservhist(lr_retorno.atdsrvnum
                                    , lr_retorno.atdsrvano
                                    , g_issk.funmat
                                    , lr_c24srvdsc
                                    , lr_retorno.atddat
                                    , lr_hora
                                    , g_issk.empcod
                                    , g_issk.usrtip)
            returning l_ret
                    , l_mensagem

       display "l_ret      .......: ", l_ret
       display "l_mensagem .......: ", l_mensagem

       display "<5804> bdatm002_gerar_servico_re -> lr_retorno.codigosql<", lr_retorno.codigosql, ">"
       if lr_retorno.codigosql = false then

            let lr_retorno.msg       = "ERRO AO GERAR O SERVICO P10 AUTOMATICAMENTE"
            let lr_retorno.codigosql = -1

            return cts10g14_xmlerro( lr_retorno.service
                                    ,lr_retorno.codigosql
                                    ,lr_retorno.msg)


       end if

       #--------------------------------------------
       # Gera Ligacao X Atendimento
       #--------------------------------------------
       display "<5820> bdatm002_gerar_servico_re -> ctd25g00_insere_atendimento ... <",lr_retorno.atdnum,"-",g_documento.lignum,">"
       call ctd25g00_insere_atendimento(lr_retorno.atdnum
                                       ,g_documento.lignum)
       returning lr_retorno.tabname,
                 lr_retorno.codigosql

       display "<5826> bdatm002_gerar_servico_re -> lr_retorno.codigosql<", lr_retorno.codigosql, ">"
       if lr_retorno.codigosql <> 0 then

            let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

            return cts10g14_xmlerro( lr_retorno.service
                                    ,lr_retorno.codigosql
                                    ,lr_retorno.msg)


       end if


       let lr_retorno.msg = "P10 GERADO COM SUCESSO "

       return cts10g14_sucesso_msg2 ( lr_retorno.service
                                     ,lr_retorno.msg
                                     ,g_documento.lignum
                                     ,lr_retorno.atdnum
                                     ,g_documento.atdsrvano
                                     ,g_documento.atdsrvnum)



end function

#----------------------------------------------
function bdatm002_alterar_aviso_re(lr_param)
#----------------------------------------------

define lr_param record
  c24soltipcod like datmligacao.c24soltipcod   ,
  c24solnom    like datmligacao.c24solnom      ,
  c24astcod    like datkassunto.c24astcod      ,
  funmat       like isskfunc.funmat            ,
  usrtip       like isskusuario.usrtip         ,
  empcod       like isskusuario.empcod         ,
  funmatatd    like isskfunc.funmat            ,
  usrtipatd    like isskusuario.usrtip         ,
  empcodatd    like isskusuario.empcod         ,
  cgccpfnum    like gsakseg.cgccpfnum          ,
  cgcord       like gsakseg.cgcord             ,
  cgccpfdig    like gsakseg.cgccpfdig          ,
  pestip       like gsakseg.pestip             ,
  succod       like datrligapol.succod         ,
  ramcod       like datrservapol.ramcod        ,
  aplnumdig    like datrligapol.aplnumdig      ,
  itmnumdig    like datrligapol.itmnumdig      ,
  edsnumref    like datrligapol.edsnumref      ,
  prporg       like datrligprp.prporg          ,
  prpnumdig    like datrligprp.prpnumdig       ,
  corsus       like datmservico.corsus         ,
  dddcod       like datmpedvist.dddcod         ,
  ctttel       like datmreclam.ctttel          ,
  semdocto     char(01)                        ,
  segnom       like datmpedvist.segnom         ,
  sinvstnum    like datmpedvist.sinvstnum      ,
  sinvstano    like datmpedvist.sinvstano      ,
  sindat       like datmpedvist.sindat         ,
  sinhor       like datmpedvist.sinhor         ,
  sinhst       like datmpedvist.sinhst         ,
  sinobs       like datmpedvist.sinobs         ,
  sinntzcod    like datrpedvistnatcob.sinntzcod,
  cbttip       like datrpedvistnatcob.cbttip   ,
  orcvlr       like datrpedvistnatcob.orcvlr   ,
  rglvstflg    like datmpedvist.rglvstflg      ,
  cornom       like datmpedvist.cornom         ,
  socntzcod    like datmsrvre.socntzcod        ,
  lgdtip       like datmpedvist.lgdtip         ,
  lgdnom       like datmpedvist.lgdnom         ,
  lgdnomcmp    like datmpedvist.lgdnomcmp      ,
  lgdnum       like datmpedvist.lgdnum         ,
  lclbrrnom    like datmlcl.lclbrrnom          ,
  endbrr       like datmpedvist.endbrr         ,
  endcid       like datmpedvist.endcid         ,
  endufd       like datmpedvist.endufd         ,
  endcep       like datmpedvist.endcep         ,
  endcepcmp    like datmpedvist.endcepcmp      ,
  lclcttnom    like datmpedvist.lclcttnom      ,
  endrefpto    like datmpedvist.endrefpto      ,
  endzon       like datmlcl.endzon             ,
  lclltt       like datmlcl.lclltt             ,
  lcllgt       like datmlcl.lcllgt             ,
  c24lclpdrcod like datmlcl.c24lclpdrcod       ,
  emeviacod    like datkemevia.emeviacod       ,
  endddd       like datmpedvist.endddd         ,
  teldes       like datmpedvist.teldes         ,
  celteldddcod like datmlcl.celteldddcod       ,
  celtelnum    like datmlcl.celtelnum          ,
  lclnumseq    like datmpedvist.lclnumseq      ,
  rmerscseq    like datmpedvist.rmerscseq      ,
  lclrsccod    like datmpedvist.lclrsccod      ,
  lclendflg    like datmpedvist.lclendflg      ,
  hist1        like datmlighist.c24ligdsc      ,
  hist2        like datmlighist.c24ligdsc      ,
  hist3        like datmlighist.c24ligdsc      ,
  hist4        like datmlighist.c24ligdsc      ,
  hist5        like datmlighist.c24ligdsc
end record

define lr_retorno record
	 codigosql    integer                      ,
   msg          char(80)                     ,
   service      char(20)                     ,
   nulo         char(1)                      ,
   sinramgrp    like gtakram.sinramgrp       ,
   data         date                         ,
   hora         datetime hour to minute      ,
   tabname      like systables.tabname       ,
   c24soltip    like datmligacao.c24soltip   ,
   c24soltipdes like datksoltip.c24soltipdes ,
   lignum       like datmligacao.lignum      ,
   atdsrvnum    like datmservico.atdsrvnum   ,
   atdsrvano    like datmservico.atdsrvano   ,
   hora_atual   datetime hour to minute      ,
   atdnum       like datratdlig.atdnum       ,
   ligcvntip    like datmligacao.ligcvntip
end record


 initialize lr_retorno.*  ,
           g_documento.* ,
           g_issk.* to null

 let lr_retorno.service   = "ALTERAR_AVISO"
 let lr_retorno.ligcvntip = 0
 let g_documento.acao     = "ALT"
 let g_issk.funmat        = lr_param.funmat
 let g_issk.empcod        = lr_param.empcod
 let g_issk.usrtip        = lr_param.usrtip


 #--------------------------------------------
 # Valida Dados do Documento
 #--------------------------------------------

 call cts10g14_valida_documento(lr_param.semdocto  ,
                                lr_param.succod    ,
                                lr_param.ramcod    ,
                                lr_param.aplnumdig ,
                                lr_param.prporg    ,
                                lr_param.prpnumdig ,
                                lr_param.corsus    ,
                                lr_param.dddcod    ,
                                lr_param.ctttel    ,
                                lr_param.funmatatd ,
                                lr_param.usrtipatd ,
                                lr_param.empcodatd ,
                                lr_param.cgccpfnum ,
                                lr_param.cgcord    ,
                                lr_param.cgccpfdig ,
                                lr_param.sinvstnum ,
                                lr_param.sinvstano )
  returning  lr_retorno.codigosql,
             lr_retorno.msg


  if lr_retorno.codigosql <> 0 then
       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)

  end if

 #--------------------------------------------
 # Recupera Pedido Atraves do Sinistro
 #--------------------------------------------

 call cts10g14_recupera_pedido_aviso_re(lr_param.sinvstnum,
                                        lr_param.sinvstano)
 returning  lr_retorno.codigosql,
            lr_retorno.msg


  if lr_retorno.codigosql <> 0 then
       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)

  end if


  #--------------------------------------------
  # Recupera Data e Hora do Banco
  #--------------------------------------------

  call cts40g03_data_hora_banco(2)
  returning lr_retorno.data,
            lr_retorno.hora

 #--------------------------------------------
 # Busca Numeracao
 #--------------------------------------------
  begin work

  call cts10g03_numeracao( 1, "" )
         returning lr_retorno.lignum     ,
                   lr_retorno.atdsrvnum  ,
                   lr_retorno.atdsrvano  ,
                   lr_retorno.codigosql,
                   lr_retorno.msg

  if  lr_retorno.codigosql = 0  then
      commit work
  else
      rollback work
      return cts10g14_xmlerro( lr_retorno.service
                              ,lr_retorno.codigosql
                              ,lr_retorno.msg)

  end if

  begin work

  #--------------------------------------------
  # Gera Atendimento
  #--------------------------------------------

  call ctd24g00_ins_atd(lr_retorno.nulo
                       ,1
                       ,lr_param.c24solnom
                       ,lr_retorno.nulo
                       ,lr_param.c24soltipcod
                       ,lr_param.ramcod
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.corsus
                       ,lr_param.succod
                       ,lr_param.aplnumdig
                       ,lr_param.itmnumdig
                       ,lr_retorno.nulo
                       ,lr_param.segnom
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.prporg
                       ,lr_param.prpnumdig
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.semdocto
                       ,"N"
                       ,"N"
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.sinvstnum
                       ,lr_param.sinvstano
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_retorno.nulo
                       ,lr_param.pestip
                       ,lr_param.cgccpfnum
                       ,lr_param.cgcord
                       ,lr_param.cgccpfdig
                       ,lr_param.corsus
                       ,lr_param.funmatatd
                       ,lr_param.empcodatd
                       ,lr_param.dddcod
                       ,lr_param.ctttel
                       ,lr_param.funmat
                       ,lr_param.empcod
                       ,lr_param.usrtip
                       ,lr_retorno.ligcvntip)
     returning lr_retorno.atdnum
              ,lr_retorno.codigosql
              ,lr_retorno.msg

     if lr_retorno.codigosql <> 0 then

          rollback work
          return cts10g14_xmlerro( lr_retorno.service
                                  ,lr_retorno.codigosql
                                  ,lr_retorno.msg)

     end if


  #--------------------------------------------
  # Gera Ligacao X Atendimento
  #--------------------------------------------

  call ctd25g00_insere_atendimento(lr_retorno.atdnum
                                  ,lr_retorno.lignum)
  returning lr_retorno.tabname,
            lr_retorno.codigosql


  if lr_retorno.codigosql <> 0 then

       rollback work
       let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

       return cts10g14_xmlerro( lr_retorno.service
                               ,lr_retorno.codigosql
                               ,lr_retorno.msg)


  end if

  #--------------------------------------------
  # Recupera o Grupo do Ramo
  #--------------------------------------------

  if lr_param.ramcod is not null then

    call cts10g14_recupera_grupo_ramo(1, lr_param.ramcod)
    returning lr_retorno.sinramgrp,
              lr_retorno.codigosql,
              lr_retorno.msg

    if lr_retorno.codigosql <> 0 then

         rollback work
         return cts10g14_xmlerro( lr_retorno.service
                                 ,lr_retorno.codigosql
                                 ,lr_retorno.msg)
    end if

  end if


  #--------------------------------------------
  # Grava a Ligacao
  #--------------------------------------------

   call cts10g00_ligacao ( lr_retorno.lignum      ,
                           lr_retorno.data        ,
                           lr_retorno.hora        ,
                           lr_param.c24soltipcod  ,
                           lr_param.c24solnom     ,
                           lr_param.c24astcod     ,
                           lr_param.funmat        ,
                           lr_retorno.ligcvntip   ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_param.sinvstnum     ,
                           lr_param.sinvstano     ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_param.succod        ,
                           lr_param.ramcod        ,
                           lr_param.aplnumdig     ,
                           lr_param.itmnumdig     ,
                           lr_param.edsnumref     ,
                           lr_param.prporg        ,
                           lr_param.prpnumdig     ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        ,
                           lr_retorno.nulo        )
                 returning lr_retorno.tabname,
                           lr_retorno.codigosql


                 if lr_retorno.codigosql <> 0 then

                      rollback work
                      let lr_retorno.msg = "ERRO AO INSERIR A LIGACAO! TABELA: ", lr_retorno.tabname clipped

                      return cts10g14_xmlerro( lr_retorno.service
                                              ,lr_retorno.codigosql
                                              ,lr_retorno.msg)

                 end if


   #--------------------------------------------
   # Recupera o Tipo de Solicitante
   #--------------------------------------------

    call cto00m00_nome_solicitante(lr_param.c24soltipcod,"")
    returning lr_retorno.codigosql    ,
              lr_retorno.msg          ,
              lr_retorno.c24soltipdes

    if lr_param.c24soltipcod < 3 then
       let lr_retorno.c24soltip = lr_retorno.c24soltipdes[1,1]
    else
       let lr_retorno.c24soltip = "O"
    end if


   #--------------------------------------------
   # Altera o Pedido da Vistoria
   #--------------------------------------------

   call cts10g14_altera_pedido_vistoria( lr_param.sinvstnum     ,
                                         lr_param.sinvstano     ,
                                         lr_param.sindat        ,
                                         lr_param.sinhor        ,
                                         lr_param.endddd        ,
                                         lr_param.teldes        ,
                                         lr_param.lclrsccod     ,
                                         lr_param.lclendflg     ,
                                         lr_param.lgdtip        ,
                                         lr_param.lgdnom        ,
                                         lr_param.lgdnum        ,
                                         lr_param.endufd        ,
                                         lr_param.lgdnomcmp     ,
                                         lr_param.endbrr        ,
                                         lr_param.endcid        ,
                                         lr_param.endcep        ,
                                         lr_param.endcepcmp     ,
                                         lr_param.endddd        ,
                                         lr_param.teldes        ,
                                         lr_param.lclcttnom     ,
                                         lr_param.endrefpto     ,
                                         lr_param.sinhst        ,
                                         lr_param.sinobs        ,
                                         lr_retorno.data        ,
                                         lr_retorno.hora        ,
                                         lr_param.rglvstflg     ,
                                         lr_param.lclnumseq     ,
                                         lr_param.rmerscseq     )
      returning lr_retorno.codigosql,
                lr_retorno.msg


      if lr_retorno.codigosql <> 0 then

           rollback work
           return cts10g14_xmlerro( lr_retorno.service
                                   ,lr_retorno.codigosql
                                   ,lr_retorno.msg)

      end if

     #--------------------------------------------
     # Altera Cobertura X Natureza
     #--------------------------------------------

      call cts10g14_altera_cobertura_natureza(lr_param.sinvstnum   ,
                                              lr_param.sinvstano   ,
                                              lr_param.cbttip      ,
                                              lr_param.sinntzcod   ,
                                              lr_param.orcvlr    )
      returning lr_retorno.codigosql,
                lr_retorno.msg


      if lr_retorno.codigosql <> 0 then

           rollback work
           return  cts10g14_xmlerro( lr_retorno.service
                                    ,lr_retorno.codigosql
                                    ,lr_retorno.msg)

      end if


    #--------------------------------------------
    # Altera Local de Ocorrencia
    #--------------------------------------------

    call cts06g07_local("M"                   ,
                        lr_param.sinvstnum    ,
                        lr_param.sinvstano    ,
                        1                     ,
                        lr_retorno.nulo       ,
                        lr_param.lgdtip       ,
                        lr_param.lgdnom       ,
                        lr_param.lgdnum       ,
                        lr_param.lclbrrnom    ,
                        lr_param.endbrr       ,
                        lr_param.endcid       ,
                        lr_param.endufd       ,
                        lr_param.endrefpto    ,
                        lr_param.endzon       ,
                        lr_param.endcep       ,
                        lr_param.endcepcmp    ,
                        lr_param.lclltt       ,
                        lr_param.lcllgt       ,
                        lr_param.endddd       ,
                        lr_param.teldes       ,
                        lr_param.lclcttnom    ,
                        lr_param.c24lclpdrcod ,
                        lr_retorno.nulo       ,
                        lr_param.emeviacod    ,
                        lr_param.celteldddcod ,
                        lr_param.celtelnum    ,
                        lr_param.lgdnomcmp)
    returning lr_retorno.codigosql

     if lr_retorno.codigosql <> 0 then

          let lr_retorno.msg = "ERRO AO ATUALIZAR O LOCAL DE OCORRENCIA"
          rollback work
          return cts10g14_xmlerro( lr_retorno.service
                                  ,lr_retorno.codigosql
                                  ,lr_retorno.msg)

     end if

     commit work
     let lr_retorno.msg = "V01 GERADO COM SUCESSO "

     return cts10g14_sucesso_msg1 ( lr_retorno.service
                                   ,lr_retorno.msg
                                   ,lr_retorno.lignum
                                   ,lr_retorno.atdnum)

end function
#------------------------------------------------------------------------------#
function bdatm002_valida_string(lr_param_in)
#------------------------------------------------------------------------------#
     define lr_param_in  record
            socntzcod    char(100)
     end    record

     define lr_param_out record
            socntzcod    like datmsrvre.socntzcod
     end    record

     define lr_count     smallint
          , i            smallint
          , lr_ret       char(100)

     initialize lr_param_out.* to null

     let lr_count = length(lr_param_in.socntzcod)
     let i        = 0
     let lr_ret   = null

     for i = 1 to lr_count

         if  lr_param_in.socntzcod[i] is not null and
             lr_param_in.socntzcod[i] <> " "      then

             let lr_ret = lr_ret   clipped
                        , lr_param_in.socntzcod[i]

         end if

     end for

     let  lr_param_out.socntzcod = lr_ret clipped

     return lr_param_out.socntzcod

end function
#------------------------------------------------------------------------------#
function bdatm002_de_para(lr_param_in)
#------------------------------------------------------------------------------#
     define lr_param_in   record
            c24pbmcod     like datkpbm.c24pbmcod
     end    record

     define lr_param_out  record
            socntzcod     like datmsrvre.socntzcod
          , c24pbmdes     like datkpbm.c24pbmdes
     end    record

#     case lr_param_in.c24pbmcod
#          when 313
#               let lr_param_out.socntzcod = 48
#          when 700
#               let lr_param_out.socntzcod = 210
#          when 701
#               let lr_param_out.socntzcod = 211
#          when 702
#               let lr_param_out.socntzcod = 212
#          when 703
#               let lr_param_out.socntzcod = 213
#          when 704
#               let lr_param_out.socntzcod = 214
#          when 844
#               let lr_param_out.socntzcod = 290
#     end  case
#
     open  cbdatm002006 using lr_param_in.c24pbmcod

           whenever error continue
           fetch cbdatm002006 into lr_param_out.c24pbmdes
           whenever error stop

           if  sqlca.sqlcode <> 0   and
               sqlca.sqlcode <> 100 then
               display "DOMINIO PROBLEMA NÃO ENCONTRADO PARA O CODIGO: "
                      , lr_param_in.c24pbmcod
               let lr_param_out.c24pbmdes = 'OUTROS' clipped
           end if

     close cbdatm002006

     return lr_param_out.c24pbmdes

end function
