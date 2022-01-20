#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SEGURO FAZ                                           #
# MODULO.........: BDBSR026                                                   #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                      #
# PSI/OSF........:                                                            #
#                  RELATÓRIO DE VENDA POLISERVICE.                            #
# ........................................................................... #
# DESENVOLVIMENTO: JOSIANE APARECIDA DE ALMEIDA                               #
# LIBERACAO......:                                                            #
#-----------------------------------------------------------------------------#
#                         * * * Alteracoes * * *                              #
#Data       Autor  Fabrica  Origem          Alteracao                         #
#---------- ------ -------- -------------- -----------------------------------#
#05/08/2015 Norton BizTalk  SPR-2015-15533 Processamento Diario, Inclusao da  #
#                           coluna valor total da Venda no relat. de retorno  #
#---------- ------ -------- -------------- -----------------------------------#
#16/09/2015 Norton BizTalk  SPR-2015-17043 Processamento Diario               #
#-----------------------------------------------------------------------------#

database porto

define m_path1        char(300)
define m_path2        char(300)

define mr_pst        record
      ciaempcod      like datmservico.ciaempcod
     ,atdetpcod      like datmservico.atdetpcod
     ,atdetpdes      like datketapa.atdetpdes
     ,c24astcod      like datmligacao.c24astcod
     ,c24astdes      like datkassunto.c24astdes
     ,cgccpfnum      like datrligcgccpf.cgccpfnum
     ,cgccpfdig      like datrligcgccpf.cgccpfdig
     ,cgcord         like datrligcgccpf.cgcord
     ,c24solnom      like datmservico.c24solnom
     ,lclcttnom      like datmlcl.lclcttnom
     ,nom            like datmservico.nom
     ,lgdtip         like datmlcl.lgdtip
     ,lgdnom         like datmlcl.lgdnom
     ,lgdnum         like datmlcl.lgdnum
     ,lclbrrnom      like datmlcl.lclbrrnom
     ,cidnom         like datmlcl.cidnom
     ,ufdcod         like datmlcl.ufdcod
     ,srrcoddig      like datmservico.srrcoddig
     ,atddat         like datmservico.atddat
     ,mes            char(2)
     ,atdsrvnum      like datmservico.atdsrvnum
     ,atdsrvano      like datmservico.atdsrvano
     ,atdhor         like datmservico.atdhor
     ,socntzcod      like datksocntz.socntzcod
     ,socntzdes      like datksocntz.socntzdes
     ,orrdat         like datmsrvre.orrdat
     ,c24pbmcod      like datkpbm.c24pbmcod
     ,c24pbmdes      like datkpbm.c24pbmdes
     ,c24pbmgrpcod   like datkpbm.c24pbmgrpcod
     ,srrnom         like datksrr.srrnom
     ,socopgitmvlr   like dbsmopgitm.socopgitmvlr
     ,socfatpgtdat   like dbsmopg.socfatpgtdat
     ,atdprinvlcod   like datmservico.atdprinvlcod
     ,atdprinvldes   char(3)
     ,atddatprg      like datmservico.atddatprg
     ,atdhorprg      like datmservico.atdhorprg
     ,funmat         like datmservico.funmat
     ,funnom         like isskfunc.funnom
     ,atdorgsrvnum   like datmsrvre.atdorgsrvnum
     ,atdorgsrvano   like datmsrvre.atdorgsrvano
     ,ratdsrvnum     like datmsrvre.atdsrvnum
     ,ratdsrvano     like datmsrvre.atdsrvano
     ,srvretmtvcod   like datksrvret.srvretmtvcod
     ,srvretmtvdes   like datksrvret.srvretmtvdes
     ,srvvndtotvlr   like datmsrvvnd.srvvndtotvlr    ##-- SPR-2015-15533-Inicio


end record

  define l_data_atual        date,
         l_hora_atual        datetime hour to minute,
         l_data_inicio       date,
         l_data_fim          date

