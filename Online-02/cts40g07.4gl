#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTS40G07                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  BUSCA O PRESTADOR PARA ATENDER O SERVICO RE VIA INTERNET.  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 09/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 09/03/2010 Adriano Santos  PSI 242853 Substituir relacionamento GRP NTZ com #
#                                       PST por NTZ                           #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g07_prep smallint

  define am_recusaram    array[10] of integer

  define am_prestadores  array[200] of record
         dstqtd          decimal(8,4),
         qldgracod       smallint,
         pstcoddig       like dpaksocor.pstcoddig,
         intsrvrcbflg    like dpaksocor.intsrvrcbflg
  end record

  define m_cont_prest    smallint

#-------------------------#
function cts40g07_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select lclltt, ",
                     " lcllgt ",
                " from datkmpacid ",
               " where mpacidcod = ? ",
                 " and lclltt between (? -2) and (? + 2) ",
                 " and lcllgt between (? -2) and (? + 2) "

  prepare pcts40g07001 from l_sql
  declare ccts40g07001 cursor for pcts40g07001

  let l_sql = " select nomgrr ",
                " from dpaksocor ",
               " where pstcoddig = ? "

  prepare pcts40g07003 from l_sql
  declare ccts40g07003 cursor for pcts40g07003

  let m_cts40g07_prep = true

end function

#------------------------------------------#
function cts40g07_carrega_pres(lr_parametro)
#------------------------------------------#

  define lr_parametro   record
         srv_fnl        smallint,
         socntzcod      like dparpstntz.socntzcod, # PSI 242853
         lclltt_srv     like datmlcl.lclltt,
         lcllgt_srv     like datmlcl.lcllgt,
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
         l_sql          char(500),
         l_resultado    smallint

  # --INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_qldgracod  =  null
        let     l_pstcoddig  =  null
        let     l_intsrvrcbflg  =  null
        let     l_mpacidcod  =  null
        let     l_lclltt  =  null
        let     l_lcllgt  =  null
        let     l_dstqtd  =  null
        let     l_msg_erro  =  null
        let     l_sql  =  null
        let     l_resultado  =  null

  initialize am_prestadores to null

  let m_cont_prest   = 1
  let l_resultado    = 0

  if lr_parametro.atdetpcod = 2 then # RECUSADO
     let l_sql = " select c.pstcoddig, ",
                        " c.mpacidcod, ",
                        " c.qldgracod, ",
                        " c.intsrvrcbflg ",
                   " from dparpstntz b, ", # PSI 242853
                        " dpaksocor c, ",
                        " dparpstemp d ", 
                  " where b.pstcoddig = c.pstcoddig ",
                    " and b.socntzcod = ", lr_parametro.socntzcod, # NATUREZA PSI 242853
                    " and c.qldgracod <> 8 ",
                    " and c.prssitcod = 'A' ",
                    " and c.pstcoddig = d.pstcoddig ",
                    " and d.ciaempcod = ", lr_parametro.ciaempcod
  else
     let l_sql = " select c.pstcoddig, ",
                        " c.mpacidcod, ",
                        " c.qldgracod, ",
                        " c.intsrvrcbflg ",
                   " from dpakdtbpst a, ",
                        " dparpstntz b, ", # PSI 242853
                        " dpaksocor c, ",
                        " dparpstemp d ",
                  " where a.pstcoddig = b.pstcoddig ",
                    " and a.atdfnlnum = ", lr_parametro.srv_fnl, # NUMERO FINAL SERVICO
                    " and b.pstcoddig = c.pstcoddig ",
                    " and b.socntzcod = ", lr_parametro.socntzcod, # NATUREZA PSI 242853
                    " and c.qldgracod <> 8 ",
                    " and c.prssitcod = 'A' ",
                    " and c.pstcoddig = d.pstcoddig ",
                    " and d.ciaempcod = ", lr_parametro.ciaempcod
  end if

  prepare pcts40g07002 from l_sql
  declare ccts40g07002 cursor for pcts40g07002

  # --BUSCA OS PRESTADORES QUE ATENDEM O SERVICO
  open ccts40g07002
  foreach ccts40g07002 into l_pstcoddig,
                            l_mpacidcod,
                            l_qldgracod,
                            l_intsrvrcbflg

     # --VERIFICA SE O PRESTADOR ESTA DENTRO DA REGIAO LIMITE DO SERVICO
     open ccts40g07001 using l_mpacidcod,
                             lr_parametro.lclltt_srv,
                             lr_parametro.lclltt_srv,
                             lr_parametro.lcllgt_srv,
                             lr_parametro.lcllgt_srv

     whenever error continue
     fetch ccts40g07001 into l_lclltt,
                             l_lcllgt
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           close ccts40g07001
           # --PRESTADOR ESTA FORA DA AREA LIMITE
           continue foreach
        else
           let l_msg_erro = "Erro SELECT ccts40g07001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           call errorlog(l_msg_erro)
           let l_resultado = 2
           close ccts40g07001
           exit foreach
        end if
     end if

     close ccts40g07001

      # --CALCULA A DISTANCIA ENTRE LOCAL DO SERVICO E A CIDADE DO PRESTADOR
      let l_dstqtd = cts18g00(lr_parametro.lclltt_srv,
                              lr_parametro.lcllgt_srv,
                              l_lclltt,
                              l_lcllgt)

      # --ARMAZENA OS DADOS NO ARRAY DE PRESTADOR
      let am_prestadores[m_cont_prest].dstqtd       = l_dstqtd
      let am_prestadores[m_cont_prest].qldgracod    = l_qldgracod
      let am_prestadores[m_cont_prest].pstcoddig    = l_pstcoddig
      let am_prestadores[m_cont_prest].intsrvrcbflg = l_intsrvrcbflg

      let m_cont_prest = m_cont_prest + 1

       if m_cont_prest > 200 then
          let l_msg_erro = "Array de Prestadores c/limite superado no modulo CTS40G07.4GL"
          call errorlog(l_msg_erro)
          exit foreach
       end if

  end foreach
  close ccts40g07002

  let m_cont_prest = m_cont_prest - 1

  if m_cont_prest > 0 then
     call cts40g07_ordena_prest(m_cont_prest)
  end if

  return l_resultado

