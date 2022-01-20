#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: BDBSA068                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 195138                                                     #
#                  ACIONAMENTO AUTOMATICO DOS SERVICOS RE.                    #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID/RAJI D. JAHCHAN                               #
# LIBERACAO......: 01/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 17/10/2006 Ligia Mattge    PSI202363  Alteração nos parametros de retorno da#
#                                       funcao cts40g05_obter_veiculo e alt no#
#                                       datracncid.cidacndst (Merge)          #
#                                                                             #
# 14/02/2007 Ligia Mattge               Chamar cta00m08_ver_contingencia      #
# 30/07/2007 Ligia Mattge    PSI211427  Tentar acionar mesmo depois que excedeu
#                                       o tempo limite e foi pro radio.       #
# 08/11/2007 Sergio Burini   DVP 25240  Monitor de Rotinas Criticas.          #
# 22/02/2008 Ligia Mattge    Porto Socorro Servicos                           #
# 28/03/2008 Ligia Mattge    Criacao funcao bdbsa068_trata_erros              #
# 21/07/2008                 PSI 214558 Inclusao metodo grava tempo distancia #
# 28/01/2009 Adriano Santos  PSI 235849 Considerar tipo de serviço SINISTRO RE#
# 13/08/2009 Sergio Burini   PSI 244236 Inclusão do Sub-Dairro                #
# 29/12/2009 Kevellin        PSI 251712 Gerenciamento da Frota Extra          #
# 27/04/2010 Adriano Santos  PSI 242853 Envia serviço PSS pela internet       #
#                                        mesmo prestador offline              #
#-----------------------------------------------------------------------------#
          
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

  define mr_principal   record
         atdsrvnum      like datmservico.atdsrvnum,
         atdsrvano      like datmservico.atdsrvano,
         atdlibhor      like datmservico.atdlibhor,
         atdlibdat      like datmservico.atdlibdat,
         atddatprg      like datmservico.atddatprg,
         atdhorprg      like datmservico.atdhorprg,
         atdhorpvt      like datmservico.atdhorpvt,
         acntntqtd      like datmservico.acntntqtd,
         atdcstvlr      like datmservico.atdcstvlr,
         atdsrvorg      like datmservico.atdsrvorg,
         c24opemat      like datmservico.c24opemat,
         atdfnlflg      like datmservico.atdfnlflg,
         acnnaomtv      like datmservico.acnnaomtv,
         ciaempcod      like datmservico.ciaempcod
  end record

  define am_multiplos   array[10] of record
         atdmltsrvnum   like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano   like datratdmltsrv.atdmltsrvano,
         socntzdes      like datksocntz.socntzdes,
         espdes         like dbskesp.espdes,
         atddfttxt      like datmservico.atddfttxt
  end record

  define mr_cts40g00_pa record
         cidacndst      like datracncid.cidacndst,
         acnlmttmp      like datkatmacnprt.acnlmttmp,
         acntntlmtqtd   like datkatmacnprt.acntntlmtqtd,
         netacnflg      like datkatmacnprt.netacnflg,
         atmacnprtcod   like datkatmacnprt.atmacnprtcod
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
         tempo_total    decimal(6,1)
  end record

  define mr_prestador   record
         cod_motivo     smallint,
         msg_motivo     like datmservico.acnnaomtv,
         pstcoddig      like datkveiculo.pstcoddig
  end record

  define mr_ctx04g00    record
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
         erro           integer,
         emeviacod      like datmlcl.emeviacod,
         celteldddcod   like datmlcl.celteldddcod,
         celtelnum      like datmlcl.celtelnum,
         endcmp         like datmlcl.endcmp
  end record

  define m_flg_ret      smallint,
         m_tentativas   smallint,
         m_agora        datetime hour to second,
         m_tmpexp       datetime year to second,
         l_prcstt       like dpamcrtpcs.prcstt,
         m_erro         char(200),
         m_atdfnlflg    like datmservico.atdfnlflg,
         m_commit       smallint, #ligia - 04/09/08
         m_atdsrvorg    like datmservico.atdsrvorg # PSI 235849 Adriano Santos 28/01/2009

