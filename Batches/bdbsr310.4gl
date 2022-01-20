############################################################################
# Nome do Modulo: bdbsr310                                                 #
#                                                                          #
# Relatorio mensal de total de servicos pagos por prestador       Nov/2001 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 25/07/2001 PSI 1355226 Rodrigo Santos Troca de relatorios por arquivos   #
#--------------------------------------------------------------------------#
# 11/11/2001 PSI 1355226   Wagner       Acertos em geral.                  #
#--------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/#
#                                       Roberto Costa.                     #
############################################################################
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
#-----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto


 define ws_data_de     date,
        ws_data_ate    date,
        ws_data_aux    char(10),
        ws_flgcab1     integer,
        ws_flgcab2     integer

 main
    call fun_dba_abre_banco("CT24HS")
    call bdbsr310()
 end main

#---------------------------------------------------------------
 function bdbsr310()
#---------------------------------------------------------------

 define d_bdbsr310    record
    atdprscod         like datmservico.atdprscod,
    atdprstip         smallint,
    nomrazsoc         like dpaksocor.nomrazsoc,
    nomgrr            like dpaksocor.nomgrr,
    endcid            like dpaksocor.endcid,
    endbrr            like dpaksocor.endbrr,
    endufd            like dpaksocor.endufd,
    endcep            like dpaksocor.endcep,
    qldgracod         like dpaksocor.qldgracod,
    cpodes            like iddkdominio.cpodes,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    pasqtd            smallint,
    asitipcod         like datmservico.asitipcod
 end record

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdfnlflg         like datmservico.atdfnlflg,
    atdetpcod         like datmsrvacp.atdetpcod,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02         char (60),
    executa           char (500)
 end record

 define sql_select    char(300)
 define l_retorno     smallint                                # Marcio Meta - PSI185035


 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 initialize d_bdbsr310.*  to null
 initialize ws.*          to null

 let ws_flgcab1 = 0
 let ws_flgcab2 = 0

 #---------------------------------------------------------------
 # Preparacao dos comandos SQL
 #---------------------------------------------------------------
 let sql_select = "select nomrazsoc, nomgrr, endcid,    ",
                  "       endufd   , endcep, vlrtabflg, ",
                  "       endbrr, qldgracod             ",
                  "  from dpaksocor where pstcoddig = ? "
 prepare sel_guerra from sql_select
 declare c_guerra cursor for sel_guerra

 let sql_select = "select count(*) ",
                  "  from datmpassageiro   ",
                  " where atdsrvnum = ? and",
                  "       atdsrvano = ?    "
 prepare sel_passageiro from sql_select
 declare c_passageiro cursor for sel_passageiro

 let sql_select = "select cpodes "
                 ,"  from iddkdominio "
                 ," where cponom = 'qldgracod' "
                 ,"   and cpocod = ? "

 prepare p_qualid from sql_select
 declare c_qualid cursor for p_qualid

 #---------------------------------------------------------------
 # Define o periodo de extracao
 #---------------------------------------------------------------
 let ws_data_aux = arg_val(1)

 if ws_data_aux is null       or
    ws_data_aux =  "  "       then
    let ws_data_aux = today
 else
    if length(ws_data_aux) < 10  then
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
#WWWX call f_path("DAT", "RELATO")
#WWWX      returning ws.dirfisnom

