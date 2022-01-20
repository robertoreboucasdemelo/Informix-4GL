#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G05                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MODULO RESPO. POR RETORNAR O VEICULO MAIS PROXIMO DA OCOR- #
#                  RENCIA DO SERVICO.                                         #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 04/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 29/08/2006 Priscila        PSI202363  Buscar a quantidade de veículos que   #
#                                       podem atender ao servico no momento do#
#                                       preenchimento do laudo                #
# 12/01/2010 Kevellin        PSI 251712 Gerenciamento da Frota Extra          #
# 27/04/2010 Adriano Santos  PSI 242853 Busca veic do prestador etapa liberada#
#-----------------------------------------------------------------------------#

#database porto
globals '/homedsa/projetos/geral/globals/glct.4gl'

  define m_cts40g05_prep smallint

  define am_veiculos     array[1000] of record
         srrcoddig       like dattfrotalocal.srrcoddig,
         socvclcod       like datkveiculo.socvclcod,
         pstcoddig       like datkveiculo.pstcoddig,
         lclltt          like datmfrtpos.lclltt,
         lcllgt          like datmfrtpos.lcllgt,
         atldat          like datmfrtpos.atldat,
         atlhor          like datmfrtpos.atlhor,
         vcllicnum       like datkveiculo.vcllicnum,
         distancia       decimal(8,4)
  end record

#-------------------------#
function cts40g05_prepare()
#-------------------------#

  define l_sql char(600)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  #let l_sql = " select a.srrcoddig, ",  # PSI 242853
  #                   " b.socvclcod, ",
  #                   " b.pstcoddig, ",
  #                   " c.lclltt, ",
  #                   " c.lcllgt, ",
  #                   " c.atldat, ",
  #                   " c.atlhor, ",
  #                   " b.vcllicnum, ",
  #                   " b.mdtcod ",
  #              " from dattfrotalocal a, ",
  #                   " datkveiculo b, ",
  #                   " datmfrtpos c, ",
  #                   " datrvclemp d, ",
  #                   " datkmdt e",
  #             " where a.socvclcod = b.socvclcod ",
  #               " and a.c24atvcod = 'QRV' ",
  #               " and b.socoprsitcod = '1' ",
  #               " and b.socacsflg = '0' ",
  #               " and c.socvclcod = a.socvclcod ",
  #               " and c.socvcllcltip = '1' ",
  #               " and b.socvclcod = d.socvclcod ",
  #               " and e.mdtcod = b.mdtcod ",
  #               " and e.mdtstt = 0 ",
  #               " and d.ciaempcod = ? ",
  #               " and c.lclltt is not null ",
  #               " and c.lcllgt is not null "
  #
  #prepare pcts40g05001 from l_sql
  #declare ccts40g05001 cursor for pcts40g05001

  let l_sql = " select socntzcod, ",
                     " espcod ",
                " from dbsrntzpstesp ",
               " where srrcoddig = ? "

  prepare p_cts40g05_001 from l_sql
  declare c_cts40g05_001 cursor for p_cts40g05_001

  let l_sql = " select rdzlcldst, ",
                     " rdzsttflg, ",
                     " vclrdzinchor, ",
                     " vclrdzfnlhor ",
                " from datkvclrdzprt ",
               " where cidcod = ? ",
                 " and vclplcfnlnum = ? ",
                 " and rdzsmndianum = ? ",
               " and ((vclrdzinchor <= ? and vclrdzfnlhor >= ?) or ",
                    " (vclrdzinchor <= ? and vclrdzfnlhor >= ?)) "

  prepare p_cts40g05_002 from l_sql
  declare c_cts40g05_002 cursor for p_cts40g05_002

  let l_sql = " select a.srrcoddig, ",
                     " b.pstcoddig, ",
                     " c.lclltt, ",
                     " c.lcllgt  ",
                     " from dattfrotalocal a, ",
                     " datkveiculo b, ",
                     " datmfrtpos c ",
               " where a.socvclcod = ? ",
                 " and a.socvclcod = b.socvclcod ",
                 " and c.socvclcod = a.socvclcod "
  prepare p_cts40g05_003 from l_sql
  declare c_cts40g05_003 cursor for p_cts40g05_003

  #PSI 251712 - FROTEX
  #VERIFICA SE VEÍCULO TEM O EQUIPAMENTO FROTEX INSTALADO
  let l_sql = ' select socvclcod ',
                ' from datreqpvcl ',
               ' where socvclcod = ? ',
                 ' and soceqpcod = 72 '
  prepare p_cts40g05_004 from l_sql
  declare c_cts40g05_004 cursor for p_cts40g05_004

  #PSI 251712 - FROTEX
  #VERIFICA SE FROTEX ESTÁ ATIVADO
  let l_sql = " select grlinf ",
                   " from datkgeral ",
                  " where grlchv = 'GER_FROTEX' "

  prepare p_cts40g05_005 from l_sql
  declare c_cts40g05_005 cursor for p_cts40g05_005


  let m_cts40g05_prep = true

end function

