############################################################################
# Nome do Modulo: BDATR014                                        Marcelo  #
#                                                                 Gilberto #
# Estatistica dos servicos por atendente                          Mar/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas #
#                                       para verificacao do servico.       #
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance            #
#--------------------------------------------------------------------------#

 database porto

 define ws_traco      char(132)
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd

 main
    call fun_dba_abre_banco('CT24HS')  
    call bdatr014()
 end main

#---------------------------------------------------------------
 function  bdatr014()
#---------------------------------------------------------------

   define  d_bdatr014   record
      funmat            like datmservico.funmat     ,
      funnom            like isskfunc.funnom        ,
      psqsrvflg         char(01)                    ,
      qtdcenoti         dec(04,0)                   ,
      qtdcenbom         dec(04,0)                   ,
      qtdcenreg         dec(04,0)                   ,
      qtdcenrui         dec(04,0)                   ,
      qtdcenpes         dec(04,0)                   ,
      qtdcennsi         dec(04,0)                   ,
      avlpsqnot         like datrpesqaval.avlpsqnot
   end record

   define ws            record
      achou             dec(1,0)                    ,
      datax             char(10)                    ,
      datade            date                        ,
      dataate           date                        ,
      atdetpcod         like datmsrvacp.atdetpcod   ,
      atdsrvnum         like datmservico.atdsrvnum  ,
      atdsrvano         like datmservico.atdsrvano  ,
      atdprscod         like datmservico.atdprscod  ,
      avlitmcod         like datrpesqaval.avlitmcod ,
      psqcod            like datmpesquisa.psqcod    ,
      dirfisnom         like ibpkdirlog.dirfisnom   ,
      pathrel01         char (60)
   end record

   define sql_select    char(250)


let ws_traco  = "____________________________________________________________________________________________________________"

initialize d_bdatr014.*  to null
initialize ws.*          to null

 #---------------------------------------------------------------
 # MONTA COMANDO SQL - PREPARE
 #---------------------------------------------------------------
 let sql_select = "select funnom           " ,
                  "  from isskfunc         " ,
                  " where succod  =  01 and" ,
                  "       funmat  =  ?     "

 prepare sql_comando from sql_select
 declare c_funnom cursor for sql_comando

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
 # MONTA DATA (PERIODO MENSAL)
 #---------------------------------------------------------------
 let ws.datax   = today
 let ws.datax   = "07/12/1998"

 let ws.datax   = "01","/",ws.datax[4,5],"/",ws.datax[7,10]
 let ws.dataate = ws.datax
 let ws.dataate = ws.dataate - 1 units day

 let ws.datax   = ws.dataate
 let ws.datax   = "01","/",ws.datax[4,5],"/",ws.datax[7,10]
 let ws.datade  = ws.datax

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT01401"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDAT01401")
      returning  ws_cctcod,
		 ws_relviaqtd

 #---------------------------------------------------------------------
 # Monta cursor contendo todos os servicos concluidos dentro do periodo
 #---------------------------------------------------------------------
 declare c_bdatr014   cursor for
    select datmpesquisa.atdsrvnum,
           datmpesquisa.atdsrvano,
           datmpesquisa.psqcod,
           datmservico.funmat
      from datmpesquisa, datmservico
     where datmpesquisa.caddat    between  ws.datade and ws.dataate

       and datmservico.atdsrvnum  = datmpesquisa.atdsrvnum
       and datmservico.atdsrvano  = datmpesquisa.atdsrvano
  #    and datmservico.atdfnlflg  = "C"
       and datmservico.atdfnlflg  = "S"

 start report  rep_psqest  to  ws.pathrel01

 foreach c_bdatr014  into  ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.psqcod,
                           d_bdatr014.funmat

