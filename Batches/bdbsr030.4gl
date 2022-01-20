#############################################################################
# Nome do Modulo: bdbsr030                                         Marcelo  #
#                                                                  Gilberto #
# Relatorio mensal de total de servicos por prestador              Mai/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 26/05/1997  PSI 3049-0   Gilberto     Relatorio bdbsr030-B inibido.       #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Nao contabilizar servicos atendidos #
#                                       como particular (srvprlflg = "S")   #
#---------------------------------------------------------------------------#
# 06/04/1999  PSI 5591-3   Gilberto     Utilizacao dos campos padronizados  #
#                                       atraves do guia postal.             #
#---------------------------------------------------------------------------#
# 30/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 14/03/2000  PSI 10246-6  Wagner       Incluir totalizadores separados para#
#                                       Assist.Passageiros.                 #
#---------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 29/08/2000  PSI 11097-3  Wagner       Incluir totalizadores separados para#
#                                       translado e ambulancias.            #
#############################################################################
# --------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################


 database porto

 define g_traco132    char (132)
 define g_traco145    char (145)

 define ws_data_de     date
 define ws_data_ate    date
 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd
 define ws_pas         array[06]  of  record
        asitipdes      char (10),
        qtdsrv         decimal (06,0),
        qtdpas         decimal (06,0)
 end record
 define m_path         char(100)                 # Marcio Meta - PSI185035
 
 main                                                           
 
    call fun_dba_abre_banco("CT24HS") 

    let m_path = f_path("DBS","LOG")             # Marcio Meta - PSI185035
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr030.log"

    call startlog(m_path)
                                                                # Marcio Meta - PSI185035
    call bdbsr030()
 end main

#---------------------------------------------------------------
 function bdbsr030()
#---------------------------------------------------------------

 define d_bdbsr030    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod ,
    pasqtd            smallint
 end record

 define ws            record
    auxdat            char (10)                  ,
    atdetpcod         like datmsrvacp.atdetpcod  ,
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atdfnlflg         like datmservico.atdfnlflg ,
    srvprlflg         like datmservico.srvprlflg ,
    vlrtabflg         like dpaksocor.vlrtabflg   ,
    dirfisnom         like ibpkdirlog.dirfisnom  ,
    pathrel01         char (60)                  ,
    pathrel02         char (60)
 end record

 define sql_select    char(300)

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdbsr030.*  to null
 initialize ws.*          to null

 let g_traco132 = "-------------------------------------------------------------------------------------------------------------------------------------"
 let g_traco145 = "------------------------------------------------------------------------------------------------------------------------------------------------"
 let ws_pas[1].asitipdes = "TAXI"
 let ws_pas[1].qtdsrv    = 0
 let ws_pas[1].qtdpas    = 0
 let ws_pas[2].asitipdes = "AVIAO"
 let ws_pas[2].qtdsrv    = 0
 let ws_pas[1].qtdpas    = 0
 let ws_pas[3].asitipdes = "RODOVIARIO"
 let ws_pas[3].qtdsrv    = 0
 let ws_pas[3].qtdpas    = 0
 let ws_pas[4].asitipdes = "AMBULANCIA"
 let ws_pas[4].qtdsrv    = 0
 let ws_pas[4].qtdpas    = 0
 let ws_pas[5].asitipdes = "TRANSLADO"
 let ws_pas[5].qtdsrv    = 0
 let ws_pas[5].qtdpas    = 0
 let ws_pas[6].asitipdes = "HOSPEDAGEM"
 let ws_pas[6].qtdsrv    = 0
 let ws_pas[6].qtdpas    = 0

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------

 let sql_select = "select nomgrr, endcid, vlrtabflg " ,
                  "  from dpaksocor                 " ,
                  " where pstcoddig = ?             "

 prepare select_dpaksocor  from sql_select
 declare c_dpaksocor cursor for select_dpaksocor

 let sql_select = "select count(*)          ",
                  "  from datmpassageiro    ",
                  " where atdsrvnum = ?  and",
                  "       atdsrvano = ?     "

 prepare select_datmpassag  from sql_select
 declare c_datmpassag cursor for select_datmpassag

 let sql_select = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"

 prepare sel_datmsrvacp from sql_select
 declare c_datmsrvacp cursor for sel_datmsrvacp

