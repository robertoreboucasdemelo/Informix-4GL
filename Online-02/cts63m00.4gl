############################################################################
#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts63m00                                                   #
#Analista Resp : Amilton Pinto                                              #
#                Laudo para assistencia a passageiros - Hospedagem          #
#...........................................................................#
#Desenvolvimento: Amilton Pinto                                             #
#Liberacao      : 02/04/2011                                                #
#---------------------------------------------------------------------------#
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
#Data       Autor Fabrica  Origem     Alteracao                             #
#---------- -------------- ---------- --------------------------------------#
# 01/10/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


 define d_cts63m00   record
    servico          char (13)                         ,
    c24solnom        like datmligacao.c24solnom        ,
    nom              like datmservico.nom              ,
    doctxt           char (32)                         ,
    corsus           like datmservico.corsus           ,
    cornom           like datmservico.cornom           ,
    vclcoddig        like datmservico.vclcoddig        ,
    vcldes           like datmservico.vcldes           ,
    vclanomdl        like datmservico.vclanomdl        ,
    vcllicnum        like datmservico.vcllicnum        ,
    vclcordes        char (11)                         ,
    asimtvcod        like datkasimtv.asimtvcod         ,
    asimtvdes        like datkasimtv.asimtvdes         ,
    refatdsrvorg     like datmservico.atdsrvorg        ,
    refatdsrvnum     like datmassistpassag.refatdsrvnum,
    refatdsrvano     like datmassistpassag.refatdsrvano,
    seghospedado     like datmhosped.hspsegsit,
    hpddiapvsqtd     like datmhosped.hpddiapvsqtd      ,
    hpdqrtqtd        like datmhosped.hpdqrtqtd         ,
    imdsrvflg        char (01)                         ,
    atdprinvlcod     like datmservico.atdprinvlcod     ,
    atdprinvldes     char (06)                         ,
    atdlibflg        like datmservico.atdlibflg        ,
    frmflg           char (01)                         ,
    atdtxt           char (48)                         ,
    atdlibdat        like datmservico.atdlibdat        ,
    atdlibhor        like datmservico.atdlibhor
 end record

 define w_cts63m00   record
    atdsrvnum        like datmservico.atdsrvnum   ,
    atdsrvano        like datmservico.atdsrvano   ,
    vclcorcod        like datmservico.vclcorcod   ,
    lignum           like datrligsrv.lignum       ,
    atdhorpvt        like datmservico.atdhorpvt   ,
    atdpvtretflg     like datmservico.atdpvtretflg,
    atddatprg        like datmservico.atddatprg   ,
    atdhorprg        like datmservico.atdhorprg   ,
    atdlibflg        like datmservico.atdlibflg   ,
    antlibflg        like datmservico.atdlibflg   ,
    atdlibdat        like datmservico.atdlibdat   ,
    atdlibhor        like datmservico.atdlibhor   ,
    atddat           like datmservico.atddat      ,
    atdhor           like datmservico.atdhor      ,
    cnldat           like datmservico.cnldat      ,
    atdfnlhor        like datmservico.atdfnlhor   ,
    atdfnlflg        like datmservico.atdfnlflg   ,
    atdetpcod        like datmsrvacp.atdetpcod    ,
    atdprscod        like datmservico.atdprscod   ,
    c24opemat        like datmservico.c24opemat   ,
    c24nomctt        like datmservico.c24nomctt   ,
    atdcstvlr        like datmservico.atdcstvlr   ,
    ligcvntip        like datmligacao.ligcvntip   ,
    ano              char (02)                    ,
    data             char (10)                    ,
    hora             char (05)                    ,
    funmat           like datmservico.funmat      ,
    atddmccidnom     like datmassistpassag.atddmccidnom,
    atddmcufdcod     like datmassistpassag.atddmcufdcod,
    atdocrcidnom     like datmlcl.cidnom,
    atdocrufdcod     like datmlcl.ufdcod,
    atddstcidnom     like datmassistpassag.atddstcidnom,
    atddstufdcod     like datmassistpassag.atddstufdcod,
    operacao         char (01)                    ,
    atdrsdflg        like datmservico.atdrsdflg
 end record

 define mr_geral     record
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        ligcvntip    like datmligacao.ligcvntip,
        succod       like datrligapol.succod,
        ramcod       like datrservapol.ramcod,
        aplnumdig    like datrligapol.aplnumdig,
        itmnumdig    like datrligapol.itmnumdig,
        acao         char(03),
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        c24astcod    like datkassunto.c24astcod,
        solnom       char(15),
        atdsrvorg    like datmservico.atdsrvorg,
        edsnumref    like datrligapol.edsnumref,
        fcapacorg    like datrligpac.fcapacorg,
        fcapacnum    like datrligpac.fcapacnum,
        lignum       like datmligacao.lignum,
        soltip       char(01),
        c24soltipcod like datmligacao.c24soltipcod,
        lclocodesres char(01),
        itaciacod    like datrligitaaplitm.itaciacod
 end record

 define a_cts63m00   array[2] of record
    operacao         char (01)                    ,
    lclidttxt        like datmlcl.lclidttxt       ,
    lgdtxt           char (65)                    ,
    lgdtip           like datmlcl.lgdtip          ,
    lgdnom           like datmlcl.lgdnom          ,
    lgdnum           like datmlcl.lgdnum          ,
    brrnom           like datmlcl.brrnom          ,
    lclbrrnom        like datmlcl.lclbrrnom       ,
    endzon           like datmlcl.endzon          ,
    cidnom           like datmlcl.cidnom          ,
    ufdcod           like datmlcl.ufdcod          ,
    lgdcep           like datmlcl.lgdcep          ,
    lgdcepcmp        like datmlcl.lgdcepcmp       ,
    lclltt           like datmlcl.lclltt          ,
    lcllgt           like datmlcl.lcllgt          ,
    dddcod           like datmlcl.dddcod          ,
    lcltelnum        like datmlcl.lcltelnum       ,
    lclcttnom        like datmlcl.lclcttnom       ,
    lclrefptotxt     like datmlcl.lclrefptotxt    ,
    c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
    ofnnumdig        like sgokofi.ofnnumdig       ,
    emeviacod        like datmlcl.emeviacod       ,
    celteldddcod     like datmlcl.celteldddcod    ,
    celtelnum        like datmlcl.celtelnum       ,
    endcmp           like datmlcl.endcmp
 end record

 define arr_aux      smallint

 define a_passag     array[15] of record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define
   aux_today         char (10),
   aux_hora          char (05),
   ws_cgccpfnum      like aeikcdt.cgccpfnum,
   ws_cgccpfdig      like aeikcdt.cgccpfdig,
   m_resultado       smallint  ,
   m_mensagem        char(100)  ,
   m_srv_acionado    smallint


 define mr_hotel record
                 hsphotnom     like datmhosped.hsphotnom
                ,hsphotend     like datmhosped.hsphotend
                ,hsphotbrr     like datmhosped.hsphotbrr
                ,hsphotuf      like datmhosped.hsphotuf
                ,hsphotcid     like datmhosped.hsphotcid
                ,hsphottelnum  like datmhosped.hsphottelnum
                ,hsphotcttnom  like datmhosped.hsphotcttnom
                ,hsphotdiavlr  like datmhosped.hsphotdiavlr
                ,hsphotacmtip  like datmhosped.hsphotacmtip
                ,obsdes        like datmhosped.obsdes
                ,hsphotrefpnt  like datmhosped.hsphotrefpnt
             end record

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

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod,
        m_cts63m00_prep smallint

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define mr_retorno record
        erro    smallint
       ,mens    char(100)
  end record



function cts63m00_prepare()

define l_sql char(1000)

let l_sql = " update datmservico ",
            " set c24opemat = ? ",
            " where atdsrvnum = ? ",
            " and atdsrvano = ? "
prepare p_cts63m00_001 from l_sql


let l_sql = " select nom,vclcoddig,vcldes,vclanomdl,vcllicnum, ",
            " corsus,cornom,vclcorcod,funmat,atddat,atdhor, ",
            " atdlibflg,atdlibhor,atdlibdat,atdhorpvt, " ,
            " atdpvtretflg,atddatprg,atdhorprg,atdfnlflg, ",
            " atdcstvlr,atdprinvlcod,ciaempcod, empcod ",             #Raul, Biz
            " from datmservico ",
            " where atdsrvnum = ?  " ,
            " and atdsrvano = ? "
prepare p_cts63m00_002 from l_sql
declare c_cts63m00_002 cursor for p_cts63m00_002

let l_sql = " select ofnnumdig     ",
            " from datmlcl        ",
            " where atdsrvano = ? ",
            " and atdsrvnum =   ? ",
            " and c24endtip = 1   "
prepare p_cts63m00_003 from l_sql
declare c_cts63m00_003 cursor for p_cts63m00_003

let l_sql = " select datmassistpassag.refatdsrvnum, ",
            " datmassistpassag.refatdsrvano, ",
            " datmassistpassag.asimtvcod   , ",
            " datmhosped.hpddiapvsqtd      , ",
            " datmhosped.hpdqrtqtd         , ",
            " datmservico.atdsrvorg, ",
            " datmhosped.hspsegsit ",
            " from datmassistpassag, datmhosped, outer datmservico ",
            " where datmassistpassag.atdsrvnum = ? and ",
            "      datmassistpassag.atdsrvano =  ? and ",
            "      datmassistpassag.atdsrvnum = datmhosped.atdsrvnum   and ",
            "      datmassistpassag.atdsrvano = datmhosped.atdsrvano   and ",
            "      datmservico.atdsrvnum = datmassistpassag.refatdsrvnum and ",
            "      datmservico.atdsrvano = datmassistpassag.refatdsrvano "
prepare p_cts63m00_004 from l_sql
declare c_cts63m00_004 cursor for p_cts63m00_004

let l_sql = " select asimtvdes  ",
            " from datkasimtv   ",
            " where asimtvcod = ? "
prepare p_cts63m00_005 from l_sql
declare c_cts63m00_005 cursor for p_cts63m00_005

let l_sql = " select pasnom, pasidd, passeq ",
           " from datmpassageiro",
           " where atdsrvnum = ? ",
           " and atdsrvano =  ? ",
           " order by passeq    "
prepare p_cts63m00_006 from l_sql
declare c_cts63m00_006 cursor for p_cts63m00_006

let l_sql = " select ligcvntip, ",
            " c24solnom, c24astcod ",
            " from datmligacao ",
            " where lignum = ?  "
prepare p_cts63m00_007 from l_sql
declare c_cts63m00_007 cursor for p_cts63m00_007

let l_sql = " select count(*) ",
            " from datmligfrm ",
            " where lignum = ? "
prepare p_cts63m00_008 from l_sql
declare c_cts63m00_008 cursor for p_cts63m00_008

let l_sql = " select funnom, dptsgl   ",
            " from isskfunc ",
            " where empcod = ? ",                                     #Raul, Biz
            " and funmat = ? "
prepare p_cts63m00_009 from l_sql
declare c_cts63m00_009 cursor for p_cts63m00_009

let l_sql = " select cpodes  ",
            " from iddkdominio ",
            " where cponom = 'vclcorcod'  and ",
            " cpocod = ? "
prepare p_cts63m00_010 from l_sql
declare c_cts63m00_010 cursor for p_cts63m00_010

let l_sql = " select cpodes   ",
            " from iddkdominio ",
            " where cponom = 'atdprinvlcod' ",
            "  and cpocod = ? "
prepare p_cts63m00_011 from l_sql
declare c_cts63m00_011 cursor for p_cts63m00_011

