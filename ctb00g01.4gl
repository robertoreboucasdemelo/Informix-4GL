#############################################################################
# Nome do Modulo: CTB00G01                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Funcoes genericas para OP Porto Socorro                          Dez/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/04/2000  PSI 10426-4  Wagner       Permitir a gravacao do historico com#
#                                       mais de um evento.                  #
#---------------------------------------------------------------------------#
# 19/06/2001  PSI 13253-5  Wagner       Permitir a gravacao da analise dos  #
#                                       prestadores e socorristas.          #
#---------------------------------------------------------------------------#
# 19/08/2003  PSI 172332   Ale Souza    Critica automatica  por numero de   #
#             OSF 24740                 Nota Fiscal.                        #
#############################################################################
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Raji                             OSF : 30155            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 15/12/2003       #
#  Objetivo       : Criar funcao generica para verificacao e alerta de      #
#                   bloqueio para um servico.                               #
# 01/06/2009  PSI 198404  Fabio Costa  Funcao sugere sucursal regra tributos#
# 28/07/2009  PSI 198404  Fabio Costa  Funcao define tipo favorecido e      #
#                                      busca dados                          #
# 09/09/2009  PSI 198404  Fabio Costa  Tratar reembolso segurado Azul       #
# 14/04/2010  PSI 198404  Fabio Costa  Ver NF repetida no favorecido(vernfs)#
# 25/05/2012  PSI-11-19199PR Jose Kurihara Tratar tipo retorno 7 flag de    #
#                                          Optante Simples                  #
#---------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define l_prepare smallint

#--------------------------------------------------------------------
 function ctb00g01_grptrf(param)    # GRUPO TARIFARIO
