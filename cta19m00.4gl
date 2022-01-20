############################################################################
# Nome do Modulo: CTA19M00                                                 #
# Porto Seguro Cia Seguros Gerais                                          #
# Envio de email de Reclamacao do Porto Socorro                            #
#                                                                          #
# Humberto Santos                                         Julho/2012       #
#--------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail#
############################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"
globals '/homedsa/projetos/geral/globals/gpvia021.4gl' ---> VEP - Vida

define m_prepara_sql  smallint
define m_prepara2_sql smallint
define m_flag         smallint
define m_c24trxnum    decimal(8,0)
define m_titulo       char(50)
define m_grupo        like gtakram.ramgrpcod
define m_crtsaunum    like datrsrvsau.crtnum
define m_ciaempcod    like datmservico.ciaempcod
define m_doc_handle   integer
define m_hostname     like ibpkdbspace.srvnom



define m_viginc      like abamapol.viginc,
       m_vigfnl      like abamapol.vigfnl,
       m_status      smallint,
       m_status_xml  smallint,
       m_msg         char(20)

define m_datkprtcpa  record like datkprtcpa.*

define mr_param      record
         ramcod      like datrservapol.ramcod,
         c24astcod   like datmligacao.c24astcod,
         cvnnum      like datkprtcpa.cvnnum,
         succod      like datrservapol.succod,
         aplnumdig   like datrservapol.aplnumdig,
         itmnumdig   like datrservapol.itmnumdig,
         lignum      like datrligsrv.lignum,
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   char(06),
         prporg      like apbmitem.prporgpcp,
         prpnumdig   like apbmitem.prpnumpcp,
         solnom      like datmligacao.c24solnom,
         atdsrvorg   like datmservico.atdsrvorg
end record


define lr_param record
         empcod    like ctgklcl.empcod,       --Empresa
         succod    like ctgklcl.succod,       --Sucursal
         cctlclcod like ctgklcl.cctlclcod,    --Local
         cctdptcod like ctgrlcldpt.cctdptcod  --Departamento
end record

define lr_ret record
         erro          smallint,
         mens          char(40),
         cctlclnom     like ctgklcl.cctlclnom,   --Nome do local
         cctdptnom     like ctgkdpt.cctdptnom,   --Nome do depto (antigo cctnom)
         cctdptrspnom  like ctgrlcldpt.cctdptrspnom, --Resp pelo departamento
         cctdptlclsit  like ctgrlcldpt.cctdptlclsit, --Sit do depto (A)tivo (I)nativo
         cctdpttip     like ctgkdpt.cctdpttip    -- Tipo de departamento
end record

#----------------------------#
 function cta19m00_prepare()
#----------------------------#
 define l_sql_stmt   char(800)

 let l_sql_stmt = ' select ramcod, ',
                  ' c24astcod, ',
                  ' cvnnum, ',
                  ' c24prtseq, ',
                  ' c24prtsit, ',
                  ' caddat, ',
                  ' cadhor, ',
                  ' cadmat, ',
                  ' cadusrtip, ',
                  ' cademp ',
                  ' from datkprtcpa ',
                  ' where (ramcod   = ? ',
                  ' or  ramcod   = 0 ) ',
                  ' and c24astcod = ? ',
                  ' and (cvnnum   = ? ',
                  ' or cvnnum    = 0 ) ',
                  ' and c24prtsit = "A" ',
                  ' order by cvnnum, c24prtseq '

 prepare p_cta19m00_001 from l_sql_stmt
 declare c_cta19m00_001 cursor with hold for p_cta19m00_001

 let l_sql_stmt = ' select c24astdes, ',
                         ' c24astpgrtxt ',
                    ' from datkassunto ',
                   ' where c24astcod = ? '

 prepare p_cta19m00_002 from l_sql_stmt
 declare c_cta19m00_002 cursor for p_cta19m00_002

 let l_sql_stmt = ' select c24prtinftip ',
                    ' from datkprtinftip ',
                   ' where ramcod    = ? ',
                     ' and c24astcod = ? ',
                     ' and cvnnum    = ? ',
                     ' and c24prtseq = ? '

 prepare p_cta19m00_003 from l_sql_stmt
 declare c_cta19m00_003 cursor with hold for p_cta19m00_003

 let l_sql_stmt = ' select segnumdig ',
                    ' from abbmdoc ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? '

 prepare p_cta19m00_004 from l_sql_stmt
 declare c_cta19m00_004 cursor for p_cta19m00_004

 let l_sql_stmt = ' select segnom, ',
                         ' cgccpfnum, ',
                         ' cgcord, ',
                         ' cgccpfdig ',
                    ' from gsakseg ',
                   ' where segnumdig = ? '

 prepare p_cta19m00_005 from l_sql_stmt
 declare c_cta19m00_005 cursor for p_cta19m00_005

 let l_sql_stmt = ' select avialgmtv, ',
                         ' avioccdat, ',
                         ' lcvcod, ',
                         ' avivclcod ',
                    ' from datmavisrent ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_006 from l_sql_stmt
 declare c_cta19m00_006 cursor for p_cta19m00_006

 let l_sql_stmt = ' select cpodes ',
                    ' from iddkdominio ',
                   ' where cponom = ? ',
                     ' and cpocod = ? '

 prepare p_cta19m00_007 from l_sql_stmt
 declare c_cta19m00_007 cursor for p_cta19m00_007

 let l_sql_stmt = ' select aviprodiaqtd, ',
                         ' aviprostt, ',
                         ' aviproseq ',
                    ' from datmprorrog ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? ',
                   ' order by aviproseq desc '

 prepare p_cta19m00_008 from l_sql_stmt
 declare c_cta19m00_008 cursor for p_cta19m00_008

 let l_sql_stmt = ' select avivclgrp ',
                    ' from datkavisveic ',
                   ' where lcvcod    = ? ',
                     ' and avivclcod = ? '

 prepare p_cta19m00_009 from l_sql_stmt
 declare c_cta19m00_009 cursor for p_cta19m00_009

 let l_sql_stmt = ' select vcldes, ',
                         ' atdsrvorg, ',
                         ' vcllicnum, ',
                         ' atddfttxt,  ',
                         ' asitipcod,  ',
                         ' ciaempcod   ',
                    ' from datmservico ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_010 from l_sql_stmt
 declare c_cta19m00_010 cursor for p_cta19m00_010

 let l_sql_stmt = ' select a.vclcoddig, ',
                         ' a.vclanofbc, ',
                         ' a.vclanomdl, ',
                         ' a.vcllicnum, ',
                         ' a.vclchsinc, ',
                         ' a.vclchsfnl ',
                    ' from abbmveic a ',
                   ' where a.succod    = ? ',
                     ' and a.aplnumdig = ? ',
                     ' and a.itmnumdig = ? ',
                     ' and a.dctnumseq = ? '

 prepare p_cta19m00_011 from l_sql_stmt
 declare c_cta19m00_011 cursor for p_cta19m00_011

 let l_sql_stmt = ' select vclcoddig, ',
                         ' vclanofbc, ',
                         ' vclanomdl, ',
                         ' vcllicnum, ',
                         ' vclchsinc, ',
                         ' vclchsfnl  ',
                    ' from apbmveic ',
                   ' where prporgpcp = ? ',
                     ' and prpnumpcp = ? '

 prepare p_cta19m00_012 from l_sql_stmt
 declare c_cta19m00_012 cursor for p_cta19m00_012

 let l_sql_stmt = ' select vclmrccod, ',
                         ' vcltipcod, ',
                         ' vclmdlnom ',
                    ' from agbkveic ',
                   ' where vclcoddig = ? '

 prepare p_cta19m00_013 from l_sql_stmt
 declare c_cta19m00_013 cursor for p_cta19m00_013

 let l_sql_stmt = ' select vclmrcnom ',
                    ' from agbkmarca ',
                   ' where vclmrccod = ? '

 prepare p_cta19m00_014 from l_sql_stmt
 declare c_cta19m00_014 cursor for p_cta19m00_014

 let l_sql_stmt = ' select vcltipnom ',
                    ' from agbktip ',
                   ' where vclmrccod = ? ',
                     ' and vcltipcod = ? '

 prepare p_cta19m00_015 from l_sql_stmt
 declare c_cta19m00_015 cursor for p_cta19m00_015


 let l_sql_stmt = ' select c24ligdsc, ',
                         ' c24txtseq ',
                    ' from datmlighist ',
                   ' where lignum = ? ',
                   ' order by c24txtseq '

 prepare p_cta19m00_017 from l_sql_stmt
 declare c_cta19m00_016 cursor with hold for p_cta19m00_017

 let l_sql_stmt = ' select lgdtip, ',
                         ' lgdnom, ',
                         ' lgdnum, ',
                         ' lclbrrnom, ',
                         ' brrnom, ',
                         ' cidnom, ',
                         ' ufdcod, ',
                         ' endzon, ',
                         ' lclrefptotxt, ',
                         ' dddcod, ',
                         ' lcltelnum, ',
                         ' lclidttxt,  ',
                         ' ofnnumdig, ',
                         ' lclcttnom ',
                    ' from datmlcl ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? ',
                     ' and c24endtip = ? '

 prepare p_cta19m00_018 from l_sql_stmt
 declare c_cta19m00_017 cursor for p_cta19m00_018

 let l_sql_stmt = ' select sindat, ',
                         ' sinhor ',
                    ' from datmservicocmp ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_019 from l_sql_stmt
 declare c_cta19m00_018 cursor for p_cta19m00_019

 let l_sql_stmt = ' select aviprvent ',
                    ' from datmavisrent ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_020 from l_sql_stmt
 declare c_cta19m00_019 cursor for p_cta19m00_020

 let l_sql_stmt = ' select socntzcod ',
                    ' from datmsrvre ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_021 from l_sql_stmt
 declare c_cta19m00_020 cursor for p_cta19m00_021

 let l_sql_stmt = ' select socntzdes ',
                    ' from datksocntz ',
                   ' where socntzcod = ? '

 prepare p_cta19m00_022 from l_sql_stmt
 declare c_cta19m00_021 cursor for p_cta19m00_022

 let l_sql_stmt = ' select corsus ',
                    ' from abamcor ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? '

 prepare p_cta19m00_023 from l_sql_stmt
 declare c_cta19m00_022 cursor for p_cta19m00_023

 let l_sql_stmt = ' select cornom ',
                    ' from gcaksusep, gcakcorr ',
                   ' where gcaksusep.corsuspcp = gcakcorr.corsuspcp ',
                     ' and corsus = ? '

 prepare p_cta19m00_024 from l_sql_stmt
 declare c_cta19m00_023 cursor for p_cta19m00_024

 let l_sql_stmt = ' select viginc, ',
                         ' vigfnl ',
                    ' from abamapol ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? '

 prepare p_cta19m00_025 from l_sql_stmt
 declare c_cta19m00_024 cursor for p_cta19m00_025

 let l_sql_stmt = ' select cbtcod ',
                    ' from abbmcasco ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? '

 prepare p_cta19m00_026 from l_sql_stmt
 declare c_cta19m00_025 cursor for p_cta19m00_026

 let l_sql_stmt = ' select cpodes ',
                    ' from iddkdominio ',
                   ' where cponom = "cbtcod" ',
                     ' and cpocod = ? '

 prepare p_cta19m00_027 from l_sql_stmt
 declare c_cta19m00_026 cursor for p_cta19m00_027

 let l_sql_stmt = ' select clscod, ',
                         ' viginc ',
                    ' from abbmclaus ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? '

 prepare p_cta19m00_028 from l_sql_stmt
 declare c_cta19m00_027 cursor with hold for p_cta19m00_028

 let l_sql_stmt = ' select clsdes ',
                    ' from aackcls ',
                   ' where tabnum = ? ',
                     ' and ramcod = ? ',
                     ' and clscod = ? '

 prepare p_cta19m00_029 from l_sql_stmt
 declare c_cta19m00_028 cursor for p_cta19m00_029

 let l_sql_stmt = ' select frqvlr ',
                    ' from abbmcasco ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? '

 prepare p_cta19m00_030 from l_sql_stmt
 declare c_cta19m00_029 cursor for p_cta19m00_030

 let l_sql_stmt = ' select bonclacod, ',
                         ' clalclcod ',
                    ' from abbmdoc ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? '

 prepare p_cta19m00_031 from l_sql_stmt
 declare c_cta19m00_030 cursor for p_cta19m00_031

 let l_sql_stmt = ' select bondscper ',
                    ' from acatbon ',
                   ' where tabnum    = ? ',
                     ' and ramcod    = ? ',
                     ' and bonclacod = ? ',
                     ' and clalclcod = ? '

 prepare p_cta19m00_032 from l_sql_stmt
 declare c_cta19m00_031 cursor for p_cta19m00_032

 let l_sql_stmt = ' select txtlin ',
                    ' from abbmquesttxt ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? ',
                     ' and qstcod = 19 '

 prepare p_cta19m00_033 from l_sql_stmt
 declare c_cta19m00_032 cursor for p_cta19m00_033

 let l_sql_stmt = ' select clcdat ',
                    ' from abbmcasco ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? '

 prepare p_cta19m00_034 from l_sql_stmt
 declare c_cta19m00_033 cursor for p_cta19m00_034

 let l_sql_stmt = 'select qstcod, ',
                        ' rspcod ',
                   ' from abbmquestionario ',
                   ' where succod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? ',
                     ' and dctnumseq = ? ',
                     ' and qstcod in (22,118,97,136,82,144)'

 prepare p_cta19m00_035 from l_sql_stmt
 declare c_cta19m00_034 cursor for p_cta19m00_035


 let l_sql_stmt = ' select qstrspdsc ',
                    ' from apqkdominio ',
                   ' where qstcod = ? ',
                     ' and rspcod = ? ',
                     ' and viginc = ? '

 prepare p_cta19m00_036 from l_sql_stmt
 declare c_cta19m00_035 cursor for p_cta19m00_036


 let l_sql_stmt = ' select pasnom, ',
                         ' pasidd, ',
                         ' passeq ',
                    ' from datmpassageiro ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? ',
                   ' order by passeq '

 prepare p_cta19m00_037 from l_sql_stmt
 declare c_cta19m00_036 cursor with hold for p_cta19m00_037

 let l_sql_stmt = ' select slcemp, ',
                         ' slcsuccod, ',
                         ' slccctcod ',
                    ' from datmavisrent ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_038 from l_sql_stmt
 declare c_cta19m00_037 cursor for p_cta19m00_038


 let l_sql_stmt = ' select c24srvdsc ',
                    ' from datmservhist ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_039 from l_sql_stmt
 declare c_cta19m00_038 cursor with hold for p_cta19m00_039

 let l_sql_stmt = ' select srvtipdes ',
                    ' from datksrvtip ',
                   ' where atdsrvorg = ? '

 prepare p_cta19m00_040 from l_sql_stmt
 declare c_cta19m00_039 cursor for p_cta19m00_040

 let l_sql_stmt = ' select asitipdes, ',
                         ' asitipabvdes ',
                    ' from datkasitip ',
                   ' where asitipcod = ? '

 prepare p_cta19m00_041 from l_sql_stmt
 declare c_cta19m00_040 cursor for p_cta19m00_041

 let l_sql_stmt = ' select atddmccidnom, ',
                         ' atddmcufdcod, ',
                         ' asimtvcod, ',
                         ' trppfrdat, ',
                         ' trppfrhor ',
                    ' from datmassistpassag ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_042 from l_sql_stmt
 declare c_cta19m00_041 cursor for p_cta19m00_042

 let l_sql_stmt = ' select asimtvdes ',
                    ' from datkasimtv ',
                   ' where asimtvcod = ? '

 prepare p_cta19m00_043 from l_sql_stmt
 declare c_cta19m00_042 cursor for p_cta19m00_043

 let l_sql_stmt = ' select hpddiapvsqtd, ',
                         ' hpdqrtqtd ',
                    ' from datmhosped ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_044 from l_sql_stmt
 declare c_cta19m00_043 cursor for p_cta19m00_044

 let l_sql_stmt = ' select ustcod, ',
                         ' empcod, ',
                         ' usrtip, ',
                         ' funmat ',
                    ' from datkprtdst ',
                   ' where ramcod    = ? ',
                     ' and c24astcod = ? ',
                     ' and cvnnum    = ? ',
                     ' and c24prtseq = ? '

 prepare p_cta19m00_045 from l_sql_stmt
 declare c_cta19m00_044 cursor with hold for p_cta19m00_045

  let l_sql_stmt = ' select funnom ',
                    ' from isskfunc ',
                   ' where usrtip = ? ',
                     ' and empcod = ? ',
                     ' and funmat = ? '

 prepare p_cta19m00_046 from l_sql_stmt
 declare c_cta19m00_045 cursor for p_cta19m00_046

 let l_sql_stmt = ' select maicod ',
                    ' from datkprtextmai ',
                   ' where ramcod    = ? ',
                     ' and c24astcod = ? ',
                     ' and cvnnum    = ? ',
                     ' and c24prtseq = ? '

 prepare p_cta19m00_047 from l_sql_stmt
 declare c_cta19m00_046 cursor with hold for p_cta19m00_047

 let l_sql_stmt = ' select a.vclcoddig, ',
                         ' a.vclanofbc, ',
                         ' a.vclanomdl, ',
                         ' a.vcllicnum, ',
                         ' a.vclchsinc, ',
                         ' a.vclchsfnl ',
                    ' from abbmveic a ',
                   ' where a.succod    = ? ',
                     ' and a.aplnumdig = ? ',
                     ' and a.itmnumdig = ? ',
                     ' and a.dctnumseq = (select max(b.dctnumseq) ',
                                          ' from abbmveic b ',
                                         ' where a.succod    = b.succod ',
                                           ' and a.aplnumdig = b.aplnumdig ',
                                           ' and a.itmnumdig = b.itmnumdig ) '

 prepare p_cta19m00_049 from l_sql_stmt
 declare c_cta19m00_047 cursor for p_cta19m00_049

 let l_sql_stmt = ' update dammtrx ',
                     ' set c24msgtrxstt = ? ',
                   ' where c24trxnum = ? '

 prepare p_cta19m00_048 from l_sql_stmt

 let l_sql_stmt = ' select count(*) ',
                    ' from datmpassageiro ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_050 from l_sql_stmt
 declare c_cta19m00_048 cursor for p_cta19m00_050

 let l_sql_stmt = ' select sinavsnum, ',
                         ' sinavsano ',
                    ' from datrligsinavs ',
                   ' where lignum = ? '

 prepare p_cta19m00_051 from l_sql_stmt
 declare c_cta19m00_049 cursor for p_cta19m00_051

 let l_sql_stmt = ' select sinavsnum ',
                    ' from datrligtrp ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_052 from l_sql_stmt
 declare c_cta19m00_050 cursor for p_cta19m00_052

 let l_sql_stmt = ' select atddstcidnom, ',
                         ' atddstufdcod ',
                    ' from datmassistpassag ',
                   ' where atdsrvnum = ? ',
                     ' and atdsrvano = ? '

 prepare p_cta19m00_053 from l_sql_stmt
 declare c_cta19m00_051 cursor for p_cta19m00_053


 let l_sql_stmt = ' select cgccpfnum , ',
                  '        cgcord    , ',
                  '        cgccpfdig   ',
                  ' from datrligcgccpf ',
                  ' where lignum = ? '

 prepare p_cta19m00_054 from l_sql_stmt
 declare c_cta19m00_052 cursor for p_cta19m00_054

 let l_sql_stmt =  ' select flcnom '
                  ,' from datmfnrsrv '
                  ,' where atdsrvnum = ? '
                  ,' and   atdsrvano = ? '
 prepare p_cta19m00_055 from l_sql_stmt
 declare c_cta19m00_053 cursor for p_cta19m00_055

 let l_sql_stmt =  ' select a.lignum '
                  ,' from datmligacao a,'
                  ,'      datmservico b '
                  ,' where a.atdsrvnum = b.atdsrvnum '
                  ,' and   a.atdsrvano = b.atdsrvano '
                  ,' and   a.atdsrvnum = ? '
                  ,' and   a.atdsrvano = ? '
 prepare p_cta19m00_070 from l_sql_stmt
 declare c_cta19m00_070 cursor for p_cta19m00_070

 let l_sql_stmt =  ' select a.ligdat,   '
                  ,'        a.lighorinc '
                  ,' from datmligacao a,'
                  ,'      datmservico b '
                  ,' where a.atdsrvnum = b.atdsrvnum '
                  ,' and   a.atdsrvano = b.atdsrvano '
                  ,' and   a.atdsrvnum = ? '
                  ,' and   a.atdsrvano = ? '
 prepare p_cta19m00_071 from l_sql_stmt
 declare c_cta19m00_071 cursor for p_cta19m00_071

 let l_sql_stmt =  ' select a.ciaempcod '
                  ,' from datmligacao a,'
                  ,'      datmservico b '
                  ,' where a.atdsrvnum = b.atdsrvnum '
                  ,' and   a.atdsrvano = b.atdsrvano '
                  ,' and   a.atdsrvnum = ? '
                  ,' and   a.atdsrvano = ? '
 prepare p_cta19m00_072 from l_sql_stmt
 declare c_cta19m00_072 cursor for p_cta19m00_072

 let l_sql_stmt =  ' select atddat, '
                  ,'        atdhor  '
                  ,' from datmservico '
                  ,' where atdsrvnum = ? '
                  ,' and   atdsrvano = ? '
 prepare p_cta19m00_073 from l_sql_stmt
 declare c_cta19m00_073 cursor for p_cta19m00_073

 let l_sql_stmt =  ' select atddatprg, '
                  ,'        atdhorprg  '
                  ,' from datmservico '
                  ,' where atdsrvnum = ? '
                  ,' and   atdsrvano = ? '
 prepare p_cta19m00_074 from l_sql_stmt
 declare c_cta19m00_074 cursor for p_cta19m00_074

 let l_sql_stmt =  ' select atdprscod '
                  ,' from datmservico '
                  ,' where atdsrvnum = ? '
                  ,' and   atdsrvano = ? '
 prepare p_cta19m00_075 from l_sql_stmt
 declare c_cta19m00_075 cursor for p_cta19m00_075

 let l_sql_stmt =  ' select cgccpfnum ,'
                  ,'        cgcord    ,'
                  ,'        cgccpfdig  '
                  ,' from datrligcgccpf '
                  ,' where lignum = ?   '
 prepare p_cta19m00_076 from l_sql_stmt
 declare c_cta19m00_076 cursor for p_cta19m00_076

 let l_sql_stmt =  ' select pesnom '
                  ,' from gsakpes '
                  ,' where cgccpfnum  = ? '
                  ,' and   cgcord     = ? '
                  ,' and   cgccpfdig  = ? '
                  ,' and   pestip     = ? '
                  ,' order by pesnum '
 prepare p_cta19m00_077 from l_sql_stmt
 declare c_cta19m00_077 cursor for p_cta19m00_077


 let l_sql_stmt =   ' select lgdtip,      '
                   ,'        lgdnom,      '
                   ,'        lgdnum,      '
                   ,'        lclbrrnom,   '
                   ,'        brrnom,      '
                   ,'        cidnom,      '
                   ,'        ufdcod,      '
                   ,'        lclrefptotxt,'
                   ,'        endzon,      '
                   ,'        lgdcep,      '
                   ,'        lgdcepcmp,   '
                   ,'        dddcod,      '
                   ,'        lcltelnum,   '
                   ,'        lclcttnom,   '
                   ,'        lclltt,      '
                   ,'        lcllgt,      '
                   ,'        celteldddcod,'
                   ,'        celtelnum,   '
                   ,'        cmlteldddcod,'
                   ,'        cmltelnum,   '
                   ,'        endcmp       '
                   ,' from datmlcl        '
                   ,' where atdsrvnum = ? '
                   ,' and   atdsrvano = ? '
                   ,' and   c24endtip = 1 '
  prepare p_cta19m00_078 from l_sql_stmt
  declare c_cta19m00_078 cursor for p_cta19m00_078

  let l_sql_stmt =  ' select a.c24astagp,   '
                   ,'        a.c24astagpdes '
                   ,' from datkastagp  a, '
                   ,'      datkassunto b, '
                   ,'      datmligacao c  '
                   ,' where a.c24astagp = b.c24astagp '
                   ,' and   c.c24astcod = b.c24astcod '
                   ,' and   c.lignum    = ? '
  prepare p_cta19m00_079 from l_sql_stmt
  declare c_cta19m00_079 cursor for p_cta19m00_079

  let l_sql_stmt =  'select a.c24pbmcod,                       '
                   ,'       a.c24pbmdes                        '
                   ,' from datkpbm a,                          '
                   ,'      datrsrvpbm b                        '
                   ,' where a.c24pbmcod = b.c24pbmcod          '
                   ,' and b.atdsrvnum = ?                      '
                   ,' and b.atdsrvano = ?                      '
                   ,' and b.c24pbmseq = (select max(c24pbmseq) '
                   ,'                    from datrsrvpbm       '
                   ,'                    where atdsrvnum = ?   '
                   ,'                    and   atdsrvano = ?)  '
                   ,'                                          '
  prepare p_cta19m00_080 from l_sql_stmt
  declare c_cta19m00_080 cursor for p_cta19m00_080

  let l_sql_stmt =  ' select b.c24pbmgrpcod,                '
                   ,'        b.c24pbmgrpdes                 '
                   ,' from datkpbm a,                       '
                   ,'      datkpbmgrp b                     '
                   ,' where a.c24pbmgrpcod = b.c24pbmgrpcod '
                   ,' and   a.c24pbmcod = ?                 '
  prepare p_cta19m00_081 from l_sql_stmt
  declare c_cta19m00_081 cursor for p_cta19m00_081

  let l_sql_stmt =  ' select a.socntzgrpcod,                '
                   ,'        a.socntzgrpdes                 '
                   ,' from datksocntzgrp a,                 '
                   ,'      datksocntz b                     '
                   ,' where a.socntzgrpcod = b.socntzgrpcod '
                   ,' and   b.socntzcod = ?                 '
  prepare p_cta19m00_082 from l_sql_stmt
  declare c_cta19m00_082 cursor for p_cta19m00_082

  let l_sql_stmt =  ' select nomrazsoc  '
                   ,' from dpaksocor    '
                   ,' where pstcoddig = ? '
  prepare p_cta19m00_083 from l_sql_stmt
  declare c_cta19m00_083 cursor for p_cta19m00_083

  let l_sql_stmt =  ' select b.c24soltipcod, b.c24soltipdes  '
                   ,' from datmligacao a, '
                   ,' datksoltip b    '
                   ,' where a.c24soltipcod = b.c24soltipcod '
                   ,' and a.lignum = ? '
  prepare p_cta19m00_084 from l_sql_stmt
  declare c_cta19m00_084 cursor for p_cta19m00_084

  let l_sql_stmt =  ' select ligcvntip  '
                   ,' from datmligacao  '
                   ,' where lignum = ? '
  prepare p_cta19m00_085 from l_sql_stmt
  declare c_cta19m00_085 cursor for p_cta19m00_085

  let l_sql_stmt = " select rcuccsmtvdes "
                     ,"from datkrcuccsmtv "
                    ,"where rcuccsmtvstt = 'A' "
                      ,"and rcuccsmtvcod = ? "
                      ,"and c24astcod    = ? "
  prepare p_cta19m00_089 from l_sql_stmt
  declare c_cta19m00_089 cursor for p_cta19m00_089


 let m_prepara_sql = true

 end function

