#------------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                   #
# Modulo     : bdbsr124                                                        #
# Programa   : bdbsr124 - Relatorio de atendimento por sucursais               #
#------------------------------------------------------------------------------#
# Analista Resp. : Raji/Cristiane                                              #
# PSI            : 206911                                                      #
#                                                                              #
# Desenvolvedor  : Fabrica de sfw                                              #
# DATA           : 05/04/2007                                                  #
#..............................................................................#
# Data        Autor      Alteracao                                             #
#                                                                              #
# ----------  ---------  ------------------------------------------------------#
# 09/09/2009  Raji       Ajuste de regra de reclamação.                        #
# 29/06/2010  Robert     PSI258466 - Novos Quadros, adicionando qtd de diarias #
#                        para carro extra.                                     #
# 26/10/2010  Robert     Envio dos arquivos por email, relatorio ira rodar     #
#                        automatico                                            #
# 11/11/2010  Robert     Aumento do tamanho oda variavel m_cmd para 5000       #
# 20/03/2012  Issamu     Controle do ano anterior para ano bisexto             #
# 11/05/2012  Thiago F   Alteração para emitir relatorios das empresas 35-azul #
#                        e 84-itau  -  PSI-2012-03848                          #
# 08/10/2012  Issamu     Implementação de controle de restart                  #
# 19/05/2015  Fornax,RCP FX-190515 - Incluir relatorios analiticos Atendidos e #
#                        Pagos (Todas as Sucursais).                           #
#------------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define hie_susep record
   coragpcod       char(6),
   coragpnom       char(40),
   corsus          char(6),
   corsuspcp       char(6),
   corgrpcod       char(6),
   succod          like pcgksuc.succod,
   iptcod          like gabkins.iptcod,
   iptnom          like gabkins.iptnom,
   msgerr          char(78)
end record

define ws record
   atdsrvnum    like datmservico.atdsrvnum,
   atdsrvano    like datmservico.atdsrvano,
   c24pagdiaqtd decimal(6,0), #adicionado campo quantidades de diarias pagas
   coragpcod    char(6),
   coragpnom    char(40),
   corsus       char(6),
   corsuspcp    char(6),
   corgrpcod    char(6),
   succod       decimal(2,0),
   regcod       like gabkins.iptcod,
   regnom       like gabkins.iptnom,
   ufdcod       char(2),
   cidnom       char(45),
   pstcoddig    like dpaksocor.pstcoddig,
   lcvcod       like dbsmopg.lcvcod,
   atdsrvorg    like datmservico.atdsrvorg,
   vlrsaida     decimal(12,2),
   vlradicional decimal(12,2),
   valor        decimal(12,2),
   qtdreclam    integer,
   doctxt       char(40),
   maxsrvnum    like datmservico.atdsrvnum,
   atddat       like datmservico.atddat,  #--> FX-190515
   socfatpgtdat like dbsmopg.socfatpgtdat #--> FX-190515
end record

define rel record
   atdsrvnum    like datmservico.atdsrvnum,
   atdsrvano    like datmservico.atdsrvano,
   c24pagdiaqtd decimal(6,0), #adicionado campo quantidades de diarias pagas
   doctxt       char(40),
   coragpcod    char(6),
   coragpnom    char(40),
   corsuspcp    char(6),
   corpcpnom    char(40),
   corgrpcod    char(6),
   corgrpnom    char(40),
   cornom       like gcakcorr.cornom,
   succod       decimal(2,0),
   sucnom       like gabksuc.sucnom,
   regcod       like gcbkinsp.iptcod,
   regnom       like gabkins.iptnom,
   ufdcod       char(2),
   cidnom       char(45),
   pstcoddig    like dpaksocor.pstcoddig,
   nomgrr       char(40),
   atdsrvorg    like datmservico.atdsrvorg,
   srvtipdes    like datksrvtip.srvtipdes,
   qtdatd       integer,
   vlratual     decimal(12,2),
   vlrmesant    decimal(12,2),
   vlranoant    decimal(12,2),
   qtdreclam    integer,
   permesant    decimal(12),
   peranoant    decimal(12),
   indrec       decimal(12)
end record

define  m_datinicial        date,
        m_datfinal          date,
        m_datprcini         date,
        m_datprcfim         date,
        m_datastr           char(10),
        m_path              char(100),
        m_sql               char(3000),
        m_tab               char(1),
        m_cont              smallint,
        m_cont_aux          smallint,
        m_succod            smallint,
        m_forper            smallint,
        m_periodo           char(7),
        m_arquivo           char(100),
        m_arquivo_txt       char(100),
        m_arquivo_pgt       char(100), #--> FX-190515
        m_arquivo_atd       char(100), #--> FX-190515
        m_arquivo_pgt_txt   char(100),
        m_arquivo_atd_txt   char(100),
        m_cmd               char(5000),
        m_peratual          char(7),
        m_permesant         char(7),
        m_peranoant         char(7),
        m_qtdDiarias        decimal(6,0),
        m_DelTabela         char(5),
        m_resumoCont        smallint,
        m_resumoData        date,
        m_resumoHora        datetime hour to fraction,
        m_email_dest        char(3000),
        m_email_aux         char(50),
        m_bisexto           smallint,
        m_empresa_par       smallint,
        m_succod_par        smallint,
        m_empnom            char(40),
        m_sucnom            like gabksuc.sucnom,
        m_empresa           char(15),
        m_mes               char(02),
        m_ano               char(04)

define mr_anexo record
    arquivoPgt   char(300)
   ,arquivoHtm   char(300)
   ,arquivoAtd   char(300)
end record

main

   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   let g_issk.empcod = 1
   let g_issk.funmat = 9904
   let g_issk.usrtip = 'F'

   #---------------------------------------------------------------
   # Inicia o LOG
   #---------------------------------------------------------------
   let m_path = f_path("DBS","LOG")
   if  m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped,"/bdbsr124.log"
   call startlog(m_path)

   #---------------------------------------------------------------
   # Define diretorios para relatorios e arquivos
   #---------------------------------------------------------------
   call f_path("DBS", "ARQUIVO")
        returning m_path
   if m_path is null then
      let m_path = "."
   end if

   #---------------------------------------------------------------
   # Cria tabelas work para o relatorio
   #---------------------------------------------------------------
   #recebe o argumento digitado na chamada do bacth
   let m_DelTabela = arg_val(1)
   call bdbsr124_create_tables_work()

   #---------------------------------------------------------------
   # Prepara comandos
   #---------------------------------------------------------------
   call bdbsr124_prepare()

   #---------------------------------------------------------------
   # Verifica se recebeu a data de processamento como argumento
   #---------------------------------------------------------------
   let m_datastr = arg_val(2)

   if m_datastr is null or
      m_datastr = " "  then
      let m_datastr =  today
   else
      let m_datinicial = m_datastr
      if m_datinicial is null then
         display "*** ERRO NO PARAMETRO: DATA INVALIDA ! ***"
         exit program(1)
      end if
   end if

   #Determina  as datas conforme o parametro ou today
   let m_bisexto = false
   let m_datastr = "01", m_datastr[3,10]
   let m_datinicial = m_datastr
   let m_datinicial = m_datinicial - 1 units month
   let m_datfinal   = m_datinicial + 1 units month - 1 units day
   if (year(m_datfinal) mod 4 ) = 0 and month(m_datfinal) = 2   then
      let m_bisexto = true
      display 'Ano bisexto'
   end if

   #Apresenta data de processamento
   display "Periodo de processamento: ", m_datinicial, " a ", m_datfinal

   #---------------------------------------------------------------
   # Verifica se recebeu a empresa de processamento como argumento
   #---------------------------------------------------------------
   initialize m_empresa_par to null
   let m_empresa_par  = arg_val(3)

   if m_empresa_par is not null then
      display "EMPRESA ",m_empresa_par, " RECEBIDA COMO PARAMETRO PARA PROCESSAMENTO."
   end if

   #---------------------------------------------------------------
   # Verifica se recebeu a empresa de processamento como argumento
   #---------------------------------------------------------------
   let m_succod_par = arg_val(4)
   if m_succod_par is not null then
      display "SUCURSAL ",m_succod_par, " RECEBIDA COMO PARAMETRO PARA PROCESSAMENTO."
   end if

   #---------------------------------------------------------------
   # Chama os Relatorios
   #---------------------------------------------------------------
   if m_empresa_par is null then
      call bdbsr124_relatorio(1)
      call bdbsr124_relatorio(35)
      call bdbsr124_relatorio(84)
   else
      call bdbsr124_relatorio(m_empresa_par)
   end if


end main



#-----------------------------------#
 function bdbsr124_prepare_sucursal()
#-----------------------------------#
  define l_sql   char(1500)

   let l_sql = " select succod ",
                 " from gabksuc "

   if m_succod_par is not null then
      let l_sql = l_sql clipped, " where succod = ", m_succod_par
   end if

   whenever error continue
   prepare p_sucursal from l_sql
   whenever error stop
   IF status <> 0 then
      display "Erro ", sqlca.sqlcode, " ao buscar as sucursais."
      return
   END IF

   whenever error continue
   declare c_sucursal cursor for p_sucursal
   whenever error stop
   IF status <> 0 then
      display "Erro ", sqlca.sqlcode, " ao buscar as sucursais."
      return
   END IF

 end function

#--------------------------#
 function bdbsr124_prepare()
#--------------------------#

   let m_sql = "select srv.atdsrvnum, ",
                     " srv.atdsrvano, ",
                     " acp.pstcoddig, ",
                     " srv.atdsrvorg, ",
                     " srv.atddat     ", #--> FX-190515
                " from datmservico srv, ",
                     " datmsrvacp acp ",
               " where srv.atdsrvnum = acp.atdsrvnum ",
                 " and srv.atdsrvano = acp.atdsrvano ",
                 " and srv.atdsrvseq = acp.atdsrvseq ",
                 " and srv.atdsrvorg not in (10,11,14,15,16) ",
                 " and acp.atdetpcod in (3,4,5) ",
                 " and acp.atdetpdat between ? and ? ",
                 " and srv.ciaempcod = ? ",
                 " and acp.atdsrvnum > ? ",
               " order by acp.atdsrvnum"
   prepare pbdbsr12401 from m_sql
   declare cbdbsr12401 cursor for pbdbsr12401

   let m_sql = "select itm.atdsrvnum, ",
                     " itm.atdsrvano, ",
                     " opg.pstcoddig, ",
                     " opg.lcvcod, ",
                     " srv.atdsrvorg, ",
                     " itm.socopgitmvlr, ",
                     " itm.c24pagdiaqtd, ",
                     " sum(cst.socopgitmcst), ",
                     " opg.socfatpgtdat ", #--> FX-190515
                " from dbsmopgitm itm, ",
                     " datmservico srv, ",
                     " dbsmopg opg, ",
                     " outer dbsmopgcst cst ",
               " where opg.socopgnum = itm.socopgnum ",
                 " and itm.atdsrvnum = srv.atdsrvnum ",
                 " and itm.atdsrvano = srv.atdsrvano ",
                 " and itm.socopgnum = cst.socopgnum ",
                 " and itm.socopgitmnum = cst.socopgitmnum ",
                 " and srv.ciaempcod = ? ",
                 " and opg.socopgsitcod = 7 ",
                 " and opg.socfatpgtdat between ? and ? ",
                 " and itm.atdsrvnum > ? ",
               " group by  1,2,3,4,5,6,7,9", #--> FX-190515
               " order by itm.atdsrvnum "
   prepare pbdbsr12404 from m_sql
   declare cbdbsr12404 cursor for pbdbsr12404

   let m_sql = "select ufdcod,",
               "       cidnom ",
               "  from datmlcl ",
               " where c24endtip = 1 ",
               "   and atdsrvnum = ? ",
               "   and atdsrvano = ? "
   prepare pbdbsr12402 from m_sql
   declare cbdbsr12402 cursor for pbdbsr12402

   let m_sql = " select sucnom ",
                " from  gabksuc ",
                " where succod = ? "
   prepare pbdbsr12405 from m_sql
   declare cbdbsr12405 cursor for pbdbsr12405

   let m_sql = " select srvtipdes ",
                " from  datksrvtip ",
                " where atdsrvorg = ? "
   prepare pbdbsr12406 from m_sql
   declare cbdbsr12406 cursor for pbdbsr12406

   let m_sql = "select cornom ",
               "  from gcakcorr, gcaksusep ",
               " where gcakcorr.corsuspcp = gcaksusep.corsuspcp ",
               "   and corsus = ? "
   prepare pbdbsr12407 from m_sql
   declare cbdbsr12407 cursor for pbdbsr12407

   let m_sql = "select iptcod, iptnom ",
               "  from gabkins ",
               " where nivcod = ? ",
               "   and hiecod = ? ",
               "   and iptstt = 'A'"
   prepare pbdbsr12409 from m_sql
   declare cbdbsr12409 cursor for pbdbsr12409

