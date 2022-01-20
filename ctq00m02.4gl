#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HS                                              #
# Modulo        : ctq00m02                                                   #
# Analista Resp.: Alberto Rodrigues / Nilo                                   #
# PSI           :                                                            #
# OSF           :                                                            #
#                 Interface para o sistema Sinistro via MQ, para visualizar  #
#                 Laudo de Vidros                                            #
#............................................................................#
# Desenvolvimento: Alberto, Porto Seguro                                     #
# Liberacao      :                                                           #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 27/02/2008                                                                 #
#----------------------------------------------------------------------------#
#globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_ctq00m02_prep smallint


#main

#define lxml char(5000)

#   let lxml = null

#   call ctq00m02(14,'2008',1233909,0)
#   call ctq00m02(531,'2007',141704,0)
#   call ctq00m02(531,'2007',0,0)
#        returning lxml

#   display "XML_2: " ,lxml

#   display "rodou..."

#end main

#-------------------------#
function ctq00m02_prepare()
#-------------------------#

  define l_sql char(1500)

  let l_sql = " select a.orrdat, ",
                     " a.orrhor, ",
                     " a.sinvstnum, ",
                     " a.sinvstano, ",
                     " a.sinnum, ",
                     " a.sinano, ",
                     " a.aplnumdig ",
                " from ssamsin a ",
                    " ,ssamitem b ",
               " where a.ramcod = ? ",
                 " and a.sinnum = ? ",
                 " and a.sinano = ? ",
                 " and b.ramcod = a.ramcod ",
                 " and b.sinnum = a.sinnum ",
                 " and b.sinano = a.sinano ",
                 " and b.sinitmseq = ? "

  prepare pctq00m02001 from l_sql
  declare cctq00m02001 cursor for pctq00m02001

  let l_sql = " select c.c24solnom, ",
                     " c.atdsrvnum, ",
                     " c.atdsrvano, ",
                     " c.lignum, ",
                     " d.viginc, ",
                     " d.vigfnl, ",
                     " d.atntip, ",
                     " d.ocrendlgd, ",
                     " d.ocrendbrr, ",
                     " d.ocrendcid, ",
                     " d.ocrcttnom, ",
                     " d.segnom, ",
                     " d.cgccpfnum, ",
                     " d.cgcord, ",
                     " d.cgccpfdig, ",
                     " d.segdddcod, ",
                     " d.segteltxt, ",
                     " d.atddatprg, ",
                     " d.atdhorprg, ",
                     " d.atdhorpvt, ",
                     " d.corsus, ",
                     " d.cornom, ",
                     " d.cordddcod, ",
                     " d.corteltxt, ",
                     " d.vcldes, ",
                     " d.vclchsnum, ",
                     " d.vcllicnum, ",
                     " d.vclanofbc, ",
                     " d.vclanomdl, ",
                     " d.clscod, ",
                     " d.clsdes, ",
                     " d.vdrpbsfrqvlr, ",
                     " d.vdrvgafrqvlr, ",
                     " d.vdresqfrqvlr, ",
                     " d.vdrdirfrqvlr, ",
                     " d.ocudirfrqvlr, ",
                     " d.ocuesqfrqvlr, ",
                     " d.vdrqbvfrqvlr, ",
                     " d.vdrpbsavrfrqvlr, ",
                     " d.vdrvgaavrfrqvlr, ",
                     " d.vdresqavrfrqvlr, ",
                     " d.vdrdiravrfrqvlr, ",
                     " d.ocudiravrfrqvlr, ",
                     " d.ocuesqavrfrqvlr, ",
                     " d.vdrqbvavrfrqvlr, ",
                     " d.vdrrprgrpcod, ",
                     " d.vdrrprempcod ",
                " from datrligsinvst b, ",
                     " datmligacao c, ",
                     " datmsrvext1 d ",
               " where b.sinvstnum = ? ",
                 " and b.sinvstano = ? ",
                 " and b.ramcod    = ? ",
                 " and c.lignum    = b.lignum ",
                 " and d.atdsrvnum = c.atdsrvnum ",
                 " and d.atdsrvano = c.atdsrvano ",
                 " and d.lignum    = c.lignum "

  prepare pctq00m02002 from l_sql
  declare cctq00m02002 cursor for pctq00m02002

  let l_sql = " select e.vdrrprempnom ",
                " from adikvdrrpremp e ",
               " where e.vdrrprgrpcod = ? ",
                 " and e.vdrrprempcod = ? "

  prepare pctq00m02003 from l_sql
  declare cctq00m02003 cursor for pctq00m02003

  let l_sql = " select max(atdsrvseq) ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pctq00m02004 from l_sql
  declare cctq00m02004 cursor for pctq00m02004

  let l_sql = " select atdetpcod ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = ? "

  prepare pctq00m02005 from l_sql
  declare cctq00m02005 cursor for pctq00m02005

  let l_sql = " select atdetpdes ",
                " from datketapa ",
               " where atdetpcod = ? "

  prepare pctq00m02006 from l_sql
  declare cctq00m02006 cursor for pctq00m02006

  let m_ctq00m02_prep = true

