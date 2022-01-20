#############################################################################
# Nome do Modulo: wdatc049                                             Zyon #
#                                                                           #
#                                                                  Mar/2003 #
# Tela de acerto de valores de serviço                                      #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 02/06/2003  PSI 163759   R. Santos    Acerto no layout das telas.         #
# 07/10/2004  PSI.187801   Carlos Zyon  Montagem condicional da pagina para #
#                          META,Marcos  flag de pendencia = "P".            #
#############################################################################
#                    * * * Alteracoes * * *                                 #
#                                                                           #
#    Data      Autor Fabrica   Origem   Alteracao                           #
#  ----------  -------------  --------- ------------------------------------#
# 16/03/2005  Adriana,Meta    PSI188751 Inclusao RIS                        #
#---------------------------------------------------------------------------#
# 26/07/2006  Priscila        PSI197858 Incluir ultimo historico cadastrado #
#                                       pelo prestador na web               #
# 31/07/2008  Fabio Costa     PSI227145 Buscar data/hora do acionamento do  #
#                                       servico                             #
# 13/08/2009  Sergio Burini   PSI244236 Inclusão do Sub-Dairro              #
#---------------------------------------------------------------------------#

database porto

main

    define ws record
        #--> Work
        sttsess             dec     (1,0),
        comando             char    (1000),
        padrao              char    (32000),
        padrao2             char    (32000),
        tamanho             integer,
        servico             char    (13),
        srvtipabvdes        like    datksrvtip.srvtipabvdes,
        selecionado         char    (1),
        cidnom              like    glakcid.cidnom,
        cont                integer,
        cont2               integer,
        erro                char    (1),
        sqlcode             integer,
        #--> Laudo:
        aplnumdig           like    datrservapol.aplnumdig,
        asimtvcod           like    datkasimtv.asimtvcod,
        asimtvdes           like    datkasimtv.asimtvdes,
        asitipabvdes        like    datkasitip.asitipabvdes,
        asitipcod           like    datmservico.asitipcod,
        atddat              like    datmservico.atddat,
        atddatprg           like    datmservico.atddatprg,
        atddfttxt           like    datmservico.atddfttxt,
        atddmccidnom        like    datmassistpassag.atddmccidnom,
        atddmcufdcod        like    datmassistpassag.atddmcufdcod,
        atddstcidnom        like    datmassistpassag.atddstcidnom,
        atddstufdcod        like    datmassistpassag.atddstufdcod,
        atdhor              like    datmservico.atdhor,
        atdhorprg           like    datmservico.atdhorprg,
        atdhorpvt           like    datmservico.atdhorpvt,
        atdmotnom           like    datmservico.atdmotnom,
        atdrsddes           char    (3),
        atdrsdflg           like    datmservico.atdrsdflg,
        atdsrvorg           like    datmservico.atdsrvorg,
        atdvclsgl           like    datmservico.atdvclsgl,
        bagflg              like    datmassistpassag.bagflg,
        bocemi              like    datmservicocmp.bocemi,
        bocnum              like    datmservicocmp.bocnum,
        dddcod              like    gsakend.dddcod,
        itmnumdig           like    datrservapol.itmnumdig,
        lclrefptotxt1       char    (100),
        lclrefptotxt2       char    (100),
        lclrsccod           like    datmsrvre.lclrsccod,
        nom                 like    datmservico.nom,
        ntzdes              char    (40),
        orrdat              like    datmsrvre.orrdat,
        orrhor              like    datmsrvre.orrhor,
        pasidd              like    datmpassageiro.pasidd,
        pasnom              like    datmpassageiro.pasnom,
        ramcod              like    datrservapol.ramcod,
        rmcacpdes           char    (3),
        rmcacpflg           like    datmservicocmp.rmcacpflg,
        roddantxt           like    datmservicocmp.roddantxt,
        sinntzcod           like    datmsrvre.sinntzcod,
        socntzcod           like    datmsrvre.socntzcod,
        socvclcod           like    datmservico.socvclcod,
        srrabvnom           like    datksrr.srrabvnom,
        srrcoddig           like    datmservico.srrcoddig,
        srvprlflg           like    datmservico.srvprlflg,
        succod              like    datrservapol.succod,
        teltxt              like    gsakend.teltxt,
        vclanomdl           like    datmservico.vclanomdl,
        vclcoddig           like    datmservico.vclcoddig,
        vclcorcod           like    datmservico.vclcorcod,
        vclcordes           char    (20),
        vcldes              like    datmservico.vcldes,
        vcllicnum           like    datmservico.vcllicnum,
        rispcstcod          like    dbstgtfcst.soccstcod, ##  RIS no prazo
        risfcstcod          like    dbstgtfcst.soccstcod, ##  RIS fora do prazo
        ciaempcod           like    datmservico.ciaempcod,
        ciaempsgl           char    (40)
    end record

    define a_rrw array[2] of record
        lclidttxt           like datmlcl.lclidttxt,
        lgdtxt              char (80),
        lgdtip              like datmlcl.lgdtip,
        lgdnom              like datmlcl.lgdnom,
        lgdnum              like datmlcl.lgdnum,
        brrnom              like datmlcl.brrnom,
        lclbrrnom           like datmlcl.lclbrrnom,
        endzon              like datmlcl.endzon,
        cidnom              like datmlcl.cidnom,
        ufdcod              like datmlcl.ufdcod,
        lgdcep              like datmlcl.lgdcep,
        lgdcepcmp           like datmlcl.lgdcepcmp,
        dddcod              like datmlcl.dddcod,
        lcltelnum           like datmlcl.lcltelnum,
        lclcttnom           like datmlcl.lclcttnom,
        lclrefptotxt        like datmlcl.lclrefptotxt,
        c24lclpdrcod        like datmlcl.c24lclpdrcod,
        endcmp              like datmlcl.endcmp 
    end record

    define param record
        usrtip              char    (1),
        webusrcod           char    (6),
        sesnum              char    (10),
        macsissgl           char    (10),
        atdsrvnum           like    datmservico.atdsrvnum,
        atdsrvano           like    datmservico.atdsrvano,
        c24pbmgrpcod        char    (20),
        ufdcod              char    (10)
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

    define d_wdatc049 record
        cidcod              like    glakcid.cidcod,
        cidnom              like    glakcid.cidnom,
        c24pbmcod           like    datkpbm.c24pbmcod,
        c24pbmdes           like    datkpbm.c24pbmdes,
        soctip              like    dbskcustosocorro.soctip,
        incvlr              like    dbsmsrvacr.incvlr,
        anlokaflg           like    dbsmsrvacr.anlokaflg, #=> PSI.187801
        #--> Custos adicionais:
        soctrfvignum        like    dbstgtfcst.soctrfvignum,        # Código da vigencia
        socgtfcod           like    dbstgtfcst.socgtfcod,           # Grupo  da tarifa
        soctrfcod           like    dbsmvigtrfsocorro.soctrfcod,    # Código da tarifa
        soccstcod           like    dbstgtfcst.soccstcod,           # Código do custo
        soccstdes           like    dbskcustosocorro.soccstdes      # Descrição do custo
    end record

