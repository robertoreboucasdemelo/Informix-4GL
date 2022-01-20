##############################################################################
# Nome do Modulo: BDATR003                                         Marcelo   #
#                                                                  Gilberto  #
# Relacao de codigos especiais (formato texto)                     Jul/1996  #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 14/10/1998  Pdm #52774   Gilberto     Redefinir DATA INICIAL, utilizando   #
#                                       a funcao DIAS_UTEIS, prevendo assim  #
#                                       processamentos em feriados.          #
#----------------------------------------------------------------------------#
# 08/10/1999  PSI 9426-9   Wagner       Transformar o Relatorio de ELOGIOS   #
#                                       RDAT00302 p/ formato WORD e enviar   #
#                                       via e-mail.                          #
#----------------------------------------------------------------------------#
# 17/02/2000  PSI 10079-0  Gilberto     Substituir tipo de solicitante pelo  #
#                                       novo campo criado (c24soltipcod).    #
#----------------------------------------------------------------------------#
# 18/02/2000  MUDANCA      Wagner       Alterar envio uuencode para mailx    #
#----------------------------------------------------------------------------#
# 12/01/2001  AS 2330      Ruiz         Listar os assunto X10 por proposta   #
#----------------------------------------------------------------------------#
# 02/08/2001  Patricia-sac Ruiz         Tratar ligacao sem docto.            #
#----------------------------------------------------------------------------#
# 06/12/2001  Patricia-sac Ruiz         Listar as reclamacoes com "X",       #
#                                       exceto X11(investigacao), sem docto. #
#----------------------------------------------------------------------------#
# 22/04/2003  FERNANDO - FSW            RESOLUCAO 86                         #
#............................................................................#
#                                                                            #
#                    * * * Alteracoes * * *                                  #
#                                                                            #
# Data        Autor Fabrica    Origem    Alteracao                           #
# ----------  --------------   --------- ------------------------------------#
# 10/09/2005  Julianna, Meta   Melhorias Melhorias de performance            #
#----------------------------------------------------------------------------#
# 26/09/2005  Alberto Rodrigues          PSI202720 Saude + casa              #
#----------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650   Nao utilizar a 1 posicao do assunto  #
#                                       como sendo o agrupamento, buscar cod #
#                                       agrupamento.                         #
#----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"
globals
   define g_ismqconn smallint
end globals

 define ws_traco      char (140)
 define ws_data       char (10)
 define ws_qtdfora    dec  (05,0)

 define m_resultado smallint
       ,m_mensagem  char(60)
       ,m_grupo     like gtakram.ramgrpcod

 define l_retorno   smallint
 main
   let l_retorno = 0
    # -> CRIA O ARQUIVO DE LOG DO PROGRAMA
    call bdatr003_cria_log()

    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    call bdatr003()
       returning l_retorno
 end main

#---------------------------------------------------------------
 function bdatr003()
#---------------------------------------------------------------

  define r_gcakfilial    record
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
        ,status          smallint
  end record

 define d_bdatr003    record
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    dddcod            like gsakend.dddcod       ,
    teltxt            like gsakend.teltxt       ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    cvnnom            char (20)                 ,
    succod            like datrligapol.succod   ,
    ramcod            like datrligapol.ramcod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    viginc            like abamapol.viginc      ,
    vigfnl            like abamapol.vigfnl      ,
    cbtcod            like abbmcasco.cbtcod     ,
    sitdes            char (10)                 ,
    cornom            like gcakcorr.cornom      ,
    corsus            like gcaksusep.corsus     ,
    corddd            like gcakfilial.dddcod    ,
    cortel            like gcakfilial.teltxt    ,
    vcldes            like datmservico.vcldes   ,
    vclanofbc         like abbmveic.vclanofbc   ,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    vcllicnum         like abbmveic.vcllicnum   ,
    prporgpcp         like datrligprp.prporg    ,
    prpnumpcp         like datrligprp.prpnumdig ,
    crtnum            like datrligsau.crtnum       ## psi202720
 end record

 define ws            record
    fimflg            smallint                  ,
    auxdat            date                      ,
    incdat            date                      ,
    fnldat            date                      ,
    relcod            smallint                  ,
    segnumdig         like gsakseg.segnumdig    ,
    vclcoddig         like abbmveic.vclcoddig   ,
    vclmrccod         like agbkveic.vclmrccod   ,
    vcltipcod         like agbkveic.vcltipcod   ,
    vclmdlnom         like agbkveic.vclmdlnom   ,
    vclmrcnom         like agbkmarca.vclmrcnom  ,
    vcltipnom         like agbktip.vcltipnom    ,
    c24funmat         like datmligacao.c24funmat,
    c24soltipcod      like datmligacao.c24soltipcod,
    ligcvntip         like datmligacao.ligcvntip,
    itmsttatu         like abbmitem.itmsttatu   ,
    aplstt            like rsdmdocto.edsstt     ,
    edsnumdig         like rsdmdocto.edsnumdig  ,
    edsstt            like rsdmdocto.edsstt     ,
    edstip            like rsdmdocto.edstip     ,
    sgrorg            like rsdmdocto.sgrorg     ,
    sgrnumdig         like rsdmdocto.sgrnumdig  ,
    prporg            like rsdmdocto.prporg     ,
    prpnumdig         like rsdmdocto.prpnumdig  ,
    viginc            like abamapol.viginc      ,
    vigfnl            like abamapol.vigfnl      ,
    apledsnum         smallint                  ,
    dirfisnom         like ibpkdirlog.dirfisnom ,
    patharq01         char (60)                 ,
    patharqtmp        char (60)                 ,
    autore            char (04)                 ,
    c24astagp         like datkassunto.c24astagp    ##psi230650
 end record

## psi202720
  define lr_dados     record
         bnfnum       like datksegsau.bnfnum,
         crtsaunum    like datksegsau.crtsaunum,
         succod       like datksegsau.succod,
         ramcod       like datksegsau.ramcod,
         aplnumdig    like datksegsau.aplnumdig,
         crtstt       like datksegsau.crtstt,
         plncod       like datksegsau.plncod,
         segnom       like datksegsau.segnom,
         cgccpfnum    like datksegsau.cgccpfnum,
         cgcord       like datksegsau.cgcord,
         cgccpfdig    like datksegsau.cgccpfdig,
         empnom       like datksegsau.empnom,
         corsus       like datksegsau.corsus,
         cornom       like datksegsau.cornom,
         cntanvdat    like datksegsau.cntanvdat,
         lgdtip       like datksegsau.lgdtip,
         lgdnom       like datksegsau.lgdnom,
         lgdnum       like datksegsau.lgdnum,
         lclbrrnom    like datksegsau.lclbrrnom,
         cidnom       like datksegsau.cidnom,
         ufdcod       like datksegsau.ufdcod,
         lclrefptotxt like datksegsau.lclrefptotxt,
         endzon       like datksegsau.endzon,
         lgdcep       like datksegsau.lgdcep,
         lgdcepcmp    like datksegsau.lgdcepcmp,
         dddcod       like datksegsau.dddcod,
         lcltelnum    like datksegsau.lcltelnum,
         lclcttnom    like datksegsau.lclcttnom,
         lclltt       like datksegsau.lclltt,
         lcllgt       like datksegsau.lcllgt,
         incdat       like datksegsau.incdat,
         excdat       like datksegsau.excdat
  end record
