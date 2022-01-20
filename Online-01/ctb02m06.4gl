#---------------------------------------------------------------------------#
# Nome de Modulo: CTB02M06                                         Wagner   #
#                                                                           #
# Manutencao dos itens da ordem de pagamento (carro-extra)         Out/2000 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/07/2001  PSI 13448-1  Wagner       Permitir pagamento do servico mais  #
#                                       de uma vez.                         #
#---------------------------------------------------------------------------#
# 19/11/2001  Correio URG  Wagner       Nao verificar mais diferenca entre  #
#                                       tipo de lojas para 68-Unidas.       #
#---------------------------------------------------------------------------#
# 21/08/2003  PSI 172332   Ale Souza    Critica automatica  por numero de   #
#             OSF 24740                 Nota Fiscal.                        #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Raji                             OSF : 30155            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 15/12/2003       #
#  Objetivo       : Incluir bloqueio na digitacao de servicos em analise    #
#                   pelo Porto Socorro.                                     #
#---------------------------------------------------------------------------#
# Teresinha Silva   OSF 33367 - 16/03/2004 - inclusao da case ws.avialgmtv=6#
#---------------------------------------------------------------------------#
# 12/12/2006 Priscila Staingel  PSI 205206 Validar que todos os itens da OP #
#                                          sao da mesma empresa             #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
# 11/11/2008  PSI 230700 Ligia Mattge   Inibir regra 7 dias/cls 33          #
# 27/05/2009  PSI 198404 Fabio Costa    Limitar uma nota fiscal por OP      #
# 12/08/2009  PSI 198404 Fabio Costa    Tratamento para OP de reembolso     #
# 26/04/2010  PSI 198404 Fabio Costa    Tratar empresa da OP                #
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                       de mais de duas casas decimais.     #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define d_ctb02m06  record
   socopgnum       like dbsmopg.socopgnum,
   socopgsitcod    like dbsmopg.socopgsitcod,
   socopgsitdes    char(30),
   empresa         char(5)              #PSI 205206
end record

define g_privez    smallint

define w_lcvvcldiavlr  like datklocaldiaria.lcvvcldiavlr
define w_lcvvclsgrvlr  like datklocaldiaria.lcvvclsgrvlr
define w_prtsgrvlr     like datklocaldiaria.prtsgrvlr
define w_diafxovlr     like datklocaldiaria.diafxovlr
define w_prtaertaxvlr  like datkavislocal.prtaertaxvlr