#----------------------------#
 function cta19m00_prepare2()
#----------------------------#

   define l_sql_stmt   char(800)

   let m_hostname = fun_dba_servidor("EMISAUTO")

   call figrc072_initGlbIsolamento()

   whenever error continue
   let l_sql_stmt = ' select segnumdig ',
                      ' from porto@',m_hostname clipped, ':apbmitem ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? '

   prepare p_cta19m00_056 from l_sql_stmt
   declare c_cta19m00_054 cursor for p_cta19m00_056
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00005"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select viginc, ',
                           ' vigfnl ',
                      ' from porto@',m_hostname clipped, ':apamcapa ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? '

   prepare p_cta19m00_057 from l_sql_stmt
   declare c_cta19m00_055 cursor for p_cta19m00_057
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00030"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select cbtcod ',
                      ' from porto@',m_hostname clipped, ':apbmcasco ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? '

   prepare p_cta19m00_058 from l_sql_stmt
   declare c_cta19m00_056 cursor for p_cta19m00_058
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00032"       ,
                                  "","","","","","")  then

      return
   end if

    whenever error continue
    let l_sql_stmt = ' select clscod, ',
                            ' viginc ',
                       ' from porto@',m_hostname clipped, ':apbmclaus ',
                      ' where prporgpcp = ? ',
                        ' and prpnumpcp = ? ',
                        ' and prporgidv = ? ',
                        ' and prpnumidv = ? '

    prepare p_cta19m00_059 from l_sql_stmt
    declare c_cta19m00_057 cursor with hold for p_cta19m00_059
    whenever error stop

    if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                   "cta19m00"           ,
                                   "cta19m00_prepare"   ,
                                   "ccta19m00035"       ,
                                   "","","","","","")  then

       return
    end if

   whenever error continue
   let l_sql_stmt = ' select frqvlr ',
                      ' from porto@',m_hostname clipped, ':apbmcasco ',
                      ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? '

   prepare p_cta19m00_060 from l_sql_stmt
   declare c_cta19m00_058 cursor for p_cta19m00_060
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00038"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select bonclacod, ',
                           ' clalclcod ',
                      ' from porto@',m_hostname clipped, ':apbmitem ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? '

   prepare p_cta19m00_061 from l_sql_stmt
   declare c_cta19m00_059 cursor for p_cta19m00_061
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00040"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select txtlin ',
                      ' from porto@',m_hostname clipped, ':apbmquesttxt ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? ',
                       ' and qstcod = 19 '

   prepare p_cta19m00_062 from l_sql_stmt
   declare c_cta19m00_060 cursor for p_cta19m00_062
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00043"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select clcdat ',
                      ' from porto@',m_hostname clipped, ':apbmcasco ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? '

   prepare p_cta19m00_063 from l_sql_stmt
   declare c_cta19m00_061 cursor for p_cta19m00_063
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00046"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select qstcod, ',
                           ' rspcod ',
                      ' from porto@',m_hostname clipped, ':apbmquestionario ',
                     ' where prporgpcp = ? ',
                       ' and prpnumpcp = ? ',
                       ' and prporgidv = ? ',
                       ' and prpnumidv = ? ',
                       ' and qstcod in (22,118,97,136,82,144) '

   prepare p_cta19m00_064 from l_sql_stmt
   declare c_cta19m00_062 cursor for p_cta19m00_064
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00048"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select cgccpfnum, ',
                           ' cgcord, ',
                           ' cgccpfdig ',
                      ' from ssamavs ',
                     ' where atdsrvnum = ? ',
                       ' and atdsrvano = ? '

   prepare p_cta19m00_065 from l_sql_stmt
   declare c_cta19m00_063 cursor for p_cta19m00_065
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00023"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = 'select sgrorg, ',
                          ' sgrnumdig ',
                     ' from rsamseguro ',
                     ' where succod    = ? ',
                       ' and ramcod    = ? ',
                       ' and aplnumdig = ? '

   prepare p_cta19m00_066 from l_sql_stmt
   declare c_cta19m00_064 cursor for p_cta19m00_066
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00006"       ,
                                  "","","","","","")  then

      return
   end if

   whenever error continue
   let l_sql_stmt = ' select segnumdig ',
                      ' from rsdmdocto ',
                     ' where sgrorg   = ? ',
                      ' and sgrnumdig = ? '

   prepare p_cta19m00_067 from l_sql_stmt
   declare c_cta19m00_065 cursor for p_cta19m00_067
   whenever error stop

   if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                  "cta19m00"           ,
                                  "cta19m00_prepare"   ,
                                  "ccta19m00007"       ,
                                  "","","","","","")  then

      return
   end if

   let m_prepara2_sql = true


