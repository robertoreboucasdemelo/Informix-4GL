#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G09                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  - VERIFICA SE E HORA DE ACIONAR O SERVICO.                 #
#                       FUNCAO: CTS40G09_ACIONA_SERVICO()                     #
#                  - ENVIA SERVICO P/ACIONAMENTO MANUAL.                      #
#                       FUNCAO: CTS40G09_ACIONA_MANUAL()                      #
#                  - CONTABILIZA TENTATIVA DE ACIONAMENTO.                    #
#                       FUNCAO: CTS40G09_CONTAB_TENTATIVA()                   #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 18/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g09_prep smallint

#-------------------------#
function cts40g09_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " update datmservico ",
                " set (acnsttflg, atdfnlflg, acnnaomtv, ",
                     " acntntqtd) = ('N', ?, ?, ?) ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pcts40g09001 from l_sql

  let l_sql = " update datmservico ",
                " set (acntntqtd, acnnaomtv) = (?, ?) ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pcts40g09002 from l_sql

  let l_sql = " select atdfnlflg ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pcts40g09003 from l_sql
  declare ccts40g09003 cursor for pcts40g09003

  let m_cts40g09_prep = true

end function

#--------------------------------------------#
function cts40g09_aciona_servico(lr_parametro)
#--------------------------------------------#

  define lr_parametro  record
         atdsrvnum     like datmservico.atdsrvnum,
         atdsrvano     like datmservico.atdsrvano,
         atddatprg     like datmservico.atddatprg,
         atdhorprg     like datmservico.atdhorprg,
         acnlmttmp     like datkatmacnprt.acnlmttmp
  end record

  define l_acionar     smallint,
         l_data_atual  date,
         l_calc_hora   interval hour(3) to minute,
         l_aux_calc2   char(07),
         l_aux_calc1   char(07),
         l_acio_man    smallint,
         l_hora_atual  datetime hour to minute,
         l_inter_h1    interval hour(3) to minute,
         l_inter_h2    interval hour(3) to minute,
         l_resultado   smallint,
         l_indice      smallint,
         l_mult_manual smallint,
         l_mensagem    char(80)

  define al_multiplos  array[10] of record
         atdmltsrvnum  like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano  like datratdmltsrv.atdmltsrvano,
         socntzdes     like datksocntz.socntzdes,
         espdes        like dbskesp.espdes,
         atddfttxt     like datmservico.atddfttxt
  end record


        define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_acionar  =  null
        let     l_data_atual  =  null
        let     l_calc_hora  =  null
        let     l_aux_calc2  =  null
        let     l_aux_calc1  =  null
        let     l_acio_man  =  null
        let     l_hora_atual  =  null
        let     l_inter_h1  =  null
        let     l_inter_h2  =  null
        let     l_resultado  =  null
        let     l_indice  =  null
        let     l_mult_manual  =  null
        let     l_mensagem  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  10
                initialize  al_multiplos[w_pf1].*  to  null
        end     for

  if m_cts40g09_prep is null or
     m_cts40g09_prep <> true then
     call cts40g09_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize al_multiplos to null

  let l_acio_man    = 0
  let l_mult_manual = 0

  # --VERIFICA SE O SERVICO E IMEDIATO
  if lr_parametro.atddatprg is null then

     # --COMO O SERVICO E IMEDIATO ELE DEVE SER ACIONADO
     let l_acionar = true
  else

     # --BUSCA A DATA E HORA DO BANCO
     call cts40g03_data_hora_banco(2)

          returning l_data_atual, l_hora_atual

     # --VERIFICA SE O SERVICO ESTA PROGRAMADO PARA A DATA DE HOJE
     if lr_parametro.atddatprg = l_data_atual then

        # --VERIFICA SE JA ESTA NA HORA DE ACIONAR, DE ACORDO COM O TEMPO
        # --LIMITE QUE FOI PARAMETRIZADO

        # --PASSA AS HORAS P/VARIAVEIS DO TIPO CHAR
        let l_calc_hora = (lr_parametro.atdhorprg - l_hora_atual)
        let l_aux_calc1 = l_calc_hora
        let l_aux_calc2 = lr_parametro.acnlmttmp

        # --PASSA AS HORAS P/VARIAVEIS DO TIPO INTERVAL
        let l_inter_h1 = l_aux_calc1
        let l_inter_h2 = l_aux_calc2

        if l_inter_h1 is null or
           l_inter_h2 is null then
           let l_acionar = false
        else
           if (l_inter_h1 <= l_inter_h2) then
              # --HORA DE ACIONAR O SERVICO
              let l_acionar = true
           else
              # --NAO E HORA DE ACIONAR O SERVICO
              let l_acionar = false
           end if
       end if

     else
        # --O SERVICO E PROGRAMADO MAS NAO PARA A DATA DE HOJE
        let l_acionar = false

        if (lr_parametro.atddatprg < l_data_atual) then

           call cts40g09_aciona_manual(lr_parametro.atdsrvnum,
                                       lr_parametro.atdsrvano,
                                       "ERRO DE SISTEMA. AVISE A INFORMATICA !",
                                       0,
                                       "N")

                returning l_resultado, l_mensagem

           let l_acio_man = l_acio_man + 1

           if l_resultado = 0 then

              # --VERIFICA SE O SERVICO ORIGINAL POSSUI SERVICOS MULTIPLOS
              call cts29g00_obter_multiplo(2,
                                           lr_parametro.atdsrvnum,
                                           lr_parametro.atdsrvano)

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
                 # --ATUALIZA OS MULTIPLOS COM A RESPECTIVA MSG DE ERRO
                 if al_multiplos[l_indice].atdmltsrvnum is not null then
                    call cts40g09_aciona_manual(al_multiplos[l_indice].atdmltsrvnum,
                                                al_multiplos[l_indice].atdmltsrvano,
                                                "ERRO DE SISTEMA. AVISE A INFORMATICA !",
                                                0,
                                                "N")

                         returning l_resultado, l_mensagem

                    if l_resultado <> 0 then
                       exit for
                    end if

                    let l_mult_manual = l_mult_manual + 1
                 else
                    # --NAO POSSUI SERVICOS MULTIPLOS
                    exit for
                 end if
              end for
           end if

        end if

     end if

  end if

  return l_acionar,
         l_acio_man,
         l_mult_manual