####### QUERY SUBSTITUIDA CONFORME ORIENTACAO DO WILLIAM DO SAC ###############
###   let m_sql = "select count(distinct a.sacocrnum) Ocorrencias",
###               "  from sjcmocr a,",
###               "       sjctobj b,",
###               "       sjctobj c,",
###               "       sjctobj d,",
###               "       sjcmocradc e,",
###               "       sjctobj f,",
###               "       sjcmocrsrv h",
###               " where h.sacocrnum = a.sacocrnum",
###               "   and h.atdsrvnum = ? ",
###               "   and h.atdsrvano = ? ",
###               "   and b.sacobjcod = a.sacocrclscod",
###               "   and c.sacobjcod = b.sacobjpcpcod",
###               "   and d.sacobjcod = c.sacobjpcpcod",
###               "   and ( (b.sacobjdes in ('PORTO SOCORRO - AUTO', ",
###               "                          'PORTO SOCORRO - CARTÕES', ",
###               "                          'PORTO SOCORRO - FROTA COMPARTILHADA',",
###               "                          'PORTO SOCORRO - HELP DESK',",
###               "                          'PORTO SOCORRO - LINHA BRANCA',",
###               "                          'PORTO SOCORRO - LINHA BÁSICA',",
###               "                          'PORTO SOCORRO - LOCADORAS') and",
###               "          b.sacobjtip = 514 and",
###               "          b.sacobjpcpcod = 604)",
###               "        or",
###               "         (c.sacobjdes in ('PORTO SOCORRO - AUTO', ",
###               "                          'PORTO SOCORRO - CARTÔES', ",
###               "                          'PORTO SOCORRO - FROTA COMPARTILHADA',",
###               "                          'PORTO SOCORRO - HELP DESK',",
###               "                          'PORTO SOCORRO - LINHA BRANCA',",
###               "                          'PORTO SOCORRO - LINHA BÁSICA',",
###               "                          'PORTO SOCORRO - LOCADORAS') and",
###               "          c.sacobjtip = 514 and",
###               "          c.sacobjpcpcod = 604)",
###               "        or",
###               "         (d.sacobjdes in ('PORTO SOCORRO - AUTO', ",
###               "                          'PORTO SOCORRO - CARTÔES', ",
###               "                          'PORTO SOCORRO - FROTA COMPARTILHADA',",
###               "                          'PORTO SOCORRO - HELP DESK',",
###               "                          'PORTO SOCORRO - LINHA BRANCA',",
###               "                          'PORTO SOCORRO - LINHA BÁSICA',",
###               "                          'PORTO SOCORRO - LOCADORAS') and",
###               "          d.sacobjtip = 514 and",
###               "          d.sacobjpcpcod = 604)",
###               "       )",
###               "   and e.sacocrnum = a.sacocrnum",
###               "   and f.sacobjcod = e.sacocradcitm",
###               "   and f.sacobjtip = 512",
###               "   and f.sacobjpcpcod = 7354",
###               "   and a.sacocrclscod not in (select g.sacobjcod",
###               "                                from sjctobj g",
###               "                               where g.sacobjdes = 'SINALISADOR PARA A ÁREA'",
###               "                                 and g.sacobjtip = 516)",
###               "   and h.exchordat is null"
   let m_sql = "select count(distinct a.sacocrnum) Ocorrencias ",
                " from sjcmocr a, ",
                     " sjctobj b, ",
                     " sjctobj c, ",
                     " sjctobj d, ",
                     " sjcmocradc e, ",
                     " sjctobj f, ",
                     " sjcmocrsrv h, ",
                     " sjcmocradc g ",
               " where h.sacocrnum = a.sacocrnum ",
                 " and h.atdsrvnum = ? ",
                 " and h.atdsrvano = ? ",
                 " and b.sacobjcod = a.sacocrclscod ",
                 " and c.sacobjcod = b.sacobjpcpcod ",
                 " and d.sacobjcod = c.sacobjpcpcod ",
                 " and ( (b.sacobjdes like 'PORTO SOCORRO -%' and ",
                        " b.sacobjtip = 514 and ",
                        " b.sacobjpcpcod = 604) ",
                      " or ",
                       " (c.sacobjdes like 'PORTO SOCORRO -%' and ",
                        " c.sacobjtip = 514 and ",
                        " c.sacobjpcpcod = 604) ",
                      " or ",
                       " (d.sacobjdes like 'PORTO SOCORRO -%' and ",
                        " d.sacobjtip = 514 and ",
                        " d.sacobjpcpcod = 604) ",
                      " ) ",
                 " and e.sacocrnum = a.sacocrnum ",
                 " and f.sacobjcod = e.sacocradcitm ",
                 " and f.sacobjtip = 512 ",
                 " and f.sacobjpcpcod = 7354 ",
                 " and h.exchordat is null ",
                 " and g.sacocrnum = a.sacocrnum ",
                 " and g.sacocradcitm = 277546 ",
                 " and g.sacocradccnt like '%|SIM' "
   prepare pbdbsr12410 from m_sql
   declare cbdbsr12410 cursor for pbdbsr12410

   let m_sql = "select nomgrr ",
               "  from dpaksocor",
               " where pstcoddig = ? "
   prepare pbdbsr12411 from m_sql
   declare cbdbsr12411 cursor for pbdbsr12411

   let m_sql = "select lcvnom ",
               "  from datklocadora",
               " where lcvcod = ? "
   prepare pbdbsr12413 from m_sql
   declare cbdbsr12413 cursor for pbdbsr12413

   let m_sql = "select corsuspcp ",
               "  from gcaksusep ",
               " where corsus = ? "
   prepare pbdbsr12414 from m_sql
   declare cbdbsr12414 cursor for pbdbsr12414

   let m_sql = "select endufd, endcid ",
               "  from datmavisrent, datkavislocal ",
               " where datmavisrent.atdsrvnum = ? ",
               "   and datmavisrent.atdsrvano = ? ",
               "   and datmavisrent.aviestcod = datkavislocal.aviestcod"
   prepare pbdbsr12415 from m_sql
   declare cbdbsr12415 cursor for pbdbsr12415

   let m_sql = "select corgrpcod ",
               "  from pcgksusep ",
               " where corsus = ? "
   prepare pbdbsr12416 from m_sql
   declare cbdbsr12416 cursor for pbdbsr12416

   let m_sql = "select corgrpnom ",
               "  from gcbkgrupo ",
               " where corgrpcod = ? "
   prepare pbdbsr12417 from m_sql
   declare cbdbsr12417 cursor for pbdbsr12417

   let m_sql = " select relpamtxt "
              ,"   from igbmparam "
              ,"  where relsgl = ? "
   prepare pbdbsr12418 from m_sql
   declare cbdbsr12418 cursor for pbdbsr12418

   let m_sql = " select corsus "
                ," from datmservico "
               ," where atdsrvnum = ? "
                 ," and atdsrvano = ? "
   prepare pbdbsr12419 from m_sql
   declare cbdbsr12419 cursor for pbdbsr12419

 end function

#-------------------------------
 function bdbsr124_compact(l_arq)
#-------------------------------

  define l_comand char(100)
  define l_arq    char(500)

  let l_comand = "gzip -f ", l_arq

  run l_comand
  let l_arq    = l_arq clipped, ".gz"
  return l_arq

end function

