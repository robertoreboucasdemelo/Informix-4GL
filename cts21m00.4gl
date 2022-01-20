#############################################################################
# Nome do Modulo: CTS21M00                                         Marcelo  #
#                                                                  Gilberto #
# Marcacao de Vistoria - Ramos Elementares                         Nov/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  Probl.Ident  Gilberto     Corrigir retorno da funcao CTS21M04.#
#---------------------------------------------------------------------------#
# 17/03/1999  PSI 8072-1   Gilberto     Impedir preenchimento de vistorias  #
#                                       de sinistro para documentos cujo    #
#                                       ramo nao pertence ao R.E.           #
#---------------------------------------------------------------------------#
# 12/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.           #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 15/02/2000  PSI 8004-7   Wagner       Gravar grupo do ramo (sinramgrp) na #
#                                       tabela datmpedvist.                 #
#---------------------------------------------------------------------------#
# 22/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 14/02/2001               Raji         Atalho p/ visualizacao Pto Referecia#
#---------------------------------------------------------------------------#
# 18/12/2001  PSI 130257   Ruiz         Alteracao no acionamento dos        #
#                                       reguladores.                        #
#---------------------------------------------------------------------------#
# 15/08/2002  PSI 131202   Ruiz         Tratamento de novas naturezas.      #
#############################################################################
#                                                                           #
#                      * * * Alteracoes * * *                               #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 24/10/2003  Meta,Bruno     PSI168890 Chamar funcao cts12g00 com mais 3    #
#                            OSF027847 parametros.                          #
# ------------------------------------------------------------------------- #
# 10/05/2004  Cesar (FSW)    CT 207365 - Display nos campos da funcao       #
#                                      'input_cts21m00'                     #
# ------------------------------------------------------------------------- #
# 12/04/2005  Vinicius, Meta PSI191663 Inibir a mensagem de alerta: "SEMPRE #
#                                      OFERECA O REPARO EMERGENCIAL ..."    #
#---------------------------------------------------------------------------#
# 17/05/2005 Julianna,Meta    PSI191108   Implementar o codigo da via       #
#---------------------------------------------------------------------------#
# 03/02/2006 Priscila         Zeladoria   Buscar data e hora do banco       #
#---------------------------------------------------------------------------#
# 13/06/2006 Priscila         PSI200140   Inserir mais de uma cobertura     #
#                                         natureza no laudo                 #
#---------------------------------------------------------------------------#
# 18/09/2006 Priscila         PSI 199850  Atualizar ao transferir ligacao   #
#                                         para sistema RE                   #
#---------------------------------------------------------------------------#
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 25/05/2007 Roberto       CT7057362 Inclusao da funcao mail_cts21m00       #
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
# 17/04/2008 Federicce     PSI 214566 Comentario da funcao que gera servico #
#                                     de JIT                                #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#
# 20/02/2009 Nilo          Psi234311  Danos Eletricos                       #
# 13/08/2009 Sergio Burini PSI244236  Inclusão do Sub-Dairro                #
#---------------------------------------------------------------------------#
# 05/01/2010 Amilton                  Projeto sucursal smallint             #
----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo   219444 .Passar/recebr em "ctf00m08_gera_p10"  #
#                                     os parametros (lclnumseq / rmerscseq) #
#                                    .Trocar a funcao cts21m04 por framc215 #
#                                    .Trocar a funcao cts06g01 por framo240 #
#                                    .Gravar lclnumseq/rmerscseq-datmpedvist#
#---------------------------------------------------------------------------#
#02/05/2012 Silvia P, Meta PSI2012-07408 Projeto Anatel-Aumento DDD/Telefone#
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

define aux_today     char (10),
       aux_hora      char (05),
       aux_ano4      char (04),
       aux_ano2      char (02)

define g_jit record
   lclidttxt         LIKE datmlcl.lclidttxt,
   lclrefptotxt      LIKE datmlcl.lclrefptotxt,
   lclltt            LIKE datmlcl.lclltt,
   lcllgt            LIKE datmlcl.lcllgt,
   c24lclpdrcod      LIKE datmlcl.c24lclpdrcod,
   ofnnumdig         LIKE sgokofi.ofnnumdig
end record

 define hist_cts21m00      record
           hist1                LIKE datmservhist.c24srvdsc,
           hist2                LIKE datmservhist.c24srvdsc,
           hist3                LIKE datmservhist.c24srvdsc,
           hist4                LIKE datmservhist.c24srvdsc,
           hist5                LIKE datmservhist.c24srvdsc
 end record

define m_temp_RE     smallint,
       m_endbrr      char(65)

define mr_retorno   record
       coderro      smallint
      ,deserro      char(70)
      ,cidsedcod    like datrcidsed.cidsedcod
      ,cidsednom    like glakcid.cidnom
end record

define m_subbairro array[03] of record
       brrnom   like datmlcl.lclbrrnom
end record

-->  Endereco do Local de risco - RE
define mr_rsc_re    record
       lclrsccod    like rlaklocal.lclrsccod
      ,lclnumseq    like datmsrvre.lclnumseq
      ,rmerscseq    like datmsrvre.rmerscseq
      ,rmeblcdes    like rsdmbloco.rmeblcdes
      ,lclltt       like datmlcl.lclltt
      ,lcllgt       like datmlcl.lcllgt
end record

#---------------------------------------------------------------
 function cts21m00()
#---------------------------------------------------------------

 define d_cts21m00    record
    vistoria          char (10)                 ,
    vstsolnom         like datmpedvist.vstsolnom,
    segnom            like datmpedvist.segnom   ,
    doctxt            char (32)                 ,
    corsus            like gcaksusep.corsus     ,
    cornom            like datmpedvist.cornom   ,
    cvnnom            char (20)                 ,
    dddcod            like datmpedvist.dddcod   ,
    teltxt            like datmpedvist.teltxt   ,
    lclrsccod         like datmpedvist.lclrsccod,
    lclrscend         char (70)                 ,
    lclendflg         char (01)                 ,
    lgdtip            like datmpedvist.lgdtip   ,
    lgdnom            like datmpedvist.lgdnom   ,
    lgdnum            like datmpedvist.lgdnum   ,
    lgdnomcmp         like datmpedvist.lgdnomcmp,
    endbrr            like datmpedvist.endbrr   ,
    endcep            like datmpedvist.endcep   ,
    endcepcmp         like datmpedvist.endcepcmp,
    endcid            like datmpedvist.endcid   ,
    endufd            like datmpedvist.endufd   ,
    endddd            like datmpedvist.endddd   ,
    teldes            like datmpedvist.teldes   ,
    lclcttnom         like datmpedvist.lclcttnom,
    endrefpto         like datmpedvist.endrefpto,
    sindat            like datmpedvist.sindat   ,
    sinhor            like datmpedvist.sinhor   ,
    sinhst            like datmpedvist.sinhst   ,
    sinobs            like datmpedvist.sinobs   ,
    rglvstflg         like datmpedvist.rglvstflg,
    celteldddcod      like datmlcl.celteldddcod,
    celtelnum         like datmlcl.celtelnum,
    endcmp            like datmlcl.endcmp
 end record

 define ws            record
    rmemdlcod         like rsamseguro.rmemdlcod ,
    sinramgrp         like gtakram.sinramgrp    ,
    viginc            like rsdmdocto.viginc     ,
    vigfnl            like rsdmdocto.vigfnl     ,
    confirma          char (01)                 ,
    vclcoddig         like datmservico.vclcoddig,
    vcldes            like datmservico.vcldes   ,
    vclanomdl         like datmservico.vclanomdl,
    vcllicnum         like datmservico.vcllicnum,
    vclcordes         char (11)
 end record

 define l_data       date,
        l_hora2      datetime hour to minute

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2

 let int_flag  = false
 let aux_today = l_data
 let m_endbrr  = null
 let aux_hora  = l_hora2
 let aux_ano4  = aux_today[7,10]
 let aux_ano2  = aux_today[9,10]

 initialize d_cts21m00.*    to null
 initialize ws.*            to null
 initialize g_jit.*         to null
 initialize m_subbairro     to null
 initialize mr_rsc_re.*     to null

#--------------------------------------------------------------------
# Verifica se ramo pertence ao Ramos Elementares
#--------------------------------------------------------------------
 if g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    select sinramgrp
      into ws.sinramgrp
      from gtakram
     where empcod = 1
       and ramcod = g_documento.ramcod

    if ws.sinramgrp <> 4  and
       ws.sinramgrp <> 1  then
       call cts08g01("A","N","VISTORIA DE SINISTRO PARA",
                             "RAMOS ELEMENTARES E NAO PODE SER",
                             "PREENCHIDA PARA DOCUMENTO",
                             "DE OUTRO RAMO!")
            returning ws.confirma
       return
    end if
 end if