let l_sql = " update datmservico set ( nom           , ",
                                       " corsus        , ",
                                       " cornom        , ",
                                       " vclcoddig     , ",
                                       " vcldes        , ",
                                       " vclanomdl     , ",
                                       " vcllicnum     , ",
                                       " vclcorcod     , ",
                                       " atdlibflg     , ",
                                       " atdlibdat     , ",
                                       " atdlibhor     , ",
                                       " atdhorpvt     , ",
                                       " atddatprg     , ",
                                       " atdhorprg     , ",
                                       " atdpvtretflg  , ",
                                       " asitipcod     , ",
                                       " atdprinvlcod  ) ",
                                       " = ( ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,13,?) ",
                    " where atdsrvnum = ?  and ",
                    "       atdsrvano = ? "
prepare p_cts63m00_012 from l_sql

let l_sql = " update datmassistpassag set ",
            " ( refatdsrvnum , ",
            "  refatdsrvano , ",
            "  asimtvcod    , ",
            "  atddmccidnom , ",
            "  atddmcufdcod , ",
            "  atddstcidnom , ",
            "  atddstufdcod ) ",
            "    = ( ?,?,?,?,?,?,?) ",
            " where atdsrvnum = ? ",
            " and   atdsrvano = ?  "
prepare p_cts63m00_013 from l_sql

let l_sql = " update datmhosped set ",
            " (hpddiapvsqtd, ",
            "  hpdqrtqtd   ) ",
            "   = (?,?)      ",
            "where atdsrvnum = ?  and ",
            "      atdsrvano = ? "
prepare p_cts63m00_014 from l_sql

let l_sql = " delete from datmpassageiro ",
            " where atdsrvnum = ? " ,
            " and atdsrvano =   ? "
prepare p_cts63m00_015 from l_sql

let l_sql = "select max(passeq)  ",
             "  from datmpassageiro ",
             " where atdsrvnum =  ? ",
             " and atdsrvano =  ? "
prepare p_cts63m00_016 from l_sql
declare c_cts63m00_016 cursor for p_cts63m00_016

let l_sql = "insert into datmpassageiro (atdsrvnum, ",
            "         atdsrvano, ",
            "         passeq, ",
            "         pasnom, ",
            "         pasidd) ",
            " values (?,?,?,?,?) "
prepare p_cts63m00_017 from l_sql

let m_cts63m00_prep = true

end function





#-----------------------------#
function cts63m00()
#-----------------------------#

 define lr_parametro record
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        ligcvntip    like datmligacao.ligcvntip,
        succod       like datrligapol.succod,
        ramcod       like datrservapol.ramcod,
        aplnumdig    like datrligapol.aplnumdig,
        itmnumdig    like datrligapol.itmnumdig,
        acao         char(03),
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        c24astcod    like datkassunto.c24astcod,
        solnom       char(15),
        atdsrvorg    like datmservico.atdsrvorg,
        edsnumref    like datrligapol.edsnumref,
        fcapacorg    like datrligpac.fcapacorg,
        fcapacnum    like datrligpac.fcapacnum,
        lignum       like datmligacao.lignum,
        soltip       char(01),
        c24soltipcod like datmligacao.c24soltipcod,
        lclocodesres char(01)
 end record

 define ws           record
    vclchsinc        like abbmveic.vclchsinc,
    vclchsfnl        like abbmveic.vclchsfnl,
    confirma         char (01),
    grvflg           smallint
 end record

 define l_azlaplcod  integer,
        l_resultado  smallint,
        l_mensagem   char(80),
        l_anomod     char(4),
        l_null       char(1)

#--------------------------------#
 define l_data       date,
        l_hora2      datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
  let l_azlaplcod  = null
  let l_resultado  = null
  let l_mensagem   = null
  let l_null = null

  initialize  ws.*  to  null
  initialize  mr_geral.*  to  null

  initialize mr_veiculo.*  to null
  initialize mr_segurado.* to null
  initialize mr_corretor.* to null
  initialize m_subbairro to null

  let g_documento.atdsrvorg = 3

 let int_flag   = false

 initialize d_cts63m00.* to null
 initialize w_cts63m00.* to null
 initialize mr_hotel to null

 initialize a_cts63m00 to null
 initialize a_passag   to null

 let lr_parametro.atdsrvnum    = g_documento.atdsrvnum
 let lr_parametro.atdsrvano    = g_documento.atdsrvano
 let lr_parametro.ligcvntip    = g_documento.ligcvntip
 let lr_parametro.succod       = g_documento.succod
 let lr_parametro.ramcod       = g_documento.ramcod
 let lr_parametro.aplnumdig    = g_documento.aplnumdig
 let lr_parametro.itmnumdig    = g_documento.itmnumdig
 let lr_parametro.acao         = g_documento.acao
 let lr_parametro.prporg       = g_documento.prporg
 let lr_parametro.prpnumdig    = g_documento.prpnumdig
 let lr_parametro.c24astcod    = g_documento.c24astcod
 let lr_parametro.solnom       = g_documento.solnom
 let lr_parametro.edsnumref    = g_documento.edsnumref
 let lr_parametro.fcapacorg    = g_documento.fcapacorg
 let lr_parametro.fcapacnum    = g_documento.fcapacnum
 let lr_parametro.lignum       = g_documento.lignum
 let lr_parametro.soltip       = g_documento.soltip
 let lr_parametro.c24soltipcod = g_documento.c24soltipcod
 let lr_parametro.lclocodesres = g_documento.lclocodesres

 let g_documento.atdsrvorg    = 3

 #display "g_documento.atdsrvnum = ",g_documento.atdsrvnum
 #display "g_documento.atdsrvano = ",g_documento.atdsrvano

 let mr_geral.atdsrvnum    = lr_parametro.atdsrvnum
 let mr_geral.atdsrvano    = lr_parametro.atdsrvano
 let mr_geral.ligcvntip    = lr_parametro.ligcvntip
 let mr_geral.succod       = lr_parametro.succod
 let mr_geral.ramcod       = lr_parametro.ramcod
 let mr_geral.aplnumdig    = lr_parametro.aplnumdig
 let mr_geral.itmnumdig    = lr_parametro.itmnumdig
 let mr_geral.acao         = lr_parametro.acao
 let mr_geral.prporg       = lr_parametro.prporg
 let mr_geral.prpnumdig    = lr_parametro.prpnumdig
 let mr_geral.c24astcod    = lr_parametro.c24astcod
 let mr_geral.solnom       = lr_parametro.solnom
 let mr_geral.edsnumref    = lr_parametro.edsnumref
 let mr_geral.fcapacorg    = lr_parametro.fcapacorg
 let mr_geral.fcapacnum    = lr_parametro.fcapacnum
 let mr_geral.lignum       = lr_parametro.lignum
 let mr_geral.soltip       = lr_parametro.soltip
 let mr_geral.c24soltipcod = lr_parametro.c24soltipcod
 let mr_geral.lclocodesres = lr_parametro.lclocodesres

 let m_c24lclpdrcod = null


 call cts40g03_data_hora_banco(2)
     returning l_data,
               l_hora2

 if m_cts63m00_prep = false or
    m_cts63m00_prep is null then
    call cts63m00_prepare()
 end if



 let aux_today       = l_data
 let aux_hora        = l_hora2
 let w_cts63m00.data = l_data
 let w_cts63m00.hora = l_hora2
 let w_cts63m00.ano  = w_cts63m00.data[9,10]
 let m_resultado     = null
 let m_mensagem      = null
 let m_srv_acionado  = false

 open window cts63m00 at 04,02 with form "cts63m00"
    attribute(form line 1)

 display "Itau Auto" to msg_itau attribute(reverse)

 display "/" at 7,50
 display "-" at 7,58
 let w_cts63m00.ligcvntip = mr_geral.ligcvntip

 if mr_geral.atdsrvnum is not null  and
    mr_geral.atdsrvano is not null  then
    call cts63m00_consulta()

    display by name d_cts63m00.*
    display by name d_cts63m00.c24solnom attribute (reverse)
    display by name mr_hotel.hsphotnom
                   ,mr_hotel.hsphotbrr
                   ,mr_hotel.hsphotcid
                   ,mr_hotel.hsphotrefpnt
                   ,mr_hotel.hsphottelnum
                   ,mr_hotel.hsphotcttnom

    if d_cts63m00.atdlibflg = "N"   then
       display by name d_cts63m00.atdlibdat attribute (invisible)
       display by name d_cts63m00.atdlibhor attribute (invisible)
    end if

    if w_cts63m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja acionado!"
       let m_srv_acionado = true
    end if

    call cts63m00_modifica() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null then
       call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                     g_issk.funmat, w_cts63m00.data, w_cts63m00.hora)
       let g_rec_his = true
    end if
 else


 if g_documento.aplnumdig is not null then


     # Busca do nome do corretor
    call cty22g00_busca_nome_corretor()
         returning d_cts63m00.cornom



       let l_anomod = g_doc_itau[1].autmodano

       let d_cts63m00.nom       = g_doc_itau[1].segnom clipped
       let d_cts63m00.corsus    = g_doc_itau[1].corsus clipped
       let d_cts63m00.vcldes =  g_doc_itau[1].autfbrnom clipped , "-",
                                g_doc_itau[1].autlnhnom clipped, " - "  ,
                                g_doc_itau[1].autmodnom clipped
       let d_cts63m00.vclanomdl = l_anomod
       let d_cts63m00.vcllicnum = g_doc_itau[1].autplcnum clipped
       let d_cts63m00.vclcordes = g_doc_itau[1].autcornom
       let d_cts63m00.vclcoddig = g_doc_itau[1].porvclcod clipped
 end if

    if mr_geral.succod    is not null and
       mr_geral.ramcod    is not null and
       mr_geral.aplnumdig is not null and
       mr_geral.itmnumdig is not null then
       let d_cts63m00.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",#"&&", projeto succod
                                        " ", mr_geral.ramcod    using "##&&",
                                        " ", mr_geral.aplnumdig using "<<<<<<<<&"
    end if

    let d_cts63m00.c24solnom = mr_geral.solnom

    display by name d_cts63m00.*
    display by name d_cts63m00.c24solnom attribute (reverse)

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call cts63m00_inclui()
         returning ws.grvflg

    if ws.grvflg = true  then
       call cts10n00(w_cts63m00.atdsrvnum, w_cts63m00.atdsrvano,
                     g_issk.funmat, w_cts63m00.data, w_cts63m00.hora)

       #-----------------------------------------------
       # Desbloqueio do servico
       #-----------------------------------------------
       if w_cts63m00.atdfnlflg = "N"  or
          w_cts63m00.atdfnlflg = "A" then


          whenever error continue
          execute p_cts63m00_001 using l_null,
                                       w_cts63m00.atdsrvnum,
                                       w_cts63m00.atdsrvano
          whenever error stop

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts63m00.atdsrvnum,w_cts63m00.atdsrvano)
          end if
       end if

    end if
 end if

 close window cts63m00

end function

#---------------------------------------------------------------
 function cts63m00_consulta()
