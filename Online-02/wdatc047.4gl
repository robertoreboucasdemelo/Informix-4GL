#############################################################################
# Nome do Modulo: wdatc047                                             Zyon #
#                                                                           #
#                                                                  Mar/2003 #
# Tela de acerto de valores de serviço                                      #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 02/06/2003  PSI 163759   R. Santos    Acerto de layout das telas          #
# 31/07/2008  PSI 227145   Fabio Costa  Buscar data/hora do acionamento do  #
#                                       servico                             #
# 13/08/2009  PSI 244236   Burini       Inclusão do Sub-Dairro              #
#############################################################################

database porto

main

    define ws record
        sttsess             dec     (1,0),
        comando             char    (1000),
        padrao              char    (32000),
        servico             char    (13),
        srvtipabvdes        like    datksrvtip.srvtipabvdes,
        selecionado         char    (1),
        ufdcod              like    glakest.ufdcod,
        cont                integer,
        # Laudo
        atdsrvorg           like    datmservico.atdsrvorg,
        asitipcod           like    datmservico.asitipcod,
        asimtvcod           like    datkasimtv.asimtvcod,
        asimtvdes           like    datkasimtv.asimtvdes,
        atdhorpvt           like    datmservico.atdhorpvt,
        atddat              like    datmservico.atddat,
        atdhor              like    datmservico.atdhor,
        nom                 like    datmservico.nom,
        ramcod              like    datrservapol.ramcod,
        succod              like    datrservapol.succod,
        aplnumdig           like    datrservapol.aplnumdig,
        itmnumdig           like    datrservapol.itmnumdig,
        vcldes              like    datmservico.vcldes,
        vclanomdl           like    datmservico.vclanomdl,
        vcllicnum           like    datmservico.vcllicnum,
        vclcorcod           like    datmservico.vclcorcod,
        dddcod              like    gsakend.dddcod,
        teltxt              like    gsakend.teltxt,
        atdrsdflg           like    datmservico.atdrsdflg,
        atddfttxt           like    datmservico.atddfttxt,
        roddantxt           like    datmservicocmp.roddantxt,
        bocnum              like    datmservicocmp.bocnum,
        bocemi              like    datmservicocmp.bocemi,
        rmcacpflg           like    datmservicocmp.rmcacpflg,
        srvprlflg           like    datmservico.srvprlflg,
        atdvclsgl           like    datmservico.atdvclsgl,
        socvclcod           like    datmservico.socvclcod,
        atdmotnom           like    datmservico.atdmotnom,
        srrcoddig           like    datmservico.srrcoddig,
        srrabvnom           like    datksrr.srrabvnom,
        vclcordes           char    (20),
        asitipabvdes        like    datkasitip.asitipabvdes,
        atdrsddes           char    (3),
        rmcacpdes           char    (3),
        atddatprg           like    datmservico.atddatprg,
        atdhorprg           like    datmservico.atdhorprg,
        pasnom              like    datmpassageiro.pasnom,
        pasidd              like    datmpassageiro.pasidd,
        bagflg              like    datmassistpassag.bagflg,
        lclrsccod           like    datmsrvre.lclrsccod,
        orrdat              like    datmsrvre.orrdat,
        orrhor              like    datmsrvre.orrhor,
        sinntzcod           like    datmsrvre.sinntzcod,
        socntzcod           like     datmsrvre.socntzcod,
        ntzdes              char    (40),
        atddmccidnom        like    datmassistpassag.atddmccidnom,
        atddmcufdcod        like    datmassistpassag.atddmcufdcod,
        atddstcidnom        like    datmassistpassag.atddstcidnom,
        atddstufdcod        like    datmassistpassag.atddstufdcod,
        lclrefptotxt1       char    (100),
        lclrefptotxt2       char    (100),
        sqlcode             integer ,
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
        atdsrvano           like    datmservico.atdsrvano
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

    define d_wdatc047 record
        ufdcod              like    glakest.ufdcod,
        ufdnom              like    glakest.ufdnom,
        c24pbmgrpcod        like    datkpbmgrp.c24pbmgrpcod,
        c24pbmgrpdes        like    datkpbmgrp.c24pbmgrpdes,
        incvlr              like    dbsmsrvacr.incvlr,
        soctip              like    dbskcustosocorro.soctip
    end record
    
    define l_acihor record
           atddat  like datmsrvacp.atdetpdat ,
           atdhor  like datmsrvacp.atdetphor ,
           acistr  char(70)
    end record
    
    define m_subbairro array[03] of record
           lclbrrnom   like datmlcl.lclbrrnom
    end record     
   
    define l_ret            smallint
    define l_mensagem       char(100)
    define m_psaerrcod      integer

    initialize ws.*         to null
    initialize a_rrw        to null
    initialize param.*      to null
    initialize ws2.*        to null
    initialize d_wdatc047   to null
    initialize l_acihor.*   to null
    initialize m_subbairro  to null
    initialize l_ret        to null
    initialize l_mensagem   to null
    initialize m_psaerrcod  to null

    let param.usrtip        = arg_val(1)
    let param.webusrcod     = arg_val(2)
    let param.sesnum        = arg_val(3)
    let param.macsissgl     = arg_val(4)
    let param.atdsrvnum     = arg_val(5)
    let param.atdsrvano     = arg_val(6)

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

