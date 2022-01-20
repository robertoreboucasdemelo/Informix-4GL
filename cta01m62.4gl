#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m62.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Espelho dos Documentos                                     #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 18/12/2007                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- -------------- ---------- --------------------------------------#
# 01/10/2008 Amilton, Meta  Psi 223689 Incluir tratamento de erro com a      #
#                                      global                                #
# 29/12/2009 Patricia W.               Projeto SUCCOD - Smallint             #
#----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS             #
#----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_neg_vig  smallint,
       m_prepare  smallint,
       m_vig      smallint,
       m_sair     smallint


#------------------------------------------------------------------------------
function cta01m62_prepare()
#------------------------------------------------------------------------------

define l_sql char(1000)

    let l_sql = " select succod "   ,
                ",ramcod "          ,
                ",aplnumdig "       ,
                ",itmnumdig "       ,
                ",edsnumdig "       ,
                " from datkazlapl " ,
                " where cgccpfnum = ? "
    prepare p_cta01m62_001  from l_sql
    declare c_cta01m62_001  cursor for p_cta01m62_001

    let l_sql = " select b.atdsrvnum, b.atdsrvano, "   ,
                " b.atddat, b.atdsrvorg           "   ,
                " from datrservapol a, datmservico b ",
                " where b.atdsrvnum   =  a.atdsrvnum ",
                " and   b.atdsrvano   =  a.atdsrvano ",
                " and a.succod     =  ? ",
                " and a.ramcod     =  ? ",
                " and a.aplnumdig  =  ? ",
                " and a.itmnumdig  =  ? ",
                " and a.edsnumref >=  0 "
    prepare p_cta01m62_002  from l_sql
    declare c_cta01m62_002  cursor for p_cta01m62_002

    let l_sql = " select b.atdsrvnum, b.atdsrvano, "  ,
                " b.atddat, b.atdsrvorg            "  ,
                " from datrservapol a, datmservico b ",
                " where b.atdsrvnum   =  a.atdsrvnum ",
                " and   b.atdsrvano   =  a.atdsrvano ",
                " and a.succod     =  ? ",
                " and a.ramcod     =  ? ",
                " and a.aplnumdig  =  ? ",
                " and a.itmnumdig  =  ? ",
                " and a.edsnumref >=  0 ",
                " and b.atdsrvorg  =  9 "
    prepare p_cta01m62_003  from l_sql
    declare c_cta01m62_003  cursor for p_cta01m62_003

    let l_sql = " select succod "   ,
                ",ramcod "          ,
                ",aplnumdig "       ,
                ",crtsaunum "       ,
                ",crtstt    "       ,
                ",bnfnum    "       ,
                " from datksegsau " ,
                " where cgccpfnum = ? "
    prepare p_cta01m62_004  from l_sql
    declare c_cta01m62_004  cursor for p_cta01m62_004

    let l_sql = " select b.atdsrvnum, b.atdsrvano, "     ,
                " b.atddat, b.atdsrvorg            "     ,
                " from datrsrvsau a, datmservico b   "   ,
                " where b.atdsrvnum   =  a.atdsrvnum "   ,
                " and   b.atdsrvano   =  a.atdsrvano "   ,
                " and a.crtnum   =  ? ",
                " and b.atdsrvorg  =  9 "
    prepare p_cta01m62_005 from l_sql
    declare c_cta01m62_005 cursor for p_cta01m62_005

    let l_sql = " select b.atdsrvnum, b.atdsrvano,   "   ,
                " b.atddat, b.atdsrvorg              "   ,
                " from datrsrvsau a, datmservico b   "   ,
                " where b.atdsrvnum   =  a.atdsrvnum "   ,
                " and   b.atdsrvano   =  a.atdsrvano "   ,
                " and a.crtnum   =  ? "
    prepare p_cta01m62_006 from l_sql
    declare c_cta01m62_006 cursor for p_cta01m62_006

    let l_sql = " select cpodes[3,50] "    ,
                " from iddkdominio  "   ,
                " where cpocod = ? "   ,
                " and   cponom = 'codprod' "
    prepare pcta01m62008 from l_sql
    declare ccta01m62008 cursor for pcta01m62008

    let l_sql = " select cpodes "    ,
                " from iddkdominio  "   ,
                " where cpocod = ? "   ,
                " and   cponom = 'sitprod' "
    prepare pcta01m62009 from l_sql
    declare ccta01m62009 cursor for pcta01m62009

    let l_sql = " select cpodes[1,1] "    ,
                " from iddkdominio  "   ,
                " where cpocod = ? "   ,
                " and   cponom = 'codprod' "
    prepare pcta01m62010 from l_sql
    declare ccta01m62010 cursor for pcta01m62010

    let l_sql = " select c.atdsrvnum, c.atdsrvano, "    ,
                " c.atddat, c.atdsrvorg            "    ,
                " from datrligcgccpf a, "               ,
                " datmligacao b, "                      ,
                " datmservico c "                       ,
                " where a.lignum = b.lignum "           ,
                " and b.atdsrvnum = c.atdsrvnum "       ,
                " and b.atdsrvano = c.atdsrvano "       ,
                " and a.cgccpfnum = ? "                 ,
                " and a.cgcord = ? "                    ,
                " and cgccpfdig = ? "                   ,
                " and b.ciaempcod = 40 "                ,
                " and b.c24astcod not in ('CON','ALT','REC','CAN','RET','IND')"
    prepare pcta01m62011 from l_sql
    declare ccta01m62011 cursor for pcta01m62011

    let l_sql =  " select atdetpcod   ",
                 "  from datmsrvacp   ",
                 " where atdsrvnum = ?",
                 "   and atdsrvano = ?",
                 "   and atdsrvseq = (select max(atdsrvseq)",
                                     "  from datmsrvacp    ",
                                     " where atdsrvnum = ? ",
                                     "   and atdsrvano = ?)"
    prepare pcta01m62012 from l_sql
    declare ccta01m62012 cursor for pcta01m62012

    let l_sql = " select count(*)   "    ,
                " from iddkdominio  "    ,
                " where cpocod = ?  "    ,
                " and   cponom = 'codprod' "
    prepare pcta01m62017 from l_sql
    declare ccta01m62017 cursor for pcta01m62017

    let l_sql = " select unfprddes     "    ,
                " from gsakprdunfseg   "    ,
                " where unfprdcod  = ? "
    prepare pcta01m62018 from l_sql
    declare ccta01m62018 cursor for pcta01m62018

    let l_sql = " insert into iddkdominio   " ,
                " (cponom, cpocod, cpodes ) " ,
                " values('codprod',?,?)"
    prepare pcta01m62019 from l_sql

    let l_sql = " select a.succod      "   ,
                ",a.itaramcod          "   ,
                ",a.itaaplnum          "   ,
                ",b.itaaplitmnum       "   ,
                ",a.aplseqnum          "   ,
                ",a.itaciacod          "   ,
                ",a.itaaplvigincdat    "   ,
                ",a.itaaplvigfnldat    "   ,
                ",b.itaaplcanmtvcod    "   ,
                " from datmitaapl a,   "   ,
                "      datmitaaplitm b "   ,
                " where a.itaciacod  = b.itaciacod ",
                " and   a.itaramcod  = b.itaramcod ",
                " and   a.itaaplnum  = b.itaaplnum ",
                " and   a.aplseqnum  = b.aplseqnum ",
                " and   a.segcgccpfnum = ? "
    prepare p_cta01m62_020  from l_sql
    declare c_cta01m62_020  cursor for p_cta01m62_020

    let l_sql = " select b.atdsrvnum, b.atdsrvano,    ",
                " b.atddat, b.atdsrvorg               ",
                " from datrservapol a, datmservico b, ",
                " datrligitaaplitm c, datmligacao d   ",
                " where b.atdsrvnum   =  a.atdsrvnum  ",
                " and   b.atdsrvano   =  a.atdsrvano  ",
                " and   b.atdsrvnum   =  d.atdsrvnum  ",
                " and   b.atdsrvano   =  d.atdsrvano  ",
                " and   d.lignum = c.lignum           ",
                " and a.succod     =  ? ",
                " and a.ramcod     =  ? ",
                " and a.aplnumdig  =  ? ",
                " and a.itmnumdig  =  ? ",
                " and a.edsnumref >=  0 ",
                " and c.itaciacod  =  ? ",
                " and d.c24astcod not in ('CON','ALT','REC','CAN','RET','IND') "
    prepare p_cta01m62_021  from l_sql
    declare c_cta01m62_021  cursor for p_cta01m62_021

    let l_sql = " select b.atdsrvnum, b.atdsrvano,    ",
                " b.atddat, b.atdsrvorg               ",
                " from datrservapol a, datmservico b, ",
                " datrligitaaplitm c, datmligacao d   ",
                " where b.atdsrvnum   =  a.atdsrvnum  ",
                " and   b.atdsrvano   =  a.atdsrvano  ",
                " and   b.atdsrvnum   =  d.atdsrvnum  ",
                " and   b.atdsrvano   =  d.atdsrvano  ",
                " and   d.lignum = c.lignum           ",
                " and a.succod     =  ? ",
                " and a.ramcod     =  ? ",
                " and a.aplnumdig  =  ? ",
                " and a.itmnumdig  =  ? ",
                " and a.edsnumref >=  0 ",
                " and c.itaciacod  =  ? ",
                " and b.atdsrvorg  =  9 ",
                " and d.c24astcod not in ('CON','ALT','REC','CAN','RET','IND') "
    prepare p_cta01m62_022  from l_sql
    declare c_cta01m62_022  cursor for p_cta01m62_022

    let l_sql = " select a.succod   "   ,
                ",a.itaramcod       "   ,
                ",a.aplnum          "   ,
                ",b.aplitmnum       "   ,
                ",max(a.aplseqnum)       "   ,
                ",a.itaciacod       "   ,
                ",a.incvigdat       "   ,
                ",a.fnlvigdat       "   ,
                ",b.itmsttcod       "   ,
                " from datmresitaapl a,   "   ,
                "      datmresitaaplitm b "   ,
                " where a.itaciacod  = b.itaciacod ",
                " and   a.itaramcod  = b.itaramcod ",
                " and   a.aplnum     = b.aplnum    ",
                " and   a.aplseqnum  = b.aplseqnum ",
                " and   a.segcpjcpfnum = ? ",
                " group by a.succod   " ,
                ",a.itaramcod         " ,
                ",a.aplnum            " ,
                ",b.aplitmnum         " ,
                ",a.itaciacod         " ,
                ",a.incvigdat         " ,
                ",a.fnlvigdat         " ,
                ",b.itmsttcod         "

    prepare p_cta01m62_023  from l_sql
    declare c_cta01m62_023  cursor for p_cta01m62_023

