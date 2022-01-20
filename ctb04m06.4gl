#############################################################################
# Nome de Modulo: CTB04m06                                         Wagner   #
#                                                                           #
# Manutencao dos itens da ordem de pagamento de RE                 Nov/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/01/2002  CORREIO      Wagner       Solicitacao do Milton para deixar o #
#                                       valor do servico fixo em R$ 40,00   #
#                                       ate que ele defina uma politica de  #
#                                       precos para os servicos praticados. #
#---------------------------------------------------------------------------#
# 22/01/2002  CORREIO      Wagner       Solicitacao do Milton para reabili- #
#                                       tar a pesquisa do 1o.,2o.,3o. etc   #
#                                       servicos realizados.                #
#---------------------------------------------------------------------------#
# 08/03/2002  PSI 14295-6  Wagner       Tratamento para valores adicionais  #
#---------------------------------------------------------------------------#
# 01/04/2002  PSI 15053-3  Wagner       Tratamento para valores adicionais  #
#                                       para nova tabela abril/2002.        #
#---------------------------------------------------------------------------#
# 15/07/2002  PSI 15620-5  Wagner       Acionamento tabela precos RE.       #
#---------------------------------------------------------------------------#
# 11/09/2002  PSI 15918-2  Wagner       Alerta para pagto de RET p/srv RE   #
#---------------------------------------------------------------------------#
# 19/08/2003  PSI 172332   Ale Souza    Critica automatica  por numero de   #
#             OSF 24740                 Nota Fiscal.                        #
#############################################################################
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Raji                             OSF : 30155            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 15/12/2003       #
#  Objetivo       : Substituir o codigo de pesquisa de bloqueio de servico  #
#---------------------------------------------------------------------------#
# 11/05/2004 OSF 35050  -  JUNIOR(FSW)  Projeto D+1 (MDS)                   #
#                                                                           #
#---------------------------------------------------------------------------#
# 12/12/2006 Priscila Staingel  PSI205206  Validar que todos os itens da OP #
#                                          sao da mesma empresa             #
#---------------------------------------------------------------------------#
# 14/06/2007 Eduardo Vieira     PSI207233  Chamada da tela de rateio        #
#                                          apenas para os assuntos          #
#                                          pertinentes                      #
#---------------------------------------------------------------------------#
# 08/08/2007 Sergio Burini      PSI211001  Inclusão de Adicional Noturno,   #
#                                          Feriado e Domingo                #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
# 02/06/2006  CT 697796    Adriano  Trava para não duplicar item em outra OP#
# 16/06/2009  PSI 198404 Fabio Costa    Limitar uma nota fiscal por OP      #
# 27/07/2009  PSI 198404 Fabio Costa    Array de itens para 1500 servicos   #
# 26/04/2010  PSI 198404 Fabio Costa    Tratar empresa da OP                #
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                       de mais de duas casas decimais.     #
#############################################################################

#database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define d_ctb04m06  record
   socopgnum       like dbsmopg.socopgnum,
   socopgsitcod    like dbsmopg.socopgsitcod,
   socopgsitdes    char(30),
   empresa         char(5)              #PSI 205206
end record