#---------------------------#
report bdbsr124_rpt(param)
#---------------------------#
 define param record
    empcod    like gabkemp.empcod,
    succod    like pcgksuc.succod
 end record

 output
  left   margin  000
  top    margin  000
  bottom margin  000
  page   length  001

 format
  on every row

      # Obtem descricao da sucursal
      initialize rel.sucnom to null
      open cbdbsr12405 using param.succod
      fetch cbdbsr12405 into rel.sucnom
      close cbdbsr12405

      print '<html>'
      print '<style>'
      print 'body { background-color: #FFFFFF; font-family: tahoma, arial; font-size: 11px; font-color: #000000; margin: 0; text-align: center; }'
      print '#cabecalho h1 { width: 99%; font-size: 20px; font-weight: bold; background-position: right center; background-repeat: no-repeat; color: #87AFFE; margin: 2px 0 2px 0; padding: 2px 0 2px 5px; }'
      print '.borda_canto { background-color: #FFFFFF; width: 1px; height: 1px; }'
      print '.borda_horizontal { background-color: #87AFFE; height: 1px; }'
      print '.borda_vertical { background-color: #87AFFE; width: 1px; }'
      print '.fundo { padding-left: 2px; padding-right: 2px; }'
      print 'h2 { clear: both; background-color: #87AFFE; font-size:11px; font-weight:bold; color:#fff; padding: 3px 0 3px 3px; margin: 2px 0 2px 0; }'
      print 'table.tabela { font-size: 11px; width: 100%; border-collapse: collapse; margin: 0; padding: 0; margin: 2px 0 2px 0; }'
      print 'table.tabela tr th { border:1px solid #aaa; padding: 2px; font-weight: bold; background-color: #DADADA; color: #1b70e1; }'
      print 'table.tabela tr td { border:1px solid #aaa; padding: 3px; }'
      print 'table.tabela tr td.head { font-weight: bold; }'
      print '</style>'

      # BODY INICIO
      print '<body><div id="cabecalho"><h1>Porto Socorro - Relatório de Sucursais ', m_peratual clipped,'(confidencial)</h1></div><br><table cellspacing=0 cellpadding=0 border=0 width=900><tr><td class=borda_canto></td><td class=borda_horizontal></td><td clas',
              's=borda_canto></td></tr><tr><td class=borda_vertical></td><td class=fundo><h2>Quadros Sintéticos</h2>'

      # TABELA Empresa - INICIO
      print '<table class="tabela"><tr><th colspan="10">Empresa</th></tr><tr><td class="head" width="20%" colspan="2">Empresa</td><td class="head" align="left" width="80%">Nome da empresa</td></tr>',
            '<tr><td class="head" width="20%" colspan="2">',param.empcod,'</td><td class="head" align="left" width="80%">',m_empnom clipped,'</td></tr>'
      print '</table><br>'
      # TABELA Empresa - FIM

      # TABELA SUCURSAL
      print '<table class="tabela"><tr><th colspan="10">Sucursais</th></tr><tr><td class="head" width="150" colspan="2">Sucursal</td><td class="head" align="right" width="150">Atendimentos</td><td class="h',
              'ead" align="right" width="150">Pagos Mês</td><td class="head" align="right" width="150" colspan="2">Pagos Mês Ant.</td><td class="head" align="right" width="150" colspan="2">Pagos Ano Ant.</td',
              '><td class="head" align="right" width="150" colspan="2">Reclamações</td></tr>'

      select count(*) into rel.qtdatd
        from work:srvatd
       where periodo = m_peratual
         and succod  = param.succod
         and empcod  = param.empcod

      select sum(qtdreclam) into rel.qtdreclam
        from work:srvatd
       where periodo = m_peratual
         and succod = param.succod
         and empcod = param.empcod

      select sum(valor) into rel.vlratual
        from work:srvpagos
       where periodo = m_peratual
         and succod  = param.succod
         and empcod  = param.empcod

      select sum(valor) into rel.vlrmesant
        from work:srvpagos
       where periodo = m_permesant
         and succod = param.succod
         and empcod = param.empcod

      select sum(valor) into rel.vlranoant
        from work:srvpagos
       where periodo = m_peranoant
         and succod  = param.succod
         and empcod  = param.empcod

      # Calcula percentual em relacao ao mes anterior
      if rel.vlrmesant <> 0 then
         let rel.permesant = (rel.vlratual / rel.vlrmesant-1)*100
      else
         let rel.permesant = 0
      end if
      # Calcula percentual em relacao ao ano anterior
      if rel.vlranoant <> 0 then
         let rel.peranoant = (rel.vlratual / rel.vlranoant-1)*100
      else
         let rel.peranoant = 0
      end if
      # Calcula indice em mil de reclamacoes
      let rel.indrec = rel.qtdreclam / rel.qtdatd * 1000

      print '<tr>',
      '<td>',param.succod using "<<<&",'</td>',
      '<td>',rel.sucnom clipped, '</td>',
      '<td align="right">',rel.qtdatd using "<<<<<&",'</td>',
      '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      '<td align="right">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
      if rel.permesant <> 0 then
         print '<td align="right">',rel.permesant using "-<<<",'%</td>';
      else
         print '<td></td>';
      end if
      print  '<td align="right">',rel.vlranoant using "<<<<<<<&.&&",'</td>';
      if rel.peranoant <> 0 then
         print '<td align="right">',rel.peranoant using "-<<<",'%</td>';
      else
         print '<td></td>';
      end if
      print  '<td align="right">',rel.qtdreclam using "<<<<&",'</td>',
      '<td align="right">',rel.indrec using "<<<<&",' em 1000</td>',
        '</tr>'

      # TABELA SUCURSAL FIM
      print '</table><br>'


      # TABELA REGIONAL
      print '<table class="tabela"><tr><th colspan="9">Regionais</th></tr><tr><td class="head" width="225">Regional/Produtor</td><td class="head" align="right" width="125">Atendimentos</td><td class="head" align="r',
              'ight" width="125">Pagos Mês</td><td class="head" align="right" width="150" colspan="2">Pagos Mês Ant.</td><td class="head" align="right" width="150" colspan="2">Pagos Ano Ant.</td><td class="h',
              'ead" align="right" width="125" colspan="2">Reclamações</td></tr>'

      declare q2 cursor for
         select regcod,
                regnom,
                count(*)
           from work:srvatd
          where periodo = m_peratual
            and succod  = param.succod
            and empcod  = param.empcod
         group by 1,2
         order by 3 desc

      foreach q2 into rel.regcod,
                      rel.regnom,
                      rel.qtdatd

         select sum(qtdreclam) into rel.qtdreclam
           from work:srvatd
          where periodo = m_peratual
            and regcod  = rel.regcod
            and succod  = param.succod
            and empcod  = param.empcod

         select sum(valor) into rel.vlratual
           from work:srvpagos
          where periodo = m_peratual
            and regcod  = rel.regcod
            and succod  = param.succod
            and empcod  = param.empcod

         select sum(valor) into rel.vlrmesant
           from work:srvpagos
          where periodo = m_permesant
            and regcod  = rel.regcod
            and succod  = param.succod
            and empcod  = param.empcod

         select sum(valor) into rel.vlranoant
           from work:srvpagos
          where periodo = m_peranoant
            and regcod  = rel.regcod
            and succod  = param.succod
            and empcod  = param.empcod

         # Calcula percentual em relacao ao mes anterior
         if rel.vlrmesant <> 0 then
            let rel.permesant = (rel.vlratual / rel.vlrmesant-1)*100
         else
            let rel.permesant = 0
         end if
         # Calcula percentual em relacao ao ano anterior
         if rel.vlranoant <> 0 then
            let rel.peranoant = (rel.vlratual / rel.vlranoant-1)*100
         else
            let rel.peranoant = 0
         end if
         # Calcula indice em mil de reclamacoes
         let rel.indrec = rel.qtdreclam / rel.qtdatd * 1000

         print '<tr>',
               '<td>',rel.regnom clipped,'</td>',
               '<td align="right">',rel.qtdatd using "<<<<<&",'</td>',
               '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
               '<td align="right">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
         if rel.permesant <> 0 then
            print '<td align="right">',rel.permesant using "-<<<",'%</td>';
         else
            print '<td></td>';
         end if
         print  '<td align="right">',rel.vlranoant using "<<<<<<<&.&&",'</td>';
         if rel.peranoant <> 0 then
            print '<td align="right">',rel.peranoant using "-<<<",'%</td>';
         else
            print '<td></td>';
         end if
         print  '<td align="right">',rel.qtdreclam using "<<<<&",'</td>',
                '<td align="right">',rel.indrec using "<<<<&",' em 1000</td>',
                '</tr>'

      end foreach
      # TABELA REGIONAL FIM
      print '</table><br>'

      declare q3 cursor for
         select coragpcod,
                coragpnom,
                count(*)
           from work:srvatd
          where periodo = m_peratual
            and succod  = param.succod
            and empcod  = param.empcod
         group by 1,2
         order by 3 desc

      # TABELA CORRETOR
      print '<table class="tabela"><tr><th colspan="8">Corretores/Grupos</th></tr><tr><td class="head" width="300" colspan="2">Corretor/Grupo</td><td class="head" align="right" width="150">Atendimentos</td><td class="h',
              'ead" align="right" width="150">Pagos Mês</td><td class="head" align="right" width="150" colspan="2">Pagos Mês Ant.</td><td class="head" align="right" width="150" colspan="2">Pagos Ano Ant.</td',
              '></tr>'
      let m_cont = 1
      foreach q3 into rel.coragpcod,
                      rel.coragpnom,
                      rel.qtdatd

         if m_cont > 10 then
            exit foreach
         end if
         let m_cont = m_cont + 1

         select sum(qtdreclam) into rel.qtdreclam
           from work:srvatd
          where periodo = m_peratual
            and coragpcod = rel.coragpcod
            and succod = param.succod
            and empcod = param.empcod

         select sum(valor) into rel.vlratual
           from work:srvpagos
          where periodo = m_peratual
            and coragpcod = rel.coragpcod
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlrmesant
           from work:srvpagos
          where periodo   = m_permesant
            and coragpcod = rel.coragpcod
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlranoant
           from work:srvpagos
          where periodo   = m_peranoant
            and coragpcod = rel.coragpcod
            and succod    = param.succod
            and empcod    = param.empcod

         # Calcula percentual em relacao ao mes anterior
         if rel.vlrmesant <> 0 then
            let rel.permesant = (rel.vlratual / rel.vlrmesant-1)*100
         else
            let rel.permesant = 0
         end if
         # Calcula percentual em relacao ao ano anterior
         if rel.vlranoant <> 0 then
            let rel.peranoant = (rel.vlratual / rel.vlranoant-1)*100
         else
            let rel.peranoant = 0
         end if

         print '<tr>',
      		'<td>',rel.coragpcod,'</td>',
      		'<td>',rel.coragpnom clipped,'</td>',
      		'<td align="right">',rel.qtdatd using "<<<<<&",'</td>',
      		'<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
                '<td align="right">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
         if rel.permesant <> 0 then
            print '<td align="right">',rel.permesant using "-<<<",'%</td>';
         else
            print '<td></td>';
         end if
      	 print '<td align="right">',rel.vlranoant using "<<<<<<<&.&&",'</td>';
         if rel.peranoant <> 0 then
            print '<td align="right">',rel.peranoant using "-<<<",'%</td>';
         else
            print '<td></td>';
         end if
         print  '</tr>'

      end foreach
      # TABELA CORRETOR FIM
      print '</table><br>'

      declare q4 cursor for
         select ufdcod,
                cidnom,
                count(*)
           from work:srvatd
          where periodo = m_peratual
            and succod  = param.succod
            and empcod  = param.empcod
         group by 1,2
         order by 3 desc

      # TABELA CIDADE
      print '<table class="tabela"><tr><th colspan="10">Cidades</th></tr><tr><td class="head" width="200" colspan="2">Cidade</td><td class="head" align="right" width="125">Atendimentos</td><td class="head"',
              ' align="right" width="125">Pagos Mês</td><td class="head" align="right" width="150" colspan="2">Pagos Mês Ant.</td><td class="head" align="right" width="150" colspan="2">Pagos Ano Ant.</td><td',
              ' class="head" align="right" width="150" colspan="2">Reclamações</td></tr>'
      let m_cont = 1
      foreach q4 into rel.ufdcod,
                      rel.cidnom,
                      rel.qtdatd

         if m_cont > 10 then
            exit foreach
         end if
         let m_cont = m_cont + 1

         select sum(qtdreclam) into rel.qtdreclam
           from work:srvatd
          where periodo = m_peratual
            and ufdcod  = rel.ufdcod
            and cidnom  = rel.cidnom
            and succod  = param.succod
            and empcod  = param.empcod

         select sum(valor) into rel.vlratual
           from work:srvpagos
          where periodo = m_peratual
            and ufdcod  = rel.ufdcod
            and cidnom  = rel.cidnom
            and succod  = param.succod
            and empcod  = param.empcod

         select sum(valor) into rel.vlrmesant
           from work:srvpagos
          where periodo = m_permesant
            and ufdcod  = rel.ufdcod
            and cidnom  = rel.cidnom
            and succod  = param.succod
            and empcod  = param.empcod

         select sum(valor) into rel.vlranoant
           from work:srvpagos
          where periodo = m_peranoant
            and ufdcod  = rel.ufdcod
            and cidnom  = rel.cidnom
            and succod  = param.succod
            and empcod  = param.empcod

         # Calcula percentual em relacao ao mes anterior
         if rel.vlrmesant <> 0 then
            let rel.permesant = (rel.vlratual / rel.vlrmesant-1)*100
         else
            let rel.permesant = 0
         end if
         # Calcula percentual em relacao ao ano anterior
         if rel.vlranoant <> 0 then
            let rel.peranoant = (rel.vlratual / rel.vlranoant-1)*100
         else
            let rel.peranoant = 0
         end if
         # Calcula indice em mil de reclamacoes
         let rel.indrec = rel.qtdreclam / rel.qtdatd * 1000

         print '<tr>',
      		'<td>',rel.ufdcod,'</td>',
      		'<td>',rel.cidnom clipped,'</td>',
      		'<td align="right">',rel.qtdatd using "<<<<<&",'</td>',
      		'<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      		'<td align="right">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
         if rel.permesant <> 0 then
            print '<td align="right">',rel.permesant using "-<<<",'%</td>';
         else
            print '<td></td>';
         end if
         print  '<td align="right">',rel.vlranoant using "<<<<<<<&.&&",'</td>';
         if rel.peranoant <> 0 then
            print '<td align="right">',rel.peranoant using "-<<<",'%</td>';
         else
            print '<td></td>';
         end if
         print  '<td align="right">',rel.qtdreclam using "<<<<&",'</td>',
      		'<td align="right">',rel.indrec using "<<<<&",' em 1000</td>',
      	'</tr>'

      end foreach
      # TABELA CIDADE FIM
      print '</table><br>'


      declare q5 cursor for
         select pstcoddig,
                count(*)
           from work:srvatd
          where periodo = m_peratual
            and succod  = param.succod
            and empcod  = param.empcod
         group by 1
         order by 2 desc

      # TABELA PRESTADOR
      print '<table class="tabela"><tr><th colspan="10">Prestadores</th></tr><tr><td class="head" width="200" colspan="2">Prestador</td><td class="head" align="right" width="125">Atendimentos</td><td class',
              '="head" align="right" width="125">Pagos Mês</td><td class="head" align="right" width="150" colspan="2">Pagos Mês Ant.</td><td class="head" align="right" width="150" colspan="2">Pagos Ano Ant.<',
              '/td><td class="head" align="right" width="150" colspan="2">Reclamações</td></tr>'
      let m_cont = 1
      foreach q5 into rel.pstcoddig,
                      rel.qtdatd

         if m_cont > 10 then
            exit foreach
         end if
         let m_cont = m_cont + 1

         select sum(qtdreclam) into rel.qtdreclam
           from work:srvatd
          where periodo   = m_peratual
            and pstcoddig = rel.pstcoddig
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlratual
           from work:srvpagos
          where periodo = m_peratual
            and pstcoddig = rel.pstcoddig
            and succod = param.succod
            and empcod = param.empcod

         select sum(valor) into rel.vlrmesant
           from work:srvpagos
          where periodo   = m_permesant
            and pstcoddig = rel.pstcoddig
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlranoant
           from work:srvpagos
          where periodo = m_peranoant
            and pstcoddig = rel.pstcoddig
            and succod = param.succod

         # Obtem nome do prestador
         initialize rel.nomgrr to null
         if rel.pstcoddig > 900000 then
            let rel.pstcoddig = rel.pstcoddig - 900000
            open cbdbsr12413 using rel.pstcoddig
            fetch cbdbsr12413 into rel.nomgrr
            close cbdbsr12413
            let rel.pstcoddig = rel.pstcoddig + 900000
         else
            open cbdbsr12411 using rel.pstcoddig
            fetch cbdbsr12411 into rel.nomgrr
            close cbdbsr12411
         end if

         # Calcula percentual em relacao ao mes anterior
         if rel.vlrmesant <> 0 then
            let rel.permesant = (rel.vlratual / rel.vlrmesant-1)*100
         else
            let rel.permesant = 0
         end if
         # Calcula percentual em relacao ao ano anterior
         if rel.vlranoant <> 0 then
            let rel.peranoant = (rel.vlratual / rel.vlranoant-1)*100
         else
            let rel.peranoant = 0
         end if
         # Calcula indice em mil de reclamacoes
         let rel.indrec = rel.qtdreclam / rel.qtdatd * 1000

         #alterado Robert Obter qtd diarias de locação m_qtdDiarias
         let rel.c24pagdiaqtd = 0
         select sum(c24pagdiaqtd) into rel.c24pagdiaqtd
           from work:srvpagos
          where periodo   = m_peratual
            and pstcoddig = rel.pstcoddig
            and succod    = param.succod
            and empcod    = param.empcod

         if rel.c24pagdiaqtd > 0 then
            print '<tr>',
      	          '<td>',rel.pstcoddig,'</td>',
      	          '<td  width="175px">',rel.nomgrr clipped,'</td>',
      	          '<td align="right" width="17%">',rel.qtdatd using "<<<<<&",' locações /  ',rel.c24pagdiaqtd,' diarias pagas','</td>',
      	          '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      	          '<td align="right" width="30px">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
         else
            print '<tr>',
                  '<td>',rel.pstcoddig,'</td>',
                  '<td  width="175px">',rel.nomgrr clipped,'</td>',
                  '<td align="right" width="17%">',rel.qtdatd using "<<<<<&",'</td>',
                  '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
                  '<td align="right" width="30px">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
         end if

         if rel.permesant <> 0 then
            print '<td align="right" width="30px">',rel.permesant using "-<<<",'%</td>';
         else
            print '<td width="30px"></td>';
         end if
         print  '<td align="right" width="30px">',rel.vlranoant using "<<<<<<<&.&&",'</td>';
         if rel.peranoant <> 0 then
            print '<td align="right" width="30px">',rel.peranoant using "-<<<",'%</td>';
         else
            print '<td width="30px"></td>';
         end if
         print  '<td align="right">',rel.qtdreclam using "<<<<&",'</td>',
      		'<td align="right">',rel.indrec using "<<<<&",' em 1000</td>',
      	'</tr>'


      end foreach
      # TABELA PRESTADOR FIM
      print '</table><br>'

      declare q6 cursor for
         select distinct atdsrvorg
           from work:srvpagos
          where periodo = m_peratual
            and succod  = param.succod
            and empcod  = param.empcod
         order by atdsrvorg

      # TABELA SRV MAIS CAROS
      #print '<table class="tabela"><tr><th colspan="5">Serviços mais caros pagos no período</th></tr><tr><td class="head" width="150">Serviço</td><td class="head" width="300">Documento</td><td class="head"',
      #        ' width="300" colspan="2">Tipo de serviço</td><td class="head" align="right" width="150">Valor</td></tr>'
      foreach q6 into rel.atdsrvorg

	 declare q7 cursor for
            select atdsrvnum,
                   atdsrvano,
                   doctxt,
                   valor
              from work:srvpagos
             where periodo   = m_peratual
               and succod    = param.succod
               and atdsrvorg = rel.atdsrvorg
               and empcod    = param.empcod
            order by valor desc

           initialize rel.srvtipdes to null
           open cbdbsr12406 using rel.atdsrvorg
           fetch cbdbsr12406 into rel.srvtipdes
           close cbdbsr12406

           if rel.atdsrvorg == 8 then
                print '<table class="tabela"><tr><th colspan="5">Serviços ',rel.srvtipdes clipped,' mais caros pagos no período</th></tr>',
                      '<tr><td class="head" width="150">Serviço</td><td class="head" width="150">QTD Diarias Pagas</td><td class="head" width="300">Documento</td>',
                      '<td class="head" align="right" width="150">Valor</td></tr>'
           else
                print '<table class="tabela"><tr><th colspan="4">Serviços ',rel.srvtipdes clipped,' mais caros pagos no período</th></tr><tr><td class="head" width="150">Serviço</td><td class="head" width="300">Documento</td>',
                      '<td class="head" align="right" width="150">Valor</td></tr>'
           end if

           let m_cont_aux = 0

         foreach q7 into rel.atdsrvnum,
                         rel.atdsrvano,
                         rel.doctxt,
                         rel.vlratual

           if m_cont_aux > 10 then
            exit foreach
           end if
           let m_cont_aux = m_cont_aux + 1

           if rel.atdsrvorg == 8 then

                select sum(c24pagdiaqtd) into rel.c24pagdiaqtd
                      from work:srvpagos
                     where periodo   = m_peratual
                       and atdsrvnum = rel.atdsrvnum
                       and atdsrvano = rel.atdsrvano
                       and succod    = param.succod
                       and empcod    = param.empcod

                print '<tr>',
      		      '<td>',rel.atdsrvnum using "#######", "-", rel.atdsrvano using "&&",'</td>',
      		      '<td>',rel.c24pagdiaqtd clipped using "####",'</td>',
      		      '<td>',rel.doctxt clipped,'</td>',
      		      '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      	              '</tr>'
           else

                print '<tr>',
      		      '<td>',rel.atdsrvnum using "#######", "-", rel.atdsrvano using "&&",'</td>',
      		      '<td>',rel.doctxt clipped,'</td>',
      		      '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      	              '</tr>'
      	   end if

        end foreach
        # TABELA SRV MAIS CAROS FIM
           print '</table><br>'
      end foreach



      declare q8 cursor for
         select atdsrvorg,
                count(*)
           from work:srvatd
          where periodo = m_peratual
            and succod  = param.succod
            and empcod  = param.empcod
         group by 1
         order by 2 desc

      # TABELA QTDE SERVICOS
      print '<table class="tabela"><tr><th colspan="10">Atendimentos por tipo de serviço</th></tr><tr><td class="head" width="225" colspan="2">Tipo de serviço</td><td class="head" align="right" width',
              '="125">Atendimentos</td><td class="head" align="right" width="125">Pagos Mês</td><td class="head" align="right" width="150" colspan="2">Pagos Mês Ant.</td><td class="head" align="right" width=',
              '"150" colspan="2">Pagos Ano Ant.</td><td class="head" align="right" width="125" colspan="2">Reclamações</td></tr>'

      foreach q8 into rel.atdsrvorg,
                      rel.qtdatd

         select sum(qtdreclam) into rel.qtdreclam
           from work:srvatd
          where periodo   = m_peratual
            and atdsrvorg = rel.atdsrvorg
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlratual
           from work:srvpagos
          where periodo   = m_peratual
            and atdsrvorg = rel.atdsrvorg
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlrmesant
           from work:srvpagos
          where periodo   = m_permesant
            and atdsrvorg = rel.atdsrvorg
            and succod    = param.succod
            and empcod    = param.empcod

         select sum(valor) into rel.vlranoant
           from work:srvpagos
          where periodo   = m_peranoant
            and atdsrvorg = rel.atdsrvorg
            and succod    = param.succod
            and empcod    = param.empcod

         initialize rel.srvtipdes to null
         open cbdbsr12406 using rel.atdsrvorg
         fetch cbdbsr12406 into rel.srvtipdes
         close cbdbsr12406

         # Calcula percentual em relacao ao mes anterior
         if rel.vlrmesant <> 0 then
            let rel.permesant = (rel.vlratual / rel.vlrmesant-1)*100
         else
            let rel.permesant = 0
         end if
         # Calcula percentual em relacao ao ano anterior
         if rel.vlranoant <> 0 then
            let rel.peranoant = (rel.vlratual / rel.vlranoant-1)*100
         else
            let rel.peranoant = 0
         end if
         # Calcula indice em mil de reclamacoes
         let rel.indrec = rel.qtdreclam / rel.qtdatd * 1000

	 if rel.atdsrvorg == 8 then
               select sum(c24pagdiaqtd) into rel.c24pagdiaqtd
                     from work:srvpagos
                    where periodo = m_peratual
                      and succod  = param.succod
                      and empcod  = param.empcod

               print '<tr>',
      	             '<td>',rel.atdsrvorg using "<<&",'</td>',
      	             '<td width="175px">',rel.srvtipdes clipped,'</td>',
      	             '<td align="right" width="17%">',rel.qtdatd using "<<<<<&",' locações / ',rel.c24pagdiaqtd,' diárias pagas','</td>',
      	             '<td align="right">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      	             '<td align="right">',rel.vlrmesant using "<<<<<<<&.&&",
      		     '</td>';
         else
               print '<tr>',
      		     '<td>',rel.atdsrvorg using "<<&",'</td>',
      		     '<td width="175px">',rel.srvtipdes clipped,'</td>',
      		     '<td align="right">',rel.qtdatd using "<<<<<&",'</td>',
      		     '<td align="right" width="10%">',rel.vlratual using "<<<<<<<&.&&",'</td>',
      		     '<td align="right" width="30px">',rel.vlrmesant using "<<<<<<<&.&&",'</td>';
         end if

         if rel.permesant <> 0 then
            print '<td align="right" width="30px">',rel.permesant using "-<<<",'%</td>';
         else
            print '<td width="30px"></td>';
         end if
         print  '<td align="right" width="30px">',rel.vlranoant using "<<<<<<<&.&&",'</td>';
         if rel.peranoant <> 0 then
            print '<td align="right" width="30px">',rel.peranoant using "-<<<",'%</td>';
         else
            print '<td width="30px"></td>';
         end if
         print  '<td align="right">',rel.qtdreclam using "<<<<&",'</td>',
      		'<td align="right">',rel.indrec using "<<<<&",' em 1000</td>',
      	'</tr>'


      end foreach
      # TABELA QTDE SERVICOS FIM
      print '</table>'

      # BODY FIM
      print '</td><td class=borda_vertical></td></tr><tr><td class=borda_canto></td><td class=borda_horizontal></td><td class=borda_canto></td></tr></table><br><br></body>'
      print '</html>'

