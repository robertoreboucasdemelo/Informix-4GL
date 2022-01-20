#############################################################################
# Nome do Modulo: bdatr091                                         Raji     #
#                                                                  Ruiz     #
# Relatorio mensal de retorno de V10/V11/V13 e cancel. V12         Nov/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                        #
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

 database porto

 define ws_data_de     date
 define ws_data_ate    date

 main
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    call bdatr091()
 end main

#---------------------------------------------------------------
 function bdatr091()
#---------------------------------------------------------------

 define d_bdatr091_V12c    record
    ligdat            like datmligacao.ligdat,
    lignum            like datmligacao.lignum,
    ramcod            like datrligsinvst.ramcod,
    sinvstnum         like datrligsinvst.sinvstnum,
    sinvstano         like datrligsinvst.sinvstano,
    vstsolstt         like datmpedvist.vstsolstt
 end record

 define d_bdatr091_vr    record
    ligdat            like datmligacao.ligdat,
    lignum            like datmligacao.lignum,
    ramcod            like datrligsinvst.ramcod,
    sinvstnum         like datrligsinvst.sinvstnum,
    sinvstano         like datrligsinvst.sinvstano,
    vstretflg         like datmvstsin.vstretflg
 end record

 define ws            record
    comando           char (300)                 ,
    auxdat            char (10)                  ,
    dirfisnom         like ibpkdirlog.dirfisnom  ,
    pathrel01         char (60)                  ,
    pathrel02         char (60)
 end record

 define sql_select    char(300)

 define l_assunto     char(100),
        l_erro_envio  smallint

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdatr091_V12c.*  to null
 initialize d_bdatr091_vr.*  to null
 initialize ws.*          to null

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
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT09101.rtf"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDAT09102.rtf"

#---------------------------------------------------------------
# Inicio da leitura principal
#---------------------------------------------------------------
 declare c_bdatr091_v12c cursor for
 select datmligacao.ligdat,
        datmligacao.lignum,
        datrligsinvst.ramcod,
        datrligsinvst.sinvstnum,
        datrligsinvst.sinvstano,
        datmpedvist.vstsolstt
  from datmligacao, datrligsinvst, datmpedvist
  where datmligacao.ligdat between ws_data_de and ws_data_ate
    and datmligacao.c24astcod = "V12"
    and datmligacao.lignum = datrligsinvst.lignum
    and datmpedvist.sinvstnum = datrligsinvst.sinvstnum
    and datmpedvist.sinvstano = datrligsinvst.sinvstano
    and datmpedvist.vstsolstt in (3,4)

 declare c_bdatr091_vr cursor for
 select datmligacao.ligdat,
        datmligacao.lignum,
        datrligsinvst.ramcod,
        datrligsinvst.sinvstnum,
        datrligsinvst.sinvstano,
        datmvstsin.vstretflg
   from datmligacao, datrligsinvst, datmvstsin
  where datmligacao.ligdat between ws_data_de and ws_data_ate
    and datmligacao.c24astcod in ("V10","V11","V13")
    and datmligacao.lignum = datrligsinvst.lignum
    and datmvstsin.sinvstnum = datrligsinvst.sinvstnum
    and datmvstsin.sinvstano = datrligsinvst.sinvstano
    and datmvstsin.vstretflg = "S"

 start report rep_v12c  to ws.pathrel01
 start report rep_vr    to ws.pathrel02

 foreach c_bdatr091_v12c into d_bdatr091_v12c.ligdat    ,
                              d_bdatr091_v12c.lignum    ,
                              d_bdatr091_v12c.ramcod    ,
                              d_bdatr091_v12c.sinvstnum ,
                              d_bdatr091_v12c.sinvstano ,
                              d_bdatr091_v12c.vstsolstt
    output to report rep_v12c(d_bdatr091_v12c.*)
 end foreach

 foreach c_bdatr091_vr into d_bdatr091_vr.ligdat    ,
                                    d_bdatr091_vr.lignum    ,
                                    d_bdatr091_vr.ramcod    ,
                                    d_bdatr091_vr.sinvstnum ,
                                    d_bdatr091_vr.sinvstano ,
                                    d_bdatr091_vr.vstretflg
    output to report rep_vr(d_bdatr091_vr.*)
 end foreach

 finish report rep_v12c
 finish report rep_vr

 # GERA E-MAIL

 let l_assunto    = null
 let l_erro_envio = null

 let l_assunto    = "Relatorio Cancelamentos V12 - ", ws_data_de, " a ", ws_data_ate
 let l_erro_envio = ctx22g00_envia_email("BDATR091",
                                         l_assunto,
                                         ws.pathrel01)
 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01
    else
       display "Nao existe email cadastrado para o modulo - BDATR091"
    end if
 end if

 let l_assunto    = null
 let l_erro_envio = null

 let l_assunto    = "Relatorio RETORNO DE V10/V11/V13"
 let l_erro_envio = ctx22g00_envia_email("BDATR091",
                                         l_assunto,
                                         ws.pathrel02)
 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel02
    else
       display "Nao existe email cadastrado para o modulo - BDATR091"
    end if
 end if

