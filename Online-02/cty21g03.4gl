# HELDER OLIVEIRA
# COMPARACAO - TELA DE: PARA :
#
#
#------------------------------------------------------------------------------

database porto

define m_chave_diff   smallint
define m_index        smallint
define m_aux          smallint
define m_key          smallint
define m_key2          smallint
define m_create16       smallint #desconto
define m_create22       smallint #desconto
define m_create17       smallint #clausula
define m_create54       smallint #clausula

define l_ppwprpnum   like gppmnetprppcl.ppwprpnum
define l_corsus      like gppmnetprppcl.corsus
define l_ppwtrxqtd   like gppmnetprppcl.ppwtrxqtd

 define w_cod decimal(5,0)
 define w_des char(50)
 define l_primeiro_registro_59 smallint
 define lr_gtakram   record
                          empcod        like gtakram.empcod
                         ,ramcod        like gtakram.ramcod
                         ,ramnom        like gtakram.ramnom
                         ,ramsgl        like gtakram.ramsgl
                         ,ramgrpcod     like gtakram.ramgrpcod
                         ,sinramgrp     like gtakram.sinramgrp
                         ,prdramgrp     like gtakram.prdramgrp
                         ,pdtcomtipcod  like gtakram.pdtcomtipcod
                         ,viginc        like gtakram.viginc
                         ,vigfnl        like gtakram.vigfnl
                         ,ramamgnom     like gtakram.ramamgnom
                         ,caddat        like gtakram.caddat
                         ,ramtipcod     like gtakram.ramtipcod
                         ,ramdcrflg     like gtakram.ramdcrflg
                         ,ramrsvprvper  like gtakram.ramrsvprvper
                         ,agdchqflg     like gtakram.agdchqflg
                         ,canfltpgt     like gtakram.canfltpgt
                         ,rscgratip     like gtakram.rscgratip
                         ,csgobrper     like gtakram.csgobrper
                         ,prdcrtcod     like gtakram.prdcrtcod
                      end record


define m_flag         char(2)   #F5 ou F6 (tipo de comparacao)

define m_ppwprpnum1   like gppmnetprppcl.ppwprpnum
define m_ppwprpnum2   like gppmnetprppcl.ppwprpnum

define m_corsus1      like gppmnetprppcl.corsus
define m_corsus2      like gppmnetprppcl.corsus

define m_ppwtrxqtd1   like gppmnetprppcl.ppwtrxqtd
define m_ppwtrxqtd2   like gppmnetprppcl.ppwtrxqtd

define m_flag_proposta smallint

define m_count00 , m_count01 , m_count04 , m_count05
     , m_count06 , m_count07 , m_count08 , m_count09
     , m_count10 , m_count11 , m_count12 , m_count13
     , m_count14 , m_count15 , m_count16 , m_count17
     , m_count18 , m_count19 , m_count20 , m_count21
     , m_count22 , m_count23 , m_count24 , m_count25
     , m_count27 , m_count29 , m_count30 , m_count31
     , m_count32 , m_count34 , m_count35 , m_count36
     , m_count37 , m_count38 , m_count39 , m_count40
     , m_count41 , m_count42 , m_count43 , m_count44
     , m_count45 , m_count46 , m_count47 , m_count48
     , m_count49 , m_count50 , m_count52 , m_count53
     , m_count54 , m_count55 , m_count56 , m_count57
     , m_count58 , m_count59 , m_count60 , m_count61
     , m_count62 , m_count63 , m_count64 , m_count66
     , m_count67
     smallint

define ccty21g03_tela   array[32767] of  char(80)
define linha         char(250)
define w_linha25     char(250)
define i             smallint
define l_sql         char(200)
define v_codreg      char(2)
define m_prep        char(01)
define m_prep2        char(01)
define m_viginc      date
define m_temkitgas   smallint
define m_vlr_tot_cls dec(15,5)
define m_renavam_char char(50)
define m_vigencia    like apamcapa.viginc

define r_apamcapa    record
       prporgpcp     like apamcapa.prporgpcp
      ,prpnumpcp     like apamcapa.prpnumpcp
      ,rnvsuccod     like apamcapa.rnvsuccod
      ,rnvaplnum     like apamcapa.rnvaplnum
      ,pgtfrm        like apamcapa.pgtfrm
end record
define l_retcartao   record
       rgtpntsld     like fscmemscrtinf.rgtpntsld
      ,rgtvlr        like fscmemscrtinf.rgtvlr
      ,mens          char(40)
end record
define m_rgtvlr         decimal(14,0)
define m_rgtvlr_s       char(08)
define m_pont_resgate   integer
define m_pont_resgate_s char(08)

define w_profissao like gsakcmcinfren.segprfcod
define w_renda     char(18)
define w_codreg    char(2)
define w_pestip    char(1)


define w_renfxacod   like gsakcmcinfren.renfxacod
define w_faixa       char(45)
define w_vigencia    date

define w_pepres      char(1)
define w_pep         smallint
define w_pepnom      char(50)


define w_prxrelpescgccpfnum   like gsakrsdestpepseg.prxrelpescgccpfnum
define w_prxrelpescgccpfdig   like gsakrsdestpepseg.prxrelpescgccpfdig
define w_pepreltip         like gsakrsdestpepseg.pepreltip
define w_pepreldes         char(50)

define w_prporgidv            like apbmpoe.prporgidv
define w_prpnumidv            like apbmpoe.prpnumidv
define m_poe                  smallint

define m_linha70  like gppmnetprpaut.ppwprplnhtxt
define m_linha71  like gppmnetprpaut.ppwprplnhtxt

#------------------------------------------------------------------------------
function ccty21g03_prepare()
#------------------------------------------------------------------------------

define l_sql     char(1000)

  let l_sql = '  select cpodes               '
            , '    from datkdominio          '
            , '   where cponom = "comp_prop" '
            , '     and cpocod = ?           '
  prepare pcty21g03vrf001 from l_sql
  declare ccty21g03vrf001 cursor with hold for pcty21g03vrf001



   #SUSEP
   let l_sql = " select b.cornom                  "
              ,"   from gcaksusep a, gcakcorr b   "
        ,"  where a.corsus = ?              "
        ,"    and b.corsuspcp = a.corsuspcp "
   prepare pccty21g03002 from l_sql
   declare cccty21g03002 cursor with hold for pccty21g03002

   #Tipo de Endosso
   let l_sql = " select edstipdes  "
        ,"   from agdktip    "
        ,"  where edstip = ? "
   prepare pccty21g03003 from l_sql
   declare cccty21g03003 cursor with hold for pccty21g03003

   #Forma Pagto
   let l_sql = " select pgtfrmdes  "
        ,"   from gfbkfpag   "
        ,"  where pgtfrm = ? "
   prepare pccty21g03004 from l_sql
   declare cccty21g03004 cursor with hold for pccty21g03004

   #Seguradora
   let l_sql = " select sgdnom        "
        ,"   from gcckcong      "
        ,"  where sgdirbcod = ? "
   prepare pccty21g03005 from l_sql
   declare cccty21g03005 cursor with hold for pccty21g03005

   #Tipo de Pessoa
   let l_sql = " select pestipdes  "
        ,"   from gabkpestip "
        ,"  where pestip = ? "
   prepare pccty21g03006 from l_sql
   declare cccty21g03006 cursor with hold for pccty21g03006

   #Classe de Localizacao
   let l_sql = " select clalcldes     "
        ,"   from agekregiao    "
        ,"  where clalclcod = ? "
        ,"    and tabnum    = ? "
   prepare pccty21g03009 from l_sql
   declare cccty21g03009 cursor with hold for pccty21g03009

   #Codigo do veiculo
   let l_sql = " select a.vclmrcnom, b.vcltipnom, c.vclmdlnom "
        ,"   from agbkmarca a, agbktip b, agbkveic c    "
        ,"  where c.vclcoddig = ?                       "
        ,"    and b.vclmrccod = c.vclmrccod             "
        ,"    and b.vcltipcod = c.vcltipcod             "
        ,"    and a.vclmrccod = b.vclmrccod             "
   prepare pccty21g03010 from l_sql
   declare cccty21g03010 cursor with hold for pccty21g03010

   #Categoria tarifaria
   let l_sql = " select ctgtrfdes     "
        ,"   from agekcateg     "
        ,"  where tabnum    = ? "
        ,"    and ramcod    = ? "
        ,"    and ctgtrfcod = ? "
   prepare pccty21g03011 from l_sql
   declare cccty21g03011 cursor with hold for pccty21g03011

   #Tipo de Logradouro
   let l_sql = " select endlgdtipdes   "
        ,"   from gsaktipolograd "
        ,"  where endlgdtip = ?  "
   prepare pccty21g03012 from l_sql
   declare cccty21g03012 cursor with hold for pccty21g03012

   #Codigo do Desconto
   let l_sql = " select cndeslnom     "
        ,"   from aggkcndesl    "
        ,"  where tabnum = ?    "
        ,"    and cndeslcod = ? "
   prepare pccty21g03013 from l_sql
   declare cccty21g03013 cursor with hold for pccty21g03013

   #Codigo da Questao
   let l_sql = " select a.qstdes, a.qstrsptip             "
        ,"   from apqkquest a                             "
        ,"  where a.qstcod = ?                            "
        ,"    and a.viginc = (select max(b.viginc)        "
        ,"                      from apqkquest b          "
        ,"                     where a.qstcod = b.qstcod) "
   prepare pccty21g03014 from l_sql
   declare cccty21g03014 cursor with hold for pccty21g03014

   #Codigo da Resposta
   let l_sql = " select qstrspdsc    "
        ,"   from apqkdominio  "
        ,"  where qstcod  = ? "
        ,"    and rspcod  = ? "
              ,"    and viginc <= ? "
              ,"    and vigfnl >= ? "
   prepare pccty21g03015 from l_sql
   declare cccty21g03015 cursor with hold for pccty21g03015

   #Tipo de Seguro / Tipo de Calculo / Ref. do Acessorio
   let l_sql = 'select cpodes '
              ,'  from iddkdominio '
              ,' where cponom = ? '
              ,'   and cpocod = ? '
   prepare pccty21g03016 from l_sql
   declare cccty21g03016 cursor with hold for pccty21g03016

   #Tipo de Acessorio
   let l_sql = 'select assnom '
              ,'  from agckaces '
              ,' where asstip    = ? '
              ,'   and asscoddig = ? '
   prepare pccty21g03019 from l_sql
   declare cccty21g03019 cursor with hold for pccty21g03019

   #Codigo da Clausula
   let l_sql = 'select a.clsdes '
              ,'  from aackcls a '
              ,' where a.ramcod = ? '
              ,'   and a.clscod = ? '
              ,'   and a.tabnum = (select max(b.tabnum) '
                                 ,'  from aackcls b '
                                 ,' where b.ramcod = a.ramcod '
                                 ,'   and b.clscod = a.clscod)'
   prepare pccty21g03020 from l_sql
   declare cccty21g03020 cursor with hold for pccty21g03020

   #Sem CNPJ/CPF
   let l_sql = 'select cgcsementdes '
              ,'  from gsakentidsemcgc '
              ,' where cgcsementcod = ? '
   prepare pccty21g03021 from l_sql
   declare cccty21g03021 cursor with hold for pccty21g03021

   #Codigo da sub-Resposta
   let l_sql = " select a.qstrsphtmdes                          "
              ,"   from apqksubrsp a                            "
              ,"  where a.qstcod = ?                            "
              ,"    and a.rspcod = ?                            "
              , "   and a.rspsubcod = ?                         "
              ,"    and a.viginc = (select max(b.viginc)        "
              ,"                      from apqksubrsp b         "
              ,"                     where a.qstcod = b.qstcod  "
              ,"                       and a.rspcod = b.rspcod  "
              ,"                       and a.rspsubcod = b.rspsubcod) "
   prepare pccty21g03022 from l_sql
   declare cccty21g03022 cursor with hold for pccty21g03022

   let l_sql = "select vigfnl from itatvig"
              , " where tabnom = 'VIGENCIA TARIFA'"
              ,"    and tabnum = ? "
              , " order by tabnum"
   prepare pccty21g03040  from l_sql
   declare cccty21g03040  cursor with hold for pccty21g03040

   let l_sql = " select rnvsuccod, rnvaplnum from apamcapa "
          ," where prporgpcp = ? and prpnumpcp = ? "
   prepare pccty21g03renov from l_sql
   declare cccty21g03renov cursor with hold for pccty21g03renov

   let l_sql = " select max(dscvlr) from fsckdscpnt "
                    ," where pntqtd <= ? "
   prepare p_ccty21g03040_1 from l_sql
   declare c_ccty21g03040_1 cursor with hold for p_ccty21g03040_1

   let l_sql = " select cncpoeflg     "
              ," from apbmpoe where   "
              ,"      prporgpcp = ?   "
              ," and  prpnumpcp = ?   "
              ," and  prporgidv = ?   "
              ," and  prpnumidv = ?   "
   prepare p_ccty21g03040_2 from l_sql
   declare c_ccty21g03040_2 cursor with hold for p_ccty21g03040_2

   let l_sql = " select socraznom     "
              ," from goekemp where   "
              ,"      poeempcod = ?   "

   prepare p_ccty21g03040_3 from l_sql
   declare c_ccty21g03040_3 cursor with hold for p_ccty21g03040_3

   #psi261378 inicio
   let l_sql = " select ppwprplnhtxt "
                ," from  gppmnetprpaut "
                ," where corsus = ? "
                ," and ppwprpnum = ? "
                ," and ppwtrxqtd = ? "
                ," and ppwprplnhtxt[13,14] = 70"
   prepare pccty21g03042  from l_sql
   declare cccty21g03042 cursor with hold for pccty21g03042

   let l_sql = " select ppwprplnhtxt "
                ," from  gppmnetprpaut "
                ," where  "
                ," corsus = ? "
                ," and ppwprpnum = ? "
                ," and ppwtrxqtd = ? "
                ," and ppwprplnhtxt[13,14] = 71"
   prepare pccty21g03043  from l_sql
   declare cccty21g03043 cursor with hold for pccty21g03043

----------------------------------------------------

   let l_sql = " select ppwprplnhtxt,ppwprpseq "
                ," from  gppmnetprpaut "
                ," where  "
                ," corsus = ? "
                ," and ppwprpnum = ? "
                ," and ppwtrxqtd = ? "
  prepare pccty21g0301  from l_sql
  declare cccty21g0301 cursor with hold for pccty21g0301

  let l_sql = " select ppwprplnhtxt,ppwprpseq "
             ," from  gppmnetprpaut "
             ," where  "
             ," corsus = ? "
             ," and ppwprpnum = ? "
             ," and ppwtrxqtd = ? "
             ," and ppwprplnhtxt[13,14] = 25"
  prepare pccty21g0301a  from l_sql
  declare cccty21g0301a cursor with hold for pccty21g0301a

  let l_sql = " select rowid "
             ," from  gppmnetprpaut "
             ," where  "
             ," corsus = ? "
             ," and ppwprpnum = ? "
             ," and ppwtrxqtd = ? "
             ," and ppwprplnhtxt[13,14] = 13 "
             ," and ppwprplnhtxt[25,28] = 620 "
             ," and ppwprplnhtxt[29,29] = 3 "
     prepare pccty21g03023  from l_sql
     declare cccty21g03023 cursor with hold for pccty21g03023

-----------------------------------------------------------------------


   let m_prep = "S"

end function


#==============================================================
function cty21g03_prepare_temp(l_campo, l_tabela_1, l_tabela_2)
#==============================================================
define l_campo   char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql     char(5000)

let l_sql =   '    SELECT a.',l_campo,', b.',l_campo,'              '
             ,'    FROM ',l_tabela_1,' a                            '
             ,'    INNER JOIN ',l_tabela_2,' b                      '
             ,'    ON a.seq = b.seq                                 '
             ,'    WHERE a.',l_campo,' <> b.',l_campo,'             '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.',l_campo,', b.',l_campo,'              '
             ,'    FROM ',l_tabela_1,' a                            '
             ,'    LEFT OUTER JOIN ',l_tabela_2,' b                 '
             ,'    ON a.seq = b.seq                                 '
             ,'    WHERE   a.',l_campo,' IS NULL                    '
             ,'    OR   b.',l_campo,' IS NULL                       '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'     SELECT a.',l_campo,', b.',l_campo,'             '
             ,'     FROM ',l_tabela_1,' a                           '
             ,'     RIGHT OUTER JOIN ',l_tabela_2,' b               '
             ,'     ON a.seq = b.seq                                '
             ,'     WHERE   a.',l_campo,' IS NULL                   '
             ,'     OR   b.',l_campo,' IS NULL                      '

     prepare pcty21g03_tmp01_11  from l_sql
     declare ccty21g03tmp  cursor with hold for pcty21g03_tmp01_11


  let m_prep2 = "S"


end function

#====================================================================================
function cty21g03_prepare_desconto_temp(l_campo, l_tabela_1, l_tabela_2, l_parametro)
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(5000)
define l_parametro char(100)

let l_sql =   '    SELECT a.',l_campo,', b.',l_campo,'              '
             ,'    FROM ',l_tabela_1,' a                            '
             ,'    INNER JOIN ',l_tabela_2,' b                      '
             ,'    ON a.',l_parametro,' = b.',l_parametro,'         '
             ,'    WHERE a.',l_campo,' <> b.',l_campo,'             '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.',l_campo,', b.',l_campo,'              '
             ,'    FROM ',l_tabela_1,' a                            '
             ,'    LEFT OUTER JOIN ',l_tabela_2,' b                 '
             ,'    ON a.',l_parametro,' = b.',l_parametro,'         '
             ,'    WHERE   a.',l_campo,' IS NULL                    '
             ,'    OR   b.',l_campo,' IS NULL                       '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'     SELECT a.',l_campo,', b.',l_campo,'             '
             ,'     FROM ',l_tabela_1,' a                           '
             ,'     RIGHT OUTER JOIN ',l_tabela_2,' b               '
             ,'    ON a.',l_parametro,' = b.',l_parametro,'         '
             ,'     WHERE   a.',l_campo,' IS NULL                   '
             ,'     OR   b.',l_campo,' IS NULL                      '

     prepare pcty21g03_tmp01_12  from l_sql
     declare ccty21g03tmp2  cursor with hold for pcty21g03_tmp01_12


  let m_prep2 = "S"


end function

#====================================================================================
function cty21g03_prepare_04_corretor()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(5000)
define l_parametro char(100)

let l_sql =   '    SELECT a.susep, a.participCorretor, a.flagcorr,  '
             ,'           b.susep, b.participCorretor, b.flagcorr   '
             ,'    FROM tmp04_1 a                                   '
             ,'    INNER JOIN tmp04_2 b                             '
             ,'    ON a.susep = b.susep                             '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.susep, a.participCorretor, a.flagcorr,  '
             ,'           b.susep, b.participCorretor, b.flagcorr   '
             ,'    FROM tmp04_1 a                                   '
             ,'    LEFT JOIN tmp04_2 b                             '
             ,'    ON a.susep = b.susep                             '
             ,'    WHERE   a.susep IS NULL                          '
             ,'    OR   b.susep IS NULL                             '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.susep, a.participCorretor, a.flagcorr,  '
             ,'           b.susep, b.participCorretor, b.flagcorr   '
             ,'    FROM tmp04_1 a                                   '
             ,'    RIGHT JOIN tmp04_2 b                             '
             ,'    ON a.susep = b.susep                             '
             ,'    WHERE   a.susep IS NULL                          '
             ,'    OR   b.susep IS NULL                             '
             ,'                                                     '
             ,'                                                     '

     prepare pcty21g03_tmp01_13  from l_sql
     declare ccty21g0304corr  cursor with hold for pcty21g03_tmp01_13

  let m_prep2 = "S"


end function

#====================================================================================
function cty21g03_prepare_19_QuestPerfil()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(10000)
define l_parametro char(100)


let l_sql =   '    SELECT a.CodigoQuestao, a.CodigoResposta, a.SubResposta,   '
             ,'           b.CodigoQuestao, b.CodigoResposta, b.SubResposta    '
             ,'    FROM tmp19_1 a                                                             '
             ,'    INNER JOIN tmp19_2 b                                                       '
             ,'    ON a.CodigoQuestao = b.CodigoQuestao                                       '
             ,'                                                                               '
             ,'    UNION ALL                                                                  '
             ,'                                                                               '
             ,'    SELECT a.CodigoQuestao, a.CodigoResposta, a.SubResposta,    '
             ,'           b.CodigoQuestao, b.CodigoResposta, b.SubResposta    '
             ,'    FROM tmp19_1 a                                                             '
             ,'    LEFT JOIN tmp19_2 b                                                       '
             ,'    ON a.CodigoQuestao = b.CodigoQuestao                                       '
             ,'    WHERE   a.CodigoQuestao IS NULL                                            '
             ,'    OR   b.CodigoQuestao IS NULL                                               '
             ,'                                                                               '
             ,'    UNION ALL                                                                  '
             ,'                                                                               '
             ,'    SELECT a.CodigoQuestao, a.CodigoResposta, a.SubResposta,    '
             ,'           b.CodigoQuestao, b.CodigoResposta, b.SubResposta    '
             ,'    FROM tmp19_1 a                                                             '
             ,'    RIGHT JOIN tmp19_2 b                                                       '
             ,'    ON a.CodigoQuestao = b.CodigoQuestao                                       '
             ,'    WHERE   a.CodigoQuestao IS NULL                                            '
             ,'    OR   b.CodigoQuestao IS NULL                                               '
             ,'                                                                               '

     prepare pcty21g03_tmp01_14  from l_sql
     declare ccty21g0319perf  cursor with hold for pcty21g03_tmp01_14

  let m_prep2 = "S"
end function

#====================================================================================
function cty21g03_19_questionarioerfil1()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(10000)
define l_parametro char(100)


let l_sql =   '  SELECT DISTINCT CodigoQuestao                          '
             ,'  from tmp19_1                                           '
             ,'  where CodigoQuestao[1,3] in ("124","127","151","167")  '
             ,'  union                                                  '
             ,'  select distinct CodigoQuestao                          '
             ,'  from tmp19_2                                           '
             ,'  where CodigoQuestao[1,3] in ("124","127","151","167")  '

     prepare pcty21g03_tmp01_21  from l_sql
     declare ccty21g0319_001  cursor with hold for pcty21g03_tmp01_21

  let m_prep2 = "S"


end function

#====================================================================================
function cty21g03_19_questionarioerfil2()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(10000)
define l_parametro char(100)


let l_sql =   '  select CodigoResposta,            '
             ,'         SubResposta                '
             ,'    from tmp19_1                    '
             ,'   where CodigoQuestao = ?          '


     prepare pcty21g03_tmp01_22  from l_sql
     declare ccty21g0319_002  cursor with hold for pcty21g03_tmp01_22

  let m_prep2 = "S"


end function


#====================================================================================
function cty21g03_19_questionarioerfil3()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(10000)
define l_parametro char(100)


let l_sql =   '  select CodigoResposta,            '
             ,'         SubResposta                '
             ,'    from tmp19_2                    '
             ,'   where CodigoQuestao = ?          '


     prepare pcty21g03_tmp01_23  from l_sql
     declare ccty21g0319_003  cursor with hold for pcty21g03_tmp01_23

  let m_prep2 = "S"


end function


#====================================================================================
function cty21g03_prepare_55_DescontoLocal()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(5000)
define l_parametro char(100)

let l_sql =   '    SELECT a.CpfCondutor, a.DigitoCpfCondutor,       '
             ,'           b.CpfCondutor, b.DigitoCpfCondutor        '
             ,'    FROM tmp55a_1 a                                  '
             ,'    INNER JOIN tmp55a_2 b                            '
             ,'    ON a.CpfCondutor = b.CpfCondutor                 '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.CpfCondutor, a.DigitoCpfCondutor,       '
             ,'           b.CpfCondutor, b.DigitoCpfCondutor        '
             ,'    FROM tmp55a_1 a                                  '
             ,'    LEFT JOIN tmp55a_2 b                            '
             ,'    ON a.CpfCondutor = b.CpfCondutor                 '
             ,'    WHERE   a.CpfCondutor IS NULL                    '
             ,'    OR   b.CpfCondutor IS NULL                       '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.CpfCondutor, a.DigitoCpfCondutor,       '
             ,'           b.CpfCondutor, b.DigitoCpfCondutor        '
             ,'    FROM tmp55a_1 a                                  '
             ,'    RIGHT JOIN tmp55a_2 b                            '
             ,'    ON a.CpfCondutor = b.CpfCondutor                 '
             ,'    WHERE   a.CpfCondutor IS NULL                    '
             ,'    OR   b.CpfCondutor IS NULL                       '
     prepare pcty21g03_tmp01_15  from l_sql
     declare ccty21g03tmp55  cursor with hold for pcty21g03_tmp01_15
  let m_prep2 = "S"
end function

#====================================================================================
function cty21g03_prepare_22_DescAgravos()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(5000)
define l_parametro char(100)

let l_sql =   '    SELECT a.CodDesconto, a.CoeficienteSemPremio,    '
             ,'           b.CodDesconto, b.CoeficienteSemPremio     '
             ,'    FROM tmp22_1 a                                   '
             ,'    INNER JOIN tmp22_2 b                             '
             ,'    ON a.CodDesconto = b.CodDesconto                 '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.CodDesconto, a.CoeficienteSemPremio,    '
             ,'           b.CodDesconto, b.CoeficienteSemPremio     '
             ,'    FROM tmp22_1 a                                   '
             ,'    LEFT JOIN tmp22_2 b                              '
             ,'    ON a.CodDesconto = b.CodDesconto                 '
             ,'    WHERE   a.CodDesconto IS NULL                    '
             ,'    OR   b.CodDesconto IS NULL                       '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.CodDesconto, a.CoeficienteSemPremio,    '
             ,'           b.CodDesconto, b.CoeficienteSemPremio     '
             ,'    FROM tmp22_1 a                                   '
             ,'    RIGHT JOIN tmp22_2 b                             '
             ,'    ON a.CodDesconto = b.CodDesconto                 '
             ,'    WHERE   a.CodDesconto IS NULL                    '
             ,'    OR   b.CodDesconto IS NULL                       '

     prepare pcty21g03_tmp01_16  from l_sql
     declare ccty21g03tmp22  cursor with hold for pcty21g03_tmp01_16
  let m_prep2 = "S"
end function

#====================================================================================
function cty21g03_prepare_20_RespostasTextos()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(5000)
define l_parametro char(100)


let l_sql =   '    SELECT a.CodigoQuestao, a.CodigoResposta, a.TextoResposta, '
             ,'           b.CodigoQuestao, b.CodigoResposta, b.TextoResposta  '
             ,'    FROM tmp20a_1 a                                  '
             ,'    INNER JOIN tmp20a_2 b                            '
             ,'    ON a.CodigoQuestao = b.CodigoQuestao             '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.CodigoQuestao, a.CodigoResposta, a.TextoResposta, '
             ,'           b.CodigoQuestao, b.CodigoResposta, b.TextoResposta  '
             ,'    FROM tmp20a_1 a                                  '
             ,'    LEFT JOIN tmp20a_2 b                             '
             ,'    ON a.CodigoQuestao = b.CodigoQuestao             '
             ,'    WHERE   a.CodigoQuestao IS NULL                  '
             ,'    OR   b.CodigoQuestao IS NULL                     '
             ,'                                                     '
             ,'    UNION ALL                                        '
             ,'                                                     '
             ,'    SELECT a.CodigoQuestao, a.CodigoResposta, a.TextoResposta, '
             ,'           b.CodigoQuestao, b.CodigoResposta, b.TextoResposta  '
             ,'    FROM tmp20a_1 a                                  '
             ,'    RIGHT JOIN tmp20a_2 b                            '
             ,'    ON a.CodigoQuestao = b.CodigoQuestao             '
             ,'    WHERE   a.CodigoQuestao IS NULL                  '
             ,'    OR   b.CodigoQuestao IS NULL                     '
     prepare pcty21g03_tmp01_17  from l_sql
     declare ccty21g03tmp20  cursor with hold for pcty21g03_tmp01_17
  let m_prep2 = "S"
end function

#====================================================================================
function cty21g03_prepare_17_RegClausula()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(15000)
define l_parametro char(100)


let l_sql =   '    SELECT a.CodClausula, a.CoeficienteClausula, a.CobrancaSN, a.IncVig, a.FinVig, '
             ,'           b.CodClausula, b.CoeficienteClausula, b.CobrancaSN, b.IncVig, b.FinVig '
             ,'    FROM tmp17_1 a                                                                '
             ,'    INNER JOIN tmp17_2 b                                                          '
             ,'    ON a.CodClausula = b.CodClausula                                              '
             ,'                                                                                  '
             ,'    UNION ALL                                                                     '
             ,'                                                                                  '
             ,'    SELECT a.CodClausula, a.CoeficienteClausula, a.CobrancaSN, a.IncVig, a.FinVig, '
             ,'           b.CodClausula, b.CoeficienteClausula, b.CobrancaSN, b.IncVig, b.FinVig '
             ,'    FROM tmp17_1 a                                                                '
             ,'    LEFT JOIN tmp17_2 b                                                           '
             ,'    ON a.CodClausula = b.CodClausula                                              '
             ,'    WHERE   a.CodClausula IS NULL                                                 '
             ,'    OR   b.CodClausula IS NULL                                                    '
             ,'                                                                                  '
             ,'    UNION ALL                                                                     '
             ,'                                                                                  '
             ,'    SELECT a.CodClausula, a.CoeficienteClausula, a.CobrancaSN, a.IncVig, a.FinVig, '
             ,'           b.CodClausula, b.CoeficienteClausula, b.CobrancaSN, b.IncVig, b.FinVig '
             ,'    FROM tmp17_1 a                                                                '
             ,'    RIGHT JOIN tmp17_2 b                                                          '
             ,'    ON a.CodClausula = b.CodClausula                                              '
             ,'    WHERE   a.CodClausula IS NULL                                                 '
             ,'    OR   b.CodClausula IS NULL                                                    '
             ,'                                                                                  '

     prepare pcty21g03_tmp01_18  from l_sql
     declare ccty21g03tmp17  cursor with hold for pcty21g03_tmp01_18
  let m_prep2 = "S"
end function

#====================================================================================
function cty21g03_prepare_54_Clausula()
#====================================================================================
define l_campo     char(100)
define l_tabela_1  char(100)
define l_tabela_2  char(100)
define l_sql       char(30000)
define l_parametro char(100)

let l_sql =   '    SELECT a.CodigoClausula, a.CoeficienteClausula, a.CobrancaSN, a.IncVigencia, a.FinalVigencia,a.PremioLiquidoClausula , a.PremioTotalClausulas, '
             ,'           b.CodigoClausula, b.CoeficienteClausula, b.CobrancaSN, b.IncVigencia, b.FinalVigencia,b.PremioLiquidoClausula , b.PremioTotalClausulas  '
             ,'    FROM tmp54_1 a                                              																																							      '
             ,'    INNER JOIN tmp54_2 b                                                                                                                           '
             ,'    ON a.CodigoClausula = b.CodigoClausula                                                                                                         '
             ,'                                                                                                                                                   '
             ,'    UNION ALL                                                                                                                                      '
             ,'                                                                                                                                                   '
             ,'    SELECT a.CodigoClausula, a.CoeficienteClausula, a.CobrancaSN, a.IncVigencia, a.FinalVigencia,a.PremioLiquidoClausula , a.PremioTotalClausulas, '
             ,'           b.CodigoClausula, b.CoeficienteClausula, b.CobrancaSN, b.IncVigencia, b.FinalVigencia,b.PremioLiquidoClausula , b.PremioTotalClausulas  '
             ,'    FROM tmp54_1 a                                                                                                                                 '
             ,'    LEFT JOIN tmp54_2 b                                                                                                                            '
             ,'    ON a.CodigoClausula = b.CodigoClausula                                                                                                         '
             ,'    WHERE   a.CodigoClausula IS NULL                                                                                                               '
             ,'    OR   b.CodigoClausula IS NULL                                                                                                                  '
             ,'                                                                                                                                                   '
             ,'    UNION ALL                                                                                                                                      '
             ,'                                                                                                                                                   '
             ,'    SELECT a.CodigoClausula, a.CoeficienteClausula, a.CobrancaSN, a.IncVigencia, a.FinalVigencia,a.PremioLiquidoClausula , a.PremioTotalClausulas, '
             ,'           b.CodigoClausula, b.CoeficienteClausula, b.CobrancaSN, b.IncVigencia, b.FinalVigencia,b.PremioLiquidoClausula , b.PremioTotalClausulas  '
             ,'    FROM tmp54_1 a                                                                                                                                 '
             ,'    RIGHT JOIN tmp54_2 b                                                                                                                           '
             ,'    ON a.CodigoClausula = b.CodigoClausula                                                                                                         '
             ,'    WHERE   a.CodigoClausula IS NULL                                                                                                               '
             ,'    OR   b.CodigoClausula IS NULL                                                                                                                  '
             ,'                                                                                                                                                   '

     prepare pcty21g03_tmp01_19  from l_sql
     declare ccty21g03tmp54  cursor with hold for pcty21g03_tmp01_19
  let m_prep2 = "S"
end function

#=============================
function prepare_desconto(l_campo, l_tabela)
#=============================
define l_campo      char(100)
define l_tabela     char(100)
define l_sql        char(5000)

   let l_sql = ''

    let l_sql =   '  select ',l_campo clipped
                , '    from ',l_tabela clipped
     prepare pcty21g03_tmp01_20  from l_sql
     declare ccty21g03tmp001  cursor with hold for pcty21g03_tmp01_20

end function



#================================================================================================================================
function cty21g03(l_ppwprpnum1, l_ppwprpnum2, l_corsus1, l_corsus2, l_ppwtrxqtd1, l_ppwtrxqtd2, l_proposta1, l_proposta2, l_flg)
#================================================================================================================================
define l_ppwprpnum1   like gppmnetprppcl.ppwprpnum
define l_ppwprpnum2   like gppmnetprppcl.ppwprpnum
define l_corsus1      like gppmnetprppcl.corsus
define l_corsus2      like gppmnetprppcl.corsus
define l_ppwtrxqtd1   like gppmnetprppcl.ppwtrxqtd
define l_ppwtrxqtd2   like gppmnetprppcl.ppwtrxqtd
define l_hora         char(50)
define l_seq          char(50)
define w_cod          decimal(5)
define w_des          char(50)
define l_errcod       smallint
define l_par1         smallint
define l_proposta1    char(15)
define l_proposta2    char(15)
define l_primeiro_registro_59  smallint
define l_flg         char(2)

 let m_flag = l_flg
 let m_ppwprpnum1 = l_ppwprpnum1
 let m_ppwprpnum2 = l_ppwprpnum2
 let m_corsus1    = l_corsus1
 let m_corsus2    = l_corsus2
 let m_ppwtrxqtd1 = l_ppwtrxqtd1
 let m_ppwtrxqtd2 = l_ppwtrxqtd2
 let m_index      = 1
 let m_aux        = 1

 initialize  m_vigencia to null

   if m_prep is null   or
      m_prep <> "S"    then
      call ccty21g03_prepare()
   end if

  let m_viginc = today
  let m_temkitgas = false
  let m_vlr_tot_cls = 0
  let w_cod = 0
  let w_des = null
  let l_primeiro_registro_59 = true

  initialize v_codreg to null

  let int_flag = false

  let l_par1 = 1

  call cty21g03_inicializa_l_count() #inicia contagem dos itens de cada tipo

  for i = 1 to 5000
      let ccty21g03_tela[i] = ""
  end for

  call cty21g03_cria_temp()        #cria temp table que pega as infs
  call cty21g03_cria_temp_prop1()  #cria temp tables para transmissao 1
  call cty21g03_cria_temp_prop2()  #cria temp tables para transmissao 2

  let m_flag_proposta = 1
  call cty21g03_dados_case()       #carrega informacao transmissao 1
  call cty21g03_insert_prop1()     #joga infs para tabelas da transmissao 1

  let m_vlr_tot_cls = 0
  call cty21g03_inicializa_l_count() #reinicia contagem dos itens de cada tipo
  call cty21g03_delete_temp()        #limpa tableas para pegar infs da 2 transmissao

  let m_flag_proposta = 2
  call cty21g03_dados_case()       #carrega informacao transmissao 2
  call cty21g03_insert_prop2()     #joga infs para tabelas da transmissao 2

  let m_chave_diff = 0
 #if m_flag = 'F5' then
     call cty21g03_compara_tudo_F5()
 #else
 #   call cty21g03_compara_tudo_F5()
 #   call cty21g03_compara_tudo_F6()
 #end if

###################################

  open window w_ccty21g03 at 6,2 with form 'cty21g03'
             attribute(form line first, comment line last -1, message line last)


  if m_flag = 'F5' then
     display 'ALTERACOES NAS TRANSMISSOES' at 1,27
  else
     display 'ALTERACOES NAS TRANSMISSOES - RESUMIDO!!' at 1,20
  end if

  message '                               (F17) Abandona'

  display l_proposta1 to prp1 attribute(reverse)
  display l_proposta2 to prp2 attribute(reverse)

  error ' Comparacao comcluida!'

  call set_count(m_index)

  display array ccty21g03_tela to s_cty21g03.*

     on key(interrupt, control-c)
       initialize ccty21g03_tela to null

       call cty21g03_delete_temp()
       call cty21g03_drop_temp()
       exit display

  end display

  initialize ccty21g03_tela to null

  let int_flag = false
  close window w_ccty21g03

end function



#==================================
function cty21g03_dados_case()
#==================================
define l_ppwprpnum   like gppmnetprppcl.ppwprpnum
define l_corsus      like gppmnetprppcl.corsus
define l_ppwtrxqtd   like gppmnetprppcl.ppwtrxqtd
 define w_cod decimal(5,0)
 define w_des char(50)
 define l_primeiro_registro_59 smallint
 define lr_gtakram   record
                          empcod        like gtakram.empcod
                         ,ramcod        like gtakram.ramcod
                         ,ramnom        like gtakram.ramnom
                         ,ramsgl        like gtakram.ramsgl
                         ,ramgrpcod     like gtakram.ramgrpcod
                         ,sinramgrp     like gtakram.sinramgrp
                         ,prdramgrp     like gtakram.prdramgrp
                         ,pdtcomtipcod  like gtakram.pdtcomtipcod
                         ,viginc        like gtakram.viginc
                         ,vigfnl        like gtakram.vigfnl
                         ,ramamgnom     like gtakram.ramamgnom
                         ,caddat        like gtakram.caddat
                         ,ramtipcod     like gtakram.ramtipcod
                         ,ramdcrflg     like gtakram.ramdcrflg
                         ,ramrsvprvper  like gtakram.ramrsvprvper
                         ,agdchqflg     like gtakram.agdchqflg
                         ,canfltpgt     like gtakram.canfltpgt
                         ,rscgratip     like gtakram.rscgratip
                         ,csgobrper     like gtakram.csgobrper
                         ,prdcrtcod     like gtakram.prdcrtcod
                      end record

  if m_prep is null   or
      m_prep <> "S"    then
      call ccty21g03_prepare()
   end if

   if m_flag_proposta = 1 then
      let l_ppwprpnum = m_ppwprpnum1
      let l_corsus    = m_corsus1
      let l_ppwtrxqtd = m_ppwtrxqtd1
   else
      let l_ppwprpnum = m_ppwprpnum2
      let l_corsus    = m_corsus2
      let l_ppwtrxqtd = m_ppwtrxqtd2
   end if


   #Captura dos Dados do registro 25
   open cccty21g0301a using l_corsus
                           ,l_ppwprpnum
                           ,l_ppwtrxqtd

   fetch cccty21g0301a into w_linha25

   let w_cod = w_linha25[15,19]
   let w_des = w_linha25[20,70]

   whenever error continue
   open cccty21g0301 using l_corsus
                          ,l_ppwprpnum
                          ,l_ppwtrxqtd



   foreach cccty21g0301 into linha
    whenever error stop

       if sqlca.sqlcode = 100 then
         error "Nao Encontrou Dados Transmitidos"
         sleep 2
       else
         if sqlca.sqlcode <> 100 and sqlca.sqlcode <> 0 then
            error 'Erro (',sqlca.sqlcode,') Avise a Informatica!'
            sleep 2
         end if
       end if

      let v_codreg = linha[13,14]
      let m_chave_diff = 0

      #if m_flag = 'F5' then
         call cty21g03_F5_full_case()
      #else
      #   call cty21g03_F7_resum_case()
      #end if


 end foreach

 let m_poe = 0

end function

#===========================================
 function cty21g03_F5_full_case()
#===========================================
     case v_codreg
         when "00"
            call ccty21g03_reg_00()
         when "01"
            call ccty21g03_reg_01()
         when "04"
            call ccty21g03_reg_04()
         when "05"
            call ccty21g03_reg_05()
         when "06"
            call ccty21g03_reg_06()
         when "07"
            call ccty21g03_reg_07()
         when "08"
            call ccty21g03_reg_08()
         when "09"
            call ccty21g03_reg_09()
         when "10"
            call ccty21g03_reg_10()
         when "11"
            call ccty21g03_reg_11(w_cod, w_des)
         when "12"
            call ccty21g03_reg_12()
         when "13"
            call ccty21g03_reg_13()
         when "14"
            call ccty21g03_reg_14()
         when "15"
            call ccty21g03_reg_15()
         #when "16"                     Sandra Feitosa (7811) Confirmou que o reg 22
         #   call ccty21g03_reg_16()     ja faz o que o 16 faz mais completo.
         when "17"
            call ccty21g03_reg_17()
         when "18"
            call ccty21g03_reg_18()
         when "19"
            call ccty21g03_reg_19()
         when "20"
            call ccty21g03_reg_20()
         when "21"
            call ccty21g03_reg_21()
         when "22"
            call ccty21g03_reg_22()
         when "24"
            call ccty21g03_reg_24()
         #when "25"
         #   call ccty21g03_reg_25()
         when "27"
            call ccty21g03_reg_27()
         when "29"
            call ccty21g03_reg_29()
         when "30"
            call ccty21g03_reg_30()
         when "31"
            call ccty21g03_reg_31()
         when "32"
            call ccty21g03_reg_32()
         {when "34"
          #dados complementares (primeira compra cartao)
            call ccty21g03_reg_70(l_corsus,
                                 l_ppwprpnum,
                                 l_ppwtrxqtd)
            call ccty21g03_reg_71(l_corsus,
                                 l_ppwprpnum,
                                 l_ppwtrxqtd)

            call ccty21g03_reg_34()

            call ccty21g03_seg2()
}
         when "35"
            call ccty21g03_reg_35()
         when "36"
            call ccty21g03_reg_36()
         when "37"
            call ccty21g03_reg_37()
         when "38"
            call ccty21g03_reg_38()
         when "39"
            call ccty21g03_reg_39()
         when "40"
            call ccty21g03_reg_40()
         when "41"
            call ccty21g03_reg_41()
         when "42"
            call ccty21g03_reg_42()
         when "43"
            call ccty21g03_reg_43()
         when "44"
            call ccty21g03_reg_44()
         when "45"
            call ccty21g03_reg_45()
         when "46"
            call ccty21g03_reg_46()
         when "47"
            call ccty21g03_reg_47()

         when "48"
            call ccty21g03_reg_48()
         when "49"
            call ccty21g03_reg_49()
         when "50"
            call ccty21g03_reg_50()
         when "52"
            call ccty21g03_reg_52()
         when "53"
            call ccty21g03_reg_53(l_corsus, l_ppwprpnum, l_ppwtrxqtd)
         when "54"
            call ccty21g03_reg_54()
         when "55"
            #call ccty21g03_reg_55()
            call ccty21g03_reg_55_auto()
         when "56"
            call ccty21g03_reg_56()

        # when "57"
        #    call ccty21g03_reg_57(lr_gtakram.empcod)

         when "58"
            call ccty21g03_reg_58(lr_gtakram.empcod)
         when "59"
            call ccty21g03_reg_59()
         when "60"
            call ccty21g03_reg_60()
         when "61"
            call ccty21g03_reg_61()
         when "62"
            call ccty21g03_reg_62()
         when "63"
            call ccty21g03_reg_63()
         when "64"
            call ccty21g03_reg_64()
         when "66"
            call ccty21g03_reg_66()
         when "67"
            call ccty21g03_reg_67()
      end case

end function

#=========================================
function cty21g03_verifica_dominio(l_cod)
#=========================================
  define l_flag char(1)
  define l_cod  char(2)
  define l_tamanho smallint
  define l_desc  char(60)

  open ccty21g03vrf001 using l_cod
  fetch ccty21g03vrf001 into l_desc

       let l_desc = l_desc clipped
       let l_tamanho = length(l_desc)
       let l_flag = l_desc[l_tamanho]     # Flag   =  'Capa da Proposta|S' = 'S'

       if l_flag    = "S" then
          return true
       else
          return false
       end if

end function

##===========================================
# function cty21g03_F7_resum_case()
##===========================================
#
#     case v_codreg
#         when "00"
#            if cty21g03_verifica_dominio('00') then
#              call ccty21g03_reg_00()
#            end if
#         when "01"
#            if cty21g03_verifica_dominio('01') then
#              call ccty21g03_reg_01()
#            end if
#         when "04"
#            if cty21g03_verifica_dominio('04') then
#              call ccty21g03_reg_04()
#            end if
#         when "05"
#            if cty21g03_verifica_dominio('05') then
#              call ccty21g03_reg_05()
#            end if
#         when "06"
#            if cty21g03_verifica_dominio('06') then
#              call ccty21g03_reg_06()
#            end if
#         when "07"
#            if cty21g03_verifica_dominio('07') then
#              call ccty21g03_reg_07()
#            end if
#         when "08"
#            if cty21g03_verifica_dominio('08') then
#              call ccty21g03_reg_08()
#            end if
#         when "09"
#            if cty21g03_verifica_dominio('09') then
#              call ccty21g03_reg_09()
#            end if
#         when "10"
#            if cty21g03_verifica_dominio('10') then
#              call ccty21g03_reg_10()
#            end if
#         when "11"
#            if cty21g03_verifica_dominio('11') then
#               call ccty21g03_reg_11(w_cod, w_des)
#            end if
#         when "12"
#            if cty21g03_verifica_dominio('12') then
#              call ccty21g03_reg_12()
#            end if
#         when "13"
#            if cty21g03_verifica_dominio('13') then
#              call ccty21g03_reg_14()
#            end if
#         when "14"
#            if cty21g03_verifica_dominio('14') then
#              call ccty21g03_reg_14()
#            end if
#         when "15"
#            if cty21g03_verifica_dominio('15') then
#              call ccty21g03_reg_15()
#            end if
#         #when "16"                     Sandra Feitosa (7811) Confirmou que o reg 22
#         #   call ccty21g03_reg_16()     ja faz o que o 16 faz mais completo.
#         when "17"
#            if cty21g03_verifica_dominio('17') then
#              call ccty21g03_reg_17()
#            end if
#         when "18"
#            if cty21g03_verifica_dominio('18') then
#              call ccty21g03_reg_18()
#            end if
#         when "19"
#            if cty21g03_verifica_dominio('19') then
#              call ccty21g03_reg_19()
#            end if
#         when "20"
#            if cty21g03_verifica_dominio('20') then
#              call ccty21g03_reg_20()
#            end if
#         when "21"
#            if cty21g03_verifica_dominio('21') then
#              call ccty21g03_reg_21()
#            end if
#         when "22"
#            if cty21g03_verifica_dominio('22') then
#              call ccty21g03_reg_22()
#            end if
#         when "24"
#            if cty21g03_verifica_dominio('24') then
#              call ccty21g03_reg_24()
#            end if
#         #when "25"
#         #   call ccty21g03_reg_25()
#         when "27"
#            if cty21g03_verifica_dominio('27') then
#              call ccty21g03_reg_27()
#            end if
#         when "29"
#            if cty21g03_verifica_dominio('29') then
#              call ccty21g03_reg_29()
#            end if
#         when "30"
#            if cty21g03_verifica_dominio('30') then
#              call ccty21g03_reg_30()
#            end if
#         when "31"
#            if cty21g03_verifica_dominio('31') then
#              call ccty21g03_reg_31()
#            end if
#         when "32"
#            if cty21g03_verifica_dominio('32') then
#              call ccty21g03_reg_32()
#            end if
#         {when "34"
#          #dados complementares (primeira compra cartao)
#            call ccty21g03_reg_70(l_corsus,
#                                 l_ppwprpnum,
#                                 l_ppwtrxqtd)
#            call ccty21g03_reg_71(l_corsus,
#                                 l_ppwprpnum,
#                                 l_ppwtrxqtd)
#
#            call ccty21g03_reg_34()
#
#            call ccty21g03_seg2()
#}
#         when "35"
#            if cty21g03_verifica_dominio('35') then
#              call ccty21g03_reg_35()
#            end if
#         when "36"
#            if cty21g03_verifica_dominio('36') then
#              call ccty21g03_reg_36()
#            end if
#         when "37"
#            if cty21g03_verifica_dominio('37') then
#              call ccty21g03_reg_37()
#            end if
#         when "38"
#            if cty21g03_verifica_dominio('38') then
#              call ccty21g03_reg_38()
#            end if
#         when "39"
#            if cty21g03_verifica_dominio('39') then
#              call ccty21g03_reg_39()
#            end if
#         when "40"
#            if cty21g03_verifica_dominio('40') then
#              call ccty21g03_reg_40()
#            end if
#         when "41"
#            if cty21g03_verifica_dominio('41') then
#              call ccty21g03_reg_41()
#            end if
#         when "42"
#            if cty21g03_verifica_dominio('42') then
#              call ccty21g03_reg_42()
#            end if
#         when "43"
#            if cty21g03_verifica_dominio('43') then
#              call ccty21g03_reg_43()
#            end if
#         when "44"
#            if cty21g03_verifica_dominio('44') then
#              call ccty21g03_reg_44()
#            end if
#         when "45"
#            if cty21g03_verifica_dominio('45') then
#              call ccty21g03_reg_45()
#            end if
#         when "46"
#            if cty21g03_verifica_dominio('46') then
#              call ccty21g03_reg_46()
#            end if
#         when "47"
#            if cty21g03_verifica_dominio('47') then
#              call ccty21g03_reg_47()
#            end if
#
#         when "48"
#            if cty21g03_verifica_dominio('48') then
#              call ccty21g03_reg_48()
#            end if
#         when "49"
#            if cty21g03_verifica_dominio('49') then
#              call ccty21g03_reg_49()
#            end if
#         when "50"
#            if cty21g03_verifica_dominio('50') then
#              call ccty21g03_reg_50()
#            end if
#         when "52"
#            if cty21g03_verifica_dominio('52') then
#              call ccty21g03_reg_52()
#            end if
#         when "53"
#            if cty21g03_verifica_dominio('53') then
#               call ccty21g03_reg_53(l_corsus, l_ppwprpnum, l_ppwtrxqtd)
#            end if
#         when "54"
#            if cty21g03_verifica_dominio('54') then
#              call ccty21g03_reg_54()
#            end if
#         when "55"
#            #call ccty21g03_reg_55()
#            if cty21g03_verifica_dominio('55') then
#              call ccty21g03_reg_55_auto()
#            end if
#         when "56"
#            if cty21g03_verifica_dominio('56') then
#              call ccty21g03_reg_56()
#            end if
#
#        # when "57"
#        #    call ccty21g03_reg_57(lr_gtakram.empcod)
#
#         when "58"
#            if cty21g03_verifica_dominio('58') then
#               call ccty21g03_reg_58(lr_gtakram.empcod)
#            end if
#         when "59"
#            if cty21g03_verifica_dominio('59') then
#              call ccty21g03_reg_59()
#            end if
#         when "60"
#            if cty21g03_verifica_dominio('60') then
#              call ccty21g03_reg_60()
#            end if
#         when "61"
#            if cty21g03_verifica_dominio('61') then
#              call ccty21g03_reg_61()
#            end if
#         when "62"
#            if cty21g03_verifica_dominio('62') then
#              call ccty21g03_reg_62()
#            end if
#         when "63"
#            if cty21g03_verifica_dominio('63') then
#              call ccty21g03_reg_63()
#            end if
#         when "64"
#            if cty21g03_verifica_dominio('64') then
#              call ccty21g03_reg_64()
#            end if
#         when "66"
#            if cty21g03_verifica_dominio('66') then
#              call ccty21g03_reg_66()
#            end if
#         when "67"
#            if cty21g03_verifica_dominio('67') then
#              call ccty21g03_reg_67()
#            end if
#      end case
#
#end function

#======================================
function ccty21g03_reg_00() # HEADER
#======================================
 define l_PropostaPPW    char(13)
 define l_CodigoReg      char(2)
 define l_Susep          char(100)
 define l_DataExtracao   char(10)
 define l_Filler         char(1)
 define l_HoraExtracao   char(8)
 define l_Versao         char(19)
 define l_PRMD           char(62)
 define l_cornom          like gcakcorr.cornom

     let l_PropostaPPW  = linha[1,12]
     let l_CodigoReg    = linha[13,14]

     let l_Susep        = linha[15,20]
         let l_cornom   = ccty21g03_susep(l_Susep)
         let l_Susep    = l_Susep clipped,'-',l_cornom clipped

     let l_DataExtracao = linha[21,30]
     let l_Filler       = linha[31,31]
     let l_HoraExtracao = linha[32,39]
     let l_Versao       = linha[40,58]
     let l_PRMD         = linha[59,120]

 --------------------------------------------------
  let l_PropostaPPW    =   l_PropostaPPW  clipped
  let l_CodigoReg      =   l_CodigoReg    clipped
  let l_Susep          =   l_Susep        clipped
  let l_DataExtracao   =   l_DataExtracao clipped
  let l_Filler         =   l_Filler       clipped
  let l_HoraExtracao   =   l_HoraExtracao clipped
  let l_Versao         =   l_Versao       clipped
  let l_PRMD           =   l_PRMD         clipped
  let l_cornom         =   l_cornom       clipped
 --------------------------------------------------
     begin work
            insert into tmp_00( SeqProposta
                              , Seq
                              , PropostaPPW
                              , CodigoReg
                              , Susep
                              , DataExtracao
                              , Filler
                              , HoraExtracao
                              , Versao
                              , PRMD          )

                      values ( m_flag_proposta
                             , m_count00
                             , l_PropostaPPW
                             , l_CodigoReg
                             , l_Susep
                             , l_DataExtracao
                             , l_Filler
                             , l_HoraExtracao
                             , l_Versao
                             , l_PRMD          )


     commit work

    let m_count00 = m_count00 + 1

end function

#===============================================
function ccty21g03_reg_01() # CAPA DA PROPOSTA
#===============================================
 define l_edstipdes       like agdktip.edstipdes

 define l_pgtfrmdes       like gfbkfpag.pgtfrmdes
 define l_sgdirbcod       like gcckcong.sgdirbcod
 define l_sgdnom          like gcckcong.sgdnom

 define l_desctiposeguro   char(100)
 define l_desctipocalculo  char(100)

 define l_descricao       char(024)
 define l_mes_tarifa  char(30)
        ,l_vigencia   like itatvig.vigfnl
        ,l_linha       char(10)

 define l_CodigoReg                char(2)
 define l_OrigemPrincipal          char(2)
 define l_PropPrincipal            char(8)
 define l_SucRenov                 char(2)
 define l_AplRenov                 char(9)
 define l_TPendosso                char(100)
 define l_TXTendosso               char(3)
 define l_QtdItens                 char(4)
 define l_corresp                  char(1)
 define l_FormaPgto                char(100)
 define l_QtdParcelas              char(2)
 define l_VencParc1                char(10)
 define w_vigencia                 char(10)
 define l_IniVig                   char(10)
 define l_FimVig                   char(10)
 define l_tiposeguro               char(100)
 define l_tipocalculo              char(100)
 define l_MoedaPremio              char(3)
 define l_SolicAnalise             char(22)
 define l_boleto_aux               char(1)
 define l_Boleto                   char(3)
 define l_Espaco                   char(11)
 define l_CodOperacao              char(2)
 define l_FlagEmissao              char(1)
 define l_Seguradora               char(100)
 define l_EmBranco                 char(7)
 define l_TarifaPPW                char(12)
 define l_FlagPOE                  char(1)

 let l_edstipdes = ""
 let l_pgtfrmdes = ""
 let l_sgdirbcod = 0
 let l_sgdnom = ""
 let l_descricao = null

     let l_CodigoReg       = linha[13,14]
     let l_OrigemPrincipal = linha[15,16]
     let l_PropPrincipal   = linha[17,24]
     let l_SucRenov        = linha[25,26]
     let l_AplRenov        = linha[27,35]

      let l_TPendosso      = linha[36,37]
        let l_edstipdes    = ccty21g03_endosso(l_TPendosso)
        let l_TPendosso    = l_TPendosso,"-",l_edstipdes clipped

     let l_TXTendosso      = linha[105,107]
     let l_QtdItens        = linha[38,41]
     let l_corresp         = linha[42,42]



     let l_FormaPgto       = linha[43,44]
       let l_pgtfrmdes     = ccty21g03_formapgto(l_FormaPgto)
       let l_FormaPgto     = l_FormaPgto,"-",l_pgtfrmdes clipped


     let l_QtdParcelas     = linha[45,46]
     let l_VencParc1       = linha[47,56]
     let w_vigencia        = linha[57,66]   #Tarifa Abril/2010
     let l_IniVig          = linha[57,66]
     let l_FimVig          = linha[67,76]

     let l_tiposeguro      = linha[84,85]
     let l_tipocalculo     = linha[77,77]
         call ccty21g03_tiposeguro_tipocalculo(l_tiposeguro, l_tipocalculo)
              returning l_desctiposeguro, l_desctipocalculo
     let l_tiposeguro  = l_tiposeguro, '-',l_desctiposeguro  clipped
     let l_tipocalculo = l_tipocalculo,'-',l_desctipocalculo clipped


     let l_MoedaPremio     = linha[78,80]

       case
          when linha[81,81] = "0"
              let l_descricao = "-Nao"
          when linha[81,81] = "1"
              let l_descricao = "–Pendencia Financeira"
          when linha[81,81] = "3"
              let l_descricao = "-POL"
       end case

     let l_SolicAnalise = linha[81,81], l_descricao clipped

     let l_boleto_aux      =  linha[83,83]
     if l_boleto_aux =  1 then
        let l_Boleto = 'SIM'
     else
        let l_Boleto = 'NAO'
     end if


     let l_Boleto          =  linha[83,83]
     let l_Espaco          =  linha[86,96]
     let l_CodOperacao     =  linha[97,98]
     let l_FlagEmissao     =  linha[99,99]

     let l_Seguradora      =  linha[100,104]
       let l_sgdnom        = ccty21g03_seguradora(l_Seguradora)
       let l_Seguradora    = l_Seguradora,"-",l_sgdnom

     let l_EmBranco        =  linha[108,114]

       #Resgate de Ptos na renovação------------------------------------
       #Armazena dados de origem e proposta de R.S.
       let r_apamcapa.prporgpcp = linha[15,16]
       let r_apamcapa.prpnumpcp = linha[17,24]
       let r_apamcapa.rnvsuccod = linha[25,26]
       let r_apamcapa.rnvaplnum = linha[27,35]
       let r_apamcapa.pgtfrm    = linha[43,44]
       #Resgate de Ptos na renovação------------------------------------

       if linha[115,117] = "000" then
           let l_linha = linha[118,119]

           ## chamar o cursor para pesquisar a vigencia da tarifa
           whenever error continue
              open cccty21g03040 using l_linha
              fetch cccty21g03040 into l_vigencia
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then
                 error "Erro no SELECT cccty21g03040.",sqlca.sqlcode,"/" ,sqlca.sqlerrd[2]
                       sleep 2
              end if
              #if sqlca.sqlcode = 100 then
              #   error "Nao encontrou a descricao da Tarifa com tabnum:" ,l_linha
              #end if
           end if
           close cccty21g03040

           ### chamar a funcao converte mes
           let l_mes_tarifa = ccty21g03_mes_tarifa(l_vigencia)
           let l_TarifaPPW  = linha[118,119],"-", l_mes_tarifa clipped
       else
           let l_linha = linha[115,117]

           ## chamar o cursor para pesquisar a vigencia da tarifa
           whenever error continue
              open cccty21g03040 using l_linha
              fetch cccty21g03040 into l_vigencia
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then
                 error "Erro no SELECT cccty21g03040.",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
                sleep 2
              end if
              #if sqlca.sqlcode = 100 then
              #   error "Nao encontrou a descricao da Tarifa com tabnum:" ,l_linha
              #end if
           end if
           close cccty21g03040

           ### chamar a funcao converte mes
           let l_mes_tarifa = ccty21g03_mes_tarifa(l_vigencia)
           let l_TarifaPPW  = linha[115,117],"-", l_mes_tarifa clipped
       end if

     let l_FlagPOE = linha[120,120]

       #let l_apbmenvpdf.prporgpcp = linha[15,16]
       #let l_apbmenvpdf.prpnumpcp = linha[17,24]
     let m_vigencia = l_vigencia

  --------------------------------------------------------
   let l_CodigoReg        =    l_CodigoReg        clipped
   let l_OrigemPrincipal  =    l_OrigemPrincipal  clipped
   let l_PropPrincipal    =    l_PropPrincipal    clipped
   let l_SucRenov         =    l_SucRenov         clipped
   let l_AplRenov         =    l_AplRenov         clipped
   let l_TPendosso        =    l_TPendosso        clipped
   let l_TXTendosso       =    l_TXTendosso       clipped
   let l_QtdItens         =    l_QtdItens         clipped
   let l_corresp          =    l_corresp          clipped
   let l_FormaPgto        =    l_FormaPgto        clipped
   let l_QtdParcelas      =    l_QtdParcelas      clipped
   let l_VencParc1        =    l_VencParc1        clipped
   let w_vigencia         =    w_vigencia         clipped
   let l_IniVig           =    l_IniVig           clipped
   let l_FimVig           =    l_FimVig           clipped
   let l_tiposeguro       =    l_tiposeguro       clipped
   let l_tipocalculo      =    l_tipocalculo      clipped
   let l_MoedaPremio      =    l_MoedaPremio      clipped
   let l_SolicAnalise     =    l_SolicAnalise     clipped
   let l_Boleto           =    l_Boleto           clipped
   let l_Espaco           =    l_Espaco           clipped
   let l_CodOperacao      =    l_CodOperacao      clipped
   let l_FlagEmissao      =    l_FlagEmissao      clipped
   let l_Seguradora       =    l_Seguradora       clipped
   let l_EmBranco         =    l_EmBranco         clipped
   let l_TarifaPPW        =    l_TarifaPPW        clipped
   let l_FlagPOE          =    l_FlagPOE          clipped
  --------------------------------------------------------

   begin work
            insert into tmp_01 (  SeqProposta
                                , Seq
                                , CodigoReg
                                , OrigemPrincipal
                                , PropPrincipal
                                , SucRenov
                                , AplRenov
                                , TPendosso
                                , TXTendosso
                                , QtdItens
                                , corresp
                                , FormaPgto
                                , QtdParcelas
                                , VencParc1
                                , vigencia
                                , IniVig
                                , FimVig
                                , tiposeguro
                                , tipocalculo
                                , MoedaPremio
                                , SolicAnalise
                                , Boleto
                                , Espaco
                                , CodOperacao
                                , FlagEmissao
                                , Seguradora
                                , EmBranco
                                , TarifaPPW
                                , FlagPOE           )

                        values (  m_flag_proposta
                                , m_count01
                                , l_CodigoReg
                                , l_OrigemPrincipal
                                , l_PropPrincipal
                                , l_SucRenov
                                , l_AplRenov
                                , l_TPendosso
                                , l_TXTendosso
                                , l_QtdItens
                                , l_corresp
                                , l_FormaPgto
                                , l_QtdParcelas
                                , l_VencParc1
                                , w_vigencia
                                , l_IniVig
                                , l_FimVig
                                , l_tiposeguro
                                , l_tipocalculo
                                , l_MoedaPremio
                                , l_SolicAnalise
                                , l_Boleto
                                , l_Espaco
                                , l_CodOperacao
                                , l_FlagEmissao
                                , l_Seguradora
                                , l_EmBranco
                                , l_TarifaPPW
                                , l_FlagPOE         )
   commit work

   let m_count01 = m_count01 + 1

end function

#========================================
function ccty21g03_reg_04() # CORRETORES
#========================================
 define l_cornom          like gcakcorr.cornom

 define l_CodigoReg          char(2)
 define l_Susep              char(100)
 define l_participCorretor   char(10)
 define l_FlagCorr          char(1)


  let l_cornom              = ''
  let l_CodigoReg           = ''
  let l_Susep               = ''
  let l_participCorretor    = ''
  let l_FlagCorr       = ''


    let l_CodigoReg = linha[13,14]

    if linha[15,20] <>  " " then
       let l_Susep        = linha[15,20]
         let l_cornom     = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep principal

       let l_ParticipCorretor  = linha[21,23], "," , linha[24,25]

       let l_FlagCorr  = linha[26,26]
    end if

  begin work

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[27,32] <>  " " then
       let l_Susep        = linha[27,32]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep       = l_Susep clipped,'-',l_cornom clipped # Susep 2

       let l_ParticipCorretor  = linha[33,35] , "," , linha[36,37]

       let l_FlagCorr      = linha[38,38]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[39,44] <>  " " then
       let l_Susep        = linha[39,44]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep 3

       let l_ParticipCorretor  = linha[45,47] , "," , linha[48,49]

       let l_FlagCorr      = linha[50,50]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[51,56] <> " " then
       let l_Susep        = linha[51,56]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep 4

       let l_ParticipCorretor  = linha[57,59] , "," , linha[60,61]

       let l_FlagCorr     = linha[62,62]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[63,68] <>  " " then
       let l_Susep        = linha[63,68]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep 5

       let l_ParticipCorretor  = linha[69,71], "," , linha[72,73]

       let l_FlagCorr = linha[74,74]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[75,80] <>  " " then
       let l_Susep        = linha[75,80]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep 6

       let l_ParticipCorretor  = linha[81,83], "," , linha[84,85]

       let l_FlagCorr    = linha[86,86]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[87,92] <>  " " then
       let l_Susep        = linha[87,92]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep 7

       let l_ParticipCorretor = linha[93,95], "," , linha[96,97]

       let l_FlagCorr    = linha[98,98]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if

    let l_Susep = " "

    if linha[99,104] <>  " " then
       let l_Susep = linha[99,104]
         let l_cornom      = ccty21g03_susep(l_Susep)
         let l_Susep      = l_Susep clipped,'-',l_cornom clipped # Susep 8

       let l_ParticipCorretor = linha[105,107], "," , linha[108,109]

       let l_FlagCorr    = linha[110,110]
    end if

    if l_Susep is not null and
       l_Susep <> ' ' then

       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )

    end if


   # let l_EmBranco = linha[111,120]

  -----------------------------------------------------------
   let l_CodigoReg         =  l_CodigoReg            clipped
   let l_Susep             =  l_Susep                clipped
   let l_participCorretor  =  l_participCorretor     clipped
   let l_FlagCorr          =  l_FlagCorr             clipped
  -----------------------------------------------------------

    {begin work
       insert into tmp_04( SeqProposta
                         , Seq
                         , CodigoReg
                         , Susep
                         , participCorretor
                         , FlagCorr          )

                 values (  m_flag_proposta
                         , l_Susep
                         , l_CodigoReg
                         , l_Susep
                         , l_participCorretor
                         , l_FlagCorr       )
    }
    commit work

 let m_count04 = m_count04 + 1
end function

#==============================================
function ccty21g03_reg_05() # DADOS DO SEGURADO
#==============================================
 define l_pestipdes        char(99)
 define l_descricao       like gsakentidsemcgc.cgcsementdes

 define l_CodigoReg       char(2)
 define l_CodSegurado     char(8)
 define l_NomeSegurado    char(50)
 define l_TipoPessoa      char(100)
 define l_CNPJ_CPF        char(20)
 define l_DataNascimento  char(10)
 define l_sexcod          char(01)
 define l_sexo            char(09)
 define l_estciv          char(30)
 define l_EstadoCivil     char(100)
 define l_MotivoSemCNPJ   char(100)
 define l_EmBranco        char(15)

  let l_estciv            = ''

  let l_CodigoReg         = ''
  let l_CodSegurado       = ''
  let l_NomeSegurado      = ''
  let l_TipoPessoa        = ''
  let l_CNPJ_CPF          = ''
  let l_DataNascimento    = ''
  let l_sexo              = ''
  let l_EstadoCivil       = ''
  let l_MotivoSemCNPJ     = ''
  let l_EmBranco          = ''

    let l_CodigoReg    =  linha[13,14]
    let l_CodSegurado  =  linha[15,22]
    let l_NomeSegurado = linha[23,72]

    let w_pestip       = linha[73,73]
    let l_pestipdes    = ccty21g03_pessoa(w_pestip)
    let l_TipoPessoa   = w_pestip,"-",l_pestipdes clipped

    let l_CNPJ_CPF        = linha[74,85] , "/" , linha[86,89] , "-" , linha[90,91]
    let l_DataNascimento  = linha[92,101]

    let l_sexcod = linha[102,102]
    case l_sexcod
       when "F"
    let l_sexo = "Feminino"
       when "M"
    let l_sexo = "Masculino"
    end case

    let l_estciv = f_fungeral_dominio("pfscvlestcod",linha[103,103])
    let l_EstadoCivil = linha[103,103] , "-" , l_estciv clipped

    let l_descricao = ccty21g03_sem_cnpj(linha[104,105])
    let l_MotivoSemCNPJ = l_descricao clipped
    let l_EmBranco = linha[106,120]

  ----------------------------------------------------
   let l_CodigoReg       =  l_CodigoReg       clipped
   let l_CodSegurado     =  l_CodSegurado     clipped
   let l_NomeSegurado    =  l_NomeSegurado    clipped
   let l_TipoPessoa      =  l_TipoPessoa      clipped
   let l_CNPJ_CPF        =  l_CNPJ_CPF        clipped
   let l_DataNascimento  =  l_DataNascimento  clipped
   let l_sexcod          =  l_sexcod          clipped
   let l_sexo            =  l_sexo            clipped
   let l_estciv          =  l_estciv          clipped
   let l_EstadoCivil     =  l_EstadoCivil     clipped
   let l_MotivoSemCNPJ   =  l_MotivoSemCNPJ   clipped
   let l_EmBranco        =  l_EmBranco        clipped
  ----------------------------------------------------

    begin work
       insert into tmp_05( SeqProposta
                         , Seq
                         , CodigoReg
                         , CodSegurado
                         , NomeSegurado
                         , TipoPessoa
                         , CNPJ_CPF
                         , DataNascimento
                         , sexo
                         , EstadoCivil
                         , MotivoSemCNPJ
                         , EmBranco         )

                   values( m_flag_proposta
                         , m_count05
                         , l_CodigoReg
                         , l_CodSegurado
                         , l_NomeSegurado
                         , l_TipoPessoa
                         , l_CNPJ_CPF
                         , l_DataNascimento
                         , l_sexo
                         , l_EstadoCivil
                         , l_MotivoSemCNPJ
                         , l_EmBranco          )
    commit work

let m_count05 = m_count05 + 1

end function

#=================================================
function ccty21g03_reg_06() # ENDERECO DO SEGURADO
#=================================================
 define l_etpendtipdes    char(99)
 define l_endlgdtipdes    char(95)

 define l_CodigoReg        char(2)
 define l_TipoEndereco     char(100)
 define l_TipoLogradouro   char(100)
 define l_Logradouro       char(40)
 define l_Numero           char(5)
 define l_Complemento      char(15)
 define l_CEP              char(10)
 define l_Espaco           char(32)

 let l_etpendtipdes    = ""
 let l_endlgdtipdes    = ""

 let l_CodigoReg       = ''
 let l_TipoEndereco    = ''
 let l_TipoLogradouro  = ''
 let l_Logradouro      = ''
 let l_Numero          = ''
 let l_Complemento     = ''
 let l_CEP             = ''
 let l_Espaco          = ''

     let l_CodigoReg  =  linha[13,14]

     let l_TipoEndereco     = linha[15,15]
        let l_etpendtipdes  = ccty21g03_endereco(l_TipoEndereco)
        let l_TipoEndereco  = linha[15,15] , "-" , l_etpendtipdes clipped

     let l_TipoLogradouro      = linha[16,20]
        let l_endlgdtipdes     = ccty21g03_logradouro(l_TipoLogradouro)
        let l_TipoLogradouro   = linha[16,20] , "-" , l_endlgdtipdes

     let l_Logradouro  = linha[21,60]

     let l_Numero      = linha[61,65]

     let l_Complemento = linha[66,80]

     let l_CEP         = linha[81,85] , "-" , linha[86,88]

     let l_Espaco      = linha[89,120]

  -----------------------------------------------------
   let l_CodigoReg       =  l_CodigoReg        clipped
   let l_TipoEndereco    =  l_TipoEndereco     clipped
   let l_TipoLogradouro  =  l_TipoLogradouro   clipped
   let l_Logradouro      =  l_Logradouro       clipped
   let l_Numero          =  l_Numero           clipped
   let l_Complemento     =  l_Complemento      clipped
   let l_CEP             =  l_CEP              clipped
   let l_Espaco          =  l_Espaco           clipped
  -----------------------------------------------------
 begin work
    insert into tmp_06(  SeqProposta
                       , Seq
                       , CodigoReg
                       , TipoEndereco
                       , TipoLogradouro
                       , Logradouro
                       , Numero
                       , Complemento
                       , CEP
                       , Espaco        )

                values(  m_flag_proposta
                       , m_count06
                       , l_CodigoReg
                       , l_TipoEndereco
                       , l_TipoLogradouro
                       , l_Logradouro
                       , l_Numero
                       , l_Complemento
                       , l_CEP
                       , l_Espaco         )

 commit work


let m_count06 = m_count06 + 1

end function

#=================================================
function ccty21g03_reg_07() # CONTINUACAO ENDERECO
#=================================================

define l_FlagEndereco char(1)
define l_Bairro       char(20)
define l_Cidade       char(20)
define l_UF           char(2)
define l_DDD          char(4)
define l_Telefone     char(15)
define l_Espaco       char(44)

   let l_FlagEndereco = ''
   let l_Bairro       = ''
   let l_Cidade       = ''
   let l_UF           = ''
   let l_DDD          = ''
   let l_Telefone     = ''
   let l_Espaco       = ''

    let l_FlagEndereco = linha[15,15]
    let l_Bairro       = linha[16,35]
    let l_Cidade       = linha[36,55]
    let l_UF           = linha[56,57]
    let l_DDD          = linha[58,61]
    let l_Telefone     = linha[62,76]
    let l_Espaco       = linha[77,120]

  ---------------------------------------------
   let l_FlagEndereco = l_FlagEndereco clipped
   let l_Bairro       = l_Bairro       clipped
   let l_Cidade       = l_Cidade       clipped
   let l_UF           = l_UF           clipped
   let l_DDD          = l_DDD          clipped
   let l_Telefone     = l_Telefone     clipped
   let l_Espaco       = l_Espaco       clipped
  ---------------------------------------------
  begin work
    insert into tmp_07 (  SeqProposta
                        , Seq
                        , FlagEndereco
                        , Bairro
                        , Cidade
                        , UF
                        , DDD
                        , Telefone
                        , Espaco      )

                values (  m_flag_proposta
                        , m_count07
                        , l_FlagEndereco
                        , l_Bairro
                        , l_Cidade
                        , l_UF
                        , l_DDD
                        , l_Telefone
                        , l_Espaco      )
  commit work

let m_count07 = m_count07 + 1

end function
#-------------------------------------
function ccty21g03_reg_08() # ITEM
#-------------------------------------
 define l_sgdnom          like gcckcong.sgdnom
 define l_clalcldes       like agekregiao.clalcldes

 define l_CodigoReg             char(2)
 define l_NumeroItem            char(7)
 define l_NumeroOrigem          char(2)
 define l_PropostaIndividual    char(8)
 define l_ClasseBonus           char(2)
 define l_ClasseLocalizacao     char(100)
 define l_TrafegoHabitual       char(45)
 define l_IncVigAnterior        char(10)
 define l_FinVigAnterior        char(10)
 define l_Seguradora            char(100)
 define l_SucursalItem          char(3)
 define l_AplDoItem             char(10)
 define l_Espaco                char(2)

 let l_CodigoReg          = ''
 let l_NumeroItem         = ''
 let l_NumeroOrigem       = ''
 let l_PropostaIndividual = ''
 let l_ClasseBonus        = ''
 let l_ClasseLocalizacao  = ''
 let l_TrafegoHabitual    = ''
 let l_IncVigAnterior     = ''
 let l_FinVigAnterior     = ''
 let l_Seguradora         = ''
 let l_SucursalItem       = ''
 let l_AplDoItem          = ''
 let l_Espaco             = ''

 let l_sgdnom = ""
 let l_clalcldes = ""


       let l_CodigoReg          = linha[13,14]
       let l_NumeroItem         = linha[15,21]
       let l_NumeroOrigem       = linha[22,23]
       let l_PropostaIndividual = linha[24,31]
       let l_ClasseBonus        = linha[32,33]

       let l_ClasseLocalizacao = linha[34,35]
       let l_clalcldes = ccty21g03_classeloc(l_ClasseLocalizacao)
       let l_ClasseLocalizacao = l_ClasseLocalizacao , "-" , l_clalcldes clipped

       let l_TrafegoHabitual   = linha[36,80]
       let l_IncVigAnterior    = linha[81,90]
       let l_FinVigAnterior    = linha[91,100]

       let l_Seguradora = linha[101,104]
       let l_sgdnom     = ccty21g03_seguradora(l_Seguradora)
       let l_Seguradora = l_Seguradora , "-" , l_sgdnom clipped

       let l_SucursalItem      = linha[106,108]
       let l_AplDoItem         = linha[109,118]
       let l_Espaco            = linha[119,120]

       let w_prporgidv = linha[22,23]
       let w_prpnumidv = linha[24,31]

  ---------------------------------------------------------
   let l_CodigoReg          = l_CodigoReg          clipped
   let l_NumeroItem         = l_NumeroItem         clipped
   let l_NumeroOrigem       = l_NumeroOrigem       clipped
   let l_PropostaIndividual = l_PropostaIndividual clipped
   let l_ClasseBonus        = l_ClasseBonus        clipped
   let l_ClasseLocalizacao  = l_ClasseLocalizacao  clipped
   let l_TrafegoHabitual    = l_TrafegoHabitual    clipped
   let l_IncVigAnterior     = l_IncVigAnterior     clipped
   let l_FinVigAnterior     = l_FinVigAnterior     clipped
   let l_Seguradora         = l_Seguradora         clipped
   let l_SucursalItem       = l_SucursalItem       clipped
   let l_AplDoItem          = l_AplDoItem          clipped
   let l_Espaco             = l_Espaco             clipped
  ---------------------------------------------------------

       begin work
         insert into tmp_08 ( SeqProposta
                            , Seq
                            , CodigoReg
                            , NumeroItem
                            , NumeroOrigem
                            , PropostaIndividual
                            , ClasseBonus
                            , ClasseLocalizacao
                            , TrafegoHabitual
                            , IncVigAnterior
                            , FinVigAnterior
                            , Seguradora
                            , SucursalItem
                            , AplDoItem
                            , Espaco             )

                    values (  m_flag_proposta
                            , m_count08
                            , l_CodigoReg
                            , l_NumeroItem
                            , l_NumeroOrigem
                            , l_PropostaIndividual
                            , l_ClasseBonus
                            , l_ClasseLocalizacao
                            , l_TrafegoHabitual
                            , l_IncVigAnterior
                            , l_FinVigAnterior
                            , l_Seguradora
                            , l_SucursalItem
                            , l_AplDoItem
                            , l_Espaco              )


       commit work

 let m_count08 = m_count08 + 1

end function

#============================================
function ccty21g03_reg_09() # OBSERVACAO ITEM
#============================================
define l_CodigoReg     char(2)
define l_ObsProposta   char(100)
define l_Sequencia     char(2)
define l_Espaco        char(54)

   let l_CodigoReg   = ''
   let l_ObsProposta = ''
   let l_Sequencia   = ''
   let l_Espaco      = ''

       let l_CodigoReg   = linha[13,14]
       let l_ObsProposta = linha[15,64]
       let l_Sequencia   = linha[65,66]
       let l_Espaco      = linha[67,120]

  --------------------------------------------
   let l_CodigoReg   = l_CodigoReg    clipped
   let l_ObsProposta = l_ObsProposta  clipped
   let l_Sequencia   = l_Sequencia    clipped
   let l_Espaco      = l_Espaco       clipped
  --------------------------------------------
   begin work
     insert into tmp_09 ( SeqProposta
                        , Seq
                        , CodigoReg
                        , ObsProposta
                        , Sequencia
                        , Espaco      )

                 values ( m_flag_proposta
                        , m_count09
                        , l_CodigoReg
                        , l_ObsProposta
                        , l_Sequencia
                        , l_Espaco        )
   commit work

 let m_count09 = m_count09 + 1

end function

#========================================================
function ccty21g03_reg_10() # DADOS DO VEICULO
#========================================================
 define l_veicdes         char(40)
 define l_vistdes         char(20)
 define l_tipovis         char(01)
 define l_ctgtrfdes       like agekcateg.ctgtrfdes

 define l_CodigoReg                char(2)
 define l_CodVeiculo               char(5)
 define l_AnoFabricacao            char(4)
 define l_AnoModelo                char(4)
 define l_Placa                    char(7)
 define l_Chassi                   char(20)
 define l_Renavam                  char(50)
 define l_TipoUso                  char(100)
 define l_Veiculo0km               char(1)
 define l_TipoVistoria             char(100)
 define l_VPCOBprovisoria          char(9)
 define l_CapacidadePassageiros    char(2)
 define l_FlagAutoRevenda          char(1)
 define l_FlagAutoNovo             char(1)
 define l_CategoriaTarifada        char(100)
 define l_combustivel              char(100)
 define l_QtdePortas               char(1)
 define l_DataVistoria             char(10)
 define l_Blindado                 char(1)
 define l_VeiculoBlindado          char(100)
 define l_FlagChassiRemarc         char(1)
 define l_CodigoTabelaFipe         char(8)
 define l_CodigoRenovacao          char(25)

 let l_veicdes = ""
 let l_vistdes = ""
 let l_tipovis = ""
 let l_ctgtrfdes = ""
 let l_combustivel = ""

 let l_CodigoReg              = ''
 let l_CodVeiculo             = ''
 let l_AnoFabricacao          = ''
 let l_AnoModelo              = ''
 let l_Placa                  = ''
 let l_Chassi                 = ''
 let l_Renavam                = ''
 let l_TipoUso                = ''
 let l_Veiculo0km             = ''
 let l_TipoVistoria           = ''
 let l_VPCOBprovisoria        = ''
 let l_CapacidadePassageiros  = ''
 let l_FlagAutoRevenda        = ''
 let l_FlagAutoNovo           = ''
 let l_CategoriaTarifada      = ''
 let l_combustivel            = ''
 let l_QtdePortas             = ''
 let l_DataVistoria           = ''
 let l_VeiculoBlindado        = ''
 let l_FlagChassiRemarc       = ''
 let l_CodigoTabelaFipe       = ''
 let l_CodigoRenovacao        = ''


    let l_CodigoReg = linha[13,14]

    let l_CodVeiculo = linha[15,19]
    let l_veicdes = ccty21g03_veiculo(l_CodVeiculo)
    let l_CodVeiculo = l_CodVeiculo, "-" , l_veicdes

    let l_AnoFabricacao = linha[20,23]
    let l_AnoModelo = linha[24,27]
    let l_Placa = linha[28,34]
    let l_Chassi = linha[35,54]
    let l_Renavam =  m_renavam_char # RENAVAM

    let l_TipoUso = f_fungeral_dominio("vcluso",linha[55,56])
    let l_TipoUso = linha[55,56],"-",l_TipoUso

    let l_Veiculo0km = linha[57,57]


    let l_tipovis = upshift(linha[58,58])
    case l_tipovis
         when "V"
              let l_vistdes = "Vistoria tradicional"
         when "C"
              let l_vistdes = "Cobertura provisoria"
    end case
    let l_TipoVistoria = l_tipovis,"-",l_vistdes

    let l_VPCOBprovisoria = linha[59,67]
    let l_CapacidadePassageiros = linha[68,69]
    let l_FlagAutoRevenda  = linha[70,70]
    let l_FlagAutoNovo     = linha[71,71]

    let l_CategoriaTarifada = linha[72,73]
    let l_ctgtrfdes = ccty21g03_categoria(l_CategoriaTarifada)
    let l_CategoriaTarifada = l_CategoriaTarifada , "-" , l_ctgtrfdes

    let l_combustivel = f_fungeral_dominio("vclcmbcod",linha[74,74])
    let l_combustivel = linha[74,74] , "-" , l_combustivel

    let l_QtdePortas       =  linha[75,75]
    let l_DataVistoria     =  linha[76,85]


    #let l_VeiculoBlindado  = linha[86,86]
    #HELDER
    let l_Blindado  = linha[86,86]

    if l_Blindado = 1 then
       let l_VeiculoBlindado = 'SIM'
    else
       let l_VeiculoBlindado = 'NAO'
    end if


    let l_FlagChassiRemarc = linha[87,87]
    let l_CodigoTabelaFipe = linha[88,95]
    let l_CodigoRenovacao  = linha[96,120]

  -----------------------------------------------------------------
   let l_CodigoReg              = l_CodigoReg              clipped
   let l_CodVeiculo             = l_CodVeiculo             clipped
   let l_AnoFabricacao          = l_AnoFabricacao          clipped
   let l_AnoModelo              = l_AnoModelo              clipped
   let l_Placa                  = l_Placa                  clipped
   let l_Chassi                 = l_Chassi                 clipped
   let l_Renavam                = l_Renavam                clipped
   let l_TipoUso                = l_TipoUso                clipped
   let l_Veiculo0km             = l_Veiculo0km             clipped
   let l_TipoVistoria           = l_TipoVistoria           clipped
   let l_VPCOBprovisoria        = l_VPCOBprovisoria        clipped
   let l_CapacidadePassageiros  = l_CapacidadePassageiros  clipped
   let l_FlagAutoRevenda        = l_FlagAutoRevenda        clipped
   let l_FlagAutoNovo           = l_FlagAutoNovo           clipped
   let l_CategoriaTarifada      = l_CategoriaTarifada      clipped
   let l_combustivel            = l_combustivel            clipped
   let l_QtdePortas             = l_QtdePortas             clipped
   let l_DataVistoria           = l_DataVistoria           clipped
   let l_VeiculoBlindado        = l_VeiculoBlindado        clipped
   let l_FlagChassiRemarc       = l_FlagChassiRemarc       clipped
   let l_CodigoTabelaFipe       = l_CodigoTabelaFipe       clipped
   let l_CodigoRenovacao        = l_CodigoRenovacao        clipped
  -----------------------------------------------------------------
   begin work
      insert into tmp_10 ( SeqProposta
                         , Seq
                         , CodigoReg
                         , CodVeiculo
                         , AnoFabricacao
                         , AnoModelo
                         , Placa
                         , Chassi
                         , Renavam
                         , TipoUso
                         , Veiculo0km
                         , TipoVistoria
                         , VPCOBprovisoria
                         , CapacidadePassageiros
                         , FlagAutoRevenda
                         , FlagAutoNovo
                         , CategoriaTarifada
                         , combustivel
                         , QtdePortas
                         , DataVistoria
                         , VeiculoBlindado
                         , FlagChassiRemarc
                         , CodigoTabelaFipe
                         , CodigoRenovacao     )

                  values ( m_flag_proposta
                         , m_count10
                         , l_CodigoReg
                         , l_CodVeiculo
                         , l_AnoFabricacao
                         , l_AnoModelo
                         , l_Placa
                         , l_Chassi
                         , l_Renavam
                         , l_TipoUso
                         , l_Veiculo0km
                         , l_TipoVistoria
                         , l_VPCOBprovisoria
                         , l_CapacidadePassageiros
                         , l_FlagAutoRevenda
                         , l_FlagAutoNovo
                         , l_CategoriaTarifada
                         , l_combustivel
                         , l_QtdePortas
                         , l_DataVistoria
                         , l_VeiculoBlindado
                         , l_FlagChassiRemarc
                         , l_CodigoTabelaFipe
                         , l_CodigoRenovacao       )

   commit work


let m_count10 = m_count10 + 1

end function

#=====================================================
function ccty21g03_reg_11(l_cod, l_des) #VEICULO 0 KM
#=====================================================
 define l_cod decimal(5,0)
 define l_des char(50)

 define l_CodigoReg             char(2)
 define l_NotaFiscal            char(8)
 define l_DataEmissao           char(10)
 define l_DataSaidaVeiculo      char(10)
 define l_CodConcessionaria     char(5)
 define l_NomeConcessionaria    char(50)
 define l_ValorNota             char(16)
 define l_Espaco                char(28)

    let l_CodigoReg          = ''
    let l_NotaFiscal         = ''
    let l_DataEmissao        = ''
    let l_DataSaidaVeiculo   = ''
    let l_CodConcessionaria  = ''
    let l_NomeConcessionaria = ''
    let l_ValorNota          = ''
    let l_Espaco             = ''
    let l_CodigoReg          = linha[13,14]
    let l_NotaFiscal         = linha[15,22]
    let l_DataEmissao        = linha[23,32]
    let l_DataSaidaVeiculo   = linha[33,42]
    let l_CodConcessionaria  = l_cod
    let l_NomeConcessionaria = l_des
    let l_ValorNota          = linha[83,92], "," , linha[93,97]
    let l_Espaco             = linha[93,120]

  --------------------------------------------------------------
   let l_CodigoReg            = l_CodigoReg             clipped
   let l_NotaFiscal           = l_NotaFiscal            clipped
   let l_DataEmissao          = l_DataEmissao           clipped
   let l_DataSaidaVeiculo     = l_DataSaidaVeiculo      clipped
   let l_CodConcessionaria    = l_CodConcessionaria     clipped
   let l_NomeConcessionaria   = l_NomeConcessionaria    clipped
   let l_ValorNota            = l_ValorNota             clipped
   let l_Espaco               = l_Espaco                clipped
  --------------------------------------------------------------
  begin work
     insert into tmp_11 ( SeqProposta
                        , Seq
                        , CodigoReg
                        , NotaFiscal
                        , DataEmissao
                        , DataSaidaVeiculo
                        , CodConcessionaria
                        , NomeConcessionaria
                        , ValorNota
                        , Espaco            )

                 values ( m_flag_proposta
                        , m_count11
                        , l_CodigoReg
                        , l_NotaFiscal
                        , l_DataEmissao
                        , l_DataSaidaVeiculo
                        , l_CodConcessionaria
                        , l_NomeConcessionaria
                        , l_ValorNota
                        , l_Espaco            )

  commit work


 let m_count11 = m_count11 + 1

end function

#======================================
function ccty21g03_reg_12() # CASCO
#======================================
 define l_etpendtipdes    like trakedctip.etpendtipdes
 define l_endlgdtipdes    like gsaktipolograd.endlgdtipdes
 define l_tabela          char(09)
 define l_imposto         char(25)

 define l_CodigoReg              char(2)
 define l_DataRealizacaoCalc     char(10)
 define l_Franquia               char(100)
 define l_Cobertura              char(100)
 define l_FranquiaCasco          char(100)
 define l_ISCalculo              char(100)
 define l_IsencaoImpostos        char(100)
 define l_ISdaBlindagem          char(100)
 define l_PremioLiqCasco         char(100)
 define l_CotacaoMotorShow       char(1)
 define l_PercentISCasco         char(10)
 define l_PercentISBlindagem     char(10)
 define l_FatorDepreciacao       char(10)
 define l_ValorBasico            char(100)
 define l_ValorMaximo            char(100)
 define l_TabelaUtilizada        char(100)

 let l_etpendtipdes = ""
 let l_endlgdtipdes = ""
 let l_franquia = ""
 let l_cobertura = ""
 let l_tabela = ""
 let l_imposto = ""

 let  l_CodigoReg             = ''
 let  l_DataRealizacaoCalc    = ''
 let  l_Franquia              = ''
 let  l_Cobertura             = ''
 let  l_FranquiaCasco         = ''
 let  l_ISCalculo             = ''
 let  l_IsencaoImpostos       = ''
 let  l_ISdaBlindagem         = ''
 let  l_PremioLiqCasco        = ''
 let  l_CotacaoMotorShow      = ''
 let  l_PercentISCasco        = ''
 let  l_PercentISBlindagem    = ''
 let  l_FatorDepreciacao      = ''
 let  l_ValorBasico           = ''
 let  l_ValorMaximo           = ''
 let  l_TabelaUtilizada       = ''


    let l_CodigoReg = linha[13,14]
    let l_DataRealizacaoCalc = linha[15,24]

    let l_Franquia = f_fungeral_dominio("frqclacod",linha[25,25])
    let l_Franquia = linha[25,25] , "-" , l_Franquia clipped

    let l_Cobertura = f_fungeral_dominio("cbtcod",linha[26,26])
    let l_Cobertura = linha[26,26], "-" , l_Cobertura clipped

    let l_FranquiaCasco = ccty21g03_valores(linha[27,36])
    let l_FranquiaCasco = l_FranquiaCasco clipped, "," , linha[37,41]

    let l_ISCalculo = ccty21g03_valores(linha[42,51])
    let l_ISCalculo = l_ISCalculo clipped, "," , linha[52,56]

    case
       when linha[57,57] = "0"
          let l_imposto = "SEM ISENCAO"
       when linha[57,57] = "1"
          let l_imposto = "ISENTO DE I.C.M.S."
       when linha[57,57] = "2"
          let l_imposto = "ISENTO DE I.P.I."
       when linha[57,57] = "3"
          let l_imposto = "ISENTO DE I.C.M.S./I.P.I."
    end case
    let l_IsencaoImpostos = linha[57,57], "-" , l_imposto

    let l_ISdaBlindagem = ccty21g03_valores(linha[58,67])
    let l_ISdaBlindagem = l_ISdaBlindagem clipped, "," , linha[68,72]

    let l_PremioLiqCasco = ccty21g03_valores(linha[73,82])
    let l_PremioLiqCasco = l_PremioLiqCasco clipped, "," , linha[83,87]

    let l_CotacaoMotorShow = linha[88,88]

    let l_PercentISCasco = linha[89,91] , "," , linha[92,93]

    let l_PercentISBlindagem = linha[94,95] , "," , linha[96,97]

    let l_FatorDepreciacao   = linha[98,98] , "," , linha[99,100]

    let l_ValorBasico = ccty21g03_valores(linha[101,107])
    let l_ValorBasico = l_ValorBasico clipped , "," , linha[108,109]

    let l_ValorMaximo = ccty21g03_valores(linha[110,116])
    let l_ValorMaximo = l_ValorMaximo clipped , "," , linha[117,118]

    #PSI 190586
    case
       when linha[119,120] = "01"
    let l_tabela = "MOTORSHOW"
       when linha[119,120] = "02"
    let l_tabela = "FIPE"
    end case
    let l_TabelaUtilizada = linha[119,120] , "-" , l_tabela clipped
  ---------------------------------------------------------------------
   let  l_CodigoReg             =   l_CodigoReg           clipped
   let  l_DataRealizacaoCalc    =   l_DataRealizacaoCalc  clipped
   let  l_Franquia              =   l_Franquia            clipped
   let  l_Cobertura             =   l_Cobertura           clipped
   let  l_FranquiaCasco         =   l_FranquiaCasco       clipped
   let  l_ISCalculo             =   l_ISCalculo           clipped
   let  l_IsencaoImpostos       =   l_IsencaoImpostos     clipped
   let  l_ISdaBlindagem         =   l_ISdaBlindagem       clipped
   let  l_PremioLiqCasco        =   l_PremioLiqCasco      clipped
   let  l_CotacaoMotorShow      =   l_CotacaoMotorShow    clipped
   let  l_PercentISCasco        =   l_PercentISCasco      clipped
   let  l_PercentISBlindagem    =   l_PercentISBlindagem  clipped
   let  l_FatorDepreciacao      =   l_FatorDepreciacao    clipped
   let  l_ValorBasico           =   l_ValorBasico         clipped
   let  l_ValorMaximo           =   l_ValorMaximo         clipped
   let  l_TabelaUtilizada       =   l_TabelaUtilizada     clipped
  ---------------------------------------------------------------------
    begin work
      insert into tmp_12 ( SeqProposta
                         , Seq
                         , CodigoReg
                         , DataRealizacaoCalc
                         , Franquia
                         , Cobertura
                         , FranquiaCasco
                         , ISCalculo
                         , IsencaoImpostos
                         , ISdaBlindagem
                         , PremioLiqCasco
                         , CotacaoMotorShow
                         , PercentISCasco
                         , PercentISBlindagem
                         , FatorDepreciacao
                         , ValorBasico
                         , ValorMaximo
                         , TabelaUtilizada     )
                values   ( m_flag_proposta
                         , m_count12
                         , l_CodigoReg
                         , l_DataRealizacaoCalc
                         , l_Franquia
                         , l_Cobertura
                         , l_FranquiaCasco
                         , l_ISCalculo
                         , l_IsencaoImpostos
                         , l_ISdaBlindagem
                         , l_PremioLiqCasco
                         , l_CotacaoMotorShow
                         , l_PercentISCasco
                         , l_PercentISBlindagem
                         , l_FatorDepreciacao
                         , l_ValorBasico
                         , l_ValorMaximo
                         , l_TabelaUtilizada      )
    commit work


 let m_count12 = m_count12 + 1

end function

#=======================================
function ccty21g03_reg_13() # ACESSORIOS
#=======================================
define l_CodigoReg        char(2)
define l_DataRealizCalc   char(10)


define l_RefAcessorio     char(100)
define l_TipoAcessorio    char(100)
define l_ValorFranquia    char(20)
define l_ISFranquia       char(20)
define l_SeqAcessorio     char(2)
define l_PremioLiqAcess   char(20)

    let l_CodigoReg       = ''
    let l_DataRealizCalc  = ''
    let l_RefAcessorio    = ''
    let l_TipoAcessorio   = ''
    let l_ValorFranquia   = ''
    let l_ISFranquia      = ''
    let l_SeqAcessorio    = ''
    let l_PremioLiqAcess  = ''


    let l_CodigoReg      = linha[13,14]
    let l_DataRealizCalc = linha[15,24]

    let l_refacessorio  = linha[25,28]
    let l_tipoacessorio = linha[29,29]

    let l_ValorFranquia  =  linha[30,39] , "," , linha[40,44]
    let l_ISFranquia     =  linha[45,54] , "," , linha[55,59]
    let l_SeqAcessorio   =  linha[60,61]
    let l_PremioLiqAcess =  linha[62,71] , "," , linha[72,76]

   ----------------------------------------------------
    let l_CodigoReg       =  l_CodigoReg       clipped
    let l_DataRealizCalc  =  l_DataRealizCalc  clipped
    let l_RefAcessorio    =  l_RefAcessorio    clipped
    let l_TipoAcessorio   =  l_TipoAcessorio   clipped
    let l_ValorFranquia   =  l_ValorFranquia   clipped
    let l_ISFranquia      =  l_ISFranquia      clipped
    let l_SeqAcessorio    =  l_SeqAcessorio    clipped
    let l_PremioLiqAcess  =  l_PremioLiqAcess  clipped
   ----------------------------------------------------

   begin work
     insert into tmp_13  ( SeqProposta
                         , Seq
                         , CodigoReg
                         , DataRealizCalc
                         , RefAcessorio
                         , TipoAcessorio
                         , ValorFranquia
                         , ISFranquia
                         , SeqAcessorio
                         , PremioLiqAcess )
                 values  ( m_flag_proposta
                         , m_count13
                         , l_CodigoReg
                         , l_DataRealizCalc
                         , l_RefAcessorio
                         , l_TipoAcessorio
                         , l_ValorFranquia
                         , l_ISFranquia
                         , l_SeqAcessorio
                         , l_PremioLiqAcess  )

   commit work

 let m_count13 = m_count13 + 1

end function

#=====================================
function ccty21g03_reg_14() # RCF
#=====================================
define l_CodigoReg        char(2)
define l_DataRealizaCalc  char(10)
define l_ClasseFranquia   char(2)
define l_ValorFranquiaDM  char(20)
define l_ISDM             char(20)
define l_ValorFranquiaDC  char(20)
define l_ISDC             char(20)
define l_PremioLiqRCF_DM   char(20)
define l_PremioLiqRCF_DC   char(20)
define l_Espaco           char(4)

    let l_CodigoReg       = ''
    let l_DataRealizaCalc = ''
    let l_ClasseFranquia  = ''
    let l_ValorFranquiaDM = ''
    let l_ISDM            = ''
    let l_ValorFranquiaDC = ''
    let l_ISDC            = ''
    let l_PremioLiqRCF_DM = ''
    let l_PremioLiqRCF_DC = ''
    let l_Espaco          = ''


    let l_CodigoReg = linha[13,14]
    let l_DataRealizaCalc = linha[15,24]
    let l_ClasseFranquia = linha[25,26]

    let linha[27,36] = ccty21g03_valores(linha[27,36])
    let l_ValorFranquiaDM  = linha[27,36] clipped , "," , linha[37,41]

    let linha[42,51] = ccty21g03_valores(linha[42,51])
    let l_ISDM             = linha[42,51] clipped, "," , linha[52,56]

    let linha[57,66] = ccty21g03_valores(linha[57,66])
    let l_ValorFranquiaDC  = linha[57,66] clipped, "," , linha[67,71]

    let linha[72,81] = ccty21g03_valores(linha[72,81])
    let l_ISDC             = linha[72,81] clipped, "," , linha[82,86]

    let linha[87,96] = ccty21g03_valores(linha[87,96])
    let l_PremioLiqRCF_DM   = linha[87,96] clipped, "," , linha[97,101]

    let linha[103,111] = ccty21g03_valores(linha[103,111])
    let l_PremioLiqRCF_DC   = linha[103,111] clipped, "," , linha[112,116]

    let l_Espaco = linha[117,120]

  ----------------------------------------------------
   let l_CodigoReg       = l_CodigoReg        clipped
   let l_DataRealizaCalc = l_DataRealizaCalc  clipped
   let l_ClasseFranquia  = l_ClasseFranquia   clipped
   let l_ValorFranquiaDM = l_ValorFranquiaDM  clipped
   let l_ISDM            = l_ISDM             clipped
   let l_ValorFranquiaDC = l_ValorFranquiaDC  clipped
   let l_ISDC            = l_ISDC             clipped
   let l_PremioLiqRCF_DM = l_PremioLiqRCF_DM   clipped
   let l_PremioLiqRCF_DC = l_PremioLiqRCF_DC   clipped
   let l_Espaco          = l_Espaco           clipped
  ----------------------------------------------------

  begin work
     insert into tmp_14 ( SeqProposta
                        , Seq
                        , CodigoReg
                        , DataRealizaCalc
                        , ClasseFranquia
                        , ValorFranquiaDM
                        , ISDM
                        , ValorFranquiaDC
                        , ISDC
                        , PremioLiqRCFDM
                        , PremioLiqRCFDC
                        , Espaco          )
                 values ( m_flag_proposta
                        , m_count14
                        , l_CodigoReg
                        , l_DataRealizaCalc
                        , l_ClasseFranquia
                        , l_ValorFranquiaDM
                        , l_ISDM
                        , l_ValorFranquiaDC
                        , l_ISDC
                        , l_PremioLiqRCF_DM
                        , l_PremioLiqRCF_DC
                        , l_Espaco          )
  commit work
  let m_count14 = m_count14 + 1

end function

#======================================
function ccty21g03_reg_15() # APP
#======================================
define l_CodigoReg          char(2)
define l_DataRealizaCalc    char(10)
define l_ISInvalidez        char(5)
define l_ISMorte            char(20)
define l_ISDMH              char(20)
define l_PremioLiqApp       char(20)
define l_Espaco             char(36)


    let l_CodigoReg         = ''
    let l_DataRealizaCalc   = ''
    let l_ISInvalidez       = ''
    let l_ISMorte           = ''
    let l_ISDMH             = ''
    let l_PremioLiqApp      = ''
    let l_Espaco            = ''

    let l_CodigoReg         = linha[13,14]
    let l_DataRealizaCalc   = linha[15,24]
    let l_ISInvalidez       = linha[35,39]
    let l_ISMorte           = linha[40,49], "," , linha[50,54]
    let l_ISDMH             = linha[55,64], "," , linha[65,69]
    let l_PremioLiqApp      = linha[70,79], "," , linha[80,84]
    let l_Espaco            = linha[85,120]

   -------------------------------------------------------
    let l_CodigoReg         = l_CodigoReg         clipped
    let l_DataRealizaCalc   = l_DataRealizaCalc   clipped
    let l_ISInvalidez       = l_ISInvalidez       clipped
    let l_ISMorte           = l_ISMorte           clipped
    let l_ISDMH             = l_ISDMH             clipped
    let l_PremioLiqApp      = l_PremioLiqApp      clipped
    let l_Espaco            = l_Espaco            clipped
   -------------------------------------------------------

   begin work
        insert into tmp_15  ( SeqProposta
                            , Seq
                            , CodigoReg
                            , DataRealizaCalc
                            , ISInvalidez
                            , ISMorte
                            , ISDMH
                            , PremioLiqApp
                            , Espaco    )

                   values   ( m_flag_proposta
                            , m_count15
                            , l_CodigoReg
                            , l_DataRealizaCalc
                            , l_ISInvalidez
                            , l_ISMorte
                            , l_ISDMH
                            , l_PremioLiqApp
                            , l_Espaco        )
   commit work

 let m_count15 = m_count15 + 1

end function

{#================================================================
function ccty21g03_reg_16() # REGISTRO DE DESCONTOS E AGRAVO
#================================================================
 define l_CodigoReg                char(2)
 define l_CodDesconto              char(100)
 define l_CoeficienteSemPremio     char(20)
 define l_CodDesconto2             char(100)
 define l_CoeficienteSemPremio2    char(20)
 define l_CodDesconto3             char(100)
 define l_CoeficienteSemPremio3    char(20)
 define l_CodDesconto4             char(100)
 define l_CoeficienteSemPremio4    char(20)
 define l_CodDesconto5             char(100)
 define l_CoeficienteSemPremio5    char(20)
 define l_CodDesconto6             char(100)
 define l_CoeficienteSemPremio6    char(20)
 define l_CodDesconto7             char(100)
 define l_CoeficienteSemPremio7    char(20)
 define l_CodDesconto8             char(100)
 define l_CoeficienteSemPremio8    char(20)
 define l_CodDesconto9             char(100)
 define l_CoeficienteSemPremio9    char(20)
 define l_CodDesconto10            char(100)
 define l_CoeficienteSemPremio10   char(20)
 define l_CodDesconto11            char(100)
 define l_CoeficienteSemPremio11   char(20)
 define l_CodDesconto12            char(100)
 define l_CoeficienteSemPremio12   char(20)
 define l_CodDesconto13            char(100)
 define l_CoeficienteSemPremio13   char(20)
 define l_CodDesconto14            char(100)
 define l_CoeficienteSemPremio14   char(20)
 define l_CodDesconto15            char(100)
 define l_CoeficienteSemPremio15   char(20)
 define l_Espaco                   char(1)

 define l_sinramgrp       like gtakram.sinramgrp
 define l_cndeslcod       like aggkcndesl.cndeslcod
 define l_cndeslnom       like aggkcndesl.cndeslnom

 let l_cndeslcod = 0
 let l_cndeslnom = ""

 let l_CodigoReg                 = ''
 let l_CodDesconto               = ''
 let l_CoeficienteSemPremio      = ''
 let l_CodDesconto2              = ''
 let l_CoeficienteSemPremio2     = ''
 let l_CodDesconto3              = ''
 let l_CoeficienteSemPremio3     = ''
 let l_CodDesconto4              = ''
 let l_CoeficienteSemPremio4     = ''
 let l_CodDesconto5              = ''
 let l_CoeficienteSemPremio5     = ''
 let l_CodDesconto6              = ''
 let l_CoeficienteSemPremio6     = ''
 let l_CodDesconto7              = ''
 let l_CoeficienteSemPremio7     = ''
 let l_CodDesconto8              = ''
 let l_CoeficienteSemPremio8     = ''
 let l_CodDesconto9              = ''
 let l_CoeficienteSemPremio9     = ''
 let l_CodDesconto10             = ''
 let l_CoeficienteSemPremio10    = ''
 let l_CodDesconto11             = ''
 let l_CoeficienteSemPremio11    = ''
 let l_CodDesconto12             = ''
 let l_CoeficienteSemPremio12    = ''
 let l_CodDesconto13             = ''
 let l_CoeficienteSemPremio13    = ''
 let l_CodDesconto14             = ''
 let l_CoeficienteSemPremio14    = ''
 let l_CodDesconto15             = ''
 let l_CoeficienteSemPremio15    = ''
 let l_Espaco                    = ''

    let l_CodigoReg = linha[13,14]

    if linha[15,16] <>  " " then
       let l_cndeslcod = linha[15,16]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto = linha[15,16], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio = linha[17,17], "," , linha[18,21], " %"
    end if

    if linha[22,23] <>  " " then
       let l_cndeslcod = linha[22,23]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto2 = linha[22,23], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio2 = linha[24,24],"," , linha[25,28], " %"
    end if

    if linha[29,30] <>  " " then
       let l_cndeslcod = linha[29,30]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto3 = linha[29,30], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio3 = linha[31,31],",", linha[32,35], " %"
    end if

    if linha[36,37] <>  " " then
       let l_cndeslcod = linha[36,37]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto4 = linha[36,37], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio4 = linha[38,38],",", linha[39,42], " %"
    end if

    if linha[43,44] <>  " " then
       let l_cndeslcod = linha[43,44]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto5 = linha[43,44], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio5 = linha[45,45],",", linha[46,49], " %"
    end if

    if linha[50,51] <>  " " then
       let l_cndeslcod = linha[50,51]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto6 = linha[50,51], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio6 = linha[52,52],",", linha[53,56], " %"
    end if

    if linha[57,58] <>  " " then
       let l_cndeslcod = linha[57,58]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto7 = linha[57,58], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio7 = linha[59,59],",", linha[60,63], " %"
    end if

    if linha[64,65] <>  " " then
       let l_cndeslcod = linha[64,65]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto8 = linha[64,65], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio8 = linha[66,66],",", linha[67,70], " %"
    end if

    if linha[71,72] <>  " " then
       let l_cndeslcod = linha[71,72]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto9 = linha[71,72], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio9 = linha[73,73],",", linha[74,77], " %"
    end if

    if linha[78,79] <>  " " then
       let l_cndeslcod = linha[78,79]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto10 = linha[78,79], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio10 = linha[80,80],",", linha[81,84], " %"
    end if

    if linha[85,86] <>  " " then
       let l_cndeslcod = linha[85,86]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto11 = linha[85,86], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio11 = linha[87,87],",", linha[88,91], " %"
    end if

    if linha[92,93] <>  " " then
       let l_cndeslcod = linha[92,93]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto12 = linha[92,93], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio12 = linha[94,94],",", linha[95,98], " %"
    end if

    if linha[99,100] <>  " " then
       let l_cndeslcod = linha[99,100]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto13 = linha[99,100], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio13 = linha[101,101],",", linha[102,105], " %"
    end if

    if linha[106,107] <>  " " then
       let l_cndeslcod = linha[106,107]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto14 = linha[106,107], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio14 = linha[108,108],",", linha[109,112], " %"
    end if

    if linha[113,114] <>  " " then
       let l_cndeslcod = linha[113,114]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto15 = linha[113,114], "-" , l_cndeslnom clipped

       let l_CoeficienteSemPremio15 = linha[115,115],",", linha[116,119], " %"
    end if

    let l_Espaco = linha[120,120]

-------------------------------------------------------------------
 let l_CodigoReg               =  l_CodigoReg               clipped
 let l_CodDesconto             =  l_CodDesconto             clipped
 let l_CoeficienteSemPremio    =  l_CoeficienteSemPremio    clipped
 let l_CodDesconto2            =  l_CodDesconto2            clipped
 let l_CoeficienteSemPremio2   =  l_CoeficienteSemPremio2   clipped
 let l_CodDesconto3            =  l_CodDesconto3            clipped
 let l_CoeficienteSemPremio3   =  l_CoeficienteSemPremio3   clipped
 let l_CodDesconto4            =  l_CodDesconto4            clipped
 let l_CoeficienteSemPremio4   =  l_CoeficienteSemPremio4   clipped
 let l_CodDesconto5            =  l_CodDesconto5            clipped
 let l_CoeficienteSemPremio5   =  l_CoeficienteSemPremio5   clipped
 let l_CodDesconto6            =  l_CodDesconto6            clipped
 let l_CoeficienteSemPremio6   =  l_CoeficienteSemPremio6   clipped
 let l_CodDesconto7            =  l_CodDesconto7            clipped
 let l_CoeficienteSemPremio7   =  l_CoeficienteSemPremio7   clipped
 let l_CodDesconto8            =  l_CodDesconto8            clipped
 let l_CoeficienteSemPremio8   =  l_CoeficienteSemPremio8   clipped
 let l_CodDesconto9            =  l_CodDesconto9            clipped
 let l_CoeficienteSemPremio9   =  l_CoeficienteSemPremio9   clipped
 let l_CodDesconto10           =  l_CodDesconto10           clipped
 let l_CoeficienteSemPremio10  =  l_CoeficienteSemPremio10  clipped
 let l_CodDesconto11           =  l_CodDesconto11           clipped
 let l_CoeficienteSemPremio11  =  l_CoeficienteSemPremio11  clipped
 let l_CodDesconto12           =  l_CodDesconto12           clipped
 let l_CoeficienteSemPremio12  =  l_CoeficienteSemPremio12  clipped
 let l_CodDesconto13           =  l_CodDesconto13           clipped
 let l_CoeficienteSemPremio13  =  l_CoeficienteSemPremio13  clipped
 let l_CodDesconto14           =  l_CodDesconto14           clipped
 let l_CoeficienteSemPremio14  =  l_CoeficienteSemPremio14  clipped
 let l_CodDesconto15           =  l_CodDesconto15           clipped
 let l_CoeficienteSemPremio15  =  l_CoeficienteSemPremio15  clipped
 let l_Espaco                  =  l_Espaco                  clipped
-------------------------------------------------------------------

 begin work
    insert into tmp_16 ( SeqProposta
                       , Seq
                       , CodigoReg
                       , CodDesconto
                       , CoeficienteSemPremio
                       , CodDesconto2
                       , CoeficienteSemPremio2
                       , CodDesconto3
                       , CoeficienteSemPremio3
                       , CodDesconto4
                       , CoeficienteSemPremio4
                       , CodDesconto5
                       , CoeficienteSemPremio5
                       , CodDesconto6
                       , CoeficienteSemPremio6
                       , CodDesconto7
                       , CoeficienteSemPremio7
                       , CodDesconto8
                       , CoeficienteSemPremio8
                       , CodDesconto9
                       , CoeficienteSemPremio9
                       , CodDesconto10
                       , CoeficienteSemPremio10
                       , CodDesconto11
                       , CoeficienteSemPremio11
                       , CodDesconto12
                       , CoeficienteSemPremio12
                       , CodDesconto13
                       , CoeficienteSemPremio13
                       , CodDesconto14
                       , CoeficienteSemPremio14
                       , CodDesconto15
                       , CoeficienteSemPremio15
                       , Espaco                 )
                values ( m_flag_proposta
                       , m_count16
                       , l_CodigoReg
                       , l_CodDesconto
                       , l_CoeficienteSemPremio
                       , l_CodDesconto2
                       , l_CoeficienteSemPremio2
                       , l_CodDesconto3
                       , l_CoeficienteSemPremio3
                       , l_CodDesconto4
                       , l_CoeficienteSemPremio4
                       , l_CodDesconto5
                       , l_CoeficienteSemPremio5
                       , l_CodDesconto6
                       , l_CoeficienteSemPremio6
                       , l_CodDesconto7
                       , l_CoeficienteSemPremio7
                       , l_CodDesconto8
                       , l_CoeficienteSemPremio8
                       , l_CodDesconto9
                       , l_CoeficienteSemPremio9
                       , l_CodDesconto10
                       , l_CoeficienteSemPremio10
                       , l_CodDesconto11
                       , l_CoeficienteSemPremio11
                       , l_CodDesconto12
                       , l_CoeficienteSemPremio12
                       , l_CodDesconto13
                       , l_CoeficienteSemPremio13
                       , l_CodDesconto14
                       , l_CoeficienteSemPremio14
                       , l_CodDesconto15
                       , l_CoeficienteSemPremio15
                       , l_Espaco                )
 commit work

 let m_count16 = m_count16 + 1

end function
}
#==================================================
function ccty21g03_reg_17() # REGISTRO DE CLAUSULA
#==================================================
define l_CodigoReg             char(2)
define l_CodClausula           char(100)
define l_CoeficienteClausula   char(20)
define l_CobrancaSN            char(1)
define l_IncVig                char(10)
define l_FinVig                char(10)

    define l_viginc     date
          ,l_clscod     like aackcls.clscod
          ,l_clsdes     like aackcls.clsdes


let l_CodigoReg             = ''
let l_CodClausula           = ''
let l_CoeficienteClausula   = ''
let l_CobrancaSN            = ''
let l_IncVig                = ''
let l_FinVig                = ''


    let l_CodigoReg = linha[13,14]

    let l_viginc = m_viginc
    let l_clscod = linha[15,17]
    let l_clsdes = ccty21g03_codigoclausula( l_viginc, l_clscod )
    let l_CodClausula = linha[15,17], '-' , l_clsdes

    let l_CoeficienteClausula = linha[18,18],",", linha[19,22]

    let l_CobrancaSN = linha[23,23]

    let l_IncVig = linha[24,33]

    let l_FinVig = linha[34,43]

--------------------------------------------------------------
let l_CodigoReg             = l_CodigoReg              clipped
let l_CodClausula           = l_CodClausula            clipped
let l_CoeficienteClausula   = l_CoeficienteClausula    clipped
let l_CobrancaSN            = l_CobrancaSN             clipped
let l_IncVig                = l_IncVig                 clipped
let l_FinVig                = l_FinVig                 clipped
--------------------------------------------------------------
   begin work

   if l_CodClausula[1,3] <> ' ' and
      l_CodClausula[1,3] is not null then
      insert into tmp_17 ( SeqProposta
                         , Seq
                         , CodigoReg
                         , CodClausula
                         , CoeficienteClausula
                         , CobrancaSN
                         , IncVig
                         , FinVig
                         )

                  values ( m_flag_proposta
                         , m_count17
                         , l_CodigoReg
                         , l_CodClausula
                         , l_CoeficienteClausula
                         , l_CobrancaSN
                         , l_IncVig
                         , l_FinVig
                        )
    end if

    let l_clscod = linha[44,46]
    let l_clsdes = ccty21g03_codigoclausula( l_viginc, l_clscod )
    let l_CodClausula = linha[44,46], '-' , l_clsdes

    let l_CoeficienteClausula = linha[47,47],",", linha[48,51]

    let l_CobrancaSN = linha[52,52]

    let l_IncVig = linha[53,62]

    let l_FinVig = linha[63,72]

--------------------------------------------------------------
let l_CodigoReg             = l_CodigoReg              clipped
let l_CodClausula           = l_CodClausula            clipped
let l_CoeficienteClausula   = l_CoeficienteClausula    clipped
let l_CobrancaSN            = l_CobrancaSN             clipped
let l_IncVig                = l_IncVig                 clipped
let l_FinVig                = l_FinVig                 clipped
--------------------------------------------------------------

   if l_CodClausula[1,3] <> ' ' and
      l_CodClausula[1,3] is not null then
      insert into tmp_17 ( SeqProposta
                         , Seq
                         , CodigoReg
                         , CodClausula
                         , CoeficienteClausula
                         , CobrancaSN
                         , IncVig
                         , FinVig
                         )

                  values ( m_flag_proposta
                         , m_count17
                         , l_CodigoReg
                         , l_CodClausula
                         , l_CoeficienteClausula
                         , l_CobrancaSN
                         , l_IncVig
                         , l_FinVig
                        )
    end if

    let l_clscod = linha[73,75]
    let l_clsdes = ccty21g03_codigoclausula( l_viginc, l_clscod )
    let l_CodClausula = linha[73,75], '-' , l_clsdes

    let l_CoeficienteClausula = linha[76,76],",", linha[77,80]

    let l_CobrancaSN = linha[81,81]

    let l_IncVig = linha[82,91]

    let l_FinVig = linha[92,101]

--------------------------------------------------------------
let l_CodigoReg             = l_CodigoReg              clipped
let l_CodClausula           = l_CodClausula            clipped
let l_CoeficienteClausula   = l_CoeficienteClausula    clipped
let l_CobrancaSN            = l_CobrancaSN             clipped
let l_IncVig                = l_IncVig                 clipped
let l_FinVig                = l_FinVig                 clipped
--------------------------------------------------------------

   if l_CodClausula[1,3] <> ' ' and
      l_CodClausula[1,3] is not null then
      insert into tmp_17 ( SeqProposta
                         , Seq
                         , CodigoReg
                         , CodClausula
                         , CoeficienteClausula
                         , CobrancaSN
                         , IncVig
                         , FinVig
                         )

                  values ( m_flag_proposta
                         , m_count17
                         , l_CodigoReg
                         , l_CodClausula
                         , l_CoeficienteClausula
                         , l_CobrancaSN
                         , l_IncVig
                         , l_FinVig
                        )
    end if

   commit work



 let m_count17 = m_count17 + 1

end function

#===============================================
function ccty21g03_reg_18() # TEXTOS DE CLAUSULA
#===============================================
define l_CodigoReg     char(2)
define l_CodClausula   char(3)
define l_txtClausula   char(50)
define l_seqTexto      char(2)
define l_Espaco        char(51)

let l_CodigoReg   = ''
let l_CodClausula = ''
let l_txtClausula = ''
let l_seqTexto    = ''
let l_Espaco      = ''

    let l_CodigoReg   = linha[13,14]
    let l_CodClausula = linha[15,17]
    let l_txtClausula = linha[18,67]
    let l_seqTexto    = linha[68,69]
    let l_Espaco      = linha[70,120]

-------------------------------------------
let l_CodigoReg   =  l_CodigoReg    clipped
let l_CodClausula =  l_CodClausula  clipped
let l_txtClausula =  l_txtClausula  clipped
let l_seqTexto    =  l_seqTexto     clipped
let l_Espaco      =  l_Espaco       clipped
-------------------------------------------
display l_CodigoReg
display l_CodClausula
display l_txtClausula
display l_seqTexto
display l_Espaco



  begin work
    insert into tmp_18 ( SeqProposta
                       , Seq
                       , CodigoReg
                       , CodClausula
                       , txtClausula
                       , seqTexto
                       , Espaco            )

                values ( m_flag_proposta
                       , m_count18
                       , l_CodigoReg
                       , l_CodClausula
                       , l_txtClausula
                       , l_seqTexto
                       , l_Espaco            )
  commit work

 let m_count18 = m_count18 + 1

end function
#-------------------------------------
function ccty21g03_reg_19() # QUESTIONARIO PERFIL
#-------------------------------------

   define l_CodigoReg         char(2)
   define l_CodigoProduto     char(2)

   define l_CodigoQuestao     char(80)
   define l_CodigoResposta    char(80)
   define l_SubResposta       char(80)

   define l_Espaco            char(9)

   define l_qstcod          like apqkquest.qstcod
   define l_qstdes          like apqkquest.qstdes
   define l_rspcod          like apqkdominio.rspcod
   define l_qstrspdsc       like apqkdominio.qstrspdsc
         ,l_qstrsptip       like apqkquest.qstrsptip
         ,l_subrspdes       like apqksubrsp.qstrsphtmdes
         ,l_subrspcod       like apqksubrsp.rspsubcod

   let l_qstcod = 0
   let l_qstdes = ""
   let l_rspcod = 0
   let l_qstrspdsc = ""
   let l_subrspdes = 0
   let l_subrspcod = ""

   let l_CodigoReg         = ""
   let l_CodigoProduto     = ""
   let l_CodigoQuestao     = "" #5
   let l_CodigoResposta    = ""
   let l_SubResposta       = ""
   let l_Espaco            = ""

   let l_CodigoReg     = linha[13,14]
   let l_CodigoProduto = linha[15,16]


   let l_qstcod = linha[17,19]
   call ccty21g03_questao(l_qstcod)
      returning l_qstdes,l_qstrsptip
   let l_CodigoQuestao = linha[17,19],"-",l_qstdes

   let l_rspcod = linha[20,22]
   let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
   let l_CodigoResposta  = linha[20,22],"-",l_qstrspdsc

   let l_subrspcod = linha[33,35]
   let l_subrspdes = ccty21g03_subresposta(l_qstcod, l_rspcod,l_subrspcod)
   let l_SubResposta     = linha[33,35],"-",l_subrspdes

   begin work

      insert into tmp_19 ( SeqProposta
                          ,CodigoReg
                          ,CodigoProduto
                          ,CodigoQuestao
                          ,CodigoResposta
                          ,SubResposta)

                  values ( m_flag_proposta
                          ,l_CodigoReg
                          ,l_CodigoProduto
                          ,l_CodigoQuestao
                          ,l_CodigoResposta
                          ,l_SubResposta)

   let l_qstcod = linha[36,38]
   call ccty21g03_questao(l_qstcod)
      returning l_qstdes,l_qstrsptip
   let l_CodigoQuestao = linha[36,38],"-",l_qstdes

   let l_rspcod = linha[39,41]
   let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
   let l_CodigoResposta  = linha[39,41],"-",l_qstrspdsc


   let l_subrspcod = linha[52,54]
   let l_subrspdes = ccty21g03_subresposta(l_qstcod, l_rspcod,l_subrspcod)
   let l_SubResposta     = linha[52,54],"-",l_subrspdes

     insert into tmp_19 ( SeqProposta
                          ,CodigoReg
                          ,CodigoProduto
                          ,CodigoQuestao
                          ,CodigoResposta
                          ,SubResposta)

                  values ( m_flag_proposta
                          ,l_CodigoReg
                          ,l_CodigoProduto
                          ,l_CodigoQuestao
                          ,l_CodigoResposta
                          ,l_SubResposta)


   let l_qstcod = linha[55,57]
   call ccty21g03_questao(l_qstcod)
      returning l_qstdes,l_qstrsptip
   let l_CodigoQuestao = linha[55,57],"-",l_qstdes

   let l_rspcod = linha[58,60]
   let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
   let l_CodigoResposta  = linha[58,60],"-",l_qstrspdsc

   let l_subrspcod = linha[71,73]
   let l_subrspdes = ccty21g03_subresposta(l_qstcod, l_rspcod,l_subrspcod)
   let l_SubResposta     = linha[71,73],"-",l_subrspdes

    insert into tmp_19 ( SeqProposta
                          ,CodigoReg
                          ,CodigoProduto
                          ,CodigoQuestao
                          ,CodigoResposta
                          ,SubResposta)

                  values ( m_flag_proposta
                          ,l_CodigoReg
                          ,l_CodigoProduto
                          ,l_CodigoQuestao
                          ,l_CodigoResposta
                          ,l_SubResposta)


   let l_qstcod = linha[74,76]
   call ccty21g03_questao(l_qstcod)
      returning l_qstdes,l_qstrsptip
   let l_CodigoQuestao = linha[74,76],"-",l_qstdes

   let l_rspcod = linha[77,79]
   let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
   let l_CodigoResposta  = linha[77,79],"-",l_qstrspdsc

   let l_subrspcod = linha[90,92]
   let l_subrspdes = ccty21g03_subresposta(l_qstcod, l_rspcod,l_subrspcod)
   let l_SubResposta     = linha[90,92],"-",l_subrspdes

    insert into tmp_19 ( SeqProposta
                          ,CodigoReg
                          ,CodigoProduto
                          ,CodigoQuestao
                          ,CodigoResposta
                          ,SubResposta)

                  values ( m_flag_proposta
                          ,l_CodigoReg
                          ,l_CodigoProduto
                          ,l_CodigoQuestao
                          ,l_CodigoResposta
                          ,l_SubResposta)

   let l_qstcod = linha[93,95]
   call ccty21g03_questao(l_qstcod)
      returning l_qstdes,l_qstrsptip
   let l_CodigoQuestao = linha[93,95],"-",l_qstdes

   let l_rspcod = linha[96,98]
   let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
   let l_CodigoResposta  = linha[96,98],"-",l_qstrspdsc

   let l_subrspcod = linha[109,111]
   let l_subrspdes = ccty21g03_subresposta(l_qstcod, l_rspcod,l_subrspcod)
   let l_SubResposta     = linha[90,92],"-",l_subrspdes

    insert into tmp_19 ( SeqProposta
                          ,CodigoReg
                          ,CodigoProduto
                          ,CodigoQuestao
                          ,CodigoResposta
                          ,SubResposta)

                  values ( m_flag_proposta
                          ,l_CodigoReg
                          ,l_CodigoProduto
                          ,l_CodigoQuestao
                          ,l_CodigoResposta
                          ,l_SubResposta)

   commit work

   let m_count19 = m_count19 + 1

end function

#-------------------------------------
function ccty21g03_reg_20() # POE - RESPOSTAS E TEXTOS
#-------------------------------------

   define l_PoeConcorrencia   char(3)
   define l_CodigoReg         char(2)
   define l_TipoProduto       char(2)

   define l_CodigoQuestao     char(80)
   define l_CodigoResposta    char(80)
   define l_TextoResposta     char(80)

   define l_CodigoQuestao2    char(80)
   define l_CodigoResposta2   char(80)
   define l_TextoResposta2    char(80)


   define l_qstcod          like apqkquest.qstcod
   define l_qstdes          like apqkquest.qstdes
   define l_rspcod          like apqkdominio.rspcod
   define l_qstrspdsc       like apqkdominio.qstrspdsc
         ,l_qstrsptip       like apqkquest.qstrsptip

   define l_cncpoeflg       like apbmpoe.cncpoeflg
   define l_literal_flgpoe  char(3)

   define l_codemp          char(6)

   initialize l_cncpoeflg to null


   let l_PoeConcorrencia   = ""
   let l_CodigoReg         = ""
   let l_TipoProduto       = ""
   let l_CodigoQuestao     = ""
   let l_CodigoResposta    = ""
   let l_TextoResposta     = ""
   let l_CodigoQuestao2    = ""
   let l_CodigoResposta2   = ""
   let l_TextoResposta2    = ""


   if m_poe <> 1 then

      if w_prporgidv = "00" or w_prporgidv = " " or w_prporgidv is null then
         let w_prporgidv = r_apamcapa.prporgpcp
         let w_prpnumidv = r_apamcapa.prpnumpcp
      end if

      open c_ccty21g03040_2 using  r_apamcapa.prporgpcp
                           ,r_apamcapa.prpnumpcp
                           ,w_prporgidv
                           ,w_prpnumidv
      fetch c_ccty21g03040_2 into l_cncpoeflg

      initialize l_literal_flgpoe to null

      if l_cncpoeflg = "S" then
         let l_literal_flgpoe = "SIM"
      else
         if l_cncpoeflg = "N" then
            let l_literal_flgpoe = "NAO"
         end if
      end if

      let l_PoeConcorrencia = l_literal_flgpoe

      let m_poe = 1

   end if


   let l_CodigoReg   = linha[13,14]
   let l_TipoProduto = linha[15,16]

   let l_qstcod = linha[17,19] clipped

   call ccty21g03_questao(l_qstcod)
         returning l_qstdes
                  ,l_qstrsptip

   let l_CodigoQuestao = linha[17,19],"-",l_qstdes
   let l_rspcod = linha[20,22]

   if l_rspcod is not null and l_rspcod <> " " and l_rspcod <> "000" then
       let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
       let l_CodigoResposta = linha[20,22],"-",l_qstrspdsc
   end if

   if l_qstcod = 991 then
      let l_codemp = linha[23,65] clipped
      let l_qstrspdsc = ccty21g03_desc_emp(l_codemp)
      let l_TextoResposta = l_codemp, "-",l_qstrspdsc clipped
   else
      let l_TextoResposta = linha[23,65]
   end if


   let l_qstcod = linha[69,71] clipped

   call ccty21g03_questao(l_qstcod)
        returning l_qstdes
                 ,l_qstrsptip


   let l_CodigoQuestao2 = linha[69,71],"-",l_qstdes
   let l_rspcod = linha[72,74]

   if l_rspcod is not null and l_rspcod <> " " and l_rspcod <> "000"  then
      let l_qstrspdsc = ccty21g03_resposta(l_qstcod, l_rspcod, l_qstrsptip)
      let l_CodigoResposta2 = linha[72,74],"-",l_qstrspdsc
   end if

   let l_TextoResposta2 = linha[75,117]


   begin work

      insert into tmp_20 ( SeqProposta
                          ,Seq
                          ,PoeConcorrencia
                          ,CodigoReg
                          ,TipoProduto)
                  values ( m_flag_proposta
                          ,m_count20
                          ,l_PoeConcorrencia
                          ,l_CodigoReg
                          ,l_TipoProduto)

      if l_CodigoQuestao is not null and
         l_CodigoQuestao <> " " then
            insert into tmp_20a ( SeqProposta
                             ,CodigoQuestao
                             ,CodigoResposta
                             ,TextoResposta)
                     values ( m_flag_proposta
                             ,l_CodigoQuestao
                             ,l_CodigoResposta
                             ,l_TextoResposta)
      end if

      if l_CodigoQuestao2 is not null and
         l_CodigoQuestao2 <> " " then
            insert into tmp_20a ( SeqProposta
                             ,CodigoQuestao
                             ,CodigoResposta
                             ,TextoResposta)
                     values ( m_flag_proposta
                             ,l_CodigoQuestao2
                             ,l_CodigoResposta2
                             ,l_TextoResposta2)
      end if

   commit work

   let m_count20 = m_count20 + 1

end function

#-------------------------------------
function ccty21g03_reg_21() # CONDUTOR
#-------------------------------------

    define l_CodigoReg    char(2)
          ,l_nome         char(40)
          ,l_cpf          char(15)
          ,l_seqcdt       char(2)
          ,l_rgcdt        char(15)
          ,l_cnhcdt       char(15)
          ,l_catcnhcdt    char(15)
          ,l_espcdt       char(5)

    let l_CodigoReg    =  ''
    let l_nome         =  ''
    let l_cpf          =  ''
    let l_seqcdt       =  ''
    let l_rgcdt        =  ''
    let l_cnhcdt       =  ''
    let l_catcnhcdt    =  ''
    let l_espcdt       =  ''

    let l_CodigoReg    = linha[13,14]
    let l_nome         = linha[15,54]
    let l_cpf          = linha[55,66], "-"clipped, linha[67,68]
    let l_seqcdt       = linha[69,70]
    let l_rgcdt        = linha[71,85]
    let l_cnhcdt       = linha[86,100]
    let l_catcnhcdt    = linha[101,115]
    let l_espcdt       = linha[116,120]

   -------------------------------------------
    let l_CodigoReg    =  l_CodigoReg clipped
    let l_nome         =  l_nome      clipped
    let l_cpf          =  l_cpf       clipped
    let l_seqcdt       =  l_seqcdt    clipped
    let l_rgcdt        =  l_rgcdt     clipped
    let l_cnhcdt       =  l_cnhcdt    clipped
    let l_catcnhcdt    =  l_catcnhcdt clipped
    let l_espcdt       =  l_espcdt    clipped
   -------------------------------------------

    begin work
      insert into tmp_21 (  SeqProposta
                          , Seq
                          , CodigoReg
                          , Nome
                          , CPF
                          , seqcdt
                          , Rg
                          , CNH
                          , CATCNH
                          , Espaco      )

                  values (  m_flag_proposta
                          , m_count21
                          , l_CodigoReg
                          , l_nome
                          , l_cpf
                          , l_seqcdt
                          , l_rgcdt
                          , l_cnhcdt
                          , l_catcnhcdt
                          , l_espcdt   )
    commit work

    let m_count21 = m_count21 + 1



end function

#-------------------------------------#
function ccty21g03_reg_22() #REGISTRO DE DESCONTOS E AGRAVO
#-------------------------------------#

 define l_cndeslcod       like aggkcndesl.cndeslcod
 define l_cndeslnom       like aggkcndesl.cndeslnom

 define l_CodigoReg  char(2)
       ,l_CodDesconto   char(100)
       ,l_CoeficienteSemPremio     char(8)
       ,l_CodDesconto2   char(100)
       ,l_CoeficienteSemPremio2     char(8)
       ,l_CodDesconto3   char(100)
       ,l_CoeficienteSemPremio3     char(8)
       ,l_CodDesconto4   char(100)
       ,l_CoeficienteSemPremio4     char(8)
       ,l_CodDesconto5   char(100)
       ,l_CoeficienteSemPremio5     char(8)
       ,l_CodDesconto6   char(100)
       ,l_CoeficienteSemPremio6     char(8)
       ,l_CodDesconto7   char(100)
       ,l_CoeficienteSemPremio7     char(8)
       ,l_CodDesconto8   char(100)
       ,l_CoeficienteSemPremio8     char(8)
       ,l_CodDesconto9   char(100)
       ,l_CoeficienteSemPremio9     char(8)
       ,l_CodDesconto10  char(100)
       ,l_CoeficienteSemPremio10    char(8)
       ,l_CodDesconto11  char(100)
       ,l_CoeficienteSemPremio11    char(8)
       ,l_CodDesconto12  char(100)
       ,l_CoeficienteSemPremio12    char(8)
       ,l_CodDesconto13  char(100)
       ,l_CoeficienteSemPremio13    char(8)
       ,l_CodDesconto14  char(100)
       ,l_CoeficienteSemPremio14    char(8)
       ,l_CodDesconto15  char(100)
       ,l_CoeficienteSemPremio15    char(8)
       ,l_espaco     char(1)


       let l_CodigoReg     = ''
       let l_CodDesconto   = ''
       let l_CoeficienteSemPremio    = ''
       let l_CodDesconto2  = ''
       let l_CoeficienteSemPremio2    = ''
       let l_CodDesconto3  = ''
       let l_CoeficienteSemPremio3    = ''
       let l_CodDesconto4  = ''
       let l_CoeficienteSemPremio4    = ''
       let l_CodDesconto5  = ''
       let l_CoeficienteSemPremio5    = ''
       let l_CodDesconto6  = ''
       let l_CoeficienteSemPremio6    = ''
       let l_CodDesconto7  = ''
       let l_CoeficienteSemPremio7    = ''
       let l_CodDesconto8  = ''
       let l_CoeficienteSemPremio8    = ''
       let l_CodDesconto9  = ''
       let l_CoeficienteSemPremio9    = ''
       let l_CodDesconto10 = ''
       let l_CoeficienteSemPremio10   = ''
       let l_CodDesconto11 = ''
       let l_CoeficienteSemPremio11   = ''
       let l_CodDesconto12 = ''
       let l_CoeficienteSemPremio12   = ''
       let l_CodDesconto13 = ''
       let l_CoeficienteSemPremio13   = ''
       let l_CodDesconto14 = ''
       let l_CoeficienteSemPremio14   = ''
       let l_CodDesconto15 = ''
       let l_CoeficienteSemPremio15   = ''
       let l_espaco    = ''




       let l_cndeslcod = 0
       let l_cndeslnom = ""


       let l_CodigoReg  = linha[13,14]



    if linha[15,17] <>  " " then
       let l_cndeslcod = linha[15,17]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto  = linha[15,17],"-",l_cndeslnom
       let l_CoeficienteSemPremio    = linha[18,18],",",linha[19,22]," %"
    end if

    if linha[23,25] <>  " " then
       let l_cndeslcod = linha[23,25]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto2  =  linha[23,25],"-",l_cndeslnom
       let l_CoeficienteSemPremio2    =  linha[26,26],",",linha[27,30], " %"

    end if

    if linha[31,33] <>  " " then
       let l_cndeslcod = linha[31,33]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto3  = linha[31,33] ,"-",l_cndeslnom
       let l_CoeficienteSemPremio3    = linha[34,34],",", linha[35,38], " %"
    end if

    if linha[39,41] <>  " " then
       let l_cndeslcod = linha[39,41]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto4  =  linha[39,41],"-",l_cndeslnom
       let l_CoeficienteSemPremio4    =  linha[42,42],",", linha[43,46], " %"
    end if

    if linha[47,49] <>  " " then
       let l_cndeslcod = linha[47,49]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto5  =  linha[47,49],"-",l_cndeslnom
       let l_CoeficienteSemPremio5    =  linha[50,50],",", linha[51,54]," %"
    end if

    if linha[55,57] <>  " " then
       let l_cndeslcod = linha[55,57]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto6  =  linha[55,57],"-",l_cndeslnom
       let l_CoeficienteSemPremio6    =  linha[58,58],",", linha[59,62], " %"

    end if

    if linha[63,65] <>  " " then
       let l_cndeslcod = linha[63,65]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto7  =  linha[63,65],"-",l_cndeslnom
       let l_CoeficienteSemPremio7    =  linha[66,66],",", linha[67,70], " %"
    end if

    if linha[71,73] <>  " " then
       let l_cndeslcod = linha[71,73]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto8  =  linha[71,73],"-",l_cndeslnom
       let l_CoeficienteSemPremio8    =  linha[74,74],",", linha[75,78], " %"
    end if

    if linha[79,81] <>  " " then
       let l_cndeslcod = linha[79,81]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto9  =  linha[79,81],"-",l_cndeslnom
       let l_CoeficienteSemPremio9    =  linha[82,82],",", linha[83,86]," %"

    end if

    if linha[87,89] <>  " " then
       let l_cndeslcod = linha[87,89]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto10  =  linha[87,89],"-",l_cndeslnom
       let l_CoeficienteSemPremio10    =  linha[90,90],",", linha[91,94], " %"

    end if

    if linha[95,97] <>  " " then
       let l_cndeslcod = linha[95,97]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto11  = linha[95,97],"-",l_cndeslnom
       let l_CoeficienteSemPremio11    = linha[98,98],",", linha[99,102], " %"

    end if

    if linha[103,105] <>  " " then
       let l_cndeslcod = linha[103,105]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto12  =  linha[103,105],"-",l_cndeslnom
       let l_CoeficienteSemPremio12    =  linha[106,106],",", linha[107,110], " %"

    end if

    if linha[111,113] <>  " " then
       let l_cndeslcod = linha[111,113]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto13  =  linha[111,113],"-",l_cndeslnom
       let l_CoeficienteSemPremio13    =  linha[114,114],",",linha[115,118], " %"

    end if

    if linha[119,121] <>  " " then
       let l_cndeslcod = linha[119,121]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto14  = linha[119,121],"-",l_cndeslnom
       let l_CoeficienteSemPremio14    = linha[122,122],",", linha[123,126], " %"

    end if

    if linha[127,129] <>  " " then
       let l_cndeslcod = linha[127,129]
       let l_cndeslnom = ccty21g03_desconto(l_cndeslcod)
       let l_CodDesconto15  =  linha[127,129],"-",l_cndeslnom
       let l_CoeficienteSemPremio15    =  linha[130,130],",", linha[131,134], " %"
    end if

    let l_espaco  = linha[135,135]

    ---------------------------------------
     let l_CodigoReg = l_CodigoReg clipped
     let l_CodDesconto  = l_CodDesconto  clipped
     let l_CoeficienteSemPremio    = l_CoeficienteSemPremio    clipped
     let l_CodDesconto2  = l_CodDesconto2  clipped
     let l_CoeficienteSemPremio2    = l_CoeficienteSemPremio2    clipped
     let l_CodDesconto3  = l_CodDesconto3  clipped
     let l_CoeficienteSemPremio3    = l_CoeficienteSemPremio3    clipped
     let l_CodDesconto4  = l_CodDesconto4  clipped
     let l_CoeficienteSemPremio4    = l_CoeficienteSemPremio4    clipped
     let l_CodDesconto5  = l_CodDesconto5  clipped
     let l_CoeficienteSemPremio5    = l_CoeficienteSemPremio5    clipped
     let l_CodDesconto6  = l_CodDesconto6  clipped
     let l_CoeficienteSemPremio6    = l_CoeficienteSemPremio6    clipped
     let l_CodDesconto7  = l_CodDesconto7  clipped
     let l_CoeficienteSemPremio7    = l_CoeficienteSemPremio7    clipped
     let l_CodDesconto8  = l_CodDesconto8  clipped
     let l_CoeficienteSemPremio8    = l_CoeficienteSemPremio8    clipped
     let l_CodDesconto9  = l_CodDesconto9  clipped
     let l_CoeficienteSemPremio9    = l_CoeficienteSemPremio9    clipped
     let l_CodDesconto10 = l_CodDesconto10 clipped
     let l_CoeficienteSemPremio10   = l_CoeficienteSemPremio10   clipped
     let l_CodDesconto11 = l_CodDesconto11 clipped
     let l_CoeficienteSemPremio11   = l_CoeficienteSemPremio11   clipped
     let l_CodDesconto12 = l_CodDesconto12 clipped
     let l_CoeficienteSemPremio12   = l_CoeficienteSemPremio12   clipped
     let l_CodDesconto13 = l_CodDesconto13 clipped
     let l_CoeficienteSemPremio13   = l_CoeficienteSemPremio3   clipped
     let l_CodDesconto14 = l_CodDesconto14 clipped
     let l_CoeficienteSemPremio14   = l_CoeficienteSemPremio14   clipped
     let l_CodDesconto15 = l_CodDesconto15 clipped
     let l_CoeficienteSemPremio15   = l_CoeficienteSemPremio15   clipped
     let l_espaco    = l_espaco    clipped
    ---------------------------------------

    begin work


      if l_CodDesconto is not null and
         l_CodDesconto <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto
                             , l_CoeficienteSemPremio)
      end if
      if l_CodDesconto2 is not null and
         l_CodDesconto2 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto2
                             , l_CoeficienteSemPremio2)
      end if
      if l_CodDesconto3 is not null and
         l_CodDesconto3 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto3
                             , l_CoeficienteSemPremio3)
      end if
      if l_CodDesconto4 is not null and
         l_CodDesconto4 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto4
                             , l_CoeficienteSemPremio4)
      end if

      if l_CodDesconto5 is not null and
         l_CodDesconto5 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto5
                             , l_CoeficienteSemPremio5)
      end if
      if l_CodDesconto6 is not null and
         l_CodDesconto6 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto6
                             , l_CoeficienteSemPremio6)
      end if
      if l_CodDesconto7 is not null and
         l_CodDesconto7 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto7
                             , l_CoeficienteSemPremio7)
      end if
      if l_CodDesconto8 is not null and
         l_CodDesconto8 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto8
                             , l_CoeficienteSemPremio8)
      end if
      if l_CodDesconto9 is not null and
         l_CodDesconto9 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto9
                             , l_CoeficienteSemPremio9)
      end if
      if l_CodDesconto10 is not null and
         l_CodDesconto10 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto10
                             , l_CoeficienteSemPremio10)
      end if
      if l_CodDesconto11 is not null and
         l_CodDesconto11 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto11
                             , l_CoeficienteSemPremio11)
      end if
      if l_CodDesconto12 is not null and
         l_CodDesconto12 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto12
                             , l_CoeficienteSemPremio12)
      end if
      if l_CodDesconto13 is not null and
         l_CodDesconto13 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto13
                             , l_CoeficienteSemPremio13)
      end if
      if l_CodDesconto14 is not null and
         l_CodDesconto14 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto14
                             , l_CoeficienteSemPremio14)
      end if
      if l_CodDesconto15 is not null and
         l_CodDesconto15 <> " " then
         insert into tmp_22 (  SeqProposta
                             , CodDesconto
                             , CoeficienteSemPremio)
                     values (  m_flag_proposta
                             , l_CodDesconto15
                             , l_CoeficienteSemPremio15)
      end if

    commit work

    let m_count22 = m_count22 + 1


end function

#------------------------------------#
function ccty21g03_reg_24() # NEGOCIACAO DE ACEITACAO
#------------------------------------#

    define l_CodigoReg char(2)
    define l_numacei   char(10)

    #Mostra na tela Informacao sobre Aceitacao

       let l_codigoReg = ''
       let l_numacei   = ''


       let l_codigoReg = linha[13,14]
       let l_numacei   = linha[17,26]


       begin work
           insert into tmp_24 (SeqProposta,Seq, CodigoReg, numacei )
                values (  m_flag_proposta, m_count24, l_CodigoReg, l_numacei  )



       commit work

       let m_count24 = m_count24 + 1

 end function

#-------------------------------------
#function ccty21g03_reg_25()
#-------------------------------------
#
#end function

#-------------------------------------
function ccty21g03_reg_27() #ID DO CARTAO PORTO VISA
#-------------------------------------

 define l_CodigoReg char(2)
       ,l_idcartao  char(11)

 let l_CodigoReg = ''
 let l_idcartao  = ''

 let l_CodigoReg   =  linha[13,14]
 let l_idcartao  =  linha[15,25]

       begin work
           insert into tmp_27 (SeqProposta,Seq, CodigoReg, idcartao )
                values (  m_flag_proposta, m_count27, l_CodigoReg, l_idcartao  )



       commit work

       let m_count27 = m_count27 + 1



end function

#-------------------------------------
function ccty21g03_reg_29() #FINALIDADE DE EMISSAO
#-------------------------------------

 define l_CodigoReg     char(2)
        ,l_finalidade   char(18)
        ,l_encargos     char(18)
        ,l_totalbruto   char(18)
        ,l_espaco       char(62)

    let l_CodigoReg  = ''
    let l_finalidade = ''
    let l_encargos   = ''
    let l_totalbruto = ''
    let l_espaco     = ''

    let l_Codigoreg = linha[13,14]

    if linha[15,15] = "-" then

       let l_finalidade  = linha[15,25] clipped,","clipped, linha[26,30]

       if linha[31,31] = '-' then

          let l_encargos  = linha[31,41] clipped,","clipped, linha[42,46]

          if linha[47,47] = '-' then
             let l_totalbruto  = linha[47,57] clipped,","clipped, linha[58,62]
          else
             let l_totalbruto  = linha[47,56] clipped,","clipped, linha[57,61]
          end if
       else
          let l_encargos  = linha[31,39] clipped,","clipped, linha[40,45]

          if linha[46,46] = '-' then
             let l_totalbruto  = linha[46,56] clipped,",", linha[57,61]

          else
             let l_totalbruto  = linha[46,55] clipped,","clipped, linha[56,60]
          end if
       end if
    else
       let l_finalidade  = linha[15,24] clipped,","clipped, linha[25,29]

       if linha[30,30] = '-' then
          let l_encargos  = linha[30,40] clipped,","clipped, linha[41,45]

          if linha[46,46] = '-' then
             let l_totalbruto  = linha[46,56] clipped,","clipped, linha[57,61]
          else
             let l_totalbruto  = linha[46,55] clipped,","clipped, linha[56,60]
          end if
       else
          let l_encargos  = linha[30,39] clipped,","clipped, linha[40,44]

          if linha[45,45] = '-' then
             let l_totalbruto  = linha[45,55] clipped,","clipped, linha[56,60]
          else
             let l_totalbruto  = linha[45,54] clipped,","clipped, linha[55,59]
          end if
       end if
    end if


    let l_espaco  =  linha[60,120]


       begin work
           insert into tmp_29 (SeqProposta
                               ,Seq
                               ,CodigoReg
                               ,Finalidade
                               ,encargos
                               ,totalbruto
                               ,espaco
                               )
           values (  m_flag_proposta
                     ,m_count29
                     ,l_CodigoReg
                     ,l_finalidade
                     ,l_encargos
                     ,l_totalbruto
                     ,l_espaco  )



       commit work

       let m_count29 = m_count29 + 1


end function

#-------------------------------------
function ccty21g03_reg_30() # INFORMACOES CARTAO
#-------------------------------------

  define  l_CodigoReg    char(2)
         ,l_Debito       char(1)
         ,l_banco        char(4)
         ,l_agencia      char(5)
         ,l_conta        char(15)
         ,l_contadig     char(5)
         ,l_seguroroubo  char(1)
         ,l_CPF          char(20)
         ,l_nome         char(40)
         ,l_data         char(10)
         ,l_parentesco   char(1)
         ,l_sexo         char(1)


    let l_Debito       = ''
    let l_banco        = ''
    let l_agencia      = ''
    let l_conta        = ''
    let l_contadig     = ''
    let l_seguroroubo  = ''
    let l_CPF          = ''
    let l_nome         = ''
    let l_data         = ''
    let l_parentesco   = ''
    let l_sexo         = ''

    let l_Debito       = linha[116,116]
    let l_banco        = linha[15,18]
    let l_agencia      = linha[19,23]
    let l_conta        = linha[24,38]
    let l_contadig     = linha[39,43]
    let l_seguroroubo  = linha[64,64]
    let l_CPF          = linha[44,63]
    let l_nome         = linha[65,104]
    let l_data         = linha[105,114]
    let l_parentesco   = linha[115,115]
    let l_sexo         = linha[117,117]

     begin work
         insert into tmp_30 (SeqProposta
                             ,Seq
                             ,CodigoReg
                             ,Debito
                             ,Banco
                             ,Agencia
                             ,Conta
                             ,Contadig
                             ,Seguroroubo
                             ,CPF
                             ,Nome
                             ,Data
                             ,Parentesco
                             ,Sexo)
         values (  m_flag_proposta
                   ,m_count30
                   ,l_CodigoReg
                   ,l_Debito
                   ,l_Banco
                   ,l_Agencia
                   ,l_Conta
                   ,l_Contadig
                   ,l_Seguroroubo
                   ,l_CPF
                   ,l_Nome
                   ,l_Data
                   ,l_Parentesco
                   ,l_Sexo)


     commit work

     let m_count30 = m_count30 + 1



end function

#-------------------------------------
function ccty21g03_reg_31() #CUSTO DE APOLICE
#-------------------------------------
 define l_aux             char(10)
        ,l_parc1           char(20)
        ,l_demais          char(20)
        ,l_codigoReg       char(2)
        ,l_custoaplanual   char(15)
        ,l_coefIOF         char(15)
        ,l_premiovista     char(15)
        ,l_taxacasco       char(9)
        ,l_tiposeg         char(1)
        ,l_vlrparc1        char(15)
        ,l_vlrdemais       char(15)
        ,l_vlrjuros        char(15)
        ,l_espaco          char(6)

      let l_aux           = ''
      let l_parc1         = ''
      let l_demais        = ''
      let l_codigoReg     = ''
      let l_custoaplanual = ''
      let l_coefIOF       = ''
      let l_premiovista   = ''
      let l_taxacasco     = ''
      let l_tiposeg       = ''
      let l_vlrparc1      = ''
      let l_vlrdemais     = ''
      let l_vlrjuros      = ''
      let l_espaco        = ''

       let l_codigoReg  =  linha[13,14]
       let l_aux = ccty21g03_valores(linha[15,24])
       let l_custoaplanual  = l_aux clipped,",", linha[25,29]
       let l_aux = ccty21g03_valores(linha[30,39])
       let l_coefIOF  =  l_aux clipped,",", linha[40,44]
       let l_aux = ccty21g03_valores(linha[45,54])
       let l_premiovista  = l_aux clipped,",", linha[55,59]
       let l_aux = ccty21g03_valores(linha[60,62])
       let l_taxacasco   = l_aux clipped,",", linha[63,68]
       let l_tiposeg     = linha[69,69]


       if linha[70,70] = "-" then
          let l_parc1 = linha[70,80],",",linha[81,85]
          if linha[86,86] = "-" then
             let l_demais  = linha[86,97],",",linha[98,101]
          else
             let l_demais  = linha[86,94],",",linha[95,100]
          end if
       else
          let l_parc1 = linha[70,79],',',linha[80,84]
          if  linha[85,85] = "-" then
              let l_demais = linha[85,96],',',linha[97,100]
          else
              let l_demais = linha[85,94],',',linha[95,99]
          end if
       end if
       let l_vlrparc1  = l_parc1 clipped
       let l_vlrdemais  =  l_demais clipped
       let l_aux = ccty21g03_valores(linha[100,109])
       let l_vlrjuros  =  l_aux clipped,",", linha[110,114]
       let l_espaco  =  linha[115,120]

        begin work
         insert into tmp_31 ( SeqProposta
                             ,Seq
                             ,CodigoReg
                             ,custoaplanual
                             ,coefIOF
                             ,premiovista
                             ,taxacasco
                             ,tiposeg
                             ,vlrparc1
                             ,vlrdemais
                             ,vlrjuros
                             ,espaco)
         values (  m_flag_proposta
                   ,m_count31
                   ,l_CodigoReg
                   ,l_custoaplanual
                   ,l_coefIOF
                   ,l_premiovista
                   ,l_taxacasco
                   ,l_tiposeg
                   ,l_vlrparc1
                   ,l_vlrdemais
                   ,l_vlrjuros
                   ,l_espaco )


     commit work

     let m_count31 = m_count31 + 1




end function

#-------------------------------------
function ccty21g03_reg_32() #COMPLEMENTO DE DADOS
#-------------------------------------

  define l_CodigoReg    char(2)
         ,l_RG           char(10)
         ,l_Cnh          char(15)
         ,l_catcnh       char(15)
         ,l_email        char(60)
         ,l_tpenviofront char(12)
         ,l_espaco       char(5)



    let l_RG            = null
    let l_Cnh           = null
    let l_catcnh        = null
    let l_email         = null
    let l_tpenviofront  = null
    let l_espaco        = null

    let l_CodigoReg   =  linha[13,14]
    let l_RG          =  linha[15,24]
    let l_Cnh         =  linha[25,39]
    let l_catcnh      =  linha[40,54]
    let l_email       =  linha[55,114]


    # -- RECUPERA TIPO E E_MAIL DE ENVIO DO FRONT -- #
    if linha[115,115] = 1 then
       let l_tpenviofront  =  linha[115,115] clipped, "-Eletronico"
    else
       let l_tpenviofront  =  linha[115,115] clipped, "-Fisico"
    end if


    let l_espaco  = linha[116,120]

     begin work
         insert into tmp_32 ( SeqProposta
                             ,Seq
                             ,CodigoReg
                             ,RG
                             ,Cnh
                             ,catcnh
                             ,email
                             ,tpenviofront
                             ,espaco    )
         values (  m_flag_proposta
                   ,m_count32
                   ,l_CodigoReg
                   ,l_RG
                   ,l_Cnh
                   ,l_catcnh
                   ,l_email
                   ,l_tpenviofront
                   ,l_espaco      )

     commit work

     let m_count32 = m_count32 + 1



end function

#---------------------------------------------------------------------------#
function ccty21g03_reg_34()
#---------------------------------------------------------------------------#
 define l_prfcod   smallint
 define l_prfdes   char(60)
 define l_viginc   date
 #PSI243957 - INICIO
 define l_preanalise char(01)
 define l_analise smallint

 let l_preanalise = null
 let l_analise = 0
 #PSI243957 - FIM
   let l_prfdes    = ""

   let i = i + 1
   let ccty21g03_tela[i]  = "------- COMPLEMENTO DO SEGURADO ----------"
   let i = i + 1
   let ccty21g03_tela[i]  = "Codigo do Registro..:  "clipped, linha[13,14]
   let i = i + 1
   let ccty21g03_tela[i]  = "Tipo do Documento...:  "clipped, linha[15,15]
   let i = i + 1
   let ccty21g03_tela[i]  = "Orgao Expedidor.....:  "clipped, linha[16,45]
   let i = i + 1
   let ccty21g03_tela[i]  = "Data de Expedicao...:  "clipped, linha[46,55]
   let i = i + 1
   #PSI 190586

   let w_pepres = linha[114,114] # PSI 254371 - Tarifa Abril/2010

   let l_prfcod = linha[56,61]
   let l_viginc = m_viginc
   let l_prfdes = ccty21g03_atividade(l_prfcod, l_viginc)
   let ccty21g03_tela[i] = "Atividade/Profissao.:  "clipped,  linha[56,61]
      ," - ",l_prfdes
   #PSI244619 - INICIO------#
   if w_pestip = "F" or w_pestip = "f" then
    let w_profissao = l_prfcod
   else
    let w_profissao = null
   end if
   #PSI244619 - FINAL-------#
   let i = i + 1
   let ccty21g03_tela[i]  = "Espaco..............:  "clipped, linha[107,120]
   let i = i + 1
   let ccty21g03_tela[i]  = "Faixa de Rendimento.:  "clipped, linha[65,66]
   let i = i + 1
   let ccty21g03_tela[i]  = "Dia de Vecto Fatura.:  "clipped, linha[63,64]
   let i = i + 1
   let ccty21g03_tela[i]  = "Nome da Mae.........:  "clipped, linha[67,106]
   let i = i + 1
   #PSI243957 - INICIO

   #psi261378 inicio
   #(dados do registro 70)
   let ccty21g03_tela[i]  = "Nome do Pai.........:  "clipped, m_linha70[15,54]
   let i = i + 1
   let ccty21g03_tela[i]  = "Nome do Conjuge.....:  "clipped, m_linha70[55,94]
   let i = i + 1

   #(dados do registro 71)
   let ccty21g03_tela[i]  = "Nacionalidade.......:  "clipped, m_linha71[15,44]
   let i = i + 1
   let ccty21g03_tela[i]  = "Naturalidade........:  "clipped, m_linha71[45,89]
   let i = i + 1
   let ccty21g03_tela[i]  = "UF..................:  "clipped, m_linha71[90,91]
   let i = i + 1

   #psi261378 fim
   let l_analise = linha[107,107]
   if l_analise = 3 then
    let l_preanalise = "S"
   else
    let l_preanalise = "N"
   end if
   let ccty21g03_tela[i]  = "Recusado Pre Analise 1ªCompra:  "clipped, l_preanalise
   let i = i + 1

#PSI243957 - FIM
   let m_pont_resgate = linha[108,113]

   if r_apamcapa.rnvsuccod is not null and
      r_apamcapa.rnvsuccod <> 0        and
      r_apamcapa.rnvaplnum is not null and
      r_apamcapa.rnvaplnum <> 0        and
      r_apamcapa.pgtfrm = 97 then

    let m_pont_resgate_s = m_pont_resgate

      #  call ffpfc295_saldo_valor(r_apamcapa.prporgpcp,r_apamcapa.prpnumpcp)
     #  returning l_retcartao.*

    if l_retcartao.rgtvlr <> 0 and l_retcartao.rgtvlr is not null then
     let m_rgtvlr = l_retcartao.rgtvlr
       let m_rgtvlr_s = m_rgtvlr
    else
     open c_ccty21g03040_1 using m_pont_resgate
     fetch c_ccty21g03040_1 into m_rgtvlr
           let m_rgtvlr_s = m_rgtvlr
    end if
    let ccty21g03_tela[i]  = "Pontos / Valores....:  "clipped,m_pont_resgate_s clipped ," / ",m_rgtvlr_s clipped,",00"
    let i = i + 1
   else
    if r_apamcapa.prporgpcp is not null and r_apamcapa.prporgpcp <> 0 and
     r_apamcapa.prpnumpcp is not null and  r_apamcapa.prpnumpcp <> 0 and
     r_apamcapa.pgtfrm = 97 then
      open cccty21g03renov using r_apamcapa.prporgpcp, r_apamcapa.prpnumpcp
      fetch cccty21g03renov into r_apamcapa.rnvsuccod, r_apamcapa.rnvaplnum

      if sqlca.sqlcode = 0 then
        if r_apamcapa.prporgpcp is not null and
            r_apamcapa.prpnumpcp is not null and
                  r_apamcapa.rnvsuccod is not null and
                  r_apamcapa.rnvaplnum is not null then
                    let m_pont_resgate_s = m_pont_resgate
             # call ffpfc295_saldo_valor(r_apamcapa.prporgpcp,r_apamcapa.prpnumpcp)
         # returning l_retcartao.*
          if l_retcartao.rgtvlr <> 0 and l_retcartao.rgtvlr is not null then
            let m_rgtvlr = l_retcartao.rgtvlr
            let m_rgtvlr_s = m_rgtvlr
          else
                open c_ccty21g03040_1 using m_pont_resgate
                fetch c_ccty21g03040_1 into m_rgtvlr
                let m_rgtvlr_s = m_rgtvlr
          end if
          let ccty21g03_tela[i]  = "Pontos / Valores....:  "clipped,m_pont_resgate_s clipped ," / ",m_rgtvlr_s clipped,",00"
          let i = i + 1
        end if
      end if
      end if
    end if

end function

#-------------------------------------
function ccty21g03_reg_35()#AGENCIA DE ANGARIACAO
#-------------------------------------

 define l_susep      like gcaksusep.corsus
 define l_cornom     like gcakcorr.cornom
 define  l_CodigoReg  char(2)
        ,l_codbanco   char(3)
        ,l_agencia    char(4)
        ,l_produtor   char(10)
        ,l_pontovenda char(10)
        ,l_postoserv  char(10)
        ,l_segcliente char(2)
        ,l_espaco     char(66)

 let l_susep = ""
 let l_cornom = ""
 let l_CodigoReg  = null
 let l_codbanco   = null
 let l_agencia    = null
 let l_produtor   = null
 let l_pontovenda = null
 let l_postoserv  = null
 let l_segcliente = null
 let l_espaco     = null


    let l_CodigoReg  =  linha[13,14]
    let l_codbanco   =  linha[15,17]
    let l_agencia    =  linha[18,22]
    let l_produtor   =  linha[23,32]
    let l_pontovenda =  linha[33,42]
    let l_postoserv  =  linha[43,52]
    let l_segcliente =  linha[53,54]
    let l_espaco     =  linha[55,120]

 begin work
     insert into tmp_35 ( SeqProposta
                         ,Seq
                         ,CodigoReg
                         ,codbanco
                         ,agencia
                         ,produtor
                         ,pontovenda
                         ,postoserv
                         ,segcliente
                         ,espaco    )

     values (  m_flag_proposta
               ,m_count35
               ,l_CodigoReg
               ,l_codbanco
               ,l_agencia
               ,l_produtor
               ,l_pontovenda
               ,l_postoserv
               ,l_segcliente
               ,l_espaco )


 commit work

 let m_count35 = m_count35 + 1


end function

#-------------------------------------
function ccty21g03_reg_36() # VIDA
#-------------------------------------
   define l_CodigoReg         char(2)
   define l_IsMorte           char(16)
   define l_IsInvalidez       char(16)
   define l_PremioLiqVidaInd  char(16)
   define l_Espaco            char(61)

   let l_CodigoReg         = ""
   let l_IsMorte           = ""
   let l_IsInvalidez       = ""
   let l_PremioLiqVidaInd  = ""
   let l_Espaco            = ""

   let l_CodigoReg         = linha[13,14]
   let l_IsMorte           = linha[15,24], ",", linha[25,29]
   let l_IsInvalidez       = linha[30,39], ",", linha[40,44]
   let l_PremioLiqVidaInd  = linha[45,54], ",", linha[55,59]
   let l_Espaco            = linha[60,120]

   begin work

      insert into tmp_36 ( SeqProposta
                          ,Seq
                          ,CodigoReg
                          ,IsMorte
                          ,IsInvalidez
                          ,PremioLiqVidaInd
                          ,Espaco)
                  values ( m_flag_proposta
                          ,m_count36
                          ,l_CodigoReg
                          ,l_IsMorte
                          ,l_IsInvalidez
                          ,l_PremioLiqVidaInd
                          ,l_Espaco)
   commit work

   let m_count36 = m_count36 + 1

end function

#-------------------------------------
function ccty21g03_reg_37() # BENEFICIARIOS DO SEGURO DE VIDA INDIVIDUAL
#-------------------------------------
   define l_CodigoReg            char(2)
   define l_NomeBeneficiario     char(50)
   define l_GrauParentesco       char(2)
   define l_Espaco               char(18)
   define l_ParticipBeneficiario char(6)
   define l_Espaco2              char(31)

   let l_CodigoReg            = ""
   let l_NomeBeneficiario     = ""
   let l_GrauParentesco       = ""
   let l_Espaco               = ""
   let l_ParticipBeneficiario = ""
   let l_Espaco2              = ""

   let l_CodigoReg            = linha[13,14]
   let l_NomeBeneficiario     = linha[15,64]
   let l_GrauParentesco       = linha[65,66]
   let l_Espaco               = linha[67,84]
   let l_ParticipBeneficiario = linha[85,87],",", linha[88,89]
   let l_Espaco2              = linha[90,120]

   begin work

      insert into tmp_37 ( SeqProposta
                          ,Seq
                          ,CodigoReg
                          ,NomeBeneficiario
                          ,GrauParentesco
                          ,Espaco
                          ,ParticipBeneficiario
                          ,Espaco2)
                  values ( m_flag_proposta
                          ,m_count37
                          ,l_CodigoReg
                          ,l_NomeBeneficiario
                          ,l_GrauParentesco
                          ,l_Espaco
                          ,l_ParticipBeneficiario
                          ,l_Espaco2)
   commit work

   let m_count37 = m_count37 + 1

end function


#-------------------------------------
function ccty21g03_reg_38() # ATENDIMENTOS
#-------------------------------------

   define l_CodigoReg         char(2)
   define l_DataAtendimento   char(10)
   define l_HoraAtendimento   char(5)
   define l_LocalAtendimento  char(50)
   define l_TipoServico       char(40)
   define l_Espaco            char(1)

   let l_CodigoReg         = ""
   let l_DataAtendimento   = ""
   let l_HoraAtendimento   = ""
   let l_LocalAtendimento  = ""
   let l_TipoServico       = ""
   let l_Espaco            = ""

   let l_CodigoReg         = linha[13,14]
   let l_DataAtendimento   = linha[15,24]
   let l_HoraAtendimento   = linha[25,29]
   let l_LocalAtendimento  = linha[30,79]
   let l_TipoServico       = linha[80,119]
   let l_Espaco            = linha[120,120]

   begin work

      insert into tmp_38 ( SeqProposta
                          ,Seq
                          ,CodigoReg
                          ,DataAtendimento
                          ,HoraAtendimento
                          ,LocalAtendimento
                          ,TipoServico
                          ,Espaco)
                  values ( m_flag_proposta
                          ,m_count38
                          ,l_CodigoReg
                          ,l_DataAtendimento
                          ,l_HoraAtendimento
                          ,l_LocalAtendimento
                          ,l_TipoServico
                          ,l_Espaco)
   commit work

   let m_count38 = m_count38 + 1

end function

#-------------------------------------
function ccty21g03_reg_39() # SERVICOS E OBSERVACOES
#-------------------------------------
   define l_CodigoReg         char(2)
   define l_TipoInformacao    char(2)
   define l_CodigoInformacao  char(4)
   define l_QtdeServico       char(2)
   define l_TextoComplementar char(98)

   let l_CodigoReg         = ""
   let l_TipoInformacao    = ""
   let l_CodigoInformacao  = ""
   let l_QtdeServico       = ""
   let l_TextoComplementar = ""

   let l_CodigoReg         = linha[13,14]
   let l_TipoInformacao    = linha[15,16]
   let l_CodigoInformacao  = linha[17,20]
   let l_QtdeServico       = linha[21,22]
   let l_TextoComplementar = linha[23,120]

   begin work

      insert into tmp_39 ( SeqProposta
                          ,Seq
                          ,CodigoReg
                          ,TipoInformacao
                          ,CodigoInformacao
                          ,QtdeServico
                          ,TextoComplementar)
                  values ( m_flag_proposta
                          ,m_count39
                          ,l_CodigoReg
                          ,l_TipoInformacao
                          ,l_CodigoInformacao
                          ,l_QtdeServico
                          ,l_TextoComplementar)
   commit work

   let m_count39 = m_count39 + 1

end function

#-------------------------------------
function ccty21g03_reg_40() # BLOCOS DE UM CONDOMINIO
#-------------------------------------
   define l_SequenciaLocal       char(2)
   define l_NumeroSeqRisco       char(6)
   define l_NomeBloco            char(60)
   define l_QtdePavimentos       char(2)
   define l_QtdeVagas            char(3)
   define l_TipoConstrucao       char(8)
   define l_QtdeAptosCondominio  char(3)
   define l_ValorRiscoDeclarado  char(15)

   let l_SequenciaLocal       = ""
   let l_NumeroSeqRisco       = ""
   let l_NomeBloco            = ""
   let l_QtdePavimentos       = ""
   let l_QtdeVagas            = ""
   let l_TipoConstrucao       = ""
   let l_QtdeAptosCondominio  = ""
   let l_ValorRiscoDeclarado  = ""

   let l_SequenciaLocal       = linha[13,14]
   let l_NumeroSeqRisco       = linha[15,20]
   let l_NomeBloco            = linha[21,80]
   let l_QtdePavimentos       = linha[81,82]
   let l_QtdeVagas            = linha[83,85]
   let l_TipoConstrucao       = linha[86,87],","clipped, linha[55,59]
   let l_QtdeAptosCondominio  = linha[88,90]
   let l_ValorRiscoDeclarado  = linha[91,105]

   begin work

      insert into tmp_40 ( SeqProposta
                          ,Seq
                          ,SequenciaLocal
                          ,NumeroSeqRisco
                          ,NomeBloco
                          ,QtdePavimentos
                          ,QtdeVagas
                          ,TipoConstrucao
                          ,QtdeAptosCondominio
                          ,ValorRiscoDeclarado)
                  values ( m_flag_proposta
                          ,m_count40
                          ,l_SequenciaLocal
                          ,l_NumeroSeqRisco
                          ,l_NomeBloco
                          ,l_QtdePavimentos
                          ,l_QtdeVagas
                          ,l_TipoConstrucao
                          ,l_QtdeAptosCondominio
                          ,l_ValorRiscoDeclarado)
   commit work

   let m_count40 = m_count40 + 1

end function



#-------------------------------------
function ccty21g03_reg_41() # PARCELAMENTO
#-------------------------------------
   define l_CodigoReg         char(2)
   define l_MeioPagamento     char(2)
   define l_NumeroParcela     char(2)
   define l_CartaoCredito     char(16)
   define l_VenctoCartao      char(6)
   define l_NumeroBanco       char(4)
   define l_NumeroAgencia     char(5)
   define l_ContaCorrente     char(15)
   define l_DigitoCC          char(5)
   define l_DataVencto        char(10)
   define l_ValorParcela      char(12)
   define l_ChequeNum         char(10)
   define l_PracaCheque       char(2)
   define l_CnpjCpfCC         char(20)

   let l_CodigoReg      = ""
   let l_MeioPagamento  = ""
   let l_NumeroParcela  = ""
   let l_CartaoCredito  = ""
   let l_VenctoCartao   = ""
   let l_NumeroBanco    = ""
   let l_NumeroAgencia  = ""
   let l_ContaCorrente  = ""
   let l_DigitoCC       = ""
   let l_DataVencto     = ""
   let l_ValorParcela   = ""
   let l_ChequeNum      = ""
   let l_PracaCheque    = ""
   let l_CnpjCpfCC      = ""

   let l_CodigoReg      = linha[13,14]
   let l_MeioPagamento  = linha[15,16]
   let l_NumeroParcela  = linha[17,18]
   let l_CartaoCredito  = linha[19,34]
   let l_VenctoCartao   = linha[35,40]
   let l_NumeroBanco    = linha[41,44]
   let l_NumeroAgencia  = linha[45,49]
   let l_ContaCorrente  = linha[50,64]
   let l_DigitoCC       = linha[65,69]
   let l_DataVencto     = linha[70,71],'/',linha[72,73],'/',linha[74,77]
   let l_ValorParcela   = linha[78,86],",",linha[87,88]
   let l_ChequeNum      = linha[89,98]
   let l_PracaCheque    = linha[99,100]
   let l_CnpjCpfCC      = linha[101,120]

   begin work

      insert into tmp_41 ( SeqProposta
                          ,Seq
                          ,CodigoReg
                          ,MeioPagamento
                          ,NumeroParcela
                          ,CartaoCredito
                          ,VenctoCartao
                          ,NumeroBanco
                          ,NumeroAgencia
                          ,ContaCorrente
                          ,DigitoCC
                          ,DataVencto
                          ,ValorParcela
                          ,ChequeNum
                          ,PracaCheque
                          ,CnpjCpfCC)
                  values ( m_flag_proposta
                          ,m_count41
                          ,l_CodigoReg
                          ,l_MeioPagamento
                          ,l_NumeroParcela
                          ,l_CartaoCredito
                          ,l_VenctoCartao
                          ,l_NumeroBanco
                          ,l_NumeroAgencia
                          ,l_ContaCorrente
                          ,l_DigitoCC
                          ,l_DataVencto
                          ,l_ValorParcela
                          ,l_ChequeNum
                          ,l_PracaCheque
                          ,l_CnpjCpfCC)
   commit work

   let m_count41 = m_count41 + 1

end function

#-------------------------------------
function ccty21g03_reg_42() # AUTO + VIDA
#-------------------------------------
   define l_CodigoReg      char(2)
   define l_Fumante        char(1)
   define l_CodigoOperacao char(3)
   define l_AtualMonetaria char(1)
   define l_NomeInformar   char(60)
   define l_Telefone       char(12)

   let l_CodigoReg      = ""
   let l_Fumante        = ""
   let l_CodigoOperacao = ""
   let l_AtualMonetaria = ""
   let l_NomeInformar   = ""
   let l_Telefone       = ""

   let l_CodigoReg      = "42"
   let l_Fumante        = linha[034,034]
   let l_CodigoOperacao = linha[035,037]
   let l_AtualMonetaria = linha[038,038]
   let l_NomeInformar   = linha[039,098]
   let l_Telefone       = linha[099,110]

   begin work

      insert into tmp_42 ( SeqProposta
                          ,Seq
                          ,CodigoReg
                          ,Fumante
                          ,CodigoOperacao
                          ,AtualMonetaria
                          ,NomeInformar
                          ,Telefone)
                  values ( m_flag_proposta
                          ,m_count42
                          ,l_CodigoReg
                          ,l_Fumante
                          ,l_CodigoOperacao
                          ,l_AtualMonetaria
                          ,l_NomeInformar
                          ,l_Telefone)
   commit work

   let m_count42 = m_count42 + 1

end function

#--------------------------#
function ccty21g03_reg_43() # VIDA (COMPLEMENTO)
#--------------------------#
   define l_CodigoReg               char(2)
   define l_Empresa                 char(30)
   define l_TempoAnosMeses          char(5)
   define l_Produto                 char(5)
   define l_Renda                   char(13)
   define l_Premio                  char(16)
   define l_QtdeParcelasAutoVida    char(2)
   define l_FormaPagtoRenovacao     char(45)
   define l_QtdeParcelasRenovacao   char(2)

   define l_pgtfrm          like gfbkfpag.pgtfrm
   define l_pgtfrmdes       like gfbkfpag.pgtfrmdes

   let l_CodigoReg               = ""
   let l_Empresa                 = ""
   let l_TempoAnosMeses          = ""
   let l_Produto                 = ""
   let l_Renda                   = ""
   let l_Premio                  = ""
   let l_QtdeParcelasAutoVida    = ""
   let l_FormaPagtoRenovacao     = ""
   let l_QtdeParcelasRenovacao   = ""

   let l_pgtfrm = 0
   let l_pgtfrmdes = ""
   let l_pgtfrm = linha[108,109]
   let l_pgtfrmdes = ccty21g03_formapgto(l_pgtfrm)

   let l_CodigoReg               = "43"
   let l_Empresa                 = linha[025,054]
   let l_TempoAnosMeses          = linha[055,056],"/", linha[057,058]
   let l_Produto                 = linha[059,063]
   let l_Renda                   = linha[064,073],",", linha[074,075]
   let l_Premio                  = linha[076,085],",", linha[086,090]
   let l_QtdeParcelasAutoVida    = linha[106,107]
   let l_FormaPagtoRenovacao     = linha[108,109],"-",l_pgtfrmdes
   let l_QtdeParcelasRenovacao   = linha[110,111]

   begin work

      insert into tmp_43  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,Empresa
                           ,TempoAnosMeses
                           ,Produto
                           ,Renda
                           ,Premio
                           ,QtdeParcelasAutoVida
                           ,FormaPagtoRenovacao
                           ,QtdeParcelasRenovacao)
                  values  ( m_flag_proposta
                           ,m_count43
                           ,l_CodigoReg
                           ,l_Empresa
                           ,l_TempoAnosMeses
                           ,l_Produto
                           ,l_Renda
                           ,l_Premio
                           ,l_QtdeParcelasAutoVida
                           ,l_FormaPagtoRenovacao
                           ,l_QtdeParcelasRenovacao)

   commit work

   let m_count43 = m_count43 + 1

end function

#--------------------------#
function ccty21g03_reg_44() # AUTO + VIDA (COBERTURAS)
#--------------------------#

   define l_CodigoReg      char(2)
   define l_AssistFuneral  char(1)
   define l_Cobertura1     char(16)
   define l_Cobertura2     char(16)
   define l_Cobertura3     char(16)
   define l_Cobertura4     char(16)
   define l_Cobertura5     char(16)

   let l_CodigoReg      = ""
   let l_AssistFuneral  = ""
   let l_Cobertura1     = ""
   let l_Cobertura2     = ""
   let l_Cobertura3     = ""
   let l_Cobertura4     = ""
   let l_Cobertura5     = ""

   let l_CodigoReg      = "44"
   let l_AssistFuneral  = linha[025]
   let l_Cobertura1     = linha[026,029], ",", linha[030,039]
   let l_Cobertura2     = linha[045,048], ",", linha[049,058]
   let l_Cobertura3     = linha[064,067], ",", linha[068,077]
   let l_Cobertura4     = linha[083,086], ",", linha[087,096]
   let l_Cobertura5     = linha[102,105], ",", linha[106,115]

   begin work

      insert into tmp_44  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,AssistFuneral)
                  values  ( m_flag_proposta
                           ,m_count44
                           ,l_CodigoReg
                           ,l_AssistFuneral)

      if l_Cobertura1 is not null and
         l_Cobertura1 <> " " then
         insert into tmp_44a ( SeqProposta
                              ,Cobertura)
                     values  ( m_flag_proposta
                              ,l_Cobertura1)
      end if
      if l_Cobertura2 is not null and
         l_Cobertura2 <> " " then
         insert into tmp_44a ( SeqProposta
                              ,Cobertura)
                     values  ( m_flag_proposta
                              ,l_Cobertura2)
      end if
      if l_Cobertura3 is not null and
         l_Cobertura3 <> " " then
         insert into tmp_44a ( SeqProposta
                              ,Cobertura)
                     values  ( m_flag_proposta
                              ,l_Cobertura3)
      end if
      if l_Cobertura4 is not null and
         l_Cobertura4 <> " " then
         insert into tmp_44a ( SeqProposta
                              ,Cobertura)
                     values  ( m_flag_proposta
                              ,l_Cobertura4)
      end if
      if l_Cobertura5 is not null and
         l_Cobertura5 <> " " then
         insert into tmp_44a ( SeqProposta
                              ,Cobertura)
                     values  ( m_flag_proposta
                              ,l_Cobertura5)
      end if
   commit work

   let m_count44 = m_count44 + 1

end function

#------------------------------------#
function ccty21g03_reg_45() # NEGOCIACAO DE CONCESSAO
#------------------------------------#

   define l_CodigoReg         char(2)
   define l_NumeroNegociacao  char(10)

   let l_CodigoReg         = ""
   let l_NumeroNegociacao  = ""

   let l_CodigoReg         = linha[13,14]
   let l_NumeroNegociacao  = linha[15,24]

   begin work

      insert into tmp_45  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,NumeroNegociacao)
                  values  ( m_flag_proposta
                           ,m_count45
                           ,l_CodigoReg
                           ,l_NumeroNegociacao)
   commit work

   let m_count45 = m_count45 + 1

 end function

#PSI243159 - INICIO
#-------------------------------------
function ccty21g03_reg_46() # ENDERECO DO CARTAO
#-------------------------------------
   define l_CodigoReg      char(2)
   define l_TipoEndereco   char(30)
   define l_TipoLogradouro char(30)
   define l_Logradouro     char(40)
   define l_Numero         char(5)
   define l_Complemento    char(15)
   define l_CEP            char(9)
   define l_Espaco         char(32)

   define l_endfld like gsakend.endfld
   define l_etpendtipdes like trakedctip.etpendtipdes
   define l_endlgdtip like gsakend.endlgdtip
   define l_endlgdtipdes like gsaktipolograd.endlgdtipdes

   let l_CodigoReg      = ""
   let l_TipoEndereco   = ""
   let l_TipoLogradouro = ""
   let l_Logradouro     = ""
   let l_Numero         = ""
   let l_Complemento    = ""
   let l_CEP            = ""
   let l_Espaco         = ""

   let l_endfld = linha[15,15]
   let l_etpendtipdes = ccty21g03_endereco(l_endfld)
   let l_endlgdtip = linha[16,20]
   let l_endlgdtipdes = ccty21g03_logradouro(l_endlgdtip)

   let l_CodigoReg      = linha[13,14]
   let l_TipoEndereco   = linha[15,15],"-",l_etpendtipdes
   let l_TipoLogradouro = linha[16,20]," - ",l_endlgdtipdes
   let l_Logradouro     = linha[21,60]
   let l_Numero         = linha[61,65]
   let l_Complemento    = linha[66,80]
   let l_CEP            = linha[81,85],"-", linha[86,88]
   let l_Espaco         = linha[89,120]

   begin work

      insert into tmp_46  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,TipoEndereco
                           ,TipoLogradouro
                           ,Logradouro
                           ,Numero
                           ,Complemento
                           ,CEP
                           ,Espaco)
                  values  ( m_flag_proposta
                           ,m_count46
                           ,l_CodigoReg
                           ,l_TipoEndereco
                           ,l_TipoLogradouro
                           ,l_Logradouro
                           ,l_Numero
                           ,l_Complemento
                           ,l_CEP
                           ,l_Espaco)
   commit work

   let m_count46 = m_count46 + 1

end function

#-------------------------------------
function ccty21g03_reg_47() # CLS. PARTICULAR/DECLARACOES
#-------------------------------------

   define l_TipoTexto      char(3)
   define l_SequenciaTexto char(2)
   define l_DescricaoTexto char(10)

   let l_TipoTexto      = ""
   let l_SequenciaTexto = ""
   let l_DescricaoTexto = ""

   let l_TipoTexto      = linha[13,15]
   let l_SequenciaTexto = linha[16,17]
   let l_DescricaoTexto = linha[30,39]

   begin work

      insert into tmp_47  ( SeqProposta
                           ,Seq
                           ,TipoTexto
                           ,SequenciaTexto
                           ,DescricaoTexto)
                  values  ( m_flag_proposta
                           ,m_count47
                           ,l_TipoTexto
                           ,l_SequenciaTexto
                           ,l_DescricaoTexto)
   commit work

   let m_count47 = m_count47 + 1

end function

#-------------------------------------
function ccty21g03_reg_48() # COMPLEMENTO DO ENDERECO - CARTAO
#-------------------------------------

    define l_FlagEndereco  char(1)
    define l_Bairro        char(20)
    define l_Cidade        char(20)
    define l_UF            char(2)
    define l_Email         char(60)
    define l_Espaco        char(3)

    let l_FlagEndereco  = ""
    let l_Bairro        = ""
    let l_Cidade        = ""
    let l_UF            = ""
    let l_Email         = ""
    let l_Espaco        = ""

    let l_FlagEndereco  = linha[15,15]
    let l_Bairro        = linha[16,35]
    let l_Cidade        = linha[36,55]
    let l_UF            = linha[56,57]
    let l_Email         = linha[58,117]
    let l_Espaco        = linha[118,120]

   begin work

      insert into tmp_48  ( SeqProposta
                           ,Seq
                           ,FlagEndereco
                           ,Bairro
                           ,Cidade
                           ,UF
                           ,Email
                           ,Espaco)
                  values  ( m_flag_proposta
                           ,m_count48
                           ,l_FlagEndereco
                           ,l_Bairro
                           ,l_Cidade
                           ,l_UF
                           ,l_Email
                           ,l_Espaco)
   commit work

   let m_count48 = m_count48 + 1

end function

#-------------------------------------
function ccty21g03_reg_49() # TELEFONES DO SEGURADO - CARTAO
#-------------------------------------
   define l_CodigoReg      char(2)
   define l_TipoTelefone   char(2)
   define l_DddTelefone    char(4)
   define l_NumeroTelefone char(10)
   define l_RamalTelefone  char(10)
   define l_Recados        char(40)
   define l_Espaco         char(40)

   let l_CodigoReg      = ""
   let l_TipoTelefone   = ""
   let l_DddTelefone    = ""
   let l_NumeroTelefone = ""
   let l_RamalTelefone  = ""
   let l_Recados        = ""
   let l_Espaco         = ""

   let l_CodigoReg      = linha[13,14]
   let l_TipoTelefone   = linha[15,16]
   let l_DddTelefone    = linha[17,20]
   let l_NumeroTelefone = linha[21,30]
   let l_RamalTelefone  = linha[31,40]
   let l_Recados        = linha[41,80]
   let l_Espaco         = linha[81,120]

   begin work

      insert into tmp_49  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,TipoTelefone
                           ,DddTelefone
                           ,NumeroTelefone
                           ,RamalTelefone
                           ,Recados
                           ,Espaco)
                  values  ( m_flag_proposta
                           ,m_count49
                           ,l_CodigoReg
                           ,l_TipoTelefone
                           ,l_DddTelefone
                           ,l_NumeroTelefone
                           ,l_RamalTelefone
                           ,l_Recados
                           ,l_Espaco)
   commit work

   let m_count49 = m_count49 + 1

end function

#-------------------------------------
function ccty21g03_reg_50() # PREMIOS PAGOS
#-------------------------------------
   define l_tpalt  char(15)

   define l_CodigoReg            char(2)
   define l_Veiculo              char(5)
   define l_AnoFabricacao        char(4)
   define l_AnoModelo            char(4)
   define l_Flag0Km              char(1)
   define l_Uso                  char(2)
   define l_Categoria            char(2)
   define l_QtdePassageiros      char(2)
   define l_PremioCasco          char(14)
   define l_PremioAcessorio      char(14)
   define l_PremioDM             char(14)
   define l_PremioDP             char(14)
   define l_PremioDMO            char(14)
   define l_PremioAPP            char(14)
   define l_AlteracaoCasco       char(18)
   define l_AlteracaoAcessorios  char(18)
   define l_AlteracaoDM          char(18)
   define l_AlteracaoDP          char(18)
   define l_AlteracaoDMO         char(18)
   define l_AlteracaoAPP         char(18)

   let l_CodigoReg            = ""
   let l_Veiculo              = ""
   let l_AnoFabricacao        = ""
   let l_AnoModelo            = ""
   let l_Flag0Km              = ""
   let l_Uso                  = ""
   let l_Categoria            = ""
   let l_QtdePassageiros      = ""
   let l_PremioCasco          = ""
   let l_PremioAcessorio      = ""
   let l_PremioDM             = ""
   let l_PremioDP             = ""
   let l_PremioDMO            = ""
   let l_PremioAPP            = ""
   let l_AlteracaoCasco       = ""
   let l_AlteracaoAcessorios  = ""
   let l_AlteracaoDM          = ""
   let l_AlteracaoDP          = ""
   let l_AlteracaoDMO         = ""
   let l_AlteracaoAPP         = ""

   let l_CodigoReg            = linha[13,14]
   let l_Veiculo              = linha[16,20]
   let l_AnoFabricacao        = linha[21,24]
   let l_AnoModelo            = linha[25,28]
   let l_Flag0Km              = linha[29,29]
   let l_Uso                  = linha[30,31]
   let l_Categoria            = linha[32,33]
   let l_QtdePassageiros      = linha[34,35]
   let l_PremioCasco          = linha[36,45],",",linha[46,47]
   let l_PremioAcessorio      = linha[48,57],",",linha[58,59]
   let l_PremioDM             = linha[60,69],",",linha[70,71]
   let l_PremioDP             = linha[72,81],",",linha[82,83]
   let l_PremioDMO            = linha[84,93],",",linha[94,95]
   let l_PremioAPP            = linha[96,105],",",linha[106,107]
   let l_tpalt = ppwc028_tp_alteracao(linha[108])
   let l_AlteracaoCasco       = linha[108],"-", l_tpalt
   let l_tpalt = ppwc028_tp_alteracao(linha[109])
   let l_AlteracaoAcessorios  = linha[109],"-", l_tpalt
   let l_tpalt = ppwc028_tp_alteracao(linha[110])
   let l_AlteracaoDM          = linha[110],"-", l_tpalt
   let l_tpalt = ppwc028_tp_alteracao(linha[111])
   let l_AlteracaoDP          = linha[111],"-", l_tpalt
   let l_tpalt = ppwc028_tp_alteracao(linha[112])
   let l_AlteracaoDMO         = linha[112],"-", l_tpalt
   let l_tpalt = ppwc028_tp_alteracao(linha[113])
   let l_AlteracaoAPP         = linha[113],"-", l_tpalt

   begin work

      insert into tmp_50  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,Veiculo
                           ,AnoFabricacao
                           ,AnoModelo
                           ,Flag0Km
                           ,Uso
                           ,Categoria
                           ,QtdePassageiros
                           ,PremioCasco
                           ,PremioAcessorio
                           ,PremioDM
                           ,PremioDP
                           ,PremioDMO
                           ,PremioAPP
                           ,AlteracaoCasco
                           ,AlteracaoAcessorios
                           ,AlteracaoDM
                           ,AlteracaoDP
                           ,AlteracaoDMO
                           ,AlteracaoAPP)
                  values  ( m_flag_proposta
                           ,m_count50
                           ,l_CodigoReg
                           ,l_Veiculo
                           ,l_AnoFabricacao
                           ,l_AnoModelo
                           ,l_Flag0Km
                           ,l_Uso
                           ,l_Categoria
                           ,l_QtdePassageiros
                           ,l_PremioCasco
                           ,l_PremioAcessorio
                           ,l_PremioDM
                           ,l_PremioDP
                           ,l_PremioDMO
                           ,l_PremioAPP
                           ,l_AlteracaoCasco
                           ,l_AlteracaoAcessorios
                           ,l_AlteracaoDM
                           ,l_AlteracaoDP
                           ,l_AlteracaoDMO
                           ,l_AlteracaoAPP)
   commit work

   let m_count50 = m_count50 + 1

end function

#-----------------------------------------------------------------------
function ccty21g03_reg_52() # TELEFONES DO SEGURADO
#---------------------------------------------------------------------------#

   define l_CodigoRegistro char(2)
   define l_TipoTelefone   char(2)
   define l_DddTelefone    char(4)
   define l_NumeroTelefone char(10)
   define l_RamalTelefone  char(10)
   define l_Recados        char(40)
   define l_Espaco         char(40)

   let l_CodigoRegistro = ""
   let l_TipoTelefone   = ""
   let l_DddTelefone    = ""
   let l_NumeroTelefone = ""
   let l_RamalTelefone  = ""
   let l_Recados        = ""
   let l_Espaco         = ""

   let l_CodigoRegistro = linha[13,14]
   let l_TipoTelefone   = linha[15,16]
   let l_DddTelefone    = linha[17,20]
   let l_NumeroTelefone = linha[21,30]
   let l_RamalTelefone  = linha[31,40]
   let l_Recados        = linha[41,80]
   let l_Espaco         = linha[81,120]

   begin work

      insert into tmp_52  ( SeqProposta
                           ,Seq
                           ,CodigoRegistro
                           ,TipoTelefone
                           ,DddTelefone
                           ,NumeroTelefone
                           ,RamalTelefone
                           ,Recados
                           ,Espaco)
                  values  ( m_flag_proposta
                           ,m_count52
                           ,l_CodigoRegistro
                           ,l_TipoTelefone
                           ,l_DddTelefone
                           ,l_NumeroTelefone
                           ,l_RamalTelefone
                           ,l_Recados
                           ,l_Espaco)
   commit work

   let m_count52 = m_count52 + 1

end function

#-------------------------------------
function ccty21g03_reg_53(l_corsus, l_ppwprpnum , l_ppwtrxqtd) # COMPLEMENTO DO VEICULO
#-------------------------------------

   define l_IdentifConfirmBonus  char(14)
   define l_NumAgendamentoDAF    char(10)
   define l_KitGas               char(80)
   define l_CambioAutomatico     char(3)
   define l_VeicFinanciado       char(3)
   define l_UtilizacaoVeiculo    char(20)

   define l_corsus      like gppmnetprppcl.corsus
   define l_ppwprpnum   like gppmnetprppcl.ppwprpnum
   define l_ppwtrxqtd   like gppmnetprppcl.ppwtrxqtd

   let l_IdentifConfirmBonus  = ""
   let l_NumAgendamentoDAF    = ""
   let l_KitGas               = ""
   let l_CambioAutomatico     = ""
   let l_VeicFinanciado       = ""
   let l_UtilizacaoVeiculo    = ""

   let l_IdentifConfirmBonus  = linha[15,28] clipped
   let l_NumAgendamentoDAF    = linha[29,38] clipped

   if linha[86,86] = "1" then

      let  m_temkitgas = false

      open cccty21g03023 using l_corsus
                             ,l_ppwprpnum
                             ,l_ppwtrxqtd

      fetch cccty21g03023
      if sqlca.sqlcode = 0 then
         let m_temkitgas = true
      end if

      if m_temkitgas then
         let l_KitGas  = "Veiculo com Kit gas e com a contratacao da cobertura"
      else
         let l_KitGas  = "Veiculo com Kit gas sem a contratacao da cobertura"
      end if
   else
      if linha[86,86] = "2" then
         let l_KitGas  = "Veiculo com Kit gas de serie"
      else
         let l_KitGas  = "Veiculo sem Kit gas"
      end if

   end if

  if linha[87,87] = "2" then
     let l_CambioAutomatico  = "SIM"
  else
     let l_CambioAutomatico  = "NAO"
  end if

  # RENAVAM - INICIO
  let m_renavam_char = "Numero do Renavam...:  "clipped, linha[88,98]

  if linha[99,99] = 1 then
     let l_VeicFinanciado = "SIM"
  else
     if linha[99,99] = 0 then
        let l_VeicFinanciado = "NAO"
     else
        let l_VeicFinanciado = ""
     end if
  end if
  # RENAVAM - FIM

  case (linha[112,112])
     when 1
        let l_UtilizacaoVeiculo = "Particular/Passeio"
     when 2
        let l_UtilizacaoVeiculo = "Comercial/Frota"
     when 3
        let l_UtilizacaoVeiculo = "Nao Informado"
     otherwise
        let l_UtilizacaoVeiculo = ""
  end case


   begin work

      insert into tmp_53  ( SeqProposta
                           ,Seq
                           ,IdentifConfirmBonus
                           ,NumAgendamentoDAF
                           ,KitGas
                           ,CambioAutomatico
                           ,VeicFinanciado
                           ,UtilizacaoVeiculo)
                  values  ( m_flag_proposta
                           ,m_count53
                           ,l_IdentifConfirmBonus
                           ,l_NumAgendamentoDAF
                           ,l_KitGas
                           ,l_CambioAutomatico
                           ,l_VeicFinanciado
                           ,l_UtilizacaoVeiculo)
   commit work

   let m_count53 = m_count53 + 1

 end function

#----------------------------------------------#
function ccty21g03_reg_54() # REGISTRO DE CLAUSULA
#----------------------------------------------#

   define l_CodigoReg               char(2)
   define l_CodigoClausula          char(50)
   define l_CoeficienteClausula     char(7)
   define l_CobrancaSN              char(1)
   define l_IncVigencia             char(10)
   define l_FinalVigencia           char(10)
   define l_PremioLiquidoClausula   char(16)
   define l_PremioTotalClausulas    char(16)

   define l_viginc     date
         ,l_clscod     like aackcls.clscod
         ,l_clsdes     like aackcls.clsdes
         ,l_valor      dec(15,4)

   let l_CodigoReg               = ""
   let l_CodigoClausula          = ""
   let l_CoeficienteClausula     = ""
   let l_CobrancaSN              = ""
   let l_IncVigencia             = ""
   let l_FinalVigencia           = ""
   let l_PremioLiquidoClausula   = ""
   let l_PremioTotalClausulas    = ""

   let l_viginc = m_viginc
   let l_clscod = linha[15,17]

   let l_clsdes = ccty21g03_codigoclausula( l_viginc, l_clscod )

   let l_CodigoReg            = linha[13,14]
   let l_CodigoClausula       = linha[15,17],'-',l_clsdes
   let l_CoeficienteClausula  = linha[18,18],","clipped, linha[19,22]
   let l_CobrancaSN           = linha[23,23]
   let l_IncVigencia          = linha[24,33]
   let l_FinalVigencia        = linha[34,43]

   let l_valor = 0
   let l_valor = linha[44,58]
   let l_valor = l_valor / 100000
   if l_valor is null then
      let l_valor = 0
   end if

    case
      when l_clscod = '034' or l_clscod = '071' or l_clscod = '26D' or l_clscod = '077'

           let l_PremioLiquidoClausula = "GRATUITA"
           let l_valor = 0

      when l_clscod = '018' or l_clscod = '34B' or l_clscod = '34C' or l_clscod = '070'
        or l_clscod = '094' or l_clscod = '114' or l_clscod = '997'

           let l_PremioLiquidoClausula = "--------"
           let l_valor = 0

      otherwise
           let l_PremioLiquidoClausula = l_valor using "#,###,##&.&&&&&"
    end case

    let m_vlr_tot_cls = m_vlr_tot_cls + l_valor

    let l_PremioTotalClausulas   = m_vlr_tot_cls using "###,##&.&&&&&"


   begin work

      if l_CodigoClausula[1,3] <> " " and
         l_CodigoClausula[1,3] is not null then

         insert into tmp_54  ( SeqProposta
                              ,Seq
                              ,CodigoReg
                              ,CodigoClausula
                              ,CoeficienteClausula
                              ,CobrancaSN
                              ,IncVigencia
                              ,FinalVigencia
                              ,PremioLiquidoClausula
                              ,PremioTotalClausulas)
                     values  ( m_flag_proposta
                              ,m_count54
                              ,l_CodigoReg
                              ,l_CodigoClausula
                              ,l_CoeficienteClausula
                              ,l_CobrancaSN
                              ,l_IncVigencia
                              ,l_FinalVigencia
                              ,l_PremioLiquidoClausula
                              ,l_PremioTotalClausulas)
      end if
   commit work

   let m_count54 = m_count54 + 1

end function

#================================================================
function ccty21g03_reg_55_auto() # DESCONTO LOCAL - POL OFF LINE
#================================================================

   define l_NumeroPpw          char(12)
   define l_SenhaUtilizada     char(15)
   define l_ClasseLocalizacao  char(2)
   define l_CodigoVeiculo      char(5)
   define l_DataCalculo        char(8)
   define l_DescontoOffLine    char(3)
   define l_Criptografia       char(20)
   define l_CpfProponente      char(12)
   define l_OrdemProponente    char(4)
   define l_DigitoProponente   char(2)
   define l_Cpf1Condutor       char(9)
   define l_DigitoCpf1Condutor char(2)
   define l_Cpf2Condutor       char(9)
   define l_DigitoCpf2Condutor char(2)
   define l_Cpf3Condutor       char(9)
   define l_DigitoCpf3Condutor char(2)

   let l_NumeroPpw          = ""
   let l_SenhaUtilizada     = ""
   let l_ClasseLocalizacao  = ""
   let l_CodigoVeiculo      = ""
   let l_DataCalculo        = ""
   let l_DescontoOffLine    = ""
   let l_Criptografia       = ""
   let l_CpfProponente      = ""
   let l_OrdemProponente    = ""
   let l_DigitoProponente   = ""
   let l_Cpf1Condutor       = ""
   let l_DigitoCpf1Condutor = ""
   let l_Cpf2Condutor       = ""
   let l_DigitoCpf2Condutor = ""
   let l_Cpf3Condutor       = ""
   let l_DigitoCpf3Condutor = ""

   let l_NumeroPpw          = linha[01,12]
   let l_SenhaUtilizada     = linha[15,29]
   let l_ClasseLocalizacao  = linha[30,31]
   let l_CodigoVeiculo      = linha[32,36]
   let l_DataCalculo        = linha[37,44]
   let l_DescontoOffLine    = linha[45,47]
   let l_Criptografia       = linha[48,67]
   let l_CpfProponente      = linha[68,79]
   let l_OrdemProponente    = linha[80,83]
   let l_DigitoProponente   = linha[84,85]

   let l_Cpf1Condutor       = linha[86,94]
   let l_DigitoCpf1Condutor = linha[95,96]

   let l_Cpf2Condutor       = linha[97,105]
   let l_DigitoCpf2Condutor = linha[106,107]

   let l_Cpf3Condutor       = linha[108,116]
   let l_DigitoCpf3Condutor = linha[117,118]

   begin work

      insert into tmp_55  ( SeqProposta
                           ,Seq
                           ,NumeroPpw
                           ,SenhaUtilizada
                           ,ClasseLocalizacao
                           ,CodigoVeiculo
                           ,DataCalculo
                           ,DescontoOffLine
                           ,Criptografia
                           ,CpfProponente
                           ,OrdemProponente
                           ,DigitoProponente)
                  values  ( m_flag_proposta
                           ,m_count55
                           ,l_NumeroPpw
                           ,l_SenhaUtilizada
                           ,l_ClasseLocalizacao
                           ,l_CodigoVeiculo
                           ,l_DataCalculo
                           ,l_DescontoOffLine
                           ,l_Criptografia
                           ,l_CpfProponente
                           ,l_OrdemProponente
                           ,l_DigitoProponente)

      if l_Cpf1Condutor is not null and
         l_Cpf1Condutor <> " " then
         insert into tmp_55a ( SeqProposta
                              ,CpfCondutor
                              ,DigitoCpfCondutor)
                     values  ( m_flag_proposta
                              ,l_Cpf1Condutor
                              ,l_DigitoCpf1Condutor)
      end if

      if l_Cpf2Condutor is not null and
         l_Cpf2Condutor <> " " then
         insert into tmp_55a ( SeqProposta
                              ,CpfCondutor
                              ,DigitoCpfCondutor)
                     values  ( m_flag_proposta
                              ,l_Cpf2Condutor
                              ,l_DigitoCpf2Condutor)
      end if

      if l_Cpf3Condutor is not null and
         l_Cpf3Condutor <> " " then
         insert into tmp_55a ( SeqProposta
                              ,CpfCondutor
                              ,DigitoCpfCondutor)
                     values  ( m_flag_proposta
                              ,l_Cpf3Condutor
                              ,l_DigitoCpf3Condutor)
      end if

   commit work

   let m_count55 = m_count55 + 1

end function
{
#-------------------------------------
function ccty21g03_reg_55() #####******************************#####
#-------------------------------------
 define l_qstcod          like apqkquest.qstcod
 define l_qstdes          like apqkquest.qstdes
       ,l_qstrsptip       like apqkquest.qstrsptip

 let l_qstcod = 0
 let l_qstdes = ""
 let l_qstrsptip = null

 let i = i + 1
 let ccty21g03_tela[i]  = "---QUESTIONARIO OBRIGATORIO(RESIDENCIA)--"
 let i = i + 1
 let ccty21g03_tela[i]  = "Sequencia do Local.....:  "clipped, linha[13,14]
 let i = i + 1
 #PSI 190586
 let l_qstcod = linha[15,17]
 call ccty21g03_questao(l_qstcod)
    returning l_qstdes
             ,l_qstrsptip
 let ccty21g03_tela[i]  = "Codigo da Questao......:  "clipped, linha[15,17]
          ," - ",l_qstdes
 let i = i + 1
 let ccty21g03_tela[i]  = "Flag de Resposta.......:  "clipped, linha[18,18]
 let i = i + 1

end function
}
#-------------------------------------
function ccty21g03_reg_56() # QUESTIONARIO OBRIGATORIO (EMPRESA)
#-------------------------------------

   define l_SequenciaLocal    char(2)
   define l_CodigoQuestao     char(50)
   define l_DescricaoResposta char(20)

   define l_qstcod          like apqkquest.qstcod
   define l_qstdes          like apqkquest.qstdes
         ,l_qstrsptip       like apqkquest.qstrsptip

   let l_SequenciaLocal    = ""
   let l_CodigoQuestao     = ""
   let l_DescricaoResposta = ""

   let l_qstcod = 0
   let l_qstdes = ""
   let l_qstrsptip = null

   let l_qstcod = linha[15,17]
   call ccty21g03_questao(l_qstcod)
      returning l_qstdes
               ,l_qstrsptip

   let l_SequenciaLocal    = linha[13,14]
   let l_CodigoQuestao     = linha[15,17],"-",l_qstdes clipped
   let l_DescricaoResposta = linha[18,37]

   begin work

      insert into tmp_56  ( SeqProposta
                           ,Seq
                           ,SequenciaLocal
                           ,CodigoQuestao
                           ,DescricaoResposta)
                  values  ( m_flag_proposta
                           ,m_count56
                           ,l_SequenciaLocal
                           ,l_CodigoQuestao
                           ,l_DescricaoResposta)
   commit work

   let m_count56 = m_count56 + 1

end function


{#==================================
function ccty21g03_reg_57(l_empcod) #####******************************#####
#==================================
   define l_renda       like gsakcmcinfren.segmesrenvlr
   define l_empcod      like gtakram.empcod
   define l_clcdat      char(10)
   define l_grauparent  char(50)
   define l_sqlcode     integer

   let l_renda = linha[15,31]
   let l_renda = (l_renda/100)
   let w_renda = l_renda
   let w_codreg = linha[13,14]

   let w_renfxacod = linha[32,34]  #Tarifa Abril/2010
   let w_pep       = linha[35,35]  # PSI 254371 - Tarifa Abril/2010
   let w_pepnom    = linha[36,85]  # PSI 254371 - Tarifa Abril/2010
   #Tarifa Junho/2010
   let w_prxrelpescgccpfnum = linha[86,97]
   let w_prxrelpescgccpfdig = linha[98,99]
   let w_pepreltip = linha[100,100]

   call osgtk1001_consultatiporelac(w_pepreltip)
                returning l_sqlcode, w_pepreldes

   if w_pep <> 3 then
      let w_pepreldes = ""
   end if

   if l_sqlcode <> 0 then
      let w_pepreldes = ""
   end if

   let w_faixa = ""
   let w_faixa = osgtc560_fxaren(l_empcod, w_renfxacod, w_vigencia)

end function
}
#--------------------------#
function ccty21g03_reg_58(l_empcod) # VERSÃO DA DLL E DADOS ADICIONAIS DO SEGURADO PJ
#--------------------------#

   define l_CodigoReg           char(2)
   define l_VersaoDllCalculo    char(8)
   define l_PatrimonioLiquido   char(40)
   define l_RecOperacBrutaAnual char(40)
   define l_AdminControlProcur  char(45)
   define l_TipoEmpresa         char(40)

   define l_empcod      like gtakram.empcod
   define l_today       date
   define l_desc_pat    char(45)
   define l_desc_rec    char(45)
   define l_desc_pjrtip char(45)
   define l_desc_ctdflg char(45)
   define l_sqlcode     integer
   define lr_dadospj record
                     pjrtip            like  gsakpjrseg.pjrtip,
                     ctdflg            like  gsakpjrseg.ctdflg,
                     liqptrfxacod      like  gsakpjrseg.liqptrfxacod,
                     crccapfxacod      like  gsakpjrseg.crccapfxacod
                     end record

   let l_CodigoReg           = ""
   let l_VersaoDllCalculo    = ""
   let l_PatrimonioLiquido   = ""
   let l_RecOperacBrutaAnual = ""
   let l_AdminControlProcur  = ""
   let l_TipoEmpresa         = ""


   let l_today = today

   initialize lr_dadospj.*  to null
   initialize l_desc_pat    to null
   initialize l_desc_rec    to null
   initialize l_desc_pjrtip to null
   initialize l_desc_ctdflg to null

   let lr_dadospj.liqptrfxacod = linha[48,49]  #osgtc564_descfxpatrliq
   let lr_dadospj.crccapfxacod = linha[50,51]  #osgtc565_descfxreceitaop
   let lr_dadospj.pjrtip       = linha[52,52]  #tipo de pessoa juridica pendente de função Kennedy.
   let lr_dadospj.ctdflg       = linha[53,53]  #flag de controladores S/N

   call osgtc563_desc_tippj(lr_dadospj.pjrtip)
      returning l_sqlcode, l_desc_pjrtip

   call osgtc564_descfxpatrliq(l_empcod,lr_dadospj.liqptrfxacod,l_today)
      returning l_desc_pat

   call osgtc565_descfxreceitaop(l_empcod,lr_dadospj.crccapfxacod,l_today)
      returning l_desc_rec

   case lr_dadospj.ctdflg
      when "S"
         let l_desc_ctdflg = "Sim"
      when "N"
         let l_desc_ctdflg = "Nao"
      when "I"
         let l_desc_ctdflg = "Nao deseja informar"
   end case

   let l_CodigoReg            = linha[13,14]
   let l_VersaoDllCalculo     = linha[15,22]
   let l_PatrimonioLiquido    = l_desc_pat
   let l_RecOperacBrutaAnual  = l_desc_rec
   let l_AdminControlProcur   = l_desc_ctdflg
   let l_TipoEmpresa          = l_desc_pjrtip

   begin work

      insert into tmp_58  ( SeqProposta
                           ,Seq
                           ,CodigoReg
                           ,VersaoDllCalculo
                           ,PatrimonioLiquido
                           ,RecOperacBrutaAnual
                           ,AdminControlProcur
                           ,TipoEmpresa        )
                  values  ( m_flag_proposta
                           ,m_count58
                           ,l_CodigoReg
                           ,l_VersaoDllCalculo
                           ,l_PatrimonioLiquido
                           ,l_RecOperacBrutaAnual
                           ,l_AdminControlProcur
                           ,l_TipoEmpresa       )
   commit work

   let m_count58 = m_count58 + 1

end function


#------------------------------------------------
function ccty21g03_reg_59() # VINCULOS PJ - CONTROLADORES, ADMINISTRADORES, PROCURADORES
#------------------------------------------------

   define l_TipoProponente char(1)
   define l_Nome           char(50)
   define l_TipoPessoa     char(1)
   define l_CpfCnpj        char(9)
   define l_Ordem          char(4)
   define l_Digito         char(2)
   define l_SemCpfCnpjPor  char(50)

   let l_TipoProponente = ""
   let l_Nome           = ""
   let l_TipoPessoa     = ""
   let l_CpfCnpj        = ""
   let l_Ordem          = ""
   let l_Digito         = ""
   let l_SemCpfCnpjPor  = ""

   let l_TipoProponente = linha[20,20]
   let l_Nome           = linha[21,70]
   let l_TipoPessoa     = linha[71,71]
   let l_CpfCnpj        = linha[72,80]
   let l_Ordem          = linha[81,84]
   let l_Digito         = linha[85,86]
   let l_SemCpfCnpjPor  = ccty21g03_sem_cnpj(linha[87,88])

   begin work

      insert into tmp_59  ( SeqProposta
                           ,Seq
                           ,TipoProponente
                           ,Nome
                           ,TipoPessoa
                           ,CpfCnpj
                           ,Ordem
                           ,Digito
                           ,SemCpfCnpjPor )
                  values  ( m_flag_proposta
                           ,m_count59
                           ,l_TipoProponente
                           ,l_Nome
                           ,l_TipoPessoa
                           ,l_CpfCnpj
                           ,l_Ordem
                           ,l_Digito
                           ,l_SemCpfCnpjPor )
   commit work

   let m_count59 = m_count59 + 1

end function

#-------------------------------------
function ccty21g03_reg_60() # OUTROS SEGUROS
#-------------------------------------

   define l_DescricaoTexto char(200)

   let l_DescricaoTexto = ""

   let l_DescricaoTexto = linha[13,212]

   begin work

      insert into tmp_60  ( SeqProposta
                           ,Seq
                           ,DescricaoTexto )
                  values  ( m_flag_proposta
                           ,m_count60
                           ,l_DescricaoTexto )
   commit work

   let m_count60 = m_count60 + 1

end function

#-------------------------------------
function ccty21g03_reg_61() # FINALIDADE DA EMISSAO
#-------------------------------------

   define l_FinalidadeEmissao  char(15)
   define l_FinalidadeEncargos char(15)
   define l_ValorTotalPremio   char(15)

   let l_FinalidadeEmissao    = ""
   let l_FinalidadeEncargos   = ""
   let l_ValorTotalPremio     = ""

   let l_FinalidadeEmissao    = linha[13,27]
   let l_FinalidadeEncargos   = linha[28,42]
   let l_ValorTotalPremio     = linha[43,57]

   begin work

      insert into tmp_61  ( SeqProposta
                           ,Seq
                           ,FinalidadeEmissao
                           ,FinalidadeEncargos
                           ,ValorTotalPremio  )

                  values  ( m_flag_proposta
                           ,m_count61
                           ,l_FinalidadeEmissao
                           ,l_FinalidadeEncargos
                           ,l_ValorTotalPremio  )
   commit work

   let m_count61 = m_count61 + 1

end function

#-------------------------------------
function ccty21g03_reg_62() # DADOS DE COBRANCA - ANTIGO
#-------------------------------------
   define l_TipoFormaPagto          char(50)
   define l_NumeroParcela           char(2)
   define l_NumeroCartaoCredito     char(16)
   define l_VencimentoCartaoCredito char(6)
   define l_NumeroBanco             char(4)
   define l_NumeroAgencia           char(5)
   define l_NumeroContaCorrente     char(15)
   define l_DigitoContaCorrente     char(1)
   define l_DataVencimento          char(10)
   define l_ValorParcela            char(12)
   define l_NumeroCheque            char(10)
   define l_PracaCheque             char(2)
   define l_CnpjCpfCorrentista      char(20)

   define l_pgtfrm      smallint
   define l_pgtfrmdes   char(40)

   let l_TipoFormaPagto          = ""
   let l_NumeroParcela           = ""
   let l_NumeroCartaoCredito     = ""
   let l_VencimentoCartaoCredito = ""
   let l_NumeroBanco             = ""
   let l_NumeroAgencia           = ""
   let l_NumeroContaCorrente     = ""
   let l_DigitoContaCorrente     = ""
   let l_DataVencimento          = ""
   let l_ValorParcela            = ""
   let l_NumeroCheque            = ""
   let l_PracaCheque             = ""
   let l_CnpjCpfCorrentista      = ""


   let l_pgtfrm = 0
   let l_pgtfrmdes = ""
   let l_pgtfrm = linha[13,14]
   let l_pgtfrmdes = ccty21g03_formapgto(l_pgtfrm)

   let l_TipoFormaPagto          = linha[13,14],"-",l_pgtfrmdes clipped
   let l_NumeroParcela           = linha[15,16]
   let l_NumeroCartaoCredito     = linha[17,32]
   let l_VencimentoCartaoCredito = linha[33,38]
   let l_NumeroBanco             = linha[39,42]
   let l_NumeroAgencia           = linha[43,47]
   let l_NumeroContaCorrente     = linha[48,62]
   let l_DigitoContaCorrente     = linha[63,63]
   let l_DataVencimento          = linha[64,73]
   let l_ValorParcela            = linha[74,85]
   let l_NumeroCheque            = linha[86,95]
   let l_PracaCheque             = linha[96,97]
   let l_CnpjCpfCorrentista      = linha[98,117]

   begin work

      insert into tmp_62  ( SeqProposta
                           ,Seq
                           ,TipoFormaPagto
                           ,NumeroParcela
                           ,NumeroCartaoCredito
                           ,VencimentoCartaoCredito
                           ,NumeroBanco
                           ,NumeroAgencia
                           ,NumeroContaCorrente
                           ,DigitoContaCorrente
                           ,DataVencimento
                           ,ValorParcela
                           ,NumeroCheque
                           ,PracaCheque
                           ,CnpjCpfCorrentista )
                  values  ( m_flag_proposta
                           ,m_count62
                           ,l_TipoFormaPagto
                           ,l_NumeroParcela
                           ,l_NumeroCartaoCredito
                           ,l_VencimentoCartaoCredito
                           ,l_NumeroBanco
                           ,l_NumeroAgencia
                           ,l_NumeroContaCorrente
                           ,l_DigitoContaCorrente
                           ,l_DataVencimento
                           ,l_ValorParcela
                           ,l_NumeroCheque
                           ,l_PracaCheque
                           ,l_CnpjCpfCorrentista )
   commit work

   let m_count62 = m_count62 + 1


end function

#==================================
function ccty21g03_reg_63() # CUSTOS DE APOLICES/PARCELAS
#==================================

   define l_CustoApolice   char(15)
   define l_IOF            char(15)
   define l_PremioVista    char(15)
   define l_TaxaCasco      char(9)
   define l_SeguroMensal   char(1)
   define l_Parcelas1      char(15)
   define l_ParcelasDemais char(15)
   define l_ParcelasJuros  char(15)

   let l_CustoApolice   = ""
   let l_IOF            = ""
   let l_PremioVista    = ""
   let l_TaxaCasco      = ""
   let l_SeguroMensal   = ""
   let l_Parcelas1      = ""
   let l_ParcelasDemais = ""
   let l_ParcelasJuros  = ""

   let l_CustoApolice   = linha[13,27]
   let l_IOF            = linha[28,42]
   let l_PremioVista    = linha[43,57]
   let l_TaxaCasco      = linha[58,66]
   let l_SeguroMensal   = linha[67,67]
   let l_Parcelas1      = linha[68,82]
   let l_ParcelasDemais = linha[83,97]
   let l_ParcelasJuros  = linha[98,112]

   begin work

      insert into tmp_63  ( SeqProposta
                           ,Seq
                           ,CustoApolice
                           ,IOF
                           ,PremioVista
                           ,TaxaCasco
                           ,SeguroMensal
                           ,Parcelas1
                           ,ParcelasDemais
                           ,ParcelasJuros )

                  values  ( m_flag_proposta
                           ,m_count63
                           ,l_CustoApolice
                           ,l_IOF
                           ,l_PremioVista
                           ,l_TaxaCasco
                           ,l_SeguroMensal
                           ,l_Parcelas1
                           ,l_ParcelasDemais
                           ,l_ParcelasJuros )
   commit work

   let m_count63 = m_count63 + 1

end function

#---------------------------------------------------------------------------#
function ccty21g03_reg_64() # DADOS DE COBRANCA - NOVO(A PARTIR DEZ)
#---------------------------------------------------------------------------#

   define l_TipoFormaPagto          char(50)
   define l_NumeroParcela           char(2)
   define l_NumeroCartaoCredito     char(16)
   define l_VencimentoCartaoCredito char(6)
   define l_NumeroBanco             char(4)
   define l_NumeroAgencia           char(5)
   define l_NumeroContaCorrente     char(15)
   define l_DigitoContaCorrente     char(5)
   define l_DataVencimento          char(10)
   define l_ValorParcela            char(12)
   define l_NumeroCheque            char(10)
   define l_PracaCheque             char(2)
   define l_CnpjCpfCorrentista      char(20)

   define l_pgtfrm char(2)
   define l_pgtfrmdes char(50)

   let l_TipoFormaPagto          = ""
   let l_NumeroParcela           = ""
   let l_NumeroCartaoCredito     = ""
   let l_VencimentoCartaoCredito = ""
   let l_NumeroBanco             = ""
   let l_NumeroAgencia           = ""
   let l_NumeroContaCorrente     = ""
   let l_DigitoContaCorrente     = ""
   let l_DataVencimento          = ""
   let l_ValorParcela            = ""
   let l_NumeroCheque            = ""
   let l_PracaCheque             = ""
   let l_CnpjCpfCorrentista      = ""

   let l_pgtfrm = linha[13,14]
   let l_pgtfrmdes = ccty21g03_formapgto(l_pgtfrm)

   let l_TipoFormaPagto           = linha[13,14],"-",l_pgtfrmdes clipped
   let l_NumeroParcela            = linha[15,16]
   let l_NumeroCartaoCredito      = linha[17,32]
   let l_VencimentoCartaoCredito  = linha[33,38]
   let l_NumeroBanco              = linha[39,42]
   let l_NumeroAgencia            = linha[43,47]
   let l_NumeroContaCorrente      = linha[48,62]
   let l_DigitoContaCorrente      = linha[63,67]
   let l_DataVencimento           = linha[68,77]
   let l_ValorParcela             = linha[78,89]
   let l_NumeroCheque             = linha[90,99]
   let l_PracaCheque              = linha[100,101]
   let l_CnpjCpfCorrentista       = linha[102,121]


   begin work

      insert into tmp_64 ( SeqProposta
                           ,Seq
                           ,TipoFormaPagto
                           ,NumeroParcela
                           ,NumeroCartaoCredito
                           ,VencimentoCartaoCredito
                           ,NumeroBanco
                           ,NumeroAgencia
                           ,NumeroContaCorrente
                           ,DigitoContaCorrente
                           ,DataVencimento
                           ,ValorParcela
                           ,NumeroCheque
                           ,PracaCheque
                           ,CnpjCpfCorrentista )
                   values ( m_flag_proposta
                           ,m_count64
                           ,l_TipoFormaPagto
                           ,l_NumeroParcela
                           ,l_NumeroCartaoCredito
                           ,l_VencimentoCartaoCredito
                           ,l_NumeroBanco
                           ,l_NumeroAgencia
                           ,l_NumeroContaCorrente
                           ,l_DigitoContaCorrente
                           ,l_DataVencimento
                           ,l_ValorParcela
                           ,l_NumeroCheque
                           ,l_PracaCheque
                           ,l_CnpjCpfCorrentista )
   commit work

   let m_count64 = m_count64 + 1

end function

#---------------------------------------------------------------------------#
function ccty21g03_reg_66() # TRANSITO MAIS GENTIL
#---------------------------------------------------------------------------#

   define l_FlagTransitoGentil char(1)
   define l_CnhTransitoGentil  char(15)

   let l_FlagTransitoGentil = ""
   let l_CnhTransitoGentil  = ""

   let l_FlagTransitoGentil = linha[15,15]
   let l_CnhTransitoGentil  = linha[16,30]

   begin work

      insert into tmp_66 ( SeqProposta
                          ,Seq
                          ,FlagTransitoGentil
                          ,CnhTransitoGentil )
                 values  ( m_flag_proposta
                          ,m_count66
                          ,l_FlagTransitoGentil
                          ,l_CnhTransitoGentil )
   commit work

   let m_count66 = m_count66 + 1

end function

#------------------------------------------------#
function ccty21g03_reg_67() # PEP
#------------------------------------------------#
   define l_CodigoPEP    char(1)
   define l_PEP          char(30)
   define l_NomePEP      char(50)
   define l_CpfPEP       char(12)
   define l_DigitoCpfPEP char(2)
   define l_GrauRelacPEP char(1)

   let l_CodigoPEP    = ""
   let l_PEP          = ""
   let l_NomePEP      = ""
   let l_CpfPEP       = ""
   let l_DigitoCpfPEP = ""
   let l_GrauRelacPEP = ""

   let l_CodigoPEP    = linha[20,20]
   let l_NomePEP      = linha[21,70]
   let l_CpfPEP       = linha[71,82]
   let l_DigitoCpfPEP = linha[83,84]
   let l_GrauRelacPEP = linha[85,85]

   case l_CodigoPEP
      when 1 let l_PEP = "1 - Sim"
      when 2 let l_PEP = "2 - Nao"
      when 3 let l_PEP = "3 - Relacionamento proximo"
      otherwise let l_PEP = ""
   end case

   begin work
      insert into tmp_67 (  SeqProposta
                           ,Seq
                           ,CodigoPEP
                           ,PEP
                           ,NomePEP
                           ,CpfPEP
                           ,DigitoCpfPEP
                           ,GrauRelacPEP )
                  values (  m_flag_proposta
                           ,m_count67
                           ,l_CodigoPEP
                           ,l_PEP
                           ,l_NomePEP
                           ,l_CpfPEP
                           ,l_DigitoCpfPEP
                           ,l_GrauRelacPEP )
   commit work

   let m_count67 = m_count67 + 1

end function

#------------------------------------------------------------------------------
function ccty21g03_susep(l_susep)
#------------------------------------------------------------------------------

define l_susep     like gcaksusep.corsus
define l_cornom    like gcakcorr.cornom

   let l_cornom = ""

   if (l_susep is not null and
       l_susep <> " ")     then

      whenever error continue
         open cccty21g03002 using l_susep
         fetch cccty21g03002 into l_cornom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03002.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_susep
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da SUSEP:"
         #        ,l_susep
         #end if
      end if
      close cccty21g03002

   end if

   return l_cornom

end function #ccty21g03_susep

#------------------------------------------------------------------------------
function ccty21g03_formapgto(l_pgtfrm)
#------------------------------------------------------------------------------

define l_pgtfrm     like gfbkfpag.pgtfrm
define l_pgtfrmdes  like gfbkfpag.pgtfrmdes

   let l_pgtfrmdes = ""

   if (l_pgtfrm is not null and
       l_pgtfrm > 0)        then

      whenever error continue
         open cccty21g03004 using l_pgtfrm
         fetch cccty21g03004 into l_pgtfrmdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03004.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_pgtfrm
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da Forma de Pagamento: "
         #        ,l_pgtfrm
         #end if
      end if
      close cccty21g03004

   end if

   return l_pgtfrmdes

end function #ccty21g03_formapgto

#------------------------------------------------------------------------------
function ccty21g03_endosso(l_edstip)
#------------------------------------------------------------------------------
define l_edstip     char(2)
define l_edstipdes  char(98)

   let l_edstipdes = ""

   whenever error continue
      open cccty21g03003 using l_edstip
      fetch cccty21g03003 into l_edstipdes
   whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03003.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_edstip
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao do Tipo do Endosso: "
         #        ,l_edstip
         #end if
      end if
      close cccty21g03003

   return l_edstipdes

end function #ccty21g03_endosso


#------------------------------------------------------------------------------
function ccty21g03_seguradora(l_sgdirbcod)
#------------------------------------------------------------------------------

define l_sgdirbcod     like gcckcong.sgdirbcod
define l_sgdnom        like gcckcong.sgdnom

   let l_sgdnom = ""

   if (l_sgdirbcod is not null and
       l_sgdirbcod > 0)        then

      whenever error continue
         open cccty21g03005 using l_sgdirbcod
         fetch cccty21g03005 into l_sgdnom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03005.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_sgdirbcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou o nome da Seguradora: "
         #        ,l_sgdirbcod
         #end if
      end if
      close cccty21g03005

   end if

   return l_sgdnom

end function #ccty21g03_seguradora

#------------------------------------------------------------------------------
function ccty21g03_pessoa(l_pestip)
#------------------------------------------------------------------------------

define l_pestip           like gabkpestip.pestip
define l_pestipdes        like gabkpestip.pestipdes

   let l_pestipdes = ""

   if (l_pestip is not null and
       l_pestip <> " ")     then

      whenever error continue
         open cccty21g03006 using l_pestip
         fetch cccty21g03006 into l_pestipdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03006.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_pestip
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao do Tipo de Pessoa: "
         #        ,l_pestip
         #end if
      end if
      close cccty21g03006

   end if

   return l_pestipdes

end function #ccty21g03_pessoa

#------------------------------------------------------------------------------
function ccty21g03_endereco(l_etpendtip)
#------------------------------------------------------------------------------

define l_etpendtip           like trakedctip.etpendtip
define l_etpendtipdes        like trakedctip.etpendtipdes

   if l_etpendtip = 1 then
      let l_etpendtipdes = "Residencial"
   else
      if l_etpendtip = 2 then
         let l_etpendtipdes = "Comercial"
      else
         let l_etpendtipdes = ""
      end if
   end if

   #whenever error continue
   #   open cccty21g03007 using l_etpendtip
   #   fetch cccty21g03007 into l_etpendtipdes
   #whenever error stop
   #if sqlca.sqlcode <> 0 then
   #   if sqlca.sqlcode < 0 then
   #      error "Erro no SELECT cccty21g03007.",sqlca.sqlcode,"/"
   #           ,sqlca.sqlerrd[2]
   #      sleep 2
   #      error l_etpendtip
   #      sleep 2
   #   end if
   #   if sqlca.sqlcode = 100 then
   #      error "Nao encontrou a descricao do Tipo de Endereco: "
   #           ,l_etpendtip
   #   end if
   #end if
   #close cccty21g03007

   return l_etpendtipdes

end function #ccty21g03_endereco

#------------------------------------------------------------------------------
function ccty21g03_atividade(l_prfcod, l_viginc)
#------------------------------------------------------------------------------

 define l_prfcod  smallint
 define l_viginc  date
 define l_cod     smallint
 define l_msgerr  char(080)

 define l_prfdes  char(60)

   let l_prfdes    = ''

   if (l_prfcod is not null and
       l_prfcod > 0 )       then

     # call fvnvl000_vgokprf_01(l_prfcod)
     #       returning l_cod
     #                ,l_msgerr
     #                ,l_prfdes
       if l_cod <> 0 then
          error l_msgerr clipped , ': ',l_prfcod, ' / ', l_viginc
       end if
   end if

   return l_prfdes

end function #ccty21g03_atividade

#------------------------------------------------------------------------------
function ccty21g03_veiculo(l_vclcoddig)
#------------------------------------------------------------------------------

define l_vclcoddig           like agbkveic.vclcoddig
define l_vclmrcnom           like agbkmarca.vclmrcnom
define l_vcltipnom           like agbktip.vcltipnom
define l_vclmldnom           like agbkveic.vclmdlnom
define l_veicdes             char(40)

   let l_vclmrcnom = ""
   let l_vcltipnom = ""
   let l_vclmldnom = ""
   let l_veicdes = ""

   if (l_vclcoddig is not null and
       l_vclcoddig > 0)        then

    whenever error continue
       open cccty21g03010 using l_vclcoddig
       fetch cccty21g03010 into l_vclmrcnom, l_vcltipnom, l_vclmldnom
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode < 0 then
          error "Erro no SELECT cccty21g03010.",sqlca.sqlcode,"/"
               ,sqlca.sqlerrd[2]
          sleep 2
          error l_vclcoddig
          sleep 2
       end if
       #if sqlca.sqlcode = 100 then
       #   error "Nao encontrou as descricoes do Veiculo: "
       #        ,l_vclcoddig
       #end if
    end if
    close cccty21g03010

    let l_veicdes = l_vclmrcnom clipped," "
      ,l_vcltipnom clipped," "
      ,l_vclmldnom clipped

   end if

   return l_veicdes

end function #ccty21g03_veiculo

#------------------------------------------------------------------------------
function ccty21g03_categoria(l_ctgtrfcod)
#------------------------------------------------------------------------------

define l_ctgtrfcod        like agekcateg.ctgtrfcod
define l_ramcod           like gtakram.ramcod

define l_tabnum           like agekcateg.tabnum
define l_ctgtrfdes        like agekcateg.ctgtrfdes

   let l_ctgtrfdes = ""

   let l_tabnum = f_fungeral_tabnum("agekcateg",m_viginc)

   if (l_tabnum is not null    and
       l_tabnum > 0)           and
      (l_ctgtrfcod is not null and
       l_ctgtrfcod > 0)        then

      let l_ramcod = 531
      whenever error continue
      open cccty21g03011 using l_tabnum,
                               l_ramcod,
                               l_ctgtrfcod
      fetch cccty21g03011 into l_ctgtrfdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03011.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_tabnum,"/",l_ctgtrfcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da Categoria Tarifaria: "
         #        ,l_ctgtrfcod
         #end if
      end if
      close cccty21g03011

   end if

   return l_ctgtrfdes

end function #ccty21g03_categoria

#------------------------------------------------------------------------------
function ccty21g03_logradouro(l_endlgdtip)
#------------------------------------------------------------------------------

define l_endlgdtip           like gsaktipolograd.endlgdtip
define l_endlgdtipdes        like gsaktipolograd.endlgdtipdes

   let l_endlgdtipdes    = ""

   if (l_endlgdtip is not null and
       l_endlgdtip <> " ")     then

      whenever error continue
         open cccty21g03012 using l_endlgdtip
         fetch cccty21g03012 into l_endlgdtipdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03012.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_endlgdtip
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao do Tipo do Logradouro: "
         #        ,l_endlgdtip
         #end if
      end if
      close cccty21g03012

   end if

   return l_endlgdtipdes

end function #ccty21g03_logradouro

#------------------------------------------------------------------------------
function ccty21g03_classeloc(l_clalclcod)
#------------------------------------------------------------------------------

define l_clalclcod        like agekregiao.clalclcod
define l_clalcldes        like agekregiao.clalcldes
define l_tabnum           like agekregiao.tabnum

   let l_clalcldes    = ""

   let l_tabnum = f_fungeral_tabnum("agekregiao",m_viginc)

   if (l_clalclcod is not null and
       l_clalclcod > 0)        and
      (l_tabnum is not null    and
       l_tabnum > 0)           then

      whenever error continue
      open cccty21g03009 using l_clalclcod, l_tabnum
      fetch cccty21g03009 into l_clalcldes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03009.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_clalclcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da Classe de Localizacao: "
         #        ,l_clalclcod
         #end if
      end if
      close cccty21g03009

   end if

   return l_clalcldes

end function #ccty21g03_classeloc

#------------------------------------------------------------------------------
function ccty21g03_desconto(l_cndeslcod)
#------------------------------------------------------------------------------

define l_cndeslcod        like aggkcndesl.cndeslcod
define l_cndeslnom        like aggkcndesl.cndeslnom
define l_tabnum           like aggkcndesl.tabnum

   let l_cndeslnom    = ""

   let l_tabnum = f_fungeral_tabnum("aggkcndesl",m_viginc)

   if (l_tabnum is not null    and
       l_tabnum > 0)           and
      (l_cndeslcod is not null and
       l_cndeslcod > 0)        then

      whenever error continue
         open cccty21g03013 using l_tabnum, l_cndeslcod
         fetch cccty21g03013 into l_cndeslnom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03013.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_cndeslcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
           # error "Nao encontrou a descricao do Desconto: "
           #      ,l_cndeslcod
         #end if
      end if
      close cccty21g03013

   end if

   return l_cndeslnom

end function #ccty21g03_desconto

#------------------------------------------------------------------------------
function ccty21g03_questao(l_qstcod)
#------------------------------------------------------------------------------

define l_qstcod        like apqkquest.qstcod
define l_qstdes        like apqkquest.qstdes
      ,l_qstrsptip     like apqkquest.qstrsptip

   let l_qstdes    = ""
   let l_qstrsptip = null

   if (l_qstcod is not null and
      l_qstcod > 0)         then

      whenever error continue
         open cccty21g03014 using l_qstcod
         fetch cccty21g03014 into l_qstdes
                                ,l_qstrsptip
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03014.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error l_qstcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da Questao: "
         #        ,l_qstcod
         #end if
      end if
      close cccty21g03014

   end if

   return l_qstdes
         ,l_qstrsptip

end function #ccty21g03_questao

#------------------------------------------------------------------------------
function ccty21g03_resposta(lr_resposta)
#------------------------------------------------------------------------------

define lr_resposta     record
   qstcod              like apqkdominio.qstcod
  ,rspcod              like apqkdominio.rspcod
  ,qstrsptip           like apqkquest.qstrsptip
end record

define l_qstrspdsc     like apqkdominio.qstrspdsc

   let l_qstrspdsc    = ""

   if lr_resposta.qstrsptip = "C"     and
      (lr_resposta.qstcod is not null and
       lr_resposta.qstcod > 0)        and
      (lr_resposta.rspcod is not null and
       lr_resposta.rspcod > 0)        then

      whenever error continue
         open cccty21g03015 using lr_resposta.qstcod
                                ,lr_resposta.rspcod
                                ,m_vigencia
                                ,m_vigencia
         fetch cccty21g03015 into l_qstrspdsc
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03015.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error lr_resposta.qstcod,"/",lr_resposta.rspcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da Resposta: "
         #        ,lr_resposta.qstcod,"/",lr_resposta.rspcod
         #end if
      end if
      close cccty21g03015

   end if

   return l_qstrspdsc

end function #ccty21g03_resposta

#------------------------------------------------------------------------------
function ccty21g03_subresposta(lr_subresposta)
#------------------------------------------------------------------------------

define lr_subresposta  record
   qstcod              like apqkdominio.qstcod
  ,rspcod              like apqkdominio.rspcod
  ,subrspcod           like apqksubrsp.rspsubcod
end record

define l_qstrsphtmdes     like apqksubrsp.qstrsphtmdes

   let l_qstrsphtmdes    = ""

   if (lr_subresposta.qstcod is not null    and
       lr_subresposta.qstcod > 0)           and
      (lr_subresposta.rspcod is not null    and
       lr_subresposta.rspcod > 0)           and
      (lr_subresposta.subrspcod is not null and
       lr_subresposta.subrspcod > 0)        then

       if lr_subresposta.qstcod = 155                             and
         (lr_subresposta.rspcod = 2 or lr_subresposta.rspcod = 3) and
          lr_subresposta.subrspcod = 3                            then
          let l_qstrsphtmdes = "Feminino e Masculino"
          return l_qstrsphtmdes
       end if

      whenever error continue
         open cccty21g03022 using lr_subresposta.qstcod
                                ,lr_subresposta.rspcod
                                ,lr_subresposta.subrspcod
         fetch cccty21g03022 into l_qstrsphtmdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro no SELECT cccty21g03022.",sqlca.sqlcode,"/"
                 ,sqlca.sqlerrd[2]
            sleep 2
            error lr_subresposta.qstcod,"/",lr_subresposta.rspcod
            sleep 2
         end if
         #if sqlca.sqlcode = 100 then
         #   error "Nao encontrou a descricao da Sub-Resposta: "
         #        ,lr_subresposta.qstcod,"/",lr_subresposta.rspcod,"/"
         #        ,lr_subresposta.subrspcod
         #end if
      end if
      close cccty21g03022

   end if

   return l_qstrsphtmdes

end function

#------------------------------------------------------------------------------
function ccty21g03_valores(l_char)
#------------------------------------------------------------------------------

define l_char      char(10)

   if l_char <> "0000000000" then
      while true
         if l_char[1] = "0" then
            let l_char = l_char[2,10]
         else
            exit while
         end if
      end while
   else
      let l_char = "0"
   end if

   return l_char

end function #ccty21g03_valores


#------------------------------------------------------------------------------
function ccty21g03_tiposeguro_tipocalculo(l_tiposeguro, l_tipocalculo)
#------------------------------------------------------------------------------
   define l_tiposeguro      like iddkdominio.cpocod
         ,l_tipocalculo     like iddkdominio.cpocod

         ,l_desctiposeguro  like iddkdominio.cpodes
         ,l_desctipocalculo like iddkdominio.cpodes

         ,l_cponom          like iddkdominio.cponom

   let l_desctiposeguro  = ''
   let l_desctipocalculo = ''

   let l_cponom = 'segtip'

   if (l_tiposeguro is not null and
       l_tiposeguro > 0)        then

      open cccty21g03016 using l_cponom, l_tiposeguro
      whenever error continue
      fetch cccty21g03016 into l_desctiposeguro
      whenever error stop
      if sqlca.sqlcode <> 0 then
         #if sqlca.sqlcode = notfound then
         #   error 'Nao encontrou a descricao do Tipo de Seguro: '
         #        ,l_tiposeguro
         #else
            error 'Erro no SELECT cccty21g03016.',' / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ccty21g03 / ccty21g03_tiposeguro_tipocalculo / ', l_tiposeguro sleep 2
         #end if
      end if

   end if

   let l_cponom = 'clctip'

   if (l_tipocalculo is not null and
       l_tipocalculo > 0)        then

      open cccty21g03016 using l_cponom, l_tipocalculo
      whenever error continue
      fetch cccty21g03016 into l_desctipocalculo
      whenever error stop
      if sqlca.sqlcode <> 0 then
         #if sqlca.sqlcode = notfound then
         #   error 'Nao encontrou a descricao do Tipo de Calculo: '
         #        ,l_tipocalculo
         #else
            error 'Erro no SELECT cccty21g03016.',' / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ccty21g03 / ccty21g03_tiposeguro_tipocalculo / ', l_tipocalculo sleep 2
         #end if
      end if

   end if

   return l_desctiposeguro, l_desctipocalculo

end function













#------------------------------------------------------------#
function ccty21g03_codigoclausula(l_viginc,l_clscod)
#------------------------------------------------------------#
define l_ramcod      like gtakram.ramcod
   define l_viginc  date

         ,l_clscod  like aackcls.clscod
         ,l_clsdes  like aackcls.clsdes

   let l_clsdes = ''

   if  (l_clscod is not null  and
       l_clscod <> " ")      then
      let l_ramcod = 531
      open cccty21g03020 using l_ramcod, l_clscod
      whenever error continue
      fetch cccty21g03020 into l_clsdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
         #   error 'Nao encontrou a descricao do Cod. da Clausula: '
         #        ,l_ramcod, ' / ', l_clscod
         else
            error 'Erro no SELECT cccty21g03020.',' / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ccty21g03 / ccty21g03_codigoclausula / ', l_ramcod, ' / ', l_clscod sleep 2
         end if
      end if

   end if

   return l_clsdes

end function

#-----------------------------------#
function ccty21g03_sem_cnpj(lr_param)
#-----------------------------------#

   define lr_param      record
          codigo        like gsakentidsemcgc.cgcsementcod
   end record

   define lr_retorno    record
          descricao     like gsakentidsemcgc.cgcsementdes
   end record

   initialize lr_retorno.*  to null

   if (lr_param.codigo is not null and
       lr_param.codigo > 0)        then

      open cccty21g03021 using lr_param.*
      whenever error continue
      fetch cccty21g03021 into lr_retorno.*
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode <> notfound then
            error 'Erro no SELECT cccty21g03021.',' / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ccty21g03 / ccty21g03_sem_cnpj / ', lr_param.codigo sleep 2
         end if
      end if

   end if

   return lr_retorno.*

end function




#========================================
function ccty21g03_mes_tarifa(l_vigencia)
#========================================

    define l_vigencia     char(10)
    define l_mes    char(02)
    define l_ano    char(04)
    define l_mes_convert  char(30)

    let l_mes = l_vigencia[4,5]
    let l_ano = l_vigencia[9,10]
  case l_mes
     when "01"
       let l_mes_convert = "Janeiro","/",l_ano
     when "02"
       let l_mes_convert = "Fevereiro","/",l_ano
     when "03"
       let l_mes_convert = "Março","/",l_ano
     when "04"
       let l_mes_convert = "Abril","/",l_ano
     when "05"
       let l_mes_convert = "Maio","/",l_ano
     when "06"
       let l_mes_convert = "Junho","/",l_ano
     when "07"
       let l_mes_convert = "Julho","/",l_ano
     when "08"
       let l_mes_convert = "Agosto","/",l_ano
     when "09"
       let l_mes_convert = "Setembro","/",l_ano
     when "10"
       let l_mes_convert = "Outubro","/",l_ano
     when "11"
       let l_mes_convert = "Novembro","/",l_ano
     when "12"
       let l_mes_convert = "Dezembro","/",l_ano
  end case

  return l_mes_convert

 end function

{#=========================
function ccty21g03_seg2()
#=========================
   define l_retvida   record
      result        smallint
     ,profdesc      like vgokprf.prfdes
   end record
   define l_profdesc    like vgokprf.prfdes

   # PSI 254371 - Tarifa Abril/2010
   define l_pep         char(30)
   define l_pepresdsc   char(10)
   define l_pepnom      char(50)

   initialize l_pep, l_pepresdsc, l_pepnom to null

   #Função Vida - retorna Profissão______
   if w_profissao is not null then
    #call fvdic270_valida_profissao(w_profissao)
    #returning l_retvida.*
    if l_retvida.result = 0 then
          let l_profdesc = l_retvida.profdesc
  else
    let l_profdesc = ""
        end if
   else
    let l_profdesc = ""
   end if
   #_____________________________________

if w_codreg is not null then
   # PSI 254371 - Tarifa Abril/2010
   case w_pep
      when 1 let l_pep = "1 - Sim"
      when 2 let l_pep = "2 - Nao"
      when 3 let l_pep = "3 - Relacionamento proximo"
      otherwise let l_pep = ""
   end case
   let l_pepnom = w_pepnom
   if w_pepres = "S"  then
      let l_pepresdsc = "Sim"
   else
      let l_pepresdsc = "Nao"
   end if
   # PSI 254371 - Tarifa Abril/2010

   let i = i + 1
   let ccty21g03_tela[i]  = "-----DADOS ADICIONAIS DO SEGURADO---------"
   let i = i + 1
   let ccty21g03_tela[i]  = "Codigo do Registro..: "clipped, w_codreg
   let i = i + 1
   let ccty21g03_tela[i]  = "Profissão...........: "clipped, l_profdesc
   let i = i + 1
   let ccty21g03_tela[i]  = "Renda...............: "clipped, w_renda
   let i = i + 1
   #Tarifa Abril/2010
   let ccty21g03_tela[i]  = "Faixa de Renda......: "clipped , w_faixa
   let i = i + 1
   # PSI 254371 - Tarifa Abril/2010
   let ccty21g03_tela[i]  = "PEP.................: "clipped , l_pep
   let i = i + 1
   let ccty21g03_tela[i]  = "Nome PEP............: "clipped , l_pepnom
   let i = i + 1
   #Tarifa Junho/2010
   let ccty21g03_tela[i]  = "CPF PEP.............: "clipped , w_prxrelpescgccpfnum
   let i = i + 1
   let ccty21g03_tela[i]  = "Digito PEP..........: "clipped , w_prxrelpescgccpfdig
   let i = i + 1
   let ccty21g03_tela[i]  = "Grau de relac. PEP..: "clipped , w_pepreldes
   let i = i + 1
   let ccty21g03_tela[i]  = "Estrangeiro residente no Brasil.: "clipped , l_pepresdsc
   let i = i + 1
   # PSI 254371 - Tarifa Abril/2010


   let ccty21g03_tela[i]  = "-----------------------------------------"
   let i = i + 1
end if

end function
}


function ccty21g03_desc_emp(l_codemp)

define l_codemp           smallint
define l_empdsc           char(100)

initialize l_empdsc to null

open c_ccty21g03040_3 using l_codemp
fetch c_ccty21g03040_3 into l_empdsc

return l_empdsc

end function

#PSI244619 - FINAL-----------#

# PSI261378 - inicio
#--------------------------------------#
 function ccty21g03_reg_70(l_corsus,
                          l_ppwprpnum,
                          l_ppwtrxqtd)
#--------------------------------------#
    define l_corsus    like gppmnetprpaut.corsus
    define l_ppwprpnum like gppmnetprpaut.ppwprpnum
    define l_ppwtrxqtd like gppmnetprpaut.ppwtrxqtd

    let m_linha70 = null

    whenever error continue
        open cccty21g03042 using l_corsus,
                                l_ppwprpnum,
                                l_ppwtrxqtd
       fetch cccty21g03042 into m_linha70
    whenever error stop

    if  sqlca.sqlcode <> 0 then
        display "Registro 70 (cccty21g03042) nao encontrado para o corretor: ", l_corsus clipped,
                " proposta ppw: ", l_ppwprpnum clipped,
                " qtd. transmissoes: ", l_ppwtrxqtd clipped, ". Sqlca.sqlcode: ", sqlca.sqlcode
    end if

    close cccty21g03042

end function

#--------------------------------------#
 function ccty21g03_reg_71(l_corsus,
                          l_ppwprpnum,
                          l_ppwtrxqtd)
#--------------------------------------#
    define l_corsus    like gppmnetprpaut.corsus
    define l_ppwprpnum like gppmnetprpaut.ppwprpnum
    define l_ppwtrxqtd like gppmnetprpaut.ppwtrxqtd

    let m_linha71 = null

    whenever error continue
        open cccty21g03043 using l_corsus,
                                l_ppwprpnum,
                                l_ppwtrxqtd
       fetch cccty21g03043 into m_linha71
    whenever error stop

    if  sqlca.sqlcode <> 0 then
        display "Registro 71 (cccty21g03043) nao encontrado para o corretor: ", l_corsus clipped,
                " proposta ppw: ", l_ppwprpnum clipped,
                " qtd. transmissoes: ", l_ppwtrxqtd clipped, ". Sqlca.sqlcode: ", sqlca.sqlcode
    end if

    close cccty21g03043

end function

#psi261378 FIM





#PSI252743 - fim




#---------------------------------------------------------------------------#
function ppwc028_tp_alteracao(w_tp)
#---------------------------------------------------------------------------#

define w_tp    smallint

   case w_tp
        when 1   return "Inalterado"
        when 2   return "Alterar"
        when 3   return "Incluir"
        when 4   return "Excluir"
        when 5   return "Nao Contratado"
   end case

   return "indefinido"

end function



#=====================================
function cty21g03_inicializa_l_count()
#=====================================

      let m_count00 = 1
      let m_count01 = 1
      let m_count04 = 1
      let m_count05 = 1
      let m_count06 = 1
      let m_count07 = 1
      let m_count08 = 1
      let m_count09 = 1
      let m_count10 = 1
      let m_count11 = 1
      let m_count12 = 1
      let m_count13 = 1
      let m_count14 = 1
      let m_count15 = 1
      let m_count16 = 1
      let m_count17 = 1
      let m_count18 = 1
      let m_count19 = 1
      let m_count20 = 1
      let m_count21 = 1
      let m_count22 = 1
      let m_count23 = 1
      let m_count24 = 1
      let m_count25 = 1
      let m_count27 = 1
      let m_count29 = 1
      let m_count30 = 1
      let m_count31 = 1
      let m_count32 = 1
      let m_count34 = 1
      let m_count35 = 1
      let m_count36 = 1
      let m_count37 = 1
      let m_count38 = 1
      let m_count39 = 1
      let m_count40 = 1
      let m_count41 = 1
      let m_count42 = 1
      let m_count43 = 1
      let m_count44 = 1
      let m_count45 = 1
      let m_count46 = 1
      let m_count47 = 1
      let m_count48 = 1
      let m_count49 = 1
      let m_count50 = 1
      let m_count52 = 1
      let m_count53 = 1
      let m_count54 = 1
      let m_count55 = 1
      let m_count56 = 1
      let m_count57 = 1
      let m_count58 = 1
      let m_count59 = 1
      let m_count60 = 1
      let m_count61 = 1
      let m_count62 = 1
      let m_count63 = 1
      let m_count64 = 1
      let m_count66 = 1
      let m_count67 = 1

end function

#==================================
function cty21g03_cria_temp()
#==================================

  if m_prep is null   or
      m_prep <> "S"    then
      call ccty21g03_prepare()
   end if

   create temp table tmp_00
                   ( SeqProposta    smallint
                    ,Seq            smallint
                    ,PropostaPPW    char(13)
                    ,CodigoReg      char(2)
                    ,Susep          char(100)
                    ,DataExtracao   char(10)
                    ,Filler         char(1)
                    ,HoraExtracao   char(8)
                    ,Versao         char(19)
                    ,PRMD           char(62)
                   ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp00_idx on tmp_00
                    (Seq)
   end if


   ---------------------------------------------
   create temp table tmp_01
                   (  SeqProposta        smallint
                    , Seq                smallint
                    , CodigoReg          char(2)
                    , OrigemPrincipal    char(2)
                    , PropPrincipal      char(8)
                    , SucRenov           char(2)
                    , AplRenov           char(9)
                    , TPendosso          char(100)
                    , TXTendosso         char(3)
                    , QtdItens           char(4)
                    , corresp            char(1)
                    , FormaPgto          char(100)
                    , QtdParcelas        char(2)
                    , VencParc1          char(10)
                    , vigencia           char(10)
                    , IniVig             char(10)
                    , FimVig             char(10)
                    , tiposeguro         char(100)
                    , tipocalculo        char(100)
                    , MoedaPremio        char(3)
                    , SolicAnalise       char(22)
                    , Boleto             char(1)
                    , Espaco             char(11)
                    , CodOperacao        char(2)
                    , FlagEmissao        char(1)
                    , Seguradora         char(100)
                    , EmBranco           char(7)
                    , TarifaPPW          char(12)
                    , FlagPOE            char(1)
                   ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp01_idx on tmp_01
                    (Seq)
   end if

  ------------------------------------------------
  create temp table tmp_04
                   ( SeqProposta         smallint
                   , Seq                  char(10)
                   , CodigoReg            char(2)
                   , Susep                char(100)
                   , participCorretor     char(10)
                   , FlagCorr             char(1)
                  ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp04_idx on tmp_04
                    (Seq)
   end if

  ------------------------------------------------
   create temp table tmp_05
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , CodigoReg             char(2)
                 , CodSegurado           char(8)
                 , NomeSegurado          char(50)
                 , TipoPessoa            char(100)
                 , CNPJ_CPF              char(20)
                 , DataNascimento        char(10)
                 , sexo                  char(09)
                 , EstadoCivil           char(100)
                 , MotivoSemCNPJ         char(100)
                 , EmBranco              char(15)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp05_idx on tmp_05
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp_06
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , CodigoReg             char(2)
                 , TipoEndereco          char(100)
                 , TipoLogradouro        char(100)
                 , Logradouro            char(40)
                 , Numero                char(5)
                 , Complemento           char(15)
                 , CEP                   char(10)
                 , Espaco                char(32)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp06_idx on tmp_06
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp_07
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , FlagEndereco          char(1)
                 , Bairro                char(20)
                 , Cidade                char(20)
                 , UF                    char(2)
                 , DDD                   char(4)
                 , Telefone              char(15)
                 , Espaco                char(44)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp07_idx on tmp_07
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_08
                 ( SeqProposta             smallint
                 , Seq                     smallint
                 , CodigoReg               char(2)
                 , NumeroItem              char(7)
                 , NumeroOrigem            char(2)
                 , PropostaIndividual      char(8)
                 , ClasseBonus             char(2)
                 , ClasseLocalizacao       char(100)
                 , TrafegoHabitual         char(45)
                 , IncVigAnterior          char(10)
                 , FinVigAnterior          char(10)
                 , Seguradora              char(100)
                 , SucursalItem            char(3)
                 , AplDoItem               char(10)
                 , Espaco                  char(2)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp08_idx on tmp_08
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_09
                 ( SeqProposta              smallint
                 , Seq                      smallint
                 , CodigoReg                char(2)
                 , ObsProposta              char(100)
                 , Sequencia                char(2)
                 , Espaco                   char(54)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp09_idx on tmp_09
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_10
                     ( SeqProposta              smallint
                     , Seq                      smallint
                     , CodigoReg                char(2)
                     , CodVeiculo               char(5)
                     , AnoFabricacao            char(4)
                     , AnoModelo                char(4)
                     , Placa                    char(7)
                     , Chassi                   char(20)
                     , Renavam                  char(50)
                     , TipoUso                  char(100)
                     , Veiculo0km               char(1)
                     , TipoVistoria             char(100)
                     , VPCOBprovisoria          char(9)
                     , CapacidadePassageiros    char(2)
                     , FlagAutoRevenda          char(1)
                     , FlagAutoNovo             char(1)
                     , CategoriaTarifada        char(100)
                     , combustivel              char(100)
                     , QtdePortas               char(1)
                     , DataVistoria             char(10)
                     , VeiculoBlindado          char(100)
                     , FlagChassiRemarc         char(1)
                     , CodigoTabelaFipe         char(8)
                     , CodigoRenovacao          char(25)
                     )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp10_idx on tmp_10
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_11
               (  SeqProposta              smallint
                , Seq                      smallint
                , CodigoReg                char(2)
                , NotaFiscal               char(8)
                , DataEmissao              char(10)
                , DataSaidaVeiculo         char(10)
                , CodConcessionaria        char(5)
                , NomeConcessionaria       char(50)
                , ValorNota                char(16)
                , Espaco                   char(28)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp11_idx on tmp_11
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_12
               (  SeqProposta            smallint
                , Seq                    smallint
                , CodigoReg              char(2)
                , DataRealizacaoCalc     char(10)
                , Franquia               char(100)
                , Cobertura              char(100)
                , FranquiaCasco          char(100)
                , ISCalculo              char(100)
                , IsencaoImpostos        char(100)
                , ISdaBlindagem          char(100)
                , PremioLiqCasco         char(100)
                , CotacaoMotorShow       char(1)
                , PercentISCasco         char(10)
                , PercentISBlindagem     char(10)
                , FatorDepreciacao       char(10)
                , ValorBasico            char(100)
                , ValorMaximo            char(100)
                , TabelaUtilizada        char(100)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp12_idx on tmp_12
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_13
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizCalc      char(10)
                , RefAcessorio        char(100)
                , TipoAcessorio       char(100)
                , ValorFranquia       char(20)
                , ISFranquia          char(20)
                , SeqAcessorio        char(2)
                , PremioLiqAcess      char(20)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp13_idx on tmp_13
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_14
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizaCalc     char(10)
                , ClasseFranquia      char(2)
                , ValorFranquiaDM     char(20)
                , ISDM                char(20)
                , ValorFranquiaDC     char(20)
                , ISDC                char(20)
                , PremioLiqRCFDM      char(20)
                , PremioLiqRCFDC      char(20)
                , Espaco              char(4)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp14_idx on tmp_14
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_15
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizaCalc     char(10)
                , ISInvalidez         char(5)
                , ISMorte             char(20)
                , ISDMH               char(20)
                , PremioLiqApp        char(20)
                , Espaco              char(36)
                ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp15_idx on tmp_15
                    (Seq)
   end if
{------------------------------------------------
 if m_create16 <> 1 then
   let m_create16 = 1

   create temp table tmp_16
                ( SeqProposta               smallint
                , Seq                       smallint
                , CodigoReg                char(2)
                , CodDesconto              char(100)
                , CoeficienteSemPremio     char(20)
                , CodDesconto2             char(100)
                , CoeficienteSemPremio2    char(20)
                , CodDesconto3             char(100)
                , CoeficienteSemPremio3    char(20)
                , CodDesconto4             char(100)
                , CoeficienteSemPremio4    char(20)
                , CodDesconto5             char(100)
                , CoeficienteSemPremio5    char(20)
                , CodDesconto6             char(100)
                , CoeficienteSemPremio6    char(20)
                , CodDesconto7             char(100)
                , CoeficienteSemPremio7    char(20)
                , CodDesconto8             char(100)
                , CoeficienteSemPremio8    char(20)
                , CodDesconto9             char(100)
                , CoeficienteSemPremio9    char(20)
                , CodDesconto10            char(100)
                , CoeficienteSemPremio10   char(20)
                , CodDesconto11            char(100)
                , CoeficienteSemPremio11   char(20)
                , CodDesconto12            char(100)
                , CoeficienteSemPremio12   char(20)
                , CodDesconto13            char(100)
                , CoeficienteSemPremio13   char(20)
                , CodDesconto14            char(100)
                , CoeficienteSemPremio14   char(20)
                , CodDesconto15            char(100)
                , CoeficienteSemPremio15   char(20)
                , Espaco                   char(1)
                ) with no log
 else
  delete from tmp_16
 end if
}
------------------------------------------------
if m_create17 <> 1 then
   let m_create17 = 1

   create temp table tmp_17
                ( SeqProposta               smallint
                , Seq                       smallint
                , CodigoReg                 char(2)
                , CodClausula               char(100)
                , CoeficienteClausula       char(20)
                , CobrancaSN                char(1)
                , IncVig                    char(10)
                , FinVig                    char(10)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp17_idx on tmp_17
                         (Seq)
   end if
 else
  delete from tmp_17
 end if

------------------------------------------------
   create temp table tmp_18
                ( SeqProposta              smallint
                , Seq                      smallint
                , CodigoReg                char(2)
                , CodClausula              char(3)
                , txtClausula              char(50)
                , seqTexto                 char(2)
                , Espaco                   char(51)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp18_idx on tmp_18
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp_19
     ( SeqProposta      smallint
      ,CodigoReg        char(2)
      ,CodigoProduto    char(2)
      ,CodigoQuestao    char(80)
      ,CodigoResposta   char(80)
      ,SubResposta      char(80)
     )with no log
#   if sqlca.sqlcode = 0 then
#      create unique index tmp19_idx on tmp_19
#                    (Seq)
#   end if
------------------------------------------------
   create temp table tmp_20
      ( SeqProposta        smallint
       ,Seq                smallint
       ,PoeConcorrencia    char(3)
       ,CodigoReg          char(2)
       ,TipoProduto        char(2)
     )with no log
   if sqlca.sqlcode = 0 then
     # create unique index tmp20_idx on tmp_20
     #               (Seq)
   end if
------------------------------------------------
   create temp table tmp_20a
      ( SeqProposta        smallint
       ,CodigoQuestao      char(80)
       ,CodigoResposta     char(80)
       ,TextoResposta      char(80)
     )with no log
   if sqlca.sqlcode = 0 then
      #create unique index tmp20a_idx on tmp_20a
      #              (CodigoQuestao)
   end if
------------------------------------------------
   create temp table tmp_21
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Nome           char(40)
                  , CPF            char(15)
                  , seqcdt         char(2)
                  , Rg             char(15)
                  , CNH            char(15)
                  , CATCNH         char(15)
                  , Espaco         char(5)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp21_idx on tmp_21
                    (Seq)
   end if

   create temp table tmp_22
                 (  SeqProposta           smallint
                  , CodDesconto           char(100)
                  , CoeficienteSemPremio  char(8)
                 )with no log
   if sqlca.sqlcode = 0 then
     # create unique index tmp22_idx on tmp_22
     #               (CodDesconto)
   end if

  create temp table tmp_24
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , numacei        char(10)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp24_idx on tmp_24
                    (Seq)
   end if

  create temp table tmp_27
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , idcartao       char(11)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp27_idx on tmp_27
                    (Seq)
   end if

create temp table tmp_29
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Finalidade    char(18)
                  , Encargos      char(18)
                  , Totalbruto    char(18)
                  , Espaco        char(62)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp29_idx on tmp_29
                    (Seq)
   end if


create temp table tmp_30
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Debito       char(1)
                  , banco        char(4)
                  , agencia      char(5)
                  , conta        char(15)
                  , contadig     char(5)
                  , seguroroubo  char(1)
                  , CPF          char(20)
                  , nome         char(40)
                  , data         char(10)
                  , parentesco   char(1)
                  , sexo         char(1)
                  )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp30_idx on tmp_30
                    (Seq)
   end if

create temp table tmp_31
            (  SeqProposta    smallint
              , Seq            smallint
              , CodigoReg      char(2)
              , custoaplanual   char(15)
              , coefIOF         char(15)
              , premiovista     char(15)
              , taxacasco       char(9)
              , tiposeg         char(1)
              , vlrparc1        char(15)
              , vlrdemais       char(15)
              , vlrjuros        char(15)
              , espaco          char(6)
              )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp31_idx on tmp_31
                    (Seq)
   end if

create temp table tmp_32
       ( SeqProposta  smallint
        ,Seq          smallint
        ,CodigoReg    char(2)
        ,RG           char(10)
        ,Cnh          char(15)
        ,catcnh       char(15)
        ,email        char(60)
        ,tpenviofront char(12)
        ,espaco       char(5)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp32_idx on tmp_32
                    (Seq)
   end if

create temp table tmp_35
       ( SeqProposta  smallint
        ,Seq          smallint
        ,CodigoReg    char(2)
        ,codbanco     char(3)
        ,agencia      char(4)
        ,produtor     char(10)
        ,pontovenda   char(10)
        ,postoserv    char(10)
        ,segcliente   char(2)
        ,espaco       char(66)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp35_idx on tmp_35
                    (Seq)
   end if


------------------------------------------------
   create temp table tmp_36
      (SeqProposta       smallint
      ,Seq               smallint
      ,CodigoReg         char(2)
      ,IsMorte           char(16)
      ,IsInvalidez       char(16)
      ,PremioLiqVidaInd  char(16)
      ,Espaco            char(61)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp36_idx on tmp_36
                    (Seq)
   end if


------------------------------------------------
   create temp table tmp_37
      (SeqProposta          smallint
      ,Seq                  smallint
      ,CodigoReg            char(2)
      ,NomeBeneficiario     char(50)
      ,GrauParentesco       char(2)
      ,Espaco               char(18)
      ,ParticipBeneficiario char(6)
      ,Espaco2              char(31)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp37_idx on tmp_37
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_38
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg         char(2)
      ,DataAtendimento   char(10)
      ,HoraAtendimento   char(5)
      ,LocalAtendimento  char(50)
      ,TipoServico       char(40)
      ,Espaco            char(1)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp38_idx on tmp_38
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_39
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg           char(2)
      ,TipoInformacao      char(2)
      ,CodigoInformacao    char(4)
      ,QtdeServico         char(2)
      ,TextoComplementar   char(98)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp39_idx on tmp_39
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_40
      (SeqProposta         smallint
      ,Seq                 smallint
      ,SequenciaLocal      char(2)
      ,NumeroSeqRisco      char(6)
      ,NomeBloco           char(60)
      ,QtdePavimentos      char(2)
      ,QtdeVagas           char(3)
      ,TipoConstrucao      char(8)
      ,QtdeAptosCondominio char(3)
      ,ValorRiscoDeclarado char(15)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp40_idx on tmp_40
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_41
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,MeioPagamento    char(2)
      ,NumeroParcela    char(2)
      ,CartaoCredito    char(16)
      ,VenctoCartao     char(6)
      ,NumeroBanco      char(4)
      ,NumeroAgencia    char(5)
      ,ContaCorrente    char(15)
      ,DigitoCC         char(5)
      ,DataVencto       char(10)
      ,ValorParcela     char(12)
      ,ChequeNum        char(10)
      ,PracaCheque      char(2)
      ,CnpjCpfCC        char(20)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp41_idx on tmp_41
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_42
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,Fumante          char(1)
      ,CodigoOperacao   char(3)
      ,AtualMonetaria   char(1)
      ,NomeInformar     char(60)
      ,Telefone         char(12)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp42_idx on tmp_42
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_43
      (SeqProposta            smallint
      ,Seq                    smallint
      ,CodigoReg              char(2)
      ,Empresa                char(30)
      ,TempoAnosMeses         char(5)
      ,Produto                char(5)
      ,Renda                  char(13)
      ,Premio                 char(16)
      ,QtdeParcelasAutoVida   char(2)
      ,FormaPagtoRenovacao    char(45)
      ,QtdeParcelasRenovacao  char(2)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp43_idx on tmp_43
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_44
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,AssistFuneral    char(1)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp44_idx on tmp_44
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_44a
      (SeqProposta      smallint
      ,Cobertura        char(16)
      )with no log
   if sqlca.sqlcode = 0 then
  #    create unique index tmp44a_idx on tmp_44a
  #                  (SeqProposta)
   end if

------------------------------------------------
   create temp table tmp_45
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,NumeroNegociacao char(10)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp45_idx on tmp_45
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_46
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,TipoEndereco     char(30)
      ,TipoLogradouro   char(30)
      ,Logradouro       char(40)
      ,Numero           char(5)
      ,Complemento      char(15)
      ,CEP              char(9)
      ,Espaco           char(32)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp46_idx on tmp_46
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_47
      (SeqProposta      smallint
      ,Seq              smallint
      ,TipoTexto        char(3)
      ,SequenciaTexto   char(2)
      ,DescricaoTexto   char(10)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp47_idx on tmp_47
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_48
      (SeqProposta      smallint
      ,Seq              smallint
      ,FlagEndereco  char(1)
      ,Bairro        char(20)
      ,Cidade        char(20)
      ,UF            char(2)
      ,Email         char(60)
      ,Espaco        char(3)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp48_idx on tmp_48
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_49
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,TipoTelefone     char(2)
      ,DddTelefone      char(4)
      ,NumeroTelefone   char(10)
      ,RamalTelefone    char(10)
      ,Recados          char(40)
      ,Espaco           char(40)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp49_idx on tmp_49
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_50
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg           char(2)
      ,Veiculo             char(5)
      ,AnoFabricacao       char(4)
      ,AnoModelo           char(4)
      ,Flag0Km             char(1)
      ,Uso                 char(2)
      ,Categoria           char(2)
      ,QtdePassageiros     char(2)
      ,PremioCasco         char(14)
      ,PremioAcessorio     char(14)
      ,PremioDM            char(14)
      ,PremioDP            char(14)
      ,PremioDMO           char(14)
      ,PremioAPP           char(14)
      ,AlteracaoCasco      char(18)
      ,AlteracaoAcessorios char(18)
      ,AlteracaoDM         char(18)
      ,AlteracaoDP         char(18)
      ,AlteracaoDMO        char(18)
      ,AlteracaoAPP        char(18)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp50_idx on tmp_50
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_52
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoRegistro   char(2)
      ,TipoTelefone     char(2)
      ,DddTelefone      char(4)
      ,NumeroTelefone   char(10)
      ,RamalTelefone    char(10)
      ,Recados          char(40)
      ,Espaco           char(40)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp52_idx on tmp_52
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_53
               (SeqProposta         smallint
               ,Seq                 smallint
               ,IdentifConfirmBonus char(14)
               ,NumAgendamentoDAF   char(10)
               ,KitGas              char(80)
               ,CambioAutomatico    char(3)
               ,VeicFinanciado      char(3)
               ,UtilizacaoVeiculo   char(20)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp53_idx on tmp_53
                    (Seq)
   end if

------------------------------------------------
if m_create54 <> 1 then
   let m_create54 = 1

   create temp table tmp_54
               (SeqProposta            smallint
               ,Seq                    smallint
               ,CodigoReg              char(2)
               ,CodigoClausula         char(50)
               ,CoeficienteClausula    char(7)
               ,CobrancaSN             char(1)
               ,IncVigencia            char(10)
               ,FinalVigencia          char(10)
               ,PremioLiquidoClausula  char(16)
               ,PremioTotalClausulas   char(16)
               ,Espaco                 char(62)
        )with no log
 if sqlca.sqlcode = 0 then
      create unique index tmp54_idx on tmp_54
                    (Seq)
   end if

else
  delete from tmp_54
end if


------------------------------------------------
   create temp table tmp_55
               (SeqProposta         smallint
               ,Seq                 smallint
               ,NumeroPpw           char(12)
               ,SenhaUtilizada      char(15)
               ,ClasseLocalizacao   char(2)
               ,CodigoVeiculo       char(5)
               ,DataCalculo         char(8)
               ,DescontoOffLine     char(3)
               ,Criptografia        char(20)
               ,CpfProponente       char(12)
               ,OrdemProponente     char(4)
               ,DigitoProponente    char(2)
               )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp55_idx on tmp_55
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_55a
               (SeqProposta         smallint
               ,CpfCondutor         char(9)
               ,DigitoCpfCondutor   char(2)
               )with no log
   if sqlca.sqlcode = 0 then
  #    create unique index tmp55a_idx on tmp_55a
  #                  (SeqProposta)
   end if

------------------------------------------------
   create temp table tmp_56
               (SeqProposta         smallint
               ,Seq                 smallint
               ,SequenciaLocal    char(2)
               ,CodigoQuestao     char(50)
               ,DescricaoResposta char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp56_idx on tmp_56
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_58
               (SeqProposta         smallint
               ,Seq                 smallint
               ,CodigoReg           char(2)
               ,VersaoDllCalculo    char(8)
               ,PatrimonioLiquido   char(40)
               ,RecOperacBrutaAnual char(40)
               ,AdminControlProcur  char(45)
               ,TipoEmpresa         char(40)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp58_idx on tmp_58
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_59
               (  SeqProposta       smallint
                , Seq               smallint
                , TipoProponente char(1)
                , Nome           char(50)
                , TipoPessoa     char(1)
                , CpfCnpj        char(9)
                , Ordem          char(4)
                , Digito         char(2)
                , SemCpfCnpjPor  char(50)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp59_idx on tmp_59
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_60
               (  SeqProposta       smallint
                , Seq               smallint
                , DescricaoTexto    char(200)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp60_idx on tmp_60
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_61
               (  SeqProposta          smallint
                , Seq                  smallint
                , FinalidadeEmissao    char(15)
                , FinalidadeEncargos   char(15)
                , ValorTotalPremio     char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp61_idx on tmp_61
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_62
               (  SeqProposta             smallint
                , Seq                     smallint
                , TipoFormaPagto          char(50)
                , NumeroParcela           char(2)
                , NumeroCartaoCredito     char(16)
                , VencimentoCartaoCredito char(6)
                , NumeroBanco             char(4)
                , NumeroAgencia           char(5)
                , NumeroContaCorrente     char(15)
                , DigitoContaCorrente     char(1)
                , DataVencimento          char(10)
                , ValorParcela            char(12)
                , NumeroCheque            char(10)
                , PracaCheque             char(2)
                , CnpjCpfCorrentista      char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp62_idx on tmp_62
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_63
               (  SeqProposta    smallint
                , Seq            smallint
                , CustoApolice   char(15)
                , IOF            char(15)
                , PremioVista    char(15)
                , TaxaCasco      char(9)
                , SeguroMensal   char(1)
                , Parcelas1      char(15)
                , ParcelasDemais char(15)
                , ParcelasJuros  char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp63_idx on tmp_63
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_64
               (  SeqProposta             smallint
                , Seq                     smallint
                , TipoFormaPagto          char(50)
                , NumeroParcela           char(2)
                , NumeroCartaoCredito     char(16)
                , VencimentoCartaoCredito char(6)
                , NumeroBanco             char(4)
                , NumeroAgencia           char(5)
                , NumeroContaCorrente     char(15)
                , DigitoContaCorrente     char(5)
                , DataVencimento          char(10)
                , ValorParcela            char(12)
                , NumeroCheque            char(10)
                , PracaCheque             char(2)
                , CnpjCpfCorrentista      char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp64_idx on tmp_64
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_66
               (  SeqProposta        smallint
                , Seq                smallint
                , FlagTransitoGentil char(1)
                , CnhTransitoGentil  char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp66_idx on tmp_66
                    (Seq)
   end if

------------------------------------------------
   create temp table tmp_67
               (  SeqProposta    smallint
                , Seq            smallint
           , CodigoPEP      char(1)
           ,  PEP            char(30)
           ,  NomePEP        char(50)
           ,  CpfPEP         char(12)
           ,  DigitoCpfPEP   char(2)
           ,  GrauRelacPEP   char(1)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp67_idx on tmp_67
                    (Seq)
   end if


end function


#==================================
function cty21g03_cria_temp_prop1()
#==================================

  if m_prep is null   or
      m_prep <> "S"    then
      call ccty21g03_prepare()
   end if

   create temp table tmp00_1
                   ( SeqProposta    smallint
                    ,Seq            smallint
                    ,PropostaPPW    char(13)
                    ,CodigoReg      char(2)
                    ,Susep          char(100)
                    ,DataExtracao   char(10)
                    ,Filler         char(1)
                    ,HoraExtracao   char(8)
                    ,Versao         char(19)
                    ,PRMD           char(62)
                   ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp00_1_idx on tmp00_1
                    (Seq)
   end if
   ---------------------------------------------
   create temp table tmp01_1
                   (  SeqProposta        smallint
                    , Seq                smallint
                    , CodigoReg          char(2)
                    , OrigemPrincipal    char(2)
                    , PropPrincipal      char(8)
                    , SucRenov           char(2)
                    , AplRenov           char(9)
                    , TPendosso          char(100)
                    , TXTendosso         char(3)
                    , QtdItens           char(4)
                    , corresp            char(1)
                    , FormaPgto          char(100)
                    , QtdParcelas        char(2)
                    , VencParc1          char(10)
                    , vigencia           char(10)
                    , IniVig             char(10)
                    , FimVig             char(10)
                    , tiposeguro         char(100)
                    , tipocalculo        char(100)
                    , MoedaPremio        char(3)
                    , SolicAnalise       char(22)
                    , Boleto             char(1)
                    , Espaco             char(11)
                    , CodOperacao        char(2)
                    , FlagEmissao        char(1)
                    , Seguradora         char(100)
                    , EmBranco           char(7)
                    , TarifaPPW          char(12)
                    , FlagPOE            char(1)
                   ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp01_1_idx on tmp01_1
                    (Seq)
   end if
  -----------------------------------------------------------
  create temp table tmp04_1
                   ( SeqProposta         smallint
                   , Seq                  char(10)
                   , CodigoReg            char(2)
                   , Susep                char(100)
                   , participCorretor     char(10)
                   , FlagCorr             char(1)
                  ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp04_1_idx on tmp04_1
                    (Seq)
   end if
  ------------------------------------------------
  create temp table tmp05_1
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , CodigoReg             char(2)
                 , CodSegurado           char(8)
                 , NomeSegurado          char(50)
                 , TipoPessoa            char(100)
                 , CNPJ_CPF              char(20)
                 , DataNascimento        char(10)
                 , sexo                  char(09)
                 , EstadoCivil           char(100)
                 , MotivoSemCNPJ         char(100)
                 , EmBranco              char(15)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp05_1_idx on tmp05_1
                    (Seq)
   end if
 --------------------------------------------------
   create temp table tmp06_1
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , CodigoReg             char(2)
                 , TipoEndereco          char(100)
                 , TipoLogradouro        char(100)
                 , Logradouro            char(40)
                 , Numero                char(5)
                 , Complemento           char(15)
                 , CEP                   char(10)
                 , Espaco                char(32)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp06_1_idx on tmp06_1
                    (Seq)
   end if
  ------------------------------------------------
   create temp table tmp07_1
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , FlagEndereco          char(1)
                 , Bairro                char(20)
                 , Cidade                char(20)
                 , UF                    char(2)
                 , DDD                   char(4)
                 , Telefone              char(15)
                 , Espaco                char(44)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp07_1_idx on tmp07_1
                    (Seq)
   end if
  ------------------------------------------------
  create temp table tmp08_1
                 ( SeqProposta             smallint
                 , Seq                     smallint
                 , CodigoReg               char(2)
                 , NumeroItem              char(7)
                 , NumeroOrigem            char(2)
                 , PropostaIndividual      char(8)
                 , ClasseBonus             char(2)
                 , ClasseLocalizacao       char(100)
                 , TrafegoHabitual         char(45)
                 , IncVigAnterior          char(10)
                 , FinVigAnterior          char(10)
                 , Seguradora              char(100)
                 , SucursalItem            char(3)
                 , AplDoItem               char(10)
                 , Espaco                  char(2)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp08_1_idx on tmp08_1
                    (Seq)
   end if
------------------------------------------------
 create temp table tmp09_1
                 ( SeqProposta              smallint
                 , Seq                      smallint
                 , CodigoReg                char(2)
                 , ObsProposta              char(100)
                 , Sequencia                char(2)
                 , Espaco                   char(54)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp09_1_idx on tmp09_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp10_1
                     ( SeqProposta              smallint
                     , Seq                      smallint
                     , CodigoReg                char(2)
                     , CodVeiculo               char(5)
                     , AnoFabricacao            char(4)
                     , AnoModelo                char(4)
                     , Placa                    char(7)
                     , Chassi                   char(20)
                     , Renavam                  char(50)
                     , TipoUso                  char(100)
                     , Veiculo0km               char(1)
                     , TipoVistoria             char(100)
                     , VPCOBprovisoria          char(9)
                     , CapacidadePassageiros    char(2)
                     , FlagAutoRevenda          char(1)
                     , FlagAutoNovo             char(1)
                     , CategoriaTarifada        char(100)
                     , combustivel              char(100)
                     , QtdePortas               char(1)
                     , DataVistoria             char(10)
                     , VeiculoBlindado          char(100)
                     , FlagChassiRemarc         char(1)
                     , CodigoTabelaFipe         char(8)
                     , CodigoRenovacao          char(25)
                     )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp10_1_idx on tmp10_1
                    (Seq)
   end if

 ------------------------------------------------
create temp table tmp11_1
               (  SeqProposta              smallint
                , Seq                      smallint
                , CodigoReg                char(2)
                , NotaFiscal               char(8)
                , DataEmissao              char(10)
                , DataSaidaVeiculo         char(10)
                , CodConcessionaria        char(5)
                , NomeConcessionaria       char(50)
                , ValorNota                char(16)
                , Espaco                   char(28)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp11_1_idx on tmp11_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp12_1
               (  SeqProposta            smallint
                , Seq                    smallint
                , CodigoReg              char(2)
                , DataRealizacaoCalc     char(10)
                , Franquia               char(100)
                , Cobertura              char(100)
                , FranquiaCasco          char(100)
                , ISCalculo              char(100)
                , IsencaoImpostos        char(100)
                , ISdaBlindagem          char(100)
                , PremioLiqCasco         char(100)
                , CotacaoMotorShow       char(1)
                , PercentISCasco         char(10)
                , PercentISBlindagem     char(10)
                , FatorDepreciacao       char(10)
                , ValorBasico            char(100)
                , ValorMaximo            char(100)
                , TabelaUtilizada        char(100)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp12_1_idx on tmp12_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp13_1
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizCalc      char(10)
                , RefAcessorio        char(100)
                , TipoAcessorio       char(100)
                , ValorFranquia       char(20)
                , ISFranquia          char(20)
                , SeqAcessorio        char(2)
                , PremioLiqAcess      char(20)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp13_1_idx on tmp13_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp14_1
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizaCalc     char(10)
                , ClasseFranquia      char(2)
                , ValorFranquiaDM     char(20)
                , ISDM                char(20)
                , ValorFranquiaDC     char(20)
                , ISDC                char(20)
                , PremioLiqRCFDM      char(20)
                , PremioLiqRCFDC      char(20)
                , Espaco              char(4)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp14_1_idx on tmp14_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp15_1
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizaCalc     char(10)
                , ISInvalidez         char(5)
                , ISMorte             char(20)
                , ISDMH               char(20)
                , PremioLiqApp        char(20)
                , Espaco              char(36)
                ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp15_1_idx on tmp15_1
                    (Seq)
   end if
{------------------------------------------------   helder
   create temp table tmp16_1
                ( SeqProposta               smallint
                , Seq                       smallint
                , CodigoReg                char(2)
                , CodDesconto              char(100)
                , CoeficienteSemPremio     char(20)
                , CodDesconto2             char(100)
                , CoeficienteSemPremio2    char(20)
                , CodDesconto3             char(100)
                , CoeficienteSemPremio3    char(20)
                , CodDesconto4             char(100)
                , CoeficienteSemPremio4    char(20)
                , CodDesconto5             char(100)
                , CoeficienteSemPremio5    char(20)
                , CodDesconto6             char(100)
                , CoeficienteSemPremio6    char(20)
                , CodDesconto7             char(100)
                , CoeficienteSemPremio7    char(20)
                , CodDesconto8             char(100)
                , CoeficienteSemPremio8    char(20)
                , CodDesconto9             char(100)
                , CoeficienteSemPremio9    char(20)
                , CodDesconto10            char(100)
                , CoeficienteSemPremio10   char(20)
                , CodDesconto11            char(100)
                , CoeficienteSemPremio11   char(20)
                , CodDesconto12            char(100)
                , CoeficienteSemPremio12   char(20)
                , CodDesconto13            char(100)
                , CoeficienteSemPremio13   char(20)
                , CodDesconto14            char(100)
                , CoeficienteSemPremio14   char(20)
                , CodDesconto15            char(100)
                , CoeficienteSemPremio15   char(20)
                , Espaco                   char(1)
                ) with no log
                }
------------------------------------------------
   create temp table tmp17_1
                ( SeqProposta               smallint
                , Seq                       smallint
                , CodigoReg                 char(2)
                , CodClausula               char(100)
                , CoeficienteClausula       char(20)
                , CobrancaSN                char(1)
                , IncVig                    char(10)
                , FinVig                    char(10)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp17_1_idx on tmp17_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp18_1
                ( SeqProposta              smallint
                , Seq                      smallint
                , CodigoReg                char(2)
                , CodClausula              char(3)
                , txtClausula              char(50)
                , seqTexto                 char(2)
                , Espaco                   char(51)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp18_1_idx on tmp18_1
                    (Seq)
   end if
------------------------------------------------
    create temp table tmp19_1
     ( SeqProposta      smallint
      ,CodigoReg        char(2)
      ,CodigoProduto    char(2)
      ,CodigoQuestao    char(80)
      ,CodigoResposta   char(80)
      ,SubResposta      char(80)
     )with no log
#   if sqlca.sqlcode = 0 then
#      create unique index tmp19_1_idx on tmp19_1
#                    (Seq)
#   end if

------------------------------------------------
   create temp table tmp20_1
      ( SeqProposta        smallint
       ,Seq                smallint
       ,PoeConcorrencia    char(3)
       ,CodigoReg          char(2)
       ,TipoProduto        char(2)
     )with no log
  # if sqlca.sqlcode = 0 then
  #    create unique index tmp20_1_idx on tmp20_1
  #                  (Seq)
  # end if
------------------------------------------------
   create temp table tmp20a_1
      ( SeqProposta        smallint
       ,CodigoQuestao      char(80)
       ,CodigoResposta     char(80)
       ,TextoResposta      char(80)
     )with no log
   if sqlca.sqlcode = 0 then
  #    create unique index tmp20a_1_idx on tmp20a_1
  #                   (CodigoQuestao)
   end if
------------------------------------------------
     create temp table tmp21_1
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Nome           char(40)
                  , CPF            char(15)
                  , seqcdt         char(2)
                  , Rg             char(15)
                  , CNH            char(15)
                  , CATCNH         char(15)
                  , Espaco         char(5)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp21_1_idx on tmp21_1
                    (Seq)
   end if
------------------------------------------------
 if m_create22 <> 1 then
   let m_create22 = 1

   create temp table tmp22_1
                 (  SeqProposta           smallint
                  , CodDesconto           char(100)
                  , CoeficienteSemPremio  char(8)
                 )with no log
if sqlca.sqlcode = 0 then
   #   create unique index tmp22_1_idx on tmp22_1
   #                 (CodDesconto)
   end if
 else
  delete from tmp22_1
 end if


 -----------------------------------------------
    create temp table tmp24_1
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , numacei        char(10)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp24_1_idx on tmp24_1
                    (Seq)
   end if
--------------------------------------------------
 create temp table tmp27_1
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , idcartao       char(11)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp27_1_idx on tmp27_1
                    (Seq)
   end if
-------------------------------------------------
create temp table tmp29_1
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Finalidade    char(18)
                  , Encargos      char(18)
                  , Totalbruto    char(18)
                  , Espaco        char(62)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp29_1_idx on tmp29_1
                    (Seq)
   end if
---------------------------------------------------
create temp table tmp30_1
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Debito       char(1)
                  , banco        char(4)
                  , agencia      char(5)
                  , conta        char(15)
                  , contadig     char(5)
                  , seguroroubo  char(1)
                  , CPF          char(20)
                  , nome         char(40)
                  , data         char(10)
                  , parentesco   char(1)
                  , sexo         char(1)
                  )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp30_1_idx on tmp30_1
                    (Seq)
   end if
---------------------------------------------------

create temp table tmp31_1
            (  SeqProposta     smallint
              , Seq            smallint
              , CodigoReg      char(2)
              ,custoaplanual   char(15)
              ,coefIOF         char(15)
              ,premiovista     char(15)
              ,taxacasco       char(9)
              ,tiposeg         char(1)
              ,vlrparc1        char(15)
              ,vlrdemais       char(15)
              ,vlrjuros        char(15)
              ,espaco          char(6)
              )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp31_1_idx on tmp31_1
                    (Seq)
   end if
---------------------------------------------------
create temp table tmp32_1
       ( SeqProposta  smallint
        ,Seq          smallint
        ,CodigoReg    char(2)
        ,RG           char(10)
        ,Cnh          char(15)
        ,catcnh       char(15)
        ,email        char(60)
        ,tpenviofront char(12)
        ,espaco       char(5)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp32_1_idx on tmp32_1
                    (Seq)
   end if
------------------------------------------------
create temp table tmp35_1
       ( SeqProposta  smallint
        ,Seq          smallint
        ,CodigoReg    char(2)
        ,codbanco   char(3)
        ,agencia    char(4)
        ,produtor   char(10)
        ,pontovenda char(10)
        ,postoserv  char(10)
        ,segcliente char(2)
        ,espaco     char(66)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp35_1_idx on tmp35_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp36_1
      (SeqProposta       smallint
      ,Seq               smallint
      ,CodigoReg         char(2)
      ,IsMorte           char(16)
      ,IsInvalidez       char(16)
      ,PremioLiqVidaInd  char(16)
      ,Espaco            char(61)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp36_1_idx on tmp36_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp37_1
      (SeqProposta          smallint
      ,Seq                  smallint
      ,CodigoReg            char(2)
      ,NomeBeneficiario     char(50)
      ,GrauParentesco       char(2)
      ,Espaco               char(18)
      ,ParticipBeneficiario char(6)
      ,Espaco2              char(31)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp37_1_idx on tmp37_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp38_1
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg         char(2)
      ,DataAtendimento   char(10)
      ,HoraAtendimento   char(5)
      ,LocalAtendimento  char(50)
      ,TipoServico       char(40)
      ,Espaco            char(1)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp38_1_idx on tmp38_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp39_1
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg           char(2)
      ,TipoInformacao      char(2)
      ,CodigoInformacao    char(4)
      ,QtdeServico         char(2)
      ,TextoComplementar   char(98)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp39_1_idx on tmp39_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp40_1
      (SeqProposta         smallint
      ,Seq                 smallint
      ,SequenciaLocal      char(2)
      ,NumeroSeqRisco      char(6)
      ,NomeBloco           char(60)
      ,QtdePavimentos      char(2)
      ,QtdeVagas           char(3)
      ,TipoConstrucao      char(8)
      ,QtdeAptosCondominio char(3)
      ,ValorRiscoDeclarado char(15)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp40_1_idx on tmp40_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp41_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,MeioPagamento    char(2)
      ,NumeroParcela    char(2)
      ,CartaoCredito    char(16)
      ,VenctoCartao     char(6)
      ,NumeroBanco      char(4)
      ,NumeroAgencia    char(5)
      ,ContaCorrente    char(15)
      ,DigitoCC         char(5)
      ,DataVencto       char(10)
      ,ValorParcela     char(12)
      ,ChequeNum        char(10)
      ,PracaCheque      char(2)
      ,CnpjCpfCC        char(20)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp41_1_idx on tmp41_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp42_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,Fumante          char(1)
      ,CodigoOperacao   char(3)
      ,AtualMonetaria   char(1)
      ,NomeInformar     char(60)
      ,Telefone         char(12)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp42_1_idx on tmp42_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp43_1
      (SeqProposta            smallint
      ,Seq                    smallint
      ,CodigoReg              char(2)
      ,Empresa                char(30)
      ,TempoAnosMeses         char(5)
      ,Produto                char(5)
      ,Renda                  char(13)
      ,Premio                 char(16)
      ,QtdeParcelasAutoVida   char(2)
      ,FormaPagtoRenovacao    char(45)
      ,QtdeParcelasRenovacao  char(2)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp43_1_idx on tmp43_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp44_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,AssistFuneral    char(1)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp44_1_idx on tmp44_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp44a_1
      (SeqProposta      smallint
      ,Cobertura        char(16)
      )with no log
   if sqlca.sqlcode = 0 then
  #    create unique index tmp44a_1_idx on tmp44a_1
  #                  (SeqProposta)
   end if
------------------------------------------------
   create temp table tmp45_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,NumeroNegociacao char(10)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp45_1_idx on tmp45_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp46_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,TipoEndereco     char(30)
      ,TipoLogradouro   char(30)
      ,Logradouro       char(40)
      ,Numero           char(5)
      ,Complemento      char(15)
      ,CEP              char(9)
      ,Espaco           char(32)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp46_1_idx on tmp46_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp47_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,TipoTexto        char(3)
      ,SequenciaTexto   char(2)
      ,DescricaoTexto   char(10)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp47_1_idx on tmp47_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp48_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,FlagEndereco     char(1)
      ,Bairro           char(20)
      ,Cidade           char(20)
      ,UF               char(2)
      ,Email            char(60)
      ,Espaco           char(3)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp48_1_idx on tmp48_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp49_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,TipoTelefone     char(2)
      ,DddTelefone      char(4)
      ,NumeroTelefone   char(10)
      ,RamalTelefone    char(10)
      ,Recados          char(40)
      ,Espaco           char(40)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp49_1_idx on tmp49_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp50_1
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg           char(2)
      ,Veiculo             char(5)
      ,AnoFabricacao       char(4)
      ,AnoModelo           char(4)
      ,Flag0Km             char(1)
      ,Uso                 char(2)
      ,Categoria           char(2)
      ,QtdePassageiros     char(2)
      ,PremioCasco         char(14)
      ,PremioAcessorio     char(14)
      ,PremioDM            char(14)
      ,PremioDP            char(14)
      ,PremioDMO           char(14)
      ,PremioAPP           char(14)
      ,AlteracaoCasco      char(18)
      ,AlteracaoAcessorios char(18)
      ,AlteracaoDM         char(18)
      ,AlteracaoDP         char(18)
      ,AlteracaoDMO        char(18)
      ,AlteracaoAPP        char(18)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp50_1_idx on tmp50_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp52_1
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoRegistro   char(2)
      ,TipoTelefone     char(2)
      ,DddTelefone      char(4)
      ,NumeroTelefone   char(10)
      ,RamalTelefone    char(10)
      ,Recados          char(40)
      ,Espaco           char(40)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp52_1_idx on tmp52_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp53_1
               (SeqProposta         smallint
               ,Seq                 smallint
               ,IdentifConfirmBonus char(14)
               ,NumAgendamentoDAF   char(10)
               ,KitGas              char(80)
               ,CambioAutomatico    char(3)
               ,VeicFinanciado      char(3)
               ,UtilizacaoVeiculo   char(20)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp53_1_idx on tmp53_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp54_1
               (SeqProposta            smallint
               ,Seq                    smallint
               ,CodigoReg              char(2)
               ,CodigoClausula         char(50)
               ,CoeficienteClausula    char(7)
               ,CobrancaSN             char(1)
               ,IncVigencia            char(10)
               ,FinalVigencia          char(10)
               ,PremioLiquidoClausula  char(16)
               ,PremioTotalClausulas   char(16)
               ,Espaco                 char(62)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp54_1_idx on tmp54_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp55_1
               (SeqProposta         smallint
               ,Seq                 smallint
               ,NumeroPpw           char(12)
               ,SenhaUtilizada      char(15)
               ,ClasseLocalizacao   char(2)
               ,CodigoVeiculo       char(5)
               ,DataCalculo         char(8)
               ,DescontoOffLine     char(3)
               ,Criptografia        char(20)
               ,CpfProponente       char(12)
               ,OrdemProponente     char(4)
               ,DigitoProponente    char(2)
               )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp55_1_idx on tmp55_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp55a_1
               (SeqProposta         smallint
               ,CpfCondutor         char(9)
               ,DigitoCpfCondutor   char(2)
               )with no log
   if sqlca.sqlcode = 0 then
      #create unique index tmp55a_1_idx on tmp55a_1
      #              (SeqProposta)
   end if
 ------------------------------------------------

   create temp table tmp56_1
               (SeqProposta         smallint
               ,Seq                 smallint
               ,SequenciaLocal    char(2)
               ,CodigoQuestao     char(50)
               ,DescricaoResposta char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp56_1_idx on tmp56_1
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp58_1
               (SeqProposta         smallint
               ,Seq                 smallint
               ,CodigoReg           char(2)
               ,VersaoDllCalculo    char(8)
               ,PatrimonioLiquido   char(40)
               ,RecOperacBrutaAnual char(40)
               ,AdminControlProcur  char(45)
               ,TipoEmpresa         char(40)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp58_1_idx on tmp58_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp59_1
               (  SeqProposta       smallint
                , Seq               smallint
                , TipoProponente char(1)
                , Nome           char(50)
                , TipoPessoa     char(1)
                , CpfCnpj        char(9)
                , Ordem          char(4)
                , Digito         char(2)
                , SemCpfCnpjPor  char(50)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp59_1_idx on tmp59_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp60_1
               (  SeqProposta       smallint
                , Seq               smallint
                , DescricaoTexto    char(200)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp60_1_idx on tmp60_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp61_1
               (  SeqProposta          smallint
                , Seq                  smallint
                , FinalidadeEmissao    char(15)
                , FinalidadeEncargos   char(15)
                , ValorTotalPremio     char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp61_1_idx on tmp61_1
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp62_1
               (  SeqProposta             smallint
                , Seq                     smallint
                , TipoFormaPagto          char(50)
                , NumeroParcela           char(2)
                , NumeroCartaoCredito     char(16)
                , VencimentoCartaoCredito char(6)
                , NumeroBanco             char(4)
                , NumeroAgencia           char(5)
                , NumeroContaCorrente     char(15)
                , DigitoContaCorrente     char(1)
                , DataVencimento          char(10)
                , ValorParcela            char(12)
                , NumeroCheque            char(10)
                , PracaCheque             char(2)
                , CnpjCpfCorrentista      char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp62_1_idx on tmp62_1
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp63_1
               (  SeqProposta    smallint
                , Seq            smallint
           , CustoApolice   char(15)
                , IOF            char(15)
                , PremioVista    char(15)
                , TaxaCasco      char(9)
                , SeguroMensal   char(1)
                , Parcelas1      char(15)
                , ParcelasDemais char(15)
                , ParcelasJuros  char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp63_1_idx on tmp63_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp64_1
               (  SeqProposta             smallint
                , Seq                     smallint
           , TipoFormaPagto          char(50)
                , NumeroParcela           char(2)
                , NumeroCartaoCredito     char(16)
                , VencimentoCartaoCredito char(6)
                , NumeroBanco             char(4)
                , NumeroAgencia           char(5)
                , NumeroContaCorrente     char(15)
                , DigitoContaCorrente     char(5)
                , DataVencimento          char(10)
                , ValorParcela            char(12)
                , NumeroCheque            char(10)
                , PracaCheque             char(2)
                , CnpjCpfCorrentista      char(20)
               )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp64_1_idx on tmp64_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp66_1
               (  SeqProposta        smallint
                , Seq                smallint
           , FlagTransitoGentil char(1)
                , CnhTransitoGentil  char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp66_1_idx on tmp66_1
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp67_1
               (  SeqProposta    smallint
                , Seq            smallint
           , CodigoPEP      char(1)
           ,  PEP            char(30)
           ,  NomePEP        char(50)
           ,  CpfPEP         char(12)
           ,  DigitoCpfPEP   char(2)
           ,  GrauRelacPEP   char(1)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp67_1_idx on tmp67_1
                    (Seq)
   end if



end function

#==================================
function cty21g03_cria_temp_prop2()
#==================================

  if m_prep is null   or
      m_prep <> "S"    then
      call ccty21g03_prepare()
   end if

   create temp table tmp00_2
                   ( SeqProposta    smallint
                    ,Seq            smallint
                    ,PropostaPPW    char(13)
                    ,CodigoReg      char(2)
                    ,Susep          char(100)
                    ,DataExtracao   char(10)
                    ,Filler         char(1)
                    ,HoraExtracao   char(8)
                    ,Versao         char(19)
                    ,PRMD           char(62)
                   ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp00_2_idx on tmp00_2
                    (Seq)
   end if
   ---------------------------------------------
   create temp table tmp01_2
                   (  SeqProposta        smallint
                    , Seq                smallint
                    , CodigoReg          char(2)
                    , OrigemPrincipal    char(2)
                    , PropPrincipal      char(8)
                    , SucRenov           char(2)
                    , AplRenov           char(9)
                    , TPendosso          char(100)
                    , TXTendosso         char(3)
                    , QtdItens           char(4)
                    , corresp            char(1)
                    , FormaPgto          char(100)
                    , QtdParcelas        char(2)
                    , VencParc1          char(10)
                    , vigencia           char(10)
                    , IniVig             char(10)
                    , FimVig             char(10)
                    , tiposeguro         char(100)
                    , tipocalculo        char(100)
                    , MoedaPremio        char(3)
                    , SolicAnalise       char(22)
                    , Boleto             char(1)
                    , Espaco             char(11)
                    , CodOperacao        char(2)
                    , FlagEmissao        char(1)
                    , Seguradora         char(100)
                    , EmBranco           char(7)
                    , TarifaPPW          char(12)
                    , FlagPOE            char(1)
                   ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp01_2_idx on tmp01_2
                    (Seq)
   end if
  -----------------------------------------------------------
  create temp table tmp04_2
                   ( SeqProposta         smallint
                   , Seq                  char(10)
                   , CodigoReg            char(2)
                   , Susep                char(100)
                   , participCorretor     char(10)
                   , FlagCorr             char(1)
                  ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp04_2_idx on tmp04_2
                    (Seq)
   end if
  ------------------------------------------------
  create temp table tmp05_2
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , CodigoReg             char(2)
                 , CodSegurado           char(8)
                 , NomeSegurado          char(50)
                 , TipoPessoa            char(100)
                 , CNPJ_CPF              char(20)
                 , DataNascimento        char(10)
                 , sexo                  char(09)
                 , EstadoCivil           char(100)
                 , MotivoSemCNPJ         char(100)
                 , EmBranco              char(15)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp05_2_idx on tmp05_2
                    (Seq)
   end if
  ------------------------------------------------
  create temp table tmp06_2
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , CodigoReg             char(2)
                 , TipoEndereco          char(100)
                 , TipoLogradouro        char(100)
                 , Logradouro            char(40)
                 , Numero                char(5)
                 , Complemento           char(15)
                 , CEP                   char(10)
                 , Espaco                char(32)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp06_2_idx on tmp06_2
                    (Seq)
   end if
  ------------------------------------------------
   create temp table tmp07_2
                 ( SeqProposta           smallint
                 , Seq                   smallint
                 , FlagEndereco          char(1)
                 , Bairro                char(20)
                 , Cidade                char(20)
                 , UF                    char(2)
                 , DDD                   char(4)
                 , Telefone              char(15)
                 , Espaco                char(44)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp07_2_idx on tmp07_2
                    (Seq)
   end if
  ------------------------------------------------
  create temp table tmp08_2
                 ( SeqProposta             smallint
                 , Seq                     smallint
                 , CodigoReg               char(2)
                 , NumeroItem              char(7)
                 , NumeroOrigem            char(2)
                 , PropostaIndividual      char(8)
                 , ClasseBonus             char(2)
                 , ClasseLocalizacao       char(100)
                 , TrafegoHabitual         char(45)
                 , IncVigAnterior          char(10)
                 , FinVigAnterior          char(10)
                 , Seguradora              char(100)
                 , SucursalItem            char(3)
                 , AplDoItem               char(10)
                 , Espaco                  char(2)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp08_2_idx on tmp08_2
                    (Seq)
   end if
------------------------------------------------
 create temp table tmp09_2
                 ( SeqProposta              smallint
                 , Seq                      smallint
                 , CodigoReg                char(2)
                 , ObsProposta              char(100)
                 , Sequencia                char(2)
                 , Espaco                   char(54)
                 ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp09_2_idx on tmp09_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp10_2
                     ( SeqProposta              smallint
                     , Seq                      smallint
                     , CodigoReg                char(2)
                     , CodVeiculo               char(5)
                     , AnoFabricacao            char(4)
                     , AnoModelo                char(4)
                     , Placa                    char(7)
                     , Chassi                   char(20)
                     , Renavam                  char(50)
                     , TipoUso                  char(100)
                     , Veiculo0km               char(1)
                     , TipoVistoria             char(100)
                     , VPCOBprovisoria          char(9)
                     , CapacidadePassageiros    char(2)
                     , FlagAutoRevenda          char(1)
                     , FlagAutoNovo             char(1)
                     , CategoriaTarifada        char(100)
                     , combustivel              char(100)
                     , QtdePortas               char(1)
                     , DataVistoria             char(10)
                     , VeiculoBlindado          char(100)
                     , FlagChassiRemarc         char(1)
                     , CodigoTabelaFipe         char(8)
                     , CodigoRenovacao          char(25)
                     )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp10_2_idx on tmp10_2
                    (Seq)
   end if
 ------------------------------------------------
create temp table tmp11_2
               (  SeqProposta              smallint
                , Seq                      smallint
                , CodigoReg                char(2)
                , NotaFiscal               char(8)
                , DataEmissao              char(10)
                , DataSaidaVeiculo         char(10)
                , CodConcessionaria        char(5)
                , NomeConcessionaria       char(50)
                , ValorNota                char(16)
                , Espaco                   char(28)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp11_2_idx on tmp11_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp12_2
               (  SeqProposta            smallint
                , Seq                    smallint
                , CodigoReg              char(2)
                , DataRealizacaoCalc     char(10)
                , Franquia               char(100)
                , Cobertura              char(100)
                , FranquiaCasco          char(100)
                , ISCalculo              char(100)
                , IsencaoImpostos        char(100)
                , ISdaBlindagem          char(100)
                , PremioLiqCasco         char(100)
                , CotacaoMotorShow       char(1)
                , PercentISCasco         char(10)
                , PercentISBlindagem     char(10)
                , FatorDepreciacao       char(10)
                , ValorBasico            char(100)
                , ValorMaximo            char(100)
                , TabelaUtilizada        char(100)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp12_2_idx on tmp12_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp13_2
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizCalc      char(10)
                , RefAcessorio        char(100)
                , TipoAcessorio       char(100)
                , ValorFranquia       char(20)
                , ISFranquia          char(20)
                , SeqAcessorio        char(2)
                , PremioLiqAcess      char(20)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp13_2_idx on tmp13_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp14_2
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizaCalc     char(10)
                , ClasseFranquia      char(2)
                , ValorFranquiaDM     char(20)
                , ISDM                char(20)
                , ValorFranquiaDC     char(20)
                , ISDC                char(20)
                , PremioLiqRCFDM      char(20)
                , PremioLiqRCFDC      char(20)
                , Espaco              char(4)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp14_2_idx on tmp14_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp15_2
                ( SeqProposta         smallint
                , Seq                 smallint
                , CodigoReg           char(2)
                , DataRealizaCalc     char(10)
                , ISInvalidez         char(5)
                , ISMorte             char(20)
                , ISDMH               char(20)
                , PremioLiqApp        char(20)
                , Espaco              char(36)
                ) with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp15_2_idx on tmp15_2
                    (Seq)
   end if
{------------------------------------------------
   create temp table tmp16_2
                ( SeqProposta               smallint
                , Seq                       smallint
                , CodigoReg                char(2)
                , CodDesconto              char(100)
                , CoeficienteSemPremio     char(20)
                , CodDesconto2             char(100)
                , CoeficienteSemPremio2    char(20)
                , CodDesconto3             char(100)
                , CoeficienteSemPremio3    char(20)
                , CodDesconto4             char(100)
                , CoeficienteSemPremio4    char(20)
                , CodDesconto5             char(100)
                , CoeficienteSemPremio5    char(20)
                , CodDesconto6             char(100)
                , CoeficienteSemPremio6    char(20)
                , CodDesconto7             char(100)
                , CoeficienteSemPremio7    char(20)
                , CodDesconto8             char(100)
                , CoeficienteSemPremio8    char(20)
                , CodDesconto9             char(100)
                , CoeficienteSemPremio9    char(20)
                , CodDesconto10            char(100)
                , CoeficienteSemPremio10   char(20)
                , CodDesconto11            char(100)
                , CoeficienteSemPremio11   char(20)
                , CodDesconto12            char(100)
                , CoeficienteSemPremio12   char(20)
                , CodDesconto13            char(100)
                , CoeficienteSemPremio13   char(20)
                , CodDesconto14            char(100)
                , CoeficienteSemPremio14   char(20)
                , CodDesconto15            char(100)
                , CoeficienteSemPremio15   char(20)
                , Espaco                   char(1)
                ) with no log
}
------------------------------------------------
   create temp table tmp17_2
                ( SeqProposta               smallint
                , Seq                       smallint
                , CodigoReg                 char(2)
                , CodClausula               char(100)
                , CoeficienteClausula       char(20)
                , CobrancaSN                char(1)
                , IncVig                    char(10)
                , FinVig                    char(10)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp17_2_idx on tmp17_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp18_2
                ( SeqProposta              smallint
                , Seq                      smallint
                , CodigoReg                char(2)
                , CodClausula              char(3)
                , txtClausula              char(50)
                , seqTexto                 char(2)
                , Espaco                   char(51)
                )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp18_2_idx on tmp18_2
                    (Seq)
   end if
------------------------------------------------
    create temp table tmp19_2
     ( SeqProposta      smallint
      ,CodigoReg        char(2)
      ,CodigoProduto    char(2)
      ,CodigoQuestao    char(80)
      ,CodigoResposta   char(80)
      ,SubResposta      char(80)
     )with no log
#   if sqlca.sqlcode = 0 then
#      create unique index tmp19_2_idx on tmp19_2
#                    (Seq)
#   end if
------------------------------------------------
   create temp table tmp20_2
      ( SeqProposta        smallint
       ,Seq                smallint
       ,PoeConcorrencia    char(3)
       ,CodigoReg          char(2)
       ,TipoProduto        char(2)
     )with no log
   if sqlca.sqlcode = 0 then
     # create unique index tmp20_2_idx on tmp20_2
     #               (Seq)
   end if
------------------------------------------------
   create temp table tmp20a_2
      ( SeqProposta        smallint
       ,CodigoQuestao      char(80)
       ,CodigoResposta     char(80)
       ,TextoResposta      char(80)
     )with no log
   if sqlca.sqlcode = 0 then
 #     create unique index tmp20a_2_idx on tmp20a_2
 #                   (CodigoQuestao)
   end if
------------------------------------------------
  create temp table tmp21_2
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Nome           char(40)
                  , CPF            char(15)
                  , seqcdt         char(2)
                  , Rg             char(15)
                  , CNH            char(15)
                  , CATCNH         char(15)
                  , Espaco         char(5)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp21_2_idx on tmp21_2
                    (Seq)
   end if
-------------------------------------------------
   create temp table tmp22_2
                 (  SeqProposta           smallint
                  , CodDesconto           char(100)
                  , CoeficienteSemPremio  char(8)
                 )with no log
   if sqlca.sqlcode = 0 then
     # create unique index tmp22_2_idx on tmp22_2
     #               (CodDesconto)
   end if
--------------------------------------------------
  create temp table tmp24_2
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , numacei        char(10)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp24_2_idx on tmp24_2
                    (Seq)
   end if
--------------------------------------------------
  create temp table tmp27_2
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , idcartao       char(11)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp27_2_idx on tmp27_2
                    (Seq)
   end if
--------------------------------------------------
create temp table tmp29_2
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Finalidade    char(18)
                  , Encargos      char(18)
                  , Totalbruto    char(18)
                  , Espaco        char(62)
                 )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp29_2_idx on tmp29_2
                    (Seq)
   end if
--------------------------------------------------
create temp table tmp30_2
                 (  SeqProposta    smallint
                  , Seq            smallint
                  , CodigoReg      char(2)
                  , Debito       char(1)
                  , banco        char(4)
                  , agencia      char(5)
                  , conta        char(15)
                  , contadig     char(5)
                  , seguroroubo  char(1)
                  , CPF          char(20)
                  , nome         char(40)
                  , data         char(10)
                  , parentesco   char(1)
                  , sexo         char(1)
                  )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp30_2_idx on tmp30_2
                    (Seq)
   end if
--------------------------------------------------
create temp table tmp31_2
            (  SeqProposta     smallint
              , Seq            smallint
              , CodigoReg      char(2)
              ,custoaplanual   char(15)
              ,coefIOF         char(15)
              ,premiovista     char(15)
              ,taxacasco       char(9)
              ,tiposeg         char(1)
              ,vlrparc1        char(15)
              ,vlrdemais       char(15)
              ,vlrjuros        char(15)
              ,espaco          char(6)
              )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp31_2_idx on tmp31_2
                    (Seq)
   end if
--------------------------------------------------
create temp table tmp32_2
       ( SeqProposta  smallint
        ,Seq          smallint
        ,CodigoReg    char(2)
        ,RG           char(10)
        ,Cnh          char(15)
        ,catcnh       char(15)
        ,email        char(60)
        ,tpenviofront char(12)
        ,espaco       char(5)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp32_2_idx on tmp32_2
                    (Seq)
   end if
------------------------------------------------
create temp table tmp35_2
       ( SeqProposta  smallint
        ,Seq          smallint
        ,CodigoReg    char(2)
        ,codbanco     char(3)
        ,agencia      char(4)
        ,produtor     char(10)
        ,pontovenda   char(10)
        ,postoserv    char(10)
        ,segcliente   char(2)
        ,espaco       char(66)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp35_2_idx on tmp35_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp36_2
      (SeqProposta       smallint
      ,Seq               smallint
      ,CodigoReg         char(2)
      ,IsMorte           char(16)
      ,IsInvalidez       char(16)
      ,PremioLiqVidaInd  char(16)
      ,Espaco            char(61)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp36_2_idx on tmp36_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp37_2
      (SeqProposta          smallint
      ,Seq                  smallint
      ,CodigoReg            char(2)
      ,NomeBeneficiario     char(50)
      ,GrauParentesco       char(2)
      ,Espaco               char(18)
      ,ParticipBeneficiario char(6)
      ,Espaco2              char(31)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp37_2_idx on tmp37_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp38_2
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg         char(2)
      ,DataAtendimento   char(10)
      ,HoraAtendimento   char(5)
      ,LocalAtendimento  char(50)
      ,TipoServico       char(40)
      ,Espaco            char(1)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp38_2_idx on tmp38_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp39_2
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg           char(2)
      ,TipoInformacao      char(2)
      ,CodigoInformacao    char(4)
      ,QtdeServico         char(2)
      ,TextoComplementar   char(98)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp39_2_idx on tmp39_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp40_2
      (SeqProposta         smallint
      ,Seq                 smallint
      ,SequenciaLocal      char(2)
      ,NumeroSeqRisco      char(6)
      ,NomeBloco           char(60)
      ,QtdePavimentos      char(2)
      ,QtdeVagas           char(3)
      ,TipoConstrucao      char(8)
      ,QtdeAptosCondominio char(3)
      ,ValorRiscoDeclarado char(15)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp40_2_idx on tmp40_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp41_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,MeioPagamento    char(2)
      ,NumeroParcela    char(2)
      ,CartaoCredito    char(16)
      ,VenctoCartao     char(6)
      ,NumeroBanco      char(4)
      ,NumeroAgencia    char(5)
      ,ContaCorrente    char(15)
      ,DigitoCC         char(5)
      ,DataVencto       char(10)
      ,ValorParcela     char(12)
      ,ChequeNum        char(10)
      ,PracaCheque      char(2)
      ,CnpjCpfCC        char(20)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp41_2_idx on tmp41_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp42_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,Fumante          char(1)
      ,CodigoOperacao   char(3)
      ,AtualMonetaria   char(1)
      ,NomeInformar     char(60)
      ,Telefone         char(12)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp42_2_idx on tmp42_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp43_2
      (SeqProposta            smallint
      ,Seq                    smallint
      ,CodigoReg              char(2)
      ,Empresa                char(30)
      ,TempoAnosMeses         char(5)
      ,Produto                char(5)
      ,Renda                  char(13)
      ,Premio                 char(16)
      ,QtdeParcelasAutoVida   char(2)
      ,FormaPagtoRenovacao    char(45)
      ,QtdeParcelasRenovacao  char(2)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp43_2_idx on tmp43_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp44_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,AssistFuneral    char(1)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp44_2_idx on tmp44_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp44a_2
      (SeqProposta      smallint
      ,Cobertura        char(16)
      )with no log
   if sqlca.sqlcode = 0 then
  #    create unique index tmp44a_2_idx on tmp44a_2
  #                  (SeqProposta)
   end if
------------------------------------------------
   create temp table tmp45_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,NumeroNegociacao char(10)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp45_2_idx on tmp45_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp46_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,TipoEndereco     char(30)
      ,TipoLogradouro   char(30)
      ,Logradouro       char(40)
      ,Numero           char(5)
      ,Complemento      char(15)
      ,CEP              char(9)
      ,Espaco           char(32)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp46_2_idx on tmp46_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp47_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,TipoTexto        char(3)
      ,SequenciaTexto   char(2)
      ,DescricaoTexto   char(10)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp47_2_idx on tmp47_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp48_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,FlagEndereco     char(1)
      ,Bairro           char(20)
      ,Cidade           char(20)
      ,UF               char(2)
      ,Email            char(60)
      ,Espaco           char(3)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp48_2_idx on tmp48_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp49_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoReg        char(2)
      ,TipoTelefone     char(2)
      ,DddTelefone      char(4)
      ,NumeroTelefone   char(10)
      ,RamalTelefone    char(10)
      ,Recados          char(40)
      ,Espaco           char(40)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp49_2_idx on tmp49_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp50_2
      (SeqProposta         smallint
      ,Seq                 smallint
      ,CodigoReg           char(2)
      ,Veiculo             char(5)
      ,AnoFabricacao       char(4)
      ,AnoModelo           char(4)
      ,Flag0Km             char(1)
      ,Uso                 char(2)
      ,Categoria           char(2)
      ,QtdePassageiros     char(2)
      ,PremioCasco         char(14)
      ,PremioAcessorio     char(14)
      ,PremioDM            char(14)
      ,PremioDP            char(14)
      ,PremioDMO           char(14)
      ,PremioAPP           char(14)
      ,AlteracaoCasco      char(18)
      ,AlteracaoAcessorios char(18)
      ,AlteracaoDM         char(18)
      ,AlteracaoDP         char(18)
      ,AlteracaoDMO        char(18)
      ,AlteracaoAPP        char(18)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp50_2_idx on tmp50_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp52_2
      (SeqProposta      smallint
      ,Seq              smallint
      ,CodigoRegistro   char(2)
      ,TipoTelefone     char(2)
      ,DddTelefone      char(4)
      ,NumeroTelefone   char(10)
      ,RamalTelefone    char(10)
      ,Recados          char(40)
      ,Espaco           char(40)
      )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp52_2_idx on tmp52_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp53_2
               (SeqProposta         smallint
               ,Seq                 smallint
               ,IdentifConfirmBonus char(14)
               ,NumAgendamentoDAF   char(10)
               ,KitGas              char(80)
               ,CambioAutomatico    char(3)
               ,VeicFinanciado      char(3)
               ,UtilizacaoVeiculo   char(20)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp53_2_idx on tmp53_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp54_2
               (SeqProposta            smallint
               ,Seq                    smallint
               ,CodigoReg              char(2)
               ,CodigoClausula         char(50)
               ,CoeficienteClausula    char(7)
               ,CobrancaSN             char(1)
               ,IncVigencia            char(10)
               ,FinalVigencia          char(10)
               ,PremioLiquidoClausula  char(16)
               ,PremioTotalClausulas   char(16)
               ,Espaco                 char(62)
        )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp54_2_idx on tmp54_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp55_2
               (SeqProposta         smallint
               ,Seq                 smallint
               ,NumeroPpw           char(12)
               ,SenhaUtilizada      char(15)
               ,ClasseLocalizacao   char(2)
               ,CodigoVeiculo       char(5)
               ,DataCalculo         char(8)
               ,DescontoOffLine     char(3)
               ,Criptografia        char(20)
               ,CpfProponente       char(12)
               ,OrdemProponente     char(4)
               ,DigitoProponente    char(2)
               )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp55_2_idx on tmp55_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp55a_2
               (SeqProposta         smallint
               ,CpfCondutor         char(9)
               ,DigitoCpfCondutor   char(2)
               )with no log
   if sqlca.sqlcode = 0 then
   #   create unique index tmp55a_2_idx on tmp55a_2
   #                 (SeqProposta)
   end if
 ------------------------------------------------
   create temp table tmp56_2
               (SeqProposta         smallint
               ,Seq                 smallint
               ,SequenciaLocal    char(2)
               ,CodigoQuestao     char(50)
               ,DescricaoResposta char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp56_2_idx on tmp56_2
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp58_2
               (SeqProposta         smallint
               ,Seq                 smallint
               ,CodigoReg           char(2)
               ,VersaoDllCalculo    char(8)
               ,PatrimonioLiquido   char(40)
               ,RecOperacBrutaAnual char(40)
               ,AdminControlProcur  char(45)
               ,TipoEmpresa         char(40)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp58_2_idx on tmp58_2
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp59_2
               (  SeqProposta       smallint
                , Seq               smallint
                , TipoProponente char(1)
                , Nome           char(50)
                , TipoPessoa     char(1)
                , CpfCnpj        char(9)
                , Ordem          char(4)
                , Digito         char(2)
                , SemCpfCnpjPor  char(50)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp59_2_idx on tmp59_2
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp60_2
               (  SeqProposta       smallint
                , Seq               smallint
                , DescricaoTexto    char(200)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp60_2_idx on tmp60_2
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp61_2
               (  SeqProposta          smallint
                , Seq                  smallint
                , FinalidadeEmissao    char(15)
                , FinalidadeEncargos   char(15)
                , ValorTotalPremio     char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp61_2_idx on tmp61_2
                    (Seq)
   end if
 ------------------------------------------------
   create temp table tmp62_2
               (  SeqProposta             smallint
                , Seq                     smallint
                , TipoFormaPagto          char(50)
                , NumeroParcela           char(2)
                , NumeroCartaoCredito     char(16)
                , VencimentoCartaoCredito char(6)
                , NumeroBanco             char(4)
                , NumeroAgencia           char(5)
                , NumeroContaCorrente     char(15)
                , DigitoContaCorrente     char(1)
                , DataVencimento          char(10)
                , ValorParcela            char(12)
                , NumeroCheque            char(10)
                , PracaCheque             char(2)
                , CnpjCpfCorrentista      char(20)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp62_2_idx on tmp62_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp63_2
               (  SeqProposta    smallint
                , Seq            smallint
           , CustoApolice   char(15)
                , IOF            char(15)
                , PremioVista    char(15)
                , TaxaCasco      char(9)
                , SeguroMensal   char(1)
                , Parcelas1      char(15)
                , ParcelasDemais char(15)
                , ParcelasJuros  char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp63_2_idx on tmp63_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp64_2
               (  SeqProposta             smallint
                , Seq                     smallint
           , TipoFormaPagto          char(50)
                , NumeroParcela           char(2)
                , NumeroCartaoCredito     char(16)
                , VencimentoCartaoCredito char(6)
                , NumeroBanco             char(4)
                , NumeroAgencia           char(5)
                , NumeroContaCorrente     char(15)
                , DigitoContaCorrente     char(5)
                , DataVencimento          char(10)
                , ValorParcela            char(12)
                , NumeroCheque            char(10)
                , PracaCheque             char(2)
                , CnpjCpfCorrentista      char(20)
               )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp64_2_idx on tmp64_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp66_2
               (  SeqProposta        smallint
                , Seq                smallint
           , FlagTransitoGentil char(1)
                , CnhTransitoGentil  char(15)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp66_2_idx on tmp66_2
                    (Seq)
   end if
------------------------------------------------
   create temp table tmp67_2
               (  SeqProposta    smallint
                , Seq            smallint
           , CodigoPEP      char(1)
           ,  PEP            char(30)
           ,  NomePEP        char(50)
           ,  CpfPEP         char(12)
           ,  DigitoCpfPEP   char(2)
           ,  GrauRelacPEP   char(1)
          )with no log
   if sqlca.sqlcode = 0 then
      create unique index tmp67_2_idx on tmp67_2
                    (Seq)
   end if
end function

#===============================
function cty21g03_insert_prop1()
#===============================

 insert into tmp00_1
 select SeqProposta
      , Seq
      , PropostaPPW
      , CodigoReg
      , Susep
      , DataExtracao
      , Filler
      , HoraExtracao
      , Versao
      , PRMD
   from tmp_00

 insert into tmp01_1
 select  SeqProposta
       , Seq
       , CodigoReg
       , OrigemPrincipal
       , PropPrincipal
       , SucRenov
       , AplRenov
       , TPendosso
       , TXTendosso
       , QtdItens
       , corresp
       , FormaPgto
       , QtdParcelas
       , VencParc1
       , vigencia
       , IniVig
       , FimVig
       , tiposeguro
       , tipocalculo
       , MoedaPremio
       , SolicAnalise
       , Boleto
       , Espaco
       , CodOperacao
       , FlagEmissao
       , Seguradora
       , EmBranco
       , TarifaPPW
       , FlagPOE
       from tmp_01

 insert into tmp04_1
 select   SeqProposta
         , Seq
         , CodigoReg
         , Susep
         , participCorretor
         , FlagCorr
       from tmp_04

 insert into tmp05_1
  select SeqProposta
       , Seq
       , CodigoReg
       , CodSegurado
       , NomeSegurado
       , TipoPessoa
       , CNPJ_CPF
       , DataNascimento
       , sexo
       , EstadoCivil
       , MotivoSemCNPJ
       , EmBranco
   from tmp_05

 insert into tmp06_1
  select SeqProposta
       , Seq
       , CodigoReg
       , TipoEndereco
       , TipoLogradouro
       , Logradouro
       , Numero
       , Complemento
       , CEP
       , Espaco
   from tmp_06

  insert into tmp07_1
   select SeqProposta
        , Seq
        , FlagEndereco
        , Bairro
        , Cidade
        , UF
        , DDD
        , Telefone
        , Espaco
      from tmp_07
  insert into tmp08_1
    select SeqProposta
         , Seq
         , CodigoReg
         , NumeroItem
         , NumeroOrigem
         , PropostaIndividual
         , ClasseBonus
         , ClasseLocalizacao
         , TrafegoHabitual
         , IncVigAnterior
         , FinVigAnterior
         , Seguradora
         , SucursalItem
         , AplDoItem
         , Espaco
    from tmp_08

   insert into tmp09_1
   select SeqProposta
        , Seq
        , CodigoReg
        , ObsProposta
        , Sequencia
        , Espaco
    from tmp_09

   insert into tmp10_1
   select SeqProposta
        , Seq
        , CodigoReg
        , CodVeiculo
        , AnoFabricacao
        , AnoModelo
        , Placa
        , Chassi
        , Renavam
        , TipoUso
        , Veiculo0km
        , TipoVistoria
        , VPCOBprovisoria
        , CapacidadePassageiros
        , FlagAutoRevenda
        , FlagAutoNovo
        , CategoriaTarifada
        , combustivel
        , QtdePortas
        , DataVistoria
        , VeiculoBlindado
        , FlagChassiRemarc
        , CodigoTabelaFipe
        , CodigoRenovacao
    from tmp_10

   insert into tmp11_1
   select SeqProposta
        , Seq
        , CodigoReg
        , NotaFiscal
        , DataEmissao
        , DataSaidaVeiculo
        , CodConcessionaria
        , NomeConcessionaria
        , ValorNota
        , Espaco
   from tmp_11

   insert into tmp12_1
   select SeqProposta
        , Seq
        , CodigoReg
        , DataRealizacaoCalc
        , Franquia
        , Cobertura
        , FranquiaCasco
        , ISCalculo
        , IsencaoImpostos
        , ISdaBlindagem
        , PremioLiqCasco
        , CotacaoMotorShow
        , PercentISCasco
        , PercentISBlindagem
        , FatorDepreciacao
        , ValorBasico
        , ValorMaximo
        , TabelaUtilizada
   from tmp_12

   insert into tmp13_1
   select SeqProposta
        , Seq
        , CodigoReg
        , DataRealizCalc
        , RefAcessorio
        , TipoAcessorio
        , ValorFranquia
        , ISFranquia
        , SeqAcessorio
        , PremioLiqAcess
    from tmp_13
   insert into tmp14_1
   select SeqProposta
        , Seq
        , CodigoReg
        , DataRealizaCalc
        , ClasseFranquia
        , ValorFranquiaDM
        , ISDM
        , ValorFranquiaDC
        , ISDC
        , PremioLiqRCFDM
        , PremioLiqRCFDC
        , Espaco
    from tmp_14

    insert into tmp15_1
    select SeqProposta
         , Seq
         , CodigoReg
         , DataRealizaCalc
         , ISInvalidez
         , ISMorte
         , ISDMH
         , PremioLiqApp
         , Espaco
     from tmp_15

    {insert into tmp16_1
    select SeqProposta
         , Seq
         , CodigoReg
         , CodDesconto
         , CoeficienteSemPremio
         , CodDesconto2
         , CoeficienteSemPremio2
         , CodDesconto3
         , CoeficienteSemPremio3
         , CodDesconto4
         , CoeficienteSemPremio4
         , CodDesconto5
         , CoeficienteSemPremio5
         , CodDesconto6
         , CoeficienteSemPremio6
         , CodDesconto7
         , CoeficienteSemPremio7
         , CodDesconto8
         , CoeficienteSemPremio8
         , CodDesconto9
         , CoeficienteSemPremio9
         , CodDesconto10
         , CoeficienteSemPremio10
         , CodDesconto11
         , CoeficienteSemPremio11
         , CodDesconto12
         , CoeficienteSemPremio12
         , CodDesconto13
         , CoeficienteSemPremio13
         , CodDesconto14
         , CoeficienteSemPremio14
         , CodDesconto15
         , CoeficienteSemPremio15
         , Espaco
    from tmp_16
}
    insert into tmp17_1
    select SeqProposta
         , Seq
         , CodigoReg
         , CodClausula
         , CoeficienteClausula
         , CobrancaSN
         , IncVig
         , FinVig
    from tmp_17

    insert into tmp18_1
    select SeqProposta
         , Seq
         , CodigoReg
         , CodClausula
         , txtClausula
         , seqTexto
         , Espaco
    from tmp_18

       insert into tmp19_1
   select SeqProposta
         ,CodigoReg
         ,CodigoProduto
         ,CodigoQuestao
         ,CodigoResposta
         ,SubResposta
   from tmp_19

   insert into tmp20_1
   select SeqProposta
         ,Seq
         ,PoeConcorrencia
         ,CodigoReg
         ,TipoProduto
   from tmp_20

   insert into tmp20a_1
   select SeqProposta
         ,CodigoQuestao
         ,CodigoResposta
         ,TextoResposta
   from tmp_20a

insert into tmp21_1
    select SeqProposta
         , Seq
         , CodigoReg
         , Nome
         , CPF
         , seqcdt
         , Rg
         , CNH
         , CATCNH
         , Espaco
      from tmp_21

   insert into tmp22_1
   select SeqProposta
        , CodDesconto
        , CoeficienteSemPremio
        from tmp_22

insert into tmp24_1
    select SeqProposta
         , Seq
         , CodigoReg
         ,numacei
      from tmp_24

insert into tmp27_1
    select SeqProposta
         , Seq
         , CodigoReg
         , idcartao
      from tmp_27

insert into tmp29_1
    select  SeqProposta
           , Seq
           , CodigoReg
           , Finalidade
           , Encargos
           , Totalbruto
           , Espaco
    from tmp_29

    insert into tmp30_1
          select  SeqProposta
                  , Seq
                  , CodigoReg
                  , Debito
                  , banco
                  , agencia
                  , conta
                  , contadig
                  , seguroroubo
                  , CPF
                  , nome
                  , data
                  , parentesco
                  , sexo
    from tmp_30

insert into tmp31_1
       select SeqProposta
              , Seq
              , CodigoReg
              ,custoaplanual
              ,coefIOF
              ,premiovista
              ,taxacasco
              ,tiposeg
              ,vlrparc1
              ,vlrdemais
              ,vlrjuros
              ,espaco
      from tmp_31

insert into tmp32_1
       select  SeqProposta
               ,Seq
               ,CodigoReg
               ,RG
               ,Cnh
               ,catcnh
               ,email
               ,tpenviofront
               ,espaco
        from tmp_32

insert into tmp35_1
       select  SeqProposta
        ,Seq
        ,CodigoReg
        ,codbanco
        ,agencia
        ,produtor
        ,pontovenda
        ,postoserv
        ,segcliente
        ,espaco
        from tmp_35


   insert into tmp36_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,IsMorte
         ,IsInvalidez
         ,PremioLiqVidaInd
         ,Espaco
   from tmp_36

   insert into tmp37_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,NomeBeneficiario
         ,GrauParentesco
         ,Espaco
         ,ParticipBeneficiario
         ,Espaco2
   from tmp_37

   insert into tmp38_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,DataAtendimento
         ,HoraAtendimento
         ,LocalAtendimento
         ,TipoServico
         ,Espaco
   from tmp_38

   insert into tmp39_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,TipoInformacao
         ,CodigoInformacao
         ,QtdeServico
         ,TextoComplementar
   from tmp_39

   insert into tmp40_1
   select SeqProposta
         ,Seq
         ,SequenciaLocal
         ,NumeroSeqRisco
         ,NomeBloco
         ,QtdePavimentos
         ,QtdeVagas
         ,TipoConstrucao
         ,QtdeAptosCondominio
         ,ValorRiscoDeclarado
   from tmp_40

   insert into tmp41_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,MeioPagamento
         ,NumeroParcela
         ,CartaoCredito
         ,VenctoCartao
         ,NumeroBanco
         ,NumeroAgencia
         ,ContaCorrente
         ,DigitoCC
         ,DataVencto
         ,ValorParcela
         ,ChequeNum
         ,PracaCheque
         ,CnpjCpfCC
   from tmp_41

   insert into tmp42_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,Fumante
         ,CodigoOperacao
         ,AtualMonetaria
         ,NomeInformar
         ,Telefone
   from tmp_42

   insert into tmp43_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,Empresa
         ,TempoAnosMeses
         ,Produto
         ,Renda
         ,Premio
         ,QtdeParcelasAutoVida
         ,FormaPagtoRenovacao
         ,QtdeParcelasRenovacao
   from tmp_43

   insert into tmp44_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,AssistFuneral
   from tmp_44

   insert into tmp44a_1
   select SeqProposta
         ,Cobertura
   from tmp_44a

   insert into tmp45_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,NumeroNegociacao
   from tmp_45

   insert into tmp46_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,TipoEndereco
         ,TipoLogradouro
         ,Logradouro
         ,Numero
         ,Complemento
         ,CEP
         ,Espaco
   from tmp_46

   insert into tmp47_1
   select SeqProposta
         ,Seq
         ,TipoTexto
         ,SequenciaTexto
         ,DescricaoTexto
   from tmp_47


   insert into tmp48_1
   select SeqProposta
         ,Seq
         ,FlagEndereco
         ,Bairro
         ,Cidade
         ,UF
         ,Email
         ,Espaco
   from tmp_48

   insert into tmp49_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,TipoTelefone
         ,DddTelefone
         ,NumeroTelefone
         ,RamalTelefone
         ,Recados
         ,Espaco
   from tmp_49

   insert into tmp50_1
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,Veiculo
         ,AnoFabricacao
         ,AnoModelo
         ,Flag0Km
         ,Uso
         ,Categoria
         ,QtdePassageiros
         ,PremioCasco
         ,PremioAcessorio
         ,PremioDM
         ,PremioDP
         ,PremioDMO
         ,PremioAPP
         ,AlteracaoCasco
         ,AlteracaoAcessorios
         ,AlteracaoDM
         ,AlteracaoDP
         ,AlteracaoDMO
         ,AlteracaoAPP
   from tmp_50
   insert into tmp52_1
   select  SeqProposta
          ,Seq
          ,CodigoRegistro
          ,TipoTelefone
          ,DddTelefone
          ,NumeroTelefone
          ,RamalTelefone
          ,Recados
          ,Espaco
   from tmp_52

   insert into tmp53_1
   select  SeqProposta
          ,Seq
          ,IdentifConfirmBonus
          ,NumAgendamentoDAF
          ,KitGas
          ,CambioAutomatico
          ,VeicFinanciado
          ,UtilizacaoVeiculo
   from tmp_53

   insert into tmp54_1
   select  SeqProposta
          ,Seq
          ,CodigoReg
          ,CodigoClausula
          ,CoeficienteClausula
          ,CobrancaSN
          ,IncVigencia
          ,FinalVigencia
          ,PremioLiquidoClausula
          ,PremioTotalClausulas
          ,Espaco
   from tmp_54

   insert into tmp55_1
   select SeqProposta
         ,Seq
         ,NumeroPpw
         ,SenhaUtilizada
         ,ClasseLocalizacao
         ,CodigoVeiculo
         ,DataCalculo
         ,DescontoOffLine
         ,Criptografia
         ,CpfProponente
         ,OrdemProponente
         ,DigitoProponente
   from tmp_55

   insert into tmp55a_1
   select SeqProposta
         ,CpfCondutor
         ,DigitoCpfCondutor
   from tmp_55a

   insert into tmp56_1
   select  SeqProposta
          ,Seq
          ,SequenciaLocal
          ,CodigoQuestao
          ,DescricaoResposta
   from tmp_56

   insert into tmp58_1
   select  SeqProposta
          ,Seq
          ,CodigoReg
          ,VersaoDllCalculo
          ,PatrimonioLiquido
          ,RecOperacBrutaAnual
          ,AdminControlProcur
          ,TipoEmpresa
   from tmp_58

   insert into tmp59_1
   select  SeqProposta
          ,Seq
          ,TipoProponente
          ,Nome
          ,TipoPessoa
          ,CpfCnpj
          ,Ordem
          ,Digito
          ,SemCpfCnpjPor
   from tmp_59

   insert into tmp60_1
   select  SeqProposta
          ,Seq
          ,DescricaoTexto
   from tmp_60

   insert into tmp61_1
   select  SeqProposta
          ,Seq
          ,FinalidadeEmissao
          ,FinalidadeEncargos
          ,ValorTotalPremio
   from tmp_61

   insert into tmp62_1
   select  SeqProposta
          ,Seq
          ,TipoFormaPagto
          ,NumeroParcela
          ,NumeroCartaoCredito
          ,VencimentoCartaoCredito
          ,NumeroBanco
          ,NumeroAgencia
          ,NumeroContaCorrente
          ,DigitoContaCorrente
          ,DataVencimento
          ,ValorParcela
          ,NumeroCheque
          ,PracaCheque
          ,CnpjCpfCorrentista
   from tmp_62

   insert into tmp63_1
   select  SeqProposta
          ,Seq
          ,CustoApolice
          ,IOF
          ,PremioVista
          ,TaxaCasco
          ,SeguroMensal
          ,Parcelas1
          ,ParcelasDemais
          ,ParcelasJuros
   from tmp_63

   insert into tmp64_1
   select   SeqProposta
          , Seq
          , TipoFormaPagto
          , NumeroParcela
          , NumeroCartaoCredito
          , VencimentoCartaoCredito
          , NumeroBanco
          , NumeroAgencia
          , NumeroContaCorrente
          , DigitoContaCorrente
          , DataVencimento
          , ValorParcela
          , NumeroCheque
          , PracaCheque
          , CnpjCpfCorrentista
   from tmp_64

   insert into tmp66_1
   select   SeqProposta
            , Seq
        , FlagTransitoGentil
            , CnhTransitoGentil
   from tmp_66

   insert into tmp67_1
   select  SeqProposta
          , Seq
          , CodigoPEP
        , PEP
        , NomePEP
        , CpfPEP
        , DigitoCpfPEP
        , GrauRelacPEP
   from tmp_67


end function


#===============================
function cty21g03_insert_prop2()
#===============================

 insert into tmp00_2
 select SeqProposta
      , Seq
      , PropostaPPW
      , CodigoReg
      , Susep
      , DataExtracao
      , Filler
      , HoraExtracao
      , Versao
      , PRMD
   from tmp_00

 insert into tmp01_2
 select  SeqProposta
       , Seq
       , CodigoReg
       , OrigemPrincipal
       , PropPrincipal
       , SucRenov
       , AplRenov
       , TPendosso
       , TXTendosso
       , QtdItens
       , corresp
       , FormaPgto
       , QtdParcelas
       , VencParc1
       , vigencia
       , IniVig
       , FimVig
       , tiposeguro
       , tipocalculo
       , MoedaPremio
       , SolicAnalise
       , Boleto
       , Espaco
       , CodOperacao
       , FlagEmissao
       , Seguradora
       , EmBranco
       , TarifaPPW
       , FlagPOE
       from tmp_01

 insert into tmp04_2
 select   SeqProposta
         , Seq
         , CodigoReg
         , Susep
         , participCorretor
         , FlagCorr
       from tmp_04

 insert into tmp05_2
  select SeqProposta
       , Seq
       , CodigoReg
       , CodSegurado
       , NomeSegurado
       , TipoPessoa
       , CNPJ_CPF
       , DataNascimento
       , sexo
       , EstadoCivil
       , MotivoSemCNPJ
       , EmBranco
   from tmp_05

 insert into tmp06_2
  select SeqProposta
       , Seq
       , CodigoReg
       , TipoEndereco
       , TipoLogradouro
       , Logradouro
       , Numero
       , Complemento
       , CEP
       , Espaco
   from tmp_06

   insert into tmp07_2
   select SeqProposta
        , Seq
        , FlagEndereco
        , Bairro
        , Cidade
        , UF
        , DDD
        , Telefone
        , Espaco
      from tmp_07

   insert into tmp08_2
    select SeqProposta
         , Seq
         , CodigoReg
         , NumeroItem
         , NumeroOrigem
         , PropostaIndividual
         , ClasseBonus
         , ClasseLocalizacao
         , TrafegoHabitual
         , IncVigAnterior
         , FinVigAnterior
         , Seguradora
         , SucursalItem
         , AplDoItem
         , Espaco
    from tmp_08

  insert into tmp09_2
   select SeqProposta
        , Seq
        , CodigoReg
        , ObsProposta
        , Sequencia
        , Espaco
    from tmp_09


   insert into tmp10_2
   select SeqProposta
        , Seq
        , CodigoReg
        , CodVeiculo
        , AnoFabricacao
        , AnoModelo
        , Placa
        , Chassi
        , Renavam
        , TipoUso
        , Veiculo0km
        , TipoVistoria
        , VPCOBprovisoria
        , CapacidadePassageiros
        , FlagAutoRevenda
        , FlagAutoNovo
        , CategoriaTarifada
        , combustivel
        , QtdePortas
        , DataVistoria
        , VeiculoBlindado
        , FlagChassiRemarc
        , CodigoTabelaFipe
        , CodigoRenovacao
    from tmp_10

   insert into tmp11_2
   select SeqProposta
        , Seq
        , CodigoReg
        , NotaFiscal
        , DataEmissao
        , DataSaidaVeiculo
        , CodConcessionaria
        , NomeConcessionaria
        , ValorNota
        , Espaco
   from tmp_11

   insert into tmp12_2
   select SeqProposta
        , Seq
        , CodigoReg
        , DataRealizacaoCalc
        , Franquia
        , Cobertura
        , FranquiaCasco
        , ISCalculo
        , IsencaoImpostos
        , ISdaBlindagem
        , PremioLiqCasco
        , CotacaoMotorShow
        , PercentISCasco
        , PercentISBlindagem
        , FatorDepreciacao
        , ValorBasico
        , ValorMaximo
        , TabelaUtilizada
   from tmp_12
   insert into tmp13_2
   select SeqProposta
        , Seq
        , CodigoReg
        , DataRealizCalc
        , RefAcessorio
        , TipoAcessorio
        , ValorFranquia
        , ISFranquia
        , SeqAcessorio
        , PremioLiqAcess
    from tmp_13

   insert into tmp14_2
   select SeqProposta
        , Seq
        , CodigoReg
        , DataRealizaCalc
        , ClasseFranquia
        , ValorFranquiaDM
        , ISDM
        , ValorFranquiaDC
        , ISDC
        , PremioLiqRCFDM
        , PremioLiqRCFDC
        , Espaco
    from tmp_14

    insert into tmp15_2
    select SeqProposta
         , Seq
         , CodigoReg
         , DataRealizaCalc
         , ISInvalidez
         , ISMorte
         , ISDMH
         , PremioLiqApp
         , Espaco
     from tmp_15

    {insert into tmp16_2
    select SeqProposta
         , Seq
         , CodigoReg
         , CodDesconto
         , CoeficienteSemPremio
         , CodDesconto2
         , CoeficienteSemPremio2
         , CodDesconto3
         , CoeficienteSemPremio3
         , CodDesconto4
         , CoeficienteSemPremio4
         , CodDesconto5
         , CoeficienteSemPremio5
         , CodDesconto6
         , CoeficienteSemPremio6
         , CodDesconto7
         , CoeficienteSemPremio7
         , CodDesconto8
         , CoeficienteSemPremio8
         , CodDesconto9
         , CoeficienteSemPremio9
         , CodDesconto10
         , CoeficienteSemPremio10
         , CodDesconto11
         , CoeficienteSemPremio11
         , CodDesconto12
         , CoeficienteSemPremio12
         , CodDesconto13
         , CoeficienteSemPremio13
         , CodDesconto14
         , CoeficienteSemPremio14
         , CodDesconto15
         , CoeficienteSemPremio15
         , Espaco
    from tmp_16
}
    insert into tmp17_2
    select SeqProposta
         , Seq
         , CodigoReg
         , CodClausula
         , CoeficienteClausula
         , CobrancaSN
         , IncVig
         , FinVig
    from tmp_17

    insert into tmp18_2
    select SeqProposta
         , Seq
         , CodigoReg
         , CodClausula
         , txtClausula
         , seqTexto
         , Espaco
    from tmp_18

   insert into tmp19_2
   select SeqProposta
         ,CodigoReg
         ,CodigoProduto
         ,CodigoQuestao
         ,CodigoResposta
         ,SubResposta
   from tmp_19

   insert into tmp20_2
   select SeqProposta
         ,Seq
         ,PoeConcorrencia
         ,CodigoReg
         ,TipoProduto
   from tmp_20

   insert into tmp20a_2
   select SeqProposta
         ,CodigoQuestao
         ,CodigoResposta
         ,TextoResposta
   from tmp_20a

   insert into tmp21_2
    select SeqProposta
         , Seq
         , CodigoReg
         , Nome
         , CPF
         , seqcdt
         , Rg
         , CNH
         , CATCNH
         , Espaco
      from tmp_21

   insert into tmp22_2
   select SeqProposta
        , CodDesconto
        , CoeficienteSemPremio
        from tmp_22

insert into tmp24_2
    select SeqProposta
         , Seq
         , CodigoReg
         ,numacei
      from tmp_24

insert into tmp27_2
    select SeqProposta
         , Seq
         , CodigoReg
         , idcartao
      from tmp_27

insert into tmp29_2
    select  SeqProposta
           , Seq
           , CodigoReg
           , Finalidade
           , Encargos
           , Totalbruto
           , Espaco
    from tmp_29

insert into tmp30_2
          select  SeqProposta
                  , Seq
                  , CodigoReg
                  , Debito
                  , banco
                  , agencia
                  , conta
                  , contadig
                  , seguroroubo
                  , CPF
                  , nome
                  , data
                  , parentesco
                  , sexo
    from tmp_30

insert into tmp31_2
       select SeqProposta
              , Seq
              , CodigoReg
              ,custoaplanual
              ,coefIOF
              ,premiovista
              ,taxacasco
              ,tiposeg
              ,vlrparc1
              ,vlrdemais
              ,vlrjuros
              ,espaco
      from tmp_31

insert into tmp32_2
       select  SeqProposta
               ,Seq
               ,CodigoReg
               ,RG
               ,Cnh
               ,catcnh
               ,email
               ,tpenviofront
               ,espaco
        from tmp_32

insert into tmp35_2
       select SeqProposta
        ,Seq
        ,CodigoReg
        ,codbanco
        ,agencia
        ,produtor
        ,pontovenda
        ,postoserv
        ,segcliente
        ,espaco
        from tmp_35


   insert into tmp36_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,IsMorte
         ,IsInvalidez
         ,PremioLiqVidaInd
         ,Espaco
   from tmp_36

   insert into tmp37_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,NomeBeneficiario
         ,GrauParentesco
         ,Espaco
         ,ParticipBeneficiario
         ,Espaco2
   from tmp_37

   insert into tmp38_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,DataAtendimento
         ,HoraAtendimento
         ,LocalAtendimento
         ,TipoServico
         ,Espaco
   from tmp_38

   insert into tmp39_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,TipoInformacao
         ,CodigoInformacao
         ,QtdeServico
         ,TextoComplementar
   from tmp_39

   insert into tmp40_2
   select SeqProposta
         ,Seq
         ,SequenciaLocal
         ,NumeroSeqRisco
         ,NomeBloco
         ,QtdePavimentos
         ,QtdeVagas
         ,TipoConstrucao
         ,QtdeAptosCondominio
         ,ValorRiscoDeclarado
   from tmp_40

   insert into tmp41_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,MeioPagamento
         ,NumeroParcela
         ,CartaoCredito
         ,VenctoCartao
         ,NumeroBanco
         ,NumeroAgencia
         ,ContaCorrente
         ,DigitoCC
         ,DataVencto
         ,ValorParcela
         ,ChequeNum
         ,PracaCheque
         ,CnpjCpfCC
   from tmp_41

   insert into tmp42_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,Fumante
         ,CodigoOperacao
         ,AtualMonetaria
         ,NomeInformar
         ,Telefone
   from tmp_42

   insert into tmp43_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,Empresa
         ,TempoAnosMeses
         ,Produto
         ,Renda
         ,Premio
         ,QtdeParcelasAutoVida
         ,FormaPagtoRenovacao
         ,QtdeParcelasRenovacao
   from tmp_43

   insert into tmp44_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,AssistFuneral
   from tmp_44

   insert into tmp44a_2
   select SeqProposta
         ,Cobertura
   from tmp_44a

   insert into tmp45_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,NumeroNegociacao
   from tmp_45


   insert into tmp46_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,TipoEndereco
         ,TipoLogradouro
         ,Logradouro
         ,Numero
         ,Complemento
         ,CEP
         ,Espaco
   from tmp_46
   insert into tmp47_2
   select SeqProposta
         ,Seq
         ,TipoTexto
         ,SequenciaTexto
         ,DescricaoTexto
   from tmp_47

   insert into tmp48_2
   select SeqProposta
         ,Seq
         ,FlagEndereco
         ,Bairro
         ,Cidade
         ,UF
         ,Email
         ,Espaco
   from tmp_48

   insert into tmp49_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,TipoTelefone
         ,DddTelefone
         ,NumeroTelefone
         ,RamalTelefone
         ,Recados
         ,Espaco
   from tmp_49
   insert into tmp50_2
   select SeqProposta
         ,Seq
         ,CodigoReg
         ,Veiculo
         ,AnoFabricacao
         ,AnoModelo
         ,Flag0Km
         ,Uso
         ,Categoria
         ,QtdePassageiros
         ,PremioCasco
         ,PremioAcessorio
         ,PremioDM
         ,PremioDP
         ,PremioDMO
         ,PremioAPP
         ,AlteracaoCasco
         ,AlteracaoAcessorios
         ,AlteracaoDM
         ,AlteracaoDP
         ,AlteracaoDMO
         ,AlteracaoAPP
   from tmp_50

   insert into tmp52_2
   select  SeqProposta
          ,Seq
          ,CodigoRegistro
          ,TipoTelefone
          ,DddTelefone
          ,NumeroTelefone
          ,RamalTelefone
          ,Recados
          ,Espaco
   from tmp_52

   insert into tmp53_2
   select  SeqProposta
          ,Seq
          ,IdentifConfirmBonus
          ,NumAgendamentoDAF
          ,KitGas
          ,CambioAutomatico
          ,VeicFinanciado
          ,UtilizacaoVeiculo
   from tmp_53

   insert into tmp54_2
   select  SeqProposta
          ,Seq
          ,CodigoReg
          ,CodigoClausula
          ,CoeficienteClausula
          ,CobrancaSN
          ,IncVigencia
          ,FinalVigencia
          ,PremioLiquidoClausula
          ,PremioTotalClausulas
          ,Espaco
   from tmp_54

   insert into tmp55_2
   select SeqProposta
         ,Seq
         ,NumeroPpw
         ,SenhaUtilizada
         ,ClasseLocalizacao
         ,CodigoVeiculo
         ,DataCalculo
         ,DescontoOffLine
         ,Criptografia
         ,CpfProponente
         ,OrdemProponente
         ,DigitoProponente
   from tmp_55

   insert into tmp55a_2
   select SeqProposta
         ,CpfCondutor
         ,DigitoCpfCondutor
   from tmp_55a

   insert into tmp56_2
   select  SeqProposta
          ,Seq
          ,SequenciaLocal
          ,CodigoQuestao
          ,DescricaoResposta
   from tmp_56

   insert into tmp58_2
   select  SeqProposta
          ,Seq
          ,CodigoReg
          ,VersaoDllCalculo
          ,PatrimonioLiquido
          ,RecOperacBrutaAnual
          ,AdminControlProcur
          ,TipoEmpresa
   from tmp_58

   insert into tmp59_2
   select  SeqProposta
          ,Seq
          ,TipoProponente
          ,Nome
          ,TipoPessoa
          ,CpfCnpj
          ,Ordem
          ,Digito
          ,SemCpfCnpjPor
   from tmp_59

   insert into tmp60_2
   select  SeqProposta
          ,Seq
          ,DescricaoTexto
   from tmp_60

   insert into tmp61_2
   select  SeqProposta
          ,Seq
          ,FinalidadeEmissao
          ,FinalidadeEncargos
          ,ValorTotalPremio
   from tmp_61

   insert into tmp62_2
   select  SeqProposta
          ,Seq
          ,TipoFormaPagto
          ,NumeroParcela
          ,NumeroCartaoCredito
          ,VencimentoCartaoCredito
          ,NumeroBanco
          ,NumeroAgencia
          ,NumeroContaCorrente
          ,DigitoContaCorrente
          ,DataVencimento
          ,ValorParcela
          ,NumeroCheque
          ,PracaCheque
          ,CnpjCpfCorrentista
   from tmp_62

   insert into tmp63_2
   select  SeqProposta
          ,Seq
          ,CustoApolice
          ,IOF
          ,PremioVista
          ,TaxaCasco
          ,SeguroMensal
          ,Parcelas1
          ,ParcelasDemais
          ,ParcelasJuros
   from tmp_63

   insert into tmp64_2
   select   SeqProposta
          , Seq
          , TipoFormaPagto
          , NumeroParcela
          , NumeroCartaoCredito
          , VencimentoCartaoCredito
          , NumeroBanco
          , NumeroAgencia
          , NumeroContaCorrente
          , DigitoContaCorrente
          , DataVencimento
          , ValorParcela
          , NumeroCheque
          , PracaCheque
          , CnpjCpfCorrentista
   from tmp_64


   insert into tmp66_2
   select   SeqProposta
            , Seq
        , FlagTransitoGentil
            , CnhTransitoGentil
   from tmp_66

   insert into tmp67_2
   select  SeqProposta
          , Seq
          , CodigoPEP
        , PEP
        , NomePEP
        , CpfPEP
        , DigitoCpfPEP
        , GrauRelacPEP
   from tmp_67


end function

#===============================
function cty21g03_compara_tudo_F5()
#===============================
let m_chave_diff = 0
call cty21g03_campos_header()         # HEADER
let m_chave_diff = 0
call cty21g03_campos_capaproposta()   # CAPA DA PROPOSTA
let m_chave_diff = 0
call cty21g03_campos_corretores()     # CORRETORES
let m_chave_diff = 0
call cty21g03_campos_dadosSegurado()  # DADOS DO SEGURADO
let m_chave_diff = 0
call cty21g03_campos_EndSegurado()    # ENDERECO DO SEGURADO
let m_chave_diff = 0
call cty21g03_campos_ContinuaEnd()    # CONTINUACAO DO ENDERECO
let m_chave_diff = 0
call cty21g03_campos_Itens()          # ITENS
let m_chave_diff = 0
call cty21g03_campos_ObsItem()        # OBSERVACAO DO ITEM
let m_chave_diff = 0
call cty21g03_campos_DadosDoVeiculo() # DADOS DO VEICULO
let m_chave_diff = 0
call cty21g03_campos_veiculo0km()     # VEICULO 0 KM
let m_chave_diff = 0
call cty21g03_campos_casco()          # CASCO
let m_chave_diff = 0
call cty21g03_campos_acessorios()     # ACESSORIOS
let m_chave_diff = 0
call cty21g03_campos_RCF()            # RCF
let m_chave_diff = 0
call cty21g03_campos_APP()            # APP
let m_chave_diff = 0
#call cty21g03_campos_refdescagravo()  # REGISTRO DE DESCONTOS E AGRAVO
#let m_chave_diff = 0
call cty21g03_campos_regclausula()    # REGISTRO DE CLAUSULA
let m_chave_diff = 0
call cty21g03_campos_txtclausula()    # TEXTOS DE CLAUSULA
let m_chave_diff = 0
call cty21g03_campos_QuestPerfil()    # QUESTIONARIO PERFIL
let m_chave_diff = 0
call cty21g03_campos_PoeRespTextos()  # POE - RESPOSTAS E TEXTOS
let m_chave_diff = 0
call cty21g03_campos_condutor()       # CONDUTOR DO VEICULO
let m_chave_diff = 0
call cty21g03_campos_desc_agravos()   # REGISTRO DE DESCONTOS E AGRAVO 22
let m_chave_diff = 0
call cty21g03_campos_nego_aceitacao() # NEGOCIACAO DE ACEITACAO
let m_chave_diff = 0
call cty21g03_campos_id_cartao()      # ID DO CARTAO PORTO VISA
let m_chave_diff = 0
call cty21g03_campos_finalidade()     # FINALIDADE DE EMISSAO
let m_chave_diff = 0
call cty21g03_campos_cartao()         # INFORMACOES CARTAO
let m_chave_diff = 0
call cty21g03_campos_custo_apolice()  # CUSTO DE APOLICE
let m_chave_diff = 0
call cty21g03_campos_compl_dados()    # COMPLEMENTO DE DADOS
let m_chave_diff = 0
call cty21g03_campos_agencia_angariacao()    # AGENCIA DE ANGARIACAO
let m_chave_diff = 0
call cty21g03_campos_Vida()           # VIDA
let m_chave_diff = 0
call cty21g03_campos_BenefVidaIndiv() # BENEFICIARIOS DO SEGURO DE VIDA INDIVIDUAL
let m_chave_diff = 0
call cty21g03_campos_Atendimentos()   # ATENDIMENTOS
let m_chave_diff = 0
call cty21g03_campos_ServicosObserv() # SERVICOS E OBSERVACOES
let m_chave_diff = 0
call cty21g03_campos_BlocosCondom()   # BLOCOS DE UM CONDOMINIO
let m_chave_diff = 0
call cty21g03_campos_Parcelamento()   # PARCELAMENTO
let m_chave_diff = 0
call cty21g03_campos_AutoMaisVida()   # AUTO + VIDA
let m_chave_diff = 0
call cty21g03_campos_VidaComplement() # VIDA (COMPLEMENTO)
let m_chave_diff = 0
call cty21g03_campos_AutoVidaCobert() # AUTO + VIDA (COBERTURAS)
let m_chave_diff = 0
call cty21g03_campos_NegocConcessao() # NEGOCIACAO DE CONCESSAO
let m_chave_diff = 0
call cty21g03_campos_EnderecoCartao() # ENDERECO DO CARTAO
let m_chave_diff = 0
call cty21g03_campos_ClsParticDeclar()# CLS. PARTICULAR/DECLARACOES
let m_chave_diff = 0
call cty21g03_campos_ComplEndCartao() # COMPLEMENTO DO ENDERECO - CARTAO
let m_chave_diff = 0
call cty21g03_campos_TelsSegurCartao()# TELEFONES DO SEGURADO - CARTAO
let m_chave_diff = 0
call cty21g03_campos_PremiosPagos()   # PREMIOS PAGOS
let m_chave_diff = 0
call cty21g03_campos_TelsSegurado()   # TELEFONES DO SEGURADO
let m_chave_diff = 0
call cty21g03_campos_ComplVeiculo()   # COMPLEMENTO DO VEICULO
let m_chave_diff = 0
call cty21g03_campos_Clausula()       # REGISTRO DE CLAUSULA
let m_chave_diff = 0
call cty21g03_campos_DescontoLocal()  # DESCONTO LOCAL - POL OFF LINE
let m_chave_diff = 0
call cty21g03_campos_QuestObrigat()   # QUESTIONARIO OBRIGATORIO (EMPRESA)
let m_chave_diff = 0
call cty21g03_campos_VersaoDLL()      # VERSÃO DA DLL E DADOS ADICIONAIS DO SEGURADO PJ
let m_chave_diff = 0
call cty21g03_campos_VinculosPJ()     # VINCULOS PJ - CONTROLADORES, ADMINISTRADORES, PROCURADORES
let m_chave_diff = 0
call cty21g03_campos_OutrosSeguros()  # OUTROS SEGUROS
let m_chave_diff = 0
call cty21g03_campos_FinalidEmissao() # FINALIDADE DA EMISSAO
let m_chave_diff = 0
call cty21g03_campos_CobrancaAntigo() # DADOS DE COBRANCA - ANTIGO
let m_chave_diff = 0
call cty21g03_campos_CustosApolices() # CUSTOS DE APOLICES/PARCELAS
let m_chave_diff = 0
call cty21g03_campos_CobrancaNovo()   # DADOS DE COBRANCA - NOVO(A PARTIR DEZ)
let m_chave_diff = 0
call cty21g03_campos_TransitoGentil() # TRANSITO MAIS GENTIL
let m_chave_diff = 0
call cty21g03_campos_Pep()            # PEP
let m_chave_diff = 0

end function


##===============================
#function cty21g03_compara_tudo_F6()
##===============================
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('00') then
#   call cty21g03_campos_header()         # HEADER
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('01') then
#   call cty21g03_campos_capaproposta()   # CAPA DA PROPOSTA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('04') then
#   call cty21g03_campos_corretores()     # CORRETORES
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('05') then
#   call cty21g03_campos_dadosSegurado()  # DADOS DO SEGURADO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('06') then
#   call cty21g03_campos_EndSegurado()    # ENDERECO DO SEGURADO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('07') then
#   call cty21g03_campos_ContinuaEnd()    # CONTINUACAO DO ENDERECO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('08') then
#   call cty21g03_campos_Itens()          # ITENS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('09') then
#   call cty21g03_campos_ObsItem()        # OBSERVACAO DO ITEM
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('10') then
#   call cty21g03_campos_DadosDoVeiculo() # DADOS DO VEICULO
#end if
#
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('11') then
#   call cty21g03_campos_veiculo0km()     # VEICULO 0 KM
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('12') then
#   call cty21g03_campos_casco()          # CASCO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('13') then
#   call cty21g03_campos_acessorios()     # ACESSORIOS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('14') then
#   call cty21g03_campos_RCF()            # RCF
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('15') then
#   call cty21g03_campos_APP()            # APP
#end if
#
#let m_chave_diff = 0
##call cty21g03_campos_refdescagravo()  # REGISTRO DE DESCONTOS E AGRAVO
##let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('17') then
#   call cty21g03_campos_regclausula()    # REGISTRO DE CLAUSULA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('18') then
#   call cty21g03_campos_txtclausula()    # TEXTOS DE CLAUSULA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('19') then
#   call cty21g03_campos_QuestPerfil()    # QUESTIONARIO PERFIL
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('20') then
#   call cty21g03_campos_PoeRespTextos()  # POE - RESPOSTAS E TEXTOS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('21') then
#   call cty21g03_campos_condutor()       # CONDUTOR DO VEICULO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('22') then
#   call cty21g03_campos_desc_agravos()   # REGISTRO DE DESCONTOS E AGRAVO 22
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('24') then
#   call cty21g03_campos_nego_aceitacao() # NEGOCIACAO DE ACEITACAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('27') then
#   call cty21g03_campos_id_cartao()      # ID DO CARTAO PORTO VISA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('29') then
#   call cty21g03_campos_finalidade()     # FINALIDADE DE EMISSAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('30') then
#   call cty21g03_campos_cartao()         # INFORMACOES CARTAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('31') then
#   call cty21g03_campos_custo_apolice()  # CUSTO DE APOLICE
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('32') then
#   call cty21g03_campos_compl_dados()    # COMPLEMENTO DE DADOS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('35') then
#   call cty21g03_campos_agencia_angariacao()    # AGENCIA DE ANGARIACAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('36') then
#   call cty21g03_campos_Vida()           # VIDA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('37') then
#   call cty21g03_campos_BenefVidaIndiv() # BENEFICIARIOS DO SEGURO DE VIDA INDIVIDUAL
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('38') then
#   call cty21g03_campos_Atendimentos()   # ATENDIMENTOS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('39') then
#   call cty21g03_campos_ServicosObserv() # SERVICOS E OBSERVACOES
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('40') then
#   call cty21g03_campos_BlocosCondom()   # BLOCOS DE UM CONDOMINIO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('41') then
#   call cty21g03_campos_Parcelamento()   # PARCELAMENTO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('42') then
#   call cty21g03_campos_AutoMaisVida()   # AUTO + VIDA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('43') then
#   call cty21g03_campos_VidaComplement() # VIDA (COMPLEMENTO)
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('44') then
#   call cty21g03_campos_AutoVidaCobert() # AUTO + VIDA (COBERTURAS)
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('45') then
#   call cty21g03_campos_NegocConcessao() # NEGOCIACAO DE CONCESSAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('46') then
#   call cty21g03_campos_EnderecoCartao() # ENDERECO DO CARTAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('47') then
#   call cty21g03_campos_ClsParticDeclar()# CLS. PARTICULAR/DECLARACOES
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('48') then
#   call cty21g03_campos_ComplEndCartao() # COMPLEMENTO DO ENDERECO - CARTAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('49') then
#   call cty21g03_campos_TelsSegurCartao()# TELEFONES DO SEGURADO - CARTAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('50') then
#   call cty21g03_campos_PremiosPagos()   # PREMIOS PAGOS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('52') then
#   call cty21g03_campos_TelsSegurado()   # TELEFONES DO SEGURADO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('53') then
#   call cty21g03_campos_ComplVeiculo()   # COMPLEMENTO DO VEICULO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('54') then
#   call cty21g03_campos_Clausula()       # REGISTRO DE CLAUSULA
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('55') then
#   call cty21g03_campos_DescontoLocal()  # DESCONTO LOCAL - POL OFF LINE
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('56') then
#   call cty21g03_campos_QuestObrigat()   # QUESTIONARIO OBRIGATORIO (EMPRESA)
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('58') then
#   call cty21g03_campos_VersaoDLL()      # VERSÃO DA DLL E DADOS ADICIONAIS DO SEGURADO PJ
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('59') then
#   call cty21g03_campos_VinculosPJ()     # VINCULOS PJ - CONTROLADORES, ADMINISTRADORES, PROCURADORES
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('60') then
#   call cty21g03_campos_OutrosSeguros()  # OUTROS SEGUROS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('61') then
#   call cty21g03_campos_FinalidEmissao() # FINALIDADE DA EMISSAO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('62') then
#   call cty21g03_campos_CobrancaAntigo() # DADOS DE COBRANCA - ANTIGO
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('63') then
#   call cty21g03_campos_CustosApolices() # CUSTOS DE APOLICES/PARCELAS
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('64') then
#   call cty21g03_campos_CobrancaNovo()   # DADOS DE COBRANCA - NOVO(A PARTIR DEZ)
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('66') then
#   call cty21g03_campos_TransitoGentil() # TRANSITO MAIS GENTIL
#end if
#
#let m_chave_diff = 0
#
#if cty21g03_verifica_dominio('67') then
#   call cty21g03_campos_Pep()            # PEP
#end if
#
#let m_chave_diff = 0
#
#end function


#================================
function cty21g03_campos_header()
#================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=============================== HEADER ============================="

######## HEADER ########

--------------------------------susep-----------------------------------
 let l_campo_compara = 'susep'
 let l_tabela_1 = 'tmp00_1'
 let l_tabela_2 = 'tmp00_2'
 let l_titulo   = ' > Susep : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)


-----------------------------DataExtracao-------------------------------
 let l_campo_compara = 'DataExtracao'
 let l_tabela_1 = 'tmp00_1'
 let l_tabela_2 = 'tmp00_2'
 let l_titulo   = ' > Data Extracao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------------Filler---------------------------------
 let l_campo_compara = 'Filler'
 let l_tabela_1 = 'tmp00_1'
 let l_tabela_2 = 'tmp00_2'
 let l_titulo   = ' > Filler : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

------------------------------HoraExtracao------------------------------
 let l_campo_compara = 'HoraExtracao'
 let l_tabela_1 = 'tmp00_1'
 let l_tabela_2 = 'tmp00_2'
 let l_titulo   = ' > Hora Extracao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

--------------------------------Versao---------------------------------
 let l_campo_compara = 'Versao'
 let l_tabela_1 = 'tmp00_1'
 let l_tabela_2 = 'tmp00_2'
 let l_titulo   = ' > Versao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------------PRMD----------------------------------
 let l_campo_compara = 'PRMD'
 let l_tabela_1 = 'tmp00_1'
 let l_tabela_2 = 'tmp00_2'
 let l_titulo   = ' > PRMD : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)
----------------------------------------------------------------------

call cty21g03_verifica_diff()


end function


#=======================================
function cty21g03_campos_capaproposta()
#=======================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== CAPA DA PROPOSTA ========================"

######## CAPA DA PROPOSTA ########

-------------------------------OrigemPrincipal-------------------------
 let l_campo_compara = 'OrigemPrincipal'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Origem Principal : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

-------------------------------PropPrincipal--------------------------
 let l_campo_compara = 'PropPrincipal'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Proposta Principal : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

-------------------------------SucRenov--------------------------------
 let l_campo_compara = 'SucRenov'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Sucursal Renovacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

-------------------------------AplRenov--------------------------------
 let l_campo_compara = 'AplRenov'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Apolice Renovacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

-------------------------------TPendosso--------------------------------
 let l_campo_compara = 'TPendosso'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Tipo do Endosso : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

-------------------------------TXTendosso--------------------------------
 let l_campo_compara = 'TXTendosso'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Texto do Endosso : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

-------------------------------QtdItens--------------------------------
 let l_campo_compara = 'QtdItens'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Quantidade de itens : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)
-------------------------------corresp--------------------------------
 let l_campo_compara = 'corresp'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Correspondencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------FormaPgto-----------------------------------
 let l_campo_compara = 'FormaPgto'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Forma de Pagamento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------QtdParcelas-----------------------------------
 let l_campo_compara = 'QtdParcelas'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Quantidade de Parcelas : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------VencParc1-----------------------------------
 let l_campo_compara = 'VencParc1'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Vencimento Parcela 1 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Vigencia-----------------------------------
 let l_campo_compara = 'Vigencia'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Vigencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------IniVig-----------------------------------
 let l_campo_compara = 'IniVig'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Inicio da Vigencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------FimVig-----------------------------------
 let l_campo_compara = 'FimVig'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Final da Vigencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------tiposeguro-----------------------------------
 let l_campo_compara = 'tiposeguro'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Tipo do Seguro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------tipocalculo-----------------------------------
 let l_campo_compara = 'tipocalculo'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Tipo do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------MoedaPremio-----------------------------------
 let l_campo_compara = 'MoedaPremio'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Moeda Premio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------SolicAnalise-----------------------------------
 let l_campo_compara = 'SolicAnalise'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Solicitacao de Analise : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Boleto-----------------------------------
 let l_campo_compara = 'Boleto'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Boleto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-----------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CodOperacao-----------------------------------
 let l_campo_compara = 'CodOperacao'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Codigo de Operacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------FlagEmissao-----------------------------------
 let l_campo_compara = 'FlagEmissao'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Flag de Emissao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Seguradora-----------------------------------
 let l_campo_compara = 'Seguradora'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Seguradora : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------EmBranco-----------------------------------
 let l_campo_compara = 'EmBranco'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Em Branco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------TarifaPPW-----------------------------------
 let l_campo_compara = 'TarifaPPW'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Tarifa Porto Print : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------FlagPOE-----------------------------------
 let l_campo_compara = 'FlagPOE'
 let l_tabela_1 = 'tmp01_1'
 let l_tabela_2 = 'tmp01_2'
 let l_titulo   = ' > Flag POE : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()
end function

#=======================================
function cty21g03_campos_corretores()
#=======================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

define l_1_susep         char(100)
define l_1_participcorr  char(10)
define l_1_flagcorr      char(1)

define l_2_susep         char(100)
define l_2_participcorr  char(10)
define l_2_flagcorr      char(1)



 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "============================= CORRETORES ==========================="

 call cty21g03_prepare_04_corretor()

 open ccty21g0304corr
 foreach ccty21g0304corr into  l_1_susep
                            ,  l_1_participcorr
                            ,  l_1_flagcorr
											      ,  l_2_susep
                            ,  l_2_participcorr
                            ,  l_2_flagcorr

    if l_1_participcorr <>  l_2_participcorr or
       l_1_flagcorr     <>  l_2_flagcorr     or
       l_1_susep        =   ' '              or
       l_2_susep        =   ' '              or
       l_1_susep        is null              or
       l_2_susep        is null              then

       #carrega array
        if (l_1_susep is not null or
            l_1_susep <> ' '         ) and
           (l_2_susep is not null or
            l_2_susep <> ' '         ) then

            let ccty21g03_tela[m_index+2] = " ----------- ", l_1_susep clipped," ----------- "
            let m_index = m_index + 2

            if l_1_participcorr <>  l_2_participcorr then
               let ccty21g03_tela[m_index+1] = " > Participacao do Corretor : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_participcorr
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_participcorr
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_flagcorr <> l_2_flagcorr then
               let ccty21g03_tela[m_index+1] = " > Flag do Corretor : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_flagcorr
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_flagcorr
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 4
            end if

        else
           let m_index = m_index + 1

           if l_1_susep is null or l_1_susep = ' ' then
              let ccty21g03_tela[m_index] = "         ----------------------------------- "
              let ccty21g03_tela[m_index+1] = " > Corretor INCLUIDO! na 2a Proposta : "
              let ccty21g03_tela[m_index+2] = "     Susep.........: ",l_2_susep
              let ccty21g03_tela[m_index+3] = "     Participacao..: ",l_2_participcorr
              let ccty21g03_tela[m_index+4] = "     Flag Corretor.: ",l_2_flagcorr

              let m_index = m_index + 5
           end if

           if l_2_susep is null or l_2_susep = ' ' then
              let ccty21g03_tela[m_index] = "          ----------------------------------- "
              let ccty21g03_tela[m_index+1] = " > Corretor EXCLUIDO! na 2a Proposta : "
              let ccty21g03_tela[m_index+2] = "    Susep.........: ",l_1_susep
              let ccty21g03_tela[m_index+3] = "    Participacao..: ",l_1_participcorr
              let ccty21g03_tela[m_index+4] = "    Flag Corretor.: ",l_1_flagcorr

              let m_index = m_index + 5
           end if

       let m_chave_diff = 1
     end if
   end if

 end foreach

call cty21g03_verifica_diff()

end function


#==========================================
function cty21g03_campos_dadosSegurado()
#==========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== DADOS DO SEGURADO ======================="

######## DADOS DO SEGURADO ########
----------------------------CodSegurado-------------------------------
 let l_campo_compara = 'CodSegurado'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Codigo do Segurado : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------NomeSegurado-------------------------------
 let l_campo_compara = 'NomeSegurado'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Nome do Segurado : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------TipoPessoa-------------------------------
 let l_campo_compara = 'TipoPessoa'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Tipo Pessoa (F/J) : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CNPJ_CPF-------------------------------
 let l_campo_compara = 'CNPJ_CPF'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > CNPJ / CPF : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------DataNascimento-------------------------------
 let l_campo_compara = 'DataNascimento'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Data de Nascimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------sexo-------------------------------
 let l_campo_compara = 'sexo'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Sexo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------EstadoCivil-------------------------------
 let l_campo_compara = 'EstadoCivil'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Estado Civil : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------MotivoSemCNPJ-------------------------------
 let l_campo_compara = 'MotivoSemCNPJ'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Motivo de Sem CNPJ : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------EmBranco-------------------------------
 let l_campo_compara = 'EmBranco'
 let l_tabela_1 = 'tmp05_1'
 let l_tabela_2 = 'tmp05_2'
 let l_titulo   = ' > Em Branco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()
end function

#========================================
function cty21g03_campos_EndSegurado()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======================== ENDERECO DO SEGURADO ======================"

######## ENDERECO DO SEGURADO ########
----------------------------TipoEndereco-------------------------------
 let l_campo_compara = 'TipoEndereco'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > Tipo do Endereco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------TipoLogradouro-------------------------------
 let l_campo_compara = 'TipoLogradouro'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > Tipo do Logradouro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Logradouro-------------------------------
 let l_campo_compara = 'Logradouro'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > Logradouro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Numero-------------------------------
 let l_campo_compara = 'Numero'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > Numero : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Complemento-------------------------------
 let l_campo_compara = 'Complemento'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > Complemento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CEP-------------------------------
 let l_campo_compara = 'CEP'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > CEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp06_1'
 let l_tabela_2 = 'tmp06_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_ContinuaEnd()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = " "

######## CONTINUACAO DO ENDERECO ########
----------------------------FlagEndereco-------------------------------
 let l_campo_compara = 'FlagEndereco'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > Flag do Endereco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Bairro-------------------------------
 let l_campo_compara = 'Bairro'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > Bairro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Cidade-------------------------------
 let l_campo_compara = 'Cidade'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > Cidade : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------UF-------------------------------
 let l_campo_compara = 'UF'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > UF : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------DDD-------------------------------
 let l_campo_compara = 'DDD'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > DDD : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Telefone-------------------------------
 let l_campo_compara = 'Telefone'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp07_1'
 let l_tabela_2 = 'tmp07_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()
end function

#===============================
function cty21g03_campos_Itens()
#===============================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================================= ITEM =============================="

######## ITEM ########
----------------------------NumeroItem-------------------------------
 let l_campo_compara = 'NumeroItem'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Numero do Item : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroOrigem-------------------------------
 let l_campo_compara = 'NumeroOrigem'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Numero da Origem : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PropostaIndividual-------------------------------
 let l_campo_compara = 'PropostaIndividual'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Proposta Individual : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ClasseBonus-------------------------------
 let l_campo_compara = 'ClasseBonus'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Classe de Bonus : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ClasseLocalizacao-------------------------------
 let l_campo_compara = 'ClasseLocalizacao'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Classe da Localizacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TrafegoHabitual-------------------------------
 let l_campo_compara = 'TrafegoHabitual'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Trafego Habitual : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------IncVigAnterior-------------------------------
 let l_campo_compara = 'IncVigAnterior'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Incio da Vigencia Anterior : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FinVigAnterior-------------------------------
 let l_campo_compara = 'FinVigAnterior'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Final da Vigencia Anterior : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Seguradora-------------------------------
 let l_campo_compara = 'Seguradora'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Seguradora : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------SucursalItem-------------------------------
 let l_campo_compara = 'SucursalItem'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Sucursal do Item : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AplDoItem-------------------------------
 let l_campo_compara = 'AplDoItem'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Apolice Do Item : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp08_1'
 let l_tabela_2 = 'tmp08_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#=================================
function cty21g03_campos_ObsItem()
#=================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "============================ OBS DO ITEM ============================"

######## OBS DO ITEM ########
---------------------------ObsProposta-------------------------------
 let l_campo_compara = 'ObsProposta'
 let l_tabela_1 = 'tmp09_1'
 let l_tabela_2 = 'tmp09_2'
 let l_titulo   = ' > Obs da Proposta : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

{---------------------------Sequencia-------------------------------
 let l_campo_compara = 'Sequencia'
 let l_tabela_1 = 'tmp09_1'
 let l_tabela_2 = 'tmp09_2'
 let l_titulo   = ' > Sequencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp09_1'
 let l_tabela_2 = 'tmp09_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)
}
 call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_DadosDoVeiculo()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== DADOS DO VEICULO ========================="

######## DADOS DO VEICULO ########
---------------------------CodVeiculo-------------------------------
 let l_campo_compara = 'CodVeiculo'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Codigo do Veiculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AnoFabricacao-------------------------------
 let l_campo_compara = 'AnoFabricacao'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Ano de Fabricacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AnoModelo-------------------------------
 let l_campo_compara = 'AnoModelo'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Ano do Modelo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Placa-------------------------------
 let l_campo_compara = 'Placa'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Placa : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Chassi-------------------------------
 let l_campo_compara = 'Chassi'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Chassi : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Renavam-------------------------------
 let l_campo_compara = 'Renavam'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Renavam : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoUso-------------------------------
 let l_campo_compara = 'TipoUso'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Tipo do Uso : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Veiculo0km-------------------------------
 let l_campo_compara = 'Veiculo0km'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Veiculo 0 km ? : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoVistoria-------------------------------
 let l_campo_compara = 'TipoVistoria'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Tipo de Vistoria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VPCOBprovisoria-------------------------------
 let l_campo_compara = 'VPCOBprovisoria'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > V.P Cob. Provisoria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CapacidadePassageiros-------------------------------
 let l_campo_compara = 'CapacidadePassageiros'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Capacidade de Passageiros : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FlagAutoRevenda-------------------------------
 let l_campo_compara = 'FlagAutoRevenda'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Flag Auto Revenda : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FlagAutoNovo-------------------------------
 let l_campo_compara = 'FlagAutoNovo'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Flag Auto Novo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CategoriaTarifada-------------------------------
 let l_campo_compara = 'CategoriaTarifada'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Categoria Tarifada : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------combustivel-------------------------------
 let l_campo_compara = 'combustivel'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Combustivel : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdePortas-------------------------------
 let l_campo_compara = 'QtdePortas'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Quantidade de Portas : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataVistoria-------------------------------
 let l_campo_compara = 'DataVistoria'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Data da Vistoria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VeiculoBlindado-------------------------------
 let l_campo_compara = 'VeiculoBlindado'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Veiculo Blindado ?: '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FlagChassiRemarc-------------------------------
 let l_campo_compara = 'FlagChassiRemarc'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Flag Chassi Remarc : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CodigoTabelaFipe-------------------------------
 let l_campo_compara = 'CodigoTabelaFipe'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Codigo Tabela Fipe : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CodigoRenovacao-------------------------------
 let l_campo_compara = 'CodigoRenovacao'
 let l_tabela_1 = 'tmp10_1'
 let l_tabela_2 = 'tmp10_2'
 let l_titulo   = ' > Codigo de Renovacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function


#====================================
function cty21g03_campos_veiculo0km()
#====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "============================ VEICULO 0 KM ==========================="

######## VEICULO 0 KM ########

---------------------------NotaFiscal-------------------------------
 let l_campo_compara = 'NotaFiscal'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Nota Fiscal : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataEmissao-------------------------------
 let l_campo_compara = 'DataEmissao'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Data de Emissao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 ---------------------------DataSaidaVeiculo-------------------------------
 let l_campo_compara = 'DataSaidaVeiculo'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Data de Saida do Veiculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 ---------------------------CodConcessionaria-------------------------------
 let l_campo_compara = 'CodConcessionaria'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Codigo da Concessionaria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 ---------------------------NomeConcessionaria-------------------------------
 let l_campo_compara = 'NomeConcessionaria'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Nome da Concessionaria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 ---------------------------ValorNota-------------------------------
 let l_campo_compara = 'ValorNota'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Valor da Nota : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp11_1'
 let l_tabela_2 = 'tmp11_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#==================================
function cty21g03_campos_casco()
#==================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================================ CASCO =============================="

######## CASCO ########
---------------------------DataRealizacaoCalc-------------------------------
 let l_campo_compara = 'DataRealizacaoCalc'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Data da Realizacao do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Franquia-------------------------------
 let l_campo_compara = 'Franquia'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Franquia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Cobertura-------------------------------
 let l_campo_compara = 'Cobertura'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Cobertura : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FranquiaCasco-------------------------------
 let l_campo_compara = 'FranquiaCasco'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Franquia do Casco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISCalculo-------------------------------
 let l_campo_compara = 'ISCalculo'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > I.S. do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------IsencaoImpostos-------------------------------
 let l_campo_compara = 'IsencaoImpostos'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Isencao de Impostos : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 ---------------------------ISdaBlindagem-------------------------------
 let l_campo_compara = 'ISdaBlindagem'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > I.S. da Blindagem : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioLiqCasco-------------------------------
 let l_campo_compara = 'PremioLiqCasco'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Premio Liquido Casco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CotacaoMotorShow-------------------------------
 let l_campo_compara = 'CotacaoMotorShow'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Cotacao Motor Show : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PercentISCasco-------------------------------
 let l_campo_compara = 'PercentISCasco'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > % I.S. do Casco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PercentISBlindagem-------------------------------
 let l_campo_compara = 'PercentISBlindagem'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > % I.S. da Blindagem : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FatorDepreciacao-------------------------------
 let l_campo_compara = 'FatorDepreciacao'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Fator de Depreciacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorBasico-------------------------------
 let l_campo_compara = 'ValorBasico'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Valor Basico : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorMaximo-------------------------------
 let l_campo_compara = 'ValorMaximo'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Valor Maximo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TabelaUtilizada-------------------------------
 let l_campo_compara = 'TabelaUtilizada'
 let l_tabela_1 = 'tmp12_1'
 let l_tabela_2 = 'tmp12_2'
 let l_titulo   = ' > Tabela Utilizada : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#====================================
function cty21g03_campos_acessorios()
#====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "============================= ACESSORIOS ============================"


######## ACESSORIOS ########

---------------------------DataRealizCalc-------------------------------
 let l_campo_compara = 'DataRealizCalc'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > Data da Realizacao do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------RefAcessorio-------------------------------
 let l_campo_compara = 'RefAcessorio'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > Referencia do Acessorio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoAcessorio-------------------------------
 let l_campo_compara = 'TipoAcessorio'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > Tipo do Acessorio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorFranquia-------------------------------
 let l_campo_compara = 'ValorFranquia'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > Valor da Franquia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISFranquia-------------------------------
 let l_campo_compara = 'ISFranquia'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > I.S. da Franquia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------SeqAcessorio-------------------------------
 let l_campo_compara = 'SeqAcessorio'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > Sequencia do Acessorio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioLiqAcess-------------------------------
 let l_campo_compara = 'PremioLiqAcess'
 let l_tabela_1 = 'tmp13_1'
 let l_tabela_2 = 'tmp13_2'
 let l_titulo   = ' > Premio Liquido Acessorio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)


 call cty21g03_verifica_diff()



end function

#==================================
function cty21g03_campos_RCF()
#==================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================================== RCF =============================="


######## RCF ########

---------------------------DataRealizaCalc-------------------------------
 let l_campo_compara = 'DataRealizaCalc'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Data de Realizao do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ClasseFranquia-------------------------------
 let l_campo_compara = 'ClasseFranquia'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Classe da Franquia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorFranquiaDM-------------------------------
 let l_campo_compara = 'ValorFranquiaDM'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Valor da Franquia DM : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISDM-------------------------------
 let l_campo_compara = 'ISDM'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > I.S. DM : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorFranquiaDC-------------------------------
 let l_campo_compara = 'ValorFranquiaDC'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Valor da Franquia DC : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISDC-------------------------------
 let l_campo_compara = 'ISDC'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > I.S. DC : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioLiqRCFDM-------------------------------
 let l_campo_compara = 'PremioLiqRCFDM'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Premio Liquido RCF DM : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioLiqRCFDC-------------------------------
 let l_campo_compara = 'PremioLiqRCFDC'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Premio Liquido RCF DC : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp14_1'
 let l_tabela_2 = 'tmp14_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)


 call cty21g03_verifica_diff()


end function

#==================================
function cty21g03_campos_APP()
#==================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================================== APP =============================="


######## APP ########
---------------------------DataRealizaCalc-------------------------------
 let l_campo_compara = 'DataRealizaCalc'
 let l_tabela_1 = 'tmp15_1'
 let l_tabela_2 = 'tmp15_2'
 let l_titulo   = ' > Data de Realizao do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISInvalidez-------------------------------
 let l_campo_compara = 'ISInvalidez'
 let l_tabela_1 = 'tmp15_1'
 let l_tabela_2 = 'tmp15_2'
 let l_titulo   = ' > I.S. Invalidez : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISMorte-------------------------------
 let l_campo_compara = 'ISMorte'
 let l_tabela_1 = 'tmp15_1'
 let l_tabela_2 = 'tmp15_2'
 let l_titulo   = ' > I.S. Morte : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ISDMH-------------------------------
 let l_campo_compara = 'ISDMH'
 let l_tabela_1 = 'tmp15_1'
 let l_tabela_2 = 'tmp15_2'
 let l_titulo   = ' > I.S. DMH : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioLiqApp-------------------------------
 let l_campo_compara = 'PremioLiqApp'
 let l_tabela_1 = 'tmp15_1'
 let l_tabela_2 = 'tmp15_2'
 let l_titulo   = ' > Premio Liquido App : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp15_1'
 let l_tabela_2 = 'tmp15_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#=====================================
function cty21g03_campos_regclausula()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)
define l_CodClausula  char(100)

define l_1_CodClausula          char(100)
define l_1_CoeficienteClausula  char(20)
define l_1_CobrancaSN           char(1)
define l_1_IncVig               char(10)
define l_1_FinVig               char(10)

define l_2_CodClausula          char(100)
define l_2_CoeficienteClausula  char(20)
define l_2_CobrancaSN           char(1)
define l_2_IncVig               char(10)
define l_2_FinVig               char(10)

######## REGISTRO DE CLAUSULA ########
 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== REGISTRO DE CLAUSULA 17 ====================="


 call cty21g03_prepare_17_regclausula()

 open ccty21g03tmp17
 foreach ccty21g03tmp17  into  l_1_CodClausula
                            ,  l_1_CoeficienteClausula
                            ,  l_1_CobrancaSN
											      ,  l_1_IncVig
                            ,  l_1_FinVig
                            ,  l_2_CodClausula
                            ,  l_2_CoeficienteClausula
                            ,  l_2_CobrancaSN
											      ,  l_2_IncVig
                            ,  l_2_FinVig

--------------------------------------------------------------------
let l_1_CodClausula          =   l_1_CodClausula             clipped
let l_1_CoeficienteClausula  =   l_1_CoeficienteClausula     clipped
let l_1_CobrancaSN           =   l_1_CobrancaSN              clipped
let l_1_IncVig               =   l_1_IncVig                  clipped
let l_1_FinVig               =   l_1_FinVig                  clipped
let l_2_CodClausula          =   l_2_CodClausula             clipped
let l_2_CoeficienteClausula  =   l_2_CoeficienteClausula     clipped
let l_2_CobrancaSN           =   l_2_CobrancaSN              clipped
let l_2_IncVig               =   l_2_IncVig                  clipped
let l_2_FinVig               =   l_2_FinVig                  clipped
--------------------------------------------------------------------

    if l_1_CoeficienteClausula <>  l_2_CoeficienteClausula       or
       l_1_CobrancaSN          <>  l_2_CobrancaSN                or
       l_1_IncVig              <>  l_2_IncVig                    or
       l_1_FinVig              <>  l_2_FinVig                    or
       l_1_CodClausula               =   ' '                     or
       l_2_CodClausula               =   ' '                     or
       l_1_CodClausula               is null                     or
       l_2_CodClausula               is null                     then

       #carrega array
        if (l_1_CodClausula[1,3] is not null or
            l_1_CodClausula[1,3] <> ' '         ) and
           (l_2_CodClausula[1,3] is not null or
            l_2_CodClausula[1,3] <> ' '         ) then

            let ccty21g03_tela[m_index+2] = " ----------- ", l_1_CodClausula clipped," ----------- "
            let m_index = m_index + 2

            if l_1_CoeficienteClausula <>  l_2_CoeficienteClausula then
               let ccty21g03_tela[m_index+1] = " > Coeficiente da Clausula : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_CoeficienteClausula
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_CoeficienteClausula
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_CobrancaSN <> l_2_CobrancaSN then
               let ccty21g03_tela[m_index+1] = " > Cobranca S/N ? : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_CobrancaSN
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_CobrancaSN
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_IncVig <>  l_2_IncVig then
               let ccty21g03_tela[m_index+1] = " > Inicio da Vigencia : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_IncVig
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_IncVig
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_FinVig <>  l_2_FinVig then
               let ccty21g03_tela[m_index+1] = " > Final da Vigencia : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_FinVig
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_FinVig
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 4
            end if

        else
           let m_index = m_index + 1

           if l_1_CodClausula[1,3] is null or l_1_CodClausula[1,3] = ' ' then
              let ccty21g03_tela[m_index] = "         ----------------------------------- "
              let ccty21g03_tela[m_index+1] = " > Clausula INCLUIDA! na 2a Proposta : "
              let ccty21g03_tela[m_index+2] = "     Clausula........: ",l_2_CodClausula
              let ccty21g03_tela[m_index+3] = "     Coeficiente.....: ",l_2_CoeficienteClausula
              let ccty21g03_tela[m_index+4] = "     Cobranca S/N....: ",l_2_CobrancaSN
              let ccty21g03_tela[m_index+5] = "     Inicio Vigencia.: ",l_2_IncVig
              let ccty21g03_tela[m_index+6] = "     Final Vigencia..: ",l_2_FinVig

              let m_index = m_index + 7
           end if

           if l_2_CodClausula[1,3] is null or l_2_CodClausula[1,3] = ' ' then
              let ccty21g03_tela[m_index] = "         ----------------------------------- "
              let ccty21g03_tela[m_index+1] = " > Clausula EXCLUIDA! na 2a Proposta : "
              let ccty21g03_tela[m_index+2] = "     Clausula........: ",l_1_CodClausula
              let ccty21g03_tela[m_index+3] = "     Coeficiente.....: ",l_1_CoeficienteClausula
              let ccty21g03_tela[m_index+4] = "     Cobranca S/N....: ",l_1_CobrancaSN
              let ccty21g03_tela[m_index+5] = "     Inicio Vigencia.: ",l_1_IncVig
              let ccty21g03_tela[m_index+6] = "     Final Vigencia..: ",l_1_FinVig

              let m_index = m_index + 7
           end if

          let m_chave_diff = 1
        end if
    end if
 end foreach

 call cty21g03_verifica_diff()

end function


#===========================================
function cty21g03_campos_txtclausula()
#===========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== TEXTOS DA CLAUSULA ======================"

######## TEXTOS DA CLAUSULA ########
----------------------------CodClausula-------------------------------
 let l_campo_compara = 'CodClausula'
 let l_tabela_1 = 'tmp18_1'
 let l_tabela_2 = 'tmp18_2'
 let l_titulo   = ' > Codigo da Clausula : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------txtClausula-------------------------------
 let l_campo_compara = 'txtClausula'
 let l_tabela_1 = 'tmp18_1'
 let l_tabela_2 = 'tmp18_2'
 let l_titulo   = ' > Texto da Clausula : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------seqTexto-------------------------------
 let l_campo_compara = 'seqTexto'
 let l_tabela_1 = 'tmp18_1'
 let l_tabela_2 = 'tmp18_2'
 let l_titulo   = ' > Sequencia do Texto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp18_1'
 let l_tabela_2 = 'tmp18_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_QuestPerfil()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

define l_CodigoQuestao   char(80)
define l_CodigoResposta  char(80)
define l_SubResposta     char(80)

define l_1_CodigoQuestao   char(80)
define l_1_CodigoResposta  char(80)
define l_1_SubResposta     char(80)

define l_2_CodigoQuestao   char(80)
define l_2_CodigoResposta  char(80)
define l_2_SubResposta     char(80)


 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================= QUESTIONARIO PERFIL ======================"

######## QUESTIONARIO PERFIL ########

 call cty21g03_prepare_19_Questperfil()

 open ccty21g0319perf
 foreach ccty21g0319perf into  l_1_CodigoQuestao
                            ,  l_1_CodigoResposta
											      ,  l_1_SubResposta
											      ,  l_2_CodigoQuestao
                            ,  l_2_CodigoResposta
                            ,  l_2_SubResposta

    if  l_1_CodigoQuestao[1,3] = '124'  or l_2_CodigoQuestao[1,3] = '124'  or
        l_1_CodigoQuestao[1,3] = '127'  or l_2_CodigoQuestao[1,3] = '127'  or
        l_1_CodigoQuestao[1,3] = '151'  or l_2_CodigoQuestao[1,3] = '151'  or
        l_1_CodigoQuestao[1,3] = '167'  or l_2_CodigoQuestao[1,3] = '167'  then
        continue foreach
    end if

    if (l_1_CodigoResposta       <>  l_2_CodigoResposta     or
        l_1_SubResposta          <>  l_2_SubResposta        or
        l_1_CodigoQuestao        =   ' '              or
        l_2_CodigoQuestao        =   ' '              or
        l_1_CodigoQuestao        is null              or
        l_2_CodigoQuestao        is null              )   and
        l_1_CodigoQuestao[1,3]   <> '124'             and
        l_1_CodigoQuestao[1,3]   <> '127'             and
        l_1_CodigoQuestao[1,3]   <> '151'             and
        l_1_CodigoQuestao[1,3]   <> '167'             and
        l_2_CodigoQuestao[1,3]   <> '124'             and
        l_2_CodigoQuestao[1,3]   <> '127'             and
        l_2_CodigoQuestao[1,3]   <> '151'             and
        l_2_CodigoQuestao[1,3]   <> '167'             then

       #carrega array
        if (l_1_CodigoQuestao is not null or
            l_1_CodigoQuestao <> ' '         ) and
           (l_2_CodigoQuestao is not null or
            l_2_CodigoQuestao <> ' '         ) then

            let ccty21g03_tela[m_index+2] = " ----------- ", l_1_CodigoQuestao clipped," ----------- "
            let m_index = m_index + 2

            if l_1_CodigoResposta <>  l_2_CodigoResposta then
               let ccty21g03_tela[m_index+1] = " >  Resposta : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_CodigoResposta
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_CodigoResposta
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 4
            end if


             if l_1_SubResposta <> l_2_SubResposta then
               let ccty21g03_tela[m_index+1] = " > Sub - Resposta : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_SubResposta
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_SubResposta
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 4
            end if

        else
           let ccty21g03_tela[m_index+1] = "         ----------------------------------- "
           let m_index = m_index + 1

           if l_1_CodigoQuestao is null or l_1_CodigoQuestao = ' ' then
              let ccty21g03_tela[m_index+1] = " > Questao INCLUIDA! : "
              let ccty21g03_tela[m_index+2] = "     Questao......: ",l_2_CodigoQuestao
              let ccty21g03_tela[m_index+3] = "     Resposta.....: ",l_2_CodigoResposta
              let ccty21g03_tela[m_index+4] = "     Sub-Resposta.: ",l_2_SubResposta

              let m_index = m_index + 4
           end if

           if l_2_CodigoQuestao is null or l_2_CodigoQuestao = ' ' then
              let ccty21g03_tela[m_index+1] = " > Questao EXCLUIDA! : "
              let ccty21g03_tela[m_index+2] = "     Questao......: ",l_1_CodigoQuestao
              let ccty21g03_tela[m_index+3] = "     Resposta.....: ",l_1_CodigoResposta
              let ccty21g03_tela[m_index+4] = "     Sub-Resposta.: ",l_1_SubResposta

              let m_index = m_index + 4
           end if
        end if

        let m_chave_diff = 1
     end if

 end foreach


 call cty21g03_19_questionarioerfil1()

 open ccty21g0319_001
 foreach ccty21g0319_001 into l_CodigoQuestao

      let ccty21g03_tela[m_index+2] = " ----------- ",l_CodigoQuestao  clipped, " ----------- "

         call cty21g03_19_questionarioerfil2()

         open ccty21g0319_002 using l_CodigoQuestao
         let ccty21g03_tela[m_index+3] = " (1) DADOS DA PRIMEIRA PROPOSTA : "
         let ccty21g03_tela[m_index+4] = "  >  Respostas  : "
         let m_index = m_index + 4
         foreach ccty21g0319_002 into l_CodigoResposta,
                                      l_SubResposta

              let ccty21g03_tela[m_index+1] = "      ",l_CodigoResposta

              let m_index = m_index + 1

              if l_SubResposta <> ' ' and l_SubResposta is not null and l_SubResposta[1,3] <> '000' then
                 let ccty21g03_tela[m_index+1] = "  >  Sub-Resposta  : "
                 let ccty21g03_tela[m_index+2] = "      ",l_SubResposta  clipped
                 let m_index = m_index + 2
              end if

         end foreach

         call cty21g03_19_questionarioerfil3()

         open ccty21g0319_003 using l_CodigoQuestao
         let ccty21g03_tela[m_index+2] = " (2) DADOS DA SEGUNDA PROPOSTA : "
         let ccty21g03_tela[m_index+3] = "  >  Respostas  : "
         let m_index = m_index + 3
         foreach ccty21g0319_003 into l_CodigoResposta,
                                      l_SubResposta

              let ccty21g03_tela[m_index+1] = "      ",l_CodigoResposta

              let m_index = m_index + 1

              if l_SubResposta <> ' ' and l_SubResposta is not null and l_SubResposta[1,3] <> '000' then
                 let ccty21g03_tela[m_index+1] = "  >  Sub-Resposta  : "
                 let ccty21g03_tela[m_index+2] = "      ",l_SubResposta clipped
                 let m_index = m_index + 2
              end if

          end foreach

        let m_index = m_index + 1

       let m_chave_diff = 1
   end foreach

 let m_index = m_index + 2

 call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_PoeRespTextos()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

define l_1_CodigoQuestao      char(80)
define l_1_CodigoResposta     char(80)
define l_1_TextoResposta      char(80)
define l_2_CodigoQuestao      char(80)
define l_2_CodigoResposta     char(80)
define l_2_TextoResposta      char(80)


 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== POE - RESPOSTAS E TEXTOS ===================="

######## POE - RESPOSTAS E TEXTOS ########
----------------------------PoeConcorrencia-------------------------------
 let l_campo_compara = 'PoeConcorrencia'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > POE Concorrencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------TipoProduto-------------------------------
 let l_campo_compara = 'TipoProduto'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Tipo do Produto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 call cty21g03_prepare_20_RespostasTextos()
 open ccty21g03tmp20
 foreach ccty21g03tmp20 into  l_1_CodigoQuestao
                          ,l_1_CodigoResposta
                          ,l_1_TextoResposta
                          ,l_2_CodigoQuestao
                          ,l_2_CodigoResposta
                          ,l_2_TextoResposta

     if l_1_CodigoResposta <>  l_2_CodigoResposta or
        l_1_TextoResposta <>  l_2_TextoResposta or
       l_1_CodigoQuestao        =   ' '              or
       l_2_CodigoQuestao        =   ' '              or
       l_1_CodigoQuestao        is null              or
       l_2_CodigoQuestao        is null              then
       #carrega array

       let ccty21g03_tela[m_index+1] = "  (1) DADOS DA PRIMEIRA PROPOSTA :  "
       let ccty21g03_tela[m_index+2] = "    > Codigo Questao..: ",l_1_CodigoQuestao
       let ccty21g03_tela[m_index+3] = "    > Codigo Resposta.: ",l_1_CodigoResposta
       let ccty21g03_tela[m_index+4] = "    > Texto Resposta..: ",l_1_TextoResposta
       let ccty21g03_tela[m_index+6] = "  (2) DADOS DA SEGUNDA PROPOSTA :  "
       let ccty21g03_tela[m_index+7] = "    > Codigo Questao..: ",l_2_CodigoQuestao
       let ccty21g03_tela[m_index+8] = "    > Codigo Resposta.: ",l_2_CodigoResposta
       let ccty21g03_tela[m_index+9] = "    > Texto Resposta..: ",l_2_TextoResposta
       let ccty21g03_tela[m_index+11] = "                           ***                                "
       let ccty21g03_tela[m_index+12]= "                                                              "
       let m_index = m_index + 12

       let m_chave_diff = 1
   end if
 end foreach



{
----------------------------CodigoQuestao-------------------------------
 let l_campo_compara = 'CodigoQuestao'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Codigo da Questao 1 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CodigoResposta-------------------------------
 let l_campo_compara = 'CodigoResposta'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Codigo da Resposta 1 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------TextoResposta-------------------------------
 let l_campo_compara = 'TextoResposta'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Texto da Resposta 1 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CodigoQuestao2-------------------------------
 let l_campo_compara = 'CodigoQuestao2'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Codigo da Questao 2 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CodigoResposta2-------------------------------
 let l_campo_compara = 'CodigoResposta2'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Codigo da Resposta 2 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------TextoResposta2-------------------------------
 let l_campo_compara = 'TextoResposta2'
 let l_tabela_1 = 'tmp20_1'
 let l_tabela_2 = 'tmp20_2'
 let l_titulo   = ' > Texto da Resposta 2 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)
}
 call cty21g03_verifica_diff()

end function



#=====================================
function cty21g03_campos_condutor()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================= CONDUTOR DO VEICULO ======================"

######## CONDUTOR DO VEICULO ########
----------------------------Nome-------------------------------
 let l_campo_compara = 'Nome'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > Nome : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CPF-------------------------------
 let l_campo_compara = 'CPF'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > CPF : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------SEQUENCIA DO CONDUTOR-------------------------------
 let l_campo_compara = 'seqcdt'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > SEQUENCIA DO CONDUTOR : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------RG-------------------------------
 let l_campo_compara = 'Rg'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > RG : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CNH-------------------------------
 let l_campo_compara = 'CNH'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > CNH : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CATEGORIA DA CNH-------------------------------
 let l_campo_compara = 'CATCNH'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > Categoria de CNH : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp21_1'
 let l_tabela_2 = 'tmp21_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_desc_agravos()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)
define l_aux            smallint
define l_CodDesconto    char(100)
define l_parametro      char(100)

define l_1_CodDesconto           char(100)
define l_1_CoeficienteSemPremio  char(8)
define l_2_CodDesconto           char(100)
define l_2_CoeficienteSemPremio  char(8)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================== REGISTRO DE DESCONTOS E AGRAVO 22 ==============="

######## REGISTRO DE DESCONTOS E AGRAVO ########


 call cty21g03_prepare_22_DescAgravos()
 open ccty21g03tmp22
 foreach ccty21g03tmp22 into  l_1_CodDesconto
                          ,l_1_CoeficienteSemPremio
                          ,l_2_CodDesconto
                          ,l_2_CoeficienteSemPremio

     if l_1_CoeficienteSemPremio <>  l_2_CoeficienteSemPremio or
       l_1_CodDesconto        =   ' '              or
       l_2_CodDesconto        =   ' '              or
       l_1_CodDesconto        is null              or
       l_2_CodDesconto        is null              then
       #carrega array

       let ccty21g03_tela[m_index+1] = "  (1) DADOS DA PRIMEIRA PROPOSTA :  "
       let ccty21g03_tela[m_index+2] = "    > Codigo Desconto........: ",l_1_CodDesconto
       let ccty21g03_tela[m_index+3] = "    > Coeficiente Sem Premio.: ",l_1_CoeficienteSemPremio
       let ccty21g03_tela[m_index+5] = "  (2) DADOS DA SEGUNDA PROPOSTA :  "
       let ccty21g03_tela[m_index+6] = "    > Codigo Desconto........: ",l_2_CodDesconto
       let ccty21g03_tela[m_index+7] = "    > Coeficiente Sem Premio.: ",l_2_CoeficienteSemPremio
       let ccty21g03_tela[m_index+8] = "                           ***                                "
       let ccty21g03_tela[m_index+9] = "                                                              "
       let m_index = m_index + 9

       let m_chave_diff = 1
   end if
 end foreach

 {
----------------------------CodDesconto-------------------------------
 let l_campo_compara = 'CodDesconto'
 let l_tabela_1 = 'tmp22_1'
 let l_tabela_2 = 'tmp22_2'
 let l_parametro = 'CodDesconto'
 let l_titulo   = ' > Codigo de Desconto : '
 call cty21g03_para_cada_desconto_item(l_campo_compara
                                       ,l_tabela_1
                                       ,l_tabela_2
                                       ,l_titulo
                                       ,l_parametro)

----------------------------CoeficienteSemPremio-------------------------------
 let l_campo_compara = 'CoeficienteSemPremio'
 let l_tabela_1 = 'tmp22_1'
 let l_tabela_2 = 'tmp22_2'
 let l_parametro = 'CodDesconto'
 let l_titulo   = ' > Coeficiente Sem Premio : '
 call cty21g03_para_cada_desconto_item(l_campo_compara
                                       ,l_tabela_1
                                       ,l_tabela_2
                                       ,l_titulo
                                       ,l_parametro)
}
   call cty21g03_verifica_diff()


end function

#=====================================
function cty21g03_campos_nego_aceitacao()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== NEGOCIACAO DE ACEITACAO ====================="


######## NEGOCIACAO DE ACEITACAO ########
----------------------------Numero da Aceitacao-------------------------------
 let l_campo_compara = 'numacei'
 let l_tabela_1 = 'tmp24_1'
 let l_tabela_2 = 'tmp24_2'
 let l_titulo   = ' > Numero da Aceitacao : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_id_cartao()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== ID DO CARTAO PORTO VISA ====================="

######## ID DO CARTAO PORTO VISA ########
----------------------------ID DO CARTAO PORTO VISA-------------------------------
 let l_campo_compara = 'idcartao'
 let l_tabela_1 = 'tmp27_1'
 let l_tabela_2 = 'tmp27_2'
 let l_titulo   = ' > ID do Cartao Porto : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_finalidade()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======================= FINALIDADE DE EMISSAO ======================"

######## FINALIDADE DE EMISSAO ########
----------------------------Finalidade-------------------------------
 let l_campo_compara = 'Finalidade'
 let l_tabela_1 = 'tmp29_1'
 let l_tabela_2 = 'tmp29_2'
 let l_titulo   = ' > Finalid. de Emissao : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Encargos Financeiros-------------------------------
 let l_campo_compara = 'Encargos'
 let l_tabela_1 = 'tmp29_1'
 let l_tabela_2 = 'tmp29_2'
 let l_titulo   = ' > Encargos Financeiros : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Total Bruto-------------------------------
 let l_campo_compara = 'totalbruto'
 let l_tabela_1 = 'tmp29_1'
 let l_tabela_2 = 'tmp29_2'
 let l_titulo   = ' > Total Bruto : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp29_1'
 let l_tabela_2 = 'tmp29_2'
 let l_titulo   = ' > Espaco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_cartao()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================= INFORMACOES CARTAO ======================="

######## FINALIDADE DE EMISSAO ########
----------------------------Debito em Conta-------------------------------
 let l_campo_compara = 'Debito'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Debito em Conta : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Banco-------------------------------
 let l_campo_compara = 'Banco'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Banco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Agencia-------------------------------
 let l_campo_compara = 'Agencia'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Agencia : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Conta Corrente-------------------------------
 let l_campo_compara = 'Conta'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Conta Corrente : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Digito Conta Corrente-------------------------------
 let l_campo_compara = 'Contadig'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Digito Conta Corrente : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Seguro Perda e Roubo-------------------------------
 let l_campo_compara = 'seguroroubo'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Seguro Perda e Roubo : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CPF-------------------------------
 let l_campo_compara = 'CPF'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > CPF : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Nome-------------------------------
 let l_campo_compara = 'Nome'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Nome : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Data Nascimento-------------------------------
 let l_campo_compara = 'Data'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Data Nascimento : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Parentesco-------------------------------
 let l_campo_compara = 'Parentesco'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Parentesco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Sexo-------------------------------
 let l_campo_compara = 'Sexo'
 let l_tabela_1 = 'tmp30_1'
 let l_tabela_2 = 'tmp30_2'
 let l_titulo   = ' > Sexo : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)


call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_custo_apolice()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== CUSTO DE APOLICE ========================"

########CUSTO DE APOLICE ########
----------------------------Custo de Apl Anual-------------------------------
 let l_campo_compara = 'custoaplanual'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Custo de Apl Anual : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Coeficiente de IOF-------------------------------
 let l_campo_compara = 'coefIOF'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Coeficiente de IOF : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Premio Avista-------------------------------
 let l_campo_compara = 'premiovista'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Premio Avista : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Taxa S/ Casco-------------------------------
 let l_campo_compara = 'taxacasco'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Taxa S/ Casco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Tipo de Seguro-------------------------------
 let l_campo_compara = 'tiposeg'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Tipo de Seguro : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Valor da Parcela 1-------------------------------
 let l_campo_compara = 'vlrparc1'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Valor da Parcela 1 : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Valor das Demais-------------------------------
 let l_campo_compara = 'vlrdemais'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Valor das Demais : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Valor dos Juros-------------------------------
 let l_campo_compara = 'vlrjuros'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Valor dos Juros : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'espaco'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Espaco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#=====================================
function cty21g03_campos_compl_dados()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======================== COMPLEMENTO DE DADOS ======================"


######## COMPLEMENTO DE DADOS ########
----------------------------R.G do Segurado-------------------------------
 let l_campo_compara = 'RG'
 let l_tabela_1 = 'tmp32_1'
 let l_tabela_2 = 'tmp32_2'
 let l_titulo   = ' > R.G do Segurado : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------CNH-------------------------------
 let l_campo_compara = 'Cnh'
 let l_tabela_1 = 'tmp32_1'
 let l_tabela_2 = 'tmp32_2'
 let l_titulo   = ' > CHN. do Segurado : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Categoria da CNH-------------------------------
 let l_campo_compara = 'catcnh'
 let l_tabela_1 = 'tmp32_1'
 let l_tabela_2 = 'tmp32_2'
 let l_titulo   = ' > Categoria da CNH : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------E-mail do Segurado-------------------------------
 let l_campo_compara = 'email'
 let l_tabela_1 = 'tmp32_1'
 let l_tabela_2 = 'tmp32_2'
 let l_titulo   = ' > E-mail do Segurado : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Tp de Envio Front-------------------------------
 let l_campo_compara = 'tpenviofront'
 let l_tabela_1 = 'tmp32_1'
 let l_tabela_2 = 'tmp32_2'
 let l_titulo   = ' > Tp de Envio Front : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'espaco'
 let l_tabela_1 = 'tmp31_1'
 let l_tabela_2 = 'tmp31_2'
 let l_titulo   = ' > Espaco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function
#=====================================
function cty21g03_campos_agencia_angariacao()
#=====================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======================== AGENCIA DE ANGARIACAO ======================"



######## AGENCIA DE ANGARIACAO ########
----------------------------Codigo do Banco-------------------------------
 let l_campo_compara = 'codbanco'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' >Codigo do Banco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Codigo da Agencia-------------------------------
 let l_campo_compara = 'agencia'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' > Codigo da Agencia : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Codigo do Produtor-------------------------------
 let l_campo_compara = 'produtor'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' > Codigo do Produtor : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Cod. Ponto de Venda-------------------------------
 let l_campo_compara = 'pontovenda'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' > Cod. Ponto de Venda : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Cod. Posto de Sevico-------------------------------
 let l_campo_compara = 'postoserv'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' > Cod. Posto de Sevico : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Cod Segmento do Cliente-------------------------------
 let l_campo_compara = 'segcliente'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' > Cod Segmento do Cliente '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

----------------------------Espaco-------------------------------
 let l_campo_compara = 'espaco'
 let l_tabela_1 = 'tmp35_1'
 let l_tabela_2 = 'tmp35_2'
 let l_titulo   = ' > Espaco : '

 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function



#========================================
function cty21g03_campos_Vida()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "============================== VIDA ==============================="

######## VIDA ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp36_1'
 let l_tabela_2 = 'tmp36_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------IsMorte-------------------------------
 let l_campo_compara = 'IsMorte'
 let l_tabela_1 = 'tmp36_1'
 let l_tabela_2 = 'tmp36_2'
 let l_titulo   = ' > IS Morte : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------IsInvalidez-------------------------------
 let l_campo_compara = 'IsInvalidez'
 let l_tabela_1 = 'tmp36_1'
 let l_tabela_2 = 'tmp36_2'
 let l_titulo   = ' > IS Invalidez : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioLiqVidaInd-------------------------------
 let l_campo_compara = 'PremioLiqVidaInd'
 let l_tabela_1 = 'tmp36_1'
 let l_tabela_2 = 'tmp36_2'
 let l_titulo   = ' > Premio Liquido Vida Ind : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp36_1'
 let l_tabela_2 = 'tmp36_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_BenefVidaIndiv()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=========== BENEFICIARIOS DO SEGURO DE VIDA INDIVIDUAL ============"

######## BENEFICIARIOS DO SEGURO DE VIDA INDIVIDUAL ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp37_1'
 let l_tabela_2 = 'tmp37_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NomeBeneficiario-------------------------------
 let l_campo_compara = 'NomeBeneficiario'
 let l_tabela_1 = 'tmp37_1'
 let l_tabela_2 = 'tmp37_2'
 let l_titulo   = ' > Nome do Beneficiario : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------GrauParentesco-------------------------------
 let l_campo_compara = 'GrauParentesco'
 let l_tabela_1 = 'tmp37_1'
 let l_tabela_2 = 'tmp37_2'
 let l_titulo   = ' > Grau de Parentesco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp37_1'
 let l_tabela_2 = 'tmp37_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ParticipBeneficiario-------------------------------
 let l_campo_compara = 'ParticipBeneficiario'
 let l_tabela_1 = 'tmp37_1'
 let l_tabela_2 = 'tmp37_2'
 let l_titulo   = ' > Participacao Beneficiario (%) : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco2-------------------------------
 let l_campo_compara = 'Espaco2'
 let l_tabela_1 = 'tmp37_1'
 let l_tabela_2 = 'tmp37_2'
 let l_titulo   = ' > Espaco2 : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_Atendimentos()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== ATENDIMENTOS ==========================="

######## ATENDIMENTOS ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp38_1'
 let l_tabela_2 = 'tmp38_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataAtendimento-------------------------------
 let l_campo_compara = 'DataAtendimento'
 let l_tabela_1 = 'tmp38_1'
 let l_tabela_2 = 'tmp38_2'
 let l_titulo   = ' > Data do Atendimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------HoraAtendimento-------------------------------
 let l_campo_compara = 'HoraAtendimento'
 let l_tabela_1 = 'tmp38_1'
 let l_tabela_2 = 'tmp38_2'
 let l_titulo   = ' > Hora do Atendimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------LocalAtendimento-------------------------------
 let l_campo_compara = 'LocalAtendimento'
 let l_tabela_1 = 'tmp38_1'
 let l_tabela_2 = 'tmp38_2'
 let l_titulo   = ' > Local do Atendimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoServico-------------------------------
 let l_campo_compara = 'TipoServico'
 let l_tabela_1 = 'tmp38_1'
 let l_tabela_2 = 'tmp38_2'
 let l_titulo   = ' > Tipo de Servico : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp38_1'
 let l_tabela_2 = 'tmp38_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_ServicosObserv()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "===================== SERVICOS E OBSERVACOES ======================"

######## SERVICOS E OBSERVACOES ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp39_1'
 let l_tabela_2 = 'tmp39_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoInformacao-------------------------------
 let l_campo_compara = 'TipoInformacao'
 let l_tabela_1 = 'tmp39_1'
 let l_tabela_2 = 'tmp39_2'
 let l_titulo   = ' > Tipo da Informacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CodigoInformacao-------------------------------
 let l_campo_compara = 'CodigoInformacao'
 let l_tabela_1 = 'tmp39_1'
 let l_tabela_2 = 'tmp39_2'
 let l_titulo   = ' > Codigo da Informacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdeServico-------------------------------
 let l_campo_compara = 'QtdeServico'
 let l_tabela_1 = 'tmp39_1'
 let l_tabela_2 = 'tmp39_2'
 let l_titulo   = ' > Qtde Servico : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TextoComplementar-------------------------------
 let l_campo_compara = 'TextoComplementar'
 let l_tabela_1 = 'tmp39_1'
 let l_tabela_2 = 'tmp39_2'
 let l_titulo   = ' > Texto Complementar : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_BlocosCondom()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "===================== BLOCOS DE UM CONDOMINIO ====================="

######## BLOCOS DE UM CONDOMINIO ########

---------------------------SequenciaLocal-------------------------------
 let l_campo_compara = 'SequenciaLocal'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Sequencia do Local : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroSeqRisco-------------------------------
 let l_campo_compara = 'NumeroSeqRisco'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Numero da Sequencia do Risco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NomeBloco-------------------------------
 let l_campo_compara = 'NomeBloco'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Nome do Bloco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdePavimentos-------------------------------
 let l_campo_compara = 'QtdePavimentos'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Qtde de Pavimentos : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdeVagas-------------------------------
 let l_campo_compara = 'QtdeVagas'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Qtde de Vagas : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoConstrucao-------------------------------
 let l_campo_compara = 'TipoConstrucao'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Tipo de Construcao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdeAptosCondominio-------------------------------
 let l_campo_compara = 'QtdeAptosCondominio'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Qtde de Aptos no Condominio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorRiscoDeclarado-------------------------------
 let l_campo_compara = 'ValorRiscoDeclarado'
 let l_tabela_1 = 'tmp40_1'
 let l_tabela_2 = 'tmp40_2'
 let l_titulo   = ' > Valor em Risco Declarado : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_Parcelamento()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== PARCELAMENTO ==========================="

######## PARCELAMENTO ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------MeioPagamento-------------------------------
 let l_campo_compara = 'MeioPagamento'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Meio de Pagamento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroParcela-------------------------------
 let l_campo_compara = 'NumeroParcela'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Numero da Parcela : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CartaoCredito-------------------------------
 let l_campo_compara = 'CartaoCredito'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Cartao de Credito : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VenctoCartao-------------------------------
 let l_campo_compara = 'VenctoCartao'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Vencimento do Cartao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroBanco-------------------------------
 let l_campo_compara = 'NumeroBanco'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Numero do Banco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroAgencia-------------------------------
 let l_campo_compara = 'NumeroAgencia'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Numero da Agencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ContaCorrente-------------------------------
 let l_campo_compara = 'ContaCorrente'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Conta Corrente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DigitoCC-------------------------------
 let l_campo_compara = 'DigitoCC'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Digito C/C : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataVencto-------------------------------
 let l_campo_compara = 'DataVencto'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Data de Vencimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorParcela-------------------------------
 let l_campo_compara = 'ValorParcela'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Valor da Parcela : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ChequeNum-------------------------------
 let l_campo_compara = 'ChequeNum'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Numero do Cheque : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PracaCheque-------------------------------
 let l_campo_compara = 'PracaCheque'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > Praca do Cheque : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CnpjCpfCC-------------------------------
 let l_campo_compara = 'CnpjCpfCC'
 let l_tabela_1 = 'tmp41_1'
 let l_tabela_2 = 'tmp41_2'
 let l_titulo   = ' > CNPJ/CPF da C/C : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_AutoMaisVida()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=========================== AUTO + VIDA ==========================="

######## AUTO + VIDA ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp42_1'
 let l_tabela_2 = 'tmp42_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Fumante-------------------------------
 let l_campo_compara = 'Fumante'
 let l_tabela_1 = 'tmp42_1'
 let l_tabela_2 = 'tmp42_2'
 let l_titulo   = ' > Fumante : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CodigoOperacao-------------------------------
 let l_campo_compara = 'CodigoOperacao'
 let l_tabela_1 = 'tmp42_1'
 let l_tabela_2 = 'tmp42_2'
 let l_titulo   = ' > Codigo Operacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AtualMonetaria-------------------------------
 let l_campo_compara = 'AtualMonetaria'
 let l_tabela_1 = 'tmp42_1'
 let l_tabela_2 = 'tmp42_2'
 let l_titulo   = ' > Atualizacao Monetaria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NomeInformar-------------------------------
 let l_campo_compara = 'NomeInformar'
 let l_tabela_1 = 'tmp42_1'
 let l_tabela_2 = 'tmp42_2'
 let l_titulo   = ' > Nome a Informar : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Telefone-------------------------------
 let l_campo_compara = 'Telefone'
 let l_tabela_1 = 'tmp42_1'
 let l_tabela_2 = 'tmp42_2'
 let l_titulo   = ' > Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_VidaComplement()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======================== VIDA (COMPLEMENTO) ======================="

######## VIDA (COMPLEMENTO) ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Empresa-------------------------------
 let l_campo_compara = 'Empresa'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Empresa : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TempoAnosMeses-------------------------------
 let l_campo_compara = 'TempoAnosMeses'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Tempo (Anos/Meses) : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Produto-------------------------------
 let l_campo_compara = 'Produto'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Produto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Renda-------------------------------
 let l_campo_compara = 'Renda'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Renda : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Premio-------------------------------
 let l_campo_compara = 'Premio'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Premio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdeParcelasAutoVida-------------------------------
 let l_campo_compara = 'QtdeParcelasAutoVida'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Qtde de Parcelas AUTO + VIDA : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FormaPagtoRenovacao-------------------------------
 let l_campo_compara = 'FormaPagtoRenovacao'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Forma de Pagamento Renovacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdeParcelasRenovacao-------------------------------
 let l_campo_compara = 'QtdeParcelasRenovacao'
 let l_tabela_1 = 'tmp43_1'
 let l_tabela_2 = 'tmp43_2'
 let l_titulo   = ' > Qtde de Parcelas Renovacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_AutoVidaCobert()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "===================== AUTO + VIDA (COBERTURAS) ===================="

######## AUTO + VIDA (COBERTURAS) ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp44_1'
 let l_tabela_2 = 'tmp44_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AssistFuneral-------------------------------
 let l_campo_compara = 'AssistFuneral'
 let l_tabela_1 = 'tmp44_1'
 let l_tabela_2 = 'tmp44_2'
 let l_titulo   = ' > Assistencia Funeral : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Cobertura-------------------------------
 let l_campo_compara = 'Cobertura'
 let l_tabela_1 = 'tmp44a_1'
 let l_tabela_2 = 'tmp44a_2'
 let l_titulo   = ' > Cobertura : '
 call cty21g03_para_cada_desconto_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo
                             ,'Cobertura')


   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_NegocConcessao()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "===================== NEGOCIACAO DE CONCESSAO ====================="

######## NEGOCIACAO DE CONCESSAO ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp45_1'
 let l_tabela_2 = 'tmp45_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroNegociacao-------------------------------
 let l_campo_compara = 'NumeroNegociacao'
 let l_tabela_1 = 'tmp45_1'
 let l_tabela_2 = 'tmp45_2'
 let l_titulo   = ' > Numero da Negociacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_EnderecoCartao()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======================= ENDERECO DO CARTAO ========================"

######## ENDERECO DO CARTAO ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoEndereco-------------------------------
 let l_campo_compara = 'TipoEndereco'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Tipo de Endereco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoLogradouro-------------------------------
 let l_campo_compara = 'TipoLogradouro'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Tipo do Logradouro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Logradouro-------------------------------
 let l_campo_compara = 'Logradouro'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Logradouro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Numero-------------------------------
 let l_campo_compara = 'Numero'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Numero : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Complemento-------------------------------
 let l_campo_compara = 'Complemento'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Complemento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CEP-------------------------------
 let l_campo_compara = 'CEP'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > CEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp46_1'
 let l_tabela_2 = 'tmp46_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_ClsParticDeclar()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=================== CLS. PARTICULAR/DECLARACOES ==================="

######## CLS. PARTICULAR/DECLARACOES ########

---------------------------TipoTexto-------------------------------
 let l_campo_compara = 'TipoTexto'
 let l_tabela_1 = 'tmp47_1'
 let l_tabela_2 = 'tmp47_2'
 let l_titulo   = ' > Tipo do Texto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------SequenciaTexto-------------------------------
 let l_campo_compara = 'SequenciaTexto'
 let l_tabela_1 = 'tmp47_1'
 let l_tabela_2 = 'tmp47_2'
 let l_titulo   = ' > Sequencia do Texto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DescricaoTexto-------------------------------
 let l_campo_compara = 'DescricaoTexto'
 let l_tabela_1 = 'tmp47_1'
 let l_tabela_2 = 'tmp47_2'
 let l_titulo   = ' > Descricao do Texto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_ComplEndCartao()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================= COMPLEMENTO DO ENDERECO - CARTAO ================"

######## COMPLEMENTO DO ENDERECO - CARTAO ########

---------------------------FlagEndereco-------------------------------
 let l_campo_compara = 'FlagEndereco'
 let l_tabela_1 = 'tmp48_1'
 let l_tabela_2 = 'tmp48_2'
 let l_titulo   = ' > Flag do Endereco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Bairro-------------------------------
 let l_campo_compara = 'Bairro'
 let l_tabela_1 = 'tmp48_1'
 let l_tabela_2 = 'tmp48_2'
 let l_titulo   = ' > Bairro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Cidade-------------------------------
 let l_campo_compara = 'Cidade'
 let l_tabela_1 = 'tmp48_1'
 let l_tabela_2 = 'tmp48_2'
 let l_titulo   = ' > Cidade : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------UF-------------------------------
 let l_campo_compara = 'UF'
 let l_tabela_1 = 'tmp48_1'
 let l_tabela_2 = 'tmp48_2'
 let l_titulo   = ' > UF : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Email-------------------------------
 let l_campo_compara = 'Email'
 let l_tabela_1 = 'tmp48_1'
 let l_tabela_2 = 'tmp48_2'
 let l_titulo   = ' > Email : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp48_1'
 let l_tabela_2 = 'tmp48_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_TelsSegurCartao()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================== TELEFONES DO SEGURADO - CARTAO ================="

######## TELEFONES DO SEGURADO - CARTAO ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoTelefone-------------------------------
 let l_campo_compara = 'TipoTelefone'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > Tipo do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DddTelefone-------------------------------
 let l_campo_compara = 'DddTelefone'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > DDD do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroTelefone-------------------------------
 let l_campo_compara = 'NumeroTelefone'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > Numero do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------RamalTelefone-------------------------------
 let l_campo_compara = 'RamalTelefone'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > Ramal do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Recados-------------------------------
 let l_campo_compara = 'Recados'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > Recados : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp49_1'
 let l_tabela_2 = 'tmp49_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_PremiosPagos()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================== PREMIOS PAGOS =========================="

######## PREMIOS PAGOS ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Veiculo-------------------------------
 let l_campo_compara = 'Veiculo'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Veiculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AnoFabricacao-------------------------------
 let l_campo_compara = 'AnoFabricacao'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Ano Fabricacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AnoModelo-------------------------------
 let l_campo_compara = 'AnoModelo'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Ano Modelo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Flag0Km-------------------------------
 let l_campo_compara = 'Flag0Km'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Flag 0Km : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Uso-------------------------------
 let l_campo_compara = 'Uso'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Uso : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Categoria-------------------------------
 let l_campo_compara = 'Categoria'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Categoria : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------QtdePassageiros-------------------------------
 let l_campo_compara = 'QtdePassageiros'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Qtde de Passageiros : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioCasco-------------------------------
 let l_campo_compara = 'PremioCasco'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Premio Casco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioAcessorio-------------------------------
 let l_campo_compara = 'PremioAcessorio'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Premio Acessorio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioDM-------------------------------
 let l_campo_compara = 'PremioDM'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Premio DM : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioDP-------------------------------
 let l_campo_compara = 'PremioDP'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Premio DP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioDMO-------------------------------
 let l_campo_compara = 'PremioDMO'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Premio DMO : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioAPP-------------------------------
 let l_campo_compara = 'PremioAPP'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Premio APP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AlteracaoCasco-------------------------------
 let l_campo_compara = 'AlteracaoCasco'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Alteracao Casco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AlteracaoAcessorios-------------------------------
 let l_campo_compara = 'AlteracaoAcessorios'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Alteracao Acessorios : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AlteracaoDM-------------------------------
 let l_campo_compara = 'AlteracaoDM'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Alteracao DM : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AlteracaoDP-------------------------------
 let l_campo_compara = 'AlteracaoDP'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Alteracao DP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AlteracaoDMO-------------------------------
 let l_campo_compara = 'AlteracaoDMO'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Alteracao DMO : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AlteracaoAPP-------------------------------
 let l_campo_compara = 'AlteracaoAPP'
 let l_tabela_1 = 'tmp50_1'
 let l_tabela_2 = 'tmp50_2'
 let l_titulo   = ' > Alteracao APP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_TelsSegurado()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== TELEFONES DO SEGURADO ======================"

######## TELEFONES DO SEGURADO ########

---------------------------CodigoRegistro-------------------------------
 let l_campo_compara = 'CodigoRegistro'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoTelefone-------------------------------
 let l_campo_compara = 'TipoTelefone'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > Tipo do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DddTelefone-------------------------------
 let l_campo_compara = 'DddTelefone'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > DDD do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroTelefone-------------------------------
 let l_campo_compara = 'NumeroTelefone'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > Numero do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------RamalTelefone-------------------------------
 let l_campo_compara = 'RamalTelefone'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > Ramal do Telefone : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Recados-------------------------------
 let l_campo_compara = 'Recados'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > Recados : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Espaco-------------------------------
 let l_campo_compara = 'Espaco'
 let l_tabela_1 = 'tmp52_1'
 let l_tabela_2 = 'tmp52_2'
 let l_titulo   = ' > Espaco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_ComplVeiculo()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "===================== COMPLEMENTO DO VEICULO ======================"

######## COMPLEMENTO DO VEICULO ########

---------------------------IdentifConfirmBonus-------------------------------
 let l_campo_compara = 'IdentifConfirmBonus'
 let l_tabela_1 = 'tmp53_1'
 let l_tabela_2 = 'tmp53_2'
 let l_titulo   = ' > Identificacao da Confirmacao de Bonus : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumAgendamentoDAF-------------------------------
 let l_campo_compara = 'NumAgendamentoDAF'
 let l_tabela_1 = 'tmp53_1'
 let l_tabela_2 = 'tmp53_2'
 let l_titulo   = ' > Numero do Agendamento DAF : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------KitGas-------------------------------
 let l_campo_compara = 'KitGas'
 let l_tabela_1 = 'tmp53_1'
 let l_tabela_2 = 'tmp53_2'
 let l_titulo   = ' > Kit Gas : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CambioAutomatico-------------------------------
 let l_campo_compara = 'CambioAutomatico'
 let l_tabela_1 = 'tmp53_1'
 let l_tabela_2 = 'tmp53_2'
 let l_titulo   = ' > Cambio Automatico : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VeicFinanciado-------------------------------
 let l_campo_compara = 'VeicFinanciado'
 let l_tabela_1 = 'tmp53_1'
 let l_tabela_2 = 'tmp53_2'
 let l_titulo   = ' > Veiculo Financiado : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------UtilizacaoVeiculo-------------------------------
 let l_campo_compara = 'UtilizacaoVeiculo'
 let l_tabela_1 = 'tmp53_1'
 let l_tabela_2 = 'tmp53_2'
 let l_titulo   = ' > Utilizacao do Veiculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_Clausula()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)
define l_CodClausula  char(100)


define l_1_CodigoClausula          char(50)
define l_1_CoeficienteClausula     char(7)
define l_1_CobrancaSN              char(1)
define l_1_IncVigencia             char(10)
define l_1_FinalVigencia           char(10)
define l_1_PremioLiquidoClausula   char(16)
define l_1_PremioTotalClausulas    char(16)
define l_2_CodigoClausula          char(50)
define l_2_CoeficienteClausula     char(7)
define l_2_CobrancaSN              char(1)
define l_2_IncVigencia             char(10)
define l_2_FinalVigencia           char(10)
define l_2_PremioLiquidoClausula   char(16)
define l_2_PremioTotalClausulas    char(16)


######## REGISTRO DE CLAUSULA ########
 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "===================== REGISTRO DE CLAUSULA 54 ====================="


 call cty21g03_prepare_54_Clausula()

 open ccty21g03tmp54
 foreach ccty21g03tmp54  into l_1_CodigoClausula
                            , l_1_CoeficienteClausula
                            , l_1_CobrancaSN
                            , l_1_IncVigencia
                            , l_1_FinalVigencia
                            , l_1_PremioLiquidoClausula
                            , l_1_PremioTotalClausulas
                            , l_2_CodigoClausula
                            , l_2_CoeficienteClausula
                            , l_2_CobrancaSN
                            , l_2_IncVigencia
                            , l_2_FinalVigencia
                            , l_2_PremioLiquidoClausula
                            , l_2_PremioTotalClausulas


    if l_1_CoeficienteClausula   <>  l_2_CoeficienteClausula       or
       l_1_CobrancaSN            <>  l_2_CobrancaSN                or
       l_1_IncVigencia           <>  l_2_IncVigencia               or
       l_1_FinalVigencia         <>  l_2_FinalVigencia             or
       l_1_PremioLiquidoClausula <>  l_2_PremioLiquidoClausula     or
       l_1_PremioTotalClausulas  <>  l_2_PremioTotalClausulas      or
       l_1_CodigoClausula           =   ' '                        or
       l_2_CodigoClausula           =   ' '                        or
       l_1_CodigoClausula           is null                        or
       l_2_CodigoClausula           is null                        then

       #carrega array
        if (l_1_CodigoClausula[1,3] is not null or
            l_1_CodigoClausula[1,3] <> ' '         ) and
           (l_2_CodigoClausula[1,3] is not null or
            l_2_CodigoClausula[1,3] <> ' '         ) then

            let ccty21g03_tela[m_index+2] = " ----------- ", l_1_CodigoClausula clipped," ----------- "
            let m_index = m_index + 2

            if l_1_CoeficienteClausula <>  l_2_CoeficienteClausula then
               let ccty21g03_tela[m_index+1] = " > Coeficiente da Clausula : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_CoeficienteClausula
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_CoeficienteClausula
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_CobrancaSN <> l_2_CobrancaSN then
               let ccty21g03_tela[m_index+1] = " > Cobranca S/N ? : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_CobrancaSN
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_CobrancaSN
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_IncVigencia <>  l_2_IncVigencia then
               let ccty21g03_tela[m_index+1] = " > Inicio da Vigencia : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_IncVigencia
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_IncVigencia
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_FinalVigencia <>  l_2_FinalVigencia then
               let ccty21g03_tela[m_index+1] = " > Final da Vigencia : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_FinalVigencia
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_FinalVigencia
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_PremioLiquidoClausula <>  l_2_PremioLiquidoClausula then
               let ccty21g03_tela[m_index+1] = " > Premio Liquido : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_PremioLiquidoClausula
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_PremioLiquidoClausula
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

            if l_1_PremioTotalClausulas <>  l_2_PremioTotalClausulas then
               let ccty21g03_tela[m_index+1] = " > Premio Total : "
               let ccty21g03_tela[m_index+2] = "    DE...: ",l_1_PremioTotalClausulas
               let ccty21g03_tela[m_index+3] = "    PARA.: ",l_2_PremioTotalClausulas
               let ccty21g03_tela[m_index+4] = "                                      "

               let m_index = m_index + 5
            end if

        else
           let m_index = m_index + 1

           if l_1_CodigoClausula[1,3] is null or l_2_CodigoClausula[1,3] = ' ' then
              let ccty21g03_tela[m_index] = "         ----------------------------------- "
              let ccty21g03_tela[m_index+1] = " > Clausula INCLUIDA! na 2a Proposta : "
              let ccty21g03_tela[m_index+2] = "     Clausula........: ",l_2_CodigoClausula
              let ccty21g03_tela[m_index+3] = "     Coeficiente.....: ",l_2_CoeficienteClausula
              let ccty21g03_tela[m_index+4] = "     Cobranca S/N....: ",l_2_CobrancaSN
              let ccty21g03_tela[m_index+5] = "     Inicio Vigencia.: ",l_2_IncVigencia
              let ccty21g03_tela[m_index+6] = "     Final Vigencia..: ",l_2_FinalVigencia
              let ccty21g03_tela[m_index+7] = "     Premio Liquido..: ",l_2_PremioLiquidoClausula
              let ccty21g03_tela[m_index+8] = "     Premio Total....: ",l_2_PremioTotalClausulas

              let m_index = m_index + 9
           end if

           if l_2_CodigoClausula[1,3] is null or l_2_CodigoClausula[1,3] = ' ' then
              let ccty21g03_tela[m_index] = "         ----------------------------------- "
              let ccty21g03_tela[m_index+1] = " > Clausula EXCLUIDA! na 2a Proposta : "
              let ccty21g03_tela[m_index+2] = "     Clausula........: ",l_1_CodigoClausula
              let ccty21g03_tela[m_index+3] = "     Coeficiente.....: ",l_1_CoeficienteClausula
              let ccty21g03_tela[m_index+4] = "     Cobranca S/N....: ",l_1_CobrancaSN
              let ccty21g03_tela[m_index+5] = "     Inicio Vigencia.: ",l_1_IncVigencia
              let ccty21g03_tela[m_index+6] = "     Final Vigencia..: ",l_1_FinalVigencia
              let ccty21g03_tela[m_index+7] = "     Premio Liquido..: ",l_1_PremioLiquidoClausula
              let ccty21g03_tela[m_index+8] = "     Premio Total....: ",l_1_PremioTotalClausulas

              let m_index = m_index + 9
           end if

          let m_chave_diff = 1
        end if
    end if
 end foreach

 call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_DescontoLocal()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)


   define l_1_CpfCondutor       char(9)
   define l_1_DigitoCpfCondutor char(2)
   define l_2_CpfCondutor       char(9)
   define l_2_DigitoCpfCondutor char(2)


 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "================== DESCONTO LOCAL - POL OFF LINE =================="

######## DESCONTO LOCAL - POL OFF LINE ########

---------------------------NumeroPpw-------------------------------
 let l_campo_compara = 'NumeroPpw'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Numero PPW : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------SenhaUtilizada-------------------------------
 let l_campo_compara = 'SenhaUtilizada'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Senha Utilizada : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ClasseLocalizacao-------------------------------
 let l_campo_compara = 'ClasseLocalizacao'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Classe de Localizacao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CodigoVeiculo-------------------------------
 let l_campo_compara = 'CodigoVeiculo'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Codigo do Veiculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataCalculo-------------------------------
 let l_campo_compara = 'DataCalculo'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Data do Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DescontoOffLine-------------------------------
 let l_campo_compara = 'DescontoOffLine'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Desconto Off-Line : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Criptografia-------------------------------
 let l_campo_compara = 'Criptografia'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Criptografia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CpfProponente-------------------------------
 let l_campo_compara = 'CpfProponente'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > CPF do Proponente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------OrdemProponente-------------------------------
 let l_campo_compara = 'OrdemProponente'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Ordem do Proponente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DigitoProponente-------------------------------
 let l_campo_compara = 'DigitoProponente'
 let l_tabela_1 = 'tmp55_1'
 let l_tabela_2 = 'tmp55_2'
 let l_titulo   = ' > Digito do Proponente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

 call cty21g03_prepare_55_DescontoLocal()
 open ccty21g03tmp55
 foreach ccty21g03tmp55 into  l_1_CpfCondutor
                          ,l_1_DigitoCpfCondutor
                          ,l_2_CpfCondutor
                          ,l_2_DigitoCpfCondutor

    if l_1_DigitoCpfCondutor <>  l_2_DigitoCpfCondutor or
       l_1_CpfCondutor        =   ' '              or
       l_2_CpfCondutor        =   ' '              or
       l_1_CpfCondutor        is null              or
       l_2_CpfCondutor        is null              then
       #carrega array

       let ccty21g03_tela[m_index+1] = "  (1) DADOS DA PRIMEIRA PROPOSTA :  "
       let ccty21g03_tela[m_index+2] = "    > CPF do Condutor........: ",l_1_CpfCondutor
       let ccty21g03_tela[m_index+3] = "    > Digito CPF do Condutor.: ",l_1_DigitoCpfCondutor
       let ccty21g03_tela[m_index+5] = "  (2) DADOS DA SEGUNDA PROPOSTA :  "
       let ccty21g03_tela[m_index+6] = "    > CPF do Condutor........: ",l_2_CpfCondutor
       let ccty21g03_tela[m_index+7] = "    > Digito CPF do Condutor.: ",l_2_DigitoCpfCondutor
       let ccty21g03_tela[m_index+8] = "                           ***                                "
       let ccty21g03_tela[m_index+9] = "                                                              "
       let m_index = m_index + 9

       let m_chave_diff = 1
   end if
 end foreach


{
---------------------------CpfCondutor--------------------------------
 let l_campo_compara = 'CpfCondutor'
 let l_tabela_1 = 'tmp55a_1'
 let l_tabela_2 = 'tmp55a_2'
 let l_titulo   = ' > CPF do Condutor : '
 call cty21g03_para_cada_desconto_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo
                             ,'CpfCondutor')

---------------------------DigitoCpfCondutor--------------------------------
 let l_campo_compara = 'DigitoCpfCondutor'
 let l_tabela_1 = 'tmp55a_1'
 let l_tabela_2 = 'tmp55a_2'
 let l_titulo   = ' > Digito CPF do Condutor : '
 call cty21g03_para_cada_desconto_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo
                             ,'CpfCondutor')
}
   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_QuestObrigat()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=============== QUESTIONARIO OBRIGATORIO (EMPRESA) ================"

######## QUESTIONARIO OBRIGATORIO (EMPRESA) ########

---------------------------SequenciaLocal-------------------------------
 let l_campo_compara = 'SequenciaLocal'
 let l_tabela_1 = 'tmp56_1'
 let l_tabela_2 = 'tmp56_2'
 let l_titulo   = ' > Sequencia do Local : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CodigoQuestao-------------------------------
 let l_campo_compara = 'CodigoQuestao'
 let l_tabela_1 = 'tmp56_1'
 let l_tabela_2 = 'tmp56_2'
 let l_titulo   = ' > Codigo da Questao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DescricaoResposta-------------------------------
 let l_campo_compara = 'DescricaoResposta'
 let l_tabela_1 = 'tmp56_1'
 let l_tabela_2 = 'tmp56_2'
 let l_titulo   = ' > Descricao da Resposta : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_VersaoDLL()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "======== VERSÃO DA DLL E DADOS ADICIONAIS DO SEGURADO PJ =========="

######## VERSÃO DA DLL E DADOS ADICIONAIS DO SEGURADO PJ ########

---------------------------CodigoReg-------------------------------
 let l_campo_compara = 'CodigoReg'
 let l_tabela_1 = 'tmp58_1'
 let l_tabela_2 = 'tmp58_2'
 let l_titulo   = ' > Codigo do Registro : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VersaoDllCalculo-------------------------------
 let l_campo_compara = 'VersaoDllCalculo'
 let l_tabela_1 = 'tmp58_1'
 let l_tabela_2 = 'tmp58_2'
 let l_titulo   = ' > Versao da DLL de Calculo : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PatrimonioLiquido-------------------------------
 let l_campo_compara = 'PatrimonioLiquido'
 let l_tabela_1 = 'tmp58_1'
 let l_tabela_2 = 'tmp58_2'
 let l_titulo   = ' > Patrimonio Liquido : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------RecOperacBrutaAnual-------------------------------
 let l_campo_compara = 'RecOperacBrutaAnual'
 let l_tabela_1 = 'tmp58_1'
 let l_tabela_2 = 'tmp58_2'
 let l_titulo   = ' > Receita Operacional Bruta Anual : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------AdminControlProcur-------------------------------
 let l_campo_compara = 'AdminControlProcur'
 let l_tabela_1 = 'tmp58_1'
 let l_tabela_2 = 'tmp58_2'
 let l_titulo   = ' > Administradores, Controladores, Procuradores : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoEmpresa-------------------------------
 let l_campo_compara = 'TipoEmpresa'
 let l_tabela_1 = 'tmp58_1'
 let l_tabela_2 = 'tmp58_2'
 let l_titulo   = ' > Tipo da Empresa : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_VinculosPJ()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====== VINCULOS PJ-CONTROLADORES,ADMINISTRADORES,PROCURADORES ====="

######## VINCULOS PJ - CONTROLADORES, ADMINISTRADORES, PROCURADORES ########

---------------------------TipoProponente-------------------------------
 let l_campo_compara = 'TipoProponente'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > Tipo do Proponente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Nome-------------------------------
 let l_campo_compara = 'Nome'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > Nome : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TipoPessoa-------------------------------
 let l_campo_compara = 'TipoPessoa'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > Tipo de Pessoa : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CpfCnpj-------------------------------
 let l_campo_compara = 'CpfCnpj'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > CPF/CNPJ : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Ordem-------------------------------
 let l_campo_compara = 'Ordem'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > Ordem : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Digito-------------------------------
 let l_campo_compara = 'Digito'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > Digito : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------SemCpfCnpjPor-------------------------------
 let l_campo_compara = 'SemCpfCnpjPor'
 let l_tabela_1 = 'tmp59_1'
 let l_tabela_2 = 'tmp59_2'
 let l_titulo   = ' > Sem CPF/CNPJ por: '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_OutrosSeguros()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "========================= OUTROS SEGUROS =========================="

######## OUTROS SEGUROS ########

---------------------------DescricaoTexto-------------------------------
 let l_campo_compara = 'DescricaoTexto'
 let l_tabela_1 = 'tmp60_1'
 let l_tabela_2 = 'tmp60_2'
 let l_titulo   = ' > Descricao do Texto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_FinalidEmissao()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== FINALIDADE DA EMISSAO ======================"

######## FINALIDADE DA EMISSAO ########

---------------------------FinalidadeEmissao-------------------------------
 let l_campo_compara = 'FinalidadeEmissao'
 let l_tabela_1 = 'tmp61_1'
 let l_tabela_2 = 'tmp61_2'
 let l_titulo   = ' > Finalidade da Emissao : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------FinalidadeEncargos-------------------------------
 let l_campo_compara = 'FinalidadeEncargos'
 let l_tabela_1 = 'tmp61_1'
 let l_tabela_2 = 'tmp61_2'
 let l_titulo   = ' > Finalidade de Encargos : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorTotalPremio-------------------------------
 let l_campo_compara = 'ValorTotalPremio'
 let l_tabela_1 = 'tmp61_1'
 let l_tabela_2 = 'tmp61_2'
 let l_titulo   = ' > Valor Total do Premio : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function


#========================================
function cty21g03_campos_CobrancaAntigo()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=================== DADOS DE COBRANCA - ANTIGO ===================="

######## DADOS DE COBRANCA - ANTIGO ########

---------------------------TipoFormaPagto-------------------------------
 let l_campo_compara = 'TipoFormaPagto'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Tipo de Forma de Pagto : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroParcela-------------------------------
 let l_campo_compara = 'NumeroParcela'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Numero da Parcela : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroCartaoCredito-------------------------------
 let l_campo_compara = 'NumeroCartaoCredito'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Numero do Cartao de Credito : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VencimentoCartaoCredito-------------------------------
 let l_campo_compara = 'VencimentoCartaoCredito'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Vencimento do Cartao de Credito : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroBanco-------------------------------
 let l_campo_compara = 'NumeroBanco'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Numero do Banco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroAgencia-------------------------------
 let l_campo_compara = 'NumeroAgencia'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Numero da Agencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroContaCorrente-------------------------------
 let l_campo_compara = 'NumeroContaCorrente'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Numero da Conta Corrente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DigitoContaCorrente-------------------------------
 let l_campo_compara = 'DigitoContaCorrente'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Digito da Conta Corrente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataVencimento-------------------------------
 let l_campo_compara = 'DataVencimento'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Data de Vencimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorParcela-------------------------------
 let l_campo_compara = 'ValorParcela'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Valor da Parcela : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroCheque-------------------------------
 let l_campo_compara = 'NumeroCheque'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Numero do Cheque : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PracaCheque-------------------------------
 let l_campo_compara = 'PracaCheque'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > Praca do Cheque : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CnpjCpfCorrentista-------------------------------
 let l_campo_compara = 'CnpjCpfCorrentista'
 let l_tabela_1 = 'tmp62_1'
 let l_tabela_2 = 'tmp62_2'
 let l_titulo   = ' > CNPJ/CPF do Correntista : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_CustosApolices()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=================== CUSTOS DE APOLICES/PARCELAS ==================="

######## CUSTOS DE APOLICES/PARCELAS ########

---------------------------CustoApolice-------------------------------
 let l_campo_compara = 'CustoApolice'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Custo da Apolice : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------IOF-------------------------------
 let l_campo_compara = 'IOF'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > IOF : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PremioVista-------------------------------
 let l_campo_compara = 'PremioVista'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Premio a Vista : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------TaxaCasco-------------------------------
 let l_campo_compara = 'TaxaCasco'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Taxa do Casco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------SeguroMensal-------------------------------
 let l_campo_compara = 'SeguroMensal'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Seguro Mensal : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------Parcelas1-------------------------------
 let l_campo_compara = 'Parcelas1'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Parcelas 1. : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ParcelasDemais-------------------------------
 let l_campo_compara = 'ParcelasDemais'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Parcelas Demais : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ParcelasJuros-------------------------------
 let l_campo_compara = 'ParcelasJuros'
 let l_tabela_1 = 'tmp63_1'
 let l_tabela_2 = 'tmp63_2'
 let l_titulo   = ' > Parcelas Juros : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function



#========================================
function cty21g03_campos_CobrancaNovo()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=========== DADOS DE COBRANCA - NOVO(A PARTIR DEZ) ================"

######## DADOS DE COBRANCA - NOVO(A PARTIR DEZ) ########

---------------------------TipoFormaPagto-------------------------------
 let l_campo_compara = 'TipoFormaPagto'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Tipo da Forma de Pagamento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroParcela-------------------------------
 let l_campo_compara = 'NumeroParcela'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Numero da Parcela : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroCartaoCredito-------------------------------
 let l_campo_compara = 'NumeroCartaoCredito'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Numero do Cartao de Credito : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------VencimentoCartaoCredito-------------------------------
 let l_campo_compara = 'VencimentoCartaoCredito'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Vencimento do Cartao de Credito : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroBanco-------------------------------
 let l_campo_compara = 'NumeroBanco'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Numero do Banco : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroAgencia-------------------------------
 let l_campo_compara = 'NumeroAgencia'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Numero da Agencia : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroContaCorrente-------------------------------
 let l_campo_compara = 'NumeroContaCorrente'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Numero da Conta Corrente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DigitoContaCorrente-------------------------------
 let l_campo_compara = 'DigitoContaCorrente'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Digito da Conta Corrente : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DataVencimento-------------------------------
 let l_campo_compara = 'DataVencimento'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Data de Vencimento : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------ValorParcela-------------------------------
 let l_campo_compara = 'ValorParcela'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Valor da Parcela : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NumeroCheque-------------------------------
 let l_campo_compara = 'NumeroCheque'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Numero do Cheque : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PracaCheque-------------------------------
 let l_campo_compara = 'PracaCheque'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > Praca do Cheque : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CnpjCpfCorrentista-------------------------------
 let l_campo_compara = 'CnpjCpfCorrentista'
 let l_tabela_1 = 'tmp64_1'
 let l_tabela_2 = 'tmp64_2'
 let l_titulo   = ' > CNPJ/CPF do Correntista : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function



#========================================
function cty21g03_campos_TransitoGentil()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "====================== TRANSITO MAIS GENTIL ======================="

######## TRANSITO MAIS GENTIL ########

---------------------------FlagTransitoGentil-------------------------------
 let l_campo_compara = 'FlagTransitoGentil'
 let l_tabela_1 = 'tmp66_1'
 let l_tabela_2 = 'tmp66_2'
 let l_titulo   = ' > Flag Transito Mais Gentil : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CnhTransitoGentil-------------------------------
 let l_campo_compara = 'CnhTransitoGentil'
 let l_tabela_1 = 'tmp66_1'
 let l_tabela_2 = 'tmp66_2'
 let l_titulo   = ' > CNH Transito Mais Gentil : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#========================================
function cty21g03_campos_Pep()
#========================================
define l_campo_1  char(100)
define l_campo_2  char(100)
define l_titulo   char(80)
define l_tabela_1 char(100)
define l_tabela_2 char(100)
define l_campo_compara char(100)

 let m_index = m_index + 1
 let ccty21g03_tela[m_index] = "=============================== PEP ==============================="

######## PEP ########

---------------------------CodigoPEP-------------------------------
 let l_campo_compara = 'CodigoPEP'
 let l_tabela_1 = 'tmp67_1'
 let l_tabela_2 = 'tmp67_2'
 let l_titulo   = ' > Codigo PEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------PEP-------------------------------
 let l_campo_compara = 'PEP'
 let l_tabela_1 = 'tmp67_1'
 let l_tabela_2 = 'tmp67_2'
 let l_titulo   = ' > PEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------NomePEP-------------------------------
 let l_campo_compara = 'NomePEP'
 let l_tabela_1 = 'tmp67_1'
 let l_tabela_2 = 'tmp67_2'
 let l_titulo   = ' > Nome PEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------CpfPEP-------------------------------
 let l_campo_compara = 'CpfPEP'
 let l_tabela_1 = 'tmp67_1'
 let l_tabela_2 = 'tmp67_2'
 let l_titulo   = ' > Cpf PEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------DigitoCpfPEP-------------------------------
 let l_campo_compara = 'DigitoCpfPEP'
 let l_tabela_1 = 'tmp67_1'
 let l_tabela_2 = 'tmp67_2'
 let l_titulo   = ' > Digito Cpf PEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

---------------------------GrauRelacPEP-------------------------------
 let l_campo_compara = 'GrauRelacPEP'
 let l_tabela_1 = 'tmp67_1'
 let l_tabela_2 = 'tmp67_2'
 let l_titulo   = ' > Grau Relac PEP : '
 call cty21g03_para_cada_item(l_campo_compara
                             ,l_tabela_1
                             ,l_tabela_2
                             ,l_titulo)

   call cty21g03_verifica_diff()

end function

#================================================================================
function cty21g03_para_cada_item(l_campo_compara,l_tabela_1,l_tabela_2, l_titulo)
#================================================================================
define l_campo_1       char(100)
define l_campo_2       char(100)
define l_titulo        char(80)
define l_tabela_1      char(100)
define l_tabela_2      char(100)
define l_campo_compara char(100)

----------------------------------------------
let l_campo_1       =  l_campo_1       clipped
let l_campo_2       =  l_campo_2       clipped
let l_titulo        =  l_titulo        clipped
let l_tabela_1      =  l_tabela_1      clipped
let l_tabela_2      =  l_tabela_2      clipped
let l_campo_compara =  l_campo_compara clipped
----------------------------------------------

 call cty21g03_prepare_temp(l_campo_compara, l_tabela_1, l_tabela_2)

 open ccty21g03tmp

 foreach ccty21g03tmp into l_campo_1, l_campo_2

   if l_campo_1 <> l_campo_2 or
      l_campo_1 is null      or
      l_campo_2 is null      then

      if not (l_campo_1 is null  and  l_campo_2 is null)  then
         let m_chave_diff = 1
         call cty21g03_carrega_array(l_titulo, l_campo_1, l_campo_2)
      end if
   end if

 end foreach

end function

#======================================================================================================
function cty21g03_para_cada_desconto_item(l_campo_compara,l_tabela_1,l_tabela_2, l_titulo, l_parametro)
#======================================================================================================
define l_campo_1       char(100)
define l_campo_2       char(100)
define l_titulo        char(80)
define l_tabela_1      char(100)
define l_tabela_2      char(100)
define l_campo_compara char(100)
define l_parametro     char(100)

----------------------------------------------
let l_campo_1       =  l_campo_1       clipped
let l_campo_2       =  l_campo_2       clipped
let l_titulo        =  l_titulo        clipped
let l_tabela_1      =  l_tabela_1      clipped
let l_tabela_2      =  l_tabela_2      clipped
let l_campo_compara =  l_campo_compara clipped
let l_parametro     =  l_parametro     clipped
----------------------------------------------

 call cty21g03_prepare_desconto_temp(l_campo_compara, l_tabela_1, l_tabela_2, l_parametro)

 open ccty21g03tmp2

 foreach ccty21g03tmp2 into l_campo_1, l_campo_2

   if l_campo_1 <> l_campo_2 or
      l_campo_1 is null      or
      l_campo_2 is null      then

      if not (l_campo_1 is null  and  l_campo_2 is null)  then
         let m_chave_diff = 1
         call cty21g03_carrega_array(l_titulo, l_campo_1, l_campo_2)
      end if
   end if

 end foreach

end function

#=============================================================================
function cty21g03_carrega_array(l_titulo, l_campo_1, l_campo_2)
#=============================================================================
define l_campo_1 char(500)
define l_campo_2 char(500)
define l_titulo  char(80)

  let m_index = m_index + 1

     let ccty21g03_tela[m_index] = l_titulo
     let ccty21g03_tela[m_index+1] = "    DE...: ",l_campo_1
     let ccty21g03_tela[m_index+2] = "    PARA.: ",l_campo_2
     let ccty21g03_tela[m_index+3] = "                                      "

  let m_index = m_index + 3

end function



#==============================
function cty21g03_delete_temp()
#==============================

delete from tmp_00
delete from tmp_01
delete from tmp_04
delete from tmp_05
delete from tmp_06
delete from tmp_07
delete from tmp_08
delete from tmp_09
delete from tmp_10
delete from tmp_11
delete from tmp_12
delete from tmp_13
delete from tmp_14
delete from tmp_15
#delete from tmp_16
delete from tmp_17
delete from tmp_18
delete from tmp_19
delete from tmp_20
delete from tmp_20a
delete from tmp_21
delete from tmp_22
delete from tmp_24
delete from tmp_27
delete from tmp_29
delete from tmp_30
delete from tmp_31
delete from tmp_32
delete from tmp_35
delete from tmp_36
delete from tmp_37
delete from tmp_38
delete from tmp_39
delete from tmp_40
delete from tmp_41
delete from tmp_42
delete from tmp_43
delete from tmp_44
delete from tmp_44a
delete from tmp_45
delete from tmp_46
delete from tmp_47
delete from tmp_48
delete from tmp_49
delete from tmp_50
delete from tmp_52
delete from tmp_53
delete from tmp_54
delete from tmp_55
delete from tmp_55a
delete from tmp_56
delete from tmp_58
delete from tmp_59
delete from tmp_60
delete from tmp_61
delete from tmp_62
delete from tmp_63
delete from tmp_64
delete from tmp_66
delete from tmp_67

end function

#==============================
function cty21g03_drop_temp()
#==============================
drop table tmp_00
drop table tmp_01
drop table tmp_04
drop table tmp_05
drop table tmp_06
drop table tmp_07
drop table tmp_08
drop table tmp_09
drop table tmp_10
drop table tmp_11
drop table tmp_12
drop table tmp_13
drop table tmp_14
drop table tmp_15
#drop table tmp_16
#drop table tmp_17
drop table tmp_18
drop table tmp_19
drop table tmp_20
drop table tmp_20a
drop table tmp_21
drop table tmp_22
drop table tmp_24
drop table tmp_27
drop table tmp_29
drop table tmp_30
drop table tmp_31
drop table tmp_32
drop table tmp_35
drop table tmp_36
drop table tmp_37
drop table tmp_38
drop table tmp_39
drop table tmp_40
drop table tmp_41
drop table tmp_42
drop table tmp_43
drop table tmp_44
drop table tmp_44a
drop table tmp_45
drop table tmp_46
drop table tmp_47
drop table tmp_48
drop table tmp_49
drop table tmp_50
drop table tmp_52
drop table tmp_53
#drop table tmp_54
drop table tmp_55
drop table tmp_55a
drop table tmp_56
drop table tmp_58
drop table tmp_59
drop table tmp_60
drop table tmp_61
drop table tmp_62
drop table tmp_63
drop table tmp_64
drop table tmp_66
drop table tmp_67

-------------------
drop table tmp00_1
drop table tmp01_1
drop table tmp04_1
drop table tmp05_1
drop table tmp06_1
drop table tmp07_1
drop table tmp08_1
drop table tmp09_1
drop table tmp10_1
drop table tmp11_1
drop table tmp12_1
drop table tmp13_1
drop table tmp14_1
drop table tmp15_1
#drop table tmp16_1
drop table tmp17_1
drop table tmp18_1
drop table tmp19_1
drop table tmp20_1
drop table tmp20a_1
drop table tmp21_1
#drop table tmp22_1
drop table tmp24_1
drop table tmp27_1
drop table tmp29_1
drop table tmp30_1
drop table tmp31_1
drop table tmp32_1
drop table tmp35_1
drop table tmp36_1
drop table tmp37_1
drop table tmp38_1
drop table tmp39_1
drop table tmp40_1
drop table tmp41_1
drop table tmp42_1
drop table tmp43_1
drop table tmp44_1
drop table tmp44a_1
drop table tmp45_1
drop table tmp46_1
drop table tmp47_1
drop table tmp48_1
drop table tmp49_1
drop table tmp50_1
drop table tmp52_1
drop table tmp53_1
drop table tmp54_1
drop table tmp55_1
drop table tmp55a_1
drop table tmp56_1
drop table tmp58_1
drop table tmp59_1
drop table tmp60_1
drop table tmp61_1
drop table tmp62_1
drop table tmp63_1
drop table tmp64_1
drop table tmp66_1
drop table tmp67_1

-----------------------

drop table tmp00_2
drop table tmp01_2
drop table tmp04_2
drop table tmp05_2
drop table tmp06_2
drop table tmp07_2
drop table tmp08_2
drop table tmp09_2
drop table tmp10_2
drop table tmp11_2
drop table tmp12_2
drop table tmp13_2
drop table tmp14_2
drop table tmp15_2
#drop table tmp16_2
drop table tmp17_2
drop table tmp18_2
drop table tmp19_2
drop table tmp20_2
drop table tmp20a_2
drop table tmp21_2
drop table tmp22_2
drop table tmp24_2
drop table tmp27_2
drop table tmp29_2
drop table tmp30_2
drop table tmp31_2
drop table tmp32_2
drop table tmp35_2
drop table tmp36_2
drop table tmp37_2
drop table tmp38_2
drop table tmp39_2
drop table tmp40_2
drop table tmp41_2
drop table tmp42_2
drop table tmp43_2
drop table tmp44_2
drop table tmp44a_2
drop table tmp45_2
drop table tmp46_2
drop table tmp47_2
drop table tmp48_2
drop table tmp49_2
drop table tmp50_2
drop table tmp52_2
drop table tmp53_2
drop table tmp54_2
drop table tmp55_2
drop table tmp55a_2
drop table tmp56_2
drop table tmp58_2
drop table tmp59_2
drop table tmp60_2
drop table tmp61_2
drop table tmp62_2
drop table tmp63_2
drop table tmp64_2
drop table tmp66_2
drop table tmp67_2

end function
#=================================
function cty21g03_verifica_diff()
#=================================

if m_flag = 'F5' then
  if m_chave_diff = 0 then
     let m_index = m_index + 1
     let ccty21g03_tela[m_index] = " Sem Alteracao! "
     let m_index = m_index + 1
  end if
else
  if m_chave_diff = 0 then
     if ccty21g03_tela[m_index - 1] is null or
        ccty21g03_tela[m_index - 1] = ' ' then
        let m_index = m_index - 1
     else
       let ccty21g03_tela[m_index] = " "
     end if
  end if
end if


end function
