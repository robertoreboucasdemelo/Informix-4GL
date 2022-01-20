#############################################################################
# Nome do Modulo: BDATR023                                         Marcelo  #
#                                                                  Gilberto #
# Relacao de observacoes para renovacao                            Mar/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 17/02/2000  PSI 10079-0  Gilberto     Substituir tipo de solicitante pelo #
#                                       novo campo criado (c24soltipcod).   #
#---------------------------------------------------------------------------#
# 16/05/2002  PSI 15421-0  Ruiz         Enviar relatorio via e-mail.        #
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance            #
#--------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws_data       char (10)
 define ws_traco      char (140)
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd
 define sql_comando   char (400)
 define ws_email      char (500)

 main
    call fun_dba_abre_banco('CT24HS')
    set isolation to dirty read
    set lock mode to wait 10
    call bdatr023()
 end main

#---------------------------------------------------------------
 function bdatr023()
#---------------------------------------------------------------

 define d_bdatr023    record
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    succod            like datrligapol.succod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig
 end record

 define ws            record
    auxdat            date                      ,
    incdat            date                      ,
    fnldat            date                      ,
    segnumdig         like gsakseg.segnumdig    ,
    c24funmat         like datmligacao.c24funmat,
    c24soltipcod      like datmligacao.c24soltipcod,
    dirfisnom         like ibpkdirlog.dirfisnom ,
    pathrel01         char (60)
 end record

 define l_assunto     char(100),
        l_erro_envio  smallint

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 let ws_traco  = "-------------------------------------------------------------------------------------------------------------------------------------------"
 initialize d_bdatr023.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------

 let sql_comando = "select funnom from isskfunc",
                   " where funmat = ?"
 prepare sel_isskfunc from sql_comando
 declare c_isskfunc cursor for sel_isskfunc

 let sql_comando = "select c24soltipdes",
                   "  from datksoltip  ",
                   " where c24soltipcod = ?"
 prepare sel_datksoltip from sql_comando
 declare c_datksoltip cursor for sel_datksoltip

 let sql_comando = "select segnumdig from abbmdoc",
                   " where succod    = ?      and",
                   "       aplnumdig = ?      and",
                   "       itmnumdig = ?      and",
                   "       dctnumseq = ?         "
 prepare sel_abbmdoc   from sql_comando
 declare c_abbmdoc   cursor for sel_abbmdoc

 let sql_comando = "select segnom from gsakseg",
                   " where segnumdig = ? "
 prepare sel_gsakseg   from sql_comando
 declare c_gsakseg   cursor for sel_gsakseg

 let sql_comando = "select ligdat   , lighorinc,",
                   "       c24funmat, c24ligdsc ",
                   "  from datmlighist          ",
                   " where lignum = ?           "
 prepare sel_datmlighist from sql_comando
 declare c_datmlighist cursor for sel_datmlighist

#---------------------------------------------------------------
# Define data parametro
#---------------------------------------------------------------

 let ws_data = arg_val(1)

 if ws_data is null       or
    ws_data =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws_data = today
    else
       let ws_data = today - 1
    end if
 else
    if ws_data > today       or
       length(ws_data) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws.auxdat = ws_data

 let ws.incdat = ws.auxdat - 8 units day
 let ws.fnldat = ws.auxdat - 1 units day

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

#Ruiz let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT02301"
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT02399.rtf"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDAT02301")
      returning  ws_cctcod,
                 ws_relviaqtd

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_bdatr023 cursor for
    select datmligacao.c24astcod,
           datmligacao.lignum   ,
           datmligacao.c24solnom,
           datmligacao.c24soltipcod,
           datmligacao.c24funmat,
           datmligacao.ligdat   ,
           datmligacao.lighorinc,
           datrligapol.succod   ,
           datrligapol.aplnumdig,
           datrligapol.itmnumdig
      from datmligacao, datrligapol
     where datmligacao.ligdat between ws.incdat    and
                                      ws.fnldat    and
           datmligacao.c24astcod = "M10"           and
           datrligapol.lignum    =  datmligacao.lignum

 start report  rep_espec  to  ws.pathrel01

 foreach c_bdatr023  into  d_bdatr023.c24astcod, d_bdatr023.lignum   ,
                           d_bdatr023.c24solnom, ws.c24soltipcod     ,
                           ws.c24funmat        , d_bdatr023.ligdat   ,
                           d_bdatr023.lighorinc, d_bdatr023.succod   ,
                           d_bdatr023.aplnumdig, d_bdatr023.itmnumdig