#-----------------------------------------#
main
#-----------------------------------------#

   define l_path     char(100),
          l_sql      char(1500),
          l_param    char(100)

   define l_comando  char(700)
         ,l_retorno  smallint


  # -> ABRE O BANCO UTILIZADO PELA CENTRAL 24 HORAS
    call fun_dba_abre_banco("CT24HS")

   let l_data_atual = arg_val(1)

    if l_data_atual is null or
       l_data_atual = " " then
    # ---> OBTER A DATA E HORA DO BANCO

    call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual
    end if
    # ---> DATA DE EXTRACAO DAS INFORMACOES
    #let l_data_inicio = (l_data_atual - 7 units day)   ##--SPR-2015-15533
    #let l_data_fim = (l_data_atual - 1)                ##--SPR-2015-15533
   
    #-- Processamento Diario
  #  let l_data_inicio =  l_data_atual                   ##--SPR-2015-15533
  #  let l_data_fim    =  l_data_atual                   ##--SPR-2015-15533
    let l_data_inicio = (l_data_atual - 1 units day)     ##--SPR-2015-17043
    let l_data_fim    = (l_data_atual - 1 units day)     ##--SPR-2015-17043

    call bdbsr026_busca_path()

    call bdbsr026_prepare()

    set isolation to dirty read

    call bdbsr026()

end main

#-----------------------------------------#
function bdbsr026_busca_path()
#-----------------------------------------#
    define l_dia char(02),
           l_mes char(02),
           l_ano char(04)

    # ---> INICIALIZACAO DAS VARIAVEIS
     let m_path1 = null
     let m_path2 = null
     let l_dia  = null
     let l_mes  = null
     let l_ano  = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path1 = f_path("SAPS","LOG")
    let m_path2 = f_path("SAPS","LOG")

    if m_path1 is null then
       let m_path1 = "."
       let m_path2 = "."
    end if

    let m_path1 = m_path1 clipped,"/bdbsr026.log"
    let m_path2 = m_path2 clipped,"/bdbsr026.log"

    call startlog(m_path1)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path1 = f_path("SAPS", "RELATO")
    let m_path2 = m_path1

    if m_path1 is null then
       let m_path1 = "."
       let m_path2 = "."
    end if

    let l_dia = day(l_data_inicio)
    let l_mes = month(l_data_inicio)clipped
    let l_ano = year(l_data_inicio)

    if l_mes < 10 then
        let l_mes = "0",l_mes
    end if

    let m_path1 = m_path1 clipped , '/'
    let m_path2 = m_path1

    let m_path1 = m_path1 clipped, l_dia clipped, l_mes clipped , l_ano ,"BDBSR026_POL.xls"
    let m_path2 = m_path2 clipped, l_dia clipped, l_mes clipped , l_ano ,"BDBSR026_RET.xls"

end function

