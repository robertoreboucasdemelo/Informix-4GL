#############################################################################
# Nome do Modulo: CTS06G11                                         Adriano  #
# Digitacao padronizada de enderecos para laudos de servicos:               #
# Indexacao Automatica                                             Nov/2009 #
# ######################################################################### #
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 02/03/2010 Adriano S     PSI252891 Inclusao do padrao idx 4 e 5           #
#---------------------------------------------------------------------------#
# 22.09.2010 Ronaldo, Meta           Redesenho dos Laudos de Assistencias   #
#                                    Fase I                                 #
#---------------------------------------------------------------------------#
# 04/11/2011 Marcos Goes  PSI2011-18556 Inclusao de Oficinas Referenciadas  #
#                                       do Itau.                            #
# 28/03/2012 Sergio Burini  PSI-2010-01968/PB                               #
# 19/02/2014 Fabio, Fornax PSI-2014-03931IN Melhorias indexacao Fase 01     #
#---------------------------------------------------------------------------#
# 09/04/2014 CDS Egeu     PSI-2014-02085   Situação Local de Ocorrência     #
#---------------------------------------------------------------------------#
# 05/06/2014 Fabio, Fornax  PSI-2014-11756/EV Melhorias na indexacao fase 2 #
#---------------------------------------------------------------------------#
# 13/02/2015 Luiz, Fornax CT236168 - Ajuste na busca do nome da cidade.     #
#---------------------------------------------------------------------------#
# 13/05/2015 Roberto Fornax          Mercosul                               #
#---------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/figrc072.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob2.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"    

define m_hostname       char(10)
define m_server         char(03)
define m_flagsemidx     smallint
define m_prep_sql       smallint

define m_subbairro array[03] of record
       brrnom      like datmlcl.lclbrrnom
end record

define m_sql       char(300)

define m_lgdtip    like datmlcl.lgdtip
define m_lgdnom    like datmlcl.lgdnom
define m_km        like datmlcl.lgdnum
define m_sentido   char(60)
define m_pista     char(60)
define m_lclrefptotxt like datmlcl.lclrefptotxt
define m_brrnomidx  char(45)

#-----------------------------------------------------------
 function cts06g11_prepare()
#-----------------------------------------------------------

 define l_sql char (300)

 let l_sql = "select glaklgd.lgdtip   ,",
              "       glaklgd.lgdnom   ,",
              "       glaklgd.cidcod   ,",
              "       glaklgd.brrcod    ",
              "  from glaklgd           ",
              " where glaklgd.lgdcep    = ? ",
              "   and glaklgd.lgdcepcmp = ? "
 prepare p_cts06g11_001 from l_sql
 declare c_cts06g11_001 cursor for p_cts06g11_001
 #----------------------------------------------
 let l_sql = "select glakcid.cidnom   ,",
              "       glakcid.ufdcod    ",
              "  from glakcid           ",
              " where glakcid.cidcod    = ? "

 prepare p_cts06g11_002 from l_sql
 declare c_cts06g11_002 cursor for p_cts06g11_002
 #----------------------------------------------
 let l_sql = "select glakbrr.brrnom    ",
              "  from glakbrr           ",
              " where glakbrr.cidcod    = ? ",
              "   and glakbrr.brrcod    = ? "

 prepare p_cts06g11_003 from l_sql
 declare c_cts06g11_003 cursor for p_cts06g11_003
 #-----------------------------------------------
 let l_sql = " select c24astcod ",
                " from datmligacao ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and lignum = (select min(lignum) ",
                                 " from datmligacao ",
                                " where atdsrvnum = ? ",
                                  " and atdsrvano = ?) "

 prepare p_cts06g11_004 from l_sql
 declare c_cts06g11_004 cursor for p_cts06g11_004

 whenever error continue
 let l_sql = " select b.segnumdig ",
                " from rsamseguro a ",
                   "  ,rsdmdocto  b ",
               " where a.succod    = ? ",
                 " and a.aplnumdig = ? ",
                 " and a.ramcod    = ? ",
                 " and b.sgrorg    = a.sgrorg ",
                 " and b.sgrnumdig = a.sgrnumdig ",
                 " and b.prpstt   in (19,65,66,88) ",
                 " order by b.dctnumseq desc "

 prepare p_cts06g11_005 from l_sql
 declare c_cts06g11_005 cursor for p_cts06g11_005
 whenever error stop

 let l_sql = "select datkmpacid.mpacidcod    ",
              "  from datkmpacid           ",
              " where datkmpacid.cidnom    = ? ",
              "   and datkmpacid.ufdcod    = ? "

 prepare p_cts06g11_006 from l_sql
 declare c_cts06g11_006 cursor for p_cts06g11_006
 
 let l_sql = "select count(datkmpacid.mpacidcod)    ",
              "  from datkmpacid           ",
              " where datkmpacid.cidnom like ? ",
              "   and datkmpacid.ufdcod    = ? "

 prepare p_cts06g11_006b from l_sql
 declare c_cts06g11_006b cursor for p_cts06g11_006b
 
 let l_sql = " select datkmpacid.mpacidcod         ",
             "   from datkmpacid                   ",
             "  where datkmpacid.cidnom like ?  ",
             "    and datkmpacid.ufdcod    = ?     "

 prepare p_cts06g11_006c from l_sql
 declare c_cts06g11_006c cursor for p_cts06g11_006c
 
 
  let l_sql = "select cidcod,cidcep,cidcepcmp ",
              " from glakcid ",
             " where cidnom = ? ",
               " and ufdcod = ? "
 prepare p_cts06g11_007 from l_sql
 declare c_cts06g11_007 cursor for p_cts06g11_007

 #let l_sql = "select datkmpabrr.lclltt,        ",
 #            "       datkmpabrr.lcllgt         ",
 #            "   from datkmpabrr               ",
 #            "  where datkmpabrr.brrnom    = ? ",
 #            "    and datkmpabrr.mpacidcod = ? "
 #
 #prepare sel_datkmpabrr from l_sql
 #declare c_datkmpabrr cursor for sel_datkmpabrr
 #
 #let l_sql = "select datkmpabrrsub.lclltt,        ",
 #            "       datkmpabrrsub.lcllgt         ",
 #            "   from datkmpabrrsub               ",
 #            "  where datkmpabrrsub.mpacidcod = ? ",
 #            "    and datkmpabrrsub.brrsubnom = ? "
 #
 #prepare sel_datkmpabrrsub from l_sql
 #declare c_datkmpabrrsub cursor for sel_datkmpabrrsub


 let l_sql = ' select count(*)                 '
            , '   from datkdominio              '
            , '  where cponom = "tipo_endereco" '
            , '    and cpodes = ?               '
  prepare p_cts06g11_008 from l_sql
  declare c_cts06g11_008 cursor for p_cts06g11_008
  let l_sql = ' select count(*)                 '
            , '   from datkdominio              '
            , '  where cponom = "tipo_endereco_nav" '
            , '    and cpodes = ?               '
  prepare p_cts06g11_009 from l_sql
  declare c_cts06g11_009 cursor for p_cts06g11_009

 let l_sql = "select mpacidcod ",
              " from datkmpacid ",
             " where cidnom = ? ",
               " and ufdcod = ? "
 prepare p_cts06g11_010 from l_sql
 declare c_cts06g11_010 cursor for p_cts06g11_010

#Inicio - Situação local de ocorrência
 let l_sql = ' select cpocod                '
            ,'   from iddkdominio           '
            ,'  where cponom = "LOCALRISCO" '
            ,'    and cpodes = ?            '
  prepare p_cts06g11_011 from l_sql
  declare c_cts06g11_011 cursor for p_cts06g11_011

 let l_sql = ' select count(*)                '
            ,'   from iddkdominio           '
            ,'  where cponom = "SRVATDLCLRSC" '
            ,'    and cpocod = ?            '
  prepare p_cts06g11_012 from l_sql
  declare c_cts06g11_012 cursor for p_cts06g11_012
#Fim - Situação local de ocorrência

 let l_sql = " select ufdcod ",
             " from glakcid ",
             " where cidnom = ? "
 prepare p_cts06g11_013 from l_sql
 declare c_cts06g11_013 cursor for p_cts06g11_013

 let l_sql = " select ufdcod ",
             " from datkmpacid ",
             " where cidnom = ? "
 prepare p_cts06g11_014 from l_sql
 declare c_cts06g11_014 cursor for p_cts06g11_014

 let l_sql = " select count(*) ",
             " from datkdominio ",
             " where cponom = 'paises_mercosul' ",
             "   and cpodes = ? "
 prepare p_cts06g11_015 from l_sql
 declare c_cts06g11_015 cursor for p_cts06g11_015
 let m_prep_sql = true

end function  ###  cts06g11_prepare

#-----------------------------------------------------------------
 function cts06g11(param, d_cts06g11, hist_cts06g11,lr_emeviacod)
#-----------------------------------------------------------------

 define param      record
    c24endtip      like datmlcl.c24endtip,
    atdsrvorg      like datmservico.atdsrvorg,
    ligcvntip      like datmligacao.ligcvntip,
    hoje           char (10),
    hora           char (05)
 end record

 define d_cts06g11 record
    lclidttxt      like datmlcl.lclidttxt,
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    brrnom         like datmlcl.brrnom,
    lclbrrnom      like datmlcl.lclbrrnom,
    endzon         like datmlcl.endzon,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    lgdnum         like datmlcl.lgdnum,
    lgdcep         like datmlcl.lgdcep,
    lgdcepcmp      like datmlcl.lgdcepcmp,
    lclltt         like datmlcl.lclltt,
    lcllgt         like datmlcl.lcllgt,
    lclrefptotxt   like datmlcl.lclrefptotxt,
    lclcttnom      like datmlcl.lclcttnom,
    dddcod         like datmlcl.dddcod,
    lcltelnum      like datmlcl.lcltelnum,
    c24lclpdrcod   like datmlcl.c24lclpdrcod,
    ofnnumdig      like sgokofi.ofnnumdig,
    celteldddcod   like datmlcl.celteldddcod,
    celtelnum      like datmlcl.celtelnum,
    endcmp         like datmlcl.endcmp
 end record

 define d1_cts06g11  record
    obsofic char(22),
    staofic char(12),
    des     char(10),
    lblnum  char(10)
 end record

 define salva      record
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    lgdnum         like datmlcl.lgdnum,
    endcmp         like datmlcl.endcmp,
    brrnom         like datmlcl.brrnom,
    lclbrrnom      like datmlcl.lclbrrnom,
    lclltt         like datmlcl.lclltt,
    lcllgt         like datmlcl.lcllgt
 end record

 define hist_cts06g11 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws         record
    cepflg         char (01),
    retflg         char (01),
    locflg         char (01),
    cidcod         like glakcid.cidcod,
    ufdcod         like glakest.ufdcod,
    brrcod         like glakbrr.brrcod,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    brrnom         like datmlcl.brrnom,
    cpodes         like iddkdominio.cpodes,
    mpacidcod      like datkmpacid.mpacidcod,
    mpacrglgdflg   like datkmpacid.mpacrglgdflg,
    gpsacngrpcod   like datkmpacid.gpsacngrpcod,
    cabtxt         char (68),
    confirma       char (01),
    benef          char (01),
    benefx         char (01),
    ofnnumdig      like datmlcl.ofnnumdig,
    ptoref1        char (50),
    ptoref2        char (50),
    ptoref3        char (50),
    ptoref4        char (50),
    result         dec  (1,0),
    clscod         char (03),
    cidcep         like glakcid.cidcep,
    cidcepcmp      like glakcid.cidcepcmp,
    prompt_key     char(01),
    ofnstt         like sgokofi.ofnstt,
    lclltt_cid     like datmlcl.lclltt,
    lcllgt_cid     like datmlcl.lcllgt,
    ctgtrfcod      like abbmcasco.ctgtrfcod, # osf 19968
    #compleme      char(20),
    ramcod         like gtakram.ramcod,
    ok             char(01),
    c24astcod      like datmligacao.c24astcod,
    endres         char(01),
#   decide_via     char(1), - #Situação local de ocorrência
    nome           char(60),
    cgccpf         char(20),
    pessoa         char(01),
    email          char(100),
    vclchsfnl      like adbmbaixa.vclchsfnl,
    vcllicnum      like adbmbaixa.vcllicnum,
    msgerr         char(100),
    codpais        char(11),
    despais        char(40),
    erro           smallint,
    latlontxt      char(32),
    ocrlclstt      char(01), #Situação local de ocorrência
    txtocrlcl      char(15) #Situação local de ocorrência
 end record

 define l_c24fxolclcod             like datkfxolcl.c24fxolclcod
       ,l_flag_local_especial      char(1)
       ,l_orides                   char(030)
       ,l_count_auto               smallint  #Situação local de ocorrência
       ,l_flag_auto                char(01)  #Situação local de ocorrência

# define l_lclltt    like datmlcl.lclltt
#       ,l_lcllgt    like datmlcl.lcllgt

 ### PSI 192007 - JUNIOR(META)

 define  l_resultado     smallint
        ,l_ret           smallint
        ,l_mensagem      char(60)
        ,l_segnumdig     like abbmdoc.segnumdig
        ,l_segnumdig_idx like abbmdoc.segnumdig
        ,l_erro          smallint

 define  l_gsakend  record
         segnumdig  like gsakend.segnumdig,
         endfld     like gsakend.endfld,
         endlgdtip  like gsakend.endlgdtip,
         endlgd     like gsakend.endlgd,
         endnum     like gsakend.endnum,
         endcmp     like gsakend.endcmp,
         endcepcmp  like gsakend.endcepcmp,
         endbrr     like gsakend.endbrr,
         endcid     char(45),
         endufd     like gsakend.endufd,
         endcep     like gsakend.endcep,
         dddcod     like gsakend.dddcod,
         teltxt     like gsakend.teltxt,
         tlxtxt     like gsakend.tlxtxt,
         factxt     like gsakend.factxt,
         atlult     like gsakend.atlult
 end record

 ### PSI 192007 - JUNIOR(META) - FIM

 define lr_ctc71m01_ret record
        c24fxolclcod   like datkfxolcl.c24fxolclcod,
        lclidttxt      like datmlcl.lclidttxt,
        lgdtip         like datmlcl.lgdtip,
        lgdnom         like datmlcl.lgdnom,
        compleme       char(20),
        lgdnum         like datmlcl.lgdnum,
        lgdcep         like datmlcl.lgdcep,
        lgdcepcmp      like datmlcl.lgdcepcmp,
        brrnom         like datmlcl.brrnom,
        cidnom         like datmlcl.cidnom,
        ufdcod         like datmlcl.ufdcod,
        endzon         like datmlcl.endzon,
        c24lclpdrcod   like datmlcl.c24lclpdrcod,
        lclltt         like datmlcl.lclltt,
        lcllgt         like datmlcl.lcllgt
 end record

 define lr_salva       record
         lgdcep        like datmlcl.lgdcep,
         lgdcepcmp     like datmlcl.lgdcepcmp,
         lclidttxt     like datmlcl.lclidttxt,
         emeviacod     like datkemevia.emeviacod
#        emeviades     like datkemevia.emeviades  #Situação local de ocorrência
 end record

 define lr_emeviacod record
                     emeviacod like datkemevia.emeviacod
                     end record

 define #l_via_desc   char(013), - Situação local de ocorrência
        l_doc_handle integer,
        l_cep        char(10),
        l_ind        smallint,
        l_ind2       smallint,
        l_status     smallint,
        l_oriprc     smallint,
        l_totcid     smallint,
        l_nomcid     like datmlcl.cidnom

#Inicio - Situação local de ocorrência
{
 define lr_ctc17m02 record
                    emeviades  like datkemevia.emeviades
                   ,emeviapri  char(005)
                   end record
}
#Fim - Situação local de ocorrência

 define lr_ctx25g05  record
        lgdtip       like datkmpalgd.lgdtip,
        lgdnom       like datkmpalgd.lgdnom,
        lgdnum       like datmlcl.lgdnum,
        brrnom       like datmlcl.brrnom,
        lgdcep       like datmlcl.lgdcep,
        lgdcepcmp    like datmlcl.lgdcepcmp,
        lclltt       like datmlcl.lclltt,
        lcllgt       like datmlcl.lcllgt,
        c24lclpdrcod like datmlcl.c24lclpdrcod,
        ufdcod       like datkmpacid.ufdcod,
        cidnom       like datkmpacid.cidnom
 end record

 define lr_ctx25g05_pes  record
        ret              integer, # 0 -> OK     <> 0 -> ERRO
        lclltt           like datmlcl.lclltt,
        lcllgt           like datmlcl.lcllgt,
        lgdtip           like datkmpalgd.lgdtip,
        lgdnom           like datkmpalgd.lgdnom,
        brrnom           char(65),
        lclbrrnom        char(65),
        lgdcep           like datmlcl.lgdcep,
        c24lclpdrcod     like datmlcl.c24lclpdrcod
 end record


 define lr_cts06g11 record
     cidnom like datmlcl.cidnom,
     ufdcod like datmlcl.ufdcod
 end record

 define lr_daf record
     status_ret smallint,
     ufdcod     like datkmpacid.ufdcod,
     cidnom     like datkmpacid.cidnom,
     lgdtip     like datkmpalgd.lgdtip,
     lgdnom     like datkmpalgd.lgdnom,
     lgdnomalt  like datkmpalgd.lgdnom,
     brrnom     like datkmpabrr.brrnom,
     lclltt     like datmlcl.lclltt,
     lcllgt     like datmlcl.lcllgt,
     numero     integer
 end record

 define lr_idx_brr    record
     lclltt       like datmlcl.lclltt,
     lcllgt       like datmlcl.lcllgt,
     c24lclpdrcod like datmlcl.c24lclpdrcod
 end record

 define l_c24lclpdrcod like datmlcl.c24lclpdrcod
       ,l_fondafinf    smallint
       ,l_end_aux      char(200)

 define  l_tplougr          char(100)
        ,l_cabec            char(30)
        ,l_pontoreferencia  char(350)
        ,l_tpmarginal       char(100)
        ,l_dstqtd           decimal(8,4)
        ,l_tolerancia       decimal(8,4)
        ,l_idxdaf           smallint
        ,l_errcod           smallint
        ,l_rodcidnom        like datmlcl.cidnom
        ,l_count            integer
	,l_c24endtip        like datmlcl.c24endtip
        
 define l_vlcodcid record
   cidcod      like glakcid.cidcod
  ,cidcep      like glakcid.cidcep
  ,cidcepcmp   like glakcid.cidcepcmp
  ,cidnom      like datmlcl.cidnom
  ,ufdcod      like datmlcl.ufdcod
  ,prcok       char(1)    #Flag dados preenchidos
 end record

 initialize d1_cts06g11.* to null      #OSF 19968
