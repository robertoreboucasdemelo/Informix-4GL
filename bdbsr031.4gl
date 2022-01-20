############################################################################
# Nome do Modulo: bdbsr030                                        Marcelo  #
#                                                                 Gilberto #
# Relatorio mensal de total de servicos pagos por prestador       Jan/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 05/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas #
#                                       para verificacao do servico.       #
#--------------------------------------------------------------------------#
# 15/03/2000  PSI 10246-6  Wagner       Incluir totalizadores separados p/ #
#                                       Assist.Passageiros.                #
#--------------------------------------------------------------------------#
# 14/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo      #
#                                       atdsrvnum de 6 p/ 10.              #
#                                       Troca do campo atdtip p/ atdsrvorg.#
#--------------------------------------------------------------------------#
# 29/08/2000  PSI 11097-3  Wagner       Inclusao de translado e Ambulancia #
#--------------------------------------------------------------------------#
# 21/09/2000  AS           Raji         Inclusao de totalizador e quebra p/#
#                                       hospedagem                         #
############################################################################
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

 define ws_traco156    char(156),
        ws_traco132    char(132),
        ws_duplo       char(120)

 define ws_data_de     date,
        ws_data_ate    date,
        ws_data_aux    char(10),
        ws_periodo     dec(1,0),
        ws_cctcod01    like igbrrelcct.cctcod,
        ws_relviaqtd01 like igbrrelcct.relviaqtd,
        ws_cctcod02    like igbrrelcct.cctcod,
        ws_relviaqtd02 like igbrrelcct.relviaqtd

 define ws_pas         array[06]  of  record
        asitipdes      char (10)     ,
        qtdsrv         decimal (06,0),
        qtdpas         decimal (06,0),
        totvlr         dec (13,2)
 end record                             
 
 define m_path         char(100)              # Marcio Meta - PSI185035

 main
    
    call fun_dba_abre_banco("CT24HS") 

    let m_path = f_path("DBS","LOG")          # Marcio Meta - PSI185035
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr031.log"

    call startlog(m_path)
                                                                # Marcio Meta - PSI185035
    call bdbsr031()
    
 end main

#---------------------------------------------------------------
 function bdbsr031()
#---------------------------------------------------------------

 define d_bdbsr031    record
    atdprscod         like datmservico.atdprscod,
    atdprstip         smallint,
    nomrazsoc         like dpaksocor.nomrazsoc,
    nomgrr            like dpaksocor.nomgrr,
    endcid            like dpaksocor.endcid,
    endufd            like dpaksocor.endufd,
    endcep            like dpaksocor.endcep,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    pasqtd            smallint,
    asitipcod         like datmservico.asitipcod
 end record

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    vlrtabflg         like dpaksocor.vlrtabflg,
    atdfnlflg         like datmservico.atdfnlflg,
    atdetpcod         like datmsrvacp.atdetpcod,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02         char (60),
    patharq01         char (60)
 end record

 define sql_select    char(300)


 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 initialize d_bdbsr031.*  to null
 initialize ws.*          to null

 let ws_traco156 = "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
 let ws_traco132 = "------------------------------------------------------------------------------------------------------------------------------------"
 let ws_duplo    = "========================================================================================================================"
 let ws_pas[1].asitipdes = "TAXI"
 let ws_pas[1].qtdsrv    = 0
 let ws_pas[1].qtdpas    = 0
 let ws_pas[1].totvlr    = 0
 let ws_pas[2].asitipdes = "AVIAO"
 let ws_pas[2].qtdsrv    = 0
 let ws_pas[2].qtdpas    = 0
 let ws_pas[2].totvlr    = 0
 let ws_pas[3].asitipdes = "RODOVIARIO"
 let ws_pas[3].qtdsrv    = 0
 let ws_pas[3].qtdpas    = 0
 let ws_pas[3].totvlr    = 0
 let ws_pas[4].asitipdes = "AMBULANCIA"
 let ws_pas[4].qtdsrv    = 0
 let ws_pas[4].qtdpas    = 0
 let ws_pas[4].totvlr    = 0
 let ws_pas[5].asitipdes = "TRANSLADO"
 let ws_pas[5].qtdsrv    = 0
 let ws_pas[5].qtdpas    = 0
 let ws_pas[5].totvlr    = 0
 let ws_pas[6].asitipdes = "HOSPEDAGEM"
 let ws_pas[6].qtdsrv    = 0
 let ws_pas[6].qtdpas    = 0
 let ws_pas[6].totvlr    = 0

 #---------------------------------------------------------------
 # Preparacao dos comandos SQL
 #---------------------------------------------------------------
 let sql_select = "select nomrazsoc, nomgrr, endcid,   ",
                  "       endufd   , endcep, vlrtabflg ",
                  "  from dpaksocor where pstcoddig = ?"
 prepare sel_guerra from sql_select
 declare c_guerra cursor for sel_guerra

 let sql_select = "select count(*) ",
                  "  from datmpassageiro   ",
                  " where atdsrvnum = ? and",
                  "       atdsrvano = ?    "
 prepare sel_passageiro from sql_select
 declare c_passageiro cursor for sel_passageiro

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

 let sql_select = "select atdetpdes    ",
                  "  from datketapa    ",
                  " where atdetpcod = ?"
 prepare sel_datketapa from sql_select
 declare c_datketapa cursor for sel_datketapa

 #---------------------------------------------------------------
 # Define o periodo de extracao
 #---------------------------------------------------------------
 let ws_periodo  = arg_val(1)    #-> (1)Semanal, (2)Mensal
 let ws_data_aux = arg_val(2)

 if ((ws_periodo   is null)  or
     (ws_periodo   <>  1     and
      ws_periodo   <>  2))   then
       display "                      *** ERRO NO PARAMETRO: PERIODO INVALIDO ***"
       exit program
 end if

 if ws_data_aux is null       or
    ws_data_aux =  "  "       then
    let ws_data_aux = today
 else