end function

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
 function cta19m00 (l_ramcod, l_c24astcod, l_cvnnum, l_succod, l_aplnumdig, l_itmnumdig, l_lignum, l_atdsrvnum, l_atdsrvano, l_prporg, l_prpnumdig, l_solnom,l_rcuccsmtvcod )
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

 define l_ramcod           like datrservapol.ramcod,
        l_c24astcod        like datmligacao.c24astcod,
        l_cvnnum           like datkprtcpa.cvnnum,
        l_succod           like datrservapol.succod,
        l_aplnumdig        like datrservapol.aplnumdig,
        l_itmnumdig        like datrservapol.itmnumdig,
        l_lignum           like datrligsrv.lignum,
        l_atdsrvnum        like datmservico.atdsrvnum,
        l_atdsrvano        char(06),
        l_prporg           like apbmitem.prporgpcp,
        l_prpnumdig        like apbmitem.prpnumpcp,
        l_solnom           like datmligacao.c24solnom,
        l_rcuccsmtvcod     like datrligrcuccsmtv.rcuccsmtvcod

 define l_atdsrvorg        like datmservico.atdsrvorg

 define l_entrou           smallint

 define l_c24astdes        char(100),
        l_c24astpgrtxt     like datkassunto.c24astpgrtxt

 define l_atddstcidnom     like datmassistpassag.atddstcidnom,
        l_atddstufdcod     like datmassistpassag.atddstufdcod

 define l_vclmdlnom like agbkveic.vclmdlnom

 define l_segnom           like gsakseg.segnom,
        l_avialgmtv        like datmavisrent.avialgmtv,
        l_cpodes           like iddkdominio.cpodes,
        l_vclmrcnom        like agbkmarca.vclmrcnom,
        l_vcltipnom        like agbktip.vcltipnom,
        l_vclmrccod        like agbkmarca.vclmrccod,
        l_vcllicnum        like abbmveic.vcllicnum,
        l_vcldes           like datmservico.vcldes,
        l_lgdtip           like datmlcl.lgdtip,
        l_lgdnom           like datmlcl.lgdnom,
        l_lgdnum           like datmlcl.lgdnum,
        l_lclbrrnom        like datmlcl.lclbrrnom,
        l_brrnom           like datmlcl.brrnom,
        l_cidnom           like datmlcl.cidnom,
        l_ufdcod           like datmlcl.ufdcod,
        l_endzon           like datmlcl.endzon,
        l_lclrefptotxt     like datmlcl.lclrefptotxt,
        l_dddcod           like datmlcl.dddcod,
        l_lcltelnum        like datmlcl.lcltelnum,
        l_sindat           like datmservicocmp.sindat,
        l_sinhor           like datmservicocmp.sinhor,
        l_cgccpfnum        like gsakseg.cgccpfnum,
        l_cgcord           like gsakseg.cgcord,
        l_cgccpfdig        like gsakseg.cgccpfdig,
        l_segnumdig        like rsdmdocto.segnumdig,
        l_aviprvent        like datmavisrent.aviprvent,
        l_atddfttxt        like datmservico.atddfttxt,
        l_asitipcod        like datmservico.asitipcod,
        l_lclidttxt        like datmlcl.lclidttxt,
        l_socntzcod        like datmsrvre.socntzcod,
        l_socntzdes        like datksocntz.socntzdes,
        l_corsus           like abamcor.corsus,
        l_cornom           like gcakcorr.cornom,
        l_cbtcod           like abbmcasco.cbtcod,
        l_clscod           like abbmclaus.clscod,
        l_clscodant        like abbmclaus.clscod,
        l_tabnum           like aackcls.tabnum,
        l_clsdes           like aackcls.clsdes,
        l_frqvlr           like abbmcasco.frqvlr,
        l_bonclacod        like abbmdoc.bonclacod,
        l_clalclcod        like abbmdoc.clalclcod,
        l_txtlin           like abbmquesttxt.txtlin,
        l_bondscper        like acatbon.bondscper,
        l_clcdat           like abbmcasco.clcdat,
        l_qstcod           like abbmquestionario.qstcod,
        l_rspcod           like abbmquestionario.rspcod,
        l_qstrspdsc        like apqkdominio.qstrspdsc,
        l_srvnome          char(200),
        l_srvjustif        char(200),
        l_pasnom           like datmpassageiro.pasnom,
        l_pasidd           like datmpassageiro.pasidd,
        l_passeq           like datmpassageiro.passeq,
        l_slcemp           like datmavisrent.slcemp,
        l_slcsuccod        like datmavisrent.slcsuccod,
        l_slccctcod        like datmavisrent.slccctcod,
        l_cctnom           like ctokcentrosuc.cctnom,
        l_c24srvdsc        like datmservhist.c24srvdsc,
        l_ofnnumdig        like datmlcl.ofnnumdig,
        l_srvtipdes        like datksrvtip.srvtipdes,
        l_asitipdes        like datkasitip.asitipdes,
        l_asitipabvdes     like datkasitip.asitipabvdes,
        l_atddmccidnom     like datmassistpassag.atddmccidnom,
        l_atddmcufdcod     like datmassistpassag.atddmcufdcod,
        l_asimtvcod        like datmassistpassag.asimtvcod,
        l_asimtvdes        like datkasimtv.asimtvdes,
        l_trppfrdat        like datmassistpassag.trppfrdat,
        l_trppfrhor        like datmassistpassag.trppfrhor,
        l_hpddiapvsqtd     like datmhosped.hpddiapvsqtd,
        l_hpdqrtqtd        like datmhosped.hpdqrtqtd,
        l_ustcod           like datkprtdst.ustcod,
        l_empcod           like datkprtdst.empcod,
        l_usrtip           like datkprtdst.usrtip,
        l_funmat           like datkprtdst.funmat,
        l_funnom           like isskfunc.funnom,
        l_maicod           like datkprtextmai.maicod,
        l_lclcttnom        like datmlcl.lclcttnom,
        l_sinavsnum        like datrligtrp.sinavsnum,
        l_nome_falecido    like datmfnrsrv.flcnom,
        l_pesnom           like gsakpes.pesnom,
        l_pestip           like gsakpes.pestip,
        l_pesnum           like gsakpes.pesnum,
        l_psscntcod        like kspmcntrsm.psscntcod,
        l_pss              char(200)

 define l_arquivo          char(12)
 define l_c24ligdsc        like datmlighist.c24ligdsc
 define l_c24txtseq        like datmlighist.c24txtseq
 define l_soma             like datmservico.atdsrvano
 define l_c24prtinftip     like datkprtinftip.c24prtinftip,
        l_assunto          char(300),
        l_nr_servico       char(200),
        l_segurado         char(200),
        l_dados_docum      char(200),
        l_cartao           char(30),
        l_dat_atend        char(200),
        l_hora             char(200),
        l_atendente        char(200),
        l_matricula        char(50),
        l_empresa          char(50),
        l_chassi           char(20),
        l_ano_modelo       char(20),
        l_texto            char(200),
        l_nome_solicitante char(200),
        l_depto_atendente  char(200),
        l_historico_lig    char(200),
        l_motivo           char(200),
        l_corretor         char(200),
        l_tipo_modelo      char(200),
        l_chassi_ano       char(200),
        l_nome_veiculo     char(200),
        l_placa            char(200),
        l_endereco         char(200),
        l_bairro_cid       char(200),
        l_referencia       char(200),
        l_dat_hor_sinistro char(200),
        l_fone_contato     char(200),
        l_cgc_cpf          char(200),
        l_previsao         char(200),
        l_aux              smallint,
        l_flag             smallint,
        l_natureza         char(200),
        l_problema         char(200),
        l_cobertura        char(200),
        l_assistencia      char(200),
        l_vigencia         char(200),
        l_endereco_ocorr   char(200),
        l_local_destino    char(200),
        l_franquia         char(200),
        l_bonus            char(200),
        l_nome_condutor    char(200),
        l_relacao          char(200),
        l_cortesia1        char(200),
        l_cortesia2        char(200),
        l_nome_idade       char(200),
        l_centro_custos    char(200),
        l_oficina          char(200),
        l_laudo            char(200),
        l_count_pas        smallint,
        l_domicilio        char(200),
        l_cid_ocor         char(200),
        l_cid_dst          char(200),
        l_qtd_pas          char(200),
        l_data_pref        char(200),
        l_qtd_hosp         char(200),
        l_diarias          char(200),
        l_result           char(200),
        l_codigo_email     char(200),
        l_endereco_email   char(200),
        l_resplocal        char(200),
        l_aviso_sinistro   char(50),
        l_foreach          smallint,
        l_cont             smallint,
        l_c24astcod_aux    like datmligacao.c24astcod,
        l_cmd              char(500),
        l_plano            char(200),
        l_cgccpf           char(200),
        l_plncod           like datkplnsau.plncod,
        l_cntanvdat        like datksegsau.cntanvdat,
        l_plndes           like datkplnsau.plndes,
        l_plnatnlimnum     like datkplnsau.plnatnlimnum,
        l_resultado        smallint,
        l_msg              char(80),
        l_qtd_end          smallint,
        l_ind              smallint,
        l_aux_char         char(100),
        l_mensag           char(32000)

 define l_mensagem         record
     msg                   char(200)
    ,de                    char(50)
    ,para                  char(100)
    ,subject               char(100)
 end record

 define lr_segurado record
        nome        char(60),
        cgccpf      char(15),
        pessoa      char(01),
        dddfone     char(05),
        numfone     char(15),
        email       char(100)
 end record

 define lr_corretor record
        corsus     like gcaksusep.corsus,
        cornom     char(40),
        endcmp     like gcakfilial.endcmp,
        dddcod     like gcakfilial.dddcod,
        telnum     like gcakfilial.teltxt,
        dddfax     like gcakfilial.dddfax,
        telfax     like gcakfilial.factxt,
        email      like gcakfilial.maides
 end record

 define lr_ffpfc073 record
        cgccpfnum    char(12),
        cgcord       char(4) ,
        cgccpfdig    char(2) ,
        cgccpfnumdig char(18),
        cgccpf       char(20),
        erro         smallint,
        mens         char(50)
end record

define lr_psa record
       descricao    char(200)                       ,
       lignum       like datmligacao.lignum         ,
       ligdat       like datmligacao.ligdat         ,
       lighorinc    like datmligacao.lighorinc      ,
       ciaempcod    like datmligacao.ciaempcod      ,
       atddat       like datmservico.atddat         ,
       atdhor       like datmservico.atdhor         ,
       atddatprg    like datmservico.atddatprg      ,
       atdhorprg    like datmservico.atdhorprg      ,
       atdprscod    like datmservico.atdprscod      ,
       cgccpfnum    like datrligcgccpf.cgccpfnum    ,
       cgcord       like datrligcgccpf.cgcord       ,
       cgccpfdig    like datrligcgccpf.cgccpfdig    ,
       pestip       like gsakpes.pestip             ,
       pesnom       like gsakpes.pesnom             ,
       lgdtip       like datmlcl.lgdtip             ,
       lgdnom       like datmlcl.lgdnom             ,
       lgdnum       like datmlcl.lgdnum             ,
       lclbrrnom    like datmlcl.lclbrrnom          ,
       brrnom       like datmlcl.brrnom             ,
       cidnom       like datmlcl.cidnom             ,
       ufdcod       like datmlcl.ufdcod             ,
       lclrefptotxt like datmlcl.lclrefptotxt       ,
       endzon       like datmlcl.endzon             ,
       lgdcep       like datmlcl.lgdcep             ,
       lgdcepcmp    like datmlcl.lgdcepcmp          ,
       dddcod       like datmlcl.dddcod             ,
       lcltelnum    like datmlcl.lcltelnum          ,
       lclcttnom    like datmlcl.lclcttnom          ,
       lclltt       like datmlcl.lclltt             ,
       lcllgt       like datmlcl.lcllgt             ,
       celteldddcod like datmlcl.celteldddcod       ,
       celtelnum    like datmlcl.celtelnum          ,
       cmlteldddcod like datmlcl.cmlteldddcod       ,
       cmltelnum    like datmlcl.cmltelnum          ,
       endcmp       like datmlcl.endcmp             ,
       c24astagp    like datkastagp.c24astagp       ,
       c24astagpdes like datkastagp.c24astagpdes    ,
       c24pbmcod    like datkpbm.c24pbmcod          ,
       c24pbmdes    like datkpbm.c24pbmdes          ,
       c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod    ,
       c24pbmgrpdes like datkpbmgrp.c24pbmgrpdes    ,
       socntzgrpcod like datksocntzgrp.socntzgrpcod ,
       socntzgrpdes like datksocntzgrp.socntzgrpdes ,
       nomrazsoc    like dpaksocor.nomrazsoc        ,
       c24soltipdes like datksoltip.c24soltipdes    ,
       c24soltipcod like datksoltip.c24soltipcod    ,
       ligcvntip    like datmligacao.ligcvntip
end record


define l_ret smallint

 initialize lr_segurado.* to null
 initialize lr_corretor.* to null
 initialize lr_ffpfc073.* to null
 initialize lr_psa.*      to null

 let m_flag = false
 let l_entrou = false
 let m_status_xml = null
 let l_ret = false

 let l_plano        = null
 let l_plncod       = null
 let l_cntanvdat    = null
 let l_plndes       = null
 let l_plnatnlimnum = null
 let l_qtd_end      = null
 let l_ind          = null
 let l_aux_char     = null
 let l_pestip       = null
 let l_pesnom       = null
 let l_pesnum       = null
 let l_psscntcod    = null
 let l_pss          = null

 if m_prepara_sql is null or
    m_prepara_sql <> true then
    call cta19m00_prepare()
 end if



 if l_atdsrvnum is null and
    l_lignum    is not null then

    open c_cta19m00_049 using l_lignum

    whenever error continue
    fetch c_cta19m00_049 into l_atdsrvnum, l_atdsrvano
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
       else
          let m_flag  = true
          return m_flag
       end if
    end if
    let  l_atdsrvano =  l_atdsrvano[3,4]
 end if

 let mr_param.ramcod     = l_ramcod
 let mr_param.c24astcod  = l_c24astcod
 let mr_param.cvnnum     = l_cvnnum
 let mr_param.succod     = l_succod
 let mr_param.aplnumdig  = l_aplnumdig
 let mr_param.itmnumdig  = l_itmnumdig
 let mr_param.lignum     = l_lignum
 let mr_param.atdsrvnum  = l_atdsrvnum
 let mr_param.atdsrvano  = l_atdsrvano
 let mr_param.prporg     = l_prporg
 let mr_param.prpnumdig  = l_prpnumdig
 let mr_param.solnom     = l_solnom


 initialize l_assunto,          l_nr_servico,       l_segurado,        l_dados_docum,
            l_segnom,           l_dat_atend,        l_hora,            l_atendente,
            l_chassi,           l_ano_modelo,       l_sinavsnum,       l_texto,
            l_nome_solicitante, l_depto_atendente,  l_historico_lig,   l_motivo,
            l_corretor,         l_tipo_modelo,      l_chassi_ano,      l_nome_veiculo,
            l_placa,            l_endereco,         l_bairro_cid,      l_referencia,
            l_dat_hor_sinistro, l_fone_contato,     l_cgc_cpf,         l_previsao,
            l_natureza,         l_problema,         l_cobertura,       l_assistencia,
            l_vigencia,         l_endereco_ocorr,   l_local_destino,   l_franquia,
            l_bonus,            l_nome_condutor,    l_relacao,         l_cortesia1,
            l_cortesia2,        l_nome_idade,       l_centro_custos,   l_oficina,
            l_laudo,            l_domicilio,        l_cid_ocor,        l_cid_dst,
            l_qtd_pas,          l_data_pref,        l_qtd_hosp,        l_diarias,
            l_result,           l_codigo_email,     l_endereco_email,  m_titulo,
            l_srvnome,          l_srvjustif,        l_atdsrvorg,       l_c24astpgrtxt,
            l_avialgmtv,        l_cpodes,           l_vclmrcnom,       l_vcltipnom,
            l_vclmrccod,        l_vcllicnum,        l_vcldes,          l_lgdtip,
            l_lgdnom,           l_lgdnum,           l_lclbrrnom,       l_brrnom,
            l_cidnom,           l_ufdcod,           l_endzon,          l_lclrefptotxt,
            l_dddcod,           l_lcltelnum,        l_sindat,          l_sinhor,
            l_cgccpfnum,        l_cgcord,           l_cgccpfdig,       l_segnumdig,
            l_aviprvent,        l_atddfttxt,        l_asitipcod,       l_lclidttxt,
            l_socntzcod,        l_socntzdes,        l_corsus,          l_cornom,
            l_cbtcod,           l_clscod,           l_tabnum,          l_clsdes,
            l_frqvlr,           l_clscodant,         l_bonclacod,      l_clalclcod,
            l_txtlin,           l_matricula,        l_empresa,         l_arquivo,
            l_bondscper,        l_clcdat,           l_qstcod,          l_rspcod,
            l_qstrspdsc,        l_srvnome,          l_srvjustif,       l_pasnom,
            l_pasidd,           l_passeq,           l_slcemp,          l_slcsuccod,
            l_slccctcod,        l_cctnom,           l_c24srvdsc,       l_ofnnumdig,
            l_srvtipdes,        l_asitipdes,        l_asitipabvdes,    l_atddmccidnom,
            l_atddmcufdcod,     l_asimtvcod,        l_asimtvdes,       l_trppfrdat,
            l_trppfrhor,        l_hpddiapvsqtd,     l_hpdqrtqtd,       l_ustcod,
            l_empcod,           l_usrtip,           l_funmat,          l_funnom,
            l_maicod,           l_c24astdes,        l_mensag,          l_cgccpf,
            l_c24ligdsc,        l_c24txtseq,        l_soma,
            l_c24prtinftip,     l_aviso_sinistro,   l_lclcttnom,
            l_resplocal,        m_grupo,
            m_ciaempcod,        m_doc_handle  ,     l_nome_falecido to null

 initialize m_datkprtcpa.*,m_c24trxnum, m_crtsaunum, m_status, m_msg to null

 call cts11g00_verifica_formulario(g_documento.lignum)
      returning l_ret
 if l_ret = true then
    let m_flag = true
    return m_flag
 end if

 call cts10g13_grava_rastreamento(l_lignum                           ,
                                  '1'                                ,
                                  'cta19m00'                         ,
                                  '1'                                ,
                                  '1- Verificando Envio Pager/Email' ,
                                  ' '                                )
if mr_param.atdsrvnum is null and
   mr_param.atdsrvano is null then
       call ctd06g00_ligacao_emp(1,l_lignum)
            returning m_status ,
                      m_msg    ,
                      m_ciaempcod
else
 open c_cta19m00_010 using mr_param.atdsrvnum,
                         mr_param.atdsrvano
 whenever error continue
 fetch c_cta19m00_010 into l_vcldes,
                         l_atdsrvorg,
                         l_vcllicnum,
                         l_atddfttxt,
                         l_asitipcod,
                         m_ciaempcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
    else
        call cts10g13_grava_rastreamento(l_lignum                    ,
                                         '1'                         ,
                                         'cta19m00'                  ,
                                         '1'                         ,
                                         '2- Servico Não Localizado' ,
                                         ' '                         )
       let m_flag  = true
       return m_flag
    end if
 end if
