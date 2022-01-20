#############################################################################
# Nome do Modulo: CTS20M00                                         Marcelo  #
#                                                                  Gilberto #
# Tela de consulta de servico (Lau_ct24h)                          Abr/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 14/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 11/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 14/02/2001               Raji         Atalho p/ visualizacao Pto Referecia#
#---------------------------------------------------------------------------#
# 21/08/2001  PSI 11153-8  Raji         Servico de JIT (processo)           #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
# 13/08/2009  Sergio Burini       PSI.244236     Inclusão do Sub-Dairro     #
#---------------------------------------------------------------------------#
# 04/01/2010  Amilton                   Projeto Sucursal smallint           #    
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define k_cts20m00   record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdsrvorg        like datmservico.atdsrvorg
 end record

 define d_cts20m00  record
    atdsrvorg       like datmservico.atdsrvorg   ,
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano   ,
    srvtipabvdes    like datksrvtip.srvtipabvdes ,
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
    vclcor          char (12)                    ,
    livre           char (37)                    ,
    c24astcod       like datkassunto.c24astcod   ,
    c24astdes       like datkassunto.c24astdes   ,
    lgdtxt          char (65)                    ,
    lclbrrnom       like datmlcl.lclbrrnom       ,
    cidnom          like datmlcl.cidnom          ,
    ufdcod          like datmlcl.ufdcod          ,
    dddcod          like datmlcl.dddcod          ,
    lcltelnum       like datmlcl.lcltelnum       ,
    lclcttnom       like datmlcl.lclcttnom       ,
    lclrefptotxt    like datmlcl.lclrefptotxt    ,
    endzon          like datmlcl.endzon          ,
    atdlibtxt       char (64)                    ,
    tmptxt          char (30)                    ,
    asitipdes       like datkasitip.asitipdes    ,
    pgtdat          like datmservico.pgtdat      ,
    atdcstvlr       like datmservico.atdcstvlr   ,
    socopgnum       like dbsmopg.socopgnum
 end record

 define a_cts20m00    array[2] of record
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (80)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    endcmp            like datmlcl.endcmp
 end record

 define arr_aux       smallint

 define ws          record
    lignum          like datrligsrv.lignum       ,
    atdsrvorg       like datmservico.atdsrvorg   ,
    asitipcod       like datmservico.asitipcod   ,
    atddatprg       like datmservico.atddatprg   ,
    atdhorprg       like datmservico.atdhorprg   ,
    atdhorpvt       like datmservico.atdhorpvt   ,
    ligcvntip       like datmligacao.ligcvntip   ,
    succod          like datrservapol.succod     ,
    ramcod          like datrservapol.ramcod     ,
    aplnumdig       like datrservapol.aplnumdig  ,
    itmnumdig       like datrservapol.itmnumdig  ,
    vclcorcod       like datmservico.vclcorcod   ,
    atddfttxt       like datmservico.atddfttxt   ,
    sindat          like datmservicocmp.sindat   ,
    bocnum          like datmservicocmp.bocnum   ,
    bocemi          like datmservicocmp.bocemi   ,
    vclchsinc       like abbmveic.vclchsinc      ,
    vclchsfnl       like abbmveic.vclchsfnl      ,
    emitecarta      char (01)                    ,
    atddat          like datmservico.atddat      ,
    atdhor          like datmservico.atdhor      ,
    funmat          like datmservico.funmat      ,
    funnom          char (15)                    ,
    dptsgl          like isskfunc.dptsgl         ,
    atdlibhor       like datmservico.atdlibhor   ,
    atdlibdat       like datmservico.atdlibdat   ,
    sqlcode         integer
 end record
 
 define m_lclbrrnom char(65)

#-----------------------------------------------------------
 function cts20m00()
