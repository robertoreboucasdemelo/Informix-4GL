# --------------------------------------------------------------------------#
# Nome do Modulo: CTB03m00                                         Wagner   #
#                                                                           #
# Tela de consulta de servico                                      Mai/2001 #
# --------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/07/2001  PSI 13448-1  Wagner       Inclusao do item LIGACOES para con- #
#                                       sulta referente a apolice do servico#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#                     * * * A L T E R A C A O * * *                         #
#---------------------------------------------------------------------------#
#  Analista Resp. : Raji                             OSF : 30155            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 16/12/2003       #
#  Objetivo       : Substituir o codigo de pesquisa de bloqueio de servico  #
#                   pela chamada da funcao de pesquisa ctb00g01_srvanl.     #
#---------------------------------------------------------------------------#
#  18/03/2004 OSF 33367    Teresinha S.  Inclusao do motivo 6               #
# --------------------------------------------------------------------------#
#  16/12/2006 psi 205206   Ruiz          Alterar descr.motivo 3 para Azul.  #
#---------------------------------------------------------------------------#
# 29/12/2009 Amilton,Meta                Projeto SUCCOD - Smallint          #
#---------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define k_ctb03m00   record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

#-----------------------------------------------------------
 function ctb03m00(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define ws           record
    time             char (11),
    hoje             char (10),
    hora             char (05)
 end record

 initialize k_ctb03m00.* to null

 let ws.hoje = today
 let ws.time = time
 let ws.hora = ws.time[1,5]

 let int_flag = false

 open window ctb03m00 at 04,02 with form "ctb03m00"
 display "/" at 02,13
 display "-" at 02,21
 display "-" at 04,21

 menu "SERVICO"

 #  before menu
 #         hide option all
 #         if get_niv_mod(g_issk.prgsgl,"ctb03m00")  then        ## NIVEL 1
 #            if g_issk.acsnivcod >= g_issk.acsnivcns  then
 #               show option "Seleciona","Prestador","Historico",
 #                           "pesQuisa", "Acompanhamento"
 #            end if
 #         end if
 #         show option "Encerra"

    command key ("S") "Seleciona"
                      "Seleciona servico para consulta"
            clear form
            call seleciona_ctb03m00(param.*) returning k_ctb03m00.*
            if k_ctb03m00.atdsrvnum is not null  then
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("H") "Historico"
                     "Exibe historico do servico selecionado"
           if k_ctb03m00.atdsrvnum is not null  then
               call cts10n00(k_ctb03m00.atdsrvnum, k_ctb03m00.atdsrvano,
                             g_issk.funmat       , ws.hoje  , ws.hora  )
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("Q") "pesQuisa"
                     "Pesquisa por data, tipo, placa, ou nome do solicitante"
              call ctb12m07() returning k_ctb03m00.atdsrvnum,
                                         k_ctb03m00.atdsrvano
              if k_ctb03m00.atdsrvnum  is not null   and
                 k_ctb03m00.atdsrvano  is not null   then
                 error "Selecione e tecle ENTER!"
                 next option "Seleciona"
              else
                 error " Nenhum servico foi selecionado!"
              end if

   command key ("A") "Acompanhamento"
                     "Acompanhamento do servico selecionado"
           if k_ctb03m00.atdsrvnum is not null then
              call cts00m11(k_ctb03m00.atdsrvnum, k_ctb03m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("L") "Ligacoes"
                     "Ligacoes referente a apolice deste servico"
           if k_ctb03m00.atdsrvnum is not null then
              call ligacoes_ctb03m00(k_ctb03m00.atdsrvnum, k_ctb03m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("P") "Previsao"
                     "Manutencao na previsao inicial da reserva"
           if k_ctb03m00.atdsrvnum is not null then
              call previsao_ctb03m00(k_ctb03m00.atdsrvnum, k_ctb03m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu

 close window ctb03m00

end function  ###  ctb03m00

#-----------------------------------------------------------
 function seleciona_ctb03m00(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_ctb03m00  record
    atdsrvorg       like datmservico.atdsrvorg   ,
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano   ,
    c24solnom       like datmligacao.c24solnom   ,
    nom             like datmservico.nom         ,
    doctxt          char (32)                    ,
    corsus          like datmservico.corsus      ,
    cornom          like datmservico.cornom      ,
    cvnnom          char (15)                    ,
    vclcoddig       like datmservico.vclcoddig   ,
    vcldes          like datmservico.vcldes      ,
    vclanomdl       like datmservico.vclanomdl   ,
    vcllicnum       like datmservico.vcllicnum   ,
    vclcordes       char (12)                    ,
    c24astcod       like datkassunto.c24astcod   ,
    c24astdes       like datkassunto.c24astdes   ,
    lcvcod          like datklocadora.lcvcod     ,
    lcvnom          like datklocadora.lcvnom     ,
    lcvextcod       like datkavislocal.lcvextcod ,
    aviestnom       like datkavislocal.aviestnom ,
    avilocnom       like datmavisrent.avilocnom  ,
    cttdddcod       like datmavisrent.cttdddcod  ,
    ctttelnum       like datmavisrent.ctttelnum  ,
    avialgmtv       like datmavisrent.avialgmtv  ,
    avimtvdes       char (16)                    ,
    aviretdat       like datmavisrent.aviretdat  ,
    aviproflg       char (01)                    ,
    atdcstvlr       like datmservico.atdcstvlr   ,
    socopgnum       like dbsmopg.socopgnum       ,
    atdlibtxt       char (64)
 end record

 define ws          record
    lignum          like datrligsrv.lignum       ,
    ligcvntip       like datmligacao.ligcvntip   ,
    succod          like datrligapol.succod      ,
    ramcod          like datrligapol.ramcod      ,
    aplnumdig       like datrligapol.aplnumdig   ,
    itmnumdig       like datrligapol.itmnumdig   ,
    edsnumref       like datrligapol.edsnumref   ,
    prporg          like datrligprp.prporg       ,
    prpnumdig       like datrligprp.prpnumdig    ,
    fcapacorg       like datrligpac.fcapacorg    ,
    fcapacnum       like datrligpac.fcapacnum    ,
    vclcorcod       like datmservico.vclcorcod   ,
    atddat          like datmservico.atddat      ,
    atdhor          like datmservico.atdhor      ,
    funmat          like datmservico.funmat      ,
    funnom          char (14)                    ,
    dptsgl          like isskfunc.dptsgl         ,
    atdlibdat       like datmservico.atdlibdat   ,
    atdlibhor       like datmservico.atdlibhor   ,
    socfatentdat    like dbsmopg.socfatentdat    ,
    pgtdat          like datmservico.pgtdat      ,
    sqlcode         integer                      ,
    c24evtcod       like datkevt.c24evtcod       ,
    c24evtcod_svl   like datkevt.c24evtcod       ,
    c24evtrdzdes    like datkevt.c24evtrdzdes    ,
    c24fsecod       like datkfse.c24fsecod       ,
    c24fsecod_svl   like datkfse.c24fsecod       ,
    c24fsedes       like datkfse.c24fsedes       ,
    cadmat          like datmsrvanlhst.cadmat    ,
    cadmat_svl      like datmsrvanlhst.cadmat    ,
    caddat          like datmsrvanlhst.caddat    ,
    caddat_svl      like datmsrvanlhst.caddat    ,
    funnom_hst      char (25)                    ,
    msg1            char (40)                    ,
    msg2            char (40)                    ,
    msg3            char (40)                    ,
    msg4            char (40)                    ,
    totanl          integer                      ,
    confirma        char (01)                    ,
    aviestcod       like datkavislocal.aviestcod ,
    countop         integer                      ,
    count           integer                      ,
    ciaempcod       like datmservico.ciaempcod   ,
    itaciacod       like datrligitaaplitm.itaciacod 
 end record

 let int_flag = false
 initialize d_ctb03m00.*   to null
 initialize ws.*           to null

 if param.atdsrvnum is not null and
    param.atdsrvano is not null then
    let k_ctb03m00.atdsrvnum = param.atdsrvnum
    let k_ctb03m00.atdsrvano = param.atdsrvano
 end if

 input by name k_ctb03m00.atdsrvnum,
               k_ctb03m00.atdsrvano  without defaults

      before field atdsrvnum
         display by name k_ctb03m00.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name k_ctb03m00.atdsrvnum

         if k_ctb03m00.atdsrvnum   is null   then
            error "Informe o numero do servico!"
            next field atdsrvnum
         end if

      before field atdsrvano
         display by name k_ctb03m00.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name k_ctb03m00.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if k_ctb03m00.atdsrvano   is null   then
            error "Informe o ano do servico!"
            next field atdsrvano
         end if
         select atdsrvorg
           into d_ctb03m00.atdsrvorg
           from datmservico
          where atdsrvnum = k_ctb03m00.atdsrvnum
            and atdsrvano = k_ctb03m00.atdsrvano

         if sqlca.sqlcode = notfound then
            error " Servico nao encontrado!"
            next field atdsrvano
         else
            if d_ctb03m00.atdsrvorg <> 8 then
               error " Consulta disponivel somente para servicos de Locacao de veiculos!"
               next field atdsrvano
            end if
         end if
         display "/" at 04,13
         display by name d_ctb03m00.atdsrvorg

    on key (interrupt)
        exit input

 end input

 if int_flag  then
    let int_flag = false
    error "Operacao cancelada!"
    clear form
    initialize k_ctb03m00.* to null
    initialize d_ctb03m00.* to null
    return d_ctb03m00.atdsrvnum, d_ctb03m00.atdsrvano
 end if

 let d_ctb03m00.atdsrvnum = k_ctb03m00.atdsrvnum
 let d_ctb03m00.atdsrvano = k_ctb03m00.atdsrvano

 select datmservico.atdsrvorg , datmservico.nom       ,
        datmservico.cornom    , datmservico.corsus    ,
        datmservico.vclcoddig , datmservico.vcldes    ,
        datmservico.vclanomdl , datmservico.vcllicnum ,
        datmservico.vclcorcod , datmservico.atddat    ,
        datmservico.atdhor    , datmservico.funmat    ,
        datmservico.pgtdat    , datmservico.atdcstvlr ,
        datmservico.atdlibdat , datmservico.atdlibhor ,
        datmservico.ciaempcod
   into d_ctb03m00.atdsrvorg  , d_ctb03m00.nom        ,
        d_ctb03m00.cornom     , d_ctb03m00.corsus     ,
        d_ctb03m00.vclcoddig  , d_ctb03m00.vcldes     ,
        d_ctb03m00.vclanomdl  , d_ctb03m00.vcllicnum  ,
        ws.vclcorcod          , ws.atddat             ,
        ws.atdhor             , ws.funmat             ,
        ws.pgtdat             , d_ctb03m00.atdcstvlr  ,
        ws.atdlibdat          , ws.atdlibhor          ,
        ws.ciaempcod
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = d_ctb03m00.atdsrvnum
    and datmservico.atdsrvano    = d_ctb03m00.atdsrvano
    and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
    and datmservicocmp.atdsrvano = datmservico.atdsrvano

#--------------------------------------------------------------------
# Dados da Ligacao
#--------------------------------------------------------------------

 let ws.lignum = cts20g00_servico(d_ctb03m00.atdsrvnum, d_ctb03m00.atdsrvano)

 call cts20g01_docto(ws.lignum) returning ws.succod,
                                          ws.ramcod,
                                          ws.aplnumdig,
                                          ws.itmnumdig,
                                          ws.edsnumref,
                                          ws.prporg,
                                          ws.prpnumdig,
                                          ws.fcapacorg,
                                          ws.fcapacnum,
                                          ws.itaciacod
 if ws.succod    is not null  and
    ws.ramcod    is not null  and
    ws.aplnumdig is not null  and
    ws.itmnumdig is not null  then
    let d_ctb03m00.doctxt = "Apolice.: ", ws.succod    using "###&&"     , " ", #using "&&"        , " ",  # projeto Succod
                                          ws.ramcod    using "&&&&"      , " ",
                                          ws.aplnumdig using "<<<<<<<& &"
 else
    if ws.prporg    is not null  and
       ws.prpnumdig is not null  then
       let d_ctb03m00.doctxt = "Proposta: ", ws.prporg    using "&&"      , " ",
                                             ws.prpnumdig using "<<<<<<<&"
    else
       if ws.fcapacorg is not null  and
          ws.fcapacnum is not null  then
          let d_ctb03m00.doctxt = "PAC.....: ", ws.fcapacorg using "&&", " ",
                                                ws.fcapacnum using "<<<<<<<&"
       else
          let d_ctb03m00.doctxt    = "** LAUDO EM BRANCO **"
       end if
    end if
 end if

 select c24astcod, ligcvntip,
        c24solnom
   into d_ctb03m00.c24astcod,
        ws.ligcvntip,
        d_ctb03m00.c24solnom
   from datmligacao
  where lignum  =  ws.lignum

#-----------------------  CONVENIO  ------------------------

 select cpodes into d_ctb03m00.cvnnom
   from iddkdominio
  where cponom  =  "ligcvntip" and
        cpocod  =  ws.ligcvntip

#-----------------  DESCRICAO DO ASSUNTO  ------------------

 call c24geral8(d_ctb03m00.c24astcod)
      returning d_ctb03m00.c24astdes

#-----------------  DESCRICAO DA COR  ----------------------

 select cpodes into d_ctb03m00.vclcordes
   from iddkdominio
  where cponom  = "vclcorcod"  and
        cpocod  = ws.vclcorcod

#------------------  NOME DO FUNCIONARIO  ------------------

 let ws.funnom = "** NAO CADASTRADO **"
 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = 1
    and funmat  =  ws.funmat

 let d_ctb03m00.atdlibtxt = ws.atddat                 clipped, " " ,
                            ws.atdhor                 clipped, " " ,
                            upshift(ws.dptsgl)        clipped, " " ,
                            ws.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)        clipped, "  ",
                            ws.atdlibdat              clipped, " " ,
                            ws.atdlibhor


#-------------------  DADOS DA RESERVA --------------------

 select datmavisrent.lcvcod   , datmavisrent.aviestcod,
        datmavisrent.avilocnom, datmavisrent.cttdddcod,
        datmavisrent.ctttelnum, datmavisrent.avialgmtv,
        datmavisrent.aviretdat
   into d_ctb03m00.lcvcod   , ws.aviestcod,
        d_ctb03m00.avilocnom, d_ctb03m00.cttdddcod,
        d_ctb03m00.ctttelnum, d_ctb03m00.avialgmtv,
        d_ctb03m00.aviretdat
   from datmavisrent
  where datmavisrent.atdsrvnum = d_ctb03m00.atdsrvnum
    and datmavisrent.atdsrvano = d_ctb03m00.atdsrvano

 let d_ctb03m00.lcvnom = "NAO ENCONTRADA!"
 select datklocadora.lcvnom
   into d_ctb03m00.lcvnom
   from datklocadora
  where datklocadora.lcvcod = d_ctb03m00.lcvcod

 let d_ctb03m00.aviestnom = "NAO ENCONTRADA!"
 let d_ctb03m00.lcvextcod = "NAO ENC!"
 select datkavislocal.aviestnom, datkavislocal.lcvextcod
   into d_ctb03m00.aviestnom   , d_ctb03m00.lcvextcod
   from datkavislocal
  where datkavislocal.lcvcod    = d_ctb03m00.lcvcod
    and datkavislocal.aviestcod = ws.aviestcod


 call ctb02m06_motivo(d_ctb03m00.avialgmtv,ws.ciaempcod)
              returning d_ctb03m00.avimtvdes
              
 let ws.count = 0
 select count(*)
   into ws.count
   from datmprorrog
  where datmprorrog.atdsrvnum = d_ctb03m00.atdsrvnum
    and datmprorrog.atdsrvano = d_ctb03m00.atdsrvano

 let d_ctb03m00.aviproflg = "N"
 if ws.count is not null   and
    ws.count <> 0          then
    let d_ctb03m00.aviproflg = "S"
 end if

#------------------- NUMERO DA O.P. ----------------------
 let ws.countop = 0
 select count(*)
   into ws.countop
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum = k_ctb03m00.atdsrvnum
    and dbsmopgitm.atdsrvano = k_ctb03m00.atdsrvano
    and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
    and dbsmopg.socopgsitcod <> 8

 if ws.countop > 1 then
    initialize d_ctb03m00.socopgnum, ws.socfatentdat to null
 else
    select dbsmopg.socopgnum   , dbsmopg.socfatentdat
      into d_ctb03m00.socopgnum, ws.socfatentdat
      from dbsmopgitm, dbsmopg
     where dbsmopgitm.atdsrvnum  =  d_ctb03m00.atdsrvnum  and
           dbsmopgitm.atdsrvano  =  d_ctb03m00.atdsrvano  and
           dbsmopgitm.socopgnum  =  dbsmopg.socopgnum     and
           dbsmopg.socopgsitcod  <> 8
 end if

 display by name d_ctb03m00.*

 if ws.countop is not null and
    ws.countop > 1         then
    call ctb03m05(k_ctb03m00.atdsrvnum,
                  k_ctb03m00.atdsrvano)
 end if

 if d_ctb03m00.atdcstvlr is not null  and
    ws.socfatentdat      is null      and
    ws.pgtdat            is null      then
    error " Ja' existe acerto de valor para este servico!"
 end if

 # -- OSF 30155 - Fabrica de Software, Katiucia -- #
 # ---------------------------------------------- #
 # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
 # ---------------------------------------------- #
 call ctb00g01_srvanl ( d_ctb03m00.atdsrvnum
                       ,d_ctb03m00.atdsrvano
                       ,"S" )
      returning ws.totanl
               ,ws.c24evtcod
               ,ws.c24fsecod

 ## VERIFICA SE SERVICO JA ESTEVE EM ANALISE
 ## declare c_datmsrvanlhst cursor for
 ##  select c24evtcod, caddat
 ##    from datmsrvanlhst
 ##   where atdsrvnum    =  d_ctb03m00.atdsrvnum
 ##     and atdsrvano    =  d_ctb03m00.atdsrvano
 ##     and c24evtcod    <> 0
 ##     and srvanlhstseq =  1
 ##
 ## let ws.totanl = 0   # total de analise do servico

 ## foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

 ##    select c24fsecod, cadmat
 ##      into ws.c24fsecod, ws.cadmat
 ##      from datmsrvanlhst
 ##     where atdsrvnum    =  d_ctb03m00.atdsrvnum
 ##       and atdsrvano    =  d_ctb03m00.atdsrvano
 ##       and c24evtcod    =  ws.c24evtcod
 ##       and srvanlhstseq = (select max(srvanlhstseq)
 ##                             from datmsrvanlhst
 ##                            where atdsrvnum  =  d_ctb03m00.atdsrvnum
 ##                              and atdsrvano  =  d_ctb03m00.atdsrvano
 ##                              and c24evtcod  =  ws.c24evtcod)

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
 ##    initialize ws.c24evtrdzdes, ws.c24fsedes to null
 ##    select c24evtrdzdes
 ##      into ws.c24evtrdzdes
 ##      from datkevt
 ##     where datkevt.c24evtcod = ws.c24evtcod_svl

 ##    select c24fsedes
 ##      into ws.c24fsedes
 ##      from datkfse
 ##     where datkfse.c24fsecod = ws.c24fsecod_svl

 ##    select funnom
 ##      into ws.funnom_hst
 ##      from isskfunc
 ##     where empcod = 1
 ##       and funmat = ws.cadmat_svl

 ##    let ws.msg1 = "ULT.ANALISE : ",ws.c24evtrdzdes,"."
 ##    let ws.msg2 = "FASE ...... : ",ws.c24fsedes,"."
 ##    let ws.msg3 = "ANALISTA... : ",ws.funnom_hst,"."
 ##    if ws.totanl > 1 then
 ##       let ws.msg4 = "ATENCAO:  EXISTEM ", ws.totanl using "&&"," ANALISES"
 ##    end if

 ##    call cts08g01("A","N", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
 ##         returning ws.confirma
 ## end if

 return d_ctb03m00.atdsrvnum, d_ctb03m00.atdsrvano

end function  ###  seleciona_ctb03m00

#-----------------------------------------------------------
 function ligacoes_ctb03m00(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define ws          record
    lignum          like datrligsrv.lignum       ,
    succod          like datrligapol.succod      ,
    ramcod          like datrligapol.ramcod      ,
    aplnumdig       like datrligapol.aplnumdig   ,
    itmnumdig       like datrligapol.itmnumdig   ,
    edsnumref       like datrligapol.edsnumref   ,
    prporg          like datrligprp.prporg       ,
    prpnumdig       like datrligprp.prpnumdig    ,
    fcapacorg       like datrligpac.fcapacorg    ,
    fcapacnum       like datrligpac.fcapacnum    ,
    crtsaunum       like datrligsau.crtnum       ,
    itaciacod       like datrligitaaplitm.itaciacod   
 end record

 let int_flag = false
 initialize ws.*           to null

 let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)

 call cts20g01_docto(ws.lignum) returning ws.succod,
                                          ws.ramcod,
                                          ws.aplnumdig,
                                          ws.itmnumdig,
                                          ws.edsnumref,
                                          ws.prporg,
                                          ws.prpnumdig,
                                          ws.fcapacorg,
                                          ws.fcapacnum,
                                          ws.itaciacod    

  call cts20g09_docto(1, ws.lignum) returning ws.crtsaunum

 if (ws.succod    is not null   and
     ws.ramcod    is not null   and
     ws.aplnumdig is not null)  or
    (ws.prporg    is not null   and
     ws.prpnumdig is not null)  or
    (ws.fcapacorg is not null   and
     ws.fcapacnum is not null)  or
     ws.crtsaunum is not null   then

     call ctp01m01(ws.succod   , ws.ramcod   ,
                   ws.aplnumdig, ws.itmnumdig,
                   ws.prporg   , ws.prpnumdig,
                   ws.fcapacorg, ws.fcapacnum,
                   ws.crtsaunum)
 else
    error " Servico sem documento informado!"
 end if

end function  ###  ligacoes_ctb03m00

#-----------------------------------------------------------
 function previsao_ctb03m00(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define ws          record
    avialgmtv       like datmavisrent.avialgmtv  ,
    aviretdat       like datmavisrent.aviretdat  ,
    avirethor       like datmavisrent.avirethor  ,
    aviprvent       like datmavisrent.aviprvent  ,
    aviprvent_svl   like datmavisrent.aviprvent  ,
    cct             integer
 end record

 let int_flag = false
 initialize ws.*           to null

#-------------------  DADOS DA RESERVA --------------------
 select datmavisrent.avialgmtv, datmavisrent.aviretdat,
        datmavisrent.avirethor, datmavisrent.aviprvent
   into ws.avialgmtv , ws.aviretdat,
        ws.avirethor , ws.aviprvent
   from datmavisrent
  where datmavisrent.atdsrvnum = param.atdsrvnum
    and datmavisrent.atdsrvano = param.atdsrvano

 let ws.aviprvent_svl = ws.aviprvent

 call cts15m04("A"         , ws.avialgmtv,
               ""          , ws.aviretdat,
               ws.avirethor, ws.aviprvent,
              #""          , ""          ) -- OSF 33367
               ""          , "" , ""     )
     returning ws.aviretdat, ws.avirethor,
               ws.aviprvent, ws.cct, ws.cct, ws.cct

 if ws.aviprvent is not null         and
    ws.aviprvent <> 0                and
    ws.aviprvent <> ws.aviprvent_svl then
    whenever error continue
    begin work
      update datmavisrent set aviprvent = ws.aviprvent
       where datmavisrent.atdsrvnum = param.atdsrvnum
         and datmavisrent.atdsrvano = param.atdsrvano

      if sqlca.sqlcode = 0  then
         commit work
      else
         rollback work
      end if
    whenever error stop
 end if

 let int_flag = false

end function  ###  previsao_ctb03m00