## psi202720

 define sql_comando   char (400)
 define l_msg         char (500)
 define l_retorno1    smallint


 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------

 let ws_traco  = "-------------------------------------------------------------------------------------------------------------------------------------------"
 initialize d_bdatr003.*  to null
 initialize ws.*          to null

 let ws.fimflg = false

 initialize m_resultado to null
 initialize m_mensagem  to null
 initialize m_grupo     to null

 initialize lr_dados.*  to null
 let l_msg  = null
 let l_retorno1 = 0

 #---------------------------------------------------------------
 # Preparacao dos comandos SQL
 #---------------------------------------------------------------

 let sql_comando = "select funnom from isskfunc",
                   " where funmat = ?"
 prepare sel_isskfunc from sql_comando
 declare c_isskfunc cursor for sel_isskfunc

 let sql_comando = "select viginc, vigfnl",
                   "  from abamapol      ",
                   " where succod    = ? ",
                   "   and aplnumdig = ? "
 prepare sel_abamapol from sql_comando
 declare c_abamapol cursor for sel_abamapol

 let sql_comando = "select vclmrccod, vcltipcod, vclmdlnom",
                   "  from agbkveic where vclcoddig = ?   "
 prepare sel_agbkveic from sql_comando
 declare c_agbkveic cursor for sel_agbkveic

 let sql_comando = "select vclmrcnom    ",
                   "  from agbkmarca    ",
                   " where vclmrccod = ?"
 prepare sel_agbkmarca from sql_comando
 declare c_agbkmarca cursor for sel_agbkmarca

 let sql_comando = "select vcltipnom    ",
                   "  from agbktip      ",
                   " where vclmrccod = ?",
                   "   and vcltipcod = ?"
 prepare sel_agbktip   from sql_comando
 declare c_agbktip   cursor for sel_agbktip

 let sql_comando = "select segnumdig from abbmdoc",
                   " where succod    = ?      and",
                   "       aplnumdig = ?      and",
                   "       itmnumdig = ?      and",
                   "       dctnumseq = ?         "
 prepare sel_abbmdoc   from sql_comando
 declare c_abbmdoc   cursor for sel_abbmdoc

 let sql_comando = "select segnom from gsakseg",
                   " where segnumdig = ? "
 prepare sel_gsakseg   from sql_comando
 declare c_gsakseg   cursor for sel_gsakseg

 let sql_comando = "select dddcod, teltxt ",
                   "  from gsakend        ",
                   " where segnumdig = ?  ",
                   "   and endfld    = '1'"
 prepare sel_gsakend   from sql_comando
 declare c_gsakend   cursor for sel_gsakend

 let sql_comando = "select cbtcod from abbmcasco",
                   " where succod    = ?     and",
                   "       aplnumdig = ?     and",
                   "       itmnumdig = ?     and",
                   "       dctnumseq = ?"
 prepare sel_abbmcasco from sql_comando
 declare c_abbmcasco cursor for sel_abbmcasco

 let sql_comando = "select itmsttatu         ",
                   "  from abbmitem          ",
                   " where succod    = ?  and",
                   "       aplnumdig = ?  and",
                   "       itmnumdig = ?"
 prepare sel_abbmitem  from sql_comando
 declare c_abbmitem  cursor for sel_abbmitem

 let sql_comando = "select vclcoddig, vclanofbc,",
                   "       vcllicnum, vclchsfnl ",
                   "  from abbmveic             ",
                   " where succod    = ?  and   ",
                   "       aplnumdig = ?  and   ",
                   "       itmnumdig = ?  and   ",
                   "       dctnumseq = ?        "
 prepare sel_abbmveic from sql_comando
 declare c_abbmveic cursor for sel_abbmveic

 let sql_comando = "select corsus from abamcor",
                   " where succod    = ?   and",
                   "       aplnumdig = ?   and",
                   "       corlidflg = 'S'    "
 prepare sel_abamcor   from sql_comando
 declare c_abamcor   cursor for sel_abamcor

 let sql_comando = "select sgrorg   ,        ",
                   "       sgrnumdig,        ",
                   "       rmemdlcod         ",
                   "  from rsamseguro        ",
                   " where succod    = ?  and",
                   "       ramcod    = ?  and",
                   "       aplnumdig = ?     "
 prepare sel_rsamseguro from sql_comando
 declare c_rsamseguro cursor with hold for sel_rsamseguro

 let sql_comando = "select segnumdig,           ",
                   "       edsstt   , edstip   ,",
                   "       prporg   , prpnumdig,",
                   "       viginc   , vigfnl    ",
                   "  from rsdmdocto            ",
                   " where sgrorg    = ?  and   ",
                   "       sgrnumdig = ?  and   ",
                   "       edsnumdig = ?  and   ",
                   "       prpstt   in (19,66,88)"
 prepare sel_rsdmdocto from sql_comando
 declare c_rsdmdocto cursor with hold for sel_rsdmdocto

 let sql_comando = "select sgrorg       ",
                   "  from rsdmdocto    ",
                   " where sgrorg    = ?",
                   "   and sgrnumdig = ?"
 prepare sel_rsdmdocto2 from sql_comando
 declare c_rsdmdocto2 cursor with hold for sel_rsdmdocto2

 let sql_comando = "select corsus         ",
                   "  from rsampcorre     ",
                   " where sgrorg    =  ? ",
                   "   and sgrnumdig =  ? ",
                   "   and corlidflg = 'S'"
 prepare sel_rsampcorre from sql_comando
 declare c_rsampcorre cursor with hold for sel_rsampcorre

 let sql_comando = "select gcakcorr.cornom",
                   "  from gcaksusep, gcakcorr ",
                   " where gcaksusep.corsus     = ?                    and",
                   "       gcakcorr.corsuspcp   = gcaksusep.corsuspcp "
 prepare sel_gcakcorr  from sql_comando
 declare c_gcakcorr  cursor for sel_gcakcorr

 let sql_comando = "select cpodes from datkdominio ",
                   " where cponom = 'ligcvntip'  and",
                   "       cpocod = ?"
 prepare sel_datkdominio from sql_comando
 declare c_datkdominio cursor for sel_datkdominio

 let sql_comando = "select c24soltipdes",
                   "  from datksoltip  ",
                   " where c24soltipcod = ?"
 prepare sel_datksoltip from sql_comando
 declare c_datksoltip cursor for sel_datksoltip

 let sql_comando = "select ligdat   , lighorinc,",
                   "       c24funmat, c24ligdsc ",
                   "  from datmlighist          ",
                   " where lignum = ?           "
 prepare sel_datmlighist from sql_comando
 declare c_datmlighist cursor for sel_datmlighist

 let sql_comando = "select etpnumdig,viginc,vigfnl",
                   "  from apamcapa  ",
                   " where prporgpcp = ? ",
                   "   and prpnumpcp = ? "
 prepare sel_apamcapa from sql_comando
 declare c_apamcapa cursor for sel_apamcapa

 let sql_comando = "select corsus    ",
                   "  from apamcor   ",
                   " where prporgpcp = ? ",
                   "   and prpnumpcp = ? ",
                   "   and corlidflg = 'S'"
 prepare sel_apamcor from sql_comando
 declare c_apamcor  cursor for sel_apamcor

 let sql_comando = "select vclcoddig,vclanofbc,vcllicnum,vclchsfnl",
                   "  from apbmveic  ",
                   " where prporgpcp = ? ",
                   "   and prpnumpcp = ? "
 prepare sel_apbmveic from sql_comando
 declare c_apbmveic cursor for sel_apbmveic

 let sql_comando = "select cbtcod",
                   "  from apbmcasco ",
                   " where prporgpcp = ? ",
                   "   and prpnumpcp = ? "
 prepare sel_apbmcasco from sql_comando
 declare c_apbmcasco cursor for sel_apbmcasco

 #---------------------------------------------------------------
 # Define data parametro
 #---------------------------------------------------------------
 let ws_data = arg_val(1)

 if ws_data is null       or
    ws_data =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws_data = today
    else
       let ws_data = today - 1
    end if
 else
    if ws_data > today       or
       length(ws_data) < 10  then
       let l_msg = "   *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       #exit program (1)
       call bdatr003_envia_email_erro("AVISO DE ERRO BATCH - bdatr003",l_msg)
       let l_retorno1 = 1
       return l_retorno1
    end if
 end if

 let ws.auxdat = ws_data
 let ws.fnldat = ws.auxdat

