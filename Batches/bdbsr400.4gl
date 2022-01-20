#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR400                                                   #
# ANALISTA RESP..: CRISTIANE SILVA                                            #
# PSI/OSF........: 207209                                                     #
#                  EXTRACAO DE SERVICOS PAGOS - AZUL SEGUROS                  #
# ........................................................................... #
# DESENVOLVIMENTO: CRISTIANE SILVA                                            #
# LIBERACAO......: 09/02/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 04/2008    Norton-Meta     sa593346_0  Otimizacao dos Selects,  colocando   #
#                                        acesso pelos indices corretos.Inclu- #
#                                        sao das funcoes figrc011_inicio_parse#
#                                        e figrc011_fim_parse.                #
#-----------------------------------------------------------------------------#
# 08/2008    Andre Pinto     PSI227  	Inclusao do relatorio B que é gerado  #
#                                        com filtro de datmservico.atddat     #
#-----------------------------------------------------------------------------#
# 18/08/08   Carla Rampazzo              Substituir tratamento da clausula 037#
#                                        DE  :kilometragem                    #
#                                        PARA:Limite Retorno/Desc.Assistencia #
#-----------------------------------------------------------------------------#
# 21/11/09   Carla Rampazzo              Tratar novas Clausulas:              #
#                                        37A : Assist.24h - Rede Referenciada #
#                                        37B : Assist.24h - Livre Escolha     #
#-----------------------------------------------------------------------------#
# 05/02/10   Carla Rampazzo              Tratar nova Clausula:                #
#                                        37C : Assist.24h - Assit.Gratuita    #
#-----------------------------------------------------------------------------#
# 20/05/10   Beatriz Araujo              Correção do realtório, pois não      #
#                                        trazia a descrição da clausula 37A   #
#-----------------------------------------------------------------------------#
# 05/06/15   RCP, Fornax     RELTXT      Criar versao .txt dos relatorios.    #
#-----------------------------------------------------------------------------#

 database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define m_path       char(100),
           m_path_txt   char(100), #--> RELTXT
    	   m_path_b     char(100),
    	   m_path_b_txt char(100), #--> RELTXT 
           m_mes_int smallint,
           m_horario datetime hour to fraction,
           m_log     char(200),
	   teste     char(1)
	   
   define mr_bdbsr400 record
      resultado       smallint
     ,azlaplcod       integer
     ,mensagem        char(50)
     ,doc_handle      integer
   end record

 main

    call fun_dba_abre_banco("CT24HS")
   
    call bdbsr400_busca_path()

    call bdbsr400_prepare()

    call cts40g03_exibe_info("I","BDBSR400")

    set isolation to dirty read

    call bdbsr400()
    
    call cts40g03_exibe_info("F","BDBSR400")

 end main

#------------------------------#
 function bdbsr400_busca_path()
#------------------------------#

    define l_dataarq char(8)
    define l_data    date
    
    let l_data = today
    display "l_data: ", l_data
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)
    display "l_dataarq: ", l_dataarq

    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    #ligia retirar aqui
    #if m_path is null then
       let m_path = "."
    #end if

    let m_path = m_path clipped, "/bdbsr400.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    #ligia desinibir aqui, foi so testes
    #if m_path is null then
        let m_path = "."
    #end if

    let m_path_b_txt = m_path clipped, "/BDBSR400B_", l_dataarq, ".txt"   
    let m_path_b     = m_path clipped, "/BDBSR400B.xls"
    let m_path_txt   = m_path clipped, "/BDBSR400_", l_dataarq, ".txt"   
    let m_path       = m_path clipped, "/BDBSR400.xls"
    
 end function

#---------------------------#
 function bdbsr400_prepare()
