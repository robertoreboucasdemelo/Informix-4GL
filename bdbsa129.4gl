################################################################################
# Nome do Modulo: bdbsa129                                          Adriano    #
#                                                                   Raji       #
# Processamento Secundario de Sinais/Botões Porto Socorro           Dez/2009   #
################################################################################
#                                                                              #
#                          * * * Alteracoes * * *                              #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 09/12/2010 Sergio Burini     PAS086894  Inclusao da empresa 84 (ISAR)        #
# 27/04/2010 Adriano Santos    PIS242853  Retorno da ctb85g02_envia_msg        #
# 04/08/2010 Sergio Burini     PSI256323  Processamento Ligue-me               #
# 08/12/2011 Celso Yamahaki    PSI020644  Controle de SMS RE                   #
# 28/02/2012 Celso Yamahaki    CT3366-IN  Detalhamento de Log para Apoio       #
# 20/03/2012 Celso Yamahaki               Incrementos de Log para Apoio        #
# 12/04/2012 Celso Yamahaki               Melhoria nas queries                 #
#------------------------------------------------------------------------------#
# 01/05/2012 Fornax  PSI03021PR PSI-2012-03021-PR - Resolucao 553 Anatel       #
#                                                                              #
# 15/07/2013 Jorge Modena   PSI201315767  Mecanismo de Seguranca               #
# 17/09/2013 Celso Yamahaki               inserção de clipped nos displays     #
#------------------------------------------------------------------------------#
# 24/07/2015 INTERA,MarcosMP SPR-2015-15533 Fechamento Automatico da Venda     #
#------------------------------------------------------------------------------#
# 22/12/2015 INTERA,MarcosMP                Tratar 'Fechamento Automatico da   #
#                                           Venda' somente para empresa 43.    #
#------------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_tempo_limite  interval hour(06) to second,
       m_dist_minima   decimal(8,4),
       m_prepare       smallint,
       m_current       datetime year to second
define m_fechaflg      smallint  #=> SPR-2015-15533


#------------------------------------------------------------------------------#
main

    define l_contingencia smallint,
           l_path         char(500),
           l_tmpexp       datetime year to second,
           l_prcstt       like dpamcrtpcs.prcstt,
           l_prcdat       date,
           l_prchor       datetime hour to second

    # ---> CONSTANTES
    let m_tempo_limite  = "00:05:00"  # --> TEMPO LIMITE PARA VERIFICACAO DE MOVIMNTO APOS QRU-REC
    let m_dist_minima   = 0.300       # --> DISTANCIA MINIMA DE DESLOCAMENTO APOS TEMPO LIMITE

    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    call bdbsa129_prepare()

    let l_path = f_path("DBS","LOG")

    if l_path is null then
       let l_path = "."
    end if

    let l_path = l_path clipped,"/bdbsa129.log"

    call startlog(l_path)

    let  l_tmpexp = current

    # BUSCAR A DATA E HORA DO BANCO
    call cts40g03_data_hora_banco(1) returning l_prcdat, l_prchor

    display l_prcdat, " ", l_prchor, " - ", "Carga"

    while true

       # --VERIFICA SE O ARQUIVO DE LOG EXISTE, SE NAO EXISTIR, ENCERRA O PROGRAMA
       if not cts40g03_verifi_log_existe(l_path) then
          display "Nao encontrou o arquivo de log: ", l_path clipped
          exit program(1)
       end if

       call ctx28g00("bdbsa129", fgl_getenv("SERVIDOR"), l_tmpexp)
            returning l_tmpexp, l_prcstt

       if  l_prcstt = 'A' then

           let l_contingencia = null
           call cta00m08_ver_contingencia(4)
                returning l_contingencia

          if l_contingencia then
              display "Contingencia Ativa/Carga ainda nao realizada."
          else
              # BUSCAR A DATA E HORA DO BANCO
              call cts40g03_data_hora_banco(1) returning l_prcdat, l_prchor

              display l_prcdat, " ", l_prchor, " - ", "Inicio"

              call bdbsa129()

              # BUSCAR A DATA E HORA DO BANCO
              call cts40g03_data_hora_banco(1) returning l_prcdat, l_prchor

              display l_prcdat, " ", l_prchor, " - ", "Fim"
          end if

       end if

       sleep 10

    end while

end main