#---------------------------------------------------------------
# Data para execucao
#---------------------------------------------------------------
 let ws.auxdat = arg_val(1)

 if ws.auxdat is null  or
    ws.auxdat =  "  "  then
    if time  >= "17:00"   and
       time  <= "23:59"   then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
#   if ws.auxdat >= today      or
    if length(ws.auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws.auxdat   = "01","/", ws.auxdat[4,5],"/", ws.auxdat[7,10]
 let ws_data_ate = ws.auxdat
 let ws_data_ate = ws_data_ate - 1 units day

 let ws.auxdat   = ws_data_ate
 let ws.auxdat   = "01","/", ws.auxdat[4,5],"/", ws.auxdat[7,10]
 let ws_data_de  = ws.auxdat

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                     # Marcio Meta - PSI185035
      returning ws.dirfisnom
      
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.' 
 end if  
                                                                  
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS03001"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS03002"
                                                                  # Marcio Meta - PSI185035

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS03001")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDBS03002")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod02,
		 ws_relviaqtd02


#---------------------------------------------------------------
# Inicio da leitura principal
#---------------------------------------------------------------
 declare c_bdbsr030 cursor for
    select datmservico.atdsrvnum ,
           datmservico.atdsrvano ,
           datmservico.atdprscod ,
           datmservico.atdsrvorg ,
           datmservico.atdfnlflg ,
           datmservico.srvprlflg ,
           datmservico.asitipcod
      from datmservico
     where atddat between ws_data_de  and ws_data_ate

 start report  rep_prssrv  to  ws.pathrel01
 start report  rep_totsrv  to  ws.pathrel01
 start report  rep_tottax  to  ws.pathrel02

 foreach c_bdbsr030  into  ws.atdsrvnum        ,
                           ws.atdsrvano        ,
                           d_bdbsr030.atdprscod,
                           d_bdbsr030.atdsrvorg,
                           ws.atdfnlflg        ,
                           ws.srvprlflg        ,
                           d_bdbsr030.asitipcod

    if d_bdbsr030.atdprscod is null or    ###  Nao contem codigo de prestador.
       d_bdbsr030.atdprscod =  0    or    ###  Codigo de Prestador e' zero.
       d_bdbsr030.atdprscod = "2"   or    ###  Servico Cancelado
       d_bdbsr030.atdsrvorg = 10    or    ###  Vistoria Previa Domiciliar
       d_bdbsr030.atdsrvorg = 11    or    ###  Aviso Furto/Roubo
       d_bdbsr030.atdsrvorg = 12    or    ###  Servico de Apoio
       d_bdbsr030.atdsrvorg = 8     then  ###  Reserva Carro Extra
       continue foreach
    end if

    if ws.srvprlflg = "S"  then
       continue foreach
    end if

    if ws.atdfnlflg = "N"  then
       continue foreach
    end if

#------------------------------------------------------------
# Verifica etapa dos servicos
#------------------------------------------------------------
    open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod = 5  or     ###  Servico CANCELADO
       ws.atdetpcod = 6  then   ###  Servico EXCLUIDO
       continue foreach
    end if