#   if ws_data_aux >= today      or
    if length(ws_data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 #---------------------------------------------------------------
 # Define o periodo semanal
 #---------------------------------------------------------------
 if ws_periodo  =  1   then
    let ws_data_ate = ws_data_aux
    let ws_data_ate = ws_data_ate - 1 units day

    let ws_data_de  = ws_data_ate - 6 units day
 end if

 #---------------------------------------------------------------
 # Define o periodo mensal
 #---------------------------------------------------------------
 if ws_periodo  =  2   then
    let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
    let ws_data_ate = ws_data_aux
    let ws_data_ate = ws_data_ate - 1 units day

    let ws_data_aux = ws_data_ate
    let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
    let ws_data_de  = ws_data_aux
 end if


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                 # Marcio Meta - PSI185035
      returning ws.dirfisnom
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if         
                                                              # Marcio Meta - PSI185035
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS03101"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS03102"

 call f_path("DBS", "ARQUIVO")                                # Marcio Meta - PSI185035
      returning ws.dirfisnom
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if               
                                                              # Marcio Meta - PSI185035
 let ws.patharq01 = ws.dirfisnom clipped, "/ADBS031I01"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS03101")                                   # Marcio Meta - PSI185035
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDBS03102")                                   # Marcio Meta - PSI185035
      returning  ws_cctcod02,
		 ws_relviaqtd02


 #---------------------------------------------------------------
 # Definicao de cursores para extracao
 #---------------------------------------------------------------
 declare  c_bdbsr031  cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdprscod,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr,
           datmservico.asitipcod
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between  ws_data_de and ws_data_ate
       and dbsmopg.socopgsitcod   =  7
       and dbsmopgitm.socopgnum   =  dbsmopg.socopgnum
       and datmservico.atdsrvnum  =  dbsmopgitm.atdsrvnum
       and datmservico.atdsrvano  =  dbsmopgitm.atdsrvano


 declare  c_bdbsr031_frota  cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdprscod,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr,
           datmservico.atdfnlflg,
           datmservico.asitipcod
      from datmservico
     where atddat between  ws_data_de and ws_data_ate


 start report  rep_prssrv  to  ws.patharq01
 start report  rep_totais  to  ws.pathrel01
 start report  rep_taxi    to  ws.pathrel02

 if ws_periodo  =  2   then
    start report  arq_totais  to  ws.patharq01
 end if

 #---------------------------------------------------------------
 # Extracao dos servicos pagos no periodo
 #---------------------------------------------------------------
 foreach c_bdbsr031  into  ws.atdsrvnum        ,
                           ws.atdsrvano        ,
                           d_bdbsr031.atdprscod,
                           d_bdbsr031.atdsrvorg,
                           d_bdbsr031.atdcstvlr,
                           d_bdbsr031.asitipcod

    if d_bdbsr031.atdprscod  is null or    # Nao contem codigo de prestador.
       d_bdbsr031.atdprscod  =  0    or    # Codigo de Prestador e' zero.
       d_bdbsr031.atdprscod  = "2"   or    # Servico Cancelado
       d_bdbsr031.atdsrvorg  = 10    or    # Vistoria Previa Domiciliar
       d_bdbsr031.atdsrvorg  = 11    or    # Aviso Furto/Roubo
       d_bdbsr031.atdsrvorg  = 12    or    # Servico de Apoio
       d_bdbsr031.atdsrvorg  =  8    then  # Reserva Carro Extra
       continue foreach
    end if

    #---------------------------------------------------------------
    # Pesquisa nome de guerra do prestador
    #---------------------------------------------------------------
    open  c_guerra using d_bdbsr031.atdprscod
    fetch c_guerra into  d_bdbsr031.nomrazsoc,
                         d_bdbsr031.nomgrr   ,
                         d_bdbsr031.endcid   ,
                         d_bdbsr031.endufd   ,
                         d_bdbsr031.endcep   ,
                         ws.vlrtabflg

    if sqlca.sqlcode < 0 then
       display "Erro (", sqlca.sqlcode, ") na localizacao do prestador ", d_bdbsr031.atdprscod using "&&&&&&", ". AVISE A INFORMATICA!"
       return
    end if
    close c_guerra

    if ( ws.atdetpcod =  6  or ws.atdetpcod =  5  ) and
       d_bdbsr031.nomgrr is null then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Informacoes para relatorio de assistencia a passageiros
    #---------------------------------------------------------------
    if d_bdbsr031.atdsrvorg =  3   or
       d_bdbsr031.atdsrvorg =  2   then
       open  c_passageiro   using ws.atdsrvnum, ws.atdsrvano
       fetch c_passageiro   into  d_bdbsr031.pasqtd
       close c_passageiro
    end if

    #---------------------------------------------------------------
    # Identifica tipo do prestador. FROTA nao sera' listada pois
    # nao possui data de pagamento (PGTDAT)
    #---------------------------------------------------------------
    if d_bdbsr031.atdprscod = 1  or
       d_bdbsr031.atdprscod = 4  or
       d_bdbsr031.atdprscod = 8  then
       let d_bdbsr031.atdprstip = 1
    else
       if ws.vlrtabflg = "S"  then
          let d_bdbsr031.atdprstip = 2
       else
          let d_bdbsr031.atdprstip = 3
       end if
    end if

    output to report rep_prssrv(d_bdbsr031.*)

 end foreach

 #---------------------------------------------------------------
 # Extracao dos servicos atendidos pela frota no periodo
 #---------------------------------------------------------------
 foreach c_bdbsr031_frota  into  ws.atdsrvnum        ,
                                 ws.atdsrvano        ,
                                 d_bdbsr031.atdprscod,
                                 d_bdbsr031.atdsrvorg,
                                 d_bdbsr031.atdcstvlr,
                                 ws.atdfnlflg        ,
                                 d_bdbsr031.asitipcod

    if ws.atdfnlflg = "N"    then
       continue foreach
    end if
    #------------------------------------------------------------
    # Verifica etapa do servico
    #------------------------------------------------------------
    open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if d_bdbsr031.atdprscod  is null  or    # Nao contem codigo de prestador.
       d_bdbsr031.atdprscod  <> 1     or    # Prestador diferente de FROTA.
       d_bdbsr031.atdsrvorg  = 10     or    # Vistoria Previa Domiciliar
       d_bdbsr031.atdsrvorg  = 11     or    # Aviso Furto/Roubo
       d_bdbsr031.atdsrvorg  = 12     or    # Servico de Apoio
       d_bdbsr031.atdsrvorg  =  8     then  # Reserva Carro Extra
       continue foreach
    end if

    if d_bdbsr031.atdcstvlr is null  then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Pesquisa nome de guerra do prestador
    #---------------------------------------------------------------
    open  c_guerra using d_bdbsr031.atdprscod
    fetch c_guerra into  d_bdbsr031.nomrazsoc,
                         d_bdbsr031.nomgrr   ,
                         d_bdbsr031.endcid   ,
                         d_bdbsr031.endufd   ,
                         d_bdbsr031.endcep   ,
                         ws.vlrtabflg

    if sqlca.sqlcode <> 0  then
       display "Erro (", sqlca.sqlcode, ") na localizacao do prestador ", d_bdbsr031.atdprscod using "&&&&&&", ". AVISE A INFORMATICA!"
       return
    end if
    close c_guerra

    if ( ws.atdetpcod =  6  or ws.atdetpcod =  5  ) and
       d_bdbsr031.nomgrr is null then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Informacoes para relatorio de assistencia a passageiros
    #---------------------------------------------------------------
    if d_bdbsr031.atdsrvorg =  3   or
       d_bdbsr031.atdsrvorg =  2   then
       open  c_passageiro   using ws.atdsrvnum, ws.atdsrvano
       fetch c_passageiro   into  d_bdbsr031.pasqtd
       close c_passageiro
    end if

    #---------------------------------------------------------------
    # Identifica tipo de prestador (sempre FROTA)
    #---------------------------------------------------------------
    if d_bdbsr031.atdprscod = 1  or
       d_bdbsr031.atdprscod = 4  or
       d_bdbsr031.atdprscod = 8  then
       let d_bdbsr031.atdprstip = 1
    else
       if ws.vlrtabflg = "S"  then
          let d_bdbsr031.atdprstip = 2
       else
          let d_bdbsr031.atdprstip = 3
       end if
    end if

    output to report rep_prssrv(d_bdbsr031.*)

 end foreach

 finish report  rep_prssrv
 finish report  rep_totais
 finish report  rep_taxi

 if ws_periodo  =  2   then
    finish report  arq_totais
 end if

end function   ###  bdbsr031


#---------------------------------------------------------------------------
 report rep_prssrv(d_bdbsr031)
#---------------------------------------------------------------------------

 define d_bdbsr031    record
    atdprscod         like datmservico.atdprscod,
    atdprstip         smallint,
    nomrazsoc         like dpaksocor.nomrazsoc,
    nomgrr            like dpaksocor.nomgrr,
    endcid            like dpaksocor.endcid,
    endufd            like dpaksocor.endufd,
    endcep            like dpaksocor.endcep,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    pasqtd            smallint,
    asitipcod         like datmservico.asitipcod
 end record

 define r_bdbsr031    record
    remqtd            dec (06,0)                 ,
    socqtd            dec (06,0)                 ,
    dafqtd            dec (06,0)                 ,
    rptqtd            dec (06,0)                 ,
    repqtd            dec (06,0)                 ,
    grlqtd            dec (06,0)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    remvlr            dec (13,2)                 ,
    socvlr            dec (13,2)                 ,
    dafvlr            dec (13,2)                 ,
    rptvlr            dec (13,2)                 ,
    repvlr            dec (13,2)                 ,
    grlvlr            dec (13,2)
 end record

 define p_bdbsr031    record
    taxqtd            dec (06,0)                 ,
    taxvlr            dec (13,2)                 ,
    hosqtd            dec (06,0)                 ,
    hosvlr            dec (13,2)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    pasqtd            dec (06,0)                 ,
    grupo             smallint
 end record

 define ws            record
    srvtotcst         dec (13,2)
 end record

   output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  099

   order by  d_bdbsr031.atdprstip,
             d_bdbsr031.atdprscod

   format

      before group of d_bdbsr031.atdprscod
         let r_bdbsr031.remqtd = 0
         let r_bdbsr031.socqtd = 0
         let r_bdbsr031.dafqtd = 0
         let r_bdbsr031.rptqtd = 0
         let r_bdbsr031.repqtd = 0
         let r_bdbsr031.grlqtd = 0
         let r_bdbsr031.medcst = 0
         let r_bdbsr031.maxcst = 0
         let r_bdbsr031.remvlr = 0
         let r_bdbsr031.socvlr = 0
         let r_bdbsr031.dafvlr = 0
         let r_bdbsr031.rptvlr = 0
         let r_bdbsr031.repvlr = 0
         let r_bdbsr031.grlvlr = 0

         let p_bdbsr031.taxqtd = 0
         let p_bdbsr031.taxvlr = 0
         let p_bdbsr031.hosqtd = 0
         let p_bdbsr031.hosvlr = 0
         let p_bdbsr031.medcst = 0
         let p_bdbsr031.maxcst = 0
         let p_bdbsr031.pasqtd = 0

         let ws.srvtotcst      = 0

         initialize r_bdbsr031.mincst to null
         initialize p_bdbsr031.mincst to null

      after  group of d_bdbsr031.atdprscod
         let r_bdbsr031.medcst = (ws.srvtotcst / r_bdbsr031.grlqtd)

         if r_bdbsr031.mincst is null then
            let r_bdbsr031.mincst = 0
         end if


         if p_bdbsr031.mincst is null then
            let p_bdbsr031.mincst = 0
         end if

         if r_bdbsr031.grlqtd > 0  then
            output to report rep_totais(d_bdbsr031.atdprscod thru d_bdbsr031.endcid, r_bdbsr031.*)

            if d_bdbsr031.atdprscod > 10  then
               if ws_periodo  =  2   then
                  output to report arq_totais(d_bdbsr031.atdprscod thru d_bdbsr031.endcep, r_bdbsr031.*)
               end if
            end if
         end if

         if p_bdbsr031.taxqtd > 0 then
            let p_bdbsr031.grupo = 1
            let p_bdbsr031.medcst = (p_bdbsr031.taxvlr / p_bdbsr031.taxqtd)
            output to report rep_taxi(d_bdbsr031.atdprscod thru d_bdbsr031.endcid, p_bdbsr031.*)
         end if

         if p_bdbsr031.hosqtd > 0 then
            let p_bdbsr031.grupo = 2
            let p_bdbsr031.medcst = (p_bdbsr031.hosvlr / p_bdbsr031.hosqtd)
            output to report rep_taxi(d_bdbsr031.atdprscod thru d_bdbsr031.endcid, p_bdbsr031.*)
         end if

      on every row
         case d_bdbsr031.atdsrvorg
            when  4         # Remocoes
               let r_bdbsr031.remqtd = r_bdbsr031.remqtd + 1
               let r_bdbsr031.remvlr = r_bdbsr031.remvlr + d_bdbsr031.atdcstvlr
            when  6         # DAF
               let r_bdbsr031.dafqtd = r_bdbsr031.dafqtd + 1
               let r_bdbsr031.dafvlr = r_bdbsr031.dafvlr + d_bdbsr031.atdcstvlr
            when  1         # Porto Socorro
               let r_bdbsr031.socqtd = r_bdbsr031.socqtd + 1
               let r_bdbsr031.socvlr = r_bdbsr031.socvlr + d_bdbsr031.atdcstvlr
            when  5         # RPT
               let r_bdbsr031.rptqtd = r_bdbsr031.rptqtd + 1
               let r_bdbsr031.rptvlr = r_bdbsr031.rptvlr + d_bdbsr031.atdcstvlr
            when  7         # Replace
               let r_bdbsr031.repqtd = r_bdbsr031.repqtd + 1
               let r_bdbsr031.repvlr = r_bdbsr031.repvlr + d_bdbsr031.atdcstvlr
            when  2         # Assistencia a Passageiros
               let p_bdbsr031.taxqtd = p_bdbsr031.taxqtd + 1
               let p_bdbsr031.taxvlr = p_bdbsr031.taxvlr + d_bdbsr031.atdcstvlr
               let p_bdbsr031.pasqtd = p_bdbsr031.pasqtd + d_bdbsr031.pasqtd
               case d_bdbsr031.asitipcod
                 when  5      # Taxi
                  let ws_pas[1].qtdsrv = ws_pas[1].qtdsrv + 1
                  let ws_pas[1].qtdpas = ws_pas[1].qtdpas + d_bdbsr031.pasqtd
                  let ws_pas[1].totvlr = ws_pas[1].totvlr + d_bdbsr031.atdcstvlr
                 when 10      # Aviao
                  let ws_pas[2].qtdsrv = ws_pas[2].qtdsrv + 1
                  let ws_pas[2].qtdpas = ws_pas[2].qtdpas + d_bdbsr031.pasqtd
                  let ws_pas[2].totvlr = ws_pas[2].totvlr + d_bdbsr031.atdcstvlr
                 when 16      # Rodoviario
                  let ws_pas[3].qtdsrv = ws_pas[3].qtdsrv + 1
                  let ws_pas[3].qtdpas = ws_pas[3].qtdpas + d_bdbsr031.pasqtd
                  let ws_pas[3].totvlr = ws_pas[3].totvlr + d_bdbsr031.atdcstvlr
                 when 11      # Ambulancia
                  let ws_pas[4].qtdsrv = ws_pas[4].qtdsrv + 1
                  let ws_pas[4].qtdpas = ws_pas[4].qtdpas + d_bdbsr031.pasqtd
                  let ws_pas[4].totvlr = ws_pas[4].totvlr + d_bdbsr031.atdcstvlr
                 when 12      # Translado
                  let ws_pas[5].qtdsrv = ws_pas[5].qtdsrv + 1
                  let ws_pas[5].qtdpas = ws_pas[5].qtdpas + d_bdbsr031.pasqtd
                  let ws_pas[5].totvlr = ws_pas[5].totvlr + d_bdbsr031.atdcstvlr
               end case
            when 3          # despesa com acomodacao
                  let p_bdbsr031.hosqtd = p_bdbsr031.hosqtd + 1
                  let p_bdbsr031.hosvlr = p_bdbsr031.hosvlr
                                        + d_bdbsr031.atdcstvlr

                  if d_bdbsr031.asitipcod =  13  then      # Hospedagem
                     let ws_pas[6].qtdsrv = ws_pas[6].qtdsrv + 1
                     #let ws_pas[6].qtdpas = ws_pas[6].qtdpas +d_bdbsr031.pasqtd
                     let ws_pas[6].totvlr = ws_pas[6].totvlr
                                          + d_bdbsr031.atdcstvlr
                  end if

         end case

         if d_bdbsr031.atdsrvorg <>  2   then
            let r_bdbsr031.grlqtd = r_bdbsr031.grlqtd + 1
            let r_bdbsr031.grlvlr = r_bdbsr031.grlvlr + d_bdbsr031.atdcstvlr

            let ws.srvtotcst = ws.srvtotcst + d_bdbsr031.atdcstvlr

            if d_bdbsr031.atdcstvlr > r_bdbsr031.maxcst  then
               let r_bdbsr031.maxcst = d_bdbsr031.atdcstvlr
            end if

            if d_bdbsr031.atdcstvlr < r_bdbsr031.mincst  or
               r_bdbsr031.mincst is null                 then
               let r_bdbsr031.mincst = d_bdbsr031.atdcstvlr
            end if
         else
            if d_bdbsr031.atdcstvlr > p_bdbsr031.maxcst  then
               let p_bdbsr031.maxcst = d_bdbsr031.atdcstvlr
            end if

            if d_bdbsr031.atdcstvlr < p_bdbsr031.mincst  or
               p_bdbsr031.mincst is null                 then
               let p_bdbsr031.mincst = d_bdbsr031.atdcstvlr
            end if
         end if

end report    ### rep_prssrv


#---------------------------------------------------------------------------
 report rep_totais(r_bdbsr031)
#---------------------------------------------------------------------------

 define r_bdbsr031    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomrazsoc         like dpaksocor.nomrazsoc   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (20)                  ,
    remqtd            dec (06,0)                 ,
    socqtd            dec (06,0)                 ,
    dafqtd            dec (06,0)                 ,
    rptqtd            dec (06,0)                 ,
    repqtd            dec (06,0)                 ,
    grlqtd            dec (06,0)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    remvlr            dec (13,2)                 ,
    socvlr            dec (13,2)                 ,
    dafvlr            dec (13,2)                 ,
    rptvlr            dec (13,2)                 ,
    repvlr            dec (13,2)                 ,
    grlvlr            dec (13,2)
 end record

 define a_total       array[04] of record
    prstip            char (12)                  ,
    remqtd            dec (06,0)                 ,
    socqtd            dec (06,0)                 ,
    dafqtd            dec (06,0)                 ,
    rptqtd            dec (06,0)                 ,
    repqtd            dec (06,0)                 ,
    grlqtd            dec (06,0)                 ,
    remvlr            dec (13,2)                 ,
    socvlr            dec (13,2)                 ,
    dafvlr            dec (13,2)                 ,
    rptvlr            dec (13,2)                 ,
    repvlr            dec (13,2)                 ,
    grlvlr            dec (13,2)
 end record

 define arr_aux       smallint
 define total         smallint

 define ws            record
   fimflg             smallint,
   percent            smallfloat
 end record

 define linha1        char(160),
        linha2        char(160)

 output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr031.atdprstip  ,
             r_bdbsr031.grlqtd desc,
             r_bdbsr031.grlvlr desc

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03101 FORMNAME=BRANCO"        # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - TOTAIS DE SERVICOS PAGOS POR TIPO/PRESTADOR"
            print "$DJDE$ JDL=XJ6531, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
            print ascii(12)

            let ws.fimflg = false

            let total = 4

            let a_total[01].prstip = "FROTA"
            let a_total[02].prstip = "TABELA"
            let a_total[03].prstip = "OUTROS"
            let a_total[04].prstip = "TOTAL GERAL"

            for arr_aux = 1  to  04
               let a_total[arr_aux].remqtd   = 0
               let a_total[arr_aux].socqtd   = 0
               let a_total[arr_aux].dafqtd   = 0
               let a_total[arr_aux].rptqtd   = 0
               let a_total[arr_aux].repqtd   = 0
               let a_total[arr_aux].grlqtd   = 0

               let a_total[arr_aux].remvlr   = 0
               let a_total[arr_aux].socvlr   = 0
               let a_total[arr_aux].dafvlr   = 0
               let a_total[arr_aux].rptvlr   = 0
               let a_total[arr_aux].repvlr   = 0
               let a_total[arr_aux].grlvlr   = 0
            end for

            let linha1 = column 005, ws_traco156
            let linha2 = column 005, "CODIGO"     ,
                         column 012, "PRESTADOR"  ,
                         column 034, "CIDADE"     ,
                         column 055, "REMOCOES"   ,
                         column 069, "SOCORRO"    ,
                         column 081, " D.A.F."    ,
                         column 091, " R.P.T."    ,
                         column 102, "REPLACE"    ,
                         column 117, "TOTAL"      ,
                         column 124, "CUSTO MEDIO",
                         column 137, "MENOR VALOR",
                         column 150, "MAIOR VALOR"
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         skip 2 lines
         print column 128, "RDBS031-01",
               column 142, "PAGINA : "  , pageno using "##,###,##&"
         print column 045, "SERVICOS PAGOS NO PERIODO DE ", ws_data_de, " A ", ws_data_ate,
               column 142, "DATA   : "  , today
         print column 142, "HORA   :   ", time
         skip 4 lines

         let arr_aux = r_bdbsr031.atdprstip
         if ws.fimflg = true  then
            print column 005, "PRESTADOR: TODOS"
         else
            print column 005, "PRESTADOR: ", a_total[arr_aux].prstip
         end if
         skip 1 lines
         print linha1
         print linha2
         print linha1

      before group of r_bdbsr031.atdprstip
         skip to top of page

      after  group of r_bdbsr031.atdprstip
         skip 2 lines
         print column 005, ws_traco156
         need 2 lines
         print column 005, "QUANTIDADE TOTAL DE SERVICOS ...............: ",
               column 057, a_total[arr_aux].remqtd     using "##,##&" ,
               column 070, a_total[arr_aux].socqtd     using "##,##&" ,
               column 081, a_total[arr_aux].dafqtd     using "##,##&" ,
               column 092, a_total[arr_aux].rptqtd     using "##,##&" ,
               column 103, a_total[arr_aux].repqtd     using "##,##&" ,
               column 115, a_total[arr_aux].grlqtd     using "###,##&"

         print column 005, "VALOR TOTAL DE SERVICOS ....................: ",
               column 051, a_total[arr_aux].remvlr     using "#,###,##&.&&" ,
               column 064, a_total[arr_aux].socvlr     using "#,###,##&.&&" ,
               column 077, a_total[arr_aux].dafvlr     using "###,##&.&&" ,
               column 088, a_total[arr_aux].rptvlr     using "###,##&.&&" ,
               column 099, a_total[arr_aux].repvlr     using "###,##&.&&" ,
               column 110, a_total[arr_aux].grlvlr     using "#,###,##&.&&"
         skip 1 line

         let a_total[total].remqtd = a_total[total].remqtd + a_total[arr_aux].remqtd
         let a_total[total].socqtd = a_total[total].socqtd + a_total[arr_aux].socqtd
         let a_total[total].dafqtd = a_total[total].dafqtd + a_total[arr_aux].dafqtd
         let a_total[total].rptqtd = a_total[total].rptqtd + a_total[arr_aux].rptqtd
         let a_total[total].repqtd = a_total[total].repqtd + a_total[arr_aux].repqtd
         let a_total[total].grlqtd = a_total[total].grlqtd + a_total[arr_aux].grlqtd

         let a_total[total].remvlr = a_total[total].remvlr + a_total[arr_aux].remvlr
         let a_total[total].socvlr = a_total[total].socvlr + a_total[arr_aux].socvlr
         let a_total[total].dafvlr = a_total[total].dafvlr + a_total[arr_aux].dafvlr
         let a_total[total].rptvlr = a_total[total].rptvlr + a_total[arr_aux].rptvlr
         let a_total[total].repvlr = a_total[total].repvlr + a_total[arr_aux].repvlr
         let a_total[total].grlvlr = a_total[total].grlvlr + a_total[arr_aux].grlvlr

      on every row
         let a_total[arr_aux].remqtd = a_total[arr_aux].remqtd + r_bdbsr031.remqtd
         let a_total[arr_aux].socqtd = a_total[arr_aux].socqtd + r_bdbsr031.socqtd
         let a_total[arr_aux].dafqtd = a_total[arr_aux].dafqtd + r_bdbsr031.dafqtd
         let a_total[arr_aux].rptqtd = a_total[arr_aux].rptqtd + r_bdbsr031.rptqtd
         let a_total[arr_aux].repqtd = a_total[arr_aux].repqtd + r_bdbsr031.repqtd
         let a_total[arr_aux].grlqtd = a_total[arr_aux].grlqtd + r_bdbsr031.grlqtd

         let a_total[arr_aux].remvlr = a_total[arr_aux].remvlr + r_bdbsr031.remvlr
         let a_total[arr_aux].socvlr = a_total[arr_aux].socvlr + r_bdbsr031.socvlr
         let a_total[arr_aux].dafvlr = a_total[arr_aux].dafvlr + r_bdbsr031.dafvlr
         let a_total[arr_aux].rptvlr = a_total[arr_aux].rptvlr + r_bdbsr031.rptvlr
         let a_total[arr_aux].repvlr = a_total[arr_aux].repvlr + r_bdbsr031.repvlr
         let a_total[arr_aux].grlvlr = a_total[arr_aux].grlvlr + r_bdbsr031.grlvlr

         need 2 lines
         print column 005, r_bdbsr031.atdprscod  using "&&&&&&"      ,
               column 012, r_bdbsr031.nomgrr                         ,
               column 034, r_bdbsr031.endcid                         ,
               column 057, r_bdbsr031.remqtd     using "##,##&"      ,
               column 070, r_bdbsr031.socqtd     using "##,##&"      ,
               column 081, r_bdbsr031.dafqtd     using "##,##&"      ,
               column 092, r_bdbsr031.rptqtd     using "##,##&"      ,
               column 103, r_bdbsr031.repqtd     using "##,##&"      ,
               column 115, r_bdbsr031.grlqtd     using "###,##&"     ,
               column 125, r_bdbsr031.medcst     using "###,##&.&&"  ,
               column 138, r_bdbsr031.mincst     using "###,##&.&&"  ,
               column 151, r_bdbsr031.maxcst     using "###,##&.&&"
         print column 051, r_bdbsr031.remvlr     using "#,###,##&.&&",
               column 064, r_bdbsr031.socvlr     using "#,###,##&.&&",
               column 077, r_bdbsr031.dafvlr     using "###,##&.&&"  ,
               column 088, r_bdbsr031.rptvlr     using "###,##&.&&"  ,
               column 099, r_bdbsr031.repvlr     using "###,##&.&&"  ,
               column 110, r_bdbsr031.grlvlr     using "#,###,##&.&&"
         skip 1 line

      on last row
         let ws.fimflg = true
         let linha1 = " "
         let linha2 = " "
         skip to top of page
         skip 3 lines
         print column 018, "QUANTIDADE DE SERVICOS"
         print column 017, ws_duplo
         print column 018, "PRESTADOR"  ,
               column 044, "REMOCOES"   ,
               column 056, "SOCORRO"    ,
               column 068, "D.A.F."     ,
               column 079, "R.P.T."     ,
               column 089, "REPLACE"    ,
               column 102, "TOTAL DE SERVICOS"
         print column 017, ws_duplo

         for arr_aux = 01  to  04
            let ws.percent = 0
            let ws.percent = ( a_total[arr_aux].grlqtd / a_total[total].grlqtd) * 100

            if arr_aux = 04  then
               print column 017, ws_duplo
            end if

            print column 019, a_total[arr_aux].prstip                  ,
                  column 045, a_total[arr_aux].remqtd  using "###,##&" ,
                  column 056, a_total[arr_aux].socqtd  using "###,##&" ,
                  column 067, a_total[arr_aux].dafqtd  using "###,##&" ,
                  column 078, a_total[arr_aux].rptqtd  using "###,##&" ,
                  column 089, a_total[arr_aux].repqtd  using "###,##&" ,
                  column 100, a_total[arr_aux].grlqtd  using "###,##&" ,
                         "  -  (" ,  ws.percent        using "##&.&&%" , ")"
         end for

         let ws.percent = 0
         let ws.percent = ( a_total[total].remqtd / a_total[total].grlqtd) * 100
         print column 045, ws.percent        using "##&.&&%" ;
         let ws.percent = 0
         let ws.percent = ( a_total[total].socqtd / a_total[total].grlqtd) * 100
         print column 056, ws.percent        using "##&.&&%" ;
         let ws.percent = 0
         let ws.percent = ( a_total[total].dafqtd / a_total[total].grlqtd) * 100
         print column 067, ws.percent        using "##&.&&%" ;
         let ws.percent = 0
         let ws.percent = ( a_total[total].rptqtd / a_total[total].grlqtd) * 100
         print column 078, ws.percent        using "##&.&&%" ;
         let ws.percent = 0
         let ws.percent = ( a_total[total].repqtd / a_total[total].grlqtd) * 100
         print column 089, ws.percent        using "##&.&&%"

         skip 6 lines
         print column 018, "VALOR DOS SERVICOS"
         print column 017, ws_duplo
         print column 018, "PRESTADOR"  ,
               column 047, "REMOCOES"   ,
               column 062, "SOCORRO"    ,
               column 077, "D.A.F."     ,
               column 091, "R.P.T."     ,
               column 104, "REPLACE"    ,
               column 114, "VALOR TOTAL"
         print column 017, ws_duplo

         for arr_aux = 01  to  04
            if arr_aux = 04  then
               print column 017, ws_duplo
            end if

            print column 019, a_total[arr_aux].prstip                        ,
                  column 042, a_total[arr_aux].remvlr  using "##,###,##&.&&" ,
                  column 056, a_total[arr_aux].socvlr  using "##,###,##&.&&" ,
                  column 070, a_total[arr_aux].dafvlr  using "##,###,##&.&&" ,
                  column 084, a_total[arr_aux].rptvlr  using "##,###,##&.&&" ,
                  column 098, a_total[arr_aux].repvlr  using "##,###,##&.&&" ,
                  column 112, a_total[arr_aux].grlvlr  using "##,###,##&.&&"
         end for

         print "$FIMREL$"

end report   ### rep_totais


#---------------------------------------------------------------------------
 report arq_totais(r_bdbsr031)
#---------------------------------------------------------------------------

 define r_bdbsr031    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomrazsoc         like dpaksocor.nomrazsoc   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            like dpaksocor.endcid      ,
    endufd            like dpaksocor.endufd      ,
    endcep            like dpaksocor.endcep      ,
    remqtd            dec (06,0)                 ,
    socqtd            dec (06,0)                 ,
    dafqtd            dec (06,0)                 ,
    rptqtd            dec (06,0)                 ,
    repqtd            dec (06,0)                 ,
    grlqtd            dec (06,0)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    remvlr            dec (13,2)                 ,
    socvlr            dec (13,2)                 ,
    dafvlr            dec (13,2)                 ,
    rptvlr            dec (13,2)                 ,
    repvlr            dec (13,2)                 ,
    grlvlr            dec (13,2)
 end record

   output
      left   margin  000
      right  margin  001
      top    margin  000
      bottom margin  000
      page   length  099

   order by  r_bdbsr031.atdprscod ,
             r_bdbsr031.grlqtd desc

   format
      on every row
         print r_bdbsr031.atdprscod  using "&&&&&&"      , "|",
               r_bdbsr031.nomrazsoc                      , "|",
               r_bdbsr031.nomgrr                         , "|",
               r_bdbsr031.endcid                         , "|",
               r_bdbsr031.endufd                         , "|",
               r_bdbsr031.endcep                         , "|",
               r_bdbsr031.remqtd     using "##,##&"      , "|",
               r_bdbsr031.remvlr     using "#,###,##&.&&", "|",
               r_bdbsr031.dafqtd     using "##,##&"      , "|",
               r_bdbsr031.dafvlr     using "###,##&.&&"  , "|",
               r_bdbsr031.socqtd     using "##,##&"      , "|",
               r_bdbsr031.socvlr     using "#,###,##&.&&", "|",
               r_bdbsr031.rptqtd     using "##,##&"      , "|",
               r_bdbsr031.rptvlr     using "###,##&.&&"  , "|",
               r_bdbsr031.repqtd     using "##,##&"      , "|",
               r_bdbsr031.repvlr     using "###,##&.&&"  , "|",
               r_bdbsr031.grlqtd     using "###,##&"     , "|",
               r_bdbsr031.grlvlr     using "#,###,##&.&&", "|",
               r_bdbsr031.medcst     using "###,##&.&&"  , "|",
               r_bdbsr031.mincst     using "###,##&.&&"  , "|",
               r_bdbsr031.maxcst     using "###,##&.&&"

end report   ### arq_totais


#---------------------------------------------------------------------------
 report rep_taxi(r_bdbsr031)
#---------------------------------------------------------------------------

 define r_bdbsr031    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomrazsoc         like dpaksocor.nomrazsoc   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (20)                  ,
    taxqtd            dec (06,0)                 ,
    taxvlr            dec (13,2)                 ,
    hosqtd            dec (06,0)                 ,
    hosvlr            dec (13,2)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    pasqtd            dec (06,0)                 ,
    grupo             smallint
 end record

 define ws            record
    totqtd            dec (06,0)   ,
    totvlr            dec (13,2)   ,
    pastotqtd         dec (06,0)   ,
    qtd               dec (06,0)   ,
    vlr               dec (13,2)
 end record

 define ws_x          smallint

 output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr031.grupo,
             r_bdbsr031.taxqtd desc,
             r_bdbsr031.taxvlr desc,
             r_bdbsr031.hosqtd desc,
             r_bdbsr031.hosvlr desc

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03102 FORMNAME=BRANCO"         # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - ASSISTENCIAS A PASSAGEIROS PAGAS POR PRESTADOR"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
            print ascii(12)

            let ws.totqtd = 0
            let ws.totvlr = 0
            let ws.pastotqtd = 0
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 099, "RDAT031-02",
               column 113, "PAGINA : "  , pageno using "##,###,##&"
         print column 022, "ASSISTENCIAS A PASSAGEIROS PAGAS NO PERIODO DE ", ws_data_de, " A ", ws_data_ate,
               column 113, "DATA   : "  , today
         print column 113, "HORA   :   ", time

      before group of r_bdbsr031.grupo
         let ws.totqtd = 0
         let ws.totvlr = 0
         let ws.pastotqtd = 0

	 skip 2 lines
         if r_bdbsr031.grupo = 1 then
            print column 001, "TRANSPORTE"
         else
            print column 001, "HOSPEDAGEM"
         end if
         print column 001, ws_traco132
         print column 001, "CODIGO"     ,
               column 010, "PRESTADOR"  ,
               column 033, "CIDADE"     ,
               column 055, "SERVICOS"   ,
               column 066, "PASSAG."    ,
               column 076, "VALOR TOTAL",
               column 090, "CUSTO MEDIO",
               column 104, "MENOR VALOR",
               column 118, "MAIOR VALOR"
         print column 001, ws_traco132

     after group of r_bdbsr031.grupo
         skip 1 lines
         print column 001, ws_traco132
         print column 001, "TOTAL GERAL: ",
               column 056, ws.totqtd  using "###,##&"     ,
               column 066, ws.pastotqtd  using "###,##&"     ,
               column 075, ws.totvlr  using "#,###,##&.&&"
         skip 1 lines

     on every row
         if r_bdbsr031.grupo = 1 then
            let ws.qtd = r_bdbsr031.taxqtd
            let ws.vlr = r_bdbsr031.taxvlr
         else
            let ws.qtd = r_bdbsr031.hosqtd
            let ws.vlr = r_bdbsr031.hosvlr
         end if
         print column 001, r_bdbsr031.atdprscod  using "&&&&&&"    ,
               column 010, r_bdbsr031.nomgrr                       ,
               column 033, r_bdbsr031.endcid                       ,
               column 056, ws.qtd                using "###,##&"   ,
               column 066, r_bdbsr031.pasqtd     using "###,##&"   ,
               column 077, ws.vlr                using "###,##&.&&",
               column 091, r_bdbsr031.medcst     using "###,##&.&&",
               column 105, r_bdbsr031.mincst     using "###,##&.&&",
               column 119, r_bdbsr031.maxcst     using "###,##&.&&"
         skip 1 line
         let ws.totqtd = ws.totqtd + ws.qtd
         let ws.totvlr = ws.totvlr + ws.vlr
         let ws.pastotqtd = ws.pastotqtd + r_bdbsr031.pasqtd

      on last row

         skip 2 lines
         let ws.vlr =0
         for ws_x = 1 to 6
             print column 001, "TOTAL ",ws_pas[ws_x].asitipdes ," : ",
                   column 056, ws_pas[ws_x].qtdsrv  using "###,##&"     ,
                   column 066, ws_pas[ws_x].qtdpas  using "###,##&"     ,
                   column 075, ws_pas[ws_x].totvlr  using "#,###,##&.&&"
             let ws.vlr = ws.vlr + ws_pas[ws_x].totvlr
         end for
         print column 001, ws_traco132
         print column 001, "TOTAL ",
                   column 075, ws.vlr               using "#,###,##&.&&"

         print "$FIMREL$"

 end report   ### rep_taxi
