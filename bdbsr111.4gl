#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........:                                                            #
# ANALISTA RESP..: RAJI DUENHAS JAHCHAN                                       #
# PSI/OSF........: 208264                                                     #
#                  EXTRACAO DE PAGAMENTOS SEM PARAR - PORTO SEGURO            #
# ........................................................................... #
# DESENVOLVIMENTO: FABIANO RAMOS DOS SANTOS                                   #
# LIBERACAO......: 10/05/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
# ---------- --------------  ---------- ------------------------------------- #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 05/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
#-----------------------------------------------------------------------------#
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#


 database porto

    define m_path       char(100),
           m_path2      char(100),
           m_path_txt   char(100), #--> RELTXT
           m_path2_txt  char(100), #--> RELTXT
           m_mes        smallint ,
           param1       char(10) ,
           param2       char(10) ,
           sdata        char(10)

    define m_dat_ini,
           m_dat_fim    date

 main

    # Carrega datas para processamento
    let param1 = arg_val(1)
    let param2 = arg_val(2)
    if param1 = " " then
       let m_dat_ini = today - 1 units month
       let sdata = m_dat_ini
       let sdata = "01/", sdata[4,10]
       let m_dat_ini = sdata
    else
       let m_dat_ini = param1
    end if
    if param2 = " " then
       let m_dat_fim = (m_dat_ini + 1 units month) - 1 units day
    else
       let m_dat_fim = param2
    end if

    call fun_dba_abre_banco("CT24HS")

    call bdbsr111_busca_path()

    call bdbsr111_prepare()

    call cts40g03_exibe_info("I","BDBSR111")

    set isolation to dirty read

    call bdbsr111()

    call cts40g03_exibe_info("F","BDBSR111")
 end main


#------------------------------#
 function bdbsr111_busca_path()
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

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr111.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path2_txt = m_path clipped, "/bdbsr111_pag_", l_dataarq, ".txt"
    let m_path2     = m_path clipped, "/bdbsr111_pag.xls"

    let m_path_txt  = m_path clipped, "/bdbsr111_atd_", l_dataarq, ".txt"
    let m_path      = m_path clipped, "/bdbsr111_atd.xls"

 end function


#---------------------------#
 function bdbsr111_prepare()
