#############################################################################
# Nome do Modulo: CTS00M40                                            Raji  #
#                                                                           #
# Gera servico de apoio                                            Jul/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS            #
# 14/09/2011 Celso Yamahaki CT-2011-11684  Remocao de verificacao de destino#
#                                          ou origem para abertura de servi-#
#                                          co de apoio                      #
# 28/02/2012 Celso Yamahaki CT-2012-3366IN Inclusao de logs mais detalhados #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_current datetime year to second


#----------------------------------------------------------------------------
function cts00m40_apoio(param)
#----------------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    mdtcod            like datmmdtmvt.mdtcod,
    apoio_cod         smallint    # Codigo do servico de apoio
 end record

 define retorno       record
    codigo            integer,
    descricao         char(70)
 end record

 define d_cts00m40    record
    servico           char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (27)                    ,
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

 define w_cts00m40    record
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
    atdrsdflg         like datmservico.atdrsdflg   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    asitipcod         like datmservico.asitipcod   ,
    c24astcod         like datmligacao.c24astcod   ,
    asitipdes         like datkasitip.asitipdes
 end record

 define a_cts00m40    array[2] of record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
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
    emeviacod         like datkemevia.emeviacod    ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp
 end record

 define ws              record
        pergunta        char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             varchar(80)                ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        vclcorcod       like datmservico.vclcorcod ,
        funmat          like datmservico.funmat    ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        srrabvnom       like datksrr.srrabvnom     ,
        atdvclsgl       like datkveiculo.atdvclsgl ,
        srrcoddig       like datksrr.srrcoddig     ,
        ligdcttip       like datrligsemapl.ligdcttip,
        ligdctnum       like datrligsemapl.ligdctnum,
        dctitm          like datrligsemapl.dctitm   ,
        psscntcod       like kspmcntrsm.psscntcod   ,
        historico1      char(78)                    ,
        historico2      char(78)                    ,
        mensagem        char(300)
 end record

 define l_lignum        LIKE datrligsinvst.lignum,
        l_succod        LIKE datrligapol.succod,
        l_aplnumdig     LIKE datrligapol.aplnumdig,
        l_corsus        LIKE abamcor.corsus

 define arr_aux       smallint                  ,
        aux_libant    like datmservico.atdlibflg,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano,
        aux_libhor    char (05)                 ,
        aux_today     char (10)                 ,
        aux_hora      char (05)                 ,
        aux_ano       char (02)                 ,
        cpl_atdsrvnum like datmservico.atdsrvnum,
        cpl_atdsrvano like datmservico.atdsrvano,
        cpl_atdsrvorg like datmservico.atdsrvorg

 define aux_sinvstano char(04),
        aux_date      datetime year to year,
        l_data        date,
        l_hora2       datetime hour to minute,
        w_pf1         integer

 let     arr_aux       =  null
 let     aux_libant    =  null
 let     aux_atdsrvnum =  null
 let     aux_atdsrvano =  null
 let     aux_libhor    =  null
 let     aux_today     =  null
 let     aux_hora      =  null
 let     aux_ano       =  null
 let     cpl_atdsrvnum =  null
 let     cpl_atdsrvano =  null
 let     cpl_atdsrvorg =  null

 for     w_pf1  =  1  to  2
         initialize  a_cts00m40[w_pf1].*  to  null
 end     for

 initialize  d_cts00m40.*  to  null
 initialize  w_cts00m40.*  to  null
 initialize  ws.*  to  null

 let retorno.codigo = 0
 let retorno.descricao = ""

  select nom      ,
         vclcoddig,
         vcldes   ,
         vclanomdl,
         vcllicnum,
         corsus   ,
         cornom   ,
         vclcorcod,
         atdlibflg,
         atdlibhor,
         atdlibdat,
         atdhorpvt,
         atdpvtretflg,
         atdfnlflg,
         asitipcod,
         atdvcltip,
         atdprinvlcod,
         atdrsdflg,
         atdsrvorg,
         ciaempcod
    into d_cts00m40.nom      ,
         d_cts00m40.vclcoddig,
         d_cts00m40.vcldes   ,
         d_cts00m40.vclanomdl,
         d_cts00m40.vcllicnum,
         d_cts00m40.corsus   ,
         d_cts00m40.cornom   ,
         ws.vclcorcod        ,
         d_cts00m40.atdlibflg,
         d_cts00m40.atdlibhor,
         d_cts00m40.atdlibdat,
         w_cts00m40.atdhorpvt,
         w_cts00m40.atdpvtretflg,
         w_cts00m40.atdfnlflg,
         d_cts00m40.asitipcod,
         w_cts00m40.atdvcltip,
         d_cts00m40.atdprinvlcod,
         w_cts00m40.atdrsdflg,
         w_cts00m40.atdsrvorg,
         g_documento.ciaempcod
    from datmservico
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound  then
    let retorno.codigo = notfound
    let retorno.descricao = "Servico nao encontrado."
    let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
    call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
         returning ws.sqlcode, ws.mensagem
    return retorno.*
 end if
 let m_current = current
 display m_current, " APOIO [01] - Verificacao da origem do servico: ", w_cts00m40.atdsrvorg , '/',param.atdsrvnum,'-',param.atdsrvano
 ##############################################################
 # Valida se a origem do servico permite a solicitacao de apoio
 ##############################################################
 if w_cts00m40.atdsrvorg <> 1 and   # Socorro
    w_cts00m40.atdsrvorg <> 4 then  # Remocao

    let retorno.codigo = 1
    let retorno.descricao = "Servico nao permite solicitacao de apoio."
    let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** NAO E POSSIVEL SOLICITAR APOIO PARA ESTE SERVICO VIA GPS. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
    call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
         returning ws.sqlcode, ws.mensagem
    return retorno.*
 end if

 let m_current = current
 display m_current, " APOIO [02] - Verificacao da Assistencia do Servico: ",d_cts00m40.asitipcod, '/',param.atdsrvnum,'-',param.atdsrvano
 ###################################################################
 # Valida se a assistencia do servico permite a solicitacao de apoio
 ###################################################################
 if d_cts00m40.asitipcod <> 1 and   # Guincho
    d_cts00m40.asitipcod <> 2 and   # Tecnico
    d_cts00m40.asitipcod <> 3 and   # Guincho/Tecnico
    d_cts00m40.asitipcod <> 4 then  # Chaveiro AUTO

    let retorno.codigo = 2
    let retorno.descricao = "Assistencia nao permite solicitacao de apoio."
    let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** NAO E POSSIVEL SOLICITAR APOIO PARA ESTE SERVICO VIA GPS. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
    call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
         returning ws.sqlcode, ws.mensagem
    return retorno.*
 end if

 let m_current = current
 display m_current, " APOIO [03] - Verifica o tipo de apoio solicitado: ", param.apoio_cod, '/',param.atdsrvnum,'-',param.atdsrvano
 ####################################################################
 # Converte o codigo de apoio recebido do GPS para codugi de problema
 ####################################################################
 case param.apoio_cod
     when 1   # Opção Apoio Plataforma
     	let w_cts00m40.c24pbmcod = 114 # ENVIO DE GUINCHO PLATAFORMA

     when 2   # Opção Apoio Lança/Bandeja
     	let w_cts00m40.c24pbmcod = 361 # ENVIO DE GUINCHO LANCA/BANDEJA

     when 3   # Opção Apoio Asa Delta
     	let w_cts00m40.c24pbmcod = 372 # ENVIO DE GUINCHO ASA DELTA

     when 4   # Opção Apoio picape
     	let w_cts00m40.c24pbmcod = 113 # ENVIO DE PICAPE

     when 5   # Opção Apoio chaveiro
     	let w_cts00m40.c24pbmcod = 115 # ENVIO DE CHAVEIRO

     when 6   # Opção Apoio picape 4x4
     	let w_cts00m40.c24pbmcod = 381 # ENVIO DE PICAPE 4X4

     when 7   # Opção Apoio patins
     	let w_cts00m40.c24pbmcod = 1009 # ENVIO DE PATINS

     when 8   # Opção Apoio tecnico
     	let w_cts00m40.c24pbmcod = 1011 # ENVIO DE TECNICO

     when 9   # Opção Apoio roda extra
     	let w_cts00m40.c24pbmcod = 1010 # ENVIO DE RODAEXTRA

     when 10   # Opção Apoio pesado plataforma
     	let w_cts00m40.c24pbmcod = 1066 # ENVIO DE PESADO PLATAFORMA

     when 11   # Opção Apoio lanca pesado
     	let w_cts00m40.c24pbmcod = 1067 # ENVIO DE LANCA PESADO

     when 12   # Opção Apoio guindaste
     	let w_cts00m40.c24pbmcod = 1068 # ENVIO DE GUINDASTE

     when 13   # Opção Apoio munck
     	let w_cts00m40.c24pbmcod = 1069 # ENVIO DE MUNCK

 end case

 ###################################################################
 # Obtem informacoes do problema para criar o sevico de apoio
 ###################################################################
 select datkpbm.c24pbmdes,
        datkpbmgrp.atdsrvorg,
        datkasitip.asitipcod,
        datrempligatdprb.c24astcod,
        datkasitip.asitipdes
   into w_cts00m40.atddfttxt,
        w_cts00m40.atdsrvorg,
        w_cts00m40.asitipcod,
        w_cts00m40.c24astcod,
        w_cts00m40.asitipdes
   from datkpbm,
        datkpbmgrp,
        datkasitip,
        datrempligatdprb
  where datkpbm.c24pbmgrpcod = datkpbmgrp.c24pbmgrpcod
    and datkpbm.c24pbmcod = datrempligatdprb.c24pbmcod
    and datkpbm.c24pbmcod = w_cts00m40.c24pbmcod
    and datkasitip.asitipcod = datkpbm.asitipcod
    and datrempligatdprb.ciaempcod = g_documento.ciaempcod
 let m_current = current
 display m_current, " APOIO [04] - Informacoes do problema para abrir apoio - sqlca.sqlcode: ",sqlca.sqlcode, '/',param.atdsrvnum,'-',param.atdsrvano
 ###################################################################
 # Obtem informacao do veiculo e socorrista que solicitou o apoio
 ###################################################################
 select srrabvnom, atdvclsgl, datksrr.srrcoddig
   into ws.srrabvnom, ws.atdvclsgl, ws.srrcoddig
   from datkveiculo,
        dattfrotalocal,
        datksrr
  where datkveiculo.socvclcod = dattfrotalocal.socvclcod
    and datksrr.srrcoddig = dattfrotalocal.srrcoddig
    and mdtcod = param.mdtcod
 let m_current = current
 display m_current, " APOIO [05] - Dados do solicitante do Apoio - sqlca.sqlcode ",sqlca.sqlcode, '/',param.atdsrvnum,'-',param.atdsrvano
 let g_documento.solnom = ws.srrabvnom clipped, " - ", ws.atdvclsgl
 let g_documento.c24soltipcod = 3

 let w_cts00m40.atddat = today
 let w_cts00m40.atdhor = current
 let d_cts00m40.atdlibflg = "S" # Servico de apoio sempre liberado
 let d_cts00m40.atdlibhor = w_cts00m40.atdhor
 let d_cts00m40.atdlibdat = w_cts00m40.atddat

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         1)
               returning a_cts00m40[1].lclidttxt   ,
                         a_cts00m40[1].lgdtip      ,
                         a_cts00m40[1].lgdnom      ,
                         a_cts00m40[1].lgdnum      ,
                         a_cts00m40[1].lclbrrnom   ,
                         a_cts00m40[1].brrnom      ,
                         a_cts00m40[1].cidnom      ,
                         a_cts00m40[1].ufdcod      ,
                         a_cts00m40[1].lclrefptotxt,
                         a_cts00m40[1].endzon      ,
                         a_cts00m40[1].lgdcep      ,
                         a_cts00m40[1].lgdcepcmp   ,
                         a_cts00m40[1].lclltt      ,
                         a_cts00m40[1].lcllgt      ,
                         a_cts00m40[1].dddcod      ,
                         a_cts00m40[1].lcltelnum   ,
                         a_cts00m40[1].lclcttnom   ,
                         a_cts00m40[1].c24lclpdrcod,
                         a_cts00m40[1].celteldddcod,
                         a_cts00m40[1].celtelnum   ,
                         a_cts00m40[1].endcmp      ,
                         ws.sqlcode,
                         a_cts00m40[1].emeviacod

 let m_current = current
 display m_current, " APOIO [06] - Local da ocorrencia - ws.sqlcode", ws.sqlcode, '/',param.atdsrvnum,'-',param.atdsrvano
 select ofnnumdig into a_cts00m40[1].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 1

 if status = notfound then
    display "Nao foi localizada oficina para o servico: ", param.atdsrvnum,"-", param.atdsrvano
 end if
 {if ws.sqlcode <> 0  then
    let retorno.codigo = ws.sqlcode
    let retorno.descricao = "Problema ao obter o local de ocorrencia."
    let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
    call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
         returning ws.sqlcode, ws.mensagem
    return retorno.*
 end if}

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------

 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         2)
               returning a_cts00m40[2].lclidttxt   ,
                         a_cts00m40[2].lgdtip      ,
                         a_cts00m40[2].lgdnom      ,
                         a_cts00m40[2].lgdnum      ,
                         a_cts00m40[2].lclbrrnom   ,
                         a_cts00m40[2].brrnom      ,
                         a_cts00m40[2].cidnom      ,
                         a_cts00m40[2].ufdcod      ,
                         a_cts00m40[2].lclrefptotxt,
                         a_cts00m40[2].endzon      ,
                         a_cts00m40[2].lgdcep      ,
                         a_cts00m40[2].lgdcepcmp   ,
                         a_cts00m40[2].lclltt      ,
                         a_cts00m40[2].lcllgt      ,
                         a_cts00m40[2].dddcod      ,
                         a_cts00m40[2].lcltelnum   ,
                         a_cts00m40[2].lclcttnom   ,
                         a_cts00m40[2].c24lclpdrcod,
                         a_cts00m40[2].celteldddcod,
                         a_cts00m40[2].celtelnum   ,
                         a_cts00m40[2].endcmp      ,
                         ws.sqlcode,
                         a_cts00m40[2].emeviacod

 let m_current = current
 display m_current, " APOIO [07] - Local de destino - ws.sqlcode", ws.sqlcode, '/',param.atdsrvnum,'-',param.atdsrvano
 select ofnnumdig into a_cts00m40[2].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 2

 if ws.sqlcode = notfound   then
    let d_cts00m40.dstflg = "N"
    display "Nao foi encontrada Oficina destino para o servico: ", param.atdsrvnum,"-",param.atdsrvano
 {else
    if ws.sqlcode = 0   then
       let d_cts00m40.dstflg = "S"
    else
       let retorno.codigo = ws.sqlcode
       let retorno.descricao = "Problema ao obter o local de destino."
       let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
       call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
            returning ws.sqlcode, ws.mensagem
       return retorno.*
    end if}
 end if

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
   into w_cts00m40.sinvitflg,
        w_cts00m40.roddantxt,
        w_cts00m40.rmcacpflg,
        d_cts00m40.sindat   ,
        d_cts00m40.sinhor   ,
        w_cts00m40.vclcamtip,
        w_cts00m40.vclcrcdsc,
        w_cts00m40.vclcrgflg,
        w_cts00m40.vclcrgpso,
        w_cts00m40.bocflg   ,
        w_cts00m40.bocnum   ,
        w_cts00m40.bocemi   ,
        w_cts00m40.vcllibflg
   from datmservicocmp
  where atdsrvnum = param.atdsrvnum and
        atdsrvano = param.atdsrvano
 let m_current = current
 display m_current, " APOIO [08] - Dados complementares do servico - sqlca.sqlcode: ", '/',param.atdsrvnum,'-',param.atdsrvano
 let d_cts00m40.asitipabvdes = "NAO PREV"


 select asitipabvdes
   into d_cts00m40.asitipabvdes
   from datkasitip
  where asitipcod = d_cts00m40.asitipcod
 let m_current = current
 display m_current, " APOIO [09] - Tipo de Assistencia - sqlca.sqlcode: ", sqlca.sqlcode, '/',param.atdsrvnum,'-',param.atdsrvano
 #------------------------------------------------------------------
 # Dados da ligacao
 #------------------------------------------------------------------
 select min(lignum)
   into ws.lignum
   from datmligacao
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 let m_current = current
 display m_current, " APOIO [10] - Dados da Ligacao - sqlca.sqlcode: ", sqlca.sqlcode, '/',param.atdsrvnum,'-',param.atdsrvano
 let d_cts00m40.frmflg = "N"
 initialize ws.caddat to null
 initialize ws.cadhor to null
 initialize ws.cademp to null
 initialize ws.cadmat to null

 select datmligacao.ligcvntip,
        datrligapol.succod,
        datrligapol.ramcod,
        datrligapol.aplnumdig,
        datrligapol.itmnumdig,
        datrligapol.edsnumref,
        datrligprp.prporg,
        datrligprp.prpnumdig,
        datrligpac.fcapacorg,
        datrligpac.fcapacnum,
        datrligsau.bnfnum,
        datrligsau.crtnum,
        datrligppt.cmnnumdig,
        datrligcor.corsus,
        datrligtel.dddcod,
        datrligtel.teltxt,
        datrligmat.funmat,
        datrligmat.empcod,
        datrligmat.usrtip,
        datrligcgccpf.cgccpfnum,
        datrligcgccpf.cgcord,
        datrligcgccpf.cgccpfdig,
        datrligcgccpf.crtdvgflg,
        datrligsemapl.ligdcttip,
        datrligsemapl.ligdctnum,
        datrcntlig.psscntcod,
        datrligitaaplitm.itaciacod
   into g_documento.ligcvntip,
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
        g_issk.empcod,
        g_issk.usrtip,
        g_documento.cgccpfnum,
        g_documento.cgcord,
        g_documento.cgccpfdig,
        g_crtdvgflg,
        ws.ligdcttip,
        ws.ligdctnum,
        ws.psscntcod,
        g_documento.itaciacod
   from datmligacao,
        outer datrligapol,
        outer datrligprp,
        outer datrligpac,
        outer datrligsau,
        outer datrligppt,
        outer datrligcor,
        outer datrligtel,
        outer datrligmat,
        outer datrligcgccpf,
        outer datrligsemapl,
        outer datrcntlig,
        outer datrligitaaplitm
  where datmligacao.lignum = ws.lignum
    and datrligapol.lignum = datmligacao.lignum
    and datrligprp.lignum  = datmligacao.lignum
    and datrligpac.lignum  = datmligacao.lignum
    and datrligsau.lignum  = datmligacao.lignum
    and datrligppt.lignum  = datmligacao.lignum
    and datrligcor.lignum  = datmligacao.lignum
    and datrligtel.lignum  = datmligacao.lignum
    and datrligmat.lignum  = datmligacao.lignum
    and datrligcgccpf.lignum  = datmligacao.lignum
    and datrligsemapl.lignum  = datmligacao.lignum
    and datrcntlig.lignum     = datmligacao.lignum
    and datrligitaaplitm.lignum = datmligacao.lignum

 if sqlca.sqlcode <> 0 then
       let retorno.codigo = ws.sqlcode
       let retorno.descricao = "Problema ao obter o documento da ligacao."
       let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
       let m_current = current
       display m_current, " APOIO [11] - Erro " , sqlca.sqlcode," ao localizar dados complementares da ligacao. "

       call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
            returning ws.sqlcode, ws.mensagem
       return retorno.*
 end if


 display "ws.lignum: ",ws.lignum
 display "g_documento.itaciacod1: ",g_documento.itaciacod
 let m_current = current
 display m_current, " APOIO [11] - Dados complementares da Ligacao ", '/',param.atdsrvnum,'-',param.atdsrvano

 if g_documento.ciaempcod = 43 then
    let g_pss.psscntcod = ws.psscntcod
 else
    let g_cgccpf.ligdcttip = ws.ligdcttip
    let g_cgccpf.ligdctnum = ws.ligdctnum
 end if

 if w_cts00m40.vclcamtip is not null  and
    w_cts00m40.vclcamtip <>  " "      then
    let d_cts00m40.camflg = "S"
 else
    if w_cts00m40.vclcrgflg is not null  and
       w_cts00m40.vclcrgflg <>  " "      then
       let d_cts00m40.camflg = "S"
    else
       let d_cts00m40.camflg = "N"
    end if
 end if

 let g_issk.funmat = 999999
 let g_issk.empcod = 1
 let g_issk.usrtip = "F"

 while true
      #begin work
      let m_current = current
      display m_current, " APOIO [12] - #begin work - NUMERACAO ", '/',param.atdsrvnum,'-',param.atdsrvano
      #-----------------------------------------------------------------------
      # Busca numeracao ligacao / servico
      #-----------------------------------------------------------------------
         call cts10g03_numeracao( 2, "1" )
              returning ws.lignum   ,
                        ws.atdsrvnum,
                        ws.atdsrvano,
                        ws.sqlcode  ,
                        ws.msg

         if  ws.sqlcode = 0  then
             #commit work
             let m_current = current
             display m_current, " APOIO [12] - proximo numero de servico e ligacao : ",ws.atdsrvnum,'-',ws.atdsrvano
             display m_current, " APOIO [12] - #commit work", '/',ws.atdsrvnum,'-',ws.atdsrvano, '/', ws.lignum
         else
             #rollback work
             let m_current = current
             display m_current, " APOIO [12] - Problema na numeracao do servico e ligacao "
             display m_current, ' APOIO [12] - call cts10g03_numeracao( 2, "1" )  '
             display m_current, " APOIO [12] - #rollback work", '/',ws.atdsrvnum,'-',ws.atdsrvano, '/', ws.lignum
             let retorno.codigo = ws.sqlcode
             let retorno.descricao = "Problema ao gerar numero da ligacao e servico."
             let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
             call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                  returning ws.sqlcode, ws.mensagem
             return retorno.*
             exit while
         end if

         let g_documento.lignum = ws.lignum
         let aux_atdsrvnum      = ws.atdsrvnum
         let aux_atdsrvano      = ws.atdsrvano

       #-------------------------------------------------------------------------
       # Grava ligacao e servico
       #-------------------------------------------------------------------------
         #begin work
         let m_current = current
         display m_current, " APOIO [13] - Gravar Ligacao "
         display m_current, " APOIO [13] - #begin work", '/',aux_atdsrvnum,'-',aux_atdsrvano

         if ws.caddat is null then
            let ws.caddat = today
         end if
         
         if ws.cadhor is null then
            let ws.cadhor = current
         end if
         
         if ws.cademp is null then
            let ws.cademp = 1
         end if
         
         if ws.cadmat is null then
            let ws.cadmat = 99999
         end if

         call cts10g00_ligacao ( g_documento.lignum      ,
                                 w_cts00m40.atddat       ,
                                 w_cts00m40.atdhor       ,
                                 g_documento.c24soltipcod,
                                 g_documento.solnom      ,
                                 w_cts00m40.c24astcod    ,
                                 g_issk.funmat           ,
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
                        ws.sqlcode

         if  ws.sqlcode  <>  0  then
             let retorno.codigo = ws.sqlcode
             let retorno.descricao = "Problema ao gravar a ligacao. Cod Erro: ", ws.sqlcode, 
                                      "Tabela: ", ws.tabname clipped
             #rollback work
             let m_current = current
             display m_current, " APOIO [13] - Problema ao gravar a Ligacao"             
             display m_current, " APOIO [13] - Parametro: g_documento.lignum      : " ,g_documento.lignum
             display m_current, " APOIO [13] - Parametro: w_cts00m40.atddat       : " ,w_cts00m40.atddat
             display m_current, " APOIO [13] - Parametro: w_cts00m40.atdhor       : " ,w_cts00m40.atdhor
             display m_current, " APOIO [13] - Parametro: g_documento.c24soltipcod: " ,g_documento.c24soltipcod
             display m_current, " APOIO [13] - Parametro: g_documento.solnom      : " ,g_documento.solnom clipped
             display m_current, " APOIO [13] - Parametro: w_cts00m40.c24astcod    : " ,w_cts00m40.c24astcod
             display m_current, " APOIO [13] - Parametro: g_issk.funmat           : " ,g_issk.funmat
             display m_current, " APOIO [13] - Parametro: g_documento.ligcvntip   : " ,g_documento.ligcvntip
             display m_current, " APOIO [13] - Parametro: g_c24paxnum             : " ,g_c24paxnum
             display m_current, " APOIO [13] - Parametro: aux_atdsrvnum           : " ,aux_atdsrvnum
             display m_current, " APOIO [13] - Parametro: aux_atdsrvano           : " ,aux_atdsrvano
             display m_current, " APOIO [13] - Parametro: "","","",""             : " ,"","","",""
             display m_current, " APOIO [13] - Parametro: g_documento.succod      : " ,g_documento.succod
             display m_current, " APOIO [13] - Parametro: g_documento.ramcod      : " ,g_documento.ramcod
             display m_current, " APOIO [13] - Parametro: g_documento.aplnumdig   : " ,g_documento.aplnumdig
             display m_current, " APOIO [13] - Parametro: g_documento.itmnumdig   : " ,g_documento.itmnumdig
             display m_current, " APOIO [13] - Parametro: g_documento.edsnumref   : " ,g_documento.edsnumref
             display m_current, " APOIO [13] - Parametro: g_documento.prporg      : " ,g_documento.prporg
             display m_current, " APOIO [13] - Parametro: g_documento.prpnumdig   : " ,g_documento.prpnumdig
             display m_current, " APOIO [13] - Parametro: g_documento.fcapacorg   : " ,g_documento.fcapacorg
             display m_current, " APOIO [13] - Parametro: g_documento.fcapacnum   : " ,g_documento.fcapacnum
             display m_current, " APOIO [13] - Parametro: "","","",""             : " ,"","","",""
             display m_current, " APOIO [13] - Parametro: ws.caddat,  ws.cadhor   : " ,ws.caddat,  ws.cadhor
             display m_current, " APOIO [13] - Parametro: ws.cademp,  ws.cadmat   : " ,ws.cademp,  ws.cadmat
             display m_current, " APOIO [13] - #rollback work", '/',aux_atdsrvnum,'-',aux_atdsrvano
             let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
             call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                  returning ws.sqlcode, ws.mensagem
             display 'ws.mensagem:',ws.mensagem clipped,'/',aux_atdsrvnum,'-',aux_atdsrvano
             return retorno.*
         end if
         let m_current = current
         display m_current, " APOIO [14] - Gravar Servico ", '/', aux_atdsrvnum, '-', aux_atdsrvano
         call cts10g02_grava_servico( aux_atdsrvnum       ,
                                      aux_atdsrvano       ,
                                      g_documento.soltip  ,     # atdsoltip
                                      g_documento.solnom  ,     # c24solnom
                                      ws.vclcorcod        ,
                                      g_issk.funmat       ,
                                      d_cts00m40.atdlibflg,
                                      d_cts00m40.atdlibhor,
                                      d_cts00m40.atdlibdat,
                                      w_cts00m40.atddat   ,     # atddat
                                      w_cts00m40.atdhor   ,     # atdhor
                                      ""                  ,     # atdlclflg
                                      w_cts00m40.atdhorpvt,
                                      ""                  ,     # Imediato
                                      ""                  ,     # Imediato
                                      "1"                 ,     # atdtip
                                      ""                  ,     # atdmotnom
                                      ""                  ,     # atdvclsgl
                                      w_cts00m40.atdprscod,
                                      ""                  ,     # atdcstvlr
                                      "N"                 ,     # atdfnlflg
                                      w_cts00m40.atdfnlhor,
                                      w_cts00m40.atdrsdflg,
                                      w_cts00m40.atddfttxt,
                                      ""                  ,     # atddoctxt
                                      w_cts00m40.c24opemat,
                                      d_cts00m40.nom      ,
                                      d_cts00m40.vcldes   ,
                                      d_cts00m40.vclanomdl,
                                      d_cts00m40.vcllicnum,
                                      d_cts00m40.corsus   ,
                                      d_cts00m40.cornom   ,
                                      w_cts00m40.cnldat   ,
                                      ""                  ,     # pgtdat
                                      w_cts00m40.c24nomctt,
                                      w_cts00m40.atdpvtretflg,
                                      w_cts00m40.atdvcltip,
                                      w_cts00m40.asitipcod,
                                      ""                  ,     # socvclcod
                                      d_cts00m40.vclcoddig,
                                      "N"                 ,     # srvprlflg
                                      ""                  ,     # srrcoddig
                                      d_cts00m40.atdprinvlcod,
                                      w_cts00m40.atdsrvorg    ) # atdsrvorg
              returning ws.tabname,
                        ws.sqlcode

         if  ws.sqlcode  <>  0  then
            let retorno.codigo = ws.sqlcode
            let retorno.descricao = "Problema ao gravar o servico. Cod Erro: ", ws.sqlcode, 
                                      "Tabela: ", ws.tabname clipped
            #rollback work
            let m_current = current
            display m_current, " APOIO [14] - Problema ao gravar o servico "
            display m_current, " APOIO [14] - #rollback work", '/',aux_atdsrvnum,'-',aux_atdsrvano
            let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
            call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                 returning ws.sqlcode, ws.mensagem
            return retorno.*
         end if

       #-------------------------------------------------------------------------
       # Grava complemento do servico
       #-------------------------------------------------------------------------
         let m_current = current
         display m_current, " APOIO [15] - Gravar Complementos", '/', aux_atdsrvnum, '-', aux_atdsrvano
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
                                      w_cts00m40.vclcamtip,
                                      w_cts00m40.vclcrcdsc,
                                      w_cts00m40.vclcrgflg,
                                      w_cts00m40.vclcrgpso,
                                      w_cts00m40.sinvitflg,
                                      w_cts00m40.bocflg   ,
                                      w_cts00m40.bocnum   ,
                                      w_cts00m40.bocemi   ,
                                      w_cts00m40.vcllibflg,
                                      w_cts00m40.roddantxt,
                                      w_cts00m40.rmcacpflg,
                                      d_cts00m40.sindat   ,
                                      d_cts00m40.sinhor    )

         if sqlca.sqlcode <> 0 then
               let retorno.codigo = ws.sqlcode
               let retorno.descricao = "Problema ao gravar o complento do servico. Cod Erro: ", ws.sqlcode, 
                                      "Tabela: DATMSERVICOCMP"
               let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
               let m_current = current
               display m_current, " APOIO [15] - Problema ao gravar complementos do servico. Erro: ", sqlca.sqlcode
               call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                    returning ws.sqlcode, ws.mensagem
               return retorno.*
         end if

       #-------------------------------------------------------------------------
       # Grava locais de (1) ocorrencia  / (2) destino
       #-------------------------------------------------------------------------

         for arr_aux = 1 to 2
             let m_current = current
             display m_current, " APOIO [16] - Gravar locais, passagem numero: ", arr_aux, '/',aux_atdsrvnum,'-',aux_atdsrvano
             if arr_aux = 2 and d_cts00m40.dstflg = "N" then
                exit for
             end IF

             if  a_cts00m40[arr_aux].operacao is null  then
                 let a_cts00m40[arr_aux].operacao = "I"
             end if


             call cts06g07_local( a_cts00m40[arr_aux].operacao    ,
                                  aux_atdsrvnum                   ,
                                  aux_atdsrvano                   ,
                                  arr_aux                         ,
                                  a_cts00m40[arr_aux].lclidttxt   ,
                                  a_cts00m40[arr_aux].lgdtip      ,
                                  a_cts00m40[arr_aux].lgdnom      ,
                                  a_cts00m40[arr_aux].lgdnum      ,
                                  a_cts00m40[arr_aux].lclbrrnom   ,
                                  a_cts00m40[arr_aux].brrnom      ,
                                  a_cts00m40[arr_aux].cidnom      ,
                                  a_cts00m40[arr_aux].ufdcod      ,
                                  a_cts00m40[arr_aux].lclrefptotxt,
                                  a_cts00m40[arr_aux].endzon      ,
                                  a_cts00m40[arr_aux].lgdcep      ,
                                  a_cts00m40[arr_aux].lgdcepcmp   ,
                                  a_cts00m40[arr_aux].lclltt      ,
                                  a_cts00m40[arr_aux].lcllgt      ,
                                  a_cts00m40[arr_aux].dddcod      ,
                                  a_cts00m40[arr_aux].lcltelnum   ,
                                  a_cts00m40[arr_aux].lclcttnom   ,
                                  a_cts00m40[arr_aux].c24lclpdrcod,
                                  a_cts00m40[arr_aux].ofnnumdig,
                                  a_cts00m40[arr_aux].emeviacod   ,
                                  a_cts00m40[arr_aux].celteldddcod,
                                  a_cts00m40[arr_aux].celtelnum   ,
                                  a_cts00m40[arr_aux].endcmp )  #Amilton
                  returning ws.sqlcode

             if ws.sqlcode <> 0 then
                   let retorno.codigo = ws.sqlcode
                   let retorno.descricao = "Problema ao gravar os enderecos."
                   #rollback work
                   let m_current = current
                   display m_current, " APOIO [16] - Problema ao gravar local do servico, passagem: ", arr_aux
                   display "#rollback work", '/',aux_atdsrvnum,'-',aux_atdsrvano
                   let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
                   call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                        returning ws.sqlcode, ws.mensagem
                   return retorno.*
             end if
         end for

       #-------------------------------------------------------------------------
       # Grava etapas do acompanhamento
       #-------------------------------------------------------------------------

        let w_cts00m40.atdetpcod = 1

        let m_current = current
        display m_current, " APOIO [17] - Gravar etapa", '/',aux_atdsrvnum,'-',aux_atdsrvano
        call cts10g04_insere_etapa(aux_atdsrvnum,
                                   aux_atdsrvano,
                                   w_cts00m40.atdetpcod,
                                   w_cts00m40.atdprscod,
                                   w_cts00m40.c24nomctt,
                                   "",
                                   "")
             returning ws.sqlcode

         if ws.sqlcode <> 0 then
            let retorno.codigo = ws.sqlcode
            let retorno.descricao = "Problema ao inserir a etapa."
            #rollback work
            let m_current = current
            display m_current, " APOIO [17] - Problema ao gravar a etapa"
            display m_current, " APOIO [17] - #rollback work", '/',aux_atdsrvnum,'-',aux_atdsrvano
            let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
            call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                 returning ws.sqlcode, ws.mensagem
            return retorno.*
         end if

       #------------------------------------------------------------------------------
       # Grava problemas do servico
       #------------------------------------------------------------------------------
         let m_current = current
         display m_current, " APOIO [18] - Gravar Problema", '/',aux_atdsrvnum,'-',aux_atdsrvano
         call ctx09g02_inclui(aux_atdsrvnum       ,
                              aux_atdsrvano       ,
                              1                   , # Org. informacao 1-Segurado 2-Pst
                              w_cts00m40.c24pbmcod,
                              w_cts00m40.atddfttxt,
                              ""                  ) # Codigo prestador
              returning ws.sqlcode,
                        ws.tabname

         if ws.sqlcode <> 0 then
               let retorno.codigo = ws.sqlcode
               let retorno.descricao = "Problema ao obter o documento da ligacao. Cod Erro: ", ws.sqlcode, 
                                      "Tabela: ", ws.tabname clipped
               #rollback work
               let m_current = current
               display m_current, " APOIO [18] - Problemas ao Gravar o Problema"
               display m_current, " APOIO [18] - #rollback work", '/',aux_atdsrvnum,'-',aux_atdsrvano
               let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
               call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                    returning ws.sqlcode, ws.mensagem
               return retorno.*
         end if

       #-------------------------------------------------------------------------
       # Grava relacionamento servico / apolice
       #-------------------------------------------------------------------------
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
                            ws.sqlcode
             let m_current = current
             display m_current, " APOIO [19] - Gravar Servico Apolice - ws.sqlcode: ", ws.sqlcode

             if ws.sqlcode <> 0 then
                let retorno.codigo = ws.sqlcode
                let retorno.descricao = "Problema ao gravar servico x apolice. Cod Erro: ", ws.sqlcode, 
                                      "Tabela: ", ws.tabname clipped
                #rollback work
                let m_current = current
                display m_current, " APOIO [19] - Poblema ao Gravar Servico x Apolice"
                display m_current, " APOIO [19] - #rollback work", '/',aux_atdsrvnum,'-',aux_atdsrvano
                let ws.mensagem = "SOLICITACAO DE APOIO NAO REALIZADA *** TENTE NOVAMENTE. SE NECESSARIO, ENTRE EM CONTATO COM A CENTRAL DE OPERACOES."
                call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
                     returning ws.sqlcode, ws.mensagem
                return retorno.*
             end if

         end if

       #------------------------------------------------------------------------------
       # Grava historico do servico
       #------------------------------------------------------------------------------
       let ws.historico1 = "APOIO AO SERVICO ", w_cts00m40.atdsrvorg using "&&", "/", param.atdsrvnum using "&&&&&&&", "-", param.atdsrvano using "&&",
                           " DE ", d_cts00m40.asitipabvdes clipped, " SOLICITADO VIA GPS"
       let ws.historico2 = "PELO QRA ", ws.srrcoddig using "<<<<<<&", " - ", ws.srrabvnom clipped, " DA VIATURA ", ws.atdvclsgl clipped, "."

       call cts10g02_historico(aux_atdsrvnum      , aux_atdsrvano,
                              w_cts00m40.atddat   , w_cts00m40.atdhor,
                              g_issk.funmat       ,                         # Sistema
                              ws.historico1,ws.historico2,"","","")
                    returning ws.histerr
       let m_current = current
       display m_current, " APOIO [20] - Gravar Histórico - ws.histerr: ", ws.histerr, '/',aux_atdsrvnum,'-',aux_atdsrvano
     # Ponto de acesso apos a gravacao do laudo
     call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                                 aux_atdsrvano)
   #commit work
   let m_current = current
   display m_current, " APOIO [20] - #commit work - historico", '/',aux_atdsrvnum,'-',aux_atdsrvano

   if cts34g00_acion_auto (w_cts00m40.atdsrvorg,
                           a_cts00m40[1].cidnom,
                           a_cts00m40[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (w_cts00m40.atdsrvorg,
                                         w_cts00m40.c24astcod,
                                         w_cts00m40.asitipcod,
                                         a_cts00m40[1].lclltt,
                                         a_cts00m40[1].lcllgt,
                                         "N",                    # Prestador no local
                                         d_cts00m40.frmflg,
                                         aux_atdsrvnum,
                                         aux_atdsrvano,
                                         " ",
                                         d_cts00m40.vclcoddig,
                                         d_cts00m40.camflg) then
        #display "Servico acionado manual"
     else
        #display "Servico foi para acionamento automatico!!"
     end if
   else
     #display "Servico acionado manual"
   end if

   # ENVIA MENSAGEM DE CONFIRMACAO DE APOIO AO MID
   let ws.mensagem = g_documento.solnom clipped, ", SUA SOLICITACAO DE APOIO FOI ABERTA COM SUCESSO *** QRU: ", w_cts00m40.atdsrvorg using "&&", "/",
                                                                aux_atdsrvnum using "&&&&&&&", "-",
                                                                aux_atdsrvano using "&&",
                                                                " (", w_cts00m40.asitipdes clipped, ")"

   call ctx01g07_envia_msg_id("","",param.mdtcod, ws.mensagem)
        returning ws.sqlcode, ws.mensagem
   let m_current = current
   display m_current, " APOIO [21] - Envio de Mensagem - ws.sqlcode - ws.mensagem: ", ws.sqlcode, '-', ws.mensagem clipped

   exit while
 end while

 return retorno.*

end function  ###  cts00m40_apoio