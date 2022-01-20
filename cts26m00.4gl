###############################################################################
# Nome do Modulo: cts26m00                                             Raji   #
#                                                                             #
# Laudo - JIT                                                      Jun/2001   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 27/11/2001  PSI 14177-1  Ruiz         Altera a chamada da funcao cts11m02   #
#                                       para o ramo transporte(78).           #
#-----------------------------------------------------------------------------#
# 01/03/2002  Correio      Wagner       Incluir dptsgl psocor na pesquisa.    #
#-----------------------------------------------------------------------------#
# 26/07/2002  PSI 15655-8  Ruiz         Alerta de oficina cortada.            #
#-----------------------------------------------------------------------------#
# 08/01/2003  PSI 16400-3  Henrique     JIT-RE.                               #
#-----------------------------------------------------------------------------#
# 04/06/2003  PSI 17027-5  Ruiz         Helio - OSF 19968 - Buscar campo      #
#                                       asiofndigflg                          #
#-----------------------------------------------------------------------------#
# 17/11/2003  Meta,Ivone     PSI179345  Controle da abertura da janela de     #
#                            OSF28851                       alerta            #
#-----------------------------------------------------------------------------#
# 19/05/2005  Solda, Meta    PSI191108  Implementar o codigo da via(emeviacod)#
#-----------------------------------------------------------------------------#
# 02/08/2005  Helio (Meta)  PSI 192015  Inibir campo roddantxt no input       #
#-----------------------------------------------------------------------------#
# 06/02/2006  Priscila      Zeladoria   Buscar data e hora do banco de dados  #
#-----------------------------------------------------------------------------#
# 21/09/2006  Ligia Mattge   PSI202720 Passando ult.campo nulo no cts16g00    #
#-----------------------------------------------------------------------------#
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# ---------- ------------- --------- -----------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32              #
#-----------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a    #
#                                         global                              #
# 13/08/2009 Sergio Burini     PSI 244236 Inclusão do Sub-Dairro              #
#-----------------------------------------------------------------------------#
# 05/01/2010 Amilton                 Projeto sucursal smallint                #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

 define m_prep_sql    smallint      #psi179345  ivone

 define d_cts26m00    record
    servico           char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
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

 define w_cts26m00    record
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
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
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
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    socvclcod         like datmservico.socvclcod   ,
    asiofndigflg      like datkasitip.asiofndigflg , #OSF 19968
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define w_hist record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define a_cts26m00 array[3] of record
                                  operacao     char (01)
                                 ,lclidttxt    like datmlcl.lclidttxt
                                 ,lgdtxt       char (65)
                                 ,lgdtip       like datmlcl.lgdtip
                                 ,lgdnom       like datmlcl.lgdnom
                                 ,lgdnum       like datmlcl.lgdnum
                                 ,brrnom       like datmlcl.brrnom
                                 ,lclbrrnom    like datmlcl.lclbrrnom
                                 ,endzon       like datmlcl.endzon
                                 ,cidnom       like datmlcl.cidnom
                                 ,ufdcod       like datmlcl.ufdcod
                                 ,lgdcep       like datmlcl.lgdcep
                                 ,lgdcepcmp    like datmlcl.lgdcepcmp
                                 ,lclltt       like datmlcl.lclltt
                                 ,lcllgt       like datmlcl.lcllgt
                                 ,dddcod       like datmlcl.dddcod
                                 ,lcltelnum    like datmlcl.lcltelnum
                                 ,lclcttnom    like datmlcl.lclcttnom
                                 ,lclrefptotxt like datmlcl.lclrefptotxt
                                 ,c24lclpdrcod like datmlcl.c24lclpdrcod
                                 ,ofnnumdig    like sgokofi.ofnnumdig
                                 ,emeviacod    like datmemeviadpt.emeviacod
                                 ,celteldddcod like datmlcl.celteldddcod
                                 ,celtelnum    like datmlcl.celtelnum
                                 ,endcmp       like datmlcl.endcmp
                               end record

 define arr_aux       smallint
 define w_retorno     smallint

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint

 define aux_libant    like datmservico.atdlibflg,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano,
        aux_libhor    char (05)                 ,
        aux_today     char (10)                 ,
        aux_hora      char (05)                 ,
        aux_ano       char (02)                 ,
        aux_ano4      char (04)                 ,
        cpl_atdsrvnum like datmservico.atdsrvnum,
        cpl_atdsrvano like datmservico.atdsrvano,
        cpl_atdsrvorg like datmservico.atdsrvorg

##inicio - 179345 (ivone)
#--------------------------------------------------------------------
function cts26m00_prepara()
#--------------------------------------------------------------------
   define l_sql  char(300)

   let l_sql = " select grlinf ",
                 " from igbkgeral ",
                " where  mducod = 'C24' ",
                  " and  grlchv = 'RADIO-DEMJI' "

   prepare p_cts26m00_001 from l_sql
   declare c_cts26m00_001 cursor for p_cts26m00_001

   let m_prep_sql = true

end function
##fim - 179345 (ivone)
#--------------------------------------------------------------------
 function cts26m00()
#--------------------------------------------------------------------

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod,
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    confirma          char (01),
    grvflg            smallint,
    refatdsrvnum      like datmservico.atdsrvnum   ,
    refatdsrvano      like datmservico.atdsrvano
 end record

 define l_grlinf      like igbkgeral.grlinf  #psi179345  ivone

 define l_data         date,
        l_hora2        datetime hour to minute,
        l_acesso       smallint

 initialize ws.*  to null
 initialize m_subbairro to null

 --------------------[ verifica se e jit-re ]----------------------
 if g_documento.atdsrvnum is not null then
    select refatdsrvnum,refatdsrvano
         into ws.refatdsrvnum,
              ws.refatdsrvano
         from datmsrvjit
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano
    if ws.refatdsrvnum is not null then
       let aux_ano4 = "20" clipped, ws.refatdsrvano using "&&"
       select sinvstnum
           from datmpedvist
          where sinvstnum = ws.refatdsrvnum
            and sinvstano = aux_ano4
       if sqlca.sqlcode = 0 then  # este servico e JIT-RE
          call cts21m03(ws.refatdsrvnum,aux_ano4) # chama laudo RE
          return
       end if
    end if
 end if
#--------------------------------#
 let g_documento.atdsrvorg = 1
#--------------------------------#

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let int_flag      = false
 let aux_today     = l_data
 let aux_hora      = l_hora2
 let aux_ano       = aux_today[9,10]

 open window cts26m00 at 04,02 with form "cts26m00"
                      attribute(form line 1)

 if g_documento.atdsrvnum is null then
    display "(F1)Help(F3)Refer(F5)Espelho(F6)Hist(F7)Funcoes(F8)Destino(F9)Copia" to msgfun
 else
    select refatdsrvnum,
           refatdsrvano
      into ws.refatdsrvnum,
           ws.refatdsrvano
      from datmsrvjit
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
    if sqlca.sqlcode = 0 then
       display "(F1)Help(F3)Refer(F5)Espelho(F6)Hist(F7)Func(F8)Destino(F9)Conclui(F2)Laudo" to msgfun
    else
       display "(F1)Help(F3)Refer(F5)Espelho(F6)Hist(F7)Func(F8)Destino(F9)Conclui" to msgfun
    end if
 end if

 initialize d_cts26m00.*,
            w_cts26m00.*,
            aux_libant  ,
            cpl_atdsrvnum,
            cpl_atdsrvano,
            cpl_atdsrvorg  to null

 initialize a_cts26m00 to null

#--------------------------------------------------------------------
# Identificacao do CONVENIO
#--------------------------------------------------------------------

 let w_cts26m00.ligcvntip = g_documento.ligcvntip

 select cpodes into d_cts26m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts26m00.ligcvntip

 if g_documento.atdsrvnum is not null then
    call consulta_cts26m00()

    call cts26m00_display()

    display by name a_cts26m00[1].lgdtxt,
                    a_cts26m00[1].lclbrrnom,
                    a_cts26m00[1].cidnom,
                    a_cts26m00[1].ufdcod,
                    a_cts26m00[1].lclrefptotxt,
                    a_cts26m00[1].endzon,
                    a_cts26m00[1].dddcod,
                    a_cts26m00[1].lcltelnum,
                    a_cts26m00[1].lclcttnom,
                    a_cts26m00[1].celteldddcod,
                    a_cts26m00[1].celtelnum,
                    a_cts26m00[1].endcmp

    if d_cts26m00.atdlibflg = "N"   then
       display by name d_cts26m00.atdlibdat attribute (invisible)
       display by name d_cts26m00.atdlibhor attribute (invisible)
    end if

    if d_cts26m00.refasstxt is not null  then
       display by name d_cts26m00.refasstxt attribute (reverse)
    end if

    if w_cts26m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"
    else
       if g_documento.aplnumdig  is not null   or
          d_cts26m00.vcllicnum   is not null   then
          call cts03g00 (1, g_documento.ramcod    ,
                            g_documento.succod    ,
                            g_documento.aplnumdig ,
                            g_documento.itmnumdig ,
                            d_cts26m00.vcllicnum  ,
                            g_documento.atdsrvnum ,
                            g_documento.atdsrvano )
       end if
    end if

    call modifica_cts26m00() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null and
       g_documento.acao <> "INC"    then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today  ,aux_hora)
       let g_rec_his = true
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then
       let d_cts26m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                        " ", g_documento.ramcod    using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"

       if g_documento.c24astcod <> "G13"  then
          call cts05g00 (g_documento.succod   ,
                         g_documento.ramcod   ,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig)
               returning d_cts26m00.nom      ,
                         d_cts26m00.corsus   ,
                         d_cts26m00.cornom   ,
                         d_cts26m00.cvnnom   ,
                         d_cts26m00.vclcoddig,
                         d_cts26m00.vcldes   ,
                         d_cts26m00.vclanomdl,
                         d_cts26m00.vcllicnum,
                         ws.vclchsinc        ,
                         ws.vclchsfnl        ,
                         d_cts26m00.vclcordes

          call cts26m01_caminhao(g_documento.succod   ,
                                 g_documento.aplnumdig,
                                 g_documento.itmnumdig,
                                 g_funapol.autsitatu)
                       returning d_cts26m00.camflg,
                                 w_cts26m00.ctgtrfcod
       end if
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts26m00.doctxt = "Cartao..: ", g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts26m00.nom      ,
                      d_cts26m00.corsus   ,
                      d_cts26m00.cornom   ,
                      d_cts26m00.cvnnom   ,
                      d_cts26m00.vclcoddig,
                      d_cts26m00.vcldes   ,
                      d_cts26m00.vclanomdl,
                      d_cts26m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts26m00.vclcordes
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

      call figrc072_setTratarIsolamento()        --> 223689

       call cts05g04 (g_documento.prporg   ,
                      g_documento.prpnumdig)
            returning d_cts26m00.nom      ,
                      d_cts26m00.corsus   ,
                      d_cts26m00.cornom   ,
                      d_cts26m00.cvnnom   ,
                      d_cts26m00.vclcoddig,
                      d_cts26m00.vcldes   ,
                      d_cts26m00.vclanomdl,
                      d_cts26m00.vcllicnum,
                      d_cts26m00.vclcordes
         if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Função cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
            return
         end if    --> 223689

       let d_cts26m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                        " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    let d_cts26m00.prsloccab   = "Prs.Local.:"
    let d_cts26m00.prslocflg   = "N"

    let d_cts26m00.c24astcod   = g_documento.c24astcod
    let d_cts26m00.c24solnom   = g_documento.solnom

    call c24geral8(d_cts26m00.c24astcod) returning d_cts26m00.c24astdes

    if d_cts26m00.c24astcod = "G13"  then
       let d_cts26m00.refatdsrvtxt = "Serv. Ref.:"
       display "/" at  09,49
       display "-" at  09,57
    end if

    call cts26m00_display()

#inicio psi179345  ivone

    if m_prep_sql is null or  m_prep_sql <> true  then
       call cts26m00_prepara()
    end if

    open c_cts26m00_001
    whenever error continue
    fetch c_cts26m00_001  into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT igbkgeral :',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
          error 'ctm26m00()/ mducod = C24 e grlchv = RADIO-DEMAU ' sleep 2
          clear form
          close window cts26m00
          let int_flag = false
          return
       end if
    end if

#fim psi179345 ivone

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------
    if (g_documento.succod    is not null   and
        g_documento.ramcod    is not null   and
        g_documento.aplnumdig is not null)  or
       (d_cts26m00.vcllicnum  is not null)  then
       call cts03g00 (1, g_documento.ramcod    ,
                         g_documento.succod    ,
                         g_documento.aplnumdig ,
                         g_documento.itmnumdig ,
                         d_cts26m00.vcllicnum  ,
                         g_documento.atdsrvnum ,
                         g_documento.atdsrvano )
    end if

    call inclui_cts26m00() returning ws.grvflg

    if ws.grvflg = true  then
       call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts26m00.funmat,
                     w_cts26m00.data      , w_cts26m00.hora)

       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if d_cts26m00.imdsrvflg =  "S"     and        # servico imediato
          d_cts26m00.atdlibflg =  "S"     and        # servico liberado
          d_cts26m00.prslocflg =  "N"     and        # prestador no local
          d_cts26m00.frmflg    =  "N"     then       # formulario
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
          if l_acesso = true then
             call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                  returning ws.confirma
             if ws.confirma  =  "S"   then
                  call cts00m02(aux_atdsrvnum, aux_atdsrvano, 1 )
             end if
          end if
       end if

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = aux_atdsrvnum
          and atdsrvano = aux_atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = aux_atdsrvnum
                              and atdsrvano = aux_atdsrvano)

       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          update datmservico set c24opemat = null
                           where atdsrvnum = aux_atdsrvnum
                             and atdsrvano = aux_atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(aux_atdsrvnum,aux_atdsrvano)
          end if
       end if
    end if
 end if

 clear form

 close window cts26m00

end function  ###  cts26m00

#--------------------------------------------------------------------
 function consulta_cts26m00()
