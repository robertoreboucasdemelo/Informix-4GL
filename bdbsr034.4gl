#############################################################################
# Nome do Modulo: BDBSR034                                         Marcelo  #
#                                                                  Gilberto #
# Relatorios de controle da frota Porto Seguro                     Jun/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 10/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 30/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 14/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
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
# 13/08/2009 Sergio Burini      PSI244236 Inclusão do Sub-Dairro              #
###############################################################################

 database porto

 define wsgtraco       char(132)
 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd
 define ws_cctcod03    like igbrrelcct.cctcod
 define ws_relviaqtd03 like igbrrelcct.relviaqtd
 define m_path         char(100) 
 
 main
    
    call fun_dba_abre_banco("CT24HS") 

    let m_path = f_path("DBS","LOG")      
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr034.log"

    call startlog(m_path)
    call bdbsr034()
 end main

#---------------------------------------------------------------
 function bdbsr034()
#---------------------------------------------------------------

 define d_bdbsr034    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddatprg         like datmservico.atddatprg,
    atdprscod         like datmservico.atdprscod,
    ufdcod            like datmlcl.ufdcod,
    cidnom            char (20),
    brrnom         char (20),
    srrcoddig         like datmservico.srrcoddig,
    atdmotnom         like datmservico.atdmotnom,
    atdcstvlr         like datmservico.atdcstvlr,
    atdvclsgl         like datmservico.atdvclsgl,
    totkmt            like datmtrajeto.trjorgkmt,
    tothor            char (06),
    totmin            integer
 end record

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod,
    atdsrvorg         like datmservico.atdsrvorg,
    atdfnlflg         like datmservico.atdfnlflg,
    socvclcod         like datmservico.socvclcod,
    data_aux          char (10),
    data_de           date,
    data_ate          date,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02         char (60),
    pathrel03         char (60)
 end record

 define sql_comando   char (250)


 initialize d_bdbsr034.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# Define o periodo mensal