#---------------------------#
    define l_sql char(600)
    define l_data_inicio, l_data_fim date
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    let l_data_atual = arg_val(1)
    
    # ---> OBTER A DATA E HORA DO BANCO
    if l_data_atual is null then
       call cts40g03_data_hora_banco(2)
            returning l_data_atual,
                      l_hora_atual
    end if                
    display "l_data_atual: ",l_data_atual
    # ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
    if  month(l_data_atual) = 01 then
        let l_data_inicio = mdy(12,01,year(l_data_atual) - 1)
        let l_data_fim    = mdy(12,31,year(l_data_atual) - 1)

    else
        #let l_data_inicio = mdy(month(l_data_atual),01,year(l_data_atual))
        let l_data_inicio = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
        let l_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
        #let l_data_fim = l_data_atual
    end if
    display "l_data_inicio: ",l_data_inicio 
    display "l_data_fim: ",l_data_fim
    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(l_data_inicio)
    #Identificando os servicos

    let l_sql = " select c.atdsrvnum, ",
                       " c.atdsrvano, ",
                       " c.atdsrvorg, ",
                       " c.asitipcod, ",
                       " c.atdetpcod, ",
                       " c.cornom, ",
                       " c.vcldes, ",
                       " c.vcllicnum, ",
                       " a.socopgnum, ",
                       " a.socfatpgtdat, ",
                       " b.socopgitmnum, ",
                       " c.vclanomdl, c.corsus, c.atddat ",
                  " from dbsmopg a, dbsmopgitm b, ",
                   " datmservico c ",
                  " where a.socfatpgtdat between '", l_data_inicio, "' and '", l_data_fim, "'",
                   " and a.socopgsitcod = 7 ",
                   " and a.soctip = 1 ",
                   " and a.socopgnum = b.socopgnum ",
                   " and b.atdsrvnum = c.atdsrvnum ",
                   " and b.atdsrvano = c.atdsrvano ",
                   " and c.ciaempcod = 35 ",
                   " and c.atdsrvorg <= 7 "
    prepare pbdbsr400001 from l_sql
    declare cbdbsr400001 cursor for pbdbsr400001
     
    #Identificando apolice
    let l_sql = " select succod, aplnumdig, itmnumdig,ramcod,edsnumref ",
                  " from datrservapol ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr400002 from l_sql
    declare cbdbsr400002 cursor for pbdbsr400002

    #Identificando segurado
    let l_sql = " select segnom ",
                 " from datkazlapl ",
                 " where succod    = ? ",
                 " and   ramcod    = ? ",
                 " and   aplnumdig = ? ",
                 " and   itmnumdig = ? ",
                 " and   edsnumdig = ? "
    prepare pbdbsr400003 from l_sql
    declare cbdbsr400003 cursor for pbdbsr400003

    #Identificando assunto da ligacao
    let l_sql = " select c24astcod, ",
                       " c24solnom, ",
                       " c24soltip ",
                  " from datmligacao ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr400004 from l_sql
    declare cbdbsr400004 cursor for pbdbsr400004

    #Identificando tipo de servico
    let l_sql = " select srvtipdes ",
                  " from datksrvtip ",
                 " where atdsrvorg = ? "
    prepare pbdbsr400005 from l_sql
    declare cbdbsr400005 cursor for pbdbsr400005

    #Identificando tipo de assitencia
    let l_sql = " select asitipdes ",
                  " from datkasitip ",
                 " where asitipcod = ? "
    prepare pbdbsr400006 from l_sql
    declare cbdbsr400006 cursor for pbdbsr400006

    #Identificando o problema
    let l_sql = " select c24pbmdes ",
                 " from datrsrvpbm ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24pbmseq = 1"
    prepare pbdbsr400007 from l_sql
    declare cbdbsr400007 cursor for pbdbsr400007

    #Identificando data de acionamento
    let l_sql = " select acp.atdetpdat, ",
                       " acp.srrcoddig, ",
                       " acp.atdvclsgl, ",
                       " acp.socvclcod ",
                  " from datmsrvacp acp ",
                 " where acp.atdsrvnum = ? ",
                   " and acp.atdsrvano = ? ",
                   " and acp.atdetpcod = ? "
    prepare pbdbsr400008 from l_sql
    declare cbdbsr400008 cursor for pbdbsr400008

    #Identificando cidade e uf da ocorrencia
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                 " from datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = ? "
    prepare pbdbsr400009 from l_sql
    declare cbdbsr400009 cursor for pbdbsr400009

    #Identificando o prestador
    let l_sql = " select socor.pstcoddig, ",
                       " socor.nomrazsoc ",
                  " from dpaksocor socor, dbsmopg opg ",
                 " where socor.pstcoddig = opg.pstcoddig ",
                   " and opg.socopgnum = ? "
    prepare pbdbsr400011 from l_sql
    declare cbdbsr400011 cursor for pbdbsr400011

    #Identificando o nome do socorrista
    let l_sql = " select srrnom ",
                  " from datksrr ",
                 " where srrcoddig = ? "
    prepare pbdbsr400012 from l_sql
    declare cbdbsr400012 cursor for pbdbsr400012

    #Identificando valor total do servico
    let l_sql = " select socopgitmvlr ",
                 " from dbsmopgitm ",
                 " where socopgnum = ? ",
                   " and atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr400013 from l_sql
    declare cbdbsr400013 cursor for pbdbsr400013

    #Identificando custos - Valor Faixa 1
    let l_sql = " select soccstcod, ",
                       " socopgitmcst, ",
                       " cstqtd ",
                  " from dbsmopgcst ",
                 " where socopgnum = ? ",
                   " and atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and soccstcod = 1 "
    prepare pbdbsr400014 from l_sql
    declare cbdbsr400014 cursor for pbdbsr400014

    #Identificando custos - Valor Faixa 2
    let l_sql = " select soccstcod, ",
                       " socopgitmcst, ",
                       " cstqtd ",
                  " from dbsmopgcst ",
                 " where socopgnum = ? ",
                   " and atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and soccstcod = 2 "
    prepare pbdbsr400015 from l_sql
    declare cbdbsr400015 cursor for pbdbsr400015

    #Identificando custos - Km Excedente
    let l_sql = " select cst.soccstcod, ",
                       " cst.socopgitmcst, ",
                       " cst.cstqtd ",
                  " from dbsmopgcst cst, dbsmopgitm itm",
                 " where cst.socopgnum = itm.socopgnum ",
                 " and cst.socopgitmnum = itm.socopgitmnum ",
                 " and cst.socopgnum = ? ",
                 " and itm.atdsrvnum = ? ",
                 " and itm.atdsrvano = ? ",
                 " and cst.soccstcod = ? "
    prepare pbdbsr400016 from l_sql
    declare cbdbsr400016 cursor for pbdbsr400016

    #Identificando cidade sede da ocorrência
    let l_sql = " select cidcod ",
                  " from glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
    prepare pbdbsr400020 from l_sql
    declare cbdbsr400020 cursor for pbdbsr400020

    let l_sql = " select cidsedcod ",
                  " from datrcidsed ",
                 " where cidcod = ? "
    prepare pbdbsr400021 from l_sql
    declare cbdbsr400021 cursor for pbdbsr400021

    let l_sql = " select cidcod, ",
                       " cidnom ",
                  " from glakcid ",
                 " where cidcod = ? ",
                   " and ufdcod = ?"
    prepare pbdbsr400022 from l_sql
    declare cbdbsr400022 cursor for pbdbsr400022

    #Identificando total pago
    let l_sql = " select sum(socopgitmcst) ",
                  " from dbsmopgcst ",
                 " where socopgnum = ? ",
                   " and socopgitmnum in (select socopgitmnum ",
                                          " from dbsmopgitm ",
                                         " where atdsrvnum = ? ",
                                           " and atdsrvano = ? ",
                                           " and socopgnum = ?)"
    prepare pbdbsr400024 from l_sql
    declare cbdbsr400024 cursor for pbdbsr400024

    #Identificando a placa do veiculo segurado
    let l_sql = " select vcllicnum ",
                  " from datkazlapl ",
                  " where succod = ? ",
                  " and ramcod    = ? ",
                  " and aplnumdig = ? ",
                  " and itmnumdig = ? ",
                  " and edsnumdig = ? "
    prepare pbdbsr400025 from l_sql
    declare cbdbsr400025 cursor for pbdbsr400025

    #Identificando a sigla do veiculo acionado
    let l_sql = " select atdvclsgl from datkveiculo ",
    		" where socvclcod = ? "
    prepare pbdbsr400026 from l_sql
    declare cbdbsr400026 cursor for pbdbsr400026

     let l_sql = " SELECT a.azlaplcod ",
                 " FROM datkazlapl a",
                 " WHERE a.succod   = ? ",
                  " AND a.ramcod    = ?  ",
                  " AND a.aplnumdig = ?  ",
                  " AND a.itmnumdig = ? ",
                  "  AND a.edsnumdig IN (SELECT max(edsnumdig) ",
                                         " FROM datkazlapl b ",
                                         " WHERE a.succod    = b.succod ",
                                         " AND a.aplnumdig = b.aplnumdig ",
                                         " AND a.itmnumdig = b.itmnumdig ",
                                         " AND a.ramcod    = b.ramcod) "

     prepare pbdbsr400028 from l_sql
     declare cbdbsr400028 cursor for pbdbsr400028


  #let l_sql = " select c.atdsrvnum, ",
  #   " c.atdsrvano, ",
  #   " c.atdsrvorg, ",
  #   " c.asitipcod, ",
  #   " c.cornom, ",
  #   " c.vcldes, ",
  #   " c.vcllicnum, ",
  #   " a.socopgnum, ",
  #   " a.socfatpgtdat, ",
  #   " b.socopgitmnum ",
  #   " from dbsmopg a, dbsmopgitm b, ",
  #   " datmservico c ",
  #   " where c.atddat between '", l_data_inicio, "' and '", l_data_fim, "'",
  #   " and a.soctip = 1 ",
  #   " and a.socopgnum = b.socopgnum ",
  #   " and b.atdsrvnum = c.atdsrvnum ",
  #   " and b.atdsrvano = c.atdsrvano ",
  #   " and c.ciaempcod = 35 ",
  #   " and c.atdsrvorg <> 8 "
  let l_sql = " select c.atdsrvnum, "
               ," c.atdsrvano, "
               ," c.atdsrvorg, "
               ," c.asitipcod, "
               ," c.atdetpcod, "
               ," c.cornom, "
               ," c.vcldes, "
               ," c.vcllicnum, "
               ," c.vclanomdl, "
               ," c.corsus, "
               ," c.atddat " #--> FX-080515
               ," from datmservico c "
              ," where c.atddat between '",l_data_inicio,"' and '", l_data_fim ,"' "
               ," and c.ciaempcod = 35 "
               ," and c.atdsrvorg <= 7 "

  prepare pbdbsr400029 from l_sql
  declare cbdbsr400029 cursor for pbdbsr400029

  let l_sql = "select a.socopgnum, "
                 ," a.socfatpgtdat, "
                 ," b.socopgitmnum "
                 ," from dbsmopg a, dbsmopgitm b"
                 ," where a.soctip = 1 "
                 ," and a.socopgnum = b.socopgnum "
                 ," and b.atdsrvnum = ? "
                 ," and b.atdsrvano = ? "

  prepare pbdbsr400030 from l_sql
  declare cbdbsr400030 cursor for pbdbsr400030

  let l_sql = "select atdetpdes from datketapa ",
        " where atdetpcod = ?"
  prepare pbdbsr400031 from l_sql
  declare cbdbsr400031 cursor for pbdbsr400031
end  function

#-------------------#
 function bdbsr400()
