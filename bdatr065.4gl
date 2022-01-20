##################################################################################
# Nome do Modulo: BDATR065                                              Marcelo  #
#                                                                       Gilberto #
#                                                                       Wagner   #
# Relatorio para checar solicitante X nome principal motorista          Jul/1999 #
##################################################################################
#                                                                                #
# 14/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo            #
#                                       atdsrvnum de 6 p/ 10.                    #
#                                       Troca do campo atdtip p/ atdsrvorg.      #
#--------------------------------------------------------------------------------#
# 22/04/2003  FERNANDO - FSW            RESOLUCAO 86                             #
##################################################################################
#                  * * *  A L T E R A C O E S  * * *                             #
#                                                                                #
# Data       Autor Fabrica         PSI       Alteracoes                          #
# ---------- --------------------- ------    ------------------------------------#
# 10/09/2005 JUNIOR (Meta)         Melhorias incluida funcao fun_dba_abre_banco. #
# 16/11/2006 alberto Rodrigues     205206    implementado leitura campo ciaempcod#
#                                            para desprezar qdo for Azul Segur.  #
##################################################################################

 database porto

 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd
 define ws_data       date

 define g_traco       char(134)

 main
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    call bdatr065()
 end main


#---------------------------------------------------------------
 function bdatr065()
#---------------------------------------------------------------

 define d_bdatr065    record
    c24solnom         like datmservico.c24solnom  ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    atddat            like datmservico.atddat     ,
    succod            like datrservapol.succod    ,
    ramcod            like datrservapol.ramcod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    ciaempcod         like datmservico.ciaempcod
 end record

 define ws            record
    comando           char(300)                    ,
    auxdat            char (10)                    ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    clscod            like abbmclaus.clscod        ,
    segnumdig         like gsakseg.segnumdig       ,
    segnom            char(40)                     ,
    txtlin            char(20)                     ,
    dctnumseq         like abbmquesttxt.dctnumseq  ,
    privez            char(1)                      ,
    dirfisnom         like ibpkdirlog.dirfisnom    ,
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

 define ws_point      smallint


#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdatr065.*  to null
 initialize ws.*          to null

 let ws.privez = "S"
 let g_traco   = "------------------------------------------------------------------------------------------------------------------------------------"


#--------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------

 let ws.comando = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let ws.comando = "select clscod   ",
                  "  from abbmclaus",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? ",
                  "   and clscod    = '018' "
 prepare sel_abbmclaus  from ws.comando
 declare c_abbmclaus  cursor for sel_abbmclaus

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

 let ws.comando = "select txtlin",
                  "  from abbmquesttxt",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? ",
                  "   and qstcod    = 19 "
 prepare sel_abbmquesttxt  from ws.comando
 declare c_abbmquesttxt  cursor for sel_abbmquesttxt

