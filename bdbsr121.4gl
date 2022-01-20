#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr121                                                   #
# ANALISTA RESP..: Andre Pinto                                                #
# PSI/OSF........: 230430                                                     #
#                  RELATORIO RESOLUCAO             - PORTO SEGURO SEGUROS     #
# ........................................................................... #
# DESENVOLVIMENTO: Andre Pinto                                                #
# LIBERACAO......: 12/11/2008                                                 #
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

    call bdbsr121_busca_path()

    call bdbsr121_prepare()

    call cts40g03_exibe_info("I","bdbsr121")

    set isolation to dirty read

    call bdbsr121()

    call cts40g03_exibe_info("F","bdbsr121")
 end main


#------------------------------#
 function bdbsr121_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr121.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr121.xls"

 end function


#---------------------------#
 function bdbsr121_prepare()
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
        let l_data_inicio = mdy(month(l_data_atual) - 1,21,year(l_data_atual))
        let l_data_fim    = mdy(month(l_data_atual),20,year(l_data_atual))
    end if

    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(l_data_inicio)

    #Identificando os servicos
    set isolation to dirty read

    let l_sql = "Select atdsrvnum, "
    	       ,"       atdsrvano, "
    	       ,"       prsokadat,  "
    	       ,"       pstcoddig  "
    	       ,"  from dbsmsrvacr "
    	       ," where prsokadat >= '", l_data_inicio using "dd/MM/yyyy", "' "
    	       ,"   and prsokadat <= '", l_data_fim using "dd/MM/yyyy", "' "
    	       ,"   and prsokaflg = 'S' "
    prepare pbdbsr121001 from l_sql
    declare cbdbsr121001 cursor for pbdbsr121001

    #Identificando apolice
    let l_sql = " select succod, aplnumdig, itmnumdig ",
                  " from datrservapol ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr121002 from l_sql
    declare cbdbsr121002 cursor for pbdbsr121002

    #Identificando segurado
    let l_sql = " select seg.segnom, ",
    		 "       seg.segsex  ",
                  " from gsakseg seg,  abbmdoc doc ",
                 " where seg.segnumdig = doc.segnumdig ",
                 " and doc.aplnumdig = ? ",
                 " and doc.succod = ? "
    prepare pbdbsr121003 from l_sql
    declare cbdbsr121003 cursor for pbdbsr121003

    #Identificando tipos de brindes
    let l_sql = " select c24pbmdes ",
                  " from datrsrvpbm ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr121004 from l_sql
    declare cbdbsr121004 cursor for pbdbsr121004

    #Identificando tipo de servico
    let l_sql = " select srvtipdes ",
                  " from datksrvtip ",
                 " where atdsrvorg = ? "
    prepare pbdbsr121005 from l_sql
    declare cbdbsr121005 cursor for pbdbsr121005

    #Identificando a resolucao
    let l_sql = " select datrsrvprt.prtseq, datrsrvprt.prtsrvdes  ",    		 
                  " from datrsrvprt, datkprt ",
                 " where atdsrvnum = ? ",
                 "   and atdsrvano = ? ",
                 "   and datkprt.prtseq = datrsrvprt.prtseq ",
                 "   and datkprt.prttip = 1 "
    prepare pbdbsr121006 from l_sql
    declare cbdbsr121006 cursor for pbdbsr121006

    #Identificando a descricao do parametro
    let l_sql = " select prtdes, prtgrpcod ",
                  " from datkprt ",
                 " where prtseq = ? "
    prepare pbdbsr121007 from l_sql
    declare cbdbsr121007 cursor for pbdbsr121007

    #Identificando data de acionamento
    let l_sql = " select acp.atdetpdat, ",
                       " acp.srrcoddig, ",
                       " acp.atdvclsgl, ",
                       " acp.socvclcod, ",
                       " acp.atdetphor  ",
                  " from datmsrvacp acp ",
                 " where acp.atdsrvnum = ? ",
                   " and acp.atdsrvano = ? ",
                   " and acp.atdetpcod = 4 "
    prepare pbdbsr121008 from l_sql
    declare cbdbsr121008 cursor for pbdbsr121008

    #Identificando cidade e uf da ocorrencia
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                  " from datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 1 "
    prepare pbdbsr121009 from l_sql
    declare cbdbsr121009 cursor for pbdbsr121009

    #Identificando nome do Corretor
    let l_sql = " select cornom ",
                  " from gcakcorr ",
                 " where corsuspcp = ? "
    prepare pbdbsr121010 from l_sql
    declare cbdbsr121010 cursor for pbdbsr121010

    #Identificando o prestador
    let l_sql = " select socor.pstcoddig, ",
                       " socor.nomrazsoc ",
                  " from  dpaksocor socor ",
                  " where pstcoddig = ? "
    prepare pbdbsr121011 from l_sql
    declare cbdbsr121011 cursor for pbdbsr121011

    #Identificando o nome do socorrista
    let l_sql = " select srrnom ",
                  " from datksrr ",
                 " where srrcoddig = ? "
    prepare pbdbsr121012 from l_sql
    declare cbdbsr121012 cursor for pbdbsr121012

    #Identificando a origem do servico
    let l_sql = " select atdsrvorg ",
                  " from datmservico ",
                 " where atdsrvnum = ? ",
                 "   and atdsrvano = ? "
    prepare pbdbsr121013 from l_sql
    declare cbdbsr121013 cursor for pbdbsr121013

    #Identificando os subgrupos
    let l_sql = " select prtgrpcod, prtdes ",
                  " from datkprt ",
                 " where prtgrpsubcod = ? ",
                 "   and prttip = 1"
    prepare pbdbsr121014 from l_sql
    declare cbdbsr121014 cursor for pbdbsr121014

    #Identificando as descricoes dos grupos
    let l_sql = " select prtseq ",
                  " from datkprt ",
                 " where prtseq in ( select prtseq",
                 "                    from datrsrvprt ",
                 "                   where atdsrvnum = ? ",
                 "                     and atdsrvano = ? ) ",
                 "   and prttip = 2 "
    prepare pbdbsr121015 from l_sql
    declare cbdbsr121015 cursor for pbdbsr121015

    #Identificando SUSEP
    let l_sql = " select corsusldr ",
                "   from abamapol  ",
                "   where aplnumdig = ? ",
                "     and succod = ? "
    prepare pbdbsr121016 from l_sql
    declare cbdbsr121016 cursor for pbdbsr121016

    #Identificando as descricoes dos brindes
    let l_sql = " select prtdes ",
                  " from datkprt ",
                 " where prtseq = ? "
    prepare pbdbsr121017 from l_sql
    declare cbdbsr121017 cursor for pbdbsr121017

    #Identificando cidade sede da ocorrência
    let l_sql = " select cidcod ",
                  " from  glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
    prepare pbdbsr121020 from l_sql
    declare cbdbsr121020 cursor for pbdbsr121020

    let l_sql = " select cidsedcod ",
                  " from  datrcidsed ",
                 " where cidcod = ? "
    prepare pbdbsr121021 from l_sql
    declare cbdbsr121021 cursor for pbdbsr121021

    let l_sql = " select cidcod, ",
                       " cidnom ",
                  " from  glakcid ",
                 " where cidcod = ? ",
                   " and ufdcod = ?"
    prepare pbdbsr121022 from l_sql
    declare cbdbsr121022 cursor for pbdbsr121022

    				
    #Identificando a sigla do veiculo acionado
    let l_sql = " select atdvclsgl   ",
    		"   from datkveiculo ",
    		"  where socvclcod = ? "
    prepare pbdbsr121026 from l_sql
    declare cbdbsr121026 cursor for pbdbsr121026 
    
    

    #Identificando o prestador
    let l_sql = " select socor.pstcoddig, ",
	               	" socor.nomrazsoc ",
		        " from  dpaksocor socor,  datmsrvacp acp ",
	         	" where socor.pstcoddig = acp.pstcoddig ",
	           	" and acp.atdsrvnum = ? ",
	           	" and acp.atdsrvano = ? ",
	           	" and acp.atdetpcod = 4 "
	prepare pbdbsr121031 from l_sql
	declare cbdbsr121031 cursor for pbdbsr121031



 end function