end function  ###  bdatr091

#---------------------------------------------------------------------------
 report rep_v12c(r_bdatr091)
#---------------------------------------------------------------------------

 define r_bdatr091  record
    ligdat            like datmligacao.ligdat,
    lignum            like datmligacao.lignum,
    ramcod            like datrligsinvst.ramcod,
    sinvstnum         like datrligsinvst.sinvstnum,
    sinvstano         like datrligsinvst.sinvstano,
    vstsolstt         like datmpedvist.vstsolstt
 end record

 define ws            record
    tab               char(1),
    linha             char(3000)
 end record

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  r_bdatr091.ligdat,
             r_bdatr091.lignum

   format
      first page header
         let ws.tab = " "
         let ws.linha = "Data da Ligacao" ,
                        ws.tab
         let ws.linha = ws.linha clipped, "Numero da Ligacao",
                        ws.tab
         let ws.linha = ws.linha clipped, "Ramo",
                        ws.tab
         let ws.linha = ws.linha clipped, "Numero da Vistoria"

      on every row
         let ws.tab = " "
         let ws.linha = r_bdatr091.ligdat ,
                        ws.tab
         let ws.linha = ws.linha clipped, r_bdatr091.lignum using "&&&&&&&&",
                        ws.tab
         let ws.linha = ws.linha clipped, r_bdatr091.ramcod using "&&&&",
                        ws.tab
         let ws.linha = ws.linha clipped, r_bdatr091.sinvstnum using "&&&&&&&&"

#         let ws.linha = ws.linha clipped, r_bdatr091.vstsolstt using "##"

         print ws.linha clipped

end report  ###  rep_v12c

#---------------------------------------------------------------------------
 report rep_vr(r_bdatr091)
#---------------------------------------------------------------------------

 define r_bdatr091    record
    ligdat            like datmligacao.ligdat,
    lignum            like datmligacao.lignum,
    ramcod            like datrligsinvst.ramcod,
    sinvstnum         like datrligsinvst.sinvstnum,
    sinvstano         like datrligsinvst.sinvstano,
    vstretflg         like datmvstsin.vstretflg
 end record

 define ws            record
    tab               char(1),
    linha             char(3000)
 end record

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  r_bdatr091.ligdat,
             r_bdatr091.lignum

   format

      first page header
         let ws.tab = " "
         let ws.linha = "Data da Ligacao" ,
                        ws.tab
         let ws.linha = ws.linha clipped, "Numero da Ligacao",
                        ws.tab
         let ws.linha = ws.linha clipped, "Ramo",
                        ws.tab
         let ws.linha = ws.linha clipped, "Numero da Vistoria"

      on every row
         let ws.tab = " "
         let ws.linha = r_bdatr091.ligdat ,
                        ws.tab
         let ws.linha = ws.linha clipped, r_bdatr091.lignum using "&&&&&&&&",
                        ws.tab
         let ws.linha = ws.linha clipped, r_bdatr091.ramcod using "&&&&",
                        ws.tab
         let ws.linha = ws.linha clipped, r_bdatr091.sinvstnum using "&&&&&&&&"

#         let ws.linha = ws.linha clipped, r_bdatr091.vstretflg clipped

         print ws.linha clipped

end report  ###  rep_vr