#--------------------------------------------------------------------
function ctb02m06(param)
#--------------------------------------------------------------------
  define param record
         socopgnum  like dbsmopgitm.socopgnum
  end record
  
  define a_ctb02m06  array[2500] of record
     nfsnum          like dbsmopgitm.nfsnum,
     atdsrvorg       like datmservico.atdsrvorg,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     qtd_saldo       decimal (6,0),
     qtd_solic       decimal (6,0),
     c24utidiaqtd    like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd    like dbsmopgitm.c24pagdiaqtd,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgitmnum    like dbsmopgitm.socopgitmnum
  end record

  define ws          record
     confirma        char (01),
     incitmok        char (01),   #-> incluiu item na tela de custo (s/n)
     count           integer,
     operacao        char (01),
     lcvcod_op       like dbsmopg.lcvcod,
     aviestcod_op    like dbsmopg.aviestcod,
     pestip          like dbsmopg.pestip,
     socpgtdoctip    like dbsmopg.socpgtdoctip,
     socopgorgcod    like dbsmopg.socopgorgcod,
     socpgtdsctip    like dbsmopg.socpgtdsctip,
     soctip          like dbsmopg.soctip,
     cgccpfnum       like dbsmopg.cgccpfnum,
     cgcord          like dbsmopg.cgcord,
     cgccpfdig       like dbsmopg.cgccpfdig,
     socopgitmnum    like dbsmopgitm.socopgitmnum,
     atdsrvnumant    like dbsmopgitm.atdsrvnum,
     atdsrvanoant    like dbsmopgitm.atdsrvano,
     atdsrvorg       like datmservico.atdsrvorg,
     pgtdat          like datmservico.pgtdat,
     atdfnlflg       like datmservico.atdfnlflg,
     socopgnum       like dbsmopgitm.socopgnum,
     atdetpcod       like datmsrvacp.atdetpcod,
     comando         char (1400),
     nfsnum          like dbsmopgitm.nfsnum,
     socopgitmvlr_sv like dbsmopgitm.socopgitmvlr,
     retorno         char(50),
     msg1            char (40),
     msg2            char (40),
     vlrfxacod       integer,
     socconlibflg    char (1),
     avivclgrp       like datkavisveic.avivclgrp ,
     aviprvent       like datmavisrent.aviprvent ,
     gratuita        char(12),
     motivo          char(25),
     saldo           smallint                     ,
     clscod          like abbmclaus.clscod        ,
     ctsopc          like ssamcts.ctsopc          ,
     succod          like datrservapol.succod     ,
     aplnumdig       like datrservapol.aplnumdig  ,
     itmnumdig       like datrservapol.itmnumdig  ,
     prporg          like datmavisrent.prporg     ,
     prpnumdig       like datmavisrent.prpnumdig  ,
     avioccdat       like datmavisrent.avioccdat  ,
     lcvcod          like datklocadora.lcvcod     ,
     aviestcod       like datkavislocal.aviestcod ,
     avivclcod       like datkavisveic.avivclcod  ,
     avivclvlr       like datmavisrent.avivclvlr  ,
     locsegvlr       like datmavisrent.locsegvlr  ,
     avialgmtv       like datmavisrent.avialgmtv  ,
     aviprodiaqtd    array[2] of like datmprorrog.aviprodiaqtd,
     soccstcod       like dbskcustosocorro.soccstcod,
     lcvlojtip_op    like datkavislocal.lcvlojtip ,
     lcvlojtip       like datkavislocal.lcvlojtip ,
     slccctcod       like datmavisrent.slccctcod  ,
     flgnf           smallint                     ,
     rsrincdat       like dbsmopgitm.rsrincdat    ,
     rsrfnldat       like dbsmopgitm.rsrfnldat    ,
     flgmultpg       smallint,
     aviretdat       like datmavisrent.aviretdat,
     ciaempcod       like datmservico.ciaempcod,     #PSI 205206
     ciaempcodOP     like datmservico.ciaempcod,     #PSI 205206
     segnumdig       like dbsmopg.segnumdig    ,
     opgempcod       like dbsmopg.empcod
  end record

  define arr_aux     smallint
  define scr_aux     smallint
  define ws_flgsub   smallint
  define l_ret       char(01)
        ,m_aviretdat like datmavisrent.aviretdat
        ,l_nfsnum    like dbsmopgitm.nfsnum
        ,l_mensagem  char(50)   #PSI205206

  define l_ctb00g01  record
     totanl          smallint
    ,c24evtcod       like datkevt.c24evtcod
    ,c24fsecod       like datkevt.c24fsecod
  end record

  define l_fav record
         errcod      smallint ,
         msg         char(80) ,
         favtip      smallint ,
         favtipnom   char(40) ,
         favtipdes   char(10)
  end record
  define l_flag  smallint
  
  initialize a_ctb02m06    to null
  initialize d_ctb02m06.*  to null
  initialize ws.*          to null
  initialize l_ctb00g01.*  to null
  initialize l_fav.*       to null

  let  g_privez = true
  let  l_ret    = null
  let  l_nfsnum = null

  let ws.comando = "select atdsrvorg, ciaempcod ",   #PSI 205206
                   "  from datmservico   ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
  prepare sel_srvorg    from   ws.comando
  declare c_ctb02m06srv cursor for sel_srvorg

  let ws.comando = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
  prepare sel_datmsrvacp from ws.comando
  declare c_datmsrvacp cursor for sel_datmsrvacp

  let ws.comando = "select a.lcvvcldiavlr,      "
                 , "       a.lcvvclsgrvlr,      "
                 , "       a.prtsgrvlr,         "
                 , "       a.diafxovlr,         "
                 , "       b.prtaertaxvlr       "
                 , "  from datklocaldiaria a,   "
                 , "       datkavislocal b      "
                 , " where b.lcvcod       =  ?  "
                 , "   and b.aviestcod    =  ?  "
                 , "   and a.lcvlojtip    =  b.lcvlojtip    "
                 , "   and a.lcvregprccod =  b.lcvregprccod "
                 , "   and a.avivclcod    =  ?  "
                 , "   and a.lcvcod       =  b.lcvcod      "
                 , "   and ?  between a.viginc and a.vigfnl  "
                 , "   and ?  between a.fxainc and a.fxafnl  "
  prepare pctb02m06001 from ws.comando
  declare cctb02m06001 cursor for pctb02m06001
  
  let ws.comando = "select aviretdat from datmavisrent "
                 , " where atdsrvnum = ?    "
                 , "   and atdsrvano = ?    "
  prepare pctb02m06002 from ws.comando
  declare cctb02m06002 cursor for pctb02m06002


  open window w_ctb02m06 at 06,02 with form "ctb02m06"
       attribute(form line first, comment line last - 1)

  let arr_aux = 1
  let d_ctb02m06.socopgnum = param.socopgnum

  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  whenever error continue
  select lcvcod      , aviestcod   , pestip,
         socpgtdoctip, socopgorgcod, socpgtdsctip,
         cgccpfnum   , cgcord      , cgccpfdig,
         soctip      , segnumdig   , empcod
  into ws.lcvcod_op   , ws.aviestcod_op, ws.pestip,
       ws.socpgtdoctip, ws.socopgorgcod, ws.socpgtdsctip,
       ws.cgccpfnum   , ws.cgcord      , ws.cgccpfdig,
       ws.soctip      , ws.segnumdig   , ws.opgempcod
  from dbsmopg
  where socopgnum = param.socopgnum
  whenever error stop
  
  if sqlca.sqlcode != 0
     then
     if sqlca.sqlcode = 100
        then
        error " Ordem de pagamento não localizada "
     else
        error " Erro (", sqlca.sqlcode,") na leitura da ordem de pagamento!"
     end if
     let int_flag = false
     close window w_ctb02m06
     return
  end if
  
  call ctb00g01_dados_favtip(5, '', ws.segnumdig, ws.lcvcod_op,
                             ws.aviestcod_op,  '',
                             ws.opgempcod, '', '', '', '')
       returning l_fav.errcod, l_fav.msg,
                 l_fav.favtip, l_fav.favtipnom, l_fav.favtipdes
                 
  if l_fav.favtip = 4  # Locadora
     then
     whenever error continue
     select lcvlojtip
       into ws.lcvlojtip_op
       from datkavislocal
      where lcvcod    = ws.lcvcod_op
        and aviestcod = ws.aviestcod_op
     whenever error stop
     
     if sqlca.sqlcode <> 0
        then
        error " Erro (",sqlca.sqlcode,") na leitura da ordem de pagamento!"
        let int_flag = false
        close window w_ctb02m06
        return
     end if
  end if
  
  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctb02m06  cursor for
     select dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
            dbsmopgitm.atdsrvano   , dbsmopgitm.c24utidiaqtd,
            dbsmopgitm.c24pagdiaqtd, dbsmopgitm.socopgitmvlr,
            dbsmopgitm.socopgitmnum, dbsmopgitm.rsrincdat,
            dbsmopgitm.rsrfnldat   , sum(dbsmopgcst.socopgitmcst)
       from dbsmopgitm, outer dbsmopgcst
      where dbsmopgitm.socopgnum    = param.socopgnum           and
            dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
            dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum
 
      group by dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
               dbsmopgitm.atdsrvano   , dbsmopgitm.c24utidiaqtd,
               dbsmopgitm.c24pagdiaqtd, dbsmopgitm.socopgitmvlr,
               dbsmopgitm.socopgitmnum, dbsmopgitm.rsrincdat,
               dbsmopgitm.rsrfnldat
      order by dbsmopgitm.socopgitmnum

      
  foreach c_ctb02m06 into a_ctb02m06[arr_aux].nfsnum,
                          a_ctb02m06[arr_aux].atdsrvnum,
                          a_ctb02m06[arr_aux].atdsrvano,
                          a_ctb02m06[arr_aux].c24utidiaqtd,
                          a_ctb02m06[arr_aux].c24pagdiaqtd,
                          a_ctb02m06[arr_aux].socopgitmvlr,
                          a_ctb02m06[arr_aux].socopgitmnum,
                          ws.rsrincdat,
                          ws.rsrfnldat,
                          a_ctb02m06[arr_aux].socopgitmcst

     open  c_ctb02m06srv using a_ctb02m06[arr_aux].atdsrvnum,
                               a_ctb02m06[arr_aux].atdsrvano
     fetch c_ctb02m06srv into  a_ctb02m06[arr_aux].atdsrvorg,
                               ws.ciaempcod    #PSI 205206
     close c_ctb02m06srv
     
     let l_nfsnum = a_ctb02m06[arr_aux].nfsnum
     
     #PSI 205206
     #se não tem empresa para OP - assumir a empresa do primeiro item
     if ws.ciaempcodOP is null then
        let ws.ciaempcodOP = ws.ciaempcod
     else
        #se tem empresa para OP - verificar se é a mesma
        if ws.ciaempcodOP <> ws.ciaempcod then
           error "Itens da OP não são da mesma empresa!! Por favor altere!! "
           display "Itens da OP não são da mesma empresa!! Por favor altere!!",
                   a_ctb02m06[arr_aux].atdsrvnum, a_ctb02m06[arr_aux].atdsrvano
        end if
        
        # OP com itens de empresas diferentes da empresa da OP
        if ws.opgempcod != ws.ciaempcod
           then
           error ' Item de OP de empresa diferente, OP: ', ws.opgempcod, ' / Item: ', ws.ciaempcod 
        end if
     end if

     if a_ctb02m06[arr_aux].socopgitmcst is null then
        let a_ctb02m06[arr_aux].socopgitmcst = 0
     end if

     let a_ctb02m06[arr_aux].socopgtotvlr = a_ctb02m06[arr_aux].socopgitmvlr +
                                     (a_ctb02m06[arr_aux].socopgitmcst * (-1))

     #-------------------------------------------
     # VERIFICA SOLICITADAS
     #-------------------------------------------
     let    ws.aviretdat = null
     select lcvcod   , aviestcod,
            avivclcod, avivclvlr,
            locsegvlr, avialgmtv,
            aviprvent, avioccdat,
            prporg   , prpnumdig,
            aviretdat
       into ws.lcvcod   , ws.aviestcod,
            ws.avivclcod, ws.avivclvlr,
            ws.locsegvlr, ws.avialgmtv,
            ws.aviprvent, ws.avioccdat,
            ws.prporg   , ws.prpnumdig,
            ws.aviretdat
       from datmavisrent
      where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
        and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
        #####DISPLAY "DATA : ",ws.aviretdat,"-",param.socopgnum
     
     # busca dados de prorrogacao
     if ws.rsrincdat is null then
        select sum(aviprodiaqtd)
          into ws.aviprodiaqtd[1]
          from datmprorrog
         where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
           and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
           and aviprostt = "A"
     end if

     if ws.aviprodiaqtd[1] is null  then
        let ws.aviprodiaqtd[1] = 0
     end if

     #-------------------------------------------
     # QUANTIDADE PAGTOS MESMO SERVICO
     #-------------------------------------------
      let ws.flgmultpg = 0
      select count(*)
        into ws.flgmultpg
        from dbsmopgitm, dbsmopg
       where dbsmopgitm.atdsrvnum =  a_ctb02m06[arr_aux].atdsrvnum
         and dbsmopgitm.atdsrvano =  a_ctb02m06[arr_aux].atdsrvano
         and dbsmopgitm.socopgnum <> param.socopgnum
         and dbsmopg.socopgnum    =  dbsmopgitm.socopgnum
         and dbsmopg.socopgsitcod <> 8

     #-------------------------------------------
     # QUANTIDADE SOLICITADAS
     #-------------------------------------------
     if ws.avialgmtv  = 4 and
        ws.flgmultpg >= 1 and
        ws.rsrincdat is not null then
        select sum(aviprodiaqtd)
          into a_ctb02m06[arr_aux].qtd_solic
          from datmprorrog
         where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
           and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
           and aviprostt = "A"
           and vclretdat between ws.rsrincdat and ws.rsrfnldat
     else
        let a_ctb02m06[arr_aux].qtd_solic = ws.aviprvent + ws.aviprodiaqtd[1]
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 2500   then
        error " Limite excedido! Ordem de pagamento com mais de 2500 itens!"
        exit foreach
     end if

  end foreach
  
  #PSI 205206 - se encontrou itens para OP
  if arr_aux > 1 then
     call cty14g00_empresa_abv(ws.opgempcod)
          returning l_ret,
                    l_mensagem,
                    d_ctb02m06.empresa
  end if

  message ""
  call set_count(arr_aux-1)  
  call cabec_ctb02m06()
  let  ws_flgsub = 0
  # message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F5)Repete NF, (F6)Historico"
  message " (F17)Abandona  (F1)Inclui  (F2)Exclui  (F6)Historico"

  while true
     let int_flag = false

     input array a_ctb02m06 without defaults from s_ctb02m06.*
        before row
           let arr_aux = arr_curr()
           let scr_aux = scr_line()
           if arr_aux <= arr_count()  then
              let ws.operacao = "a"
              let ws.atdsrvnumant = a_ctb02m06[arr_aux].atdsrvnum
              let ws.atdsrvanoant = a_ctb02m06[arr_aux].atdsrvano
           else
              initialize ws.rsrincdat, ws.rsrfnldat to null
           end if
           
           initialize ws.gratuita, ws.motivo  to null
           
           display by name ws.gratuita
           display by name ws.motivo

           if a_ctb02m06[arr_aux].socopgitmnum  is null   then
              let a_ctb02m06[arr_aux].socopgitmnum = 0
           end if

        before insert
           options insert key F31
           let ws.operacao = "i"
           
           initialize a_ctb02m06[arr_aux].* to null
           
           let a_ctb02m06[arr_aux].socopgitmnum = 0
           display a_ctb02m06[arr_aux].* to s_ctb02m06[scr_aux].*
           
           # PSI 198404 People, uma NF por OP, nao editar nfsnum
           #before field nfsnum
           #   if ws.socopgorgcod is not null and
           #      ws.socopgorgcod = 2         then  # OP AUTOMATICA
           #      if ws.flgnf is  null        or
           #         ws.flgnf = 0             then
           #         next field atdsrvnum
           #      end if
           #   else
           #      if a_ctb02m06[arr_aux].nfsnum is null then
           #         let a_ctb02m06[arr_aux].nfsnum  = ws.nfsnum
           #         if a_ctb02m06[arr_aux].nfsnum  is not null then
           #            display a_ctb02m06[arr_aux].nfsnum  to
           #                    s_ctb02m06[scr_aux].nfsnum
           #            next field atdsrvnum
           #         end if
           #      end if
           #   end if
           #   display a_ctb02m06[arr_aux].nfsnum    to
           #           s_ctb02m06[scr_aux].nfsnum    attribute (reverse)
           #
           #after field nfsnum
           #   display a_ctb02m06[arr_aux].nfsnum    to
           #           s_ctb02m06[scr_aux].nfsnum
           #
           #   if a_ctb02m06[arr_aux].nfsnum  =  0   then
           #      error " Numero da nota fiscal nao deve ser zeros!"
           #      next field nfsnum
           #   end if
           #
           #   if ws.socpgtdoctip  =  1   then   #-> Docto Nota Fiscal
           #      if a_ctb02m06[arr_aux].nfsnum   is null   then
           #         error " Numero da nota fiscal deve ser informado!"
           #         next field nfsnum
           #      end if
           #   end if
           #
           #   if a_ctb02m06[arr_aux].nfsnum is not null and
           #      a_ctb02m06[arr_aux].nfsnum    <>  0    then
           #
           #      let l_ret    = null
           #      let l_nfsnum = a_ctb02m06[arr_aux].nfsnum
           #
           #      if param.socopgnum is null then
           #         let param.socopgnum = 0
           #      end if
           #
           #      call ctb00g01_vernfs(ws.soctip
           #                          ,ws.pestip
           #                          ,ws.cgccpfnum
           #                          ,ws.cgcord
           #                          ,ws.cgccpfdig
           #                          ,param.socopgnum
           #                          ,ws.socpgtdoctip
           #                          ,l_nfsnum)
           #         returning l_ret
           #
           #      if l_ret = "S" then
           #         error " Documento duplicado! "
           #         next field nfsnum
           #      end if
           #   end if
           #
           #   if fgl_lastkey() = fgl_keyval("up")    or
           #      fgl_lastkey() = fgl_keyval("left")  or
           #      fgl_lastkey() = fgl_keyval("down")  then
           #      if a_ctb02m06[arr_aux].atdsrvnum    is null  or
           #         a_ctb02m06[arr_aux].atdsrvano    is null  or
           #         a_ctb02m06[arr_aux].socopgitmvlr is null  then
           #         error " Dados nao foram completamente preenchidos!"
           #         next field nfsnum
           #      end if
           #   end if
           #
           #   let ws.flgnf = 0
        
           
        before field atdsrvnum
           display a_ctb02m06[arr_aux].atdsrvnum  to
                   s_ctb02m06[scr_aux].atdsrvnum  attribute (reverse)

        after field atdsrvnum
           display a_ctb02m06[arr_aux].atdsrvnum  to
                   s_ctb02m06[scr_aux].atdsrvnum

           if fgl_lastkey() = fgl_keyval("down")  then
              next field atdsrvano
           end if

           if a_ctb02m06[arr_aux].atdsrvnum   is null   or
              a_ctb02m06[arr_aux].atdsrvnum   =  0      then
              error " Numero da ordem de servico deve ser informado!"
              next field atdsrvnum
           end if

           if ws.operacao  =  "a"   then
              if a_ctb02m06[arr_aux].atdsrvnum  <>  ws.atdsrvnumant   then
                 error " Numero da ordem de servico nao deve ser alterado!"
                 next field atdsrvnum
              end if
           end if
           
           if fgl_lastkey() = fgl_keyval("up")    or
              fgl_lastkey() = fgl_keyval("left")  or
              fgl_lastkey() = fgl_keyval("down")  then
              if a_ctb02m06[arr_aux].atdsrvnum    is null  or
                 a_ctb02m06[arr_aux].atdsrvano    is null  or
                 a_ctb02m06[arr_aux].socopgitmvlr is null  then
                 error " Dados nao foram completamente preenchidos!"
                 next field atdsrvnum
              end if
           end if
           

        before field atdsrvano
           display a_ctb02m06[arr_aux].atdsrvano  to
                   s_ctb02m06[scr_aux].atdsrvano  attribute (reverse)

        after field atdsrvano
           display a_ctb02m06[arr_aux].atdsrvano  to
                   s_ctb02m06[scr_aux].atdsrvano

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field atdsrvnum
           end if

           if a_ctb02m06[arr_aux].atdsrvano is null  then
              error " Ano da ordem de servico deve ser informado!"
              next field atdsrvano
           end if

           if ws.operacao  =  "a"   then
              if a_ctb02m06[arr_aux].atdsrvano  <>  ws.atdsrvanoant   then
                 error " Ano da ordem de servico nao deve ser alterado!"
                 next field atdsrvano
              end if
           end if

           # BUSCAR OS VALORES VIA INTEGRAÇÃO APENAS SE FOR INCLUSAO.
           if  ws.operacao = "i" then
               
               call cty24g00_recalculo(a_ctb02m06[arr_aux].atdsrvnum,
                             a_ctb02m06[arr_aux].atdsrvano, 
                             a_ctb02m06[arr_aux].c24utidiaqtd,
                             a_ctb02m06[arr_aux].c24pagdiaqtd,
                             a_ctb02m06[arr_aux].qtd_solic)
               returning l_flag,
                         a_ctb02m06[arr_aux].qtd_solic,    
                         a_ctb02m06[arr_aux].c24utidiaqtd, 
                         a_ctb02m06[arr_aux].c24pagdiaqtd, 
                         a_ctb02m06[arr_aux].socopgtotvlr       
               
               
               
                              
           end if
           
           let a_ctb02m06[arr_aux].socopgitmvlr = a_ctb02m06[arr_aux].socopgtotvlr 
           if l_flag = true then
              let a_ctb02m06[arr_aux].socopgitmcst = 0
           end if
             

           #-----------------------------
           # CHECAGEM DA ORDEM DE SERVICO
           #-----------------------------
           initialize ws.atdfnlflg, ws.atdsrvorg to null
           initialize ws.pgtdat   , ws.atdetpcod to null

           select atdfnlflg   , atdsrvorg   , pgtdat, ciaempcod   #PSI 205206
             into ws.atdfnlflg, ws.atdsrvorg, ws.pgtdat, ws.ciaempcod   #PSI 205206
             from datmservico
            where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
              and atdsrvano = a_ctb02m06[arr_aux].atdsrvano

           if sqlca.sqlcode  =  notfound   then
              error " Ordem de servico nao cadastrada!"
              next field atdsrvano
           else
              if sqlca.sqlcode <> 0    then
                 error " Erro (", sqlca.sqlcode,") na leitura do servico!"
                 next field atdsrvano
              end if
           end if

           # OP com itens de empresas diferentes da empresa da OP
           if ws.opgempcod != ws.ciaempcod
              then
              error ' Item de OP de empresa diferente, OP: ', ws.opgempcod, ' / Item: ', ws.ciaempcod
              next field atdsrvnum
           end if
           
           #PSI 205206
           #se não tem empresa para OP - assumir a empresa do primeiro item
           if ws.ciaempcodOP is null then
              let ws.ciaempcodOP = ws.ciaempcod
           else
              #se tem empresa para OP - verificar se é a mesma
              if ws.ciaempcodOP <> ws.ciaempcod then
                 error "Empresa do item é diferente da empresa dos demais itens. "
                 next field atdsrvnum
              end if
           end if

           let a_ctb02m06[arr_aux].atdsrvorg = ws.atdsrvorg
           display a_ctb02m06[arr_aux].atdsrvorg  to
                   s_ctb02m06[scr_aux].atdsrvorg

           if ws.atdsrvorg <> 8 then      ## CARRO-EXTRA
              error " Somente servicos com origem 08 'carro-extra' !"
              next field atdsrvano
           end if

           # -- OSF 30155 - Fabrica de Software, Katiucia -- #
           initialize l_ctb00g01.* to null

           # ---------------------------------------------- #
           # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
           # ---------------------------------------------- #
           call ctb00g01_srvanl( a_ctb02m06[arr_aux].atdsrvnum
                                ,a_ctb02m06[arr_aux].atdsrvano
                                ,"S" )
                returning l_ctb00g01.totanl
                         ,l_ctb00g01.c24evtcod
                         ,l_ctb00g01.c24fsecod

           if l_ctb00g01.totanl > 0 then
              error "Ordem de servico nao pode ser paga, pendencia(s) em "
                   ,"analise!"
              next field atdsrvano
           end if

           #------------------------------------------------------------
           # VERIFICA ETAPA DO SERVICO
           #------------------------------------------------------------
           open  c_datmsrvacp using  a_ctb02m06[arr_aux].atdsrvnum,
                                     a_ctb02m06[arr_aux].atdsrvano,
                                     a_ctb02m06[arr_aux].atdsrvnum,
                                     a_ctb02m06[arr_aux].atdsrvano
           fetch c_datmsrvacp into   ws.atdetpcod
           close c_datmsrvacp

           if ws.atdfnlflg = "N"  then
              error " Ordem de servico nao finalizada nao pode ser paga!"
              next field atdsrvano
           end if

           if ws.atdetpcod = 1  then  # Etapa LIBERADO
              error " Ordem de servico esta' liberada!"
              next field atdsrvano
           end if

           if ws.atdetpcod <> 4 then  # Etapa srv nao acionado
              error " Etapa do servico diferente de 4 (acionado/finalizado)!"
              next field atdsrvano
           end if

           #------------------------------
           # VERIFICA SE O.P. JA' FOI PAGA
           #------------------------------
           if ws.operacao  =  "i"   then
           initialize ws.socopgnum   to null
                 select dbsmopg.socopgnum, dbsmopgitm.socopgitmnum
                   into ws.socopgnum, a_ctb02m06[arr_aux].socopgitmnum
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
                    and dbsmopgitm.atdsrvano = a_ctb02m06[arr_aux].atdsrvano
                    and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
                    and dbsmopg.socopgsitcod <> 8

                 if sqlca.sqlcode = 0    then
                    if param.socopgnum = ws.socopgnum   then
                       if ws_flgsub = 1 then
                          let ws.operacao = "a"
                       else
                         error " O.S. ja' cadastrada!"
                         next field atdsrvano
                       end if
                    else
                       error " O.S. ja' foi paga pela O.P. No. ", ws.socopgnum
                       next field atdsrvano
                    end if
                 end if

              select avialgmtv
                into ws.avialgmtv
                from datmavisrent
               where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
                 and atdsrvano = a_ctb02m06[arr_aux].atdsrvano

              if ws.avialgmtv <>  4
                 then
                 initialize ws.socopgnum   to null
                 select dbsmopg.socopgnum, dbsmopgitm.socopgitmnum
                   into ws.socopgnum, a_ctb02m06[arr_aux].socopgitmnum
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
                    and dbsmopgitm.atdsrvano = a_ctb02m06[arr_aux].atdsrvano
                    and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
                    and dbsmopg.socopgsitcod <> 8

                 if sqlca.sqlcode = 0    then
                    if param.socopgnum = ws.socopgnum   then
                       if ws_flgsub = 1 then
                          let ws.operacao = "a"
                       else
                         error " O.S. ja' cadastrada!"
                         next field atdsrvano
                       end if
                    else
                       error " O.S. ja' foi paga pela O.P. No. ", ws.socopgnum
                       next field atdsrvano
                    end if
                 end if
                 #--------------------------------------------
                 # SERVICOS PAGOS ANTES DA IMPLANTACAO DA O.P.
                 #--------------------------------------------
                 if ws.pgtdat  is not null    then
                    error " Servico ja' foi pago em ", ws.pgtdat, "!"
                    next field atdsrvano
                 end if
                 
              else
              
                 let ws.flgmultpg = 0
                 select count(*)
                   into ws.flgmultpg
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum =  a_ctb02m06[arr_aux].atdsrvnum
                    and dbsmopgitm.atdsrvano =  a_ctb02m06[arr_aux].atdsrvano
                    and dbsmopgitm.socopgnum <> param.socopgnum
                    and dbsmopg.socopgnum    =  dbsmopgitm.socopgnum
                    and dbsmopg.socopgsitcod <> 8

                 if ws.flgmultpg >= 1 then
                    call cts08g01("C","S",
                                  "ATENCAO: ESTE SERVICO JA' FOI PAGO UMA",
                                  " ",
                                  "OU MAIS VEZES, DESEJA PAGAR NOVAMENTE?",
                                  " ")
                        returning ws.confirma

                    if ws.confirma = "N"  then
                       next field atdsrvano
                    else
                       call ctb02m18(param.socopgnum,
                                     a_ctb02m06[arr_aux].atdsrvnum,
                                     a_ctb02m06[arr_aux].atdsrvano,
                                     ws.rsrincdat,
                                     ws.rsrfnldat)
                           returning ws.rsrincdat,
                                     ws.rsrfnldat

                       if ws.rsrincdat is null or
                          ws.rsrfnldat is null then
                          next field atdsrvano
                       end if
                    end if
                 end if
              end if
           end if

           #-------------------------------------------
           # VERIFICA SALDO/SOLICITADAS/LOJA-LOCADORA
           #-------------------------------------------
           select lcvcod   , aviestcod,
                  avivclcod, avivclvlr,
                  locsegvlr, avialgmtv,
                  aviprvent, avioccdat,
                  prporg   , prpnumdig,
                  slccctcod, aviretdat
             into ws.lcvcod   , ws.aviestcod,
                  ws.avivclcod, ws.avivclvlr,
                  ws.locsegvlr, ws.avialgmtv,
                  ws.aviprvent, ws.avioccdat,
                  ws.prporg   , ws.prpnumdig,
                  ws.slccctcod, ws.aviretdat
             from datmavisrent
            where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
              and atdsrvano = a_ctb02m06[arr_aux].atdsrvano

           if l_fav.favtip = 4  # Locadora
              then
              select lcvlojtip
                into ws.lcvlojtip
                from datkavislocal
               where lcvcod    = ws.lcvcod
                 and aviestcod = ws.aviestcod
   
              if ws.lcvcod_op <> ws.lcvcod then
                 error " Esta reserva pertence a outra Locadora, verifique!"
                 next field atdsrvano
              else
                 if ws.lcvcod_op = 68 or
                    ws.lcvcod_op = 2 then
                    # Locadora 68-Unidas nao verificar tipo de loja
                    # Locadora 02-Localiza nao verificar tipo de loja
                 else
                    if ws.lcvlojtip_op = 1   then   # Corporacao
                       if ws.lcvlojtip <> 1  then
                          error " OP pertence a CORPORACAO e reserva a uma FRANQUIA, verifique!"
                          next field atdsrvano
                       end if
                    else
                       if ws.lcvlojtip_op = 3   and    # REDE/FRANQUIA
                          ws.lcvlojtip   <> 3   then
                          if ws.aviestcod_op <> ws.aviestcod then
                             error " Esta reserva pertence a outra Loja, verifique!"
                             next field atdsrvano
                          end if
                       end if
                    end if
                 end if
              end if
           end if
           
           
           call ctb02m06_motivo(ws.avialgmtv,ws.ciaempcod)
              returning ws.motivo               
          
           case ws.ciaempcod
              when 84
                 call ctb02m06_valida(ws.avialgmtv,ws.slccctcod) 
                    returning ws.confirma   
                 
                 if ws.confirma <> 'S' then
                    next field atdsrvano   
                 end if                              
              otherwise
                 case ws.avialgmtv
                    when 4                        
                          if ws.slccctcod is null or
                              ws.slccctcod = 0     then
                              call cts08g01("A","N",
                                            "NAO CONSTA CODIGO DO CENTRO DE CUSTO",
                                            "PARA ESTA RESERVA POR DEPARTAMENTO.",
                                            " ","FAVOR VERIFICAR!")
                              returning ws.confirma
                              next field atdsrvano
                           end if
                           if ws.socpgtdsctip = 4 then
                              error " Reserva motivo DEPARTAMENTOS nao permitido p/OP com ACERTO CONTABIL!"
                              next field atdsrvano
                           end if
                    when 5 
                           if ws.socpgtdsctip = 4 then
                              error " Reserva motivo PARTICULAR nao permitido p/OP com ACERTO CONTABIL!"
                              next field atdsrvano
                           end if
                 end case
           end case
           display by name ws.motivo attribute (reverse)

           select sum(aviprodiaqtd)
             into ws.aviprodiaqtd[1]       # Prorrogacoes do segurado
             from datmprorrog
            where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
              and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
              and aviprostt = "A"
              and cctcod    is null

           if ws.aviprodiaqtd[1] is NULL  then
              let ws.aviprodiaqtd[1] = 0
           end if

           select sum(aviprodiaqtd)
             into ws.aviprodiaqtd[2]       # Prorrogacoes do C.Cento
             from datmprorrog
            where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
              and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
              and aviprostt = "A"
              and cctcod    is not null

           if ws.aviprodiaqtd[2] is null  then
              let ws.aviprodiaqtd[2] = 0
           end if

           if ws.avialgmtv  = 4 and
              ws.flgmultpg >= 1 then
              select sum(aviprodiaqtd)
                into a_ctb02m06[arr_aux].qtd_solic
                from datmprorrog
               where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
                 and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
                 and aviprostt = "A"
                 and vclretdat between ws.rsrincdat
                                   and ws.rsrfnldat
           else
              let a_ctb02m06[arr_aux].qtd_solic = ws.aviprvent       +
                                                  ws.aviprodiaqtd[1] +
                                                  ws.aviprodiaqtd[2]
           end if

           if l_fav.favtip = 4  # Locadora
              then
              select avivclgrp into ws.avivclgrp
                from datkavisveic
               where lcvcod    = ws.lcvcod
                 and avivclcod = ws.avivclcod
   
              if sqlca.sqlcode <> 0  then
                 error " Erro na localizacao da VEICULO. AVISE A INFORMATICA!"
                 next field atdsrvano
              end if
           end if
           
           initialize ws.saldo to null

           call ctb02m06_condicoes(a_ctb02m06[arr_aux].atdsrvnum,
                                   a_ctb02m06[arr_aux].atdsrvano,
                                   ws.avivclgrp, ws.avialgmtv, ws.avioccdat)
                         returning ws.gratuita, ws.clscod, ws.saldo

           initialize a_ctb02m06[arr_aux].qtd_saldo to null

           if ws.avialgmtv = 1 and ws.avivclgrp = "A"  then
              if ws.saldo is not null  then
                 let a_ctb02m06[arr_aux].qtd_saldo =  ws.saldo
              end if
           end if

           display a_ctb02m06[arr_aux].qtd_saldo  to
                   s_ctb02m06[scr_aux].qtd_saldo
           display a_ctb02m06[arr_aux].qtd_solic  to
                   s_ctb02m06[scr_aux].qtd_solic
                   
           if ws.gratuita is not null  then
              display by name ws.gratuita attribute (reverse)
           end if

           #---------------------------------------------------------------
           # Verifica opcao (Carro Extra/Desc.20%) em caso de BENEF.OFICINA
           #---------------------------------------------------------------
           if (ws.avialgmtv = 3  or
              ws.avialgmtv = 6)  and
              ws.ciaempcod <> 35 and ws.ciaempcod <> 84 then  -- OSF 33367
              select succod   , aplnumdig   , itmnumdig
                into ws.succod, ws.aplnumdig, ws.itmnumdig
                from datrservapol
               where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
                 and atdsrvano = a_ctb02m06[arr_aux].atdsrvano

             call ossaa009_ultima_opc(ws.succod, ws.aplnumdig, ws.itmnumdig,
                                      ws.prporg, ws.prpnumdig, ws.avioccdat)
                            returning ws.ctsopc

             if ws.ctsopc = "F"  then
                call cts08g01("A","N","SEGURADO OPTOU POR DESCONTO",
                                      "DE 20% NA FRANQUIA.","",
                                      "SOLICITE COBRANCA DAS DIARIAS!")
                    returning ws.confirma
             end if
           end if

           #PSI 205206
           #caso é o primeiro item a ser vinculado a OP
           # e ainda nao buscamos o nome da empresa
           if d_ctb02m06.empresa is null then
               call cty14g00_empresa_abv(ws.opgempcod)
                    returning l_ret,
                              l_mensagem,
                              d_ctb02m06.empresa
               display by name d_ctb02m06.empresa attribute (reverse)
           end if
           
           
                                                                
        before field c24utidiaqtd                                     
           display a_ctb02m06[arr_aux].c24utidiaqtd to
                   s_ctb02m06[scr_aux].c24utidiaqtd attribute (reverse)

        after  field c24utidiaqtd
           display a_ctb02m06[arr_aux].c24utidiaqtd to
                   s_ctb02m06[scr_aux].c24utidiaqtd

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field atdsrvano
           end if

           if a_ctb02m06[arr_aux].c24utidiaqtd is null    then
              error " Quantidade de diarias utilizadas deve ser informada!"
              next field c24utidiaqtd
           end if

           if a_ctb02m06[arr_aux].c24utidiaqtd  <  1      then
              error " Quantidade de diarias utilizadas deve ser maior que ZERO!"
              next field c24utidiaqtd
           end if
           
           #let a_ctb02m06[arr_aux].c24pagdiaqtd = a_ctb02m06[arr_aux].c24utidiaqtd

        before field c24pagdiaqtd
           
           call cty24g00_recalculo(a_ctb02m06[arr_aux].atdsrvnum,
                                  a_ctb02m06[arr_aux].atdsrvano,
                                  a_ctb02m06[arr_aux].c24utidiaqtd, 
                                  a_ctb02m06[arr_aux].c24pagdiaqtd,
                                  a_ctb02m06[arr_aux].qtd_solic ) 
               returning l_flag,
                         a_ctb02m06[arr_aux].qtd_solic,    
                         a_ctb02m06[arr_aux].c24utidiaqtd, 
                         a_ctb02m06[arr_aux].c24pagdiaqtd, 
                         a_ctb02m06[arr_aux].socopgtotvlr           
           
           
           display a_ctb02m06[arr_aux].c24pagdiaqtd to
                   s_ctb02m06[scr_aux].c24pagdiaqtd attribute (reverse)

        after  field c24pagdiaqtd
           display a_ctb02m06[arr_aux].c24pagdiaqtd to
                   s_ctb02m06[scr_aux].c24pagdiaqtd

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field c24utidiaqtd
           end if

           if a_ctb02m06[arr_aux].c24pagdiaqtd is null    then
              error " Quantidade de diarias a serem pagas deve ser informada!"
              next field c24pagdiaqtd
           end if

           if a_ctb02m06[arr_aux].c24pagdiaqtd  >
              a_ctb02m06[arr_aux].c24utidiaqtd  then
              error " Quant. de diarias a serem pagas nao pode ser maior que quantidade utilizada!"
              next field c24pagdiaqtd
           end if

           #if ws.opgempcod <> 84 then
           #   case ws.avialgmtv
           #      when 1
           #           if a_ctb02m06[arr_aux].c24pagdiaqtd   >
           #              a_ctb02m06[arr_aux].qtd_saldo  +  1   then
           #              initialize ws.msg1, ws.msg2 to null
           #              if ws.aviprodiaqtd[2] <> 0 then
           #                 let ws.msg1 = "CONSTA PRORROGACOES DE ",
           #                               ws.aviprodiaqtd[2] using "&&#" ,
           #                               " RESERVA(S)"
           #                 let ws.msg2 = "POR CENTO DE CUSTO PARA ESTE SEGURADO."
           #              end if
           #              call cts08g01("C","S"," ",
           #                            "ATENCAO :  QTDE PAGA SUPERIOR AO SALDO",
           #                             ws.msg1, ws.msg2)
           #              returning ws.confirma
           #   
           #              if ws.confirma = "N"  then
           #                 next field c24pagdiaqtd
           #              end if
           #           end if
           #      when 2
           #           #PSI 232700 - ligia - 11/11/2008 - inibir
           #           #if a_ctb02m06[arr_aux].c24pagdiaqtd  > 7 then
           #           #   error " Para este motivo, quant.de diarias pagas nao pode ser maior que 7 (sete)!"
           #           #   next field c24pagdiaqtd
           #           #end if
           #   end case
           #end if 
           if ws.avialgmtv = 5 and ws.opgempcod <> 84  and
              a_ctb02m06[arr_aux].c24pagdiaqtd > 0  then
              error " Nao ha' pagamento de diarias para locacao particular!"
              next field c24pagdiaqtd
           end if

           if ws.locsegvlr is null  then
              let ws.locsegvlr = 0.00
           end if

           #BURINI if ws.operacao  <> "a"   then
           #BURINI    if ws.avialgmtv =  5 and ws.opgempcod <> 84 then
           #BURINI       let a_ctb02m06[arr_aux].socopgtotvlr = 0
           #BURINI       next field socopgitmvlr
           #BURINI    else
           #BURINI    #Marcel
           #BURINI    
           #BURINI       if l_fav.favtip = 4  # Locadora
           #BURINI          then
           #BURINI          let   m_aviretdat = null
           #BURINI          OPEN  cctb02m06002  USING a_ctb02m06[arr_aux].atdsrvnum
           #BURINI                                   ,a_ctb02m06[arr_aux].atdsrvano
           #BURINI          FETCH cctb02m06002  INTO  m_aviretdat
           #BURINI          close cctb02m06002
           #BURINI 
           #BURINI          let   w_lcvvcldiavlr  = null
           #BURINI          let   w_lcvvclsgrvlr  = null
           #BURINI          let   w_prtsgrvlr     = null
           #BURINI          let   w_diafxovlr     = null
           #BURINI          let   w_prtaertaxvlr  = null
           #BURINI 
           #BURINI          OPEN cctb02m06001  USING  ws.lcvcod
           #BURINI                                  , ws.aviestcod
           #BURINI                                  , ws.avivclcod
           #BURINI                                  , m_aviretdat
           #BURINI                                  , a_ctb02m06[arr_aux].c24pagdiaqtd
           #BURINI 
           #BURINI          #####DISPLAY "EChave: ",ws.lcvcod,"-", ws.aviestcod,"-", ws.avivclcod,"-",ws.aviretdat,"-", a_ctb02m06[arr_aux].c24pagdiaqtd,"-",m_aviretdat
           #BURINI 
           #BURINI          FETCH cctb02m06001  INTO  w_lcvvcldiavlr
           #BURINI                                  , w_lcvvclsgrvlr
           #BURINI                                  , w_prtsgrvlr
           #BURINI                                  , w_diafxovlr
           #BURINI                                  , w_prtaertaxvlr
           #BURINI          CLOSE cctb02m06001
           #BURINI       end if
           #BURINI       
           #BURINI       if  w_lcvvcldiavlr  is null then
           #BURINI           let  w_lcvvcldiavlr  = 0
           #BURINI       end if
           #BURINI       if  w_lcvvclsgrvlr  is null then
           #BURINI           let  w_lcvvclsgrvlr  = 0
           #BURINI       end if
           #BURINI       if  w_prtsgrvlr  is null then
           #BURINI           let  w_prtsgrvlr  = 0
           #BURINI       end if
           #BURINI       if  w_diafxovlr  is null then
           #BURINI           let  w_diafxovlr  = 0
           #BURINI       end if
           #BURINI       if  w_prtaertaxvlr  is null then
           #BURINI           let  w_prtaertaxvlr  = 0
           #BURINI       end if
           #BURINI 
           #BURINI       #####display "Evalores dia:", w_lcvvcldiavlr,"-Seg",w_lcvvclsgrvlr,"-porto", w_prtsgrvlr, "-fixo",w_diafxovlr,"-txaer", w_prtaertaxvlr
           #BURINI 
           #BURINI       IF w_diafxovlr > 0 THEN
           #BURINI          LET a_ctb02m06[arr_aux].socopgtotvlr =
           #BURINI              (w_diafxovlr + w_lcvvclsgrvlr)
           #BURINI       ELSE
           #BURINI         IF w_diafxovlr <= 0 THEN
           #BURINI             LET a_ctb02m06[arr_aux].socopgtotvlr =
           #BURINI                 (w_prtsgrvlr + w_lcvvclsgrvlr)   *
           #BURINI                  a_ctb02m06[arr_aux].c24pagdiaqtd
           #BURINI         END IF
           #BURINI       END IF
           #BURINI 
           #BURINI       #####display "Evlr antes:", a_ctb02m06[arr_aux].socopgtotvlr
           #BURINI 
           #BURINI       IF w_prtaertaxvlr  <>  0  THEN
           #BURINI          LET a_ctb02m06[arr_aux].socopgtotvlr =
           #BURINI            ((a_ctb02m06[arr_aux].socopgtotvlr * w_prtaertaxvlr)
           #BURINI              / 100 ) + a_ctb02m06[arr_aux].socopgtotvlr
           #BURINI       END IF
           #BURINI 
           #BURINI       #####display "Evlr apos:", a_ctb02m06[arr_aux].socopgtotvlr
           #BURINI 
           #BURINI    end if
           #BURINI end if
 
           display a_ctb02m06[arr_aux].socopgtotvlr  to
                   s_ctb02m06[scr_aux].socopgtotvlr 
           

        before field socopgtotvlr
        
           call cty24g00_recalculo(a_ctb02m06[arr_aux].atdsrvnum,
                                  a_ctb02m06[arr_aux].atdsrvano,
                                  a_ctb02m06[arr_aux].c24utidiaqtd, 
                                  a_ctb02m06[arr_aux].c24pagdiaqtd,
                                  a_ctb02m06[arr_aux].qtd_solic ) 
               returning l_flag,
                         a_ctb02m06[arr_aux].qtd_solic,    
                         a_ctb02m06[arr_aux].c24utidiaqtd, 
                         a_ctb02m06[arr_aux].c24pagdiaqtd, 
                         a_ctb02m06[arr_aux].socopgtotvlr           
           
           
           display a_ctb02m06[arr_aux].c24pagdiaqtd to
                   s_ctb02m06[scr_aux].c24pagdiaqtd attribute (reverse)        
        
        
           display a_ctb02m06[arr_aux].socopgtotvlr  to
                   s_ctb02m06[scr_aux].socopgtotvlr  attribute (reverse)

        after field socopgtotvlr
           display a_ctb02m06[arr_aux].socopgtotvlr  to
                   s_ctb02m06[scr_aux].socopgtotvlr

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field atdsrvano
           end if

           if a_ctb02m06[arr_aux].socopgtotvlr is null   then
              let a_ctb02m06[arr_aux].socopgtotvlr = 0
           end if

           if a_ctb02m06[arr_aux].socopgtotvlr  = 0  and
              ws.avialgmtv                     <> 5  then
              error " Valor inicial da reserva deve ser informado!"
              next field socopgtotvlr
           end if

           #-------------------------------------------
           # CONSISTENCIA DE LIMITE DE VALORES
           #-------------------------------------------
           initialize ws.msg1, ws.msg2 to null
           # if a_ctb02m06[arr_aux].socopgtotvlr > 1000.00 then
           #    let ws.msg1  =  "RESERVA DE CARRO-EXTRA COM"
           #    let ws.msg2  =  "VALOR ACIMA DE R$ 1.000,00"
           # end if
           # 
           # if ws.msg1 is not null then
           #    if g_issk.acsnivcod  <  8   then
           #       error " Nivel de acesso nao permite liberacao!"
           #       next field socopgtotvlr
           #    else
           #       call cts08g01("C","S", ws.msg1, ws.msg2, "",
           #                              "CONFIRMA PAGAMENTO ?")
           #            returning ws.confirma
           # 
           #       if ws.confirma = "N"  then
           #          next field socopgtotvlr
           #       end if
           #    end if
           # end if
 
           let a_ctb02m06[arr_aux].socopgitmvlr = a_ctb02m06[arr_aux].socopgtotvlr
           let a_ctb02m06[arr_aux].socopgitmvlr = a_ctb02m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

           display a_ctb02m06[arr_aux].* to s_ctb02m06[scr_aux].*

        before field socopgitmvlr
           display a_ctb02m06[arr_aux].socopgitmvlr  to
                   s_ctb02m06[scr_aux].socopgitmvlr  attribute (reverse)

        after field socopgitmvlr
           display a_ctb02m06[arr_aux].socopgitmvlr  to
                   s_ctb02m06[scr_aux].socopgitmvlr

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field socopgtotvlr
           end if

           if a_ctb02m06[arr_aux].socopgitmvlr   is null   then
              error " Valor da reserva deve ser informado!"
              next field socopgitmvlr
           end if
           
           let a_ctb02m06[arr_aux].socopgitmcst =
                                        a_ctb02m06[arr_aux].socopgitmvlr -
                                        a_ctb02m06[arr_aux].socopgtotvlr
           
           let a_ctb02m06[arr_aux].socopgitmcst = a_ctb02m06[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
           display a_ctb02m06[arr_aux].socopgitmcst to
                   s_ctb02m06[scr_aux].socopgitmcst

           if a_ctb02m06[arr_aux].socopgitmcst is not null and
              a_ctb02m06[arr_aux].socopgitmcst <> 0
              then
              call ctb02m07(2, a_ctb02m06[arr_aux].socopgitmcst)
                   returning ws.soccstcod
              if ws.soccstcod = 0 
                 then
                 call cts08g01("A","N","","ESTE ITEM CONTEM DESCONTO, FAVOR",
                                       "","INDICAR O CODIGO CORRETO.")
                      returning ws.confirma
                 next field socopgitmvlr
              end if
           else
              let a_ctb02m06[arr_aux].socopgitmcst =  0
              let ws.soccstcod = 0
           end if

        on key(interrupt)
           exit input

        before delete
           let ws.operacao = "d"
           if a_ctb02m06[arr_aux].socopgitmnum   is null   or
              a_ctb02m06[arr_aux].socopgitmnum   =  0      then
              continue input
           end if

           let ws.confirma = "N"

           call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                returning ws.confirma

           if ws.confirma = "N"  then
              exit input
           end if

           # CASO SEJA ULTIMO ITEM A O.P. DEVE SER REMOVIDA
           # ----------------------------------------------
           let ws.count = 0
           select count(*)  into  ws.count
             from dbsmopgitm
            where socopgnum  =  param.socopgnum

           if ws.count = 1   then
              error " Nao e' possivel excluir todos itens da O.P. em digitacao!"
              exit input
           end if

           begin work
           #----------
           delete from dbsmopgcst
            where dbsmopgcst.socopgnum    = param.socopgnum      and
                  dbsmopgcst.socopgitmnum = a_ctb02m06[arr_aux].socopgitmnum
                  
           if sqlca.sqlcode <> 100   and
              sqlca.sqlcode <> 0     then
              error "Erro (",sqlca.sqlcode,") na exclusao do custo do item!"
              next field atdsrvnum
           end if
           
           delete from dbsmopgitm
            where dbsmopgitm.socopgnum    = param.socopgnum      and
                  dbsmopgitm.socopgitmnum = a_ctb02m06[arr_aux].socopgitmnum
                  
           if sqlca.sqlcode <> 0   then
              error "Erro (",sqlca.sqlcode,") na exclusao do item da O.P.!"
              next field atdsrvnum
           end if
           commit work
          #-----------

           initialize a_ctb02m06[arr_aux].* to null
           display a_ctb02m06[arr_aux].* to s_ctb02m06[scr_aux].*

        # PSI 198404 People, digitar NF apenas na OP
        # on key (F5)
        #    call ctb11m15(ws.nfsnum) returning ws.nfsnum
        #    
        #    initialize a_ctb02m06[arr_aux].nfsnum to null
        # 
        #    if param.socopgnum is null then
        #       let param.socopgnum = 0
        #    end if
        # 
        #    call ctb00g01_vernfs(ws.soctip
        #                        ,ws.pestip
        #                        ,ws.cgccpfnum
        #                        ,ws.cgcord
        #                        ,ws.cgccpfdig
        #                        ,param.socopgnum
        #                        ,ws.socpgtdoctip
        #                        ,ws.nfsnum)
        #       returning l_ret
        #       
        #    if l_ret = "S" then
        #       error " Documento duplicado! "
        #       initialize ws.nfsnum to null
        #       next field nfsnum
        #    end if
        #    
        #    next field nfsnum
        
        on key (F6)
           if a_ctb02m06[arr_aux].atdsrvnum is not null  then
              call cts10n00(a_ctb02m06[arr_aux].atdsrvnum,
                            a_ctb02m06[arr_aux].atdsrvano,
                            g_issk.funmat, " ", " ")
           end if

        after row
           options insert key F1
           
           {
           # PSI198404 tratar nao mandar nulls para o banco
           if g_issk.funmat   is null or 
              param.socopgnum is null or
              a_ctb02m06[arr_aux].atdsrvnum is null or
              a_ctb02m06[arr_aux].atdsrvano is null or
              a_ctb02m06[arr_aux].socopgitmvlr is null
              then
              error "Valores nulos na insercao do item, revise"
              next field atdsrvnum 
           end if
           }
           let a_ctb02m06[arr_aux].nfsnum = l_nfsnum
           
           #Formatação do campo alterada para atendimento do chamado 100913299
           let a_ctb02m06[arr_aux].socopgitmvlr = a_ctb02m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"
           let a_ctb02m06[arr_aux].socopgitmcst = a_ctb02m06[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
           
           case ws.operacao
              when "i"
                 initialize ws.socopgnum   to null
                 select dbsmopg.socopgnum, dbsmopgitm.socopgitmnum
                   into ws.socopgnum, a_ctb02m06[arr_aux].socopgitmnum
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum and
                        dbsmopgitm.atdsrvano = a_ctb02m06[arr_aux].atdsrvano and
                        dbsmopg.socopgnum    = dbsmopgitm.socopgnum          and
                        dbsmopg.socopgsitcod <> 8
               
                 if sqlca.sqlcode = 0    then
                    if param.socopgnum = ws.socopgnum   then
                       error " O.S. ja' cadastrada!"
                       next field atdsrvano
                    else
                       error " O.S. ja' foi paga pela O.P. No. ", ws.socopgnum
                       next field atdsrvano
                    end if
                 end if
                 
                 initialize  ws.socopgitmnum   to null
                 select max(socopgitmnum)
                   into ws.socopgitmnum
                   from dbsmopgitm
                  where socopgnum = param.socopgnum

                 if ws.socopgitmnum   is null   then
                    let ws.socopgitmnum = 0
                 end if
                 let ws.socopgitmnum = ws.socopgitmnum + 1
                 let a_ctb02m06[arr_aux].socopgitmnum = ws.socopgitmnum
                 
                 # INCLUI ITEM DA O.P.
                 #--------------------
                 begin work
                 #---------
                 insert into dbsmopgitm
                             (socopgnum,
                              atdsrvnum,
                              atdsrvano,
                              socopgitmvlr,
                              nfsnum,
                              socopgitmnum,
                              funmat,
                              socconlibflg,
                              c24utidiaqtd,
                              c24pagdiaqtd,
                              rsrincdat,
                              rsrfnldat)
                      values (param.socopgnum,
                              a_ctb02m06[arr_aux].atdsrvnum,
                              a_ctb02m06[arr_aux].atdsrvano,
                              a_ctb02m06[arr_aux].socopgitmvlr,
                              a_ctb02m06[arr_aux].nfsnum,
                              ws.socopgitmnum,
                              g_issk.funmat,
                              "N",
                              a_ctb02m06[arr_aux].c24utidiaqtd,
                              a_ctb02m06[arr_aux].c24pagdiaqtd,
                              ws.rsrincdat,
                              ws.rsrfnldat)


                 # INCLUSAO DA FASE (DIGITADA)
                 #----------------------------

                 # PSI 221074 - BURINI
                 call cts50g00_sel_etapa(param.socopgnum, 3)
                      returning ws.retorno,
                                ws.msg1

                 if  ws.retorno = 2  then

                     call cts50g00_insere_etapa(param.socopgnum, 3, g_issk.funmat)
                          returning ws.retorno,
                                    ws.msg1

                     if ws.retorno <> 1   then
                        error ws.msg1
                     end if
                 else
                     if  ws.retorno = 1 then
                         call cts50g00_atualiza_etapa(param.socopgnum, 3, g_issk.funmat)
                              returning ws.retorno,
                                        ws.msg1

                         if ws.retorno <> 1   then
                            error ws.msg1
                         end if
                     else
                         error ws.msg1
                     end if
                 end if

                 # INCLUSAO DO CUSTO DO ITEM
                 #----------------------------
                 if a_ctb02m06[arr_aux].socopgitmcst is not null and
                    a_ctb02m06[arr_aux].socopgitmcst <>   0      then
                    insert into dbsmopgcst
                               (socopgnum,
                                socopgitmnum,
                                soccstcod,
                                cstqtd,
                                socopgitmcst)
                        values (param.socopgnum,
                                ws.socopgitmnum,
                                ws.soccstcod,
                                1 ,
                                a_ctb02m06[arr_aux].socopgitmcst )
                 end if

                 commit work
                 #----------

              when "a"
                 begin work
                 #----------
                 update dbsmopgitm  set
                             (vlrfxacod,
                              socopgitmvlr,
                              nfsnum,
                              c24utidiaqtd,
                              c24pagdiaqtd,
                              rsrincdat,
                              rsrfnldat)
                           = (ws.vlrfxacod,
                              a_ctb02m06[arr_aux].socopgitmvlr,
                              a_ctb02m06[arr_aux].nfsnum,
                              a_ctb02m06[arr_aux].c24utidiaqtd,
                              a_ctb02m06[arr_aux].c24pagdiaqtd,
                              ws.rsrincdat,
                              ws.rsrfnldat)
                  where socopgnum    = param.socopgnum
                    and socopgitmnum = a_ctb02m06[arr_aux].socopgitmnum

                 if ws.soccstcod is not null then
                    select soccstcod
                      from dbsmopgcst
                     where socopgnum    = param.socopgnum
                       and socopgitmnum = a_ctb02m06[arr_aux].socopgitmnum

                    if sqlca.sqlcode = notfound then
                       if a_ctb02m06[arr_aux].socopgitmcst is not null and
                          a_ctb02m06[arr_aux].socopgitmcst <>   0      then
                          insert into dbsmopgcst
                                     (socopgnum,
                                      socopgitmnum,
                                      soccstcod,
                                      cstqtd,
                                      socopgitmcst)
                              values (param.socopgnum,
                                      a_ctb02m06[arr_aux].socopgitmnum,
                                      ws.soccstcod,
                                      1 ,
                                      a_ctb02m06[arr_aux].socopgitmcst )
                       end if
                    else
                       update dbsmopgcst set
                                     (soccstcod,
                                      socopgitmcst)
                                   = (ws.soccstcod,
                                      a_ctb02m06[arr_aux].socopgitmcst )
                        where socopgnum    = param.socopgnum
                          and socopgitmnum = a_ctb02m06[arr_aux].socopgitmnum
                    end if
                 end if

                 commit work
                 #----------
           end case

           display a_ctb02m06[arr_aux].* to s_ctb02m06[scr_aux].*
           let ws.operacao = " "
           
     end input
     
     # FAZ BATIMENTO E ATUALIZA SITUACAO DA O.P.
     #------------------------------------------
     if int_flag
        then
        call ctb02m09(param.socopgnum, ws.lcvcod_op, ws.aviestcod_op,
                      ws.segnumdig)
        exit while
     end if
     
 end while

 let int_flag = false
 close window w_ctb02m06

end function  ###  ctb02m06

#--------------------------------------------------------------------
function cabec_ctb02m06()
#--------------------------------------------------------------------

 select socopgsitcod
   into d_ctb02m06.socopgsitcod
   from dbsmopg
  where socopgnum = d_ctb02m06.socopgnum

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da O.P. durante montagem do cabecalho!"
    return
 end if

 select cpodes
   into d_ctb02m06.socopgsitdes
   from iddkdominio
  where cponom = "socopgsitcod"   and
        cpocod = d_ctb02m06.socopgsitcod

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da situacao!"
    return
 end IF

 display by name d_ctb02m06.socopgnum
 display by name d_ctb02m06.socopgsitcod
 display by name d_ctb02m06.socopgsitdes
 display by name d_ctb02m06.empresa  attribute (reverse)        #PSI 205206

end function  ###  cabec_ctb02m06

#-----------------------------------#
 function ctb02m06_condicoes(param)
#-----------------------------------#

 define param        record
    atdsrvnum        like datmservico.atdsrvnum  ,
    atdsrvano        like datmservico.atdsrvano  ,
    avivclgrp        like datkavisveic.avivclgrp ,
    avialgmtv        like datmavisrent.avialgmtv ,
    avioccdat        like datmavisrent.avioccdat
 end record

 define ws           record
    saldo            smallint  ,
    limite           smallint  ,
    condicao         char (25) ,
    clscod           like abbmclaus.clscod      ,
    viginc           like abbmclaus.viginc      ,
    vigfnl           like abbmclaus.vigfnl      ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    atddat           like datmservico.atddat    ,
    datasaldo        date                       ,
    ciaempcod        like datmservico.ciaempcod ,
    temcls           smallint,
    c24astcod        like datmligacao.c24astcod
 end record

 initialize ws.*   to null

 whenever error continue
 select succod, aplnumdig, itmnumdig, atddat, datmservico.ciaempcod,
        datmligacao.c24astcod
   into ws.succod   , ws.aplnumdig,
        ws.itmnumdig, ws.atddat, ws.ciaempcod, ws.c24astcod
   from datmservico, datrservapol, datmligacao
  where datmservico.atdsrvnum  = param.atdsrvnum
    and datmservico.atdsrvano  = param.atdsrvano
    and datrservapol.atdsrvnum = datmservico.atdsrvnum
    and datrservapol.atdsrvano = datmservico.atdsrvano
    and datmligacao.atdsrvano = datmservico.atdsrvano
    and datmligacao.atdsrvnum = datmservico.atdsrvnum
    and datmligacao.c24astcod not in ("ALT", "CON", "CAN","RET", "REC")
 whenever error stop
 
 if sqlca.sqlcode <> 0  then
    return ws.condicao, ws.clscod, ws.saldo
 end if

#-----------------------------------------------------------
# Verifica existencia da clausula Carro Extra
#-----------------------------------------------------------
 let ws.datasaldo = ws.atddat
 if param.avialgmtv  =  1   then
    let ws.datasaldo = param.avioccdat
 end if
 
 case ws.ciaempcod 
    when 35
       call cts44g01_claus_azul(ws.succod,
                                531      ,
                                ws.aplnumdig,
                                ws.itmnumdig)
        returning ws.temcls, ws.clscod
    when 84
       
    
    otherwise
       call ctx01g01_claus(ws.succod,               
                           ws.aplnumdig,            
                           ws.itmnumdig,            
                           ws.datasaldo,            
                           true)                    
           returning ws.clscod, ws.viginc, ws.vigfnl      
 end case
       
 if param.avialgmtv  =  1   and
    ws.clscod  is not null  then
    if ws.clscod[1,2] = "26"  or
       ws.clscod[1,2] = "80"  then
       let ws.condicao = "CLAUSULA ", ws.clscod
    end if
 else
    if param.avialgmtv = 1    then
#    or param.avialgmtv = 2 #PSI207373
       if param.avivclgrp = "A"  then
          let ws.condicao  = "1a. GRATUITA"
       end if
    end if
 end if

 if ws.clscod[1,2] = "26"  or
    ws.clscod[1,2] = "80"  or
    ws.clscod[1,2] = "58"  then  # Azul Seguros
    call ctx01g00_saldo_novo(ws.succod      ,
                        ws.aplnumdig   ,
                        ws.itmnumdig   ,
                        " "            ,
                        " "            ,
                        " "            ,
                        2              ,
                        g_privez       ,
                        ws.ciaempcod,
                        param.avialgmtv,
                        ws.c24astcod)
              returning ws.limite, ws.saldo

    if g_privez = true  then
       let g_privez = false
    end if

    if ws.saldo > 0  then
    else
       let ws.condicao  = "1a. GRATUITA"
       initialize ws.saldo to null
    end if
 end if

 return ws.condicao, ws.clscod, ws.saldo

end function  ###  ctb02m06_condicoes,





#-----------------------------------
function ctb02m06_motivo(param)
#-----------------------------------

 define param record
    avialgmtv   like datmavisrent.avialgmtv,
    ciaempcod   like datmservico.ciaempcod
 end record
 
 define lr_retorno record
    motivo          like iddkdominio.cpodes,   
    avialgmtv       like iddkdominio.cponom
 end record
 
 let lr_retorno.motivo = null 
 
 case param.ciaempcod
    when 84
       whenever error continue 
          select itarsrcaomtvdes
            into lr_retorno.motivo     																																															
          from datkitarsrcaomtv 
           where itarsrcaomtvcod = param.avialgmtv
           
          if sqlca.sqlcode <> 0 then
             let lr_retorno.motivo= "NAO CADASTRADO"       
          end if 
       whenever error stop  
       
    otherwise 
       whenever error continue 
          select cpodes
            into lr_retorno.avialgmtv      																																															
          from iddkdominio 
           where cpocod = param.ciaempcod  
             and cponom = 'avialgmtv_empresa'
          
          if sqlca.sqlcode <> 0 then
             let lr_retorno.avialgmtv = 'avialgmtv'       
          end if 
       whenever error stop  
        	
        																																															
       whenever error continue 
        select cpodes
          into lr_retorno.motivo      																																															
          from iddkdominio 
         where cpocod = param.avialgmtv  
           and cponom = lr_retorno.avialgmtv
       whenever error stop   
    
 end case
 
 if lr_retorno.motivo is null or lr_retorno.motivo = " " then
     
     whenever error continue 
        select cpodes
          into lr_retorno.motivo      																																															
          from datkdominio 
         where cpocod = param.avialgmtv  
           and cponom = lr_retorno.avialgmtv 
       whenever error stop 
     
     if lr_retorno.motivo is null or lr_retorno.motivo = " " then
       let lr_retorno.motivo = "NAO CADASTRADO" 
     end if
 end if 
 
return lr_retorno.motivo 

end function

#-----------------------------------
function ctb02m06_valida(param)
#-----------------------------------

 define param record
    avialgmtv   like datmavisrent.avialgmtv,
    slccctcod   like datmavisrent.slccctcod
 end record
 
 define lr_retorno record
    confirma   char (1)
 end record
 
 initialize lr_retorno.* to null
 
 
 case param.avialgmtv
    when 5
        if param.slccctcod is null or
           param.slccctcod = 0     then
           call cts08g01("A","N",
                         "NAO CONSTA CODIGO DO CENTRO DE CUSTO",
                         "PARA ESTA RESERVA POR DEPARTAMENTO.",
                         " ","FAVOR VERIFICAR!")
           returning lr_retorno.confirma
        end if
    otherwise
        let lr_retorno.confirma = 'S'           
 end case
  
return lr_retorno.confirma 

end function