#-------------------
# INICIO DO PROCESSO
#-------------------
main

  define l_path         char(100),
         l_arg_numero   like datmservico.atdsrvnum,
         l_arg_ano      like datmservico.atdsrvano,
         l_tempo_limite interval hour(6) to second,
         l_espera        interval hour(6) to second,
         l_limite_espera interval hour(6) to second,
         l_resultado    integer,
         l_msg          char(40),
         l_em_uso       smallint,
         l_indice       smallint,
         l_erro         integer,
         l_c24opemat    like datmservico.c24opemat,
         l_atddatprg     like datmservico.atddatprg,
         l_atdhorprg     like datmservico.atdhorprg,
         l_atdlibhor     like datmservico.atdlibhor,
         l_atdlibdat     like datmservico.atdlibdat,
         l_acnnaomtv     like datmservico.acnnaomtv,
         l_contingencia  smallint,
         l_atdfnlflg     like datmservico.atdfnlflg,
         l_srvprsacnhordat like datmservico.srvprsacnhordat,
         l_data_ac         date,
         l_hora_ac         datetime hour to minute,
         l_grlinf_cont  like datkgeral.grlinf,
         l_grlinf_carga like datkgeral.grlinf

  # -> INICIALIZACAO DAS VARIAVEIS
  initialize mr_principal.*   to null
  initialize mr_ctx04g00.*    to null
  initialize mr_cts40g00_pa.* to null
  initialize mr_veiculo.*     to null
  initialize mr_prestador.*   to null
  initialize l_grlinf_cont    to null
  initialize l_grlinf_carga   to null

  let m_commit       = null
  let m_erro         = null
  let l_path         = null
  let l_tempo_limite = null
  let l_espera       = null
  let l_arg_numero   = arg_val(1) # -> NUMERO DO SERVICO
  let l_arg_ano      = arg_val(2) # -> ANO DO SERVICO
  let m_tentativas   = 10
  let l_resultado    = null
  let l_em_uso       = null
  let l_c24opemat    = null
  let l_indice       = null
  let m_agora        = null
  let l_erro         = null
  let l_atdlibhor     = null
  let l_atdlibdat     = null
  let l_atddatprg     = null
  let l_atdhorprg     = null
  let l_acnnaomtv     = null
  let l_limite_espera = null
  let l_contingencia  = null
  let l_atdfnlflg     = null
  let m_atdfnlflg     = null
  let l_srvprsacnhordat = null
  let l_data_ac = null
  let l_hora_ac = null
  let m_atdsrvorg = null

  # -> CRIA O ARQUIVO DE LOG
  let l_path = bdbsa068_cria_log()

  # -> ABRE O BANCO UTILIZADO PELA CENTRAL 24 HORAS
  call fun_dba_abre_banco("CT24HS")

  # -> CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read

  # -> TEMPO PARA VERIFICAR SE O REGISTRO ESTA ALOCADO
  set lock mode to wait 20

  # -> PREPARA OS COMANDOS SQL
  call bdbsa068_prepare()

  #call cta00m08_ver_contingencia(4)
  #     returning l_contingencia

  #if l_contingencia then
  #   exit program(1)
  #end if
  #----------------------------------------------------------------------------------------------------
  # VERIFICA SE O PROCESSO DEVE ACIONAR O SRV RECBIDO NO PARAMETRO OU PESQUISAR SRV EM ACION AUTOMATICO
  #----------------------------------------------------------------------------------------------------

  if l_arg_numero is not null and   # -> NUMERO DO SERVICO
     l_arg_ano    is not null then  # -> ANO DO SERVICO
     #---------------------------------------------------------------------------
     # OBTEM TEMPO MAXIMO QUE O SERVICO DEVE PERMANECER NO ACIONAMENTO AUTOMATICO
     #---------------------------------------------------------------------------


     call cts10g06_dados_servicos(19, l_arg_numero, l_arg_ano)
          returning l_resultado,
                    l_msg,
                    l_atdlibhor,
                    l_atdlibdat,
                    l_atddatprg,
                    l_atdhorprg,
                    l_acnnaomtv,
                    l_atdfnlflg,
                    l_srvprsacnhordat,
                    m_atdsrvorg # PSI 235849 Adriano Santos 28/01/2009 recebendo atdsrvorg
     
     if l_srvprsacnhordat is null or l_srvprsacnhordat = ' ' then
     
        call ctd07g00_alt_hora_acn(l_arg_numero, l_arg_ano)
        
        call cts10g06_dados_servicos(19, l_arg_numero, l_arg_ano)
          returning l_resultado,
                    l_msg,
                    l_atdlibhor,
                    l_atdlibdat,
                    l_atddatprg,
                    l_atdhorprg,
                    l_acnnaomtv,
                    l_atdfnlflg,
                    l_srvprsacnhordat,
                    m_atdsrvorg # PSI 235849 Adriano Santos 28/01/2009 recebendo atdsrvorg
        
     end if
     # -> OBTEM OS PARAMETROS DO ACIONAMENTO AUTOMATICO C/ORIGEM 9 ou 13 # PSI 235849 Adriano Santos 28/01/2009
     call bdbsa068_obter_param()


     if l_resultado <> 1 then
        call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, l_msg)
        exit program(1)
     end if

     let m_atdfnlflg = l_atdfnlflg

     if l_atddatprg is null then
        # SERVICO IMEDIATO
        let l_limite_espera = "0:10:00"
    else
        # SERVICO PROGRAMADO
        let l_limite_espera = "00:20:00"
    end if

    let l_data_ac = date(l_srvprsacnhordat)
    let l_hora_ac = time(l_srvprsacnhordat)

    let l_espera = cts40g03_espera(l_data_ac, l_hora_ac)

    if l_espera is null then
       let m_erro =  "Calculo do tempo de espera esta nulo"
       call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
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

          let l_atdfnlflg = bdbsa068_envia_radio(l_arg_numero, l_arg_ano)

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
                           " -> JA CONCLUIDO!"
          exit program(1)
       end if

       #---------------------------------------------------------
       # VERIFICA SE O SERVICO ESTA SENDO ALTERADO PELO ATENDENTE
       #---------------------------------------------------------
       call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano)
            returning l_em_uso, l_c24opemat

       if l_c24opemat is not null then     # -> SERVICO ESTA EM USO(ATENDENTE)
          let m_agora = current
          display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                           l_arg_ano    using "&&",
                           " -> EM USO POR ", l_c24opemat
          exit program(1)
       end if

       if l_c24opemat is null then     # -> SERVICO NAO ESTA EM USO(ATENDENTE)
                                       # -> SERVICO PRESO C/MATRICULA DO SISTEMA
          # -> BLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
          let l_resultado = cts40g06_bloq_srv(l_arg_numero,
                                              l_arg_ano)

          if l_resultado <> 0 then
             let m_erro = "cts40g06_bloq_srv() ", l_resultado
             call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
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

          let l_resultado = bdbsa068_proc_srv(l_arg_numero, # -> NUMERO DO SERVICO
                                              l_arg_ano)    # -> ANO DO SERVICO

          let m_agora = current
          case l_resultado

             when(0) # -> NAO ACIONADO
                display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                 l_arg_ano    using "&&",
                                 " -> AGUARDANDO NOVA TENTATIVA."

                #ligia 29/08/07
                call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano)
                     returning l_em_uso, l_c24opemat

                if l_c24opemat = 999999 then
                   # -> DESBLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
                   let l_erro = cts40g06_desb_srv(l_arg_numero,
                                                  l_arg_ano)
                   if l_erro <> 0 then
                      let m_erro = "cts40g06_desb_srv() ", l_erro
                      call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
                      exit program(1)
                   end if
                end if

             when(1) # -> ACIONADO
                display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                 l_arg_ano using "&&",
                                 " -> ACIONADO COM SUCESSO! lclltt: ", mr_ctx04g00.lclltt,' lcllgt', mr_ctx04g00.lcllgt,' VEIC: ', mr_veiculo.socvclcod,' lclltt: ',mr_veiculo.lclltt,' lcllgt: ', mr_veiculo.lcllgt
                exit while

             when(2) # -> NAO ACIONAR
                display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                                 l_arg_ano    using "&&",
                                 " -> NAO PODE SER ACIONADO."

                #ligia 29/08/07
                call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano)
                     returning l_em_uso, l_c24opemat

                if l_c24opemat = 999999 then
                   # ->  DESBLOQUEAR SERVICO P/ACIONAMENTO AUTOMATICO
                   let l_erro = cts40g06_desb_srv(l_arg_numero,
                                                  l_arg_ano)

                   if l_erro <> 0 then
                      let m_erro = "cts40g06_desb_srv() ", l_erro
                      call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
                      exit program(1)
                   end if
                end if

             otherwise
                let m_erro =  m_agora, " -> ERRO NO ACIONAMENTO ", l_resultado
                call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
                exit program(1)
          end case

       end if  #FIM VERIFICACAO SE SERVICO ESTA EM USO

       if l_resultado = 2 then # -> NAO ACIONAR
          let l_espera = cts40g03_espera(l_data_ac, l_hora_ac)
          display m_agora, " Servico: ",
                 l_arg_numero using "<<<<<<<<<&", "/",
                 l_arg_ano    using "&&",
                 " ESPERA", l_espera, " DATA ",l_data_ac," HORA ",l_hora_ac

          # VERIFICA SE ESTA NA HORA DE ENVIAR O SERVICO PARA O RADIO
          if (l_espera >= l_limite_espera) and l_atdfnlflg = "A" then

             let l_atdfnlflg = bdbsa068_envia_radio(l_arg_numero, l_arg_ano)

          end if
          exit while
       else
          let l_espera = cts40g03_espera(l_data_ac, l_hora_ac)
          display m_agora, " Servico: ",
                 l_arg_numero using "<<<<<<<<<&", "/",
                 l_arg_ano    using "&&",
                 " ESPERA", l_espera, " DATA ",l_data_ac," HORA ",l_hora_ac

          # VERIFICA SE ESTA NA HORA DE ENVIAR O SERVICO PARA O RADIO
          if (l_espera >= l_limite_espera) and l_atdfnlflg = "A" then

             let l_atdfnlflg = bdbsa068_envia_radio(l_arg_numero, l_arg_ano)

          end if
       end if

       #--------------------------------------------------------
       # AGUARDA 60 SEGUNDOS PARA NOVA TENTATIVA DE ACIONAMENTO
       #--------------------------------------------------------
       sleep 60

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

       # -> ENVIA O SERVICO P/O RADIO
       #ligia 29/08/07
       call cts40g18_srv_em_uso(l_arg_numero, l_arg_ano)
            returning l_em_uso, l_c24opemat

       if l_c24opemat is null or l_c24opemat = 999999 then
          let l_erro = cts40g06_env_radio(l_arg_numero,
                                          l_arg_ano)

          if l_erro <> 0 then
             let m_erro = "cts40g06_env_radio() ", l_erro
             call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
             exit program(1)
          end if
       else
          let m_agora = current
          display m_agora, " Servico: ", l_arg_numero using "<<<<<<<<<&", "/",
                           l_arg_ano    using "&&",
                           " -> EM USO POR: ", l_c24opemat
           exit program(1)
       end if

       # -> ENVIA OS SERVICOS MULTIPLOS
       for l_indice = 1 to 10
          if am_multiplos[l_indice].atdmltsrvnum is not null then

             # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
             if cts40g18_srv_finalizado(am_multiplos[l_indice].atdmltsrvnum,
                                        am_multiplos[l_indice].atdmltsrvano) then
                let m_agora = current
                display m_agora, " Servico: ",
                        am_multiplos[l_indice].atdmltsrvnum using "<<<<<<<<<&", "/",
                        am_multiplos[l_indice].atdmltsrvano using "&&", " -> JA CONCLUIDO!"
                exit program(1)
             end if

             # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
             if cts40g18_srv(am_multiplos[l_indice].atdmltsrvnum,
                             am_multiplos[l_indice].atdmltsrvano) then
                let m_agora = current
                display m_agora, " Servico: ",
                                 am_multiplos[l_indice].atdmltsrvnum using "<<<<<<<<<&", "/",
                                 am_multiplos[l_indice].atdmltsrvano using "&&", " -> JA CONCLUIDO!"
                exit program(1)
             end if

             # -> ENVIA O SERVICO MULTIPLO P/O RADIO
             let l_erro = cts40g06_env_radio(am_multiplos[l_indice].atdmltsrvnum,
                                             am_multiplos[l_indice].atdmltsrvano)

             if l_erro <> 0 then
                let m_erro = "cts40g06_env_radio() ", l_erro
                call bdbsa068_trata_erros(0, am_multiplos[l_indice].atdmltsrvnum,
                                          am_multiplos[l_indice].atdmltsrvano,
                                          m_erro)
                exit program(1)
             end if

          else
             # -> NAO POSSUI SERVICOS MULTIPLOS
             exit for
          end if

       end for
    end if

  else
     # PESQUISA SERVICOS NO ACIONAMENTO AUTOMATICO PARA CRIAR PROCESSO

     #--------------------------------------------------
     # LACO INFINITO P/PESQUISA DE SERVICOS P/ACIONAMENTO
     #--------------------------------------------------

     let  m_tmpexp = current

     while true
        
        let m_agora = current
        display m_agora, " Inicio do processo"
        
        call ctx28g00("bdbsa068", fgl_getenv("SERVIDOR"), m_tmpexp)
             returning m_tmpexp, l_prcstt

        if  l_prcstt = 'A' then

            #------------------------------------------------------------------------
            # VERIFICA SE O ARQUIVO DE LOG EXISTE, SE NAO EXISTIR, ENCERRA O PROGRAMA
            #------------------------------------------------------------------------
            if not cts40g03_verifi_log_existe(l_path) then
               let m_erro = "Nao encontrou o arquivo de log !"
               call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
               exit program(0)
            end if

            #---------------------------------------
            # GRAVA O MONITORAMENTO DO PROCESSAMENTO
            #---------------------------------------
            let l_resultado = cts40g03_atlz_proc("BDBSA068")
            if l_resultado <> 0 then
               let m_erro = "cts40g03_atlz_proc() ", l_resultado
               call bdbsa068_trata_erros(0, l_arg_numero, l_arg_ano, m_erro)
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

            #-----------------------------------------------------------
            #CHAMA CARGA AUTOMATICA DE CONTINGENCIA
            #-----------------------------------------------------------
            call cts40g23_busca_chv("PSOCONTINGENCIA")
                 returning l_grlinf_cont
                 
            call cts40g23_busca_chv("PSOCNTCARGA")
                 returning l_grlinf_carga

            if l_grlinf_cont = "INATIVA" AND l_grlinf_carga <> "PROCESSADA" then
            	 initialize g_contigencia.* to null
            	 let g_contigencia.aut = 1 
               let m_agora = current
            	 display "   ", m_agora, " Antes da carga automatica de contingencia"
            	 call cts35m00()
               let m_agora = current
             	 display "   ", m_agora, " Depois da carga automatica de contingencia"
            end if

            #-----------------------------------------------------------
            #VERIFICA SE O ACIONAMENTOWEB E CONTINGENCIA NAO ESTAO ATIVO
            #-----------------------------------------------------------
            if (not ctx34g00_ver_acionamentoWEB(2)) and
            	 (not cta00m08_ver_contingencia(4)) then
               #--------------------------------------------------------------
               # VERIFICA SERVICOS QUE ESTAO AGUARDANDO ACIONAMENTO AUTOMATICO
               #--------------------------------------------------------------
               call bdbsa068()
            end if

        end if

        let m_agora = current
        display m_agora, " Fim do processo"

        #------------------------------------------------------
        # AGUARDA 60 SEGUNDOS PARA NOVA VERIFICACAO DE SERVICOS
        #------------------------------------------------------
        sleep 60

     end while

   end if

end main

#-------------------------#
function bdbsa068_prepare()
#-------------------------#

  define l_sql char(400)

  let l_sql = null

  let l_sql = " select atdlibhor, ",
                     " atdlibdat, ",
                     " atddatprg, ",
                     " atdhorprg, ",
                     " atdhorpvt, ",
                     " acntntqtd, ",
                     " atdcstvlr, ",
                     " atdsrvorg, ",
                     " ciaempcod ", ## psi 211982
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pbdbsa068002 from l_sql
  declare cbdbsa068002 cursor for pbdbsa068002
  
  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "
  prepare pbdbsa068003 from l_sql
  declare cbdbsa068003 cursor for pbdbsa068003

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
                 ' and atdetpcod = 3 '

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
                 " and atdetpcod in (3,10) ",
                 " and atdsrvorg in (9,13) "
  prepare pbdbsa068004 from l_sql
  