#---------------------------#
 function bdbsa129_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = "select grlinf ",
                  " from datkgeral ",
                 " where grlchv = ? "
     prepare pbdbsa129_01 from l_sql
     declare cbdbsa129_01 cursor for pbdbsa129_01

     let l_sql = "insert into datkgeral (grlchv, grlinf, atldat, atlhor, atlemp, atlmat) values (?, ?, current, current, 1, 999999)"
     prepare pbdbsa129_02 from l_sql

     let l_sql = "update datkgeral set (grlinf,atldat,atlhor,atlemp,atlmat) ",
                 " = (?,current,current,1,999999) where grlchv = ? "
     prepare pbdbsa129_03 from l_sql

     let l_sql = "select rmcacpflg ",
                  " from datmservicocmp ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "
     prepare pbdbsa129_04 from l_sql
     declare cbdbsa129_04 cursor for pbdbsa129_04

     let l_sql = "select datmmdtmvt.mdtmvtseq, ",
                       " datmmdtmvt.mdtcod, ",
                       " datmmdtmvt.mdtmvttipcod, ",
                       " datmmdtmvt.mdtbotprgseq, ",
                       " datmmdtmvt.mdtmvtdigcnt, ",
                       " datmmdtmvt.atdsrvnum, ",
                       " datmmdtmvt.atdsrvano, ",
                       " datmmdtmvt.mdtmvtsnlflg, ",
                       " datmmdtmvt.lclltt, ",
                       " datmmdtmvt.lcllgt, ",
                       " datkveiculo.socvclcod, ",
                       " dattfrotalocal.srrcoddig, ",
                       " dattfrotalocal.c24atvcod, ",
                       " dattfrotalocal.atdsrvnum, ",
                       " dattfrotalocal.atdsrvano, ",
                       " datmmdtmvt.caddat, ",
                       " datmmdtmvt.cadhor ",
                  " from datmmdtmvt, datkveiculo, dattfrotalocal ",
                 " where mdtmvtseq >   ? ",
                   " and mdtmvtseq <=  ? ",
                   " and datmmdtmvt.mdtcod = datkveiculo.mdtcod ",
                   " and dattfrotalocal.socvclcod = datkveiculo.socvclcod ",
                   " and datmmdtmvt.mdtmvtstt = 2 ",
                   " and year(datmmdtmvt.caddat) = year(today) ",
                " order by 1"
     prepare pbdbsa129_05 from l_sql
     declare cbdbsa129_05 cursor with hold for pbdbsa129_05

     let l_sql = "select vcl.socvclcod, frt.c24atvcod ",
                 "  from datkveiculo vcl, dattfrotalocal frt",
                 " where vcl.mdtcod = ? ",
                 "   and vcl.socvclcod = frt.socvclcod"
     prepare selbdbsa129_06 from       l_sql
     declare cbdbsa129_06   cursor for selbdbsa129_06

     #let l_sql = " select c24atvcod ",
     #              " from dattfrotalocal ",
     #             " where socvclcod = ? "
     #prepare pbdbsa129_07 from l_sql
     #declare cbdbsa129_07 cursor for pbdbsa129_07

     let l_sql = " select lclltt, ",
                        " lcllgt, ",
                        " caddat, ",
                        " cadhor, ",
                        " atdsrvnum, ",
                        " atdsrvano ",
                   " from datmmdtmvt ",
                  " where mdtmvtseq = (select max(mdtmvtseq) ",
                                       " from datmmdtmvt ",
                                      " where mdtcod = ? ",
                                        " and mdtmvttipcod = 2 ",  # BOTAO
                                        " and mdtbotprgseq = 1 ",  # QRU-REC
                                        " and caddat >= (today - 2 units day)) "                                        
     prepare pbdbsa129_08 from l_sql
     declare cbdbsa129_08 cursor for pbdbsa129_08

     let l_sql = " select caddat, ",
                        " cadhor ",
                   " from datmmdtinc ",
                  " where mdtcod = ? ",
                    " and mdtinctip = ? ",
                  " order by caddat desc, ",
                           " cadhor desc "
    prepare pbdbsa129_09 from l_sql
    declare cbdbsa129_09 cursor for pbdbsa129_09

    let l_sql = "select srrcoddig, atdsrvnum, atdsrvano",
                     "  from dattfrotalocal",
                     " where dattfrotalocal.socvclcod = ?",
                     "   and dattfrotalocal.c24atvcod not in ('QTP','NIL') "
    prepare sel_bdbsa129_10 from       l_sql
    declare cbdbsa129_10  cursor for sel_bdbsa129_10

    let l_sql = "update datmmdtmvt ",
                  " set atdsrvnum = ? ,",
                      " atdsrvano = ?  ",
                " where mdtmvtseq = ? "
    prepare pbdbsa129_11 from  l_sql

    let l_sql = "select 1 ",
                 " from dpcmdscitf ",
                " where mdtcod = ? ",
                  " and current < caddat + 60 units second "
    prepare sel_bdbsa129_12 from       l_sql
    declare cbdbsa129_12  cursor for sel_bdbsa129_12

    let l_sql = "select vcl.socvclcod, ",
                      " vcl.celdddcod, ",
                      " vcl.celtelnum, ",
                      " srr.srrcoddig, ",
                      " srr.celdddcod, ",
                      " srr.celtelnum, ",
                      " srr.srrabvnom ",
                 " from datkveiculo    vcl, ",
                      " dattfrotalocal frt, ",
                      " datksrr        srr ",
                " where vcl.mdtcod    = ? ",
                  " and vcl.socvclcod = frt.socvclcod ",
                  " and srr.srrcoddig = frt.srrcoddig "
    prepare sel_bdbsa129_13 from       l_sql
    declare cbdbsa129_13  cursor for sel_bdbsa129_13

    let l_sql = "insert into dpcmdscitf values (0,?,?,?,'A',current,0)"
    prepare pbdbsa129_14 from  l_sql

    let l_sql = "select grlinf ",
                 " from datkgeral ",
                " where grlchv = ? "
    prepare sel_bdbsa129_15 from       l_sql
    declare cbdbsa129_15  cursor for sel_bdbsa129_15

    let l_sql = "select atdsrvorg ",
                "  from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
    prepare sel_bdbsa129_16 from       l_sql
    declare cbdbsa129_16  cursor for sel_bdbsa129_16

    let l_sql = "select smsenvcod      ",
                "  from dbsmenvmsgsms  ",
                " where smsenvcod =  ? "
    prepare sel_bdbsa129_17 from l_sql
    declare cbdbsa129_17 cursor for sel_bdbsa129_17

    let l_sql = "update datmmdtmvt ",
                  " set snsetritv = ? ",
                " where mdtmvtseq = ? "
    prepare pbdbsa129_18 from  l_sql

    # pegar ultimos tres sinais do mesmo botao
    let l_sql = " select first 3 caddat, cadhor ",
                  " from datmmdtmvt " ,
                 " where mdtmvttipcod = 2 " ,  # tipo movto botao acionado
                   " and mdtbotprgseq = ? " ,  # botao
                   " and mdtcod       = ? " ,  # MDT
                " order by caddat desc, cadhor desc "
    prepare pbdbsa129_19 from l_sql
    declare cbdbsa129_19 cursor with hold for pbdbsa129_19

    #=> SPR-2015-15533
    declare cbdbsa1292020 cursor for
            select relpamtxt
              from igbmparam
             where relsgl = "FECHA129"

    let l_sql = "select ciaempcod ",
                "  from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
    prepare pbdbsa1292121 from l_sql
    declare cbdbsa1292121 cursor for pbdbsa1292121

    let m_prepare = true

 end function

