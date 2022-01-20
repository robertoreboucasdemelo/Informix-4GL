#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr120                                                   #
# ANALISTA RESP..: Andre Pinto                                                #
# PSI/OSF........: 230430                                                     #
#                  RELATORIO DE BRINDES ENTREGUES  - PORTO SEGURO SEGUROS     #
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

    define mr_dados record
           atdsrvnum    like    datmservico.atdsrvnum,
           atdsrvano    like    datmservico.atdsrvano,
           atdsrvorg    like    datmservico.atdsrvorg,
           prsokadat    like    dbsmsrvacr.prsokadat,
           succod       like    datrservapol.succod,
           aplnumdig    like    datrservapol.aplnumdig,
           itmnumdig    like    datrservapol.itmnumdig,
           segnom       like    gsakseg.segnom,
           corsusldr    like    gcakcorr.corsuspcp,
           cornom       like    gcakcorr.cornom,
           srvtipdes    like    datksrvtip.srvtipdes,
           pstcoddig    like    dpaksocor.pstcoddig,
           nomrazsoc    like    dpaksocor.nomrazsoc,
           prttip       like    datkprt.prttip,
           prtseq       like    datkprt.prtseq,
           prtdes       like    datkprt.prtdes,
           prtgrp       like    datkprt.prtgrpcod,
           prtgrpsubcod like    datkprt.prtgrpsubcod,
           prtsrvdes    like    datrsrvprt.prtsrvdes,
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
           srrnom       like    datksrr.srrnom
    end record
    
    define a_bdbsr1201 array[50] of record
        brinde char(100),
        grupo smallint
    end record
    
    define a_bdbsr1202 array[200] of record
        prtseq smallint
    end record
    
    define m_path    char(100),
          #m_mes_int smallint
           m_data_inicio, m_data_fim date
    define m_cabecalho  char(100)
    define m_lenght, m_ind_1, m_ind_2 smallint

 main
    call fun_dba_abre_banco("CT24HS")

    call bdbsr120_busca_path()

    call bdbsr120_prepare()

    call cts40g03_exibe_info("I","bdbsr120")

    set isolation to dirty read

    call bdbsr120()

    call cts40g03_exibe_info("F","bdbsr120")
 end main


#------------------------------#
 function bdbsr120_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr120.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr120.xls"

 end function


#---------------------------#
 function bdbsr120_prepare()