#-----------------------------------------#
function bdbsr026_prepare()
#-----------------------------------------#
      define l_sql char(9000)

      let l_sql = '  SELECT srv.ciaempcod, srv.atdetpcod, etp.atdetpdes,                       '
                 ,'       lig.c24astcod, ast.c24astdes, cpf.cgccpfnum,                         '
                 ,'       cpf.cgccpfdig, cpf.cgcord, srv.c24solnom, lcl.lclcttnom, srv.nom,    '
                 ,' lcl.lgdtip, lcl.lgdnom, lcl.lgdnum, lcl.lclbrrnom, lcl.cidnom, lcl.ufdcod, '
                 ,' srv.srrcoddig, srv.atddat, month(srv.atddat), srv.atdsrvnum, srv.atdsrvano,'
                 ,' srv.atdhor, srv.atdprinvlcod, srv.atddatprg, srv.atdhorprg, srv.funmat     '
                 ,'  FROM datmligacao lig, datmservico srv, datmlcl lcl, datketapa etp,        '
                 ,'       datkassunto ast, outer datrligcgccpf cpf                             '
                 ,' WHERE lig.c24astcod in (102,103,104)  '
                 ,'   and srv.atdsrvnum = lig.atdsrvnum   '
                 ,'   and srv.atdsrvano = lig.atdsrvano   '
                 ,'   and srv.atdsrvnum = lcl.atdsrvnum   '
                 ,'   and srv.atdsrvano = lcl.atdsrvano   '
                 ,'   and lcl.c24endtip = 1               '
                 ,'   and srv.atdetpcod = etp.atdetpcod   '
                 ,'   and ast.c24astcod = lig.c24astcod   '
                 ,'   and lig.lignum = cpf.lignum         '
              ##   ,'   and srv.atddat between ? and ?      '
                 ,'   and srv.atddat   =  ?               '

                 prepare p_ps_01 from l_sql
                 declare c_ps_01 cursor for p_ps_01


      let l_sql = 'select                         '
                 ,'      k.socntzcod,             '
                 ,'      k.socntzdes,             '
                 ,'      m.orrdat                 '
                 ,' from datmsrvre m,             '
                 ,'      datksocntz k             '
                 ,'where m.atdsrvnum = ?          '
                 ,'  and m.atdsrvano = ?          '
                 ,'  and m.socntzcod = k.socntzcod'

                 prepare p_ps_02 from l_sql
                 declare c_ps_02 cursor for p_ps_02

      let l_sql = 'select                         '
             ,'      pbm.c24pbmcod,               '
             ,'      pbm.c24pbmdes,               '
             ,'      pbm.c24pbmgrpcod             '
             ,' from                              '
             ,'      datkpbm pbm,                 '
             ,'      datrsrvpbm svp               '
             ,'where                              '
             ,'   svp.atdsrvnum = ?               '
             ,'  and svp.atdsrvano = ?            '
             ,'  and svp.c24pbmcod = pbm.c24pbmcod'

             prepare p_ps_03 from l_sql
             declare c_ps_03 cursor for p_ps_03


      let l_sql = 'select          '
                 ,'      srrnom    '
                 ,' from           '
                 ,'      datksrr   '
                 ,'where           '
                 ,'   srrcoddig = ?'

                 prepare p_ps_04 from l_sql
                 declare c_ps_04 cursor for p_ps_04


      let l_sql =  'select                             '
             ,'      itm.socopgitmvlr, opg.socfatpgtdat'
             ,' from dbsmopg opg,    '
             ,'      dbsmopgitm itm  '
             ,'where atdsrvnum = ?   '
             ,'  and atdsrvano = ?   '
             ,'  and opg.socopgnum = itm.socopgnum '

             prepare p_ps_05 from l_sql
             declare c_ps_05 cursor for p_ps_05


      let l_sql = 'select                         '
                 ,'       funnom                  '
                 ,'   from                        '
                 ,'       isskfunc iss,           '
                 ,'       datmservico srv         '
                 ,' where srv.funmat = iss.funmat '
                 ,'   and srv.empcod = iss.empcod '
                 ,'   and srv.atdsrvnum = ?       '
                 ,'   and srv.atdsrvano = ?       '

             prepare p_ps_06 from l_sql
             declare c_ps_06 cursor for p_ps_06


      let l_sql = 'select                   '
                 ,'      atdorgsrvnum onum, '
                 ,'      atdorgsrvano oano, '
                 ,'      srvretmtvcod       '
                 ,' from datmsrvre          '
                 ,'where atdsrvnum = ?      '
                 ,'  and atdsrvano = ?      '

             prepare p_ps_07 from l_sql
             declare c_ps_07 cursor for p_ps_07


      let l_sql = '  SELECT srv.ciaempcod, srv.atdetpcod, etp.atdetpdes,                       '
                 ,'       lig.c24astcod, ast.c24astdes, cpf.cgccpfnum,                         '
                 ,'       cpf.cgccpfdig, cpf.cgcord, srv.c24solnom, lcl.lclcttnom, srv.nom,    '
                 ,' lcl.lgdtip, lcl.lgdnom, lcl.lgdnum, lcl.lclbrrnom, lcl.cidnom, lcl.ufdcod, '
                 ,' srv.srrcoddig, srv.atddat, month(srv.atddat),                              '
                 ,' srv.atdhor, srv.atdprinvlcod, srv.atddatprg, srv.atdhorprg, srv.funmat     '
                 ,'  FROM datmligacao lig, datmservico srv, datmlcl lcl, datketapa etp,        '
                 ,'       datkassunto ast, outer datrligcgccpf cpf                             '
                 ,' WHERE srv.atdsrvnum = ?            '
                 ,'   and srv.atdsrvano = ?            '
                 ,'   and srv.atdsrvnum = lig.atdsrvnum'
                 ,'   and srv.atdsrvano = lig.atdsrvano'
                 ,'   and srv.atdsrvnum = lcl.atdsrvnum'
                 ,'   and srv.atdsrvano = lcl.atdsrvano'
                 ,'   and lcl.c24endtip = 1            '
                 ,'   and srv.atdetpcod = etp.atdetpcod'
                 ,'   and ast.c24astcod = lig.c24astcod'
                 ,'   and lig.lignum = cpf.lignum      '


             prepare p_ps_08 from l_sql
             declare c_ps_08 cursor for p_ps_08


      let l_sql = 'select                  '
                 ,'      d.srvretmtvdes    '
                 ,' from datksrvret d,     '
                 ,'      datmsrvre r       '
                 ,'where d.srvretmtvcod = ?'
                 ,'  and d.srvretmtvcod = r.srvretmtvcod'

             prepare p_ps_09 from l_sql
             declare c_ps_09 cursor for p_ps_09


      let l_sql = ' select                       '
                  ,'      atdsrvnum,             '
                  ,'      atdsrvano              '
                  ,' from datmligacao            '
               #   ,"where c24astcod = 'RET'      "     ##--SPR-2015-15533
                  ,'where c24astcod = "RET"      '      ##--SPR-2015-15533
                  ,'  and ciaempcod = 43         '
                  ,'  and ligdat = ?             '      ##--SPR-2015-15533
              ##    ,'  and ligdat between ? and ? '    ##--SPR-2015-15533                  

             prepare p_ps_10 from l_sql
             declare c_ps_10 cursor for p_ps_10

     ##-- SPR-2015-15533        	
      let l_sql = ' select srvvndtotvlr    '
                 ,'   from datmsrvvnd      '
                 ,'  where atdsrvnum = ?   '
                 ,'    and atdsrvano = ?   '
        
             prepare p_ps_11 from l_sql
             declare c_ps_11 cursor for p_ps_11             	