#-------------------#
function bdbsa129()
#-------------------#

 define retorno record
    errocod   integer,
    erromsg   char(70)
 end record

 define l_mdtmvtseq like datmmdtmvt.mdtmvtseq,
        l_mdtmvtult like datmmdtmvt.mdtmvtseq,
        l_difqtdsin integer


 define lr_bdbsa129 record
    mdtmvtseq    like datmmdtmvt.mdtmvtseq,
    mdtcod       like datmmdtmvt.mdtcod,
    mdtmvttipcod like datmmdtmvt.mdtmvttipcod,
    mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
    mdtmvtdigcnt like datmmdtmvt.mdtmvtdigcnt,
    atdsrvnum    like datmmdtmvt.atdsrvnum,
    atdsrvano    like datmmdtmvt.atdsrvano,
    mdtmvtsnlflg like datmmdtmvt.mdtmvtsnlflg,
    lclltt       like datmmdtmvt.lclltt,
    lcllgt       like datmmdtmvt.lcllgt,
    socvclcod    like dattfrotalocal.socvclcod,
    c24atvcod    like dattfrotalocal.c24atvcod,
    srrcoddig    like dattfrotalocal.srrcoddig,
    atdsrvnumfrt like dattfrotalocal.atdsrvnum,
    atdsrvanofrt like dattfrotalocal.atdsrvano,
    caddat       like datmmdtmvt.caddat,
    cadhor       like datmmdtmvt.cadhor
 end record

 call bdbsa129_ult_sinal()
      returning l_mdtmvtseq,
                retorno.errocod,
                retorno.erromsg

 # Busca o ultimo movimento gravado
 select max(mdtmvtseq) 
   into l_mdtmvtult
   from datmmdtmvt 
  where caddat <= today 
    and caddat >= (today - 1 units day)

    display "l_mdtmvtseq: ", l_mdtmvtseq
    display "l_mdtmvtult: ", l_mdtmvtult

 # Limita em 10000 o atraso no processamento
 if (l_mdtmvtult - l_mdtmvtseq) > 10000 then
    let l_difqtdsin = (l_mdtmvtult - l_mdtmvtseq) - 10000
    let l_mdtmvtseq = l_mdtmvtult - 10000
    display "Ignorados ",  l_difqtdsin, " sinais. Serao analisados os sinais de ", l_mdtmvtseq, " ate ", l_mdtmvtult
 end if

 #=> SPR-2015-15533 - VERIFICA SE FECHAMENTO AUTOMATICO ESTA "LIGADO"
 let m_fechaflg = bdbsa129_ligado()

 open cbdbsa129_05 using l_mdtmvtseq,
                         l_mdtmvtult

 foreach cbdbsa129_05 into lr_bdbsa129.mdtmvtseq,
                           lr_bdbsa129.mdtcod,
                           lr_bdbsa129.mdtmvttipcod,
                           lr_bdbsa129.mdtbotprgseq,
                           lr_bdbsa129.mdtmvtdigcnt,
                           lr_bdbsa129.atdsrvnum,
                           lr_bdbsa129.atdsrvano,
                           lr_bdbsa129.mdtmvtsnlflg,
                           lr_bdbsa129.lclltt,
                           lr_bdbsa129.lcllgt,
                           lr_bdbsa129.socvclcod,
                           lr_bdbsa129.srrcoddig,
                           lr_bdbsa129.c24atvcod,
                           lr_bdbsa129.atdsrvnumfrt,
                           lr_bdbsa129.atdsrvanofrt,
                           lr_bdbsa129.caddat,
                           lr_bdbsa129.cadhor

     let l_mdtmvtseq = lr_bdbsa129.mdtmvtseq

     case lr_bdbsa129.mdtmvttipcod
          when 1 #SINAL
               call bdbsa129_processa_sinal(lr_bdbsa129.mdtmvtseq,
                                            lr_bdbsa129.mdtcod,
                                            lr_bdbsa129.mdtmvttipcod,
                                            lr_bdbsa129.mdtbotprgseq,
                                            lr_bdbsa129.mdtmvtdigcnt,
                                            lr_bdbsa129.atdsrvnum,
                                            lr_bdbsa129.atdsrvano,
                                            lr_bdbsa129.mdtmvtsnlflg,
                                            lr_bdbsa129.lclltt,
                                            lr_bdbsa129.lcllgt,
                                            lr_bdbsa129.socvclcod,
                                            lr_bdbsa129.srrcoddig,
                                            lr_bdbsa129.c24atvcod,
                                            lr_bdbsa129.atdsrvnumfrt,
                                            lr_bdbsa129.atdsrvanofrt )
                    returning retorno.errocod,
                              retorno.erromsg
          when 2 #BOTAO
               call bdbsa129_processa_botao(lr_bdbsa129.mdtmvtseq,
                                            lr_bdbsa129.mdtcod,
                                            lr_bdbsa129.mdtmvttipcod,
                                            lr_bdbsa129.mdtbotprgseq,
                                            lr_bdbsa129.mdtmvtdigcnt,
                                            lr_bdbsa129.atdsrvnum,
                                            lr_bdbsa129.atdsrvano,
                                            lr_bdbsa129.mdtmvtsnlflg,
                                            lr_bdbsa129.lclltt,
                                            lr_bdbsa129.lcllgt,
                                            lr_bdbsa129.socvclcod,
                                            lr_bdbsa129.srrcoddig,
                                            lr_bdbsa129.c24atvcod,
                                            lr_bdbsa129.atdsrvnumfrt,
                                            lr_bdbsa129.atdsrvanofrt,
                                            lr_bdbsa129.caddat,
                                            lr_bdbsa129.cadhor )
                    returning retorno.errocod,
                              retorno.erromsg
     end case

 end foreach

 call bdbsa129_grava_ult_sinal(l_mdtmvtseq)
      returning retorno.errocod,
                retorno.erromsg

end function

#---------------------------------#
function bdbsa129_ult_sinal()
#---------------------------------#

 define retorno record
    mdtmvtseq like datmmdtmvt.mdtmvtseq,
    errocod   integer,
    erromsg   char(70)
 end record

 define l_aux       char(15)

 let retorno.mdtmvtseq = null
 let retorno.errocod = 0
 let retorno.erromsg = ""

 let l_aux    = 'PSOPRCSNLULT'

 open cbdbsa129_01 using l_aux
 fetch cbdbsa129_01 into retorno.mdtmvtseq
 close cbdbsa129_01
 if  sqlca.sqlcode = 100 then
     select max(mdtmvtseq) into retorno.mdtmvtseq from datmmdtmvt
 end if

 return retorno.mdtmvtseq,
        retorno.errocod,
        retorno.erromsg

end function

#---------------------------------#
function bdbsa129_grava_ult_sinal(param)
#---------------------------------#
 define param record
     mdtmvtseq like datmmdtmvt.mdtmvtseq
 end record

 define retorno record
    errocod   integer,
    erromsg   char(70)
 end record

 define l_aux       char(15)

 let retorno.errocod = 0
 let retorno.erromsg = ""
 let l_aux = 'PSOPRCSNLULT'

 open cbdbsa129_01 using l_aux
 fetch cbdbsa129_01

 if sqlca.sqlcode = notfound then
     execute pbdbsa129_02 using l_aux,
                                param.mdtmvtseq
 else
     execute pbdbsa129_03 using param.mdtmvtseq,
                                l_aux
 end if
 close cbdbsa129_01

 return retorno.errocod,
        retorno.erromsg

end function

