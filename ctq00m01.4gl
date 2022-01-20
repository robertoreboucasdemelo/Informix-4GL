#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HS                                              #
# Modulo        : ctq00m01                                                   #
# Analista Resp.: Alberto Rodrigues                                          #
# PSI           :                                                            #
# OSF           :                                                            #
#                 Interface para o sistema Sinistro via MQ, para emissao de  #
#                 Laudo Automático de Furto/Roubo                            #
#............................................................................#
# Desenvolvimento: Alberto, Porto Seguro                                     #
# Liberacao      :                                                           #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 30/10/2008 Amilton,Meta   PSI 230669  Incluir atdnum no nos parametros     #
#----------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada #
#                                          por ctd25g00                      #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'

#----------------------------------
function ctq00m01(lr_param)
#----------------------------------

 define  lr_param      record
  lignum        like datmligacao.lignum      ,#  1 datmligacao.lignum
  ligdat        like datmligacao.ligdat      ,#  2 datmligacao.ligdat
  lighorinc     like datmligacao.lighorinc   ,#  3 datmligacao.lighorinc
  c24soltipcod  like datksoltip.c24soltipcod ,#  4 datksoltip.c24soltipcod
  c24solnom     like datmligacao.c24solnom   ,#  5 datmligacao.c24solnom
  c24astcod     like datmligacao.c24astcod   ,#  6 datmligacao.c24astcod
  c24funmat     like datmligacao.c24funmat   ,#  7 datmligacao.c24funmat
  ligcvntip     like datmligacao.ligcvntip   ,#  8 datmligacao.ligcvntip
  c24paxnum     like datmligacao.c24paxnum   ,#  9 datmligacao.c24paxnum
  succod        like datrligapol.succod      ,# 10 datrligapol.succod
  ramcod        like datrligapol.ramcod      ,# 11 datrligapol.ramcod
  aplnumdig     like datrligapol.aplnumdig   ,# 12 datrligapol.aplnumdig
  itmnumdig     like datrligapol.itmnumdig   ,# 13 datrligapol.itmnumdig
  edsnumref     like datrligapol.edsnumref   ,# 14 datrligapol.edsnumref
  prporg        like datrligprp.prporg       ,# 15 datrligprp.prporg
  prpnumdig     like datrligprp.prpnumdig    ,# 16 datrligprp.prpnumdig
  fcapacorg     like datrligpac.fcapacorg    ,# 17 datrligpac.fcapacorg
  fcapacnum     like datrligpac.fcapacnum    ,# 18 datrligpac.fcapacnum
  cornom        like datmvstsin.cornom       ,# 19 datmvstsin.cornom
  corsus        like datmvstsin.corsus       ,# 20 datmvstsin.corsus
  vcldes        like datmvstsin.vcldes       ,# 21 datmvstsin.vcldes
  vclanomdl     like datmvstsin.vclanomdl    ,# 22 datmvstsin.vclanomdl
  vcllicnum     like datmvstsin.vcllicnum    ,# 23 datmvstsin.vcllicnum
  sindat        like datmvstsin.sindat       ,# 24 datmvstsin.sindat
  sinavs        like datmvstsin.sinavs       ,# 25 datmvstsin.sinavs
  ## Grava Serviço                            #
  vclcorcod     like datmservico.vclcorcod   ,# 26 datmservico.vclcorcod
  atdlclflg     like datmservico.atdlclflg   ,# 27 datmservico.atdlclflg
  atdrsdflg     like datmservico.atdrsdflg   ,# 28 datmservico.atdrsdflg
  atddfttxt     like datmservico.atddfttxt   ,# 29 datmservico.atddfttxt
  atddoctxt     like datmservico.atddoctxt   ,# 30 datmservico.atddoctxt
  c24opemat     like datmservico.c24opemat   ,# 31 datmservico.c24opemat
  nom           like datmservico.nom         ,# 32 datmservico.nom
  cnldat        like datmservico.cnldat      ,# 33 datmservico.cnldat
  vclcoddig     like datmservico.vclcoddig   ,# 34 datmservico.vclcoddig
  atdsrvorg     like datmservico.atdsrvorg   ,# 35 datmservico.atdsrvorg
  ## Grava datmservicocmp                     #
  c24sintip     like datmservicocmp.c24sintip,# 36 datmservicocmp.c24sintip
  c24sinhor     like datmservicocmp.c24sinhor,# 37 datmservicocmp.c24sinhor
  bocflg        like datmservicocmp.bocflg   ,# 38 datmservicocmp.bocflg
  bocnum        like datmservicocmp.bocnum   ,# 39 datmservicocmp.bocnum
  bocemi        like datmservicocmp.bocemi   ,# 40 datmservicocmp.bocemi
  vicsnh        like datmservicocmp.vicsnh   ,# 41 datmservicocmp.vicsnh
  sinhor        like datmservicocmp.sinhor   ,# 42 datmservicocmp.sinhor
  ## Grava datmsrvacp Local e Ocorrencia      #
  c24endtip     like datmlcl.c24endtip       ,# 43 datmlcl.c24endtip
  lclidttxt     like datmlcl.lclidttxt       ,# 44 datmlcl.lclidttxt
  lgdtip        like datmlcl.lgdtip          ,# 45 datmlcl.lgdtip
  lgdnom        like datmlcl.lgdnom          ,# 46 datmlcl.lgdnom
  lgdnum        like datmlcl.lgdnum          ,# 47 datmlcl.lgdnum
  lclbrrnom     like datmlcl.lclbrrnom       ,# 48 datmlcl.lclbrrnom
  brrnom        like datmlcl.brrnom          ,# 49 datmlcl.brrnom
  cidnom        like datmlcl.cidnom          ,# 50 datmlcl.cidnom
  ufdcod        like datmlcl.ufdcod          ,# 51 datmlcl.ufdcod
  lclrefptotxt  like datmlcl.lclrefptotxt    ,# 52 datmlcl.lclrefptotxt
  endzon        like datmlcl.endzon          ,# 53 datmlcl.endzon
  lgdcep        like datmlcl.lgdcep          ,# 54 datmlcl.lgdcep
  lgdcepcmp     like datmlcl.lgdcepcmp       ,# 55 datmlcl.lgdcepcmp
  lclltt        like datmlcl.lclltt          ,# 56 datmlcl.lclltt
  lcllgt        like datmlcl.lcllgt          ,# 57 datmlcl.lcllgt
  lcldddcod     like datmlcl.dddcod          ,# 58 datmlcl.dddcod
  lcltelnum     like datmlcl.lcltelnum       ,# 59 datmlcl.lcltelnum
  lclcttnom     like datmlcl.lclcttnom       ,# 50 datmlcl.lclcttnom
  c24lclpdrcod  like datmlcl.c24lclpdrcod    ,# 61 datmlcl.c24lclpdrcod
  lclofnnumdig  like datmlcl.ofnnumdig       ,# 62 datmlcl.ofnnumdig
  emeviacod     like datmlcl.emeviacod       ,# 63 datmlcl.emeviacod
  ## Grava tabela de Aviso de sinistro        #
  sinntzcod     like datmavssin.sinntzcod    ,# 64 datmavssin.sinntzcod
  eqprgicod     like datmavssin.eqprgicod    ,# 65 datmavssin.eqprgicod
  ## Condutor                                 #
  ctcdtnom      char(50)                     ,# 66 ctcdtnom
  ctcgccpfnum   dec(12,0)                    ,# 67 ctcgccpfnum
  ctcgccpfdig   dec(02,0)                    ,# 68 ctcgccpfdig
  sinramcod     like ssamsin.ramcod          ,# 69 ssamsin.ramcod
  sinano        like ssamsin.sinano          ,# 70 ssamsin.sinano
  sinnum        like ssamsin.sinnum          ,# 71 ssamsin.sinnum
  sinitmseq     like ssamitem.sinitmseq      ,# 72 ssamitem.sinitmseq
  atdnum        like datmatd6523.atdnum      ,# 73 datmatd6523.atdnum
  qtd_historico smallint                     ,# 74 Qtde de linhas do Historico
  historico     char(32766)
 end record

 define l_retorno_furrou   record
        err       smallint,
        msg       char(80),
        lignum    like datmligacao.lignum,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
 end record

 define l_ret_srvlig_furrou
        record
        erro      smallint,
        msgerro   char(80),
        lignum    like datmligacao.lignum,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
 end record

 define l_ret_tab
         record
         sqlcode         integer,
         tabname         like systables.tabname
 end record

 define l_mensagem_erro char(80)
 define l_cts14m00_ano4 char(04)
 define l_gera_hist_srv smallint
 define l_ret_siniven   smallint
 define l_display       char(01)
 define ins_etapa       integer
 define avsrcprd        smallint

 define l_data_banco  date,
        l_hora2       datetime hour to minute

 define d_cts37m00    record
        nom           like datmservico.nom          ,
        corsus        like datmservico.corsus       ,
        cornom        like datmservico.cornom       ,
        cvnnom        char (19)                     ,
        vclcoddig     like datmservico.vclcoddig    ,
        vcldes        like datmservico.vcldes       ,
        vclanomdl     like datmservico.vclanomdl    ,
        vcllicnum     like datmservico.vcllicnum    ,
        vclchsinc     like abbmveic.vclchsinc       ,
        vclchsfnl     like abbmveic.vclchsfnl       ,
        vclcordes     char (11)                     ,
        vclchsnum     char (20)
 end record

 define arg_furto_roubo    record
        lignum           like datmligacao.lignum      ,
        ligdat           like datmligacao.ligdat      ,
        lighorinc        like datmligacao.lighorinc   ,
        c24soltipcod     like datksoltip.c24soltipcod ,
        c24solnom        like datmligacao.c24solnom   ,
        c24astcod        like datmligacao.c24astcod   ,
        c24funmat        like datmligacao.c24funmat   ,
        ligcvntip        like datmligacao.ligcvntip   ,
        c24paxnum        like datmligacao.c24paxnum   ,
        atdsrvnum        like datrligsrv.atdsrvnum    ,
        atdsrvano        like datrligsrv.atdsrvano    ,
        sinvstnum        like datrligsinvst.sinvstnum ,
        sinvstano        like datrligsinvst.sinvstano ,
        sinavsnum        like datrligsinavs.sinavsnum ,
        sinavsano        like datrligsinavs.sinavsano ,
        succod           like datrligapol.succod      ,
        ramcod           like datrligapol.ramcod      ,
        aplnumdig        like datrligapol.aplnumdig   ,
        itmnumdig        like datrligapol.itmnumdig   ,
        edsnumref        like datrligapol.edsnumref   ,
        prporg           like datrligprp.prporg       ,
        prpnumdig        like datrligprp.prpnumdig    ,
        fcapacorg        like datrligpac.fcapacorg    ,
        fcapacnum        like datrligpac.fcapacnum    ,
        sinramcod        like ssamsin.ramcod          ,
        sinano           like ssamsin.sinano          ,
        sinnum           like ssamsin.sinnum          ,
        sinitmseq        like ssamitem.sinitmseq      ,
        caddat           like datmligfrm.caddat       ,
        cadhor           like datmligfrm.cadhor       ,
        cademp           like datmligfrm.cademp       ,
        cadmat           like datmligfrm.cadmat       ,