end function

#---------------------------------------#
function cts40g07_ordena_prest(l_tamanho)
#---------------------------------------#

  define l_tamanho      integer,
         l_contador1    integer,
         l_contador2    integer

  define lr_prestadores record
         dstqtd         decimal(8,4),
         qldgracod      smallint,
         pstcoddig      like dpaksocor.pstcoddig,
         intsrvrcbflg   like dpaksocor.intsrvrcbflg
  end record

  # --INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_contador1  =  null
        let     l_contador2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_prestadores.*  to  null

  initialize lr_prestadores to null

  let l_contador1 = 0
  let l_contador2 = 0

  # --ORDENA O ARRAY DOS PRESTADORES POR ORDEM CRESCENTE DE DISTANCIA
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
function cts40g07_obter_prestador(lr_parametro)
#---------------------------------------------#

  define lr_parametro  record
         lclltt_srv    like datmlcl.lclltt,
         lcllgt_srv    like datmlcl.lcllgt,
         atdsrvnum     like datmservico.atdsrvnum,
         atdsrvano     like datmservico.atdsrvano,
         ciaempcod     like datmservico.ciaempcod
  end record

  define l_cod_motivo  smallint,
         l_msg_motivo  like datmservico.acnnaomtv,
         l_status      integer,
         l_atdetpcod   like datmsrvacp.atdetpcod,
         l_pstcoddig   like dpaksocor.pstcoddig


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_cod_motivo  =  null
        let     l_msg_motivo  =  null
        let     l_status  =  null
        let     l_atdetpcod  =  null
        let     l_pstcoddig  =  null

  if m_cts40g07_prep is null or
     m_cts40g07_prep <> true then
     call cts40g07_prepare()
  end if

  # --VERIFICA SE O SERVICO ESTAVA RECUSADO ANTERIORMENTE
  call cts40g16_pnletp_srvint(lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano)
       returning l_status,
                 l_atdetpcod

  if l_status = 0 then
     if l_atdetpcod is not null then
        if l_atdetpcod = 2 then # SERVICO RECUSADO NO PORTAL
           #---------------------------------------------
           # BUSCA OS PRESTADORES QUE RECUSARAM O SERVICO
           #---------------------------------------------
           let l_cod_motivo = 0
           initialize am_recusaram to null
           call cts40g17_lista_prest(lr_parametro.atdsrvnum,
                                     lr_parametro.atdsrvano,
                                     3) # ETAPA - SERVICO RE ACIONADO

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
        let l_cod_motivo = 0
        let l_atdetpcod = 1 # SERVICO LIBERADO, ESPERANDO ACIONAMENTO
     end if
  else
     let l_cod_motivo = 3
     let l_msg_motivo = "ERRO DE ACESSO AO BANCO DE DADOS"
  end if

  if l_cod_motivo = 0 then
     call cts40g07_analisa_prestador(lr_parametro.lclltt_srv,
                                     lr_parametro.lcllgt_srv,
                                     lr_parametro.atdsrvnum,
                                     lr_parametro.atdsrvano,
                                     l_atdetpcod,
                                     l_pstcoddig,
                                     lr_parametro.ciaempcod)
          returning l_cod_motivo,
                    l_msg_motivo,
                    l_pstcoddig
  end if

  return l_cod_motivo, l_msg_motivo, l_pstcoddig

