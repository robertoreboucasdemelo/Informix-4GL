#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR420                                                   #
# ANALISTA RESP..: CRISTIANE SILVA                                            #
# PSI/OSF........: 207209                                                     #
#                  EXTRACAO DE SERVICOS PAGOS - PORTO SEGURO RE               #
# ........................................................................... #
# DESENVOLVIMENTO: CRISTIANE SILVA                                            #
# LIBERACAO......: 09/02/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 17/08/2007 Klaus, Meta     PSI211915  Alteracao de sql para contemplar a ta-#
#                                       bela rgfkmrsapccls                    #
#-----------------------------------------------------------------------------#
# 02/04/2009 Carla Rampazzo  PSI 239097 Inclusao da Clausula 76 p/ Ramo 118   #
#-----------------------------------------------------------------------------#
# 18/03/2010 Beatriz Araujo     PSI219444 Buscar a descrição da clausula de   #
#                                         uma função do RE, e não acessar     #
#                                         direto a base deles                 #
#-----------------------------------------------------------------------------#

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define m_path    char(100),
           m_mes_int smallint

 main
    call fun_dba_abre_banco("CT24HS")

    call bdbsr420_busca_path()

    call bdbsr420_prepare()

    call cts40g03_exibe_info("I","BDBSR420")

    set isolation to dirty read

    call bdbsr420()

    call cts40g03_exibe_info("F","BDBSR420")
 end main


#------------------------------#
 function bdbsr420_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr420.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path = m_path clipped, "/BDBSR420.xls"

 end function


#---------------------------#
 function bdbsr420_prepare()