end report


#------------------------------------
function bdbsr124_obtemcorretor(lr_parametro)
#------------------------------------

define lr_parametro record
   atdsrvnum     like datmservico.atdsrvnum,
   atdsrvano     like datmservico.atdsrvano
end record

define lr_retorno record
   succod          like datrligapol.succod,      # Codigo Sucursal
   ramcod          like datrservapol.ramcod,     # Codigo Ramo
   aplnumdig       like datrligapol.aplnumdig,   # Numero Apolice
   itmnumdig       like datrligapol.itmnumdig,   # Numero do Item
   edsnumref       like datrligapol.edsnumref,   # Numero do Endosso
   prporg          like datrligprp.prporg,       # Origem da Proposta
   prpnumdig       like datrligprp.prpnumdig,    # Numero da Proposta
   crtsaunum       like datksegsau.crtsaunum,    # Cartao Saude
   corsus          like gcaksusep.corsus,        # Corretor
   doctxt          char(40)
end record

 define pa_fgeral1_ret record
        segnom     like gsakseg.segnom,
        corsus     like apamcor.corsus,
        ramcod     like gtakram.ramcod,
        cornom     like gcakcorr.cornom,
        prptip     like apamcapa.prptip ,
        unocod     like gcaksusep.unocod
 end record

define l_resultado    integer,
       l_mensagem     char(100),
       l_aplnumdig    like datrligapol.aplnumdig,   # Numero Apolice
       l_succod       like datrligapol.succod,      # Codigo Sucursal
       l_ramcod       like datrservapol.ramcod,     # Codigo Ramo
       l_itmnumdig    like datrligapol.itmnumdig,   # Numero do Item
       l_ramgrpcod    like gtakram.ramgrpcod,       # Grupo de ramo
       l_sgrorg       like rsamseguro.sgrorg,       # Orgiem Seguro RE
       l_sgrnumdig    like rsamseguro.sgrnumdig,    # Numero Seguro RE
       l_crtnum       like datrsrvsau.crtnum,       # Numero do cartao saude
       l_lignum       like datmligacao.lignum,      # Numero da ligacao
       l_cornom       char(100),                    # Nome do corretor
       l_prporg       like datrligprp.prporg,       # Origem proposta
       l_prpnumdig    like datrligprp.prpnumdig,    # Numero da proposta
       l_cmnnumdig    like rptmcmn.cmnnumdig        # Contrato do patrimonial