# initialize lr_ctc17m02.* to null - Situação local de ocorrência
 initialize lr_ctx25g05.* to null
 initialize lr_ctx25g05_pes.* to null 
 initialize ws.* to null
 initialize lr_ctc71m01_ret.* to null
 initialize lr_salva.* to null
 initialize salva.* to null  
 initialize lr_cts06g11.* to null
 initialize lr_daf.* to null
 initialize l_c24lclpdrcod to null
 initialize l_vlcodcid.* to null  
 initialize lr_emeviacod.* to null 
 initialize lr_idx_brr.* to null   
 initialize l_gsakend.* to null
 
 let l_c24lclpdrcod = d_cts06g11.c24lclpdrcod
 initialize l_resultado       to null
 initialize l_mensagem        to null
 initialize l_doc_handle      to null
 initialize l_cep             to null
 initialize l_status          to null
 initialize l_fondafinf       to null
 initialize l_end_aux         to null
 initialize l_erro            to null
 initialize l_dstqtd          to null
 initialize m_brrnomidx       to null
 initialize l_count           to null
 initialize l_count_auto      to null #Situação local de ocorrência
 initialize l_flag_auto       to null #Situação local de ocorrência
 initialize l_pontoreferencia to null
 initialize l_tplougr         to null
 initialize l_cabec           to null
 initialize l_tpmarginal      to null
 initialize m_lgdtip          to null
 initialize m_lgdnom          to null    
 initialize l_c24endtip       to null
 let l_c24endtip       = param.c24endtip
 initialize l_totcid          to null  
 initialize l_nomcid          to null
 initialize l_rodcidnom       to null
 initialize l_tolerancia      to null
 initialize l_oriprc          to null
 initialize l_ret             to null
 initialize l_segnumdig       to null
 initialize l_segnumdig_idx   to null
 
 if param.c24endtip = 1 then
   let g_indexado.endnum1 = null
   let g_indexado.endcid1 = null
   let g_indexado.endnum2 = null
   let g_indexado.endcid2 = null
 end if
 let l_flag_local_especial = "N"
 #let l_via_desc = null - #Situação local de ocorrência
 initialize l_ind  to null
 initialize l_ind2 to null  
 initialize m_flagsemidx to null
 initialize l_idxdaf to null
 initialize l_errcod to null
 
 let m_flagsemidx = false
 let l_idxdaf     = false
 let l_errcod = 0

 initialize  ws.*, lr_daf.*  to  null
 #let ws.decide_via = 'N'
 # let entrou.*  = d_cts06g11.* ##ligia - retirar


 if d_cts06g11.brrnom is null or
    d_cts06g11.brrnom = " " then
    let d_cts06g11.brrnom = d_cts06g11.lclbrrnom
 end if

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts06g11_prepare()
 end if

 if  param.c24endtip = 1 then
     whenever error continue
     create temp table tmp_idx
          (srvhstseq smallint,
           endlgdtip char(10),
           endlgd    char(60),
           endlgdnum smallint,
           endbrrnom char(40),
           ciddes    char(45),
           ufdcod    char(2),
           lclltt    decimal(8,6),
           lcllgt    decimal(8,6)) with no log
     whenever error stop
 end if
 

 
 #-------------------------------
 #Verifica o agrupamento
 #-------------------------------
 if d_cts06g11.lclidttxt = "BRASIL" then
    let d1_cts06g11.des  = "Local Fixo"
    let d_cts06g11.ufdcod = ""
    let d_cts06g11.lclidttxt = ""
 else
    if (g_documento.c24astcod = 'M15' or
        g_documento.c24astcod = 'M20' or
        g_documento.c24astcod = 'M23' or
        g_documento.c24astcod = 'M33' or
        g_documento.c24astcod = 'KM1' or      
        g_documento.c24astcod = 'KM2' or      
        g_documento.c24astcod = 'KM3') then   
         
       if d_cts06g11.ufdcod = "EX" and
          d_cts06g11.lclidttxt is null then
          let d_cts06g11.lclidttxt = d_cts06g11.cidnom
          let d_cts06g11.cidnom = ""
       else
       	 
          let m_sql = "select cpocod "
                     ,",cpodes "
                     ,"from datkdominio "
                     ,"where cponom = 'paises_mercosul' "
                     ,"order by cpodes "
          call ofgrc001_popup(10,10,"PAISES - MERCOSUL","CODIGO","DESCRICAO",
                         'N',m_sql,
                         "",'D')
              returning ws.erro,
                        ws.codpais,
                        ws.despais

          let d_cts06g11.ufdcod = "EX"
          let d_cts06g11.lclidttxt = ws.despais
       end if
    end if
 end if
 #------------------------------------------------------------------------
 # Verifica tipo de local a ser informado
 #------------------------------------------------------------------------
 if param.atdsrvorg    is null  or
    param.ligcvntip is null  then
    error " Parametros nao informados. AVISE A INFORMATICA!"
    call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
    return d_cts06g11.*, "N", hist_cts06g11.*,lr_emeviacod.emeviacod
 #Inicio - Situação local de ocorrência
 else  #Possui origem
    open  c_cts06g11_012 using param.atdsrvorg
    fetch c_cts06g11_012 into l_count_auto
    if l_count_auto = 0 then
       let l_flag_auto = 'N' #Serviço não é auto
    else
       let l_flag_auto = 'S' #Serviço auto
    end if
 #Fim - Situação local de ocorrência
 end if

 if param.ligcvntip  =  89   or      ## Avis Rent a Car
    param.ligcvntip  =  90   or      ## Mega Rent a Car
    param.ligcvntip  =  91   or      ## Seg Car Locadora
    param.ligcvntip  =  92   then    ## Repar Locadora
    let ws.locflg = "S"
 else
    let ws.locflg = "N"
 end if

 let ws.retflg = "N"

 if g_documento.ciaempcod = 1  or   ## Empresa Porto
    g_documento.ciaempcod = 50 then ## Empresa Porto Saude

    select ctgtrfcod into ws.ctgtrfcod from abbmcasco
     where abbmcasco.succod    = g_documento.succod     and
           abbmcasco.aplnumdig = g_documento.aplnumdig  and
           abbmcasco.itmnumdig = g_documento.itmnumdig  and
           abbmcasco.dctnumseq = g_funapol.autsitatu

    -------[ categorias tarifarias que oferecem desconto ou carro extra ]-----
    let ws.benefx = "N"
    if ws.ctgtrfcod = 10 or
       ws.ctgtrfcod = 14 or
       ws.ctgtrfcod = 16 or
       ws.ctgtrfcod = 22 or
       ws.ctgtrfcod = 80 or
       ws.ctgtrfcod = 30 or #CT263618
       ws.ctgtrfcod = 31 or #CT263618
       # inclusao dessas categorais por solicitacao da Bia. 25/04/07
       ws.ctgtrfcod = 11 or
       ws.ctgtrfcod = 15 or
       ws.ctgtrfcod = 17 or
       ws.ctgtrfcod = 20 or
       ws.ctgtrfcod = 21 or
       ws.ctgtrfcod = 23 or
       ws.ctgtrfcod = 81 then
       let ws.benefx = "S"
    end if              # osf 19968

 else
    if g_documento.ciaempcod = 35 then ## Azul Seguros
       call cts42g00_doc_handle(g_documento.succod, g_documento.ramcod,
                                g_documento.aplnumdig, g_documento.itmnumdig,
                                g_documento.edsnumref)
            returning l_resultado, l_mensagem, l_doc_handle
    end if
 end if

 #------------------------------------------------------------------------
 # Verifica tipo de local a ser informado
 #------------------------------------------------------------------------
 if param.c24endtip is null  then
    error " Tipo do local nao informado. AVISE A INFORMATICA!"
    call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg, ws.mpacidcod, ws.cidcod)
    return d_cts06g11.*, ws.retflg, hist_cts06g11.*,lr_emeviacod.emeviacod
 end if

 if param.atdsrvorg = 18 then
    let param.c24endtip  = param.c24endtip + 3
 end if

 select cpodes
   into ws.cpodes
   from iddkdominio
  where iddkdominio.cponom  =  "c24endtip"
    and iddkdominio.cpocod  =  param.c24endtip

  if param.atdsrvorg = 18 then
     if param.c24endtip = 5 then
        let param.c24endtip  = param.c24endtip - 4
     else
        if param.c24endtip = 6 then
           let param.c24endtip  = param.c24endtip - 5
        else
           let param.c24endtip  = param.c24endtip - 3
        end if
     end if
 end if

 if sqlca.sqlcode  <>  0    then
    error " Tipo do local (", param.c24endtip  using "<<<<&",
          ") nao cadastrado. AVISE A INFORMATICA!"
    call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
    return d_cts06g11.*, ws.retflg, hist_cts06g11.*,lr_emeviacod.emeviacod
 end if

 let ws.cabtxt  =  "                 Informacoes do local de ", downshift(ws.cpodes)

 if g_documento.ciaempcod = 1  or   ## Empresa Porto
    g_documento.ciaempcod = 50 then ## Empresa Porto Saude

    #------------------------------------------------------------------------
    # Verifica se apolice tem clausula 096
    #------------------------------------------------------------------------
     select clscod into ws.clscod
         from abbmclaus
        where succod    = g_documento.succod
          and aplnumdig = g_documento.aplnumdig
          and itmnumdig = g_documento.itmnumdig
          and dctnumseq = g_funapol.dctnumseq
          and clscod    = "096"
 end if

 #------------------------------------------------------------------------
 # Salva dados sobre o local
 #------------------------------------------------------------------------
 initialize salva.*  to null
 let salva.cidnom     =  d_cts06g11.cidnom  #ligia 09/10/07
 let salva.ufdcod     =  d_cts06g11.ufdcod
 let salva.lgdtip     =  d_cts06g11.lgdtip
 let salva.lgdnom     =  d_cts06g11.lgdnom
 let salva.endcmp     =  d_cts06g11.endcmp
 let salva.lgdnum     =  d_cts06g11.lgdnum
 let salva.brrnom     =  d_cts06g11.brrnom
 let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
 let salva.lclltt     =  d_cts06g11.lclltt
 let salva.lcllgt     =  d_cts06g11.lcllgt

 let d1_cts06g11.des  = "Local Fixo"
 if param.atdsrvorg   = 16 and
    d_cts06g11.ufdcod = "EX" then
    let d1_cts06g11.des = "Pais"
 end if

  if (param.atdsrvorg = 1 or
      param.atdsrvorg = 2 or     # Mercosul
      param.atdsrvorg = 4) and
		  d_cts06g11.ufdcod = "EX" then
		  let d1_cts06g11.des = "Pais"
	end if

 call cty22g02_retira_acentos(d_cts06g11.cidnom)
                                 returning d_cts06g11.cidnom
 let d_cts06g11.cidnom = upshift(d_cts06g11.cidnom)
 call cty22g02_retira_acentos(d_cts06g11.ufdcod)
                                 returning d_cts06g11.ufdcod
 let d_cts06g11.ufdcod = upshift(d_cts06g11.ufdcod)
 call cty22g02_retira_acentos(d_cts06g11.lgdtip)
                                 returning d_cts06g11.lgdtip
 let d_cts06g11.lgdtip = upshift(d_cts06g11.lgdtip)
 call cty22g02_retira_acentos(d_cts06g11.lgdnom)
                                 returning d_cts06g11.lgdnom
 let d_cts06g11.lgdnom = upshift(d_cts06g11.lgdnom)
 call cty22g02_retira_acentos(d_cts06g11.brrnom )
                                 returning d_cts06g11.brrnom
 let d_cts06g11.brrnom  = upshift(d_cts06g11.brrnom )
 call cty22g02_retira_acentos(d_cts06g11.lclbrrnom)
                                 returning d_cts06g11.lclbrrnom
 let d_cts06g11.lclbrrnom = upshift(d_cts06g11.lclbrrnom)

 # PSI-2014-11756 - Muda label quando rodovia
 let d1_cts06g11.lblnum = 'Numero.....'

 open window cts06g11 at 05,03 with form "cts06g11"
      attribute(border, form line 1, message line last, comment line last - 1)

 display by name ws.cabtxt
 display by name d1_cts06g11.des
 display by name d1_cts06g11.lblnum
 #display l_via_desc to via - Situação local de ocorrência
 initialize ws.endres to null
 initialize ws.confirma to null
 initialize m_lclrefptotxt to null

 display 'Ponto Ref...:' to pontoref

 if g_documento.lclocodesres <> "S" and
    g_documento.atdsrvnum is null then
    if param.atdsrvorg =  1  or
       param.atdsrvorg =  2  or   # assistencia a passageiros
       param.atdsrvorg =  4  or
       param.atdsrvorg =  6  or
       param.atdsrvorg =  13 or
       param.atdsrvorg =  14 then

       if g_documento.aplnumdig is not null  or
          g_documento.prpnumdig is not null  then
          if param.c24endtip = 1  then
             let l_orides = " OCORRENCIA "
          else
             if param.c24endtip = 2 then
                initialize l_gsakend.* to null
             end if
             let l_orides = " DESTINO "
          end if

          let l_orides = " O ENDERECO DE " clipped, l_orides

          if param.atdsrvorg =  9  or
             param.atdsrvorg =  13 then
              let g_documento.lclocodesres = "S"
          else
              
              if not cty41g00_valida_assunto(g_documento.c24astcod) then            
                 if cts08g01("A","S",""
                            ,l_orides
                            ," E O MESMO DA RESIDENCIA  "
                            ," DO SEGURADO ? ") = "S" then
                    let g_documento.lclocodesres = "S"
                 end if
              end if
          end if

          if g_documento.lclocodesres = "S" then

              if not ((param.atdsrvorg = 9 or param.atdsrvorg = 13) and       # Org 9 e 13
                      (d_cts06g11.lgdnom is not null and
                       d_cts06g11.lgdnom <> " ")) then
                  if g_documento.c24astcod = 'M15' or
                     g_documento.c24astcod = 'M20' or
                     g_documento.c24astcod = 'M23' or
                     g_documento.c24astcod = 'M33' or
                     g_documento.c24astcod = 'KM1' or                         
                     g_documento.c24astcod = 'KM2' or                         
                     g_documento.c24astcod = 'KM3' then                      
                     open  c_cts06g11_015 using d_cts06g11.lclidttxt
                     fetch c_cts06g11_015 into l_count
                     if l_count > 0 then
                        initialize d_cts06g11.lclidttxt ,d_cts06g11.ufdcod to null
                     end if
                  end if
                  if g_documento.ciaempcod = 1  or   ## Empresa Porto
                     g_documento.ciaempcod = 50 then ## Empresa Porto Saude

                     call figrc072_setTratarIsolamento()

                     ### Pesquisa codigo do segurado atraves da apolice
                     call cty05g00_segnumdig(g_documento.succod,
                                             g_documento.aplnumdig,
                                             g_documento.itmnumdig,
                                             g_funapol.dctnumseq,
                                             g_documento.prporg,
                                             g_documento.prpnumdig )
                          returning l_resultado, l_mensagem, l_segnumdig

                     if g_isoAuto.sqlCodErr <> 0 then
                        let l_resultado = g_isoAuto.sqlCodErr
                        let l_mensagem  = "Pesquisa do Codigo do Segurado Indisponivel! Erro: "
                              ,g_isoAuto.sqlCodErr
                     end if

                     if l_resultado <> 1 then

                        whenever error continue
                        open c_cts06g11_005 using g_documento.succod,
                                                g_documento.aplnumdig,
                                                g_documento.ramcod
                        fetch c_cts06g11_005 into l_segnumdig
                        whenever error stop

                        if sqlca.sqlcode = 100 then
                           error l_mensagem
                        end if
                     end if

                     ## Obter o endereco do segurado

                     call osgtk1001_pesquisarEnderecoPorCodigo(l_segnumdig)
                     returning l_ret, l_ind2

                     for l_ind = 1 to l_ind2

                        if g_a_gsakend[l_ind].endfld = 1 then

                           let l_gsakend.segnumdig   =  l_segnumdig
                           let l_gsakend.endfld      =  g_a_gsakend[l_ind].endfld
                           let l_gsakend.endlgdtip   =  g_a_gsakend[l_ind].endlgdtip
                           let l_gsakend.endlgd      =  g_a_gsakend[l_ind].endlgd
                           let l_gsakend.endnum      =  g_a_gsakend[l_ind].endnum
                           let l_gsakend.endcmp      =  g_a_gsakend[l_ind].endcmp
                           let l_gsakend.endcepcmp   =  g_a_gsakend[l_ind].endcepcmp
                           let l_gsakend.endbrr      =  g_a_gsakend[l_ind].endbrr
                           let l_gsakend.endcid      =  g_a_gsakend[l_ind].endcid
                           let l_gsakend.endufd      =  g_a_gsakend[l_ind].endufd
                           let l_gsakend.endcep      =  g_a_gsakend[l_ind].endcep
                           let l_gsakend.dddcod      =  g_a_gsakend[l_ind].dddcod
                           let l_gsakend.teltxt      =  g_a_gsakend[l_ind].teltxt
                           let l_gsakend.tlxtxt      =  g_a_gsakend[l_ind].tlxtxt
                           let l_gsakend.factxt      =  g_a_gsakend[l_ind].factxt
                           let l_gsakend.atlult      =  g_a_gsakend[l_ind].atlult

                           #CT236168 - Ini
                           call cts06g11_carrega_endcid(l_gsakend.endcep, l_gsakend.endcepcmp, l_gsakend.endcid)
                              returning l_status, l_gsakend.endcid
                          #CT236168 - Fim

                           exit for

                        end if

                     end for

                  else
                     if g_documento.ciaempcod = 35 then
                        if l_doc_handle is not null then
                           call cts40g02_extraiDoXML(l_doc_handle, "SEGURADO_ENDERECO")
                                returning l_gsakend.endufd,
                                          l_gsakend.endcid,
                                          l_gsakend.endlgdtip,
                                          l_gsakend.endlgd,
                                          l_gsakend.endnum,
                                          d_cts06g11.lclrefptotxt,
                                          l_gsakend.endbrr,
                                          l_cep

                           call cts40g02_extraiDoXML(l_doc_handle, "SEGURADO")
                                returning ws.nome,
                                          ws.cgccpf,
                                          ws.pessoa,
                                          l_gsakend.dddcod,
                                          l_gsakend.teltxt,
                                          ws.email

                           let l_ret = 0
                           let l_gsakend.endcep = l_cep[1,5]
                           let l_gsakend.endcepcmp = l_cep[6,8]
                        end if
                     end if

                     if g_documento.ciaempcod = 84 then

                        
                        if g_documento.ramcod = 14 then
                        	
                       
                        	   let l_gsakend.endcep     = g_doc_itau[1].rsccepcod    clipped          
                        	   let l_gsakend.endcepcmp  = g_doc_itau[1].rsccepcplcod clipped        
                        	                                                                        
                        	   call cts06g11_retira_tipo_lougradouro(g_doc_itau[1].rsclgdnom)       
                        	   returning l_gsakend.endlgdtip                                        
                        	            ,l_gsakend.endlgd                                           
                        	                                                                        
                        	    let l_ret = 0                                                       
                        	    let l_gsakend.dddcod     = g_doc_itau[1].segresteldddnum clipped    
                        	    let l_gsakend.teltxt     = g_doc_itau[1].segrestelnum    clipped       
                        	    let l_gsakend.endnum     = g_doc_itau[1].rsclgdnum       clipped          
                        	    let l_gsakend.endbrr     = g_doc_itau[1].rscbrrnom       clipped          
                        	    let l_gsakend.endcid     = g_doc_itau[1].rsccidnom       clipped          
                        	    let l_gsakend.endufd     = g_doc_itau[1].rscestsgl       clipped          
                        	    let l_gsakend.endcep     = l_gsakend.endcep              using "&&&&&"          
                        	    let l_gsakend.endcepcmp  = l_gsakend.endcepcmp           using "&&&"          
                        	    let l_gsakend.endcmp     = ""      
                        
                        else
                        
                              let l_gsakend.endcep     = g_doc_itau[1].segcepnum  clipped
                              let l_gsakend.endcepcmp  = g_doc_itau[1].segcepcmpnum clipped
                              
                              call cts06g11_retira_tipo_lougradouro(g_doc_itau[1].seglgdnom)
                              returning l_gsakend.endlgdtip
                                       ,l_gsakend.endlgd
                              
                               let l_ret = 0
                               let l_gsakend.dddcod     = g_doc_itau[1].segresteldddnum clipped
                               let l_gsakend.teltxt     = g_doc_itau[1].segrestelnum clipped
                               let l_gsakend.endnum     = g_doc_itau[1].seglgdnum clipped
                               let l_gsakend.endbrr     = g_doc_itau[1].segbrrnom clipped
                               let l_gsakend.endcid     = g_doc_itau[1].segcidnom clipped
                               let l_gsakend.endufd     = g_doc_itau[1].segufdsgl clipped
                               let l_gsakend.endcep     = l_gsakend.endcep  using "&&&&&"
                               let l_gsakend.endcepcmp  = l_gsakend.endcepcmp using "&&&"
                               let l_gsakend.endcmp     = g_doc_itau[1].segendcmpdes clipped
                        
                        end if
                     end if

                  end if

                  if l_ret = 0 then

                     # Tipo de Lougradouro
                     call cty22g02_retira_acentos(l_gsakend.endlgdtip)
                                                     returning d_cts06g11.lgdtip
                     let d_cts06g11.lgdtip = upshift(d_cts06g11.lgdtip)
                     let d_cts06g11.dddcod    = l_gsakend.dddcod
                     let d_cts06g11.lcltelnum = l_gsakend.teltxt


                     # Lougradouro
                     call cty22g02_retira_acentos(l_gsakend.endlgd)
                          returning d_cts06g11.lgdnom
                     let d_cts06g11.lgdnom = upshift(d_cts06g11.lgdnom)


                     let d_cts06g11.lgdnum    = l_gsakend.endnum


                     # Bairro
                     call cty22g02_retira_acentos(l_gsakend.endbrr)
                          returning d_cts06g11.brrnom
                     let d_cts06g11.brrnom = upshift(d_cts06g11.brrnom)

                     # Cidade
                     call cty22g02_retira_acentos(l_gsakend.endcid)
                          returning d_cts06g11.cidnom
                     let d_cts06g11.cidnom = upshift(d_cts06g11.cidnom)

                     let d_cts06g11.ufdcod    = l_gsakend.endufd
                     let d_cts06g11.lgdcep    = l_gsakend.endcep
                     let d_cts06g11.lgdcepcmp = l_gsakend.endcepcmp
                     let d_cts06g11.endcmp    = l_gsakend.endcmp
                  end if
              end if
          else

           if param.c24endtip = 1 then

              if g_documento.c24astcod = 'M15' or
                 g_documento.c24astcod = 'M20' or
                 g_documento.c24astcod = 'M23' or
                 g_documento.c24astcod = 'M33' or
                 g_documento.c24astcod = 'KM1' or    
                 g_documento.c24astcod = 'KM2' or    
                 g_documento.c24astcod = 'KM3' then 
                 

                 initialize d_cts06g11.cidnom
                           ,d_cts06g11.brrnom
                           ,d_cts06g11.lclbrrnom
                           ,d_cts06g11.endzon
                           ,d_cts06g11.lgdtip
                           ,d_cts06g11.lgdnom
                           ,d_cts06g11.lgdnum
                           ,d_cts06g11.lgdcep
                           ,d_cts06g11.lgdcepcmp
                           ,d_cts06g11.lclltt
                           ,d_cts06g11.lcllgt
                           ,d_cts06g11.lclrefptotxt
                           ,d_cts06g11.lclcttnom
                           ,d_cts06g11.dddcod
                           ,d_cts06g11.lcltelnum
                           ,d_cts06g11.c24lclpdrcod
                           ,d_cts06g11.ofnnumdig
                           ,d_cts06g11.celteldddcod
                           ,d_cts06g11.celtelnum
                           ,d_cts06g11.endcmp
                 to null

              #else
              #
              #     initialize d_cts06g11.* to null

              end if

           end if

          end if

          let salva.cidnom     =  d_cts06g11.cidnom #ligia 09/10/07
          let salva.ufdcod     =  d_cts06g11.ufdcod
          let salva.lgdtip     =  d_cts06g11.lgdtip
          let salva.lgdnom     =  d_cts06g11.lgdnom
          let salva.lgdnum     =  d_cts06g11.lgdnum
          let salva.brrnom     =  d_cts06g11.brrnom
          let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
          let salva.lclltt     =  d_cts06g11.lclltt
          let salva.lcllgt     =  d_cts06g11.lcllgt
          let salva.endcmp     =  d_cts06g11.endcmp
       end if
    end if
 end if

 # SM-PSI-2014-02085 - Verifica horario de bloqueio de msg - Robson D.(Inexsoft) - Inicio -
 if not cts06g11_verif_bloq() then
    #Inicio - Situação local de ocorrência
    if param.c24endtip = 1 and #Verifica tipo do endereço = ocorrência
       l_flag_auto = 'S' then  #Verifica se o serviço é auto
      if g_documento.lclocodesres = "N" OR g_documento.lclocodesres = "" OR
         g_documento.lclocodesres is null then

          let ws.txtocrlcl = 'Local de risco:'
          display ws.txtocrlcl to txtocrlcl

          let ws.ocrlclstt = ''
          let ws.ptoref1   = ''

          #Verifica se é uma INCLUSÃO ou ALTERAÇÃO
          if g_documento.atdsrvnum is null OR
             g_documento.atdsrvnum = "" then #Novo laudo

              call cts08g01_respostaobrigatoria("A","S"
                                   ," O VEICULO ESTA EM UM LOCAL SEGURO?"
                                   ,"Ex: Em um estacionamento ou garagem do"
                                   ,"trabalho, shopping, mercado, hotel, "
                                   ,"outra residência, posto de gasolina, etc.")
                         returning ws.ocrlclstt

              #Verifica retorno
              if ws.ocrlclstt = 'S' then
                  let ws.ocrlclstt = 'N' #Veiculo NÃO está em local de risco
                  ### SM-PSI-2014-02085 - Retirar a atribuição do valor.
                  ### let ws.ptoref1 = 'EM LOCAL SEGURO'
                  let ws.ptoref1 = ''
              else
                 if ws.ocrlclstt = 'N' then
                    let ws.ocrlclstt = 'S' #Veiculo está em local de risco
                    #let ws.ptoref1 = 'PRIORIZAR ATENDIMENTO'
                 else
                    error "Situação do local de ocorrência não foi informada"
                    let ws.ocrlclstt = ''
                    #let ws.ptoref1 = ''
                 end if
              end if

              open  c_cts06g11_011 using ws.ocrlclstt
              fetch c_cts06g11_011  into lr_emeviacod.emeviacod
          else #Alteração de laudo
            if lr_emeviacod.emeviacod = 1 then #Em local de risco
              let ws.ocrlclstt = 'S'
              #let ws.ptoref1 = 'PRIORIZAR ATENDIMENTO'
            else
              let ws.ocrlclstt = 'N'
              ### SM-PSI-2014-02085 - Retirar a atribuição do valor.
              ### let ws.ptoref1 = 'EM LOCAL SEGURO'
              let ws.ptoref1 = ''
           end if
          end if
          display by name ws.ocrlclstt
          display by name ws.ptoref1
      end if
    end if
    #Fim - Situação local de ocorrência
    ### PSI 192007 JUNIOR(META) - Fim
 end if
 #Fim - SM-PSI-2014-02085 - Robson D.

 let ws.benef = null
 let ws.ofnnumdig = null

 if g_documento.ciaempcod = 1  or   ## Empresa Porto
    g_documento.ciaempcod = 50 then ## Empresa Porto Saude
    call fbenefic(g_documento.succod,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig,
                  g_documento.edsnumref)
         returning ws.benef, ws.ofnnumdig

 end if

 if param.atdsrvorg =  3   then
    message " (F17)Abandona (F5)Espelho  "
 else
    if param.c24endtip <> 2 or
       g_documento.ciaempcod = 35  then # Azul Seguros - Ruiz
       if param.atdsrvorg =  10 then   # vistoria previa
          message " (F17)Abandona (F6)Historico (F3)Preenc."
       else
          message " (F17)Abandona (F3)Preenc (F4)Patio (F5)Espelho (F6)Historico "
       end if
    else
       if param.atdsrvorg =  4   and
          ws.locflg    = "N"  and
          g_documento.ciaempcod <> 84 then

          if ws.benefx  = "S"  then
             
             if not cty31g00_valida_atd_premium() then
                 call cts08g01("A","N",""     #OSF 19968
                              ," VEICULO TEM DIREITO AO BENEFICIO."
                              ," CONSULTE O CADASTRO DE OFICINAS"
                              ,"REFERENCIADAS.PRESSIONE(F9).")
                 returning ws.confirma
             end if
             
             message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist,",
                     "(F7)Revendas,(F8)Oficinas,(F9)Ofic.Ref."
             if g_documento.ramcod = 16  or
                g_documento.ramcod = 524 or
                ws.clscod          = "096"  then
                message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist,",
                        "(F7)Revendas,(F8)Ofic_Garantia_Mec,(F9)Ofic.Ref."
             end if
          else
             if g_documento.succod is null    and
                g_documento.aplnumdig is null then
                call cts08g01("A","N",""     #OSF 19968
                            ," VERIFIQUE SE O VEICULO TEM DIREITO"
                            ," AO BENEFICIO.","")
                    returning ws.confirma   #by aguinaldo
                message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist.,",
                        "(F8)Oficinas,(F9)Ofic.Ref."
             else
                call cts08g01("A","N",""     #OSF 19968
                            ," VEICULO NAO TEM DIREITO AO BENEFICIO."
                            ," CONSULTE O CADASTRO DE OFICINAS."
                            ,"PRESSIONE(F8).")
                    returning ws.confirma
                message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist.,",
                        "(F8)Oficinas,(F9)Ofic. Ref."
                if g_documento.ramcod = 16  or
                   g_documento.ramcod = 524 or
                   ws.clscod          = "096" then
                   message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist.,",
                           "(F8)Ofic_Garantia_Mec,(F9)Referenciadas"
                end if
             end if
          end if
       else
         if g_documento.ciaempcod = 84 then
            if param.atdsrvorg = 4 then
               message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Historico,(F8)Oficinas"
            else
               message "(F17)Abandona,(F5)Espelho,(F6)Historico"
            end if
         else
           message " (F17)Abandona,(F5)Espelho,(F6)Historico,(F8)Oficinas"
           if g_documento.ramcod = 16  or
              g_documento.ramcod = 524 or
              ws.clscod          = "096" then
              message "(F17)Abandona,(F5)Espelho,(F6)Historico,",
                     "(F8)Oficinas_Garantia_Mecanica"
           end if
         end if
       end if
    end if
 end if
 let int_flag = false

 let ws.ptoref1 = d_cts06g11.lclrefptotxt[1,50]
 let ws.ptoref2 = d_cts06g11.lclrefptotxt[51,100]
 let ws.ptoref3 = d_cts06g11.lclrefptotxt[101,150]
 let ws.ptoref4 = d_cts06g11.lclrefptotxt[151,200]
 let m_lclrefptotxt = d_cts06g11.lclrefptotxt

 if d_cts06g11.ofnnumdig is not null and
    param.c24endtip  =  2            then  # destino
    if ws.benef = "S"  then
       if ws.ofnnumdig = d_cts06g11.ofnnumdig then
          let d1_cts06g11.obsofic = "* Oficina Beneficio *"
       else
          let d1_cts06g11.obsofic = "* Cadastro Beneficio *"
       end if
    end if
    display by name d1_cts06g11.obsofic
    select ofnstt
      into ws.ofnstt
      from sgokofi
     where ofnnumdig = d_cts06g11.ofnnumdig
     if ws.ofnstt = "C" then
        let d1_cts06g11.staofic  =  "OBSERVACAO"
     end if
     display by name d1_cts06g11.staofic attribute (reverse)
 end if

 initialize lr_salva to null

 let lr_salva.lgdcep     = d_cts06g11.lgdcep
 let lr_salva.lgdcepcmp  = d_cts06g11.lgdcepcmp
 let lr_salva.lclidttxt  = d_cts06g11.lclidttxt

