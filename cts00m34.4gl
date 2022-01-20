#---------------------------------------------------------------------------#
# Nome do Modulo: CTS00M34                                         Wagner   #
#                                                                           #
# Espelho da conclusao do Servico                                  Set/2002 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 21/10/2003  OSF25143     Teresinha S.   Padronizar a entrada do tipo de   #
#             PSI 170585                  veiculo para os servicos de taxi  #
#---------------------------------------------------------------------------#
# 17/05/2005 Julianna,Meta    PSI191108   Implementar o codigo da via       #
# 13/08/2009 Sergio Burini    PSI 244236  Inclusão do Sub-Dairro            #
#---------------------------------------------------------------------------#

globals  '/homedsa/projetos/geral/globals/glct.4gl'

  define m_tipo_rota char(07)

#--------------------------------------------------------------------
 function cts00m34(param)
#--------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_cts00m34   record
    cnldat           like datmservico.cnldat,
    atdfnlhor        char (05),
    operador         like isskfunc.funnom,
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetpdes        like datketapa.atdetpdes,
    retorno          char (20),
    envio            char (08),
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
    atddat           like datmservico.atddat,
    atddatprg        like datmservico.atddatprg,
    sindat           like datmservicocmp.sindat,
    sinhor           like datmservicocmp.sinhor,
    ufdcod           like datmfrtpos.ufdcod,
    cidnom           like datmfrtpos.cidnom,
    brrnom           like datmfrtpos.brrnom,
    endzon           like datmfrtpos.endzon,
    socoprsitcod     like datkveiculo.socoprsitcod,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetptipcod     like datketapa.atdetptipcod,
    atdetppndflg     like datketapa.atdetppndflg,
    vclcoddig        like datkveiculo.vclcoddig,
    srrcoddig        like datksrr.srrcoddig,
    mpacrglgdflg     like datkmpacid.mpacrglgdflg,
    gpsacngrpcod     like datkmpacid.gpsacngrpcod,
    fax              smallint,
    grvetpflg        smallint,
    sqlcode          integer,
    dataatu          date,
    confirma         char (01),
    vclctrposqtd     dec  (4,0),
    horaatu          char (05),
    ofnnumdig        like datmlcl.ofnnumdig,
    ofncrdflg        like sgokofi.ofncrdflg,
    mpacidcod        like dpaksocor.mpacidcod,
    atdetpseq        like datmsrvint.atdetpseq,
    intsrvrcbflg     like dpaksocor.intsrvrcbflg,
    atdetpcod        like datmsrvint.atdetpcod,
    etpmtvcod        like datksrvintmtv.etpmtvcod,
    etpmtvdes        like datksrvintmtv.etpmtvdes,
    result           integer
 end record

 define l_tempo      decimal(6,1),
        l_rota_final char(01)

 define a_cts00m34   array[1] of record
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
    ofnnumdig        like sgokofi.ofnnumdig,
    emeviacod        like datkemevia.emeviacod,
    celteldddcod     like datmlcl.celteldddcod,
    celtelnum        like datmlcl.celtelnum,
    endcmp           like datmlcl.endcmp
 end record

 define arr_aux      smallint
 define prompt_key   char (01)
 define l_descveiculo char(07)

        let     l_descveiculo = null
        let     arr_aux       = null
        let     prompt_key    = null
        let     l_tempo       = null
        let     l_rota_final  = null

        initialize  a_cts00m34  to  null
        initialize  d_cts00m34.*  to  null

        initialize  ws.*  to  null

 open window cts00m34 at 09,06 with form "cts00m34"
      attribute (form line 1, border, comment line last - 1)

 message " (F6)Etapas, (F17)Abandona"

 initialize d_cts00m34.*  to null
 initialize ws.*          to null

 let int_flag        = false
 let ws.dataatu      = today
 let ws.horaatu      = current hour to minute
 let ws.vclctrposqtd = 0

 #--------------------------------------------------------------------
 # Verifica se servico ja' foi concluido
 #--------------------------------------------------------------------
 select atdprscod   , atdmotnom   , atdvclsgl, atdfnlflg   ,
        c24opemat   , cnldat   , atdfnlhor   ,
        c24nomctt   , atdpvtretflg, atdsrvorg   , asitipcod   ,
        atdcstvlr   , atddat      , atddatprg, sindat      ,
        sinhor      , socvclcod, srrcoddig,   atdprvdat,
        srrltt      , srrlgt
   into d_cts00m34.atdprscod   , d_cts00m34.srrabvnom   ,
        d_cts00m34.atdvclsgl   , ws.atdfnlflg           ,
        ws.c24opemat           ,
        d_cts00m34.cnldat      , d_cts00m34.atdfnlhor   ,
        d_cts00m34.c24nomctt   , ws.atdpvtretflg        ,
        ws.atdsrvorg           , ws.asitipcod           ,
        ws.atdcstvlr           , ws.atddat              ,
        ws.atddatprg           , ws.sindat              ,
        ws.sinhor              , d_cts00m34.socvclcod   ,
        d_cts00m34.srrcoddig   , d_cts00m34.atdprvdat   ,
        d_cts00m34.srrltt      , d_cts00m34.srrlgt
   from datmservico, outer datmservicocmp, outer datmassistpassag
  where datmservico.atdsrvnum       =  param.atdsrvnum
    and datmservico.atdsrvano       =  param.atdsrvano

    and datmservicocmp.atdsrvnum    =  datmservico.atdsrvnum
    and datmservicocmp.atdsrvano    =  datmservico.atdsrvano

    and datmassistpassag.atdsrvnum  =  datmservico.atdsrvnum
    and datmassistpassag.atdsrvano  =  datmservico.atdsrvano

 if sqlca.sqlcode  =  notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    close window cts00m34
    return
 end if

 if ws.atdsrvorg =  2   and
    ws.asitipcod =  5   then
    select pasasivcldes
      into d_cts00m34.pasasivcldes
      from datmtrptaxi
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano
     # Fabrica de software - Teresinha Silva - Verificar ??
     if d_cts00m34.pasasivcldes = 'P' then
        let l_descveiculo       = 'Passeio'
     end if
     if d_cts00m34.pasasivcldes = 'V' then
        let l_descveiculo       = 'Van'
     end if
 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(param.atdsrvnum,
                         param.atdsrvano,
                         1)
               returning a_cts00m34[1].lclidttxt   ,
                         a_cts00m34[1].lgdtip      ,
                         a_cts00m34[1].lgdnom      ,
                         a_cts00m34[1].lgdnum      ,
                         a_cts00m34[1].lclbrrnom   ,
                         a_cts00m34[1].brrnom      ,
                         a_cts00m34[1].cidnom      ,
                         a_cts00m34[1].ufdcod      ,
                         a_cts00m34[1].lclrefptotxt,
                         a_cts00m34[1].endzon      ,
                         a_cts00m34[1].lgdcep      ,
                         a_cts00m34[1].lgdcepcmp   ,
                         a_cts00m34[1].lclltt      ,
                         a_cts00m34[1].lcllgt      ,
                         a_cts00m34[1].dddcod      ,
                         a_cts00m34[1].lcltelnum   ,
                         a_cts00m34[1].lclcttnom   ,
                         a_cts00m34[1].c24lclpdrcod,
                         a_cts00m34[1].celteldddcod,
                         a_cts00m34[1].celtelnum,
                         a_cts00m34[1].endcmp,
                         ws.sqlcode,
                         a_cts00m34[1].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_cts00m34[1].brrnom,
                                a_cts00m34[1].lclbrrnom)
      returning a_cts00m34[1].lclbrrnom
 select ofnnumdig into a_cts00m34[1].ofnnumdig
   from datmlcl
  where atdsrvano = param.atdsrvano
    and atdsrvnum = param.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    close window cts00m34
    return
 end if

 #--------------------------------------------------------------------
 # Informacoes sobre veiculo/operador de radio
 #--------------------------------------------------------------------
 if d_cts00m34.socvclcod  is not null   then
    select atdvclsgl,
           vclcoddig
      into d_cts00m34.atdvclsgl,
           ws.vclcoddig
      from datkveiculo
     where socvclcod  =  d_cts00m34.socvclcod

    if sqlca.sqlcode  =  notfound  then
       error " Veiculo nao encontrado. AVISE A INFORMATICA!"
       close window cts00m34
       return
    end if

    call cts15g00 (ws.vclcoddig)  returning d_cts00m34.socvcldes
 end if

 if ws.c24opemat is not null  then
    let d_cts00m34.operador = "**NAO CADASTRADO**"

    select funnom
      into d_cts00m34.operador
      from isskfunc
     where empcod = 01
       and funmat = ws.c24opemat

    let d_cts00m34.operador = upshift(d_cts00m34.operador)
 end if

 #--------------------------------------------------------------------
 # Informacoes do socorrista
 #--------------------------------------------------------------------
 if d_cts00m34.srrcoddig  is not null   then
    select srrabvnom,
           celdddcod,
           celtelnum
      into d_cts00m34.srrabvnom,
           d_cts00m34.celdddcod,
           d_cts00m34.celtelnum
      from datksrr
     where srrcoddig  =  d_cts00m34.srrcoddig
 end if

 #--------------------------------------------------------------------
 # Informacoes etapa
 #--------------------------------------------------------------------
 initialize ws.atdsrvseq to null

  call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
                   returning d_cts00m34.atdetpcod

 if sqlca.sqlcode = 0 then
    let d_cts00m34.atdetpdes = "NAO CADASTRADA"

    call cts10g05_desc_etapa(2,d_cts00m34.atdetpcod)
                   returning ws.result,
                             d_cts00m34.atdetpdes,
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
 if d_cts00m34.atdprscod  is not null   then
    select nomgrr,
           dddcod,
           teltxt,
           endcid,
           endufd,
           faxnum,
           intsrvrcbflg
      into d_cts00m34.nomgrr,
           d_cts00m34.dddcod,
           d_cts00m34.teltxt,
           ws.endcidprs,
           ws.endufdprs,
           ws.faxnum,
           ws.intsrvrcbflg
      from dpaksocor
     where pstcoddig = d_cts00m34.atdprscod
    let d_cts00m34.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs
 end if

 #--------------------------------------------------------------------
 # Calcula distancia no acionamento
 #--------------------------------------------------------------------
 if d_cts00m34.atdetpcod = 4 or
    d_cts00m34.atdetpcod = 5 or
    d_cts00m34.atdetpcod = 11 then
    if d_cts00m34.srrltt is not null and d_cts00m34.srrlgt is not null then

       # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
       if ctx25g05_rota_ativa() then

          # -> BUSCA O TIPO DE ROTA
          let m_tipo_rota = null
          let m_tipo_rota = ctx25g05_tipo_rota()

          call ctx25g02(d_cts00m34.srrltt,
                        d_cts00m34.srrlgt,
                        a_cts00m34[1].lclltt,
                        a_cts00m34[1].lcllgt,
                        m_tipo_rota,
                        0)

               returning d_cts00m34.dstqtd,
                         l_tempo,
                         l_rota_final
       else
          call cts18g00(d_cts00m34.srrltt,
                        d_cts00m34.srrlgt,
                        a_cts00m34[1].lclltt,
                        a_cts00m34[1].lcllgt)

               returning d_cts00m34.dstqtd
       end if

    else
       if d_cts00m34.srrcoddig is null then
          select mpacidcod into ws.mpacidcod
            from dpaksocor
            where pstcoddig = d_cts00m34.atdprscod
          call cts23g00_inf_cidade(3,ws.mpacidcod,"","")
               returning ws.result,
                         d_cts00m34.srrltt,
                         d_cts00m34.srrlgt

          # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
          if ctx25g05_rota_ativa() then

             # -> BUSCA O TIPO DE ROTA
             let m_tipo_rota = null
             let m_tipo_rota = ctx25g05_tipo_rota()

             call ctx25g02(d_cts00m34.srrltt,
                           d_cts00m34.srrlgt,
                           a_cts00m34[1].lclltt,
                           a_cts00m34[1].lcllgt,
                           m_tipo_rota,
                           0)

                  returning d_cts00m34.dstqtd,
                            l_tempo,
                            l_rota_final
          else
             call cts18g00(d_cts00m34.srrltt,
                           d_cts00m34.srrlgt,
                           a_cts00m34[1].lclltt,
                           a_cts00m34[1].lcllgt)

                  returning d_cts00m34.dstqtd
          end if
       end if
    end if
 end if


 display by name d_cts00m34.cnldat thru d_cts00m34.envtipcod
 display by name l_descveiculo --> OSF 275143

 if ws.atdpvtretflg = "S"  then
    display "RETORNAR AO SEGURADO" to retorno attribute(reverse)
 end if

 #--------------------------------------------------------------------
 # Verifica se ja' houve algum  tipo de envio para o servico
 #--------------------------------------------------------------------
 initialize d_cts00m34.envio  to null
 call cts00m34_envio(param.atdsrvnum,
                     param.atdsrvano,
                     d_cts00m34.atdprscod)
      returning d_cts00m34.envio

 if d_cts00m34.envio  is not null   then
    display by name d_cts00m34.envio  attribute(reverse)
 end if

 display by name l_descveiculo  --> Teresinha OSF 25143

 if ws.atdsrvorg =  2   or
    ws.atdsrvorg =  3   then
    display "Valor....:"  to valor
    let d_cts00m34.atdcstvlr = ws.atdcstvlr
    if ws.asitipcod =  5   then
       display "Veiculo..:"  to veiculo
    end if
 else
    initialize d_cts00m34.atdcstvlr     to null
    initialize d_cts00m34.pasasivcldes  to null
    display by name d_cts00m34.atdcstvlr
    display by name d_cts00m34.pasasivcldes
 end if


 #--------------------------------------------------------------------
 # Digita dados para conclusao
 #--------------------------------------------------------------------
 input by name d_cts00m34.atdetpcod  without defaults

   on key (interrupt)
      let int_flag = true
      exit input

   on key (F6)
      #-----------------------------------------------------
      # Exibe Etapas
      #-----------------------------------------------------
      if ws.atdsrvorg =  10  then
         error " Funcao nao disponivel!"
      else
         open window w_branco at 04,02 with 04 rows,78 columns

         call cts00m11(param.atdsrvnum, param.atdsrvano)

         close window w_branco
      end if

 end input

 close window cts00m34

 let int_flag = false

