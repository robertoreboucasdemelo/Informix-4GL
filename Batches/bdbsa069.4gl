#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: BDBSA069                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTO.                      #
#                  ACIONAMENTO AUTOMATICO DOS SERVICOS AUTO.                  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID/RAJI D.JAHCHAN                                #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 18/10/2006 Ligia Mattge    PSI202363  Alteração nos parametros de retorno da#
#                                       funcao cts40g13_obter_veic e alt no   #
#                                       datracncid.cidacndst (Merge)          #
# 02/12/2006 Ligia Mattge    PSI205206  ciaempcod                             #
# 14/02/2007 Ligia Mattge               Chamar cta00m08_ver_contingencia      #
# 30/07/2007 Ligia Mattge    PSI211427  Tentar acionar mesmo depois que excedeu
#                                       o tempo limite e foi pro radio.       #
# 21/07/2008                 PSI 214558 Inclusao metodo grava tempo distancia #
# 13/08/2009 Sergio Burini   PSI 244236 Inclusão do Sub-Dairro                #
# 29/12/2009 Kevellin        PSI 251712 Gerenciamento da Frota Extra          #
#-----------------------------------------------------------------------------#

database porto

  define mr_parametro  record
         cidacndst     like datracncid.cidacndst,
         acnlmttmp     like datkatmacnprt.acnlmttmp,
         acntntlmtqtd  like datkatmacnprt.acntntlmtqtd,
         netacnflg     like datkatmacnprt.netacnflg,
         atmacnprtcod  like datkatmacnprt.atmacnprtcod
  end record

  define mr_principal  record
         atdsrvnum       like datmservico.atdsrvnum,
         atdsrvano       like datmservico.atdsrvano,
         atdlibhor       like datmservico.atdlibhor,
         atdlibdat       like datmservico.atdlibdat,
         atddatprg       like datmservico.atddatprg,
         atdhorprg       like datmservico.atdhorprg,
         atdhorpvt       like datmservico.atdhorpvt,
         acntntqtd       like datmservico.acntntqtd,
         atdcstvlr       like datmservico.atdcstvlr,
         atdsrvorg       like datmservico.atdsrvorg,
         asitipcod       like datmservico.asitipcod,
         vclcoddig       like datmservico.vclcoddig,
         ciaempcod       like datmservico.ciaempcod,
         c24opemat       like datmservico.c24opemat,
         atdfnlflg       like datmservico.atdfnlflg,
         acnnaomtv       like datmservico.acnnaomtv,
         srvprsacnhordat like datmservico.srvprsacnhordat
  end record

  define mr_prestador  record
         cod_motivo    smallint,
         msg_motivo    like datmservico.acnnaomtv,
         pstcoddig     like datkveiculo.pstcoddig,
         nomgrr        like dpaksocor.nomgrr,
         distancia     decimal(8,4)
  end record

  define mr_local    record
         lclidttxt      like datmlcl.lclidttxt,
         lgdtip         like datmlcl.lgdtip,
         lgdnom         like datmlcl.lgdnom,
         lgdnum         like datmlcl.lgdnum,
         lclbrrnom      like datmlcl.lclbrrnom,
         brrnom         like datmlcl.brrnom,
         cidnom         like datmlcl.cidnom,
         ufdcod         like datmlcl.ufdcod,
         lclrefptotxt   like datmlcl.lclrefptotxt,
         endzon         like datmlcl.endzon,
         lgdcep         like datmlcl.lgdcep,
         lgdcepcmp      like datmlcl.lgdcepcmp,
         lclltt         like datmlcl.lclltt,
         lcllgt         like datmlcl.lcllgt,
         dddcod         like datmlcl.dddcod,
         lcltelnum      like datmlcl.lcltelnum,
         lclcttnom      like datmlcl.lclcttnom,
         c24lclpdrcod   like datmlcl.c24lclpdrcod,
         sqlcode        integer,
         emeviacod      like datmlcl.emeviacod,
         celteldddcod   like datmlcl.celteldddcod,
         celtelnum      like datmlcl.celtelnum,
         endcmp         like datmlcl.endcmp

  end record

  define mr_veiculo     record
         cod_motivo     smallint,
         msg_motivo     like datmservico.acnnaomtv,
         srrcoddig      like dattfrotalocal.srrcoddig,
         socvclcod      like datkveiculo.socvclcod,
         pstcoddig      like datkveiculo.pstcoddig,
         distancia      decimal(8,4),
         lclltt         like datmfrtpos.lclltt,
         lcllgt         like datmfrtpos.lcllgt,
         srrabvnom      like datksrr.srrabvnom,
         tempo_total    decimal(6,1)
  end record

  define m_agora        datetime hour to second,
         m_tmpexp       datetime year to second,
         l_prcstt       like dpamcrtpcs.prcstt,
         l_msg          char(100),
         m_atdfnlflg     like datmservico.atdfnlflg