#-----------------------------------------------------------

 define ws           record
    time             char (11),
    hoje             char (10),
    hora             char (05)
 end record

 initialize k_cts20m00.* to null
 initialize d_cts20m00.* to null
 initialize ws.*         to null

 let ws.hoje = today
 let ws.time = time
 let ws.hora = ws.time[1,5]

 let int_flag = false

 open window cts20m00 at 04,02 with form "cts20m00"

 menu "SERVICO"

    command key ("S") "Seleciona"
                      "Seleciona servico para consulta"
            clear form
            call seleciona_cts20m00() returning k_cts20m00.*
            if k_cts20m00.atdsrvnum is not null  then
               next option "Destino"
            else
               error " Nenhum servico selecionado!"
               next option "Seleciona"
            end if

   command key ("D") "Destino"
                     "Destino do veiculo"
           if k_cts20m00.atdsrvnum is not null then
              call cts06g08(k_cts20m00.atdsrvnum,
                            k_cts20m00.atdsrvano,
                            2)
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key ("P") "Prestador"
                     "Prestador acionado"
           if k_cts20m00.atdsrvnum is not null then
              call cts20m05(k_cts20m00.atdsrvnum, k_cts20m00.atdsrvano)
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key ("H") "Historico"
                     "Exibe historico do servico selecionado"
           if k_cts20m00.atdsrvnum is not null  then
              call cts10n00(k_cts20m00.atdsrvnum, k_cts20m00.atdsrvano,
                            g_issk.funmat       , ws.hoje  , ws.hora  )
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key ("C") "proCesso"  "Informacoes sobre o ultimo processo de sinistro aberto"
           if k_cts20m00.atdsrvnum is not null then
              if k_cts20m00.atdsrvorg  =  4     or
                 k_cts20m00.atdsrvorg  =  5     or
                 k_cts20m00.atdsrvorg  = 15     then
                 call cts20m06(k_cts20m00.atdsrvnum, k_cts20m00.atdsrvano)
              else
                 error " Opcao valida para remocao por Sinistro e Remocao de Perda Total!"
                 next option "Seleciona"
              end if
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key ("I") "Imprime"
                     "Imprime servico selecionado"
           if k_cts20m00.atdsrvnum is not null then
              call ctr03m02(k_cts20m00.atdsrvnum, k_cts20m00.atdsrvano)
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key ("A") "Acompanhamento"
                     "Acompanhamento do servico selecionado"
           if k_cts20m00.atdsrvnum is not null then
              call cts00m11(k_cts20m00.atdsrvnum, k_cts20m00.atdsrvano)
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key ("T") "carTa" "Emite carta de R.P.T."
            if k_cts20m00.atdsrvnum is not null then
               if k_cts20m00.atdsrvorg  =  5     then
                  call rpt_cts20m00()
               else
                  error " Opcao valida para Remocao de Perda Total!"
                  next option "Seleciona"
               end if
            else
               error " Nenhum servico selecionado!"
               next option "Seleciona"
            end if

   command key ("R") "P_Referenc" "Ponto de Referencia do Servico"
           if k_cts20m00.atdsrvnum is not null then
              call cts00m23(k_cts20m00.atdsrvnum, k_cts20m00.atdsrvano)
           else
              error " Nenhum servico selecionado!"
              next option "Seleciona"
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu

 close window cts20m00

end function  ###  cts20m00


#-----------------------------------------------------------
 function seleciona_cts20m00()
