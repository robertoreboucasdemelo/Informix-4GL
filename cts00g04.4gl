#############################################################################
# Nome do Modulo: CTS00G04                                          Wagner  #
#                                                                           #
# Formata e envia mensagens  do servico via teletrim               Jan/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 09/02/2001  PSI 125377   Wagner       Adaptacao para envio servicos via   #
#                                       Teletrim para RE.                   #
#---------------------------------------------------------------------------#
# 16/12/2002  CORREIO      Wagner       Adaptacao para envio servicos via   #
#                                       Teletrim para Socorro.              #
#---------------------------------------------------------------------------#
# 10/02/2003  PSI 169960   Raji         Enivio de laudo JIT por PAGER       #
#---------------------------------------------------------------------------#
# 23/02/2010  PSI 253006   Beatriz      Substituir o envio de pager pelo    #
#                                       envio de SMS para o plantão         #
#############################################################################
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
# 27/06/2003  James, Meta    174688    Enviar mensagem(pager) p/servicos VP #
#                                                                           #
# 05/10/2003  Marcelo, Meta  psi178381 Criar funcao para gerar texto do JIT #
#                            osf26522  com codigo ja existente              #
#                                                                           #
# 11/01/2005 Helio (Meta)    PSI190250 Ajustes gerais                       #
#---------------------------------------------------------------------------#
# 07/03/2006 Priscila        Zeladoria Buscar data e hora do banco de dados #
#---------------------------------------------------------------------------#
# 09/05/2012   Silvia        PSI 2012-07408  Anatel - DDD/Telefone          #
#                                                                           #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca             #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep_sql smallint

  # projeto novos ambientes
  define m_host like ibpkdbspace.srvnom

#----------------------------#
function cts00g04_prepare()
#----------------------------#

 define l_sql       char(600)

 # projeto novos ambientes
 # -> BUSCA O HOSTNAME
 # select sitename
 #   into g_hostname
 #   from dual

 let l_sql = ' select sindat,       ',
             '        sinhor        ',
             '   from datmservicocmp',
             '  where atdsrvnum = ? ',
             '    and atdsrvano = ? '

 prepare p_cts00g04_001 from l_sql
 declare c_cts00g04_001 cursor for p_cts00g04_001

 let l_sql = ' select cpodes               ',
             '   from iddkdominio          ',
             '  where cponom = "vclcorcod" ',
             '    and cpocod = ?           '

 prepare p_cts00g04_002 from l_sql
 declare c_cts00g04_002 cursor for p_cts00g04_002
 let l_sql = ' select succod,       ',
             '       aplnumdig,     ',
             '       itmnumdig,     ',
             '       edsnumref      ',
             '  from datrservapol   ',
             ' where atdsrvnum = ?  ',
             '   and atdsrvano = ?  '

 prepare p_cts00g04_003 from l_sql
 declare c_cts00g04_003 cursor for p_cts00g04_003

 let l_sql = ' select clalclcod,     ',
             '        vigfnl,        ',
             '        viginc,        ',
             '        bonclacod      ',
             '   from abbmdoc        ',
             '  where succod    =  ? ',
             '    and aplnumdig =  ? ',
             '    and itmnumdig =  ? ',
             '    and dctnumseq =  ? '

 prepare p_cts00g04_004 from l_sql
 declare c_cts00g04_004 cursor for p_cts00g04_004

 let l_sql = ' select cbtcod,       ',
             '        ctgtrfcod,    ',
             '        bondscper,    ',
             '        frqvlr,       ',
             '        imsvlr,       ',
             '        clcdat        ',
             '   from abbmcasco     ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and itmnumdig = ? ',
             '    and dctnumseq = ? '

 prepare p_cts00g04_005 from l_sql
 declare c_cts00g04_005 cursor for p_cts00g04_005

 let l_sql = ' select imsvlr, clcdat ',
             '   from abbmdm        ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and itmnumdig = ? ',
             '    and dctnumseq = ? '

 prepare p_cts00g04_006 from l_sql
 declare c_cts00g04_006 cursor for p_cts00g04_006

 let l_sql = ' select imsvlr, clcdat ',
             '   from abbmdp        ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and itmnumdig = ? ',
             '    and dctnumseq = ? '

 prepare p_cts00g04_007 from l_sql
 declare c_cts00g04_007 cursor for p_cts00g04_007

 let l_sql = ' select bondscper    ',
             '  from acatbon       ',
             ' where tabnum    = ? ',
             '   and ramcod    = 31',
             '   and clalclcod = ? ', ###  REGIAO ESPECIFICA, 0 - DEMAIS REGIOES
             '   and bonclacod = ? '

 prepare p_cts00g04_008 from l_sql
 declare c_cts00g04_008 cursor for p_cts00g04_008

 let l_sql = ' select cbtstt                           ',
             '   from abbmvida2                        ',
             '  where succod    = ?                    ',
             '    and aplnumdig = ?                    ',
             '    and itmnumdig = ?                    ',
             '    and dctnumseq =(select max(dctnumseq)',
             '                      from abbmvida2     ',
             '                     where succod    = ? ',
             '                       and aplnumdig = ? ',
             '                       and itmnumdig = ?)'

    prepare p_cts00g04_009 from l_sql
    declare c_cts00g04_009 cursor for p_cts00g04_009

 #projeto novos ambientes
 #if g_hostname = "u07" then
 #   let l_sql = ' select grlinf              ',
 #               '   from igbkgeral           ',
 #               '  where mducod  =  "VDA"    ',
 #               '    and grlchv  =  "PREMIO" '
 #
 #   prepare p_cts00g04_010 from l_sql
 #   declare c_cts00g04_010 cursor for p_cts00g04_010
 #else
    let m_host = fun_dba_servidor("EMISAUTO")

    let l_sql = ' select grlinf              ',
                '   from porto@',m_host clipped,':igbkgeral ',
                '  where mducod  =  "VDA"    ',
                '    and grlchv  =  "PREMIO" '

    prepare p_cts00g04_011 from l_sql
    declare c_cts00g04_011 cursor for p_cts00g04_011
 #end if

 let l_sql = ' select viginc        ',
             '   from abamapol      ',
             '  where succod    = ? ',
             '    and aplnumdig = ? '

 prepare p_cts00g04_012 from l_sql
 declare c_cts00g04_012 cursor for p_cts00g04_012

 let l_sql = ' select viginc,       ',
             '        dctnumseq     ',
             '   from abbmdoc       ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and itmnumdig = ? ',
             '    and edstip    = 2 '

 prepare p_cts00g04_013 from l_sql
 declare c_cts00g04_013 cursor for p_cts00g04_013

 let l_sql = ' select edsstt        ',
             '   from abamdoc       ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and dctnumseq = ? '

 prepare p_cts00g04_014 from l_sql
 declare c_cts00g04_014 cursor for p_cts00g04_014

 let l_sql = ' select clscod        ',
             '   from abbmclaus     ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and itmnumdig = ? ',
             '    and dctnumseq = ? '

 prepare p_cts00g04_016 from l_sql
 declare c_cts00g04_016 cursor for p_cts00g04_016

 let l_sql = ' select refatdsrvnum, ',
             '        refatdsrvano  ',
             '   from datmsrvjit    ',
             '  where atdsrvnum = ? ',
             '    and atdsrvano = ? '

 prepare p_cts00g04_017 from l_sql
 declare c_cts00g04_017 cursor for p_cts00g04_017

 let l_sql = ' select atdvclsgl     ',
             '   from datkveiculo   ',
             '  where socvclcod = ? '

 prepare p_cts00g04_018 from l_sql
 declare c_cts00g04_018 cursor for p_cts00g04_018

 let l_sql = ' select srrabvnom     ',
             '   from datksrr       ',
             '  where srrcoddig = ? '

 prepare p_cts00g04_019 from l_sql
 declare c_cts00g04_019 cursor for p_cts00g04_019

 let l_sql = ' select nomgrr        ',
             '   from dpaksocor     ',
             '  where pstcoddig = ? '

 prepare p_cts00g04_020 from l_sql
 declare c_cts00g04_020 cursor for p_cts00g04_020

 let l_sql = ' select atdsrvnum,  ',
                    ' atdsrvano,  ',
                    ' atdsrvorg,  ',
                    ' vclcorcod,  ',
                    ' vcldes,     ',
                    ' vclanomdl,  ',
                    ' vcllicnum,  ',
                    ' atdrsdflg,  ',
                    ' atdhorpvt,  ',
                    ' atdprvdat,  ',
                    ' atddatprg,  ',
                    ' atdhorprg,  ',
                    ' atddfttxt,  ',
                    ' srvprlflg,  ',
                    ' atdprscod,  ',
                    ' asitipcod,  ',
                    ' nom,        ',
                    ' socvclcod,  ',
                    ' srrcoddig,  ',
                    ' atdprscod   ',
             '   from datmservico ',
             '  where atdsrvnum    = ? ',
             '    and atdsrvano    = ? '

 prepare p_cts00g04_021 from l_sql
 declare c_cts00g04_021 cursor for p_cts00g04_021

 let l_sql = ' select atdetpcod    ',
             '  from datmsrvacp    ',
             ' where atdsrvnum = ? ',
             '   and atdsrvano = ? ',
             '   and atdsrvseq = (select max(atdsrvseq)',
                                '   from datmsrvacp    ',
                                '  where atdsrvnum = ? ',
                                '    and atdsrvano = ?)'


 prepare p_cts00g04_022 from l_sql
 declare c_cts00g04_022 cursor for p_cts00g04_022

 let l_sql = "select atdprscod, socvclcod, atddat, atdhor ",
                "from datmservico ",
                "where atdsrvnum = ? ",
                "  and atdsrvano = ? "

  prepare p_cts00g04_023 from l_sql
  declare c_cts00g04_023 cursor for p_cts00g04_023

  let l_sql = "select socvclcod,atdetpcod from datmsrvacp a ",
              "where  a.atdsrvnum = ? ",
              "  and  a.atdsrvano = ? ",
              "  and  a.atdsrvseq = (select max(b.atdsrvseq) ",
                                    "  from datmsrvacp b ",
                                    " where b.atdsrvnum = a.atdsrvnum ",
                                    "   and b.atdsrvano = a.atdsrvano)"
  prepare p_cts00g04_024 from l_sql
  declare c_cts00g04_024 cursor for p_cts00g04_024

  let l_sql = "select  vstnumdig, vstdat, ",
              "vstfld, segnom, corsus, cornom, vclmrcnom, ",
              "vcltipnom, vclmdlnom, vcllicnum, vclchsnum, ",
              "vclanomdl, vclanofbc, pestip, cgccpfnum, cgccpfdig ",
              "from   datmvistoria ",
              "where  atdsrvnum = ?    and  ",
              "       atdsrvano = ? "

  prepare p_cts00g04_025 from l_sql
  declare c_cts00g04_025 cursor for p_cts00g04_025

  let l_sql = "select b.cornom from gcaksusep a, gcakcorr b ",
              "where  a.corsus = ?               and ",
              "       a.corsuspcp = b.corsuspcp"

  prepare p_cts00g04_026 from l_sql
  declare c_cts00g04_026 cursor for p_cts00g04_026

  let l_sql = "select cpodes from iddkdominio ",
              "where  cponom = ?     and ",
              "       cpocod = ? "

  prepare p_cts00g04_027 from l_sql
  declare c_cts00g04_027 cursor for p_cts00g04_027

  let l_sql = "select c24srvdsc from datmservhist ",
              "where  atdsrvnum = ?   and ",
              "       atdsrvano = ?"

  prepare p_cts00g04_028 from l_sql
  declare c_cts00g04_028 cursor for p_cts00g04_028

  let l_sql = " select atdsrvnum, ",
                     " atdsrvano, ",
                     " atdsrvorg, ",
                     " vclcorcod, ",
                     " vcldes,    ",
                     " vclanomdl, ",
                     " vcllicnum, ",
                     " atdrsdflg, ",
                     " atdhorpvt, ",
                     " atdprvdat, ",
                     " atddatprg, ",
                     " atdhorprg, ",
                     " atddfttxt, ",
                     " srvprlflg, ",
                     " atdprscod, ",
                     " asitipcod, ",
                     " nom,       ",
                     " c24solnom  ",
               " from datmservico  ",
              " where atdsrvnum = ? ",
               "  and atdsrvano = ? "

  prepare p_cts00g04_029 from l_sql
  declare c_cts00g04_029 cursor for p_cts00g04_029

 let l_sql = " select atdvclsgl, ",
                    " pgrnum ",
               " from datkveiculo ",
              " where socvclcod = ? "

 prepare p_cts00g04_030 from l_sql
 declare c_cts00g04_030 cursor for p_cts00g04_030

 let l_sql =  " select ustcod ",
                " from htlrust ",
               " where pgrnum = ? "

 prepare p_cts00g04_031 from l_sql
 declare c_cts00g04_031 cursor for p_cts00g04_031

 let l_sql = " select pgrnum ",
               " from htlrust ",
              " where ustcod = ? "

 prepare p_cts00g04_032 from l_sql
 declare c_cts00g04_032 cursor for p_cts00g04_032

 # para buscar da maxima sequencia a hora, data e etapa do servico
  let l_sql = "select acp.atdetpdat,",
              "       acp.atdetphor",
              "  from datmsrvacp acp",
              " where acp.atdsrvnum = ?",
              "   and acp.atdsrvano = ?",
              "   and acp.atdsrvseq = (select max (acpmax.atdsrvseq)",
                                 "  from datmsrvacp acpmax",
                                 " where acpmax.atdsrvnum = acp.atdsrvnum",
                                 "   and acpmax.atdsrvano = acp.atdsrvano",
                                 "   and acpmax.atdetpcod in (3,4,10)) "
  prepare p_cts00g04_033 from l_sql
  declare c_cts00g04_033 cursor for p_cts00g04_033


 let m_prep_sql = true

 end function