end if

 if m_ciaempcod = 35 and
    mr_param.aplnumdig is not null then
    call cts42g00_doc_handle(mr_param.succod, mr_param.ramcod,
                             mr_param.aplnumdig, mr_param.itmnumdig,
                             g_documento.edsnumref)
         returning m_status_xml, m_msg, m_doc_handle
    if m_status_xml = 1 then
       call cts40g02_extraiDoXML(m_doc_handle, "SEGURADO")
            returning lr_segurado.nome,
                      lr_segurado.cgccpf,
                      lr_segurado.pessoa,
                      lr_segurado.dddfone,
                      lr_segurado.numfone,
                      lr_segurado.email
    end if
 end if

 if m_ciaempcod = 40 then
      open c_cta19m00_052 using mr_param.lignum
      fetch c_cta19m00_052 into lr_ffpfc073.cgccpfnum,
                              lr_ffpfc073.cgcord   ,
                              lr_ffpfc073.cgccpfdig

      let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum,
                                                             lr_ffpfc073.cgcord   ,
                                                             lr_ffpfc073.cgccpfdig)
  end if

 let mr_param.atdsrvorg = l_atdsrvorg

 open c_cta19m00_001 using mr_param.ramcod,
                         mr_param.c24astcod,
                         mr_param.cvnnum

 foreach c_cta19m00_001 into m_datkprtcpa.ramcod,
                           m_datkprtcpa.c24astcod,
                           m_datkprtcpa.cvnnum,
                           m_datkprtcpa.c24prtseq,
                           m_datkprtcpa.c24prtsit,
                           m_datkprtcpa.caddat,
                           m_datkprtcpa.cadhor,
                           m_datkprtcpa.cadmat,
                           m_datkprtcpa.cadusrtip,
                           m_datkprtcpa.cademp

    call cty10g00_grupo_ramo(g_issk.empcod, m_datkprtcpa.ramcod)
      returning m_status, m_msg, m_grupo

    let l_entrou = true

    if m_grupo = 5 then
       call cts20g10_cartao(1, mr_param.atdsrvnum, mr_param.atdsrvano)
            returning l_resultado, l_msg, m_crtsaunum
    else
       if m_ciaempcod = 1 then
          initialize g_funapol.* to null

          if mr_param.aplnumdig is not null then
             call f_funapol_ultima_situacao(mr_param.succod,
                                            mr_param.aplnumdig,
                                            mr_param.itmnumdig)
                           returning g_funapol.*
          end if
       end if
    end if

    open c_cta19m00_002 using mr_param.c24astcod

    whenever error continue
    fetch c_cta19m00_002 into l_c24astdes,
                            l_c24astpgrtxt
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
       else
          let m_flag  = true
          exit foreach
       end if
    end if

    let m_titulo = mr_param.c24astcod clipped, "-", l_c24astdes clipped

  call ctx14g00_msg(9999, mr_param.lignum, mr_param.atdsrvnum, mr_param.atdsrvano, m_titulo)
             returning m_c24trxnum
    let l_foreach = false

    open c_cta19m00_003 using m_datkprtcpa.ramcod,
                            m_datkprtcpa.c24astcod,
                            m_datkprtcpa.cvnnum,
                            m_datkprtcpa.c24prtseq

    foreach c_cta19m00_003 into l_c24prtinftip

     case l_c24prtinftip

       when 1
          initialize l_assunto to null

            open c_cta19m00_089 using l_rcuccsmtvcod,
                                      l_c24astcod
             fetch c_cta19m00_089 into l_c24astdes
             close c_cta19m00_089

          let l_assunto = "Assunto: ", l_c24astcod clipped, "-", l_c24astdes clipped

          if l_c24astcod is not null or
             l_c24astdes is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_assunto)
          end if

       when 2
          initialize l_nr_servico to null
          let l_nr_servico = "Nr. do Servico: "

             let l_nr_servico=  l_nr_servico clipped, mr_param.atdsrvorg, "/"

          let l_nr_servico=  l_nr_servico clipped," ",mr_param.atdsrvnum using "&&&&&&&&","-", mr_param.atdsrvano using "<<&&"


             call ctx14g00_msgtxt(m_c24trxnum,l_nr_servico)

       when 3

          initialize l_segnom, l_segurado to null

          if m_ciaempcod = 1  or
             m_ciaempcod = 50 then
             call cta19m00_segurado() returning l_segnom
          end if

          if m_ciaempcod = 35 then
             let l_segnom = lr_segurado.nome
          end if

          if m_ciaempcod = 84 then
             let l_segnom = g_doc_itau[1].segnom
          end if

          if m_ciaempcod = 40 then
             call ffpfc073_rec_prop(lr_ffpfc073.cgccpfnumdig,"F")
             returning lr_ffpfc073.erro,
                       lr_ffpfc073.mens,
                       l_segnom

             if lr_ffpfc073.erro <> 0 then
                 error lr_ffpfc073.mens sleep 2
             end if

          end if

          let l_segurado = "Segurado: ",l_segnom clipped

          if l_segnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_segurado)
          end if

       when 4
          initialize l_dados_docum to null
          if m_crtsaunum is not null then
             let l_cartao = null
             call cts20g16_formata_cartao(m_crtsaunum)
                  returning l_cartao
             let l_dados_docum = "CARTAO: ", l_cartao clipped
          else
             if mr_param.aplnumdig is not null then
                if m_ciaempcod = 84 then
                   let l_dados_docum = "APL: ", g_documento.itaciacod using "&&", "/" ,
                                                mr_param.succod using "<<<<<"   , "/" ,
                                                mr_param.ramcod using "<<<<"    , "/" ,
                                                mr_param.aplnumdig using "<<<<<<<<&&"
                else
                   let l_dados_docum = "APL: ", mr_param.succod using "<<<<<",#"<<"," ", projeto succod
                                                mr_param.ramcod using "<<<<"," ",
                                                mr_param.aplnumdig using "<<<<<<<<&&"
                   end if
             end if
             if mr_param.prpnumdig is not null then
                let l_dados_docum = "PRP: ", mr_param.prporg using "<<","/",mr_param.prpnumdig using "<<<<<<<<<<"
             end if
          end if

          if mr_param.aplnumdig is not null or
             mr_param.prpnumdig is not null or
             m_crtsaunum is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_dados_docum)
          end if

       when 5
          initialize l_dat_atend to null
          let l_dat_atend = "Data: ", today
          call ctx14g00_msgtxt(m_c24trxnum, l_dat_atend)
       when 6
          initialize l_hora to null
          let l_hora = "Hora: ", time
          call ctx14g00_msgtxt(m_c24trxnum, l_hora)
       when 7
          initialize l_atendente to null
          let l_atendente = "Atendente: ", g_issk.funnom
          if g_issk.funnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_atendente)
          end if
          let l_atendente = "Matricula: ", g_issk.funmat
          if g_issk.funnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_atendente)
          end if
          let l_atendente = "Empresa do Funcionario: ", g_issk.empcod
          if g_issk.funnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_atendente)
          end if

       when 8
          open c_cta19m00_016 using mr_param.lignum
          let l_cont = 1
          initialize l_c24ligdsc, l_c24txtseq, l_historico_lig to null

          foreach c_cta19m00_016 into l_c24ligdsc,
                                    l_c24txtseq
             if l_cont = 1 then
                let l_historico_lig = "Historico:", l_c24ligdsc
                call ctx14g00_msgtxt(m_c24trxnum, l_historico_lig)
                let l_cont = l_cont + 1
             else
                if l_c24ligdsc is not null then
                   call ctx14g00_msgtxt(m_c24trxnum,l_c24ligdsc)
                end if
             end if
          end foreach
       when 9
          initialize l_nome_solicitante to null
          let l_nome_solicitante = "Solicitante: ", mr_param.solnom clipped

          if mr_param.solnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_nome_solicitante)
          end if
       when 10
          initialize l_depto_atendente to null
          let l_depto_atendente = "Depto: ", g_issk.dptsgl

          if g_issk.dptsgl is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_depto_atendente)
          end if
       when 11
          initialize l_c24astdes, l_c24astpgrtxt, l_historico_lig to null
          open c_cta19m00_002 using mr_param.c24astcod

          whenever error continue
          fetch c_cta19m00_002 into l_c24astdes,
                                  l_c24astpgrtxt
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          if l_c24astpgrtxt[1,80] is not null then
             let l_historico_lig = "Historico: ",l_c24astpgrtxt[1,80]
             call ctx14g00_msgtxt(m_c24trxnum,l_historico_lig)
          end if
          if l_c24astpgrtxt[81,160] is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_c24astpgrtxt[81,160])
          end if
          if l_c24astpgrtxt[161,200] is not null then
             call ctx14g00_msgtxt(m_c24trxnum,l_c24astpgrtxt[161,200])
          end if
       when 12
          initialize l_avialgmtv, l_cpodes, l_texto, l_motivo to null
          call cta19m00_motivo_aluguel(mr_param.atdsrvnum,mr_param.atdsrvano,mr_param.c24astcod,
                                      m_datkprtcpa.c24prtseq,mr_param.succod)
                          returning l_flag, l_avialgmtv, l_cpodes, l_texto

          let l_motivo = "Motivo: ", l_avialgmtv clipped," ",l_cpodes clipped," ",l_texto clipped

          if l_avialgmtv is not null or
             l_cpodes    is not null or
             l_texto     is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_motivo)
          end if

       when 13
          initialize l_vclmrcnom,  l_vcltipnom, l_vclmdlnom, l_chassi,
                     l_ano_modelo, l_vcllicnum, l_vcldes,    l_tipo_modelo,
                     l_chassi_ano to null

          call cta19m00_veiculo()
                 returning l_vclmrcnom, l_vcltipnom,  l_vclmdlnom,
                           l_chassi,    l_ano_modelo, l_vcllicnum, l_vcldes

          let l_tipo_modelo = "Tipo:", l_vcltipnom clipped," Modelo: ",l_vclmdlnom

          if m_ciaempcod = 35 then
             let l_tipo_modelo = "Modelo: ",l_vclmdlnom clipped
             call ctx14g00_msgtxt(m_c24trxnum, l_tipo_modelo)
          else
		          if l_vcltipnom is not null or
		             l_vclmrccod is not null then
		             call ctx14g00_msgtxt(m_c24trxnum, l_tipo_modelo)
		          end if
          end if
          let l_chassi_ano = "Chassi:", l_chassi clipped," Ano/Modelo: ", l_ano_modelo clipped

          if l_chassi     is not null or
             l_ano_modelo is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_chassi_ano)
          end if
       when 14
          initialize l_vclmrcnom,  l_vcltipnom, l_vclmdlnom, l_chassi,
                     l_ano_modelo, l_vcllicnum, l_vcldes, l_nome_veiculo to null



          call cta19m00_veiculo()
                 returning l_vclmrcnom, l_vcltipnom,  l_vclmdlnom,
                           l_chassi,    l_ano_modelo, l_vcllicnum, l_vcldes

          if l_vcldes is not null then
             let l_nome_veiculo = "Veiculo: ", l_vcldes clipped
          else
             let l_nome_veiculo = "Veiculo: ", l_vclmrcnom clipped," ",l_vcltipnom clipped," ",l_vclmdlnom
          end if

          if l_vclmrcnom is not null or
             l_vcltipnom is not null or
             l_vclmrccod is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_nome_veiculo)
          end if
       when 15
          initialize l_vclmrcnom,  l_vcltipnom, l_vclmdlnom, l_chassi,
                     l_ano_modelo, l_vcllicnum, l_vcldes,    l_atdsrvorg,
                     l_atddfttxt,  l_asitipcod, l_placa to null

          if mr_param.atdsrvnum is not null and
             mr_param.atdsrvnum <> 0 then
             open c_cta19m00_010 using mr_param.atdsrvnum,
                                     mr_param.atdsrvano

             whenever error continue
             fetch c_cta19m00_010 into l_vcldes,
                                     l_atdsrvorg,
                                     l_vcllicnum,
                                     l_atddfttxt,
                                     l_asitipcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          end if
          if mr_param.atdsrvnum is null or
             mr_param.atdsrvnum = 0 then
             call cta19m00_veiculo()
                returning l_vclmrcnom, l_vcltipnom,  l_vclmdlnom,
                          l_chassi,    l_ano_modelo, l_vcllicnum, l_vcldes
          end if


          let l_placa = "Placa: ", l_vcllicnum

          if l_vcllicnum is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_placa)
          end if

       when 16
          initialize l_lgdtip,       l_lgdnom,     l_lgdnum,    l_lclbrrnom,
                     l_brrnom,       l_cidnom,     l_ufdcod,    l_endzon,
                     l_lclrefptotxt, l_dddcod,     l_lcltelnum, l_lclidttxt,
                     l_ofnnumdig,    l_referencia, l_endereco,  l_bairro_cid,
                     l_lclcttnom   to null

          let l_aux = 1
          open c_cta19m00_017 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano,
                                  l_aux

          whenever error continue
          fetch c_cta19m00_017 into l_lgdtip,
                                  l_lgdnom,
                                  l_lgdnum,
                                  l_lclbrrnom,
                                  l_brrnom,
                                  l_cidnom,
                                  l_ufdcod,
                                  l_endzon,
                                  l_lclrefptotxt,
                                  l_dddcod,
                                  l_lcltelnum,
                                  l_lclidttxt,
                                  l_ofnnumdig,
                                  l_lclcttnom
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_endereco = "Endereco: ", l_lgdtip," ",l_lgdnom clipped," ", l_lgdnum clipped

          if l_lgdtip is not null or
             l_lgdnom is not null or
             l_lgdnum is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_endereco)
          end if
          call cts06g10_monta_brr_subbrr(l_brrnom,
                                         l_lclbrrnom)
               returning l_brrnom
          let l_bairro_cid = "Bairro: ",l_brrnom clipped," Cidade: ",l_cidnom clipped," ",l_ufdcod," Zona: ",l_endzon clipped

          if l_brrnom is not null or
             l_cidnom is not null or
             l_ufdcod is not null or
             l_endzon is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_bairro_cid)
          end if

          let l_resplocal  = "Resp Local : ",l_lclcttnom clipped

          if l_lclcttnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_resplocal)
          end if

          let l_referencia = "Ref: ",l_lclrefptotxt

          if l_lclrefptotxt is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_referencia)
          end if

       when 17
          initialize l_sindat, l_sinhor, l_dat_hor_sinistro to null
          open c_cta19m00_018 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_018 into l_sindat,
                                  l_sinhor
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_dat_hor_sinistro = "Data/Hora Sinistro : ", l_sindat," ",l_sinhor

          if l_sindat is not null or
             l_sinhor is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_dat_hor_sinistro)
          end if

       when 18
          initialize l_lgdtip,       l_lgdnom, l_lgdnum,    l_lclbrrnom,
                     l_brrnom,       l_cidnom, l_ufdcod,    l_endzon,
                     l_lclrefptotxt, l_dddcod, l_lcltelnum, l_lclidttxt,
                     l_ofnnumdig,    l_fone_contato to null

          let l_aux = 1
          open c_cta19m00_017 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano,
                                  l_aux

          whenever error continue
          fetch c_cta19m00_017 into l_lgdtip,
                                  l_lgdnom,
                                  l_lgdnum,
                                  l_lclbrrnom,
                                  l_brrnom,
                                  l_cidnom,
                                  l_ufdcod,
                                  l_endzon,
                                  l_lclrefptotxt,
                                  l_dddcod,
                                  l_lcltelnum,
                                  l_lclidttxt,
                                  l_ofnnumdig
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          if m_ciaempcod = 40 then
             call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,"F")
             returning l_dddcod        ,
                       l_lcltelnum     ,
                       lr_ffpfc073.erro,
                       lr_ffpfc073.mens


             if lr_ffpfc073.erro <> 0 then
                 error lr_ffpfc073.mens sleep 2
             end if

          end if

          let l_fone_contato = "Tel.Contato : ", l_dddcod," ",l_lcltelnum

          if l_dddcod is not null or
             l_lcltelnum is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_fone_contato)
          end if

       when 19
          initialize l_soma, l_cgccpfnum, l_cgcord, l_cgccpfdig, l_segnumdig,
                     l_segnom, l_cgc_cpf to null

          if mr_param.atdsrvano > 50 then
             let l_soma = mr_param.atdsrvano + 1900
          else
             let l_soma = mr_param.atdsrvano + 2000
          end if

          if m_prepara2_sql is null or
             m_prepara2_sql <> true then
             call cta19m00_prepare2()

             if figrc072_getErro() then
                   return m_flag
             end if

          end if

          open c_cta19m00_063 using mr_param.atdsrvnum,
                                  l_soma

          whenever error continue
          fetch c_cta19m00_063 into l_cgccpfnum,
                                  l_cgcord,
                                  l_cgccpfdig
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
                open c_cta19m00_004 using mr_param.succod,
                                        mr_param.aplnumdig,
                                        mr_param.itmnumdig,
                                        g_funapol.dctnumseq

                whenever error continue
                fetch c_cta19m00_004 into l_segnumdig
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
                open c_cta19m00_005 using l_segnumdig

                whenever error continue
                fetch c_cta19m00_005 into l_segnom,
                                        l_cgccpfnum,
                                        l_cgcord,
                                        l_cgccpfdig
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_cgc_cpf = "Cpf/Cnpj : ", l_cgccpfnum ,"-",l_cgccpfdig

          if l_cgccpfnum is not null or
             l_cgccpfdig is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_cgc_cpf)
          end if

       when 20
          initialize l_aviprvent, l_previsao to null
          open c_cta19m00_019 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_019 into l_aviprvent
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_previsao = "Previsao de : ", l_aviprvent," dia(s) de utilizacao"

          if l_aviprvent is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_previsao)
          end if

       when 21
          initialize l_natureza, l_socntzcod, l_socntzdes  to null
          open c_cta19m00_020 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_020 into l_socntzcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if
          open c_cta19m00_021 using l_socntzcod

          whenever error continue
          fetch c_cta19m00_021 into l_socntzdes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_natureza = "Natureza: ", l_socntzcod, " - ", l_socntzdes

          if l_socntzdes is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_natureza)
          end if

       when 22
          initialize l_problema, l_vcldes, l_atdsrvorg, l_vcllicnum, l_atddfttxt, l_asitipcod to null

          open c_cta19m00_010 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_010 into l_vcldes,
                                  l_atdsrvorg,
                                  l_vcllicnum,
                                  l_atddfttxt,
                                  l_asitipcod
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_problema = "Tipo Problema: ",l_atddfttxt

          if l_atddfttxt is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_problema)
          end if

       when 23
          initialize l_vcldes,    l_atdsrvorg, l_vcllicnum, l_atddfttxt,
                     l_asitipcod, l_asitipdes, l_asitipabvdes, l_assistencia to null
          open c_cta19m00_010 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_010 into l_vcldes,
                                  l_atdsrvorg,
                                  l_vcllicnum,
                                  l_atddfttxt,
                                  l_asitipcod
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          open c_cta19m00_040 using l_asitipcod

          whenever error continue
          fetch c_cta19m00_040 into l_asitipdes,
                                  l_asitipabvdes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_assistencia = "Tipo Assistencia: ",l_asitipabvdes

          if l_asitipcod is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_assistencia)
          end if

       when 24
          initialize l_lgdtip,       l_lgdnom, l_lgdnum,    l_lclbrrnom,
                     l_brrnom,       l_cidnom, l_ufdcod,    l_endzon,
                     l_lclrefptotxt, l_dddcod, l_lcltelnum, l_lclidttxt,
                     l_ofnnumdig, l_endereco_ocorr, l_bairro_cid to null

          let l_aux = 1
          open c_cta19m00_017 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano,
                                  l_aux

          whenever error continue
          fetch c_cta19m00_017 into l_lgdtip,
                                  l_lgdnom,
                                  l_lgdnum,
                                  l_lclbrrnom,
                                  l_brrnom,
                                  l_cidnom,
                                  l_ufdcod,
                                  l_endzon,
                                  l_lclrefptotxt,
                                  l_dddcod,
                                  l_lcltelnum,
                                  l_lclidttxt,
                                  l_ofnnumdig
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_endereco_ocorr = "Endereco Ocorr: ", l_lgdtip," ",l_lgdnom clipped," ", l_lgdnum

          if l_lgdtip is not null or
             l_lgdnom is not null or
             l_lgdnum is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_endereco_ocorr)
          end if

          call cts06g10_monta_brr_subbrr(l_brrnom,
                                         l_lclbrrnom)
               returning l_brrnom
          let l_bairro_cid = "Bairro: ",l_brrnom clipped," Cidade: ",l_cidnom clipped," ",l_ufdcod," Zona: ",l_endzon clipped

          if l_brrnom is not null or
             l_cidnom is not null or
             l_ufdcod is not null or
             l_endzon is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_bairro_cid)
          end if

       when 25
          initialize l_lgdtip,       l_lgdnom, l_lgdnum,    l_lclbrrnom,
                     l_brrnom,       l_cidnom, l_ufdcod,    l_endzon,
                     l_lclrefptotxt, l_dddcod, l_lcltelnum, l_lclidttxt,
                     l_ofnnumdig,    l_local_destino,       l_endereco,
                     l_bairro_cid to null

          let l_aux = 2
          open c_cta19m00_017 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano,
                                  l_aux

          whenever error continue
          fetch c_cta19m00_017 into l_lgdtip,
                                  l_lgdnom,
                                  l_lgdnum,
                                  l_lclbrrnom,
                                  l_brrnom,
                                  l_cidnom,
                                  l_ufdcod,
                                  l_endzon,
                                  l_lclrefptotxt,
                                  l_dddcod,
                                  l_lcltelnum,
                                  l_lclidttxt,
                                  l_ofnnumdig
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_local_destino = "Local Detino: ", l_lclidttxt

          if l_lclidttxt is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_local_destino)
          end if

          let l_endereco = "Endereco Dest.: ", l_lgdtip," ",l_lgdnom clipped," ", l_lgdnum

          if l_lgdtip is not null or
             l_lgdnom is not null or
             l_lgdnum is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_endereco)
          end if

          let l_bairro_cid = "Bairro: ",l_brrnom clipped," Cidade: ",l_cidnom clipped," ",l_ufdcod," Zona: ",l_endzon

          if l_brrnom is not null or
             l_cidnom is not null or
             l_ufdcod is not null or
             l_endzon is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_bairro_cid)
          end if

       when 26
          initialize l_corretor, l_corsus, l_cornom to null


          if m_crtsaunum is not null then
             call cta01m15_sel_datksegsau (2, m_crtsaunum, "","","")
                  returning m_status, m_msg, l_corsus, l_cornom
          else

             if m_ciaempcod = 1  or
                m_ciaempcod = 50 then
                open c_cta19m00_022 using mr_param.succod,
                                        mr_param.aplnumdig

                whenever error continue
                fetch c_cta19m00_022 into l_corsus
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
                open c_cta19m00_023 using l_corsus

                whenever error continue
                fetch c_cta19m00_023 into l_cornom
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
             else
                if m_ciaempcod = 35 then
                   if m_status_xml = 1 then
                      call cts40g02_extraiDoXML(m_doc_handle, "CORRETOR")
                           returning lr_corretor.corsus,
                                     lr_corretor.cornom,
                                     lr_corretor.dddcod,
                                     lr_corretor.telnum,
                                     lr_corretor.dddfax,
                                     lr_corretor.telfax,
                                     lr_corretor.email

                      let l_corsus = lr_corretor.corsus
                      let l_cornom = lr_corretor.cornom
                   end if
                end if

                if m_ciaempcod = 84 then
                   let l_corsus = g_doc_itau[1].corsus
                   let l_cornom = cty22g00_busca_nome_corretor()
                end if

                if m_ciaempcod = 40 then
                   call ffpfc073_rec_susep(lr_ffpfc073.cgccpfnumdig,"F")
                   returning l_corsus        ,
                             lr_ffpfc073.erro,
                             lr_ffpfc073.mens


                   if lr_ffpfc073.erro <> 0 then
                       error lr_ffpfc073.mens sleep 2
                   else
                       open c_cta19m00_023 using l_corsus

                       whenever error continue
                       fetch c_cta19m00_023 into l_cornom
                       whenever error stop
                       if sqlca.sqlcode <> 0 then
                          if sqlca.sqlcode = 100 then
                          else
                             let m_flag  = true
                             let l_foreach = true
                             exit foreach
                          end if
                       end if
                   end if
                end if
             end if
          end if

          let l_corretor = "Corretor: ",l_corsus clipped," ",l_cornom

          if l_corsus is not null or
             l_cornom is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_corretor)
          end if

       when 27
          initialize m_viginc, m_vigfnl, l_vigencia to null

          if m_ciaempcod = 1  or
             m_ciaempcod = 50 then
             if mr_param.aplnumdig is not null then
                open c_cta19m00_024 using mr_param.succod,
                                        mr_param.aplnumdig

                whenever error continue
                fetch c_cta19m00_024 into m_viginc,
                                        m_vigfnl
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
             else

                if m_prepara2_sql is null or
                   m_prepara2_sql <> true then
                   call cta19m00_prepare2()

                   if figrc072_getErro() then
                         return m_flag
                   end if

                end if

                open c_cta19m00_055 using mr_param.prporg,
                                        mr_param.prpnumdig

                whenever error continue
                fetch c_cta19m00_055 into m_viginc,
                                        m_vigfnl
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
             end if

          else

             if m_ciaempcod = 35 then
                if m_status_xml = 1 then
                   call cts40g02_extraiDoXML(m_doc_handle, "APOLICE_VIGENCIA")
                        returning m_viginc,
                                  m_vigfnl
                end if
             end if

             if m_ciaempcod = 84 then
                let m_viginc = g_doc_itau[1].itaaplvigincdat
                let m_vigfnl = g_doc_itau[1].itaaplvigfnldat
             end if

          end if

          let l_vigencia = "Vigencia: ",m_viginc," a ",m_vigfnl

          if m_viginc is not null or
             m_vigfnl is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_vigencia)
          end if

       when 28
          initialize l_cbtcod, l_cobertura, l_cpodes to null
          if mr_param.aplnumdig is not null then
             open c_cta19m00_025 using mr_param.succod,
                                     mr_param.aplnumdig,
                                     mr_param.itmnumdig,
                                     g_funapol.autsitatu

             whenever error continue
             fetch c_cta19m00_025 into l_cbtcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          else

             if m_prepara2_sql is null or
                m_prepara2_sql <> true then
                call cta19m00_prepare2()

                if figrc072_getErro() then
                      return m_flag
                end if

             end if

             open c_cta19m00_056 using mr_param.prporg,
                                     mr_param.prpnumdig,
                                     mr_param.prporg,
                                     mr_param.prpnumdig

             whenever error continue
             fetch c_cta19m00_056 into l_cbtcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          end if

          open c_cta19m00_026 using l_cbtcod

          whenever error continue
          fetch c_cta19m00_026 into l_cpodes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_cobertura = "Cobertura: ",l_cbtcod," - ",l_cpodes

          if l_cbtcod is not null or
             l_cpodes is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_cobertura)
          end if
       when 29
          initialize l_clscod, m_viginc, m_vigfnl, l_tabnum, l_clsdes, l_cobertura to null

          if m_ciaempcod = 1  or
             m_ciaempcod = 50 then
             if mr_param.aplnumdig is not null then
                open c_cta19m00_027 using mr_param.succod,
                                        mr_param.aplnumdig,
                                        mr_param.itmnumdig,
                                        g_funapol.dctnumseq

                foreach c_cta19m00_027 into l_clscod, m_viginc
                   if l_clscod <> "034" and
                      l_clscod <> "071" then
                      let l_clscodant = l_clscod
                   end if
                   if l_clscod = "034" or
                      l_clscod = "071" or
                      l_clscod = "077" then
                    if cta13m00_verifica_clausula(mr_param.succod,
                                                  mr_param.aplnumdig,
                                                  mr_param.itmnumdig,
                                                  g_funapol.dctnumseq ,
                                                  l_clscod           ) then
                       let l_clscod = l_clscodant
                       continue foreach
                    end if
                   end if

                   if m_viginc is null then
                      open c_cta19m00_024 using mr_param.succod,
                                              mr_param.aplnumdig
                      whenever error continue
                      fetch c_cta19m00_024 into m_viginc,
                                              m_vigfnl
                      whenever error stop
                      if sqlca.sqlcode <> 0 then
                         if sqlca.sqlcode = 100 then
                         else
                            let m_flag  = true
                            let l_foreach = true
                            exit foreach
                         end if
                      end if
                   end if

                   call f_fungeral_tabnum('aackcls',m_viginc)
                           returning l_tabnum

                   open c_cta19m00_028 using l_tabnum,
                                           mr_param.ramcod,
                                           l_clscod

                   whenever error continue
                   fetch c_cta19m00_028 into l_clsdes
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode = 100 then
                      else
                         let m_flag  = true
                         let l_foreach = true
                         exit foreach
                      end if
                   end if
                   let l_cobertura = "Clausula: ",l_clscod," - ",l_clsdes

                   if l_clscod is not null or
                      l_clsdes is not null then
                      call ctx14g00_msgtxt(m_c24trxnum, l_cobertura)
                   end if
                end foreach
             else

                if m_prepara2_sql is null or
                   m_prepara2_sql <> true then
                   call cta19m00_prepare2()

                   if figrc072_getErro() then
                         return m_flag
                   end if

                end if

                open c_cta19m00_057 using mr_param.prporg,
                                        mr_param.prpnumdig,
                                        mr_param.prporg,
                                        mr_param.prpnumdig

                foreach c_cta19m00_057 into l_clscod, m_viginc

                   call f_fungeral_tabnum('aackcls',m_viginc)
                           returning l_tabnum

                   open c_cta19m00_028 using l_tabnum,
                                           mr_param.ramcod,
                                           l_clscod


                   whenever error continue
                   fetch c_cta19m00_028 into l_clsdes
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode = 100 then
                      else
                         let m_flag  = true
                         let l_foreach = true
                         exit foreach
                      end if
                   end if

                   let l_cobertura = "Clausula: ",l_clscod," - ",l_clsdes
                   if l_clscod is not null or
                      l_clsdes is not null then
                      call ctx14g00_msgtxt(m_c24trxnum, l_cobertura)
                   end if
                end foreach
             end if
          else

             if m_ciaempcod = 35 then

                let l_qtd_end = figrc011_xpath(m_doc_handle,"count(/APOLICES/APOLICE/CLAUSULAS/CLAUSULA)")
                for l_ind = 1 to l_qtd_end

                    let l_aux_char = "/APOLICES/APOLICE/CLAUSULAS/CLAUSULA[",
                                     l_ind using "<<<<&","]/CODIGO"
                    let l_clscod = figrc011_xpath(m_doc_handle, l_aux_char)

                    let l_aux_char = "/APOLICES/APOLICE/CLAUSULAS/CLAUSULA[",
                                     l_ind using "<<<<&", "]/DESCRICAO"
                    let l_clsdes = figrc011_xpath(m_doc_handle, l_aux_char)

                    let l_cobertura = "Clausula: ",l_clscod," - ",l_clsdes


                    if l_clscod is not null or
                       l_clsdes is not null then
                       call ctx14g00_msgtxt(m_c24trxnum, l_cobertura)
                    end if
                end for

             end if

             if m_ciaempcod = 84 then # Itau

                let l_clscod = g_doc_itau[1].itacbtcod

                call cto00m10_recupera_descricao(14,g_doc_itau[1].itacbtcod)
                returning l_clsdes

                let l_cobertura = "Cobertura: ",l_clscod," - ",l_clsdes

                if l_clscod is not null or
                   l_clsdes is not null then
                   call ctx14g00_msgtxt(m_c24trxnum, l_cobertura)
                end if
             end if
          end if
       when 30
          initialize l_frqvlr, l_franquia to null

          if m_ciaempcod = 1  or
             m_ciaempcod = 50 then
             if mr_param.aplnumdig is not null then
                open c_cta19m00_029 using mr_param.succod,
                                        mr_param.aplnumdig,
                                        mr_param.itmnumdig,
                                        g_funapol.autsitatu

                whenever error continue
                fetch c_cta19m00_029 into l_frqvlr
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
             else

                if m_prepara2_sql is null or
                   m_prepara2_sql <> true then
                   call cta19m00_prepare2()

                   if figrc072_getErro() then
                         return m_flag
                   end if

                end if

                open c_cta19m00_058 using mr_param.prporg,
                                        mr_param.prpnumdig,
                                        mr_param.prporg,
                                        mr_param.prpnumdig

                whenever error continue
                fetch c_cta19m00_058 into l_frqvlr
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                   else
                      let m_flag  = true
                      let l_foreach = true
                      exit foreach
                   end if
                end if
             end if
          else
             if m_ciaempcod = 35 then
                if m_status_xml = 1 then
                   call cts40g02_extraiDoXML(m_doc_handle, "FRANQUIA")
                        returning l_frqvlr
                end if
             end if

             if m_ciaempcod = 84 then # Itau
                let l_frqvlr = g_doc_itau[1].casfrqvlr
             end if

          end if

          let l_franquia = "Franquia p/abertura de processo: ",l_frqvlr

          if l_frqvlr is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_franquia)
          end if


       when 31
          initialize l_bonclacod, l_clalclcod, m_viginc, m_vigfnl, l_tabnum,
                     l_bondscper, l_bonus to null

          if mr_param.aplnumdig is not null then
             open c_cta19m00_030 using mr_param.succod,
                                     mr_param.aplnumdig,
                                     mr_param.itmnumdig,
                                     g_funapol.dctnumseq

             whenever error continue
             fetch c_cta19m00_030 into l_bonclacod,
                                     l_clalclcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          else

             if m_prepara2_sql is null or
                m_prepara2_sql <> true then
                call cta19m00_prepare2()

                if figrc072_getErro() then
                      return m_flag
                end if

             end if

             open c_cta19m00_059 using mr_param.prporg,
                                     mr_param.prpnumdig,
                                     mr_param.prporg,
                                     mr_param.prpnumdig

             whenever error continue
             fetch c_cta19m00_059 into l_bonclacod,
                                     l_clalclcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          end if

          open c_cta19m00_024 using mr_param.succod,
                                  mr_param.aplnumdig

          whenever error continue
          fetch c_cta19m00_024 into m_viginc,
                                  m_vigfnl
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          call f_fungeral_tabnum('acatbon',m_viginc)
                  returning l_tabnum

          open c_cta19m00_031 using l_tabnum,
                                  mr_param.ramcod,
                                  l_bonclacod,
                                  l_clalclcod

          whenever error continue
          fetch c_cta19m00_031 into l_bondscper
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_bonus = "Bonus: ",l_bonclacod," - ",l_bondscper,"%"

          if l_bonclacod is not null or
             l_bondscper is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_bonus)
          end if
       when 32
          initialize l_txtlin, l_nome_condutor to null
          if mr_param.aplnumdig is not null then
             open c_cta19m00_032 using mr_param.succod,
                                     mr_param.aplnumdig,
                                     mr_param.itmnumdig,
                                     g_funapol.dctnumseq

             whenever error continue
             fetch c_cta19m00_032 into l_txtlin
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          else

             if m_prepara2_sql is null or
                m_prepara2_sql <> true then
                call cta19m00_prepare2()

                if figrc072_getErro() then
                      return m_flag
                end if

             end if

             open c_cta19m00_060 using mr_param.prporg,
                                     mr_param.prpnumdig,
                                     mr_param.prporg,
                                     mr_param.prpnumdig

             whenever error continue
             fetch c_cta19m00_060 into l_txtlin
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          end if

          let l_nome_condutor = "Nome principal condutor: ",l_txtlin

          if l_txtlin is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_nome_condutor)
          end if

       when 33
          initialize l_clcdat, l_qstcod, l_rspcod, l_qstrspdsc, l_relacao to null
          if mr_param.aplnumdig is not null then
             open c_cta19m00_033 using mr_param.succod,
                                     mr_param.aplnumdig,
                                     mr_param.itmnumdig,
                                     g_funapol.dctnumseq

             whenever error continue
             fetch c_cta19m00_033 into l_clcdat
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if

             open c_cta19m00_034 using mr_param.succod,
                                     mr_param.aplnumdig,
                                     mr_param.itmnumdig,
                                     g_funapol.dctnumseq

             whenever error continue
             fetch c_cta19m00_034 into l_qstcod,
                                     l_rspcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          else

             if m_prepara2_sql is null or
                m_prepara2_sql <> true then
                call cta19m00_prepare2()

                if figrc072_getErro() then
                      return m_flag
                end if

             end if

             open c_cta19m00_061 using mr_param.prporg,
                                     mr_param.prpnumdig,
                                     mr_param.prporg,
                                     mr_param.prpnumdig

             whenever error continue
             fetch c_cta19m00_061 into l_clcdat
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if

             open c_cta19m00_062 using mr_param.prporg,
                                     mr_param.prpnumdig,
                                     mr_param.prporg,
                                     mr_param.prpnumdig

             whenever error continue
             fetch c_cta19m00_062 into l_qstcod,
                                     l_rspcod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                else
                   let m_flag  = true
                   let l_foreach = true
                   exit foreach
                end if
             end if
          end if

          open c_cta19m00_035 using l_qstcod,
                                  l_rspcod,
                                  l_clcdat

          whenever error continue
          fetch c_cta19m00_035 into l_qstrspdsc
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_relacao = "Relacao segurado: ",l_qstrspdsc

          if l_qstrspdsc is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_relacao)
          end if

       when 34
          initialize l_srvnome, l_srvjustif, l_cortesia1, l_cortesia2 to null
          whenever error continue
          select srvnome,
                 srvjustif
            into l_srvnome,
                 l_srvjustif
            from tmp_autorizasrv
           where srvfunmat = g_issk.funmat
             and srvempcod = g_issk.empcod
             and srvmaqsgl = g_issk.maqsgl
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_cortesia1 = "Servico cortesia: ",l_srvnome

          if l_srvnome is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_cortesia1)
          end if

          let l_cortesia2 = "                  ",l_srvjustif

          if l_srvjustif is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_cortesia2)
          end if

       when 35
          initialize l_pasnom, l_pasidd, l_passeq, l_nome_idade to null
          open c_cta19m00_036 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano


          foreach c_cta19m00_036 into l_pasnom,
                                    l_pasidd,
                                    l_passeq

             let l_nome_idade = "Nome: ",l_pasnom," Idade: ",l_pasidd

             if l_pasnom is not null or
                l_pasidd is not null then
                call ctx14g00_msgtxt(m_c24trxnum, l_nome_idade)
             end if
          end foreach

       when 36
          initialize l_slcemp, l_slcsuccod, l_slccctcod, l_cctnom, l_centro_custos to null

          open c_cta19m00_037 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_037 into l_slcemp,
                                  l_slcsuccod,
                                  l_slccctcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let lr_param.empcod    = 1
          let lr_param.succod    = 1
          let lr_param.cctlclcod = (l_slccctcod / 10000)
          let lr_param.cctdptcod = (l_slccctcod mod 10000)
          call fctgc102_vld_dep(lr_param.*)
               returning lr_ret.*
          let l_cctnom = lr_ret.cctdptnom

          let l_centro_custos = "Centro de Custos: ",l_slccctcod,"-",l_cctnom

          if l_slccctcod is not null or
             l_cctnom is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_centro_custos)
          end if

       when 37
          initialize l_c24srvdsc, l_historico_lig to null

          open c_cta19m00_038 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          let l_cont = 1

          foreach c_cta19m00_038 into l_c24srvdsc

             if l_cont = 1 then
                let l_historico_lig = "Historico: ",l_c24srvdsc
                call ctx14g00_msgtxt(m_c24trxnum, l_historico_lig)
                let l_cont = l_cont + 1
             else
                if l_c24srvdsc is not null then
                   call ctx14g00_msgtxt(m_c24trxnum,l_c24srvdsc)
                end if
             end if
          end foreach

       when 38
          initialize l_lgdtip,       l_lgdnom, l_lgdnum,    l_lclbrrnom,
                     l_brrnom,       l_cidnom, l_ufdcod,    l_endzon,
                     l_lclrefptotxt, l_dddcod, l_lcltelnum, l_lclidttxt,
                     l_ofnnumdig, l_oficina to null

          let l_aux = 2
          open c_cta19m00_017 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano,
                                  l_aux

          whenever error continue
          fetch c_cta19m00_017 into l_lgdtip,
                                  l_lgdnom,
                                  l_lgdnum,
                                  l_lclbrrnom,
                                  l_brrnom,
                                  l_cidnom,
                                  l_ufdcod,
                                  l_endzon,
                                  l_lclrefptotxt,
                                  l_dddcod,
                                  l_lcltelnum,
                                  l_lclidttxt,
                                  l_ofnnumdig
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_oficina = "Oficina: ",l_ofnnumdig,"-",l_lclidttxt

          if l_ofnnumdig is not null or
             l_lclidttxt is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_oficina)
          end if


       when 39
          initialize l_vcldes,    l_atdsrvorg, l_vcllicnum,    l_atddfttxt, l_asitipcod,
                     l_srvtipdes, l_asitipdes, l_asitipabvdes, l_laudo to null

          open c_cta19m00_010 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_010 into l_vcldes,
                                  l_atdsrvorg,
                                  l_vcllicnum,
                                  l_atddfttxt,
                                  l_asitipcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          open c_cta19m00_039 using l_atdsrvorg

          whenever error continue
          fetch c_cta19m00_039 into l_srvtipdes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          open c_cta19m00_040 using l_asitipcod

          whenever error continue
          fetch c_cta19m00_040 into l_asitipdes,
                                  l_asitipabvdes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if


          let l_laudo = "Laudo: ",l_srvtipdes clipped," ",l_asitipdes clipped

          if l_srvtipdes is not null or
             l_asitipdes is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_laudo)
          end if

       when 40
          initialize l_atddmccidnom, l_atddmcufdcod, l_asimtvcod, l_trppfrdat, l_trppfrhor,
                     l_domicilio to null

          open c_cta19m00_041 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_041 into l_atddmccidnom,
                                  l_atddmcufdcod,
                                  l_asimtvcod,
                                  l_trppfrdat,
                                  l_trppfrhor
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_domicilio = "Domicilio: ",l_atddmccidnom clipped,"-",l_atddmcufdcod

          if l_atddmccidnom is not null or
             l_atddmcufdcod is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_domicilio)
          end if

       when 41
          initialize l_lgdtip,       l_lgdnom, l_lgdnum,    l_lclbrrnom,
                     l_brrnom,       l_cidnom, l_ufdcod,    l_endzon,
                     l_lclrefptotxt, l_dddcod, l_lcltelnum, l_lclidttxt,
                     l_ofnnumdig, l_cid_ocor to null

          let l_aux = 1
          open c_cta19m00_017 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano,
                                  l_aux

          whenever error continue
          fetch c_cta19m00_017 into l_lgdtip,
                                  l_lgdnom,
                                  l_lgdnum,
                                  l_lclbrrnom,
                                  l_brrnom,
                                  l_cidnom,
                                  l_ufdcod,
                                  l_endzon,
                                  l_lclrefptotxt,
                                  l_dddcod,
                                  l_lcltelnum,
                                  l_lclidttxt,
                                  l_ofnnumdig
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_cid_ocor = "Ocorrencia: ",l_cidnom clipped,"-",l_ufdcod

          if l_cidnom is not null or
             l_ufdcod is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_cid_ocor)
          end if

       when 42
          initialize l_atddstcidnom, l_atddstufdcod, l_cid_dst to null

          open c_cta19m00_051 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_051 into l_atddstcidnom,
                                  l_atddstufdcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_cid_dst = "Destino: ",l_atddstcidnom clipped,"-",l_atddstufdcod

          if l_atddmccidnom is not null or
             l_atddmcufdcod is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_cid_dst)
          end if

       when 43
          initialize l_atddmccidnom, l_atddmcufdcod, l_asimtvcod, l_trppfrdat,
                     l_trppfrhor, l_asimtvdes, l_motivo to null

          open c_cta19m00_041 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_041 into l_atddmccidnom,
                                  l_atddmcufdcod,
                                  l_asimtvcod,
                                  l_trppfrdat,
                                  l_trppfrhor
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          open c_cta19m00_042 using l_asimtvcod

          whenever error continue
          fetch c_cta19m00_042 into l_asimtvdes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_motivo = "Motivo: ",l_asimtvdes

          if l_asimtvdes is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_motivo)
          end if

       when 44
          initialize l_count_pas, l_qtd_pas to null
          open c_cta19m00_048 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_048 into l_count_pas
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_qtd_pas = "Quant. Passageiros: ",l_count_pas

          if l_count_pas is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_qtd_pas)
          end if

       when 45
          initialize l_atddmccidnom, l_atddmcufdcod, l_asimtvcod, l_trppfrdat,
                     l_trppfrhor, l_data_pref to null

          open c_cta19m00_041 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_041 into l_atddmccidnom,
                                  l_atddmcufdcod,
                                  l_asimtvcod,
                                  l_trppfrdat,
                                  l_trppfrhor
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_data_pref = "Preferencia para viagem: ",l_trppfrdat," as ", l_trppfrhor

          if l_trppfrdat is not null or
             l_trppfrhor is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_data_pref)
          end if

       when 46
          initialize l_hpddiapvsqtd, l_hpdqrtqtd, l_diarias to null
          open c_cta19m00_043 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_043 into l_hpddiapvsqtd,
                                  l_hpdqrtqtd
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_diarias = "Diarias: ",l_hpddiapvsqtd," Quartos: ", l_hpdqrtqtd

          if l_hpddiapvsqtd is not null or
             l_hpdqrtqtd is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_diarias)
          end if

       when 47
          initialize l_sinavsnum, l_aviso_sinistro to null
          open c_cta19m00_050 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_050 into l_sinavsnum
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_aviso_sinistro =  "Nr. Aviso Sinistro: ", l_sinavsnum using "<<<<<<<<<<"

          if l_sinavsnum  is not null then
             call ctx14g00_msgtxt(m_c24trxnum, l_aviso_sinistro)
          end if

       when 48
            if m_crtsaunum is not null then

               call cta01m15_sel_datksegsau (4, m_crtsaunum, "","","")
                    returning m_status, m_msg, l_plncod, l_cntanvdat

               call cta01m16_sel_datkplnsau(l_plncod)
                    returning m_status, m_msg, l_plndes, l_plnatnlimnum

               let l_plano =  "Plano de Saude: ", l_plncod, ' - ',
                                                  l_plndes clipped


               if l_plncod is not null then
                  call ctx14g00_msgtxt(m_c24trxnum, l_plano)
               end if
            end if

       when 49

             if m_ciaempcod = 40 then # Cartao
                let lr_ffpfc073.cgccpf = cta01m60_formata_cgccpf(lr_ffpfc073.cgccpfnum,
                                                                 lr_ffpfc073.cgcord   ,
                                                                 lr_ffpfc073.cgccpfdig)

                let l_cgccpf = "CGC/CPF do Cartao: ", lr_ffpfc073.cgccpf

                if l_cgccpf is not null then
                   call ctx14g00_msgtxt(m_c24trxnum, l_cgccpf)
                end if
             end if

       when 50
          initialize l_nome_falecido  to null

          open c_cta19m00_053 using mr_param.atdsrvnum,
                                  mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_053 into l_nome_falecido
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_nome_falecido = "Nome do falecido: ", l_nome_falecido

          if l_nome_falecido is not null  then
             call ctx14g00_msgtxt(m_c24trxnum, l_nome_falecido)
          end if
       when 51
            if g_documento.ciaempcod = 43 and
               g_pss.psscntcod is not null  then
               let l_pss = "Contrato PSS: ", g_pss.psscntcod
               if l_pss is not null then
                   call ctx14g00_msgtxt(m_c24trxnum, l_pss)
               end if
            end if
       when 52
            if g_documento.ciaempcod = 43 and
               g_pss.psscntcod is not null  then
               call pss01g00_consulta_CNPJ(g_pss.psscntcod)
               returning l_cgccpfnum,
                         l_cgcord   ,
                         l_cgccpfdig,
                         l_resultado ,
                         l_msg
               if l_resultado = 0 then
                  let l_pss = cta01m60_formata_cgccpf(l_cgccpfnum,
                                                      l_cgcord   ,
                                                      l_cgccpfdig)
                  let l_pss = "CGC/CPF do Cliente PSS: ", l_pss
                  if l_pss is not null then
                      call ctx14g00_msgtxt(m_c24trxnum, l_pss)
                  end if
               end if
            end if
        when 53
            if g_documento.ciaempcod = 43 and
               g_pss.psscntcod is not null  then
               call pss01g00_consulta_CNPJ(g_pss.psscntcod)
               returning l_cgccpfnum,
                         l_cgcord   ,
                         l_cgccpfdig,
                         l_resultado ,
                         l_msg
               if l_resultado = 0 then
                  if l_cgcord = 0 then
                     let l_pestip = "F"
                  else
                     let l_pestip = "J"
                  end if


                  call cta00m23_rec_cliente(l_pesnom    ,
                                            l_pestip    ,
                                            l_cgccpfnum ,
                                            l_cgcord    ,
                                            l_cgccpfdig )
                  returning l_cgccpfnum  ,
                            l_cgcord     ,
                            l_cgccpfdig  ,
                            l_pesnom     ,
                            l_pestip     ,
                            l_psscntcod  ,
                            l_pesnum     ,
                            l_resultado
                  if l_resultado = 0 then
                      let l_pesnom = "Nome do Cliente PSS: ", l_pesnom
                      if l_pesnom is not null then
                          call ctx14g00_msgtxt(m_c24trxnum, l_pesnom)
                      end if
                  end if
               end if
            end if
         when 54

            initialize lr_psa.descricao to null

            open c_cta19m00_070 using mr_param.atdsrvnum,
                                      mr_param.atdsrvano

            whenever error continue
            fetch c_cta19m00_070 into lr_psa.lignum
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            let lr_psa.descricao  = "Numero da Ligacao: ", lr_psa.lignum

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

         when 55

            initialize lr_psa.descricao to null

            open c_cta19m00_071 using mr_param.atdsrvnum,
                                      mr_param.atdsrvano

            whenever error continue
            fetch c_cta19m00_071 into lr_psa.ligdat    ,
                                      lr_psa.lighorinc
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            let lr_psa.descricao = "Data/Hora da Ligacao: ", lr_psa.ligdat , " - " , lr_psa.lighorinc

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

         when 56

           initialize lr_psa.descricao to null

           open c_cta19m00_072 using mr_param.atdsrvnum,
                                     mr_param.atdsrvano

           whenever error continue
           fetch c_cta19m00_072 into lr_psa.ciaempcod
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           let lr_psa.descricao = "Empresa da Ligacao: ", lr_psa.ciaempcod

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

         when 57

           initialize lr_psa.descricao to null

           open c_cta19m00_073 using mr_param.atdsrvnum,
                                     mr_param.atdsrvano

           whenever error continue
           fetch c_cta19m00_073 into lr_psa.atddat ,
                                     lr_psa.atdhor
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           let lr_psa.descricao = "Data/Hora da Abertura do Servico: ",  lr_psa.atddat , " - " , lr_psa.atdhor

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

         when 58

           initialize lr_psa.descricao to null

           open c_cta19m00_074 using mr_param.atdsrvnum,
                                     mr_param.atdsrvano

           whenever error continue
           fetch c_cta19m00_074 into lr_psa.atddatprg,
                                     lr_psa.atdhorprg
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           let lr_psa.descricao = "Data/Hora Agendamento do Servico: ", lr_psa.atddatprg , " - " , lr_psa.atdhorprg

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

         when 59

          initialize lr_psa.descricao to null

          open c_cta19m00_075 using mr_param.atdsrvnum,
                                    mr_param.atdsrvano

          whenever error continue
          fetch c_cta19m00_075 into lr_psa.atdprscod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          open c_cta19m00_083 using lr_psa.atdprscod

          whenever error continue
          fetch c_cta19m00_083 into lr_psa.nomrazsoc
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let lr_psa.descricao = "Prestador do Servico: ", lr_psa.atdprscod, " - ", lr_psa.nomrazsoc

          if lr_psa.descricao  is not null  then
             call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
          end if

         when 60

           initialize lr_psa.descricao to null

           open c_cta19m00_076 using l_lignum

           whenever error continue
           fetch c_cta19m00_076 into lr_psa.cgccpfnum ,
                                     lr_psa.cgcord    ,
                                     lr_psa.cgccpfdig

           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           if lr_psa.cgcord = 0 then
              let lr_psa.pestip = "F"
              let lr_psa.descricao = "CGC/CPF do Cliente PSA: ", lr_psa.cgccpfnum, "-", lr_psa.cgccpfdig
           else
              let lr_psa.pestip = "J"
              let lr_psa.descricao = "CGC/CPF do Cliente PSA: ", lr_psa.cgccpfnum, "/", lr_psa.cgcord ,"-", lr_psa.cgccpfdig
           end if


           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           initialize lr_psa.descricao to null

           let lr_psa.descricao = "Tipo Pessoa: ", lr_psa.pestip

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

         when 61

           initialize lr_psa.descricao to null

           open c_cta19m00_076 using l_lignum

           whenever error continue
           fetch c_cta19m00_076 into lr_psa.cgccpfnum ,
                                     lr_psa.cgcord    ,
                                     lr_psa.cgccpfdig

           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           if lr_psa.cgcord = 0 then
              let lr_psa.pestip = "F"
           else
              let lr_psa.pestip = "J"
           end if

           open c_cta19m00_077 using lr_psa.cgccpfnum ,
                                     lr_psa.cgcord    ,
                                     lr_psa.cgccpfdig ,
                                     lr_psa.pestip
           whenever error continue
           fetch c_cta19m00_077 into lr_psa.pesnom
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           let lr_psa.descricao = "Nome do Cliente PSA: ", lr_psa.pesnom

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

         when 62

           initialize lr_psa.descricao to null

           open c_cta19m00_078 using mr_param.atdsrvnum,
                                     mr_param.atdsrvano
           whenever error continue
           fetch c_cta19m00_078 into lr_psa.lgdtip      ,
                                     lr_psa.lgdnom      ,
                                     lr_psa.lgdnum      ,
                                     lr_psa.lclbrrnom   ,
                                     lr_psa.brrnom      ,
                                     lr_psa.cidnom      ,
                                     lr_psa.ufdcod      ,
                                     lr_psa.lclrefptotxt,
                                     lr_psa.endzon      ,
                                     lr_psa.lgdcep      ,
                                     lr_psa.lgdcepcmp   ,
                                     lr_psa.dddcod      ,
                                     lr_psa.lcltelnum   ,
                                     lr_psa.lclcttnom   ,
                                     lr_psa.lclltt      ,
                                     lr_psa.lcllgt      ,
                                     lr_psa.celteldddcod,
                                     lr_psa.celtelnum   ,
                                     lr_psa.cmlteldddcod,
                                     lr_psa.cmltelnum   ,
                                     lr_psa.endcmp


           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if


           let lr_psa.descricao = "Tipo de Logradouro: ", lr_psa.lgdtip

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if
           let lr_psa.descricao = "Logradouro: ", lr_psa.lgdnom

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Numero: ", lr_psa.lgdnum

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Bairro: ", lr_psa.brrnom

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if
           let lr_psa.descricao = "Sub-Bairro: ", lr_psa.lclbrrnom

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if
           let lr_psa.descricao = "Cidade: ", lr_psa.cidnom

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "UF: ", lr_psa.ufdcod

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Referencia: ", lr_psa.lclrefptotxt

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Zona: ", lr_psa.endzon

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "CEP: ", lr_psa.lgdcep, "-", lr_psa.lgdcepcmp

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Telefone Residencia: ", lr_psa.dddcod, "-", lr_psa.lcltelnum

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Latitude: ", lr_psa.lclltt

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Longitude: ", lr_psa.lcllgt

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Contato: ", lr_psa.lclcttnom

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if


           let lr_psa.descricao = "Telefone Celular: ", lr_psa.celteldddcod, "-", lr_psa.celtelnum

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Telefone Comercial: ", lr_psa.cmlteldddcod, "-",  lr_psa.cmltelnum

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if

           let lr_psa.descricao = "Complemento: ", lr_psa.endcmp

           if lr_psa.descricao  is not null  then
              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
           end if
         when 63

           initialize lr_psa.descricao to null

           open c_cta19m00_079 using l_lignum

           whenever error continue
           fetch c_cta19m00_079 into lr_psa.c24astagp   ,
                                     lr_psa.c24astagpdes
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else
                 let m_flag  = true
                 let l_foreach = true
                 exit foreach
              end if
           end if

           let lr_psa.descricao = "Agrupamento do Assunto: ", lr_psa.c24astagp, " - ", lr_psa.c24astagpdes
	           if lr_psa.descricao  is not null  then
	              call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
	           end if


         when 64

            initialize lr_psa.descricao to null

            open c_cta19m00_080 using mr_param.atdsrvnum,
                                      mr_param.atdsrvano,
                                      mr_param.atdsrvnum,
                                      mr_param.atdsrvano

            whenever error continue
            fetch c_cta19m00_080 into lr_psa.c24pbmcod,
                                      lr_psa.c24pbmdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            open c_cta19m00_081 using lr_psa.c24pbmcod

            whenever error continue
            fetch c_cta19m00_081 into lr_psa.c24pbmgrpcod ,
                                      lr_psa.c24pbmgrpdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            let lr_psa.descricao = "Grupo do Problema de Servico: ", lr_psa.c24pbmgrpcod, " - ", lr_psa.c24pbmgrpdes

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

         when 65

            initialize lr_psa.descricao to null

            open c_cta19m00_080 using mr_param.atdsrvnum,
                                      mr_param.atdsrvano,
                                      mr_param.atdsrvnum,
                                      mr_param.atdsrvano

            whenever error continue
            fetch c_cta19m00_080 into lr_psa.c24pbmcod   ,
                                      lr_psa.c24pbmdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            let lr_psa.descricao = "Problema do Servico: ", lr_psa.c24pbmcod, " - ", lr_psa.c24pbmdes

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

         when 66

            initialize lr_psa.descricao to null

            open c_cta19m00_020 using mr_param.atdsrvnum,
                                      mr_param.atdsrvano

            whenever error continue
            fetch c_cta19m00_020 into l_socntzcod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            open c_cta19m00_082 using l_socntzcod

            whenever error continue
            fetch c_cta19m00_082 into lr_psa.socntzgrpcod   ,
                                      lr_psa.socntzgrpdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            let lr_psa.descricao = "Grupo da Natureza: ", lr_psa.socntzgrpcod, " - ", lr_psa.socntzgrpdes

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

         when 67

            initialize lr_psa.descricao to null

            open c_cta19m00_084 using l_lignum

            whenever error continue
            fetch c_cta19m00_084 into lr_psa.c24soltipcod   ,
                                      lr_psa.c24soltipdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            let lr_psa.descricao = "Tipo de Solicitante: ", lr_psa.c24soltipcod, " - ", lr_psa.c24soltipdes

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

         when 68

            initialize lr_psa.descricao, l_cpodes to null

            open c_cta19m00_085 using l_lignum

            whenever error continue
            fetch c_cta19m00_085 into lr_psa.ligcvntip
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
               else
                  let m_flag  = true
                  let l_foreach = true
                  exit foreach
               end if
            end if

            call cta00m00_recupera_convenio(lr_psa.ligcvntip)
            returning l_cpodes

            let lr_psa.descricao = "Convenio: ", lr_psa.ligcvntip, " - ", l_cpodes

            if lr_psa.descricao  is not null  then
               call ctx14g00_msgtxt(m_c24trxnum, lr_psa.descricao )
            end if

       end case

    end foreach

    if l_foreach then
       let l_foreach = false
       exit foreach
    end if

    if (l_flag = 1 and m_datkprtcpa.c24prtseq <> 1) or
       (l_flag = 2 and m_datkprtcpa.c24prtseq <> 2) or
       (l_flag = 3 and m_datkprtcpa.c24prtseq <> 3) or
       (l_flag = 4 and m_datkprtcpa.c24prtseq <> 4) then
       continue foreach
    end if

    initialize l_ustcod, l_empcod, l_usrtip, l_funmat to null

    open c_cta19m00_044 using m_datkprtcpa.ramcod,
                            m_datkprtcpa.c24astcod,
                            m_datkprtcpa.cvnnum,
                            m_datkprtcpa.c24prtseq


    foreach c_cta19m00_044 into l_ustcod,
                              l_empcod,
                              l_usrtip,
                              l_funmat

       if l_ustcod =  0 and
          l_funmat <> 0 then
          initialize l_result, l_codigo_email, l_endereco_email, l_funnom to null
          call fgrhc001_mailgicod(l_usrtip,l_empcod,l_funmat)
                 returning l_result, l_codigo_email, l_endereco_email

          if l_result = 0 then
             continue foreach
          end if

          open c_cta19m00_045 using l_usrtip,
                                  l_empcod,
                                  l_funmat

          whenever error continue
          fetch c_cta19m00_045 into l_funnom
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
                let l_funnom = 'NAO CADASTRADO'
             else
                let m_flag  = true
                let l_foreach = true
                exit foreach
             end if
          end if

          let l_aux = 1

          call ctx14g00_msgdst(m_c24trxnum,l_endereco_email,l_funnom, l_aux)
       end if
       if l_ustcod <> 0 and
          l_funmat =  0 then
          let l_aux = 2
          call ctx14g00_msgdst(m_c24trxnum,l_ustcod,'cta19m00', l_aux)
       end if

    end foreach

    let l_maicod = null
    open c_cta19m00_046 using m_datkprtcpa.ramcod,
                              m_datkprtcpa.c24astcod,
                              m_datkprtcpa.cvnnum,
                              m_datkprtcpa.c24prtseq


    foreach c_cta19m00_046 into l_maicod

       let l_aux = 1
       call ctx14g00_msgdst(m_c24trxnum,l_maicod,'cta19m00', l_aux)

    end foreach


    let l_aux = 9
    whenever error continue
    execute p_cta19m00_048 using l_aux,
                               m_c24trxnum
    whenever error stop
    if sqlca.sqlcode = 0 then
    else
       error "Erro UPDATE na tabela dammtrx.",sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep(1)
       let m_flag  = true
    end if


    call cta19m00_envia(m_c24trxnum)

    let m_flag = true

 end foreach

 if l_entrou = false then
    let m_flag = true
 end if

 return m_flag