#-------------------#

    define lr_dados record
            atdsrvnum      like datmservico.atdsrvnum,
            atdsrvano      like datmservico.atdsrvano,
            atdsrvorg      like datmservico.atdsrvorg,
            srvtipdes      like datksrvtip.srvtipdes,
            asitipcod      like datmservico.asitipcod,
            atdetpcod      like datmservico.atdetpcod,
            succod         like datrservapol.succod,
            aplnumdig      like datrservapol.aplnumdig,
            segnom         like gsakseg.segnom,
            cornom         like gcakcorr.cornom,
            vcldes         like datmservico.vcldes,
            vcllicnum      like datmservico.vcllicnum,
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
            ramcod         like datrservapol.ramcod,
            edsnumref      like datrligapol.edsnumref,
            vclanomdl      like datmservico.vclanomdl, 
            corsus2        like datmservico.corsus,
            atddat         like datmservico.atddat
    end record

    define l_doc_handle     integer
    define l_qtd_end, l_ind smallint
    define l_aux_char       char(500)
    define l_clscod         like aackcls.clscod
    define l_grlchv         like datkgeral.grlchv
    define l_tipo           smallint
    define l_cont           integer
    define l_descricao      char(50)
    define l_aux_cls400     char(2)

    define la_clausula array[20] of record
            clscod like aackcls.clscod,
            clsdes like aackcls.clsdes
    end record

    define lr_km       record
            kmlimite smallint,
            qtde     integer
    end record

    define l_length smallint
    define l_contador integer

    initialize la_clausula,
               l_aux_char,
               l_ind,
               l_qtd_end,
               l_grlchv,
               l_tipo,
               l_descricao,
               l_doc_handle,
               l_aux_cls400 to null

    initialize lr_dados.* to null

    start report bdbsr400_relatorio to m_path
    start report bdbsr400_relatorio_txt to m_path_txt #--> RELTXT

    let l_contador = 0

    open cbdbsr400001
    foreach cbdbsr400001 into lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.atdsrvorg,
                              lr_dados.asitipcod,
                              lr_dados.atdetpcod,
                              lr_dados.cornom,
                              lr_dados.vcldesatend,
                              lr_dados.vcllicnumatend,
                              lr_dados.socopgnum,
                              lr_dados.socfatpgtdat,
                              lr_dados.socopgitmnum,
                              lr_dados.vclanomdl,
                              lr_dados.corsus2,
			                        lr_dados.atddat 
                              
       ############ ligia retirar isso, foi so pra testes shell eventual
       let l_contador = l_contador + 1
       if l_contador > 500 then
	  exit foreach
       end if
       ########## retirar ate aqui ######

       open cbdbsr400002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400002 into lr_dados.succod, lr_dados.aplnumdig,
                               lr_dados.itmnumdig,lr_dados.ramcod,
                               lr_dados.edsnumref
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400002
       
       display "lr_dados.atdsrvnum:      ",  lr_dados.atdsrvnum        
       display "lr_dados.atdsrvano:      ",  lr_dados.atdsrvano        
       display "lr_dados.atdsrvorg:      ",  lr_dados.atdsrvorg        
       display "lr_dados.socopgnum:      ",  lr_dados.socopgnum      
       display "lr_dados.socfatpgtdat:   ",  lr_dados.socfatpgtdat  

       open cbdbsr400003 using lr_dados.succod, lr_dados.ramcod,
                               lr_dados.aplnumdig,
                               lr_dados.itmnumdig,lr_dados.edsnumref

       whenever error continue
       fetch cbdbsr400003 into lr_dados.segnom
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400003

       open cbdbsr400004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400004 into lr_dados.c24astcod, lr_dados.c24solnom, lr_dados.c24soltip
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400004

       #Trata nome do solicitante, retirando possiveis pipes, que prejudicam a validacao
       # dos valores do relatório

       let l_length = length(lr_dados.c24solnom)
       for l_ind = 1 to l_length
           if lr_dados.c24solnom[l_ind] = "|" then
              let lr_dados.c24solnom[l_ind] = " "
           end if
       end for

       open cbdbsr400005 using lr_dados.atdsrvorg
       whenever error continue
       fetch cbdbsr400005 into lr_dados.srvtipdes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400005

       open cbdbsr400006 using lr_dados.asitipcod
       whenever error continue
       fetch cbdbsr400006 into lr_dados.asitipdes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400006

       open cbdbsr400007 using lr_dados.atdsrvnum, lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400007 into lr_dados.c24pbmdes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400007

       open cbdbsr400008 using lr_dados.atdsrvnum, lr_dados.atdsrvano,
                               lr_dados.atdetpcod
       whenever error continue
       fetch cbdbsr400008 into lr_dados.atdetpdat, lr_dados.srrcoddig,
                               lr_dados.atdvclsgl, lr_dados.socvclcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400008

       if lr_dados.atdvclsgl is null or lr_dados.atdvclsgl = 0 then
         if lr_dados.socvclcod is not null and lr_dados.socvclcod <> 0 then
           open cbdbsr400026 using lr_dados.socvclcod
           whenever error continue
             fetch cbdbsr400026 into lr_dados.atdvclsgl
           whenever error stop
           if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400026 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
             end if
           end if
           close cbdbsr400026
         end if
       end if

       #Identificando cidade e uf da ocorrencia  -- c24endtip = 1
       let l_tipo = 1
       open cbdbsr400009 using lr_dados.atdsrvnum, lr_dados.atdsrvano,
       l_tipo
       whenever error continue
       fetch cbdbsr400009 into lr_dados.cidnom, lr_dados.ufdcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400009

       #Identificando cidade e uf do destino  -- c24endtip = 2

       let l_tipo = 2
       open cbdbsr400009 using lr_dados.atdsrvnum, lr_dados.atdsrvano,
       l_tipo
       whenever error continue
       fetch cbdbsr400009 into lr_dados.cidcoddes, lr_dados.ufdcodes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400009

       open cbdbsr400011 using lr_dados.socopgnum
       whenever error continue
       fetch cbdbsr400011 into lr_dados.pstcoddig, lr_dados.nomrazsoc
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400011

       if  lr_dados.srrcoddig is null or lr_dados.srrcoddig = 0 then
           let lr_dados.srrnom = " "
       else
           open cbdbsr400012 using lr_dados.srrcoddig
           whenever error continue
           fetch cbdbsr400012 into lr_dados.srrnom
           whenever error stop
           if  sqlca.sqlcode <> 0 then
               if  sqlca.sqlcode <> notfound then
                   display "Erro SELECT cbdbsr400012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                   exit program(1)
               end if
           end if
           close cbdbsr400012
       end if

       open cbdbsr400013 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400013 into lr_dados.socopgitmvlr
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400013 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400013

       #Identificando custos - Km Excedente --soccstcod = 3
       let l_tipo = 3
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod3,
                               lr_dados.socopgitmcst3,
                               lr_dados.cstqtd3
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       #Identificando custos - Hora Parada  -- soccstcod = 4
       let l_tipo = 4
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod4,
                               lr_dados.socopgitmcst4,
                               lr_dados.cstqtd4
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       #Identificando custos - Hora Trabalhada -- soccstcod = 5
       let l_tipo = 5
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano, l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod5,
                               lr_dados.socopgitmcst5,
                               lr_dados.cstqtd5
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400018 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       #Identificando  custos - Pedagio   -- soccstcod = 18
       let l_tipo = 18
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano, l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod18,
                               lr_dados.socopgitmcst18,
                               lr_dados.cstqtd18
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       open cbdbsr400020 using lr_dados.cidnom, lr_dados.ufdcod
       whenever error continue
       fetch cbdbsr400020 into lr_dados.cidcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400020 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400020

       open cbdbsr400021 using lr_dados.cidcod
       whenever error continue
       fetch cbdbsr400021 into lr_dados.cidsedcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400021

       open cbdbsr400022 using lr_dados.cidsedcod, lr_dados.ufdcod
       whenever error continue
       fetch cbdbsr400022 into lr_dados.cidsedcod, lr_dados.cidnomsed
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400022

       ##Identificando custos - Adicionais
       let l_tipo = 6
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod6,
                               lr_dados.socopgitmcst6,
                               lr_dados.cstqtd6
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       open cbdbsr400024 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano, lr_dados.socopgnum
       whenever error continue
       fetch cbdbsr400024 into lr_dados.soma
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400024 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400024

       let int_flag = false
       let l_cont   = 0
       call figrc011_inicio_parse()
       
       display "lr_dados.atdsrvnum:      ",  lr_dados.atdsrvnum        
       display "lr_dados.atdsrvano:      ",  lr_dados.atdsrvano        
       display "lr_dados.succod    ",  lr_dados.succod      
       display "lr_dados.ramcod    ",  lr_dados.ramcod      
       display "lr_dados.aplnumdig  ", lr_dados.aplnumdig     
       display "lr_dados.itmnumdig  ", lr_dados.itmnumdig
       
     if lr_dados.succod  is not null and
        lr_dados.aplnumdig is not null then
        

       #CLAUSULAS DA APOLICE
       call bdbsr400_dados_apolice(lr_dados.succod,
                                   lr_dados.ramcod,
                                   lr_dados.aplnumdig,
                                   lr_dados.itmnumdig)
                         returning lr_dados.aplnumdig,
                                   lr_dados.itmnumdig,
                                   lr_dados.edsnumref2,
                                   lr_dados.succod,
                                   lr_dados.ramcod2,
                                   lr_dados.emsdat,
                                   lr_dados.viginc,
                                   lr_dados.vigfnl,
                                   lr_dados.segcod,
                                   lr_dados.segnom,
                                   lr_dados.vcldes,
                                   lr_dados.corsus,
                                   lr_dados.doc_handle,
                                   lr_dados.resultado,
                                   lr_dados.mensagem,
                                   lr_dados.situacao
       let l_doc_handle = lr_dados.doc_handle
       let l_qtd_end = figrc011_xpath(l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")
       
      # display "l_qtd_end: ",l_qtd_end
       
       if l_qtd_end is not null and l_qtd_end > 0 then
          for l_ind = 1 to l_qtd_end
             let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
                        #display "l_aux_char: ",l_aux_char clipped
             let la_clausula[l_ind].clscod = figrc011_xpath(l_doc_handle,l_aux_char)
             let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&", "]/DESCRICAO"
                     #display "clausula que vem do XML la_clausula[l_ind].clscod: ",la_clausula[l_ind].clscod clipped
             if la_clausula[l_ind].clscod = "037" then
                call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_DESCRICAO')
                     returning l_descricao
                         #display "l_descricao: ",l_descricao clipped
                if l_descricao is not null and
                   l_descricao <> " "      then
          
                   case l_descricao
                      when "ASSISTENCIA PLUS II"
                         let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA PLUSII"
                         let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "SEM ASSISTENCIA"
                         let la_clausula[l_ind].clsdes = 'SEM ASSISTENCIA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA REDE REFERENCIADA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIAREDE REFERENCIADA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA REDEREFERENCIADA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA LIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIALIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA LIVREESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA PLUS II - LIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIAPLUS II - LIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA PLUSII - LIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA PLUS II- LIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA PLUS II -LIVRE ESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
                      when "ASSISTENCIA PLUS II - LIVREESCOLHA"
                         let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let lr_dados.clausulades = la_clausula[l_ind].clsdes
          
          
                      otherwise
                         let lr_dados.clausula    = la_clausula[l_ind].clscod
                         let la_clausula[l_ind].clsdes = "** DESCRICAO NAO CADASTRADA **"
                   end case
                end if
             end if
             
          let l_aux_cls400 = la_clausula[l_ind].clscod
          ---> Busca Descricao da clausula no cadastro
              if la_clausula[1].clscod is null then
                let la_clausula[l_ind].clsdes = "NENHUMA CLAUSULA  ***"
                let lr_dados.clausula    = la_clausula[l_ind].clscod
                let lr_dados.clausulades = la_clausula[l_ind].clsdes
              else
                 if l_aux_cls400 = '37' then
                    let l_grlchv = "CLS.AZUL.", la_clausula[l_ind].clscod
                    select grlinf
                      into la_clausula[l_ind].clsdes
                      from datkgeral
                     where grlchv = l_grlchv
             
                  if sqlca.sqlcode = notfound then
                       if la_clausula[l_ind].clsdes is null then
                          let la_clausula[l_ind].clsdes = "** NAO CADASTRADA **"
                       end if
                   end if
                       let lr_dados.clausula    = la_clausula[l_ind].clscod
                       let lr_dados.clausulades = la_clausula[l_ind].clsdes
           
                   end if
                 end if
              end for
           end if 
       else
          let mr_bdbsr400.resultado = 3
          let mr_bdbsr400.mensagem  = "Parametros nulos"
       end if
       #FIM CLAUSULAS DA APOLICE

            call figrc011_fim_parse()

            #FIM CLAUSULAS DA APOLICE

       open cbdbsr400025 using lr_dados.succod, lr_dados.ramcod,
                               lr_dados.aplnumdig,
                               lr_dados.itmnumdig,lr_dados.edsnumref
       whenever error continue
       fetch cbdbsr400025 into lr_dados.vcllicnum
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400025 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400025

       #Identificando custos - Hospedagem -- soccstcod = 22
       let l_tipo = 22
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod22,
                               lr_dados.socopgitmcst22,
                               lr_dados.cstqtd22
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       let lr_dados.soma = lr_dados.soma + lr_dados.socopgitmvlr

       output to report bdbsr400_relatorio(lr_dados.atdsrvnum,
                                           lr_dados.atdsrvano,
                                           lr_dados.atdsrvorg,
                                           lr_dados.srvtipdes,
                                           lr_dados.asitipcod,
                                           lr_dados.atdetpcod,
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
                                           lr_dados.soma,
                                           lr_dados.clausula,
                                           lr_dados.clausulades,
                                           lr_dados.vclanomdl, 
                                           lr_dados.corsus2,
                                           lr_dados.atddat    )

       #--> RELTXT (inicio)
       output to report bdbsr400_relatorio_txt(lr_dados.atdsrvnum,
                                           lr_dados.atdsrvano,
                                           lr_dados.atdsrvorg,
                                           lr_dados.srvtipdes,
                                           lr_dados.asitipcod,
                                           lr_dados.atdetpcod,
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
                                           lr_dados.soma,
                                           lr_dados.clausula,
                                           lr_dados.clausulades,
                                           lr_dados.vclanomdl, 
                                           lr_dados.corsus2,
                                           lr_dados.atddat    )
       #--> RELTXT (final) 

       initialize lr_dados.*, l_aux_cls400 to null

    end foreach
    close cbdbsr400001

    finish report bdbsr400_relatorio
    finish report bdbsr400_relatorio_txt #--> RELTXT

    call bdbsr400_B()

 end function