#if weekday(ws.auxdat) = 1  then
#   let ws.auxdat = ws.auxdat - 2 units day
#end if
#
#let ws.incdat = ws.auxdat - 1 units day

 call dias_uteis(ws.auxdat, -1, "", "S", "S")
     returning ws.incdat

 if ws.incdat is null  then
    let l_msg = "   *** ERRO DATA INICIAL: DATA INVALIDA! ***"
    #exit program (1)
    call bdatr003_envia_email_erro("AVISO DE ERRO BATCH - bdatr003",l_msg)
    let l_retorno1 = 1
    return l_retorno1
 end if

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "ARQUIVO")
   returning ws.dirfisnom

 let ws.patharq01  = ws.dirfisnom clipped, "/ADAT003I01"
 let ws.patharqtmp = ws.dirfisnom clipped, "/ADAT003T01"

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_bdatr003 cursor for
    select datmligacao.c24astcod,
           datmligacao.lignum   ,
           datmligacao.c24solnom,
           datmligacao.c24soltipcod,
           datmligacao.c24funmat,
           datmligacao.ligdat   ,
           datmligacao.lighorinc,
           datmligacao.ligcvntip,
           datrligapol.succod   ,
           datrligapol.ramcod   ,
           datrligapol.aplnumdig,
           datrligapol.itmnumdig,
           datrligprp.prporg    ,
           datrligprp.prpnumdig ,
           ##datrligsau.succod     ## Alberto
           ##datrligsau.ramcod     ## Alberto
           ##datrligsau.aplnumdig  ## Alberto
           datrligsau.crtnum,     ## Alberto
           ##datrligsau.bnfnum     ## Alberto
           ##datrligsau.lignum     ## Alberto
           datkassunto.c24astagp   ## psi230650
      from datmligacao, datkassunto, outer datrligapol, outer datrligprp,
           outer datrligsau
     where datmligacao.ligdat  between  ws.incdat     and
                                        ws.fnldat     and
           datkassunto.c24astagp in ("X","Z")    and          ## psi230650
           datrligapol.lignum  =  datmligacao.lignum  and
           datrligprp.lignum   =  datmligacao.lignum  and
           datrligsau.lignum   =  datmligacao.lignum  and     ## psi202720
           datmligacao.c24astcod = datkassunto.c24astcod      ## psi230650

     order by c24astcod

 start report  arq_espec  to  ws.patharq01
 start report  rep_class  to  ws.patharqtmp

 foreach c_bdatr003  into  d_bdatr003.c24astcod, d_bdatr003.lignum   ,
                           d_bdatr003.c24solnom, ws.c24soltipcod     ,
                           ws.c24funmat        , d_bdatr003.ligdat   ,
                           d_bdatr003.lighorinc, ws.ligcvntip        ,
                           d_bdatr003.succod   , d_bdatr003.ramcod   ,
                           d_bdatr003.aplnumdig, d_bdatr003.itmnumdig,
                           d_bdatr003.prporgpcp, d_bdatr003.prpnumpcp,
                           d_bdatr003.crtnum   , ws.c24astagp

    #---------------------------------------------------------------
    # Despreza reclamacoes/elogios ja' listados em relatorio
    #---------------------------------------------------------------
    #if d_bdatr003.c24astcod[1,1] = "X"  then
    if ws.c24astagp = "X"  then           ## psi230650
       if d_bdatr003.ligdat     = ws.incdat  and
          d_bdatr003.lighorinc <= "17:00"    then
          continue foreach
       end if

       if d_bdatr003.ligdat     = ws.fnldat  and
          d_bdatr003.lighorinc >= "17:00"    then
          continue foreach
       end if
    end if

    #if d_bdatr003.c24astcod[1,1] = "Z"  and
    if ws.c24astagp = "Z"  and            ## psi230650
       d_bdatr003.ligdat <> ws.fnldat   then
       continue foreach
    end if
    #---------------------------------------------------------------
    # Despreza reclamacoes com docto. Patricia(sac) 05/12/2001.
    #---------------------------------------------------------------

    if d_bdatr003.ramcod is not null and
       #d_bdatr003.c24astcod[1,1] <> "Z" and
       ws.c24astagp <> "Z" and                    ## psi230650
       d_bdatr003.c24astcod      <> "X11" then
       let ws_qtdfora = ws_qtdfora + 1
       continue foreach
    end if
    #---------------------------------------------------------------
    # Nome do Funcionario
    #---------------------------------------------------------------
    let d_bdatr003.funnom = "NAO CADASTRADO!"

    open  c_isskfunc  using  ws.c24funmat
    fetch c_isskfunc  into   d_bdatr003.funnom
    close c_isskfunc

    #---------------------------------------------------------------
    # Convenio Operacional
    #---------------------------------------------------------------
    let d_bdatr003.cvnnom = "NAO CADASTRADO!"

    open  c_datkdominio using ws.ligcvntip
    fetch c_datkdominio into  d_bdatr003.cvnnom
    close c_datkdominio

    let d_bdatr003.c24soltipdes = "** NAO CADASTRADO **"

    open  c_datksoltip  using ws.c24soltipcod
    fetch c_datksoltip  into  d_bdatr003.c24soltipdes
    close c_datksoltip

    initialize ws.autore to null
    if d_bdatr003.prpnumpcp is not null  then
       select prporgpcp
             from apamcapa
            where prporgpcp = d_bdatr003.prporgpcp
              and prpnumpcp = d_bdatr003.prpnumpcp
       if sqlca.sqlcode <> notfound then
          let ws.autore = "auto"
       else
          open c_rsdmdocto2 using d_bdatr003.prporgpcp, d_bdatr003.prpnumpcp
          fetch c_rsdmdocto2
          if sqlca.sqlcode <> notfound  then
             let ws.autore = "re"
          end if
       end if
    end if

    if ws.autore   =  "auto"  then
       #---------------------------------------------------------------
       # Vigencia inicial e final  -  proposta
       #---------------------------------------------------------------
       open c_apamcapa using d_bdatr003.prporgpcp,
                             d_bdatr003.prpnumpcp
       fetch c_apamcapa into ws.segnumdig,d_bdatr003.viginc, d_bdatr003.vigfnl
       close c_apamcapa
       #---------------------------------------------------------------
       # Descricao do veiculo  -  proposta
       #---------------------------------------------------------------
       initialize d_bdatr003.vcldes    to null
       initialize d_bdatr003.vcllicnum to null
       initialize d_bdatr003.vclchsfnl to null

       open  c_apbmveic using d_bdatr003.prporgpcp,
                              d_bdatr003.prpnumpcp
       fetch c_apbmveic into  ws.vclcoddig        , d_bdatr003.vclanofbc,
                              d_bdatr003.vcllicnum, d_bdatr003.vclchsfnl

       if sqlca.sqlcode <> notfound  then

          initialize ws.vclmdlnom to null

          open  c_agbkveic  using ws.vclcoddig
          fetch c_agbkveic  into  ws.vclmrccod, ws.vcltipcod, ws.vclmdlnom
          close c_agbkveic

          initialize ws.vclmrcnom to null

          open  c_agbkmarca  using ws.vclmrccod
          fetch c_agbkmarca  into  ws.vclmrcnom
          close c_agbkmarca

          initialize ws.vcltipnom to null

          open  c_agbktip  using ws.vclmrccod, ws.vcltipcod
          fetch c_agbktip  into  ws.vcltipnom
          close c_agbktip

          let d_bdatr003.vcldes = ws.vclmrcnom clipped , " ",
                                  ws.vcltipnom clipped , " ",
                                  ws.vclmdlnom clipped
       end if
       close c_apbmveic
       #---------------------------------------------------------------
       # Cobertura   -  proposta
       #---------------------------------------------------------------
       open  c_apbmcasco using d_bdatr003.prporgpcp,
                               d_bdatr003.prpnumpcp
       fetch c_apbmcasco into  d_bdatr003.cbtcod
       close c_apbmcasco


       open c_apamcor using d_bdatr003.prporgpcp,
                            d_bdatr003.prpnumpcp
       fetch c_apamcor into d_bdatr003.corsus
       close c_apamcor
       let d_bdatr003.sitdes = "ATIVA"  # qdo proposta sempre ativa
    end if

    #---------------------------------------------------------------
    # Ultima situacao da apolice
    #---------------------------------------------------------------
    # psi202720 - saude+casa
    call cty10g00_grupo_ramo(1
                            ,d_bdatr003.ramcod)
         returning m_resultado, m_mensagem, m_grupo

    if m_grupo = 1 then
       call f_funapol_ultima_situacao
            (d_bdatr003.succod, d_bdatr003.aplnumdig, d_bdatr003.itmnumdig)
            returning  g_funapol.*

       #---------------------------------------------------------------
       # Vigencia inicial e final
       #---------------------------------------------------------------
       open  c_abamapol  using d_bdatr003.succod, d_bdatr003.aplnumdig
       fetch c_abamapol  into  d_bdatr003.viginc, d_bdatr003.vigfnl
       close c_abamapol

       #---------------------------------------------------------------
       # Descricao do veiculo
       #---------------------------------------------------------------
       initialize d_bdatr003.vcldes    to null
       initialize d_bdatr003.vcllicnum to null
       initialize d_bdatr003.vclchsfnl to null

       open  c_abbmveic using d_bdatr003.succod,
                              d_bdatr003.aplnumdig,
                              d_bdatr003.itmnumdig,
                              g_funapol.vclsitatu
       fetch c_abbmveic into  ws.vclcoddig        , d_bdatr003.vclanofbc,
                              d_bdatr003.vcllicnum, d_bdatr003.vclchsfnl

       if sqlca.sqlcode <> notfound  then

          initialize ws.vclmdlnom to null

          open  c_agbkveic  using ws.vclcoddig
          fetch c_agbkveic  into  ws.vclmrccod, ws.vcltipcod, ws.vclmdlnom
          close c_agbkveic

          initialize ws.vclmrcnom to null

          open  c_agbkmarca  using ws.vclmrccod
          fetch c_agbkmarca  into  ws.vclmrcnom
          close c_agbkmarca

          initialize ws.vcltipnom to null

          open  c_agbktip  using ws.vclmrccod, ws.vcltipcod
          fetch c_agbktip  into  ws.vcltipnom
          close c_agbktip

          let d_bdatr003.vcldes = ws.vclmrcnom clipped , " ",
                                  ws.vcltipnom clipped , " ",
                                  ws.vclmdlnom clipped
       end if

       close c_abbmveic

       open  c_abbmdoc  using d_bdatr003.succod   ,
                              d_bdatr003.aplnumdig,
                              d_bdatr003.itmnumdig,
                              g_funapol.dctnumseq
       fetch c_abbmdoc  into  ws.segnumdig
       close c_abbmdoc

       #---------------------------------------------------------------
       # Cobertura
       #---------------------------------------------------------------
       open  c_abbmcasco using d_bdatr003.succod   ,
                               d_bdatr003.aplnumdig,
                               d_bdatr003.itmnumdig,
                               g_funapol.autsitatu
       fetch c_abbmcasco into  d_bdatr003.cbtcod
       close c_abbmcasco

       #---------------------------------------------------------------
       # Situacao do item
       #---------------------------------------------------------------
       open  c_abbmitem  using d_bdatr003.succod   ,
                               d_bdatr003.aplnumdig,
                               d_bdatr003.itmnumdig
       fetch c_abbmitem  into  ws.itmsttatu
       close c_abbmitem

       if ws.itmsttatu = "A"  then
          let d_bdatr003.sitdes = "ATIVA"
       else
          if ws.itmsttatu = "C"  then
             let d_bdatr003.sitdes = "CANCELADA"
          else
             let d_bdatr003.sitdes = "N/PREVISTO"
          end if
       end if

       if d_bdatr003.vigfnl < today  then
          let d_bdatr003.sitdes = "VENCIDA"
       end if

       open  c_abamcor using d_bdatr003.succod, d_bdatr003.aplnumdig
       fetch c_abamcor into  d_bdatr003.corsus
       close c_abamcor
    end if

    ## PSI202720 Saude + casa
    if m_grupo <> 1   then
       if m_grupo = 5 then
          call cta01m15_sel_datksegsau(1,
                                       d_bdatr003.crtnum , ##
                                       "","","")
          returning m_resultado,
                    m_mensagem,
                    lr_dados.*
          ## status = crtstt = A ativo, C cancelado, R remido
          if lr_dados.crtstt = "A" then
             let d_bdatr003.sitdes = "ATIVO"
          else
             if lr_dados.crtstt = "C" then
                let d_bdatr003.sitdes = "CANCELADO"
             else
                let d_bdatr003.sitdes = "REMIDO"
             end if
          end if
          let d_bdatr003.succod     = lr_dados.succod
          let d_bdatr003.ramcod     = lr_dados.ramcod
          let d_bdatr003.aplnumdig  = lr_dados.aplnumdig

          let d_bdatr003.corsus     = lr_dados.corsus
          let d_bdatr003.cornom     = lr_dados.cornom

          #---> Utilizacao da nova funcao de comissoes p/ enderecamento
          initialize r_gcakfilial.* to null
          call fgckc811(d_bdatr003.corsus)
               returning r_gcakfilial.*
          let d_bdatr003.corddd = r_gcakfilial.dddcod
          let d_bdatr003.cortel = r_gcakfilial.teltxt

          let d_bdatr003.segnom     = lr_dados.segnom
          let d_bdatr003.dddcod     = lr_dados.dddcod
          let d_bdatr003.teltxt     = lr_dados.lcltelnum


       else
          if ws.autore      =  "re" then
             open  c_rsamseguro using d_bdatr003.succod   ,
                                      d_bdatr003.ramcod   ,
                                      d_bdatr003.aplnumdig
             fetch c_rsamseguro into  ws.sgrorg   ,
                                      ws.sgrnumdig
             close c_rsamseguro
             if ws.autore  = "re"  then
                let ws.sgrorg    = d_bdatr003.prporgpcp
                let ws.sgrnumdig = d_bdatr003.prpnumpcp
             end if
             let ws.apledsnum = 0

             open  c_rsdmdocto  using ws.sgrorg   ,
                                      ws.sgrnumdig,
                                      ws.apledsnum
             fetch c_rsdmdocto  into  ws.segnumdig           ,
                                      ws.aplstt, ws.edstip   ,
                                      ws.prporg, ws.prpnumdig,
                                      d_bdatr003.viginc      ,
                                      d_bdatr003.vigfnl
             close c_rsdmdocto

             if ws.edsstt  =  "A"   then
                let d_bdatr003.sitdes = "ATIVA"
             else
                if ws.edstip = 40 or ws.edstip = 41 then
                   let d_bdatr003.sitdes = "ATIVA"
                else
                   let d_bdatr003.sitdes = "CANCELADA"
                end if
             end if

             open  c_rsdmdocto  using ws.sgrorg   ,
                                      ws.sgrnumdig,
                                      ws.edsnumdig
             fetch c_rsdmdocto  into  ws.segnumdig   ,
                                      ws.edsstt, ws.edstip   ,
                                      ws.prporg, ws.prpnumdig,
                                      ws.viginc, ws.vigfnl
             close c_rsdmdocto

             open  c_rsampcorre using ws.sgrorg   ,
                                      ws.sgrnumdig
             fetch c_rsampcorre into  d_bdatr003.corsus
             close c_rsampcorre
          end if

          #---------------------------------------------------------------
          # Dados do Segurado
          #---------------------------------------------------------------
          initialize d_bdatr003.segnom to null
          if ws.segnumdig is not null  then
             open  c_gsakseg  using  ws.segnumdig
             fetch c_gsakseg  into   d_bdatr003.segnom
             close c_gsakseg

             open  c_gsakend  using  ws.segnumdig
             fetch c_gsakend  into   d_bdatr003.dddcod, d_bdatr003.teltxt
             close c_gsakend
          end if

          #---------------------------------------------------------------
          # Dados do corretor
          #---------------------------------------------------------------
          if d_bdatr003.corsus is not null  then
             initialize d_bdatr003.cornom to null
             initialize d_bdatr003.corddd to null
             initialize d_bdatr003.cortel to null

             open  c_gcakcorr  using  d_bdatr003.corsus
             fetch c_gcakcorr  into   d_bdatr003.cornom
             close c_gcakcorr

             #---> Utilizacao da nova funcao de comissoes p/ enderecamento
             initialize r_gcakfilial.* to null
             call fgckc811(d_bdatr003.corsus)
                  returning r_gcakfilial.*
             let d_bdatr003.corddd = r_gcakfilial.dddcod
             let d_bdatr003.cortel = r_gcakfilial.teltxt
             #------------------------------------------------------------

          end if
       end if
    end if
    if m_grupo = 1 then
       output to report arq_espec(d_bdatr003.*)
    end if

    #---------------------------------------------------------------
    # Identifica destinatario do relatorio
    #---------------------------------------------------------------
    if d_bdatr003.c24astcod  =  "X11"   then
       let ws.relcod = 3                         #--> Investigacao
    else
       #if d_bdatr003.c24astcod[1,1] = "Z"   then
       if ws.c24astagp = "Z"   then              ## psi230650
          let ws.relcod = 2                      #--> Central 24 hs
       else
          let ws.relcod = 1                      #--> S.A.C.
       end if
    end if

    output to report rep_class(ws.relcod, d_bdatr003.*)

    initialize d_bdatr003.*  to null
    initialize ws.segnumdig  to null   # para ligacao sem docto.
 end foreach

 finish report  arq_espec
 finish report  rep_class

 return l_retorno1