main

  define l_path         char(100),
         l_arg_numero   like datmservico.atdsrvnum,
         l_arg_ano      like datmservico.atdsrvano,
         l_tempo_limite interval hour to second,
         l_resultado    integer,
         l_em_uso       smallint,
         l_indice       smallint,
         l_erro         integer,
         l_c24opemat    like datmservico.c24opemat,
         l_atdlibhor     like datmservico.atdlibhor,
         l_atdlibdat     like datmservico.atdlibdat,
         l_atddatprg     like datmservico.atddatprg,
         l_atdhorprg     like datmservico.atdhorprg,
         l_acnnaomtv     like datmservico.acnnaomtv,
         l_espera        interval hour(6) to second,
         l_limite_espera interval hour(6) to second,
         l_contingencia  smallint,
         l_atdfnlflg     like datmservico.atdfnlflg,
         l_srvprsacnhordat like datmservico.srvprsacnhordat,
         l_data_ac         date,
         l_hora_ac         datetime hour to minute

  define al_apoio  array[3] of record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
  end record

  let l_msg          = null
  let l_path         = null
  let l_tempo_limite = null
  let l_arg_numero   = arg_val(1) # -> NUMERO DO SERVICO
  let l_arg_ano      = arg_val(2) # -> ANO DO SERVICO
  let l_resultado    = null
  let l_em_uso       = null
  let l_c24opemat    = null
  let l_indice       = null
  let m_agora        = null
  let l_erro         = null
  let l_atdlibhor    = null
  let l_atdlibdat    = null
  let l_atddatprg    = null
  let l_atdhorprg    = null
  let l_acnnaomtv    = null
  let l_espera        = null
  let l_limite_espera = null
  let l_contingencia  = null
  let l_atdfnlflg     = null
  let m_atdfnlflg     = null
  let l_srvprsacnhordat = null
  let l_data_ac = null
  let l_hora_ac = null

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdbsa069.log"

  call startlog(l_path)

  call fun_dba_abre_banco("CT24HS")

  # --CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read

  # --TEMPO PARA VERIFICAR SE O REGISTRO ESTA ALOCADO
  set lock mode to wait 20

  # --PREPARA OS COMANDOS SQL
  call bdbsa069_prepare()

  #----------------------------------------------------------------------------------------------------
  # VERIFICA SE O PROCESSO DEVE ACIONAR O SRV RECBIDO NO PARAMETRO OU PESQUISAR SRV EM ACION AUTOMATICO
  #----------------------------------------------------------------------------------------------------
  if l_arg_numero is not null and   # -> NUMERO DO SERVICO
     l_arg_ano    is not null then  # -> ANO DO SERVICO

     #---------------------------------------------------------------------------
     # OBTEM TEMPO MAXIMO QUE O SERVICO DEVE PERMANECER NO ACIONAMENTO AUTOMATICO
     #---------------------------------------------------------------------------
     call cts10g06_dados_servicos(16, l_arg_numero, l_arg_ano)
          returning l_resultado,
                    l_msg,
                    l_atdlibhor,
                    l_atdlibdat,
                    l_atddatprg,
                    l_atdhorprg,
                    l_acnnaomtv,
                    l_atdfnlflg,
                    l_srvprsacnhordat

     if l_resultado <> 1 then
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if

     let m_atdfnlflg     = l_atdfnlflg

     if l_atddatprg is null then
        # SERVICO IMEDIATO
        #let l_tempo_limite = "00:05:00"
        let l_limite_espera = "0:10:00"
     else
        # SERVICO PROGRAMADO
        #let l_tempo_limite = "00:55:00"
        let l_limite_espera = "00:20:00"
     end if

     let l_data_ac = date(l_srvprsacnhordat)
     let l_hora_ac = time(l_srvprsacnhordat)

     let l_espera = cts40g03_espera(l_data_ac, l_hora_ac)

     if l_espera is null then
        let l_msg = "Erro no calculo do tempo de espera ", l_arg_numero, l_arg_ano
        display l_msg
        call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
        exit program(1)
     end if

     #------------------------------------------------------------------------------
     # LACO INFINITO ATE O ACIONAMENTO DO SRV OU REGRA PARA NAO ACIONAR O SRV
     #------------------------------------------------------------------------------
     while true

        let m_agora = current
        display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                         l_arg_ano    using "&&",
                         " -> EM ACIONAMENTO AUTOMATICO. "

        let l_espera = cts40g03_espera(l_data_ac, l_hora_ac)
        display m_agora, " Servico: ",
               l_arg_numero using "<<<<<<<<<&", "/",
               l_arg_ano    using "&&",
               " ESPERA", l_espera, " DATA ",l_data_ac," HORA ",l_hora_ac

        # VERIFICA SE ESTA NA HORA DE ENVIAR O SERVICO PARA O RADIO
        if (l_espera >= l_limite_espera) and l_atdfnlflg = "A" then

           let l_atdfnlflg = bdbsa069_envia_radio(l_arg_numero, l_arg_ano)

        end if

        #------------------------
        # TENTA ACIONAR O SERVICO
        #------------------------

        # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
        if cts40g18_srv(l_arg_numero,
                        l_arg_ano) then
           let m_agora = current
           display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                            l_arg_ano    using "&&",
                            " -> JA CONCLUIDO!."
           exit program(1)
        end if

        #---------------------------------------------------------
        # VERIFICA SE O SERVICO ESTA SENDO ALTERADO PELO ATENDENTE
        #---------------------------------------------------------
        call cts40g18_srv_em_uso(l_arg_numero,
                                 l_arg_ano)
             returning l_em_uso,
                       l_c24opemat

        if l_c24opemat is not null then     # -> SERVICO ESTA EM USO(ATENDENTE)
           let m_agora = current
           display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                            l_arg_ano    using "&&",
                            " -> EM USO POR: ", l_c24opemat
           exit program(1)
        end if

        if l_c24opemat is null then    # -> SERVICO NAO ESTA EM USO(ATENDENTE)
                                       # -> SERVICO PRESO C/MATRICULA DO SISTEMA

           #------------------------------------------
           # BLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
           #------------------------------------------
           let l_resultado = cts40g06_bloq_srv(l_arg_numero,
                                               l_arg_ano)

           if l_resultado <> 0 then
              let l_msg = "Erro ao chamar a funcao cts40g06_bloq_srv()"
              display l_msg
              call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
              exit program(1)
           end if

           # -> FUNCAO QUE AGUARDA O TEMPO NECESSARIO PARA DISTRIBUIR OS SERVICOS
           call cts40g03_srv_dist_acn(l_arg_numero)

           # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
           if cts40g18_srv_finalizado(l_arg_numero, l_arg_ano) then
              let m_agora = current
              display m_agora, " Servico: ",
                      l_arg_numero using "<<<<<<<<<&", "/",
                      l_arg_ano    using "&&",
                      " -> JA CONCLUIDO!"
              exit program(1)
           end if

           let l_resultado = bdbsa069_proc_srv(l_arg_numero, # -> NUMERO DO SERVICO
                                               l_arg_ano)    # -> ANO DO SERVICO

           let m_agora = current
           case l_resultado

              when(0) # -> NAO ACIONADO
                 display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                  l_arg_ano    using "&&",
                                  " -> AGUARDANDO NOVA TENTATIVA."

                 call cts40g18_srv_em_uso(l_arg_numero,
                                          l_arg_ano)
                      returning l_em_uso, l_c24opemat

                 if l_c24opemat = 999999 then ## ligia 29/08/07
                    #---------------------------------------------
                    # DESBLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
                    #---------------------------------------------
                    let l_erro = cts40g06_desb_srv(l_arg_numero,
                                                   l_arg_ano)
                    if l_erro <> 0 then
                       let l_msg = "Erro ao chamar a funcao cts40g06_desb_srv()"
                       display l_msg
                       call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
                       exit program(1)
                    end if
                 end if

              when(1) # -> ACIONADO
                 display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                  l_arg_ano using "&&",
                                  " -> ACIONADO COM SUCESSO! lclltt: ", mr_local.lclltt,' lcllgt', mr_local.lcllgt,' VEIC: ', mr_veiculo.socvclcod,' lclltt: ',mr_veiculo.lclltt,' lcllgt: ', mr_veiculo.lcllgt
                 exit while

              when(2) # -> NAO ACIONAR
                 display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                  l_arg_ano    using "&&",
                                  " -> NAO PODE SER ACIONADO."
                 #ligia 211427
                 call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano)
                      returning l_em_uso, l_c24opemat

                 if l_c24opemat is not null and l_c24opemat <> 999999 then

                    # -> DESBLOQUEAR O VEICULO
                    let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

                    if l_resultado <> 0 then
                        let l_msg = "Erro na funcao: cts40g06_desb_veic()"
                        display l_msg
                        call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
                        exit program(1)
                    end if

                    display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                              l_arg_ano  using "&&",
                                              " -> SENDO ACIONADO PELO RADIO."
                    exit program(1)
                 end if

                 #---------------------------------------------
                 # DESBLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
                 #---------------------------------------------
                 if l_c24opemat = 999999 then  #ligia 29/08/07
                    let l_erro = cts40g06_desb_srv(l_arg_numero,
                                                   l_arg_ano)

                    if l_erro <> 0 then
                       let l_msg = "Erro ao chamar a funcao cts40g06_desb_srv()"
                       display l_msg
                       call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
                       exit program(1)
                    end if

                 end if

              otherwise
                 display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                  l_arg_ano using "&&",
                                  " -> ERRO NO ACIONAMENTO ", l_resultado
                 exit program(1)
           end case

        end if

        let l_espera = cts40g03_espera(l_data_ac, l_hora_ac)
        display m_agora, " Servico: ",
               l_arg_numero using "<<<<<<<<<&", "/",
               l_arg_ano    using "&&",
               " ESPERA", l_espera, " DATA ",l_data_ac," HORA ",l_hora_ac

        # VERIFICA SE ESTA NA HORA DE ENVIAR O SERVICO PARA O RADIO
        if (l_espera >= l_limite_espera) and l_atdfnlflg = "A" then

           let l_atdfnlflg = bdbsa069_envia_radio(l_arg_numero, l_arg_ano)

        end if
        if l_resultado = 2 then # -> NAO ACIONAR
           exit while
        end if

        #-------------------------------------------------------
        # AGUARDA 30 SEGUNDOS PARA NOVA TENTATIVA DE ACIONAMENTO
        #-------------------------------------------------------
        sleep 30

        # VERIFICA CONTINGENCIA
        call cta00m08_ver_contingencia(4)
             returning l_contingencia
        if l_contingencia then
           display "Processo de acionamento suspenso por conta da ativacao da CONTINGENCIA"
           exit program(1)
        end if

        # VERIFICA ACIONAMENTOWEB
        if ctx34g00_ver_acionamentoWEB(2) then
           display "Processo de acionamento suspenso por conta da ativacao do ACIONAMENTOWEB"
           exit program(1)
        end if

     end while

     if l_resultado = 0 then # NAO ACIONADO

        # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
        if cts40g18_srv_finalizado(l_arg_numero,
                                   l_arg_ano) then
           let m_agora = current
           display m_agora, " Servico: ",
                   l_arg_numero using "<<<<<<<<<&", "/",
                   l_arg_ano    using "&&",
                   " -> JA CONCLUIDO!"
           exit program(1)
        end if

        # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
        if cts40g18_srv(l_arg_numero,
                        l_arg_ano) then
           let m_agora = current
           display m_agora, " Servico: ",
                            l_arg_numero using "<<<<<<<<<&", "/",
                            l_arg_ano    using "&&",
                            " -> JA CONCLUIDO!"
           exit program(1)
        end if

        call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano) #ligia 29/08/07
             returning l_em_uso, l_c24opemat

        if l_c24opemat is null or l_c24opemat = 999999 then
           # -> ENVIA O SERVICO P/O RADIO
           let l_erro = cts40g06_env_radio(l_arg_numero,
                                           l_arg_ano)

           if l_erro <> 0 then
              let l_msg = "Erro ao chamar a funcao cts40g06_env_radio()"
              display l_msg
              call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
              exit program(1)
           end if
        end if

        #--------------------------------------------------------
        # BUSCA OS SERVICOS DE APOIO E ENVIA PARA A TELA DO RADIO
        #--------------------------------------------------------
        for l_indice = 1 to 3
            initialize al_apoio[l_indice].* to null
        end for

        call cts37g00_buscaServicoApoio(1,
                                        l_arg_numero,
                                        l_arg_ano)
             returning al_apoio[1].*,
                       al_apoio[2].*,
                       al_apoio[3].*

        for l_indice = 1 to 3
           if al_apoio[l_indice].atdsrvnum is not null then

              # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
              if cts40g18_srv_finalizado(al_apoio[l_indice].atdsrvnum,
                                         al_apoio[l_indice].atdsrvano) then
                 let m_agora = current
                 display m_agora, " Servico: ",
                         al_apoio[l_indice].atdsrvnum using "<<<<<<<<<&", "/",
                         al_apoio[l_indice].atdsrvano using "&&",
                         " -> JA CONCLUIDO!"
                 exit program(1)
              end if

              # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
              if cts40g18_srv(al_apoio[l_indice].atdsrvnum,
                              al_apoio[l_indice].atdsrvano) then
                 let m_agora = current
                 display m_agora, " Servico: ",
                                  al_apoio[l_indice].atdsrvnum using "<<<<<<<<<&", "/",
                                  al_apoio[l_indice].atdsrvano    using "&&",
                                  " -> JA CONCLUIDO!"
                 exit program(1)
              end if

              #---------------------------------------------
              # ENVIA OS SERVICOS DE APOIO P/A TELA DO RADIO
              #---------------------------------------------
              call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano) #ligia 29/08/07
                   returning l_em_uso, l_c24opemat

              if l_c24opemat is null or l_c24opemat = 999999 then
                 let l_erro = cts40g06_env_radio(al_apoio[l_indice].atdsrvnum,
                                                 al_apoio[l_indice].atdsrvano)

                 if l_erro <> 0 then
                    let l_msg = "Erro ao chamar a funcao cts40g06_env_radio()"
                    display l_msg
                    call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
                    exit program(1)
                 end if
              end if

           else
              exit for
           end if

        end for

        let m_agora = current
        display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                       l_arg_ano    using "&&",
                                    " -> ENVIADO PARA O RADIO."
        exit program(1)

     end if

  else
     # PESQUISA SERVICOS NO ACIONAMENTO AUTOMATICO PARA CRIAR PROCESSO

     #--------------------------------------------------
     # LACO INFINITO P/PEQUISA DE SERVICOS P/ACIONAMENTO
     #--------------------------------------------------
     let  m_tmpexp = current

     while true

        let l_prcstt = null

        call ctx28g00("bdbsa069", fgl_getenv("SERVIDOR"), m_tmpexp)
             returning m_tmpexp, l_prcstt

        if  l_prcstt = 'A' then

            #------------------------------------------------------------------------
            # VERIFICA SE O ARQUIVO DE LOG EXISTE, SE NAO EXISTIR, ENCERRA O PROGRAMA
            #------------------------------------------------------------------------
            if not cts40g03_verifi_log_existe(l_path) then
               let l_msg = "Nao encontrou o arquivo de log !"
               display l_msg
               call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
               exit program(1)
            end if

            #---------------------------------------
            # GRAVA O MONITORAMENTO DO PROCESSAMENTO
            #---------------------------------------
            let l_resultado = cts40g03_atlz_proc("BDBSA069")
            if l_resultado <> 0 then
               let l_msg= "ERRO AO CHAMAR A FUNCAO cts40g03_atlz_proc()"
               display l_msg
               call bdbsa069_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
               exit program(1)
            end if

            #--------------------------------
            #VERIFICA AMBIENTE DE ROTERIZACAO
            #--------------------------------
            if not ctx25g05_rota_ativa() then
               if ctx25g05_testa_amb_rota() then

                  # -> ATIVA A ROTERIZACAO
                  call ctx25g05_ativacao_rota()

               end if
            end if

            #---------------------------------------
            #VERIFICA SE O ACIONAMENTOWEB ESTA ATIVO
            #---------------------------------------
            if ctx34g00_ver_acionamentoWEB(2)then
               #--------------------------------------------------------------
               # REENVIA MQ COM ERRO DO ACIONAMENTOWEB
               #--------------------------------------------------------------
               call ctx34g00_processa_mq_AW()

               #--------------------------------------------------------------
               # ENVIA SERVICOS PENDENTES PARA O ACIONAMENTOWEB
               #--------------------------------------------------------------
               call ctx34g02_valida_servico()
            else
               #--------------------------------------------------------------
               # VERIFICA SERVICOS QUE ESTAO AGUARDANDO ACIONAMENTO AUTOMATICO
               #--------------------------------------------------------------
               call bdbsa069()
            end if

        end if

        #------------------------------------------------------
        # AGUARDA 20 SEGUNDOS PARA NOVA VERIFICACAO DE SERVICOS
        #------------------------------------------------------
        sleep 20

     end while

   end if