#=> PSI.187801
    define lr_acrobs        record
           srvacrobs        like dbsmsrvacrobs.srvacrobs,
           srvacrobslinseq  like dbsmsrvacrobs.srvacrobslinseq
    end record
    define lr_srvcst        record
           socadccstvlr     like dbsmsrvcst.socadccstvlr,
           socadccstqtd     like dbsmsrvcst.socadccstqtd
    end record

    #PSI 197858 - Ultimo Historico cadastrado pelo Prestador
    define d_hist record
           c24txtseq like datmservhist.c24txtseq,
           c24srvdsc like datmservhist.c24srvdsc,
           ligdat    like datmservhist.ligdat,
           lighorinc like datmservhist.lighorinc,
           ligdatant like datmservhist.ligdat,
           lighorincant like datmservhist.lighorinc
    end record

    define lr_pdg record
        pdgqtd      like dbarsemprrsrv.pdgqtd,
        pdgttlvlr   like dbarsemprrsrv.pdgttlvlr
    end record
    
    define l_acihor record
           atddat  like datmsrvacp.atdetpdat ,
           atdhor  like datmsrvacp.atdetphor ,
           acistr  char(70)
    end record
    
    define m_subbairro array[03] of record
           lclbrrnom   like datmlcl.lclbrrnom
    end record      
    
    define l_achou          smallint,
           l_vlrvalue       char(80),
           l_qtdvalue       char(80),
           l_c24pbmcod      like datrsrvpbm.c24pbmcod,
           l_texto          char(7000),
           l_ret            smallint,
           l_mensagem       char(100),
           l_cont           smallint

    define m_psaerrcod      integer
    
    initialize ws.*         to null
    initialize a_rrw        to null
    initialize param.*      to null
    initialize ws2.*        to null
    initialize d_wdatc049   to null
    initialize d_hist.*     to null      #PSI197858
    initialize lr_pdg.*     to null      #PSI208264
    initialize l_acihor.*   to null
    initialize m_subbairro  to null
    initialize m_psaerrcod  to null
    initialize lr_acrobs.*  to null
    initialize lr_srvcst.*  to null

    initialize l_achou          to null
    initialize l_vlrvalue       to null
    initialize l_qtdvalue       to null
    initialize l_c24pbmcod      to null
    initialize l_texto          to null
    initialize l_ret            to null
    initialize l_mensagem       to null
    initialize l_cont           to null

    let param.usrtip        = arg_val(1)
    let param.webusrcod     = arg_val(2)
    let param.sesnum        = arg_val(3)
    let param.macsissgl     = arg_val(4)
    let param.atdsrvnum     = arg_val(5)
    let param.atdsrvano     = arg_val(6)
    let param.c24pbmgrpcod  = arg_val(7)
    let param.ufdcod        = arg_val(8)

    #------------------------------------------
    #  ABRE BANCO   (TESTE ou PRODUCAO)
    #------------------------------------------
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read

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

    # LAUDO INICIO #

    #--------------------------------------------------------------
    # Busca informacoes do servico
    #--------------------------------------------------------------
    select datmservico.atdsrvorg   ,
           datmservico.asitipcod   ,
           datmservico.atdhorpvt   ,
           datmservico.atddat      ,
           datmservico.atdhor      ,
           datmservico.nom         ,
           datrservapol.ramcod     ,
           datrservapol.succod     ,
           datrservapol.aplnumdig  ,
           datrservapol.itmnumdig  ,
           datmservico.vcldes      ,
           datmservico.vclanomdl   ,
           datmservico.vcllicnum   ,
           datmservico.vclcorcod   ,
           datmservico.atdrsdflg   ,
           datmservico.atddfttxt   ,
           datmservico.atdvclsgl   ,
           datmservico.atdmotnom   ,
           datmservico.atddatprg   ,
           datmservico.atdhorprg   ,
           datmservico.socvclcod   ,
           datmservico.srvprlflg   ,
           datmservico.srrcoddig   ,
           datmservicocmp.roddantxt,
           datmservicocmp.bocnum   ,
           datmservicocmp.bocemi   ,
           datmservicocmp.rmcacpflg,
           datmservico.ciaempcod
      into ws.atdsrvorg,
           ws.asitipcod,
           ws.atdhorpvt,
           ws.atddat   ,
           ws.atdhor   ,
           ws.nom      ,
           ws.ramcod   ,
           ws.succod   ,
           ws.aplnumdig,
           ws.itmnumdig,
           ws.vcldes   ,
           ws.vclanomdl,
           ws.vcllicnum,
           ws.vclcorcod,
           ws.atdrsdflg,
           ws.atddfttxt,
           ws.atdvclsgl,
           ws.atdmotnom,
           ws.atddatprg,
           ws.atdhorprg,
           ws.socvclcod,
           ws.srvprlflg,
           ws.srrcoddig,
           ws.roddantxt,
           ws.bocnum   ,
           ws.bocemi   ,
           ws.rmcacpflg,
           ws.ciaempcod
      from datmservico,
     outer datmservicocmp,
     outer datrservapol

     where datmservico.atdsrvnum    = param.atdsrvnum
       and datmservico.atdsrvano    = param.atdsrvano

       and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
       and datmservicocmp.atdsrvano = datmservico.atdsrvano

       and datrservapol.atdsrvnum   = datmservico.atdsrvnum
       and datrservapol.atdsrvano   = datmservico.atdsrvano

    #--------------------------------------------------------------
    # Busca informacoes do local da ocorrencia
    #--------------------------------------------------------------
    call ctx04g00_local_completo(param.atdsrvnum, param.atdsrvano, 1) returning
        a_rrw[1].lclidttxt   ,
        a_rrw[1].lgdtip      ,
        a_rrw[1].lgdnom      ,
        a_rrw[1].lgdnum      ,
        a_rrw[1].lclbrrnom   ,
        a_rrw[1].brrnom      ,
        a_rrw[1].cidnom      ,
        a_rrw[1].ufdcod      ,
        a_rrw[1].lclrefptotxt,
        a_rrw[1].endzon      ,
        a_rrw[1].lgdcep      ,
        a_rrw[1].lgdcepcmp   ,
        a_rrw[1].dddcod      ,
        a_rrw[1].lcltelnum   ,
        a_rrw[1].lclcttnom   ,
        a_rrw[1].c24lclpdrcod,
        ws.sqlcode           ,
        a_rrw[1].endcmp 
        
    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    let m_subbairro[1].lclbrrnom = a_rrw[1].lclbrrnom
    
    call cts06g10_monta_brr_subbrr(a_rrw[1].brrnom,
                                   a_rrw[1].lclbrrnom)
         returning a_rrw[1].lclbrrnom         

    if ws.sqlcode <> 0  then
       #OSF 20370
       display "ERRO@@Erro (", ws.sqlcode using'<<<<<&', ") na leitura local de ocorrencia. AVISE A INFORMATICA!@@BACK"
       exit program
    end if
    let a_rrw[1].lgdtxt = a_rrw[1].lgdtip clipped, " ",
                          a_rrw[1].lgdnom clipped, " ",
                          a_rrw[1].lgdnum using "<<<<#", " ",
                          a_rrw[1].endcmp clipped 

    #--------------------------------------------------------------
    # Busca informacoes do local de destino
    #--------------------------------------------------------------
    call ctx04g00_local_completo(param.atdsrvnum, param.atdsrvano, 2) returning
        a_rrw[2].lclidttxt   ,
        a_rrw[2].lgdtip      ,
        a_rrw[2].lgdnom      ,
        a_rrw[2].lgdnum      ,
        a_rrw[2].lclbrrnom   ,
        a_rrw[2].brrnom      ,
        a_rrw[2].cidnom      ,
        a_rrw[2].ufdcod      ,
        a_rrw[2].lclrefptotxt,
        a_rrw[2].endzon      ,
        a_rrw[2].lgdcep      ,
        a_rrw[2].lgdcepcmp   ,
        a_rrw[2].dddcod      ,
        a_rrw[2].lcltelnum   ,
        a_rrw[2].lclcttnom   ,
        a_rrw[2].c24lclpdrcod,
        ws.sqlcode           ,
        a_rrw[2].endcmp          

    if ws.sqlcode <> notfound then
       if ws.sqlcode = 0   then
          let a_rrw[2].lgdtxt = a_rrw[2].lgdtip clipped, " ",
                                a_rrw[2].lgdnom clipped, " ",
                                a_rrw[2].lgdnum using "<<<<#", " ",
                                a_rrw[2].endcmp clipped 
       else
          #OSF 20370
          display "ERRO@@Erro (", ws.sqlcode using'<<<<<&', ") na leitura local de destino. AVISE A INFORMATICA!@@BACK"
          exit program
       end if
    end if

    #--------------------------------------------------------------
    # Busca natureza Porto Socorro/Sinistro de R.E.
    #--------------------------------------------------------------
    if ws.atdsrvorg = 9  or
       ws.atdsrvorg = 13 then

       select lclrsccod   ,
              orrdat      ,
              orrhor      ,
              sinntzcod   ,
              socntzcod
         into ws.lclrsccod,
              ws.orrdat   ,
              ws.orrhor   ,
              ws.sinntzcod,
              ws.socntzcod
        from datmsrvre
        where atdsrvnum = param.atdsrvnum  and
              atdsrvano = param.atdsrvano

       let ws.ntzdes = "*** NAO CADASTRADO ***"

       if ws.sinntzcod is not null  then
          select sinntzdes
            into ws.ntzdes
            from sgaknatur
           where sinramgrp = "4"      and
                 sinntzcod = ws.sinntzcod
       else
          select socntzdes
            into ws.ntzdes
            from datksocntz
           where socntzcod = ws.socntzcod
       end if
    end if

    let ws.srvtipabvdes = "NAO CADASTR"

    select srvtipabvdes
      into ws.srvtipabvdes
      from datksrvtip
     where atdsrvorg = ws.atdsrvorg

    let ws.asitipabvdes = "N/CADAST"

    select asitipabvdes
      into ws.asitipabvdes
      from datkasitip
     where asitipcod = ws.asitipcod

    case ws.atdrsdflg
       when "S"  let ws.atdrsddes = "SIM"
       when "N"  let ws.atdrsddes = "NAO"
    end case

    case ws.rmcacpflg
       when "S"  let ws.rmcacpdes = "SIM"
       when "N"  let ws.rmcacpdes = "NAO"
    end case

    if ws.vclcorcod   is not null    then
       select cpodes
         into ws.vclcordes
         from iddkdominio
        where cponom = "vclcorcod"    and
              cpocod = ws.vclcorcod
    end if

