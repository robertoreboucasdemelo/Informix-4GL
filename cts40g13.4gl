#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G13                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTOMOVEL.                 #
#                  BUSCA UM VEICULO MAIS ADEQUADO P/ATENDER O SERVICO AUTO.   #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 19/12/2007 Ligia Mattge               considerar equipamento p/tecnico bike #
# 24/11/2008 Ligia Mattge PSI 232700 Retirar a excessao do Tecnico            #
# 12/01/2010 Kevellin     PSI 251712 Gerenciamento da Frota Extra             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g13_prep smallint
        ,m_display       smallint


  define am_veiculo array[500] of record
         srrcoddig  like dattfrotalocal.srrcoddig,
         socvclcod  like datkveiculo.socvclcod,
         pstcoddig  like datkveiculo.pstcoddig,
         lclltt     like datmfrtpos.lclltt,
         lcllgt     like datmfrtpos.lcllgt,
         atldat     like datmfrtpos.atldat,
         atlhor     like datmfrtpos.atlhor,
         vcllicnum  like datkveiculo.vcllicnum,
         distancia  decimal(8,4)
  end record

 #########################RETIRAR
 define l_destinatarios char(4000)
 define l_comando char(4000)
 define l_assunto char(2000)
 #########################RETIRAR

#-------------------------#
function cts40g13_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select vclcndlclcod ",
                " from datrcndlclsrv ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g13_001 from l_sql
  declare c_cts40g13_001 cursor for p_cts40g13_001

  let l_sql = " select 1 ",
                " from datrsrrasi ",
               " where srrcoddig = ? ",
                 " and asitipcod = ? "

  prepare p_cts40g13_002 from l_sql
  declare c_cts40g13_002 cursor for p_cts40g13_002

  let l_sql = " select soceqpcod ",
                " from datrctggch ",
               " where ctgtrfcod = ? "

  prepare p_cts40g13_003 from l_sql
  declare c_cts40g13_003 cursor for p_cts40g13_003

  let l_sql = " select soceqpcod ",
                " from datrvclexcgch ",
               " where vclcoddig = ? "

  prepare p_cts40g13_004 from l_sql
  declare c_cts40g13_004 cursor for p_cts40g13_004

  let l_sql = " select soceqpcod ",
                " from datrlclcndvclgch ",
               " where vclcndlclcod = ? "

  prepare p_cts40g13_005 from l_sql
  declare c_cts40g13_005 cursor for p_cts40g13_005

  let l_sql = " select srrabvnom ",
                " from datksrr ",
               " where srrcoddig = ? "

  prepare p_cts40g13_006 from l_sql
  declare c_cts40g13_006 cursor for p_cts40g13_006

  let l_sql = " select socvcltip ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare p_cts40g13_007 from l_sql
  declare c_cts40g13_007 cursor for p_cts40g13_007

  #PSI 251712 - FROTEX
  #VERIFICA SE VEÍCULO TEM O EQUIPAMENTO FROTEX INSTALADO
  let l_sql = ' select socvclcod ',
                ' from datreqpvcl ',
               ' where socvclcod = ? ',
                 ' and soceqpcod = 72 '
  prepare p_cts40g13_008 from l_sql
  declare c_cts40g13_008 cursor for p_cts40g13_008

  #PSI 251712 - FROTEX
  #VERIFICA SE FROTEX ESTÁ ATIVADO
  let l_sql = " select grlinf ",
                   " from datkgeral ",
                  " where grlchv = 'GER_FROTEX' "

  prepare p_cts40g13_009 from l_sql
  declare c_cts40g13_009 cursor for p_cts40g13_009

  let l_sql = ' select ufdcod '
             ,'   from datmlcl '
             ,'  where atdsrvnum = ? '
             ,'    and atdsrvano = ? '
             ,'    and c24endtip = 1 '
  prepare p_cts40g13_011 from l_sql
  declare c_cts40g13_011 cursor for p_cts40g13_011


  let m_cts40g13_prep = true

end function

#-------------------------------------#
function cts40g13_e_pickup(l_socvclcod)
#-------------------------------------#

  # FUNCAO PARA VERIFICAR SE O VEICULO E UMA PICK-UP

  define l_socvclcod like datkveiculo.socvclcod,
         l_socvcltip like datkveiculo.socvcltip,
         l_e_pickup  smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_socvcltip  =  null
        let     l_e_pickup  =  null

  let l_e_pickup  = false

  open c_cts40g13_007 using l_socvclcod
  fetch c_cts40g13_007 into l_socvcltip
  close c_cts40g13_007

  if l_socvcltip = 1 then # PICK-UP
     let l_e_pickup = true
  end if

  return l_e_pickup

end function

