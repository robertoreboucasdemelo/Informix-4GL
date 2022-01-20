#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR440                                                   #
# ANALISTA RESP..: CRISTIANE SILVA                                            #
# PSI/OSF........: 207209                                                     #
#                  EXTRACAO DE CARRO EXTRA - PORTO SEGURO SEGUROS             #
# ........................................................................... #
# DESENVOLVIMENTO: CRISTIANE SILVA                                            #
# LIBERACAO......: 04/04/2007                                                 #
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

    call bdbsr440_busca_path()

    call bdbsr440_prepare()

    call cts40g03_exibe_info("I","BDBSR440")

    set isolation to dirty read

    call bdbsr440()

    call cts40g03_exibe_info("F","BDBSR440")
 end main


#------------------------------#
 function bdbsr440_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr440.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path = m_path clipped, "/BDBSR440.xls"

 end function


#---------------------------#
 function bdbsr440_prepare()
#---------------------------#
    define l_sql char(1000)
    define l_data_inicio, l_data_fim date
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    # ---> OBTER A DATA E HORA DO BANCO
   call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual

    # ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
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
                       " a.socfatpgtdat, ",
                       " b.socopgitmvlr ",
                  " from dbsmopg a, dbsmopgitm b, datmservico c ",
                " where a.socfatpgtdat between '",l_data_inicio,"'",
	    			    	   " and '",l_data_fim,"'",
                   " and a.socopgsitcod = 7 ",
                   " and a.socopgnum = b.socopgnum ",
                   " and b.atdsrvnum = c.atdsrvnum ",
                   " and b.atdsrvano = c.atdsrvano ",
                   " and c.ciaempcod = 1 ",
                   " and c.atdsrvorg = 8 ",
                   " and a.soctip = 2 "
    prepare pbdbsr440001 from l_sql
    declare cbdbsr440001 cursor for pbdbsr440001

    #Identificando apolice
    let l_sql = " select succod, aplnumdig, itmnumdig ",
                  " from datrservapol ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr440002 from l_sql
    declare cbdbsr440002 cursor for pbdbsr440002

    #Identificando segurado
    let l_sql = " select segnom ",
                  " from gsakseg ",
                 " where segnumdig = ? "
    prepare pbdbsr440003 from l_sql
    declare cbdbsr440003 cursor for pbdbsr440003

    #Identificando assunto da ligacao
    let l_sql = " select c24astcod, ",
                       " c24solnom, ",
                       " c24soltip ",
                  " from datmligacao ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr440004 from l_sql
    declare cbdbsr440004 cursor for pbdbsr440004

    #Identificando tipo de servico
    let l_sql = " select srvtipdes ",
                  " from datksrvtip ",
                 " where atdsrvorg = ? "
    prepare pbdbsr440005 from l_sql
    declare cbdbsr440005 cursor for pbdbsr440005

    #Identificando data de acionamento
    let l_sql = " select acp.atdetpdat, ",
                       " acp.srrcoddig, ",
                       " acp.atdvclsgl ",
                  " from datmsrvacp acp ",
                 " where acp.atdsrvnum = ? ",
                   " and acp.atdsrvano = ? ",
                   " and acp.atdetpcod = 4 "
    prepare pbdbsr440006 from l_sql
    declare cbdbsr440006 cursor for pbdbsr440006

    #Identificando codigo locadora, nome locadora, sigla loja, nome loja,
    #diarias utilizadas, diarias pagas, valor pago locacao, motivo locacao,
    #usuario locacao, cpf usuario locacao, cheque caucao, segundo condutor,
    #descricao do veiculo, grupo veiculo, previsao uso, data retirada,
    #telefone contato da locacao
    let l_sql = " select rent.lcvcod, ",
                       " loc.lcvnom, ",
                       " rent.aviestcod, ",
                       " avis.lcvextcod, ",
                       " avis.aviestnom, ",
                       " itm.c24utidiaqtd , ",
                       " itm.c24pagdiaqtd, ",
                       " iddk.cpodes, ",
                       " rent.avilocnom, ",
                       " rent.locrspcpfnum, ",
                       " rent.locrspcpfdig, ",
                       " avis.cauchqflg, ",
                       " rent.cdtoutflg, ",
                       " veic.avivclmdl, ",
                       " veic.avivcldes, ",
                       " veic.avivclgrp, ",
                       " rent.aviprvent, ",
                       " rent.aviretdat, ",
                       " rent.ctttelnum, ",
                       " rent.avirsrgrttip ",
                  " from datklocadora loc, ",
                       " datmavisrent rent, ",
                       " dbsmopgitm itm, ",
                       " datkavislocal avis, ",
                       " iddkdominio iddk, ",
                       " datkavisveic veic ",
                 " where loc.lcvcod = rent.lcvcod ",
                   " and avis.aviestcod = rent.aviestcod ",
                   " and rent.avialgmtv = iddk.cpocod ",
                   " and rent.avivclcod = veic.avivclcod ",
                   " and rent.atdsrvnum = itm.atdsrvnum ",
                   " and rent.atdsrvano = itm.atdsrvano ",
                   " and rent.atdsrvnum = ? ",
                   " and rent.atdsrvano = ? ",
                   " and iddk.cponom = 'avialgmtv' "
    prepare pbdbsr440007 from l_sql
    declare cbdbsr440007 cursor for pbdbsr440007

    #Identificando cidade e uf da ocorrencia
    let l_sql = " select endcid, ",
                       " endufd ",
                  " from datkavislocal ",
                 " where lcvcod = ? ",
                   " and aviestcod = ? "
    prepare pbdbsr440008 from l_sql
    declare cbdbsr440008 cursor for pbdbsr440008

    #Identificando Prorrogacao
    let l_sql = " select atdsrvnum, atdsrvano ",
                  " from datmprorrog ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr440009 from l_sql
    declare cbdbsr440009 cursor for pbdbsr440009
    #CASO O RETORNO DESTE CURSOR SEJA 0, DEVERA SER APRESENTADO NO RELATORIO O FLAG "S",
    #CASO CONTRARIO, APRESENTAR "N"

    #Identificando cidade sede da ocorrência
    let l_sql = " select cidcod ",
                  " from glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
    prepare pbdbsr440010 from l_sql
    declare cbdbsr440010 cursor for pbdbsr440010

    let l_sql = " select cidsedcod ",
                  " from datrcidsed ",
                 " where cidcod = ? "
    prepare pbdbsr440011 from l_sql
    declare cbdbsr440011 cursor for pbdbsr440011

    let l_sql = " select cidcod, ",
                       " cidnom ",
                  " from glakcid ",
                 " where cidcod = ? ",
                   " and ufdcod = ?"
    prepare pbdbsr440012 from l_sql
    declare cbdbsr440012 cursor for pbdbsr440012

    #Identificando as cláusulas da apólice
    let l_sql = "  select clscod ",
      		" from abbmclaus ",
     		" where succod    = ? ",
     		" and aplnumdig = ? ",
     		" and itmnumdig = ? ",
     		" and clscod in ('26A', '26B', '26C', '26D', '26E', '26F', '26G') "
    prepare pbdbsr440013 from l_sql
    declare cbdbsr440013 cursor for pbdbsr440013

    let l_sql = " select clsdes ",
    		" from aackcls ",
    		" where clscod = ? "
    prepare pbdbsr440014 from l_sql
    declare cbdbsr440014 cursor for pbdbsr440014



 end function