#=> PSI.187801
    select incvlr, anlokaflg
      into d_wdatc049.incvlr, d_wdatc049.anlokaflg
      from dbsmsrvacr
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
    if sqlca.sqlcode = notfound then
       display "ERRO@@Serviço não encontrado@@BACK"
       exit program
    end if

#=> PSI.187801
    if d_wdatc049.anlokaflg = "P" then
       display "PADRAO@@1@@B@@C@@0@@Atenção: Serviço pendente pelo motivo@@"
       declare cwdatc0490101 cursor for
          select srvacrobs, srvacrobslinseq
            from dbsmsrvacrobs
           where atdsrvnum = param.atdsrvnum
             and atdsrvano = param.atdsrvano
             and srvacrobslinseq between 1 and 5
           order by 2
       let l_achou = false
       initialize l_texto to null
       foreach cwdatc0490101 into lr_acrobs.*
          let l_achou = true
          let l_texto = l_texto clipped,
                        lr_acrobs.srvacrobs clipped,
                        "<br>"
       end foreach
       if not l_achou then
          display "PADRAO@@6@@1@@N@@C@@1@@1@@100%@@ @@@@"
       else
          display "PADRAO@@6@@1@@N@@C@@1@@1@@100%@@", l_texto clipped, "@@@@"
       end if
    end if

    initialize ws.ciaempsgl to null
    # Pesquisa a empresa do servico para exibir no cabecalho
    call cty14g00_empresa(1, ws.ciaempcod)
         returning l_ret,
                   l_mensagem,
                   ws.ciaempsgl
                   
    call cts59g00_idt_srv_saps(1, param.atdsrvnum, param.atdsrvano) returning m_psaerrcod
    
    if m_psaerrcod = 0
       then
       let ws.ciaempsgl = 'SERVIÇOS AVULSOS PORTO SEGURO' 
    end if
    
    if l_ret <> 1 then
       let ws.ciaempsgl = ""
    else
       let ws.ciaempsgl = " - ", ws.ciaempsgl
    end if
    
    # buscar data/hora do acionamento do servico
    whenever error continue
    select atdetpdat, atdetphor into l_acihor.atddat, l_acihor.atdhor
    from datmsrvacp
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
      and atdsrvseq = ( select max(atdsrvseq)
                        from datmsrvacp
                        where atdsrvnum = param.atdsrvnum
                          and atdsrvano = param.atdsrvano
                          and atdetpcod in (4,3,10) )
    whenever error stop
    
    if l_acihor.atddat is not null and
       l_acihor.atdhor is not null
       then
       let l_acihor.acistr = "PADRAO@@8@@Acionado em@@", l_acihor.atddat,
                             " as ",l_acihor.atdhor,"@@"
    else
       let l_acihor.acistr = "PADRAO@@8@@Solicitado em@@", ws.atddat,
                             " as ",ws.atdhor,"@@"
    end if
    
    display "PADRAO@@1@@B@@C@@0@@Informações do serviço", ws.ciaempsgl clipped, "@@"
    display "PADRAO@@8@@Ordem  serviço@@", ws.atdsrvorg using "&&", "/",
             param.atdsrvnum using "&&&&&&&" , "-",
             param.atdsrvano using "&&",
             "  ", ws.srvtipabvdes clipped,
             "@@"
    display "PADRAO@@8@@Tipo socorro@@" ,ws.asitipabvdes,"@@"
    display l_acihor.acistr clipped

    #-----------------------------------------------------------
    # Se codigo veiculo informado, ler cadastro de veiculos
    #-----------------------------------------------------------
    if ws.socvclcod  is not null   then
       select atdvclsgl
         into ws.atdvclsgl
         from datkveiculo
        where datkveiculo.socvclcod  =  ws.socvclcod
    end if

    #-----------------------------------------------------------
    # Se codigo socorrista informado, ler cadastro de socorrista
    #-----------------------------------------------------------
    if ws.srrcoddig  is not null   then
       select srrabvnom
         into ws.srrabvnom
         from datksrr
        where datksrr.srrcoddig  =  ws.srrcoddig
    end if

    if ws.atdvclsgl  is not null   or
       ws.atdmotnom  is not null   or
       ws.srrabvnom  is not null   then
       if ws.atdmotnom  is not null and
          ws.atdmotnom  <>  "  "    then
           display "PADRAO@@8@@Viatura / Socorrista@@",
                   ws.atdvclsgl clipped,
                   " / ",
                   ws.atdmotnom clipped, "@@"
       else
           display "PADRAO@@8@@Viatura / Socorrista@@",
                   ws.atdvclsgl clipped,
                   " / ", ws.srrcoddig using "####&&&&",
                   " - ", ws.srrabvnom, "@@"
       end if
    end if

    #-----------------------------------------------------
    # INFO VEÍCULO
    #-----------------------------------------------------
    if ws.atdsrvorg = 9  or
       ws.atdsrvorg = 13 then
    else
       display "PADRAO@@8@@Veículo@@",ws.vcldes clipped,
               " Ano: ", ws.vclanomdl clipped,
               " Placa: ", ws.vcllicnum clipped, "@@"
    end if

    if ws.atdsrvorg  =   4     or
       ws.atdsrvorg  =   6     or
       ws.atdsrvorg  =   1     then
       display  "PADRAO@@8@@Problema@@", ws.atddfttxt,"@@"
    else
       if ws.atdsrvorg =  5   or
          ws.atdsrvorg =  7   then
       else
          if ws.atdsrvorg =  9   or
             ws.atdsrvorg = 13   then
             display  "PADRAO@@8@@Problema@@", ws.atddfttxt,"@@"
             display  "PADRAO@@8@@Natureza@@", ws.ntzdes,"@@"
          end if
       end if
    end if

    initialize ws.lclrefptotxt1, ws.lclrefptotxt2 to null
    let ws.lclrefptotxt1 = a_rrw[1].lclrefptotxt[001,100]
    let ws.lclrefptotxt2 = a_rrw[1].lclrefptotxt[101,200]

    display "PADRAO@@8@@Local de ocorrência@@",a_rrw[1].cidnom clipped, " - ", a_rrw[1].ufdcod,"@@"

    #-----------------------------------------------------
    # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (DESTINO)
    #-----------------------------------------------------
    if ws.atdsrvorg  =   4    or
       ws.atdsrvorg  =   6    or
       ws.atdsrvorg  =   1    or
       ws.atdsrvorg  =   5    or
       ws.atdsrvorg  =   7    then
        display "PADRAO@@8@@Local destino@@", a_rrw[2].cidnom clipped, " - ", a_rrw[2].ufdcod,"@@"
    end if

    #------------------------------------------------
    # PARA ASSISTENCIA PASSAGEIROS - TAXI  (DESTINO)
    #------------------------------------------------
    if ws.atdsrvorg  =   2    or
       ws.atdsrvorg  =   3    then

        if (ws.atdsrvorg =  3 )  or
           (ws.atdsrvorg =  2    and
            ws.asitipcod = 10 )  then
           display "HIDDEN@@<input type='hidden' name='cidcod' value='909090'>@@"
        else
            display  "PADRAO@@8@@Local destino@@", a_rrw[2].cidnom clipped, " - ",a_rrw[2].ufdcod,"@@"
        end if

    end if

    # LAUDO FIM #

    #----------------------------------------------
    #  Informações Adicionais
    #----------------------------------------------

    # OSF 20370
    display "PADRAO@@1@@B@@C@@0@@Informações adicionais@@"

    display "PADRAO@@8@@Valor inicial do serviço@@", d_wdatc049.incvlr using "###,###,##&.&&", "@@"