#---------------------------#
    define l_sql char(600)
    define l_data_inicio, l_data_fim date
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    # ---> OBTER A DATA E HORA DO BANCO
    call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual

     #---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
    if  month(l_data_atual) = 01 then
        let l_data_inicio = mdy(12,01,year(l_data_atual) - 1)
        #let l_data_fim    = l_data_inicio + 1 units day
        let l_data_fim    = mdy(12,31,year(l_data_atual) - 1)
    else
        let l_data_inicio = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
        #let l_data_fim    = l_data_inicio + 1 units day
        let l_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
    end if

    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(l_data_inicio)

    #Identificando os servicos
    let l_sql = " select c.atdsrvnum, ",
                       " c.atdsrvano, ",
                       " c.atdsrvorg, ",
                       " c.asitipcod, ",
                       " c.cornom, ",
                       " c.vcldes, ",
                       " c.vcllicnum, ",
                       " a.socopgnum, ",
                       " a.socfatpgtdat ",
                  " from dbsmopg a, dbsmopgitm b, datmservico c ",
                  " where a.socfatpgtdat between '", l_data_inicio, "' and '", l_data_fim, "'",
                   " and a.socopgsitcod = 7 ",
                   " and a.socopgnum = b.socopgnum ",
                   " and b.atdsrvnum = c.atdsrvnum ",
                   " and b.atdsrvano = c.atdsrvano ",
                   " and c.ciaempcod = 1 ",
                   " and a.soctip = 3 ",
                   " and c.atdsrvorg in (9,13) "
    prepare pbdbsr420001 from l_sql
    declare cbdbsr420001 cursor for pbdbsr420001

    #Identificando apolice
    let l_sql = " select succod, aplnumdig, itmnumdig, ramcod ",
                  " from datrservapol ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr420002 from l_sql
    declare cbdbsr420002 cursor for pbdbsr420002

    #Identificando segurado
    let l_sql = " select seg.segnom ",
                  " from gsakseg seg, abbmdoc doc ",
                 " where seg.segnumdig = doc.segnumdig ",
                 " and doc.aplnumdig = ? ",
                 " and doc.succod = ? "
    prepare pbdbsr420003 from l_sql
    declare cbdbsr420003 cursor for pbdbsr420003

    #Identificando assunto da ligacao
    let l_sql = " select c24astcod, ",
                       " c24solnom, ",
                       " c24soltip ",
                  " from datmligacao ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr420004 from l_sql
    declare cbdbsr420004 cursor for pbdbsr420004

    #Identificando assunto da ligacao
    let l_sql = " select c24astdes ",
                  " from datkassunto ",
                 " where c24astcod = ? "
    prepare pbdbsr420005 from l_sql
    declare cbdbsr420005 cursor for pbdbsr420005

    #Identificando tipo de servico
    let l_sql = " select srvtipdes ",
                  " from datksrvtip ",
                 " where atdsrvorg = ? "
    prepare pbdbsr420006 from l_sql
    declare cbdbsr420006 cursor for pbdbsr420006

    #Identificando tipo de assitencia
    let l_sql = " select asitipdes ",
                  " from datkasitip ",
                 " where asitipcod = ? "
    prepare pbdbsr420007 from l_sql
    declare cbdbsr420007 cursor for pbdbsr420007

    #Identificando o problema
    let l_sql = " select c24pbmdes ",
                  " from datrsrvpbm ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr420008 from l_sql
    declare cbdbsr420008 cursor for pbdbsr420008

    #Identificando data de acionamento
    let l_sql = " select acp.atdetpdat, ",
                       " acp.srrcoddig, ",
                       " acp.atdvclsgl ",
                  " from datmsrvacp acp ",
                 " where acp.atdsrvnum = ? ",
                   " and acp.atdsrvano = ? ",
                   " and acp.atdetpcod = 3 "
    prepare pbdbsr420009 from l_sql
    declare cbdbsr420009 cursor for pbdbsr420009

    #Identificando cidade e uf da ocorrencia
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                  " from datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 1 "
    prepare pbdbsr420010 from l_sql
    declare cbdbsr420010 cursor for pbdbsr420010

    #Identificando cidade e uf do destino
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                  " from datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 2 "
    prepare pbdbsr420011 from l_sql
    declare cbdbsr420011 cursor for pbdbsr420011

    #Identificando o prestador
    let l_sql = " select socor.pstcoddig, ",
                       " socor.nomrazsoc ",
                  " from dpaksocor socor, dbsmopg opg ",
                 " where socor.pstcoddig = opg.pstcoddig ",
                   " and opg.socopgnum = ? "
    prepare pbdbsr420012 from l_sql
    declare cbdbsr420012 cursor for pbdbsr420012

    #Identificando o nome do socorrista
    let l_sql = " select srrnom ",
                  " from datksrr ",
                 " where srrcoddig = ? "
    prepare pbdbsr420013 from l_sql
    declare cbdbsr420013 cursor for pbdbsr420013

    #Identificando valor total do servico
    let l_sql = " select socopgitmvlr ",
                  " from dbsmopgitm ",
                 " where socopgnum = ? ",
                   " and atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr420014 from l_sql
    declare cbdbsr420014 cursor for pbdbsr420014

    #Identificando custos - Louca Sanitaria
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm ",
                " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 9 "
    prepare pbdbsr420015 from l_sql
    declare cbdbsr420015 cursor for pbdbsr420015



    #Identificando custos - Fornecimento de Pecas
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm ",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 10 "
    prepare pbdbsr420016 from l_sql
    declare cbdbsr420016 cursor for pbdbsr420016

    #Identificando custos - Diversos RE
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm ",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 13 "
    prepare pbdbsr420017 from l_sql
    declare cbdbsr420017 cursor for pbdbsr420017

    #Identificando custos - Complemento Mao de Obra
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm ",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 21 "
    prepare pbdbsr420018 from l_sql
    declare cbdbsr420018 cursor for pbdbsr420018

    #Identificando custos - KM Excedente RE
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm ",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 11 "
    prepare pbdbsr420019 from l_sql
    declare cbdbsr420019 cursor for pbdbsr420019



    #Identificando custos - Pedagio RE
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm ",
                " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 12 "
    prepare pbdbsr420020 from l_sql
    declare cbdbsr420020 cursor for pbdbsr420020

    #Identificando cidade sede da ocorrência
    let l_sql = " select cidcod ",
                  " from glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
    prepare pbdbsr420021 from l_sql
    declare cbdbsr420021 cursor for pbdbsr420021

    let l_sql = " select cidsedcod ",
                  " from datrcidsed ",
                 " where cidcod = ? "
    prepare pbdbsr420022 from l_sql
    declare cbdbsr420022 cursor for pbdbsr420022

    let l_sql = " select cidcod, ",
                       " cidnom ",
                  " from glakcid ",
                 " where cidcod = ? ",
                   " and ufdcod = ?"
    prepare pbdbsr420023 from l_sql
    declare cbdbsr420023 cursor for pbdbsr420023

    #Identificando total pago
    let l_sql = " select sum(socopgitmcst) ",
                  " from dbsmopgcst ",
                 " where socopgnum = ? ",
                   " and socopgitmnum in (select socopgitmnum ",
                                          " from dbsmopgitm ",
                                         " where atdsrvnum = ? ",
                                           " and atdsrvano = ? ",
                                           " and socopgnum = ?)"
    prepare pbdbsr420024 from l_sql
    declare cbdbsr420024 cursor for pbdbsr420024

    #Identificando a placa do veiculo segurado
    let l_sql = " select vcllicnum ",
                  " from abbmveic ",
                 " where succod = ? ",
                   " and aplnumdig = ? ",
                   " and itmnumdig = ? "
    prepare pbdbsr420025 from l_sql
    declare cbdbsr420025 cursor for pbdbsr420025

    #Identificando o veículo segurado
    let l_sql = " select marca.vclmrcnom || veic.vclmdlsgl ",
                  " from agbkmarca marca, agbkveic veic, abbmveic abb ",
                 " where marca.vclmrccod = veic.vclmrccod ",
                   " and veic.vclcoddig = abb.vclcoddig ",
                   " and abb.aplnumdig = ? ",
                   " and abb.succod = ? "
    prepare pbdbsr420026 from l_sql
    declare cbdbsr420026 cursor for pbdbsr420026

    #Aqui
    let l_sql =  "  select sgrorg,         "
                   ,"         sgrnumdig,      "
                   ,"         rmemdlcod       "
                   ,"    from rsamseguro      "
                   ,"   where succod    = ?   "
                   ,"     and ramcod    = ?   "
                   ,"     and aplnumdig = ?   "

    prepare pbdbsr420027 from l_sql
    declare cbdbsr420027 cursor for pbdbsr420027

    let l_sql = " select prporg    , prpnumdig ",
            	      " from rsdmdocto ",
           	      " where sgrorg    = ? ",
             	      " and sgrnumdig = ? ",
             	      " and dctnumseq = (select max(dctnumseq) ",
                                	" from rsdmdocto ",
                               		" where sgrorg     = ? ",
                                 	" and sgrnumdig  = ? ",
                                 	" and prpstt in (19,66,88)) "
    prepare pbdbsr420032 from l_sql
    declare cbdbsr420032 cursor for pbdbsr420032


    let l_sql = " select clscod ",
                " from rsdmclaus ",
               	" where prporg     = ? ",
                " and prpnumdig  = ? ",
                " and lclnumseq  = 1 ",
                " and clsstt     = 'A' "
    prepare pbdbsr420033 from l_sql
    declare cbdbsr420033 cursor for pbdbsr420033

    ## 18/03/2010 PSI 219444 - Beatriz Araujo 
    ##let l_sql = ' select clsdes '
    ##           ,'   from rgfkclaus2 '
    ##           ,'  where ramcod    = ? '
    ##           ,'    and rmemdlcod = ? '
    ##           ,'    and clscod    = ? '
    ##           ,'  union '
    ##           ,' select clsdes '
    ##           ,'   from rgfkmrsapccls '
    ##           ,'  where ramcod    = ? '
    ##           ,'    and rmemdlcod = ? '
    ##           ,'    and clscod    = ? '
    ##
    ##prepare pbdbsr420034 from l_sql
    ##declare cbdbsr420034 cursor for pbdbsr420034


    #Identificando a natureza
    let l_sql = " select ntz.socntzcod, ",
                       " ntz.socntzdes ",
                  " from datksocntz ntz, datmsrvre srv ",
                 " where srv.socntzcod = ntz.socntzcod ",
                   " and srv.atdsrvnum = ? ",
                   " and srv.atdsrvano = ? "
    prepare pbdbsr420028 from l_sql
    declare cbdbsr420028 cursor for pbdbsr420028

    #Identificando o grupo de natureza (linha basica ou linha branca)
    let l_sql = " select grp.socntzgrpdes ",
                  " from datksocntzgrp grp, datksocntz ntz ",
                 " where grp.socntzgrpcod = ntz.socntzgrpcod ",
                   " and ntz.socntzcod = ? "
    prepare pbdbsr420029 from l_sql
    declare cbdbsr420029 cursor for pbdbsr420029

    #Identificando ramo do seguro
    let l_sql = " select rmemdlcod ",
                  " from rsamseguro ",
                 " where succod = ? ",
                   " and ramcod = ? ",
                   " and aplnumdig = ? "
    prepare pbdbsr420030 from l_sql
    declare cbdbsr420030 cursor for pbdbsr420030

    #Identificando sigla do veiculo (alternativa)
    let l_sql = " select veic.atdvclsgl ",
                  " from datkveiculo veic, datmsrvacp acp ",
                 " where veic.socvclcod = acp.socvclcod ",
                   " and acp.atdsrvnum = ? ",
                   " and acp.atdsrvano = ? ",
                   " and acp.atdetpcod = 3 "
    prepare pbdbsr420031 from l_sql
    declare cbdbsr420031 cursor for pbdbsr420031

    #Identificando as clausulas da apolice
    let l_sql = " select unique claus.clscod, aack.clsdes ",
                  " from abbmclaus claus, aackcls aack ",
                 " where claus.clscod = aack.clscod ",
                   " and claus.succod = ? ",
                   " and claus.aplnumdig = ? ",
                   " and claus.itmnumdig = ? ",
                   " and claus.clscod in ('033','33R','034','035','035R') "
    prepare pbdbsr420035 from l_sql
    declare cbdbsr420035 cursor for pbdbsr420035


 end function