end function

#--------------------------#
function bdbsa068_cria_log()
#--------------------------#

  define l_path char(100)

  let l_path = null

  let l_path = f_path("DBS","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdbsa068.log"

  call startlog(l_path)

  return l_path

end function

#-----------------------------#
function bdbsa068_obter_param()
#-----------------------------#

  define l_resultado integer,
         l_mensagem  char(100)

  let l_resultado = null
  let l_mensagem  = null

  # -> OBTEM OS PARAMETROS DO ACIONAMENTO AUTOMATICO C/ORIGEM 9 ou 13
  initialize mr_cts40g00_pa.* to null

  call cts40g00_obter_parametro(m_atdsrvorg) # PSI 235849 Adriano Santos 28/01/2009
       returning l_resultado,
                 l_mensagem,
                 mr_cts40g00_pa.acnlmttmp,
                 mr_cts40g00_pa.acntntlmtqtd,
                 mr_cts40g00_pa.netacnflg,
                 mr_cts40g00_pa.atmacnprtcod

  if l_resultado <> 0 then
     if l_resultado = 1 then
        let m_erro = l_mensagem
     else
        let m_erro = "cts40g00_obter_parametro(m_atdsrvorg) ", l_mensagem
     end if
     call bdbsa068_trata_erros(0, 0,0, m_erro)
     exit program(1)
  end if

end function

#-----------------#
function bdbsa068()
#-----------------#

  define l_atdsrvorg like datmservico.atdsrvorg

  define lr_cts29g00    record
         atdsrvnum      like datratdmltsrv.atdsrvnum,
         atdsrvano      like datratdmltsrv.atdsrvano
  end record

  define l_hora_char1      char(08),
         l_hora_char2      char(08),
         l_sql             char(800),
         l_comando         char(50),
         l_hora_inter1     interval hour to minute,
         l_hora_inter2     interval hour to minute,
         l_data_sql        date,
         l_data_pos        date,
         l_hora_inicial    datetime hour to second,
         l_hora_final      datetime hour to minute,
         l_hora_ant00      datetime hour to minute,
         l_hora_pos00      datetime hour to minute,
         l_salva_hora      datetime hour to minute,
         l_calc_hora       interval hour to minute,
         l_resultado       integer,
         l_mensagem        char(100),
         l_continua        smallint,
         l_retorno         smallint,
         l_despreza        smallint,
         l_desprezados     integer,
         l_instanciados    integer,
         l_contingencia    smallint,
         l_hordatc         char(25),
         l_hordat          datetime year to second,
         l_prog            char(25), # PSI 235849 Adriano Santos 28/01/2009
         l_dias_atecipados smallint,
         l_roda_atecipados smallint,
         l_grlchv          like datkgeral.grlchv

  let l_continua        = false
  let l_retorno         = false
  let l_despreza        = false
  let l_desprezados     = 0
  let l_instanciados    = 0
  let l_hora_char1      = null
  let l_hora_char2      = null
  let l_sql             = null
  let l_comando         = null
  let l_hora_inter1     = null
  let l_hora_inter2     = null
  let l_data_sql        = null
  let l_data_pos        = null
  let l_hora_inicial    = null
  let l_hora_final      = null
  let l_hora_ant00      = null
  let l_hora_pos00      = null
  let l_salva_hora      = null
  let l_calc_hora       = null
  let l_resultado       = null
  let l_mensagem        = null
  let l_contingencia    = null
  let l_hordatc         = null
  let l_hordat          = null 
  let l_dias_atecipados = 0   
  let l_roda_atecipados = 0
  let l_grlchv          = null

  initialize lr_cts29g00.* to null
  call cta00m08_ver_contingencia(4)
       returning l_contingencia

  if l_contingencia then
     let m_agora = current
     display m_agora, " Contingencia Ativa/Carga ainda nao realizada"
  end if

  if ctx34g00_ver_acionamentoWEB(2) then
     display "AcionamentoWeb Ativo."
  end if
  
  # Obtem numero de tentativas para processar servicos antecipados
  let l_grlchv = 'PSOACNAUTPRCANT'
  open cbdbsa068003 using l_grlchv
  fetch cbdbsa068003 into l_roda_atecipados
  if sqlca.sqlcode = notfound then
     let l_roda_atecipados = 30
  end if
  close cbdbsa068003

  let l_sql = " select atdsrvnum, ",
                     " atdsrvano, ",
                     " atdlibhor, ",
                     " atdlibdat, ",
                     " atddatprg, ",
                     " atdhorprg, ",
                     " atdhorpvt, ",
                     " acntntqtd, ",
                     " atdcstvlr, ",
                     " atdsrvorg, ",
                     " c24opemat, ",
                     " atdfnlflg, ",
                     " acnnaomtv, ",
                     " ciaempcod ",
                " from datmservico ",
                " where atdlibflg = 'S' ",
                  " and atdfnlflg in ('A','N') ", #psi 211427
                  " and atdsrvorg in (9,13)" # PSI 235849 Adriano Santos 28/01/2009 serviço 9 e 13

  if m_tentativas >= l_roda_atecipados then
     # -> EXECUTA O SQL COMPLETO SEM FILTRO EM HORARIO DE ACIONAMENTO
     let m_tentativas = 0

     # Obtem numero de dias de atecedencia para processar servicos antecipados
     let l_grlchv = 'PSOACNAUTDIAANT'
     open cbdbsa068003 using l_grlchv
     fetch cbdbsa068003 into l_dias_atecipados
     if sqlca.sqlcode = notfound then
        let l_roda_atecipados = 7
     end if
     close cbdbsa068003

     let l_sql =  l_sql clipped,
                  " and (srvprsacnhordat <= (current + ", l_dias_atecipados," units day) or srvprsacnhordat is null)"
                  
     #----------------------------------------------------------------
     # AJUSTA OS SERVICOS JA CONCLUIDOS COM FLAG DE ACIONAMENTO ERRADO
     #----------------------------------------------------------------
     whenever error continue
     execute pbdbsa068004
     whenever error stop                  
     
  else
     # -> FILTRA OS SERVICO COM O FILTRO EM HORARIO DE ACIONAMENTO
     let m_tentativas = m_tentativas + 1

     let l_sql =  l_sql clipped,
                  " and srvprsacnhordat > (current - 24 units hour)",
                  " and srvprsacnhordat < current "
  end if

  let l_sql = l_sql clipped,
              " order by 5, 6, 4, 3 "

  prepare pbdbsa068001 from l_sql
  declare cbdbsa068001 cursor with hold for pbdbsa068001

  # -> CURSOR PRINCIPAL, BUSCA OS DADOS DA TABELA datmservico
  open cbdbsa068001
  foreach cbdbsa068001 into mr_principal.atdsrvnum,
                            mr_principal.atdsrvano,
                            mr_principal.atdlibhor,
                            mr_principal.atdlibdat,
                            mr_principal.atddatprg,
                            mr_principal.atdhorprg,
                            mr_principal.atdhorpvt,
                            mr_principal.acntntqtd,
                            mr_principal.atdcstvlr,
                            mr_principal.atdsrvorg,
                            mr_principal.c24opemat,
                            mr_principal.atdfnlflg,
                            mr_principal.acnnaomtv,  #psi 211427
                            mr_principal.ciaempcod

     call cta00m08_ver_contingencia(4)
          returning l_contingencia

     if l_contingencia or
        (mr_principal.atdfnlflg = "N" and mr_principal.acnnaomtv is null) then
        continue foreach
     end if

     if ctx34g00_ver_acionamentoWEB(2) then
        continue foreach
     end if

     if mr_principal.atdfnlflg = "A" and mr_principal.c24opemat is not null then
        if mr_principal.atdsrvorg = 9 then # PSI 235849 Adriano Santos 28/01/2009
            let l_prog = "ACIONAMENTO_AUTOMATICO_RE"
        else
            let l_prog = "ACIONAMENTO_AUTOMATICO_SINISTRO_RE"
        end if
        call cts40g25_srv_preso(mr_principal.atdsrvnum,
                                mr_principal.atdsrvano,
                                mr_principal.c24opemat,
                                mr_principal.atdfnlflg,
                                mr_principal.acnnaomtv,
                                mr_principal.atdsrvorg,
                                l_prog) # PSI 235849 Adriano Santos 28/01/2009
        continue foreach
     end if

     # -> CHAMA A FUNCAO P/VERIFICAR SE O SERVICO E MULTIPLO
     call cts29g00_consistir_multiplo(mr_principal.atdsrvnum,
                                      mr_principal.atdsrvano)
          returning l_resultado,
                    l_mensagem,
                    lr_cts29g00.atdsrvnum,
                    lr_cts29g00.atdsrvano

     if l_resultado <> 2 then
        # -> NAO FOR ERRO
        if l_resultado = 1 then
           # -> SE O SERVICO FOR MULTIPLO, DESPREZA
           continue foreach
        else
           let m_erro = "cts29g00_consistir_multiplo() ", l_mensagem
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano, m_erro)
           exit program(1)
        end if
     end if

     let l_resultado = 0
     let l_mensagem  = null
     let l_retorno = false

     call ctd07g04_srv_ret(mr_principal.atdsrvnum, mr_principal.atdsrvano)
          returning l_resultado, l_mensagem

     ## Instanciar para os servicos de retorno (RET)
     if l_resultado = 1 then
        let l_retorno = true
     end if

     if m_tentativas = 0 then ## Quando executa o sql completo

        if l_retorno = false then
           ## Valida os servicos de internet que devem ser instaciados
           let l_continua = false
           call bdbsa068_val_instancias() returning l_continua

           if l_continua = false then ##ligia 25/04/08
              let l_desprezados = l_desprezados + 1
              continue foreach
           end if

           ## Porto Servicos - ligia - 22/02/08
           let l_despreza = false
           call bdbsa068_val_srv() returning l_despreza

           # desprezar os servicos que estao fora do tempo previsto p/acionamento
           if l_despreza = true then
              let l_desprezados = l_desprezados + 1
              let l_continua = false
           else
              let l_continua = true
           end if
        else
           let l_continua = true
        end if
     else
        let l_continua = true
     end if


     if l_continua = false then
        let l_desprezados = l_desprezados + 1
        continue foreach
     else
        let l_instanciados = l_instanciados + 1
     end if

     # -> MONTA O COMANDO P/CRIAR UMA NOVA INSTANCIA DO PROGRAMA
     let l_comando = "bdbsx068.sh ", mr_principal.atdsrvnum using "<<<<<<<<<&", " ",
                                     mr_principal.atdsrvano using "<&"

     run l_comando

  end foreach

  close cbdbsa068001

  let m_agora = current
  display " ***** RESUMO DOS SERVICOS LIDOS ************ "
  display " HORA/TENTATIVAS            : ", m_agora,' ', m_tentativas
  display " TOTAL SERVICOS INSTANCIADOS: ", l_instanciados using "####&"
  display " TOTAL SERVICOS DESPREZADOS : ", l_desprezados  using "####&"
  display " ******************************************** "