#---------------------------------------------------------------
# Dados do prestador
#---------------------------------------------------------------
    let d_bdbsr030.nomgrr = "*** NAO CADASTRADO ***"
    let d_bdbsr030.endcid = "*** NAO CADASTRADO ***"

    open  c_dpaksocor using d_bdbsr030.atdprscod
    fetch c_dpaksocor into  d_bdbsr030.nomgrr    ,
                            d_bdbsr030.endcid    ,
                            ws.vlrtabflg
    close c_dpaksocor

    if d_bdbsr030.atdprscod = 1  or
       d_bdbsr030.atdprscod = 4  or
       d_bdbsr030.atdprscod = 8  then
       let d_bdbsr030.atdprstip = 1     ###  Frota Porto Seguro
    else
       if ws.vlrtabflg = "S" then
          let d_bdbsr030.atdprstip = 2  ###  Tabela
       else
          let d_bdbsr030.atdprstip = 3  ###  Outros
       end if
    end if

#----------------------------------------------------------------
# Informacoes para relatorio de assistencia a passageiros - Taxi
#----------------------------------------------------------------
    let d_bdbsr030.pasqtd = 0
    if d_bdbsr030.atdsrvorg = 3    or
       d_bdbsr030.atdsrvorg = 2    then
       open  c_datmpassag using ws.atdsrvnum, ws.atdsrvano
       fetch c_datmpassag into  d_bdbsr030.pasqtd
       close c_datmpassag
    end if

    output to report rep_prssrv(d_bdbsr030.*)

 end foreach

 finish report rep_prssrv
 finish report rep_totsrv
 finish report rep_tottax

end function  ###  bdbsr030

#---------------------------------------------------------------------------
 report rep_prssrv(par_bdbsr030)