# OSF 20370
{
    ##### LAUDO #####

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
           datmservicocmp.rmcacpflg

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
           ws.rmcacpflg

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
        ws.sqlcode

    if ws.sqlcode <> 0  then
       #OSF 20370
       display "ERRO@@Erro (", ws.sqlcode using'<<<<<&', ") na leitura local de ocorrencia. AVISE A INFORMATICA!@@BACK"
       exit program
    end if
    let a_rrw[1].lgdtxt = a_rrw[1].lgdtip clipped, " ",
                          a_rrw[1].lgdnom clipped, " ",
                          a_rrw[1].lgdnum using "<<<<#"

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
        ws.sqlcode

    if ws.sqlcode <> notfound then
       if ws.sqlcode = 0   then
          let a_rrw[2].lgdtxt = a_rrw[2].lgdtip clipped, " ",
                                a_rrw[2].lgdnom clipped, " ",
                                a_rrw[2].lgdnum using "<<<<#"
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

    display "PADRAO@@1@@B@@C@@0@@Informações do servi\347o@@"
    display "PADRAO@@8@@Tipo de serviço@@", ws.srvtipabvdes,"@@"
    display "PADRAO@@8@@Ordem  serviço@@", ws.atdsrvorg using "&&", "/",
             param.atdsrvnum using "&&&&&&&" , "-",
             param.atdsrvano using "&&","@@"
    display "PADRAO@@8@@Tipo socorro@@" ,ws.asitipabvdes,"@@"
    if ws.atddatprg  is not null   then
       if ws.atddatprg = today     or
          ws.atddatprg > today     then
          display "PADRAO@@8@@Programado@@" ,ws.atddatprg, " as ", ws.atdhorprg,"@@"
       end if
    else
       display "PADRAO@@8@@Previsão@@"  ,ws.atdhorpvt,"@@"
    end if
    display "PADRAO@@8@@Solicitado em@@",ws.atddat," as ",ws.atdhor,"@@"

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
           display "PADRAO@@8@@Viatura@@", ws.atdvclsgl,"@@"
           display "PADRAO@@8@@Socorrista@@", ws.atdmotnom, "@@"
       else
           display "PADRAO@@8@@Viatura@@", ws.atdvclsgl,"@@"
           display "PADRAO@@8@@Socorrista@@", ws.srrcoddig using "####&&&&",
                   " - ", ws.srrabvnom,"@@"
       end if
    end if

    if ws.atdsrvorg = 9  or
       ws.atdsrvorg = 13 then
    else
       display "PADRAO@@1@@B@@C@@0@@Veículo@@"
       display "PADRAO@@8@@Modelo@@",ws.vcldes,"@@"
       display "PADRAO@@8@@Ano@@",ws.vclanomdl,"@@"
       display "PADRAO@@8@@Placa@@",ws.vcllicnum,"@@"
       display "PADRAO@@8@@Cor@@",ws.vclcordes,"@@"
    end if

    #-----------------------------------------------------------------
    # Exibe endereco do local da ocorrencia
    #-----------------------------------------------------------------

    initialize ws.lclrefptotxt1, ws.lclrefptotxt2 to null
    let ws.lclrefptotxt1 = a_rrw[1].lclrefptotxt[001,100]
    let ws.lclrefptotxt2 = a_rrw[1].lclrefptotxt[101,200]

    # OSF 20370
    display "PADRAO@@1@@B@@C@@0@@Local de ocorrência@@"

    if a_rrw[1].lclidttxt  is not null   then
        display "PADRAO@@8@@Local@@", a_rrw[1].lclidttxt,"@@"
    end if

    display "PADRAO@@8@@Endereço@@",a_rrw[1].lgdtxt,"@@"
    display "PADRAO@@8@@Bairro@@",a_rrw[1].lclbrrnom,"@@"
    display "PADRAO@@8@@Cidade@@",a_rrw[1].cidnom clipped, " - ", a_rrw[1].ufdcod,"@@"
    display "PADRAO@@8@@Telefone@@", "(",a_rrw[1].dddcod ,") ", a_rrw[1].lcltelnum,"@@"

    let ws.lclrefptotxt1 = ws.lclrefptotxt1 clipped
    if ws.lclrefptotxt1 is not null then
        display "PADRAO@@8@@Referência@@",ws.lclrefptotxt1,"@@", ws.lclrefptotxt2,"@@"
    end if

    display "PADRAO@@8@@Responsável@@", a_rrw[1].lclcttnom,"@@"

    if ws.atdrsddes is not null  then
        display  "PADRAO@@8@@Residência@@", ws.atdrsddes,"@@"
    end if

    if ws.atdsrvorg  =   4     or
       ws.atdsrvorg  =   6     or
       ws.atdsrvorg  =   1     then
       display  "PADRAO@@8@@Problema@@", ws.atddfttxt,"@@"
       display  "PADRAO@@8@@Rodas danificadas@@", ws.roddantxt,"@@"
       display  "PADRAO@@8@@Número B.O.@@", ws.bocnum using  "<<<<#", "  ", ws.bocemi,"@@"
    else
       if ws.atdsrvorg =  5   or
          ws.atdsrvorg =  7   then
          if ws.roddantxt is not null  then
              display "PADRAO@@8@@Rodas danificadas@@", ws.roddantxt,"@@"
          end if
       else
          if ws.atdsrvorg =  9   or
             ws.atdsrvorg = 13   then
             display  "PADRAO@@8@@Problema@@", ws.atddfttxt,"@@"
             display  "PADRAO@@8@@Natureza@@", ws.ntzdes,"@@"
             display  "PADRAO@@8@@Data ocorrência@@", ws.orrdat,"@@"
             display  "PADRAO@@8@@Hora ocorrencia@@", ws.orrhor,"@@"
          end if
       end if
    end if

    #-----------------------------------------------------
    # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (DESTINO)
    #-----------------------------------------------------
    if ws.atdsrvorg  =   4    or
       ws.atdsrvorg  =   6    or
       ws.atdsrvorg  =   1    or
       ws.atdsrvorg  =   5    or
       ws.atdsrvorg  =   7    then
        display "PADRAO@@1@@B@@C@@0@@Local destino@@"
        display "PADRAO@@8@@Local@@", a_rrw[2].lclidttxt,"@@"
        display "PADRAO@@8@@Endereço@@", a_rrw[2].lgdtxt,"@@"
        display "PADRAO@@8@@Bairro@@", a_rrw[2].lclbrrnom,"@@"
        display "PADRAO@@8@@Cidade@@", a_rrw[2].cidnom clipped, " - ", a_rrw[2].ufdcod,"@@"
       if ws.rmcacpdes is not null  then
           display "PADRAO@@8@@Acompanha remoção@@", ws.rmcacpdes,"@@"
       end if
    end if

    #------------------------------------------------
    # PARA ASSISTENCIA PASSAGEIROS - TAXI  (DESTINO)
    #------------------------------------------------
    if ws.atdsrvorg  =   2    or
       ws.atdsrvorg  =   3    then

        select atddmccidnom, atddmcufdcod,
               atddstcidnom, atddstufdcod,
               asimtvcod   , bagflg
          into ws.atddmccidnom,
               ws.atddmcufdcod,
               ws.atddstcidnom,
               ws.atddstufdcod,
               ws.asimtvcod   ,
               ws.bagflg
          from datmassistpassag
         where atdsrvnum = param.atdsrvnum   and
               atdsrvano = param.atdsrvano

        let ws.asimtvdes = "NAO CADASTRADO"

        select asimtvdes
          into ws.asimtvdes
          from datkasimtv
         where asimtvcod = ws.asimtvcod

        display  "PADRAO@@8@@Domicílio@@", ws.atddmccidnom clipped, " - ", ws.atddmcufdcod,"@@"
        display  "PADRAO@@8@@Ocorrência@@",a_rrw[1].cidnom clipped, " - ", a_rrw[1].ufdcod,"@@"
        display  "PADRAO@@8@@Destino@@",   ws.atddstcidnom clipped, " - ", ws.atddstufdcod,"@@"

        if (ws.atdsrvorg =  3 )  or
           (ws.atdsrvorg =  2    and
            ws.asitipcod = 10 )  then
        else
            display  "PADRAO@@8@@Local destino@@", a_rrw[2].lgdtxt,"@@"
            display  "PADRAO@@8@@Bairro@@", a_rrw[2].lclbrrnom,"@@"
            display  "PADRAO@@8@@Cidade@@", a_rrw[2].cidnom clipped, " - ",a_rrw[2].ufdcod,"@@"
        end if

        if ws.bagflg  =  "S"   then
            display "PADRAO@@8@@Bagagem@@SIM@@"
        else
            display "PADRAO@@8@@Bagagem@@NÃO@@"
        end if

        display "PADRAO@@8@@Motivo@@",ws.asimtvdes,"@@"

        #----------------------------------------------
        # IMPRIME INFORMACOES SOBRE OS PASSAGEIROS
        #----------------------------------------------
        display "PADRAO@@1@@B@@C@@0@@Informações sobre passageiros@@"

        declare c_cts00m014pas  cursor for
         select pasnom, pasidd
           from datmpassageiro
          where atdsrvnum = param.atdsrvnum  and
                atdsrvano = param.atdsrvano
        foreach c_cts00m014pas  into  ws.pasnom, ws.pasidd
            display "PADRAO@@1@@N@@L@@1@@",  ws.pasnom, " ", ws.pasidd, " anos de idade@@"
        end foreach

    end if

    ##### LAUDO #####
}