end function




#----------------------------#
 function cta19m00_segurado()
#----------------------------#

  define l_segnom      like gsakseg.segnom
  define l_segnumdig   like rsdmdocto.segnumdig
  define l_sgrorg      like rsamseguro.sgrorg
  define l_sgrnumdig   like rsamseguro.sgrnumdig,
         l_cgccpfnum   like gsakseg.cgccpfnum,
         l_cgcord      like gsakseg.cgcord,
         l_cgccpfdig   like gsakseg.cgccpfdig

  define lr_ret_vida01     record
         coderro         smallint
        ,msgerr          char(080)
        ,sgrorg      decimal(2,0)
        ,sgrnumdig   decimal(9,0)
        ,ciaperptc   decimal(8,5)
        ,succod      smallint
        ,aplnumdig   decimal(9,0)
        ,rnvsuccod   smallint
        ,rnvaplnum   decimal(9,0)
        ,ramcod      smallint
        ,rmemdlcod   decimal(3,0)
        ,subcod      decimal(2,0)
        ,csginfflg   char(001)
        ,empcod      decimal(2,0)
        ,clbctrtip   decimal(2,0)
        ,rnvramcod   smallint
  end record

  define lr_ret_vida02 record
         coderro       smallint
        ,msgerr        char(080)
        ,vigfnl        date
        ,edsnumdig     decimal(9,0)
        ,segnumdig     decimal(8,0)
        ,prporg        decimal(2,0)
        ,prpnumdig     decimal(8,0)
  end record

  define l_ret_prev01    record
         coderro         integer,
         menserro        char(30),
         qtdlinhas       integer
  end record

  initialize l_segnom, l_segnumdig, l_sgrorg, l_sgrnumdig,
             l_cgccpfnum, l_cgcord, l_cgccpfdig, m_status, m_msg to null

  initialize lr_ret_vida01.* to null
  initialize lr_ret_vida02.* to null
  initialize l_ret_prev01.*  to null



  if m_ciaempcod = 1  or
     m_ciaempcod = 50 then

     if m_grupo = 1 then

        if mr_param.aplnumdig is not null then
           open c_cta19m00_004 using mr_param.succod,
                                   mr_param.aplnumdig,
                                   mr_param.itmnumdig,
                                   g_funapol.dctnumseq

           whenever error continue
           fetch c_cta19m00_004 into l_segnumdig
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else

                 let m_flag  = true
                 return l_segnom
              end if
           end if
        else

           if m_prepara2_sql is null or
              m_prepara2_sql <> true then
              call cta19m00_prepare2()

              if figrc072_getErro() then
                    return m_flag
              end if

           end if

           open c_cta19m00_054 using mr_param.prporg,
                                   mr_param.prpnumdig,
                                   mr_param.prporg,
                                   mr_param.prpnumdig

           whenever error continue
           fetch c_cta19m00_054 into l_segnumdig
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
              else

                 let m_flag  = true
                 return l_segnom
              end if
              return l_segnom
           end if
        end if
     else


        if m_grupo  = 5 then
           call cta01m15_sel_datksegsau (5, m_crtsaunum, "","","")
                returning m_status, m_msg, l_segnom
        else
           if m_grupo <> 3 then

              if m_prepara2_sql is null or
                 m_prepara2_sql <> true then
                 call cta19m00_prepare2()

                 if figrc072_getErro() then
                       return m_flag
                 end if

              end if


              open c_cta19m00_064 using mr_param.succod,
                                      mr_param.ramcod,
                                      mr_param.aplnumdig

              whenever error continue
              fetch c_cta19m00_064 into l_sgrorg,
                                      l_sgrnumdig

              whenever error stop
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = 100 then
                 else

                    let m_flag  = true
                    return l_segnom
                 end if
                 return l_segnom
              end if

              open c_cta19m00_065 using l_sgrorg,
                                      l_sgrnumdig

              whenever error continue
              fetch c_cta19m00_065 into l_segnumdig

              whenever error stop
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = 100 then
                 else

                    let m_flag  = true
                    return l_segnom
                 end if
                 return l_segnom
              end if
           else
              ---> VEP - Vida
              call fvnre000_rsamseguro_01(mr_param.succod
                                        , mr_param.ramcod
                                        , mr_param.aplnumdig)
                   returning lr_ret_vida01.*

              if lr_ret_vida01.coderro <> 0 then

                 call fpvia21_pesquisa_dados_segurado(mr_param.succod
                                                     ,991
                                                     ,mr_param.aplnumdig)
                      returning l_ret_prev01.coderro
                               ,l_ret_prev01.menserro
                               ,l_ret_prev01.qtdlinhas


                 if l_ret_prev01.qtdlinhas > 0 then
                    let l_segnom = g_a_psqdadseg[1].segnom
                 end if
              else
                 call fvnre000_rsdmdocto_06(lr_ret_vida01.sgrorg
                                           ,lr_ret_vida01.sgrnumdig)
                      returning lr_ret_vida02.*

                 if lr_ret_vida02.coderro = 0 then
                    let l_segnumdig = lr_ret_vida02.segnumdig

                    open c_cta19m00_005 using l_segnumdig

                    whenever error continue
                    fetch c_cta19m00_005 into l_segnom,
                                            l_cgccpfnum,
                                            l_cgcord,
                                            l_cgccpfdig

                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                       if sqlca.sqlcode = 100 then
                       else
                          let m_flag  = true
                          return l_segnom
                       end if
                    end if
                 end if
              end if
           end if
        end if
     end if


     if m_grupo <> 5 and
        m_grupo <> 3 then

        open c_cta19m00_005 using l_segnumdig

        whenever error continue
        fetch c_cta19m00_005 into l_segnom,
                                l_cgccpfnum,
                                l_cgcord,
                                l_cgccpfdig

        whenever error stop
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
           else
              let m_flag  = true
              return l_segnom
           end if
        end if
     end if
  end if

  return l_segnom