#---------------------------#
    define l_sql char(600)
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    # ---> OBTER A DATA E HORA DO BANCO
    call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual
    
    # Calculo das datas dos ultimos 7 dias (semana anterior) ou recebida por parametro
    let m_data_inicio = arg_val(1)
    let m_data_fim = arg_val(2)

    if m_data_inicio is null or m_data_fim is null then
        let m_data_inicio = l_data_atual - 7 units day
        let m_data_fim = l_data_atual - 1 units day
    end if  
    
    #let m_data_fim = today
    ## ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
    #if  month(l_data_atual) = 01 then
    #    let m_data_inicio = mdy(12,21,year(l_data_atual) - 1)
    #    let m_data_fim    = mdy(01,20,year(l_data_atual))
    #else
    #    let m_data_inicio = mdy(month(l_data_atual) - 1,21,year(l_data_atual))
    #    let m_data_fim    = mdy(month(l_data_atual),20,year(l_data_atual))
    #end if

    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    #let m_mes_int = month(m_data_inicio)
    
    #Identificando os servicos
    set isolation to dirty read

    let l_sql = " select a.atdsrvnum,    "
               ,"        a.atdsrvano,    "
               ,"        a.prsokadat,    "
               ,"        a.pstcoddig     "
               ,"   from dbsmsrvacr a    "
               ,"  where a.prsokadat >= '", m_data_inicio using "dd/MM/yyyy", "' "
               ,"    and a.prsokadat <= '", m_data_fim    using "dd/MM/yyyy", "' "
               ,"    and a.prsokaflg = 'S' "
               ,"    and exists (select 1                          "
               ,"                  from datrsrvprt p               "
               ,"                 where a.atdsrvnum = p.atdsrvnum  "
               ,"                   and a.atdsrvano = p.atdsrvano) "
    prepare pbdbsr120001 from l_sql
    declare cbdbsr120001 cursor for pbdbsr120001

    #Identificando apolice
    let l_sql = " select succod, aplnumdig, itmnumdig ",
                  " from datrservapol ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
    prepare pbdbsr120002 from l_sql
    declare cbdbsr120002 cursor for pbdbsr120002

    #Identificando segurado
    let l_sql = " select seg.segnom ",
                  " from gsakseg seg,  abbmdoc doc ",
                 " where seg.segnumdig = doc.segnumdig ",
                 " and doc.aplnumdig = ? ",
                 " and doc.succod = ? "
    prepare pbdbsr120003 from l_sql
    declare cbdbsr120003 cursor for pbdbsr120003

    #Identificando tipos de brindes
    let l_sql = " select prtdes, ",
                "        prtgrpsubcod ",
                  " from datkprt ",
                 " where prttip = 2 ",
                   " and prtgrpcod = 2 "
    prepare pbdbsr120004 from l_sql
    declare cbdbsr120004 cursor for pbdbsr120004

    #Identificando tipo de servico
    let l_sql = " select srvtipdes ",
                  " from datksrvtip ",
                 " where atdsrvorg = ? "
    prepare pbdbsr120005 from l_sql
    declare cbdbsr120005 cursor for pbdbsr120005

    #Identificando a quantidade de brindes
    let l_sql = " select prtdes, prtsrvdes ",
                  " from datrsrvprt, datkprt ",
                 " where atdsrvnum = ? ",
                 "   and atdsrvano = ? ",
                 "   and datrsrvprt.prtseq = datkprt.prtseq ",
                 "   and datkprt.prttip = 2 "
    prepare pbdbsr120006 from l_sql
    declare cbdbsr120006 cursor for pbdbsr120006

    #Identificando a qtd de brindes
    #let l_sql = " select prtdes ",
    #              " from datkprt ",
    #             " where prtseq = ? "
    #prepare pbdbsr120007 from l_sql
    #declare cbdbsr120007 cursor for pbdbsr120007

    #Identificando data de acionamento
    let l_sql = " select a.atdetpdat,             ",
                "        a.srrcoddig,             ",
                "        a.atdvclsgl,             ",
                "        a.socvclcod,             ",
                "        a.atdetphor,             ",
                "        s.pstcoddig,             ",
                "        s.nomrazsoc              ",
                "  from datmsrvacp a, dpaksocor s ",
                " where s.pstcoddig = a.pstcoddig ", 
                "   and a.atdsrvnum = ?           ",
                "   and a.atdsrvano = ?           ",
                "   and a.atdsrvseq = (select max(acp.atdsrvseq) ",
                "                      from datmsrvacp acp       ",
                "                     where acp.atdsrvnum = ?    ",
                "                       and acp.atdsrvano = ?    ",
                "                       and acp.atdetpcod = 4)   "
    prepare pbdbsr120008 from l_sql
    declare cbdbsr120008 cursor for pbdbsr120008
    
    #Identificando o prestador
    #let l_sql = " select socor.pstcoddig, ",
    #                   " socor.nomrazsoc ",
    #              " from  dpaksocor socor,  datmsrvacp acp ",
    #             " where socor.pstcoddig = acp.pstcoddig ",
    #               " and acp.atdsrvnum = ? ",
    #               " and acp.atdsrvano = ? ",
    #               " and acp.atdetpcod = 4 "
    #prepare pbdbsr120031 from l_sql
    #declare cbdbsr120031 cursor for pbdbsr120031
    
    #Identificando cidade e uf da ocorrencia
    let l_sql = " select cidnom, ",
                       " ufdcod ",
                  " from datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 1 "
    prepare pbdbsr120009 from l_sql
    declare cbdbsr120009 cursor for pbdbsr120009

    ##Identificando nome do Corretor
    #let l_sql = " select cornom ",
    #              " from gcakcorr ",
    #             " where corsuspcp = ? "
    #prepare pbdbsr120010 from l_sql
    #declare cbdbsr120010 cursor for pbdbsr120010

    #Identificando o prestador
    #let l_sql = " select socor.pstcoddig, ",
    #                   " socor.nomrazsoc ",
    #              " from  dpaksocor socor ",
    #              " where pstcoddig = ? "
    #prepare pbdbsr120011 from l_sql
    #declare cbdbsr120011 cursor for pbdbsr120011

    #Identificando o nome do socorrista
    let l_sql = " select srrnom ",
                  " from datksrr ",
                 " where srrcoddig = ? "
    prepare pbdbsr120012 from l_sql
    declare cbdbsr120012 cursor for pbdbsr120012

    #Identificando a origem do servico
    let l_sql = " select atdsrvorg ",
                "       ,corsus    ",
                "       ,cornom    ",
                  " from datmservico ",
                 " where atdsrvnum = ? ",
                 "   and atdsrvano = ? "
    prepare pbdbsr120013 from l_sql
    declare cbdbsr120013 cursor for pbdbsr120013

    #Identificando os subgrupos
    let l_sql = " select prtseq ",
                  " from datkprt ",
                 " where prtgrpcod = ? "
    prepare pbdbsr120014 from l_sql
    declare cbdbsr120014 cursor for pbdbsr120014

    #Identificando as descricoes dos grupos
    let l_sql =  "select prtseq, prtdes                    ",
                 "  from datkprt                           ",
                 " where prtseq in ( select prtseq         ",
                 "                    from datrsrvprt      ",
                 "                   where atdsrvnum = ?   ",
                 "                     and atdsrvano = ? ) ",
                 "   and prttip = 2                        "
    prepare pbdbsr120015 from l_sql
    declare cbdbsr120015 cursor for pbdbsr120015

    ##Identificando SUSEP
    #let l_sql = " select corsusldr ",
    #            "   from abamapol  ",
    #            "   where aplnumdig = ? ",
    #            "     and succod = ? "
    #prepare pbdbsr120016 from l_sql
    #declare cbdbsr120016 cursor for pbdbsr120016

    #Identificando as descricoes dos brindes
    #let l_sql = " select prtdes     ",
    #              " from datkprt    ",
    #             " where prtseq = ? "
    #prepare pbdbsr120017 from l_sql
    #declare cbdbsr120017 cursor for pbdbsr120017

    #Identificando cidade sede da ocorrência
    let l_sql = " select cidcod ",
                  " from  glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
    prepare pbdbsr120020 from l_sql
    declare cbdbsr120020 cursor for pbdbsr120020

    let l_sql = " select cidsedcod ",
                  " from  datrcidsed ",
                 " where cidcod = ? "
    prepare pbdbsr120021 from l_sql
    declare cbdbsr120021 cursor for pbdbsr120021

    let l_sql = " select cidcod, ",
                       " cidnom ",
                  " from  glakcid ",
                 " where cidcod = ? ",
                   " and ufdcod = ?"
    prepare pbdbsr120022 from l_sql
    declare cbdbsr120022 cursor for pbdbsr120022

    #Identificando a sigla do veiculo acionado
     let l_sql = " select atdvclsgl   ",
       "   from datkveiculo ",
       "  where socvclcod = ? "
    prepare pbdbsr120026 from l_sql
    declare cbdbsr120026 cursor for pbdbsr120026

 end function