#-------------------#
 function bdbsr420()
#-------------------#

    define lr_dados record
            atdsrvnum      like datmservico.atdsrvnum,
            atdsrvano      like datmservico.atdsrvano,
            atdsrvorg      like datmservico.atdsrvorg,
            srvtipdes      like datksrvtip.srvtipdes,
            asitipcod      like datmservico.asitipcod,
            succod         like datrservapol.succod,
            aplnumdig      like datrservapol.aplnumdig,
            segnom         like gsakseg.segnom,
            cornom         like gcakcorr.cornom,
            vcldes         like datmservico.vcldes,
            vcllicnum      like datmservico.vcllicnum,
            c24astcod      like datmligacao.c24astcod,
            c24astdes      like datkassunto.c24astdes,
            cpodes         like iddkdominio.cpodes,
            asitipdes      like datkasitip.asitipdes,
            c24pbmdes      like datrsrvpbm.c24pbmdes,
            atdetpdat      like datmsrvacp.atdetpdat,
            atdvclsgl      like datmsrvacp.atdvclsgl,
            srrcoddig      like datmsrvacp.srrcoddig,
            cidcod         like glakcid.cidcod,
            cidnomsed      like glakcid.cidnom,
            cidnom         like datmlcl.cidnom,
            ufdcod         like datmlcl.ufdcod,
            cidcoddes      like datmlcl.cidnom,
            ufdcodes       like datmlcl.ufdcod,
            pstcoddig      like datmsrvacp.pstcoddig,
            nomrazsoc      like dpaksocor.nomrazsoc,
            srrnom         like datksrr.srrnom,
            socopgnum      like dbsmopgitm.socopgnum,
            socfatpgtdat   like dbsmopg.socfatpgtdat,
            socopgitmvlr   like dbsmopgitm.socopgitmvlr,
            soccstcod1     like dbsmopgcst.soccstcod,
            socopgitmcst1  like dbsmopgcst.socopgitmcst,
            cstqtd1        like dbsmopgcst.cstqtd,
            soccstcod2     like dbsmopgcst.soccstcod,
            socopgitmcst2  like dbsmopgcst.socopgitmcst,
            cstqtd2        like dbsmopgcst.cstqtd,
            soccstcod3     like dbsmopgcst.soccstcod,
            socopgitmcst3  like dbsmopgcst.socopgitmcst,
            cstqtd3        like dbsmopgcst.cstqtd,
            soccstcod4     like dbsmopgcst.soccstcod,
            socopgitmcst4  like dbsmopgcst.socopgitmcst,
            cstqtd4        like dbsmopgcst.cstqtd,
            soccstcod5     like dbsmopgcst.soccstcod,
            socopgitmcst5  like dbsmopgcst.socopgitmcst,
            cstqtd5        like dbsmopgcst.cstqtd,
            soccstcod6     like dbsmopgcst.soccstcod,
            socopgitmcst6  like dbsmopgcst.socopgitmcst,
            cstqtd6        like dbsmopgcst.cstqtd,
            soma           decimal(15,2),
            clscod         char(03),
            clsdes         char(80),
            itmnumdig      like datrservapol.itmnumdig,
            aplnumdig2     like datrligapol.aplnumdig,
            itmnumdig2     like datrligapol.itmnumdig,
            edsnumref2     like datrligapol.edsnumref,
            succod2        like datrligapol.succod,
            ramcod2        like datrservapol.ramcod,
            emsdat         date,
            viginc         date,
            vigfnl         date,
            segcod         integer,
            corsus         char(06),
            resultado      smallint,
            mensagem       char(50),
            situacao       char(10),
            doc_handle     integer,
            c24solnom      like datmligacao.c24solnom,
            c24soltip      like datmligacao.c24soltip,
            vcldesatend    like datmservico.vcldes,
            vcllicnumatend like datmservico.vcllicnum,
            cidsedcod      like datrcidsed.cidsedcod,
            socntzcod      like datksocntz.socntzcod,
            socntzdes      like datksocntz.socntzdes,
            socntzgrpdes   like datksocntzgrp.socntzgrpdes,
            ramcod         like datrservapol.ramcod,
            rmemdlcod      like rsamseguro.rmemdlcod,
            sgrorg	   like rsamseguro.sgrorg      ,
            sgrnumdig      like rsamseguro.sgrnumdig,
            prporg         like rsdmdocto.prporg     ,
            prpnumdig      like rsdmdocto.prpnumdig   ,
            rsdclscod      like rsdmclaus.clscod,
            datclscod      char(03)
    end record


    define l_ind, l_exitfor smallint
    define ws record
    	clscod         char(03),
        clsdes         char(80)
    end record

    define l_count smallint

    define la_clausula array[20] of record
            clscod like aackcls.clscod,
            clsdes like aackcls.clsdes
    end record

    define lr_km       record
            kmlimite smallint,
            qtde     integer
    end record

    define l_length smallint

    initialize la_clausula,
               l_ind,
               ws.clscod,
               ws.clsdes to null

    initialize lr_dados.* to null

    start report bdbsr420_relatorio to m_path

    let l_count = 0
    open cbdbsr420001
    foreach cbdbsr420001 into lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.atdsrvorg,
                              lr_dados.asitipcod,
                              lr_dados.cornom,
                              lr_dados.vcldesatend,
                              lr_dados.vcllicnumatend,
                              lr_dados.socopgnum,
                              lr_dados.socfatpgtdat

            open cbdbsr420002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420002 into lr_dados.succod, lr_dados.aplnumdig,
                                    lr_dados.itmnumdig, lr_dados.ramcod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr420002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr420002

            open cbdbsr420003 using lr_dados.aplnumdig, lr_dados.succod
            whenever error continue
            fetch cbdbsr420003 into lr_dados.segnom
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420003

            open cbdbsr420004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420004 into lr_dados.c24astcod, lr_dados.c24solnom, lr_dados.c24soltip
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420004

            #Trata nome do solicitante, retirando possiveis pipes, que prejudicam a validacao
            # dos valores do relatório

             let l_length = length(lr_dados.c24solnom)
  	     for l_ind = 1 to l_length
     		if lr_dados.c24solnom[l_ind] = "|" then
        		let lr_dados.c24solnom[l_ind] = " "
     		end if
 	     end for


            open cbdbsr420005 using lr_dados.c24astcod
            whenever error continue
            fetch cbdbsr420005 into lr_dados.c24astdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420005

            open cbdbsr420006 using lr_dados.atdsrvorg
            whenever error continue
            fetch cbdbsr420006 into lr_dados.srvtipdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420006

            open cbdbsr420007 using lr_dados.asitipcod
            whenever error continue
            fetch cbdbsr420007 into lr_dados.asitipdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420007

            open cbdbsr420008 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420008 into lr_dados.c24pbmdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420008

            open cbdbsr420009 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420009 into lr_dados.atdetpdat, lr_dados.srrcoddig, lr_dados.atdvclsgl
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420009

            if  lr_dados.atdvclsgl is null or lr_dados.atdvclsgl = " " then
                open cbdbsr420031 using lr_dados.atdsrvnum, lr_dados.atdsrvano
                whenever error continue
                fetch cbdbsr420031 into lr_dados.atdvclsgl
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode <> notfound then
                      display "Erro SELECT cbdbsr420031 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                      exit program(1)
                   end if
                end if
                close cbdbsr420031
            end if

            open cbdbsr420010 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420010 into lr_dados.cidnom, lr_dados.ufdcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420010

            open cbdbsr420011 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420011 into lr_dados.cidcoddes, lr_dados.ufdcodes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420011

            open cbdbsr420012 using lr_dados.socopgnum
            whenever error continue
            fetch cbdbsr420012 into lr_dados.pstcoddig, lr_dados.nomrazsoc
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420012

            if  lr_dados.srrcoddig is null or lr_dados.srrcoddig = 0 then
                let lr_dados.srrnom = " "
            else
                open cbdbsr420013 using lr_dados.srrcoddig
                whenever error continue
                fetch cbdbsr420013 into lr_dados.srrnom
                whenever error stop
                if  sqlca.sqlcode <> 0 then
                    if  sqlca.sqlcode <> notfound then
                        display "Erro SELECT cbdbsr420013 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                        exit program(1)
                    end if
                end if
                close cbdbsr420013
            end if

            open cbdbsr420014 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420014 into lr_dados.socopgitmvlr
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420014 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420014

            open cbdbsr420015 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420015 into lr_dados.soccstcod1,
                                    lr_dados.socopgitmcst1,
                                    lr_dados.cstqtd1
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420015 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420015

            open cbdbsr420016 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420016 into lr_dados.soccstcod2,
                                    lr_dados.socopgitmcst2,
                                    lr_dados.cstqtd2
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420016

            open cbdbsr420017 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420017 into lr_dados.soccstcod3,
                                    lr_dados.socopgitmcst3,
                                    lr_dados.cstqtd3
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420017 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420017

            open cbdbsr420018 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420018 into lr_dados.soccstcod4,
                                    lr_dados.socopgitmcst4,
                                    lr_dados.cstqtd4
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420018 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420018

            open cbdbsr420019 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420019 into lr_dados.soccstcod5,
                                    lr_dados.socopgitmcst5,
                                    lr_dados.cstqtd5
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420019 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420019

            open cbdbsr420020 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420020 into lr_dados.soccstcod6,
                                    lr_dados.socopgitmcst6,
                                    lr_dados.cstqtd6
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420020 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420020

            open cbdbsr420021 using lr_dados.cidnom, lr_dados.ufdcod
            whenever error continue
            fetch cbdbsr420021 into lr_dados.cidcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420021

            open cbdbsr420022 using lr_dados.cidcod
            whenever error continue
            fetch cbdbsr420022 into lr_dados.cidsedcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420022

            open cbdbsr420023 using lr_dados.cidsedcod, lr_dados.ufdcod
            whenever error continue
            fetch cbdbsr420023 into lr_dados.cidsedcod, lr_dados.cidnomsed
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420023

            open cbdbsr420024 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano, lr_dados.socopgnum
            whenever error continue
            fetch cbdbsr420024 into lr_dados.soma
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr420024 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr420024


            let lr_dados.soma = lr_dados.soma + lr_dados.socopgitmvlr


            open cbdbsr420025 using lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            whenever error continue
            fetch cbdbsr420025 into lr_dados.vcllicnum
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr420025 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr420025

            open cbdbsr420026 using lr_dados.aplnumdig, lr_dados.succod
            whenever error continue
            fetch cbdbsr420026 into lr_dados.vcldes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr420026 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr420026

            open cbdbsr420028 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr420028 into lr_dados.socntzcod, lr_dados.socntzdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr420028 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr420028

            open cbdbsr420029 using lr_dados.socntzcod
            whenever error continue
            fetch cbdbsr420029 into lr_dados.socntzgrpdes
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr420029 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr420029

            open cbdbsr420030 using lr_dados.succod, lr_dados.ramcod, lr_dados.aplnumdig
            whenever error continue
            fetch cbdbsr420030 into lr_dados.rmemdlcod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr420030 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr420030



            #CLAUSULAS

            if lr_dados.ramcod = 531 then
            	open cbdbsr420035 using lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            	fetch cbdbsr420035 into lr_dados.clscod, lr_dados.clsdes
            	close cbdbsr420035
          	output to report bdbsr420_relatorio(lr_dados.atdsrvnum,
                                                    lr_dados.atdsrvano,
                                                    lr_dados.atdsrvorg,
                                                    lr_dados.srvtipdes,
                                                    lr_dados.asitipcod,
                                                    lr_dados.succod,
                                                    lr_dados.aplnumdig,
                                                    lr_dados.segnom,
                                                    lr_dados.c24soltip,
                                                    lr_dados.c24solnom,
                                                    lr_dados.cornom,
                                                    lr_dados.vcldes,
                                                    lr_dados.vcllicnum,
                                                    lr_dados.vcldesatend,
                                                    lr_dados.vcllicnumatend,
                                                    lr_dados.c24astcod,
                                                    lr_dados.c24astdes,
                                                    lr_dados.cpodes,
                                                    lr_dados.asitipdes,
                                                    lr_dados.c24pbmdes,
                                                    lr_dados.atdetpdat,
                                                    lr_dados.atdvclsgl,
                                                    lr_dados.srrcoddig,
                                                    lr_dados.cidsedcod,
                                                    lr_dados.cidnomsed,
                                                    lr_dados.cidnom,
                                                    lr_dados.ufdcod,
                                                    lr_dados.cidcoddes,
                                                    lr_dados.ufdcodes,
                                                    lr_dados.pstcoddig,
                                                    lr_dados.nomrazsoc,
                                                    lr_dados.srrnom,
                                                    lr_dados.socopgnum,
                                                    lr_dados.socfatpgtdat,
                                                    lr_dados.socopgitmvlr,
                                                    lr_dados.socopgitmcst1,
                                                    lr_dados.cstqtd1,
                                                    lr_dados.socopgitmcst2,
                                                    lr_dados.cstqtd2,
                                                    lr_dados.socopgitmcst3,
                                                    lr_dados.cstqtd3,
                                                    lr_dados.socopgitmcst4,
                                                    lr_dados.cstqtd4,
                                                    lr_dados.socopgitmcst5,
                                                    lr_dados.cstqtd5,
                                                    lr_dados.socopgitmcst6,
                                                    lr_dados.cstqtd6,
                                                    lr_dados.soma,
                                                    lr_dados.clscod,
                                                    lr_dados.clsdes,
                                                    lr_dados.socntzcod,
                                                    lr_dados.socntzdes,
                                                    lr_dados.socntzgrpdes,
                                                    lr_dados.ramcod,
                                                    lr_dados.rmemdlcod,
                                                    l_ind)

                initialize lr_dados.* to null

            	initialize lr_dados.*, la_clausula to null
            else
            	if lr_dados.ramcod is null or lr_dados.ramcod = 0 then
            		let ws.clscod = null
            		let ws.clsdes  = null

            		output to report bdbsr420_relatorio(lr_dados.atdsrvnum,
                        	                            lr_dados.atdsrvano,
                                	                    lr_dados.atdsrvorg,
                                        	            lr_dados.srvtipdes,
	                                                    lr_dados.asitipcod,
        	                                            lr_dados.succod,
                	                                    lr_dados.aplnumdig,
                        	                            lr_dados.segnom,
                                	                    lr_dados.c24soltip,
                                        	            lr_dados.c24solnom,
                                                	    lr_dados.cornom,
	                                                    lr_dados.vcldes,
        	                                            lr_dados.vcllicnum,
                	                                    lr_dados.vcldesatend,
                        	                            lr_dados.vcllicnumatend,
                                	                    lr_dados.c24astcod,
                                        	            lr_dados.c24astdes,
                                                	    lr_dados.cpodes,
	                                                    lr_dados.asitipdes,
        	                                            lr_dados.c24pbmdes,
                	                                    lr_dados.atdetpdat,
                        	                            lr_dados.atdvclsgl,
                                	                    lr_dados.srrcoddig,
                                        	            lr_dados.cidsedcod,
                                                	    lr_dados.cidnomsed,
	                                                    lr_dados.cidnom,
        	                                            lr_dados.ufdcod,
                	                                    lr_dados.cidcoddes,
                        	                            lr_dados.ufdcodes,
                                	                    lr_dados.pstcoddig,
                                        	            lr_dados.nomrazsoc,
                                                	    lr_dados.srrnom,
	                                                    lr_dados.socopgnum,
        	                                            lr_dados.socfatpgtdat,
                	                                    lr_dados.socopgitmvlr,
                        	                            lr_dados.socopgitmcst1,
                                	                    lr_dados.cstqtd1,
                                        	            lr_dados.socopgitmcst2,
                                                	    lr_dados.cstqtd2,
	                                                    lr_dados.socopgitmcst3,
        	                                            lr_dados.cstqtd3,
                	                                    lr_dados.socopgitmcst4,
                        	                            lr_dados.cstqtd4,
                                	                    lr_dados.socopgitmcst5,
                                        	            lr_dados.cstqtd5,
                                                	    lr_dados.socopgitmcst6,
	                                                    lr_dados.cstqtd6,
        	                                            lr_dados.soma,
                	                                    lr_dados.clscod,
                        	                            lr_dados.clsdes,
                                	                    lr_dados.socntzcod,
                                        	            lr_dados.socntzdes,
                                                	    lr_dados.socntzgrpdes,
	                                                    lr_dados.ramcod,
        	                                            lr_dados.rmemdlcod,
                	                                    l_ind)
	                initialize lr_dados.* to null

        	    	initialize lr_dados.*, la_clausula to null

            	else

            		open cbdbsr420027 using lr_dados.succod, lr_dados.ramcod, lr_dados.aplnumdig
            		fetch cbdbsr420027 into lr_dados.sgrorg, lr_dados.sgrnumdig, lr_dados.rmemdlcod
            		close cbdbsr420027


		    	open cbdbsr420032 using lr_dados.sgrorg, lr_dados.sgrnumdig, lr_dados.sgrorg, lr_dados.sgrnumdig
            		fetch cbdbsr420032 into lr_dados.prporg, lr_dados.prpnumdig
            		close cbdbsr420032


        	    	if lr_dados.prporg is not null    and 
                           lr_dados.prporg <> 0           and 
                           lr_dados.prpnumdig is not null and
                           lr_dados.prporg <> 0           then

                           let ws.clscod = 0

                           open cbdbsr420033 using lr_dados.prporg
                                                 , lr_dados.prpnumdig
                           foreach cbdbsr420033 into lr_dados.rsdclscod

                              let lr_dados.datclscod = lr_dados.rsdclscod

                              case
                                 when lr_dados.ramcod =  11 or
                                      lr_dados.ramcod = 111

                                    if (lr_dados.datclscod = 13    or 
                                        lr_dados.datclscod = "13R"    ) then
                                        let ws.clscod = lr_dados.datclscod
                                    end if

                                 when lr_dados.ramcod =   44 or
                                      lr_dados.ramcod =  118

                                    if (lr_dados.datclscod = 20    or 
                                        lr_dados.datclscod = "20R"   ) or
                                        lr_dados.datclscod = 21        or
                                        lr_dados.datclscod = 22        or
                                        lr_dados.datclscod = 23        or
                                       (lr_dados.datclscod = 24    or
					lr_dados.datclscod = "24R"   ) or
                                        lr_dados.datclscod = 30        or
                                       (lr_dados.datclscod = 31    or
					lr_dados.datclscod = "31R"   ) or
                                       (lr_dados.datclscod = 32    or 
					lr_dados.datclscod = "32R"   ) or
                                       (lr_dados.datclscod = 36    or
					lr_dados.datclscod = "36R"   ) or
                                        lr_dados.datclscod = "55"      or
					lr_dados.datclscod = "56"      or
                                        lr_dados.datclscod = "56R"     or
                                        lr_dados.datclscod = "56C"     or
                                        lr_dados.datclscod = "57"      or
                                        lr_dados.datclscod = "57R"     or
                                        lr_dados.datclscod = 76        then 

                                       if lr_dados.datclscod > ws.clscod then
                                          let ws.clscod = lr_dados.datclscod
                                       end if
                                    end if

                   			when 	lr_dados.ramcod =   45 or
                        			lr_dados.ramcod =  114
                        			if (lr_dados.datclscod    =   08  or lr_dados.datclscod = "08R") or
                           			   (lr_dados.datclscod    =   10  or lr_dados.datclscod = "10R") or
                           			   (lr_dados.datclscod    =   11  or lr_dados.datclscod = "11R") or
                           			   (lr_dados.datclscod    =   12  or lr_dados.datclscod = "12R") or
                           			   (lr_dados.datclscod    =   13  or lr_dados.datclscod = "13R") or
                            			    lr_dados.datclscod    =   30  or
                           			   (lr_dados.datclscod    =   31  or lr_dados.datclscod = "31R") or
                           			   (lr_dados.datclscod    =   32  or lr_dados.datclscod = "32R") or
                           			   (lr_dados.datclscod    =   40  or lr_dados.datclscod = "40R") or   #  PSI-230.057 Inicio
                                                    lr_dados.datclscod    = "55"  or lr_dados.datclscod = "56"   or
                                                    lr_dados.datclscod    = "56R" or lr_dados.datclscod = "56C"  or
                                                    lr_dados.datclscod    = "57"  or lr_dados.datclscod = "57R"  then #  PSI-230.057 Fim
                           			    #inclusao da cls 40/40R-a pedido Neia-07/05/07
                           			    if lr_dados.datclscod > ws.clscod  then
	                              		       let ws.clscod = lr_dados.datclscod
         	                  		    end if
                	        		end if
                   			when 	lr_dados.ramcod =   46 or
                        			lr_dados.ramcod =  746
                        			if lr_dados.datclscod = 30      or
                          			(lr_dados.datclscod = 31      or lr_dados.datclscod = "31R") or
                          			(lr_dados.datclscod = 32      or lr_dados.datclscod = "32R") then
        	                   			if lr_dados.datclscod > ws.clscod  then
                	              				let ws.clscod = lr_dados.datclscod
                        	   			end if
                        			end if
                   			when 	lr_dados.ramcod =   47
                      				if (lr_dados.datclscod = 10 or lr_dados.datclscod = "10R") or
                         			(lr_dados.datclscod = 13 or lr_dados.datclscod = "13R") then
                         				if lr_dados.datclscod > ws.clscod  then
	                            				let ws.clscod = lr_dados.datclscod
        	                 			end if
                	      			end if
                		end case
                		