#Marcelo - psi174343 - fim
#----------------------------------------------------------------------
 function cts00g04_msgsrv(param)
#----------------------------------------------------------------------

 define w_cgccpf      char(20)

 define param            record
    atdsrvnum       like datmmdtsrv.atdsrvnum,
    atdsrvano       like datmmdtsrv.atdsrvano,
    socvclcod       like datkveiculo.socvclcod,
    atdetpcod       like datmsrvacp.atdetpcod,
    atdprscod       like datmservico.atdprscod,
    flgmsg          char(03),   # (SRV)Servicos socorro (REF)Ref.do ender.
    tipo_programa   char(01)   # "B" --> BATCH  "O"  --> ONLINE
 end record

 define d_cts00g04  record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    vcldes          like datmservico.vcldes,
    vclcordes       char (20)              ,
    vclanomdl       like datmservico.vclanomdl,
    vcllicnum       like datmservico.vcllicnum,
    atdhorpvt       like datmservico.atdhorpvt,
    atdprvdat       like datmservico.atdprvdat,
    atddatprg       like datmservico.atddatprg,
    atdhorprg       like datmservico.atdhorprg,
    atddfttxt       like datmservico.atddfttxt,
    atdvclsgl       like datkveiculo.atdvclsgl,
    asitipabvdes    like datkasitip.asitipabvdes,
    roddantxt       like datmservicocmp.roddantxt,
    ustcod          like htlrust.ustcod,
    atdrsddes       char (03),
    rmcacpdes       char (03),
    msgtxt          char (880)   #PSI 190250
 end record

 define a_cts00g04  array[2] of record
    lclidttxt       like datmlcl.lclidttxt,
    lgdtxt          char (65),
    lclbrrnom       like datmlcl.lclbrrnom,
    endzon          like datmlcl.endzon,
    cidnom          like datmlcl.cidnom,
    ufdcod          like datmlcl.ufdcod,
    lclrefptotxt    like datmlcl.lclrefptotxt,
    dddcod          like datmlcl.dddcod,
    lcltelnum       like datmlcl.lcltelnum,
    lclcttnom       like datmlcl.lclcttnom
 end record

 define ws          record
    campo           char (40),
    msgpvt          char (40),
    msgpgttxt       char (50),
    pgrnum          like datkveiculo.pgrnum,
    atdsrvorg       like datmservico.atdsrvorg,
    orrdat          like datmsrvre.orrdat,
    orrhor          like datmsrvre.orrhor,
    socntzcod       like datmsrvre.socntzcod,
    sinntzcod       like sgaknatur.sinntzcod,
    natureza        char (40),
    mstnum          like htlmmst.mstnum,
    errcod          smallint,
    atdrsdflg       like datmservico.atdrsdflg,
    srvprlflg       like datmservico.srvprlflg,
    vclcorcod       like datmservico.vclcorcod,
    asitipcod       like datmservico.asitipcod,
    atdprscod       like datmservico.atdprscod,
    rmcacpflg       like datmservicocmp.rmcacpflg,
    sqlcode         integer,

    sindat          like datmservicocmp.sindat,
    sinhor          like datmservicocmp.sinhor,
    succod          like datrservapol.succod,
    aplnumdig       like datrservapol.aplnumdig,
    itmnumdig       like datrservapol.itmnumdig,
    edsnumref       like datrservapol.edsnumref,

    segnom          like datmservico.nom,
    clalclcod       like abbmdoc.clalclcod,
    vigfnl          like abbmdoc.vigfnl,
    cbtcod          like abbmcasco.cbtcod,
    ctgtrfcod       like abbmcasco.ctgtrfcod,
    bondscper       like abbmcasco.bondscper,
    frqvlr          like abbmcasco.frqvlr,
    casco           like abbmcasco.imsvlr,
    dm              like abbmdm.imsvlr,
    dp              like abbmdp.imsvlr,
    refatdsrvnum    like datmservico.atdsrvnum,
    refatdsrvano    like datmservico.atdsrvano,
    socvclcod       like datmservico.socvclcod,
    atdvclsgl       like datmservico.atdvclsgl,
    srrcoddig       like datksrr.srrcoddig,
    srrabvnom       like datksrr.srrabvnom,
    refatdprscod    like datmservico.atdprscod,
    nomgrr          like dpaksocor.nomgrr,
    clscod          char(30),
    clausulas       char(50),
    vctdat          date,
    pgto            char(30),

    #DESCONTO FRANQUIA
    tabnum         smallint,
    frqobrvlr      like abbmcasco.frqvlr,
    dmtobrvlr      like abbmdm.frqvlr,
    dpsobrvlr      like abbmdp.frqvlr,
    bonclacod      like abbmdoc.bonclacod,
    frqpbr         decimal(14,2),
    frqvig         decimal(14,2),
    frqlat         decimal(14,2),
    frqrtr         decimal(14,2),
    texto1         char(34),
    frqdsc         decimal(14,2),
    sinnum         like ssamsin.sinnum,
    texto          char(25),
    dthoje         date,
    frqhoje        decimal(14,2),
    classcod       like abbmdoc.bonclacod,
    classper       like acatbon.bondscper,
    classvlr       like abbmdp.frqvlr,
    cbtstt         like abbmvida2.cbtstt,
    temsinis       char(01),
    viginc         like abbmdoc.viginc,
    viginc1        like abbmdoc.viginc,
    viginc2        like abbmdoc.viginc,
    edsstt         like abamdoc.edsstt,
    dctnumseq      like abamdoc.dctnumseq,

    perfil          char(120),
    msgmid          char(360),

    clcdat         like abbmcasco.clcdat,
    clcdat_dm      like abbmdm.clcdat,
    clcdat_dp      like abbmdp.clcdat
   ,mdtcod         like datmmdtmsg.mdtcod   #PSI 190250
   ,tabname        like systables.tabname   #PSI 190250
 end record
 define l_c24solnom        like datmservico.c24solnom

        define  w_pf1   integer
        define l_status     smallint

        define l_var smallint