#-----------------------------------#
function bdbsa129_processa_sinal(param)
#-----------------------------------#
 define param record
    mdtmvtseq    like datmmdtmvt.mdtmvtseq,
    mdtcod       like datmmdtmvt.mdtcod,
    mdtmvttipcod like datmmdtmvt.mdtmvttipcod,
    mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
    mdtmvtdigcnt like datmmdtmvt.mdtmvtdigcnt,
    atdsrvnum    like datmmdtmvt.atdsrvnum,
    atdsrvano    like datmmdtmvt.atdsrvano,
    mdtmvtsnlflg like datmmdtmvt.mdtmvtsnlflg,
    lclltt       like datmmdtmvt.lclltt,
    lcllgt       like datmmdtmvt.lcllgt,
    socvclcod    like dattfrotalocal.socvclcod,
    srrcoddig    like dattfrotalocal.srrcoddig,
    c24atvcod    like dattfrotalocal.c24atvcod,
    atdsrvnumfrt like dattfrotalocal.atdsrvnum,
    atdsrvanofrt like dattfrotalocal.atdsrvano
 end record

 define retorno record
    errocod   integer,
    erromsg   char(70)
 end record

 define lr_ctb85g02 record
    codigo  smallint, # 0 -> OK, 1 -> Nao enviado sms, 2 -> Erro de banco
    mensagem  char(100)
 end record

 define ws record
    rec_lclltt    like datmmdtmvt.lclltt,
    rec_lcllgt    like datmmdtmvt.lcllgt,
    rec_caddat    like datmmdtmvt.caddat,
    rec_cadhor    like datmmdtmvt.cadhor,
    rec_atdsrvnum like datmmdtmvt.atdsrvnum,
    rec_atdsrvano like datmmdtmvt.atdsrvano,
    espera        interval hour(06) to second,
    distancia     decimal(8,4),
    mdtinctip     like datmmdtinc.mdtinctip,
    inccaddat     like datmmdtinc.caddat,
    inccadhor     like datmmdtinc.cadhor
 end record

 define l_atdlibhor        like datmservico.atdlibhor,
        l_atdhorprg        like datmservico.atdhorprg,
        l_atdprvdat        like datmservico.atdprvdat,
        l_hora_calc        interval hour(06) to second,
        l_hora_atu         datetime hour to second,     #interval hour(06) to second,
        l_hora_dif         interval hour(06) to second,
        l_chave_sms        like dbsmenvmsgsms.smsenvcod,
        l_atdsrvorg        like datmservico.atdsrvorg


 initialize lr_ctb85g02.*, l_chave_sms to null

 let retorno.errocod = 0
 let retorno.erromsg = ""

 if param.mdtmvtsnlflg  =  "S"  then     #--> Sinal lat/longitude valido

    if param.c24atvcod = "REC" then

       open cbdbsa129_08 using param.mdtcod
       whenever error continue
       fetch cbdbsa129_08 into ws.rec_lclltt,
                               ws.rec_lcllgt,
                               ws.rec_caddat,
                               ws.rec_cadhor,
                               ws.rec_atdsrvnum,
                               ws.rec_atdsrvano
       whenever error stop

       if sqlca.sqlcode <> 0 and
          sqlca.sqlcode <> notfound then
          display "Erro SELECT cbdbsa129_08 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          display "Codigo do MDT: ", param.mdtcod
          exit program(1)
       end if

       close cbdbsa129_08

       #verifica origem do servico
       whenever error continue
       open cbdbsa129_16 using ws.rec_atdsrvnum,
                               ws.rec_atdsrvano

       fetch cbdbsa129_16 into l_atdsrvorg
       whenever error stop

        if sqlca.sqlcode <> 0 and
          sqlca.sqlcode <> notfound then
          display "Erro SELECT cbdbsa129_16 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          display "SERVICO: ", ws.rec_atdsrvnum
          exit program(1)
       end if

       close cbdbsa129_16



      # VERIFICA DESLOCAMENTO APOS TEMPO LIMITE (CINCO MINUTOS)
       let ws.espera = ctx01g07_espera(ws.rec_caddat, ws.rec_cadhor)
       if ws.espera > m_tempo_limite then

          let ws.distancia = cts18g00(param.lclltt, param.lcllgt,
                                      ws.rec_lclltt, ws.rec_lcllgt)

          # VERIFICA SE HOUVE DESLOCAMENTO MINIMO
          if ws.distancia > m_dist_minima then
             #VERIFICA SE O SMS DE SERVIÇO RE NÃO FOI ENVIADO
             let l_chave_sms = "R", param.atdsrvnum using "<<<<<<<<&",
                                            param.atdsrvano using "<&"
             whenever error continue
             open cbdbsa129_17 using l_chave_sms
             fetch cbdbsa129_17 into l_chave_sms
             whenever error stop
             if sqlca.sqlcode = 100 then
                if l_atdsrvorg = 9 or l_atdsrvorg = 13 then
                    ###########################################
                    # ENVIA SMS PARA SEGURADO COM PREVISAO RE
                    ###########################################
                    call ctb85g02_envia_msg(2,
                                            ws.rec_atdsrvnum,
                                            ws.rec_atdsrvano)
                         returning lr_ctb85g02.codigo,
                                   lr_ctb85g02.mensagem
                    display lr_ctb85g02.mensagem clipped
                else
                   ###########################################
                   # ENVIA SMS PARA SEGURADO COM PREVISAO AUTO
                   ###########################################
                   call ctb85g02_envia_msg(3,
                                           ws.rec_atdsrvnum,
                                           ws.rec_atdsrvano)
                        returning lr_ctb85g02.codigo,
                                  lr_ctb85g02.mensagem
                   display lr_ctb85g02.mensagem clipped
                end if
             end if
             close cbdbsa129_17
          else

             #########################################
             # ALERTA AO PRESTADOR DE NAO DESLOCAMENTO
             #########################################
             call cts10g06_dados_servicos
                  (15, ws.rec_atdsrvnum, ws.rec_atdsrvano)
                  returning retorno.errocod, retorno.erromsg,
                            l_atdlibhor, l_atdhorprg, l_atdprvdat

             if l_atdhorprg is null then
                 let l_hora_calc  = l_atdlibhor + l_atdprvdat
                 ###else
                 ###   let l_hora_calc  = l_atdhorprg - l_atdprvdat
                 ###end if

                 let l_hora_atu   = current
                 let l_hora_dif = l_hora_calc - l_hora_atu

                 if l_hora_calc > m_tempo_limite then

                    # --> PESQUISAR TEMPO DO ULTIMO ALERTA
                    let ws.mdtinctip = 7
                    open cbdbsa129_09 using param.mdtcod, ws.mdtinctip
                    whenever error continue
                    fetch cbdbsa129_09 into ws.inccaddat, ws.inccadhor
                    whenever error stop

                    if sqlca.sqlcode <> 0 then
                       if sqlca.sqlcode = notfound then
                          let ws.espera = "02:00:00" # GRAVA
                       else
                          display "Erro SELECT cbdbsa129_09 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                          exit program(1)
                       end if
                    else
                       let ws.espera = ctx01g07_espera(ws.inccaddat, ws.inccadhor)
                    end if

                    close cbdbsa129_09

                    # VERIFICA SE PASSOU O TEMPO LIMITE DO ULTIMO ALERTA.
                    if ws.espera > m_tempo_limite then

                       let retorno.errocod = ctx01g07_inc_alerta(param.socvclcod,
                                                            param.mdtcod,
                                                            param.srrcoddig, 7) # ALERTA REFERENTE A VIATURA SEM DESLOCAMENTO

                       if retorno.errocod <> 0 then
                          display "Erro na funcao ctx01g07_inc_alerta() ERRO - ", retorno.errocod
                          #exit program(1)
                       end if

                       ### ENVIA ALERTA PARA GPS
                       call ctx01g07_envia_msg_id("",  #numero do servico
                                                  "",  #ano do servico
                                                  param.mdtcod,# codigo mdt
                                                 "VOCE RECEBEU UM QRU E NAO SAIU DO LUGAR, SIGA IMEDIATAMENTE" )
                            returning retorno.errocod,
                                      retorno.erromsg

                       if retorno.errocod <> 0 then
                          display "Erro na funcao ctx01g07_envia_msg_id() ERRO - ", retorno.errocod, " ", retorno.erromsg
                       end if

                    end if

                 end if
             end if

          end if

       end if

    end if

 else
    ###################################
    #### COORDENADA INVALIDA
    ###################################
    ###let ws.mdtinctip = 2
    ###
    #### --> PESQUISAR TEMPO DO ULTIMO ALERTA
    ###
    ###open cbdbsa129_09 using param.mdtcod, ws.mdtinctip
    ###whenever error continue
    ###fetch cbdbsa129_09 into ws.inccaddat, ws.inccadhor
    ###whenever error stop
    ###
    ###if sqlca.sqlcode <> 0 then
    ###   if sqlca.sqlcode = notfound then
    ###      let ws.espera = "02:00:00" # GRAVA
    ###   else
    ###      display "Erro SELECT cbdbsa129_09 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
    ###      exit program(1)
    ###   end if
    ###else
    ###   let ws.espera = ctx01g07_espera(ws.inccaddat, ws.inccadhor)
    ###end if
    ###
    ###close cbdbsa129_09
    ###
    ###if ws.espera > m_tempo_limite then
    ###
    ###   let retorno.errocod = ctx01g07_inc_alerta(ws.socvclcod,
    ###                                        param.mdtcod,
    ###                                        ws.srrcoddig, 2) # SINAL POLL
    ###
    ###   if retorno.errocod <> 0 then
    ###      display "Erro na funcao ctx01g07_inc_alerta() ERRO - ", retorno.errocod
    ###      #exit program(1)
    ###   end if
    ###
    ###   let retorno.errocod = ctx01g07_envia_msg("", "", param.mdtcod, "POLL")
    ###
    ###   if retorno.errocod <> 0 then
    ###      display "Erro na funcao ctx01g07_envia_msg() ERRO - ", retorno.errocod
    ###      #exit program(1)
    ###   end if
    ###
    ###end if
    ###
    ###whenever error stop
    ###
 end if

 if param.atdsrvnumfrt is not null then
    # GRAVA NUMERO DO SERVICO NO SINAL
    execute pbdbsa129_11 using param.atdsrvnumfrt,
                               param.atdsrvanofrt,
                               param.mdtmvtseq
 end if

 return retorno.errocod,
        retorno.erromsg

 end function