end main

#-------------------------#
function bdbsa069_prepare()
#-------------------------#

  define l_sql char(600)

  let l_sql = " select atdsrvnum, ",
                     " atdsrvano, ",
                     " c24opemat, ",
                     " atdfnlflg, ",
                     " acnnaomtv, ",
                     " atdsrvorg, ",
                     " srvprsacnhordat ",
                " from datmservico ",
               " where atdlibflg = 'S' ",
                 " and atdfnlflg in('A','N') ", #psi 211427
                 " and atdsrvorg in (1,2,3,4,5,6,7,17) ",
                 " and (srvprsacnhordat < current or srvprsacnhordat is null)"

  prepare pbdbsa069001 from l_sql
  declare cbdbsa069001 cursor with hold for pbdbsa069001

  let l_sql = " update datmservico ",
                 " set (atdfnlflg,c24opemat) = ('N',null) ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pbdbsa069002 from l_sql

  let l_sql = " select atdlibhor, ",
                     " atdlibdat, ",
                     " atddatprg, ",
                     " atdhorprg, ",
                     " atdhorpvt, ",
                     " acntntqtd, ",
                     " atdcstvlr, ",
                     " atdsrvorg, ",
                     " asitipcod, ",
                     " vclcoddig, ",
                     " ciaempcod ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pbdbsa069004 from l_sql
  declare cbdbsa069004 cursor for pbdbsa069004

  ############ ligia em 20/03/2007
  ############ sqls apenas para detectar um problema em producao ##############

   ##obter coordenada do servico
   let l_sql = ' select lclltt,lcllgt, c24lclpdrcod ',
               ' from datmlcl ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and c24endtip = 1 '

  prepare pcomando1 from l_sql
  declare ccomando1 cursor for pcomando1

   ##obter viatura acionado
   let l_sql = ' select pstcoddig, socvclcod, srrcoddig ',
               ' from datmsrvacp ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and atdetpcod = 4 '

  prepare pcomando2 from l_sql
  declare ccomando2 cursor for pcomando2

   ##obter coordenada da viatura no servico
   let l_sql = ' select srrltt, srrlgt ',
                ' from datmservico ',
                ' where atdsrvnum = ? ',
                  ' and atdsrvano = ? '
  prepare pcomando3 from l_sql
  declare ccomando3 cursor for pcomando3

  let l_sql = " update datmservico ",
                 " set atdfnlflg = 'S' ",
               " where atdfnlflg in('A','N') ",
                 " and atdetpcod in (4,5) ",
                 " and atdsrvorg in (1,2,3,4,5,6,7,17) "
  prepare pbdbsa069005 from l_sql

 #############################################################################

end function

#-----------------#
function bdbsa069()
#-----------------#

  define l_comando      char(50),
         l_contingencia smallint

  initialize mr_principal.* to null

  let l_comando      = null
  let l_contingencia = null

  call cta00m08_ver_contingencia(4)
       returning l_contingencia

  if l_contingencia then
     let m_agora = current
     display m_agora, " Contingencia Ativa/Carga ainda nao realizada"
  end if

  #----------------------------------------------------------------
  # AJUSTA OS SERVICOS JA CONCLUIDOS COM FLAG DE ACIONAMENTO ERRADO
  #----------------------------------------------------------------
  whenever error continue
  execute pbdbsa069005
  whenever error stop

  #---------------------------------------------------------
  # BUSCA OS SERVICOS DA DATMSERVICO QUE DEVEM SER ACIONADOS
  #---------------------------------------------------------
  open cbdbsa069001
  foreach cbdbsa069001 into mr_principal.atdsrvnum,
                            mr_principal.atdsrvano,
                            mr_principal.c24opemat,
                            mr_principal.atdfnlflg,
                            mr_principal.acnnaomtv, #psi 211427
                            mr_principal.atdsrvorg,
                            mr_principal.srvprsacnhordat

    call cta00m08_ver_contingencia(4)
         returning l_contingencia

    if l_contingencia or
       (mr_principal.atdfnlflg = "N" and mr_principal.acnnaomtv is null) then
       continue foreach
    end if

    if ctx34g00_ver_acionamentoWEB(2) then
      display "AcionamentoWeb Ativo."
      exit foreach
    end if

    if mr_principal.atdfnlflg = "A" and  mr_principal.c24opemat is not null then
       call cts40g25_srv_preso(mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               mr_principal.c24opemat,
                               mr_principal.atdfnlflg,
                               mr_principal.acnnaomtv,
                               mr_principal.atdsrvorg,
                               "ACIONAMENTO_AUTOMATICO_AUTO")
       continue foreach
    end if

    if mr_principal.srvprsacnhordat is null or mr_principal.srvprsacnhordat = ' ' then
            call ctd07g00_alt_hora_acn(mr_principal.atdsrvnum, mr_principal.atdsrvano)
    end if

    # -> MONTA O COMANDO P/CRIAR UMA NOVA INSTANCIA DO PROGRAMA
    let l_comando = "bdbsx069.sh ", mr_principal.atdsrvnum using "<<<<<<<<<&", " ",
                                    mr_principal.atdsrvano using "<&"

    run l_comando

  end foreach
  close cbdbsa069001

