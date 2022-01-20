#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema.......: CT24H / Automóvel                                           #
# Modulo........: bdata126                                                    #
# Analista Resp.: Nilo Costa                                                  #
# PSI...........: 223689 - Alta Disponibilidade                               #
# Objetivo......: Ler apolices desprezadas na carga do processo diario.       #
#                (ffpwa022 / bdatm003)                                        #
###############################################################################
#.............................................................................#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
#-----------------------------------------------------------------------------#
# 16/06/2012 Johnny Alves    Segregacao Bases                                 #
#            Biztalking                                                       #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/figrc012.4gl"    #Johnny,Biz

database porto
define m_hostname   like ibpkdbspace.srvnom            #Johnny,Biz
      ,m_hostname1  like ibpkdbspace.srvnom

main

define hora_ini  datetime hour to fraction
define hora_fin  datetime hour to fraction
define data_ini  date
define data_fin  date
let data_ini = null
let data_fin = null
let hora_ini = null
let hora_fin = null

let data_ini = today
let hora_ini = current
if not figrc012_sitename('bdata126', '', '') then     #Johnny,Biz
  display 'Erro Selecionando Sitename da dual'
  exit program(1)
end if
let m_hostname  = null
let m_hostname1 = null
call fun_dba_abre_banco("CT24HS")
let m_hostname = fun_dba_servidor("CT24HS")
let m_hostname1 = fun_dba_servidor("EMISAUTO")
set isolation to dirty read
display '#---> INICIO DO PROCESSAMENTO: ' ,data_ini ,'-' ,hora_ini


   call bdata126()

let data_fin = today
let hora_fin = current
display '#---> FIM DO PROCESSAMENTO: ' ,data_fin ,'-' ,hora_fin


