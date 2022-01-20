#############################################################################
# Nome do Modulo: CTR03M02                                            Pedro #
#                                                                   Marcelo #
# Impressao on-line de servicos                                    Mai/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Incluir identificacao para servicos #
#                                       atendidos como particular.          #
#---------------------------------------------------------------------------#
# 15/06/1999  PSI 7547-7   Gilberto     Permitir impressao dos demais tipos #
#                                       de assistencia a passageiros.       #
#---------------------------------------------------------------------------#
# 12/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 14/09/1999  PSI 8821-8   Marcelo      Substituicao do campo ATDMOTNOM por #
#                                       cadastro de motoristas (datksrr).   #
#---------------------------------------------------------------------------#
# 28/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 16/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 26/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 11/12/2000  PSI 11155-4  Ruiz         Inclusao de alerta no relatorio     #
#---------------------------------------------------------------------------#
# 06/02/2001  PSI 11767-6  Wagner       Adaptacao referencia endereco.      #
#---------------------------------------------------------------------------#
# 01/11/2004  Chamado 4084276 Cristina -acerto do layout do relatorio para  #
#                                       impressao em impressoras Laser      #
#############################################################################
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 28/04/2005 Carlos, Meta      PSI189790  alterado relatorio.               #
#                                                                           #
#---------------------------------------------------------------------------#
# 26/10/2005 Lucas Scheid      PSI195138  Obter a descricao da especialidade#
#                                         do servico.                       #
# 25/11/2006 Ligia Mattge      PSI205206  ciaempcod                         #
# 13/08/2009 Sergio Burini     PSI244236  Inclusão do Sub-Dairro            #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton, Meta                Projeto sucursal smallint         #
#---------------------------------------------------------------------------#


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define g_traco         char (80)
 define g_pipe          char (20)
 define g_imptip        char (01),
        m_ctr03m02_prep smallint

 define am_cts29g00 array[10] of record
    atdmltsrvnum   like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano   like datratdmltsrv.atdmltsrvano
   ,socntzdes      like datksocntz.socntzdes
   ,espdes         like dbskesp.espdes
   ,atddfttxt      like datmservico.atddfttxt
 end record

--define m_sem_uso char (01)
define m_maxcstvlr like datmservico.atdcstvlr

define m_mensagem char (80)
define m_mensagem_2 char (135)
define m_mensagem_3 char (135)
define m_mensagem_4 char (135)
define m_mensagem_5 char (135)
define m_mensagem_6 char (135)
define m_nulo smallint

#-------------------------#
function ctr03m02_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select espcod ",
                " from datmsrvre ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_ctr03m02_001 from l_sql
  declare c_ctr03m02_001 cursor for p_ctr03m02_001

  let l_sql = " select vclcndlclcod ",
                " from datrcndlclsrv ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_ctr03m02_002 from l_sql
  declare c_ctr03m02_002 cursor for p_ctr03m02_002

  let l_sql = "select cgccpfnum, "   ,
              " cgcord    , "        ,
              " cgccpfdig   "        ,
              " from datrligcgccpf " ,
              " where lignum = ?   "
  prepare p_ctr03m02_003 from l_sql
  declare c_ctr03m02_003 cursor for p_ctr03m02_003


  let m_ctr03m02_prep = true

end function

#-------------------------------------------------#
function ctr03m02_busca_especialidade(lr_parametro)
#-------------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvre.atdsrvnum,
         atdsrvano    like datmsrvre.atdsrvano
  end record

  define l_espcod like datmsrvre.espcod,
         l_espdes like dbskesp.espdes

  let     l_espcod  =  null
  let     l_espdes  =  null

  # --BUSCA O CODIGO DA ESPECIALIDADE
  open c_ctr03m02_001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  whenever error continue
  fetch c_ctr03m02_001 into l_espcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_espcod = null
     else
        error "Erro SELECT c_ctr03m02_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "CTR03M02/ctr03m02_busca_especialidade() ", lr_parametro.atdsrvnum, "/",
                                                          lr_parametro.atdsrvano sleep 3
     end if
  end if

  # --SE EXISTIR O CODIGO DA ESPECIALIDADE
  if l_espcod is not null then

     # --BUSCA A DESCRICAO DA ESPECIALIDADE
     let l_espdes = cts31g00_descricao_esp(l_espcod, "")

  end if

  return l_espdes

end function

#---------------------------------------------------------------
 function ctr03m02(param)
#---------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_ctr03m02    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    srvtipdes         like datksrvtip.srvtipdes    ,
    c24solnom         like datmligacao.c24solnom   ,
    c24soltipdes      like datksoltip.c24soltipdes ,
    c24astcod         like datmligacao.c24astcod   ,
    c24astdes         char (60)                    ,
    ligcvntip         like datmligacao.ligcvntip   ,
    ligcvnnom         char (20)                    ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (15)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcamdes         char (08)                    ,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    orrlclidttxt      like datmlcl.lclidttxt       ,
    orrlgdtxt         char (65)                    ,
    orrlclbrrnom      like datmlcl.lclbrrnom       ,
    orrbrrnom         like datmlcl.lclbrrnom       ,
    orrcidnom         like datmlcl.cidnom          ,
    orrufdcod         like datmlcl.ufdcod          ,
    orrlclrefptotxt   like datmlcl.lclrefptotxt    ,
    orrendzon         like datmlcl.endzon          ,
    orrdddcod         like datmlcl.dddcod          ,
    orrlcltelnum      like datmlcl.lcltelnum       ,
    orrlclcttnom      like datmlcl.lclcttnom       ,
    atdrsdtxt         char (03)                    ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atddfttxt         like datmservico.atddfttxt   ,
    ntzdes            like datksocntz.socntzdes    ,
    boctxt            char (03)                    ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    sinvittxt         char (03)                    ,
    rmcacptxt         char (03)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    dstlclidttxt      like datmlcl.lclidttxt       ,
    dstlgdtxt         char (65)                    ,
    dstlclbrrnom      like datmlcl.lclbrrnom       ,
    dstbrrnom         like datmlcl.lclbrrnom       ,
    dstcidnom         like datmlcl.cidnom          ,
    dstufdcod         like datmlcl.ufdcod          ,
    dstlclrefptotxt   like datmlcl.lclrefptotxt    ,
    dstendzon         like datmlcl.endzon          ,
    dstdddcod         like datmlcl.dddcod          ,
    dstlcltelnum      like datmlcl.lcltelnum       ,
    dstlclcttnom      like datmlcl.lclcttnom       ,
    asimtvdes         like datkasimtv.asimtvdes    ,
    imdsrvtxt         char (03)                    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atdlibflg         like datmservico.atdlibflg   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdfunmat         like datmservico.funmat      ,
    atdfunnom         like isskfunc.funnom         ,
    atddptsgl         like isskfunc.dptsgl         ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    cnlfunmat         like datmservico.c24opemat   ,
    cnlfunnom         like isskfunc.funnom         ,
    cnldptsgl         like isskfunc.dptsgl         ,
    atdprscod         like datmservico.atdprscod   ,
    nomgrr            like dpaksocor.nomgrr        ,
    nomrazsoc         like dpaksocor.nomrazsoc     ,
    pstdddcod         like dpaksocor.dddcod        ,
    pstteltxt         like dpaksocor.teltxt        ,
    pstfaxnum         like dpaksocor.faxnum        ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdmotnom         like datmservico.atdmotnom   ,
    srrcoddig         like datmservico.srrcoddig   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    socvclcod         like datmservico.socvclcod   ,
    pgtdat            like datmservico.pgtdat      ,
    atdcstvlr         like datmservico.atdcstvlr   ,
    avsfurtxt         char (30)                    ,
    atddocflg         char (03)                    ,
    atddoctxt         like datmservico.atddoctxt   ,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    srvprlflg         like datmservico.srvprlflg        ,
    sgdnom            char (30),
    crtsaunum         like datrligsau.crtnum,
    bnfnum            like datrligsau.bnfnum,
    empnom            like gabkemp.empnom
 end record

 define ws            record
    impflg            smallint                       ,
    impnom            char (08)                      ,
    lignum            like datrligsrv.lignum         ,
    c24soltipcod      like datmligacao.c24soltipcod  ,
    vclcorcod         like datmservico.vclcorcod     ,
    atdrsdflg         like datmservico.atdrsdflg     ,
    asitipcod         like datmservico.asitipcod     ,
    vclcamtip         like datmservicocmp.vclcamtip  ,
    bocflg            like datmservicocmp.bocflg     ,
    sinvitflg         like datmservicocmp.sinvitflg  ,
    rmcacpflg         like datmservicocmp.rmcacpflg  ,
    atdlclflg         like datmservico.atdlclflg     ,
    socntzcod         like datmsrvre.socntzcod       ,
    sinntzcod         like datmsrvre.sinntzcod       ,
    asimtvcod         like datmassistpassag.asimtvcod,
    atddstcidnom      like datmassistpassag.atddstcidnom,
    atddstufdcod      like datmassistpassag.atddstufdcod,
    c24sintip         like datmservicocmp.c24sintip  ,
    c24sinhor         like datmservicocmp.c24sinhor  ,
    lgdtip            like datmlcl.lgdtip            ,
    lgdnom            like datmlcl.lgdnom            ,
    lgdnum            like datmlcl.lgdnum            ,
    lgdcep            like datmlcl.lgdcep            ,
    lgdcepcmp         like datmlcl.lgdcepcmp         ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod      ,
    sqlcode           integer                        ,
    sgdirbcod         like datmservicocmp.sgdirbcod  ,
    ciaempcod         like datmservico.ciaempcod,
    qtddia            like datmhosped.hpddiapvsqtd,
    endcmp            like datmlcl.endcmp,
    empcod            like datmservico.empcod                         #Raul, Biz
   -- qtdqrt            like datmhosped.hpdqrtqtd
 end record

 define lr_ffpfc073 record
        cgccpfnumdig char(18) ,
        cgccpfnum    char(12) ,
        cgcord       char(4)  ,
        cgccpfdig    char(2)  ,
        mens         char(50) ,
        erro         smallint
 end record

 define l_erro    smallint
       ,l_msg     char(30)
       ,l_grupo   smallint
       ,l_segnom  char(50)
       ,l_doc_handle integer