{define l_param record
   ramcod      like datrservapol.ramcod   ,
   succod      like datrligapol.succod    ,
   aplnumdig   like datrligapol.aplnumdig ,
   prporg      like datrligprp.prporg     ,
   prpnumdig   like datrligprp.prpnumdig  ,
   segnumdig   like gsaksegger.segnumdig  ,
   cgccpfnum   like gsakseg.cgccpfnum     ,
   cgccpfdig   like gsakseg.cgccpfdig
end record}

define l_param record
    ramcod    like vtamcap.ramcod
   ,succod    like vtamdoc.succod
   ,aplnumdig like vtamdoc.aplnumdig
   ,prporg    like vtamdoc.prporg
   ,prpnumdig like vtamdoc.prpnumdig
   ,segnumdig like vtamdoc.segnumdig
   ,cgccpfnum like vtamseguro.cgccpfnum
   ,cgccpfdig like vtamseguro.cgccpfdig
end record


define l_cta01m32vida    record
       msg           char(80),
       tipo          char(02),  #VN Vida Nova/VI Vida Individual/VG Vida Grupo
       existe_massa  smallint,  # 0 NAO Tem Massa / 1 TEM MASSA
       empcod      dec(2,0)                    ,   ---> Nilo
       ramcod      smallint                    ,
       succod      like  vtamdoc.succod        ,
       aplnumdig   like  vtamdoc.aplnumdig     ,
       vdapdtcod   like  vtamseguro.vdapdtcod  ,
       vdapdtdes   like  vgpkprod.vdapdtdes    ,
       prporg      like  vtamdoc.prporg        ,
       prpnumdig   like  vtamdoc.prpnumdig     ,
       emsdat      like  vtamdoc.emsdat        ,
       viginc      like  vtamdoc.viginc        ,
       vigfnl      like  vtamdoc.vigfnl        ,
       prpstt      like  vtamdoc.prpstt        ,
       cpodes      like iddkdominio.cpodes     ,
       segnumdig   like  gsakseg.segnumdig     ,
       segnom      like  gsakseg.segnom        ,
       nscdat      like  gsakseg.nscdat        ,
       segsex      like  gsakseg.segsex        ,
       endlgdtip   like  gsakend.endlgdtip     ,
       endlgd      like  gsakend.endlgd        ,
       endnum      like  gsakend.endnum        ,
       endbrr      like  gsakend.endbrr        ,
       endcid      like  gsakend.endcid        ,
       endufd      like  gsakend.endufd        ,
       endcep      like  gsakend.endcep        ,
       corsuspcp   like  gcakcorr.corsuspcp    ,
       cornom      like  gcakcorr.cornom
end record

initialize lr_retorno.* to null
initialize pa_fgeral1_ret.* to null
initialize l_param.* to null
initialize l_cta01m32vida.* to null


#verifica se documento e do tipo apolice
call cts20g13_obter_apolice(lr_parametro.atdsrvnum,
                            lr_parametro.atdsrvano)
     returning l_resultado,
               l_mensagem,
               l_aplnumdig,
               l_succod,
               l_ramcod,
               l_itmnumdig

if l_resultado = 1 then   ### APOLICE
   #encontrou dados da apolice para o servico - logo tipo documento e apolice

   let lr_retorno.succod    = l_succod
   let lr_retorno.ramcod    = l_ramcod
   let lr_retorno.aplnumdig = l_aplnumdig
   let lr_retorno.itmnumdig = l_itmnumdig
   let lr_retorno.doctxt    = "Apl: ", lr_retorno.succod using "&&",
                              "-", lr_retorno.ramcod using "&&&",
                              "-", lr_retorno.aplnumdig using "<<<<<<<<<<<&",
                              "-", lr_retorno.itmnumdig using "<<<<<<<<&"
   #let lr_retorno.edsnumref = l_edsnumref

   call cty10g00_grupo_ramo(1,
                            l_ramcod)
        returning l_resultado,
                  l_mensagem,
                  l_ramgrpcod

   case l_ramgrpcod
      when 1
         #AUTOMOVEL
         select corsus into lr_retorno.corsus
           from  abamcor
          where succod    = l_succod
            and aplnumdig = l_aplnumdig
            and corlidflg = 'S'

         return lr_retorno.corsus,
                lr_retorno.doctxt

      when 2
         #2-TRANSPORTES
         select  sgrorg   , sgrnumdig
                 into l_sgrorg, l_sgrnumdig
           from  rsamseguro
          where succod    = l_succod
            and ramcod    = l_ramcod
            and aplnumdig = l_aplnumdig

         select corsus into lr_retorno.corsus
          from  rsampcorre
          where rsampcorre.sgrorg    = l_sgrorg
            and rsampcorre.sgrnumdig = l_sgrnumdig
            and rsampcorre.corlidflg = "S"

         return lr_retorno.corsus,
                lr_retorno.doctxt

      when 4
          #4-RE
         declare q9 cursor for
         select  sgrorg   , sgrnumdig
           from  rsamseguro
          where succod    = l_succod
            and ramcod    = l_ramcod
            and aplnumdig = l_aplnumdig

	 open q9 using l_succod,
                       l_ramcod,
                       l_aplnumdig

	 fetch q9 into l_sgrorg,l_sgrnumdig

         select corsus into lr_retorno.corsus
          from  rsampcorre
          where rsampcorre.sgrorg    = l_sgrorg
            and rsampcorre.sgrnumdig = l_sgrnumdig
            and rsampcorre.corlidflg = "S"

         return lr_retorno.corsus,
                lr_retorno.doctxt

      when 3
         # VIDA
         let l_param.ramcod    = l_ramcod
         let l_param.succod    = l_succod
         let l_param.aplnumdig = l_aplnumdig

         call fvita008_vida(l_param.*)
              returning l_resultado,l_cta01m32vida.*

         let lr_retorno.corsus = l_cta01m32vida.corsuspcp

         return lr_retorno.corsus,
                lr_retorno.doctxt

      ###5 SAUDE
      ###SO PELO CARTAO ***** NAO TEM APOLICE  *********
   end case

end if

#verifica se documento e do tipo saude
call cts20g10_cartao(1,
                     lr_parametro.atdsrvnum,
                     lr_parametro.atdsrvano)
     returning l_resultado,
               l_mensagem,
               l_crtnum