end function

#-----------------------------------------#
function cts40g07_grp_nat_srv(lr_parametro)
#-----------------------------------------#

  define lr_parametro     record
         atdsrvnum        like datmservico.atdsrvnum,
         atdsrvano        like datmservico.atdsrvano
  end record

  define l_resultado      smallint,
         l_orig_socntzcod like datmsrvre.socntzcod,
         l_orig_espcod    like datmsrvre.espcod,
         l_socntzdes      like datksocntz.socntzdes,
         l_socntzgrpcod   like datksocntz.socntzgrpcod,
         l_mensagem       char(100)

  # --INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_resultado  =  null
        let     l_orig_socntzcod  =  null
        let     l_orig_espcod  =  null
        let     l_socntzdes  =  null
        let     l_socntzgrpcod  =  null
        let     l_mensagem  =  null

  let l_resultado      = 0

  # --OBTER CODIGO DA NATUREZA E O CODIGO DA ESPECIALIDADE DO SERVICO ORIGINAL (datmsrvre)
  call cts40g01_obter_codnat_codesp(lr_parametro.atdsrvnum,
                                    lr_parametro.atdsrvano)
       returning l_resultado,
                 l_mensagem,
                 l_orig_socntzcod,
                 l_orig_espcod

  if l_resultado <> 0 then
     if l_resultado <> 1 then
        let l_resultado = 3
        call errorlog(l_mensagem)
     end if
  else

     let l_resultado = 0

     # --OBTER O GRUPO DA NATUREZA DO SERVICO
     call ctc16m03_inf_natureza(l_orig_socntzcod,"A")

          returning l_resultado,
                    l_mensagem,
                    l_socntzdes,
                    l_socntzgrpcod

     if l_resultado <> 1 then
        if l_resultado <> 2 then
           let l_resultado = 3
           call errorlog(l_mensagem)
        end if
     else
        let l_resultado = 0
     end if

  end if

  return l_resultado,
         l_socntzgrpcod

end function