#--------------------------------------------------------------------
# Verifica ramos/modalidades nao aceitas
#--------------------------------------------------------------------
 if (g_documento.ramcod     =  71  or
     g_documento.ramcod     = 171) and
     g_documento.aplnumdig  is not null   then
    select rmemdlcod
      into ws.rmemdlcod
      from rsamseguro
     where succod    = g_documento.succod
       and ramcod    = g_documento.ramcod
       and aplnumdig = g_documento.aplnumdig

    if ws.rmemdlcod  =  232   then
       call cts08g01("A","N","","DOCUMENTO POSSUI COBERTURA APENAS",
                     "PARA PORTO RESIDENCIA!","") returning ws.confirma
       return
    end if
 end if

 open window cts21m00 at 04,02 with form "cts21m00"
             attribute (form line 1)

 let d_cts21m00.vstsolnom   = g_documento.solnom

 select cpodes into d_cts21m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = g_documento.ligcvntip

 if g_documento.succod    is not null and
    g_documento.aplnumdig is not null and
    g_documento.c24astcod = "V12" then
    call cts05g01(g_documento.succod   ,
                  g_documento.ramcod   ,
                  g_documento.aplnumdig)
        returning d_cts21m00.segnom    ,
                  d_cts21m00.cornom    ,
                  d_cts21m00.corsus    ,
                  d_cts21m00.cvnnom    ,
                  ws.viginc            ,
                  ws.vigfnl

    call cts09g00(g_documento.ramcod,
                  g_documento.succod,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig,
                  false)
        returning d_cts21m00.dddcod,
                  d_cts21m00.teltxt

    let d_cts21m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                     " ", g_documento.ramcod    using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then

    call figrc072_setTratarIsolamento()        --> 223689

       call cts05g04 (g_documento.prporg   ,
                      g_documento.prpnumdig)
            returning d_cts21m00.segnom   ,
                      d_cts21m00.corsus   ,
                      d_cts21m00.cornom   ,
                      d_cts21m00.cvnnom   ,
                      ws.vclcoddig,
                      ws.vcldes   ,
                      ws.vclanomdl,
                      ws.vcllicnum,
                      ws.vclcordes

         if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Função cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
            return
         end if    --> 223689



    let d_cts21m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                   " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 ---> Se houver conteudo a apolice eh do RE
 if g_rsc_re.lclrsccod is not null and
    g_rsc_re.lclrsccod <> 0       then

    let d_cts21m00.lclrsccod = g_rsc_re.lclrsccod
    let mr_rsc_re.lclrsccod  = g_rsc_re.lclrsccod
    let d_cts21m00.lgdtip    = g_rsc_re.lgdtip
    let d_cts21m00.lgdnom    = g_rsc_re.lgdnom
    let d_cts21m00.lgdnum    = g_rsc_re.lgdnum
    let d_cts21m00.endbrr    = g_rsc_re.lclbrrnom
    let d_cts21m00.endcid    = g_rsc_re.cidnom
    let d_cts21m00.endufd    = g_rsc_re.ufdcod
    let d_cts21m00.endcep    = g_rsc_re.lgdcep
    let d_cts21m00.endcepcmp = g_rsc_re.lgdcepcmp
    let mr_rsc_re.lclltt     = g_rsc_re.lclltt
    let mr_rsc_re.lcllgt     = g_rsc_re.lcllgt
 end if

 display by name d_cts21m00.vstsolnom attribute (reverse)
 display by name d_cts21m00.segnom
 display by name d_cts21m00.doctxt
 display by name d_cts21m00.corsus
 display by name d_cts21m00.cornom
 display by name d_cts21m00.lclrsccod
 display by name d_cts21m00.cvnnom    attribute (reverse)

 call inclui_cts21m00(d_cts21m00.*, ws.viginc, ws.vigfnl)

 close window cts21m00

end function  ###  cts21m00

#---------------------------------------------------------------
 function inclui_cts21m00(d_cts21m00)