# Inicio - Situação local de ocorrência
{
#Consistir o departamento para entrar ou nao com a via emergencial.
if (g_documento.c24astcod = 'M15' or
   g_documento.c24astcod = 'M20' or
   g_documento.c24astcod = 'M23' or
   g_documento.c24astcod = 'M33') then
   		let ws.decide_via = "N"
else
		 call ctc17m02_consiste_depto_via(g_issk.dptsgl)
		    returning l_resultado
		             ,l_mensagem

		 if l_resultado = 1 then
		    if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
		        param.atdsrvorg = 4 or param.atdsrvorg = 6) and param.c24endtip = 1 then

		       let l_via_desc = 'Via Emerg...:'
		       display l_via_desc to via

		       let ws.decide_via = "N"
		       if lr_emeviacod.emeviacod is not null then
		          let ws.decide_via = "S"
		       end if

		       display by name ws.decide_via

		       display '-' to espaco1
		       display by name lr_emeviacod.emeviacod
		    else
		       let l_resultado = 2
		    end if
		 else
		   if l_resultado = 3 then
		      error l_mensagem sleep 2
		      call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
		      return d_cts06g11.*, ws.retflg, hist_cts06g11.*,lr_emeviacod.emeviacod
		   end if
		 end if

		#Obter a descricao da via emergencial
		 if l_resultado = 1 or #tem via para o departamento
		    lr_emeviacod.emeviacod is not null then
		    call ctc17m02_obter_via(lr_emeviacod.emeviacod,g_issk.dptsgl)
		        returning l_resultado
		                 ,l_mensagem
		                 ,lr_ctc17m02.emeviades
		                 ,lr_ctc17m02.emeviapri

		    if l_resultado = 3 then
		       error l_mensagem sleep 2
		       call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
		       return d_cts06g11.*, ws.retflg, hist_cts06g11.*,lr_emeviacod.emeviacod
		    else
		       if l_resultado = 2 and lr_emeviacod.emeviacod is null then
		          let l_resultado  = 1
		       end if

		       display by name lr_emeviacod.emeviacod
		       display by name lr_ctc17m02.emeviades
		    end if
		 end if
end if
}
# Fim - Situação local de ocorrência

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].brrnom = d_cts06g11.brrnom

 call cts06g10_monta_brr_subbrr(d_cts06g11.brrnom,
                                d_cts06g11.lclbrrnom)
      returning d_cts06g11.brrnom

 let l_oriprc = false



 # PSI-2014-11756/EV - Nao duplicar concatenacao de brrnom
 if m_brrnomidx is not null
   then
   let d_cts06g11.brrnom = m_brrnomidx
 end if

 input by name d_cts06g11.lgdcep,
               d_cts06g11.lgdcepcmp,
               d_cts06g11.lclidttxt,
               d_cts06g11.cidnom,
               d_cts06g11.ufdcod,
               d_cts06g11.lgdtip,
               d_cts06g11.lgdnom,
               d_cts06g11.lgdnum,
               d_cts06g11.brrnom,
               d_cts06g11.endzon,
#              ws.decide_via, #Situação local de ocorrência
               ws.ocrlclstt, #Situação local de ocorrência
               d_cts06g11.endcmp,
               ws.ptoref1,
               ws.ptoref2,
               ws.ptoref3,
               ws.ptoref4,
               d_cts06g11.lclcttnom,
               d_cts06g11.celteldddcod,
               d_cts06g11.celtelnum,
               d_cts06g11.dddcod,
               d_cts06g11.lcltelnum without defaults

   before input
   	   if g_documento.ciaempcod = 1 and
   	   	 (g_documento.ramcod = 31   or
        	g_documento.ramcod = 531) then
          #--------------------------------------------------------
          # Recupera Codigo do Segurado
          #--------------------------------------------------------
          call cty05g00_segnumdig(g_documento.succod    ,
                                  g_documento.aplnumdig ,
                                  g_documento.itmnumdig ,
                                  g_funapol.dctnumseq   ,
                                  g_documento.prporg    ,
                                  g_documento.prpnumdig )
          returning l_resultado,
                    l_mensagem ,
                    l_segnumdig_idx
       end if

       if d_cts06g11.lgdnum is not null and
          d_cts06g11.lgdnum <> " "      then
          if d_cts06g11.lclltt is not null  and
             d_cts06g11.lcllgt is not null  then
             let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
             let d_cts06g11.c24lclpdrcod = 3
             display by name ws.latlontxt
             next field ocrlclstt
          end if

          if cts52m00_acessa_endereco_itau(g_documento.ciaempcod   ,
          	                               g_doc_itau[1].itaciacod ,
          	                               g_doc_itau[1].itaramcod ,
          	                               g_doc_itau[1].itaaplnum ,
                                           g_doc_itau[1].aplseqnum ) or
             cts55m00_acessa_endereco_itau(g_documento.ciaempcod   ,
          	                               g_doc_itau[1].itaciacod ,
          	                               g_doc_itau[1].itaramcod ,
          	                               g_doc_itau[1].itaaplnum ,
                                           g_doc_itau[1].aplseqnum ) or
          	 cts53m00_acessa_endereco_azul(g_documento.ciaempcod   ,
          	                               g_indexado.azlaplcod    ) or
          	 cts56m00_acessa_endereco_porto_auto(l_segnumdig_idx   ) or
          	 cts56m00_acessa_endereco_porto_re(g_rsc_re.lclrsccod  ,
          	                                   d_cts06g11.lclltt   ,
          	                                   d_cts06g11.lcllgt   ) then

          	 if g_documento.ciaempcod = 84 then

          	      call cts52m00_recupera_endereco_itau (g_doc_itau[1].itaciacod ,
          	                                            g_doc_itau[1].itaramcod ,
          	                                            g_doc_itau[1].itaaplnum ,
          	                                            g_doc_itau[1].aplseqnum )
                  returning lr_ctx25g05_pes.lclltt      ,
                            lr_ctx25g05_pes.lcllgt      ,
                            lr_ctx25g05_pes.lgdtip      ,
                            lr_ctx25g05_pes.lgdnom      ,
                            lr_ctx25g05_pes.brrnom      ,
                            lr_ctx25g05_pes.lclbrrnom   ,
                            lr_ctx25g05_pes.lgdcep      ,
                            lr_ctx25g05_pes.c24lclpdrcod
             else
             	  if g_documento.ciaempcod   = 84 and
          	 	     g_doc_itau[1].itaramcod = 14 then
          	      call cts55m00_recupera_endereco_itau (g_doc_itau[1].itaciacod ,
          	                                            g_doc_itau[1].itaramcod ,
          	                                            g_doc_itau[1].itaaplnum ,
          	                                            g_doc_itau[1].aplseqnum )
                  returning lr_ctx25g05_pes.lclltt      ,
                            lr_ctx25g05_pes.lcllgt      ,
                            lr_ctx25g05_pes.lgdtip      ,
                            lr_ctx25g05_pes.lgdnom      ,
                            lr_ctx25g05_pes.brrnom      ,
                            lr_ctx25g05_pes.lclbrrnom   ,
                            lr_ctx25g05_pes.lgdcep      ,
                            lr_ctx25g05_pes.c24lclpdrcod
                else

              	  call cts53m00_recupera_endereco_azul (g_indexado.azlaplcod)
                  returning lr_ctx25g05_pes.lclltt      ,
                            lr_ctx25g05_pes.lcllgt      ,
                            lr_ctx25g05_pes.lgdtip      ,
                            lr_ctx25g05_pes.lgdnom      ,
                            lr_ctx25g05_pes.brrnom      ,
                            lr_ctx25g05_pes.lclbrrnom   ,
                            lr_ctx25g05_pes.lgdcep      ,
                            lr_ctx25g05_pes.c24lclpdrcod

                end if
             end if

             if g_documento.ciaempcod <> 1 then
                let m_brrnomidx = lr_ctx25g05_pes.brrnom

                if lr_ctx25g05_pes.c24lclpdrcod = 3   and
                   lr_ctx25g05_pes.lclltt is not null and
                   lr_ctx25g05_pes.lcllgt is not null and
                   lr_ctx25g05_pes.lclltt <> 0        and
                   lr_ctx25g05_pes.lcllgt <> 0        then # -> INDEXOU AUTOMATICO

                    {if  (d_cts06g11.lgdnom = lr_ctx25g05_pes.lgdnom) then  }

                       if (l_c24endtip <> 2) or
                          (cts02m07_retorna_cappstcod() is null) or
                          (cts02m07_retorna_cappstcod() = 0) then
                       let d_cts06g11.lclltt       = lr_ctx25g05_pes.lclltt
                       let d_cts06g11.lcllgt       = lr_ctx25g05_pes.lcllgt
                       let d_cts06g11.lgdtip       = lr_ctx25g05_pes.lgdtip
                       let d_cts06g11.lgdnom       = lr_ctx25g05_pes.lgdnom
                       let d_cts06g11.brrnom       = lr_ctx25g05_pes.brrnom
                       let d_cts06g11.lclbrrnom    = lr_ctx25g05_pes.lclbrrnom
                       let d_cts06g11.lgdcep       = null
                       let d_cts06g11.lgdcepcmp    = null
                       let d_cts06g11.c24lclpdrcod = lr_ctx25g05_pes.c24lclpdrcod
                       end if
                       # PSI 244589 - Inclusão de Sub-Bairro - Burini
                       let m_subbairro[1].brrnom = d_cts06g11.brrnom

                       call cts06g10_monta_brr_subbrr(d_cts06g11.brrnom,
                                                      d_cts06g11.lclbrrnom)
                            returning d_cts06g11.brrnom


                       display by name d_cts06g11.endcmp
                       display by name d_cts06g11.cidnom
                       display by name d_cts06g11.ufdcod
                       display by name d_cts06g11.lgdtip
                       display by name d_cts06g11.lgdnom
                       display by name d_cts06g11.lgdnum
                       display by name d_cts06g11.brrnom
                       display by name d_cts06g11.lclbrrnom
                       display by name d_cts06g11.lclltt
                       display by name d_cts06g11.lcllgt



                       let salva.cidnom     =  d_cts06g11.cidnom
                       let salva.ufdcod     =  d_cts06g11.ufdcod
                       let salva.lgdtip     =  d_cts06g11.lgdtip
                       let salva.lgdnom     =  d_cts06g11.lgdnom
                       let salva.lgdnum     =  d_cts06g11.lgdnum
                       let salva.endcmp     =  d_cts06g11.endcmp
                       let salva.brrnom     =  d_cts06g11.brrnom
                       let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
                       let salva.lclltt     =  d_cts06g11.lclltt
                       let salva.lcllgt     =  d_cts06g11.lcllgt


                       if d_cts06g11.c24lclpdrcod is null  then
                          error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
                          next field lgdnom
                       end if
                       if d_cts06g11.c24lclpdrcod <> 01  and   ### Fora de padrao
                          d_cts06g11.c24lclpdrcod <> 02  and   ### Padrao Guia Postal
                          d_cts06g11.c24lclpdrcod <> 03  and   ### Padrao Mapas Rua
                          d_cts06g11.c24lclpdrcod <> 04  and   ### Padrao Mapas Bairro
                          d_cts06g11.c24lclpdrcod <> 05  then  ### Padrao Mapas Sub-Bairro
                          error " Codigo de padronizacao invalido! AVISE A INFORMATICA!"
                          next field lgdtip
                       end if

                       display by name d_cts06g11.lgdcep thru d_cts06g11.lcltelnum
                       display by name d_cts06g11.brrnom
                       display by name d_cts06g11.celteldddcod
                       display by name d_cts06g11.celtelnum

                       if d_cts06g11.lclltt != 0      and
                          d_cts06g11.lcllgt != 0      and
                        	d_cts06g11.c24lclpdrcod = 3 then
                          let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                          display by name ws.latlontxt
                          next field ocrlclstt
                       end if
                end if
           else
           	  if g_documento.ramcod = 31  or
           	  	 g_documento.ramcod = 531 then
           	     call cts56m00_recupera_latlong_porto_auto(l_segnumdig_idx)
           	     returning d_cts06g11.lclltt,
           	               d_cts06g11.lcllgt
           	  end if
           	  let d_cts06g11.c24lclpdrcod = 3
           	  display by name d_cts06g11.endcmp
           	  display by name d_cts06g11.cidnom
           	  display by name d_cts06g11.ufdcod
           	  display by name d_cts06g11.lgdtip
           	  display by name d_cts06g11.lgdnom
           	  display by name d_cts06g11.lgdnum
           	  display by name d_cts06g11.brrnom
           	  display by name d_cts06g11.lclbrrnom
           	  display by name d_cts06g11.lclltt
           	  display by name d_cts06g11.lcllgt
           	  display by name d_cts06g11.lgdcep thru d_cts06g11.lcltelnum
           	  display by name d_cts06g11.brrnom
           	  display by name d_cts06g11.celteldddcod
           	  display by name d_cts06g11.celtelnum
           	  let salva.cidnom     =  d_cts06g11.cidnom
           	  let salva.ufdcod     =  d_cts06g11.ufdcod
           	  let salva.lgdtip     =  d_cts06g11.lgdtip
           	  let salva.lgdnom     =  d_cts06g11.lgdnom
           	  let salva.lgdnum     =  d_cts06g11.lgdnum
           	  let salva.endcmp     =  d_cts06g11.endcmp
           	  let salva.brrnom     =  d_cts06g11.brrnom
           	  let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
           	  let salva.lclltt     =  d_cts06g11.lclltt
           	  let salva.lcllgt     =  d_cts06g11.lcllgt
           	  if d_cts06g11.lclltt != 0      and
           	     d_cts06g11.lcllgt != 0      then
           	     let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
           	     display by name ws.latlontxt
           	     next field ocrlclstt
           	  end if
           end if

          else
           # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
           if ctx25g05_rota_ativa() then

              initialize lr_ctx25g05_pes.* to null
              call ctx25g05_pesq_auto_cep(d_cts06g11.lgdtip,
                                          d_cts06g11.lgdnom,
                                          d_cts06g11.lgdnum,
                                          m_subbairro[1].brrnom,
                                          d_cts06g11.lclbrrnom,
                                          d_cts06g11.ufdcod,
                                          d_cts06g11.cidnom,
                                          d_cts06g11.lgdcep,
                                          d_cts06g11.lgdcepcmp)
                           returning lr_ctx25g05_pes.ret         ,
                                     lr_ctx25g05_pes.lclltt      ,
                                     lr_ctx25g05_pes.lcllgt      ,
                                     lr_ctx25g05_pes.lgdtip      ,
                                     lr_ctx25g05_pes.lgdnom      ,
                                     lr_ctx25g05_pes.brrnom      ,
                                     lr_ctx25g05_pes.lclbrrnom   ,
                                     lr_ctx25g05_pes.lgdcep      ,
                                     lr_ctx25g05_pes.c24lclpdrcod

              let m_brrnomidx = lr_ctx25g05_pes.brrnom

              if lr_ctx25g05_pes.ret <> 0 then
                 error "Erro ao chamar a funcao ctx25g05_pesq_auto() " sleep 2
              end if

              if lr_ctx25g05_pes.c24lclpdrcod = 3   and
                 lr_ctx25g05_pes.lclltt is not null and
                 lr_ctx25g05_pes.lcllgt is not null and
                 lr_ctx25g05_pes.lclltt <> 0        and
                 lr_ctx25g05_pes.lcllgt <> 0        then # -> INDEXOU AUTOMATICO
                  if  (d_cts06g11.lgdnom = lr_ctx25g05_pes.lgdnom) then

                     let d_cts06g11.lclltt       = lr_ctx25g05_pes.lclltt
                     let d_cts06g11.lcllgt       = lr_ctx25g05_pes.lcllgt
                     let d_cts06g11.lgdtip       = lr_ctx25g05_pes.lgdtip
                     let d_cts06g11.lgdnom       = lr_ctx25g05_pes.lgdnom
                     let d_cts06g11.brrnom       = lr_ctx25g05_pes.brrnom
                     let d_cts06g11.lclbrrnom    = lr_ctx25g05_pes.lclbrrnom
                     let d_cts06g11.lgdcep       = null
                     let d_cts06g11.lgdcepcmp    = null
                     let d_cts06g11.c24lclpdrcod = lr_ctx25g05_pes.c24lclpdrcod

                     # PSI 244589 - Inclusão de Sub-Bairro - Burini
                     let m_subbairro[1].brrnom = d_cts06g11.brrnom

                     call cts06g10_monta_brr_subbrr(lr_ctx25g05_pes.brrnom,
                                                    lr_ctx25g05_pes.lclbrrnom)
                          returning d_cts06g11.brrnom

                     #let ws.compleme = d_cts06g11.endcmp
                     display by name d_cts06g11.endcmp

                     let salva.cidnom     =  d_cts06g11.cidnom
                     let salva.ufdcod     =  d_cts06g11.ufdcod
                     let salva.lgdtip     =  d_cts06g11.lgdtip
                     let salva.lgdnom     =  d_cts06g11.lgdnom
                     let salva.lgdnum     =  d_cts06g11.lgdnum
                     let salva.endcmp     =  d_cts06g11.endcmp
                     let salva.brrnom     =  d_cts06g11.brrnom
                     let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
                     let salva.lclltt     =  d_cts06g11.lclltt
                     let salva.lcllgt     =  d_cts06g11.lcllgt

                     if d_cts06g11.c24lclpdrcod is null  then
                        error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
                        next field lgdnom
                     end if
                     if d_cts06g11.c24lclpdrcod <> 01  and   ### Fora de padrao
                        d_cts06g11.c24lclpdrcod <> 02  and   ### Padrao Guia Postal
                        d_cts06g11.c24lclpdrcod <> 03  and   ### Padrao Mapas Rua
                        d_cts06g11.c24lclpdrcod <> 04  and   ### Padrao Mapas Bairro
                        d_cts06g11.c24lclpdrcod <> 05  then  ### Padrao Mapas Sub-Bairro
                        error " Codigo de padronizacao invalido! AVISE A INFORMATICA!"
                        next field lgdtip
                     end if

                 display by name d_cts06g11.lgdcep thru d_cts06g11.lcltelnum
                 display by name d_cts06g11.lgdtip
                 display by name d_cts06g11.lgdnom
                 display by name d_cts06g11.brrnom
                 display by name d_cts06g11.celteldddcod
                 display by name d_cts06g11.celtelnum

                 if d_cts06g11.lclltt != 0      and
                    d_cts06g11.lcllgt != 0      and
                  	d_cts06g11.c24lclpdrcod = 3 then
                    let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                    display by name ws.latlontxt
                    next field ocrlclstt
                 end if

                 end if
              end if
           end if
         end if
           if param.c24endtip = 1 then
              let g_indexado.endnum1 = d_cts06g11.lgdnum
              let g_indexado.endcid1 = d_cts06g11.cidnom
           end if
       end if

   before field lgdcep
          let ws.cepflg = "0"
          if param.atdsrvorg   = 16   and  # sinistro transportes
             d_cts06g11.ufdcod = "EX" then # sinistro fora do Brasil
             let d_cts06g11.c24lclpdrcod = 01  # FORA DO PADRAO
             next field cidnom
          end if
          if (param.atdsrvorg = 1 or
              param.atdsrvorg = 2 or    # Mercosul
              param.atdsrvorg = 4) and
		          d_cts06g11.ufdcod = "EX" then
		          let d_cts06g11.c24lclpdrcod = 01
		          next field cidnom
		    end if
          display by name d_cts06g11.lgdcep attribute (reverse)

   after  field lgdcep
          display by name d_cts06g11.lgdcep

          if d_cts06g11.lgdcep is null then
             if ws.benefx = "S"     and
                param.c24endtip = 2 then
                call cts08g01("A","S",""     #OSF 19968
                             ,"CONFIRMA O PREENCHIMENTO MANUAL"
                             ,"SEM A CONSULTA DO CADASTRO DE  "
                             ,"OFICINAS?")
                     returning ws.confirma
                if ws.confirma = "N" then
                   next field lgdcep
                end if
             end if

             initialize d_cts06g11.lgdcepcmp  to null
             display by name d_cts06g11.lgdcepcmp
             next field lclidttxt
          end if

   before field lgdcepcmp
          display by name d_cts06g11.lgdcepcmp attribute (reverse)

   after  field lgdcepcmp
          display by name d_cts06g11.lgdcepcmp

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lgdcep
          end if
          if d_cts06g11.lgdcepcmp is null then
             initialize d_cts06g11.lgdcep  to null
             display by name d_cts06g11.lgdcep
          end if
          if d_cts06g11.lgdcep    is not null   and
             d_cts06g11.lgdcepcmp is not null   then
             open  c_cts06g11_001  using  d_cts06g11.lgdcep,
                                     d_cts06g11.lgdcepcmp
             fetch c_cts06g11_001  into   d_cts06g11.lgdtip,
                                     d_cts06g11.lgdnom,
                                     ws.cidcod,
                                     ws.brrcod
             if sqlca.sqlcode  =  100   then
                error " Cep nao cadastrado!"
                next field lgdcep
             end if
             close c_cts06g11_001

             call cts06g06(d_cts06g11.lgdnom)  returning d_cts06g11.lgdnom

             open  c_cts06g11_002  using  ws.cidcod
             fetch c_cts06g11_002  into   d_cts06g11.cidnom,
                                     d_cts06g11.ufdcod
             close c_cts06g11_002
             open  c_cts06g11_003  using  ws.cidcod, ws.brrcod
             fetch c_cts06g11_003  into   d_cts06g11.brrnom
             close c_cts06g11_003

             display by name d_cts06g11.lgdtip, d_cts06g11.lgdnom
             display by name d_cts06g11.cidnom, d_cts06g11.ufdcod
             display by name d_cts06g11.brrnom

             let d_cts06g11.c24lclpdrcod = 02  # PADRAO GUIA POSTAL
             let ws.cepflg = "1"