#--------------------------------------------------------------------

 define param       record
    atdsrvnum       like dbsmopgitm.atdsrvnum,
    atdsrvano       like dbsmopgitm.atdsrvano,
    vclcoddig       like datmservico.vclcoddig,
    origem          dec(1,0)              # 1-OP digitacao   2-OP automatica
 end record

 define ws         record
    succod          like datrservapol.succod,
    aplnumdig       like datrservapol.aplnumdig,
    itmnumdig       like datrservapol.itmnumdig,
    edsnumref       like datrservapol.edsnumref,
    vclcoddig       like abbmveic.vclcoddig,
    socgtfcod       like dbsrvclgtf.socgtfcod,
    erro            char (01),
    confirma        char (01),
    resultado       char (01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record



	initialize  ws.*  to  null

 initialize ws.*   to null
 let ws.erro = "n"

 if param.vclcoddig is null  then
    select succod, aplnumdig, itmnumdig, edsnumref
      into ws.succod, ws.aplnumdig, ws.itmnumdig, ws.edsnumref
      from datrservapol
     where atdsrvnum = param.atdsrvnum     and
           atdsrvano = param.atdsrvano

    if sqlca.sqlcode = 0   then
       call f_funapol_auto(ws.succod   , ws.aplnumdig,
                           ws.itmnumdig, ws.edsnumref)
                 returning ws.resultado, ws.dctnumseq, ws.vclsitatu,
                           ws.autsitatu, ws.dmtsitatu, ws.dpssitatu,
                           ws.appsitatu, ws.vidsitatu

       if ws.resultado  is not null   then
          select vclcoddig
            into ws.vclcoddig
            from abbmveic
           where succod    = ws.succod      and
                 aplnumdig = ws.aplnumdig   and
                 itmnumdig = ws.itmnumdig   and
                 dctnumseq = ws.vclsitatu
       else
          if param.origem = 1 then
             error " Erro no acesso da apolice. AVISE A INFORMATICA!"
          end if
          let ws.erro = "s"
       end if
    end if
 else
    let ws.vclcoddig = param.vclcoddig
 end if

 if ws.vclcoddig is not null  then
    select socgtfcod
      into ws.socgtfcod
      from dbsrvclgtf
     where vclcoddig = ws.vclcoddig

    if sqlca.sqlcode <> 0    then
       initialize ws.socgtfcod   to null
       if param.origem = 1 then
          error " Veiculo ", ws.vclcoddig, " nao possui grupo tarifario cadastrado!"
       end if
       let ws.erro = "s"
    end if
 end if

 return ws.erro, ws.socgtfcod

end function  ###  ctb00g01_grptrf

#--------------------------------------------------------------------
 function ctb00g01_anlsrv(param)    # GRAVA ANALISE SERVICO
#--------------------------------------------------------------------

 define param       record
    c24evtcod       like datkevt.c24evtcod,
    c24fsecod       like datkfse.c24fsecod,
    atdsrvnum       like dbsmopgitm.atdsrvnum,
    atdsrvano       like dbsmopgitm.atdsrvano,
    funmat          like isskfunc.funmat
 end record

 define ws         record
    srvanlhstseq    like datmsrvanlhst.srvanlhstseq,
    count           smallint
 end record


 #--------------------------------------------------------------
 # Verifica duplicidade antes de inserir p/processamento batch
 #--------------------------------------------------------------


	initialize  ws.*  to  null

 if param.c24fsecod is null then
    select count(*)
      into ws.count
      from datmsrvanlhst
     where datmsrvanlhst.atdsrvnum = param.atdsrvnum
       and datmsrvanlhst.atdsrvano = param.atdsrvano
       and datmsrvanlhst.c24evtcod = param.c24evtcod

    if ws.count is not null and
       ws.count  > 0        then
       return                # SERVICO JA RETIDO COM O MESMO EVENTO
    else
       select c24fsecod
         into param.c24fsecod
         from datkevt
        where datkevt.c24evtcod = param.c24evtcod
    end if
 end if

 select max(srvanlhstseq)
   into ws.srvanlhstseq
   from datmsrvanlhst
  where datmsrvanlhst.atdsrvnum = param.atdsrvnum
    and datmsrvanlhst.atdsrvano = param.atdsrvano
    and datmsrvanlhst.c24evtcod = param.c24evtcod

 if ws.srvanlhstseq is null then
    let ws.srvanlhstseq = 0
 end if
 let ws.srvanlhstseq = ws.srvanlhstseq + 1

 whenever error continue

 #begin work
    insert into datmsrvanlhst (atdsrvnum,
                               atdsrvano,
                               srvanlhstseq,
                               c24evtcod,
                               c24fsecod,
                               caddat,
                               cademp,
                               cadmat   )
                       values (param.atdsrvnum,
                               param.atdsrvano,
                               ws.srvanlhstseq,
                               param.c24evtcod,
                               param.c24fsecod,
                               today,
                               1,
                               param.funmat)

    if sqlca.sqlcode  <>  0   then
       error "Erro (",sqlca.sqlcode,") na inclusao da tabela DATMSRVANLHST!"
       #rollback work
    else
       #commit work
    end if

end function  ###  ctb00g01_anlsrv


#--------------------------------------------------------------------
 function ctb00g01_anlsrr(param)    # GRAVA ANALISE SOCORRISTA
#--------------------------------------------------------------------

 define param       record
    c24evtcod       like datkevt.c24evtcod,
    socopgfascod    like datmsrranlhst.socopgfascod,
    srrcoddig       like datmsrranlhst.srrcoddig,
    evtocrdat       like datmsrranlhst.evtocrdat,
    funmat          like isskfunc.funmat
 end record

 define ws          record
    evtanlseq       like datmsrranlhst.evtanlseq,
    count           smallint
 end record

 #--------------------------------------------------------------
 # Verifica duplicidade antes de inserir p/processamento batch
 #--------------------------------------------------------------


	initialize  ws.*  to  null

 if param.socopgfascod is null then
    select count(*)
      into ws.count
      from datmsrranlhst
     where datmsrranlhst.srrcoddig = param.srrcoddig
       and datmsrranlhst.c24evtcod = param.c24evtcod
       and datmsrranlhst.evtocrdat = param.evtocrdat

    if ws.count is not null and
       ws.count  > 0        then
       return                # motorista JA RETIDO COM O MESMO EVENTO
    else
       select c24fsecod
         into param.socopgfascod
         from datkevt
        where datkevt.c24evtcod = param.c24evtcod
    end if
 end if

 select max(evtanlseq)
   into ws.evtanlseq
   from datmsrranlhst
  where datmsrranlhst.srrcoddig = param.srrcoddig
    and datmsrranlhst.c24evtcod = param.c24evtcod
    and datmsrranlhst.evtocrdat = param.evtocrdat

 if ws.evtanlseq is null then
    let ws.evtanlseq = 0
 end if
 let ws.evtanlseq = ws.evtanlseq + 1

 whenever error continue

#WWWbegin work
    insert into datmsrranlhst (srrcoddig,
                               c24evtcod,
                               evtocrdat,
                               evtanlseq,
                               socopgfascod,
                               fasmdcdat,
                               cademp,
                               cadmat,
                               cadusrtip)
                       values (param.srrcoddig,
                               param.c24evtcod,
                               param.evtocrdat,
                               ws.evtanlseq,
                               param.socopgfascod,
                               today,
                               1,
                               param.funmat,
                               "F")

    if sqlca.sqlcode  <>  0   then
       error "Erro (",sqlca.sqlcode,") na inclusao da tabela datmsrranlhst!"
#WWW   rollback work
    else
#WWW   commit work
    end if

end function  ###  ctb00g01_anlsrr

#--------------------------------------------------------------------
 function ctb00g01_fsesrv(param)    # GRAVA fase na ANALISE SERVICO
#--------------------------------------------------------------------
 define param       record
    c24evtcod       like datkevt.c24evtcod,
    c24fsecod       like datkfse.c24fsecod,
    atdsrvnum       like dbsmopgitm.atdsrvnum,
    atdsrvano       like dbsmopgitm.atdsrvano,
    funmat          like isskfunc.funmat
 end record

 define ws         record
    srvanlhstseq    like datmsrvanlhst.srvanlhstseq,
    count           smallint
 end record

 #--------------------------------------------------------------
 # Verifica duplicidade antes de inserir
 #--------------------------------------------------------------


	initialize  ws.*  to  null

 select count(*)
   into ws.count
   from datmsrvanlhst
  where datmsrvanlhst.atdsrvnum = param.atdsrvnum
    and datmsrvanlhst.atdsrvano = param.atdsrvano
    and datmsrvanlhst.c24evtcod = param.c24evtcod
    and datmsrvanlhst.c24fsecod = param.c24fsecod

 if ws.count is not null and
    ws.count  > 0        then
    return                # SERVICO JA RETIDO COM O MESMO EVENTO
 end if

 select max(srvanlhstseq)
   into ws.srvanlhstseq
   from datmsrvanlhst
  where datmsrvanlhst.atdsrvnum = param.atdsrvnum
    and datmsrvanlhst.atdsrvano = param.atdsrvano
    and datmsrvanlhst.c24evtcod = param.c24evtcod

 if ws.srvanlhstseq is null then
    let ws.srvanlhstseq = 0
 end if
 let ws.srvanlhstseq = ws.srvanlhstseq + 1

 whenever error continue

 #begin work
    insert into datmsrvanlhst (atdsrvnum,
                               atdsrvano,
                               srvanlhstseq,
                               c24evtcod,
                               c24fsecod,
                               caddat,
                               cademp,
                               cadmat   )
                       values (param.atdsrvnum,
                               param.atdsrvano,
                               ws.srvanlhstseq,
                               param.c24evtcod,
                               param.c24fsecod,
                               today,
                               1,
                               param.funmat)

    if sqlca.sqlcode  <>  0   then
       error "Erro (",sqlca.sqlcode,") na inclusao da tabela DATMSRVANLHST!"
       #rollback work
    else
       #commit work
    end if

end function  ###  ctb00g01_fsesrv

#-----------------------------------------------------------------------------
function ctb00g01_vernfs(param)    # Verifica se Nota Fiscal esta duplicada
#-----------------------------------------------------------------------------
# Regra: numero igual de documento fiscal nao podera ser incluso para mesmo
#        CPF/CNPJ de favorecido e mesmo tipo de documento, para OP nao cancelada

   define param        record
          soctip       like dbsmopg.soctip #> 1-P.Socorro/2-Carro Ext/3-Serv RE
         ,pestip       like dbsmopg.pestip #> F-Fisica/J-Juridica
         ,cgccpfnum    like dbsmopg.cgccpfnum
         ,cgcord       like dbsmopg.cgcord
         ,cgccpfdig    like dbsmopg.cgccpfdig
         ,socopgnum    like dbsmopg.socopgnum
         ,socpgtdoctip like dbsmopg.socpgtdoctip
         ,nfsnum       like dbsmopgitm.nfsnum
   end record

   define l_dadosop    record
          pstcoddig    like dbsmopg.pstcoddig
         ,segnumdig    like dbsmopg.segnumdig
         ,corsus       like dbsmopg.corsus
         ,socfatentdat like dbsmopg.socfatentdat
         ,socfatpgtdat like dbsmopg.socfatpgtdat
         ,socfatitmqtd like dbsmopg.socfatitmqtd
         ,socfatrelqtd like dbsmopg.socfatrelqtd
         ,socfattotvlr like dbsmopg.socfattotvlr
         ,empcod       like dbsmopg.empcod
         ,cctcod       like dbsmopg.cctcod
         ,socopgdscvlr like dbsmopg.socopgdscvlr
         ,socopgsitcod like dbsmopg.socopgsitcod
         ,atldat       like dbsmopg.atldat
         ,funmat       like dbsmopg.funmat
         ,soctrfcod    like dbsmopg.soctrfcod
         ,succod       like dbsmopg.succod
         ,socpgtdsctip like dbsmopg.socpgtdsctip
         ,socemsnfsdat like dbsmopg.socemsnfsdat
         ,pgtdstcod    like dbsmopg.pgtdstcod
         ,socopgorgcod like dbsmopg.socopgorgcod
         ,lcvcod       like dbsmopg.lcvcod
         ,aviestcod    like dbsmopg.aviestcod
         ,socopgnum    like dbsmopg.socopgnum
   end record

   define l_cts08g01   record
          linha1       char(40)
         ,linha2       char(40)
         ,linha3       char(40)
         ,confirma     char(01)
   end record

   define l_ctb00g01    char(01)
          # ,l_datpgt     like dbsmopg.socfatpgtdat
          # ,l_datpas     like dbsmopg.socfatpgtdat
        , l_sql  char(600)
        , l_whe  char(100)
   initialize l_dadosop.*
            , l_cts08g01.*
             # ,l_datpgt
             # ,l_datpas
            , l_ctb00g01
            , l_sql
            , l_whe  to null
   let l_ctb00g01 = "N"

   # nao e possivel validar a NF sem estas informacoes
   if param.socpgtdoctip is null or
      param.cgccpfnum is null or
      param.cgccpfdig is null or
      param.nfsnum is null    or
      param.socopgnum is null
      then
      error ' Atenção, não foi possível verificar NF duplicada '
      sleep 2
      return l_ctb00g01
   end if

   if param.cgcord is not null
      then
      let l_whe = " and v.cgcord = ", param.cgcord
   end if
   if param.socopgnum is not null and param.socopgnum > 0
      then
      let l_whe = l_whe clipped, ' and o.socopgnum != ', param.socopgnum  # OP atual
   end if
   # buscar NFS repetida para o favorecido
   let l_sql = ' select o.socfatpgtdat, o.socopgnum         ',
               ' from dbsmopg o, dbsmopgfav v, dbsmopgitm i ',
               ' where v.socopgnum = o.socopgnum            ',
               '   and o.socopgnum = i.socopgnum            ',
               '   and o.socopgsitcod != 8                  ',  # nao cancelada
               '   and o.socpgtdoctip = ', param.socpgtdoctip,
               '   and v.cgccpfnum    = ', param.cgccpfnum   ,
               '   and v.cgccpfdig    = ', param.cgccpfdig   ,
               '   and i.nfsnum       = ', param.nfsnum      ,
               l_whe clipped
   prepare p_nfs_dup_sel from l_sql
   declare c_nfs_dup_sel cursor for p_nfs_dup_sel
   # let l_datpas = today - 1 units year

   foreach c_nfs_dup_sel into l_dadosop.socfatpgtdat, l_dadosop.socopgnum
      # let l_datpgt = l_dadosop.socfatpgtdat
      # let l_datpgt = l_datpgt - 1 units year
      # if l_datpas > l_datpgt then
      #    continue foreach
      # end if

      #---> TIPO DE DOCUMENTO <---#
      case param.socpgtdoctip

         when 1
            let l_cts08g01.linha1 = "NOTA FISCAL JA INFORMADA"
         when 2
            let l_cts08g01.linha1 = "RECIBO JA INFORMADO"
         when 3
            let l_cts08g01.linha1 = "R.P.A. JA INFORMADO"
         otherwise
            let l_cts08g01.linha1 = "DOCUMENTO JA INFORMADO"
      end case
      let l_cts08g01.linha2 = "NA O.P. "
                             ,l_dadosop.socopgnum using '&&&&&&&&&&'
                             ," PARA PAGAMENTO"
      let l_cts08g01.linha3 = "EM "
                             ,l_dadosop.socfatpgtdat
                             ,"."
      call cts08g01("A"
                   ,"N"
                   ,l_cts08g01.linha1
                   ,l_cts08g01.linha2
                   ,l_cts08g01.linha3
                   ," ")
         returning l_cts08g01.confirma
      let l_ctb00g01 = "S"

      exit foreach

   end foreach
   if l_dadosop.socopgnum is null then
      let l_ctb00g01 = "N"
   end if

   return l_ctb00g01
end function  ###  ctb00g01_vernfs
# ----------------------------------------------------------------------------
# PREPARAR CURSORES PARA PESQUISA
# ----------------------------------------------------------------------------
function ctb00g01_prep ( )

   # -- OSF 30155 - Fabrica de Software, Katiucia -- #
   define
      l_sql           char(500)

   let l_sql = " select c24evtcod "
                    ," ,caddat "
                ," from datmsrvanlhst "
               ," where atdsrvnum    = ? "
                 ," and atdsrvano    = ? "
                 ," and c24evtcod   <> 0 "
                 ," and srvanlhstseq = 1 "

   prepare p_ctb00g01_001 from l_sql
   declare c_ctb00g01_001 cursor
       for p_ctb00g01_001

   let l_sql = " select c24fsecod "
                    ," ,cadmat "
                ," from datmsrvanlhst "
               ," where atdsrvnum    = ? "
                 ," and atdsrvano    = ? "
                 ," and c24evtcod    = ? "
                 ," and srvanlhstseq = (select max(srvanlhstseq) "
                                       ," from datmsrvanlhst "
                                      ," where atdsrvnum = ? "
                                        ," and atdsrvano = ? "
                                        ," and c24evtcod = ?) "

   prepare p_ctb00g01_002 from l_sql
   declare c_ctb00g01_002 cursor
       for p_ctb00g01_002

   let l_sql = " select c24evtrdzdes "
                ," from datkevt "
               ," where c24evtcod = ? "

   prepare p_ctb00g01_003 from l_sql
   declare c_ctb00g01_003 cursor
       for p_ctb00g01_003

   let l_sql = " select c24fsedes "
                ," from datkfse "
               ," where c24fsecod = ? "

   prepare p_ctb00g01_004 from l_sql
   declare c_ctb00g01_004 cursor
       for p_ctb00g01_004

   let l_sql = " select funnom "
                ," from isskfunc "
               ," where empcod = 1 "
                 ," and funmat = ? "

   prepare p_ctb00g01_005 from l_sql
   declare c_ctb00g01_005 cursor
       for p_ctb00g01_005

   # Busca o nome do segurado itau
   let l_sql = "select distinct segnom ",
               "  from datmitaapl a  ",
               " where a.segcgccpfnum = ?  ",
               "   and a.segcgcordnum = ?  ",
               "   and a.segcgccpfdig = ?  ",
               "   and aplseqnum = (select max(b.aplseqnum) ",
               "                      from datmitaapl b ",
               "                      where a.itaciacod = b.itaciacod    ",
               "                        and   a.itaramcod = b.itaramcod  ",
               "                        and   a.itaaplnum = b.itaaplnum) ",
               "  order by segnom"
   prepare p_ctb00g01_006  from l_sql
   declare c_ctb00g01_006  cursor for p_ctb00g01_006


   # Busca o nome do segurado itau
   let l_sql = "select distinct segnom ",
               "  from datmresitaapl a  ",
               " where a.segcpjcpfnum = ?  ",
               "   and a.cpjordnum = ?  ",
               "   and a.cpjcpfdignum = ?  ",
               "   and aplseqnum = (select max(b.aplseqnum) ",
               "                      from datmresitaapl b ",
               "                      where a.itaciacod = b.itaciacod    ",
               "                        and   a.itaramcod = b.itaramcod  ",
               "                        and   a.aplnum = b.aplnum) ",
               "  order by segnom"
   prepare p_ctb00g01_007  from l_sql
   declare c_ctb00g01_007  cursor for p_ctb00g01_007


end function

# ----------------------------------------------------------------------------
# FUNCAO GENERICA PARA VERIFICACAO E ALERTA DE BLOQUEIO PARA UM SERVICO
# ----------------------------------------------------------------------------
function ctb00g01_srvanl ( l_param )

   # -- OSF 30155 - Fabrica de Software, Katiucia -- #
   define l_param        record
      atdsrvnum          like datmservico.atdsrvnum
     ,atdsrvano          like datmservico.atdsrvano
     ,alertaflg          char(01)
   end record

   define l_ctb00g01     record
      totanl             smallint
     ,c24evtcod          like datkevt.c24evtcod
     ,c24fsecod          like datkevt.c24fsecod
     ,caddat             like datmsrvanlhst.caddat
     ,cadmat             like datmsrvanlhst.cadmat
     ,c24evtcod_svl      like datkevt.c24evtcod
     ,c24fsecod_svl      like datkevt.c24fsecod
     ,caddat_svl         like datmsrvanlhst.caddat
     ,cadmat_svl         like datmsrvanlhst.cadmat
   end record

   define
      l_c24evtrdzdes     like datkevt.c24evtrdzdes
     ,l_c24fsedes        like datkfse.c24fsedes
     ,l_funnom           like isskfunc.funnom
     ,l_msg1             char(80)
     ,l_msg2             char(80)
     ,l_msg3             char(80)
     ,l_msg4             char(80)
     ,l_confirma         char(01)

   let int_flag = false
   error ""

   # ----------------- #
   # PREPARAR CURSORES #
   # ----------------- #
   call ctb00g01_prep()

   let l_prepare = 1

   initialize l_ctb00g01.*   to null
   initialize l_c24evtrdzdes to null
   initialize l_c24fsedes    to null
   initialize l_funnom       to null
   initialize l_msg1         to null
   initialize l_msg2         to null
   initialize l_msg3         to null
   initialize l_msg4         to null

   # -- TOTAL DE ANALISE DO SERVICO -- #
   let l_ctb00g01.totanl = 0

   # ----------------------------------------------- #
   # VERIFICAR SE SERVICO FASE DO SERVICO EM ANALISE #
   # ----------------------------------------------- #
   open c_ctb00g01_001 using l_param.atdsrvnum
                          ,l_param.atdsrvano
   while true
      whenever error continue
      fetch c_ctb00g01_001 into l_ctb00g01.c24evtcod
                             ,l_ctb00g01.caddat
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode <> notfound then
            error "Erro:", sqlca.sqlcode
                 ,", Problemas ao acessar servico em DATMSRVANLHST!"
         end if
         exit while
      end if

      # --------------------------------- #
      # SELECIONAR DADOS EM DATMSRVANLHST #
      # --------------------------------- #
      open c_ctb00g01_002 using l_param.atdsrvnum
                             ,l_param.atdsrvano
                             ,l_ctb00g01.c24evtcod
                             ,l_param.atdsrvnum
                             ,l_param.atdsrvano
                             ,l_ctb00g01.c24evtcod
         whenever error continue
         fetch c_ctb00g01_002 into l_ctb00g01.c24fsecod
                                ,l_ctb00g01.cadmat
         whenever error stop
         if sqlca.sqlcode <> 0 then
            close c_ctb00g01_002
            continue while
         end if
      close c_ctb00g01_002

      if l_ctb00g01.c24fsecod <> 2 and    # --> OK ANALISADO E PAGO
         l_ctb00g01.c24fsecod <> 4 then   # --> NAO PROCEDE
         if l_ctb00g01.totanl = 0 then
            let l_ctb00g01.totanl        = 1
            let l_ctb00g01.c24evtcod_svl = l_ctb00g01.c24evtcod
            let l_ctb00g01.c24fsecod_svl = l_ctb00g01.c24fsecod
            let l_ctb00g01.caddat_svl    = l_ctb00g01.caddat
            let l_ctb00g01.cadmat_svl    = l_ctb00g01.cadmat
         else
            if l_ctb00g01.caddat > l_ctb00g01.caddat_svl then
               let l_ctb00g01.c24evtcod_svl = l_ctb00g01.c24evtcod
               let l_ctb00g01.c24fsecod_svl = l_ctb00g01.c24fsecod
               let l_ctb00g01.caddat_svl    = l_ctb00g01.caddat
               let l_ctb00g01.cadmat_svl    = l_ctb00g01.cadmat
            end if
         end if

         let l_ctb00g01.totanl = l_ctb00g01.totanl + 1
      else
         continue while
      end if

   end while
   close c_ctb00g01_001

   if l_ctb00g01.totanl >  0  and
      l_param.alertaflg = "S" then
      # ------------------------------- #
      # SELECIONAR DESCRICAO EM DATKEVT #
      # ------------------------------- #
      open c_ctb00g01_003 using l_ctb00g01.c24evtcod_svl
         whenever error continue
         fetch c_ctb00g01_003 into l_c24evtrdzdes

         whenever error stop
         if sqlca.sqlcode <> 0 then
            initialize l_c24evtrdzdes to null
         end if
      close c_ctb00g01_003

      # ------------------------------- #
      # SELECIONAR DESCRICAO EM DATKFSE #
      # ------------------------------- #
      open c_ctb00g01_004 using l_ctb00g01.c24fsecod_svl
         whenever error continue
         fetch c_ctb00g01_004 into l_c24fsedes

         whenever error stop
         if sqlca.sqlcode <> 0 then
            initialize l_c24fsedes to null
         end if
      close c_ctb00g01_004

      # ---------------------------------- #
      # SELECIONAR FUNCIONARIO EM ISSKFUNC #
      # ---------------------------------- #
      open c_ctb00g01_005 using l_ctb00g01.cadmat_svl
         whenever error continue
         fetch c_ctb00g01_005 into l_funnom

         whenever error stop
         if sqlca.sqlcode <> 0 then
            initialize l_funnom to null
         end if
      close c_ctb00g01_005

      let l_msg1 = "ULT.ANALISE : ", l_c24evtrdzdes, "."
      let l_msg2 = "FASE .......: ", l_c24fsedes, "."
      let l_msg3 = "ANALISE ....: ", l_funnom, "   ."

      if l_ctb00g01.totanl > 1 then
         let l_msg4 = "ATENCAO : EXISTEM ", l_ctb00g01.totanl using "##&&"
                     ," ANALISES"
      end if

      error " Ordem de servico nao pode ser paga, pendencia(s) em analise!"

      call cts08g01 ( "A"
                     ,"N"
                     ,l_msg1
                     ,l_msg2
                     ,l_msg3
                     ,l_msg4 )
           returning l_confirma

   end if

   return l_ctb00g01.totanl
         ,l_ctb00g01.c24evtcod_svl
         ,l_ctb00g01.c24fsecod_svl

end function

#----------------------------------------------------------------
function ctb00g01_sugere_sucursal(l_ufdcod, l_cidnom)
#----------------------------------------------------------------
# Conforme regra estabelecida entre o Orlando e a area de tributos na ocasiao
# da implantacao do People PSI 198404 para o cadastro dos prestadores existentes
# Programar para transformar em cadastro e retirar o hardcode

  define l_ufdcod like glakcid.ufdcod ,
         l_cidnom like glakcid.cidnom ,
         l_succod like dpaksocor.succod
  let l_succod = null
  if l_ufdcod is null or
     l_ufdcod <= 0
     then
     return l_succod
  end if
  case l_ufdcod
     when 'RJ'  let l_succod = 02
     when 'PE'  let l_succod = 03
     when 'BA'  let l_succod = 04
     when 'TO'  let l_succod = 05
     when 'MG'  let l_succod = 06
     when 'PR'  let l_succod = 07
     when 'MA'  let l_succod = 09
     when 'PA'  let l_succod = 10
     when 'DF'  let l_succod = 11
     when 'ES'  let l_succod = 13
     when 'GO'  let l_succod = 14
     when 'RS'  let l_succod = 15
     when 'SC'  let l_succod = 16
     when 'MT'  let l_succod = 17
     when 'AL'  let l_succod = 18
     when 'RN'  let l_succod = 19
     when 'MS'  let l_succod = 20
     when 'PI'  let l_succod = 23
     when 'PB'  let l_succod = 71
     when 'SE'  let l_succod = 72
     when 'RO'  let l_succod = 73
     when 'RR'  let l_succod = 74
     when 'CE'  let l_succod = 01
     when 'SP'
        case l_cidnom
           # Mogi das Cruzes
           when 'MOGI DAS CRUZES'       let l_succod = 08
           when 'SUZANO'                let l_succod = 08
           when 'POA'                   let l_succod = 08
           when 'FERRAZ DE VASCONCELOS' let l_succod = 08
           # Litoral Paulista
           when 'SANTOS'                let l_succod = 22
           when 'GUARUJA'               let l_succod = 22
           when 'SAO VICENTE'           let l_succod = 22
           when 'PRAIA GRANDE'          let l_succod = 22
           when 'MONGAGUA'              let l_succod = 22
           when 'ITANHAEM'              let l_succod = 22
           when 'PERUIBE'               let l_succod = 22
           when 'REGISTRO'              let l_succod = 22
           # Campinas
           when 'CAMPINAS'              let l_succod = 26
           when 'JUNDIAI'               let l_succod = 26
           when 'MOGI MIRIM'            let l_succod = 26
           when 'INDAIATUBA'            let l_succod = 26
           when 'ITATIBA'               let l_succod = 26
           when 'VALINHOS'              let l_succod = 26
           when 'SUMARE'                let l_succod = 26
           when 'SAO JOAO DA BOA VISTA' let l_succod = 26
           # Vale do paraiba
           when 'SAO JOSE DOS CAMPOS'   let l_succod = 64
           when 'TAUBATE'               let l_succod = 64
           when 'GUARATINGUETA'         let l_succod = 64
           when 'PINDAMONHANGABA'       let l_succod = 64
           when 'JACAREI'               let l_succod = 64
           when 'APARECIDA'             let l_succod = 64
           when 'ATIBAIA'               let l_succod = 64
           when 'CACHOEIRA PAULISTA'    let l_succod = 64
           when 'BERTIOGA'              let l_succod = 64
           when 'SAO SEBASTIAO'         let l_succod = 64
           when 'CARAGUATATUBA'         let l_succod = 64
           when 'UBATUBA'               let l_succod = 64
           # Ribeirao Preto
           when 'RIBEIRAO PRETO'        let l_succod = 65
           when 'SAO CARLOS'            let l_succod = 65
           when 'FRANCA'                let l_succod = 65
           when 'ARARAQUARA'            let l_succod = 65
           # Sorocaba
           when 'SOROCABA'              let l_succod = 66
           when 'SAO ROQUE'             let l_succod = 66
           when 'ITU'                   let l_succod = 66
           when 'SALTO'                 let l_succod = 66
           when 'BOITUVA'               let l_succod = 66
           # Sao Jose do Rio Preto
           when 'SAO JOSE DO RIO PRETO' let l_succod = 67
           when 'BARRETOS'              let l_succod = 67
           when 'CATANDUVA'             let l_succod = 67
           when 'FERNANDOPOLIS'         let l_succod = 67
           # Piracicaba
           when 'PIRACICABA'            let l_succod = 68
           when 'ARARAS'                let l_succod = 68
           when 'AMERICANA'             let l_succod = 68
           when 'LIMEIRA'               let l_succod = 68
           when "SANTA BARBARA D'OESTE" let l_succod = 68
           # Bauru
           when 'BAURU'                 let l_succod = 69
           when 'MARILIA'               let l_succod = 69
           when 'ARACATUBA'             let l_succod = 69
           when 'PRESIDENTE PRUDENTE'   let l_succod = 69
           when 'LINS'                  let l_succod = 69
           when 'BOTUCATU'              let l_succod = 69
           when 'AVARE'                 let l_succod = 69
           # Outras sucursais
           when 'SAO CAETANO DO SUL'    let l_succod = 56
           when 'SAO BERNARDO DO CAMPO' let l_succod = 57
           when 'DIADEMA'               let l_succod = 58
           when 'GUARULHOS'             let l_succod = 59
           when 'SANTO ANDRE'           let l_succod = 60
           when 'MAUA'                  let l_succod = 61
           when 'BARUERI'               let l_succod = 62
           when 'BRAGANCA PAULISTA'     let l_succod = 75
        end case
        if l_succod is null or
           l_succod <= 0
           then
           let l_succod = 01   # SP Matriz
        end if
     when l_ufdcod
        if l_ufdcod = 'AM' or l_ufdcod = 'AC'
           then
           let l_succod = 12
        end if
        if l_ufdcod = 'PA' or l_ufdcod = 'AP'
           then
           let l_succod = 10
        end if
     otherwise
        let l_succod = 01
  end case
  return l_succod
end function


#----------------------------------------------------------------
function ctb00g01_dados_favtip(l_param)
#----------------------------------------------------------------
# definir tipo do favorecido e buscar dados conforme tipo

  define l_param record
         nivel_retorno  smallint               ,
         pstcoddig      like dbsmopg.pstcoddig ,
         segnumdig      like dbsmopg.segnumdig ,
         lcvcod         like dbsmopg.lcvcod    ,
         aviestcod      like dbsmopg.aviestcod ,
         corsus         like dbsmopg.corsus    ,
         empcod         like dbsmopg.empcod    ,
         cgccpfnum      like dbsmopg.cgccpfnum ,
         cgcord         like dbsmopg.cgcord    ,
         cgccpfdig      like dbsmopg.cgccpfdig ,
         favtip         smallint
  end record
  define l_fav record
         errcod      smallint ,
         msg         char(80) ,
         favtip      smallint ,
         favtipcod1  char(08) ,
         favtipcod2  char(08) ,
         favtipcab1  char(14) ,
         favtipcab2  char(14) ,
         favtipnom1  char(40) ,
         favtipnom2  char(40) ,
         favtipdes   char(10)
  end record
  define l_ret  smallint
       , l_simoptpstflg    like dpaksocor.simoptpstflg
  let l_ret = null
  initialize l_fav.* to null
  let l_simoptpstflg  = null
  let l_fav.errcod = 0
  if l_param.segnumdig is not null  or   # Segurado
     l_param.favtip = 3  or
     l_param.pstcoddig = 3  or
     l_param.lcvcod = 33
     then
     let l_fav.favtipcod1 = l_param.segnumdig using "&&&&&&&&"
     let l_fav.favtipcab1 = "Segurado.....:"
     let l_fav.favtip = 3
     let l_fav.favtipdes  = 'SEGURADO'
     # Tratar quando precisar buscar segurado ISAR para reembolso

     case l_param.empcod
        when 1
           call ctd20g07_nome_cli(l_param.segnumdig)
                returning l_fav.errcod, l_fav.msg, l_fav.favtipnom1
        when 35
           call ctd02g01_azlapl_sel(2, l_param.cgccpfnum, l_param.cgcord,
                                    l_param.cgccpfdig)
                returning l_fav.errcod, l_fav.msg, l_fav.favtipnom1

        when 84
            call ctb00g01_seg_itau(l_param.cgccpfnum, l_param.cgcord,
                                            l_param.cgccpfdig)
                 returning l_fav.favtipnom1,
                           l_fav.errcod,
                           l_fav.msg

     end case
  else
     if (l_param.pstcoddig is not null and   # Prestador
         l_param.pstcoddig > 0) or
        l_param.favtip = 1
        then
        call ctd12g00_dados_pst2(7, l_param.pstcoddig)
             returning l_fav.errcod, l_fav.msg, l_fav.favtipnom1
                     , l_simoptpstflg                           #PSI-11-19199PR
        if l_fav.errcod != 0
           then
           let l_fav.msg = " Erro (", l_fav.errcod, ") na leitura do prestador "
        end if
        let l_fav.favtipcod1 = l_param.pstcoddig using "&&&&&&"
        let l_fav.favtipcab1 = "Prestador....:"
        let l_fav.favtip = 1
        let l_fav.favtipdes  = 'PRESTADOR'
     else
        if (l_param.corsus is not null and    # Corretor
            l_param.lcvcod    is null  and
            l_param.segnumdig is null) or
           l_param.favtip = 2
           then
           call cty00g00_nome_corretor(l_param.corsus)
                returning l_ret, l_fav.msg, l_fav.favtipnom1
           if l_ret != 1
              then
              let l_fav.errcod = 999
           end if
           let l_fav.favtipcod1 = l_param.corsus
           let l_fav.favtipcab1 = "Corretor.....:"
           let l_fav.favtip = 2
           let l_fav.favtipdes  = 'CORRETOR'
        else
           if (l_param.lcvcod is not null and   # Locadora
               l_param.segnumdig is null) or
              l_param.favtip = 4
              then
              call ctd19g00_nome_loja(l_param.lcvcod, l_param.aviestcod)
                   returning l_fav.errcod, l_fav.msg, l_fav.favtipnom1,
                             l_fav.favtipnom2, l_fav.favtipcod2
              let l_fav.favtipcod1 = l_param.lcvcod
              let l_fav.favtipcab1 = "Cod.Locadora.:"
              let l_fav.favtipcab2 = "Cod.Loja.....:"
              let l_fav.favtip = 4
              let l_fav.favtipdes  = 'LOCADORA'
           else
              let l_fav.favtip = 999  # Nao identificado
              let l_fav.errcod = 999
           end if
        end if
     end if
  end if
  if l_param.nivel_retorno = 1
     then
     return l_fav.errcod, l_fav.msg, l_fav.favtip,
            l_fav.favtipcod1, l_fav.favtipcab1, l_fav.favtipnom1
  end if
  if l_param.nivel_retorno = 2
     then
     return l_fav.errcod, l_fav.msg, l_fav.favtip,
            l_fav.favtipcod1, l_fav.favtipcab1, l_fav.favtipnom1,
            l_fav.favtipcod2, l_fav.favtipcab2, l_fav.favtipnom2
  end if
  if l_param.nivel_retorno = 3
     then
     return l_fav.errcod, l_fav.msg, l_fav.favtip,
            l_fav.favtipcod1, l_fav.favtipcab1, l_fav.favtipnom1,
            l_fav.favtipdes
  end if
  if l_param.nivel_retorno = 4
     then
     return l_fav.errcod, l_fav.msg, l_fav.favtip,
            l_fav.favtipcod1, l_fav.favtipcab1, l_fav.favtipnom1,
            l_fav.favtipcod2, l_fav.favtipcab2, l_fav.favtipnom2,
            l_fav.favtipdes
  end if
  if l_param.nivel_retorno = 5
     then
     return l_fav.errcod, l_fav.msg,
            l_fav.favtip, l_fav.favtipnom1, l_fav.favtipdes
  end if
  if l_param.nivel_retorno = 6
     then
     return l_fav.errcod, l_fav.msg,
            l_fav.favtip, l_fav.favtipnom1, l_fav.favtipnom2, l_fav.favtipcod2,
            l_fav.favtipdes
  end if
  if l_param.nivel_retorno = 7                     # ini PSI-11-19199PR
     then
     return l_fav.errcod, l_fav.msg, l_fav.favtip,
            l_fav.favtipcod1, l_fav.favtipcab1, l_fav.favtipnom1
          , l_simoptpstflg
  end if                                           # fim PSI-11-19199PR
end function

#----------------------------------------------------------------
function ctb00g01_seg_itau(l_param)
#----------------------------------------------------------------

define l_param record
  segcgccpfnum  like datmitaapl.segcgccpfnum  ,
  segcgcordnum  like datmitaapl.segcgcordnum  ,
  segcgccpfdig  like datmitaapl.segcgccpfdig
end record

define lr_retorno record
   segnom   like datmitaapl.segnom,
   errocod  smallint,
   erromsg  char(80)
end record

if l_prepare <> 1 then
   call ctb00g01_prep()
end if


initialize lr_retorno.* to null

if l_param.segcgcordnum is null or
   l_param.segcgcordnum = ' ' then
   let l_param.segcgcordnum = 0
end if

whenever error continue
   open c_ctb00g01_006 using l_param.segcgccpfnum,
                             l_param.segcgcordnum,
                             l_param.segcgccpfdig

   fetch c_ctb00g01_006 into lr_retorno.segnom
   if sqlca.sqlcode <> 0 then

      if sqlca.sqlcode = notfound then
         open c_ctb00g01_007 using l_param.segcgccpfnum,
                                   l_param.segcgcordnum,
                                   l_param.segcgccpfdig

         fetch c_ctb00g01_007 into lr_retorno.segnom
         if sqlca.sqlcode <> 0 then
           let lr_retorno.errocod = sqlca.sqlcode
           let lr_retorno.erromsg = 'Erro(',sqlca.sqlcode,') ao localizar o nome do segurado - ',
                                    l_param.segcgccpfnum,l_param.segcgcordnum,'-',l_param.segcgccpfdig
         else
            let lr_retorno.errocod = sqlca.sqlcode
            let lr_retorno.erromsg = ' '
         end if
         close c_ctb00g01_007

      else
         let lr_retorno.errocod = sqlca.sqlcode
         let lr_retorno.erromsg = 'Erro(',sqlca.sqlcode,') ao localizar o nome do segurado - ',
                                  l_param.segcgccpfnum,l_param.segcgcordnum,'-',l_param.segcgccpfdig
      end if
   else
      let lr_retorno.errocod = sqlca.sqlcode
      let lr_retorno.erromsg = ' '
   end if
   close c_ctb00g01_006

whenever error stop

return lr_retorno.segnom,
       lr_retorno.errocod,
       lr_retorno.erromsg

end function
