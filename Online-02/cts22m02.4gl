#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS22M02                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 205.206 - AZUL SEGUROS                                     #
#                  LAUDO - ASSISTENCIA A PASSAGEIROS(HOSPEDAGEM).             #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 13/08/2009 Sergio Burini   PSI 244236 Inclusão do Sub-Dairro                #
#-----------------------------------------------------------------------------#
# 05/01/2010  Amilton                   Projeto sucursal smallint             #
#-----------------------------------------------------------------------------#
# 01/10/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario  #
#
# 12/08/2012 Fornax-Hamilton PSI-2012-16125/EV Inclusao de tratativas para as #
#                                              clausulas 37D, 37E, 37F, 37G   #
#-----------------------------------------------------------------------------#
# 13/05/2015  Roberto Fornax           Mercosul                               #
#-----------------------------------------------------------------------------#


#------------------------------------------------------------------------#
#                       OBSERVACOES IMPORTANTES                          #
#------------------------------------------------------------------------#
# ESTE MODULO E UMA COPIA DO CT22M00.                                    #
# APESAR DE SER UM FONTE NOVO, O NOME DAS VARIAVAIES ESTA FORA DO        #
# PADRAO. A MAIORIA DOS ACESSOS NAO ESTA PREPARADO NA FUNCAO PREPARE.    #
# EM RAZAO DO CURTO ESPACO DE TEMPO PARA ENTREGAR ESTE PROJETO DA AZUL,  #
# VAMOS LIBERAR EM PRODUCAO DESTA MANEIRA.                               #
# FUTURAMENTE VAMOS COLOCAR ESTE MODULO NO PADRAO DE CODIFICACAO.        #
#                                                                        #
# ASS: LUCAS SCHEID                                                      #
#------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define d_cts22m02   record
    servico          char (13)                         ,
    c24solnom        like datmligacao.c24solnom        ,
    nom              like datmservico.nom              ,
    doctxt           char (32)                         ,
    corsus           like datmservico.corsus           ,
    cornom           like datmservico.cornom           ,
    cvnnom           char (19)                         ,
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

 define w_cts22m02   record
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

 define a_cts22m02   array[2] of record
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

 define l_doc_handle   integer
 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

#-----------------------------#
function cts22m02(lr_parametro)
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
        l_mensagem   char(80)

#--------------------------------#
 define l_data       date,
        l_hora2      datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
  let l_azlaplcod  = null
  let l_resultado  = null
  let l_mensagem   = null
  let l_doc_handle = null

  initialize  ws.*  to  null
  initialize  mr_geral.*  to  null

  initialize mr_veiculo.*  to null
  initialize mr_segurado.* to null
  initialize mr_corretor.* to null
  initialize m_subbairro to null

  let g_documento.atdsrvorg = 3

 let int_flag   = false

 initialize d_cts22m02.* to null
 initialize w_cts22m02.* to null
 initialize mr_hotel to null

 initialize a_cts22m02 to null
 initialize a_passag   to null

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
 let g_documento.atdsrvorg    = 3
 let mr_geral.edsnumref    = lr_parametro.edsnumref
 let mr_geral.fcapacorg    = lr_parametro.fcapacorg
 let mr_geral.fcapacnum    = lr_parametro.fcapacnum
 let mr_geral.lignum       = lr_parametro.lignum
 let mr_geral.soltip       = lr_parametro.soltip
 let mr_geral.c24soltipcod = lr_parametro.c24soltipcod
 let mr_geral.lclocodesres = lr_parametro.lclocodesres

 let m_c24lclpdrcod = null

 if lr_parametro.aplnumdig is not null then
    # -> BUSCA O CODIGO DA APOLICE
    call ctd02g01_azlaplcod(lr_parametro.succod,
                            lr_parametro.ramcod,
                            lr_parametro.aplnumdig,
                            lr_parametro.itmnumdig,
                            lr_parametro.edsnumref)

         returning l_resultado,
                   l_mensagem,
                   l_azlaplcod

    if l_resultado <> 1 then
       error l_mensagem
       sleep 4
       return
    end if

    # -> BUSCA O XML DA APOLICE
    let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

    if l_doc_handle is null then
       error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
       return
    end if
 end if

 call cts40g03_data_hora_banco(2)
     returning l_data,
               l_hora2

 let aux_today       = l_data
 let aux_hora        = l_hora2
 let w_cts22m02.data = l_data
 let w_cts22m02.hora = l_hora2
 let w_cts22m02.ano  = w_cts22m02.data[9,10]
 let m_resultado     = null
 let m_mensagem      = null
 let m_srv_acionado  = false

 open window cts22m02 at 04,02 with form "cts22m02"
    attribute(form line 1)

 display "Azul Seguros" to msg_azul attribute(reverse)

 display "/" at 7,50
 display "-" at 7,58
 let w_cts22m02.ligcvntip = mr_geral.ligcvntip

#------------------------------------
# IDENTIFICACAO DO CONVENIO
#------------------------------------
 select cpodes into d_cts22m02.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts22m02.ligcvntip

 if mr_geral.atdsrvnum is not null  and
    mr_geral.atdsrvano is not null  then
    call cts22m02_consulta()

    display by name d_cts22m02.*
    display by name d_cts22m02.c24solnom attribute (reverse)
    ##display by name d_cts22m02.cvnnom    attribute (reverse)
    display by name mr_hotel.hsphotnom
                   ,mr_hotel.hsphotbrr
                   ,mr_hotel.hsphotcid
                   ,mr_hotel.hsphotrefpnt
                   ,mr_hotel.hsphottelnum
                   ,mr_hotel.hsphotcttnom

    if d_cts22m02.atdlibflg = "N"   then
       display by name d_cts22m02.atdlibdat attribute (invisible)
       display by name d_cts22m02.atdlibhor attribute (invisible)
    end if

    if w_cts22m02.atdfnlflg = "S"  then
       error " Atencao! Servico ja acionado!"
       let m_srv_acionado = true
    end if

    call cts22m02_modifica() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null then
       call cts10n00(mr_geral.atdsrvnum, mr_geral.atdsrvano,
                     g_issk.funmat, w_cts22m02.data, w_cts22m02.hora)
       let g_rec_his = true
    end if
 else
    if l_doc_handle is not null then
       # -> BUSCA OS DADOS DO XML DA APOLICE

       # -> DADOS DO SEGURADO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "SEGURADO")
            returning mr_segurado.nome,
                      mr_segurado.cgccpf,
                      mr_segurado.pessoa,
                      mr_segurado.dddfone,
                      mr_segurado.numfone,
                      mr_segurado.email

       # -> DADOS DO CORRETOR
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "CORRETOR")
            returning mr_corretor.susep,
                      mr_corretor.nome,
                      mr_corretor.dddfone,
                      mr_corretor.numfone,
                      mr_corretor.dddfax,
                      mr_corretor.numfax,
                      mr_corretor.email

       # -> DADOS DO VEICULO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "VEICULO")
            returning mr_veiculo.codigo,
                      mr_veiculo.marca,
                      mr_veiculo.tipo,
                      mr_veiculo.modelo,
                      mr_veiculo.chassi,
                      mr_veiculo.placa,
                      mr_veiculo.anofab,
                      mr_veiculo.anomod,
                      mr_veiculo.catgtar,
                      mr_veiculo.automatico

        let d_cts22m02.nom       = mr_segurado.nome
        let d_cts22m02.corsus    = mr_corretor.susep
        let d_cts22m02.cornom    = mr_corretor.nome
        let d_cts22m02.vclcoddig = mr_veiculo.codigo
        let d_cts22m02.vclanomdl = mr_veiculo.anomod
        let d_cts22m02.vcllicnum = mr_veiculo.placa
        let d_cts22m02.vcldes    = cts15g00(d_cts22m02.vclcoddig)

    end if

    if mr_geral.succod    is not null and
       mr_geral.ramcod    is not null and
       mr_geral.aplnumdig is not null and
       mr_geral.itmnumdig is not null then
       let d_cts22m02.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",#"&&", projeto succod
                                        " ", mr_geral.ramcod    using "##&&",
                                        " ", mr_geral.aplnumdig using "<<<<<<<<&"
    end if

    let d_cts22m02.c24solnom = mr_geral.solnom

    display by name d_cts22m02.*
    display by name d_cts22m02.c24solnom attribute (reverse)
    ##display by name d_cts22m02.cvnnom    attribute (reverse)

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call cts22m02_inclui()
         returning ws.grvflg

    if ws.grvflg = true  then
       call cts10n00(w_cts22m02.atdsrvnum, w_cts22m02.atdsrvano,
                     g_issk.funmat, w_cts22m02.data, w_cts22m02.hora)

       #-----------------------------------------------
       # Desbloqueio do servico
       #-----------------------------------------------
       if w_cts22m02.atdfnlflg = "N"  or
          w_cts22m02.atdfnlflg = "A" then
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts22m02.atdsrvnum
                             and atdsrvano = w_cts22m02.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts22m02.atdsrvnum,w_cts22m02.atdsrvano)
          end if
       end if

    end if
 end if

 close window cts22m02