#--------------------------------------------------------------------

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    vclcorcod         like datmservico.vclcorcod,
    funmat            like datmservico.funmat   ,
    funnom            like isskfunc.funnom       ,
    dptsgl            like isskfunc.dptsgl       ,
    codigosql         integer,
    succod            like datrservapol.succod   ,
    ramcod            like datrservapol.ramcod   ,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    edsnumref         like datrservapol.edsnumref,
    prporg            like datrligprp.prporg,
    prpnumdig         like datrligprp.prpnumdig,
    fcapcorg          like datrligpac.fcapacorg,
    fcapacnum         like datrligpac.fcapacnum
 end record

 initialize ws.*  to null

 select nom      ,
        vclcoddig,
        vcldes   ,
        vclanomdl,
        vcllicnum,
        corsus   ,
        cornom   ,
        vclcorcod,
        funmat   ,
        atddat   ,
        atdhor   ,
        atdlibflg,
        atdlibhor,
        atdlibdat,
        atdhorpvt,
        atdpvtretflg,
        atddatprg,
        atdhorprg,
        atdfnlflg,
        asitipcod,
        atdvcltip,
        atdprinvlcod,
        ciaempcod
   into d_cts26m00.nom      ,
        d_cts26m00.vclcoddig,
        d_cts26m00.vcldes   ,
        d_cts26m00.vclanomdl,
        d_cts26m00.vcllicnum,
        d_cts26m00.corsus   ,
        d_cts26m00.cornom   ,
        ws.vclcorcod        ,
        ws.funmat           ,
        w_cts26m00.atddat   ,
        w_cts26m00.atdhor   ,
        d_cts26m00.atdlibflg,
        d_cts26m00.atdlibhor,
        d_cts26m00.atdlibdat,
        w_cts26m00.atdhorpvt,
        w_cts26m00.atdpvtretflg,
        w_cts26m00.atddatprg,
        w_cts26m00.atdhorprg,
        w_cts26m00.atdfnlflg,
        d_cts26m00.asitipcod,
        w_cts26m00.atdvcltip,
        d_cts26m00.atdprinvlcod,
        g_documento.ciaempcod
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
   returning a_cts26m00[1].lclidttxt
            ,a_cts26m00[1].lgdtip
            ,a_cts26m00[1].lgdnom
            ,a_cts26m00[1].lgdnum
            ,a_cts26m00[1].lclbrrnom
            ,a_cts26m00[1].brrnom
            ,a_cts26m00[1].cidnom
            ,a_cts26m00[1].ufdcod
            ,a_cts26m00[1].lclrefptotxt
            ,a_cts26m00[1].endzon
            ,a_cts26m00[1].lgdcep
            ,a_cts26m00[1].lgdcepcmp
            ,a_cts26m00[1].lclltt
            ,a_cts26m00[1].lcllgt
            ,a_cts26m00[1].dddcod
            ,a_cts26m00[1].lcltelnum
            ,a_cts26m00[1].lclcttnom
            ,a_cts26m00[1].c24lclpdrcod
            ,a_cts26m00[1].celteldddcod
            ,a_cts26m00[1].celtelnum
            ,a_cts26m00[1].endcmp
            ,ws.codigosql
            ,a_cts26m00[1].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts26m00[1].lclbrrnom
 call cts06g10_monta_brr_subbrr(a_cts26m00[1].brrnom,
                                a_cts26m00[1].lclbrrnom)
      returning a_cts26m00[1].lclbrrnom

 select ofnnumdig into a_cts26m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts26m00[1].lgdtxt = a_cts26m00[1].lgdtip clipped, " ",
                            a_cts26m00[1].lgdnom clipped, " ",
                            a_cts26m00[1].lgdnum using "<<<<#"

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         2)
   returning a_cts26m00[2].lclidttxt
            ,a_cts26m00[2].lgdtip
            ,a_cts26m00[2].lgdnom
            ,a_cts26m00[2].lgdnum
            ,a_cts26m00[2].lclbrrnom
            ,a_cts26m00[2].brrnom
            ,a_cts26m00[2].cidnom
            ,a_cts26m00[2].ufdcod
            ,a_cts26m00[2].lclrefptotxt
            ,a_cts26m00[2].endzon
            ,a_cts26m00[2].lgdcep
            ,a_cts26m00[2].lgdcepcmp
            ,a_cts26m00[2].lclltt
            ,a_cts26m00[2].lcllgt
            ,a_cts26m00[2].dddcod
            ,a_cts26m00[2].lcltelnum
            ,a_cts26m00[2].lclcttnom
            ,a_cts26m00[2].c24lclpdrcod
            ,a_cts26m00[2].celteldddcod
            ,a_cts26m00[2].celtelnum
            ,a_cts26m00[2].endcmp
            ,ws.codigosql
            ,a_cts26m00[2].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[2].lclbrrnom = a_cts26m00[2].lclbrrnom
 call cts06g10_monta_brr_subbrr(a_cts26m00[2].brrnom,
                                a_cts26m00[2].lclbrrnom)
      returning a_cts26m00[2].lclbrrnom

 select ofnnumdig into a_cts26m00[2].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 2

 if ws.codigosql = notfound   then
    let d_cts26m00.dstflg = "N"
 else
    if ws.codigosql = 0   then
       let d_cts26m00.dstflg = "S"
    else
       error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

 let a_cts26m00[2].lgdtxt = a_cts26m00[2].lgdtip clipped, " ",
                            a_cts26m00[2].lgdnom clipped, " ",
                            a_cts26m00[2].lgdnum using "<<<<#"

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
   into w_cts26m00.sinvitflg,
        w_cts26m00.roddantxt,
        w_cts26m00.rmcacpflg,
        w_cts26m00.sindat   ,
        d_cts26m00.sinhor   ,
        w_cts26m00.vclcamtip,
        w_cts26m00.vclcrcdsc,
        w_cts26m00.vclcrgflg,
        w_cts26m00.vclcrgpso,
        w_cts26m00.bocflg   ,
        w_cts26m00.bocnum   ,
        w_cts26m00.bocemi   ,
        w_cts26m00.vcllibflg
   from datmservicocmp
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 let d_cts26m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into d_cts26m00.asitipabvdes
   from datkasitip
  where asitipcod = d_cts26m00.asitipcod

#--------------------------------------------------------------------
# Verifica se ha' ASSISTENCIA A PASSAGEIROS relacionada
#--------------------------------------------------------------------

 declare c_assist  cursor for
    select atdsrvnum, atdsrvano
      from datmassistpassag
     where refatdsrvnum = g_documento.atdsrvnum  and
           refatdsrvano = g_documento.atdsrvano
     order by atdsrvnum, atdsrvano

 foreach c_assist into ws.atdsrvnum,
                       ws.atdsrvano
 end foreach

 if ws.atdsrvnum is null  or
    ws.atdsrvano is null  then
    initialize d_cts26m00.refasstxt to null
 else
    let d_cts26m00.refasstxt = "ASSIST.PASSAG. ",
                               F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,07),
                          "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,02)
 end if

#--------------------------------------------------------------------
# Obtem documento do servico
#--------------------------------------------------------------------

 let w_cts26m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts26m00.lignum)
      returning g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum,
                g_documento.itaciacod

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts26m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                     " ", g_documento.ramcod    using "&&&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts26m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

#--------------------------------------------------------------------
# Dados da ligacao
#--------------------------------------------------------------------

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts26m00.c24astcod,
        w_cts26m00.ligcvntip,
        d_cts26m00.c24solnom
   from datmligacao
  where lignum  =  w_cts26m00.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts26m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts26m00.frmflg = "N"
 else
    let d_cts26m00.frmflg = "S"
 end if

 select cpodes
   into d_cts26m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts26m00.ligcvntip

#--------------------------------------------------------------------
# Descricao do ASSUNTO
#--------------------------------------------------------------------

 call c24geral8(d_cts26m00.c24astcod) returning d_cts26m00.c24astdes

#--------------------------------------------------------------------
# Obtem COR DO VEICULO
#--------------------------------------------------------------------

 select cpodes
   into d_cts26m00.vclcordes
   from iddkdominio
  where cponom    = "vclcorcod"  and
        cpocod    = ws.vclcorcod

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = 1
    and funmat = ws.funmat

 let d_cts26m00.atdtxt = w_cts26m00.atddat        clipped, " ",
                         w_cts26m00.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)

 if w_cts26m00.atdhorpvt is not null  or
    w_cts26m00.atdhorpvt  = "00:00"   then
    let d_cts26m00.imdsrvflg = "S"
 end if

 if w_cts26m00.atddatprg is not null  then
    let d_cts26m00.imdsrvflg = "N"
 end if

 if w_cts26m00.vclcamtip is not null  and
    w_cts26m00.vclcamtip <>  " "      then
    let d_cts26m00.camflg = "S"
 else
    if w_cts26m00.vclcrgflg is not null  and
       w_cts26m00.vclcrgflg <>  " "      then
       let d_cts26m00.camflg = "S"
    else
       let d_cts26m00.camflg = "N"
    end if
 end if

 let aux_libant = d_cts26m00.atdlibflg

 if d_cts26m00.atdlibflg = "N"  then
    let d_cts26m00.atdlibdat = w_cts26m00.atddat
    let d_cts26m00.atdlibhor = w_cts26m00.atdhor
 end if

 let d_cts26m00.sinvitflg    = w_cts26m00.sinvitflg
 let d_cts26m00.bocflg       = w_cts26m00.bocflg
 let d_cts26m00.roddantxt    = w_cts26m00.roddantxt
 let d_cts26m00.rmcacpflg    = w_cts26m00.rmcacpflg
 let d_cts26m00.sindat       = w_cts26m00.sindat

 let d_cts26m00.servico = g_documento.atdsrvorg using "&&",
                          "/", g_documento.atdsrvnum using "&&&&&&&",
                          "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts26m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts26m00.atdprinvlcod

end function  ###  consulta_cts26m00

#--------------------------------------------------------------------
 function modifica_cts26m00()
#--------------------------------------------------------------------

 define ws           record
    codigosql        integer,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor
 end record

 define hist_cts26m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key    char (01)

 define l_data     date,
        l_hora2    datetime hour to minute

 initialize ws.*  to null

 call input_cts26m00() returning hist_cts26m00.*

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize d_cts26m00.*    to null
    initialize a_cts26m00      to null
    initialize w_cts26m00.*    to null
    clear form
    return false
 end if

 whenever error continue

#--------------------------------------------------------------------
# Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO
#--------------------------------------------------------------------
 if g_documento.ramcod = 31  or
    g_documento.ramcod = 531 then
    call cts26m00_cambio (g_documento.succod   ,
                          g_documento.aplnumdig,
                          g_documento.itmnumdig)
                returning w_cts26m00.atdvcltip
 end if

#--------------------------------------------------------------------
# Verifica solicitacao de guincho para caminhao
#--------------------------------------------------------------------
 if d_cts26m00.asitipcod = 1  or       ###  Guincho
    d_cts26m00.asitipcod = 3  then     ###  Guincho/Tecnico
    if d_cts26m00.camflg = "S"  then
       let w_cts26m00.atdvcltip = 3
    end if
 end if

 begin work

 update datmservico set ( nom,
                          corsus,
                          cornom,
                          vclcoddig,
                          vcldes,
                          vclanomdl,
                          vcllicnum,
                          vclcorcod,
                          atdlibflg,
                          atdlibhor,
                          atdlibdat,
                          atdhorpvt,
                          atddatprg,
                          atdhorprg,
                          atdpvtretflg,
                          asitipcod,
                          atdvcltip,
                          atdprinvlcod,
                          prslocflg)
                      = ( d_cts26m00.nom      ,
                          d_cts26m00.corsus   ,
                          d_cts26m00.cornom   ,
                          d_cts26m00.vclcoddig,
                          d_cts26m00.vcldes   ,
                          d_cts26m00.vclanomdl,
                          d_cts26m00.vcllicnum,
                          w_cts26m00.vclcorcod,
                          d_cts26m00.atdlibflg,
                          d_cts26m00.atdlibhor,
                          d_cts26m00.atdlibdat,
                          w_cts26m00.atdhorpvt,
                          w_cts26m00.atddatprg,
                          w_cts26m00.atdhorprg,
                          w_cts26m00.atdpvtretflg,
                          d_cts26m00.asitipcod,
                          w_cts26m00.atdvcltip,
                          d_cts26m00.atdprinvlcod,
                          d_cts26m00.prslocflg)
                    where atdsrvnum = g_documento.atdsrvnum and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmservicocmp set ( vclcamtip,
                             vclcrcdsc,
                             vclcrgflg,
                             vclcrgpso,
                             sinvitflg,
                             bocflg   ,
                             bocnum   ,
                             bocemi   ,
                             vcllibflg,
                             roddantxt,
                             rmcacpflg,
                             sindat   ,
                             sinhor   )
                         = ( w_cts26m00.vclcamtip,
                             w_cts26m00.vclcrcdsc,
                             w_cts26m00.vclcrgflg,
                             w_cts26m00.vclcrgpso,
                             d_cts26m00.sinvitflg,
                             d_cts26m00.bocflg,
                             w_cts26m00.bocnum,
                             w_cts26m00.bocemi,
                             w_cts26m00.vcllibflg,
                             d_cts26m00.roddantxt,
                             d_cts26m00.rmcacpflg,
                             d_cts26m00.sindat,
                             d_cts26m00.sinhor)
                       where atdsrvnum = g_documento.atdsrvnum and
                             atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao do complemento do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 2
    if a_cts26m00[arr_aux].operacao is null  then
       let a_cts26m00[arr_aux].operacao = "M"
    end if
    let a_cts26m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    let ws.codigosql = cts06g07_local( a_cts26m00[arr_aux].operacao
                                    ,g_documento.atdsrvnum
                                    ,g_documento.atdsrvano
                                    ,arr_aux
                                    ,a_cts26m00[arr_aux].lclidttxt
                                    ,a_cts26m00[arr_aux].lgdtip
                                    ,a_cts26m00[arr_aux].lgdnom
                                    ,a_cts26m00[arr_aux].lgdnum
                                    ,a_cts26m00[arr_aux].lclbrrnom
                                    ,a_cts26m00[arr_aux].brrnom
                                    ,a_cts26m00[arr_aux].cidnom
                                    ,a_cts26m00[arr_aux].ufdcod
                                    ,a_cts26m00[arr_aux].lclrefptotxt
                                    ,a_cts26m00[arr_aux].endzon
                                    ,a_cts26m00[arr_aux].lgdcep
                                    ,a_cts26m00[arr_aux].lgdcepcmp
                                    ,a_cts26m00[arr_aux].lclltt
                                    ,a_cts26m00[arr_aux].lcllgt
                                    ,a_cts26m00[arr_aux].dddcod
                                    ,a_cts26m00[arr_aux].lcltelnum
                                    ,a_cts26m00[arr_aux].lclcttnom
                                    ,a_cts26m00[arr_aux].c24lclpdrcod
                                    ,a_cts26m00[arr_aux].ofnnumdig
                                    ,a_cts26m00[arr_aux].emeviacod
                                    ,a_cts26m00[arr_aux].celteldddcod
                                    ,a_cts26m00[arr_aux].celtelnum
                                    ,a_cts26m00[arr_aux].endcmp)


    if ws.codigosql is null   or
       ws.codigosql <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.codigosql, ") na alteracao do local de ocorrencia. AVISE A INFORMATICA!"
       else
          error " Erro (", ws.codigosql, ") na alteracao do local de destino. AVISE A INFORMATICA!"
       end if
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if aux_libant <> d_cts26m00.atdlibflg  then
    if d_cts26m00.atdlibflg = "S"  then
       let w_cts26m00.atdetpcod = 1
       let ws.atdetpdat = d_cts26m00.atdlibdat
       let ws.atdetphor = d_cts26m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
          returning l_data, l_hora2
       let w_cts26m00.atdetpcod = 2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts26m00.atdetpcod,
                               w_cts26m00.atdprscod ,
                               " ",
                               " ",
                               w_cts26m00.srrcoddig) returning w_retorno

    if w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento. AVISE A INFORMATICA!"
       prompt "" for char prompt_key
       rollback work
       return false
    end if
 end if

 whenever error stop

 commit work
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

 return true

end function  ###  modifica_cts26m00()



#-------------------------------------------------------------------------------
 function inclui_cts26m00()