#-------------------#
 function bdbsr120()
#-------------------#

    initialize mr_dados.* to null
    initialize a_bdbsr1201, a_bdbsr1202  to null
    
    let m_ind_1 = 0
    let m_ind_2 = 0
    let m_cabecalho = null
            
    open cbdbsr120004
    foreach cbdbsr120004 into a_bdbsr1201[m_ind_1+1].brinde, a_bdbsr1201[m_ind_1+1].grupo
        let m_ind_1 = m_ind_1 + 1
        let m_cabecalho = m_cabecalho clipped, upshift(a_bdbsr1201[m_ind_1].brinde) clipped,      ASCII(09)
        
        open cbdbsr120014 using a_bdbsr1201[m_ind_1].grupo
        foreach cbdbsr120014 into a_bdbsr1202[m_ind_2+1].prtseq
              let m_ind_2 = m_ind_2 + 1  
        end foreach
        close cbdbsr120014
        
        let m_ind_2 = m_ind_2 + 1
        let a_bdbsr1202[m_ind_2].prtseq = -1
    end foreach
    close cbdbsr120004
            
    start report bdbsr120_relatorio to m_path
            
    open cbdbsr120001
    foreach cbdbsr120001 into mr_dados.atdsrvnum,
                              mr_dados.atdsrvano,
                              mr_dados.prsokadat,
                              mr_dados.pstcoddig

        output to report bdbsr120_relatorio()
        initialize mr_dados.* to null
        
    end foreach
    close cbdbsr120001
        
    finish report bdbsr120_relatorio
    
    call bdbsr120_envia_email()

 end function