# Inicio - Situação local de ocorrência
{
             # Priscila 24/01/2006 - Buscar via emergencial de acordo com o
             # tipo de logradouro retornado pela funcao
             if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
                 param.atdsrvorg = 4 or param.atdsrvorg = 6) and
                 param.c24endtip = 1 then
                 call ctc17m02_obter_emeviacod(d_cts06g11.lgdtip, g_issk.dptsgl)
                      returning l_resultado
                               ,l_mensagem
                               ,lr_emeviacod.emeviacod

                 if l_resultado = 1 then
                    #encontrou esse tipo de logradouro como via emergencial
                    # para o departamento
                    let ws.decide_via = 'S'
                    let lr_ctc17m02.emeviades = d_cts06g11.lgdtip

                 else
                    let ws.decide_via = 'N'
                    let lr_emeviacod.emeviacod = null
                    let lr_ctc17m02.emeviades = null
                 end if
                 display by name ws.decide_via
                 display by name lr_emeviacod.emeviacod
                 display by name lr_ctc17m02.emeviades
             end if
}
             let lr_salva.emeviacod = lr_emeviacod.emeviacod
# Fim - Situação local de ocorrência

          end if

   before field lclidttxt
          display by name d_cts06g11.lgdcep thru d_cts06g11.lcltelnum
          display by name d_cts06g11.celteldddcod
          display by name d_cts06g11.celtelnum

          if param.c24endtip = 1  and
             param.atdsrvorg <>  5   and
             param.atdsrvorg <>  7   and
             param.atdsrvorg <> 17   then
             if ws.cepflg = "1" then
                next field lgdnum
             end if
          end if

          display by name d_cts06g11.lclidttxt   attribute (reverse)

   after  field lclidttxt
          display by name d_cts06g11.lclidttxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts06g11.lgdcepcmp is not null then
                next field lgdcepcmp
             else
                next field lgdcep
             end if
          end if

          let l_flag_local_especial = "N"

          # --Inicio CT 322083

          if param.atdsrvorg <> 10 then
             # --Inicio CT 318779

             let ws.c24astcod = g_documento.c24astcod

             if g_documento.atdsrvnum is not null then
                open c_cts06g11_004 using g_documento.atdsrvnum,
                                        g_documento.atdsrvano,
                                        g_documento.atdsrvnum,
                                        g_documento.atdsrvano
                whenever error continue
                fetch c_cts06g11_004 into ws.c24astcod
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = notfound then
                      error "Assunto relacionado a ligacao, nao encontrado !"
                   else
                      error "Erro de acesso ao banco de dados: ", sqlca.sqlcode, " /Cursor: ccts06g11002"
                   end if
                   next field lclidttxt
                end if
             end if

             # --Final CT 318779

             if ws.c24astcod <> "RPT" and
                ws.c24astcod <> "T11" then

                if (d_cts06g11.lclidttxt <> ""       or
                    d_cts06g11.lclidttxt is not null) and
                    d_cts06g11.lgdcep    is null      then
                    let l_flag_local_especial = "S"
                end if

              if g_documento.c24astcod <> 'M15' and
			           g_documento.c24astcod <> 'M20' and
			           g_documento.c24astcod <> 'M23' and
			           g_documento.c24astcod <> 'M33' and
                 g_documento.c24astcod <> 'KM1' and    			           
                 g_documento.c24astcod <> 'KM2' and    			           
                 g_documento.c24astcod <> 'KM3' then 			           
                if l_flag_local_especial = "S" then

                   initialize lr_ctc71m01_ret to null
                   initialize ws.latlontxt    to null

                   call ctc71m01(d_cts06g11.lclidttxt,"A","","")
                        returning lr_ctc71m01_ret.c24fxolclcod,
                                   lr_ctc71m01_ret.lclidttxt,
                                   lr_ctc71m01_ret.lgdtip,
                                   lr_ctc71m01_ret.lgdnom,
                                   lr_ctc71m01_ret.compleme,
                                   lr_ctc71m01_ret.lgdnum,
                                   lr_ctc71m01_ret.lgdcep,
                                   lr_ctc71m01_ret.lgdcepcmp,
                                   lr_ctc71m01_ret.brrnom,
                                   lr_ctc71m01_ret.cidnom,
                                   lr_ctc71m01_ret.ufdcod,
                                   lr_ctc71m01_ret.endzon,
                                   lr_ctc71m01_ret.c24lclpdrcod,
                                   lr_ctc71m01_ret.lclltt,
                                   lr_ctc71m01_ret.lcllgt

                   if lr_ctc71m01_ret.lgdnom is not null or
                      lr_ctc71m01_ret.lgdnom <> " " then

                      let l_c24fxolclcod          = lr_ctc71m01_ret.c24fxolclcod
                      let d_cts06g11.lclidttxt    = lr_ctc71m01_ret.lclidttxt
                      let d_cts06g11.lgdtip       = lr_ctc71m01_ret.lgdtip
                      let d_cts06g11.lgdnom       = lr_ctc71m01_ret.lgdnom
                      let d_cts06g11.endcmp       = lr_ctc71m01_ret.compleme
                      let d_cts06g11.lgdnum       = lr_ctc71m01_ret.lgdnum
                      let d_cts06g11.lgdcep       = lr_ctc71m01_ret.lgdcep
                      let d_cts06g11.lgdcepcmp    = lr_ctc71m01_ret.lgdcepcmp
                      let d_cts06g11.brrnom       = lr_ctc71m01_ret.brrnom
                      let d_cts06g11.cidnom       = lr_ctc71m01_ret.cidnom
                      let d_cts06g11.ufdcod       = lr_ctc71m01_ret.ufdcod
                      let d_cts06g11.endzon       = lr_ctc71m01_ret.endzon
                      let d_cts06g11.c24lclpdrcod = lr_ctc71m01_ret.c24lclpdrcod
                      let d_cts06g11.lclltt       = lr_ctc71m01_ret.lclltt
                      let d_cts06g11.lcllgt       = lr_ctc71m01_ret.lcllgt

                      if d_cts06g11.lclltt != 0      and
                      	 d_cts06g11.lcllgt != 0      and
                      	 d_cts06g11.c24lclpdrcod = 3 then
                         let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                         display by name ws.latlontxt
                      end if

                      display by name d_cts06g11.lclidttxt
                      display by name d_cts06g11.lgdtip
                      display by name d_cts06g11.lgdnom
                      display by name d_cts06g11.lgdnum
                      display by name d_cts06g11.lgdcep
                      display by name d_cts06g11.lgdcepcmp
                      display by name d_cts06g11.brrnom
                      display by name d_cts06g11.cidnom
                      display by name d_cts06g11.ufdcod
                      display by name d_cts06g11.endzon
                      display by name d_cts06g11.lclltt
                      display by name d_cts06g11.lcllgt
                      display by name d_cts06g11.endcmp

                   else
                      error "Nenhum local selecionado !"

                      let l_flag_local_especial = "N"

                      let d_cts06g11.lclidttxt  = lr_salva.lclidttxt
                      let d_cts06g11.lgdcep     = lr_salva.lgdcep
                      let d_cts06g11.lgdcepcmp  = lr_salva.lgdcepcmp

                      display by name d_cts06g11.lclidttxt
                      display by name d_cts06g11.lgdcep
                      display by name d_cts06g11.lgdcepcmp

                      next field cidnom
                   end if
                end if
             end if
          end if
          end if
          let ws.cepflg = "0"

   before field cidnom
          display by name d_cts06g11.cidnom attribute (reverse)

          if  lr_cts06g11.cidnom is null then
              let lr_cts06g11.cidnom = " "
          else
              let lr_cts06g11.cidnom = d_cts06g11.cidnom
          end if

          if  lr_cts06g11.ufdcod is null then
              let lr_cts06g11.ufdcod = " "
          else
              let lr_cts06g11.ufdcod = d_cts06g11.ufdcod
          end if

   after  field cidnom
          display by name d_cts06g11.cidnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts06g11.lclidttxt is not null then
                next field lclidttxt
             else
                if d_cts06g11.lgdcepcmp is not null then
                   next field lgdcepcmp
                else
                   next field lgdcep
                end if
             end if
          end if

          if d_cts06g11.cidnom is null or d_cts06g11.cidnom = ' '
             then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

          # PSI-2014-11756 - Identificar UF automaticamente, auxiliar com cidades desconhecidas
          if d_cts06g11.cidnom is not null and d_cts06g11.cidnom != ' '  then
             if d_cts06g11.ufdcod is null or d_cts06g11.ufdcod = " " then
                call cts06g11_id_uf_capital(param.atdsrvorg, d_cts06g11.cidnom)
                     returning l_errcod, d_cts06g11.ufdcod, d_cts06g11.cidnom

                if l_errcod = 0 then
                    display by name d_cts06g11.ufdcod
                    display by name d_cts06g11.cidnom
                    error "UF localizada para a cidade informada"
                    
                   call cts06g11_verifica_cidade(param.atdsrvorg, d_cts06g11.cidnom, d_cts06g11.ufdcod)
                      returning l_vlcodcid.*
                       
                   if ws.cidcod is null then
                      let ws.cidcod = l_vlcodcid.cidcod
                   end if 
                   
                   if ( l_vlcodcid.cidnom is not null or l_vlcodcid.cidnom <> ' ' )
                      and (l_vlcodcid.ufdcod is not null or l_vlcodcid.ufdcod <> ' ' ) then
                          let d_cts06g11.cidnom = l_vlcodcid.cidnom
                          let d_cts06g11.ufdcod = l_vlcodcid.ufdcod
                   end if  
                   
                   if l_vlcodcid.cidcep > 0 then
                      let ws.cidcep = l_vlcodcid.cidcep
                      let ws.cidcepcmp = l_vlcodcid.cidcepcmp                     
                   end if
                     
                   if l_vlcodcid.prcok = 'N' then
                      error " Cidade deve ser informada!"
                      next field cidnom
                   else
                      next field lgdtip
                   end if                   
                else
                   error "UF nao localizada, digite a UF para pesquisa manual"
                   let d_cts06g11.ufdcod = null
                   display by name d_cts06g11.ufdcod
                   next field ufdcod
                end if
             end if
          end if
          # PSI-2014-11756

          if param.atdsrvorg   = 16   and  # sinistro transportes
             d_cts06g11.ufdcod = "EX" then # sinistro fora do Brasil
             next field lgdtip
          end if

          if (param.atdsrvorg = 1 or
              param.atdsrvorg = 2 or       # Mercosul
              param.atdsrvorg = 4) and
              d_cts06g11.ufdcod = "EX" then
              next field lgdtip
          end if

   before field ufdcod
          display by name d_cts06g11.ufdcod attribute (reverse)

   after  field ufdcod
          display by name d_cts06g11.ufdcod

          if d_cts06g11.ufdcod = "DF"  then
             let d_cts06g11.cidnom = "BRASILIA"
             display by name d_cts06g11.cidnom
          end if

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts06g11.ufdcod = "DF"  then
                let d_cts06g11.lgdtip = ""
                display by name d_cts06g11.lgdtip
                next field lgdnom
             end if

             if d_cts06g11.ufdcod is null  then
                error " Sigla da unidade da federacao deve ser informada!"
                next field ufdcod
             end if

             if param.atdsrvorg   = 16   and  # sinistro transportes
                d_cts06g11.ufdcod = "EX" then # sinistro fora do Brasil
                next field lgdtip
             end if

             if (param.atdsrvorg = 1 or
                 param.atdsrvorg = 2 or     # Mercosul
                 param.atdsrvorg = 4) and
                d_cts06g11.ufdcod = "EX" then
                next field lgdtip
             end if

             #--------------------------------------------------------------
             # Verifica se UF esta cadastrada
             #--------------------------------------------------------------
             select ufdcod
               from glakest
              where ufdcod = d_cts06g11.ufdcod

             if sqlca.sqlcode = notfound then
                error " Unidade federativa nao cadastrada!"
                next field ufdcod
             end if

             if d_cts06g11.ufdcod = d_cts06g11.cidnom  then
                select ufdnom
                  into d_cts06g11.cidnom
                  from glakest
                 where ufdcod = d_cts06g11.cidnom

                if sqlca.sqlcode = 0  then
                   display by name d_cts06g11.cidnom
                else
                   let d_cts06g11.cidnom = d_cts06g11.ufdcod
                end if
             end if

             call cts06g11_verifica_cidade(param.atdsrvorg, d_cts06g11.cidnom, d_cts06g11.ufdcod)
                returning l_vlcodcid.* 
                
                if ws.cidcod is null then
                   let ws.cidcod = l_vlcodcid.cidcod
                end if 
                
                if ( l_vlcodcid.cidnom is not null or l_vlcodcid.cidnom <> ' ' )
                   and (l_vlcodcid.ufdcod is not null or l_vlcodcid.ufdcod <> ' ' ) then
                       let d_cts06g11.cidnom = l_vlcodcid.cidnom
                       let d_cts06g11.ufdcod = l_vlcodcid.ufdcod
                end if   
                
                   if l_vlcodcid.cidcep > 0 then
                      let ws.cidcep = l_vlcodcid.cidcep
                      let ws.cidcepcmp = l_vlcodcid.cidcepcmp                     
                   end if
                
             if l_vlcodcid.prcok = 'N' then
                   error " Cidade deve ser informada!"
                   next field cidnom
             end if

             if  lr_cts06g11.cidnom <> d_cts06g11.cidnom or
                 lr_cts06g11.ufdcod <> d_cts06g11.ufdcod then
                 call ctc87m00_orientacao_preenchimento(d_cts06g11.cidnom,
                                                        d_cts06g11.ufdcod)
                 let l_oriprc = true
             end if
          end if

   before field lgdtip
          display by name d_cts06g11.lgdtip attribute (reverse)

          if d_cts06g11.lgdtip is null or d_cts06g11.lgdtip = " " then
             call cta00m06_tipo_logradouro()
                  returning l_tplougr

             if l_tplougr is not null then
                let l_cabec = "Tipo logradouro"

                call ctx14g01_tipo_logradouro(l_cabec, l_tplougr)
                   returning d_cts06g11.lgdtip

                let m_lgdtip = d_cts06g11.lgdtip
             end if
          end if

   after  field lgdtip
          display by name d_cts06g11.lgdtip
          let m_lgdtip = d_cts06g11.lgdtip

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts06g11.lgdtip is null or d_cts06g11.lgdtip = " " then
                error " Tipo do logradouro deve ser informado!"
                next field lgdtip
             end if
          end if

          # PSI-2014-11756 - identificar rodovia e situacao de consulta de rodovia sem a cidade
          if upshift(d_cts06g11.lgdtip) = 'RODOVIA'
             then
                let d1_cts06g11.lblnum = 'KM.........'
                display by name d1_cts06g11.lblnum
             else
                let d1_cts06g11.lblnum = 'Numero.....'
                display by name d1_cts06g11.lblnum
          end if