#=> PSI.187801
    case ws.atdsrvorg
       when 13      let d_wdatc049.soctip = 3
       when 9       let d_wdatc049.soctip = 3
       when 8       let d_wdatc049.soctip = 2
       otherwise    let d_wdatc049.soctip = 1
    end case

    if d_wdatc049.anlokaflg = "P" then

#=>    ACESSA 'DETALHE DO PROBLEMA'
       select c24pbmcod
         into l_c24pbmcod
         from datrsrvpbm
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and c24pbmseq = 2
       if sqlca.sqlcode <> 0 and sqlca.sqlcode <> notfound then
          display "ERRO@@Erro ao encontrar detalhe do problema@@BACK"
          exit program
       end if
       display "HIDDEN@@<input type='hidden' name='c24pbmcod' value='",
               l_c24pbmcod using "<<<<&", "'>@@"

#=>    ACESSA O CODIGO DA CIDADE (TIPO 'HIDDEN')
       if d_wdatc049.soctip <> 3 then
          if a_rrw[2].cidnom is not null and
              a_rrw[2].ufdcod is not null then
              select min (cidcod)
                into d_wdatc049.cidcod
                from glakcid
               where cidnom = a_rrw[2].cidnom
                 and ufdcod = a_rrw[2].ufdcod
              if sqlca.sqlcode = notfound then
                 display "ERRO@@Código da cidade não encontrado@@BACK"
                 exit program(1)
              end if
              display "HIDDEN@@<input type='hidden' name='cidcod' value='",
                      d_wdatc049.cidcod using "<<<<<<<&", "'>@@"
          end if
       else
           display "HIDDEN@@<input type='hidden' name='cidcod' value='909090'>@@"
       end if

    else #=> FLAG DE PENDENCIA (anlokaflg) <> "P"

       #--> Pesquisa Problemas de acordo com o Grupo
       let ws.comando = "select datkpbm.c24pbmcod,",
                        "       datkpbm.c24pbmdes ",
                        "  from datkpbm ",
                        " where datkpbm.c24pbmgrpcod = ", param.c24pbmgrpcod clipped,
                        "   and datkpbm.c24pbmstt = 'A' ",
                        " order by 2"

       prepare sel_probs from ws.comando

       declare c_probs cursor for sel_probs

       open c_probs

       let ws.cont     = 0
       let ws.padrao   = ""

       foreach c_probs
          into d_wdatc049.c24pbmcod,
               d_wdatc049.c24pbmdes

           let ws.padrao = ws.padrao clipped,
                           d_wdatc049.c24pbmdes clipped,
                           "@@",
                           "0",
                           "@@",
                           d_wdatc049.c24pbmcod clipped,
                           "@@"

           let ws.cont = (ws.cont + 1)

       end foreach

       # OSF 20370
       case ws.cont
          when 0    let ws.padrao = "PADRAO@@2@@c24pbmcod@@Detalhe do problema@@0@@0@@", ws.srvtipabvdes clipped, "@@1@@0@@" clipped
          when 1    let ws.padrao = "PADRAO@@2@@c24pbmcod@@Detalhe do problema@@0@@0@@", ws.padrao clipped
          otherwise let ws.padrao = "PADRAO@@2@@c24pbmcod@@Detalhe do problema@@0@@0@@(Selecione uma opcao)@@1@@-1@@", ws.padrao clipped
       end case

       display ws.padrao clipped

       #--> Pesquisa Cidades de acordo com o Estado

       #--> Para RE não mostra a combo de cidades
       if d_wdatc049.soctip <> 3 then

           ####if a_rrw[2].cidnom is not null then
           ####    let ws.cidnom = a_rrw[2].cidnom clipped
           ####else
           ####    if a_rrw[1].cidnom is not null then
           ####        let ws.cidnom = a_rrw[1].cidnom clipped
           ####    end if
           ####end if
           ####
           ####let ws.comando = "select glakcid.cidcod,",
           ####                 "       glakcid.cidnom ",
           ####                 "  from glakcid ",
           ####                 " where glakcid.ufdcod = '", param.ufdcod clipped,
           ####                 "'", " order by 2"
           ####
           ####prepare sel_cidades from ws.comando
           ####
           ####declare c_cidades cursor for sel_cidades
           ####
           ####open c_cidades
           ####
           ##### OSF 20370
           ####let ws.padrao = "PADRAO@@2@@cidcod@@Cidade do destino@@0@@0@@(Selecione uma opcao)@@1@@0@@" clipped
           ####
           ####foreach c_cidades
           ####   into d_wdatc049.cidcod,
           ####        d_wdatc049.cidnom
           ####
           ####    let ws.selecionado = "0"
           ####    if d_wdatc049.cidnom = ws.cidnom then
           ####        let ws.selecionado = "1"
           ####    end if
           ####
           ####    let ws.tamanho = length(ws.padrao)
           ####
           ####    if ws.tamanho <= 31900 then
           ####        let ws.padrao = ws.padrao clipped,
           ####                        d_wdatc049.cidnom clipped,
           ####                        "@@",
           ####                        ws.selecionado,
           ####                        "@@",
           ####                        d_wdatc049.cidcod clipped,
           ####                        "@@"
           ####    else
           ####        let ws.padrao2 = ws.padrao2 clipped,
           ####                        d_wdatc049.cidnom clipped,
           ####                        "@@",
           ####                        ws.selecionado,
           ####                        "@@",
           ####                        d_wdatc049.cidcod clipped,
           ####                        "@@"
           ####    end if
           ####
           ####end foreach

           #display ws.padrao clipped, ws.padrao2 clipped
           display "PADRAO@@8@@Cidade do destino@@", a_rrw[2].cidnom clipped, " - ",a_rrw[2].ufdcod,"@@"
           display "TEXTO@@Informe o detalhe do problema, a cidade do destino, os valores adicionais e o histórico (se houver).@@"

       else

           display "HIDDEN@@<input type='hidden' name='cidcod' value='909090'>@@"
           display "TEXTO@@Informe o detalhe do problema, os valores adicionais e o histórico (se houver).@@"

       end if

    end if

    # Se for servico de auto, solicita renavam e quilometragem do veiculo
    if ws.atdsrvorg = 1 or
       ws.atdsrvorg = 4 or
       ws.atdsrvorg = 5 or
       ws.atdsrvorg = 6 or
       ws.atdsrvorg = 7 or
       ws.atdsrvorg = 12 or
       ws.atdsrvorg = 13 then

        # RENAVAM
        display  "PADRAO@@8@@Renavam do veículo@@",
                 "<input type='text' name='renavam' size='15' maxlength='9' onKeypress='return somenteNumeros(event)'>", "@@"

        # QUILOMETRAGEM
        display  "PADRAO@@8@@Quilometragem atual@@",
                 "<input type='text' name='quilometragem' size='15' maxlength='6' onKeypress='return somenteNumeros(event)'>", "@@"

    end if

    #--> Seleciona os adicionais de acordo com o tipo de serviço
    # OSF 20370
    display "PADRAO@@1@@B@@C@@0@@Valores adicionais@@"

    ##PSI:188751
    whenever error continue
      select grlinf into ws.rispcstcod
        from datkgeral
       where grlchv = "PSOCODCSTRISDPR"
    whenever error stop
    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode <> 100 then
          display "ERRO@@Problema no acesso a tabela datkgeral@@BACK"
          exit program
       end if
    end if

    ## Codigo do custo para RIS fora do prazo
    whenever error continue
      select grlinf into ws.risfcstcod
        from datkgeral
       where grlchv = "PSOCODCSTRISFPR"
    whenever error stop
    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode <> 100 then
          display "ERRO@@Problema no acesso a tabela datkgeral - RIS fora prazo@@BACK"
          exit program
       end if
    end if
    ##Fim

    #--> Para RE não mostra a combo de cidades
    if d_wdatc049.soctip <> 3 then

       let ws.comando = "select dbskcustosocorro.soccstcod,",
                        "       dbskcustosocorro.soccstdes",
                        "  from dbskcustosocorro",
                        " where dbskcustosocorro.soccstcod > 0",
                        "   and dbskcustosocorro.soctip <> 3",
                        "   and dbskcustosocorro.soccstcod not in (1,2,7,8)",
                        "   and dbskcustosocorro.soccstsitcod <> 'C'"

    else

        let ws.comando = "select dbskcustosocorro.soccstcod,",
                         "       dbskcustosocorro.soccstdes",
                         "  from dbskcustosocorro",
                         " where dbskcustosocorro.soccstcod > 0",
                         "   and dbskcustosocorro.soctip = 3",
                         "   and dbskcustosocorro.soccstsitcod <> 'C'"

    end if

    prepare sel_adics from ws.comando
    declare c_adics cursor for sel_adics