end function


#---------------------------------------------------------------------------#
 function cta19m00_motivo_aluguel(l_atdsrvnum,
                                  l_atdsrvano,
                                  l_c24astcod,
                                  l_c24prtseq,
                                  l_succod)
#---------------------------------------------------------------------------#

  define l_atdsrvnum like datmservico.atdsrvnum,
         l_atdsrvano like datmservico.atdsrvano,
         l_c24astcod like datmligacao.c24astcod,
         l_c24prtseq like datkprtcpa.c24prtseq,
         l_succod    like datrservapol.succod,
         l_cponom    like iddkdominio.cponom

  define l_avialgmtv      like datmavisrent.avialgmtv,
         l_avioccdat      like datmavisrent.avioccdat,
         l_lcvcod         like datmavisrent.lcvcod,
         l_avivclcod      like datmavisrent.avivclcod,
         l_cpodes         like iddkdominio.cpodes,
         l_aviprodiaqtd   like datmprorrog.aviprodiaqtd,
         l_aviprostt      like datmprorrog.aviprostt,
         l_aviproseq      like datmprorrog.aviproseq,
         l_avivclgrp      like datkavisveic.avivclgrp,
         l_flag           smallint

   define l_texto         char(200),
          l_titulo        char(200),
          l_data_saldo    date,
          l_aux           smallint,
          l_clscod        char(50),
          l_dat_vigini    date,
          l_dat_vigfim    date,
          l_temcls        smallint

  initialize l_cponom, l_avialgmtv, l_avioccdat, l_lcvcod, l_avivclcod,
             l_cpodes, l_aviprodiaqtd, l_aviprostt, l_aviproseq, l_avivclgrp,
             l_flag, l_texto, l_titulo, l_data_saldo, l_aux,
             l_clscod, l_dat_vigini, l_temcls to null

  let l_flag = 1

  open c_cta19m00_006 using l_atdsrvnum,
                          l_atdsrvano

  whenever error continue
  fetch c_cta19m00_006 into l_avialgmtv,
                          l_avioccdat,
                          l_lcvcod,
                          l_avivclcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     return l_flag, l_avialgmtv, l_cpodes, l_texto
  end if

  let l_cponom = 'avialgmtv'

  open c_cta19m00_007 using l_cponom,
                          l_avialgmtv

  whenever error continue
  fetch c_cta19m00_007 into l_cpodes
  whenever error stop
  if sqlca.sqlcode <> 0 then
     return l_flag, l_avialgmtv, l_cpodes, l_texto
  end if

  if l_c24astcod = "KA1"  and
     l_avialgmtv = 3      then
     let l_cpodes = "BENEFICIO"
  end if

  open c_cta19m00_008 using l_atdsrvnum,
                          l_atdsrvano

  whenever error continue
  fetch c_cta19m00_008 into l_aviprodiaqtd,
                          l_aviprostt,
                          l_aviproseq
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if (l_c24astcod = "H10" or
         l_c24astcod = "H11" or
         l_c24astcod = "KA1") then
         let l_flag = 1
     end if
  else
     if l_avialgmtv = 3 or
        l_avialgmtv = 6 then -- OSF 33367
        if l_aviprodiaqtd > 0 and l_aviprostt  = "A" then
           let l_texto  = " Dias Uteis: ", l_aviprodiaqtd
           let l_titulo = m_titulo clipped," ","PRORROGADO"
        end if
        if l_aviprostt     = "C" then
           let l_texto  = null
           let l_titulo = m_titulo clipped," ","CANCELADO"
        end if


        if (l_c24astcod = "H10" or  l_c24astcod = "H11" ) and
           (l_succod = 6  or l_succod = 7  or
            l_succod = 15 or l_succod = 16 or
            l_succod = 20 or l_succod = 22 or
            l_succod = 24 or l_succod = 26) then
            let l_flag = 2
        else
           if (l_c24astcod = "H10" or l_c24astcod = "H11") and
              (l_succod = 2 or l_succod = 3 or l_succod = 4 or l_succod = 9 or
               l_succod = 10 or l_succod = 11 or l_succod = 13 or l_succod = 14 or
               l_succod = 18 or l_succod = 19 or l_succod = 21 or l_succod = 23) then
              let l_flag = 3
           else
              let l_flag = 4
           end if
        end if

        if (l_c24astcod = "H10" or
            l_c24astcod = "H11" ) and
           (l_succod = 2  or l_succod = 3  or
            l_succod = 4  or l_succod = 9  or
            l_succod = 10 or l_succod = 11 or
            l_succod = 13 or l_succod = 14 or
            l_succod = 18 or l_succod = 19 or
            l_succod = 21 or l_succod = 23) then
            let l_flag = 3
        end if

        return l_flag, l_avialgmtv, l_cpodes, l_texto
     end if
  end if

  open c_cta19m00_009 using l_lcvcod,
                          l_avivclcod

  whenever error continue
  fetch c_cta19m00_009 into l_avivclgrp
  whenever error stop
  if sqlca.sqlcode <> 0 then
     return l_flag, l_avialgmtv, l_cpodes, l_texto
  end if

  if l_avialgmtv = 1 then
     let l_data_saldo = l_avioccdat
  else
     let l_data_saldo = today
  end if

  let l_aux = 1

  if l_c24astcod = "KA1"  then
     call cts44g01_claus_azul(mr_param.succod,
                              531            ,
                              mr_param.aplnumdig,
                              mr_param.itmnumdig)
            returning l_temcls,l_clscod
  else
     call ctx01g01_claus_novo(mr_param.succod,
                         mr_param.aplnumdig  ,
                         mr_param.itmnumdig  ,
                         l_data_saldo        ,
                         l_aux               ,
                         l_avialgmtv         )
             returning l_clscod, l_dat_vigini, l_dat_vigfim
  end if
  if l_avialgmtv = 1  and l_avivclgrp = "A" then
     if l_clscod[1,2] = "26" or
        l_clscod[1,2] = "80" or
        l_clscod[1,2] = "58" or
        l_clscod = "033" or
        l_clscod = "33R" then
        let l_texto = "CLAUSULA: ",l_clscod
     else
        let l_texto = "1 DIARIA GRATUITA"
     end if
  end if

  if l_avialgmtv = 2  and  l_avivclgrp = "A" then
     if l_clscod = "033" or l_clscod = "33R" then
        let l_texto = "CLAUSULA: ",l_clscod
     else
        let l_texto = "1 DIARIA GRATUITA"
     end if
  end if

  return l_flag, l_avialgmtv, l_cpodes, l_texto

