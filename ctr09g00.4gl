############################################################################
# Nome do Modulo: ctr09g00                                        Marcelo  #
#                                                                 Gilberto #
# Funcoes genericas para gravacao de dimensoes                    Set/1999 #
###############################################################################
#                         * * * Alteracoes * * *                              #
# --------------------------------------------------------------------------- #
# 25/02/2004  Paula Romanini PSI183105 Incluir a funcao ctr09g00_motivo       #
#                            OSF32646                                         #
###############################################################################
# 07/04/2004  Mariana        CT193143  Alterar o cursor c_dagkfundim          #
###############################################################################
# 19/05/2004 Teresinha       CT211044  Comentar linha do programa             #
#-----------------------------------------------------------------------------#
# Data        Autor Fabrica Origem    Alteracao                               #
# ----------  ------------- --------- --------------------------------------- #
# 08/08/2005  Paulo, Meta   PSI194212 Na funcao ctr09g00_local, verificar a   #
#                                     existencia do registro na tabela antes  #
#                                     de inserir.                             #
###############################################################################

 database porto

#---------------------------------------------------------------
 function ctr09g00_host()
#---------------------------------------------------------------

 define ws          record
    hostname        char (20)
 end record

 initialize ws.*  to null

#---------------------------------------------------------------
# Verifica banco de dados utilizado (desenvolvimento ou producao)
#---------------------------------------------------------------

 select sitename
   into ws.hostname
   from dual

 if sqlca.sqlcode <> 0  then
    initialize ws.*  to null
    return ws.hostname
 end if

 if ws.hostname is not null  then
    let ws.hostname = ws.hostname[1,3]
 end if

 if ws.hostname = "u07"  then
    let ws.hostname = "u07"
 else
    let ws.hostname = "u33"
 end if

#WWW PARA TESTES -->  let ws.hostname = "u07"

 return ws.hostname

 end function  ###  ctr09g00_host

#---------------------------------------------------------------
 function ctr09g00_tempo(param)
#---------------------------------------------------------------

 define param       record
    ligdat          like datmligacao.ligdat,
    lighor          like datmligacao.lighorinc,
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    utldat          date,
    chrdat          char (10),
    tmpdia          dec  (2,0),
    tmpmes          dec  (2,0),
    tmpano          dec  (4,0),
    tmpsemdia       char (07),
    tmpferdiaflg    char (01),
    tmpdimcod       integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select tmpdimcod    ",
                 "  from dmct24h@", ws.hostname clipped, ":dagktmpdim",
                 " where tmpdiadat = ?",
                 "   and tmpdiahor = ?"
    prepare sel_dagktmpdim  from ws.sql
    declare c_dagktmpdim  cursor with hold for sel_dagktmpdim

    let ws.sql = "insert into dmct24h@", ws.hostname clipped, ":dagktmpdim",
                 "       (tmpdimcod, tmpdiadat, tmpdiahor,",
                 "        tmpdia   , tmpmes   , tmpano   ,",
                 "        tmpsemdia, tmpferdiaflg        )",
                 "values (0, ?, ?, ?, ?, ?, ?, ?)         "
    prepare ins_dagktmpdim from ws.sql

    let param.privez = false
 end if

 let ws.tabnom = "dagktmpdim"

 open  c_dagktmpdim using param.ligdat,
                          param.lighor
 fetch c_dagktmpdim into  ws.tmpdimcod

 if sqlca.sqlcode = notfound  then
    let ws.chrdat = param.ligdat

    let ws.tmpdia = ws.chrdat[1,2]
    let ws.tmpmes = ws.chrdat[4,5]
    let ws.tmpano = ws.chrdat[7,10]

    case weekday(param.ligdat)
       when 0  let ws.tmpsemdia = "DOMINGO"
       when 1  let ws.tmpsemdia = "SEGUNDA"
       when 2  let ws.tmpsemdia = "TERCA"
       when 3  let ws.tmpsemdia = "QUARTA"
       when 4  let ws.tmpsemdia = "QUINTA"
       when 5  let ws.tmpsemdia = "SEXTA"
       when 6  let ws.tmpsemdia = "SABADO"
    end case

    call dias_uteis(param.ligdat, 0, "", "N", "N")
         returning ws.utldat

    if ws.utldat is null          or
       ws.utldat  < param.ligdat  then
       let ws.sqlcod = -1000
       display "Erro na verificacao da data ", param.ligdat, "/", ws.utldat
       return ws.tmpdimcod, ws.tabnom, ws.sqlcod, param.privez
    end if

    if ws.utldat = param.ligdat  then
       let ws.tmpferdiaflg = "N"
    else
       let ws.tmpferdiaflg = "S"
    end if

    whenever error continue
    execute ins_dagktmpdim using param.ligdat,
                                 param.lighor,
                                 ws.tmpdia   ,
                                 ws.tmpmes   ,
                                 ws.tmpano   ,
                                 ws.tmpsemdia,
                                 ws.tmpferdiaflg
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.tmpdimcod to null
    else
       let ws.tmpdimcod = sqlca.sqlerrd[2]
    end if
 end if

 let ws.sqlcod = sqlca.sqlcode

 close c_dagktmpdim

 return ws.tmpdimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_tempo