#-------------------------------------------#
function cts40g05_obter_veiculo(lr_parametro)
#-------------------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,          # --LATITUDE DO SERVCIO
         lcllgt       like datmlcl.lcllgt,          # --LONGITUDE DO SERVICO
         cidacndst    like datracncid.cidacndst, # --DISTANCIA LIMITE PARAMETRIZADA
         cidcod       like glakcid.cidcod,          # --NOME DA CIDADE
         ufdcod       like glakcid.ufdcod,          # --CODIGO DO ESTADO DA CIDADE
         atdsrvnum    like datmservico.atdsrvnum,   # --NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano,   # --ANO DO SERVICO
         atdhorprg    like datmservico.atdhorprg,   # --HORA PROGRAMADA DO SERVICO
         ciaempcod    like datmservico.ciaempcod    # --EMPRESA
  end record

  define lr_analise   record
         cod_motivo   smallint,
         msg_motivo   like datmservico.acnnaomtv,
         srrcoddig    like dattfrotalocal.srrcoddig,
         socvclcod    like datkveiculo.socvclcod,
         pstcoddig    like datkveiculo.pstcoddig,
         distancia    decimal(8,4),
         lclltt       like datmfrtpos.lclltt,
         lcllgt       like datmfrtpos.lcllgt
  end record
  define lr_cts10g04 record
     resultado smallint
    ,mensagem  char(60)
    ,atdetpcod like datmsrvacp.atdetpcod
    ,pstcoddig like datmsrvacp.pstcoddig
    ,srrcoddig like datmsrvacp.srrcoddig
    ,socvclcod like datmsrvacp.socvclcod
  end record

  define l_contador    integer,
         l_distancia   decimal(8,4),
         l_tempo_total decimal(6,1),
         l_msg         char(200),
         l_flg_erro    char(01),
         l_limite      interval hour(6) to minute,
         l_espera      interval hour(6) to minute,
         l_resultado   smallint,
         ##l_cidcod      like glakcid.cidcod,
         l_qtd_srr_possiveis  smallint,            #PSI202363
         l_mdtcod      like datkveiculo.mdtcod,
         l_data_atual  date,
         l_hora_atual  datetime hour to minute,
         l_limpa       smallint,
         l_socvclcod_frotex decimal(6,0),
         l_grlinf_frotex like datkgeral.grlinf,
         l_sql char(600)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let l_contador  =  null
        let l_distancia  =  null
        let l_msg  =  null
        let l_flg_erro  =  null
        let l_limite  =  null
        let l_espera  =  null
        let l_tempo_total = null
        let l_resultado = null
        let l_mdtcod = null
        let l_limpa = null
        let l_qtd_srr_possiveis = 0      #PSI202363
        let l_socvclcod_frotex = null
        let l_grlinf_frotex = null
        let l_sql = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_analise.*  to  null

  set isolation to dirty read

  if m_cts40g05_prep is null or
     m_cts40g05_prep <> true then
     call cts40g05_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize am_veiculos to null

  let l_data_atual  =  null
  let l_hora_atual  =  null

  # --BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual, l_hora_atual

  let l_limite    = "0:20"
  let l_contador  = 1

  call cts10g04_ultimo_pst(g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           1)
      returning lr_cts10g04.resultado,
                lr_cts10g04.mensagem ,
                lr_cts10g04.atdetpcod,
                lr_cts10g04.pstcoddig,
                lr_cts10g04.srrcoddig,
                lr_cts10g04.socvclcod
  let l_sql = " select a.srrcoddig, ", # PSI 242853
                     " b.socvclcod, ",
                     " b.pstcoddig, ",
                     " c.lclltt, ",
                     " c.lcllgt, ",
                     " c.atldat, ",
                     " c.atlhor, ",
                     " b.vcllicnum, ",
                     " b.mdtcod ",
                " from dattfrotalocal a, ",
                     " datkveiculo b, ",
                     " datmfrtpos c, ",
                     " datrvclemp d, ",
                     " datkmdt e",
               " where a.socvclcod = b.socvclcod ",
                 " and a.c24atvcod = 'QRV' ",
                 " and b.socoprsitcod = '1' ",
                 " and b.socacsflg = '0' ",
                 " and c.socvclcod = a.socvclcod ",
                 " and c.socvcllcltip = '1' ",
                 " and b.socvclcod = d.socvclcod ",
                 " and e.mdtcod = b.mdtcod ",
                 " and e.mdtstt = 0 ",
                 " and d.ciaempcod = ? ",
                 " and c.lclltt is not null ",
                 " and c.lcllgt is not null "

  if lr_cts10g04.atdetpcod is not null and  # PSI 242853
     lr_cts10g04.atdetpcod <> " " and
     lr_cts10g04.atdetpcod <> 0 then
     let l_sql = l_sql, " and pstcoddig = ", lr_cts10g04.atdetpcod
  end if
  prepare pcts40g05001 from l_sql
  declare ccts40g05001 cursor for pcts40g05001
  open ccts40g05001 using lr_parametro.ciaempcod
  # --BUSCA OS VEICULOS DISPONIVEIS P/ATENDER O SERVICO
  foreach ccts40g05001 into am_veiculos[l_contador].srrcoddig,
                            am_veiculos[l_contador].socvclcod,
                            am_veiculos[l_contador].pstcoddig,
                            am_veiculos[l_contador].lclltt,
                            am_veiculos[l_contador].lcllgt,
                            am_veiculos[l_contador].atldat,
                            am_veiculos[l_contador].atlhor,
                            am_veiculos[l_contador].vcllicnum,
                            l_mdtcod

     #PSI 251712 - VERIFICA SE VEÍCULO FAZ PARTE DA FROTA EXTRA
     #SE SIM E FROTEX ATIVADO, VEÍCULO NÃO RECEBE SERVIÇOS RE
     let l_socvclcod_frotex = 0
     initialize l_grlinf_frotex to null

     open c_cts40g05_004 using am_veiculos[l_contador].socvclcod
     fetch c_cts40g05_004 into l_socvclcod_frotex

     if sqlca.sqlcode = 0 then

        #VEÍCULO POSSUI EQUIPAMENTO FROTEX
        if l_socvclcod_frotex <> 0 and l_socvclcod_frotex is not null then

           #VERIFICA SE FROTEX ESTÁ ATIVADO
           open c_cts40g05_005
           fetch c_cts40g05_005 into l_grlinf_frotex

           if sqlca.sqlcode = 0 then

               #SE FROTEX ATIVADO, VEÍCULO NÃO PODE RECEBER SERVIÇO RE
               if l_grlinf_frotex == 'S' then

                   #display "VEICULO ", am_veiculos[l_contador].socvclcod, " NAO PODE SER ACIONADO, FROTEX ATIVO "

                   close c_cts40g05_004
                   close c_cts40g05_005
                   continue foreach
               end if

           end if

           close c_cts40g05_005

         end if

     end if

     close c_cts40g05_004

     # --VERIFICA SE A LATITUDE OU LONGITUDE ESTAO NULAS/ZERADAS
     if am_veiculos[l_contador].lclltt is null or
        am_veiculos[l_contador].lclltt =  0    or
        am_veiculos[l_contador].lcllgt is null or
        am_veiculos[l_contador].lcllgt =  0    then

        continue foreach

     end if

     # --CALCULA A DISTANCIA ENTRE O LOCAL DO SERVICO E O LOCAL DO VEICULO
     let l_distancia = cts18g00(lr_parametro.lclltt,
                                lr_parametro.lcllgt,
                                am_veiculos[l_contador].lclltt,
                                am_veiculos[l_contador].lcllgt)

     if l_distancia is null or l_distancia <= 0 then
        continue foreach
     end if

     # --VERIFICA SE O VEICULO ESTA DENTRO DO LIMITE PARAMETRIZADO
     if l_distancia > lr_parametro.cidacndst then
        # --SE NAO ESTIVER, DESPREZA O VEICULO
        continue foreach
     else
        let am_veiculos[l_contador].distancia = l_distancia
     end if

     #----------------------------------------------------------
     # VERIFICA SE O VEICULO ESTA SEM SINAL A MAIS DE 20 MINUTOS
     #----------------------------------------------------------
     let l_espera = null
     let l_espera = cts40g03_espera(am_veiculos[l_contador].atldat,
                                    am_veiculos[l_contador].atlhor)

     if l_espera is null or
        l_espera > l_limite then # VEICULO SEM SINAL A MAIS DE 20 MINUTOS
        continue foreach # DESPREZA
     end if

     # --VERIFICA O MDT DO VEICULO
     let l_flg_erro = cts00g03_checa_mdt(3,am_veiculos[l_contador].socvclcod)

     if l_flg_erro = "S" then
        # --SE O MDT ESTIVER COM PROBLEMAS DESPREZA O VEICULO
        continue foreach
     end if

     # --VERIFICA OS SINAIS DO VEICULO
     let l_flg_erro = cts00g06_checa_sinal(l_mdtcod, l_data_atual)

     if l_flg_erro = "N" then
        continue foreach
     end if

     let l_contador = l_contador + 1

     if l_contador > 1000 then
        let l_msg = "A quantidade de registros superou o limite do array ! Modulo CTS40G05.4GL"
        call errorlog(l_msg)
        exit foreach
     end if

  end foreach

  close ccts40g05001

  ## inicializar com nulo a ultima linha # ligia 10/04/07
  initialize am_veiculos[l_contador].* to null

  let l_contador = l_contador - 1

  # --NAO ENCONTROU NENHUM VEICULO DENTRO DO LIMITE
  if l_contador = 0 then
     let lr_analise.cod_motivo = 7
  else
     #PSI202363
     #caso nao tenha numero de servico é pq esta procurando por um
     # socorrista no momento em que o laudo está sendo preenchido

     if lr_parametro.atdsrvnum is null and
        lr_parametro.atdsrvano is null then

        #preciso ordenar os veiculos encontrados por causa da roteirização
        call cts40g05_ordena_array(l_contador)

        #funcao para buscar a quantidade de socorristas q poderiam atender
        # o servico e o mais próximo, que será a viatura que atenderá o servico
        # caso o atendente informe que usuário deseja serviço imediato
        call cts40g05_busca_qtde_veiculos(lr_parametro.cidcod,
                                          lr_parametro.ufdcod,
                                          lr_parametro.atdhorprg,
                                          lr_parametro.lclltt,
                                          lr_parametro.lcllgt,
                                          lr_parametro.cidacndst )
             returning lr_analise.cod_motivo,
                       lr_analise.srrcoddig,
                       lr_analise.socvclcod,
                       lr_analise.pstcoddig,
                       lr_analise.distancia,
                       lr_analise.lclltt,
                       lr_analise.lcllgt,
                       l_tempo_total,
                       l_qtd_srr_possiveis

     else
         call cts40g05_ordena_array(l_contador)

         call cts40g05_analisa_veiculos(l_contador,
                                        lr_parametro.cidcod,
                                        lr_parametro.ufdcod,
                                        lr_parametro.atdsrvnum,
                                        lr_parametro.atdsrvano,
                                        lr_parametro.atdhorprg,
                                        lr_parametro.lclltt,
                                        lr_parametro.lcllgt,
                                        lr_parametro.cidacndst)

              returning lr_analise.cod_motivo,
                        lr_analise.srrcoddig,
                        lr_analise.socvclcod,
                        lr_analise.pstcoddig,
                        lr_analise.distancia,
                        lr_analise.lclltt,
                        lr_analise.lcllgt,
                        l_tempo_total

     end if    #PSI202363

     # --SE NAO ENCONTROU NENHUM SOCORRISTA, NAO DEVOLVE DADOS REFERENTE AO VEICULO
     if lr_analise.cod_motivo <> 0 then
        let lr_analise.srrcoddig = null
        let lr_analise.socvclcod = null
        let lr_analise.pstcoddig = null
        let lr_analise.distancia = null
        let lr_analise.lclltt    = null
        let lr_analise.lcllgt    = null
        let l_tempo_total        = null
     end if

  end if

  # --OBTER A MENSAGEM REFERENTE AO CODIGO DO MOTIVO
  let lr_analise.msg_motivo = cts40g05_obter_msg_motivo(lr_analise.cod_motivo)

  return lr_analise.cod_motivo,
         lr_analise.msg_motivo,
         lr_analise.srrcoddig,
         lr_analise.socvclcod,
         lr_analise.pstcoddig,
         lr_analise.distancia,
         lr_analise.lclltt,
         lr_analise.lcllgt,
         l_tempo_total,
         l_qtd_srr_possiveis            #PSI202363