#----------------------------------#
function bdbsa129_processa_botao (param)
#----------------------------------#
 define param record
    mdtmvtseq    like datmmdtmvt.mdtmvtseq,
    mdtcod       like datmmdtmvt.mdtcod,
    mdtmvttipcod like datmmdtmvt.mdtmvttipcod,
    mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
    mdtmvtdigcnt like datmmdtmvt.mdtmvtdigcnt,
    atdsrvnum    like datmmdtmvt.atdsrvnum,
    atdsrvano    like datmmdtmvt.atdsrvano,
    mdtmvtsnlflg like datmmdtmvt.mdtmvtsnlflg,
    lclltt       like datmmdtmvt.lclltt,
    lcllgt       like datmmdtmvt.lcllgt,
    socvclcod    like dattfrotalocal.socvclcod,
    srrcoddig    like dattfrotalocal.srrcoddig,
    c24atvcod    like dattfrotalocal.c24atvcod,
    atdsrvnumfrt like dattfrotalocal.atdsrvnum,
    atdsrvanofrt like dattfrotalocal.atdsrvano,
    caddat       like datmmdtmvt.caddat,
    cadhor       like datmmdtmvt.cadhor
 end record

 define retorno record
    errocod   integer,
    erromsg   char(70)
 end record

 define lr_ctb85g02 record
    codigo  smallint, # 0 -> OK, 1 -> Nao enviado sms, 2 -> Erro de banco
    mensagem  char(100)
 end record

 define l_apoio smallint

 define l_mail integer,
        l_assunto   char(300),
        l_mensagem  char(300),
        l_intervalo like datmmdtmvt.snsetritv,
        l_botao     smallint

 define l_atdsrvorg like datmservico.atdsrvorg

 initialize lr_ctb85g02.*, l_atdsrvorg to null

 let retorno.errocod = 0
 let retorno.erromsg = ""
 let l_mail = 0
 let l_mensagem = null
 let l_apoio = 0

 # PSI 214566 Gestao de Frota
 # buscar intervalo entre QRU para calculo de tempo medio
 let l_botao = 0
 initialize l_intervalo to null
 if param.mdtbotprgseq = 1 or   # QRU REC
    param.mdtbotprgseq = 2 or   # QRU inicio
    param.mdtbotprgseq = 3      # QRU fim
      then
    case param.mdtbotprgseq
       when 1
          let l_botao = 9
       when 2
          let l_botao = 1
       when 3
          let l_botao = 2
       end case


    let l_intervalo = bdbsa129_intervalo( l_botao      ,
                                          param.mdtcod ,
                                          param.caddat ,
                                          param.cadhor )

    execute pbdbsa129_18  using  l_intervalo,
                                 param.mdtmvtseq

 end if

 case param.mdtbotprgseq
      when 1 #QRU-REC
           #Comentado no Projeto Mecanismo de Seguranca
           #SMS RE sera enviado apos confirmacao de movimento na funcao bdbsa129_processa_sinal
           #Comentado por: JORGE MODENA a pedido de: Renato Bastos em 03/07/2013
           #if not m_prepare then
           #   call bdbsa129_prepare()
           #end if
           #
           #open cbdbsa129_16 using param.atdsrvnum,
           #                        param.atdsrvano
           #
           #fetch cbdbsa129_16 into l_atdsrvorg
           #
           #if l_atdsrvorg = 9 or l_atdsrvorg = 13 then
           #   call ctb85g02_envia_msg(2,
           #                           param.atdsrvnum,
           #                           param.atdsrvano)
           #        returning lr_ctb85g02.codigo,
           #                  lr_ctb85g02.mensagem
           #
           #   display lr_ctb85g02.mensagem
           #end if
           #close cbdbsa129_16

      when 3 #QRU-FIM
           call bdbsa129_processa_qrufim(param.atdsrvnum,
                                         param.atdsrvano,
                                         param.mdtmvtdigcnt)
                               returning retorno.errocod,
                                         retorno.erromsg

      #=> SPR-2015-15533 - TRATA SOLICITACAO DE FECHAMENTO DA VENDA
      when 7  #FECHAR
           if param.atdsrvnum is not null then
              call bdbsa129_fecha_venda(param.atdsrvnum,
                                        param.atdsrvano,
                                        param.mdtmvtdigcnt)
           end if

      when 17 # SOLICITACAO DE APOIO

           let m_current = current
           display m_current, " APOIO - VERIFICANDO EXISTENCIA DE MAIS SINAIS DE APOIO PARA O SERVICO: ", param.atdsrvnum,'-',param.atdsrvano
           #Verifica se não há mais de 1 pedido para o mesmo serviço
           whenever error continue
             select count(mdtmvtseq)
               into l_apoio
               from datmmdtmvt
              where datmmdtmvt.atdsrvnum = param.atdsrvnum
                and datmmdtmvt.atdsrvano = param.atdsrvano
                and datmmdtmvt.mdtmvttipcod = 2
                and datmmdtmvt.mdtbotprgseq = 17
                and datmmdtmvt.mdtmvtseq < param.mdtmvtseq

           whenever error stop

           if l_apoio > 0 then

              let m_current = current
              display m_current, " APOIO - EXISTE APOIO SOLICITADO PARA O SERVIÇO: ",param.atdsrvnum,'-',param.atdsrvano

           else
              let m_current = current
              display m_current, " APOIO - SOLICITACAO DE APOIO PARA O SERVICO: ",param.atdsrvnum,'-',param.atdsrvano
                                ,"MDT: ",param.mdtcod, "TIPO DO APOIO: ",param.mdtmvtdigcnt

	            call cts00m40_apoio(param.atdsrvnum,
                                  param.atdsrvano,
                                  param.mdtcod   ,
                                  param.mdtmvtdigcnt)
                   returning retorno.errocod,
                             retorno.erromsg

              if retorno.errocod <> 0 then
                 let l_assunto = 'Erro na abertura de apoio: ', param.atdsrvnum,'-',param.atdsrvano
                                ,'. Erro: ', retorno.errocod, '-', retorno.erromsg clipped
                 let l_mensagem = " Erro na abertura de apoio para o servico: ", param.atdsrvnum, '-'
                                   ,param.atdsrvano, ' Erro: ', retorno.errocod, ' - '
                                   ,retorno.erromsg clipped
                 whenever error continue
                 let l_mail = ctx22g00_mail_corpo("BDBSA129", l_assunto, l_mensagem)
                 whenever error stop
                 let m_current = current
                 display m_current, " APOIO - Erro no cts00m40_apoio, erro: ", retorno.errocod, " - ", retorno.erromsg
              end if
           end if

      when 20 # LIGUE-ME
           if  bdbsa129_processa("LIGUEME") then
               display "PROCESSA LIGUEME Para MDT: ", param.mdtcod
               call bdbsa129_processa_ligueme(param.mdtcod)
           else
               display "NAO PROCESSA LIGUEME"
           end if

 end case

 return retorno.errocod,
        retorno.erromsg