#-------------------------------------------------------------------------------

 define hist_cts26m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql    integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        vclatmflg       like abbmveic.vclatmflg    ,
        vclcoddig       like abbmveic.vclcoddig    ,
        vstnumdig       like abbmveic.vstnumdig    ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq
 end record

 define l_data    date,
        l_hora2   datetime hour to minute

 while true

   initialize ws.*  to null

   let g_documento.acao = "INC"

   call input_cts26m00() returning hist_cts26m00.*

   if  int_flag  then
       let int_flag = false
       initialize d_cts26m00.*    to null
       initialize w_cts26m00.*    to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts26m00.data is null  then
       let w_cts26m00.data   = aux_today
       let w_cts26m00.hora   = aux_hora
       let w_cts26m00.funmat = g_issk.funmat
   end if

   if  d_cts26m00.frmflg = "S"  then
       call cts40g03_data_hora_banco(2)
          returning l_data, l_hora2
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

   if  w_cts26m00.atdfnlflg is null  then
       let w_cts26m00.atdfnlflg = "N"
       let w_cts26m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if


 #------------------------------------------------------------------------------
 # Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO
 #------------------------------------------------------------------------------
   if  g_documento.ramcod = 31  or
       g_documento.ramcod = 531 then
       call cts26m00_cambio( g_documento.succod   ,
                             g_documento.aplnumdig,
                             g_documento.itmnumdig )
            returning w_cts26m00.atdvcltip
   end if


 #------------------------------------------------------------------------------
 # Verifica solicitacao de guincho para caminhao
 #------------------------------------------------------------------------------
   if  d_cts26m00.asitipcod = 1  or       ###  Guincho
       d_cts26m00.asitipcod = 3  then     ###  Guincho/Tecnico
       if  d_cts26m00.camflg = "S"  then
           let w_cts26m00.atdvcltip = 3
       end if
   end if

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "1" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS26M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum = ws.lignum
   let aux_atdsrvnum      = ws.atdsrvnum
   let aux_atdsrvano      = ws.atdsrvano


 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts26m00.data         ,
                           w_cts26m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts26m00.funmat       ,
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
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                w_cts26m00.vclcorcod,
                                w_cts26m00.funmat   ,
                                d_cts26m00.atdlibflg,
                                d_cts26m00.atdlibhor,
                                d_cts26m00.atdlibdat,
                                w_cts26m00.data     ,     # atddat
                                w_cts26m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts26m00.atdhorpvt,
                                w_cts26m00.atddatprg,
                                w_cts26m00.atdhorprg,
                                "1"                 ,     # atdtip
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts26m00.atdprscod,
                                ""                  ,     # atdcstvlr
                                w_cts26m00.atdfnlflg,
                                w_cts26m00.atdfnlhor,
                                w_cts26m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts26m00.c24opemat,
                                d_cts26m00.nom      ,
                                d_cts26m00.vcldes   ,
                                d_cts26m00.vclanomdl,
                                d_cts26m00.vcllicnum,
                                d_cts26m00.corsus   ,
                                d_cts26m00.cornom   ,
                                w_cts26m00.cnldat   ,
                                ""                  ,     # pgtdat
                                w_cts26m00.c24nomctt,
                                w_cts26m00.atdpvtretflg,
                                w_cts26m00.atdvcltip,
                                d_cts26m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts26m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts26m00.atdprinvlcod,
                                g_documento.atdsrvorg   ) # atdsrvorg
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if d_cts26m00.prslocflg = "S" then
      update datmservico set prslocflg = d_cts26m00.prslocflg,
                             socvclcod = w_cts26m00.socvclcod,
                             srrcoddig = w_cts26m00.srrcoddig
       where datmservico.atdsrvnum = aux_atdsrvnum
         and datmservico.atdsrvano = aux_atdsrvano
   end if

 #------------------------------------------------------------------------------
 # Grava complemento do servico
 #------------------------------------------------------------------------------
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
                                w_cts26m00.vclcamtip,
                                w_cts26m00.vclcrcdsc,
                                w_cts26m00.vclcrgflg,
                                w_cts26m00.vclcrgpso,
                                d_cts26m00.sinvitflg,
                                d_cts26m00.bocflg   ,
                                w_cts26m00.bocnum   ,
                                w_cts26m00.bocemi   ,
                                w_cts26m00.vcllibflg,
                                d_cts26m00.roddantxt,
                                d_cts26m00.rmcacpflg,
                                d_cts26m00.sindat   ,
                                d_cts26m00.sinhor    )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 2
       if  a_cts26m00[arr_aux].operacao is null  then
           let a_cts26m00[arr_aux].operacao = "I"
       end if
       let a_cts26m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       let ws.codigosql = cts06g07_local( a_cts26m00[arr_aux].operacao
                                       ,aux_atdsrvnum
                                       ,aux_atdsrvano
                                       ,arr_aux
                                       ,a_cts26m00[arr_aux].lclidttxt
                                       ,a_cts26m00[arr_aux].lgdtip
                                       ,a_cts26m00[arr_aux].lgdnom
                                       ,a_cts26m00[arr_aux].lgdnum
                                       ,a_cts26m00[arr_aux].lclbrrnom
                                       ,a_cts26m00[arr_aux].brrnom
                                       ,a_cts26m00[arr_aux].cidnom
                                       ,a_cts26m00[arr_aux].ufdcod
                                       ,a_cts26m00[arr_aux].lclrefptotxt
                                       ,a_cts26m00[arr_aux].endzon
                                       ,a_cts26m00[arr_aux].lgdcep
                                       ,a_cts26m00[arr_aux].lgdcepcmp
                                       ,a_cts26m00[arr_aux].lclltt
                                       ,a_cts26m00[arr_aux].lcllgt
                                       ,a_cts26m00[arr_aux].dddcod
                                       ,a_cts26m00[arr_aux].lcltelnum
                                       ,a_cts26m00[arr_aux].lclcttnom
                                       ,a_cts26m00[arr_aux].c24lclpdrcod
                                       ,a_cts26m00[arr_aux].ofnnumdig
                                       ,a_cts26m00[arr_aux].emeviacod
                                       ,a_cts26m00[arr_aux].celteldddcod
                                       ,a_cts26m00[arr_aux].celtelnum
                                       ,a_cts26m00[arr_aux].endcmp)

       if  ws.codigosql is null  or
           ws.codigosql <> 0     then
           if  arr_aux = 1  then
               error " Erro (", ws.codigosql, ") na gravacao do",
                     " local de ocorrencia. AVISE A INFORMATICA!"
           else
               error " Erro (", ws.codigosql, ") na gravacao do",
                     " local de destino. AVISE A INFORMATICA!"
           end if
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  w_cts26m00.atdetpcod is null  then
       if  d_cts26m00.atdlibflg = "S"  then
           let w_cts26m00.atdetpcod = 1
           let ws.etpfunmat = w_cts26m00.funmat
           let ws.atdetpdat = d_cts26m00.atdlibdat
           let ws.atdetphor = d_cts26m00.atdlibhor
       else
           let w_cts26m00.atdetpcod = 2
           let ws.etpfunmat = w_cts26m00.funmat
           let ws.atdetpdat = w_cts26m00.data
           let ws.atdetphor = w_cts26m00.hora
       end if
   else

      call cts10g04_insere_etapa(aux_atdsrvnum,
                                 aux_atdsrvano,
                                 1,
                                 w_cts26m00.atdprscod,
                                 " ",
                                 " ",
                                 w_cts26m00.srrcoddig )returning w_retorno

       if  w_retorno <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts26m00.cnldat
       let ws.atdetphor = w_cts26m00.atdfnlhor
       let ws.etpfunmat = w_cts26m00.c24opemat
   end if

   call cts10g04_insere_etapa(aux_atdsrvnum,
                              aux_atdsrvano,
                              w_cts26m00.atdetpcod,
                              w_cts26m00.atdprscod,
                              w_cts26m00.c24nomctt,
                              " ",
                              w_cts26m00.srrcoddig )returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if  g_documento.aplnumdig is not null  and
       g_documento.aplnumdig <> 0        then

       call cts10g02_grava_servico_apolice(ws.atdsrvnum         ,
                                           ws.atdsrvano         ,
                                           g_documento.succod   ,
                                           g_documento.ramcod   ,
                                           g_documento.aplnumdig,
                                           g_documento.itmnumdig,
                                           g_documento.edsnumref)
            returning ws.tabname,
                      ws.codigosql
       if  ws.codigosql <> 0  then
           error " Erro (", ws.codigosql, ") na gravacao do",
                 " relacionamento servico x apolice. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
       if g_documento.cndslcflg = "S"  then
          select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                 into ws.cdtnom,ws.cgccpfnum,ws.cgccpfdig
                 from tmpcondutor
          call grava_condutor(g_documento.succod,g_documento.aplnumdig,
                              g_documento.itmnumdig,ws.cdtnom,ws.cgccpfnum,
                              ws.cgccpfdig,"D","CENTRAL24H") returning ws.cdtseq
               # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
          insert into datrsrvcnd
                    (atdsrvnum,
                     atdsrvano,
                     succod   ,
                     aplnumdig,
                     itmnumdig,
                     vclcndseq)
             values (aux_atdsrvnum        ,
                     aux_atdsrvano        ,
                     g_documento.succod   ,
                     g_documento.aplnumdig,
                     g_documento.itmnumdig,
                     ws.cdtseq             )
          if  sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na gravacao do",
                    " relacionamento servico x condutor. AVISE A INFORMATICA!"
              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
         end if
       end if
   end if


 #------------------------------------------------------------------------------
 # Interface SINISTRO - indicacao de oficinas credenciadas
 #------------------------------------------------------------------------------
   if  a_cts26m00[2].ofnnumdig is not null  then
       call fsgoa005_ct24hs( a_cts26m00[2].ofnnumdig ,
                             1                    ,
                             w_cts26m00.data      ,
                             w_cts26m00.hora      ,
                             g_documento.aplnumdig,
                             d_cts26m00.vcllicnum ,
                             "", "", "", "", ""   ,
                             g_issk.empcod        ,
                             w_cts26m00.funmat,"N","N","N","N")
            returning ws.codigosql

       if  ws.codigosql <> 0  then
           error " Erro (", sqlca.sqlcode, ") na indicacao da",
                 " oficina credenciada!"
           prompt "" for char ws.prompt_key
       end if
   end if

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   if w_hist.hist1 is not null then   # registra o motivo da escolha oficina
      call cts10g02_historico(aux_atdsrvnum    , aux_atdsrvano  ,
                              w_cts26m00.data  , w_cts26m00.hora,
                              w_cts26m00.funmat, w_hist.* )
           returning ws.histerr
   end if
   call cts10g02_historico(aux_atdsrvnum    , aux_atdsrvano  ,
                           w_cts26m00.data  , w_cts26m00.hora,
                           w_cts26m00.funmat, hist_cts26m00.* )
        returning ws.histerr

### if ws.histerr  = 0  then
### initialize g_documento.acao  to null
### end if


 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let d_cts26m00.servico = g_documento.atdsrvorg using "&&",
                            "/", aux_atdsrvnum using "&&&&&&&",
                            "-", aux_atdsrvano using "&&"
   display d_cts26m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function  ###  inclui_cts26m00

#--------------------------------------------------------------------
 function input_cts26m00()
#--------------------------------------------------------------------

 define hist_cts26m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    refatdsrvorg      like datmservico.atdsrvorg,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    retflg            char (01),
    prpflg            char (01),
    senhaok           char (01),
    blqnivcod         like datkblq.blqnivcod,
    vcllicant         like datmservico.vcllicnum,
    endcep            like glaklgd.lgdcep,
    endcepcmp         like glaklgd.lgdcepcmp,
    confirma          char (01),
    dtparam           char (16),
    codigosql         integer,
    resp              char (01),
    linha1            char (62),
    linha2            char (62),
    linha3            char (62),
    linha4            char (62),
    auxatdsrvorg      like datmservico.atdsrvorg   ,
    auxatdsrvnum      like datmservico.atdsrvnum   ,
    auxatdsrvano      like datmservico.atdsrvano   ,
    refatdsrvnum      like datmsrvjit.refatdsrvnum,
    refatdsrvano      like datmsrvjit.refatdsrvano,
    opcao             smallint,
    opcaodes          char(20),
    ofnstt            like sgokofi.ofnstt
 end record

#define aux_ano4      char (04)
 define prompt_key    char (01)
 define erros_chk     char (01)
 define l_acesso      smallint

 define l_data          date,
        l_hora2         datetime hour to minute

 initialize ws.*     to null
 initialize aux_ano4 to null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let ws.dtparam        = l_data using "yyyy-mm-dd"
 let ws.dtparam[12,16] = l_hora2

 let ws.vcllicant      = d_cts26m00.vcllicnum

 input by name d_cts26m00.nom         ,
               d_cts26m00.corsus      ,
               d_cts26m00.cornom      ,
               d_cts26m00.vclcoddig   ,
               d_cts26m00.vclanomdl   ,
               d_cts26m00.vcllicnum   ,
               d_cts26m00.vclcordes   ,
               d_cts26m00.camflg      ,
               d_cts26m00.refatdsrvorg,
               d_cts26m00.refatdsrvnum,
               d_cts26m00.refatdsrvano,
               d_cts26m00.sindat      ,
               d_cts26m00.sinhor      ,