end function

#-----------------------------------------#
function bdbsr026()
#-----------------------------------------#

     display " "
     display "******Parametros do Relatório******"
     display "Data Início: ", l_data_inicio
     display "Data Fim: ", l_data_fim
     display " "

     initialize mr_pst.* to null

     start report bdbsr026_relatorio_pol to m_path1
     display "Extraindo relatório Poliservice..."

     open c_ps_01 using    l_data_inicio
                 ##         ,l_data_fim          ##--SPR-2015-15533
		 foreach c_ps_01 into  mr_pst.ciaempcod
                          ,mr_pst.atdetpcod
                          ,mr_pst.atdetpdes
                          ,mr_pst.c24astcod
                          ,mr_pst.c24astdes
                          ,mr_pst.cgccpfnum
                          ,mr_pst.cgccpfdig
                          ,mr_pst.cgcord
                          ,mr_pst.c24solnom
                          ,mr_pst.lclcttnom
                          ,mr_pst.nom
                          ,mr_pst.lgdtip
                          ,mr_pst.lgdnom
                          ,mr_pst.lgdnum
                          ,mr_pst.lclbrrnom
                          ,mr_pst.cidnom
                          ,mr_pst.ufdcod
                          ,mr_pst.srrcoddig
                          ,mr_pst.atddat
                          ,mr_pst.mes
                          ,mr_pst.atdsrvnum
                          ,mr_pst.atdsrvano
                          ,mr_pst.atdhor
                          ,mr_pst.atdprinvlcod
                          ,mr_pst.atddatprg
                          ,mr_pst.atdhorprg
                          ,mr_pst.funmat


        if mr_pst.atdprinvlcod = 3 then
        	let mr_pst.atdprinvldes = 'Sim'
        else
        	let mr_pst.atdprinvldes = 'Não'
        end if

        open c_ps_02 using mr_pst.atdsrvnum
                          ,mr_pst.atdsrvano
		    fetch c_ps_02 into mr_pst.socntzcod
		                      ,mr_pst.socntzdes
		                      ,mr_pst.orrdat

		    open c_ps_03 using mr_pst.atdsrvnum
                          ,mr_pst.atdsrvano
		    fetch c_ps_03 into mr_pst.c24pbmcod
		                      ,mr_pst.c24pbmdes
		                      ,mr_pst.c24pbmgrpcod

		    open c_ps_04 using mr_pst.srrcoddig
		    fetch c_ps_04 into mr_pst.srrnom

		    open c_ps_05 using mr_pst.atdsrvnum
		                      ,mr_pst.atdsrvano
		    fetch c_ps_05 into mr_pst.socopgitmvlr
		                      ,mr_pst.socfatpgtdat

		    open c_ps_06 using mr_pst.atdsrvnum
		                      ,mr_pst.atdsrvano
		    fetch c_ps_06 into mr_pst.funnom


        output to report bdbsr026_relatorio_pol()
        initialize mr_pst.* to null

     end foreach

     close c_ps_01
     close c_ps_02
     close c_ps_03
     close c_ps_04
     close c_ps_05
     close c_ps_06

     finish report bdbsr026_relatorio_pol

     call bdbsr026_envia_email_pol(l_data_inicio, l_data_fim)

     display "Relatório Poliservice extraído!"



     initialize mr_pst.* to null

     start report bdbsr026_relatorio_ret to m_path2
     display "Extraindo relatório de Retornos..."

     open c_ps_10 using    l_data_inicio
                      ##    ,l_data_fim              ##--SPR-2015-15533
     foreach c_ps_10 into  mr_pst.ratdsrvnum
                          ,mr_pst.ratdsrvano


     open c_ps_07 using    mr_pst.ratdsrvnum
                          ,mr_pst.ratdsrvano
     fetch c_ps_07 into    mr_pst.atdorgsrvnum
                          ,mr_pst.atdorgsrvano
                          ,mr_pst.srvretmtvcod


     open c_ps_08 using    mr_pst.ratdsrvnum
                          ,mr_pst.ratdsrvano
		 fetch c_ps_08 into    mr_pst.ciaempcod
                          ,mr_pst.atdetpcod
                          ,mr_pst.atdetpdes
                          ,mr_pst.c24astcod
                          ,mr_pst.c24astdes
                          ,mr_pst.cgccpfnum
                          ,mr_pst.cgccpfdig
                          ,mr_pst.cgcord
                          ,mr_pst.c24solnom
                          ,mr_pst.lclcttnom
                          ,mr_pst.nom
                          ,mr_pst.lgdtip
                          ,mr_pst.lgdnom
                          ,mr_pst.lgdnum
                          ,mr_pst.lclbrrnom
                          ,mr_pst.cidnom
                          ,mr_pst.ufdcod
                          ,mr_pst.srrcoddig
                          ,mr_pst.atddat
                          ,mr_pst.mes
                          ,mr_pst.atdhor
                          ,mr_pst.atdprinvlcod
                          ,mr_pst.atddatprg
                          ,mr_pst.atdhorprg
                          ,mr_pst.funmat


        if mr_pst.atdprinvlcod = 3 then
        	let mr_pst.atdprinvldes = 'Sim'
        else
        	let mr_pst.atdprinvldes = 'Não'
        end if

        open c_ps_02 using mr_pst.ratdsrvnum
                          ,mr_pst.ratdsrvano
		    fetch c_ps_02 into mr_pst.socntzcod
		                      ,mr_pst.socntzdes
		                      ,mr_pst.orrdat

		    open c_ps_03 using mr_pst.ratdsrvnum
                          ,mr_pst.ratdsrvano
		    fetch c_ps_03 into mr_pst.c24pbmcod
		                      ,mr_pst.c24pbmdes
		                      ,mr_pst.c24pbmgrpcod

		    open c_ps_04 using mr_pst.srrcoddig
		    fetch c_ps_04 into mr_pst.srrnom

		    open c_ps_05 using mr_pst.ratdsrvnum
		                      ,mr_pst.ratdsrvano
		    fetch c_ps_05 into mr_pst.socopgitmvlr
		                      ,mr_pst.socfatpgtdat

		    open c_ps_06 using mr_pst.ratdsrvnum
		                      ,mr_pst.ratdsrvano
		    fetch c_ps_06 into mr_pst.funnom


		    open c_ps_09 using mr_pst.srvretmtvcod
		    fetch c_ps_09 into mr_pst.srvretmtvdes

        ##-- SPR-2015-15533-Inicio
        open c_ps_11 using mr_pst.atdorgsrvnum
		                      ,mr_pst.atdorgsrvano
		    whenever error continue                  
 		     fetch c_ps_11 into mr_pst.srvvndtotvlr
        whenever error stop
        
        if sqlca.sqlcode <> 0 then
        	 if sqlca.sqlcode <> 100 then
        	 	  display 'Erro SELECT c_ps_11: ' ,sqlca.sqlcode,
        	 	          ' / ',sqlca.sqlerrd[2]  
        	 end if	
        end if	
        ##-- SPR-2015-15533-Fim
        
        output to report bdbsr026_relatorio_ret()
        initialize mr_pst.* to null

     end foreach

     close c_ps_10
     close c_ps_07
     close c_ps_08
     close c_ps_02
     close c_ps_03
     close c_ps_04
     close c_ps_05
     close c_ps_06
     close c_ps_09

     finish report bdbsr026_relatorio_ret

     call bdbsr026_envia_email_ret(l_data_inicio, l_data_fim)

     display "Relatório de Retornos extraído!"