if l_resultado = 1 then
   call cts20g10_cartao(2,
                        lr_parametro.atdsrvnum,
                        lr_parametro.atdsrvano)
        returning l_resultado,
                  l_mensagem,
                  l_succod,
                  l_ramcod ,
                  l_aplnumdig,
                  l_crtnum

   let lr_retorno.doctxt    = "Cat.Saude: ", l_crtnum

   if l_resultado = 1 then
      #Obter corsus da tabela do saúde
      call cta01m15_sel_datksegsau (2,
                                    l_crtnum,
                                    "",
                                    "",
                                    "" )
           returning l_resultado,
                     l_mensagem,
                     lr_retorno.corsus,
                     l_cornom

      return lr_retorno.corsus,
             lr_retorno.doctxt
   end if
end if

#busca numero da ligacao do servico
call cts20g00_servico(lr_parametro.atdsrvnum,
                      lr_parametro.atdsrvano)
     returning l_lignum

#verifica se documento e propsta
call cts20g00_proposta(l_lignum)
     returning l_resultado
              ,l_mensagem
              ,l_prporg
              ,l_prpnumdig
if l_resultado = 1 then

   let lr_retorno.doctxt    = "Proposta: ", l_prporg using "&&", "-", l_prpnumdig using "<<<<<<<<<<<<<&"

   #PROPOSTA
   call pa_fgeral1(l_prporg, l_prpnumdig)
        returning pa_fgeral1_ret.*

   let lr_retorno.corsus = pa_fgeral1_ret.corsus

   return lr_retorno.corsus,
          lr_retorno.doctxt
end if

#verifica se documento e contrato
call cts20g12_contrato(l_lignum)
     returning l_resultado,
               l_mensagem,
               l_cmnnumdig
if l_resultado = 1 then

   let lr_retorno.doctxt    = "Contrato: ", l_cmnnumdig using "<<<<<<<<<<<<<&"

   #encontrou dados do contrato para servico , logo documento e contrato
   select corsus into lr_retorno.corsus
     from rptmcmn
    where cmnnumdig = l_cmnnumdig

   return lr_retorno.corsus,
          lr_retorno.doctxt
end if

let lr_retorno.corsus = ""
let lr_retorno.doctxt = "Sem Documento"


return lr_retorno.corsus,
       lr_retorno.doctxt

end function

#--------------------------------------#
function bdbsr124_hie_corretor(l_corsus)
#--------------------------------------#

 define l_corsus char(06),
        l_nivcod smallint

 define w_retorno_fpcgc052 record
    inpcod          like  gcaksusep.inpcod,
    succod          like  pcgksuc.succod,
    msgerr          char (78)
 end record

 define p03_sai052    record
    inpnom            like gcbkinsp.inpnom
   ,pdtcod            like gcbkprod.pdtcod
   ,pdtnom            like gcbkprod.pdtnom
   ,succod            like gcbkprod.succod
   ,msgerr            char(78)
 end record

 initialize hie_susep.* to null

 let hie_susep.corsus    = l_corsus

 # Busca NOME da SUSEP
 # open cbdbsr12407 using hie_susep.corsus
 # fetch cbdbsr12407 into hie_susep.cornom
 # close cbdbsr12407

 # Busca a SUSEP principal
 open cbdbsr12414 using hie_susep.corsus
 fetch cbdbsr12414 into hie_susep.corsuspcp
 close cbdbsr12414

  #select corsuspcp
  #  into hie_susep.corsuspcp
  #  from gcaksusep
  # where corsus = hie_susep.corsus


 # Busca grupo da SUSEP
 open cbdbsr12416 using hie_susep.corsus
 fetch cbdbsr12416 into hie_susep.corgrpcod
 close cbdbsr12416

 if hie_susep.corgrpcod is null or hie_susep.corgrpcod = 0 then
    let hie_susep.coragpcod = hie_susep.corsuspcp

    # Busca NOME da SUSEP principal
    open cbdbsr12407 using hie_susep.corsuspcp
    fetch cbdbsr12407 into hie_susep.coragpnom
    close cbdbsr12407

 else
    let hie_susep.coragpcod = hie_susep.corgrpcod

    # Busca NOME do grupo da SUSEP
    open cbdbsr12417 using hie_susep.corgrpcod
    fetch cbdbsr12417 into hie_susep.coragpnom
    close cbdbsr12417

 end if

 # Obtem sucursal e regional do servico
 call fpcgc052_suc_susep(l_corsus)
      returning w_retorno_fpcgc052.*

 let hie_susep.succod = w_retorno_fpcgc052.succod

 call fpcgc052_hie_insp(w_retorno_fpcgc052.inpcod)
      returning p03_sai052.*

 let l_nivcod = 2
 open cbdbsr12409 using l_nivcod,
                        p03_sai052.pdtcod
 fetch cbdbsr12409 into hie_susep.iptcod,
                        hie_susep.iptnom

 if sqlca.sqlcode <> 0 then
    let l_nivcod = 1
    open cbdbsr12409 using l_nivcod,
                           w_retorno_fpcgc052.inpcod
    fetch cbdbsr12409 into hie_susep.iptcod,
                           hie_susep.iptnom
    if sqlca.sqlcode <> 0 then
       let hie_susep.iptcod = p03_sai052.pdtcod
       let hie_susep.iptnom = p03_sai052.pdtnom
    end if
 end if
 close cbdbsr12409

 return hie_susep.*

end function

#---------------------------------#
function bdbsr124_relatorio(param)
#---------------------------------#

  define param record
     empcod  like gabkemp.empcod
  end record
  define lr_verifica record
         suc like pcgksuc.succod,
         emp like gabkemp.empcod,
         per char (07),
         flg smallint
  end record

  define lr_mail record
         rem     char(50)
        ,des     char(250)
        ,ccp     char(250)
        ,cco     char(250)
        ,ass     char(500)
        ,msg     char(32000)
        ,idr     char(20)
        ,tip     char(4)
  end record
  
  define l_data      date
  define l_dataarq    char(8)

  define l_retorno smallint

  define l_succod like pcgksuc.succod
  initialize lr_verifica.* to null
  let m_empnom      = bdbsr124_busca_empnom(param.empcod)

   initialize mr_anexo.* to null

   initialize ws to null
   
   let l_data = today
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)  

   let m_tab = ascii(9)

   for m_forper=1 to 3

      case m_forper
         when 1
              #######################################################
              # Pesquisa no periodo do relatorio
              #######################################################
              let m_datprcini = m_datinicial
              let m_datprcfim = m_datfinal
              let m_peratual = m_datprcini using "mm/yyyy"
              let m_periodo   = m_peratual

         when 2
             #########################################################################
             # Pesquisa no mes anterior ao periodo do relatorio
             #########################################################################
             let m_datprcini = m_datinicial - 1 units month
             let m_datprcfim = m_datfinal   - 1 units month

             if m_datprcfim is null then
                let m_datprcfim = m_datprcini + 1 units month - 1 units day
             end if

             let m_permesant = m_datprcini using "mm/yyyy"
             let m_periodo   = m_permesant

         when 3
             #########################################################################
             # Pesquisa no ano anterior ao periodo do relatorio
             #########################################################################
             if m_bisexto then
                let m_datfinal = m_datfinal - 1 units day
             end if
             let m_datprcini = m_datinicial - 1 units year
             let m_datprcfim = m_datfinal   - 1 units year
             let m_peranoant = m_datprcini using "mm/yyyy"
             let m_periodo   = m_peranoant

      end case

      display "   ", m_periodo, " - ", m_datprcini, " a ", m_datprcfim

      ##############################
      # Pesquisa serviços atendidos
      ##############################
      initialize ws.maxsrvnum to null
      SET LOCK MODE TO WAIT 10
      select max(atdsrvnum) into ws.maxsrvnum
        from work:srvatd
       where periodo = m_periodo
         and empcod  = param.empcod

      if ws.maxsrvnum is null then
         let ws.maxsrvnum = 1000000 - 1  # Todos os servicos
      else
         display "      Servicos atendidos maiores que ", ws.maxsrvnum using "&&&&&&&"
      end if

      let m_resumoCont = 0;

      display "===========[RESUMO srvatd]================="
      open cbdbsr12401 using  m_datprcini,
                              m_datprcfim,
                              param.empcod,
                              ws.maxsrvnum
      foreach cbdbsr12401 into ws.atdsrvnum,
                               ws.atdsrvano,
                               ws.pstcoddig,
                               ws.atdsrvorg,
                               ws.atddat #--> FX-190515

         let m_resumoCont = m_resumoCont + 1
         ##########[LOG RESUMO A CADA 10000 REGISTROS]#######################
         if m_resumoCont = 10000 then
            let m_resumoData = today
            let m_resumoHora = current

            display "Resumo do processo - ",m_resumoData,"  ",m_resumoHora
            display "Lidos: ",m_resumoCont clipped
            display "-------------------------------------------"
         end if
         ###################################################################
         if ws.atdsrvorg = 8 then # Carro-Extra
            let ws.pstcoddig = ws.pstcoddig + 900000
         end if

         # Obtem uf e cidade do servico
         if ws.atdsrvorg = 8 then  # Carro-Extra
            open cbdbsr12415 using ws.atdsrvnum,
                                   ws.atdsrvano
            fetch cbdbsr12415 into ws.ufdcod,
                                   ws.cidnom
            close cbdbsr12415
         else
            open cbdbsr12402 using ws.atdsrvnum,
                                   ws.atdsrvano
            fetch cbdbsr12402 into ws.ufdcod,
                                   ws.cidnom
            close cbdbsr12402
         end if

         # Obtem corsus do servico
         call bdbsr124_obtemcorretor(ws.atdsrvnum,
                                     ws.atdsrvano)
         returning ws.corsus,
                   ws.doctxt

         # Obtem o corretor do servico caso nao seja localizado pelo documento
         if ws.corsus is null or ws.corsus = ' ' then
            open cbdbsr12419 using ws.atdsrvnum, ws.atdsrvano
            fetch cbdbsr12419 into ws.corsus
            close cbdbsr12419
         end if

         call bdbsr124_hie_corretor (ws.corsus)
              returning hie_susep.*

         let ws.coragpcod = hie_susep.coragpcod
         let ws.coragpnom = hie_susep.coragpnom
         let ws.corsus    = hie_susep.corsus
         let ws.corsuspcp = hie_susep.corsuspcp
         let ws.corgrpcod = hie_susep.corgrpcod
         let ws.succod    = hie_susep.succod
         let ws.regcod    = hie_susep.iptcod
         let ws.regnom    = hie_susep.iptnom

         # Obtem a quantidade de reclamacoes do servico
         open cbdbsr12410 using ws.atdsrvnum,
                                ws.atdsrvano
         fetch cbdbsr12410 into ws.qtdreclam
         close cbdbsr12410

         # Insere regitro na tabela temporaria
         insert into work:srvatd values ( m_periodo,
                                          ws.atdsrvnum,
                                          ws.atdsrvano,
                                          ws.coragpcod,
                                          ws.coragpnom,
                                          ws.corsus,
                                          ws.corsuspcp,
                                          ws.corgrpcod,
                                          ws.succod,
                                          ws.regcod,
                                          ws.regnom,
                                          ws.ufdcod,
                                          ws.cidnom,
                                          ws.pstcoddig,
                                          ws.atdsrvorg,
                                          ws.qtdreclam,
                                          ws.doctxt,
                                          param.empcod,
                                          ws.atddat) #--> FX-190515

          initialize ws.* to null
          let m_resumoCont = m_resumoCont + 1

      end foreach
      let m_resumoData = today
      let m_resumoHora = current

      display "Resumo final do processo - ",m_resumoData,"  ",m_resumoHora
      display "Lidos: ",m_resumoCont clipped
      display "========================================="

      ##########################
      # Pesquisa serviços pagos
      ##########################
      initialize ws.maxsrvnum to null
      select max(atdsrvnum) into ws.maxsrvnum
        from work:srvpagos
       where periodo = m_periodo
         and empcod  = param.empcod

      if ws.maxsrvnum is null then
         let ws.maxsrvnum = 1000000 - 1  # Todos os servicos
      else
         display "      Servicos pagos maiores que ", ws.maxsrvnum using "&&&&&&&"
      end if

      let m_resumoCont = 0
      display "===========[RESUMO srvpagos]================="
      open cbdbsr12404 using  param.empcod,
                              m_datprcini,
                              m_datprcfim,
                              ws.maxsrvnum
      foreach cbdbsr12404 into ws.atdsrvnum,
                               ws.atdsrvano,
                               ws.pstcoddig,
                               ws.lcvcod,
                               ws.atdsrvorg,
                               ws.vlrsaida,
                               ws.c24pagdiaqtd,
                               ws.vlradicional,
                               ws.socfatpgtdat #--> FX-190515

         let m_resumoCont = m_resumoCont + 1
         ##########[LOG RESUMO A CADA 10000 REGISTROS]#######################
         if m_resumoCont = 10000 then
            let m_resumoData = today
            let m_resumoHora = current

            display "Resumo do processo - ",m_resumoData,"  ",m_resumoHora
            display "Lidos: ",m_resumoCont clipped
            display "-------------------------------------------"
         end if
         ###################################################################

         if ws.atdsrvorg = 8 then # Carro-Extra
            let ws.pstcoddig = ws.lcvcod + 900000   # Soma no codigo da loja para nao misturar codigo do prestador
         end if

         # Obtem uf e cidade do servico
         if ws.atdsrvorg = 8 then  # Carro-Extra
            open cbdbsr12415 using ws.atdsrvnum,
                                   ws.atdsrvano
            fetch cbdbsr12415 into ws.ufdcod,
                                   ws.cidnom
            close cbdbsr12415
         else
            open cbdbsr12402 using ws.atdsrvnum,
                                   ws.atdsrvano
            fetch cbdbsr12402 into ws.ufdcod,
                                   ws.cidnom
            close cbdbsr12402
         end if

         # Obtem corsus do servico
         call bdbsr124_obtemcorretor(ws.atdsrvnum,
                                     ws.atdsrvano)
         returning ws.corsus,
                   ws.doctxt

         # Obtem o corretor do servico caso nao seja localizado pelo documento
         if ws.corsus is null or ws.corsus = ' ' then
            open cbdbsr12419 using ws.atdsrvnum, ws.atdsrvano
            fetch cbdbsr12419 into ws.corsus
            close cbdbsr12419
         end if

         call bdbsr124_hie_corretor (ws.corsus)
              returning hie_susep.*

         let ws.coragpcod = hie_susep.coragpcod
         let ws.coragpnom = hie_susep.coragpnom
         let ws.corsus    = hie_susep.corsus
         let ws.corsuspcp = hie_susep.corsuspcp
         let ws.corgrpcod = hie_susep.corgrpcod
         let ws.succod    = hie_susep.succod
         let ws.regcod    = hie_susep.iptcod
         let ws.regnom    = hie_susep.iptnom

         if ws.vlrsaida is null then
            let ws.vlrsaida = 0
         end if

         if ws.vlradicional is null then
            let ws.vlradicional = 0
         end if

         let ws.valor = ws.vlrsaida + ws.vlradicional

         # Insere regitro na tabela temporaria
         insert into work:srvpagos values ( m_periodo,
                                            ws.atdsrvnum,
                                            ws.atdsrvano,
                                            ws.c24pagdiaqtd,
                                            ws.coragpcod,
                                            ws.coragpnom,
                                            ws.corsus,
                                            ws.corsuspcp,
                                            ws.corgrpcod,
                                            ws.succod,
                                            ws.regcod,
                                            ws.regnom,
                                            ws.ufdcod,
                                            ws.cidnom,
                                            ws.pstcoddig,
                                            ws.atdsrvorg,
                                            ws.qtdreclam,
                                            ws.doctxt,
                                            ws.valor,
                                            param.empcod,
                                            ws.socfatpgtdat #--> FX-190515
                                           )

         initialize ws.* to null

      end foreach
      let m_resumoData = today
      let m_resumoHora = current
      display "Resumo final do processo - ",m_resumoData,"  ",m_resumoHora
      display "Lidos: ",m_resumoCont clipped
      display "============================================"

   end for