end function  ###  bdatr003


#---------------------------------------------------------------------------
 report arq_espec(r_bdatr003)
#---------------------------------------------------------------------------

 define r_bdatr003    record
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    dddcod            like gsakend.dddcod       ,
    teltxt            like gsakend.teltxt       ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    cvnnom            char (20)                 ,
    succod            like datrligapol.succod   ,
    ramcod            like datrligapol.ramcod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    viginc            like abamapol.viginc      ,
    vigfnl            like abamapol.vigfnl      ,
    cbtcod            like abbmcasco.cbtcod     ,
    sitdes            char (10)                 ,
    cornom            like gcakcorr.cornom      ,
    corsus            like datmservico.corsus   ,
    corddd            like gcakfilial.dddcod    ,
    cortel            like gcakfilial.teltxt    ,
    vcldes            like datmservico.vcldes   ,
    vclanofbc         like abbmveic.vclanofbc   ,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    vcllicnum         like abbmveic.vcllicnum   ,
    prporgpcp         like datrligprp.prporg    ,
    prpnumpcp         like datrligprp.prpnumdig ,
    crtnum            like datrligsau.crtnum       ## psi202720
 end record

 define h_bdatr003    record
    c24txtseq         like datmlighist.c24txtseq,
    c24ligdsc         like datmlighist.c24ligdsc,
    c24funmat         like datmlighist.c24funmat,
    ligdat            like datmlighist.ligdat   ,
    lighorinc         like datmlighist.lighorinc
 end record

 define ws            record
    funnom            like isskfunc.funnom      ,
    lintxt            like datmlighist.c24ligdsc,
    ligdat            like datmlighist.ligdat   ,
    lighor            like datmlighist.lighorinc
 end record

   output
      left   margin  00
      right  margin  00
      top    margin  00
      bottom margin  00
      page   length  99

   order by  r_bdatr003.segnom

   format

      on every row
           print column 001, '"', r_bdatr003.c24astcod, '",'                  ,
                             '"', r_bdatr003.segnom   , '",'                  ,
                                  r_bdatr003.succod    using "&&"        ,',' ,
                                  r_bdatr003.aplnumdig using "&&&&&&&& &",',' ,
                                  r_bdatr003.itmnumdig using "&&&&&& &"  ,',' ,
                             '"', r_bdatr003.ligdat   , '",'                  ,
                             '"', r_bdatr003.lighorinc, '",'                  ,
                             '"', r_bdatr003.c24solnom, '",'                  ,
                             '"', r_bdatr003.c24soltipdes, '",'               ,
                             '"', r_bdatr003.funnom   , '",'                  ,
                             '"', r_bdatr003.viginc   , '",'                  ,
                             '"', r_bdatr003.vigfnl   , '",'                  ,
                             '"', r_bdatr003.cvnnom   , '",'                  ,
                                  r_bdatr003.cbtcod   ,                   ',' ,
                             '"', r_bdatr003.sitdes   , '",'                  ,
                             '"', r_bdatr003.corsus   , '",'                  ,
                             '"', r_bdatr003.cornom   , '",'                  ,
                             '"', r_bdatr003.dddcod   , '",'                  ,
                             '"', r_bdatr003.teltxt   , '",'                  ,
                             '"', r_bdatr003.vcldes   , '",'                  ,
                             '"', r_bdatr003.vclanofbc, '",'                  ,
                             '"', r_bdatr003.vcllicnum, '",'                  ,
                             '"', r_bdatr003.vclchsfnl, '",'                  ,
                             '"', r_bdatr003.prporgpcp, '",'                  ,
                             '"', r_bdatr003.prpnumpcp, '",'                  ;

         print '"';
         open    c_datmlighist using r_bdatr003.lignum
         foreach c_datmlighist into  h_bdatr003.ligdat   , h_bdatr003.lighorinc,
                                     h_bdatr003.c24funmat, h_bdatr003.c24ligdsc

              if ws.ligdat <> h_bdatr003.ligdat     or
                 ws.lighor <> h_bdatr003.lighorinc  then
                 open  c_isskfunc  using h_bdatr003.c24funmat
                 fetch c_isskfunc  into  ws.funnom
                 close c_isskfunc

                 let ws.lintxt = "EM: "   , h_bdatr003.ligdat    clipped,
                                 "  AS: " , h_bdatr003.lighorinc clipped,
                                 "  POR: ", ws.funnom            clipped
                 let ws.ligdat = h_bdatr003.ligdat
                 let ws.lighor = h_bdatr003.lighorinc
                 print ws.lintxt ;
              end if
              print h_bdatr003.c24ligdsc clipped, " " ;

           end foreach
           print '"'