#---------------------------------------------------------------
 function ctr09g00_func(param)
#---------------------------------------------------------------

 define param       record
    empcod          like isskfunc.empcod,
    funmat          like isskfunc.funmat,
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    empcod          like isskfunc.empcod,
    funnom          like isskfunc.funnom,
    dptsgl          like isskfunc.dptsgl,
    fundimcod       integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select fundimcod ",
                 "  from dmct24h@", ws.hostname clipped, ":dagkfundim",
                 " where funempcod = ?",
                 "   and funmat = ? ",
                 "   and dptsgl = ? ",
                 "   and funnom = ? " 	
    prepare sel_dagkfundim  from ws.sql
    declare c_dagkfundim  cursor with hold for sel_dagkfundim

    let ws.sql = "select empcod, funnom,",
                 "       dptsgl         ",
                 "  from isskfunc       ",
                 " where empcod = ?     ",
                 "   and funmat = ?     "
    prepare sel_isskfunc from ws.sql
    declare c_isskfunc cursor with hold for sel_isskfunc

    let ws.sql = "insert into dmct24h@", ws.hostname clipped, ":dagkfundim",
                 "       (fundimcod, funempcod, funmat   ,",
                 "        funnom   , dptsgl              )",
                 "values (0, ?, ?, ?, ?)                  "
    prepare ins_dagkfundim from ws.sql

    let param.privez = false
 end if

 let ws.tabnom = "dagkfundim"

 initialize ws.empcod  to null
 initialize ws.funnom  to null
 initialize ws.dptsgl  to null

 open  c_isskfunc  using param.empcod,
                         param.funmat
 fetch c_isskfunc  into  ws.empcod,
                         ws.funnom,
                         ws.dptsgl

 if sqlca.sqlcode = 0  then
    let ws.funnom = upshift(ws.funnom)
    let ws.dptsgl = upshift(ws.dptsgl)
 else
    let ws.empcod = 1
    let ws.funnom = "** NAO CADASTRADO **"
    let ws.dptsgl = "N/CAD"
 end if

    close c_isskfunc


 open  c_dagkfundim using param.empcod,
                          param.funmat,
                          ws.dptsgl,
                          ws.funnom
 fetch c_dagkfundim into  ws.fundimcod

 if sqlca.sqlcode = notfound  then

    whenever error continue
    execute ins_dagkfundim using param.empcod,
                                 param.funmat,
                                 ws.funnom,
                                 ws.dptsgl
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.fundimcod to null
    else
       let ws.fundimcod = sqlca.sqlerrd[2]
    end if
 end if

 let ws.sqlcod = sqlca.sqlcode

 close c_dagkfundim

 return ws.fundimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_func

#---------------------------------------------------------------
 function ctr09g00_assunto(param)
#---------------------------------------------------------------

 define param       record
    c24astcod       like datkassunto.c24astcod,
    c24astadv       char(3),
    c24atrflg       like datkassunto.c24atrflg,
    c24jstflg       like datkassunto.c24jstflg,
    privez          dec (1,0)
 end record

 define ws          record
    c24astbo        char(6),
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    c24astdimcod    integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 if param.privez = true  then

    let ws.hostname = ctr09g00_host()

    if param.c24atrflg is not null or
       param.c24jstflg is not null then

       let ws.sql = "select c24astdimcod ",
                    "  from dmct24h@", ws.hostname clipped, ":dagkastdim",
                    " where c24astcod = ?",
                    "   and c24atrflg = '", param.c24atrflg, "'",
                    "   and c24jstflg = '", param.c24jstflg, "'",
                    "order by c24astdimcod desc"
    else

       let ws.sql = "select c24astdimcod ",
                    "  from dmct24h@", ws.hostname clipped, ":dagkastdim",
                    " where c24astcod = ?",
                    "order by c24astdimcod desc"
    end if
    let param.privez = false

    prepare sel_dagkastdim  from ws.sql
    declare c_dagkastdim  cursor with hold for sel_dagkastdim
 end if

 # Assunto BO Assunto + (ALT,CAN,RET,REC,IND,CON)
 let ws.c24astbo = param.c24astcod,
                   param.c24astadv

 let ws.tabnom = "dagkastdim"

 open  c_dagkastdim  using ws.c24astbo
 fetch c_dagkastdim  into  ws.c24astdimcod

 if sqlca.sqlcode = notfound  then
    initialize ws.c24astdimcod to null
 end if

 let ws.sqlcod = sqlca.sqlcode

 close c_dagkastdim

 return ws.c24astdimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_assunto