end function

#-------------------------------------------#
function cts40g09_aciona_manual(lr_parametro)
#-------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         acnnaomtv    like datmservico.acnnaomtv,
         acntntqtd    like datmservico.acntntqtd,
         atdfnlflg    like datmservico.atdfnlflg
  end record

  define l_resultado  smallint,
         l_mensagem   char(80),
         l_msg_erro   char(100),
         l_etapa      like datmsrvacp.atdetpcod,
         l_atdfnlflg  like datmservico.atdfnlflg

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     l_msg_erro  =  null
        let     l_atdfnlflg = null
        let     l_etapa     = null

  if m_cts40g09_prep is null or
     m_cts40g09_prep <> true then
     call cts40g09_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_resultado = 0

  # -> BUSCA O atdfnlflg da datmservico
  open ccts40g09003 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  fetch ccts40g09003 into l_atdfnlflg
  close ccts40g09003

  # -> BUSCA A ULTIMA ETAPA DO SERVICO
  let l_etapa = cts10g04_ultima_etapa(lr_parametro.atdsrvnum,
                                      lr_parametro.atdsrvano)

  if l_atdfnlflg = "S" or
     l_etapa = 3 or
     l_etapa = 4 or
     l_etapa = 5 then
     # -> NAO ENVIA PARA MANUAL
     let l_resultado = 0
  else
     whenever error continue
     execute pcts40g09001 using lr_parametro.atdfnlflg,
                                lr_parametro.acnnaomtv,
                                lr_parametro.acntntqtd,
                                lr_parametro.atdsrvnum,
                                lr_parametro.atdsrvano
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_resultado = 2
        let l_mensagem = "Erro UPDATE pcts40g09001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_mensagem)
        let l_msg_erro = "CTS40G09/cts40g09_aciona_manual() / ", lr_parametro.acnnaomtv clipped, "/",
                                                        lr_parametro.atdsrvnum clipped, "/",
                                                        lr_parametro.atdsrvano clipped, "/",
                                                        lr_parametro.acntntqtd
        call errorlog(l_msg_erro)
     else
       call cts00g07_apos_grvlaudo(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)
     end if
  end if

  return l_resultado,
         l_mensagem

end function