#---------------------------------------------------------------------------

 define par_bdbsr030  record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod ,
    pasqtd            smallint
 end record

 define r_bdbsr030    record
    rem               dec (06,0)                 ,
    soc               dec (06,0)                 ,
    gui               dec (06,0)                 ,
    tec               dec (06,0)                 ,
    amb               dec (06,0)                 ,
    cha               dec (06,0)                 ,
    daf               dec (06,0)                 ,
    rpt               dec (06,0)                 ,
    rep               dec (06,0)                 ,
    sre               dec (06,0)                 ,
    grl               dec (06,0)                 ,
    tax               dec (06,0)                 ,
    pas               dec (06,0)
 end record

   output
      left   margin  000
      right  margin  001
      top    margin  000
      bottom margin  000
      page   length  080

   order by  par_bdbsr030.atdprstip,
             par_bdbsr030.atdprscod

   format

      before group of par_bdbsr030.atdprscod
             let r_bdbsr030.rem      = 0
             let r_bdbsr030.soc      = 0
             let r_bdbsr030.gui      = 0
             let r_bdbsr030.tec      = 0
             let r_bdbsr030.amb      = 0
             let r_bdbsr030.cha      = 0
             let r_bdbsr030.daf      = 0
             let r_bdbsr030.rpt      = 0
             let r_bdbsr030.rep      = 0
             let r_bdbsr030.sre      = 0
             let r_bdbsr030.grl      = 0
             let r_bdbsr030.tax      = 0
             let r_bdbsr030.pas      = 0

      after  group of par_bdbsr030.atdprscod

             if r_bdbsr030.grl > 0  then
                output to report rep_totsrv(par_bdbsr030.*, r_bdbsr030.*)
             end if

             if r_bdbsr030.tax > 0  then
                output to report rep_tottax(par_bdbsr030.*, r_bdbsr030.*)
             end if

      on every row
             case par_bdbsr030.atdsrvorg
                  when 4          # Remocoes
                       let r_bdbsr030.rem = r_bdbsr030.rem + 1
                  when 6          # D.A.F.
                       let r_bdbsr030.daf = r_bdbsr030.daf + 1
                  when 1          # Porto Socorro
                       let r_bdbsr030.soc = r_bdbsr030.soc + 1
                       case par_bdbsr030.asitipcod
                            when  1      # Guincho
                                 let r_bdbsr030.gui = r_bdbsr030.gui + 1
                            when  2      # Tecnico
                                 let r_bdbsr030.tec = r_bdbsr030.tec + 1
                            when  3      # Ambos
                                 let r_bdbsr030.amb = r_bdbsr030.amb + 1
                            when  4      # Chaveiro
                                 let r_bdbsr030.cha = r_bdbsr030.cha + 1
                            when  8      # Chaveiro/Dispositivo
                                 let r_bdbsr030.cha = r_bdbsr030.cha + 1
                       end case

                  when 5          # RPT
                       let r_bdbsr030.rpt = r_bdbsr030.rpt + 1
                  when 7          # Replace
                       let r_bdbsr030.rep = r_bdbsr030.rep + 1
                  when 9          # Socorro R.E.
                       let r_bdbsr030.sre = r_bdbsr030.sre + 1
                  when 13         # Sinistro R.E.
                       let r_bdbsr030.sre = r_bdbsr030.sre + 1
                  when 2          # Assist. Passageiros
                       let r_bdbsr030.tax = r_bdbsr030.tax + 1
                       let r_bdbsr030.pas = r_bdbsr030.pas + par_bdbsr030.pasqtd
                       case par_bdbsr030.asitipcod
                            when  5      # Taxi
                               let ws_pas[1].qtdsrv = ws_pas[1].qtdsrv + 1
                               let ws_pas[1].qtdpas = ws_pas[1].qtdpas +
                                                      par_bdbsr030.pasqtd
                            when 10      # Aviao
                               let ws_pas[2].qtdsrv = ws_pas[2].qtdsrv + 1
                               let ws_pas[2].qtdpas = ws_pas[2].qtdpas +
                                                      par_bdbsr030.pasqtd
                            when 16      # Rodoviario
                               let ws_pas[3].qtdsrv = ws_pas[3].qtdsrv + 1
                               let ws_pas[3].qtdpas = ws_pas[3].qtdpas +
                                                      par_bdbsr030.pasqtd
                            when 11      # Ambulancia
                               let ws_pas[4].qtdsrv = ws_pas[4].qtdsrv + 1
                               let ws_pas[4].qtdpas = ws_pas[4].qtdpas +
                                                      par_bdbsr030.pasqtd
                            when 12      # Translado
                               let ws_pas[5].qtdsrv = ws_pas[5].qtdsrv + 1
                               let ws_pas[5].qtdpas = ws_pas[5].qtdpas +
                                                      par_bdbsr030.pasqtd
                       end case
                  when 3          # Assist. Passageiros
                       let r_bdbsr030.tax = r_bdbsr030.tax + 1
                       let r_bdbsr030.pas = r_bdbsr030.pas + par_bdbsr030.pasqtd
                       if par_bdbsr030.asitipcod =  13  then      # Hospedagem
                          let ws_pas[6].qtdsrv = ws_pas[6].qtdsrv + 1
                          let ws_pas[6].qtdpas = ws_pas[6].qtdpas +
                                                 par_bdbsr030.pasqtd
                       end if
             end case

             if par_bdbsr030.atdsrvorg <> 3  and
                par_bdbsr030.atdsrvorg <> 2  then
                let r_bdbsr030.grl = r_bdbsr030.grl + 1
             end if

end report  ###  rep_prssrv

#---------------------------------------------------------------------------
 report rep_totsrv(r_bdbsr030)