#---------------------------------------------------------------
 function ctr09g00_convenio(param)
#---------------------------------------------------------------

 define param       record
    cvnnum          like datmligacao.ligcvntip,
    cvnnom          char (50),
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    cvndimcod       integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select cvndimcod ",
                 "  from dmct24h@", ws.hostname clipped, ":dagkcvndim",
                 " where cvnnum = ?"
    prepare sel_dagkcvndim  from ws.sql
    declare c_dagkcvndim  cursor with hold for sel_dagkcvndim

    let ws.sql = "insert into dmct24h@", ws.hostname clipped, ":dagkcvndim",
                 "       (cvndimcod, cvnnum, cvnnom)  ",
                 "values (0, ?, ?)"
    prepare ins_dagkcvndim from ws.sql

    let param.privez = false
 end if

 let ws.tabnom = "dagkcvndim"

 open  c_dagkcvndim  using param.cvnnum
 fetch c_dagkcvndim  into  ws.cvndimcod

 if sqlca.sqlcode = notfound  then
    whenever error continue
    execute ins_dagkcvndim using param.cvnnum,
                                 param.cvnnom
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.cvndimcod to null
    else
       let ws.cvndimcod = sqlca.sqlerrd[2]
    end if
 end if

 close c_dagkcvndim

 let ws.sqlcod = sqlca.sqlcode

 close c_dagkcvndim

 return ws.cvndimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_convenio

#---------------------------------------------------------------
 function ctr09g00_veiculo(param)
#---------------------------------------------------------------

 define param       record
    vclcoddig       like agbkveic.vclcoddig,
    privez          dec (1,0)
 end record

 define d_ctr09g00  record
    vcldes          like agbkvcldes.vcldes,
    vclmrcnom       like agbkmarca.vclmrcnom,
    vcltipnom       like agbktip.vcltipnom,
    vclmdlnom       like agbkveic.vclmdlnom
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    vcldimcod       integer,
    vclmrccod       like agbkmarca.vclmrccod,
    vcltipcod       like agbktip.vcltipcod,
    hostname        char (20)
 end record

 initialize ws.*  to null

 let ws.tabnom = "dagkvcldim"

 if param.vclcoddig is null  then
    let ws.vcldimcod = 0
    let ws.sqlcod    = 0
    return ws.vcldimcod, ws.tabnom, ws.sqlcod, param.privez
 end if

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select vcldimcod    ",
                 "  from dmct24h@", ws.hostname clipped, ":dagkvcldim",
                 " where vclcoddig = ?"
    prepare sel_dagkvcldim  from ws.sql
    declare c_dagkvcldim  cursor with hold for sel_dagkvcldim

    let ws.sql = "insert into dmct24h@", ws.hostname clipped, ":dagkvcldim",
                 "       (vcldimcod, vclcoddig, vcldes   , ",
                 "        vclmrcnom, vcltipnom, vclmdlnom) ",
                 "values (0, ?, ?, ?, ?, ?)"
    prepare ins_dagkvcldim from ws.sql

    let ws.sql = "select vclmrccod,   ",
                 "       vcltipcod,   ",
                 "       vclmdlnom    ",
                 "  from agbkveic     ",
                 " where vclcoddig = ?"
    prepare sel_agbkveic from ws.sql
    declare c_agbkveic cursor with hold for sel_agbkveic

    let ws.sql = "select vclmrcnom    ",
                 "  from agbkmarca    ",
                 " where vclmrccod = ?"
    prepare sel_agbkmarca from ws.sql
    declare c_agbkmarca cursor with hold for sel_agbkmarca

    let ws.sql = "select vcltipnom    ",
                 "  from agbktip      ",
                 " where vclmrccod = ?",
                 "   and vcltipcod = ?"
    prepare sel_agbktip from ws.sql
    declare c_agbktip cursor with hold for sel_agbktip

    let param.privez = false
 end if

 open  c_dagkvcldim  using param.vclcoddig
 fetch c_dagkvcldim  into  ws.vcldimcod

 if sqlca.sqlcode = notfound  then
    open  c_agbkveic using param.vclcoddig
    fetch c_agbkveic into  ws.vclmrccod,
                           ws.vcltipcod,
                           d_ctr09g00.vclmdlnom
    close c_agbkveic

    open  c_agbkmarca using ws.vclmrccod
    fetch c_agbkmarca into  d_ctr09g00.vclmrcnom
    close c_agbkmarca

    open  c_agbktip using ws.vclmrccod, ws.vcltipcod
    fetch c_agbktip into  d_ctr09g00.vcltipnom
    close c_agbktip

    let d_ctr09g00.vcldes = d_ctr09g00.vclmrcnom clipped, " ",
                            d_ctr09g00.vcltipnom clipped, " ",
                            d_ctr09g00.vclmdlnom clipped

    whenever error continue
    execute ins_dagkvcldim using param.vclcoddig,
                                 d_ctr09g00.vcldes,
                                 d_ctr09g00.vclmrcnom,
                                 d_ctr09g00.vcltipnom,
                                 d_ctr09g00.vclmdlnom
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.vcldimcod to null
    else
       let ws.vcldimcod = sqlca.sqlerrd[2]
    end if
 end if

 let ws.sqlcod = sqlca.sqlcode

 close c_dagkvcldim

 return ws.vcldimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_veiculo