#-------------------------------#
 function bdbsr120_envia_email()
#-------------------------------#

   define l_assunto     char(200),
          l_comando     char(200),
          l_mes_extenso char(010),
          l_erro_envio  integer

   #case m_mes_int
   #   when 01 let l_mes_extenso = 'Janeiro'
   #   when 02 let l_mes_extenso = 'Fevereiro'
   #   when 03 let l_mes_extenso = 'Marco'
   #   when 04 let l_mes_extenso = 'Abril'
   #   when 05 let l_mes_extenso = 'Maio'
   #   when 06 let l_mes_extenso = 'Junho'
   #   when 07 let l_mes_extenso = 'Julho'
   #   when 08 let l_mes_extenso = 'Agosto'
   #   when 09 let l_mes_extenso = 'Setembro'
   #   when 10 let l_mes_extenso = 'Outubro'
   #   when 11 let l_mes_extenso = 'Novembro'
   #   when 12 let l_mes_extenso = 'Dezembro'
   #end case

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relatorio de Brindes Mes de (", m_data_inicio, " a ", m_data_fim, ")", " - Porto Seguro Seguros"

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path

   run l_comando

   let m_path = m_path clipped, ".gz"      
   
   let l_erro_envio = ctx22g00_envia_email("BDBSR120", l_assunto clipped, m_path clipped)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - BDBSR120"
       end if
   end if

end function


#---------------------------------------#
 report bdbsr120_relatorio()