let m_prepare = true

end function

#------------------------------------------------------------------------------
function cta01m62_cria_temp()
#------------------------------------------------------------------------------

 call cta01m62_drop_temp()

 whenever error continue
      create temp table cta01m62_temp(produto      char(30)     ,
                                      cod_produto  smallint     ,
                                      succod       smallint     ,   #decimal(2,0) ,  #projeto succod
                                      ramcod       smallint     ,
                                      aplmundig    decimal(9,0) ,
                                      itmnumdig    decimal(7,0) ,
                                      crtsaunum    char(18)     ,
                                      bnfnum       char(20)     ,
		                                situacao     char(30)     ,
	                                   qtdsrv       decimal(5,0) ,
                                      qtdsrvre     decimal(5,0) ,
                                      viginc       date         ,
                                      vigfnl       date         ,
                                      vig          smallint     ,
                                      documento    char(110)    ,
                                      permissao    char(1)      ,
                                      prporg       decimal(2,0) ,
                                      prpnumdig    decimal(8,0) ,
                                      sitdoc       char(70)     ,
                                      pesnum       integer      ,
                                      itaciacod    smallint     ) with no log
  whenever error stop

  if sqlca.sqlcode <> 0  then

	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cta01m62_drop_temp()
	  end if

	 return false

  end if

  return true

end function

#------------------------------------------------------------------------------
function cta01m62_drop_temp()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cta01m62_temp
    whenever error stop

    return

end function

#------------------------------------------------------------------------------
function cta01m62_prep_temp()
#------------------------------------------------------------------------------

    define w_ins char(1000)

    let w_ins = 'insert into cta01m62_temp'
	     , ' values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
    prepare p_cta01m62_007 from w_ins

end function