#-------------------#
 function bdbsr400_B()
#-------------------#

    define lr_dados record
            atdsrvnum      like datmservico.atdsrvnum,
            atdsrvano      like datmservico.atdsrvano,
            atdsrvorg      like datmservico.atdsrvorg,
            srvtipdes      like datksrvtip.srvtipdes,
            asitipcod      like datmservico.asitipcod,
            atdetpcod      like datmservico.atdetpcod,
            succod         like datrservapol.succod,
            aplnumdig      like datrservapol.aplnumdig,
            segnom         like gsakseg.segnom,
            cornom         like gcakcorr.cornom,
            vcldes         like datmservico.vcldes,
            vcllicnum      like datmservico.vcllicnum,
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
            ramcod         like datrservapol.ramcod,
            edsnumref      like datrligapol.edsnumref,
            vclanomdl      like datmservico.vclanomdl ,
            corsus2        like datmservico.corsus,   
            atddat         like datmservico.atddat #--> FX-080515
    end record

    define l_doc_handle     integer
    define l_qtd_end, l_ind smallint
    define l_aux_char       char(500)
    define l_clscod         like aackcls.clscod
    define l_grlchv         like datkgeral.grlchv
    define l_tipo           smallint
    define l_cont           integer
    define l_descricao      char(50)
    define l_aux_cls400b    char(2)

    define la_clausula array[20] of record
            clscod like aackcls.clscod,
            clsdes like aackcls.clsdes
    end record

    define lr_km       record
            kmlimite smallint,
            qtde     integer
    end record

    define l_length smallint
    define l_contador integer

    initialize la_clausula,
               l_aux_char,
               l_ind,
               l_qtd_end,
               l_grlchv,
	       l_tipo, 
	       l_descricao, 
               l_doc_handle,
               l_aux_cls400b to null

    initialize lr_dados.* to null

    start report bdbsr400_relatorio to m_path_b
    start report bdbsr400_relatorio_txt to m_path_b_txt #--> RELTXT

    let l_contador = 0

    open cbdbsr400029
    foreach cbdbsr400029 into lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.atdsrvorg,
                              lr_dados.asitipcod,
                              lr_dados.atdetpcod,
                              lr_dados.cornom,
                              lr_dados.vcldesatend,
                              lr_dados.vcllicnumatend,
                              lr_dados.vclanomdl,
                              lr_dados.corsus2,
			                        lr_dados.atddat #--> FX-080515
       open cbdbsr400030 using  lr_dados.atdsrvnum, lr_dados.atdsrvano

       whenever error continue
       fetch cbdbsr400030 into  lr_dados.socopgnum,
                                lr_dados.socfatpgtdat,
                                lr_dados.socopgitmnum
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400030 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if

          let lr_dados.socopgnum = 0
          let lr_dados.socfatpgtdat = null
          let lr_dados.socopgnum = 0
       end if
       close cbdbsr400030

       open cbdbsr400002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
       fetch cbdbsr400002 into lr_dados.succod, lr_dados.aplnumdig, lr_dados.itmnumdig,lr_dados.ramcod,lr_dados.edsnumref
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400002

       open cbdbsr400003 using lr_dados.succod, lr_dados.ramcod,
                               lr_dados.aplnumdig,
                               lr_dados.itmnumdig,lr_dados.edsnumref

       whenever error continue
       fetch cbdbsr400003 into lr_dados.segnom
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400003

       open cbdbsr400004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400004 into lr_dados.c24astcod, lr_dados.c24solnom, lr_dados.c24soltip
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400004

       #Trata nome do solicitante, retirando possiveis pipes, que prejudicam a validacao
       # dos valores do relatório

       let l_length = length(lr_dados.c24solnom)
       for l_ind = 1 to l_length
          if lr_dados.c24solnom[l_ind] = "|" then
             let lr_dados.c24solnom[l_ind] = " "
          end if
       end for

       open cbdbsr400005 using lr_dados.atdsrvorg
       whenever error continue
       fetch cbdbsr400005 into lr_dados.srvtipdes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400005

       open cbdbsr400006 using lr_dados.asitipcod
       whenever error continue
       fetch cbdbsr400006 into lr_dados.asitipdes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400006

       open cbdbsr400007 using lr_dados.atdsrvnum, lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400007 into lr_dados.c24pbmdes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400007

       open cbdbsr400008 using lr_dados.atdsrvnum, lr_dados.atdsrvano, lr_dados.atdetpcod
       whenever error continue
       fetch cbdbsr400008 into lr_dados.atdetpdat, lr_dados.srrcoddig, lr_dados.atdvclsgl, lr_dados.socvclcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400008

       if lr_dados.atdvclsgl is null or lr_dados.atdvclsgl = 0 then
          if lr_dados.socvclcod is not null and lr_dados.socvclcod <> 0 then
             open cbdbsr400026 using lr_dados.socvclcod
             whenever error continue
             fetch cbdbsr400026 into lr_dados.atdvclsgl
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> notfound then
                   display "Erro SELECT cbdbsr400026 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                   exit program(1)
                end if
             end if
             close cbdbsr400026
          end if
       end if

       #Identificando cidade e uf da ocorrencia  -- c24endtip = 1

       let l_tipo = 1
       open cbdbsr400009 using lr_dados.atdsrvnum, lr_dados.atdsrvano,
       l_tipo
       whenever error continue
       fetch cbdbsr400009 into lr_dados.cidnom, lr_dados.ufdcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400009

       #Identificando cidade e uf do destino  -- c24endtip = 2

       let l_tipo = 2
       open cbdbsr400009 using lr_dados.atdsrvnum, lr_dados.atdsrvano,
       l_tipo
       whenever error continue
       fetch cbdbsr400009 into lr_dados.cidcoddes, lr_dados.ufdcodes
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400009

       open cbdbsr400011 using lr_dados.socopgnum
       whenever error continue
       fetch cbdbsr400011 into lr_dados.pstcoddig, lr_dados.nomrazsoc
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400011

       if  lr_dados.srrcoddig is null or lr_dados.srrcoddig = 0 then
           let lr_dados.srrnom = " "
       else
           open cbdbsr400012 using lr_dados.srrcoddig
           whenever error continue
           fetch cbdbsr400012 into lr_dados.srrnom
           whenever error stop
           if  sqlca.sqlcode <> 0 then
               if  sqlca.sqlcode <> notfound then
                   display "Erro SELECT cbdbsr400012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                   exit program(1)
               end if
           end if
           close cbdbsr400012
       end if

       open cbdbsr400013 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano
       whenever error continue
       fetch cbdbsr400013 into lr_dados.socopgitmvlr
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400013 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400013

       #Identificando custos - Km Excedente --soccstcod = 3
       let l_tipo = 3
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod3,
                               lr_dados.socopgitmcst3,
                               lr_dados.cstqtd3
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       #Identificando custos - Hora Parada  -- soccstcod = 4
       let l_tipo = 4
       open cbdbsr400016 using lr_dados.socopgnum, 
                               lr_dados.atdsrvnum,
                               lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod4,
                               lr_dados.socopgitmcst4,
                               lr_dados.cstqtd4
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400016

       #Identificando custos - Hora Trabalhada -- soccstcod = 5
       let l_tipo = 5
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano, l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod5,
                               lr_dados.socopgitmcst5,
                               lr_dados.cstqtd5
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400018 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400016

       #Identificando  custos - Pedagio   -- soccstcod = 18
       let l_tipo = 18
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano, l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod18,
                               lr_dados.socopgitmcst18,
                               lr_dados.cstqtd18
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400016

       open cbdbsr400020 using lr_dados.cidnom, lr_dados.ufdcod
       whenever error continue
       fetch cbdbsr400020 into lr_dados.cidcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400020 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400020

       open cbdbsr400021 using lr_dados.cidcod
       whenever error continue
       fetch cbdbsr400021 into lr_dados.cidsedcod
       whenever error stop
       if  sqlca.sqlcode <> 0 then
           if  sqlca.sqlcode <> notfound then
               display "Erro SELECT cbdbsr400021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               exit program(1)
           end if
       end if
       close cbdbsr400021

       open cbdbsr400022 using lr_dados.cidsedcod, lr_dados.ufdcod
       whenever error continue
       fetch cbdbsr400022 into lr_dados.cidsedcod, lr_dados.cidnomsed
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400022

       ##Identificando custos - Adicionais
       let l_tipo = 6
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod6,
                               lr_dados.socopgitmcst6,
                               lr_dados.cstqtd6
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400016

       open cbdbsr400024 using lr_dados.socopgnum, lr_dados.atdsrvnum, lr_dados.atdsrvano, lr_dados.socopgnum
       whenever error continue
       fetch cbdbsr400024 into lr_dados.soma
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400024 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400024

       let int_flag = false
       let l_cont   = 0
       call figrc011_inicio_parse()
       
       display "lr_dados.atdsrvnum:      ",  lr_dados.atdsrvnum        
       display "lr_dados.atdsrvano:      ",  lr_dados.atdsrvano        
       display "lr_dados.succod    ",  lr_dados.succod      
       display "lr_dados.ramcod    ",  lr_dados.ramcod      
       display "lr_dados.aplnumdig  ", lr_dados.aplnumdig     
       display "lr_dados.itmnumdig  ", lr_dados.itmnumdig
       
     if lr_dados.succod  is not null and
        lr_dados.aplnumdig is not null then
        

           #CLAUSULAS DA APOLICE
           call bdbsr400_dados_apolice(lr_dados.succod,
                                       lr_dados.ramcod,
                                       lr_dados.aplnumdig,
                                       lr_dados.itmnumdig)
                             returning lr_dados.aplnumdig,
                                       lr_dados.itmnumdig,
                                       lr_dados.edsnumref2,
                                       lr_dados.succod,
                                       lr_dados.ramcod2,
                                       lr_dados.emsdat,
                                       lr_dados.viginc,
                                       lr_dados.vigfnl,
                                       lr_dados.segcod,
                                       lr_dados.segnom,
                                       lr_dados.vcldes,
                                       lr_dados.corsus,
                                       lr_dados.doc_handle,
                                       lr_dados.resultado,
                                       lr_dados.mensagem,
                                       lr_dados.situacao
           
           let l_doc_handle = lr_dados.doc_handle
           let l_qtd_end = figrc011_xpath(l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")
           
           if l_qtd_end is not null and l_qtd_end > 0 then  
              for l_ind = 1 to l_qtd_end
                 let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
              
                 let la_clausula[l_ind].clscod = figrc011_xpath(l_doc_handle,l_aux_char)
                 let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&", "]/DESCRICAO"
              
              
                 if la_clausula[l_ind].clscod = "037" then
              
                    call cts40g02_extraiDoXML(l_doc_handle, 'ASSISTENCIA_DESCRICAO')
                                    returning l_descricao
              
                    if l_descricao is not null and
                       l_descricao <> " "      then
              
                       case l_descricao
                          when "ASSISTENCIA PLUS II"
                             let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA PLUSII"
                             let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "SEM ASSISTENCIA"
                             let la_clausula[l_ind].clsdes = 'SEM ASSISTENCIA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA REDE REFERENCIADA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIAREDE REFERENCIADA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA REDEREFERENCIADA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA LIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIALIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA LIVREESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA PLUS II - LIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIAPLUS II - LIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA PLUSII - LIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA PLUS II- LIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA PLUS II -LIVRE ESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          when "ASSISTENCIA PLUS II - LIVREESCOLHA"
                             let la_clausula[l_ind].clsdes = 'ASSIST.24hrs-LIVRE ESCOLHA'
                             let lr_dados.clausula    = la_clausula[l_ind].clscod
                             let lr_dados.clausulades = la_clausula[l_ind].clsdes
              
                          otherwise 
                             let lr_dados.clausula    = la_clausula[l_ind].clscod  
                             let la_clausula[l_ind].clsdes = "** DESCRICAO NAO CADASTRADA **"
                       end case
                    end if
                 end if
              
              let l_aux_cls400b = la_clausula[l_ind].clscod
              
              
                 ---> Busca Descricao da clausula no cadastro
                  if la_clausula[1].clscod is null then
                    let la_clausula[l_ind].clsdes = "NENHUMA CLAUSULA  ***"
                    let lr_dados.clausula    = la_clausula[l_ind].clscod
                    let lr_dados.clausulades = la_clausula[l_ind].clsdes
                  else
                     if l_aux_cls400b = '37' then
                    
                        let l_grlchv = "CLS.AZUL.", la_clausula[l_ind].clscod
                        select grlinf
                          into la_clausula[l_ind].clsdes
                          from datkgeral
                         where grlchv = l_grlchv
                 
                        if sqlca.sqlcode = notfound then
                           if la_clausula[l_ind].clsdes is null then
                              let la_clausula[l_ind].clsdes = "** NAO CADASTRADA **"
                           end if
                       end if
                       
                       let lr_dados.clausula    = la_clausula[l_ind].clscod
                       let lr_dados.clausulades = la_clausula[l_ind].clsdes
           
                   end if
                 end if
              end for
           end if 
       else
         let mr_bdbsr400.resultado = 3
         let mr_bdbsr400.mensagem  = "Parametros nulos"
       end if
       #FIM CLAUSULAS DA APOLICE

       # Finaliza o parse para liberar a memoria da maquina.
       call figrc011_fim_parse()

       open cbdbsr400025 using lr_dados.succod, lr_dados.ramcod,
                               lr_dados.aplnumdig,
                               lr_dados.itmnumdig,lr_dados.edsnumref
       whenever error continue
       fetch cbdbsr400025 into lr_dados.vcllicnum
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400025 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400025

       #Identificando custos - Hospedagem -- soccstcod = 22
       let l_tipo = 22
       open cbdbsr400016 using lr_dados.socopgnum, lr_dados.atdsrvnum,
       lr_dados.atdsrvano,l_tipo
       whenever error continue
       fetch cbdbsr400016 into lr_dados.soccstcod22,
                               lr_dados.socopgitmcst22,
                               lr_dados.cstqtd22
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display "Erro SELECT cbdbsr400016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             exit program(1)
          end if
       end if
       close cbdbsr400016

       let lr_dados.soma = lr_dados.soma + lr_dados.socopgitmvlr

       output to report bdbsr400_relatorio(lr_dados.atdsrvnum,
                                           lr_dados.atdsrvano,
                                           lr_dados.atdsrvorg,
                                           lr_dados.srvtipdes,
                                           lr_dados.asitipcod,
                                           lr_dados.atdetpcod,
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
                                           lr_dados.soma,
                                           lr_dados.clausula,
                                           lr_dados.clausulades,
                                           lr_dados.vclanomdl,
                                           lr_dados.corsus2,
					                                 lr_dados.atddat) #--> FX-080515    


       #--> RELTXT (inicio)
       output to report bdbsr400_relatorio_txt(lr_dados.atdsrvnum,          
                                               lr_dados.atdsrvano,         
                                               lr_dados.atdsrvorg,         
                                               lr_dados.srvtipdes,         
                                               lr_dados.asitipcod,         
                                               lr_dados.atdetpcod,         
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
                                               lr_dados.soma,              
                                               lr_dados.clausula,          
                                               lr_dados.clausulades,       
                                               lr_dados.vclanomdl,         
                                               lr_dados.corsus2,           
					                                     lr_dados.atddat) #--> FX-080515                           
       #--> RELTXT (final) 

       initialize lr_dados.*, l_aux_cls400b to null

    end foreach
    close cbdbsr400029

    finish report bdbsr400_relatorio
    finish report bdbsr400_relatorio_txt #--> RELTXT
    
    # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
    # pois a nova funcao nao retorna o erro, ela aborta o programa
    whenever error continue
    call bdbsr400_envia_email()
    whenever error stop
   
 end function


