#***************************************************************************#
# Nome de Modulo: CTB11M06                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao dos itens da ordem de pagamento                       Dez/1996 #
#***************************************************************************#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Nao permitir pagamento de servicos  #
#                                       atendidos como particular.          #
#---------------------------------------------------------------------------#
# 19/11/1998  PSI 6467-0   Gilberto     Verificar tarifa das ordens de ser- #
#                                       vico atraves do codigo do veiculo   #
#                                       atendido.                           #
#---------------------------------------------------------------------------#
# 19/04/1999  ** ERRO **   Gilberto     Impedir que nao sejam feitas as ve- #
#                                       rificacoes quando for pressionada a #
#                                       tecla SETA P/BAIXO no campo referen-#
#                                       te ao numero do servico (atdsrvnum) #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 06/05/1999  ** ERRO **   Gilberto     Impedir pressionamento da tecla F1  #
#                                       antes de terminar digitacao da linha#
#---------------------------------------------------------------------------#
# 21/05/1999  PSI 8467-0   Wagner       Permitir troca de nr NF a qualquer  #
#                                       momento mediante tecla funcao (F5)  #
#                                       e tambem diferentes natureza opera- #
#                                       cao para a mesma NF.                #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 9428-5   Wagner       Acesso a verificacao com a analise  #
#                                       dos servicos prestados.             #
#---------------------------------------------------------------------------#
# 13/12/1999  PSI 9637-7   Wagner       Permitir o nao preenchimento do Nro #
#                                       da NF quando for OP automatica.     #
#---------------------------------------------------------------------------#
# 10/03/2000  PSI 10246-6  Wagner       Liberar srvs.Ass.Passageiros para   #
#                                       emissao OP.                         #
#---------------------------------------------------------------------------#
# 14/04/2000  PSI 10426-4  Wagner       Verificar mais de um evento em      #
#                                       analise por servico.                #
#---------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 23/08/2000  PSI 11097-3  Wagner       Permitir digitacao tipos assistencia#
#                                       translado e ambulancias             #
#---------------------------------------------------------------------------#
# 10/04/2001  PSI 12759-0  Wagner       Inclusao desconto automatico para   #
#                                       diferenca de valores.               #
#---------------------------------------------------------------------------#
# 14/05/2001  PSI 130064-8 Wagner       Alerta para servicos de TAXI caso   #
#                                       servico de referencia ainda nao pago#
#---------------------------------------------------------------------------#
# 26/06/2001  Correio      Eduardo      Valores acertados.                  #
#---------------------------------------------------------------------------#
# 17/10/2001  PSI 14064-3  Wagner       Tratamento do retorno da funcao     #
#                                       ctb00g00 campo cancod = 4 e 5.      #
#---------------------------------------------------------------------------#
# 09/12/2002  PSI 16393-3  Wagner       Alteracao nos limites dos servicos  #
#---------------------------------------------------------------------------#
# 21/08/2003  PSI 172332   Ale Souza    Critica automatica  por numero de   #
#             OSF 24740                 Nota Fiscal.                        #
#---------------------------------------------------------------------------#
# 22/10/2003  PSI 170585   Teresinha S  Retirar o codigo 4 - chaveiro das   #
#             OSF 25143                 consistencias referente as assis    #
#                                       tencias sem tarifa.                 #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Raji                             OSF : 30155            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 16/12/2003       #
#  Objetivo       : Substituir o codigo de pesquisa de bloqueio de servico  #
#                   pela chamada da funcao de pesquisa ctb00g01_srvanl.     #
#---------------------------------------------------------------------------#
# 07/05/2004 OSF 35050     JUNIOR(FSW)  Projeto D+1 (MDS)                   #
#---------------------------------------------------------------------------#
# 14/10/2010 PGP_2010_00274 Robert lima Foi tratado o problema de inserção  #
#                                       de mais de duas casas decimais.     #
#############################################################################

# .............................................................................#
#                                                                              #
#                           * * * Alteracoes * * *                             #
#                                                                              #
# Data       Autor Fabrica      Origem     Alteracao                           #
# ---------- --------------     ---------- ------------------------------------#
# 13/09/2005 Tiago Solda,Meta   PSI 193925 Incluir campo para contemplar o     #
#                                          horario de atendimento              #
#------------------------------------------------------------------------------#
# 06/10/2005 Cristiane Silva    CT 5101389 Correções do Adicional Noturno      #
#------------------------------------------------------------------------------#
# 07/12/2006 Priscila Staingel  PSI 205206 Validar que todos os itens da OP sao#
#                                          da mesma empresa                    #
#------------------------------------------------------------------------------#
# 14/06/2007 Eduardo Vieira     PSI207233  Chamada da tela de rateio           #
#                                          apenas para os assuntos             #
#                                          pertinentes                         #
#------------------------------------------------------------------------------#
# 08/08/2007 Sergio Burini      PSI211001  Inclusão de Adicional Noturno,      #
#                                          Feriado e Domingo                   #
#------------------------------------------------------------------------------#
# 25/02/2008 Sergio Burini                 Validação "Usa tabela", eliminação  #
#                                          do campo faixa e correção no retorno#
#                                          do valor da tarifa.                 #
#------------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel     #
# 02/06/2006  CT 697796  Adriano       Trava para não duplicar item em outra OP#
# 16/06/2009  PSI 198404 Fabio Costa    Limitar uma nota fiscal por OP         #
# 08/10/2009  PSI 247790   Burini       Adequação de tabelas                   #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define d_ctb11m06  record
   socopgnum       like dbsmopg.socopgnum,
   socopgsitcod    like dbsmopg.socopgsitcod,
   socopgsitdes    char(30),
   empresa         char(5)              #PSI 205206
end record

define m_prepsql smallint

#--------------------------
function ctb11m06_prepare()
#--------------------------
   define l_sql char(1000)

   let l_sql = 'select dbstgtfcst.socgtfcstvlr '
              ,' from dbstgtfcst, dbsrvclgtf, datmservico '
              ,' where dbstgtfcst.soctrfvignum = ? '
              ,' and dbsrvclgtf.vclcoddig  = datmservico.vclcoddig '
              ,' and dbsrvclgtf.socgtfcod  = dbstgtfcst.socgtfcod '
              ,' and dbstgtfcst.soccstcod  = ? '
              ,' and datmservico.atdsrvnum = ? '
              ,' and datmservico.atdsrvano = ? '
   prepare pctb11m06001 from l_sql
   declare cctb11m06001 cursor for pctb11m06001

   let l_sql = 'select atdetpcod, atdetphor '
              ,'  from datmsrvacp '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
              ,'   and atdsrvseq = (select max(atdsrvseq) '
                                  ,'  from datmsrvacp '
                                  ,' where atdsrvnum = ? '
                                  ,'   and atdsrvano = ?) '
   prepare pctb11m06002 from l_sql
   declare cctb11m06002 cursor for pctb11m06002

   let l_sql = 'select socopgsitcod '
              ,'  from dbsmopg '
              ,' where socopgnum = ? '
   prepare pctb11m06003 from l_sql
   declare cctb11m06003 cursor for pctb11m06003

    let l_sql = " select atdprscod ",
                  " from datmservico ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

    prepare pctb11m06004 from l_sql
    declare cctb11m06004 cursor for pctb11m06004

   let m_prepsql = true

##PSI207233
  let l_sql = "select pgttipcodps from dbscadtippgt",
                   "   where nrosrv = ?",
                   "   and   anosrv = ?"

  prepare sel_dbscadtippgt from l_sql
  declare c_dbscadtippgt cursor for sel_dbscadtippgt

  let l_sql = "select datmligacao.c24astcod ",
                   "from datmligacao ",
                   "where datmligacao.atdsrvnum = ?",
                   "and datmligacao.atdsrvano = ?"

  prepare sel_datmligacao from l_sql
  declare c_datmligacao cursor for sel_datmligacao

##PSI207233
end function