end function

#-----------------------------------#
function bdbsa129_processa_qrufim (param)
#-----------------------------------#
 define param record
    atdsrvnum    like datmmdtmvt.atdsrvnum,
    atdsrvano    like datmmdtmvt.atdsrvano,
    mdtmvtdigcnt like datmmdtmvt.mdtmvtdigcnt
 end record

 define retorno record
    errocod   integer,
    erromsg   char(70)
 end record

 define lr_ctb85g02 record
    codigo  smallint, # 0 -> OK, 1 -> Nao enviado sms, 2 -> Erro de banco
    mensagem  char(100)
 end record

 define l_rmcacpflg like datmservicocmp.rmcacpflg

 initialize lr_ctb85g02.* to null

 let retorno.errocod = 0
 let retorno.erromsg = ""
 let l_rmcacpflg = null

 # códigos de resolução que devem gerar o SMS do QRU-FIM
 if (param.mdtmvtdigcnt = 7)  or   # Veiculo removido W700 Tipo 2
    (param.mdtmvtdigcnt = 12) or   # Oficina indicada pelo cliente MDT/WVT/W700 Tipo 1
    (param.mdtmvtdigcnt = 13) or   # Oficina indicada no laudo MDT/WVT/W700 Tipo 1
    (param.mdtmvtdigcnt = 14) or   # Caps MDT/WVT/W700 Tipo 1
    (param.mdtmvtdigcnt = 15) then # Residencia ou local indicado pelo cliente MDT/WVT/W700 Tipo 1

    # VERIFICA SE O SEGURO ACOMPANHOU
    open cbdbsa129_04 using param.atdsrvnum,
                            param.atdsrvano
    fetch cbdbsa129_04 into l_rmcacpflg
    close cbdbsa129_04
    if l_rmcacpflg = "N" then
       call ctb85g02_envia_msg(1,
                               param.atdsrvnum,
                               param.atdsrvano)
                     returning lr_ctb85g02.codigo,
                               lr_ctb85g02.mensagem
       display lr_ctb85g02.mensagem clipped
    end if
 end if

 return retorno.errocod,
        retorno.erromsg

end function

#-----------------------------------------#
 function bdbsa129_processa_ligueme(param)