#-------------------#
 function bdbsr121()
#-------------------#

    define lr_dados record
           atdsrvnum    like    datmservico.atdsrvnum,
           atdsrvano    like    datmservico.atdsrvano,
           atdsrvorg    like    datmservico.atdsrvorg,
           prsokadat    like    dbsmsrvacr.prsokadat,
           succod       like    datrservapol.succod,
           aplnumdig    like    datrservapol.aplnumdig,
           itmnumdig    like    datrservapol.itmnumdig,
           segnom       like    gsakseg.segnom,
           segsex       like    gsakseg.segsex,
           corsusldr    like    gcakcorr.corsuspcp,
           cornom       like    gcakcorr.cornom,
           srvtipdes    like    datksrvtip.srvtipdes,
           pstcoddig    like    dpaksocor.pstcoddig,
           nomrazsoc    like    dpaksocor.nomrazsoc,
           prttip       like    datkprt.prttip,
           prtseq       like    datkprt.prtseq,
           prtdes       char(1000),
           c24pbmdes    like    datkpbm.c24pbmdes,
           atdvclsgl    like    datkveiculo.atdvclsgl,
           atdetpdat    like    datmsrvacp.atdetpdat,
           atdetphor    like    datmsrvacp.atdetphor,
           srrcoddig    like    datmsrvacp.srrcoddig,
           socvclcod    like    datmsrvacp.socvclcod,
           cidcod       like    glakcid.cidcod,
           cidnom       like    glakcid.cidnom,
           ufdcod       like    glakcid.ufdcod,
           cidsedcod    like    glakcid.cidcod,
           cidsednom    like    glakcid.cidnom,
           srrnom       like    datksrr.srrnom,
           prtgrpcod    like    datkprt.prtgrpcod,
           prtgrpsubcod like    datkprt.prtgrpsubcod,
           prtsrvdes    like    datrsrvprt.prtsrvdes
    end record

    define l_qtd_end, l_ind smallint
    define l_aux     char(1000)
    define l_cabecalho  char(10000)
    define l_linha  char(10000)
    define l_brinde char(100)
    define l_grupo smallint
    define l_subgrupo smallint
    define l_prtseq  smallint
    define x smallint

    define l_length smallint

    initialize lr_dados.* to null
    let l_linha = null
    
    start report bdbsr121_relatorio to m_path

    open cbdbsr121001
    foreach cbdbsr121001 into lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.prsokadat,
                              lr_dados.pstcoddig

            open cbdbsr121002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr121002 into lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr121002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr121002

            open cbdbsr121003 using lr_dados.aplnumdig, lr_dados.succod
            whenever error continue
            fetch cbdbsr121003 into lr_dados.segnom, lr_dados.segsex
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121003

	    open cbdbsr121013 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr121013 into lr_dados.atdsrvorg
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121013

            open cbdbsr121005 using lr_dados.atdsrvorg
            whenever error continue
            fetch cbdbsr121005 into lr_dados.srvtipdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121005

            open cbdbsr121008 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr121008 into lr_dados.atdetpdat, lr_dados.srrcoddig, lr_dados.atdvclsgl, lr_dados.socvclcod, lr_dados.atdetphor
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121008

	    if lr_dados.socvclcod is not null and lr_dados.socvclcod <> 0 then
	    	open cbdbsr121026 using lr_dados.socvclcod
	    	whenever error continue
	                fetch cbdbsr121026 into lr_dados.atdvclsgl
	    	whenever error stop
	    	if sqlca.sqlcode <> 0 then
	    		if sqlca.sqlcode <> notfound then
	    		    display "Erro SELECT cbdbsr121026 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2], "socvclcod = ",lr_dados.atdvclsgl
	    		    exit program(1)
	    		end if
	    	end if
	    	close cbdbsr121026
	    
	    end if

            open cbdbsr121009 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr121009 into lr_dados.cidnom, lr_dados.ufdcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121009

            open cbdbsr121011 using lr_dados.pstcoddig
            whenever error continue
            fetch cbdbsr121011 into lr_dados.pstcoddig, lr_dados.nomrazsoc
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121011

            if  lr_dados.srrcoddig is null or lr_dados.srrcoddig = 0 then
                let lr_dados.srrnom = " "
            else
                open cbdbsr121012 using lr_dados.srrcoddig
                whenever error continue
                fetch cbdbsr121012 into lr_dados.srrnom
                whenever error stop
                if  sqlca.sqlcode <> 0 then
                    if  sqlca.sqlcode <> notfound then
                        display "Erro SELECT cbdbsr121012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                        exit program(1)
                    end if
                end if
                close cbdbsr121012
            end if

            open cbdbsr121016 using lr_dados.aplnumdig, lr_dados.succod
            whenever error continue
            fetch cbdbsr121016 into lr_dados.corsusldr

            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121016

            open cbdbsr121020 using lr_dados.cidnom, lr_dados.ufdcod
            whenever error continue
            fetch cbdbsr121020 into lr_dados.cidcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121020 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121020

            open cbdbsr121021 using lr_dados.cidcod
            whenever error continue
            fetch cbdbsr121021 into lr_dados.cidsedcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121021

            open cbdbsr121022 using lr_dados.cidsedcod, lr_dados.ufdcod
            whenever error continue
            fetch cbdbsr121022 into lr_dados.cidsedcod, lr_dados.cidsednom
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121022

	    open cbdbsr121004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr121004 into lr_dados.c24pbmdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121004

            open cbdbsr121006 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr121006 into lr_dados.prtseq, lr_dados.prtsrvdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121006

            open cbdbsr121007 using lr_dados.prtseq
            whenever error continue
            fetch cbdbsr121007 into lr_dados.prtdes, lr_dados.prtgrpcod
            if lr_dados.prtdes is not null then
               let l_ind = true
            end if
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr121007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr121007
            let x = 0
            let l_grupo = lr_dados.prtgrpcod
            
            while(x = 0)                 
                 open cbdbsr121014 using l_grupo
            	 let l_aux = null     
                 whenever error continue
                 fetch cbdbsr121014 into l_grupo, l_aux
                     if l_aux is not null then
                         let lr_dados.prtdes = l_aux clipped, " / ", lr_dados.prtdes clipped
                     end if
                     whenever error stop
                     if  sqlca.sqlcode <> 0 then
                        if  sqlca.sqlcode <> notfound then
                            display "Erro SELECT cbdbsr121014 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                            exit program(1)
                        else
                            let x = 1
                        end if
                     end if                  
                 close cbdbsr121014
            end while

	    open cbdbsr121031 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            fetch cbdbsr121031 into lr_dados.pstcoddig, lr_dados.nomrazsoc
	    close cbdbsr121031

	    #Cabecalho
	    let l_cabecalho = "CODIGO PRESTADOR",            ASCII(09),
                 	       "NOME PRESTADOR",              ASCII(09),
                           "NUMERO SERVICO",              ASCII(09),
                  	       "ANO SERVICO",                 ASCII(09),
	                      "SIGLA VIATURA",               ASCII(09),
	                      "CODIGO SOCORRISTA",           ASCII(09),
	                      "NOME SOCORRISTA",             ASCII(09),
	                      "CIDADE",                      ASCII(09),
	                      "CIDADE SEDE",                 ASCII(09),
	                      "UF",                          ASCII(09),
	                      "TIPO SERVICO",                ASCII(09),
	                      "SUCURSAL",                    ASCII(09),
	                      "APOLICE",                     ASCII(09),
	                      "NOME SEGURADO",               ASCII(09),
	                      "SEXO SEGURADO",               ASCII(09),
	                      "SUSEP",                       ASCII(09),
	                      "NOME CORRETOR",               ASCII(09),
	                      "DATA ACIONAMENTO",            ASCII(09),
	                      "HORA ACIONAMENTO",            ASCII(09),	                      
	                      "PROBLEMA APRESENTADO",        ASCII(09),	                     
	                      "LOCAL REMOCAO",               ASCII(09),
	                      "DESCRICAO SERVICO",	     ASCII(09)



            #Linha
            if  lr_dados.pstcoddig is null or lr_dados.pstcoddig = 0 then
                let l_linha = l_linha clipped, "PRESTADOR NAO CADASTRADA", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.pstcoddig,       ASCII(09);
            end if

            if  lr_dados.nomrazsoc is null or lr_dados.nomrazsoc clipped = "" then
                let l_linha = l_linha clipped, "PRESTADOR NAO CADASTRADA",  ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.nomrazsoc,    ASCII(09);
            end if

            if  lr_dados.atdsrvnum is null or lr_dados.atdsrvnum = " " then
                let l_linha = l_linha clipped, "SERVICO NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.atdsrvnum,       ASCII(09);
            end if
          

            if  lr_dados.atdsrvano is null or lr_dados.atdsrvano = " " then
                let l_linha = l_linha clipped, "SERVICO NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.atdsrvano,       ASCII(09);
            end if


            if  lr_dados.atdvclsgl is null or lr_dados.atdvclsgl = " " then
                let l_linha = l_linha clipped, "SIGLA NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.atdvclsgl,       ASCII(09);
            end if


            if  lr_dados.srrcoddig is null or lr_dados.srrcoddig = " " then
                let l_linha = l_linha clipped, "SOCORRISTA NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.srrcoddig,       ASCII(09);
            end if


            if  lr_dados.srrnom is null or lr_dados.srrnom = " " then
                let l_linha = l_linha clipped, "SOCORRISTA NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.srrnom,       ASCII(09);
            end if


            if  lr_dados.cidnom is null or lr_dados.cidnom = " " then
                let l_linha = l_linha clipped, "CIDADE NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.cidnom,       ASCII(09);
            end if


            if  lr_dados.cidsednom is null or lr_dados.cidsednom = " " then
                let l_linha = l_linha clipped, "CIDADE NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.cidsednom,       ASCII(09);
            end if


            if  lr_dados.ufdcod is null or lr_dados.ufdcod = " " then
                let l_linha = l_linha clipped, "UF NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.ufdcod,       ASCII(09);
            end if


            if  lr_dados.srvtipdes is null or lr_dados.srvtipdes = " " then
                let l_linha = l_linha clipped, "ORIGEM NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.srvtipdes,       ASCII(09);
            end if


            if  lr_dados.succod is null or lr_dados.succod = " " then
                let l_linha = l_linha clipped, "SUCURSAL NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.succod,       ASCII(09);
            end if


            if  lr_dados.aplnumdig is null or lr_dados.aplnumdig = " " then
                let l_linha = l_linha clipped, "APLOICE NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.aplnumdig,       ASCII(09);
            end if


            if  lr_dados.segnom is null or lr_dados.segnom = " " then
                let l_linha = l_linha clipped, "SEGURADO NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.segnom,       ASCII(09);
            end if


            if  lr_dados.segsex is null or lr_dados.segsex = " " then
                let l_linha = l_linha clipped, "SEGURADO NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.segsex,       ASCII(09);
            end if


            if  lr_dados.corsusldr is null or lr_dados.corsusldr = " " then
                let l_linha = l_linha clipped, "SUSEP NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.corsusldr,       ASCII(09);
            end if


            if  lr_dados.cornom is null or lr_dados.cornom = " " then
                let l_linha = l_linha clipped, "CORRETOR NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.cornom,       ASCII(09);
            end if


            if  lr_dados.atdetpdat is null or lr_dados.atdetpdat = " " then
                let l_linha = l_linha clipped, "SERVICO NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.atdetpdat,       ASCII(09);
            end if


	       if  lr_dados.atdetphor is null or lr_dados.atdetphor = " " then
                let l_linha = l_linha clipped, "SERVICO NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.atdetphor,       ASCII(09);
            end if

            if lr_dados.c24pbmdes is null or lr_dados.c24pbmdes = " " then
                let l_linha = l_linha clipped, "PROBLEMA NAO CADASTRADO", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.c24pbmdes, ASCII(09);
            end if
		
	    #if l_ind = true and lr_dados.prtseq != 1 then
            #    let l_linha = l_linha clipped, "SIM", ASCII(09);
            #else
            #    let l_linha = l_linha clipped, "NAO", ASCII(09);
            #end if
	    if lr_dados.prtdes is null or lr_dados.prtdes clipped = ""  then
	    	let l_linha = l_linha clipped, " ", ASCII(09);
	    else
	        let l_linha = l_linha clipped, lr_dados.prtdes, ASCII(09);
	    end if
	    
            if lr_dados.prtsrvdes is null or lr_dados.prtsrvdes clipped= "" then
                let l_linha = l_linha clipped, " ", ASCII(09);
            else
                let l_linha = l_linha clipped, lr_dados.prtsrvdes, ASCII(09);
            end if
            
            

            output to report bdbsr121_relatorio( l_cabecalho,
            					 l_linha)
        initialize lr_dados.* to null
        let l_linha = null
        let l_cabecalho = null
        let l_ind = null
    end foreach
    close cbdbsr121001

    finish report bdbsr121_relatorio

    call bdbsr121_envia_email()

 end function


#-------------------------------#
 function bdbsr121_envia_email()
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
   let l_assunto    = "Relatorio de Resolucoes Mes de ", l_mes_extenso clipped, " - Porto Seguro Seguros"

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path

   run l_comando

   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("bdbsr121", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - bdbsr121"
       end if
   end if

end function


#---------------------------------------#
 report bdbsr121_relatorio(lr_parametro)
#---------------------------------------#

   define lr_parametro record
           cabecalho char(10000),
   	   linha char(10000)
   end record

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00


   format
       first page header
           print lr_parametro.cabecalho
           skip 1 line

     on every row
         print lr_parametro.linha
 end report