#------------------------------------------------------------------------------
function cta01m62_ins_temp(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       produto     char(30)                      ,
       cod_produto smallint                      ,
       succod      like datrligapol.succod       ,
       ramcod      like datrligapol.ramcod       ,
       aplnumdig   like datrligapol.aplnumdig    ,
       itmnumdig   like datrligapol.itmnumdig    ,
       crtsaunum   char(18)                      ,
       bnfnum      char(20)                      ,
       situacao    char(15)                      ,
       cont1       integer                       ,
       cont2       integer                       ,
       viginc      date                          ,
       vigfnl      date                          ,
       vig         smallint                      ,
       documento   char(110)                     ,
       permissao   char(1)                       ,
       prporg      like gcamproponente.prporg    ,
       prpnumdig   like gcamproponente.prpnumdig ,
       sitdoc      char(70)                      ,
       pesnum      like gsakpes.pesnum           ,
       itaciacod   like datkitacia.itaciacod
end record

       whenever error continue
       execute p_cta01m62_007 using lr_param.produto       ,
                              lr_param.cod_produto   ,
                              lr_param.succod        ,
                              lr_param.ramcod        ,
                              lr_param.aplnumdig     ,
                              lr_param.itmnumdig     ,
                              lr_param.crtsaunum     ,
                              lr_param.bnfnum        ,
                              lr_param.situacao      ,
                              lr_param.cont1         ,
                              lr_param.cont2         ,
                              lr_param.viginc        ,
                              lr_param.vigfnl        ,
                              lr_param.vig           ,
                              lr_param.documento     ,
                              lr_param.permissao     ,
                              lr_param.prporg        ,
                              lr_param.prpnumdig     ,
                              lr_param.sitdoc        ,
                              lr_param.pesnum        ,
                              lr_param.itaciacod
       whenever error stop

end function


#------------------------------------------------------------------------------
function cta01m62_seleciona_negocio()
#------------------------------------------------------------------------------

define l_comando char(200)
define l_negocio char(20)

    if m_neg_vig = 0 then
           let l_comando = "select * from " ,
                           "cta01m62_temp " ,
                           "where vig = 0 "

           let l_negocio = "NEGOCIOS VIGENTES"
           let m_neg_vig = 1
    else
           let l_comando = "select * from " ,
                           "cta01m62_temp "

           let l_negocio = " TODOS NEGOCIOS"
           let m_neg_vig = 0
    end if

    prepare pcta01m62004 from l_comando
    declare ccta01m62004 cursor for pcta01m62004

    return l_negocio

end function

#---------------------------------------------------------------------------
function cta01m62_seleciona_proposta()
#---------------------------------------------------------------------------
define l_comando char(200)

  let l_comando = "select * from fpacc280_proposta",
                  " order by evtdat  "
  prepare pcta01m62014 from l_comando
  declare ccta01m62014 cursor for pcta01m62014

  return
end function

#---------------------------------------------------------------------------
function cta01m62_seleciona_vistoria()
#---------------------------------------------------------------------------
define l_comando char(200)
define l_prazo date

  let l_prazo = today - 365
  let l_comando = " select vstnumdig ,     ",
                  "        vstdat    ,     ",
                  "        vstcpodomdes    ",
                  " from fvpic012_vistoria ",
                  " where vstdat between '", l_prazo, "' and today" ,
                  " order by vstdat        "
  prepare pcta01m62015 from l_comando
  declare ccta01m62015 cursor for pcta01m62015

  return

end function

#---------------------------------------------------------------------------
function cta01m62_seleciona_cobertura()
#---------------------------------------------------------------------------
define l_prazo date
define l_comando char(200)

  let l_prazo = today - 365

  let l_comando = " select cbpnum  ,        ",
                  "        soldat  ,        ",
                  "        vststtdes        ",
                  " from fvpic012_cobertura ",
                  " where soldat between '", l_prazo, "' and today" ,
                  " order by soldat         "
  prepare pcta01m62016 from l_comando
  declare ccta01m62016 cursor for pcta01m62016

  return
end function

#------------------------------------------------------------------------------
function cta01m62_carrega_espelho(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cgccpfnum   char(20)                ,
       cgcord    like gsakpes.cgcord       ,
       cgccpfdig like gsakpes.cgccpfdig    ,
       pesnom    like gsakpes.pesnom       ,
       pestip    char(1)
end record


define lr_cta01m62 record
       produto     char(30)                   ,
       cod_produto smallint                   ,
       succod      like datrligapol.succod    ,
       ramcod      like datrligapol.ramcod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       itmnumdig   like datrligapol.itmnumdig ,
       crtsaunum   like datksegsau.crtsaunum  ,
       bnfnum      like datksegsau.bnfnum     ,
       situacao    char(30)                   ,
       qtdsrv      integer                    ,
       qtdsrvre    integer                    ,
       viginc      date                       ,
       vigfnl      date                       ,
       vig         smallint                   ,
       documento   char(110)                  ,
       permissao   char(1)                    ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       sitdoc      char(70)                   ,
       pesnum      like gsakpes.pesnum        ,
       itaciacod   like datkitacia.itaciacod
end record

define lr_param_aux record
     negocio    char(20)                   ,
     obs        char(70)                   ,
     atdsrvnum  like datmservico.atdsrvnum ,
     atdsrvano  like datmservico.atdsrvano ,
     atdsrvorg  like datmservico.atdsrvorg
end record

define a_cta01m62 array[500] of record
       seta        char(1)   ,
       produto     char(30)  ,
       documento   char(30)  ,
       situacao    char(30)  ,
       qtdsrv      integer   ,
       qtdsrvre    integer
end record

define a_aux array[500] of record
       cod_produto smallint                    ,
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnumdig   like datrligapol.itmnumdig  ,
       crtsaunum   like datksegsau.crtsaunum   ,
       bnfnum      like datksegsau.bnfnum      ,
       permissao   char(1)                     ,
       viginc      date                        ,
       vigfnl      date                        ,
       sitdoc      char(70)                    ,
       vig         smallint                    ,
       prporg      like datrligprp.prporg      ,
       prpnumdig   like datrligprp.prpnumdig   ,
       documento   integer                     ,
       pesnum      like gsakpes.pesnum         ,
       itaciacod   like datkitacia.itaciacod
end record

define lr_retorno record
       cod_produto smallint                    ,
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnumdig   like datrligapol.itmnumdig  ,
       crtsaunum   like datksegsau.crtsaunum   ,
       segnom      char(50)                    ,
       cgccpfnum   like gsakpes.cgccpfnum      ,
       cgcord      like gsakpes.cgcord         ,
       cgccpfdig   like gsakpes.cgccpfdig      ,
       prporg      like datrligprp.prporg      ,
       prpnumdig   like datrligprp.prpnumdig   ,
       documento   integer                     ,
       pesnum      like gsakpes.pesnum         ,
       itaciacod   like datkitacia.itaciacod
end record

define msg record
   linha1            char(40),
   linha2            char(40),
   linha3            char(40),
   linha4            char(40),
   confirma          char(1)
end record

define arr_aux          integer
define l_f1             smallint
define l_cgccpfnum_aux  char(20)
define l_cgccpfnum_ant  char(20)
define l_confirma       char(1)


initialize lr_cta01m62.*  to null
initialize lr_param_aux.* to null
initialize lr_retorno.*   to null
initialize msg.*          to null

for  arr_aux  =  1  to  500
   initialize  a_cta01m62[arr_aux].* to  null
   initialize  a_aux[arr_aux].* to  null
end  for

let arr_aux      = 0
let l_f1         = 0
let l_cgccpfnum_aux = null
let l_cgccpfnum_ant = null
let l_confirma = null

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if


 call cta01m62_seleciona_negocio()
      returning  lr_param_aux.negocio

 open ccta01m62004
 foreach ccta01m62004 into lr_cta01m62.*

  let arr_aux = arr_aux + 1

  if arr_aux > 500 then
     error "Pesquisa com mais de 500 Produtos !"
     exit foreach
  end if

  # Cartao Saude - Funcionario
  case lr_cta01m62.cod_produto
       when 1   # Auto
            let a_cta01m62[arr_aux].documento = lr_cta01m62.succod    using '<<<<&' ,".",
                                                lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.aplnumdig using '<<<&&&&&&',".",
                                                lr_cta01m62.itmnumdig using '<<<<<<&'
       when 2   # RE
            let lr_cta01m62.itmnumdig = 0
            let a_cta01m62[arr_aux].documento = lr_cta01m62.succod    using '<<<<&' ,".",
                                                lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.aplnumdig using '<<<&&&&&&',".",
                                                lr_cta01m62.itmnumdig using '<<<<<<&'
       when 12 # Transporte
            let lr_cta01m62.itmnumdig = 0
            let a_cta01m62[arr_aux].documento = lr_cta01m62.succod    using '<<<<&' ,".",
                                                lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.aplnumdig using '<<<&&&&&&',".",
                                                lr_cta01m62.itmnumdig using '<<<<<<&'
       when 13 # Fianca
            let lr_cta01m62.itmnumdig = 0
            let a_cta01m62[arr_aux].documento = lr_cta01m62.succod    using '<<<<&' ,".",
                                                lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.aplnumdig using '<<<&&&&&&',".",
                                                lr_cta01m62.itmnumdig using '<<<<<<&'
       when 98  # Saude
            let a_cta01m62[arr_aux].documento = cts20g16_formata_cartao(lr_cta01m62.crtsaunum)
       when 99  # Azul
            let a_cta01m62[arr_aux].documento = lr_cta01m62.succod    using '<<<<&' ,".",
                                                lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.aplnumdig using '<<<&&&&&&',".",
                                                lr_cta01m62.itmnumdig using '<<<<<<&'
       when 97  # Cartao
            let a_cta01m62[arr_aux].documento = cta01m60_formata_cgccpf(lr_param.cgccpfnum  ,
                                                                        lr_param.cgcord     ,
                                                                        lr_param.cgccpfdig)
       when 96  # Proposta
            let a_cta01m62[arr_aux].documento = lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.prporg    using '<&',".",
                                                lr_cta01m62.prpnumdig using '<<<&&&&&&'
       when 95  # Vistoria
            let a_cta01m62[arr_aux].documento = lr_cta01m62.documento using '<<<&&&&&&'
       when 94  # Cobertura
            let a_cta01m62[arr_aux].documento = lr_cta01m62.documento using '<<<&&&&&&'
       when 93  # Itau
            let a_cta01m62[arr_aux].documento = lr_cta01m62.itaciacod using '&&' ,".",
                                                lr_cta01m62.ramcod    using '<<&',".",
                                                lr_cta01m62.aplnumdig using '<<<&&&&&&',".",
                                                lr_cta01m62.itmnumdig using '<<<<<<&'
       otherwise # Outros
            let a_cta01m62[arr_aux].documento = lr_cta01m62.documento
    end case

  let a_aux[arr_aux].succod         = lr_cta01m62.succod
  let a_aux[arr_aux].ramcod         = lr_cta01m62.ramcod
  let a_aux[arr_aux].aplnumdig      = lr_cta01m62.aplnumdig
  let a_aux[arr_aux].itmnumdig      = lr_cta01m62.itmnumdig
  let a_aux[arr_aux].cod_produto    = lr_cta01m62.cod_produto
  let a_aux[arr_aux].crtsaunum      = lr_cta01m62.crtsaunum
  let a_aux[arr_aux].bnfnum         = lr_cta01m62.bnfnum
  let a_aux[arr_aux].permissao      = lr_cta01m62.permissao
  let a_aux[arr_aux].viginc         = lr_cta01m62.viginc
  let a_aux[arr_aux].vigfnl         = lr_cta01m62.vigfnl
  let a_aux[arr_aux].vig            = lr_cta01m62.vig
  let a_aux[arr_aux].prporg         = lr_cta01m62.prporg
  let a_aux[arr_aux].prpnumdig      = lr_cta01m62.prpnumdig
  let a_aux[arr_aux].pesnum         = lr_cta01m62.pesnum
  let a_aux[arr_aux].itaciacod      = lr_cta01m62.itaciacod

  let a_cta01m62[arr_aux].produto   = lr_cta01m62.produto
  let a_cta01m62[arr_aux].qtdsrv    = lr_cta01m62.qtdsrv    clipped
  let a_cta01m62[arr_aux].qtdsrvre  = lr_cta01m62.qtdsrvre  clipped

  if  a_aux[arr_aux].cod_produto <> 96 and
      a_aux[arr_aux].cod_produto <> 95 and
      a_aux[arr_aux].cod_produto <> 94 then

      if a_aux[arr_aux].cod_produto = 1 then
           let  a_aux[arr_aux].sitdoc = lr_cta01m62.sitdoc
      end if

      if a_aux[arr_aux].cod_produto = 25 then
            let  a_aux[arr_aux].sitdoc   = lr_cta01m62.sitdoc
            let a_aux[arr_aux].documento = lr_cta01m62.documento
      end if

      let a_cta01m62[arr_aux].situacao  = lr_cta01m62.situacao  clipped
  else
      let a_aux[arr_aux].sitdoc    = lr_cta01m62.sitdoc
      let a_aux[arr_aux].documento = lr_cta01m62.documento
  end if

 end foreach

 if arr_aux = 0 then

    let l_confirma = cts08g01("C","S","CNPJ/CPF SEM DOCTO",
                               " VIGENTE LOCALIZADO",
                               " LOCALIZA TODOS",
                               " OS NEGOCIOS?")
    if l_confirma = "S" then
       let m_vig  = false
       let m_sair = false

       call cta01m62_carrega_espelho(lr_param.*)
       returning lr_retorno.*

       if m_sair = true then
         return lr_retorno.*
       end if

    else
       let m_sair = true
       return lr_retorno.*
    end if

 end if

 open window cta01m62 at 03,02 with form "cta01m62"
                       attribute(form line 1)

 let l_cgccpfnum_ant = lr_param.cgccpfnum
 let lr_param.cgccpfnum = cta01m60_formata_cgccpf(lr_param.cgccpfnum  ,
                                                  lr_param.cgcord     ,
                                                  lr_param.cgccpfdig)

 call set_count(arr_aux)
  if m_neg_vig <> 0 then
      let lr_param_aux.obs = "   (F1)TodosNeg (F3)QtdSrv (F5)Dados.Veic (F8)Seleciona (F17)Abandona"
  else
      let lr_param_aux.obs = "(F1)NegVigentes (F3)QtdSrv (F5)Dados.Veic (F8)Seleciona (F17)Abandona"
  end if

 display by name lr_param.cgccpfnum
 display by name lr_param.pesnom
 display by name lr_param_aux.negocio attribute (reverse)
 display by name lr_param_aux.obs

 let lr_param.cgccpfnum= l_cgccpfnum_ant

 options insert   key F40
 options delete   key F35
 options next     key F30
 options previous key F25

 input array a_cta01m62 without defaults from s_cta01m62.*

 before field seta
  let arr_aux  = arr_curr()

  display by name a_aux[arr_aux].viginc
  display by name a_aux[arr_aux].vigfnl

  if a_aux[arr_aux].cod_produto = 96 or
     a_aux[arr_aux].cod_produto = 95 or
     a_aux[arr_aux].cod_produto = 94 then
    display by name a_aux[arr_aux].sitdoc attribute (reverse)
  else
    display by name a_aux[arr_aux].sitdoc
  end if

 after field seta
  if  fgl_lastkey() <> fgl_keyval("up")   and
      fgl_lastkey() <> fgl_keyval("left") then
           if a_cta01m62[arr_aux + 1 ].produto is null then
                 next field seta
           end if
  end if

 on key (interrupt)
     let m_sair = true
     exit input

 on key(f1)
  if m_vig = true then
     let l_f1 = 1
     exit input
  end if

 on key(f3)
  if a_aux[arr_aux].permissao = "S" then
      let arr_aux  = arr_curr()

      call cts22g00(a_aux[arr_aux].succod    ,
                    a_aux[arr_aux].ramcod    ,
                    a_aux[arr_aux].aplnumdig ,
                    a_aux[arr_aux].itmnumdig ,
                    "","",360,
                    a_aux[arr_aux].bnfnum    ,
                    lr_param.cgccpfnum       ,
                    lr_param.cgcord          ,
                    lr_param.cgccpfdig       ,
                    "cta01m62")
      returning lr_param_aux.atdsrvnum,
                lr_param_aux.atdsrvano,
                lr_param_aux.atdsrvorg
  else
      error "Produto sem acesso para o atendimento"
  end if

 on key(f5)
   if a_aux[arr_aux].cod_produto = 1 then
       let arr_aux  = arr_curr()
       call cta01m63(a_aux[arr_aux].succod    ,
                     a_aux[arr_aux].aplnumdig ,
                     a_aux[arr_aux].itmnumdig )
   else
      error "Funcao nao disponivel para esse produto"
   end if

 on key(f8)

 let arr_aux  = arr_curr()
  if a_aux[arr_aux].permissao = "S" then

       let msg.confirma = 'S'

       if a_aux[arr_aux].vig = 1 then
          let msg.linha1 = "Esta apolice esta vencida ou cancelada"
          let msg.linha2 = "Procure uma apolice vigente e ativa"
          let msg.linha3 = "Ou consulte a supervisao."
          let msg.linha4 = "Deseja prosseguir?"
          call cts08g01("C","S",msg.linha1,msg.linha2,msg.linha3,msg.linha4)
               returning msg.confirma
       end if

       if msg.confirma = 'S' then
           let lr_retorno.cod_produto = a_aux[arr_aux].cod_produto
           let lr_retorno.succod      = a_aux[arr_aux].succod
           let lr_retorno.ramcod      = a_aux[arr_aux].ramcod
           let lr_retorno.aplnumdig   = a_aux[arr_aux].aplnumdig
           let lr_retorno.itmnumdig   = a_aux[arr_aux].itmnumdig
           let lr_retorno.crtsaunum   = a_aux[arr_aux].crtsaunum
           let lr_retorno.prporg      = a_aux[arr_aux].prporg
           let lr_retorno.prpnumdig   = a_aux[arr_aux].prpnumdig
           let lr_retorno.documento   = a_aux[arr_aux].documento
           let lr_retorno.segnom      = lr_param.pesnom
           let lr_retorno.cgccpfnum   = lr_param.cgccpfnum
           let lr_retorno.cgcord      = lr_param.cgcord
           let lr_retorno.cgccpfdig   = lr_param.cgccpfdig
           let lr_retorno.pesnum      = a_aux[arr_aux].pesnum
           let lr_retorno.itaciacod   = a_aux[arr_aux].itaciacod
           let m_sair = true
           exit input
       end if
 else
     error "Produto sem acesso para o atendimento"
 end if

end input

 close window cta01m62
 message " "
 if l_f1 = 1 then

    if m_vig = true then
        let m_sair = false
        call cta01m62_carrega_espelho(lr_param.*)
        returning lr_retorno.*
    end if

 end if

 return lr_retorno.*

end function

#------------------------------------------------------------------------------
function cta01m62(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum    ,
       cgcord    like gsakpes.cgcord       ,
       cgccpfdig like gsakpes.cgccpfdig    ,
       pesnom    like gsakpes.pesnom       ,
       pestip    char(1)
end record

define lr_retorno record
       cod_produto smallint                    ,
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnundig   like datrligapol.itmnumdig  ,
       crtsaunum   like datksegsau.crtsaunum   ,
       segnom      char(50)                    ,
       cgccpfnum   like gsakpes.cgccpfnum      ,
       cgcord      like gsakpes.cgcord         ,
       cgccpfdig   like gsakpes.cgccpfdig      ,
       prporg      like datrligprp.prporg      ,
       prpnumdig   like datrligprp.prpnumdig   ,
       documento   integer                     ,
       pesnum      like gsakpes.pesnum         ,
       itaciacod   like datkitacia.itaciacod
end record

define ws record
       erro smallint ,
       sair smallint
end record

define arr_aux integer
define l_resultado smallint

initialize lr_retorno.* to null
initialize ws.*        to null

let ws.erro      = 0
let m_neg_vig    = 0
let arr_aux      = 0
let m_vig        = true
let m_sair       = false
let l_resultado  = null

  if not cta01m62_cria_temp() then
      let ws.erro = 1
      error  "Erro na Criacao da Tabela Temporaria!"
  end if

  if m_prepare is null or
     m_prepare <> true then
     call cta01m62_prepare()
  end if
  call cta01m62_prep_temp()

  if ws.erro = 0  then
      message " Aguarde, pesquisando..." attribute (reverse)

      # Recupero os Dados do Auto/Re/Diversos
      call cta01m62_rec_doc_geral(lr_param.cgccpfnum ,
                                  lr_param.cgcord    ,
                                  lr_param.cgccpfdig ,
                                  lr_param.pestip    )

      # Recupero os Dados da Azul Seguros
      call cta01m62_rec_azul(lr_param.cgccpfnum)

      # Recupero os Dados da Itau Seguros
      call cta01m62_rec_itau(lr_param.cgccpfnum)

      # Recupero os Dados da Itau Seguros RE
      call cta01m62_rec_itau_re(lr_param.cgccpfnum)

      # Recupero os Dados do Saude
      call cta01m62_rec_saude(lr_param.cgccpfnum)

      # Recupero os Dados do Cartao Visa
      call cta01m62_rec_cartao(lr_param.cgccpfnum ,
                               lr_param.cgcord    ,
                               lr_param.cgccpfdig ,
                               lr_param.pestip    )

      # Recupero os Dados da Proposta
       call cta01m62_rec_proposta(lr_param.cgccpfnum)

      # Recupero os Dados da Vistoria
       call cta01m62_rec_vistoria(lr_param.cgccpfnum)

      # Recupero os Dados da Cobertura
       call cta01m62_rec_cobertura(lr_param.cgccpfnum)
      end if

      # Verifico se cliente tem produtos
      let l_resultado = cta01m62_conta_negocio()

      if l_resultado = 0 then

           # Carrego o Espelho do Segurado
           call cta01m62_carrega_espelho(lr_param.*)
           returning lr_retorno.*
      else
         error "Cliente nao possui nenhum produto cadastrado"
      end if

  return lr_retorno.*

end function

#------------------------------------------------------------------------------
function cta01m62_rec_doc_geral(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    char(1)
end record


define lr_cta01m62 record
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnumdig   like datrligapol.itmnumdig  ,
       edsnumdig   like datrligapol.edsnumref
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       doc_handle integer  ,
       viginc     date     ,
       vigfnl     date
end record


define lr_temp record
       cont1       integer   ,
       cont2       integer   ,
       produto     char(30)  ,
       cod_produto smallint  ,
       crtsaunum   char(18)  ,
       bnfnum      char(20)  ,
       situacao    char(15)  ,
       viginc      date      ,
       vigfnl      date      ,
       vig         smallint  ,
       documento   char(110) ,
       permissao   char(1)   ,
       sitdoc      char(70)  ,
       pesnum      integer
end record

define l_qtd integer
define l_array integer


initialize lr_retorno.* to null
initialize lr_temp.*    to null

let l_qtd = null
let l_array = null

let lr_temp.cont1 = 0
let lr_temp.cont2 = 0

       if m_prepare is null or
          m_prepare <> true then
          call cta01m62_prepare()
       end if

       call osgtf550_pesquisa_negocios_cpfcnpj(lr_param.cgccpfnum,
                                               lr_param.cgcord   ,
                                               lr_param.cgccpfdig,
                                               lr_param.pestip   )
       returning lr_retorno.resultado, l_qtd

       if l_qtd is not null and
          l_qtd > 0         then

           for l_array = 1 to l_qtd
              # Formata Documento
              call cta01m62_formata_doc(g_a_gsakdocngcseg[l_array].doc1  ,
                                        g_a_gsakdocngcseg[l_array].doc2  ,
                                        g_a_gsakdocngcseg[l_array].doc3  ,
                                        g_a_gsakdocngcseg[l_array].doc4  ,
                                        g_a_gsakdocngcseg[l_array].doc5  ,
                                        g_a_gsakdocngcseg[l_array].doc6  ,
                                        g_a_gsakdocngcseg[l_array].doc7  ,
                                        g_a_gsakdocngcseg[l_array].doc8  ,
                                        g_a_gsakdocngcseg[l_array].doc9  ,
                                        g_a_gsakdocngcseg[l_array].doc10 )
             returning lr_temp.documento

              # Recupera a situacao do documento
              open ccta01m62009 using g_a_gsakdocngcseg[l_array].docsitcod
              whenever error continue
              fetch ccta01m62009  into lr_temp.situacao
              close ccta01m62009

              whenever error stop
              case g_a_gsakdocngcseg[l_array].docsitcod
                 when 1
                   let lr_temp.situacao = lr_temp.situacao[1,5]
                 when 2
                   let lr_temp.situacao = lr_temp.situacao[1,9]
              end case

              if g_a_gsakdocngcseg[l_array].docsitcod = 0 then
                 let lr_temp.situacao = "VENCIDO"
              end if

              if sqlca.sqlcode <> 0  then
                 error "Erro ao recuperar a situacao do documento"
              end if

              # Verifica se o documento e vigente
              if g_a_gsakdocngcseg[l_array].viginc  <= today and
                 g_a_gsakdocngcseg[l_array].vigfnl  >= today then

                   if g_a_gsakdocngcseg[l_array].docsitcod = 1 then
                       let lr_temp.vig = 0
                   else
                       let lr_temp.vig = 1
                   end if

              else
                   let lr_temp.vig = 1
                   if g_a_gsakdocngcseg[l_array].docsitcod = 1 then
                        let lr_temp.situacao = "VENCIDO"
                   end if
              end if

              # Se for Auto, RE, Transporte ou Fianca recupero a quantidade de serviços
              if g_a_gsakdocngcseg[l_array].unfprdcod = 1  or
                 g_a_gsakdocngcseg[l_array].unfprdcod = 2  or
                 g_a_gsakdocngcseg[l_array].unfprdcod = 12 or
                 g_a_gsakdocngcseg[l_array].unfprdcod = 13 then

                 let lr_cta01m62.succod    = g_a_gsakdocngcseg[l_array].doc1
                 let lr_cta01m62.ramcod    = g_a_gsakdocngcseg[l_array].doc2
                 let lr_cta01m62.aplnumdig = g_a_gsakdocngcseg[l_array].doc3
                 let lr_cta01m62.itmnumdig = g_a_gsakdocngcseg[l_array].doc4

                 # Recupera a quantidade de servicos
                 call cta01m62_conta_servico(lr_cta01m62.succod    ,
                                             lr_cta01m62.ramcod    ,
                                             lr_cta01m62.aplnumdig ,
                                             lr_cta01m62.itmnumdig ,
                                             "","","","","")
                 returning lr_temp.cont1, lr_temp.cont2
              else
                  let lr_temp.cont1 =  0
                  let lr_temp.cont2 =  0
              end if

              # Recupero a descricao e a permissao do produto
              call cta01m62_rec_descricao_prod(g_a_gsakdocngcseg[l_array].unfprdcod)
              returning lr_temp.produto, lr_temp.permissao

              # Recupera o Numero do Cliente (pesnum)
              let lr_temp.pesnum = g_a_gsakdocngcseg[l_array].pesnum
              let lr_temp.cod_produto = g_a_gsakdocngcseg[l_array].unfprdcod
              let lr_temp.viginc      = g_a_gsakdocngcseg[l_array].viginc
              let lr_temp.vigfnl      = g_a_gsakdocngcseg[l_array].vigfnl

              # Recupero Dados do Endereco PSS
              if g_a_gsakdocngcseg[l_array].unfprdcod = 25 then
                let lr_temp.sitdoc = cta01m62_endereco_pss(lr_temp.pesnum)
              else

                 # Recupero os dados do veiculo
                 let  lr_temp.sitdoc = cta01m62_concatena_veic(lr_cta01m62.succod    ,
                                                               lr_cta01m62.aplnumdig ,
                                                               lr_cta01m62.itmnumdig)
              end if

              # Insiro os dados na tabela temporaria
              call cta01m62_ins_temp(lr_temp.produto       ,
                                     lr_temp.cod_produto   ,
                                     lr_cta01m62.succod    ,
                                     lr_cta01m62.ramcod    ,
                                     lr_cta01m62.aplnumdig ,
                                     lr_cta01m62.itmnumdig ,
                                     lr_temp.crtsaunum     ,
                                     lr_temp.bnfnum        ,
                                     lr_temp.situacao      ,
                                     lr_temp.cont1         ,
                                     lr_temp.cont2         ,
                                     lr_temp.viginc        ,
                                     lr_temp.vigfnl        ,
                                     lr_temp.vig           ,
                                     lr_temp.documento     ,
                                     lr_temp.permissao     ,
                                     ""                    ,
                                     ""                    ,
                                     lr_temp.sitdoc        ,
                                     lr_temp.pesnum        ,
                                     ""                    )
          end for
       end if
    return

end function


#------------------------------------------------------------------------------
function cta01m62_rec_azul(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum


define lr_cta01m62 record
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnumdig   like datrligapol.itmnumdig  ,
       edsnumdig   like datrligapol.edsnumref
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       doc_handle integer  ,
       viginc     date     ,
       vigfnl     date
end record


define lr_temp record
       cont1       integer   ,
       cont2       integer   ,
       produto     char(30)  ,
       cod_produto smallint  ,
       crtsaunum   char(18)  ,
       bnfnum      char(20)  ,
       situacao    char(15)  ,
       viginc      date      ,
       vigfnl      date      ,
       vig         smallint  ,
       documento   char(110) ,
       permissao   char(1)
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if


let lr_temp.cod_produto = 99

    open c_cta01m62_001 using lr_param_cgccpfnum
    foreach c_cta01m62_001 into   lr_cta01m62.*

      call cts42g00_doc_handle(lr_cta01m62.*)
      returning lr_retorno.resultado,
                lr_retorno.mensagem,
                lr_retorno.doc_handle

      call cts38m00_extrai_vigencia(lr_retorno.doc_handle)
           returning lr_retorno.viginc,
                     lr_retorno.vigfnl

      call cts38m00_extrai_situacao(lr_retorno.doc_handle)
           returning lr_temp.situacao

      if lr_retorno.viginc <= today and
         lr_retorno.vigfnl >= today then

           if lr_temp.situacao = "ATIVO" or
              lr_temp.situacao = "ATIVA" then
               let lr_temp.vig = 0
           else
               let lr_temp.vig = 1
           end if
      else
           let lr_temp.vig = 1
           let lr_temp.situacao = "VENCIDO"
      end if

      # Recupera a quantidade de servicos
      call cta01m62_conta_servico(lr_cta01m62.succod    ,
                                  lr_cta01m62.ramcod    ,
                                  lr_cta01m62.aplnumdig ,
                                  lr_cta01m62.itmnumdig ,
                                  "","","","","")
      returning lr_temp.cont1, lr_temp.cont2

      # Recupero a descricao e a permissao do produto
      call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
      returning lr_temp.produto, lr_temp.permissao

      let lr_temp.viginc = lr_retorno.viginc
      let lr_temp.vigfnl = lr_retorno.vigfnl

      # Insiro na tabela temporaria
      call cta01m62_ins_temp(lr_temp.produto       ,
                             lr_temp.cod_produto   ,
                             lr_cta01m62.succod    ,
                             lr_cta01m62.ramcod    ,
                             lr_cta01m62.aplnumdig ,
                             lr_cta01m62.itmnumdig ,
                             lr_temp.crtsaunum     ,
                             lr_temp.bnfnum        ,
                             lr_temp.situacao      ,
                             lr_temp.cont1         ,
                             lr_temp.cont2         ,
                             lr_temp.viginc        ,
                             lr_temp.vigfnl        ,
                             lr_temp.vig           ,
                             lr_temp.documento     ,
                             lr_temp.permissao     ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             ""                    )
    end foreach

    return

end function

#------------------------------------------------------------------------------
function cta01m62_rec_itau(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cta01m62 record
       succod          like datrligapol.succod            ,
       ramcod          like datrligapol.ramcod            ,
       aplnumdig       like datrligapol.aplnumdig         ,
       itmnumdig       like datrligapol.itmnumdig         ,
       edsnumdig       like datrligapol.edsnumref         ,
       itaciacod       like datkitacia.itaciacod          ,
       itaaplvigincdat like datmitaapl.itaaplvigincdat    ,
       itaaplvigfnldat like datmitaapl.itaaplvigfnldat    ,
       itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30)
end record


define lr_temp record
       cont1       integer   ,
       cont2       integer   ,
       produto     char(30)  ,
       cod_produto smallint  ,
       crtsaunum   char(18)  ,
       bnfnum      char(20)  ,
       situacao    char(15)  ,
       viginc      date      ,
       vigfnl      date      ,
       vig         smallint  ,
       documento   char(110) ,
       permissao   char(1)   ,
       itaciacod   smallint
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if

let lr_temp.cod_produto = 93

    open c_cta01m62_020 using lr_param_cgccpfnum
    foreach c_cta01m62_020 into   lr_cta01m62.*


     if lr_cta01m62.itaaplvigincdat <= today and
        lr_cta01m62.itaaplvigfnldat  >= today then

           if lr_cta01m62.itaaplcanmtvcod is null then
               let lr_temp.situacao = "ATIVA"
               let lr_temp.vig = 0
           else
               let lr_temp.situacao = "CANCELADA"
               let lr_temp.vig = 1
           end if
     else
           let lr_temp.situacao = "VENCIDA"
           let lr_temp.vig = 1
     end if

     # Recupera a quantidade de servicos
     call cta01m62_conta_servico(lr_cta01m62.succod    ,
                                 lr_cta01m62.ramcod    ,
                                 lr_cta01m62.aplnumdig ,
                                 lr_cta01m62.itmnumdig ,
                                 "","","","",
                                 lr_cta01m62.itaciacod)
     returning lr_temp.cont1, lr_temp.cont2

      # Recupero a descricao e a permissao do produto
      call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
      returning lr_temp.produto, lr_temp.permissao

      let lr_temp.viginc    = lr_cta01m62.itaaplvigincdat
      let lr_temp.vigfnl    = lr_cta01m62.itaaplvigfnldat
      let lr_temp.itaciacod = lr_cta01m62.itaciacod

      # Insiro na tabela temporaria
      call cta01m62_ins_temp(lr_temp.produto       ,
                             lr_temp.cod_produto   ,
                             lr_cta01m62.succod    ,
                             lr_cta01m62.ramcod    ,
                             lr_cta01m62.aplnumdig ,
                             lr_cta01m62.itmnumdig ,
                             lr_temp.crtsaunum     ,
                             lr_temp.bnfnum        ,
                             lr_temp.situacao      ,
                             lr_temp.cont1         ,
                             lr_temp.cont2         ,
                             lr_temp.viginc        ,
                             lr_temp.vigfnl        ,
                             lr_temp.vig           ,
                             lr_temp.documento     ,
                             lr_temp.permissao     ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             lr_temp.itaciacod     )
    end foreach

    return

end function

#------------------------------------------------------------------------------
function cta01m62_rec_saude(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cta01m62 record
       succod      like datksegsau.succod     ,
       ramcod      like datksegsau.ramcod     ,
       aplnumdig   like datksegsau.aplnumdig  ,
       crtsaunum   like datksegsau.crtsaunum  ,
       crtstt      like datksegsau.crtstt     ,
       bnfnum      like datksegsau.bnfnum
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       doc_handle integer  ,
       viginc     date     ,
       vigfnl     date
end record


define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       itmnumdig   decimal(7,0) ,
       situacao    char(15)     ,
       vig         smallint     ,
       documento   char(110)    ,
       permissao   char(1)
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null

let lr_temp.cod_produto = 98

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if

    open c_cta01m62_004 using lr_param_cgccpfnum
    foreach c_cta01m62_004 into   lr_cta01m62.*

       if lr_cta01m62.crtstt = 'A' then
           let lr_temp.situacao = "ATIVO"
           let lr_temp.vig = 0
       else
           let lr_temp.situacao = "CANCELADO"
           let lr_temp.vig = 1
       end if

       # Recupera a quantidade de servicos
       call cta01m62_conta_servico("","","","",
                                   lr_cta01m62.crtsaunum,
                                   "","","","")
       returning lr_temp.cont1, lr_temp.cont2

       # Recupero a descricao e a permissao do produto
       call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
       returning lr_temp.produto, lr_temp.permissao

       # Insiro na tabela temporaria
       call cta01m62_ins_temp(lr_temp.produto       ,
                              lr_temp.cod_produto   ,
                              lr_cta01m62.succod    ,
                              lr_cta01m62.ramcod    ,
                              lr_cta01m62.aplnumdig ,
                              lr_temp.itmnumdig     ,
                              lr_cta01m62.crtsaunum ,
                              lr_cta01m62.bnfnum    ,
                              lr_temp.situacao      ,
                              lr_temp.cont1         ,
                              lr_temp.cont2         ,
                              ""                    ,
                              ""                    ,
                              lr_temp.vig           ,
                              lr_temp.documento     ,
                              lr_temp.permissao     ,
                              ""                    ,
                              ""                    ,
                              ""                    ,
                              ""                    ,
                              ""                    )
    end foreach

    return

end function

#---------------------------------------------------------------------
function cta01m62_conta_servico(lr_param)
#---------------------------------------------------------------------

define lr_param record
    succod    like datrligapol.succod    ,
    ramcod    like datrligapol.ramcod    ,
    aplnumdig like datrligapol.aplnumdig ,
    itmnumdig like datrligapol.itmnumdig ,
    crtsaunum like datksegsau.crtsaunum  ,
    cgccpfnum like gsakpes.cgccpfnum     ,
    cgcord    like gsakpes.cgcord        ,
    cgccpfdig like gsakpes.cgccpfdig     ,
    itaciacod like datkitacia.itaciacod
end record

define lr_retorno record
       cont1 integer ,
       cont2 integer
end record

define ws record
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano,
     atddat    date                      ,
     atdsrvorg like datmservico.atdsrvorg,
     inidat    date                      ,
     fimdat    date
end record

define l_result smallint

initialize ws.* to null
let l_result = null

let lr_retorno.cont1 = 0
let lr_retorno.cont2 = 0

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if

    # Porto, Azul ou Itau

    if lr_param.aplnumdig is not null then

         # Itau

         if lr_param.itaciacod is not null then

            open c_cta01m62_021 using lr_param.succod   ,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig,
                                      lr_param.itaciacod
            foreach c_cta01m62_021 into ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atddat   ,
                                        ws.atdsrvorg

               # Recupero a Vigencia da Apolice
               call cta01m62_rec_vigencia(lr_param.crtsaunum)
               returning ws.inidat, ws.fimdat

               # Verifico se a Origem e a Data estão dentro da Regra
               let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg ,
                                                           ws.inidat    ,
                                                           ws.fimdat    ,
                                                           ws.atddat    )
               if l_result = 0 or
                  l_result is null then
                  continue foreach
               end if

               # Recupero a Etapa p/ desconsideracao de servicos
               let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                                 ws.atdsrvano)
               if l_result = 0 or
                  l_result is null then
                  continue foreach
               end if

               let lr_retorno.cont1 = lr_retorno.cont1 + 1

            end foreach

            open c_cta01m62_022 using lr_param.succod     ,
                                      lr_param.ramcod     ,
                                      lr_param.aplnumdig  ,
                                      lr_param.itmnumdig  ,
                                      lr_param.itaciacod
            foreach c_cta01m62_022 into ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atddat   ,
                                        ws.atdsrvorg

             # Recupero a Vigencia da Apolice
             call cta01m62_rec_vigencia(lr_param.crtsaunum)
             returning ws.inidat, ws.fimdat

             # Verifico se a Origem e a Data estão dentro da Regra
             let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg ,
                                                         ws.inidat    ,
                                                         ws.fimdat    ,
                                                         ws.atddat    )
             if l_result = 0 or
                l_result is null then
                continue foreach
             end if

             # Recupero a Etapa p/ desconsideracao de servicos
             let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                               ws.atdsrvano)
             if l_result = 0 or
                l_result is null then
                continue foreach
             end if

             let lr_retorno.cont2 = lr_retorno.cont2 + 1
            end foreach

         else

            # Porto e Azul

            open c_cta01m62_002 using lr_param.succod   ,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig
            foreach c_cta01m62_002 into ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atddat   ,
                                        ws.atdsrvorg

               # Recupero a Vigencia da Apolice
               call cta01m62_rec_vigencia(lr_param.crtsaunum)
               returning ws.inidat, ws.fimdat

               # Verifico se a Origem e a Data estão dentro da Regra
               let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg ,
                                                           ws.inidat    ,
                                                           ws.fimdat    ,
                                                           ws.atddat    )
               if l_result = 0 or
                  l_result is null then
                  continue foreach
               end if

               # Recupero a Etapa p/ desconsideracao de servicos
               let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                                 ws.atdsrvano)
               if l_result = 0 or
                  l_result is null then
                  continue foreach
               end if

               let lr_retorno.cont1 = lr_retorno.cont1 + 1

            end foreach

            open c_cta01m62_003 using lr_param.succod   ,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig
            foreach c_cta01m62_003 into ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atddat   ,
                                        ws.atdsrvorg

             # Recupero a Vigencia da Apolice
             call cta01m62_rec_vigencia(lr_param.crtsaunum)
             returning ws.inidat, ws.fimdat

             # Verifico se a Origem e a Data estão dentro da Regra
             let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg ,
                                                         ws.inidat    ,
                                                         ws.fimdat    ,
                                                         ws.atddat    )
             if l_result = 0 or
                l_result is null then
                continue foreach
             end if

             # Recupero a Etapa p/ desconsideracao de servicos
             let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                               ws.atdsrvano)
             if l_result = 0 or
                l_result is null then
                continue foreach
             end if

             let lr_retorno.cont2 = lr_retorno.cont2 + 1
            end foreach
         end if
     else

          # Saude
          if lr_param.crtsaunum is not null then
                 open c_cta01m62_005 using lr_param.crtsaunum
                 foreach c_cta01m62_005 into ws.atdsrvnum,
                                           ws.atdsrvano,
                                           ws.atddat   ,
                                           ws.atdsrvorg

                    # Recupero a Vigencia da Apolice
                    call cta01m62_rec_vigencia(lr_param.crtsaunum)
                    returning ws.inidat, ws.fimdat

                    # Verifico se a Origem e a Data estão dentro da Regra
                    let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg ,
                                                                ws.inidat    ,
                                                                ws.fimdat    ,
                                                                ws.atddat    )
                    if l_result = 0 or
                       l_result is null then
                       continue foreach
                    end if

                    # Recupero a Etapa p/ desconsideracao de servicos
                    let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                                      ws.atdsrvano)
                    if l_result = 0 or
                       l_result is null then
                       continue foreach
                    end if
                    let lr_retorno.cont1 = lr_retorno.cont1 + 1
                 end foreach

                 open c_cta01m62_006 using lr_param.crtsaunum
                 foreach c_cta01m62_006 into ws.atdsrvnum,
                                           ws.atdsrvano,
                                           ws.atddat   ,
                                           ws.atdsrvorg

                    # Recupero a Vigencia da Apolice
                    call cta01m62_rec_vigencia(lr_param.crtsaunum)
                    returning ws.inidat, ws.fimdat

                    # Verifico se a Origem e a Data estão dentro da Regra
                    let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg ,
                                                                ws.inidat    ,
                                                                ws.fimdat    ,
                                                                ws.atddat    )
                    if l_result = 0 or
                       l_result is null then
                       continue foreach
                    end if

                    # Recupero a Etapa p/ desconsideracao de servicos
                    let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                                      ws.atdsrvano)

                    if l_result = 0 or
                       l_result is null then
                       continue foreach
                    end if
                    let lr_retorno.cont2 = lr_retorno.cont2 + 1
                 end foreach
          else

               # Cartao
               open ccta01m62011 using lr_param.cgccpfnum ,
                                       lr_param.cgcord    ,
                                       lr_param.cgccpfdig
               foreach ccta01m62011 into ws.atdsrvnum,
                                         ws.atdsrvano,
                                         ws.atddat   ,
                                         ws.atdsrvorg

                       # Recupero a Vigencia da Apolice
                       call cta01m62_rec_vigencia(lr_param.crtsaunum)
                       returning ws.inidat, ws.fimdat

                       # Verifico se a Origem e a Data estão dentro da Regra
                       let l_result= cta01m62_desconsidera_servico(ws.atdsrvorg,
                                                                   ws.inidat,
                                                                   ws.fimdat,
                                                                   ws.atddat)
                       if l_result = 0 or
                          l_result is null then
                          continue foreach
                       end if

                       # Recupero a Etapa p/ desconsideracao de servicos
                       let l_result = cta01m62_rec_etapa(ws.atdsrvnum,
                                                         ws.atdsrvano)
                       if l_result = 0 or
                          l_result is null then
                          continue foreach
                       end if

                       let lr_retorno.cont1 = lr_retorno.cont1 + 1

               end foreach

               if lr_retorno.cont1 is not null then
                    let lr_retorno.cont2 = lr_retorno.cont1
               end if

          end if
      end if

      if lr_retorno.cont1 is null then
         let lr_retorno.cont1 = 0
      end if

      if lr_retorno.cont2 is null then
         let lr_retorno.cont2 = 0
      end if

    return lr_retorno.*