#---------------------------#
    define l_sql char(1000)

    #Identificando os acionamentos
    let l_sql = "select acp.atdetpdat,",
                      " acp.atdetphor,",
                      " acp.pstcoddig,",
                      " acp.socvclcod,",
                      " veic.atdvclsgl,",
                      " veic.prrsemnum,",
                      " pdg.atdsrvnum,",
                      " pdg.atdsrvano,",
                      " srv.ciaempcod,",
                      " pdg.pdgqtd,",
                      " pdg.pdgttlvlr",
                 " from datmsrvacp acp,",
                      " dbarsemprrsrv pdg,",
                      " datmservico srv,",
                " outer datkveiculo veic",
                " where acp.atdetpdat between '", m_dat_ini, "' and '", m_dat_fim, "'",
                  " and acp.atdetpcod in (3,4,10)",
                  " and pdg.pdgqtd > 0 ",
                  " and acp.atdsrvnum = pdg.atdsrvnum",
                  " and acp.atdsrvano = pdg.atdsrvano",
                  " and acp.atdsrvnum = srv.atdsrvnum",
                  " and acp.atdsrvano = srv.atdsrvano",
                  " and acp.socvclcod = veic.socvclcod",
                " order by acp.atdetpdat, acp.pstcoddig, acp.socvclcod"
    prepare pbdbsr111001 from l_sql
    declare cbdbsr111001 cursor for pbdbsr111001

    #Identificando cidade e uf da ocorrencia
    let l_sql = " select cidnom,",
                       " ufdcod",
                  " from datmlcl",
                 " where atdsrvnum = ?",
                   " and atdsrvano = ?",
                   " and c24endtip = 1"
    prepare pbdbsr111002 from l_sql
    declare cbdbsr111002 cursor for pbdbsr111002

    #Identificando cidade e uf do destino
    let l_sql = " select cidnom,",
                       " ufdcod",
                  " from datmlcl",
                 " where atdsrvnum = ?",
                   " and atdsrvano = ?",
                   " and c24endtip = 2"
    prepare pbdbsr111003 from l_sql
    declare cbdbsr111003 cursor for pbdbsr111003

    #Identificando o prestador
    let l_sql = " select nomrazsoc",
                  " from dpaksocor",
                 " where pstcoddig = ?"
    prepare pbdbsr111004 from l_sql
    declare cbdbsr111004 cursor for pbdbsr111004

    #Identificando os pagamentos
    let l_sql = "select opg.socfatpgtdat,",
                      " srv.atdprscod,",
                      " srv.socvclcod,",
                      " veic.atdvclsgl,",
                      " veic.prrsemnum,",
                      " pdg.atdsrvnum,",
                      " pdg.atdsrvano,",
                      " srv.ciaempcod,",
                      " pdg.pdgqtd,",
                      " pdg.pdgttlvlr",
                 " from dbsmopg opg,",
                      " dbsmopgitm itm,",
                      " dbarsemprrsrv pdg,",
                      " datmservico srv,",
                " outer datkveiculo veic",
                " where opg.socfatpgtdat between '", m_dat_ini, "' and '", m_dat_fim, "'",
                  " and opg.socopgsitcod = 7",
                  " and opg.socopgnum = itm.socopgnum",
                  " and pdg.pdgqtd > 0 ",
                  " and itm.atdsrvnum = pdg.atdsrvnum",
                  " and itm.atdsrvano = pdg.atdsrvano",
                  " and itm.atdsrvnum = srv.atdsrvnum",
                  " and itm.atdsrvano = srv.atdsrvano",
                  " and srv.socvclcod = veic.socvclcod",
                " order by opg.socfatpgtdat, srv.atdprscod, srv.socvclcod"
    prepare pbdbsr111005 from l_sql
    declare cbdbsr111005 cursor for pbdbsr111005

 end function

#-------------------#
 function bdbsr111()