## PSI 174 688 - Inicio

define  l_recsvp    record
        vstnumdig   like datmvistoria.vstnumdig,
        vstdat      like datmvistoria.vstdat,
        vstfld      like datmvistoria.vstfld,
        segnom      like datmvistoria.segnom,
        corsus      like datmvistoria.corsus,
        cornom      like datmvistoria.cornom,
        vclmrcnom   like datmvistoria.vclmrcnom,
        vcltipnom   like datmvistoria.vcltipnom,
        vclmdlnom   like datmvistoria.vclmdlnom,
        vcllicnum   like datmvistoria.vcllicnum,
        vclchsnum   like datmvistoria.vclchsnum,
        vclanomdl   like datmvistoria.vclanomdl,
        vclanofbc   like datmvistoria.vclanofbc,
        atdprscod   like datmservico.atdprscod,
        socvclcod   like datmservico.socvclcod,
        atddat      like datmservico.atddat,
        atdhor      like datmservico.atdhor,
        cornom_c    like gcakcorr.cornom,
        cponom      like iddkdominio.cponom,
        descfin     like iddkdominio.cpodes,
        corveic     like iddkdominio.cpodes,
        c24srvdsc   like datmservhist.c24srvdsc,
        pestip      like datmvistoria.pestip,
        cgccpfnum   like datmvistoria.cgccpfnum,
        cgccpfdig   like datmvistoria.cgccpfdig
end record

define r_fgckc811    record
       endlgd          like gcakfilial.endlgd
      ,endnum          like gcakfilial.endnum
      ,endcmp          like gcakfilial.endcmp
      ,endbrr          like gcakfilial.endbrr
      ,endcid          like gcakfilial.endcid
      ,endcep          like gcakfilial.endcep
      ,endcepcmp       like gcakfilial.endcepcmp
      ,endufd          like gcakfilial.endufd
      ,dddcod          like gcakfilial.dddcod
      ,teltxt          like gcakfilial.teltxt
      ,dddfax          like gcakfilial.dddfax
      ,factxt          like gcakfilial.factxt
      ,maides          like gcakfilial.maides
      ,crrdstcod       like gcaksusep.crrdstcod
      ,crrdstnum       like gcaksusep.crrdstnum
      ,crrdstsuc       like gcaksusep.crrdstsuc
      ,status          smallint                   # 0 - OK
                                                  # 1 - SUSEP INEXISTENTE
                                                  # 2 - ENDER. NAO LOCALIZ.
end record

define l_celular char(14)  ## Anatel - char(13)

# para inserir na tabela de SMS
define l_sms record
  smsenvcod  like dbsmenvmsgsms.smsenvcod ,
  celnum     like dbsmenvmsgsms.celnum    ,
  msgtxt     like dbsmenvmsgsms.msgtxt    ,
  envdat     like dbsmenvmsgsms.envdat    ,
  incdat     like dbsmenvmsgsms.incdat    ,
  dddcel     like dbsmenvmsgsms.dddcel
end record
#---------

# verifica se teve erro na gravação
define l_retorno record
    codido  smallint, # esse código é o sqlca.sqlcode
    mensagem  char(30)
  end record
#---------

# para saber qual a ultima etapa do servico e sua hora e data
define msg_sms record
  atdetpdat    like datmsrvacp.atdetpdat,
  atdetphor    like datmsrvacp.atdetphor
end record
#---------------

  if m_prep_sql is null or
     m_prep_sql <> true then
     call cts00g04_prepare()
  end if

## PSI 174 688 - Final

 for     w_pf1  =  1  to  2
         initialize  a_cts00g04[w_pf1].*  to  null
 end     for

 initialize d_cts00g04.*  to null
 initialize a_cts00g04    to null
 initialize ws.*          to null

 #-------------------------------------------------------------------------
 # Checa parametros informados
 #-------------------------------------------------------------------------
 if (param.atdsrvnum  is null   or
     param.atdsrvano  is null)  then
#   error   " Texto ou nro servico nao informado, AVISE INFORMATICA!"
    return
 end if

 #-------------------------------------------------------------------------
 # SQL principal
 #-------------------------------------------------------------------------
 open c_cts00g04_029 using param.atdsrvnum, param.atdsrvano
 fetch c_cts00g04_029 into d_cts00g04.atdsrvnum,
                         d_cts00g04.atdsrvano,
                         ws.atdsrvorg        ,
                         ws.vclcorcod        ,
                         d_cts00g04.vcldes,
                         d_cts00g04.vclanomdl,
                         d_cts00g04.vcllicnum,
                         ws.atdrsdflg,
                         d_cts00g04.atdhorpvt,
                         d_cts00g04.atdprvdat,
                         d_cts00g04.atddatprg,
                         d_cts00g04.atdhorprg,
                         d_cts00g04.atddfttxt,
                         ws.srvprlflg,
                         ws.atdprscod,
                         ws.asitipcod,
                         ws.segnom,
                         l_c24solnom

 if sqlca.sqlcode <> 0  then
    close c_cts00g04_029
    return
 end if

 close c_cts00g04_029

 if ws.atdprscod    is null     and
    param.atdprscod is not null then
    let ws.atdprscod = param.atdprscod
 end if
 if ws.atdsrvorg  =  9  or    # SOCORRO  RE
    ws.atdsrvorg  = 13  then  # SINISTRO RE
    if param.socvclcod  is null   then
#      error   " Codigo do veiculo nao informado, AVISE INFORMATICA!"
       return
    end if
 end if


 if param.atdetpcod is null then
    #---------------------------
    # Verifica etapa do servico
    #---------------------------
    open c_cts00g04_022 using param.atdsrvnum,
                            param.atdsrvano,
                            param.atdsrvnum,
                            param.atdsrvano
    fetch c_cts00g04_022 into param.atdetpcod

    close c_cts00g04_022

 end if

 if param.atdetpcod <>  3 and       # SERVICO ACIONADO/ACOMP
    param.atdetpcod <>  4 and       # SERVICO ACIONADO/FINAL
    param.atdetpcod <>  5 and       # SERVICO CANCELADO
    param.atdetpcod <> 10 then      # SERVICO RETORNO
    return
 end if

 if param.atdetpcod = 5   then      # SERVICO CANCELADO
    if param.flgmsg = "REF"  then
       return
    end if
    if ws.atdsrvorg  =  9  or    # SOCORRO  RE
       ws.atdsrvorg  = 13  then  # SINISTRO RE
       return
    end if
 end if
 # inibido pelo PSI 253006 - Beatriz Araujo - 23/02/2010
 #--------------------------------------
 # Verifica se veiculo tem nro.teletrim
 #--------------------------------------
   if param.socvclcod is not null then
      open c_cts00g04_030 using param.socvclcod
      fetch c_cts00g04_030 into d_cts00g04.atdvclsgl, ws.pgrnum
      close c_cts00g04_030
###   if ws.pgrnum is not null   and
###      ws.pgrnum <> 0          then
###      #-----------------------------------
###      # Acessa nro codigo tabela teletrim
###      #-----------------------------------
###      open c_cts00g04_031 using ws.pgrnum
###
###      whenever error continue
###      fetch c_cts00g04_031 into d_cts00g04.ustcod
###      whenever error continue
###      if sqlca.sqlcode <> 0 then
###         close c_cts00g04_031
###         #return
###      end if
###
###      close c_cts00g04_031
###
###   else
###      return
###   end if
   else
      return   #PSI 190250
   end if

