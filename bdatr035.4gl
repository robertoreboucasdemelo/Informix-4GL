############################################################################
# Nome do Modulo: BDATR035                                        Marcelo  #
#                                                                 Gilberto #
# Relatorio mensal de reclamacoes (analitico/totais)              Out/1997 #
############################################################################
#                    * * * * A L T E R A C O E S * * * *                   #
# DATA       AUTHOR               DESCRICAO RESUMIDA DA ALTERACAO          #
# 22/04/2003 FERNANDO ( FABRICA ) RESOLUCAO 86                             #
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance            #
#--------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto #
#                                      como sendo o agrupamento, buscar cod#
#                                      agrupamento.                        #
#--------------------------------------------------------------------------#

 database porto
 globals
   define g_ismqconn smallint
end globals

 define ws_data_de     date,
        ws_data_ate    date,
        ws_data_aux    char(10),
        ws_traco       char(500),
        ws_cctcod      like igbrrelcct.cctcod,
        ws_relviaqtd   like igbrrelcct.relviaqtd

 main
    call fun_dba_abre_banco('CT24HS')
    set isolation to dirty read
    set lock mode to wait 10
    call bdatr035()
 end main

#---------------------------------------------------------------
 function bdatr035()
#---------------------------------------------------------------

 define d_bdatr035    record
    ligdat            like datmligacao.ligdat,
    diasem            char(09),
    lighorinc         like datmligacao.lighorinc,
    lignum            like datmligacao.lignum,
    c24astcod         like datmligacao.c24astcod,
    c24astdes         char(50),
    succod            like datrligapol.succod,
    ramcod            like datrligapol.ramcod,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    segnom            char(40),
    c24rclsitcod      like datmsitrecl.c24rclsitcod,
    c24rclsitdes      char(20),
    dias              integer,
    tempo             interval hour(06) to minute
 end record

 define ws            record
    comando           char(400),
    diasem            integer,
    cponom            like iddkdominio.cponom,
    rclrlzdat         like datmsitrecl.rclrlzdat,
    rclrlzhor         like datmsitrecl.rclrlzhor,
    segnumdig         like gsakseg.segnumdig,
    sgrorg            like rsamseguro.sgrorg,
    sgrnumdig         like rsamseguro.sgrnumdig,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60)
 end record

 define ws_funapol    record
    resultado         char (01),
    dctnumseq         decimal(04,00),
    vclsitatu         decimal(04,00),
    autsitatu         decimal(04,00),
    dmtsitatu         decimal(04,00),
    dpssitatu         decimal(04,00),
    appsitatu         decimal(04,00),
    vidsitatu         decimal(04,00)
 end record

  define l_assunto     char(100),
         l_erro_envio  smallint

 #---------------------------------------------------------------
 # Inicializacao das variaveis / Preparacao dos comandos SQL
 #---------------------------------------------------------------

 initialize d_bdatr035.*  to null
 initialize ws.*          to null
 initialize ws_funapol.*  to null
 let ws.cponom = "c24rclsitcod"

 let ws_traco  = "------------------------------------------------------------------------------------------------------------------------------------------------"

 let ws.comando = "select c24astdes",
                  "  from datkassunto ",
                  " where c24astcod = ? "
 prepare sel_assun  from ws.comando
 declare c_assun  cursor for sel_assun

 let ws.comando = "select c24rclsitcod,",
                  "       rclrlzdat,",
                  "       rclrlzhor",
                  " from datmligacao, datmsitrecl ",
                  "where datmligacao.lignum       = ?",
                  "  and datmsitrecl.lignum       = datmligacao.lignum",
                  "  and datmsitrecl.c24rclsitcod =",
                  "      (select max(c24rclsitcod)",
                  "         from datmsitrecl",
                  "        where datmsitrecl.lignum = datmligacao.lignum)"
 prepare sel_rclsit from ws.comando
 declare c_rclsit cursor for sel_rclsit

 let ws.comando = "select cpodes",
                  "  from iddkdominio",
                  " where cponom = ? ",
                  "   and cpocod = ? "
 prepare sel_iddk   from ws.comando
 declare c_iddk   cursor for sel_iddk

 let ws.comando = "select segnumdig",
                  "  from abbmdoc",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? "
 prepare sel_abbmdoc  from ws.comando
 declare c_abbmdoc  cursor for sel_abbmdoc

 let ws.comando = "select segnom ",
                  "  from gsakseg",
                  " where segnumdig = ? "
 prepare sel_gsakseg  from ws.comando
 declare c_gsakseg  cursor for sel_gsakseg

 let ws.comando = "select  segnumdig",
                  "  from  rsdmdocto ",
                  " where sgrorg    = ?",
                  "   and sgrnumdig = ?",
                  "   and dctnumseq = ",
                  "       (select max(dctnumseq)",
                  "          from  rsdmdocto",
                  "         where sgrorg     = ?",
                  "           and sgrnumdig  = ?",
                  "           and prpstt     in (19,66,88))"
 prepare sel_rsdmdocto  from ws.comando
 declare c_rsdmdocto  cursor for sel_rsdmdocto

 let ws.comando = "select sgrorg, sgrnumdig ",
                  "  from rsamseguro ",
                  " where succod    = ? ",
                  "   and ramcod    = ? ",
                  "   and aplnumdig = ? "
 prepare sel_rsamseguro  from ws.comando
 declare c_rsamseguro  cursor for sel_rsamseguro


 #---------------------------------------------------------------
 # Define o periodo mensal
 #---------------------------------------------------------------
 let ws_data_aux = arg_val(1)

 if ws_data_aux is null       or
    ws_data_aux =  "  "       then
    let ws_data_aux = today
 else
    if ws_data_aux >= today      or
       length(ws_data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
 let ws_data_ate = ws_data_aux
 let ws_data_ate = ws_data_ate - 1 units day

 let ws_data_aux = ws_data_ate
 let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
 let ws_data_de  = ws_data_aux

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT03501.rtf"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDAT03501")
      returning  ws_cctcod,
		 ws_relviaqtd