#--------------------------------------------------------------------
# Define data parametro
#--------------------------------------------------------------------
 let ws.auxdat = arg_val(1)

 if ws.auxdat is null       or
    ws.auxdat =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
    if ws.auxdat > today       or
       length(ws.auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if
 let ws_data  = ws.auxdat


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT06501"

#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDAT06501")
      returning  ws_cctcod,
         	 ws_relviaqtd

#---------------------------------------------------------------
# Cursor principal
#---------------------------------------------------------------

 declare  c_bdatr065  cursor for
    select datmservico.atdsrvnum , datmservico.atdsrvano ,
           datmservico.atdsrvorg ,
           datmservico.atddat    , datrservapol.succod   ,
           datrservapol.ramcod   , datrservapol.aplnumdig,
           datrservapol.itmnumdig, datmservico.c24solnom ,
           datmservico.ciaempcod
      from datmservico, datrservapol
     where datmservico.atddat      = ws_data
       and datmservico.atdsrvorg   in ( 4 ,  6 ,  1 ,  2 )
       and datmservico.atdfnlflg   = "S"
       and datmservico.atdsoltip   = "S"
       and datrservapol.atdsrvnum  = datmservico.atdsrvnum
       and datrservapol.atdsrvano  = datmservico.atdsrvano

 start report  rep_semproc  to  ws.pathrel01

 foreach c_bdatr065  into  d_bdatr065.atdsrvnum , d_bdatr065.atdsrvano ,
                           d_bdatr065.atdsrvorg ,
                           d_bdatr065.atddat    , d_bdatr065.succod   ,
                           d_bdatr065.ramcod    , d_bdatr065.aplnumdig,
                           d_bdatr065.itmnumdig , d_bdatr065.c24solnom,
                           d_bdatr065.ciaempcod

    if d_bdatr065.ciaempcod = 35  or       
       d_bdatr065.ciaempcod = 40  or       
       d_bdatr065.ciaempcod = 43  or     
       d_bdatr065.ciaempcod = 84  or     
       d_bdatr065.ciaempcod = 27  then ## PSI Empresa 27
       continue foreach            
    end if                         

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using d_bdatr065.atdsrvnum, d_bdatr065.atdsrvano,
                             d_bdatr065.atdsrvnum, d_bdatr065.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod <> 4      then   # somente servicos etapa concluida
       continue foreach
    end if

    #---------------------------------------------------------------
    # Busca ultima situacao da apolice / Nome do segurado
    #---------------------------------------------------------------
    initialize ws_funapol.*   to null
    initialize ws.segnumdig   to null

    call f_funapol_ultima_situacao
         (d_bdatr065.succod, d_bdatr065.aplnumdig, d_bdatr065.itmnumdig)
          returning  ws_funapol.*

    open  c_abbmdoc   using d_bdatr065.succod   , d_bdatr065.aplnumdig,
                            d_bdatr065.itmnumdig, ws_funapol.dctnumseq
    fetch c_abbmdoc   into  ws.segnumdig
    close c_abbmdoc


    #---------------------------------------------------------------
    # Verifica clausula 18
    #---------------------------------------------------------------
    initialize ws.clscod  to null
    open  c_abbmclaus using d_bdatr065.succod   , d_bdatr065.aplnumdig,
                            d_bdatr065.itmnumdig, ws_funapol.dctnumseq
    fetch c_abbmclaus into  ws.clscod
    close c_abbmclaus

    if ws.clscod <> "018"  or
       ws.clscod is null   then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Busca nome do segurado
    #---------------------------------------------------------------
    initialize ws.segnom      to null

    if ws.segnumdig  is not null   then
       open  c_gsakseg using ws.segnumdig
       fetch c_gsakseg into  ws.segnom
       close c_gsakseg
    end if

    #---------------------------------------------------------------
    # Busca nome no questionario
    #---------------------------------------------------------------
    open  c_abbmquesttxt using d_bdatr065.succod   , d_bdatr065.aplnumdig,
                               d_bdatr065.itmnumdig, ws_funapol.dctnumseq
    fetch c_abbmquesttxt into  ws.txtlin
    close c_abbmquesttxt

    if ws.txtlin is null then
       select max(dctnumseq)
         into ws.dctnumseq
         from abbmquesttxt
        where succod    = d_bdatr065.succod
          and aplnumdig = d_bdatr065.aplnumdig
          and itmnumdig = d_bdatr065.itmnumdig
          and qstcod    = 19

          open c_abbmquesttxt using d_bdatr065.succod ,   d_bdatr065.aplnumdig,
                                    d_bdatr065.itmnumdig , ws.dctnumseq
          fetch c_abbmquesttxt   into  ws.txtlin
          close c_abbmquesttxt

       if ws.txtlin is null then
          continue foreach
       end if
    end if


    for ws_point = 1 to length(ws.txtlin)
        if ws.txtlin[ws_point,ws_point] =  " "  then
           exit for
        end if
    end for
    let ws_point = ws_point - 1
    if ws_point < 1 then
       let ws_point = 1
    end if

    if ws.txtlin[1,ws_point] <> d_bdatr065.c24solnom[1,ws_point] then
       output to report rep_semproc(d_bdatr065.ramcod   , d_bdatr065.succod   ,
                                    d_bdatr065.aplnumdig, d_bdatr065.itmnumdig,
                                    d_bdatr065.atdsrvnum, d_bdatr065.atdsrvano,
                                    d_bdatr065.atdsrvorg, ws.segnom           ,                                     ws.txtlin           , d_bdatr065.c24solnom)
    end if

 end foreach

 finish report  rep_semproc

end function  ###  bdatr065

#---------------------------------------------------------------------------
 report rep_semproc(r_bdatr065)
#---------------------------------------------------------------------------

 define r_bdatr065    record
    ramcod            like datrservapol.ramcod    ,
    succod            like datrservapol.succod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    segnom            char(40)                    ,
    txtlin            like abbmquesttxt.txtlin    ,
    c24solnom         like datmservico.c24solnom
 end record

 define ws_rep        record
    total             integer
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
              print "OUTPUT JOBNAME=DAT06501 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - DIVERGENCIA 018 X SOLICITANTE SERVICOS"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)
              let ws_rep.total  = 0
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if
           print column 099, "RDAT065-01",
                 column 113, "PAGINA : ", pageno using "##,###,###"
           print column 113, "DATA   : ", today
           print column 025, "DIVERGENCIA 018 X SOLICITANTE SERVICOS DE : ",
                             ws_data,
                 column 113, "HORA   :   ", time
           skip 2 lines

           print column 001, g_traco

           print column 001, "RAMO/SUC./APOLICE/ITEM",
                 column 024, "SERVICO "  ,
                 column 038, "NOME SEGURADO" ,
                 column 070, "NOME MOTORISTA",
                 column 097, "NOME SOLICITANTE"

           print column 001, g_traco
           skip 1 line

      on every row
           print column 002, r_bdatr065.ramcod     using "&&&&"     ,
                 column 005, r_bdatr065.succod     using "&&"       ,
                 column 008, r_bdatr065.aplnumdig  using "&&&&&&&&&",
                 column 018, r_bdatr065.itmnumdig  using "&&&&&&"   ,
                 column 024, r_bdatr065.atdsrvorg  using "&&"       ,
                        "/", r_bdatr065.atdsrvnum  using "&&&&&&&"  ,
                        "-", r_bdatr065.atdsrvano  using "&&"       ,
                 column 038, r_bdatr065.segnom[1,30]                ,
                 column 070, r_bdatr065.txtlin[1,25]                ,
                 column 097, r_bdatr065.c24solnom

           let ws_rep.total = ws_rep.total + 1

      on last  row
           skip 2 lines
           print column 001, g_traco
           print column 001, "TOTAL DE SERVICOS ",
                             ws_rep.total   using "##,##&"
           print column 001, g_traco

           print "$FIMREL$"

end report  ###  rep_semproc