#-----------------------------------------------#
function cts40g07_analisa_prestador(lr_parametro)
#-----------------------------------------------#

  define lr_parametro     record
         lclltt_srv       like datmlcl.lclltt,
         lcllgt_srv       like datmlcl.lcllgt,
         atdsrvnum        like datmservico.atdsrvnum,
         atdsrvano        like datmservico.atdsrvano,
         atdetpcod        like datmsrvint.atdetpcod,
         pstcoddig        decimal(6,0), # PRESTADOR QUE RECUSOU O SERVICO ANTERIOR
         ciaempcod        like datmservico.ciaempcod
  end record

  define l_mensagem       char(100),
         l_cod_motivo     smallint,
         l_msg_motivo     char(100),
         l_srv_char       char(10),
         l_status         smallint,
         l_srv_fnl        smallint,
         l_cont           smallint,
         l_pstcoddig      like datmsrvacp.pstcoddig,
         l_atdetpcod      like datmsrvint.atdetpcod,
         l_ind            smallint,
         l_flgdesp        smallint,
         l_srv_tam        smallint,
         l_socntzgrpcod   like datksocntz.socntzgrpcod,
         l_nomgrr         like dpaksocor.nomgrr,
         l_resultado      smallint, # PSI 252853
         l_orig_socntzcod like datmsrvre.socntzcod,
         l_orig_espcod    like datmsrvre.espcod
  
  # --INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_mensagem  =  null
        let     l_cod_motivo  =  null
        let     l_msg_motivo  =  null
        let     l_srv_char  =  null
        let     l_status  =  null
        let     l_srv_fnl  =  null
        let     l_cont  =  null
        let     l_pstcoddig  =  null
        let     l_atdetpcod  =  null
        let     l_ind  =  null
        let     l_flgdesp  =  null
        let     l_srv_tam  =  null
        let     l_socntzgrpcod  =  null
        let     l_nomgrr  =  null   
        let     l_resultado  =  null  # PSI 252853    
        let     l_orig_socntzcod  =  null
        let     l_orig_espcod  =  null
        
  let l_cod_motivo     = 0
  let l_ind            = 1

  # --OBTER O ULTIMO DIGITO DO SERVICO
  let l_srv_char = lr_parametro.atdsrvnum
  let l_srv_tam  = length(l_srv_char)
  let l_srv_fnl  = l_srv_char[l_srv_tam, l_srv_tam]

  ## --OBTER O GRUPO DO SERVICO
  #call cts40g07_grp_nat_srv(lr_parametro.atdsrvnum,
  #                          lr_parametro.atdsrvano)
  #
  #     returning l_cod_motivo,
  #               l_socntzgrpcod

  # --OBTER CODIGO DA NATUREZA E O CODIGO DA ESPECIALIDADE DO SERVICO ORIGINAL (datmsrvre)
  call cts40g01_obter_codnat_codesp(lr_parametro.atdsrvnum,
                                    lr_parametro.atdsrvano)
       returning l_resultado,
                 l_mensagem,
                 l_orig_socntzcod,
                 l_orig_espcod
  
  #if l_cod_motivo = 0 then
  #   # --CARREGA OS PRESTADORES DISPONIVEIS
  #   let l_cod_motivo =  cts40g07_carrega_pres(l_srv_fnl,
  #                                             l_socntzgrpcod,
  #                                             lr_parametro.lclltt_srv,
  #                                             lr_parametro.lcllgt_srv,
  #                                             lr_parametro.atdetpcod,
  #                                             lr_parametro.ciaempcod)
  #end if
  
  if l_resultado = 0 then
     # --CARREGA OS PRESTADORES DISPONIVEIS
     let l_cod_motivo =  cts40g07_carrega_pres(l_srv_fnl,
                                               l_orig_socntzcod,
                                               lr_parametro.lclltt_srv,
                                               lr_parametro.lcllgt_srv,
                                               lr_parametro.atdetpcod,
                                               lr_parametro.ciaempcod)
  end if

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
              if fissc101_prestador_sessao_ativa(am_prestadores[l_ind].pstcoddig,
                                                 "PSRONLINE") then
                 let l_cod_motivo = 0
                 let l_msg_motivo = null
              else
                 let l_cod_motivo = 12
                 let l_nomgrr = null
                 open ccts40g07003 using am_prestadores[l_ind].pstcoddig
                 fetch ccts40g07003 into l_nomgrr
                 close ccts40g07003

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
         am_prestadores[l_ind].pstcoddig

end function

