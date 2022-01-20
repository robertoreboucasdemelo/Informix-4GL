#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HS                                              #
# Modulo        : cts10g12                                                   #
# Analista Resp.: Roberto Melo                                               #
# PSI           :                                                            #
# OSF           :                                                            #
#                 Função para gravação de ligacao de F10                     #
#............................................................................#
# Desenvolvimento: Amilton Pinto                                             #
# Liberacao      : 29/04/2010                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define w_cts10g12_f10    record
    data              char (10)                    ,
    hora              char (05)                    ,
    ano2              char (02)                    ,
    ano4              char (04)
 end record

  define mr_retorno record
    erro         smallint,
    msgerro      char(150),
    lignum       like datmligacao.lignum,
    atdsrvnum    like datmservico.atdsrvnum,
    atdsrvano    like datmservico.atdsrvano
 end record

 define mr_n10 record
       lignum           like datmligacao.lignum      ,
       ligdat           like datmligacao.ligdat      ,
       lighorinc        like datmligacao.lighorinc   ,
       lighorfnl        like datmligacao.lighorfnl   ,
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
       corsus	        like datrligcor.corsus       ,
       dddcod	        like datrligtel.dddcod       ,
       ctttel	        like datrligtel.teltxt       ,
       funmat	        like datrligmat.funmat       ,
       empcod 	        like datrligmat.empcod       ,
       usrtip	        like datrligmat.usrtip       ,
       cgccpfnum        like datrligcgccpf.cgccpfnum ,
       cgcord           like datrligcgccpf.cgcord    ,
       cgccpfdig        like datrligcgccpf.cgccpfdig ,
       atdnum           like datmatd6523.atdnum      ,
       qtd_historico    smallint                     ,
       historico        char(32766)
 end record


 define m_prep smallint


#---------------------------------------------------
function cts10g12_prepare()

define l_sql char(800)

let l_sql = " insert into datmservicocmp (atdsrvnum, atdsrvano, c24sintip, ",
               "c24sinhor, sindat, bocflg,",
               "bocnum, bocemi, vicsnh, sinhor) ",
               " values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
   prepare p_cts10g12_001 from l_sql

   let l_sql = " insert into datrservapol (atdsrvnum, atdsrvano, succod, ",
               "                           ramcod, aplnumdig, itmnumdig, ",
               "                           edsnumref) ",
               " values (?, ?, ?, ?, ?, ?, ?) "
   prepare p_cts10g12_002 from l_sql

   let l_sql = " insert into datrsrvcnd (atdsrvnum,atdsrvano,succod,aplnumdig,",
               "itmnumdig,vclcndseq )",
               " values (?, ?, ?, ?, ?,?) "
   prepare p_cts10g12_003 from l_sql
   let l_sql = " insert into datrsrvvstsin (atdsrvnum, atdsrvano, sinvstnum, ",
               "                            sinvstano, sinvstlauemsstt) ",
               " values (?, ?, ?, ?, 1) "
   prepare pcts10g12004 from l_sql
   let l_sql = " insert into datmavssin ( sinvstnum,sinvstano,atdsrvnum,atdsrvano,sinntzcod,eqprgicod ) ",
               " values (?, ?, ?, ?, ?, ? ) "
   prepare pcts10g12005 from l_sql
   let l_sql = " select cndslcflg   ",
               " from datkassunto   ",
               " where c24astcod = ?"
   prepare pcts10g12006 from l_sql
   declare ccts10g12001 cursor for pcts10g12006
   let m_prep = true

end function


#---------------------------------------------------
function cts10g12_registra_ligacao(lr_param)
#---------------------------------------------------

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
         c24sintip     like datmservicocmp.c24sintip,# 36 datmservicocmp.c24sintip
         c24sinhor     like datmservicocmp.c24sinhor,# 37 datmservicocmp.c24sinhor
         bocflg        like datmservicocmp.bocflg   ,# 38 datmservicocmp.bocflg
         bocnum        like datmservicocmp.bocnum   ,# 39 datmservicocmp.bocnum
         bocemi        like datmservicocmp.bocemi   ,# 40 datmservicocmp.bocemi
         vicsnh        like datmservicocmp.vicsnh   ,# 41 datmservicocmp.vicsnh
         sinhor        like datmservicocmp.sinhor   ,# 42 datmservicocmp.sinhor
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
         sinntzcod     like datmavssin.sinntzcod    ,# 64 datmavssin.sinntzcod
         eqprgicod     like datmavssin.eqprgicod    ,# 65 datmavssin.eqprgicod
         ctcdtnom      char(50)                     ,# 66 ctcdtnom
         ctcgccpfnum   dec(12,0)                    ,# 67 ctcgccpfnum
         ctcgccpfdig   dec(02,0)                    ,# 68 ctcgccpfdig
         sinramcod     like ssamsin.ramcod          ,# 69 ssamsin.ramcod
         sinano        like ssamsin.sinano          ,# 70 ssamsin.sinano
         sinnum        like ssamsin.sinnum          ,# 71 ssamsin.sinnum
         sinitmseq     like ssamitem.sinitmseq      ,# 72 ssamitem.sinitmseq
         sinvstnum     like datrligsinvst.sinvstnum ,
         sinvstano     like datrligsinvst.sinvstano ,
         sinavsnum     like datrligsinavs.sinavsnum ,
         sinavsano     like datrligsinavs.sinavsano ,
         atdnum        like datmatd6523.atdnum      ,# 73 datmatd6523.atdnum
         qtd_historico smallint                     ,# 74 Qtde de linhas do Historico
         historico     char(32766)
    end record
    define l_retorno   record
        err       smallint,
        msg       char(80),
        lignum    like datmligacao.lignum,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
    end record
    initialize l_retorno.* to null
    initialize mr_n10.*    to null
    call cts10g12_alimenta_variaveis(lr_param.*)
    case lr_param.c24astcod
        when "F10"
             initialize w_cts10g12_f10.*    to null
             call cts10g12_registra_F10(lr_param.*)
                  returning l_retorno.*
        when "N10"
             call cts10g12_registra_n10()
                  returning l_retorno.*
        when "N11"
             call cts10g12_registra_n10()
                  returning l_retorno.*
        otherwise
             let l_retorno.msg = "Paramentro Assunto invalido"
             let l_retorno.err = 3
    end case
    return l_retorno.*