#start report  rep_reclam  to  "bdatr035a.rel"
 start report  rep_totais  to  ws.pathrel01


 #---------------------------------------------------------------
 # Ler todas as ligacoes de reclamacao do mes
 #---------------------------------------------------------------
 declare  c_bdatr035  cursor for
    select datmligacao.ligdat,
           datmligacao.lighorinc,
           datmligacao.lignum,
           datmligacao.c24astcod,
           datrligapol.succod,
           datrligapol.ramcod,
           datrligapol.aplnumdig,
           datrligapol.itmnumdig
      from datmligacao, datkassunto, outer datrligapol        ## psi230650
     where datmligacao.ligdat between  ws_data_de and ws_data_ate
       and datkassunto.c24astagp = "W"                        ## psi230650
       and datrligapol.lignum    = datmligacao.lignum
       and datmligacao.c24astcod = datkassunto.c24astcod

 foreach c_bdatr035  into d_bdatr035.ligdat,
                          d_bdatr035.lighorinc,
                          d_bdatr035.lignum,
                          d_bdatr035.c24astcod,
                          d_bdatr035.succod,
                          d_bdatr035.ramcod,
                          d_bdatr035.aplnumdig,
                          d_bdatr035.itmnumdig

   #let ws.diasem = weekday(d_bdatr035.ligdat)

   #case ws.diasem
   #   when  0   let d_bdatr035.diasem = "DOMINGO"
   #   when  1   let d_bdatr035.diasem = "SEGUNDA"
   #   when  2   let d_bdatr035.diasem = "TERCA"
   #   when  3   let d_bdatr035.diasem = "QUARTA"
   #   when  4   let d_bdatr035.diasem = "QUINTA"
   #   when  5   let d_bdatr035.diasem = "SEXTA"
   #   when  6   let d_bdatr035.diasem = "SABADO"
   #   otherwise initialize d_bdatr035.diasem  to null
   #end case

    #---------------------------------------------------------------
    # Monta descricao do codigo do assunto da ligacao
    #---------------------------------------------------------------
    let d_bdatr035.c24astdes = "* ASSUNTO NAO CADASTRADO *"
    open  c_assun  using d_bdatr035.c24astcod
    fetch c_assun  into  d_bdatr035.c24astdes
    if sqlca.sqlcode < 0 then
       display "Erro (", sqlca.sqlcode, ") leitura da descricao do assunto"
       return
    end if
    close c_assun

    #---------------------------------------------------------------
    # Ler ultima situacao da reclamacao / Descricao da situacao
    #---------------------------------------------------------------
    initialize d_bdatr035.c24rclsitcod  to null
    open  c_rclsit  using d_bdatr035.lignum
    fetch c_rclsit  into  d_bdatr035.c24rclsitcod,
                          ws.rclrlzdat,
                          ws.rclrlzhor
    if sqlca.sqlcode < 0 then
       display "Erro (", sqlca.sqlcode, ") leitura da situacao da reclamacao"
       return
    end if
    close c_rclsit

    if d_bdatr035.c24rclsitcod  is null  then
       let d_bdatr035.c24rclsitcod = 0
       let ws.rclrlzdat            = today
       let ws.rclrlzhor            = current
    end if

    open  c_iddk  using ws.cponom,
                        d_bdatr035.c24rclsitcod
    fetch c_iddk  into  d_bdatr035.c24rclsitdes
    if sqlca.sqlcode < 0 then
       display "Erro (", sqlca.sqlcode, ") leitura da descricao da situacao "
       return
    end if
    close c_iddk

   #---------------------------------------------------------------
   # Busca ultima situacao da apolice / Nome do segurado
   #---------------------------------------------------------------
   #initialize ws.segnumdig   to null
   #let d_bdatr035.segnom = "* NOME DO SEGURADO NAO CADASTRADO *"
   #
   #if d_bdatr035.ramcod =  31  or
   #   d_bdatr035.ramcod = 531  then
   #   initialize ws_funapol.*   to null
   #   call f_funapol_ultima_situacao
   #        (d_bdatr035.succod, d_bdatr035.aplnumdig, d_bdatr035.itmnumdig)
   #         returning  ws_funapol.*
   #
   #   open  c_abbmdoc   using d_bdatr035.succod   , d_bdatr035.aplnumdig,
   #                           d_bdatr035.itmnumdig, ws_funapol.dctnumseq
   #   fetch c_abbmdoc   into  ws.segnumdig
   #   close c_abbmdoc
   #else
   #
   #   open  c_rsamseguro   using d_bdatr035.succod,
   #                              d_bdatr035.ramcod,
   #                              d_bdatr035.aplnumdig
   #   fetch c_rsamseguro   into  ws.sgrorg,
   #                              ws.sgrnumdig
   #   close c_rsamseguro
   #
   #   if sqlca.sqlcode = 0   then
   #      open  c_rsdmdocto   using ws.sgrorg,
   #                                ws.sgrnumdig,
   #                                ws.sgrorg,
   #                                ws.sgrnumdig
   #      fetch c_rsdmdocto   into  ws.segnumdig
   #      close c_rsdmdocto
   #   end if
   #
   #end if
   #
   #if ws.segnumdig  is not null   then
   #   open  c_gsakseg using ws.segnumdig
   #   fetch c_gsakseg into  d_bdatr035.segnom
   #   close c_gsakseg
   #end if

   #---------------------------------------------------------------
   # Calcula tempo de espera para conclusao da reclamacao
   #---------------------------------------------------------------
   #call bdatr035_espera(d_bdatr035.ligdat,
   #                     d_bdatr035.lighorinc,
   #                     ws.rclrlzdat,
   #                     ws.rclrlzhor)
   #     returning d_bdatr035.dias,
   #               d_bdatr035.tempo
   #
   #output to report rep_reclam(d_bdatr035.*)
    output to report rep_totais(d_bdatr035.*)

 end foreach