#----------------------------------------------#
function cts40g09_contab_tentativa(lr_parametro)
#----------------------------------------------#

  define lr_parametro  record
         acntntqtd     like datmservico.acntntqtd,
         acntntlmtqtd  like datkatmacnprt.acntntlmtqtd,
         msg_motivo    like datmservico.acnnaomtv,
         atdsrvnum     like datmservico.atdsrvnum,
         atdsrvano     like datmservico.atdsrvano,
         atdsrvorg     like datmservico.atdsrvorg
  end record

  define l_qtd_tent      like datmservico.acntntqtd,
         l_resultado     smallint,
         l_mensagem      char(80),
         l_indice        smallint,
         l_msg_erro      char(100),
         l_aciona_manual smallint,
         l_mult_manual   smallint,
         l_resultado_m   smallint,
         l_mensagem_m    char(80)

  define al_multiplos  array[10] of record
         atdmltsrvnum  like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano  like datratdmltsrv.atdmltsrvano,
         socntzdes     like datksocntz.socntzdes,
         espdes        like dbskesp.espdes,
         atddfttxt     like datmservico.atddfttxt
  end record


        define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_qtd_tent  =  null
        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     l_indice  =  null
        let     l_msg_erro  =  null
        let     l_aciona_manual  =  null
        let     l_mult_manual  =  null
        let     l_resultado_m  =  null
        let     l_mensagem_m  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  10
                initialize  al_multiplos[w_pf1].*  to  null
        end     for

  if m_cts40g09_prep is null or
     m_cts40g09_prep <> true then
     call cts40g09_prepare()
  end if

  let l_qtd_tent      = lr_parametro.acntntqtd
  let l_resultado     = 0
  let l_aciona_manual = 0
  let l_mult_manual   = 0

  if l_qtd_tent is null then
     let l_qtd_tent = 0
  end if

  # --ACRESCENTAR MAIS UMA TENTATIVA DE ACIONAMENTO NA TABELA datmservico
  let l_qtd_tent = l_qtd_tent + 1

  if lr_parametro.atdsrvorg = 9 then # SERVICOS RE

     # --VERIFICA SE O SERVICO ORIGINAL POSSUI SERVICOS MULTIPLOS
     call cts29g00_obter_multiplo(2,
                                  lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano)

          returning l_resultado_m,
                    l_mensagem_m,
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
  end if

  # --VERIFICA SE A QUANTIDADE DE ACIONAMENTOS E MENOR DO QUE
  # --O LIMITE DE TENTATIVAS PARAMETRIZADO
  ##if l_qtd_tent < lr_parametro.acntntlmtqtd then

     # --SE FOR, CONTABILIZA MAIS UMA TENTATIVA DE ACIONAMENTO
     whenever error continue
     execute pcts40g09002 using l_qtd_tent,
                                lr_parametro.msg_motivo,
                                lr_parametro.atdsrvnum,
                                lr_parametro.atdsrvano
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_resultado = 2
        let l_mensagem  = "Erro UPDATE pcts40g09002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_mensagem)
        let l_msg_erro =  "CTS40G09/cts40g09_contab_tentativa() / ", l_qtd_tent clipped, "/",
                                                                     lr_parametro.msg_motivo clipped, "/",
                                                                     lr_parametro.atdsrvnum clipped , "/",
                                                                     lr_parametro.atdsrvano
        call errorlog(l_msg_erro)
     else
        call cts00g07_apos_grvlaudo(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)
     end if


     if lr_parametro.atdsrvorg = 9 then # SERVICOS RE
        for l_indice = 1 to 10

            # --ATUALIZA OS MULTIPLOS
            if al_multiplos[l_indice].atdmltsrvnum is not null then

               whenever error continue
               execute pcts40g09002 using l_qtd_tent,
                                          lr_parametro.msg_motivo,
                                          al_multiplos[l_indice].atdmltsrvnum,
                                          al_multiplos[l_indice].atdmltsrvano
               whenever error stop

               if sqlca.sqlcode <> 0 then
                  let l_resultado = 2
                  let l_mensagem  = "Erro UPDATE pcts40g09002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                  call errorlog(l_mensagem)
                  let l_msg_erro =  "CTS40G09/cts40g09_contab_tentativa() / ", l_qtd_tent clipped, "/",
                                                                               lr_parametro.msg_motivo clipped, "/",
                                                                               al_multiplos[l_indice].atdmltsrvnum clipped , "/",
                                                                               al_multiplos[l_indice].atdmltsrvano
                  call errorlog(l_msg_erro)
                  exit for
               end if
            else
               exit for
            end if

        end for
     end if

{ ## ligia em 20/12/06
  else
     # --ENVIAR O SERVICO PARA ACIONAMENTO MANUAL NA TELA DO RADIO
     # --POIS O SERVICO ULTRAPASSOU AS TENTATIVAS POSSIVEIS QUE FORAM PARAMETRIZADAS

     let l_aciona_manual = l_aciona_manual + 1

     call cts40g09_aciona_manual(lr_parametro.atdsrvnum,
                                 lr_parametro.atdsrvano,
                                 lr_parametro.msg_motivo,
                                 l_qtd_tent,
                                 "N")

          returning l_resultado,
                    l_mensagem

     if lr_parametro.atdsrvorg = 9 then # SERVICOS RE
        for l_indice = 1 to 10

            # --ATUALIZA OS MULTIPLOS
            if al_multiplos[l_indice].atdmltsrvnum is not null then

               # --CONTABILIZA OS REGISTROS ENVIADOS PARA ACIONAMENTO MANUAL
               let l_mult_manual = l_mult_manual + 1

               call cts40g09_aciona_manual(al_multiplos[l_indice].atdmltsrvnum,
                                           al_multiplos[l_indice].atdmltsrvano,
                                           lr_parametro.msg_motivo,
                                           l_qtd_tent,
                                           "N")

                    returning l_resultado,
                              l_mensagem

               if l_resultado <> 0 then
                  exit for
               end if

            else
               exit for
            end if

        end for
     end if

  end if
}


  return l_resultado,
         l_mensagem,
         l_aciona_manual,
         l_mult_manual

end function
