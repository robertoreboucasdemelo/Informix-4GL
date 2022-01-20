#############################################################################
# Nome do Modulo: CTS00G00                                          Marcelo #
#                                                                  Gilberto #
# Impressao Remota do Laudo de Servico                             Jun/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Incluir identificacao para servicos #
#                                       atendidos como particular.          #
#---------------------------------------------------------------------------#
# 17/03/1999  PSI 8009-8   Wagner       Incluir nr.telefone do segurado em  #
#                                       todos os tipos de servicos.         #
#---------------------------------------------------------------------------#
# 06/04/1999  PSI 5591-3   Gilberto     Utilizacao dos campos padronizados  #
#                                       atraves do guia postal.             #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#-----------------------------------------------------------------------------#
# 18/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a     #
#                                       serem excluidos.                      #
#-----------------------------------------------------------------------------#
# 14/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo         #
#                                       atdsrvnum de 6 p/ 10.                 #
#                                       Troca do campo atdtip p/ atdsrvorg.   #
#-----------------------------------------------------------------------------#
# 01/11/2000  AS 22241     Ruiz         Chamar funcao abre banco              #
#-----------------------------------------------------------------------------#
# 13/07/2001  Claudinha    Ruiz         tirar o prepare gcaksusep,gcakfilial, #
#                                       gcakcorr.                             #
#-----------------------------------------------------------------------------#
# 23/05/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 #
# 13/08/2009  Sergio Burini       PSI 244236     Inclusão do Sub-Dairro       #
###############################################################################

 database porto

 main

    call fun_dba_abre_banco("CT24HS")

    set lock mode to wait
    set isolation to dirty read
    call startlog("cts00g00.log")
    call cts00g00()
 end main

#----------------------------------------------------------------------
 function cts00g00()