## Alberto
        cornom           like datmvstsin.cornom       ,
        corsus           like datmvstsin.corsus       ,
        vcldes           like datmvstsin.vcldes       ,
        vclanomdl        like datmvstsin.vclanomdl    ,
        vcllicnum        like datmvstsin.vcllicnum    ,
        sindat           like datmvstsin.sindat       ,
        sinavs           like datmvstsin.sinavs       ,
## Alberto
        ## Grava Serviço
        vclcorcod        like datmservico.vclcorcod   ,
        atdlibflg        like datmservico.atdlibflg   ,
        atdlibhor        like datmservico.atdlibhor   ,
        atdlibdat        like datmservico.atdlibdat   ,
        atdlclflg        like datmservico.atdlclflg   ,
        atdhorpvt        like datmservico.atdhorpvt   ,
        atddatprg        like datmservico.atddatprg   ,
        atdhorprg        like datmservico.atdhorprg   ,
        atdtip           like datmservico.atdtip      ,
        atdmotnom        like datmservico.atdmotnom   ,
        atdvclsgl        like datmservico.atdvclsgl   ,
        atdprscod        like datmservico.atdprscod   ,
        atdcstvlr        like datmservico.atdcstvlr   ,
        atdfnlflg        like datmservico.atdfnlflg   ,
        atdfnlhor        like datmservico.atdfnlhor   ,
        atdrsdflg        like datmservico.atdrsdflg   ,
        atddfttxt        like datmservico.atddfttxt   ,
        atddoctxt        like datmservico.atddoctxt   ,
        c24opemat        like datmservico.c24opemat   ,
        nom              like datmservico.nom         ,
        cnldat           like datmservico.cnldat      ,
        pgtdat           like datmservico.pgtdat      ,
        c24nomctt        like datmservico.c24nomctt   ,
        atdpvtretflg     like datmservico.atdpvtretflg,
        atdvcltip        like datmservico.atdvcltip   ,
        asitipcod        like datmservico.asitipcod   ,
        socvclcod        like datmservico.socvclcod   ,
        vclcoddig        like datmservico.vclcoddig   ,
        srvprlflg        like datmservico.srvprlflg   ,
        srrcoddig        like datmservico.srrcoddig   ,
        atdprinvlcod     like datmservico.atdprinvlcod,
        atdsrvorg        like datmservico.atdsrvorg   ,
        ## Grava datmservicocmp
        c24sintip        like datmservicocmp.c24sintip,
        c24sinhor        like datmservicocmp.c24sinhor,
        bocflg           like datmservicocmp.bocflg   ,
        bocnum           like datmservicocmp.bocnum   ,
        bocemi           like datmservicocmp.bocemi   ,
        vicsnh           like datmservicocmp.vicsnh   ,
        sinhor           like datmservicocmp.sinhor   ,
        ## Grava datmsrvacp
        atdsrvseq        like datmsrvacp.atdsrvseq    ,
        atdetpcod        like datmsrvacp.atdetpcod    ,
        atdetpdat        like datmsrvacp.atdetpdat    ,
        atdetphor        like datmsrvacp.atdetphor    ,
        empcod           like datmsrvacp.empcod       ,
        funmat           like datmsrvacp.funmat       ,
        ## Grava locais de (1) ocorrencia  / (2) destino
        operacao         char (01),
        c24endtip        like datmlcl.c24endtip,
        lclidttxt        like datmlcl.lclidttxt,
        lgdtip           like datmlcl.lgdtip,
        lgdnom           like datmlcl.lgdnom,
        lgdnum           like datmlcl.lgdnum,
        lclbrrnom        like datmlcl.lclbrrnom,
        brrnom           like datmlcl.brrnom,
        cidnom           like datmlcl.cidnom,
        ufdcod           like datmlcl.ufdcod,
        lclrefptotxt     like datmlcl.lclrefptotxt,
        endzon           like datmlcl.endzon,
        lgdcep           like datmlcl.lgdcep,
        lgdcepcmp        like datmlcl.lgdcepcmp,
        lclltt           like datmlcl.lclltt,
        lcllgt           like datmlcl.lcllgt,
        lcldddcod        like datmlcl.dddcod,
        lcltelnum        like datmlcl.lcltelnum,
        lclcttnom        like datmlcl.lclcttnom,
        c24lclpdrcod     like datmlcl.c24lclpdrcod,
        lclofnnumdig     like datmlcl.ofnnumdig,
        emeviacod        like datmlcl.emeviacod,
        sinntzcod        like datmavssin.sinntzcod,
        eqprgicod        like datmavssin.eqprgicod,
        ## Condutor
        ctcdtnom         char(50)                    ,
        ctcgccpfnum      dec(12,0)                   ,
        ctcgccpfdig      dec(02,0)                   ,
        cdtseq           like aeikcdt.cdtseq         ,
        qtd_historico    smallint                    ,
        historico        char(32766)                 ,
        celteldddcod     like datmlcl.celteldddcod   ,
        celtelnum        like datmlcl.celtelnum      ,
        endcmp           like datmlcl.endcmp
 end record

 define l_c24txtseq      like datmservhist.c24txtseq
 define l_sinvstano      char(04)
 define l_sinvstnum      like datmsinatditf.sinvstnum
 define l_dddcod         like datrligtel.dddcod
 define l_teltxt         like datrligtel.teltxt
 define l_solempcod      like datrligmat.empcod
 define l_solfunmat      like datrligmat.funmat
 define l_solusrtip      like datrligmat.usrtip
 define l_cgccpfnum      like datrligcgccpf.cgccpfnum
 define l_cgcord         like datrligcgccpf.cgcord
 define l_cgccpfdig      like datrligcgccpf.cgccpfdig
 define l_corsus         like datrligcor.corsus
 define l_cndslcflg      like datkassunto.cndslcflg
 define ret_cons_msg     char(50)

 define l_ret       smallint,
        l_mensagem  char(60)
 define l_erro      smallint
 define l_msg_erro  char(200)
 define l_lignum    like datmligacao.lignum

 ## Historico da WEB
 define n_posicao_inc smallint
 define n_posicao_fin smallint
 define n_conta       smallint
 define l_historico   char(70)

 define l_aux char(25)    ## retirar
 let    l_aux = current   ## retirar


 initialize l_sinvstano to null
 initialize l_sinvstnum to null
 initialize l_dddcod    to null
 initialize l_teltxt    to null
 initialize l_solempcod to null
 initialize l_solfunmat to null
 initialize l_solusrtip to null
 initialize l_cgccpfnum to null
 initialize l_cgcord    to null
 initialize l_cgccpfdig to null
 initialize l_corsus    to null
 initialize l_cndslcflg to null
 initialize l_display   to null

 let l_lignum = null

 select cpodes
   into l_display
   from iddkdominio
  where cponom = "ctq00m01"
 if sqlca.sqlcode <> 0 then
    let l_display = null
 end if
 if l_display = "s" or l_display = "S" then
    display "***** PARAMETRO RECEBIDOS ******"
    display "lr_param.lignum        = ",lr_param.lignum
    display "lr_param.ligdat        = ",lr_param.ligdat
    display "lr_param.lighorinc     = ",lr_param.lighorinc
    display "lr_param.c24soltipcod  = ",lr_param.c24soltipcod
    display "lr_param.c24solnom     = ",lr_param.c24solnom
    display "lr_param.c24astcod     = ",lr_param.c24astcod
    display "lr_param.c24funmat     = ",lr_param.c24funmat
    display "lr_param.ligcvntip     = ",lr_param.ligcvntip
    display "lr_param.c24paxnum     = ",lr_param.c24paxnum
    display "lr_param.succod        = ",lr_param.succod
    display "lr_param.ramcod        = ",lr_param.ramcod
    display "lr_param.aplnumdig     = ",lr_param.aplnumdig
    display "lr_param.itmnumdig     = ",lr_param.itmnumdig
    display "lr_param.edsnumref     = ",lr_param.edsnumref
    display "lr_param.prporg        = ",lr_param.prporg
    display "lr_param.prpnumdig     = ",lr_param.prpnumdig
    display "lr_param.fcapacorg     = ",lr_param.fcapacorg
    display "lr_param.fcapacnum     = ",lr_param.fcapacnum
    display "lr_param.cornom        = ",lr_param.cornom
    display "lr_param.corsus        = ",lr_param.corsus
    display "lr_param.vcldes        = ",lr_param.vcldes
    display "lr_param.vclanomdl     = ",lr_param.vclanomdl
    display "lr_param.vcllicnum     = ",lr_param.vcllicnum
    display "lr_param.sindat        = ",lr_param.sindat
    display "lr_param.sinavs        = ",lr_param.sinavs
    display "lr_param.vclcorcod     = ",lr_param.vclcorcod
    display "lr_param.atdlclflg     = ",lr_param.atdlclflg
    display "lr_param.atdrsdflg     = ",lr_param.atdrsdflg
    display "lr_param.atddfttxt     = ",lr_param.atddfttxt
    display "lr_param.atddoctxt     = ",lr_param.atddoctxt
    display "lr_param.c24opemat     = ",lr_param.c24opemat
    display "lr_param.nom           = ",lr_param.nom
    display "lr_param.cnldat        = ",lr_param.cnldat
    display "lr_param.vclcoddig     = ",lr_param.vclcoddig
    display "lr_param.atdsrvorg     = ",lr_param.atdsrvorg
    display "lr_param.c24sintip     = ",lr_param.c24sintip
    display "lr_param.c24sinhor     = ",lr_param.c24sinhor
    display "lr_param.bocflg        = ",lr_param.bocflg
    display "lr_param.bocnum        = ",lr_param.bocnum
    display "lr_param.bocemi        = ",lr_param.bocemi
    display "lr_param.vicsnh        = ",lr_param.vicsnh
    display "lr_param.sinhor        = ",lr_param.sinhor
    display "lr_param.c24endtip     = ",lr_param.c24endtip
    display "lr_param.lclidttxt     = ",lr_param.lclidttxt
    display "lr_param.lgdtip        = ",lr_param.lgdtip
    display "lr_param.lgdnom        = ",lr_param.lgdnom
    display "lr_param.lgdnum        = ",lr_param.lgdnum
    display "lr_param.lclbrrnom     = ",lr_param.lclbrrnom
    display "lr_param.brrnom        = ",lr_param.brrnom
    display "lr_param.cidnom        = ",lr_param.cidnom
    display "lr_param.ufdcod        = ",lr_param.ufdcod
    display "lr_param.lclrefptotxt  = ",lr_param.lclrefptotxt
    display "lr_param.endzon        = ",lr_param.endzon
    display "lr_param.lgdcep        = ",lr_param.lgdcep
    display "lr_param.lgdcepcmp     = ",lr_param.lgdcepcmp
    display "lr_param.lclltt        = ",lr_param.lclltt
    display "lr_param.lcllgt        = ",lr_param.lcllgt
    display "lr_param.lcldddcod     = ",lr_param.lcldddcod
    display "lr_param.lcltelnum     = ",lr_param.lcltelnum
    display "lr_param.lclcttnom     = ",lr_param.lclcttnom
    display "lr_param.c24lclpdrcod  = ",lr_param.c24lclpdrcod
    display "lr_param.lclofnnumdig  = ",lr_param.lclofnnumdig
    display "lr_param.emeviacod     = ",lr_param.emeviacod
    display "lr_param.sinntzcod     = ",lr_param.sinntzcod
    display "lr_param.eqprgicod     = ",lr_param.eqprgicod
    display "lr_param.ctcdtnom      = ",lr_param.ctcdtnom
    display "lr_param.ctcgccpfnum   = ",lr_param.ctcgccpfnum
    display "lr_param.ctcgccpfdig   = ",lr_param.ctcgccpfdig
    display "lr_param.sinramcod     = ",lr_param.sinramcod
    display "lr_param.sinano        = ",lr_param.sinano
    display "lr_param.sinnum        = ",lr_param.sinnum
    display "lr_param.sinitmseq     = ",lr_param.sinitmseq
    display "lr_param.atdnum        = ",lr_param.atdnum
    display "lr_param.qtd_historico = ",lr_param.qtd_historico
    display "lr_param.historico     = ",lr_param.historico clipped
    display "***** FIM PARAMETROS RECEBIDOS *****"
 end if
 -------------------[ inicializa os campos ]---------------------
 let l_ret_srvlig_furrou.erro     = null
 let l_ret_srvlig_furrou.msgerro  = ""
 let arg_furto_roubo.atdtip       = "5"
 let arg_furto_roubo.atdfnlflg    = "S"
 let arg_furto_roubo.atdprinvlcod = 2
 let arg_furto_roubo.lignum       = lr_param.lignum

 if lr_param.c24endtip    is null then
    let lr_param.c24endtip    = 1
 end if
 if lr_param.lgdnom       is null then
    let lr_param.lgdnom = " "
 end if
 if lr_param.lclbrrnom    is null then
    let lr_param.lclbrrnom    = " "
 end if
 if lr_param.cidnom       is null then
    let lr_param.cidnom       = " "
 end if
 if lr_param.ufdcod       is null then
    let lr_param.ufdcod       = " "
 end if
 if lr_param.c24lclpdrcod is null then
    let lr_param.c24lclpdrcod = 1
 end if
 if lr_param.succod     = 0 then
    let lr_param.succod = null
 end if
 if lr_param.ramcod     = 0 then
    let lr_param.ramcod = null
 end if
 if lr_param.aplnumdig     = 0 then
    let lr_param.aplnumdig = null
 end if
 if lr_param.itmnumdig     = 0 then
    let lr_param.itmnumdig = null
 end if
 if lr_param.prporg     = 0 then
    let lr_param.prporg = null
 end if
 if lr_param.prpnumdig     = 0 then
    let lr_param.prpnumdig = null
 end if
 -----------------------------------------------------------

 let l_aux = current
 display "<ctq00m01 465 > Vai chamar consistencias de parametros ", l_aux
 call ctq00m01_cons_param( lr_param.ligdat              ,
                           lr_param.lighorinc           ,
                           lr_param.c24soltipcod        ,
                           lr_param.c24solnom           ,
                           lr_param.c24astcod           ,
                           lr_param.c24funmat           ,
                           lr_param.ligcvntip           ,
                           lr_param.c24soltipcod        ,
                           lr_param.succod              ,
                           lr_param.ramcod              ,
                           lr_param.aplnumdig           ,
                           lr_param.itmnumdig           ,
                           lr_param.edsnumref           ,
                           lr_param.ligdat              ,
                           lr_param.lighorinc           ,
                           arg_furto_roubo.atdtip       ,
                           arg_furto_roubo.atdfnlflg    ,
                           arg_furto_roubo.atdprinvlcod ,
                           lr_param.c24endtip           ,
                           lr_param.lgdnom              ,
                           lr_param.lclbrrnom           ,
                           lr_param.cidnom              ,
                           lr_param.ufdcod              ,
                           lr_param.c24lclpdrcod
                         )
 returning ret_cons_msg
 let l_aux = current
 display "<ctq00m01 493 > retornou de consistencias de parametros ", l_aux," ",ret_cons_msg

 if ret_cons_msg[1,3] <> "000" then
    let l_retorno_furrou.err       = 999
    let l_retorno_furrou.msg       = ret_cons_msg
    let l_retorno_furrou.lignum    = 0
    let l_retorno_furrou.atdsrvnum = 0
    let l_retorno_furrou.atdsrvano = 0
    if l_display = "s" or l_display = "S" then
       display "<502>* FIM ctq00m01 l_retorno_furrou.err = ",l_retorno_furrou.err
       display "               l_retorno_furrou.msg = ",l_retorno_furrou.msg
       display "            l_retorno_furrou.lignum = ",l_retorno_furrou.lignum
       display "         l_retorno_furrou.atdsrvnum = ",l_retorno_furrou.atdsrvnum
       display "         l_retorno_furrou.atdsrvano = ",l_retorno_furrou.atdsrvano
    end if
    return l_retorno_furrou.err       ,
           l_retorno_furrou.msg       ,
           l_retorno_furrou.lignum    ,
           l_retorno_furrou.atdsrvnum ,
           l_retorno_furrou.atdsrvano

 end if

 let l_aux = current
 let arg_furto_roubo.ligdat        = lr_param.ligdat
 let arg_furto_roubo.lighorinc     = lr_param.lighorinc
 let arg_furto_roubo.c24soltipcod  = lr_param.c24soltipcod
 let arg_furto_roubo.c24solnom     = lr_param.c24solnom
 let arg_furto_roubo.c24astcod     = lr_param.c24astcod
 let arg_furto_roubo.c24funmat     = lr_param.c24funmat
 let arg_furto_roubo.ligcvntip     = lr_param.ligcvntip
 let arg_furto_roubo.c24paxnum     = lr_param.c24paxnum
 let arg_furto_roubo.atdsrvnum     = l_ret_srvlig_furrou.atdsrvnum
 let arg_furto_roubo.atdsrvano     = l_ret_srvlig_furrou.atdsrvano
 let arg_furto_roubo.sinavsnum     = ""
 let arg_furto_roubo.sinavsano     = ""
 let arg_furto_roubo.succod        = lr_param.succod
 let arg_furto_roubo.ramcod        = lr_param.ramcod
 let arg_furto_roubo.aplnumdig     = lr_param.aplnumdig
 let arg_furto_roubo.itmnumdig     = lr_param.itmnumdig
 let arg_furto_roubo.edsnumref     = lr_param.edsnumref
 let arg_furto_roubo.prporg        = lr_param.prporg
 let arg_furto_roubo.prpnumdig     = lr_param.prpnumdig
 let arg_furto_roubo.caddat        = ""
 let arg_furto_roubo.cadhor        = ""
 let arg_furto_roubo.cademp        = ""
 let arg_furto_roubo.cadmat        = ""
 let arg_furto_roubo.vclcorcod     = lr_param.vclcorcod
 let arg_furto_roubo.atdlibflg     = ""
 let arg_furto_roubo.atdlibhor     = ""
 let arg_furto_roubo.atdlibdat     = ""
 let arg_furto_roubo.atdlclflg     = lr_param.atdlclflg
 let arg_furto_roubo.atdhorpvt     = ""
 let arg_furto_roubo.atddatprg     = ""
 let arg_furto_roubo.atdhorprg     = ""
 let arg_furto_roubo.atdtip        = "5"
 let arg_furto_roubo.atdmotnom     = ""
 let arg_furto_roubo.atdvclsgl     = ""
 let arg_furto_roubo.atdprscod     = ""
 let arg_furto_roubo.atdcstvlr     = ""
 let arg_furto_roubo.atdfnlflg     = "S"
 let arg_furto_roubo.atdfnlhor     = ""
 let arg_furto_roubo.atdrsdflg     = lr_param.atdrsdflg
 let arg_furto_roubo.atddfttxt     = lr_param.atddfttxt
 let arg_furto_roubo.atddoctxt     = lr_param.atddoctxt
 let arg_furto_roubo.c24opemat     = lr_param.c24opemat
 let arg_furto_roubo.nom           = lr_param.nom
 let arg_furto_roubo.cornom        = lr_param.cornom
 let arg_furto_roubo.corsus        = lr_param.corsus
 let arg_furto_roubo.vcldes        = lr_param.vcldes
 let arg_furto_roubo.vclanomdl     = lr_param.vclanomdl
 let arg_furto_roubo.vcllicnum     = lr_param.vcllicnum
 let arg_furto_roubo.sindat        = lr_param.sindat
 let arg_furto_roubo.sinavs        = lr_param.sinavs
 let arg_furto_roubo.cnldat        = lr_param.cnldat
 let arg_furto_roubo.pgtdat        = ""
 let arg_furto_roubo.c24nomctt     = ""
 let arg_furto_roubo.atdpvtretflg  = ""
 let arg_furto_roubo.atdvcltip     = ""
 let arg_furto_roubo.asitipcod     = ""
 let arg_furto_roubo.socvclcod     = ""
 let arg_furto_roubo.vclcoddig     = lr_param.vclcoddig
 let arg_furto_roubo.srvprlflg     = "N"
 let arg_furto_roubo.srrcoddig     = ""
 let arg_furto_roubo.atdprinvlcod  = 2
 let arg_furto_roubo.atdsrvorg     = lr_param.atdsrvorg
 let arg_furto_roubo.c24sintip     = lr_param.c24sintip
 let arg_furto_roubo.c24sinhor     = lr_param.c24sinhor
 let arg_furto_roubo.sindat        = lr_param.sindat
 let arg_furto_roubo.bocflg        = lr_param.bocflg
 let arg_furto_roubo.bocnum        = lr_param.bocnum
 let arg_furto_roubo.bocemi        = lr_param.bocemi
 let arg_furto_roubo.vicsnh        = lr_param.vicsnh
 let arg_furto_roubo.sinhor        = lr_param.sinhor
 let arg_furto_roubo.atdsrvseq     = 0
 let arg_furto_roubo.atdetpcod     = 4
 let arg_furto_roubo.atdetpdat     = lr_param.ligdat
 let arg_furto_roubo.atdetphor     = lr_param.lighorinc
 let arg_furto_roubo.empcod        = 1
 let arg_furto_roubo.funmat        = lr_param.c24funmat
 let arg_furto_roubo.c24endtip     = lr_param.c24endtip
 let arg_furto_roubo.lclidttxt     = lr_param.lclidttxt
 let arg_furto_roubo.lgdtip        = lr_param.lgdtip
 let arg_furto_roubo.lgdnom        = lr_param.lgdnom
 let arg_furto_roubo.lgdnum        = lr_param.lgdnum
 let arg_furto_roubo.lclbrrnom     = lr_param.lclbrrnom
 let arg_furto_roubo.brrnom        = lr_param.brrnom
 let arg_furto_roubo.cidnom        = lr_param.cidnom
 let arg_furto_roubo.ufdcod        = lr_param.ufdcod
 let arg_furto_roubo.lclrefptotxt  = lr_param.lclrefptotxt
 let arg_furto_roubo.endzon        = lr_param.endzon
 let arg_furto_roubo.lgdcep        = lr_param.lgdcep
 let arg_furto_roubo.lgdcepcmp     = lr_param.lgdcepcmp
 let arg_furto_roubo.lclltt        = lr_param.lclltt
 let arg_furto_roubo.lcllgt        = lr_param.lcllgt
 let arg_furto_roubo.lcldddcod     = lr_param.lcldddcod
 let arg_furto_roubo.lcltelnum     = lr_param.lcltelnum
 let arg_furto_roubo.lclcttnom     = lr_param.lclcttnom
 let arg_furto_roubo.c24lclpdrcod  = lr_param.c24lclpdrcod
 let arg_furto_roubo.lclofnnumdig  = lr_param.lclofnnumdig
 let arg_furto_roubo.emeviacod     = lr_param.emeviacod
 let arg_furto_roubo.sinntzcod     = lr_param.sinntzcod
 let arg_furto_roubo.eqprgicod     = lr_param.eqprgicod
 let arg_furto_roubo.ctcdtnom      = lr_param.ctcdtnom
 let arg_furto_roubo.ctcgccpfnum   = lr_param.ctcgccpfnum
 let arg_furto_roubo.ctcgccpfdig   = lr_param.ctcgccpfdig
 let arg_furto_roubo.qtd_historico = lr_param.qtd_historico
 let arg_furto_roubo.historico     = lr_param.historico
 let arg_furto_roubo.sinramcod     = lr_param.sinramcod clipped
 let arg_furto_roubo.sinano        = lr_param.sinano    clipped
 let arg_furto_roubo.sinnum        = lr_param.sinnum    clipped
 let arg_furto_roubo.sinitmseq     = lr_param.sinitmseq clipped

 if l_display = "s" or l_display = "S" then
    display "****** PARAMETROS ATUALIZADOS ********"
    display "arg_furto_roubo.ligdat       = ",arg_furto_roubo.ligdat
    display "arg_furto_roubo.lighorinc    = ",arg_furto_roubo.lighorinc
    display "arg_furto_roubo.c24soltipcod = ",arg_furto_roubo.c24soltipcod
    display "arg_furto_roubo.c24solnom    = ",arg_furto_roubo.c24solnom
    display "arg_furto_roubo.c24astcod    = ",arg_furto_roubo.c24astcod
    display "arg_furto_roubo.c24funmat    = ",arg_furto_roubo.c24funmat
    display "arg_furto_roubo.ligcvntip    = ",arg_furto_roubo.ligcvntip
    display "arg_furto_roubo.c24paxnum    = ",arg_furto_roubo.c24paxnum
    display "arg_furto_roubo.atdsrvnum    = ",arg_furto_roubo.atdsrvnum
    display "arg_furto_roubo.atdsrvano    = ",arg_furto_roubo.atdsrvano
    display "arg_furto_roubo.sinavsnum    = ",arg_furto_roubo.sinavsnum
    display "arg_furto_roubo.sinavsano    = ",arg_furto_roubo.sinavsano
    display "arg_furto_roubo.succod       = ",arg_furto_roubo.succod
    display "arg_furto_roubo.ramcod       = ",arg_furto_roubo.ramcod
    display "arg_furto_roubo.aplnumdig    = ",arg_furto_roubo.aplnumdig
    display "arg_furto_roubo.itmnumdig    = ",arg_furto_roubo.itmnumdig
    display "arg_furto_roubo.edsnumref    = ",arg_furto_roubo.edsnumref
    display "arg_furto_roubo.prporg       = ",arg_furto_roubo.prporg
    display "arg_furto_roubo.prpnumdig    = ",arg_furto_roubo.prpnumdig
    display "arg_furto_roubo.caddat       = ",arg_furto_roubo.caddat
    display "arg_furto_roubo.cadhor       = ",arg_furto_roubo.cadhor
    display "arg_furto_roubo.cademp       = ",arg_furto_roubo.cademp
    display "arg_furto_roubo.cadmat       = ",arg_furto_roubo.cadmat
    display "arg_furto_roubo.vclcorcod    = ",arg_furto_roubo.vclcorcod
    display "arg_furto_roubo.atdlibflg    = ",arg_furto_roubo.atdlibflg
    display "arg_furto_roubo.atdlibhor    = ",arg_furto_roubo.atdlibhor
    display "arg_furto_roubo.atdlibdat    = ",arg_furto_roubo.atdlibdat
    display "arg_furto_roubo.atdlclflg    = ",arg_furto_roubo.atdlclflg
    display "arg_furto_roubo.atdhorpvt    = ",arg_furto_roubo.atdhorpvt
    display "arg_furto_roubo.atddatprg    = ",arg_furto_roubo.atddatprg
    display "arg_furto_roubo.atdhorprg    = ",arg_furto_roubo.atdhorprg
    display "arg_furto_roubo.atdtip       = ",arg_furto_roubo.atdtip
    display "arg_furto_roubo.atdmotnom    = ",arg_furto_roubo.atdmotnom
    display "arg_furto_roubo.atdvclsgl    = ",arg_furto_roubo.atdvclsgl
    display "arg_furto_roubo.atdprscod    = ",arg_furto_roubo.atdprscod
    display "arg_furto_roubo.atdcstvlr    = ",arg_furto_roubo.atdcstvlr
    display "arg_furto_roubo.atdfnlflg    = ",arg_furto_roubo.atdfnlflg
    display "arg_furto_roubo.atdfnlhor    = ",arg_furto_roubo.atdfnlhor
    display "arg_furto_roubo.atdrsdflg    = ",arg_furto_roubo.atdrsdflg
    display "arg_furto_roubo.atddfttxt    = ",arg_furto_roubo.atddfttxt
    display "arg_furto_roubo.atddoctxt    = ",arg_furto_roubo.atddoctxt
    display "arg_furto_roubo.c24opemat    = ",arg_furto_roubo.c24opemat
    display "arg_furto_roubo.nom          = ",arg_furto_roubo.nom
    display "arg_furto_roubo.cornom       = ",arg_furto_roubo.cornom
    display "arg_furto_roubo.corsus       = ",arg_furto_roubo.corsus
    display "arg_furto_roubo.vcldes       = ",arg_furto_roubo.vcldes
    display "arg_furto_roubo.vclanomdl    = ",arg_furto_roubo.vclanomdl
    display "arg_furto_roubo.vcllicnum    = ",arg_furto_roubo.vcllicnum
    display "arg_furto_roubo.sindat       = ",arg_furto_roubo.sindat
    display "arg_furto_roubo.sinavs       = ",arg_furto_roubo.sinavs
    display "arg_furto_roubo.cnldat       = ",arg_furto_roubo.cnldat
    display "arg_furto_roubo.pgtdat       = ",arg_furto_roubo.pgtdat
    display "arg_furto_roubo.c24nomctt    = ",arg_furto_roubo.c24nomctt
    display "arg_furto_roubo.atdpvtretflg = ",arg_furto_roubo.atdpvtretflg
    display "arg_furto_roubo.atdvcltip    = ",arg_furto_roubo.atdvcltip
    display "arg_furto_roubo.asitipcod    = ",arg_furto_roubo.asitipcod
    display "arg_furto_roubo.socvclcod    = ",arg_furto_roubo.socvclcod
    display "arg_furto_roubo.vclcoddig    = ",arg_furto_roubo.vclcoddig
    display "arg_furto_roubo.srvprlflg    = ",arg_furto_roubo.srvprlflg
    display "arg_furto_roubo.srrcoddig    = ",arg_furto_roubo.srrcoddig
    display "arg_furto_roubo.atdprinvlcod = ",arg_furto_roubo.atdprinvlcod
    display "arg_furto_roubo.atdsrvorg    = ",arg_furto_roubo.atdsrvorg
    display "arg_furto_roubo.c24sintip    = ",arg_furto_roubo.c24sintip
    display "arg_furto_roubo.c24sinhor    = ",arg_furto_roubo.c24sinhor
    display "arg_furto_roubo.sindat       = ",arg_furto_roubo.sindat
    display "arg_furto_roubo.bocflg       = ",arg_furto_roubo.bocflg
    display "arg_furto_roubo.bocnum       = ",arg_furto_roubo.bocnum
    display "arg_furto_roubo.bocemi       = ",arg_furto_roubo.bocemi
    display "arg_furto_roubo.vicsnh       = ",arg_furto_roubo.vicsnh
    display "arg_furto_roubo.sinhor       = ",arg_furto_roubo.sinhor
    display "arg_furto_roubo.atdsrvseq    = ",arg_furto_roubo.atdsrvseq
    display "arg_furto_roubo.atdetpcod    = ",arg_furto_roubo.atdetpcod
    display "arg_furto_roubo.atdetpdat    = ",arg_furto_roubo.atdetpdat
    display "arg_furto_roubo.atdetphor    = ",arg_furto_roubo.atdetphor
    display "arg_furto_roubo.empcod       = ",arg_furto_roubo.empcod
    display "arg_furto_roubo.funmat       = ",arg_furto_roubo.funmat
    display "arg_furto_roubo.c24endtip    = ",arg_furto_roubo.c24endtip
    display "arg_furto_roubo.lclidttxt    = ",arg_furto_roubo.lclidttxt
    display "arg_furto_roubo.lgdtip       = ",arg_furto_roubo.lgdtip
    display "arg_furto_roubo.lgdnom       = ",arg_furto_roubo.lgdnom
    display "arg_furto_roubo.lgdnum       = ",arg_furto_roubo.lgdnum
    display "arg_furto_roubo.lclbrrnom    = ",arg_furto_roubo.lclbrrnom
    display "arg_furto_roubo.brrnom       = ",arg_furto_roubo.brrnom
    display "arg_furto_roubo.cidnom       = ",arg_furto_roubo.cidnom
    display "arg_furto_roubo.ufdcod       = ",arg_furto_roubo.ufdcod
    display "arg_furto_roubo.lclrefptotxt = ",arg_furto_roubo.lclrefptotxt
    display "arg_furto_roubo.endzon       = ",arg_furto_roubo.endzon
    display "arg_furto_roubo.lgdcep       = ",arg_furto_roubo.lgdcep
    display "arg_furto_roubo.lgdcepcmp    = ",arg_furto_roubo.lgdcepcmp
    display "arg_furto_roubo.lclltt       = ",arg_furto_roubo.lclltt
    display "arg_furto_roubo.lcllgt       = ",arg_furto_roubo.lcllgt
    display "arg_furto_roubo.lcldddcod    = ",arg_furto_roubo.lcldddcod
    display "arg_furto_roubo.lcltelnum    = ",arg_furto_roubo.lcltelnum
    display "arg_furto_roubo.lclcttnom    = ",arg_furto_roubo.lclcttnom
    display "arg_furto_roubo.c24lclpdrcod = ",arg_furto_roubo.c24lclpdrcod
    display "arg_furto_roubo.lclofnnumdig = ",arg_furto_roubo.lclofnnumdig
    display "arg_furto_roubo.emeviacod    = ",arg_furto_roubo.emeviacod
    display "arg_furto_roubo.sinntzcod    = ",arg_furto_roubo.sinntzcod
    display "arg_furto_roubo.eqprgicod    = ",arg_furto_roubo.eqprgicod
    display "arg_furto_roubo.ctcdtnom     = ",arg_furto_roubo.ctcdtnom
    display "arg_furto_roubo.ctcgccpfnum  = ",arg_furto_roubo.ctcgccpfnum
    display "arg_furto_roubo.ctcgccpfdig  = ",arg_furto_roubo.ctcgccpfdig
    display "arg_furto_roubo.qtd_historico= ",arg_furto_roubo.qtd_historico
    display "arg_furto_roubo.historico    = ",arg_furto_roubo.historico clipped
    display "arg_furto_roubo.sinramcod    = ",arg_furto_roubo.sinramcod
    display "arg_furto_roubo.sinano       = ",arg_furto_roubo.sinano
    display "arg_furto_roubo.sinnum       = ",arg_furto_roubo.sinnum
    display "arg_furto_roubo.sinitmseq    = ",arg_furto_roubo.sinitmseq
    display "******* FIM PARAMETROS ATUALIZADOS ********"
 end if

 ## Gera ligacao

 begin work
 call cts10g03_numeracao( 1, "" )
      returning l_ret_srvlig_furrou.lignum    ,
                l_ret_srvlig_furrou.atdsrvnum ,
                l_ret_srvlig_furrou.atdsrvano ,
                l_ret_srvlig_furrou.erro      ,
                l_ret_srvlig_furrou.msgerro

 if l_ret_srvlig_furrou.erro <> 0 then
    rollback work
    let l_retorno_furrou.err = l_ret_srvlig_furrou.erro
    let l_retorno_furrou.msg = l_ret_srvlig_furrou.msgerro
 else
    commit work
 end if

 if arg_furto_roubo.sinramcod is null or arg_furto_roubo.sinramcod = " " or
    arg_furto_roubo.sinano    is null or arg_furto_roubo.sinano    = " " or
    arg_furto_roubo.sinnum    is null or arg_furto_roubo.sinnum    = " " or
    arg_furto_roubo.sinitmseq is null or arg_furto_roubo.sinitmseq = " " then
    # nao gerou numero de sinistro na web, registra ligacao no aviso
    let arg_furto_roubo.sinramcod = null
    let arg_furto_roubo.sinano    = null
    let arg_furto_roubo.sinnum    = null
    let arg_furto_roubo.sinitmseq = null
    select sinvstano,
           sinvstnum,
           prporg,
           prpnumdig,
           dddcod,
           teltxt,
           solempcod,
           solfunmat,
           solusrtip,
           cgccpfnum,
           cgcord,
           cgccpfdig,
           corsus
    into   l_sinvstano,
           l_sinvstnum,
           arg_furto_roubo.prporg,
           arg_furto_roubo.prpnumdig,
           l_dddcod,
           l_teltxt,
           l_solempcod,
           l_solfunmat,
           l_solusrtip,
           l_cgccpfnum,
           l_cgcord,
           l_cgccpfdig,
           l_corsus
    from   datmsinatditf
    where  atlemp    = arg_furto_roubo.empcod
    and    atlmat    = arg_furto_roubo.c24funmat
    and    atlusrtip = "F"
    and    atdassdes = arg_furto_roubo.c24astcod

    if sqlca.sqlcode = notfound then
       display "entrei "
        begin work
        call cts10g03_numeracao( 0, "5" )
             returning l_lignum    ,
                       l_sinvstnum ,
                       l_sinvstano ,
                       l_ret_srvlig_furrou.erro      ,
                       l_ret_srvlig_furrou.msgerro

        if l_ret_srvlig_furrou.erro <> 0 then
           rollback work
           let l_retorno_furrou.err = l_ret_srvlig_furrou.erro
           let l_retorno_furrou.msg = l_ret_srvlig_furrou.msgerro
        else
           commit work
           let l_ret_srvlig_furrou.atdsrvnum = l_sinvstnum
           let l_ret_srvlig_furrou.atdsrvano = l_sinvstano
        end if
    else
       let l_ret_srvlig_furrou.atdsrvnum = l_sinvstnum
       let l_ret_srvlig_furrou.atdsrvano = l_sinvstano[3,4]
    end if



    let arg_furto_roubo.atdsrvnum = l_ret_srvlig_furrou.atdsrvnum
    let arg_furto_roubo.atdsrvano = l_ret_srvlig_furrou.atdsrvano

    let l_gera_hist_srv = true

    if l_display = "s" or l_display = "S" then
       display "<ctq00m01 807 > **** Nao gerou sinistro na web ****"
       display "l_sinvstano              = ",l_sinvstano
       display "l_sinvstnum              = ",l_sinvstnum
       display "arg_furto_roubo.prporg   = ",arg_furto_roubo.prporg
       display "arg_furto_roubo.prpnumdig= ",arg_furto_roubo.prpnumdig
       display "l_dddcod                 = ",l_dddcod
       display "l_teltxt                 = ",l_teltxt
       display "l_solempcod              = ",l_solempcod
       display "l_solfunmat              = ",l_solfunmat
       display "l_solusrtip              = ",l_solusrtip
       display "l_cgccpfnum              = ",l_cgccpfnum
       display "l_cgcord                 = ",l_cgcord
       display "l_cgccpfdig              = ",l_cgccpfdig
       display "l_corsus                 = ",l_corsus
       display "arg_furto_roubo.atdsrvnum =",arg_furto_roubo.atdsrvnum
       display "arg_furto_roubo.atdsrvano =",arg_furto_roubo.atdsrvano
    end if
 else
    let l_gera_hist_srv = false
 end if

 let l_aux = current

 let l_cts14m00_ano4 =  '20', l_ret_srvlig_furrou.atdsrvano using "&&"

 ## retirar
 if arg_furto_roubo.lignum is null then
    let arg_furto_roubo.lignum       = l_ret_srvlig_furrou.lignum
 end if

 ## Inicializar Variaves ##
 let g_documento.corsus       = null
 let g_documento.dddcod       = null
 let g_documento.ctttel       = null
 let g_documento.funmat       = null
 let g_documento.cgccpfnum    = null
 let g_documento.empcodatd    = null
 let g_documento.funmatatd    = null
 let g_documento.usrtipatd    = null
 let g_documento.rcuccsmtvcod = null
 let g_documento.ligcvntip    = null
 let g_issk.funmat            = lr_param.c24funmat


 if arg_furto_roubo.aplnumdig is null then
    select sinvstano,
           sinvstnum,
           prporg,
           prpnumdig,
           dddcod,
           teltxt,
           solempcod,
           solfunmat,
           solusrtip,
           cgccpfnum,
           cgcord,
           cgccpfdig,
           corsus
    into   l_sinvstano,
           l_sinvstnum,
           arg_furto_roubo.prporg,
           arg_furto_roubo.prpnumdig,
           l_dddcod,
           l_teltxt,
           l_solempcod,
           l_solfunmat,
           l_solusrtip,
           l_cgccpfnum,
           l_cgcord,
           l_cgccpfdig,
           l_corsus
    from   datmsinatditf
    where  atlemp    = arg_furto_roubo.empcod
    and    atlmat    = arg_furto_roubo.c24funmat
    and    atlusrtip = "F"
    #and    atdassdes = arg_furto_roubo.c24astcod

    display "917    l_solfunmat = ",l_solfunmat
    display "918    l_cgccpfnum = ",l_cgccpfnum
    display "919    l_cgcord,   = ",l_cgcord
    display "920    l_cgccpfdig = ",l_cgccpfdig
    display "921    l_corsus    = ",l_corsus
    display "arg_furto_roubo.prporg     = ",arg_furto_roubo.prporg
    display "arg_furto_roubo.prpnumdig  = ",arg_furto_roubo.prpnumdig

 end if



 # carrega global para registro sem documento

 if l_corsus is not null then
       display "Entrei Sem Documento Corretor"
       let g_documento.corsus = l_corsus
 end if

 if l_teltxt is not null and
    l_teltxt <> 0 then
    display "Entrei Sem Documento Telefone"
    let g_documento.dddcod = l_dddcod
    let g_documento.ctttel = l_teltxt
 end if

 if l_solfunmat is not null and
    l_solfunmat <> 0 then
    display "Entrei Sem Documento Matricula"
    let g_documento.funmat = l_solfunmat
 end if

 if l_cgccpfnum is not null and
    l_cgccpfnum <> 0 then
    display "Entrei Sem Documento cgccpf"
    let g_documento.cgccpfnum = l_cgccpfnum
    let g_documento.cgcord    = l_cgcord
    let g_documento.cgccpfdig = l_cgccpfdig
 end if

 ## Inicializada como null pois nao recebe como parametro
 let g_issk.empcod            =  1
 let g_issk.usrtip            = "F"
 let g_documento.empcodatd    =  null
 let g_documento.funmatatd    =  null
 let g_documento.usrtipatd    =  null

 ## psi Galbe V10 select grlinf
 ## psi Galbe V10 into   g_issk.funmat
 ## psi Galbe V10 from   datkgeral
 ## psi Galbe V10 where  grlchv = "USRCT24HPORTAL"

 if arg_furto_roubo.ligcvntip is not null then
    let g_documento.ligcvntip = arg_furto_roubo.ligcvntip
 end if

 let l_aux = current
 display "<ctq00m01 888> Gravando Ligacao ", l_aux

 begin work
 call cts10g00_ligacao( arg_furto_roubo.lignum       ,
                        arg_furto_roubo.ligdat       ,
                        arg_furto_roubo.lighorinc    ,
                        arg_furto_roubo.c24soltipcod ,
                        arg_furto_roubo.c24solnom    ,
                        arg_furto_roubo.c24astcod    ,
                        arg_furto_roubo.c24funmat    ,
                        arg_furto_roubo.ligcvntip    ,
                        arg_furto_roubo.c24paxnum    ,
                        arg_furto_roubo.atdsrvnum    ,
                        arg_furto_roubo.atdsrvano    ,
                        arg_furto_roubo.sinvstnum    ,
                        arg_furto_roubo.sinvstano    ,
                        arg_furto_roubo.sinavsnum    ,
                        arg_furto_roubo.sinavsano    ,
                        arg_furto_roubo.succod       ,
                        arg_furto_roubo.ramcod       ,
                        arg_furto_roubo.aplnumdig    ,
                        arg_furto_roubo.itmnumdig    ,
                        arg_furto_roubo.edsnumref    ,
                        arg_furto_roubo.prporg       ,
                        arg_furto_roubo.prpnumdig    ,
                        arg_furto_roubo.fcapacorg    ,
                        arg_furto_roubo.fcapacnum    ,
                        arg_furto_roubo.sinramcod    ,
                        arg_furto_roubo.sinano       ,
                        arg_furto_roubo.sinnum       ,
                        arg_furto_roubo.sinitmseq    ,
                        arg_furto_roubo.caddat       ,
                        arg_furto_roubo.cadhor       ,
                        arg_furto_roubo.cademp       ,
                        arg_furto_roubo.cadmat
                        )
 returning l_ret_tab.tabname,
           l_ret_tab.sqlcode

 let l_mensagem_erro = "**** GRAVOU OK ****"
 if l_ret_tab.sqlcode <> 0 then
    let l_mensagem_erro = l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela " ,l_ret_tab.tabname
    let l_retorno_furrou.err = l_ret_tab.sqlcode
    let l_retorno_furrou.msg = l_mensagem_erro
    rollback work
 else
    commit work
 end if
 let l_aux = current
 display "<ctq00m01 937 > ",l_mensagem_erro," ",l_aux

 if arg_furto_roubo.sinnum is null then
    display "<ctq00m01 940> **** NAO GEROU SINISTRO, GRAVAR LEGADO INFORMIX ****"
    display "<ctq00m01 941 > Gravando Servico ", l_aux
    call cts10g02_grava_servico(arg_furto_roubo.atdsrvnum    ,
                                arg_furto_roubo.atdsrvano,
                                arg_furto_roubo.c24soltipcod ,
                                arg_furto_roubo.c24solnom    ,
                                arg_furto_roubo.vclcorcod    ,
                                arg_furto_roubo.funmat       ,
                                arg_furto_roubo.atdlibflg    ,
                                arg_furto_roubo.atdlibhor    ,
                                arg_furto_roubo.atdlibdat    ,
                                arg_furto_roubo.ligdat       , ##  atddat
                                arg_furto_roubo.lighorinc    , ##  atdhor
                                arg_furto_roubo.atdlclflg    ,
                                arg_furto_roubo.atdhorpvt    ,
                                arg_furto_roubo.atddatprg    ,
                                arg_furto_roubo.atdhorprg    ,
                                arg_furto_roubo.atdtip       ,
                                arg_furto_roubo.atdmotnom    ,
                                arg_furto_roubo.atdvclsgl    ,
                                arg_furto_roubo.atdprscod    ,
                                arg_furto_roubo.atdcstvlr    ,
                                arg_furto_roubo.atdfnlflg    ,
                                arg_furto_roubo.atdfnlhor    ,
                                arg_furto_roubo.atdrsdflg    ,
                                arg_furto_roubo.atddfttxt    ,
                                arg_furto_roubo.atddoctxt    ,
                                arg_furto_roubo.c24opemat    ,
                                arg_furto_roubo.nom          ,
                                arg_furto_roubo.vcldes       ,
                                arg_furto_roubo.vclanomdl    ,
                                arg_furto_roubo.vcllicnum    ,
                                arg_furto_roubo.corsus       ,
                                arg_furto_roubo.cornom       ,
                                arg_furto_roubo.cnldat       ,
                                arg_furto_roubo.pgtdat       ,
                                arg_furto_roubo.c24nomctt    ,
                                arg_furto_roubo.atdpvtretflg ,
                                arg_furto_roubo.atdvcltip    ,
                                arg_furto_roubo.asitipcod    ,
                                arg_furto_roubo.socvclcod    ,
                                arg_furto_roubo.vclcoddig    ,
                                arg_furto_roubo.srvprlflg    ,
                                arg_furto_roubo.srrcoddig    ,
                                arg_furto_roubo.atdprinvlcod ,
                                arg_furto_roubo.atdsrvorg)
    returning l_ret_tab.tabname,
              l_ret_tab.sqlcode

    let l_mensagem_erro = "**** GRAVOU OK ****"
    if l_ret_tab.sqlcode <> 0 then
       let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela " ,l_ret_tab.tabname
       let l_retorno_furrou.err = l_ret_tab.sqlcode
       let l_retorno_furrou.msg = l_mensagem_erro
    end if
    let l_aux = current
    display "<ctq00m01 996 > ",l_mensagem_erro," ",l_aux
    #---------------------------------------------------------------------------
    # Grava complemento do servico
    #---------------------------------------------------------------------------
     display "<ctq00m01 1000 > Gravando Datmservicocmp ", l_aux
     insert into datmservicocmp ( atdsrvnum,
                                  atdsrvano,
                                  c24sintip,
                                  c24sinhor,
                                  sindat   ,
                                  bocflg   ,
                                  bocnum   ,
                                  bocemi   ,
                                  vicsnh   ,
                                  sinhor)
                         values ( arg_furto_roubo.atdsrvnum     ,
                                  arg_furto_roubo.atdsrvano     ,
                                  arg_furto_roubo.c24sintip     , ## F-Furto ou R-Roubo
                                  arg_furto_roubo.c24sinhor     ,
                                  arg_furto_roubo.sindat        ,
                                  arg_furto_roubo.bocflg        ,
                                  arg_furto_roubo.bocnum        ,
                                  arg_furto_roubo.bocemi        ,
                                  arg_furto_roubo.vicsnh        ,
                                  arg_furto_roubo.sinhor
                                )
    let l_mensagem_erro = "**** GRAVOU OK ****"
    if l_ret_tab.sqlcode <> 0 then
       let l_ret_tab.sqlcode = sqlca.sqlcode
       let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela DATMSERVICOCMP "
       let l_retorno_furrou.err     = l_ret_tab.sqlcode
       let l_retorno_furrou.msg     = l_mensagem_erro
    end if
    let l_aux = current
    display "<ctq00m01 1030 > ",l_mensagem_erro," ",l_aux
    #--------------------------------------------------------------------------
    # Grava etapas do acompanhamento
    #---------------------------------------------------------------------------
    let ins_etapa  =  null
    let l_aux = current
    display "<ctq00m01 1036 > Gravando Etapa ", l_aux
    call cts10g04_insere_etapa( arg_furto_roubo.atdsrvnum     ,
                                l_ret_srvlig_furrou.atdsrvano ,
                                4                             ,
                                ""                            ,
                                ""                            ,
                                ""                            ,
                                ""
                              )
    returning ins_etapa
    let l_mensagem_erro = "**** GRAVOU OK ****", ins_etapa
    display "<ctq00m01 1047 > ",l_mensagem_erro," ",l_aux

    #---------------------------------------------------------------------------
    # Grava locais de (1) ocorrencia  / (2) destino
    #---------------------------------------------------------------------------
    let arg_furto_roubo.operacao = "I"
    let l_aux = current
    display "<ctq00m01 1054 > Gravando Local ", l_aux

    let l_ret_tab.sqlcode = cts06g07_local( arg_furto_roubo.operacao     ,
                                            arg_furto_roubo.atdsrvnum    ,
                                            arg_furto_roubo.atdsrvano    ,
                                            arg_furto_roubo.c24endtip    ,
                                            arg_furto_roubo.lclidttxt    ,
                                            arg_furto_roubo.lgdtip       ,
                                            arg_furto_roubo.lgdnom       ,
                                            arg_furto_roubo.lgdnum       ,
                                            arg_furto_roubo.lclbrrnom    ,
                                            arg_furto_roubo.brrnom       ,
                                            arg_furto_roubo.cidnom       ,
                                            arg_furto_roubo.ufdcod       ,
                                            arg_furto_roubo.lclrefptotxt ,
                                            arg_furto_roubo.endzon       ,
                                            arg_furto_roubo.lgdcep       ,
                                            arg_furto_roubo.lgdcepcmp    ,
                                            arg_furto_roubo.lclltt       ,
                                            arg_furto_roubo.lcllgt       ,
                                            arg_furto_roubo.lcldddcod    ,
                                            arg_furto_roubo.lcltelnum    ,
                                            arg_furto_roubo.lclcttnom    ,
                                            arg_furto_roubo.c24lclpdrcod ,
                                            arg_furto_roubo.lclofnnumdig ,
                                            arg_furto_roubo.emeviacod,
                                            arg_furto_roubo.celteldddcod,
                                            arg_furto_roubo.celtelnum   ,
                                            arg_furto_roubo.endcmp )
    let l_mensagem_erro = "**** GRAVOU OK ****"
    if l_ret_tab.sqlcode <> 0 then
       let l_ret_tab.sqlcode = sqlca.sqlcode
       let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela datmlcl(Ocorrencia) "
       let l_retorno_furrou.err     = l_ret_tab.sqlcode
       let l_retorno_furrou.msg     = l_mensagem_erro
    end if
    let l_aux = current
    display "<ctq00m01 1089 > ",l_mensagem_erro," ",l_aux
    #--------------------------------------------------------------------------
    # Grava relacionamento servico / apolice
    #---------------------------------------------------------------------------
    ## futuramente Substituir pela função ctd07g02 - Implementando a funçãso de insert

    if arg_furto_roubo.succod    is not null  and
       arg_furto_roubo.ramcod    is not null  and
       arg_furto_roubo.aplnumdig is not null  then
       let l_aux = current
       display "<ctq00m01 1099 > Gravando Datrservapol ", l_aux
       insert into datrservapol ( atdsrvnum,
                                  atdsrvano,
                                  succod   ,
                                  ramcod   ,
                                  aplnumdig,
                                  itmnumdig,
                                  edsnumref )
                         values ( arg_furto_roubo.atdsrvnum    ,
                                  arg_furto_roubo.atdsrvano, ## arg_furto_roubo.sinvstano ,
                                  arg_furto_roubo.succod       ,
                                  arg_furto_roubo.ramcod       ,
                                  arg_furto_roubo.aplnumdig    ,
                                  arg_furto_roubo.itmnumdig    ,
                                  arg_furto_roubo.edsnumref )
       let l_mensagem_erro = "**** GRAVOU OK ****"
       if l_ret_tab.sqlcode <> 0 then
          let l_ret_tab.sqlcode = sqlca.sqlcode
          let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela DATRSERVAPOL "
          let l_retorno_furrou.err = l_ret_tab.sqlcode
          let l_retorno_furrou.msg = l_mensagem_erro
       end if
       let l_aux = current
       display "<ctq00m01 1122 > ",l_mensagem_erro," ",l_aux

       -------------[ gravar condutor conforme flag assunto ]-------------
       let l_cndslcflg = null
       select cndslcflg
         into l_cndslcflg
         from datkassunto
        where c24astcod = arg_furto_roubo.c24astcod
       if sqlca.sqlcode <> 0 then
          let l_cndslcflg = null
       end if
       if l_cndslcflg = "S"  then
          let l_aux = current
          display "<ctq00m01 > Gravando Condutor     ", l_aux
          call grava_condutor(arg_furto_roubo.succod,
                              arg_furto_roubo.aplnumdig,
                              arg_furto_roubo.itmnumdig,
                              arg_furto_roubo.ctcdtnom,
                              arg_furto_roubo.ctcgccpfnum,
                              arg_furto_roubo.ctcgccpfdig,
                              "D",
                              "CENTRAL24H" )
               returning      arg_furto_roubo.cdtseq
          # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
          insert into datrsrvcnd
                     (atdsrvnum,
                      atdsrvano,
                      succod   ,
                      aplnumdig,
                      itmnumdig,
                      vclcndseq )
              values (arg_furto_roubo.atdsrvnum ,
                      arg_furto_roubo.atdsrvano ,
                      arg_furto_roubo.succod    ,
                      arg_furto_roubo.aplnumdig ,
                      arg_furto_roubo.itmnumdig ,
                      arg_furto_roubo.cdtseq )

          let l_mensagem_erro = "**** GRAVOU OK ****"
          if l_ret_tab.sqlcode <> 0 then
             let l_ret_tab.sqlcode = sqlca.sqlcode
             let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela datrsrvcnd "
             let l_retorno_furrou.err = l_ret_tab.sqlcode
             let l_retorno_furrou.msg = l_mensagem_erro
          end if
          let l_aux = current
          display "<ctq00m01 1168 > ",l_mensagem_erro," ",l_aux
       end if
    end if
    #--------------------------------------------------------------------------
    # Grava tabela de relacionamento Servico x Vistoria Sinistro
    #---------------------------------------------------------------------------
    let l_aux = current
    display "<ctq00m01 1175 > Gravando Datrsrvvstsin ", l_aux
    display "arg_furto_roubo.atdsrvnum = ",arg_furto_roubo.atdsrvnum
    display "arg_furto_roubo.atdsrvano = ",arg_furto_roubo.atdsrvano
    display "l_cts14m00_ano4 = ",l_cts14m00_ano4
    insert into datrsrvvstsin( atdsrvnum                     ,
                               atdsrvano                     ,
                               sinvstnum                     ,
                               sinvstano                     ,
                               sinvstlauemsstt )
                       values( arg_furto_roubo.atdsrvnum     ,
                               arg_furto_roubo.atdsrvano     ,
                               arg_furto_roubo.atdsrvnum     ,
                               l_cts14m00_ano4               ,
                               1               )
    let l_mensagem_erro = "**** GRAVOU OK ****"
    if l_ret_tab.sqlcode <> 0 then
       let l_ret_tab.sqlcode = sqlca.sqlcode
       let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela DATRSRVVSTSIN "
       let l_retorno_furrou.err = l_ret_tab.sqlcode
       let l_retorno_furrou.msg = l_mensagem_erro
    end if
    let l_aux = current
    display "<ctq00m01 1194> ",l_mensagem_erro," ",l_aux

    #---------------------------------------------------------------------------
    # Grava tabela de Aviso de sinistro
    #---------------------------------------------------------------------------
    let l_aux = current
    display "<ctq00m01 1200 > Gravando Datmavssin    ", l_aux
    insert into datmavssin( sinvstnum,
                            sinvstano,
                            atdsrvnum,
                            atdsrvano,
                            sinntzcod,
                            eqprgicod )
                    values( arg_furto_roubo.atdsrvnum     ,
                            l_cts14m00_ano4               ,
                            arg_furto_roubo.atdsrvnum     ,
                            arg_furto_roubo.atdsrvano     ,
                            arg_furto_roubo.sinntzcod     ,
                            arg_furto_roubo.eqprgicod )

    let l_mensagem_erro = "**** GRAVOU OK ****"
    if l_ret_tab.sqlcode <> 0 then
       let l_ret_tab.sqlcode = sqlca.sqlcode
       let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela DATMAVSSIN "
       let l_retorno_furrou.err = l_ret_tab.sqlcode
       let l_retorno_furrou.msg = l_mensagem_erro
    end if
    let l_aux = current
    display "<ctq00m01 1222> ",l_mensagem_erro," ",l_aux

    #---------------------------------------------------------------------------
    # Grava tabela de Historico do Servico
    #-------------------------------------------------------------------------

    display "<ctq00m01 1228> Gravando Datmlighist ", l_aux
    let l_mensagem_erro = "**** GRAVOU OK ****"
    let n_posicao_fin = 0
    let n_conta       = 0
    let l_historico   = " "

    let n_posicao_inc = 1
    for n_conta = 1 to arg_furto_roubo.qtd_historico
        let n_posicao_fin = n_conta * 70
        let l_historico = arg_furto_roubo.historico[n_posicao_inc,n_posicao_fin]
        call ctd07g01_ins_datmservhist(arg_furto_roubo.atdsrvnum,
                                       arg_furto_roubo.atdsrvano,
                                       arg_furto_roubo.c24funmat,
                                       l_historico,
                                       arg_furto_roubo.ligdat,
                                       arg_furto_roubo.lighorinc,
                                       g_issk.empcod,
                                       g_issk.usrtip)

             returning l_ret,
                       l_mensagem

        if l_ret <> 1  then
           let l_mensagem_erro = l_mensagem," ","ctq00m01-Avise Info!"
           exit for
        end if
        let n_posicao_inc = n_posicao_fin + 1
    end for
    let l_aux = current
    display "<ctq00m01 1257 > ",l_mensagem_erro," ",l_aux

    call cts40g03_data_hora_banco(2)
         returning l_data_banco, l_hora2

    # Ponto de acesso apos a gravacao do laudo
    call cts00g07_apos_grvlaudo(arg_furto_roubo.atdsrvnum,
                                arg_furto_roubo.atdsrvano)


 else
    display "<ctq00m0 1262> **** GEROU SINISTRO-",arg_furto_roubo.sinano," ", arg_furto_roubo.sinnum
    #---------------------------------------------------------------------------
    # Grava tabela de Historico da Ligacao
    #---------------------------------------------------------------------------
    if l_retorno_furrou.err = 0 then
        display "<ctq00m01 1267 > Gravando Datmlighist ", l_aux
        let l_mensagem_erro = "**** GRAVOU OK ****"
        let n_posicao_fin = 0
        let n_conta       = 0
        let l_historico   = " "
        let n_posicao_inc = 1
        for n_conta = 1 to arg_furto_roubo.qtd_historico
            let n_posicao_fin = n_conta * 70
            let l_historico = arg_furto_roubo.historico[n_posicao_inc,n_posicao_fin]
            call ctd06g01_ins_datmlighist(arg_furto_roubo.lignum    ,
                                          arg_furto_roubo.c24funmat ,
                                          l_historico               ,
                                          arg_furto_roubo.ligdat    ,
                                          arg_furto_roubo.lighorinc ,
                                          g_issk.empcod             ,
                                          g_issk.usrtip)
            returning l_ret,
                      l_mensagem

            if l_ret <> 1  then
               let l_mensagem_erro = l_mensagem," ","ctq00m01-Avise Info!"
               exit for
            end if
            let n_posicao_inc = n_posicao_fin + 1
        end for
        let l_aux = current
        display "<ctq00m0 1293> ",l_mensagem_erro," ",l_aux
    end if
 end if

 # psi230669
 if (lr_param.atdnum is not null and
     lr_param.atdnum <> 0) then
     call ctd25g00_insere_atendimento(lr_param.atdnum,arg_furto_roubo.lignum)
     returning l_erro,l_msg_erro

     let l_mensagem_erro = "**** GRAVOU OK ****"
     if l_erro = 1 then
           let l_mensagem_erro = l_msg_erro
           let l_retorno_furrou.err = l_erro
           let l_retorno_furrou.msg = l_msg_erro
     end if
     let l_aux = current
     display "<ctq00m01 1310 > ",l_mensagem_erro," ",l_aux
 end if
 # Fim psi230669

 #let l_retorno_furrou.err       = l_ret_srvlig_furrou.erro
 #let l_retorno_furrou.msg       = l_ret_srvlig_furrou.msgerro
 let l_retorno_furrou.lignum    = l_ret_srvlig_furrou.lignum
 let l_retorno_furrou.atdsrvnum = l_ret_srvlig_furrou.atdsrvnum
 let l_retorno_furrou.atdsrvano = l_ret_srvlig_furrou.atdsrvano
 if l_display = "s" or l_display = "S" then
    display "**** FIM ctq00m01 - l_retorno_furrou.err = ",l_retorno_furrou.err
    display "                    l_retorno_furrou.msg = ",l_retorno_furrou.msg
    display "                 l_retorno_furrou.lignum = ",l_retorno_furrou.lignum
    display "              l_retorno_furrou.atdsrvnum = ",l_retorno_furrou.atdsrvnum
    display "              l_retorno_furrou.atdsrvano = ",l_retorno_furrou.atdsrvano
 end if
 return l_retorno_furrou.err       ,
        l_retorno_furrou.msg       ,
        l_retorno_furrou.lignum    ,
        l_retorno_furrou.atdsrvnum ,
        l_retorno_furrou.atdsrvano

 end function