#--------------------------------------------------------------------
function ctb11m06(param)
#--------------------------------------------------------------------
  define param       record
     socopgnum       like dbsmopgitm.socopgnum
  end record

  define a_ctb11m06  array[1800] of record
     nfsnum          like dbsmopgitm.nfsnum,
     atdsrvorg       like datmservico.atdsrvorg,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     #BURINI# vlrfxacod       like dbsmopgitm.vlrfxacod,
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
     vclcoddig       like datmservico.vclcoddig,
     socvclcod       like datmservico.socvclcod,
     atdvclsgl_acn   like datkveiculo.atdvclsgl,
     socgtfcod_acn   like dbstgtfcst.socgtfcod ,
     vclcoddig_acn   like datmservico.vclcoddig,
     vcldes_acn      char (80),
     asitipcod       like datmservico.asitipcod,
     cnldat          like datmservico.cnldat,
     atdfnlhor       like datmservico.atdfnlhor,
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
     atdetphor       like datmsrvacp.atdetphor,
     socopgsitcod    like dbsmopg.socopgsitcod,
     srvrmedifvlr     like dbsksrvrmeprc.srvrmedifvlr,
     ciaempcod       like datmservico.ciaempcod,     #PSI 205206
     ciaempcodOP     like datmservico.ciaempcod,     #PSI 205206
     segnumdig       like dbsmopg.segnumdig,
     vlrprm          like dbsksrvrmeprc.srvrmevlr,
     opgempcod       like dbsmopg.empcod
  end record

  define arr_aux       smallint
  define scr_aux       smallint
  define ws_flgsub     smallint
  define l_ret         char(01)
        ,l_param       char(03)
        ,l_nfsnum      like dbsmopgitm.nfsnum
        ,l_mensagem    char(50)   #PSI205206
        ,m_pgttipcodps like dbscadtippgt.pgttipcodps ##PSI207233
        ,m_c24astcod   like datmligacao.c24astcod    ##PSI207233
        ,m_vlrfxacod   smallint
        ,l_vlrtabflg   like dpaksocor.vlrtabflg

  define lr_erro record
      err       smallint,
      msgerr    char(100)
  end record

  ########## BURINI - Projeto SAPS - Nova cobrança #########
  define lr_retSAPS record
      errcod smallint,
      errmsg char(100),
      incvlr like dbsmsrvacr.incvlr
  end record

  if m_prepsql is null or
     m_prepsql <> true then
     call ctb11m06_prepare()
  end if

  initialize a_ctb11m06    to null
  initialize d_ctb11m06.*  to null
  initialize ws.*          to null
  initialize lr_retSAPS.*  to null
  let  l_ret    = null
  let  l_nfsnum = null
  let  m_vlrfxacod = null

  let ws.comando = "select socopgitmcst     ",
                   "  from dbsmopgcst       ",
                   " where socopgnum    = ? ",
                   "   and socopgitmnum = ? "
  prepare sel_opgcst    from   ws.comando
  declare c_ctb11m06cst cursor for sel_opgcst

  let ws.comando = "select atdsrvorg, ciaempcod ",
                   "  from datmservico   ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
  prepare sel_srvorg    from   ws.comando
  declare c_ctb11m06srv cursor for sel_srvorg

  open window w_ctb11m06 at 06,02 with form "ctb11m06"
       attribute(form line first, comment line last - 1)

  let arr_aux = 1
  let d_ctb11m06.socopgnum = param.socopgnum

  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  select pstcoddig   , pestip,
         cgccpfnum   , cgcord,
         cgccpfdig   , socfatrelqtd,
         socpgtdoctip, socopgorgcod,
         soctip      , segnumdig   ,
         empcod
    into ws.pstcoddig   , ws.pestip,
         ws.cgccpfnumop , ws.cgcordop,
         ws.cgccpfdigop , ws.socfatrelqtd,
         ws.socpgtdoctip, ws.socopgorgcod,
         ws.soctip      , ws.segnumdig   ,
         ws.opgempcod
    from dbsmopg
   where socopgnum = param.socopgnum

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura da ordem de pagamento = ", param.socopgnum
     close window w_ctb11m06
     return
  end if

  if ws.socopgorgcod = 2 then
     let ws.socfatrelqtd = 1  # provisorio para abilitar alteracao
  end if

  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctb11m06  cursor for
    select dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
           dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
           dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum,
           #BURINI# dbsmopgitm.vlrfxacod   ,
           sum(dbsmopgcst.socopgitmcst)
      from dbsmopgitm, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum           and
           dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
           dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

     group by dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
              dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
              dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum
              #BURINI# dbsmopgitm.vlrfxacod
     order by dbsmopgitm.socopgitmnum

  foreach c_ctb11m06 into a_ctb11m06[arr_aux].nfsnum,
                          a_ctb11m06[arr_aux].atdsrvnum,
                          a_ctb11m06[arr_aux].atdsrvano,
                          a_ctb11m06[arr_aux].socopgitmvlr,
                          a_ctb11m06[arr_aux].socconlibflg,
                          a_ctb11m06[arr_aux].socopgitmnum,
                          #BURINI# a_ctb11m06[arr_aux].vlrfxacod,
                          ws.socopgitmcst

     select socopgitmcst
       into a_ctb11m06[arr_aux].socopgdscvlr
       from dbsmopgcst
      where dbsmopgcst.socopgnum    = param.socopgnum
        and dbsmopgcst.socopgitmnum = a_ctb11m06[arr_aux].socopgitmnum
        and dbsmopgcst.soccstcod    = 07

     if sqlca.sqlcode = notfound then
        let a_ctb11m06[arr_aux].socopgdscvlr = 0
     end if

     open  c_ctb11m06srv using a_ctb11m06[arr_aux].atdsrvnum,
                               a_ctb11m06[arr_aux].atdsrvano
     fetch c_ctb11m06srv into  a_ctb11m06[arr_aux].atdsrvorg,
                               ws.ciaempcod    #PSI 205206
     close c_ctb11m06srv

     let l_nfsnum = a_ctb11m06[arr_aux].nfsnum

     #PSI 205206
     #se não tem empresa para OP - assumir a empresa do primeiro item
     if ws.ciaempcodOP is null then
        let ws.ciaempcodOP = ws.ciaempcod
     else
        #se tem empresa para OP - verificar se é a mesma
        if ws.ciaempcodOP <> ws.ciaempcod then
           error "Itens da OP não são da mesma empresa!! Por favor altere!! "
           #display "Itens da OP não são da mesma empresa!! Por favor altere!!",
           #       a_ctb11m06[arr_aux].atdsrvnum, a_ctb11m06[arr_aux].atdsrvano
        end if

        # OP com itens de empresas diferentes da empresa da OP
        if ws.opgempcod != ws.ciaempcod
           then
           error ' Item de OP de empresa diferente, OP: ', ws.opgempcod, ' / Item: ', ws.ciaempcod
        end if
     end if

     let a_ctb11m06[arr_aux].socopgtotvlr = a_ctb11m06[arr_aux].socopgitmvlr

     if ws.socopgitmcst  is not null   then
        let a_ctb11m06[arr_aux].socopgtotvlr =
            a_ctb11m06[arr_aux].socopgtotvlr + ws.socopgitmcst
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 1800   then
        error " Limite excedido! Ordem de pagamento com mais de 1800 itens!"
        exit foreach
     end if

  end foreach

  #PSI 205206 - se encontrou itens para OP
  if arr_aux > 1 then
     call cty14g00_empresa(1, ws.opgempcod)
          returning l_ret, l_mensagem, d_ctb11m06.empresa
  end if

  message ""
  call set_count(arr_aux-1)
  call cabec_ctb11m06()
  let  ws_flgsub = 0
  if  ws.socopgorgcod is not null and
      ws.socopgorgcod = 2         then  # OP AUTOMATICA
      message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F6)Correcao itens "
  else
      message " (F17)Abandona, (F1)Inclui, (F2)Exclui "
  end if

  while true
     let int_flag = false

     input array a_ctb11m06 without defaults from s_ctb11m06.*

        before row
           let arr_aux = arr_curr()
           let scr_aux = scr_line()
           if arr_aux <= arr_count()  then
              let ws.operacao = "a"
              let ws.atdsrvnumant = a_ctb11m06[arr_aux].atdsrvnum
              let ws.atdsrvanoant = a_ctb11m06[arr_aux].atdsrvano
           end if

           if a_ctb11m06[arr_aux].socopgitmnum  is null   then
              let a_ctb11m06[arr_aux].socconlibflg = "N"
              let a_ctb11m06[arr_aux].socopgitmnum = 0
           end if

        before insert
           options insert key F31
           let ws.operacao = "i"
           initialize a_ctb11m06[arr_aux].*  to null
           let a_ctb11m06[arr_aux].socconlibflg = "N"
           let a_ctb11m06[arr_aux].socopgitmnum = 0
           display a_ctb11m06[arr_aux].* to s_ctb11m06[scr_aux].*

           # PSI 198404 People, uma NF por OP, nao editar nfsnum
           # before field nfsnum
           #    if ws.socopgorgcod is not null and
           #       ws.socopgorgcod = 2         then  # OP AUTOMATICA
           #       if ws.flgnf is  null        or
           #          ws.flgnf = 0             then
           #          next field atdsrvnum
           #       end if
           #    else
           #       if a_ctb11m06[arr_aux].nfsnum  is null then
           #          let a_ctb11m06[arr_aux].nfsnum  = ws.nfsnum
           #          if a_ctb11m06[arr_aux].nfsnum  is not null then
           #             display a_ctb11m06[arr_aux].nfsnum  to
           #                     s_ctb11m06[scr_aux].nfsnum
           #             next field atdsrvnum
           #          end if
           #       end if
           #    end if
           #    display a_ctb11m06[arr_aux].nfsnum    to
           #            s_ctb11m06[scr_aux].nfsnum    attribute (reverse)

           # after field nfsnum
           #    display a_ctb11m06[arr_aux].nfsnum    to
           #            s_ctb11m06[scr_aux].nfsnum
           #
           #    # if ws.socopgorgcod is not null and
           #    #    ws.socopgorgcod = 2         then  # OP AUTOMATICA
           #    # else
           #       if a_ctb11m06[arr_aux].nfsnum  =  0   then
           #          error " Numero da nota fiscal nao deve ser zeros!"
           #          next field nfsnum
           #       end if
           #
           #       if ws.socpgtdoctip  =  1   then   #-> Docto Nota Fiscal
           #          if a_ctb11m06[arr_aux].nfsnum   is null   then
           #             error " Numero da nota fiscal deve ser informado!"
           #             next field nfsnum
           #          end if
           #       end if
           #    # end if
           #
           #    if a_ctb11m06[arr_aux].nfsnum is not null and
           #       a_ctb11m06[arr_aux].nfsnum    <>  0    then
           #
           #       let l_ret    = null
           #       let l_nfsnum = a_ctb11m06[arr_aux].nfsnum
           #
           #       if param.socopgnum is null then
           #          let param.socopgnum = 0
           #       end if
           #
           #       call ctb00g01_vernfs(ws.soctip
           #                           ,ws.pestip
           #                           ,ws.cgccpfnumop
           #                           ,ws.cgcordop
           #                           ,ws.cgccpfdigop
           #                           ,param.socopgnum
           #                           ,ws.socpgtdoctip
           #                           ,l_nfsnum)
           #          returning l_ret
           #
           #       if l_ret = "S" then
           #          error " Documento duplicado! "
           #          next field nfsnum
           #       end if
           #    end if
           #
           #    if fgl_lastkey() = fgl_keyval("up")    or
           #       fgl_lastkey() = fgl_keyval("left")  or
           #       fgl_lastkey() = fgl_keyval("down")  then
           #       if a_ctb11m06[arr_aux].atdsrvnum    is null  or
           #          a_ctb11m06[arr_aux].atdsrvano    is null  or
           #          a_ctb11m06[arr_aux].socopgitmvlr is null  then
           #          error " Dados nao foram completamente preenchidos!"
           #          next field nfsnum
           #       end if
           #    end if
           #
           #    let ws.flgnf = 0

        before field atdsrvnum

           ########## BURINI - Projeto SAPS - Nova cobrança #########
           initialize lr_retSAPS.* to null

           display a_ctb11m06[arr_aux].atdsrvnum  to
                   s_ctb11m06[scr_aux].atdsrvnum  attribute (reverse)

        after field atdsrvnum
           display a_ctb11m06[arr_aux].atdsrvnum  to
                   s_ctb11m06[scr_aux].atdsrvnum

           if fgl_lastkey() = fgl_keyval("down")  then
              next field atdsrvano
           end if

           if a_ctb11m06[arr_aux].atdsrvnum   is null   or
              a_ctb11m06[arr_aux].atdsrvnum   =  0      then
              error " Numero da ordem de servico deve ser informado!"
              next field atdsrvnum
           end if

           if ws.operacao  =  "a"   then
              if a_ctb11m06[arr_aux].atdsrvnum  <>  ws.atdsrvnumant   then
                 error " Numero da ordem de servico nao deve ser alterado!"
                 next field atdsrvnum
              end if
           end if

           if fgl_lastkey() = fgl_keyval("up")    or
              fgl_lastkey() = fgl_keyval("left")  or
              fgl_lastkey() = fgl_keyval("down")
              then
              if a_ctb11m06[arr_aux].atdsrvnum    is null  or
                 a_ctb11m06[arr_aux].atdsrvano    is null  or
                 a_ctb11m06[arr_aux].socopgitmvlr is null  then
                 error " Dados nao foram completamente preenchidos!"
                 next field atdsrvnum
              end if
           end if

        before field atdsrvano
           display a_ctb11m06[arr_aux].atdsrvano  to
                   s_ctb11m06[scr_aux].atdsrvano  attribute (reverse)

        after field atdsrvano
           display a_ctb11m06[arr_aux].atdsrvano  to
                   s_ctb11m06[scr_aux].atdsrvano

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field atdsrvnum
           end if

           if a_ctb11m06[arr_aux].atdsrvano is null  then
              error " Ano da ordem de servico deve ser informado!"
              next field atdsrvano
           end if

           if ws.operacao  =  "a"   then
              if a_ctb11m06[arr_aux].atdsrvano  <>  ws.atdsrvanoant   then
                 error " Ano da ordem de servico nao deve ser alterado!"
                 next field atdsrvano
              end if
           end if

           # CHECAGEM DA ORDEM DE SERVICO
           #-----------------------------
           initialize ws.atdfnlflg, ws.atdprscod, ws.atddat    to null
           initialize ws.atdsrvorg, ws.pgtdat   , ws.asitipcod to null
           initialize ws.atdcstvlr, ws.cnldat   , ws.atdfnlhor to null
           initialize ws.vclcoddig, ws.atdetpcod, ws.socvclcod to null

           select atdfnlflg, atdprscod,
                  atddat   , atdsrvorg,
                  pgtdat   , asitipcod,
                  atdcstvlr, cnldat   ,
                  atdfnlhor, srvprlflg,
                  vclcoddig, socvclcod,
                  ciaempcod                    #PSI 205206
             into ws.atdfnlflg, ws.atdprscod,
                  ws.atddat   , ws.atdsrvorg,
                  ws.pgtdat   , ws.asitipcod,
                  ws.atdcstvlr, ws.cnldat   ,
                  ws.atdfnlhor, ws.srvprlflg,
                  ws.vclcoddig, ws.socvclcod,
                  ws.ciaempcod   #PSI 205206
             from datmservico
            where atdsrvnum = a_ctb11m06[arr_aux].atdsrvnum
              and atdsrvano = a_ctb11m06[arr_aux].atdsrvano

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

           let a_ctb11m06[arr_aux].atdsrvorg = ws.atdsrvorg
           display a_ctb11m06[arr_aux].atdsrvorg  to
                   s_ctb11m06[scr_aux].atdsrvorg
           # display by name  a_ctb11m06[arr_aux].atdsrvorg

           if ws.srvprlflg = "S"  then
              error " Servico particular deve ser pago pelo cliente!"
              next field atdsrvnum
           end if

           if ws.atdsrvorg = 4 or                          ## REMOCAO
              ws.atdsrvorg = 6 or                          ## DAF
              ws.atdsrvorg = 1 or                          ## SOCORRO
              ws.atdsrvorg = 5 or                          ## RPT
              ws.atdsrvorg = 7 or                          ## REPLACE
              ws.atdsrvorg = 17 or                         ## REPLACE s/docto
              ws.atdsrvorg = 18 or                         ## FUNERAL
             (ws.atdsrvorg = 2 and (ws.asitipcod =  5   or ## TAXI
                                    ws.asitipcod = 10   or ## AVIAO
                                    ws.asitipcod = 11   or ## AMBULANCIA
                                    ws.asitipcod = 12   or ## TRANSLADO
                                    ws.asitipcod = 16)) or ## RODOVIARIO
             (ws.atdsrvorg = 3 and ws.asitipcod = 13) then ## HOSPEDAGEM
           else
              error " Somente: Remoc., Daf, Socor., Rpt, Replace, Taxi, Aviao, Rodov., Hosped., Funeral!"
              next field atdsrvano
           end if

           if ws.atdprscod  is null   then
              error " Ordem de servico sem codigo de prestador informado!"
              next field atdsrvano
           end if

           # -- OSF 30155 - Fabrica de Software, Katiucia -- #
           # ---------------------------------------------- #
           # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
           # ---------------------------------------------- #
           call ctb00g01_srvanl ( a_ctb11m06[arr_aux].atdsrvnum
                                 ,a_ctb11m06[arr_aux].atdsrvano
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
           ##   where atdsrvnum    = a_ctb11m06[arr_aux].atdsrvnum
           ##     and atdsrvano    = a_ctb11m06[arr_aux].atdsrvano
           ##     and c24evtcod    <> 0
           ##     and srvanlhstseq =  1

           ## let ws.totanl = 0   # total de analise do servico

           ## foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

           ##    select c24fsecod, cadmat
           ##      into ws.c24fsecod, ws.cadmat
           ##      from datmsrvanlhst
           ##     where atdsrvnum    = a_ctb11m06[arr_aux].atdsrvnum
           ##       and atdsrvano    = a_ctb11m06[arr_aux].atdsrvano
           ##       and c24evtcod    =  ws.c24evtcod
           ##       and srvanlhstseq = (select max(srvanlhstseq)
           ##                    from datmsrvanlhst
           ##                   where atdsrvnum = a_ctb11m06[arr_aux].atdsrvnum
           ##                     and atdsrvano = a_ctb11m06[arr_aux].atdsrvano
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
           open cctb11m06002 using  a_ctb11m06[arr_aux].atdsrvnum,
                                    a_ctb11m06[arr_aux].atdsrvano,
                                    a_ctb11m06[arr_aux].atdsrvnum,
                                    a_ctb11m06[arr_aux].atdsrvano

           whenever error continue
           fetch cctb11m06002 into ws.atdetpcod
                                  ,ws.atdetphor
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> notfound then
                 error 'Erro SELECT cctb11m06002 / ', sqlca.sqlcode, ' / ',
                       sqlca.sqlerrd[2]
                 sleep 2

                 error 'CTB11M06 / ctb11m06() / ',
                         a_ctb11m06[arr_aux].atdsrvnum, ' / '
                         ,a_ctb11m06[arr_aux].atdsrvano, ' / '
                         ,a_ctb11m06[arr_aux].atdsrvnum, ' / '
                         ,a_ctb11m06[arr_aux].atdsrvano
                 sleep 2

                 exit input
              end if
           end if

           close cctb11m06002

           if ws.atdfnlflg = "N"  then
              error " Ordem de servico nao finalizada nao pode ser paga!"
              next field atdsrvano
           end if

           if ws.atdetpcod = 1  then  # Etapa LIBERADO
              error " Ordem de servico esta' liberada!"
              next field atdsrvano
           end if

           if ws.atdetpcod = 5  then  # Etapa CANCELADO

              # VERIFICA SE PRESTADOR TEM VEICULO CONTROLADO PELO RADIO
              #--------------------------------------------------------
              declare c_datkveiculo  cursor for
                 select pstcoddig
                   from datkveiculo
                  where pstcoddig     =  ws.atdprscod
                    and socctrposflg  =  "S"
                    and socoprsitcod  in (1,2)

              open  c_datkveiculo
              fetch c_datkveiculo
              if sqlca.sqlcode  =  notfound   then
                 error " Ordem de servico com situacao: cancelada!"
                 next field atdsrvano
              end if
              close c_datkveiculo

              if ws.atdsrvorg = 4 or                          # REMOCAO
                 ws.atdsrvorg = 6 or                          # DAF
                 ws.atdsrvorg = 1 or                          # SOCORRO
                 ws.atdsrvorg = 5 or                          # RPT
                 ws.atdsrvorg = 7 or                          # REPLACE
                 ws.atdsrvorg = 17 or                         # REPLACE s/docto
                 ws.atdsrvorg = 18 or                         # FUNERAL
                (ws.atdsrvorg = 2 and (ws.asitipcod =  5   or # TAXI
                                       ws.asitipcod = 10   or # AVIAO
                                       ws.asitipcod = 11   or # AMBULANCIA
                                       ws.asitipcod = 12   or # TRANSLADO
                                       ws.asitipcod = 16)) or # RODOVIARIO
                (ws.atdsrvorg = 3 and ws.asitipcod = 13)      # HOSPEDAGEM
                 then
                 call ctb00g00(a_ctb11m06[arr_aux].atdsrvnum,
                               a_ctb11m06[arr_aux].atdsrvano,
                               ws.cnldat,
                               ws.atdfnlhor)
                     returning ws.canpgtcod, ws.difcanhor
              end if

              if ws.canpgtcod  =  2   then
                 error " Ordem de servico cancelada antes de 30 minutos! (", ws.difcanhor, ")"
                 next field atdsrvano
              end if

              if ws.canpgtcod  =  3   then
                 error " Ordem de servico cancelada / cancelamento nao realizado pelo atendente!"
                 next field atdsrvano
              end if

              if ws.canpgtcod  =  5   then
                 error " Ordem de servico cancelada antes de 10 minutos! (", ws.difcanhor, ")"
                 next field atdsrvano
              end if
           end if

           if ws.atdetpcod = 6  then  # Etapa EXCLUIDO
              error " Ordem de servico com situacao: excluida!"
              next field atdsrvano
           end if

           if ws.atdsrvorg = 2 and ws.asitipcod =  5  then     ## TAXI
              initialize ws.msg1, ws.msg2, ws.msg3,
                         ws.refatdsrvnum, ws.refatdsrvano to null
              select refatdsrvnum   , refatdsrvano
                into ws.refatdsrvnum, ws.refatdsrvano
                from datmassistpassag
               where atdsrvnum  = a_ctb11m06[arr_aux].atdsrvnum
                 and atdsrvano  = a_ctb11m06[arr_aux].atdsrvano

              if ws.refatdsrvnum is null and
                 ws.refatdsrvnum is null then
                 let ws.msg1 = "NAO EXISTE SERVICO RELACIONADO A ESTE"
                 let ws.msg2 = "SERVICO DE TAXI(ASSIST.A PASSAGEIRO)."
              else
                 initialize ws.socopgnum_ast, ws.socopgsitcod_ast,
                            ws.atdsrvorg_ast  to null
                 select datmservico.atdsrvorg
                   into ws.atdsrvorg_ast
                   from datmservico
                  where datmservico.atdsrvnum = ws.refatdsrvnum
                    and datmservico.atdsrvano = ws.refatdsrvano

                 select dbsmopg.socopgnum,
                        dbsmopg.socopgsitcod
                   into ws.socopgnum_ast,
                        ws.socopgsitcod_ast
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum = ws.refatdsrvnum
                    and dbsmopgitm.atdsrvano = ws.refatdsrvano
                    and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
                    and dbsmopg.socopgsitcod <> 8
                 if ws.socopgnum_ast is null then
                    let ws.msg1 = "O SERVICO ",
                                   ws.atdsrvorg_ast using "&&","/",
                                   ws.refatdsrvnum using "&&&&&&&","-",
                                   ws.refatdsrvano using "&&",
                                  " RELACIONADO A"
                    let ws.msg2 = "ESTE SERVICO DE TAXI, NAO SE ENCONTRA"
                    let ws.msg3 = "EM NENHUMA ORDEM DE PAGAMENTO."
                 else
                    let ws.msg1 = "O SERVICO ",
                                   ws.atdsrvorg_ast using "&&","/",
                                   ws.refatdsrvnum using "&&&&&&&","-",
                                   ws.refatdsrvano using "&&",
                                  " RELACIONADO A"
                    let ws.msg2 = "ESTE SERVICO DE TAXI, ENCONTRA-SE"
                    let ws.msg3 = "NA OP. NR. ",
                                   ws.socopgnum_ast using "&&&&&&",
                                   " COM SITUACAO ",
                                   ws.socopgsitcod_ast using "&"
                 end if
              end if
              call cts08g01("A","N"," ",ws.msg1, ws.msg2, ws.msg3)
                   returning ws.confirma
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
                into ws.socopgnum, a_ctb11m06[arr_aux].socopgitmnum
                from dbsmopgitm, dbsmopg
               where dbsmopgitm.atdsrvnum = a_ctb11m06[arr_aux].atdsrvnum and
                     dbsmopgitm.atdsrvano = a_ctb11m06[arr_aux].atdsrvano and
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

           #----------------------------------------------
           # ASSISTISTENCIAS SEM TARIFA
           #----------------------------------------------
           #if ws.asitipcod =  4  or       # CHAVEIRO --> OSF 25143
           if ws.asitipcod =  5  or       # TAXI
              ws.asitipcod =  8  or       # CHAV/DAF
              ws.asitipcod = 10  or       # AVIAO
              ws.asitipcod = 13  or       # HOSPEDAGEM
              ws.asitipcod = 11  or       # AMBULANCIA
              ws.asitipcod = 12  or       # TRANSLADO
              ws.asitipcod = 16  then     # RODOVIARIO
              next field socopgitmvlr
           end if

           if  ws.pstcoddig is null or ws.pstcoddig = " " then
               open cctb11m06004 using a_ctb11m06[arr_aux].atdsrvnum,
                                       a_ctb11m06[arr_aux].atdsrvano
               fetch cctb11m06004 into ws.pstcoddig
           end if

           whenever error continue
             select vlrtabflg
               into l_vlrtabflg
               from dpaksocor
              where pstcoddig = ws.pstcoddig
           whenever error stop

           #Verifica se o prestador utiliza tabela.
           if l_vlrtabflg = 'S'
              then
              #display "a_ctb11m06[arr_aux].socopgitmvlr: ", a_ctb11m06[arr_aux].socopgitmvlr
              if a_ctb11m06[arr_aux].socopgitmvlr is null
                 then
                 #-----------------------------------------------
                 # BUSCA NUMERO DA TABELA(VIGENCIA) P/ O SERVICO
                 #-----------------------------------------------
                 call ctc00m15_rettrfvig(ws.pstcoddig,
                                         ws.ciaempcod,
                                         ws.atdsrvorg,
                                         ws.asitipcod,
                                         ws.atddat)
                      returning ws.soctrfcod,
                                ws.soctrfvignum,
                                lr_erro.*

                 if lr_erro.err = 0 then
                    # BURINI - ADICIONAL NOTURNO
                    if ctx15g01_verif_adic(a_ctb11m06[arr_aux].atdsrvnum,
                                           a_ctb11m06[arr_aux].atdsrvano) then
                       let m_vlrfxacod = 2
                    else
                       let m_vlrfxacod = 1
                    end if

                    select atdvclsgl, vclcoddig
                      into ws.atdvclsgl_acn, ws.vclcoddig_acn
                      from datkveiculo
                     where socvclcod = ws.socvclcod

                    if ws.vclcoddig_acn is not null then

                       call ctc00m15_retsocgtfcod(ws.vclcoddig_acn)
                           returning ws.socgtfcod_acn,
                                     lr_erro.err,
                                     lr_erro.msgerr

                       if ws.socgtfcod  =  5                and
                          ws.socgtfcod  >  ws.socgtfcod_acn then
                          let ws.socgtfcod = ws.socgtfcod_acn
                          call cts15g00(ws.vclcoddig_acn)
                              returning ws.vcldes_acn

                          initialize ws.msg1 to null
                          let ws.msg1 = "SIGLA ", ws.atdvclsgl_acn,
                                        " ACIONADA PARA ESTE SOCORRO."
                          call cts08g01("A","N",
                                        "CALCULAR VALOR DO SERVICO SOBRE VIATURA",
                                        ws.msg1,
                                        ws.vcldes_acn[1,40],
                                        ws.vcldes_acn[41,80])
                              returning ws.confirma
                       end if
                    end if

                    if ws.socgtfcod is null then
                       let ws.socgtfcod  = 10
                    end if
                    call ctc00m15_retvlrvig(ws.soctrfvignum,
                                            ws.socgtfcod,
                                            m_vlrfxacod)
                        returning ws.socgtfcstvlr, lr_erro.*

                    case m_vlrfxacod
                       when 1
                            let l_param = "INI"
                       when 2
                            let l_param = "ADC"
                       otherwise
                            let l_param = ""
                    end case

                    call ctd00g00_vlrprmpgm(a_ctb11m06[arr_aux].atdsrvnum,
                                            a_ctb11m06[arr_aux].atdsrvano,
                                            l_param)
                         returning ws.vlrprm,
                                   lr_erro.err

                    let ws.socgtfcstvlr = ctd00g00_compvlr(ws.socgtfcstvlr, ws.vlrprm)

                    #display a_ctb11m06[arr_aux].vlrfxacod to s_ctb11m06[scr_aux].vlrfxacod

                    #busca o valor do servico automaticamente...
                    #BURINI#    open cctb11m06003 using param.socopgnum
                    #BURINI#    whenever error continue
                    #BURINI#    fetch cctb11m06003 into ws.socopgsitcod
                    #BURINI#    whenever error stop
                    #BURINI#    if sqlca.sqlcode <> 0 then
                    #BURINI#       if sqlca.sqlcode <> notfound then
                    #BURINI#           error 'Erro SELECT cctb11m06001 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
                    #BURINI#               error 'CTB11M06 / ctb11m06() / ',a_ctb11m06[arr_aux].atdsrvnum, ' / '
                    #BURINI#                          ,a_ctb11m06[arr_aux].atdsrvano, ' / '
                    #BURINI#                              ,param.socopgnum sleep 2
                    #BURINI#               exit input
                    #BURINI#       end if
                    #BURINI#    else
                    #BURINI#       if ws.socopgsitcod = 1 or ws.socopgsitcod = 2 then
                    #BURINI#           open cctb11m06001 using ws.soctrfvignum
                    #BURINI#                               ,m_vlrfxacod
                    #BURINI#                                   ,a_ctb11m06[arr_aux].atdsrvnum
                    #BURINI#                                   ,a_ctb11m06[arr_aux].atdsrvano
                    #BURINI#
                    #BURINI#           whenever error continue
                    #BURINI#           fetch cctb11m06001 into a_ctb11m06[arr_aux].socopgitmvlr
                    #BURINI#           whenever error stop
                    #BURINI#
                    #BURINI#           if sqlca.sqlcode <> 0 then
                    #BURINI#               if sqlca.sqlcode <> notfound then
                    #BURINI#                   error 'Erro SELECT cctb11m06001 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
                    #BURINI#                   error 'CTB11M06 / ctb11m06() / ',a_ctb11m06[arr_aux].atdsrvnum, ' / '
                    #BURINI#                                  ,a_ctb11m06[arr_aux].atdsrvano, ' / '
                    #BURINI#                                  ,param.socopgnum sleep 2
                    #BURINI#                   exit input
                    #BURINI#               end if
                    #BURINI#           else
                                     # PSI 211001
                                     # Pagamento de Adicionais Noturno, Feriado e Domingo - Burini
                                     #### APENAS RE ###if  ctx15g00_verif_adic(a_ctb11m06[arr_aux].atdsrvnum,
                                     #### APENAS RE ###                        a_ctb11m06[arr_aux].atdsrvano) then
                                     #### APENAS RE ###     call ctx15g00_vlr_adic(a_ctb11m06[arr_aux].atdsrvnum,
                                     #### APENAS RE ###                            a_ctb11m06[arr_aux].atdsrvano,
                                     #### APENAS RE ###                            a_ctb11m06[arr_aux].socopgitmvlr)
                                     #### APENAS RE ###          returning a_ctb11m06[arr_aux].socopgitmvlr
                                     #### APENAS RE ###end if
                    #BURINI#                display a_ctb11m06[arr_aux].socopgitmvlr to s_ctb11m06[scr_aux].socopgitmvlr
                    #BURINI#            end if
                    #BURINI#        else
                    display a_ctb11m06[arr_aux].socopgitmvlr to s_ctb11m06[scr_aux].socopgitmvlr
                    #BURINI#        end if
                    #BURINI#     end if
                 else
                    error lr_erro.msgerr
                    next field atdsrvano
                 end if
              end if
          else
              error ' Prestador sem tabela '
              sleep 1
          end if

          #PSI 205206
          #caso é o primeiro item a ser vinculado a OP
          # e ainda nao buscamos o nome da empresa
          if d_ctb11m06.empresa is null then
             call cty14g00_empresa(1, ws.opgempcod)
                  returning l_ret,
                            l_mensagem,
                            d_ctb11m06.empresa
             display by name d_ctb11m06.empresa attribute (reverse)
          end if

        before field socopgitmvlr

           display "ws.ciaempcod = ", ws.ciaempcod
           display "ws.opgempcod = ", ws.opgempcod


           ########### BURINI - Projeto SAPS - Nova cobrança #########
           if  ws.opgempcod = 43 then
               #if  ws.socgtfcstvlr is null then
                   call ctb11m06_busca_valor_saps(a_ctb11m06[arr_aux].atdsrvnum,
                                                  a_ctb11m06[arr_aux].atdsrvano)
                        returning lr_retSAPS.errcod,
                                  lr_retSAPS.errmsg,
                                  lr_retSAPS.incvlr

                        display "RETORNO DA FUNÇÃO DO SAPS"
                        display "lr_retspas.errcod = ", lr_retSAPS.errcod
                        display "lr_retspas.errmsg = ", lr_retSAPS.errmsg
                        display "lr_retspas.incvlr = ", lr_retSAPS.incvlr

                        if  lr_retSAPS.errcod = 0 then
                            let a_ctb11m06[arr_aux].socopgitmvlr = lr_retSAPS.incvlr
                        else
                            error lr_retSAPS.errmsg
                            next field atdsrvnum
                        end if

               #end if
           end if
           ###########################################################

           display a_ctb11m06[arr_aux].socopgitmvlr  to
                   s_ctb11m06[scr_aux].socopgitmvlr  attribute (reverse)

        after field socopgitmvlr
           let a_ctb11m06[arr_aux].socopgitmvlr = a_ctb11m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"
           display a_ctb11m06[arr_aux].socopgitmvlr  to
                   s_ctb11m06[scr_aux].socopgitmvlr

           ########### BURINI - Projeto SAPS - Nova cobrança #########
           if  ws.ciaempcod <> 43 then

               #BURINI# if fgl_lastkey() = fgl_keyval("up")   or
               #BURINI#    fgl_lastkey() = fgl_keyval("left") then
               #BURINI#    if ws.soctrfcod     is not null and
               #BURINI#       ws.socfatrelqtd  is not null and
               #BURINI#       ws.asitipcod  <>   5         and
               #BURINI#   #   ws.asitipcod  <>   4         and --> OSF 25143
               #BURINI#       ws.asitipcod  <>   8         and
               #BURINI#       ws.asitipcod  <>  10         and
               #BURINI#       ws.asitipcod  <>  11         and
               #BURINI#       ws.asitipcod  <>  12         and
               #BURINI#       ws.asitipcod  <>  13         and
               #BURINI#       ws.asitipcod  <>  16         then
               #BURINI#       next field vlrfxacod
               #BURINI#    else
               #BURINI#       next field atdsrvano
               #BURINI#    end if
               #BURINI# end if

               if a_ctb11m06[arr_aux].socopgitmvlr   is null   or
                  a_ctb11m06[arr_aux].socopgitmvlr   = 0       then
                  error " Valor inicial da ordem de servico deve ser informado!"
                  next field socopgitmvlr
               end if

               # VERIFICA SE JA' HOUVE ACERTO DE VALOR PARA TRANSPORTE
               #------------------------------------------------------
               #WWW if ws.atdcstvlr  is not null   and
               #WWW    ws.atdsrvorg     <>  2      then
               if ws.atdcstvlr  is not null   and
                  ws.atdcstvlr  <> 0          then
                  if a_ctb11m06[arr_aux].socopgitmvlr  >  ws.atdcstvlr  then
                     error " Valor do servico maior que valor acertado (",
                           ws.atdcstvlr using "<<<,###,##&.&&", ")!"
                     next field socopgitmvlr
                  end if
               end if

               # CONSISTENCIA DE LIMITE DE VALOR PARA SERVICO CANCELADO
               #-------------------------------------------------------
               if ws.atdetpcod  =   5    then
                  if ws.atdsrvorg  =  4  or
                     ws.atdsrvorg  =  6  or
                     ws.atdsrvorg  =  1  or
                     ws.atdsrvorg  =  5  or
                     ws.atdsrvorg  =  7  or
                     ws.atdsrvorg  = 17  or
                     ws.atdsrvorg  =  2  then

                     if a_ctb11m06[arr_aux].socopgitmvlr  >  30.00   then
                        if g_issk.acsnivcod  <  8   then
                          error " Servico cancelado com valor acima de R$ 30.00!"
                           next field socopgitmvlr
                        else
                           call cts08g01("C","S", "SERVICO CANCELADO COM VALOR ",
                                                  "ACIMA DE R$ 30,00",
                                                  "",
                                                  "CONFIRMA PAGAMENTO ?")
                                returning ws.confirma

                           if ws.confirma = "N"  then
                              next field socopgitmvlr
                           end if

                           let a_ctb11m06[arr_aux].socconlibflg = "S"
                           display by name a_ctb11m06[arr_aux].socconlibflg
                        end if
                     end if
                  end if
               end if

               #-------------------------------------------
               # CONSISTENCIA DE LIMITE DE VALORES
               #-------------------------------------------
               initialize ws.msg1, ws.msg2 to null
               if ws.atdsrvorg     =   2    then
                  if (ws.asitipcod =   5    or        # TAXI
                      ws.asitipcod =  10    or        # AVIAO
                      ws.asitipcod =  16)   and       # RODOVIARIO
                     a_ctb11m06[arr_aux].socopgitmvlr > 1000.00 then
                     let ws.msg1  =  "SERVICO DE ASSIST. A PASSAGEIRO"
                     let ws.msg2  =  "COM VALOR ACIMA DE R$ 1000,00"
                  else
                     if ws.asitipcod = 11   and       # AMBULANCIA
                        a_ctb11m06[arr_aux].socopgitmvlr > 2500.00 then
                        let ws.msg1  =  "SERVICO DE AMBULANCIA COM"
                        let ws.msg2  =  "VALOR ACIMA DE R$ 2.500,00"
                     end if
                     if ws.asitipcod = 12   and       # AMBULANCIA
                        a_ctb11m06[arr_aux].socopgitmvlr > 1500.00 then
                        let ws.msg1  =  "SERVICO DE TRANSLADO  COM"
                        let ws.msg2  =  "VALOR ACIMA DE R$ 1.500,00"
                     end if
                  end if
               else
                  if ws.atdsrvorg =   3    and
                     ws.asitipcod =  13    and       # HOSPEDAGEM
                     a_ctb11m06[arr_aux].socopgitmvlr > 1400.00 then
                     let ws.msg1  =  "SERVICO DE HOSPEDAGEM COM"
                     let ws.msg2  =  "VALOR ACIMA DE R$ 1.400,00"
                  end if
               end if

               if ws.msg1 is not null then
                  if g_issk.acsnivcod  <  8   then
                     error " Nivel de acesso nao permite liberacao!"
                     next field socopgitmvlr
                  else
                     call cts08g01("C","S", ws.msg1, ws.msg2, "",
                                            "CONFIRMA PAGAMENTO ?")
                          returning ws.confirma

                     if ws.confirma = "N"  then
                        next field socopgitmvlr
                     end if

                     let a_ctb11m06[arr_aux].socconlibflg = "S"
                     display by name a_ctb11m06[arr_aux].socconlibflg
                  end if
               end if

               # PARAMETROS : INFORMA RELACAO/CHECA TARIFA
               #------------------------------------------
               let ws.checktab = "n"
               let ws.relcusto = "n"

               if ws.pstcoddig  is not null  then
                  if ws.soctrfcod     is not null and   ### Tarifa da Porto
                     ws.socfatrelqtd  is not null and   ### Entrega relacao
                     ws.asitipcod     <>   5      and   ### Taxi
                   # ws.asitipcod     <>   4      and   ### Chaveiro --> OSF25143
                     ws.asitipcod     <>   8      and   ### Chaveiro/Dispositivo
                     ws.asitipcod     <>  10      and   ### Aviao
                     ws.asitipcod     <>  11      and   ### Ambulancia
                     ws.asitipcod     <>  12      and   ### Translado
                     ws.asitipcod     <>  13      and   ### Hospedagem
                     ws.asitipcod     <>  16      then  ### Rodov.
                     let ws.checktab = "s"
                  end if

                  # LAUDO EM BRANCO (S/ DOCUMENTO INFORMADO)
                  #-----------------------------------------
                  select atdsrvnum, atdsrvano from datrservapol
                   where atdsrvnum = a_ctb11m06[arr_aux].atdsrvnum   and
                         atdsrvano = a_ctb11m06[arr_aux].atdsrvano

                  if sqlca.sqlcode  =  notfound  then
                     if ws.vclcoddig is null  then
                        error " Codigo do veiculo nao informado no atendimento!"
                        call cts08g01("A","N","CODIGO DO VEICULO NAO INFORMADO",
                                              "NO ATENDIMENTO!","","CUSTO NAO SERA' VERIFICADO NAS TABELAS!") returning ws.confirma
                        let ws.checktab = "n"
                    # else
                    #    let ws.checktab = "s"
                     end if
                  end if

                  if ws.socfatrelqtd  is not null then   ### Entrega relacao
                    # ws.asitipcod  <>   5          and   ### Taxi
                    # ws.asitipcod  <>   4          and   ### Chaveiro -->OSF25143
                    # ws.asitipcod  <>   8          and   ### Chaveiro/Dispositivo
                    # ws.asitipcod  <>  10          and   ### Aviao
                    # ws.asitipcod  <>  11          and   ### Ambulancia
                    # ws.asitipcod  <>  12          and   ### Translado
                    # ws.asitipcod  <>  13          and   ### Hospedagem
                    # ws.asitipcod  <>  16          then  ### Rodov.
                     let ws.relcusto = "s"
                  end if
               end if

               # MONTA GRUPO TARIFARIO DO VEICULO DO SERVICO
               #      LAUDO EM BRANCO SOCGTFCOD = NULL
               #--------------------------------------------
               if  ws.socopgorgcod is not null and
                   ws.socopgorgcod = 2         then  # OP AUTOMATICA
                   message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F6)Correcao itens"
               else
                   message " (F17)Abandona, (F1)Inclui, (F2)Exclui "
               end if

               initialize ws.socgtfcod     to null
               initialize ws.socgtfcstvlr  to null
               let a_ctb11m06[arr_aux].socopgtotvlr = 0.00
               let ws.erro = "n"

               #display 'UTILIZA TABELA: ', ws.checktab

               if ws.checktab  =  "s"   then
                  ##call ctb00g01_grptrf(a_ctb11m06[arr_aux].atdsrvnum,
                  ##                     a_ctb11m06[arr_aux].atdsrvano,
                  ##                     ws.vclcoddig,
                  ##                      1 )
                  ##     returning ws.erro, ws.socgtfcod
                  call ctc00m15_retsocgtfcod(ws.vclcoddig)
                     returning ws.socgtfcod, lr_erro.*

                  #display 'RETORNO CTC00M15_RETSOCGTFCOD :', ws.socgtfcod
                  #display 'ERRO: ', lr_erro.*

                  # VEICULOS SEM GRUPO TARIFARIO, OU PRECO A COMBINAR
                  #         SO' E' LIBERADO PELO NIVEL >= 5
                  #--------------------------------------------------
                  if lr_erro.err <> 0 or
                     ws.socgtfcod is null then
                     call cts15g00(ws.vclcoddig)
                          returning ws.vcldes

                     call cts08g01("A","N","VEICULO SEM GRUPO TARIFARIO","",
                                    ws.vcldes[1,40], ws.vcldes[41,80])
                          returning ws.confirma

                     if g_issk.acsnivcod  <  5   and
                        ws.atdcstvlr  is null    then
                        message " Nivel de acesso nao permite liberacao!"
                        #BURINI# next field vlrfxacod
                        next field atdsrvnum
                     else
                        call cts08g01("C","S", "NAO E' POSSIVEL ENCONTRAR O ",
                                               "VALOR NA TABELA P/ ESTE SERVICO",
                                               "VERIFIQUE O VALOR",
                                               "CONFIRMA PAGAMENTO ?")
                                returning ws.confirma

                        if ws.confirma = "N"  then
                           #next field vlrfxacod
                           next field atdsrvnum
                        end if

                        let a_ctb11m06[arr_aux].socconlibflg = "S"
                        display by name a_ctb11m06[arr_aux].socconlibflg
                        let ws.checktab = "n"
                        let ws.relcusto = "n"
                     end if
                  end if

                  #--------------------------------------------------
                  # VERIFICA VEICULO ACIONADO WWWW
                  #--------------------------------------------------
                  #select atdvclsgl, vclcoddig
                  #  into ws.atdvclsgl_acn, ws.vclcoddig_acn
                  #  from datkveiculo
                  # where socvclcod = ws.socvclcod

                  #display 'VEICULOS ACN'
                  #display 'ws.atdvclsgl_acn = ', ws.atdvclsgl_acn
                  #display 'ws.vclcoddig_acn = ', ws.vclcoddig_acn


                  # Verifica grp tar.veic.socorro
                  #if ws.vclcoddig_acn is not null then
                  #
                  #   call ctc00m15_retsocgtfcod(ws.vclcoddig_acn)
                  #       returning ws.socgtfcod_acn,
                  #                 lr_erro.err,
                  #                 lr_erro.msgerr
                  #
                  #   display 'TARIFA VEICULO SOCORRO'
                  #   display 'ws.socgtfcod_acn = ', ws.socgtfcod_acn
                  #   display 'lr_erro.err      = ', lr_erro.err
                  #   display 'lr_erro.msgerr   = ', lr_erro.msgerr
                  #
                  #   if ws.socgtfcod  =  5                and
                  #      ws.socgtfcod  >  ws.socgtfcod_acn then
                  #      let ws.socgtfcod = ws.socgtfcod_acn
                  #      call cts15g00(ws.vclcoddig_acn)
                  #          returning ws.vcldes_acn
                  #
                  #      initialize ws.msg1 to null
                  #      let ws.msg1 = "SIGLA ", ws.atdvclsgl_acn,
                  #                    " ACIONADA PARA ESTE SOCORRO."
                  #      call cts08g01("A","N",
                  #                    "CALCULAR VALOR DO SERVICO SOBRE VIATURA",
                  #                    ws.msg1,
                  #                    ws.vcldes_acn[1,40],
                  #                    ws.vcldes_acn[41,80])
                  #          returning ws.confirma
                  #      if ws.socgtfcod is null then
                  #         let ws.socgtfcod  = 10
                  #      end if
                  #   end if
                  #end if

                  if ws.socgtfcod  is not null   then
                     call ctc00m15_retvlrvig(ws.soctrfvignum,
                                             ws.socgtfcod,
                                             m_vlrfxacod)
                         returning ws.socgtfcstvlr, lr_erro.*

		     if lr_erro.err = notfound   then
                        error " Faixa de valor nao possui vigencia cadastrada!"
                        next field atdsrvnum
                     end if

                     case m_vlrfxacod
                        when 1
                             let l_param = "INI"
                        when 2
                             let l_param = "ADC"
                        otherwise
                             let l_param = ""
                     end case

                     call ctd00g00_vlrprmpgm(a_ctb11m06[arr_aux].atdsrvnum,
                                             a_ctb11m06[arr_aux].atdsrvano,
                                             l_param)
                          returning ws.vlrprm,
                                    lr_erro.err

                     let ws.socgtfcstvlr = ctd00g00_compvlr(ws.socgtfcstvlr, ws.vlrprm)

                     #display 'TARIFA ws.socgtfcstvlr : ', ws.socgtfcstvlr
                     #display 'TARIFA a_ctb11m06[arr_aux].socopgitmvlr : ', a_ctb11m06[arr_aux].socopgitmvlr

                     # CHECA VALOR INICIAL MAIOR QUE A TABELA
                     #       SO' LIBERA SE FOR NIVEL >= 5
                     #-----------------------------------------
                     if ws.soctrfcod                     <> 2               and
                        a_ctb11m06[arr_aux].socopgitmvlr  > ws.socgtfcstvlr then
                        #WWW  a_ctb11m06[arr_aux].socopgitmvlr <> ws.socgtfcstvlr then
                        error " Valor inicial diferente da tabela --> ", ws.socgtfcstvlr
                        if g_issk.acsnivcod  >= 5   then
                           call cts08g01("C","S","","VALOR INICIAL DIFERE DA",
                                         "TABELA PARA VEICULO ATENDIDO!","")
                                returning ws.confirma

                           if ws.confirma = "N"  then
                              next field socopgitmvlr
                           end if

                           let a_ctb11m06[arr_aux].socconlibflg = "S"
                           display by name a_ctb11m06[arr_aux].socconlibflg
                        else
                           next field socopgitmvlr
                        end if
                     end if
                  end if
               end if

               # SE PRESTADOR UTILIZA RELACAO, ABRE
               # TELA PARA DISCRIMINAR CUSTO DO SERVICO
               #----------------------------------------
               let ws.incitmok = "n"

               if ws.relcusto  =  "s"   then
                  call ctb11m07(param.socopgnum,
                                ws.operacao,
                                a_ctb11m06[arr_aux].nfsnum,
                                a_ctb11m06[arr_aux].atdsrvnum,
                                a_ctb11m06[arr_aux].atdsrvano,
                                m_vlrfxacod,
                                a_ctb11m06[arr_aux].socopgitmvlr,
                                a_ctb11m06[arr_aux].socconlibflg,
                                a_ctb11m06[arr_aux].socopgitmnum,
                                ws.soctrfvignum,
                                ws.socgtfcod,
                                ws.checktab)
                      returning a_ctb11m06[arr_aux].nfsnum,
                                a_ctb11m06[arr_aux].atdsrvnum,
                                a_ctb11m06[arr_aux].atdsrvano,
                                m_vlrfxacod,
                                a_ctb11m06[arr_aux].socopgitmvlr,
                                a_ctb11m06[arr_aux].socopgitmnum,
                                a_ctb11m06[arr_aux].socopgtotvlr,
                                a_ctb11m06[arr_aux].socconlibflg,
                                ws.incitmok,
                                a_ctb11m06[arr_aux].socopgdscvlr

                  # QUANDO A INCLUSAO FOR OK, ALTERAR OPERACAO
                  # PARA "a", PARA NAO INSERIR NO  AFTER ROW
                  # ------------------------------------------
                  if ws.operacao = "i"  then
                     if ws.incitmok = "s"   then
                        let ws.operacao = "a"
                     else
                        initialize a_ctb11m06[arr_aux].socopgtotvlr  to null
                        display by name a_ctb11m06[arr_aux].socopgtotvlr
                        error " O.S. nao incluida, custos devem ser informados!"
                        next field atdsrvnum
                     end if
                  end if
                  call cabec_ctb11m06()
               end if

               # NAO INFORMOU CUSTOS TOTAL GERAL = VALOR INICIAL
               #------------------------------------------------
               if ws.relcusto  =  "n"   then
                  let a_ctb11m06[arr_aux].socopgtotvlr =
                      a_ctb11m06[arr_aux].socopgitmvlr
               end if

               ### OSF35050  // Chamar a tela de rateio PS //
               ##PSI207233
               open c_datmligacao using a_ctb11m06[arr_aux].atdsrvnum,
                                        a_ctb11m06[arr_aux].atdsrvano
               fetch c_datmligacao into m_c24astcod
               close c_datmligacao

               if m_c24astcod = "S11"  or
                  m_c24astcod = "S14"  or
                  m_c24astcod = "S53"  or
                  m_c24astcod = "S64"
                  then
                  open c_dbscadtippgt using a_ctb11m06[arr_aux].atdsrvnum,
                                            a_ctb11m06[arr_aux].atdsrvano
                      fetch c_dbscadtippgt into m_pgttipcodps
                  close c_dbscadtippgt
                  if m_pgttipcodps = 3 then
                     call ctb04m12(a_ctb11m06[arr_aux].atdsrvorg,
                                   a_ctb11m06[arr_aux].atdsrvnum,
                                   a_ctb11m06[arr_aux].atdsrvano,
                                   a_ctb11m06[arr_aux].socopgtotvlr)
                  end if
               else
                  call ctb04m12(a_ctb11m06[arr_aux].atdsrvorg,
                                a_ctb11m06[arr_aux].atdsrvnum,
                                a_ctb11m06[arr_aux].atdsrvano,
                                a_ctb11m06[arr_aux].socopgtotvlr)
               end if
               ##PSI207233
           else
               # VALOR DO SERVIÇO SAPS NAO PODERÁ SER ALTERADO
               if  a_ctb11m06[arr_aux].socopgtotvlr <> lr_retSAPS.incvlr then
                   error 'Valor do serviço SAPS nao pode ser alterado.'
                   let a_ctb11m06[arr_aux].socopgtotvlr = lr_retSAPS.incvlr
               end if
           end if

           display a_ctb11m06[arr_aux].*  to  s_ctb11m06[scr_aux].*

        on key(interrupt)
           exit input

        before delete
           let ws.operacao = "d"
           if a_ctb11m06[arr_aux].socopgitmnum   is null   or
              a_ctb11m06[arr_aux].socopgitmnum   =  0      then
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
                  dbsmopgcst.socopgitmnum = a_ctb11m06[arr_aux].socopgitmnum

           if sqlca.sqlcode <> 100   and
              sqlca.sqlcode <> 0     then
              error "Erro (",sqlca.sqlcode,") na exclusao do custo do item!"
              next field atdsrvnum
           end if

           delete from dbsmopgitm
            where dbsmopgitm.socopgnum    = param.socopgnum      and
                  dbsmopgitm.socopgitmnum = a_ctb11m06[arr_aux].socopgitmnum

           if sqlca.sqlcode <> 0   then
              error "Erro (",sqlca.sqlcode,") na exclusao do item da O.P.!"
              next field atdsrvnum
           end if
           commit work
           #-----------

           initialize a_ctb11m06[arr_aux].* to null
           display a_ctb11m06[arr_aux].* to s_ctb11m06[scr_aux].*

        # on key (F5)
        #    call ctb11m15(ws.nfsnum)
        #         returning ws.nfsnum
        #    initialize a_ctb11m06[arr_aux].nfsnum to null
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
                 initialize a_ctb11m06    to null
                 for arr_aux = 1 to 11
                    display a_ctb11m06[arr_aux].* to s_ctb11m06[arr_aux].*
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

           let a_ctb11m06[arr_aux].nfsnum = l_nfsnum

           #Formatação do campo alterada para atendimento do chamado 100913299
           let a_ctb11m06[arr_aux].socopgitmvlr = a_ctb11m06[arr_aux].socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

           case ws.operacao
              when "i"
                 initialize ws.socopgnum   to null # CT 697796
                 select dbsmopg.socopgnum, dbsmopgitm.socopgitmnum
                   into ws.socopgnum, a_ctb11m06[arr_aux].socopgitmnum
                   from dbsmopgitm, dbsmopg
                  where dbsmopgitm.atdsrvnum = a_ctb11m06[arr_aux].atdsrvnum and
                        dbsmopgitm.atdsrvano = a_ctb11m06[arr_aux].atdsrvano and
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
                 let a_ctb11m06[arr_aux].socopgitmnum = ws.socopgitmnum

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
                              socconlibflg)
                      values (param.socopgnum,
                              a_ctb11m06[arr_aux].atdsrvnum,
                              a_ctb11m06[arr_aux].atdsrvano,
                              a_ctb11m06[arr_aux].socopgitmvlr,
                              a_ctb11m06[arr_aux].nfsnum,
                              ws.socopgitmnum,
                              g_issk.funmat,
                              a_ctb11m06[arr_aux].socconlibflg)

                 #--------------------------------------#
                 # INCLUSAO DA FASE (DIGITADA) - BURINI #
                 #--------------------------------------#

                 initialize ws.erro, ws.msg1 to null

                 # PSI 221074 - BURINI
                 call cts50g00_sel_etapa(param.socopgnum, 3)
                      returning ws.erro, ws.msg1

                 if  ws.erro = 2  then

                     call cts50g00_insere_etapa(param.socopgnum, 3, g_issk.funmat)
                          returning ws.erro, ws.msg1

                     if  ws.erro <> 1 then
                         display ws.msg1
                     end if

                 else
                     if  ws.erro <> 1 then
                         display ws.msg1
                     end if
                 end if

                 commit work
                 #----------

              when "a"
                 begin work
                 #----------
                 update dbsmopgitm  set
                             (vlrfxacod,
                              socopgitmvlr,
                              nfsnum)
                           = (m_vlrfxacod,
                              a_ctb11m06[arr_aux].socopgitmvlr,
                              a_ctb11m06[arr_aux].nfsnum)
                  where socopgnum    = param.socopgnum                  and
                        socopgitmnum = a_ctb11m06[arr_aux].socopgitmnum

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

           end case

           display a_ctb11m06[arr_aux].* to s_ctb11m06[scr_aux].*
           let ws.operacao = " "
     end input

     # FAZ BATIMENTO E ATUALIZA SITUACAO DA O.P.
     #------------------------------------------
     if int_flag
        then
        call ctb11m09(param.socopgnum, "ctb11m06", ws.pstcoddig, ws.pestip,
                      ws.segnumdig)
        exit while
     end if

 end while

 let int_flag = false
 close window w_ctb11m06