#-------------------#

    define lr_dados record
        atdetpdat       like datmsrvacp.atdetpdat,
        atdetphor       like datmsrvacp.atdetphor,
        pstcoddig       like datmsrvacp.pstcoddig,
        nomrazsoc       like dpaksocor.nomrazsoc,
        socvclcod       like datmsrvacp.socvclcod,
        atdvclsgl       like datkveiculo.atdvclsgl,
        prrsemnum       like datkveiculo.prrsemnum,
        atdsrvnum       like dbarsemprrsrv.atdsrvnum,
        atdsrvano       like dbarsemprrsrv.atdsrvano,
        ciaempcod       like datmservico.ciaempcod,
        pdgqtd          like dbarsemprrsrv.pdgqtd,
        pdgttlvlr       like dbarsemprrsrv.pdgttlvlr,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        cidcoddes       like datmlcl.cidnom,
        ufdcodes        like datmlcl.ufdcod
    end record

    initialize lr_dados.* to null

    ##### ATENDIMENTO #####
    start report bdbsr111_rel_atd to m_path
    start report bdbsr111_rel_atd_txt to m_path_txt #--> RELTXT
    open cbdbsr111001
    foreach cbdbsr111001 into lr_dados.atdetpdat,
                              lr_dados.atdetphor,
                              lr_dados.pstcoddig,
                              lr_dados.socvclcod,
                              lr_dados.atdvclsgl,
                              lr_dados.prrsemnum,
                              lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.ciaempcod,
                              lr_dados.pdgqtd,
                              lr_dados.pdgttlvlr

            open cbdbsr111002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr111002 into lr_dados.cidnom, lr_dados.ufdcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr111002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr111002

            open cbdbsr111003 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr111003 into lr_dados.cidcoddes, lr_dados.ufdcodes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr111003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr111003

            open cbdbsr111004 using lr_dados.pstcoddig
            whenever error continue
            fetch cbdbsr111004 into lr_dados.nomrazsoc
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr111004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr111004

            let m_mes = month(lr_dados.atdetpdat)
            output to report bdbsr111_rel_atd(lr_dados.atdetpdat,
                                                lr_dados.atdetphor,
                                                lr_dados.pstcoddig,
                                                lr_dados.nomrazsoc,
                                                lr_dados.socvclcod,
                                                lr_dados.atdvclsgl,
                                                lr_dados.prrsemnum,
                                                lr_dados.atdsrvnum,
                                                lr_dados.atdsrvano,
                                                lr_dados.ciaempcod,
                                                lr_dados.pdgqtd,
                                                lr_dados.pdgttlvlr,
                                                lr_dados.cidnom,
                                                lr_dados.ufdcod,
                                                lr_dados.cidcoddes,
                                                lr_dados.ufdcodes,
                                                m_mes)
	    #--> RELTXT (inicio)
            output to report bdbsr111_rel_atd_txt(lr_dados.atdetpdat,
                                                lr_dados.atdetphor,
                                                lr_dados.pstcoddig,
                                                lr_dados.nomrazsoc,
                                                lr_dados.socvclcod,
                                                lr_dados.atdvclsgl,
                                                lr_dados.prrsemnum,
                                                lr_dados.atdsrvnum,
                                                lr_dados.atdsrvano,
                                                lr_dados.ciaempcod,
                                                lr_dados.pdgqtd,
                                                lr_dados.pdgttlvlr,
                                                lr_dados.cidnom,
                                                lr_dados.ufdcod,
                                                lr_dados.cidcoddes,
                                                lr_dados.ufdcodes,
                                                m_mes)
	    #--> RELTXT (final)

            initialize lr_dados.* to null
    end foreach
    close cbdbsr111001
    finish report bdbsr111_rel_atd
    finish report bdbsr111_rel_atd_txt #--> RELTXT

    ##### PAGAMENTO #####
    start report bdbsr111_rel_pag to m_path2
    start report bdbsr111_rel_pag_txt to m_path2_txt #--> RELTXT
    open cbdbsr111005
    foreach cbdbsr111005 into lr_dados.atdetpdat,
                              lr_dados.pstcoddig,
                              lr_dados.socvclcod,
                              lr_dados.atdvclsgl,
                              lr_dados.prrsemnum,
                              lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.ciaempcod,
                              lr_dados.pdgqtd,
                              lr_dados.pdgttlvlr

            open cbdbsr111002 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr111002 into lr_dados.cidnom, lr_dados.ufdcod
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr111002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr111002

            open cbdbsr111003 using lr_dados.atdsrvnum, lr_dados.atdsrvano
            whenever error continue
            fetch cbdbsr111003 into lr_dados.cidcoddes, lr_dados.ufdcodes
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr111003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr111003

            open cbdbsr111004 using lr_dados.pstcoddig
            whenever error continue
            fetch cbdbsr111004 into lr_dados.nomrazsoc
            whenever error stop
            if  sqlca.sqlcode <> 0 then
                if  sqlca.sqlcode <> notfound then
                    display "Erro SELECT cbdbsr111004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    exit program(1)
                end if
            end if
            close cbdbsr111004

            let m_mes = month(lr_dados.atdetpdat)
            output to report bdbsr111_rel_pag(lr_dados.atdetpdat,
                                              lr_dados.pstcoddig,
                                              lr_dados.nomrazsoc,
                                              lr_dados.socvclcod,
                                              lr_dados.atdvclsgl,
                                              lr_dados.prrsemnum,
                                              lr_dados.atdsrvnum,
                                              lr_dados.atdsrvano,
                                              lr_dados.ciaempcod,
                                              lr_dados.pdgqtd,
                                              lr_dados.pdgttlvlr,
                                              lr_dados.cidnom,
                                              lr_dados.ufdcod,
                                              lr_dados.cidcoddes,
                                              lr_dados.ufdcodes,
                                              m_mes)
	    #--> RELTXT (inicio)
            output to report bdbsr111_rel_pag_txt(lr_dados.atdetpdat,
                                              lr_dados.pstcoddig,
                                              lr_dados.nomrazsoc,
                                              lr_dados.socvclcod,
                                              lr_dados.atdvclsgl,
                                              lr_dados.prrsemnum,
                                              lr_dados.atdsrvnum,
                                              lr_dados.atdsrvano,
                                              lr_dados.ciaempcod,
                                              lr_dados.pdgqtd,
                                              lr_dados.pdgttlvlr,
                                              lr_dados.cidnom,
                                              lr_dados.ufdcod,
                                              lr_dados.cidcoddes,
                                              lr_dados.ufdcodes,
                                              m_mes)
	    #--> RELTXT (final)

            initialize lr_dados.* to null

    end foreach
    close cbdbsr111005

    finish report bdbsr111_rel_pag
    finish report bdbsr111_rel_pag_txt #--> RELTXT

    ##### EMAIL #####
    call bdbsr111_envia_email()

 end function