#-------------------------------#
 function bdbsr400_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
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
   let l_assunto    = "Relatorio de Servicos Pagos em ", l_mes_extenso clipped, " - Azul Seguros BDBSR400 disponivel na APLTRANSM"

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"
   let m_path = null #fornax abr/16

   #let l_anexo = m_path clipped, ",", m_path_b clipped

{#ligia retirar isso so pra testes

   let l_erro_envio = ctx22g00_envia_email("BDBSR400", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR400"
       end if
   end if

   let l_assunto    = "Relatorio de Servicos Pagos em ", l_mes_extenso clipped, " - Azul Seguros BDBSR400B disponivel na APLTRANSM"

   let l_comando = "gzip -f ", m_path_b
   run l_comando
   let m_path_b = m_path_b clipped, ".gz"
   let m_path_b = null #fornax abr/16

   let l_erro_envio = ctx22g00_envia_email("BDBSR400", l_assunto, m_path_b)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path_b clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR400"
       end if
   end if
} ##ligia retirar aqui, foi so testes


end function

#---------------------------------------#
 report bdbsr400_relatorio(lr_parametro)
#---------------------------------------#

   define lr_parametro record
           atdsrvnum        like datmservico.atdsrvnum,
           atdsrvano        like datmservico.atdsrvano,
           atdsrvorg        like datmservico.atdsrvorg,
           srvtipdes        like datksrvtip.srvtipdes,
           asitipcod        like datmservico.asitipcod,
           atdetpcod	      like datmservico.atdetpcod,
           succod           like datrservapol.succod,
           aplnumdig        like datrservapol.aplnumdig,
           segnom           like gsakseg.segnom,
           c24soltip        like datmligacao.c24soltip,
           c24solnom        like datmligacao.c24solnom,
           cornom           like gcakcorr.cornom,
           vcldes           like datmservico.vcldes,
           vcllicnum        like datkazlapl.vcllicnum,
           vcldesatend      like datmservico.vcldes,
           vcllicnumatend   like datmservico.vcllicnum,
           c24astcod        like datmligacao.c24astcod,
           cpodes           like iddkdominio.cpodes,
           asitipdes        like datkasitip.asitipdes,
           c24pbmdes        like datrsrvpbm.c24pbmdes,
           atdetpdat        like datmsrvacp.atdetpdat,
           atdvclsgl        like datmsrvacp.atdvclsgl,
           srrcoddig        like datmsrvacp.srrcoddig,
           cidsedcod        like datrcidsed.cidsedcod,
           cidnomsed        like glakcid.cidnom,
           cidnom           like datmlcl.cidnom,
           ufdcod           like datmlcl.ufdcod,
           cidcoddes        like datmlcl.cidnom,
           ufdcodes         like datmlcl.ufdcod,
           pstcoddig        like datmsrvacp.pstcoddig,
           nomrazsoc        like dpaksocor.nomrazsoc,
           srrnom           like datksrr.srrnom,
           socopgnum        like dbsmopgitm.socopgnum,
           socfatpgtdat     like dbsmopg.socfatpgtdat,
           socopgitmvlr     decimal(15,2), #like dbsmopgitm.socopgitmvlr,
           socopgitmcst3    decimal(15,2), # like dbsmopgcst.socopgitmcst,
           cstqtd3          smallint, # like dbsmopgcst.cstqtd,
           socopgitmcst4    decimal(15,2), # like dbsmopgcst.socopgitmcst,
           cstqtd4          smallint, # like dbsmopgcst.cstqtd,
           socopgitmcst5    decimal(15,2), # like dbsmopgcst.socopgitmcst,
           cstqtd5          smallint, # like dbsmopgcst.cstqtd,
           socopgitmcst18   decimal(15,2), # like dbsmopgcst.socopgitmcst,
           cstqtd18         smallint, # like dbsmopgcst.cstqtd,
           socopgitmcst6    decimal(15,2), # like dbsmopgcst.socopgitmcst,
           cstqtd6          smallint, # like dbsmopgcst.cstqtd,
           socopgitmcst22   decimal(15,2), # like dbsmopgcst.socopgitmcst,
           cstqtd22         smallint, # like dbsmopgcst.cstqtd,
           soma             decimal(15,2),
           clausula         char(03),
           clausulades      char(50),
           vclanomdl        like datmservico.vclanomdl , 
           corsus2          like datmservico.corsus,
	         atddat           like datmservico.atddat #--> FX-080515 
   end record

   define l_atdetpdat,
   	  l_atdetpdes,
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
           print "SUCURSAL",                                   ASCII(09),
                 "APOLICE",                                    ASCII(09),
                 "SEGURADO",                                   ASCII(09),
                 "TIPO PESSOA LIGACAO",                        ASCII(09),
                 "NOME PESSOA LIGACAO",                        ASCII(09),
                 "CORRETOR",                                   ASCII(09),
                 "VEICULO SEGURADO",                           ASCII(09),
                 "PLACA VEICULO SEGURADO",                     ASCII(09),
                 "VEICULO ATENDIDO",                           ASCII(09),
                 "PLACA VEICULO ATENDIDO",                     ASCII(09),
                 "ASSUNTO",                                    ASCII(09),
                 "ORIGEM SERVICO",                             ASCII(09),
                 "SERVICO",                                    ASCII(09),
                 "ANO SERVICO",                                ASCII(09),
                 "TIPO SERVICO",                               ASCII(09),
                 "TIPO ASSISTENCIA",                           ASCII(09),
                 "PROBLEMA APRESENTADO",                       ASCII(09),
                 "ETAPA DO SERVICO",			                     ASCII(09),
                 "DATA DE ACIONAMENTO",                        ASCII(09),
                 "CODIGO CIDADE SEDE",                         ASCII(09),
                 "CIDADE SEDE DA OCORRENCIA",                  ASCII(09),
                 "CIDADE DA OCORRENCIA",                       ASCII(09),
                 "UF DA OCORRENCIA",                           ASCII(09),
                 "CIDADE DE DESTINO",                          ASCII(09),
                 "UF DE DESTINO",                              ASCII(09),
                 "CODIGO PRESTADOR",                           ASCII(09),
                 "NOME PRESTADOR",                             ASCII(09),
                 "SIGLA VIATURA",                              ASCII(09),
                 "NUMERO QRA",                                 ASCII(09),
                 "NOME QRA",                                   ASCII(09),
                 "NUMERO DA OP",                               ASCII(09),
                 "DATA DE PAGAMENTO",                          ASCII(09),
                 "VALOR SAIDA",		                             ASCII(09),
                 "VALOR KM EXCEDENTE",                         ASCII(09),
                 "QUANTIDADE CUSTO KM EXCEDENTE",              ASCII(09),
                 "VALOR CUSTO HORA PARADA",                    ASCII(09),
                 "QUANTIDADE CUSTO HORA PARADA",               ASCII(09),
                 "VALOR CUSTO HORA TRABALHADA",                ASCII(09),
                 "QUANTIDADE CUSTO HORA TRABALHADA",           ASCII(09),
                 "VALOR CUSTO PEDAGIO",                        ASCII(09),
                 "QUANTIDADE CUSTO PEDAGIO",                   ASCII(09),
                 "VALOR CUSTO ADICIONAL",                      ASCII(09),
                 "QUANTIDADE CUSTO ADICIONAL",                 ASCII(09),
                  "VALOR CUSTO PASSAGEM AREA/HOSPEDAGEM", 		 ASCII(09),
                 "QUANTIDADE CUSTO PASSAGEM AREA/HOSPEDAGEM",  ASCII(09),
                 "VALOR TOTAL PAGO",                           ASCII(09),
                 "CLAUSULA",                                   ASCII(09),
                 "DESCRICAO",                                  ASCII(09),
                 "ANO_MODELO",                                 ASCII(09),
                 "SUSEP",                                      ASCII(09);

		 if lr_parametro.atddat is not null then #--> FX-080515
		    print "DATA ATENDIMENTO", ASCII(09); #--> FX-080515
		 end if                                  #--> FX-080515

                 skip 1 line    

       on every row

           let l_atdetpdat    = extend(lr_parametro.atdetpdat, year to year), "-",
                                extend(lr_parametro.atdetpdat, month to month), "-",
                                extend(lr_parametro.atdetpdat, day to day)

           let l_socfatpgtdat = extend(lr_parametro.socfatpgtdat, year to year), "-",
                                extend(lr_parametro.socfatpgtdat, month to month), "-",
                                extend(lr_parametro.socfatpgtdat, day to day)


     open cbdbsr400031 using lr_parametro.atdetpcod
     whenever error continue
      fetch cbdbsr400031 into l_atdetpdes
          close cbdbsr400031
     whenever error stop

           if  lr_parametro.succod is null or lr_parametro.succod = 0 then
               print "SUCURSAL NAO CADASTRADA", ASCII(09);
           else
               print lr_parametro.succod clipped,       ASCII(09);
           end if

           if  lr_parametro.aplnumdig is null or lr_parametro.aplnumdig = 0 then
               print "APOLICE NAO CADASTRADA",  ASCII(09);
           else
               print lr_parametro.aplnumdig clipped,    ASCII(09);
           end if

           if  lr_parametro.segnom is null or lr_parametro.segnom = " " then
               print "SEGURADO NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.segnom clipped,       ASCII(09);
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
               print lr_parametro.c24solnom clipped,    ASCII(09);
           end if

           if  lr_parametro.cornom is null or lr_parametro.cornom = " " then
               print "CORRETOR NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.cornom clipped,       ASCII(09);
           end if

           print lr_parametro.vcldes clipped,           ASCII(09),
                 lr_parametro.vcllicnum clipped,        ASCII(09),
                 lr_parametro.vcldesatend clipped,      ASCII(09),
                 lr_parametro.vcllicnumatend clipped,   ASCII(09),
                 lr_parametro.c24astcod clipped,        ASCII(09),
                 lr_parametro.atdsrvorg clipped,        ASCII(09),
                 lr_parametro.atdsrvnum clipped,        ASCII(09),
                 lr_parametro.atdsrvano clipped,        ASCII(09),
                 lr_parametro.srvtipdes clipped,        ASCII(09),
                 lr_parametro.asitipdes clipped,        ASCII(09),
                 lr_parametro.c24pbmdes clipped,        ASCII(09),
                 l_atdetpdes clipped,			ASCII(09),
                 l_atdetpdat clipped,                   ASCII(09),
                 lr_parametro.cidsedcod clipped,        ASCII(09),
                 lr_parametro.cidnomsed clipped,        ASCII(09),
                 lr_parametro.cidnom clipped,           ASCII(09),
                 lr_parametro.ufdcod clipped,           ASCII(09),
                 lr_parametro.cidcoddes clipped,        ASCII(09),
                 lr_parametro.ufdcodes clipped,         ASCII(09),
                 lr_parametro.pstcoddig clipped,        ASCII(09),
                 lr_parametro.nomrazsoc clipped,        ASCII(09),
                 lr_parametro.atdvclsgl clipped,        ASCII(09),
                 lr_parametro.srrcoddig clipped,        ASCII(09),
                 lr_parametro.srrnom clipped,           ASCII(09),
                 lr_parametro.socopgnum clipped,        ASCII(09),
                 l_socfatpgtdat clipped,                ASCII(09);


                 if lr_parametro.socopgitmvlr is null or lr_parametro.socopgitmvlr = 0 then
                  let lr_parametro.socopgitmvlr = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmvlr,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst3 is null or lr_parametro.socopgitmcst3 = 0 then
                  let lr_parametro.socopgitmcst3 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst3,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd3 is null or lr_parametro.cstqtd3 = 0 then
                  let lr_parametro.cstqtd3 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd3,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst4 is null or lr_parametro.socopgitmcst4 = 0 then
                  let lr_parametro.socopgitmcst4 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst4,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd4 is null or lr_parametro.cstqtd4 = 0 then
                  let lr_parametro.cstqtd4 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd4,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst5 is null or lr_parametro.socopgitmcst5 = 0 then
                  let lr_parametro.socopgitmcst5 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst5,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd5 is null or lr_parametro.cstqtd5 = 0 then
                  let lr_parametro.cstqtd5 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd5,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst18 is null  or lr_parametro.socopgitmcst18 = 0 then
                  let lr_parametro.socopgitmcst18 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst18,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd18 is null or lr_parametro.cstqtd18 = 0 then
                  let lr_parametro.cstqtd18 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd18,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst6 is null or lr_parametro.socopgitmcst6 = 0 then
                  let lr_parametro.socopgitmcst6 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst6,".",",") clipped, ASCII(09);

     if lr_parametro.cstqtd6 is null or lr_parametro.cstqtd6 = 0 then
                  let lr_parametro.cstqtd6 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd6,".",",") clipped, ASCII(09);

                  if lr_parametro.socopgitmcst22 is null or lr_parametro.socopgitmcst22 = 0 then
                  let lr_parametro.socopgitmcst22 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst22,".",",") clipped, ASCII(09);

     if lr_parametro.cstqtd22 is null or lr_parametro.cstqtd22 = 0 then
                  let lr_parametro.cstqtd22 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd22,".",",") clipped, ASCII(09);

           if  lr_parametro.soma is null or lr_parametro.soma = 0 then
               print figrc005_troca1byte(lr_parametro.socopgitmvlr,".",",")  clipped, ASCII(09);
           else
               print figrc005_troca1byte(lr_parametro.soma,".",",")  clipped,  ASCII(09);
           end if

           if  lr_parametro.clausula is null or lr_parametro.clausula = 0 then
               print " ",                       ASCII(09),
                     "SEM CLAUSULA CADASTRADA", ASCII(09);
           else
               print lr_parametro.clausula clipped,     ASCII(09),
                     lr_parametro.clausulades clipped,  ASCII(09);
           end if
           
           if lr_parametro.vclanomdl is null or lr_parametro.vclanomdl = 0 then
              print " ", ASCII(09);
           else
              print lr_parametro.vclanomdl clipped, ASCII(09);
           end if
           
           if lr_parametro.corsus2 is null or lr_parametro.corsus2 = 0 then
              print " ", ASCII(09);
           else
              print lr_parametro.corsus2 clipped, ASCII(09);
           end if

           if lr_parametro.atddat is not null then  #--> FX-080515
	            print lr_parametro.atddat, ASCII(09); #--> FX-080515
	         else
	            print " ", ASCII(09);
           end if                                   #--> FX-080515

           skip 1 line

 end report
 