#----------------------------------------------------------------------

 define d_cts00g00  record
    atdtrxnum       like datmtrxfila.atdtrxnum,
    atdtrxsit       like datmtrxfila.atdtrxsit,
    atdtrxdat       like datmtrxfila.atdtrxdat,
    atdtrxhor       like datmtrxfila.atdtrxhor,
    atdsrvnum       like datmtrxfila.atdsrvnum,
    atdsrvano       like datmtrxfila.atdsrvano,
    atdvclsgl       like datkveiculo.atdvclsgl ,
    atdimpcod       like datktrximp.atdimpcod ,
    atdimpsit       like datktrximp.atdimpsit
 end record

 define ws          record
    privez          smallint ,
    retflg          smallint ,
    hora            char (15),
    data            char (10),
    espera          char (09),
    tabname         like systables.tabname,
    sqlcode         integer
 end record

 define str_laudo   char(3586)
 define sql_comando char(500)
 define x           smallint

 initialize d_cts00g00.*  to null
 initialize ws.*          to null

 let ws.data   = today
 let ws.privez = true

 let sql_comando = "select atdimpsit     ",
                   "  from datktrximp    ",
                   " where atdimpcod = ? "

 prepare sel_datktrximp  from sql_comando
 declare c_datktrximp  cursor for sel_datktrximp


 #-------------------------------------------------------------------------
 # Ler todas as transmissoes pendentes
 #-------------------------------------------------------------------------
 declare c_cts00g00 cursor with hold for
    select atdtrxnum ,
           atdtrxdat ,
           atdtrxhor ,
           atdsrvnum ,
           atdsrvano
      from datmtrxfila
     where atdtrxnum > 0 and
         ( atdtrxsit = 1 or
           atdtrxsit = 2 )
     order by atdtrxdat ,
              atdtrxhor ,
              atdtrxnum

 foreach c_cts00g00 into d_cts00g00.atdtrxnum,
                         d_cts00g00.atdtrxdat,
                         d_cts00g00.atdtrxhor,
                         d_cts00g00.atdsrvnum,
                         d_cts00g00.atdsrvano

    call cts00g00_espera(d_cts00g00.atdtrxdat, d_cts00g00.atdtrxhor)
               returning ws.espera

    if ws.espera[3,9] > "0:10:00"  then
       call cts00g01_remove(d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano, 4)
       continue foreach
    end if

    #-----------------------------------------------------------------------
    # Monta mensagem a ser transmitida
    #-----------------------------------------------------------------------
    let ws.hora = ws.data[1,5]," ",time
    display ws.hora, " ===> Servico   : ", d_cts00g00.atdsrvnum using "&&&&&&&",
                                      "-", d_cts00g00.atdsrvano using "&&"

    if ws.privez = true  then
       call cts00g00_prepare()
    end if

    call cts00g00_laudo(d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano)
              returning str_laudo,
                        d_cts00g00.atdvclsgl,
                        d_cts00g00.atdimpcod,
                        ws.tabname, ws.sqlcode

    if ws.sqlcode <> 0  then
       let ws.hora = ws.data[1,5]," ",time
       display ws.hora, " ===> SERVICO ", d_cts00g00.atdsrvnum using "&&&&&&&",
                                     "-", d_cts00g00.atdsrvano using "&&"    ,
                        ": Erro (", ws.sqlcode using "<<<<<&",
                        ") no acesso a tabela ", ws.tabname, "!"
       continue foreach
    end if

    if d_cts00g00.atdvclsgl is null then
       let ws.hora = ws.data[1,5]," ",time
       display ws.hora, " ===> SERVICO ", d_cts00g00.atdsrvnum using "&&&&&&&",
                                     "-", d_cts00g00.atdsrvano using "&&"    ,
                        ": Sigla nao cadastrada!"
       continue foreach
    end if

    open  c_datktrximp using d_cts00g00.atdimpcod
    fetch c_datktrximp into  d_cts00g00.atdimpsit
    close c_datktrximp

    if d_cts00g00.atdimpsit <> 0  then
       let ws.hora = ws.data[1,5]," ",time
       display ws.hora, " ===> SERVICO ", d_cts00g00.atdsrvnum using "&&&&&&&",
                                     "-", d_cts00g00.atdsrvano using "&&"    ,
                        ": Impressora com situacao ", d_cts00g00.atdimpsit using "&&"
       continue foreach
    end if

    #-----------------------------------------------------------------------
    # Checa codigo de retorno do protocolo
    #-----------------------------------------------------------------------
    let ws.retflg = 9

    for x = 01 to 03 step 01

       #--------------------------------------------------------------------
       # Chamada da funcao de comunicacao ("C")
       #--------------------------------------------------------------------
       let ws.hora = ws.data[1,5]," ",time
       display ws.hora, " ===> Inicio  ", x using "&"," : ",
                         d_cts00g00.atdtrxnum using "&&&&&&&&&&"

       call guincho(d_cts00g00.atdimpcod, str_laudo) returning ws.retflg

       let ws.hora = ws.data[1,5]," ",time
       display ws.hora, " ===> Retorno ", x using "&"," : ", ws.retflg
       display ""

       #--------------------------------------------------------------------
       # Verifica se houve erro na 3a. tentativa
       #--------------------------------------------------------------------
       if x        =  03   and
          ws.retflg <> 0    then
          let ws.hora = ws.data[1,5]," ",time
         display ws.hora, " ===> SERVICO ",d_cts00g00.atdsrvnum using "&&&&&&&",
                                      "-", d_cts00g00.atdsrvano using "&&"    ,
                           ": Erro (", ws.retflg using "-&",
                           ") na 3a. tentativa de envio a impressora ", d_cts00g00.atdimpcod using "&&&&"

          #----------------------------------------------------------------
          # Problema de comunicacao - re-coloca na fila
          #----------------------------------------------------------------
          call cts00g01_remove(d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano, 2)
       end if

       #-------------------------------------------------------------------
       # Envio OK ou pager invalido - retira da fila
       #-------------------------------------------------------------------
       if ws.retflg = 0  then
          call cts00g01_remove(d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano, 0)
          call cts00g01_log(d_cts00g00.atdtrxnum, ws.retflg)
          exit for
       end if

       if ws.retflg = -7 then
          call cts00g01_remove(d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano, 3)
          call cts00g01_log(d_cts00g00.atdtrxnum, ws.retflg)
          exit for
       end if

       #--------------------------------------------------------------------
       # Grava log da transmissao
       #--------------------------------------------------------------------
       call cts00g01_log(d_cts00g00.atdtrxnum, ws.retflg)

    end for

 end foreach

end function  ###  cts00g00


#----------------------------------------------------------------------
 function cts00g00_prepare()