end function

#---------------------------------------------------------------
 function cts22m02_consulta()
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

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  ws.*  to  null
 initialize mr_hotel to null

 select nom         ,
        vclcoddig   ,
        vcldes      ,
        vclanomdl   ,
        vcllicnum   ,
        corsus      ,
        cornom      ,
        vclcorcod   ,
        funmat      ,
        atddat      ,
        atdhor      ,
        atdlibflg   ,
        atdlibhor   ,
        atdlibdat   ,
        atdhorpvt   ,
        atdpvtretflg,
        atddatprg   ,
        atdhorprg   ,
        atdfnlflg   ,
        atdcstvlr   ,
        atdprinvlcod,
        ciaempcod   ,
        empcod                                                        #Raul, Biz
   into d_cts22m02.nom      ,
        d_cts22m02.vclcoddig,
        d_cts22m02.vcldes   ,
        d_cts22m02.vclanomdl,
        d_cts22m02.vcllicnum,
        d_cts22m02.corsus   ,
        d_cts22m02.cornom   ,
        w_cts22m02.vclcorcod,
        ws.funmat           ,
        w_cts22m02.atddat   ,
        w_cts22m02.atdhor   ,
        d_cts22m02.atdlibflg,
        d_cts22m02.atdlibhor,
        d_cts22m02.atdlibdat,
        w_cts22m02.atdhorpvt,
        w_cts22m02.atdpvtretflg,
        w_cts22m02.atddatprg,
        w_cts22m02.atdhorprg,
        w_cts22m02.atdfnlflg,
        w_cts22m02.atdcstvlr,
        d_cts22m02.atdprinvlcod,
        g_documento.ciaempcod,
        ws.empcod                                                     #Raul, Biz
   from datmservico
  where atdsrvnum = mr_geral.atdsrvnum and
        atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode = notfound then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(mr_geral.atdsrvnum,
                         mr_geral.atdsrvano,
                         1)
               returning a_cts22m02[1].lclidttxt   ,
                         a_cts22m02[1].lgdtip      ,
                         a_cts22m02[1].lgdnom      ,
                         a_cts22m02[1].lgdnum      ,
                         a_cts22m02[1].lclbrrnom   ,
                         a_cts22m02[1].brrnom      ,
                         a_cts22m02[1].cidnom      ,
                         a_cts22m02[1].ufdcod      ,
                         a_cts22m02[1].lclrefptotxt,
                         a_cts22m02[1].endzon      ,
                         a_cts22m02[1].lgdcep      ,
                         a_cts22m02[1].lgdcepcmp   ,
                         a_cts22m02[1].lclltt      ,
                         a_cts22m02[1].lcllgt      ,
                         a_cts22m02[1].dddcod      ,
                         a_cts22m02[1].lcltelnum   ,
                         a_cts22m02[1].lclcttnom   ,
                         a_cts22m02[1].c24lclpdrcod,
                         a_cts22m02[1].celteldddcod,
                         a_cts22m02[1].celtelnum   ,
                         a_cts22m02[1].endcmp   ,
                         ws.sqlcode                ,
                         a_cts22m02[1].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts22m02[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts22m02[1].brrnom,
                                a_cts22m02[1].lclbrrnom)
      returning a_cts22m02[1].lclbrrnom

 select ofnnumdig into a_cts22m02[1].ofnnumdig
   from datmlcl
  where atdsrvano = mr_geral.atdsrvano
    and atdsrvnum = mr_geral.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local",
          " de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts22m02[1].lgdtxt = a_cts22m02[1].lgdtip clipped, " ",
                            a_cts22m02[1].lgdnom clipped, " ",
                            a_cts22m02[1].lgdnum using "<<<<#"

#---------------------------------------------------------------
# Obtencao dos dados da ASSISTENCIA A PASSAGEIROS
#---------------------------------------------------------------

 select datmassistpassag.refatdsrvnum,
        datmassistpassag.refatdsrvano,
        datmassistpassag.asimtvcod   ,
        datmhosped.hpddiapvsqtd      ,
        datmhosped.hpdqrtqtd         ,
        datmservico.atdsrvorg,
        datmhosped.hspsegsit
   into d_cts22m02.refatdsrvnum      ,
        d_cts22m02.refatdsrvano      ,
        d_cts22m02.asimtvcod         ,
        d_cts22m02.hpddiapvsqtd      ,
        d_cts22m02.hpdqrtqtd         ,
        d_cts22m02.refatdsrvorg, d_cts22m02.seghospedado
   from datmassistpassag, datmhosped, outer datmservico
  where datmassistpassag.atdsrvnum = mr_geral.atdsrvnum  and
        datmassistpassag.atdsrvano = mr_geral.atdsrvano  and
        datmassistpassag.atdsrvnum = datmhosped.atdsrvnum   and
        datmassistpassag.atdsrvano = datmhosped.atdsrvano   and
        datmservico.atdsrvnum = datmassistpassag.refatdsrvnum and
        datmservico.atdsrvano = datmassistpassag.refatdsrvano

 if sqlca.sqlcode = notfound then
    error " Assistencia a passageiros nao encontrado. AVISE A INFORMATICA!"
    return
 end if

#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------
 let d_cts22m02.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into d_cts22m02.asimtvdes
   from datkasimtv
  where asimtvcod = d_cts22m02.asimtvcod

#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 declare ccts22m02001 cursor for
    select pasnom, pasidd, passeq
      from datmpassageiro
     where atdsrvnum = mr_geral.atdsrvnum
       and atdsrvano = mr_geral.atdsrvano
     order by passeq

 let arr_aux = 1

 foreach ccts22m02001 into a_passag[arr_aux].pasnom,
                           a_passag[arr_aux].pasidd,
                           ws.passeq

    let arr_aux = arr_aux + 1

    if arr_aux > 5 then
       error " Limite excedido. Foram encontrados mais de 5 passageiros!"
       exit foreach
    end if

 end foreach

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 let w_cts22m02.lignum = cts20g00_servico(mr_geral.atdsrvnum,
                                          mr_geral.atdsrvano)

 call cts20g01_docto(w_cts22m02.lignum)
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
    let d_cts22m02.doctxt = "Apolice.: ", mr_geral.succod    using "<<<&&",#"&&", projeto succod
                                     " ", mr_geral.ramcod    using "##&&",
                                   " ", mr_geral.aplnumdig using "<<<<<<<<&"
 end if

 select ligcvntip,
        c24solnom, c24astcod
   into w_cts22m02.ligcvntip,
        d_cts22m02.c24solnom, mr_geral.c24astcod
   from datmligacao
  where lignum = w_cts22m02.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts22m02.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts22m02.frmflg = "N"
 else
    let d_cts22m02.frmflg = "S"
 end if

 select cpodes into d_cts22m02.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts22m02.ligcvntip

#---------------------------------------------------------------
# Identificacao do ATENDENTE
#---------------------------------------------------------------

 let ws.funnom = "*** NAO CADASTRADO ***"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 let d_cts22m02.atdtxt = w_cts22m02.atddat         clipped, " ",
                         w_cts22m02.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

#---------------------------------------------------------------
# Descricao da COR do veiculo
#---------------------------------------------------------------

 select cpodes
   into d_cts22m02.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = w_cts22m02.vclcorcod

 if w_cts22m02.atdhorpvt is not null  or
    w_cts22m02.atdhorpvt =  "00:00"   then
    let d_cts22m02.imdsrvflg = "S"
 end if

 if w_cts22m02.atddatprg is not null   then
    let d_cts22m02.imdsrvflg = "N"
 end if

 if d_cts22m02.atdlibflg = "N"  then
    let d_cts22m02.atdlibdat = w_cts22m02.atddat
    let d_cts22m02.atdlibhor = w_cts22m02.atdhor
 end if

 let w_cts22m02.antlibflg = d_cts22m02.atdlibflg

 let d_cts22m02.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 let m_c24lclpdrcod = a_cts22m02[1].c24lclpdrcod

 select cpodes
   into d_cts22m02.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts22m02.atdprinvlcod

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

end function  ###  cts22m02_consulta