#-------------------#
 function bdbsr440()
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
            asitipdes      like datkasitip.asitipdes,
            atdetpdat      like datmsrvacp.atdetpdat,
            atdvclsgl      like datmsrvacp.atdvclsgl,
            srrcoddig      like datmsrvacp.srrcoddig,
            cidcod         like glakcid.cidcod,
            cidnomsed      like glakcid.cidnom,
            endcid         like datkavislocal.endcid,
            endufd         like datkavislocal.endufd,
            cidcoddes      like datmlcl.cidnom,
            ufdcodes       like datmlcl.ufdcod,
            socopgnum      like dbsmopgitm.socopgnum,
            socfatpgtdat   like dbsmopg.socfatpgtdat,
            clscod         char(03),
            clsdes         char(50),
            itmnumdig      like datrservapol.itmnumdig,
            edsnumref      like datrligapol.edsnumref,
            ramcod         like datrservapol.ramcod,
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
            cidsedcod      like datrcidsed.cidsedcod,
            lcvcod         like datmavisrent.lcvcod,
            lcvnom         like datklocadora.lcvnom,
            aviestcod      like datmavisrent.aviestcod,
            lcvextcod      like datkavislocal.lcvextcod,
            aviestnom      like datkavislocal.aviestnom,
            c24utidiaqtd   like dbsmopgitm.c24utidiaqtd,
            c24pagdiaqtd   like dbsmopgitm.c24pagdiaqtd,
            socopgitmvlr   like dbsmopgitm.socopgitmvlr,
            cpodes         like iddkdominio.cpodes,
            avilocnom      like datmavisrent.avilocnom,
            locrspcpfnum   like datmavisrent.locrspcpfnum,
            locrspcpfdig   like datmavisrent.locrspcpfdig,
            cauchqflg      like datkavislocal.cauchqflg,
            cdtoutflg      like datmavisrent.cdtoutflg,
            avivclmdl      like datkavisveic.avivclmdl,
            avivcldes      like datkavisveic.avivcldes,
            avivclgrp      like datkavisveic.avivclgrp,
            prrflg         char(01),
            aviprvent      like datmavisrent.aviprvent,
            aviretdat      like datmavisrent.aviretdat,
            ctttelnum      like datmavisrent.ctttelnum,
            avirsrgrttip   like datmavisrent.avirsrgrttip
    end record

    define l_doc_handle     integer
    define l_qtd_end, l_ind smallint
    define l_aux_char       char(100)
    define l_grlchv	    char(100)

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
               l_doc_handle to null

    initialize lr_dados.* to null

    start report bdbsr440_relatorio to m_path

    open cbdbsr440001
    foreach cbdbsr440001 into lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.atdsrvorg,
                              lr_dados.asitipcod,
                              lr_dados.cornom,
                              lr_dados.vcldes,
                              lr_dados.vcllicnum,
                              lr_dados.socopgnum,
                              lr_dados.socfatpgtdat,
                              lr_dados.socopgitmvlr

            open cbdbsr440002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr440002 into lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  display "Erro SELECT cbdbsr440002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            close cbdbsr440002

            open cbdbsr440003 using lr_dados.aplnumdig
            whenever error continue
            fetch cbdbsr440003 into lr_dados.segnom
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440003

            open cbdbsr440004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr440004 into lr_dados.c24astcod, lr_dados.c24solnom, lr_dados.c24soltip
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440004

            #Trata nome do solicitante, retirando possiveis pipes, que prejudicam a validacao
            # dos valores do relatório

             let l_length = length(lr_dados.c24solnom)
  	     for l_ind = 1 to l_length
     		if lr_dados.c24solnom[l_ind] = "|" then
        		let lr_dados.c24solnom[l_ind] = " "
     		end if
 	     end for


            open cbdbsr440005 using lr_dados.atdsrvorg
            whenever error continue
            fetch cbdbsr440005 into lr_dados.srvtipdes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440005

            open cbdbsr440006 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr440006 into lr_dados.atdetpdat, lr_dados.srrcoddig, lr_dados.atdvclsgl
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440006

            open cbdbsr440007 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr440007 into lr_dados.lcvcod, lr_dados.lcvnom, lr_dados.aviestcod, lr_dados.lcvextcod, lr_dados.aviestnom,
                                    lr_dados.c24utidiaqtd, lr_dados.c24pagdiaqtd,
                                    lr_dados.cpodes, lr_dados.avilocnom, lr_dados.locrspcpfnum,
                                    lr_dados.locrspcpfdig, lr_dados.cauchqflg, lr_dados.cdtoutflg,
                                    lr_dados.avivclmdl, lr_dados.avivcldes, lr_dados.avivclgrp,
                                    lr_dados.aviprvent, lr_dados.aviretdat, lr_dados.ctttelnum,
                                    lr_dados.avirsrgrttip
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440007

            open cbdbsr440008 using lr_dados.lcvcod, lr_dados.aviestcod
            whenever error continue
            fetch cbdbsr440008 into lr_dados.endcid, lr_dados.endufd
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440008

            #PRORROGACAO
            let lr_dados.prrflg = "N"
            open cbdbsr440009 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr440009 into lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error stop
            if  sqlca.sqlcode = 0 then
                let lr_dados.prrflg = "S"
            else
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440009
            ############

            open cbdbsr440010 using lr_dados.endcid, lr_dados.endufd
            whenever error continue
            fetch cbdbsr440010 into lr_dados.cidcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440010

            open cbdbsr440011 using lr_dados.cidcod
            whenever error continue
            fetch cbdbsr440011 into lr_dados.cidsedcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440011

            open cbdbsr440012 using lr_dados.cidsedcod, lr_dados.endufd
            whenever error continue
            fetch cbdbsr440012 into lr_dados.cidsedcod, lr_dados.cidnomsed
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr440012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr440012

	    #CHEQUE CAUCAO
	    if lr_dados.avirsrgrttip = 1 then
	    	let lr_dados.cauchqflg = "N"
	    else
	    	if lr_dados.avirsrgrttip = 2 then
	    		let lr_dados.cauchqflg = "S"
	    	end if
	    end if


            open cbdbsr440013 using lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig
            fetch cbdbsr440013 into lr_dados.clscod
	    close cbdbsr440013

	    if lr_dados.clscod is not null then
	    	open cbdbsr440014 using lr_dados.clscod
	    	fetch cbdbsr440014 into lr_dados.clsdes
	    	close cbdbsr440014
	    end if

            output to report bdbsr440_relatorio(lr_dados.atdsrvnum,
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
                                                lr_dados.c24astcod,
                                                lr_dados.asitipdes,
                                                lr_dados.atdetpdat,
                                                lr_dados.atdvclsgl,
                                                lr_dados.srrcoddig,
                                                lr_dados.cidsedcod,
                                                lr_dados.cidnomsed,
                                                lr_dados.endcid,
                                                lr_dados.endufd,
                                                lr_dados.cidcoddes,
                                                lr_dados.ufdcodes,
                                                lr_dados.socopgnum,
                                                lr_dados.socfatpgtdat,
                                                lr_dados.clscod,
                                                lr_dados.clsdes,
                                                lr_dados.lcvcod,
                                                lr_dados.lcvnom,
                                                lr_dados.lcvextcod,
                                                lr_dados.aviestnom,
                                                lr_dados.c24utidiaqtd,
                                                lr_dados.c24pagdiaqtd,
                                                lr_dados.socopgitmvlr,
                                                lr_dados.cpodes,
                                                lr_dados.avilocnom,
                                                lr_dados.locrspcpfnum,
                                                lr_dados.locrspcpfdig,
                                                lr_dados.cauchqflg,
                                                lr_dados.cdtoutflg,
                                                lr_dados.avivclmdl,
                                                lr_dados.avivcldes,
                                                lr_dados.avivclgrp,
                                                lr_dados.prrflg,
                                                lr_dados.aviprvent,
                                                lr_dados.aviretdat,
                                                lr_dados.ctttelnum)

            initialize lr_dados.* to null

    end foreach
    close cbdbsr440001

    finish report bdbsr440_relatorio

    call bdbsr440_envia_email()

 end function