end function

#--------------------------------------#
function bdbsa069_proc_srv(lr_parametro)
#--------------------------------------#

  define lr_parametro    record
         atdsrvnum       like datmservico.atdsrvnum,
         atdsrvano       like datmservico.atdsrvano
  end record

  define l_resultado     integer,
         l_lx            smallint,
         l_em_uso        smallint,
         l_ac_manual     smallint,
         l_bloqueou      smallint,
         l_aciona        smallint,
         l_qdt_serv      smallint,
         l_proximo       smallint,
         l_mensagem      char(100),
         l_c24opemat     like datmservico.c24opemat,
         l_atdsrvnum_org like datmservico.atdsrvnum,
         l_atdsrvano_org like datmservico.atdsrvano,
         l_atdfnlflg     like datmservico.atdfnlflg,
         l_imsvlr        like abbmcasco.imsvlr,
         l_gpsacngrpcod  like datrorgcidacntip.gpsacngrpcod

  define lr_cidade       record
         mpacidcod       like datkmpacid.mpacidcod,
         lclltt          like datkmpacid.lclltt,
         lcllgt          like datkmpacid.lcllgt,
         mpacrglgdflg    like datkmpacid.mpacrglgdflg,
         gpsacngrpcod    like datkmpacid.gpsacngrpcod
  end record

  define l_erro_veic smallint,
         l_fator     decimal(4,2)

  let  l_resultado     = null
  let  l_lx            = null
  let  l_em_uso        = null
  let  l_ac_manual     = null
  let  l_aciona        = null
  let  l_qdt_serv      = null
  let  l_proximo       = null
  let  l_mensagem      = null
  let  l_c24opemat     = null
  let  l_atdsrvnum_org = null
  let  l_atdsrvano_org = null
  let  l_atdfnlflg     = null
  let  l_bloqueou      = null
  let  l_imsvlr        = null
  let  l_fator         = null
  let l_gpsacngrpcod   = null

  initialize lr_cidade.*    to null
  initialize mr_parametro.* to null
  initialize mr_veiculo.*   to null
  initialize mr_local.*     to null
  initialize mr_prestador.* to null

  let mr_principal.atdsrvnum = lr_parametro.atdsrvnum
  let mr_principal.atdsrvano = lr_parametro.atdsrvano

  # -> BUSCA OS DADOS DO SERVICO
  open cbdbsa069004 using mr_principal.atdsrvnum,
                          mr_principal.atdsrvano
  whenever error continue
  fetch cbdbsa069004 into mr_principal.atdlibhor,
                          mr_principal.atdlibdat,
                          mr_principal.atddatprg,
                          mr_principal.atdhorprg,
                          mr_principal.atdhorpvt,
                          mr_principal.acntntqtd,
                          mr_principal.atdcstvlr,
                          mr_principal.atdsrvorg,
                          mr_principal.asitipcod,
                          mr_principal.vclcoddig,
                          mr_principal.ciaempcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_msg = "Nao encontrou os dados do servico: ",
                mr_principal.atdsrvnum, "/",
                mr_principal.atdsrvano
     else
        display "Erro SELECT cbdbsa069004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        let l_msg = "bdbsa069_proc_srv() ",
                 mr_principal.atdsrvnum, "/",
                 mr_principal.atdsrvano
     end if
     display l_msg
     call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano, l_msg)
     exit program(1)
  end if

  close cbdbsa069004

  #------------------------------------------------------------------
  # OBTEM OS PARAMETROS DA TABELA DE PARAMETRIZACAO COM A ORIGEM LIDA
  #------------------------------------------------------------------
  call cts40g00_obter_parametro(mr_principal.atdsrvorg)
       returning l_resultado,
                 l_mensagem,
                 mr_parametro.acnlmttmp,
                 mr_parametro.acntntlmtqtd,
                 mr_parametro.netacnflg,
                 mr_parametro.atmacnprtcod

  if l_resultado <> 0 then
     if l_resultado = 1 then
        let l_msg = l_mensagem
     else
        display "Erro ao chamar a funcao cts40g00_obter_parametro()"
        let l_msg = "Mensagem de erro: ", l_mensagem
     end if
     display l_msg
     call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano, l_msg)
     exit program(1)
  end if

  #--------------------------------
  # OBTER DADOS DO LOCAL DO SERVICO
  #--------------------------------
  initialize mr_local.* to null
  call ctx04g00_local_gps(mr_principal.atdsrvnum,
                          mr_principal.atdsrvano,
                          1)

       returning mr_local.lclidttxt,
                 mr_local.lgdtip,
                 mr_local.lgdnom,
                 mr_local.lgdnum,
                 mr_local.lclbrrnom,
                 mr_local.brrnom,
                 mr_local.cidnom,
                 mr_local.ufdcod,
                 mr_local.lclrefptotxt,
                 mr_local.endzon,
                 mr_local.lgdcep,
                 mr_local.lgdcepcmp,
                 mr_local.lclltt,
                 mr_local.lcllgt,
                 mr_local.dddcod,
                 mr_local.lcltelnum,
                 mr_local.lclcttnom,
                 mr_local.c24lclpdrcod,
                 mr_local.celteldddcod,
                 mr_local.celtelnum,
                 mr_local.endcmp,
                 mr_local.sqlcode,
                 mr_local.emeviacod

  if mr_local.sqlcode <> 0 then
     let l_msg = "Erro: ", mr_local.sqlcode, " ao chamar a funcao ctx04g00_local_completo()"
     display l_msg
     call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano, l_msg)
     exit program(1)
  end if

  # -> VERIFICA SE A LATITUDE OU LONGITUDE DO SERVICO ESTAO NULAS
  if mr_local.lclltt is null or
     mr_local.lcllgt is null then
     let l_mensagem = "SRV. C/LATITUDE OU LONGITUDE NULAS"
     # -> ENVIA O SERVICO PARA A TELA DO RADIO
     call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  l_mensagem,
                                  1,
                                  "N")
          returning l_resultado,
                    l_mensagem

     if l_resultado <> 0 then
        let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual()"
        display l_mensagem
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if
     return 2
  end if

  # -> VERIFICA SE A LATITUDE OU LONGITUDE DO SERVICO ESTAO ZERADAS
  if mr_local.lclltt = 0 or
     mr_local.lcllgt = 0 then
     let l_mensagem = "SRV. C/LATITUDE OU LONGITUDE ZERADAS"
     # -> ENVIA O SERVICO PARA A TELA DO RADIO
     call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  l_mensagem,
                                  1,
                                  "N")
          returning l_resultado,
                    l_mensagem

     if l_resultado <> 0 then
        let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual()"
        display l_mensagem
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if
     return 2
  end if

  # SE ORIGEM 2(ASSISTENCIA PASSAGEIRO) OU 3(HOSPEDAGEM)
  # OS SERVICOS SERAO ACIONADOS VIA INTERNET, SEM VERIFICAR
  # A CIDADE DO SERVICO
  #--------------------------------------------------------
  if (mr_principal.atdsrvorg = 2 and   # ASSISTENCIA A PASSAGEIROS
      mr_principal.asitipcod <> 5) or  # ASITIPCOD <> 5(TAXI)
     mr_principal.atdsrvorg = 3 then  # HOSPEDAGEM
     let lr_cidade.gpsacngrpcod = 0   # SERVICO SERA ENVIADO VIA INTERNET
  else
     #--------------------------------------------
     # BUSCA INFORMACOES SOBRE A CIDADE DO SERVICO
     #--------------------------------------------
     initialize lr_cidade.* to null
     call cts23g00_inf_cidade(2,
                              "",
                              mr_local.cidnom,
                              mr_local.ufdcod)

          returning l_resultado,
                    lr_cidade.mpacidcod,
                    lr_cidade.lclltt,
                    lr_cidade.lcllgt,
                    lr_cidade.mpacrglgdflg,
                    lr_cidade.gpsacngrpcod

     if l_resultado <> 0 then
        if l_resultado = 100 then
           let l_msg = "Nao encontrou informacoes sobre a cidade do servico: ",
                    mr_principal.atdsrvnum, "/",
                    mr_principal.atdsrvano
        else
           let l_msg = "Erro: ", l_resultado, " na funcao cts23g00_inf_cidade()"
        end if
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if

     #-----------------------------------------------
     #BUSCA TIPO DE ACIONAMENTO POR ORIGEM DO SERVICO
     #-----------------------------------------------
     whenever error continue

       select gpsacngrpcod into l_gpsacngrpcod
         from datrorgcidacntip
           where mpacidcod = lr_cidade.mpacidcod
             and atdsrvorg = mr_principal.atdsrvorg

       #Sistema considera Tipo de Acioanamento se tiver cadastro para origem informada
       if sqlca.sqlcode == 0   then
          if  l_gpsacngrpcod is not null  then
             let lr_cidade.gpsacngrpcod = l_gpsacngrpcod
          end if
       end if
     whenever error stop
  end if

  if lr_cidade.gpsacngrpcod > 0 then

     # -> OBTEM COD DA CIDADE SEDE - PSI 202363
     call ctd01g00_obter_cidsedcod(1,
                                   lr_cidade.mpacidcod)
          returning l_resultado,
                    l_mensagem,
                    lr_cidade.mpacidcod

     # -> OBTEM DISTANCIA PARAMETRIZADA NA CIDADE SEDE - PSI 202363
     call cts40g00_obter_distancia(mr_parametro.atmacnprtcod,
                                   lr_cidade.mpacidcod)
          returning l_resultado,
                    l_mensagem,
                    mr_parametro.cidacndst

     if l_resultado <> 0 then
        let l_msg = "Distancia nao parametrizada para cidade ", lr_cidade.mpacidcod using "<<<<<<<<<<"," ", mr_local.cidnom clipped ,"/", mr_local.ufdcod
        display l_msg
        call bdbsa069_trata_erros(1, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if

     #----------------------------------------------------------------------
     # CODIGO DE PADRONIZACAO DO LOCAL > 0, ENTAO O LOCAL E ATENDIDO POR GPS
     #----------------------------------------------------------------------

     #-------------------------------------------
     # VERIFICA SE JA E HORA DE ACIONAR O SERVICO
     #-------------------------------------------
     call cts40g09_aciona_servico(mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  mr_principal.atddatprg,
                                  mr_principal.atdhorprg,
                                  mr_parametro.acnlmttmp)
          returning l_aciona,
                    l_lx, # VARIAVEIS SEM UTILIDADE P/ACIONAMENTO AUTO
                    l_lx  # VARIAVEIS SEM UTILIDADE P/ACIONAMENTO AUTO

     if l_aciona = false then
        #-----------------------------------------------------
        # DESPREZA O SERVICO, POIS AINDA NAO E HORA DE ACIONAR
        #-----------------------------------------------------
        return 2
     end if

     #---------------------------------------------
     # CHAMA A FUNCAO P/VERIFICAR A SITUACAO DO GPS
     #---------------------------------------------
     let l_resultado = cts40g04_verifica_gps(mr_local.cidnom,
                                             mr_local.ufdcod,
                                             mr_parametro.atmacnprtcod)
     if l_resultado = 1 then # -> GPS INATIVO
        #------------------------------------------------------------------
        # SE O ACIONAMENTO GPS ESTIVER INATIVO P/CIDADE, DESPREZA O SERVICO
        #------------------------------------------------------------------
        return 2
     end if

     ## OBTER IS DA APOLICE
     let l_imsvlr = 0
     call cts40g26_obter_is_apol(mr_principal.atdsrvnum,
                                 mr_principal.atdsrvano,
                                 mr_principal.ciaempcod)
          returning l_resultado, l_mensagem, l_imsvlr

     if l_resultado <> 1 then
        let l_msg = l_mensagem
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if

     let l_proximo = false

     while true

        # --OBTER O VEICULO PARA ATENDER O SERVICO
        initialize mr_veiculo.* to null
        call cts40g13_obter_veic(mr_local.lclltt,
                                 mr_local.lcllgt,
                                 mr_parametro.cidacndst,
                                 mr_local.cidnom,
                                 mr_local.ufdcod,
                                 mr_principal.atdsrvnum,
                                 mr_principal.atdsrvano,
                                 mr_principal.atdhorprg,
                                 mr_principal.atdsrvorg,
                                 mr_principal.asitipcod,
                                 mr_principal.vclcoddig,
                                 mr_principal.ciaempcod, #psi 205026
                                 l_imsvlr)

             returning mr_veiculo.cod_motivo,
                       mr_veiculo.msg_motivo,
                       mr_veiculo.srrcoddig,
                       mr_veiculo.socvclcod,
                       mr_veiculo.pstcoddig,
                       mr_veiculo.distancia,
                       mr_veiculo.lclltt,
                       mr_veiculo.lcllgt,
                       mr_veiculo.srrabvnom,
                       mr_veiculo.tempo_total

        let l_erro_veic = false
        if mr_veiculo.cod_motivo = 0 then
            if mr_veiculo.distancia is null or
               mr_veiculo.lclltt    is null or
               mr_veiculo.lcllgt    is null then
                let l_erro_veic = true
                display 'Servico: ',mr_principal.atdsrvnum,'-',mr_principal.atdsrvano,'-> Erro no parametro do veiculo(',mr_veiculo.socvclcod,'): NULL'
            else
                if mr_veiculo.distancia < 0 or
                   mr_veiculo.lclltt    = 0 or
                   mr_veiculo.lcllgt    = 0 then
                    let l_erro_veic = true
                    display 'Servico: ',mr_principal.atdsrvnum,'-',mr_principal.atdsrvano,'-> Erro no parametro do veiculo(',mr_veiculo.socvclcod,'): 0'
                else
                   let l_fator = ctx25g05_fator_desvio()
                   if (mr_veiculo.distancia > (mr_parametro.cidacndst * l_fator)) then
                       let l_erro_veic = true
                       display 'Servico: ',mr_principal.atdsrvnum,'-',mr_principal.atdsrvano,'-> Erro no parametro do veiculo(',mr_veiculo.socvclcod,'): mr_veiculo.distancia > mr_parametro.cidacndst = ', mr_veiculo.distancia
                   end if
                end if
            end if

            if l_erro_veic = true then
                exit program(1)
            end if
        end if

        if mr_veiculo.cod_motivo <> 0 then
           if  mr_veiculo.cod_motivo = 13 then # DIVERGENCIA: CAD. EXECOES E LOCA/COND
              # --ENVIA O SERVICO PARA A TELA DO RADIO PARA O ACIONAMENTO MANUAL
              call cts40g09_aciona_manual(mr_principal.atdsrvnum,
                                          mr_principal.atdsrvano,
                                          mr_veiculo.msg_motivo,
                                          1,
                                          "N")
                   returning l_resultado,
                             l_mensagem

              if l_resultado <> 0 then
                 let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual()"
                 display l_mensagem
                 display l_msg
                 call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano, l_msg)
                 exit program(1)
              end if

              # --> ENVIA OS SERVICOS DE APOIO P/O RADIO
              call bdbsa069_atlz_apoio(mr_principal.atdsrvnum,
                                       mr_principal.atdsrvano,
                                       mr_veiculo.msg_motivo,
                                       "N")

              # --BUSCA O PROXIMO SERVICO
              let l_proximo = true
              exit while
           end if

           if mr_veiculo.cod_motivo = 1 or   # --NAO LOCALIZOU SOCORRISTA ADEQUADO
              mr_veiculo.cod_motivo = 4 or   # --VEICULO EM RODIZIO FORA DA DISTANCIA LIMITE.
              mr_veiculo.cod_motivo = 7 or   # --NAO LOCALI. VEIC. DISP.DENTRO LIMITE PARAMETR.
              mr_veiculo.cod_motivo = 3 or   # --ERRO DE ACESSO A BASE DE DADOS

              mr_veiculo.cod_motivo =14 then # --ERRO NA ROTEIRIZACAO

              #------------------------------------------------------
              # CONTABILIZA A TENTATIVA DE ACIONAMENTO PARA O SERVICO
              #------------------------------------------------------
              call cts40g09_contab_tentativa(mr_principal.acntntqtd,
                                             mr_parametro.acntntlmtqtd,
                                             mr_veiculo.msg_motivo,
                                             mr_principal.atdsrvnum,
                                             mr_principal.atdsrvano,
                                             mr_principal.atdsrvorg)
                   returning l_resultado,
                             l_mensagem,
                             l_ac_manual,
                             l_lx # VARIAVEIS SEM UTILIDADE P/ACIONAMENTO AUTO

              if l_resultado <> 0 then
                 let l_msg = "Erro ao chamar a funcao cts40g09_contab_tentativa()"
                 display l_msg
                 call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano, l_msg)
                 exit program(1)
              end if

              # --BUSCA O PROXIMO SERVICO
              let l_proximo = true

              let m_agora = current
              display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                             mr_principal.atdsrvano using "&&",
                               " -> MOTIVO DO NAO ACN: ", mr_veiculo.msg_motivo

              exit while
           else
              let l_msg = "Erro na funcao: cts40g13_obter_veic()"
              display l_msg
              call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano, l_msg)
              exit program(1)
           end if
        else

           # -> BLOQUEIA O VEICULO
           call cts40g06_bloq_veic(mr_veiculo.socvclcod, 999999)
                returning l_resultado,
                          l_bloqueou

           if l_resultado = 0 then
              if l_bloqueou = false then
                 # -> BUSCA UM NOVO VEICULO POIS O VEICULO
                 # -> ESCOLHIDO, JA ESTA EM USO
                 continue while
              else
                 let l_proximo = false
                 exit while
              end if
           else
              let l_msg= "Erro na funcao cts40g06_bloq_veic()!"
              display l_msg
              call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano, l_msg)
              exit program(1)
           end if

        end if

     end while

     #ligia 211427
     call cts40g18_srv_em_uso(mr_principal.atdsrvnum, mr_principal.atdsrvano)
          returning l_em_uso, l_c24opemat

     if l_c24opemat is not null and l_c24opemat <> 999999 then

        # -> DESBLOQUEAR O VEICULO
        let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

        if l_resultado <> 0 then
            let l_msg = "Erro na funcao: cts40g06_desb_veic()"
            display l_msg
            call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                      mr_principal.atdsrvano, l_msg)
            exit program(1)
        end if

        display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                  mr_principal.atdsrvano using "&&",
                                  " -> SENDO ACIONADO PELO RADIO."
        exit program(1)
     end if

     if l_proximo then
        return 0
     end if

     begin work

     # --CHAMA A FUNCAO PARA REALIZAR AS TAREFAS E OS PROCEDIMENTOS
     # --DO ACIONAMENTO DO SERVICO VIA GPS
     if bdbsa069_tarefas_gps() then

        #---------------------------------------------------------
        # VERIFICA SE O SERVICO ESTA SENDO ALTERADO PELO ATENDENTE
        #---------------------------------------------------------
        call cts40g18_srv_em_uso(mr_principal.atdsrvnum,
                                 mr_principal.atdsrvano)
             returning l_em_uso, l_c24opemat

        if l_c24opemat is not null and
           l_c24opemat <> 999999 then     # -> SERVICO ESTA EM USO(ATENDENTE)
           let m_agora = current
           display m_agora, " Servico: ", mr_principal.atdsrvnum
                            using "<<<<<<<<<&", "/",
                            mr_principal.atdsrvano    using "&&",
                            " -> SENDO USADO POR: ", l_c24opemat
           rollback work
           let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)
        else
           commit work
        end if

        ### EMVIA SMS AO CELULAR DO SEGURADO
        # ligia - 17/05/2007 - inibido temporariamente a pedido da Neia
        #call cts40g15(1,
        #              mr_principal.atdsrvnum,
        #              mr_principal.atdsrvano,
        #              mr_veiculo.srrabvnom)
     else
        rollback work
        let l_msg = "Erro na funcao bdbsa069_tarefas_gps()"
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
        exit program(1)
     end if

     # -> DESBLOQUEAR O VEICULO
     let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

     if l_resultado <> 0 then
        let l_msg = "Erro na funcao: cts40g06_desb_veic()"
        display l_msg
        call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano, l_msg)
         exit program(1)
     end if

     return 1

  else # -> ACIONAMENTO VIA INTERNET OU FAX
     #--------------------------------------------------
     # VERIFICA SE O ACIONAMENTO VIA INTERNET ESTA ATIVO
     #--------------------------------------------------
     if mr_parametro.netacnflg = "A" then  # ATIVO
        #-------------------------------------------------------
        # BUSCA DO PRESTADOR P/ATENDER SERVICO AUTO VIA INTERNET
        #-------------------------------------------------------
        initialize mr_prestador.* to null

        call cts40g14_obter_prestador(mr_local.lclltt,
                                      mr_local.lcllgt,
                                      mr_principal.atdsrvnum,
                                      mr_principal.atdsrvano,
                                      mr_principal.asitipcod,
                                      mr_principal.atdsrvorg,
                                      mr_principal.ciaempcod)

             returning mr_prestador.cod_motivo,
                       mr_prestador.msg_motivo,
                       mr_prestador.pstcoddig,
                       mr_prestador.nomgrr,
                       mr_prestador.distancia

        if mr_prestador.cod_motivo <> 0 then
           if mr_prestador.cod_motivo = 12 then # -> PRESTADOR NAO LOGADO NA INTERNET

              # --ENVIA O SERVICO P/A TELA NO RADIO P/O ACIONAMENTO MANUAL
              # --E MANTEM NO ACIONAMENTO AUTOMATICO
              call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano,
                                           mr_prestador.msg_motivo,
                                           1,
                                           "N")

                   returning l_resultado,
                             l_mensagem

              if l_resultado <> 0 then
                 let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual()"
                 display l_mensagem
                 display l_msg
                 call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano, l_msg)
                 exit program(1)
              end if

               # --> ENVIA OS SERVICOS DE APOIO P/O RADIO
               call bdbsa069_atlz_apoio(mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        mr_prestador.msg_motivo,
                                        "A")
               return 2
           else
              if mr_prestador.cod_motivo = 7  or   # -> NAO ENCONTR. PRESTADOR DISPONIVEL
                 mr_prestador.cod_motivo = 8  or   # -> NAO LOCAL. PRESTADOR PARAMETRIZADO
                 mr_prestador.cod_motivo = 10 or   # -> SERVICO E APOIO, MAS O SERVICO ORIGINAL AINDA NAO FOI ACIONADO
                 mr_prestador.cod_motivo = 11 then # -> PRESTADOR E COMUNICADO VIA FAX

                 # --ENVIA O SERVICO PARA A TELA NO RADIO PARA O ACIONAMENTO MANUAL
                 let l_atdfnlflg = "N"

                 # --MANTER SRV DE APOIO NO ACIONAMENTO AUTOMATICO
                 if mr_prestador.cod_motivo = 10  then
                    let l_atdfnlflg = "A"
                 end if

                 call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano,
                                              mr_prestador.msg_motivo,
                                              1,
                                              l_atdfnlflg)
                      returning l_resultado,
                                l_mensagem

                 if l_resultado <> 0 then
                    let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual()"
                    display l_mensagem
                    display l_msg
                    call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano, l_msg)
                    exit program(1)
                 end if

                 # --> ENVIA OS SERVICOS DE APOIO PARA O RADIO
                 call bdbsa069_atlz_apoio(mr_principal.atdsrvnum,
                                          mr_principal.atdsrvano,
                                          mr_prestador.msg_motivo,
                                          l_atdfnlflg)

                 return 2

              else
                 let l_msg= "Erro ao chamar a funcao cts40g14_obter_prestador()"
                 display l_msg
                 call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano, l_msg)
                 exit program(1)
              end if
           end if
        else
           #----------------------------------------------------------------------
           # VERIFICA SE O PRESTADOR POSSUI SERVICOS C/STATUS AGUARDANDO NO PORTAL
           #----------------------------------------------------------------------
           call cts40g16_srv_pend(mr_prestador.pstcoddig)

                returning l_resultado,
                          l_qdt_serv

           if l_resultado = 0 then
              if l_qdt_serv = 0 then  #PRESTADOR NAO TEM SERVICOS PENDENTES

                 call cts40g18_srv_em_uso(mr_principal.atdsrvnum, #ligia 211427
                                          mr_principal.atdsrvano)
                      returning l_em_uso, l_c24opemat

                 if l_c24opemat is not null and l_c24opemat <> 999999 then
                    display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                             mr_principal.atdsrvano using "&&",
                                             " -> SENDO ACIONADO PELO RADIO."
                    exit program(1)
                 end if

                 begin work

                 # --CHAMA A FUNCAO PARA REALIZAR AS TAREFAS E OS PROCEDIMENTOS
                 # --DO ACIONAMENTO DO SERVICO VIA INTERNET

                 if bdbsa069_tarefas_internet() then

                    #---------------------------------------------------------
                    # VERIFICA SE O SERVICO ESTA SENDO ALTERADO PELO ATENDENTE
                    #---------------------------------------------------------
                    call cts40g18_srv_em_uso(mr_principal.atdsrvnum,
                                             mr_principal.atdsrvano)
                         returning l_em_uso, l_c24opemat

                    if l_c24opemat is not null and
                       l_c24opemat <> 999999 then  # -> SERVICO ESTA EM USO(ATENDENTE)
                       let m_agora = current
                       display m_agora, " Servico: ", mr_principal.atdsrvnum
                                        using "<<<<<<<<<&", "/",
                                        mr_principal.atdsrvano    using "&&",
                                        " -> SENDO USADO POR: ", l_c24opemat
                       rollback work
                    else
                       commit work
                    end if
                 else
                    rollback work
                    let l_msg = "Erro na funcao bdbsa069_tarefas_internet()"
                    display l_msg
                    call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano, l_msg)
                    exit program(1)
                 end if

                 return 1

              else
                 # -> ESPERA ATE O PRESTADOR ACEITAR OU RECUSAR OS SERVICOS
                 return 0
              end if

           else
              let l_msg= "Erro: ", l_resultado, " ao chamar a funcao cts40g16_srv_pend()"
                    display l_msg
                    call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano, l_msg)
              exit program(1)
           end if
        end if

     else
        #------------------------------------------------------------
        # O ACIONAMENTO VIA INTERNET ESTA INATIVO, DESPREZA O SERVICO
        #------------------------------------------------------------
        return 2
     end if
  end if