let m_mensagem_2 = null
let m_mensagem_3 = null
let m_mensagem_4 = null
let m_mensagem_5 = null
let m_mensagem_6 = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_erro  =  null
        let     l_msg   =  null
        let     l_grupo =  null
        let     l_segnom =  null
        let     l_doc_handle =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctr03m02.*  to  null

        initialize  ws.*  to  null
        initialize lr_ffpfc073.* to null

 if m_ctr03m02_prep is null or
    m_ctr03m02_prep <> true then
    call ctr03m02_prepare()
 end if

 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 let g_traco = "--------------------------------------------------------------------------------"

 initialize d_ctr03m02.*  to null
 initialize ws.*          to null
 initialize g_pipe        to null

 #---------------------------------------------------------------
 # Selecao da impressora
 #---------------------------------------------------------------
 call fun_print_seleciona (g_issk.dptsgl, "")
      returning ws.impflg, ws.impnom

 if ws.impflg = 0  then
    error " Departamento/impressora nao cadastrada!"
    return
 else
    if ws.impnom is null  then
       error " Uma impressora deve ser selecionada!"
       return
    else
       call fun_print_tipo (ws.impnom) returning g_imptip
       let g_pipe = "lp -sd ", ws.impnom
    end if
 end if


 #--------------------------------------------------------------------
 # Informacoes do servico
 #--------------------------------------------------------------------
 start report rep_servico

 select datmservico.atdsrvnum   , datmservico.atdsrvano   ,
        datmservico.atdsrvorg   ,
        datmservico.nom         , datmservico.corsus      ,
        datmservico.cornom      , datmservico.vcldes      ,
        datmservico.vclcorcod   , datmservico.vcllicnum   ,
        datmservico.vclanomdl   , datmservicocmp.vclcamtip,
        datmservicocmp.vclcrcdsc, datmservicocmp.vclcrgpso,
        datmservico.atdrsdflg   , datmservico.asitipcod   ,
        datmservico.atddfttxt   , datmservicocmp.bocflg   ,
        datmservicocmp.bocnum   , datmservicocmp.bocemi   ,
        datmservicocmp.sindat   , datmservicocmp.sinhor   ,
        datmservicocmp.sinvitflg, datmservicocmp.rmcacpflg,
        datmservicocmp.roddantxt, datmservico.atdhorpvt   ,
        datmservico.atddatprg   , datmservico.atdhorprg   ,
        datmservico.atdlibdat   , datmservico.atdlibhor   ,
        datmservico.atdlibflg   , datmservico.atddat      ,
        datmservico.atdhor      , datmservico.funmat      ,
        datmservico.cnldat      , datmservico.atdfnlhor   ,
        datmservico.c24opemat   , datmservico.atdprscod   ,
        datmservico.c24nomctt   , datmservico.atdmotnom   ,
        datmservico.atdvclsgl   , datmservico.socvclcod   ,
        datmservico.pgtdat      , datmservico.atdcstvlr   ,
        datmservico.atddoctxt   , datmservicocmp.c24sintip,
        datmservicocmp.c24sinhor, datmservico.atdlclflg   ,
        datmservico.srvprlflg   , datmservico.srrcoddig   ,
        datmservicocmp.sgdirbcod, datmservico.ciaempcod   ,
        datmservico.empcod                                            #Raul, Biz
   into d_ctr03m02.atdsrvnum    , d_ctr03m02.atdsrvano    ,
        d_ctr03m02.atdsrvorg    ,
        d_ctr03m02.nom          , d_ctr03m02.corsus       ,
        d_ctr03m02.cornom       , d_ctr03m02.vcldes       ,
        ws.vclcorcod            , d_ctr03m02.vcllicnum    ,
        d_ctr03m02.vclanomdl    , ws.vclcamtip            ,
        d_ctr03m02.vclcrcdsc    , d_ctr03m02.vclcrgpso    ,
        ws.atdrsdflg            , ws.asitipcod            ,
        d_ctr03m02.atddfttxt    , ws.bocflg               ,
        d_ctr03m02.bocnum       , d_ctr03m02.bocemi       ,
        d_ctr03m02.sindat       , d_ctr03m02.sinhor       ,
        ws.sinvitflg            , ws.rmcacpflg            ,
        d_ctr03m02.roddantxt    , d_ctr03m02.atdhorpvt    ,
        d_ctr03m02.atddatprg    , d_ctr03m02.atdhorprg    ,
        d_ctr03m02.atdlibdat    , d_ctr03m02.atdlibhor    ,
        d_ctr03m02.atdlibflg    , d_ctr03m02.atddat       ,
        d_ctr03m02.atdhor       , d_ctr03m02.atdfunmat    ,
        d_ctr03m02.cnldat       , d_ctr03m02.atdfnlhor    ,
        d_ctr03m02.cnlfunmat    , d_ctr03m02.atdprscod    ,
        d_ctr03m02.c24nomctt    , d_ctr03m02.atdmotnom    ,
        d_ctr03m02.atdvclsgl    , d_ctr03m02.socvclcod    ,
        d_ctr03m02.pgtdat       , d_ctr03m02.atdcstvlr    ,
        d_ctr03m02.atddoctxt    , ws.c24sintip            ,
        ws.c24sinhor            , ws.atdlclflg            ,
        d_ctr03m02.srvprlflg    , d_ctr03m02.srrcoddig    ,
        ws.sgdirbcod            , ws.ciaempcod            ,
        ws.empcod                                                     #Raul, Biz
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = param.atdsrvnum
    and datmservico.atdsrvano    = param.atdsrvano
    and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
    and datmservicocmp.atdsrvano = datmservico.atdsrvano



 ## obter o nome da empresa
 call cty14g00_empresa(1, ws.ciaempcod)
      returning l_erro, l_msg, d_ctr03m02.empnom

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              1)
                    returning d_ctr03m02.orrlclidttxt   ,
                              ws.lgdtip                 ,
                              ws.lgdnom                 ,
                              ws.lgdnum                 ,
                              d_ctr03m02.orrlclbrrnom   ,
                              d_ctr03m02.orrbrrnom      ,
                              d_ctr03m02.orrcidnom      ,
                              d_ctr03m02.orrufdcod      ,
                              d_ctr03m02.orrlclrefptotxt,
                              d_ctr03m02.orrendzon      ,
                              ws.lgdcep                 ,
                              ws.lgdcepcmp              ,
                              d_ctr03m02.orrdddcod      ,
                              d_ctr03m02.orrlcltelnum   ,
                              d_ctr03m02.orrlclcttnom   ,
                              ws.c24lclpdrcod           ,
                              ws.sqlcode                ,
                              ws.endcmp
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(d_ctr03m02.orrbrrnom,
                                d_ctr03m02.orrlclbrrnom)
      returning d_ctr03m02.orrbrrnom

 let d_ctr03m02.orrlgdtxt = ws.lgdtip clipped, " ",
                            ws.lgdnom clipped, " ",
                            ws.lgdnum using "<<<<#", " ",
                            ws.endcmp clipped

 #--------------------------------------------------------------------
 # Informacoes do local de destino
 #--------------------------------------------------------------------
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              2)
                    returning d_ctr03m02.dstlclidttxt,
                              ws.lgdtip              ,
                              ws.lgdnom              ,
                              ws.lgdnum              ,
                              d_ctr03m02.dstlclbrrnom,
                              d_ctr03m02.dstbrrnom   ,
                              d_ctr03m02.dstcidnom   ,
                              d_ctr03m02.dstufdcod   ,
                              d_ctr03m02.dstlclrefptotxt,
                              d_ctr03m02.dstendzon   ,
                              ws.lgdcep              ,
                              ws.lgdcepcmp           ,
                              d_ctr03m02.dstdddcod   ,
                              d_ctr03m02.dstlcltelnum,
                              d_ctr03m02.dstlclcttnom,
                              ws.c24lclpdrcod        ,
                              ws.sqlcode             ,
                              ws.endcmp
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(d_ctr03m02.dstbrrnom,
                                d_ctr03m02.dstlclbrrnom)
      returning d_ctr03m02.dstbrrnom

 let d_ctr03m02.dstlgdtxt = ws.lgdtip clipped, " ",
                            ws.lgdnom clipped, " ",
                            ws.lgdnum using "<<<<#", " ",
                            ws.endcmp clipped

 #---------------------------------------------------------------
 # Documento de referencia
 #---------------------------------------------------------------
 select ramcod   , succod   ,
        aplnumdig, itmnumdig,
        edsnumref
   into d_ctr03m02.ramcod   ,
        d_ctr03m02.succod   ,
        d_ctr03m02.aplnumdig,
        d_ctr03m02.itmnumdig,
        g_documento.edsnumref ##psi 205206
   from datrservapol
  where atdsrvnum = d_ctr03m02.atdsrvnum  and
        atdsrvano = d_ctr03m02.atdsrvano

 #---------------------------------------------------------------
 # Dados da ligacao
 #---------------------------------------------------------------
 let ws.lignum = cts20g00_servico(d_ctr03m02.atdsrvnum, d_ctr03m02.atdsrvano)

 select c24solnom, c24soltipcod,
        c24astcod, ligcvntip
   into d_ctr03m02.c24solnom,
        ws.c24soltipcod     ,
        d_ctr03m02.c24astcod,
        d_ctr03m02.ligcvntip
   from datmligacao
  where lignum = ws.lignum

 call c24geral8(d_ctr03m02.c24astcod)
      returning d_ctr03m02.c24astdes

 let d_ctr03m02.ligcvnnom = "** NAO CADASTRADO **"

 select cpodes
   into d_ctr03m02.ligcvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = d_ctr03m02.ligcvntip

 select c24soltipdes
   into d_ctr03m02.c24soltipdes
   from datksoltip
        where c24soltipcod = ws.c24soltipcod

 #---------------------------------------------------------------
 # Descricao da congenere
 #----------------------------------------------------------------
 if ws.sgdirbcod is not null  then
    select sgdnom
      into d_ctr03m02.sgdnom
      from gcckcong
     where sgdirbcod = ws.sgdirbcod
 end if
 #---------------------------------------------------------------
 # Telefone do segurado
 #---------------------------------------------------------------

 ### PSI 202720
 let l_erro = null
 let l_msg = null
 let l_grupo = null

 call cty10g00_grupo_ramo(g_issk.empcod, d_ctr03m02.ramcod )
      returning l_erro, l_msg, l_grupo

 if l_grupo is null or l_grupo = 5 then ## Saude
    call cts20g09_docto(2, ws.lignum)
         returning d_ctr03m02.ramcod, d_ctr03m02.succod,
                   d_ctr03m02.aplnumdig,  d_ctr03m02.crtsaunum,
                   d_ctr03m02.bnfnum

    call cta01m15_sel_datksegsau (3, d_ctr03m02.crtsaunum, "","","")
         returning l_erro, l_msg, l_segnom, d_ctr03m02.dddcod,
                   d_ctr03m02.teltxt
 else
    if ws.ciaempcod = 1 then
       call cts09g00(d_ctr03m02.ramcod,
                     d_ctr03m02.succod,
                     d_ctr03m02.aplnumdig,
                     d_ctr03m02.itmnumdig,
                     false)
           returning d_ctr03m02.dddcod,
                     d_ctr03m02.teltxt
    else
       ## obtem o telefone do segurado da Azul - psi 205206
       if ws.ciaempcod = 35 then
          call cts42g00_doc_handle(d_ctr03m02.succod, d_ctr03m02.ramcod,
                                   d_ctr03m02.aplnumdig, d_ctr03m02.itmnumdig,
                                   g_documento.edsnumref)
               returning l_erro, l_msg, l_doc_handle

          if l_erro = 1 and l_doc_handle is not null then
             call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                  returning d_ctr03m02.dddcod,  d_ctr03m02.teltxt
          end if
       end if

       # Itau

       if ws.ciaempcod = 84 then
           let d_ctr03m02.dddcod = g_doc_itau[1].segresteldddnum
           let d_ctr03m02.teltxt = g_doc_itau[1].segrestelnum
       end if



       #PortoSeg
       if ws.ciaempcod = 40 then

         whenever error continue
         open c_ctr03m02_003 using ws.lignum

         fetch c_ctr03m02_003 into lr_ffpfc073.cgccpfnum ,
                                 lr_ffpfc073.cgcord    ,
                                 lr_ffpfc073.cgccpfdig

         whenever error stop

         let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                lr_ffpfc073.cgcord    ,
                                                                lr_ffpfc073.cgccpfdig )

            call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                  returning d_ctr03m02.dddcod ,
                            d_ctr03m02.teltxt ,
                            lr_ffpfc073.mens  ,
                            lr_ffpfc073.erro

            if lr_ffpfc073.erro <> 0 then
                error lr_ffpfc073.mens
            end if
       end if
    end if
 end if

 #---------------------------------------------------------------
 # Cor do veiculo
 #---------------------------------------------------------------
 select cpodes
   into d_ctr03m02.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod

 let d_ctr03m02.vclcordes = upshift(d_ctr03m02.vclcordes)

 #---------------------------------------------------------------
 # Dados do atendente / operador do radio
 #---------------------------------------------------------------
 let d_ctr03m02.atdfunnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into d_ctr03m02.atdfunnom,
        d_ctr03m02.atddptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = d_ctr03m02.atdfunmat

 let d_ctr03m02.atdfunnom = upshift(d_ctr03m02.atdfunnom)
 let d_ctr03m02.atddptsgl = upshift(d_ctr03m02.atddptsgl)

 let d_ctr03m02.cnlfunnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into d_ctr03m02.cnlfunnom,
        d_ctr03m02.cnldptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = d_ctr03m02.cnlfunmat

 let d_ctr03m02.cnlfunnom = upshift(d_ctr03m02.cnlfunnom)
 let d_ctr03m02.cnldptsgl = upshift(d_ctr03m02.cnldptsgl)

 #---------------------------------------------------------------
 # Dados do prestador
 #---------------------------------------------------------------
 select nomgrr   ,
        nomrazsoc,
        dddcod   ,
        teltxt   ,
        faxnum
   into d_ctr03m02.nomgrr   ,
        d_ctr03m02.nomrazsoc,
        d_ctr03m02.pstdddcod,
        d_ctr03m02.pstteltxt,
        d_ctr03m02.pstfaxnum
   from dpaksocor
  where pstcoddig = d_ctr03m02.atdprscod

 if ws.atdrsdflg is not null  then
    if ws.atdrsdflg = "S"  then
       let d_ctr03m02.atdrsdtxt = "SIM"
    else
       let d_ctr03m02.atdrsdtxt = "NAO"
    end if
 end if

 #---------------------------------------------------------------
 # Tipo do atendimento
 #---------------------------------------------------------------
 select srvtipdes
   into d_ctr03m02.srvtipdes
   from datksrvtip
  where atdsrvorg = d_ctr03m02.atdsrvorg

 select asitipabvdes
   into d_ctr03m02.asitipabvdes
   from datkasitip
  where asitipcod = ws.asitipcod

 if ws.bocflg is not null  then
    if ws.bocflg = "S"  then
       let d_ctr03m02.boctxt = "SIM"
    else
       let d_ctr03m02.boctxt = "NAO"
    end if
 end if

 if ws.sinvitflg is not null  then
    if ws.sinvitflg = "S"  then
       let d_ctr03m02.sinvittxt = "SIM"
    else
       let d_ctr03m02.sinvittxt = "NAO"
    end if
 end if

 if ws.rmcacpflg is not null  then
    if ws.rmcacpflg = "S"  then
       let d_ctr03m02.rmcacptxt = "SIM"
    else
       let d_ctr03m02.rmcacptxt = "NAO"
    end if
 end if

 case ws.vclcamtip
    when 1  let d_ctr03m02.vclcamdes = "TRUCK"
    when 2  let d_ctr03m02.vclcamdes = "TOCO"
    when 3  let d_ctr03m02.vclcamdes = "CARRETA"
 end case

 if d_ctr03m02.atdsrvorg = 11 then
    case ws.c24sintip
       when "F"  let d_ctr03m02.avsfurtxt  = "FURTO"
       when "R"  let d_ctr03m02.avsfurtxt  = "ROUBO"
    end case

    let d_ctr03m02.avsfurtxt = d_ctr03m02.avsfurtxt clipped, " OCORRIDO"

    case ws.c24sinhor
       when "D"  let d_ctr03m02.avsfurtxt = d_ctr03m02.avsfurtxt clipped, " DURANTE O DIA"
       when "N"  let d_ctr03m02.avsfurtxt = d_ctr03m02.avsfurtxt clipped, " DURANTE A NOITE"
       otherwise let d_ctr03m02.avsfurtxt = d_ctr03m02.avsfurtxt clipped, " AS ", d_ctr03m02.sinhor
    end case
 end if

 if d_ctr03m02.atdhorpvt is not null  or
    d_ctr03m02.atdhorpvt  = "00:00"   then
    let d_ctr03m02.imdsrvtxt = "SIM"
 end if

 if d_ctr03m02.atddatprg is not null  then
    let d_ctr03m02.imdsrvtxt = "NAO"
 end if

 if ws.atdlclflg = "S"  then
    let d_ctr03m02.atddocflg = "SIM"
 else
    let d_ctr03m02.atddocflg = "NAO"
 end if

 #---------------------------------------------------------------
 # Dados especificos de servicos Ramos Elementares
 #---------------------------------------------------------------
 if d_ctr03m02.atdsrvorg = 9   or
    d_ctr03m02.atdsrvorg = 13  then
    select socntzcod,
           sinntzcod
      into ws.socntzcod,
           ws.sinntzcod
      from datmsrvre
     where atdsrvnum = d_ctr03m02.atdsrvnum  and
           atdsrvano = d_ctr03m02.atdsrvano

    let d_ctr03m02.ntzdes = "*** NAO CADASTRADO! ***"

    if ws.socntzcod is not null  then
       select socntzdes
         into d_ctr03m02.ntzdes
         from datksocntz
        where socntzcod = ws.socntzcod
    else
       select sinntzdes
         into d_ctr03m02.ntzdes
         from sgaknatur
        where sinramgrp = "4"      and
              sinntzcod = ws.sinntzcod
    end if
 end if

 #---------------------------------------------------------------
 # Dados especificos de assistencia a passageiros
 #---------------------------------------------------------------
 if d_ctr03m02.atdsrvorg = 2  then
    select asimtvcod,
           atddmccidnom,
           atddmcufdcod,
           atddstcidnom,
           atddstufdcod
      into ws.asimtvcod,
           d_ctr03m02.atddmccidnom,
           d_ctr03m02.atddmcufdcod,
           ws.atddstcidnom,
           ws.atddstufdcod
      from datmassistpassag
     where atdsrvnum = d_ctr03m02.atdsrvnum  and
           atdsrvano = d_ctr03m02.atdsrvano

    if ws.asimtvcod is not null  then
       let d_ctr03m02.asimtvdes = "*** NAO PREVISTO ***"

       select asimtvdes
         into d_ctr03m02.asimtvdes
         from datkasimtv
        where asimtvcod = ws.asimtvcod
    end if

    if (d_ctr03m02.atdsrvorg =  2  and
        ws.asitipcod      = 10 )   or
       (d_ctr03m02.atdsrvorg = 3)  then
       let d_ctr03m02.dstcidnom = ws.atddstcidnom
       let d_ctr03m02.dstufdcod = ws.atddstufdcod
    end if

 end if

 #-- Obter os servicos multiplos
 initialize am_cts29g00 to null
 let l_erro = null
 let l_msg  = null

 call cts29g00_obter_multiplo(1
                             ,d_ctr03m02.atdsrvnum
                             ,d_ctr03m02.atdsrvano)
    returning l_erro
             ,l_msg
             ,am_cts29g00[01].*
             ,am_cts29g00[02].*
             ,am_cts29g00[03].*
             ,am_cts29g00[04].*
             ,am_cts29g00[05].*
             ,am_cts29g00[06].*
             ,am_cts29g00[07].*
             ,am_cts29g00[08].*
             ,am_cts29g00[09].*
             ,am_cts29g00[10].*

 if l_erro = 3 then
    error l_msg sleep 2
 else  --varani
     if d_ctr03m02.atdsrvorg =  03  then
             select hpddiapvsqtd
               into ws.qtddia
               from datmhosped
              where atdsrvnum = d_ctr03m02.atdsrvnum
                and atdsrvano = d_ctr03m02.atdsrvano
      end if

      if (d_ctr03m02.atdsrvorg = 2 or d_ctr03m02.atdsrvorg = 3) then
         call ctr03m02_busca_limite_cob( d_ctr03m02.atdsrvnum
                                        ,d_ctr03m02.atdsrvano
                                        ,d_ctr03m02.succod
                                        ,d_ctr03m02.aplnumdig  --varani --> passando os parametros recuperados
                                        ,d_ctr03m02.itmnumdig
                                        ,ws.asitipcod
                                        ,d_ctr03m02.ramcod
                                        ,ws.asimtvcod
                                        ,d_ctr03m02.ligcvntip
                                        ,ws.qtddia
                                        ,d_ctr03m02.atdsrvorg  )
              returning m_mensagem_2,
                        m_mensagem_3,
                        m_mensagem_4,
                        m_mensagem_5,
                        m_mensagem_6


      end if


      output to report rep_servico(d_ctr03m02.*,
                                   m_mensagem_2,
                                   m_mensagem_3,  --varani passando os parametros recuperados = retorno mensagem
                                   m_mensagem_4,
                                   m_mensagem_5,
                                   m_mensagem_6)


     finish report rep_servico

 end if