end function

#----------------------------------
function cts10g12_registra_F10(lr_param)
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
      c24sintip     like datmservicocmp.c24sintip,# 36 datmservicocmp.c24sintip
      c24sinhor     like datmservicocmp.c24sinhor,# 37 datmservicocmp.c24sinhor
      bocflg        like datmservicocmp.bocflg   ,# 38 datmservicocmp.bocflg
      bocnum        like datmservicocmp.bocnum   ,# 39 datmservicocmp.bocnum
      bocemi        like datmservicocmp.bocemi   ,# 40 datmservicocmp.bocemi
      vicsnh        like datmservicocmp.vicsnh   ,# 41 datmservicocmp.vicsnh
      sinhor        like datmservicocmp.sinhor   ,# 42 datmservicocmp.sinhor
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
      sinntzcod     like datmavssin.sinntzcod    ,# 64 datmavssin.sinntzcod
      eqprgicod     like datmavssin.eqprgicod    ,# 65 datmavssin.eqprgicod
      ctcdtnom      char(50)                     ,# 66 ctcdtnom
      ctcgccpfnum   dec(12,0)                    ,# 67 ctcgccpfnum
      ctcgccpfdig   dec(02,0)                    ,# 68 ctcgccpfdig
      sinramcod     like ssamsin.ramcod          ,# 69 ssamsin.ramcod
      sinano        like ssamsin.sinano          ,# 70 ssamsin.sinano
      sinnum        like ssamsin.sinnum          ,# 71 ssamsin.sinnum
      sinitmseq     like ssamitem.sinitmseq      ,# 72 ssamitem.sinitmseq
      sinvstnum     like datrligsinvst.sinvstnum ,
      sinvstano     like datrligsinvst.sinvstano ,
      sinavsnum     like datrligsinavs.sinavsnum ,
      sinavsano     like datrligsinavs.sinavsano ,
      atdnum        like datmatd6523.atdnum      ,# 73 datmatd6523.atdnum
      qtd_historico smallint                     ,# 74 Qtde de linhas do Historico
      historico     char(32766)
  end record

  define lr_cts10g12 record
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     codigosql    integer,
     tabname      like systables.tabname,
     prompt_key   char(01),
     cndslcflg    like datkassunto.cndslcflg,
     cdtseq       like aeikcdt.cdtseq
  end record
  define arg_F10    record
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
        cornom           like datmvstsin.cornom       ,
        corsus           like datmvstsin.corsus       ,
        vcldes           like datmvstsin.vcldes       ,
        vclanomdl        like datmvstsin.vclanomdl    ,
        vcllicnum        like datmvstsin.vcllicnum    ,
        sindat           like datmvstsin.sindat       ,
        sinavs           like datmvstsin.sinavs       ,
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
        c24sintip        like datmservicocmp.c24sintip,
        c24sinhor        like datmservicocmp.c24sinhor,
        bocflg           like datmservicocmp.bocflg   ,
        bocnum           like datmservicocmp.bocnum   ,
        bocemi           like datmservicocmp.bocemi   ,
        vicsnh           like datmservicocmp.vicsnh   ,
        sinhor           like datmservicocmp.sinhor   ,
        atdsrvseq        like datmsrvacp.atdsrvseq    ,
        atdetpcod        like datmsrvacp.atdetpcod    ,
        atdetpdat        like datmsrvacp.atdetpdat    ,
        atdetphor        like datmsrvacp.atdetphor    ,
        empcod           like datmsrvacp.empcod       ,
        funmat           like datmsrvacp.funmat       ,
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
 define n_posicao_inc smallint
 define n_posicao_fin smallint
 define n_conta       smallint
 define l_historico   char(70)
 define l_data_banco     date,
        l_hora2          datetime hour to minute
 initialize mr_retorno.* to null
 initialize lr_cts10g12.* to null
 initialize arg_f10.* to null
 let l_data_banco = null
 let l_hora2      = null
 if m_prep = false or
    m_prep = "" then
    call cts10g12_prepare()
 end if
 #------------------------------------------------------------------------------
 # Alimenta variaveis
 #------------------------------------------------------------------------------
 let arg_f10.ligdat        = lr_param.ligdat
 let arg_f10.lighorinc     = lr_param.lighorinc
 let arg_f10.c24soltipcod  = lr_param.c24soltipcod
 let arg_f10.c24solnom     = lr_param.c24solnom
 let arg_f10.c24astcod     = lr_param.c24astcod
 let arg_f10.c24funmat     = lr_param.c24funmat
 let arg_f10.ligcvntip     = lr_param.ligcvntip
 let arg_f10.c24paxnum     = lr_param.c24paxnum
 let arg_f10.atdsrvnum     = null
 let arg_f10.atdsrvano     = null
 let arg_f10.sinavsnum     = lr_param.sinavsnum
 let arg_f10.sinavsano     = lr_param.sinavsano
 let arg_f10.sinvstnum     = lr_param.sinvstnum
 let arg_f10.sinvstano     = lr_param.sinvstano
 let arg_f10.succod        = lr_param.succod
 let arg_f10.ramcod        = lr_param.ramcod
 let arg_f10.aplnumdig     = lr_param.aplnumdig
 let arg_f10.itmnumdig     = lr_param.itmnumdig
 let arg_f10.edsnumref     = lr_param.edsnumref
 let arg_f10.prporg        = lr_param.prporg
 let arg_f10.prpnumdig     = lr_param.prpnumdig
 let arg_f10.caddat        = ""
 let arg_f10.cadhor        = ""
 let arg_f10.cademp        = ""
 let arg_f10.cadmat        = ""
 let arg_f10.vclcorcod     = lr_param.vclcorcod
 let arg_f10.atdlibflg     = ""
 let arg_f10.atdlibhor     = ""
 let arg_f10.atdlibdat     = ""
 let arg_f10.atdlclflg     = lr_param.atdlclflg
 let arg_f10.atdhorpvt     = ""
 let arg_f10.atddatprg     = ""
 let arg_f10.atdhorprg     = ""
 let arg_f10.atdtip        = "5"
 let arg_f10.atdmotnom     = ""
 let arg_f10.atdvclsgl     = ""
 let arg_f10.atdprscod     = ""
 let arg_f10.atdcstvlr     = ""
 let arg_f10.atdfnlflg     = "S"
 let arg_f10.atdfnlhor     = ""
 let arg_f10.atdrsdflg     = lr_param.atdrsdflg
 let arg_f10.atddfttxt     = lr_param.atddfttxt
 let arg_f10.atddoctxt     = lr_param.atddoctxt
 let arg_f10.c24opemat     = lr_param.c24opemat
 let arg_f10.nom           = lr_param.nom
 let arg_f10.cornom        = lr_param.cornom
 let arg_f10.corsus        = lr_param.corsus
 let arg_f10.vcldes        = lr_param.vcldes
 let arg_f10.vclanomdl     = lr_param.vclanomdl
 let arg_f10.vcllicnum     = lr_param.vcllicnum
 let arg_f10.sindat        = lr_param.sindat
 let arg_f10.sinavs        = lr_param.sinavs
 let arg_f10.cnldat        = lr_param.cnldat
 let arg_f10.pgtdat        = ""
 let arg_f10.c24nomctt     = ""
 let arg_f10.atdpvtretflg  = ""
 let arg_f10.atdvcltip     = ""
 let arg_f10.asitipcod     = ""
 let arg_f10.socvclcod     = ""
 let arg_f10.vclcoddig     = lr_param.vclcoddig
 let arg_f10.srvprlflg     = "N"
 let arg_f10.srrcoddig     = ""
 let arg_f10.atdprinvlcod  = 2
 let arg_f10.atdsrvorg     = lr_param.atdsrvorg
 let arg_f10.c24sintip     = lr_param.c24sintip
 let arg_f10.c24sinhor     = lr_param.c24sinhor
 let arg_f10.sindat        = lr_param.sindat
 let arg_f10.bocflg        = lr_param.bocflg
 let arg_f10.bocnum        = lr_param.bocnum
 let arg_f10.bocemi        = lr_param.bocemi
 let arg_f10.vicsnh        = lr_param.vicsnh
 let arg_f10.sinhor        = lr_param.sinhor
 let arg_f10.atdsrvseq     = 0
 let arg_f10.atdetpcod     = 4
 let arg_f10.atdetpdat     = lr_param.ligdat
 let arg_f10.atdetphor     = lr_param.lighorinc
 let arg_f10.empcod        = 1
 let arg_f10.funmat        = lr_param.c24funmat
 let arg_f10.c24endtip     = lr_param.c24endtip
 let arg_f10.lclidttxt     = lr_param.lclidttxt
 let arg_f10.lgdtip        = lr_param.lgdtip
 let arg_f10.lgdnom        = lr_param.lgdnom
 let arg_f10.lgdnum        = lr_param.lgdnum
 let arg_f10.lclbrrnom     = lr_param.lclbrrnom
 let arg_f10.brrnom        = lr_param.brrnom
 let arg_f10.cidnom        = lr_param.cidnom
 let arg_f10.ufdcod        = lr_param.ufdcod
 let arg_f10.lclrefptotxt  = lr_param.lclrefptotxt
 let arg_f10.endzon        = lr_param.endzon
 let arg_f10.lgdcep        = lr_param.lgdcep
 let arg_f10.lgdcepcmp     = lr_param.lgdcepcmp
 let arg_f10.lclltt        = lr_param.lclltt
 let arg_f10.lcllgt        = lr_param.lcllgt
 let arg_f10.lcldddcod     = lr_param.lcldddcod
 let arg_f10.lcltelnum     = lr_param.lcltelnum
 let arg_f10.lclcttnom     = lr_param.lclcttnom
 let arg_f10.c24lclpdrcod  = lr_param.c24lclpdrcod
 let arg_f10.lclofnnumdig  = lr_param.lclofnnumdig
 let arg_f10.emeviacod     = lr_param.emeviacod
 let arg_f10.sinntzcod     = lr_param.sinntzcod
 let arg_f10.eqprgicod     = lr_param.eqprgicod
 let arg_f10.ctcdtnom      = lr_param.ctcdtnom
 let arg_f10.ctcgccpfnum   = lr_param.ctcgccpfnum
 let arg_f10.ctcgccpfdig   = lr_param.ctcgccpfdig
 let arg_f10.qtd_historico = lr_param.qtd_historico
 let arg_f10.historico     = lr_param.historico
 let arg_f10.sinramcod     = lr_param.sinramcod clipped
 let arg_f10.sinano        = lr_param.sinano    clipped
 let arg_f10.sinnum        = lr_param.sinnum    clipped
 let arg_f10.sinitmseq     = lr_param.sinitmseq clipped
  #------------------------------------------------------------------------------
  # Busca Data e hora do banco
  #------------------------------------------------------------------------------
   call cts40g03_data_hora_banco(2)
      returning l_data_banco, l_hora2
      let w_cts10g12_f10.data = l_data_banco
      let w_cts10g12_f10.hora = l_hora2
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------

 begin work

 call cts10g03_numeracao( 2, "5" )
      returning mr_retorno.lignum    ,
                mr_retorno.atdsrvnum ,
                mr_retorno.atdsrvano ,
                mr_retorno.erro      ,
                mr_retorno.msgerro
 if mr_retorno.erro <> 0 then
    let mr_retorno.msgerro = "SSATA801 - ", mr_retorno.msgerro
    call errorlog (mr_retorno.msgerro)
    call ctx13g00 (mr_retorno.erro, "DATKGERAL", mr_retorno.msgerro)
    rollback work
    return
 else
    commit work
 end if
   let lr_cts10g12.atdsrvnum  = mr_retorno.atdsrvnum
   let lr_cts10g12.atdsrvano  = mr_retorno.atdsrvano
   let w_cts10g12_f10.ano4    =  '20', mr_retorno.atdsrvano using "&&"
 #------------------------------------------------------------------------------
 # Grava ligacao
 #------------------------------------------------------------------------------
 if arg_f10.lignum is null then
    let arg_f10.lignum       = mr_retorno.lignum
 end if
 begin work
   call cts10g00_ligacao(
                        arg_f10.lignum       ,
                        w_cts10g12_f10.data       ,
                        w_cts10g12_f10.hora    ,
                        arg_f10.c24soltipcod   ,
                        arg_f10.c24solnom   ,
                        arg_f10.c24astcod    ,
                        arg_f10.funmat    ,
                        arg_f10.ligcvntip    ,
                        arg_f10.c24paxnum    ,
                        lr_cts10g12.atdsrvnum    ,
                        lr_cts10g12.atdsrvano    ,
                        arg_f10.sinvstnum    ,
                        arg_f10.sinvstano    ,
                        arg_f10.sinavsnum    ,
                        arg_f10.sinavsano    ,
                        arg_f10.succod       ,
                        arg_f10.ramcod       ,
                        arg_f10.aplnumdig    ,
                        arg_f10.itmnumdig    ,
                        arg_f10.edsnumref    ,
                        arg_f10.prporg       ,
                        arg_f10.prpnumdig    ,
                        arg_f10.fcapacorg    ,
                        arg_f10.fcapacnum    ,
                        arg_f10.sinramcod    ,
                        arg_f10.sinano       ,
                        arg_f10.sinnum       ,
                        arg_f10.sinitmseq    ,
                        arg_f10.caddat       ,
                        arg_f10.cadhor       ,
                        arg_f10.cademp       ,
                        arg_f10.cadmat )
        returning lr_cts10g12.tabname,
                  lr_cts10g12.codigosql

   if  lr_cts10g12.codigosql  <>  0  then
       let mr_retorno.erro = lr_cts10g12.codigosql
       let mr_retorno.msgerro =" Erro (", lr_cts10g12.codigosql, ") na gravacao da",
                   " tabela ", lr_cts10g12.tabname clipped, ". AVISE A INFORMATICA!"
       error mr_retorno.msgerro
       call errorlog(mr_retorno.msgerro)
       rollback work
       prompt "" for char lr_cts10g12.prompt_key
   end if
 #------------------------------------------------------------------------------
 # Grava Serviço
 #------------------------------------------------------------------------------
      call cts10g02_grava_servico( lr_cts10g12.atdsrvnum       ,
                                   lr_cts10g12.atdsrvano       ,
                                   arg_f10.c24soltipcod,     # atdsoltip
                                   arg_f10.c24solnom   ,     # c24solnom
                                   arg_f10.vclcorcod   ,
                                   arg_f10.funmat      ,
                                   ""                  ,     # atdlibflg
                                   ""                  ,     # atdlibhor
                                   ""                  ,     # atdlibdat
                                   w_cts10g12_f10.data ,
                                   w_cts10g12_f10.hora ,
                                   arg_f10.atdlclflg,
                                   ""                  ,     # atdhorpvt
                                   ""                  ,     # atddatprg
                                   ""                  ,     # atdhorprg
                                   "5"                 ,     # ATDTIP
                                   ""                  ,     # atdmotnom
                                   ""                  ,     # atdvclsgl
                                   ""                  ,     # atdprscod
                                   ""                  ,     # atdcstvlr
                                   "S"                 ,     # atdfnlflg
                                   ""                  ,     # atdfnlhor
                                   arg_f10.atdrsdflg  ,
                                   arg_f10.atddfttxt  ,
                                   arg_f10.atddoctxt  ,
                                   arg_f10.funmat       ,
                                   arg_f10.nom        ,
                                   arg_f10.vcldes     ,
                                   arg_f10.vclanomdl  ,
                                   arg_f10.vcllicnum  ,
                                   arg_f10.corsus     ,
                                   arg_f10.cornom     ,
                                   w_cts10g12_f10.data       ,     # cnldat
                                   ""                  ,     # pgtdat
                                   ""                  ,     # c24nomctt
                                   ""                  ,     # atdpvtretflg
                                   ""                  ,     # atdvcltip
                                   ""                  ,     # asitipcod
                                   ""                  ,     # socvclcod
                                   arg_f10.vclcoddig,
                                   "N"                 ,     # srvprlflg
                                   ""                  ,     # srrcoddig
                                   2                   ,   # atdprinvlcod 2-normal
                                   arg_f10.atdsrvorg   ) # ATDSRVORG
      returning lr_cts10g12.tabname,
                lr_cts10g12.codigosql

   if  lr_cts10g12.codigosql  <>  0  then
       let mr_retorno.erro = lr_cts10g12.codigosql
       let mr_retorno.msgerro = " Erro (",  lr_cts10g12.codigosql, ") na gravacao da",
             " tabela ", lr_cts10g12.tabname clipped, ". AVISE A INFORMATICA!"
       error mr_retorno.msgerro
       call errorlog(mr_retorno.msgerro)
       rollback work
       prompt "" for char lr_cts10g12.prompt_key
   end if


 #------------------------------------------------------------------------------
 # Grava complemento do serviço
 #------------------------------------------------------------------------------
   whenever error continue
   execute p_cts10g12_001 using lr_cts10g12.atdsrvnum ,
                              lr_cts10g12.atdsrvano ,
                              arg_f10.c24sintip,
                              arg_f10.c24sinhor,
                              arg_f10.sindat   ,
                              arg_f10.bocflg   ,
                              arg_f10.bocnum   ,
                              arg_f10.bocemi   ,
                              arg_f10.vicsnh   ,
                              arg_f10.sinhor
   whenever error stop
   if  sqlca.sqlcode  <>  0  then
       let mr_retorno.erro = lr_cts10g12.codigosql
       let mr_retorno.msgerro = " Erro (", sqlca.sqlcode, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       error mr_retorno.msgerro
       call errorlog(mr_retorno.msgerro)
       rollback work
       prompt "" for char lr_cts10g12.prompt_key
   end if

 #------------------------------------------------------------------------------
 # Grava estapas de acompanhamento
 #------------------------------------------------------------------------------
    call cts10g04_insere_etapa( lr_cts10g12.atdsrvnum,
                                lr_cts10g12.atdsrvano,
                                4 ,
                                "",
                                "",
                                "",
                                "")
    returning lr_cts10g12.codigosql
    if (lr_cts10g12.codigosql <> 0) then
      let mr_retorno.erro = lr_cts10g12.codigosql
      let mr_retorno.msgerro = " Erro (", lr_cts10g12.codigosql, ") na gravacao da",
            " etapa de acompanhamento. AVISE A INFORMATICA!"
      error mr_retorno.msgerro
      call errorlog(mr_retorno.msgerro)
      rollback work
      return mr_retorno.*
   end if
 #---------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #---------------------------------------------------------------------------
    let arg_f10.operacao = "I"
    call cts06g07_local( arg_f10.operacao,
                         lr_cts10g12.atdsrvnum    ,
                         lr_cts10g12.atdsrvano    ,
                         arg_f10.c24endtip    ,
                         arg_f10.lclidttxt    ,
                         arg_f10.lgdtip       ,
                         arg_f10.lgdnom       ,
                         arg_f10.lgdnum       ,
                         arg_f10.lclbrrnom    ,
                         arg_f10.brrnom       ,
                         arg_f10.cidnom       ,
                         arg_f10.ufdcod       ,
                         arg_f10.lclrefptotxt ,
                         arg_f10.endzon       ,
                         arg_f10.lgdcep       ,
                         arg_f10.lgdcepcmp    ,
                         arg_f10.lclltt       ,
                         arg_f10.lcllgt       ,
                         arg_f10.lcldddcod    ,
                         arg_f10.lcltelnum    ,
                         arg_f10.lclcttnom    ,
                         arg_f10.c24lclpdrcod ,
                         arg_f10.lclofnnumdig ,
                         arg_f10.emeviacod,
                         arg_f10.celteldddcod,
                         arg_f10.celtelnum   ,
                         arg_f10.endcmp )
        returning lr_cts10g12.codigosql
    if lr_cts10g12.codigosql <> 0 then
      let mr_retorno.erro = lr_cts10g12.codigosql
      let mr_retorno.msgerro = " Erro (", lr_cts10g12.codigosql, ") na gravacao da",
            " datmlcl(Ocorrencia), AVISE A INFORMATICA!"
      error mr_retorno.msgerro
      call errorlog(mr_retorno.msgerro)
      rollback work
      return mr_retorno.*

    end if
  #---------------------------------------------------------------------------
  # Grava Relacionamento servico / apolice
  #---------------------------------------------------------------------------
  if (arg_f10.succod is not null and
      arg_f10.ramcod is not null and
      arg_f10.aplnumdig is not null) then
      whenever error continue
      execute p_cts10g12_002 using lr_cts10g12.atdsrvnum,
                                 lr_cts10g12.atdsrvano,
                                 arg_f10.succod,
                                 arg_f10.ramcod,
                                 arg_f10.aplnumdig,
                                 arg_f10.itmnumdig,
                                 arg_f10.edsnumref

      whenever error stop

      if (sqlca.sqlcode <> 0) then
         let mr_retorno.erro = sqlca.sqlcode
         let mr_retorno.msgerro = " Erro (", sqlca.sqlcode, ") na gravacao do",
                      " relacionamento servico x apolice. AVISE A INFORMATICA!"

         error mr_retorno.msgerro
         call errorlog(mr_retorno.msgerro)
         rollback work
         return mr_retorno.*
      end if
      #---------------------------------------------------------------------------
      # Grava gravar condutor conforme flag assunto
      #---------------------------------------------------------------------------
       let lr_cts10g12.cndslcflg = null
       whenever error continue
         open ccts10g12001 using arg_f10.c24astcod
         fetch ccts10g12001 into lr_cts10g12.cndslcflg
       whenever error stop
       if sqlca.sqlcode <> 0 then
          let lr_cts10g12.cndslcflg = null
       end if
       if lr_cts10g12.cndslcflg = "S"  then
          call grava_condutor(arg_f10.succod,
                              arg_f10.aplnumdig,
                              arg_f10.itmnumdig,
                              arg_f10.ctcdtnom,
                              arg_f10.ctcgccpfnum,
                              arg_f10.ctcgccpfdig,
                              "D",
                              "CENTRAL24H" )
               returning      lr_cts10g12.cdtseq
          whenever error continue
          execute p_cts10g12_003 using lr_cts10g12.atdsrvnum,
                                     lr_cts10g12.atdsrvano,
                                     arg_f10.succod,
                                     arg_f10.aplnumdig,
                                     arg_f10.itmnumdig,
                                     lr_cts10g12.cdtseq
          whenever error stop
          if sqlca.sqlcode <> 0 then
             let mr_retorno.erro = sqlca.sqlcode
             let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na gravacao da",
                      " tabela datrsrvcnd. AVISE A INFORMATICA!"
              error mr_retorno.msgerro
              call errorlog(mr_retorno.msgerro)
              rollback work
              return mr_retorno.*
           end if
       end if
  end if
    #--------------------------------------------------------------------------
    # Grava tabela de relacionamento Servico x Vistoria Sinistro
    #---------------------------------------------------------------------------

    whenever error continue
    execute pcts10g12004 using lr_cts10g12.atdsrvnum,
                               lr_cts10g12.atdsrvano,
                               lr_cts10g12.atdsrvnum,
                               w_cts10g12_f10.ano4
   whenever error stop

   if (sqlca.sqlcode <> 0) then
      let mr_retorno.erro = sqlca.sqlcode
      let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na gravacao do",
                   " relacionamento servico x vst sin. AVISE A INFORMATICA!"
       error mr_retorno.msgerro
       call errorlog(mr_retorno.msgerro)
       rollback work
       return mr_retorno.*
    end if
    #---------------------------------------------------------------------------
    # Grava tabela de Aviso de sinistro
    #---------------------------------------------------------------------------
    whenever error continue
    execute pcts10g12005 using lr_cts10g12.atdsrvnum,
                               w_cts10g12_f10.ano4,
                               lr_cts10g12.atdsrvnum,
                               lr_cts10g12.atdsrvano,
                               arg_f10.sinntzcod,
                               arg_f10.eqprgicod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let mr_retorno.erro = sqlca.sqlcode
       let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na gravacao da",
                   " Tabela DATMAVSSIN. AVISE A INFORMATICA!"
       error mr_retorno.msgerro
       call errorlog(mr_retorno.msgerro)
       rollback work
       return mr_retorno.*
    end if
    #---------------------------------------------------------------------------
    # Grava tabela de Historico do Servico
    #-------------------------------------------------------------------------
    let n_posicao_fin = 0
    let n_conta       = 0
    let l_historico   = " "
    let n_posicao_inc = 1
    for n_conta = 1 to arg_f10.qtd_historico
        let n_posicao_fin = n_conta * 70
        let l_historico = arg_f10.historico[n_posicao_inc,n_posicao_fin]
        call ctd07g01_ins_datmservhist(lr_cts10g12.atdsrvnum,
                                       lr_cts10g12.atdsrvano,
                                       g_issk.funmat,
                                       l_historico,
                                       arg_f10.ligdat,
                                       arg_f10.lighorinc,
                                       g_issk.empcod,
                                       g_issk.usrtip)

             returning mr_retorno.erro,
                       mr_retorno.msgerro

        if mr_retorno.erro <> 1  then
           let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na gravacao do",
                       " historico do servico. AVISE A INFORMATICA!"
           error mr_retorno.msgerro
           call errorlog(mr_retorno.msgerro)
           exit for
        end if
        let n_posicao_inc = n_posicao_fin + 1
    end for
  #---------------------------------------------------------------------------
  # Grava tabela de Atendimento
  #---------------------------------------------------------------------------
    if lr_param.atdnum is not null and
       lr_param.atdnum <> 0 then
       call ctd25g00_insere_atendimento(lr_param.atdnum, arg_f10.lignum )
       returning mr_retorno.erro,mr_retorno.msgerro
       if mr_retorno.erro = 1 then
             call errorlog(mr_retorno.msgerro)
       end if
    end if

    commit work

    # War Room 
    # Ponto de acesso apos a gravacao do laudo
    call cts00g07_apos_grvlaudo(lr_cts10g12.atdsrvnum,
                                lr_cts10g12.atdsrvano)

    return mr_retorno.*