end function

#-----------------------------#
function bdbsa069_tarefas_gps()
#-----------------------------#

  define l_socacsflg     like datkveiculo.socacsflg,
         l_previsao      like datmservico.atdprvdat,
         l_calc_prev     char(06),
         l_resultado     integer,
         l_tempo_distancia integer,
         l_flgerro       char(01),
         l_aux_calc      char(06),
         l_mensagem      char(60),
         l_indice        smallint,
         l_ok            smallint,
         l_tentativas    like datmservico.acntntqtd,
         l_data_atual    date,
         l_hora_atual    datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_socacsflg  =  null
        let     l_previsao  =  null
        let     l_calc_prev  =  null
        let     l_resultado  =  null
        let     l_flgerro  =  null
        let     l_aux_calc  =  null
        let     l_mensagem  =  null
        let     l_indice  =  null
        let     l_ok  =  null
        let     l_tentativas  =  null
        let     l_data_atual  =  null
        let     l_hora_atual  =  null

  let l_ok = true

  if ctx25g05_rota_ativa() then
     let l_previsao = "00:00"
     let l_previsao = (l_previsao + mr_veiculo.tempo_total units minute)
  else
     # --CALCULAR A PREVISAO DE CHEGADA
     let l_aux_calc  = mr_principal.atdhorpvt
     let l_calc_prev = cts21g00_calc_prev(mr_veiculo.distancia, l_aux_calc)

     # --RECEBE O CALCULO DA PREVISAO(l_calc_prev) NUM CHAR(06) E APOS PASSA
     # --PARA A PREVISAO FINAL(l_previsao) QUE E DO TIPO datetime hour to minute
     let l_previsao  = l_calc_prev
  end if

  let l_tentativas = mr_principal.acntntqtd

  # --CONTABILIZA A TENTATIVA DO ACIONAMENTO
  let l_tentativas = l_tentativas + 1

  # --ATUALIZAR O VEICULO/SOCORRISTA NO SERVICO
  let l_resultado = cts33g01_alt_dados_automat(mr_veiculo.pstcoddig,
                                               mr_veiculo.socvclcod,
                                               mr_veiculo.srrcoddig,
                                               "",
                                               999999,
                                               mr_principal.atdcstvlr,
                                               mr_veiculo.lclltt,
                                               mr_veiculo.lcllgt,
                                               l_previsao,
                                               l_tentativas,
                                               mr_principal.atdsrvnum,
                                               mr_principal.atdsrvano)
  if l_resultado <> 0 then
     let l_ok = false
     return l_ok
  end if

  # --INSERIR ETAPA
  let l_resultado = cts40g22_insere_etapa(mr_principal.atdsrvnum,
                                          mr_principal.atdsrvano,
                                          4,
                                          mr_veiculo.pstcoddig,
                                          "",
                                          mr_veiculo.socvclcod,
                                          mr_veiculo.srrcoddig)

  if l_resultado <> 0 then
     display "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
     let l_ok = false
     return l_ok
  end if

  ####PSI 214558
  let     l_tempo_distancia  =  null
  #if l_etapa = 3 or l_etapa = 4 then
     call cts10g04_tempo_distancia(mr_principal.atdsrvnum,
                                   mr_principal.atdsrvano,
                                   4,
                                   mr_veiculo.distancia)
       returning l_resultado

       if l_resultado <> 0 then
           let l_mensagem = " Erro: ", l_tempo_distancia, " ao chamar a funcao ",
                            " cts10g04_tempo_distancia() ",
                            " Srv: ", mr_principal.atdsrvnum

           display l_mensagem
           let l_ok = false
           return l_ok
       end if

  #end if
  ####

  call cts10g04_atualiza_dados(mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               "",
                               1)
       returning l_mensagem,
                 l_resultado

  if l_resultado <> 1 then
     display "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
     display l_mensagem
     let l_ok = false
     return l_ok
  end if

  # --ENVIO DA REFERENCIA DO ENDERECO VIA TELETRIM
  call cts00g04_msgsrv(mr_principal.atdsrvnum,
                       mr_principal.atdsrvano,
                       mr_veiculo.socvclcod,
                       " ",
                       " ",
                       "SRV",
                       "B")

  let l_flgerro = cts00g02_env_msg_mdt(2,
                                       mr_principal.atdsrvnum,
                                       mr_principal.atdsrvano,
                                       "",
                                       mr_veiculo.socvclcod)

  if l_flgerro = "S" then
     display "Erro ao chamar a funcao cts00g02_env_msg_mdt()"
     let l_ok = false
     return l_ok
  end if

  # --BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual,
                 l_hora_atual

  # --CARREGA DADOS DO SERVICO P/POSICAO DA FROTA
  let l_resultado = cts33g01_posfrota(mr_veiculo.socvclcod,
                                      "N",
                                       mr_local.ufdcod,
                                       mr_local.cidnom,
                                       mr_local.brrnom,
                                       mr_local.endzon,
                                       mr_local.lclltt,
                                       mr_local.lcllgt,
                                       "",
                                       "",
                                       "",
                                       "",
                                       "",
                                       "",
                                       l_data_atual,
                                       l_hora_atual,
                                       "QRU",
                                       mr_principal.atdsrvnum,
                                       mr_principal.atdsrvano)
  if l_resultado <> 0 then
    let l_ok = false
  end if

  ## p/acompanhar os casos em que aciona viatura fora da distancia limite
  ## ligia 29/03/2007
  call cts40g25_ac(mr_principal.atdsrvnum, mr_principal.atdsrvano,"BDBSA069")

  return l_ok