#############################################################################
# Define a SUCURSAL para geracao
#############################################################################
call bdbsr124_prepare_sucursal()

initialize m_email_aux to null
initialize m_email_dest to null

#--> FX-190515 (inicio)

let m_mes = m_periodo[1,2]
let m_ano = m_periodo[4,7]
let m_ano = m_ano + 1

case param.empcod
     when 1 let m_empresa = 'PortoSeguro'
     when 35 let m_empresa = 'Azul'
     when 84 let m_empresa = 'Itau'
end  case

let m_arquivo_pgt = m_path clipped
                   ,"/", m_empresa clipped, '_'
                   ,"Pgto_Todas_Sucursais_"
                  #,m_mes
                  #,'_'
                  #,m_ano 
                  #,"_"
                   ,l_dataarq
                   
 let m_arquivo_pgt_txt =  m_arquivo_pgt clipped, ".txt"

 let m_arquivo_pgt = m_arquivo_pgt clipped,".xls"
 
 display 'Arquivo Pgt (Todas as Sucursais) : ', m_arquivo_pgt clipped

let m_arquivo_atd = m_path clipped
                   ,"/", m_empresa clipped, '_'
                   ,"Atd_Todas_Sucursais_"
                  #,m_mes
                  #,'_'
                  #,m_ano 
                  #,"_"
                   ,l_dataarq
                   
let m_arquivo_atd_txt =  m_arquivo_atd clipped, ".txt"
                   
 let m_arquivo_atd =  m_arquivo_atd clipped,".xls"
display 'Arquivo Atd (Todas as Sucursais) : ', m_arquivo_atd clipped

#--> FX-190515 (fim)

let m_email_aux = "BDBSR124"

open cbdbsr12418 using m_email_aux
foreach cbdbsr12418 into m_email_aux
    let m_email_dest = m_email_aux clipped,",",m_email_dest clipped
end foreach