#-------------------------------#
 function bdbsr111_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_mes_extenso char(010),
          l_erro_envio  integer

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null

   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path       = m_path clipped, ".gz"
   let l_assunto    = "Relatorio de SEM PARAR - Atendimento"
   let l_erro_envio = ctx22g00_envia_email("BDBSR111", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - bdbsr111"
       end if
   end if

   let l_comando = "gzip -f ", m_path2
   run l_comando
   let m_path2      = m_path2 clipped, ".gz"
   let l_assunto    = "Relatorio de SEM PARAR - Pagamento"
   let l_erro_envio = ctx22g00_envia_email("BDBSR111", l_assunto, m_path2)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path2
       else
           display "Nao existe email cadastrado para o modulo - bdbsr111"
       end if
   end if

end function


#---------------------------------------#
 report bdbsr111_rel_atd(lr_parametro)
#---------------------------------------#

    define lr_parametro record
        atdetpdat       like datmsrvacp.atdetpdat,
        atdetphor       like datmsrvacp.atdetphor,
        pstcoddig       like datmsrvacp.pstcoddig,
        nomrazsoc       like dpaksocor.nomrazsoc,
        socvclcod       like datmsrvacp.socvclcod,
        atdvclsgl       like datkveiculo.atdvclsgl,
        prrsemnum       like datkveiculo.prrsemnum,
        atdsrvnum       like dbarsemprrsrv.atdsrvnum,
        atdsrvano       like dbarsemprrsrv.atdsrvano,
        ciaempcod       like datmservico.ciaempcod,
        pdgqtd          like dbarsemprrsrv.pdgqtd,
        pdgttlvlr       like dbarsemprrsrv.pdgttlvlr,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        cidcoddes       like datmlcl.cidnom,
        ufdcodes        like datmlcl.ufdcod,
        mes             smallint
    end record

    define l_atdetpdat  char(10)

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 02

    format
        first page header
            print "DATA REF",           ASCII(09),
                  "HORA",               ASCII(09),
                  "PRESTADOR",          ASCII(09),
                  "NOME PRESTADOR",     ASCII(09),
                  "VEICULO SOCORRISTA", ASCII(09),
                  "SIGLA VIATURA",      ASCII(09),
                  "NUMERO SEM PARAR",   ASCII(09),
                  "NUMERO SERVICO",     ASCII(09),
                  "ANO SERVICO",        ASCII(09),
                  "EMPRESA",            ASCII(09),
                  "QUANTIDADE PEDAGIO", ASCII(09),
                  "VALOR TOTAL PAGO",   ASCII(09),
                  "CIDADE ORIGEM",      ASCII(09),
                  "ESTADO ORIGEM",      ASCII(09),
                  "CIDADE DESTINO",     ASCII(09),
                  "ESTADO DESTINO"

        on every row
            let l_atdetpdat = extend(lr_parametro.atdetpdat, year to year), "-",
                              extend(lr_parametro.atdetpdat, month to month), "-",
                              extend(lr_parametro.atdetpdat, day to day)

            print l_atdetpdat,   ASCII(09),
                  lr_parametro.atdetphor,   ASCII(09),
                  lr_parametro.pstcoddig,   ASCII(09),
                  lr_parametro.nomrazsoc,   ASCII(09),
                  lr_parametro.socvclcod,   ASCII(09),
                  lr_parametro.atdvclsgl,   ASCII(09),
                  lr_parametro.prrsemnum,   ASCII(09),
                  lr_parametro.atdsrvnum,   ASCII(09),
                  lr_parametro.atdsrvano,   ASCII(09),
                  lr_parametro.ciaempcod,   ASCII(09),
                  lr_parametro.pdgqtd,      ASCII(09),
                  lr_parametro.pdgttlvlr  using "---------&,&&",   ASCII(09),
                  lr_parametro.cidnom,     ASCII(09),
                  lr_parametro.ufdcod,     ASCII(09),
                  lr_parametro.cidcoddes,  ASCII(09),
                  lr_parametro.ufdcodes

 end report

#-----------------------------------------------------#
 report bdbsr111_rel_atd_txt(lr_parametro) #--> RELTXT
#-----------------------------------------------------#

    define lr_parametro record
        atdetpdat       like datmsrvacp.atdetpdat,
        atdetphor       like datmsrvacp.atdetphor,
        pstcoddig       like datmsrvacp.pstcoddig,
        nomrazsoc       like dpaksocor.nomrazsoc,
        socvclcod       like datmsrvacp.socvclcod,
        atdvclsgl       like datkveiculo.atdvclsgl,
        prrsemnum       like datkveiculo.prrsemnum,
        atdsrvnum       like dbarsemprrsrv.atdsrvnum,
        atdsrvano       like dbarsemprrsrv.atdsrvano,
        ciaempcod       like datmservico.ciaempcod,
        pdgqtd          like dbarsemprrsrv.pdgqtd,
        pdgttlvlr       like dbarsemprrsrv.pdgttlvlr,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        cidcoddes       like datmlcl.cidnom,
        ufdcodes        like datmlcl.ufdcod,
        mes             smallint
    end record

    define l_atdetpdat  char(10)

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 01

    format

        on every row
            let l_atdetpdat = extend(lr_parametro.atdetpdat, year to year), "-",
                              extend(lr_parametro.atdetpdat, month to month), "-",
                              extend(lr_parametro.atdetpdat, day to day)

            print l_atdetpdat,   ASCII(09),
                  lr_parametro.atdetphor,   ASCII(09),
                  lr_parametro.pstcoddig,   ASCII(09),
                  lr_parametro.nomrazsoc,   ASCII(09),
                  lr_parametro.socvclcod,   ASCII(09),
                  lr_parametro.atdvclsgl,   ASCII(09),
                  lr_parametro.prrsemnum,   ASCII(09),
                  lr_parametro.atdsrvnum,   ASCII(09),
                  lr_parametro.atdsrvano,   ASCII(09),
                  lr_parametro.ciaempcod,   ASCII(09),
                  lr_parametro.pdgqtd,      ASCII(09),
                  lr_parametro.pdgttlvlr  using "---------&,&&",   ASCII(09),
                  lr_parametro.cidnom,     ASCII(09),
                  lr_parametro.ufdcod,     ASCII(09),
                  lr_parametro.cidcoddes,  ASCII(09),
                  lr_parametro.ufdcodes

 end report

#---------------------------------------#
 report bdbsr111_rel_pag(lr_parametro)
#---------------------------------------#

    define lr_parametro record
        atdetpdat       like datmsrvacp.atdetpdat,
        pstcoddig       like datmsrvacp.pstcoddig,
        nomrazsoc       like dpaksocor.nomrazsoc,
        socvclcod       like datmsrvacp.socvclcod,
        atdvclsgl       like datkveiculo.atdvclsgl,
        prrsemnum       like datkveiculo.prrsemnum,
        atdsrvnum       like dbarsemprrsrv.atdsrvnum,
        atdsrvano       like dbarsemprrsrv.atdsrvano,
        ciaempcod       like datmservico.ciaempcod,
        pdgqtd          like dbarsemprrsrv.pdgqtd,
        pdgttlvlr       like dbarsemprrsrv.pdgttlvlr,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        cidcoddes       like datmlcl.cidnom,
        ufdcodes        like datmlcl.ufdcod,
        mes             smallint
    end record

    define l_atdetpdat  char(10)

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 02

    format
        first page header
            print "DATA PAG",           ASCII(09),
                  "PRESTADOR",          ASCII(09),
                  "NOME PRESTADOR",     ASCII(09),
                  "VEICULO SOCORRISTA", ASCII(09),
                  "SIGLA VIATURA",      ASCII(09),
                  "NUMERO SEM PARAR",   ASCII(09),
                  "NUMERO SERVICO",     ASCII(09),
                  "ANO SERVICO",        ASCII(09),
                  "EMPRESA",            ASCII(09),
                  "QUANTIDADE PEDAGIO", ASCII(09),
                  "VALOR TOTAL PAGO",   ASCII(09),
                  "CIDADE ORIGEM",      ASCII(09),
                  "ESTADO ORIGEM",      ASCII(09),
                  "CIDADE DESTINO",     ASCII(09),
                  "ESTADO DESTINO"

        on every row
            let l_atdetpdat = extend(lr_parametro.atdetpdat, year to year), "-",
                              extend(lr_parametro.atdetpdat, month to month), "-",
                              extend(lr_parametro.atdetpdat, day to day)

            print l_atdetpdat,   ASCII(09),
                  lr_parametro.pstcoddig,   ASCII(09),
                  lr_parametro.nomrazsoc,   ASCII(09),
                  lr_parametro.socvclcod,   ASCII(09),
                  lr_parametro.atdvclsgl,   ASCII(09),
                  lr_parametro.prrsemnum,   ASCII(09),
                  lr_parametro.atdsrvnum,   ASCII(09),
                  lr_parametro.atdsrvano,   ASCII(09),
                  lr_parametro.ciaempcod,   ASCII(09),
                  lr_parametro.pdgqtd,      ASCII(09),
                  lr_parametro.pdgttlvlr  using "---------&,&&",   ASCII(09),
                  lr_parametro.cidnom,     ASCII(09),
                  lr_parametro.ufdcod,     ASCII(09),
                  lr_parametro.cidcoddes,  ASCII(09),
                  lr_parametro.ufdcodes

 end report

#-----------------------------------------------------#
 report bdbsr111_rel_pag_txt(lr_parametro) #--> RELTXT
#-----------------------------------------------------#

    define lr_parametro record
        atdetpdat       like datmsrvacp.atdetpdat,
        pstcoddig       like datmsrvacp.pstcoddig,
        nomrazsoc       like dpaksocor.nomrazsoc,
        socvclcod       like datmsrvacp.socvclcod,
        atdvclsgl       like datkveiculo.atdvclsgl,
        prrsemnum       like datkveiculo.prrsemnum,
        atdsrvnum       like dbarsemprrsrv.atdsrvnum,
        atdsrvano       like dbarsemprrsrv.atdsrvano,
        ciaempcod       like datmservico.ciaempcod,
        pdgqtd          like dbarsemprrsrv.pdgqtd,
        pdgttlvlr       like dbarsemprrsrv.pdgttlvlr,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        cidcoddes       like datmlcl.cidnom,
        ufdcodes        like datmlcl.ufdcod,
        mes             smallint
    end record

    define l_atdetpdat  char(10)

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 01

    format
        on every row
            let l_atdetpdat = extend(lr_parametro.atdetpdat, year to year), "-",
                              extend(lr_parametro.atdetpdat, month to month), "-",
                              extend(lr_parametro.atdetpdat, day to day)

            print l_atdetpdat,              ASCII(09),
                  lr_parametro.pstcoddig,   ASCII(09),
                  lr_parametro.nomrazsoc,   ASCII(09),
                  lr_parametro.socvclcod,   ASCII(09),
                  lr_parametro.atdvclsgl,   ASCII(09),
                  lr_parametro.prrsemnum,   ASCII(09),
                  lr_parametro.atdsrvnum,   ASCII(09),
                  lr_parametro.atdsrvano,   ASCII(09),
                  lr_parametro.ciaempcod,   ASCII(09),
                  lr_parametro.pdgqtd,      ASCII(09),
                  lr_parametro.pdgttlvlr    using "---------&,&&",   ASCII(09),
                  lr_parametro.cidnom,      ASCII(09),
                  lr_parametro.ufdcod,      ASCII(09),
                  lr_parametro.cidcoddes,   ASCII(09),
                  lr_parametro.ufdcodes

 end report