end function

#----------------------------------#
function bdbsa069_tarefas_internet()
#----------------------------------#

  define l_resultado    smallint,
         l_mensagem     char(100),
         l_atdetpseq    like datmsrvint.atdetpseq,
         l_atdetpcod    like datmsrvint.atdetpcod,
         l_ok           smallint,
         l_indice       smallint,
         l_etapa        smallint,
         l_data_atual   date,
         l_hora_atual   datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_resultado  = null
  let l_mensagem   = null
  let l_atdetpseq  = null
  let l_atdetpcod  = null
  let l_ok         = null
  let l_indice     = null
  let l_etapa      = null
  let l_data_atual = null
  let l_hora_atual = null

  let l_ok = true

  call cts33g00_inf_internet(mr_principal.atdsrvnum,
                             mr_principal.atdsrvano)
       returning l_resultado,
                 l_mensagem,
                 l_atdetpseq,
                 l_atdetpcod

  if l_resultado <> 1 then
     if l_resultado <> 2 then
        display "Erro ao chamar a funcao cts33g00_inf_internet()"
        display l_mensagem
        let l_ok = false
        return l_ok
     end if
  end if

  # --REGISTRA P/INTERNET O SERVICO ENCONTRADO
  call cts33g00_registrar_para_internet(mr_principal.atdsrvano,
                                        mr_principal.atdsrvnum,
                                        l_atdetpseq,
                                        0, # AGUARDANDO NO PORTAL DE NEGOCIOS
                                        mr_prestador.pstcoddig,
                                        "F",
                                        1,
                                        999999,
                                        "")
       returning l_resultado,
                 l_mensagem

  if l_resultado <> 1 then
     display " Erro ao chamar a funcao cts33g00_registrar_para_internet()"
     display l_mensagem
     let l_ok = false
     return l_ok
  end if

  # --ATUALIZA OS DADOS DO SERVICO ORIGINAL
  let l_resultado = cts33g01_alt_dados_automat(mr_prestador.pstcoddig,
                                               "",
                                               "",
                                               "",
                                               999999,
                                               mr_principal.atdcstvlr,
                                               "",
                                               "",
                                               "",
                                               1,
                                               mr_principal.atdsrvnum,
                                               mr_principal.atdsrvano)
  if l_resultado <> 0 then
     let l_ok = false
     return l_ok
  end if

  let l_etapa = 4 # SERVICO AUTO ACIONADO

  if (mr_principal.atdsrvorg = 3) or     # HOSPEDAGEM
     (mr_principal.atdsrvorg = 2 and     # ASSISTENCIA A PASSAGEIROS
      mr_principal.asitipcod <> 5) then  # ASITIPCOD <> 5(TAXI)

      # SERVICO ACIONADO, POREM CONTINUA NA TELA DO RADIO
      # POIS PARA ESTAS ORIGENS O SERCVICO FOI ENVIADO AO PORTAL
      # E TERA A RESPOSTA NO RADIO

      let l_etapa = 43 # SERVICO ENVIADO

      whenever error continue
      execute pbdbsa069002 using mr_principal.atdsrvnum,
                                 mr_principal.atdsrvano
      whenever error stop

      if sqlca.sqlcode <> 0 then
         display "Erro UPDATE pbdbsa069002 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
         let l_ok = false
         return l_ok
      else
         call cts00g07_apos_grvlaudo(mr_principal.atdsrvnum,mr_principal.atdsrvano)
      end if

  end if

  #--INSERIR ETAPA PARA O SERVICO ORIGINAL
  let l_resultado = cts40g22_insere_etapa(mr_principal.atdsrvnum,
                                          mr_principal.atdsrvano,
                                          l_etapa,
                                          mr_prestador.pstcoddig,
                                          "",
                                          "",
                                          "")
  if l_resultado <> 0 then
     display "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
     let l_ok = false
     return l_ok
  end if

  call cts10g04_atualiza_dados(mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               "",
                               2)
       returning l_mensagem,
                 l_resultado

  if l_resultado <> 1 then
     display "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
     display l_mensagem
     let l_ok = false
  end if

  return l_ok