#-------------------------------#
 function bdbsr440_envia_email()
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
   let l_assunto    = "Relatorio de Carro Extra em ", l_mes_extenso clipped, " - Porto Seguro Seguros"

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path

   run l_comando

   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR440", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - BDBSR440"
       end if
   end if

end function


#---------------------------------------#
 report bdbsr440_relatorio(lr_parametro)
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
           c24astcod      like datmligacao.c24astcod,
           asitipdes      like datkasitip.asitipdes,
           atdetpdat      like datmsrvacp.atdetpdat,
           atdvclsgl      like datmsrvacp.atdvclsgl,
           srrcoddig      like datmsrvacp.srrcoddig,
           cidsedcod      like datrcidsed.cidsedcod,
           cidnomsed      like glakcid.cidnom,
           endcid         like datkavislocal.endcid,
           endufd         like datkavislocal.endufd,
           cidcoddes      like datmlcl.cidnom,
           ufdcodes       like datmlcl.ufdcod,
           socopgnum      like dbsmopgitm.socopgnum,
           socfatpgtdat   like dbsmopg.socfatpgtdat,
           clscod         char(03),
           clsdes         char(50),
           lcvcod         like datmavisrent.lcvcod,
           lcvnom         like datklocadora.lcvnom,
           lcvextcod      like datkavislocal.lcvextcod,
           aviestnom      like datkavislocal.aviestnom,
           c24utidiaqtd   like dbsmopgitm.c24utidiaqtd,
           c24pagdiaqtd   like dbsmopgitm.c24pagdiaqtd,
           socopgitmvlr   decimal(15,5),
           cpodes         like iddkdominio.cpodes,
           avilocnom      like datmavisrent.avilocnom,
           locrspcpfnum   like datmavisrent.locrspcpfnum,
           locrspcpfdig   like datmavisrent.locrspcpfdig,
           cauchqflg      char(01),
           cdtoutflg      like datmavisrent.cdtoutflg,
           avivclmdl      like datkavisveic.avivclmdl,
           avivcldes      like datkavisveic.avivcldes,
           avivclgrp      like datkavisveic.avivclgrp,
           prrflg         char(01),
           aviprvent      like datmavisrent.aviprvent,
           aviretdat      like datmavisrent.aviretdat,
           ctttelnum      like datmavisrent.ctttelnum
   end record

   define l_atdetpdat,
          l_socfatpgtdat,
          l_aviretdat char(010),
          l_cpf       char(012),
          l_vcldes    char(100)

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
           print "SUCURSAL",                       ASCII(09),
                 "APOLICE",                        ASCII(09),
                 "SEGURADO",                       ASCII(09),
                 "TIPO PESSOA LIGACAO",            ASCII(09),
                 "NOME PESSOA LIGACAO",            ASCII(09),
                 "CORRETOR",                       ASCII(09),
                 "VEICULO SEGURADO",               ASCII(09),
                 "PLACA VEICULO SEGURADO",         ASCII(09),
                 "ASSUNTO",                        ASCII(09),
                 "ORIGEM SERVICO",                 ASCII(09),
                 "SERVICO",                        ASCII(09),
                 "ANO SERVICO",                    ASCII(09),
                 "TIPO SERVICO",                   ASCII(09),
                 "DATA DE ACIONAMENTO",            ASCII(09),
                 "CIDADE SEDE DA OCORRENCIA",      ASCII(09),
                 "CIDADE DA OCORRENCIA",           ASCII(09),
                 "UF DA OCORRENCIA",               ASCII(09),
                 "CODIGO LOCADORA",                ASCII(09),
                 "NOME LOCADORA",                  ASCII(09),
                 "SIGLA LOJA",                     ASCII(09),
                 "NOME LOJA",                      ASCII(09),
                 "NUMERO DA OP",                   ASCII(09),
                 "DATA DE PAGAMENTO",              ASCII(09),
                 "DIARIAS UTILIZADAS",             ASCII(09),
                 "DIARIAS PAGAS",                  ASCII(09),
                 "VALOR PAGO LOCACAO",             ASCII(09),
                 "MOTIVO LOCACAO",                 ASCII(09),
                 "USUARIO LOCACAO",                ASCII(09),
                 "CPF USUARIO LOCACAO",            ASCII(09),
                 "CHEQUE CAUCAO",                  ASCII(09),
                 "2º CONDUTOR",                    ASCII(09),
                 "DESCRICAO VEICULO LOCADO",       ASCII(09),
                 "GRUPO VEICULO LOCADO",           ASCII(09),
                 "PRORROGACAO",                    ASCII(09),
                 "PREVISAO DE USO EM DIAS",        ASCII(09),
                 "DATA RETIRADA",                  ASCII(09),
                 "TELEFONE CONTATO",               ASCII(09),
                 "CLAUSULA CARRO EXTRA",           ASCII(09),
                 "DESCRICAO CLAUSULA CARRO EXTRA", ASCII(09);

                 skip 1 line

       on every row
           let l_atdetpdat    = extend(lr_parametro.atdetpdat, year to year), "-",
                                extend(lr_parametro.atdetpdat, month to month), "-",
                                extend(lr_parametro.atdetpdat, day to day)

           let l_socfatpgtdat = extend(lr_parametro.socfatpgtdat, year to year), "-",
                                extend(lr_parametro.socfatpgtdat, month to month), "-",
                                extend(lr_parametro.socfatpgtdat, day to day)

           let l_aviretdat    = extend(lr_parametro.aviretdat, year to year), "-",
                                extend(lr_parametro.aviretdat, month to month), "-",
                                extend(lr_parametro.aviretdat, day to day)

           let l_cpf = lr_parametro.locrspcpfnum clipped using "&&&&&&&&&", "-",
                       lr_parametro.locrspcpfdig clipped using "&&"

           let l_vcldes = lr_parametro.avivclmdl clipped, " ",
                          lr_parametro.avivcldes clipped

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

           if  lr_parametro.c24solnom is null or lr_parametro.c24solnom = " " then
               print " ",                       ASCII(09);
           else
               print lr_parametro.c24solnom,    ASCII(09);
           end if

           if  lr_parametro.cornom is null or lr_parametro.cornom = " " then
               print "CORRETOR NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.cornom,       ASCII(09);
           end if

           print lr_parametro.vcldes,           ASCII(09),
                 lr_parametro.vcllicnum,        ASCII(09),
                 lr_parametro.c24astcod,        ASCII(09),
                 lr_parametro.atdsrvorg,        ASCII(09),
                 lr_parametro.atdsrvnum,        ASCII(09),
                 lr_parametro.atdsrvano,        ASCII(09),
                 lr_parametro.srvtipdes,        ASCII(09),
                 l_atdetpdat,                   ASCII(09),
                 lr_parametro.cidnomsed,        ASCII(09),
                 lr_parametro.endcid,           ASCII(09),
                 lr_parametro.endufd,           ASCII(09),
                 lr_parametro.lcvcod,           ASCII(09),
                 lr_parametro.lcvnom,           ASCII(09),
                 lr_parametro.lcvextcod,        ASCII(09),
                 lr_parametro.aviestnom,        ASCII(09),
                 lr_parametro.socopgnum,        ASCII(09),
                 l_socfatpgtdat,                ASCII(09),
                 lr_parametro.c24utidiaqtd,     ASCII(09),
                 lr_parametro.c24pagdiaqtd ,     ASCII(09),
                 lr_parametro.socopgitmvlr using "---------&,&&",     ASCII(09),
                 lr_parametro.cpodes,           ASCII(09),
                 lr_parametro.avilocnom,        ASCII(09),
                 l_cpf,                         ASCII(09),
                 lr_parametro.cauchqflg,        ASCII(09),
                 lr_parametro.cdtoutflg,        ASCII(09),
                 l_vcldes,                      ASCII(09),
                 lr_parametro.avivclgrp,        ASCII(09),
                 lr_parametro.prrflg,           ASCII(09),
                 lr_parametro.aviprvent,        ASCII(09),
                 l_aviretdat,                   ASCII(09),
                 lr_parametro.ctttelnum,        ASCII(09);

           if  lr_parametro.clscod is null or lr_parametro.clscod = 0 then
               print " ",                       ASCII(09),
                     "SEM CLAUSULA CADASTRADA", ASCII(09);
           else
               print lr_parametro.clscod,       ASCII(09),
                     lr_parametro.clsdes,       ASCII(09);
           end if

           skip 1 line

 end report