#---------------------------------------------------------------
 let ws.data_aux = arg_val(1)

 if ws.data_aux is null       or
    ws.data_aux =  "  "       then
    let ws.data_aux = today
 else
    if ws.data_aux >= today      or
       length(ws.data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws.data_aux = "01","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_ate = ws.data_aux
 let ws.data_ate = ws.data_ate - 1 units day

 let ws.data_aux = ws.data_ate
 let ws.data_aux = "01","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_de  = ws.data_aux

 let wsgtraco  = "------------------------------------------------------------------------------------------------------------------------------------"

#---------------------------------------------------------------
# Definicao dos comandos SQL para os relatorios
#---------------------------------------------------------------
 let sql_comando = "select nom from datkmotorista",
                   " where atdmotnom = ? "
 prepare sel_motorista from sql_comando
 declare c_motorista cursor for sel_motorista

 let sql_comando = "select srrabvnom from datksrr",
                   " where srrcoddig = ? "
 prepare sel_datksrr_1 from sql_comando
 declare c_datksrr_1 cursor for sel_datksrr_1

 let sql_comando = "select srrnom from datksrr",
                   " where srrcoddig = ? "
 prepare sel_datksrr_2 from sql_comando
 declare c_datksrr_2 cursor for sel_datksrr_2

 let sql_comando = "select atdvclsgl from datkveiculo",
                   " where socvclcod = ? "
 prepare sel_datkveiculo from sql_comando
 declare c_datkveiculo cursor for sel_datkveiculo

 let sql_comando = "select brrnom, cidnom, ufdcod",
                   "  from datmlcl           ",
                   " where atdsrvnum = ?  and",
                   "       atdsrvano = ?  and",
                   "       c24endtip = 1     "
 prepare sel_datmlcl from sql_comando
 declare c_datmlcl cursor for sel_datmlcl


 let sql_comando = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"

 prepare sel_datmsrvacp from sql_comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                     # Marcio Meta - PSI185035
      returning ws.dirfisnom 
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if                                                           
 
 let ws.pathrel01  = ws.dirfisnom clipped, "/RDBS03401"
 let ws.pathrel02  = ws.dirfisnom clipped, "/RDBS03402"
 let ws.pathrel03  = ws.dirfisnom clipped, "/RDBS03403"
                                                                  # Marcio Meta - PSI185035
 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS03401")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDBS03402")                                     
      returning  ws_cctcod02,
		 ws_relviaqtd02

 call fgerc010("RDBS03403")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod03,
		 ws_relviaqtd03

 #---------------------------------------------------------------
 # Cursor para obtencao dos servicos realizados no mes
 #---------------------------------------------------------------
 declare c_bdbsr034   cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atddatprg,
           datmservico.atdsrvorg,
           datmservico.atdprscod,
           datmservico.srrcoddig,
           datmservico.atdmotnom,
           datmservico.atdcstvlr,
           datmservico.atdvclsgl,
           datmservico.socvclcod,
           datmservico.atdfnlflg
      from datmservico
     where datmservico.atddat  between ws.data_de and ws.data_ate

 start report  rep_motsrv  to  ws.pathrel01
 start report  rep_vclsrv  to  ws.pathrel02
 start report  rep_apoio   to  ws.pathrel03

 foreach c_bdbsr034  into  d_bdbsr034.atdsrvnum,
                           d_bdbsr034.atdsrvano,
                           d_bdbsr034.atddatprg,
                           ws.atdsrvorg,
                           d_bdbsr034.atdprscod,
                           d_bdbsr034.srrcoddig,
                           d_bdbsr034.atdmotnom,
                           d_bdbsr034.atdcstvlr,
                           d_bdbsr034.atdvclsgl,
                           ws.socvclcod,
                           ws.atdfnlflg

   if ws.atdsrvorg = 10   or    # vistoria
      ws.atdsrvorg = 11   or    # furto
      ws.atdsrvorg =  8   then  # reserva
      continue foreach
   end if

   if d_bdbsr034.atdprscod is null  then
      continue foreach
   end if

   if d_bdbsr034.atdprscod <> 1  and
      d_bdbsr034.atdprscod <> 4  and
      d_bdbsr034.atdprscod <> 8  then
      continue foreach
   end if

   #------------------------------------------------------------
   # Verifica etapa dos servicos
   #------------------------------------------------------------
   open  c_datmsrvacp using d_bdbsr034.atdsrvnum, d_bdbsr034.atdsrvano,
                            d_bdbsr034.atdsrvnum, d_bdbsr034.atdsrvano
   fetch c_datmsrvacp into  ws.atdetpcod
   close c_datmsrvacp

   if ws.atdetpcod <> 4      and     # somente servicos etapas
      ws.atdetpcod <> 5      then    # concluidas e canceladas
      continue foreach
   end if

   initialize d_bdbsr034.totkmt,
                d_bdbsr034.tothor,
                  d_bdbsr034.totmin   to null

   if d_bdbsr034.atdcstvlr  is not null   then
      call bdbsr034_calc(d_bdbsr034.atdsrvnum, d_bdbsr034.atdsrvano)
           returning d_bdbsr034.totkmt, d_bdbsr034.tothor, d_bdbsr034.totmin
   end if

   if d_bdbsr034.atdcstvlr  is null    then
      let d_bdbsr034.atdcstvlr = 0.00
   end if
   if d_bdbsr034.totkmt     is null    then
      let d_bdbsr034.totkmt    = 0
   end if
   if d_bdbsr034.tothor     is null    then
      let d_bdbsr034.tothor    = "0000:00"
   end if
   if d_bdbsr034.totmin     is null    then
      let d_bdbsr034.totmin    = 0
   end if

   #---------------------------------------------------------------
   # Busca sigla no cadastro de veiculos
   #---------------------------------------------------------------
   if ws.socvclcod  is not null   then
      open  c_datkveiculo  using  ws.socvclcod
      fetch c_datkveiculo  into   d_bdbsr034.atdvclsgl

      if sqlca.sqlcode  =  notfound   then
         display " Veiculo nao encontrado --> ", ws.socvclcod
         exit program(1)
      end if
   end if

   #---------------------------------------------------------------
   # Busca nome abreviado no cadastro de socorristas
   #---------------------------------------------------------------
   if d_bdbsr034.atdmotnom  is null   or
      d_bdbsr034.atdmotnom  =  "  "   then
      open  c_datksrr_1  using  d_bdbsr034.srrcoddig
      fetch c_datksrr_1  into   d_bdbsr034.atdmotnom
      close c_datksrr_1
   end if

   if ws.atdsrvorg = 12   then   # apoio
      initialize d_bdbsr034.brrnom,
                 d_bdbsr034.cidnom,
                 d_bdbsr034.ufdcod     to null

      open  c_datmlcl using d_bdbsr034.atdsrvnum,
                            d_bdbsr034.atdsrvano
      fetch c_datmlcl into  d_bdbsr034.brrnom,
                            d_bdbsr034.cidnom,
                            d_bdbsr034.ufdcod
      close c_datmlcl

      output to report rep_apoio(ws.data_de, ws.data_ate, d_bdbsr034.*)
   else
      output to report rep_motsrv(ws.data_de, ws.data_ate, d_bdbsr034.*)
      output to report rep_vclsrv(ws.data_de, ws.data_ate, d_bdbsr034.*)
   end if

end foreach

finish report  rep_motsrv
finish report  rep_vclsrv
finish report  rep_apoio

end function   ###  bdbsr034