#-----------------------------------------#

     define param record
         mdtcod    like datmmdtmvt.mdtcod
     end record

     define lr_celdsc record
         celdddcod like datkveiculo.celdddcod,
         celtelnum like datkveiculo.celtelnum
     end record

     define lr_aux record
         param        char(15),
         tmpexc       integer,
         socvclcod    like datkveiculo.socvclcod,
         celdddcodvcl like datkveiculo.celdddcod,
         celtelnumvcl like datkveiculo.celtelnum,
         srrcoddig    like datksrr.srrcoddig,
         celdddcodsrr like datksrr.celdddcod,
         celtelnumsrr like datksrr.celtelnum,
         srrabvnom    like datksrr.srrabvnom
     end record

     define lr_erro record
         coderro   smallint,
         msgerro   char(200)
     end record

     define l_msg    char(300),
            l_status smallint,
            l_assunto char(300),
            l_mensagem char(300),
            l_mail integer

     initialize l_assunto, l_mensagem to null
     # VERIFICA SE ANO EXISTE NENHUM SINAL COM MENOS DE 1
     # MINUTO ENVIADO NA FILA DA DISCADORA.
     let m_current = current
     display m_current, ' Ligue-me [1] ', param.mdtcod, ' Verifica Acionamento Indevido '
     open cbdbsa129_12 using param.mdtcod
     fetch cbdbsa129_12 into l_status

     if  sqlca.sqlcode = 0 then
         let m_current = current
         display m_current, ' Ligue-me [2] ', param.mdtcod,' Acionamento em menos de um minuto'
         display "BOTAO LIGUE-ME ACIONADO INDEVIDAMENTE, AGUARDANDO DISCAGEM."
         let l_mensagem = 'ACIONAMENTO DO BOTÃO EM MENOS DE UM MINUTO PARA MDT: ', param.mdtcod
         let l_assunto = "PROCESSAMENTO DO BOTÃO LIGUE-ME MDT: ", param.mdtcod
         let l_mail = ctx22g00_mail_corpo("BDBSA129", l_assunto, l_mensagem )
         return
     end if
     close cbdbsa129_12
     let m_current = current
     display m_current, ' Ligue-me [2] ', param.mdtcod,' Buscando dados do Socorrista'

     open cbdbsa129_13 using param.mdtcod
     fetch cbdbsa129_13 into lr_aux.socvclcod,
                             lr_aux.celdddcodvcl,
                             lr_aux.celtelnumvcl,
                             lr_aux.srrcoddig,
                             lr_aux.celdddcodsrr,
                             lr_aux.celtelnumsrr,
                             lr_aux.srrabvnom
     close cbdbsa129_13

     if  (lr_aux.celdddcodvcl is null or lr_aux.celdddcodvcl = '') or
         (lr_aux.celtelnumvcl is null or lr_aux.celtelnumvcl = '') then

         if  (lr_aux.celdddcodsrr is null or lr_aux.celdddcodsrr = '') or
             (lr_aux.celtelnumsrr is null or lr_aux.celtelnumsrr = '') then
             let lr_celdsc.celdddcod = 0
             let lr_celdsc.celtelnum = 0
         else
             let lr_celdsc.celdddcod = lr_aux.celdddcodsrr
             let lr_celdsc.celtelnum = lr_aux.celtelnumsrr
         end if

     else
         let lr_celdsc.celdddcod = lr_aux.celdddcodvcl
         let lr_celdsc.celtelnum = lr_aux.celtelnumvcl
     end if

     let m_current = current
     display m_current, ' Ligue-me [3] ', param.mdtcod,' Telefone a ser chamado: ',lr_celdsc.celdddcod, '-', lr_celdsc.celtelnum

     if  lr_celdsc.celdddcod <> 0 and
         lr_celdsc.celtelnum <> 0 then

         # INCLUI NA TABELA DE INTERFACE
         execute pbdbsa129_14 using param.mdtcod,
                                    lr_celdsc.celdddcod,
                                    lr_celdsc.celtelnum

         let l_msg = lr_aux.srrabvnom clipped,
                            ", solicitacao de ligacao realizada com sucesso. ",
                            "Estamos entrando em contato no telefone (",
                            lr_celdsc.celdddcod using "&&", ") ",
                            lr_celdsc.celtelnum using "<&&&&&&&&",
                            " nesse momento. Por favor, aguarde."

     else
         let l_msg = 'TELEFONES NAO ENCONTRADO'
     end if

     let m_current = current
     display m_current, ' Ligue-me [4] ', param.mdtcod,' Mensagem a ser Enviada ao GPS: ', l_msg clipped

     # ENVIA MENSAGEM DE DISCAGEM AO SOCORRISTA
     call ctx01g07_envia_msg_id("","",param.mdtcod,l_msg)
          returning lr_erro.coderro,
                    lr_erro.msgerro

     let m_current = current
     display m_current, ' Ligue-me [5] ', param.mdtcod, ' Retorno do Envio da Mensagem: ', lr_erro.coderro, '-',lr_erro.msgerro clipped

     #Envia email informando processamento do botão
     let l_assunto = 'PROCESSAMENTO DO BOTÃO LIGUE-ME MDT: ', param.mdtcod
     let l_mensagem = 'PROCESSAMENTO DO BOTAO LIGUE-ME'
                      ,' Veículo: ', lr_aux.socvclcod
                      ,' DDD: ', lr_celdsc.celdddcod
                      ,' Celular: ',lr_celdsc.celtelnum
                      ,' QRA: ', lr_aux.srrcoddig
                      ,' Nome: ', lr_aux.srrabvnom clipped
                      ,' Mensagem Enviada ao GPS: ', l_msg clipped

     let l_mensagem = l_mensagem clipped
     whenever error continue
     let l_mail = ctx22g00_mail_corpo("BDBSA129", l_assunto, l_mensagem)
     whenever error stop

 end function


#-----------------------------------#
 function bdbsa129_processa(l_opcao)
#-----------------------------------#

     define l_opcao  char(020)

     define lr_param record
         grlchv like datkgeral.grlchv,
         grlinf like datkgeral.grlinf
     end record

     initialize lr_param.* to null

     let lr_param.grlchv = "PSONPROC" clipped, l_opcao

     display "lr_param.grlchv = ", lr_param.grlchv

     whenever error continue
     open cbdbsa129_15 using lr_param.grlchv
     fetch cbdbsa129_15 into lr_param.grlinf
     close cbdbsa129_15
     whenever error stop


     if  lr_param.grlinf = 'N' then
         return false
     end if

     return true

 end function

# definir intervalo entre os sinais de QRU (rec, ini, fim)
# nao ha limite de tempo entre os sinais, a media devera conter os tempos reais
# formato "0000:00:00 ddmmyyyy" interval
# formato "yyyy-mm-dd 00:00:00" datetime
#----------------------------------------------------------------
function bdbsa129_intervalo(l_param)
#----------------------------------------------------------------
  define l_param record
         mdtbotprgseq  like datmmdtmvt.mdtbotprgseq ,
         mdtcod        like datmmdtmvt.mdtcod       ,
         caddat        date                         ,
         cadhor        datetime hour to second
  end record

  define l_aux record
         texto     char(19)                   ,
         datant    date                       ,
         horant    datetime hour to second    ,
         hora_ini  datetime year to second    ,
         hora_fim  datetime year to second    ,
         intervalo interval hour(3) to second
  end record

  initialize l_aux.* to null

  # definir datetime do botao
  let l_aux.texto = null
  let l_aux.texto = l_param.caddat using "yyyy-mm-dd", " ", l_param.cadhor
  let l_aux.hora_fim  = l_aux.texto

  # buscar sinal QRU anterior. Testar ultimos 3 para nao pegar sinais de
  # eventos posteriores
  whenever error continue
  open cbdbsa129_19 using l_param.mdtbotprgseq, l_param.mdtcod
  whenever error stop

  foreach cbdbsa129_19 into l_aux.datant, l_aux.horant
     let l_aux.texto    = l_aux.datant using "yyyy-mm-dd", " ", l_aux.horant
     let l_aux.hora_ini = l_aux.texto
     if l_aux.hora_ini < l_aux.hora_fim
        then
        exit foreach
     else
        let l_aux.hora_ini = null
     end if
  end foreach

  if l_aux.hora_ini is null
     then
     display "Erro na consulta ultimo sinal, MDT: ", l_param.mdtcod
     return l_aux.intervalo
  end if

  let l_aux.intervalo = l_aux.hora_fim - l_aux.hora_ini

  if l_aux.intervalo < "00:00:01"
     then
     let l_aux.intervalo = null
  end if

  return l_aux.intervalo

end function


#=> SPR-2015-15533 - VERIFICA SE FECHAMENTO AUTOMATICO ESTA "LIGADO"
#------------------------------------------------------------------------------#
function bdbsa129_ligado()
#------------------------------------------------------------------------------#
   define l_grlchv          like datkgeral.grlchv,
          l_grlinf          like datkgeral.grlinf

   let l_grlchv = "PSOFECHAUTOMAT"
   let l_grlinf = "N"              #=> SE NAO ACHAR, CONSIDERA COMO DESLIGADO

   whenever error continue
   open  cbdbsa129_15 using l_grlchv
   fetch cbdbsa129_15  into l_grlinf
   whenever error stop

   if l_grlinf = "S" then
      return true
   end if

   return false