#---------------------------------------#

   define m_aux_char       char(1000)
   define m_brinde char(100)
   define l_brinde char(100)
   define m_grupo smallint
   define m_subgrupo smallint
   define m_prtseq  smallint
   define m_prtdes char(100)
      
   #define lr_parametro record
   #        cabecalho char(10000),
   #    linha char(10000)
   #end record

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00


   format
       first page header
           
           #open cbdbsr120004
           #     foreach cbdbsr120004 into l_brinde, l_grupo
           #         let l_cabecalho = l_cabecalho clipped, upshift(l_brinde) clipped,      ASCII(09)
           #     end foreach
           #close cbdbsr120004
                      
           #Cabecalho
           print "CODIGO PRESTADOR",            ASCII(09),
                 "NOME PRESTADOR",              ASCII(09),
                 "NUMERO SERVICO",              ASCII(09),
                 "ANO SERVICO",                 ASCII(09),
                 m_cabecalho clipped,
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
                 "SUSEP",                       ASCII(09),
                 "NOME CORRETOR",               ASCII(09),
                 "DATA ACIONAMENTO",            ASCII(09),
                 "HORA ACIONAMENTO",            ASCII(09),
                 "DATA ACERTO",                 ASCII(09),
                 "HISTORICOS",                  ASCII(09)
           skip 1 line

     on every row
                              
               open cbdbsr120002 using mr_dados.atdsrvnum, mr_dados.atdsrvano
               whenever error continue
               fetch cbdbsr120002 into mr_dados.succod, mr_dados.aplnumdig, mr_dados.itmnumdig
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode <> notfound then
                     display "Erro SELECT cbdbsr120002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                     exit program(1)
                  end if
               end if
               close cbdbsr120002
               
               open cbdbsr120003 using mr_dados.aplnumdig, mr_dados.succod
               whenever error continue
               fetch cbdbsr120003 into mr_dados.segnom
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120003
               
               open cbdbsr120013 using mr_dados.atdsrvnum, mr_dados.atdsrvano
               whenever error continue
               fetch cbdbsr120013 into mr_dados.atdsrvorg
                                      ,mr_dados.corsusldr
                                      ,mr_dados.cornom
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120013
               
               open cbdbsr120005 using mr_dados.atdsrvorg
               whenever error continue
               fetch cbdbsr120005 into mr_dados.srvtipdes
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120005
               
               open cbdbsr120008 using mr_dados.atdsrvnum, 
                                       mr_dados.atdsrvano,
                                       mr_dados.atdsrvnum, 
                                       mr_dados.atdsrvano
                                       
               whenever error continue
               fetch cbdbsr120008 into mr_dados.atdetpdat, mr_dados.srrcoddig, 
                                       mr_dados.atdvclsgl, mr_dados.socvclcod, 
                                       mr_dados.atdetphor, mr_dados.pstcoddig, 
                                       mr_dados.nomrazsoc
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120008
               
               if mr_dados.socvclcod is not null and mr_dados.socvclcod <> 0 then
                   
                   open cbdbsr120026 using mr_dados.socvclcod
                   whenever error continue
                   fetch cbdbsr120026 into mr_dados.atdvclsgl
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                       if sqlca.sqlcode <> notfound then
                           display "Erro SELECT cbdbsr120026 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2], "socvclcod = ",mr_dados.atdvclsgl
                           exit program(1)
                       end if
                   end if
                   close cbdbsr120026
                   
               end if
               
               open cbdbsr120009 using mr_dados.atdsrvnum, mr_dados.atdsrvano
               whenever error continue
               fetch cbdbsr120009 into mr_dados.cidnom, mr_dados.ufdcod
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120009
                                             
               #open cbdbsr120011 using mr_dados.pstcoddig
               #whenever error continue
               #fetch cbdbsr120011 into mr_dados.pstcoddig, mr_dados.nomrazsoc
               #whenever error stop
               #if  sqlca.sqlcode <> 0 then
               #    if  sqlca.sqlcode <> notfound then
               #        display "Erro SELECT cbdbsr120011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               #        exit program(1)
               #    end if
               #end if
               #close cbdbsr120011
               
               if  mr_dados.srrcoddig is null or mr_dados.srrcoddig = 0 then
                   let mr_dados.srrnom = " "
               else
                   
                   open cbdbsr120012 using mr_dados.srrcoddig
                   whenever error continue
                   fetch cbdbsr120012 into mr_dados.srrnom
                   whenever error stop
                   if  sqlca.sqlcode <> 0 then
                       if  sqlca.sqlcode <> notfound then
                           display "Erro SELECT cbdbsr120012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                           exit program(1)
                       end if
                   end if
                   close cbdbsr120012
                   
               end if
               
               #let m_temp = current
               #display 'antes cbdbsr120016 = ', m_temp
               #open cbdbsr120016 using mr_dados.aplnumdig, mr_dados.succod
               #whenever error continue
               #fetch cbdbsr120016 into mr_dados.corsusldr
               #
               #whenever error stop
               #if  sqlca.sqlcode <> 0 then
               #    if  sqlca.sqlcode <> notfound then
               #        display "Erro SELECT cbdbsr120016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               #        exit program(1)
               #    end if
               #end if
               #close cbdbsr120016
               #let m_temp = current
               #display 'depois cbdbsr120016 = ', m_temp
               
               #let m_temp = current
               #display 'antes cbdbsr120010 = ', m_temp
               #open cbdbsr120010 using mr_dados.corsusldr
               #whenever error continue
               #fetch cbdbsr120010 into mr_dados.cornom
               #whenever error stop
               #if  sqlca.sqlcode <> 0 then
               #    if  sqlca.sqlcode <> notfound then
               #        display "Erro SELECT cbdbsr120010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
               #        exit program(1)
               #    end if
               #end if
               #close cbdbsr120010
               #let m_temp = current
               #display 'depois cbdbsr120010 = ', m_temp
               
               open cbdbsr120020 using mr_dados.cidnom, mr_dados.ufdcod
               whenever error continue
               fetch cbdbsr120020 into mr_dados.cidcod
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120020 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120020
               
               open cbdbsr120021 using mr_dados.cidcod
               whenever error continue
               fetch cbdbsr120021 into mr_dados.cidsedcod
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120021
               
               open cbdbsr120022 using mr_dados.cidsedcod, mr_dados.ufdcod
               whenever error continue
               fetch cbdbsr120022 into mr_dados.cidsedcod, mr_dados.cidsednom
               whenever error stop
               if  sqlca.sqlcode <> 0 then
                   if  sqlca.sqlcode <> notfound then
                       display "Erro SELECT cbdbsr120022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                       exit program(1)
                   end if
               end if
               close cbdbsr120022
               
               #open cbdbsr120031 using mr_dados.atdsrvnum, mr_dados.atdsrvano
               #fetch cbdbsr120031 into mr_dados.pstcoddig, mr_dados.nomrazsoc
               #close cbdbsr120031
               
               let m_aux_char = null
               open cbdbsr120006 using mr_dados.atdsrvnum,                   
                                       mr_dados.atdsrvano                    
               foreach cbdbsr120006 into m_prtdes, mr_dados.prtsrvdes        
                   if mr_dados.prtsrvdes is not null then                    
                       let m_aux_char = m_aux_char clipped, m_prtdes clipped,
                                         " - ", mr_dados.prtsrvdes, " ; "    
                   end if                                                    
               end foreach                                                   
               close cbdbsr120006
               
               #Linha
               if  mr_dados.pstcoddig is null or mr_dados.pstcoddig = 0 then
                   print  "PRESTADOR NAO CADASTRADA", ASCII(09);
               else
                   print mr_dados.pstcoddig using '<<<<<<',       ASCII(09);
               end if
               
               if  mr_dados.nomrazsoc is null or mr_dados.nomrazsoc clipped = "" then
                   print "PRESTADOR NAO CADASTRADA",  ASCII(09);
               else
                   print mr_dados.nomrazsoc clipped,    ASCII(09);
               end if
               
               if  mr_dados.atdsrvnum is null or mr_dados.atdsrvnum = " " then
                   print "SERVICO NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.atdsrvnum using '<<<<<<<<<<',       ASCII(09);
               end if
               
               if  mr_dados.atdsrvano is null or mr_dados.atdsrvano = " " then
                   print "SERVICO NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.atdsrvano using '<<',       ASCII(09);
               end if
               
               let m_brinde = null 
               for	m_ind_1  =  1  to  m_ind_2
                   if a_bdbsr1202[m_ind_1].prtseq = -1 then
                       if m_brinde is null then
                           let m_brinde = "0"
                           print m_brinde clipped, ASCII(09);
                       end if
                       let m_brinde = null
                       continue for
                   end if
                   
                   open cbdbsr120015 using mr_dados.atdsrvnum,
                                           mr_dados.atdsrvano 
                   foreach cbdbsr120015 into m_prtseq
                                            ,l_brinde
                       if m_prtseq = a_bdbsr1202[m_ind_1].prtseq then
                           let m_brinde = l_brinde
                           print m_brinde clipped, ASCII(09);
                       end if
                   
                   end foreach       
                   close cbdbsr120015
               end	for
               
               #open cbdbsr120004
               #foreach cbdbsr120004 into l_brinde,
               #    l_grupo
               #    let l_brinde = null
               #    let l_aux_char = null
               #    open cbdbsr120014 using l_grupo
               #    foreach cbdbsr120014 into l_subgrupo
               #        open cbdbsr120015 using lr_dados.atdsrvnum,
               #            lr_dados.atdsrvano
               #            foreach cbdbsr120015 into l_prtseq
               #            if l_prtseq = l_subgrupo then
               #            open cbdbsr120017 using l_prtseq
               #            fetch cbdbsr120017 into l_brinde
               #                let l_linha = l_linha clipped, l_brinde clipped, ASCII(09);
               #            close cbdbsr120017
               #            end if
               #        end foreach
               #        close cbdbsr120015
               #        
               #        open cbdbsr120006 using lr_dados.atdsrvnum,
               #        lr_dados.atdsrvano
               #        foreach cbdbsr120006 into l_prtdes, lr_dados.prtsrvdes
               #            if lr_dados.prtsrvdes is not null then		                            
               #                let l_aux_char = l_aux_char clipped, l_prtdes clipped, 
               #                " - ", lr_dados.prtsrvdes, " | "
               #            end if
               #        end foreach
               #        close cbdbsr120006   
               #    end foreach
               #    close cbdbsr120014
               #    
               #    if l_brinde is null then
               #    let l_brinde = "0"
               #    let l_linha = l_linha clipped, l_brinde clipped, ASCII(09);
               #    end if
               #
               #end foreach
               #close cbdbsr120004
               
               if  mr_dados.atdvclsgl is null or mr_dados.atdvclsgl = " " then
                   print "SIGLA NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.atdvclsgl clipped,       ASCII(09);
               end if
               
               if  mr_dados.srrcoddig is null or mr_dados.srrcoddig = " " then
                   print "SOCORRISTA NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.srrcoddig using '<<<<<<<<',       ASCII(09);
               end if
               
               if  mr_dados.srrnom is null or mr_dados.srrnom = " " then
                   print "SOCORRISTA NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.srrnom clipped,       ASCII(09);
               end if
               
               if  mr_dados.cidnom is null or mr_dados.cidnom = " " then
                   print "CIDADE NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.cidnom clipped,       ASCII(09);
               end if
               
               if  mr_dados.cidsednom is null or mr_dados.cidsednom = " " then
                   print "CIDADE NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.cidsednom clipped,       ASCII(09);
               end if
               
               if  mr_dados.ufdcod is null or mr_dados.ufdcod = " " then
                   print "UF NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.ufdcod clipped,       ASCII(09);
               end if
               
               if  mr_dados.srvtipdes is null or mr_dados.srvtipdes = " " then
                   print "ORIGEM NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.srvtipdes clipped,       ASCII(09);
               end if
               
               if  mr_dados.succod is null or mr_dados.succod = " " then
                   print "SUCURSAL NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.succod,       ASCII(09);
               end if
               
               if  mr_dados.aplnumdig is null or mr_dados.aplnumdig = " " then
                   print "APLOICE NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.aplnumdig using '<<<<<<<<<',       ASCII(09);
               end if
               
               if  mr_dados.segnom is null or mr_dados.segnom = " " then
                   print "SEGURADO NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.segnom clipped,       ASCII(09);
               end if
               
               if  mr_dados.corsusldr is null or mr_dados.corsusldr = " " then
                   print "SUSEP NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.corsusldr clipped,       ASCII(09);
               end if
               
               if  mr_dados.cornom is null or mr_dados.cornom = " " then
                   print "CORRETOR NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.cornom clipped,       ASCII(09);
               end if
               
               if  mr_dados.atdetpdat is null or mr_dados.atdetpdat = " " then
                   print "SERVICO NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.atdetpdat,       ASCII(09);
               end if
               
               if  mr_dados.atdetphor is null or mr_dados.atdetphor = " " then
                   print "SERVICO NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.atdetphor,       ASCII(09);
               end if
               
               if  mr_dados.prsokadat is null or mr_dados.prsokadat = " " then
                   print "SERVICO NAO CADASTRADO", ASCII(09);
               else
                   print mr_dados.prsokadat,       ASCII(09);
               end if
               
               if  m_aux_char is null or m_aux_char clipped = "" then
                   print " ", ASCII(09)
               else
                   print m_aux_char  clipped,       ASCII(09)
               end if
 end report                 