#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSA103                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: 197092 - CONTROLE AUTOMATICO DE FROTA                      #
#                  INCONSISTENCIAS DA FROTA (TEMPOS DOS MDT'S)                #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/12/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 26/02/2007 Ligia Mattge               Chamar cta00m08_ver_contingencia      #
# 08/11/2007 Sergio Burini   DVP 25240  Monitor de Rotinas Criticas.          #
# 25/10/2010 Sergio Burini   PSI260894  Temporizador dinamico                 #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_tmpexp       datetime year to second

main

  define l_data         date,
         l_hora         datetime hour to second,
         l_path         char(100),
         l_contingencia smallint,
         l_prcstt       like dpamcrtpcs.prcstt

  call fun_dba_abre_banco("CT24HS")

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  # ---> CARREGAR GLOBAL, POIS E USADO EM OUTRO MODULO
  select sitename
    into g_hostname
    from dual

  let l_path = l_path clipped,"/bdbsa103.log"

  call startlog(l_path)

  call bdbsa103_prepare()

  # --OBTER A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1)
       returning l_data, l_hora

  display " "
  display "---------------------------------------"
  display "BDBSA103 CARGA: ", l_data, " ", l_hora
  display "---------------------------------------"
  display " "

  set lock mode to wait 10
  set isolation to dirty read

  #DVP 25240
  let  m_tmpexp = current

  while true

     call ctx28g00("bdbsa103", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, l_prcstt

     if  l_prcstt = 'A' then

         call cts40g03_exibe_info("I","BDBSA103")

         # --VERIFICA SE O ARQUIVO DE LOG EXISTE, SE NAO EXISTIR, ENCERRA O PROGRAMA
         if not cts40g03_verifi_log_existe(l_path) then
            display "Nao encontrou o arquivo de log !"
            exit program(1)
         end if

         let l_contingencia = null
         call cta00m08_ver_contingencia(4)
              returning l_contingencia

         if l_contingencia then
            display "Contingencia Ativa/Carga ainda nao realizada."
         else
            if ctx34g00_ver_acionamentoWEB(2) then
               display "AcionamentoWeb Ativo."
            else
               call bdbsa103()
            end if
         end if

         call cts40g03_exibe_info("F","BDBSA103")
     end if

     sleep 60

  end while

end main

#-------------------------#
function bdbsa103_prepare()
#-------------------------#

  define l_sql char(500)

  let l_sql = "select a.mdtcod, ",
                    " a.atdvclsgl, ",
                    " b.mdtctrcod ",
               " from datkveiculo a, ",
                    " datkmdt b ",
              " where a.socvclcod = ? ",
                " and a.mdtcod = b.mdtcod "
  prepare pbdbsa103001 from l_sql
  declare cbdbsa103001 cursor for pbdbsa103001

  let l_sql = " select a.socvclcod, ",
                     " a.c24atvcod, ",
                     " b.atlhor, ",
                     " b.atldat, ",
                     " a.srrcoddig, ",
                     " b.lclltt, ",
                     " b.lcllgt, ",
                     " a.cttdat, ",
                     " a.ctthor, ",
                     " a.atdsrvnum, ",
                     " a.atdsrvano ",
                " from dattfrotalocal a, ",
                     " datmfrtpos b, ",
                     " datkveiculo c ",
               " where b.atldat >= ? ",
                 " and b.socvcllcltip = 1 ",
                 " and a.c24atvcod in ('QRV','QRX','QRU','REC','INI','FIM','QRA') ",
                 " and b.lclltt is not null ",
                 " and b.lcllgt is not null ",
                 " and c.mdtcod is not null ",
                 " and b.socvclcod = a.socvclcod ",
                 " and c.socvclcod = a.socvclcod "
  prepare pbdbsa103002 from l_sql
  declare cbdbsa103002 cursor for pbdbsa103002

  let l_sql = " select caddat, ",
                     " cadhor ",
                " from datmmdtinc ",
               " where mdtcod = ? ",
                 " and mdtinctip = ? ",
               " order by caddat desc, ",
                        " cadhor desc "
  prepare pbdbsa103003 from l_sql
  declare cbdbsa103003 cursor for pbdbsa103003

  let l_sql = " select atdprvdat, ",
                     " atddatprg, ",
                     " atdhorprg ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
  prepare pbdbsa103004 from l_sql
  declare cbdbsa103004 cursor for pbdbsa103004

  #PSI 260894 - Temporização das atividades GPS
  let l_sql = "select mdtcod, ",
                    " c24atvcod ",
              "  from dattfrotalocal, ",
                    " datkveiculo, ",
                    " iddkdominio ",
              " where dattfrotalocal.c24atvcod = iddkdominio.cpodes ",
              "   and iddkdominio.cponom       = 'BTNCOMTMP' ",
              "   and dattfrotalocal.socvclcod = datkveiculo.socvclcod"

  prepare pbdbsa103005 from l_sql
  declare cbdbsa103005 cursor for pbdbsa103005

  let l_sql = "select caddat, cadhor, mdtmvtdigcnt ",
              "  from datmmdtmvt mvtqrx ",
              " where mvtqrx.mdtmvtseq = (select max(mdtmvtseq) ",
                                        "  from datmmdtmvt, ",
                                              " iddkdominio ",
                                        " where mdtcod       = ? ",
                                        "   and cpodes       = ? ",
                                        "   and cponom       = 'mdtbotcod' ",
                                        "   and mdtmvttipcod = 2 ",
                                        "   and mdtbotprgseq = cpocod ",
                                        "   and mdtmvtstt    = 2 )"

  prepare pbdbsa103006 from l_sql
  declare cbdbsa103006 cursor for pbdbsa103006


  let l_sql =    "insert into datmmdtmvt (mdtmvtseq, caddat, cadhor,  "
  let l_sql = l_sql clipped,     "        mdtmvtstt, mdttrxnum, empcod, "
  let l_sql = l_sql clipped,     "        funmat, usrtip, snsetritv,    "
  let l_sql = l_sql clipped,     "        mdtcod, mdtmvttipcod, mdtbotprgseq, "
  let l_sql = l_sql clipped,     "        mdtmvtdigcnt, ufdcod, cidnom, "
  let l_sql = l_sql clipped,     "        brrnom, lclltt, lcllgt, "
  let l_sql = l_sql clipped,     "        mdtmvtdircod, mdtmvtvlc, endzon, "
  let l_sql = l_sql clipped,     "        mdtmvtsnlflg, atdsrvnum, atdsrvano) "
  let l_sql = l_sql clipped,     " values (0, current, current, "
  let l_sql = l_sql clipped,     "        1, 0, 1, "
  let l_sql = l_sql clipped,     "        999999, 'F', '', "
  let l_sql = l_sql clipped,     "        ?, ?, ?, "
  let l_sql = l_sql clipped,     "        ?, ?, ?, "
  let l_sql = l_sql clipped,     "        ?, ?, ?, "
  let l_sql = l_sql clipped,     "        ?, ?, ?, "
  let l_sql = l_sql clipped,     "        ?, ?, ?) "
  prepare pbdbsa103007 from l_sql


  let l_sql = "select mvtmax.ufdcod, ",
                   "  mvtmax.cidnom, ",
                   "  mvtmax.brrnom, ",
                   "  mvtmax.lclltt, ",
                   "  mvtmax.lcllgt, ",
                   "  mvtmax.mdtmvtdircod, ",
                   "  mvtmax.mdtmvtvlc, ",
                   "  mvtmax.endzon, ",
                   "  mvtmax.mdtmvtsnlflg, ",
                   "  mvtmax.atdsrvnum, ",
                   "  mvtmax.atdsrvano, ",
                   "  mvtmax.snsetritv  ",
               " from datmmdtmvt mvtmax ",
              " where mvtmax.mdtmvtseq = (select max(mdtmvtseq) ",
                                          " from datmmdtmvt ",
                                         " where mdtcod = ? ) "
  prepare pbdbsa103008 from l_sql
  declare cbdbsa103008 cursor for pbdbsa103008

  let l_sql = "select mvtqrv.caddat ",
              "  from datmmdtmvt mvtqrv ",
              " where mvtqrv.mdtmvtseq = (select max(mdtmvtseq) ",
                                        "  from datmmdtmvt, ",
                                              " iddkdominio ",
                                        " where mdtcod       = ? ",
                                        "   and cpodes       = ? ",
                                        "   and cponom       = 'mdtbotcod' ",
                                        "   and mdtmvttipcod = 2 ",
                                        "   and mdtbotprgseq = cpocod ",
                                        "   and mdtmvtstt    = 1 )"
  prepare pbdbsa103009 from l_sql
  declare cbdbsa103009 cursor for pbdbsa103009

  let l_sql = "select grlinf ",
               " from datkgeral ",
              " where grlchv = ? "

  prepare pbdbsa103010 from l_sql
  declare cbdbsa103010 cursor for pbdbsa103010

  let l_sql = "select cpocod ",
               " from iddkdominio ",
              " where cponom = 'mdtbotcod' ",
                " and cpodes = ? "

  prepare pbdbsa103011 from l_sql
  declare cbdbsa103011 cursor for pbdbsa103011

end function

#-----------------#
function bdbsa103()
#-----------------#

 define lr_dados    record
        c24atvcod   like dattfrotalocal.c24atvcod,
        socvclcod   like dattfrotalocal.socvclcod,
        srrcoddig   like dattfrotalocal.srrcoddig,
        atdprscod   like datmservico.atdprscod,
        atdvclsgl   like datkveiculo.atdvclsgl,
        atldat      like datmfrtpos.atldat,
        atlhor      like datmfrtpos.atlhor,
        mdtcod      like datkveiculo.mdtcod,
        srrabvnom   like datksrr.srrabvnom,
        mdtctrcod   like datkmdt.mdtctrcod,
        lclltt      like datmfrtpos.lclltt,
        lcllgt      like datmfrtpos.lcllgt,
        cttdat      like dattfrotalocal.cttdat,
        ctthor      like dattfrotalocal.ctthor,
        atdsrvnum   like dattfrotalocal.atdsrvnum,
        atdsrvano   like dattfrotalocal.atdsrvano,
        tmp_sinal   interval hour(06) to second,
        tmp_stt     interval hour(06) to second,
        tmp_prg     interval hour(06) to second,
        caddat       like datmmdtmvt.caddat,
        cadhor       like datmmdtmvt.cadhor,
        mdtmvtdigcnt like datmmdtmvt.mdtmvtdigcnt

 end record

 define l_data_calc        date,
        l_data             date,
        l_cod_erro         smallint,
        l_des_erro         char(70),
        l_atdprvdat        like datmservico.atdprvdat,
        l_atddatprg        like datmservico.atddatprg,
        l_atdhorprg        like datmservico.atdhorprg,
        l_hora             datetime hour to minute,
        l_prev             interval hour(06) to second,
        l_soma_prev        interval hour(06) to second,
        l_intervalo        interval hour(06) to second,
        l_prev_char        char(10),
        l_param            like datkgeral.grlinf,
        l_tmewtg           integer,
        l_msg_alerta       char(100),
        l_nxt_mdtbotprgseq char(003),
        l_contingencia     smallint,
        l_dathortxt        char(19),
        l_dathorqrx        datetime year to second,
        l_dathoratu        datetime year to second,
        l_tmpqrx           interval minute(03) to minute,

        l_qrv_mdtmvttipcod  like datmmdtmvt.mdtmvttipcod,
        l_qrv_mdtbotprgseq  like datmmdtmvt.mdtbotprgseq,
        l_qrv_mdtmvtdigcnt  like datmmdtmvt.mdtmvtdigcnt,
        l_qrv_ufdcod        like datmmdtmvt.ufdcod,
        l_qrv_cidnom        like datmmdtmvt.cidnom,
        l_qrv_brrnom        like datmmdtmvt.brrnom,
        l_qrv_lclltt        like datmmdtmvt.lclltt,
        l_qrv_lcllgt        like datmmdtmvt.lcllgt,
        l_qrv_mdtmvtdircod  like datmmdtmvt.mdtmvtdircod,
        l_qrv_mdtmvtvlc     like datmmdtmvt.mdtmvtvlc,
        l_qrv_endzon        like datmmdtmvt.endzon,
        l_qrv_mdtmvtsnlflg  like datmmdtmvt.mdtmvtsnlflg,
        l_qrv_atdsrvnum     like datmmdtmvt.atdsrvnum,
        l_qrv_atdsrvano     like datmmdtmvt.atdsrvano,
        l_qrv_snsetritv     like datmmdtmvt.snsetritv



  # --> INICIALIZACAO DAS VARIAVEIS

  let l_cod_erro   = null
  let l_des_erro   = null
  let l_data_calc  = null
  let l_data       = null
  let l_soma_prev  = "00:05:00"
  let l_atdprvdat  = null
  let l_hora       = null
  let l_prev       = null
  let l_prev_char  = null
  let l_msg_alerta = null
  let l_atddatprg  = null
  let l_atdhorprg  = null
  let l_intervalo  = null

  initialize lr_dados to null

  # --> BUSCA DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1)
       returning l_data, l_hora


  #######################################################
  # PROCESSO ATIVIDADES TEMPORIZADA
  #######################################################
  foreach cbdbsa103005 into lr_dados.mdtcod,
                            lr_dados.c24atvcod

     # PESQUISA O ULTIMA ATIVIDADE
     open  cbdbsa103006 using lr_dados.mdtcod,
                              lr_dados.c24atvcod
     fetch cbdbsa103006 into  lr_dados.caddat,
                              lr_dados.cadhor,
                              lr_dados.mdtmvtdigcnt
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           display "Não há sinais a serem processados"
           continue foreach
        else
           display "Erro SELECT cbdbsa103006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           display "mdt: ", lr_dados.mdtcod
           exit program(1)
        end if
     end if
     close cbdbsa103006

     if  lr_dados.c24atvcod <> 'QRX' then
         let l_param = "PSOTMPMAX" clipped, lr_dados.c24atvcod
         open cbdbsa103010 using l_param
         fetch cbdbsa103010 into l_tmewtg

         if  sqlca.sqlcode <> 0 then
             display "Parametro ", l_param clipped, " nao localizado. ERRO: ", sqlca.sqlcode
             continue foreach
         end if

         # SE A ATIVIDADE NAO FOR TEMPORIZADA
         if l_tmewtg is null or l_tmewtg = " " then
            display lr_dados.c24atvcod clipped, " nao e temporizado"
            continue foreach
         end if
     else
         let l_tmewtg = lr_dados.mdtmvtdigcnt
     end if

     let l_dathortxt = extend(lr_dados.caddat, year to year), "-",
                       extend(lr_dados.caddat, month to month), "-",
                       extend(lr_dados.caddat, day to day), " ",
                       lr_dados.cadhor

     let l_dathorqrx = l_dathortxt

     # BUSCA DATA-HORA DO BANCO
     select current into l_dathoratu from dual

     # VERIFICA SE JA PASSOU O TEMPO DO QRX TEMPORIZADO
     let l_dathorqrx = l_dathorqrx + l_tmewtg units minute

     if l_dathoratu > l_dathorqrx then

        display "	BUSCA INFORMACAO DO ULTIMO SINAL PARA INCLUIR O QRV"
        # BUSCA INFORMACAO DO ULTIMO SINAL PARA INCLUIR O QRV
        open  cbdbsa103008 using lr_dados.mdtcod
        fetch cbdbsa103008 into  l_qrv_ufdcod,
                                 l_qrv_cidnom,
                                 l_qrv_brrnom,
                                 l_qrv_lclltt,
                                 l_qrv_lcllgt,
                                 l_qrv_mdtmvtdircod,
                                 l_qrv_mdtmvtvlc,
                                 l_qrv_endzon,
                                 l_qrv_mdtmvtsnlflg,
                                 l_qrv_atdsrvnum,
                                 l_qrv_atdsrvano,
                                 l_qrv_snsetritv

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              continue foreach
           else
              display "Erro SELECT cbdbsa103008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
              display "mdt: ", lr_dados.mdtcod
              exit program(1)
           end if
        end if
        close cbdbsa103008

        let l_param = "PSOTMPNXT" clipped, lr_dados.c24atvcod
        open cbdbsa103010 using l_param
        fetch cbdbsa103010 into l_nxt_mdtbotprgseq

        if  sqlca.sqlcode <> 0 then
            display "Parametro ", l_param clipped, " nao localizado. ERRO: ", sqlca.sqlcode
            continue foreach
        end if

        # VERIFICA SE HA QRV PENDENTE DE PROCESSAMENTO, SE HOUVER IGNORA PROCESSO
        open  cbdbsa103009 using lr_dados.mdtcod,
                                 l_nxt_mdtbotprgseq
        fetch cbdbsa103009 into  lr_dados.caddat
        if sqlca.sqlcode <> notfound then
           display "Ja existe", l_nxt_mdtbotprgseq clipped, " pendente"
           continue foreach
        end if
        close cbdbsa103009

        display "INCLUI BOTAO ", l_nxt_mdtbotprgseq, " AUTOMATICAMENTE"

        open cbdbsa103011 using l_nxt_mdtbotprgseq
        fetch cbdbsa103011 into l_qrv_mdtbotprgseq

        # INCLUI BOTAO QRV AUTOMATICAMENTE
        whenever error continue
        let l_qrv_mdtmvttipcod = 2  # BOTAO
        #let l_qrv_mdtbotprgseq = 9  # QRV
        let l_qrv_mdtmvtdigcnt = "" # COMPLEMENTO

        execute pbdbsa103007 using lr_dados.mdtcod,
                                   l_qrv_mdtmvttipcod,
                                   l_qrv_mdtbotprgseq,
                                   l_qrv_mdtmvtdigcnt,
                                   l_qrv_ufdcod,
                                   l_qrv_cidnom,
                                   l_qrv_brrnom,
                                   l_qrv_lclltt,
                                   l_qrv_lcllgt,
                                   l_qrv_mdtmvtdircod,
                                   l_qrv_mdtmvtvlc,
                                   l_qrv_endzon,
                                   l_qrv_mdtmvtsnlflg,
                                   l_qrv_atdsrvnum,
                                   l_qrv_atdsrvano
        whenever error stop
        if sqlca.sqlcode <> 0 then
           display "Erro sql pbdbsa103007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           display "mdt: ", lr_dados.mdtcod
           exit program(1)
        end if

        let l_msg_alerta   = l_nxt_mdtbotprgseq clipped, " RECEBIDO EM ", l_qrv_ufdcod, " - ", l_qrv_cidnom clipped, " - ", l_qrv_brrnom

        call ctx01g07_envia_msg_id("",  #numero do servico
                                   "",  #ano do servico
                                   lr_dados.mdtcod,# codigo mdt
                                   l_msg_alerta )
                         returning l_cod_erro, l_des_erro

        if l_cod_erro <> 0 then
           display "Erro na funcao ctx01g07_envia_msg_id() ERRO - ", l_cod_erro
        end if

     end if

  end foreach

  ###########################################################
  ##### PROCESSO DE ALERTAS DA FROTA DESATIVADOS
  ###########################################################
  #### --> CALCULA A DATA PARA EXTRACAO DOS DADOS
  ###let l_data_calc = (l_data - 1 units day)
  ###
  ###open cbdbsa103002 using l_data_calc
  ###
  ###foreach cbdbsa103002 into lr_dados.socvclcod,
  ###                          lr_dados.c24atvcod,
  ###                          lr_dados.atlhor,
  ###                          lr_dados.atldat,
  ###                          lr_dados.srrcoddig,
  ###                          lr_dados.lclltt,
  ###                          lr_dados.lcllgt,
  ###                          lr_dados.cttdat,
  ###                          lr_dados.ctthor,
  ###                          lr_dados.atdsrvnum,
  ###                          lr_dados.atdsrvano
  ###
  ###   let l_contingencia = null
  ###   call cta00m08_ver_contingencia(4)
  ###        returning l_contingencia
  ###
  ###   if l_contingencia then
  ###      display "Contingencia Ativa/Carga ainda nao realizada.."
  ###      exit foreach
  ###   end if
  ###
  ###   # --> TEMPO DO ULTIMO SINAL
  ###   let lr_dados.tmp_sinal = ctx01g07_dif_tempo(l_data,
  ###                                               l_hora,
  ###                                               lr_dados.atldat,
  ###                                               lr_dados.atlhor)
  ###
  ###   # --> TEMPO DA ULTIMA SITUACAO
  ###   let lr_dados.tmp_stt   = ctx01g07_dif_tempo(l_data,
  ###                                               l_hora,
  ###                                               lr_dados.cttdat,
  ###                                               lr_dados.ctthor)
  ###
  ###
  ###   # --> VIATURA SEM CONTATO SUPERIOR AO TEMPO PADRAO
  ###   call bdbsa103_alerta (lr_dados.socvclcod, # --> CODIGO DO VEICULO
  ###                         1,                  # --> TIPO DE ALERTA
  ###                         lr_dados.tmp_sinal, # --> TEMPO DE ESPERA
  ###                         "00:20:00",         # --> TEMPO LIMITE DE ESPERA
  ###                         "00:20:00",         # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                         lr_dados.srrcoddig, # --> CODIGO DO SOCORRISTA
  ###                         "APERTE O BOTAO F1 PARA CONFIRMAR SUA SITUACAO E POSICIONAMENTO", # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                         "S")                # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###
  ###   case lr_dados.c24atvcod
  ###
  ###      when 'QRX'
  ###
  ###        # --> QRX EXCEDIDO
  ###
  ###        call bdbsa103_alerta (lr_dados.socvclcod, # --> CODIGO DO VEICULO
  ###                              13,                 # --> TIPO DE ALERTA
  ###                              lr_dados.tmp_stt,   # --> TEMPO DE ESPERA
  ###                              "01:00:00",         # --> TEMPO LIMITE DE ESPERA
  ###                              "00:30:00",         # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                              lr_dados.srrcoddig, # --> CODIGO DO SOCORRISTA
  ###                              "PRESSIONE F1 E CONFIRME A SUA ATIVIDADE",# --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                              "N")                # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###      when 'QRA'
  ###
  ###         # --> VIATURA EM QRA SEM CONFIRMACAO SUPERIOR AO TEMPO PADRAO
  ###         call bdbsa103_alerta (lr_dados.socvclcod, # --> CODIGO DO VEICULO
  ###                               10,                 # --> TIPO DE ALERTA
  ###                               lr_dados.tmp_stt,   # --> TEMPO DE ESPERA
  ###                               "00:03:00",         # --> TEMPO LIMITE DE ESPERA
  ###                               "00:10:00",         # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                               lr_dados.srrcoddig, # --> CODIGO DO SOCORRISTA
  ###                               "TEMPO DE QRA EXCEDIDO, PRESSIONE QRV OU QRX", # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                               "N")                # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###      when 'QRU'
  ###
  ###         # --> VIATURA EM QRU SEM CONFIRMACAO SUPERIOR AO TEMPO PADRAO
  ###         call bdbsa103_alerta (lr_dados.socvclcod,  # --> CODIGO DO VEICULO
  ###                               8,                   # --> TIPO DE ALERTA
  ###                               lr_dados.tmp_stt,    # --> TEMPO DE ESPERA
  ###                               "00:02:00",          # --> TEMPO LIMITE DE ESPERA
  ###                               "00:10:00",          # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                               lr_dados.srrcoddig,  # --> CODIGO DO SOCORRISTA
  ###                               "VOCE RECEBEU UMA QRU E NAO APERTOU O QRU-REC. ENVIE IMEDIATAMENTE", # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                               "N")                 # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###      when 'REC'
  ###
  ###        # --> ALERTA REFERENTE AO TERMINO DE PREVISAO
  ###
  ###        # --> BUSCA A PREVISAO DO SERVICO
  ###        open cbdbsa103004 using lr_dados.atdsrvnum, lr_dados.atdsrvano
  ###        whenever error continue
  ###        fetch cbdbsa103004 into l_atdprvdat,
  ###                                l_atddatprg,
  ###                                l_atdhorprg
  ###
  ###        whenever error stop
  ###
  ###        if sqlca.sqlcode <> 0 and
  ###           sqlca.sqlcode <> notfound then
  ###           display "Erro SELECT cbdbsa103004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
  ###           display "bdbsa103() / ", lr_dados.atdsrvnum, "/", lr_dados.atdsrvano
  ###           exit program(1)
  ###        end if
  ###
  ###        close cbdbsa103004
  ###
  ###        if l_atdprvdat is null then
  ###           let l_atdprvdat = "00:20"
  ###        end if
  ###
  ###        if l_atddatprg is null and l_atdhorprg is null then #SRV IMEDIATO
  ###
  ###           # --> ALERTA 5 MINUTOS ANTES DO TERMINO DA PREVISAO
  ###           let l_prev_char = l_atdprvdat, ":00"
  ###           let l_prev      = l_prev_char
  ###
  ###           # --> VERIFICA O TIPO DE MENSAGEM A SER ENVIADO AO PRESTADOR
  ###           if lr_dados.tmp_stt < l_prev then
  ###              let l_msg_alerta = "ATENCAO, O TERMINO DA PREVISAO ESTA PROXIMO. APERTE O BOTAO INICIO AO CHEGAR NO QTH"
  ###           else
  ###
  ###              if lr_dados.tmp_stt > (l_prev + 5 units minute) then
  ###                 let l_msg_alerta = "ATENCAO, QRU EM ATRASO"
  ###              else
  ###                 let l_msg_alerta = "ATENCAO, QRU VENCIDA"
  ###              end if
  ###
  ###           end if
  ###
  ###           let l_prev = l_prev + l_soma_prev
  ###
  ###           call bdbsa103_alerta (lr_dados.socvclcod,  # --> CODIGO DO VEICULO
  ###                                 14,                  # --> TIPO DE ALERTA
  ###                                 lr_dados.tmp_stt,    # --> TEMPO DE ESPERA
  ###                                 l_prev,              # --> TEMPO LIMITE DE ESPERA
  ###                                 "00:05:00",          # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                                 lr_dados.srrcoddig,  # --> CODIGO DO SOCORRISTA
  ###                                 l_msg_alerta,        # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                                 "N")                 # --> ENVIA POLL ? (S)SIM (N)NAO
  ###        else  # ---> SERVICO PROGRAMADO
  ###
  ###           call cts40g03_data_hora_banco(1)
  ###                returning l_data, l_hora
  ###
  ###           # --> TEMPO DA ULTIMA SITUACAO
  ###           let lr_dados.tmp_prg   = ctx01g07_dif_tempo(l_data,
  ###                                                       l_hora,
  ###                                                       l_atddatprg,
  ###                                                       l_atdhorprg)
  ###
  ###           let l_intervalo = "-00:05:00"
  ###
  ###           if lr_dados.tmp_prg > l_intervalo then
  ###
  ###              let l_intervalo = "00:00:00"
  ###
  ###              if lr_dados.tmp_prg > l_intervalo then
  ###
  ###                 let l_intervalo = "00:05:00"
  ###
  ###                 if lr_dados.tmp_prg > l_intervalo then
  ###                    let l_msg_alerta = "ATENCAO, QRU EM ATRASO"
  ###                 else
  ###                    let l_msg_alerta = "ATENCAO, QRU VENCIDA"
  ###                 end if
  ###
  ###              else
  ###                 let l_msg_alerta = "ATENCAO, O TERMINO DA PREVISAO ESTA PROXIMO. APERTE O BOTAO INICIO AO CHEGAR NO QTH"
  ###              end if
  ###
  ###              let lr_dados.tmp_prg = "00:05:00"
  ###              let l_prev           = "00:01:00"
  ###
  ###              call bdbsa103_alerta (lr_dados.socvclcod,  # --> CODIGO DO VEICULO
  ###                                    14,                  # --> TIPO DE ALERTA
  ###                                    lr_dados.tmp_prg,    # --> TEMPO DE ESPERA
  ###                                    l_prev,              # --> TEMPO LIMITE DE ESPERA
  ###                                    "00:05:00",          # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                                    lr_dados.srrcoddig,  # --> CODIGO DO SOCORRISTA
  ###                                    l_msg_alerta,        # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                                    "N")                 # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###           end if
  ###
  ###        end if
  ###
  ###      when 'INI'
  ###
  ###         # --> QRU-INI EXCEDIDO
  ###         call bdbsa103_alerta (lr_dados.socvclcod,  # --> CODIGO DO VEICULO
  ###                               12,                  # --> TIPO DE ALERTA
  ###                               lr_dados.tmp_stt,    # --> TEMPO DE ESPERA
  ###                               "01:00:00",          # --> TEMPO LIMITE DE ESPERA
  ###                               "00:30:00",          # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                               lr_dados.srrcoddig,  # --> CODIGO DO SOCORRISTA
  ###                               "PRESSIONE F1 PARA CONFIRMAR SUA ATIVIDADE", # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                               "N")                 # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###      when 'FIM'
  ###
  ###         # --> QRU-FIM EXCEDIDO
  ###         call bdbsa103_alerta (lr_dados.socvclcod,  # --> CODIGO DO VEICULO
  ###                               11,                  # --> TIPO DE ALERTA
  ###                               lr_dados.tmp_stt,    # --> TEMPO DE ESPERA
  ###                               "00:03:00",          # --> TEMPO LIMITE DE ESPERA
  ###                               "00:10:00",          # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
  ###                               lr_dados.srrcoddig,  # --> CODIGO DO SOCORRISTA
  ###                               "TEMPO DE QRU-FIM EXCEDIDO, PRESSIONE QRV, QRX OU QTP", # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
  ###                               "N")                 # --> ENVIA POLL ? (S)SIM (N)NAO
  ###
  ###   end case
  ###
  ###end foreach
  ###
  ###close cbdbsa103002

end function

#------------------------------------#
function bdbsa103_alerta(lr_parametro)
#------------------------------------#

  define lr_parametro record
         socvclcod    like datkveiculo.socvclcod,     # --> CODIGO DO VEICULO
         mdtinctip    like datmmdtinc.mdtinctip,      # --> TIPO DE ALERTA
         tempo_espera interval hour(06) to second,    # --> TEMPO DE ESPERA
         tempo_limite interval hour(06) to second,    # --> TEMPO LIMITE DE ESPERA
         tempo_verifi interval hour(06) to second,    # --> TEMPO ANTES DE REALIZAR A NOVA VERIFICACAO
         srrcoddig    like dattfrotalocal.srrcoddig,  # --> CODIGO DO SOCORRISTA
         msg_alerta   char(300),                      # --> MENSAGEM REFERENTE AO TIPO DE ALERTA
         pollflg      char(01)                        # --> ENVIA POLL ? (S)SIM (N)NAO
  end record

  define l_mdtcod     like datkveiculo.mdtcod,
         l_atdvclsgl  like datkveiculo.atdvclsgl,
         l_mdtctrcod  like datkmdt.mdtctrcod,
         l_caddat     like datmmdtinc.caddat,
         l_cadhor     like datmmdtinc.cadhor,
         l_cod_erro   smallint,
         l_tempo      interval hour(06) to second

  # --> INICIALIZACAO DAS VARIAVEIS
  let l_mdtcod    = null
  let l_atdvclsgl = null
  let l_mdtctrcod = null
  let l_caddat    = null
  let l_cadhor    = null
  let l_cod_erro  = null
  let l_tempo     = null

  # --> VERIFICA SE O TEMPO DE ESPERA E SUPERIOR AO TEMPO LIMITE
  if lr_parametro.tempo_espera > lr_parametro.tempo_limite then

     open cbdbsa103001 using lr_parametro.socvclcod
     fetch cbdbsa103001 into l_mdtcod, l_atdvclsgl, l_mdtctrcod
     close cbdbsa103001

     # --> PESQUISAR TEMPO DO ULTIMO ALERTA
     open cbdbsa103003 using l_mdtcod, lr_parametro.mdtinctip
     whenever error continue
     fetch cbdbsa103003 into l_caddat, l_cadhor
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let l_tempo = "02:00:00" # GRAVA
        else
           display "Erro SELECT cbdbsa103003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           display "bdbsa103_alerta() / ", l_mdtcod, "/", lr_parametro.mdtinctip
           exit program(1)
        end if
     else
        let l_tempo = ctx01g07_espera(l_caddat, l_cadhor)
     end if

     close cbdbsa103003

     if l_tempo > lr_parametro.tempo_verifi then

        # --> GRAVA ALERTA REFERENTE A: 1 --> SEM SINAL
        let l_cod_erro = ctx01g07_inc_alerta(lr_parametro.socvclcod,
                                             l_mdtcod,
                                             lr_parametro.srrcoddig,
                                             lr_parametro.mdtinctip)

        if l_cod_erro <> 0 and l_cod_erro <> 1 then
           display "Erro na funcao ctx01g07_inc_alerta() !"
           exit program(1)
        end if

        # --> ENVIA PAGER PARA SOCORRISTA
        let l_cod_erro = ctx01g07_envia_pager(lr_parametro.socvclcod,
                                              "CENTRAL 24H - INCONSISTENCIA DE FROTA",
                                              lr_parametro.msg_alerta)

        if l_cod_erro <> 0 then
           display "Erro na funcao ctx01g07_envia_pager() !"
           exit program(1)
        end if

        if lr_parametro.pollflg = "S" then

           # --> ENVIA POLL PARA A VIATURA
           let l_cod_erro = ctx01g07_envia_msg("", "", l_mdtcod, "POLL")

           if l_cod_erro <> 0 then
              display "Erro na funcao ctx01g07_envia_msg() !"
              exit program(1)
           end if

        end if

     end if

  end if


end function