end function  ###--  cts00m34

#--------------------------------------------------------------------
 function cts00m34_envio(param)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdprscod         like datmservico.atdprscod
 end record

 define ws2           record
    envio             char (08),
    faxch1            like datmfax.faxch1,
    faxchx            char (10),
    atdtrxnum         like datmtrxfila.atdtrxnum,
    mdtmsgnum         like datmmdtsrv.mdtmsgnum,
    faxenvdat         like datmfax.faxenvdat,
    interenvdat       like datmsrvint.caddat
 end record




        initialize  ws2.*  to  null

 initialize ws2.*  to null

 declare c_cts00m34_001 cursor for
   select caddat
     from datmsrvint
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
      and pstcoddig = param.atdprscod

 foreach c_cts00m34_001 into ws2.interenvdat
   exit foreach
 end foreach

 if ws2.interenvdat is not null then
    let ws2.envio = "INTERNET"
    return ws2.envio
 end if

 declare c_cts00m34_002  cursor for
   select atdtrxnum
     from datmtrxfila
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano

 foreach c_cts00m34_002  into  ws2.atdtrxnum
   exit foreach
 end foreach

 if ws2.atdtrxnum  is not null   then
    let ws2.envio = "PAGER"
    return ws2.envio
 end if

 declare c_cts00m34_003  cursor for
   select mdtmsgnum
     from datmmdtsrv
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano

 foreach c_cts00m34_003  into  ws2.mdtmsgnum
   exit foreach
 end foreach

 if ws2.mdtmsgnum  is not null   then
    let ws2.envio = " MDT "
    return ws2.envio
 end if

 let ws2.faxchx = param.atdsrvnum  using "&&&&&&&&",
                  param.atdsrvano  using "&&"
 let ws2.faxch1 = ws2.faxchx

 declare c_cts00m34_004  cursor for
   select faxenvdat
     from datmfax
    where faxsiscod = "CT"
      and faxsubcod = "PS"
      and faxch1    = ws2.faxch1

 foreach c_cts00m34_004  into  ws2.faxenvdat
   exit foreach
 end foreach

 if ws2.faxenvdat  is not null   then
    let ws2.envio = " FAX"
 end if

 return ws2.envio

 end function  ###--  cts00m34_envio