#-------------------------------------------------------#
 report bdbsr400_relatorio_txt(lr_parametro) #--> RELTXT 
#-------------------------------------------------------#

   define lr_parametro record
           atdsrvnum        like datmservico.atdsrvnum,                           
           atdsrvano        like datmservico.atdsrvano,                           
           atdsrvorg        like datmservico.atdsrvorg,                           
           srvtipdes        like datksrvtip.srvtipdes,                            
           asitipcod        like datmservico.asitipcod,                           
           atdetpcod	      like datmservico.atdetpcod,                           
           succod           like datrservapol.succod,                             
           aplnumdig        like datrservapol.aplnumdig,                          
           segnom           like gsakseg.segnom,                                  
           c24soltip        like datmligacao.c24soltip,                           
           c24solnom        like datmligacao.c24solnom,                           
           cornom           like gcakcorr.cornom,                                 
           vcldes           like datmservico.vcldes,                              
           vcllicnum        like datkazlapl.vcllicnum,                            
           vcldesatend      like datmservico.vcldes,                              
           vcllicnumatend   like datmservico.vcllicnum,                           
           c24astcod        like datmligacao.c24astcod,                           
           cpodes           like iddkdominio.cpodes,                              
           asitipdes        like datkasitip.asitipdes,                            
           c24pbmdes        like datrsrvpbm.c24pbmdes,                            
           atdetpdat        like datmsrvacp.atdetpdat,                            
           atdvclsgl        like datmsrvacp.atdvclsgl,                            
           srrcoddig        like datmsrvacp.srrcoddig,                            
           cidsedcod        like datrcidsed.cidsedcod,                            
           cidnomsed        like glakcid.cidnom,                                  
           cidnom           like datmlcl.cidnom,                                  
           ufdcod           like datmlcl.ufdcod,                                  
           cidcoddes        like datmlcl.cidnom,                                  
           ufdcodes         like datmlcl.ufdcod,                                  
           pstcoddig        like datmsrvacp.pstcoddig,                            
           nomrazsoc        like dpaksocor.nomrazsoc,                             
           srrnom           like datksrr.srrnom,                                  
           socopgnum        like dbsmopgitm.socopgnum,                            
           socfatpgtdat     like dbsmopg.socfatpgtdat,                            
           socopgitmvlr     decimal(15,2), #like dbsmopgitm.socopgitmvlr,         
           socopgitmcst3    decimal(15,2), # like dbsmopgcst.socopgitmcst,        
           cstqtd3          smallint, # like dbsmopgcst.cstqtd,                   
           socopgitmcst4    decimal(15,2), # like dbsmopgcst.socopgitmcst,        
           cstqtd4          smallint, # like dbsmopgcst.cstqtd,                   
           socopgitmcst5    decimal(15,2), # like dbsmopgcst.socopgitmcst,        
           cstqtd5          smallint, # like dbsmopgcst.cstqtd,                   
           socopgitmcst18   decimal(15,2), # like dbsmopgcst.socopgitmcst,        
           cstqtd18         smallint, # like dbsmopgcst.cstqtd,                   
           socopgitmcst6    decimal(15,2), # like dbsmopgcst.socopgitmcst,        
           cstqtd6          smallint, # like dbsmopgcst.cstqtd,                   
           socopgitmcst22   decimal(15,2), # like dbsmopgcst.socopgitmcst,        
           cstqtd22         smallint, # like dbsmopgcst.cstqtd,                   
           soma             decimal(15,2),                                        
           clausula         char(03),                                             
           clausulades      char(50),                                             
           vclanomdl        like datmservico.vclanomdl ,                          
           corsus2          like datmservico.corsus,                              
	         atddat           like datmservico.atddat #--> FX-080515                                   
   end record

   define l_atdetpdat,
   	  l_atdetpdes,
          l_socfatpgtdat,
          l_aviretdat char(010),
          l_cpf       char(012),
          l_vcldes    char(100)


   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 01

   format

       on every row

           let l_atdetpdat    = extend(lr_parametro.atdetpdat, year to year), "-",
                                extend(lr_parametro.atdetpdat, month to month), "-",
                                extend(lr_parametro.atdetpdat, day to day)

           let l_socfatpgtdat = extend(lr_parametro.socfatpgtdat, year to year), "-",
                                extend(lr_parametro.socfatpgtdat, month to month), "-",
                                extend(lr_parametro.socfatpgtdat, day to day)


     open cbdbsr400031 using lr_parametro.atdetpcod
     whenever error continue
      fetch cbdbsr400031 into l_atdetpdes
          close cbdbsr400031
     whenever error stop

           if  lr_parametro.succod is null or lr_parametro.succod = 0 then
               print "SUCURSAL NAO CADASTRADA", ASCII(09);
           else
               print lr_parametro.succod clipped,       ASCII(09);
           end if

           if  lr_parametro.aplnumdig is null or lr_parametro.aplnumdig = 0 then
               print "APOLICE NAO CADASTRADA",  ASCII(09);
           else
               print lr_parametro.aplnumdig clipped,    ASCII(09);
           end if

           if  lr_parametro.segnom is null or lr_parametro.segnom = " " then
               print "SEGURADO NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.segnom clipped,       ASCII(09);
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
               print lr_parametro.c24solnom clipped,    ASCII(09);
           end if

           if  lr_parametro.cornom is null or lr_parametro.cornom = " " then
               print "CORRETOR NAO CADASTRADO", ASCII(09);
           else
               print lr_parametro.cornom clipped,       ASCII(09);
           end if

           print lr_parametro.vcldes clipped,           ASCII(09),
                 lr_parametro.vcllicnum clipped,        ASCII(09),
                 lr_parametro.vcldesatend clipped,      ASCII(09),
                 lr_parametro.vcllicnumatend clipped,   ASCII(09),
                 lr_parametro.c24astcod clipped,        ASCII(09),
                 lr_parametro.atdsrvorg clipped,        ASCII(09),
                 lr_parametro.atdsrvnum clipped,        ASCII(09),
                 lr_parametro.atdsrvano clipped,        ASCII(09),
                 lr_parametro.srvtipdes clipped,        ASCII(09),
                 lr_parametro.asitipdes clipped,        ASCII(09),
                 lr_parametro.c24pbmdes clipped,        ASCII(09),
                 l_atdetpdes clipped,			ASCII(09),
                 l_atdetpdat clipped,                   ASCII(09),
                 lr_parametro.cidsedcod clipped,        ASCII(09),
                 lr_parametro.cidnomsed clipped,        ASCII(09),
                 lr_parametro.cidnom clipped,           ASCII(09),
                 lr_parametro.ufdcod clipped,           ASCII(09),
                 lr_parametro.cidcoddes clipped,        ASCII(09),
                 lr_parametro.ufdcodes clipped,         ASCII(09),
                 lr_parametro.pstcoddig clipped,        ASCII(09),
                 lr_parametro.nomrazsoc clipped,        ASCII(09),
                 lr_parametro.atdvclsgl clipped,        ASCII(09),
                 lr_parametro.srrcoddig clipped,        ASCII(09),
                 lr_parametro.srrnom clipped,           ASCII(09),
                 lr_parametro.socopgnum clipped,        ASCII(09),
                 l_socfatpgtdat clipped,                ASCII(09);


                 if lr_parametro.socopgitmvlr is null or lr_parametro.socopgitmvlr = 0 then
                  let lr_parametro.socopgitmvlr = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmvlr,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst3 is null or lr_parametro.socopgitmcst3 = 0 then
                  let lr_parametro.socopgitmcst3 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst3,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd3 is null or lr_parametro.cstqtd3 = 0 then
                  let lr_parametro.cstqtd3 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd3,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst4 is null or lr_parametro.socopgitmcst4 = 0 then
                  let lr_parametro.socopgitmcst4 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst4,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd4 is null or lr_parametro.cstqtd4 = 0 then
                  let lr_parametro.cstqtd4 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd4,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst5 is null or lr_parametro.socopgitmcst5 = 0 then
                  let lr_parametro.socopgitmcst5 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst5,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd5 is null or lr_parametro.cstqtd5 = 0 then
                  let lr_parametro.cstqtd5 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd5,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst18 is null  or lr_parametro.socopgitmcst18 = 0 then
                  let lr_parametro.socopgitmcst18 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst18,".",",") clipped, ASCII(09);

                 if lr_parametro.cstqtd18 is null or lr_parametro.cstqtd18 = 0 then
                  let lr_parametro.cstqtd18 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd18,".",",") clipped, ASCII(09);

                 if lr_parametro.socopgitmcst6 is null or lr_parametro.socopgitmcst6 = 0 then
                  let lr_parametro.socopgitmcst6 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst6,".",",") clipped, ASCII(09);

     if lr_parametro.cstqtd6 is null or lr_parametro.cstqtd6 = 0 then
                  let lr_parametro.cstqtd6 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd6,".",",") clipped, ASCII(09);

                  if lr_parametro.socopgitmcst22 is null or lr_parametro.socopgitmcst22 = 0 then
                  let lr_parametro.socopgitmcst22 = 0.00
                 end if
                 print figrc005_troca1byte(lr_parametro.socopgitmcst22,".",",") clipped, ASCII(09);

     if lr_parametro.cstqtd22 is null or lr_parametro.cstqtd22 = 0 then
                  let lr_parametro.cstqtd22 = 0
                 end if
                 print figrc005_troca1byte(lr_parametro.cstqtd22,".",",") clipped, ASCII(09);

           if  lr_parametro.soma is null or lr_parametro.soma = 0 then
               print figrc005_troca1byte(lr_parametro.socopgitmvlr,".",",")  clipped, ASCII(09);
           else
               print figrc005_troca1byte(lr_parametro.soma,".",",")  clipped,  ASCII(09);
           end if

           if  lr_parametro.clausula is null or lr_parametro.clausula = 0 then
               print " ",                       ASCII(09),
                     "SEM CLAUSULA CADASTRADA", ASCII(09);
           else
               print lr_parametro.clausula clipped,     ASCII(09),
                     lr_parametro.clausulades clipped,  ASCII(09);
           end if
           
           if lr_parametro.vclanomdl is null or lr_parametro.vclanomdl = 0 then
              print " ", ASCII(09);
           else
              print lr_parametro.vclanomdl clipped, ASCII(09);
           end if
           
           if lr_parametro.corsus2 is null or lr_parametro.corsus2 = 0 then
              print " ", ASCII(09);
           else
              print lr_parametro.corsus2 clipped, ASCII(09);
           end if

           if lr_parametro.atddat is not null then  #--> FX-080515
	            print lr_parametro.atddat; #--> FX-080515
	         else
	            print " ";
           end if  

           skip 1 line

 end report

  #---- Copia  da Funcao cts38m00_dados_apolice, devido a alteracao na passagem
  #---- de parametros  03/2008

 #---------------------------------------#
  function bdbsr400_dados_apolice(lr_par)
 #---------------------------------------#
  define lr_par  record
     succod      decimal(2,0),
     ramcod      like datrservapol.ramcod,
     aplnumdig   decimal(9,0),
     itmnumdig   like datrligapol.itmnumdig
  end record



  define Lr_bdbsr400 record
     documento char(30),
     itmnumdig decimal(7,0),
     edsnumref decimal(9,0),
     succod    decimal(2,0),
     ramcod    smallint,
     emsdat    date,
     viginc    date,
     vigfnl    date,
     segcod    integer,
     segnom    char(50),
     vcldes    char(25),
     corsus    char(06),
     situacao  char(10)
  end record

  define l_doc_handle integer
  define l_retorno    smallint

  initialize mr_bdbsr400.* to null
  initialize lr_bdbsr400.* to null
  let l_doc_handle = null

  if lr_par.succod is not null and
     lr_par.aplnumdig is not null then

     open cbdbsr400028 using lr_par.*

     whenever error continue
       fetch cbdbsr400028 into  mr_bdbsr400.azlaplcod
       close cbdbsr400028
     whenever error stop

     if sqlca.sqlcode = 0 then
       display "   ============= INICIO DOS PARAMETROS: ",mr_bdbsr400.azlaplcod," ======================" 
       let mr_bdbsr400.doc_handle = ctd02g00_agrupaXML(mr_bdbsr400.azlaplcod)