#---------------------------------------------------------------
# Nome do Funcionario
#---------------------------------------------------------------

    let d_bdatr023.funnom = "NAO CADASTRADO!"

    open  c_isskfunc using ws.c24funmat
    fetch c_isskfunc into  d_bdatr023.funnom
    close c_isskfunc

    let d_bdatr023.c24soltipdes = "** NAO CADASTRADO **"

    open  c_datksoltip using ws.c24soltipcod
    fetch c_datksoltip into  d_bdatr023.c24soltipdes
    close c_datksoltip

#---------------------------------------------------------------
# Ultima situacao da apolice
#---------------------------------------------------------------

    call f_funapol_ultima_situacao
         (d_bdatr023.succod, d_bdatr023.aplnumdig, d_bdatr023.itmnumdig)
         returning  g_funapol.*

#---------------------------------------------------------------
# Dados do Segurado
#---------------------------------------------------------------

    open  c_abbmdoc  using d_bdatr023.succod   ,
                           d_bdatr023.aplnumdig,
                           d_bdatr023.itmnumdig,
                           g_funapol.dctnumseq
    fetch c_abbmdoc  into  ws.segnumdig
    close c_abbmdoc

    if sqlca.sqlcode <> notfound  then
       initialize d_bdatr023.segnom to null

       open  c_gsakseg  using  ws.segnumdig
       fetch c_gsakseg  into   d_bdatr023.segnom
       close c_gsakseg
    end if

    output to report rep_espec(ws.incdat, ws.fnldat, d_bdatr023.*)

 end foreach

 finish report  rep_espec

 let l_assunto    = null
 let l_erro_envio = null

 let l_assunto    = "Observacoes para Renovacao M10"
 let l_erro_envio = ctx22g00_envia_email("BDATR023",
                                         l_assunto,
                                         ws.pathrel01)
 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01
    else
       display "Nao existe email cadastrado para o modulo - BDATR023"
    end if
 end if

end function  ###  bdatr023

{
#---------------------------------------------------------------------------
 report rep_espec(r_bdatr023)
#---------------------------------------------------------------------------

 define r_bdatr023    record
    incdat            date                      ,
    fnldat            date                      ,
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    succod            like datrligapol.succod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig
 end record

 define h_bdatr023    record
    c24txtseq         like datmlighist.c24txtseq,
    c24ligdsc         like datmlighist.c24ligdsc,
    c24funmat         like datmlighist.c24funmat,
    ligdat            like datmlighist.ligdat   ,
    lighorinc         like datmlighist.lighorinc
 end record

 define ws            record
    funnom            like isskfunc.funnom      ,
    lintxt            like datmlighist.c24ligdsc,
    ligdat            like datmlighist.ligdat   ,
    lighor            like datmlighist.lighorinc
 end record

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066


   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DAT02301 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "    JOBNAME= CT24HS - OBSERVACOES PARA RENOVACAO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if
         print column 107, "RDAT023-01",
               column 121, "PAGINA : ", pageno using "##,###,##&"
         print column 121, "DATA   : ", today
         print column 024, "OBSERVACOES PARA RENOVACAO NO PERIODO DE ", r_bdatr023.incdat, " A ", r_bdatr023.fnldat,
               column 121, "HORA   :   ", time
         skip 2 lines

         print column 001, "ASS."       ,
               column 006, "SEGURADO"   ,
               column 047, "DATA"       ,
               column 055, "HORA"       ,
               column 064, "ATENDENTE"  ,
               column 086, "SOLICITANTE",
               column 102, "TIPO"       ,
               column 113, "DOCUMENTO"

         print column 001, ws_traco
         skip 1 line

      on every row
         print column 001, r_bdatr023.c24astcod                   ,
               column 006, r_bdatr023.segnom                      ,
               column 044, r_bdatr023.ligdat                      ,
               column 055, r_bdatr023.lighorinc                   ,
               column 064, r_bdatr023.funnom                      ,
               column 086, r_bdatr023.c24solnom                   ,
               column 102, r_bdatr023.c24soltipdes[1,10]          ,
               column 113, r_bdatr023.succod    using "&&"        ,
               column 116, r_bdatr023.aplnumdig using "#######& &",
               column 117, r_bdatr023.itmnumdig using "<<<<<& &"

         open    c_datmlighist using r_bdatr023.lignum
         foreach c_datmlighist into  h_bdatr023.ligdat   , h_bdatr023.lighorinc,
                                     h_bdatr023.c24funmat, h_bdatr023.c24ligdsc

           if ws.ligdat <> h_bdatr023.ligdat     or
              ws.lighor <> h_bdatr023.lighorinc  then
              open  c_isskfunc  using h_bdatr023.c24funmat
              fetch c_isskfunc  into  ws.funnom
              close c_isskfunc

              let ws.lintxt = "EM: "   , h_bdatr023.ligdat    clipped,
                              "  AS: " , h_bdatr023.lighorinc clipped,
                              "  POR: ", ws.funnom            clipped
              let ws.ligdat = h_bdatr023.ligdat
              let ws.lighor = h_bdatr023.lighorinc
              skip 1 line

              print column 044, ws.lintxt
           end if

           print column 044, h_bdatr023.c24ligdsc

      end foreach
      skip 2 lines

      on last row
           print "$FIMREL$"

 end report  ###  rep_espec
}
#---------------------------------------------------------------------------
 report rep_espec(r_bdatr023)
