#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTS40G14                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTOMOVEL                  #
#                  BUSCA O PRESTADOR P/ATENDER O SERVICO AUTO VIA INTERNET.   #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/12/2006  Ligia Mattge   PSI205206  ciaempcod                             #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g14_prep smallint

  define am_prestadores  array[200] of record
         dstqtd          decimal(8,4),
         qldgracod       smallint,
         pstcoddig       like datmsrvacp.pstcoddig,
         intsrvrcbflg    like dpaksocor.intsrvrcbflg
  end record

  define am_recusaram    array[10] of integer

  define m_cont_prest    smallint

#-------------------------#
function cts40g14_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select lclltt, ",
                     " lcllgt ",
                " from datkmpacid ",
               " where mpacidcod = ? ",
                 " and lclltt between (? -'0.25') and (? + '0.25') ",
                 " and lcllgt between (? -'0.25') and (? + '0.25') "

  prepare pcts40g14001 from l_sql
  declare ccts40g14001 cursor for pcts40g14001

  let l_sql = " select nomgrr ",
                " from dpaksocor ",
               " where pstcoddig = ? "

  prepare pcts40g14003 from l_sql
  declare ccts40g14003 cursor for pcts40g14003

  let m_cts40g14_prep = true

end function

#------------------------------------------#
function cts40g14_carrega_pres(lr_parametro)
#------------------------------------------#

  define lr_parametro   record
         srv_fnl        smallint,
         asitipcod      like datmservico.asitipcod,
         lclltt_srv     like datmlcl.lclltt,
         lcllgt_srv     like datmlcl.lcllgt,
         atdsrvorg      like datmservico.atdsrvorg,
         atdetpcod      like datmsrvacp.atdetpcod,
         ciaempcod      like datmservico.ciaempcod
  end record

  define l_qldgracod    like dpaksocor.qldgracod,
         l_pstcoddig    like dpaksocor.pstcoddig,
         l_intsrvrcbflg like dpaksocor.intsrvrcbflg,
         l_mpacidcod    like datkmpacid.mpacidcod,
         l_lclltt       like datkmpacid.lclltt,
         l_lcllgt       like datkmpacid.lcllgt,
         l_dstqtd       decimal(8,4),
         l_msg_erro     char(100),
         l_sql          char(600),
         l_resultado    smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_qldgracod    = null
  let l_pstcoddig    = null
  let l_sql          = null
  let l_intsrvrcbflg = null
  let l_mpacidcod    = null
  let l_lclltt       = null
  let l_lcllgt       = null
  let l_dstqtd       = null
  let l_msg_erro     = null

  initialize am_prestadores to null

  let m_cont_prest = 1
  let l_resultado  = 0

  if lr_parametro.atdetpcod <> 2 then # SERVICO RECUSADO
     let l_sql = " select c.pstcoddig, ",
                        " c.mpacidcod, ",
                        " c.qldgracod, ",
                        " c.intsrvrcbflg ",
                   " from dpakdtbpst a, ",
                        " datrassprs b, ",
                        " dpaksocor c,",
                        " dparpstemp d ",
                  " where a.pstcoddig = b.pstcoddig ",
                    " and a.atdfnlnum = ", lr_parametro.srv_fnl,   # NUMERACAO FINAL
                    " and b.pstcoddig = c.pstcoddig ",
                    " and b.asitipcod = ", lr_parametro.asitipcod, # TIPO ASSISTENCIA
                    " and c.qldgracod <> 8 ",
                    " and c.prssitcod = 'A' ",
                    " and c.pstcoddig = d.pstcoddig ",
                    " and d.ciaempcod = ", lr_parametro.ciaempcod ##psi 205206
  else
     let l_sql = " select c.pstcoddig, ",
                        " c.mpacidcod, ",
                        " c.qldgracod, ",
                        " c.intsrvrcbflg ",
                   " from datrassprs b, ",
                        " dpaksocor c, ",
                        " dparpstemp d ",
                  " where b.pstcoddig = c.pstcoddig ",
                    " and b.asitipcod = ", lr_parametro.asitipcod, # TIPO ASSISTENCIA
                    " and c.qldgracod <> 8 ",
                    " and c.prssitcod = 'A' ",
                    " and c.pstcoddig = d.pstcoddig ",
                    " and d.ciaempcod = ", lr_parametro.ciaempcod ##psi 205206
  end if

  prepare pcts40g14002 from l_sql
  declare ccts40g14002 cursor for pcts40g14002

  # --BUSCA OS PRESTADORES QUE ATENDEM O SERVICO
  open ccts40g14002
  foreach ccts40g14002 into l_pstcoddig,
                            l_mpacidcod,
                            l_qldgracod,
                            l_intsrvrcbflg

     # --NAS ORIGENS 2 COM ASSISTENCIA <> TAXI E ORIGEM 3 NAO E NECESSARIO
     # --CALCULAR A DISTANCIA ENTRE O LOCAL
     # --DO SERVICO E A CIDADE DO PRESTADOR, SENDO ASSIM SETA DISTANCIA = 1 PARA
     # --PODER ORDENAR O ARRAY DE PRESTADORES

     if lr_parametro.atdsrvorg = 1 or lr_parametro.atdsrvorg = 4 or
        lr_parametro.atdsrvorg = 5 or lr_parametro.atdsrvorg = 6 or
        lr_parametro.atdsrvorg = 7 or lr_parametro.atdsrvorg = 17 or

        (lr_parametro.atdsrvorg = 2 and lr_parametro.asitipcod = 5) then

        # --VERIFICA SE O PRESTADOR ESTA DENTRO DA REGIAO LIMITE DO SERVICO
        open ccts40g14001 using l_mpacidcod,
                                lr_parametro.lclltt_srv,
                                lr_parametro.lclltt_srv,
                                lr_parametro.lcllgt_srv,
                                lr_parametro.lcllgt_srv

        whenever error continue
        fetch ccts40g14001 into l_lclltt,
                                l_lcllgt
        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              # --PRESTADOR ESTA FORA DA AREA LIMITE
              close ccts40g14001
              continue foreach
           else
              let l_msg_erro = "Erro SELECT ccts40g14001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
              call errorlog(l_msg_erro)
              let l_resultado = 2
              close ccts40g14001
              exit foreach
           end if
        end if

        close ccts40g14001

        # --CALCULA A DISTANCIA ENTRE LOCAL DO SERVICO E A CIDADE DO PRESTADOR
        let l_dstqtd = cts18g00(lr_parametro.lclltt_srv,
                                lr_parametro.lcllgt_srv,
                                l_lclltt,
                                l_lcllgt)
     else
        let l_dstqtd = 1
     end if

     # --ARMAZENA OS DADOS NO ARRAY DE PRESTADOR
     let am_prestadores[m_cont_prest].dstqtd       = l_dstqtd
     let am_prestadores[m_cont_prest].qldgracod    = l_qldgracod
     let am_prestadores[m_cont_prest].pstcoddig    = l_pstcoddig
     let am_prestadores[m_cont_prest].intsrvrcbflg = l_intsrvrcbflg

     let m_cont_prest = m_cont_prest + 1

     if m_cont_prest > 200 then
        let l_msg_erro = "Array de Prestadores c/limite superado no modulo CTS40G14.4GL"
        call errorlog(l_msg_erro)
        exit foreach
     end if

  end foreach
  close ccts40g14002

  let m_cont_prest = (m_cont_prest - 1)

  if m_cont_prest > 0 then
     call cts40g14_ordena_prest(m_cont_prest)
  end if

  return l_resultado