# OSF 20370 - O trecho acima foi inibido em funcao de existir uma nova
#             forma de impressao, que segue abaixo, entre # LAUDO INICIO #
#             e # LAUDO FIM #

    # LAUDO INICIO #

    #--------------------------------------------------------------
    # Busca informacoes do servico
    #--------------------------------------------------------------

    # Caso nao exista o registro, as variaveis devem permanecer nulas.
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
        
    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    let m_subbairro[2].lclbrrnom = a_rrw[2].lclbrrnom
    
    call cts06g10_monta_brr_subbrr(a_rrw[2].brrnom,
                                   a_rrw[2].lclbrrnom)
         returning a_rrw[2].lclbrrnom           

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

       # Caso nao exista o registro, as variaveis devem permanecer nulas.
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

       # Caso nao exista o registro, as variaveis devem permanecer nulas.
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

    # Caso nao exista o registro, as variaveis devem permanecer nulas.
    select srvtipabvdes
      into ws.srvtipabvdes
      from datksrvtip
     where atdsrvorg = ws.atdsrvorg

    let ws.asitipabvdes = "N/CADAST"

    # Caso nao exista o registro, as variaveis devem permanecer nulas.
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

    # Caso nao exista o registro, as variaveis devem permanecer nulas.
    if ws.vclcorcod   is not null    then
       select cpodes
         into ws.vclcordes
         from iddkdominio
        where cponom = "vclcorcod"    and
              cpocod = ws.vclcorcod
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
                             " as ", ws.atdhor,"@@"
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
    # Caso nao exista o registro, as variaveis devem permanecer nulas.
    if ws.socvclcod  is not null   then
       select atdvclsgl
         into ws.atdvclsgl
         from datkveiculo
        where datkveiculo.socvclcod  =  ws.socvclcod
    end if

    #-----------------------------------------------------------
    # Se codigo socorrista informado, ler cadastro de socorrista
    #-----------------------------------------------------------
    # Caso nao exista o registro, as variaveis devem permanecer nulas.
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
        else
            display  "PADRAO@@8@@Local destino@@", a_rrw[2].cidnom clipped, " - ",a_rrw[2].ufdcod,"@@"
        end if

    end if

    # LAUDO FIM #

    #----------------------------------------------
    #  Informações Adicionais
    #----------------------------------------------

    display "PADRAO@@1@@B@@C@@0@@Informações adicionais@@"

    # Caso nao exista o registro, as variaveis devem permanecer nulas.
    select dbsmsrvacr.incvlr
      into d_wdatc047.incvlr
      from dbsmsrvacr
     where dbsmsrvacr.atdsrvnum = param.atdsrvnum
       and dbsmsrvacr.atdsrvano = param.atdsrvano

    display "PADRAO@@8@@Valor inicial do serviço@@", d_wdatc047.incvlr using "###,###,##&.&&", "@@"

    #--> Pesquisa Grupos de problemas
    let ws.comando = "select datkpbmgrp.c24pbmgrpcod,",
                     "       datkpbmgrp.c24pbmgrpdes ",
                     "  from datkpbmgrp              ",
                     " where datkpbmgrp.atdsrvorg  = ", ws.atdsrvorg,
                     "   and datkpbmgrp.c24pbmgrpstt = 'A' ",
                     " order by 2"

    prepare sel_grupos from ws.comando

    declare c_grupos cursor for sel_grupos

    open c_grupos

    let ws.cont     = 0
    let ws.padrao   = ""

    foreach c_grupos
       into d_wdatc047.c24pbmgrpcod,
            d_wdatc047.c24pbmgrpdes

        let ws.padrao = ws.padrao clipped,
                        d_wdatc047.c24pbmgrpdes clipped,
                        "@@",
                        "0",
                        "@@",
                        d_wdatc047.c24pbmgrpcod clipped,
                        "@@"

        let ws.cont = (ws.cont + 1)

    end foreach

    # OSF 20370
    case ws.cont
       when 0    let ws.padrao = "PADRAO@@2@@c24pbmgrpcod@@Grupo do problema@@0@@0@@", ws.srvtipabvdes clipped, "@@1@@0@@"
       when 1    let ws.padrao = "PADRAO@@2@@c24pbmgrpcod@@Grupo do problema@@0@@0@@", ws.padrao clipped
       otherwise let ws.padrao = "PADRAO@@2@@c24pbmgrpcod@@Grupo do problema@@0@@0@@(Selecione uma opcao)@@1@@-1@@", ws.padrao clipped
    end case

    display ws.padrao clipped

    #--> Pesquisa Estados

    case ws.atdsrvorg
       when 13      let d_wdatc047.soctip = 3
       when 9       let d_wdatc047.soctip = 3
       when 8       let d_wdatc047.soctip = 2
       otherwise    let d_wdatc047.soctip = 1
    end case

    #--> Para RE não mostra a combo de estados
    if d_wdatc047.soctip <> 3 then

        if a_rrw[2].ufdcod is not null then
            let ws.ufdcod = a_rrw[2].ufdcod clipped
        else
            if a_rrw[1].ufdcod is not null then
                let ws.ufdcod = a_rrw[1].ufdcod clipped
            end if
        end if

        let ws.comando = "select glakest.ufdcod,",
                         "       glakest.ufdnom ",
                         "  from glakest        ",
                         " order by 1"

        prepare sel_estados from ws.comando

        declare c_estados cursor for sel_estados

        open c_estados

        # OSF 20370
        let ws.padrao = "PADRAO@@2@@ufdcod@@UF do destino@@0@@0@@" clipped

        foreach c_estados
           into d_wdatc047.ufdcod,
                d_wdatc047.ufdnom

            let ws.selecionado = "0"
            if d_wdatc047.ufdcod = ws.ufdcod then
                let ws.selecionado = "1"
            end if

            let ws.padrao = ws.padrao clipped,
                            d_wdatc047.ufdcod clipped,
                            " - ",
                            d_wdatc047.ufdnom clipped,
                            "@@",
                            ws.selecionado,
                            "@@",
                            d_wdatc047.ufdcod clipped,
                            "@@"
        end foreach

        display ws.padrao clipped
        display "TEXTO@@Informe o grupo do problema, a UF do destino e clique em continuar.@@"

    else

        display "HIDDEN@@<input type='hidden' name='ufdcod' value='XR'>@@"
        display "TEXTO@@Informe o grupo do problema e clique em continuar.@@"

    end if

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