#---------------------------------------------------------------

 define d_cts21m00    record
    vistoria          char (10)                 ,
    vstsolnom         like datmpedvist.vstsolnom,
    segnom            like datmpedvist.segnom   ,
    doctxt            char (27)                 ,
    corsus            like gcaksusep.corsus     ,
    cornom            like datmpedvist.cornom   ,
    cvnnom            char (20)                 ,
    dddcod            like datmpedvist.dddcod   ,
    teltxt            like datmpedvist.teltxt   ,
    lclrsccod         like datmpedvist.lclrsccod,
    lclrscend         char (70)                 ,
    lclendflg         char (01)                 ,
    lgdtip            like datmpedvist.lgdtip   ,
    lgdnom            like datmpedvist.lgdnom   ,
    lgdnum            like datmpedvist.lgdnum   ,
    lgdnomcmp         like datmpedvist.lgdnomcmp,
    endbrr            like datmpedvist.endbrr   ,
    endcep            like datmpedvist.endcep   ,
    endcepcmp         like datmpedvist.endcepcmp,
    endcid            like datmpedvist.endcid   ,
    endufd            like datmpedvist.endufd   ,
    endddd            like datmpedvist.endddd   ,
    teldes            like datmpedvist.teldes   ,
    lclcttnom         like datmpedvist.lclcttnom,
    endrefpto         like datmpedvist.endrefpto,
    sindat            like datmpedvist.sindat   ,
    sinhor            like datmpedvist.sinhor   ,
    sinhst            like datmpedvist.sinhst   ,
    sinobs            like datmpedvist.sinobs   ,
    rglvstflg         like datmpedvist.rglvstflg,
    viginc            like rsdmdocto.viginc     ,
    vigfnl            like rsdmdocto.vigfnl     ,
    celteldddcod      like datmlcl.celteldddcod ,
    celtelnum         like datmlcl.celtelnum,
    endcmp            like datmlcl.endcmp
 end record

 define ws            record
    prompt_key        char(01)                    ,
    retorno           smallint                    ,
    lignum            like datmligacao.lignum     ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    codigosql         integer                     ,
    tabname           like systables.tabname      ,
    msg               char(80)                    ,
    sinramgrp         like gtakram.sinramgrp      ,
    confirma          char (01)                   ,
    dtplantao         char (10)                   ,
    hora              like sgkmpdoperplt.atlhor   ,
    sinpricod         like sgkmpdoperplt.sinpricod,
    lclbrrnom         LIKE datmlcl.lclbrrnom      ,
    endzon            LIKE datmlcl.endzon         ,
    monta_sql         char (2000)                 ,
    sisemscod         like gabkorigem.sisemscod   ,
    tel_comp_sms      char(14)                    , ## Anatel -- char(10)                    ,
    ddd_sms           char(04)                    , ## Anatel -- char(02)                    ,
    tel_sms           char(10)                      ## Anatel -- char(08)
 end RECORD

 define retorno record
    data              like sgkmpdoperplt.atldat,
    hora              like sgkmpdoperplt.atlhor
 end record

 ---> Danos Eletricos
 define param_danos   record
         c24astcod     like datkassunto.c24astcod
        ,atdsrvorg     like datksrvtip.atdsrvorg
        ,atdsrvnum     like datmservico.atdsrvnum
        ,atdsrvano     like datmservico.atdsrvano
        ,srvnum        char (13)
	,atddat        like datmservico.atddat
	,atdhor        like datmservico.atdhor
	,funmat        like datmservico.funmat
        ,frmflg        char (01)
        ,atdfnlflg     like datmservico.atdfnlflg
        ,acao_origem   char(03)
        ,prslocflg     char (01)
        ,operacao      char (01)
        ,lclidttxt     like datmlcl.lclidttxt
        ,lgdtxt        char (65)
        ,lgdtip        like datmlcl.lgdtip
        ,lgdnom        like datmlcl.lgdnom
        ,lgdnum        like datmlcl.lgdnum
        ,brrnom        like datmlcl.brrnom
        ,lclbrrnom     like datmlcl.lclbrrnom
        ,endzon        like datmlcl.endzon
        ,cidnom        like datmlcl.cidnom
        ,ufdcod        like datmlcl.ufdcod
        ,lgdcep        like datmlcl.lgdcep
        ,lgdcepcmp     like datmlcl.lgdcepcmp
        ,lclltt        like datmlcl.lclltt
        ,lcllgt        like datmlcl.lcllgt
        ,dddcod        like datmlcl.dddcod
        ,lcltelnum     like datmlcl.lcltelnum
        ,lclcttnom     like datmlcl.lclcttnom
        ,lclrefptotxt  like datmlcl.lclrefptotxt
        ,c24lclpdrcod  like datmlcl.c24lclpdrcod
        ,ofnnumdig     like sgokofi.ofnnumdig
        ,emeviacod     like datmemeviadpt.emeviacod
        ,celteldddcod  like datmlcl.celteldddcod
        ,celtelnum     like datmlcl.celtelnum
        ,endcmp        like datmlcl.endcmp
        ,atdetpcod     like datmsrvacp.atdetpcod
        ,atdlibflg     like datmservico.atdlibflg
        ,srrcoddig     like datmsrvacp.srrcoddig
        ,cnldat        like datmservico.cnldat
        ,atdfnlhor     like datmservico.atdfnlhor
        ,c24opemat     like datmservico.c24opemat
        ,atdprscod     like datmservico.atdprscod
        ,c24nomctt     like datmservico.c24nomctt
        ,lclrsccod     like datmsrvre.lclrsccod
        ,orrdat        like datmsrvre.orrdat
        ,orrhor        like datmsrvre.orrhor
        ,sinntzcod     like datmsrvre.sinntzcod   ---> Natureza Sinistro!!!!
        ,socntzcod     like datmsrvre.socntzcod   ---> Natureza P.Socorro!!!!
        ,lclnumseq     like datmsrvre.lclnumseq
        ,rmerscseq     like datmsrvre.rmerscseq
        ,sinvstnum     like datmpedvist.sinvstnum
        ,sinvstano     like datmpedvist.sinvstano
        ,atdorgsrvnum  like datmsrvre.atdorgsrvnum
        ,atdorgsrvano  like datmsrvre.atdorgsrvano
        ,srvretmtvcod  like datmsrvre.srvretmtvcod
        ,srvretmtvdes  like datksrvret.srvretmtvdes
        ,c24pbmcod     like datkpbm.c24pbmcod
        ,atddfttxt     like datmservico.atddfttxt
        ,nom           like datmservico.nom
        ,corsus        like datmservico.corsus
        ,cornom        like datmservico.cornom
        ,asitipcod     like datmservico.asitipcod
        ,atdprinvlcod  like datmservico.atdprinvlcod
        ,imdsrvflg     char (01)
        ,atdlibhor     like datmservico.atdlibhor
        ,atdlibdat     like datmservico.atdlibdat
        ,atdhorpvt     like datmservico.atdhorpvt
        ,atdhorprg     like datmservico.atdhorprg
        ,atddatprg     like datmservico.atddatprg
        ,atdpvtretflg  like datmservico.atdpvtretflg
        ,socvclcod     like datmservico.socvclcod
 end record

 define aux_grlchv    like igbkgeral.grlchv     ,
        aux_grlinf    like igbkgeral.grlinf     ,
        aux_sinvstnum like datmpedvist.sinvstnum,
        aux_vistoria  char (10)                 ,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano

 define w_message     char(500)
 define w_run         char(500)
 define l_emeviacod   like datkemevia.emeviacod

 define prompt_key    char (01)

  define  l_data         date,
          l_hora2        datetime hour to minute,
          l_hora1        datetime hour to second

 #PSI200140
  define  l_cbttip      like datrpedvistnatcob.cbttip,
          l_sinntzcod   like datrpedvistnatcob.sinntzcod,
          l_orcvlr      like datrpedvistnatcob.orcvlr,

          ---> Danos Eletricos
          l_socntzcod   smallint,
          l_socntzdes   char(40),
          l_hora_current datetime hour to minute,
          l_retorno     smallint,
          l_i           smallint,
          l_count       smallint,
          l_dif_p10     smallint



  #PSI 199850
  define  l_transfere like sremligsnc.sncinftxt

  define lr_aux record
          resultado    smallint
         ,mensagem     char(60)
         ,c24soltipdes like datksoltip.c24soltipdes
  end record

  define aux_serv_prg  char(01)

        let     aux_grlchv  =  null
        let     aux_grlinf  =  null
        let     aux_sinvstnum  =  null
        let     aux_vistoria  =  null
        let     aux_atdsrvnum  =  null
        let     aux_atdsrvano  =  null
        let     prompt_key  =  null
        let     l_cbttip    = null
        let     l_sinntzcod = null
        let     l_orcvlr    = null
        let     l_transfere = null

        ---> Danos Eletricos
        let     l_socntzcod = null
        let     l_socntzdes = null
        let     l_retorno   = null
        let     l_i         = null
        let     l_count     = null
        let     l_hora_current = null
        let     l_dif_p10      = null
        let     aux_serv_prg   = null



        initialize  ws.*       to  null
        initialize  lr_aux.*   to null
        initialize  retorno.*  to  null
        initialize  mr_retorno.*  to  null

 let aux_vistoria = ""
 initialize param_danos.*  to null

 call input_cts21m00(d_cts21m00.*) returning d_cts21m00.*

 if int_flag then
    let int_flag = false
    initialize d_cts21m00.*  to null
    error " Operacao cancelada!"
    clear form
    return
 end if

 if aux_today > "31/12/1998"     and
    aux_today < "16/01/1999"     then
    if d_cts21m00.sindat < "01/01/1999"  then
       let aux_ano2 = 98
       let aux_ano4 = "1998"
    end if
 end if
 #------------------------------------------------------------------------------
 # Busca numeracao
 #------------------------------------------------------------------------------
 begin work

 call cts10g03_numeracao( 1, "" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

 if  ws.codigosql = 0  then
     commit work
 else
     let ws.msg = "CTS21M00 - ",ws.msg
     call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
     rollback work
     prompt "" for char ws.prompt_key
     return
 end if
 let g_documento.lignum = ws.lignum

 if g_documento.ramcod is not null then
    select sinramgrp
      into ws.sinramgrp                 # Grupo do ramo
      from gtakram
     where empcod = 1
       and ramcod = g_documento.ramcod
 end if

 let aux_grlchv = aux_ano2,"VSTSINRE"
#---------------------------------------------------------------
# Obtencao do numero da ultima vistoria de sinistro de R.E.
#---------------------------------------------------------------

 whenever error continue

 declare c_cts21m00_001 cursor with hold for
         select grlinf [1,6]
           from igbkgeral
          where mducod = "C24"      and
                grlchv = aux_grlchv
            for update

 foreach c_cts21m00_001 into aux_vistoria
    exit foreach
 end foreach

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 if aux_vistoria is null then

    let aux_grlinf    = 400000             -- 700000 PSI 189685
    let aux_sinvstnum = 400000             -- 700000 PSI 189685

    begin work

    insert into igbkgeral ( mducod , grlinf ,
                            grlchv , atlult )
                  values  ( "C24"      ,
                            aux_grlinf ,
                            aux_grlchv ,
                            l_data      )

    if sqlca.sqlcode <> 0 then
       error " Erro (", sqlca.sqlcode, ") na criacao do numero de vistoria.",
             " AVISE A INFORMATICA!"
       rollback work
       return
    end if
 else
    begin work

    declare c_cts21m00_002 cursor for
       select grlinf [1,6]
         from igbkgeral
        where mducod = "C24"      and
              grlchv = aux_grlchv
          for update

    foreach c_cts21m00_002  into aux_vistoria
       let aux_sinvstnum = aux_vistoria[1,6]
       let aux_sinvstnum = aux_sinvstnum + 1
       if aux_ano2 <> "04" then
          if aux_sinvstnum  > 499999 then      -- 749999 PSI 189685
             error " Faixa de vistoria de sinistro para R.E. esgotada. AVISE A INFORMATICA!"
             rollback work
             return
          end if
       else
          if aux_sinvstnum  > 749999 then      -- 749999 PSI 189685
             error " Faixa de vistoria de sinistro para R.E. esgotada. AVISE A INFORMATICA!"
             rollback work
             return
          end if
       end if
       update igbkgeral
          set (grlinf       , atlult) =
              (aux_sinvstnum, l_data)
        where mducod = "C24"
          and grlchv = aux_grlchv

       if sqlca.sqlcode <>  0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao da ultima vistoria",
                " de sinistro de R.E. AVISE A INFORMATICA!"
          rollback work
          return
       end if
    end foreach
 end if

#---------------------------------------------------------------
# Grava tabela de pedido de vistoria de sinistro
#---------------------------------------------------------------

 call cts10g00_ligacao ( g_documento.lignum,
                         aux_today,
                         aux_hora,
                         g_documento.c24soltipcod,
                         g_documento.solnom,
                         g_documento.c24astcod,
                         g_issk.funmat,
                         g_documento.ligcvntip,
                         g_c24paxnum,
                         "",""        ,
                         aux_sinvstnum,
                         aux_ano4,
                         "","",
                         g_documento.succod,
                         g_documento.ramcod,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig,
                         g_documento.edsnumref,
                         g_documento.prporg,
                         g_documento.prpnumdig,
                         g_documento.fcapacorg,
                         g_documento.fcapacnum,
                         "","","","",
                         "", "", "", "" )
               returning ws.tabname, ws.codigosql

 if ws.codigosql  <>  0  then
    error " Erro (", ws.codigosql, ") na gravacao da tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
    rollback work
    return
 end if

 if g_documento.aplnumdig is null then
    if ws.sinramgrp is not null   and
       ws.sinramgrp <> 4          then
       let ws.sinramgrp = 4
    end if
 end if

  #Roberto - CT7057362

 if g_documento.soltip is null or
    g_documento.soltip = " "   then

     call cto00m00_nome_solicitante(g_documento.c24soltipcod,"")

         returning lr_aux.resultado
                  ,lr_aux.mensagem
                  ,lr_aux.c24soltipdes

    if g_documento.c24soltipcod < 3 then
       let g_documento.soltip = lr_aux.c24soltipdes[1,1]
    else
       let g_documento.soltip = "O"
    end if

 end if
 # Roberto - fim

 #PSI 200140
 #os campos sinramgrp e sinntzcod nao devem mais serem gravados na datmpedvist
 #mas como nao aceitam nulo por enquanto iremos gravar zero
 #esses campos sao registrados na tabela datrpedvistnatcob agora.
 #no momento de limpeza de tabela onde todos os registros tem registro em
 # datrpedvistnatcob iremos dropar os campos sinramgrp, sinntzcod e orcvlr
 # da tabela datmpedvist
 #Durante homologacao em 20/07/06:
 #Conforme necessidade do RE e como nao foi previsto nesse projeto alteracoes
 # devido a inutilizacao do campo sinramgrp - por enquanto continuaremos
 # gravando o ramo da natureza em datmpedvist

 insert into datmpedvist ( sinvstnum,
                           sinvstano,
                           vstsolnom,
                           vstsoltip,
                           vstsoltipcod,
                           sindat   ,
                           sinhor   ,
                           segnom   ,
                           cornom   ,
                           dddcod   ,
                           teltxt   ,
                           funmat   ,
                           sinntzcod,
                           lclrsccod,
                           lclendflg,
                           lgdtip   ,
                           lgdnom   ,
                           lgdnum   ,
                           endufd   ,
                           lgdnomcmp,
                           endbrr   ,
                           endcid   ,
                           endcep   ,
                           endcepcmp,
                           endddd   ,
                           teldes   ,
                           lclcttnom,
                           endrefpto,
                           sinhst   ,
                           sinobs   ,
                           vstsolstt,
                           sinvstdat,
                           sinvsthor,
                           rglvstflg,
                           sinramgrp,
                           lclnumseq,
                           rmerscseq)
                values ( aux_sinvstnum        ,
                         aux_ano4             ,
                         g_documento.solnom   ,
                         g_documento.soltip   ,
                         g_documento.c24soltipcod,
                         d_cts21m00.sindat    ,
                         d_cts21m00.sinhor    ,
                         d_cts21m00.segnom    ,
                         d_cts21m00.cornom    ,
                         d_cts21m00.dddcod    ,
                         d_cts21m00.teltxt    ,
                         g_issk.funmat        ,
                         0                    ,
                         d_cts21m00.lclrsccod ,
                         d_cts21m00.lclendflg ,
                         d_cts21m00.lgdtip    ,
                         d_cts21m00.lgdnom    ,
                         d_cts21m00.lgdnum    ,
                         d_cts21m00.endufd    ,
                         d_cts21m00.lgdnomcmp ,
                         d_cts21m00.endbrr    ,
                         d_cts21m00.endcid    ,
                         d_cts21m00.endcep    ,
                         d_cts21m00.endcepcmp ,
                         d_cts21m00.endddd    ,
                         d_cts21m00.teldes    ,
                         d_cts21m00.lclcttnom ,
                         d_cts21m00.endrefpto ,
                         d_cts21m00.sinhst    ,
                         d_cts21m00.sinobs    ,
                         1                    ,
                         aux_today            ,
                         aux_hora             ,
                         d_cts21m00.rglvstflg ,
                         ws.sinramgrp         ,
                         g_documento.lclnumseq,
                         g_documento.rmerscseq)

 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na inclusao do pedido de vistoria",
          " de sinistro. AVISE A INFORMATICA!"
    rollback work

    #Roberto - CT7057362
    call mail_cts21m00(aux_sinvstnum       ,
                       aux_ano4            ,
                       g_documento.solnom  ,
                       g_documento.soltip  ,
                       d_cts21m00.segnom   ,
                       g_issk.funmat       ,
                       aux_today           ,
                       ws.sinramgrp        )
    #Fim Roberto
    return
 end if

 #---------------------------------------------------------------------------
 # Grava cobertura/natureza       #PSI200140
 #--------------------------------------------------------------------------
 #Ler registros da tabela temporária (RE)

 declare c_cts21m00_003 cursor for
 select cbttip, sinntzcod, sinrclvlr
  from temp_fsrec770
 foreach c_cts21m00_003 into l_cbttip,
                     l_sinntzcod,
                     l_orcvlr

     #gravar na tabela de cobertura/natureza
     insert into datrpedvistnatcob (sinvstnum,
                                    sinvstano,
                                    cbttip,
                                    sinramgrp,
                                    sinntzcod,
                                    orcvlr)
                 values (aux_sinvstnum,
                         aux_ano4     ,
                         l_cbttip     ,
                         ws.sinramgrp,
                         l_sinntzcod  ,
                         l_orcvlr     )
     if sqlca.sqlcode <> 0 then
        error " Erro (", sqlca.sqlcode, ") na inclusao da natureza do pedido de vistoria",
              " de sinistro. AVISE A INFORMATICA!"
        rollback work
        return
     end if
 end foreach

#--------------------------------------------------------------------
# Grava dados da ligacao
#--------------------------------------------------------------------

 if g_documento.succod    is not null   and
    g_documento.aplnumdig is not null   then
    call osrea140 (1,                      ###  Codigo da Central
                   3,                      ###  Tipo Documento: Apolice
                   g_documento.aplnumdig,
                   g_documento.succod,
                   g_documento.ramcod,
                   6936,                   ###  Matricula ROSIMEIRE SILVA
                   5178,                   ###  Ramal para contato
                   aux_ano4,               ###  Ano Vistoria Sinistro R.E.
                   aux_sinvstnum,          ###  Numero Vistoria Sinistro R.E.
                   aux_today,
                   1)                      ###  Codigo da Empresa
         returning ws.codigosql

    if ws.codigosql <> 0  then
       error " Erro (", ws.codigosql, ") na interface CEDOC x Sinistro de R.E.",
             " AVISE A INFORMATICA!"
       rollback work
       return
    end if
 end if

 let d_cts21m00.endbrr = m_subbairro[1].brrnom

 call cts06g07_local("I",
                     aux_sinvstnum,
                     aux_ano2,
                     1,
                     g_jit.lclidttxt,
                     d_cts21m00.lgdtip,
                     d_cts21m00.lgdnom,
                     d_cts21m00.lgdnum,
                     ws.lclbrrnom,
                     d_cts21m00.endbrr,
                     d_cts21m00.endcid,
                     d_cts21m00.endufd,
                     g_jit.lclrefptotxt,
                     ws.endzon,
                     d_cts21m00.endcep,
                     d_cts21m00.endcepcmp,
                     g_jit.lclltt,
                     g_jit.lcllgt,
                     d_cts21m00.dddcod,
                     d_cts21m00.teltxt,
                     d_cts21m00.lclcttnom,
                     g_jit.c24lclpdrcod,
                     g_jit.ofnnumdig,
                     l_emeviacod,
                     d_cts21m00.celteldddcod,
                     d_cts21m00.celtelnum,
                     d_cts21m00.endcmp)
 returning ws.codigosql
 commit work

 ---> Danos Eletricos
 select count(*) into l_count from tmp_natureza_mlt

 if mr_retorno.cidsednom = 'SAO PAULO' and
    l_count              > 0           then

    let param_danos.c24astcod    = "P10"
    let param_danos.atdfnlflg    = "N"
    let param_danos.atdsrvorg    = 13
    let param_danos.operacao     = "I"
    let param_danos.atdlibflg    = "S"
    let param_danos.asitipcod    = 6
    let param_danos.atdprinvlcod = 2
    let param_danos.atdsrvnum    = ws.atdsrvnum
    let param_danos.atdsrvano    = ws.atdsrvano
    let param_danos.atddat       = l_data
    let param_danos.atdhor       = l_hora2
    let param_danos.funmat       = g_issk.funmat
    let param_danos.operacao     = "I"
    let param_danos.lclidttxt    = g_jit.lclidttxt
    let param_danos.lgdtip       = d_cts21m00.lgdtip
    let param_danos.lgdnom       = d_cts21m00.lgdnom
    let param_danos.lgdnum       = d_cts21m00.lgdnum
    let param_danos.brrnom       = d_cts21m00.endbrr
    let param_danos.lclbrrnom    = ws.lclbrrnom
    let param_danos.endzon       = ws.endzon
    let param_danos.cidnom       = d_cts21m00.endcid
    let param_danos.ufdcod       = d_cts21m00.endufd
    let param_danos.lgdcep       = d_cts21m00.endcep
    let param_danos.lgdcepcmp    = d_cts21m00.endcepcmp
    let param_danos.lclltt       = g_jit.lclltt
    let param_danos.lcllgt       = g_jit.lcllgt
    let param_danos.dddcod       = d_cts21m00.dddcod
    let param_danos.lcltelnum    = d_cts21m00.teltxt
    let param_danos.lclcttnom    = d_cts21m00.lclcttnom
    let param_danos.lclrefptotxt = g_jit.lclrefptotxt ---> d_cts21m00.endrefpto
    let param_danos.c24lclpdrcod = g_jit.c24lclpdrcod
    let param_danos.ofnnumdig    = g_jit.ofnnumdig
    let param_danos.emeviacod    = l_emeviacod
    let param_danos.lclrsccod    = d_cts21m00.lclrsccod
    let param_danos.orrdat       = d_cts21m00.sindat
    let param_danos.orrhor       = d_cts21m00.sinhor
    let param_danos.lclnumseq    = g_documento.lclnumseq
    let param_danos.rmerscseq    = g_documento.rmerscseq
    let param_danos.sinvstnum    = aux_sinvstnum
    let param_danos.sinvstano    = aux_ano4
    let param_danos.nom          = d_cts21m00.segnom
    let param_danos.corsus       = d_cts21m00.corsus
    let param_danos.cornom       = d_cts21m00.cornom
    let param_danos.atdlibhor    = l_hora2
    let param_danos.atdlibdat    = l_data
    let param_danos.sinntzcod    = 5
    let param_danos.c24pbmcod    = 352
    let param_danos.atddfttxt    = 'SINISTRO RE - LEVA E TRAZ'


    let g_documento.sinvstnum    = param_danos.sinvstnum
    let g_documento.sinvstano    = param_danos.sinvstano

    let hist_cts21m00.hist1 = 'GERACAO AUTOMATICA DE P10. REFERENTE AO SINISTRO: ' ,aux_sinvstnum,'/',aux_ano4

    let l_hora_current = current

    if l_hora_current >= "09:00" and
       l_hora_current <= "18:00" then
       let param_danos.imdsrvflg    = "S"
       let param_danos.atdhorpvt    = "02:00"
       let aux_serv_prg = 'N'
    else

       let param_danos.imdsrvflg    = "N"

       if l_hora_current >= "06:00" and
          l_hora_current <  "09:00" then
          call dias_uteis(l_data,0,"","S","N")
               returning param_danos.atddatprg

          if param_danos.atddatprg = l_data then
             let param_danos.atdhorprg = l_hora_current + 3 units hour
             let aux_serv_prg = 'H' ---> Programado pra Hoje hora atual + 3 h.
          else
             let param_danos.atdhorprg = "09:00"
             let aux_serv_prg = 'S' ---> Programado prx. dia util primeira hora
          end if
       else
          if l_hora_current > "18:00" then
             call dias_uteis(l_data,+1,"","S","N")
                  returning param_danos.atddatprg

             let param_danos.atdhorprg = "09:00"
             let aux_serv_prg = 'S' ---> Programado prx. dia util primeira hora
          else
             call dias_uteis(l_data,0,"","S","N")
                  returning param_danos.atddatprg

             let param_danos.atdhorprg = "09:00"
             let aux_serv_prg = 'S' ---> Programado prx. dia util primeira hora
          end if
       end if
    end if

    let param_danos.atdpvtretflg = "N"

    let l_socntzcod = null
    let l_socntzdes = null
    let l_i = 0

    set isolation to dirty read

    declare i_temp_mlt_ntz cursor with hold for
    select unique socntzcod
          ,socntzdes
     from tmp_natureza_mlt
     --for update

    let l_i = 0
    let l_dif_p10 = null

    foreach i_temp_mlt_ntz into l_socntzcod,
                                l_socntzdes

       let l_i = l_i + 1

       let param_danos.socntzcod = l_socntzcod
       let param_danos.atdetpcod = null
       let l_retorno             = null

       call ctf00m08_gera_p10(param_danos.*,hist_cts21m00.*)
            returning l_retorno
                     ,param_danos.*

       if l_retorno = false then
          if l_i = 1 then
             error " Problema na Geracao Automatica do(s) P10(s). Favor gera-lo(s) Manualmente."
             prompt "" for char prompt_key
             exit foreach
          else
             error " Problema na Geracao Automatica do(s) P10(s). Favor gera-lo(s) Manualmente. <ENTER> "
             prompt "" for char prompt_key

             let l_dif_p10 = l_count - l_i using "<&&"

             error " Apenas ", l_dif_p10 clipped ," P10 de " ,l_count clipped ," foi Gerado. <ENTER> "
             prompt "" for char prompt_key

             exit foreach
          end if
       end if

       if l_i = l_count then
          exit foreach
       end if

    end foreach

    if aux_serv_prg = 'S' or
       aux_serv_prg = 'H' then
       error "Servico agendado para o proximo dia util, no primeiro horario." sleep 2
    else
       if aux_serv_prg = 'N' then
          #error "Servico Imediato." sleep 2
       end if
    end if

 end if

 if (g_documento.ramcod =  31  or
     g_documento.ramcod = 531  or
     g_documento.ramcod =  53  or
     g_documento.ramcod = 553) and
     g_documento.c24astcod = "V12" then
     initialize ws.sisemscod to null
     if g_documento.succod    is not null and
        g_documento.aplnumdig is not null then
        let ws.sisemscod = "AUTO "
     end if
     ---------------[ verifica se a proposta e de auto ]-------------
     if g_documento.prporg    is not null  and
        g_documento.prpnumdig is not null  then
        select sisemscod
            into ws.sisemscod
            from gabkorigem
           where prporg = g_documento.prporg
        if sqlca.sqlcode <> 0 and
           ws.sisemscod  <> "AUTO " then
           initialize ws.sisemscod to null
        end if
     end if
 end if

 let g_documento.acao = "AAA" # forca historico na abertura do laudo.

 if g_documento.ramcod =  31 or
    g_documento.ramcod = 531 then
    initialize aux_atdsrvnum, aux_atdsrvano to null
    select atdsrvnum, atdsrvano
      into aux_atdsrvnum, aux_atdsrvano
      from datmsrvjit
     where refatdsrvnum = aux_sinvstnum
       and refatdsrvano = aux_ano2
 end if
 if  aux_atdsrvnum is not null then
     let d_cts21m00.vistoria = aux_atdsrvnum using "&&&&&&&",
                          "-", aux_atdsrvano using "&&"
     display d_cts21m00.vistoria to vistoria attribute (reverse)
     error  " Verifique o numero do servico JIT-RE e tecle ENTER!"
     prompt "" for char prompt_key
     call cts10n00(aux_atdsrvnum,aux_ano2, g_issk.funmat,
                   aux_today,aux_hora)
     error "Servico JIT-RE efetuado com sucesso!"
 else    #---- nao gerou jit, considera o aviso de sinistro.
     call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
     let ws.hora   = l_hora2
     call fsrea200_valida_plantao(aux_today, ws.hora )
          returning ws.dtplantao

     if ws.dtplantao is not null then
        let d_cts21m00.rglvstflg = "S"
        call fsrea200_seleciona_regulador(ws.dtplantao,"")
                    returning ws.sinpricod,ws.tel_comp_sms

        let ws.ddd_sms = ws.tel_comp_sms[1,4]   ## Anatel - [1,2]
        let ws.tel_sms = ws.tel_comp_sms[5,14]  ## Anatel - [3,10]

        call cts40g03_data_hora_banco(1)
             returning l_data, l_hora1
        let ws.hora = l_hora1
        call fsrea200_atualiza_horario(ws.dtplantao,ws.sinpricod,ws.hora,l_data)
                    returning retorno.data,retorno.hora
     end if
     update datmpedvist
          set rglvstflg = d_cts21m00.rglvstflg
        where sinvstnum = aux_sinvstnum
          and sinvstano = aux_ano4

     let d_cts21m00.vistoria = F_FUNDIGIT_INTTOSTR(aux_sinvstnum,6),
                          "-", F_FUNDIGIT_INTTOSTR(aux_ano2     ,2)
     display d_cts21m00.vistoria to vistoria attribute (reverse)
     error  " Verifique o numero da vistoria sinistro e tecle ENTER!"
     prompt "" for char prompt_key

     call cts14m10(aux_sinvstnum,aux_ano4, g_issk.funmat,
                   aux_today,aux_hora)
     error "Marcacao efetuada com sucesso!"
 end if

 #PSI 199850 - sincronizar ligação com sistema RE - antes de registrar historico
 #montar chave para transferir ligacao
 let l_transfere = "SINRE",                      #chave para RE
               ";","V12",                        #assunto para V12
               ";",aux_ano4,                     #ano vistoria
               ";",aux_sinvstnum,                #numero vistoria
               ";",g_documento.succod,           #sucursal
               ";",g_documento.ramcod,           #ramo
               ";",g_documento.aplnumdig,        #apolice
               ";",g_documento.c24soltipcod,     #tipo solicitante
               ";",g_documento.solnom,           #nome solicitante
               ";"

 begin work
 if cts39g00_transfere_ligacao(g_c24paxnum,               #PA do atendente
                               l_transfere) then          #chave para transferencia
    #atualizou tabela do sincronismo para transferencia da ligação
    commit work
 else
    rollback work
 end if

 whenever error stop

 if d_cts21m00.rglvstflg = "S"  then
    if cts21m07( aux_sinvstnum,            # numero servico
                 aux_ano4,                 # ano servico
                 ws.sinpricod,             #.. regulador
                 "",                       # regulador antigo
                 ws.dtplantao,             # data de plantao
                 "",                       # motivo
                 retorno.data,             # data do regulador
                 retorno.hora,             # hora do regulador
                 ws.ddd_sms  ,             # ddd sms
                 ws.tel_sms) = false then  # telefone sms
       call cts08g01("A","N","","NAO FOI POSSIVEL ACIONAR O REGULADOR ",
                     "VIA SMS ATRAVES DO SISTEMA!","") returning ws.confirma
    end if
 end if

end function  ###  inclui_cts21m00

#---------------------------------------------------------------
 function input_cts21m00(d_cts21m00, w_viginc, w_vigfnl)
#---------------------------------------------------------------

 define d_cts21m00    record
    vistoria          char (09)                 ,
    vstsolnom         like datmpedvist.vstsolnom,
    segnom            like datmpedvist.segnom   ,
    doctxt            char (27),
    corsus            like gcaksusep.corsus     ,
    cornom            like datmpedvist.cornom   ,
    cvnnom            char (20)                 ,
    dddcod            like datmpedvist.dddcod   ,
    teltxt            like datmpedvist.teltxt   ,
    lclrsccod         like datmpedvist.lclrsccod,
    lclrscend         char (70)                 ,
    lclendflg         char (01)                 ,
    lgdtip            like datmpedvist.lgdtip   ,
    lgdnom            like datmpedvist.lgdnom   ,
    lgdnum            like datmpedvist.lgdnum   ,
    lgdnomcmp         like datmpedvist.lgdnomcmp,
    endbrr            like datmpedvist.endbrr   ,
    endcep            like datmpedvist.endcep   ,
    endcepcmp         like datmpedvist.endcepcmp,
    endcid            like datmpedvist.endcid   ,
    endufd            like datmpedvist.endufd   ,
    endddd            like datmpedvist.endddd   ,
    teldes            like datmpedvist.teldes   ,
    lclcttnom         like datmpedvist.lclcttnom,
    endrefpto         like datmpedvist.endrefpto,
    sindat            like datmpedvist.sindat   ,
    sinhor            like datmpedvist.sinhor   ,
    sinhst            like datmpedvist.sinhst   ,
    sinobs            like datmpedvist.sinobs   ,
    rglvstflg         like datmpedvist.rglvstflg,
    celteldddcod      like datmlcl.celteldddcod,
    celtelnum         like datmlcl.celtelnum,
    endcmp            like datmlcl.endcmp
 end record

 define w_viginc      like rsdmdocto.viginc     ,
        w_vigfnl      like rsdmdocto.vigfnl

 define ws            record
         lgdtip            like datmpedvist.lgdtip,
         lgdnom            like datmpedvist.lgdnom,
         lgdnum            like datmpedvist.lgdnum,
         lgdnomcmp         like datmpedvist.lgdnomcmp,
         endbrr            like datmpedvist.endbrr,
         endcid            like datmpedvist.endcid,
         endufd            like datmpedvist.endufd,
         endcep            like datmpedvist.endcep,
         endcepcmp         like datmpedvist.endcepcmp,
         lclidttxt         like datmlcl.lclidttxt,
         lclbrrnom         like datmlcl.lclbrrnom,
         lclrefptotxt      like datmlcl.lclrefptotxt,
         endzon            like datmlcl.endzon,
         lclltt            like datmlcl.lclltt,
         lcllgt            like datmlcl.lcllgt,
         c24lclpdrcod      like datmlcl.c24lclpdrcod,
         ofnnumdig         like sgokofi.ofnnumdig,
         celteldddcod      like datmlcl.celteldddcod   ,
         celtelnum         like datmlcl.celtelnum,
         endcmp            like datmlcl.endcmp,
         retflg            char (01),
         prpflg            char (01),
         confirma          char (01),
         codigosql         smallint
 end record

 define hist_cts21m00      record
           hist1                LIKE datmservhist.c24srvdsc,
           hist2                LIKE datmservhist.c24srvdsc,
           hist3                LIKE datmservhist.c24srvdsc,
           hist4                LIKE datmservhist.c24srvdsc,
           hist5                LIKE datmservhist.c24srvdsc
 end record

 define l_clscod          like rsdmclaus.clscod        ## PSI 168890
       ,l_emeviacod       like datkemevia.emeviacod
       ,l_qtdcobertura    smallint                 #PSI 200140
       ,l_data            date
       ,l_hora2           datetime hour to minute
       ,l_lclflg          smallint
       ,l_mensagem        char(60)

  ---> Danos Eletricos
  define  l_cbttip      like datrpedvistnatcob.cbttip,
          l_sinntzcod   like datrpedvistnatcob.sinntzcod,
          l_orcvlr      like datrpedvistnatcob.orcvlr,
          l_erro        smallint,
          l_desc_erro   char(40),
          l_count       smallint,
          l_confirma    char (01)

 initialize hist_cts21m00.* to null
 initialize ws.*  to null

 let l_qtdcobertura = 0
 let m_temp_RE = false

 let l_cbttip    = null
 let l_sinntzcod = null
 let l_orcvlr    = null
 let l_erro      = null
 let l_desc_erro = null
 let l_count     = null
 let l_confirma  = null
 let l_lclflg    = null
 let l_mensagem  = null

 input by name d_cts21m00.segnom   ,
               d_cts21m00.corsus   ,
               d_cts21m00.cornom   ,
               d_cts21m00.lclrsccod,
               d_cts21m00.lclendflg,
               d_cts21m00.lgdtip   ,
               d_cts21m00.lgdnom   ,
               d_cts21m00.lgdnum   ,
               d_cts21m00.lgdnomcmp,
               d_cts21m00.endbrr   ,
               d_cts21m00.endcid   ,
               d_cts21m00.endufd   ,
               d_cts21m00.endcep   ,
               d_cts21m00.endcepcmp,
               d_cts21m00.endddd   ,
               d_cts21m00.teldes   ,
               d_cts21m00.lclcttnom,
               d_cts21m00.endrefpto,
               d_cts21m00.sindat   ,
               d_cts21m00.sinhor
       without defaults

   before field segnom
          if g_documento.c24astcod = "V12"      and
             g_documento.aplnumdig is not null  and
             d_cts21m00.segnom     is not null  then
             next field lclrsccod
          end if

          display by name d_cts21m00.segnom     attribute (reverse)

   after  field segnom
          display by name d_cts21m00.segnom

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                next field segnom
          end if
          if d_cts21m00.segnom is null or
             d_cts21m00.segnom =  "  " then
             error " Nome do segurado deve ser informado!"
             next field segnom
          end if

   before field corsus
          display by name d_cts21m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts21m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.corsus is not null  then
                select cornom
                  into d_cts21m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts21m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts21m00.cornom
                end if
             end if
          end if

   before field cornom
          display by name d_cts21m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts21m00.cornom

          if g_documento.aplnumdig is null  or
            (g_documento.ramcod  <>  45     and
             g_documento.ramcod  <> 114)    then
             next field lclendflg
          end if

   before field lclrsccod
          display by name d_cts21m00.lclrsccod   attribute (reverse)
          if g_documento.aplnumdig  is null   then
             next field lclendflg
          end if

   after  field lclrsccod
          display by name d_cts21m00.lclrsccod
          display by name d_cts21m00.lclrscend
	  #-- CT 207365
	  display by name d_cts21m00.lgdtip
	  display by name d_cts21m00.lgdnom
	  display by name d_cts21m00.lgdnum
	  display by name d_cts21m00.endbrr
	  display by name d_cts21m00.endcid
	  display by name d_cts21m00.endufd
	  display by name d_cts21m00.endcep
	  display by name d_cts21m00.endcepcmp
	  #--

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts21m00.lclrsccod is null then

		let d_cts21m00.lclrsccod = mr_rsc_re.lclrsccod

                error " Alteracao do Local de Risco nao permitida."

                display by name d_cts21m00.lclrsccod
                next field lclrsccod

             else

                if d_cts21m00.lclrsccod <> mr_rsc_re.lclrsccod then

                   let d_cts21m00.lclrsccod = mr_rsc_re.lclrsccod

                   error " Alteracao do Local de Risco nao permitida."

                   display by name d_cts21m00.lclrsccod

                   next field lclrsccod
                end if

                --->Verifica se o Local de Risco e valido
                call framo240_valida_local(g_documento.succod,
                                           g_documento.ramcod,
                                           g_documento.aplnumdig,
                                           d_cts21m00.lclrsccod  )
                   returning l_lclflg
                            ,l_mensagem

                if l_lclflg = true  then
                   next field lclendflg
                else
                   let l_erro      = null
                   let l_desc_erro = null

                   ---> Locais de Risco ou Bloco do Condominio
                   call framc215(g_documento.succod
                                ,g_documento.ramcod
                                ,g_documento.aplnumdig)
                       returning l_erro
                                ,l_desc_erro
                                ,d_cts21m00.lclrsccod
                                ,d_cts21m00.lgdtip
                                ,d_cts21m00.lgdnom
                                ,d_cts21m00.lgdnum
                                ,d_cts21m00.endbrr
                                ,d_cts21m00.endcid
                                ,d_cts21m00.endufd
                                ,d_cts21m00.endcep
                                ,d_cts21m00.endcepcmp
                                ,mr_rsc_re.lclnumseq
                                ,mr_rsc_re.rmerscseq
                                ,mr_rsc_re.rmeblcdes
                                ,mr_rsc_re.lclltt
                                ,mr_rsc_re.lcllgt

                   next field lclrsccod

                end if
             end if
	   else
              next field corsus
           end if

           #-- CT 207365
	   let ws.lgdtip    = d_cts21m00.lgdtip
	   let ws.lgdnom    = d_cts21m00.lgdnom
	   let ws.lgdnum    = d_cts21m00.lgdnum
	   let ws.endbrr    = d_cts21m00.endbrr
	   let ws.endcid    = d_cts21m00.endcid
	   let ws.endufd    = d_cts21m00.endufd
	   let ws.endcep    = d_cts21m00.endcep
	   let ws.endcepcmp = d_cts21m00.endcepcmp
	   #--

           call frama185_end (ws.lgdtip, ws.lgdnom, ws.lgdnum,
                              ws.endbrr, ws.endcid, ws.endufd, "", "")
                 returning d_cts21m00.lclrscend

          display by name d_cts21m00.lclrsccod
          display by name d_cts21m00.lclrscend
	  #-- CT 207365
	  display by name d_cts21m00.lgdtip
	  display by name d_cts21m00.lgdnom
	  display by name d_cts21m00.lgdnum
	  display by name d_cts21m00.endbrr
	  display by name d_cts21m00.endcid
	  display by name d_cts21m00.endufd
	  display by name d_cts21m00.endcep
	  display by name d_cts21m00.endcepcmp
	  #--

   before field lclendflg
          if g_documento.aplnumdig  is null   or
            (g_documento.ramcod  <>  45       and
             g_documento.ramcod  <> 114)      then
             let d_cts21m00.lclendflg = "N"
          end if
          display by name d_cts21m00.lclendflg  attribute (reverse)

   after  field lclendflg  # --- PSI 164003 --- #
          display by name d_cts21m00.lclendflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if (d_cts21m00.lclendflg <> "S"  and
                 d_cts21m00.lclendflg <> "N") or
                 d_cts21m00.lclendflg is null then
                error " Vistoria no Local de Risco ? (S)im ou (N)ao"
                next field lclendflg
             else
                if d_cts21m00.lclendflg    = "S"   and
                   g_documento.aplnumdig is null   then
                   error " Vistoria sem documento nao pode ser feita",
                         " no Local de Risco"
                   next field lclendflg
                end if

                if d_cts21m00.lclendflg    = "S"   and
                  (g_documento.ramcod  =   31      or
                   g_documento.ramcod  =  531)     then
                   error " Vistoria com ramo de automovel nao pode ser",
                         " feita no Local de Risco"
                   next field lclendflg
                end if

                if d_cts21m00.lclendflg = "S" then
                   if d_cts21m00.lclrsccod is null or
                      d_cts21m00.lclrsccod = 0    then
                      next field lclrsccod
                   else
                      if d_cts21m00.endbrr is null or
                         d_cts21m00.endcid is null or
                         d_cts21m00.endufd is null or
                         d_cts21m00.lgdnom is null then
                         #nao permitir endereco nulo
                         error "Informe local de risco."
                         #limpando a variavel para que informe novamente e busque o endereco
                         let d_cts21m00.lclrsccod = ""
                         next field lclrsccod
                      else
##                       next field endddd     ---> Danos Eletricos
                      end if
                   end if
                end if
             end if
          else
             if g_documento.aplnumdig  is null   or
               (g_documento.ramcod  <>  45       and
                g_documento.ramcod  <> 114)      then
                next field corsus
             end if
          end if

         let d_cts21m00.endbrr = m_endbrr

         #quando lclendflg igual a N

         call ctx04g00_local_gps(g_documento.atdsrvnum,
                                 g_documento.atdsrvano,
                                 1)
                       returning ws.lclidttxt,
                                 d_cts21m00.lgdtip,
                                 d_cts21m00.lgdnom,
                                 d_cts21m00.lgdnum,
                                 ws.lclbrrnom,
                                 d_cts21m00.endbrr,
                                 d_cts21m00.endcid,
                                 d_cts21m00.endufd,
                                 ws.lclrefptotxt,
                                 ws.endzon,
                                 d_cts21m00.endcep,
                                 d_cts21m00.endcepcmp,
                                 ws.lclltt,
                                 ws.lcllgt,
                                 d_cts21m00.dddcod,
                                 d_cts21m00.teltxt,
                                 d_cts21m00.lclcttnom,
                                 ws.c24lclpdrcod,
                                 d_cts21m00.celteldddcod,
                                 d_cts21m00.celtelnum,
                                 d_cts21m00.endcmp,
                                 ws.codigosql,
                                 l_emeviacod


          select ofnnumdig
            into ws.ofnnumdig
            from datmlcl
           where atdsrvano = g_documento.atdsrvano
             and atdsrvnum = g_documento.atdsrvnum
             and c24endtip = 1

             let d_cts21m00.endbrr = m_subbairro[1].brrnom

             call cts06g03(1,
                           13,
                           ---> 15,
                           g_documento.ligcvntip,
                           aux_today,
                           aux_hora,
                           ws.lclidttxt,
                           d_cts21m00.endcid,
                           d_cts21m00.endufd,
                           d_cts21m00.endbrr,
                           ws.lclbrrnom,
                           ws.endzon,
                           d_cts21m00.lgdtip,
                           d_cts21m00.lgdnom,
                           d_cts21m00.lgdnum,
                           d_cts21m00.endcep,
                           d_cts21m00.endcepcmp,
                           ws.lclltt,
                           ws.lcllgt,
                           ws.lclrefptotxt,
                           d_cts21m00.lclcttnom,
                           d_cts21m00.dddcod,
                           d_cts21m00.teltxt,
                           ws.c24lclpdrcod,
                           ws.ofnnumdig,
                           ws.celteldddcod   ,
                           ws.celtelnum,
                           ws.endcmp,
                           hist_cts21m00.*,
                           l_emeviacod)
                 returning ws.lclidttxt,
                           d_cts21m00.endcid,
                           d_cts21m00.endufd,
                           d_cts21m00.endbrr,
                           ws.lclbrrnom,
                           ws.endzon,
                           d_cts21m00.lgdtip,
                           d_cts21m00.lgdnom,
                           d_cts21m00.lgdnum,
                           d_cts21m00.endcep,
                           d_cts21m00.endcepcmp,
                           ws.lclltt,
                           ws.lcllgt,
                           ws.lclrefptotxt,
                           d_cts21m00.lclcttnom,
                           d_cts21m00.dddcod,
                           d_cts21m00.teltxt,
                           ws.c24lclpdrcod,
                           ws.ofnnumdig,
                           ws.celteldddcod   ,
                           ws.celtelnum,
                           ws.endcmp,
                           ws.retflg,
                           hist_cts21m00.*,
                           l_emeviacod

             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].brrnom = d_cts21m00.endbrr

             call cts06g10_monta_brr_subbrr(d_cts21m00.endbrr,
                                            ws.lclbrrnom)
                  returning d_cts21m00.endbrr

             #if d_cts21m00.lclendflg = "N" and
             if d_cts21m00.endcid is null or
                d_cts21m00.endufd is null or
                d_cts21m00.lgdnom is null then
                 #nao permitir endereco nulo
                 error "Informe endereco para local de risco."
                 next field lclendflg
             end if

             let g_jit.lclidttxt    = ws.lclidttxt
             let g_jit.lclrefptotxt = ws.lclrefptotxt
             let g_jit.lclltt       = ws.lclltt
             let g_jit.lcllgt       = ws.lcllgt
             let g_jit.c24lclpdrcod = ws.c24lclpdrcod
             let g_jit.ofnnumdig    = ws.ofnnumdig

             let d_cts21m00.endrefpto = ws.lclrefptotxt
             let d_cts21m00.endddd = d_cts21m00.dddcod
             let d_cts21m00.teldes = d_cts21m00.teltxt

             display by name d_cts21m00.endbrr
             display by name d_cts21m00.endrefpto
             display by name d_cts21m00.endddd
             display by name d_cts21m00.teldes
             display by name d_cts21m00.endcep
             display by name d_cts21m00.endcepcmp

          #next field sinntzcod
           next field sindat

   before field lgdtip
          display by name d_cts21m00.lgdtip     attribute (reverse)

   after  field lgdtip
          display by name d_cts21m00.lgdtip

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.lgdtip is null or
                d_cts21m00.lgdtip =  "  " then
                error " Tipo Logradouro: Rua, Avenida, Alameda, Praca, etc.!!"
                next field lgdtip
             end if
          end if

   before field lgdnom
          display by name d_cts21m00.lgdnom     attribute (reverse)

   after  field lgdnom
          display by name d_cts21m00.lgdnom

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.lgdnom is null or
                d_cts21m00.lgdnom =  "  " then
                error " Endereco deve ser informado!"
                next field lgdnom
             end if
          end if

   before field lgdnum
          display by name d_cts21m00.lgdnum attribute (reverse)

   after  field lgdnum
          display by name d_cts21m00.lgdnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.lgdnum is null or
                d_cts21m00.lgdnum =  "  " then
                error " Numero no logradouro deve ser informado!"
                next field lgdnum
             end if
          end if

   before field lgdnomcmp
          display by name d_cts21m00.lgdnomcmp attribute (reverse)

   after  field lgdnomcmp
          display by name d_cts21m00.lgdnomcmp

   before field endbrr
          display by name d_cts21m00.endbrr    attribute (reverse)

   after  field endbrr
          display by name d_cts21m00.endbrr

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.endbrr is null or
                d_cts21m00.endbrr =  "  " then
                error " Bairro deve ser informado!"
                next field endbrr
             end if
          end if

   before field endcid
          display by name d_cts21m00.endcid attribute (reverse)

   after  field endcid
          display by name d_cts21m00.endcid

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.endcid is null then
                error " Cidade deve ser informada!"
                next field endcid
             end if
          end if

   before field endufd
          display by name d_cts21m00.endufd attribute (reverse)

   after  field endufd
          display by name d_cts21m00.endufd

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts21m00.endufd is null or
                d_cts21m00.endufd =  "  " then
                error " Unidade de Federacao deve ser informada!"
                next field endufd
             else
                select ufdcod from glakest
                 where ufdcod = d_cts21m00.endufd

                if sqlca.sqlcode = notfound then
                   error " Unidade Federativa nao cadastrada!"
                   next field endufd
                else
                   if sqlca.sqlcode < 0 then
                      error " Erro (", sqlca.sqlcode, ") na localizacao",
                            " da U.F. AVISE A INFORMATICA!"
                   end if
                end if
             end if
          end if

   before field endcep
          display by name d_cts21m00.endcep attribute (reverse)

   after  field endcep
          display by name d_cts21m00.endcep

   before field endcepcmp
          display by name d_cts21m00.endcepcmp attribute (reverse)

   after  field endcepcmp
          display by name d_cts21m00.endcepcmp

   before field endddd
          display by name d_cts21m00.endddd attribute (reverse)

   after  field endddd
          display by name d_cts21m00.endddd

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts21m00.lclendflg = "S" then
                next field lclendflg
             end if
          end if

   before field teldes
          display by name d_cts21m00.teldes attribute (reverse)

   after  field teldes
          display by name d_cts21m00.teldes

   before field lclcttnom
          display by name d_cts21m00.lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name d_cts21m00.lclcttnom

   before field endrefpto
          display by name d_cts21m00.endrefpto attribute (reverse)

   after  field endrefpto
          display by name d_cts21m00.endrefpto


   before field sindat
          #PSI 200140 chamar funcao RE para informar cobertura/natureza
          # utilizado apenas na criacao do laudo
          # na consulta do laudo utilizamos cts21m03 e atalho
          if g_documento.atdsrvnum is null then
             #while nao informou a cobertura
             while true
                if m_temp_RE <> true then
                   let m_temp_RE = true
                   call fsrec770_cria_temp()
                end if
                call fsrec770_sel_cobnat("S",  g_documento.succod,
                                         g_documento.ramcod, g_documento.aplnumdig)

                ---> Danos Eletricos - Verifica Cidade Sede
                call ctf00m07(d_cts21m00.endufd,d_cts21m00.endcid)
                     returning mr_retorno.*

                if mr_retorno.cidsednom = 'SAO PAULO' then
                #busca registros na tabela temporaria

                   ---> Danos Eletricos
                   select count(*) into l_qtdcobertura from temp_fsrec770
                   # se encontrou registro
                   if l_qtdcobertura <> 0 then

                      declare i2_temp cursor for
                      select cbttip, sinntzcod, sinrclvlr
                       from temp_fsrec770
                      foreach i2_temp into l_cbttip,
                                          l_sinntzcod,
                                          l_orcvlr

                         if l_cbttip = 75 then

                            let l_confirma = null

                            call cts08g01 ("Q","S",""
                         ,"E' NECESSARIO ENVIO DE PRESTADOR (P10) ","A RESIDENCIA?","")
                                 returning l_confirma

                            if l_confirma = "S" then
                               whenever error continue
                               delete from tmp_natureza_mlt
                               whenever error stop

                               while true
                                  call cts21m00_mult_natureza()
                                       returning l_erro
                                                ,l_desc_erro

                                  let l_count = null
                                  select count(*)
                                    into l_count
                                    from tmp_natureza_mlt
                                  if l_erro = 0  and
                                     l_count > 0 then
                                     exit while
                                  else
                                     error "Nenhuma natureza selecionada. Selecione uma natureza."
                                  end if
                               end while
                            end if
                         else
                            whenever error continue
                            delete from tmp_natureza_mlt
                            whenever error stop
                         end if

                      end foreach

                      exit while
                   else
                      error "Informe cobertura/natureza do sinistro!" sleep 3
                   end if
                else