#----------------------------------------------------------------------

 define ws      record
    sql         char (2000),
    sqlcode     integer
 end record

 let ws.sql = "select datmservico.atdsrvnum   ,",
              "       datmservico.atdsrvano   ,",
              "       datmservico.vclcorcod   ,",
              "       datmservico.c24opemat   ,",
              "       datmservicocmp.rmcacpflg,",
              "       datmservico.srvprlflg   ,",
              "       datmservico.atdsrvorg   ,",
              "       datmservico.asitipcod   ,",
              "       datmservico.atdrsdflg   ,",
              "       datmservico.nom         ,",
              "       datmservico.vcldes      ,",
              "       datmservico.vclanomdl   ,",
              "       datmservico.vcllicnum   ,",
              "       datmservicocmp.bocflg   ,",
              "       datmservicocmp.bocnum   ,",
              "       datmservicocmp.bocemi   ,",
              "       datmservico.atddfttxt   ,",
              "       datmservicocmp.roddantxt,",
              "       datmservico.atdprscod   ,",
              "       datmservico.atdvclsgl   ,",
              "       datmservico.socvclcod   ,",
              "       datmservico.atddat      ,",
              "       datmservico.atdhor      ,",
              "       datmservico.atdhorpvt   ,",
              "       datmservico.atddatprg   ,",
              "       datmservico.atdhorprg   ,",
              "       datmservico.cnldat      ,",
              "       datmservico.atdfnlhor    ",
              "  from datmservico, outer datmservicocmp",
              " where datmservico.atdsrvnum    = ?                      and",
              "       datmservico.atdsrvano    = ?                      and",
              "       datmservicocmp.atdsrvnum = datmservico.atdsrvnum  and",
              "       datmservicocmp.atdsrvano = datmservico.atdsrvano     "

 prepare sel_datmservico from ws.sql
 declare c_datmservico cursor for sel_datmservico

 let ws.sql = "select ramcod   ,        ",
              "       succod   ,        ",
              "       aplnumdig,        ",
              "       itmnumdig         ",
              "  from datrservapol      ",
              " where atdsrvnum = ?  and",
              "       atdsrvano = ?     "

 prepare sel_datrservapol from ws.sql
 declare c_datrservapol cursor for sel_datrservapol

 let ws.sql = "select atdetpcod    ",
              "  from datmsrvacp   ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"

 prepare sel_datmsrvacp from ws.sql
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let ws.sql = "select orrdat   ,   ",
              "       orrhor   ,   ",
              "       sinntzcod,   ",
              "       socntzcod,   ",
              "       lclrsccod    ",
              "  from datmsrvre    ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?"

 prepare sel_datmsrvre   from ws.sql
 declare c_datmsrvre   cursor for sel_datmsrvre

 let ws.sql = "select srvtipabvdes",
              "  from datksrvtip  ",
              " where atdsrvorg = ?  "

 prepare sel_datksrvtip from ws.sql
 declare c_datksrvtip cursor for sel_datksrvtip

 let ws.sql = "select asitipabvdes ",
              "  from datkasitip   ",
              " where asitipcod = ?"

 prepare sel_datkasitip from ws.sql
 declare c_datkasitip cursor for sel_datkasitip

 let ws.sql = "select sinntzdes      ",
              "  from sgaknatur      ",
              " where sinramgrp = '4'",
              "   and sinntzcod = ?  "

 prepare sel_sgaknatur  from ws.sql
 declare c_sgaknatur  cursor for sel_sgaknatur

 let ws.sql = "select socntzdes      ",
              "  from datksocntz     ",
              " where socntzcod = ?  "

 prepare sel_datksocntz from ws.sql
 declare c_datksocntz cursor for sel_datksocntz

 let ws.sql = "select cpodes         ",
              "  from iddkdominio    ",
              " where cponom = ?  and",
              "       cpocod = ?     "

 prepare sel_iddkdominio from ws.sql
 declare c_iddkdominio cursor for sel_iddkdominio

 let ws.sql = "select nomgrr       ",
              "  from dpaksocor    ",
              " where pstcoddig = ?"

 prepare sel_dpaksocor   from ws.sql
 declare c_dpaksocor   cursor for sel_dpaksocor

 let ws.sql = "select c24srvdsc, c24txtseq",
              "  from datmservhist      ",
              " where atdsrvnum = ?  and",
              "       atdsrvano = ?     ",
              " order by c24txtseq      "

 prepare sel_datmservhist from ws.sql
 declare c_datmservhist cursor for sel_datmservhist

 let ws.sql = "select vstnumdig, vstfld   ,",
              "       corsus   , cornom   ,",
              "       segnom   , vclmrcnom,",
              "       vcltipnom, vclmdlnom,",
              "       vcllicnum, vclchsnum,",
              "       vclanomdl, vclanofbc ",
              "  from datmvistoria         ",
              " where atdsrvnum = ?  and   ",
              "       atdsrvano = ?        "

 prepare sel_datmvistoria from ws.sql
 declare c_datmvistoria cursor for sel_datmvistoria

#let ws.sql = "select cornom                                         ",
#             "  from gcaksusep, gcakcorr ",
#             " where gcaksusep.corsus     = ?                    and",
#             "       gcakcorr.corsuspcp   = gcaksusep.corsuspcp"

#prepare sel_gcakcorr from ws.sql
#declare c_gcakcorr cursor for sel_gcakcorr

 let ws.sql = "select atdvclsgl, atdimpcod ",
              "  from datkveiculo  ",
              " where socvclcod = ?"

 prepare sel_datkveiculo from ws.sql
 declare c_datkveiculo cursor for sel_datkveiculo

 call ctx04g00_prepare() returning ws.sqlcode

 end function  ###  cts00g00_prepare


#--------------------------------------------------------------------------#
 function cts00g00_laudo(param)