#---------------------------------------------------------------

 define ws           record
    passeq           like datmpassageiro.passeq,
    funmat           like isskfunc.funmat,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl,
    sqlcode          integer,
    succod           like datrservapol.succod   ,
    ramcod           like datrservapol.ramcod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapcorg         like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum,
    empcod           like datmservico.empcod                          #Raul, Biz
 end record

 define l_hpddiapvsqtd like datmhosped.hpddiapvsqtd
       ,l_hpdqrtqtd    like datmhosped.hpdqrtqtd
       ,l_count        smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  ws.*  to  null
 initialize mr_hotel to null
 let l_count = null

 whenever error continue
 open c_cts63m00_002 using mr_geral.atdsrvnum,
                           mr_geral.atdsrvano
 fetch c_cts63m00_002 into d_cts63m00.nom      ,
                           d_cts63m00.vclcoddig,
                           d_cts63m00.vcldes   ,
                           d_cts63m00.vclanomdl,
                           d_cts63m00.vcllicnum,
                           d_cts63m00.corsus   ,
                           d_cts63m00.cornom   ,
                           w_cts63m00.vclcorcod,
                           ws.funmat           ,
                           w_cts63m00.atddat   ,
                           w_cts63m00.atdhor   ,
                           d_cts63m00.atdlibflg,
                           d_cts63m00.atdlibhor,
                           d_cts63m00.atdlibdat,
                           w_cts63m00.atdhorpvt,
                           w_cts63m00.atdpvtretflg,
                           w_cts63m00.atddatprg,
                           w_cts63m00.atdhorprg,
                           w_cts63m00.atdfnlflg,
                           w_cts63m00.atdcstvlr,
                           d_cts63m00.atdprinvlcod,
                           g_documento.ciaempcod,
                           ws.empcod                                  #Raul, Biz
 whenever error stop


 if sqlca.sqlcode = notfound then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

close c_cts63m00_002

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(mr_geral.atdsrvnum,
                         mr_geral.atdsrvano,
                         1)
               returning a_cts63m00[1].lclidttxt   ,
                         a_cts63m00[1].lgdtip      ,
                         a_cts63m00[1].lgdnom      ,
                         a_cts63m00[1].lgdnum      ,
                         a_cts63m00[1].lclbrrnom   ,
                         a_cts63m00[1].brrnom      ,
                         a_cts63m00[1].cidnom      ,
                         a_cts63m00[1].ufdcod      ,
                         a_cts63m00[1].lclrefptotxt,
                         a_cts63m00[1].endzon      ,
                         a_cts63m00[1].lgdcep      ,
                         a_cts63m00[1].lgdcepcmp   ,
                         a_cts63m00[1].lclltt      ,
                         a_cts63m00[1].lcllgt      ,
                         a_cts63m00[1].dddcod      ,
                         a_cts63m00[1].lcltelnum   ,
                         a_cts63m00[1].lclcttnom   ,
                         a_cts63m00[1].c24lclpdrcod,
                         a_cts63m00[1].celteldddcod,
                         a_cts63m00[1].celtelnum   ,
                         a_cts63m00[1].endcmp   ,
                         ws.sqlcode                ,
                         a_cts63m00[1].emeviacod

 let m_subbairro[1].lclbrrnom = a_cts63m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts63m00[1].brrnom,
                                a_cts63m00[1].lclbrrnom)
      returning a_cts63m00[1].lclbrrnom

 whenever error continue
 open c_cts63m00_003 using mr_geral.atdsrvano,
                           mr_geral.atdsrvnum
 fetch c_cts63m00_003 into a_cts63m00[1].ofnnumdig
 whenever error stop

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local",
          " de ocorrencia. AVISE A INFORMATICA!"
    return
 end if
  close c_cts63m00_003

 let a_cts63m00[1].lgdtxt = a_cts63m00[1].lgdtip clipped, " ",
                            a_cts63m00[1].lgdnom clipped, " ",
                            a_cts63m00[1].lgdnum using "<<<<#"

#---------------------------------------------------------------
# Obtencao dos dados da ASSISTENCIA A PASSAGEIROS
#---------------------------------------------------------------


 whenever error continue
 open c_cts63m00_004 using mr_geral.atdsrvnum,
                           mr_geral.atdsrvano

 fetch c_cts63m00_004 into d_cts63m00.refatdsrvnum      ,
                           d_cts63m00.refatdsrvano      ,
                           d_cts63m00.asimtvcod         ,
                           d_cts63m00.hpddiapvsqtd      ,
                           d_cts63m00.hpdqrtqtd         ,
                           d_cts63m00.refatdsrvorg      ,
                           d_cts63m00.seghospedado
 whenever error stop

 #display "sqlca.sqlcode = ",sqlca.sqlcode
 if sqlca.sqlcode = notfound then
    error " Assistencia a passageiros nao encontrado. AVISE A INFORMATICA!"
    return
 end if
 close c_cts63m00_004

#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------
 let d_cts63m00.asimtvdes = "*** NAO PREVISTO ***"

 whenever error continue
 open c_cts63m00_005 using d_cts63m00.asimtvcod
 fetch c_cts63m00_005 into d_cts63m00.asimtvdes
 whenever error stop
 close c_cts63m00_005



#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 whenever error continue
 open c_cts63m00_006 using mr_geral.atdsrvnum,
                           mr_geral.atdsrvano

 let arr_aux = 1

 foreach c_cts63m00_006 into a_passag[arr_aux].pasnom,
                           a_passag[arr_aux].pasidd,
                           ws.passeq

    let arr_aux = arr_aux + 1

    if arr_aux > 5 then
       error " Limite excedido. Foram encontrados mais de 5 passageiros!"
       exit foreach
    end if

 end foreach
 whenever error stop
 close c_cts63m00_006

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 let w_cts63m00.lignum = cts20g00_servico(mr_geral.atdsrvnum,
                                          mr_geral.atdsrvano)

 call cts20g01_docto(w_cts63m00.lignum)
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




 if mr_geral.succod    is not null  and
    mr_geral.ramcod    is not null  and
    mr_geral.aplnumdig is not null  then
    let d_cts63m00.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",#"&&", projeto succod
                                     " ", mr_geral.ramcod    using "##&&",
                                     " ", mr_geral.aplnumdig using "<<<<<<<<&"
 end if

 whenever error continue
 open c_cts63m00_007 using w_cts63m00.lignum
 fetch c_cts63m00_007 into w_cts63m00.ligcvntip,
                           d_cts63m00.c24solnom, mr_geral.c24astcod
 whenever error stop


 whenever error continue
  open c_cts63m00_008 using w_cts63m00.lignum
  fetch c_cts63m00_008 into l_count
 whenever error stop

 close c_cts63m00_008

 if l_count = 0 then
    let d_cts63m00.frmflg = "N"
 else
    let d_cts63m00.frmflg = "S"
 end if


#---------------------------------------------------------------
# Identificacao do ATENDENTE
#---------------------------------------------------------------

 let ws.funnom = "*** NAO CADASTRADO ***"

 whenever error continue
  open c_cts63m00_009 using ws.empcod,                                #Raul, Biz
                            ws.funmat
  fetch c_cts63m00_009 into ws.funnom, ws.dptsgl
 whenever error stop

 let d_cts63m00.atdtxt = w_cts63m00.atddat         clipped, " ",
                         w_cts63m00.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

#---------------------------------------------------------------
# Descricao da COR do veiculo
#---------------------------------------------------------------

 whenever error continue
  open c_cts63m00_010 using w_cts63m00.vclcorcod
  fetch c_cts63m00_010 into d_cts63m00.vclcordes
 whenever error stop


 if w_cts63m00.atdhorpvt is not null  or
    w_cts63m00.atdhorpvt =  "00:00"   then
    let d_cts63m00.imdsrvflg = "S"
 end if

 if w_cts63m00.atddatprg is not null   then
    let d_cts63m00.imdsrvflg = "N"
 end if

 if d_cts63m00.atdlibflg = "N"  then
    let d_cts63m00.atdlibdat = w_cts63m00.atddat
    let d_cts63m00.atdlibhor = w_cts63m00.atdhor
 end if

 let w_cts63m00.antlibflg = d_cts63m00.atdlibflg

 let d_cts63m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 let m_c24lclpdrcod = a_cts63m00[1].c24lclpdrcod

 whenever error continue
  open c_cts63m00_011 using d_cts63m00.atdprinvlcod
  fetch c_cts63m00_011 into d_cts63m00.atdprinvldes
 whenever error stop
 close c_cts63m00_011

 call cts22m01_selecionar(1
                         ,mr_geral.atdsrvnum
                         ,mr_geral.atdsrvano)
     returning m_resultado
              ,m_mensagem
              ,mr_hotel.hsphotnom
              ,mr_hotel.hsphotend
              ,mr_hotel.hsphotbrr
              ,mr_hotel.hsphotuf
              ,mr_hotel.hsphotcid
              ,mr_hotel.hsphottelnum
              ,mr_hotel.hsphotcttnom
              ,mr_hotel.hsphotdiavlr
              ,mr_hotel.hsphotacmtip
              ,mr_hotel.obsdes
              ,mr_hotel.hsphotrefpnt
              ,l_hpddiapvsqtd
              ,l_hpdqrtqtd

end function  ###  cts63m00_consulta

#---------------------------------------------------------------
 function cts63m00_modifica()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    sqlcode          integer
 end record

 define hist_cts63m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key   char (01)
 define w_retorno    smallint

 define l_data       date,
        l_hora2      datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null
        let     w_retorno  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts63m00.*  to  null

        let     prompt_key  =  null
        let     w_retorno  =  null

        initialize  ws.*  to  null

        initialize  hist_cts63m00.*  to  null

 initialize ws.*  to null

 call cts63m00_input() returning hist_cts63m00.*

 if d_cts63m00.seghospedado = 'S' then
    call cts22m01_gravar('M'
                        ,mr_geral.atdsrvnum
                        ,mr_geral.atdsrvano
                        ,d_cts63m00.hpddiapvsqtd
                        ,d_cts63m00.hpdqrtqtd
                        ,mr_hotel.hsphotnom
                        ,mr_hotel.hsphotend
                        ,mr_hotel.hsphotbrr
                        ,mr_hotel.hsphotuf
                        ,mr_hotel.hsphotcid
                        ,mr_hotel.hsphottelnum
                        ,mr_hotel.hsphotcttnom
                        ,mr_hotel.hsphotacmtip
                        ,mr_hotel.obsdes
                        ,mr_hotel.hsphotrefpnt)
      returning m_resultado
               ,m_mensagem

    if m_resultado = 3 then
        error m_mensagem
    end if
 end if

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts63m00      to null
    initialize a_passag        to null
    initialize d_cts63m00.*    to null
    initialize w_cts63m00.*    to null
    clear form
    return false
 end if

 whenever error continue

 begin work

 whenever error continue
 execute p_cts63m00_012 using d_cts63m00.nom,
                              d_cts63m00.corsus,
                              d_cts63m00.cornom,
                              d_cts63m00.vclcoddig,
                              d_cts63m00.vcldes,
                              d_cts63m00.vclanomdl,
                              d_cts63m00.vcllicnum,
                              w_cts63m00.vclcorcod,
                              d_cts63m00.atdlibflg,
                              d_cts63m00.atdlibdat,
                              d_cts63m00.atdlibhor,
                              w_cts63m00.atdhorpvt,
                              w_cts63m00.atddatprg,
                              w_cts63m00.atdhorprg,
                              w_cts63m00.atdpvtretflg,
                              d_cts63m00.atdprinvlcod,
                              mr_geral.atdsrvnum,
                              mr_geral.atdsrvano
whenever error stop

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do servico.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 whenever error continue
 execute p_cts63m00_013 using d_cts63m00.refatdsrvnum,
                              d_cts63m00.refatdsrvano,
                              d_cts63m00.asimtvcod   ,
                              w_cts63m00.atddmccidnom,
                              w_cts63m00.atddmcufdcod,
                              w_cts63m00.atddstcidnom,
                              w_cts63m00.atddstufdcod,
                              mr_geral.atdsrvnum,
                              mr_geral.atdsrvano