#finish report  rep_reclam
 finish report  rep_totais

 let l_assunto    = null
 let l_erro_envio = null

 let l_assunto    = "Relatorio de Reclamacoes"
 let l_erro_envio = ctx22g00_envia_email("BDATR035",
                                         l_assunto,
                                         ws.pathrel01)
 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01
    else
       display "Nao existe email cadastrado para o modulo - BDATR035"
    end if
 end if

#let ws_traco = "mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
#               " -s 'Relatorio_de_Reclamacoes '",
#               " 'ct24hs_relatorios/spaulo_ct24hs_teleatendimento@u55'",
#               " < ",ws.pathrel01
#    run ws_traco
# psi13540

 close c_bdatr035

end function   ##---  bdatr035


#---------------------------------------------------------------------------
 report rep_reclam(r_bdatr035)
#---------------------------------------------------------------------------

 define r_bdatr035    record
    ligdat            like datmligacao.ligdat,
    diasem            char(09),
    lighorinc         like datmligacao.lighorinc,
    lignum            like datmligacao.lignum,
    c24astcod         like datmligacao.c24astcod,
    c24astdes         char(50),
    succod            like datrligapol.succod,
    ramcod            like datrligapol.ramcod,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    segnom            char(40),
    c24rclsitcod      like datmsitrecl.c24rclsitcod,
    c24rclsitdes      char(20),
    dias              integer,
    tempo             interval hour(06) to minute
 end record

 define ws            record
    totrcl            dec(6,0)
 end record


 output
      left   margin  000
      right  margin  144
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdatr035.ligdat,
             r_bdatr035.lighorinc

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=BDATR035 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - RELACAO MENSAL DE RECLAMACOES"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, DEPT='TELE-ATENDIMENTO', END;"
            print ascii(12)

            let ws.totrcl = 0
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 113, "BDATR035-A",
               column 126, "PAGINA : "  , pageno using "##,###,##&"
         print column 037, "RECLAMACOES REGISTRADAS NO PERIODO DE ",
                            ws_data_de, " A ", ws_data_ate,
               column 126, "DATA   : "  , today
         print column 126, "HORA   :   ", time
         skip 2 lines

         print column 001, "DIA",
               column 013, "LIGACAO",
               column 026, "DOCUMENTO",
               column 055, "SEGURADO",
               column 098, "SITUACAO",
               column 134, "TEMPO"

         print column 013, "HORA",
               column 026, "RECLAMACAO",
               column 130, "DIAS  /  HORAS"

         print column 001, ws_traco
         skip 1 line

      after group of r_bdatr035.ligdat
         skip 2 lines

      on every row
         need 3 lines
         print column 001, r_bdatr035.ligdat,
               column 013, r_bdatr035.lignum     using "<<<<<<<&&&",
               column 026, r_bdatr035.ramcod     using "&&&&",       "/",
                           r_bdatr035.succod     using "&&",         "/",
                           r_bdatr035.aplnumdig  using "<<<<<<<& &", "/",
                           r_bdatr035.itmnumdig  using "<<<<<& &",
               column 055, r_bdatr035.segnom,
               column 098, r_bdatr035.c24rclsitdes,
               column 130, r_bdatr035.dias       using "##&&",
                           r_bdatr035.tempo

         print column 001, r_bdatr035.diasem,
               column 013, r_bdatr035.lighorinc,
               column 026, r_bdatr035.c24astcod, " - ",
                           r_bdatr035.c24astdes

         let ws.totrcl = ws.totrcl + 1

         skip 1 line

      on last row
         need 3 lines
         skip 3 lines
         print column 001, ws_traco
         print column 001, "TOTAL GERAL: ",
               column 020, ws.totrcl     using "###&&&"
         print column 001, ws_traco

         print "$FIMREL$"