#------------------------------------------------------------
# Verifica etapa dos servicos
#------------------------------------------------------------
   open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                            ws.atdsrvnum, ws.atdsrvano
   fetch c_datmsrvacp into  ws.atdetpcod
   close c_datmsrvacp

   if ws.atdetpcod <> 4      then   # somente servicos etapa concluida
      continue foreach
   end if

   let d_bdatr014.psqsrvflg = "N"
   if ws.psqcod = "M10"    then
      let d_bdatr014.psqsrvflg = "S"
   end if

   open  c_funnom using d_bdatr014.funmat
   fetch c_funnom into  d_bdatr014.funnom
     if sqlca.sqlcode <> 0 then
        let d_bdatr014.funnom = "NAO CADASTRADO!"
     end if
   close c_funnom

   let d_bdatr014.funnom = upshift(d_bdatr014.funnom)

   let ws.achou = 0

   if ws.psqcod = "M10"   then
      declare c_bdatr014itm   cursor for
         select avlitmcod, avlpsqnot
           from datrpesqaval
          where atdsrvnum = ws.atdsrvnum    and
                atdsrvano = ws.atdsrvano    and
                avlitmcod = 1

      foreach c_bdatr014itm  into  ws.avlitmcod ,
                                   d_bdatr014.avlpsqnot

         let d_bdatr014.qtdcenoti = 0
         let d_bdatr014.qtdcenbom = 0
         let d_bdatr014.qtdcenreg = 0
         let d_bdatr014.qtdcenrui = 0
         let d_bdatr014.qtdcenpes = 0
         let d_bdatr014.qtdcennsi = 0

         let ws.achou = 1

         if d_bdatr014.avlpsqnot is null then
            let d_bdatr014.qtdcennsi = d_bdatr014.qtdcennsi + 1
         else
           if d_bdatr014.avlpsqnot >= 0   and
              d_bdatr014.avlpsqnot <= 2   then
              let d_bdatr014.qtdcenpes = d_bdatr014.qtdcenpes + 1
           else
             if d_bdatr014.avlpsqnot = 3   or
                d_bdatr014.avlpsqnot = 4   then
                let d_bdatr014.qtdcenrui = d_bdatr014.qtdcenrui + 1
             else
               if d_bdatr014.avlpsqnot >= 5   and
                  d_bdatr014.avlpsqnot <= 7   then
                  let d_bdatr014.qtdcenreg = d_bdatr014.qtdcenreg + 1
               else
                 if d_bdatr014.avlpsqnot = 8   or
                    d_bdatr014.avlpsqnot = 9   then
                    let d_bdatr014.qtdcenbom = d_bdatr014.qtdcenbom + 1
                else
                  if d_bdatr014.avlpsqnot = 10   then
                     let d_bdatr014.qtdcenoti = d_bdatr014.qtdcenoti + 1
                  else
                     let d_bdatr014.qtdcennsi = d_bdatr014.qtdcennsi + 1
                  end if
                end if
               end if
             end if
           end if
         end if

         output to report rep_psqest(ws.datade, ws.dataate, d_bdatr014.*)
         initialize d_bdatr014.psqsrvflg  to null

      end foreach
   end if

   if ws.achou  = 0   then
      let d_bdatr014.qtdcenoti = 0
      let d_bdatr014.qtdcenbom = 0
      let d_bdatr014.qtdcenreg = 0
      let d_bdatr014.qtdcenrui = 0
      let d_bdatr014.qtdcenpes = 0
      let d_bdatr014.qtdcennsi = 0

      output to report rep_psqest(ws.datade, ws.dataate, d_bdatr014.*)

      initialize d_bdatr014.psqsrvflg  to null
   end if

end foreach

finish report  rep_psqest
close c_bdatr014

end function   ##-- bdatr014