end function  ###  ctr03m02

--varani
function ctr03m02_busca_limite_cob(param)
  define param record
               atdsrvnum like datmservico.atdsrvnum
              ,atdsrvano like datmservico.atdsrvano
              ,succod like datrservapol.succod
              ,aplnumdig like datrservapol.aplnumdig
              ,itmnumdig like datrservapol.itmnumdig  --varani
              ,asitipcod like datmservico.asitipcod
              ,ramcod like datrservapol.ramcod
              ,asimtvcod like datmassistpassag.asimtvcod
              ,ligcvntip like datmligacao.ligcvntip
              ,qtddia like datmhosped.hpddiapvsqtd
              ,atdsrvorg like datmservico.atdsrvorg

   end record

   call cts45g00_limites_cob(1
                              ,param.atdsrvnum
                              ,param.atdsrvano
                              ,param.succod
                              ,param.aplnumdig
                              ,param.itmnumdig
                              ,param.asitipcod
                              ,param.ramcod
                              ,param.asimtvcod
                              ,param.ligcvntip
                              ,param.qtddia)
          returning m_maxcstvlr


  if (param.atdsrvorg = 2 or param.atdsrvorg = 3 ) then


     if param.asimtvcod = 3 then
        let m_mensagem_2 = "----------------------------------------------- ******* ATENCAO ******* ------------------------------------------------------------"  -- motivo 3 - recuperacao de veiculo
        let m_mensagem_3 = "Limite de cobertura restrito ao valor de uma passagem aerea na classe economica"
        let m_mensagem_4 = null
        let m_mensagem_5 = "Qualquer valor excedente deve ser cobrado do segurado."
        let m_mensagem_6 = "------------------------------------------------------------------------------------------------------------------------------------"

     else
        if (m_maxcstvlr > 0) then

           if(param.asitipcod = 5 ) then
              let m_mensagem_2 = "--------------------------------------------------  *** ATENCAO ***  ---------------------------------------------------------------"  --taxi
              let m_mensagem_3 = "Em caso de viagem devidamente autorizada pela Central de Atendimento,"
              let m_mensagem_4 = "cobrar ate o limite de R$ ",m_maxcstvlr using "<,<<<.<<"," da PORTO SEGURO."
              let m_mensagem_5 = "Qualquer valor excedente deve ser cobrado do segurado."
              let m_mensagem_6 = "------------------------------------------------------------------------------------------------------------------------------------"
           else
              if (param.asitipcod = 10  ) then
                  let m_mensagem_2 = "--------------------------------------------------  *** ATENCAO ***  ---------------------------------------------------------------"  --aviao
                  let m_mensagem_3 = "Em caso de viagem aerea devidamente autorizada pela Central de Atendimento,"
                  let m_mensagem_4 = "cobrar ate o limite de R$ ",m_maxcstvlr using "<,<<<.<<"," da PORTO SEGURO."
                  let m_mensagem_5 = "Qualquer valor excedente deve ser cobrado do segurado."
                  let m_mensagem_6 =  "------------------------------------------------------------------------------------------------------------------------------------"
              else
                 if (param.asitipcod = 13) then
                       let m_mensagem_2 = "--------------------------------------------------  *** ATENCAO ***  ---------------------------------------------------------------" --hospedagem
                       let m_mensagem_3 = "Em caso de hospedagem devidamente autorizada pela Central de Atendimento, "
                       let m_mensagem_4 = "cobrar ate o limite de R$ ",m_maxcstvlr using "<,<<<.<<"," da PORTO SEGURO."
                       let m_mensagem_5 = "Qualquer valor excedente deve ser cobrado do segurado."
                       let m_mensagem_6 = "------------------------------------------------------------------------------------------------------------------------------------"
                 else
                     if (param.asitipcod = 12) then
                           let m_mensagem_2 = null
                           let m_mensagem_3 = null
                           let m_mensagem_4 = null
                           let m_mensagem_5 = null
                           let m_mensagem_6 = null
                     end if
                 end if
              end if
           end if
        end if
     end if
  end if


  return m_mensagem_2,
         m_mensagem_3,
         m_mensagem_4,
         m_mensagem_5,
         m_mensagem_6