end function

#---------------------------------------#
function cts40g14_ordena_prest(l_tamanho)
#---------------------------------------#

  define l_tamanho      integer,
         l_contador1    integer,
         l_contador2    integer

  define lr_prestadores record
         dstqtd         decimal(8,4),
         qldgracod      smallint,
         pstcoddig      like datmsrvacp.pstcoddig,
         intsrvrcbflg   like dpaksocor.intsrvrcbflg
  end record

  # --ORDENA O ARRAY DOS PRESTADORES POR ORDEM CRESCENTE DE DISTANCIA

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_contador1  =  null
        let     l_contador2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_prestadores.*  to  null

  for l_contador1 = 1 to l_tamanho
     for l_contador2 = l_contador1 + 1 to l_tamanho
        if am_prestadores[l_contador1].dstqtd > am_prestadores[l_contador2].dstqtd then

           let lr_prestadores.dstqtd                    = am_prestadores[l_contador1].dstqtd
           let lr_prestadores.qldgracod                 = am_prestadores[l_contador1].qldgracod
           let lr_prestadores.pstcoddig                 = am_prestadores[l_contador1].pstcoddig
           let lr_prestadores.intsrvrcbflg              = am_prestadores[l_contador1].intsrvrcbflg

           let am_prestadores[l_contador1].dstqtd       = am_prestadores[l_contador2].dstqtd
           let am_prestadores[l_contador1].qldgracod    = am_prestadores[l_contador2].qldgracod
           let am_prestadores[l_contador1].pstcoddig    = am_prestadores[l_contador2].pstcoddig
           let am_prestadores[l_contador1].intsrvrcbflg = am_prestadores[l_contador2].intsrvrcbflg

           let am_prestadores[l_contador2].dstqtd       = lr_prestadores.dstqtd
           let am_prestadores[l_contador2].qldgracod    = lr_prestadores.qldgracod
           let am_prestadores[l_contador2].pstcoddig    = lr_prestadores.pstcoddig
           let am_prestadores[l_contador2].intsrvrcbflg = lr_prestadores.intsrvrcbflg

        end if
     end for
  end for

