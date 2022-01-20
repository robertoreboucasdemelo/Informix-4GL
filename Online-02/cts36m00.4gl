#############################################################################
# Nome do Modulo: CTS36M00                                         Priscila #
#                                                                  Mai/2006 #
# Gera servico de apoio para serviços de auto com local/condicao veiculo    #
# subsolo ou veiculo trancado ou quebra/perda chave codificada              #
#...........................................................................#
#                                                                           #
#                        * * * Alteracoes * * *                             #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts36m00_prepara  smallint

#--------------------------------------------------------------------#
function cts36m00_prepare()
#--------------------------------------------------------------------#
 define l_sql   char(700)

 let l_sql = "select ligdat, lighorinc, c24soltipcod, c24solnom, "
            ," c24astcod, c24funmat, ligcvntip, c24paxnum     "
            ," from datmligacao "
            ," where lignum = ? "
 prepare pcts36m00001  from l_sql
 declare ccts36m00001 cursor for pcts36m00001

 let l_sql = "select succod, ramcod, aplnumdig, "
            ," itmnumdig, edsnumref             "
            ," from datrligapol "
            ," where lignum = ? "
 prepare pcts36m00002  from l_sql
 declare ccts36m00002 cursor for pcts36m00002

 let l_sql = "select prporg, prpnumdig "
            ," from datrligprp         "
            ," where lignum = ?        "
 prepare pcts36m00003  from l_sql
 declare ccts36m00003 cursor for pcts36m00003

 let l_sql = "select fcapacorg, fcapacnum  "
            ," from datrligpac             "
            ," where lignum = ?            "
 prepare pcts36m00004  from l_sql
 declare ccts36m00004 cursor for pcts36m00004

 let l_sql = "select caddat, cadhor, cademp, cadmat "
            ," from datmligfrm  "
            ," where lignum = ? "
 prepare pcts36m00005  from l_sql
 declare ccts36m00005 cursor for pcts36m00005

 let l_sql = "select asitipcod, atdsoltip, vclcorcod, atdlibflg, "
            ," atdlibhor, atdlibdat, atddat, atdhor, atdhorpvt,  "
            ," atddatprg, atdhorprg, atdtip, atdprscod, atdfnlhor, "
            ," atdrsdflg, atddfttxt, c24opemat, nom, vcldes, vclanomdl, "
            ," vcllicnum, corsus, cornom, cnldat, c24nomctt, atdpvtretflg, "
            ," atdvcltip, vclcoddig, atdprinvlcod, atdsrvorg      "
            ," from datmservico     "
            ," where atdsrvnum = ?  "
            ,"   and atdsrvano = ?  "
 prepare pcts36m00006  from l_sql
 declare ccts36m00006 cursor for pcts36m00006

 let l_sql = "select sgdirbcod, roddantxt, vclcamtip, "
            ," vclcrcdsc, vclcrgflg, vclcrgpso, sinvitflg, "
            ," bocflg, bocnum, bocemi, vcllibflg, rmcacpflg, "
            ," sindat, c24sintip, c24sinhor, vicsnh, sinhor "
            ," from datmservicocmp "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
 prepare pcts36m00007  from l_sql
 declare ccts36m00007 cursor for pcts36m00007

 let l_sql = "select lclidttxt, lgdtip, lgdnom, lgdnum, "
            ," lclbrrnom, brrnom, cidnom, ufdcod, "
            ," lclrefptotxt, endzon, lgdcep, lgdcepcmp, "
            ," lclltt, lcllgt, dddcod, lcltelnum, "
            ," lclcttnom, c24lclpdrcod, ofnnumdig, emeviacod"
            ," from datmlcl "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
 prepare pcts36m00008  from l_sql
 declare ccts36m00008 cursor for pcts36m00008

 let l_sql = "insert into DATMSERVICOCMP ( atdsrvnum, sgdirbcod, "
            ," atdsrvano, roddantxt, vclcamtip, vclcrcdsc, "
            ," vclcrgflg, vclcrgpso, sinvitflg, bocflg, bocnum, "
            ," bocemi, vcllibflg, rmcacpflg, sindat, c24sintip, "
            ," c24sinhor, vicsnh, sinhor )"
            ," values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "
            ,"          ?, ?, ?, ?, ?, ?, ?, ?, ? )   "
 prepare pcts36m00009  from l_sql

 let l_sql = "insert into DATRSERVAPOL ( atdsrvnum, atdsrvano, "
            ," succod, ramcod, aplnumdig, itmnumdig, edsnumref )"
            ,"  values(?, ?, ?, ?, ?, ?, ? ) "
 prepare pcts36m00010  from l_sql

 let l_sql = "insert into DATMRPT(atdsrvnum, atdsrvano, "
            ," rptvclsitdsmflg, rptvclsitestflg, dddcod, telnum )"
            ," values(?, ?, ?, ?, ?, ?) "
  prepare pcts36m00011  from l_sql

  let l_sql = "select rptvclsitdsmflg, rptvclsitestflg, dddcod, telnum "
             ," from datmrpt "
             ," where atdsrvnum = ? "
             ,"   and atdsrvano = ? "
 prepare pcts36m00012  from l_sql
 declare ccts36m00012 cursor for pcts36m00012

 let l_sql = "select c24pbmdes "
            ," from datkpbm    "
            ," where c24pbmcod = ? "
 prepare pcts36m00013  from l_sql
 declare ccts36m00013 cursor for pcts36m00013

 let l_sql = " insert into datrsrvcnd  "
            ," (atdsrvnum,             "
            ,"  atdsrvano,             "
            ,"  succod   ,             "
            ,"  aplnumdig,             "
            ,"  itmnumdig,             "
            ,"  vclcndseq)             "
            ," values (?,?,?,?,?,?)    "
 prepare pcts36m00014  from l_sql

 let l_sql = "select vclcndseq    "
            ," from datrsrvcnd "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
 prepare pcts36m00015  from l_sql
 declare ccts36m00015 cursor for pcts36m00015

 let l_sql = "insert into datrcndlclsrv "
            ," (atdsrvnum, atdsrvano, vclcndlclcod) "
            ," values (?,?,?)           "
 prepare pcts36m00016  from l_sql

 let l_sql = "insert into datratdmltsrv "
            ," (atdsrvnum, atdsrvano, atdmltsrvnum, atdmltsrvano) "
            ," values (?,?,?,?)         "
 prepare pcts36m00017  from l_sql

 let  m_cts36m00_prepara =  true