end report  ###  arq_espec

#---------------------------------------------------------------------------
 report rep_class(r_bdatr003)
#---------------------------------------------------------------------------

 define r_bdatr003    record
    relcod            smallint                  ,
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    dddcod            like gsakend.dddcod       ,
    teltxt            like gsakend.teltxt       ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    cvnnom            char (20)                 ,
    succod            like datrligapol.succod   ,
    ramcod            like datrligapol.ramcod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    viginc            like abamapol.viginc      ,
    vigfnl            like abamapol.vigfnl      ,
    cbtcod            like abbmcasco.cbtcod     ,
    sitdes            char (10)                 ,
    cornom            like gcakcorr.cornom      ,
    corsus            like datmservico.corsus   ,
    corddd            like gcakfilial.dddcod    ,
    cortel            like gcakfilial.teltxt    ,
    vcldes            like datmservico.vcldes   ,
    vclanofbc         like abbmveic.vclanofbc   ,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    vcllicnum         like abbmveic.vcllicnum   ,
    prporgpcp         like datrligprp.prporg    ,
    prpnumpcp         like datrligprp.prpnumdig ,
    crtnum            like datrligsau.crtnum       ## psi202720
 end record

 define ws            record
    dirfisnom         like ibpkdirlog.dirfisnom ,
    pathrel01         char (60)                 ,
    pathrel02         char (60)                 ,
    pathrel03         char (60)                 ,
    comando           char (400)
 end record

 define l_assunto     char(300),
        l_erro_envio  smallint

   output
      left   margin  000
      right  margin  000
      top    margin  000
      bottom margin  000
      page   length  003

   order by  r_bdatr003.relcod,
             r_bdatr003.ligdat,
             r_bdatr003.segnom

   format
       first page header

          #---------------------------------------------------------------
          # Define diretorios para relatorios e arquivos
          #---------------------------------------------------------------
          call f_path("DAT", "RELATO")
               returning ws.dirfisnom

          let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT00301.rtf"
          let ws.pathrel02 = ws.dirfisnom clipped, "/RDAT00302.rtf"
          let ws.pathrel03 = ws.dirfisnom clipped, "/RDAT00303.rtf"

       before group of  r_bdatr003.relcod

          case  r_bdatr003.relcod
                when  1   start report rep_espec      to  ws.pathrel01
                when  2   start report rep_especword  to  ws.pathrel02
                when  3   start report rep_espec      to  ws.pathrel03
          end case

       after group of  r_bdatr003.relcod
          if r_bdatr003.relcod = 2   then
             finish report rep_especword

             let l_assunto    = null
             let l_erro_envio = null

             let l_assunto    = "Elogios de ", ws_data, " DAT00302 "
             let l_erro_envio = ctx22g00_envia_email("BDATR003",
                                                     l_assunto,
                                                     ws.pathrel02)
             if l_erro_envio <> 0 then
                if l_erro_envio <> 99 then
                   display "Erro ao enviar email(ctx22g00) - ", ws.pathrel02
                else
                   display "Nao existe email cadastrado para o modulo - BDATR003"
                end if
             end if

          else
             finish report rep_espec
          end if

       on every row
          if r_bdatr003.relcod = 2   then
             output to report rep_especword(r_bdatr003.*)
          else
             output to report rep_espec(r_bdatr003.*)
          end if