end main
#------------------
function bdata126()
#------------------

   define l_data_inicio date

   define lr_abamapol   record
          succod        like abamapol.succod
         ,aplnumdig     like abamapol.aplnumdig
         ,rnvatmflg     like abamapol.rnvatmflg
         ,ciaperptc     like abamapol.ciaperptc
         ,etpnumdig     like abamapol.etpnumdig
         ,aplstt        like abamapol.aplstt
         ,emsdat        like abamapol.emsdat
         ,viginc        like abamapol.viginc
         ,vigfnl        like abamapol.vigfnl
         ,cvnnum        like abamapol.cvnnum
         ,cvnvdaflg     like abamapol.cvnvdaflg
         ,segtip        like abamapol.segtip
         ,poeempcod     like abamapol.poeempcod
         ,corsusldr     like abamapol.corsusldr
         ,poeempcod1    like abamapol.poeempcod1
   end record

   define lr_abbmdoc    record
          succod        like abbmdoc.succod
         ,aplnumdig     like abbmdoc.aplnumdig
         ,itmnumdig     like abbmdoc.itmnumdig
         ,dctnumseq     like abbmdoc.dctnumseq
         ,edstip        like abbmdoc.edstip
         ,edstxt        like abbmdoc.edstxt
         ,prporgidv     like abbmdoc.prporgidv
         ,prpnumidv     like abbmdoc.prpnumidv
         ,prpnumcor     like abbmdoc.prpnumcor
         ,clalclcod     like abbmdoc.clalclcod
         ,vclcircid     like abbmdoc.vclcircid
         ,clctip        like abbmdoc.clctip
         ,viginc        like abbmdoc.viginc
         ,vigfnl        like abbmdoc.vigfnl
         ,segnumdig     like abbmdoc.segnumdig
         ,bonclacod     like abbmdoc.bonclacod
         ,cansinano     like abbmdoc.cansinano
         ,cansinnum     like abbmdoc.cansinnum
         ,cansindat     like abbmdoc.cansindat
         ,itmstt        like abbmdoc.itmstt
         ,clsatmocc     like abbmdoc.clsatmocc
         ,aplemstip     like abbmdoc.aplemstip
         ,segtip        like abbmdoc.segtip
         ,poevintipcod  like abbmdoc.poevintipcod
         ,crpultcod     like abbmdoc.crpultcod
   end record

   define lr_abbmapp    record
          succod        like abbmapp.succod
         ,aplnumdig     like abbmapp.aplnumdig
         ,itmnumdig     like abbmapp.itmnumdig
         ,dctnumseq     like abbmapp.dctnumseq
         ,rsgflg        like abbmapp.rsgflg
         ,imsmda        like abbmapp.imsmda
         ,imsinvtax     like abbmapp.imsinvtax
         ,imsinvvlr     like abbmapp.imsinvvlr
         ,imsmortax     like abbmapp.imsmortax
         ,imsmorvlr     like abbmapp.imsmorvlr
         ,imsdmhtax     like abbmapp.imsdmhtax
         ,imsdmhvlr     like abbmapp.imsdmhvlr
         ,pssqtd        like abbmapp.pssqtd
         ,clcdat        like abbmapp.clcdat
         ,prmfnlvlr     like abbmapp.prmfnlvlr
         ,pandifvlr     like abbmapp.pandifvlr
         ,cbtstt        like abbmapp.cbtstt
         ,sitseqorg     like abbmapp.sitseqorg
   end record

   define lr_abbmcasco  record
          succod        like abbmcasco.succod
         ,aplnumdig     like abbmcasco.aplnumdig
         ,itmnumdig     like abbmcasco.itmnumdig
         ,dctnumseq     like abbmcasco.dctnumseq
         ,ctgtrfcod     like abbmcasco.ctgtrfcod
         ,imsmda        like abbmcasco.imsmda
         ,imstax        like abbmcasco.imstax
         ,imsvlr        like abbmcasco.imsvlr
         ,rsgflg        like abbmcasco.rsgflg
         ,bondscper     like abbmcasco.bondscper
         ,cbtcod        like abbmcasco.cbtcod
         ,frqcfc        like abbmcasco.frqcfc
         ,frqvlr        like abbmcasco.frqvlr
         ,frqclacod     like abbmcasco.frqclacod
         ,frqdscper     like abbmcasco.frqdscper
         ,agrtextax     like abbmcasco.agrtextax
         ,agrmottax     like abbmcasco.agrmottax
         ,prfcfc        like abbmcasco.prfcfc
         ,prfmda        like abbmcasco.prfmda
         ,prfvlr        like abbmcasco.prfvlr
         ,prmfnlvlr     like abbmcasco.prmfnlvlr
         ,pandifvlr     like abbmcasco.pandifvlr
         ,clcdat        like abbmcasco.clcdat
         ,cbtstt        like abbmcasco.cbtstt
         ,sitseqorg     like abbmcasco.sitseqorg
         ,isnipiflg     like abbmcasco.isnipiflg
         ,imsmcdcfc     like abbmcasco.imsmcdcfc
   end record

   define lr_abbmdm     record
          succod        like abbmdm.succod
         ,aplnumdig     like abbmdm.aplnumdig
         ,itmnumdig     like abbmdm.itmnumdig
         ,dctnumseq     like abbmdm.dctnumseq
         ,bondscper     like abbmdm.bondscper
         ,frqclacod     like abbmdm.frqclacod
         ,frqvlr        like abbmdm.frqvlr
         ,frqcfc        like abbmdm.frqcfc
         ,imsmda        like abbmdm.imsmda
         ,imsvlr        like abbmdm.imsvlr
         ,imsniv        like abbmdm.imsniv
         ,ctgtrfcod     like abbmdm.ctgtrfcod
         ,rsgflg        like abbmdm.rsgflg
         ,prmfnlvlr     like abbmdm.prmfnlvlr
         ,pandifvlr     like abbmdm.pandifvlr
         ,prmbasvlr     like abbmdm.prmbasvlr
         ,prmbascfc     like abbmdm.prmbascfc
         ,clcdat        like abbmdm.clcdat
         ,cbtstt        like abbmdm.cbtstt
         ,sitseqorg     like abbmdm.sitseqorg
   end record

   define lr_abbmdp     record
          succod        like abbmdp.succod
        ,aplnumdig      like abbmdp.aplnumdig
        ,itmnumdig      like abbmdp.itmnumdig
        ,dctnumseq      like abbmdp.dctnumseq
        ,bondscper      like abbmdp.bondscper
        ,frqclacod      like abbmdp.frqclacod
        ,frqvlr         like abbmdp.frqvlr
        ,frqcfc         like abbmdp.frqcfc
        ,imsmda         like abbmdp.imsmda
        ,imsvlr         like abbmdp.imsvlr
        ,imsniv         like abbmdp.imsniv
        ,ctgtrfcod      like abbmdp.ctgtrfcod
        ,rsgflg         like abbmdp.rsgflg
        ,prmfnlvlr      like abbmdp.prmfnlvlr
        ,pandifvlr      like abbmdp.pandifvlr
        ,prmbasvlr      like abbmdp.prmbasvlr
        ,prmbascfc      like abbmdp.prmbascfc
        ,clcdat         like abbmdp.clcdat
        ,cbtstt         like abbmdp.cbtstt
        ,sitseqorg      like abbmdp.sitseqorg
   end record

   define lr_abbmveic   record
          succod        like abbmveic.succod
         ,aplnumdig     like abbmveic.aplnumdig
         ,itmnumdig     like abbmveic.itmnumdig
         ,dctnumseq     like abbmveic.dctnumseq
         ,vclcoddig     like abbmveic.vclcoddig
         ,vclanofbc     like abbmveic.vclanofbc
         ,vclanomdl     like abbmveic.vclanomdl
         ,vcllicnum     like abbmveic.vcllicnum
         ,vclchsinc     like abbmveic.vclchsinc
         ,vclchsfnl     like abbmveic.vclchsfnl
         ,vcluso        like abbmveic.vcluso
         ,vsttip        like abbmveic.vsttip
         ,vstnumdig     like abbmveic.vstnumdig
         ,vclcmbcod     like abbmveic.vclcmbcod
         ,vclporqtd     like abbmveic.vclporqtd
         ,vclcpc        like abbmveic.vclcpc
         ,vclatmflg     like abbmveic.vclatmflg
         ,vcltexflg     like abbmveic.vcltexflg
         ,vclmotflg     like abbmveic.vclmotflg
         ,atlult        like abbmveic.atlult
         ,avrexcflg     like abbmveic.avrexcflg
         ,sitseqorg     like abbmveic.sitseqorg
         ,vcl0kmflg     like abbmveic.vcl0kmflg
         ,vclkitgasflg  like abbmveic.vclkitgasflg
         ,vclrnvnum     like abbmveic.vclrnvnum
         ,finflg        like abbmveic.finflg
   end record

   define lr_abbmvida2  record
          succod        like abbmvida2.succod
         ,aplnumdig     like abbmvida2.aplnumdig
         ,itmnumdig     like abbmvida2.itmnumdig
         ,dctnumseq     like abbmvida2.dctnumseq
         ,prmfnlvlr     like abbmvida2.prmfnlvlr
         ,pandifvlr     like abbmvida2.pandifvlr
         ,clcdat        like abbmvida2.clcdat
         ,cbtstt        like abbmvida2.cbtstt
         ,sitseqorg     like abbmvida2.sitseqorg
         ,iofvlr        like abbmvida2.iofvlr
         ,adcfrccfc     like abbmvida2.adcfrccfc
         ,cnjnum        like abbmvida2.cnjnum
         ,prpvdaorg     like abbmvida2.prpvdaorg
         ,prpvdanumdig  like abbmvida2.prpvdanumdig
         ,imsinvvlr     like abbmvida2.imsinvvlr
         ,prmvlr        like abbmvida2.prmvlr
         ,imsmorvlr     like abbmvida2.imsmorvlr
   end record

   define lr_abbm0km    record
          succod        like abbm0km.succod
         ,aplnumdig     like abbm0km.aplnumdig
         ,dctnumseq     like abbm0km.dctnumseq
         ,itmnumdig     like abbm0km.itmnumdig
         ,nfsnum        like abbm0km.nfsnum
         ,nfsemidat     like abbm0km.nfsemidat
         ,nfssaidat     like abbm0km.nfssaidat
         ,nfscnsnom     like abbm0km.nfscnsnom
         ,cnscod        like abbm0km.cnscod
         ,nfsvlr        like abbm0km.nfsvlr
   end record

   define lr_abbmbli    record
          succod        like abbmbli.succod
         ,aplnumdig     like abbmbli.aplnumdig
         ,itmnumdig     like abbmbli.itmnumdig
         ,dctnumseq     like abbmbli.dctnumseq
         ,imsvlr        like abbmbli.imsvlr
   end record

   define lr_abamcor    record
          succod        like abamcor.succod
         ,aplnumdig     like abamcor.aplnumdig
         ,corsus        like abamcor.corsus
         ,corperptc     like abamcor.corperptc
         ,corlidflg     like abamcor.corlidflg
         ,comngcflg     like abamcor.comngcflg
   end record

   define lr_abamdoc    record
          succod        like abamdoc.succod
         ,aplnumdig     like abamdoc.aplnumdig
         ,edsnumdig     like abamdoc.edsnumdig
         ,prporgpcp     like abamdoc.prporgpcp
         ,prpnumpcp     like abamdoc.prpnumpcp
         ,etpendtip     like abamdoc.etpendtip
         ,edsnumref     like abamdoc.edsnumref
         ,comadtcod     like abamdoc.comadtcod
         ,comtaxcod     like abamdoc.comtaxcod
         ,cobadcflg     like abamdoc.cobadcflg
         ,edsquecan     like abamdoc.edsquecan
         ,edsstt        like abamdoc.edsstt
         ,cptdat        like abamdoc.cptdat
         ,emsdat        like abamdoc.emsdat
         ,dctnumseq     like abamdoc.dctnumseq
         ,pgtfrm        like abamdoc.pgtfrm
         ,parqtd        like abamdoc.parqtd
         ,onscod        like abamdoc.onscod
         ,prmmda        like abamdoc.prmmda
         ,imsmda        like abamdoc.imsmda
         ,unocod        like abamdoc.unocod
         ,emsunocod     like abamdoc.emsunocod
         ,dctemsprvflg  like abamdoc.dctemsprvflg
   end record

   define lr_abbmclaus  record
          succod        like abbmclaus.succod
         ,aplnumdig     like abbmclaus.aplnumdig
         ,itmnumdig     like abbmclaus.itmnumdig
         ,dctnumseq     like abbmclaus.dctnumseq
         ,clscod        like abbmclaus.clscod
         ,clscfc        like abbmclaus.clscfc
         ,prmcobflg     like abbmclaus.prmcobflg
         ,viginc        like abbmclaus.viginc
         ,vigfnl        like abbmclaus.vigfnl
         ,clsvlr        like abbmclaus.clsvlr
         ,prmfnlvlr     like abbmclaus.prmfnlvlr
         ,pandifvlr     like abbmclaus.pandifvlr
         ,frqvlr        like abbmclaus.frqvlr
         ,ltrvdrfrqvlr  like abbmclaus.ltrvdrfrqvlr
         ,rtvfrqvlr     like abbmclaus.rtvfrqvlr
         ,lntfrlfrqvlr  like abbmclaus.lntfrlfrqvlr
   end record

   define lr_abbmcondesp record
          succod         like abbmcondesp.succod
         ,aplnumdig      like abbmcondesp.aplnumdig
         ,itmnumdig      like abbmcondesp.itmnumdig
         ,dctnumseq      like abbmcondesp.dctnumseq
         ,cndeslcod      like abbmcondesp.cndeslcod
         ,cndeslcfc      like abbmcondesp.cndeslcfc
   end record

   define lr_abbmitem     record
          succod          like abbmitem.succod
         ,aplnumdig       like abbmitem.aplnumdig
         ,itmnumdig       like abbmitem.itmnumdig
         ,rnvsuccod       like abbmitem.rnvsuccod
         ,rnvaplnum       like abbmitem.rnvaplnum
         ,rnvitmnum       like abbmitem.rnvitmnum
         ,rnvoutcia       like abbmitem.rnvoutcia
         ,emsdat          like abbmitem.emsdat
         ,viginc          like abbmitem.viginc
         ,vigfnl          like abbmitem.vigfnl
         ,itmsttatu       like abbmitem.itmsttatu
         ,vclsitatu       like abbmitem.vclsitatu
         ,autsitatu       like abbmitem.autsitatu
         ,dmtsitatu       like abbmitem.dmtsitatu
         ,dpssitatu       like abbmitem.dpssitatu
         ,appsitatu       like abbmitem.appsitatu
         ,vidsitatu       like abbmitem.vidsitatu
         ,aplquernv       like abbmitem.aplquernv
         ,itmquernv       like abbmitem.itmquernv
         ,antaplsinflg    like abbmitem.antaplsinflg
         ,przdntrnvflg    like abbmitem.przdntrnvflg
         ,bonrpvsuccod    like abbmitem.bonrpvsuccod
         ,bonrpvaplnumdig like abbmitem.bonrpvaplnumdig
         ,bonrpvitmnumdig like abbmitem.bonrpvitmnumdig
         ,bonrpvtip       like abbmitem.bonrpvtip
   end record

   define lr_abbmquestionario record
          succod              like abbmquestionario.succod
         ,aplnumdig           like abbmquestionario.aplnumdig
         ,itmnumdig           like abbmquestionario.itmnumdig
         ,dctnumseq           like abbmquestionario.dctnumseq
         ,qstcod              like abbmquestionario.qstcod
         ,rspcod              like abbmquestionario.rspcod
         ,rspdat              like abbmquestionario.rspdat
         ,c18tipcod           like abbmquestionario.c18tipcod
         ,rsppto              like abbmquestionario.rsppto
   end record

   define lr_abbmquesttxt     record
          succod              like abbmquesttxt.succod
         ,aplnumdig           like abbmquesttxt.aplnumdig
         ,itmnumdig           like abbmquesttxt.itmnumdig
         ,dctnumseq           like abbmquesttxt.dctnumseq
         ,qstcod              like abbmquesttxt.qstcod
         ,rspcod              like abbmquesttxt.rspcod
         ,rspdat              like abbmquesttxt.rspdat
         ,txtlin              like abbmquesttxt.txtlin
         ,c18tipcod           like abbmquesttxt.c18tipcod
         ,rsppto              like abbmquesttxt.rsppto
   end record

   define lr_abcmaces         record
          succod              like abcmaces.succod
         ,aplnumdig           like abcmaces.aplnumdig
         ,itmnumdig           like abcmaces.itmnumdig
         ,assnum              like abcmaces.assnum
         ,asstip              like abcmaces.asstip
         ,asscoddig           like abcmaces.asscoddig
         ,assritflg           like abcmaces.assritflg
         ,asssitatu           like abcmaces.asssitatu
         ,asssttatu           like abcmaces.asssttatu
   end record

   define lr_abcmdoc          record
          succod              like abcmdoc.succod
         ,aplnumdig           like abcmdoc.aplnumdig
         ,itmnumdig           like abcmdoc.itmnumdig
         ,assnum              like abcmdoc.assnum
         ,dctnumseq           like abcmdoc.dctnumseq
         ,assdescmp           like abcmdoc.assdescmp
         ,imstax              like abcmdoc.imstax
         ,imsmda              like abcmdoc.imsmda
         ,imsvlr              like abcmdoc.imsvlr
         ,imstaxinf           like abcmdoc.imstaxinf
         ,frqcfc              like abcmdoc.frqcfc
         ,frqvlr              like abcmdoc.frqvlr
         ,clcdat              like abcmdoc.clcdat
         ,prmfnlvlr           like abcmdoc.prmfnlvlr
         ,pandifvlr           like abcmdoc.pandifvlr
         ,assstt              like abcmdoc.assstt
         ,sitseqorg           like abcmdoc.sitseqorg
   end record

   define lr_abdmparc         record
          succod              like abdmparc.succod
         ,aplnumdig           like abdmparc.aplnumdig
         ,itmnumdig           like abdmparc.itmnumdig
         ,autparliqvlr        like abdmparc.autparliqvlr
         ,assparliqvlr        like abdmparc.assparliqvlr
         ,dmtparliqvlr        like abdmparc.dmtparliqvlr
         ,dpsparliqvlr        like abdmparc.dpsparliqvlr
         ,appparliqvlr        like abdmparc.appparliqvlr
         ,adcfrcvlr           like abdmparc.adcfrcvlr
         ,cstaplvlr           like abdmparc.cstaplvlr
         ,iofvlr              like abdmparc.iofvlr
         ,dctnumseq           like abdmparc.dctnumseq
         ,parnum              like abdmparc.parnum
         ,vctdat              like abdmparc.vctdat
         ,notcmpflg           like abdmparc.notcmpflg
         ,parsitcod           like abdmparc.parsitcod
         ,parmda              like abdmparc.parmda
         ,titnumdig           like abdmparc.titnumdig
   end record

   define lr_abamdoc_rec  record
          succod          like abamapol.succod
         ,aplnumdig       like abamapol.aplnumdig
   end record

   define l_sql         char(3000)
   define l_lidos       dec(9,0)
   define l_carregados  dec(9,0)
   define l_desprezados dec(9,0)
   define l_disp        dec(9,0)
   define l_dpz_flg     smallint
   define aux_questionario  dec(5,0)
   define i             smallint

   define l_srvnom char(09)

   initialize lr_abamapol.*         to null
   initialize lr_abbmdoc.*          to null
   initialize lr_abbmapp.*          to null
   initialize lr_abbmcasco.*        to null
   initialize lr_abbmdm.*           to null
   initialize lr_abbmdp.*           to null
   initialize lr_abbmveic.*         to null
   initialize lr_abbmvida2.*        to null
   initialize lr_abbm0km.*          to null
   initialize lr_abbmbli.*          to null
   initialize lr_abamcor.*          to null
   initialize lr_abamdoc.*          to null
   initialize lr_abbmclaus.*        to null
   initialize lr_abbmcondesp.*      to null
   initialize lr_abbmitem.*         to null
   initialize lr_abbmquestionario.* to null
   initialize lr_abbmquesttxt.*     to null
   initialize lr_abcmaces.*         to null
   initialize lr_abcmdoc.*          to null
   initialize lr_abdmparc.*         to null
   initialize lr_abamdoc_rec.*      to null

   let i = null
   let l_sql = null
   let l_srvnom = null
   let l_lidos       = null
   let l_carregados  = null
   let l_desprezados = null
   let l_dpz_flg     = null
   let l_disp        = null
   let aux_questionario = null
   let l_data_inicio = null

   #let l_srvnom = 'u18w'      #TESTE

   #---------------------------------------------------------------
   # Define data parametro
   #---------------------------------------------------------------
    let l_data_inicio = arg_val(1)

   if l_data_inicio is null       or
      l_data_inicio =  "  "       then
      if time >= "17:00"  and
         time <= "23:59"  then
         let l_data_inicio = today
      else
         let l_data_inicio = today - 1
      end if
   else
      if l_data_inicio > today       or
         length(l_data_inicio) < 10  then
         display "     *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
         exit program (1)
      end if
   end if


   #let l_sql = " select unique itmnumdig from porto@u01:abbmdoc ",
   #            "  where succod = ? and aplnumdig = ? "
   #prepare p_abbmdoc01 from l_sql
   #declare c_abbmdoc01 cursor with hold for p_abbmdoc01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmdoc ",
               "  where succod    = ? ",
               "    and aplnumdig = ? "
   prepare p_abbmdoc02 from l_sql
   declare c_abbmdoc02 cursor with hold for p_abbmdoc02

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmapp ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbmapp01 from l_sql
   declare c_abbmapp01 cursor with hold for p_abbmapp01

   #let l_sql = " select * from porto@u01:abbmcasco ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? ",
   #            "    and itmnumdig = ? ",
   #            "    and dctnumseq = ? "
   #prepare p_abbmcasco01 from l_sql
   #declare c_abbmcasco01 cursor with hold for p_abbmcasco01

   #let l_sql = " select * from porto@u01:abbmdm ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? ",
   #            "    and itmnumdig = ? ",
   #            "    and dctnumseq = ? "
   #prepare p_abbmdm01 from l_sql
   #declare c_abbmdm01 cursor with hold for p_abbmdm01

   #let l_sql = " select * from porto@u01:abbmdp ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? ",
   #            "    and itmnumdig = ? ",
   #            "    and dctnumseq = ? "
   #prepare p_abbmdp01 from l_sql
   #declare c_abbmdp01 cursor with hold for p_abbmdp01

   #let l_sql = " select * from porto@u01:abbmveic ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? ",
   #            "    and itmnumdig = ? ",
   #            "    and dctnumseq = ? "
   #prepare p_abbmveic01 from l_sql
   #declare c_abbmveic01 cursor with hold for p_abbmveic01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmvida2 ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbmvida201 from l_sql
   declare c_abbmvida201 cursor with hold for p_abbmvida201

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbm0km ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbm0km01 from l_sql
   declare c_abbm0km01 cursor with hold for p_abbm0km01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmbli ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbmbli01 from l_sql
   declare c_abbmbli01 cursor with hold for p_abbmbli01

   #let l_sql = " select * from porto@u01:abamcor ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? "
   #prepare p_abamcor01 from l_sql
   #declare c_abamcor01 cursor with hold for p_abamcor01

   #let l_sql = " select * from porto@u01:abamdoc ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? ",
   #            "  order by edsnumdig desc "
   #prepare p_abamdoc01 from l_sql
   #declare c_abamdoc01 cursor with hold for p_abamdoc01

   #let l_sql = " select * from porto@u01:abbmclaus ",
   #            "  where succod    = ? ",
   #            "    and aplnumdig = ? ",
   #            "    and itmnumdig = ? ",
   #            "    and dctnumseq = ? "
   #prepare p_abbmclaus01 from l_sql
   #declare c_abbmclaus01 cursor with hold for p_abbmclaus01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmcondesp ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbmcondesp01 from l_sql
   declare c_abbmcondesp01 cursor with hold for p_abbmcondesp01