end function

#---------------------------------------------------------------------
function cta01m62_rec_descricao_prod(lr_param)
#---------------------------------------------------------------------

define lr_param record
       unfprdcod like gsakdocngcseg.unfprdcod
end record

define lr_retorno record
       docsitdes char(50) ,
       permissao char(1)  ,
       cont      integer
end record

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if

initialize lr_retorno.* to null

   # Verifica se o codigo ja existe na base da Central
   open ccta01m62017 using lr_param.unfprdcod
   fetch ccta01m62017  into lr_retorno.cont
   close ccta01m62017

   if lr_retorno.cont = 0 then
      # Crio o novo codigo na Base da Central
      call cta01m62_cria_produto(lr_param.unfprdcod)
   end if

   # Recupera a descricao do produto
   open ccta01m62008 using lr_param.unfprdcod
   whenever error continue
   fetch ccta01m62008  into lr_retorno.docsitdes
   whenever error stop
   if sqlca.sqlcode <> 0  then
      error "Erro ao recuperar a descricao do produto ", sqlca.sqlcode
   end if
   close ccta01m62008

   # Recupera a permissao do documento
   open ccta01m62010 using lr_param.unfprdcod
   whenever error continue
   fetch ccta01m62010  into lr_retorno.permissao
   whenever error stop
   if sqlca.sqlcode <> 0  then
      error "Erro ao recuperar a permissao do produto ", sqlca.sqlcode
   end if
   close ccta01m62010

   return lr_retorno.docsitdes,
          lr_retorno.permissao