#---------------------------------------------------------------
 function cts22m02_modifica()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    sqlcode          integer
 end record

 define hist_cts22m02 record
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

        initialize  hist_cts22m02.*  to  null

        let     prompt_key  =  null
        let     w_retorno  =  null

        initialize  ws.*  to  null

        initialize  hist_cts22m02.*  to  null

 initialize ws.*  to null

 call cts22m02_input() returning hist_cts22m02.*

 if d_cts22m02.seghospedado = 'S' then
    call cts22m01_gravar('M'
                        ,mr_geral.atdsrvnum
                        ,mr_geral.atdsrvano
                        ,d_cts22m02.hpddiapvsqtd
                        ,d_cts22m02.hpdqrtqtd
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
    initialize a_cts22m02      to null
    initialize a_passag        to null
    initialize d_cts22m02.*    to null
    initialize w_cts22m02.*    to null
    clear form
    return false
 end if

 whenever error continue

 begin work

 update datmservico set ( nom           ,
                          corsus        ,
                          cornom        ,
                          vclcoddig     ,
                          vcldes        ,
                          vclanomdl     ,
                          vcllicnum     ,
                          vclcorcod     ,
                          atdlibflg     ,
                          atdlibdat     ,
                          atdlibhor     ,
                          atdhorpvt     ,
                          atddatprg     ,
                          atdhorprg     ,
                          atdpvtretflg  ,
                          asitipcod     ,
                          atdprinvlcod  )
                      = ( d_cts22m02.nom,
                          d_cts22m02.corsus,
                          d_cts22m02.cornom,
                          d_cts22m02.vclcoddig,
                          d_cts22m02.vcldes,
                          d_cts22m02.vclanomdl,
                          d_cts22m02.vcllicnum,
                          w_cts22m02.vclcorcod,
                          d_cts22m02.atdlibflg,
                          d_cts22m02.atdlibdat,
                          d_cts22m02.atdlibhor,
                          w_cts22m02.atdhorpvt,
                          w_cts22m02.atddatprg,
                          w_cts22m02.atdhorprg,
                          w_cts22m02.atdpvtretflg,
                          13, #d_cts22m02.asitipcod,
                          d_cts22m02.atdprinvlcod)
                    where atdsrvnum = mr_geral.atdsrvnum  and
                          atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do servico.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmassistpassag set ( refatdsrvnum ,
                               refatdsrvano ,
                               asimtvcod    ,
                               atddmccidnom ,
                               atddmcufdcod ,
                               atddstcidnom ,
                               atddstufdcod )
                           = ( d_cts22m02.refatdsrvnum,
                               d_cts22m02.refatdsrvano,
                               d_cts22m02.asimtvcod   ,
                               w_cts22m02.atddmccidnom,
                               w_cts22m02.atddmcufdcod,
                               w_cts22m02.atddstcidnom,
                               w_cts22m02.atddstufdcod)
                         where atdsrvnum = mr_geral.atdsrvnum  and
                               atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da assistencia.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmhosped set (hpddiapvsqtd,
                        hpdqrtqtd   )
                     = (d_cts22m02.hpddiapvsqtd,
                        d_cts22m02.hpdqrtqtd   )
                  where atdsrvnum = mr_geral.atdsrvnum  and
                        atdsrvano = mr_geral.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da hospedagem.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 delete from datmpassageiro
  where atdsrvnum = mr_geral.atdsrvnum
    and atdsrvano = mr_geral.atdsrvano

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

    select max(passeq)
      into ws.passeq
      from datmpassageiro
     where atdsrvnum = mr_geral.atdsrvnum  and
           atdsrvano = mr_geral.atdsrvano

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

    insert into datmpassageiro (atdsrvnum,
                                atdsrvano,
                                passeq,
                                pasnom,
                                pasidd)
                        values (mr_geral.atdsrvnum,
                                mr_geral.atdsrvano,
                                ws.passeq,
                                a_passag[arr_aux].pasnom,
                                a_passag[arr_aux].pasidd)

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao do ",
               arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 for arr_aux = 1 to 1
    if a_cts22m02[arr_aux].operacao is null  then
       let a_cts22m02[arr_aux].operacao = "M"
    end if
    let  a_cts22m02[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    call cts06g07_local(a_cts22m02[arr_aux].operacao,
                        mr_geral.atdsrvnum,
                        mr_geral.atdsrvano,
                        arr_aux,
                        a_cts22m02[arr_aux].lclidttxt,
                        a_cts22m02[arr_aux].lgdtip,
                        a_cts22m02[arr_aux].lgdnom,
                        a_cts22m02[arr_aux].lgdnum,
                        a_cts22m02[arr_aux].lclbrrnom,
                        a_cts22m02[arr_aux].brrnom,
                        a_cts22m02[arr_aux].cidnom,
                        a_cts22m02[arr_aux].ufdcod,
                        a_cts22m02[arr_aux].lclrefptotxt,
                        a_cts22m02[arr_aux].endzon,
                        a_cts22m02[arr_aux].lgdcep,
                        a_cts22m02[arr_aux].lgdcepcmp,
                        a_cts22m02[arr_aux].lclltt,
                        a_cts22m02[arr_aux].lcllgt,
                        a_cts22m02[arr_aux].dddcod,
                        a_cts22m02[arr_aux].lcltelnum,
                        a_cts22m02[arr_aux].lclcttnom,
                        a_cts22m02[arr_aux].c24lclpdrcod,
                        a_cts22m02[arr_aux].ofnnumdig,
                        a_cts22m02[arr_aux].emeviacod,
                        a_cts22m02[arr_aux].celteldddcod,
                        a_cts22m02[arr_aux].celtelnum,
                        a_cts22m02[arr_aux].endcmp   )
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

 if w_cts22m02.antlibflg <> d_cts22m02.atdlibflg  then
    if d_cts22m02.atdlibflg = "S"  then
       let w_cts22m02.atdetpcod = 1
       let ws.atdetpdat = d_cts22m02.atdlibdat
       let ws.atdetphor = d_cts22m02.atdlibhor
    else
       let w_cts22m02.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(mr_geral.atdsrvnum,
                               mr_geral.atdsrvano,
                               w_cts22m02.atdetpcod,
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

 ###call cts02m00_valida_indexacao(mr_geral.atdsrvnum,
 ###                               mr_geral.atdsrvano,
 ###                               m_c24lclpdrcod,
 ###                               a_cts22m02[1].c24lclpdrcod)

 whenever error stop

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts22m02[1].cidnom,
                          a_cts22m02[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         mr_geral.c24astcod,
                                         13,   #d_cts22m02.asitipcod,
                                         a_cts22m02[1].lclltt,
                                         a_cts22m02[1].lcllgt,
                                         "",
                                         d_cts22m02.frmflg,
                                         mr_geral.atdsrvnum,
                                         mr_geral.atdsrvano,
                                         " ",
                                         "", "") then
        #servico nao pode ser acionado automaticamente
        #display "Servico acionado manual"
     else
        #display "Servico foi para acionamento automatico!!"
     end if
  end if

 commit work
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(mr_geral.atdsrvnum,
                             mr_geral.atdsrvano)

 return true

end function

#-------------------------------
 function cts22m02_inclui()
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

 define hist_cts22m02    record
        hist1            like datmservhist.c24srvdsc,
        hist2            like datmservhist.c24srvdsc,
        hist3            like datmservhist.c24srvdsc,
        hist4            like datmservhist.c24srvdsc,
        hist5            like datmservhist.c24srvdsc
 end record

 define l_data       date,
        l_hora2      datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts22m02.*  to  null

        initialize  ws.*  to  null

        initialize  hist_cts22m02.*  to  null

 while true
   initialize ws.*  to null

   let g_documento.acao    = "INC"
   let w_cts22m02.operacao = "i"

   call cts22m02_input() returning hist_cts22m02.*

   if  int_flag then
       let int_flag  =  false
       initialize a_cts22m02      to null
       initialize a_passag        to null
       initialize d_cts22m02.*    to null
       initialize w_cts22m02.*    to null
       initialize hist_cts22m02.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
   if  w_cts22m02.data is null  or
       w_cts22m02.hora is null  then
       let w_cts22m02.data   = l_data
       let w_cts22m02.hora   = l_hora2
   end if

   if  w_cts22m02.funmat is null  then
       let w_cts22m02.funmat = g_issk.funmat
   end if

   if  d_cts22m02.frmflg = "S"  then
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


   if  w_cts22m02.atdfnlflg is null  then
       let w_cts22m02.atdfnlflg = "N"
       let w_cts22m02.c24opemat = g_issk.funmat  ###  Bloqueio do servico
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
       let ws.msg = "cts22m02 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let mr_geral.lignum      = ws.lignum
    let g_documento.lignum  = ws.lignum
   let w_cts22m02.atdsrvnum = ws.atdsrvnum
   let w_cts22m02.atdsrvano = ws.atdsrvano

   if d_cts22m02.seghospedado = 'S' then
      call cts22m01_gravar('I'
                          ,w_cts22m02.atdsrvnum
                          ,w_cts22m02.atdsrvano
                          ,d_cts22m02.hpddiapvsqtd
                          ,d_cts22m02.hpdqrtqtd
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
                            w_cts22m02.data         ,
                            w_cts22m02.hora         ,
                            mr_geral.c24soltipcod,
                            mr_geral.solnom      ,
                            mr_geral.c24astcod   ,
                            w_cts22m02.funmat       ,
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


   call cts10g02_grava_servico( w_cts22m02.atdsrvnum,
                                w_cts22m02.atdsrvano,
                                mr_geral.soltip  ,     # atdsoltip
                                mr_geral.solnom  ,     # c24solnom
                                w_cts22m02.vclcorcod,
                                w_cts22m02.funmat   ,
                                d_cts22m02.atdlibflg,
                                d_cts22m02.atdlibhor,
                                d_cts22m02.atdlibdat,
                                w_cts22m02.data     ,     # atddat
                                w_cts22m02.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts22m02.atdhorpvt,
                                w_cts22m02.atddatprg,
                                w_cts22m02.atdhorprg,
                                "H"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts22m02.atdprscod,
                                w_cts22m02.atdcstvlr,
                                w_cts22m02.atdfnlflg,
                                w_cts22m02.atdfnlhor,
                                w_cts22m02.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts22m02.c24opemat,
                                d_cts22m02.nom      ,
                                d_cts22m02.vcldes   ,
                                d_cts22m02.vclanomdl,
                                d_cts22m02.vcllicnum,
                                d_cts22m02.corsus   ,
                                d_cts22m02.cornom   ,
                                w_cts22m02.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts22m02.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                13,  #d_cts22m02.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts22m02.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts22m02.atdprinvlcod,
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
                          values ( w_cts22m02.atdsrvnum   ,
                                   w_cts22m02.atdsrvano   ,
                                   "N"                    ,
                                   d_cts22m02.refatdsrvnum,
                                   d_cts22m02.refatdsrvano,
                                   d_cts22m02.asimtvcod   ,
                                   w_cts22m02.atddmccidnom,
                                   w_cts22m02.atddmcufdcod,
                                   w_cts22m02.atddstcidnom,
                                   w_cts22m02.atddstufdcod )

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
    if d_cts22m02.seghospedado = "N" then

       insert into DATMHOSPED ( atdsrvnum   ,
                                atdsrvano   ,
                                hpddiapvsqtd,
                                hpdqrtqtd,
                                hspsegsit    )
                       values ( w_cts22m02.atdsrvnum   ,
                                w_cts22m02.atdsrvano   ,
                                d_cts22m02.hpddiapvsqtd,
                                d_cts22m02.hpdqrtqtd,
                                d_cts22m02.seghospedado)

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
              where atdsrvnum = w_cts22m02.atdsrvnum
                and atdsrvano = w_cts22m02.atdsrvano

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
                           values ( w_cts22m02.atdsrvnum    ,
                                    w_cts22m02.atdsrvano    ,
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
       if  a_cts22m02[arr_aux].operacao is null  then
           let a_cts22m02[arr_aux].operacao = "I"
       end if
       let a_cts22m02[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       call cts06g07_local( a_cts22m02[arr_aux].operacao    ,
                            w_cts22m02.atdsrvnum            ,
                            w_cts22m02.atdsrvano            ,
                            arr_aux                         ,
                            a_cts22m02[arr_aux].lclidttxt   ,
                            a_cts22m02[arr_aux].lgdtip      ,
                            a_cts22m02[arr_aux].lgdnom      ,
                            a_cts22m02[arr_aux].lgdnum      ,
                            a_cts22m02[arr_aux].lclbrrnom   ,
                            a_cts22m02[arr_aux].brrnom      ,
                            a_cts22m02[arr_aux].cidnom      ,
                            a_cts22m02[arr_aux].ufdcod      ,
                            a_cts22m02[arr_aux].lclrefptotxt,
                            a_cts22m02[arr_aux].endzon      ,
                            a_cts22m02[arr_aux].lgdcep      ,
                            a_cts22m02[arr_aux].lgdcepcmp   ,
                            a_cts22m02[arr_aux].lclltt      ,
                            a_cts22m02[arr_aux].lcllgt      ,
                            a_cts22m02[arr_aux].dddcod      ,
                            a_cts22m02[arr_aux].lcltelnum   ,
                            a_cts22m02[arr_aux].lclcttnom   ,
                            a_cts22m02[arr_aux].c24lclpdrcod,
                            a_cts22m02[arr_aux].ofnnumdig   ,
                            a_cts22m02[arr_aux].emeviacod   ,
                            a_cts22m02[arr_aux].celteldddcod,
                            a_cts22m02[arr_aux].celtelnum,
                            a_cts22m02[arr_aux].endcmp)
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
          where atdsrvnum = w_cts22m02.atdsrvnum
            and atdsrvano = w_cts22m02.atdsrvano

   if  ws.atdsrvseq is null  then
       let ws.atdsrvseq = 0
   end if

   if  w_cts22m02.atdetpcod is null  then
       if  d_cts22m02.atdlibflg = "S"  then
           let w_cts22m02.atdetpcod = 1
           let ws.etpfunmat = w_cts22m02.funmat
           let ws.atdetpdat = d_cts22m02.atdlibdat
           let ws.atdetphor = d_cts22m02.atdlibhor
       else
           let w_cts22m02.atdetpcod = 2
           let ws.etpfunmat = w_cts22m02.funmat
           let ws.atdetpdat = w_cts22m02.data
           let ws.atdetphor = w_cts22m02.hora
       end if
   else
       #let ws.atdsrvseq = ws.atdsrvseq + 1
       #
       #insert into DATMSRVACP ( atdsrvnum,
       #                         atdsrvano,
       #                         atdsrvseq,
       #                         atdetpcod,
       #                         atdetpdat,
       #                         atdetphor,
       #                         empcod   ,
       #                         funmat    )
       #                values ( w_cts22m02.atdsrvnum,
       #                         w_cts22m02.atdsrvano,
       #                         ws.atdsrvseq        ,
       #                         1                   ,
       #                         w_cts22m02.data     ,
       #                         w_cts22m02.hora     ,
       #                         g_issk.empcod       ,
       #                         w_cts22m02.funmat    )

       # 218545 - Burini
       call cts10g04_insere_etapa(w_cts22m02.atdsrvnum,
                                  w_cts22m02.atdsrvano,
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

       let ws.atdetpdat = w_cts22m02.cnldat
       let ws.atdetphor = w_cts22m02.atdfnlhor
       let ws.etpfunmat = w_cts22m02.c24opemat
   end if

   #let ws.atdsrvseq = ws.atdsrvseq + 1
   #
   #insert into DATMSRVACP ( atdsrvnum,
   #                         atdsrvano,
   #                         atdsrvseq,
   #                         atdetpcod,
   #                         atdetpdat,
   #                         atdetphor,
   #                         empcod   ,
   #                         funmat   ,
   #                         pstcoddig )
   #                values ( w_cts22m02.atdsrvnum,
   #                         w_cts22m02.atdsrvano,
   #                         ws.atdsrvseq        ,
   #                         w_cts22m02.atdetpcod,
   #                         ws.atdetpdat        ,
   #                         ws.atdetphor        ,
   #                         g_issk.empcod       ,
   #                         ws.etpfunmat        ,
   #                         w_cts22m02.atdprscod )

   call cts10g04_insere_etapa(w_cts22m02.atdsrvnum,
                              w_cts22m02.atdsrvano,
                              w_cts22m02.atdetpcod,
                              w_cts22m02.atdprscod, "", "", "")
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

      call cts10g02_grava_servico_apolice(w_cts22m02.atdsrvnum ,
                                          w_cts22m02.atdsrvano ,
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

         call cts10g02_grava_servico_apolice(w_cts22m02.atdsrvnum ,
                                             w_cts22m02.atdsrvano ,
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
   call cts00g07_apos_grvlaudo(w_cts22m02.atdsrvnum,
                               w_cts22m02.atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( w_cts22m02.atdsrvnum,
                            w_cts22m02.atdsrvano,
                            w_cts22m02.data     ,
                            w_cts22m02.hora     ,
                            w_cts22m02.funmat   ,
                            hist_cts22m02.*      )
        returning ws.histerr

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts22m02[1].cidnom,
                          a_cts22m02[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         mr_geral.c24astcod,
                                         13,   #d_cts22m02.asitipcod,
                                         a_cts22m02[1].lclltt,
                                         a_cts22m02[1].lcllgt,
                                         "",
                                         d_cts22m02.frmflg,
                                         w_cts22m02.atdsrvnum,
                                         w_cts22m02.atdsrvano,
                                         " ",
                                         "", "") then
        #servico nao pode ser acionado automaticamente
        #display "Servico acionado manual"
     else
        #display "Servico foi para acionamento automatico!!"
     end if
  end if

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let d_cts22m02.servico = g_documento.atdsrvorg using "&&",
                            "/", w_cts22m02.atdsrvnum using "&&&&&&&",
                            "-", w_cts22m02.atdsrvano using "&&"
   display by name d_cts22m02.servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function  ###  cts22m02_inclui

#--------------------------
 function cts22m02_input()
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

 define hist_cts22m02 record
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

 initialize  hist_cts22m02.*  to  null

 initialize ws.*  to null

 let ws.vcllicant = d_cts22m02.vcllicnum

 let l_vclcoddig_contingencia = d_cts22m02.vclcoddig

 input by name d_cts22m02.nom         ,
               d_cts22m02.corsus      ,
               d_cts22m02.cornom      ,
               d_cts22m02.vclcoddig   ,
               d_cts22m02.vclanomdl   ,
               d_cts22m02.vcllicnum   ,
               d_cts22m02.vclcordes   ,
               d_cts22m02.asimtvcod   ,
               d_cts22m02.refatdsrvorg,
               d_cts22m02.refatdsrvnum,
               d_cts22m02.refatdsrvano,
               d_cts22m02.seghospedado,
               d_cts22m02.hpddiapvsqtd,
               d_cts22m02.hpdqrtqtd   ,
               d_cts22m02.imdsrvflg   ,
               d_cts22m02.atdprinvlcod,
               d_cts22m02.atdlibflg   ,
               d_cts22m02.frmflg      without defaults

   before field nom
          display by name d_cts22m02.nom        attribute (reverse)

   after  field nom
          display by name d_cts22m02.nom

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                next field nom
          end if
          if d_cts22m02.nom is null  then
              error " Nome deve ser informado!"
              next field nom
           end if
           if mr_geral.atdsrvnum is null  and
              mr_geral.atdsrvano is null  then
              if mr_geral.succod    is not null  and
                 mr_geral.aplnumdig is not null  and
                 mr_geral.itmnumdig is not null  and
                 w_cts22m02.atddmccidnom is null    and
                 w_cts22m02.atddmcufdcod is null    then
                 call f_funapol_ultima_situacao (mr_geral.succod,
                                                 mr_geral.aplnumdig,
                                                 mr_geral.itmnumdig)
                                       returning g_funapol.*
                 select segnumdig
                   into ws.segnumdig
                   from abbmdoc
                 where succod    = mr_geral.succod     and
                       aplnumdig = mr_geral.aplnumdig  and
                       itmnumdig = mr_geral.itmnumdig  and
                       dctnumseq = g_funapol.dctnumseq

                select endcid, endufd
                  into w_cts22m02.atddmccidnom,
                       w_cts22m02.atddmcufdcod
                  from gsakend
                 where segnumdig = ws.segnumdig  and
                       endfld    = "1"
             end if

             call cts11m06(w_cts22m02.atddmccidnom,
                           w_cts22m02.atddmcufdcod,
                           w_cts22m02.atdocrcidnom,
                           w_cts22m02.atdocrufdcod,
                           w_cts22m02.atddstcidnom,
                           w_cts22m02.atddstufdcod)
                 returning w_cts22m02.atddmccidnom,
                           w_cts22m02.atddmcufdcod,
                           w_cts22m02.atdocrcidnom,
                           w_cts22m02.atdocrufdcod,
                           w_cts22m02.atddstcidnom,
                           w_cts22m02.atddstufdcod

             if w_cts22m02.atddmccidnom is null  or
                w_cts22m02.atddmcufdcod is null  or
                w_cts22m02.atdocrcidnom is null  or
                w_cts22m02.atdocrufdcod is null  or
                w_cts22m02.atddstcidnom is null  or
                w_cts22m02.atddstufdcod is null  then
                error " Localidades devem ser informadas para confirmacao",
                      " do direito de utilizacao!"
                next field nom
             end if

             if w_cts22m02.atddmccidnom = w_cts22m02.atdocrcidnom  and
                w_cts22m02.atddmcufdcod = w_cts22m02.atdocrufdcod  then
             #  error " Nao e' possivel a utilizacao da clausula de",
             #        " assistencia aos passageiros! "
                call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                              "A LOCAL DE DOMICILIO!","") returning ws.confirma
                if ws.confirma = "N"  then
                   next field nom
                end if
             end if

             let a_cts22m02[1].cidnom = w_cts22m02.atdocrcidnom
             let a_cts22m02[1].ufdcod = w_cts22m02.atdocrufdcod
          end if

          if w_cts22m02.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                   "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                  returning ws.confirma

             next field frmflg
          end if

   before field corsus
          display by name d_cts22m02.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts22m02.corsus

   before field cornom
          display by name d_cts22m02.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts22m02.cornom

   before field vclcoddig
          display by name d_cts22m02.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts22m02.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts22m02.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts22m02.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts22m02.vclcoddig is null  then
                call agguvcl() returning d_cts22m02.vclcoddig
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts22m02.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cts15g00(d_cts22m02.vclcoddig)
                 returning d_cts22m02.vcldes

             display by name d_cts22m02.vcldes
          end if

   before field vclanomdl
          display by name d_cts22m02.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts22m02.vclanomdl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclcoddig
          end if

          if d_cts22m02.vclanomdl is null then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts22m02.vclcoddig,
                         d_cts22m02.vclanomdl) = false  then
                error " Veiculo nao consta como fabricado em ",
                        d_cts22m02.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts22m02.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts22m02.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts22m02.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

        #---------------------------------------------------------------------
        # Chama verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if mr_geral.aplnumdig   is null       and
           d_cts22m02.vcllicnum    is not null   then

           if d_cts22m02.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.snhflg to null

              call cts13g00(mr_geral.c24astcod,
                            "", "", "", "",
                            d_cts22m02.vcllicnum,
                            "", "", "")
                  returning ws.blqnivcod, ws.snhflg
           end if
        end if

   before field vclcordes
          display by name d_cts22m02.vclcordes attribute (reverse)

   after  field vclcordes
          display by name d_cts22m02.vclcordes

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vcllicnum
          end if

          if d_cts22m02.vclcordes is not null then
             let ws.vclcordes = d_cts22m02.vclcordes[2,9]

             select cpocod into w_cts22m02.vclcorcod
               from iddkdominio
              where cponom      = "vclcorcod"  and
                    cpodes[2,9] = ws.vclcordes

             if sqlca.sqlcode = notfound  then
                error " Cor fora do padrao!"
                call c24geral4()
                     returning w_cts22m02.vclcorcod, d_cts22m02.vclcordes

                if w_cts22m02.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informada!"
                   next field vclcordes
                else
                   display by name d_cts22m02.vclcordes
                end if
             end if
          else
             call c24geral4()
                  returning w_cts22m02.vclcorcod, d_cts22m02.vclcordes

             if w_cts22m02.vclcorcod  is null   then
                error " Cor do veiculo deve ser informada!"
                next field  vclcordes
             else
                display by name d_cts22m02.vclcordes
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
                           mr_geral.itmnumdig, w_cts22m02.atddat,
                           mr_geral.ramcod)
          end if

   before field asimtvcod
          display by name d_cts22m02.asimtvcod attribute (reverse)

   after  field asimtvcod
          display by name d_cts22m02.asimtvcod

          ---> Funcao que retorna o Limite de Km p/ Taxi ou
          ---> Limite do Retorno - Ambos os casos so para
          ---> Clausula 37 ,37A ou 37B ou 37C ou 37D ou 37E ou 37F

          initialize l_desc_1, l_desc_2, l_clscod  to null

          call cts11m10_clausulas(l_doc_handle)
               returning l_desc_1 ---> Km Taxi
                        ,l_desc_2 ---> Limite so p/ Plus II
                        ,l_clscod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts22m02.asimtvcod is null  then
                call cts11m03(13)
                    returning d_cts22m02.asimtvcod

                if d_cts22m02.asimtvcod is not null  then
                   select asimtvdes
                     into d_cts22m02.asimtvdes
                     from datkasimtv
                    where asimtvcod = d_cts22m02.asimtvcod  and
                          asimtvsit = "A"

                   display by name d_cts22m02.asimtvcod
                   display by name d_cts22m02.asimtvdes

		   if l_clscod <> "37B" and
		      l_clscod <> "37C" and
		      l_clscod <> "37D" and #--> PSI-2012-16125/EV
		      l_clscod <> "37E" and #--> PSI-2012-16125/EV
		      l_clscod <> "37F" and #--> PSI-2012-16125/EV
		      l_clscod <> "37G" and #--> PSI-2012-16125/EV  
		      l_clscod <> "37H" then 
                      next field refatdsrvorg
                   end if
                else
                   next field asimtvcod
                end if
             else
                select asimtvdes
                  into d_cts22m02.asimtvdes
                  from datkasimtv
                 where asimtvcod = d_cts22m02.asimtvcod  and
                       asimtvsit = "A"

                if sqlca.sqlcode = notfound  then
                   error " Motivo invalido!"
                   call cts11m03(13)
                       returning d_cts22m02.asimtvcod
                   next field asimtvcod
                else
                   display by name d_cts22m02.asimtvcod
                end if

                select asimtvcod
                  from datrmtvasitip
                 where asitipcod = 13
                   and asimtvcod = d_cts22m02.asimtvcod

                if sqlca.sqlcode = notfound  then
                   error " Motivo nao pode ser informado para este tipo de",
                         " assistencia!"
                   next field asimtvcod
                end if
             end if

             display by name d_cts22m02.asimtvdes
          end if

           if l_clscod = "37B" or
	           l_clscod = "37D"  or #- PSI-2012-16125/EV
	           l_clscod = "37E"  or #- PSI-2012-16125/EV
	           l_clscod = "37F"  or #- PSI-2012-16125/EV
	           l_clscod = "37G"  or #- PSI-2012-16125/EV 
	           l_clscod = "37H"  then 
             call cts08g01("A","N","",
                           "LIMITE DE 2 DIARIAS "
                          ,"LIMITADO AO VALOR DE R$ 80,00 " #Alterado conforme solicitacao de Vinicius Henrique
                          ,"POR PESSOA")
                  returning ws.confirma
          end if

          if d_cts22m02.asimtvcod = 4  then   ##  Outras Situacoes
             call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
                  returning ws.confirma
          end if

   before field refatdsrvorg
          display by name d_cts22m02.refatdsrvorg attribute (reverse)

   after  field refatdsrvorg
          display by name d_cts22m02.refatdsrvorg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field asimtvcod
          end if

          if  d_cts22m02.refatdsrvorg is null  then
           if  mr_geral.succod    is not null  and
               mr_geral.aplnumdig is not null  then
               call cts11m12 ( mr_geral.succod   ,
                               mr_geral.aplnumdig,
                               mr_geral.itmnumdig, "",
                               mr_geral.ramcod,
                               l_doc_handle)
                     returning d_cts22m02.refatdsrvorg,
                               d_cts22m02.refatdsrvnum,
                               d_cts22m02.refatdsrvano
               display by name d_cts22m02.refatdsrvorg
               display by name d_cts22m02.refatdsrvnum
               display by name d_cts22m02.refatdsrvano

               if  d_cts22m02.refatdsrvnum is null  and
                   d_cts22m02.refatdsrvano is null  then

                   let a_cts22m02[1].cidnom = w_cts22m02.atddstcidnom
                   let a_cts22m02[1].ufdcod = w_cts22m02.atddstufdcod

                   let a_cts22m02[1].lclbrrnom = m_subbairro[1].lclbrrnom
                   call cts06g03( 3,
                                  2,
                                  w_cts22m02.ligcvntip,
                                  aux_today,
                                  aux_hora,
                                  a_cts22m02[1].lclidttxt,
                                  a_cts22m02[1].cidnom,
                                  a_cts22m02[1].ufdcod,
                                  a_cts22m02[1].brrnom,
                                  a_cts22m02[1].lclbrrnom,
                                  a_cts22m02[1].endzon,
                                  a_cts22m02[1].lgdtip,
                                  a_cts22m02[1].lgdnom,
                                  a_cts22m02[1].lgdnum,
                                  a_cts22m02[1].lgdcep,
                                  a_cts22m02[1].lgdcepcmp,
                                  a_cts22m02[1].lclltt,
                                  a_cts22m02[1].lcllgt,
                                  a_cts22m02[1].lclrefptotxt,
                                  a_cts22m02[1].lclcttnom,
                                  a_cts22m02[1].dddcod,
                                  a_cts22m02[1].lcltelnum,
                                  a_cts22m02[1].c24lclpdrcod,
                                  a_cts22m02[1].ofnnumdig,
                                  a_cts22m02[1].celteldddcod   ,
                                  a_cts22m02[1].celtelnum ,
                                  a_cts22m02[1].endcmp   ,
                                  hist_cts22m02.*,
                                  a_cts22m02[1].emeviacod)
                        returning a_cts22m02[1].lclidttxt,
                                  a_cts22m02[1].cidnom,
                                  a_cts22m02[1].ufdcod,
                                  a_cts22m02[1].brrnom,
                                  a_cts22m02[1].lclbrrnom,
                                  a_cts22m02[1].endzon,
                                  a_cts22m02[1].lgdtip,
                                  a_cts22m02[1].lgdnom,
                                  a_cts22m02[1].lgdnum,
                                  a_cts22m02[1].lgdcep,
                                  a_cts22m02[1].lgdcepcmp,
                                  a_cts22m02[1].lclltt,
                                  a_cts22m02[1].lcllgt,
                                  a_cts22m02[1].lclrefptotxt,
                                  a_cts22m02[1].lclcttnom,
                                  a_cts22m02[1].dddcod,
                                  a_cts22m02[1].lcltelnum,
                                  a_cts22m02[1].c24lclpdrcod,
                                  a_cts22m02[1].ofnnumdig,
                                  a_cts22m02[1].celteldddcod   ,
                                  a_cts22m02[1].celtelnum ,
                                  a_cts22m02[1].endcmp,
                                  ws.retflg,
                                  hist_cts22m02.*,
                                  a_cts22m02[1].emeviacod
                   # PSI 244589 - Inclusão de Sub-Bairro - Burini
                   let m_subbairro[1].lclbrrnom = a_cts22m02[1].lclbrrnom
                   call cts06g10_monta_brr_subbrr(a_cts22m02[1].brrnom,
                                                  a_cts22m02[1].lclbrrnom)
                        returning a_cts22m02[1].lclbrrnom

                   let a_cts22m02[1].lgdtxt = a_cts22m02[1].lgdtip clipped, " ",
                                              a_cts22m02[1].lgdnom clipped, " ",
                                              a_cts22m02[1].lgdnum using "<<<<#"

                   if  w_cts22m02.atddmccidnom = w_cts22m02.atdocrcidnom  and
                       w_cts22m02.atddmcufdcod = w_cts22m02.atdocrufdcod  then
                       {error " Nao e' possivel a utilizacao da clausula",
                             " de assistencia aos passageiros! "}
                       call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                     "A LOCAL DE DOMICILIO!","")
                            returning ws.confirma
                       if  ws.confirma = "N"  then
                           next field nom
                       end if
                   end if
                   
                   if a_cts22m02[1].ufdcod = "EX" then  
                      let ws.retflg = "S"               
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
               initialize d_cts22m02.refatdsrvano to null
               initialize d_cts22m02.refatdsrvnum to null
               display by name d_cts22m02.refatdsrvano
               display by name d_cts22m02.refatdsrvnum
           end if
          end if

          if  d_cts22m02.refatdsrvorg <> 4   and    # Remocao
              d_cts22m02.refatdsrvorg <> 6   and    # DAF
              d_cts22m02.refatdsrvorg <> 1   and    # Socorro
              d_cts22m02.refatdsrvorg <> 2   then   # Transporte
              error " Origem do servico de referencia deve ser",
                    " p/ SOCORRO ou REMOCAO!"
              next field refatdsrvorg
          end if

   before field refatdsrvnum
          display by name d_cts22m02.refatdsrvnum attribute (reverse)

   after  field refatdsrvnum
          display by name d_cts22m02.refatdsrvnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field refatdsrvorg
          end if

          if d_cts22m02.refatdsrvorg is not null  and
             d_cts22m02.refatdsrvnum is null      then
             error " Numero do servico de referencia nao informado!"
             next field refatdsrvnum
          end if

   before field refatdsrvano

          display by name d_cts22m02.refatdsrvano attribute (reverse)

   after  field refatdsrvano
          display by name d_cts22m02.refatdsrvano

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field refatdsrvnum
          end if

          if  d_cts22m02.refatdsrvnum is not null  then
           if  d_cts22m02.refatdsrvano is not null   then
               select atdsrvorg
                 into ws.refatdsrvorg
                 from DATMSERVICO
                      where atdsrvnum = d_cts22m02.refatdsrvnum
                        and atdsrvano = d_cts22m02.refatdsrvano

               if  ws.refatdsrvorg <> d_cts22m02.refatdsrvorg  then
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
                          where atdsrvnum = d_cts22m02.refatdsrvnum
                            and atdsrvano = d_cts22m02.refatdsrvano

                   if  sqlca.sqlcode <> notfound  then
                    ##if  ws.succod    <> mr_geral.succod     or
                    ##    ws.aplnumdig <> mr_geral.aplnumdig  or
                    ##    ws.itmnumdig <> mr_geral.itmnumdig  then
                    ##    error " Servico original nao pertence a esta apolice!"
                    ##    next field refatdsrvorg
                    ##end if
                   end if
               end if
           else
               error " Ano do servico original nao informado!"
               next field refatdsrvano
           end if
          end if

          let a_cts22m02[1].cidnom = w_cts22m02.atddstcidnom
          let a_cts22m02[1].ufdcod = w_cts22m02.atddstufdcod

          let a_cts22m02[1].lclbrrnom = m_subbairro[1].lclbrrnom
          call cts06g03( 3,
                         2,
                         w_cts22m02.ligcvntip,
                         aux_today,
                         aux_hora,
                         a_cts22m02[1].lclidttxt,
                         a_cts22m02[1].cidnom,
                         a_cts22m02[1].ufdcod,
                         a_cts22m02[1].brrnom,
                         a_cts22m02[1].lclbrrnom,
                         a_cts22m02[1].endzon,
                         a_cts22m02[1].lgdtip,
                         a_cts22m02[1].lgdnom,
                         a_cts22m02[1].lgdnum,
                         a_cts22m02[1].lgdcep,
                         a_cts22m02[1].lgdcepcmp,
                         a_cts22m02[1].lclltt,
                         a_cts22m02[1].lcllgt,
                         a_cts22m02[1].lclrefptotxt,
                         a_cts22m02[1].lclcttnom,
                         a_cts22m02[1].dddcod,
                         a_cts22m02[1].lcltelnum,
                         a_cts22m02[1].c24lclpdrcod,
                         a_cts22m02[1].ofnnumdig,
                         a_cts22m02[1].celteldddcod   ,
                         a_cts22m02[1].celtelnum ,
                         a_cts22m02[1].endcmp,
                         hist_cts22m02.*,
                         a_cts22m02[1].emeviacod)
               returning a_cts22m02[1].lclidttxt,
                         a_cts22m02[1].cidnom,
                         a_cts22m02[1].ufdcod,
                         a_cts22m02[1].brrnom,
                         a_cts22m02[1].lclbrrnom,
                         a_cts22m02[1].endzon,
                         a_cts22m02[1].lgdtip,
                         a_cts22m02[1].lgdnom,
                         a_cts22m02[1].lgdnum,
                         a_cts22m02[1].lgdcep,
                         a_cts22m02[1].lgdcepcmp,
                         a_cts22m02[1].lclltt,
                         a_cts22m02[1].lcllgt,
                         a_cts22m02[1].lclrefptotxt,
                         a_cts22m02[1].lclcttnom,
                         a_cts22m02[1].dddcod,
                         a_cts22m02[1].lcltelnum,
                         a_cts22m02[1].c24lclpdrcod,
                         a_cts22m02[1].ofnnumdig,
                         a_cts22m02[1].celteldddcod   ,
                         a_cts22m02[1].celtelnum ,
                         a_cts22m02[1].endcmp,
                         ws.retflg,
                         hist_cts22m02.*,
                         a_cts22m02[1].emeviacod
          # PSI 244589 - Inclusão de Sub-Bairro - Burini
          let m_subbairro[1].lclbrrnom = a_cts22m02[1].lclbrrnom
          call cts06g10_monta_brr_subbrr(a_cts22m02[1].brrnom,
                                         a_cts22m02[1].lclbrrnom)
               returning a_cts22m02[1].lclbrrnom

          let a_cts22m02[1].lgdtxt = a_cts22m02[1].lgdtip clipped, " ",
                                     a_cts22m02[1].lgdnom clipped, " ",
                                     a_cts22m02[1].lgdnum using "<<<<#"

          if  w_cts22m02.atddmccidnom = w_cts22m02.atdocrcidnom  and
              w_cts22m02.atddmcufdcod = w_cts22m02.atdocrufdcod  then
              {error " Nao e' possivel a utilizacao da clausula",
                    " de assistencia aos passageiros! "}
              call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                            "A LOCAL DE DOMICILIO!","") returning ws.confirma
              if  ws.confirma = "N"  then
                  next field nom
              end if
          end if
          
          if a_cts22m02[1].ufdcod = "EX" then            
             let ws.retflg = "S"                         
          end if                                         
          
          if  ws.retflg = "N"  then
              error " Dados referentes ao local incorretos ou nao preenchidos!"
              next field refatdsrvano
          end if

   before field seghospedado
      display by name d_cts22m02.seghospedado attribute (reverse)

   after field seghospedado
      display by name d_cts22m02.seghospedado

      if (d_cts22m02.seghospedado <> 'S' and
         d_cts22m02.seghospedado <> 'N') or d_cts22m02.seghospedado is null then
         error 'Digite "S" ou "N" '
         next field seghospedado
      end if

      if d_cts22m02.seghospedado = 'S' then
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
          display by name d_cts22m02.hpddiapvsqtd attribute (reverse)

   after  field hpddiapvsqtd
          display by name d_cts22m02.hpddiapvsqtd

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts22m02.hpddiapvsqtd is null  then
                error " Quantidade prevista de diarias deve ser informada!"
                next field hpddiapvsqtd
             end if

             if d_cts22m02.hpddiapvsqtd = 0  then
                error " Quantidade prevista de diarias nao pode ser zero!"
                next field hpddiapvsqtd
             end if
             if d_cts22m02.hpddiapvsqtd > 2  then
                call cts08g01("A","N","",
                              "LIMITE MAXIMO DE DUAS DIARIAS.",
                              "CONSULTE A COORDENACAO PARA ",
                              "LIBERAR ATENDIMENTO.")
                     returning ws.confirma
                {if ws.confirma = "N"  then}
                   next field hpddiapvsqtd
                {end if}
             end if
          end if

   before field hpdqrtqtd
          display by name d_cts22m02.hpdqrtqtd attribute (reverse)

   after  field hpdqrtqtd
          display by name d_cts22m02.hpdqrtqtd

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts22m02.hpdqrtqtd is null  then
                error " Numero de quartos deve ser informado!"
                next field hpdqrtqtd
             end if

             if d_cts22m02.hpdqrtqtd = 0  then
                error " Numero de quartos nao pode ser zero!"
                next field hpdqrtqtd
             end if

             {call cts08g01("A","N",
                           "",
                           "LIMITE POR VIGENCIA: 02 DIARIAS, SENDO",
                           "R$ 80,00 POR PESSOA/DIA." , "" )
                  returning ws.confirma}
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
          let d_cts22m02.imdsrvflg    = "S"
          let w_cts22m02.atdpvtretflg = "S"
          let w_cts22m02.atdhorpvt    = "00:00"

          initialize w_cts22m02.atddatprg to null
          initialize w_cts22m02.atdhorprg to null

          display by name d_cts22m02.imdsrvflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field hpdqrtqtd
          else
             next field atdprinvlcod
          end if

   after  field imdsrvflg
          display by name d_cts22m02.imdsrvflg

          if d_cts22m02.imdsrvflg = "N" then
             let d_cts22m02.atdprinvlcod  = 2
             select cpodes
               into d_cts22m02.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts22m02.atdprinvlcod

             display by name d_cts22m02.atdprinvlcod
             display by name d_cts22m02.atdprinvldes

             next field atdlibflg
          end if

   before field atdprinvlcod
          display by name d_cts22m02.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts22m02.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts22m02.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts22m02.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts22m02.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa,",
                      " (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts22m02.atdprinvldes

          end if

   before field atdlibflg
          display by name d_cts22m02.atdlibflg attribute (reverse)

          if mr_geral.atdsrvnum is not null then
             if w_cts22m02.atdfnlflg = "S"  then
                exit input
             end if
          end if

          if d_cts22m02.atdlibflg is null  and
             mr_geral.c24soltipcod = 1  then   # Tipo Solic = Segurado

          end if

   after  field atdlibflg
          display by name d_cts22m02.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if d_cts22m02.atdlibflg is null then
             error " Envio liberado deve ser informado!"
             next field atdlibflg
          end if

          if d_cts22m02.atdlibflg <> "S"  and
             d_cts22m02.atdlibflg <> "N"  then
             error " Informe (S)im ou (N)ao!"
             next field atdlibflg
          end if

         #call cts02m06() returning w_cts22m02.atdlibflg
          let w_cts22m02.atdlibflg   =  d_cts22m02.atdlibflg

          if w_cts22m02.atdlibflg is null   then
             next field atdlibflg
          end if

         #let d_cts22m02.atdlibflg = w_cts22m02.atdlibflg
          display by name d_cts22m02.atdlibflg

          if w_cts22m02.antlibflg is null  then
             if w_cts22m02.atdlibflg = "S"  then
                call cts40g03_data_hora_banco(2)
                   returning l_data, l_hora2
                let d_cts22m02.atdlibdat = l_data
                let d_cts22m02.atdlibhor =  l_hora2
             else
                let d_cts22m02.atdlibflg = "N"
                display by name d_cts22m02.atdlibflg
                initialize d_cts22m02.atdlibhor to null
                initialize d_cts22m02.atdlibdat to null
             end if
          else
             select atdfnlflg
               from datmservico
              where atdsrvnum = mr_geral.atdsrvnum  and
                    atdsrvano = mr_geral.atdsrvano  and
                    atdfnlflg in ("A","N") #PSI 198714
                     ## CT 5024358

             if sqlca.sqlcode = notfound  then
                error " Servico ja' acionado nao pode ser alterado!"
                let m_srv_acionado = true
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma
                next field atdlibflg
             end if

             if w_cts22m02.antlibflg = "S"  then
                if w_cts22m02.atdlibflg = "S"  then
                   exit input
                else
                   error " A liberacao do servico nao pode ser cancelada!"
                   next field atdlibflg
                   let d_cts22m02.atdlibflg = "N"
                   display by name d_cts22m02.atdlibflg
                   initialize d_cts22m02.atdlibhor to null
                   initialize d_cts22m02.atdlibdat to null
                   error " Liberacao do servico cancelada!"
                   sleep 1
                   exit input
                end if
             else
                if w_cts22m02.antlibflg = "N"  then
                   if w_cts22m02.atdlibflg = "N"  then
                      exit input
                   else
                      call cts40g03_data_hora_banco(2)
                         returning l_data, l_hora2
                      let d_cts22m02.atdlibdat = l_data
                      let d_cts22m02.atdlibhor = l_hora2
                      exit input
                   end if
                end if
             end if
          end if

   before field frmflg
          if w_cts22m02.operacao = "i"  then
             let d_cts22m02.frmflg = "N"
             display by name d_cts22m02.frmflg attribute (reverse)
          else
             if w_cts22m02.atdfnlflg = "S"  then
                call cts11g00(w_cts22m02.lignum)
                let int_flag = true
             end if

             exit input
          end if

   after  field frmflg
          display by name d_cts22m02.frmflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdlibflg
          end if

          if d_cts22m02.frmflg = "S"  then
             if d_cts22m02.atdlibflg = "N"  then
                error " Nao e' possivel registrar servico nao liberado",
                      " via formulario!"
                next field atdlibflg
             end if

             call cts02m05(2) returning w_cts22m02.data,
                                        w_cts22m02.hora,
                                        w_cts22m02.funmat,
                                        w_cts22m02.cnldat,
                                        w_cts22m02.atdfnlhor,
                                        w_cts22m02.c24opemat,
                                        w_cts22m02.atdprscod

             if w_cts22m02.hora      is null or
                w_cts22m02.data      is null or
                w_cts22m02.funmat    is null or
                w_cts22m02.cnldat    is null or
                w_cts22m02.atdfnlhor is null or
                w_cts22m02.c24opemat is null or
                w_cts22m02.atdprscod is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let d_cts22m02.atdlibhor = w_cts22m02.hora
             let d_cts22m02.atdlibdat = w_cts22m02.data
             let w_cts22m02.atdfnlflg = "S"
             let w_cts22m02.atdetpcod =  4
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

              if d_cts22m02.refatdsrvnum is null then
                 let l_servico = mr_geral.atdsrvnum
                 let l_ano     = mr_geral.atdsrvano
              else
                 let l_servico = d_cts22m02.refatdsrvnum
                 let l_ano     = d_cts22m02.refatdsrvano
              end if

              call ctx04g00_local_gps( l_servico,
                                       l_ano,
                                       1                       )
                             returning a_cts22m02[1].lclidttxt   ,
                                       a_cts22m02[1].lgdtip      ,
                                       a_cts22m02[1].lgdnom      ,
                                       a_cts22m02[1].lgdnum      ,
                                       a_cts22m02[1].lclbrrnom   ,
                                       a_cts22m02[1].brrnom      ,
                                       a_cts22m02[1].cidnom      ,
                                       a_cts22m02[1].ufdcod      ,
                                       a_cts22m02[1].lclrefptotxt,
                                       a_cts22m02[1].endzon      ,
                                       a_cts22m02[1].lgdcep      ,
                                       a_cts22m02[1].lgdcepcmp   ,
                                       a_cts22m02[1].lclltt      ,
                                       a_cts22m02[1].lcllgt      ,
                                       a_cts22m02[1].dddcod      ,
                                       a_cts22m02[1].lcltelnum   ,
                                       a_cts22m02[1].lclcttnom   ,
                                       a_cts22m02[1].c24lclpdrcod,
                                       a_cts22m02[1].celteldddcod,
                                       a_cts22m02[1].celtelnum   ,
                                       a_cts22m02[1].endcmp,
                                       ws.sqlcode                ,
                                       a_cts22m02[1].emeviacod

              select ofnnumdig into a_cts22m02[1].ofnnumdig
                from datmlcl
               where atdsrvano = mr_geral.atdsrvano
                 and atdsrvnum = mr_geral.atdsrvnum
                 and c24endtip = 1

              let a_cts22m02[1].lgdtxt = a_cts22m02[1].lgdtip clipped, " ",
                                         a_cts22m02[1].lgdnom clipped, " ",
                                         a_cts22m02[1].lgdnum using "<<<<#"

                   let a_cts22m02[1].lclbrrnom = m_subbairro[1].lclbrrnom

                   call cts06g03( 1, ## Local ocorrencia
                                  2,
                                  w_cts22m02.ligcvntip,
                                  aux_today,
                                  aux_hora,
                                  a_cts22m02[1].lclidttxt,
                                  a_cts22m02[1].cidnom,
                                  a_cts22m02[1].ufdcod,
                                  a_cts22m02[1].brrnom,
                                  a_cts22m02[1].lclbrrnom,
                                  a_cts22m02[1].endzon,
                                  a_cts22m02[1].lgdtip,
                                  a_cts22m02[1].lgdnom,
                                  a_cts22m02[1].lgdnum,
                                  a_cts22m02[1].lgdcep,
                                  a_cts22m02[1].lgdcepcmp,
                                  a_cts22m02[1].lclltt,
                                  a_cts22m02[1].lcllgt,
                                  a_cts22m02[1].lclrefptotxt,
                                  a_cts22m02[1].lclcttnom,
                                  a_cts22m02[1].dddcod,
                                  a_cts22m02[1].lcltelnum,
                                  a_cts22m02[1].c24lclpdrcod,
                                  a_cts22m02[1].ofnnumdig,
                                  a_cts22m02[1].celteldddcod   ,
                                  a_cts22m02[1].celtelnum ,
                                  a_cts22m02[1].endcmp,
                                  hist_cts22m02.*,
                                  a_cts22m02[1].emeviacod)
                        returning a_cts22m02[1].lclidttxt,
                                  a_cts22m02[1].cidnom,
                                  a_cts22m02[1].ufdcod,
                                  a_cts22m02[1].brrnom,
                                  a_cts22m02[1].lclbrrnom,
                                  a_cts22m02[1].endzon,
                                  a_cts22m02[1].lgdtip,
                                  a_cts22m02[1].lgdnom,
                                  a_cts22m02[1].lgdnum,
                                  a_cts22m02[1].lgdcep,
                                  a_cts22m02[1].lgdcepcmp,
                                  a_cts22m02[1].lclltt,
                                  a_cts22m02[1].lcllgt,
                                  a_cts22m02[1].lclrefptotxt,
                                  a_cts22m02[1].lclcttnom,
                                  a_cts22m02[1].dddcod,
                                  a_cts22m02[1].lcltelnum,
                                  a_cts22m02[1].c24lclpdrcod,
                                  a_cts22m02[1].ofnnumdig,
                                  a_cts22m02[1].celteldddcod   ,
                                  a_cts22m02[1].celtelnum ,
                                  a_cts22m02[1].endcmp,
                                  ws.retflg,
                                  hist_cts22m02.*,
                                  a_cts22m02[1].emeviacod

               #------------------------------------------------------------------------------
               # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
               #------------------------------------------------------------------------------
               if g_documento.lclocodesres = "S" then
                  let w_cts22m02.atdrsdflg = "S"
               else
                  let w_cts22m02.atdrsdflg = "N"
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
         call cts10m02 (hist_cts22m02.*)
              returning hist_cts22m02.*
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
         if d_cts22m02.atdlibflg = "N"   then
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

 return hist_cts22m02.*

end function