###### fim do PSI 253006
 #-------------------------------
 # Acessa local ocorrencia (QTH)
 #-------------------------------
 call ctx04g00_local_reduzido(param.atdsrvnum, param.atdsrvano, 1)
     returning a_cts00g04[1].lclidttxt thru a_cts00g04[1].lclcttnom,
               ws.sqlcode

 if ws.sqlcode                   <> 0       or
    a_cts00g04[1].lclrefptotxt   = "     "  or
    a_cts00g04[1].lclrefptotxt is null      then
    let a_cts00g04[1].lclrefptotxt = " NAO HA REFERENCIAS DO ENDERECO"
 end if

 #-------------------------------
 # Seleciona tipo envio
 #-------------------------------
 case param.flgmsg
    when "REF"

       #PSI 190250 - retirado acesso ao prestador p/ teletrim

       let d_cts00g04.msgtxt = d_cts00g04.atdvclsgl clipped, "  ",
                      "QRU:",   ws.atdsrvorg         using "&&"     , "/",
                               d_cts00g04.atdsrvnum using "&&&&&&&", "-",
                               d_cts00g04.atdsrvano using "&&",   " ",
                      "Ref: ", a_cts00g04[1].lclrefptotxt clipped,
                               "#"

       call cts00g04_env_msgtel(d_cts00g04.ustcod,
                                "CENTRAL 24H - TRANSMISSAO DE REFERENCIA",
                                d_cts00g04.msgtxt,
                                g_issk.funmat,
                                g_issk.empcod,
                                g_issk.maqsgl,
                                0,
                                param.tipo_programa)

                      returning ws.errcod,
                                ws.sqlcode,
                                ws.mstnum

       if ws.errcod >= 5  then
          return
       end if

    when "SRV"
          #Marcelo - psi178381 JIT
          if ws.atdsrvorg  = 15  then
              call cts00g04_msgjittxt(param.atdsrvnum,
                                      param.atdsrvano)
                                      returning d_cts00g04.msgtxt, l_status
              if l_status <> 0 then
                 error d_cts00g04.msgtxt
                 sleep 3
                 return
              end if

              call cts00g04_env_msgtel(d_cts00g04.ustcod,
                                       "CENTRAL 24H ACIONAMENTO-JIT",
                                       d_cts00g04.msgtxt,
                                       g_issk.funmat,
                                       g_issk.empcod,
                                       g_issk.maqsgl,
                                       0,
                                       param.tipo_programa)
               returning ws.errcod,
                         ws.sqlcode,
                         ws.mstnum

              if ws.errcod >= 5  then
                 return
              end if

          #Marcelo - psi178381 JIT
          else
             # VERIFICA SE AGORA ESTA EM PLANTAO SMS
             if ctc88m00_plantao_sms() then
                   open c_cts00g04_033 using param.atdsrvnum,
                                           param.atdsrvano
                   fetch c_cts00g04_033 into msg_sms.atdetpdat,
                                           msg_sms.atdetphor

                   call cts00g02_busca_cel(param.socvclcod)
                        returning l_celular
                   let l_sms.smsenvcod = "P",param.atdsrvnum using "<<<<<<<<<<",param.atdsrvano using "<<"
                   let l_sms.dddcel = l_celular[1,4]  ## Anatel - [1,2]
                   let l_sms.celnum = l_celular[5,14] ## Anatel - [5,13]
                   let l_sms.msgtxt = "Enviada a QRU ",param.atdsrvnum using "<<<<<<<<<<",
                                      "-",param.atdsrvano using "<<",
                                      " as ", msg_sms.atdetphor," de ",msg_sms.atdetpdat,
                                      " para a viatura ",d_cts00g04.atdvclsgl,"."
                   let l_sms.envdat = today
                   let l_sms.incdat = current
                   call ctb85g02_envia_sms(l_sms.smsenvcod,
                                           l_sms.celnum   ,
                                           l_sms.msgtxt   ,
                                           l_sms.envdat   ,
                                           l_sms.incdat   ,
                                           l_sms.dddcel   )
                       returning l_retorno.mensagem,
                                 l_retorno.codido
                  if l_retorno.codido <> 100 then
                    display  l_retorno.mensagem clipped," ", l_retorno.codido
                  else
                    error "SMS PLANTAO ENVIADO COM SUCESSO - ",
                     param.atdsrvnum using "<<<<<<<<<<",
                     "-", param.atdsrvano using "<<"
                  end if
             end if
             #### inibido pelo PSI 253006 - Beatriz Araujo - 23/02/2010
             ####call cts00g02_laudo (param.atdsrvnum,   #PSI 190250
             ####                     param.atdsrvano,
             ####                     param.socvclcod)
             ####   returning d_cts00g04.msgtxt,
             ####             ws.mdtcod,
             ####             ws.tabname,
             ####             ws.sqlcode
             ####if ws.sqlcode <> 0 then
             ####   error " Erro (",ws.sqlcode,") na tabela ", ws.tabname," !"
             ####   sleep 3
             ####   return
             ####end if
             ####
             ####let l_var = length(d_cts00g04.msgtxt)
             ####let l_var = l_var - 1
             ####let d_cts00g04.msgtxt = d_cts00g04.msgtxt[1,l_var] clipped
             ####                          ," Ref: ",
             ####                          a_cts00g04[1].lclrefptotxt clipped, "#"
             ####
             ####call cts00g04_env_msgtel(d_cts00g04.ustcod,
             ####                         "CENTRAL 24H ACIONAMENTO",  #PSI 190250
             ####                      d_cts00g04.msgtxt,  #PSI 190250
             ####                         g_issk.funmat,
             ####                         g_issk.empcod,
             ####                         g_issk.maqsgl,
             ####                         0,
             ####                         param.tipo_programa)
             ####
             ####               returning ws.errcod,
             ####                         ws.sqlcode,
             ####                         ws.mstnum
             ####
             ####if ws.errcod >= 5  then
             ####   return
             ####end if
             ####   Fim do psi 253006
          end if
## PSI 174 688 - Inicio

    when "SVP"

       open c_cts00g04_025 using  param.atdsrvnum
                               ,param.atdsrvano
       whenever error continue
       fetch c_cts00g04_025 into  l_recsvp.vstnumdig,
                                l_recsvp.vstdat,
                                l_recsvp.vstfld,
                                l_recsvp.segnom,
                                l_recsvp.corsus,
                                l_recsvp.cornom,
                                l_recsvp.vclmrcnom,
                                l_recsvp.vcltipnom,
                                l_recsvp.vclmdlnom,
                                l_recsvp.vcllicnum,
                                l_recsvp.vclchsnum,
                                l_recsvp.vclanomdl,
                                l_recsvp.vclanofbc,
                                l_recsvp.pestip,
                                l_recsvp.cgccpfnum,
                                l_recsvp.cgccpfdig
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Vistoria nao encontrada"
          else
             error "Erro de Acesso a Tabela DATMVISTORIA",
                    sqlca.sqlcode," | ",sqlca.sqlerrd[2]
          end if
          close c_cts00g04_025
          return
       end if

       close c_cts00g04_025

       if  l_recsvp.cgccpfnum = 0      or
           l_recsvp.cgccpfnum is null  then
           let w_cgccpf = " "
       else
           let w_cgccpf = l_recsvp.cgccpfnum using "###,###,###", "-",
                          l_recsvp.cgccpfdig using "&&"
       end if


       open c_cts00g04_023 using  param.atdsrvnum
                               ,param.atdsrvano
       whenever error continue
       fetch c_cts00g04_023 into  l_recsvp.atdprscod
                               ,l_recsvp.socvclcod
                               ,l_recsvp.atddat
                               ,l_recsvp.atdhor
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Servico nao encontrado "
          else
             error "Erro de Acesso a Tabela DATMSERVICO",
                   sqlca.sqlcode," | ",sqlca.sqlerrd[2]
          end if
          close c_cts00g04_023
          return
       end if

       close c_cts00g04_023

       open c_cts00g04_026 using  l_recsvp.corsus
       whenever error continue
       fetch c_cts00g04_026 into  l_recsvp.cornom_c
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Corretor nao encontrado "
          else
             error "Erro de Acesso a Tabela GCAKCORR",
                   sqlca.sqlcode," | ",sqlca.sqlerrd[2]
          end if

          close c_cts00g04_026
          return
       end if

       close c_cts00g04_026

       let l_recsvp.cponom = "vstfld"
       open c_cts00g04_027 using  l_recsvp.cponom,
                                l_recsvp.vstfld
       whenever error continue
       fetch c_cts00g04_027 into  l_recsvp.descfin
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Descricao da Finalidade nao encontrada "
          else
             error "Erro de Acesso a Tabela IDDKDOMINIO",
                   sqlca.sqlcode," | ",sqlca.sqlerrd[2]
          end if

          close c_cts00g04_027
          return
       end if

       close c_cts00g04_027

       let l_recsvp.cponom = "vclcorcod"
       open c_cts00g04_027 using  l_recsvp.cponom,
                                ws.vclcorcod
       whenever error continue
       fetch c_cts00g04_027 into  l_recsvp.corveic
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Cor do Veiculo nao encontrada "
          else
             error "Erro de Acesso a Tabela IDDKDOMINIO",
                   sqlca.sqlcode," | ",sqlca.sqlerrd[2]
          end if
          close c_cts00g04_027
          return
       end if

       close c_cts00g04_027

       open c_cts00g04_028 using  param.atdsrvnum,
                                param.atdsrvano
       whenever error continue
       fetch c_cts00g04_028 into  l_recsvp.c24srvdsc
       whenever error stop
       --if sqlca.sqlcode <> 0 then
       --   if sqlca.sqlcode = notfound then
       --      error "Historico nao encontrado "
       --   else
       --      error "Erro de Acesso a Tabela DATMSRVHIST",
       --            sqlca.sqlcode," | ",sqlca.sqlerrd[2]
       --   end if
       --   return
       --end if

       close c_cts00g04_028

       # miguel
       call fgckc811(l_recsvp.corsus)
                returning  r_fgckc811.*

       let d_cts00g04.msgtxt = "No. Vistoria : ", l_recsvp.vstnumdig using "&&&&&&&&&" clipped, "  ",
                               "Solicitado : ", l_recsvp.atddat clipped, " ", l_recsvp.atdhor clipped, "  ",
                               "Solicitante: ", l_c24solnom, "  ",
                               "Finalidade : ", l_recsvp.descfin clipped, "  ",
                               "Corretor : ", l_recsvp.corsus clipped, " - ", l_recsvp.cornom_c clipped, "  ",
                               "Telefone Corretor : ", r_fgckc811.dddcod, " ", r_fgckc811.teltxt, "  ",

                               "Segurado : ", l_recsvp.segnom clipped, "  ",
                               "CPF/CNPJ : ", w_cgccpf, "  ",
                               "Endereco : ", a_cts00g04[1].lgdtxt clipped, " ", a_cts00g04[1].lclbrrnom clipped,
                               "  ", a_cts00g04[1].cidnom clipped, " ",
                               "Telefone contato : ",a_cts00g04[1].dddcod clipped, " - ",a_cts00g04[1].lcltelnum clipped," ",
                               "Referencia : ", a_cts00g04[1].lclrefptotxt clipped, "  ",
                               "Procurar por : ", a_cts00g04[1].lclcttnom clipped,
                               " ",
                               "Veiculo : ", l_recsvp.vclmrcnom clipped, " ", l_recsvp.vcltipnom clipped,
                               "  ", l_recsvp.vclmdlnom clipped, " ", l_recsvp.corveic clipped, "  ",
                               "Ano/Modelo Veiculo : ", l_recsvp.vclanofbc clipped, "/", l_recsvp.vclanomdl , "  ",
                               "Placa : ", l_recsvp.vcllicnum clipped, "  ",
                               "Chassi : ", l_recsvp.vclchsnum clipped, "  ",
                               "Historico : ", l_recsvp.c24srvdsc clipped

       if length(d_cts00g04.msgtxt) > 360 then
          let ws.msgmid = d_cts00g04.msgtxt[361, 720]
          call cts00g04_env_msgtel(d_cts00g04.ustcod,
                                   "CENTRAL 24H - Transmissao de VP",
                                   ws.msgmid,
                                   g_issk.funmat,
                                   g_issk.empcod,
                                   g_issk.maqsgl,
                                   0,
                                   param.tipo_programa)

                         returning ws.errcod,
                                   ws.sqlcode,
                                   ws.mstnum
          if ws.errcod >= 5  then
             return
          end if
       end if

       let ws.msgmid = d_cts00g04.msgtxt[1, 360]
       call cts00g04_env_msgtel(d_cts00g04.ustcod,
                                "CENTRAL 24H - Transmissao de VP",
                                ws.msgmid,
                                g_issk.funmat,
                                g_issk.empcod,
                                g_issk.maqsgl,
                                0,
                                param.tipo_programa)

                         returning ws.errcod,
                                   ws.sqlcode,
                                   ws.mstnum
       if ws.errcod >= 5  then
          return
       end if

