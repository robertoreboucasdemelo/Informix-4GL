#############################################################################
# Nome do Modulo: wdatc051                                             Zyon #
#                                                                           #
#                                                                  Mar/2003 #
# Tela de acerto de valores de serviço                                      #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 16/06/2003  PSI 163759   R. Santos    Nova atualizacao na tabela          #
#                                       dbsmsrvacr                          #
#                                                                           #
#---------------------------------------------------------------------------#
#                   * * * A L T E R A C O E S * * *                         #
# Data      Autor Fabrica           PSI    Alteracao                        #
#---------- ----------------------- ------ ---------------------------------#
#06/10/2004 Helio (Meta)            187801 Alterar logica de gravacao do    #
#                                          historico                        #
#---------------------------------------------------------------------------#
#                    * * * Alteracoes * * *                                 #
#                                                                           #
#    Data      Autor Fabrica   Origem   Alteracao                           #
#  ----------  -------------  --------- ------------------------------------#
# 16/03/2005  Adriana,Meta    PSI188751 Inclusao RIS                        #
#---------------------------------------------------------------------------#
# 05/12/2005  Cristiane Silva CT5104824 Inclusão de log                     #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

main

define m_path char(100)

    define ws record
        sttsess             dec     (1,0),
        comando             char    (1000),
        c24pbmdes           like    datrsrvpbm.c24pbmdes,
        ufdcod              like    glakcid.ufdcod,
        cidnom              like    glakcid.cidnom,
        somaadic            like    dbsmsrvacr.fnlvlr,
        somaqtd             smallint,
        cont                integer,
        histerr             smallint,
        rispcstcod          like    dbstgtfcst.soccstcod,## RIS no prazo
        risfcstcod          like    dbstgtfcst.soccstcod,## RIS fora do prazo
        pendente            char(1),                     ## Flag de pendencia
        vclchsinc           like abbmveic.vclchsinc,
        vclchsfnl           like abbmveic.vclchsfnl,
        atdsrvorg           like datmservico.atdsrvorg,
        vcllicnum           like abbmveic.vcllicnum,
        atdetpdat           like datmsrvacp.atdetpdat,
        atdetphor           datetime hour to second
    end record

    define param record
        sttsess             dec     (1,0),
        usrtip              char    (1),
        webusrcod           char    (6),
        sesnum              char    (10),
        macsissgl           char    (10),
        atdsrvnum           like    datmservico.atdsrvnum,
        atdsrvano           like    datmservico.atdsrvano,
        c24pbmcod           char    (20),
        cidcod              char    (10),
        pdgqtd              smallint,
        pdgttlvlr           dec     (13,2),
        historico           char    (7000),   #PSI 187801
        renavam             decimal (9,0),
        quilometragem       integer
    end record

    define d_wdatc051 array[10] of record
        soccstcod           like    dbsmsrvcst.soccstcod,
        socadccstqtd        like    dbsmsrvcst.socadccstqtd,
        socadccstvlr        like    dbsmsrvcst.socadccstvlr
    end record

    define hist_wdatc051 record
        hist1               like    datmservhist.c24srvdsc,
        hist2               like    datmservhist.c24srvdsc,
        hist3               like    datmservhist.c24srvdsc,
        hist4               like    datmservhist.c24srvdsc,
        hist5               like    datmservhist.c24srvdsc
    end record

    define ws2 record
        statusprc           dec     (1,0),
        sestblvardes1       char    (256),
        sestblvardes2       char    (256),
        sestblvardes3       char    (256),
        sestblvardes4       char    (256),
        sespcsprcnom        char    (256),
        prgsgl              char    (256),
        acsnivcod           dec     (1,0),
        webprscod           dec     (16,0)
    end record

    define l_retorno       record
           coderro         integer,
           menserro        char(30),
           mensagemRet     char(32766)
    end record

    define ws_cont integer

    define l_comando       char(1000)
    define l_histaux        char(7000)
    define l_count          integer
    define l_de             integer
    define l_ate            integer
    define l_found          smallint
    define l_data           date
    define l_hora           datetime hour to second

    initialize ws.*             to null
    initialize param.*          to null
    initialize ws2.*            to null
    initialize hist_wdatc051.*  to null
    initialize l_retorno.*      to null
    initialize l_data           to null
    initialize l_hora           to null
    initialize m_path           to null
    initialize ws_cont           to null

    initialize l_comando        to null
    initialize l_histaux        to null
    initialize l_count          to null
    initialize l_de             to null
    initialize l_ate            to null
    initialize l_found          to null

    let l_histaux = ""
    let l_count = 0
    let l_de = 0
    let l_ate = 0

    for	ws_cont = 1 to 10
		initialize d_wdatc051[ws_cont].* to null
	end	for

    let param.usrtip        = arg_val(01)
    let param.webusrcod     = arg_val(02)
    let param.sesnum        = arg_val(03)
    let param.macsissgl     = arg_val(04)
    let param.atdsrvnum     = arg_val(05)
    let param.atdsrvano     = arg_val(06)
    let param.c24pbmcod     = arg_val(07)
    let param.cidcod        = arg_val(08)
    for	ws_cont = 1 to 10
		let d_wdatc051[ws_cont].soccstcod    = arg_val(ws_cont+08)
		let d_wdatc051[ws_cont].socadccstqtd = arg_val(ws_cont+18)
		let d_wdatc051[ws_cont].socadccstvlr = arg_val(ws_cont+28)
	end	for
	let param.pdgqtd        = arg_val(39)
    let param.pdgttlvlr     = arg_val(40)
    let param.historico     = arg_val(41)
    let param.renavam       = arg_val(42)
    let param.quilometragem = arg_val(43)

    #-------------------------------------------
    #  ABRE BANCO   (TESTE ou PRODUCAO)
    #-------------------------------------------
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read

    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped, "/wdatc051.log"

    call startlog(m_path)

    #---------------------------------------------
    #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
    #---------------------------------------------

    call wdatc002(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl)
                  returning ws2.*

    if ws2.statusprc <> 0 then
        display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta p\341gina atingiu o limite m\341ximo.@@"
        exit program(0)
    end if

    #----------------------------------------------
    #  Informações Adicionais
    #----------------------------------------------

    begin work

    #--> 1 - Detalhe do problema

    select datkpbm.c24pbmdes
      into ws.c24pbmdes
      from datkpbm
     where datkpbm.c24pbmcod = param.c24pbmcod

    let ws.cont = 0

    select count(*)
      into ws.cont
      from datrsrvpbm
     where datrsrvpbm.atdsrvnum = param.atdsrvnum
       and datrsrvpbm.atdsrvano = param.atdsrvano
       and datrsrvpbm.c24pbmseq = 2

    if ws.cont > 0 then
        update datrsrvpbm
           set c24pbmcod    = param.c24pbmcod,
               c24pbminforg = 2,
               c24pbmdes    = ws.c24pbmdes,
               caddat       = current,
               cadmat       = 999999,
               cademp       = 1,
               cadusrtip    = "F",
               pstcoddig    = ws2.webprscod
         where datrsrvpbm.atdsrvnum = param.atdsrvnum
           and datrsrvpbm.atdsrvano = param.atdsrvano
           and datrsrvpbm.c24pbmseq = 2
    else
        insert into datrsrvpbm
                   (atdsrvnum,
                    atdsrvano,
                    c24pbmseq,
                    c24pbmcod,
                    c24pbminforg,
                    c24pbmdes,
                    caddat,
                    cadmat,
                    cademp,
                    cadusrtip,
                    pstcoddig)
            values (param.atdsrvnum,
                    param.atdsrvano,
                    2,
                    param.c24pbmcod,
                    2,
                    ws.c24pbmdes,
                    current,
                    999999,
                    1,
                    "F",
                    ws2.webprscod)
    end if

    if sqlca.sqlcode <> 0 then
        rollback work
        exit program(1)
    end if

    #--> 2 - UF/Cidade do destino

    #--> Somente grava o destino se não for RE
    if param.cidcod <> 909090 then

        select glakcid.ufdcod,
               glakcid.cidnom
          into ws.ufdcod,
               ws.cidnom
          from glakcid
         where glakcid.cidcod = param.cidcod

        let ws.cont = 0

        select count(*)
          into ws.cont
          from datmlcl
         where datmlcl.atdsrvnum = param.atdsrvnum
           and datmlcl.atdsrvano = param.atdsrvano
           and datmlcl.c24endtip = 2

        if ws.cont > 0 then
            update datmlcl
               set ufdcod       = ws.ufdcod,
                   cidnom       = ws.cidnom
             where datmlcl.atdsrvnum = param.atdsrvnum
               and datmlcl.atdsrvano = param.atdsrvano
               and datmlcl.c24endtip = 2
        else
            insert into datmlcl
                       (atdsrvnum,
                        atdsrvano,
                        c24endtip,
                        ufdcod,
                        cidnom,
                        lgdnom,
                        lclbrrnom,
                        c24lclpdrcod)
                values (param.atdsrvnum,
                        param.atdsrvano,
                        2,
                        ws.ufdcod,
                        ws.cidnom,
                        "AC",
                        "AC",
                        1)
        end if

        if sqlca.sqlcode <> 0 then
            rollback work
            exit program(1)
        end if

    end if

    #--> 3 - Histórico

    let g_issk.funmat = 999999
    let g_issk.empcod = 1
    let g_issk.usrtip = "F"

    let hist_wdatc051.hist1  =  "--- Prestador informou via internet: ---"
    let hist_wdatc051.hist2  =  ""   #PSI 187801
    let hist_wdatc051.hist3  =  ""
    let hist_wdatc051.hist4  =  ""
    let hist_wdatc051.hist5  =  ""
    call cts10g02_historico(param.atdsrvnum,
                            param.atdsrvano,
                            current,
                            current,
                            g_issk.funmat,
                            hist_wdatc051.*)
                            returning ws.histerr

    if ws.histerr <> 0 then
        rollback work
        exit program(1)
    end if

    #--> Executa o loop de gravacao - PSI 187801

    for l_count = 1 to 20
       let l_ate = l_count * 350
       let l_de = l_ate - 349
       let l_histaux = param.historico[l_de, l_ate] clipped
       let hist_wdatc051.hist1 = l_histaux[001,070] clipped
       let hist_wdatc051.hist2 = l_histaux[071,140] clipped
       let hist_wdatc051.hist3 = l_histaux[141,210] clipped
       let hist_wdatc051.hist4 = l_histaux[211,280] clipped
       let hist_wdatc051.hist5 = l_histaux[281,350] clipped

       let ws.histerr =  cts10g02_historico(param.atdsrvnum
                                           ,param.atdsrvano
                                           ,current
                                           ,current
                                           ,g_issk.funmat
                                           ,hist_wdatc051.*)
       if ws.histerr <> 0 then
          rollback work
          exit program(1)
       end if
    end for

    #--> 4 - Valores dos adicionais

    ##PSI:188751

    whenever error continue
    select grlinf
    into   ws.rispcstcod
    from   datkgeral
    where  grlchv = "PSOCODCSTRISDPR"
    whenever error stop
    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode <> 100 then
          display "ERRO@@Problema no acesso a tabela datkgeral@@BACK"
          exit program
       end if
    end if

    ## Codigo do custo para RIS fora do prazo
    whenever error continue
    select grlinf
    into   ws.risfcstcod
    from   datkgeral
    where  grlchv = "PSOCODCSTRISFPR"
    whenever error stop
    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode <> 100 then
          display "ERRO@@Problema no acesso a tabela datkgeral - RIS fora prazo@@BACK"
          exit program
       end if
    end if
    ##Fim


    let ws.somaadic = 0
    let ws.somaqtd  = 0
    let ws.pendente = "N"

    for ws_cont = 1 to 10

        if d_wdatc051[ws_cont].soccstcod <> 0 then

            if d_wdatc051[ws_cont].socadccstqtd is null then
                let d_wdatc051[ws_cont].socadccstqtd = 0
            end if

            if d_wdatc051[ws_cont].socadccstvlr is null then
                let d_wdatc051[ws_cont].socadccstvlr = 0
            end if

            ##PSI 188751
            if d_wdatc051[ws_cont].soccstcod <> ws.rispcstcod and
               d_wdatc051[ws_cont].soccstcod <> ws.risfcstcod then

               if d_wdatc051[ws_cont].socadccstvlr <> 0 or
                  d_wdatc051[ws_cont].socadccstqtd <> 0 then

                  let ws.pendente = "S"
               end if
            end if
            ## Fim


            #--> Acumula valores dos adicionais para valor final
            let ws.somaadic = ws.somaadic + d_wdatc051[ws_cont].socadccstvlr

            #--> Acumula quantidades adicionais
            let ws.somaqtd = ws.somaqtd + d_wdatc051[ws_cont].socadccstqtd

            let ws.cont = 0

            select count(*)
              into ws.cont
              from dbsmsrvcst
             where dbsmsrvcst.atdsrvnum = param.atdsrvnum
               and dbsmsrvcst.atdsrvano = param.atdsrvano
               and dbsmsrvcst.soccstcod = d_wdatc051[ws_cont].soccstcod

            if ws.cont > 0 then
                update dbsmsrvcst
                   set socadccstvlr = d_wdatc051[ws_cont].socadccstvlr,
                       socadccstqtd = d_wdatc051[ws_cont].socadccstqtd
                 where dbsmsrvcst.atdsrvnum = param.atdsrvnum
                   and dbsmsrvcst.atdsrvano = param.atdsrvano
                   and dbsmsrvcst.soccstcod = d_wdatc051[ws_cont].soccstcod
            else
                insert into dbsmsrvcst
                           (atdsrvnum,
                            atdsrvano,
                            soccstcod,
                            socadccstvlr,
                            socadccstqtd)
                    values (param.atdsrvnum,
                            param.atdsrvano,
                            d_wdatc051[ws_cont].soccstcod,
                            d_wdatc051[ws_cont].socadccstvlr,
                            d_wdatc051[ws_cont].socadccstqtd)
            end if

            if sqlca.sqlcode <> 0 then
                rollback work
                exit program(1)
            end if

        end if

    end for

    #PSI 208264 - Grava valores do Pedágio Eletrônico, se houver
    if  param.pdgqtd > 0 and param.pdgttlvlr > 0 then
        let ws_cont = 0
        select count(*) into ws_cont
          from dbarsemprrsrv
         where atdsrvnum = param.atdsrvnum
           and atdsrvano = param.atdsrvano
        if  ws_cont > 0 then
            update dbarsemprrsrv
               set pdgqtd    = param.pdgqtd,
                   pdgttlvlr = param.pdgttlvlr
             where atdsrvnum = param.atdsrvnum
               and atdsrvano = param.atdsrvano
        else
            insert into dbarsemprrsrv
                       (atdsrvnum,
                        atdsrvano,
                        pdgqtd,
                        pdgttlvlr)
                values (param.atdsrvnum,
                        param.atdsrvano,
                        param.pdgqtd,
                        param.pdgttlvlr)
        end if

        if sqlca.sqlcode <> 0 then
            rollback work
            exit program(1)
        end if
    end if

    #--> 5 - Acerto de Valores

    {Inibido PSI188751 if ws.somaadic > 0 or
       ws.somaqtd  > 0 then
    }
    if ws.pendente = "S" then
       update dbsmsrvacr
          set dbsmsrvacr.prsokaflg = "S",
              dbsmsrvacr.prsokadat = current,
              dbsmsrvacr.prsokahor = current,
              dbsmsrvacr.anlokaflg = "N",
              dbsmsrvacr.fnlvlr    = dbsmsrvacr.incvlr + ws.somaadic
        where dbsmsrvacr.atdsrvnum = param.atdsrvnum
          and dbsmsrvacr.atdsrvano = param.atdsrvano
    else
       update dbsmsrvacr
          set dbsmsrvacr.prsokaflg = "S",
              dbsmsrvacr.prsokadat = current,
              dbsmsrvacr.prsokahor = current,
              dbsmsrvacr.anlokaflg = "S",
              dbsmsrvacr.anlokadat = current,
              dbsmsrvacr.anlokahor = current,
              dbsmsrvacr.autokaflg = "S",
              dbsmsrvacr.autokadat = current,
              dbsmsrvacr.autokahor = current,
              dbsmsrvacr.anlusrtip = "F",
              dbsmsrvacr.anlemp    = 1,
              dbsmsrvacr.anlmat    = 999999,
              dbsmsrvacr.fnlvlr    = dbsmsrvacr.incvlr +  ws.somaadic #PSI188751
        where dbsmsrvacr.atdsrvnum = param.atdsrvnum
          and dbsmsrvacr.atdsrvano = param.atdsrvano
    end if

    if sqlca.sqlcode <> 0 then
        rollback work
        exit program(1)
    end if

    commit work

    # VERIFICA SE O SERVICO É UM SERVICO DE AUTO
    select atdsrvorg
      into ws.atdsrvorg
      from datmservico
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano

    if  ws.atdsrvorg = 1 or
        ws.atdsrvorg = 4 or
        ws.atdsrvorg = 5 or
        ws.atdsrvorg = 6 or
        ws.atdsrvorg = 7 or
        ws.atdsrvorg = 12 or
        ws.atdsrvorg = 13 then

        if  param.quilometragem is not null then

            let l_found = false

            select distinct vcl.vclchsinc,
                   vcl.vclchsfnl,
                   vcl.vcllicnum,
                   acp.atdetpdat,
                   acp.atdetphor
              into ws.vclchsinc,
                   ws.vclchsfnl,
                   ws.vcllicnum,
                   ws.atdetpdat,
                   ws.atdetphor
              from datmservico srv,
                   abbmveic    vcl,
                   datmsrvacp  acp
             where vcl.vcllicnum = srv.vcllicnum
               and srv.atdsrvnum = param.atdsrvnum
               and srv.atdsrvano = param.atdsrvano
               and acp.atdsrvnum = srv.atdsrvnum
               and acp.atdsrvano = srv.atdsrvano
               and acp.atdetpcod = 4
               and acp.atdsrvseq = (select max(atdsrvseq)
                                      from datmsrvacp acpmax
                                     where acpmax.atdsrvnum = acp.atdsrvnum
                                       and acpmax.atdsrvano = acp.atdsrvano)

            # CASO NAO ENCONTRE NENHUM AUTOMOVEL VERIFICA A TABELA DE PROPOSTAS.
            if  sqlca.sqlcode = notfound then
                select distinct vcl.vclchsinc,
                       vcl.vclchsfnl,
                       vcl.vcllicnum,
                       acp.atdetpdat,
                       acp.atdetphor
                  into ws.vclchsinc,
                       ws.vclchsfnl,
                       ws.vcllicnum,
                       ws.atdetpdat,
                       ws.atdetphor
                  from datmservico srv,
                       apbmveic    vcl,
                       datmsrvacp  acp
                 where vcl.vcllicnum = srv.vcllicnum
                   and srv.atdsrvnum = param.atdsrvnum
                   and srv.atdsrvano = param.atdsrvano
                   and acp.atdsrvnum = srv.atdsrvnum
                   and acp.atdsrvano = srv.atdsrvano
                   and acp.atdetpcod = 4
                   and acp.atdsrvseq = (select max(atdsrvseq)
                                          from datmsrvacp acpmax
                                         where acpmax.atdsrvnum = acp.atdsrvnum
                                           and acpmax.atdsrvano = acp.atdsrvano)

                 if  sqlca.sqlcode = 0 then
                     let l_found = true
                 else
                     display "ERRO@@Problema no acesso dos dados do Automovel@@BACK"
                 end if
            else
                if  sqlca.sqlcode = 0 then
                    let l_found = true
                else
                    display "ERRO@@Problema no acesso dos dados da proposta do Automovel@@BACK"
                end if
            end if

            # CASO ACHE NA APOLICE OU NA PROPOSTA.
            if  l_found then

                # INICIALIZA PROCESSO
                call figrc010_inicio_doc()

                call figrc010_inicio_integracao(
                    "GerirInformacaoVeiculo",
                    "EJB",
                    "com.porto.automovel.controletelemetriaveiculo.service.GerirInformacaoVeiculoServiceHome",
                    "ejb/com/porto/automovel/controletelemetriaveiculo/service/GerirInformacaoVeiculoServiceHome")

                # INICIALIZA O METODO
                call figrc010_inicio_metodo("persisteTelemetriaIntegra")

                call figrc010_inicio_parametro_vo(
                          "dadosVO",
                          "com.porto.automovel.vomanipulacaoautomovel.common.DadosKmRenavanIntegraVO")

                let l_data = current
                let l_hora = extend(current, hour to second)

                if(param.renavam is null or param.renavam = "" ) then
                    let param.renavam = 0
                end if

                # SETA AS VARIAS DA CLASSE COM AS PASSADAS POR PARAMETROS
                call figrc010_add_parametro_vo_attr("parteInicialNumeroChassi",ws.vclchsinc)
                call figrc010_add_parametro_vo_attr("parteFinalNumeroChassi",ws.vclchsfnl)
                call figrc010_add_parametro_vo_attr("dataColetaInformacaoVeiculo", ws.atdetpdat)
                call figrc010_add_parametro_vo_attr("horaColetaInformacaoVeiculo", ws.atdetphor)
                call figrc010_add_parametro_vo_attr("numeroLicencaVeiculo",ws.vcllicnum)
                call figrc010_add_parametro_vo_attr("codigoOrigemInformacaoVeiculo",1)
                call figrc010_add_parametro_vo_attr("codigoPostoColetaInformacaoVaiculo",0)
                call figrc010_add_parametro_vo_attr("matriculaAtualizacao", g_issk.funmat)
                call figrc010_add_parametro_vo_attr("statusDadoComplementarVeiculo","")
                call figrc010_add_parametro_vo_attr("empresaAtualizacao", g_issk.empcod)
                call figrc010_add_parametro_vo_attr("tipoUsuarioAtualizacao", g_issk.usrtip)
                call figrc010_add_parametro_vo_attr("numeroRenavamVeiculo",param.renavam)
                call figrc010_add_parametro_vo_attr("dataAtualizacao", l_data)
                call figrc010_add_parametro_vo_attr("horaUltimaAtualizacao", l_hora)
                call figrc010_add_parametro_vo_attr("quantidadeQuilometragemVeiculo", param.quilometragem)

                # FINALIZA PROCESSOS
                call figrc010_fim_parametro_vo()
                call figrc010_fim_metodo()
                call figrc010_fim_integracao()
                call figrc010_fim_doc()

                # EXECUTA PROCESSO E RETORNA XML DE RESPONSE
                call figrc010_executa()
                   returning l_retorno.coderro,
                             l_retorno.menserro,
                             l_retorno.mensagemRet
            end if
        end if
    end if

    display "OK@@OK@@"

    #------------------------------------
    # ATUALIZA TEMPO DE SESSAO DO USUARIO
    #------------------------------------

    call wdatc003(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl,
                  ws2.*)
        returning ws.sttsess

end main

 function fonetica2()

 end function
 
 function conqua59()

 end function