end report   ##--- rep_reclam


#---------------------------------------------------------------------------
 report rep_totais(r_bdatr035)
#---------------------------------------------------------------------------

 define r_bdatr035    record
    ligdat            like datmligacao.ligdat,
    diasem            char(09),
    lighorinc         like datmligacao.lighorinc,
    lignum            like datmligacao.lignum,
    c24astcod         like datmligacao.c24astcod,
    c24astdes         char(50),
    succod            like datrligapol.succod,
    ramcod            like datrligapol.ramcod,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    segnom            char(40),
    c24rclsitcod      like datmsitrecl.c24rclsitcod,
    c24rclsitdes      char(20),
    dias              integer,
    tempo             interval hour(06) to minute
 end record

 define ws            record
    totrclsit         dec(6,0),
    totrclast         dec(6,0),
    totrclgrl         dec(6,0)
 end record


 output
      left   margin  000
      right  margin  144
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdatr035.c24astcod,
             r_bdatr035.c24rclsitcod

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DAT03501 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - TOTAL MENSAL DE RECLAMACOES"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)

            let ws.totrclsit = 0
            let ws.totrclast = 0
            let ws.totrclgrl = 0
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 112, "RDAT035-01",
               column 126, "PAGINA : "  , pageno using "##,###,##&"
         print column 031, "TOTAL DE RECLAMACOES REGISTRADAS NO PERIODO DE ",
                            ws_data_de, " A ", ws_data_ate,
               column 126, "DATA   : "  , today
         print column 126, "HORA   :   ", time
         skip 2 lines

         print column 011, "RECLAMACAO",
               column 082, "SITUACAO",
               column 104, "QUANTIDADE"

         print column 001, ws_traco
         skip 1 lines

      before group of r_bdatr035.c24rclsitcod
         let ws.totrclsit = 0

      after  group of r_bdatr035.c24rclsitcod
         print column 011, r_bdatr035.c24astcod, " - ",
                           r_bdatr035.c24astdes,
               column 082, r_bdatr035.c24rclsitdes,
               column 108, ws.totrclsit   using "####&&"

      before group of r_bdatr035.c24astcod
         let ws.totrclsit = 0
         let ws.totrclast = 0

      after group of r_bdatr035.c24astcod
         print column 108, "------"
         print column 108, ws.totrclast   using "####&&"

         skip 2 lines

      on every row
         let ws.totrclsit = ws.totrclsit + 1
         let ws.totrclast = ws.totrclast + 1
         let ws.totrclgrl = ws.totrclgrl + 1

      on last row
         need 3 lines
         skip 1 line
         print column 001, ws_traco
         print column 001, "TOTAL GERAL: ",
               column 020, ws.totrclgrl  using "###&&&"
         print column 001, ws_traco

         print "$FIMREL$"