end function

#-----------------------------#
function bdbsa068_ac_internet()
#-----------------------------#

  define l_resultado    smallint,
         l_mensagem     char(100),
         l_atdetpseq    like datmsrvint.atdetpseq,
         l_atdetpcod    like datmsrvint.atdetpcod,
         l_ok           smallint,
         l_indice       smallint,
         l_etapa        like datmsrvacp.atdetpcod,
         l_data_atual   date,
         l_hora_atual   datetime hour to minute

  let l_resultado  =  null
  let l_mensagem  =  null
  let l_atdetpseq  =  null
  let l_atdetpcod  =  null
  let l_indice  =  null
  let l_etapa  =  null
  let l_data_atual  =  null
  let l_hora_atual  =  null

  let l_ok = true

  call cts33g00_inf_internet(mr_principal.atdsrvnum,
                             mr_principal.atdsrvano)
       returning l_resultado,
                 l_mensagem,
                 l_atdetpseq,
                 l_atdetpcod

  if l_resultado <> 1 then
     if l_resultado <> 2 then
        let m_erro = "Erro ao chamar a funcao cts33g00_inf_internet()"
        display l_mensagem
        let l_ok = false
        call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano,
                                     m_erro)
        return l_ok
     end if
  end if

  # -> REGISTRA P/INTERNET O SERVICO ENCONTRADO
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
     let m_erro = " Erro ao chamar a funcao cts33g00_registrar_para_internet()"
     let m_erro = m_erro clipped, " ",l_mensagem
     let l_ok = false
     display m_erro
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  # -> ATUALIZA OS DADOS DO SERVICO ORIGINAL
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
     let m_erro = l_resultado, " em cts33g01_alt_dados_automat"
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  for l_indice = 1 to 10

     if am_multiplos[l_indice].atdmltsrvnum is not null then

        # -> ATUALIZAR PARA CADA SERVICO MULTIPLO
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
                                                     am_multiplos[l_indice].atdmltsrvnum,
                                                     am_multiplos[l_indice].atdmltsrvano)
        if l_resultado <> 0 then
           let l_ok = false
           exit for
        end if
     else
        # -> NAO POSSUI SERVICOS MULTIPLOS
        exit for
     end if

  end for

  # -> SE OCORREU ERRO NO "FOR" ACIMA, ENCERRA OS PROCEDIMENTOS
  if l_ok = false then
     let m_erro = l_resultado, " em cts33g01_alt_dados_automat c/mlt"
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  # -> SE FOR SERVICO DE RETORNO ETAPA = 10
  # -> CASO CONTRARIO A ETAPA = 3

  if m_flg_ret then
     # -> SERVICO DE RETORNO
     let l_etapa = 10
  else
     let l_etapa = 3
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
     let m_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
     let l_ok = false
     display m_erro
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  # -> ATUALIZA DADOS DO SERVICO
  call cts10g04_atualiza_dados(mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               "",
                               2)

       returning l_mensagem,
                 l_resultado

  if l_resultado <> 1 then
     let m_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
     let m_erro = m_erro clipped, " ", l_mensagem
     display m_erro
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     let l_ok = false
     return l_ok
  end if

  for l_indice = 1 to 10

     if am_multiplos[l_indice].atdmltsrvnum is not null then

        # -> INSERIR ETAPA PARA CADA SERVICO MULTIPLO
        let l_resultado = cts40g22_insere_etapa(am_multiplos[l_indice].atdmltsrvnum,
                                                am_multiplos[l_indice].atdmltsrvano,
                                                l_etapa,
                                                mr_prestador.pstcoddig,
                                                "",
                                                "",
                                                "")

        if l_resultado <> 0 then
           let m_erro= "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
           display m_erro
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        m_erro)
           let l_ok = false
           exit for
        end if

        # -> ATUALIZA OS DADOS PARA CADA SERVICO MULTIPLO
        call cts10g04_atualiza_dados(am_multiplos[l_indice].atdmltsrvnum,
                                     am_multiplos[l_indice].atdmltsrvano,
                                     "",
                                     2)
             returning l_mensagem,
                       l_resultado

        if l_resultado <> 1 then
           let m_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
           let m_erro = m_erro clipped, " ",l_mensagem
           display m_erro

           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        m_erro)
           let l_ok = false
           exit for
        end if

     else
        # -> NAO TEM MULTIPLOS
        exit for
     end if

  end for

  return l_ok

end function

#------------------------#
function bdbsa068_ac_gps()
#------------------------#

  define l_socacsflg     like datkveiculo.socacsflg,
         l_previsao      like datmservico.atdprvdat,
         l_calc_prev     char(06),
         l_resultado     integer,
         l_flgerro       char(01),
         l_aux_calc      char(06),
         l_mensagem      char(60),
         l_indice        smallint,
         l_ok            smallint,
         l_tentativas    like datmservico.acntntqtd,
         l_data_atual    date,
         l_hora_atual    datetime hour to minute

  let l_socacsflg  =  null
  let l_previsao  =  null
  let l_calc_prev  =  null
  let l_resultado  =  null
  let l_flgerro  =  null
  let l_aux_calc  =  null
  let l_mensagem  =  null
  let l_indice  =  null
  let l_tentativas  =  null
  let l_data_atual  =  null
  let l_hora_atual  =  null

  let l_ok = true

  if ctx25g05_rota_ativa() then
     let l_previsao = "00:00"
     let l_previsao = (l_previsao + mr_veiculo.tempo_total units minute)
  else
     # -> CALCULAR A PREVISAO DE CHEGADA
     let l_aux_calc  = mr_principal.atdhorpvt
     let l_calc_prev = cts21g00_calc_prev(mr_veiculo.distancia, l_aux_calc)

     # -> RECEBE O CALCULO DA PREVISAO(l_calc_prev) NUM CHAR(06) E APOS PASSA
     # -> PARA A PREVISAO FINAL(l_previsao) QUE E DO TIPO datetime hour to minute
     let l_previsao  = l_calc_prev
  end if

  let l_tentativas = mr_principal.acntntqtd

  # -> CONTABILIZA A TENTATIVA DO ACIONAMENTO
  let l_tentativas = l_tentativas + 1

  # -> ATUALIZAR O VEICULO/SOCORRISTA NO SERVICO
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
     let m_erro = "Nao atualizou em cts33g01_alt_dados_automat()"
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  for l_indice = 1 to 10
     if am_multiplos[l_indice].atdmltsrvnum is not null then

        #--REGISTRAR PRESTADOR PARA CADA SERVICO MULTIPLO
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
                                                     am_multiplos[l_indice].atdmltsrvnum,
                                                     am_multiplos[l_indice].atdmltsrvano)
        if l_resultado <> 0 then
           let l_ok = false
           exit for
        end if
     else
        # -> NAO POSSUI SERVICOS MULTIPLOS
        exit for
     end if

  end for

  if l_ok = false then
     let m_erro = "Nao atualizou em cts33g01_alt_dados_automat() p/mlt"
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  # -> INSERIR ETAPA
  let l_resultado = cts40g22_insere_etapa(mr_principal.atdsrvnum,
                                          mr_principal.atdsrvano,
                                          3,
                                          mr_veiculo.pstcoddig,
                                          "",
                                          mr_veiculo.socvclcod,
                                          mr_veiculo.srrcoddig)

  if l_resultado <> 0 then
     let l_ok = false
     let m_erro =  "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  ####PSI 214558
  call cts10g04_tempo_distancia(mr_principal.atdsrvnum,
                                mr_principal.atdsrvano,
                                3,
                                mr_veiculo.distancia)
       returning l_resultado

  if l_resultado <> 0 then
      let m_erro = " Erro: ", l_resultado, " ao chamar a funcao ",
                       " cts10g04_tempo_distancia() ",
                       " Srv: ", mr_principal.atdsrvnum
      let l_ok = false
      call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                   mr_principal.atdsrvano,
                                   m_erro)
      return l_ok
  end if

  call cts10g04_atualiza_dados(mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               "",
                               1)
       returning l_mensagem,
                 l_resultado

  if l_resultado <> 1 then
     let m_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
     display l_mensagem
     let m_erro = m_erro clipped, " ", l_mensagem
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     let l_ok = false
     return l_ok
  end if

  # -> INSERIR A ETAPA PARA OS SERVICOS MULTIPLOS
  for l_indice = 1 to 10
     if am_multiplos[l_indice].atdmltsrvnum is not null then
        # -> REGISTRAR PRESTADOR PARA CADA SERVICO MULTIPLO
        let l_resultado = cts40g22_insere_etapa(am_multiplos[l_indice].atdmltsrvnum,
                                                am_multiplos[l_indice].atdmltsrvano,
                                                3,
                                                mr_veiculo.pstcoddig,
                                                "",
                                                mr_veiculo.socvclcod,
                                                mr_veiculo.srrcoddig)

        if l_resultado <> 0 then
           let m_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
           display m_erro
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        m_erro)
           let l_ok = false
           exit for
        end if

        ####PSI 214558
        call cts10g04_tempo_distancia(mr_principal.atdsrvnum,
                                      mr_principal.atdsrvano,
                                      3,
                                      mr_veiculo.distancia)
             returning l_resultado

        if l_resultado <> 0 then
            let m_erro = " Erro: ", l_resultado, " ao chamar a funcao ",
                             " cts10g04_tempo_distancia() ",
                             " Srv: ", mr_principal.atdsrvnum
            let l_ok = false
            call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                         mr_principal.atdsrvano,
                                         m_erro)
            return l_ok
        end if

        call cts10g04_atualiza_dados(am_multiplos[l_indice].atdmltsrvnum,
                                     am_multiplos[l_indice].atdmltsrvano,
                                     "",
                                     1)
             returning l_mensagem,
                       l_resultado

        if l_resultado <> 1 then
           let m_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
           let m_erro = m_erro clipped, " ", l_mensagem
           display m_erro
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        m_erro)
           let l_ok = false
           exit for
        end if

     else
        # -> NAO POSSUI SERVICOS MULTIPLOS
        exit for
     end if

  end for

  if l_ok = false then
     return l_ok
  end if

  # -> ENVIO DA REFERENCIA DO ENDERECO VIA TELETRIM
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
     let l_ok = false
     let m_erro = "Erro ao chamar a funcao cts00g02_env_msg_mdt()"
     display m_erro
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
     return l_ok
  end if

  # -> BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual,
                 l_hora_atual

  # -> CARREGA DADOS DO SERVICO P/POSICAO DA FROTA
  let l_resultado = cts33g01_posfrota(mr_veiculo.socvclcod,
                                      "N",
                                       mr_ctx04g00.ufdcod,
                                       mr_ctx04g00.cidnom,
                                       mr_ctx04g00.brrnom,
                                       mr_ctx04g00.endzon,
                                       mr_ctx04g00.lclltt,
                                       mr_ctx04g00.lcllgt,
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
    let m_erro = l_resultado, " em cts33g01_posfrota() "
    call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                 mr_principal.atdsrvano,
                                 m_erro)
  end if


  ## p/acompanhar os casos em que aciona viatura fora da distancia limite
  ## ligia 20/03/2007
  call cts40g25_ac(mr_principal.atdsrvnum, mr_principal.atdsrvano,"BDBSA068")

  return l_ok