#-----------------------------------------------
 function ctq00m01_cons_param(lr_cons_param)
#-----------------------------------------------

 define lr_cons_param record
        ligdat           like datmligacao.ligdat         ,
        lighorinc        like datmligacao.lighorinc      ,
        c24soltip        like datmligacao.c24soltip      ,
        c24solnom        like datmligacao.c24solnom      ,
        c24astcod        like datmligacao.c24astcod      ,
        c24funmat        like datmligacao.c24funmat      ,
        ligcvntip        like datmligacao.ligcvntip      ,
        c24soltipcod     like datmligacao.c24soltipcod   ,
        succod           like datrservapol.succod        ,
        ramcod           like datrservapol.ramcod        ,
        aplnumdig        like datrservapol.aplnumdig     ,
        itmnumdig        like datrservapol.itmnumdig     ,
        edsnumref        like datrservapol.edsnumref     ,
        atddat           like datmservico.atddat         ,
        atdhor           like datmservico.atdhor         ,
        atdtip           like datmservico.atdtip         ,
        atdfnlflg        like datmservico.atdfnlflg      ,
        atdprinvlcod     like datmservico.atdprinvlcod   ,
## Local de Ocorrencia
        c24endtip        like datmlcl.c24endtip          ,
        lgdnom           like datmlcl.lgdnom             ,
        lclbrrnom        like datmlcl.lclbrrnom          ,
        cidnom           like datmlcl.cidnom             ,
        ufdcod           like datmlcl.ufdcod             ,
        c24lclpdrcod     like datmlcl.c24lclpdrcod
 end record

 define ret_param_msg char(50)

 let ret_param_msg= "000-Parametros OK "

 if lr_cons_param.ligdat       is null or
    lr_cons_param.lighorinc    is null or
    lr_cons_param.c24soltip    is null or
    lr_cons_param.c24solnom    is null or
    lr_cons_param.c24astcod    is null or
    lr_cons_param.c24funmat    is null or
    lr_cons_param.ligcvntip    is null then
    let ret_param_msg = "001-Parametro Nulo para gravar datmligacao "
 end if

#if lr_cons_param.succod    is null or
#   lr_cons_param.ramcod    is null or
#   lr_cons_param.aplnumdig is null or
#   lr_cons_param.itmnumdig is null or
#   lr_cons_param.edsnumref is null then
#   let ret_param_msg = "002-Parametro Nulo para gravar datrservapol "
#end if

 if lr_cons_param.atddat       is null  or
    lr_cons_param.atdhor       is null  or
    lr_cons_param.atdtip       is null  or
    lr_cons_param.atdfnlflg    is null  or
    lr_cons_param.atdprinvlcod is null  then
    let ret_param_msg = "002-Parametro Nulo para gravar datmservico "
 end if
 if lr_cons_param.c24endtip    is null  or
    lr_cons_param.lgdnom       is null  or
    lr_cons_param.lclbrrnom    is null  or
    lr_cons_param.cidnom       is null  or
    lr_cons_param.ufdcod       is null  or
    lr_cons_param.c24lclpdrcod is null  then
    let ret_param_msg = "003-Parametros nulos p/ Local 1-Ocorrencia/2-Destino "
 end if

 return ret_param_msg

end function