###################### 18/03/2010 PSI 219444 - Beatriz Araujo
                                display "lr_dados.ramcod,   : ",lr_dados.ramcod   
                                display "lr_dados.rmemdlcod : ",lr_dados.rmemdlcod
                                display "lr_dados.datclscod : ",lr_dados.datclscod       
                                
                                
                               call cts17m11_descricaoclaure(lr_dados.ramcod,
                                                             lr_dados.rmemdlcod,
                                                             lr_dados.datclscod)
                                     returning  ws.clsdes
                                     
                                display "ws.clsdes          : ",ws.clsdes  
                                display "----------------------------------------------------------"
                                ##open cbdbsr420034 using lr_dados.ramcod, lr_dados.rmemdlcod, ws.clscod
				##                       ,lr_dados.ramcod, lr_dados.rmemdlcod, ws.clscod
            			##fetch cbdbsr420034 into ws.clsdes
            			##close cbdbsr420034
######################## Fim do PSI

	             	end foreach
             		close cbdbsr420033

             		if ws.clscod = 0  then
                		initialize ws.clscod to null
             		end if

             		let lr_dados.clscod = lr_dados.datclscod
             		let lr_dados.clsdes = ws.clsdes

             		output to report bdbsr420_relatorio(lr_dados.atdsrvnum,
                        	                            lr_dados.atdsrvano,
                                	                    lr_dados.atdsrvorg,
                                        	            lr_dados.srvtipdes,
	                                                    lr_dados.asitipcod,
        	                                            lr_dados.succod,
                	                                    lr_dados.aplnumdig,
                        	                            lr_dados.segnom,
                                	                    lr_dados.c24soltip,
                                        	            lr_dados.c24solnom,
                                                	    lr_dados.cornom,
	                                                    lr_dados.vcldes,
        	                                            lr_dados.vcllicnum,
                	                                    lr_dados.vcldesatend,
                        	                            lr_dados.vcllicnumatend,
                                	                    lr_dados.c24astcod,
                                        	            lr_dados.c24astdes,
                                                	    lr_dados.cpodes,
	                                                    lr_dados.asitipdes,
        	                                            lr_dados.c24pbmdes,
                	                                    lr_dados.atdetpdat,
                        	                            lr_dados.atdvclsgl,
                                	                    lr_dados.srrcoddig,
                                        	            lr_dados.cidsedcod,
                                                	    lr_dados.cidnomsed,
	                                                    lr_dados.cidnom,
        	                                            lr_dados.ufdcod,
                	                                    lr_dados.cidcoddes,
                        	                            lr_dados.ufdcodes,
                                	                    lr_dados.pstcoddig,
                                        	            lr_dados.nomrazsoc,
                                                	    lr_dados.srrnom,
	                                                    lr_dados.socopgnum,
        	                                            lr_dados.socfatpgtdat,
                	                                    lr_dados.socopgitmvlr,
                        	                            lr_dados.socopgitmcst1,
                                	                    lr_dados.cstqtd1,
                                        	            lr_dados.socopgitmcst2,
                                                	    lr_dados.cstqtd2,
	                                                    lr_dados.socopgitmcst3,
        	                                            lr_dados.cstqtd3,
                	                                    lr_dados.socopgitmcst4,
                        	                            lr_dados.cstqtd4,
                                	                    lr_dados.socopgitmcst5,
                                        	            lr_dados.cstqtd5,
                                                	    lr_dados.socopgitmcst6,
	                                                    lr_dados.cstqtd6,
        	                                            lr_dados.soma,
                	                                    lr_dados.clscod,
                        	                            lr_dados.clsdes,
                                	                    lr_dados.socntzcod,
                                        	            lr_dados.socntzdes,
                                                	    lr_dados.socntzgrpdes,
	                                                    lr_dados.ramcod,
        	                                            lr_dados.rmemdlcod,
                	                                    l_ind)
	                initialize lr_dados.* to null

        	    	initialize lr_dados.*, la_clausula to null
		end if
          end if
	end if
    end foreach
    close cbdbsr420001

    finish report bdbsr420_relatorio

    call bdbsr420_envia_email()

 end function