end function

#---------------------------------------------------------------------
function cta01m62_formata_doc(lr_param)
#---------------------------------------------------------------------

define lr_param record
   doc1    char(10)
  ,doc2    char(10)
  ,doc3    char(10)
  ,doc4    char(10)
  ,doc5    char(10)
  ,doc6    char(10)
  ,doc7    char(10)
  ,doc8    char(10)
  ,doc9    char(10)
  ,doc10   char(10)
end record

define lr_retorno record
       documento char(110)
end record

initialize lr_retorno.* to null

  if lr_param.doc1 is not null then
      let lr_retorno.documento = lr_param.doc1 clipped
  end if

  if lr_param.doc2 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped, "." , lr_param.doc2 clipped
  end if

  if lr_param.doc3 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped, "." , lr_param.doc3 clipped
  end if

  if lr_param.doc4 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc4 clipped
  end if

  if lr_param.doc5 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc5 clipped
  end if

  if lr_param.doc6 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc6 clipped
  end if

  if lr_param.doc7 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc7 clipped
  end if

  if lr_param.doc8 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc8 clipped
  end if

  if lr_param.doc9 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc9 clipped
  end if

  if lr_param.doc10 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc10 clipped
  end if

return lr_retorno.documento

end function

#------------------------------------------------------------------------------
function cta01m62_rec_cartao(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    char(1)
end record

define lr_cta01m62 record
       cgccpfnumdig char(18)
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       qtd        integer
end record


define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       itmnumdig   decimal(7,0) ,
       situacao    char(15)     ,
       vig         smallint     ,
       documento   char(110)    ,
       permissao   char(1)
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null

let lr_temp.cod_produto = 97

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if

     let lr_cta01m62.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_param.cgccpfnum,
                                                            lr_param.cgcord   ,
                                                            lr_param.cgccpfdig)
     call ffpfc073_qtd_prop(lr_cta01m62.cgccpfnumdig ,
                            lr_param.pestip           )
     returning lr_retorno.mensagem ,
               lr_retorno.resultado,
               lr_retorno.qtd

     if lr_retorno.qtd > 0 then
           let lr_temp.situacao = "ATIVO"
           let lr_temp.vig = 0

            # Recupera a Quantidade de Servicos
            call cta01m62_conta_servico("","","","","",
                                        lr_param.cgccpfnum ,
                                        lr_param.cgcord    ,
                                        lr_param.cgccpfdig ,
                                        "" )
            returning lr_temp.cont1, lr_temp.cont2

            # Recupero a descricao e a permissao do produto
            call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
            returning lr_temp.produto, lr_temp.permissao

            # Insiro na tabela temporaria
            call cta01m62_ins_temp(lr_temp.produto       ,
                                   lr_temp.cod_produto   ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   lr_temp.situacao      ,
                                   lr_temp.cont1         ,
                                   lr_temp.cont2         ,
                                   ""                    ,
                                   ""                    ,
                                   lr_temp.vig           ,
                                   lr_temp.documento     ,
                                   lr_temp.permissao     ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    )

    end if

    return