end function

#----------------------------------------------#
function cts40g05_obter_msg_motivo(l_cod_motivo)
#----------------------------------------------#

  define l_cod_motivo smallint,
         l_msg_motivo like datmservico.acnnaomtv


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg_motivo  =  null

  case l_cod_motivo

     when 0
        let l_msg_motivo = null

     when 1
        let l_msg_motivo = "NAO LOCALIZOU SOCORRISTA ADEQUADO."

     when 2
        let l_msg_motivo = "NAO LOCALIZOU SOCORRISTA ESPECIALIZADO."

     when 3
        let l_msg_motivo = "ERRO DE ACESSO A BASE DE DADOS."

     when 4
        let l_msg_motivo = "VEIC. EM RODIZIO FORA DA DISTAN. LIMITE."

     when 5
        let l_msg_motivo = "NAO LOCALIZ. SOCOR. ESPECI. P/SRV. MULT."

     when 6
        let l_msg_motivo = "NAO LOCALIZ. SOCOR. ADEQ. P/SRV. MULTIP."

     when 7
        let l_msg_motivo = "NAO LOCALI. VEIC. DISP. LIMITE PARAMETR."

     when 8
        let l_msg_motivo = "PROBLEMAS NO CALCULO DA DISTANCIA"
     when 14
        let l_msg_motivo = "ERRO NA ROTEIRIZACAO."

  end case

  return l_msg_motivo

end function