end report   ##--- rep_totais


#-----------------------------------------------------------
 function bdatr035_espera(param3)
#-----------------------------------------------------------

 define param3        record
    rclrlzdat        like datmsitrecl.rclrlzdat,
    rclrlzhor        char (05),
    rclfnldat        like datmsitrecl.rclrlzdat,
    rclfnlhor        char (08)
 end record

 define ws3          record
    incdat           date,
    fnldat           date,
    resdat           integer,
    time             char (05),
    chrhor           char (07),
    inchor           interval hour(05) to minute,
    fnlhor           interval hour(05) to minute,
    reshor           interval hour(06) to minute,
    dias             integer
 end record

 let ws3.incdat = param3.rclrlzdat
 if param3.rclfnldat is null  or
    param3.rclfnldat < param3.rclrlzdat  then
    let ws3.fnldat = today
 else
    let ws3.fnldat = param3.rclfnldat
 end if

 let ws3.inchor = param3.rclrlzhor
 if param3.rclfnlhor is null  then
    let ws3.time = time
 else
    let ws3.time = param3.rclfnlhor[1,5]
 end if

 let ws3.fnlhor = ws3.time

 let ws3.resdat = (ws3.fnldat - ws3.incdat) * 24
 let ws3.reshor = (ws3.fnlhor - ws3.inchor)

 let ws3.chrhor = ws3.resdat using "###&" , ":00"
 let ws3.reshor = ws3.reshor + ws3.chrhor

 for ws3.dias = 0 to 90
     if ws3.reshor < "24:00"  then
        exit for
     end if
     let ws3.reshor = ws3.reshor - "24:00"
 end for

 return ws3.dias, ws3.reshor

end function  ###  bdatr035_espera