## PSI 174 688 - Final

 end case

end function  ###--- cts00g04_msgsrv


#-----------------------------------
function cts00g04_env_msgtel(param)
#-----------------------------------

 define param       record
    ustcod          like htlrust.ustcod,
    titulo          char (40),
    msgtxt          char (880),    #PSI 190250
    funmat          like isskfunc.funmat,
    empcod          like isskfunc.empcod,
    maqsgl          like ismkmaq.maqsgl,
    tltmvtnum       like datmtltmsglog.tltmvtnum,
    tipo_programa   char(1)     # "B" --> BATCH  "O"  --> ONLINE
 end record

 define ws          record
    errcod          smallint,
    sqlcode         integer,
    mstnum          like htlmmst.mstnum,
    atldat          like datmtltmsglog.atldat,
    atlhor          like datmtltmsglog.atlhor,
    atlhorant       like datmtltmsglog.atlhor,
    mststt          like datmtltmsglog.mststt,
    mstnumseq       like datmtltmsglog.mstnumseq
 end record

 define l_pgrnum    like htlrust.pgrnum

 ##define arr_aux   integer
 ##
 ##define l_data    date,
 ##       l_hora1   datetime hour to second
 ##
 ##       let     arr_aux  =  null
 ##
 initialize  ws.*  to  null

 let l_pgrnum = null

 ##call cts40g03_data_hora_banco(1)
 ##     returning l_data, l_hora1
 ##let ws.atlhorant = l_hora1

  if m_prep_sql is null or
     m_prep_sql <> true then
     call cts00g04_prepare()
  end if

  # -> BUSCA O NUMERO DO PAGER
  open c_cts00g04_032 using param.ustcod
  fetch c_cts00g04_032 into l_pgrnum
  close c_cts00g04_032

  call ctx01g07_pager_simples(l_pgrnum, param.msgtxt)

  let ws.errcod  = 0
  let ws.sqlcode = 0
  let ws.mstnum  = 0

  if param.tipo_programa = "O" then # -->PROGRAMA ONLINE
     message " Mensagem enviada com sucesso!"
  end if

 ##call fptla025_usuario(param.ustcod,   ## NRO.CODIGO TELETRIM
 ##                      param.titulo,   ## TITULO DA MENSAGEM
 ##                      param.msgtxt,   ## TEXTO DA MENSAGEM 9 x 40
 ##                      param.funmat,   ## MATRICULA FUNCIONARIO
 ##                      param.empcod,   ## EMPRESA FUNCIONARIO
 ##                      false,          ## 0 = NAO 1 = CONTROLAR TRANSACAO
 ##                      "O",            ## B = batch ou O = online
 ##                      "M",            ## D = discada  M = mailtrim
 ##                      "",             ## DATA TRANSMISSAO
 ##                      "",             ## HORA TRANSMISSAO
 ##                      param.maqsgl)   ## SERVIDOR APLICACAO OU BANCO
 ##            returning ws.errcod,
 ##                      ws.sqlcode,
 ##                      ws.mstnum
 ##if ws.errcod >= 5  then
 ##   error "Erro (", ws.sqlcode, ") na gravacao da interface com",
 ##                " Teletrim. AVISE A INFORMATICA!"
 ##else
 ##
 ##   if param.tipo_programa = "O" then # -->PROGRAMA ONLINE
 ##      message " Mensagem enviada com sucesso!"
 ##   end if
 ##
 ##end if
 ##for arr_aux = 1 to 2
 ##    call cts40g03_data_hora_banco(1)
 ##         returning l_data, l_hora1
 ##   let ws.atldat = l_data
 ##   let ws.atlhor = l_hora1
 ##   let ws.mststt = ws.errcod + 1
 ##
 ##   if arr_aux = 1 then
 ##      let ws.atlhor = ws.atlhorant
 ##      let ws.mststt = 0
 ##   end if
 ##
 ##   whenever error continue
 ##
 ##   insert into datmtltmsglog (mstnum,
 ##                              mstnumseq,
 ##                              tltmvtnum,
 ##                              mststt,
 ##                              atldat,
 ##                              atlhor,
 ##                              atlemp,
 ##                              atlmat,
 ##                              atlusrtip)
 ##                      values (ws.mstnum,
 ##                              arr_aux  ,
 ##                              param.tltmvtnum,
 ##                              ws.mststt,
 ##                              ws.atldat,
 ##                              ws.atlhor,
 ##                              param.empcod,
 ##                              param.funmat,
 ##                              g_issk.usrtip)
 ##end for
 ##whenever error stop

 return ws.errcod, ws.sqlcode, ws.mstnum

end function #-- cts00g04_env_msgtel

#----------------------------------------------------------------------
 function cts00g04_msgjit(param)
#----------------------------------------------------------------------

 define param       record
    atdsrvnum       like datmmdtsrv.atdsrvnum,
    atdsrvano       like datmmdtsrv.atdsrvano
 end record

 define ws          record
    socvclcod       like datkveiculo.socvclcod,
    atdetpcod       like datmsrvacp.atdetpcod,
    atdprscod       like datmservico.atdprscod
 end record

  if m_prep_sql is null or
     m_prep_sql <> true then
     call cts00g04_prepare()
  end if

 select atdprscod,
        socvclcod
        into ws.atdprscod,
             ws.socvclcod
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 select atdetpcod
   into ws.atdetpcod
   from datmsrvacp
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdsrvseq = (select max(atdsrvseq)
                       from datmsrvacp
                      where atdsrvnum = param.atdsrvnum
                        and atdsrvano = param.atdsrvano)

 call cts00g04_msgsrv( param.atdsrvnum,
                       param.atdsrvano,
                       ws.socvclcod,
                       ws.atdetpcod,
                       ws.atdprscod,
                       "SRV",
                       "O")

end function #-- cts00g04_msgsrv

## PSI 174 688 - Inicio

#----------------------------------------------------------------------
 function cts00g04_msgvp(l_param)
#----------------------------------------------------------------------

   define l_param     record
      atdsrvnum       like datmmdtsrv.atdsrvnum,
      atdsrvano       like datmmdtsrv.atdsrvano
   end record

   define l_ws        record
      socvclcod       like datkveiculo.socvclcod,
      atdetpcod       like datmsrvacp.atdetpcod,
      atdprscod       like datmservico.atdprscod,
      atddat          like datmservico.atddat,
      atdhor          like datmservico.atdhor
   end record

    if m_prep_sql is null or
       m_prep_sql <> true then
       call cts00g04_prepare()
    end if

   open c_cts00g04_023 using  l_param.atdsrvnum
                           ,l_param.atdsrvano
   whenever error continue
   fetch c_cts00g04_023 into  l_ws.atdprscod
                           ,l_ws.socvclcod
                           ,l_ws.atddat
                           ,l_ws.atdhor
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error "Servico nao encontrado (1)"
      else
         error "Erro de Acesso a Tabela DATMSERVICO",
                 sqlca.sqlcode," | ",sqlca.sqlerrd[2]
      end if
      close c_cts00g04_023
      return
   end if

   close c_cts00g04_023

   open c_cts00g04_024 using  l_param.atdsrvnum
                           ,l_param.atdsrvano
   whenever error continue
   fetch c_cts00g04_024 into  l_ws.socvclcod
                           ,l_ws.atdetpcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error "Servico nao encontrado (2)"
      else
         error "Erro de Acesso a Tabela DATMSRVACP",
                 sqlca.sqlcode," | ",sqlca.sqlerrd[2]
      end if
      return
   end if

   close c_cts00g04_024

   call cts00g04_msgsrv(l_param.atdsrvnum,
                        l_param.atdsrvano,
                        l_ws.socvclcod,
                        l_ws.atdetpcod,
                        l_ws.atdprscod,
                        "SVP",
                        "O")

end function

## PSI 174 688 - Final

# PSI178381 - Marcelo - inicio
#-------------------------------------#
 function cts00g04_msgjittxt(lr_param)