#----------------------------------------------#
function cts40g05_analisa_veiculos(lr_parametro)
#----------------------------------------------#

  define lr_parametro    record
         tamanho         smallint,
         cidcod          like glakcid.cidcod,
         ufdcod          like glakcid.ufdcod,
         atdsrvnum       like datmservico.atdsrvnum,
         atdsrvano       like datmservico.atdsrvano,
         atdhorprg       like datmservico.atdhorprg,
         lclltt_srv      like datmlcl.lclltt,
         lcllgt_srv      like datmlcl.lcllgt,
         cidacndst       like datracncid.cidacndst # --DISTANCIA LIMITE PARAMETRIZADA
  end record

  define l_contador        smallint,
         l_rodizio         smallint,
         l_msg             char(80),
         l_mensagem        char(100),
         l_tempo_total     decimal(6,1),
         l_fator           decimal(4,2),
         l_resultado       smallint,
         l_cod_motivo      smallint,
         l_achou_socorrista smallint,
         l_atende          smallint,
         l_roter_ativa     smallint,
         l_roter_qtd       smallint,
         l_roter_arr       smallint,
         l_roter_xml_veic  char(32000),
         ##l_cidcod          like glakcid.cidcod,
         l_orig_socntzcod  like datmsrvre.socntzcod,
         l_orig_espcod     like datmsrvre.espcod,
         l_distancia       dec(8,4)

  # --INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_contador  =  null
        let     l_rodizio  =  null
        let     l_msg  =  null
        let     l_mensagem  =  null
        let     l_resultado  =  null
        let     l_cod_motivo  =  null
        let     l_atende  =  null
       ## let     l_cidcod  =  null
        let     l_orig_socntzcod  =  null
        let     l_orig_espcod  =  null
        let     l_roter_ativa   = null
        let     l_roter_qtd     = null
        let     l_tempo_total   = null
        let     l_fator         = null
        let     l_roter_xml_veic     = '<VEICULOS>'
        let     l_distancia     = null
        let     l_achou_socorrista = 0

  let l_contador   = 1
  let l_cod_motivo = 0
  let l_roter_arr  = 0

  # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
  let l_roter_ativa = ctx25g05_rota_ativa()

  if lr_parametro.ufdcod <> "RJ" and
     lr_parametro.ufdcod <> "SP" and
     lr_parametro.ufdcod <> "PR" then
     let l_roter_ativa = false
  end if

  # -> BUSCA A QTD DE ROTAS PARAMETRIZDA
  let l_roter_qtd   = ctx25g05_qtde_rotas_ac()

  if l_roter_qtd > 10 then
     let l_roter_qtd = 10 # -> QTD. LIMITE DE VEICULOS A SEREM ROTERIZADOS
  end if

  # --OBTER CODIGO DA NATUREZA E O CODIGO DA ESPECIALIDADE DO SERVICO ORIGINAL (datmsrvre)
  call cts40g01_obter_codnat_codesp(lr_parametro.atdsrvnum,
                                    lr_parametro.atdsrvano)

       returning l_resultado,
                 l_mensagem,
                 l_orig_socntzcod,
                 l_orig_espcod

  if l_resultado <> 0 then
     if l_resultado <> 1 then
        let l_msg = "Erro na funcao cts40g01_obter_codnat_codesp()"
        call errorlog(l_msg)
        call errorlog(l_mensagem)
        let l_cod_motivo = 3
        initialize am_veiculos to null
     end if
  end if

  if l_cod_motivo = 0 then

     for l_contador = 1 to lr_parametro.tamanho
        let l_cod_motivo = cts40g05_verifica_naturezas(am_veiculos[l_contador].srrcoddig,
                                                       lr_parametro.atdsrvnum,
                                                       lr_parametro.atdsrvano,
                                                       l_orig_espcod,
                                                       l_orig_socntzcod)

        # --VERIFICA SE OCORREU ERRO DE ACESSO AO BANCO
        if l_cod_motivo = 3 then
           exit for
        end if

        # --SE O SOCORRISTA NAO ATENDEU, BUSCA O PROXIMO
        if l_cod_motivo = 1 or    # --NAO LOCALIZOU SOCORRISTA ADEQUADO
           l_cod_motivo = 2 or    # --NAO LOCALIZOU SOCORRISTA ESPECIALIZADO
           l_cod_motivo = 5 or    # --NAO LOCALIZOU SOCORRISTA ESPECIALIZADO P/SRV. MULTIPLO
           l_cod_motivo = 6 then  # --NAO LOCALIZOU SOCORRISTA ADEQUADO P/SRV. MULTIPLO
           continue for
        else

           # --SE ENCONTROU VEICULO, VERIFICA A SITUACAO DO RODIZIO
           call cts40g05_verifica_rodizio(lr_parametro.cidcod,
                                          am_veiculos[l_contador].vcllicnum,
                                          am_veiculos[l_contador].distancia,
                                          lr_parametro.atdhorprg)

                returning l_resultado, l_rodizio

           if l_resultado <> 0 then
              let l_cod_motivo = 3 # --ERRO DE ACESSO AO BANCO DE DADOS
              exit for
           else
              if not l_rodizio then
                 # --ENCONTROU SOCORRISTA
                 let l_cod_motivo = 0
                 let l_achou_socorrista  = 1 # achei socorrista s/rodizio

                 if l_roter_ativa then
                    # -> VERIFICA O LIMITE DE ROTAS PARA O ACIONAMENTO
                    if l_roter_arr <= l_roter_qtd then
                       let l_roter_arr = (l_roter_arr + 1)

                       # -> MONTA O XML DE REQUEST DOS VEICULOS
                       let l_roter_xml_veic =  l_roter_xml_veic clipped,
                                               '<VEICULO>',
                                               '<ID>', l_contador using "<<<<&", '</ID>',
                                                  '<COORDENADAS>',
                                                     '<TIPO>WGS84</TIPO>',
                                                     '<X>',
                                                     am_veiculos[l_contador].lcllgt,
                                                     '</X>',
                                                     '<Y>',
                                                     am_veiculos[l_contador].lclltt,
                                                     '</Y>',
                                                  '</COORDENADAS>',
                                               '</VEICULO>'
                       continue for
                    else
                       exit for
                    end if
                 else
                    exit for
                 end if

              else
                 # --VEICULO EM RODIZIO FORA DA DISTANCIA LIMITE.
                 let l_cod_motivo = 4
                 continue for
              end if
           end if

        end if

     end for

  end if

  ## se achou algum socorrista adequado manter cod_motivo = 0
  if l_achou_socorrista = 1 then
     let l_cod_motivo = 0
  end if

  # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
  if l_roter_ativa then
     if l_roter_arr <> 0 then # ENCONTROU VEICULO
        let l_roter_xml_veic = l_roter_xml_veic clipped, '</VEICULOS>'

        call ctx25g06(lr_parametro.lclltt_srv,
                      lr_parametro.lcllgt_srv,
                      l_roter_xml_veic)

             returning l_contador,
                       l_distancia,
                       ##am_veiculos[l_contador].distancia,
                       l_tempo_total

        if l_contador is null or l_contador = 0 then #ligia 19/12
           return 14, '','','','','','',''
        else
           let am_veiculos[l_contador].distancia = l_distancia
        end if

        if am_veiculos[l_contador].distancia <= 0 then

           let l_msg = "cts40g05 -> distancia roteirizada <= 0 : ", am_veiculos[l_contador].distancia, ' para veiculo ',  am_veiculos[l_contador].socvclcod
           call errorlog(l_msg)


           return 8, ##############l_codigo_motivo,
                  am_veiculos[l_contador].srrcoddig,
                  am_veiculos[l_contador].socvclcod,
                  am_veiculos[l_contador].pstcoddig,
                  am_veiculos[l_contador].distancia,
                  am_veiculos[l_contador].lclltt,
                  am_veiculos[l_contador].lcllgt,
                  l_tempo_total
        end if

        # -> BUSCA O FATOR MAXIMO DE DESVIO DA DISTANCIA EM LINHA RETA P/ROTERIZADA
        let l_fator = ctx25g05_fator_desvio()

        if (am_veiculos[l_contador].distancia > (lr_parametro.cidacndst * l_fator)) then
           let l_cod_motivo = 7
        end if

     end if
  end if

  return l_cod_motivo,
         am_veiculos[l_contador].srrcoddig,
         am_veiculos[l_contador].socvclcod,
         am_veiculos[l_contador].pstcoddig,
         am_veiculos[l_contador].distancia,
         am_veiculos[l_contador].lclltt,
         am_veiculos[l_contador].lcllgt,
         l_tempo_total

end function