whenever error stop

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da assistencia.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

whenever error continue
execute p_cts63m00_014 using d_cts63m00.hpddiapvsqtd,
                             d_cts63m00.hpdqrtqtd,
                             mr_geral.atdsrvnum,
                             mr_geral.atdsrvano


whenever error stop

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da hospedagem.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

whenever error stop
execute p_cts63m00_015 using mr_geral.atdsrvnum,
                             mr_geral.atdsrvano
whenever error stop

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na substituicao da relacao de",
          " passageiros. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 5
    if a_passag[arr_aux].pasnom is null  or
       a_passag[arr_aux].pasidd is null  then
       exit for
    end if

    initialize ws.passeq to null

    whenever error continue
    open c_cts63m00_016 using mr_geral.atdsrvnum,
                              mr_geral.atdsrvano
    fetch c_cts63m00_016 into ws.passeq
    whenever error stop

    if sqlca.sqlcode < 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do ultimo",
             " passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if

    if ws.passeq is null  then
       let ws.passeq = 0
    end if

    let ws.passeq = ws.passeq + 1

    whenever error continue
    execute p_cts63m00_017 using mr_geral.atdsrvnum,
                                 mr_geral.atdsrvano,
                                 ws.passeq,
                                 a_passag[arr_aux].pasnom,
                                 a_passag[arr_aux].pasidd
    whenever error stop


    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao do ",
               arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 for arr_aux = 1 to 1
    if a_cts63m00[arr_aux].operacao is null  then
       let a_cts63m00[arr_aux].operacao = "M"
    end if
    let  a_cts63m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    call cts06g07_local(a_cts63m00[arr_aux].operacao,
                        mr_geral.atdsrvnum,
                        mr_geral.atdsrvano,
                        arr_aux,
                        a_cts63m00[arr_aux].lclidttxt,
                        a_cts63m00[arr_aux].lgdtip,
                        a_cts63m00[arr_aux].lgdnom,
                        a_cts63m00[arr_aux].lgdnum,
                        a_cts63m00[arr_aux].lclbrrnom,
                        a_cts63m00[arr_aux].brrnom,
                        a_cts63m00[arr_aux].cidnom,
                        a_cts63m00[arr_aux].ufdcod,
                        a_cts63m00[arr_aux].lclrefptotxt,
                        a_cts63m00[arr_aux].endzon,
                        a_cts63m00[arr_aux].lgdcep,
                        a_cts63m00[arr_aux].lgdcepcmp,
                        a_cts63m00[arr_aux].lclltt,
                        a_cts63m00[arr_aux].lcllgt,
                        a_cts63m00[arr_aux].dddcod,
                        a_cts63m00[arr_aux].lcltelnum,
                        a_cts63m00[arr_aux].lclcttnom,
                        a_cts63m00[arr_aux].c24lclpdrcod,
                        a_cts63m00[arr_aux].ofnnumdig,
                        a_cts63m00[arr_aux].emeviacod,
                        a_cts63m00[arr_aux].celteldddcod,
                        a_cts63m00[arr_aux].celtelnum,
                        a_cts63m00[arr_aux].endcmp   )
              returning ws.sqlcode

    if ws.sqlcode is null   or
       ws.sqlcode <> 0      then
       error " Erro (", ws.sqlcode, ") na alteracao do local de ocorrencia.",
             " AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if w_cts63m00.antlibflg <> d_cts63m00.atdlibflg  then
    if d_cts63m00.atdlibflg = "S"  then
       let w_cts63m00.atdetpcod = 1
       let ws.atdetpdat = d_cts63m00.atdlibdat
       let ws.atdetphor = d_cts63m00.atdlibhor
    else
       let w_cts63m00.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(mr_geral.atdsrvnum,
                               mr_geral.atdsrvano,
                               w_cts63m00.atdetpcod,
                               " ",
                               " ",
                               " ",
                               " ") returning w_retorno



    if w_retorno <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de",
             " acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if
 whenever error stop

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts63m00[1].cidnom,
                          a_cts63m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         mr_geral.c24astcod,
                                         13,   #d_cts63m00.asitipcod,
                                         a_cts63m00[1].lclltt,
                                         a_cts63m00[1].lcllgt,
                                         "",
                                         d_cts63m00.frmflg,
                                         mr_geral.atdsrvnum,
                                         mr_geral.atdsrvano,
                                         " ",
                                         "", "") then
        #servico nao pode ser acionado automaticamente
     end if
  end if

 commit work
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(mr_geral.atdsrvnum,
                             mr_geral.atdsrvano)

 return true

end function

#-------------------------------
 function cts63m00_inclui()
#-------------------------------

 define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat           like datmligfrm.caddat    ,
        cadhor           like datmligfrm.cadhor    ,
        cademp           like datmligfrm.cademp    ,
        cadmat           like datmligfrm.cadmat    ,
        atdetpdat        like datmsrvacp.atdetpdat ,
        atdetphor        like datmsrvacp.atdetphor ,
        etpfunmat        like datmsrvacp.funmat    ,
        atdsrvseq        like datmsrvacp.atdsrvseq ,
        passeq           like datmpassageiro.passeq,
        ano              char (02)                 ,
        todayX           char (10)                 ,
        histerr          smallint                  ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        c24trxnum       like dammtrx.c24trxnum     ,  # Msg pager/email
        lintxt          like dammtrxtxt.c24trxtxt
 end record

 define hist_cts63m00    record
        hist1            like datmservhist.c24srvdsc,
        hist2            like datmservhist.c24srvdsc,
        hist3            like datmservhist.c24srvdsc,
        hist4            like datmservhist.c24srvdsc,
        hist5            like datmservhist.c24srvdsc
 end record

 define l_data       date,
        l_hora2      datetime hour to minute

        initialize  ws.*  to  null
        initialize  hist_cts63m00.*  to  null



 while true
   initialize ws.*  to null

   let g_documento.acao    = "INC"
   let w_cts63m00.operacao = "i"

   call cts63m00_input() returning hist_cts63m00.*

   if  int_flag then
       let int_flag  =  false
       initialize a_cts63m00      to null
       initialize a_passag        to null
       initialize d_cts63m00.*    to null
       initialize w_cts63m00.*    to null
       initialize hist_cts63m00.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
   if  w_cts63m00.data is null  or
       w_cts63m00.hora is null  then
       let w_cts63m00.data   = l_data
       let w_cts63m00.hora   = l_hora2
   end if

   if  w_cts63m00.funmat is null  then
       let w_cts63m00.funmat = g_issk.funmat
   end if

   if  d_cts63m00.frmflg = "S"  then
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

   let ws.todayX  = l_data
   let ws.ano    = ws.todayX[9,10]


   if  w_cts63m00.atdfnlflg is null  then
       let w_cts63m00.atdfnlflg = "N"
       let w_cts63m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "H" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlcode  ,
                  ws.msg

   if  ws.sqlcode = 0  then
       commit work
   else
       let ws.msg = "cts63m00 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let mr_geral.lignum      = ws.lignum
    let g_documento.lignum  = ws.lignum
   let w_cts63m00.atdsrvnum = ws.atdsrvnum
   let w_cts63m00.atdsrvano = ws.atdsrvano

   if d_cts63m00.seghospedado = 'S' then
      call cts22m01_gravar('I'
                          ,w_cts63m00.atdsrvnum
                          ,w_cts63m00.atdsrvano
                          ,d_cts63m00.hpddiapvsqtd
                          ,d_cts63m00.hpdqrtqtd
                          ,mr_hotel.hsphotnom
                          ,mr_hotel.hsphotend
                          ,mr_hotel.hsphotbrr
                          ,mr_hotel.hsphotuf
                          ,mr_hotel.hsphotcid
                          ,mr_hotel.hsphottelnum
                          ,mr_hotel.hsphotcttnom
                          ,mr_hotel.hsphotacmtip
                          ,mr_hotel.obsdes
                          ,mr_hotel.hsphotrefpnt)
      returning m_resultado
               ,m_mensagem

      if m_resultado = 3 then
         error m_mensagem
      end if
   end if


  #-----------------------------------------------------
  # Grava ligacao e servico
  #-----------------------------------------------------
    begin work

    call cts10g00_ligacao ( mr_geral.lignum      ,
                            w_cts63m00.data         ,
                            w_cts63m00.hora         ,
                            mr_geral.c24soltipcod,
                            mr_geral.solnom      ,
                            mr_geral.c24astcod   ,
                            w_cts63m00.funmat       ,
                            mr_geral.ligcvntip   ,
                            g_c24paxnum             ,
                            ws.atdsrvnum            ,
                            ws.atdsrvano            ,
                            "","","",""             ,
                            mr_geral.succod      ,
                            mr_geral.ramcod      ,
                            mr_geral.aplnumdig   ,
                            mr_geral.itmnumdig   ,
                            mr_geral.edsnumref   ,
                            mr_geral.prporg      ,
                            mr_geral.prpnumdig   ,
                            mr_geral.fcapacorg   ,
                            mr_geral.fcapacnum   ,
                            "","","",""             ,
                            ws.caddat               ,
                            ws.cadhor               ,
                            ws.cademp               ,
                            ws.cadmat                )
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


   call cts10g02_grava_servico( w_cts63m00.atdsrvnum,
                                w_cts63m00.atdsrvano,
                                mr_geral.soltip  ,     # atdsoltip
                                mr_geral.solnom  ,     # c24solnom
                                w_cts63m00.vclcorcod,
                                w_cts63m00.funmat   ,
                                d_cts63m00.atdlibflg,
                                d_cts63m00.atdlibhor,
                                d_cts63m00.atdlibdat,
                                w_cts63m00.data     ,     # atddat
                                w_cts63m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts63m00.atdhorpvt,
                                w_cts63m00.atddatprg,
                                w_cts63m00.atdhorprg,
                                "H"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts63m00.atdprscod,
                                w_cts63m00.atdcstvlr,
                                w_cts63m00.atdfnlflg,
                                w_cts63m00.atdfnlhor,
                                w_cts63m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts63m00.c24opemat,
                                d_cts63m00.nom      ,
                                d_cts63m00.vcldes   ,
                                d_cts63m00.vclanomdl,
                                d_cts63m00.vcllicnum,
                                d_cts63m00.corsus   ,
                                d_cts63m00.cornom   ,
                                w_cts63m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts63m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                13,  #d_cts63m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts63m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts63m00.atdprinvlcod,
                                g_documento.atdsrvorg   ) # ATDSRVORG
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


  #-----------------------------------------------------------------------------
  # Gravacao dos dados da ASSISTENCIA A PASSAGEIROS
  #-----------------------------------------------------------------------------
    insert into DATMASSISTPASSAG ( atdsrvnum    ,
                                   atdsrvano    ,
                                   bagflg       ,
                                   refatdsrvnum ,
                                   refatdsrvano ,
                                   asimtvcod    ,
                                   atddmccidnom ,
                                   atddmcufdcod ,
                                   atddstcidnom ,
                                   atddstufdcod  )
                          values ( w_cts63m00.atdsrvnum   ,
                                   w_cts63m00.atdsrvano   ,
                                   "N"                    ,
                                   d_cts63m00.refatdsrvnum,
                                   d_cts63m00.refatdsrvano,
                                   d_cts63m00.asimtvcod   ,
                                   w_cts63m00.atddmccidnom,
                                   w_cts63m00.atddmcufdcod,
                                   w_cts63m00.atddstcidnom,
                                   w_cts63m00.atddstufdcod )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " assistencia a passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


