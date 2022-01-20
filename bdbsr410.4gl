#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR410                                                   #
# ANALISTA RESP..: CRISTIANE SILVA                                            #
# PSI/OSF........: 207209                                                     #
#                  EXTRACAO DE SERVICOS PAGOS AUTO - PORTO SEGURO SEGUROS     #
# ........................................................................... #
# DESENVOLVIMENTO: CRISTIANE SILVA                                            #
# LIBERACAO......: 03/07/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

 database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define m_path    char(100),
           m_mes_int smallint

 main
    call fun_dba_abre_banco("CT24HS")

    call bdbsr410_busca_path()

    call bdbsr410_prepare()

    call cts40g03_exibe_info("I","BDBSR410")

    set isolation to dirty read

    call bdbsr410()

    call cts40g03_exibe_info("F","BDBSR410")
 end main


#------------------------------#
 function bdbsr410_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr410.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path = m_path clipped, "/BDBSR410.txt"

 end function


#---------------------------#
 function bdbsr410_prepare()
#---------------------------#
    define l_sql char(600)
    define l_data_inicio, l_data_fim date
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    # ---> OBTER A DATA E HORA DO BANCO
    call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual

    let l_data_fim = today
    # ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
    if  month(l_data_atual) = 01 then
        let l_data_inicio = mdy(12,01,year(l_data_atual) - 1)
        let l_data_fim    = mdy(12,31,year(l_data_atual) - 1)

    else
        let l_data_inicio = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
        let l_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
    end if

    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(l_data_inicio)

    #Identificando os servicos