end function

#------------------------------------------------------------------------------
function cta01m62_rec_etapa(lr_param)
#------------------------------------------------------------------------------

define lr_param record
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano
end record

define lr_retorno record
    atdetpcod like datmsrvacp.atdetpcod,
    resultado smallint
end record

initialize lr_retorno.* to null

   open ccta01m62012 using lr_param.atdsrvnum,
                           lr_param.atdsrvano,
                           lr_param.atdsrvnum,
                           lr_param.atdsrvano
   whenever error continue
   fetch ccta01m62012  into lr_retorno.atdetpcod
   close ccta01m62012
   whenever error stop

   if lr_retorno.atdetpcod = 5  or    # Servico Cancelado
      lr_retorno.atdetpcod = 6  or    # Servico Excluido
      lr_retorno.atdetpcod = 10 then  # Retorno
         let lr_retorno.resultado = 0
   else
         let lr_retorno.resultado = 1
   end if

   return lr_retorno.resultado
end function

#------------------------------------------------------------------------------
function cta01m62_conta_negocio()
#------------------------------------------------------------------------------
define l_sql char(200)
define l_qtd integer
define l_resultado smallint

let l_qtd = null
let l_resultado = null

      let l_sql = " select count(*) " ,
                  " from cta01m62_temp "
      prepare pcta01m62013 from l_sql
      declare ccta01m62013 cursor for pcta01m62013

      open ccta01m62013
      whenever error continue
      fetch ccta01m62013 into l_qtd
      close ccta01m62013
      whenever error stop

      if l_qtd > 0 then
         let l_resultado = 0
      else
         let l_resultado = 1
      end if

   return l_resultado