#---------------------------------------------------------------------------
 report rep_motsrv(param, r_bdbsr034)
#---------------------------------------------------------------------------

 define param         record
    data_de           date,
    data_ate          date
 end record

 define r_bdbsr034    record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atddatprg         like datmservico.atddatprg ,
    atdprscod         like datmservico.atdprscod ,
    ufdcod            like datmlcl.ufdcod,
    cidnom            char (20),
    brrnom         char (20),
    srrcoddig         like datmservico.srrcoddig,
    atdmotnom         like datmservico.atdmotnom ,
    atdcstvlr         like datmservico.atdcstvlr ,
    atdvclsgl         like datmservico.atdvclsgl ,
    totkmt            like datmtrajeto.trjorgkmt ,
    tothor            char (06)                  ,
    totmin            integer
 end record

 define ws            record
    fimflg            smallint,
    srvmot            dec (6,0),
    kmtmot            dec (8,0),
    hormot            integer ,
    minmot            integer ,
    cstmot            like datmservico.atdcstvlr,
    kmtmed            dec (8,0),
    cstmed            like datmservico.atdcstvlr,
    tmpmed            char (07),
    tmptot            char (07),
    horaux            integer ,
    minaux            integer ,
    horchr            char (04),
    minchr            char (02),
    motnom            char (50)
 end record

 define a_bdbsr034    array[04]  of  record
    frtdsc            char(20),
    srvtot            dec (6,0),
    kmttot            dec (8,0),
    hortot            dec (6,0),
    mintot            dec (6,0),
    csttot            like datmservico.atdcstvlr
 end record

 define total         smallint
 define arr_aux       smallint

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr034.atdprscod,
             r_bdbsr034.atdmotnom

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03401 FORMNAME=BRANCO"         # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS POR MOTORISTA"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
            print ascii(12)

            let total = 4

            let a_bdbsr034[1].frtdsc = "SAO PAULO"
            let a_bdbsr034[2].frtdsc = "RIO DE JANEIRO"
            let a_bdbsr034[3].frtdsc = "SALVADOR"
            let a_bdbsr034[4].frtdsc = "TOTAL GERAL"

            for arr_aux = 1 to 4
               let a_bdbsr034[arr_aux].srvtot = 0
               let a_bdbsr034[arr_aux].kmttot = 0
               let a_bdbsr034[arr_aux].hortot = 0
               let a_bdbsr034[arr_aux].mintot = 0
               let a_bdbsr034[arr_aux].csttot = 0
            end for

            let arr_aux = 1
            let ws.fimflg = false
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 099, "RDBS034-01",
               column 113, "PAGINA : ", pageno using "##,###,###"
         print column 018, "CONTROLE DA FROTA POR MOTORISTA NO PERIODO DE ", param.data_de, " A ", param.data_ate,
               column 113, "DATA   : ", today
         print column 113, "HORA   :   ", time
         skip 2 lines

         if ws.fimflg = true  then
            let arr_aux = 4
         end if

         if arr_aux < 4  then
            print column 001, "FROTA ", a_bdbsr034[arr_aux].frtdsc
         else
            print column 001, a_bdbsr034[arr_aux].frtdsc
         end if
         print column 001, wsgtraco

         if ws.fimflg = true  then
            print column 001, "FROTA"      ;
         else
            print column 001, "MOTORISTA"  ;
         end if

         print column 050, "SERVICOS"   ,
               column 060, "KM TOTAL"   ,
               column 070, "KM MEDIA"   ,
               column 079, "TEMPO TOTAL",
               column 092, "TEMPO MEDIO",
               column 107, "CUSTO TOTAL",
               column 122, "CUSTO MEDIO"
         print column 001, wsgtraco
         skip 1 line

      before group of r_bdbsr034.atdprscod
         if r_bdbsr034.atdprscod = 1  then
            let arr_aux = 1
            skip to top of page
         else
            if r_bdbsr034.atdprscod = 4  then
               let arr_aux = 2
            else
               let arr_aux = 3
            end if
         end if

      after group of r_bdbsr034.atdprscod
         if arr_aux < 4  then
            let a_bdbsr034[total].srvtot = a_bdbsr034[total].srvtot + a_bdbsr034[arr_aux].srvtot
            let a_bdbsr034[total].kmttot = a_bdbsr034[total].kmttot + a_bdbsr034[arr_aux].kmttot
            let a_bdbsr034[total].mintot = a_bdbsr034[total].mintot + a_bdbsr034[arr_aux].mintot
            let a_bdbsr034[total].csttot = a_bdbsr034[total].csttot + a_bdbsr034[arr_aux].csttot
         end if

      before group of r_bdbsr034.atdmotnom
         if r_bdbsr034.srrcoddig  is not null   then
            let ws.motnom = "*** NAO INFORMADO ***"

            open  c_datksrr_2 using r_bdbsr034.srrcoddig
            fetch c_datksrr_2 into  ws.motnom
            close c_datksrr_2
         else
            let ws.motnom = "*** NAO CADASTRADO ***"

            open  c_motorista using r_bdbsr034.atdmotnom
            fetch c_motorista into  ws.motnom
            close c_motorista
         end if

         let ws.motnom = r_bdbsr034.atdmotnom clipped, " - ", ws.motnom clipped

         let ws.srvmot = 0
         let ws.kmtmot = 0
         let ws.minmot = 0
         let ws.cstmot = 0

      after group of r_bdbsr034.atdmotnom
         let a_bdbsr034[arr_aux].srvtot = a_bdbsr034[arr_aux].srvtot + ws.srvmot
         let a_bdbsr034[arr_aux].kmttot = a_bdbsr034[arr_aux].kmttot + ws.kmtmot
         let a_bdbsr034[arr_aux].mintot = a_bdbsr034[arr_aux].mintot + ws.minmot
         let a_bdbsr034[arr_aux].csttot = a_bdbsr034[arr_aux].csttot + ws.cstmot

         if r_bdbsr034.atdprscod = 1  then
            let ws.kmtmed = ws.kmtmot / ws.srvmot
            let ws.cstmed = ws.cstmot / ws.srvmot

            let ws.hormot = ws.minmot / 60
            let ws.horaux = ws.hormot
            let ws.minaux = ws.minmot mod 60

            let ws.horchr = ws.horaux using "##&&"
            let ws.minchr = ws.minaux using "&&"
            let ws.tmptot = ws.horchr[1,4], ":" , ws.minchr[1,2]

            let ws.minmot = ws.minmot / ws.srvmot
            let ws.horaux = ws.minmot / 60
            let ws.minaux = ws.minmot mod 60

            let ws.horchr = ws.horaux using "##&&"
            let ws.minchr = ws.minaux using "&&"
            let ws.tmpmed = ws.horchr[1,4], ":" , ws.minchr[1,2]

            print column 001;
            if ws.fimflg = true  then
               print a_bdbsr034[arr_aux].frtdsc;
            else
               print ws.motnom;
            end if

            print column 051, ws.srvmot using "###,##&",
                  column 059, ws.kmtmot using "#####,##&",
                  column 069, ws.kmtmed using "#####,##&",
                  column 083, ws.tmptot,
                  column 096, ws.tmpmed,
                  column 105, ws.cstmot using "##,###,##&.&&",
                  column 120, ws.cstmed using "##,###,##&.&&"
         end if

      on every row
         let ws.srvmot = ws.srvmot + 1
         let ws.kmtmot = ws.kmtmot + r_bdbsr034.totkmt
         let ws.minmot = ws.minmot + r_bdbsr034.totmin
         let ws.cstmot = ws.cstmot + r_bdbsr034.atdcstvlr

      on last row
         let ws.fimflg = true
         skip to top of page

         for arr_aux = 1 to 4
            let a_bdbsr034[arr_aux].hortot = a_bdbsr034[arr_aux].mintot / 60
            let ws.kmtmed = a_bdbsr034[arr_aux].kmttot / a_bdbsr034[arr_aux].srvtot
            if ws.kmtmed is null  then
               let ws.kmtmed = 0
            end if

            let ws.cstmed = a_bdbsr034[arr_aux].csttot / a_bdbsr034[arr_aux].srvtot
            if ws.cstmed is null  then
               let ws.cstmed = 0
            end if

            let ws.horaux = a_bdbsr034[arr_aux].mintot / 60
            let ws.minaux = a_bdbsr034[arr_aux].mintot mod 60

            if ws.horaux is null  then
               let ws.horaux = 00
            end if

            if ws.minaux is null  then
               let ws.minaux = 00
            end if

            let ws.horchr = ws.horaux using "##&&"
            let ws.minchr = ws.minaux using "&&"
            let ws.tmptot = ws.horchr[1,4], ":", ws.minchr[1,2]

            let a_bdbsr034[arr_aux].mintot = a_bdbsr034[arr_aux].mintot / a_bdbsr034[arr_aux].srvtot
            let ws.horaux = a_bdbsr034[arr_aux].mintot / 60
            let ws.minaux = a_bdbsr034[arr_aux].mintot mod 60

            if ws.horaux is null  then
               let ws.horaux = 00
            end if

            if ws.minaux is null  then
               let ws.minaux = 00
            end if

            let ws.horchr = ws.horaux using "##&&"
            let ws.minchr = ws.minaux using "&&"
            let ws.tmpmed = ws.horchr[1,4], ":", ws.minchr[1,2]

            if arr_aux = 4  then
               print column 001, wsgtraco
               print column 001, "TOTAL";
            else
               print column 001, a_bdbsr034[arr_aux].frtdsc;
            end if

            print column 051, a_bdbsr034[arr_aux].srvtot using "###,##&",
                  column 059, a_bdbsr034[arr_aux].kmttot using "#####,##&",
                  column 069, ws.kmtmed using "#####,##&",
                  column 083, ws.tmptot,
                  column 096, ws.tmpmed,
                  column 105, a_bdbsr034[arr_aux].csttot using "##,###,##&.&&",
                  column 120, ws.cstmed using "##,###,##&.&&"
         end for

         print "$FIMREL$"