end function

#--------------------------------------#
function bdbsa068_atlz_mul(l_msg_motivo)
#--------------------------------------#

  # FUNCAO PARA ENVIAR OS SERVICOS MULTIPLOS DO SERVICO P/A TELA DO RADIO

  define l_indice     smallint,
         l_resultado  smallint,
         l_mensagem   char(80),
         l_msg_motivo char(40)

  let l_indice    = null
  let l_resultado = null
  let l_mensagem  = null
  let l_indice    = null
  let l_resultado = null
  let l_mensagem  = null

  # -> ATUALIZA OS SERVICOS MULTIPLOS
  for l_indice = 1 to 10
     if am_multiplos[l_indice].atdmltsrvnum is not null then

        call cts40g09_aciona_manual (am_multiplos[l_indice].atdmltsrvnum,
                                     am_multiplos[l_indice].atdmltsrvano,
                                     l_msg_motivo,
                                     1,
                                     "N")
             returning l_resultado,
                       l_mensagem

        if l_resultado <> 0 then
           let m_erro =  "cts40g09_aciona_manual() ", l_mensagem
           call bdbsa068_trata_erros(0, am_multiplos[l_indice].atdmltsrvnum,
                                     am_multiplos[l_indice].atdmltsrvano,
                                     m_erro)
           exit program(1)
        end if

     else
        # -> NAO POSSUI SERVICOS MULTIPLOS
        exit for
     end if

  end for

  let m_agora = current
  display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                 mr_principal.atdsrvano using "&&",
                   " -> MOTIVO DO NAO ACN: ", l_msg_motivo

end function

#--------------------------------------#
function bdbsa068_proc_srv(lr_parametro)
#--------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