end function

#----------------------------------
function ctq00m02(lr_param)
#----------------------------------

 define  lr_param      record
  sinramcod     like ssamsin.ramcod          ,# 01 ssamsin.ramcod
  sinano        like ssamsin.sinano          ,# 02 ssamsin.sinano
  sinnum        like ssamsin.sinnum          ,# 03 ssamsin.sinnum
  sinitmseq     like ssamitem.sinitmseq       # 04 ssamitem.sinitmseq
 end record

 define  lr_aux           record
         c24solnom        like datmligacao.c24solnom,
         atdsrvnum        like datmligacao.atdsrvnum,
         atdsrvano        like datmligacao.atdsrvano,
         atdsrvseq        like datmsrvacp.atdsrvseq,
         atdetpcod        like datmsrvacp.atdetpcod,
         atdetpdes        like datketapa.atdetpdes,
         lignum           like datmligacao.lignum,
         orrdat           like ssamsin.orrdat,
         orrhor           like ssamsin.orrhor,
         sinvstnum        like ssamsin.sinvstnum,
         sinvstano        like ssamsin.sinvstano,
         sinnum           like ssamsin.sinnum,
         sinano           like ssamsin.sinano,
         aplnumdig        like ssamsin.aplnumdig,
         viginc           like datmsrvext1.viginc,
         vigfnl           like datmsrvext1.vigfnl,
         atntip           like datmsrvext1.atntip,
         ocrendlgd        like datmsrvext1.ocrendlgd,
         ocrendbrr        like datmsrvext1.ocrendbrr,
         ocrendcid        like datmsrvext1.ocrendcid,
         ocrcttnom        like datmsrvext1.ocrcttnom,
         segnom           like datmsrvext1.segnom,
         cgccpfnum        like datmsrvext1.cgccpfnum,
         cgcord           like datmsrvext1.cgcord,
         cgccpfdig        like datmsrvext1.cgccpfdig,
         segdddcod        like datmsrvext1.segdddcod,
         segteltxt        like datmsrvext1.segteltxt,
         atddatprg        like datmsrvext1.atddatprg,
         atdhorprg        like datmsrvext1.atdhorprg,
         atdhorpvt        like datmsrvext1.atdhorpvt,
         corsus           like datmsrvext1.corsus,
         cornom           like datmsrvext1.cornom,
         cordddcod        like datmsrvext1.cordddcod,
         corteltxt        like datmsrvext1.corteltxt,
         vcldes           like datmsrvext1.vcldes,
         vclchsnum        like datmsrvext1.vclchsnum,
         vcllicnum        like datmsrvext1.vcllicnum,
         vclanofbc        like datmsrvext1.vclanofbc,
         vclanomdl        like datmsrvext1.vclanomdl,
         clscod           like datmsrvext1.clscod,
         clsdes           like datmsrvext1.clsdes,
         vdrpbsfrqvlr     like datmsrvext1.vdrpbsfrqvlr,
         vdrvgafrqvlr     like datmsrvext1.vdrvgafrqvlr,
         vdresqfrqvlr     like datmsrvext1.vdresqfrqvlr,
         vdrdirfrqvlr     like datmsrvext1.vdrdirfrqvlr,
         ocudirfrqvlr     like datmsrvext1.ocudirfrqvlr,
         ocuesqfrqvlr     like datmsrvext1.ocuesqfrqvlr,
         vdrqbvfrqvlr     like datmsrvext1.vdrqbvfrqvlr,
         vdrpbsavrfrqvlr  like datmsrvext1.vdrpbsavrfrqvlr,
         vdrvgaavrfrqvlr  like datmsrvext1.vdrvgaavrfrqvlr,
         vdresqavrfrqvlr  like datmsrvext1.vdresqavrfrqvlr,
         vdrdiravrfrqvlr  like datmsrvext1.vdrdiravrfrqvlr,
         ocudiravrfrqvlr  like datmsrvext1.ocudiravrfrqvlr,
         ocuesqavrfrqvlr  like datmsrvext1.ocuesqavrfrqvlr,
         vdrqbvavrfrqvlr  like datmsrvext1.vdrqbvavrfrqvlr,
         vdrrprgrpcod     like adikvdrrpremp.vdrrprgrpcod,
         vdrrprempcod     like adikvdrrpremp.vdrrprempcod,
         vdrrprempnom     like adikvdrrpremp.vdrrprempnom
 end record

 define l_retxml       char(5000)

 initialize lr_aux.* to null

 let l_retxml = null

 if m_ctq00m02_prep is null or
    m_ctq00m02_prep <> true then
    call ctq00m02_prepare()
 end if

 open cctq00m02001 using lr_param.sinramcod
                        ,lr_param.sinnum
                        ,lr_param.sinano
                        ,lr_param.sinitmseq
 whenever error continue
 fetch cctq00m02001 into lr_aux.orrdat
                        ,lr_aux.orrhor
                        ,lr_aux.sinvstnum
                        ,lr_aux.sinvstano
                        ,lr_aux.sinnum
                        ,lr_aux.sinano
                        ,lr_aux.aplnumdig


 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Registro nao encontrado no acesso a tabela ssamsin - cctq00m02001.</msg>"
                     ,"</mq>"
           return l_retxml
    else
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Erro - (" ,sqlca.sqlcode using "<<<<<<<<<<<",") no acesso a tabela ssamsin - cctq00m02001.</msg>"
                     ,"</mq>"
           return l_retxml
    end if
 end if

 open cctq00m02002 using lr_aux.sinvstnum
                        ,lr_aux.sinvstano
                        ,lr_param.sinramcod
 whenever error continue
 fetch cctq00m02002 into lr_aux.c24solnom
                        ,lr_aux.atdsrvnum
                        ,lr_aux.atdsrvano
                        ,lr_aux.lignum
                        ,lr_aux.viginc
                        ,lr_aux.vigfnl
                        ,lr_aux.atntip
                        ,lr_aux.ocrendlgd
                        ,lr_aux.ocrendbrr
                        ,lr_aux.ocrendcid
                        ,lr_aux.ocrcttnom
                        ,lr_aux.segnom
                        ,lr_aux.cgccpfnum
                        ,lr_aux.cgcord
                        ,lr_aux.cgccpfdig
                        ,lr_aux.segdddcod
                        ,lr_aux.segteltxt
                        ,lr_aux.atddatprg
                        ,lr_aux.atdhorprg
                        ,lr_aux.atdhorpvt
                        ,lr_aux.corsus
                        ,lr_aux.cornom
                        ,lr_aux.cordddcod
                        ,lr_aux.corteltxt
                        ,lr_aux.vcldes
                        ,lr_aux.vclchsnum
                        ,lr_aux.vcllicnum
                        ,lr_aux.vclanofbc
                        ,lr_aux.vclanomdl
                        ,lr_aux.clscod
                        ,lr_aux.clsdes
                        ,lr_aux.vdrpbsfrqvlr
                        ,lr_aux.vdrvgafrqvlr
                        ,lr_aux.vdresqfrqvlr
                        ,lr_aux.vdrdirfrqvlr
                        ,lr_aux.ocudirfrqvlr
                        ,lr_aux.ocuesqfrqvlr
                        ,lr_aux.vdrqbvfrqvlr
                        ,lr_aux.vdrpbsavrfrqvlr
                        ,lr_aux.vdrvgaavrfrqvlr
                        ,lr_aux.vdresqavrfrqvlr
                        ,lr_aux.vdrdiravrfrqvlr
                        ,lr_aux.ocudiravrfrqvlr
                        ,lr_aux.ocuesqavrfrqvlr
                        ,lr_aux.vdrqbvavrfrqvlr
                        ,lr_aux.vdrrprgrpcod
                        ,lr_aux.vdrrprempcod

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode  = notfound then
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Registro nao encontrado no acesso ao join principal - cctq00m02002.</msg>"
                     ,"</mq>"
           return l_retxml
    else
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Erro - (" ,sqlca.sqlcode using "<<<<<<<<<<<",") no acesso ao join principal - cctq00m02002.</msg>"
                     ,"</mq>"
           return l_retxml
    end if
 end if

 open cctq00m02003 using lr_aux.vdrrprgrpcod
                        ,lr_aux.vdrrprempcod
 whenever error continue
 fetch cctq00m02003 into lr_aux.vdrrprempnom

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode  = notfound then
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Registro nao encontrado no acesso a tabela adikvdrrpremp - cctq00m02003.</msg>"
                     ,"</mq>"
           return l_retxml
    else
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Erro - (" ,sqlca.sqlcode using "<<<<<<<<<<<",") no acesso a tabela adikvdrrpremp - cctq00m02003.</msg>"
                     ,"</mq>"
           return l_retxml
    end if
 end if

 open cctq00m02004 using lr_aux.atdsrvnum
                        ,lr_aux.atdsrvano
 whenever error continue
 fetch cctq00m02004 into lr_aux.atdsrvseq

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode  = notfound then
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Registro nao encontrado no acesso a tabela datmsrvacp (01) - cctq00m02004.</msg>"
                     ,"</mq>"
           return l_retxml
    else
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Erro - (" ,sqlca.sqlcode using "<<<<<<<<<<<",") no acesso a tabela datmsrvacp (01) - cctq00m02004.</msg>"
                     ,"</mq>"
           return l_retxml
    end if
 end if

 open cctq00m02005 using lr_aux.atdsrvnum
                        ,lr_aux.atdsrvano
                        ,lr_aux.atdsrvseq
 whenever error continue
 fetch cctq00m02005 into lr_aux.atdetpcod

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode  = notfound then
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Registro nao encontrado no acesso a tabela datmsrvacp (02) - cctq00m02005.</msg>"
                     ,"</mq>"
           return l_retxml
    else
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Erro - (" ,sqlca.sqlcode using "<<<<<<<<<<<",") no acesso a tabela datmsrvacp (02) - cctq00m02005.</msg>"
                     ,"</mq>"
           return l_retxml
    end if
 end if

 open cctq00m02006 using lr_aux.atdetpcod
 whenever error continue
 fetch cctq00m02006 into lr_aux.atdetpdes

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode  = notfound then
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Registro nao encontrado no acesso a tabela datketapa - cctq00m02006.</msg>"
                     ,"</mq>"
           return l_retxml
    else
       let l_retxml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<mq>"
                     ,"<servico>ERRO</servico>"
                     ,"<msg>Erro - (" ,sqlca.sqlcode using "<<<<<<<<<<<",") no acesso a tabela datketapa - cctq00m02006.</msg>"
                     ,"</mq>"
           return l_retxml
    end if
 end if

 # sleep 3

 call ctq00m02_monta_xml(lr_aux.*)
    returning l_retxml

 return l_retxml

 end function