set isolation to dirty read

    let l_sql = " select c.atdsrvnum, ",
                       " c.atdsrvano, ",
                       " c.atdsrvorg, ",
                       " c.asitipcod, ",
                       " c.cornom, ",
                       " c.vcldes, ",
                       " c.vcllicnum, ",
                       " a.socopgnum, ",
                       " a.socfatpgtdat, ",
                       " b.socopgitmvlr ",
                  " from dbsmopg a, dbsmopgitm b, datmservico c ",
                 " where a.socfatpgtdat between '", l_data_inicio, "' and '", l_data_fim, "'",
                   " and a.socopgsitcod = 7 ",
                   " and a.socopgnum = b.socopgnum ",
                   " and b.atdsrvnum = c.atdsrvnum ",
                   " and b.atdsrvano = c.atdsrvano ",
                   " and c.ciaempcod = 1 ",
                   " and a.soctip = 1 ",
                   " and c.atdsrvorg not in (8,9,13)"
    prepare pbdbsr410001 from l_sql
    declare cbdbsr410001 cursor for pbdbsr410001

    #Identificando apolice
    let l_sql = " select succod, aplnumdig, itmnumdig ",
                  " from datrservapol ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr410002 from l_sql
    declare cbdbsr410002 cursor for pbdbsr410002

    #Identificando segurado
    let l_sql = " select seg.segnom ",
                  " from  gsakseg seg,  abbmdoc doc ",
                 " where seg.segnumdig = doc.segnumdig ",
                 " and doc.aplnumdig = ? ",
                 " and doc.succod = ? "
    prepare pbdbsr410003 from l_sql
    declare cbdbsr410003 cursor for pbdbsr410003

    #Identificando assunto da ligacao
    let l_sql = " select c24astcod, ",
                       " c24solnom, ",
                       " c24soltip ",
                  " from  datmligacao ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr410004 from l_sql
    declare cbdbsr410004 cursor for pbdbsr410004

    #Identificando tipo de servico
    let l_sql = " select srvtipdes ",
                  " from  datksrvtip ",
                 " where atdsrvorg = ? "
    prepare pbdbsr410005 from l_sql
    declare cbdbsr410005 cursor for pbdbsr410005

    #Identificando tipo de assitencia
    let l_sql = " select asitipdes ",
                  " from  datkasitip ",
                 " where asitipcod = ? "
    prepare pbdbsr410006 from l_sql
    declare cbdbsr410006 cursor for pbdbsr410006

    #Identificando o problema
    let l_sql = " select c24pbmdes ",
                  " from  datrsrvpbm ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr410007 from l_sql
    declare cbdbsr410007 cursor for pbdbsr410007

    #Identificando data de acionamento
    let l_sql = " select acp.atdetpdat, ",
                       " acp.srrcoddig, ",
                       " acp.atdvclsgl, ",
                       " acp.socvclcod ",
                  " from  datmsrvacp acp ",
                 " where acp.atdsrvnum = ? ",
                   " and acp.atdsrvano = ? ",
                   " and acp.atdetpcod = 4 "
    prepare pbdbsr410008 from l_sql
    declare cbdbsr410008 cursor for pbdbsr410008

    #Identificando cidade e uf da ocorrencia
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                  " from  datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 1 "
    prepare pbdbsr410009 from l_sql
    declare cbdbsr410009 cursor for pbdbsr410009


    #Identificando cidade e uf do destino
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                  " from  datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 2 "
    prepare pbdbsr410010 from l_sql
    declare cbdbsr410010 cursor for pbdbsr410010

    #Identificando o prestador
    let l_sql = " select socor.pstcoddig, ",
                       " socor.nomrazsoc ",
                  " from  dpaksocor socor,  dbsmopg opg ",
                 " where socor.pstcoddig = opg.pstcoddig ",
                   " and opg.socopgnum = ? "
    prepare pbdbsr410011 from l_sql
    declare cbdbsr410011 cursor for pbdbsr410011

    #Identificando o nome do socorrista
    let l_sql = " select srrnom ",
                  " from datksrr ",
                 " where srrcoddig = ? "
    prepare pbdbsr410012 from l_sql
    declare cbdbsr410012 cursor for pbdbsr410012


    #Identificando custos - Km Excedente
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 3 "
    prepare pbdbsr410016 from l_sql
    declare cbdbsr410016 cursor for pbdbsr410016

    #Identificando custos - Hora Parada
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 4 "
    prepare pbdbsr410017 from l_sql
    declare cbdbsr410017 cursor for pbdbsr410017

    #Identificando custos - Hora Trabalhada
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 5 "
    prepare pbdbsr410018 from l_sql
    declare cbdbsr410018 cursor for pbdbsr410018

    #Identificando custos - Pedagio
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 18 "
    prepare pbdbsr410019 from l_sql
    declare cbdbsr410019 cursor for pbdbsr410019

    #Identificando cidade sede da ocorrência
    let l_sql = " select cidcod ",
                  " from  glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
    prepare pbdbsr410020 from l_sql
    declare cbdbsr410020 cursor for pbdbsr410020

    let l_sql = " select cidsedcod ",
                  " from  datrcidsed ",
                 " where cidcod = ? "
    prepare pbdbsr410021 from l_sql
    declare cbdbsr410021 cursor for pbdbsr410021

    let l_sql = " select cidcod, ",
                       " cidnom ",
                  " from  glakcid ",
                 " where cidcod = ? ",
                   " and ufdcod = ?"
    prepare pbdbsr410022 from l_sql
    declare cbdbsr410022 cursor for pbdbsr410022

    #Identificando custos - Adicionais
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 6 "
    prepare pbdbsr410023 from l_sql
    declare cbdbsr410023 cursor for pbdbsr410023

    #Identificando total pago
    let l_sql = " select sum(socopgitmcst) ",
                  " from  dbsmopgcst ",
                 " where socopgnum = ? ",
                   " and socopgitmnum in (select socopgitmnum ",
                                          " from  dbsmopgitm ",
                                         " where atdsrvnum = ? ",
                                           " and atdsrvano = ? ",
                                           " and socopgnum = ?)"
    prepare pbdbsr410024 from l_sql
    declare cbdbsr410024 cursor for pbdbsr410024

    #Identificando a placa do veiculo segurado
    let l_sql = " select vcllicnum ",
                  " from  datkazlapl ",
                 " where succod = ? ",
                   " and ramcod = 531",
                   " and aplnumdig = ? ",
                   " and itmnumdig = ? "
    prepare pbdbsr410025 from l_sql
    declare cbdbsr410025 cursor for pbdbsr410025

    #Identificando a sigla do veiculo acionado
    let l_sql = " select atdvclsgl from datkveiculo ",
    		" where socvclcod = ? "
    prepare pbdbsr410026 from l_sql
    declare cbdbsr410026 cursor for pbdbsr410026

    #Identificando custos - Hospedagem
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 22 "
    prepare pbdbsr410027 from l_sql
    declare cbdbsr410027 cursor for pbdbsr410027

    #Identificando as cláusulas da apólice
    let l_sql = "  select clscod ",
      		" from  abbmclaus ",
     		" where succod    = ? ",
     		" and aplnumdig = ? ",
     		" and itmnumdig = ? ",
     		" and clscod in ('034','34A','035', '35A', '35R', '033', '33R') "
    prepare pbdbsr410028 from l_sql
    declare cbdbsr410028 cursor for pbdbsr410028

    let l_sql = " select clsdes ",
    		" from  aackcls ",
    		" where clscod = ? "
    prepare pbdbsr410029 from l_sql
    declare cbdbsr410029 cursor for pbdbsr410029

    #Identificando o veiculo segurado
    let l_sql = " select abb.vcllicnum, mrc.vclmrcnom, tip.vcltipnom, veic.vclmdlnom ",
		" from 	 abbmveic abb,  agbkveic veic, ",
		"  agbkmarca mrc,  agbktip tip ",
		" where	abb.vclcoddig = veic.vclcoddig ",
		" and 	veic.vclmrccod = mrc.vclmrccod ",
		" and 	veic.vclmrccod = tip.vclmrccod ",
		" and	veic.vcltipcod = tip.vcltipcod ",
		" and 	abb.aplnumdig = ? ",
		" and 	abb.succod = ? "
    prepare pbdbsr410030 from l_sql
    declare cbdbsr410030 cursor for pbdbsr410030

	#Identificando o prestador
    	let l_sql = " select socor.pstcoddig, ",
                       	" socor.nomrazsoc ",
        	        " from  dpaksocor socor,  datmsrvacp acp ",
                 	" where socor.pstcoddig = acp.pstcoddig ",
                   	" and acp.atdsrvnum = ? ",
                   	" and acp.atdsrvano = ? ",
                   	" and acp.atdetpcod = 4 "
    	prepare pbdbsr410031 from l_sql
    	declare cbdbsr410031 cursor for pbdbsr410031


    #Identificando custos - Descontos
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 7 "
    prepare pbdbsr410032 from l_sql
    declare cbdbsr410032 cursor for pbdbsr410032

    #Identificando custos - RA no Prazo
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 19 "
    prepare pbdbsr410033 from l_sql
    declare cbdbsr410033 cursor for pbdbsr410033


    #Identificando custos - RA Fora do Prazo
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                   " from  dbsmopgcst cst,  dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = 20 "
    prepare pbdbsr410034 from l_sql
    declare cbdbsr410034 cursor for pbdbsr410034


 end function