#WWWX -->teste
#let ws.dirfisnom = "/rdat"
#WWWX --
                                                                     # Marcio Meta - PSI185035
 call f_path("DBS", "ARQUIVO")
    returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS31001.TXT"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS31002.TXT"
                                                                     # Marcio Meta - PSI185035
 #---------------------------------------------------------------
 # Definicao de cursores para extracao
 #---------------------------------------------------------------
 declare  c_bdbsr310  cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdprscod,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr,
           datmservico.asitipcod
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between  ws_data_de and ws_data_ate
       and dbsmopg.socopgsitcod   =  7
       and dbsmopg.soctip         =  1
       and dbsmopgitm.socopgnum   =  dbsmopg.socopgnum
       and datmservico.atdsrvnum  =  dbsmopgitm.atdsrvnum
       and datmservico.atdsrvano  =  dbsmopgitm.atdsrvano

 start report  rep_prssrv  to  ws.pathrel01
 start report  rep_prsvlr  to  ws.pathrel01
 start report  rep_pasvlr  to  ws.pathrel02

 #---------------------------------------------------------------
 # Extracao dos servicos pagos no periodo
 #---------------------------------------------------------------
 foreach c_bdbsr310  into  ws.atdsrvnum        ,
                           ws.atdsrvano        ,
                           d_bdbsr310.atdprscod,
                           d_bdbsr310.atdsrvorg,
                           d_bdbsr310.atdcstvlr,
                           d_bdbsr310.asitipcod

    if d_bdbsr310.atdsrvorg  = 10    or    # Vistoria Previa Domiciliar
       d_bdbsr310.atdsrvorg  = 11    or    # Aviso Furto/Roubo
       d_bdbsr310.atdsrvorg  = 12    or    # Servico de Apoio
       d_bdbsr310.atdsrvorg  =  8    then  # Reserva Carro Extra
       continue foreach
    end if

    if d_bdbsr310.atdcstvlr is null  then
       let d_bdbsr310.atdcstvlr = 0
    end if

    #---------------------------------------------------------------
    # Informacoes para relatorio de assistencia a passageiros
    #---------------------------------------------------------------
    let d_bdbsr310.pasqtd = 0
    if d_bdbsr310.atdsrvorg =  3   or
       d_bdbsr310.atdsrvorg =  2   then
       open  c_passageiro   using ws.atdsrvnum, ws.atdsrvano
       fetch c_passageiro   into  d_bdbsr310.pasqtd
       close c_passageiro
    end if

    output to report rep_prssrv(d_bdbsr310.*)

 end foreach

 finish report  rep_prssrv
 finish report  rep_prsvlr
 finish report  rep_pasvlr
                                                            # Marcio Meta - PSI185035
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
 let ws.executa = ' PSocorro mensal pagos '

 let l_retorno = ctx22g00_envia_email('BDBSR310',
                                       ws.executa,
                                       ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel01
    else
       display " Email nao encontrado para este modulo BDBSR310 "
    end if
 end if

 let ws.executa = 'Ass.Pass. mensal pagos '

 let l_retorno = ctx22g00_envia_email('BDBSR310',
                                       ws.executa,
                                       ws.pathrel02)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel02
    else
       display " Email nao encontrado para este modulo BDBSR310 "
    end if
 end if

                                                               # Marcio Meta - PSI185035
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'PSocorro mensal pagos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#               ws.pathrel01 clipped
# run ws.executa
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'PSocorro mensal pagos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#               ws.pathrel01 clipped
# run ws.executa
#
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Ass.Pass. mensal pagos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#               ws.pathrel02 clipped
# run ws.executa
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Ass.Pass. mensal pagos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#               ws.pathrel02 clipped
# run ws.executa
#
end function   ###  bdbsr310


#---------------------------------------------------------------------------
 report rep_prssrv(d_bdbsr310)
#---------------------------------------------------------------------------

 define d_bdbsr310    record
    atdprscod         like datmservico.atdprscod,
    atdprstip         smallint,
    nomrazsoc         like dpaksocor.nomrazsoc,
    nomgrr            like dpaksocor.nomgrr,
    endcid            like dpaksocor.endcid,
    endbrr            like dpaksocor.endbrr,
    endufd            like dpaksocor.endufd,
    endcep            like dpaksocor.endcep,
    qldgracod         like dpaksocor.qldgracod,
    cpodes            like iddkdominio.cpodes,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    pasqtd            smallint,
    asitipcod         like datmservico.asitipcod
 end record

 define r_bdbsr310    record
    remqtd            dec (06,0)                 ,
    socqtd            dec (06,0)                 ,
    dafqtd            dec (06,0)                 ,
    rptqtd            dec (06,0)                 ,
    repqtd            dec (06,0)                 ,
    grlqtd            dec (06,0)                 ,
    guiqtd            dec (06,0)                 ,
    tecqtd            dec (06,0)                 ,
    ambqtd            dec (06,0)                 ,
    sreqtd            dec (06,0)                 ,
    chaqtd            dec (06,0)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    remvlr            dec (13,2)                 ,
    socvlr            dec (13,2)                 ,
    dafvlr            dec (13,2)                 ,
    rptvlr            dec (13,2)                 ,
    repvlr            dec (13,2)                 ,
    grlvlr            dec (13,2)                 ,
    guivlr            dec (13,2)                 ,
    tecvlr            dec (13,2)                 ,
    ambvlr            dec (13,2)                 ,
    srevlr            dec (13,2)                 ,
    chavlr            dec (13,2)
 end record

 define p_bdbsr310    record
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

 define r_ws          record
    txqtdsrv          dec(6,0),
    txvlrsrv          dec(13,2),
    txqtdpas          dec(6,0),
    avqtdsrv          dec(6,0),
    avvlrsrv          dec(13,2),
    avqtdpas          dec(6,0),
    rdqtdsrv          dec(6,0),
    rdvlrsrv          dec(13,2),
    rdqtdpas          dec(6,0),
    abqtdsrv          dec(6,0),
    abvlrsrv          dec(13,2),
    abqtdpas          dec(6,0),
    trqtdsrv          dec(6,0),
    trvlrsrv          dec(13,2),
    trqtdpas          dec(6,0),
    hpqtdsrv          dec(6,0),
    hpvlrsrv          dec(13,2),
    hpqtdpas          dec(6,0)
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

   order by  d_bdbsr310.atdprscod

   format

      before group of d_bdbsr310.atdprscod
         let r_bdbsr310.remqtd = 0
         let r_bdbsr310.socqtd = 0
         let r_bdbsr310.dafqtd = 0
         let r_bdbsr310.rptqtd = 0
         let r_bdbsr310.repqtd = 0
         let r_bdbsr310.grlqtd = 0
         let r_bdbsr310.guiqtd = 0
         let r_bdbsr310.tecqtd = 0
         let r_bdbsr310.ambqtd = 0
         let r_bdbsr310.sreqtd = 0
         let r_bdbsr310.chaqtd = 0
         let r_bdbsr310.medcst = 0
         let r_bdbsr310.maxcst = 0
         let r_bdbsr310.remvlr = 0
         let r_bdbsr310.socvlr = 0
         let r_bdbsr310.dafvlr = 0
         let r_bdbsr310.rptvlr = 0
         let r_bdbsr310.repvlr = 0
         let r_bdbsr310.grlvlr = 0
         let r_bdbsr310.guivlr = 0
         let r_bdbsr310.tecvlr = 0
         let r_bdbsr310.ambvlr = 0
         let r_bdbsr310.srevlr = 0
         let r_bdbsr310.chavlr = 0

         let p_bdbsr310.taxqtd = 0
         let p_bdbsr310.taxvlr = 0
         let p_bdbsr310.hosqtd = 0
         let p_bdbsr310.hosvlr = 0
         let p_bdbsr310.medcst = 0
         let p_bdbsr310.maxcst = 0
         let p_bdbsr310.pasqtd = 0
         let r_ws.txqtdsrv     = 0
         let r_ws.txvlrsrv     = 0
         let r_ws.txqtdpas     = 0
         let r_ws.avqtdsrv     = 0
         let r_ws.avvlrsrv     = 0
         let r_ws.avqtdpas     = 0
         let r_ws.rdqtdsrv     = 0
         let r_ws.rdvlrsrv     = 0
         let r_ws.rdqtdpas     = 0
         let r_ws.abqtdsrv     = 0
         let r_ws.abvlrsrv     = 0
         let r_ws.abqtdpas     = 0
         let r_ws.trqtdsrv     = 0
         let r_ws.trvlrsrv     = 0
         let r_ws.trqtdpas     = 0
         let r_ws.hpqtdsrv     = 0
         let r_ws.hpvlrsrv     = 0
         let r_ws.hpqtdpas     = 0

         let ws.srvtotcst      = 0

         initialize r_bdbsr310.mincst to null
         initialize p_bdbsr310.mincst to null

      after  group of d_bdbsr310.atdprscod

         if r_bdbsr310.grlqtd > 0  then
            output to report rep_prsvlr(d_bdbsr310.atdprscod thru
                                        d_bdbsr310.cpodes,
                                        r_bdbsr310.*,
                                        ws.srvtotcst)
         end if

         if p_bdbsr310.taxqtd > 0 or
            p_bdbsr310.hosqtd > 0 then
            output to report rep_pasvlr(d_bdbsr310.atdprscod thru
                                        d_bdbsr310.cpodes,
                                        p_bdbsr310.*,
                                        ws.srvtotcst,
                                        r_bdbsr310.grlqtd,
                                        r_ws.*)
         end if


      on every row
         case d_bdbsr310.atdsrvorg
            when  1         # Porto Socorro
               let r_bdbsr310.socqtd = r_bdbsr310.socqtd + 1
               let r_bdbsr310.socvlr = r_bdbsr310.socvlr + d_bdbsr310.atdcstvlr
               case d_bdbsr310.asitipcod
                    when  1      # Guincho
                          let r_bdbsr310.guiqtd = r_bdbsr310.guiqtd + 1
                          let r_bdbsr310.guivlr = r_bdbsr310.guivlr +
                                                  d_bdbsr310.atdcstvlr
                    when  2      # Tecnico
                          let r_bdbsr310.tecqtd = r_bdbsr310.tecqtd + 1
                          let r_bdbsr310.tecvlr = r_bdbsr310.tecvlr +
                                                  d_bdbsr310.atdcstvlr
                    when  3      # Ambos
                          let r_bdbsr310.ambqtd = r_bdbsr310.ambqtd + 1
                          let r_bdbsr310.ambvlr = r_bdbsr310.ambvlr +
                                                  d_bdbsr310.atdcstvlr
                    when  4      # Chaveiro
                          let r_bdbsr310.chaqtd = r_bdbsr310.chaqtd + 1
                          let r_bdbsr310.chavlr = r_bdbsr310.chavlr +
                                                  d_bdbsr310.atdcstvlr
                    when  8      # Chaveiro/Dispositivo
                          let r_bdbsr310.chaqtd = r_bdbsr310.chaqtd + 1
                          let r_bdbsr310.chavlr = r_bdbsr310.chavlr +
                                                  d_bdbsr310.atdcstvlr
               end case
            when  2         # Assistencia a Passageiros
               let p_bdbsr310.taxqtd = p_bdbsr310.taxqtd + 1
               case d_bdbsr310.asitipcod
                 when  5      # Taxi
                  let r_ws.txqtdsrv  = r_ws.txqtdsrv + 1
                  let r_ws.txvlrsrv  = r_ws.txvlrsrv + d_bdbsr310.atdcstvlr
                  let r_ws.txqtdpas  = r_ws.txqtdpas + d_bdbsr310.pasqtd
                 when 10      # Aviao
                  let r_ws.avqtdsrv  = r_ws.avqtdsrv + 1
                  let r_ws.avvlrsrv  = r_ws.avvlrsrv + d_bdbsr310.atdcstvlr
                  let r_ws.avqtdpas  = r_ws.avqtdpas + d_bdbsr310.pasqtd
                 when 11      # Ambulancia
                  let r_ws.abqtdsrv  = r_ws.abqtdsrv + 1
                  let r_ws.abvlrsrv  = r_ws.abvlrsrv + d_bdbsr310.atdcstvlr
                  let r_ws.abqtdpas  = r_ws.abqtdpas + d_bdbsr310.pasqtd
                 when 12      # Translado
                  let r_ws.trqtdsrv  = r_ws.trqtdsrv + 1
                  let r_ws.trvlrsrv  = r_ws.trvlrsrv + d_bdbsr310.atdcstvlr
                  let r_ws.trqtdpas  = r_ws.trqtdpas + d_bdbsr310.pasqtd
                 when 16      # Rodoviario
                  let r_ws.rdqtdsrv  = r_ws.rdqtdsrv + 1
                  let r_ws.rdvlrsrv  = r_ws.rdvlrsrv + d_bdbsr310.atdcstvlr
                  let r_ws.rdqtdpas  = r_ws.rdqtdpas + d_bdbsr310.pasqtd
               end case
            when 3          # despesa com acomodacao
                  let p_bdbsr310.hosqtd = p_bdbsr310.hosqtd + 1
                  if d_bdbsr310.asitipcod =  13  then      # Hospedagem
                     let r_ws.hpqtdsrv  = r_ws.hpqtdsrv + 1
                     let r_ws.hpvlrsrv  = r_ws.hpvlrsrv + d_bdbsr310.atdcstvlr
                     let r_ws.hpqtdpas  = r_ws.hpqtdpas + d_bdbsr310.pasqtd
                  end if
            when  4         # Remocoes
               let r_bdbsr310.remqtd = r_bdbsr310.remqtd + 1
               let r_bdbsr310.remvlr = r_bdbsr310.remvlr + d_bdbsr310.atdcstvlr
            when  5         # RPT
               let r_bdbsr310.rptqtd = r_bdbsr310.rptqtd + 1
               let r_bdbsr310.rptvlr = r_bdbsr310.rptvlr + d_bdbsr310.atdcstvlr
            when  6         # DAF
               let r_bdbsr310.dafqtd = r_bdbsr310.dafqtd + 1
               let r_bdbsr310.dafvlr = r_bdbsr310.dafvlr + d_bdbsr310.atdcstvlr
            when  7         # Replace
               let r_bdbsr310.repqtd = r_bdbsr310.repqtd + 1
               let r_bdbsr310.repvlr = r_bdbsr310.repvlr + d_bdbsr310.atdcstvlr
            when  9         # socorro RE
               let r_bdbsr310.sreqtd = r_bdbsr310.sreqtd + 1
               let r_bdbsr310.srevlr = r_bdbsr310.srevlr + d_bdbsr310.atdcstvlr
            when 13         # sinistro RE
               let r_bdbsr310.sreqtd = r_bdbsr310.sreqtd + 1
               let r_bdbsr310.srevlr = r_bdbsr310.srevlr + d_bdbsr310.atdcstvlr
         end case

         if d_bdbsr310.atdsrvorg <>  2   then
            let r_bdbsr310.grlqtd = r_bdbsr310.grlqtd + 1
            let r_bdbsr310.grlvlr = r_bdbsr310.grlvlr + d_bdbsr310.atdcstvlr

            let ws.srvtotcst = ws.srvtotcst + d_bdbsr310.atdcstvlr

            if d_bdbsr310.atdcstvlr > r_bdbsr310.maxcst  then
               let r_bdbsr310.maxcst = d_bdbsr310.atdcstvlr
            end if

            if d_bdbsr310.atdcstvlr < r_bdbsr310.mincst  or
               r_bdbsr310.mincst is null                 then
               let r_bdbsr310.mincst = d_bdbsr310.atdcstvlr
            end if
         else
            if d_bdbsr310.atdcstvlr > p_bdbsr310.maxcst  then
               let p_bdbsr310.maxcst = d_bdbsr310.atdcstvlr
            end if

            if d_bdbsr310.atdcstvlr < p_bdbsr310.mincst  or
               p_bdbsr310.mincst is null                 then
               let p_bdbsr310.mincst = d_bdbsr310.atdcstvlr
            end if
         end if

end report    ### rep_prssrv

#---------------------------------------------------------------------------
 report rep_prsvlr(r_bdbsr310)  # SERVICOS PAGOS (VALORES)  RDAT03101.TXT
#---------------------------------------------------------------------------

 define r_bdbsr310    record
        atdprscod         like datmservico.atdprscod ,
        atdprstip         smallint                   ,
        nomrazsoc         like dpaksocor.nomrazsoc   ,
        nomgrr            like dpaksocor.nomgrr      ,
        endcid            char (20)                  ,
        endbrr            like dpaksocor.endbrr      ,
        endufd            like dpaksocor.endufd      ,
        endcep            like dpaksocor.endcep      ,
        qldgracod         like dpaksocor.qldgracod   ,
        cpodes            like iddkdominio.cpodes    ,
        remqtd            dec (06,0)                 ,
        socqtd            dec (06,0)                 ,
        dafqtd            dec (06,0)                 ,
        rptqtd            dec (06,0)                 ,
        repqtd            dec (06,0)                 ,
        grlqtd            dec (06,0)                 ,
        guiqtd            dec (06,0)                 ,
        tecqtd            dec (06,0)                 ,
        ambqtd            dec (06,0)                 ,
        sreqtd            dec (06,0)                 ,
        chaqtd            dec (06,0)                 ,
        mincst            dec (13,2)                 ,
        maxcst            dec (13,2)                 ,
        medcst            dec (13,2)                 ,
        remvlr            dec (13,2)                 ,
        socvlr            dec (13,2)                 ,
        dafvlr            dec (13,2)                 ,
        rptvlr            dec (13,2)                 ,
        repvlr            dec (13,2)                 ,
        grlvlr            dec (13,2)                 ,
        guivlr            dec (13,2)                 ,
        tecvlr            dec (13,2)                 ,
        ambvlr            dec (13,2)                 ,
        srevlr            dec (13,2)                 ,
        chavlr            dec (13,2)                 ,
        totsrv            dec (13,2)
 end record

 define ws_tipo           char(13)
 define ws_vlrtabflg      like dpaksocor.vlrtabflg

 output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  066

   order by r_bdbsr310.atdprscod

   format

      on every row
         #-----------------------------
         # Dados do prestador
         #-----------------------------
         let r_bdbsr310.nomgrr = "*** NAO CADASTRADO ***"
         let r_bdbsr310.endcid = "*** NAO CADASTRADO ***"
         open  c_guerra using r_bdbsr310.atdprscod
         fetch c_guerra into  r_bdbsr310.nomrazsoc, r_bdbsr310.nomgrr   ,
                              r_bdbsr310.endcid   , r_bdbsr310.endufd   ,
                              r_bdbsr310.endcep   , ws_vlrtabflg        ,
                              r_bdbsr310.endbrr   , r_bdbsr310.qldgracod
         close c_guerra

         if r_bdbsr310.atdprscod = 1  or
            r_bdbsr310.atdprscod = 4  or
            r_bdbsr310.atdprscod = 8  then
            let r_bdbsr310.atdprstip = 1
         else
            if ws_vlrtabflg = "S"  then
               let r_bdbsr310.atdprstip = 2
            else
               let r_bdbsr310.atdprstip = 3
            end if
         end if
         open c_qualid using r_bdbsr310.qldgracod
         fetch c_qualid into r_bdbsr310.cpodes
         close c_qualid

         case r_bdbsr310.atdprstip
              when 1 let ws_tipo = "FROTA"
              when 2 let ws_tipo = "TABELA"
              when 3 let ws_tipo = "OUTROS"
              when 4 let ws_tipo = "TODOS"
         end case

         if ws_flgcab1 = 0 then
            let ws_flgcab1 = 1
            print column 001, "Cod_prestador",     "|"
                            , "Nome_prestador",    "|"
                            , "Tipo",              "|"
                            , "Cidade",            "|"
                            , "UF",                "|"
                            , "Qualidade",         "|"
                            , "Vlr_Remocoes(/100)","|"
                            , "Qtd_Remocoes",      "|"
                            , "Vlr_Guincho(/100)", "|"
                            , "Qtd_Guincho",       "|"
                            , "Vlr_Tecnico(/100)", "|"
                            , "Qtd_Tecnico",       "|"
                            , "Vlr_Ambos(/100)",   "|"
                            , "Qtd_Ambos",         "|"
                            , "Vlr_Cheveiro(/100)","|"
                            , "Qtd_Cheveiro",      "|"
                            , "Vlr_DAF(/100)",     "|"
                            , "Qtd_DAF",           "|"
                            , "Vlr_RPT(/100)",     "|"
                            , "Qtd_RPT",           "|"
                            , "Vlr_Replace(/100)", "|"
                            , "Qtd_Replace",       "|"
                            , "Vlr_RE(/100)",      "|"
                            , "Qtd_RE",            "|"
                            , ascii(13)
         end if

         print r_bdbsr310.atdprscod,      "|", #codigo prestador
               r_bdbsr310.nomgrr clipped, "|", #nome prestador
               ws_tipo clipped,           "|", #tipo prestador
               r_bdbsr310.endcid clipped, "|", #cidade prestador
               r_bdbsr310.endufd,         "|", #uf prestador
               r_bdbsr310.cpodes clipped, "|", #qual prestador
               r_bdbsr310.remvlr * 100 using "-----------&","|", #vlr remocoes
               r_bdbsr310.remqtd       using "------&",     "|", #qtd remocoes
               r_bdbsr310.guivlr * 100 using "-----------&","|", #vlr guincho
               r_bdbsr310.guiqtd       using "------&",     "|", #qtd guincho
               r_bdbsr310.tecvlr * 100 using "-----------&","|", #vlr tecnico
               r_bdbsr310.tecqtd       using "------&",     "|", #qtd tecnico
               r_bdbsr310.ambvlr * 100 using "-----------&","|", #vlr ambos
               r_bdbsr310.ambqtd       using "------&",     "|", #vlr ambos
               r_bdbsr310.chavlr * 100 using "-----------&","|", #vlr chaveiro
               r_bdbsr310.chaqtd       using "------&",     "|", #qtd chaveiro
               r_bdbsr310.dafvlr * 100 using "-----------&","|", #vlr D.A.F.
               r_bdbsr310.dafqtd       using "------&",     "|", #qtd D.A.F.
               r_bdbsr310.rptvlr * 100 using "-----------&","|", #vlr R.P.T.
               r_bdbsr310.rptqtd       using "------&",     "|", #qtd R.P.T.
               r_bdbsr310.repvlr * 100 using "-----------&","|", #vlr replace
               r_bdbsr310.repqtd       using "------&",     "|", #qtd replace
               r_bdbsr310.srevlr * 100 using "-----------&","|", #vlr RE
               r_bdbsr310.sreqtd       using "------&",     "|", #qtd RE
               ascii(13)

end report   ### rep_totais

#---------------------------------------------------------------------------
 report rep_pasvlr(r_bdbsr310)   # SERVICOS ASS.PASS.(VALORES) RDAT03102.TXT
#---------------------------------------------------------------------------

 define r_bdbsr310    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomrazsoc         like dpaksocor.nomrazsoc   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (20)                  ,
    endbrr            like dpaksocor.endbrr      ,
    endufd            like dpaksocor.endufd      ,
    endcep            like dpaksocor.endcep      ,
    qldgracod         like dpaksocor.qldgracod   ,
    cpodes            like iddkdominio.cpodes    ,
    taxqtd            dec (06,0)                 ,
    taxvlr            dec (13,2)                 ,
    hosqtd            dec (06,0)                 ,
    hosvlr            dec (13,2)                 ,
    mincst            dec (13,2)                 ,
    maxcst            dec (13,2)                 ,
    medcst            dec (13,2)                 ,
    pasqtd            dec (06,0)                 ,
    grupo             smallint                   ,
    totsrv            dec(13,2)                  ,
    grlqtd            dec(6,0),
    txqtdsrv          dec(6,0),
    txvlrsrv          dec(13,2),
    txqtdpas          dec(6,0),
    avqtdsrv          dec(6,0),
    avvlrsrv          dec(13,2),
    avqtdpas          dec(6,0),
    rdqtdsrv          dec(6,0),
    rdvlrsrv          dec(13,2),
    rdqtdpas          dec(6,0),
    abqtdsrv          dec(6,0),
    abvlrsrv          dec(13,2),
    abqtdpas          dec(6,0),
    trqtdsrv          dec(6,0),
    trvlrsrv          dec(13,2),
    trqtdpas          dec(6,0),
    hpqtdsrv          dec(6,0),
    hpvlrsrv          dec(13,2),
    hpqtdpas          dec(6,0)
 end record

 define ws_tipo       char(13)
 define ws_vlrtabflg  like dpaksocor.vlrtabflg

 output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr310.atdprscod

   format

     on every row
         #-----------------------------
         # Dados do prestador
         #-----------------------------
         let r_bdbsr310.nomgrr = "*** NAO CADASTRADO ***"
         let r_bdbsr310.endcid = "*** NAO CADASTRADO ***"
         open  c_guerra using r_bdbsr310.atdprscod
         fetch c_guerra into  r_bdbsr310.nomrazsoc, r_bdbsr310.nomgrr   ,
                              r_bdbsr310.endcid   , r_bdbsr310.endufd   ,
                              r_bdbsr310.endcep   , ws_vlrtabflg        ,
                              r_bdbsr310.endbrr   , r_bdbsr310.qldgracod
         close c_guerra

         if r_bdbsr310.atdprscod = 1  or
            r_bdbsr310.atdprscod = 4  or
            r_bdbsr310.atdprscod = 8  then
            let r_bdbsr310.atdprstip = 1
         else
            if ws_vlrtabflg = "S"  then
               let r_bdbsr310.atdprstip = 2
            else
               let r_bdbsr310.atdprstip = 3
            end if
         end if
         open c_qualid using r_bdbsr310.qldgracod
         fetch c_qualid into r_bdbsr310.cpodes
         close c_qualid

         case r_bdbsr310.atdprstip
              when 1 let ws_tipo = "FROTA"
              when 2 let ws_tipo = "TABELA"
              when 3 let ws_tipo = "OUTROS"
              when 4 let ws_tipo = "TODOS"
         end case

         if ws_flgcab2 = 0 then
            let ws_flgcab2 = 1
            print column 001, "Cod_prestador",   "|"
                            , "Nome_prestador",  "|"
                            , "Tipo",            "|"
                            , "Cidade",          "|"
                            , "UF",              "|"
                            , "Qualidade",       "|"
                            , "Vlr_Taxi(/100)",  "|"
                            , "Qtd_Taxi      ",  "|"
                            , "Pas_Taxi      ",  "|"
                            , "Vlr_Aviao(/100)", "|"
                            , "Qtd_Aviao      ", "|"
                            , "Pas_Aviao      ", "|"
                            , "Vlr_Rodov(/100)", "|"
                            , "Qtd_Rodov      ", "|"
                            , "Pas_Rodov      ", "|"
                            , "Vlr_Ambul(/100)", "|"
                            , "Qtd_Ambul      ", "|"
                            , "Pas_Ambul      ", "|"
                            , "Vlr_Transl(/100)","|"
                            , "Qtd_Transl      ","|"
                            , "Pas_Transl      ","|"
                            , "Vlr_Hosped(/100)","|"
                            , "Qtd_Hosped      ","|"
                            , "Pas_Hosped      ","|"
                            , ascii(13)
         end if

         print r_bdbsr310.atdprscod,      "|", #codigo prestador
               r_bdbsr310.nomgrr clipped, "|", #nome prestador
               ws_tipo clipped,           "|", #tipo prestador
               r_bdbsr310.endcid clipped, "|", #cidade prestador
               r_bdbsr310.endufd,         "|", #uf prestador
               r_bdbsr310.cpodes clipped, "|", #qualid prestador
               r_bdbsr310.txvlrsrv * 100 using "-----------&","|", #vlr taxi
               r_bdbsr310.txqtdsrv       using "------&",     "|", #qtd taxi
               r_bdbsr310.txqtdpas       using "------&",     "|", #pas taxi
               r_bdbsr310.avvlrsrv * 100 using "-----------&","|", #vlr aviao
               r_bdbsr310.avqtdsrv       using "------&",     "|", #qtd aviao
               r_bdbsr310.avqtdpas       using "------&",     "|", #pas aviao
               r_bdbsr310.rdvlrsrv * 100 using "-----------&","|", #vlr rodov
               r_bdbsr310.rdqtdsrv       using "------&",     "|", #qtd rodov
               r_bdbsr310.rdqtdpas       using "------&",     "|", #pas rodov
               r_bdbsr310.abvlrsrv * 100 using "-----------&","|", #vlr ambul
               r_bdbsr310.abqtdsrv       using "------&",     "|", #qtd ambul
               r_bdbsr310.abqtdpas       using "------&",     "|", #pas ambul
               r_bdbsr310.trvlrsrv * 100 using "-----------&","|", #vlr transl
               r_bdbsr310.trqtdsrv       using "------&",     "|", #qtd transl
               r_bdbsr310.trqtdpas       using "------&",     "|", #pas transl
               r_bdbsr310.hpvlrsrv * 100 using "-----------&","|", #vlr hosped
               r_bdbsr310.hpqtdsrv       using "------&",     "|", #qtd hosped
               r_bdbsr310.hpqtdpas       using "------&",     "|", #pas hosped
               ascii(13)

 end report   ### rep_taxi