foreach c_sucursal into l_succod

   initialize lr_verifica.flg to null

   whenever error continue
   select enviado
     into lr_verifica.flg
     from work:arqenviados
    where periodo = m_periodo
      and succod = l_succod
      and empcod = param.empcod

   if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
      display "erro ", sqlca.sqlcode, " ao pesquisar dados na tabela work:arqenviados"
   end if

   if lr_verifica.flg = 1 then
      continue foreach
   else
      let lr_verifica.flg = 0
   end if

   whenever error stop
   display 'm_periodo:', m_periodo


   whenever error continue
      open cbdbsr12405 using l_succod
      fetch cbdbsr12405 into m_sucnom
      close cbdbsr12405
   whenever error stop

   call bdbsr124_tira_espaco(m_sucnom) returning m_sucnom

   #let m_arquivo = m_path clipped, "/PortoSocorro_", param.empcod using "<<<&", "_Sucursal_", l_succod using "&&", ".htm"
   let m_arquivo = m_path clipped
                  ,"/"
                  ,m_empresa clipped, '_'
                  ,l_succod using "&&", '_'
                  ,m_sucnom clipped, '_'
                  ,m_mes
                  ,'_'
                  ,m_ano
                  ,".htm"

   display 'Arquivo htm: ', m_arquivo clipped
   let mr_anexo.arquivoHtm = m_arquivo

   start report bdbsr124_rpt to m_arquivo
   output to report bdbsr124_rpt(param.empcod, l_succod)
   finish report bdbsr124_rpt


   let m_arquivo = m_path clipped
                  ,"/", m_empresa clipped, '_'
                  ,"Pgto_"
                  ,l_succod using "&&", '_'
                  ,m_sucnom clipped, '_'
                  ,m_mes
                  ,'_'
                  ,m_ano
                  ,".xls"
                  
   let m_arquivo_txt = m_path clipped
                  ,"/", m_empresa clipped, '_'
                  ,"Pgto_"
                  ,l_succod using "&&", '_'
                  ,m_sucnom clipped, '_'
                  ,m_mes
                  ,'_'
                  ,m_ano
                  ,".txt"
   display 'Arquivo Pgto: ', m_arquivo clipped
   let mr_anexo.arquivoPgt = m_arquivo clipped, '.gz'

   unload to m_arquivo delimiter "	"
   select atdsrvorg,              ## SERVICO ORIGEM
          atdsrvnum,              ## SERVICO NUMERO
          atdsrvano,              ## SERVICO ANO
          doctxt,                 ## DOCUMENTO
          corsus,                 ## SUSEP
          corsuspcp,              ## SUSEP PRINCIPAL
          corgrpcod,              ## GRUPO SUSEP
          succod,                 ## SUCURSAL
          regcod,                 ## REGIONAL
          regnom,                 ## REGIONAL NOME
          ufdcod,                 ## UF OCORRENCIA
          cidnom,                 ## CIDADE OCORRENCIA
          pstcoddig,              ## PRESTADOR
          qtdreclam,              ## QUANT. RECLAMACOES
          valor,                  ## VALOR PAGO
          coragpcod,              ## AGRUP CORRETOR
          coragpnom,              ## AGRUP CORRETOR DESC
          socfatpgtdat            ## DATA PAGAMENTO #--> FX-190515
     from work:srvpagos
    where periodo = m_peratual
      and succod  = l_succod
      and empcod  = param.empcod
      
   unload to m_arquivo_txt delimiter m_tab
   select atdsrvorg,              ## SERVICO ORIGEM
          atdsrvnum,              ## SERVICO NUMERO
          atdsrvano,              ## SERVICO ANO
          doctxt,                 ## DOCUMENTO
          corsus,                 ## SUSEP
          corsuspcp,              ## SUSEP PRINCIPAL
          corgrpcod,              ## GRUPO SUSEP
          succod,                 ## SUCURSAL
          regcod,                 ## REGIONAL
          regnom,                 ## REGIONAL NOME
          ufdcod,                 ## UF OCORRENCIA
          cidnom,                 ## CIDADE OCORRENCIA
          pstcoddig,              ## PRESTADOR
          qtdreclam,              ## QUANT. RECLAMACOES
          valor,                  ## VALOR PAGO
          coragpcod,              ## AGRUP CORRETOR
          coragpnom,              ## AGRUP CORRETOR DESC
          socfatpgtdat            ## DATA PAGAMENTO #--> FX-190515
     from work:srvpagos
    where periodo = m_peratual
      and succod  = l_succod
      and empcod  = param.empcod
  
  #--> FX-190515 (inicio)
  let m_cmd = "cat ", m_arquivo clipped, ">> ", m_arquivo_pgt clipped
  let m_cmd = "cat ", m_arquivo clipped, ">> ", m_arquivo_pgt_txt clipped
  display "m_cmd=",m_cmd clipped 
  run m_cmd 
  #--> FX-190515 (fim)
  
  call bdbsr124_compact(m_arquivo)
      returning  m_arquivo

  let mr_anexo.arquivoAtd = m_arquivo

  let m_arquivo = m_path clipped
                  ,"/", m_empresa clipped, '_'
                  ,"Atd_"
                  ,l_succod using "&&", '_'
                  ,m_sucnom clipped, '_'
                  ,m_mes
                  ,'_'
                  ,m_ano
                  ,".xls"
                  
  let m_arquivo_txt = m_path clipped
                  ,"/", m_empresa clipped, '_'
                  ,"Atd_"
                  ,l_succod using "&&", '_'
                  ,m_sucnom clipped, '_'
                  ,m_mes
                  ,'_'
                  ,m_ano
                  ,".txt"
   display 'Arquivo Atd: ', m_arquivo clipped
   
   unload to m_arquivo delimiter "	"
   select atdsrvorg,              ## SERVICO ORIGEM
          atdsrvnum,              ## SERVICO NUMERO
          atdsrvano,              ## SERVICO ANO
          doctxt,                 ## DOCUMENTO
          corsus,                 ## SUSEP
          corsuspcp,              ## SUSEP PRINCIPAL
          corgrpcod,              ## GRUPO SUSEP
          succod,                 ## SUCURSAL
          regcod,                 ## REGIONAL
          regnom,                 ## REGIONAL NOME
          ufdcod,                 ## UF OCORRENCIA
          cidnom,                 ## CIDADE OCORRENCIA
          pstcoddig,              ## PRESTADOR
          qtdreclam,              ## QUANT. RECLAMACOES
          coragpcod,              ## AGRUP CORRETOR
          coragpnom,              ## AGRUP CORRETOR DESC
          atddat                  ## DATA ATENDIMENTO #--> FX-190515
     from work:srvatd
    where periodo = m_peratual
      and succod  = l_succod
      and empcod  = param.empcod
      
   unload to m_arquivo_txt delimiter m_tab
   select atdsrvorg,              ## SERVICO ORIGEM
          atdsrvnum,              ## SERVICO NUMERO
          atdsrvano,              ## SERVICO ANO
          doctxt,                 ## DOCUMENTO
          corsus,                 ## SUSEP
          corsuspcp,              ## SUSEP PRINCIPAL
          corgrpcod,              ## GRUPO SUSEP
          succod,                 ## SUCURSAL
          regcod,                 ## REGIONAL
          regnom,                 ## REGIONAL NOME
          ufdcod,                 ## UF OCORRENCIA
          cidnom,                 ## CIDADE OCORRENCIA
          pstcoddig,              ## PRESTADOR
          qtdreclam,              ## QUANT. RECLAMACOES
          coragpcod,              ## AGRUP CORRETOR
          coragpnom,              ## AGRUP CORRETOR DESC
          atddat                  ## DATA ATENDIMENTO #--> FX-190515
     from work:srvatd
    where periodo = m_peratual
      and succod  = l_succod
      and empcod  = param.empcod

  #--> FX-190515 (inicio)
  let m_cmd = "cat ", m_arquivo clipped, ">> ", m_arquivo_atd clipped
  let m_cmd = "cat ", m_arquivo clipped, ">> ", m_arquivo_atd_txt clipped
  display "m_cmd=", m_cmd clipped
  run m_cmd 
  #--> FX-190515 (fim)

  call bdbsr124_compact(m_arquivo)
      returning  m_arquivo
  let mr_anexo.arquivoAtd = m_arquivo

  initialize lr_verifica.* to null

  if lr_verifica.flg = 0 or
     lr_verifica.flg is null then

     #let m_cmd = m_cmd clipped, ",", m_arquivo clipped,"'"

     #display m_cmd clipped

     #run m_cmd
     let lr_mail.ass = 'Relatorio Sucursais - ', m_empresa clipped
                 ,' - Sucursal ', l_succod using "<<<&"
                 ," - ", m_sucnom clipped
                 ," - ", m_mes, "/", m_ano clipped


     let lr_mail.rem = "porto.socorro@portoseguro.com.br"
     let lr_mail.des = m_email_dest clipped
     let lr_mail.tip = "text"
     let lr_mail.cco = null
     let lr_mail.msg = 'RELATORIO DE SUCURSAIS '
     let lr_mail.idr = "P0603000"

     call bdbsr124_sendMail(lr_mail.*) returning l_retorno

     whenever error continue
        insert into work:arqenviados values (m_periodo, param.empcod, l_succod, 1)
        if sqlca.sqlcode <> 0 then
           display "erro ", sqlca.sqlcode, " ao gravar dados na tabela work:arqenviados"
        end if
     whenever error stop

     initialize lr_verifica.* to null
  else

     continue foreach

  end if

end foreach

#--> FX-190515 (inicio)
     
if lr_verifica.flg = 0 or
   lr_verifica.flg is null then

   call bdbsr124_compact(m_arquivo_atd)
        returning m_arquivo_atd

   call bdbsr124_compact(m_arquivo_pgt)
        returning m_arquivo_pgt

   let lr_mail.ass = 'Relatorio Sucursais - ', m_empresa clipped
                    ,' - TODAS SUCURSAIS'
                    ," - ", m_mes, "/", m_ano clipped

   let lr_mail.rem = "porto.socorro@portoseguro.com.br"
   let lr_mail.des = m_email_dest clipped
   let lr_mail.tip = "text"
   let lr_mail.cco = null
   let lr_mail.msg = 'RELATORIO DE SUCURSAIS (GERAL)'
   let lr_mail.idr = "P0603000"
   
   call bdbsr124_sendMail(lr_mail.*) returning l_retorno

end if

#--> FX-190515 (fim)

end function

#---------------------------------------#
 FUNCTION bdbsr124_busca_empnom(l_empcod)
#---------------------------------------#
  define l_empcod   decimal(2,0),
         l_empnom   char(40)

   initialize l_empnom to null
   whenever error continue
   select empnom
     into l_empnom
     from gabkemp
    where empcod = l_empcod
   whenever error stop
   if status <> 0 then
      display "Erro ", sqlca.sqlcode, " ao buscar descricao da empresa"
      return
   end if

   RETURN l_empnom

 END FUNCTION

#-------------------------------------#
 function bdbsr124_create_tables_work()
#-------------------------------------#
   database work

   ### Apagar as tabelas faz com que o re-start do programa nao funcione
   ### Verifica se foi passado algum parametro, se foi passado "drop" ele deleta as tabelas

   whenever error continue

   if m_DelTabela = 'drop' then
     drop table srvatd
     drop table srvpagos
     drop table arqenviados
   end if

   create table
              srvatd (periodo     char(7),
                      atdsrvnum   decimal(7,0),
                      atdsrvano   decimal(2,0),
                      coragpcod   char(6),
                      coragpnom   char(40),
                      corsus      char(6),
                      corsuspcp   char(6),
                      corgrpcod   char(6),
                      succod      decimal(2,0),
                      regcod      decimal(3,0),
                      regnom      char(40),
                      ufdcod      char(2),
                      cidnom      char(45),
                      pstcoddig   decimal(6,0),
                      atdsrvorg   smallint,
                      qtdreclam   integer,
                      doctxt      char(40),
                      empcod      smallint,
                      atddat      date #--> FX-190515
                     ) extent size 16000 next size 8000 lock mode page #with no log
   create index srvatd on srvatd (periodo,succod)

   create table
            srvpagos (periodo      char(7),
                      atdsrvnum    decimal(7,0),
                      atdsrvano    decimal(2,0),
                      c24pagdiaqtd decimal(6,0), #adicionado campo quantidades de diarias pagas
                      coragpcod    char(6),
                      coragpnom    char(40),
                      corsus       char(6),
                      corsuspcp    char(6),
                      corgrpcod    char(6),
                      succod       decimal(2,0),
                      regcod       decimal(3,0),
                      regnom       char(40),
                      ufdcod       char(2),
                      cidnom       char(45),
                      pstcoddig    decimal(6,0),
                      atdsrvorg    smallint,
                      qtdreclam    integer,
                      doctxt       char(40),
                      valor        decimal(12,2),
                      empcod       smallint,
                      socfatpgtdat date #--> FX-190515
                      )extent size 16000 next size 8000 lock mode page # with no log
   create index srvpagos on srvpagos (periodo,succod)

   create table
         arqenviados (periodo      char(7),
                      empcod       smallint,
                     #succod       decimal(2,0),
                      succod       smallint, #--> FX-190515
                      enviado      smallint
                      )extent size 16000 next size 8000 lock mode page # with no log
   create index srvpagos on srvpagos (periodo,succod)

   whenever error stop

   database porto

 end function

#------------------------------------------------
 function bdbsr124_tira_espaco(l_texto)
#------------------------------------------------

  define l_texto char(50)
  define l_i  smallint,
         l_tamanho smallint,
         l_caracter char(1)

  let l_tamanho = length (l_texto)
    for l_i = 1 to l_tamanho
      let l_caracter = l_texto[l_i]

         if l_caracter = " " then
            let l_texto[l_i] = "_"
         end if
    end for

   return l_texto clipped

 end function

#------------------------------------------------------
function bdbsr124_sendMail(lr_param)
#------------------------------------------------------
  define lr_param record
         rem     char(50)
        ,des     char(10000)
        ,ccp     char(10000)
        ,cco     char(10000)
        ,ass     char(500)
        ,msg     char(32000)
        ,idr     char(20)
        ,tip     char(4)
 end record

 define l_anexo         char(300)
       ,l_retorno       smallint
       ,l_ret_figrc009  integer
       ,l_mensagem_erro char(20)

 initialize l_mensagem_erro
           ,l_ret_figrc009
 to null

 let l_retorno = 0
 
 

 if lr_param.des is not null then
 
    if lr_param.msg = 'RELATORIO DE SUCURSAIS (GERAL)' then #--> FX-190515
       call figrc009_attach_file(m_arquivo_atd)             #--> FX-190515
       call figrc009_attach_file(m_arquivo_pgt)             #--> FX-190515
    else                                                    #--> FX-190515  
      if mr_anexo.arquivoHtm is not null and
         mr_anexo.arquivoAtd is not null and
         mr_anexo.arquivoPgt is not null then
         call figrc009_attach_file(mr_anexo.arquivoHtm)
         call figrc009_attach_file(mr_anexo.arquivoAtd)
         call figrc009_attach_file(mr_anexo.arquivoPgt) 
      end if
    end if   
     
    call figrc009_mail_send1(lr_param.*)
         returning l_ret_figrc009, l_mensagem_erro

    let l_retorno = l_ret_figrc009

 else

    let l_retorno = 99

 end if

 return l_retorno

 end function