#  #-----------------------------------------------------------------------------
#  # Gravacao dos dados da hospedagem
#  #-----------------------------------------------------------------------------
    if d_cts63m00.seghospedado = "N" then

       insert into DATMHOSPED ( atdsrvnum   ,
                                atdsrvano   ,
                                hpddiapvsqtd,
                                hpdqrtqtd,
                                hspsegsit    )
                       values ( w_cts63m00.atdsrvnum   ,
                                w_cts63m00.atdsrvano   ,
                                d_cts63m00.hpddiapvsqtd,
                                d_cts63m00.hpdqrtqtd,
                                d_cts63m00.seghospedado)

      if  sqlca.sqlcode  <>  0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao do",
                " dados da hospedagem. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.promptX
          let ws.retorno = false
          exit while
      end if

   end if

 #------------------------------------------------------------------------------
 # Gravacao dos passageiros
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 5
       if  a_passag[arr_aux].pasnom is null  or
           a_passag[arr_aux].pasidd is null  then
           exit for
       end if

       initialize ws.passeq to null

       select max(passeq)
         into ws.passeq
         from DATMPASSAGEIRO
              where atdsrvnum = w_cts63m00.atdsrvnum
                and atdsrvano = w_cts63m00.atdsrvano

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na selecao do",
                 " ultimo hospede. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       if  ws.passeq is null  then
           let ws.passeq = 0
       end if

       let ws.passeq = ws.passeq + 1

       insert into DATMPASSAGEIRO ( atdsrvnum,
                                    atdsrvano,
                                    passeq   ,
                                    pasnom   ,
                                    pasidd    )
                           values ( w_cts63m00.atdsrvnum    ,
                                    w_cts63m00.atdsrvano    ,
                                    ws.passeq               ,
                                    a_passag[arr_aux].pasnom,
                                    a_passag[arr_aux].pasidd )

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 arr_aux using "<&", "o. hospede. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for

 #------------------------------------------------------------------------------
 # Grava local de ocorrencia
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 1
       if  a_cts63m00[arr_aux].operacao is null  then
           let a_cts63m00[arr_aux].operacao = "I"
       end if
       let a_cts63m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       call cts06g07_local( a_cts63m00[arr_aux].operacao    ,
                            w_cts63m00.atdsrvnum            ,
                            w_cts63m00.atdsrvano            ,
                            arr_aux                         ,
                            a_cts63m00[arr_aux].lclidttxt   ,
                            a_cts63m00[arr_aux].lgdtip      ,
                            a_cts63m00[arr_aux].lgdnom      ,
                            a_cts63m00[arr_aux].lgdnum      ,
                            a_cts63m00[arr_aux].lclbrrnom   ,
                            a_cts63m00[arr_aux].brrnom      ,
                            a_cts63m00[arr_aux].cidnom      ,
                            a_cts63m00[arr_aux].ufdcod      ,
                            a_cts63m00[arr_aux].lclrefptotxt,
                            a_cts63m00[arr_aux].endzon      ,
                            a_cts63m00[arr_aux].lgdcep      ,
                            a_cts63m00[arr_aux].lgdcepcmp   ,
                            a_cts63m00[arr_aux].lclltt      ,
                            a_cts63m00[arr_aux].lcllgt      ,
                            a_cts63m00[arr_aux].dddcod      ,
                            a_cts63m00[arr_aux].lcltelnum   ,
                            a_cts63m00[arr_aux].lclcttnom   ,
                            a_cts63m00[arr_aux].c24lclpdrcod,
                            a_cts63m00[arr_aux].ofnnumdig   ,
                            a_cts63m00[arr_aux].emeviacod   ,
                            a_cts63m00[arr_aux].celteldddcod,
                            a_cts63m00[arr_aux].celtelnum,
                            a_cts63m00[arr_aux].endcmp)
            returning ws.sqlcode

       if  ws.sqlcode is null  or
           ws.sqlcode <> 0     then
           error " Erro (", ws.sqlcode, ") na gravacao do",
                 " local de ocorrencia. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
   select max(atdsrvseq)
     into ws.atdsrvseq
     from datmsrvacp
          where atdsrvnum = w_cts63m00.atdsrvnum
            and atdsrvano = w_cts63m00.atdsrvano

   if  ws.atdsrvseq is null  then
       let ws.atdsrvseq = 0
   end if

   if  w_cts63m00.atdetpcod is null  then
       if  d_cts63m00.atdlibflg = "S"  then
           let w_cts63m00.atdetpcod = 1
           let ws.etpfunmat = w_cts63m00.funmat
           let ws.atdetpdat = d_cts63m00.atdlibdat
           let ws.atdetphor = d_cts63m00.atdlibhor
       else
           let w_cts63m00.atdetpcod = 2
           let ws.etpfunmat = w_cts63m00.funmat
           let ws.atdetpdat = w_cts63m00.data
           let ws.atdetphor = w_cts63m00.hora
       end if
   else
       call cts10g04_insere_etapa(w_cts63m00.atdsrvnum,
                                  w_cts63m00.atdsrvano,
                                  1, "", "", "", "")
            returning ws.sqlcode

       if  ws.sqlcode  <>  0  then
           error " Erro (", ws.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts63m00.cnldat
       let ws.atdetphor = w_cts63m00.atdfnlhor
       let ws.etpfunmat = w_cts63m00.c24opemat
   end if

   call cts10g04_insere_etapa(w_cts63m00.atdsrvnum,
                              w_cts63m00.atdsrvano,
                              w_cts63m00.atdetpcod,
                              w_cts63m00.atdprscod, "", "", "")
        returning ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if mr_geral.succod    is not null  and
      mr_geral.ramcod    is not null  and
      mr_geral.aplnumdig is not null  then

      call cts10g02_grava_servico_apolice(w_cts63m00.atdsrvnum ,
                                          w_cts63m00.atdsrvano ,
                                          mr_geral.succod   ,
                                          mr_geral.ramcod   ,
                                          mr_geral.aplnumdig,
                                          mr_geral.itmnumdig,
                                          mr_geral.edsnumref)
                                returning ws.tabname,
                                          ws.sqlcode

      if  ws.sqlcode <> 0  then
          error " Erro (", ws.sqlcode, ") na gravacao do",
                " relacionamento servico x apolice. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.promptX
          let ws.retorno = false
          exit while
      end if
   else
      # este registro indica um atendimento sem documento
      if mr_geral.ramcod is not null then

         call cts10g02_grava_servico_apolice(w_cts63m00.atdsrvnum ,
                                             w_cts63m00.atdsrvano ,
                                             0,
                                             mr_geral.ramcod,
                                             0,
                                             0,
                                             0)
                                   returning ws.tabname,
                                             ws.sqlcode


         if  ws.sqlcode <> 0  then
             error " Erro (", ws.sqlcode, ") na gravacao do",
                   " relac. servico x apolice-atd.s/docto.AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.promptX
             let ws.retorno = false
             exit while
         end if
      end if
   end if

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(w_cts63m00.atdsrvnum,
                               w_cts63m00.atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( w_cts63m00.atdsrvnum,
                            w_cts63m00.atdsrvano,
                            w_cts63m00.data     ,
                            w_cts63m00.hora     ,
                            w_cts63m00.funmat   ,
                            hist_cts63m00.*      )
        returning ws.histerr

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts63m00[1].cidnom,
                          a_cts63m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         mr_geral.c24astcod,
                                         13,   #d_cts63m00.asitipcod,
                                         a_cts63m00[1].lclltt,
                                         a_cts63m00[1].lcllgt,
                                         "",
                                         d_cts63m00.frmflg,
                                         w_cts63m00.atdsrvnum,
                                         w_cts63m00.atdsrvano,
                                         " ",
                                         "", "") then
        #servico nao pode ser acionado automaticamente
     end if
  end if

  #------------------------------------------------------------------------------
  # Insere inf. de pagamentos na tabela dbscadtippgt  ## PSI207233
  #------------------------------------------------------------------------------
     if g_documento.c24astcod = "I34" then

          let g_cc.anosrv = w_cts63m00.atdsrvano
          let g_cc.nrosrv = w_cts63m00.atdsrvnum


          Insert into dbscadtippgt (anosrv,
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

     end if

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let d_cts63m00.servico = g_documento.atdsrvorg using "&&",
                            "/", w_cts63m00.atdsrvnum using "&&&&&&&",
                            "-", w_cts63m00.atdsrvano using "&&"
   display by name d_cts63m00.servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function  ###  cts63m00_inclui

#--------------------------
 function cts63m00_input()
#------------------------------

 define ws           record
    refatdsrvorg     like datmservico.atdsrvorg,
    succod           like datrservapol.succod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    segnumdig        like gsakend.segnumdig,
    atdsrvorg        like datmservico.atdsrvorg,
    vclanomdl        like datmservico.vclanomdl,
    vclcordes        char (11),
    blqnivcod        like datkblq.blqnivcod,
    vcllicant        like datmservico.vcllicnum,
    dddcod           like gsakend.dddcod,
    teltxt           like gsakend.teltxt,
    snhflg           char (01),
    retflg           char (01),
    prpflg           char (01),
    confirma         char (01),
    sqlcode          integer
 end record

 define hist_cts63m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define l_vclcoddig_contingencia like datmservico.vclcoddig

 define l_data    date,
        l_hora2   datetime hour to minute,
        l_servico like datmservico.atdsrvnum,
        l_ano     like datmservico.atdsrvano,
        l_acesso  smallint,
        l_desc_1  char(40),
        l_desc_2  char(40),
        l_clscod  like aackcls.clscod


 let l_vclcoddig_contingencia  =  null

 initialize  hist_cts63m00.*  to  null

 initialize ws.*  to null

 let ws.vcllicant = d_cts63m00.vcllicnum

 let l_vclcoddig_contingencia = d_cts63m00.vclcoddig

 input by name d_cts63m00.nom         ,
               d_cts63m00.corsus      ,
               d_cts63m00.cornom      ,
               d_cts63m00.vclcoddig   ,
               d_cts63m00.vclanomdl   ,
               d_cts63m00.vcllicnum   ,
               d_cts63m00.vclcordes   ,
               d_cts63m00.asimtvcod   ,
               d_cts63m00.refatdsrvorg,
               d_cts63m00.refatdsrvnum,
               d_cts63m00.refatdsrvano,
               d_cts63m00.seghospedado,
               d_cts63m00.hpddiapvsqtd,
               d_cts63m00.hpdqrtqtd   ,
               d_cts63m00.imdsrvflg   ,
               d_cts63m00.atdprinvlcod,
               d_cts63m00.atdlibflg   ,
               d_cts63m00.frmflg      without defaults

   before field nom
          display by name d_cts63m00.nom        attribute (reverse)

   after  field nom
          display by name d_cts63m00.nom

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                next field nom
          end if
          if d_cts63m00.nom is null  then
              error " Nome deve ser informado!"
              next field nom
          end if
           if mr_geral.atdsrvnum is null  and
              mr_geral.atdsrvano is null  then
              if mr_geral.succod    is not null  and
                 mr_geral.aplnumdig is not null  and
                 mr_geral.itmnumdig is not null  and
                 w_cts63m00.atddmccidnom is null    and
                 w_cts63m00.atddmcufdcod is null    then

                     let w_cts63m00.atddmccidnom = g_doc_itau[1].segcidnom
                     let w_cts63m00.atddmcufdcod = g_doc_itau[1].segufdsgl
              end if

             call cts11m06(w_cts63m00.atddmccidnom,
                           w_cts63m00.atddmcufdcod,
                           w_cts63m00.atdocrcidnom,
                           w_cts63m00.atdocrufdcod,
                           w_cts63m00.atddstcidnom,
                           w_cts63m00.atddstufdcod)
                 returning w_cts63m00.atddmccidnom,
                           w_cts63m00.atddmcufdcod,
                           w_cts63m00.atdocrcidnom,
                           w_cts63m00.atdocrufdcod,
                           w_cts63m00.atddstcidnom,
                           w_cts63m00.atddstufdcod

             if w_cts63m00.atddmccidnom is null  or
                w_cts63m00.atddmcufdcod is null  or
                w_cts63m00.atdocrcidnom is null  or
                w_cts63m00.atdocrufdcod is null  or
                w_cts63m00.atddstcidnom is null  or
                w_cts63m00.atddstufdcod is null  then
                error " Localidades devem ser informadas para confirmacao",
                      " do direito de utilizacao!"
                next field nom
             end if

             if w_cts63m00.atddmccidnom = w_cts63m00.atdocrcidnom  and
                w_cts63m00.atddmcufdcod = w_cts63m00.atdocrufdcod  then
                call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                              "A LOCAL DE DOMICILIO!","") returning ws.confirma
                if ws.confirma = "N"  then
                   next field nom
                end if
             end if

             let a_cts63m00[1].cidnom = w_cts63m00.atdocrcidnom
             let a_cts63m00[1].ufdcod = w_cts63m00.atdocrufdcod
          end if

          if w_cts63m00.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                   "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                  returning ws.confirma

             next field frmflg
          end if

   before field corsus
          display by name d_cts63m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts63m00.corsus

   before field cornom
          display by name d_cts63m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts63m00.cornom

   before field vclcoddig
          display by name d_cts63m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts63m00.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts63m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts63m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts63m00.vclcoddig is null  then
                call agguvcl() returning d_cts63m00.vclcoddig
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts63m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cts15g00(d_cts63m00.vclcoddig)
                 returning d_cts63m00.vcldes

             display by name d_cts63m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts63m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts63m00.vclanomdl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclcoddig
          end if

          if d_cts63m00.vclanomdl is null then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts63m00.vclcoddig,
                         d_cts63m00.vclanomdl) = false  then
                error " Veiculo nao consta como fabricado em ",
                        d_cts63m00.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts63m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts63m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts63m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

   before field vclcordes
          display by name d_cts63m00.vclcordes attribute (reverse)

   after  field vclcordes
          display by name d_cts63m00.vclcordes

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vcllicnum
          end if

          if d_cts63m00.vclcordes is not null then
             let ws.vclcordes = d_cts63m00.vclcordes[2,9]

             select cpocod into w_cts63m00.vclcorcod
               from iddkdominio
              where cponom      = "vclcorcod"  and
                    cpodes[2,9] = ws.vclcordes

             if sqlca.sqlcode = notfound  then
                error " Cor fora do padrao!"
                call c24geral4()
                     returning w_cts63m00.vclcorcod, d_cts63m00.vclcordes

                if w_cts63m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informada!"
                   next field vclcordes
                else
                   display by name d_cts63m00.vclcordes
                end if
             end if
          else
             call c24geral4()
                  returning w_cts63m00.vclcorcod, d_cts63m00.vclcordes

             if w_cts63m00.vclcorcod  is null   then
                error " Cor do veiculo deve ser informada!"
                next field  vclcordes
             else
                display by name d_cts63m00.vclcordes
             end if
          end if

          if mr_geral.atdsrvnum is null  and
             mr_geral.atdsrvano is null  then
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             call cts11m04(mr_geral.succod   , mr_geral.aplnumdig,
                           mr_geral.itmnumdig, l_data,
                           mr_geral.ramcod)
          else
             call cts11m04(mr_geral.succod   , mr_geral.aplnumdig,
                           mr_geral.itmnumdig, w_cts63m00.atddat,
                           mr_geral.ramcod)
          end if

   before field asimtvcod
          display by name d_cts63m00.asimtvcod attribute (reverse)

   after  field asimtvcod
          display by name d_cts63m00.asimtvcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts63m00.asimtvcod is null  then
                call cts11m03(13)
                    returning d_cts63m00.asimtvcod

                if d_cts63m00.asimtvcod is not null  then
                   select asimtvdes
                     into d_cts63m00.asimtvdes
                     from datkasimtv
                    where asimtvcod = d_cts63m00.asimtvcod  and
                          asimtvsit = "A"

                   display by name d_cts63m00.asimtvcod
                   display by name d_cts63m00.asimtvdes


                   next field refatdsrvorg
                end if
             else
                select asimtvdes
                  into d_cts63m00.asimtvdes
                  from datkasimtv
                 where asimtvcod = d_cts63m00.asimtvcod  and
                       asimtvsit = "A"

                if sqlca.sqlcode = notfound  then
                   error " Motivo invalido!"
                   call cts11m03(13)
                       returning d_cts63m00.asimtvcod
                   next field asimtvcod
                else
                   display by name d_cts63m00.asimtvcod
                end if

                select asimtvcod
                  from datrmtvasitip
                 where asitipcod = 13
                   and asimtvcod = d_cts63m00.asimtvcod

                if sqlca.sqlcode = notfound  then
                   error " Motivo nao pode ser informado para este tipo de",
                         " assistencia!"
                   next field asimtvcod
                end if
             end if

             display by name d_cts63m00.asimtvdes
          end if

          #if l_clscod = "37B" then
             call cts08g01("A","N","",
                           "LIMITE TOTAL POR EVENTO: "
                          ,"R$ 100,00 POR PASSAGEIRO - "
                          ,"MAXIMO DE DUAS DIARIAS DIAS.")
                  returning ws.confirma
          #end if

          if d_cts63m00.asimtvcod = 4  then   ##  Outras Situacoes
             call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
                  returning ws.confirma
          end if
          #---------------------------------------------------------------
          # Alerta Novos Correntistas
          #---------------------------------------------------------------
          if g_doc_itau[1].itaasiplncod = 3 then
            if cts12g08_valida_data_limite(g_doc_itau[1].itaasiplncod   ,
                                           g_doc_itau[1].itaaplvigincdat) then
             	   call cty37g00_valida_alerta_motivo(g_doc_itau[1].itaclisgmcod,
             	                                      d_cts63m00.asimtvcod      )
             end if
          end if

   before field refatdsrvorg
          display by name d_cts63m00.refatdsrvorg attribute (reverse)

   after  field refatdsrvorg
          display by name d_cts63m00.refatdsrvorg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field asimtvcod
          end if

          if  d_cts63m00.refatdsrvorg is null  then
           if  mr_geral.succod    is not null  and
               mr_geral.aplnumdig is not null  then

               call cts11m13(g_doc_itau[1].itaasiplncod
                            ,g_doc_itau[1].itaaplvigincdat
                            ,g_doc_itau[1].itaaplvigfnldat
                            ,g_doc_itau[1].itaciacod
                            ,g_doc_itau[1].itaramcod
                            ,g_doc_itau[1].itaaplnum
                            ,g_doc_itau[1].itaaplitmnum)
                   returning d_cts63m00.refatdsrvorg,
                             d_cts63m00.refatdsrvnum,
                             d_cts63m00.refatdsrvano,
                             l_acesso

               if l_acesso = 1 then
                   next field refatdsrvorg
               end if

               display by name d_cts63m00.refatdsrvorg
               display by name d_cts63m00.refatdsrvnum
               display by name d_cts63m00.refatdsrvano

               if  d_cts63m00.refatdsrvnum is null  and
                   d_cts63m00.refatdsrvano is null  then

                   let a_cts63m00[1].cidnom = w_cts63m00.atddstcidnom
                   let a_cts63m00[1].ufdcod = w_cts63m00.atddstufdcod

                   let a_cts63m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
                   call cts06g03( 3,
                                  2,
                                  w_cts63m00.ligcvntip,
                                  aux_today,
                                  aux_hora,
                                  a_cts63m00[1].lclidttxt,
                                  a_cts63m00[1].cidnom,
                                  a_cts63m00[1].ufdcod,
                                  a_cts63m00[1].brrnom,
                                  a_cts63m00[1].lclbrrnom,
                                  a_cts63m00[1].endzon,
                                  a_cts63m00[1].lgdtip,
                                  a_cts63m00[1].lgdnom,
                                  a_cts63m00[1].lgdnum,
                                  a_cts63m00[1].lgdcep,
                                  a_cts63m00[1].lgdcepcmp,
                                  a_cts63m00[1].lclltt,
                                  a_cts63m00[1].lcllgt,
                                  a_cts63m00[1].lclrefptotxt,
                                  a_cts63m00[1].lclcttnom,
                                  a_cts63m00[1].dddcod,
                                  a_cts63m00[1].lcltelnum,
                                  a_cts63m00[1].c24lclpdrcod,
                                  a_cts63m00[1].ofnnumdig,
                                  a_cts63m00[1].celteldddcod   ,
                                  a_cts63m00[1].celtelnum ,
                                  a_cts63m00[1].endcmp   ,
                                  hist_cts63m00.*,
                                  a_cts63m00[1].emeviacod)
                        returning a_cts63m00[1].lclidttxt,
                                  a_cts63m00[1].cidnom,
                                  a_cts63m00[1].ufdcod,
                                  a_cts63m00[1].brrnom,
                                  a_cts63m00[1].lclbrrnom,
                                  a_cts63m00[1].endzon,
                                  a_cts63m00[1].lgdtip,
                                  a_cts63m00[1].lgdnom,
                                  a_cts63m00[1].lgdnum,
                                  a_cts63m00[1].lgdcep,
                                  a_cts63m00[1].lgdcepcmp,
                                  a_cts63m00[1].lclltt,
                                  a_cts63m00[1].lcllgt,
                                  a_cts63m00[1].lclrefptotxt,
                                  a_cts63m00[1].lclcttnom,
                                  a_cts63m00[1].dddcod,
                                  a_cts63m00[1].lcltelnum,
                                  a_cts63m00[1].c24lclpdrcod,
                                  a_cts63m00[1].ofnnumdig,
                                  a_cts63m00[1].celteldddcod   ,
                                  a_cts63m00[1].celtelnum ,
                                  a_cts63m00[1].endcmp,
                                  ws.retflg,
                                  hist_cts63m00.*,
                                  a_cts63m00[1].emeviacod

                   let m_subbairro[1].lclbrrnom = a_cts63m00[1].lclbrrnom
                   call cts06g10_monta_brr_subbrr(a_cts63m00[1].brrnom,
                                                  a_cts63m00[1].lclbrrnom)
                        returning a_cts63m00[1].lclbrrnom

                   let a_cts63m00[1].lgdtxt = a_cts63m00[1].lgdtip clipped, " ",
                                              a_cts63m00[1].lgdnom clipped, " ",
                                              a_cts63m00[1].lgdnum using "<<<<#"

                   if  w_cts63m00.atddmccidnom = w_cts63m00.atdocrcidnom  and
                       w_cts63m00.atddmcufdcod = w_cts63m00.atdocrufdcod  then
                       error " Nao e' possivel a utilizacao da clausula",
                             " de assistencia aos passageiros! "
                       call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                     "A LOCAL DE DOMICILIO!","")
                            returning ws.confirma
                       if  ws.confirma = "N"  then
                           next field nom
                       end if
                   end if

                   if  ws.retflg = "N"  then
                       error " Dados referentes ao local incorretos",
                             " ou nao preenchidos!"
                       next field refatdsrvorg
                   else
                       next field seghospedado
                   end if
               end if
           else
               initialize d_cts63m00.refatdsrvano to null
               initialize d_cts63m00.refatdsrvnum to null
               display by name d_cts63m00.refatdsrvano
               display by name d_cts63m00.refatdsrvnum
           end if
          end if

          if  d_cts63m00.refatdsrvorg <> 4   and    # Remocao
              d_cts63m00.refatdsrvorg <> 6   and    # DAF
              d_cts63m00.refatdsrvorg <> 1   and    # Socorro
              d_cts63m00.refatdsrvorg <> 2   then   # Transporte
              error " Origem do servico de referencia deve ser",
                    " p/ SOCORRO ou REMOCAO!"
              next field refatdsrvorg
          end if

   before field refatdsrvnum
          display by name d_cts63m00.refatdsrvnum attribute (reverse)

   after  field refatdsrvnum
          display by name d_cts63m00.refatdsrvnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field refatdsrvorg
          end if

          if d_cts63m00.refatdsrvorg is not null  and
             d_cts63m00.refatdsrvnum is null      then
             error " Numero do servico de referencia nao informado!"
             next field refatdsrvnum
          end if

   before field refatdsrvano

          display by name d_cts63m00.refatdsrvano attribute (reverse)

   after  field refatdsrvano
          display by name d_cts63m00.refatdsrvano

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field refatdsrvnum
          end if

          if  d_cts63m00.refatdsrvnum is not null  then
           if  d_cts63m00.refatdsrvano is not null   then
               select atdsrvorg
                 into ws.refatdsrvorg
                 from DATMSERVICO
                      where atdsrvnum = d_cts63m00.refatdsrvnum
                        and atdsrvano = d_cts63m00.refatdsrvano

               if  ws.refatdsrvorg <> d_cts63m00.refatdsrvorg  then
                   error " Origem do numero de servico invalido.",
                         " A origem deve ser ", ws.refatdsrvorg using "&&"
                   next field refatdsrvorg
               end if

               if  mr_geral.aplnumdig is not null  then
                   select succod   ,
                          aplnumdig,
                          itmnumdig
                     into ws.succod   ,
                          ws.aplnumdig,
                          ws.itmnumdig
                     from DATRSERVAPOL
                          where atdsrvnum = d_cts63m00.refatdsrvnum
                            and atdsrvano = d_cts63m00.refatdsrvano

                   if  sqlca.sqlcode <> notfound  then

                   end if
               end if
           else
               error " Ano do servico original nao informado!"
               next field refatdsrvano
           end if
          end if

          let a_cts63m00[1].cidnom = w_cts63m00.atddstcidnom
          let a_cts63m00[1].ufdcod = w_cts63m00.atddstufdcod

          let a_cts63m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
          call cts06g03( 3,
                         2,
                         w_cts63m00.ligcvntip,
                         aux_today,
                         aux_hora,
                         a_cts63m00[1].lclidttxt,
                         a_cts63m00[1].cidnom,
                         a_cts63m00[1].ufdcod,
                         a_cts63m00[1].brrnom,
                         a_cts63m00[1].lclbrrnom,
                         a_cts63m00[1].endzon,
                         a_cts63m00[1].lgdtip,
                         a_cts63m00[1].lgdnom,
                         a_cts63m00[1].lgdnum,
                         a_cts63m00[1].lgdcep,
                         a_cts63m00[1].lgdcepcmp,
                         a_cts63m00[1].lclltt,
                         a_cts63m00[1].lcllgt,
                         a_cts63m00[1].lclrefptotxt,
                         a_cts63m00[1].lclcttnom,
                         a_cts63m00[1].dddcod,
                         a_cts63m00[1].lcltelnum,
                         a_cts63m00[1].c24lclpdrcod,
                         a_cts63m00[1].ofnnumdig,
                         a_cts63m00[1].celteldddcod   ,
                         a_cts63m00[1].celtelnum ,
                         a_cts63m00[1].endcmp,
                         hist_cts63m00.*,
                         a_cts63m00[1].emeviacod)
               returning a_cts63m00[1].lclidttxt,
                         a_cts63m00[1].cidnom,
                         a_cts63m00[1].ufdcod,
                         a_cts63m00[1].brrnom,
                         a_cts63m00[1].lclbrrnom,
                         a_cts63m00[1].endzon,
                         a_cts63m00[1].lgdtip,
                         a_cts63m00[1].lgdnom,
                         a_cts63m00[1].lgdnum,
                         a_cts63m00[1].lgdcep,
                         a_cts63m00[1].lgdcepcmp,
                         a_cts63m00[1].lclltt,
                         a_cts63m00[1].lcllgt,
                         a_cts63m00[1].lclrefptotxt,
                         a_cts63m00[1].lclcttnom,
                         a_cts63m00[1].dddcod,
                         a_cts63m00[1].lcltelnum,
                         a_cts63m00[1].c24lclpdrcod,
                         a_cts63m00[1].ofnnumdig,
                         a_cts63m00[1].celteldddcod   ,
                         a_cts63m00[1].celtelnum ,
                         a_cts63m00[1].endcmp,
                         ws.retflg,
                         hist_cts63m00.*,
                         a_cts63m00[1].emeviacod

          let m_subbairro[1].lclbrrnom = a_cts63m00[1].lclbrrnom
          call cts06g10_monta_brr_subbrr(a_cts63m00[1].brrnom,
                                         a_cts63m00[1].lclbrrnom)
               returning a_cts63m00[1].lclbrrnom

          let a_cts63m00[1].lgdtxt = a_cts63m00[1].lgdtip clipped, " ",
                                     a_cts63m00[1].lgdnom clipped, " ",
                                     a_cts63m00[1].lgdnum using "<<<<#"

          if  w_cts63m00.atddmccidnom = w_cts63m00.atdocrcidnom  and
              w_cts63m00.atddmcufdcod = w_cts63m00.atdocrufdcod  then
              call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                            "A LOCAL DE DOMICILIO!","") returning ws.confirma
              if  ws.confirma = "N"  then
                  next field nom
              end if
          end if

          if  ws.retflg = "N"  then
              error " Dados referentes ao local incorretos ou nao preenchidos!"
              next field refatdsrvano
          end if

   before field seghospedado
      display by name d_cts63m00.seghospedado attribute (reverse)

   after field seghospedado
      display by name d_cts63m00.seghospedado

      if (d_cts63m00.seghospedado <> 'S' and
         d_cts63m00.seghospedado <> 'N') or d_cts63m00.seghospedado is null then
         error 'Digite "S" ou "N" '
         next field seghospedado
      end if

      if d_cts63m00.seghospedado = 'S' then
         call cts22m01_hotel('', '', g_documento.acao, mr_hotel.*)
            returning mr_hotel.hsphotnom
                     ,mr_hotel.hsphotend
                     ,mr_hotel.hsphotbrr
                     ,mr_hotel.hsphotuf
                     ,mr_hotel.hsphotcid
                     ,mr_hotel.hsphottelnum
                     ,mr_hotel.hsphotcttnom
                     ,mr_hotel.hsphotdiavlr
                     ,mr_hotel.hsphotacmtip
                     ,mr_hotel.obsdes
                     ,mr_hotel.hsphotrefpnt

         display by name mr_hotel.hsphotnom
                        ,mr_hotel.hsphotbrr
                        ,mr_hotel.hsphotuf
                        ,mr_hotel.hsphotcid
                        ,mr_hotel.hsphotrefpnt
                        ,mr_hotel.hsphottelnum
                        ,mr_hotel.hsphotcttnom
      end if



   before field hpddiapvsqtd
          display by name d_cts63m00.hpddiapvsqtd attribute (reverse)

   after  field hpddiapvsqtd
          display by name d_cts63m00.hpddiapvsqtd

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts63m00.hpddiapvsqtd is null  then
                error " Quantidade prevista de diarias deve ser informada!"
                next field hpddiapvsqtd
             end if

             if d_cts63m00.hpddiapvsqtd = 0  then
                error " Quantidade prevista de diarias nao pode ser zero!"
                next field hpddiapvsqtd
             end if
             if d_cts63m00.hpddiapvsqtd > 2  then
                 call cts08g01("A","N",
                               "",
                               "LIMITE POR EVENTO: 02 DIARIAS, SENDO",
                               "R$ 100,00 POR PESSOA/DIA." , "" )
                      returning ws.confirma
                   next field hpddiapvsqtd
             end if
          end if

   before field hpdqrtqtd
          display by name d_cts63m00.hpdqrtqtd attribute (reverse)

   after  field hpdqrtqtd
          display by name d_cts63m00.hpdqrtqtd

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts63m00.hpdqrtqtd is null  then
                error " Numero de quartos deve ser informado!"
                next field hpdqrtqtd
             end if

             if d_cts63m00.hpdqrtqtd = 0  then
                error " Numero de quartos nao pode ser zero!"
                next field hpdqrtqtd
             end if
          end if

          error " Informe a relacao de hospedes!"
          call cts11m11 (a_passag[01].*,
                         a_passag[02].*,
                         a_passag[03].*,
                         a_passag[04].*,
                         a_passag[05].*)
               returning a_passag[01].*,
                         a_passag[02].*,
                         a_passag[03].*,
                         a_passag[04].*,
                         a_passag[05].*

   before field imdsrvflg
          let d_cts63m00.imdsrvflg    = "S"
          let w_cts63m00.atdpvtretflg = "S"
          let w_cts63m00.atdhorpvt    = "00:00"

          initialize w_cts63m00.atddatprg to null
          initialize w_cts63m00.atdhorprg to null

          display by name d_cts63m00.imdsrvflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field hpdqrtqtd
          else
             next field atdprinvlcod
          end if

   after  field imdsrvflg
          display by name d_cts63m00.imdsrvflg

          if d_cts63m00.imdsrvflg = "N" then
             let d_cts63m00.atdprinvlcod  = 2
             select cpodes
               into d_cts63m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts63m00.atdprinvlcod

             display by name d_cts63m00.atdprinvlcod
             display by name d_cts63m00.atdprinvldes

             next field atdlibflg
          end if

   before field atdprinvlcod
          let d_cts63m00.atdprinvlcod = 2
          display by name d_cts63m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts63m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts63m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts63m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts63m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa,",
                      " (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts63m00.atdprinvldes

          end if

   before field atdlibflg
          display by name d_cts63m00.atdlibflg attribute (reverse)

          if mr_geral.atdsrvnum is not null then
             if w_cts63m00.atdfnlflg = "S"  then
                exit input
             end if
          end if

          if d_cts63m00.atdlibflg is null  and
             mr_geral.c24soltipcod = 1  then   # Tipo Solic = Segurado

          end if

   after  field atdlibflg
          display by name d_cts63m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if d_cts63m00.atdlibflg is null then
             error " Envio liberado deve ser informado!"
             next field atdlibflg
          end if

          if d_cts63m00.atdlibflg <> "S"  and
             d_cts63m00.atdlibflg <> "N"  then
             error " Informe (S)im ou (N)ao!"
             next field atdlibflg
          end if

          let w_cts63m00.atdlibflg   =  d_cts63m00.atdlibflg

          if w_cts63m00.atdlibflg is null   then
             next field atdlibflg
          end if

          display by name d_cts63m00.atdlibflg

          if w_cts63m00.antlibflg is null  then
             if w_cts63m00.atdlibflg = "S"  then
                call cts40g03_data_hora_banco(2)
                   returning l_data, l_hora2
                let d_cts63m00.atdlibdat = l_data
                let d_cts63m00.atdlibhor =  l_hora2
             else
                let d_cts63m00.atdlibflg = "N"
                display by name d_cts63m00.atdlibflg
                initialize d_cts63m00.atdlibhor to null
                initialize d_cts63m00.atdlibdat to null
             end if
          else
             select atdfnlflg
               from datmservico
              where atdsrvnum = mr_geral.atdsrvnum  and
                    atdsrvano = mr_geral.atdsrvano  and
                    atdfnlflg in ("A","N")


             if sqlca.sqlcode = notfound  then
                error " Servico ja' acionado nao pode ser alterado!"
                let m_srv_acionado = true
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma
                next field atdlibflg
             end if

             if w_cts63m00.antlibflg = "S"  then
                if w_cts63m00.atdlibflg = "S"  then
                   exit input
                else
                   error " A liberacao do servico nao pode ser cancelada!"
                   next field atdlibflg
                   let d_cts63m00.atdlibflg = "N"
                   display by name d_cts63m00.atdlibflg
                   initialize d_cts63m00.atdlibhor to null
                   initialize d_cts63m00.atdlibdat to null
                   error " Liberacao do servico cancelada!"
                   sleep 1
                   exit input
                end if
             else
                if w_cts63m00.antlibflg = "N"  then
                   if w_cts63m00.atdlibflg = "N"  then
                      exit input
                   else
                      call cts40g03_data_hora_banco(2)
                         returning l_data, l_hora2
                      let d_cts63m00.atdlibdat = l_data
                      let d_cts63m00.atdlibhor = l_hora2
                      exit input
                   end if
                end if
             end if
          end if

   before field frmflg
          if w_cts63m00.operacao = "i"  then
             let d_cts63m00.frmflg = "N"
             display by name d_cts63m00.frmflg attribute (reverse)
          else
             if w_cts63m00.atdfnlflg = "S"  then
                call cts11g00(w_cts63m00.lignum)
                let int_flag = true
             end if

             exit input
          end if

   after  field frmflg
          display by name d_cts63m00.frmflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdlibflg
          end if

          if d_cts63m00.frmflg = "S"  then
             if d_cts63m00.atdlibflg = "N"  then
                error " Nao e' possivel registrar servico nao liberado",
                      " via formulario!"
                next field atdlibflg
             end if

             call cts02m05(2) returning w_cts63m00.data,
                                        w_cts63m00.hora,
                                        w_cts63m00.funmat,
                                        w_cts63m00.cnldat,
                                        w_cts63m00.atdfnlhor,
                                        w_cts63m00.c24opemat,
                                        w_cts63m00.atdprscod

             if w_cts63m00.hora      is null or
                w_cts63m00.data      is null or
                w_cts63m00.funmat    is null or
                w_cts63m00.cnldat    is null or
                w_cts63m00.atdfnlhor is null or
                w_cts63m00.c24opemat is null or
                w_cts63m00.atdprscod is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let d_cts63m00.atdlibhor = w_cts63m00.hora
             let d_cts63m00.atdlibdat = w_cts63m00.data
             let w_cts63m00.atdfnlflg = "S"
             let w_cts63m00.atdetpcod =  4
          end if

          while true
             if a_passag[01].pasnom is null  or
                a_passag[01].pasidd is null  then
                error " Informe a relacao de hospedes!"
                call cts11m11 (a_passag[01].*,
                               a_passag[02].*,
                               a_passag[03].*,
                               a_passag[04].*,
                               a_passag[05].*)
                     returning a_passag[01].*,
                               a_passag[02].*,
                               a_passag[03].*,
                               a_passag[04].*,
                               a_passag[15].*
             else
                exit while
             end if
          end while

   on key (interrupt)
      if mr_geral.atdsrvnum  is null   then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?",
                     "","") = "S"  then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if mr_geral.c24astcod is not null then
         call ctc58m00_vis(mr_geral.c24astcod)
      end if

   on key (F4)

              if d_cts63m00.refatdsrvnum is null then
                 let l_servico = mr_geral.atdsrvnum
                 let l_ano     = mr_geral.atdsrvano
              else
                 let l_servico = d_cts63m00.refatdsrvnum
                 let l_ano     = d_cts63m00.refatdsrvano
              end if

              call ctx04g00_local_gps( l_servico,
                                       l_ano,
                                       1                       )
                             returning a_cts63m00[1].lclidttxt   ,
                                       a_cts63m00[1].lgdtip      ,
                                       a_cts63m00[1].lgdnom      ,
                                       a_cts63m00[1].lgdnum      ,
                                       a_cts63m00[1].lclbrrnom   ,
                                       a_cts63m00[1].brrnom      ,
                                       a_cts63m00[1].cidnom      ,
                                       a_cts63m00[1].ufdcod      ,
                                       a_cts63m00[1].lclrefptotxt,
                                       a_cts63m00[1].endzon      ,
                                       a_cts63m00[1].lgdcep      ,
                                       a_cts63m00[1].lgdcepcmp   ,
                                       a_cts63m00[1].lclltt      ,
                                       a_cts63m00[1].lcllgt      ,
                                       a_cts63m00[1].dddcod      ,
                                       a_cts63m00[1].lcltelnum   ,
                                       a_cts63m00[1].lclcttnom   ,
                                       a_cts63m00[1].c24lclpdrcod,
                                       a_cts63m00[1].celteldddcod,
                                       a_cts63m00[1].celtelnum   ,
                                       a_cts63m00[1].endcmp,
                                       ws.sqlcode                ,
                                       a_cts63m00[1].emeviacod

              select ofnnumdig into a_cts63m00[1].ofnnumdig
                from datmlcl
               where atdsrvano = mr_geral.atdsrvano
                 and atdsrvnum = mr_geral.atdsrvnum
                 and c24endtip = 1

              let a_cts63m00[1].lgdtxt = a_cts63m00[1].lgdtip clipped, " ",
                                         a_cts63m00[1].lgdnom clipped, " ",
                                         a_cts63m00[1].lgdnum using "<<<<#"

                   let a_cts63m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

                   call cts06g03( 1, ## Local ocorrencia
                                  2,
                                  w_cts63m00.ligcvntip,
                                  aux_today,
                                  aux_hora,
                                  a_cts63m00[1].lclidttxt,
                                  a_cts63m00[1].cidnom,
                                  a_cts63m00[1].ufdcod,
                                  a_cts63m00[1].brrnom,
                                  a_cts63m00[1].lclbrrnom,
                                  a_cts63m00[1].endzon,
                                  a_cts63m00[1].lgdtip,
                                  a_cts63m00[1].lgdnom,
                                  a_cts63m00[1].lgdnum,
                                  a_cts63m00[1].lgdcep,
                                  a_cts63m00[1].lgdcepcmp,
                                  a_cts63m00[1].lclltt,
                                  a_cts63m00[1].lcllgt,
                                  a_cts63m00[1].lclrefptotxt,
                                  a_cts63m00[1].lclcttnom,
                                  a_cts63m00[1].dddcod,
                                  a_cts63m00[1].lcltelnum,
                                  a_cts63m00[1].c24lclpdrcod,
                                  a_cts63m00[1].ofnnumdig,
                                  a_cts63m00[1].celteldddcod   ,
                                  a_cts63m00[1].celtelnum ,
                                  a_cts63m00[1].endcmp,
                                  hist_cts63m00.*,
                                  a_cts63m00[1].emeviacod)
                        returning a_cts63m00[1].lclidttxt,
                                  a_cts63m00[1].cidnom,
                                  a_cts63m00[1].ufdcod,
                                  a_cts63m00[1].brrnom,
                                  a_cts63m00[1].lclbrrnom,
                                  a_cts63m00[1].endzon,
                                  a_cts63m00[1].lgdtip,
                                  a_cts63m00[1].lgdnom,
                                  a_cts63m00[1].lgdnum,
                                  a_cts63m00[1].lgdcep,
                                  a_cts63m00[1].lgdcepcmp,
                                  a_cts63m00[1].lclltt,
                                  a_cts63m00[1].lcllgt,
                                  a_cts63m00[1].lclrefptotxt,
                                  a_cts63m00[1].lclcttnom,
                                  a_cts63m00[1].dddcod,
                                  a_cts63m00[1].lcltelnum,
                                  a_cts63m00[1].c24lclpdrcod,
                                  a_cts63m00[1].ofnnumdig,
                                  a_cts63m00[1].celteldddcod   ,
                                  a_cts63m00[1].celtelnum ,
                                  a_cts63m00[1].endcmp,
                                  ws.retflg,
                                  hist_cts63m00.*,
                                  a_cts63m00[1].emeviacod

               #------------------------------------------------------------------------------
               # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
               #------------------------------------------------------------------------------
               if g_documento.lclocodesres = "S" then
                  let w_cts63m00.atdrsdflg = "S"
               else
                  let w_cts63m00.atdrsdflg = "N"
               end if
   on key (F5)

      let g_monitor.horaini = current ## Flexvision
      call cta01m12_espelho(mr_geral.ramcod,
                            mr_geral.succod,
                            mr_geral.aplnumdig,
                            mr_geral.itmnumdig,
                            mr_geral.prporg,
                            mr_geral.prpnumdig,
                            mr_geral.fcapacorg,
                            mr_geral.fcapacnum,
                            "",  # pcacarnum
                            "",  # pcaprpitm
                            "",  # cmnnumdig,
                            "",  # crtsaunum
                            "",  # bnfnum
                            g_documento.ciaempcod)

   on key (F6)
      if mr_geral.atdsrvnum is null  or
         mr_geral.atdsrvano is null  then
         call cts10m02 (hist_cts63m00.*)
              returning hist_cts63m00.*
      else
         call cts10n00(mr_geral.atdsrvnum,
                       mr_geral.atdsrvano,
                       g_issk.funmat,
                       aux_today,
                       aux_hora)
      end if

   on key (F7)
      if mr_geral.atdsrvnum is null or
         mr_geral.atdsrvano is null then
         error " Impressao somente com cadastramento do servico!"
      else
         call ctr03m02(mr_geral.atdsrvnum,
                       mr_geral.atdsrvano)
      end if

   on key (F9)
      if mr_geral.atdsrvnum is null or
         mr_geral.atdsrvano is null then
         error " Servico nao cadastrado!"
      else
         if d_cts63m00.atdlibflg = "N"   then
            error " Servico nao liberado!"
         else
            call cta00m06_acionamento(g_issk.dptsgl)
            returning l_acesso
            if l_acesso = true then
               call cts00m02(mr_geral.atdsrvnum,mr_geral.atdsrvano,0)
            else
               call cts00m02(mr_geral.atdsrvnum, mr_geral.atdsrvano, 2 )
            end if
         end if
      end if

   on key (F10)
      call cts11m11 (a_passag[01].*,
                     a_passag[02].*,
                     a_passag[03].*,
                     a_passag[04].*,
                     a_passag[05].*)
           returning a_passag[01].*,
                     a_passag[02].*,
                     a_passag[03].*,
                     a_passag[04].*,
                     a_passag[05].*

   on key (F3)
      call cts00m23(mr_geral.atdsrvnum,
                    mr_geral.atdsrvano)

 end input

 if int_flag then
    error " Operacao cancelada!"
 end if

 return hist_cts63m00.*

end function