#-------------------------------#
 function bdbsr420_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_mes_extenso char(010),
          l_erro_envio  integer

   case m_mes_int
      when 01 let l_mes_extenso = 'Janeiro'
      when 02 let l_mes_extenso = 'Fevereiro'
      when 03 let l_mes_extenso = 'Marco'
      when 04 let l_mes_extenso = 'Abril'
      when 05 let l_mes_extenso = 'Maio'
      when 06 let l_mes_extenso = 'Junho'
      when 07 let l_mes_extenso = 'Julho'
      when 08 let l_mes_extenso = 'Agosto'
      when 09 let l_mes_extenso = 'Setembro'
      when 10 let l_mes_extenso = 'Outubro'
      when 11 let l_mes_extenso = 'Novembro'
      when 12 let l_mes_extenso = 'Dezembro'
   end case

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relacao de Pagamentos / Composicao de Preco Porto Seguro RE" clipped,
                      " do mes de ", l_mes_extenso

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path

   run l_comando

   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR420", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - BDBSR420"
       end if
   end if

end function


#---------------------------------------#
 report bdbsr420_relatorio(lr_parametro, l_print_dados)
#---------------------------------------#

   define lr_parametro record
           atdsrvnum      like datmservico.atdsrvnum,
           atdsrvano      like datmservico.atdsrvano,
           atdsrvorg      like datmservico.atdsrvorg,
           srvtipdes      like datksrvtip.srvtipdes,
           asitipcod      like datmservico.asitipcod,
           succod         like datrservapol.succod,
           aplnumdig      like datrservapol.aplnumdig,
           segnom         like gsakseg.segnom,
           c24soltip      like datmligacao.c24soltip,
           c24solnom      like datmligacao.c24solnom,
           cornom         like gcakcorr.cornom,
           vcldes         like datmservico.vcldes,
           vcllicnum      like datkazlapl.vcllicnum,
           vcldesatend    like datmservico.vcldes,
           vcllicnumatend like datmservico.vcllicnum,
           c24astcod      like datmligacao.c24astcod,
           c24astdes      like datkassunto.c24astdes,
           cpodes         like iddkdominio.cpodes,
           asitipdes      like datkasitip.asitipdes,
           c24pbmdes      like datrsrvpbm.c24pbmdes,
           atdetpdat      like datmsrvacp.atdetpdat,
           atdvclsgl      like datmsrvacp.atdvclsgl,
           srrcoddig      like datmsrvacp.srrcoddig,
           cidsedcod      like datrcidsed.cidsedcod,
           cidnomsed      like glakcid.cidnom,
           cidnom         like datmlcl.cidnom,
           ufdcod         like datmlcl.ufdcod,
           cidcoddes      like datmlcl.cidnom,
           ufdcodes       like datmlcl.ufdcod,
           pstcoddig      like datmsrvacp.pstcoddig,
           nomrazsoc      like dpaksocor.nomrazsoc,
           srrnom         like datksrr.srrnom,
           socopgnum      like dbsmopgitm.socopgnum,
           socfatpgtdat   like dbsmopg.socfatpgtdat,
           socopgitmvlr   decimal(15,2),
           socopgitmcst1  decimal(15,2),
           cstqtd1        smallint,
           socopgitmcst2  decimal(15,2),
           cstqtd2        smallint,
           socopgitmcst3  decimal(15,2),
           cstqtd3        smallint,
           socopgitmcst4  decimal(15,2),
           cstqtd4        smallint,
           socopgitmcst5  decimal(15,2),
           cstqtd5        smallint,
           socopgitmcst6  decimal(15,2),
           cstqtd6        smallint,
           soma           decimal(15,2),
           clscod         char(03),
           clsdes         char(80),
           socntzcod      like datksocntz.socntzcod,
           socntzdes      like datksocntz.socntzdes,
           socntzgrpdes   like datksocntzgrp.socntzgrpdes,
           ramcod         like datrservapol.ramcod,
           rmemdlcod      like rsamseguro.rmemdlcod
   end record

   define l_print_dados   smallint

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
           print "RAMO",                                ASCII(09),
                 "MODALIDADE",                          ASCII(09),
                 "APOLICE",                             ASCII(09),
                 "CORRETOR",                            ASCII(09),
                 "SEGURADO",                            ASCII(09),
                 "TIPO PESSOA LIGACAO",                 ASCII(09),
                 "NOME PESSOA LIGACAO",                 ASCII(09),
                 "ASSUNTO",                             ASCII(09),
                 "ORIGEM SERVICO",                      ASCII(09),
                 "SERVIÇO",                             ASCII(09),
                 "ANO SERVIÇO",                         ASCII(09),
                 "TIPO SERVIÇO",                        ASCII(09),
                 "TIPO ASSISTENCIA",                    ASCII(09),
                 "PROBLEMA APRESENTADO",                ASCII(09),
                 "DATA DE ACIONAMENTO",                 ASCII(09),
                 "CODIGO CIDADE SEDE",                  ASCII(09),
                 "CIDADE SEDE DA OCORRENCIA",           ASCII(09),
                 "CIDADE DA OCORRENCIA",                ASCII(09),
                 "UF DA OCORRENCIA",                    ASCII(09),
                 "CODIGO PRESTADOR",                    ASCII(09),
                 "NOME PRESTADOR",                      ASCII(09),
                 "SIGLA VIATURA",                       ASCII(09),
                 "NUMERO QRA",                          ASCII(09),
                 "NOME QRA",                            ASCII(09),
                 "NUMERO OP",                           ASCII(09),
                 "DATA DE PAGAMENTO",                   ASCII(09),
                 "VALOR DE SAIDA",			ASCII(09),
                 "VALOR LOUCA SANITARIA",               ASCII(09),
                 "QTDE LOUCA SANITARIA",                ASCII(09),
                 "VALOR FORNECIMENTO PECAS",            ASCII(09),
                 "QTDE FORNECIMENTO PECAS",             ASCII(09),
                 "VALOR DIVERSOS RE",                   ASCII(09),
                 "QTDE DIVERSOS RE",                    ASCII(09),
                 "VALOR COMPLEMENTO MAO DE OBRA",       ASCII(09),
                 "QTDE COMPLEMENTO MAO DE OBRA",        ASCII(09),
                 "VALOR KM EXCEDENTE RE",               ASCII(09),
                 "QTDE KM EXCEDENTE RE",                ASCII(09),
                 "VALOR PEDAGIO RE",                    ASCII(09),
                 "QTDE PEDAGIO RE",                     ASCII(09),
                 "VALOR TOTAL PAGO",                    ASCII(09),
                 "CODIGO NATUREZA",                     ASCII(09),
                 "DESCR NATUREZA",                      ASCII(09),
                 "BASICA OU BRANCA",                    ASCII(09),
                 "CLAUSULA",                            ASCII(09),
                 "DESCRICAO",                           ASCII(09);

           skip 1 line

       on every row
           print lr_parametro.ramcod,           ASCII(09);

           if lr_parametro.rmemdlcod is null then
           	let lr_parametro.rmemdlcod = 0
           end if
           print lr_parametro.rmemdlcod,        ASCII(09);


	   if lr_parametro.aplnumdig is null or lr_parametro.aplnumdig = 0 then
               print "APOLICE NAO CADASTRADA",  ASCII(09);
           else
               print lr_parametro.aplnumdig,    ASCII(09);
           end if

           if  lr_parametro.cornom is null or lr_parametro.cornom = " " then
               print "CORRETOR NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.cornom,       ASCII(09);
           end if

           if  lr_parametro.segnom is null or lr_parametro.segnom = " " then
               print "SEGURADO NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.segnom,       ASCII(09);
           end if

               if  lr_parametro.c24soltip = "S" then
                   print "SEGURADO",            ASCII(09);
               else
                   if  lr_parametro.c24soltip = "C" then
                       print "CORRETOR",        ASCII(09);
                   else
                       print "OUTROS",          ASCII(09);
                   end if
               end if

           if  lr_parametro.c24solnom is null or lr_parametro.c24solnom = " " then
               print " ",                       ASCII(09);
           else
               print lr_parametro.c24solnom,    ASCII(09);
           end if

           print lr_parametro.c24astdes,        ASCII(09),
                 lr_parametro.atdsrvorg,        ASCII(09),
                 lr_parametro.atdsrvnum,        ASCII(09),
                 lr_parametro.atdsrvano,        ASCII(09),
                 lr_parametro.srvtipdes,        ASCII(09),
                 lr_parametro.asitipdes,        ASCII(09),
                 lr_parametro.c24pbmdes,        ASCII(09),
                 lr_parametro.atdetpdat using "yyyy-mm-dd",        ASCII(09),
                 lr_parametro.cidsedcod,        ASCII(09),
                 lr_parametro.cidnomsed,        ASCII(09),
                 lr_parametro.cidnom,           ASCII(09),
                 lr_parametro.ufdcod,           ASCII(09),
                 lr_parametro.pstcoddig,        ASCII(09),
                 lr_parametro.nomrazsoc,        ASCII(09),
                 lr_parametro.atdvclsgl,        ASCII(09),
                 lr_parametro.srrcoddig,        ASCII(09),
                 lr_parametro.srrnom,           ASCII(09),
                 lr_parametro.socopgnum,        ASCII(09),
                 lr_parametro.socfatpgtdat using "yyyy-mm-dd",     ASCII(09),
                 lr_parametro.socopgitmvlr  using "---------&,&&",	ASCII(09),
                 lr_parametro.socopgitmcst1 using "---------&,&&",    ASCII(09),
                 lr_parametro.cstqtd1,          ASCII(09),
                 lr_parametro.socopgitmcst2  using "---------&,&&",    ASCII(09),
                 lr_parametro.cstqtd2,          ASCII(09),
                 lr_parametro.socopgitmcst3  using "---------&,&&",    ASCII(09),
                 lr_parametro.cstqtd3,          ASCII(09),
                 lr_parametro.socopgitmcst4  using "---------&,&&",    ASCII(09),
                 lr_parametro.cstqtd4,          ASCII(09),
                 lr_parametro.socopgitmcst5  using "---------&,&&",    ASCII(09),
                 lr_parametro.cstqtd5,          ASCII(09),
                 lr_parametro.socopgitmcst6  using "---------&,&&",     ASCII(09),
                 lr_parametro.cstqtd6,          ASCII(09);

           if  lr_parametro.soma is null or lr_parametro.soma = 0 then
               print lr_parametro.socopgitmvlr  using "---------&,&&", ASCII(09);
           else
               print lr_parametro.soma  using "---------&,&&",         ASCII(09);
           end if

           print lr_parametro.socntzcod,        ASCII(09),
                 lr_parametro.socntzdes,        ASCII(09),
                 lr_parametro.socntzgrpdes,     ASCII(09);

	   if lr_parametro.clscod is null or lr_parametro.clscod = 0 then
	   	let lr_parametro.clscod = " "
	   	print lr_parametro.clscod, 	ASCII(09);
	   else
	   	print lr_parametro.clscod, 	ASCII(09);
	   end if

           if lr_parametro.clsdes is null or lr_parametro.clsdes = " " then
           	let lr_parametro.clsdes = "CLAUSULA NAO CADASTRADA"
                print lr_parametro.clsdes,           ASCII(09);
           else
           	print lr_parametro.clsdes,           ASCII(09);
           end if

           skip 1 line

 end report