end function

#-----------------------------------------#
function bdbsr026_envia_email_pol(lr_parametro)
#-----------------------------------------#

     define lr_parametro record
            data_inicial date,
            data_final   date
     end record

     define l_assunto     char(100),
            l_erro_envio  integer,
            l_comando     char(200)

     # ---> INICIALIZACAO DAS VARIAVEIS
     let l_comando    = null
     let l_erro_envio = null
     let l_assunto    = "Servicos Poliservice do periodo: ",
                        lr_parametro.data_inicial using "dd/mm/yyyy",
                        " a ",
                        lr_parametro.data_final using "dd/mm/yyyy"

     # ---> COMPACTA O ARQUIVO DO RELATORIO
     let l_comando = "gzip -f ", m_path1

     run l_comando
     let m_path1 = m_path1 clipped, ".gz"

     let l_erro_envio = ctx22g00_envia_email("BDBSR026", l_assunto, m_path1)

     if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
          display "Erro ao enviar email(ctx22g00) - ", m_path1
       else
          display "Nao existe email cadastrado para o modulo - BDBSR026"
       end if
     end if

end function

#-----------------------------------------#
function bdbsr026_envia_email_ret(lr_parametro)
#-----------------------------------------#

     define lr_parametro record
            data_inicial date,
            data_final   date
     end record

     define l_assunto     char(100),
            l_erro_envio  integer,
            l_comando     char(200)

     # ---> INICIALIZACAO DAS VARIAVEIS
     let l_comando    = null
     let l_erro_envio = null
     let l_assunto    = "Servicos de retorno do periodo: ",
                        lr_parametro.data_inicial using "dd/mm/yyyy",
                        " a ",
                        lr_parametro.data_final using "dd/mm/yyyy"

     # ---> COMPACTA O ARQUIVO DO RELATORIO
     let l_comando = "gzip -f ", m_path2

     run l_comando
     let m_path2 = m_path2 clipped, ".gz"

     let l_erro_envio = ctx22g00_envia_email("BDBSR026", l_assunto, m_path2)

     if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
          display "Erro ao enviar email(ctx22g00) - ", m_path2
       else
          display "Nao existe email cadastrado para o modulo - BDBSR026"
       end if
     end if