# Inicio - Situação local de ocorrência
{

          # Priscila 20/01/2006 - Busca via emergencial de acordo com
          # tipo de logradouro informado
          if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
              param.atdsrvorg = 4 or param.atdsrvorg = 6) and
              param.c24endtip = 1 then
              call ctc17m02_obter_emeviacod(d_cts06g11.lgdtip, g_issk.dptsgl)
                   returning l_resultado
                            ,l_mensagem
                            ,lr_emeviacod.emeviacod

              if l_resultado = 1 then
                 #encontrou esse tipo de logradouro como via emergencial para o
                 # departamento
                 let ws.decide_via = 'S'
                 let lr_ctc17m02.emeviades = d_cts06g11.lgdtip

              else
                 let ws.decide_via = 'N'
                 let lr_emeviacod.emeviacod = null
                 let lr_ctc17m02.emeviades = null
              end if
              display by name ws.decide_via
              display by name lr_emeviacod.emeviacod
              display by name lr_ctc17m02.emeviades
          end if
}
          let lr_salva.emeviacod = lr_emeviacod.emeviacod
# Fim - Situação local de ocorrência

          if upshift(d_cts06g11.ufdcod) = 'SP'        and
             upshift(d_cts06g11.cidnom) = 'SAO PAULO' and
             upshift(m_lgdtip)          = 'MARGINAL'  then
                call cta00m06_tipo_marginal()
                returning l_tpmarginal

                if l_tpmarginal is not null then
                   let l_cabec = "Tipo Marginal"

                   call ctx14g01_tipo_marginal(l_cabec, l_tpmarginal)
                      returning d_cts06g11.lgdnom

                      let m_lgdnom = d_cts06g11.lgdnom
                end if
          end if


          if upshift(d_cts06g11.lgdtip) = 'RODOANEL' or
             upshift(d_cts06g11.lgdtip) = 'RODO ANEL'
             then
             let d_cts06g11.lgdnom = 'MARIO COVAS'
             display by name d_cts06g11.lgdnom
             next field lgdnum
          end if

   before field lgdnom
          display by name d_cts06g11.lgdnom attribute (reverse)

          if upshift(m_lgdtip) = 'MARGINAL' then
             call cts06g11_sentido(m_lgdnom
                                  ,m_lgdtip)
             returning l_pontoreferencia

                   let ws.ptoref1 = upshift(l_pontoreferencia[001,050]) clipped
                   let ws.ptoref2 = upshift(l_pontoreferencia[051,100]) clipped
                   let ws.ptoref3 = upshift(l_pontoreferencia[101,150]) clipped
                   let ws.ptoref4 = upshift(l_pontoreferencia[151,200]) clipped

                   let ws.ptoref1 = ws.ptoref1 clipped
                   let ws.ptoref2 = ws.ptoref2 clipped
                   let ws.ptoref3 = ws.ptoref3 clipped
                   let ws.ptoref4 = ws.ptoref4 clipped


                   initialize ws.latlontxt to null

                   if m_lgdtip = 'MARGINAL' then

                      call cts06g11_concatena_local(d_cts06g11.lgdnom)
                           returning d_cts06g11.lgdnom

                      call ctc71m01(d_cts06g11.lgdnom,
                                    "A",
                                    d_cts06g11.cidnom,
                                    d_cts06g11.ufdcod)
                           returning lr_ctc71m01_ret.c24fxolclcod,
                                      lr_ctc71m01_ret.lclidttxt,
                                      lr_ctc71m01_ret.lgdtip,
                                      lr_ctc71m01_ret.lgdnom,
                                      lr_ctc71m01_ret.compleme,
                                      lr_ctc71m01_ret.lgdnum,
                                      lr_ctc71m01_ret.lgdcep,
                                      lr_ctc71m01_ret.lgdcepcmp,
                                      lr_ctc71m01_ret.brrnom,
                                      lr_ctc71m01_ret.cidnom,
                                      lr_ctc71m01_ret.ufdcod,
                                      lr_ctc71m01_ret.endzon,
                                      lr_ctc71m01_ret.c24lclpdrcod,
                                      lr_ctc71m01_ret.lclltt,
                                      lr_ctc71m01_ret.lcllgt

                      if lr_ctc71m01_ret.lgdnom is not null or
                         lr_ctc71m01_ret.lgdnom <> " " then

                         if ( lr_ctc71m01_ret.lclltt is not null or
                              lr_ctc71m01_ret.lclltt <> " " ) and
                            ( lr_ctc71m01_ret.lcllgt is not null or
                              lr_ctc71m01_ret.lcllgt <> " " ) then

                              let l_c24fxolclcod          = lr_ctc71m01_ret.c24fxolclcod
                              let d_cts06g11.lclidttxt    = lr_ctc71m01_ret.lclidttxt
                              let d_cts06g11.lgdtip       = lr_ctc71m01_ret.lgdtip
                              let d_cts06g11.lgdnom       = lr_ctc71m01_ret.lgdnom
                              let d_cts06g11.endcmp       = lr_ctc71m01_ret.compleme
                              let d_cts06g11.lgdnum       = lr_ctc71m01_ret.lgdnum
                              let d_cts06g11.lgdcep       = lr_ctc71m01_ret.lgdcep
                              let d_cts06g11.lgdcepcmp    = lr_ctc71m01_ret.lgdcepcmp
                              let d_cts06g11.brrnom        = lr_ctc71m01_ret.brrnom
                              let d_cts06g11.cidnom       = lr_ctc71m01_ret.cidnom
                              let d_cts06g11.ufdcod       = lr_ctc71m01_ret.ufdcod
                              let d_cts06g11.endzon       = lr_ctc71m01_ret.endzon
                              let d_cts06g11.c24lclpdrcod = lr_ctc71m01_ret.c24lclpdrcod
                              let d_cts06g11.lclltt       = lr_ctc71m01_ret.lclltt
                              let d_cts06g11.lcllgt       = lr_ctc71m01_ret.lcllgt

                              if d_cts06g11.lclltt != 0       and
                              	 d_cts06g11.lcllgt != 0       and
                                 d_cts06g11.c24lclpdrcod = 3 then
                                    let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                                    display by name ws.latlontxt
                              end if

                              display by name d_cts06g11.lclidttxt
                              display by name d_cts06g11.lgdtip
                              display by name d_cts06g11.lgdnom
                              display by name d_cts06g11.lgdnum
                              display by name d_cts06g11.lgdcep
                              display by name d_cts06g11.lgdcepcmp
                              display by name d_cts06g11.brrnom
                              display by name d_cts06g11.cidnom
                              display by name d_cts06g11.ufdcod
                              display by name d_cts06g11.endzon
                              display by name d_cts06g11.lclltt
                              display by name d_cts06g11.lcllgt
                              display by name d_cts06g11.endcmp
                              next field ptoref1
                         else
                            error " Local sem indexação ! "
                         end if
                      end if
                   end if
          end if

   after  field lgdnom
          display by name d_cts06g11.lgdnom

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts06g11.lgdnom is null then
                error " Logradouro deve ser informado!"
                next field lgdnom
             end if
          end if

          initialize ws.latlontxt to null

          if upshift(m_lgdtip) = 'LOCAL FIXO' then

             call ctc71m01(d_cts06g11.lgdnom,
                            "A",
                            d_cts06g11.cidnom,
                            d_cts06g11.ufdcod)
                   returning lr_ctc71m01_ret.c24fxolclcod,
                              lr_ctc71m01_ret.lclidttxt,
                              lr_ctc71m01_ret.lgdtip,
                              lr_ctc71m01_ret.lgdnom,
                              lr_ctc71m01_ret.compleme,
                              lr_ctc71m01_ret.lgdnum,
                              lr_ctc71m01_ret.lgdcep,
                              lr_ctc71m01_ret.lgdcepcmp,
                              lr_ctc71m01_ret.brrnom,
                              lr_ctc71m01_ret.cidnom,
                              lr_ctc71m01_ret.ufdcod,
                              lr_ctc71m01_ret.endzon,
                              lr_ctc71m01_ret.c24lclpdrcod,
                              lr_ctc71m01_ret.lclltt,
                              lr_ctc71m01_ret.lcllgt

             if lr_ctc71m01_ret.lgdnom is not null or
                lr_ctc71m01_ret.lgdnom <> " " then

                if ( lr_ctc71m01_ret.lclltt is not null or
                     lr_ctc71m01_ret.lclltt <> " " ) and
                   ( lr_ctc71m01_ret.lcllgt is not null or
                     lr_ctc71m01_ret.lcllgt <> " " ) then

                     let l_c24fxolclcod          = lr_ctc71m01_ret.c24fxolclcod
                     let d_cts06g11.lclidttxt    = lr_ctc71m01_ret.lclidttxt
                     let d_cts06g11.lgdtip       = lr_ctc71m01_ret.lgdtip
                     let d_cts06g11.lgdnom       = lr_ctc71m01_ret.lgdnom
                     let d_cts06g11.endcmp       = lr_ctc71m01_ret.compleme
                     let d_cts06g11.lgdnum       = lr_ctc71m01_ret.lgdnum
                     let d_cts06g11.lgdcep       = lr_ctc71m01_ret.lgdcep
                     let d_cts06g11.lgdcepcmp    = lr_ctc71m01_ret.lgdcepcmp
                     let d_cts06g11.brrnom        = lr_ctc71m01_ret.brrnom
                     let d_cts06g11.cidnom       = lr_ctc71m01_ret.cidnom
                     let d_cts06g11.ufdcod       = lr_ctc71m01_ret.ufdcod
                     let d_cts06g11.endzon       = lr_ctc71m01_ret.endzon
                     let d_cts06g11.c24lclpdrcod = lr_ctc71m01_ret.c24lclpdrcod
                     let d_cts06g11.lclltt       = lr_ctc71m01_ret.lclltt
                     let d_cts06g11.lcllgt       = lr_ctc71m01_ret.lcllgt

                     if d_cts06g11.lclltt != 0      and
                     	  d_cts06g11.lcllgt != 0      and
                        d_cts06g11.c24lclpdrcod = 3 then
                           let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                           display by name ws.latlontxt
                     end if

                     display by name d_cts06g11.lclidttxt
                     display by name d_cts06g11.lgdtip
                     display by name d_cts06g11.lgdnom
                     display by name d_cts06g11.lgdnum
                     display by name d_cts06g11.lgdcep
                     display by name d_cts06g11.lgdcepcmp
                     display by name d_cts06g11.brrnom
                     display by name d_cts06g11.cidnom
                     display by name d_cts06g11.ufdcod
                     display by name d_cts06g11.endzon
                     display by name d_cts06g11.lclltt
                     display by name d_cts06g11.lcllgt
                     display by name d_cts06g11.endcmp
                     next field ptoref1
                else
                   error " Local sem indexação ! "
                end if
             end if
          end if

          let d_cts06g11.lgdnom = trim(d_cts06g11.lgdnom)

          if d_cts06g11.lgdnom is null or d_cts06g11.lgdnom = ''
             then
             error " Logradouro deve ser informado!"
             next field lgdnom
          end if

   before field lgdnum
          display by name d_cts06g11.lgdnum attribute (reverse)

   after  field lgdnum
          display by name d_cts06g11.lgdnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if ws.cepflg = "0" then
                next field lgdnom
             else
                next field lgdcep
             end if
          end if

          if d_cts06g11.lgdnum is null  then
             call cts08g01("C","S","","NUMERO DO LOGRADOURO",
                                   "NAO INFORMADO!","")
                 returning ws.confirma
             if ws.confirma = "N"  then
                next field lgdnum
             end if
          end if

   before field brrnom
        display by name d_cts06g11.brrnom attribute (reverse)
        if d_cts06g11.brrnom is null then
           let m_subbairro[1].brrnom = null
        end if
   after  field brrnom
          display by name d_cts06g11.brrnom
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             #if d_cts06g11.brrnom is null and
             #   m_lgdtip <> "RODOVIA"     then
             #   error " Bairro deve ser informado!"
             #   next field brrnom
             #end if
             if param.atdsrvorg   = 16   and  # sinistro transportes
                d_cts06g11.ufdcod = "EX" then # sinistro fora do Brasil
                next field endcmp
             end if

             if (param.atdsrvorg = 1 or
                 param.atdsrvorg = 2 or    # Mercosul
                 param.atdsrvorg = 4) and
                 d_cts06g11.ufdcod = "EX" then
                 next field endcmp
             end if
          else
             next field cidnom
          end if
          if d_cts06g11.brrnom is not null and
             d_cts06g11.brrnom <> " "      then
           # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
           if ctx25g05_rota_ativa() then
              initialize lr_ctx25g05_pes.* to null
              call ctx25g05_pesq_auto_cep(d_cts06g11.lgdtip,
                                          d_cts06g11.lgdnom,
                                          d_cts06g11.lgdnum,
                                          d_cts06g11.brrnom,
                                          d_cts06g11.lclbrrnom,
                                          d_cts06g11.ufdcod,
                                          d_cts06g11.cidnom,
                                          d_cts06g11.lgdcep,
                                          d_cts06g11.lgdcepcmp)
                           returning lr_ctx25g05_pes.ret         ,
                                     lr_ctx25g05_pes.lclltt      ,
                                     lr_ctx25g05_pes.lcllgt      ,
                                     lr_ctx25g05_pes.lgdtip      ,
                                     lr_ctx25g05_pes.lgdnom      ,
                                     lr_ctx25g05_pes.brrnom      ,
                                     lr_ctx25g05_pes.lclbrrnom   ,
                                     lr_ctx25g05_pes.lgdcep      ,
                                     lr_ctx25g05_pes.c24lclpdrcod
              if lr_ctx25g05_pes.ret <> 0 then
                 error "Erro ao chamar a funcao ctx25g05_pesq_auto() " sleep 2
              end if
              if lr_ctx25g05_pes.c24lclpdrcod = 3   and
                 lr_ctx25g05_pes.lclltt is not null and
                 lr_ctx25g05_pes.lcllgt is not null and
                 lr_ctx25g05_pes.lclltt <> 0        and
                 lr_ctx25g05_pes.lcllgt <> 0        then # -> INDEXOU AUTOMATICO

                  if  (d_cts06g11.lgdnom = lr_ctx25g05_pes.lgdnom) then
                     let d_cts06g11.lclltt       = lr_ctx25g05_pes.lclltt
                     let d_cts06g11.lcllgt       = lr_ctx25g05_pes.lcllgt
                     let d_cts06g11.lgdtip       = lr_ctx25g05_pes.lgdtip
                     let d_cts06g11.lgdnom       = lr_ctx25g05_pes.lgdnom
                     let d_cts06g11.brrnom       = lr_ctx25g05_pes.brrnom
                     let d_cts06g11.lclbrrnom    = lr_ctx25g05_pes.lclbrrnom
                     let d_cts06g11.lgdcep       = null
                     let d_cts06g11.lgdcepcmp    = null
                     let d_cts06g11.c24lclpdrcod = lr_ctx25g05_pes.c24lclpdrcod
                     # PSI 244589 - Inclusão de Sub-Bairro - Burini
                     let m_subbairro[1].brrnom = d_cts06g11.brrnom
                     call cts06g10_monta_brr_subbrr(lr_ctx25g05_pes.brrnom,
                                                    lr_ctx25g05_pes.lclbrrnom)
                          returning d_cts06g11.brrnom
                     #let ws.compleme = d_cts06g11.endcmp
                     display by name d_cts06g11.endcmp
                     let salva.cidnom     =  d_cts06g11.cidnom
                     let salva.ufdcod     =  d_cts06g11.ufdcod
                     let salva.lgdtip     =  d_cts06g11.lgdtip
                     let salva.lgdnom     =  d_cts06g11.lgdnom
                     let salva.lgdnum     =  d_cts06g11.lgdnum
                     let salva.endcmp     =  d_cts06g11.endcmp
                     let salva.brrnom     =  d_cts06g11.brrnom
                     let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
                     let salva.lclltt     =  d_cts06g11.lclltt
                     let salva.lcllgt     =  d_cts06g11.lcllgt
                     if d_cts06g11.c24lclpdrcod is null  then
                        error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
                        next field brrnom
                     end if
                     if d_cts06g11.c24lclpdrcod <> 01  and   ### Fora de padrao
                        d_cts06g11.c24lclpdrcod <> 02  and   ### Padrao Guia Postal
                        d_cts06g11.c24lclpdrcod <> 03  and   ### Padrao Mapas Rua
                        d_cts06g11.c24lclpdrcod <> 04  and   ### Padrao Mapas Bairro
                        d_cts06g11.c24lclpdrcod <> 05  then  ### Padrao Mapas Sub-Bairro
                        error " Codigo de padronizacao invalido! AVISE A INFORMATICA!"
                        next field lgdtip
                     end if
                     if d_cts06g11.lclltt != 0      and
                     	  d_cts06g11.lcllgt != 0      and
                        d_cts06g11.c24lclpdrcod = 3 then
                            let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                            display by name ws.latlontxt
                     end if
                 display by name d_cts06g11.lgdcep thru d_cts06g11.lcltelnum
                 display by name d_cts06g11.lgdtip
                 display by name d_cts06g11.lgdnom
                 display by name d_cts06g11.brrnom
                 display by name d_cts06g11.celteldddcod
                 display by name d_cts06g11.celtelnum
                 if d_cts06g11.brrnom is NOT NULL then
                    next field endcmp
                     end if
                 end if
              end if
           end if
          end if

          if l_flag_local_especial = "N" then
             #--------------------------------------------------------------
             # Verifica se a cidade possui mapa carregado
             #--------------------------------------------------------------
             initialize ws.mpacidcod  to null
             initialize ws.result     to null

             call cts23g00_inf_cidade(2,"",d_cts06g11.cidnom
                                     ,d_cts06g11.ufdcod)
                returning ws.result,
                          ws.mpacidcod,
                          ws.lclltt_cid,
                          ws.lcllgt_cid,
                          ws.mpacrglgdflg,
                          ws.gpsacngrpcod

             if param.atdsrvorg = 10 and    #OSF 19968
                v_retorno = 0 then
                let ws.mpacrglgdflg = null
             end if

             if ws.mpacrglgdflg = "1" then  # existe coordenadas por rua.

                # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
                if  ctx25g05_rota_ativa() then


                    let l_fondafinf = false

                    if  param.c24endtip = 1 then

                        if  ctn55c00_verifica_srv_org(g_documento.c24astcod) then

                            call ctn55c00_valida_endereco_daf(g_documento.succod,
                                                              g_documento.aplnumdig,
                                                              g_documento.itmnumdig,
                                                              g_funapol.vclsitatu,
                                                              "","")
                                 returning lr_daf.status_ret,
                                           lr_daf.lclltt,
                                           lr_daf.lcllgt,
                                           lr_daf.ufdcod,
                                           lr_daf.cidnom,
                                           lr_daf.lgdtip,
                                           lr_daf.lgdnom,
                                           lr_daf.brrnom,
                                           lr_daf.numero


                            if  g_issk.funmat = 4236 then
                                display "lr_daf.status_ret = ", lr_daf.status_ret
                                display "lr_daf.lclltt     = ", lr_daf.lclltt
                                display "lr_daf.lcllgt     = ", lr_daf.lcllgt
                                display "lr_daf.ufdcod     = ", lr_daf.ufdcod
                                display "lr_daf.cidnom     = ", lr_daf.cidnom
                                display "lr_daf.lgdtip     = ", lr_daf.lgdtip
                                display "lr_daf.lgdnom     = ", lr_daf.lgdnom
                                display "lr_daf.brrnom     = ", lr_daf.brrnom
                                display "lr_daf.numero     = ", lr_daf.numero
                            end if

                            if  lr_daf.status_ret = 0 then
                                if lr_daf.lgdtip is null or lr_daf.lgdtip = " " then
                                   call cts06g11_retira_tipo_lougradouro_navteq(lr_daf.lgdnom)
                                        returning lr_daf.lgdtip
                                                 ,lr_daf.lgdnom
                                end if


                                call cts06g03_inclui_temp_hstidx(1,
                                                                 lr_daf.lgdtip,
                                                                 lr_daf.lgdnom,
                                                                 lr_daf.numero,
                                                                 lr_daf.brrnom,
                                                                 lr_daf.cidnom,
                                                                 lr_daf.ufdcod,
                                                                 lr_daf.lclltt,
                                                                 lr_daf.lcllgt)

                                if  ctn55c00_compara_end(lr_daf.lgdnom, d_cts06g11.lgdnom) or
                                    ctn55c00_compara_end(lr_daf.lgdnom, d_cts06g11.lgdnom) then
                                    #display "MESMA FONETICA"
                                    let l_fondafinf = true

                                    if  g_issk.funmat = 4236 then
                                        display "MESMA FONETICA"
                                    end if
                                else
                                    #display "NAO POSSUI A MESMA FONETICA"
                                    let l_fondafinf = false
                                    if  g_issk.funmat = 4236 then
                                        display "NAO POSSUI MESMA FONETICA"
                                    end if
                                end if
                            end if
                        else
                            let lr_daf.status_ret = 1
                        end if
                    else
                        let l_fondafinf = false
                        let lr_daf.status_ret = 1
                    end if

                    initialize lr_ctx25g05.* to null

                    if  l_fondafinf then
                        if  param.c24endtip = 1 then
                            let d_cts06g11.lclltt = lr_daf.lclltt
                            let d_cts06g11.lcllgt = lr_daf.lcllgt
                            let d_cts06g11.c24lclpdrcod = 3
                            let d_cts06g11.brrnom = lr_daf.brrnom
                            display by name d_cts06g11.brrnom
                            message "                             Serviço indexado                                " attribute (reverse)
                        end if
                    else

                       # PSI-2014-11756/EV - Se pesquisa rodovia, considera o km e ignora a cidade. Se nao informar km, mantem a cidade
                       if upshift(d_cts06g11.lgdtip) = 'RODOVIA' and
                          d_cts06g11.lgdnum is not null and d_cts06g11.lgdnum > 0 then
                          let l_rodcidnom = d_cts06g11.cidnom
                          let d_cts06g11.cidnom = null
                       end if

                       # PSI-2014-11756/EV - Nao duplicar concatenacao de brrnom
                       if m_brrnomidx is not null
                          then
                          let d_cts06g11.brrnom = m_brrnomidx
                       end if

                       if  lr_daf.status_ret = 0 then
                           if param.c24endtip = 1 then
                              call ctx25g05_prox(d_cts06g11.ufdcod,
                                                d_cts06g11.cidnom,
                                                d_cts06g11.lgdtip,
                                                d_cts06g11.lgdnom,
                                                d_cts06g11.lgdnum,
                                                d_cts06g11.brrnom,
                                                d_cts06g11.lclbrrnom,
                                                d_cts06g11.lgdcep,
                                                d_cts06g11.lgdcepcmp,
                                                d_cts06g11.lclltt,
                                                d_cts06g11.lcllgt,
                                                d_cts06g11.c24lclpdrcod,
                                                lr_daf.lclltt,
                                                lr_daf.lcllgt)
                                      returning d_cts06g11.lgdtip,
                                                d_cts06g11.lgdnom,
                                                d_cts06g11.lgdnum,
                                                d_cts06g11.brrnom,
                                                d_cts06g11.lclbrrnom,
                                                d_cts06g11.lgdcep,
                                                d_cts06g11.lgdcepcmp,
                                                d_cts06g11.lclltt,
                                                d_cts06g11.lcllgt,
                                                d_cts06g11.c24lclpdrcod,
                                                d_cts06g11.ufdcod,
                                                d_cts06g11.cidnom,
                                                m_flagsemidx

                              let m_brrnomidx = d_cts06g11.brrnom
                           else
                               call ctx25g05("C", # -> INPUT COMPLETO
                                             "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                                             d_cts06g11.ufdcod,
                                             d_cts06g11.cidnom,
                                             d_cts06g11.lgdtip,
                                             d_cts06g11.lgdnom,
                                             d_cts06g11.lgdnum,
                                             d_cts06g11.brrnom,
                                             d_cts06g11.lclbrrnom,
                                             d_cts06g11.lgdcep,
                                             d_cts06g11.lgdcepcmp,
                                             d_cts06g11.lclltt,
                                             d_cts06g11.lcllgt,
                                             d_cts06g11.c24lclpdrcod)

                                   returning d_cts06g11.lgdtip,
                                             d_cts06g11.lgdnom,
                                             d_cts06g11.lgdnum,
                                             d_cts06g11.brrnom,
                                             d_cts06g11.lclbrrnom,
                                             d_cts06g11.lgdcep,
                                             d_cts06g11.lgdcepcmp,
                                             d_cts06g11.lclltt,
                                             d_cts06g11.lcllgt,
                                             d_cts06g11.c24lclpdrcod,
                                             d_cts06g11.ufdcod,
                                             d_cts06g11.cidnom

                              let m_brrnomidx = d_cts06g11.brrnom
                           end if
                       else
                           call ctx25g05("C", # -> INPUT COMPLETO
                                         "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                                         d_cts06g11.ufdcod,
                                         d_cts06g11.cidnom,
                                         d_cts06g11.lgdtip,
                                         d_cts06g11.lgdnom,
                                         d_cts06g11.lgdnum,
                                         d_cts06g11.brrnom,
                                         d_cts06g11.lclbrrnom,
                                         d_cts06g11.lgdcep,
                                         d_cts06g11.lgdcepcmp,
                                         d_cts06g11.lclltt,
                                         d_cts06g11.lcllgt,
                                         d_cts06g11.c24lclpdrcod)

                               returning d_cts06g11.lgdtip,
                                         d_cts06g11.lgdnom,
                                         d_cts06g11.lgdnum,
                                         d_cts06g11.brrnom,
                                         d_cts06g11.lclbrrnom,
                                         d_cts06g11.lgdcep,
                                         d_cts06g11.lgdcepcmp,
                                         d_cts06g11.lclltt,
                                         d_cts06g11.lcllgt,
                                         d_cts06g11.c24lclpdrcod,
                                         d_cts06g11.ufdcod,
                                         d_cts06g11.cidnom

                          let m_brrnomidx = d_cts06g11.brrnom
                       end if
                    end if

                    if  not l_fondafinf then
                        if d_cts06g11.lgdtip is null or d_cts06g11.lgdtip = " " then
                           call cts06g11_retira_tipo_lougradouro_navteq(d_cts06g11.lgdnom)
                                returning d_cts06g11.lgdtip
                                         ,d_cts06g11.lgdnom
                        end if
                    end if

                    if d_cts06g11.cidnom is null or d_cts06g11.cidnom = ' ' then
                       let d_cts06g11.cidnom = l_rodcidnom
                    end if

                    # PSI-2014-11756/EV - Reexibir dados, possibilidade de ter mantido indexacao anterior
                    display by name d_cts06g11.lgdcep
                    display by name d_cts06g11.lgdcepcmp
                    display by name d_cts06g11.lclidttxt
                    display by name d_cts06g11.cidnom
                    display by name d_cts06g11.ufdcod
                    display by name d_cts06g11.lgdtip
                    display by name d_cts06g11.lgdnom
                    display by name d_cts06g11.lgdnum
                    display by name d_cts06g11.brrnom
                    display by name ws.latlontxt

                    if  param.c24endtip = 1 then

                        call cts18g00(d_cts06g11.lclltt, d_cts06g11.lcllgt, lr_daf.lclltt, lr_daf.lcllgt)
                          returning l_dstqtd

                        call cta12m00_seleciona_datkgeral("PSOTOLDSPDAFPSO")
                             returning  l_resultado
                                       ,l_mensagem
                                       ,l_tolerancia

                        if  not l_fondafinf then

                           if  l_tolerancia > l_dstqtd and
                               lr_daf.lclltt is not null and
                               lr_daf.lcllgt is not null then
                               let d_cts06g11.lclltt = lr_daf.lclltt
                               let d_cts06g11.lcllgt = lr_daf.lcllgt

                               call cts06g03_inclui_temp_hstidx(3,
                                                                d_cts06g11.lgdtip,
                                                                d_cts06g11.lgdnom,
                                                                d_cts06g11.lgdnum,
                                                                d_cts06g11.brrnom,
                                                                d_cts06g11.cidnom,
                                                                d_cts06g11.ufdcod,
                                                                d_cts06g11.lclltt,
                                                                d_cts06g11.lcllgt)

                               let l_idxdaf = true
                           end if

                           if not l_idxdaf then
                               call cts06g03_inclui_temp_hstidx(4,
                                                                d_cts06g11.lgdtip,
                                                                d_cts06g11.lgdnom,
                                                                d_cts06g11.lgdnum,
                                                                d_cts06g11.brrnom,
                                                                d_cts06g11.cidnom,
                                                                d_cts06g11.ufdcod,
                                                                d_cts06g11.lclltt,
                                                                d_cts06g11.lcllgt)
                           end if
                        end if

                    end if

                    # PSI-2014-11756/EV - Nao duplicar concatenacao de brrnom
                    if m_brrnomidx is not null
                       then
                       let d_cts06g11.brrnom = m_brrnomidx
                    end if

                    # PSI 244589 - Inclusão de Sub-Bairro - Burini
                    let m_subbairro[1].brrnom = d_cts06g11.brrnom
                    if d_cts06g11.c24lclpdrcod = 3 then
                        call cts06g10_monta_brr_subbrr(d_cts06g11.brrnom,
                                                       d_cts06g11.lclbrrnom)
                             returning d_cts06g11.brrnom
                    end if
                else


                    # CASO OS CODIGOS FONETICOS DA ENDEREÇO DO DAF E DO
                    # INFORMADO NÃO SÃO SEJAM IGUAIS ABRE INPUT DE ENDEREÇO
                    call cts06g09(d_cts06g11.lgdtip,
                                  d_cts06g11.lgdnom,
                                  d_cts06g11.lgdnum,
                                  d_cts06g11.brrnom,
                                  ws.mpacidcod)
                        returning d_cts06g11.lgdtip,
                                  d_cts06g11.lgdnom,
                                  d_cts06g11.brrnom,
                                  d_cts06g11.lgdcep,
                                  d_cts06g11.lgdcepcmp,
                                  d_cts06g11.lclltt,
                                  d_cts06g11.lcllgt,
                                  d_cts06g11.c24lclpdrcod

                    let m_subbairro[1].brrnom = d_cts06g11.brrnom
                end if

                if d_cts06g11.c24lclpdrcod <> 03 or
                   d_cts06g11.lclltt is null     or
                   d_cts06g11.lclltt = 0         or
                   d_cts06g11.lcllgt is null     or
                   d_cts06g11.lcllgt = 0         then

                    let d_cts06g11.lclltt = ws.lclltt_cid #salva corrd. da cidade
                    let d_cts06g11.lcllgt = ws.lcllgt_cid
                    let d_cts06g11.c24lclpdrcod = 1
                end if

             else
                let  d_cts06g11.lclltt = ws.lclltt_cid #salva corrd. da cidade
                let  d_cts06g11.lcllgt = ws.lcllgt_cid

                if ws.cepflg  =  "0" then
                   call cts06g05(d_cts06g11.lgdtip,
                                 d_cts06g11.lgdnom,
                                 d_cts06g11.lgdnum,
                                 d_cts06g11.brrnom,
                                 ws.cidcod,
                                 d_cts06g11.ufdcod)
                       returning d_cts06g11.lgdtip,
                                 d_cts06g11.lgdnom,
                                 d_cts06g11.brrnom,
                                 d_cts06g11.lgdcep,
                                 d_cts06g11.lgdcepcmp,
                                 d_cts06g11.c24lclpdrcod

                    let m_subbairro[1].brrnom = d_cts06g11.brrnom
                end if
             end if

             if salva.lclltt = d_cts06g11.lclltt and  #ligia 09/10/07
                salva.lcllgt = d_cts06g11.lcllgt and
                salva.cidnom <> d_cts06g11.cidnom then
                let d_cts06g11.cidnom    = salva.cidnom
                let d_cts06g11.ufdcod    = salva.ufdcod
                let d_cts06g11.lgdtip    = salva.lgdtip
                let d_cts06g11.lgdnom    = salva.lgdnom
                let d_cts06g11.lgdnum    = salva.lgdnum
                let d_cts06g11.endcmp    = salva.endcmp
                let d_cts06g11.brrnom    = salva.brrnom
                let d_cts06g11.lclbrrnom = salva.lclbrrnom

             else
                let salva.cidnom     =  d_cts06g11.cidnom
                let salva.ufdcod     =  d_cts06g11.ufdcod
                let salva.lgdtip     =  d_cts06g11.lgdtip
                let salva.lgdnom     =  d_cts06g11.lgdnom
                let salva.lgdnum     =  d_cts06g11.lgdnum
                let salva.endcmp     =  d_cts06g11.endcmp
                let salva.brrnom     =  d_cts06g11.brrnom
                let salva.lclbrrnom  =  d_cts06g11.lclbrrnom
                let salva.lclltt     =  d_cts06g11.lclltt
                let salva.lcllgt     =  d_cts06g11.lcllgt
             end if

             if d_cts06g11.c24lclpdrcod is null  then
                error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
                next field lgdnom
             end if

             if d_cts06g11.c24lclpdrcod <> 01  and   ### Fora de padrao
                d_cts06g11.c24lclpdrcod <> 02  and   ### Padrao Guia Postal
                d_cts06g11.c24lclpdrcod <> 03  and   ### Padrao Mapas Rua
                d_cts06g11.c24lclpdrcod <> 04  and   ### Padrao Mapas Bairro
                d_cts06g11.c24lclpdrcod <> 05  then  ### Padrao Mapas Sub-bairro
                error " Codigo de padronizacao invalido! AVISE A INFORMATICA!"
                next field lgdtip
             end if

             if d_cts06g11.c24lclpdrcod = 02  then
                call cts06g06(d_cts06g11.lgdnom)
                    returning d_cts06g11.lgdnom
             end if

             display by name d_cts06g11.lgdcep thru d_cts06g11.lcltelnum
             display by name d_cts06g11.celteldddcod
             display by name d_cts06g11.celtelnum

             # mostrar latlon aqui por causa dos next field antes do fim desse
             if d_cts06g11.lclltt != 0      and
             	  d_cts06g11.lcllgt != 0      and
                d_cts06g11.c24lclpdrcod = 3 then
                    let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                    display by name ws.latlontxt
             end if


             if upshift(m_lgdtip) = 'MARGINAL' or upshift(m_lgdtip) = 'RODOVIA'
                then

                call cts06g11_sentido(m_lgdnom, m_lgdtip)
                     returning l_pontoreferencia

                let ws.ptoref1 = upshift(l_pontoreferencia[001,050]) clipped
                let ws.ptoref2 = upshift(l_pontoreferencia[051,100]) clipped
                let ws.ptoref3 = upshift(l_pontoreferencia[101,150]) clipped
                let ws.ptoref4 = upshift(l_pontoreferencia[151,200]) clipped

                let ws.ptoref1 = ws.ptoref1 clipped
                let ws.ptoref2 = ws.ptoref2 clipped
                let ws.ptoref3 = ws.ptoref3 clipped
                let ws.ptoref4 = ws.ptoref4 clipped

                let d_cts06g11.brrnom = " "
                if ws.ptoref2 is not null then
                  if ws.ptoref3 is null then
                     next field ptoref3
                  else
                    next field ptoref4
                  end if
                else
                  if ws.ptoref1 is not null then
                     next field ptoref2
                  else
                     next field ptoref1
                  end if
                end if
             else
               if d_cts06g11.brrnom is NOT null then
                  next field endcmp
               end if
             end if

          end if

          if d_cts06g11.lclltt != 0      and
          	 d_cts06g11.lcllgt != 0      and
             d_cts06g11.c24lclpdrcod = 3 then
                let ws.latlontxt = 'LAT/LON: ', d_cts06g11.lclltt, "," , d_cts06g11.lcllgt
                display by name ws.latlontxt
          end if


          if  lr_daf.status_ret = 0 then
              if  param.c24endtip = 1 then
                  if  l_fondafinf then
                      call cts06g03_inclui_temp_hstidx(2,
                                                       d_cts06g11.lgdtip,
                                                       d_cts06g11.lgdnom,
                                                       d_cts06g11.lgdnum,
                                                       d_cts06g11.brrnom,
                                                       d_cts06g11.cidnom,
                                                       d_cts06g11.ufdcod,
                                                       lr_daf.lclltt,
                                                       lr_daf.lcllgt)
                  else
                      if  m_flagsemidx then
                          call cts06g03_inclui_temp_hstidx(4,
                                                           d_cts06g11.lgdtip,
                                                           d_cts06g11.lgdnom,
                                                           d_cts06g11.lgdnum,
                                                           d_cts06g11.brrnom,
                                                           d_cts06g11.ufdcod,
                                                           d_cts06g11.cidnom,
                                                           d_cts06g11.lclltt,
                                                           d_cts06g11.lcllgt)
                      end if
                  end if
              end if
          end if

          if lr_daf.status_ret = 0 then
             initialize lr_daf.* to null
          end if

          if m_subbairro[1].brrnom <> d_cts06g11.brrnom then
              let d_cts06g11.lclbrrnom = d_cts06g11.brrnom
          end if

          let m_subbairro[1].brrnom = d_cts06g11.brrnom

   before field endzon
          display by name d_cts06g11.endzon attribute (reverse)
          let ws.cepflg = "0"

          if upshift(m_lgdtip) = 'MARGINAL' or
             upshift(m_lgdtip) = 'RODOVIA'  then
             next field ptoref1
          end if


   after  field endzon
          display by name d_cts06g11.endzon

          if d_cts06g11.endzon is not null  then
             if d_cts06g11.endzon <> "NO"  and
                d_cts06g11.endzon <> "LE"  and
                d_cts06g11.endzon <> "OE"  and
                d_cts06g11.endzon <> "SU"  and
                d_cts06g11.endzon <> "CE"  then
               error "Zona deve ser (NO)rte,(LE)ste,(OE)ste,(SU)l ou (CE)ntral!"
                next field endzon
             end if
          end if