#-------------------------------------#
 define lr_param record
    atdsrvnum like datmmdtsrv.atdsrvnum,
    atdsrvano like datmmdtsrv.atdsrvano
 end record

  define lr_ws      record
                       campo           char (40),
                       msgpvt          char (40),
                       msgpgttxt       char (50),
                       pgrnum          like datkveiculo.pgrnum,
                       atdsrvorg       like datmservico.atdsrvorg,
                       orrdat          like datmsrvre.orrdat,
                       orrhor          like datmsrvre.orrhor,
                       socntzcod       like datmsrvre.socntzcod,
                       sinntzcod       like sgaknatur.sinntzcod,
                       atdetpcod       like datmsrvacp.atdetpcod,
                       natureza        char (40),
                       mstnum          like htlmmst.mstnum,
                       errcod          smallint,
                       atdrsdflg       like datmservico.atdrsdflg,
                       srvprlflg       like datmservico.srvprlflg,
                       vclcorcod       like datmservico.vclcorcod,
                       asitipcod       like datmservico.asitipcod,
                       atdprscod       like datmservico.atdprscod,
                       rmcacpflg       like datmservicocmp.rmcacpflg,
                       sqlcode         integer,
                       sindat          like datmservicocmp.sindat,
                       sinhor          like datmservicocmp.sinhor,
                       succod          like datrservapol.succod,
                       aplnumdig       like datrservapol.aplnumdig,
                       itmnumdig       like datrservapol.itmnumdig,
                       edsnumref       like datrservapol.edsnumref,
                       segnom          like datmservico.nom,
                       clalclcod       like abbmdoc.clalclcod,
                       vigfnl          like abbmdoc.vigfnl,
                       cbtcod          like abbmcasco.cbtcod,
                       ctgtrfcod       like abbmcasco.ctgtrfcod,
                       bondscper       like abbmcasco.bondscper,
                       frqvlr          like abbmcasco.frqvlr,
                       casco           like abbmcasco.imsvlr,
                       dm              like abbmdm.imsvlr,
                       dp              like abbmdp.imsvlr,
                       refatdsrvnum    like datmservico.atdsrvnum,
                       refatdsrvano    like datmservico.atdsrvano,
                       socvclcod       like datmservico.socvclcod,
                       atdvclsgl       like datmservico.atdvclsgl,
                       srrcoddig       like datksrr.srrcoddig,
                       srrabvnom       like datksrr.srrabvnom,
                       refatdprscod    like datmservico.atdprscod,
                       nomgrr          like dpaksocor.nomgrr,
                       clscod          char(30),
                       clscodant       char(30),
                       clausulas       char(50),
                       vctdat          date,
                       pgto            char(30),
                       #DESCONTO FRANQUIA
                       tabnum         smallint,
                       frqobrvlr      like abbmcasco.frqvlr,
                       dmtobrvlr      like abbmdm.frqvlr,
                       dpsobrvlr      like abbmdp.frqvlr,
                       bonclacod      like abbmdoc.bonclacod,
                       frqpbr         decimal(14,2),
                       frqvig         decimal(14,2),
                       frqlat         decimal(14,2),
                       frqrtr         decimal(14,2),
                       texto1         char(34),
                       frqdsc         decimal(14,2),
                       sinnum         like ssamsin.sinnum,
                       texto          char(25),
                       dthoje         date,
                       frqhoje        decimal(14,2),
                       classcod       like abbmdoc.bonclacod,
                       classper       like acatbon.bondscper,
                       classvlr       like abbmdp.frqvlr,
                       cbtstt         like abbmvida2.cbtstt,
                       temsinis       char(01),
                       viginc         like abbmdoc.viginc,
                       viginc1        like abbmdoc.viginc,
                       viginc2        like abbmdoc.viginc,
                       edsstt         like abamdoc.edsstt,
                       dctnumseq      like abamdoc.dctnumseq,
                       perfil          char(120),
                       msgmid          char(360),
                       clcdat         like abbmcasco.clcdat,
                       clcdat_dm      like abbmdm.clcdat,
                       clcdat_dp      like abbmdp.clcdat
                     end record

 define lr_cts00g04  record
                       atdsrvnum       like datmservico.atdsrvnum,
                       atdsrvano       like datmservico.atdsrvano,
                       vcldes          like datmservico.vcldes,
                       vclcordes       char (20)              ,
                       vclanomdl       like datmservico.vclanomdl,
                       vcllicnum       like datmservico.vcllicnum,
                       atdhorpvt       like datmservico.atdhorpvt,
                       atdprvdat       like datmservico.atdprvdat,
                       atddatprg       like datmservico.atddatprg,
                       atdhorprg       like datmservico.atdhorprg,
                       atddfttxt       like datmservico.atddfttxt,
                       atdvclsgl       like datkveiculo.atdvclsgl,
                       asitipabvdes    like datkasitip.asitipabvdes,
                       roddantxt       like datmservicocmp.roddantxt,
                       ustcod          like htlrust.ustcod,
                       atdrsddes       char (03),
                       rmcacpdes       char (03),
                       msgtxt          char (720)
                     end record
  define al_cts00g04 array[2] of record
                       lclidttxt       like datmlcl.lclidttxt,
                       lgdtxt          char (65),
                       lclbrrnom       like datmlcl.lclbrrnom,
                       endzon          like datmlcl.endzon,
                       cidnom          like datmlcl.cidnom,
                       ufdcod          like datmlcl.ufdcod,
                       lclrefptotxt    like datmlcl.lclrefptotxt,
                       dddcod          like datmlcl.dddcod,
                       lcltelnum       like datmlcl.lcltelnum,
                       lclcttnom       like datmlcl.lclcttnom
                     end record

 define l_var        smallint,
        l_i          integer,
        l_status     smallint,
        l_lixo       char(040)

 define l_data       date,
        l_hora1      datetime hour to second

 initialize lr_cts00g04.* to null
 initialize lr_ws.*       to null

  if m_prep_sql is null or
     m_prep_sql <> true then
     call cts00g04_prepare()
  end if

 for l_i = 1 to 2
   initialize  al_cts00g04[l_i].*  to  null
 end for

 open c_cts00g04_022 using lr_param.atdsrvnum,lr_param.atdsrvano,
                         lr_param.atdsrvnum,lr_param.atdsrvano
 whenever error continue
 fetch c_cts00g04_022 into lr_ws.atdetpcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_ws.atdetpcod = 0
    else
       error 'Problemas de acesso a tabela datmsrvacp, ',
       sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       sleep 2
       let l_status = 1
       let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datmsrvacp, ',
                                ' contate a informatica!!! '
       close c_cts00g04_022
       return lr_cts00g04.msgtxt,l_status
    end if
 end if

 close c_cts00g04_022

 #select principal
 open c_cts00g04_021 using lr_param.atdsrvnum,
                         lr_param.atdsrvano
 whenever error continue
 fetch c_cts00g04_021 into lr_cts00g04.atdsrvnum,
                         lr_cts00g04.atdsrvano,
                         lr_ws.atdsrvorg        ,
                         lr_ws.vclcorcod        ,
                         lr_cts00g04.vcldes,
                         lr_cts00g04.vclanomdl,
                         lr_cts00g04.vcllicnum,
                         lr_ws.atdrsdflg,
                         lr_cts00g04.atdhorpvt,
                         lr_cts00g04.atdprvdat,
                         lr_cts00g04.atddatprg,
                         lr_cts00g04.atdhorprg,
                         lr_cts00g04.atddfttxt,
                         lr_ws.srvprlflg,
                         lr_ws.atdprscod,
                         lr_ws.asitipcod,
                         lr_ws.segnom,
                         l_lixo,
                         l_lixo,
                         l_lixo
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       error 'Problemas de acesso a tabela datmservico, ',
       sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       sleep 2
       let l_status = 1
       let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datmservico, ',
                                ' contate a informatica!!! '
       close c_cts00g04_021
       return lr_cts00g04.msgtxt, l_status
    end if
 end if

 close c_cts00g04_021

 #-------------------------------
 # Acessa local ocorrencia (QTH)
 #-------------------------------
 call ctx04g00_local_reduzido(lr_param.atdsrvnum,
                              lr_param.atdsrvano, 1)
                    returning al_cts00g04[1].lclidttxt thru
                              al_cts00g04[1].lclcttnom,
                              lr_ws.sqlcode

 if lr_ws.sqlcode                   <> 0       or
    al_cts00g04[1].lclrefptotxt   = "     "  or
    al_cts00g04[1].lclrefptotxt is null      then
    let al_cts00g04[1].lclrefptotxt = " NAO HA REFERENCIAS DO ENDERECO"
 end if

 #----------------------
 # Complemento servico
 #----------------------
 open c_cts00g04_001 using lr_param.atdsrvnum,
                         lr_param.atdsrvano
 whenever error continue
 fetch c_cts00g04_001 into lr_ws.sindat,
                         lr_ws.sinhor
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       error 'Problemas de acesso a tabela datmservicocmp, ',
              sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       sleep 2
       let l_status = 1
       let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datmservicocmp, ',
                                ' contate a informatica!!! '
       close c_cts00g04_001
       return lr_cts00g04.msgtxt, l_status
    end if
 end if

 close c_cts00g04_001

 #-----------------
 # Cor do veiculo
 #-----------------

 let lr_cts00g04.vclcordes = "N/I"

 open c_cts00g04_002 using lr_ws.vclcorcod
 whenever error continue
 fetch c_cts00g04_002 into lr_cts00g04.vclcordes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       error 'Problemas de acesso a tabela iddkdominio, ',
              sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       sleep 2
       let l_status = 1
       let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela iddkdominio, ',
                                 ' contate a informatica!!! '
       close c_cts00g04_002
       return lr_cts00g04.msgtxt, l_status
    end if
 end if

 close c_cts00g04_002

 #------------------#
 # Monta Mensagem   #
 #------------------#
 if lr_ws.atdetpcod > 5   then
    let lr_ws.msgpgttxt = "*** SERVICO CANCELADO *** "

    let lr_cts00g04.msgtxt = lr_cts00g04.atdvclsgl    clipped, " ",
                     "QRU:", lr_ws.atdsrvorg          using    "&&",      "/",
                             lr_cts00g04.atdsrvnum    using    "&&&&&&&", "-",
                             lr_cts00g04.atdsrvano    using    "&&",      " ",

                     "Tel:", al_cts00g04[1].dddcod    clipped, " ",
                             al_cts00g04[1].lcltelnum using    "<<<<<<<<<"," ", ## Anatel
                             lr_cts00g04.vcldes       clipped, " ",
                             lr_cts00g04.vclanomdl    clipped, " ",

                     "QNR:", lr_cts00g04.vcllicnum    clipped, " ",
                             lr_cts00g04.vclcordes    clipped, " ",

                "ATENCAO: ", lr_ws.msgpgttxt          clipped, "#"
 else
    #---------------------#
    # Local destino  QTI  #
    #---------------------#
    call ctx04g00_local_reduzido(lr_param.atdsrvnum,
                                 lr_param.atdsrvano,
                                 2)
                                 returning al_cts00g04[2].lclidttxt thru
                                           al_cts00g04[2].lclcttnom,
                                           lr_ws.sqlcode

    if lr_ws.sqlcode <> 0  then
       initialize al_cts00g04[2].* to null
    end if

    if lr_ws.srvprlflg = "S"  then
       let lr_ws.msgpgttxt = "**SERVICO PARTICULAR: PAGTO POR CONTA DO CLIENTE**"
    end if

    let lr_cts00g04.msgtxt = lr_cts00g04.atdvclsgl    clipped, " ",
                     "QRU:", lr_ws.atdsrvorg          using    "&&"     , "/",
                             lr_cts00g04.atdsrvnum    using    "&&&&&&&", "-",
                             lr_cts00g04.atdsrvano    using    "&&",      " ",

                "SINISTRO:", lr_ws.sindat,                     " ",
                             lr_ws.sinhor,                     " ",

                     "QTH:", al_cts00g04[1].lclidttxt clipped, " ",
                             al_cts00g04[1].lgdtxt    clipped, " ",
                             al_cts00g04[1].lclbrrnom clipped, " ",
                             al_cts00g04[1].cidnom    clipped, " ",
                             al_cts00g04[1].ufdcod    clipped, " ",

                   "Resp:",  al_cts00g04[1].lclcttnom clipped, " ",

                   "Tel:",   al_cts00g04[1].dddcod    clipped, " ",
                             al_cts00g04[1].lcltelnum using    "<<<<<<<<<"  # Anatel

    if al_cts00g04[2].cidnom is not null and
       al_cts00g04[2].ufdcod is not null and
       cts47g00_mesma_cidsed_cid(al_cts00g04[1].cidnom,
                                 al_cts00g04[1].ufdcod,
                                 al_cts00g04[2].cidnom,
                                 al_cts00g04[2].ufdcod) <> 1 then #mesma cidade
       let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt clipped, " ",
           "QTI:", al_cts00g04[2].lclidttxt  clipped, " ",
                   al_cts00g04[2].lgdtxt     clipped, " ",
                   al_cts00g04[2].lclbrrnom  clipped, " ",
                   al_cts00g04[2].cidnom     clipped, " ",
                   al_cts00g04[2].ufdcod
    end if

    open c_cts00g04_003 using lr_cts00g04.atdsrvnum,
                            lr_cts00g04.atdsrvano
    whenever error continue
    fetch c_cts00g04_003 into lr_ws.succod,
                            lr_ws.aplnumdig,
                            lr_ws.itmnumdig,
                            lr_ws.edsnumref
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          error 'Problemas de acesso a tabela datrservapol, ',
                 sqlca.sqlcode,'/',sqlca.sqlcode
          sleep 2
          let l_status = 1
          let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datrservapol, ',
                                  ' contate a informatica!!! '
          close c_cts00g04_003
          return lr_cts00g04.msgtxt, l_status
       end if
    else
       call f_funapol_ultima_situacao(lr_ws.succod,
                                      lr_ws.aplnumdig,
                                      lr_ws.itmnumdig)
                                      returning g_funapol.*
       open c_cts00g04_004 using lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig,
                               g_funapol.dctnumseq
       whenever error continue
       fetch c_cts00g04_004 into lr_ws.clalclcod,
                               lr_ws.vigfnl,
                               lr_ws.viginc,
                               lr_ws.bonclacod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela abbmdoc, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmdoc, ',
                                      'contate a informatica!!! '
             close c_cts00g04_004
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_004

       open c_cts00g04_005 using lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig,
                               g_funapol.autsitatu
       whenever error continue
       fetch c_cts00g04_005 into lr_ws.cbtcod,
                               lr_ws.ctgtrfcod,
                               lr_ws.bondscper,
                               lr_ws.frqobrvlr,
                               lr_ws.casco,
                               lr_ws.clcdat
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela abbmcasco, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmcasco, ',
                                      'contate a informatica!!! '
             close c_cts00g04_005
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_005

       open c_cts00g04_006 using lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig,
                               g_funapol.dmtsitatu
       whenever error continue
       fetch c_cts00g04_006 into lr_ws.dm, lr_ws.clcdat_dm
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela abbmdm, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmdm, ',
                                      'contate a informatica!!! '
             close c_cts00g04_006
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_006

       open c_cts00g04_007 using lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig,
                               g_funapol.dpssitatu
       whenever error continue
       fetch c_cts00g04_007 into lr_ws.dp, lr_ws.clcdat_dp
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela abbmdm, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmdm, ',
                                      'contate a informatica!!! '
             close c_cts00g04_007
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_007

       if lr_ws.clcdat is null then
          if lr_ws.clcdat_dm is null then
             if lr_ws.clcdat_dp is null then
                let lr_ws.clcdat = lr_ws.viginc
             else
                let lr_ws.clcdat = lr_ws.clcdat_dp
             end if
          else
             let lr_ws.clcdat = lr_ws.clcdat_dm
          end if
       end if

       #---------------------#
       # Percentual de bonus #
       #---------------------#

       let lr_ws.tabnum = F_FUNGERAL_TABNUM("acatbon", lr_ws.viginc)

       open c_cts00g04_008 using lr_ws.tabnum,
                               lr_ws.clalclcod,
                               lr_ws.bonclacod
       whenever error continue
       fetch c_cts00g04_008 into lr_ws.bondscper
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = 100 then
             close c_cts00g04_008
             let l_var = 0
             open c_cts00g04_008 using lr_ws.tabnum,
                                     l_var,
                                     lr_ws.bonclacod
             whenever error continue
             fetch c_cts00g04_008 into lr_ws.bondscper
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   initialize lr_ws.bondscper to null
                   if lr_ws.bonclacod = 0  then
                      initialize lr_ws.bonclacod to null
                   end if
                else
                   error 'Problemas de acesso a tabela acatbon, ',
                          sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                   sleep 2
                   let l_status = 1
                   let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela acatbon, ',
                                            'contate a informatica!!! '
                   return lr_cts00g04.msgtxt, l_status
                end if
             end if
          else
             error 'Problemas de acesso a tabela acatbon, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela acatbon, ',
                                      'contate a informatica!!! '
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_008

       #---------------------------------------#
       # verifica se a apolice e de AUTO+VIDA
       #---------------------------------------#
       let lr_ws.frqdsc    = 0
       let lr_ws.frqvlr    = lr_ws.frqobrvlr
       let lr_ws.classcod  = lr_ws.bonclacod
       let lr_ws.classper  = lr_ws.bondscper

       open c_cts00g04_009 using lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig,
                               lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig
       whenever error continue
       fetch c_cts00g04_009 into lr_ws.cbtstt
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela abbmvida2, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmvida2, ',
                                      'contate a informatica!!! '
             close c_cts00g04_009
             return lr_cts00g04.msgtxt, l_status
          end if
       else
          if lr_ws.cbtstt = "A" then
             call fssac029(g_documento.ramcod,
                           lr_ws.aplnumdig,            #funcao informa
                           lr_ws.succod,
                           lr_ws.itmnumdig,0)          #se o sinistro
                           returning lr_ws.temsinis,   #foi indenizado
                                     lr_ws.sinnum,
                                     lr_ws.orrdat
             if lr_ws.temsinis       = "S"  then
                let lr_ws.sinnum  = lr_ws.sinnum
                let lr_ws.orrdat  = lr_ws.orrdat
                let lr_ws.frqdsc  = 0
             else
                # projeto novos ambientes
                #if g_hostname   =  "u07"  then
                #   open c_cts00g04_010
                #   whenever error continue
                #   fetch c_cts00g04_010 into lr_ws.frqdsc
                #   whenever error stop
                #   if sqlca.sqlcode <> 0 then
                #      if sqlca.sqlcode <> 100 then
                #         error 'Problemas de acesso a tabela igbkgeral, ',
                #                sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                #         sleep 2
                #         let l_status = 1
                #         let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela igbkgeral, ',
                #                                  'contate a informatica!!! '
                #         return lr_cts00g04.msgtxt, l_status
                #      end if
                #   end if
                #
                #   close c_cts00g04_010
                #
                #else
                   open c_cts00g04_011
                   whenever error continue
                   fetch c_cts00g04_011 into lr_ws.frqdsc
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode <> 100 then
                         error 'Problemas de acesso a tabela porto@',m_host clipped,':igbkgeral, ',
                                sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                         sleep 2
                         let l_status = 1
                         let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela porto@u01:igbkgeral, ',
                                                  'contate a informatica!!! '
                         return lr_cts00g04.msgtxt, l_status
                      end if
                   end if

                   close c_cts00g04_011

                #end if
             end if
          end if
       end if

       close c_cts00g04_009

       #---------------------#
       # vigencia da apolice #
       #---------------------#
       open c_cts00g04_012 using lr_ws.succod,
                               lr_ws.aplnumdig
       whenever error continue
       fetch c_cts00g04_012 into lr_ws.viginc
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela abamapol, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abamapol, ',
                                      'contate a informatica!!! '
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_012

       if lr_ws.viginc      >= "15/03/2000" then
          let lr_ws.viginc1  = lr_ws.viginc
       else
          open c_cts00g04_013 using lr_ws.succod,    # procura endosso de substituicao
                                  lr_ws.aplnumdig,
                                  lr_ws.itmnumdig
          whenever error continue
          fetch c_cts00g04_013 into lr_ws.viginc2,
                                  lr_ws.dctnumseq
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
                let lr_ws.viginc1  = lr_ws.viginc
             else
                error 'Problemas de acesso a tabela abbmdoc, ',
                       sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                 sleep 2
                 let l_status = 1
                 let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmdoc, ',
                                          'contate a informatica!!! '
                 return lr_cts00g04.msgtxt, l_status
             end if
          else
             open c_cts00g04_014 using lr_ws.succod,    # verifica se o endosso de substituicao esta ativo
                                     lr_ws.aplnumdig,
                                     lr_ws.dctnumseq
             whenever error continue
             fetch c_cts00g04_014 into lr_ws.edsstt
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> 100 then
                   error 'Problemas de acesso a tabela abamdoc, ',
                          sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                   sleep 2
                   let l_status = 1
                   let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela abbmdoc, ',
                                            'contate a informatica!!! '
                   return lr_cts00g04.msgtxt, l_status
                end if
             end if

             close c_cts00g04_014

             if lr_ws.edsstt    = "A"  then
                let lr_ws.viginc1  = lr_ws.viginc2
             else
                let lr_ws.viginc1  = lr_ws.viginc
             end if
          end if

          close c_cts00g04_013

       end if

       call cts40g03_data_hora_banco(1)
           returning l_data, l_hora1
       let lr_ws.dthoje  =  l_data