end report  ###  rep_class

#---------------------------------------------------------------------------
 report rep_espec(r_bdatr003)
#---------------------------------------------------------------------------

 define r_bdatr003    record
    relcod            smallint                  ,
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    dddcod            like gsakend.dddcod       ,
    teltxt            like gsakend.teltxt       ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    cvnnom            char (20)                 ,
    succod            like datrligapol.succod   ,
    ramcod            like datrligapol.ramcod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    viginc            like abamapol.viginc      ,
    vigfnl            like abamapol.vigfnl      ,
    cbtcod            like abbmcasco.cbtcod     ,
    sitdes            char (10)                 ,
    cornom            like gcakcorr.cornom      ,
    corsus            like datmservico.corsus   ,
    corddd            like gcakfilial.dddcod    ,
    cortel            like gcakfilial.teltxt    ,
    vcldes            like datmservico.vcldes   ,
    vclanofbc         like abbmveic.vclanofbc   ,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    vcllicnum         like abbmveic.vcllicnum   ,
    prporgpcp         like datrligprp.prporg    ,
    prpnumpcp         like datrligprp.prpnumdig ,
    crtnum            like datrligsau.crtnum       ## psi202720
 end record

 define h_bdatr003    record
    c24txtseq         like datmlighist.c24txtseq,
    c24ligdsc         like datmlighist.c24ligdsc,
    c24funmat         like datmlighist.c24funmat,
    ligdat            like datmlighist.ligdat   ,
    lighorinc         like datmlighist.lighorinc
 end record

 define ws            record
    funnom            like isskfunc.funnom      ,
    doctxt            char (33)                 ,
    lintxt            like datmlighist.c24ligdsc,
    ligdat            like datmlighist.ligdat   ,
    lighor            like datmlighist.lighorinc,
    jobname           char (60)                 ,
    rotulo            char (10)                 ,
    relsgl            char (10)                 ,
    cabrel            char (20)                 ,
    cctcod            like igbrrelcct.cctcod    ,
    relviaqtd         like igbrrelcct.relviaqtd
 end record

 define l_doctxt_sau  char(33)

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066


   format
      page header
           if pageno  =  1   then
              case r_bdatr003.relcod
                when 1
                     let ws.jobname = "    JOBNAME= S.A.C. - ASSUNTOS ESPECIAIS"
                     let ws.rotulo  = "RDAT003-01"
                     let ws.relsgl  = "RDAT00301"
                     let ws.cabrel  = "S.A.C."
                when 3
                     let ws.jobname = "    JOBNAME= REPLACE - ASSUNTOS ESPECIAIS"
                     let ws.rotulo  = "RDAT003-03"
                     let ws.relsgl  = "RDAT00303"
                     let ws.cabrel  = "INVESTIGACAO"
              end case

              #---------------------------------------------------------------
              # Define numero de vias e account dos relatorios
              #---------------------------------------------------------------
              call fgerc010(ws.relsgl)  returning  ws.cctcod,
                                                   ws.relviaqtd

              print "OUTPUT JOBNAME=", ws.relsgl[2,9], " FORMNAME=BRANCO"
              print "HEADER PAGE"

              print ws.jobname
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws.relviaqtd using "&&", ", DEPT='", ws.cctcod using "&&&", "', END;"
              print ascii(12)

           else
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, END ;"
             print ascii(12)
           end if

           print column 100, ws.rotulo,
                 column 113, "PAGINA : ", pageno using "##,###,##&"
           print column 113, "DATA   : ", today
           print column 042, "INCIDENCIA DE ASSUNTOS ESPECIAIS - ", ws.cabrel,
                 column 113, "HORA   :   ", time
           skip 2 lines

           print column 001, "ASS."       ,
                 column 006, "SEGURADO"   ,
                 column 043, "DATA"       ,
                 column 054, "HORA"       ,
                 column 061, "ATENDENTE"  ,
                 column 083, "SOLICITANTE",
                 column 100, "TIPO"       ,
                 column 111, "DOCUMENTO"

           print column 001, ws_traco
           skip 1 line

      on every row
         if r_bdatr003.ramcod    is null     then
            if r_bdatr003.prpnumpcp is not null then
               let ws.doctxt = "PROPOSTA - ",
                               r_bdatr003.prporgpcp  using "&&", "/",
                               r_bdatr003.prpnumpcp  using "<<<<<<<&"
            else
               let ws.doctxt = "Nao existe doc. vinculado"
            end if
         else
           ## Se for Saude
           if r_bdatr003.crtnum is not null then
              let l_doctxt_sau = "Cartao Saude:-"
              let ws.doctxt = cts20g16_formata_cartao(r_bdatr003.crtnum)
              let  ws.doctxt = l_doctxt_sau clipped,  ws.doctxt
           else
              let ws.doctxt = r_bdatr003.succod     using "&&", "/",
                              r_bdatr003.ramcod     using "&&&&", "/",
                              r_bdatr003.aplnumdig  using "<<<<<<<& &", "/",
                              r_bdatr003.itmnumdig  using "<<<<<<& &"
           end if
         end if

         print column 001, r_bdatr003.c24astcod      ,
               column 006, r_bdatr003.segnom         ,
               column 043, r_bdatr003.ligdat         ,
               column 054, r_bdatr003.lighorinc      ,
               column 061, upshift(r_bdatr003.funnom),
               column 083, r_bdatr003.c24solnom      ,
               column 100, r_bdatr003.c24soltipdes   ,
               column 111, ws.doctxt

         open    c_datmlighist using r_bdatr003.lignum
         foreach c_datmlighist into  h_bdatr003.ligdat   , h_bdatr003.lighorinc,
                                     h_bdatr003.c24funmat, h_bdatr003.c24ligdsc

            if ws.ligdat <> h_bdatr003.ligdat     or
               ws.lighor <> h_bdatr003.lighorinc  then
               open  c_isskfunc  using h_bdatr003.c24funmat
               fetch c_isskfunc  into  ws.funnom
               close c_isskfunc

               let ws.lintxt = "EM: "   , h_bdatr003.ligdat    clipped,
                               "  AS: " , h_bdatr003.lighorinc clipped,
                               "  POR: ", upshift(ws.funnom)   clipped
               let ws.ligdat = h_bdatr003.ligdat
               let ws.lighor = h_bdatr003.lighorinc
               skip 1 line

               print column 044,  ws.lintxt
            end if

            print column 044, h_bdatr003.c24ligdsc

      end foreach
      skip 2 lines

      on last row
           print "$FIMREL$"