end report   ### rep_motsrv


#---------------------------------------------------------------------------
 report rep_vclsrv(param, r_bdbsr034)
#---------------------------------------------------------------------------

 define param         record
    data_de           date,
    data_ate          date
 end record

 define r_bdbsr034    record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atddatprg         like datmservico.atddatprg ,
    atdprscod         like datmservico.atdprscod ,
    ufdcod            like datmlcl.ufdcod,
    cidnom            char (20),
    brrnom         char (20),
    srrcoddig         like datmservico.srrcoddig ,
    atdmotnom         like datmservico.atdmotnom ,
    atdcstvlr         like datmservico.atdcstvlr ,
    atdvclsgl         like datmservico.atdvclsgl ,
    totkmt            like datmtrajeto.trjorgkmt ,
    tothor            char (06)                  ,
    totmin            integer
 end record

 define ws            record
    fimflg            smallint,
    srvvcl            dec (6,0),
    kmtvcl            dec (8,0),
    horvcl            integer ,
    minvcl            integer ,
    cstvcl            like datmservico.atdcstvlr,
    kmtmed            dec (8,0),
    cstmed            like datmservico.atdcstvlr,
    tmpmed            char (07),
    tmptot            char (07),
    horaux            integer ,
    minaux            integer ,
    horchr            char (04),
    minchr            char (02)
 end record

 define a_bdbsr034    array[04]  of  record
    frtdsc            char(20),
    srvtot            dec (6,0),
    kmttot            dec (8,0),
    hortot            integer ,
    mintot            integer ,
    csttot            like datmservico.atdcstvlr
 end record

 define total         smallint
 define arr_aux       smallint


   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr034.atdprscod,
             r_bdbsr034.atdvclsgl

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03402 FORMNAME=BRANCO"       # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS POR VEICULO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
            print ascii(12)

            let total = 4

            let a_bdbsr034[1].frtdsc = "SAO PAULO"
            let a_bdbsr034[2].frtdsc = "RIO DE JANEIRO"
            let a_bdbsr034[3].frtdsc = "SALVADOR"
            let a_bdbsr034[4].frtdsc = "TOTAL GERAL"

            for arr_aux = 1 to 4
               let a_bdbsr034[arr_aux].srvtot = 0
               let a_bdbsr034[arr_aux].kmttot = 0
               let a_bdbsr034[arr_aux].hortot = 0
               let a_bdbsr034[arr_aux].mintot = 0
               let a_bdbsr034[arr_aux].csttot = 0
            end for

            let arr_aux = 1
            let ws.fimflg = false
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 099, "RDBS034-02",
               column 113, "PAGINA : ", pageno using "##,###,###"
         print column 018, "CONTROLE DA FROTA POR VEICULO NO PERIODO DE ", param.data_de, " A ", param.data_ate,
               column 113, "DATA   : ", today
         print column 113, "HORA   :   ", time
         skip 2 lines

         if ws.fimflg = true  then
            let arr_aux = 4
         end if

         if arr_aux < 4  then
            print column 001, "FROTA ", a_bdbsr034[arr_aux].frtdsc
         else
            print column 001, a_bdbsr034[arr_aux].frtdsc
         end if
         print column 001, wsgtraco

         if ws.fimflg = true  then
            print column 001, "FROTA"   ;
         else
            print column 001, "VEICULO" ;
         end if
         print column 024, "SERVICOS"   ,
               column 036, "KM TOTAL"   ,
               column 048, "KM MEDIA"   ,
               column 060, "TEMPO TOTAL",
               column 075, "TEMPO MEDIO",
               column 094, "CUSTO TOTAL",
               column 113, "CUSTO MEDIO"
         print column 001, wsgtraco
         skip 1 line

      before group of r_bdbsr034.atdprscod
         if r_bdbsr034.atdprscod = 1  then
            let arr_aux = 1
         else
            if r_bdbsr034.atdprscod = 4  then
               let arr_aux = 2
            else
               let arr_aux = 3
            end if
         end if
         skip to top of page

      after group of r_bdbsr034.atdprscod
         if arr_aux < 4  then
            let a_bdbsr034[total].srvtot = a_bdbsr034[total].srvtot + a_bdbsr034[arr_aux].srvtot
            let a_bdbsr034[total].kmttot = a_bdbsr034[total].kmttot + a_bdbsr034[arr_aux].kmttot
            let a_bdbsr034[total].mintot = a_bdbsr034[total].mintot + a_bdbsr034[arr_aux].mintot
            let a_bdbsr034[total].csttot = a_bdbsr034[total].csttot + a_bdbsr034[arr_aux].csttot
         end if

      before group of r_bdbsr034.atdvclsgl
         let ws.srvvcl = 0
         let ws.kmtvcl = 0
         let ws.minvcl = 0
         let ws.cstvcl = 0

      after group of r_bdbsr034.atdvclsgl
         let a_bdbsr034[arr_aux].srvtot = a_bdbsr034[arr_aux].srvtot + ws.srvvcl
         let a_bdbsr034[arr_aux].kmttot = a_bdbsr034[arr_aux].kmttot + ws.kmtvcl
         let a_bdbsr034[arr_aux].mintot = a_bdbsr034[arr_aux].mintot + ws.minvcl
         let a_bdbsr034[arr_aux].csttot = a_bdbsr034[arr_aux].csttot + ws.cstvcl

         let ws.kmtmed = ws.kmtvcl / ws.srvvcl
         let ws.cstmed = ws.cstvcl / ws.srvvcl

         let ws.horvcl = ws.minvcl / 60
         let ws.horaux = ws.horvcl
         let ws.minaux = ws.minvcl mod 60

         let ws.horchr = ws.horaux using "##&&"
         let ws.minchr = ws.minaux using "&&"
         let ws.tmptot = ws.horchr[1,4], ":" , ws.minchr[1,2]

         let ws.minvcl = ws.minvcl / ws.srvvcl
         let ws.horaux = ws.minvcl / 60
         let ws.minaux = ws.minvcl mod 60

         let ws.horchr = ws.horaux using "##&&"
         let ws.minchr = ws.minaux using "&&"
         let ws.tmpmed = ws.horchr[1,4], ":" , ws.minchr[1,2]

         print column 001;
         if ws.fimflg = true  then
            print a_bdbsr034[arr_aux].frtdsc;
         else
            if r_bdbsr034.atdvclsgl is null  then
               print "*** NAO INFORMADO ***";
            else
               print r_bdbsr034.atdvclsgl;
            end if
         end if

         print column 025, ws.srvvcl using "###,##&",
               column 035, ws.kmtvcl using "#####,##&",
               column 047, ws.kmtmed using "#####,##&",
               column 064, ws.tmptot,
               column 079, ws.tmpmed,
               column 092, ws.cstvcl using "##,###,##&.&&",
               column 111, ws.cstmed using "##,###,##&.&&"

      on every row
         let ws.srvvcl = ws.srvvcl + 1
         let ws.kmtvcl = ws.kmtvcl + r_bdbsr034.totkmt
         let ws.minvcl = ws.minvcl + r_bdbsr034.totmin
         let ws.cstvcl = ws.cstvcl + r_bdbsr034.atdcstvlr

      on last row
         let ws.fimflg = true
         skip to top of page

         for arr_aux = 1 to 4
            let a_bdbsr034[arr_aux].hortot = a_bdbsr034[arr_aux].mintot / 60
            let ws.kmtmed = a_bdbsr034[arr_aux].kmttot / a_bdbsr034[arr_aux].srvtot
            if ws.kmtmed is null  then
               let ws.kmtmed = 0
            end if

            let ws.cstmed = a_bdbsr034[arr_aux].csttot / a_bdbsr034[arr_aux].srvtot
            if ws.cstmed is null  then
               let ws.cstmed = 0
            end if

            let ws.horaux = a_bdbsr034[arr_aux].mintot / 60
            let ws.minaux = a_bdbsr034[arr_aux].mintot mod 60

            if ws.horaux is null  then
               let ws.horaux = 00
            end if

            if ws.minaux is null  then
               let ws.minaux = 00
            end if

            let ws.horchr = ws.horaux using "##&&"
            let ws.minchr = ws.minaux using "&&"
            let ws.tmptot = ws.horchr[1,4], ":", ws.minchr[1,2]

            let a_bdbsr034[arr_aux].mintot = a_bdbsr034[arr_aux].mintot / a_bdbsr034[arr_aux].srvtot
            let ws.horaux = a_bdbsr034[arr_aux].mintot / 60
            let ws.minaux = a_bdbsr034[arr_aux].mintot mod 60

            if ws.horaux is null  then
               let ws.horaux = 00
            end if

            if ws.minaux is null  then
               let ws.minaux = 00
            end if

            let ws.horchr = ws.horaux using "##&&"
            let ws.minchr = ws.minaux using "&&"
            let ws.tmpmed = ws.horchr[1,4], ":", ws.minchr[1,2]

            if arr_aux = 4  then
               print column 001, wsgtraco
               print column 001, "TOTAL";
            else
               print column 001, a_bdbsr034[arr_aux].frtdsc;
            end if
            print column 025, a_bdbsr034[arr_aux].srvtot using "###,##&",
                  column 035, a_bdbsr034[arr_aux].kmttot using "#####,##&",
                  column 047, ws.kmtmed using "#####,##&",
                  column 064, ws.tmptot,
                  column 079, ws.tmpmed,
                  column 092, a_bdbsr034[arr_aux].csttot using "##,###,##&.&&",
                  column 111, ws.cstmed using "##,###,##&.&&"
         end for

         print "$FIMREL$"