#-----------------------------------------------
 function ctq00m02_monta_xml(lr_param)
#-----------------------------------------------

 define lr_param         record
        c24solnom        like datmligacao.c24solnom,
        atdsrvnum        like datmligacao.atdsrvnum,
        atdsrvano        like datmligacao.atdsrvano,
        atdsrvseq        like datmsrvacp.atdsrvseq,
        atdetpcod        like datmsrvacp.atdetpcod,
        atdetpdes        like datketapa.atdetpdes,
        lignum           like datmligacao.lignum,
        orrdat           like ssamsin.orrdat,
        orrhor           like ssamsin.orrhor,
        sinvstnum        like ssamsin.sinvstnum,
        sinvstano        like ssamsin.sinvstano,
        sinnum           like ssamsin.sinnum,
        sinano           like ssamsin.sinano,
        aplnumdig        like ssamsin.aplnumdig,
        viginc           like datmsrvext1.viginc,
        vigfnl           like datmsrvext1.vigfnl,
        atntip           like datmsrvext1.atntip,
        ocrendlgd        like datmsrvext1.ocrendlgd,
        ocrendbrr        like datmsrvext1.ocrendbrr,
        ocrendcid        like datmsrvext1.ocrendcid,
        ocrcttnom        like datmsrvext1.ocrcttnom,
        segnom           like datmsrvext1.segnom,
        cgccpfnum        like datmsrvext1.cgccpfnum,
        cgcord           like datmsrvext1.cgcord,
        cgccpfdig        like datmsrvext1.cgccpfdig,
        segdddcod        like datmsrvext1.segdddcod,
        segteltxt        like datmsrvext1.segteltxt,
        atddatprg        like datmsrvext1.atddatprg,
        atdhorprg        like datmsrvext1.atdhorprg,
        atdhorpvt        like datmsrvext1.atdhorpvt,
        corsus           like datmsrvext1.corsus,
        cornom           like datmsrvext1.cornom,
        cordddcod        like datmsrvext1.cordddcod,
        corteltxt        like datmsrvext1.corteltxt,
        vcldes           like datmsrvext1.vcldes,
        vclchsnum        like datmsrvext1.vclchsnum,
        vcllicnum        like datmsrvext1.vcllicnum,
        vclanofbc        like datmsrvext1.vclanofbc,
        vclanomdl        like datmsrvext1.vclanomdl,
        clscod           like datmsrvext1.clscod,
        clsdes           like datmsrvext1.clsdes,
        vdrpbsfrqvlr     like datmsrvext1.vdrpbsfrqvlr,
        vdrvgafrqvlr     like datmsrvext1.vdrvgafrqvlr,
        vdresqfrqvlr     like datmsrvext1.vdresqfrqvlr,
        vdrdirfrqvlr     like datmsrvext1.vdrdirfrqvlr,
        ocudirfrqvlr     like datmsrvext1.ocudirfrqvlr,
        ocuesqfrqvlr     like datmsrvext1.ocuesqfrqvlr,
        vdrqbvfrqvlr     like datmsrvext1.vdrqbvfrqvlr,
        vdrpbsavrfrqvlr  like datmsrvext1.vdrpbsavrfrqvlr,
        vdrvgaavrfrqvlr  like datmsrvext1.vdrvgaavrfrqvlr,
        vdresqavrfrqvlr  like datmsrvext1.vdresqavrfrqvlr,
        vdrdiravrfrqvlr  like datmsrvext1.vdrdiravrfrqvlr,
        ocudiravrfrqvlr  like datmsrvext1.ocudiravrfrqvlr,
        ocuesqavrfrqvlr  like datmsrvext1.ocuesqavrfrqvlr,
        vdrqbvavrfrqvlr  like datmsrvext1.vdrqbvavrfrqvlr,
        vdrrprgrpcod     like adikvdrrpremp.vdrrprgrpcod,
        vdrrprempcod     like adikvdrrpremp.vdrrprempcod,
        vdrrprempnom     like adikvdrrpremp.vdrrprempnom
 end record

 define aux              record
        atdsrvnum        char(10)
       ,lignum		 char(10)
       ,sinnum		 char(06)
       ,sinano		 char(04)
       ,viginc		 char(10)
       ,vigfnl		 char(10)
       ,atdsrvano        char(04)
       ,orrdat           char(10)
       ,orrhor           char(05)
       ,sinvstnum        char(06)
       ,sinvstano        char(04)
       ,aplnumdig        char(09)
       ,cgccpfnum        char(12)
       ,cgcord           char(04)
       ,cgccpfdig        char(02)
       ,atddatprg        char(10)
       ,atdhorprg        char(05)
       ,atdhorpvt        char(05)
       ,vclanofbc        char(04)
       ,vclanomdl        char(04)
       ,vdrpbsfrqvlr     char(15)
       ,vdrvgafrqvlr     char(15)
       ,vdresqfrqvlr     char(15)
       ,vdrdirfrqvlr     char(15)
       ,ocudirfrqvlr     char(14)
       ,ocuesqfrqvlr     char(14)
       ,vdrqbvfrqvlr     char(14)
       ,vdrpbsavrfrqvlr  char(15)
       ,vdrvgaavrfrqvlr  char(15)
       ,vdresqavrfrqvlr  char(15)
       ,vdrdiravrfrqvlr  char(15)
       ,ocudiravrfrqvlr  char(14)
       ,ocuesqavrfrqvlr  char(14)
       ,vdrqbvavrfrqvlr  char(14)
       ,vdrrprempcod     char(05)
 end record

 define l_xml       char(5000)
 define l_aux       integer

 define lr_aux_atndesc char(12)

 initialize aux.* to null

 let l_xml          = null
 let lr_aux_atndesc = null

 case lr_param.atntip
     when 01
        let lr_aux_atndesc = 'REDE'
     when 02
        let lr_aux_atndesc = 'FORA DA REDE'
     when 03
        let lr_aux_atndesc = 'AMBOS'
 end case

 if lr_param.atdsrvnum    is null then
    let aux.atdsrvnum = ''
 else
    let aux.atdsrvnum = lr_param.atdsrvnum using   "<<<<<<<<<<"
 end if

 if lr_param.lignum    is null then
    let aux.lignum = ''
 else
    let aux.lignum = lr_param.lignum  using   "<<<<<<<<<<"
 end if

 if lr_param.sinnum    is null then
    let aux.sinnum = ''
 else
    let aux.sinnum = lr_param.sinnum  using "<<<<<<"
 end if

 if lr_param.sinano    is null then
    let aux.sinano = ''
 else
    let aux.sinano = lr_param.sinano
 end if

 if lr_param.viginc    is null then
    let aux.viginc = ''
 else
    let aux.viginc = lr_param.viginc  using "dd/mm/yyyy"
 end if

 if lr_param.vigfnl    is null then
    let aux.vigfnl = ''
 else
    let aux.vigfnl = lr_param.vigfnl  using "dd/mm/yyyy"
 end if

 if lr_param.orrdat    is null then
    let aux.orrdat = ''
 else
    let aux.orrdat = lr_param.orrdat  using "dd/mm/yyyy"
 end if

 if lr_param.orrhor    is null then
    let aux.orrhor = ''
 else
    let aux.orrhor = lr_param.orrhor
 end if

 if lr_param.sinvstnum is null then
    let aux.sinvstnum = ''
 else
    let aux.sinvstnum = lr_param.sinvstnum using "<<<<<<"
 end if

 if lr_param.sinvstano is null then
    let aux.sinvstano = ''
 else
    let aux.sinvstano = lr_param.sinvstano
 end if

 if lr_param.aplnumdig is null then
    let aux.aplnumdig = ''
 else
    let aux.aplnumdig = lr_param.aplnumdig using "<<<<<<<<<<"
 end if

 if lr_param.cgccpfnum       is null then
    let aux.cgccpfnum = ''
 else
    let aux.cgccpfnum = lr_param.cgccpfnum  using "<<<<<<<<<<<<"
 end if

 if lr_param.cgcord          is null then
    let aux.cgcord = ''
 else
    let aux.cgcord = lr_param.cgcord
 end if

 if lr_param.cgccpfdig       is null then
    let aux.cgccpfdig = ''
 else
    let aux.cgccpfdig = lr_param.cgccpfdig using "<<"
 end if

 if lr_param.atddatprg       is null then
    let aux.atddatprg = ''
 else
    let aux.atddatprg = lr_param.atddatprg using "dd/mm/yyyy"
 end if

 if lr_param.atdhorprg       is null then
    let aux.atdhorprg = ''
 else
    let aux.atdhorprg = lr_param.atdhorprg
 end if

 if lr_param.atdhorpvt       is null then
    let aux.atdhorpvt = ''
 else
    let aux.atdhorpvt = lr_param.atdhorpvt
 end if

 if lr_param.vclanofbc       is null then
    let aux.vclanofbc = ''
 else
    let aux.vclanofbc = lr_param.vclanofbc
 end if

 if lr_param.vclanomdl       is null then
    let aux.vclanomdl = ''
 else
    let aux.vclanomdl = lr_param.vclanomdl
 end if

 if lr_param.vdrpbsfrqvlr    is null then
    let aux.vdrpbsfrqvlr = ''
 else
    let aux.vdrpbsfrqvlr = lr_param.vdrpbsfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.vdrvgafrqvlr    is null then
    let aux.vdrvgafrqvlr = ''
 else
    let aux.vdrvgafrqvlr = lr_param.vdrvgafrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.vdresqfrqvlr    is null then
    let aux.vdresqfrqvlr = ''
 else
    let aux.vdresqfrqvlr = lr_param.vdresqfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.vdrdirfrqvlr    is null then
    let aux.vdrdirfrqvlr = ''
 else
    let aux.vdrdirfrqvlr = lr_param.vdrdirfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.ocudirfrqvlr    is null then
    let aux.ocudirfrqvlr = ''
 else
    let aux.ocudirfrqvlr = lr_param.ocudirfrqvlr using "<<<<<<<<<<<<&.<&"
 end if

 if lr_param.ocuesqfrqvlr    is null then
    let aux.ocuesqfrqvlr = ''
 else
    let aux.ocuesqfrqvlr = lr_param.ocuesqfrqvlr using "<<<<<<<<<<<<&.<&"
 end if

 if lr_param.vdrqbvfrqvlr    is null then
    let aux.vdrqbvfrqvlr = ''
 else
    let aux.vdrqbvfrqvlr = lr_param.vdrqbvfrqvlr using "<<<<<<<<<<<<&.<&"
 end if

 if lr_param.vdrpbsavrfrqvlr is null then
    let aux.vdrpbsavrfrqvlr = ''
 else
    let aux.vdrpbsavrfrqvlr = lr_param.vdrpbsavrfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.vdrvgaavrfrqvlr is null then
    let aux.vdrvgaavrfrqvlr = ''
 else
    let aux.vdrvgaavrfrqvlr = lr_param.vdrvgaavrfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.vdresqavrfrqvlr is null then
    let aux.vdresqavrfrqvlr = ''
 else
    let aux.vdresqavrfrqvlr = lr_param.vdresqavrfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.vdrdiravrfrqvlr is null then
    let aux.vdrdiravrfrqvlr = ''
 else
    let aux.vdrdiravrfrqvlr = lr_param.vdrdiravrfrqvlr using "<<<<<<<<<<&.<<<<&"
 end if

 if lr_param.ocudiravrfrqvlr is null then
    let aux.ocudiravrfrqvlr = ''
 else
    let aux.ocudiravrfrqvlr = lr_param.ocudiravrfrqvlr using "<<<<<<<<<<<<&.<&"
 end if

 if lr_param.ocuesqavrfrqvlr is null then
    let aux.ocuesqavrfrqvlr = ''
 else
    let aux.ocuesqavrfrqvlr = lr_param.ocuesqavrfrqvlr using "<<<<<<<<<<<<&.<&"
 end if

 if lr_param.vdrqbvavrfrqvlr is null then
    let aux.vdrqbvavrfrqvlr = ''
 else
    let aux.vdrqbvavrfrqvlr = lr_param.vdrqbvavrfrqvlr using "<<<<<<<<<<<<&.<&"
 end if

 if lr_param.vdrrprempcod    is null then
    let aux.vdrrprempcod = ''
 else
    let aux.vdrrprempcod = lr_param.vdrrprempcod using "<<<<<"
 end if

 # display 'Monta xml...'
 # display 'lr_param.vdrrprempnom   : ',lr_param.vdrrprempnom
 # display 'aux.vdrrprempcod        : ',aux.vdrrprempcod clipped
 # display 'lr_param.c24solnom      : ',lr_param.c24solnom
 # display 'lr_param.atdetpdes      : ',lr_param.atdetpdes clipped
 # display 'aux.atdsrvnum           : ',aux.atdsrvnum clipped
 # display 'aux.atdsrvano           : ',aux.atdsrvano clipped
 # display 'aux.lignum              : ',aux.lignum clipped
 # display 'aux.orrdat              : ',aux.orrdat clipped
 # display 'aux.orrhor              : ',aux.orrhor clipped
 # display 'aux.sinvstnum           : ',aux.sinvstnum clipped
 # display 'aux.sinvstano           : ',aux.sinvstano clipped
 # display 'aux.sinnum              : ',aux.sinnum clipped
 # display 'aux.sinano              : ',aux.sinano clipped
 # display 'aux.aplnumdig           : ',aux.aplnumdig clipped
 # display 'aux.viginc              : ',aux.viginc clipped
 # display 'aux.vigfnl              : ',aux.vigfnl clipped
 # display 'lr_aux_atndesc          : ',lr_aux_atndesc
 # display 'lr_param.ocrendlgd      : ',lr_param.ocrendlgd
 # display 'lr_param.ocrendbrr      : ',lr_param.ocrendbrr
 # display 'lr_param.ocrendcid      : ',lr_param.ocrendcid
 # display 'lr_param.ocrcttnom      : ',lr_param.ocrcttnom
 # display 'lr_param.segnom         : ',lr_param.segnom
 # display 'aux.cgccpfnum           : ',aux.cgccpfnum clipped
 # display 'aux.cgcord              : ',aux.cgcord clipped
 # display 'aux.cgccpfdig           : ',aux.cgccpfdig clipped
 # display 'lr_param.segdddcod      : ',lr_param.segdddcod clipped
 # display 'lr_param.segteltxt      : ',lr_param.segteltxt clipped
 # display 'aux.atddatprg           : ',aux.atddatprg clipped
 # display 'aux.atdhorprg           : ',aux.atdhorprg clipped
 # display 'aux.atdhorpvt           : ',aux.atdhorpvt clipped
 # display 'lr_param.corsus         : ',lr_param.corsus
 # display 'lr_param.cornom         : ',lr_param.cornom
 # display 'lr_param.cordddcod      : ',lr_param.cordddcod clipped
 # display 'lr_param.corteltxt      : ',lr_param.corteltxt clipped
 # display 'lr_param.vcldes         : ',lr_param.vcldes    clipped
 # display 'lr_param.vclchsnum      : ',lr_param.vclchsnum clipped
 # display 'lr_param.vcllicnum      : ',lr_param.vcllicnum clipped
 # display 'aux.vclanofbc           : ',aux.vclanofbc
 # display 'aux.vclanomdl           : ',aux.vclanomdl
 # display 'lr_param.clscod         : ',lr_param.clscod clipped
 # display 'lr_param.clsdes         : ',lr_param.clsdes clipped
 # display 'aux.vdrpbsfrqvlr        : ',aux.vdrpbsfrqvlr clipped
 # display 'aux.vdrvgafrqvlr        : ',aux.vdrvgafrqvlr clipped
 # display 'aux.vdresqfrqvlr        : ',aux.vdresqfrqvlr clipped
 # display 'aux.vdrdirfrqvlr        : ',aux.vdrdirfrqvlr clipped
 # display 'aux.ocudirfrqvlr        : ',aux.ocudirfrqvlr clipped
 # display 'aux.ocuesqfrqvlr        : ',aux.ocuesqfrqvlr clipped
 # display 'aux.vdrqbvfrqvlr        : ',aux.vdrqbvfrqvlr clipped
 # display 'aux.vdrpbsavrfrqvlr     : ',aux.vdrpbsavrfrqvlr clipped
 # display 'aux.vdrvgaavrfrqvlr     : ',aux.vdrvgaavrfrqvlr clipped
 # display 'aux.vdresqavrfrqvlr     : ',aux.vdresqavrfrqvlr clipped
 # display 'aux.vdrdiravrfrqvlr     : ',aux.vdrdiravrfrqvlr clipped
 # display 'aux.ocudiravrfrqvlr     : ',aux.ocudiravrfrqvlr clipped
 # display 'aux.ocuesqavrfrqvlr     : ',aux.ocuesqavrfrqvlr clipped
 # display 'aux.vdrqbvavrfrqvlr     : ',aux.vdrqbvavrfrqvlr clipped


 let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
             "<mq>",
             "<param>",lr_param.vdrrprempnom clipped,"</param>",
             "<param>",aux.vdrrprempcod      clipped,"</param>",
             "<param>",lr_param.c24solnom    clipped,"</param>",
             "<param>",lr_param.atdetpdes    clipped,"</param>",
             "<param>",aux.atdsrvnum         clipped,"</param>",
             "<param>",aux.atdsrvano         clipped,"</param>",
             "<param>",lr_param.vcldes       clipped,"</param>",             
             "<param>",aux.lignum            clipped,"</param>",
             "<param>",aux.orrdat            clipped,"</param>",
             "<param>",aux.orrhor            clipped,"</param>",
             "<param>",aux.sinvstnum         clipped,"</param>",
             "<param>",aux.sinvstano         clipped,"</param>",
             "<param>",aux.sinnum            clipped,"</param>",
             "<param>",aux.sinano            clipped,"</param>",
             "<param>",aux.aplnumdig         clipped,"</param>",
             "<param>",aux.viginc            clipped,"</param>",
             "<param>",aux.vigfnl            clipped,"</param>",
             "<param>",lr_aux_atndesc        clipped,"</param>",
             "<param>",lr_param.ocrendlgd    clipped,"</param>",
             "<param>",lr_param.ocrendbrr    clipped,"</param>",
             "<param>",lr_param.ocrendcid    clipped,"</param>",
             "<param>",lr_param.ocrcttnom    clipped,"</param>",
             "<param>",lr_param.segnom       clipped,"</param>",
             "<param>",aux.cgccpfnum         clipped,"</param>",
             "<param>",aux.cgcord            clipped,"</param>",
             "<param>",aux.cgccpfdig         clipped,"</param>",
             "<param>",lr_param.segdddcod    clipped,"</param>",
             "<param>",lr_param.segteltxt    clipped,"</param>",
             "<param>",aux.atddatprg         clipped,"</param>",
             "<param>",aux.atdhorprg         clipped,"</param>",
             "<param>",aux.atdhorpvt         clipped,"</param>",
             "<param>",lr_param.corsus       clipped,"</param>",
             "<param>",lr_param.cornom       clipped,"</param>",
             "<param>",lr_param.cordddcod    clipped,"</param>",
             "<param>",lr_param.corteltxt    clipped,"</param>",
             "<param>",lr_param.vcldes       clipped,"</param>",                          
             "<param>",lr_param.vclchsnum    clipped,"</param>",
             "<param>",lr_param.vcllicnum    clipped,"</param>",
             "<param>",aux.vclanofbc         clipped,"</param>",
             "<param>",aux.vclanomdl         clipped,"</param>",
             "<param>",lr_param.clscod       clipped,"</param>",
             "<param>",lr_param.clsdes       clipped,"</param>",
             "<param>",aux.vdrpbsfrqvlr      clipped,"</param>",
             "<param>",aux.vdrvgafrqvlr      clipped,"</param>",
             "<param>",aux.vdresqfrqvlr      clipped,"</param>",
             "<param>",aux.vdrdirfrqvlr      clipped,"</param>",
             "<param>",aux.ocudirfrqvlr      clipped,"</param>",
             "<param>",aux.ocuesqfrqvlr      clipped,"</param>",
             "<param>",aux.vdrqbvfrqvlr      clipped,"</param>",
             "<param>",aux.vdrpbsavrfrqvlr   clipped,"</param>",
             "<param>",aux.vdrvgaavrfrqvlr   clipped,"</param>",
             "<param>",aux.vdresqavrfrqvlr   clipped,"</param>",
             "<param>",aux.vdrdiravrfrqvlr   clipped,"</param>",
             "<param>",aux.ocudiravrfrqvlr   clipped,"</param>",
             "<param>",aux.ocuesqavrfrqvlr   clipped,"</param>",
             "<param>",aux.vdrqbvavrfrqvlr   clipped,"</param>",
             "</mq>"