#-----------------------------------------------------------

 let int_flag = false
 initialize d_cts20m00.*   to null
 initialize k_cts20m00.*   to null
 initialize ws.*           to null

 input by name k_cts20m00.atdsrvnum,
               k_cts20m00.atdsrvano  without defaults

      before field atdsrvnum
         display by name k_cts20m00.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name k_cts20m00.atdsrvnum

         if k_cts20m00.atdsrvnum   is null   then
            error " Numero do servico deve ser informado!"
            next field atdsrvnum
         end if

      before field atdsrvano
         display by name k_cts20m00.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name k_cts20m00.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if k_cts20m00.atdsrvano   is null   then
            error " Ano do servico deve ser informado!"
            next field atdsrvano
         end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    clear form
    initialize k_cts20m00.* to null
    initialize d_cts20m00.* to null
    return d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano, ws.atdsrvorg
 end if

 let d_cts20m00.atdsrvnum = k_cts20m00.atdsrvnum
 let d_cts20m00.atdsrvano = k_cts20m00.atdsrvano

 select datmservico.atdsrvorg   , datmservico.atdsrvorg ,
        datmservico.nom         , datmservico.corsus    ,
        datmservico.cornom      , datmservico.vclcoddig ,
        datmservico.vcldes      , datmservico.vclanomdl ,
        datmservico.vcllicnum   , datmservico.vclcorcod ,
        datmservico.atddat      , datmservico.atdhor    ,
        datmservico.funmat      , datmservico.asitipcod ,
        datmservico.atddatprg   , datmservico.atdhorprg ,
        datmservico.atdhorpvt   , datmservico.pgtdat    ,
        datmservico.atdcstvlr   , datmservico.atddfttxt ,
        datrservapol.ramcod     , datrservapol.succod   ,
        datrservapol.aplnumdig  , datrservapol.itmnumdig,
        datmservicocmp.sindat   , datmservicocmp.bocnum ,
        datmservicocmp.bocemi   ,
        datmservico.atdlibdat   , datmservico.atdlibhor
   into ws.atdsrvorg            , k_cts20m00.atdsrvorg  ,
        d_cts20m00.nom          , d_cts20m00.corsus     ,
        d_cts20m00.cornom       , d_cts20m00.vclcoddig  ,
        d_cts20m00.vcldes       , d_cts20m00.vclanomdl  ,
        d_cts20m00.vcllicnum    , ws.vclcorcod          ,
        ws.atddat               , ws.atdhor             ,
        ws.funmat               ,
        ws.asitipcod            , ws.atddatprg          ,
        ws.atdhorprg            , ws.atdhorpvt          ,
        d_cts20m00.pgtdat       , d_cts20m00.atdcstvlr  ,
        ws.atddfttxt            ,
        ws.ramcod               , ws.succod             ,
        ws.aplnumdig            , ws.itmnumdig          ,
        ws.sindat               , ws.bocnum             ,
        ws.bocemi               ,
        ws.atdlibdat            , ws.atdlibhor
   from datmservico, outer datmservicocmp, outer datrservapol
  where datmservico.atdsrvnum     = d_cts20m00.atdsrvnum    and
        datmservico.atdsrvano     = d_cts20m00.atdsrvano    and
        datmservicocmp.atdsrvnum  = datmservico.atdsrvnum   and
        datmservicocmp.atdsrvano  = datmservico.atdsrvano   and
        datrservapol.atdsrvnum    = datmservico.atdsrvnum   and
        datrservapol.atdsrvano    = datmservico.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao cadastrado!"
    sleep 2
    clear form
    initialize d_cts20m00.* to null
    return d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano, ws.atdsrvorg
 end if
 let d_cts20m00.atdsrvorg  =  ws.atdsrvorg
#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 call ctx04g00_local_completo(d_cts20m00.atdsrvnum,
                              d_cts20m00.atdsrvano,
                              1)
                    returning a_cts20m00[1].lclidttxt   ,
                              a_cts20m00[1].lgdtip      ,
                              a_cts20m00[1].lgdnom      ,
                              a_cts20m00[1].lgdnum      ,
                              a_cts20m00[1].lclbrrnom   ,
                              a_cts20m00[1].brrnom      ,
                              a_cts20m00[1].cidnom      ,
                              a_cts20m00[1].ufdcod      ,
                              a_cts20m00[1].lclrefptotxt,
                              a_cts20m00[1].endzon      ,
                              a_cts20m00[1].lgdcep      ,
                              a_cts20m00[1].lgdcepcmp   ,
                              a_cts20m00[1].dddcod      ,
                              a_cts20m00[1].lcltelnum   ,
                              a_cts20m00[1].lclcttnom   ,
                              a_cts20m00[1].c24lclpdrcod,
                              ws.sqlcode,
                              a_cts20m00[1].endcmp
                              
 let m_lclbrrnom = a_cts20m00[1].lclbrrnom
 
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_cts20m00[1].brrnom,
                                a_cts20m00[1].lclbrrnom)
      returning a_cts20m00[1].lclbrrnom                              

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    initialize d_cts20m00.* to null
    return d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano, ws.atdsrvorg
 end if

 let a_cts20m00[1].lgdtxt = a_cts20m00[1].lgdtip clipped, " ",
                            a_cts20m00[1].lgdnom clipped, " ",
                            a_cts20m00[1].lgdnum using "<<<<#", " ",
                            a_cts20m00[1].endcmp clipped

