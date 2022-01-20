############################################################################
# Nome do Modulo: bdbsr013                                        Marcelo  #
#                                                                 Gilberto #
# Estatistica dos servicos por motorista/prestador                Jan/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas #
#                                       para verificacao do servico.       #
############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

 database porto

 define ws_traco      char(145)
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd
 
 define m_path        char(100)

 main
  
    call fun_dba_abre_banco("CT24HS") 

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr013.log"

    call startlog(m_path)
    # PSI 185035 - Final
  
    call bdbsr013()
 end main

#---------------------------------------------------------------
 function  bdbsr013()
#---------------------------------------------------------------

 define  d_bdbsr013   record
    motprstip         char(06)                    ,
    atdprscod         like datmservico.atdprscod  ,
    motprsnom         char(20)                    ,
    psqsrvflg         char(01)                    ,
    qtdtmpoti         dec (4,0)                   ,
    qtdtmpbom         dec (4,0)                   ,
    qtdtmpreg         dec (4,0)                   ,
    qtdtmprui         dec (4,0)                   ,
    qtdtmppes         dec (4,0)                   ,
    qtdtmpnsi         dec (4,0)                   ,
    qtdsrvoti         dec (4,0)                   ,
    qtdsrvbom         dec (4,0)                   ,
    qtdsrvreg         dec (4,0)                   ,
    qtdsrvrui         dec (4,0)                   ,
    qtdsrvpes         dec (4,0)                   ,
    qtdsrvnsi         dec (4,0)                   ,
    avlitmcod         like datrpesqaval.avlitmcod ,
    avlpsqnot         like datrpesqaval.avlpsqnot
 end record

 define ws            record
    achou             dec (1,0)                   ,
    datax             char(10)                    ,
    datade            date                        ,
    dataate           date                        ,
    atdetpcod         like datmsrvacp.atdetpcod   ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atdprscod         like datmservico.atdprscod  ,
    srrcoddig         like datmservico.srrcoddig  ,
    atdmotnom         like datmservico.atdmotnom  ,
    psqcod            like datmpesquisa.psqcod    ,
    vlrtabflg         like dpaksocor.vlrtabflg    ,
    dirfisnom         like ibpkdirlog.dirfisnom   ,
    pathrel01         char (60)
 end record

 define sql_select    char(250)


 let ws_traco  = "_________________________________________________________________________________________________________________________________________________"

 initialize d_bdbsr013.*  to null
 initialize ws.*          to null

 #---------------------------------------------------------------
 # Prepara comando sql
 #---------------------------------------------------------------
 let sql_select = "select nomgrr,",
                  "       vlrtabflg ",
                  "  from dpaksocor ",
                  " where pstcoddig = ?"
 prepare sel_dpaksocor from sql_select
 declare c_dpaksocor cursor for sel_dpaksocor

 let sql_select = "select srrabvnom ",
                  "  from datksrr ",
                  " where srrcoddig = ?"
 prepare sel_datksrr from sql_select
 declare c_datksrr cursor for sel_datksrr

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
 # Monta data (periodo mensal)
 #---------------------------------------------------------------
 let ws.datax   = today

 let ws.datax   = "01","/",ws.datax[4,5],"/",ws.datax[7,10]
 let ws.dataate = ws.datax
 let ws.dataate = ws.dataate - 1 units day

 let ws.datax   = ws.dataate
 let ws.datax   = "01","/",ws.datax[4,5],"/",ws.datax[7,10]
 let ws.datade  = ws.datax

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws.dirfisnom
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS01301"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS01301")
      returning  ws_cctcod,
		 ws_relviaqtd

 #---------------------------------------------------------------------
 # Monta cursor contendo todos os servicos concluidos dentro do periodo
 #---------------------------------------------------------------------
 declare c_bdbsr013   cursor for
    select datmpesquisa.atdsrvnum ,
           datmpesquisa.atdsrvano ,
           datmpesquisa.psqcod    ,
           datmservico.atdprscod  ,
           datmservico.atdmotnom  ,
           datmservico.srrcoddig
      from datmpesquisa, datmservico
     where datmpesquisa.caddat    between  ws.datade and ws.dataate

       and datmservico.atdsrvnum  =  datmpesquisa.atdsrvnum
       and datmservico.atdsrvano  =  datmpesquisa.atdsrvano
       and datmservico.atdfnlflg  =  "S"

 start report  rep_psqest  to  ws.pathrel01

 foreach c_bdbsr013  into  ws.atdsrvnum         ,
                           ws.atdsrvano         ,
                           ws.psqcod            ,
                           d_bdbsr013.atdprscod ,
                           d_bdbsr013.motprsnom ,
                           ws.srrcoddig

   #------------------------------------------------------------
   # Verifica etapa dos servicos
   #------------------------------------------------------------
   open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                            ws.atdsrvnum, ws.atdsrvano
   fetch c_datmsrvacp into  ws.atdetpcod
   close c_datmsrvacp

   if ws.atdetpcod < 3  and
      ws.atdetpcod > 4  then
      continue foreach
   end if

   if d_bdbsr013.atdprscod = 2   or    # Servico Cancelado
      d_bdbsr013.atdprscod = 3   or    # Reembolso ao Segurado
      d_bdbsr013.atdprscod = 6   then  # Prestador nao credenciado
      continue foreach
   end if

   #------------------------------------------------------------
   # Se nao for frota Porto pesquisa nome de guerra
   #------------------------------------------------------------
   let d_bdbsr013.motprstip = "FROTA"   # Define o prestador como Frota Porto

   if d_bdbsr013.atdprscod  <>  1   then

      open  c_dpaksocor  using  d_bdbsr013.atdprscod
      fetch c_dpaksocor  into   d_bdbsr013.motprsnom,
                                ws.vlrtabflg

      if sqlca.sqlcode = notfound then
         let d_bdbsr013.motprsnom = "NAO CADASTRADO!"
         let d_bdbsr013.motprstip = "OUTROS"
      else
         if sqlca.sqlcode < 0 then
            error "Erro (", sqlca.sqlcode, ") - Nao foi possivel localizar o " ,
                  "prestador. AVISE A INFORMATICA!"
            return
         end if
      end if

      if ws.vlrtabflg = "S" then
         let d_bdbsr013.motprstip = "TABELA"
      else
         let d_bdbsr013.motprstip = "OUTROS"
      end if
   else

      if ws.srrcoddig  is not null   then
         open  c_datksrr  using  ws.srrcoddig
         fetch c_datksrr  into   d_bdbsr013.motprsnom
         close c_datksrr
      end if
   end if

   let ws.achou = 0

   let d_bdbsr013.psqsrvflg = "N"

   if ws.psqcod  =  "M10"   then

      let d_bdbsr013.psqsrvflg = "S"

      declare c_bdbsr013itm   cursor for
         select avlitmcod, avlpsqnot
           from datrpesqaval
          where atdsrvnum = ws.atdsrvnum    and
                atdsrvano = ws.atdsrvano    and
                avlitmcod between 2 and 3

      foreach c_bdbsr013itm  into  d_bdbsr013.avlitmcod,
                                   d_bdbsr013.avlpsqnot

         let ws.achou = 1

         let d_bdbsr013.qtdtmpoti = 0
         let d_bdbsr013.qtdtmpbom = 0
         let d_bdbsr013.qtdtmpreg = 0
         let d_bdbsr013.qtdtmprui = 0
         let d_bdbsr013.qtdtmppes = 0
         let d_bdbsr013.qtdtmpnsi = 0

         let d_bdbsr013.qtdsrvoti = 0
         let d_bdbsr013.qtdsrvbom = 0
         let d_bdbsr013.qtdsrvreg = 0
         let d_bdbsr013.qtdsrvrui = 0
         let d_bdbsr013.qtdsrvpes = 0
         let d_bdbsr013.qtdsrvnsi = 0

         if d_bdbsr013.avlitmcod = 2  then
            if d_bdbsr013.avlpsqnot is null   then
               let d_bdbsr013.qtdtmpnsi = d_bdbsr013.qtdtmpnsi + 1
            else
              if d_bdbsr013.avlpsqnot >= 0   and
                 d_bdbsr013.avlpsqnot <= 2   then
                 let d_bdbsr013.qtdtmppes = d_bdbsr013.qtdtmppes + 1
              else
                if d_bdbsr013.avlpsqnot = 3   or
                   d_bdbsr013.avlpsqnot = 4   then
                   let d_bdbsr013.qtdtmprui = d_bdbsr013.qtdtmprui + 1
                else
                  if d_bdbsr013.avlpsqnot >= 5   and
                     d_bdbsr013.avlpsqnot <= 7   then
                     let d_bdbsr013.qtdtmpreg = d_bdbsr013.qtdtmpreg + 1
                  else
                    if d_bdbsr013.avlpsqnot = 8   or
                       d_bdbsr013.avlpsqnot = 9   then
                       let d_bdbsr013.qtdtmpbom = d_bdbsr013.qtdtmpbom + 1
                    else
                      if d_bdbsr013.avlpsqnot = 10   then
                         let d_bdbsr013.qtdtmpoti = d_bdbsr013.qtdtmpoti + 1
                      else
                         let d_bdbsr013.qtdtmpnsi = d_bdbsr013.qtdtmpnsi + 1
                      end if
                    end if
                  end if
                end if
              end if
            end if
         else
           if d_bdbsr013.avlpsqnot is null then
              let d_bdbsr013.qtdsrvnsi = d_bdbsr013.qtdsrvnsi + 1
           else
             if d_bdbsr013.avlpsqnot >= 0   and
                d_bdbsr013.avlpsqnot <= 2   then
                let d_bdbsr013.qtdsrvpes = d_bdbsr013.qtdsrvpes + 1
             else
               if d_bdbsr013.avlpsqnot = 3   or
                  d_bdbsr013.avlpsqnot = 4   then
                  let d_bdbsr013.qtdsrvrui = d_bdbsr013.qtdsrvrui + 1
               else
                 if d_bdbsr013.avlpsqnot >= 5   and
                    d_bdbsr013.avlpsqnot <= 7   then
                    let d_bdbsr013.qtdsrvreg = d_bdbsr013.qtdsrvreg + 1
                 else
                   if d_bdbsr013.avlpsqnot = 8   or
                      d_bdbsr013.avlpsqnot = 9   then
                      let d_bdbsr013.qtdsrvbom = d_bdbsr013.qtdsrvbom + 1
                   else
                      if d_bdbsr013.avlpsqnot = 10   then
                         let d_bdbsr013.qtdsrvoti = d_bdbsr013.qtdsrvoti + 1
                      else
                         let d_bdbsr013.qtdsrvnsi = d_bdbsr013.qtdsrvnsi + 1
                      end if
                   end if
                 end if
               end if
             end if
           end if
         end if

        output to report rep_psqest(ws.datade, ws.dataate, d_bdbsr013.*)
        initialize d_bdbsr013.psqsrvflg  to null

      end foreach
   end if

   if ws.achou  = 0   then
      let d_bdbsr013.qtdtmpoti = 0
      let d_bdbsr013.qtdtmpbom = 0
      let d_bdbsr013.qtdtmpreg = 0
      let d_bdbsr013.qtdtmprui = 0
      let d_bdbsr013.qtdtmppes = 0
      let d_bdbsr013.qtdtmpnsi = 0

      let d_bdbsr013.qtdsrvoti = 0
      let d_bdbsr013.qtdsrvbom = 0
      let d_bdbsr013.qtdsrvreg = 0
      let d_bdbsr013.qtdsrvrui = 0
      let d_bdbsr013.qtdsrvpes = 0
      let d_bdbsr013.qtdsrvnsi = 0

      output to report rep_psqest(ws.datade, ws.dataate, d_bdbsr013.*)
      initialize d_bdbsr013.psqsrvflg  to null
   end if