#----------------------------------------#
function cts40g13_obter_veic(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,          # --LATITUDE DO SERVCIO
         lcllgt       like datmlcl.lcllgt,          # --LONGITUDE DO SERVICO
         cidacndst    like datracncid.cidacndst,    # --DISTANCIA LIMITE PARAMETRIZADA
         cidnom       like glakcid.cidnom,          # --NOME DA CIDADE
         ufdcod       like glakcid.ufdcod,          # --CODIGO DO ESTADO DA CIDADE
         atdsrvnum    like datmservico.atdsrvnum,   # --NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano,   # --ANO DO SERVICO
         atdhorprg    like datmservico.atdhorprg,   # --HORA PROGRAMADA DO SERVICO
         atdsrvorg    like datmservico.atdsrvorg,   # --ORIGEM DO SERVICO
         asitipcod    like datmservico.asitipcod,   # --COD. TIPO DE ASSISTENCIA
         vclcoddig    like datmservico.vclcoddig,   # --COD. DO VEICULO DO SEGURADO
         ciaempcod    like datmservico.ciaempcod,   # --COD. DA EMPRESA DO SERVICO
         imsvlr       like abbmcasco.imsvlr         # --Valor da IS da Apolice
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

  define l_qtd_veic    smallint,
         l_msg         char(80),
         l_data_atual  date,
         l_hora_atual  datetime hour to minute,
         l_mensagem    char(100),
         l_sql_regra   char(100),
         l_tempo_total decimal(6,1),
         l_resultado  smallint,
         l_ctgtrfcod  like datrctggch.ctgtrfcod,
         l_srrabvnom  like datksrr.srrabvnom,
         l_ufdcod     like datmlcl.ufdcod


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_qtd_veic    = null
        let     l_msg         = null
        let     l_data_atual  = null
        let     l_hora_atual  = null
        let     l_mensagem    = null
        let     l_sql_regra   = null
        let     l_resultado   = null
        let     l_ctgtrfcod   = null
        let     l_srrabvnom   = null
        let     l_tempo_total = null
        let     l_ufdcod      = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_analise.*  to  null

  if m_cts40g13_prep is null or
     m_cts40g13_prep <> true then
     call cts40g13_prepare()
  end if

  #------------------------------
  # BUSCAR A DATA E HORA DO BANCO
  #------------------------------
  call cts40g03_data_hora_banco(2)
       returning l_data_atual,
                 l_hora_atual

  #--------------------------------------
  # OBTER O CODIGO DA CATEGORIA TARIFARIA
  #--------------------------------------
  call cty05g03_pesq_catgtf(lr_parametro.vclcoddig,
                            l_data_atual)
       returning l_resultado,
                 l_mensagem,
                 l_ctgtrfcod

  if l_resultado <> 0 then
     if l_resultado = 1 then
        let l_msg = "Nao encontrou categoria tarifaria na funcao cty05g03_pesq_catgtf()"
     else
        let l_msg = "Erro de acesso a banco na funcao cty05g03_pesq_catgtf()"
     end if
     call errorlog(l_msg)
     call errorlog(l_mensagem)
     let lr_analise.cod_motivo = 3
     initialize am_veiculo to null
  end if
whenever error continue
  open c_cts40g13_011 using lr_parametro.atdsrvnum
                           ,lr_parametro.atdsrvano
  fetch c_cts40g13_011 into l_ufdcod
  if l_ufdcod = 'DF' then
     let m_display = true
  end if
whenever error stop
  if m_display then
    display ' --- PARAMETROS CHAMADA cts40g13_regra_eqp --- '
    display 'l_ctgtrfcod           : ',l_ctgtrfcod
    display 'lr_parametro.vclcoddig: ',lr_parametro.vclcoddig
    display 'lr_parametro.atdsrvnum: ',lr_parametro.atdsrvnum
    display 'lr_parametro.atdsrvano: ',lr_parametro.atdsrvano
    display 'lr_parametro.asitipcod: ',lr_parametro.asitipcod
  end if


  let l_sql_regra = cts40g13_regra_eqp(l_ctgtrfcod,
                                       lr_parametro.vclcoddig,
                                       lr_parametro.atdsrvnum,
                                       lr_parametro.atdsrvano,
                                       lr_parametro.asitipcod)
  #display ' l_sql_regra: ', l_sql_regra clipped
  if l_sql_regra is null then
     let lr_analise.cod_motivo = 13
  else
     #--------------------
     # CARREGA OS VEICULOS
     #--------------------

     if m_display then
        display ' --- PARAMETRO DE CHAMADA cts40g13_carga_veic --- '
        display 'lr_parametro.lclltt   :',lr_parametro.lclltt
        display 'lr_parametro.lcllgt   :',lr_parametro.lcllgt
        display 'l_sql_regra           :',l_sql_regra clipped
        display 'lr_parametro.cidacndst:',lr_parametro.cidacndst
        display 'lr_parametro.asitipcod:',lr_parametro.asitipcod
        display 'lr_parametro.ciaempcod:',lr_parametro.ciaempcod
        display 'l_data_atual          :',l_data_atual
        display 'lr_parametro.imsvlr   :',lr_parametro.imsvlr
     end if

     let l_qtd_veic = cts40g13_carga_veic(lr_parametro.lclltt,
                                          lr_parametro.lcllgt,
                                          l_sql_regra,
                                          lr_parametro.cidacndst,
                                          lr_parametro.asitipcod,
                                          lr_parametro.ciaempcod,
                                          l_data_atual,
                                          lr_parametro.imsvlr)

     if m_display then
        display 'l_qtd_veic: ', l_qtd_veic
     end if
     #------------------------------------------------------------
     # NAO ENCONTROU NENHUM VEICULO DENTRO DO LIMITE PARAMETRIZADO
     #------------------------------------------------------------
     if l_qtd_veic = 0 then
        let lr_analise.cod_motivo = 7
     else
        #----------------------------------------------------
        # ORDENA OS VEICULOS POR ORDEM DE DISTANCIA CRESCENTE
        #----------------------------------------------------
        call cts40g13_ordena_array(l_qtd_veic)

        #-----------------------------------------------------------------
        # ANALISE, VERIFICANDO SE EXISTE ALGUM VEICULO P/ATENDER O SERVICO
        #-----------------------------------------------------------------
        if m_display then
           display ' --- chamada da função cts40g13_analise_veic --- '
           display 'l_qtd_veic            :',l_qtd_veic
           display 'lr_parametro.cidnom   :',lr_parametro.cidnom
           display 'lr_parametro.ufdcod   :',lr_parametro.ufdcod
           display 'lr_parametro.atdsrvnum:',lr_parametro.atdsrvnum
           display 'lr_parametro.atdsrvano:',lr_parametro.atdsrvano
           display 'lr_parametro.atdhorprg:',lr_parametro.atdhorprg
           display 'lr_parametro.atdsrvorg:',lr_parametro.atdsrvorg
           display 'lr_parametro.asitipcod:',lr_parametro.asitipcod
           display 'lr_parametro.vclcoddig:',lr_parametro.vclcoddig
           display 'lr_parametro.lclltt   :',lr_parametro.lclltt
           display 'lr_parametro.lcllgt   :',lr_parametro.lcllgt
           display 'lr_parametro.cidacndst:',lr_parametro.cidacndst
        end if


        call cts40g13_analise_veic(l_qtd_veic,
                                   lr_parametro.cidnom,
                                   lr_parametro.ufdcod,
                                   lr_parametro.atdsrvnum,
                                   lr_parametro.atdsrvano,
                                   lr_parametro.atdhorprg,
                                   lr_parametro.atdsrvorg,
                                   lr_parametro.asitipcod,
                                   lr_parametro.vclcoddig,
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

             if m_display then
                display ' --- retorno da função cts40g13_analise_veic --- '
                display 'lr_analise.cod_motivo:' ,lr_analise.cod_motivo
                display 'lr_analise.srrcoddig :' ,lr_analise.srrcoddig
                display 'lr_analise.socvclcod :' ,lr_analise.socvclcod
                display 'lr_analise.pstcoddig :' ,lr_analise.pstcoddig
                display 'lr_analise.distancia :' ,lr_analise.distancia
                display 'lr_analise.lclltt    :' ,lr_analise.lclltt
                display 'lr_analise.lcllgt    :' ,lr_analise.lcllgt
                display 'l_tempo_total        :' ,l_tempo_total
             end if

        #---------------------------------------------------------------------------
        # SE NAO ENCONTROU NENHUM SOCORRISTA, NAO DEVOLVE DADOS REFERENTE AO VEICULO
        #---------------------------------------------------------------------------
        if lr_analise.cod_motivo <> 0 then
           let lr_analise.srrcoddig = null
           let lr_analise.socvclcod = null
           let lr_analise.pstcoddig = null
           let lr_analise.distancia = null
           let lr_analise.lclltt    = null
           let lr_analise.lcllgt    = null
        end if
     end if

     if lr_analise.srrcoddig is not null then
       #---------------------------
       # OBTER O NOME DO SOCORRISTA
       #---------------------------
       open c_cts40g13_006 using lr_analise.srrcoddig
       whenever error continue
       fetch c_cts40g13_006 into l_srrabvnom
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             let l_srrabvnom = null
             let l_msg       = "Nao encontrou o nome abreviado do socorrista: ",
                               lr_analise.srrcoddig
             call errorlog(l_msg)
          else
             let l_msg = "Erro SELECT c_cts40g13_006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
             call errorlog(l_msg)
             let l_msg = "cts40g13_obter_veic() / ", lr_analise.srrcoddig
             call errorlog(l_msg)
             let lr_analise.cod_motivo = 3
          end if
       end if

       close c_cts40g13_006

     end if
  end if

  #-----------------------------------------------
  # OBTER A MENSAGEM REFERENTE AO CODIGO DO MOTIVO
  #-----------------------------------------------
  let lr_analise.msg_motivo = cts40g13_obter_msg_motivo(lr_analise.cod_motivo)

  #display '-----------------------------------------------------------'
  #display 'lr_analise.cod_motivo: ', lr_analise.cod_motivo
  #display 'lr_analise.msg_motivo: ', lr_analise.msg_motivo clipped
  #display 'lr_analise.srrcoddig : ', lr_analise.srrcoddig
  #display 'lr_analise.socvclcod : ', lr_analise.socvclcod
  #display 'lr_analise.pstcoddig : ', lr_analise.pstcoddig
  #display 'lr_analise.distancia : ', lr_analise.distancia
  #display 'lr_analise.lclltt    : ', lr_analise.lclltt
  #display 'lr_analise.lcllgt    : ', lr_analise.lcllgt
  #display 'l_srrabvnom          : ', l_srrabvnom          clipped
  #display 'l_tempo_total        : ', l_tempo_total

  return lr_analise.cod_motivo,
         lr_analise.msg_motivo,
         lr_analise.srrcoddig,
         lr_analise.socvclcod,
         lr_analise.pstcoddig,
         lr_analise.distancia,
         lr_analise.lclltt,
         lr_analise.lcllgt,
         l_srrabvnom,
         l_tempo_total

end function

#---------------------------------------#
function cts40g13_regra_eqp(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         ctgtrfcod    like datrctggch.ctgtrfcod,
         vclcoddig    like datmservico.vclcoddig,
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         asitipcod    like datmservico.asitipcod
  end record

  define l_vclcndlclcod  like datrcndlclsrv.vclcndlclcod,
         l_contCatg      smallint,
         l_contExce      smallint,
         l_contLoca      smallint,
         l_contPer       smallint,
         l_contPer2      smallint,
         l_apoio         smallint,
         l_sql_final     char(1000),
         l_sql_ret       char(2000),
         l_sql_inicial   char(1000)

  define al_eqpCatg array[50] of smallint
  define al_eqpExce array[30] of smallint
  define al_eqpLoca array[30] of smallint


        define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vclcndlclcod  =  null
        let     l_contCatg  =  null
        let     l_contExce  =  null
        let     l_contLoca  =  null
        let     l_contPer  =  null
        let     l_contPer2  =  null
        let     l_apoio  =  null
        let     l_sql_final  =  null
        let     l_sql_ret  =  null
        let     l_sql_inicial  =  null

  if m_cts40g13_prep is null or
     m_cts40g13_prep <> true then
     call cts40g13_prepare()
  end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  50
                initialize  al_eqpCatg[w_pf1]    to  null
        end     for

        for     w_pf1  =  1  to  30
                initialize  al_eqpExce[w_pf1]    to  null
        end     for

        for     w_pf1  =  1  to  30
                initialize  al_eqpLoca[w_pf1]    to  null
        end     for

  let l_contCatg      = 0
  let l_contExce      = 0
  let l_contLoca      = 0

  #-------------------------------------------
  # BUSCA OS EQUIPAMENTOS SOMENTE PARA GUINCHO E PARA BIKE
  #-------------------------------------------
  # PSI 232700 retirar regra para tecnico - ligia - 24/11/2008
  #if lr_parametro.asitipcod = 1 or      # GUINCHO
  #   lr_parametro.asitipcod = 3 or      # GUINCHO TECNICO
  #   lr_parametro.asitipcod = 61 then   # TECNICO II

     let l_sql_inicial = " and d.soceqpcod in ("

     #------------------------------------------
     # BUSCA EQUIPAMENTOS DA CATEGORIA TARIFARIA
     #------------------------------------------
     let l_contCatg = 1
     open c_cts40g13_003 using lr_parametro.ctgtrfcod
     foreach c_cts40g13_003 into al_eqpCatg[l_contCatg]

        let l_contCatg = (l_contCatg + 1)

        if l_contCatg > 50 then
           exit foreach
        end if

     end foreach
     close c_cts40g13_003

     let l_contCatg = (l_contCatg - 1)


     #-------------------------------------------
     # BUSCA EQUIPAMENTOS DO CADASTRO DE EXCECOES
     #-------------------------------------------
     let l_contExce = 1
     open c_cts40g13_004 using lr_parametro.vclcoddig
     foreach c_cts40g13_004 into al_eqpExce[l_contExce]

        let l_contExce = (l_contExce + 1)

        if l_contCatg > 30 then
           exit foreach
        end if

     end foreach
     close c_cts40g13_004

     let l_contExce = (l_contExce - 1)

     # --VERIFICA SE O SERVICO E DE APOIO
     let l_apoio = cts37g00_existeServicoApoio(lr_parametro.atdsrvnum,
                                               lr_parametro.atdsrvano)

     #--------------------------------------
     # BUSCA O CODIGO LOCAL/CONDICAO VEICULO
     #--------------------------------------
     if l_apoio = 2 or # SERVICO ORIGINAL (TEM OUTROS SERVICOS DE APOIO)
        lr_parametro.ctgtrfcod = 30 or   #MOTO no subsolo nao enviar pickup
        lr_parametro.ctgtrfcod = 31 then #MOTO - ligia 07/12/06 - CT
        let l_contLoca = 0
     else
        let l_contLoca = 1
        open c_cts40g13_001 using lr_parametro.atdsrvnum,
                                lr_parametro.atdsrvano
        foreach c_cts40g13_001 into l_vclcndlclcod

           #----------------------------------------------------------
           # BUSCA EQUIPAMENTOS DO CADASTRO DE LOCAL/CONDICOES VEICULO
           #----------------------------------------------------------
           open c_cts40g13_005 using l_vclcndlclcod
           foreach c_cts40g13_005 into al_eqpLoca[l_contLoca]

              let l_contLoca = (l_contLoca + 1)

              if l_contCatg > 30 then
                 exit foreach
              end if

           end foreach
           close c_cts40g13_005

        end foreach
        close c_cts40g13_001

        let l_contLoca = (l_contLoca - 1)
     end if

     let l_sql_final = null
     #----------------------------------------
     # VERIFICA ONDE ENCONTROU OS EQUIPAMENTOS
     #----------------------------------------
     if l_contExce = 0 then
        if l_contLoca = 0 then
           #-------------------------------------------
           # ASSUME EQUIPAMENTOS DA CATEGORIA TARIFARIA
           #-------------------------------------------
           for l_contPer = 1 to l_contCatg
              if l_sql_final is null then
                 let l_sql_final = l_sql_final clipped,
                                   al_eqpCatg[l_contPer] using "<<<<&"
              else
                 let l_sql_final = l_sql_final clipped, ",",
                                   al_eqpCatg[l_contPer] using "<<<<&"
              end if
           end for
        else
           #--------------------------------------
           # ASSUME EQUIPAMENTOS DE LOCAL/CONDICAO
           #--------------------------------------
           for l_contPer = 1 to l_contLoca
              if l_sql_final is null then
                 let l_sql_final = l_sql_final clipped,
                                   al_eqpLoca[l_contPer] using "<<<<&"
              else
                 let l_sql_final = l_sql_final clipped, ",",
                                   al_eqpLoca[l_contPer] using "<<<<&"
              end if
           end for
        end if

     else
        #-----------------------------------
        # EXISTE EQP. CADASTRADO EM EXCECOES
        #-----------------------------------

        #------------------------------------------
        # VERIFICA SE EXISTE EQP. EM LOCAL/CONDICAO
        #------------------------------------------
        if l_contLoca = 0 then
           #---------------------------
           # ASSUME EQUIPAMENTOS DE EXC
           #---------------------------
           for l_contPer = 1 to l_contExce
              if l_sql_final is null then
                 let l_sql_final = l_sql_final clipped,
                                   al_eqpExce[l_contPer] using "<<<<&"
              else
                 let l_sql_final = l_sql_final clipped, ",",
                                   al_eqpExce[l_contPer] using "<<<<&"
              end if
           end for
        else
           #-------------------------------
           # EXISTE EQP. EM EXC. E LOC/COND
           #-------------------------------

           #-------------------------------------------------------
           # VERIFICA SE O EQP. DE EXC. ESTA CADASTRADO EM LOC/COND
           #-------------------------------------------------------
           for l_contPer = 1 to l_contExce
              for l_contPer2 = 1 to l_contLoca
                 #-------------------------------------------
                 # MONTA SQL C/EQP. IGUAIS NOS DOIS CADASTROS
                 #-------------------------------------------
                 if al_eqpExce[l_contPer] = al_eqpLoca[l_contPer2] then
                    if l_sql_final is null then
                       let l_sql_final = l_sql_final clipped,
                                         al_eqpExce[l_contPer] using "<<<<&"
                    else
                       let l_sql_final = l_sql_final clipped, ",",
                                         al_eqpExce[l_contPer] using "<<<<&"
                    end if
                 end if
              end for
           end for

        end if
     end if

     if l_sql_final is not null then
        let l_sql_ret = l_sql_inicial clipped,
                        l_sql_final   clipped, ")"
     end if
  #else
  #   let l_sql_ret = " "
  #end if

  return l_sql_ret

end function

#----------------------------------------#
function cts40g13_ver_assist(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         srrcoddig    like datrsrrasi.srrcoddig,
         asitipcod    like datrsrrasi.asitipcod
  end record

  define l_atende     smallint,
         l_msg        char(100),
         l_status     smallint # 0-> OK    2-> Erro acesso BD


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_atende  =  null
        let     l_msg  =  null
        let     l_status  =  null

  if m_cts40g13_prep is null or
     m_cts40g13_prep <> true then
     call cts40g13_prepare()
  end if

  let l_atende = true
  let l_status = 0

  #--------------------------------------------------------
  # VERIFICA SE O SOCORRISTA ATENDE A ASSITENCIA DO SERVICO
  #--------------------------------------------------------
  open c_cts40g13_002 using lr_parametro.srrcoddig,
                          lr_parametro.asitipcod
  whenever error continue
  fetch c_cts40g13_002
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_atende = false
     else
        let l_status = 2
        let l_msg = "Erro SELECT c_cts40g13_002 / ",
                     sqlca.sqlcode, "/",
                     sqlca.sqlerrd[2]
        call errorlog(l_msg)
        let l_msg = "CTS40G13/cts40g13_ver_assist() / ",
                     lr_parametro.srrcoddig, "/",
                     lr_parametro.asitipcod
        call errorlog(l_msg)
     end if
  end if

  close c_cts40g13_002

  return l_status, l_atende

end function

#----------------------------------------#
function cts40g13_carga_veic(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         sql_regra    char(100),
         cidacndst    like datracncid.cidacndst,
         asitipcod    like datmservico.asitipcod,
         ciaempcod    like datmservico.ciaempcod,
         data_atual   date,
         imsvlr       like abbmcasco.imsvlr
  end record

  define l_contador     smallint,
         l_flg_erro     char(01),
         l_sql          char(2000),
         l_msg          char(100),
         l_espera       interval hour(6) to minute,
         l_limite       interval hour(6) to minute,
         l_distancia    decimal(8,4),
         l_mdtcod       like datkveiculo.mdtcod,
         l_soceqpcod    like datreqpvcl.soceqpcod,
         l_eqpacndst    like datkvcleqp.eqpacndst,
         l_eqpimsvlr    like datkvcleqp.eqpimsvlr,
         l_res          smallint,
         l_eqpacndst_k  dec(15,5),
         l_vcldtbgrpcod like dattfrotalocal.vcldtbgrpcod,
         l_socvcltip    like datkveiculo.socvcltip,
         l_flag         char(1)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let l_contador     = null
        let l_flg_erro     = null
        let l_sql          = null
        let l_msg          = null
        let l_espera       = null
        let l_limite       = null
        let l_distancia    = null
        let l_eqpacndst    = null
        let l_eqpacndst_k  = null
        let l_eqpimsvlr    = null
        let l_res          = null
        let l_vcldtbgrpcod = null
        let l_socvcltip    = null
        let l_flag         = null

  let l_limite    = "0:10"

  for l_contador = 1 to 500
     let am_veiculo[l_contador].srrcoddig = null
     let am_veiculo[l_contador].socvclcod = null
     let am_veiculo[l_contador].pstcoddig = null
     let am_veiculo[l_contador].lclltt    = null
     let am_veiculo[l_contador].lcllgt    = null
     let am_veiculo[l_contador].atldat    = null
     let am_veiculo[l_contador].atlhor    = null
     let am_veiculo[l_contador].vcllicnum = null
     let am_veiculo[l_contador].distancia = null
  end for

  let l_contador = 1

# if lr_parametro.asitipcod = 2 then  # TECNICO
#
#     # QUANDO FOR SOMENTE UM TECNICO PARA ATENDER O SERVICO, NAO
#     # VAMOS FAZER O JOIN COM A TABELA DE EQUIPAMENTOS(datreqpvcl)
#
#     let l_sql = " select a.srrcoddig, ",
#                        " b.socvclcod, ",
#                        " b.pstcoddig, ",
#                        " c.lclltt, ",
#                        " c.lcllgt, ",
#                        " c.atldat, ",
#                        " c.atlhor, ",
#                        " b.vcllicnum, ",
#                        " b.mdtcod ",
#                   " from dattfrotalocal a, ",
#                        " datkveiculo b, ",
#                        " datmfrtpos c, ",
#                        " datreqpvcl d, ",
#                  " where a.c24atvcod = 'QRV' ",
#                    " and b.socvclcod = a.socvclcod ",
#                    " and b.socoprsitcod = '1' ",
#                    " and c.socvclcod = a.socvclcod ",
#                    " and c.socvcllcltip = '1' ",
#                    " and b.socacsflg = '0' ",
#                    " and b.socvclcod = d.socvclcod ",
#                    " and d.ciaempcod = ", lr_parametro.ciaempcod,  #psi 205206
#                    " and a.vcldtbgrpcod <> 7 " ##A pedido do Cesar em 22/11/06
#                    ## porque os veiculos destes grupo sao VP, JIT e tecnico de
#                    ## pericia dos servicos de remocao por sinistro. Nao devem
#                    ## ser considerados no acionamento automatico. Ligia
#  else
     let l_sql = " select a.srrcoddig, ",
                        " b.socvclcod, ",
                        " b.pstcoddig, ",
                        " c.lclltt, ",
                        " c.lcllgt, ",
                        " c.atldat, ",
                        " c.atlhor, ",
                        " b.vcllicnum, ",
                        " b.mdtcod, ",
                        " d.soceqpcod, ",
                        " a.vcldtbgrpcod, ", #adicionado cod grp distrib.
                        " b.socvcltip ",     #adicionado cod grp distrib.
                   " from dattfrotalocal a, ",
                        " datkveiculo b, ",
                        " datmfrtpos c, ",
                        " datreqpvcl d, ",
                        " datrvclemp e, ",
                        " datrvclasi f ",
                  " where a.c24atvcod = 'QRV' ",
                    " and b.socvclcod = a.socvclcod ",
                    " and b.socoprsitcod = '1' ",
                    " and c.socvclcod = a.socvclcod ",
                    " and c.socvcllcltip = '1' ",
                    " and b.socacsflg = '0' ",
                    " and b.socvclcod = d.socvclcod ",
                    " and b.socvclcod = e.socvclcod ",
                    " and e.ciaempcod = ", lr_parametro.ciaempcod,  #psi 205206
                    " and a.vcldtbgrpcod <> 7 ",
                    " and f.socvclcod = b.socvclcod ",
                    " and f.asitipcod = ", lr_parametro.asitipcod,
                    lr_parametro.sql_regra

#  end if ## ligia 20/12/07

  if m_display then
     display 'Query: ', l_sql clipped
  end if

  prepare p_cts40g13_010 from l_sql
  declare c_cts40g13_010 cursor for p_cts40g13_010

  #-------------------------------------------------------
  # BUSCA OS VEICULOS DISPONIVEIS P/ATENDER O SERVICO AUTO
  #-------------------------------------------------------
  let l_mdtcod    = null
  let l_soceqpcod = null

  open c_cts40g13_010
  foreach c_cts40g13_010 into am_veiculo[l_contador].srrcoddig,
                              am_veiculo[l_contador].socvclcod,
                              am_veiculo[l_contador].pstcoddig,
                              am_veiculo[l_contador].lclltt,
                              am_veiculo[l_contador].lcllgt,
                              am_veiculo[l_contador].atldat,
                              am_veiculo[l_contador].atlhor,
                              am_veiculo[l_contador].vcllicnum,
                              l_mdtcod, l_soceqpcod,
                              l_vcldtbgrpcod, l_socvcltip

     #------------------------------------------------
     # VERIFICA SE A LATITUDE OU LONGITUDE ESTAO NULAS
     #------------------------------------------------
     if am_veiculo[l_contador].lclltt is null or
        am_veiculo[l_contador].lcllgt is null then
        #-------------------
        # DESPREZA O VEICULO
        #-------------------
        if m_display then
           if am_veiculo[l_contador].socvclcod = 7688 then
              display 'Veiculo ', am_veiculo[l_contador].srrcoddig, 'Com lat/long null'
           end if
        end if


        continue foreach
     end if

     #------------------------------------------------------------------
     # CALCULA A DISTANCIA ENTRE O LOCAL DO SERVICO E O LOCAL DO VEICULO
     #------------------------------------------------------------------
     let l_distancia = cts18g00(lr_parametro.lclltt,
                                lr_parametro.lcllgt,
                                am_veiculo[l_contador].lclltt,
                                am_veiculo[l_contador].lcllgt)

     if l_distancia <= 0 then  ## quando am_veiculo[l_contador].lcllgt > 0
        if m_display then
           if am_veiculo[l_contador].socvclcod = 7688 then
              display 'veiculo: ', am_veiculo[l_contador].socvclcod
              display 'Distancia: ', l_distancia , ' continue foreach'
           end if
        end if

        continue foreach
     end if

     ## obter eqps do veiculo
     if l_soceqpcod is not null then
        call ctd13g00_dados_eqp(1,l_soceqpcod)
             returning l_res, l_msg, l_eqpacndst, l_eqpimsvlr

        if l_res = 3 then
           let l_msg = l_msg clipped, " veic: ",
                       am_veiculo[l_contador].socvclcod
           display l_msg
           call errorlog(l_msg)
           continue foreach
        end if

        if l_eqpimsvlr is not null and l_eqpimsvlr <> 0 then
           ## se imsvlr da apolice > que do eqp, desprezar veiculo
           if lr_parametro.imsvlr > l_eqpimsvlr then
              if m_display then
                 if am_veiculo[l_contador].socvclcod = 7688 then
                   display 'importancia segurada > que do eqp '
                 end if
              end if
              continue foreach
           end if
        end if

        ## Converte metros p/km.
        let l_eqpacndst_k  = l_eqpacndst / 1000

       if l_eqpacndst_k is not null and l_eqpacndst_k <> 0 then
          ## se dist. do srv > que dist do eqp, desprezar veiculo
          if l_distancia > l_eqpacndst_k then
             if m_display then
                if am_veiculo[l_contador].socvclcod = 7688 then
                  display 'dist do srv > dist eqp'
                end if
             end if
             continue foreach
          end if
       end if

     end if

     #----------------------------------------------------------
     # VERIFICA SE O VEICULO ESTA DENTRO DO LIMITE PARAMETRIZADO
     #----------------------------------------------------------
     if l_distancia > lr_parametro.cidacndst then

        #-----------------------------------
        # SE NAO ESTIVER, DESPREZA O VEICULO
        #-----------------------------------
        if m_display then
           if am_veiculo[l_contador].socvclcod = 7688 then
            display 'l_distancia > lr_parametro.cidacndst'
            display 'l_distancia', l_distancia
            display 'lr_parametro.cidacndst', lr_parametro.cidacndst
           end if
        end if


        continue foreach
     else
        let am_veiculo[l_contador].distancia = l_distancia
     end if

     #--------------------------
     # VERIFICA O MDT DO VEICULO
     #--------------------------
     let l_flg_erro = cts00g03_checa_mdt(3,
                                         am_veiculo[l_contador].socvclcod)

     if l_flg_erro = "S" then
        #--------------------------------------------------
        # SE O MDT ESTIVER COM PROBLEMAS DESPREZA O VEICULO
        #--------------------------------------------------
        if m_display then
           if am_veiculo[l_contador].socvclcod = 7688 then
            display 'l_flg_erro = S retorno cts00g03_checa_mdt'
           end if
        end if
        continue foreach
     end if

     # --VERIFICA OS SINAIS DO VEICULO
     let l_flg_erro = cts00g06_checa_sinal(l_mdtcod, lr_parametro.data_atual)

     if l_flg_erro = "N" then
        # --SE O MDT ESTIVER DESLIGADO/SEM SINAL NO DIA
        let l_msg = " VEICULO ", am_veiculo[l_contador].socvclcod,
                    " NAO POSSUI MOVIMENTO DE MDT"

        #call errorlog(l_msg)
        #display am_veiculo[l_contador].socvclcod,
        #        " MDT SEM SINAL HOJE"
        if m_display then
           if am_veiculo[l_contador].socvclcod = 7688 then
              display 'veiculo sem movimento mdt retorno cts00g06_checa_sinal '
           end if
        end if
        continue foreach
     end if

     #---------------------------------------------------
     # SO PODE ENVIAR PICK-UP P/TECNICO E GUINCHO TECNICO
     #---------------------------------------------------
     if lr_parametro.asitipcod <> 2 and   # TECNICO
        lr_parametro.asitipcod <> 3 then  # GUINCHO TECNICO

        #--------------------------------
        # VERIFICA SE O VEICULO E PICK-UP
        #--------------------------------
        if cts40g13_e_pickup(am_veiculo[l_contador].socvclcod) then
           if m_display then
              if am_veiculo[l_contador].socvclcod = 7688 then
                 display 'eh pickup'
              end if
           end if
           continue foreach
        end if

     end if

     #----------------------------------------------------------
     # VERIFICA SE O VEICULO ESTA SEM SINAL A MAIS DE 20 MINUTOS
     #----------------------------------------------------------
     let l_espera = null
     let l_espera = cts40g03_espera(am_veiculo[l_contador].atldat,
                                    am_veiculo[l_contador].atlhor)

     if l_espera > l_limite then # VEICULO SEM SINAL A MAIS DE 20 MINUTOS
        if m_display then
           if am_veiculo[l_contador].socvclcod = 7688 then
              display ' K70 espera > limite, veiculo sem sinal a mais de 10 minutos'
           end if
        end if


        continue foreach # DESPREZA
     end if

     #----------------------------------------------------------------
     # VERIFICA SE O VEICULO ESTA LIBERADO PARA ACIONAMENTO AUTOMATICO
     #----------------------------------------------------------------
     call ctc00m23_acionamento_auto(l_vcldtbgrpcod,
                                    l_socvcltip,
                                    lr_parametro.asitipcod)
          returning l_msg,l_flag

     if l_msg is not null then
        display "Erro ao consultar gerenciamento de estecialidade: ", l_msg
     else
        if l_flag = 'N' then  # Veiculo nao liberado para acionamento automatico
           display "GER.ESPECIALIDADES NAO PERMITIU O ACIONAMENTO", " GrupoAcn: ", l_vcldtbgrpcod,
                                                                    " Tipo Vcl: ", l_socvcltip,
                                                                    " Assistencia: ", lr_parametro.asitipcod
           continue foreach
        end if
     end if

     #----------------------------------------------------------------
     # Adiciona Veiculo a Lista
     #----------------------------------------------------------------
     let l_contador = l_contador + 1

     if l_contador > 500 then
        let l_msg = "A quantidade de registros superou o limite do array ! Modulo CTS40G13.4GL"
        call errorlog(l_msg)
        exit foreach
     end if

  end foreach

  close c_cts40g13_010

  let l_contador = (l_contador - 1)

  return l_contador

end function

#---------------------------------------#
function cts40g13_ordena_array(l_tamanho)
#---------------------------------------#

  define l_tamanho   integer,
         l_contador1 integer,
         l_contador2 integer

  define lr_veiculo record
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

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_contador1  =  null
        let     l_contador2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_veiculo.*  to  null

  let l_contador1 = null
  let l_contador2 = null

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_veiculo.*  to  null

   # --ORDENA O ARRAY POR ORDEM CRESCENTE DE DISTANCIA
   for l_contador1 = 1 to l_tamanho
      for l_contador2 = l_contador1 + 1 to l_tamanho
         if am_veiculo[l_contador1].distancia > am_veiculo[l_contador2].distancia then

            let lr_veiculo.srrcoddig = am_veiculo[l_contador1].srrcoddig
            let lr_veiculo.socvclcod = am_veiculo[l_contador1].socvclcod
            let lr_veiculo.pstcoddig = am_veiculo[l_contador1].pstcoddig
            let lr_veiculo.lclltt    = am_veiculo[l_contador1].lclltt
            let lr_veiculo.lcllgt    = am_veiculo[l_contador1].lcllgt
            let lr_veiculo.atldat    = am_veiculo[l_contador1].atldat
            let lr_veiculo.atlhor    = am_veiculo[l_contador1].atlhor
            let lr_veiculo.vcllicnum = am_veiculo[l_contador1].vcllicnum
            let lr_veiculo.distancia = am_veiculo[l_contador1].distancia

            let am_veiculo[l_contador1].srrcoddig  = am_veiculo[l_contador2].srrcoddig
            let am_veiculo[l_contador1].socvclcod  = am_veiculo[l_contador2].socvclcod
            let am_veiculo[l_contador1].pstcoddig  = am_veiculo[l_contador2].pstcoddig
            let am_veiculo[l_contador1].lclltt     = am_veiculo[l_contador2].lclltt
            let am_veiculo[l_contador1].lcllgt     = am_veiculo[l_contador2].lcllgt
            let am_veiculo[l_contador1].atldat     = am_veiculo[l_contador2].atldat
            let am_veiculo[l_contador1].atlhor     = am_veiculo[l_contador2].atlhor
            let am_veiculo[l_contador1].vcllicnum  = am_veiculo[l_contador2].vcllicnum
            let am_veiculo[l_contador1].distancia  = am_veiculo[l_contador2].distancia

            let am_veiculo[l_contador2].srrcoddig = lr_veiculo.srrcoddig
            let am_veiculo[l_contador2].socvclcod = lr_veiculo.socvclcod
            let am_veiculo[l_contador2].pstcoddig = lr_veiculo.pstcoddig
            let am_veiculo[l_contador2].lclltt    = lr_veiculo.lclltt
            let am_veiculo[l_contador2].lcllgt    = lr_veiculo.lcllgt
            let am_veiculo[l_contador2].atldat    = lr_veiculo.atldat
            let am_veiculo[l_contador2].atlhor    = lr_veiculo.atlhor
            let am_veiculo[l_contador2].vcllicnum = lr_veiculo.vcllicnum
            let am_veiculo[l_contador2].distancia = lr_veiculo.distancia

         end if
      end for
   end for

end function

#------------------------------------------#
function cts40g13_analise_veic(lr_parametro)
#------------------------------------------#

  define lr_parametro    record
         tamanho         smallint,
         cidnom          like glakcid.cidnom,
         ufdcod          like glakcid.ufdcod,
         atdsrvnum       like datmservico.atdsrvnum,
         atdsrvano       like datmservico.atdsrvano,
         atdhorprg       like datmservico.atdhorprg,
         atdsrvorg       like datmservico.atdsrvorg,
         asitipcod       like datrsrrasi.asitipcod,
         vclcoddig       like datmservico.vclcoddig,
         lclltt_srv      like datmlcl.lclltt,
         lcllgt_srv      like datmlcl.lcllgt,
         cidacndst       like datracncid.cidacndst # --DISTANCIA LIMITE PARAMETRIZADA
  end record

  define l_contador       smallint,
         l_rodizio        smallint,
         l_msg            char(80),
         l_mensagem       char(100),
         l_resultado      smallint,
         l_cod_motivo     smallint,
         l_atende         smallint,
         l_roter_ativa    smallint,
         l_roter_qtd      smallint,
         l_tempo_total    decimal(6,1),
         l_fator          decimal(4,2),
         l_roter_arr      smallint,
         l_roter_xml_veic char(32000),
         l_cidcod         like glakcid.cidcod,
         l_distancia decimal(8,4),
         l_achou_socorrista smallint,
         l_socvclcod_frotex decimal(6,0),
         l_grlinf_frotex like datkgeral.grlinf

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_rodizio        = null
  let l_msg            = null
  let l_mensagem       = null
  let l_resultado      = null
  let l_atende         = null
  let l_cidcod         = null
  let l_roter_ativa    = null
  let l_roter_qtd      = null
  let l_roter_xml_veic = '<VEICULOS>'
  let l_tempo_total    = null
  let l_fator          = null
  let l_roter_arr      = 0
  let l_distancia  =  null
  let l_achou_socorrista  = 0
  let l_socvclcod_frotex = null
  let l_grlinf_frotex    = null

  let l_contador    = 1
  let l_cod_motivo  = 0

  #-------------------------------------
  # VERIFICA SE A ROTERIZACAO ESTA ATIVA
  #-------------------------------------
  let l_roter_ativa = ctx25g05_rota_ativa()

  if lr_parametro.ufdcod <> "RJ" and
     lr_parametro.ufdcod <> "SP" and
     lr_parametro.ufdcod <> "PR" then
     let l_roter_ativa = false
  end if

  #-----------------------------------
  # BUSCA A QTD DE ROTAS PARAMETRIZADA
  #-----------------------------------
  let l_roter_qtd   = ctx25g05_qtde_rotas_ac()

  if l_roter_qtd > 10 then
     let l_roter_qtd = 10 # -> QTD. LIMITE DE VEICULOS A SEREM ROTERIZADOS
  end if

  #-------------------------
  # OBTER O CODIGO DA CIDADE
  #-------------------------
  call cty10g00_obter_cidcod(lr_parametro.cidnom,
                             lr_parametro.ufdcod)

       returning l_resultado,
                 l_mensagem,
                 l_cidcod

  if l_resultado <> 0 then
     if l_resultado <> 1 then
        let l_msg = "Erro na funcao cty10g00_obter_cidcod()"
        call errorlog(l_msg)
        call errorlog(l_mensagem)
        let l_cod_motivo = 3
        initialize am_veiculo to null
     end if
  end if

  if l_cod_motivo = 0 then
     #---------------------------------
     # PERCORRE OS VEICULOS DISPONIVEIS
     #---------------------------------
     for l_contador = 1 to lr_parametro.tamanho
         #------------------------------------------------------
         # VERIFICA SE O SOCORRISTA ATENDE O TIPO DE ASSISTENCIA
         #------------------------------------------------------
         #PSI 251712
         let l_socvclcod_frotex = 0
         initialize l_grlinf_frotex to null

         #PSI 251712 - VERIFICA SE VEÍCULO FAZ PARTE DA FROTA EXTRA
         #SE SIM E FROTEX DESATIVADO, VEÍCULO NÃO RECEBE SERVIÇOS AUTO
         open c_cts40g13_008 using am_veiculo[l_contador].socvclcod
         fetch c_cts40g13_008 into l_socvclcod_frotex

         if sqlca.sqlcode = 0 then

             #VEÍCULO POSSUI EQUIPAMENTO FROTEX
             if l_socvclcod_frotex <> 0 and l_socvclcod_frotex is not null then

                 #VERIFICA SE FROTEX ESTÁ ATIVADO
                 open c_cts40g13_009
                 fetch c_cts40g13_009 into l_grlinf_frotex

                 if sqlca.sqlcode = 0 then
                    #SE FROTEX DESATIVADO, VEÍCULO NÃO PODE RECEBER SERVIÇO AUTO
                    if l_grlinf_frotex == 'N' then

                        display "VEICULO ", am_veiculo[l_contador].socvclcod, " NAO RECEBE SRV AUTO, FROTEX DESATIVADO "

                        close c_cts40g13_008
                        close c_cts40g13_009
                        continue for
                    end if
                 end if

                 close c_cts40g13_009

             end if

         end if

         close c_cts40g13_008

         call cts40g13_ver_assist(am_veiculo[l_contador].srrcoddig,
                                  lr_parametro.asitipcod)
              returning l_resultado,
                        l_atende

         if l_resultado = 0 then
            if l_atende = true then
               #-----------------------------------
               # VERIFICAR O RODIZIO PARA CHAVEIROS
               #-----------------------------------
               if lr_parametro.asitipcod = 4 then
                  #-------------------------------
                  # VERIFICA A SITUACAO DO RODIZIO
                  #-------------------------------
                  call cts40g05_verifica_rodizio(l_cidcod,
                                                 am_veiculo[l_contador].vcllicnum,
                                                 am_veiculo[l_contador].distancia,
                                                 lr_parametro.atdhorprg)
                       returning l_resultado,
                                 l_rodizio

                  if l_resultado <> 0 then
                     let l_cod_motivo = 3 # --ERRO DE ACESSO AO BANCO DE DADOS
                     exit for
                  else
                     if l_rodizio = true then
                        # --VEICULO EM RODIZIO FORA DA DISTANCIA LIMITE
                        let l_cod_motivo = 4
                        continue for
                     else
                        let l_cod_motivo = 0
                        #exit for
                     end if
                  end if

               else
                  let l_cod_motivo = 0
                  #exit for
               end if
            else
               # SOCORRISTA NAO ATENDE A ASSISTENCIA
               let l_cod_motivo = 1
               continue for
            end if
         else
            let l_cod_motivo = 3
            exit for
         end if

         if l_cod_motivo = 0 then

            let l_achou_socorrista = 1

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
                                                am_veiculo[l_contador].lcllgt,
                                                '</X>',
                                                '<Y>',
                                                am_veiculo[l_contador].lclltt,
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
                       ##am_veiculo[l_contador].distancia,
                       l_tempo_total

        if l_contador is null or l_contador = 0 then #ligia 09/01/07
           let l_cod_motivo = 14
           return l_cod_motivo, '','','','','','',''
        else
           let am_veiculo[l_contador].distancia = l_distancia
        end if

        # -> BUSCA O FATOR MAXIMO DE DESVIO DA DISTANCIA EM LINHA RETA P/ROTERIZADA
        let l_fator = ctx25g05_fator_desvio()

        if (am_veiculo[l_contador].distancia > (lr_parametro.cidacndst * l_fator)) then
           let l_cod_motivo = 7
        end if

     end if
  end if

  return l_cod_motivo,
         am_veiculo[l_contador].srrcoddig,
         am_veiculo[l_contador].socvclcod,
         am_veiculo[l_contador].pstcoddig,
         am_veiculo[l_contador].distancia,
         am_veiculo[l_contador].lclltt,
         am_veiculo[l_contador].lcllgt,
         l_tempo_total

end function

#----------------------------------------------#
function cts40g13_obter_msg_motivo(l_cod_motivo)
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

     when 3
        let l_msg_motivo = "ERRO DE ACESSO A BASE DE DADOS."

     when 4
        let l_msg_motivo = "VEIC. EM RODIZIO FORA DA DISTAN. LIMITE."

     when 7
        let l_msg_motivo = "NAO LOCALI. VEIC. DISP. LIMITE PARAMETR."

     when 13
        let l_msg_motivo = "DIVERGENCIA: CAD. EXECOES E LOCA/COND."

     when 14
        let l_msg_motivo = "ERRO NA ROTEIRIZACAO."

  end case

  return l_msg_motivo

end function