#--------------------------------------------------------------------
# Informacoes do local de destino
#--------------------------------------------------------------------
 call ctx04g00_local_completo(d_cts20m00.atdsrvnum,
                              d_cts20m00.atdsrvano,
                              2)
                    returning a_cts20m00[2].lclidttxt   ,
                              a_cts20m00[2].lgdtip      ,
                              a_cts20m00[2].lgdnom      ,
                              a_cts20m00[2].lgdnum      ,
                              a_cts20m00[2].lclbrrnom   ,
                              a_cts20m00[2].brrnom      ,
                              a_cts20m00[2].cidnom      ,
                              a_cts20m00[2].ufdcod      ,
                              a_cts20m00[2].lclrefptotxt,
                              a_cts20m00[2].endzon      ,
                              a_cts20m00[2].lgdcep      ,
                              a_cts20m00[2].lgdcepcmp   ,
                              a_cts20m00[2].dddcod      ,
                              a_cts20m00[2].lcltelnum   ,
                              a_cts20m00[2].lclcttnom   ,
                              a_cts20m00[2].c24lclpdrcod,
                              ws.sqlcode,
                              a_cts20m00[2].endcmp
                              

 if ws.sqlcode < 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
    initialize d_cts20m00.* to null
    return d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano, ws.atdsrvorg
 end if

 let a_cts20m00[2].lgdtxt = a_cts20m00[2].lgdtip clipped, " ",
                            a_cts20m00[2].lgdnom clipped, " ",
                            a_cts20m00[2].lgdnum using "<<<<#", " ",
                            a_cts20m00[2].endcmp clipped
                            

 if ws.ramcod    is null  or
    ws.succod    is null  or
    ws.aplnumdig is null  or
    ws.itmnumdig is null  then
    let d_cts20m00.doctxt = "** LAUDO EM BRANCO **"
 else
    let d_cts20m00.doctxt = ws.ramcod    using "##&&"      , "/",
                            ws.succod    using "<<<&&" , "/", #"&&"        , "/", projeto succod
                            ws.aplnumdig using "<<<<<<<& &"
    if ws.itmnumdig <> 0  then
       let d_cts20m00.doctxt = d_cts20m00.doctxt clipped, "/",
                               ws.itmnumdig using "<<<<<<& &"
    end if
 end if

#-----------------  DADOS DA LIGACAO  ----------------------

 let ws.lignum = cts20g00_servico(d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano)

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts20m00.c24astcod, ws.ligcvntip,
        d_cts20m00.c24solnom
   from datmligacao
  where lignum  =  ws.lignum

#-----------------------  CONVENIO  ------------------------

 select cpodes into d_cts20m00.cvnnom
   from datkdominio
  where cponom  =  "ligcvntip" and
        cpocod  =  ws.ligcvntip

#-----------------  DESCRICAO DO ASSUNTO  ------------------

 call c24geral8(d_cts20m00.c24astcod)
      returning d_cts20m00.c24astdes

#-----------------  DESCRICAO DA COR  ----------------------

 select cpodes into d_cts20m00.vclcor
   from iddkdominio
  where cponom  = "vclcorcod"  and
        cpocod  = ws.vclcorcod

#------------------  NOME DO FUNCIONARIO  ------------------

 let ws.funnom = "** NAO CADASTRADO **"
 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where isskfunc.funmat  =  ws.funmat
    and isskfunc.empcod  =  g_issk.empcod
    and isskfunc.rhmfunsitcod = "A"

 let d_cts20m00.atdlibtxt = ws.atddat                 clipped, " " ,
                            ws.atdhor                 clipped, " " ,
                            upshift(ws.dptsgl)        clipped, " " ,
                            ws.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)        clipped, "  ",
                            ws.atdlibdat              clipped, " " ,
                            ws.atdlibhor