end foreach

finish report  rep_psqest
close c_bdbsr013

end function   ###  bdbsr013


#---------------------------------------------------------------------------
 report rep_psqest(ws_datade, ws_dataate, r_bdbsr013)
#---------------------------------------------------------------------------

 define ws_datade     char(10)
 define ws_dataate    char(10)

 define arr_aux       smallint

 define  r_bdbsr013   record
    motprstip         char(06)                    ,
    atdprscod         like datmservico.atdprscod  ,
    motprsnom         char(20)                    ,
    psqsrvflg         char(01)                    ,
    qtdtmpoti         dec (4,0)                   ,
    qtdtmpbom         dec (4,0)                   ,
    qtdtmpreg         dec (4,0)                   ,
    qtdtmprui         dec (4,0)                   ,
    qtdtmppes         dec (4,0)                   ,
    qtdtmpnsi         dec (4,0)                   ,
    qtdsrvoti         dec (4,0)                   ,
    qtdsrvbom         dec (4,0)                   ,
    qtdsrvreg         dec (4,0)                   ,
    qtdsrvrui         dec (4,0)                   ,
    qtdsrvpes         dec (4,0)                   ,
    qtdsrvnsi         dec (4,0)                   ,
    avlitmcod         like datrpesqaval.avlitmcod ,
    avlpsqnot         like datrpesqaval.avlpsqnot
 end record

 #--------------------------------------------------------
 #         Contadores: Totais por Prestador
 #--------------------------------------------------------
 define wsatdtmpoti   integer ,
        wsatdtmpbom   integer ,
        wsatdtmpreg   integer ,
        wsatdtmprui   integer ,
        wsatdtmppes   integer ,
        wsatdtmpnsi   integer

 define wsatdsrvoti   integer ,
        wsatdsrvbom   integer ,
        wsatdsrvreg   integer ,
        wsatdsrvrui   integer ,
        wsatdsrvpes   integer ,
        wsatdsrvnsi   integer

 define wsatdprest    integer ,
        wspsqprest    integer

 define wstmpnotprs   dec (8,2) ,
        wssrvnotprs   dec (8,2)


 #--------------------------------------------------------
 #       Contadores: Totais por Tipo de Prestador
 #--------------------------------------------------------
 define wstiptmpoti   integer ,
        wstiptmpbom   integer ,
        wstiptmpreg   integer ,
        wstiptmprui   integer ,
        wstiptmppes   integer ,
        wstiptmpnsi   integer

 define wstipsrvoti   integer ,
        wstipsrvbom   integer ,
        wstipsrvreg   integer ,
        wstipsrvrui   integer ,
        wstipsrvpes   integer ,
        wstipsrvnsi   integer

 define wsatdtipo     integer ,
        wspsqtipo     integer

 #--------------------------------------------------------
 #             Contadores: Totais Gerais
 #--------------------------------------------------------
 define wsgrltmpoti   integer ,
        wsgrltmpbom   integer ,
        wsgrltmpreg   integer ,
        wsgrltmprui   integer ,
        wsgrltmppes   integer ,
        wsgrltmpnsi   integer

 define wsgrlsrvoti   integer ,
        wsgrlsrvbom   integer ,
        wsgrlsrvreg   integer ,
        wsgrlsrvrui   integer ,
        wsgrlsrvpes   integer ,
        wsgrlsrvnsi   integer

 define wsatdgeral    integer ,
        wspsqgeral    integer

 #--------------------------------------------------------
 #             Contadores - Notas Obtidas
 #--------------------------------------------------------
 define wstmpnottot   integer   ,
        wssrvnottot   integer

 define wstmpnotmed   dec (8,2) ,
        wssrvnotmed   dec (8,2)

 define wstmpnotgrl   dec (8,2) ,
        wssrvnotgrl   dec (8,2)

 define wsatdnotcnt   smallint  ,
        wstipnotcnt   smallint  ,
        wsgrlnotcnt   smallint

 #--------------------------------------------------------
 #             Arrays de Totalizacao por Notas
 #--------------------------------------------------------
 define arr_not       array[11] of record
    quant_tmp         dec (5,0) ,
    quant_srv         dec (5,0) ,
    perc_tmp          dec (7,4) ,
    perc_srv          dec (7,4)
 end record

 define arr_prs       array[11] of record
    quant_tmp         dec (5,0) ,
    quant_srv         dec (5,0) ,
    perc_tmp          dec (7,4) ,
    perc_srv          dec (7,4)
 end record

 define wspercent     dec(7,4)  ,
        wsperctmp     dec(7,4)  ,
        wspercsrv     dec(7,4)

 define wstotdes      char(20)


   output
      left   margin  000
      right  margin  145
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr013.motprstip  ,
             r_bdbsr013.motprsnom  ,
             r_bdbsr013.atdprscod

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS01301 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CENTRO DE CONSULTAS/PESQUISA - SERVICOS CONCLUIDOS"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)

              for arr_aux = 1 to 11
                  let arr_not[arr_aux].quant_tmp = 0
                  let arr_not[arr_aux].quant_srv = 0
                  let arr_not[arr_aux].perc_tmp  = 0
                  let arr_not[arr_aux].perc_srv  = 0
              end for

              let wsgrltmpoti = 0
              let wsgrltmpbom = 0
              let wsgrltmpreg = 0
              let wsgrltmprui = 0
              let wsgrltmppes = 0
              let wsgrltmpnsi = 0

              let wsgrlsrvoti = 0
              let wsgrlsrvbom = 0
              let wsgrlsrvreg = 0
              let wsgrlsrvrui = 0
              let wsgrlsrvpes = 0
              let wsgrlsrvnsi = 0

              let wsgrlnotcnt = 0

              let wsatdgeral  = 0
              let wspsqgeral  = 0
           else
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, END ;"
             print ascii(12)
           end if

           print column 106, "RDBS013-01",
                 column 120, "PAGINA : ", pageno using "##,###,###"
           print column 120, "DATA   : ", today
           print column 034, "ESTATISTICA POR MOTORISTA/PRESTADOR DE ",
                             ws_datade, " A ", ws_dataate,
                 column 120, "HORA   :   ", time
           skip 2 lines

           print column 001, "PRESTADOR: ", r_bdbsr013.motprstip

           print column 047,"----------- NIVEL DE QUALIDADE(TEMPO) ----------",
                 column 098,"--------- NIVEL DE QUALIDADE(SERVICO) ----------"

           print column 001, "CODIGO",
                 column 008, "MOTORISTA/PRESTADOR",
                 column 029, "CONTATO"    ,
                 column 039, "PESQ."      ,
                 column 047, "OTIMO"      ,
                 column 055, "BOM"        ,
                 column 060, "REGULAR"    ,
                 column 069, "RUIM"       ,
                 column 075, "PESSIMO"    ,
                 column 085, "NSI"        ,
                 column 090, "MEDIA"      ,
                 column 098, "OTIMO"      ,
                 column 106, "BOM"        ,
                 column 111, "REGULAR"    ,
                 column 120, "RUIM"       ,
                 column 126, "PESSIMO"    ,
                 column 136, "NSI"        ,
                 column 141, "MEDIA"

           print column 001, ws_traco
           skip 1 line

      before group of r_bdbsr013.motprstip

             skip to top of page

             let wstiptmpoti = 0
             let wstiptmpbom = 0
             let wstiptmpreg = 0
             let wstiptmprui = 0
             let wstiptmppes = 0
             let wstiptmpnsi = 0

             let wstipsrvoti = 0
             let wstipsrvbom = 0
             let wstipsrvreg = 0
             let wstipsrvrui = 0
             let wstipsrvpes = 0
             let wstipsrvnsi = 0

             let wstipnotcnt = 0

             let wsatdtipo   = 0
             let wspsqtipo   = 0

             for arr_aux = 1 to 11
                 let arr_prs[arr_aux].quant_tmp = 0
                 let arr_prs[arr_aux].quant_srv = 0
                 let arr_prs[arr_aux].perc_tmp  = 0
                 let arr_prs[arr_aux].perc_srv  = 0
             end for

      after  group of r_bdbsr013.motprstip

             let wsgrltmpoti = wsgrltmpoti + wstiptmpoti
             let wsgrltmpbom = wsgrltmpbom + wstiptmpbom
             let wsgrltmpreg = wsgrltmpreg + wstiptmpreg
             let wsgrltmprui = wsgrltmprui + wstiptmprui
             let wsgrltmppes = wsgrltmppes + wstiptmppes
             let wsgrltmpnsi = wsgrltmpnsi + wstiptmpnsi

             let wsgrlsrvoti = wsgrlsrvoti + wstipsrvoti
             let wsgrlsrvbom = wsgrlsrvbom + wstipsrvbom
             let wsgrlsrvreg = wsgrlsrvreg + wstipsrvreg
             let wsgrlsrvrui = wsgrlsrvrui + wstipsrvrui
             let wsgrlsrvpes = wsgrlsrvpes + wstipsrvpes
             let wsgrlsrvnsi = wsgrlsrvnsi + wstipsrvnsi

             let wsgrlnotcnt = wsgrlnotcnt + wstipnotcnt

             let wsatdgeral  = wsatdgeral  + wsatdtipo
             let wspsqgeral  = wspsqgeral  + wspsqtipo

             if r_bdbsr013.motprstip = "FROTA"      then
                let wstotdes = "TOTAL MOTORISTAS "
             else
                let wstotdes = "TOTAL PRESTADORES "
             end if

             skip 3 lines
             print column 001, ws_traco
             skip 1 line

             print column 001, wstotdes                       ,
                   column 030, wsatdtipo       using "#####&" ,
                   column 038, wspsqtipo       using "#####&" ,
                   column 048, wstiptmpoti     using "###&"   ,
                   column 054, wstiptmpbom     using "###&"   ,
                   column 063, wstiptmpreg     using "###&"   ,
                   column 069, wstiptmprui     using "###&"   ,
                   column 078, wstiptmppes     using "###&"   ,
                   column 084, wstiptmpnsi     using "###&"   ,
                   column 099, wstipsrvoti     using "###&"   ,
                   column 105, wstipsrvbom     using "###&"   ,
                   column 114, wstipsrvreg     using "###&"   ,
                   column 120, wstipsrvrui     using "###&"   ,
                   column 129, wstipsrvpes     using "###&"   ,
                   column 135, wstipsrvnsi     using "###&"

             print column 001, ws_traco
             skip 1 line

             let wspercent = 00.00
             let wspercent = wspsqtipo / wsatdtipo * 100
             print column 039, wspercent       using "#&&.&","%";

             let wsperctmp = 00.00
             let wsperctmp = wstiptmpoti / wspsqtipo * 100
             print column 047, wsperctmp       using "##&.&","%";

             let wsperctmp = 00.00
             let wsperctmp = wstiptmpbom / wspsqtipo * 100
             print column 053, wsperctmp       using "##&.&","%";

             let wsperctmp = 00.00
             let wsperctmp = wstiptmpreg / wspsqtipo * 100
             print column 062, wsperctmp       using "##&.&","%";

             let wsperctmp = 00.00
             let wsperctmp = wstiptmprui / wspsqtipo * 100
             print column 068, wsperctmp       using "##&.&","%";

             let wsperctmp = 00.00
             let wsperctmp = wstiptmppes / wspsqtipo * 100
             print column 077, wsperctmp       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstiptmpnsi / wspsqtipo * 100
             print column 083, wspercsrv       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstipsrvoti / wspsqtipo * 100
             print column 098, wspercsrv       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstipsrvbom / wspsqtipo * 100
             print column 104, wspercsrv       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstipsrvreg / wspsqtipo * 100
             print column 113, wspercsrv       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstipsrvrui / wspsqtipo * 100
             print column 119, wspercsrv       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstipsrvpes / wspsqtipo * 100
             print column 128, wspercsrv       using "##&.&","%";

             let wspercsrv = 00.00
             let wspercsrv = wstipsrvnsi / wspsqtipo * 100
             print column 134, wspercsrv       using "##&.&","%"

           skip to top of page
           skip 8 lines
           print column 035, " ESCALA DE NOTAS - TEMPO  " ,
                 column 070, "ESCALA DE NOTAS - SERVICO"
           print column 035, "==========================" ,
                 column 070, "=========================="
           skip 1 line
           let wstmpnotprs = 0
           let wssrvnotprs = 0

           for arr_aux = 1 to 11
               let wstmpnotprs = ( wstmpnotprs + ( (arr_aux - 1) * arr_prs[arr_aux].quant_tmp) )
               let wssrvnotprs = ( wssrvnotprs + ( (arr_aux - 1) * arr_prs[arr_aux].quant_srv) )
               let arr_prs[arr_aux].perc_tmp = arr_prs[arr_aux].quant_tmp / wspsqtipo  * 100
               let arr_prs[arr_aux].perc_srv = arr_prs[arr_aux].quant_srv / wspsqtipo  * 100
               print column 035, "NOTA ", arr_aux - 1 using "#&"  , " - " ,
                     arr_prs[arr_aux].quant_tmp   using  "####&"  , " ("  ,
                     arr_prs[arr_aux].perc_tmp    using  "##&.&&" , "% )" ,
                     column 070, "NOTA ", arr_aux - 1 using "#&"  , " - " ,
                     arr_prs[arr_aux].quant_srv   using  "####&"  , " ("  ,
                     arr_prs[arr_aux].perc_srv    using  "##&.&&" , "% )"
           end for

           let wsperctmp = 0
           let wspercsrv = 0
           let wsperctmp = wstiptmpnsi / wspsqtipo * 100
           let wspercsrv = wstipsrvnsi / wspsqtipo * 100
           print column 035, "NAO INF - ", wstiptmpnsi using "####&" , " ("  ,
                                           wsperctmp   using "##&.&&", "% )" ,
                 column 070, "NAO INF - ", wstipsrvnsi using "####&" , " ("  ,
                                           wspercsrv   using "##&.&&", "% )"
           print column 035, "--------------------------" ,
                 column 070, "--------------------------"
           let wstmpnotprs = wstmpnotprs/wstipnotcnt
           let wssrvnotprs = wssrvnotprs/wstipnotcnt
           print column 035, "MEDIA GERAL = ", wstmpnotprs using "#&.&&" ,
                 column 070, "MEDIA GERAL = ", wssrvnotprs using "#&.&&"

      before group of r_bdbsr013.motprsnom

             let wsatdtmpoti = 0
             let wsatdtmpbom = 0
             let wsatdtmpreg = 0
             let wsatdtmprui = 0
             let wsatdtmppes = 0
             let wsatdtmpnsi = 0

             let wsatdsrvoti = 0
             let wsatdsrvbom = 0
             let wsatdsrvreg = 0
             let wsatdsrvrui = 0
             let wsatdsrvpes = 0
             let wsatdsrvnsi = 0

             let wsatdprest  = 0
             let wspsqprest  = 0

             let wsatdnotcnt = 0

             let wstmpnotmed = 0
             let wssrvnotmed = 0
             let wstmpnottot = 0
             let wssrvnottot = 0

      after  group of r_bdbsr013.motprsnom

             let   wstmpnotmed = wstmpnottot / wsatdnotcnt
             let   wssrvnotmed = wssrvnottot / wsatdnotcnt

             need  3 lines
             print column 001, r_bdbsr013.atdprscod using "###&&&" ,
                   column 008, r_bdbsr013.motprsnom                ,
                   column 030, wsatdprest           using "#####&" ,
                   column 038, wspsqprest           using "#####&" ,
                   column 048, wsatdtmpoti          using "###&"   ,
                   column 054, wsatdtmpbom          using "###&"   ,
                   column 063, wsatdtmpreg          using "###&"   ,
                   column 069, wsatdtmprui          using "###&"   ,
                   column 078, wsatdtmppes          using "###&"   ,
                   column 084, wsatdtmpnsi          using "###&"   ,
                   column 090, wstmpnotmed          using "#&.&&"  ,
                   column 099, wsatdsrvoti          using "###&"   ,
                   column 105, wsatdsrvbom          using "###&"   ,
                   column 114, wsatdsrvreg          using "###&"   ,
                   column 120, wsatdsrvrui          using "###&"   ,
                   column 129, wsatdsrvpes          using "###&"   ,
                   column 135, wsatdsrvnsi          using "###&"   ,
                   column 141, wssrvnotmed          using "#&.&&"

             print column 001, ws_traco
             skip 1 line

             let wstiptmpoti = wstiptmpoti + wsatdtmpoti
             let wstiptmpbom = wstiptmpbom + wsatdtmpbom
             let wstiptmpreg = wstiptmpreg + wsatdtmpreg
             let wstiptmprui = wstiptmprui + wsatdtmprui
             let wstiptmppes = wstiptmppes + wsatdtmppes
             let wstiptmpnsi = wstiptmpnsi + wsatdtmpnsi

             let wstipsrvoti = wstipsrvoti + wsatdsrvoti
             let wstipsrvbom = wstipsrvbom + wsatdsrvbom
             let wstipsrvreg = wstipsrvreg + wsatdsrvreg
             let wstipsrvrui = wstipsrvrui + wsatdsrvrui
             let wstipsrvpes = wstipsrvpes + wsatdsrvpes
             let wstipsrvnsi = wstipsrvnsi + wsatdsrvnsi

             let wstipnotcnt = wstipnotcnt + wsatdnotcnt

             let wsatdtipo   = wsatdtipo   + wsatdprest
             let wspsqtipo   = wspsqtipo   + wspsqprest

      on every row

             let wsatdtmpoti = wsatdtmpoti + r_bdbsr013.qtdtmpoti
             let wsatdtmpbom = wsatdtmpbom + r_bdbsr013.qtdtmpbom
             let wsatdtmpreg = wsatdtmpreg + r_bdbsr013.qtdtmpreg
             let wsatdtmprui = wsatdtmprui + r_bdbsr013.qtdtmprui
             let wsatdtmppes = wsatdtmppes + r_bdbsr013.qtdtmppes
             let wsatdtmpnsi = wsatdtmpnsi + r_bdbsr013.qtdtmpnsi

             let wsatdsrvoti = wsatdsrvoti + r_bdbsr013.qtdsrvoti
             let wsatdsrvbom = wsatdsrvbom + r_bdbsr013.qtdsrvbom
             let wsatdsrvreg = wsatdsrvreg + r_bdbsr013.qtdsrvreg
             let wsatdsrvrui = wsatdsrvrui + r_bdbsr013.qtdsrvrui
             let wsatdsrvpes = wsatdsrvpes + r_bdbsr013.qtdsrvpes
             let wsatdsrvnsi = wsatdsrvnsi + r_bdbsr013.qtdsrvnsi

             if r_bdbsr013.psqsrvflg is null then
                if r_bdbsr013.avlpsqnot is not null or
                   r_bdbsr013.avlpsqnot <> " "      then
                   let arr_aux = r_bdbsr013.avlpsqnot
                   if r_bdbsr013.avlitmcod = 2 then
                      let arr_not[arr_aux + 1].quant_tmp =
                          arr_not[arr_aux + 1].quant_tmp + 1
                      let arr_prs[arr_aux + 1].quant_tmp =
                          arr_prs[arr_aux + 1].quant_tmp + 1
                      let wstmpnottot = wstmpnottot + r_bdbsr013.avlpsqnot
                   else
                      let arr_not[arr_aux + 1].quant_srv =
                          arr_not[arr_aux + 1].quant_srv + 1
                      let arr_prs[arr_aux + 1].quant_srv =
                          arr_prs[arr_aux + 1].quant_srv + 1
                      let wssrvnottot = wssrvnottot + r_bdbsr013.avlpsqnot
		   end if
                end if
             else
                if r_bdbsr013.psqsrvflg = "S" then
                   let wspsqprest = wspsqprest + 1
                   let wsatdprest = wsatdprest + 1
                   if r_bdbsr013.avlpsqnot is not null or
                      r_bdbsr013.avlpsqnot <> " "      then
                      let wsatdnotcnt = wsatdnotcnt + 1
                      let arr_aux = r_bdbsr013.avlpsqnot
                      if r_bdbsr013.avlitmcod = 2 then
                         let arr_not[arr_aux + 1].quant_tmp =
                             arr_not[arr_aux + 1].quant_tmp + 1
                         let arr_prs[arr_aux + 1].quant_tmp =
                             arr_prs[arr_aux + 1].quant_tmp + 1
                         let wstmpnottot = wstmpnottot + r_bdbsr013.avlpsqnot
                      else
                         let arr_not[arr_aux + 1].quant_srv =
                             arr_not[arr_aux + 1].quant_srv + 1
                         let arr_prs[arr_aux + 1].quant_srv =
                             arr_prs[arr_aux + 1].quant_srv + 1
                         let wssrvnottot = wssrvnottot + r_bdbsr013.avlpsqnot
	              end if
                   end if
                else
                   if r_bdbsr013.psqsrvflg = "N" then
                      let wsatdprest = wsatdprest + 1
                   end if
                end if
             end if

      on   last  row

           skip 3 lines
           print column 001, ws_traco
           skip 1 line

           print column 001, "TOTAL GERAL"                 ,
                 column 030, wsatdgeral      using "#####&",
                 column 038, wspsqgeral      using "#####&",
                 column 048, wsgrltmpoti     using "###&"  ,
                 column 054, wsgrltmpbom     using "###&"  ,
                 column 063, wsgrltmpreg     using "###&"  ,
                 column 069, wsgrltmprui     using "###&"  ,
                 column 078, wsgrltmppes     using "###&"  ,
                 column 084, wsgrltmpnsi     using "###&"  ,
                 column 099, wsgrlsrvoti     using "###&"  ,
                 column 105, wsgrlsrvbom     using "###&"  ,
                 column 114, wsgrlsrvreg     using "###&"  ,
                 column 120, wsgrlsrvrui     using "###&"  ,
                 column 129, wsgrlsrvpes     using "###&"  ,
                 column 135, wsgrlsrvnsi     using "###&"

           print column 001, ws_traco
           skip 1 line

           let wspercent = 00.00
           let wspercent = wspsqgeral / wsatdgeral
           let wspercent = wspercent * 100
           print column 039, wspercent       using "#&&.&","%";

           let wsperctmp = 00.00
           let wsperctmp = wsgrltmpoti / wspsqgeral * 100
           print column 047, wsperctmp       using "##&.&","%";

           let wsperctmp = 00.00
           let wsperctmp = wsgrltmpbom / wspsqgeral * 100
           print column 053, wsperctmp       using "##&.&","%";

           let wsperctmp = 00.00
           let wsperctmp = wsgrltmpreg / wspsqgeral * 100
           print column 062, wsperctmp       using "##&.&","%";

           let wsperctmp = 00.00
           let wsperctmp = wsgrltmprui / wspsqgeral * 100
           print column 068, wsperctmp       using "##&.&","%";

           let wsperctmp = 00.00
           let wsperctmp = wsgrltmppes / wspsqgeral * 100
           print column 077, wsperctmp       using "##&.&","%";

           let wsperctmp = 00.00
           let wsperctmp = wsgrltmpnsi / wspsqgeral * 100
           print column 083, wsperctmp       using "##&.&","%";

           let wspercsrv = 00.00
           let wspercsrv = wsgrlsrvoti / wspsqgeral * 100
           print column 098, wspercsrv       using "##&.&","%";

           let wspercsrv = 00.00
           let wspercsrv = wsgrlsrvbom / wspsqgeral * 100
           print column 104, wspercsrv       using "##&.&","%";

           let wspercsrv = 00.00
           let wspercsrv = wsgrlsrvreg / wspsqgeral * 100
           print column 113, wspercsrv       using "##&.&","%";

           let wspercsrv = 00.00
           let wspercsrv = wsgrlsrvrui / wspsqgeral * 100
           print column 119, wspercsrv       using "##&.&","%";

           let wspercsrv = 00.00
           let wspercsrv = wsgrlsrvpes / wspsqgeral * 100
           print column 128, wspercsrv       using "##&.&","%";

           let wspercsrv = 00.00
           let wspercsrv = wsgrlsrvnsi / wspsqgeral * 100
           print column 134, wspercsrv       using "##&.&","%"

           let r_bdbsr013.motprstip = "TOTAL"
           skip to top of page
           skip 8 lines
           print column 035, " ESCALA DE NOTAS - TEMPO  " ,
                 column 070, "ESCALA DE NOTAS - SERVICO "
           print column 035, "==========================" ,
                 column 070, "=========================="
           skip 1 line
           let wstmpnotgrl = 0
           let wssrvnotgrl = 0

           for arr_aux = 1 to 11
               let wstmpnotgrl = ( wstmpnotgrl + ( (arr_aux - 1) * arr_not[arr_aux].quant_tmp) )
               let wssrvnotgrl = ( wssrvnotgrl + ( (arr_aux - 1) * arr_not[arr_aux].quant_srv) )
               let arr_not[arr_aux].perc_tmp = arr_not[arr_aux].quant_tmp / wspsqgeral * 100
               let arr_not[arr_aux].perc_srv = arr_not[arr_aux].quant_srv / wspsqgeral * 100
               print column 035, "NOTA ", arr_aux - 1 using "#&"  , " - " ,
                     arr_not[arr_aux].quant_tmp   using  "####&"  , " ("  ,
                     arr_not[arr_aux].perc_tmp    using  "##&.&&" , "% )" ,
                     column 070, "NOTA ", arr_aux - 1 using "#&"  , " - " ,
                     arr_not[arr_aux].quant_srv   using  "####&"  , " ("  ,
                     arr_not[arr_aux].perc_srv    using  "##&.&&" , "% )"
           end for

           print column 035, "NAO INF - ", wsgrltmpnsi using "####&" , " ("  ,
                                           wsperctmp   using "##&.&&", "% )" ,
                 column 070, "NAO INF - ", wsgrlsrvnsi using "####&" , " ("  ,
                                           wspercsrv   using "##&.&&", "% )"
           print column 035, "--------------------------" ,
                 column 070, "--------------------------"
           let wstmpnotgrl = wstmpnotgrl / wsgrlnotcnt
           let wssrvnotgrl = wssrvnotgrl / wsgrlnotcnt
           print column 035, "MEDIA GERAL = ", wstmpnotgrl using "#&.&&" ,
                 column 070, "MEDIA GERAL = ", wssrvnotgrl using "#&.&&"
           print "$FIMREL$"

end report