# Inicio - Situação local de ocorrência
{
   # Inicio - Priscila 20/01/2006
   # Permite escolher outra via emergencial caso limpe a variavel.
   before field decide_via

         if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
             param.atdsrvorg = 4 or param.atdsrvorg = 6) and
             param.c24endtip = 1 then

              let lr_salva.emeviacod = lr_emeviacod.emeviacod
              let lr_salva.emeviades = lr_ctc17m02.emeviades
         else
            #nao exibe via emergencial
            let ws.decide_via = "S"
            let lr_emeviacod.emeviacod = null
            next field endcmp
         end if

         display by name ws.decide_via attribute (reverse)

    after field decide_via
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endzon
         end if

         if ws.decide_via = "N" then
            if lr_emeviacod.emeviacod is not null then
               error "Limpe o campo para selecionar outra via emergencial!"
               next field decide_via
            end if
         end if

         if ws.decide_via is null or
            (ws.decide_via = 'S' and lr_emeviacod.emeviacod is null) then
            call ctc17m02_popup_via(g_issk.dptsgl)
                  returning l_resultado
                           ,lr_emeviacod.emeviacod
                           ,lr_ctc17m02.emeviades
                           ,lr_ctc17m02.emeviapri
            if lr_emeviacod.emeviacod is null then
               let ws.decide_via = 'N'
            else
               let ws.decide_via = 'S'
            end if
            display by name ws.decide_via
            display by name lr_emeviacod.emeviacod
            display by name lr_ctc17m02.emeviades
         end if
}
   before field ocrlclstt

   if l_flag_auto = 'N' OR cts06g11_verif_bloq()  then
        next field endcmp
   else
        display by name ws.ocrlclstt attribute (reverse)
   end if

   after  field ocrlclstt
          display by name ws.ocrlclstt

        if ws.ocrlclstt <> 'S' AND ws.ocrlclstt <> 'N' then
             error "Tipo Local de Ocorrência inválido! Informe 'S' ou 'N'"
             next field ocrlclstt
        else
             open  c_cts06g11_011 using ws.ocrlclstt
             fetch c_cts06g11_011  into lr_emeviacod.emeviacod
             let lr_salva.emeviacod = lr_emeviacod.emeviacod
        end if

#Fim - Situação Local Ocorrência

   before field endcmp
          display by name d_cts06g11.endcmp attribute (reverse)

          if upshift(m_lgdtip) = 'MARGINAL' or
             upshift(m_lgdtip) = 'RODOVIA'  then
             next field ptoref1
          end if


   after  field endcmp
          display by name d_cts06g11.endcmp

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then

                if l_flag_auto = 'N' OR cts06g11_verif_bloq()  then
                   next field endzon
                else
                   next field ocrlclstt
                end if