#=> PSI.187801
    let ws.comando = "select socadccstvlr, socadccstqtd",
                     "  from dbsmsrvcst",
                     " where atdsrvnum = ", param.atdsrvnum,
                     "   and atdsrvano = ", param.atdsrvano,
                     "   and soccstcod = ?"
    prepare pwdatc0490202 from ws.comando
    declare cwdatc0490202 cursor for pwdatc0490202

    open c_adics

    display "PADRAO@@6@@3@@",
            "N@@C@@0@@1@@29%@@Adicional@@@@",
            "N@@C@@0@@1@@35%@@Quantidade@@@@",
            "N@@C@@0@@1@@36%@@Valor total@@@@" # OSF 20370

    let ws.cont = 0
    let ws.comando = ""

    foreach c_adics
       into d_wdatc049.soccstcod,
            d_wdatc049.soccstdes

        let ws.cont = ( ws.cont + 1 )

        ### PSI:188751 let ws.comando = ws.comando clipped, "C", d_wdatc049.soccstcod using "&&&&"

        display "HIDDEN@@<input type='hidden' name='C", ws.cont using "&&", "' value='", d_wdatc049.soccstcod using "&&&&","'>@@"

      # let ws.padrao  = "<input type='text' name='Q", ws.cont using "&&", "' size='10' maxlength='06' onchange='funcValidaQ",ws.cont using "&&","()'>"
      # let ws.padrao2 = "<input type='text' name='V", ws.cont using "&&", "' size='10' maxlength='10' onchange='funcValidaV",ws.cont using "&&","()'>"