### a pedido bia   error "Local de risco fora da Grande Sao Paulo. Danos Eletricos"
                   exit while
                end if
             end while
          end if
          display by name d_cts21m00.sindat    attribute (reverse)

   after  field sindat
          display by name d_cts21m00.sindat

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field lclendflg
          end if

          if d_cts21m00.sindat is null  then
             error " Data do sinistro deve ser informada!"
             next field sindat
          end if
          call  cts40g03_data_hora_banco(2)
             returning l_data, l_hora2
          if d_cts21m00.sindat < l_data - 366 units day then
             call cts08g01("A","N","",
                           "DATA DO SINISTRO INFORMADA E'",
                           "ANTERIOR A  1 (UM) ANO !","")
                   returning ws.confirma
             next field sindat
          end if

          if d_cts21m00.sindat + 180 units day < l_data  then
             call cts08g01("C","N", "","DATA DO SINISTRO ANTERIOR",
                           "A TRES MESES!", "") returning ws.confirma
          end if

          if d_cts21m00.sindat > aux_today   then
             error " Data do sinistro maior que data atual!"
             next field sindat
          else
             if w_viginc  is not null   then
                if d_cts21m00.sindat < w_viginc   or
                   d_cts21m00.sindat > w_vigfnl   then
                   error " Data do sinistro fora da vigencia da apolice!"
                end if
             end if
          end if

   before field sinhor
          display by name d_cts21m00.sinhor    attribute (reverse)

   after  field sinhor
          display by name d_cts21m00.sinhor

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sindat
          end if

          if d_cts21m00.sindat = aux_today and
             d_cts21m00.sinhor > aux_hora  then
             error " Hora do sinistro maior que Hora atual!"
             next field sinhor
          end if

          call cts21m02 (d_cts21m00.sinhst, d_cts21m00.sinobs)
               returning d_cts21m00.sinhst, d_cts21m00.sinobs

          #confirmar informações do laudo
          if cts08g01("C","S","","CONFIRMA INFORMACOES DO LAUDO ?",
                     "","") = "N"  then
             next field lclendflg
          end if


   on key (interrupt)
      if g_documento.atdsrvnum  is null   then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?",
                     "","") = "S"  then
            let int_flag = true
            #PSI200140 - destroi tabela temporaria do RE
            #ao tentar dropar tabela temporaria esta ocorrendo o erro 242
            # como se eu nao fosse o proprietario da tabela criada
            #e quando faço um rollback ou commit a tabela é dropada
            # entao dentro da funcao fsrec770_drop_temp criamos uma transacao
            # e assim a tabela é dropada
            #como existe uma transacao dentro da funcao nao posso chama-la dentro
            # de outra transacao senao perco minhas informações ao dar rollback
            if m_temp_RE = true then
               let m_temp_RE = false
               call fsrec770_drop_temp()
            end if
            #begin work
            #rollback work
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F5)
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
          call cts21m02 (d_cts21m00.sinhst, d_cts21m00.sinobs)
               returning d_cts21m00.sinhst, d_cts21m00.sinobs

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)


 end input

 if int_flag then
    error "Operacao cancelada!"
 end if

 return d_cts21m00.*, "",""