#       display "Finalizei a funcao ctd02g00_agrupaXML :",mr_bdbsr400.doc_handle
       call cts38m00_extrai_dados_xml(mr_bdbsr400.doc_handle)
                       returning lr_bdbsr400.documento,
                                 lr_bdbsr400.itmnumdig,
                                 lr_bdbsr400.edsnumref,
                                 lr_bdbsr400.succod,
                                 lr_bdbsr400.ramcod,
                                 lr_bdbsr400.emsdat,
                                 lr_bdbsr400.viginc,
                                 lr_bdbsr400.vigfnl,
                                 lr_bdbsr400.segcod,
                                 lr_bdbsr400.segnom,
                                 lr_bdbsr400.vcldes,
                                 lr_bdbsr400.corsus,
                                 lr_bdbsr400.situacao

      display "   ============= FIM DOS PARAMETROS ======================"
       let mr_bdbsr400.resultado = 1
       let mr_bdbsr400.mensagem  = 'Apolice encontrada.(apol.)'

     else
        if  sqlca.sqlcode = notfound then
            let mr_bdbsr400.resultado = 2
            let mr_bdbsr400.mensagem  = "Apolice nao encontrada!(apol)"
          else
            let mr_bdbsr400.resultado = sqlca.sqlcode
            let mr_bdbsr400.mensagem  = 'Problema encontrado: Erro: ',
                                        sqlca.sqlcode
        end if
     end if
  else
     let mr_bdbsr400.resultado = 3
     let mr_bdbsr400.mensagem  = "Parametros nulos"
  end if

  return lr_bdbsr400.documento,
         lr_bdbsr400.itmnumdig,
         lr_bdbsr400.edsnumref,
         lr_bdbsr400.succod,
         lr_bdbsr400.ramcod,
         lr_bdbsr400.emsdat,
         lr_bdbsr400.viginc,
         lr_bdbsr400.vigfnl,
         lr_bdbsr400.segcod,
         lr_bdbsr400.segnom,
         lr_bdbsr400.vcldes,
         lr_bdbsr400.corsus,
         mr_bdbsr400.doc_handle,
         mr_bdbsr400.resultado,
         mr_bdbsr400.mensagem,
         lr_bdbsr400.situacao

end function