#-------------------#
 function bdbsr410()
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
            vcllicnum      like abbmveic.vcllicnum,
            c24astcod      like datmligacao.c24astcod,
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
            soccstcod18     like dbsmopgcst.soccstcod,
            socopgitmcst18  like dbsmopgcst.socopgitmcst,
            cstqtd18        like dbsmopgcst.cstqtd,
            soccstcod6     like dbsmopgcst.soccstcod,
            socopgitmcst6  like dbsmopgcst.socopgitmcst,
            cstqtd6        like dbsmopgcst.cstqtd,
            soccstcod22     like dbsmopgcst.soccstcod,
            socopgitmcst22  like dbsmopgcst.socopgitmcst,
            cstqtd22        like dbsmopgcst.cstqtd,
            soccstcod7     like dbsmopgcst.soccstcod,
            socopgitmcst7  like dbsmopgcst.socopgitmcst,
            cstqtd7        like dbsmopgcst.cstqtd,
            soccstcod19     like dbsmopgcst.soccstcod,
            socopgitmcst19  like dbsmopgcst.socopgitmcst,
            cstqtd19        like dbsmopgcst.cstqtd,
            soccstcod20     like dbsmopgcst.soccstcod,
            socopgitmcst20  like dbsmopgcst.socopgitmcst,
            cstqtd20        like dbsmopgcst.cstqtd,
            soma           decimal(15,2),
            clausula       char(03),
            clausulades    char(50),
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
            socvclcod	   like datmsrvacp.socvclcod,
            socopgitmnum   like dbsmopgitm.socopgitmnum,
            vclmrcnom 	   like agbkmarca.vclmrcnom,
            vcltipnom 	   like agbktip.vcltipnom,
            vclmdlnom	   like agbkveic.vclmdlnom
    end record

    define l_doc_handle     integer
    define l_qtd_end, l_ind smallint
    define l_aux_char       char(100)
    define l_clscod         like aackcls.clscod
    define l_grlchv         like datkgeral.grlchv

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
               l_aux_char,
               l_ind,
               l_qtd_end,
               l_grlchv,
               l_doc_handle to null

    initialize lr_dados.* to null

    start report bdbsr410_relatorio to m_path

    open cbdbsr410001
    foreach cbdbsr410001 into lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.atdsrvorg,
                              lr_dados.asitipcod,
                              lr_dados.cornom,
                              lr_dados.vcldesatend,
                              lr_dados.vcllicnumatend,
                              lr_dados.socopgnum,
                              lr_dados.socfatpgtdat,
                              lr_dados.socopgitmvlr

            open cbdbsr410002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410002 into lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr410002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr410002

            open cbdbsr410003 using lr_dados.aplnumdig, lr_dados.succod
            whenever error continue
            fetch cbdbsr410003 into lr_dados.segnom
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410003

            open cbdbsr410004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410004 into lr_dados.c24astcod, lr_dados.c24solnom, lr_dados.c24soltip
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410004

            #Trata nome do solicitante, retirando possiveis pipes, que prejudicam a validacao
            # dos valores do relatório

             let l_length = length(lr_dados.c24solnom)
  	     for l_ind = 1 to l_length
     		if lr_dados.c24solnom[l_ind] = "|" then
        		let lr_dados.c24solnom[l_ind] = " "
     		end if
 	     end for

            open cbdbsr410005 using lr_dados.atdsrvorg
            whenever error continue
            fetch cbdbsr410005 into lr_dados.srvtipdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410005

            open cbdbsr410006 using lr_dados.asitipcod
            whenever error continue
            fetch cbdbsr410006 into lr_dados.asitipdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410006

            open cbdbsr410007 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410007 into lr_dados.c24pbmdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410007

            open cbdbsr410008 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410008 into lr_dados.atdetpdat, lr_dados.srrcoddig, lr_dados.atdvclsgl, lr_dados.socvclcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410008

	    if lr_dados.atdvclsgl is null or lr_dados.atdvclsgl = 0 then
	    	if lr_dados.socvclcod is not null and lr_dados.socvclcod <> 0 then
	    		open cbdbsr410026 using lr_dados.socvclcod
	    		whenever error continue
	    			fetch cbdbsr410026 into lr_dados.atdvclsgl
	    		whenever error stop
	    		if sqlca.sqlcode <> 0 then
	    			if sqlca.sqlcode <> notfound then
	    				display "Erro SELECT cbdbsr410026 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
	    				exit program(1)
	    			end if
	    		end if
	    		close cbdbsr410026
	    	end if
	    end if

            open cbdbsr410009 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410009 into lr_dados.cidnom, lr_dados.ufdcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410009

            open cbdbsr410010 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410010 into lr_dados.cidcoddes, lr_dados.ufdcodes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410010

            open cbdbsr410011 using lr_dados.socopgnum
            whenever error continue
            fetch cbdbsr410011 into lr_dados.pstcoddig, lr_dados.nomrazsoc
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410011

            if  lr_dados.srrcoddig is null or lr_dados.srrcoddig = 0 then
                let lr_dados.srrnom = " "
            else
                open cbdbsr410012 using lr_dados.srrcoddig
                whenever error continue
                fetch cbdbsr410012 into lr_dados.srrnom
                whenever error stop
                if  sqlca.sqlcode <> 0 then
                    if  sqlca.sqlcode <> notfound then
                        display "Erro SELECT cbdbsr410012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                        exit program(1)
                    end if
                end if
                close cbdbsr410012
            end if


            open cbdbsr410016 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410016 into lr_dados.soccstcod3,
                                    lr_dados.socopgitmcst3,
                                    lr_dados.cstqtd3
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410016

	    open cbdbsr410017 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410017 into lr_dados.soccstcod4,
                                    lr_dados.socopgitmcst4,
                                    lr_dados.cstqtd4
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410017 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410017



            open cbdbsr410018 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410018 into lr_dados.soccstcod5,
                                    lr_dados.socopgitmcst5,
                                    lr_dados.cstqtd5
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410018 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410018




            open cbdbsr410019 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410019 into lr_dados.soccstcod18,
                                    lr_dados.socopgitmcst18,
                                    lr_dados.cstqtd18
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410019 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410019




            open cbdbsr410020 using lr_dados.cidnom, lr_dados.ufdcod
            whenever error continue
            fetch cbdbsr410020 into lr_dados.cidcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410020 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410020

            open cbdbsr410021 using lr_dados.cidcod
            whenever error continue
            fetch cbdbsr410021 into lr_dados.cidsedcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410021

            open cbdbsr410022 using lr_dados.cidsedcod, lr_dados.ufdcod
            whenever error continue
            fetch cbdbsr410022 into lr_dados.cidsedcod, lr_dados.cidnomsed
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410022

            open cbdbsr410023 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410023 into lr_dados.soccstcod6,
                                    lr_dados.socopgitmcst6,
                                    lr_dados.cstqtd6
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410023


            open cbdbsr410024 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano, lr_dados.socopgnum
            whenever error continue
            fetch cbdbsr410024 into lr_dados.soma
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410024 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410024

            open cbdbsr410025 using lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            whenever error continue
            fetch cbdbsr410025 into lr_dados.vcllicnum
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr410025 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr410025

            open cbdbsr410027 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410027 into lr_dados.soccstcod22,
                                    lr_dados.socopgitmcst22,
                                    lr_dados.cstqtd22
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410027

            open cbdbsr410032 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410032 into lr_dados.soccstcod7,
                                    lr_dados.socopgitmcst7,
                                    lr_dados.cstqtd7
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410032

	    open cbdbsr410033 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410033 into lr_dados.soccstcod19,
                                    lr_dados.socopgitmcst19,
                                    lr_dados.cstqtd19
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410033

            open cbdbsr410034 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr410034 into lr_dados.soccstcod20,
                                    lr_dados.socopgitmcst20,
                                    lr_dados.cstqtd20
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr410023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr410034


            let lr_dados.soma = lr_dados.soma + lr_dados.socopgitmvlr


            open cbdbsr410028 using lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            fetch cbdbsr410028 into lr_dados.clausula
	    close cbdbsr410028

	    if lr_dados.clausula is not null then
	    	open cbdbsr410029 using lr_dados.clausula
	    	fetch cbdbsr410029 into lr_dados.clausulades
	    	close cbdbsr410029
	    end if


	    open cbdbsr410030 using  lr_dados.aplnumdig, lr_dados.succod
            fetch cbdbsr410030 into lr_dados.vcllicnum, lr_dados.vclmrcnom, lr_dados.vcltipnom, lr_dados.vclmdlnom
	    close cbdbsr410030

	    open cbdbsr410031 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            fetch cbdbsr410031 into lr_dados.pstcoddig, lr_dados.nomrazsoc
	    close cbdbsr410031

            		output to report bdbsr410_relatorio(lr_dados.atdsrvnum,
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
                                                lr_dados.vclmrcnom,
                                                lr_dados.vcltipnom,
                                                lr_dados.vclmdlnom,
                                                lr_dados.vcllicnum,
                                                lr_dados.vcldesatend,
                                                lr_dados.vcllicnumatend,
                                                lr_dados.c24astcod,
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
                                                lr_dados.socopgitmcst3,
                                                lr_dados.cstqtd3,
                                                lr_dados.socopgitmcst4,
                                                lr_dados.cstqtd4,
                                                lr_dados.socopgitmcst5,
                                                lr_dados.cstqtd5,
                                                lr_dados.socopgitmcst18,
                                                lr_dados.cstqtd18,
                                                lr_dados.socopgitmcst6,
                                                lr_dados.cstqtd6,
                                                lr_dados.socopgitmcst22,
                                                lr_dados.cstqtd22,
                                                lr_dados.socopgitmcst7,
                                                lr_dados.cstqtd7,
                                                lr_dados.socopgitmcst19,
                                                lr_dados.cstqtd19,
                                                lr_dados.socopgitmcst20,
                                                lr_dados.cstqtd20,
                                                lr_dados.soma,
                                                lr_dados.clausula,
                                                lr_dados.clausulades)



        initialize lr_dados.* to null
    end foreach
    close cbdbsr410001

    finish report bdbsr410_relatorio

    call bdbsr410_envia_email()

 end function