#---------------------------------------------------------------
 function ctr09g00_local(param)
#---------------------------------------------------------------

 define param       record
    ufdcod          like datmlcl.ufdcod,
    cidnom          like datmlcl.cidnom,
    lclbrrnom       like datmlcl.lclbrrnom,
    lgdtip          like datmlcl.lgdtip,
    lgdnom          like datmlcl.lgdnom,
    lgdnum          like datmlcl.lgdnum,
    lclltt          like datmlcl.lclltt,
    lcllgt          like datmlcl.lcllgt,
    lclidttxt       like datmlcl.lclidttxt,
    ofnnumdig       like datmlcl.ofnnumdig,
    ofncrdflg       like sgokofi.ofncrdflg,
    ofntip          char(15),
    dddcod          like datmlcl.dddcod,
    lcltelnum       like datmlcl.lcltelnum,
    lclcttnom       like datmlcl.lclcttnom,
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    srvlcldimcod    integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select srvlcldimcod",
                 "  from dmct24h@", ws.hostname clipped, ":dagksrvlcldim",
                 " where ufdcod = ?",
                 "   and cidnom = ?",
                 "   and brrnom = ?",
                 "   and lgdtip = ?",
                 "   and lgdnom = ?",
                 "   and lgdnum = ?"

    prepare sel_dagksrvlcldim from ws.sql
    declare c_dagksrvlcldim cursor with hold for sel_dagksrvlcldim

    let ws.sql = "insert into dmct24h@", ws.hostname clipped,
                 ":dagksrvlcldim (srvlcldimcod, ufdcod,    cidnom, ",
                 "                brrnom      , lgdtip,    lgdnom, ",
                 "                lgdnum      , lclltt,    lcllgt, ",
                 "                lclidttxt   , ofnnumdig, crdofnflg,",
                 "                ofntip      , dddcod,    lcltelnum,",
                 "                lclcttnom   ) ",
                 "        values (  0, ?, ?, ?, ?, ?, ?, ?, ?,",
                 "                  ?, ?, ?, ?, ?, ?, ? ) "
    prepare ins_dagksrvlcldim from ws.sql

    let param.privez = false
 end if

 let ws.tabnom = "dagksrvlcldim"

 if param.lclbrrnom is null  then
    let param.lclbrrnom = "** NAO INFORMADO **"
 end if
 if param.lgdtip is null  then
    let param.lgdtip = "R"
 end if
 if param.lgdnom is null  then
    let param.lgdnom = "** NAO INFORMADA **"
 end if
 if param.lgdnum is null  then
    let param.lgdnum = 0
 end if

 open  c_dagksrvlcldim  using param.ufdcod,
                              param.cidnom,
                              param.lclbrrnom,
                              param.lgdtip,
                              param.lgdnom,
                              param.lgdnum

 whenever error continue
 fetch c_dagksrvlcldim  into  ws.srvlcldimcod
 whenever error stop
 if sqlca.sqlcode = notfound then
    whenever error continue
    execute ins_dagksrvlcldim using param.ufdcod,
                                    param.cidnom,
                                    param.lclbrrnom,
                                    param.lgdtip,
                                    param.lgdnom,
                                    param.lgdnum,
                                    param.lclltt,
                                    param.lcllgt,
                                    param.lclidttxt,
                                    param.ofnnumdig,
                                    param.ofncrdflg,
                                    param.ofntip,
                                    param.dddcod,
                                    param.lcltelnum,
                                    param.lclcttnom

    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.srvlcldimcod to null
    else
       let ws.srvlcldimcod = sqlca.sqlerrd[2]
    end if
 end if

 let ws.tabnom = "dagksrvlcldim"
 let ws.sqlcod = sqlca.sqlcode

 close c_dagksrvlcldim

 return ws.srvlcldimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_local