end function  ###  input_cts21m00


#---------------------------------------------------------------
 function cts21m00_regulador(param)
#---------------------------------------------------------------

 define param      record
    sinvstdat      like datmpedvist.sinvstdat ,
    sinvsthor      like datmpedvist.sinvsthor
 end record

 define ws         record
    hoje           smallint ,
    retorno        char (01),
    data_util      char (10)
 end record

 define l_data     date,
        l_hora2    datetime hour to minute

 initialize  ws.*  to  null

 let ws.hoje = weekday(param.sinvstdat)

 if ws.hoje = 6 or ws.hoje = 0  then   ## Sabado ou Domingo
    let ws.retorno = "S"
    return ws.retorno
 else
    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2
    call c24geral9(param.sinvstdat,0,"01000","S","S")
         returning ws.data_util
    if ws.data_util is not null  and   ## Feriado
       ws.data_util  > l_data     then
       let ws.retorno = "S"
    else
       if param.sinvsthor > "17:30"  or
          param.sinvsthor < "08:15"  then
          let ws.retorno = "S"
       else
          let ws.retorno = "N"
       end if
    end if
 end if

 return ws.retorno

end function  ###  cts21m00_regulador

#--------------------------------
function mail_cts21m00(l_param)
#-------------------------------
define l_param record
       sinvstnum like datmpedvist.sinvstnum  ,
       ano       like datmpedvist.sinvstano  ,
       solnom    like datmpedvist.vstsolnom  ,
       soltip    like datmpedvist.vstsoltip  ,
       segnom    like datmpedvist.segnom     ,
       funmat    like datmpedvist.funmat     ,
       dia       like datmpedvist.sinvstdat  ,
       sinramgrp like datmpedvist.sinramgrp