end function

#----------------------------#
 function cta19m00_veiculo()
#----------------------------#

  define l_vclcoddig like abbmveic.vclcoddig,
         l_vclanofbc like abbmveic.vclanofbc,
         l_vclanomdl like abbmveic.vclanomdl,
         l_vcllicnum like abbmveic.vcllicnum,
         l_vclchsinc like abbmveic.vclchsinc,
         l_vclchsfnl like abbmveic.vclchsfnl,
         l_vcltipcod like agbkveic.vcltipcod,
         l_vclmdlnom like agbkveic.vclmdlnom,
         l_vclmrccod like agbkmarca.vclmrccod,
         l_vcltipnom like agbktip.vcltipnom,
         l_vclmrcnom like agbkmarca.vclmrcnom,
         l_atdsrvorg like datmservico.atdsrvorg,
         l_asitipcod like datmservico.asitipcod,
         l_atddfttxt like datmservico.atddfttxt

  define l_vcldes     like datmservico.vcldes
  define l_chassi     char(20),
         l_ano_modelo char(20),
         l_categ      smallint,
         l_automatico char(3)

  initialize l_vcldes,    l_chassi,    l_ano_modelo, l_vclcoddig, l_vclanofbc,
             l_vclanomdl, l_vcllicnum, l_vclchsinc,  l_vclchsfnl, l_vcltipcod,
             l_vclmdlnom, l_vclmrccod, l_vcltipnom,  l_vclmrcnom, l_atdsrvorg,
             l_asitipcod, l_atddfttxt, l_categ,      l_automatico to null


  if mr_param.atdsrvnum is not null then
     open c_cta19m00_010 using mr_param.atdsrvnum,
                             mr_param.atdsrvano

     whenever error continue
     fetch c_cta19m00_010 into l_vcldes,
                             l_atdsrvorg,
                             l_vcllicnum,
                             l_atddfttxt,
                             l_asitipcod
     whenever error stop


     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
        else
           let m_flag  = true
           return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
        end if
     end if
  end if

  if m_ciaempcod = 1  or
     m_ciaempcod = 50 then

     if mr_param.aplnumdig is not null then
        open c_cta19m00_011 using mr_param.succod,
                                mr_param.aplnumdig,
                                mr_param.itmnumdig,
                                g_funapol.vclsitatu

        whenever error continue

        fetch c_cta19m00_011 into l_vclcoddig,
                                l_vclanofbc,
                                l_vclanomdl,
                                l_vcllicnum,
                                l_vclchsinc,
                                l_vclchsfnl
        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
              open c_cta19m00_047 using mr_param.succod,
                                      mr_param.aplnumdig,
                                      mr_param.itmnumdig

              whenever error continue
              fetch c_cta19m00_047 into l_vclcoddig,
                                      l_vclanofbc,
                                      l_vclanomdl,
                                      l_vcllicnum,
                                      l_vclchsinc,
                                      l_vclchsfnl
              whenever error stop


              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = 100 then
                 else
                    let m_flag  = true
                    return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
                 end if
              end if
           else
              let m_flag  = true
              return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
           end if
        end if
     end if

     if mr_param.aplnumdig is not null then
        open c_cta19m00_012 using mr_param.prporg,
                                mr_param.prpnumdig

        whenever error continue
           fetch c_cta19m00_012 into l_vclcoddig,
                                l_vclanofbc,
                                l_vclanomdl,
                                l_vcllicnum,
                                l_vclchsinc,
                                l_vclchsfnl
        whenever error stop
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
           else
              let m_flag  = true
              return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
           end if
        end if
     end if

     open c_cta19m00_013 using l_vclcoddig

     whenever error continue
     fetch c_cta19m00_013 into l_vclmrccod,
                             l_vcltipcod,
                             l_vclmdlnom
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
        else
           let m_flag  = true
           return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
        end if
     end if

     open c_cta19m00_014 using l_vclmrccod

     whenever error continue
     fetch c_cta19m00_014 into l_vclmrcnom
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
        else
           let m_flag  = true
           return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
        end if
     end if

     open c_cta19m00_015 using l_vclmrccod,
                             l_vcltipcod

     whenever error continue
     fetch c_cta19m00_015 into l_vcltipnom
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
        else
           let m_flag  = true
           return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes
        end if
     end if

     let l_chassi = l_vclchsinc,l_vclchsfnl
     let l_ano_modelo = l_vclanofbc,"/",l_vclanomdl
  else

     if m_ciaempcod = 35 then
        if m_status_xml = 1 then
           call cts40g02_extraiDoXML(m_doc_handle, "VEICULO")
                returning l_vclcoddig,
                          l_vclmrcnom,
                          l_vcltipnom,
                          l_vclmdlnom,
                          l_chassi,
                          l_vcllicnum,
                          l_vclanofbc,
                          l_vclanomdl,
                          l_categ,
                          l_automatico

           let l_ano_modelo = l_vclanofbc,"/",l_vclanomdl

        end if
     end if

     if m_ciaempcod = 84 then

        let l_vclmrcnom  = g_doc_itau[1].autfbrnom
        let l_vcltipnom  = g_doc_itau[1].autlnhnom
        let l_vclmdlnom  = g_doc_itau[1].autmodnom
        let l_chassi     = g_doc_itau[1].autchsnum
        let l_ano_modelo = g_doc_itau[1].autfbrano, "/", g_doc_itau[1].autmodano
        let l_vcllicnum  = g_doc_itau[1].autplcnum

     end if

  end if

  return l_vclmrcnom, l_vcltipnom, l_vclmdlnom, l_chassi, l_ano_modelo, l_vcllicnum, l_vcldes