#---------------------------------------------------------------
 function ctr09g00_prestador(param)
#---------------------------------------------------------------

 define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    prsdimcod       integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 let ws.tabnom = "dagkprsdim"

 if param.pstcoddig is null  then
    let ws.prsdimcod = 0
    let ws.sqlcod    = 0
    return ws.prsdimcod, ws.tabnom, ws.sqlcod, param.privez
 end if

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select prsdimcod    ",
                 "  from dmct24h@", ws.hostname clipped, ":dagkprsdim",
                 " where pstcoddig = ?"
    prepare sel_dagkprsdim  from ws.sql
    declare c_dagkprsdim  cursor with hold for sel_dagkprsdim

    let param.privez = false
 end if

 open  c_dagkprsdim  using param.pstcoddig
 fetch c_dagkprsdim  into  ws.prsdimcod

 if sqlca.sqlcode = notfound  then
    initialize ws.prsdimcod to null
 end if

 let ws.sqlcod = sqlca.sqlcode

 close c_dagkprsdim

 return ws.prsdimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_prestador

#---------------------------------------------------------------
 function ctr09g00_socorrista(param)
#---------------------------------------------------------------

 define param       record
    srrcoddig       like datksrr.srrcoddig,
    srrnom          like datksrr.srrnom,
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    srrdimcod       integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 let ws.tabnom = "dagksrrdim"

 if param.srrcoddig is null  then
    let ws.srrdimcod = 0
    let ws.sqlcod    = 0
    return ws.srrdimcod, ws.tabnom, ws.sqlcod, param.privez
 end if

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select srrnom       ",
                 "  from datksrr      ",
                 " where srrcoddig = ?"
    prepare sel_datksrr from ws.sql
    declare c_datksrr cursor with hold for sel_datksrr

    let ws.sql = "select srrdimcod    ",
                 "  from dmct24h@", ws.hostname clipped, ":dagksrrdim",
                 " where srrcoddig = ?"
    prepare sel_dagksrrdim  from ws.sql
    declare c_dagksrrdim  cursor with hold for sel_dagksrrdim

    let ws.sql = "insert into dmct24h@", ws.hostname clipped, ":dagksrrdim",
                 "       (srrdimcod, srrcoddig, srrnom)  ",
                 "values (0, ?, ?)"
    prepare ins_dagksrrdim from ws.sql

    let param.privez = false
 end if

 open  c_dagksrrdim  using param.srrcoddig
 fetch c_dagksrrdim  into  ws.srrdimcod

 if sqlca.sqlcode = notfound  then
    whenever error continue

    if param.srrnom is null  then
       open  c_datksrr using param.srrcoddig
       fetch c_datksrr into  param.srrnom
       if sqlca.sqlcode <> 0  then
          let ws.sqlcod = sqlca.sqlcode
          return ws.srrdimcod, ws.tabnom, ws.sqlcod, param.privez
       end if
       close c_datksrr
    end if

    execute ins_dagksrrdim using param.srrcoddig,
                                 param.srrnom
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.srrdimcod to null
    else
       let ws.srrdimcod = sqlca.sqlerrd[2]
    end if
 end if

 let ws.sqlcod = sqlca.sqlcode

 close c_dagksrrdim

 return ws.srrdimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_socorrista

#---------------------------------------------------------------
 function ctr09g00_favorecido(param)