end function

#------------------------------------------------------------------------------
function cta01m62_rec_vigencia(lr_param)
#------------------------------------------------------------------------------

define lr_param record
 crtsaunum like datksegsau.crtsaunum
end record

define lr_retorno record
       inidat date,
       fimdat date
end record

define lr_concatena record
       inidat char(10) ,
       fimdat char(10)
end record

initialize lr_retorno.*,
           lr_concatena.* to null

      if lr_param.crtsaunum is not null then
         let lr_concatena.inidat = '01/01/', year(today) using "####"
         let lr_concatena.fimdat = '31/12/', year(today) using "####"
         let lr_retorno.inidat = lr_concatena.inidat
         let lr_retorno.fimdat = lr_concatena.fimdat
      else
         let lr_retorno.inidat = today - 360 units day
         let lr_retorno.fimdat = today
      end if

     return lr_retorno.*

end function

#------------------------------------------------------------------------------
function cta01m62_desconsidera_servico(lr_param)
#------------------------------------------------------------------------------

define lr_param record
  atdsrvorg like datmservico.atdsrvorg ,
  inidat    date                       ,
  fimdat    date                       ,
  atddat    date
end record

define lr_retorno record
  resultado smallint
end record

initialize lr_retorno.* to null

   if lr_param.atddat < lr_param.inidat  or
      lr_param.atddat > lr_param.fimdat  then
         let lr_retorno.resultado = 0
         return lr_retorno.*
   else
         let lr_retorno.resultado = 1
   end if

   if lr_param.atdsrvorg =  1   or
      lr_param.atdsrvorg =  2   or
      lr_param.atdsrvorg =  3   or
      lr_param.atdsrvorg =  4   or
      lr_param.atdsrvorg =  5   or
      lr_param.atdsrvorg =  6   or
      lr_param.atdsrvorg =  8   or
      lr_param.atdsrvorg =  9   or
      lr_param.atdsrvorg = 13   or
      lr_param.atdsrvorg = 14   then
         let lr_retorno.resultado = 1
   else
         let lr_retorno.resultado = 0
   end if

   return lr_retorno.*

end function