end function

#--------------------------------------------------------------------#
function cts36m00(param)
#--------------------------------------------------------------------#
  define param         record
        lignum        like datmligacao.lignum,
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano,
        vclcndlclcod1  like datrcndlclsrv.vclcndlclcod,
        vclcndlclcod2  like datrcndlclsrv.vclcndlclcod,
        vclcndlclcod3  like datrcndlclsrv.vclcndlclcod
  end record

  define d_cts36m00    record
        lignum           like datmligacao.lignum,
        ligdat           like datmligacao.ligdat,
        lighorinc        like datmligacao.lighorinc,
        c24soltipcod     like datmligacao.c24soltipcod,
        solnom           like datmligacao.c24solnom,
        c24astcod        like datmligacao.c24astcod,
        c24funmat        like datmligacao.c24funmat,
        ligcvntip        like datmligacao.ligcvntip,
        c24paxnum        like datmligacao.c24paxnum,
        succod           like datrligapol.succod,
        ramcod           like datrligapol.ramcod,
        aplnumdig        like datrligapol.aplnumdig,
        itmnumdig        like datrligapol.itmnumdig,
        edsnumref        like datrligapol.edsnumref,
        prporg           like datrligprp.prporg,
        prpnumdig        like datrligprp.prpnumdig,
        fcapacorg        like datrligpac.fcapacorg,
        fcapacnum        like datrligpac.fcapacnum,
        caddat           like datmligfrm.caddat,
        cadhor           like datmligfrm.cadhor,
        cademp           like datmligfrm.cademp,
        cadmat           like datmligfrm.cadmat,
        atdsrvnum        like datmservico.atdsrvnum,
        atdsrvano        like datmservico.atdsrvano,
        asitipcod        like datmservico.asitipcod,
        atdsoltip        like datmservico.atdsoltip,
        vclcorcod        like datmservico.vclcorcod,
        atdlibflg        like datmservico.atdlibflg,
        atdlibhor        like datmservico.atdlibhor,
        atdlibdat        like datmservico.atdlibdat,
        atddat           like datmservico.atddat,
        atdhor           like datmservico.atdhor,
        atdhorpvt        like datmservico.atdhorpvt,
        atddatprg        like datmservico.atddatprg,
        atdhorprg        like datmservico.atdhorprg,
        atdtip           like datmservico.atdtip,
        atdprscod        like datmservico.atdprscod,
        atdfnlhor        like datmservico.atdfnlhor,
        atdrsdflg        like datmservico.atdrsdflg,
        atddfttxt        like datmservico.atddfttxt,
        c24opemat        like datmservico.c24opemat,
        nom              like datmservico.nom,
        vcldes           like datmservico.vcldes,
        vclanomdl        like datmservico.vclanomdl,
        vcllicnum        like datmservico.vcllicnum,
        corsus           like datmservico.corsus,
        cornom           like datmservico.cornom,
        cnldat           like datmservico.cnldat,
        c24nomctt        like datmservico.c24nomctt,
        atdpvtretflg     like datmservico.atdpvtretflg,
        atdvcltip        like datmservico.atdvcltip,
        vclcoddig        like datmservico.vclcoddig,
        atdprinvlcod     like datmservico.atdprinvlcod,
        atdsrvorg        like datmservico.atdsrvorg,
        sgdirbcod        like datmservicocmp.sgdirbcod,
        roddantxt        like datmservicocmp.roddantxt,
        vclcamtip        like datmservicocmp.vclcamtip,
        vclcrcdsc        like datmservicocmp.vclcrcdsc,
        vclcrgflg        like datmservicocmp.vclcrgflg,
        vclcrgpso        like datmservicocmp.vclcrgpso,
        sinvitflg        like datmservicocmp.sinvitflg,
        bocflg           like datmservicocmp.bocflg,
        bocnum           like datmservicocmp.bocnum,
        bocemi           like datmservicocmp.bocemi,
        vcllibflg        like datmservicocmp.vcllibflg,
        rmcacpflg        like datmservicocmp.rmcacpflg,
        sindat           like datmservicocmp.sindat,
        c24sintip        like datmservicocmp.c24sintip,
        c24sinhor        like datmservicocmp.c24sinhor,
        vicsnh           like datmservicocmp.vicsnh,
        sinhor           like datmservicocmp.sinhor,
        c24pbmcod        like datrsrvpbm.c24pbmcod
  end record

  define a_cts36m00    array[2] of record
        operacao       char (01),
        lclidttxt      like datmlcl.lclidttxt,
        lgdtip         like datmlcl.lgdtip,
        lgdnom         like datmlcl.lgdnom,
        lgdnum         like datmlcl.lgdnum,
        lclbrrnom      like datmlcl.lclbrrnom,
        brrnom         like datmlcl.brrnom,
        cidnom         like datmlcl.cidnom,
        ufdcod         like datmlcl.ufdcod,
        lclrefptotxt   like datmlcl.lclrefptotxt,
        endzon         like datmlcl.endzon,
        lgdcep         like datmlcl.lgdcep,
        lgdcepcmp      like datmlcl.lgdcepcmp,
        lclltt         like datmlcl.lclltt,
        lcllgt         like datmlcl.lcllgt,
        dddcod         like datmlcl.dddcod,
        lcltelnum      like datmlcl.lcltelnum,
        lclcttnom      like datmlcl.lclcttnom,
        c24lclpdrcod   like datmlcl.c24lclpdrcod,
        ofnnumdig      like datmlcl.ofnnumdig,
        emeviacod      like datmlcl.emeviacod,
        celteldddcod   like datmlcl.celteldddcod,
        celtelnum      like datmlcl.celtelnum,
        endcmp         like datmlcl.endcmp
  end record

  define hist_cts36m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
  end record

  define ws       record
        sqlcode       integer,
        msg           char(80),
        tabname       like systables.tabname,
        retorno       smallint,
        atdetpcod     like datmsrvacp.atdetpcod,
        frmflg        char(1),
        cdtseq        like datrsrvcnd.vclcndseq
  end record

  define rpt_cts36m00 record
      rptvclsitdsmflg   like datmrpt.rptvclsitdsmflg,
      rptvclsitestflg   like datmrpt.rptvclsitestflg,
      dddcod            like datmrpt.dddcod,
      telnum            like datmrpt.telnum
  end record

  define arr_aux      smallint,
         l_aux        smallint

  define l_camflg     char(01),
         l_ctgtrfcod  like abbmcasco.ctgtrfcod

  initialize d_cts36m00.* to null
  initialize a_cts36m00 to null
  initialize hist_cts36m00.* to null
  initialize ws.* to null
  initialize rpt_cts36m00.* to null

  let arr_aux = 1

  if m_cts36m00_prepara = false then
    call cts36m00_prepare()
  end if

  #acertar as variaveis vclcndlclcod (caso nao vanha a primeira)
  if param.vclcndlclcod1 is null then
     if param.vclcndlclcod2 is null then
        if param.vclcndlclcod3 is null then
           error "Local condicao veiculo invalido para servico de apoio."
           return
        else
           let param.vclcndlclcod1 = param.vclcndlclcod3
           let param.vclcndlclcod3 = null
        end if
     else
        let param.vclcndlclcod1 = param.vclcndlclcod2
        let param.vclcndlclcod2 = null
     end if
  end if
  if param.vclcndlclcod2 is null and
     param.vclcndlclcod3 is not null then
     let param.vclcndlclcod2 = param.vclcndlclcod3
     let param.vclcndlclcod3 = null
  end if


  #Codigo do problema depende da condicao/local veiculo
  if param.vclcndlclcod1 = 6 then
     #se local/condicao veiculo e subsolo
     # problema do servico e 113"LOCAL DIFICIL ACESSO"
     let d_cts36m00.c24pbmcod = 113
  else
     if param.vclcndlclcod1 = 10 or
        param.vclcndlclcod1 = 13 or
        param.vclcndlclcod1 = 14 then
        # se local/condicao veiculo e COM CHAVE CODE/NAO TEM CODIGO
        #ou se local/condicao veiculo e "VEICULO TRANCADO"
        #ou "QUEBRA/PERDA CHAVE CODIFICADA"
        #  problema do servico e 114"COMPLEMENTO DO EQUIPAMENTO"
        let d_cts36m00.c24pbmcod = 114
     end if
  end if


  #----------------------------------------------------------------------------
  #Ler informacoes necessarias para copia do servico original
  #----------------------------------------------------------------------------
  #ler dados da ligacao - datmligacao
  open ccts36m00001 using param.lignum
  whenever error continue
  fetch ccts36m00001 into d_cts36m00.ligdat      ,
                          d_cts36m00.lighorinc   ,
                          d_cts36m00.c24soltipcod,
                          d_cts36m00.solnom      ,
                          d_cts36m00.c24astcod   ,
                          d_cts36m00.c24funmat   ,
                          d_cts36m00.ligcvntip   ,
                          d_cts36m00.c24paxnum

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error "Geracao laudo de apoio - Ligacao original nao encontrada ",param.lignum
     else
        error "Geracao laudo de apoio - problemas ao buscar ligacao ",param.lignum
     end if
     return
  end if

  #ler dados da ligacao com apolice - datrligapol
  open ccts36m00002 using param.lignum
  whenever error continue
  fetch ccts36m00002 into d_cts36m00.succod    ,
                          d_cts36m00.ramcod    ,
                          d_cts36m00.aplnumdig ,
                          d_cts36m00.itmnumdig ,
                          d_cts36m00.edsnumref

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error "Geracao laudo de apoio - LigXApol original nao encontrada ",param.lignum
     else
        error "Geracao laudo de apoio - problemas ao buscar LigXApol ",param.lignum
     end if
     return
  end if


  #ler dados da ligacao com proposta - datrligprp
  open ccts36m00003 using param.lignum
  fetch ccts36m00003 into d_cts36m00.prporg,
                          d_cts36m00.prpnumdig


  #ler dados da ligacao com PAC  - datrligpac
  open ccts36m00004 using param.lignum
  fetch ccts36m00004 into d_cts36m00.fcapacorg,
                          d_cts36m00.fcapacnum


  #ler dados da ligacao com formulario - datmligfrm
  open ccts36m00005 using param.lignum
  whenever error continue
  fetch ccts36m00005 into d_cts36m00.caddat,
                          d_cts36m00.cadhor,
                          d_cts36m00.cademp,
                          d_cts36m00.cadmat

  whenever error stop
  if sqlca.sqlcode = 0 then
     #se encontrou registro em DATMLIGFRM - servico foi preenchido via formulario
     let ws.frmflg = "S"
  else
     let ws.frmflg = "N"
  end if

  #ler dados do servico - datmservico
  open ccts36m00006 using param.atdsrvnum,
                          param.atdsrvano
  whenever error continue
  fetch ccts36m00006 into d_cts36m00.asitipcod,
                          d_cts36m00.atdsoltip,
                          d_cts36m00.vclcorcod,
                          d_cts36m00.atdlibflg,
                          d_cts36m00.atdlibhor,
                          d_cts36m00.atdlibdat,
                          d_cts36m00.atddat,
                          d_cts36m00.atdhor,
                          d_cts36m00.atdhorpvt,
                          d_cts36m00.atddatprg,
                          d_cts36m00.atdhorprg,
                          d_cts36m00.atdtip,
                          d_cts36m00.atdprscod,
                          d_cts36m00.atdfnlhor,
                          d_cts36m00.atdrsdflg,
                          d_cts36m00.atddfttxt,
                          d_cts36m00.c24opemat,
                          d_cts36m00.nom,
                          d_cts36m00.vcldes,
                          d_cts36m00.vclanomdl,
                          d_cts36m00.vcllicnum,
                          d_cts36m00.corsus,
                          d_cts36m00.cornom,
                          d_cts36m00.cnldat,
                          d_cts36m00.c24nomctt,
                          d_cts36m00.atdpvtretflg,
                          d_cts36m00.atdvcltip,
                          d_cts36m00.vclcoddig,
                          d_cts36m00.atdprinvlcod,
                          d_cts36m00.atdsrvorg

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error "Geracao laudo de apoio - servico original nao encontrado ",param.atdsrvnum
     else
        error "Geracao laudo de apoio - problemas ao buscar servico ",param.atdsrvnum
     end if
     return
  end if

  #Tipo de assistencia depende da condicao/local veiculo
  #se local/condicao veiculo e subsolo
  #servico de apoio tem mesmo tipo assistencia que original
  #se local/condicao veiculo e "COM CHAVE CODE/NAO TEM CODIGO"
  #ou se local/condicao veiculo e "VEICULO TRANCADO"
  #ou "QUEBRA/PERDA CHAVE CODIFICADA"
  if param.vclcndlclcod1 = 10 or
     param.vclcndlclcod1 = 13 or
     param.vclcndlclcod1 = 14 then
     #if d_cts36m00.asitipcod = 4 then
        #se tipo de assistencia é 4 "CHAVAUTO"
        # altera tipo de assistemcia para 1 "GUINCHO"
        #pois e necessario enviar um chaveiro e um guincho
     #   let d_cts36m00.asitipcod = 1
     #else
        if d_cts36m00.asitipcod = 1 or
           d_cts36m00.asitipcod = 3 then
           #se tipo de assistencia é 1 "GUINCHO"
           #OU se tipo de assistencia é 3"GUINCHO TECNICO"
           #altera tipo de assistencia para 4"CHAVAUTO"
           #pois e necessario enviar um chaveiro e um guincho
           let d_cts36m00.asitipcod = 4
        end if
     #end if
  end if



  #envio nulo para c24opemat porque caso ele esteja preenchido servico fica travado
  let  d_cts36m00.c24opemat = " "

  #se assunto S10 - alterar descricao do problema
  if d_cts36m00.c24astcod = "S10" then
     open ccts36m00013 using d_cts36m00.c24pbmcod
     whenever error continue
     fetch ccts36m00013 into d_cts36m00.atddfttxt
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           error "Geracao laudo de apoio - problema nao encontrado ",d_cts36m00.c24pbmcod
        else
           error "Geracao laudo de apoio - problemas ao buscar descr. problema ",d_cts36m00.c24pbmcod
        end if
        return
     end if
  end if


  #ler dados do complemento do servico - datmservicocmp
  open ccts36m00007 using param.atdsrvnum,
                          param.atdsrvano
  whenever error continue
  fetch ccts36m00007 into d_cts36m00.sgdirbcod,
                          d_cts36m00.roddantxt,
                          d_cts36m00.vclcamtip,
                          d_cts36m00.vclcrcdsc,
                          d_cts36m00.vclcrgflg,
                          d_cts36m00.vclcrgpso,
                          d_cts36m00.sinvitflg,
                          d_cts36m00.bocflg,
                          d_cts36m00.bocnum,
                          d_cts36m00.bocemi,
                          d_cts36m00.vcllibflg,
                          d_cts36m00.rmcacpflg,
                          d_cts36m00.sindat,
                          d_cts36m00.c24sintip,
                          d_cts36m00.c24sinhor,
                          d_cts36m00.vicsnh,
                          d_cts36m00.sinhor

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error "Geracao laudo de apoio - complemento servico original nao encontrado ",param.atdsrvnum
     else
        error "Geracao laudo de apoio - problemas ao buscar complemento servico ",param.atdsrvnum
     end if
     return
  end if

  #ler locais de ocorrencia do servico
  open ccts36m00008 using param.atdsrvnum,
                          param.atdsrvano
  whenever error continue
  foreach ccts36m00008 into a_cts36m00[arr_aux].lclidttxt   ,
                            a_cts36m00[arr_aux].lgdtip      ,
                            a_cts36m00[arr_aux].lgdnom      ,
                            a_cts36m00[arr_aux].lgdnum      ,
                            a_cts36m00[arr_aux].lclbrrnom   ,
                            a_cts36m00[arr_aux].brrnom      ,
                            a_cts36m00[arr_aux].cidnom      ,
                            a_cts36m00[arr_aux].ufdcod      ,
                            a_cts36m00[arr_aux].lclrefptotxt,
                            a_cts36m00[arr_aux].endzon      ,
                            a_cts36m00[arr_aux].lgdcep      ,
                            a_cts36m00[arr_aux].lgdcepcmp   ,
                            a_cts36m00[arr_aux].lclltt      ,
                            a_cts36m00[arr_aux].lcllgt      ,
                            a_cts36m00[arr_aux].dddcod      ,
                            a_cts36m00[arr_aux].lcltelnum   ,
                            a_cts36m00[arr_aux].lclcttnom   ,
                            a_cts36m00[arr_aux].c24lclpdrcod,
                            a_cts36m00[arr_aux].ofnnumdig   ,
                            a_cts36m00[arr_aux].emeviacod

      if arr_aux > 2 then
         error "Limite array excedido"
         exit foreach
      end if
      let arr_aux = arr_aux + 1
  end foreach
  if arr_aux = 1 then   #nao encontrou nenhum registro de local
     error "Geracao laudo de apoio - locais nao encontrados ", param.atdsrvnum
     return
  end if

  #ler informacoes do veiculo perda total - datmrpt
  if d_cts36m00.c24astcod = "RPT" then

       open ccts36m00012 using param.atdsrvnum,
                               param.atdsrvano
       whenever error continue
       fetch ccts36m00012 into rpt_cts36m00.rptvclsitdsmflg,
                               rpt_cts36m00.rptvclsitestflg,
                               rpt_cts36m00.dddcod         ,
                               rpt_cts36m00.telnum

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Geracao laudo de apoio - inf. veiculo original nao encontrado ",param.atdsrvnum
          else
             error "Geracao laudo de apoio - problemas ao buscar inf. veiculo ",param.atdsrvnum
          end if
          return
       end if
  end if

  #buscar sequencia do condutor em datrsrvcnd
  if d_cts36m00.c24astcod = "G10" or
     d_cts36m00.c24astcod = "G11" or
     d_cts36m00.c24astcod = "S10" then
     open ccts36m00015 using param.atdsrvnum,
                             param.atdsrvano
     fetch ccts36m00015 into ws.cdtseq
  end if
  
  #------------------------------------------------------------------------------ 
  # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia                  
  #------------------------------------------------------------------------------ 
                                                                                  
  if g_documento.lclocodesres = "S" then                                          
     let d_cts36m00.atdrsdflg = "S"                                               
  else                                                                            
     let d_cts36m00.atdrsdflg = "N"                                               
  end if                                                                          
  
  #-----------------------------------------------------------------------------
  # Gravar novo servico (apoio)
  #-----------------------------------------------------------------------------
  while true
    begin work

    #buscar numero do servico e da ligação utilizando o mesmo atdtip do original
    call cts10g03_numeracao( 2, d_cts36m00.atdtip )
         returning d_cts36m00.lignum,
                   d_cts36m00.atdsrvnum,
                   d_cts36m00.atdsrvano,
                   ws.sqlcode,
                   ws.msg

    if  ws.sqlcode = 0  then
        commit work
    else
        let ws.msg = "CTS36M00 - ",ws.msg
        call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
        rollback work
        let ws.retorno = false
        exit while
    end if

    # Grava ligacao
    begin work
    call cts10g00_ligacao ( d_cts36m00.lignum       ,
                            d_cts36m00.ligdat       ,
                            d_cts36m00.lighorinc    ,
                            d_cts36m00.c24soltipcod ,
                            d_cts36m00.solnom       ,
                            d_cts36m00.c24astcod    ,
                            d_cts36m00.c24funmat    ,
                            d_cts36m00.ligcvntip    ,
                            d_cts36m00.c24paxnum    ,
                            d_cts36m00.atdsrvnum    ,
                            d_cts36m00.atdsrvano    ,
                            ""                      ,     #sinvstnum
                            ""                      ,     #sinvstano
                            ""                      ,     #sinavsnum
                            ""                      ,     #sinavsano
                            d_cts36m00.succod       ,
                            d_cts36m00.ramcod       ,
                            d_cts36m00.aplnumdig    ,
                            d_cts36m00.itmnumdig    ,
                            d_cts36m00.edsnumref    ,
                            d_cts36m00.prporg       ,
                            d_cts36m00.prpnumdig    ,
                            d_cts36m00.fcapacorg    ,
                            d_cts36m00.fcapacnum    ,
                            ""                      ,    #sinramcod
                            ""                      ,    #sinano
                            ""                      ,    #sinnum
                            ""                      ,    #sinitmseq
                            d_cts36m00.caddat       ,    #data cadastro formulario
                            d_cts36m00.cadhor       ,    #hora cadastro formulario
                            d_cts36m00.cademp       ,    #empresa cadastro formulario
                            d_cts36m00.cadmat       )    #matricula cadastro formulario
         returning ws.tabname,
                   ws.sqlcode

    if  ws.sqlcode  <>  0  then
        error " Erro (", ws.sqlcode, ") na gravacao da",
              " tabela ", ws.tabname clipped, " para servico de apoio. AVISE A INFORMATICA!" sleep 2
        rollback work
        let ws.retorno = false
        exit while
    end if

    # Grava servico
    call cts10g02_grava_servico( d_cts36m00.atdsrvnum    ,
                                 d_cts36m00.atdsrvano    ,
                                 d_cts36m00.atdsoltip    ,
                                 d_cts36m00.solnom       , #c24solnom(o mesmo da datmligacao)
                                 d_cts36m00.vclcorcod    ,
                                 d_cts36m00.c24funmat    , #funmat(o mesmo da datmligacao)
                                 d_cts36m00.atdlibflg    ,
                                 d_cts36m00.atdlibhor    ,
                                 d_cts36m00.atdlibdat    ,
                                 d_cts36m00.ligdat       , # atddat(o mesmo da datmligacao)
                                 d_cts36m00.lighorinc    , # atdhor(o mesmo da datmligacao)
                                 ""                      , # atdlclflg
                                 d_cts36m00.atdhorpvt    ,
                                 d_cts36m00.atddatprg    ,
                                 d_cts36m00.atdhorprg    ,
                                 d_cts36m00.atdtip       , # ATDTIP
                                 ""                      , # atdmotnom
                                 ""                      , # atdvclsgl
                                 d_cts36m00.atdprscod    ,
                                 ""                      , # atdcstvlr
                                 "N"                     , #atdfnlflg
                                 d_cts36m00.atdfnlhor    ,
                                 d_cts36m00.atdrsdflg    , # atdrsdflg
                                 d_cts36m00.atddfttxt    , # atddfttxt
                                 ""                      , # atddoctxt
                                 d_cts36m00.c24opemat    , #c24opemat
                                 d_cts36m00.nom          ,
                                 d_cts36m00.vcldes       ,
                                 d_cts36m00.vclanomdl    ,
                                 d_cts36m00.vcllicnum    ,
                                 d_cts36m00.corsus       ,
                                 d_cts36m00.cornom       ,
                                 d_cts36m00.cnldat       ,
                                 ""                      , # pgtdat
                                 d_cts36m00.c24nomctt    , # c24nomctt
                                 d_cts36m00.atdpvtretflg ,
                                 d_cts36m00.atdvcltip    ,
                                 d_cts36m00.asitipcod    ,
                                 ""                      , # socvclcod
                                 d_cts36m00.vclcoddig    ,
                                 "N"                     , # srvprlflg
                                 ""                      , # srrcoddig
                                 d_cts36m00.atdprinvlcod ,
                                 d_cts36m00.atdsrvorg   )
         returning ws.tabname,
                   ws.sqlcode


    if  ws.sqlcode  <>  0  then
        error " Erro (", ws.sqlcode, ") na gravacao da",
              " tabela ", ws.tabname clipped, " para servico de apoio. AVISE A INFORMATICA!" sleep 2
        rollback work
        let ws.retorno = false
        exit while
    end if

    # Grava complemento do servico - datmservicocmp
    whenever error continue
    execute pcts36m00009 using d_cts36m00.atdsrvnum,
                               d_cts36m00.sgdirbcod,
                               d_cts36m00.atdsrvano,
                               d_cts36m00.roddantxt,
                               d_cts36m00.vclcamtip,
                               d_cts36m00.vclcrcdsc,
                               d_cts36m00.vclcrgflg,
                               d_cts36m00.vclcrgpso,
                               d_cts36m00.sinvitflg,
                               d_cts36m00.bocflg,
                               d_cts36m00.bocnum,
                               d_cts36m00.bocemi,
                               d_cts36m00.vcllibflg,
                               d_cts36m00.rmcacpflg,
                               d_cts36m00.sindat,
                               d_cts36m00.c24sintip,
                               d_cts36m00.c24sinhor,
                               d_cts36m00.vicsnh,
                               d_cts36m00.sinhor

    whenever error stop
    if  sqlca.sqlcode  <>  0  then
        error " Erro (", sqlca.sqlcode, ") na gravacao do",
              " complemento do servico de apoio. AVISE A INFORMATICA!" sleep 2
        rollback work
        let ws.retorno = false
        exit while
    end if


    #---------------------------------------------------------------------------
    # Grava locais de (1) ocorrencia  / (2) destino
    #---------------------------------------------------------------------------
    #como foi somado 1 em arr_aux para então ler o proximo - subtrair para ter a qtde extata
    let l_aux = arr_aux - 1
    for arr_aux = 1 to l_aux
        let a_cts36m00[arr_aux].operacao = "I"

        let ws.sqlcode = cts06g07_local( a_cts36m00[arr_aux].operacao    ,
                                         d_cts36m00.atdsrvnum            ,
                                         d_cts36m00.atdsrvano            ,
                                         arr_aux                         ,
                                         a_cts36m00[arr_aux].lclidttxt   ,
                                         a_cts36m00[arr_aux].lgdtip      ,
                                         a_cts36m00[arr_aux].lgdnom      ,
                                         a_cts36m00[arr_aux].lgdnum      ,
                                         a_cts36m00[arr_aux].lclbrrnom   ,
                                         a_cts36m00[arr_aux].brrnom      ,
                                         a_cts36m00[arr_aux].cidnom      ,
                                         a_cts36m00[arr_aux].ufdcod      ,
                                         a_cts36m00[arr_aux].lclrefptotxt,
                                         a_cts36m00[arr_aux].endzon      ,
                                         a_cts36m00[arr_aux].lgdcep      ,
                                         a_cts36m00[arr_aux].lgdcepcmp   ,
                                         a_cts36m00[arr_aux].lclltt      ,
                                         a_cts36m00[arr_aux].lcllgt      ,
                                         a_cts36m00[arr_aux].dddcod      ,
                                         a_cts36m00[arr_aux].lcltelnum   ,
                                         a_cts36m00[arr_aux].lclcttnom   ,
                                         a_cts36m00[arr_aux].c24lclpdrcod,
                                         a_cts36m00[arr_aux].ofnnumdig   ,
                                         a_cts36m00[arr_aux].emeviacod   ,
                                         a_cts36m00[arr_aux].celteldddcod,
                                         a_cts36m00[arr_aux].celtelnum   ,
                                         a_cts36m00[arr_aux].endcmp)
        if  ws.sqlcode is null  or
            ws.sqlcode <> 0     then
            if  arr_aux = 1  then
                error " Erro (", ws.sqlcode, ") na gravacao do",
                      " local de ocorrencia. AVISE A INFORMATICA!" sleep 2
            else
                error " Erro (", ws.sqlcode, ") na gravacao do",
                      " local de destino. AVISE A INFORMATICA!" sleep 2
            end if
            rollback work
            let ws.retorno = false
            exit while
        end if
    end for

    # Grava etapas do acompanhamento do servico
    #se servico nao foi liberado etapa deve ser 2
    if d_cts36m00.atdlibflg = "S" then
       let ws.atdetpcod = 1   #LIBERADO
    else
       let ws.atdetpcod = 2   #"NAO LIBERADO"
    end if
    call cts10g04_insere_etapa(d_cts36m00.atdsrvnum,
                               d_cts36m00.atdsrvano,
                               ws.atdetpcod,
                               d_cts36m00.atdprscod,        #(mesmo da datmservico)
                               " ",
                               " ",
                               " ")
                               returning ws.sqlcode


    if  ws.sqlcode <>  0  then
        error " Erro (", sqlca.sqlcode, ") na gravacao da",
              " etapa de acompanhamento do serico de apoio. AVISE A INFORMATICA!" sleep 2
        rollback work
        let ws.retorno = false
        exit while
    end if

    # Grava relacionamento servico / apolice - datrservapol
    if d_cts36m00.aplnumdig is not null  and
       d_cts36m00.aplnumdig <> 0         then
       whenever error continue
       execute pcts36m00010 using d_cts36m00.atdsrvnum ,
                                  d_cts36m00.atdsrvano ,
                                  d_cts36m00.succod    ,
                                  d_cts36m00.ramcod    ,
                                  d_cts36m00.aplnumdig ,
                                  d_cts36m00.itmnumdig ,
                                  d_cts36m00.edsnumref

       whenever error stop
       if  sqlca.sqlcode  <>  0  then
               error " Erro (", sqlca.sqlcode, ") na gravacao do",
                     " relacionamento servico apoio x apolice. AVISE A INFORMATICA!" sleep 2
               rollback work
               let ws.retorno = false
               exit while
       end if
    end if

    #----------------------------------------------------------
    #grava relacionamento servico X local condicao veiculo
    #----------------------------------------------------------
    #insere local condicao veiculo para servico de apoio
    whenever error continue
    execute pcts36m00016 using d_cts36m00.atdsrvnum,
                               d_cts36m00.atdsrvano,
                               param.vclcndlclcod1
    whenever error stop
    if  sqlca.sqlcode  <>  0  then
            error " Erro (", sqlca.sqlcode, ") na gravacao do",
                  " relacionamento servico apoio x local veiculo. AVISE A INFORMATICA!" sleep 2
            rollback work
            let ws.retorno = false
            exit while
    end if

    #insere outro local condicao veiculo para servico de apoio
    if param.vclcndlclcod2 is not null then
       whenever error continue
       execute pcts36m00016 using d_cts36m00.atdsrvnum,
                                  d_cts36m00.atdsrvano,
                                  param.vclcndlclcod2
       whenever error stop
       if  sqlca.sqlcode  <>  0  then
               error " Erro (", sqlca.sqlcode, ") na gravacao do",
                     " relacionamento servico apoio x local veiculo. AVISE A INFORMATICA!" sleep 2
               rollback work
               let ws.retorno = false
               exit while
       end if
    end if

    #insere um terceiro local condicao veiculo para servico de apoio
    if param.vclcndlclcod3 is not null then
       whenever error continue
       execute pcts36m00016 using d_cts36m00.atdsrvnum,
                                  d_cts36m00.atdsrvano,
                                  param.vclcndlclcod3
       whenever error stop
       if  sqlca.sqlcode  <>  0  then
               error " Erro (", sqlca.sqlcode, ") na gravacao do",
                     " relacionamento servico apoio x local veiculo. AVISE A INFORMATICA!" sleep 2
               rollback work
               let ws.retorno = false
               exit while
       end if
    end if

    #grava relacionamento entre o servico original e o servico de apoio
    whenever error continue
    execute pcts36m00017 using param.atdsrvnum,
                               param.atdsrvano,
                               d_cts36m00.atdsrvnum,
                               d_cts36m00.atdsrvano
     whenever error stop
    if  sqlca.sqlcode  <>  0  then
            error " Erro (", sqlca.sqlcode, ") na gravacao do",
                  " relacionamento servico apoio x servico original. AVISE A INFORMATICA!" sleep 2
            rollback work
            let ws.retorno = false
            exit while
    end if

    #Grava relacionamento servico X condutor - datrsrvcnd
    if ws.cdtseq is not null and
       (d_cts36m00.c24astcod = "G10" or
       d_cts36m00.c24astcod = "G11" or
       d_cts36m00.c24astcod = "S10") then
       whenever error continue
       execute pcts36m00014 using d_cts36m00.atdsrvnum ,
                                  d_cts36m00.atdsrvano ,
                                  d_cts36m00.succod    ,
                                  d_cts36m00.aplnumdig ,
                                  d_cts36m00.itmnumdig ,
                                  ws.cdtseq
       whenever error stop
       if  sqlca.sqlcode  <>  0  then
                error " Erro (", sqlca.sqlcode, ") na gravacao da",
                      " situacao do veiculo - servico apoio. AVISE A INFORMATICA!" sleep 2
                rollback work
                let ws.retorno = false
                exit while
       end if
    end if

    #Grava problemas do servico (datrsrvpbm)
    if d_cts36m00.c24astcod = "S10" then
       call ctx09g02_inclui(d_cts36m00.atdsrvnum,
                            d_cts36m00.atdsrvano,
                            1                   , # Org. informacao 1-Segurado 2-Pst
                            d_cts36m00.c24pbmcod,
                            d_cts36m00.atddfttxt, #descricao do problema
                            ""                  ) # Codigo prestador
       returning ws.sqlcode,
                 ws.tabname
       if  ws.sqlcode  <>  0  then
           error "ctx09g02_inclui do servico de apoio", ws.sqlcode, ws.tabname
           sleep 2
           rollback work
           let ws.retorno = false
           exit while
       end if
    end if

    #Grava informacoes do veiculo perda total- datmrpt
    if d_cts36m00.c24astcod = "RPT" then
       whenever error continue
       execute pcts36m00011 using d_cts36m00.atdsrvnum,
                                  d_cts36m00.atdsrvano,
                                  rpt_cts36m00.rptvclsitdsmflg,
                                  rpt_cts36m00.rptvclsitestflg,
                                  rpt_cts36m00.dddcod         ,
                                  rpt_cts36m00.telnum

       whenever error stop
       if  sqlca.sqlcode  <>  0  then
                error " Erro (", sqlca.sqlcode, ") na gravacao da",
                      " situacao do veiculo - servico apoio. AVISE A INFORMATICA!" sleep 2
                rollback work
                let ws.retorno = false
                exit while
       end if
    end if

    commit work
    # Ponto de acesso apos a gravacao do laudo
    call cts00g07_apos_grvlaudo(d_cts36m00.atdsrvnum,
                                d_cts36m00.atdsrvano)

    exit while
  end while

  if ws.retorno = false then
     return
  end if

  # Grava HISTORICO do servico ---- 43 + 10 + 2 +1 = 56
  let hist_cts36m00.hist1 = "Servico de apoio gerado atraves do servico ",param.atdsrvnum, "/",
                            param.atdsrvano

  call cts10g02_historico( d_cts36m00.atdsrvnum ,
                           d_cts36m00.atdsrvano ,
                           d_cts36m00.ligdat   , # atddat(o mesmo da datmligacao)
                           d_cts36m00.lighorinc, # atddat(o mesmo da datmligacao)
                           d_cts36m00.c24funmat, #funmat(o mesmo da datmligacao)
                           hist_cts36m00.* )
       returning ws.retorno

  #Busca
  call cts02m01_caminhao(d_cts36m00.succod   ,
                         d_cts36m00.aplnumdig,
                         d_cts36m00.itmnumdig,
                         g_funapol.autsitatu)
                    returning l_camflg,
                              l_ctgtrfcod


  #-----------------------------------------------
  # Aciona Servico automaticamente
  #-----------------------------------------------
  #PSI198714 - Acionar servico automaticamente
  #chamar funcao que verifica se acionamento pode ser feito
  # verifica se servico para cidade e internet ou GPS e se esta ativo
  #retorna true para acionamento e false para nao acionamento
  if cts34g00_acion_auto (d_cts36m00.atdsrvorg,
                          a_cts36m00[1].cidnom,
                          a_cts36m00[1].ufdcod) then
       #funcao cts34g00_acion_auto verificou que parametrizacao para origem
       # do servico esta OK
       #chamar funcao para validar regras gerais se um servico sera acionado
       # automaticamente ou nao e atualizar datmservico
       if not cts40g12_regras_aciona_auto (
                            d_cts36m00.atdsrvorg,
                            d_cts36m00.c24astcod,
                            d_cts36m00.asitipcod,
                            a_cts36m00[1].lclltt,
                            a_cts36m00[1].lcllgt,
                            "",  #datmservico.prslocflg
                            ws.frmflg,
                            d_cts36m00.atdsrvnum,
                            d_cts36m00.atdsrvano,
                            "",
                            d_cts36m00.vclcoddig,
                            l_camflg ) then
          #servico nao pode ser acionado automaticamente
          #display "Servico acionado manual"
       else
          #display "Servico foi para acionamento automatico!!"
       end if
  end if

end function