end function

#-------------------------------------#
report bdbsr026_relatorio_pol()
#-------------------------------------#
   output
     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02
   format

   first page header

   print "NÚMERO DO SERVIÇO",         ASCII(09),
         "ANO",                       ASCII(09),
         "EMPRESA",                   ASCII(09),
         "CÓDIGO DO ASSUNTO",         ASCII(09),
         "DESCRIÇÃO DO ASSUNTO",      ASCII(09),
         "CÓDIGO NATUREZA",           ASCII(09),
         "DESCRIÇÃO DA NATUREZA",     ASCII(09),
         "CÓDIGO DO PROBLEMA",        ASCII(09),
         "DESCRIÇÃO DO PROBLEMA",     ASCII(09),
         "DATA DE ATENDIMENTO",       ASCII(09),
         "HORA ATENDIMENTO",          ASCII(09),
         "DATA PROGRAMADA",           ASCII(09),
         "HORA PROGRAMADA",           ASCII(09),
         "SERVIÇO EMERGENCIAL",       ASCII(09),
         "CLIENTE",                   ASCII(09),
         "NUM CGC CPF",               ASCII(09),
         "NUM ORDEM",                 ASCII(09),
         "NUM DIGITO CPF",            ASCII(09),
         "NOME SOLICITANTE",          ASCII(09),
         "NOME CONTATO",              ASCII(09),
         "TIPO LOGRADOURO",           ASCII(09),
         "NOME LOGRADOURO",           ASCII(09),
         "NÚMERO LOGRADOURO",         ASCII(09),
         "BAIRRO",                    ASCII(09),
         "CIDADE",                    ASCII(09),
         "UFD",                       ASCII(09),
         "MATRÍCULA OPERADOR",        ASCII(09),
         "NOME DO OPERADOR",          ASCII(09),
         "CÓDIGO DA ETAPA",           ASCII(09),
         "DESCRIÇÃO DA ETAPA",        ASCII(09),
         "CÓDIGO SOCORRISTA",         ASCII(09),
         "NOME SOCORRISTA",           ASCII(09),
         "DATA DE PAGAMENTO",         ASCII(09),
         "CUSTO SERVIÇO"



    on every row

    print mr_pst.atdsrvnum            ,ascii(09);
    print mr_pst.atdsrvano            ,ascii(09);
    print mr_pst.ciaempcod            ,ascii(09);
    print mr_pst.c24astcod            ,ascii(09);
    print mr_pst.c24astdes    clipped ,ascii(09);
    print mr_pst.socntzcod            ,ascii(09);
    print mr_pst.socntzdes    clipped ,ascii(09);
    print mr_pst.c24pbmcod            ,ascii(09);
    print mr_pst.c24pbmdes    clipped ,ascii(09);
    print mr_pst.atddat               ,ascii(09);
    print mr_pst.atdhor               ,ascii(09);
    print mr_pst.atddatprg            ,ascii(09);
    print mr_pst.atdhorprg            ,ascii(09);
    print mr_pst.atdprinvldes clipped ,ascii(09);
    print mr_pst.nom          clipped ,ascii(09);
    print mr_pst.cgccpfnum            ,ascii(09);
    print mr_pst.cgcord               ,ascii(09);
    print mr_pst.cgccpfdig            ,ascii(09);
    print mr_pst.c24solnom    clipped ,ascii(09);
    print mr_pst.lclcttnom    clipped ,ascii(09);
    print mr_pst.lgdtip       clipped ,ascii(09);
    print mr_pst.lgdnom       clipped ,ascii(09);
    print mr_pst.lgdnum               ,ascii(09);
    print mr_pst.lclbrrnom    clipped ,ascii(09);
    print mr_pst.cidnom       clipped ,ascii(09);
    print mr_pst.ufdcod               ,ascii(09);
    print mr_pst.funmat               ,ascii(09);
    print mr_pst.funnom       clipped ,ascii(09);
    print mr_pst.atdetpcod            ,ascii(09);
    print mr_pst.atdetpdes    clipped ,ascii(09);
    print mr_pst.srrcoddig            ,ascii(09);
    print mr_pst.srrnom       clipped ,ascii(09);
    print mr_pst.socfatpgtdat         ,ascii(09);
    print mr_pst.socopgitmvlr         using "<<<<<<<&.&&"