#--------------------------------------------------------------------------#

 define param         record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_cts00g00    record
    pagercode         dec (04,0)                   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    srvtipabvdes      like datksrvtip.srvtipabvdes ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    c24opemat         like datmservico.c24opemat   ,
    rmcacpdes         char (03)                    ,
    atdrsddes         char (03)                    ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (20)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    bocflg            like datmservicocmp.bocflg   ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    atddfttxt         like datmservico.atddfttxt   ,
    roddantxt         like datmservicocmp.roddantxt,
    nomgrr            like dpaksocor.nomgrr        ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,

    ntzdes            like datksocntz.socntzdes    ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,

    vstnumdig         like datmvistoria.vstnumdig  ,
    vstflddes         char (30)                    ,
    corsus            like datmvistoria.corsus     ,
    cornom            like datmvistoria.cornom     ,
    segnom            like datmvistoria.segnom     ,
    vclchsnum         like datmvistoria.vclchsnum  ,
    vclanofbc         like datmvistoria.vclanofbc
 end record

 define a_cts00g00    array[2] of record
    lgdtxt            char (65)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    endzon            like datmlcl.endzon          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod
 end record

 define ws            record
    campo             char (40)                    ,
    msgpvt            char (40)                    ,
    fim               char (01)                    ,
    cponom            like iddkdominio.cponom      ,
    lignum            like datrligsrv.lignum       ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    atdprscod         like datmservico.atdprscod   ,
    vclcorcod         like datmservico.vclcorcod   ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    c24srvdsc         like datmservhist.c24srvdsc  ,
    c24txtseq         like datmservhist.c24txtseq  ,
    vstfld            like datmvistoria.vstfld     ,
    vclmrcnom         like datmvistoria.vclmrcnom  ,
    vcltipnom         like datmvistoria.vcltipnom  ,
    vclmdlnom         like datmvistoria.vclmdlnom  ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    socntzcod         like datmsrvre.socntzcod     ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    socvclcod         like datmservico.socvclcod   ,
    srvprlflg         like datmservico.srvprlflg   ,
    atdimpcod         like datkveiculo.atdimpcod   ,
    canpgtcod         dec (1,0)                    ,
    difcanhor         datetime hour to minute      ,
    msgpgttxt         char (50)                    ,
    tabname           like systables.tabname       ,
    sqlcode           integer
 end record

 define str_laudo     char (3586)

 initialize d_cts00g00.*  to null
 initialize a_cts00g00    to null
 initialize ws.*          to null

 #-------------------------------------------------------------------------
 # Identifica fim de mensagem - caracter ASCII (ETX)
 #-------------------------------------------------------------------------
 let ws.fim = ascii(03)

 open  c_datmservico using param.atdsrvnum,
                           param.atdsrvano
 fetch c_datmservico into  d_cts00g00.atdsrvnum,
                           d_cts00g00.atdsrvano,
                           ws.vclcorcod,
                           d_cts00g00.c24opemat,
                           ws.rmcacpflg,
                           ws.srvprlflg,
                           ws.atdsrvorg,
                           ws.asitipcod,
                           ws.atdrsdflg,
                           d_cts00g00.nom,
                           d_cts00g00.vcldes,
                           d_cts00g00.vclanomdl,
                           d_cts00g00.vcllicnum,
                           d_cts00g00.bocflg,
                           d_cts00g00.bocnum,
                           d_cts00g00.bocemi,
                           d_cts00g00.atddfttxt,
                           d_cts00g00.roddantxt,
                           ws.atdprscod,
                           d_cts00g00.atdvclsgl,
                           ws.socvclcod,
                           d_cts00g00.atddat,
                           d_cts00g00.atdhor,
                           d_cts00g00.atdhorpvt,
                           d_cts00g00.atddatprg,
                           d_cts00g00.atdhorprg,
                           ws.cnldat,
                           ws.atdfnlhor

 if sqlca.sqlcode <> 0  then
    let ws.tabname = "datmservico"
    let ws.sqlcode = sqlca.sqlcode
    return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
 end if

 close c_datmservico

 call ctx04g00_local_prepare(param.atdsrvnum, param.atdsrvano, 1, false)
                   returning a_cts00g00[1].lclidttxt
                        thru a_cts00g00[1].c24lclpdrcod, ws.sqlcode

 if ws.sqlcode <> 0  then
    let ws.tabname = "datmlcl"
    return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
 end if
 
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_cts00g00[1].brrnom,
                                a_cts00g00[1].lclbrrnom)
      returning a_cts00g00[1].lclbrrnom  

 let a_cts00g00[1].lgdtxt = a_cts00g00[1].lgdtip clipped, " ",
                            a_cts00g00[1].lgdnom clipped, " ",
                            a_cts00g00[1].lgdnum using "<<<<#"

 call ctx04g00_local_prepare(param.atdsrvnum, param.atdsrvano, 2, false)
                   returning a_cts00g00[2].lclidttxt
                        thru a_cts00g00[2].c24lclpdrcod, ws.sqlcode

 if ws.sqlcode < 0  then
    let ws.tabname = "datmlcl"
    return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
 end if
 
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_cts00g00[2].brrnom,
                                a_cts00g00[2].lclbrrnom)
      returning a_cts00g00[2].lclbrrnom  

 let a_cts00g00[2].lgdtxt = a_cts00g00[2].lgdtip clipped, " ",
                            a_cts00g00[2].lgdnom clipped, " ",
                            a_cts00g00[2].lgdnum using "<<<<#"

 #---------------------------------------------------------
 # Sigla/pager do veiculo
 #---------------------------------------------------------
 if ws.socvclcod  is not null  then
    open  c_datkveiculo  using ws.socvclcod
    fetch c_datkveiculo  into  d_cts00g00.atdvclsgl,
                               ws.atdimpcod

    if sqlca.sqlcode <> 0  then
       let ws.tabname = "datkveiculo"
       let ws.sqlcode = sqlca.sqlcode
       return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
    end if

    close c_datkveiculo
 end if

 #---------------------------------------------------------
 # Apolice do servico
 #---------------------------------------------------------
 open  c_datrservapol using d_cts00g00.atdsrvnum,
                            d_cts00g00.atdsrvano
 fetch c_datrservapol into  d_cts00g00.ramcod   ,
                            d_cts00g00.succod   ,
                            d_cts00g00.aplnumdig,
                            d_cts00g00.itmnumdig

 if sqlca.sqlcode < 0  then
    let ws.tabname = "datrservapol"
    let ws.sqlcode = sqlca.sqlcode
    return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
 end if

 close c_datrservapol

 call cts09g00(d_cts00g00.ramcod,
               d_cts00g00.succod,
               d_cts00g00.aplnumdig,
               d_cts00g00.itmnumdig,
               false)
     returning d_cts00g00.dddcod,
               d_cts00g00.teltxt

 #---------------------------------------------------------
 # Descricao do tipo do servico
 #---------------------------------------------------------
 let d_cts00g00.srvtipabvdes = "NAO PREV."

 open  c_datksrvtip using ws.atdsrvorg
 fetch c_datksrvtip into  d_cts00g00.srvtipabvdes
 close c_datksrvtip

 #---------------------------------------------------------
 # Descricao do tipo de assistencia
 #---------------------------------------------------------
 let d_cts00g00.asitipabvdes = "NAO PREV."

 open  c_datkasitip using ws.asitipcod
 fetch c_datkasitip into  d_cts00g00.asitipabvdes
 close c_datkasitip

 #---------------------------------------------------------
 # Cor do veiculo
 #---------------------------------------------------------
 let ws.cponom         = "vclcorcod"
 let d_cts00g00.vclcordes = "NAO INFORMADA"

 open  c_iddkdominio using ws.cponom, ws.vclcorcod
 fetch c_iddkdominio into  d_cts00g00.vclcordes
 close c_iddkdominio

 #-----------------------------------------------------------------------
 # Formata mensagem de: Vistoria Previa
 #-----------------------------------------------------------------------
 if ws.atdsrvorg  =  10    then
    open  c_datmvistoria using d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano
    fetch c_datmvistoria into  d_cts00g00.vstnumdig, ws.vstfld           ,
                               d_cts00g00.corsus   , d_cts00g00.cornom   ,
                               d_cts00g00.segnom   , ws.vclmrcnom        ,
                               ws.vcltipnom        , ws.vclmdlnom        ,
                               d_cts00g00.vcllicnum, d_cts00g00.vclchsnum,
                               d_cts00g00.vclanomdl, d_cts00g00.vclanofbc

    if sqlca.sqlcode <> 0  then
       let ws.tabname = "datmvistoria"
       let ws.sqlcode = sqlca.sqlcode
       return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
    end if

    close c_datmvistoria

    #-------------------------------------------------------------------
    # Envia a 1a linha do historico (se houver)
    #-------------------------------------------------------------------
    initialize ws.c24srvdsc  to null

    open  c_datmservhist using d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano
    fetch c_datmservhist into  ws.c24srvdsc     , ws.c24txtseq
    close c_datmservhist

    let ws.cponom            = "vstfld"
    let d_cts00g00.vstflddes = "*** NAO PREVISTA ***"

    open  c_iddkdominio  using ws.cponom, ws.vstfld
    fetch c_iddkdominio  into  d_cts00g00.vstflddes

    if sqlca.sqlcode = 0  then
       let d_cts00g00.vstflddes = upshift(d_cts00g00.vstflddes)
    end if

    close c_iddkdominio

    let d_cts00g00.vcldes = ws.vclmrcnom clipped, " ",
                            ws.vcltipnom clipped, " ",
                            ws.vclmdlnom

    if d_cts00g00.corsus  is not null   then
      #whenever error continue
      #open  c_gcakcorr using d_cts00g00.corsus
      #fetch c_gcakcorr into  d_cts00g00.cornom
      #close c_gcakcorr
      #whenever error stop

       select cornom
         into d_cts00g00.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus     = d_cts00g00.corsus    and
              gcakcorr.corsuspcp   = gcaksusep.corsuspcp 
    end if

    let str_laudo =
        "Laudo: ",           d_cts00g00.srvtipabvdes    clipped, "  ",
        "Ordem Servico: ",   ws.atdsrvorg         using "&&"     , "/",
                             d_cts00g00.atdsrvnum using "&&&&&&&", "-",
                             d_cts00g00.atdsrvano using "&&",   "  ",
        "No. Vistoria: ",    d_cts00g00.vstnumdig using "&&&&&&&&&", "  ",

        "Solicitado: ",      d_cts00g00.atddat          clipped, " as ",
                             d_cts00g00.atdhor          clipped, "  ",#59
        "Finalidade: ",      d_cts00g00.vstflddes       clipped, "  ",
        "Viatura: ",         d_cts00g00.atdvclsgl       clipped, "  ",

        "Corretor: ",        d_cts00g00.corsus          clipped, " ",
                             d_cts00g00.cornom          clipped, "  ",

        "Segurado: ",        d_cts00g00.segnom          clipped, "  ",
        "Endereco: ",        a_cts00g00[1].lgdtxt       clipped, "  ",
        "Bairro: ",          a_cts00g00[1].lclbrrnom    clipped, "  ",
        "Cidade: ",          a_cts00g00[1].cidnom       clipped, "  ",

        "Referencia: ",      a_cts00g00[1].lclrefptotxt clipped, "  ",
        "Procurar por: ",    a_cts00g00[1].lclcttnom    clipped, "  ",

        "Veiculo: ",         d_cts00g00.vcldes          clipped, "  ",
        "Fabricacao: ",      d_cts00g00.vclanofbc       clipped, "  ",
        "Modelo: ",          d_cts00g00.vclanomdl       clipped, "  ",
        "Cor: ",             d_cts00g00.vclcordes       clipped, "  ",
        "Placa: ",           d_cts00g00.vcllicnum       clipped, "  ",
        "Chassi: ",          d_cts00g00.vclchsnum       clipped, "  ",
        "Historico: ",       ws.c24srvdsc               clipped,
                             ws.fim clipped
 else
    if d_cts00g00.atdhorpvt  is not null   then
       let ws.msgpvt = "Previsao: ", d_cts00g00.atdhorpvt
    else
       let ws.msgpvt = "Programado: ", d_cts00g00.atddatprg  clipped, " as ",
                                       d_cts00g00.atdhorprg
    end if

    case ws.atdrsdflg
       when "S"  let d_cts00g00.atdrsddes = "SIM"
       when "N"  let d_cts00g00.atdrsddes = "NAO"
    end case

    case ws.rmcacpflg
       when "S"  let d_cts00g00.rmcacpdes = "SIM"
       when "N"  let d_cts00g00.rmcacpdes = "NAO"
    end case

    open  c_dpaksocor using ws.atdprscod
    fetch c_dpaksocor into  d_cts00g00.nomgrr
    close c_dpaksocor

    #----------------------------------------------------------------------
    # Formata mensagem de: Remocao, DAF, Socorro, RPT, Replace (AUTOMOVEL)
    #----------------------------------------------------------------------
    if ws.atdsrvorg  =   4    or
       ws.atdsrvorg  =   6    or
       ws.atdsrvorg  =   1    or
       ws.atdsrvorg  =   5    or
       ws.atdsrvorg  =   7    or   
       ws.atdsrvorg  =  17    then

       if d_cts00g00.roddantxt is not null  then
          let ws.campo = ws.campo clipped, "Rodas Danificadas: ", d_cts00g00.roddantxt clipped
       end if

       if d_cts00g00.atddfttxt is not null  then
          if ws.atdsrvorg =  5   or
             ws.atdsrvorg =  7   or   
             ws.atdsrvorg = 17   then
          else
             let ws.campo = ws.campo clipped, " Problema: ", d_cts00g00.atddfttxt clipped
          end if
       end if

       initialize ws.msgpgttxt to null

       open  c_datmsrvacp using param.atdsrvnum, param.atdsrvano,
                                param.atdsrvnum, param.atdsrvano
       fetch c_datmsrvacp into  ws.atdetpcod
       close c_datmsrvacp

       #-------------------------------------------------------------------
       # Formata mensagem para servico cancelado
       #-------------------------------------------------------------------
       if ws.atdetpcod = 5   then
          call ctb00g00(param.atdsrvnum, param.atdsrvano,
                        ws.cnldat      , ws.atdfnlhor)
              returning ws.canpgtcod, ws.difcanhor

          let ws.msgpgttxt = "*** SERVICO CANCELADO ***"
          #let ws.msgpgttxt = "*** SERVICO CANCELADO SEM PAGAMENTO ***"
          #if ws.canpgtcod  =  1   then
          #   let ws.msgpgttxt = "*** SERVICO CANCELADO COM PAGAMENTO ***"
          #end if

          let str_laudo =
              "Laudo: ",         d_cts00g00.srvtipabvdes   clipped, "  ",
              "Solicitado: ",    d_cts00g00.atddat         clipped, " as ",
                                 d_cts00g00.atdhor         clipped, "  ",
                                 ws.msgpvt                 clipped, "  ",

              "Ordem Servico: ", ws.atdsrvorg         using "&&"     , "/",
                                 d_cts00g00.atdsrvnum using "&&&&&&&", "-",
                                 d_cts00g00.atdsrvano using "&&",   "  ",

              "Tipo Socorro: ",  d_cts00g00.asitipabvdes   clipped, "  ",
              "Prestador: ",     d_cts00g00.nomgrr         clipped, "  ",

              "Viatura: ",       d_cts00g00.atdvclsgl      clipped, "  ",

              "Segurado: ",      d_cts00g00.nom            clipped, "  ",
              "Apolice: ",       d_cts00g00.ramcod    using "&&&&",   "/",
                                 d_cts00g00.succod    using "<<<&&",  "/",#"&&",  "/", # Projeto Succod
                                 d_cts00g00.aplnumdig using "<<<<<<<& &", "/",
                                 d_cts00g00.itmnumdig using "<<<<<<& &",  "  ",
              "Tel.Segurado: ",  "("                                 ,
                                 d_cts00g00.dddcod         clipped,
                                 ") "                                ,
                                 d_cts00g00.teltxt         clipped, "  ",

              "Veiculo: ",       d_cts00g00.vcldes         clipped, "  ",
              "Ano: ",           d_cts00g00.vclanomdl      clipped, "  ",
              "Placa: ",         d_cts00g00.vcllicnum      clipped, "  ",
              "Cor: ",           d_cts00g00.vclcordes      clipped, "  ",
              "ATENCAO: ",       ws.msgpgttxt              clipped,
              ws.fim

       else
          if ws.srvprlflg = "S"  then
             let ws.msgpgttxt = "**SERVICO PARTICULAR: PAGTO POR CONTA DO CLIENTE**"
          end if

          let str_laudo =
              "Laudo: ",         d_cts00g00.srvtipabvdes   clipped, "  ",
              "Solicitado: ",    d_cts00g00.atddat         clipped, " as ",
                                 d_cts00g00.atdhor         clipped, "  ",
                                 ws.msgpvt                 clipped, "  ",

              "Ordem Servico: ", ws.atdsrvorg         using "&&"     , "/",
                                 d_cts00g00.atdsrvnum using "&&&&&&&", "-",
                                 d_cts00g00.atdsrvano using "&&",      "  ",

              "Tipo Socorro: ",  d_cts00g00.asitipabvdes   clipped, "  ",
              "Prestador: ",     d_cts00g00.nomgrr         clipped, "  ",

              "Viatura: ",       d_cts00g00.atdvclsgl      clipped, "  ",

              "Segurado: ",      d_cts00g00.nom             clipped, "  ",
              "Apolice: ",       d_cts00g00.ramcod    using "&&&&",  "/",
                                 d_cts00g00.succod    using "<<<&&", "/",   #"&&",         "/", Projeto Succod
                                 d_cts00g00.aplnumdig using "<<<<<<<& &", "/",
                                 d_cts00g00.itmnumdig using "<<<<<<& &",  "  ",
              "Tel.Segurado: ",  "("                                  ,
                                 d_cts00g00.dddcod          clipped,
                                 ") "                                 ,
                                 d_cts00g00.teltxt          clipped, "  ",

              "Veiculo: ",       d_cts00g00.vcldes          clipped, "  ",
              "Ano: ",           d_cts00g00.vclanomdl       clipped, "  ",
              "Placa: ",         d_cts00g00.vcllicnum       clipped, "  ",
              "Cor: ",           d_cts00g00.vclcordes       clipped, "  ",

                                 ws.campo                   clipped, "  ",

              "Local: ",         a_cts00g00[1].lclidttxt    clipped, "  ",
              "Endereco: ",      a_cts00g00[1].lgdtxt       clipped, "  ",
              "Bairro: ",        a_cts00g00[1].lclbrrnom    clipped, "  ",
              "Cidade: ",        a_cts00g00[1].cidnom       clipped, "  ",
              "UF: ",            a_cts00g00[1].ufdcod       clipped, "  ",
              "Referencia: ",    a_cts00g00[1].lclrefptotxt clipped, "  ",
              "Na residencia: ", d_cts00g00.atdrsddes       clipped, "  ",

              "Responsavel: ",   a_cts00g00[1].lclcttnom    clipped, "  ",

              "Acompanha: ",     d_cts00g00.rmcacpdes       clipped, "  ",

              "Destino: ",       a_cts00g00[2].lgdtxt       clipped, "  ",
              "Bairro: ",        a_cts00g00[2].lclbrrnom    clipped, "  ",
              "Cidade: ",        a_cts00g00[2].cidnom       clipped, "  ",
              "UF: ",            a_cts00g00[2].ufdcod       clipped,
              " ",               ws.msgpgttxt               clipped,
              ws.fim
       end if
    end if

    #----------------------------------------------------------------------
    # Formata mensagem de: Sinistro, Socorro (RAMOS ELEMENTARES)
    #----------------------------------------------------------------------
    if ws.atdsrvorg  =   9    or
       ws.atdsrvorg  =  13    then
       open  c_datmsrvre    using d_cts00g00.atdsrvnum, d_cts00g00.atdsrvano
       fetch c_datmsrvre    into  d_cts00g00.orrdat,
                                  d_cts00g00.orrhor,
                                  ws.socntzcod  ,
                                  ws.sinntzcod  ,
                                  ws.lclrsccod

       if sqlca.sqlcode <> 0  then
          let ws.tabname = "datmsrvre"
          let ws.sqlcode = sqlca.sqlcode
          return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode
       end if

       close c_datmsrvre

       if ws.socntzcod is not null  then
          open  c_datksocntz using ws.socntzcod
          fetch c_datksocntz into  d_cts00g00.ntzdes
          close c_datksocntz
       else
          open  c_sgaknatur  using ws.sinntzcod
          fetch c_sgaknatur  into  d_cts00g00.ntzdes
          close c_sgaknatur
       end if

       let str_laudo =
           "Laudo: ",           d_cts00g00.srvtipabvdes    clipped, "  ",
           "Solicitado: ",      d_cts00g00.atddat          clipped, " as ",
                                d_cts00g00.atdhor          clipped, "  ",
                                ws.msgpvt                  clipped, "  ",

           "Ordem Servico: ",   ws.atdsrvorg         using "&&"     , "/",
                                d_cts00g00.atdsrvnum using "&&&&&&&", "-",
                                d_cts00g00.atdsrvano using "&&",   "  ",

           "Tipo Socorro: ",    d_cts00g00.asitipabvdes    clipped, "  ",
           "Prestador: ",       d_cts00g00.nomgrr          clipped, "  ",

           "Viatura: ",         d_cts00g00.atdvclsgl       clipped, "  ",

           "Segurado: ",        d_cts00g00.nom             clipped, "  ",
           "Apolice: ",         d_cts00g00.ramcod    using "&&&&",  "/",
                                d_cts00g00.succod    using "<<<&&", "/", #"&&",         "/", Projeto Succod
                                d_cts00g00.aplnumdig using "<<<<<<<& &", "  ",
           "Tel.Segurado: ",    "("                                 ,
                                d_cts00g00.dddcod          clipped,
                                ") "                                ,
                                d_cts00g00.teltxt          clipped, "  ",

           "Endereco: ",        a_cts00g00[1].lgdtxt       clipped, "  ",
           "Bairro: ",          a_cts00g00[1].lclbrrnom    clipped, "  ",
           "Cidade: ",          a_cts00g00[1].cidnom       clipped, "  ",
           "UF: ",              a_cts00g00[1].ufdcod       clipped, "  ",
           "Referencia: ",      a_cts00g00[1].lclrefptotxt clipped, "  ",
           "Responsavel: ",     a_cts00g00[1].lclcttnom    clipped, "  ",
           "Data/Hora Ocorr: ", d_cts00g00.orrdat          clipped, "  ",
                                d_cts00g00.orrhor          clipped, "  ",
           "Problema: ",        d_cts00g00.atddfttxt       clipped, "  ",
           "Natureza: ",        d_cts00g00.ntzdes          clipped,
           ws.fim
    end if
 end if

 let ws.sqlcode = 0
 return str_laudo, d_cts00g00.atdvclsgl, ws.atdimpcod, ws.tabname, ws.sqlcode

end function  ###  cts00g00_laudo


#--------------------------------------------------------------------------
 function cts00g00_espera(param)
#--------------------------------------------------------------------------

 define param  record
    atdtrxdat  like datmtrxfila.atdtrxdat ,
    atdtrxhor  like datmtrxfila.atdtrxhor
 end record

 define hora   record
    atual      datetime hour to second ,
    h24        datetime hour to second ,
    espera     char (09)
 end record

 initialize hora.*  to null
 let hora.atual = time

  if param.atdtrxdat = today  then
     let hora.espera = hora.atual - param.atdtrxhor
  else
     let hora.h24    = "23:59:59"
     let hora.espera = hora.h24 - param.atdtrxhor
     let hora.h24    = "00:00:00"
     let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
  end if

  return hora.espera

end function  ###  cts00g00_espera