#=>     PSI.187801
        let l_vlrvalue = null
        let l_qtdvalue = null

        ### PSI188751 if d_wdatc049.anlokaflg = "P" then
        open  cwdatc0490202 using d_wdatc049.soccstcod
        fetch cwdatc0490202  into lr_srvcst.*
        if sqlca.sqlcode = 0 then
           let l_vlrvalue = lr_srvcst.socadccstvlr using "<<<<<<<<<&.&&"
           let l_vlrvalue = wdatc049_literal(l_vlrvalue)
           let l_vlrvalue = "value='", l_vlrvalue clipped, "'"
           let l_qtdvalue = lr_srvcst.socadccstqtd using "<<<<<&.&&"
           let l_qtdvalue = wdatc049_literal(l_qtdvalue)
           let l_qtdvalue = "value='", l_qtdvalue clipped, "'"
        end if

        ## Se o custo for de RIS no prazo ou fora,
        ## nao permite editar
        ##----------------------------------------
        if d_wdatc049.soccstcod = ws.rispcstcod  or
           d_wdatc049.soccstcod = ws.risfcstcod  then
           let ws.comando = "readonly"
        else
           let ws.comando = ""
        end if

        let ws.padrao  = "<input type='text' name='Q", ws.cont using "&&",
                         "' size='10' maxlength='06' ", l_qtdvalue clipped,
                         ws.comando clipped , ##PSI188751
                         " onBlur='javascript:this.value = formatarValor(this.value,true)'",
                         " onKeypress='return somenteNumeros(event)'>"
        let ws.padrao2 = "<input type='text' name='V", ws.cont using "&&",
                         "' size='10' maxlength='10' ", l_vlrvalue clipped,
                         ws.comando clipped , ##PSI188751
                         " onBlur='javascript:this.value = formatarValor(this.value,true)'",
                         " onKeypress='return somenteNumeros(event)'>"

        display "PADRAO@@6@@3@@",
                "N@@L@@0@@1@@29%@@", d_wdatc049.soccstdes clipped, "@@@@",
                "N@@C@@1@@1@@35%@@", ws.padrao  clipped, "@@@@",
                "N@@C@@1@@1@@36%@@", ws.padrao2 clipped, "@@@@"

    end foreach

    for ws.cont2 = (ws.cont + 1) to 10
        display "HIDDEN@@<input type='hidden' name='C", ws.cont2 using "&&", "' value='0'>@@"
        display "HIDDEN@@<input type='hidden' name='Q", ws.cont2 using "&&", "' value='0'>@@"
        display "HIDDEN@@<input type='hidden' name='V", ws.cont2 using "&&", "' value='0'>@@"
    end for

    #PSI 208264 - Se o prestador possuir um veiculo com o sistema de pedagio
    #eletronico, eh apresentada a opcao: "Utilizou Pedágio Eletrônico Porto?"
    let l_cont = 0
    whenever error continue
      select count(*) into l_cont
        from datkveiculo
       where pstcoddig = ws2.webprscod
         and prrsemnum is not null
    whenever error stop
    if  sqlca.sqlcode <> 0 then
        if  sqlca.sqlcode <> 100 then
           display "ERRO@@Problema no acesso a tabela datkveiculo - Pedagio Eletronico@@BACK"
           exit program
        end if
    end if
    if  l_cont > 0 then

        let l_cont = 0

        let ws.comando = "select pdgqtd, pdgttlvlr",
                          " from dbarsemprrsrv",
                         " where atdsrvnum = ", param.atdsrvnum,
                           " and atdsrvano = ", param.atdsrvano
        prepare pwdatc0490204 from ws.comando
        declare cwdatc0490204 cursor for pwdatc0490204
        open  cwdatc0490204
        whenever error continue
        fetch cwdatc0490204 into lr_pdg.*
        whenever error stop
        if  sqlca.sqlcode = 0 then
            let l_qtdvalue = lr_pdg.pdgqtd using "<<<<<&.&&"
            let l_qtdvalue = wdatc049_literal(l_qtdvalue)
            let l_qtdvalue = "value='", l_qtdvalue clipped, "'"
            let l_vlrvalue = lr_pdg.pdgttlvlr using "<<<<<<<<<&.&&"
            let l_vlrvalue = wdatc049_literal(l_vlrvalue)
            let l_vlrvalue = "value='", l_vlrvalue clipped, "'"
        else
            if  sqlca.sqlcode <> 100 then
               display "ERRO@@Problema no acesso a tabela dbarsemprrsrv - Pedagio Eletronico@@BACK"
               exit program
            end if
            let lr_pdg.pdgqtd = 0
            let lr_pdg.pdgttlvlr = 0
        end if

        display "PADRAO@@1@@B@@C@@0@@Pedágio Eletrônico Porto Seguro - Passagem Livre@@"

        display "PADRAO@@4@@3@@Utilizou Pedágio Eletrônico Porto?@@0@@",
                "@@pdgelt@@1@@Sim@@0@@0@@@@",
                "@@pdgelt@@2@@Não@@0@@0@@@@@@"

        display "HIDDEN@@<input type='hidden' name='C99' value='0000'>@@"

        let ws.padrao  = "<input type='text' name='Q99' ", l_qtdvalue, " size='10' maxlength='06'",
                         " onBlur='javascript:this.value = formatarValor(this.value,true)'",
                         " onKeypress='return somenteNumeros(event)'>"
        let ws.padrao2 = "<input type='text' name='V99' ", l_vlrvalue, " size='10' maxlength='10'",
                         " onBlur='javascript:this.value = formatarValor(this.value,true)'",
                         " onKeypress='return somenteNumeros(event)'>"

        display "PADRAO@@6@@3@@",
                "N@@C@@0@@1@@29%@@@@@@",
                "N@@C@@0@@1@@35%@@Quantidade@@@@",
                "N@@C@@0@@1@@36%@@Valor total@@@@"

        display "PADRAO@@6@@3@@",
                "N@@L@@0@@1@@29%@@Passagens@@@@",
                "N@@C@@1@@1@@35%@@", ws.padrao  clipped, "@@@@",
                "N@@C@@1@@1@@36%@@", ws.padrao2 clipped, "@@@@"
    end if

    #PSI 197858 - Incluir ultimo historico cadastrado pelo prestador na web
    # para o servico
    display "PADRAO@@1@@B@@C@@0@@Ultimo Histórico informado pelo Prestador@@"
    let ws.comando = "select c24txtseq, c24srvdsc, ",
                     "       ligdat, lighorinc     ",
                     "  from datmservhist",
                     " where atdsrvnum = ", param.atdsrvnum,
                     "   and atdsrvano = ", param.atdsrvano,
                     "   and c24funmat = 999999 ",
                     "   order by ligdat desc, lighorinc desc, c24txtseq "
    prepare pwdatc0490203 from ws.comando
    declare cwdatc0490203 cursor for pwdatc0490203

    foreach cwdatc0490203 into d_hist.c24txtseq,
                               d_hist.c24srvdsc,
                               d_hist.ligdat,
                               d_hist.lighorinc
         if d_hist.ligdatant is not null and
            d_hist.ligdat <> d_hist.ligdatant then
            #historico cadastrado em dia diferente do primeiro registro lido
            exit foreach
         end if
         if d_hist.lighorincant is not null and
            d_hist.lighorinc <> d_hist.lighorincant then
            #historico cadastrado no mesmo dia so que em horario diferente
            # do primeiro registro lido
            exit foreach
         end if
         if d_hist.c24srvdsc = "--- Prestador informou via internet: ---" then
            #esta frase indica inicio de um registro vindo do Portal, entao
            # salvar a data e hora para comparar com o proximo registro lido
            # caso o prestador nao tenha digitado nenhum historico em sua
            # ultima visualizada no servico ele nao ira aparecer
            let d_hist.ligdatant = d_hist.ligdat
            let d_hist.lighorincant = d_hist.lighorinc
            continue foreach
         end if
         if d_hist.ligdatant is null and
            d_hist.lighorincant is null then
            #caso tenha lido um outro historico que foi gravado de um processo
            # batch (matricula 99999) mas nao foi pelo prestador no Portal
            continue foreach
         end if
         display "PADRAO@@1@@N@@L@@1@@", d_hist.c24srvdsc, "@@"
    end foreach
    #exibir linha em branco
    display "PADRAO@@1@@N@@L@@1@@@@"


    #--> O cabeçalho do Histórico deve ser o último item,
    #    porque o textarea é montado pelo pl.
    display "PADRAO@@1@@B@@C@@0@@Histórico@@"  # OSF 20370

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

# SUBSTITUI '.' POR ','
#-------------------------------------------------------------------------------
function wdatc049_literal(l_valor)
#-------------------------------------------------------------------------------
   define l_valor     char(20),
          l_retorno   char(20),
          l_i         smallint

   initialize l_retorno to null
   initialize l_i to null

   for l_i = 1 to length(l_valor)
      if l_valor[l_i,l_i] = "." then
         let l_retorno = l_retorno clipped, ","
      else
         let l_retorno = l_retorno clipped, l_valor[l_i,l_i]
      end if
   end for

   return l_retorno

end function