end report


#-------------------------------------#
report bdbsr026_relatorio_ret()
#-------------------------------------#
   output
     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02
   format

   first page header

   print "NÚMERO DO SERVIÇO",            ASCII(09),
         "ANO",                          ASCII(09),
         "NÚMERO DO SERVIÇO DE ORIGEM",  ASCII(09),
         "ANO",                          ASCII(09),
         "EMPRESA",                      ASCII(09),
         "CÓDIGO DO ASSUNTO",            ASCII(09),
         "DESCRIÇÃO DO ASSUNTO",         ASCII(09),
         "CÓDIGO NATUREZA",              ASCII(09),
         "DESCRIÇÃO DA NATUREZA",        ASCII(09),
         "CÓDIGO DO PROBLEMA",           ASCII(09),
         "DESCRIÇÃO DO PROBLEMA",        ASCII(09),
         "DATA DE ATENDIMENTO",          ASCII(09),
         "HORA ATENDIMENTO",             ASCII(09),
         "DATA PROGRAMADA",              ASCII(09),
         "HORA PROGRAMADA",              ASCII(09),
         "SERVIÇO EMERGENCIAL",          ASCII(09),
         "CLIENTE",                      ASCII(09),
         "NUM CGC CPF",                  ASCII(09),
         "NUM ORDEM",                    ASCII(09),
         "NUM DIGITO CPF",               ASCII(09),
         "NOME SOLICITANTE",             ASCII(09),
         "NOME CONTATO",                 ASCII(09),
         "TIPO LOGRADOURO",              ASCII(09),
         "NOME LOGRADOURO",              ASCII(09),
         "NÚMERO LOGRADOURO",            ASCII(09),
         "BAIRRO",                       ASCII(09),
         "CIDADE",                       ASCII(09),
         "UFD",                          ASCII(09),
         "MATRÍCULA OPERADOR",           ASCII(09),
         "NOME DO OPERADOR",             ASCII(09),
         "CÓDIGO DA ETAPA",              ASCII(09),
         "DESCRIÇÃO DA ETAPA",           ASCII(09),
         "CÓDIGO SOCORRISTA",            ASCII(09),
         "NOME SOCORRISTA",              ASCII(09),
         "MOTIVO DO RETORNO",            ASCII(09),
         "VALOR TOTAL DA VENDA"


    on every row

    print mr_pst.ratdsrvnum         ,ascii(09);
    print mr_pst.ratdsrvano         ,ascii(09);
    print mr_pst.atdorgsrvnum       ,ascii(09);
    print mr_pst.atdorgsrvano       ,ascii(09);
    print mr_pst.ciaempcod          ,ascii(09);
    print mr_pst.c24astcod          ,ascii(09);
    print mr_pst.c24astdes          ,ascii(09);
    print mr_pst.socntzcod          ,ascii(09);
    print mr_pst.socntzdes          ,ascii(09);
    print mr_pst.c24pbmcod          ,ascii(09);
    print mr_pst.c24pbmdes          ,ascii(09);
    print mr_pst.atddat             ,ascii(09);
    print mr_pst.atdhor             ,ascii(09);
    print mr_pst.atddatprg          ,ascii(09);
    print mr_pst.atdhorprg          ,ascii(09);
    print mr_pst.atdprinvlcod       ,ascii(09);
    print mr_pst.nom                ,ascii(09);
    print mr_pst.cgccpfnum          ,ascii(09);
    print mr_pst.cgcord             ,ascii(09);
    print mr_pst.cgccpfdig          ,ascii(09);
    print mr_pst.c24solnom          ,ascii(09);
    print mr_pst.lclcttnom          ,ascii(09);
    print mr_pst.lgdtip             ,ascii(09);
    print mr_pst.lgdnom             ,ascii(09);
    print mr_pst.lgdnum             ,ascii(09);
    print mr_pst.lclbrrnom          ,ascii(09);
    print mr_pst.cidnom             ,ascii(09);
    print mr_pst.ufdcod             ,ascii(09);
    print mr_pst.funmat             ,ascii(09);
    print mr_pst.funnom             ,ascii(09);
    print mr_pst.atdetpcod          ,ascii(09);
    print mr_pst.atdetpdes          ,ascii(09);
    print mr_pst.srrcoddig          ,ascii(09);
    print mr_pst.srrnom             ,ascii(09);
    print mr_pst.srvretmtvdes       ,ascii(09);
    print mr_pst.srvvndtotvlr                     ##-- SPR-2015-15533-Inicio
end report