end function

function cts10g12_alimenta_variaveis(lr_param)

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
         c24sintip     like datmservicocmp.c24sintip,# 36 datmservicocmp.c24sintip
         c24sinhor     like datmservicocmp.c24sinhor,# 37 datmservicocmp.c24sinhor
         bocflg        like datmservicocmp.bocflg   ,# 38 datmservicocmp.bocflg
         bocnum        like datmservicocmp.bocnum   ,# 39 datmservicocmp.bocnum
         bocemi        like datmservicocmp.bocemi   ,# 40 datmservicocmp.bocemi
         vicsnh        like datmservicocmp.vicsnh   ,# 41 datmservicocmp.vicsnh
         sinhor        like datmservicocmp.sinhor   ,# 42 datmservicocmp.sinhor
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
         sinntzcod     like datmavssin.sinntzcod    ,# 64 datmavssin.sinntzcod
         eqprgicod     like datmavssin.eqprgicod    ,# 65 datmavssin.eqprgicod
         ctcdtnom      char(50)                     ,# 66 ctcdtnom
         ctcgccpfnum   dec(12,0)                    ,# 67 ctcgccpfnum
         ctcgccpfdig   dec(02,0)                    ,# 68 ctcgccpfdig
         sinramcod     like ssamsin.ramcod          ,# 69 ssamsin.ramcod
         sinano        like ssamsin.sinano          ,# 70 ssamsin.sinano
         sinnum        like ssamsin.sinnum          ,# 71 ssamsin.sinnum
         sinitmseq     like ssamitem.sinitmseq      ,# 72 ssamitem.sinitmseq
         sinvstnum     like datrligsinvst.sinvstnum ,
         sinvstano     like datrligsinvst.sinvstano ,
         sinavsnum     like datrligsinavs.sinavsnum ,
         sinavsano     like datrligsinavs.sinavsano ,
         atdnum        like datmatd6523.atdnum      ,# 73 datmatd6523.atdnum
         qtd_historico smallint                     ,# 74 Qtde de linhas do Historico
         historico     char(32766)
    end record



    initialize mr_n10.* to null
    let mr_n10.ligdat        = lr_param.ligdat
    let mr_n10.lighorinc     = lr_param.lighorinc
    let mr_n10.lighorfnl     = null
    let mr_n10.c24soltipcod  = lr_param.c24soltipcod
    let mr_n10.c24solnom     = lr_param.c24solnom
    let mr_n10.c24astcod     = lr_param.c24astcod
    let mr_n10.c24funmat     = lr_param.c24funmat
    let mr_n10.ligcvntip     = lr_param.ligcvntip
    let mr_n10.c24paxnum     = lr_param.c24paxnum
    let mr_n10.succod        = lr_param.succod
    let mr_n10.ramcod        = lr_param.ramcod
    let mr_n10.aplnumdig     = lr_param.aplnumdig
    let mr_n10.itmnumdig     = lr_param.itmnumdig
    let mr_n10.edsnumref     = lr_param.edsnumref
    let mr_n10.prporg        = lr_param.prporg
    let mr_n10.prpnumdig     = lr_param.prpnumdig
    let mr_n10.corsus        = lr_param.corsus
    let mr_n10.sinramcod     = lr_param.sinramcod
    let mr_n10.sinano        = lr_param.sinano
    let mr_n10.sinnum        = lr_param.sinnum
    let mr_n10.sinitmseq     = lr_param.sinitmseq
    let mr_n10.sinvstnum     = lr_param.sinvstnum
    let mr_n10.sinvstano     = lr_param.sinvstano
    let mr_n10.sinavsnum     = lr_param.sinavsnum
    let mr_n10.sinavsano     = lr_param.sinavsano
    let mr_n10.atdnum        = lr_param.atdnum
    let mr_n10.qtd_historico = lr_param.qtd_historico
    let mr_n10.historico     = lr_param.historico
    {
    let mr_n10.c24soltipcod  = lr_param.c24soltipcod
    let mr_n10.c24solnom     = lr_param.c24solnom
    let mr_n10.c24astcod     = lr_param.c24astcod
    let mr_n10.c24funmat     = lr_param.c24funmat
    let mr_n10.ligcvntip     = lr_param.ligcvntip
    let mr_n10.c24paxnum     = lr_param.c24paxnum
    let mr_n10.atdsrvnum     = lr_param.atdsrvnum
    let mr_n10.atdsrvano     = lr_param.atdsrvano
    let mr_n10.sinvstnum     = lr_param.sinvstnum
    let mr_n10.sinvstano     = lr_param.sinvstano
    let mr_n10.sinavsnum     = lr_param.sinavsnum
    let mr_n10.sinavsano     = lr_param.sinavsano
    let mr_n10.succod        = lr_param.succod
    let mr_n10.ramcod        = lr_param.ramcod
    let mr_n10.aplnumdig     = lr_param.aplnumdig
    let mr_n10.itmnumdig     = lr_param.itmnumdig
    let mr_n10.edsnumref     = lr_param.edsnumref
    let mr_n10.prporg        = lr_param.prporg
    let mr_n10.prpnumdig     = lr_param.prpnumdig
    let mr_n10.fcapacorg     = lr_param.fcapacorg
    let mr_n10.fcapacnum     = lr_param.fcapacnum
    let mr_n10.sinramcod     = lr_param.sinramcod
    let mr_n10.sinano        = lr_param.sinano
    let mr_n10.sinnum        = lr_param.sinnum
    let mr_n10.sinitmseq     = lr_param.sinitmseq
    let mr_n10.caddat        = lr_param.caddat
    let mr_n10.cadhor        = lr_param.cadhor
    let mr_n10.cademp        = lr_param.cademp
    let mr_n10.cadmat        = lr_param.cadmat
    let mr_n10.corsus	     = lr_param.corsus
    let mr_n10.dddcod	     = lr_param.dddcod
    let mr_n10.ctttel	     = lr_param.ctttel
    let mr_n10.funmat	     = lr_param.funmat
    let mr_n10.empcod 	     = lr_param.empcod
    let mr_n10.usrtip	     = lr_param.usrtip
    let mr_n10.cgccpfnum     = lr_param.cgccpfnum
    let mr_n10.cgcord        = lr_param.cgcord
    let mr_n10.cgccpfdig     = lr_param.cgccpfdig
    let mr_n10.atdnum        = lr_param.atdnum
    let mr_n10.qtd_historico = lr_param.qtd_historico
    let mr_n10.historico     = lr_param.historico     }