end function

#-----------------------------------------------------------------------------
 function cta19m00_envia(param)
#-----------------------------------------------------------------------------
  define param record
         c24trxnum like dammtrx.c24trxnum
  end record
  define cta19m00_msg record
         sistema   char(10) ,
         de        char(50) ,
         para      char(5000),
         subject   char(100),
         msg       char(32000),
         arquivo   char(300)
  end record
  define ws record
        msglog    char(300),
        hora      datetime hour to second,
        data      char(10)
  end record

  define cmd          char(32000)
  define ret          integer
  define r_dammtrx    record like dammtrx.*
  define r_dammtrxtxt record like dammtrxtxt.*
  define r_dammtrxdst record like dammtrxdst.*
  define w_usuario    char(500)
  define w_usuariocc  char(500)
  define w_titulo     char(300)
  define f_cmd        char(1500)
  define l_erro       smallint,
         l_para       char(1000),
         l_email      like datkdominio.cponom
  define l_tamanho    integer

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

        let     cmd         = null
        let     ret         = null
        let     w_usuario   = null
        let     w_usuariocc = null
        let     w_titulo    = null
        let     f_cmd       = null
        let     l_tamanho   = 0


        initialize  cta19m00_msg.*  to  null
        initialize  ws.*  to  null
        initialize  r_dammtrx.*  to  null
        initialize  r_dammtrxtxt.*  to  null
        initialize  r_dammtrxdst.*  to  null

  let f_cmd = 'select c24trxnum '
                   ,',c24msgtrxstt '
                   ,',c24msgtit '
                   ,',atdsrvnum '
                   ,',lignum '
               ,'from dammtrx '
              ,'where c24trxnum = ? '
                ,'and c24msgtrxstt = 9'
  prepare p_cta19m00_087   from f_cmd
  declare c_cta19m00_087   cursor for p_cta19m00_087


  let f_cmd = "select c24trxtxt "
                   ,",c24trxlinnum "
               ,"from dammtrxtxt "
              ,"where c24trxnum  = ? "
              ,"order by 2 "
  prepare p_cta19m00_088 from f_cmd
  declare c_cta19m00_088 cursor for p_cta19m00_088

  let f_cmd = " SELECT cpodes      "
                    ,"FROM datkdominio "
                   ,"WHERE cponom = ?  "
  prepare p_cta19m00_086 from f_cmd
  declare c_cta19m00_086 cursor with hold for p_cta19m00_086
 #---------------------------------------------------------------------------

  let l_erro = false
  let l_email = "reclamacao_ps"
  begin work

  open c_cta19m00_087 using param.c24trxnum
  foreach c_cta19m00_087 into r_dammtrx.c24trxnum   ,
                              r_dammtrx.c24msgtrxstt ,
                              r_dammtrx.c24msgtit    ,
                              r_dammtrx.atdsrvnum    ,
                              r_dammtrx.lignum

      open c_cta19m00_086 using l_email
       foreach c_cta19m00_086 into l_para


           initialize cta19m00_msg to null
           initialize cmd          to null

              let w_titulo = r_dammtrx.c24msgtit clipped

           open  c_cta19m00_088 using  r_dammtrx.c24trxnum
           foreach c_cta19m00_088 into r_dammtrxtxt.c24trxtxt,
                                       r_dammtrxtxt.c24trxlinnum

              if r_dammtrxtxt.c24trxtxt is null or
                 r_dammtrxtxt.c24trxtxt = " " then
                 continue foreach
              else
                let cta19m00_msg.msg = cta19m00_msg.msg clipped, '<br>',
                                       r_dammtrxtxt.c24trxtxt
              end if
            end foreach

           let w_usuario = l_para

              let cta19m00_msg.sistema = "ct24hs"
              let cta19m00_msg.de    = "ct24hs.email@portoseguro.com.br"
              let cta19m00_msg.para  = w_usuario
              let cta19m00_msg.subject = w_titulo
              let cta19m00_msg.arquivo    = ""
              let ws.data              = today
              let ws.hora              = current hour to second

            #PSI-2013-23297 - Inicio

             let l_mail.de = cta19m00_msg.de
             #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
             let l_mail.para = cta19m00_msg.para
             let l_mail.cc = ""
             let l_mail.cco = ""
             let l_mail.assunto = cta19m00_msg.subject
             let l_mail.mensagem = cta19m00_msg.msg
             let l_mail.id_remetente = "CT24HS"
             let l_mail.tipo = "html"
             call figrc009_mail_send1 (l_mail.*)
                returning l_coderro,msg_erro
             #PSI-2013-23297 - Fim

     end foreach

     if l_erro then
        exit foreach
     end if

     update dammtrx
        set (c24msgtrxstt,
             c24msgtrxdat,
             c24msgtrxhor)
          = (2,
             today,
             current hour to minute)
      where c24trxnum    = r_dammtrx.c24trxnum

  end foreach

  if l_erro then
     call cts10g13_grava_rastreamento(r_dammtrx.lignum                      ,
                                      '1'                                   ,
                                      'cta19m00'                            ,
                                      '1'                                   ,
                                      '1- Erro ao Gerar Numero de Mensagem' ,
                                      ' '                                   )
     rollback work
  else
     call cts10g13_grava_rastreamento(r_dammtrx.lignum                      ,
                                      '1'                                   ,
                                      'cta19m00'                            ,
                                      '0'                                   ,
                                      '2- Mensagem Enviada Com Sucesso'     ,
                                      w_usuario                             )
     commit work
  end if

 end function