# Inicio - Situação local de ocorrência
{
             if ws.decide_via = "N" then
                next field decide_via
             end if
             if lr_emeviacod.emeviacod is not null then
                next field emeviacod
             else
                next field endzon
             end if
}
#Fim - Situação local de ocorrência
          end if

   before field ptoref1
          display by name ws.ptoref1 attribute (reverse)

   after  field ptoref1
          display by name ws.ptoref1

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if upshift(m_lgdtip) = 'MARGINAL' or
            upshift(m_lgdtip) = 'RODOVIA'  then

            let m_lgdtip = null
            let m_lgdnom = null

            next field brrnom
         end if
      end if


   before field ptoref2
          display by name ws.ptoref2 attribute (reverse)

   after  field ptoref2
          display by name ws.ptoref2

   before field ptoref3
          display by name ws.ptoref3 attribute (reverse)

   after  field ptoref3
          display by name ws.ptoref3

   before field ptoref4
          display by name ws.ptoref4 attribute (reverse)

   after  field ptoref4
          display by name ws.ptoref4

   before field lclcttnom
          display by name d_cts06g11.lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name d_cts06g11.lclcttnom

          if (d_cts06g11.lclcttnom is null or
              d_cts06g11.lclcttnom = " "  ) and
              param.c24endtip = 1 then
             error "Contato deve ser informado!"
             next field lclcttnom
          end if

   before field dddcod
          display by name d_cts06g11.dddcod attribute (reverse)

   after  field dddcod
          display by name d_cts06g11.dddcod

   before field lcltelnum
          display by name d_cts06g11.lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name d_cts06g11.lcltelnum

          if (d_cts06g11.dddcod    is not null  and
              d_cts06g11.lcltelnum is null   )  or
             (d_cts06g11.dddcod    is null      and
              d_cts06g11.lcltelnum is not null) then
             error " Numero de telefone incompleto! "
             next field dddcod
          end if
          if param.c24endtip = 1 then ---> Apresenta Alerta so p/ Origem
             if d_cts06g11.lcltelnum is null and
                d_cts06g11.celtelnum is null then
                if cts08g01_6l("A","S"
                              ,""
                              ,"Não foram informados telefones"
                              ,"de contato com o cliente. Essa"
                              ,"informação e  muito importante"
                              ,"Deseja prosseguir mesmo assim?"
                              ,"") = "N" then
                    next field celteldddcod
                end if
             end if
          end if

   before field celteldddcod
          display by name d_cts06g11.celteldddcod attribute (reverse)

   after  field celteldddcod
          display by name d_cts06g11.celteldddcod

   before field celtelnum
          display by name d_cts06g11.celtelnum attribute (reverse)

   after  field celtelnum
          display by name d_cts06g11.celtelnum

          if (d_cts06g11.celteldddcod    is not null  and
              d_cts06g11.celtelnum is null   )  or
             (d_cts06g11.celteldddcod    is null      and
              d_cts06g11.celtelnum is not null) then
             error " Numero de celular incompleto! "
             next field celteldddcod
          end if

   on key (f3)

      if  (d_cts06g11.cidnom is not null and d_cts06g11.cidnom <> " ") and
          (d_cts06g11.ufdcod is not null and d_cts06g11.ufdcod <> " ") then
              call ctc87m00_orientacao_preenchimento(d_cts06g11.cidnom,
                                                     d_cts06g11.ufdcod)
      else
          error "Para consulta a cidade e o estado devem ser informados."
          next field cidnom
      end if


   on key (interrupt)
      #------------------------------------------------------------------
      # Verifica se os dados foram alterados e nao confirmados
      #------------------------------------------------------------------

         if d_cts06g11.cidnom  <>  salva.cidnom   then
            let ws.retflg = "N"
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field cidnom
         end if

         if d_cts06g11.ufdcod  <>  salva.ufdcod   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field ufdcod
         end if

         if d_cts06g11.lgdtip  <>  salva.lgdtip   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field lgdtip
         end if

         if d_cts06g11.lgdnom  <>  salva.lgdnom   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field lgdnom
         end if

         if d_cts06g11.lgdnum  <>  salva.lgdnum   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field lgdnum
         end if

      exit input

   on key (F5)
      if param.atdsrvorg <> 10 then # vistoria previa
         ##-- Exibir espelho da apolice --##
         let g_monitor.horaini = current ## Flexvision
         call cta01m12_espelho(g_documento.ramcod
                              ,g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig
                              ,g_documento.prporg
                              ,g_documento.prpnumdig
                              ,g_documento.fcapacorg
                              ,g_documento.fcapacnum
                              ,g_documento.pcacarnum
                              ,g_documento.pcaprpitm
                              ,g_ppt.cmnnumdig
                              ,g_documento.crtsaunum
                              ,g_documento.bnfnum
                              ,g_documento.ciaempcod)
      end if

   on key (F4)
      if param.atdsrvorg =  4   and   # remocao
         ws.locflg    = "N"  then
         call ctc54m00_patio("","")
              returning d_cts06g11.lclidttxt,
                        d_cts06g11.lgdtip,
                        d_cts06g11.lgdnom,
                        d_cts06g11.lgdnum,
                        d_cts06g11.brrnom,
                        d_cts06g11.cidnom,
                        d_cts06g11.ufdcod,
                        d_cts06g11.lclrefptotxt,
                        d_cts06g11.endzon,
                        d_cts06g11.lgdcep,
                        d_cts06g11.lgdcepcmp,
                        d_cts06g11.dddcod,
                        d_cts06g11.lcltelnum,
                        d_cts06g11.lclcttnom,
                        d_cts06g11.lclltt,
                        d_cts06g11.lcllgt,
                        d_cts06g11.c24lclpdrcod

         display by name d_cts06g11.lclidttxt
         display by name d_cts06g11.lgdtip
         display by name d_cts06g11.lgdnom
         display by name d_cts06g11.lgdnum
         display by name d_cts06g11.brrnom
         display by name d_cts06g11.cidnom
         display by name d_cts06g11.ufdcod
         display by name d_cts06g11.endzon
         display by name d_cts06g11.lgdcep
         display by name d_cts06g11.lgdcepcmp
         display by name d_cts06g11.dddcod
         display by name d_cts06g11.lcltelnum
         display by name d_cts06g11.lclcttnom
      end if

   on key (F6)
      if param.atdsrvorg <>  3   then
         if g_documento.atdsrvnum is null  then
            call cts10m02 (hist_cts06g11.*) returning hist_cts06g11.*
         else
            call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                          g_issk.funmat        , param.hoje  ,param.hora)
         end if
      end if

   on key (F7)
      if ws.benef = "S"  then
         call cts06g03_oficina("B","")
              returning d_cts06g11.ofnnumdig,
                        d_cts06g11.lclidttxt,
                        d_cts06g11.lgdnom,
                        d_cts06g11.brrnom,
                        d_cts06g11.cidnom,
                        d_cts06g11.ufdcod,
                        d_cts06g11.lgdcep,
                        d_cts06g11.lgdcepcmp
         if d_cts06g11.ofnnumdig is not null then
            let d1_cts06g11.obsofic = "* Oficina Beneficio *"
            display by name d1_cts06g11.obsofic
         end if
      end if

   on key (F8)
      if param.c24endtip = 2  then
         if g_documento.ciaempcod = 84 and
            param.atdsrvorg = 4 then
            call cts08g01("A","S",""
                         ,"ESTAS OFICINAS ATENDEM APENAS"
                         ,"CARROS DE PASSEIO."
                         ,"DESEJA PROSSEGUIR?")
                 returning ws.confirma
            if ws.confirma = "S" then
               call ctc91m19()
               returning d_cts06g11.ofnnumdig
                        ,d_cts06g11.lclidttxt
                        ,d_cts06g11.lgdtip
                        ,d_cts06g11.lgdnom
                        ,d_cts06g11.lgdnum
                        ,d_cts06g11.endcmp
                        ,d_cts06g11.brrnom
                        ,d_cts06g11.cidnom
                        ,d_cts06g11.ufdcod
                        ,d_cts06g11.lgdcep
                        ,d_cts06g11.lgdcepcmp
                        ,d_cts06g11.lclltt
                        ,d_cts06g11.lcllgt
                        ,d_cts06g11.lclcttnom
                        ,d_cts06g11.dddcod
                        ,d_cts06g11.lcltelnum
                        ,d_cts06g11.endzon
               let d_cts06g11.ofnnumdig = null # Desprezo o que foi retornado
               display by name d_cts06g11.lclidttxt
                              ,d_cts06g11.lgdtip
                              ,d_cts06g11.lgdnom
                              ,d_cts06g11.lgdnum
                              ,d_cts06g11.endcmp
                              ,d_cts06g11.brrnom
                              ,d_cts06g11.cidnom
                              ,d_cts06g11.ufdcod
                              ,d_cts06g11.lgdcep
                              ,d_cts06g11.lgdcepcmp
                              ,d_cts06g11.lclltt
                              ,d_cts06g11.lcllgt
                              ,d_cts06g11.lclcttnom
                              ,d_cts06g11.dddcod
                              ,d_cts06g11.lcltelnum
               if d_cts06g11.lclltt is not null and
                  d_cts06g11.lclltt <> 0 and
                  d_cts06g11.lcllgt is not null and
                  d_cts06g11.lcllgt <> 0 then
                  let d_cts06g11.c24lclpdrcod = 03
#                  next field decide_via - Situação local de ocorrência
               end if
            end if
         end if
         if g_documento.ciaempcod <> 84 then
         if ws.locflg = "S"  then
            call cts06g03_locadora(param.ligcvntip,
                                   d_cts06g11.cidnom,
                                   d_cts06g11.ufdcod)
                returning d_cts06g11.lclidttxt,
                          d_cts06g11.lgdnom,
                          d_cts06g11.brrnom,
                          d_cts06g11.cidnom,
                          d_cts06g11.ufdcod,
                          d_cts06g11.lgdcep,
                          d_cts06g11.lgdcepcmp
         else
            let ws.ramcod = g_documento.ramcod
            if ws.clscod = "096" then
               let ws.ramcod = 16
            end if
            let ws.ok  =  "S"
            if ws.benefx = "S" then     #OSF 19968
               call cts08g01("A","S",""     #OSF 19968
                            ," ESTAS OFICINAS NAO OFERECEM O"
                            ," BENEFICIO DE SINISTRO."
                            ," DESEJA PROSSEGUIR A CONSULTA?")
                    returning ws.confirma
               if ws.confirma = "N" then
                  let ws.ok = "N"
               end if
            end if
            if ws.ok = "S" then
            call ctn06n00(ws.ramcod,"")
                returning d_cts06g11.ofnnumdig,
                          d_cts06g11.lclidttxt,
                          d_cts06g11.lgdnom,
                          d_cts06g11.brrnom,
                          d_cts06g11.cidnom,
                          d_cts06g11.ufdcod
            if ws.benef = "S"  then
               if ws.ofnnumdig = d_cts06g11.ofnnumdig then
                  let d1_cts06g11.obsofic = "* Oficina Beneficio *"
               else
                  initialize d1_cts06g11.obsofic to null
               end if
               display by name d1_cts06g11.obsofic
            end if
            initialize d1_cts06g11.staofic to null
            if d_cts06g11.ofnnumdig is not null then
               select ofnstt
                   into ws.ofnstt
                   from sgokofi
                  where ofnnumdig = d_cts06g11.ofnnumdig
               if ws.ofnstt = "C" then
                  let d1_cts06g11.staofic  = "OBSERVACAO"
                  display by name d1_cts06g11.staofic attribute (reverse)
               end if
            end if
            end if
         end if
      end if
      end if

   on key (F9)
      if param.atdsrvorg =  4   and   # remocao
         ws.locflg       = "N"  and
         g_documento.ciaempcod <> 84 then
         call cts06g03_oficina("C","")
              returning d_cts06g11.ofnnumdig,
                        d_cts06g11.lclidttxt,
                        d_cts06g11.lgdnom,
                        d_cts06g11.brrnom,
                        d_cts06g11.cidnom,
                        d_cts06g11.ufdcod,
                        d_cts06g11.lgdcep,
                        d_cts06g11.lgdcepcmp
         if d_cts06g11.ofnnumdig is not null then
            if ws.benef = "S"  then
              if ws.ofnnumdig = d_cts06g11.ofnnumdig then
                 let d1_cts06g11.obsofic = "* Oficina Beneficio *"
              else
                 let d1_cts06g11.obsofic = "* Cadastro Beneficio *"
              end if
            end if
         end if
         display by name d1_cts06g11.obsofic
      end if

 end input



 if int_flag  then
    let int_flag = false
 end if

 let d_cts06g11.lclrefptotxt = ws.ptoref1 ,
                               ws.ptoref2 ,
                               ws.ptoref3 ,
                               ws.ptoref4

 if d_cts06g11.cidnom        is not null  and
    d_cts06g11.ufdcod        is not null  and
    ( d_cts06g11.brrnom      is not null or
      m_lgdtip = "RODOVIA"             )and

    d_cts06g11.lgdnom        is not null  and
    d_cts06g11.c24lclpdrcod  is not null  then
    
    let ws.retflg = "S"
 end if
 #------------------------------------------------------------------
 # Verifica se UF foi alterada e nao foi feita pesquisa no cadastro
 #------------------------------------------------------------------
 select ufdcod
   from glakest
  where ufdcod = d_cts06g11.ufdcod

 if sqlca.sqlcode = notfound then
    let ws.retflg = "N"
 end if
 #------------------------------------------------------------------------
 # Verifica se cidade foi alterada e nao foi feita pesquisa no cadastro
 #------------------------------------------------------------------------
 declare c_glakcid2 cursor for
    select cidcod
      from glakcid
     where cidnom = d_cts06g11.cidnom
       and ufdcod = d_cts06g11.ufdcod

 open  c_glakcid2
 fetch c_glakcid2

 if sqlca.sqlcode = notfound   then
    open  c_cts06g11_006 using d_cts06g11.cidnom,
                               d_cts06g11.ufdcod
    fetch c_cts06g11_006
    
    let ws.retflg = "S"
    if sqlca.sqlcode = notfound then
       let ws.retflg = "N"
    end if
 end if

 #------------------------------------------------------------------------
 # Verifica se cidade foi alterada (mapas)
 #------------------------------------------------------------------------
 if d_cts06g11.c24lclpdrcod = 03   then
    open  c_cts06g11_006 using d_cts06g11.cidnom,
                             d_cts06g11.ufdcod
    fetch c_cts06g11_006

    if sqlca.sqlcode <> 0 then
       let ws.retflg = "N"
       let l_nomcid = d_cts06g11.cidnom clipped, '%'
       open  c_cts06g11_006b using l_nomcid,
                                   d_cts06g11.ufdcod
       fetch c_cts06g11_006b into l_totcid
       
       if l_totcid = 1 then    
           open  c_cts06g11_006c using l_nomcid,
                                       d_cts06g11.ufdcod
           fetch c_cts06g11_006c into ws.mpacidcod
          
          if sqlca.sqlcode = 0 then
              let ws.retflg = "S"
          end if
      else
         if l_totcid = 0 then
             error "Nao ha cidades para os parametros informados"
          else
             error "Ha ", l_totcid,  " localizadas. Favor especificar a cidade"
          end if
       end if
    end if
 end if

 #------------------------------------------------------------------------
 # Verifica padrao guia postal
 #------------------------------------------------------------------------
 if d_cts06g11.c24lclpdrcod = 02   then
    if d_cts06g11.lgdcep    is not null   and
       d_cts06g11.lgdcepcmp is not null   then
       open  c_cts06g11_001  using  d_cts06g11.lgdcep,
                               d_cts06g11.lgdcepcmp
       fetch c_cts06g11_001  into   ws.lgdtip,
                               ws.lgdnom,
                               ws.cidcod,
                               ws.brrcod
       if sqlca.sqlcode  =  notfound   then
          let ws.retflg = "N"
       else
          # Inibido por Lucas Scheid - 30/10/06 - Conforme chamado 6107715
          # Nao e necessario validar o tipo de logradouro
          ##if d_cts06g11.lgdtip <> ws.lgdtip then
          ##   let ws.retflg = "N"
          ##end if
       end if
    end if
 end if

 close window cts06g11

 if  d_cts06g11.lgdcep is null  and
     param.atdsrvorg   =  10    then         #vistoria previa
     let d_cts06g11.lgdcep    = ws.cidcep    #se nao encontrar cep da rua
     let d_cts06g11.lgdcepcmp = ws.cidcepcmp #pegar da cidade. VP roterizada.
 end if

 if d_cts06g11.c24lclpdrcod = 1 or # PSI 252891
    d_cts06g11.c24lclpdrcod = 2 then
     call cts06g03_idx_brr(d_cts06g11.ufdcod,
                           d_cts06g11.cidnom,
                           m_subbairro[1].brrnom,
                           d_cts06g11.lclbrrnom,
                           d_cts06g11.lclltt,
                           d_cts06g11.lcllgt,
                           d_cts06g11.c24lclpdrcod)
         returning l_erro,
                   lr_idx_brr.lclltt,
                   lr_idx_brr.lcllgt,
                   lr_idx_brr.c24lclpdrcod

     if l_erro = 0 then
         let d_cts06g11.lclltt       = lr_idx_brr.lclltt
         let d_cts06g11.lcllgt       = lr_idx_brr.lcllgt
         let d_cts06g11.c24lclpdrcod = lr_idx_brr.c24lclpdrcod
     else
         if l_erro = 2 then
             error "Erro na indexacao por bairro e sub-bairro. AVISE A INFORMATICA"
             sleep 2
         end if
     end if
 end if

 #ligia 27/12/2006
 if g_documento.atdsrvnum is not null and
    param.atdsrvorg <> 10 then
    call cts06g03_valida_indexacao(l_c24lclpdrcod, d_cts06g11.c24lclpdrcod)
 end if

 #CHAMADO 91015273
 if m_subbairro[1].brrnom is not null and m_subbairro[1].brrnom <> " " then
    let d_cts06g11.brrnom = m_subbairro[1].brrnom
 end if

 if  (d_cts06g11.lclbrrnom is null or d_cts06g11.lclbrrnom = " ") and
     (d_cts06g11.brrnom is not null and d_cts06g11.brrnom <> " ") then
     let d_cts06g11.lclbrrnom = d_cts06g11.brrnom
     if d_cts06g11.lclbrrnom is null then
        let d_cts06g11.lclbrrnom = null
     end if
 end if

 if  (d_cts06g11.brrnom is null or d_cts06g11.brrnom = " ") and
     (d_cts06g11.lclbrrnom is not null and d_cts06g11.lclbrrnom <> " ") then
     let d_cts06g11.brrnom = d_cts06g11.lclbrrnom
 end if


 if g_issk.funmat = 7275 then
    display "2821 - d_cts06g11.brrnom = ",d_cts06g11.brrnom
    display "2822 - d_cts06g11.lclbrrnom = ",d_cts06g11.lclbrrnom
    display "2823 - d_cts06g11.c24lclpdrcod = ",d_cts06g11.c24lclpdrcod
    display "2824 - param.c24endtip = ",param.c24endtip
    display "2825 - d_cts06g11.lgdnom = ",d_cts06g11.lgdnom
    display "2826 - d_cts06g11.cidnom = ", d_cts06g11.cidnom
    display "2827 - d_cts06g11.ufdcod = ", d_cts06g11.ufdcod
 end if

 if d_cts06g11.lclbrrnom is null then
    #m_lgdtip = "RODOVIA" then
    let d_cts06g11.lclbrrnom = '.'
 end if

 if g_issk.funmat = 7275 then
    display "2836 - d_cts06g11.brrnom = ",d_cts06g11.brrnom
    display "2837 - d_cts06g11.lclbrrnom = ",d_cts06g11.lclbrrnom
    display "2838 - d_cts06g11.c24lclpdrcod = ",d_cts06g11.c24lclpdrcod
 end if

 if param.c24endtip = 1 then
    let g_indexado.endnum2 = d_cts06g11.lgdnum
    let g_indexado.endcid2 = d_cts06g11.cidnom
 end if
 call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)

    return d_cts06g11.*, ws.retflg, hist_cts06g11.*,lr_emeviacod.emeviacod

end function  ###  cts06g11