#-------------------  NUMERO DA O.P. ----------------------

 select dbsmopg.socopgnum into d_cts20m00.socopgnum
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum  =  d_cts20m00.atdsrvnum  and
        dbsmopgitm.atdsrvano  =  d_cts20m00.atdsrvano  and
        dbsmopgitm.socopgnum  =  dbsmopg.socopgnum     and
        dbsmopg.socopgsitcod  <> 8

 let d_cts20m00.srvtipabvdes = "NAO PREV."

 select srvtipabvdes
   into d_cts20m00.srvtipabvdes
   from datksrvtip
  where atdsrvorg = ws.atdsrvorg

 if ws.atdsrvorg = 10   or  ws.atdsrvorg = 11   or
    ws.atdsrvorg =  8   then
    error " Consulta de ", d_cts20m00.srvtipabvdes clipped, " nao disponivel!"
    sleep 2
    clear form
    initialize d_cts20m00.* to null
    return d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano, ws.atdsrvorg
 end if

 let d_cts20m00.asitipdes = "*** NAO CADASTRADA ***"

 select asitipdes
   into d_cts20m00.asitipdes
   from datkasitip
  where asitipcod = ws.asitipcod

 if ws.atdhorpvt is not null  then
    let d_cts20m00.tmptxt = "Previsao..: ", ws.atdhorpvt
 else
    let d_cts20m00.tmptxt = "Programado: ", ws.atddatprg, " - ", ws.atdhorprg
 end if

 #---------------------------------------------------
 # Formata dados para remocao por sinistro e socorro
 #---------------------------------------------------
 if ws.atdsrvorg  =  4  or ws.atdsrvorg  = 15  then  ###  Sinistro/Jit
    let d_cts20m00.livre = "Sinistro..: ", ws.sindat,
                           " B.O: ", ws.bocnum using "#####", "/", ws.bocemi
 else
    if ws.atdsrvorg  =   1   then  ###  Socorro
       let d_cts20m00.livre = "Problema..: ", ws.atddfttxt
    end if
 end if

 display by name d_cts20m00.*
 display by name a_cts20m00[1].lgdtxt,
                 a_cts20m00[1].lclbrrnom,
                 a_cts20m00[1].cidnom,
                 a_cts20m00[1].ufdcod,
                 a_cts20m00[1].lclrefptotxt,
                 a_cts20m00[1].endzon,
                 a_cts20m00[1].dddcod,
                 a_cts20m00[1].lcltelnum,
                 a_cts20m00[1].lclcttnom

 return d_cts20m00.atdsrvnum, d_cts20m00.atdsrvano, ws.atdsrvorg

end function  ###  seleciona_cts20m00


#-----------------------------------------------------------
 function rpt_cts20m00()
#-----------------------------------------------------------

 define w_funapol   record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record

 initialize w_funapol to null
 call f_funapol_ultima_situacao (ws.succod, ws.aplnumdig, ws.itmnumdig)
      returning w_funapol.*

 select vclchsinc,
        vclchsfnl
  into  ws.vclchsinc,
        ws.vclchsfnl
  from  abbmveic
  where succod    = ws.succod     and
        aplnumdig = ws.aplnumdig  and
        itmnumdig = ws.itmnumdig  and
        dctnumseq = w_funapol.vclsitatu

 call cts12m01(d_cts20m00.atdsrvorg   , d_cts20m00.atdsrvnum   ,
               d_cts20m00.atdsrvano   ,
               d_cts20m00.nom         , ws.succod              ,
               ws.ramcod              , ws.aplnumdig           ,
               ws.itmnumdig           , d_cts20m00.vcldes      ,
               d_cts20m00.vclanomdl   , d_cts20m00.vcllicnum   ,
               ws.vclchsinc           , ws.vclchsfnl           ,
               ws.atddfttxt           , a_cts20m00[1].lgdtxt   ,
               a_cts20m00[1].brrnom   , a_cts20m00[1].lclbrrnom, 
               a_cts20m00[1].cidnom   , a_cts20m00[1].ufdcod   , 
               a_cts20m00[1].dddcod   , a_cts20m00[1].lcltelnum, 
               a_cts20m00[1].lclcttnom, a_cts20m00[2].lclidttxt, 
               a_cts20m00[2].lgdtxt   , a_cts20m00[2].cidnom   , 
               a_cts20m00[2].lclbrrnom, a_cts20m00[2].ufdcod   )
     returning ws.emitecarta

end function  ###  rpt_cts20m00