#------------------------------------------------------------------------------
function cta01m62_rec_proposta(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cta01m62 record
       ramcod     like datrligapol.ramcod      ,
       prporg     like gcamproponente.prporg   ,
       prpnumdig  like gcamproponente.prpnumdig,
       evtdat     like papmhist.evtdat         ,
       tfades     like packtarefa.tfades
end record

define lr_retorno record
      { prporg    like gcamproponente.prporg   ,
       prpnumdig like gcamproponente.prpnumdig,
       sisemscod like pgakorigem.sisemscod    ,
       corsus    like apamcor.corsus          ,
       ramcod    like datrligapol.ramcod      ,
       prptip    dec(01,0)                    ,
       evtdat    like papmhist.evtdat         ,
       tfades    like packtarefa.tfades       ,}
       resultado  smallint
end record

define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       vig         smallint     ,
       permissao   char(1)      ,
       sitdoc      char(70)
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null

let lr_temp.cod_produto = 96
let lr_temp.vig         = 0
let lr_temp.cont1       = 0
let lr_temp.cont2       = 0

       # Recupero a descricao e a permissao do produto
       call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
       returning lr_temp.produto, lr_temp.permissao

       call figrc072_setTratarIsolamento()

       call fpacc280_rec_proposta(lr_param_cgccpfnum)
          returning lr_retorno.resultado

       if g_isoAuto.sqlCodErr <> 0 then
          error "Função fpacc280_rec_proposta indisponivel no momento! Avise a Informatica !" sleep 2
          return
       end if

       if lr_retorno.resultado = 0 then
          call cta01m62_seleciona_proposta()
          open ccta01m62014
          foreach ccta01m62014 into lr_cta01m62.prporg   ,
                                    lr_cta01m62.prpnumdig,
                                    lr_cta01m62.ramcod   ,
                                    lr_cta01m62.evtdat   ,
                                    lr_cta01m62.tfades
               let lr_cta01m62.tfades = upshift(lr_cta01m62.tfades)
               let lr_temp.sitdoc = "Situacao da Proposta : ", lr_cta01m62.tfades  clipped

               # Insiro na tabela temporaria
               call cta01m62_ins_temp(lr_temp.produto       ,
                                      lr_temp.cod_produto   ,
                                      ""                    ,
                                      lr_cta01m62.ramcod    ,
                                      ""                    ,
                                      ""                    ,
                                      ""                    ,
                                      ""                    ,
                                      lr_cta01m62.tfades    ,
                                      lr_temp.cont1         ,
                                      lr_temp.cont2         ,
                                      lr_cta01m62.evtdat    ,
                                      lr_cta01m62.evtdat    ,
                                      lr_temp.vig           ,
                                      ""                    ,
                                      lr_temp.permissao     ,
                                      lr_cta01m62.prporg    ,
                                      lr_cta01m62.prpnumdig ,
                                      lr_temp.sitdoc        ,
                                      ""                    ,
                                      ""                    )
          end foreach
     end if
    return

end function

#------------------------------------------------------------------------------
function cta01m62_rec_vistoria(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cta01m62 record
       vstnumdig    like avlmlaudo.vstnumdig           ,
       vstdat       like avlmlaudo.vstdat              ,
       vstcpodomdes like avlkdomcampovst.vstcpodomdes
end record

define lr_retorno record
       resultado  smallint
end record

define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       vig         smallint     ,
       permissao   char(1)      ,
       sitdoc      char(70)
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null
let lr_temp.cod_produto = 95
let lr_temp.vig         = 0
let lr_temp.cont1       = 0
let lr_temp.cont2       = 0

   # Recupero a descricao e a permissao do produto
   call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
   returning lr_temp.produto, lr_temp.permissao

   let lr_retorno.resultado = fvpic012_rec_vistoria(lr_param_cgccpfnum)

   if lr_retorno.resultado = 0 then

      call cta01m62_seleciona_vistoria()

      open ccta01m62015
      foreach ccta01m62015 into lr_cta01m62.vstnumdig   ,
                                lr_cta01m62.vstdat      ,
                                lr_cta01m62.vstcpodomdes
          let lr_temp.sitdoc = "Situacao da Vistoria : ", lr_cta01m62.vstcpodomdes  clipped

          # Insiro na tabela temporaria
          call cta01m62_ins_temp(lr_temp.produto           ,
                                 lr_temp.cod_produto       ,
                                 ""                        ,
                                 ""                        ,
                                 ""                        ,
                                 ""                        ,
                                 ""                        ,
                                 ""                        ,
                                 lr_cta01m62.vstcpodomdes  ,
                                 lr_temp.cont1             ,
                                 lr_temp.cont2             ,
                                 lr_cta01m62.vstdat        ,
                                 lr_cta01m62.vstdat        ,
                                 lr_temp.vig               ,
                                 lr_cta01m62.vstnumdig     ,
                                 lr_temp.permissao         ,
                                 ""                        ,
                                 ""                        ,
                                 lr_temp.sitdoc            ,
                                 ""                        ,
                                 ""                        )
      end foreach
  end if

  return
end function

#------------------------------------------------------------------------------
function cta01m62_rec_cobertura(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cta01m62 record
    cbpnum    like avbmcobert.cbpnum    ,
    soldat    like avbmcobert.soldat    ,
    vststtdes like avckstatus.vststtdes
end record

define lr_retorno record
       resultado  smallint
end record

define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       vig         smallint     ,
       permissao   char(1)      ,
       sitdoc      char(70)
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null
let lr_temp.cod_produto = 94
let lr_temp.vig         = 0
let lr_temp.cont1       = 0
let lr_temp.cont2       = 0

   # Recupero a descricao e a permissao do produto
   call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
   returning lr_temp.produto, lr_temp.permissao

   let lr_retorno.resultado = fvpic012_rec_cobertura(lr_param_cgccpfnum)

   if lr_retorno.resultado = 0 then

      call cta01m62_seleciona_cobertura()

      open ccta01m62016
      foreach ccta01m62016 into lr_cta01m62.cbpnum    ,
                                lr_cta01m62.soldat    ,
                                lr_cta01m62.vststtdes

        let lr_temp.sitdoc = "Situacao da Cobertura : ", lr_cta01m62.vststtdes  clipped

        # Insiro na tabela temporaria
        call cta01m62_ins_temp(lr_temp.produto           ,
                               lr_temp.cod_produto       ,
                               ""                        ,
                               ""                        ,
                               ""                        ,
                               ""                        ,
                               ""                        ,
                               ""                        ,
                               lr_cta01m62.vststtdes     ,
                               lr_temp.cont1             ,
                               lr_temp.cont2             ,
                               lr_cta01m62.soldat        ,
                               lr_cta01m62.soldat        ,
                               lr_temp.vig               ,
                               lr_cta01m62.cbpnum        ,
                               lr_temp.permissao         ,
                               ""                        ,
                               ""                        ,
                               lr_temp.sitdoc            ,
                               ""                        ,
                               ""                        )
      end foreach
    end if

    return
end function

#------------------------------------------------------------------------------
function cta01m62_cria_produto(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       unfprdcod like gsakdocngcseg.unfprdcod
end record

define lr_retorno record
    unfprddes  like gsakprdunfseg.unfprddes
end record

initialize lr_retorno.* to null

  open ccta01m62018 using lr_param.unfprdcod
  whenever error continue
  fetch ccta01m62018  into lr_retorno.unfprddes
  whenever error stop

  if sqlca.sqlcode <> 0  then
     error "Erro ao recuperar a descricao do produto ", sqlca.sqlcode
  else

     let lr_retorno.unfprddes = "N|", lr_retorno.unfprddes

     execute pcta01m62019 using lr_param.unfprdcod,
                                lr_retorno.unfprddes

     if sqlca.sqlcode <> 0  then
        error "Erro ao inserir o produto ", sqlca.sqlcode
     end if
  end if

  close ccta01m62018
end function

#------------------------------------------------------------------------------
function cta01m62_concatena_veic(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   succod    like datrligapol.succod    ,
   aplnumdig like datrligapol.aplnumdig ,
   itmnumdig like datrligapol.itmnumdig
end record

define lr_retorno record
   vcllicnum like abbmveic.vcllicnum ,
   vclmrcnom like agbkmarca.vclmrcnom,
   vcltipnom like agbktip.vcltipnom  ,
   vclmdlnom like agbkveic.vclmdlnom ,
   vclanofbc like abbmveic.vclanofbc ,
   vclanomdl like abbmveic.vclanomdl ,
   vclchs    char (20)               ,
   vcldes    char (70)
end record

initialize lr_retorno.* to null

  call cta01m63_rec_dados_veic(lr_param.*)
  returning lr_retorno.vcllicnum ,
            lr_retorno.vclmrcnom ,
            lr_retorno.vcltipnom ,
            lr_retorno.vclmdlnom ,
            lr_retorno.vclanofbc ,
            lr_retorno.vclanomdl ,
            lr_retorno.vclchs

  let lr_retorno.vcldes = "Placa.: ", lr_retorno.vcllicnum clipped, " Veiculo : ",
                                      lr_retorno.vclmrcnom clipped ,
                                 " ", lr_retorno.vcltipnom clipped,
                                 " ", lr_retorno.vclmdlnom clipped

  return lr_retorno.vcldes
end function

#------------------------------------------------------------------------------
function cta01m62_endereco_pss(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   pesnum like gsakpes.pesnum
end record

define lr_retorno record
   endlgdtip  like gsakpesend.endlgdtip   ,
   endlgd     like gsakpesend.endlgd      ,
   endnum     like gsakpesend.endnum      ,
   endcmp     like gsakpesend.endcmp      ,
   endcep     like gsakpesend.endcep      ,
   endcepcmp  like gsakpesend.endcepcmp   ,
   endbrr     like gsakpesend.endbrr      ,
   endcid     like gsakpesend.endcid      ,
   endufd     like gsakpesend.endufd      ,
   endereco   char(70)
end record

initialize lr_retorno.* to null

  call cta00m25_endereco_pss(lr_param.pesnum)
  returning lr_retorno.endlgdtip    ,
            lr_retorno.endlgd       ,
            lr_retorno.endnum       ,
            lr_retorno.endcmp       ,
            lr_retorno.endufd       ,
            lr_retorno.endbrr       ,
            lr_retorno.endcid       ,
            lr_retorno.endcep       ,
            lr_retorno.endcepcmp

  let lr_retorno.endereco = "Endereco: ", lr_retorno.endlgd clipped, " CEP: ",
                          lr_retorno.endcep clipped ,
                          "-", lr_retorno.endcepcmp
  return lr_retorno.endereco

end function
#------------------------------------------------------------------------------
function cta01m62_rec_itau_re(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cta01m62 record
       succod     like datmresitaapl.succod         ,
       itaramcod  like datmresitaapl.itaramcod      ,
       aplnum     like datmresitaapl.aplnum         ,
       aplitmnum  like datmresitaaplitm.aplitmnum   ,
       aplseqnum  like datmresitaaplitm.aplseqnum   ,
       itaciacod  like datmresitaapl.itaciacod      ,
       incvigdat  like datmresitaapl.incvigdat      ,
       fnlvigdat  like datmresitaapl.fnlvigdat      ,
       itmsttcod  like datmresitaaplitm.itmsttcod
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30)
end record


define lr_temp record
       cont1       integer   ,
       cont2       integer   ,
       produto     char(30)  ,
       cod_produto smallint  ,
       crtsaunum   char(18)  ,
       bnfnum      char(20)  ,
       situacao    char(15)  ,
       viginc      date      ,
       vigfnl      date      ,
       vig         smallint  ,
       documento   char(110) ,
       permissao   char(1)   ,
       itaciacod   smallint
end record

initialize lr_retorno.* to null
initialize lr_temp.*    to null

if m_prepare is null or
   m_prepare <> true then
   call cta01m62_prepare()
end if

let lr_temp.cod_produto = 93

    open c_cta01m62_023 using lr_param_cgccpfnum
    foreach c_cta01m62_023 into   lr_cta01m62.*

     if lr_cta01m62.incvigdat <= today and
        lr_cta01m62.fnlvigdat >= today then

           if lr_cta01m62.itmsttcod <> 'C' then
               let lr_temp.situacao = "ATIVA"
               let lr_temp.vig = 0
           else
               let lr_temp.situacao = "CANCELADA"
               let lr_temp.vig = 1
           end if
     else
           let lr_temp.situacao = "VENCIDA"
           let lr_temp.vig = 1
     end if

     # Recupera a quantidade de servicos
     call cta01m62_conta_servico(lr_cta01m62.succod    ,
                                 lr_cta01m62.itaramcod ,
                                 lr_cta01m62.aplnum    ,
                                 lr_cta01m62.aplitmnum ,
                                 "","","","",
                                 lr_cta01m62.itaciacod)
     returning lr_temp.cont1, lr_temp.cont2

      # Recupero a descricao e a permissao do produto
      call cta01m62_rec_descricao_prod(lr_temp.cod_produto)
      returning lr_temp.produto, lr_temp.permissao

      let lr_temp.viginc    = lr_cta01m62.incvigdat
      let lr_temp.vigfnl    = lr_cta01m62.fnlvigdat
      let lr_temp.itaciacod = lr_cta01m62.itaciacod

      # Insiro na tabela temporaria
      call cta01m62_ins_temp(lr_temp.produto       ,
                             lr_temp.cod_produto   ,
                             lr_cta01m62.succod    ,
                             lr_cta01m62.itaramcod ,
                             lr_cta01m62.aplnum    ,
                             lr_cta01m62.aplitmnum ,
                             lr_temp.crtsaunum     ,
                             lr_temp.bnfnum        ,
                             lr_temp.situacao      ,
                             lr_temp.cont1         ,
                             lr_temp.cont2         ,
                             lr_temp.viginc        ,
                             lr_temp.vigfnl        ,
                             lr_temp.vig           ,
                             lr_temp.documento     ,
                             lr_temp.permissao     ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             lr_temp.itaciacod     )
    end foreach

    return

end function

#------------------------------------------------------------------------------