#--------------------------------------------------------------------
function ctb04m06(param)
#--------------------------------------------------------------------
  define param       record
         socopgnum       like dbsmopgitm.socopgnum
  end record

  define a_ctb04m06  array[1500] of record
     nfsnum          like dbsmopgitm.nfsnum,
     atdsrvorg       like datmservico.atdsrvorg,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     socopgdscvlr    like dbsmopgitm.socopgitmvlr,
     socconlibflg    like dbsmopgitm.socconlibflg,
     socopgitmnum    like dbsmopgitm.socopgitmnum
  end record

  define ws          record
     confirma        char (01),
     incitmok        char (01),   #-> incluiu item na tela de custo (s/n)
     checktab        char (01),   #-> checa valores c/ a tarifa (s/n)
     relcusto        char (01),   #-> informa relacao de custos (s/n)
     count           dec (5,0),
     operacao        char (01),
     erro            char (01),
     canpgtcod       dec  (1,0),
     difcanhor       datetime hour to minute,
     linhamsg        char (40),
     pstcoddig       like dbsmopg.pstcoddig,
     pestip          like dbsmopg.pestip,
     cgccpfnumop     like dbsmopg.cgccpfnum,
     cgcordop        like dbsmopg.cgcord,
     cgccpfdigop     like dbsmopg.cgccpfdig,
     soctip          like dbsmopg.soctip,
     cgccpfnumos     like dbsmopg.cgccpfnum,
     cgcordos        like dbsmopg.cgcord,
     soctrfcod       like dbsmopg.soctrfcod,
     socfatrelqtd    like dbsmopg.socfatrelqtd,
     socpgtdoctip    like dbsmopg.socpgtdoctip,
     socopgorgcod    like dbsmopg.socopgorgcod,
     socopgitmnum    like dbsmopgitm.socopgitmnum,
     vlrfxacod       like dbsmopgitm.vlrfxacod,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     atdsrvnumant    like dbsmopgitm.atdsrvnum,
     atdsrvanoant    like dbsmopgitm.atdsrvano,
     atddat          like datmservico.atddat,
     atdsrvorg       like datmservico.atdsrvorg,
     pgtdat          like datmservico.pgtdat,
     atdprscod       like datmservico.atdprscod,
     atdcstvlr       like datmservico.atdcstvlr,
     atdfnlflg       like datmservico.atdfnlflg,
     srvprlflg       like datmservico.srvprlflg,
     atdvclsgl_acn   like datkveiculo.atdvclsgl,
     socgtfcod_acn   like dbstgtfcst.socgtfcod ,
     vcldes_acn      char (80),
     socopgnum       like dbsmopgitm.socopgnum,
     socopgitmprx    like dbsmopgitm.socopgitmnum,
     socgtfcod       like dbstgtfcst.socgtfcod,
     soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
     socgtfcstvlr    like dbstgtfcst.socgtfcstvlr,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     atdetpcod       like datmsrvacp.atdetpcod,
     comando         char (400),
     nfsnum          like dbsmopgitm.nfsnum,
     c24evtcod       like datkevt.c24evtcod,
     c24evtcod_svl   like datkevt.c24evtcod,
     c24evtrdzdes    like datkevt.c24evtrdzdes,
     c24fsecod       like datkfse.c24fsecod,
     c24fsecod_svl   like datkfse.c24fsecod,
     c24fsedes       like datkfse.c24fsedes,
     cadmat          like datmsrvanlhst.cadmat,
     cadmat_svl      like datmsrvanlhst.cadmat,
     caddat          like datmsrvanlhst.caddat,
     caddat_svl      like datmsrvanlhst.caddat,
     totanl          integer,
     funnom          char (25),
     msg1            char (40),
     msg2            char (40),
     msg3            char (40),
     msg4            char (40),
     vcldes          char (80),
     flgnf           smallint,
     refatdsrvnum    like datmassistpassag.refatdsrvnum,
     refatdsrvano    like datmassistpassag.refatdsrvano,
     atdsrvorg_ast   like datmservico.atdsrvorg,
     socopgnum_ast   like dbsmopg.socopgnum,
     socopgsitcod_ast like dbsmopg.socopgsitcod,
     socntzdes       like datksocntz.socntzdes,
     socntzcod       like datmsrvre.socntzcod,
     totcstvlr       like datmservico.atdcstvlr,
     vlrsugerido     like dbsmopgitm.socopgitmvlr,
     vlrmaximo       like dbsmopgitm.socopgitmvlr,
     vlrdiferenc     like dbsksrvrmeprc.srvrmedifvlr,
     vlrmltdesc      like dbsksrvrmeprc.srvrmedscmltvlr,
     nrsrvs          smallint,   # (nro. do servico executado)
     flgtab          smallint,   # (1-tabela 1) (2-tabela 2) (3-sem tabela)
     c24astcod_ret   like datmligacao.c24astcod,
     ciaempcod       like datmservico.ciaempcod,     #PSI 205206
     ciaempcodOP     like datmservico.ciaempcod,     #PSI 205206
     srvrmedifvlr    like dbsksrvrmeprc.srvrmedifvlr,
     segnumdig       like dbsmopg.segnumdig,
     opgempcod       like dbsmopg.empcod
  end record

  define arr_aux     smallint
  define scr_aux     smallint
  define ws_flgsub   smallint
  define l_ret       char(01)
        ,l_nfsnum    like dbsmopgitm.nfsnum
        ,l_mensagem  char(50)   #PSI205206

  define m_pgttipcodps like dbscadtippgt.pgttipcodps ##PSI207233
  define m_c24astcod   like datmligacao.c24astcod    ##PSI207233

  ########## BURINI - Projeto SAPS - Nova cobrança #########
  define lr_retSAPS record
      errcod smallint,
      errmsg char(100),
      fnlvlr like dbsmsrvacr.fnlvlr
  end record

  initialize a_ctb04m06    to null
  initialize d_ctb04m06.*  to null
  initialize ws.*          to null
  initialize lr_retSAPS.*  to null
  let  l_ret    = null
  let  l_nfsnum = null

  let ws.comando = "select socopgitmcst     ",
                   "  from dbsmopgcst       ",
                   " where socopgnum    = ? ",
                   "   and socopgitmnum = ? "
  prepare sel_opgcst    from   ws.comando
  declare c_ctb04m06cst cursor for sel_opgcst

  let ws.comando = "select atdsrvorg, ciaempcod ",   #PSI 205206
                   "  from datmservico   ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
  prepare sel_srvorg    from   ws.comando
  declare c_ctb04m06srv cursor for sel_srvorg

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