##             d_cts26m00.roddantxt   ,
               d_cts26m00.sinvitflg   ,
               d_cts26m00.bocflg      ,
               d_cts26m00.asitipcod   ,
               d_cts26m00.dstflg      ,
               d_cts26m00.rmcacpflg   ,
               d_cts26m00.imdsrvflg   ,
               d_cts26m00.atdprinvlcod,
               d_cts26m00.prslocflg   ,
               d_cts26m00.atdlibflg   ,
               d_cts26m00.frmflg        without defaults

   before field nom
          display by name d_cts26m00.nom        attribute (reverse)

          if g_documento.atdsrvnum   is not null   and
             g_documento.atdsrvano   is not null   and
             d_cts26m00.camflg       =  "S"        and
             w_cts26m00.atdfnlflg    =  "N"        then
             call cts26m01(w_cts26m00.ctgtrfcod,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           w_cts26m00.vclcrgflg, w_cts26m00.vclcrgpso,
                           w_cts26m00.vclcamtip, w_cts26m00.vclcrcdsc)
                 returning w_cts26m00.vclcrgflg, w_cts26m00.vclcrgpso,
                           w_cts26m00.vclcamtip, w_cts26m00.vclcrcdsc
          end if

   after  field nom
          display by name d_cts26m00.nom

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                next field nom
          end if
          if d_cts26m00.nom is null or
             d_cts26m00.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if

          if w_cts26m00.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                   "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                  returning ws.confirma

             call cts26m03(w_cts26m00.atdfnlflg,
                           d_cts26m00.imdsrvflg,
                           w_cts26m00.atdhorpvt,
                           w_cts26m00.atddatprg,
                           w_cts26m00.atdhorprg,
                           w_cts26m00.atdpvtretflg)
                 returning w_cts26m00.atdhorpvt,
                           w_cts26m00.atddatprg,
                           w_cts26m00.atdhorprg,
                           w_cts26m00.atdpvtretflg

             next field frmflg
          end if

   before field corsus
          display by name d_cts26m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts26m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.corsus is not null  then
                select cornom
                  into d_cts26m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts26m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts26m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts26m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts26m00.cornom

   before field vclcoddig
          display by name d_cts26m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts26m00.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts26m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else
             if d_cts26m00.vclcoddig is null  or
                d_cts26m00.vclcoddig =  0     then
                call agguvcl() returning d_cts26m00.vclcoddig
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts26m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cts15g00(d_cts26m00.vclcoddig)
                 returning d_cts26m00.vcldes

             display by name d_cts26m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts26m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts26m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.vclanomdl is null or
                d_cts26m00.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts26m00.vclcoddig, d_cts26m00.vclanomdl) = false  then
                   error " Veiculo nao consta como fabricado em ", d_cts26m00.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts26m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts26m00.vcllicnum

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vclanomdl
        end if

        if not srp1415(d_cts26m00.vcllicnum)  then
           error " Placa invalida!"
           next field vcllicnum
        end if

        #---------------------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if g_documento.aplnumdig   is null       and
           d_cts26m00.vcllicnum    is not null   then

           if d_cts26m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.senhaok  to null

              call cts13g00(d_cts26m00.c24astcod,
                            "", "", "", "",
                            d_cts26m00.vcllicnum,
                            "", "", "")
                   returning ws.blqnivcod, ws.senhaok

              if ws.blqnivcod  =  3   then
                 error " Bloqueio cadastrado nao permite atendimento para este assunto/apolice!"
                 next field vcllicnum
              end if

              if ws.blqnivcod  =  2     and
                 ws.senhaok    =  "n"   then
                 error " Bloqueio necessita de permissao para atendimento!"
                 next field vcllicnum
              end if
           end if

           #-----------------------------------------------------------------
           # Verifica se ja' houve solicitacao de servico para apolice
           #-----------------------------------------------------------------
           call cts03g00 (1, g_documento.ramcod    ,
                             g_documento.succod    ,
                             g_documento.aplnumdig ,
                             g_documento.itmnumdig ,
                             d_cts26m00.vcllicnum  ,
                             g_documento.atdsrvnum ,
                             g_documento.atdsrvano )
        end if

   before field vclcordes
          display by name d_cts26m00.vclcordes  attribute (reverse)

   after  field vclcordes
          display by name d_cts26m00.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.vclcordes  is not null then
                let w_cts26m00.vclcordes = d_cts26m00.vclcordes[2,9]

                select cpocod into w_cts26m00.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts26m00.vclcordes

                if sqlca.sqlcode = notfound    then
                   error " Cor fora do padrao!"
                   call c24geral4()
                        returning w_cts26m00.vclcorcod, d_cts26m00.vclcordes

                   if w_cts26m00.vclcorcod  is null   then
                      error " Cor do veiculo deve ser informado!"
                      next field vclcordes
                   else
                      display by name d_cts26m00.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts26m00.vclcorcod, d_cts26m00.vclcordes

                if w_cts26m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts26m00.vclcordes
                end if
             end if
          end if

   before field camflg
          display by name d_cts26m00.camflg attribute (reverse)

   after  field camflg
          display by name d_cts26m00.camflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts26m00.camflg  is null)  or
                 (d_cts26m00.camflg  <>  "S"   and
                  d_cts26m00.camflg  <>  "N")) then
                error " Informacao sobre caminhao/utilitario invalida!"
                next field camflg
             end if

             if d_cts26m00.camflg = "S"  then
                call cts26m01(w_cts26m00.ctgtrfcod,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              w_cts26m00.vclcrgflg, w_cts26m00.vclcrgpso,
                              w_cts26m00.vclcamtip, w_cts26m00.vclcrcdsc)
                    returning w_cts26m00.vclcrgflg, w_cts26m00.vclcrgpso,
                              w_cts26m00.vclcamtip, w_cts26m00.vclcrcdsc

                if w_cts26m00.vclcamtip  is null   and
                   w_cts26m00.vclcrgflg  is null   then
                   error " Faltam informacoes sobre caminhao/utilitario!"
                   next field camflg
                end if
             else
                initialize w_cts26m00.vclcamtip to null
                initialize w_cts26m00.vclcrcdsc to null
                initialize w_cts26m00.vclcrgflg to null
                initialize w_cts26m00.vclcrgpso to null
             end if

             if (g_documento.atdsrvnum is not null   and
                 g_documento.atdsrvano is not null)  or
                (d_cts26m00.c24astcod <> "G13"    )  then
                let a_cts26m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

                let m_acesso_ind = false
                let m_atdsrvorg = 4
                call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                     returning m_acesso_ind
                if m_acesso_ind = false then
                   call cts06g03( 1
                                 ,m_atdsrvorg
                                 ,w_cts26m00.ligcvntip
                                 ,aux_today
                                 ,aux_hora
                                 ,a_cts26m00[1].lclidttxt
                                 ,a_cts26m00[1].cidnom
                                 ,a_cts26m00[1].ufdcod
                                 ,a_cts26m00[1].brrnom
                                 ,a_cts26m00[1].lclbrrnom
                                 ,a_cts26m00[1].endzon
                                 ,a_cts26m00[1].lgdtip
                                 ,a_cts26m00[1].lgdnom
                                 ,a_cts26m00[1].lgdnum
                                 ,a_cts26m00[1].lgdcep
                                 ,a_cts26m00[1].lgdcepcmp
                                 ,a_cts26m00[1].lclltt
                                 ,a_cts26m00[1].lcllgt
                                 ,a_cts26m00[1].lclrefptotxt
                                 ,a_cts26m00[1].lclcttnom
                                 ,a_cts26m00[1].dddcod
                                 ,a_cts26m00[1].lcltelnum
                                 ,a_cts26m00[1].c24lclpdrcod
                                 ,a_cts26m00[1].ofnnumdig
                                 ,a_cts26m00[1].celteldddcod
                                 ,a_cts26m00[1].celtelnum
                                 ,a_cts26m00[1].endcmp
                                 ,hist_cts26m00.*
                                 ,a_cts26m00[1].emeviacod )
                     returning    a_cts26m00[1].lclidttxt
                                 ,a_cts26m00[1].cidnom
                                 ,a_cts26m00[1].ufdcod
                                 ,a_cts26m00[1].brrnom
                                 ,a_cts26m00[1].lclbrrnom
                                 ,a_cts26m00[1].endzon
                                 ,a_cts26m00[1].lgdtip
                                 ,a_cts26m00[1].lgdnom
                                 ,a_cts26m00[1].lgdnum
                                 ,a_cts26m00[1].lgdcep
                                 ,a_cts26m00[1].lgdcepcmp
                                 ,a_cts26m00[1].lclltt
                                 ,a_cts26m00[1].lcllgt
                                 ,a_cts26m00[1].lclrefptotxt
                                 ,a_cts26m00[1].lclcttnom
                                 ,a_cts26m00[1].dddcod
                                 ,a_cts26m00[1].lcltelnum
                                 ,a_cts26m00[1].c24lclpdrcod
                                 ,a_cts26m00[1].ofnnumdig
                                 ,a_cts26m00[1].celteldddcod
                                 ,a_cts26m00[1].celtelnum
                                 ,a_cts26m00[1].endcmp
                                 ,ws.retflg
                                 ,hist_cts26m00.*
                                 ,a_cts26m00[1].emeviacod
                else
                   call cts06g11( 1
                                 ,m_atdsrvorg
                                 ,w_cts26m00.ligcvntip
                                 ,aux_today
                                 ,aux_hora
                                 ,a_cts26m00[1].lclidttxt
                                 ,a_cts26m00[1].cidnom
                                 ,a_cts26m00[1].ufdcod
                                 ,a_cts26m00[1].brrnom
                                 ,a_cts26m00[1].lclbrrnom
                                 ,a_cts26m00[1].endzon
                                 ,a_cts26m00[1].lgdtip
                                 ,a_cts26m00[1].lgdnom
                                 ,a_cts26m00[1].lgdnum
                                 ,a_cts26m00[1].lgdcep
                                 ,a_cts26m00[1].lgdcepcmp
                                 ,a_cts26m00[1].lclltt
                                 ,a_cts26m00[1].lcllgt
                                 ,a_cts26m00[1].lclrefptotxt
                                 ,a_cts26m00[1].lclcttnom
                                 ,a_cts26m00[1].dddcod
                                 ,a_cts26m00[1].lcltelnum
                                 ,a_cts26m00[1].c24lclpdrcod
                                 ,a_cts26m00[1].ofnnumdig
                                 ,a_cts26m00[1].celteldddcod
                                 ,a_cts26m00[1].celtelnum
                                 ,a_cts26m00[1].endcmp
                                 ,hist_cts26m00.*
                                 ,a_cts26m00[1].emeviacod )
                    returning     a_cts26m00[1].lclidttxt
                                 ,a_cts26m00[1].cidnom
                                 ,a_cts26m00[1].ufdcod
                                 ,a_cts26m00[1].brrnom
                                 ,a_cts26m00[1].lclbrrnom
                                 ,a_cts26m00[1].endzon
                                 ,a_cts26m00[1].lgdtip
                                 ,a_cts26m00[1].lgdnom
                                 ,a_cts26m00[1].lgdnum
                                 ,a_cts26m00[1].lgdcep
                                 ,a_cts26m00[1].lgdcepcmp
                                 ,a_cts26m00[1].lclltt
                                 ,a_cts26m00[1].lcllgt
                                 ,a_cts26m00[1].lclrefptotxt
                                 ,a_cts26m00[1].lclcttnom
                                 ,a_cts26m00[1].dddcod
                                 ,a_cts26m00[1].lcltelnum
                                 ,a_cts26m00[1].c24lclpdrcod
                                 ,a_cts26m00[1].ofnnumdig
                                 ,a_cts26m00[1].celteldddcod
                                 ,a_cts26m00[1].celtelnum
                                 ,a_cts26m00[1].endcmp
                                 ,ws.retflg
                                 ,hist_cts26m00.*
                                 ,a_cts26m00[1].emeviacod
                end if
                #------------------------------------------------------------------------------
                # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
                #------------------------------------------------------------------------------
                if g_documento.lclocodesres = "S" then
                   let w_cts26m00.atdrsdflg = "S"
                else
                   let w_cts26m00.atdrsdflg = "N"
                end if
                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_subbairro[1].lclbrrnom = a_cts26m00[1].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts26m00[1].brrnom,
                                               a_cts26m00[1].lclbrrnom)
                     returning a_cts26m00[1].lclbrrnom

                let a_cts26m00[1].lgdtxt = a_cts26m00[1].lgdtip clipped, " ",
                                           a_cts26m00[1].lgdnom clipped, " ",
                                           a_cts26m00[1].lgdnum using "<<<<#"

                if a_cts26m00[1].cidnom is not null and
                   a_cts26m00[1].ufdcod is not null then
                   call cts14g00 (d_cts26m00.c24astcod,
                                  "","","","",
                                  a_cts26m00[1].cidnom,
                                  a_cts26m00[1].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if

                display by name a_cts26m00[1].lgdtxt
                display by name a_cts26m00[1].lclbrrnom
                display by name a_cts26m00[1].endzon
                display by name a_cts26m00[1].cidnom
                display by name a_cts26m00[1].ufdcod
                display by name a_cts26m00[1].lclrefptotxt
                display by name a_cts26m00[1].lclcttnom
                display by name a_cts26m00[1].dddcod
                display by name a_cts26m00[1].lcltelnum
                display by name a_cts26m00[1].celteldddcod
                display by name a_cts26m00[1].celtelnum
                display by name a_cts26m00[1].endcmp

                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos ou nao preenchidos!"
                   next field camflg
                end if

                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then
                   call cts08g01("Q","N","LOCAL ONDE VEICULO SE ENCONTRA",
                                         "E' DE DIFICIL ACESSO ?",
                                         "GARAGEM, SUBSOLO, ESTACIONAMENTO",
                                         "REGISTRE INFORMACAO NO HISTORICO")
                        returning ws.confirma
                end if
             end if
          end if

   before field refatdsrvorg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  and
             d_cts26m00.c24astcod = "G13"   then
             display by name d_cts26m00.refatdsrvorg attribute (reverse)
          else
             display by name d_cts26m00.refatdsrvorg
             display by name d_cts26m00.refatdsrvnum
             display by name d_cts26m00.refatdsrvano
             next field sindat
          end if

   after  field refatdsrvorg
          display by name d_cts26m00.refatdsrvorg

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field camflg
          end if

          if  d_cts26m00.refatdsrvorg is null  then
           if  g_documento.succod    is not null  or
               g_documento.aplnumdig is not null  then
               call cts11m02( g_documento.succod   ,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig,
                              4                    , # atdsrvorg-remocao
                              g_documento.ramcod   )
                    returning d_cts26m00.refatdsrvorg,
                              d_cts26m00.refatdsrvnum,
                              d_cts26m00.refatdsrvano

               display by name d_cts26m00.refatdsrvorg
               display by name d_cts26m00.refatdsrvnum
               display by name d_cts26m00.refatdsrvano

               if  d_cts26m00.refatdsrvnum is null  and
                   d_cts26m00.refatdsrvano is null  then
                   let a_cts26m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
                   let m_acesso_ind = false
                   let m_atdsrvorg = 4
                   call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                        returning m_acesso_ind
                   if m_acesso_ind = false then
                      call cts06g03( 1
                                    ,m_atdsrvorg
                                    ,w_cts26m00.ligcvntip
                                    ,aux_today
                                    ,aux_hora
                                    ,a_cts26m00[1].lclidttxt
                                    ,a_cts26m00[1].cidnom
                                    ,a_cts26m00[1].ufdcod
                                    ,a_cts26m00[1].brrnom
                                    ,a_cts26m00[1].lclbrrnom
                                    ,a_cts26m00[1].endzon
                                    ,a_cts26m00[1].lgdtip
                                    ,a_cts26m00[1].lgdnom
                                    ,a_cts26m00[1].lgdnum
                                    ,a_cts26m00[1].lgdcep
                                    ,a_cts26m00[1].lgdcepcmp
                                    ,a_cts26m00[1].lclltt
                                    ,a_cts26m00[1].lcllgt
                                    ,a_cts26m00[1].lclrefptotxt
                                    ,a_cts26m00[1].lclcttnom
                                    ,a_cts26m00[1].dddcod
                                    ,a_cts26m00[1].lcltelnum
                                    ,a_cts26m00[1].c24lclpdrcod
                                    ,a_cts26m00[1].ofnnumdig
                                    ,a_cts26m00[1].celteldddcod
                                    ,a_cts26m00[1].celtelnum
                                    ,a_cts26m00[1].endcmp
                                    ,hist_cts26m00.*
                                    ,a_cts26m00[1].emeviacod )
                         returning a_cts26m00[1].lclidttxt
                                  ,a_cts26m00[1].cidnom
                                  ,a_cts26m00[1].ufdcod
                                  ,a_cts26m00[1].brrnom
                                  ,a_cts26m00[1].lclbrrnom
                                  ,a_cts26m00[1].endzon
                                  ,a_cts26m00[1].lgdtip
                                  ,a_cts26m00[1].lgdnom
                                  ,a_cts26m00[1].lgdnum
                                  ,a_cts26m00[1].lgdcep
                                  ,a_cts26m00[1].lgdcepcmp
                                  ,a_cts26m00[1].lclltt
                                  ,a_cts26m00[1].lcllgt
                                  ,a_cts26m00[1].lclrefptotxt
                                  ,a_cts26m00[1].lclcttnom
                                  ,a_cts26m00[1].dddcod
                                  ,a_cts26m00[1].lcltelnum
                                  ,a_cts26m00[1].c24lclpdrcod
                                  ,a_cts26m00[1].ofnnumdig
                                  ,a_cts26m00[1].celteldddcod
                                  ,a_cts26m00[1].celtelnum
                                  ,a_cts26m00[1].endcmp
                                  ,ws.retflg
                                  ,hist_cts26m00.*
                                  ,a_cts26m00[1].emeviacod
                   else
                      call cts06g11( 1
                                    ,m_atdsrvorg
                                    ,w_cts26m00.ligcvntip
                                    ,aux_today
                                    ,aux_hora
                                    ,a_cts26m00[1].lclidttxt
                                    ,a_cts26m00[1].cidnom
                                    ,a_cts26m00[1].ufdcod
                                    ,a_cts26m00[1].brrnom
                                    ,a_cts26m00[1].lclbrrnom
                                    ,a_cts26m00[1].endzon
                                    ,a_cts26m00[1].lgdtip
                                    ,a_cts26m00[1].lgdnom
                                    ,a_cts26m00[1].lgdnum
                                    ,a_cts26m00[1].lgdcep
                                    ,a_cts26m00[1].lgdcepcmp
                                    ,a_cts26m00[1].lclltt
                                    ,a_cts26m00[1].lcllgt
                                    ,a_cts26m00[1].lclrefptotxt
                                    ,a_cts26m00[1].lclcttnom
                                    ,a_cts26m00[1].dddcod
                                    ,a_cts26m00[1].lcltelnum
                                    ,a_cts26m00[1].c24lclpdrcod
                                    ,a_cts26m00[1].ofnnumdig
                                    ,a_cts26m00[1].celteldddcod
                                    ,a_cts26m00[1].celtelnum
                                    ,a_cts26m00[1].endcmp
                                    ,hist_cts26m00.*
                                    ,a_cts26m00[1].emeviacod )
                         returning a_cts26m00[1].lclidttxt
                                  ,a_cts26m00[1].cidnom
                                  ,a_cts26m00[1].ufdcod
                                  ,a_cts26m00[1].brrnom
                                  ,a_cts26m00[1].lclbrrnom
                                  ,a_cts26m00[1].endzon
                                  ,a_cts26m00[1].lgdtip
                                  ,a_cts26m00[1].lgdnom
                                  ,a_cts26m00[1].lgdnum
                                  ,a_cts26m00[1].lgdcep
                                  ,a_cts26m00[1].lgdcepcmp
                                  ,a_cts26m00[1].lclltt
                                  ,a_cts26m00[1].lcllgt
                                  ,a_cts26m00[1].lclrefptotxt
                                  ,a_cts26m00[1].lclcttnom
                                  ,a_cts26m00[1].dddcod
                                  ,a_cts26m00[1].lcltelnum
                                  ,a_cts26m00[1].c24lclpdrcod
                                  ,a_cts26m00[1].ofnnumdig
                                  ,a_cts26m00[1].celteldddcod
                                  ,a_cts26m00[1].celtelnum
                                  ,a_cts26m00[1].endcmp
                                  ,ws.retflg
                                  ,hist_cts26m00.*
                                  ,a_cts26m00[1].emeviacod
                   end if
                   #------------------------------------------------------------------------------
                   # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
                   #------------------------------------------------------------------------------
                   if g_documento.lclocodesres = "S" then
                      let w_cts26m00.atdrsdflg = "S"
                   else
                      let w_cts26m00.atdrsdflg = "N"
                   end if
                   # PSI 244589 - Inclusão de Sub-Bairro - Burini
                   let m_subbairro[1].lclbrrnom = a_cts26m00[1].lclbrrnom
                   call cts06g10_monta_brr_subbrr(a_cts26m00[1].brrnom,
                                                  a_cts26m00[1].lclbrrnom)
                        returning a_cts26m00[1].lclbrrnom

                   let a_cts26m00[1].lgdtxt = a_cts26m00[1].lgdtip clipped, " ",
                                              a_cts26m00[1].lgdnom clipped, " ",
                                              a_cts26m00[1].lgdnum using "<<<<#"

                   if a_cts26m00[1].cidnom is not null and
                      a_cts26m00[1].ufdcod is not null then
                      call cts14g00( d_cts26m00.c24astcod,
                                     "","","","",
                                     a_cts26m00[1].cidnom,
                                     a_cts26m00[1].ufdcod,
                                     "S",
                                     ws.dtparam)
                   end if

                   display by name a_cts26m00[1].lgdtxt
                   display by name a_cts26m00[1].lclbrrnom
                   display by name a_cts26m00[1].endzon
                   display by name a_cts26m00[1].cidnom
                   display by name a_cts26m00[1].ufdcod
                   display by name a_cts26m00[1].lclrefptotxt
                   display by name a_cts26m00[1].lclcttnom
                   display by name a_cts26m00[1].dddcod
                   display by name a_cts26m00[1].lcltelnum
                   display by name a_cts26m00[1].celteldddcod
                   display by name a_cts26m00[1].celtelnum
                   display by name a_cts26m00[1].endcmp

                   if  ws.retflg = "N"  then
                       error " Dados referentes ao local incorretos",
                             " ou nao preenchidos!"
                       next field refatdsrvorg
                   else
                       next field sindat
                   end if
               end if
           else
               initialize d_cts26m00.refatdsrvnum to null
               initialize d_cts26m00.refatdsrvano to null
               display by name d_cts26m00.refatdsrvnum
               display by name d_cts26m00.refatdsrvano
           end if
          end if

   before field refatdsrvnum
          display by name d_cts26m00.refatdsrvnum attribute (reverse)

   after  field refatdsrvnum
          display by name d_cts26m00.refatdsrvnum

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field refatdsrvorg
          end if

          if d_cts26m00.refatdsrvorg is not null  and
             d_cts26m00.refatdsrvnum is null      then
             error " Numero do servico de referencia nao informado!"
             next field refatdsrvnum
          end if

   before field refatdsrvano
          display by name d_cts26m00.refatdsrvano attribute (reverse)

   after  field refatdsrvano
          display by name d_cts26m00.refatdsrvano

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field refatdsrvnum
          end if

          if d_cts26m00.refatdsrvnum is not null  and
             d_cts26m00.refatdsrvano is null      then
             error " Ano do servico de referencia nao informado!"
             next field refatdsrvano
          end if

          if d_cts26m00.refatdsrvorg is not null  and
             d_cts26m00.refatdsrvnum is not null  and
             d_cts26m00.refatdsrvano is not null  then
             select atdsrvorg
               into ws.refatdsrvorg
               from DATMSERVICO
                    where atdsrvnum = d_cts26m00.refatdsrvnum
                      and atdsrvano = d_cts26m00.refatdsrvano

             if  ws.refatdsrvorg <> d_cts26m00.refatdsrvorg  then
                 error " Origem do numero de servico invalido.",
                       " A origem deve ser ", ws.refatdsrvorg using "&&"
                 next field refatdsrvorg
             end if

             call ctx04g00_local_gps (d_cts26m00.refatdsrvnum,
                                      d_cts26m00.refatdsrvano,
                                      1)
               returning a_cts26m00[1].lclidttxt
                        ,a_cts26m00[1].lgdtip
                        ,a_cts26m00[1].lgdnom
                        ,a_cts26m00[1].lgdnum
                        ,a_cts26m00[1].lclbrrnom
                        ,a_cts26m00[1].brrnom
                        ,a_cts26m00[1].cidnom
                        ,a_cts26m00[1].ufdcod
                        ,a_cts26m00[1].lclrefptotxt
                        ,a_cts26m00[1].endzon
                        ,a_cts26m00[1].lgdcep
                        ,a_cts26m00[1].lgdcepcmp
                        ,a_cts26m00[1].lclltt
                        ,a_cts26m00[1].lcllgt
                        ,a_cts26m00[1].dddcod
                        ,a_cts26m00[1].lcltelnum
                        ,a_cts26m00[1].lclcttnom
                        ,a_cts26m00[1].c24lclpdrcod
                        ,a_cts26m00[1].celteldddcod
                        ,a_cts26m00[1].celtelnum
                        ,a_cts26m00[1].endcmp
                        ,ws.codigosql
                        ,a_cts26m00[1].emeviacod

             if ws.codigosql <> 0  then
                error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                next field refatdsrvorg
             end if

             select ofnnumdig into a_cts26m00[1].ofnnumdig
               from datmlcl
              where atdsrvano = g_documento.atdsrvano
                and atdsrvnum = g_documento.atdsrvnum
                and c24endtip = 1

             let a_cts26m00[1].lgdtxt = a_cts26m00[1].lgdtip clipped, " ",
                                        a_cts26m00[1].lgdnom clipped, " ",
                                        a_cts26m00[1].lgdnum using "<<<<#"

             if g_documento.succod    is not null  and
                g_documento.ramcod    is not null  and
                g_documento.aplnumdig is not null  and
                g_documento.itmnumdig is not null  then
                select atdsrvnum, atdsrvano
                  from datrservapol
                 where atdsrvnum = d_cts26m00.refatdsrvnum  and
                       atdsrvano = d_cts26m00.refatdsrvano  and
                       succod    = g_documento.succod       and
                       ramcod    = g_documento.ramcod       and
                       aplnumdig = g_documento.aplnumdig    and
                       itmnumdig = g_documento.itmnumdig

                if sqlca.sqlcode = notfound  then
                   error " Servico de referencia nao pertence ao documento informado!"
                   next field refatdsrvorg
                end if
             end if

             display by name a_cts26m00[1].lgdtxt
             display by name a_cts26m00[1].lclbrrnom
             display by name a_cts26m00[1].endzon
             display by name a_cts26m00[1].cidnom
             display by name a_cts26m00[1].ufdcod
             display by name a_cts26m00[1].lclrefptotxt
             display by name a_cts26m00[1].lclcttnom
             display by name a_cts26m00[1].dddcod
             display by name a_cts26m00[1].lcltelnum
             display by name a_cts26m00[1].celteldddcod
             display by name a_cts26m00[1].celtelnum
             display by name a_cts26m00[1].endcmp

             let a_cts26m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
             let m_acesso_ind = false
             let m_atdsrvorg = 4
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind
             if m_acesso_ind = false then
                call cts06g03( 1
                              ,m_atdsrvorg
                              ,w_cts26m00.ligcvntip
                              ,aux_today
                              ,aux_hora
                              ,a_cts26m00[1].lclidttxt
                              ,a_cts26m00[1].cidnom
                              ,a_cts26m00[1].ufdcod
                              ,a_cts26m00[1].brrnom
                              ,a_cts26m00[1].lclbrrnom
                              ,a_cts26m00[1].endzon
                              ,a_cts26m00[1].lgdtip
                              ,a_cts26m00[1].lgdnom
                              ,a_cts26m00[1].lgdnum
                              ,a_cts26m00[1].lgdcep
                              ,a_cts26m00[1].lgdcepcmp
                              ,a_cts26m00[1].lclltt
                              ,a_cts26m00[1].lcllgt
                              ,a_cts26m00[1].lclrefptotxt
                              ,a_cts26m00[1].lclcttnom
                              ,a_cts26m00[1].dddcod
                              ,a_cts26m00[1].lcltelnum
                              ,a_cts26m00[1].c24lclpdrcod
                              ,a_cts26m00[1].ofnnumdig
                              ,a_cts26m00[1].celteldddcod
                              ,a_cts26m00[1].celtelnum
                              ,a_cts26m00[1].endcmp
                              ,hist_cts26m00.*
                              ,a_cts26m00[1].emeviacod )
                   returning a_cts26m00[1].lclidttxt
                            ,a_cts26m00[1].cidnom
                            ,a_cts26m00[1].ufdcod
                            ,a_cts26m00[1].brrnom
                            ,a_cts26m00[1].lclbrrnom
                            ,a_cts26m00[1].endzon
                            ,a_cts26m00[1].lgdtip
                            ,a_cts26m00[1].lgdnom
                            ,a_cts26m00[1].lgdnum
                            ,a_cts26m00[1].lgdcep
                            ,a_cts26m00[1].lgdcepcmp
                            ,a_cts26m00[1].lclltt
                            ,a_cts26m00[1].lcllgt
                            ,a_cts26m00[1].lclrefptotxt
                            ,a_cts26m00[1].lclcttnom
                            ,a_cts26m00[1].dddcod
                            ,a_cts26m00[1].lcltelnum
                            ,a_cts26m00[1].c24lclpdrcod
                            ,a_cts26m00[1].ofnnumdig
                            ,a_cts26m00[1].celteldddcod
                            ,a_cts26m00[1].celtelnum
                            ,a_cts26m00[1].endcmp
                            ,ws.retflg
                            ,hist_cts26m00.*
                            ,a_cts26m00[1].emeviacod
             else
                call cts06g11( 1
                              ,m_atdsrvorg
                              ,w_cts26m00.ligcvntip
                              ,aux_today
                              ,aux_hora
                              ,a_cts26m00[1].lclidttxt
                              ,a_cts26m00[1].cidnom
                              ,a_cts26m00[1].ufdcod
                              ,a_cts26m00[1].brrnom
                              ,a_cts26m00[1].lclbrrnom
                              ,a_cts26m00[1].endzon
                              ,a_cts26m00[1].lgdtip
                              ,a_cts26m00[1].lgdnom
                              ,a_cts26m00[1].lgdnum
                              ,a_cts26m00[1].lgdcep
                              ,a_cts26m00[1].lgdcepcmp
                              ,a_cts26m00[1].lclltt
                              ,a_cts26m00[1].lcllgt
                              ,a_cts26m00[1].lclrefptotxt
                              ,a_cts26m00[1].lclcttnom
                              ,a_cts26m00[1].dddcod
                              ,a_cts26m00[1].lcltelnum
                              ,a_cts26m00[1].c24lclpdrcod
                              ,a_cts26m00[1].ofnnumdig
                              ,a_cts26m00[1].celteldddcod
                              ,a_cts26m00[1].celtelnum
                              ,a_cts26m00[1].endcmp
                              ,hist_cts26m00.*
                              ,a_cts26m00[1].emeviacod )
                   returning a_cts26m00[1].lclidttxt
                            ,a_cts26m00[1].cidnom
                            ,a_cts26m00[1].ufdcod
                            ,a_cts26m00[1].brrnom
                            ,a_cts26m00[1].lclbrrnom
                            ,a_cts26m00[1].endzon
                            ,a_cts26m00[1].lgdtip
                            ,a_cts26m00[1].lgdnom
                            ,a_cts26m00[1].lgdnum
                            ,a_cts26m00[1].lgdcep
                            ,a_cts26m00[1].lgdcepcmp
                            ,a_cts26m00[1].lclltt
                            ,a_cts26m00[1].lcllgt
                            ,a_cts26m00[1].lclrefptotxt
                            ,a_cts26m00[1].lclcttnom
                            ,a_cts26m00[1].dddcod
                            ,a_cts26m00[1].lcltelnum
                            ,a_cts26m00[1].c24lclpdrcod
                            ,a_cts26m00[1].ofnnumdig
                            ,a_cts26m00[1].celteldddcod
                            ,a_cts26m00[1].celtelnum
                            ,a_cts26m00[1].endcmp
                            ,ws.retflg
                            ,hist_cts26m00.*
                            ,a_cts26m00[1].emeviacod
             end if
             #------------------------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #------------------------------------------------------------------------------
             if g_documento.lclocodesres = "S" then
                let w_cts26m00.atdrsdflg = "S"
             else
                let w_cts26m00.atdrsdflg = "N"
             end if
             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts26m00[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts26m00[1].brrnom,
                                            a_cts26m00[1].lclbrrnom)
                  returning a_cts26m00[1].lclbrrnom

             let a_cts26m00[1].lgdtxt = a_cts26m00[1].lgdtip clipped, " ",
                                        a_cts26m00[1].lgdnom clipped, " ",
                                        a_cts26m00[1].lgdnum using "<<<<#"


             if a_cts26m00[1].cidnom is not null and
                a_cts26m00[1].ufdcod is not null then
                call cts14g00 (d_cts26m00.c24astcod,
                               "","","","",
                               a_cts26m00[1].cidnom,
                               a_cts26m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts26m00[1].lgdtxt
             display by name a_cts26m00[1].lclbrrnom
             display by name a_cts26m00[1].endzon
             display by name a_cts26m00[1].cidnom
             display by name a_cts26m00[1].ufdcod
             display by name a_cts26m00[1].lclrefptotxt
             display by name a_cts26m00[1].lclcttnom
             display by name a_cts26m00[1].dddcod
             display by name a_cts26m00[1].lcltelnum
             display by name a_cts26m00[1].celteldddcod
             display by name a_cts26m00[1].celtelnum
             display by name a_cts26m00[1].endcmp

             if ws.retflg = "N"  then
                error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field refatdsrvorg
             end if

             if g_documento.atdsrvnum is null  and
                g_documento.atdsrvano is null  then
                call cts08g01("Q","N","LOCAL ONDE VEICULO SE ENCONTRA",
                                      "E' DE DIFICIL ACESSO ?",
                                      "GARAGEM, SUBSOLO, ESTACIONAMENTO",
                                      "REGISTRE INFORMACAO NO HISTORICO")
                     returning ws.confirma
             end if
          end if

   before field sindat
          display by name d_cts26m00.sindat attribute (reverse)

   after  field sindat
          display by name d_cts26m00.sindat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if g_documento.atdsrvnum is null  and
                g_documento.atdsrvano is null  and
                d_cts26m00.c24astcod = "G13"   then
                next field refatdsrvorg
             else
                next field camflg
             end if
          else
             if d_cts26m00.sindat is null  then
                error " Data do sinistro deve ser informada!"
                next field sindat
             end if

             if d_cts26m00.sindat < l_data - 366 units day  then
                call cts08g01("A","N","","DATA DO SINISTRO INFORMADA E'","ANTERIOR A  1 (UM) ANO !","") returning ws.confirma
                next field sindat
             end if

             if d_cts26m00.sindat > l_data   then
                error " Data do sinistro nao deve ser maior que hoje!"
                next field sindat
             end if
          end if

   before field sinhor
          display by name d_cts26m00.sinhor attribute (reverse)

   after  field sinhor
          display by name d_cts26m00.sinhor

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts26m00.sinhor is null  then
                error " Hora do sinistro deve ser informada!"
                next field sinhor
             end if

             if d_cts26m00.sindat =  l_data    and
                d_cts26m00.sinhor <> "00:00"   and
                d_cts26m00.sinhor >  aux_hora  then
                error " Hora do sinistro nao deve ser maior que hora atual!"
                next field sinhor
             end if
          end if

   #before field roddantxt
   #       display by name d_cts26m00.roddantxt attribute (reverse)

   #after  field roddantxt
   #       display by name d_cts26m00.roddantxt
#
#          if fgl_lastkey() <> fgl_keyval("up")   and
#             fgl_lastkey() <> fgl_keyval("left") then
#             if d_cts26m00.roddantxt is null     or
#                d_cts26m00.roddantxt =  " "      then
#                error " Se rodas foram danificadas deve ser informado!"
#                next field roddantxt
#             end if
#          end if
#
   before field sinvitflg
          display by name d_cts26m00.sinvitflg attribute (reverse)

   after  field sinvitflg
          display by name d_cts26m00.sinvitflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.sinvitflg is null     then
                error " Informe se ha' ou nao vitimas!"
                next field sinvitflg
             end if

             if d_cts26m00.sinvitflg <> "S"      and
                d_cts26m00.sinvitflg <> "N"      then
                error " Ha' vitimas: (S)im ou (N)ao!"
                next field sinvitflg
             end if
          end if

   before field bocflg
          display by name d_cts26m00.bocflg attribute (reverse)

   after  field bocflg
          display by name d_cts26m00.bocflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.bocflg is null        then
                error " Dados sobre boletim de ocorrencia devem ser informados!"
                next field bocflg
             end if

             if d_cts26m00.bocflg <> "S"         and
                d_cts26m00.bocflg <> "N"         and
                d_cts26m00.bocflg <> "P"         then
                error " Fez B.O.?: (S)im ou (N)ao, (P)esquisa delegacias!"
                next field bocflg
             end if

             if d_cts26m00.bocflg =  "P"         then
                error " Pesquisa Distrito Policial/Batalhoes via CEP!"

                call ctn00c02("SP","SAO PAULO"," "," ")
                     returning ws.endcep, ws.endcepcmp

                if ws.endcep is null then
                   error " Nenhum cep foi selecionado!"
                else
                   call ctn03c01(ws.endcep)
                end if

                next field bocflg
             end if

             if d_cts26m00.bocflg = "S"  then
                call cts26m02(w_cts26m00.bocnum, w_cts26m00.bocemi, w_cts26m00.vcllibflg)
                    returning w_cts26m00.bocnum, w_cts26m00.bocemi, w_cts26m00.vcllibflg
             else
                initialize w_cts26m00.bocnum    to null
                initialize w_cts26m00.bocemi    to null
                initialize w_cts26m00.vcllibflg to null
             end if
          end if

   before field asitipcod
          display by name d_cts26m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts26m00.asitipcod

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts26m00.asitipcod is null  then
                call ctn25c00(15) returning d_cts26m00.asitipcod

                if d_cts26m00.asitipcod is not null  then
                   select asitipabvdes, asiofndigflg
                     into d_cts26m00.asitipabvdes
                         ,w_cts26m00.asiofndigflg
                     from datkasitip
                    where asitipcod = d_cts26m00.asitipcod  and
                          asitipstt = "A"

                   display by name d_cts26m00.asitipcod
                   display by name d_cts26m00.asitipabvdes

                   if d_cts26m00.asitipcod = 1 and        #OSF 19968
                      w_cts26m00.asiofndigflg = "S" then
                      let d_cts26m00.dstflg = "S"
                      display by name d_cts26m00.dstflg
                   end if
                else
                   next field asitipcod
                end if
             else
                select asitipabvdes, asiofndigflg
                  into d_cts26m00.asitipabvdes
                      ,w_cts26m00.asiofndigflg
                  from datkasitip
                 where asitipcod = d_cts26m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   call ctn25c00(15) returning d_cts26m00.asitipcod
                   next field asitipcod
                else
                   display by name d_cts26m00.asitipcod
                end if

                if d_cts26m00.asitipcod = 1 and        #OSF 19968
                   w_cts26m00.asiofndigflg = "S" then
                   let d_cts26m00.dstflg = "S"
                   display by name d_cts26m00.dstflg
                end if

                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = g_documento.atdsrvorg
                   and asitipcod = d_cts26m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada para este servico!"
                   next field asitipcod
                end if
             end if

             display by name d_cts26m00.asitipabvdes
          end if

   before field dstflg
          display by name d_cts26m00.dstflg attribute (reverse)


   after  field dstflg
          display by name d_cts26m00.dstflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.dstflg is null    then
                error " Local de destino deve ser informado!"
                next field dstflg
             end if

             if d_cts26m00.dstflg <> "S"     and
                d_cts26m00.dstflg <> "N"     then
                error " Existe destino: (S)im ou (N)ao!"
                next field dstflg
             end if

             initialize w_hist.* to null
             if d_cts26m00.dstflg = "S"  then
                let a_cts26m00[3].* = a_cts26m00[2].*
                let a_cts26m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                let m_acesso_ind = false
                let m_atdsrvorg = 4
                call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                     returning m_acesso_ind
                if m_acesso_ind = false then
                   call cts06g03( 2
                                 ,m_atdsrvorg
                                 ,w_cts26m00.ligcvntip
                                 ,aux_today
                                 ,aux_hora
                                 ,a_cts26m00[2].lclidttxt
                                 ,a_cts26m00[2].cidnom
                                 ,a_cts26m00[2].ufdcod
                                 ,a_cts26m00[2].brrnom
                                 ,a_cts26m00[2].lclbrrnom
                                 ,a_cts26m00[2].endzon
                                 ,a_cts26m00[2].lgdtip
                                 ,a_cts26m00[2].lgdnom
                                 ,a_cts26m00[2].lgdnum
                                 ,a_cts26m00[2].lgdcep
                                 ,a_cts26m00[2].lgdcepcmp
                                 ,a_cts26m00[2].lclltt
                                 ,a_cts26m00[2].lcllgt
                                 ,a_cts26m00[2].lclrefptotxt
                                 ,a_cts26m00[2].lclcttnom
                                 ,a_cts26m00[2].dddcod
                                 ,a_cts26m00[2].lcltelnum
                                 ,a_cts26m00[2].c24lclpdrcod
                                 ,a_cts26m00[2].ofnnumdig
                                 ,a_cts26m00[2].celteldddcod
                                 ,a_cts26m00[2].celtelnum
                                 ,a_cts26m00[2].endcmp
                                 ,hist_cts26m00.*
                                 ,a_cts26m00[2].emeviacod )
                      returning a_cts26m00[2].lclidttxt
                               ,a_cts26m00[2].cidnom
                               ,a_cts26m00[2].ufdcod
                               ,a_cts26m00[2].brrnom
                               ,a_cts26m00[2].lclbrrnom
                               ,a_cts26m00[2].endzon
                               ,a_cts26m00[2].lgdtip
                               ,a_cts26m00[2].lgdnom
                               ,a_cts26m00[2].lgdnum
                               ,a_cts26m00[2].lgdcep
                               ,a_cts26m00[2].lgdcepcmp
                               ,a_cts26m00[2].lclltt
                               ,a_cts26m00[2].lcllgt
                               ,a_cts26m00[2].lclrefptotxt
                               ,a_cts26m00[2].lclcttnom
                               ,a_cts26m00[2].dddcod
                               ,a_cts26m00[2].lcltelnum
                               ,a_cts26m00[2].c24lclpdrcod
                               ,a_cts26m00[2].ofnnumdig
                               ,a_cts26m00[2].celteldddcod
                               ,a_cts26m00[2].celtelnum
                               ,a_cts26m00[2].endcmp
                               ,ws.retflg
                               ,hist_cts26m00.*
                               ,a_cts26m00[2].emeviacod
                else
                   call cts06g11( 2
                                 ,m_atdsrvorg
                                 ,w_cts26m00.ligcvntip
                                 ,aux_today
                                 ,aux_hora
                                 ,a_cts26m00[2].lclidttxt
                                 ,a_cts26m00[2].cidnom
                                 ,a_cts26m00[2].ufdcod
                                 ,a_cts26m00[2].brrnom
                                 ,a_cts26m00[2].lclbrrnom
                                 ,a_cts26m00[2].endzon
                                 ,a_cts26m00[2].lgdtip
                                 ,a_cts26m00[2].lgdnom
                                 ,a_cts26m00[2].lgdnum
                                 ,a_cts26m00[2].lgdcep
                                 ,a_cts26m00[2].lgdcepcmp
                                 ,a_cts26m00[2].lclltt
                                 ,a_cts26m00[2].lcllgt
                                 ,a_cts26m00[2].lclrefptotxt
                                 ,a_cts26m00[2].lclcttnom
                                 ,a_cts26m00[2].dddcod
                                 ,a_cts26m00[2].lcltelnum
                                 ,a_cts26m00[2].c24lclpdrcod
                                 ,a_cts26m00[2].ofnnumdig
                                 ,a_cts26m00[2].celteldddcod
                                 ,a_cts26m00[2].celtelnum
                                 ,a_cts26m00[2].endcmp
                                 ,hist_cts26m00.*
                                 ,a_cts26m00[2].emeviacod )
                      returning a_cts26m00[2].lclidttxt
                               ,a_cts26m00[2].cidnom
                               ,a_cts26m00[2].ufdcod
                               ,a_cts26m00[2].brrnom
                               ,a_cts26m00[2].lclbrrnom
                               ,a_cts26m00[2].endzon
                               ,a_cts26m00[2].lgdtip
                               ,a_cts26m00[2].lgdnom
                               ,a_cts26m00[2].lgdnum
                               ,a_cts26m00[2].lgdcep
                               ,a_cts26m00[2].lgdcepcmp
                               ,a_cts26m00[2].lclltt
                               ,a_cts26m00[2].lcllgt
                               ,a_cts26m00[2].lclrefptotxt
                               ,a_cts26m00[2].lclcttnom
                               ,a_cts26m00[2].dddcod
                               ,a_cts26m00[2].lcltelnum
                               ,a_cts26m00[2].c24lclpdrcod
                               ,a_cts26m00[2].ofnnumdig
                               ,a_cts26m00[2].celteldddcod
                               ,a_cts26m00[2].celtelnum
                               ,a_cts26m00[2].endcmp
                               ,ws.retflg
                               ,hist_cts26m00.*
                               ,a_cts26m00[2].emeviacod
                end if
                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_subbairro[2].lclbrrnom = a_cts26m00[2].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts26m00[2].brrnom,
                                               a_cts26m00[2].lclbrrnom)
                     returning a_cts26m00[2].lclbrrnom

                let a_cts26m00[2].lgdtxt = a_cts26m00[2].lgdtip clipped, " ",
                                           a_cts26m00[2].lgdnom clipped, " ",
                                           a_cts26m00[2].lgdnum using "<<<<#"

                if a_cts26m00[2].lclltt <> a_cts26m00[3].lclltt or
                   a_cts26m00[2].lcllgt <> a_cts26m00[3].lcllgt or
                   (a_cts26m00[3].lclltt is null and a_cts26m00[2].lclltt is not null) or
                   (a_cts26m00[3].lcllgt is null and a_cts26m00[2].lcllgt is not null) then

                      call cts00m33(1,
                                    a_cts26m00[1].lclltt,
                                    a_cts26m00[1].lcllgt,
                                    a_cts26m00[2].lclltt,
                                    a_cts26m00[2].lcllgt)
                end if

                if a_cts26m00[2].cidnom is not null and
                   a_cts26m00[2].ufdcod is not null then
                   call cts14g00 (d_cts26m00.c24astcod,
                                  "","","","",
                                  a_cts26m00[2].cidnom,
                                  a_cts26m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if

                if ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos ou nao preenchidos!"
                   next field dstflg
                end if

                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then
                   let a_cts26m00[2].operacao = "I"
                else
                   select c24lclpdrcod
                     from datmlcl
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano  and
                          c24endtip = 2

                   if sqlca.sqlcode = notfound  then
                      let a_cts26m00[2].operacao = "I"
                   else
                      let a_cts26m00[2].operacao = "M"
                   end if
                end if
                if a_cts26m00[2].ofnnumdig is not null then
                   select ofnstt
                       into ws.ofnstt
                       from sgokofi
                      where ofnnumdig = a_cts26m00[2].ofnnumdig
                   if ws.ofnstt = "C" then
                      # digita o motivo
                      let w_hist.hist1 = "OF CORT MOTIVO:"
                      call cts10m02 (w_hist.*) returning w_hist.*
                   end if
                end if
             else
                if d_cts26m00.asitipcod    = 1   and
                   w_cts26m00.asiofndigflg = "S" then
                   error "Destino e Obrigatorio"
                   next field dstflg
                end if
                initialize a_cts26m00[2].*  to null
                let a_cts26m00[2].operacao = "D"
             end if
          end if

   before field rmcacpflg
          display by name d_cts26m00.rmcacpflg attribute (reverse)

   after  field rmcacpflg
          display by name d_cts26m00.rmcacpflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.rmcacpflg  is null   then
                error " Acompanha remocao deve ser informado!"
                next field rmcacpflg
             end if

             if d_cts26m00.rmcacpflg <> "S"      and
                d_cts26m00.rmcacpflg <> "N"      then
                error " Acompanha remocao invalida!"
                next field rmcacpflg
             end if
          end if

   before field imdsrvflg
          display by name d_cts26m00.imdsrvflg attribute (reverse)

   after  field imdsrvflg
          display by name d_cts26m00.imdsrvflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.imdsrvflg is null   or
                d_cts26m00.imdsrvflg =  " "    then
                error " Informacoes sobre servico imediato deve ser informado!"
                next field imdsrvflg
             end if

             if d_cts26m00.imdsrvflg <> "S"    and
                d_cts26m00.imdsrvflg <> "N"    then
                error " Servico imediato: (S)im ou (N)ao!"
                next field imdsrvflg
             end if

             call cts26m03(w_cts26m00.atdfnlflg,
                           d_cts26m00.imdsrvflg,
                           w_cts26m00.atdhorpvt,
                           w_cts26m00.atddatprg,
                           w_cts26m00.atdhorprg,
                           w_cts26m00.atdpvtretflg)
                 returning w_cts26m00.atdhorpvt,
                           w_cts26m00.atddatprg,
                           w_cts26m00.atdhorprg,
                           w_cts26m00.atdpvtretflg

             if d_cts26m00.imdsrvflg = "S"     then
                if w_cts26m00.atdhorpvt is null        then
                   error " Previsao de horas nao informada para servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts26m00.atddatprg   is null        or
                   w_cts26m00.atddatprg        = " "     or
                   w_cts26m00.atdhorprg   is null        then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts26m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts26m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts26m00.atdprinvlcod

                    display by name d_cts26m00.atdprinvlcod
                    display by name d_cts26m00.atdprinvldes

                    next field prslocflg

                end if
             end if
          end if

   before field atdprinvlcod
          display by name d_cts26m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts26m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts26m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts26m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts26m00.atdprinvldes

          else
             next field imdsrvflg
          end if

   before field prslocflg
          if g_documento.atdsrvnum  is not null   or
             g_documento.atdsrvano  is not null   then
             initialize d_cts26m00.prslocflg  to null
             next field atdlibflg
          end if

          if d_cts26m00.imdsrvflg   = "N"         then
             initialize w_cts26m00.c24nomctt  to null
             let d_cts26m00.prslocflg = "N"
             display by name d_cts26m00.prslocflg
             next field atdlibflg
          end if

          display by name d_cts26m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts26m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if ((d_cts26m00.prslocflg  is null)  or
              (d_cts26m00.prslocflg  <> "S"    and
             d_cts26m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts26m00.prslocflg = "S"   then
             call ctn24c01()
                  returning w_cts26m00.atdprscod, w_cts26m00.srrcoddig,
                            w_cts26m00.atdvclsgl, w_cts26m00.socvclcod

             if w_cts26m00.atdprscod  is null then
                error " Faltam dados para prestador no local!"
                next field prslocflg
             end if

             call cts40g03_data_hora_banco(2)
                returning l_data, l_hora2
             let d_cts26m00.atdlibhor = w_cts26m00.hora
             let d_cts26m00.atdlibdat = w_cts26m00.data
             let w_cts26m00.cnldat    = l_data
             let w_cts26m00.atdfnlhor = l_hora2
             let w_cts26m00.c24opemat = g_issk.funmat
             let w_cts26m00.atdfnlflg = "S"
             let w_cts26m00.atdetpcod =  4
          else
             initialize w_cts26m00.funmat   ,
                        w_cts26m00.cnldat   ,
                        w_cts26m00.atdfnlhor,
                        w_cts26m00.c24opemat,
                        w_cts26m00.atdfnlflg,
                        w_cts26m00.atdetpcod,
                        w_cts26m00.atdprscod,
                        w_cts26m00.c24nomctt  to null
          end if


   before field atdlibflg
          display by name d_cts26m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts26m00.atdfnlflg   = "S"       then
             exit input
          end if

          if d_cts26m00.atdlibflg is null  and
             g_documento.c24soltipcod = 1  then   # Tipo solic = Segurado
           # call cts09g00(g_documento.ramcod   ,   # psi 141003
           #               g_documento.succod   ,
           #               g_documento.aplnumdig,
           #               g_documento.itmnumdig,
           #               true)
           #     returning ws.dddcod, ws.teltxt
          end if

   after  field atdlibflg
          display by name d_cts26m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts26m00.atdlibflg <> "S"  and
                d_cts26m00.atdlibflg <> "N"  then
                error " Envio liberado invalido!"
                next field atdlibflg
             end if

             if d_cts26m00.atdlibflg = "N"  and
                d_cts26m00.prslocflg = "S"  then
                error " Servico com prestador no local deve ser liberado!"
                next field atdlibflg
             end if

             call cts26m06() returning w_cts26m00.atdlibflg
             if w_cts26m00.atdlibflg  is null   then
                next field atdlibflg
             end if

             let d_cts26m00.atdlibflg = w_cts26m00.atdlibflg
             display by name d_cts26m00.atdlibflg

             if aux_libant is null  then
                if w_cts26m00.atdlibflg  =  "S"  then
                   call cts40g03_data_hora_banco(2)
                      returning l_data, l_hora2
                   let aux_libhor           = l_hora2
                   let d_cts26m00.atdlibhor = aux_libhor
                   let d_cts26m00.atdlibdat = l_data
                else
                   let d_cts26m00.atdlibflg = "N"
                   display by name d_cts26m00.atdlibflg
                   initialize d_cts26m00.atdlibhor to null
                   initialize d_cts26m00.atdlibdat to null
                end if
             else
                select atdfnlflg
                  from datmservico
                 where atdsrvnum = g_documento.atdsrvnum  and
                       atdsrvano = g_documento.atdsrvano  and
                       atdfnlflg = "N"

                if sqlca.sqlcode = notfound  then
                   error " Servico ja' concluido nao pode ser alterado!"
                   call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                     " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                        "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                        returning ws.confirma
                   next field atdlibflg
                end if

                if aux_libant = "S"   then
                   if w_cts26m00.atdlibflg = "S" then
                      next field frmflg
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts26m00.atdlibflg = "N"
                      display by name d_cts26m00.atdlibflg
                      initialize d_cts26m00.atdlibhor to null
                      initialize d_cts26m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      next field frmflg
                   end if
                else
                   if aux_libant = "N"   then
                      if w_cts26m00.atdlibflg = "N" then
                         next field frmflg
                      else
                         call cts40g03_data_hora_banco(2)
                           returning l_data, l_hora2
                         let aux_libhor           = l_hora2
                         let d_cts26m00.atdlibhor = aux_libhor
                         let d_cts26m00.atdlibdat = l_data
                         next field frmflg
                      end if
                   end if
                end if
             end if
          else
             next field atdprinvlcod
          end if

   before field frmflg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             let d_cts26m00.frmflg = "N"
             display by name d_cts26m00.frmflg attribute (reverse)
          else
             if w_cts26m00.atdfnlflg = "S"  then
                call cts11g00(w_cts26m00.lignum)
                let int_flag = true
             end if

             exit input
          end if

   after  field frmflg
          display by name d_cts26m00.frmflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m00.frmflg = "S" then
                if d_cts26m00.atdlibflg = "N"  then
                   error " Nao e' possivel registrar servico nao liberado via formulario!"
                   next field atdlibflg
                end if

                call cts26m05(4) returning w_cts26m00.data     ,
                                           w_cts26m00.hora     ,
                                           w_cts26m00.funmat   ,
                                           w_cts26m00.cnldat   ,
                                           w_cts26m00.atdfnlhor,
                                           w_cts26m00.c24opemat,
                                           w_cts26m00.atdprscod

                if w_cts26m00.hora      is null  or
                   w_cts26m00.data      is null  or
                   w_cts26m00.funmat    is null  or
                   w_cts26m00.cnldat    is null  or
                   w_cts26m00.atdfnlhor is null  or
                   w_cts26m00.c24opemat is null  or
                   w_cts26m00.atdprscod is null  then
                   error " Faltam dados para entrada via formulario!"
                   next field frmflg
                end if

                let d_cts26m00.atdlibhor = w_cts26m00.hora
                let d_cts26m00.atdlibdat = w_cts26m00.data
                let w_cts26m00.atdfnlflg = "S"
                let w_cts26m00.atdetpcod =  4
             else
                if d_cts26m00.prslocflg = "N"   then
                   initialize w_cts26m00.hora     ,
                              w_cts26m00.data     ,
                              w_cts26m00.funmat   ,
                              w_cts26m00.cnldat   ,
                              w_cts26m00.atdfnlhor,
                              w_cts26m00.c24opemat,
                              w_cts26m00.atdfnlflg,
                              w_cts26m00.atdetpcod,
                              w_cts26m00.atdprscod to null
                end if
             end if
          end if

   on key (interrupt)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
              returning ws.confirma

         if ws.confirma  =  "S"   then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if d_cts26m00.c24astcod is not null then
         call ctc58m00_vis(d_cts26m00.c24astcod)
      end if

   on key (F2)
      ###################################################
      # Checa se existe tela de servico remocao ja aberta
      ###################################################
      # 16400-3  Henrique 08/01/2003

     #select refatdsrvnum,
     #       refatdsrvano
     #  into ws.refatdsrvnum,
     #       ws.refatdsrvano
     #  from datmsrvjit
     # where atdsrvnum = g_documento.atdsrvnum
     #   and atdsrvano = g_documento.atdsrvano

     #if sqlca.sqlcode = 0 then

     #   let ws.auxatdsrvnum = g_documento.atdsrvnum
     #   let ws.auxatdsrvano = g_documento.atdsrvano
     #   let ws.auxatdsrvorg = g_documento.atdsrvorg

#    #   let g_documento.atdsrvnum = ws.refatdsrvnum
#    #   let g_documento.atdsrvano = ws.refatdsrvano

     #end if

     #let aux_ano4 = "20" clipped, ws.refatdsrvano using "&&"

     #select * from datmpedvist
     # where sinvstnum = ws.refatdsrvnum
     #   and sinvstano = aux_ano4

     #if sqlca.sqlcode = 0 then
     #   call cts21m03(ws.refatdsrvnum, aux_ano4)
     #else
     #   whenever error continue
     #      open window cts02m00 at 04,02 with form "cts02m00"
     #                          attribute(form line 1)
     #      if status = 0     then
     #         let erros_chk = "N"
     #         close window cts02m00
     #      else
     #         let erros_chk = "S"
     #      end if
     #   whenever error stop
  #
     #   if erros_chk = "N"  then
     #      call cts04g00('cts26m00') returning ws.retflg
     #   end if

     #end if
     #let g_documento.atdsrvnum = ws.auxatdsrvnum
     #let g_documento.atdsrvano = ws.auxatdsrvano
     #let g_documento.atdsrvorg = ws.auxatdsrvorg

      whenever error continue
         open window cts02m00 at 04,02 with form "cts02m00"
                             attribute(form line 1)
         if status = 0     then
            let erros_chk = "N"
            close window cts02m00
         else
            let erros_chk = "S"
         end if
      whenever error stop

      if erros_chk = "N"  then

         select refatdsrvnum,
                refatdsrvano
           into ws.refatdsrvnum,
                ws.refatdsrvano
           from datmsrvjit
          where atdsrvnum = g_documento.atdsrvnum
            and atdsrvano = g_documento.atdsrvano

         if sqlca.sqlcode = 0 then

            let ws.auxatdsrvnum = g_documento.atdsrvnum
            let ws.auxatdsrvano = g_documento.atdsrvano
            let ws.auxatdsrvorg = g_documento.atdsrvorg

            let g_documento.atdsrvnum = ws.refatdsrvnum
            let g_documento.atdsrvano = ws.refatdsrvano

            call cts04g00('cts26m00') returning ws.retflg

            let g_documento.atdsrvnum = ws.auxatdsrvnum
            let g_documento.atdsrvano = ws.auxatdsrvano
            let g_documento.atdsrvorg = ws.auxatdsrvorg

         end if
      end if

   on key (F5)
{
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         if g_documento.ramcod = 31  or
            g_documento.ramcod = 531 then
            call cta01m00()
         else
            call cta01m20()
         end if
      else
         if g_documento.prporg    is not null  and
            g_documento.prpnumdig is not null  then
            call opacc149(g_documento.prporg, g_documento.prpnumdig) returning ws.prpflg
         else
            if g_documento.pcacarnum is not null  and
               g_documento.pcaprpitm is not null  then
               call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
            else
               error " Espelho so' com documento localizado!"
            end if
         end if
      end if
}
       let g_monitor.horaini = current ## Flexvision
       call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

   on key (F6)
      if g_documento.atdsrvnum is null  then
         call cts10m02 (hist_cts26m00.*) returning hist_cts26m00.*
#        error " Acesso ao historico somente c/ cadastramento do servico!"
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat        , aux_today  ,aux_hora)
      end if

   on key (F7)
      call ctx14g00("Funcoes","Impressao|Condutor|Caminhao|Distancia")
           returning ws.opcao,
                     ws.opcaodes
      case ws.opcao
         when 1  ### Impressao
            if g_documento.atdsrvnum is null  then
               error " Impressao somente com cadastramento do servico!"
            else
               call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
            end if
         when 2  ### Condutor
            if g_documento.succod    is not null  and
               g_documento.ramcod    is not null  and
               g_documento.aplnumdig is not null  then
               select clscod
                from abbmclaus
                where succod    = g_documento.succod  and
                      aplnumdig = g_documento.aplnumdig and
                      itmnumdig = g_documento.itmnumdig and
                      dctnumseq = g_funapol.dctnumseq and
                      clscod    = "018"
               if sqlca.sqlcode  = 0  then
                  if g_documento.atdsrvnum is null  or
                     g_documento.atdsrvano is null  then
                     if g_documento.cndslcflg = "S"  then
                        call cta07m00(g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig, "I")
                     else
                        call cta07m00(g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig, "C")
                     end if
                  else
                     call cta07m00(g_documento.succod,
                                   g_documento.aplnumdig,
                                   g_documento.itmnumdig, "C")
                  end if
               else
                   error "Docto nao possui clausula 18 !"
               end if
            else
               error "Condutor so' com Documento localizado!"
            end if

         when 3  ### Caminhao
             if d_cts26m00.camflg = "S"  then
                call cts26m01(w_cts26m00.ctgtrfcod,
                              g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              w_cts26m00.vclcrgflg, w_cts26m00.vclcrgpso,
                              w_cts26m00.vclcamtip, w_cts26m00.vclcrcdsc)
                    returning w_cts26m00.vclcrgflg, w_cts26m00.vclcrgpso,
                              w_cts26m00.vclcamtip, w_cts26m00.vclcrcdsc
             end if

         when 4   #### Distancia QTH-QTI
            call cts00m33(1,
                          a_cts26m00[1].lclltt,
                          a_cts26m00[1].lcllgt,
                          a_cts26m00[2].lclltt,
                          a_cts26m00[2].lcllgt)

      end case

   on key (F8)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts26m00.dstflg = "N"  then
            error " Nao foi informado destino para este servico!"
         else
            let a_cts26m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
            let m_acesso_ind = false
             let m_atdsrvorg = 4
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind
             if m_acesso_ind = false then
                call cts06g03( 2
                              ,m_atdsrvorg
                              ,w_cts26m00.ligcvntip
                              ,aux_today
                              ,aux_hora
                              ,a_cts26m00[2].lclidttxt
                              ,a_cts26m00[2].cidnom
                              ,a_cts26m00[2].ufdcod
                              ,a_cts26m00[2].brrnom
                              ,a_cts26m00[2].lclbrrnom
                              ,a_cts26m00[2].endzon
                              ,a_cts26m00[2].lgdtip
                              ,a_cts26m00[2].lgdnom
                              ,a_cts26m00[2].lgdnum
                              ,a_cts26m00[2].lgdcep
                              ,a_cts26m00[2].lgdcepcmp
                              ,a_cts26m00[2].lclltt
                              ,a_cts26m00[2].lcllgt
                              ,a_cts26m00[2].lclrefptotxt
                              ,a_cts26m00[2].lclcttnom
                              ,a_cts26m00[2].dddcod
                              ,a_cts26m00[2].lcltelnum
                              ,a_cts26m00[2].c24lclpdrcod
                              ,a_cts26m00[2].ofnnumdig
                              ,a_cts26m00[2].celteldddcod
                              ,a_cts26m00[2].celtelnum
                              ,a_cts26m00[2].endcmp
                              ,hist_cts26m00.*
                              ,a_cts26m00[2].emeviacod )
                   returning a_cts26m00[2].lclidttxt
                            ,a_cts26m00[2].cidnom
                            ,a_cts26m00[2].ufdcod
                            ,a_cts26m00[2].brrnom
                            ,a_cts26m00[2].lclbrrnom
                            ,a_cts26m00[2].endzon
                            ,a_cts26m00[2].lgdtip
                            ,a_cts26m00[2].lgdnom
                            ,a_cts26m00[2].lgdnum
                            ,a_cts26m00[2].lgdcep
                            ,a_cts26m00[2].lgdcepcmp
                            ,a_cts26m00[2].lclltt
                            ,a_cts26m00[2].lcllgt
                            ,a_cts26m00[2].lclrefptotxt
                            ,a_cts26m00[2].lclcttnom
                            ,a_cts26m00[2].dddcod
                            ,a_cts26m00[2].lcltelnum
                            ,a_cts26m00[2].c24lclpdrcod
                            ,a_cts26m00[2].ofnnumdig
                            ,a_cts26m00[2].celteldddcod
                            ,a_cts26m00[2].celtelnum
                            ,a_cts26m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts26m00.*
                            ,a_cts26m00[2].emeviacod

             else
                call cts06g11( 2
                              ,m_atdsrvorg
                              ,w_cts26m00.ligcvntip
                              ,aux_today
                              ,aux_hora
                              ,a_cts26m00[2].lclidttxt
                              ,a_cts26m00[2].cidnom
                              ,a_cts26m00[2].ufdcod
                              ,a_cts26m00[2].brrnom
                              ,a_cts26m00[2].lclbrrnom
                              ,a_cts26m00[2].endzon
                              ,a_cts26m00[2].lgdtip
                              ,a_cts26m00[2].lgdnom
                              ,a_cts26m00[2].lgdnum
                              ,a_cts26m00[2].lgdcep
                              ,a_cts26m00[2].lgdcepcmp
                              ,a_cts26m00[2].lclltt
                              ,a_cts26m00[2].lcllgt
                              ,a_cts26m00[2].lclrefptotxt
                              ,a_cts26m00[2].lclcttnom
                              ,a_cts26m00[2].dddcod
                              ,a_cts26m00[2].lcltelnum
                              ,a_cts26m00[2].c24lclpdrcod
                              ,a_cts26m00[2].ofnnumdig
                              ,a_cts26m00[2].celteldddcod
                              ,a_cts26m00[2].celtelnum
                              ,a_cts26m00[2].endcmp
                              ,hist_cts26m00.*
                              ,a_cts26m00[2].emeviacod )
                   returning a_cts26m00[2].lclidttxt
                            ,a_cts26m00[2].cidnom
                            ,a_cts26m00[2].ufdcod
                            ,a_cts26m00[2].brrnom
                            ,a_cts26m00[2].lclbrrnom
                            ,a_cts26m00[2].endzon
                            ,a_cts26m00[2].lgdtip
                            ,a_cts26m00[2].lgdnom
                            ,a_cts26m00[2].lgdnum
                            ,a_cts26m00[2].lgdcep
                            ,a_cts26m00[2].lgdcepcmp
                            ,a_cts26m00[2].lclltt
                            ,a_cts26m00[2].lcllgt
                            ,a_cts26m00[2].lclrefptotxt
                            ,a_cts26m00[2].lclcttnom
                            ,a_cts26m00[2].dddcod
                            ,a_cts26m00[2].lcltelnum
                            ,a_cts26m00[2].c24lclpdrcod
                            ,a_cts26m00[2].ofnnumdig
                            ,a_cts26m00[2].celteldddcod
                            ,a_cts26m00[2].celtelnum
                            ,a_cts26m00[2].endcmp
                            ,ws.retflg
                            ,hist_cts26m00.*
                            ,a_cts26m00[2].emeviacod
             end if
            if a_cts26m00[2].cidnom is not null and
               a_cts26m00[2].ufdcod is not null then
               call cts14g00 (d_cts26m00.c24astcod,
                              "","","","",
                              a_cts26m00[2].cidnom,
                              a_cts26m00[2].ufdcod,
                              "S",
                              ws.dtparam)
            end if
         end if
      end if

   on key (F9)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         if cpl_atdsrvnum is not null  or
            cpl_atdsrvano is not null  then
            error " Servico ja' selecionado para copia!"
         else
            call cts16g00 (g_documento.succod   ,
                           g_documento.ramcod   ,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig,
                           4                    ,  # atdsrvorg (REMOCAO)
                           d_cts26m00.vcllicnum ,
                           7, ""                )  # nr dias p/pesquisa
                 returning cpl_atdsrvnum, cpl_atdsrvano, cpl_atdsrvorg

            if cpl_atdsrvorg <> 1 and
               cpl_atdsrvorg <> 2 and
               cpl_atdsrvorg <> 4 and
               cpl_atdsrvorg <> 6 then
               initialize cpl_atdsrvnum, cpl_atdsrvano to null
            end if

            #------------------------------------------------------------
            # Informacoes do local da ocorrencia
            #------------------------------------------------------------
            if cpl_atdsrvnum is not null or
               cpl_atdsrvano is not null then

               call ctx04g00_local_gps(cpl_atdsrvnum,
                                       cpl_atdsrvano,
                                       1)
                  returning a_cts26m00[1].lclidttxt
                           ,a_cts26m00[1].lgdtip
                           ,a_cts26m00[1].lgdnom
                           ,a_cts26m00[1].lgdnum
                           ,a_cts26m00[1].lclbrrnom
                           ,a_cts26m00[1].brrnom
                           ,a_cts26m00[1].cidnom
                           ,a_cts26m00[1].ufdcod
                           ,a_cts26m00[1].lclrefptotxt
                           ,a_cts26m00[1].endzon
                           ,a_cts26m00[1].lgdcep
                           ,a_cts26m00[1].lgdcepcmp
                           ,a_cts26m00[1].lclltt
                           ,a_cts26m00[1].lcllgt
                           ,a_cts26m00[1].dddcod
                           ,a_cts26m00[1].lcltelnum
                           ,a_cts26m00[1].lclcttnom
                           ,a_cts26m00[1].c24lclpdrcod
                           ,a_cts26m00[1].celteldddcod
                           ,a_cts26m00[1].celtelnum
                           ,a_cts26m00[1].endcmp
                           ,ws.codigosql
                           ,a_cts26m00[1].emeviacod

               if ws.codigosql <> 0  then
                  error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
                  prompt "" for char prompt_key
                  initialize hist_cts26m00.*  to null
                  return hist_cts26m00.*
               end if

               select ofnnumdig into a_cts26m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = g_documento.atdsrvano
                  and atdsrvnum = g_documento.atdsrvnum
                  and c24endtip = 1

               let a_cts26m00[1].lgdtxt = a_cts26m00[1].lgdtip clipped, " ",
                                          a_cts26m00[1].lgdnom clipped, " ",
                                          a_cts26m00[1].lgdnum using "<<<<#"

               #-----------------------------------------------------------
               # Informacoes do local de destino
               #-----------------------------------------------------------
               call ctx04g00_local_gps( cpl_atdsrvnum,
                                        cpl_atdsrvano,
                                        2 )
                  returning a_cts26m00[2].lclidttxt
                           ,a_cts26m00[2].lgdtip
                           ,a_cts26m00[2].lgdnom
                           ,a_cts26m00[2].lgdnum
                           ,a_cts26m00[2].lclbrrnom
                           ,a_cts26m00[2].brrnom
                           ,a_cts26m00[2].cidnom
                           ,a_cts26m00[2].ufdcod
                           ,a_cts26m00[2].lclrefptotxt
                           ,a_cts26m00[2].endzon
                           ,a_cts26m00[2].lgdcep
                           ,a_cts26m00[2].lgdcepcmp
                           ,a_cts26m00[2].lclltt
                           ,a_cts26m00[2].lcllgt
                           ,a_cts26m00[2].dddcod
                           ,a_cts26m00[2].lcltelnum
                           ,a_cts26m00[2].lclcttnom
                           ,a_cts26m00[2].c24lclpdrcod
                           ,a_cts26m00[2].celteldddcod
                           ,a_cts26m00[2].celtelnum
                           ,a_cts26m00[2].endcmp
                           ,ws.codigosql
                           ,a_cts26m00[2].emeviacod

               select ofnnumdig into a_cts26m00[1].ofnnumdig
                 from datmlcl
                where atdsrvano = g_documento.atdsrvano
                  and atdsrvnum = g_documento.atdsrvnum
                  and c24endtip = 1

               if ws.codigosql = notfound   then
                  let d_cts26m00.dstflg = "N"
               else
                  if ws.codigosql = 0   then
                     let d_cts26m00.dstflg = "S"
                  else
                     error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
                     prompt "" for char prompt_key
                     initialize hist_cts26m00.*  to null
                     return hist_cts26m00.*
                  end if
               end if

               let a_cts26m00[2].lgdtxt = a_cts26m00[2].lgdtip clipped, " ",
                                          a_cts26m00[2].lgdnom clipped, " ",
                                          a_cts26m00[2].lgdnum using "<<<<#"

               call cts16g00_atendimento(cpl_atdsrvnum, cpl_atdsrvano)
                               returning d_cts26m00.nom,
                                         w_cts26m00.vclcorcod,
                                         d_cts26m00.vclcordes

               if cpl_atdsrvorg = 4 then
                  call cts16g00_complemento(cpl_atdsrvnum, cpl_atdsrvano)
                                  returning w_cts26m00.sinvitflg,
                                            w_cts26m00.bocnum,
                                            w_cts26m00.bocemi,
                                            w_cts26m00.vcllibflg,
                                            w_cts26m00.roddantxt,
                                            w_cts26m00.sindat,
                                            d_cts26m00.sinhor

                  let d_cts26m00.sinvitflg = w_cts26m00.sinvitflg
                  let d_cts26m00.roddantxt = w_cts26m00.roddantxt
                  let d_cts26m00.sindat    = w_cts26m00.sindat
               end if

               call cts26m00_display()

               display by name a_cts26m00[1].lgdtxt
               display by name a_cts26m00[1].lclbrrnom
               display by name a_cts26m00[1].endzon
               display by name a_cts26m00[1].cidnom
               display by name a_cts26m00[1].ufdcod
               display by name a_cts26m00[1].lclrefptotxt
               display by name a_cts26m00[1].lclcttnom
               display by name a_cts26m00[1].dddcod
               display by name a_cts26m00[1].lcltelnum
               display by name a_cts26m00[1].celteldddcod
               display by name a_cts26m00[1].celtelnum
               display by name a_cts26m00[1].endcmp
            end if
         end if
      else
         if d_cts26m00.atdlibflg = "N"   then
            error " Servico nao liberado!"
         else
            call cta00m06_sinistro_re(g_issk.dptsgl)
            returning l_acesso
            if l_acesso = true then
               call cts00m00_alertajit(g_documento.atdsrvnum,
                                       g_documento.atdsrvano)
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if
         end if
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts26m00.* to null
 end if

return hist_cts26m00.*

end function  ###  input_cts26m00


#---------------------------------------------------------------
 function cts26m00_cambio(param)
#---------------------------------------------------------------

 define param        record
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig
 end record

 define ws           record
    atdvcltip        like datmservico.atdvcltip,
    vclatmflg        like abbmveic.vclatmflg   ,
    vclchsfnl        like avlmveic.vclchsfnl   ,
    vcllicnum        like avlmveic.vcllicnum   ,
    vclcoddig        like avlmveic.vclcoddig   ,
    vstnumdig        like avlmlaudo.vstnumdig  ,
    vstdat           like avlmlaudo.vstdat     ,
    vsthor           like avlmlaudo.vsthor
 end record

 initialize ws.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return ws.atdvcltip
 end if

#---------------------------------------------------------------
# Obtem a ULTIMA SITUACAO do veiculo
#---------------------------------------------------------------

 call f_funapol_ultima_situacao
      (param.succod, param.aplnumdig, param.itmnumdig)
      returning g_funapol.*

#---------------------------------------------------------------
# Verifica se veiculo possui CAMBIO AUTOMATICO/HIDRAMATICO
#---------------------------------------------------------------

 select vclatmflg   , vclcoddig,
        vcllicnum   , vclchsfnl
   into ws.vclatmflg, ws.vclcoddig,
        ws.vcllicnum, ws.vclchsfnl
   from abbmveic
  where succod    = param.succod     and
        aplnumdig = param.aplnumdig  and
        itmnumdig = param.itmnumdig  and
        dctnumseq = g_funapol.vclsitatu

 if ws.vclatmflg = "S"  then
    let ws.atdvcltip = 1
    return ws.atdvcltip
 end if

#---------------------------------------------------------------
# Obtem o ULTIMO NUMERO DE VISTORIA atraves da Vistoria Previa
#---------------------------------------------------------------

 initialize ws.vstnumdig to null

 if ( ws.vclchsfnl is null or ws.vclchsfnl = " " ) and
    ( ws.vcllicnum is null or ws.vcllicnum = " " ) then
    return ws.atdvcltip
 else
    declare c_cts26m00_002 cursor for
       select avlmlaudo.vstdat ,
              avlmlaudo.vsthor ,
              avlmlaudo.vstnumdig
         from avlmveic, avlmlaudo
        where avlmveic.vclchsfnl  = ws.vclchsfnl       and
              avlmveic.vcllicnum  = ws.vcllicnum       and
              avlmveic.vclcoddig  = ws.vclcoddig       and
              avlmlaudo.vstnumdig = avlmveic.vstnumdig and
              (vstldostt = 0 or vstldostt is null)
        order by 1 desc, 2 desc

    foreach c_cts26m00_002 into ws.vstdat, ws.vsthor, ws.vstnumdig
        exit foreach
    end foreach
 end if

 if ws.vstnumdig = 0  or  ws.vstnumdig is null  then
    initialize ws.atdvcltip to null
 else
#---------------------------------------------------------------
# Verifica nos ACESSORIOS da V.P. se existe cambio hidramatico
#---------------------------------------------------------------
    select vstnumdig from avlmaces
     where vstnumdig = ws.vstnumdig and
           asstip    = 1            and
           asscoddig = 175

    if sqlca.sqlcode <> 0  then
       select vstnumdig from avlmaces
        where vstnumdig = ws.vstnumdig and
              asstip    = 1            and
              asscoddig = 2518

       if sqlca.sqlcode <> 0  then
          initialize ws.atdvcltip to null
       else
          let ws.atdvcltip = 1
       end if
    end if
 end if

 return ws.atdvcltip

end function  ###  cts26m00_cambio

#---------------------------#
function cts26m00_display()
#--------------------------#

   display by name d_cts26m00.servico
   display by name d_cts26m00.c24solnom attribute (reverse)
   display by name d_cts26m00.nom
   display by name d_cts26m00.doctxt
   display by name d_cts26m00.corsus
   display by name d_cts26m00.cornom
   display by name d_cts26m00.cvnnom    attribute (reverse)
   display by name d_cts26m00.vclcoddig
   display by name d_cts26m00.vcldes
   display by name d_cts26m00.vclanomdl
   display by name d_cts26m00.vcllicnum
   display by name d_cts26m00.vclcordes
   display by name d_cts26m00.c24astcod
   display by name d_cts26m00.c24astdes
   display by name d_cts26m00.refasstxt
   display by name d_cts26m00.camflg
   display by name d_cts26m00.refatdsrvtxt
   display by name d_cts26m00.refatdsrvorg
   display by name d_cts26m00.refatdsrvnum
   display by name d_cts26m00.refatdsrvano
   display by name d_cts26m00.sindat
   display by name d_cts26m00.sinhor
   display by name d_cts26m00.sinvitflg
   display by name d_cts26m00.bocflg
   display by name d_cts26m00.dstflg
   display by name d_cts26m00.asitipcod
   display by name d_cts26m00.asitipabvdes
   display by name d_cts26m00.rmcacpflg
   display by name d_cts26m00.imdsrvflg
   display by name d_cts26m00.prsloccab
   display by name d_cts26m00.prslocflg
   display by name d_cts26m00.atdprinvlcod
   display by name d_cts26m00.atdprinvldes
   display by name d_cts26m00.atdlibflg
   display by name d_cts26m00.frmflg
   display by name d_cts26m00.atdtxt
   display by name d_cts26m00.atdlibdat
   display by name d_cts26m00.atdlibhor

end function
