#---------------------------------------------------------------------------#
# Nome do Modulo: cts26m07                                           Raji   #
#                                                                           #
# Consulta conclusao do Servico original                           Jul/2001 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 21/10/2003  OSF25143     Teresinha S.   Padronizar a entrada do tipo de   #
#             PSI 170585                  veiculo para os servicos de taxi  #
# 13/08/2009  PSI 244236   Sergio Burini  Inclusão do Sub-Dairro            #
#---------------------------------------------------------------------------#
# 21/10/2010 Alberto Rodrigues            Correcao de ^M                    #
#---------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function cts26m07(param)
#--------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_cts26m07   record
    cnldat           like datmservico.cnldat,
    atdfnlhor        char (05),
    operador         like isskfunc.funnom,
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetpdes        like datketapa.atdetpdes,
    retorno          char (20),
    envio            char (05),
    atdprscod        like dpaksocor.pstcoddig,
    nomgrr           like dpaksocor.nomgrr,
    cidufdprs        char (48),
    dddcod           like dpaksocor.dddcod,
    teltxt           like dpaksocor.teltxt,
    c24nomctt        like datmservico.c24nomctt,
    atdvclsgl        like datmservico.atdvclsgl,
    socvclcod        like datmservico.socvclcod,
    socvcldes        char (50),
    srrcoddig        like datmservico.srrcoddig,
    srrabvnom        like datksrr.srrabvnom,
    atdcstvlr        like datmservico.atdcstvlr,
    pasasivcldes     like datmtrptaxi.pasasivcldes,
    celdddcod        like datksrr.celdddcod,
    celtelnum        like datksrr.celtelnum,
    atdprvdat        like datmservico.atdprvdat,
    dstqtd           dec (8,4),
    envtipcod        dec  (1,0),
    atdimpcod        like datktrximp.atdimpcod,
    atdimpsit        like datktrximp.atdimpsit,
    impsitdes        char (13),
    mdtcod           like datkveiculo.mdtcod,
    srrltt           like datmservico.srrltt,
    srrlgt           like datmservico.srrlgt
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
    erroflg          char (01),
    hst              char (01),
    flag_cts00m20    char (01),
    flagf7           char (01),
    flagf8           char (01),
    flagf9           char (01),
    ofnnumdig        like datmlcl.ofnnumdig,
    ofncrdflg        like sgokofi.ofncrdflg,
    mpacidcod        like dpaksocor.mpacidcod,
    result           integer
 end record

 define a_cts26m07   array[3] of record
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
    ofnnumdig        like sgokofi.ofnnumdig
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
 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define arr_aux      smallint
 define prompt_key   char (01)
 define ins_etapa    integer
 define l_descveiculo char(07)

	define	w_pf1	integer
        let     l_descveiculo  =  null
	let	arr_aux  =  null
	let	prompt_key  =  null
	let	ins_etapa  =  null

	for	w_pf1  =  1  to  3
		initialize  a_cts26m07[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  3
		initialize  a_voo[w_pf1].*  to  null
	end	for

	initialize  d_cts26m07.*  to  null

	initialize  ws.*  to  null
 initialize m_subbairro to null

 open window cts26m07 at 09,06 with form "cts26m07"
                         attribute (form line 1, border, comment line last - 1)

 message " (F6)Etapas"

 initialize d_cts26m07.*  to null
 initialize ws.*          to null
 initialize a_voo         to null

 let int_flag        = false
 let ws.dataatu      = today
 let ws.horaatu      = current hour to minute
 let ws.vclctrposqtd = 0

 if param.atdsrvnum  is null   or
    param.atdsrvano  is null   then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    close window cts26m07
    return
 end if

 #--------------------------------------------------------------------
 # Verifica se servico ja' foi concluido
 #--------------------------------------------------------------------
 select atdprscod   , atdmotnom   , atdvclsgl, atdfnlflg   ,
        c24opemat   , cnldat   , atdfnlhor   ,
        c24nomctt   , atdpvtretflg, atdsrvorg   , asitipcod   ,
        atdcstvlr   , atddat      , atddatprg, sindat      ,
        sinhor      , socvclcod, srrcoddig,   atdprvdat,
        srrltt      , srrlgt
   into d_cts26m07.atdprscod   , d_cts26m07.srrabvnom   ,
        d_cts26m07.atdvclsgl   , ws.atdfnlflg           ,
        ws.c24opemat           ,
        d_cts26m07.cnldat      , d_cts26m07.atdfnlhor   ,
        d_cts26m07.c24nomctt   , ws.atdpvtretflg        ,
        ws.atdsrvorg           , ws.asitipcod           ,
        ws.atdcstvlr           , ws.atddat              ,
        ws.atddatprg           , ws.sindat              ,
        ws.sinhor              , d_cts26m07.socvclcod   ,
        d_cts26m07.srrcoddig   , d_cts26m07.atdprvdat   ,
        d_cts26m07.srrltt      , d_cts26m07.srrlgt
   from datmservico, outer datmservicocmp, outer datmassistpassag
  where datmservico.atdsrvnum       =  param.atdsrvnum
    and datmservico.atdsrvano       =  param.atdsrvano

    and datmservicocmp.atdsrvnum    =  datmservico.atdsrvnum
    and datmservicocmp.atdsrvano    =  datmservico.atdsrvano

    and datmassistpassag.atdsrvnum  =  datmservico.atdsrvnum
    and datmassistpassag.atdsrvano  =  datmservico.atdsrvano

 if sqlca.sqlcode  =  notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    close window cts26m07
    return
 end if

 if ws.atdsrvorg =  2   and
    ws.asitipcod =  5   then
    select pasasivcldes
      into d_cts26m07.pasasivcldes
      from datmtrptaxi
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano
     if d_cts26m07.pasasivcldes  = 'P' then
         let l_descveiculo       = 'Passeio'
     end if
     if d_cts26m07.pasasivcldes = 'V' then
        let l_descveiculo       = 'Van'
     end if
 end if

 #--------------------------------------------------------------------
 # Informacoes especificas de assistencia a passageiros - pass.aerea
 #--------------------------------------------------------------------
 if ws.atdsrvorg =  2   and
    ws.asitipcod = 10   then
    declare c_datmtrppsgaer cursor for
       select voocnxseq,
              trpaerempnom,
              trpaervoonum,
              trpaerptanum,
              trpaerlzdnum,
              arpembcod,
              trpaersaidat,
              trpaersaihor,
              arpchecod,
              trpaerchedat,
              trpaerchehor
         from datmtrppsgaer
        where atdsrvnum = param.atdsrvnum  and
              atdsrvano = param.atdsrvano
        order by voocnxseq

    let arr_aux = 1

    foreach c_datmtrppsgaer into ws.voocnxseq,
                                 a_voo[arr_aux].trpaerempnom,
                                 a_voo[arr_aux].trpaervoonum,
                                 a_voo[arr_aux].trpaerptanum,
                                 a_voo[arr_aux].trpaerlzdnum,
                                 a_voo[arr_aux].arpembcod,
                                 a_voo[arr_aux].trpaersaidat,
                                 a_voo[arr_aux].trpaersaihor,
                                 a_voo[arr_aux].arpchecod,
                                 a_voo[arr_aux].trpaerchedat,
                                 a_voo[arr_aux].trpaerchehor

       let arr_aux = arr_aux + 1

       if arr_aux > 3  then
          exit foreach
       end if
    end foreach

    if arr_aux > 1  then
       let ws.operacao = "A"
    else
       let ws.operacao = "I"
    end if

    message " (F5)Voo, (F6)Etapas, (F7)Psq.Prest, (F8)Pos.Frota, (F9)Pos.GPS"
 end if

 #--------------------------------------------------------------------
 # Informacoes especificas de assistencia a passageiros - hospedagem
 #--------------------------------------------------------------------
 if ws.atdsrvorg =  3   then
    call ctx04g00_local_gps(param.atdsrvnum,
                            param.atdsrvano,
                            3)
                  returning a_cts26m07[3].lclidttxt   ,
                            a_cts26m07[3].lgdtip      ,
                            a_cts26m07[3].lgdnom      ,
                            a_cts26m07[3].lgdnum      ,
                            a_cts26m07[3].lclbrrnom   ,
                            a_cts26m07[3].brrnom      ,
                            a_cts26m07[3].cidnom      ,
                            a_cts26m07[3].ufdcod      ,
                            a_cts26m07[3].lclrefptotxt,
                            a_cts26m07[3].endzon      ,
                            a_cts26m07[3].lgdcep      ,
                            a_cts26m07[3].lgdcepcmp   ,
                            a_cts26m07[3].lclltt      ,
                            a_cts26m07[3].lcllgt      ,
                            a_cts26m07[3].dddcod      ,
                            a_cts26m07[3].lcltelnum   ,
                            a_cts26m07[3].lclcttnom   ,
                            a_cts26m07[3].c24lclpdrcod,
                            ws.sqlcode
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[3].lclbrrnom = a_cts26m07[3].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts26m07[3].brrnom,
                                a_cts26m07[3].lclbrrnom)
      returning a_cts26m07[3].lclbrrnom

 select ofnnumdig into a_cts26m07[3].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 3

    if ws.sqlcode < 0  then
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
       close window cts26m07
       return
    end if

    if ws.sqlcode = 100  then
       let ws.operacao = "I"
    else
       let ws.operacao = "M"
    end if

 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         1)
               returning a_cts26m07[1].lclidttxt   ,
                         a_cts26m07[1].lgdtip      ,
                         a_cts26m07[1].lgdnom      ,
                         a_cts26m07[1].lgdnum      ,
                         a_cts26m07[1].lclbrrnom   ,
                         a_cts26m07[1].brrnom      ,
                         a_cts26m07[1].cidnom      ,
                         a_cts26m07[1].ufdcod      ,
                         a_cts26m07[1].lclrefptotxt,
                         a_cts26m07[1].endzon      ,
                         a_cts26m07[1].lgdcep      ,
                         a_cts26m07[1].lgdcepcmp   ,
                         a_cts26m07[1].lclltt      ,
                         a_cts26m07[1].lcllgt      ,
                         a_cts26m07[1].dddcod      ,
                         a_cts26m07[1].lcltelnum   ,
                         a_cts26m07[1].lclcttnom   ,
                         a_cts26m07[1].c24lclpdrcod,
                         ws.sqlcode
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts26m07[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts26m07[1].brrnom,
                                a_cts26m07[1].lclbrrnom)
      returning a_cts26m07[1].lclbrrnom

 select ofnnumdig into a_cts26m07[1].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    close window cts26m07
    return
 end if

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         2)
               returning a_cts26m07[2].lclidttxt   ,
                         a_cts26m07[2].lgdtip      ,
                         a_cts26m07[2].lgdnom      ,
                         a_cts26m07[2].lgdnum      ,
                         a_cts26m07[2].lclbrrnom   ,
                         a_cts26m07[2].brrnom      ,
                         a_cts26m07[2].cidnom      ,
                         a_cts26m07[2].ufdcod      ,
                         a_cts26m07[2].lclrefptotxt,
                         a_cts26m07[2].endzon      ,
                         a_cts26m07[2].lgdcep      ,
                         a_cts26m07[2].lgdcepcmp   ,
                         a_cts26m07[2].lclltt      ,
                         a_cts26m07[2].lcllgt      ,
                         a_cts26m07[2].dddcod      ,
                         a_cts26m07[2].lcltelnum   ,
                         a_cts26m07[2].lclcttnom   ,
                         a_cts26m07[2].c24lclpdrcod,
                         ws.sqlcode
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[2].lclbrrnom = a_cts26m07[2].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts26m07[2].brrnom,
                                a_cts26m07[2].lclbrrnom)
      returning a_cts26m07[2].lclbrrnom

 select ofnnumdig into a_cts26m07[2].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 2

 if ws.sqlcode < 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
    close window cts26m07
    return
 end if

 #--------------------------------------------------------------------
 # Informacoes sobre veiculo/operador de radio
 #--------------------------------------------------------------------
 if d_cts26m07.socvclcod  is not null   then
    select atdvclsgl,
           vclcoddig
      into d_cts26m07.atdvclsgl,
           ws.vclcoddig
      from datkveiculo
     where socvclcod  =  d_cts26m07.socvclcod

    if sqlca.sqlcode  =  notfound  then
       error " Veiculo nao encontrado. AVISE A INFORMATICA!"
       close window cts26m07
       return
    end if

    call cts15g00 (ws.vclcoddig)  returning d_cts26m07.socvcldes
 end if

 if ws.c24opemat is not null  then
    let d_cts26m07.operador = "**NAO CADASTRADO**"

    select funnom
      into d_cts26m07.operador
      from isskfunc
     where empcod = 01
       and funmat = ws.c24opemat

    let d_cts26m07.operador = upshift(d_cts26m07.operador)
 end if

 #--------------------------------------------------------------------
 # Informacoes do socorrista
 #--------------------------------------------------------------------
 if d_cts26m07.srrcoddig  is not null   then
    select srrabvnom,
           celdddcod,
           celtelnum
      into d_cts26m07.srrabvnom,
           d_cts26m07.celdddcod,
           d_cts26m07.celtelnum
      from datksrr
     where srrcoddig  =  d_cts26m07.srrcoddig
 end if

 #--------------------------------------------------------------------
 # Informacoes etapa
 #--------------------------------------------------------------------
 initialize ws.atdsrvseq to null

  call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
                   returning d_cts26m07.atdetpcod

 if sqlca.sqlcode = 0 then
    let d_cts26m07.atdetpdes = "NAO CADASTRADA"

    call cts10g05_desc_etapa(2,d_cts26m07.atdetpcod)
                   returning ws.result,
                             d_cts26m07.atdetpdes,
                             ws.atdetptipcod,
                             ws.atdetppndflg

    if ws.atdetppndflg = "S"  then
       let ws.atdfnlflg = "N"
    else
       let ws.atdfnlflg = "S"
    end if
 end if

 #--------------------------------------------------------------------
 # Informacoes do prestador
 #--------------------------------------------------------------------
 if d_cts26m07.atdprscod  is not null   then
    select nomgrr,
           dddcod,
           teltxt,
           endcid,
           endufd,
           faxnum
      into d_cts26m07.nomgrr,
           d_cts26m07.dddcod,
           d_cts26m07.teltxt,
           ws.endcidprs,
           ws.endufdprs,
           ws.faxnum
      from dpaksocor
     where pstcoddig = d_cts26m07.atdprscod

    let d_cts26m07.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs
 end if

 #--------------------------------------------------------------------
 # Calcula distancia no acionamento
 #--------------------------------------------------------------------
 if d_cts26m07.atdetpcod = 4 or
    d_cts26m07.atdetpcod = 5 or
    d_cts26m07.atdetpcod = 11 then
    if d_cts26m07.srrltt is not null and d_cts26m07.srrlgt is not null then
       call cts18g00(d_cts26m07.srrltt,d_cts26m07.srrlgt,
                     a_cts26m07[1].lclltt,a_cts26m07[1].lcllgt)
            returning d_cts26m07.dstqtd
    else
       if d_cts26m07.srrcoddig is null then
          select mpacidcod into ws.mpacidcod
            from dpaksocor
            where pstcoddig = d_cts26m07.atdprscod
          call cts23g00_inf_cidade(3,ws.mpacidcod,"","")
               returning ws.result,
                         d_cts26m07.srrltt,
                         d_cts26m07.srrlgt
          call cts18g00(d_cts26m07.srrltt,d_cts26m07.srrlgt,
                        a_cts26m07[1].lclltt,a_cts26m07[1].lcllgt)
               returning d_cts26m07.dstqtd
       end if
    end if
 end if

 display by name d_cts26m07.cnldat thru d_cts26m07.envtipcod
 display by name l_descveiculo --> OSF 275143

 if ws.atdpvtretflg = "S"  then
    display "RETORNAR AO SEGURADO" to retorno attribute(reverse)
 end if

 #--------------------------------------------------------------------
 # Verifica se ja' houve algum  tipo de envio para o servico
 #--------------------------------------------------------------------
 initialize d_cts26m07.envio  to null
 call cts00m02_envio(param.atdsrvnum,
                     param.atdsrvano)
      returning d_cts26m07.envio

 if d_cts26m07.envio  is not null   then
    display by name d_cts26m07.envio  attribute(reverse)
 end if

 display by name l_descveiculo  --> Teresinha OSF 25143

 if ws.atdsrvorg =  2   or
    ws.atdsrvorg =  3   then
    display "Valor....:"  to valor
    let d_cts26m07.atdcstvlr = ws.atdcstvlr
    if ws.asitipcod =  5   then
       display "Veiculo..:"  to veiculo
    end if
 else
    initialize d_cts26m07.atdcstvlr     to null
    initialize d_cts26m07.pasasivcldes  to null
    display by name d_cts26m07.atdcstvlr
    display by name d_cts26m07.pasasivcldes
 end if

   #--------------------------------------------------------------------
   # Exibe Etapas
   #--------------------------------------------------------------------
#   on key (F6)
#      if ws.atdsrvorg =  10  then
#         error " Funcao nao disponivel!"
#      else
#         open window w_branco at 04,02 with 04 rows,78 columns
#
#         call cts00m11(param.atdsrvnum, param.atdsrvano)
#
#         close window w_branco
#      end if

 prompt "" for char prompt_key

 close window cts26m07

end function  ###--  cts26m07