end record

define l_cmd           char(500)

define l_mens          record
       msg             char(500),
       de              char(50),
       subject         char(100),
       para            char(100)
end record

define  l_mail             record
   de                 char(500)   # De
  ,para               char(5000)  # Para
  ,cc                 char(500)   # cc
  ,cco                char(500)   # cco
  ,assunto            char(500)   # Assunto do e-mail
  ,mensagem           char(32766) # Nome do Anexo
  ,id_remetente       char(20)
  ,tipo               char(4)     #
end  record
define l_coderro  smallint
define msg_erro char(500)
let l_cmd = null
initialize l_mens.* to null


let l_mens.msg = "l_param.sinvstnum: "       ,       l_param.sinvstnum        ,"<br>",
                 "l_param.ano: "             ,       l_param.ano              ,"<br>",
                 "l_param.solnom: "          ,       l_param.solnom           ,"<br>",
                 "l_param.soltip: "          ,       l_param.soltip           ,"<br>",
                 "l_param.segnom: "          ,       l_param.segnom           ,"<br>",
                 "l_param.funmat: "          ,       l_param.funmat           ,"<br>",
                 "l_param.dia: "             ,       l_param.dia              ,"<br>",
                 "l_param.sinramgrp: "       ,       l_param.sinramgrp        ,"<br>",
                 "g_documento.c24soltipcod: ",       g_documento.c24soltipcod ,"<br>",
                 "P.A: "                     ,       g_c24paxnum              ,"<br>",
                 "Nome Funcionario: "        ,       g_issk.funnom