end function

#---------------------------------------------#
function cts40g14_obter_prestador(lr_parametro)
#---------------------------------------------#

  define lr_parametro    record
         lclltt_srv      like datmlcl.lclltt,         # LATITUDE DO SERVICO
         lcllgt_srv      like datmlcl.lcllgt,         # LONGITUDE DO SERVICO
         atdsrvnum       like datmservico.atdsrvnum,  # NUMERO DO SERVICO
         atdsrvano       like datmservico.atdsrvano,  # ANO DO SERVICO
         asitipcod       like datmservico.asitipcod,  # COD. TIPO DE ASSISTENCIA
         atdsrvorg       like datmservico.atdsrvorg,  # ORIGEM DO SERVICO
         ciaempcod       like datmservico.ciaempcod   # COD. DA EMPRESA DO SERV.
  end record

  define l_cod_motivo    smallint,
         l_msg_motivo    like datmservico.acnnaomtv,
         l_pstcoddig     decimal(6,0),
         l_busca_prest   smallint,
         l_status        integer,
         l_msg           char(100),
         l_atdetpcod     like datmsrvint.atdetpcod,
         l_nomgrr        like dpaksocor.nomgrr,
         l_atdsrvnum_org like datmservico.atdsrvnum,
         l_atdsrvano_org like datmservico.atdsrvano,
         l_atdfnlflg     like datmservico.atdfnlflg,
         l_distancia     decimal(8,4),
         l_etapa         smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_cod_motivo  =  null
        let     l_msg_motivo  =  null
        let     l_pstcoddig  =  null
        let     l_busca_prest  =  null
        let     l_status  =  null
        let     l_msg  =  null
        let     l_atdetpcod  =  null
        let     l_nomgrr  =  null
        let     l_atdsrvnum_org  =  null
        let     l_atdsrvano_org  =  null
        let     l_atdfnlflg  =  null
        let     l_distancia  =  null
        let     l_etapa  =  null

  let l_cod_motivo    = 0
  let l_busca_prest   = true

  if m_cts40g14_prep is null or
     m_cts40g14_prep <> true then
     call cts40g14_prepare()
  end if

  # --VERIFICA SE O SERVICO ESTAVA RECUSADO ANTERIORMENTE
  call cts40g16_pnletp_srvint(lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano)
       returning l_status,
                 l_atdetpcod

  if l_status = 0 then
     if l_atdetpcod is not null then
        if l_atdetpcod = 2 then # SERVICO RECUSADO NO PORTAL

           if (lr_parametro.atdsrvorg = 2 and lr_parametro.asitipcod <> 5) or
               lr_parametro.atdsrvorg = 3 then
               let l_etapa = 43
           else
               let l_etapa = 4
           end if

           #---------------------------------------------
           # BUSCA OS PRESTADORES QUE RECUSARAM O SERVICO
           #---------------------------------------------
           initialize am_recusaram to null
           call cts40g17_lista_prest(lr_parametro.atdsrvnum,
                                     lr_parametro.atdsrvano,
                                     l_etapa) # ETAPA - SERVICO AUTO ACIONADO

                returning am_recusaram[1],
                          am_recusaram[2],
                          am_recusaram[3],
                          am_recusaram[4],
                          am_recusaram[5],
                          am_recusaram[6],
                          am_recusaram[7],
                          am_recusaram[8],
                          am_recusaram[9],
                          am_recusaram[10]
        end if
     else

        let l_atdetpcod = 1 # SERVICO LIBERADO, ESPERANDO ACIONAMENTO

        ##------------------------------
        # VERIFICA SE O SERVICO E APOIO
        #------------------------------
        let l_status = cts37g00_existeServicoApoio(lr_parametro.atdsrvnum,
                                                   lr_parametro.atdsrvano)

        if l_status = 3 then # SERVICO DE APOIO
           #-------------------------
           # BUSCA O SERVICO ORIGINAL
           #-------------------------
           let l_atdsrvnum_org = null
           let l_atdsrvano_org = null
           call cts37g00_buscaServicoOriginal(lr_parametro.atdsrvnum,
                                              lr_parametro.atdsrvano)

                returning l_status,
                          l_atdsrvnum_org, # NUMERO SERVICO ORIGINAL
                          l_atdsrvano_org  # ANO SERVICO ORIGINAL

           if l_status <> 0 then
              call errorlog("Erro ao chamar a funcao cts37g00_buscaServicoOriginal()")
              let l_cod_motivo = 3
           end if

           # --VERIFICA SE O SERVICO ORIGINAL ESTAVA RECUSADO ANTERIORMENTE
           call cts40g16_pnletp_srvint(l_atdsrvnum_org,
                                       l_atdsrvano_org)
                returning l_status,
                          l_atdetpcod

           if l_atdetpcod = 2 then

              ## VERIFICA SE O SRV ORG JA ESTA NO RADIO
              call cts10g06_dados_servicos(4,l_atdsrvnum_org, l_atdsrvano_org)
                   returning l_status, l_msg, l_atdfnlflg

              ## SE O SRV ORG JA ESTIVER NO RADIO ENVIA APOIO P/RADIO TAMBEM
              if l_atdfnlflg = "N" then
                 let l_cod_motivo = 7
                 let l_msg_motivo = "NAO ENCONTROU PRESTADOR DISPONIVEL"
              end if

           end if

           if l_cod_motivo = 0 then
              #-------------------------------------------------
              # BUSCA O PRESTADOR QUE RECEBEU O SERVICO ORIGINAL
              #-------------------------------------------------
              let l_pstcoddig = null
              call cts40g17_unico_prest(l_atdsrvnum_org,
                                        l_atdsrvano_org,
                                        4) # ETAPA - SERVICO AUTO ACIONADO

                   returning l_status,
                             l_pstcoddig

              if l_status <> 0 then
                 if l_status = 100 then
                    let l_pstcoddig  = null
                    let l_cod_motivo = 0
                 else
                    let l_msg = "ERRO: ", l_status, " ao chamar a funcao cts40g17_unico_prest()"
                    call errorlog(l_msg)
                    let l_cod_motivo = 3
                 end if
              end if

              if l_cod_motivo = 0 then
                 if l_pstcoddig is null then
                    let l_cod_motivo = 10 # -> SERVICO ORIGINAL AINDA NAO FOI ACIONADO
                    let l_msg_motivo = "SERVICO ORIGINAL AINDA NAO FOI ACIONADO"
                 else
                    let l_busca_prest = false # NAO BUSCA UM PRESTADOR, POIS JA FOI ENCONTRADO
                    let l_cod_motivo  = 0  # -> OK ENCONTROU PRESTADOR
                 end if
              end if

           end if

           if l_cod_motivo = 0 then
              #------------------------------------
              # BUSCA O NOME DE GUERRA DO PRESTADOR
              #------------------------------------
              open ccts40g14003 using l_pstcoddig
              whenever error continue
              fetch ccts40g14003 into l_nomgrr
              whenever error stop

              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = notfound then
                    let l_msg = "Nao encontrou o nome de guerra p/o prestador: ",
                                l_pstcoddig
                    call errorlog(l_msg)
                 else
                    let l_msg = "Erro SELECT cbdbsa069002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    call errorlog(l_msg)
                    let l_cod_motivo = 3
                 end if
              end if

              close ccts40g14003
           end if
        end if
     end if
  else
     let l_cod_motivo = 3
     let l_msg_motivo = "ERRO: ", l_status, " na funcao cts40g16_pnletp_srvint()"
     call errorlog(l_msg_motivo)
     let l_msg_motivo = "ERRO DE ACESSO AO BANCO DE DADOS"
  end if

  if l_busca_prest = true then
     if l_cod_motivo = 0 then
        call cts40g14_analisa_prestador(lr_parametro.lclltt_srv,
                                        lr_parametro.lcllgt_srv,
                                        lr_parametro.atdsrvnum,
                                        lr_parametro.atdsrvano,
                                        lr_parametro.asitipcod,
                                        lr_parametro.atdsrvorg,
                                        l_atdetpcod,
                                        l_pstcoddig, # PRESTADOR QUE RECUSOU O SERVICO
                                        lr_parametro.ciaempcod) #psi 205206
             returning l_cod_motivo,
                       l_msg_motivo,
                       l_pstcoddig,
                       l_distancia

        if l_pstcoddig is not null then
           #------------------------------------
           # BUSCA O NOME DE GUERRA DO PRESTADOR
           #------------------------------------
           open ccts40g14003 using l_pstcoddig
           whenever error continue
           fetch ccts40g14003 into l_nomgrr
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = notfound then
                 let l_nomgrr = null
                 let l_msg    = "Nao encontrou o nome de guerra do prestador: ",
                                l_pstcoddig
                 call errorlog(l_msg)
              else
                 let l_msg = "Erro SELECT ccts40g14003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                 call errorlog(l_msg)
                 let l_msg = "cts40g14_obter_prestador() / ", l_pstcoddig
                 call errorlog(l_msg)
                 let l_cod_motivo = 3
                 let l_msg_motivo = "ERRO DE ACESSO AO BANCO DE DADOS"
              end if
           end if

           close ccts40g14003

        end if
     end if
  end if

  return l_cod_motivo,
         l_msg_motivo,
         l_pstcoddig,
         l_nomgrr,
         l_distancia