end report   ### rep_vclsrv


#---------------------------------------------------------------------------
 report rep_apoio(param, r_bdbsr034)
#---------------------------------------------------------------------------

 define param         record
    data_de           date,
    data_ate          date
 end record

 define r_bdbsr034    record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atddatprg         like datmservico.atddatprg ,
    atdprscod         like datmservico.atdprscod ,
    ufdcod            like datmlcl.ufdcod,
    cidnom            char (20),
    brrnom         char (20),
    srrcoddig         like datmservico.srrcoddig ,
    atdmotnom         like datmservico.atdmotnom ,
    atdcstvlr         like datmservico.atdcstvlr ,
    atdvclsgl         like datmservico.atdvclsgl ,
    totkmt            like datmtrajeto.trjorgkmt ,
    tothor            char (06)                  ,
    totmin            integer
 end record

 define ws            record
    srvtot            dec (6,0),
    kmttot            dec (8,0),
    kmtmed            dec (8,0),
    hortot            integer ,
    horaux            integer ,
    horchr            char (04),
    mintot            integer ,
    minaux            integer ,
    minchr            char (02),
    csttot            like datmservico.atdcstvlr,
    cstmed            like datmservico.atdcstvlr,
    tmptot            char (07),
    tmpmed            char (07)
 end record

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by r_bdbsr034.atddatprg,
            r_bdbsr034.atdsrvnum

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03403 FORMNAME=BRANCO"        # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS DE APOIO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd03 using "&&", ", DEPT='", ws_cctcod03 using "&&&", "', END;"
            print ascii(12)

            let ws.srvtot = 0
            let ws.kmttot = 0
            let ws.csttot = 0
            let ws.mintot = 0
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 099, "RDBS034-03",
               column 113, "PAGINA : ", pageno using "##,###,###"
         print column 018, "SERVICOS DE APOIO REALIZADOS NO PERIODO DE ", param.data_de, " A ", param.data_ate,
               column 113, "DATA   : ", today
         print column 113, "HORA   :   ", time
         skip 2 lines

         print column 001, "DATA"       ,
               column 014, "SERVICO"    ,
               column 025, "VEICULO"    ,
               column 034, "MOTORISTA"  ,
               column 045, "BAIRRO"     ,
               column 067, "CIDADE"     ,
               column 089, "UF"         ,
               column 093, "QUILOM."    ,
               column 104, "TEMPO"      ,
               column 121, "CUSTO"
         print column 001, wsgtraco
         skip 1 line

      on every row
         let ws.srvtot = ws.srvtot + 1
         let ws.kmttot = ws.kmttot + r_bdbsr034.totkmt
         let ws.csttot = ws.csttot + r_bdbsr034.atdcstvlr
         let ws.mintot = ws.mintot + r_bdbsr034.totmin

         let ws.horaux = r_bdbsr034.totmin / 60
         let ws.minaux = r_bdbsr034.totmin mod 60

         if ws.horaux is null  then
            let ws.horaux = 00
         end if

         if ws.minaux is null  then
            let ws.minaux = 00
         end if

         let ws.horchr = ws.horaux using "##&&"
         let ws.minchr = ws.minaux using "&&"
         let ws.tmptot = ws.horchr[1,4], ":", ws.minchr[1,2]

         print column 001, r_bdbsr034.atddatprg,
               column 014, r_bdbsr034.atdsrvnum  using "&&&&&&&","-",
                           r_bdbsr034.atdsrvano  using "&&",
               column 025, r_bdbsr034.atdvclsgl,
               column 034, r_bdbsr034.atdmotnom,
               column 045, r_bdbsr034.brrnom,
               column 067, r_bdbsr034.cidnom,
               column 089, r_bdbsr034.ufdcod,
               column 091, r_bdbsr034.totkmt     using "#####,##&",
               column 102, ws.tmptot,
               column 112, r_bdbsr034.atdcstvlr  using "###,###,##&.&&"

      on last row
         let ws.kmtmed = ws.kmttot / ws.srvtot
         if ws.kmtmed is null  then
            let ws.kmtmed = 0
         end if

         let ws.cstmed = ws.csttot / ws.srvtot
         if ws.cstmed is null  then
            let ws.cstmed = 0
         end if

         let ws.horaux = ws.mintot / 60
         let ws.minaux = ws.mintot mod 60

         if ws.horaux is null  then
            let ws.horaux = 00
         end if

         if ws.minaux is null  then
            let ws.minaux = 00
         end if

         let ws.horchr = ws.horaux using "##&&"
         let ws.minchr = ws.minaux using "&&"
         let ws.tmptot = ws.horchr[1,4], ":", ws.minchr[1,2]

         let ws.mintot = ws.mintot / ws.srvtot
         let ws.horaux = ws.mintot / 60
         let ws.minaux = ws.mintot mod 60

         if ws.horaux is null  then
            let ws.horaux = 00
         end if

         if ws.minaux is null  then
            let ws.minaux = 00
         end if

         let ws.horchr = ws.horaux using "##&&"
         let ws.minchr = ws.minchr using "&&"
         let ws.tmpmed = ws.horchr[1,4], ":", ws.minchr[1,2]

         need 6 lines
         skip 1 line
         print column 001, wsgtraco
         print column 001, "QUANTIDADE DE SERVICOS ...: ", ws.srvtot using "###,##&"
         print column 001, "QUILOMETRAGEM TOTAL ......: ", ws.kmttot using "<<###,##&",
               column 070, "QUILOMETRAGEM MEDIA ......: ", ws.kmtmed using "<<###,##&"
         print column 001, "TEMPO TOTAL UTILIZADO ....: ", ws.tmptot,
               column 070, "TEMPO MEDIO UTILIZADO ....: ", ws.tmpmed
         print column 001, "CUSTO TOTAL ..............: ", ws.csttot using "###,###,###,##&.&&",
               column 070, "CUSTO MEDIO ..............: ", ws.cstmed using "###,###,###,##&.&&"

         print "$FIMREL$"

