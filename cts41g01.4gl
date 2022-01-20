#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cts41g01.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 202363                                              #
#                Trata cotas para serviço imediato                    #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 06/09/2006                                         #
#                                                                     #
# Objetivo: Funcoes de "controle" para acionar servico RE para um     #
#           prestador já selecionado                                  #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 13/08/2009  Sergio Burini  PSI244236 Inclusão do Sub-Dairro         #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint

#-----------------------------------------------------#
function cts41g01_prepare()
#-----------------------------------------------------#
   define l_sql char(500)

   let l_sql = "select ufdcod,   ",
              "       cidnom,   ",
              "       brrnom,",
              "       endzon,   ",
              "       lclltt,   ",
              "       lcllgt    ",
              " from datmlcl    ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
   prepare p_cts41g01_001 from l_sql
   declare c_cts41g01_001 cursor for p_cts41g01_001


   let l_sql = "select atdhorpvt ",
               " from datmservico ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? "
   prepare p_cts41g01_002 from l_sql
   declare c_cts41g01_002 cursor for p_cts41g01_002

   let m_prepare = true

end function


#-----------------------------------------------------#
function cts41g01_acionaServicoImediato(param)
#-----------------------------------------------------#

   define param record
       socvclcod  like datkveiculo.socvclcod,
       atdsrvnum  like datmservico.atdsrvnum,
       atdsrvano  like datmservico.atdsrvano
   end record

   define d_servicos record
       ufdcod     like datmlcl.ufdcod,
       cidnom     like datmlcl.cidnom,
       brrnom     like datmlcl.brrnom,
       endzon     like datmlcl.endzon,
       lclltt     like datmlcl.lclltt,
       lcllgt     like datmlcl.lcllgt,
       atdhorpvt  like datmservico.atdhorpvt
   end record

   define d_veiculo record
         srrcoddig      like dattfrotalocal.srrcoddig,
         socvclcod      like datkveiculo.socvclcod,
         pstcoddig      like datkveiculo.pstcoddig,
         lclltt         like datmfrtpos.lclltt,
         lcllgt         like datmfrtpos.lcllgt
   end record

   define am_multiplos array[10] of record
         atdmltsrvnum   like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano   like datratdmltsrv.atdmltsrvano,
         socntzdes      like datksocntz.socntzdes,
         espdes         like dbskesp.espdes,
         atddfttxt      like datmservico.atddfttxt
   end record

   define l_resultado    integer,
          l_tempo_distancia integer,
          l_mensagem     char(100),
          l_ok           smallint,
          l_flgerro      char(1),
          l_aux_calc      char(06),
          l_data_atual   date,
          l_hora_atual   datetime hour to minute,
          l_distancia    decimal(8,4),
          l_tempo_total  char(6), ##decimal(6,1),
          l_tipo_rota    like datkgeral.grlinf,
          l_rota_final   char(1),
          l_previsao      like datmservico.atdprvdat

   define l_aux  smallint
   define l_funmat like isskfunc.funmat
   define l_empcod like isskfunc.empcod

   initialize d_servicos.* to null
   initialize d_veiculo.* to null
   initialize am_multiplos to null
   let l_resultado = null
   let l_mensagem = null
   let l_ok = true
   let l_flgerro = null
   let l_aux_calc = null
   let l_data_atual = null
   let l_hora_atual = null
   let l_distancia  = null
   let l_tempo_total= null
   let l_tipo_rota  = null
   let l_rota_final = null
   let l_previsao = null
   let l_aux = 0

   if m_prepare <> true then
      call cts41g01_prepare()
   end if

   #buscar dados do socorrista
   call cts40g05_obter_dados_veiculo(param.socvclcod)
        returning l_resultado,
                  d_veiculo.srrcoddig,
                  d_veiculo.pstcoddig,
                  d_veiculo.lclltt,
                  d_veiculo.lcllgt
   if l_resultado <> true then
      return false
   end if

   #busca dados da localização do servico
   open c_cts41g01_001 using param.atdsrvnum,
                           param.atdsrvano
   fetch c_cts41g01_001 into d_servicos.ufdcod,
                           d_servicos.cidnom,
                           d_servicos.brrnom,
                           d_servicos.endzon,
                           d_servicos.lclltt,
                           d_servicos.lcllgt
   if sqlca.sqlcode <> 0 then
      return false
   end if

   #buscar laudos multiplos
   call cts29g00_obter_multiplo(2,
                                param.atdsrvnum,
                                param.atdsrvano)
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

   # --CALCULA A DISTANCIA ENTRE O LOCAL DO SERVICO E O LOCAL DO VEICULO
   let l_distancia = cts18g00(d_servicos.lclltt,
                              d_servicos.lcllgt,
                              d_veiculo.lclltt,
                              d_veiculo.lcllgt)

  # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
   if ctx25g05_rota_ativa() then     #esta ativa
      # buscar tipo de rota parametrizada (rapida ou curta)
      call ctx25g05_tipo_rota()
           returning l_tipo_rota

      #calcular distancia e previsao
      call ctx25g02 (d_servicos.lclltt,
                     d_servicos.lcllgt,
                     d_veiculo.lclltt,
                     d_veiculo.lcllgt,
                     l_tipo_rota,
                     false )
           returning l_distancia,
                     l_tempo_total,
                     l_rota_final      #detalhamento da rota - como enviei false nao retorna
     let l_previsao = "00:00"
     let l_previsao = (l_previsao + l_tempo_total units minute) #ligia
   else
      #nao esta ativa
      let l_distancia = cts18g00(d_servicos.lclltt,
                                 d_servicos.lcllgt,
                                 d_veiculo.lclltt,
                                 d_veiculo.lcllgt)
      # --CALCULAR A PREVISAO DE CHEGADA
      #buscar hora previsão informada pelo atendente
      open c_cts41g01_002 using param.atdsrvnum,
                              param.atdsrvano
      fetch c_cts41g01_002 into d_servicos.atdhorpvt
      let l_aux_calc  = d_servicos.atdhorpvt
      let l_tempo_total = cts21g00_calc_prev(l_distancia, l_aux_calc)
      let l_previsao = l_tempo_total

   end if

   let l_funmat      = g_issk.funmat
   let l_empcod      = g_issk.empcod
   # Assume matricula do ACN AUTOMATICO para acionar automaticamente pelo laudo
   let g_issk.funmat = 999999
   let g_issk.empcod = 1
   begin work
   while true
       #chamar cts33g01 para servico original
       let l_resultado = cts33g01_alt_dados_automat(d_veiculo.pstcoddig,
                                                    param.socvclcod,
                                                    d_veiculo.srrcoddig,
                                                    "",
                                                    g_issk.funmat,
                                                    "", #atdcstvlr,
                                                    d_veiculo.lclltt,
                                                    d_veiculo.lcllgt,
                                                    l_previsao,
                                                    1, ##"",  #acntntqtd #ligia
                                                    param.atdsrvnum,
                                                    param.atdsrvano)
       if l_resultado <> 0 then
          let l_ok = false
          exit while
       end if

       #para cada laudo multiplo, chamar cts33g01 para laudos multiplos
       # estou passando nulo em atdcstvlr, pois qdo gero o servico gravo nulo
       # -- campo nao utilizado
       for l_aux = 1 to 10
          if am_multiplos[l_aux].atdmltsrvnum is not null then
            let l_resultado = cts33g01_alt_dados_automat(d_veiculo.pstcoddig,
                                                         param.socvclcod,
                                                         d_veiculo.srrcoddig,
                                                         "",
                                                         g_issk.funmat,
                                                         "", #atdcstvlr
                                                         d_veiculo.lclltt,
                                                         d_veiculo.lcllgt,
                                                         l_previsao,
                                                         1, ##"",  #acntntqtd
                                                         am_multiplos[l_aux].atdmltsrvnum,
                                                         am_multiplos[l_aux].atdmltsrvano)
             if l_resultado <> 0 then
                let l_ok = false
                exit for
             end if
          else
             # --NAO POSSUI SERVICOS MULTIPLOS
             exit for
          end if
       end for

       if l_ok = false then
          exit while
       end if

       # --INSERIR ETAPA
       let l_resultado = cts40g22_insere_etapa(param.atdsrvnum,
                                               param.atdsrvano,
                                               3,
                                               d_veiculo.pstcoddig,
                                               "",
                                               param.socvclcod,
                                               d_veiculo.srrcoddig)

       if l_resultado <> 0 then
          display "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
          let l_ok = false
          exit while
       end if

       ####PSI 214558
       let     l_tempo_distancia  =  null
       call cts10g04_tempo_distancia(param.atdsrvnum,
                                     param.atdsrvano,
                                     3,
                                     l_distancia)
         returning l_tempo_distancia

       if l_tempo_distancia <> 0 then
           display "Erro: (", l_tempo_distancia, ") ao chamar a funcao cts10g04_tempo_distancia()"
           rollback work
       end if
       ####
       call cts10g04_atualiza_dados(param.atdsrvnum,
                                    param.atdsrvano,
                                    "",
                                    1)
            returning l_mensagem,
                      l_resultado
       if l_resultado <> 1 then
          display "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
          display l_mensagem
          let l_ok = false
          exit while
       end if

       # --INSERIR A ETAPA PARA OS SERVICOS MULTIPLOS
       for l_aux = 1 to 10
          if am_multiplos[l_aux].atdmltsrvnum is not null then
             # --REGISTRAR PRESTADOR PARA CADA SERVICO MULTIPLO
             let l_resultado = cts40g22_insere_etapa(am_multiplos[l_aux].atdmltsrvnum,
                                                     am_multiplos[l_aux].atdmltsrvano,
                                                     3,
                                                     d_veiculo.pstcoddig,
                                                     "",
                                                     param.socvclcod,
                                                     d_veiculo.srrcoddig)
             if l_resultado <> 0 then
                display "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
                let l_ok = false
                exit for
             end if
             ####PSI 214558
             let     l_tempo_distancia  =  null
             call cts10g04_tempo_distancia(param.atdsrvnum,
                                           param.atdsrvano,
                                           3,
                                           l_distancia)
               returning l_tempo_distancia

             if l_tempo_distancia <> 0 then
                 display "Erro: (", l_tempo_distancia, ") ao chamar a funcao cts10g04_tempo_distancia()"
                 rollback work
             end if
             ####

             call cts10g04_atualiza_dados(am_multiplos[l_aux].atdmltsrvnum,
                                          am_multiplos[l_aux].atdmltsrvano,
                                          "",
                                          1)
                  returning l_mensagem,
                            l_resultado
              if l_resultado <> 1 then
                 display "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
                 display l_mensagem
                 let l_ok = false
                 exit for
              end if
          else
             # --NAO POSSUI SERVICOS MULTIPLOS
             exit for
          end if
       end for
       if l_ok = false then
          exit while
       end if

       let l_flgerro = cts00g02_env_msg_mdt(2,
                                       param.atdsrvnum,
                                       param.atdsrvano,
                                       "",
                                       param.socvclcod)

       if l_flgerro = "S" then
          display "Erro ao chamar a funcao cts00g02_env_msg_mdt()"
          let l_ok = false
          exit while
       else
          # --ENVIO DA REFERENCIA DO ENDERECO VIA TELETRIM
          call cts00g04_msgsrv(param.atdsrvnum,
                               param.atdsrvano,
                               param.socvclcod,
                               " ",
                               " ",
                               "SRV",
                               "B")
       end if

       # --BUSCAR A DATA E HORA DO BANCO
       call cts40g03_data_hora_banco(2)
            returning l_data_atual, l_hora_atual

       # --CARREGA DADOS DO SERVICO P/POSICAO DA FROTA
       let l_resultado = cts33g01_posfrota(param.socvclcod,
                                           "N",
                                            d_servicos.ufdcod,
                                            d_servicos.cidnom,
                                            d_servicos.brrnom,
                                            d_servicos.endzon,
                                            d_servicos.lclltt,
                                            d_servicos.lcllgt,
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            l_data_atual,
                                            l_hora_atual,
                                            "QRU",
                                            param.atdsrvnum,
                                            param.atdsrvano)
       if l_resultado <> 0 then
         let l_ok = false
         exit while
       end if

      #desbloquear veiculo
      call cts40g06_desb_veic (param.socvclcod,999997)
           returning l_resultado

      if l_resultado <> 0 then
         let l_ok = false
         exit while
       end if

       exit while

   end while

   let g_issk.funmat = l_funmat
   let g_issk.empcod = l_empcod
   if l_ok = true then
      commit work
      return true
   else
      rollback work
      return false
   end if

end function