display "XML: " ,l_xml clipped

   call ctq00m02_retira_caract_especiais(l_xml)
        returning l_xml

 return l_xml

end function

function ctq00m02_retira_caract_especiais(l_xml)

   define l_xml      char(32766)
   define l_xml_novo char(32766)
   define l_max      integer
   define i          integer   
   define l_teste     char(10)            
   define x          integer
   
            
   let l_max = length(l_xml)
   let l_xml_novo = null 
   let i = 0 
   let x = 0 
         
   if l_max > 0 then 
          
     for i = 1 to l_max   
       
       let l_teste = l_xml[i,i]               
       case l_xml[i,i]     
                           
       when '&'            
            let l_xml_novo = l_xml_novo clipped ,' &amp;'
            exit case                  
       otherwise                                   
          
          if l_xml[i,i] is null or
             l_xml[i,i] = " "   then
              let l_xml_novo = l_xml_novo clipped ," "     
          else   
              let x = i - 1 
              if x > 1 then 
                 if l_xml[x,x] is null or  
                    l_xml[x,x] = " "   then                    
                    let l_xml_novo = l_xml_novo clipped ," " ,l_xml[i,i] clipped    
                 else                                      
                    let l_xml_novo = l_xml_novo clipped ,l_xml[i,i] clipped
                 end if 
              else
                let l_xml_novo = l_xml_novo clipped ,l_xml[i,i] clipped
              end if                    
          end if                               
       end case            
     end for               
                           
   end if                  
                                                         
   return l_xml_novo       
          
   
end function    
   
   
   
   
   
   
   
   
   
   