#------------------------------------------------#
function cts40g05_verifica_naturezas(lr_parametro)
#------------------------------------------------#

  define lr_parametro     record
         srrcoddig        like dattfrotalocal.srrcoddig,
         atdsrvnum        like datmservico.atdsrvnum,
         atdsrvano        like datmservico.atdsrvano,
         espcod           like datmsrvre.espcod,
         socntzcod        like datmsrvre.socntzcod
  end record

  define al_multiplos     array[10] of record
         atdmltsrvnum     like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano     like datratdmltsrv.atdmltsrvano,
         socntzdes        like datksocntz.socntzdes,
         espdes           like dbskesp.espdes,
         atddfttxt        like datmservico.atddfttxt
  end record

  define al_naturezas     array[10] of record
         espcod           like datmsrvre.socntzcod,
         socntzcod        like datmsrvre.espcod
  end record

  define l_socntzcod      like datmsrvre.socntzcod,
         l_espcod         like datmsrvre.espcod,
         l_cod_motivo     smallint,
         l_indice         smallint,
         l_resultado      smallint,
         l_mensagem       char(80),
         l_msg            char(80)

  # --DESCRICAO DOS CODIGOS DE MOTIVO

     # 0 - Socorrista encontrado.
     # 1 - Nao localizou socorrista adequado.
     # 2 - Nao localizou socorrista especializado.
     # 3 - Erro de acesso a base de dados.
     # 4 - veiculo em rodizio fora da distancia limite.
     # 5 - Nao localizou socorrista especializado p/srv. multiplo.
     # 6 - Nao localizou socorrista adequado p/srv. multiplo.

  # --INICIALIZACAO DAS VARIAVEIS

        define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_socntzcod  =  null
        let     l_espcod  =  null
        let     l_cod_motivo  =  null
        let     l_indice  =  null
        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  10
                initialize  al_multiplos[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  10
                initialize  al_naturezas[w_pf1].*  to  null
        end     for

  # --VERIFICA SE O SERVICO ORIGINAL POSSUI SERVICOS MULTIPLOS
  call cts29g00_obter_multiplo(2, lr_parametro.atdsrvnum, lr_parametro.atdsrvano)

       returning l_resultado,
                 l_mensagem,
                 al_multiplos[1].*,
                 al_multiplos[2].*,
                 al_multiplos[3].*,
                 al_multiplos[4].*,
                 al_multiplos[5].*,
                 al_multiplos[6].*,
                 al_multiplos[7].*,
                 al_multiplos[8].*,
                 al_multiplos[9].*,
                 al_multiplos[10].*

  for l_indice = 1 to 10

     if al_multiplos[l_indice].atdmltsrvnum is not null then

        # --OBTER CODIGO DA NATUREZA E O CODIGO DA ESPECIALIDADE
        # --PARA CADA SERVICO MULTIPLO ENCONTRADO (datmsrvre)
        call cts40g01_obter_codnat_codesp(al_multiplos[l_indice].atdmltsrvnum,
                                          al_multiplos[l_indice].atdmltsrvano)

             returning l_resultado,
                       l_mensagem,
                       al_naturezas[l_indice].socntzcod,
                       al_naturezas[l_indice].espcod

        if l_resultado <> 0 then
           if l_resultado <> 1 then
              let l_msg = "Erro na funcao cts40g01_obter_codnat_codesp()"
              let l_cod_motivo = 3
              call errorlog(l_msg)
              call errorlog(l_mensagem)
              return l_cod_motivo
           end if
        end if
     else
        # --NAO POSSUI SERVICOS MULTIPLOS
        exit for
     end if

  end for

  let l_cod_motivo = 1

  # --OBTER CODIGO DA NATUREZA E O CODIGO DA ESPECIALIDADE DO SOCORRISTA
  # --PASSADO COMO PARAMETRO
  open c_cts40g05_001 using lr_parametro.srrcoddig

  foreach c_cts40g05_001 into l_socntzcod, l_espcod

      # --VERIFICA SE O SOCORRISTA ATENDE A NATUREZA DO SERVICO
      if lr_parametro.socntzcod = l_socntzcod then

          # --SE ATENDER, VERIFICA SE O SERVICO POSSUI ALGUMA ESPECIALIDADE
          if lr_parametro.espcod is not null then

             # --SE POSSUIR ESPECIALIDADE, VERIFICA SE O SOCORRISTA ATENDE A ESPECIALIDADE
             if l_espcod = lr_parametro.espcod then
                let l_cod_motivo = 0
                exit foreach
             else
                # --NAO LOCALIZOU SOCORRISTA ESPECIALIZADO
                let l_cod_motivo = 2
                continue foreach
             end if
          else
             # --SE NAO PUSSUIR ESPECIALIDADE O SOCORRISTA ATENDE O SERVICO
             let l_cod_motivo = 0
             exit foreach
          end if

      end if

  end foreach

  close c_cts40g05_001

  if l_cod_motivo = 0 then

     # --CONSISTIR AS NATUREZAS DOS SERVICOS MULTIPLOS
     for l_indice = 1 to 10

         if al_naturezas[l_indice].socntzcod is not null then

            let l_cod_motivo = 6

            #  --BUSCA AS NATUREZAS NO CADASTRO DO SOCORRISTA
            open c_cts40g05_001 using lr_parametro.srrcoddig

            foreach c_cts40g05_001 into l_socntzcod, l_espcod

                # --VERIFICA SE O SOCORRISTA ATENDE A NATUREZA DO SERVICO MULTIPLO
                if al_naturezas[l_indice].socntzcod = l_socntzcod then

                    # --SE ATENDER, VERIFICA SE O SERVICO MULTIPLO POSSUI ALGUMA ESPECIALIDADE
                    if al_naturezas[l_indice].espcod is not null then

                       # --SE POSSUIR ESPECIALIDADE, VERIFICA SE O SOCORRISTA ATENDE A ESPECIALIDADE
                       if l_espcod = al_naturezas[l_indice].espcod then
                          let l_cod_motivo = 0
                          exit foreach
                       else
                          # --NAO LOCALIZOU SOCORRISTA ESPECIALIZADO P/SRV. MULTIPLO
                          let l_cod_motivo = 5
                          continue foreach
                       end if

                    else
                       # --SE NAO PUSSUIR ESPECIALIDADE, O SOCORRISTA ATENDE O SERVICO
                       let l_cod_motivo = 0
                       exit foreach
                    end if
                end if

            end foreach

            close c_cts40g05_001

            # --SE PARA QUALQUER MULTIPLO NAO ENCONTRAR UM SOCORRISTA ESPECIALIZADO
            # --NAO PRECISA TESTAR O RESTANTE DOS MULTIPLOS
            if l_cod_motivo = 5 or
               l_cod_motivo = 6 then
               exit for
            end if

         else
            # --NAO EXISTE SERVICO MULTIPLO
            exit for
         end if

     end for

  end if

  return l_cod_motivo

end function

#----------------------------------------------#
function cts40g05_verifica_rodizio(lr_parametro)
#----------------------------------------------#

  define lr_parametro  record
         cidcod        like glakcid.cidcod,
         vcllicnum     like datkveiculo.vcllicnum,
         distancia     decimal(8,4),
         atdhorprg     like datmservico.atdhorprg
  end record

  define l_rdzlcldst   like datkvclrdzprt.rdzlcldst,
         l_rdzsttflg   like datkvclrdzprt.rdzsttflg,
         l_resultado   smallint,
         l_rodizio     smallint,
         l_msg         char(100),
         l_final_placa decimal(1,0),
         l_dia_semana  smallint,
         l_data_atual  date,
         l_hora_atual  datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_rdzlcldst  =  null
        let     l_rdzsttflg  =  null
        let     l_resultado  =  null
        let     l_rodizio  =  null
        let     l_msg  =  null
        let     l_final_placa  =  null
        let     l_dia_semana  =  null
        let     l_data_atual  =  null
        let     l_hora_atual  =  null

  if m_cts40g05_prep is null or
     m_cts40g05_prep <> true then
     call cts40g05_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_rodizio     = false

  let l_resultado = 0

  # --OBTER O ULTIMO NUMERO DA PLACA
  let l_final_placa = lr_parametro.vcllicnum[7,7]


  # --BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual, l_hora_atual

  # --OBTER O DIA DA SEMANA(NUMERO)
  let l_dia_semana = weekday(l_data_atual)

  open c_cts40g05_002 using lr_parametro.cidcod,
                          l_final_placa,
                          l_dia_semana,
                          l_hora_atual,
                          l_hora_atual,
                          lr_parametro.atdhorprg,
                          lr_parametro.atdhorprg

  whenever error continue
  fetch c_cts40g05_002 into l_rdzlcldst,
                          l_rdzsttflg
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_rodizio   = false
        let l_resultado = 0
        let l_rdzlcldst = null
        let l_rdzsttflg = null
     else
        let l_resultado = 2
        let l_msg = "Erro SELECT c_cts40g05_002 / ",
                     sqlca.sqlcode, "/",
                     sqlca.sqlerrd[2]

        call errorlog(l_msg)

        let l_msg = "CTS40G05/cts40g05_verifica_rodizio() / ",
                     lr_parametro.cidcod clipped, "/",
                     l_final_placa clipped, "/",
                     l_dia_semana clipped, "/",
                     l_hora_atual clipped, "/",
                     l_hora_atual clipped, "/",
                     lr_parametro.atdhorprg clipped, "/",
                     lr_parametro.atdhorprg

        call errorlog(l_msg)
     end if
  else

     # -- VERIFICA SE O RODIZIO ESTA SUSPENSO
     if l_rdzsttflg = "S" then
        let l_rodizio = false
     else

        # --VERIFICA SE O RODIZIO ESTA ATIVO
        if l_rdzsttflg = "N" then

           if (lr_parametro.distancia <= l_rdzlcldst) then
              let l_rodizio = false
           else
              # --VEICULO EM RODIZIO FORA DA DISTANCIA LIMITE
              let l_rodizio = true
           end if
        end if

     end if

  end if

  close c_cts40g05_002

  return l_resultado,
         l_rodizio

end function

#---------------------------------------#
function cts40g05_ordena_array(l_tamanho)
#---------------------------------------#

  define l_tamanho   integer,
         l_contador1 integer,
         l_contador2 integer

  define lr_veiculos record
         srrcoddig   like dattfrotalocal.srrcoddig,
         socvclcod   like datkveiculo.socvclcod,
         pstcoddig   like datkveiculo.pstcoddig,
         lclltt      like datmfrtpos.lclltt,
         lcllgt      like datmfrtpos.lcllgt,
         atldat      like datmfrtpos.atldat,
         atlhor      like datmfrtpos.atlhor,
         vcllicnum   like datkveiculo.vcllicnum,
         distancia   decimal(8,4)
  end record

  # --INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_contador1  =  null
        let     l_contador2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_veiculos.*  to  null

  initialize lr_veiculos to null

  let l_contador1 = 0
  let l_contador2 = 0

   # --ORDENA O ARRAY POR ORDEM CRESCENTE DE DISTANCIA
   for l_contador1 = 1 to l_tamanho
      for l_contador2 = l_contador1 + 1 to l_tamanho

         if am_veiculos[l_contador1].distancia > am_veiculos[l_contador2].distancia then
            let lr_veiculos.srrcoddig = am_veiculos[l_contador1].srrcoddig
            let lr_veiculos.socvclcod = am_veiculos[l_contador1].socvclcod
            let lr_veiculos.pstcoddig = am_veiculos[l_contador1].pstcoddig
            let lr_veiculos.lclltt    = am_veiculos[l_contador1].lclltt
            let lr_veiculos.lcllgt    = am_veiculos[l_contador1].lcllgt
            let lr_veiculos.atldat    = am_veiculos[l_contador1].atldat
            let lr_veiculos.atlhor    = am_veiculos[l_contador1].atlhor
            let lr_veiculos.vcllicnum = am_veiculos[l_contador1].vcllicnum
            let lr_veiculos.distancia = am_veiculos[l_contador1].distancia

            let am_veiculos[l_contador1].srrcoddig  = am_veiculos[l_contador2].srrcoddig
            let am_veiculos[l_contador1].socvclcod  = am_veiculos[l_contador2].socvclcod
            let am_veiculos[l_contador1].pstcoddig  = am_veiculos[l_contador2].pstcoddig
            let am_veiculos[l_contador1].lclltt     = am_veiculos[l_contador2].lclltt
            let am_veiculos[l_contador1].lcllgt     = am_veiculos[l_contador2].lcllgt
            let am_veiculos[l_contador1].atldat     = am_veiculos[l_contador2].atldat
            let am_veiculos[l_contador1].atlhor     = am_veiculos[l_contador2].atlhor
            let am_veiculos[l_contador1].vcllicnum  = am_veiculos[l_contador2].vcllicnum
            let am_veiculos[l_contador1].distancia  = am_veiculos[l_contador2].distancia

            let am_veiculos[l_contador2].srrcoddig = lr_veiculos.srrcoddig
            let am_veiculos[l_contador2].socvclcod = lr_veiculos.socvclcod
            let am_veiculos[l_contador2].pstcoddig = lr_veiculos.pstcoddig
            let am_veiculos[l_contador2].lclltt    = lr_veiculos.lclltt
            let am_veiculos[l_contador2].lcllgt    = lr_veiculos.lcllgt
            let am_veiculos[l_contador2].atldat    = lr_veiculos.atldat
            let am_veiculos[l_contador2].atlhor    = lr_veiculos.atlhor
            let am_veiculos[l_contador2].vcllicnum = lr_veiculos.vcllicnum
            let am_veiculos[l_contador2].distancia = lr_veiculos.distancia

         end if
   end for
      end for

end function


#PSI202363
#Funcao que encontra a quantidade de prestadores que podem atender
# o servico no momento e o veículo mais proximo
#---------------------------------------#
function cts40g05_busca_qtde_veiculos(param)
#---------------------------------------#

    define param record
       cidcod  like glakcid.cidcod,
       ufdcod  like glakcid.ufdcod,
       hora    like datmservico.atdhorprg,
       lclltt_srv  like datmlcl.lclltt,
       lcllgt_srv  like datmlcl.lcllgt,
       cidacndst   like datracncid.cidacndst
    end record

    define a_natserv array[11] of record
          socntzcod    like datmsrvre.socntzcod,
          espcod       like datmsrvre.espcod
    end record

    #veiculo mais proximo que pode atender o servico
    define veiculo record
         cod_motivo   smallint,
         msg_motivo   like datmservico.acnnaomtv,
         srrcoddig    like dattfrotalocal.srrcoddig,
         socvclcod    like datkveiculo.socvclcod,
         pstcoddig    like datkveiculo.pstcoddig,
         distancia    decimal(8,4),
         lclltt       like datmfrtpos.lclltt,
         lcllgt       like datmfrtpos.lcllgt
    end record

    # array auxiliar para guardar apenas os veiculos validos
    define a_veiculos_aux  array[500] of record
           srrcoddig       like dattfrotalocal.srrcoddig,
           socvclcod       like datkveiculo.socvclcod,
           pstcoddig       like datkveiculo.pstcoddig,
           lclltt          like datmfrtpos.lclltt,
           lcllgt          like datmfrtpos.lcllgt,
           atldat          like datmfrtpos.atldat,
           atlhor          like datmfrtpos.atlhor,
           vcllicnum       like datkveiculo.vcllicnum,
           distancia       decimal(8,4)
    end record

    define l_aux     smallint,
           l_aux2    smallint,
           l_aux_nat smallint,
           l_sql     char(200),
           l_resultado   smallint,
           l_rodizio     smallint,
           l_qtde_validos      smallint,
           l_qtde_desprezados  smallint,
           l_qtde_lido         smallint,
           l_tempo_total       decimal(6,1),
           l_codigo_motivo     smallint,
           l_distancia       decimal(8,4)

    define l_roter_ativa      smallint,
           l_roter_qtd        smallint,
           l_roter_arr        smallint,
           l_bloqueou         smallint,
           ##l_ufdcod           like glakcid.ufdcod,
           ##l_cidnom           like glakcid.cidnom,
           l_mensagem         char(60),
           l_roter_xml_veic   char(32000),
           l_fator            decimal(4,2)

    initialize a_natserv to null
    initialize veiculo.* to null
    initialize a_veiculos_aux to null

    let l_bloqueou = null
    let l_aux = 1
    let l_aux2 = 1
    let l_aux_nat = 1
    let l_sql = null
    let l_resultado = 0
    let l_rodizio = null
    let l_qtde_validos = 0
    let l_qtde_desprezados = 0
    let l_qtde_lido = 0
    let l_tempo_total = 0
    let l_codigo_motivo = 0
    let l_roter_ativa = null
    let l_roter_qtd = null
    let l_roter_arr = 0
    ##let l_ufdcod = null
    ##let l_cidnom = null
    let l_mensagem = null
    let l_roter_xml_veic     = '<VEICULOS>'
    let l_fator = null
    let l_distancia = null

    #ler tabela temporaria onde foi aramazenado as naturezas do servico
    let l_sql = " select socntzcod, ",
                       " espcod ",
                " from temp_nat_cts17m00 "
    prepare p_cts40g05_006 from l_sql
    declare c_cts40g05_006 cursor for p_cts40g05_006

    # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
    let l_roter_ativa = ctx25g05_rota_ativa()

    #para estados diferentes de RJ, SP e PR nao tem roteirização
    if param.ufdcod <> "RJ" and
       param.ufdcod <> "SP" and
       param.ufdcod <> "PR" then
       let l_roter_ativa = false
    end if

    # -> BUSCA A QTD DE ROTAS PARAMETRIZDA
    let l_roter_qtd   = ctx25g05_qtde_rotas_ac()

    if l_roter_qtd > 10 then
       let l_roter_qtd = 10 # -> QTD. LIMITE DE VEICULOS A SEREM ROTERIZADOS
    end if

    #para cada socorrista lido
    while am_veiculos[l_aux].socvclcod is not null

         let l_resultado = 0
         let l_qtde_lido = l_qtde_lido + 1
         let l_aux_nat = 1

         #ler natureza/especialidade do servico e seus multiplos
         open c_cts40g05_006
         foreach c_cts40g05_006 into a_natserv[l_aux_nat].socntzcod,
                                         a_natserv[l_aux_nat].espcod
             if a_natserv[l_aux_nat].socntzcod is null or
                a_natserv[l_aux_nat].socntzcod = 0 then
                exit foreach
             end if

             #verificar se socorrista atende natureza lida
             if ctc74m01_verificasocnat(am_veiculos[l_aux].srrcoddig,
                                        a_natserv[l_aux_nat].socntzcod,
                                        a_natserv[l_aux_nat].espcod) = false then
                #se socorrista nao atende natureza/especialidade do servico
                # despreza o socorrista
                let l_resultado = 1
                exit foreach
             end if

             #vai ler a proxima natureza
             let l_aux_nat = l_aux_nat + 1

         end foreach

         #se desprezou veiculo, vai ler o proximo
         if l_resultado <> 0 then
            let l_aux = l_aux + 1
            let l_qtde_desprezados = l_qtde_desprezados + 1
            continue while
         end if

         #verifica se veiculo está no rodizio
         call cts40g05_verifica_rodizio(param.cidcod,
                                        am_veiculos[l_aux].vcllicnum,
                                        am_veiculos[l_aux].distancia,
                                        param.hora)
              returning l_resultado,
                        l_rodizio

         if l_resultado <> 0 then
            #problemas no acesso ao banco
            # despreza o socorrista
            let l_aux = l_aux + 1
            let l_qtde_desprezados = l_qtde_desprezados + 1
            continue while
         end if

         if l_rodizio then
            # --VEICULO EM RODIZIO FORA DA DISTANCIA LIMITE.
            # despreza o socorrista
            let l_aux = l_aux + 1
            let l_qtde_desprezados = l_qtde_desprezados + 1
            continue while
         end if

         # --ENCONTROU SOCORRISTA
         #veiculo é valido - copiar para array auxiliar

         let l_qtde_validos = l_qtde_validos + 1
         let a_veiculos_aux[l_aux2].srrcoddig = am_veiculos[l_aux].srrcoddig
         let a_veiculos_aux[l_aux2].socvclcod = am_veiculos[l_aux].socvclcod
         let a_veiculos_aux[l_aux2].pstcoddig = am_veiculos[l_aux].pstcoddig
         let a_veiculos_aux[l_aux2].lclltt    = am_veiculos[l_aux].lclltt
         let a_veiculos_aux[l_aux2].lcllgt    = am_veiculos[l_aux].lcllgt
         let a_veiculos_aux[l_aux2].atldat    = am_veiculos[l_aux].atldat
         let a_veiculos_aux[l_aux2].atlhor    = am_veiculos[l_aux].atlhor
         let a_veiculos_aux[l_aux2].vcllicnum = am_veiculos[l_aux].vcllicnum
         let a_veiculos_aux[l_aux2].distancia = am_veiculos[l_aux].distancia

         #vai validar próximo socorrista
         let l_aux = l_aux + 1
         let l_aux2 = l_aux2 + 1

    end while

    #se nao sobrou veiculo valido - retornar
    if l_qtde_validos < 1 then
        return l_codigo_motivo,
               veiculo.srrcoddig,
               veiculo.socvclcod,
               veiculo.pstcoddig,
               veiculo.distancia,
               veiculo.lclltt,
               veiculo.lcllgt,
               l_tempo_total,
               l_qtde_validos
    end if

    #após carregar os prestadores que podem atender o servico
    # buscar entre os que ficaram o prestador com a menor distancia

    if l_roter_ativa then

       # veiculos já estão ordenados por distancia
       # antes de chamar a função ordenei array am_veiculos e
       # ao montar o array auxiliar
       # já separei os veiculos validos já ordenado
       # roteirização ativa

       for l_aux = 1 to l_qtde_validos
         # montar texto xml
         # -> VERIFICA O LIMITE DE ROTAS PARA O ACIONAMENTO

         if l_roter_arr <= l_roter_qtd then

            #manda apenas os 6 primeiros para roteirizar
            let l_roter_arr = (l_roter_arr + 1)

            # -> MONTA O XML DE REQUEST DOS VEICULOS
            let l_roter_xml_veic =  l_roter_xml_veic clipped,
                                   '<VEICULO>',
                                   '<ID>', l_aux using "<<<<&", '</ID>',
                                   '<COORDENADAS>',
                                   '<TIPO>WGS84</TIPO>',
                                   '<X>',
                                    a_veiculos_aux[l_aux].lcllgt,
                                   '</X>',
                                   '<Y>',
                                    a_veiculos_aux[l_aux].lclltt,
                                   '</Y>',
                                   '</COORDENADAS>',
                                   '</VEICULO>'
         end if
       end for

       if l_roter_arr <> 0 then # ENCONTROU VEICULO
          let l_roter_xml_veic = l_roter_xml_veic clipped, '</VEICULOS>'

          call ctx25g06(param.lclltt_srv,
                        param.lcllgt_srv,
                        l_roter_xml_veic)
               returning l_aux,
                         l_distancia,
                         ##a_veiculos_aux[l_aux].distancia,
                         l_tempo_total

          if l_aux is null or l_aux = 0 then #ligia 19/12
             return 14, '','','','','','','', '' ## Alterei outra vez
          else
             let a_veiculos_aux[l_aux].distancia = l_distancia
          end if

          if a_veiculos_aux[l_aux].distancia <= 0 then

             return 8, ##############l_codigo_motivo,
                    veiculo.srrcoddig,
                    veiculo.socvclcod,
                    veiculo.pstcoddig,
                    veiculo.distancia,
                    veiculo.lclltt,
                    veiculo.lcllgt,
                    l_tempo_total,
                    l_qtde_validos
          end if

           # -> BUSCA O FATOR MAXIMO DE DESVIO DA DISTANCIA EM LINHA RETA P/ROTERIZADA
           let l_fator = ctx25g05_fator_desvio()

           # se o veiculo mais proximo está fora da distancia limite
           # já com o fator de desvio
           # aplicado - retornar que não tem veiculo que atenda o servico

           if (a_veiculos_aux[l_aux].distancia > (param.cidacndst * l_fator))
               then
               return l_codigo_motivo,
                      veiculo.srrcoddig,
                      veiculo.socvclcod,
                      veiculo.pstcoddig,
                      veiculo.distancia,
                      veiculo.lclltt,
                      veiculo.lcllgt,
                      l_tempo_total,
                      l_qtde_validos
           end if

           #copiar o veiculo com menor distancia
           let veiculo.srrcoddig = a_veiculos_aux[l_aux].srrcoddig
           let veiculo.socvclcod = a_veiculos_aux[l_aux].socvclcod
           let veiculo.pstcoddig = a_veiculos_aux[l_aux].pstcoddig
           let veiculo.distancia = a_veiculos_aux[l_aux].distancia
           let veiculo.lclltt    = a_veiculos_aux[l_aux].lclltt
           let veiculo.lcllgt    = a_veiculos_aux[l_aux].lcllgt
       end if
    else
       # roteirização inativa
       # copiar primeira posição (array já está ordenado) para o
       # veiculo mais proximo

       let veiculo.srrcoddig = a_veiculos_aux[1].srrcoddig
       let veiculo.socvclcod = a_veiculos_aux[1].socvclcod
       let veiculo.pstcoddig = a_veiculos_aux[1].pstcoddig
       let veiculo.distancia = a_veiculos_aux[1].distancia
       let veiculo.lclltt    = a_veiculos_aux[1].lclltt
       let veiculo.lcllgt    = a_veiculos_aux[1].lcllgt

    end if

    let l_aux = 0
    #bloquear prestador
    call cts40g06_bloq_veic(veiculo.socvclcod,999997)
         returning l_aux, l_bloqueou

    if l_aux <> 0 then
       #nao conseguiu bloquear veiculo
       let veiculo.socvclcod = null
    end if

    return l_codigo_motivo,
           veiculo.srrcoddig,
           veiculo.socvclcod,
           veiculo.pstcoddig,
           veiculo.distancia,
           veiculo.lclltt,
           veiculo.lcllgt,
           l_tempo_total,
           l_qtde_validos

end function


#Funcao que retorna os dados de um veiculo necessario ao acionamento
#---------------------------------------#
function cts40g05_obter_dados_veiculo(param)
#---------------------------------------#

   define param record
       socvclcod  like datkveiculo.socvclcod
   end record

   define d_veiculo record
         cod_retorno    smallint,
         srrcoddig      like dattfrotalocal.srrcoddig,
         pstcoddig      like datkveiculo.pstcoddig,
         lclltt         like datmfrtpos.lclltt,
         lcllgt         like datmfrtpos.lcllgt
   end record

   initialize d_veiculo.* to null

   if m_cts40g05_prep is null or
      m_cts40g05_prep <> true then
      call cts40g05_prepare()
   end if

   open c_cts40g05_003 using param.socvclcod
   fetch c_cts40g05_003 into d_veiculo.srrcoddig,
                           d_veiculo.pstcoddig,
                           d_veiculo.lclltt,
                           d_veiculo.lcllgt
   if sqlca.sqlcode <> 0 then
      let d_veiculo.cod_retorno = false
   end if

   close c_cts40g05_003

   return d_veiculo.*

end function