#      let lr_ws.frqhoje =  lr_ws.frqvlr - lr_ws.frqdsc

       if lr_ws.clcdat >= "01/07/2003" then
          let lr_ws.frqhoje =  lr_ws.frqvlr
       else
          let lr_ws.frqhoje =  lr_ws.frqvlr - lr_ws.frqdsc
       end if

       if  lr_ws.classcod   >=  5  and           # desc. bonus franquia
           lr_ws.classper   >   0  and
           lr_ws.viginc1            >= "15/03/2000" then
           call fssac029(g_documento.ramcod,   #funcao informa
                         lr_ws.aplnumdig,
                         lr_ws.succod,
                         lr_ws.itmnumdig,
                         0)
                         returning lr_ws.temsinis,  #se o sinistro
                                   lr_ws.sinnum,    #foi indenizado
                                   lr_ws.orrdat

           if lr_ws.temsinis     = "S"  then
              let lr_ws.sinnum   = lr_ws.sinnum
              let lr_ws.orrdat   = lr_ws.orrdat
              let lr_ws.classper = 0
           end if

#          let lr_ws.classvlr  = (lr_ws.classper * lr_ws.frqhoje ) / 100
#          let lr_ws.frqhoje   =  lr_ws.frqhoje  - lr_ws.classvlr

           if lr_ws.clcdat < "01/07/2003" then
              let lr_ws.classvlr  = (lr_ws.classper *
                                     lr_ws.frqhoje ) / 100
           else
              let lr_ws.classvlr  = 0
           end if

           let lr_ws.frqhoje = lr_ws.frqhoje - lr_ws.classvlr

           if lr_ws.classper = 0 then
              initialize lr_ws.classcod to null
              initialize lr_ws.classper to null
           end if
       else
           initialize lr_ws.classcod to null
           initialize lr_ws.classper to null
       end if

       initialize lr_ws.frqobrvlr to null
       #----------fim do auto+vida----------#

       # 1a PARCELA PENDENTE   *** NAO USAR PREPARE ***
       whenever error continue
       select min(vctdat) into lr_ws.vctdat
         from fctrpevparc a,
              fctmtitulos b
        where succod      = lr_ws.succod
          and ramcod      = 531
          and aplnumdig   = lr_ws.aplnumdig
          and a.titnumdig = b.titnumdig
          and parsitcod   = 1

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = 100 then
             let lr_ws.pgto = "APOLICE PAGA"
          else
             error 'Problemas de acesso a tabela fctrpevparc, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela fctrpevparc, ',
                                      'contate a informatica!!! '
             return lr_cts00g04.msgtxt, l_status
          end if
       else
          let lr_ws.pgto = "PGTO_PEND:", lr_ws.vctdat
       end if

       # CLAUSULAS
       open c_cts00g04_016 using lr_ws.succod,
                               lr_ws.aplnumdig,
                               lr_ws.itmnumdig,
                               g_funapol.dctnumseq

       foreach c_cts00g04_016 into lr_ws.clscod

           if lr_ws.clscod <> "034" and
              lr_ws.clscod <> "071" then
              let lr_ws.clscodant = lr_ws.clscod
           end if
           if lr_ws.clscod = "034" or
              lr_ws.clscod = "071" or
              lr_ws.clscod = "077" then # PSI 239.399 Clausula 077

             if cta13m00_verifica_clausula(lr_ws.succod        ,
                                           lr_ws.aplnumdig     ,
                                           lr_ws.itmnumdig     ,
                                           g_funapol.dctnumseq ,
                                           lr_ws.clscod           ) then
                let lr_ws.clscod = lr_ws.clscodant
                continue foreach
             end if
           end if
           if lr_ws.clausulas is null then
              let lr_ws.clausulas = lr_ws.clscod
           else
              let lr_ws.clausulas = lr_ws.clausulas clipped, "/", lr_ws.clscod
           end if

       end foreach

       close c_cts00g04_016

       let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt   clipped, " ",
                         "APL:",lr_ws.aplnumdig      using "<<<<<<<&&", " ",
                        "ITEM:",lr_ws.itmnumdig      using "<<<&&"

       if lr_ws.edsnumref > 0 then
          let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt   clipped, " ",
                           " END:",lr_ws.edsnumref      using "<<<<<<<<&"
       end if

       let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt   clipped, " ",
                     "VIG-FIM:",lr_ws.vigfnl,                 " ",
                                lr_ws.pgto           clipped, " ",
                         "COB:",lr_ws.cbtcod         using    "<<&", " ",
                       "CATEG:",lr_ws.ctgtrfcod      using    "<<&", " ",
                    "CLAS_LOC:",lr_ws.clalclcod      using    "<<&", " ",
                   "CLAUSULAS:",lr_ws.clausulas      clipped, " ",
                       "CASCO:",lr_ws.casco          using    "<<<<<<<<&.&&", " ",
                       "DM/DP:",lr_ws.dm             using    "<<<<<<<<&.&&", "/",
                                lr_ws.dp             using    "<<<<<<<<&.&&", " "
       if lr_ws.bondscper > 0 then
          let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt clipped, " ",
                          "BONUS:",lr_ws.bondscper      using    "<<&.&&", " "
       end if

       let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt   clipped, " ",
                         "SEG:",lr_ws.segnom         clipped, " ",
                    "FR-CHEIA:",lr_ws.frqvlr         using    "<<<<<<<<&.&&", " ",
                     "FR-DESC:",lr_ws.frqhoje        using    "<<<<<<<<&.&&"
       call faemc037(lr_ws.succod,
                     lr_ws.aplnumdig,
                     lr_ws.itmnumdig)
                     returning lr_ws.perfil
    end if

    close c_cts00g04_003

    let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt    clipped, " ",
                     "VEIC:",lr_cts00g04.vcldes    clipped, " ",
                             lr_cts00g04.vclanomdl clipped, " ",
                             lr_cts00g04.vcllicnum clipped, " ",
                             lr_cts00g04.vclcordes clipped, " "

    let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt    clipped, " ",
                             lr_ws.perfil

    open c_cts00g04_017 using lr_param.atdsrvnum,
                            lr_param.atdsrvano
    whenever error continue
    fetch c_cts00g04_017 into lr_ws.refatdsrvnum,
                            lr_ws.refatdsrvano
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          error 'Problemas de acesso a tabela datmsrvjit, ',
                 sqlca.sqlcode,'/',sqlca.sqlerrd[2]
           sleep 2
           let l_status = 1
           let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datmsrvjit, ',
                                    'contate a informatica!!! '
           return lr_cts00g04.msgtxt, l_status
       end if
    else
       open c_cts00g04_021 using lr_ws.refatdsrvnum,
                               lr_ws.refatdsrvano
       whenever error continue
       fetch c_cts00g04_021 into l_lixo,l_lixo,l_lixo,l_lixo,
                               l_lixo,l_lixo,l_lixo,l_lixo,
                               l_lixo,l_lixo,l_lixo,l_lixo,
                               l_lixo,l_lixo,l_lixo,l_lixo,
                               l_lixo,
                               lr_ws.socvclcod,
                               lr_ws.srrcoddig,
                               lr_ws.refatdprscod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> 100 then
             error 'Problemas de acesso a tabela datmservico, ',
                    sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             let l_status = 1
             let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datmservico, ',
                                      'contate a informatica!!! '
             return lr_cts00g04.msgtxt, l_status
          end if
       end if

       close c_cts00g04_021

       if lr_ws.socvclcod > 0 then
          open c_cts00g04_018 using lr_ws.socvclcod
          whenever error continue
          fetch c_cts00g04_018 into lr_ws.atdvclsgl
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> 100 then
                error 'Problemas de acesso a tabela datkveiculo, ',
                       sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                sleep 2
                let l_status = 1
                let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datkveiculo, ',
                                         'contate a informatica!!! '
                return lr_cts00g04.msgtxt, l_status
             end if
          end if

          close c_cts00g04_018

          open c_cts00g04_019 using lr_ws.srrcoddig
          whenever error continue
          fetch c_cts00g04_019 into lr_ws.srrabvnom
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> 100 then
                error 'Problemas de acesso a tabela datksrr, ',
                       sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                sleep 2
                let l_status = 1
                let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela datksrr, ',
                                         'contate a informatica!!! '
                close c_cts00g04_019
                return lr_cts00g04.msgtxt, l_status
             end if
          end if

          close c_cts00g04_019

          let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt clipped,
                       " GUINCHO:",lr_ws.atdvclsgl, " ",
                                   lr_ws.srrabvnom
       else
          open c_cts00g04_020 using lr_ws.refatdprscod
          whenever error continue
          fetch c_cts00g04_020 into lr_ws.nomgrr
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> 100 then
                error 'Problemas de acesso a tabela dpaksocor, ',
                       sqlca.sqlcode,'/',sqlca.sqlerrd[2]
                sleep 2
                let l_status = 1
                let lr_cts00g04.msgtxt = 'Problemas de acesso a tabela dpaksocor, ',
                                         'contate a informatica!!! '
                close c_cts00g04_020
                return lr_cts00g04.msgtxt, l_status
             end if
          end if

          close c_cts00g04_020

          let lr_cts00g04.msgtxt = lr_cts00g04.msgtxt clipped,
                       " GUINCHO:",lr_ws.nomgrr
       end if
    end if

    close c_cts00g04_017

 end if

 let l_status = 0
 return lr_cts00g04.msgtxt, l_status

end function
# PSI178381 - Marcelo - fim