#---------------------------------------------------------------

 define param       record
    pstcoddig       like dbsmopg.pstcoddig,
    socopgfavnom    like dbsmopgfav.socopgfavnom,
    pestip          like dbsmopgfav.pestip,
    cgccpfnum       like dbsmopgfav.cgccpfnum,
    cgcord          like dbsmopgfav.cgcord,
    cgccpfdig       like dbsmopgfav.cgccpfdig,
    privez          dec (1,0)
 end record

 define ws          record
    sql             char (900),
    tabnom          char (30),
    sqlcod          integer,
    favdimcod       integer,
    hostname        char (20)
 end record

 initialize ws.*  to null

 let ws.tabnom = "dagkfavdim"

 if param.cgccpfnum    is null  and
    param.socopgfavnom is null  then
    let ws.sqlcod  = 0
    return ws.favdimcod, ws.tabnom, ws.sqlcod, param.privez
 end if

 if param.privez = true  then
    let ws.hostname = ctr09g00_host()

    let ws.sql = "select favdimcod",
                 "  from dmct24h@", ws.hostname clipped, ":dagkfavdim",
                 " where pstcoddig = ?"
    prepare sel_dagkfavdim from ws.sql
    declare c_dagkfavdim cursor with hold for sel_dagkfavdim

    let ws.sql = "insert into dmct24h@", ws.hostname clipped,
                 ":dagkfavdim (favdimcod , pstcoddig, socfavnom, ",
                 "             pestip    , cgccpfnum, cgcord,    ",
                 "             cgccpfdig )                       ",
                 "        values (  0, ?, ?, ?, ?, ?, ? ) "
    prepare ins_dagkfavdim from ws.sql

    let param.privez = false
 end if


 open  c_dagkfavdim  using param.pstcoddig
 fetch c_dagkfavdim  into  ws.favdimcod

 if sqlca.sqlcode = notfound  then
    whenever error continue
    execute ins_dagkfavdim using param.pstcoddig,
                                 param.socopgfavnom,
                                 param.pestip,
                                 param.cgccpfnum,
                                 param.cgcord,
                                 param.cgccpfdig

    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -391  then
          let ws.tabnom = sqlca.sqlerrm
       end if
       initialize ws.favdimcod to null
    else
       let ws.favdimcod = sqlca.sqlerrd[2]
    end if
 end if

 let ws.tabnom = "dagkfavdim"
 let ws.sqlcod = sqlca.sqlcode

 close c_dagkfavdim

 return ws.favdimcod, ws.tabnom, ws.sqlcod, param.privez

 end function  ###  ctr09g00_favorecido

#---------------------------------------------------------------
 function ctr09g00_motivo(l_param)
#---------------------------------------------------------------

  define l_param record
    c24astcod    like datkassunto.c24astcod
   ,rcuccsmtvcod like datkrcuccsmtv.rcuccsmtvcod
   ,rcuccsmtvdes like datkrcuccsmtv.rcuccsmtvdes
   ,privez       dec(1,0)
  end record

  define ws record
    sql             char(900)
   ,tabnom          char(30)
   ,sqlcod          integer
   ,rcuccsmtvdimcod integer
   ,hostname        char(20)
  end record

  define l_rcuccsmtvdimcod integer

  initialize ws.* to null

  if l_param.privez = true then
     let ws.hostname = ctr09g00_host()

     let ws.sql = "select rcuccsmtvdimcod    ",
                  "  from dmct24h@", ws.hostname clipped, ":dagkrcuccsmtvdim",
                  " where rcuccsmtvcod = ?       ",
                  "   and c24astcod    = ?       ",
              #   "   and rcuccsmtvdes = ?       ", -- CT 211044
                  " order by rcuccsmtvdimcod desc"
     prepare pctr09g00001  from ws.sql
     declare cctr09g00001  cursor for pctr09g00001

     let l_param.privez = false
  end if

  whenever error continue
  open cctr09g00001 using l_param.rcuccsmtvcod
                         ,l_param.c24astcod
                       # ,l_param.rcuccsmtvdes  -- CT 211044
  fetch cctr09g00001 into l_rcuccsmtvdimcod
  whenever error stop
   if sqlca.sqlcode = 100 then
      initialize ws.rcuccsmtvdimcod to null
   else
     let ws.rcuccsmtvdimcod = l_rcuccsmtvdimcod
   end if
   let ws.sqlcod = sqlca.sqlcode
  close cctr09g00001

  return ws.rcuccsmtvdimcod
        ,ws.tabnom
        ,ws.sqlcod
        ,l_param.privez


end function   ### ctr09g00_motivo