##PSI207233
  let ws.comando = "select pgttipcodps from dbscadtippgt",
                   "   where nrosrv = ?",
                   "   and   anosrv = ?"

  prepare sel_dbscadtippgt from ws.comando
  declare c_dbscadtippgt cursor for sel_dbscadtippgt

  let ws.comando = "select datmligacao.c24astcod ",
                   "from datmligacao ",
                   "where datmligacao.atdsrvnum = ?",
                   "and datmligacao.atdsrvano = ?"

  prepare sel_datmligacao from ws.comando
  declare c_datmligacao cursor for sel_datmligacao


  ##PSI207233
  open window w_ctb04m06 at 06,02 with form "ctb04m06"
       attribute(form line first, comment line last - 1)

  let arr_aux = 1
  let d_ctb04m06.socopgnum = param.socopgnum

  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  select pstcoddig   , pestip,
         cgccpfnum   , cgcord,
         cgccpfdig   , soctrfcod,
         socfatrelqtd, socpgtdoctip,
         socopgorgcod, soctip,
         segnumdig   , empcod
    into ws.pstcoddig   , ws.pestip,
         ws.cgccpfnumop , ws.cgcordop,
         ws.cgccpfdigop , ws.soctrfcod,
         ws.socfatrelqtd, ws.socpgtdoctip,
         ws.socopgorgcod, ws.soctip,
         ws.segnumdig   , ws.opgempcod
    from dbsmopg
   where socopgnum = param.socopgnum

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura da ordem de pagamento!"
     return
  end if

  if ws.socopgorgcod = 2 then
     let ws.socfatrelqtd = 1  # provisorio para abilitar alteracao
  end if

  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctb04m06  cursor for
    select dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
           dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
           dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum,
           sum(dbsmopgcst.socopgitmcst)
      from dbsmopgitm, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum           and
           dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
           dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

     group by dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
              dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
              dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum
     order by dbsmopgitm.socopgitmnum

  foreach c_ctb04m06 into a_ctb04m06[arr_aux].nfsnum,
                          a_ctb04m06[arr_aux].atdsrvnum,
                          a_ctb04m06[arr_aux].atdsrvano,
                          a_ctb04m06[arr_aux].socopgitmvlr,
                          a_ctb04m06[arr_aux].socconlibflg,
                          a_ctb04m06[arr_aux].socopgitmnum,
                          ws.socopgitmcst

     open  c_ctb04m06srv using a_ctb04m06[arr_aux].atdsrvnum,
                               a_ctb04m06[arr_aux].atdsrvano
     fetch c_ctb04m06srv into  a_ctb04m06[arr_aux].atdsrvorg,
                               ws.ciaempcod     #PSI 205206
     close c_ctb04m06srv

     let l_nfsnum = a_ctb04m06[arr_aux].nfsnum

     #PSI 205206
     #se não tem empresa para OP - assumir a empresa do primeiro item
     if ws.ciaempcodOP is null then
        let ws.ciaempcodOP = ws.ciaempcod
     else
        #se tem empresa para OP - verificar se é a mesma
        if ws.ciaempcodOP <> ws.ciaempcod then
           error "Itens da OP não são da mesma empresa!! Por favor altere!! "
           display "Itens da OP não são da mesma empresa!! Por favor altere!!",
                   a_ctb04m06[arr_aux].atdsrvnum, a_ctb04m06[arr_aux].atdsrvano
        end if

        # OP com itens de empresas diferentes da empresa da OP
        if ws.opgempcod != ws.ciaempcod
           then
           error ' Item de OP de empresa diferente, OP: ', ws.opgempcod, ' / Item: ', ws.ciaempcod
        end if
     end if

     let a_ctb04m06[arr_aux].socopgtotvlr = a_ctb04m06[arr_aux].socopgitmvlr

     if ws.socopgitmcst  is not null   then
        let a_ctb04m06[arr_aux].socopgtotvlr =
            a_ctb04m06[arr_aux].socopgtotvlr + ws.socopgitmcst
     end if

     let a_ctb04m06[arr_aux].socopgdscvlr = a_ctb04m06[arr_aux].socopgtotvlr -
                                            a_ctb04m06[arr_aux].socopgitmvlr

     let arr_aux = arr_aux + 1
     if arr_aux > 1500   then
        error " Limite excedido! Ordem de pagamento com mais de 1500 itens!"
        exit foreach
     end if

  end foreach

  #PSI 205206 - se encontrou itens para OP
  # buscar a descricao da empresa da OP
  if arr_aux > 1 then
     call cty14g00_empresa_abv(ws.opgempcod)
          returning l_ret,
                    l_mensagem,
                    d_ctb04m06.empresa
  end if

  message ""
  call set_count(arr_aux-1)
  call cabec_ctb04m06()
  let  ws_flgsub = 0
  if  ws.socopgorgcod is not null and
      ws.socopgorgcod = 2         then  # OP AUTOMATICA
      message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F6)Correcao itens"
  else
      message " (F17)Abandona, (F1)Inclui, (F2)Exclui "
  end if

  while true
     let int_flag = false

     input array a_ctb04m06 without defaults from s_ctb04m06.*
        before row
           let arr_aux = arr_curr()
           let scr_aux = scr_line()
           if arr_aux <= arr_count()  then
              let ws.operacao = "a"
              let ws.atdsrvnumant = a_ctb04m06[arr_aux].atdsrvnum
              let ws.atdsrvanoant = a_ctb04m06[arr_aux].atdsrvano
           end if

           if a_ctb04m06[arr_aux].socopgitmnum  is null   then
              let a_ctb04m06[arr_aux].socconlibflg = "N"
              let a_ctb04m06[arr_aux].socopgitmnum = 0
           end if

        before insert
           options insert key F31

           let ws.operacao = "i"
           initialize a_ctb04m06[arr_aux].*  to null

           let a_ctb04m06[arr_aux].socconlibflg = "N"
           let a_ctb04m06[arr_aux].socopgitmnum = 0

           display a_ctb04m06[arr_aux].* to s_ctb04m06[scr_aux].*

        # PSI 198404 People, uma NF por OP, nao editar nfsnum
        # before field nfsnum
        #    if ws.socopgorgcod is not null and
        #       ws.socopgorgcod = 2         then  # OP AUTOMATICA
        #       if ws.flgnf is  null        or
        #          ws.flgnf = 0             then
        #          next field atdsrvnum
        #       end if
        #    else
        #       if a_ctb04m06[arr_aux].nfsnum  is null then
        #          let a_ctb04m06[arr_aux].nfsnum  = ws.nfsnum
        #          if a_ctb04m06[arr_aux].nfsnum  is not null then
        #             display a_ctb04m06[arr_aux].nfsnum  to
        #                     s_ctb04m06[scr_aux].nfsnum
        #             next field atdsrvnum
        #          end if
        #       end if
        #    end if
        #    display a_ctb04m06[arr_aux].nfsnum    to
        #            s_ctb04m06[scr_aux].nfsnum    attribute (reverse)
        #
        # after field nfsnum
        #    display a_ctb04m06[arr_aux].nfsnum    to
        #            s_ctb04m06[scr_aux].nfsnum
        #
        # # if ws.socopgorgcod is not null and
        # #    ws.socopgorgcod = 2         then  # OP AUTOMATICA
        # # else
        #      if a_ctb04m06[arr_aux].nfsnum  =  0   then
        #         error " Numero da nota fiscal nao deve ser zeros!"
        #         next field nfsnum
        #      end if
        #
        #      if ws.socpgtdoctip  =  1   then   #-> Docto Nota Fiscal
        #         if a_ctb04m06[arr_aux].nfsnum   is null   then
        #            error " Numero da nota fiscal deve ser informado!"
        #            next field nfsnum
        #         end if
        #      end if
        #   # end if
        #
        #   if a_ctb04m06[arr_aux].nfsnum is not null and
        #      a_ctb04m06[arr_aux].nfsnum    <>  0    then
        #
        #      let l_ret    = null
        #      let l_nfsnum = a_ctb04m06[arr_aux].nfsnum
        #
        #      if param.socopgnum is null then
        #         let param.socopgnum = 0
        #      end if
        #
        #      call ctb00g01_vernfs(ws.soctip
        #                          ,ws.pestip
        #                          ,ws.cgccpfnumop
        #                          ,ws.cgcordop
        #                          ,ws.cgccpfdigop
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
        #      if a_ctb04m06[arr_aux].atdsrvnum    is null  or
        #         a_ctb04m06[arr_aux].atdsrvano    is null  or
        #         a_ctb04m06[arr_aux].socopgitmvlr is null  then
        #         error " Dados nao foram completamente preenchidos!"
        #         next field nfsnum
        #      end if
        #   end if
        #
        #   let ws.flgnf = 0


        before field atdsrvnum
           display a_ctb04m06[arr_aux].atdsrvnum  to
                   s_ctb04m06[scr_aux].atdsrvnum  attribute (reverse)

        after field atdsrvnum
           display a_ctb04m06[arr_aux].atdsrvnum  to
                   s_ctb04m06[scr_aux].atdsrvnum

           if fgl_lastkey() = fgl_keyval("down")  then
              next field atdsrvano
           end if

           if a_ctb04m06[arr_aux].atdsrvnum   is null   or
              a_ctb04m06[arr_aux].atdsrvnum   =  0      then
              error " Numero da ordem de servico deve ser informado!"
              next field atdsrvnum
           end if

           if ws.operacao  =  "a"   then
              if a_ctb04m06[arr_aux].atdsrvnum  <>  ws.atdsrvnumant   then
                 error " Numero da ordem de servico nao deve ser alterado!"
                 next field atdsrvnum
              end if
           end if

           if fgl_lastkey() = fgl_keyval("up")    or
              fgl_lastkey() = fgl_keyval("left")  or
              fgl_lastkey() = fgl_keyval("down")  then
              if a_ctb04m06[arr_aux].atdsrvnum    is null  or
                 a_ctb04m06[arr_aux].atdsrvano    is null  or
                 a_ctb04m06[arr_aux].socopgitmvlr is null  then
                 error " Dados nao foram completamente preenchidos!"
                 next field atdsrvnum
              end if
           end if

        before field atdsrvano
           display a_ctb04m06[arr_aux].atdsrvano  to
                   s_ctb04m06[scr_aux].atdsrvano  attribute (reverse)

        after field atdsrvano
           display a_ctb04m06[arr_aux].atdsrvano  to
                   s_ctb04m06[scr_aux].atdsrvano

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field atdsrvnum
           end if

           if a_ctb04m06[arr_aux].atdsrvano is null  then
              error " Ano da ordem de servico deve ser informado!"
              next field atdsrvano
           end if

           if ws.operacao  =  "a"   then
              if a_ctb04m06[arr_aux].atdsrvano  <>  ws.atdsrvanoant   then
                 error " Ano da ordem de servico nao deve ser alterado!"
                 next field atdsrvano
              end if
           end if

           # CHECAGEM DA ORDEM DE SERVICO
           #-----------------------------
           initialize ws.atdfnlflg, ws.atdprscod, ws.atddat    to null
           initialize ws.pgtdat   , ws.atdcstvlr, ws.atdetpcod to null

           select atdfnlflg, atdprscod,
                  atddat   , atdsrvorg,
                  pgtdat   , atdcstvlr,
                  srvprlflg,
                  ciaempcod              #PSI 205206
             into ws.atdfnlflg, ws.atdprscod,
                  ws.atddat   , a_ctb04m06[arr_aux].atdsrvorg,
                  ws.pgtdat   , ws.atdcstvlr,
                  ws.srvprlflg,
                  ws.ciaempcod   #PSI 205206
             from datmservico
            where atdsrvnum = a_ctb04m06[arr_aux].atdsrvnum  and
                  atdsrvano = a_ctb04m06[arr_aux].atdsrvano

           if sqlca.sqlcode  =  notfound   then
              error " Ordem de servico nao cadastrada!"
              next field atdsrvano
           else
              if sqlca.sqlcode <> 0    then
                 error " Erro (",sqlca.sqlcode,") na leitura do servico!"
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

           display a_ctb04m06[arr_aux].atdsrvorg  to
                   s_ctb04m06[scr_aux].atdsrvorg

           if a_ctb04m06[arr_aux].atdsrvorg <>  9  then   ## SOCORRO RE
              error " Somente servicos de Socorro RE (09/...)!"
              next field atdsrvano
           end if

           if ws.srvprlflg = "S"  then
              error " Servico particular deve ser pago pelo cliente!"
              next field atdsrvnum
           end if

           if ws.atdprscod  is null   then
              error " Ordem de servico sem codigo de prestador informado!"
              next field atdsrvano
           end if

           # -- OSF 30155 - Fabrica de Software, Katiucia -- #
           # ---------------------------------------------- #
           # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
           # ---------------------------------------------- #
           call ctb00g01_srvanl ( a_ctb04m06[arr_aux].atdsrvnum
                                 ,a_ctb04m06[arr_aux].atdsrvano
                                 ,"S" )
                returning ws.totanl
                         ,ws.c24evtcod
                         ,ws.c24fsecod

           if ws.totanl > 0 then
              error "Ordem de servico nao pode ser paga, pendencia(s) em "
                   ,"analise!"
              next field atdsrvano
           end if

           ## initialize ws.c24evtcod, ws.caddat, ws.c24fsecod,
           ##            ws.cadmat     to null

           ## declare c_datmsrvanlhst cursor for
           ##  select c24evtcod, caddat
           ##    from datmsrvanlhst
           ##   where atdsrvnum    = a_ctb04m06[arr_aux].atdsrvnum
           ##     and atdsrvano    = a_ctb04m06[arr_aux].atdsrvano
           ##     and c24evtcod    <> 0
           ##     and srvanlhstseq =  1

           ## let ws.totanl = 0   # total de analise do servico

           ## foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

           ##    select c24fsecod, cadmat
           ##      into ws.c24fsecod, ws.cadmat
           ##      from datmsrvanlhst
           ##     where atdsrvnum    = a_ctb04m06[arr_aux].atdsrvnum
           ##       and atdsrvano    = a_ctb04m06[arr_aux].atdsrvano
           ##       and c24evtcod    =  ws.c24evtcod
           ##       and srvanlhstseq = (select max(srvanlhstseq)
           ##                    from datmsrvanlhst
           ##                   where atdsrvnum = a_ctb04m06[arr_aux].atdsrvnum
           ##                     and atdsrvano = a_ctb04m06[arr_aux].atdsrvano
           ##                     and c24evtcod =  ws.c24evtcod)

           ##    if ws.c24fsecod <> 2  and        # 2- ok analisado e pago
           ##       ws.c24fsecod <> 4  then       # 4- nao procede
           ##       if ws.totanl = 0 then
           ##          let ws.totanl = 1
           ##          let ws.c24evtcod_svl = ws.c24evtcod
           ##          let ws.c24fsecod_svl = ws.c24fsecod
           ##          let ws.cadmat_svl    = ws.cadmat
           ##          let ws.caddat_svl    = ws.caddat
           ##       else
           ##          if ws.caddat > ws.caddat_svl then
           ##             let ws.c24evtcod_svl = ws.c24evtcod
           ##             let ws.c24fsecod_svl = ws.c24fsecod
           ##             let ws.cadmat_svl    = ws.cadmat
           ##             let ws.caddat_svl    = ws.caddat
           ##          end if
           ##          let ws.totanl = ws.totanl + 1
           ##       end if
           ##    else
           ##       continue foreach
           ##    end if

           ## end foreach

           ## if ws.totanl > 0   then
           ##    initialize ws.c24evtrdzdes, ws.c24fsedes , ws.msg1,
           ##               ws.msg2        , ws.msg3      , ws.msg4,
           ##               ws.funnom        to null
           ##    select c24evtrdzdes
           ##      into ws.c24evtrdzdes
           ##      from datkevt
           ##     where datkevt.c24evtcod = ws.c24evtcod_svl

           ##    select c24fsedes
           ##      into ws.c24fsedes
           ##      from datkfse
           ##     where datkfse.c24fsecod = ws.c24fsecod_svl

           ##    select funnom
           ##      into ws.funnom
           ##      from isskfunc
           ##     where empcod = 1
           ##       and funmat = ws.cadmat_svl

           ##    let ws.msg1 = "ULT.ANALISE : ",ws.c24evtrdzdes,"."
           ##    let ws.msg2 = "FASE ...... : ",ws.c24fsedes,"."
           ##    let ws.msg3 = "ANALISTA... : ",ws.funnom,"."
           ##    if ws.totanl > 1 then
           ##       let ws.msg4 = "ATENCAO:  EXISTEM ", ws.totanl using "&&"," ANALISES"
           ##    end if

           ##    error " Ordem de servico nao pode ser paga, pendencia(s) em analise !"

           ##    call cts08g01("A","N", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
           ##         returning ws.confirma

           ##    next field atdsrvano
           ## end if

           #------------------------------------------------------------
           # VERIFICA ETAPA DO SERVICO
           #------------------------------------------------------------
           open  c_datmsrvacp using  a_ctb04m06[arr_aux].atdsrvnum,
                                     a_ctb04m06[arr_aux].atdsrvano,
                                     a_ctb04m06[arr_aux].atdsrvnum,
                                     a_ctb04m06[arr_aux].atdsrvano
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

           if ws.atdetpcod = 5  then  # Etapa CANCELADO
              error " Ordem de servico com situacao: CANCELADA!"
              next field atdsrvano
           end if

           if ws.atdetpcod = 6  then  # Etapa EXCLUIDO
              error " Ordem de servico com situacao: EXCLUIDA!"
              next field atdsrvano
           end if

           initialize ws.cgccpfnumos   to null
           initialize ws.cgcordos      to null

           if ws.pstcoddig  is not null       and
              ws.pstcoddig  <> ws.atdprscod   then

              # VERIFICA SE CGC/CPF E' IGUAL (PRESTADOR C/ OUTRA BASE)
              #-------------------------------------------------------
              select cgccpfnum, cgcord
                into ws.cgccpfnumos, ws.cgcordos
                from dpaksocor
               where pstcoddig = ws.atdprscod

              if ws.cgccpfnumop  is null   or
                 ws.cgccpfnumos  is null   then
                 error " Prestador da O.P. diferente do prestador da O.S.!"
                 next field atdsrvano
              end if

              if ws.cgccpfnumop  <>  ws.cgccpfnumos   or
                (ws.cgcordop     is not null          and
                 ws.cgcordop     <>  ws.cgcordos)     then
                 error " Prestador da O.P. diferente do prestador da O.S.!"
                 next field atdsrvano
              end if
           end if

           # VERIFICA SE O.P. JA' FOI PAGA
           #------------------------------
           if ws.operacao  =  "i"   then
              initialize ws.socopgnum   to null
              select dbsmopg.socopgnum, dbsmopgitm.socopgitmnum
                into ws.socopgnum, a_ctb04m06[arr_aux].socopgitmnum
                from dbsmopgitm, dbsmopg
               where dbsmopgitm.atdsrvnum = a_ctb04m06[arr_aux].atdsrvnum and
                     dbsmopgitm.atdsrvano = a_ctb04m06[arr_aux].atdsrvano and
                     dbsmopg.socopgnum    = dbsmopgitm.socopgnum          and
                     dbsmopg.socopgsitcod <> 8

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

              # SERVICOS PAGOS ANTES DA IMPLANTACAO DA O.P.
              #--------------------------------------------
              if ws.pgtdat  is not null    then
                 error " Servico ja' foi pago em ", ws.pgtdat, "!"
                 next field atdsrvano
              end if
           end if

           #----------------------------------
           # Verifica se servico e' RET
           #----------------------------------
           declare c_ret cursor for
            select datmligacao.c24astcod
              from datmligacao
             where datmligacao.atdsrvnum = a_ctb04m06[arr_aux].atdsrvnum
               and datmligacao.atdsrvano = a_ctb04m06[arr_aux].atdsrvano
               and datmligacao.lignum    <> 0

           foreach c_ret into ws.c24astcod_ret
              if ws.c24astcod_ret = "RET"  then
                 call cts08g01("C","S",
                               "","ATENCAO: ESTE SERVICO E' UM (RET)ORNO",
                               "","CONTINUA O SEU PAGAMENTO ?")
                        returning ws.confirma
                 if ws.confirma = "N"  then
                    next field atdsrvano
                 end if
              end if
              exit foreach
           end foreach

           #----------------------------------
           # Verifica servicos multiplos
           #----------------------------------
           call ctb12m12(a_ctb04m06[arr_aux].atdsrvnum,
                         a_ctb04m06[arr_aux].atdsrvano)

           #----------------------------------
           # Valor acertado para o servico
           #----------------------------------
           initialize ws.totcstvlr to null
           if (a_ctb04m06[arr_aux].socopgitmvlr is null  or
               a_ctb04m06[arr_aux].socopgitmvlr = 0    ) and
              (a_ctb04m06[arr_aux].socopgtotvlr is null  or
               a_ctb04m06[arr_aux].socopgtotvlr = 0    ) then
              if ws.atdcstvlr is not null and
                 ws.atdcstvlr <> 0        then
                 select sum(socopgitmcst)
                   into ws.totcstvlr
                   from dbsmopgcst
                   where socopgnum    = a_ctb04m06[arr_aux].atdsrvnum
                     and socopgitmnum = a_ctb04m06[arr_aux].atdsrvano
                     and atdsrvnum    = a_ctb04m06[arr_aux].atdsrvnum
                     and atdsrvano    = a_ctb04m06[arr_aux].atdsrvano

                 if ws.totcstvlr is  null  then
                    let ws.totcstvlr = 0
                 end if

                 let a_ctb04m06[arr_aux].socopgitmvlr =  ws.atdcstvlr
                                                         - ws.totcstvlr
                 let a_ctb04m06[arr_aux].socopgtotvlr =  ws.atdcstvlr
                 display a_ctb04m06[arr_aux].socopgitmvlr  to
                         s_ctb04m06[scr_aux].socopgitmvlr
                 display a_ctb04m06[arr_aux].socopgtotvlr  to
                         s_ctb04m06[scr_aux].socopgtotvlr
              end if
           end if

           #PSI 205206
           #caso é o primeiro item a ser vinculado a OP
           # e ainda nao buscamos o nome da empresa
           if d_ctb04m06.empresa is null then
               call cty14g00_empresa_abv(ws.opgempcod)
                    returning l_ret,
                              l_mensagem,
                              d_ctb04m06.empresa
               display by name d_ctb04m06.empresa attribute (reverse)
            end if

        before field socopgitmvlr

           display "ws.ciaempcod = ", ws.ciaempcod
           display "ws.opgempcod = ", ws.opgempcod

           ########### BURINI - Projeto SAPS - Nova cobrança #########
           if  a_ctb04m06[arr_aux].socopgitmvlr is null then

               if  ws.opgempcod = 43 then
                   #if  ws.socgtfcstvlr is null then
                       call ctb11m06_busca_valor_saps(a_ctb04m06[arr_aux].atdsrvnum,
                                                      a_ctb04m06[arr_aux].atdsrvano)
                            returning lr_retSAPS.errcod,
                                      lr_retSAPS.errmsg,
                                      lr_retSAPS.fnlvlr

                            display "RETORNO DA FUNÇÃO DO SAPS"
                            display "lr_retspas.errcod = ", lr_retSAPS.errcod
                            display "lr_retspas.errmsg = ", lr_retSAPS.errmsg
                            display "lr_retspas.fnlvlr = ", lr_retSAPS.fnlvlr

                            if  lr_retSAPS.errcod = 0 then
                                let a_ctb04m06[arr_aux].socopgitmvlr = lr_retSAPS.fnlvlr

                            else
                                error lr_retSAPS.errmsg
                                next field atdsrvnum
                            end if

                   #end if
               else # DEMAIS EMPRESAS FLUXOS NORMAIS
                   #-------------------------------------------
                   # CONSISTENCIA DE dos valores
                   #-------------------------------------------
                   call ctx15g00_vlrre(a_ctb04m06[arr_aux].atdsrvnum,
                                       a_ctb04m06[arr_aux].atdsrvano)
                             returning ws.socntzcod, ws.vlrsugerido,
                                       ws.vlrmaximo, ws.vlrdiferenc,
                                       ws.vlrmltdesc,ws.nrsrvs, ws.flgtab

                   if a_ctb04m06[arr_aux].socopgitmvlr is null or
                      a_ctb04m06[arr_aux].socopgitmvlr = 0     then
                      let a_ctb04m06[arr_aux].socopgitmvlr = ws.vlrsugerido
                   end if
               end if
           end if
           ###########################################################

           let a_ctb04m06[arr_aux].socopgitmvlr = a_ctb04m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"
           display a_ctb04m06[arr_aux].socopgitmvlr  to
                   s_ctb04m06[scr_aux].socopgitmvlr  attribute (reverse)

        after field socopgitmvlr
           display a_ctb04m06[arr_aux].socopgitmvlr  to
                   s_ctb04m06[scr_aux].socopgitmvlr

           ########### BURINI - Projeto SAPS - Nova cobrança #########
           #if  ws.ciaempcod <> 43 then

               if fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field atdsrvano
               end if

               if a_ctb04m06[arr_aux].socopgitmvlr   is null   then
                  error " Valor inicial da ordem de servico deve ser informado!"
                  next field socopgitmvlr
               end if

               if a_ctb04m06[arr_aux].socopgitmvlr  >  ws.vlrsugerido then
                  select datksocntz.socntzdes
                    into ws.socntzdes
                    from datksocntz
                   where datksocntz.socntzcod = ws.socntzcod

                  initialize ws.msg1, ws.msg2, ws.msg3 to null
                  let ws.msg1  =  "SERVICO DE NATUREZA ",ws.socntzdes
                  let ws.msg2  =  "VALOR TABELA DO SERVICO DE R$ ",
                                  ws.vlrsugerido using "<<<&.&&"
                  case ws.flgtab
                     when  1
                        case ws.nrsrvs
                           when  1
                             let ws.msg3 = "1o. SERVICO! VALOR TABELA SEM DESCONTO"
                           otherwise
                             let ws.msg3 = ws.nrsrvs using "#&","o. SERVICO! JA' DESCONTADO R$ ",
                                           ws.vlrmltdesc using "<<<&.&&"
                        end case
                     when  2
                       let ws.msg3 = "ATENCAO PRESTADOR SEM TABELA!"
                  end case
                  call cts08g01("C","S", ws.msg1, ws.msg2, ws.msg3,
                                            "CONFIRMA PAGAMENTO ?")
                          returning ws.confirma

                  if ws.confirma = "N"  then
                     next field socopgitmvlr
                  end if

                  let a_ctb04m06[arr_aux].socconlibflg = "S"
                  display by name a_ctb04m06[arr_aux].socconlibflg
               end if

               #----------------------------------------
               #   SE PRESTADOR UTILIZA RELACAO, ABRE
               # TELA PARA DISCRIMINAR CUSTO DO SERVICO
               #----------------------------------------
               let ws.vlrfxacod = 2

               ### verificar o valor, para não ter mais de duas casas depois da virgula - Beatriz Araujo
               let a_ctb04m06[arr_aux].socopgitmvlr = a_ctb04m06[arr_aux].socopgitmvlr using "&&,&&&,&&&,&&&.&&"
               ### fim

               call ctb04m07(param.socopgnum,
                             ws.operacao,
                             a_ctb04m06[arr_aux].nfsnum,
                             a_ctb04m06[arr_aux].atdsrvnum,
                             a_ctb04m06[arr_aux].atdsrvano,
                             ws.vlrfxacod,
                             a_ctb04m06[arr_aux].socopgitmvlr,
                             a_ctb04m06[arr_aux].socconlibflg,
                             a_ctb04m06[arr_aux].socopgitmnum,
                             ws.soctrfvignum,
                             ws.socgtfcod,
                             "n")      #   ws.checktab)
                   returning a_ctb04m06[arr_aux].nfsnum,
                             a_ctb04m06[arr_aux].atdsrvnum,
                             a_ctb04m06[arr_aux].atdsrvano,
                             ws.vlrfxacod,
                             a_ctb04m06[arr_aux].socopgitmvlr,
                             a_ctb04m06[arr_aux].socopgitmnum,
                             a_ctb04m06[arr_aux].socopgtotvlr,
                             a_ctb04m06[arr_aux].socconlibflg,
                             ws.incitmok,
                             a_ctb04m06[arr_aux].socopgdscvlr
                             #WWWXX
               display by name a_ctb04m06[arr_aux].socconlibflg

               ### OSF35050        // Chamar a tela de rateio PS //
               ##PSI207233
               open c_datmligacao using   a_ctb04m06[arr_aux].atdsrvnum,
                                          a_ctb04m06[arr_aux].atdsrvano
                   fetch c_datmligacao into m_c24astcod
               close c_datmligacao
               if m_c24astcod = "S11" or
                  m_c24astcod = "S14"  or
                  m_c24astcod = "S53"  or
                  m_c24astcod = "S64"  then
                     open c_dbscadtippgt using a_ctb04m06[arr_aux].atdsrvnum,
                                               a_ctb04m06[arr_aux].atdsrvano
                         fetch c_dbscadtippgt into m_pgttipcodps
                     close c_dbscadtippgt
                     if m_pgttipcodps = 3 then
                        call ctb04m12(a_ctb04m06[arr_aux].atdsrvorg,
                                      a_ctb04m06[arr_aux].atdsrvnum,
                                      a_ctb04m06[arr_aux].atdsrvano,
                                      a_ctb04m06[arr_aux].socopgtotvlr)
                     end if
               else
               call ctb04m12(a_ctb04m06[arr_aux].atdsrvorg,
                             a_ctb04m06[arr_aux].atdsrvnum,
                             a_ctb04m06[arr_aux].atdsrvano,
                             a_ctb04m06[arr_aux].socopgtotvlr)
               end if

               ##PSI207233
               # QUANDO A INCLUSAO FOR OK, ALTERAR OPERACAO
               # PARA "a", PARA NAO INSERIR NO  AFTER ROW
               # ------------------------------------------
               if ws.operacao = "i"  then
                  if ws.incitmok = "s"   then
                     let ws.operacao = "a"
                  else
                     let ws.incitmok = "s"
                     #WWW begin work
                     #WWW delete from dbsmopgcst
                     #WWW  where socopgnum    = param.socopgnum
                     #WWW    and socopgitmnum = a_ctb04m06[arr_aux].socopgitmnum
                     #WWW commit work
                  end if
               end if
               call cabec_ctb04m06()

               #------------------------------------------------
               # NAO INFORMOU CUSTOS TOTAL GERAL = VALOR INICIAL
               #------------------------------------------------
               select sum(dbsmopgcst.socopgitmcst)
                 into ws.socopgitmcst
                 from dbsmopgcst
                where dbsmopgcst.socopgnum    = param.socopgnum
                  and dbsmopgcst.socopgitmnum = a_ctb04m06[arr_aux].socopgitmnum
               if sqlca.sqlcode = notfound then
                  let ws.socopgitmcst = 0
               end if

               let a_ctb04m06[arr_aux].socopgtotvlr = a_ctb04m06[arr_aux].socopgitmvlr

               if ws.socopgitmcst  is not null   then
                  let a_ctb04m06[arr_aux].socopgtotvlr =
                      a_ctb04m06[arr_aux].socopgtotvlr + ws.socopgitmcst
               end if

               display a_ctb04m06[arr_aux].*  to  s_ctb04m06[scr_aux].*

               if a_ctb04m06[arr_aux].socopgtotvlr <= 0 then
                  error " Valor total do servico nao pode ser menor ou igual a zero!"
                  next field socopgitmvlr
               end if
           #else
           #    display "a_ctb04m06[arr_aux].socopgitmvlr = ", a_ctb04m06[arr_aux].socopgitmvlr
           #    display "lr_retSAPS.fnlvlr                = ", lr_retSAPS.fnlvlr
           #
           #    # VALOR DO SERVIÇO SAPS NAO PODERÁ SER ALTERADO
           #    if  a_ctb04m06[arr_aux].socopgitmvlr <> lr_retSAPS.fnlvlr then
           #        error 'Valor do serviço SAPS nao pode ser alterado.'
           #        let a_ctb04m06[arr_aux].socopgtotvlr = lr_retSAPS.fnlvlr
           #        next field socopgitmvlr
           #    end if
           #end if

        on key(interrupt)
           exit input

        before delete
           let ws.operacao = "d"
           if a_ctb04m06[arr_aux].socopgitmnum   is null   or
              a_ctb04m06[arr_aux].socopgitmnum   =  0      then
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
                  dbsmopgcst.socopgitmnum = a_ctb04m06[arr_aux].socopgitmnum

           if sqlca.sqlcode <> 100   and
              sqlca.sqlcode <> 0     then
              error "Erro (",sqlca.sqlcode,") na exclusao do custo do item!"
              next field atdsrvnum
           end if

           delete from dbsmopgitm
            where dbsmopgitm.socopgnum    = param.socopgnum      and
                  dbsmopgitm.socopgitmnum = a_ctb04m06[arr_aux].socopgitmnum

           if sqlca.sqlcode <> 0   then
              error "Erro (",sqlca.sqlcode,") na exclusao do item da O.P.!"
              next field atdsrvnum
           end if
           commit work
           #-----------

           initialize a_ctb04m06[arr_aux].* to null
           display a_ctb04m06[arr_aux].* to s_ctb04m06[scr_aux].*

        # PSI 198404 People, digitar NF apenas na OP
        # on key (F5)
        #    call ctb11m15(ws.nfsnum)
        #         returning ws.nfsnum
        #    initialize a_ctb04m06[arr_aux].nfsnum to null
        #
        #    if param.socopgnum is null then
        #       let param.socopgnum = 0
        #    end if
        #
        #    call ctb00g01_vernfs(ws.soctip
        #                        ,ws.pestip
        #                        ,ws.cgccpfnumop
        #                        ,ws.cgcordop
        #                        ,ws.cgccpfdigop
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
           if ws.socopgorgcod is not null and
              ws.socopgorgcod = 2         then  # OP AUTOMATICA
              call cts08g01("C","S","","CORRIGE ITENS ? ","","")
                  returning ws.confirma

              if ws.confirma = "S"  then
                 initialize a_ctb04m06    to null
                 for arr_aux = 1 to 11
                    display a_ctb04m06[arr_aux].* to s_ctb04m06[arr_aux].*
                 end for
                 call set_count(0)
                 let ws.flgnf  = 0
                 let ws_flgsub = 1
                 exit input
              else
                 let ws_flgsub = 0
              end if
           end if


        after row
           options insert key F1

           let a_ctb04m06[arr_aux].nfsnum = l_nfsnum

           #Formatação do campo alterada para atendimento do chamado 100913299
           let a_ctb04m06[arr_aux].socopgitmvlr = a_ctb04m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

           case ws.operacao
              when "i"
                 initialize ws.socopgnum   to null # CT 697796
                 select dbsmopg.socopgnum, dbsmopgitm.socopgitmnum
                   into ws.socopgnum, a_ctb04m06[arr_aux].socopgitmnum
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum = a_ctb04m06[arr_aux].atdsrvnum and
                        dbsmopgitm.atdsrvano = a_ctb04m06[arr_aux].atdsrvano and
                        dbsmopg.socopgnum    = dbsmopgitm.socopgnum and
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
                 let a_ctb04m06[arr_aux].socopgitmnum = ws.socopgitmnum

                 # INCLUI ITEM DA O.P.
                 #--------------------
                 begin work
                 #---------
                 let a_ctb04m06[arr_aux].socopgitmvlr = a_ctb04m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"
                 insert into dbsmopgitm
                             (socopgnum,
                              atdsrvnum,
                              atdsrvano,
                              socopgitmvlr,
                              nfsnum,
                              socopgitmnum,
                              funmat,
                              socconlibflg)
                      values (param.socopgnum,
                              a_ctb04m06[arr_aux].atdsrvnum,
                              a_ctb04m06[arr_aux].atdsrvano,
                              a_ctb04m06[arr_aux].socopgitmvlr,
                              a_ctb04m06[arr_aux].nfsnum,
                              ws.socopgitmnum,
                              g_issk.funmat,
                              a_ctb04m06[arr_aux].socconlibflg)

                 #-----------------------------#
                 # INCLUSAO DA FASE (DIGITADA) #
                 #-----------------------------#

                 # PSI 221074 - BURINI
                 call cts50g00_sel_etapa(param.socopgnum, 3)
                      returning ws.erro , ws.msg1

                 if  ws.erro = 2  then

                     call cts50g00_insere_etapa(param.socopgnum, 3, g_issk.funmat)
                          returning ws.erro , ws.msg1

                     if  ws.erro <> 1 then
                         display ws.msg1
                     end if
                 end if
                 commit work
                 #----------

              when "a"
                 begin work
                 #----------
                 let a_ctb04m06[arr_aux].socopgitmvlr = a_ctb04m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"
                 update dbsmopgitm  set
                             (socopgitmvlr,
                              socconlibflg,
                              nfsnum)
                           = (a_ctb04m06[arr_aux].socopgitmvlr,
                              a_ctb04m06[arr_aux].socconlibflg,
                              a_ctb04m06[arr_aux].nfsnum)
                  where socopgnum    = param.socopgnum                  and
                        socopgitmnum = a_ctb04m06[arr_aux].socopgitmnum

                 #-------------------------------#
                 # ATUALIZACAO DA FASE (DIGITADA)#
                 #-------------------------------#

                 # PSI 221074 - BURINI
                 call cts50g00_atualiza_etapa(param.socopgnum, 3, g_issk.funmat)
                      returning ws.erro, ws.msg1

                 if  ws.erro <> 1 then
                     display ws.msg1
                 end if

                 commit work
                 #-----------
           end case

           display a_ctb04m06[arr_aux].* to s_ctb04m06[scr_aux].*
           let ws.operacao = " "
     end input

     # FAZ BATIMENTO E ATUALIZA SITUACAO DA O.P.
     #------------------------------------------
     if int_flag
        then
        call ctb11m09(param.socopgnum, "ctb04m06", ws.pstcoddig, ws.pestip,
                      ws.segnumdig)
        exit while
     end if

 end while

 let int_flag = false
 close window w_ctb04m06

end function  ###  ctb04m06


#--------------------------------------------------------------------
function cabec_ctb04m06()
#--------------------------------------------------------------------

 select socopgsitcod
   into d_ctb04m06.socopgsitcod
   from dbsmopg
  where socopgnum = d_ctb04m06.socopgnum

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da O.P. durante montagem do cabecalho!"
    return
 end if

 select cpodes
   into d_ctb04m06.socopgsitdes
   from iddkdominio
  where cponom = "socopgsitcod"   and
        cpocod = d_ctb04m06.socopgsitcod

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da situacao!"
    return
 end if

 display by name d_ctb04m06.socopgnum
 display by name d_ctb04m06.socopgsitcod
 display by name d_ctb04m06.socopgsitdes
 display by name d_ctb04m06.empresa  attribute (reverse)        #PSI 205206

end function  ###  cabec_ctb04m06