end function




#---------------------------------------------------------------------------
 report rep_servico(r_ctr03m02,
                    m_mensagem_2,
                    m_mensagem_3,
                    m_mensagem_4,  --varani
                    m_mensagem_5,
                    m_mensagem_6)
#---------------------------------------------------------------------------
 define m_mensagem_2 char (80)
 define m_mensagem_3 char (80)  --varani
 define m_mensagem_4 char (80)
 define m_mensagem_5 char (80)
 define m_mensagem_6 char (80)

 define r_ctr03m02    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    srvtipdes         like datksrvtip.srvtipdes    ,
    c24solnom         like datmligacao.c24solnom   ,
    c24soltipdes      like datksoltip.c24soltipdes ,
    c24astcod         like datmligacao.c24astcod   ,
    c24astdes         char (60)                    ,
    ligcvntip         like datmligacao.ligcvntip   ,
    ligcvnnom         char (20)                    ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (15)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcamdes         char (08)                    ,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    orrlclidttxt      like datmlcl.lclidttxt       ,
    orrlgdtxt         char (80)                    ,
    orrlclbrrnom      like datmlcl.lclbrrnom       ,
    orrbrrnom         like datmlcl.lclbrrnom       ,
    orrcidnom         like datmlcl.cidnom          ,
    orrufdcod         like datmlcl.ufdcod          ,
    orrlclrefptotxt   like datmlcl.lclrefptotxt    ,
    orrendzon         like datmlcl.endzon          ,
    orrdddcod         like datmlcl.dddcod          ,
    orrlcltelnum      like datmlcl.lcltelnum       ,
    orrlclcttnom      like datmlcl.lclcttnom       ,
    atdrsdtxt         char (03)                    ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atddfttxt         like datmservico.atddfttxt   ,
    ntzdes            like datksocntz.socntzdes    ,
    boctxt            char (03)                    ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    sinvittxt         char (03)                    ,
    rmcacptxt         char (03)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    dstlclidttxt      like datmlcl.lclidttxt       ,
    dstlgdtxt         char (65)                    ,
    dstlclbrrnom      like datmlcl.lclbrrnom       ,
    dstbrrnom         like datmlcl.lclbrrnom       ,
    dstcidnom         like datmlcl.cidnom          ,
    dstufdcod         like datmlcl.ufdcod          ,
    dstlclrefptotxt   like datmlcl.lclrefptotxt    ,
    dstendzon         like datmlcl.endzon          ,
    dstdddcod         like datmlcl.dddcod          ,
    dstlcltelnum      like datmlcl.lcltelnum       ,
    dstlclcttnom      like datmlcl.lclcttnom       ,
    asimtvdes         like datkasimtv.asimtvdes    ,
    imdsrvtxt         char (03)                    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atdlibflg         like datmservico.atdlibflg   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdfunmat         like datmservico.funmat      ,
    atdfunnom         like isskfunc.funnom         ,
    atddptsgl         like isskfunc.dptsgl         ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    cnlfunmat         like datmservico.c24opemat   ,
    cnlfunnom         like isskfunc.funnom         ,
    cnldptsgl         like isskfunc.dptsgl         ,
    atdprscod         like datmservico.atdprscod   ,
    nomgrr            like dpaksocor.nomgrr        ,
    nomrazsoc         like dpaksocor.nomrazsoc     ,
    pstdddcod         like dpaksocor.dddcod        ,
    pstteltxt         like dpaksocor.teltxt        ,
    pstfaxnum         like dpaksocor.faxnum        ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdmotnom         like datmservico.atdmotnom   ,
    srrcoddig         like datmservico.srrcoddig   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    socvclcod         like datmservico.socvclcod   ,
    pgtdat            like datmservico.pgtdat      ,
    atdcstvlr         like datmservico.atdcstvlr   ,
    avsfurtxt         char (30)                    ,
    atddocflg         char (03)                    ,
    atddoctxt         like datmservico.atddoctxt   ,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    srvprlflg         like datmservico.srvprlflg        ,
    sgdnom            char (30),
    crtsaunum         like datrligsau.crtnum,
    bnfnum            like datrligsau.bnfnum,
    empnom            like gabkemp.empnom
 end record

 define h_ctr03m02  record
    ligdat          like datmservhist.ligdat     ,
    lighorinc       like datmservhist.lighorinc  ,
    c24funmat       like datmservhist.c24funmat  ,
    c24srvdsc       like datmservhist.c24srvdsc  ,
    c24empcod       like datmservhist.c24empcod                       #Raul, Biz
 end record

 define p_ctr03m02  record
    ligdat          like datmpesqhist.ligdat     ,
    lighorinc       like datmpesqhist.lighorinc  ,
    c24funmat       like datmpesqhist.c24funmat  ,
    c24psqdsc       like datmpesqhist.c24psqdsc
 end record

 define ws          record
    funnom          like isskfunc.funnom         ,
    lintxt          like datmservhist.c24srvdsc  ,
    pasnom          like datmpassageiro.pasnom   ,
    pasidd          like datmpassageiro.pasidd   ,
    avlitmcod       like datrpesqaval.avlitmcod  ,
    avlpsqnot       like datrpesqaval.avlpsqnot  ,
    ligdatant       like datmservhist.ligdat     ,
    lighorant       like datmservhist.lighorinc  ,
    vclcoddig       like datkveiculo.vclcoddig   ,
    srrabvnom       like datksrr.srrabvnom       ,
    vcldes          char (58),
    pagflg          smallint,
    qtddia          like datmhosped.hpddiapvsqtd,
    qtdqrt          like datmhosped.hpdqrtqtd   ,
    conge           char(41),
    vclcndlclcod    like datrcndlclsrv.vclcndlclcod,
    vclcndlcldes    like datkvclcndlcl.vclcndlcldes
 end record

 define l_i smallint
       ,l_aux1 char(50)
       ,l_aux2 char(50)
       ,l_passou smallint
       ,l_cartao char(30)

 define l_espdes like dbskesp.espdes

 output report to pipe g_pipe
    left   margin  00
    right  margin  80
    top    margin  01
    bottom margin  01
    page   length  66

 format
    page header
       if pageno  =  1   then
          initialize ws.* to null
       end if
       if g_imptip = "L"  then
          print ascii(027),"E",                 #resert
                ascii(027),"(s0p13h0s0b4099T",  #Fonte - Currier
                ascii(027),"&l0O",              #Formato de Impressao -Landscape
                ascii(027),"&a06L",             #margem direita
                ascii(027),"&24E",              #posicao inicial - Topo da pag
                ascii(027),"&l7C",
                ascii(027),"&f1y4X"             #Formulario
       else
          print column 001, ""
       end if

       print column 001, r_ctr03m02.empnom clipped,
             column 050, "CTR03M02",
             column 065, "PAG.:    ", pageno using "###,##&"
       print column 065, "DATA: "   , today
       print column 027, "CONTROLE DE SERVICOS",
             column 065, "HORA:   " , time
       skip 1 line
       --   print column 001, g_traco


    on every row

        if m_mensagem_2 is not null then
          print column 001, m_mensagem_2 clipped
          print column 001, m_mensagem_3 clipped
          print column 001, m_mensagem_4 clipped   --varani -->imprimindo as linhas de mensagem
          print column 001, m_mensagem_5 clipped
          print column 001, m_mensagem_6 clipped
       end if

      -- print column 001 ,"ASITIPCOD", asitipcod clipped -- varani teste

       print column 001, "TIPO.....: ", r_ctr03m02.srvtipdes;
       if r_ctr03m02.srvprlflg = "S"  then
          print column 040, "(PARTICULAR)"
       else
          print column 040, " "
       end if

       print column 001, "ASSUNTO..: ", r_ctr03m02.c24astcod,
                          " - "       , r_ctr03m02.c24astdes
       initialize ws.conge to null
       if r_ctr03m02.sgdnom is not null then
          let ws.conge = "CONGENERE: ", r_ctr03m02.sgdnom
       end if
       print column 001, "CONVENIO.: ", r_ctr03m02.ligcvntip using "###&",
                         " - "        , r_ctr03m02.ligcvnnom,
             column 039, ws.conge

       print column 001, "SERVICO..: ",r_ctr03m02.atdsrvorg using "&&"
                                  ,"/",r_ctr03m02.atdsrvnum using "&&&&&&&"
                                  ,"-",r_ctr03m02.atdsrvano using "&&",
             column 026, "NAT.: ",r_ctr03m02.ntzdes[1,19],
             column 051, "PROBLEMA.:",r_ctr03m02.atddfttxt[1,20]

       let l_espdes = null

       # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
       let l_espdes = ctr03m02_busca_especialidade(r_ctr03m02.atdsrvnum,
                                                   r_ctr03m02.atdsrvano)

       # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
       if l_espdes is not null and
          l_espdes <> " " then
          print column 026, "ESP.: ", l_espdes
       end if

       #-- Imprimir servico, natureza e problema dos servicos multiplos
       for l_i = 1 to 10
          if am_cts29g00[l_i].atdmltsrvnum is not null then
             let l_aux1 = am_cts29g00[l_i].socntzdes
             let l_aux2 = am_cts29g00[l_i].atddfttxt
             print column 012, r_ctr03m02.atdsrvorg          using "&&"
                          ,"/",am_cts29g00[l_i].atdmltsrvnum using "&&&&&&&"
                          ,"-",am_cts29g00[l_i].atdmltsrvano using "&&",
                   column 026, "NAT.: ",     l_aux1[1,19],
                   column 051, "PROBLEMA.:",l_aux2[1,20]

             let l_espdes = null

             # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
             let l_espdes = ctr03m02_busca_especialidade(am_cts29g00[l_i].atdmltsrvnum,
                                                         am_cts29g00[l_i].atdmltsrvano)

             # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
             if l_espdes is not null and
                l_espdes <> " " then
                print column 026, "ESP.: ", l_espdes
             end if

          end if
       end for

       print column 001, g_traco

       print column 001, "DOCUMENTO: ";
       if r_ctr03m02.crtsaunum is not null then
          let l_cartao = null
          call cts20g16_formata_cartao(r_ctr03m02.crtsaunum)
               returning l_cartao
          print l_cartao
       else
          if r_ctr03m02.ramcod    is null  or
             r_ctr03m02.succod    is null  or
             r_ctr03m02.aplnumdig is null  then
             print "*** NAO INFORMADO ***"
          else
             print r_ctr03m02.succod     using "<<<&&" , "/",#"&&"   , "/", #Projeto Succod
                    r_ctr03m02.ramcod    using "&&&&"  , "/",
                   r_ctr03m02.aplnumdig  using "<<<<<<<& &";
             if r_ctr03m02.itmnumdig <> 0  then
                print "/", r_ctr03m02.itmnumdig using "<<<<<<& &"
             else
                print ""
             end if
          end if
       end if

       print column 001, "SOLICIT..: ", r_ctr03m02.c24solnom,
             column 059, "TIPO..: "   , r_ctr03m02.c24soltipdes
       print column 001, "SEGURADO.: ", r_ctr03m02.nom
       print column 001, "TELEFONE.: ", "(", r_ctr03m02.dddcod, ") ", r_ctr03m02.teltxt
       print column 001, "CORRETOR.: ", r_ctr03m02.corsus, " - ",
                                        r_ctr03m02.cornom
       print column 001, g_traco

       if r_ctr03m02.vcldes is not null  then
          print column 001, "VEICULO..: ", r_ctr03m02.vcldes,
                column 059, "COR...: ",    r_ctr03m02.vclcordes

          if r_ctr03m02.vclcamdes is not null  then
             print column 001, "TIPO.....: ", r_ctr03m02.vclcamdes;

             if r_ctr03m02.vclcrcdsc is not null  then
                print column 021, "CARROCERIA: ", r_ctr03m02.vclcrcdsc;
             end if

             if r_ctr03m02.vclcrgpso is not null  then
                print column 053, "PESO..: ", r_ctr03m02.vclcrgpso using "###,###", " KG"
             else
                print ""
             end if
          end if

          print column 001, "ANO MOD..: ", r_ctr03m02.vclanomdl,
                column 059, "PLACA.: "   , r_ctr03m02.vcllicnum
          print column 001, g_traco
       end if

       #---------------------------------------------------------------
       # Impressao dos dados referentes ao local da ocorrencia
       #---------------------------------------------------------------
       if r_ctr03m02.orrlclidttxt  is not null  then
          print column 001, "LOCAL....: " , r_ctr03m02.orrlclidttxt
       end if

       print column 001, "ENDERECO.: ", r_ctr03m02.orrlgdtxt
       print column 001, "BAIRRO...: ", r_ctr03m02.orrbrrnom
       print column 001, "CIDADE...: ", r_ctr03m02.orrcidnom,
             column 059, "UF....: "   , r_ctr03m02.orrufdcod
       print column 001, "REFERENC.: ", r_ctr03m02.orrlclrefptotxt[1,40],
             column 059, "ZONA..: "   , r_ctr03m02.orrendzon
       print column 001, "TELEFONE.: ", "(", r_ctr03m02.orrdddcod, ") ",
                                        r_ctr03m02.orrlcltelnum
       print column 001, "RESPONS..: ", r_ctr03m02.orrlclcttnom

       #---------------------------------------------------------------
       # Impressao de dados especificos de REMOCOES
       #---------------------------------------------------------------
       if r_ctr03m02.atdsrvorg = 4  or
          r_ctr03m02.atdsrvorg = 5  or
          r_ctr03m02.atdsrvorg = 7  or
          r_ctr03m02.atdsrvorg =17  then

          if r_ctr03m02.atdsrvorg  =  4  then
             if r_ctr03m02.boctxt is not null  then
                print column 001, "B.O.?....: " , r_ctr03m02.boctxt,
                      column 025, "B.O. No...: ",
                      r_ctr03m02.bocnum using "<<<<&",
                      column 059, "ORGAO.: "    , r_ctr03m02.bocemi
             end if

             print column 001, "DATA SIN.: "    , r_ctr03m02.sindat,
                   column 025, "HORA SINIS: "   , r_ctr03m02.sinhor,
                   column 059, "VITIMA: "       , r_ctr03m02.sinvittxt

             print column 001, "ACOMPANHA: "    , r_ctr03m02.rmcacptxt,
                   column 025, "RODAS DAN.: "   , r_ctr03m02.roddantxt
          else
             print column 001, "RODAS DAN: "    , r_ctr03m02.roddantxt
          end if

          if r_ctr03m02.atdsrvorg = 5    and  #  R.P.T.
             r_ctr03m02.orrufdcod <> "SP" then
             print column 001, g_traco
             print column 001, "* ATENCAO:",
                   column 012,
           "Para recebimento deste servico,favor enviar a sucursal Porto Seguro"
             print column 012,
            "em 24hrs,copia ou fax do laudo de remocao totalmente preenchido  e"
             print column 012, "assinado pela recepcao do patio."
          end if
          skip 1 lines
       end if

       #---------------------------------------------------------------
       # Impressao de dados especificos de DAF / SOCORRO AUTO/R.E.
       #---------------------------------------------------------------
       if r_ctr03m02.atdsrvorg = 6 or
          r_ctr03m02.atdsrvorg = 1 then
          print column 001, "RESIDENC.: ", r_ctr03m02.atdrsdtxt,
                column 053, "ENVIAR: "   , r_ctr03m02.asitipabvdes
          if r_ctr03m02.atddfttxt is not null  then
             print column 001, "PROBLEMA.: ", r_ctr03m02.atddfttxt
          end if

          if r_ctr03m02.ntzdes is not null  then
             print column 001, "NATUREZA.: ", r_ctr03m02.ntzdes
          end if
       end if

       #---------------------------------------------------------------
       # Impressao de dados especificos de DAF / SOCORRO AUTO/R.E.
       #---------------------------------------------------------------
       if r_ctr03m02.atdsrvorg = 11  then
          if r_ctr03m02.boctxt is not null  then
             print column 001, "B.O.? ...: " , r_ctr03m02.boctxt,
                   column 025, "B.O. No...: ", r_ctr03m02.bocnum using "<<<<&",
                   column 059, "ORGAO.: "    , r_ctr03m02.bocemi
          end if

          print column 001, "OCORRENC.: ", r_ctr03m02.avsfurtxt
          skip 1 lines

          print column 001, "CHASSI/PLACA CONFEREM ?: ", r_ctr03m02.atdrsdtxt,
                column 053, "OBS...: "                 , r_ctr03m02.atddfttxt
          print column 001, "DOCTOS FORAM ROUBADOS ?: ", r_ctr03m02.atddocflg,
                column 053, "QUAIS.: "                 , r_ctr03m02.atddoctxt
          skip 2 lines
       end if

       #---------------------------------------------------------------
       # Impressao de dados especificos de ASSISTENCIA A PASSAGEIROS
       #---------------------------------------------------------------
       if r_ctr03m02.atdsrvorg = 2    then
          skip 1 line
          print column 001, "----------------------------- LISTA DE PASSAGEIROS -----------------------------"
          skip 1 line
          declare c_ctr03m02_004 cursor for
             select pasnom, pasidd
               from datmpassageiro
              where atdsrvnum = r_ctr03m02.atdsrvnum  and
                    atdsrvano = r_ctr03m02.atdsrvano

          foreach c_ctr03m02_004 into ws.pasnom,
                                        ws.pasidd
             print column 012, ws.pasnom,
                   column 061, ws.pasidd using "#&", " anos"
          end foreach
          print column 001, "--------------------------------------------------------------------------------"

          skip 1 lines
          print column 001, "MOTIVO...: "  , r_ctr03m02.asimtvdes,
                column 059, "TRANSP: "     , r_ctr03m02.asitipabvdes

          if r_ctr03m02.atddmccidnom is not null  or
             r_ctr03m02.atddmcufdcod is not null  then
             print column 001, "DOMICILIO: ", r_ctr03m02.atddmccidnom clipped, " - ", r_ctr03m02.atddmcufdcod
          end if

          print column 001, "DESTINO..: "  , r_ctr03m02.dstlclidttxt

          if (r_ctr03m02.dstlgdtxt    is not null  and
              r_ctr03m02.dstlgdtxt    <> "   "  )  or
             (r_ctr03m02.dstlclbrrnom is not null  and
              r_ctr03m02.dstlclbrrnom <> "   "  )  then
             print column 001, "ENDERECO.: "  , r_ctr03m02.dstlgdtxt
             print column 001, "BAIRRO...: "  , r_ctr03m02.dstbrrnom
          end if

          print column 001, "CIDADE...: "  , r_ctr03m02.dstcidnom,
                column 059, "UF....: "     , r_ctr03m02.dstufdcod

          if (r_ctr03m02.dstlclrefptotxt is not null  and
              r_ctr03m02.dstlclrefptotxt <> "   "  )  or
             (r_ctr03m02.dstendzon       is not null  and
              r_ctr03m02.dstendzon       <> "   "  )  then
             print column 001, "REFERENC.: "  , r_ctr03m02.dstlclrefptotxt,
                   column 059, "ZONA..: "     , r_ctr03m02.dstendzon
          end if

          if r_ctr03m02.dstdddcod    is not null  or
             r_ctr03m02.dstlcltelnum is not null  then
             print column 001, "TELEFONE.: "  , "(", r_ctr03m02.dstdddcod, ") ",
                                                r_ctr03m02.dstlcltelnum
          end if

          if r_ctr03m02.dstlclcttnom is not null  then
             print column 001, "RESPONS..: "  , r_ctr03m02.dstlclcttnom
          end if
          skip 1 line
       end if

       #---------------------------------------------------------------
       # Impressao dos dados referentes ao local de destino
       #---------------------------------------------------------------
       if r_ctr03m02.atdsrvorg <> 2    then
          if r_ctr03m02.dstlclidttxt  is not null  then
             print column 001, "DESTINO..: " , r_ctr03m02.dstlclidttxt
          end if

          if r_ctr03m02.dstcidnom  is not null  and
             r_ctr03m02.dstcidnom  <>  " "      then
             print column 001, "ENDERECO.: " , r_ctr03m02.dstlgdtxt
             print column 001, "BAIRRO...: " , r_ctr03m02.dstbrrnom
             print column 001, "CIDADE...: " , r_ctr03m02.dstcidnom,
                   column 059, "UF....: "    , r_ctr03m02.dstufdcod
             print column 001, "REFERENC.: " , r_ctr03m02.dstlclrefptotxt[1,40],
                   column 059, "ZONA..: "    , r_ctr03m02.dstendzon
             print column 001, "TELEFONE.: " , "(", r_ctr03m02.dstdddcod, ") ",
                                               r_ctr03m02.dstlcltelnum
             print column 001, "RESPONS..: " , r_ctr03m02.dstlclcttnom
          end if
       end if
       print column 001, g_traco

       #---------------------------------------------------------------
       # Impressao dos dados referentes a qtd diarias e quartos
       #---------------------------------------------------------------
       if r_ctr03m02.atdsrvorg =  03  then
          select hpddiapvsqtd,hpdqrtqtd
               into ws.qtddia,
                    ws.qtdqrt
               from datmhosped
              where atdsrvnum = r_ctr03m02.atdsrvnum
                and atdsrvano = r_ctr03m02.atdsrvano
          if sqlca.sqlcode =  0  then
             print column 001, "DIARIAS..: ", ws.qtddia using "<&"
             print column 001, "QUARTOS..: ", ws.qtdqrt using "<&"
             print column 001, g_traco
          end if
       end if
       skip 1 line

       let l_passou = false
       open c_ctr03m02_002 using r_ctr03m02.atdsrvnum, r_ctr03m02.atdsrvano
       foreach c_ctr03m02_002 into ws.vclcndlclcod

               if l_passou = false then
                  let l_passou = true
                  print column 001,"LOCAL/CONDICOES DO VEICULO"
               end if

               call ctc61m03 (1,ws.vclcndlclcod) returning ws.vclcndlcldes

               print column 007, ws.vclcndlcldes clipped

       end foreach

       if l_passou = true then
          skip 1 line
       end if

       if r_ctr03m02.atdsrvorg <> 11  then
          print column 001, "SERVICO IMED.: ", r_ctr03m02.imdsrvtxt;
          if r_ctr03m02.imdsrvtxt = "SIM"  then
             print column 025, "PREVISAO..: "  , r_ctr03m02.atdhorpvt
          else
             print column 025, "PROGRAMADO: "  , r_ctr03m02.atddatprg,
                               " AS "          , r_ctr03m02.atdhorprg
          end if

          if r_ctr03m02.atdlibflg = "S"  then
             print column 001, "LIBERADO EM ", r_ctr03m02.atdlibdat,
                                      " AS " , r_ctr03m02.atdlibhor,
                                      " POR ", r_ctr03m02.atdfunmat using "&&&&&&", " - "  , r_ctr03m02.atdfunnom,
                                  "  DEPTO: ", upshift(r_ctr03m02.atddptsgl)
          end if
          print column 001, "ATENDIDO EM ", r_ctr03m02.atddat   ,
                                   " AS " , r_ctr03m02.atdhor   ,
                                   " POR ", r_ctr03m02.atdfunmat using "&&&&&&", " - "  , r_ctr03m02.atdfunnom,
                               "  DEPTO: ", upshift(r_ctr03m02.atddptsgl)

          if r_ctr03m02.cnldat    is not null  and
             r_ctr03m02.atdprscod is not null  then
             print column 001, g_traco
             print column 017, "***  CONTROLE DE ACIONAMENTO DE PRESTADORES  ***"
             print column 001, g_traco
             print column 001, "CONCLUIDO EM ", r_ctr03m02.cnldat,
                                        " AS ", r_ctr03m02.atdfnlhor,
                                       " POR ", r_ctr03m02.cnlfunmat using "&&&&&&", " - ", r_ctr03m02.cnlfunnom,
                                    " DEPTO: ", upshift(r_ctr03m02.cnldptsgl)
             skip 1 line
             print column 001, "PRESTADOR: " , r_ctr03m02.atdprscod using "&&&&&&", " - ", r_ctr03m02.nomgrr
             print column 001, "R. SOCIAL: " , r_ctr03m02.nomrazsoc
             print column 001, "TELEFONE.: (", r_ctr03m02.pstdddcod, ") ",
                                               r_ctr03m02.pstteltxt      ,
                   column 045, "FAX.....: "  , r_ctr03m02.pstfaxnum
             print column 001, "CONTATO..: " , r_ctr03m02.c24nomctt

             #---------------------------------------------------------------
             # Se codigo do socorrista informado, ler cadastro de socorrista
             #---------------------------------------------------------------
             if r_ctr03m02.atdmotnom  is not null   and
                r_ctr03m02.atdmotnom  <>  "  "      then
                print column 001, "SOCORRIS.: " , r_ctr03m02.atdmotnom
             else
                if r_ctr03m02.srrcoddig  is not null   then
                   select srrabvnom
                     into ws.srrabvnom
                     from datksrr
                    where datksrr.srrcoddig  =  r_ctr03m02.srrcoddig

                   print column 001, "SOCORRIS.: " ,
                                     r_ctr03m02.srrcoddig  using "####&&&&",
                                     " - ", ws.srrabvnom
                end if
             end if

             #---------------------------------------------------------------
             # Se codigo do veiculo informado, ler cadastro de veiculos
             #---------------------------------------------------------------
             if r_ctr03m02.socvclcod  is null   then
                if r_ctr03m02.atdvclsgl  is not null   then
                   print column 001, "VEICULO..: " , r_ctr03m02.atdvclsgl
                end if
             else
                 select vclcoddig
                   into ws.vclcoddig
                   from datkveiculo
                  where datkveiculo.socvclcod  =  r_ctr03m02.socvclcod

                 call cts15g00(ws.vclcoddig)  returning ws.vcldes

                 print column 001, "VEICULO..: " , r_ctr03m02.atdvclsgl, " ",
                                   r_ctr03m02.socvclcod  using "###&",
                                   " - ", ws.vcldes
             end if

             skip 1 line

             if r_ctr03m02.atdcstvlr is not null  then
                print column 001, "CUSTO....: ", r_ctr03m02.atdcstvlr using "<,<<<,<<<,<<&.&&",
                      column 045, "DATA PAGT: ", r_ctr03m02.pgtdat
                skip 1 line
             end if
          end if
          print column 001, g_traco
       end if

       let ws.pagflg    = TRUE
       let ws.ligdatant = "31/12/1899"
       let ws.lighorant = "00:00"

       #---------------------------------------------------------------
       # Linhas do HISTORICO do servico
       #---------------------------------------------------------------
       declare c_ctr03m02_005 cursor for
          select ligdat   ,
                 lighorinc,
                 c24funmat,
                 c24srvdsc,
                 c24empcod                                            #Raul, Biz
            from datmservhist
           where atdsrvnum = r_ctr03m02.atdsrvnum  and
                 atdsrvano = r_ctr03m02.atdsrvano

       foreach c_ctr03m02_005 into h_ctr03m02.ligdat    ,
                                h_ctr03m02.lighorinc ,
                                h_ctr03m02.c24funmat ,
                                h_ctr03m02.c24srvdsc,
                                h_ctr03m02.c24empcod                  #Raul, Biz

          if ws.pagflg = true  then
             if g_imptip = "L"  then
                print ascii(12)
             else
                skip to top of page
             end if

             let ws.pagflg = false

             if r_ctr03m02.atdsrvorg = 11 then
                print column 020, "*****  HISTORICO DO AVISO  *****"
             else
                print column 020, "***** HISTORICO DO SERVICO *****"
             end if
             skip 1 line
          end if

          if ws.ligdatant <> h_ctr03m02.ligdat     or
             ws.lighorant <> h_ctr03m02.lighorinc  then

             select funnom into ws.funnom
               from isskfunc
              where empcod = h_ctr03m02.c24empcod                     #Raul, Biz
                and funmat = h_ctr03m02.c24funmat

             let ws.lintxt =  "EM: "   , h_ctr03m02.ligdat    clipped,
                             "  AS: " , h_ctr03m02.lighorinc clipped,
                             "  POR: ", ws.funnom            clipped
             let ws.ligdatant = h_ctr03m02.ligdat
             let ws.lighorant = h_ctr03m02.lighorinc

             skip 1 line

             print column 005,  ws.lintxt
          end if

          print column 005, h_ctr03m02.c24srvdsc
       end foreach

       if ws.pagflg = false  then
          skip 1 line
          print column 001, g_traco
       end if

       let ws.pagflg    = true
       let ws.ligdatant = "31/12/1899"
       let ws.lighorant = "00:00"

       #---------------------------------------------------------------
       # Linhas do HISTORICO da pesquisa
       #---------------------------------------------------------------
       declare c_ctr03m02_006 cursor for
         select ligdat   ,
                lighorinc,
                c24funmat,
                c24psqdsc
           from datmpesqhist
          where atdsrvnum = r_ctr03m02.atdsrvnum  and
                atdsrvano = r_ctr03m02.atdsrvano

       foreach c_ctr03m02_006 into p_ctr03m02.ligdat    ,
                                p_ctr03m02.lighorinc ,
                                p_ctr03m02.c24funmat ,
                                p_ctr03m02.c24psqdsc

          if ws.pagflg = true  then
             if g_imptip = "L"   then
                print ascii(12)
             else
                skip to top of page
             end if
             let ws.pagflg = false

             print column 026, "***** HISTORICO DA PESQUISA *****"
             skip 1 line

             declare c_ctr03m02_007  cursor for
                select avlitmcod, avlpsqnot from datrpesqaval
                 where atdsrvnum   = param.atdsrvnum    and
                       atdsrvano   = param.atdsrvano

             foreach c_ctr03m02_007 into ws.avlitmcod,
                                      ws.avlpsqnot
                case ws.avlitmcod
                     when "01"
                          print column 005,"AVALIACAO : ";
                          print column 017,"CENTRAL 24 HS....:";
                     when "02"
                          print column 017,"TEMPO DE CHEGADA.:";
                     when "03"
                          print column 017,"SERVICO..........:";
                     when "04"
                          print column 017,"OUTROS...........:";
                end case
                if ws.avlpsqnot >= 0 and
                   ws.avlpsqnot <= 6 then
                   print column 036,"NOTA ",ws.avlpsqnot using "#&",
                                    " - INSATISFACAO"
                else
                   if ws.avlpsqnot = 7 or
                      ws.avlpsqnot = 8 then
                      print column 036,"NOTA ",ws.avlpsqnot using "#&",
                                       " - MEDIA SATISFACAO"
                   else
                      if ws.avlpsqnot = 9  or
                         ws.avlpsqnot = 10 then
                         print column 036,"NOTA ",ws.avlpsqnot using "#&",
                                          " - ALTA SATISFACAO"
                      end if
                   end if
                end if
             end foreach
            skip 1 line

         end if

         if ws.ligdatant <> p_ctr03m02.ligdat     or
            ws.lighorant <> p_ctr03m02.lighorinc  then
#SELECT NA DATMSERVICO COM A CHAVE
            select funnom into ws.funnom
              from isskfunc
             where empcod = 1
               and funmat = p_ctr03m02.c24funmat

            let ws.lintxt =  "EM: "   , p_ctr03m02.ligdat    clipped,
                            "  AS: " , p_ctr03m02.lighorinc clipped,
                            "  POR: ", ws.funnom             clipped
            let ws.ligdatant = p_ctr03m02.ligdat
            let ws.lighorant = p_ctr03m02.lighorinc

            skip 1 line

            print column 005,  ws.lintxt
         end if

         print column 005, p_ctr03m02.c24psqdsc

      end foreach

      if ws.pagflg = false  then
         skip 1 line
         print column 001, g_traco
         if g_imptip = "L"   then
            print ascii(12)
         else
            skip to top of page
         end if
      end if

 end report  ###  rep_servico