end function


#=> SPR-2015-15533 - TRATA REQUISICAO DE FECHAMENTO DA VENDA
#------------------------------------------------------------------------------#
function bdbsa129_fecha_venda(lr_param)
#------------------------------------------------------------------------------#
   define lr_param          record
          atdsrvnum         like datmmdtmvt.atdsrvnum,
          atdsrvano         like datmmdtmvt.atdsrvano,
          mdtmvtdigcnt      like datmmdtmvt.mdtmvtdigcnt
   end record
   define l_vndepacod       like datmvndepa.vndepacod,
          l_ciaempcod       like datmservico.ciaempcod
   define lr_ret            record
          cod               smallint,
          msg               char(80)
   end record
   define lr_retmai         record
          cod               smallint,
          msg               char(80)
   end record
   define l_horario         datetime hour to second,
          l_msg             varchar(70,0),
          l_msg1            varchar(70,0),
          l_msg2            varchar(70,0),
          l_msg3            varchar(70,0)
   define lr_mail           record
          de                char(500)  , # De
          para              char(5000) , # Para
          cc                char(500)  , # cc
          cco               char(500)  , # cco
          assunto           char(500)  , # Assunto do e-mail
          mensagem          char(32766), # Nome do Anexo
          id_remetente      char(20)   , # Identif. Remetente
          tipo              char(4)      # Tipo corpo e-mail
   end record
   define l_relpamtxt       like igbmparam.relpamtxt

   #=> TRATA OBSERVACAO DO GPS
   if lr_param.mdtmvtdigcnt[11,12]    = "20" then     #=> VISITA TECNICA
      let l_vndepacod = 4     #VISITA TECNICA
   else
      if lr_param.mdtmvtdigcnt[11,12] = "18" then     #=> (EXEC SEM ALTERACAO)
         let l_vndepacod = 3  #FECHADO
      else
         if lr_param.mdtmvtdigcnt[11,12] = "19" then  #=> (EXEC COM ALTERACAO)
            let l_vndepacod = 0
         else
            return  #=> NAO Eh ACIONAMENTO PARA FECHAMENTO (mmp.24/08)
         end if
      end if
   end if

   #=> VERIFICA SE O SERVICO Eh 'PORTO FAZ' (EMPRESA 43)
   whenever error continue
   open  cbdbsa1292121 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch cbdbsa1292121  into l_ciaempcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let lr_ret.cod = sqlca.sqlcode
      let lr_ret.msg = "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                       " NO ACESSO A 'datmservico'!!!"
   else
      if l_ciaempcod is null or
         l_ciaempcod <> 43   then
         return  #=> NAO Eh UM SERVICO DA 'PORTO FAZ'
      end if

      #=> EFETUA O FECHAMENTO DA VENDA
      if m_fechaflg       and  #=> LIGADO
         l_vndepacod <> 0 then #=> SEM ALTERACAO OU VISITA TECNICA
         call opsfa005_fecha_web(lr_param.atdsrvnum,
                                 lr_param.atdsrvano,
                                 l_vndepacod)
              returning lr_ret.*
      else
         let lr_ret.cod = false
      end if
   end if

   #=> TRATA FECHAMENTO NAO EFETUADO
   if not lr_ret.cod then

      let l_horario = current
      initialize l_msg2,
                 l_msg3  to null

      #=> ENVIA E-MAIL
      if m_fechaflg then #=> LIGADO

         initialize lr_mail.* to null
         let lr_mail.de           = "portosegurofaz@portoseguro.com.br"

         #=> APURA DESTINATARIOS
         foreach cbdbsa1292020 into l_relpamtxt
            if lr_mail.para is null then
               let lr_mail.para = l_relpamtxt
            else
               let lr_mail.para = lr_mail.para clipped, ",", l_relpamtxt
            end if
         end foreach

         ### lr_mail.cc           --> NULO
         ### lr_mail.cco          --> NULO

         let lr_mail.assunto   = "SERVICO NAO FECHADO (GPS)"
         if l_vndepacod = 0 then  #=> EXECUTADO COM ALTERACAO
            let lr_mail.assunto   = lr_mail.assunto clipped,
                                 " - COM ALTERACAO"
         end if

         let lr_mail.mensagem     =
             "<html>",
              "<body>",
               "<font face = Times New Roman>",
                "PORTO SEGURO FAZ - SERVI&Ccedil;O N&Atilde;O FECHADO ",
                "AUTOMATICAMENTE (GPS)",
                "<br>",
                "<br>",
                "SERVI&Ccedil;O: ", lr_param.atdsrvnum using "<<<<<<<<<&", "-",
                                    lr_param.atdsrvano using "&&",
                "<br>",
                "<br>"
         if l_vndepacod = 0 then  #=> EXECUTADO COM ALTERACAO
            let lr_mail.mensagem = lr_mail.mensagem clipped,
                "MOTIVO : SERVI&Ccedil;O REALIZADO COM ALTERA&Ccedil;&Atilde;O"
         else
            let lr_mail.mensagem = lr_mail.mensagem clipped,
                "ERRO   : ", lr_ret.msg
         end if
         let lr_mail.mensagem = lr_mail.mensagem clipped,
               "</font>",
              "</body>",
             "</html>"

         let lr_mail.id_remetente = "CT24HS"
         let lr_mail.tipo         = "html"

         #=> ENVIA E-MAIL
         call figrc009_mail_send1 (lr_mail.*)
              returning lr_retmai.*
         if lr_retmai.cod <> 0 then
            let l_msg2 = "ERRO AO ENVIAR E-MAIL... E-MAIL NAO ENVIADO!!!"
            let l_msg3 = "ERRO:", lr_retmai.cod, "-", lr_retmai.msg clipped
         end if
      end if

      #=> ATUALIZA HISTORICO DO SERVICO
      let l_msg        = "Fechamento automatico da Venda (GPS) nao realizado"
      if not m_fechaflg then  #=> DESLIGADO
         let l_msg1    = "Procedimento DESLIGADO!!"
      else
         if l_vndepacod = 0 then #=> EXECUTADO COM ALTERACAO
            let l_msg1 = "Servico executado com alteracao"
         else
            let l_msg1 = lr_ret.msg
         end if
      end if
      #=> ALIMENTA VARIAVEIS GLOBAIS
      let g_issk.usrtip = "F"
      let g_issk.funmat = 999999
      let g_issk.empcod = 1
      let lr_ret.cod = cts10g02_historico (lr_param.atdsrvnum,
                                           lr_param.atdsrvano,
                                           today,
                                           l_horario,
                                           999999,
                                           l_msg, l_msg1, l_msg2, l_msg3, '')
   end if

end function