end report   ### rep_motsrv


#---------------------------------------------------------------
 function bdbsr034_calc(param)
#---------------------------------------------------------------

 define param     record
    atdsrvnum     like datmservico.atdsrvnum,
    atdsrvano     like datmservico.atdsrvano
 end record

 define ws        record
    h24           datetime hour to minute,
    totmin        integer  ,
    tothor        char (06),
    totkmt        dec (8,0),
    atdcstvlr     like datmservico.atdcstvlr,
    inckmt        like datmtrajeto.trjorgkmt,
    fnlkmt        like datmtrajeto.trjdstkmt,
    inchor        datetime hour to minute,
    fnlhor        datetime hour to minute,
    trjnumseq     like datmtrajeto.trjnumseq
 end record

 initialize ws.inchor  to null
 initialize ws.fnlhor  to null

 let ws.totmin     = 0
 let ws.atdcstvlr  = 0
 let ws.inckmt     = 0
 let ws.fnlkmt     = 0
 let ws.trjnumseq  = 0

 select min(trjnumseq)
   into ws.trjnumseq
   from datmtrajeto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound  or
    ws.trjnumseq = 0          then
    return ws.totkmt, ws.tothor, ws.totmin
 end if

 select trjorghor, trjorgkmt
   into ws.inchor, ws.inckmt
   from datmtrajeto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano  and
        trjnumseq = ws.trjnumseq

 let ws.trjnumseq = 0

 select max(trjnumseq)
   into ws.trjnumseq
   from datmtrajeto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound  or
    ws.trjnumseq = 0          then
    return ws.totkmt, ws.tothor, ws.totmin
 end if

 select trjdsthor, trjdstkmt
   into ws.fnlhor, ws.fnlkmt
   from datmtrajeto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano  and
        trjnumseq = ws.trjnumseq

#---------------------------------------------------------------
# Calcula horas trabalhadas
#---------------------------------------------------------------

 if ws.inchor <= ws.fnlhor  then
    let ws.tothor = ws.fnlhor - ws.inchor
 else
    let ws.h24    = "23:59"
    let ws.tothor = ws.h24 - ws.inchor
    let ws.h24    = "00:00"
    let ws.tothor = ws.tothor + (ws.fnlhor - ws.h24) + "00:01"
 end if

 let ws.totmin    = (ws.tothor[2,3] * 60) + ws.tothor[5,6]

#---------------------------------------------------------------
# Calcula quilometros rodados
#---------------------------------------------------------------

 let ws.totkmt    = ws.fnlkmt - ws.inckmt

 return ws.totkmt, ws.tothor, ws.totmin

end function   ###  bdbsr034_calc