#---------------------------------------------------------------------------

 define r_bdbsr030    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod ,
    pasqtd            smallint                   ,
    rem               dec (6,0)                  ,
    soc               dec (6,0)                  ,
    gui               dec (6,0)                  ,
    tec               dec (6,0)                  ,
    amb               dec (6,0)                  ,
    cha               dec (6,0)                  ,
    daf               dec (6,0)                  ,
    rpt               dec (6,0)                  ,
    rep               dec (6,0)                  ,
    sre               dec (6,0)                  ,
    grl               dec (06,0)                 ,
    tax               dec (06,0)                 ,
    pas               dec (06,0)
 end record

 define a_bdbsr030    array[04] of record
    dsc               char (06)                  ,
    rem               dec (6,0)                  ,
    soc               dec (6,0)                  ,
    gui               dec (6,0)                  ,
    tec               dec (6,0)                  ,
    amb               dec (6,0)                  ,
    cha               dec (6,0)                  ,
    daf               dec (6,0)                  ,
    rpt               dec (6,0)                  ,
    rep               dec (6,0)                  ,
    sre               dec (6,0)                  ,
    grl               dec (6,0)
 end record

 define arr_aux       smallint
 define tot           smallint

 define porcent       dec (5,2)

   output
      left   margin  000
      right  margin  145
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr030.atdprstip ,
             r_bdbsr030.grl desc

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03001 FORMNAME=BRANCO"          # Marcio Meta - PSI185035 
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - TOTAIS DE SERVICOS ATENDIDOS POR TIP/PRESTADOR"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
            print ascii(12)

            let tot = 4

            for arr_aux = 1  to  4
               case arr_aux
                  when 1  let a_bdbsr030[arr_aux].dsc = "FROTA"
                  when 2  let a_bdbsr030[arr_aux].dsc = "TABELA"
                  when 3  let a_bdbsr030[arr_aux].dsc = "OUTROS"
                  when 4  let a_bdbsr030[arr_aux].dsc = "TODOS"
               end case

               let a_bdbsr030[arr_aux].rem = 0
               let a_bdbsr030[arr_aux].soc = 0
               let a_bdbsr030[arr_aux].gui = 0
               let a_bdbsr030[arr_aux].tec = 0
               let a_bdbsr030[arr_aux].amb = 0
               let a_bdbsr030[arr_aux].cha = 0
               let a_bdbsr030[arr_aux].daf = 0
               let a_bdbsr030[arr_aux].rpt = 0
               let a_bdbsr030[arr_aux].rep = 0
               let a_bdbsr030[arr_aux].sre = 0
               let a_bdbsr030[arr_aux].grl = 0
            end for

            let arr_aux = 1
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 112, "RDBS030-01",
               column 126, "PAGINA : "  , pageno using "##,###,#&&"
         print column 021, "SERVICOS ATENDIDOS POR PRESTADOR NO PERIODO DE ", ws_data_de, " A ", ws_data_ate,
               column 126, "DATA   : "  , today
         print column 126, "HORA   :   ", time
         print column 001, "TIPO PRESTADORES: ", a_bdbsr030[arr_aux].dsc
         skip 1 lines
         print column 001, g_traco145

         print column 001, "CODIGO"     ,
               column 009, "PRESTADOR"  ,
               column 031, "CIDADE"     ,
               column 057, "REMOCAO"    ,
               column 066, "-----------  SOCORRO  ------------",
               column 102, " D.A.F."    ,
               column 111, " R.P.T."    ,
               column 120, "REPLACE"    ,
               column 129, "   R.E."    ,
               column 138, "  TOTAL"

         print column 066, "GUINCHO"    ,
               column 075, "TECNICO"    ,
               column 084, "  AMBOS"    ,
               column 092, "CHAVEIRO"

         print column 001, g_traco145
         skip 1 line

      before group of r_bdbsr030.atdprstip
         let arr_aux = r_bdbsr030.atdprstip
         skip to top of page

      after group of r_bdbsr030.atdprstip
         skip 2 lines
         print column 001, g_traco145
         print column 001, "TOTAL DE SERVICOS:",
               column 057, a_bdbsr030[arr_aux].rem using "###,##&" ,
               column 066, a_bdbsr030[arr_aux].gui using "###,##&" ,
               column 075, a_bdbsr030[arr_aux].tec using "###,##&" ,
               column 084, a_bdbsr030[arr_aux].amb using "###,##&" ,
               column 093, a_bdbsr030[arr_aux].cha using "###,##&" ,
               column 102, a_bdbsr030[arr_aux].daf using "###,##&" ,
               column 111, a_bdbsr030[arr_aux].rpt using "###,##&" ,
               column 120, a_bdbsr030[arr_aux].rep using "###,##&" ,
               column 129, a_bdbsr030[arr_aux].sre using "###,##&" ,
               column 138, a_bdbsr030[arr_aux].grl using "###,##&"
         print column 001, g_traco145
         skip 1 line

         let a_bdbsr030[tot].rem = a_bdbsr030[tot].rem + a_bdbsr030[arr_aux].rem
         let a_bdbsr030[tot].soc = a_bdbsr030[tot].soc + a_bdbsr030[arr_aux].soc
         let a_bdbsr030[tot].gui = a_bdbsr030[tot].gui + a_bdbsr030[arr_aux].gui
         let a_bdbsr030[tot].tec = a_bdbsr030[tot].tec + a_bdbsr030[arr_aux].tec
         let a_bdbsr030[tot].amb = a_bdbsr030[tot].amb + a_bdbsr030[arr_aux].amb
         let a_bdbsr030[tot].cha = a_bdbsr030[tot].cha + a_bdbsr030[arr_aux].cha
         let a_bdbsr030[tot].daf = a_bdbsr030[tot].daf + a_bdbsr030[arr_aux].daf
         let a_bdbsr030[tot].rpt = a_bdbsr030[tot].rpt + a_bdbsr030[arr_aux].rpt
         let a_bdbsr030[tot].rep = a_bdbsr030[tot].rep + a_bdbsr030[arr_aux].rep
         let a_bdbsr030[tot].sre = a_bdbsr030[tot].sre + a_bdbsr030[arr_aux].sre
         let a_bdbsr030[tot].grl = a_bdbsr030[tot].grl + a_bdbsr030[arr_aux].grl

      on every row
         let a_bdbsr030[arr_aux].rem = a_bdbsr030[arr_aux].rem + r_bdbsr030.rem
         let a_bdbsr030[arr_aux].soc = a_bdbsr030[arr_aux].soc + r_bdbsr030.soc
         let a_bdbsr030[arr_aux].gui = a_bdbsr030[arr_aux].gui + r_bdbsr030.gui
         let a_bdbsr030[arr_aux].tec = a_bdbsr030[arr_aux].tec + r_bdbsr030.tec
         let a_bdbsr030[arr_aux].amb = a_bdbsr030[arr_aux].amb + r_bdbsr030.amb
         let a_bdbsr030[arr_aux].cha = a_bdbsr030[arr_aux].cha + r_bdbsr030.cha
         let a_bdbsr030[arr_aux].daf = a_bdbsr030[arr_aux].daf + r_bdbsr030.daf
         let a_bdbsr030[arr_aux].rpt = a_bdbsr030[arr_aux].rpt + r_bdbsr030.rpt
         let a_bdbsr030[arr_aux].rep = a_bdbsr030[arr_aux].rep + r_bdbsr030.rep
         let a_bdbsr030[arr_aux].sre = a_bdbsr030[arr_aux].sre + r_bdbsr030.sre
         let a_bdbsr030[arr_aux].grl = a_bdbsr030[arr_aux].grl + r_bdbsr030.grl

         print column 001, r_bdbsr030.atdprscod  using "&&&&&&" ,
               column 009, r_bdbsr030.nomgrr                    ,
               column 031, r_bdbsr030.endcid                    ,
               column 057, r_bdbsr030.rem        using "###,##&",
               column 066, r_bdbsr030.gui        using "###,##&",
               column 075, r_bdbsr030.tec        using "###,##&",
               column 084, r_bdbsr030.amb        using "###,##&",
               column 093, r_bdbsr030.cha        using "###,##&",
               column 102, r_bdbsr030.daf        using "###,##&",
               column 111, r_bdbsr030.rpt        using "###,##&",
               column 120, r_bdbsr030.rep        using "###,##&",
               column 129, r_bdbsr030.sre        using "###,##&",
               column 138, r_bdbsr030.grl        using "###,##&"

      on last row
         let r_bdbsr030.atdprstip = 4
         skip to top of page
         skip 5 lines

         print column 021, "============================================================================================================"
         print column 022, "PRESTADOR"  ,
               column 047, "REMOCAO"    ,
               column 057, "SOCORRO"    ,
               column 067, " D.A.F."    ,
               column 077, " R.P.T."    ,
               column 087, "REPLACE"    ,
               column 097, "   R.E."    ,
               column 107, "  TOTAL DE SERVICOS "
         print column 021, "============================================================================================================"

         for arr_aux = 1  to  tot
            if arr_aux = tot  then
               print column 021, "============================================================================================================"
            else
               let porcent = 0
               let porcent = (a_bdbsr030[arr_aux].grl / a_bdbsr030[tot].grl) * 100
            end if
            print column 022, a_bdbsr030[arr_aux].dsc                  ,
                  column 047, a_bdbsr030[arr_aux].rem  using "###,##&" ,
                  column 057, a_bdbsr030[arr_aux].soc  using "###,##&" ,
                  column 067, a_bdbsr030[arr_aux].daf  using "###,##&" ,
                  column 077, a_bdbsr030[arr_aux].rpt  using "###,##&" ,
                  column 087, a_bdbsr030[arr_aux].rep  using "###,##&" ,
                  column 097, a_bdbsr030[arr_aux].sre  using "###,##&" ,
                  column 107, a_bdbsr030[arr_aux].grl  using "###,##&" ,
                  "  -  (" ,  porcent                  using "##&.&&%" , ")"
         end for

         let porcent = 0
         let porcent = (a_bdbsr030[tot].rem / a_bdbsr030[tot].grl) * 100
         print column 047, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].soc / a_bdbsr030[tot].grl) * 100
         print column 057, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].daf / a_bdbsr030[tot].grl) * 100
         print column 067, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].rpt / a_bdbsr030[tot].grl) * 100
         print column 077, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].rep / a_bdbsr030[tot].grl) * 100
         print column 087, porcent     using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].sre / a_bdbsr030[tot].grl) * 100
         print column 097, porcent     using "##&.&&%"

         skip 10 lines

         print column 021, "================================================================================================"
         print column 022, "SOCORRO"    ,
               column 047, "GUINCHO"    ,
               column 057, "TECNICO"    ,
               column 067, "  AMBOS"    ,
               column 076, "CHAVEIRO"   ,
               column 107, "  TOTAL"
         print column 021, "=============================================================================================="

         print column 022, "TOTAL: "  ,
               column 047, a_bdbsr030[tot].gui  using "###,##&" ,
               column 057, a_bdbsr030[tot].tec  using "###,##&" ,
               column 067, a_bdbsr030[tot].amb  using "###,##&" ,
               column 077, a_bdbsr030[tot].cha  using "###,##&" ,
               column 107, a_bdbsr030[tot].soc  using "###,##&"

         print column 021, "=============================================================================================="
         let porcent = 0
         let porcent = (a_bdbsr030[tot].gui / a_bdbsr030[tot].soc) * 100
         print column 047, porcent        using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].tec / a_bdbsr030[tot].soc) * 100
         print column 057, porcent        using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].amb / a_bdbsr030[tot].soc) * 100
         print column 067, porcent        using "##&.&&%" ;
         let porcent = 0
         let porcent = (a_bdbsr030[tot].cha / a_bdbsr030[tot].soc) * 100
         print column 077, porcent        using "##&.&&%"

         print "$FIMREL$"