#   let l_sql = " select * from porto@u01:abbmitem ",
#               "  where succod    = ? ",
#               "    and aplnumdig = ? ",
#               "    and itmnumdig = ? "
#   prepare p_abbmitem01 from l_sql
#   declare c_abbmitem01 cursor with hold for p_abbmitem01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmquestionario ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbmquestionario01 from l_sql
   declare c_abbmquestionario01 cursor with hold for p_abbmquestionario01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abbmquesttxt ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abbmquesttxt01 from l_sql
   declare c_abbmquesttxt01 cursor with hold for p_abbmquesttxt01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abcmaces ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? "
   prepare p_abcmaces01 from l_sql
   declare c_abcmaces01 cursor with hold for p_abcmaces01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abcmdoc ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abcmdoc01 from l_sql
   declare c_abcmdoc01 cursor with hold for p_abcmdoc01

   let l_sql = " select * from porto@",m_hostname1 clipped,":abdmparc ",
               "  where succod    = ? ",
               "    and aplnumdig = ? ",
               "    and itmnumdig = ? ",
               "    and dctnumseq = ? "
   prepare p_abdmparc01 from l_sql
   declare c_abdmparc01 cursor with hold for p_abdmparc01

#   let l_sql = " insert into porto@",l_srvnom ,":abamapol_atd ",
#                          " (succod      ",
#                          " ,aplnumdig   ",
#                          " ,rnvatmflg   ",
#                          " ,ciaperptc   ",
#                          " ,etpnumdig   ",
#                          " ,aplstt      ",
#                          " ,emsdat      ",
#                          " ,viginc      ",
#                          " ,vigfnl      ",
#                          " ,cvnnum      ",
#                          " ,cvnvdaflg   ",
#                          " ,segtip      ",
#                          " ,poeempcod   ",
#                          " ,corsusldr   ",
#                          " ,poeempcod1) ",
#                          " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
#   prepare p_ins_abamapol from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abbmdoc_atd (succod     ",
   #                                " ,aplnumdig  ",
   #                                " ,itmnumdig  ",
   #                                " ,dctnumseq  ",
   #                                " ,edstip     ",
   #                                " ,edstxt     ",
   #                                " ,prporgidv  ",
   #                                " ,prpnumidv  ",
   #                                " ,prpnumcor  ",
   #                                " ,clalclcod  ",
   #                                " ,vclcircid  ",
   #                                " ,clctip     ",
   #                                " ,viginc     ",
   #                                " ,vigfnl     ",
   #                                " ,segnumdig  ",
   #                                " ,bonclacod   ",
   #                                " ,cansinano   ",
   #                                " ,cansinnum   ",
   #                                " ,cansindat   ",
   #                                " ,itmstt      ",
   #                                " ,clsatmocc   ",
   #                                " ,aplemstip   ",
   #                                " ,segtip      ",
   #                                " ,poevintipcod ",
   #                                " ,crpultcod)  ",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abbmdoc from l_sql

   let l_sql = " insert into porto@",m_hostname clipped,":abbmapp (succod     ",
                                   " ,aplnumdig  ",
                                   " ,itmnumdig  ",
                                   " ,dctnumseq  ",
                                   " ,rsgflg     ",
                                   " ,imsmda     ",
                                   " ,imsinvtax  ",
                                   " ,imsinvvlr  ",
                                   " ,imsmortax  ",
                                   " ,imsmorvlr  ",
                                   " ,imsdmhtax  ",
                                   " ,imsdmhvlr  ",
                                   " ,pssqtd     ",
                                   " ,clcdat     ",
                                   " ,prmfnlvlr  ",
                                   " ,pandifvlr  ",
                                   " ,cbtstt     ",
                                   " ,sitseqorg) ",
            " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abbmapp from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abbmcasco_atd (succod     ",
   #                                  " ,aplnumdig  ",
   #                                  " ,itmnumdig  ",
   #                                  " ,dctnumseq  ",
   #                                  " ,ctgtrfcod  ",
   #                                  " ,imsmda     ",
   #                                  " ,imstax     ",
   #                                  " ,imsvlr     ",
   #                                  " ,rsgflg     ",
   #                                  " ,bondscper  ",
   #                                  " ,cbtcod     ",
   #                                  " ,frqcfc     ",
   #                                  " ,frqvlr     ",
   #                                  " ,frqclacod  ",
   #                                  " ,frqdscper  ",
   #                                  " ,agrtextax  ",
   #                                  " ,agrmottax  ",
   #                                  " ,prfcfc     ",
   #                                  " ,prfmda     ",
   #                                  " ,prfvlr     ",
   #                                  " ,prmfnlvlr  ",
   #                                  " ,pandifvlr  ",
   #                                  " ,clcdat     ",
   #                                  " ,cbtstt     ",
   #                                  " ,sitseqorg  ",
   #                                  " ,isnipiflg  ",
   #                                  " ,imsmcdcfc) ",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abbmcasco from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abbmdm_atd (succod     ",
   #                               " ,aplnumdig  ",
   #                               " ,itmnumdig  ",
   #                               " ,dctnumseq  ",
   #                               " ,bondscper  ",
   #                               " ,frqclacod  ",
   #                               " ,frqvlr     ",
   #                               " ,frqcfc     ",
   #                               " ,imsmda     ",
   #                               " ,imsvlr     ",
   #                               " ,imsniv     ",
   #                               " ,ctgtrfcod  ",
   #                               " ,rsgflg     ",
   #                               " ,prmfnlvlr  ",
   #                               " ,pandifvlr  ",
   #                               " ,prmbasvlr  ",
   #                               " ,prmbascfc  ",
   #                               " ,clcdat     ",
   #                               " ,cbtstt     ",
   #                               " ,sitseqorg) ",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abbmdm from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abbmdp_atd (succod     ",
   #                               " ,aplnumdig  ",
   #                               " ,itmnumdig  ",
   #                               " ,dctnumseq  ",
   #                               " ,bondscper  ",
   #                               " ,frqclacod  ",
   #                               " ,frqvlr     ",
   #                               " ,frqcfc     ",
   #                               " ,imsmda     ",
   #                               " ,imsvlr     ",
   #                               " ,imsniv     ",
   #                               " ,ctgtrfcod  ",
   #                               " ,rsgflg     ",
   #                               " ,prmfnlvlr  ",
   #                               " ,pandifvlr  ",
   #                               " ,prmbasvlr  ",
   #                               " ,prmbascfc  ",
   #                               " ,clcdat     ",
   #                               " ,cbtstt     ",
   #                               " ,sitseqorg) ",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abbmdp from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abbmveic_atd (succod     ",
   #                                 " ,aplnumdig  ",
   #                                 " ,itmnumdig  ",
   #                                 " ,dctnumseq  ",
   #                                 " ,vclcoddig  ",
   #                                 " ,vclanofbc  ",
   #                                 " ,vclanomdl  ",
   #                                 " ,vcllicnum  ",
   #                                 " ,vclchsinc  ",
   #                                 " ,vclchsfnl  ",
   #                                 " ,vcluso     ",
   #                                 " ,vsttip     ",
   #                                 " ,vstnumdig  ",
   #                                 " ,vclcmbcod  ",
   #                                 " ,vclporqtd  ",
   #                                 " ,vclcpc     ",
   #                                 " ,vclatmflg  ",
   #                                 " ,vcltexflg  ",
   #                                 " ,vclmotflg  ",
   #                                 " ,atlult     ",
   #                                 " ,avrexcflg  ",
   #                                 " ,sitseqorg  ",
   #                                 " ,vcl0kmflg  ",
   #                                 " ,vclkitgasflg ",
   #                                 " ,vclrnvnum  ",
   #                                 " ,finflg) ",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abbmveic from l_sql

   let l_sql = " insert into porto@",m_hostname clipped,":abbmvida2_atd (succod ",
                                     " ,aplnumdig ",
                                     " ,itmnumdig ",
                                     " ,dctnumseq ",
                                     " ,prmfnlvlr ",
                                     " ,pandifvlr ",
                                     " ,clcdat ",
                                     " ,cbtstt ",
                                     " ,sitseqorg ",
                                     " ,iofvlr ",
                                     " ,adcfrccfc ",
                                     " ,cnjnum ",
                                     " ,prpvdaorg ",
                                     " ,prpvdanumdig ",
                                     " ,imsinvvlr ",
                                     " ,prmvlr  ",
                                     " ,imsmorvlr  )    ",
            " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abbmvida2 from l_sql

   let l_sql = " insert into porto@",m_hostname clipped ,":abbm0km_atd (succod    ",
                                   " ,aplnumdig ",
                                   " ,dctnumseq ",
                                   " ,itmnumdig ",
                                   " ,nfsnum    ",
                                   " ,nfsemidat ",
                                   " ,nfssaidat ",
                                   " ,nfscnsnom ",
                                   " ,cnscod    ",
                                   " ,nfsvlr   ) ",
            " values (?,?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abbm0km from l_sql

   let l_sql = " insert into porto@",m_hostname clipped ,":abbmbli_atd (succod    ",
                                   " ,aplnumdig ",
                                   " ,itmnumdig ",
                                   " ,dctnumseq ",
                                   " ,imsvlr)   ",
            " values (?,?,?,?,?) "
   prepare p_ins_abbmbli from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abamcor_atd (succod    ",
   #                                " ,aplnumdig ",
   #                                " ,corsus    ",
   #                                " ,corperptc ",
   #                                " ,corlidflg ",
   #                                " ,comngcflg ) ",
   #         " values (?,?,?,?,?,?) "
   #prepare p_ins_abamcor from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abamdoc_atd (succod    ",
   #                                " ,aplnumdig ",
   #                                " ,edsnumdig ",
   #                                " ,prporgpcp ",
   #                                " ,prpnumpcp ",
   #                                " ,etpendtip ",
   #                                " ,edsnumref ",
   #                                " ,comadtcod ",
   #                                " ,comtaxcod ",
   #                                " ,cobadcflg ",
   #                                " ,edsquecan ",
   #                                " ,edsstt    ",
   #                                " ,cptdat    ",
   #                                " ,emsdat    ",
   #                                " ,dctnumseq ",
   #                                " ,pgtfrm    ",
   #                                " ,parqtd    ",
   #                                " ,onscod    ",
   #                                " ,prmmda    ",
   #                                " ,imsmda    ",
   #                                " ,unocod    ",
   #                                " ,emsunocod ",
   #                                " ,dctemsprvflg) ",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abamdoc from l_sql

   #let l_sql = " insert into porto@",l_srvnom ,":abbmclaus_atd (succod       ",
   #                                  " ,aplnumdig    ",
   #                                  " ,itmnumdig    ",
   #                                  " ,dctnumseq    ",
   #                                  " ,clscod       ",
   #                                  " ,clscfc       ",
   #                                  " ,prmcobflg    ",
   #                                  " ,viginc       ",
   #                                  " ,vigfnl       ",
   #                                  " ,clsvlr       ",
   #                                  " ,prmfnlvlr    ",
   #                                  " ,pandifvlr    ",
   #                                  " ,frqvlr       ",
   #                                  " ,ltrvdrfrqvlr ",
   #                                  " ,rtvfrqvlr    ",
   #                                  " ,lntfrlfrqvlr)",
   #         " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   #prepare p_ins_abbmclaus from l_sql

   let l_sql = " insert into porto@",m_hostname clipped ,":abbmcondesp_atd (succod    ",
                                       " ,aplnumdig ",
                                       " ,itmnumdig ",
                                       " ,dctnumseq ",
                                       " ,cndeslcod ",
                                       " ,cndeslcfc)",
                                " values (?,?,?,?,?,?) "
   prepare p_ins_abbmcondesp from l_sql

#   let l_sql = " insert into porto@",l_srvnom ,":abbmitem_atd (succod          ",
#                                    " ,aplnumdig       ",
#                                    " ,itmnumdig       ",
#                                    " ,rnvsuccod       ",
#                                    " ,rnvaplnum       ",
#                                    " ,rnvitmnum       ",
#                                    " ,rnvoutcia       ",
#                                    " ,emsdat          ",
#                                    " ,viginc          ",
#                                    " ,vigfnl          ",
#                                    " ,itmsttatu       ",
#                                    " ,vclsitatu       ",
#                                    " ,autsitatu       ",
#                                    " ,dmtsitatu       ",
#                                    " ,dpssitatu       ",
#                                    " ,appsitatu       ",
#                                    " ,vidsitatu       ",
#                                    " ,aplquernv       ",
#                                    " ,itmquernv       ",
#                                    " ,antaplsinflg    ",
#                                    " ,przdntrnvflg    ",
#                                    " ,bonrpvsuccod    ",
#                                    " ,bonrpvaplnumdig ",
#                                    " ,bonrpvitmnumdig ",
#                                    " ,bonrpvtip)      ",
#                 " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
#   prepare p_ins_abbmitem from l_sql

   let l_sql = " insert into porto@",m_hostname clipped ,":abbmquestionario_atd (succod     ",
                                            " ,aplnumdig  ",
                                            " ,itmnumdig  ",
                                            " ,dctnumseq  ",
                                            " ,qstcod     ",
                                            " ,rspcod     ",
                                            " ,rspdat     ",
                                            " ,c18tipcod  ",
                                            " ,rsppto   ) ",
                                     " values (?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abbmquestionario from l_sql

   let l_sql = " insert into porto@",m_hostname clipped,":abbmquesttxt_atd (succod     ",
                                        " ,aplnumdig  ",
                                        " ,itmnumdig  ",
                                        " ,dctnumseq  ",
                                        " ,qstcod     ",
                                        " ,rspcod     ",
                                        " ,rspdat     ",
                                        " ,txtlin     ",
                                        " ,c18tipcod  ",
                                        " ,rsppto   ) ",
                                 " values (?,?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abbmquesttxt from l_sql

   let l_sql = " insert into porto@",m_hostname clipped,":abcmaces_atd (succod     ",
                                    " ,aplnumdig  ",
                                    " ,itmnumdig  ",
                                    " ,assnum     ",
                                    " ,asstip     ",
                                    " ,asscoddig  ",
                                    " ,assritflg  ",
                                    " ,asssitatu  ",
                                    " ,asssttatu) ",
                             " values (?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abcmaces from l_sql

   let l_sql = " insert into porto@",m_hostname clipped,":abcmdoc_atd (succod     ",
                                   " ,aplnumdig  ",
                                   " ,itmnumdig  ",
                                   " ,assnum     ",
                                   " ,dctnumseq  ",
                                   " ,assdescmp  ",
                                   " ,imstax     ",
                                   " ,imsmda     ",
                                   " ,imsvlr     ",
                                   " ,imstaxinf  ",
                                   " ,frqcfc     ",
                                   " ,frqvlr     ",
                                   " ,clcdat     ",
                                   " ,prmfnlvlr  ",
                                   " ,pandifvlr  ",
                                   " ,assstt     ",
                                   " ,sitseqorg) ",
                            " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abcmdoc from l_sql

   let l_sql = " insert into porto@",m_hostname clipped,":abdmparc_atd (succod        ",
                                    " ,aplnumdig     ",
                                    " ,itmnumdig     ",
                                    " ,autparliqvlr  ",
                                    " ,assparliqvlr  ",
                                    " ,dmtparliqvlr  ",
                                    " ,dpsparliqvlr  ",
                                    " ,appparliqvlr  ",
                                    " ,adcfrcvlr     ",
                                    " ,cstaplvlr     ",
                                    " ,iofvlr        ",
                                    " ,dctnumseq     ",
                                    " ,parnum        ",
                                    " ,vctdat        ",
                                    " ,notcmpflg     ",
                                    " ,parsitcod     ",
                                    " ,parmda        ",
                                    " ,titnumdig)    ",
                             " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_ins_abdmparc from l_sql

#   let l_sql = ' delete from porto@',l_srvnom ,':abamapol where succod = ? and aplnumdig = ? '
#   prepare p_dlt_abamapol01 from l_sql

#   let l_sql = ' delete from porto@',l_srvnom ,':abbmitem where succod = ? and aplnumdig = ? and itmnumdig = ? '
#   prepare p_dlt_abbmitem01 from l_sql

#   let l_sql = ' delete from porto@',l_srvnom ,':abamcor where succod = ? and aplnumdig = ? and corsus = ? '
#   prepare p_dlt_abamcor01 from l_sql

 {  let l_sql = ' delete from porto@',m_hostname1 clipped ,':abcmaces where succod = ? and aplnumdig = ? and itmnumdig = ? and assnum = ? '
   prepare p_dlt_abcmaces01 from l_sql}

   let l_sql = ' select * '
              ,'   from porto@',m_hostname1 clipped,':abamapol '
              ,' where succod = ? '
              ,'   and aplnumdig = ? '
   prepare p_abamapol_01 from l_sql
   declare c_abamapol_01 cursor with hold for p_abamapol_01

   let l_sql = ' select unique succod ,aplnumdig '
              ,'   from porto@',m_hostname1 clipped,':abamdoc '
              ,' where emsdat = ? '
   prepare p_abamdoc_recarg from l_sql
   declare c_abamdoc_recarg cursor with hold for p_abamdoc_recarg

   let l_lidos       = 0
   let l_carregados  = 0
   let l_desprezados = 0
   let l_disp        = 0

   let l_dpz_flg = 0

   display ''
   display 'DATA DE PROCESSAMENTO - ' ,l_data_inicio
   display ''

   open c_abamdoc_recarg using l_data_inicio
   foreach c_abamdoc_recarg into lr_abamdoc_rec.succod
                                ,lr_abamdoc_rec.aplnumdig

      begin work

      let l_lidos = l_lidos + 1

      let l_dpz_flg = 0

      #--------------------
      #---> Acessa abamapol
      #--------------------
      open c_abamapol_01 using lr_abamdoc_rec.succod
                              ,lr_abamdoc_rec.aplnumdig
      fetch c_abamapol_01 into lr_abamapol.*

      if sqlca.sqlcode = notfound then
         display '#--> Problema ao acessar tabela abamapol. Erro ' ,sqlca.sqlcode clipped ,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
               ,' Chave desprezada Suc/Apol - ' ,lr_abamdoc_rec.succod ,'/' ,lr_abamdoc_rec.aplnumdig
         let l_desprezados = l_desprezados + 1
         let l_dpz_flg = 1
         rollback work
         call bdata126_erro(lr_abamdoc_rec.succod
                           ,lr_abamdoc_rec.aplnumdig)
         continue foreach
      end if

      open c_abbmdoc02 using lr_abamapol.succod
                            ,lr_abamapol.aplnumdig
      foreach c_abbmdoc02 into lr_abbmdoc.*


          # Tabela abbmdoc Replicada
          ##-------------------
          ##---> Insere abbmdoc
          ##-------------------
          #whenever error continue
          #execute p_ins_abbmdoc using lr_abbmdoc.*
          #whenever error stop
          #
          #if sqlca.sqlcode <> 0 then
          #   if sqlca.sqlcode <> -268 and
          #      sqlca.sqlcode <> -239 then
          #      display '#--> Problema ao inserir tabela abbmdoc. Erro ' ,sqlca.sqlcode clipped ,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
          #             ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
          #      let l_desprezados = l_desprezados + 1
          #      let l_dpz_flg = 1
          #      rollback work
          #      call bdata126_erro(lr_abamapol.succod
          #                     ,lr_abamapol.aplnumdig)
          #      exit foreach
          #   end if
          #end if

          open c_abbmapp01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          fetch c_abbmapp01 into lr_abbmapp.*

          if sqlca.sqlcode <> notfound then

             #-------------------
             #---> Insere abbmapp
             #-------------------
             whenever error continue
             execute p_ins_abbmapp using lr_abbmapp.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbmapp. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                          ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end if

          # Tabela abbmcasco Replicada
          #open c_abbmcasco01 using lr_abamapol.succod
          #                      ,lr_abamapol.aplnumdig
          #                      ,lr_abbmdoc.itmnumdig
          #                      ,lr_abbmdoc.dctnumseq
          #fetch c_abbmcasco01 into lr_abbmcasco.*
          #
          #if sqlca.sqlcode <> notfound then
          #
          #   #---------------------
          #   #---> Insere abbmcasco
          #   #---------------------
          #   whenever error continue
          #   execute p_ins_abbmcasco using lr_abbmcasco.*
          #   whenever error stop
          #
          #   if sqlca.sqlcode <> 0 then
          #      if sqlca.sqlcode <> -268 and
          #         sqlca.sqlcode <> -239 then
          #         display '#--> Problema ao inserir tabela abbmcasco. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
          #             ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
          #         let l_desprezados = l_desprezados + 1
          #         let l_dpz_flg = 1
          #         rollback work
          #         call bdata126_erro(lr_abamapol.succod
          #                           ,lr_abamapol.aplnumdig)
          #         exit foreach
          #      end if
          #   end if
          #end if

          # Tabela abbmdm Replicada
          #open c_abbmdm01 using lr_abamapol.succod
          #                      ,lr_abamapol.aplnumdig
          #                      ,lr_abbmdoc.itmnumdig
          #                      ,lr_abbmdoc.dctnumseq
          #fetch c_abbmdm01 into lr_abbmdm.*
          #
          #if sqlca.sqlcode <> notfound then
          #
          #   #------------------
          #   #---> Insere abbmdm
          #   #------------------
          #   whenever error continue
          #   execute p_ins_abbmdm using lr_abbmdm.*
          #   whenever error stop
          #
          #   if sqlca.sqlcode <> 0 then
          #      if sqlca.sqlcode <> -268 and
          #         sqlca.sqlcode <> -239 then
          #         display '#--> Problema ao inserir tabela abbmdm. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
          #             ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
          #         let l_desprezados = l_desprezados + 1
          #         let l_dpz_flg = 1
          #         rollback work
          #         call bdata126_erro(lr_abamapol.succod
          #                           ,lr_abamapol.aplnumdig)
          #         exit foreach
          #      end if
          #   end if
          #end if

          # Tabela abbmdp Replicada
          #open c_abbmdp01 using lr_abamapol.succod
          #                     ,lr_abamapol.aplnumdig
          #                     ,lr_abbmdoc.itmnumdig
          #                     ,lr_abbmdoc.dctnumseq
          #fetch c_abbmdp01 into lr_abbmdp.*
          #
          #if sqlca.sqlcode <> notfound then
          #
          #   #------------------
          #   #---> Insere abbmdp
          #   #------------------
          #   whenever error continue
          #   execute p_ins_abbmdp using lr_abbmdp.*
          #   whenever error stop
          #
          #   if sqlca.sqlcode <> 0 then
          #      if sqlca.sqlcode <> -268 and
          #         sqlca.sqlcode <> -239 then
          #         display '#--> Problema ao inserir tabela abbmdp. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
          #             ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
          #         let l_desprezados = l_desprezados + 1
          #         let l_dpz_flg = 1
          #         rollback work
          #         call bdata126_erro(lr_abamapol.succod
          #                           ,lr_abamapol.aplnumdig)
          #         exit foreach
          #      end if
          #   end if
          #end if

          # Tabela abbmveic Replicada
          #open c_abbmveic01 using lr_abamapol.succod
          #                      ,lr_abamapol.aplnumdig
          #                      ,lr_abbmdoc.itmnumdig
          #                      ,lr_abbmdoc.dctnumseq
          #fetch c_abbmveic01 into lr_abbmveic.*
          #
          #if sqlca.sqlcode <> notfound then
          #
          #   #--------------------
          #   #---> Insere abbmveic
          #   #--------------------
          #   whenever error continue
          #   execute p_ins_abbmveic using lr_abbmveic.*
          #   whenever error stop
          #
          #   if sqlca.sqlcode <> 0 then
          #      if sqlca.sqlcode <> -268 and
          #         sqlca.sqlcode <> -239 then
          #         display '#--> Problema ao inserir tabela abbmveic. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
          #             ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
          #         let l_desprezados = l_desprezados + 1
          #         let l_dpz_flg = 1
          #         rollback work
          #         call bdata126_erro(lr_abamapol.succod
          #                           ,lr_abamapol.aplnumdig)
          #         exit foreach
          #      end if
          #   end if
          #end if

          open c_abbmvida201 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          fetch c_abbmvida201 into lr_abbmvida2.*

          if sqlca.sqlcode <> notfound then

             #---------------------
             #---> Insere abbmvida2
             #---------------------
             whenever error continue
             execute p_ins_abbmvida2 using lr_abbmvida2.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbmvida2. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                        ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end if

          open c_abbm0km01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          fetch c_abbm0km01 into lr_abbm0km.*

          if sqlca.sqlcode <> notfound then

             #-------------------
             #---> Insere abbm0km
             #-------------------
             whenever error continue
             execute p_ins_abbm0km using lr_abbm0km.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbm0km. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end if

          open c_abbmbli01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          fetch c_abbmbli01 into lr_abbmbli.*

          if sqlca.sqlcode <> notfound then

             #-------------------
             #---> Insere abbmbli
             #-------------------
             whenever error continue
             execute p_ins_abbmbli using lr_abbmbli.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbmbli. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end if

          # Tabela abbmclaus Replicada
          #open c_abbmclaus01 using lr_abamapol.succod
          #                      ,lr_abamapol.aplnumdig
          #                      ,lr_abbmdoc.itmnumdig
          #                      ,lr_abbmdoc.dctnumseq
          #foreach c_abbmclaus01 into lr_abbmclaus.*
          #
          #   #---------------------
          #   #---> Insere abbmclaus
          #   #---------------------
          #   whenever error continue
          #   execute p_ins_abbmclaus using lr_abbmclaus.*
          #   whenever error stop
          #
          #   if sqlca.sqlcode <> 0 then
          #      if sqlca.sqlcode <> -268 and
          #         sqlca.sqlcode <> -239 then
          #         display '#--> Problema ao inserir tabela abbmclaus. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
          #             ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
          #         let l_desprezados = l_desprezados + 1
          #         let l_dpz_flg = 1
          #         rollback work
          #         call bdata126_erro(lr_abamapol.succod
          #                           ,lr_abamapol.aplnumdig)
          #         exit foreach
          #      end if
          #   end if
          #end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

          open c_abbmcondesp01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          foreach c_abbmcondesp01 into lr_abbmcondesp.*

             #-----------------------
             #---> Insere abbmcondesp
             #-----------------------
             whenever error continue
             execute p_ins_abbmcondesp using lr_abbmcondesp.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbmcondesp. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

#--> Tabela replicada.
#          open c_abbmitem01 using lr_abamapol.succod
#                                ,lr_abamapol.aplnumdig
#                                ,lr_abbmdoc.itmnumdig
#          fetch c_abbmitem01 into lr_abbmitem.*

#          if sqlca.sqlcode <> notfound then

#             #--------------------
#             #---> Deleta abbmitem
#             #--------------------
#             whenever error continue
#             execute p_dlt_abbmitem01 using lr_abamapol.succod
#                                           ,lr_abamapol.aplnumdig
#                                           ,lr_abbmdoc.itmnumdig
#             whenever error stop

#             if sqlca.sqlcode <> 0 then
#                display '#--> Problema ao deletar tabela abbmitem. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
#                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
#                let l_desprezados = l_desprezados + 1
#                let l_dpz_flg = 1
#                rollback work
#                call bdata126_erro(lr_abamapol.succod
#                                  ,lr_abamapol.aplnumdig)
#                exit foreach
#             end if

#             #--------------------
#             #---> Insere abbmitem
#             #--------------------
#             whenever error continue
#             execute p_ins_abbmitem using lr_abbmitem.*
#             whenever error stop

#             if sqlca.sqlcode <> 0 then
#                if sqlca.sqlcode <> -268 and
#                   sqlca.sqlcode <> -239 then
#                   display '#--> Problema ao inserir tabela abbmitem. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
#                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
#                   let l_desprezados = l_desprezados + 1
#                   let l_dpz_flg = 1
#                   rollback work
#                   call bdata126_erro(lr_abamapol.succod
#                                     ,lr_abamapol.aplnumdig)
#                   exit foreach
#                end if
#             end if
#          end if

          let aux_questionario = 0
          open c_abbmquestionario01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          foreach c_abbmquestionario01 into lr_abbmquestionario.*

             let aux_questionario = aux_questionario + 1

             #----------------------------
             #---> Insere abbmquestionario
             #----------------------------
             whenever error continue
             execute p_ins_abbmquestionario using lr_abbmquestionario.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbmquestionario. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

          let aux_questionario = 0
          open c_abbmquesttxt01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          foreach c_abbmquesttxt01 into lr_abbmquesttxt.*

             #------------------------
             #---> Insere abbmquesttxt
             #------------------------
             whenever error continue
             execute p_ins_abbmquesttxt using lr_abbmquesttxt.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abbmquesttxt. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

          open c_abcmaces01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
          foreach c_abcmaces01 into lr_abcmaces.*

             #--------------------
             #---> Deleta abcmaces
             #--------------------
             whenever error continue
             execute p_dlt_abcmaces01 using lr_abamapol.succod
                                           ,lr_abamapol.aplnumdig
                                           ,lr_abbmdoc.itmnumdig
                                           ,lr_abcmaces.assnum
             whenever error stop

             if sqlca.sqlcode <> 0 then
                display '#--> Problema ao deletar tabela abcmaces. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                let l_desprezados = l_desprezados + 1
                let l_dpz_flg = 1
                rollback work
                call bdata126_erro(lr_abamapol.succod
                                  ,lr_abamapol.aplnumdig)
                exit foreach
             end if

             #---------------------
             #---> Inserir abcmaces
             #---------------------
             whenever error continue
             execute p_ins_abcmaces using lr_abcmaces.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abcmaces. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

          open c_abcmdoc01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          foreach c_abcmdoc01 into lr_abcmdoc.*

             #-------------------
             #---> Insere abcmdoc
             #-------------------
             whenever error continue
             execute p_ins_abcmdoc using lr_abcmdoc.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abcmdoc. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

          open c_abdmparc01 using lr_abamapol.succod
                                ,lr_abamapol.aplnumdig
                                ,lr_abbmdoc.itmnumdig
                                ,lr_abbmdoc.dctnumseq
          foreach c_abdmparc01 into lr_abdmparc.*

             #--------------------
             #---> Insere abdmparc
             #--------------------
             whenever error continue
             execute p_ins_abdmparc using lr_abdmparc.*
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> -268 and
                   sqlca.sqlcode <> -239 then
                   display '#--> Problema ao inserir tabela abdmparc. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
                       ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
                   let l_desprezados = l_desprezados + 1
                   let l_dpz_flg = 1
                   rollback work
                   call bdata126_erro(lr_abamapol.succod
                                     ,lr_abamapol.aplnumdig)
                   exit foreach
                end if
             end if
          end foreach

          if l_dpz_flg = 1 then
             exit foreach
          end if

      end foreach


      if l_dpz_flg = 0 then

         # Tabela abamdoc Replicada
         #   open c_abamdoc01 using lr_abamapol.succod
         #                         ,lr_abamapol.aplnumdig
         #   foreach c_abamdoc01 into lr_abamdoc.*
         #
         #      #-------------------
         #      #---> Insere abamdoc
         #      #-------------------
         #      whenever error continue
         #      execute p_ins_abamdoc using lr_abamdoc.*
         #      whenever error stop
         #
         #      if sqlca.sqlcode <> 0 then
         #         if sqlca.sqlcode <> -268 and
         #            sqlca.sqlcode <> -239 then
         #            display '#--> Problema ao inserir tabela abamdoc. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
         #                ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
         #            let l_desprezados = l_desprezados + 1
         #            let l_dpz_flg = 1
         #            rollback work
         #            call bdata126_erro(lr_abamapol.succod
         #                              ,lr_abamapol.aplnumdig)
         #            exit foreach
         #         end if
         #      end if
         #   end foreach

         # Tabela abamcor Replicada
         #if l_dpz_flg = 0 then
         #
         #   open c_abamcor01 using lr_abamapol.succod
         #                         ,lr_abamapol.aplnumdig
         #   foreach c_abamcor01 into lr_abamcor.*
         #
         #         #-------------------
         #         #---> Deleta abamcor
         #         #-------------------
         #         whenever error continue
         #         execute p_dlt_abamcor01 using lr_abamapol.succod
         #                                      ,lr_abamapol.aplnumdig
         #                                      ,lr_abamcor.corsus
         #         whenever error stop
         #
         #         if sqlca.sqlcode <> 0 then
         #            display '#--> Problema ao deletar tabela abamcor. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
         #                ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
         #            let l_desprezados = l_desprezados + 1
         #            let l_dpz_flg = 1
         #            rollback work
         #            call bdata126_erro(lr_abamapol.succod
         #                              ,lr_abamapol.aplnumdig)
         #            exit foreach
         #         end if
         #
         #         #-------------------
         #         #---> Insere abamcor
         #         #-------------------
         #         whenever error continue
         #         execute p_ins_abamcor using lr_abamcor.*
         #         whenever error stop
         #
         #         if sqlca.sqlcode <> 0 then
         #            if sqlca.sqlcode <> -268 and
         #               sqlca.sqlcode <> -239 then
         #               display '#--> Problema ao inserir tabela abamcor. Erro ' ,sqlca.sqlcode clipped,'/' ,sqlca.sqlerrd[2] clipped ,' registro: ' ,l_lidos
         #                ,' Chave desprezada Suc/Apol - ' ,lr_abamapol.succod ,'/' ,lr_abamapol.aplnumdig
         #               let l_desprezados = l_desprezados + 1
         #               let l_dpz_flg = 1
         #               rollback work
         #               call bdata126_erro(lr_abamapol.succod
         #                                 ,lr_abamapol.aplnumdig)
         #               exit foreach
         #            end if
         #         end if
         #
         #   end foreach
         #end if

         if l_dpz_flg = 0 then
            commit work
            let l_carregados = l_carregados + 1

            let l_disp = l_disp + 1

            if l_disp  = 5000 then
               display '#-------------------------------------#'
               display '# Registros Carregados ateh o momento : ' ,l_carregados
               display '#-------------------------------------#'
               let l_disp = 0
            end if
         end if

      end if

   end foreach

   display '#---> Registros Lidos do dia - ' ,l_data_inicio ,' : ' ,l_lidos

   display ''
   display '#--------------------------------------#'
   display '#---> Registros Lidos      : ' ,l_lidos
   display '#---> Registros Desprezados: ' ,l_desprezados
   display '#---> Registros Carregados : ' ,l_carregados
   display '#--------------------------------------#'
   display ''

   return

end function
#----------------------------
function bdata126_erro(param)
#----------------------------

   define param         record
          succod        like abamapol.succod
         ,aplnumdig     like abamapol.aplnumdig
   end record

   define l_relpamseq   decimal(5,0)
         ,l_relpamtxt   varchar(75,0)
         ,l_atu_flg     smallint
         ,l_i           smallint

   let l_relpamseq = null
   let l_relpamtxt = null
   let l_atu_flg   = null
   let l_i         = null

   #---> 223689 - Atualiza Chave para Central 24h
   #---> Grava Sucursal e Apolice para start de processo batch,
   #---> partindo da abamapol, buscando a última situação
   #---> e atualizando as tabelas do auto replicadas no banco u18w

   select max(relpamseq)
     into l_relpamseq
     from igbmparam
    where relsgl = 'ct24h_bdata126'

   if l_relpamseq is null or
      l_relpamseq =  0    then
      let l_relpamseq = 1
   else
      let l_relpamseq = l_relpamseq + 1
   end if

   let l_relpamtxt = null
   let l_relpamtxt = param.succod           using "&&"
                    ,param.aplnumdig        using "&&&&&&&&&"

   begin work

   let l_atu_flg = null

   for l_i = 1 to 10
      whenever error continue

      insert into igbmparam (relsgl,relpamseq,relpamtip,relpamtxt)
                      values("ct24h_bdata126",l_relpamseq, 1, l_relpamtxt)

      whenever error stop

      if sqlca.sqlcode = 0 then
         commit work
         let l_atu_flg = 0
         exit for
      else
         let l_atu_flg = 1
      end if

   end for

   if l_atu_flg = 1 then
      rollback work
   end if

end function