# define lr_cts23g00   record
#        resultado     integer,
#        mpacidcod     like datkmpacid.mpacidcod,
#        lclltt        like datkmpacid.lclltt,
#        lcllgt        like datkmpacid.lcllgt,
#        mpacrglgdflg  like datkmpacid.mpacrglgdflg,
#        gpsacngrpcod  like datkmpacid.gpsacngrpcod
# end record

  define lr_cts41g03   record
         resultado     smallint,
         mensagem      char(70),
         mpacidcod     like datkmpacid.mpacidcod,
         gpsacngrpcod  like datkmpacid.gpsacngrpcod
  end record

  define l_resultado    integer,
         l_em_uso       smallint,
         l_c24opemat    like datmservico.c24opemat,
         l_proximo      smallint,
         l_qtd_acion    smallint,
         l_qdt_serv     smallint,
         l_ok_aciona    smallint,
         l_online       smallint,
         l_situacao_gps smallint,
         l_exis_48h     smallint,
         l_mult_manual  smallint,
         l_ac_manual    smallint,
         l_bloqueou     smallint,
         l_desbloqueou  smallint,
         l_mensagem     char(100),
         l_atdfnlflg    like datmservico.atdfnlflg,
         l_qtd_srr_disponiveis  smallint,          #PSI202363
         l_acionar      smallint,
         l_srv_retorno  smallint

  let l_resultado  =  null
  let l_em_uso  =  null
  let l_c24opemat  =  null
  let l_proximo  =  null
  let l_qtd_acion  =  null
  let l_qdt_serv  =  null
  let l_online  =  null
  let l_situacao_gps  =  null
  let l_mult_manual  =  null
  let l_ac_manual  =  null
  let l_mensagem  =  null
  let l_atdfnlflg  =  null
  let l_bloqueou    = null
  let l_desbloqueou = null
  let l_qtd_srr_disponiveis = null
  let l_acionar  = false
  let l_srv_retorno = false

  initialize  lr_cts41g03.*  to  null

  let l_ok_aciona             = false
  let l_exis_48h              = false
  let m_flg_ret               = false
  let mr_prestador.cod_motivo = 0

  # -> OBTEM OS PARAMETROS DO ACIONAMENTO AUTOMATICO C/ORIGEM 9
  call bdbsa068_obter_param()

  let mr_principal.atdsrvnum = lr_parametro.atdsrvnum
  let mr_principal.atdsrvano = lr_parametro.atdsrvano

  # -> BUSCA OS DADOS DO SERVICO
  open cbdbsa068002 using mr_principal.atdsrvnum,
                          mr_principal.atdsrvano
  whenever error continue
  fetch cbdbsa068002 into mr_principal.atdlibhor,
                          mr_principal.atdlibdat,
                          mr_principal.atddatprg,
                          mr_principal.atdhorprg,
                          mr_principal.atdhorpvt,
                          mr_principal.acntntqtd,
                          mr_principal.atdcstvlr,
                          mr_principal.atdsrvorg,
                          mr_principal.ciaempcod

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let m_erro =  "Nao encontrou os dados do servico"
     else
        let m_erro = "Erro SELECT cbdbsa068002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        display "bdbsa068_proc_srv() ",
                 mr_principal.atdsrvnum, "/",
                 mr_principal.atdsrvano
     end if
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               m_erro)
     exit program(1)
  end if

  close cbdbsa068002

  # -> INICIALIZA O ARRAY DE MULTIPLOS
  for l_resultado = 1 to 10
     let am_multiplos[l_resultado].atdmltsrvnum = null
     let am_multiplos[l_resultado].atdmltsrvano = null
     let am_multiplos[l_resultado].socntzdes    = null
     let am_multiplos[l_resultado].espdes       = null
     let am_multiplos[l_resultado].atddfttxt    = null
  end for

  # -> VERIFICA SE O SERVICO ORIGINAL POSSUI SERVICOS MULTIPLOS
  call cts29g00_obter_multiplo(2,
                               mr_principal.atdsrvnum,
                               mr_principal.atdsrvano)

       returning l_resultado,
                 l_mensagem,
                 am_multiplos[1].*,
                 am_multiplos[2].*,
                 am_multiplos[3].*,
                 am_multiplos[4].*,
                 am_multiplos[5].*,
                 am_multiplos[6].*,
                 am_multiplos[7].*,
                 am_multiplos[8].*,
                 am_multiplos[9].*,
                 am_multiplos[10].*

  # -> CHAMA A FUNCAO PARA VERIFICAR SE O SERVICO E RETORNO
  call cts40g10_verifica_retorno(mr_principal.atdsrvnum,
                                 mr_principal.atdsrvano)

       returning l_resultado,
                 l_mensagem,
                 mr_prestador.pstcoddig,
                 l_online

  if l_resultado <> 0 then
     if l_resultado <> 1 then
        let m_erro = "cts40g10_verifica_retorno() ", l_mensagem
        call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
        exit program(1)
     end if
  else
     let l_acionar = true
     let l_srv_retorno = true
  end if

  if l_acionar = false then
     call bdbsa068_ver_srv_pst(mr_principal.atdsrvnum,
                               mr_principal.atdsrvano)
          returning l_acionar, l_online, mr_prestador.pstcoddig
  end if

  if l_acionar = true then

     # -> VERIFICA SE O PRESTADOR ESTA LOGADO NA INTERNET
     if l_online = true then
        # -> O PRESTADOR ESTA LOGADO NA INTERNET

        #----------------------------------------------------------------------
        # VERIFICA SE O PRESTADOR POSSUI SERVICOS C/STATUS AGUARDANDO NO PORTAL
        #----------------------------------------------------------------------
        call cts40g16_srv_pend(mr_prestador.pstcoddig)
             returning l_resultado,
                       l_qdt_serv

        if l_resultado = 0 then
           if l_qdt_serv = 0 then  # PRESTADOR NAO TEM SERVICOS PENDENTES
              # or mr_principal.ciaempcod = 43 then # PSI 242853 Envia pela internet mesmo que pst
                                                    # possua serviços pendentes para PSS

              call cts40g18_srv_em_uso(mr_principal.atdsrvnum, #ligia 211427
                                       mr_principal.atdsrvano)
                   returning l_em_uso, l_c24opemat

              if l_c24opemat is not null and l_c24opemat <> 999999 then
                  display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                  mr_principal.atdsrvano    using "&&",
                                  " -> SENDO ACIONADO PELO RADIO."
                 exit program(1)
              end if

              # -> SETA O FLAG COMO SENDO SERVICO DE RETORNO
              # -> ESTE FLAG E UTILIZADO FUTURAMENTE PARA SETAR A ETAPA CORRETA
              if l_srv_retorno = true then
                  let m_flg_ret = true
              end if
              begin work

              # -> FUNCAO P/EXECUTAR AS TAREFAS E PROCEDIEMNTOS DO
              # -> ACIONAMENTO VIA INTERNET
              if bdbsa068_ac_internet() then
                 call bdbsa068_ver_srv_preso() returning m_commit
                 if m_commit then
                    commit work
                 else
                    rollback work
                    exit program(1)
                 end if
              else
                 rollback work
                 exit program(1)
              end if

              return 1

           end if

           return 0
        else
           let m_erro = "cts40g16_srv_pend() ", l_resultado
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano,
                                     m_erro)
           exit program(1)
        end if
     else
        # -> O PRESTADOR NAO ESTA LOGADO NA INTERNET

        # -> ENVIA O SERVICO PARA A TELA DO RADIO PARA O ACIONAMENTO MANUAL
        call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano,
                                     "PRESTADOR NAO CONECTADO NO PORTAL",
                                     1,
                                     "A")
             returning l_resultado,
                       l_mensagem

        if l_resultado <> 0 then
           let m_erro = "cts40g09_aciona_manual() ", l_mensagem
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano,
                                     m_erro)
           exit program(1)
        end if

        # -> ATUALIZA SERVICOS MULTIPLOS
        call bdbsa068_atlz_mul("PRESTADOR NAO CONECTADO NO PORTAL")

        return 2

     end if
  end if

  # -> OBTER O LOCAL DO SERVICO
  initialize mr_ctx04g00.* to null
  call ctx04g00_local_gps(mr_principal.atdsrvnum,
                          mr_principal.atdsrvano,
                          1)

       returning mr_ctx04g00.lclidttxt,
                 mr_ctx04g00.lgdtip,
                 mr_ctx04g00.lgdnom,
                 mr_ctx04g00.lgdnum,
                 mr_ctx04g00.lclbrrnom,
                 mr_ctx04g00.brrnom,
                 mr_ctx04g00.cidnom,
                 mr_ctx04g00.ufdcod,
                 mr_ctx04g00.lclrefptotxt,
                 mr_ctx04g00.endzon,
                 mr_ctx04g00.lgdcep,
                 mr_ctx04g00.lgdcepcmp,
                 mr_ctx04g00.lclltt,
                 mr_ctx04g00.lcllgt,
                 mr_ctx04g00.dddcod,
                 mr_ctx04g00.lcltelnum,
                 mr_ctx04g00.lclcttnom,
                 mr_ctx04g00.c24lclpdrcod,
                 mr_ctx04g00.celteldddcod,
                 mr_ctx04g00.celtelnum,
                 mr_ctx04g00.endcmp,
                 mr_ctx04g00.erro,
                 mr_ctx04g00.emeviacod

  if mr_ctx04g00.erro <> 0 then
     let m_erro = "ctx04g00_local_gps() ", mr_ctx04g00.erro
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               m_erro)
     exit program(1)
  end if

 # -> VERIFICA SE A LATITUDE OU LONGITUDE DO SERVICO ESTAO NULAS
  if mr_ctx04g00.lclltt is null or
     mr_ctx04g00.lcllgt is null then
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
        let m_erro = "cts40g09_aciona_manual() ", l_mensagem
        call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
        exit program(1)
     end if
     return 2
  end if

  # -> VERIFICA SE A LATITUDE OU LONGITUDE DO SERVICO ESTAO ZERADAS
  if mr_ctx04g00.lclltt = 0 or
     mr_ctx04g00.lcllgt = 0 then
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
        let m_erro = "cts40g09_aciona_manual() ", l_mensagem
        call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
        exit program(1)
     end if

     return 2
  end if

  # -> BUSCA INFORMACOES/TIPO DE ACIONAMENTO SOBRE A CIDADE DO SERVICO
  # -> Acrescentado Origem para pesquisa de Tipo de Acionamento - Jorge Modena
  call cts41g03_tipo_acion_cidade(mr_ctx04g00.cidnom,
                                  mr_ctx04g00.ufdcod,
                                  mr_cts40g00_pa.atmacnprtcod,
                                   mr_principal.atdsrvorg)#incluido origem para pesquisa de tipo de acionamento
       returning lr_cts41g03.resultado,
                 lr_cts41g03.mensagem,
                 lr_cts41g03.gpsacngrpcod,
                 lr_cts41g03.mpacidcod

  if lr_cts41g03.resultado = 2 then
     let m_erro = "cts41g03_tipo_acion_cidade() ", lr_cts41g03.mensagem
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               m_erro)
     exit program(1)
  end if

  # -> SE O CODIGO DE PADRONIZACAO DO LOCAL > 0, ENTAO O LOCAL E ATENDIDO POR GPS
  if lr_cts41g03.gpsacngrpcod > 0 then

     ## OBTEM COD DA CIDADE SEDE - PSI 202363
     call ctd01g00_obter_cidsedcod(1, lr_cts41g03.mpacidcod)
          returning l_resultado, l_mensagem, lr_cts41g03.mpacidcod

     ## OBTEM DISTANCIA PARAMETRIZADA NA CIDADE SEDE - PSI 202363
     call cts40g00_obter_distancia(mr_cts40g00_pa.atmacnprtcod,
                                   lr_cts41g03.mpacidcod)
          returning l_resultado, l_mensagem, mr_cts40g00_pa.cidacndst

     if l_resultado <> 0 then
        let m_erro= "cts40g00_obter_distancia() ",l_mensagem
        call bdbsa068_trata_erros(1, mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  m_erro)
        exit program(1)
     end if

     # -> VERIFICA SE JA E HORA DE ACIONAR O SERVICO
     call cts40g09_aciona_servico(mr_principal.atdsrvnum,
                                  mr_principal.atdsrvano,
                                  mr_principal.atddatprg,
                                  mr_principal.atdhorprg,
                                  mr_cts40g00_pa.acnlmttmp)
          returning l_ok_aciona,
                    l_qtd_acion,
                    l_mult_manual

     if l_ok_aciona then
        # -> HORA DE ACIONAR O SERVICO

        # -> VERIFICA SE EXISTE UM SERVICO P/O MESMO SEGURADO NUM PRAZO DE 48 HORAS
        call cts40g08_obter_srv_48h(mr_principal.atdsrvorg,
                                    mr_principal.atdsrvnum,
                                    mr_principal.atdsrvano,
                                    mr_ctx04g00.lclltt,
                                    mr_ctx04g00.lcllgt,
                                    mr_principal.atdhorprg,
                                    mr_ctx04g00.cidnom,
                                    mr_ctx04g00.ufdcod,
                                    "GPS")

             returning mr_veiculo.cod_motivo,
                       mr_veiculo.msg_motivo,
                       mr_veiculo.socvclcod,
                       mr_veiculo.pstcoddig,
                       mr_veiculo.srrcoddig,
                       mr_veiculo.distancia,
                       mr_veiculo.lclltt,
                       mr_veiculo.lcllgt

        if mr_veiculo.cod_motivo is not null then
           # -> EXISTE SERVICO 24h/48h E SOCORRISTA ESTA OK
           if mr_veiculo.cod_motivo = 0 then

              call cts40g18_srv_em_uso(mr_principal.atdsrvnum, #ligia 211427
                                       mr_principal.atdsrvano)
                   returning l_em_uso, l_c24opemat

              if l_c24opemat is not null and l_c24opemat <> 999999 then

                 # -> DESBLOQUEAR O VEICULO
                 let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

                 if l_resultado <> 0 then
                     let m_erro = "cts40g06_desb_veic() ", l_resultado
                     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                               mr_principal.atdsrvano,
                                               m_erro)
                     exit program(1)
                 end if

                 display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                 mr_principal.atdsrvano    using "&&",
                                 " -> SENDO ACIONADO PELO RADIO."
                exit program(1)
              end if

              begin work

              # -> CHAMA A FUNCAO PARA REALIZAR AS TAREFAS E OS PROCEDIMENTOS
              # ->  DO ACIONAMENTO DO SERVICO VIA GPS

              if bdbsa068_ac_gps() then
                 call bdbsa068_ver_srv_preso() returning m_commit
                 if m_commit then
                    commit work
                 else
                    rollback work
                    exit program(1)
                 end if
              else
                 rollback work
                 exit program(1)
              end if

              return 1

           else
              # -> EXISTE SERVICO 24/48H, MAS O SOCORRISTA NAO ESTA DISPONIVEL

               # -> ENVIA O SERVICO PARA A TELA NO RADIO PARA O ACIONAMENTO MANUAL
               call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                            mr_principal.atdsrvano,
                                            mr_veiculo.msg_motivo,
                                            1,
                                            "N")
                    returning l_resultado,
                              l_mensagem

               if l_resultado <> 0 then
                  let m_erro = "cts40g09_aciona_manual() ", l_mensagem
                  call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                            mr_principal.atdsrvano,
                                            m_erro)
                  exit program(1)
               end if

               # -> ATUALIZA SERVICOS MULTIPLOS
               call bdbsa068_atlz_mul(mr_veiculo.msg_motivo)

               return 2

           end if

        end if

        let l_proximo = false
        while true

           # -> OBTER O VEICULO PARA ATENDER O SERVICO
           initialize mr_veiculo to null

           call cts40g05_obter_veiculo(mr_ctx04g00.lclltt,
                                       mr_ctx04g00.lcllgt,
                                       mr_cts40g00_pa.cidacndst, #PSI202363
                                       lr_cts41g03.mpacidcod,    #ligia 24/10
                                       mr_ctx04g00.ufdcod,
                                       mr_principal.atdsrvnum,
                                       mr_principal.atdsrvano,
                                       mr_principal.atdhorprg,
                                       mr_principal.ciaempcod)

                returning mr_veiculo.cod_motivo,
                          mr_veiculo.msg_motivo,
                          mr_veiculo.srrcoddig,
                          mr_veiculo.socvclcod,
                          mr_veiculo.pstcoddig,
                          mr_veiculo.distancia,
                          mr_veiculo.lclltt,
                          mr_veiculo.lcllgt,
                          mr_veiculo.tempo_total,
                          l_qtd_srr_disponiveis      #PSI202363

           if mr_veiculo.cod_motivo <> 0 then

              if mr_veiculo.cod_motivo = 1 or   # -> N LOCALIZOU SOCORRISTA ADEQUADO
                 mr_veiculo.cod_motivo = 2 or   # -> N LOCALIZOU SOCORRISTA ESPECIALIZADO
                 mr_veiculo.cod_motivo = 4 or   # -> VEICULO EM RODIZIO FORA DA DISTANCIA LIMITE.
                 mr_veiculo.cod_motivo = 5 or   # -> N LOCALI. SOCOR. ESPECIA. P/SRV. MULTI.
                 mr_veiculo.cod_motivo = 6 or   # -> N LOCALI. SOCOR. ADEQUADO P/SRV. MULTI.
                 mr_veiculo.cod_motivo = 7 or # -> N LOCALI. VEIC. DISP.DENTRO LIM. PARAMETR.
                 mr_veiculo.cod_motivo = 3 or   # -> ERRO DE ACESSO A BASE DE DADOS
                 mr_veiculo.cod_motivo = 8 or   # -> PROBLEMAS NO CALCULO DA DISTANCIA"
                 mr_veiculo.cod_motivo = 14 then # -> ERRO NA ROTEIRIZACAO

                 # -> CONTABILIZAR A TENTATIVA DE ACIONAMENTO PARA O SERVICO ORIGINAL
                 call cts40g09_contab_tentativa(mr_principal.acntntqtd,
                                                mr_cts40g00_pa.acntntlmtqtd,
                                                mr_veiculo.msg_motivo,
                                                mr_principal.atdsrvnum,
                                                mr_principal.atdsrvano,
                                                mr_principal.atdsrvorg)
                      returning l_resultado,
                                l_mensagem,
                                l_ac_manual,
                                l_mult_manual

                 if l_resultado <> 0 then
                    let m_erro = "cts40g09_contab_tentativa() ", l_mensagem
                    call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano,
                                              m_erro)
                    exit program(1)
                 end if

                 # -> BUSCA O PROXIMO SERVICO
                 let l_proximo = true

                 let m_agora = current
                 display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                                                mr_principal.atdsrvano using "&&",
                                  " -> MOTIVO DO NAO ACN: ", mr_veiculo.msg_motivo

                 exit while
              else
                 let m_erro = "cts40g05_obter_veiculo() MOT: ", mr_veiculo.cod_motivo
                 call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano,
                                           m_erro)
                 exit program(1)
              end if
           else

              display "Veiculo Bloqueado >>>>> ", mr_veiculo.socvclcod
              display ""

              # -> BLOQUEIA O VEICULO
              call cts40g06_bloq_veic(mr_veiculo.socvclcod,999999)
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
                 let m_erro = "cts40g06_bloq_veic() ", l_resultado, l_bloqueou
                 call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                           mr_principal.atdsrvano,
                                           m_erro)
                 exit program(1)
              end if

           end if

        end while

        if l_proximo then
           return 0
        end if

        call cts40g18_srv_em_uso(mr_principal.atdsrvnum, #ligia 211427
                                 mr_principal.atdsrvano)
             returning l_em_uso, l_c24opemat

        if l_c24opemat is not null and l_c24opemat <> 999999 then

           # -> DESBLOQUEAR O VEICULO
           let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

           if l_resultado <> 0 then
               let m_erro = "cts40g06_desb_veic() ", l_resultado
               call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                         mr_principal.atdsrvano,
                                         m_erro)
               exit program(1)
           end if

           display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                            mr_principal.atdsrvano    using "&&",
                            " -> SENDO ACIONADO PELO RADIO."
           exit program(1)
        end if

        begin work

        # -> CHAMA A FUNCAO PARA REALIZAR AS TAREFAS E OS PROCEDIMENTOS
        # -> DO ACIONAMENTO DO SERVICO VIA GPS
        if bdbsa068_ac_gps() then
           call bdbsa068_ver_srv_preso() returning m_commit
           if m_commit then
              commit work
           else
              rollback work
              exit program(1)
           end if
        else
           rollback work
           exit program(1)
        end if

        # -> DESBLOQUEAR O VEICULO
        let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

        if l_resultado <> 0 then
           let m_erro = "cts40g06_desb_veic() ", l_resultado
           call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                     mr_principal.atdsrvano,
                                     m_erro)
            exit program(1)
        end if

        return 1
     else
        return 2
     end if
  else
     # -> ACIONAMENTO VIA INTERNET OU FAX

     # -> VERIFICA SE O ACIONAMENTO VIA INTERNET ESTA ATIVO
     if mr_cts40g00_pa.netacnflg = "A" then

        # -> VERIFICA SE EXISTE UM SERVICO P/O MESMO SEGURADO NUM
        # -> PRAZO DE 48 HORAS
        call cts40g08_obter_srv_48h(mr_principal.atdsrvorg,
                                    mr_principal.atdsrvnum,
                                    mr_principal.atdsrvano,
                                    mr_ctx04g00.lclltt,
                                    mr_ctx04g00.lcllgt,
                                    mr_principal.atdhorprg,
                                    mr_ctx04g00.cidnom,
                                    mr_ctx04g00.ufdcod,
                                    "INT")
             returning l_resultado,
                       l_exis_48h,
                       mr_prestador.pstcoddig

        if l_resultado <> 0 then
           if l_resultado <> 1 then
              let m_erro = "cts40g08_obter_srv_48h() ", l_resultado, l_exis_48h, mr_prestador.pstcoddig
              call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        m_erro)
              exit program(1)
           end if
        end if

        # -> NAO EXISTEM SERVICOS NUM PRAZO DE 48 HORAS
        # -> ENTAO, BUSCA UM PRESTADOR P/ATENDER O SERVICO
        if not l_exis_48h then

           # -> BUSCA DO PRESTADOR
           initialize mr_prestador.* to null

           call cts40g07_obter_prestador(mr_ctx04g00.lclltt,
                                         mr_ctx04g00.lcllgt,
                                         mr_principal.atdsrvnum,
                                         mr_principal.atdsrvano,
                                         mr_principal.ciaempcod)

                returning mr_prestador.cod_motivo,
                          mr_prestador.msg_motivo,
                          mr_prestador.pstcoddig

           if mr_prestador.cod_motivo <> 0 then
              if mr_prestador.cod_motivo = 12 then # -> PRESTADOR NAO CONECTADO
                 # -> ENVIA O SERVICO PARA A TELA NO RADIO PARA O ACIONAMENTO MANUAL
                 # -> E MANTEM NO ACIONAMENTO AUTOMATICO
                 call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano,
                                              mr_prestador.msg_motivo,
                                              1,
                                              "N")
                      returning l_resultado,
                                l_mensagem

                 if l_resultado <> 0 then
                    let m_erro = "cts40g09_aciona_manual() ", l_mensagem
                    call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano,
                                              m_erro)
                    exit program(1)
                 end if

                 # -> ATUALIZA SERVICOS MULTIPLOS
                 call bdbsa068_atlz_mul(mr_prestador.msg_motivo)

              else
                 if mr_prestador.cod_motivo = 7 or    # -> NAO ENCONTR. PRESTADOR DISPONIVEL
                    mr_prestador.cod_motivo = 8 or    # -> NAO LOCAL. PRESTADOR PARAMETRIZADO
                    mr_prestador.cod_motivo = 11 then # -> PRESTADOR E COMUNICADO VIA FAX

                    # -> ENVIA O SERVICO PARA A TELA NO RADIO PARA O ACIONAMENTO MANUAL
                    call cts40g09_aciona_manual (mr_principal.atdsrvnum,
                                                 mr_principal.atdsrvano,
                                                 mr_prestador.msg_motivo,
                                                 1,
                                                 "N")
                         returning l_resultado,
                                   l_mensagem

                    if l_resultado <> 0 then
                       let m_erro = "cts40g09_aciona_manual() ", l_mensagem
                       call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                                 mr_principal.atdsrvano,
                                                 m_erro)
                       exit program(1)
                    end if

                    # -> ATUALIZA SERVICOS MULTIPLOS
                    call bdbsa068_atlz_mul(mr_prestador.msg_motivo)

                 else
                    let m_erro = "cts40g07_obter_prestador()", mr_prestador.cod_motivo
                    call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                              mr_principal.atdsrvano,
                                              m_erro)
                    exit program(1)
                 end if

              end if

              return 2
           end if

        end if

        if mr_prestador.cod_motivo = 0 or
           l_exis_48h = true then

           # -> SETA O FLAG DE SERVICO DE RETORNO COMO FALSE
           let m_flg_ret = false

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
                                     mr_principal.atdsrvano    using "&&",
                                     " -> SENDO ACIONADO PELO RADIO."
                    exit program(1)
                 end if

                 begin work

                 # -> CHAMA A FUNCAO PARA REALIZAR AS TAREFAS E OS PROCEDIMENTOS
                 # -> DO ACIONAMENTO DO SERVICO VIA INTERNET
                 if bdbsa068_ac_internet() then
                    call bdbsa068_ver_srv_preso() returning m_commit
                    if m_commit then
                       commit work
                    else
                       rollback work
                       exit program(1)
                    end if
                 else
                    rollback work
                    exit program(1)
                 end if

                 return 1

              end if

              return 0
           else
              let m_erro = "Erro ref. ao prest. c/srv pendentes no Portal"
              call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                        mr_principal.atdsrvano,
                                        m_erro)
              exit program(1)
           end if
        else
           return 0
        end if
     else
        # ACIONAMENTO VIA INTERNET ESTA DESATIVADO
        return 2
     end if
  end if