end report  ###  rep_totsrv

#---------------------------------------------------------------------------
 report rep_tottax(r_bdbsr030)
#---------------------------------------------------------------------------

 define r_bdbsr030   record
    atdprscod        like datmservico.atdprscod ,
    atdprstip        smallint                   ,
    nomgrr           like dpaksocor.nomgrr      ,
    endcid           char (030)                 ,
    atdsrvorg        like datmservico.atdsrvorg ,
    asitipcod        like datmservico.asitipcod ,
    pasqtd           smallint                   ,
    rem              dec (6,0)                  ,
    soc              dec (6,0)                  ,
    gui              dec (6,0)                  ,
    tec              dec (6,0)                  ,
    amb              dec (6,0)                  ,
    cha              dec (6,0)                  ,
    daf              dec (6,0)                  ,
    rpt              dec (6,0)                  ,
    rep              dec (6,0)                  ,
    sre              dec (6,0)                  ,
    grl              dec (6,0)                  ,
    tax              dec (6,0)                  ,
    pas              dec (6,0)
 end record

 define ws           record
    taxtotqtd        dec (6,0)                  ,
    pastotqtd        dec (6,0)                  ,
    pasmed           dec (13,2)
 end record

 define ws_x         smallint

 output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr030.tax  desc


   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03002 FORMNAME=BRANCO"         # Marcio Meta - PSI185035 
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - ASSISTENCIAS A PASSAGEIROS ATENDIDAS POR PRESTADOR"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
            print ascii(12)

            let ws.taxtotqtd = 0
            let ws.pastotqtd = 0
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 099, "RDBS030-02",
               column 113, "PAGINA : "  , pageno using "##,###,##&"
         print column 008, "ASSISTENCIAS A PASSAGEIROS ATENDIDAS POR PRESTADOR NO PERIODO DE ", ws_data_de, " A ", ws_data_ate,
               column 113, "DATA   : "  , today
         print column 113, "HORA   :   ", time
         skip 2 lines

         print column 001, "ASSISTENCIAS A PASSAGEIROS"
         print column 001, g_traco132

         print column 001, "CODIGO"     ,
               column 010, "PRESTADOR"  ,
               column 033, "CIDADE"     ,
               column 071, "SERVICOS"   ,
               column 087, "PASSAG."    ,
               column 105, "MEDIA"
         print column 001, g_traco132

      on every row
         if r_bdbsr030.pas  >  0   then
            let ws.pasmed = r_bdbsr030.pas / r_bdbsr030.tax
         end if

         print column 001, r_bdbsr030.atdprscod  using "&&&&&&"    ,
               column 010, r_bdbsr030.nomgrr                       ,
               column 033, r_bdbsr030.endcid                       ,
               column 072, r_bdbsr030.tax        using "###,##&"   ,
               column 087, r_bdbsr030.pas        using "###,##&"   ,
               column 100, ws.pasmed             using "###,##&.&&"
         skip 1 line

         let ws.taxtotqtd = ws.taxtotqtd + r_bdbsr030.tax
         let ws.pastotqtd = ws.pastotqtd + r_bdbsr030.pas

      on last row
         if ws.pastotqtd  >  0   then
            let ws.pasmed = ws.pastotqtd / ws.taxtotqtd
         end if

         skip 2 lines
         need 6 lines
         print column 001, g_traco132
         print column 001, "TOTAL GERAL : ",
               column 072, ws.taxtotqtd  using "###,##&"     ,
               column 087, ws.pastotqtd  using "###,##&"     ,
               column 100, ws.pasmed     using "###,##&.&&"
         print column 001, g_traco132

         skip 1 lines
         for ws_x = 1 to 6
             if ws_pas[ws_x].qtdsrv  >  0   then
                let ws.pasmed = ws_pas[ws_x].qtdpas / ws_pas[ws_x].qtdsrv
             else
                let ws.pasmed = 0
             end if
             print column 001, "TOTAL ",ws_pas[ws_x].asitipdes ," : ",
                   column 072, ws_pas[ws_x].qtdsrv  using "###,##&"     ,
                   column 087, ws_pas[ws_x].qtdpas  using "###,##&"     ,
                   column 100, ws.pasmed     using "###,##&.&&"
         end for
         print column 001, g_traco132

         print "$FIMREL$"

end report  ###  rep_tottax