end function

#----------------------------------------#
function bdbsa069_atlz_apoio(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         msg_motivo   char(40),
         flag_aciona  char(01)
  end record

  define al_apoio  array[3] of record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
  end record

  define l_contador   smallint,
         l_resultado  integer,
         l_mensagem   char(100)

  define  w_pf1   integer

  let l_contador  = null
  let l_resultado = null
  let l_mensagem  = null

  for w_pf1  =  1  to  3
      initialize al_apoio[w_pf1].*  to  null
  end for

  let m_agora = current
  display m_agora, " Servico: ", lr_parametro.atdsrvnum using "<<<<<<<<<&", "/",
                                 lr_parametro.atdsrvano using "&&",
                   " -> MOTIVO DO NAO ACN: ", lr_parametro.msg_motivo

  # --> BUSCA OS SERVICOS DE APOIO E ENVIA PARA A TELA DO RADIO
  call cts37g00_buscaServicoApoio(1,
                                  lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano)
       returning al_apoio[1].*,
                 al_apoio[2].*,
                 al_apoio[3].*

  for l_contador = 1 to 3
     if al_apoio[l_contador].atdsrvnum is not null then

        # --ENVIA O SERVICO PARA A TELA DO RADIO PARA O ACIONAMENTO MANUAL
        call cts40g09_aciona_manual (al_apoio[l_contador].atdsrvnum,
                                     al_apoio[l_contador].atdsrvano,
                                     lr_parametro.msg_motivo,
                                     1,
                                     lr_parametro.flag_aciona)

             returning l_resultado,
                       l_mensagem

        if l_resultado <> 0 then
           let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual()"
           display l_mensagem
           display l_msg
           call bdbsa069_trata_erros(0, mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano, l_msg)
           exit program(1)
        end if
     else
        exit for
     end if

  end for

end function

function bdbsa069_trata_erros(l_env_usuar,l_atdsrvnum, l_atdsrvano, l_msg_param)

   define l_env_usuar smallint,
          l_msg_param char(200),
          l_atdsrvnum like datmservico.atdsrvnum,
          l_atdsrvano like datmservico.atdsrvano,
          l_cmd       char(1000),
          l_erro      smallint,
          l_em_uso    smallint,
          l_c24opemat like datmservico.c24opemat

   define l_mens       record
          msg          char(200)
         ,de           char(50)
         ,subject      char(100)
         ,para         char(200)
         end record

   initialize l_mens to null
   let l_cmd = null
   let l_erro = null
   let l_em_uso = null
   let l_c24opemat = null

   let l_msg_param = "SRV: ", l_atdsrvnum using "<<<<<<<<<<",
                     " - ERRO: ", l_msg_param

   display l_msg_param

   call cts40g18_srv_em_uso(l_atdsrvnum, l_atdsrvano)
        returning l_em_uso, l_c24opemat

   if l_c24opemat = 999999 then
      # -> DESBLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
      let l_erro = cts40g06_desb_srv(l_atdsrvnum, l_atdsrvano)
      if l_erro <> 0 then
         let l_msg_param = l_msg_param clipped,
                           " Erro ao chamar cts40g06_desb_srv()"
      end if
   end if

   if l_env_usuar = true then
      if m_atdfnlflg = "A" then
          let l_erro = ctx22g00_mail_corpo("BDBSA69A", "Acionamento AUTO cadastro de parametrizacao", l_msg_param)
         if l_erro <> 0 then
            if l_erro <> 99 then
               display "Erro de envio de email(cx22g00)- "
            else
               display "Nao ha email cadastrado para o modulo BDBSA069 "
            end if
         end if
      end if
   else
      let l_erro = ctx22g00_mail_corpo("BDBSA069I", "Acionamento AUTO erro sistema", l_msg_param)
         if l_erro <> 0 then
            if l_erro <> 99 then
               display "Erro de envio de email(cx22g00)- "
            else
               display "Nao ha email cadastrado para o modulo BDBSA069 "
            end if
         end if
   end if

end function

#-----------------------------------------#
function bdbsa069_envia_radio(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define al_apoio  array[3] of record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
  end record

  define l_atdfnlflg     char(1),
         l_acnnaomtv     like datmservico.acnnaomtv,
         l_resultado     integer,
         l_msg           char(40),
         l_indice        smallint

  for l_indice  =  1  to  3
      initialize al_apoio[l_indice].*  to  null
  end for

  let l_atdfnlflg = null
  let l_acnnaomtv = null
  let l_resultado = null
  let l_msg       = null
  let l_indice    = null

  # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
  if cts40g18_srv_finalizado(lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano) then
     let m_agora = current
     display m_agora, " Servico: ",
             lr_parametro.atdsrvnum using "<<<<<<<<<&", "/",
             lr_parametro.atdsrvano    using "&&",
             " -> JA CONCLUIDO!"
     exit program(1)
  end if

  # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
  if cts40g18_srv(lr_parametro.atdsrvnum,
                  lr_parametro.atdsrvano) then
     let m_agora = current
     display m_agora, " Servico: ",
                      lr_parametro.atdsrvnum using "<<<<<<<<<&", "/",
                      lr_parametro.atdsrvano    using "&&",
                      " -> JA CONCLUIDO!"
     exit program(1)
  end if

  if l_acnnaomtv is null then
     let l_acnnaomtv = "LIMITE TEMPO EXCEDIDO P/ACIONAMENTO AUTO"
  end if

  # --ENVIA O SERVICO PARA A TELA DO RADIO PARA O ACIONAMENTO MANUAL
  call cts40g09_aciona_manual(lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano,
                              l_acnnaomtv,
                              1,
                              "N")
       returning l_resultado,
                 l_msg

  if l_resultado <> 0 then
     let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual1()"
     display l_msg
     call bdbsa069_trata_erros(0, lr_parametro.atdsrvnum, lr_parametro.atdsrvano, l_msg)
     exit program(1)
  end if

  #--------------------------------------------------------
  # BUSCA OS SERVICOS DE APOIO E ENVIA PARA A TELA DO RADIO
  #--------------------------------------------------------
  for l_indice = 1 to 3
      initialize al_apoio[l_indice].* to null
  end for

  call cts37g00_buscaServicoApoio(1,
                                  lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano)
       returning al_apoio[1].*,
                 al_apoio[2].*,
                 al_apoio[3].*

  for l_indice = 1 to 3
     if al_apoio[l_indice].atdsrvnum is not null then

        # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
        if cts40g18_srv_finalizado(al_apoio[l_indice].atdsrvnum,
                                   al_apoio[l_indice].atdsrvano) then
           let m_agora = current
           display m_agora, " Servico: ",
                   al_apoio[l_indice].atdsrvnum using "<<<<<<<<<&", "/",
                   al_apoio[l_indice].atdsrvano using "&&",
                   " -> JA CONCLUIDO!"
           continue for
        end if

        # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
        if cts40g18_srv(al_apoio[l_indice].atdsrvnum,
                        al_apoio[l_indice].atdsrvano) then
           let m_agora = current
           display m_agora, " Servico: ",
                            al_apoio[l_indice].atdsrvnum using "<<<<<<<<<&", "/",
                            al_apoio[l_indice].atdsrvano using "&&",
                            " -> JA CONCLUIDO!"
           continue for
        end if

        # --ENVIA O SERVICO PARA A TELA DO RADIO PARA O ACIONAMENTO MANUAL
        call cts40g09_aciona_manual(al_apoio[l_indice].atdsrvnum,
                                    al_apoio[l_indice].atdsrvano,
                                    l_acnnaomtv,
                                    1,
                                    "N")
             returning l_resultado,
                       l_msg

        if l_resultado <> 0 then
           let l_msg = "Erro ao chamar a funcao cts40g09_aciona_manual2()"
           display l_msg
           call bdbsa069_trata_erros(0, lr_parametro.atdsrvnum, lr_parametro.atdsrvano, l_msg)
           exit program(1)
        end if

     else
        exit for
     end if
  end for

  let m_agora = current
  display m_agora, " Servico: ", lr_parametro.atdsrvnum using "<<<<<<<<<&", "/",
                                 lr_parametro.atdsrvano    using "&&",
                              " -> ENVIADO PARA O RADIO <-"

  let l_atdfnlflg = "N"

  return l_atdfnlflg

end function