end function

function bdbsa068_val_instancias()

  define lr_cts41g03   record
         resultado     smallint,
         mensagem      char(70),
         mpacidcod     like datkmpacid.mpacidcod,
         gpsacngrpcod  like datkmpacid.gpsacngrpcod
  end record

  initialize mr_ctx04g00.* to null
  initialize lr_cts41g03.* to null

  # -> OBTER A CIDADE/UF DO SERVICO
  call ctx04g00_local_gps(mr_principal.atdsrvnum,
                          mr_principal.atdsrvano,
                          1)
       returning mr_ctx04g00.lclidttxt,
                 mr_ctx04g00.lgdtip,
                 mr_ctx04g00.lgdnom,
                 mr_ctx04g00.lgdnum,
                 mr_ctx04g00.lclbrrnom,
                 mr_ctx04g00.brrnom,
                 mr_ctx04g00.cidnom,
                 mr_ctx04g00.ufdcod,
                 mr_ctx04g00.lclrefptotxt,
                 mr_ctx04g00.endzon,
                 mr_ctx04g00.lgdcep,
                 mr_ctx04g00.lgdcepcmp,
                 mr_ctx04g00.lclltt,
                 mr_ctx04g00.lcllgt,
                 mr_ctx04g00.dddcod,
                 mr_ctx04g00.lcltelnum,
                 mr_ctx04g00.lclcttnom,
                 mr_ctx04g00.c24lclpdrcod,
                 mr_ctx04g00.celteldddcod,
                 mr_ctx04g00.celtelnum,
                 mr_ctx04g00.endcmp,
                 mr_ctx04g00.erro,
                 mr_ctx04g00.emeviacod

  if mr_ctx04g00.erro <> 0 then
     let m_erro = "Erro ",mr_ctx04g00.erro," ao chamar a ctx04g00_local_gps()"
     call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                               mr_principal.atdsrvano,
                               m_erro)
     exit program(1)
  end if
 #adicionado origem para pesquisa de tipo de Acionamento
  call cts41g03_tipo_acion_cidade(mr_ctx04g00.cidnom,
                                  mr_ctx04g00.ufdcod,
                                  mr_cts40g00_pa.atmacnprtcod,
                                  mr_principal.atdsrvorg) # Jorge Modena 04/03/2013
       returning lr_cts41g03.resultado,
                 lr_cts41g03.mensagem,
                 lr_cts41g03.gpsacngrpcod,
                 lr_cts41g03.mpacidcod

  if lr_cts41g03.gpsacngrpcod = 0 then
     return true
  else
     return false
  end if