#---------------------------------------------------------------------------

 define r_bdatr023    record
    incdat            date                      ,
    fnldat            date                      ,
    c24astcod         like datmligacao.c24astcod,
    lignum            like datmligacao.lignum   ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            char (35)                 ,
    funnom            like isskfunc.funnom      ,
    ligdat            like datmligacao.ligdat   ,
    lighorinc         like datmligacao.lighorinc,
    succod            like datrligapol.succod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig
 end record

 define h_bdatr023    record
    c24txtseq         like datmlighist.c24txtseq,
    c24ligdsc         like datmlighist.c24ligdsc,
    c24funmat         like datmlighist.c24funmat,
    ligdat            like datmlighist.ligdat   ,
    lighorinc         like datmlighist.lighorinc
 end record

 define ws            record
    funnom            like isskfunc.funnom      ,
    lintxt            like datmlighist.c24ligdsc,
    ligdat            like datmlighist.ligdat   ,
    lighor            like datmlighist.lighorinc,
    doctxt            char(25)
 end record

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DAT02301 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "    JOBNAME= CT24HS - OBSERVACOES PARA RENOVACAO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if
         print column 062, "RDAT023-01"
         print column 062, "PAGINA : ", pageno using "##,###,##&"
         print column 062, "DATA   : ", today
         print column 062, "HORA   :   ", time
         print column 005, "OBSERVACOES PARA RENOVACAO NO PERIODO ", r_bdatr023.incdat, " A ", r_bdatr023.fnldat

         skip 2 lines
         print column 001, ws_traco[1,80]
         skip 1 line

      on every row
         let ws.doctxt = r_bdatr023.succod     using "&&", "/",
                         r_bdatr023.aplnumdig  using "<<<<<<<& &", "/",
                         r_bdatr023.itmnumdig  using "<<<<<<& &"

         print column 001, "ASSUNTO......: ", r_bdatr023.c24astcod
         print column 001, "SEGURADO.....: ", r_bdatr023.segnom
         print column 001, "DATA.........: ", r_bdatr023.ligdat
         print column 001, "HORA.........: ", r_bdatr023.lighorinc
         print column 001, "ATENDENTE....: ", r_bdatr023.funnom
         print column 001, "SOLICITANTE..: ", r_bdatr023.c24solnom
         print column 001, "TIPO.........: ", r_bdatr023.c24soltipdes[1,10]
         print column 001, "DOCUMENTO....: ", ws.doctxt

         open    c_datmlighist using r_bdatr023.lignum
         foreach c_datmlighist into  h_bdatr023.ligdat   , h_bdatr023.lighorinc,
                                     h_bdatr023.c24funmat, h_bdatr023.c24ligdsc

           if ws.ligdat <> h_bdatr023.ligdat     or
              ws.lighor <> h_bdatr023.lighorinc  then
              open  c_isskfunc  using h_bdatr023.c24funmat
              fetch c_isskfunc  into  ws.funnom
              close c_isskfunc

              let ws.lintxt = "EM: "   , h_bdatr023.ligdat    clipped,
                              "  AS: " , h_bdatr023.lighorinc clipped,
                              "  POR: ", ws.funnom            clipped
              let ws.ligdat = h_bdatr023.ligdat
              let ws.lighor = h_bdatr023.lighorinc
              skip 1 line

              print column 005, ws.lintxt
           end if

           print column 005, h_bdatr023.c24ligdsc

      end foreach
      skip 2 lines

      on last row
           print "$FIMREL$"

end report  ###  rep_espec