end function  ###  ctb11m06

#--------------------------------------------------------------------
function cabec_ctb11m06()
#--------------------------------------------------------------------

 select socopgsitcod
   into d_ctb11m06.socopgsitcod
   from dbsmopg
  where socopgnum = d_ctb11m06.socopgnum

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da O.P. durante montagem do cabecalho!"
    close window w_ctb11m06
    return
 end if

 select cpodes
   into d_ctb11m06.socopgsitdes
   from iddkdominio
  where cponom = "socopgsitcod"   and
        cpocod = d_ctb11m06.socopgsitcod

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da situacao!"
    close window w_ctb11m06
    return
 end if

 display by name d_ctb11m06.socopgnum
 display by name d_ctb11m06.socopgsitcod
 display by name d_ctb11m06.socopgsitdes
 display by name d_ctb11m06.empresa  attribute (reverse)        #PSI 205206

end function  ###  cabec_ctb11m06

#-----------------------------------------#
 function ctb11m06_busca_valor_saps(param)
#-----------------------------------------#

     define param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     define lr_aux record
         prsokaflg like dbsmsrvacr.prsokaflg,
         anlokaflg like dbsmsrvacr.anlokaflg,
         pstcoddig like dpaksocor.pstcoddig,
         pstacrptl smallint
     end record

     define lr_ret record
         errcod smallint,
         errmsg char(100),
         incvlr like dbsmsrvacr.incvlr
     end record

     initialize lr_aux.*, lr_ret.* to null

     whenever error continue
     select incvlr,
            prsokaflg,
            anlokaflg,
            pstcoddig
       into lr_ret.incvlr,
            lr_aux.prsokaflg,
            lr_aux.anlokaflg,
            lr_aux.pstcoddig
       from dbsmsrvacr
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano
     whenever error stop

     let lr_ret.errcod =  sqlca.sqlcode

     if  sqlca.sqlcode = 100 then
         let lr_ret.errmsg =  'Serviço não encontrado no Acerto de valores SAPS.'
         return lr_ret.*
     end if

     # VALOR DO SERVIÇO 0 OU INFERIOR
     if  lr_ret.incvlr <= 0 then
         # RETORNA ERRO DE NEGOCIO
         let lr_ret.errcod = 1
         let lr_ret.errmsg = 'Valor do serviço invalido.'
         return lr_ret.*
     end if

     whenever error continue
     select 1
       from dpaksocor
      where pstcoddig = lr_aux.pstcoddig
        and outciatxt like '%INTERNET%'
     whenever error stop

     if  sqlca.sqlcode <> 0 then
         let lr_aux.pstacrptl = false
     else
         let lr_aux.pstacrptl = true
     end if

     display "lr_aux.pstacrptl = ", lr_aux.pstacrptl

     if  lr_aux.pstacrptl then
         # SERVIÇO NAO ACERTADO PELO PRESTADOR
         if  lr_aux.prsokaflg <> 'S' then
             # RETORNA ERRO DE NEGOCIO
             let lr_ret.errcod = 1
             let lr_ret.errmsg = 'Serviço ainda não acertado pelo prestador.'
             return lr_ret.*
         end if

         # SERVIÇO NAO ANALISADO
         if  lr_aux.anlokaflg <> 'S' then
             # RETORNA ERRO DE NEGOCIO
             let lr_ret.errcod = 1
             let lr_ret.errmsg = 'Serviço ainda não analisado pelo Porto Socorro.'
             return lr_ret.*
         end if
     end if

     return lr_ret.*

 end function