#-------------------------------#
 function bdbsr410_envia_email()
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
   let l_assunto    = "Relatorio de Servicos Auto Pagos em ", l_mes_extenso clipped, " - Porto Seguro Seguros"

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path

   run l_comando

   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR410", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - BDBSR410"
       end if
   end if

end function


#---------------------------------------#
 report bdbsr410_relatorio(lr_parametro)
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
           vclmrcnom 	   like agbkmarca.vclmrcnom,
           vcltipnom 	   like agbktip.vcltipnom,
           vclmdlnom	   like agbkveic.vclmdlnom,
           vcllicnum	   like abbmveic.vcllicnum,
           vcldesatend    like datmservico.vcldes,
           vcllicnumatend like datmservico.vcllicnum,
           c24astcod      like datmligacao.c24astcod,
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
           socopgitmvlr   like dbsmopgitm.socopgitmvlr,
           socopgitmcst3  decimal(15,2),
           cstqtd3        smallint,
           socopgitmcst4  decimal(15,2),
           cstqtd4        smallint,
           socopgitmcst5  decimal(15,2),
           cstqtd5        smallint,
           socopgitmcst18  decimal(15,2),
           cstqtd18        smallint,
           socopgitmcst6  decimal(15,2),
           cstqtd6        smallint,
           socopgitmcst22  decimal(15,2),
           cstqtd22        smallint,
           socopgitmcst7  decimal(15,2),
           cstqtd7        smallint,
           socopgitmcst19  decimal(15,2),
           cstqtd19        smallint,
           socopgitmcst20  decimal(15,2),
           cstqtd20        smallint,
           soma           decimal(15,2),
           clausula       char(03),
           clausulades    char(50)
   end record

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
           print "SUCURSAL",                             ASCII(09),
                 "APOLICE",                              ASCII(09),
                 "SEGURADO",                             ASCII(09),
                 "TIPO PESSOA LIGACAO",                  ASCII(09),
                 "NOME PESSOA LIGACAO",                  ASCII(09),
                 "CORRETOR",                             ASCII(09),
                 "VEICULO SEGURADO",                     ASCII(09),
                 "PLACA VEICULO SEGURADO",               ASCII(09),
                 "VEICULO ATENDIDO",                     ASCII(09),
                 "PLACA VEICULO ATENDIDO",               ASCII(09),
                 "ASSUNTO",                              ASCII(09),
                 "ORIGEM SERVICO",                       ASCII(09),
                 "SERVICO",                              ASCII(09),
                 "ANO SERVICO",                          ASCII(09),
                 "TIPO SERVICO",                         ASCII(09),
                 "TIPO ASSISTENCIA",                     ASCII(09),
                 "PROBLEMA APRESENTADO",                 ASCII(09),
                 "DATA DE ACIONAMENTO",                  ASCII(09),
                 "CODIGO CIDADE SEDE",                   ASCII(09),
                 "CIDADE SEDE DA OCORRENCIA",            ASCII(09),
                 "CIDADE DA OCORRENCIA",                 ASCII(09),
                 "UF DA OCORRENCIA",                     ASCII(09),
                 "CIDADE DE DESTINO",                    ASCII(09),
                 "UF DE DESTINO",                        ASCII(09),
                 "CODIGO PRESTADOR",                     ASCII(09),
                 "NOME PRESTADOR",                       ASCII(09),
                 "SIGLA VIATURA",                        ASCII(09),
                 "NUMERO QRA",                           ASCII(09),
                 "NOME QRA",                             ASCII(09),
                 "NUMERO DA OP",                         ASCII(09),
                 "DATA DE PAGAMENTO",                    ASCII(09),
                 "VALOR SAIDA",		                 ASCII(09),
                 "VALOR KM EXCEDENTE",                   ASCII(09),
                 "QUANTIDADE CUSTO KM EXCEDENTE",        ASCII(09),
                 "VALOR CUSTO HORA PARADA",              ASCII(09),
                 "QUANTIDADE CUSTO HORA PARADA",         ASCII(09),
                 "VALOR CUSTO HORA TRABALHADA",          ASCII(09),
                 "QUANTIDADE CUSTO HORA TRABALHADA",     ASCII(09),
                 "VALOR CUSTO PEDAGIO",                  ASCII(09),
                 "QUANTIDADE CUSTO PEDAGIO",             ASCII(09),
                 "VALOR CUSTO ADICIONAL",                ASCII(09),
                 "QUANTIDADE CUSTO ADICIONAL",           ASCII(09),
                  "VALOR CUSTO PASSAGEM AREA/HOSPEDAGEM", 		ASCII(09),
                 "QUANTIDADE CUSTO PASSAGEM AREA/HOSPEDAGEM",           ASCII(09),
                 "VALOR DESCONTO",			 ASCII(09),
                 "QUANTIDADE DESCONTO",			 ASCII(09),
                 "RELATORIO RA NO PRAZO",		 ASCII(09),
                 "QUANTIDADE RA NO PRAZO",		 ASCII(09),
                 "RELATORIO RA FORA PRAZO",		 ASCII(09),
                 "QUANTIDADE RA FORA PRAZO",		 ASCII(09),
                 "VALOR TOTAL PAGO",                     ASCII(09),
                 "CLAUSULA",                             ASCII(09),
                 "DESCRICAO",                            ASCII(09);

                 skip 1 line

       on every row
           if  lr_parametro.succod is null or lr_parametro.succod = 0 then
               print "SUCURSAL NAO CADASTRADA", ASCII(09);
           else
               print lr_parametro.succod,       ASCII(09);
           end if

           if  lr_parametro.aplnumdig is null or lr_parametro.aplnumdig = 0 then
               print "APOLICE NAO CADASTRADA",  ASCII(09);
           else
               print lr_parametro.aplnumdig,    ASCII(09);
           end if

           if  lr_parametro.segnom is null or lr_parametro.segnom = " " then
               print "SEGURADO NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.segnom,       ASCII(09);
           end if

           if  lr_parametro.c24soltip = "S" then
               print "SEGURADO",                ASCII(09);
           else
               if  lr_parametro.c24soltip = "C" then
                   print "CORRETOR",            ASCII(09);
               else
                   print "OUTROS",              ASCII(09);
               end if
           end if

           print lr_parametro.c24solnom,    ASCII(09);


           if  lr_parametro.cornom is null or lr_parametro.cornom = " " then
               print "CORRETOR NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.cornom,       ASCII(09);
           end if



           print lr_parametro.vclmrcnom, lr_parametro.vcltipnom, lr_parametro.vclmdlnom,  ASCII(09),
                 lr_parametro.vcllicnum,        ASCII(09),
                 lr_parametro.vcldesatend,      ASCII(09),
                 lr_parametro.vcllicnumatend,   ASCII(09),
                 lr_parametro.c24astcod,        ASCII(09),
                 lr_parametro.atdsrvorg,        ASCII(09),
                 lr_parametro.atdsrvnum,        ASCII(09),
                 lr_parametro.atdsrvano,        ASCII(09),
                 lr_parametro.srvtipdes,        ASCII(09),
                 lr_parametro.asitipdes,        ASCII(09),
                 lr_parametro.c24pbmdes,        ASCII(09),
                 lr_parametro.atdetpdat,        ASCII(09),
                 lr_parametro.cidsedcod,        ASCII(09),
                 lr_parametro.cidnomsed,        ASCII(09),
                 lr_parametro.cidnom,           ASCII(09),
                 lr_parametro.ufdcod,           ASCII(09),
                 lr_parametro.cidcoddes,        ASCII(09),
                 lr_parametro.ufdcodes,         ASCII(09),
                 lr_parametro.pstcoddig,        ASCII(09),
                 lr_parametro.nomrazsoc,        ASCII(09),
                 lr_parametro.atdvclsgl,        ASCII(09),
                 lr_parametro.srrcoddig,        ASCII(09),
                 lr_parametro.srrnom,           ASCII(09),
                 lr_parametro.socopgnum,        ASCII(09),
                 lr_parametro.socfatpgtdat,     ASCII(09);


                 if lr_parametro.socopgitmvlr is null or lr_parametro.socopgitmvlr = 0 then
                 	let lr_parametro.socopgitmvlr = 0.00
                 end if
                 print lr_parametro.socopgitmvlr, ASCII(09);

                 if lr_parametro.socopgitmcst3 is null or lr_parametro.socopgitmcst3 = 0 then
                 	let lr_parametro.socopgitmcst3 = 0.00
                 end if
                 print lr_parametro.socopgitmcst3, ASCII(09);

                 if lr_parametro.cstqtd3 is null or lr_parametro.cstqtd3 = 0 then
                 	let lr_parametro.cstqtd3 = 0
                 end if
                 print lr_parametro.cstqtd3, ASCII(09);

                 if lr_parametro.socopgitmcst4 is null or lr_parametro.socopgitmcst4 = 0 then
                 	let lr_parametro.socopgitmcst4 = 0.00
                 end if
                 print lr_parametro.socopgitmcst4, ASCII(09);

                 if lr_parametro.cstqtd4 is null or lr_parametro.cstqtd4 = 0 then
                 	let lr_parametro.cstqtd4 = 0
                 end if
                 print lr_parametro.cstqtd4, ASCII(09);

                 if lr_parametro.socopgitmcst5 is null or lr_parametro.socopgitmcst5 = 0 then
                 	let lr_parametro.socopgitmcst5 = 0.00
                 end if
                 print lr_parametro.socopgitmcst5, ASCII(09);

                 if lr_parametro.cstqtd5 is null or lr_parametro.cstqtd5 = 0 then
                 	let lr_parametro.cstqtd5 = 0
                 end if
                 print lr_parametro.cstqtd5, ASCII(09);

                 if lr_parametro.socopgitmcst18 is null  or lr_parametro.socopgitmcst18 = 0 then
                 	let lr_parametro.socopgitmcst18 = 0.00
                 end if
                 print lr_parametro.socopgitmcst18, ASCII(09);

                 if lr_parametro.cstqtd18 is null or lr_parametro.cstqtd18 = 0 then
                 	let lr_parametro.cstqtd18 = 0
                 end if
                 print lr_parametro.cstqtd18, ASCII(09);

                 if lr_parametro.socopgitmcst6 is null or lr_parametro.socopgitmcst6 = 0 then
                 	let lr_parametro.socopgitmcst6 = 0.00
                 end if
                 print lr_parametro.socopgitmcst6, ASCII(09);

		 if lr_parametro.cstqtd6 is null or lr_parametro.cstqtd6 = 0 then
                 	let lr_parametro.cstqtd6 = 0
                 end if
                 print lr_parametro.cstqtd6, ASCII(09);

                  if lr_parametro.socopgitmcst22 is null or lr_parametro.socopgitmcst22 = 0 then
                 	let lr_parametro.socopgitmcst22 = 0.00
                 end if
                 print lr_parametro.socopgitmcst22, ASCII(09);

		 if lr_parametro.cstqtd22 is null or lr_parametro.cstqtd22 = 0 then
                 	let lr_parametro.cstqtd22 = 0
                 end if
                 print lr_parametro.cstqtd22, ASCII(09);

 		if lr_parametro.socopgitmcst7 is null or lr_parametro.socopgitmcst7 = 0 then
                 	let lr_parametro.socopgitmcst7 = 0.00
                 end if
                 print lr_parametro.socopgitmcst7, ASCII(09);

		 if lr_parametro.cstqtd7 is null or lr_parametro.cstqtd7 = 0 then
                 	let lr_parametro.cstqtd7 = 0
                 end if
                 print lr_parametro.cstqtd7, ASCII(09);


 		if lr_parametro.socopgitmcst19 is null or lr_parametro.socopgitmcst19 = 0 then
                 	let lr_parametro.socopgitmcst19 = 0.00
                 end if
                 print lr_parametro.socopgitmcst19, ASCII(09);

		 if lr_parametro.cstqtd19 is null or lr_parametro.cstqtd19 = 0 then
                 	let lr_parametro.cstqtd19 = 0
                 end if
                 print lr_parametro.cstqtd19, ASCII(09);

                  if lr_parametro.socopgitmcst20 is null or lr_parametro.socopgitmcst20 = 0 then
                 	let lr_parametro.socopgitmcst20 = 0.00
                 end if
                 print lr_parametro.socopgitmcst20, ASCII(09);

		 if lr_parametro.cstqtd20 is null or lr_parametro.cstqtd20 = 0 then
                 	let lr_parametro.cstqtd20 = 0
                 end if
                 print lr_parametro.cstqtd20, ASCII(09);


           if  lr_parametro.soma is null or lr_parametro.soma = 0 then
               print lr_parametro.socopgitmvlr, ASCII(09);
           else
               print lr_parametro.soma,         ASCII(09);
           end if

           if  lr_parametro.clausula is null or lr_parametro.clausula = 0 then
               print " ",                       ASCII(09),
                     "SEM CLAUSULA CADASTRADA", ASCII(09);
           else
               print lr_parametro.clausula,     ASCII(09),
                     lr_parametro.clausulades,  ASCII(09);
           end if

           skip 1 line

 end report