# -----------------------------------------------------------------------------
function cts06g11_sentido(l_param)
# -----------------------------------------------------------------------------
# funcao criada para abrir nova janela de local de ocorrencia
#    onde sao informados sentido/pista/km/referencia, dependendo situacao

   define l_param record
      lgdnom            char(100)
     ,lgdtip            char(100)
   end record

   define l_tpsentido        char(100)
         ,l_tpmarginal       char(100)
         ,l_tppista          char(100)
         ,l_tplougr          char(100)
         ,l_cabec            char(30)
         ,l_pontoreferencia  char(350)

  define lr_compl record
      titulo           char(20)
     ,sentido          char(35)
     ,pista            char(35)
     ,campo_km         char(03)
     ,km               char(5)
     ,referencias      char(200)
     ,exemplo          char(200)
   end record

   initialize lr_compl.* to null

   let l_tpsentido  = null
   let l_tppista    = null
   let l_cabec      = null

   if upshift(l_param.lgdtip) = 'RODOVIA' then
      let lr_compl.campo_km = 'KM:'
      let lr_compl.exemplo = "(Origem-Destino)"
   end if

   let l_pontoreferencia = null
   let lr_compl.referencias = m_lclrefptotxt

   open window w_sentido at 13,10 with form 'cts06g11b'
      attribute (border,form line first)

      input by name lr_compl.* without defaults

         before field titulo
            display '        Dados Complementares ' to titulo attribute (reverse)

         before field sentido
             display by name lr_compl.sentido

             if lr_compl.sentido is null  and
                upshift(l_param.lgdnom) = 'MARGINAL TIETE' then

                call cta00m06_tipo_sentido()
                     returning l_tpsentido

                if l_tpsentido is not null then
                   let l_cabec = "SENTIDO"

                   call ctx14g01a(l_cabec, l_tpsentido)
                      returning lr_compl.sentido
                end if
             end if

             if lr_compl.sentido is null  and
                upshift(l_param.lgdnom) = 'MARGINAL PINHEIROS' then

                call cta00m06_tipo_sentido2()
                     returning l_tpsentido

                if l_tpsentido is not null then
                   let l_cabec = " SENTIDO"

                   call ctx14g01a(l_cabec, l_tpsentido)
                      returning lr_compl.sentido
                end if
             end if

         after field sentido

            if lr_compl.sentido is null or
               lr_compl.sentido = ' ' then
               error ' E PRECISO INFORMAR UM SENTIDO !'
               next field sentido
            end if

         before field pista
            display by name lr_compl.pista

            if lr_compl.pista is null then
               if upshift(l_param.lgdtip) = 'MARGINAL' then
                 call cta00m06_tipo_pista_marginal()
                 returning l_tppista
               else
                 if upshift(l_param.lgdtip) = 'RODOVIA' then
                   call cta00m06_tipo_pista_rodovia()
                   returning l_tppista
                 end if
               end if

               if l_tppista is not null then
                  let l_cabec = "Tipo Pista"

                  call ctx14g01a(l_cabec, l_tppista)
                     returning lr_compl.pista
                  display lr_compl.pista to pista
               end if
            end if

         after field pista

            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field sentido
            end if

            if (lr_compl.pista is null or
               lr_compl.pista = " "    ) and
               (upshift(l_param.lgdtip) = 'MARGINAL' or
               upshift(l_param.lgdtip) = 'RODOVIA'  )then
                error ' E preciso informar a Pista !'
                next field pista
            end if

            if upshift(l_param.lgdtip) = 'RODOVIA' then
               display  lr_compl.campo_km to campo_km
               next field km
            else
                next field referencias
            end if

         before field km
            display by name lr_compl.km

         after field km

            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field pista
            end if

            #let lr_compl.km = lr_compl.km clipped

            if lr_compl.km is null or
               lr_compl.km = " "   then
               error " E preciso informar KM ! "
            end if

         before field referencias
            display by name lr_compl.referencias
            error ' Informe ponto de referencia !'

         after field referencias

            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               if upshift(l_param.lgdtip) = 'RODOVIA' then
                  next field km
               else
                  next field pista
               end if
            end if

            if lr_compl.referencias is null then
               if upshift(l_param.lgdtip) <> 'MARGINAL' then
                  next field referencias
               end if
            end if

            let m_sentido = lr_compl.sentido
            let m_pista   = lr_compl.pista

            if upshift(l_param.lgdtip) <> 'MARGINAL' then
               let l_pontoreferencia = 'Sentido: ' ,lr_compl.sentido clipped ,' / '
                                     , 'Pista: ' ,lr_compl.pista clipped ,' / '
            end if

            if lr_compl.km is not null or
               lr_compl.km <> " " then
               let l_pontoreferencia = l_pontoreferencia clipped , 'KM: ' ,lr_compl.km clipped ,' / '
               let m_km = lr_compl.km
            end if

            # Retirar termo Referencias - PSI xxxxx
            if lr_compl.referencias is not null or
               lr_compl.referencias <> " " then
               let l_pontoreferencia = l_pontoreferencia clipped, ' ' , lr_compl.referencias clipped, ' / '
            end if

      before field exemplo
           display by name lr_compl.exemplo
           exit input
      after field exemplo
           display by name lr_compl.exemplo


      on key (interrupt,control-c)

           let m_sentido = lr_compl.sentido
           let m_pista   = lr_compl.pista
           if upshift(l_param.lgdtip) <> 'MARGINAL' then
              let l_pontoreferencia = 'Sentido: ' ,lr_compl.sentido clipped ,' / '
                                    , 'Pista: ' ,lr_compl.pista clipped ,' / '
           end if

           if lr_compl.km is not null or
              lr_compl.km <> " " then
              let l_pontoreferencia = l_pontoreferencia clipped , 'KM: ' ,lr_compl.km clipped ,' / '
           end if

           # Retirar termo Referencias - PSI xxxxx
           if lr_compl.referencias is not null or
              lr_compl.referencias <> " " then
              let l_pontoreferencia = l_pontoreferencia clipped, ' ' , lr_compl.referencias clipped, ' / '
           end if

           exit input

      end input

   close window w_sentido

   return l_pontoreferencia clipped
end function

# -----------------------------------------------------------------------------
function cts06g11_retira_tipo_lougradouro(l_string)
# -----------------------------------------------------------------------------
 define l_string      char(100)
 define l_j           smallint
 define l_i           smallint
 define l_tamanho     smallint
 define l_rua         char(100)
 define l_tipo_logradouro char(30)
 define l_count       smallint

 let l_i = 1
 let l_tamanho = 0
 let l_rua = ''
 let l_tipo_logradouro = ''

 #REMOVE ESPACOS DO INICIO DO LOGRADOURO
 let l_string = cts06g11_ltrim(l_string)

 let l_tamanho = length(l_string)

 if m_prep_sql is null or
    m_prep_sql = false then
    call cts06g11_prepare()
 end if


 for l_i = 1 to l_tamanho
     if l_string[l_i] = ' ' then
        let l_tipo_logradouro = l_string[1,l_i-1]

        whenever error continue
          open c_cts06g11_008 using l_tipo_logradouro
          fetch c_cts06g11_008 into l_count
        whenever error stop

        if l_count > 0 then
           let l_rua = l_string[l_i+1,l_tamanho]
        end if

        exit for
     end if
 end for
 close c_cts06g11_008

 let l_tamanho = length(l_tipo_logradouro)
 for l_j = 1 to l_tamanho
     if l_tipo_logradouro[l_j] = '.' then
        let l_tipo_logradouro[l_j] = ' '
     end if
 end for

 let l_tipo_logradouro = l_tipo_logradouro clipped

 if l_rua = ''  or
    l_rua = ' ' or
    l_rua is null then
    return ' ', l_string
 else
    return l_tipo_logradouro
         , l_rua

 end if

end function

#--------------------------------------------------------------------------
function cts06g11_concatena_local(l_lgdnom)
#--------------------------------------------------------------------------
 define l_lgdnom char(200)
 define lr_lgdnom char(200)
 define l_sentido char(60)
 define l_pista   char(60)

 let lr_lgdnom = null


 if g_issk.funmat = 7275 then
 display "m_sentido = ","|",m_sentido,"|"
 end if
 let m_sentido = m_sentido clipped
 let m_pista   = m_pista clipped
 case m_sentido

     when "Santo Amaro"
         let l_sentido = "SENT ST AMARO"
     when "Jaguare"
         let l_sentido = "SENT JAGUARE"
     when "Zona Sul"
         let l_sentido = "SENT SUL"
     when "Zona Oeste"
         let l_sentido = "SENT OESTE"
     when "Interlagos"
         let l_sentido = "SENT INTERLAG"
     when "Castelo Branco"
         let l_sentido = "SENT CASTELO"
     when "Penha"
         let l_sentido = "SENT PENHA"
     when "Lapa"
         let l_sentido = "SENT LAPA"
     when "Ayrton Senna"
         let l_sentido = "SENT A. SENNA"
     #when "Castelo Branco"
     #    let l_sentido = "SENT C. BRANCO"
     when "Zona Leste"
         let l_sentido = "SENT LESTE"
     when "Zona Oeste"
         let l_sentido = "SENT OESTE"
     otherwise
         let l_sentido = null
 end case

 if g_issk.funmat = 7275 then
 display "m_pista = ","|",m_pista,"|"
 end if
 case m_pista
      when "Central"
         let l_pista = "CENTRAL"
      when "Expressa(Junto ao Rio)"
         let l_pista = "EXPRESS"
      when "Local"
         let l_pista = "LOCAL"
      otherwise
         let l_pista = null
 end case

 if g_issk.funmat = 7275 then
 display "l_pista = ",l_pista
 end if
 let lr_lgdnom = l_lgdnom clipped, ",",l_sentido clipped, ",",l_pista clipped
 if g_issk.funmat = 7275 then
 display "lr_lgdnom = ",lr_lgdnom
 end if

 return lr_lgdnom

end function

# -----------------------------------------------------------------------------
 function cts06g11_retira_tipo_lougradouro_navteq(l_string)
# -----------------------------------------------------------------------------
 define l_string          char(100)
 define l_j               smallint
 define l_i               smallint
 define l_tamanho         smallint
 define l_rua             char(100)
 define l_tipo_logradouro char(30)
 define l_count           smallint

 let l_i = 1
 let l_tamanho = 0
 let l_rua = ''
 let l_tipo_logradouro = ''

 #REMOVE ESPACOS DO INICIO DO LOGRADOURO
 let l_string = cts06g11_ltrim(l_string)

 let l_tamanho = length(l_string)

 if m_prep_sql is null or
    m_prep_sql = false then
    call cts06g11_prepare()
 end if


 for l_i = 1 to l_tamanho
     if l_string[l_i] = ' ' then
        let l_tipo_logradouro = l_string[1,l_i-1]

        whenever error continue
          open c_cts06g11_009 using l_tipo_logradouro
          fetch c_cts06g11_009 into l_count
        whenever error stop

        if l_count > 0 then
           let l_rua = l_string[l_i+1,l_tamanho]
        end if

        exit for
     end if
 end for
 close c_cts06g11_009

 let l_tamanho = length(l_tipo_logradouro)
 for l_j = 1 to l_tamanho
     if l_tipo_logradouro[l_j] = '.' then
        let l_tipo_logradouro[l_j] = ' '
     end if
 end for

 let l_tipo_logradouro = l_tipo_logradouro clipped

 if l_rua = ''  or
    l_rua = ' ' or
    l_rua is null then
    return ' ', l_string
 else
    return l_tipo_logradouro
         , l_rua

 end if

end function

# -----------------------------------------------------------------------------
function cts06g11_ltrim(l_string)
# -----------------------------------------------------------------------------
# RETINA ESPACOS DO INICIO DO TEXTO
 define l_string          char(100)

 while l_string[1] = ' '
    let l_string = l_string[2,99]
 end while

 return l_string

end function

#----------------------------#
function cts06g11_verif_bloq()
#----------------------------#

   define l_variavel_ret  like datkgeral.grlinf #formato: XX:XX-XX:XX
         ,l_erro          smallint
         ,l_mensagem      char(60)
         ,l_ini_restricao datetime hour to minute
         ,l_fim_restricao datetime hour to minute
         ,l_horario_atual datetime hour to minute

   initialize l_variavel_ret
             ,l_erro
             ,l_mensagem
             ,l_ini_restricao
             ,l_fim_restricao
             ,l_horario_atual to null

   #consultar o valor do parametro
   call cta12m00_seleciona_datkgeral("PSOBLQEXBMSGLCL")
      returning l_erro
               ,l_mensagem
               ,l_variavel_ret

   # Não existem parametro de restricao de horario
   if l_variavel_ret is null or
      l_variavel_ret = " "   or
      l_erro <> 1 then
      return false
   end if

   # Cast dos tipos de variaveis char > datetime
   let l_ini_restricao = l_variavel_ret[1,5]
   let l_fim_restricao = l_variavel_ret[7,11]
   let l_horario_atual = current

   # Horario de restricao tem inico e fim igual
   if l_ini_restricao  = l_fim_restricao then
      return true
   end if

   # Horario atual esta entre a restrição.
   if l_horario_atual >= l_ini_restricao and
      l_horario_atual <= l_fim_restricao then
      return true
   end if

   # Horario atual não possui restrição.
   return false

end function

# PSI-2014-11756 - preencher UF a partir da cidade informada ou UF e capital da UF
#----------------------------------------------------------------
function cts06g11_id_uf_capital(l_param)
#----------------------------------------------------------------

  define l_param record
         atdsrvorg      like datmservico.atdsrvorg,
         cidnom         like datmlcl.cidnom
  end record

  define la_uf array[30] of record
         ufdcod  char(02)
       , ufdnom  char(45)
  end record

  define l_arr smallint
       , l_ct  smallint
       , l_estados  char(600)
       , l_ufdcod   char(02)
       , l_opcao    smallint
       , l_ufdnom   char(20)
       , l_errcod   smallint
       , l_cidnom   char(45)

  initialize la_uf
           , l_arr
           , l_ct
           , l_estados
           , l_ufdcod
           , l_opcao
           , l_ufdnom
           , l_cidnom to null

  if l_param.atdsrvorg <= 0 or
     l_param.cidnom is null
     then
     return 99, '', l_param.cidnom
  end if

  let l_param.cidnom = upshift(l_param.cidnom)
  let l_param.cidnom = trim(l_param.cidnom)
  let l_cidnom = l_param.cidnom

  # fixado no codigo, datkmpacid nao tem nomes das UFs
  let la_uf[01].ufdcod = 'AC'	let la_uf[01].ufdnom = 'ACRE'
  let la_uf[02].ufdcod = 'AL'	let la_uf[02].ufdnom = 'ALAGOAS'
  let la_uf[03].ufdcod = 'AP'	let la_uf[03].ufdnom = 'AMAPA'
  let la_uf[04].ufdcod = 'AM'	let la_uf[04].ufdnom = 'AMAZONAS'
  let la_uf[05].ufdcod = 'BA'	let la_uf[05].ufdnom = 'BAHIA'
  let la_uf[06].ufdcod = 'CE'	let la_uf[06].ufdnom = 'CEARA'
  let la_uf[07].ufdcod = 'DF'	let la_uf[07].ufdnom = 'DISTRITO FEDERAL'
  let la_uf[08].ufdcod = 'ES'	let la_uf[08].ufdnom = 'ESPIRITO SANTO'
  let la_uf[09].ufdcod = 'GO'	let la_uf[09].ufdnom = 'GOIAS'
  let la_uf[10].ufdcod = 'MA'	let la_uf[10].ufdnom = 'MARANHAO'
  let la_uf[11].ufdcod = 'MT'	let la_uf[11].ufdnom = 'MATO GROSSO'
  let la_uf[12].ufdcod = 'MS'	let la_uf[12].ufdnom = 'MATO GROSSO DO SUL'
  let la_uf[13].ufdcod = 'MG'	let la_uf[13].ufdnom = 'MINAS GERAIS'
  let la_uf[14].ufdcod = 'PA'	let la_uf[14].ufdnom = 'PARA'
  let la_uf[15].ufdcod = 'PB'	let la_uf[15].ufdnom = 'PARAIBA'
  let la_uf[16].ufdcod = 'PR'	let la_uf[16].ufdnom = 'PARANA'
  let la_uf[17].ufdcod = 'PE'	let la_uf[17].ufdnom = 'PERNAMBUCO'
  let la_uf[18].ufdcod = 'PI'	let la_uf[18].ufdnom = 'PIAUI'
  let la_uf[19].ufdcod = 'RJ'	let la_uf[19].ufdnom = 'RIO DE JANEIRO'
  let la_uf[20].ufdcod = 'RN'	let la_uf[20].ufdnom = 'RIO GRANDE DO NORTE'
  let la_uf[21].ufdcod = 'RS'	let la_uf[21].ufdnom = 'RIO GRANDE DO SUL'
  let la_uf[22].ufdcod = 'RO'	let la_uf[22].ufdnom = 'RONDONIA'
  let la_uf[23].ufdcod = 'RR'	let la_uf[23].ufdnom = 'RORAIMA'
  let la_uf[24].ufdcod = 'SC'	let la_uf[24].ufdnom = 'SANTA CATARINA'
  let la_uf[25].ufdcod = 'SP'	let la_uf[25].ufdnom = 'SAO PAULO'
  let la_uf[26].ufdcod = 'SE'	let la_uf[26].ufdnom = 'SERGIPE'
  let la_uf[27].ufdcod = 'TO'	let la_uf[27].ufdnom = 'TOCANTINS'

  # cidades com maior numero de servicos e que sejam unicas no pais, nao pesquisa no DB
  # principais capitais sao identificadas a partir da digitacao da UF
  # SAO PAULO nao entra porque tem outras cidades com o termo no meio
  case l_param.cidnom
     when 'RIO DE JANEIRO'
        return 0, 'RJ', l_cidnom
     when 'BRASILIA'
        return 0, 'DF', l_cidnom
     when 'BELO HORIZONTE'
        return 0, 'MG', l_cidnom
     when 'CURITIBA'
        return 0, 'PR', l_cidnom
     when 'SALVADOR'
        return 0, 'BA', l_cidnom
     when 'PORTO ALEGRE'
        return 0, 'RS', l_cidnom
     when 'GOIANIA'
        return 0, 'GO', l_cidnom
     when 'SP'
        return 0, 'SP', 'SAO PAULO'
     when 'RJ'
        return 0, 'RJ', 'RIO DE JANEIRO'
     when 'DF'
        return 0, 'DF', 'BRASILIA'
     when 'BH'
        return 0, 'MG', 'BELO HORIZONTE'
     when 'PR'
        return 0, 'PR', 'CURITIBA'
     when 'BA'
        return 0, 'BA', 'SALVADOR'
     when 'RS'
        return 0, 'RS', 'PORTO ALEGRE'
     when 'GO'
        return 0, 'GO', 'GOIANIA'
     when 'SAO BERNARDO DO CAMPO'
        return 0, 'SP', l_cidnom
     when 'CAMPINAS'
        return 0, 'SP', l_cidnom
     when 'GUARULHOS'
        return 0, 'SP', l_cidnom
     when 'SANTOS'
        return 0, 'SP', l_cidnom
     when 'OSASCO'
        return 0, 'SP', l_cidnom
     when 'SAO JOSE DOS CAMPOS'
        return 0, 'SP', l_cidnom
  end case

  let l_arr = 1

  whenever error continue
  if l_param.atdsrvorg = 10   # Vistoria Previa - Valida a cidade pelo Guia Postal
     then
     open c_cts06g11_013 using l_param.cidnom

     foreach c_cts06g11_013 into l_ufdcod

        for l_ct = 1 to 27
          if l_ufdcod = la_uf[l_ct].ufdcod
             then
             let l_ufdnom = la_uf[l_ct].ufdnom
             exit for
          end if
        end for

        if l_ufdnom is not null
           then
           if l_arr = 1
              then
              let l_estados = l_ufdnom
           else
              let l_estados = l_estados clipped, '|', l_ufdnom clipped
           end if

           let l_arr = l_arr + 1
        end if

        let l_ufdnom = null
     end foreach

  else  # outras origens, valida a cidade pelo Mapa

     open c_cts06g11_014 using l_param.cidnom

     foreach c_cts06g11_014 into l_ufdcod

        for l_ct = 1 to 27
          if l_ufdcod = la_uf[l_ct].ufdcod
             then
             let l_ufdnom = la_uf[l_ct].ufdnom
             exit for
          end if
        end for

        if l_ufdnom is not null
           then
           if l_arr = 1
              then
              let l_estados = l_ufdnom
           else
              let l_estados = l_estados clipped, '|', l_ufdnom clipped
           end if

           let l_arr = l_arr + 1
        end if

        let l_ufdnom = null
     end foreach

  end if

  whenever error stop

  let l_arr = l_arr - 1

  if l_arr > 1
     then
     call ctx14g01('Selecione o estado:', l_estados)
          returning l_opcao, l_ufdnom

     for l_ct = 1 to 27
       if trim(l_ufdnom) = trim(la_uf[l_ct].ufdnom)
          then
          let l_ufdcod = la_uf[l_ct].ufdcod
          exit for
       end if
     end for
  end if

  if l_ufdcod is not null
     then
     return 0, l_ufdcod, l_cidnom
  else
     return 99, '', l_cidnom
  end if

end function

function cts06g11_verifica_cidade(lr_vldcid)

define lr_vldcid record
   atdsrvorg   like datmservico.atdsrvorg
  ,cidnom      like datmlcl.cidnom
  ,ufdcod      like datmlcl.ufdcod
end record

define retorno record
   cidcod      like glakcid.cidcod
  ,cidcep      like glakcid.cidcep
  ,cidcepcmp   like glakcid.cidcepcmp
  ,cidnom      like datmlcl.cidnom
  ,ufdcod      like datmlcl.ufdcod
  ,prcok       char(1)    #Flag dados preenchidos
end record

initialize retorno.* to null
             
#--------------------------------------------------------------
# Verifica se a cidade esta cadastrada
#--------------------------------------------------------------
   if lr_vldcid.atdsrvorg = 10 then
      # Vistoria Previa - Valida a cidade pelo Guia Postal
      open  c_cts06g11_007 using lr_vldcid.cidnom,
                                 lr_vldcid.ufdcod
      fetch c_cts06g11_007  into  retorno.cidcod,retorno.cidcep,retorno.cidcepcmp
      
         if sqlca.sqlcode = 0 then
            let retorno.prcok = 'S'
         else
            let retorno.prcok = 'N'
         end if
      close c_cts06g11_007
   
   else
      # Valida a cidade pelo Mapa
      open  c_cts06g11_010 using lr_vldcid.cidnom,
                                 lr_vldcid.ufdcod
      fetch c_cts06g11_010  into  retorno.cidcod
      
         if sqlca.sqlcode = 0 then
            let retorno.prcok = 'S'
         else
            let retorno.prcok = 'N'
         end if
      close c_cts06g11_010
   end if
   
   if retorno.prcok = 'N' then
      call cts06g04_oficial(lr_vldcid.cidnom, lr_vldcid.ufdcod)
                 returning retorno.cidcod, retorno.cidnom, retorno.ufdcod
         
      if retorno.cidcod  is null   then
         let retorno.prcok = 'N'
      else
         let retorno.prcok = 'S'
      end if
   end if
   
   return retorno.*  
   
end function

#--------------------------------------------------------------#
 function cts06g11_carrega_endcid(l_endcep, l_endcepcmp, l_endcid)
#--------------------------------------------------------------#
 define l_endcep           like gsakend.endcep,
        l_endcepcmp        like gsakend.endcepcmp,
        l_endcid           char(45)
 define l_lgdtip           like glaklgd.lgdtip,
        l_lgdnom           like glaklgd.lgdnom,
        l_cidcod           like glaklgd.cidcod,
        l_brrcod           like glaklgd.brrcod
 define l_cidnom           like glakcid.cidnom,
        l_ufdcod           like glakcid.ufdcod
 #glaklgd
 open c_cts06g11_001 using l_endcep,
                           l_endcepcmp
 fetch c_cts06g11_001 into l_lgdtip,
                           l_lgdnom,
                           l_cidcod,
                           l_brrcod

 if sqlca.sqlcode <> 0 then
    return false, l_endcid
 end if
 close c_cts06g11_001

 #glakcid
 open c_cts06g11_002 using l_cidcod

 fetch c_cts06g11_002 into l_cidnom,
                           l_ufdcod

 if sqlca.sqlcode <> 0 then
    return false, l_endcid
 end if
 close c_cts06g11_002

 return true, l_cidnom

 end function 