end function

function cts10g12_registra_n10()

  define n_posicao_inc smallint
       ,n_posicao_fin smallint
       ,n_conta       smallint
       ,l_historico   char(70)
    initialize mr_retorno.* to null
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
     begin work
     call cts10g03_numeracao( 1, "" )
         returning mr_retorno.lignum    ,
                   mr_retorno.atdsrvnum ,
                   mr_retorno.atdsrvano ,
                   mr_retorno.erro      ,
                   mr_retorno.msgerro

     if mr_retorno.erro <> 0 then
        let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na geracao do",
                    " numero da ligacao. AVISE A INFORMATICA!"
        error mr_retorno.msgerro
        call errorlog(mr_retorno.msgerro)
        rollback work
     else
        commit work
     end if

     if mr_n10.lignum is null then
        let mr_n10.lignum       = mr_retorno.lignum
     end if

 #------------------------------------------------------------------------------
 # Inicializa variaveis de vistoria e aviso
 #------------------------------------------------------------------------------

    if mr_n10.sinramcod     is not null and
       mr_n10.sinano        is not null and
       mr_n10.sinnum        is not null and
       mr_n10.sinitmseq     is not null then
         let mr_n10.sinavsnum = null
         let mr_n10.sinavsano = null
         let mr_n10.atdsrvnum = null
         let mr_n10.atdsrvano = null
         let mr_n10.sinvstnum = null
         let mr_n10.sinvstano = null
    end if

 #----------------------------------------------------------
 # Grava Ligação
 #----------------------------------------------------------
   begin work
   call cts10g00_ligacao( mr_n10.lignum       ,
                          mr_n10.ligdat       ,
                          mr_n10.lighorinc    ,
                          mr_n10.c24soltipcod ,
                          mr_n10.c24solnom    ,
                          mr_n10.c24astcod    ,
                          mr_n10.c24funmat    ,
                          mr_n10.ligcvntip    ,
                          mr_n10.c24paxnum    ,
                          mr_n10.atdsrvnum    ,
                          mr_n10.atdsrvano    ,
                          mr_n10.sinvstnum    ,
                          mr_n10.sinvstano    ,
                          mr_n10.sinavsnum    ,
                          mr_n10.sinavsano    ,
                          mr_n10.succod       ,
                          mr_n10.ramcod       ,
                          mr_n10.aplnumdig    ,
                          mr_n10.itmnumdig    ,
                          mr_n10.edsnumref    ,
                          mr_n10.prporg       ,
                          mr_n10.prpnumdig    ,
                          mr_n10.fcapacorg    ,
                          mr_n10.fcapacnum    ,
                          mr_n10.sinramcod    ,
                          mr_n10.sinano       ,
                          mr_n10.sinnum       ,
                          mr_n10.sinitmseq    ,
                          mr_n10.caddat       ,
                          mr_n10.cadhor       ,
                          mr_n10.cademp       ,
                          mr_n10.cadmat
                          )
   returning mr_retorno.msgerro,
             mr_retorno.erro


   if mr_retorno.erro <> 0 then
      let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na gravacao da",
                      "da ligacao. AVISE A INFORMATICA!"
          error mr_retorno.msgerro
          call errorlog(mr_retorno.msgerro)
          rollback work
          return mr_retorno.*
   end if
 #---------------------------------------------------------------------------
 # Grava tabela de Atendimento
 #---------------------------------------------------------------------------


   if mr_n10.atdnum is not null and
      mr_n10.atdnum <> 0 then
      call ctd25g00_insere_atendimento(mr_n10.atdnum, mr_n10.lignum)
      returning mr_retorno.erro,mr_retorno.msgerro
      if mr_retorno.erro = 1 then
            call errorlog(mr_retorno.msgerro)
      end if
   end if
 #---------------------------------------------------------------------------
 # Grava tabela de Historico da Ligacao
 #---------------------------------------------------------------------------
      let n_posicao_fin   = 0
      let n_conta         = 0
      let l_historico     = null
      let n_posicao_inc   = 1
      for n_conta = 1 to mr_n10.qtd_historico
          let n_posicao_fin = n_conta * 70
          let l_historico = mr_n10.historico[n_posicao_inc,n_posicao_fin]
          call ctd06g01_ins_datmlighist(mr_n10.lignum         ,
                                        mr_n10.c24funmat      ,
                                        l_historico           ,
                                        mr_n10.ligdat         ,
                                        mr_n10.lighorinc      ,
                                        g_issk.usrtip         ,
                                        g_issk.empcod )
          returning mr_retorno.erro,
                    mr_retorno.msgerro
          if mr_retorno.erro <> 1  then
             let mr_retorno.msgerro = " Erro (", mr_retorno.erro, ") na gravacao do",
                         " historico do ligacao. AVISE A INFORMATICA!"
             error mr_retorno.msgerro
             call errorlog(mr_retorno.msgerro)
             exit for
          end if
          let n_posicao_inc = n_posicao_fin + 1
      end for
  commit work
  return mr_retorno.*
end function