end function

#-----------------------------------------------#
function cts40g14_analisa_prestador(lr_parametro)
#-----------------------------------------------#

  define lr_parametro     record
         lclltt_srv       like datmlcl.lclltt,
         lcllgt_srv       like datmlcl.lcllgt,
         atdsrvnum        like datmservico.atdsrvnum,
         atdsrvano        like datmservico.atdsrvano,
         asitipcod        like datmservico.asitipcod,
         atdsrvorg        like datmservico.atdsrvorg,
         atdetpcod        like datmsrvint.atdetpcod,
         pstcoddig        decimal(6,0),
         ciaempcod        like datmservico.ciaempcod #psi205206
  end record

  define l_mensagem       char(100),
         l_status         smallint,
         l_pstcoddig      like datmsrvacp.pstcoddig,
         l_nomgrr         like dpaksocor.nomgrr,
         l_cod_motivo     smallint,
         l_ind            smallint,
         l_cont           smallint,
         l_msg_motivo     char(100),
         l_srv_char       char(10),
         l_srv_fnl        smallint,
         l_flgdesp        smallint,
         l_srv_tam        smallint,
         l_socntzgrpcod   like datksocntz.socntzgrpcod


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_mensagem  =  null
        let     l_status  =  null
        let     l_pstcoddig  =  null
        let     l_nomgrr  =  null
        let     l_cod_motivo  =  null
        let     l_ind  =  null
        let     l_cont  =  null
        let     l_msg_motivo  =  null
        let     l_srv_char  =  null
        let     l_srv_fnl  =  null
        let     l_flgdesp  =  null
        let     l_srv_tam  =  null
        let     l_socntzgrpcod  =  null

  let l_ind           = 1
  let l_cod_motivo    = 0

  # --OBTER O ULTIMO DIGITO DO SERVICO
  let l_srv_char = lr_parametro.atdsrvnum
  let l_srv_tam  = length(l_srv_char)
  let l_srv_fnl  = l_srv_char[l_srv_tam, l_srv_tam]

  # --CARREGA OS PRESTADORES DISPONIVEIS
  let l_cod_motivo = cts40g14_carrega_pres(l_srv_fnl,
                                           lr_parametro.asitipcod,
                                           lr_parametro.lclltt_srv,
                                           lr_parametro.lcllgt_srv,
                                           lr_parametro.atdsrvorg,
                                           lr_parametro.atdetpcod,
                                           lr_parametro.ciaempcod) #psi205206
  if l_cod_motivo = 0 then
     if m_cont_prest = 0 then
        let l_cod_motivo = 8
        let l_msg_motivo = "NAO LOCALIZOU PRESTAD. PARAMETR. P/SERV."
        initialize am_prestadores to null
     else
        # --PESQUISA DENTRO DOS PRESTADORES DISPONIVEIS
        for l_ind = 1 to m_cont_prest


           if lr_parametro.atdetpcod = 2 then # SERVICO RECUSADO ANTERIORMENTE

              let l_flgdesp = false

              # --VERIFICA SE O PRESTADOR ENCONTRADO E O MESMO QUE RECUSOU O SERVICO
              # --OS PRESTADORES QUE RECUSARAM O SERVICO ESTAO NO ARRAY am_recusaram

              for l_cont = 1 to 10 # PERCORRE O ARRAY DE RECUSADOS
                  if am_recusaram[l_cont] is not null then
                     if am_recusaram[l_cont] = am_prestadores[l_ind].pstcoddig then
                        let l_cod_motivo = 7
                        let l_msg_motivo = "NAO ENCONTROU PRESTADOR DISPONIVEL"
                        let l_flgdesp    = true # DESPREZA O PRESTADOR
                        exit for
                     end if
                  else
                     let l_flgdesp = false
                     exit for
                  end if
              end for

              if l_flgdesp = true then
                 # DESPREZA O PRESTADOR
                 continue for
              end if
           end if

           # --VERIFICA COMO O PRESTADOR RECEBE O SERVICO
           if am_prestadores[l_ind].intsrvrcbflg = "1" then
              # --RECEBE VIA INTERNET
              # --VERIFICA SE O PRESTADOR ESTA LOGADO NO PORTAL DE NEGOCIOS
              # --PARA ORIGEM 2(ASSISTENCIA PASSAG.) E ASSISTENCIA NAO E 5-TAXI
              #   OU origem 3 (HOSPEDAGEM) ENVIAMOS OUTRO PARAMETRO
              if ((lr_parametro.atdsrvorg = 3) or
                  (lr_parametro.atdsrvorg = 2 and lr_parametro.asitipcod <> 5))
                 then
                 let l_status = fissc101_prestador_sessao_ativa(
                                  am_prestadores[l_ind].pstcoddig,
                                  "AGTONLINE")
              else
                 let l_status = fissc101_prestador_sessao_ativa(
                                  am_prestadores[l_ind].pstcoddig,
                                  "PSRONLINE")
              end if
              if l_status then
                 let l_cod_motivo = 0
                 let l_msg_motivo = null
              else
                 open ccts40g14003 using am_prestadores[l_ind].pstcoddig
                 whenever error continue
                 fetch ccts40g14003 into l_nomgrr
                 whenever error stop
                 close ccts40g14003

                 let l_cod_motivo = 12
                 let l_msg_motivo = " ", am_prestadores[l_ind].pstcoddig using "<<<<<<", "-", l_nomgrr[1,10]," DESCONECTADO DO PORTAL"
                 initialize am_prestadores to null
              end if
           else
              # --PRESTADOR ATENDE FAX
              let l_cod_motivo = 11
              let l_msg_motivo = "PRESTADOR RECEBE POR FAX."
           end if

           exit for # O PRIMEIRO PRESTADOR ENCONTRADO E O ESCOLHIDO

        end for
     end if
  end if

  return l_cod_motivo,
         l_msg_motivo,
         am_prestadores[l_ind].pstcoddig,
         am_prestadores[l_ind].dstqtd

end function