#---------------------------------------------------------------------------
report rep_psqest(ws_datade, ws_dataate, r_bdatr014)
#---------------------------------------------------------------------------
   define  ws_datade    char(10)
   define  ws_dataate   char(10)

   define  arr_aux      smallint

   define  r_bdatr014   record
      funmat            like datmservico.funmat   ,
      funnom            like isskfunc.funnom      ,
      psqsrvflg         char(01)                  ,
      qtdcenoti         dec(04,0)                 ,
      qtdcenbom         dec(04,0)                 ,
      qtdcenreg         dec(04,0)                 ,
      qtdcenrui         dec(04,0)                 ,
      qtdcenpes         dec(04,0)                 ,
      qtdcennsi         dec(04,0)                 ,
      avlpsqnot         like datrpesqaval.avlpsqnot
   end record

   define  wsatdcenoti  integer ,
           wsatdcenbom  integer ,
           wsatdcenreg  integer ,
           wsatdcenrui  integer ,
           wsatdcenpes  integer ,
           wsatdcennsi  integer

   define  wsgrlcenoti  integer ,
           wsgrlcenbom  integer ,
           wsgrlcenreg  integer ,
           wsgrlcenrui  integer ,
           wsgrlcenpes  integer ,
           wsgrlcennsi  integer

   define  wsatdtotal   integer ,
           wspsqtotal   integer

   define  wsatdgeral   integer ,
           wspsqgeral   integer

   define  wsnotmedia   dec(8,2) ,
           wsnotgeral   dec(8,2) ,
           wsnottotal   integer  ,
           wsnotcont    integer

   define  wspercent    dec(7,4)

   define arr_not array[11] of record
      quantidade  dec(5,0) ,
      percent     dec(7,4)
   end record

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdatr014.funnom ,
             r_bdatr014.funmat

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DAT01401 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CENTRO DE CONSULTAS/PESQUISA - SERVICOS CONCLUIDOS"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)

              for arr_aux = 1 to 11
                  let arr_not[arr_aux].quantidade = 0
                  let arr_not[arr_aux].percent    = 0
              end for

           else
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, END ;"
             print ascii(12)
           end if
           print column 099, "RDAT014-01",
                 column 113, "PAGINA : ", pageno using "##,###,###"
           print column 113, "DATA   : ", today
           print column 042, "ESTATISTICA POR ATENDENTE DE ",
                             ws_datade, " A ", ws_dataate,
                 column 113, "HORA   :   ", time
           skip 2 lines

           print column 051,"------- NIVEL DE QUALIDADE(ATENDIMENTO) -------"

           print column 001, "ATENDENTE" ,
                 column 032, "CONTATO"   ,
                 column 042, "PESQ."     ,
                 column 051, "OTIMO"     ,
                 column 061, "BOM"       ,
                 column 066, "REGULAR"   ,
                 column 077, "RUIM"      ,
                 column 083, "PESSIMO"   ,
                 column 095, "NSI"       ,
                 column 102, "MEDIA"

           print column 001, ws_traco
           skip 1 line

      before group of r_bdatr014.funnom

           let wsatdcenoti = 0
           let wsatdcenbom = 0
           let wsatdcenreg = 0
           let wsatdcenrui = 0
           let wsatdcenpes = 0
           let wsatdcennsi = 0

           let wsatdtotal  = 0
           let wspsqtotal  = 0

           let wsnottotal  = 0
           let wsnotmedia  = 0
           let wsnotcont   = 0

      after  group of r_bdatr014.funnom

           let wsnotmedia   = wsnottotal / wsnotcont

           print column 001, r_bdatr014.funmat using "###&&&", " - ",
                             r_bdatr014.funnom             ,
                 column 033, wsatdtotal        using "#####&",
                 column 041, wspsqtotal        using "#####&",
                 column 052, wsatdcenoti       using "###&"  ,
                 column 060, wsatdcenbom       using "###&"  ,
                 column 069, wsatdcenreg       using "###&"  ,
                 column 077, wsatdcenrui       using "###&"  ,
                 column 086, wsatdcenpes       using "###&"  ,
                 column 094, wsatdcennsi       using "###&"  ,
                 column 102, wsnotmedia        using "#&.&&"

           print column 001, ws_traco
           skip 1 line

           let wsatdgeral  = wsatdgeral  + wsatdtotal
           let wspsqgeral  = wspsqgeral  + wspsqtotal

           let wsgrlcenoti = wsgrlcenoti + wsatdcenoti
           let wsgrlcenbom = wsgrlcenbom + wsatdcenbom
           let wsgrlcenreg = wsgrlcenreg + wsatdcenreg
           let wsgrlcenrui = wsgrlcenrui + wsatdcenrui
           let wsgrlcenpes = wsgrlcenpes + wsatdcenpes
           let wsgrlcennsi = wsgrlcennsi + wsatdcennsi

      on every row

           let wsatdcenoti = wsatdcenoti + r_bdatr014.qtdcenoti
           let wsatdcenbom = wsatdcenbom + r_bdatr014.qtdcenbom
           let wsatdcenreg = wsatdcenreg + r_bdatr014.qtdcenreg
           let wsatdcenrui = wsatdcenrui + r_bdatr014.qtdcenrui
           let wsatdcenpes = wsatdcenpes + r_bdatr014.qtdcenpes
           let wsatdcennsi = wsatdcennsi + r_bdatr014.qtdcennsi

           if r_bdatr014.psqsrvflg = "S"   then
              let wspsqtotal = wspsqtotal + 1
              let wsatdtotal = wsatdtotal + 1

              if r_bdatr014.avlpsqnot is not null or
                 r_bdatr014.avlpsqnot <> " "      then
                 let arr_aux = r_bdatr014.avlpsqnot
                 let arr_not[arr_aux + 1].quantidade =
                     arr_not[arr_aux + 1].quantidade + 1
                 let wsnotcont = wsnotcont + 1
                 let wsnottotal = wsnottotal + r_bdatr014.avlpsqnot
              end if
           else
              if r_bdatr014.psqsrvflg = "N" then
                 let wsatdtotal = wsatdtotal + 1
              end if
           end if

      on last  row
           skip 2 lines
           print column 001, ws_traco
           skip 1 line

           print column 001, "TOTAL GERAL"                 ,
                 column 033, wsatdgeral      using "#####&",
                 column 041, wspsqgeral      using "#####&",
                 column 052, wsgrlcenoti     using "###&"  ,
                 column 060, wsgrlcenbom     using "###&"  ,
                 column 069, wsgrlcenreg     using "###&"  ,
                 column 077, wsgrlcenrui     using "###&"  ,
                 column 086, wsgrlcenpes     using "###&"  ,
                 column 094, wsgrlcennsi     using "###&"  ,
                 column 102, wsnotgeral      using "#&.&&"

           print column 001, ws_traco
           skip 1 line

           let wspercent = 00.00
           let wspercent = wspsqgeral / wsatdgeral
           let wspercent = wspercent * 100
           print column 041, wspercent       using "#&&.&&","%";

           let wspercent = 00.00
           let wspercent = wsgrlcenoti / wspsqgeral
           let wspercent = wspercent * 100
           print column 050, wspercent       using "##&.&&","%";

           let wspercent = 00.00
           let wspercent = wsgrlcenbom / wspsqgeral
           let wspercent = wspercent * 100
           print column 058, wspercent       using "##&.&&","%";

           let wspercent = 00.00
           let wspercent = wsgrlcenreg / wspsqgeral
           let wspercent = wspercent * 100
           print column 067, wspercent       using "##&.&&","%";

           let wspercent = 00.00
           let wspercent = wsgrlcenrui / wspsqgeral
           let wspercent = wspercent * 100
           print column 075, wspercent       using "##&.&&","%";

           let wspercent = 00.00
           let wspercent = wsgrlcenpes / wspsqgeral
           let wspercent = wspercent * 100
           print column 084, wspercent       using "##&.&&","%";

           let wspercent = 00.00
           let wspercent = wsgrlcennsi / wspsqgeral
           let wspercent = wspercent * 100
           print column 092, wspercent       using "##&.&&","%"

           skip to top of page
           skip 8 lines

           print column 040, "     ESCALA DE NOTAS      "
           print column 040, "=========================="
           skip 1 line
           let wsnotgeral = 0
           for arr_aux = 1 to 11
               let wsnotgeral = ( wsnotgeral + ( (arr_aux - 1) * arr_not[arr_aux].quantidade) )
               let arr_not[arr_aux].percent = arr_not[arr_aux].quantidade / wspsqgeral * 100
               print column 040, "NOTA ", arr_aux - 1 using "#&"  , " - " ,
                     arr_not[arr_aux].quantidade  using  "####&"  , " ("  ,
                     arr_not[arr_aux].percent     using  "##&.&&" , "% )"
           end for
           print column 040, "NAO INF - ", wsgrlcennsi using "####&" , " (" ,
                                           wspercenT   using "##&.&&", "% )"
           print column 040, "--------------------------"
           let wsnotgeral = wsnotgeral / wspsqgeral
           print column 040, "MEDIA GERAL = ", wsnotgeral using "#&.&&"
           print "$FIMREL$"

end report