end function

function bdbsa068_ver_srv_pst(l_atdsrvnum, l_atdsrvano)

   define l_atdsrvnum  like datmservico.atdsrvnum,
          l_atdsrvano  like datmservico.atdsrvano,
          l_acionar    smallint,
          l_online     smallint

   define lr_retorno1 record
          resultado      smallint
         ,mensagem       char(60)
         ,atdsrvseq      like datmsrvacp.atdsrvseq
         end record

   define lr_retorno2 record
          resultado smallint
         ,mensagem  char(60)
         ,atdetpcod like datmsrvacp.atdetpcod
         ,pstcoddig like datmsrvacp.pstcoddig
         ,srrcoddig like datmsrvacp.srrcoddig
         ,socvclcod like datmsrvacp.socvclcod
         end record

   initialize lr_retorno1.* to null
   initialize lr_retorno2.* to null
   let l_acionar = false
   let l_online = false

   call cts10g04_max_seq(l_atdsrvnum, l_atdsrvano, 1)
        returning lr_retorno1.*

   if lr_retorno1.resultado = 1 then

      call cts10g04_ultimo_pst(l_atdsrvnum, l_atdsrvano, lr_retorno1.atdsrvseq)
           returning lr_retorno2.*

      if lr_retorno2.pstcoddig is not null and lr_retorno2.pstcoddig <> " " and
         lr_retorno2.pstcoddig <> 0  then
         # --VERIFICA SE O PRESTADOR ESTA ONLINE
         if fissc101_prestador_sessao_ativa(lr_retorno2.pstcoddig, "PSRONLINE") then
	   # or mr_principal.ciaempcod = 43 then # PSI 242853 Para serviços PSS envia
                                                 # online mesmo pst offline
            let l_online = true
            let l_acionar = true
         end if
      end if
   end if

   return l_acionar, l_online, lr_retorno2.pstcoddig

end function

function bdbsa068_val_srv()

   define l_res             smallint,
          l_msg             char(40),
          l_c24astcod       like datmligacao.c24astcod,
          l_socntzcod       like datmsrvre.socntzcod,
          l_atmacnatchorqtd like datrgrpntz.atmacnatchorqtd,
          l_espera          interval hour(6) to second,
          l_despreza        smallint

   let l_res              = null
   let l_msg              = null
   let l_c24astcod        = null
   let l_socntzcod        = null
   let l_atmacnatchorqtd  = null
   let l_espera           = null
   let l_despreza         = false

   call ctd06g00_pri_ligacao(1, mr_principal.atdsrvnum,
                                mr_principal.atdsrvano)
        returning l_res, l_msg, l_c24astcod

   if l_res = 1 then
      call ctd07g04_sel_re(1,mr_principal.atdsrvnum,
                             mr_principal.atdsrvano)
           returning l_res, l_msg, l_socntzcod

      if l_res = 1 then

         call cts12g02_param(1,mr_principal.ciaempcod,
                               l_c24astcod, l_socntzcod)
              returning l_res, l_msg, l_atmacnatchorqtd

         if l_atmacnatchorqtd is not null then
            let l_espera = cts40g03_espera(mr_principal.atddatprg,
                                           mr_principal.atdhorprg)

            let l_atmacnatchorqtd = l_atmacnatchorqtd * -1

            if l_espera < l_atmacnatchorqtd then
               let l_despreza = true
            end if

         end if

      end if

   end if

   return l_despreza

end function

#=====================================================================================
function bdbsa068_trata_erros(l_env_usuar,l_atdsrvnum, l_atdsrvano, l_msg_param)
#======================================================================================

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
         let l_erro = ctx22g00_mail_corpo("BDBSA68A", "Acionamento RE cadastro de parametrizacao", l_msg_param)
         if l_erro <> 0 then
            if l_erro <> 99 then
               display "Erro de envio de email(cx22g00)- "
            else
               display "Nao ha email cadastrado para o modulo BDBSA068 "
            end if
         end if
      end if
   else
      let l_erro = ctx22g00_mail_corpo("BDBSA068I", "Acionamento RE erro sistema", l_msg_param)
         if l_erro <> 0 then
            if l_erro <> 99 then
               display "Erro de envio de email(cx22g00)- "
            else
               display "Nao ha email cadastrado para o modulo BDBSA068 "
            end if
         end if
   end if
   
end function

######## VERIFICA SE O SERVICO ESTA PRESO PRA NAO DAR COMMIT ################
function bdbsa068_ver_srv_preso()

   define l_em_uso       smallint,
          l_c24opemat    like datmservico.c24opemat,
          l_resultado    integer

   let l_em_uso = null
   let l_c24opemat = null
   let l_resultado = null

   call cts40g18_srv_em_uso(mr_principal.atdsrvnum, mr_principal.atdsrvano)
        returning l_em_uso, l_c24opemat

   if l_c24opemat is not null and l_c24opemat <> 999999 then

      if mr_veiculo.socvclcod is not null and mr_veiculo.socvclcod <> 0 then
         # -> DESBLOQUEAR O VEICULO
         let l_resultado = cts40g06_desb_veic(mr_veiculo.socvclcod,999999)

         if l_resultado <> 0 then
             let m_erro = "cts40g06_desb_veic() ", l_resultado
             call bdbsa068_trata_erros(0, mr_principal.atdsrvnum,
                                          mr_principal.atdsrvano,
                                       m_erro)
             return false
         end if
      end if

      display m_agora, " Servico: ", mr_principal.atdsrvnum using "<<<<<<<<<&", "/",
                      mr_principal.atdsrvano    using "&&",
                      " -> SENDO SENDO USADO POR: ", l_c24opemat

      return false ## para realizar o rollback
   else
      return true ## para realizar o commit
   end if

end function

#-----------------------------------------#
function bdbsa068_envia_radio(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_atdfnlflg     char(1),
         l_acnnaomtv     like datmservico.acnnaomtv,
         l_resultado     integer,
         l_msg           char(40),
         l_indice        smallint

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
     let m_erro = "cts40g09_aciona_manual() ", l_msg
     call bdbsa068_trata_erros(0, lr_parametro.atdsrvnum, lr_parametro.atdsrvano, m_erro)
     exit program(1)
  end if

  # -> ENVIA OS SERVICOS MULTIPLOS
  for l_indice = 1 to 10
     if am_multiplos[l_indice].atdmltsrvnum is not null then

        # -> VERIFICA SE O SERVICO JA ESTA FINALIZADO(atdfnlflg="S")
        if cts40g18_srv_finalizado(am_multiplos[l_indice].atdmltsrvnum,
                                   am_multiplos[l_indice].atdmltsrvano) then
           let m_agora = current
           display m_agora, " Servico: ",
                   am_multiplos[l_indice].atdmltsrvnum using "<<<<<<<<<&", "/",
                   am_multiplos[l_indice].atdmltsrvano using "&&",
                   " -> JA CONCLUIDO!"
           continue for
        end if

        # -> VERIFICA SE O SERVICO JA FOI ACIONADO OU CANCELADO
        if cts40g18_srv(am_multiplos[l_indice].atdmltsrvnum,
                        am_multiplos[l_indice].atdmltsrvano) then
           let m_agora = current
           display m_agora, " Servico: ",
                            am_multiplos[l_indice].atdmltsrvnum
                            using "<<<<<<<<<&", "/",
                            am_multiplos[l_indice].atdmltsrvano
                            using "&&",
                            " -> JA CONCLUIDO!"
           continue for
        end if

        # --ENVIA SRV PARA A TELA DO RADIO PARA O ACIONAMENTO MANUAL
        call cts40g09_aciona_manual(am_multiplos[l_indice].atdmltsrvnum,
                                    am_multiplos[l_indice].atdmltsrvano,
                                    l_acnnaomtv,
                                    1,
                                    "N")
             returning l_resultado,
                       l_msg

        if l_resultado <> 0 then
           let m_erro = "cts40g09_aciona_manual() ", l_msg
           call bdbsa068_trata_erros
                (0, am_multiplos[l_indice].atdmltsrvnum,
                 am_multiplos[l_indice].atdmltsrvano, m_erro)

           exit program(1)
        end if

     else
        # -> NAO POSSUI SERVICOS MULTIPLOS
        exit for
     end if

  end for

  let m_agora = current
  display m_agora, " Servico: ", lr_parametro.atdsrvnum using "<<<<<<<<<&", "/",
                                 lr_parametro.atdsrvano    using "&&",
                              " -> ENVIADO PARA O RADIO <-"
  display m_agora, " Servico: ", lr_parametro.atdsrvnum using "<<<<<<<<<&", "/",
                                 lr_parametro.atdsrvano    using "&&",
                              " -> MOTIVO DO NAO ACN: ", l_acnnaomtv
  let l_atdfnlflg = "N"

  return l_atdfnlflg

end function