let l_mens.de = "CT24H-cts21m00"
let l_mens.subject = "Erro de Insercao"
let l_mens.para = "roberto.melo@correioporto"
#PSI-2013-23297 - Inicio
let l_mail.de = l_mens.de
#let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
let l_mail.para = l_mens.para
let l_mail.cc = ""
let l_mail.cco = ""
let l_mail.assunto = l_mens.subject
let l_mail.mensagem = l_mens.msg
let l_mail.id_remetente = "CT24HS"
let l_mail.tipo = "html"

call figrc009_mail_send1 (l_mail.*)
 returning l_coderro,msg_erro
#PSI-2013-23297 - Fim

return

end function

#--------------------------------
function cts21m00_mult_natureza()
#--------------------------------

 define a_ctc48m05   array[100] of record
        opcao        char(01)
       ,socntzcod    smallint
       ,socntzdes    char(40)
 end record

 define l_cod_erro   smallint
       ,l_desc_erro  char(40)
       ,arr_aux      smallint
       ,l_scr        smallint
       ,l_arr        smallint
       ,l_sql        char(3000)
       ,l_mensagem   char(50)
       ,l_opcao_ant  char(01)

 initialize a_ctc48m05 to null

 let l_cod_erro  = null
 let l_desc_erro = null
 let arr_aux     = null
 let l_scr       = null
 let l_arr       = null
 let l_sql       = null
 let l_mensagem  = null
 let l_opcao_ant = null

 options
      delete   key control-y,
      insert   key control-z,
      next     key f3,
      previous key f4

 call ctc48m04(93,'')
    returning l_cod_erro ,l_desc_erro

 if l_cod_erro <> 0 then
    error l_desc_erro
    return l_cod_erro ,l_desc_erro
 end if

 whenever error continue
 delete from tmp_natureza_mlt
 whenever error stop

 whenever error continue
 create temp table tmp_natureza_mlt
       (socntzcod smallint
       ,socntzdes char(40)) with no log
 whenever error stop

 whenever error continue
 create index tmp_natureza_mlt_idx1 on tmp_natureza_mlt (socntzcod)
 whenever error stop

 let l_sql = " insert into tmp_natureza_mlt ",
             " (socntzcod, socntzdes) ",
             " values(?,?) "
 prepare p_cts21m00_001 from l_sql

 let l_sql = " delete from tmp_natureza_mlt ",
             "  where socntzcod = ?  "
 prepare p_cts21m00_002 from l_sql

 open window ctc48m05 at 10,23 with form "ctc48m05"
                     attribute(form line 1, border)

 let int_flag = false
 let arr_aux  = 1

 declare c_cts21m00_004 cursor for
    select socntzcod,socntzdes
      from datksocntz
     where c24pbmgrpcod = 106 ---> SINISTRO RE - LEVA E TRAZ

 foreach c_cts21m00_004  into  a_ctc48m05[arr_aux].socntzcod,
                           a_ctc48m05[arr_aux].socntzdes

       let arr_aux = arr_aux + 1
 end foreach

 call set_count(arr_aux-1)

 message "  (CONTROL+C) Confirma"

 let l_mensagem = "MARQUE COM 'X' A NATUREZA AFETADA"

 display l_mensagem to mensagem

 input array a_ctc48m05 without defaults from s_ctc48m05.*

       before row
         let l_arr = arr_curr()
         let l_scr = scr_line()

       before field opcao
         display a_ctc48m05[l_arr].opcao  to
                 s_ctc48m05[l_scr].opcao  attribute (reverse)

         if a_ctc48m05[l_arr].opcao is null  then
            let a_ctc48m05[l_arr].opcao = " "
         end if

         let l_opcao_ant = a_ctc48m05[l_arr].opcao

       after field opcao
         display a_ctc48m05[l_arr].opcao  to s_ctc48m05[l_scr].opcao

         if a_ctc48m05[l_arr].opcao is null  then
            let a_ctc48m05[l_arr].opcao = " "
         end if

         if a_ctc48m05[l_arr].opcao = " " then
         else
            if a_ctc48m05[l_arr].opcao <> "X" then
               error 'Somente digitar "X" ou barra de espaco '
               next field opcao
            end if
         end if

         if l_opcao_ant <> a_ctc48m05[l_arr].opcao then
            if a_ctc48m05[l_arr].opcao = "X" then
               whenever error continue
               execute p_cts21m00_001  using a_ctc48m05[l_arr].socntzcod
                                              ,a_ctc48m05[l_arr].socntzdes
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error " Erro na inclusao do Problema! " sleep 2
                  let int_flag = true
                  --exit input
               end if
            else
               whenever error continue
               execute p_cts21m00_002 using a_ctc48m05[l_arr].socntzcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error " Erro na exclusao do Problema! " ,sqlca.sqlcode ,a_ctc48m05[l_arr].socntzcod
                  let int_flag = true
                  --exit input
               end if
            end if
         end if

         if fgl_lastkey() = fgl_keyval('up') then
         else
             if length(a_ctc48m05[l_arr + 1].socntzdes) = 0 then
                error " There are no more rows in the direction ",
                      "you are going "
                next field opcao
             end if
         end if

         on key (f17,control-c,interrupt,accept,escape)

           let int_flag = true
           exit input

   end input

   let l_mensagem = ""

   display l_mensagem to mensagem

   let int_flag = false

   close window ctc48m05

   return 0,"OK"

end function  ###  ctc48m05