end report  ###  rep_espec

#---------------------------------------------------------------------------
 report rep_especword(r_bdatr003)
#---------------------------------------------------------------------------

 define r_bdatr003    record
    relcod            smallint                  ,
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    dddcod            like gsakend.dddcod       ,
    teltxt            like gsakend.teltxt       ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    cvnnom            char (20)                 ,
    succod            like datrligapol.succod   ,
    ramcod            like datrligapol.ramcod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    viginc            like abamapol.viginc      ,
    vigfnl            like abamapol.vigfnl      ,
    cbtcod            like abbmcasco.cbtcod     ,
    sitdes            char (10)                 ,
    cornom            like gcakcorr.cornom      ,
    corsus            like datmservico.corsus   ,
    corddd            like gcakfilial.dddcod    ,
    cortel            like gcakfilial.teltxt    ,
    vcldes            like datmservico.vcldes   ,
    vclanofbc         like abbmveic.vclanofbc   ,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    vcllicnum         like abbmveic.vcllicnum   ,
    prporgpcp         like datrligprp.prporg    ,
    prpnumpcp         like datrligprp.prpnumdig ,
    crtnum            like datrligsau.crtnum       ## psi202720
 end record

 define h_bdatr003    record
    c24txtseq         like datmlighist.c24txtseq,
    c24ligdsc         like datmlighist.c24ligdsc,
    c24funmat         like datmlighist.c24funmat,
    ligdat            like datmlighist.ligdat   ,
    lighorinc         like datmlighist.lighorinc
 end record

 define ws            record
    funnom            like isskfunc.funnom      ,
    doctxt            char (33)                 ,
    lintxt            like datmlighist.c24ligdsc,
    ligdat            like datmlighist.ligdat   ,
    lighor            like datmlighist.lighorinc,
    jobname           char (60)                 ,
    rotulo            char (10)                 ,
    relsgl            char (10)                 ,
    cabrel            char (20)                 ,
    cctcod            like igbrrelcct.cctcod    ,
    relviaqtd         like igbrrelcct.relviaqtd
 end record


   output
      left   margin  000
      top    margin  000
      bottom margin  000


   format
      first page header

           print column 072, "DAT003-02"
           print column 062, "DATA   : ", today
           print column 062, "HORA   :   ", time
           print column 005, "INCIDENCIA DE ASSUNTOS ESPECIAIS - CENTRAL 24 HORAS DE ",ws_data
           skip 1 lines
           print column 001, ws_traco[1,80]
           skip 1 line



      on every row
         if r_bdatr003.ramcod    is null     then
            if r_bdatr003.prpnumpcp is not null then
               let ws.doctxt = "PROPOSTA - ",
                               r_bdatr003.prporgpcp  using "&&", "/",
                               r_bdatr003.prpnumpcp  using "<<<<<<<&"
            else
               let ws.doctxt = "Nao existe doc. vinculado"
            end if
         else
            let ws.doctxt = r_bdatr003.succod     using "&&", "/",
                            r_bdatr003.ramcod     using "&&&&", "/",
                            r_bdatr003.aplnumdig  using "<<<<<<<& &", "/",
                            r_bdatr003.itmnumdig  using "<<<<<<& &"
         end if
         print column 001, "ASSUNTO....: ", r_bdatr003.c24astcod
         print column 001, "SEGURADO...: ", r_bdatr003.segnom
         print column 001, "DATA/HORA..: ", r_bdatr003.ligdat, " / ",
                                            r_bdatr003.lighorinc
         print column 001, "ATENDENTE..: ", upshift(r_bdatr003.funnom)
         print column 001, "SOLICITANTE: ", r_bdatr003.c24solnom
         print column 001, "TIPO.......: ", r_bdatr003.c24soltipdes
         print column 001, "DOCUMENTO..: ", ws.doctxt

         open    c_datmlighist using r_bdatr003.lignum
         foreach c_datmlighist into  h_bdatr003.ligdat   , h_bdatr003.lighorinc,
                                     h_bdatr003.c24funmat, h_bdatr003.c24ligdsc

            if ws.ligdat <> h_bdatr003.ligdat     or
               ws.lighor <> h_bdatr003.lighorinc  then
               open  c_isskfunc  using h_bdatr003.c24funmat
               fetch c_isskfunc  into  ws.funnom
               close c_isskfunc

               let ws.lintxt = "EM: "   , h_bdatr003.ligdat    clipped,
                               "  AS: " , h_bdatr003.lighorinc clipped,
                               "  POR: ", upshift(ws.funnom)   clipped
               let ws.ligdat = h_bdatr003.ligdat
               let ws.lighor = h_bdatr003.lighorinc
               skip 1 line

               print column 005,  ws.lintxt
            end if
            print column 005, h_bdatr003.c24ligdsc
      end foreach
      skip 2 lines

end report  ###  rep_especword

#--------------------------#
function bdatr003_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdatr003.log"

  call startlog(l_path)

end function
#------------------------------------------------#
function bdatr003_envia_email_erro(lr_parametro)
#------------------------------------------------#
  define lr_parametro record
         assunto      char(150),
         msg          char(400)
  end record
  define lr_mail record
          rem     char(50),
          des     char(250),
          ccp     char(250),
          cco     char(250),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
  define l_cod_erro      integer,
         l_msg_erro      char(20)
 initialize lr_mail.* to null
     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = lr_parametro.assunto
     let lr_mail.idr = "bdatr003"
     let lr_mail.tip = "text"
     let lr_mail.msg = lr_parametro.msg
        call figrc009_mail_send1(lr_mail.*)
           returning l_cod_erro, l_msg_erro
  if l_cod_erro = 0  then
    display l_msg_erro
  else
    display l_msg_erro
  end if
end function