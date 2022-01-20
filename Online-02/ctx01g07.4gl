#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX01G07                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: 197092 - CONTROLE AUTOMATICO DE FROTA                      #
#                  CONTROLE DE ALERTAS PARA SOCORRISTAS.                      #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/12/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 08/05/2009 Kevellin        PSI 237337 criacao metodo envia_msg_id()         #
#-----------------------------------------------------------------------------#
database porto

  globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctx01g07_prep smallint

#-------------------------#
function ctx01g07_prepare()
#-------------------------#

  define l_sql char(400)

  let l_sql = " insert into datmmdtinc ",
                         " (mdtcod, ",
                          " srrcoddig, ",
                          " mdtinctip, ",
                          " atdtrxdat, ",
                          " atdtrxhor, ",
                          " lclltt, ",
                          " lcllgt, ",
                          " caddat, ",
                          " cadhor) ",
                  " values (?, ?, ?, ?, ?, ?, ?, ?, ?) "
  prepare p_ctx01g07_001 from l_sql

  let l_sql = " select atlhor, ",
                     " atldat, ",
                     " lclltt, ",
                     " lcllgt  ",
                " from datmfrtpos ",
               " where socvclcod = ? ",
                 " and socvcllcltip = 1  "
  prepare p_ctx01g07_002 from l_sql
  declare c_ctx01g07_001 cursor for p_ctx01g07_002

  let l_sql = " insert into datmmdtmsg ",
                         " (mdtmsgnum, ",
                          " mdtmsgorgcod, ",
                          " mdtcod, ",
                          " mdtmsgstt, ",
                          " mdtmsgavstip) ",
                  " values (0, 1, ?, 1, 4) "
  prepare p_ctx01g07_003 from l_sql

  let l_sql = " insert into datmmdtlog ",
                         " (mdtmsgnum, ",
                          " mdtlogseq, ",
                          " mdtmsgstt, ",
                          " atldat, ",
                          " atlhor, ",
                          " atlemp, ",
                          " atlmat) ",
                  " values (?, 1, 1, ?, ?, 1, 999999) "
  prepare p_ctx01g07_004 from l_sql

  let l_sql = " insert into datmmdtmsgtxt ",
                         " (mdtmsgnum, ",
                          " mdtmsgtxtseq, ",
                          " mdtmsgtxt) ",
                  " values (?, 1, ?) "
  prepare p_ctx01g07_005 from l_sql

  let l_sql = " insert into datmmdtsrv ",
                         " (mdtmsgnum, ",
                          " atdsrvnum, ",
                          " atdsrvano) ",
                  " values (?, ?, ?) "
  prepare p_ctx01g07_006 from l_sql

  let l_sql = " select pgrnum ",
                " from datkveiculo ",
               " where socvclcod = ? "
  prepare p_ctx01g07_007 from l_sql
  declare c_ctx01g07_002 cursor for p_ctx01g07_007

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = 'PSOPAGERATIVO' "
  prepare p_ctx01g07_008 from l_sql
  declare c_ctx01g07_003 cursor for p_ctx01g07_008

  let l_sql = " select cpodes ",
               " from htlkdominio ",
              " where cponom = 'PTL-EMAIL-SERVER' ",
                " and cpocod = 1"
  prepare pctx01g07010 from l_sql
  declare cctx01g07010 cursor for pctx01g07010

  let l_sql = " insert into datmmdtmsg ",
                         " (mdtmsgnum, ",
                          " mdtmsgorgcod, ",
                          " mdtcod, ",
                          " mdtmsgstt, ",
                          " mdtmsgavstip) ",
                  " values (0, 1, ?, 1, 2) "
  prepare pctx01g07011 from l_sql

  let l_sql = " select datkveiculo.pstcoddig, ",
                     " datkveiculo.socvclcod, ",
                     " dattfrotalocal.srrcoddig ",
                " from datkveiculo, dattfrotalocal ",
               " where dattfrotalocal.socvclcod = datkveiculo.socvclcod ",
                 " and datkveiculo.mdtcod = ? "
  prepare p_ctx01g07_012 from l_sql
  declare c_ctx01g07_004 cursor for p_ctx01g07_012

  let m_ctx01g07_prep = true

end function

#----------------------------------------#
function ctx01g07_inc_alerta(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         socvclcod    like datmfrtpos.socvclcod, # --CODIGO DO VEICULO
         mdtcod       like datmmdtinc.mdtcod,    # --CODIGO DO MDT
         srrcoddig    like datmmdtinc.srrcoddig, # --CODIGO DO SOCORRISTA
         mdtinctip    like datmmdtinc.mdtinctip  # --TIPO DE EVENTO(ALERTA)
  end record

  define lr_dados record
         atlhor   like datmfrtpos.atlhor,
         atldat   like datmfrtpos.atldat,
         lclltt   like datmfrtpos.lclltt,
         lcllgt   like datmfrtpos.lcllgt
  end record

  define l_msg_erro char(200),
         l_cod_erro smallint,
         l_caddat   like datmmdtinc.caddat,
         l_cadhor   like datmmdtinc.cadhor


  if m_ctx01g07_prep is null or
     m_ctx01g07_prep <> true then
     call ctx01g07_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS

  initialize lr_dados to null


  let l_cod_erro = 0
  let l_msg_erro = null
  let l_caddat   = null
  let l_cadhor   = null

  open c_ctx01g07_001 using lr_parametro.socvclcod
  whenever error continue
  fetch c_ctx01g07_001 into lr_dados.atlhor,
                          lr_dados.atldat,
                          lr_dados.lclltt,
                          lr_dados.lcllgt
  whenever error stop

  if sqlca.sqlcode <> 0 and
     sqlca.sqlcode <> notfound then
     let l_msg_erro = "Erro SELECT c_ctx01g07_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg_erro)
     let l_msg_erro = "ctx01g07_inc_alerta() / ", lr_parametro.socvclcod
     call errorlog(l_msg_erro)
     let l_cod_erro = 2
  else

     if lr_dados.lclltt is null then
        let lr_dados.lclltt = 0
     end if

     if lr_dados.lcllgt is null then
        let lr_dados.lcllgt = 0
     end if

     # --BUSCA A DATA E HORA DO BANCO
     call cts40g03_data_hora_banco(1)

          returning l_caddat,
                    l_cadhor

     whenever error continue
     execute p_ctx01g07_001 using lr_parametro.mdtcod,
                                lr_parametro.srrcoddig,
                                lr_parametro.mdtinctip,
                                lr_dados.atldat,
                                lr_dados.atlhor,
                                lr_dados.lclltt,
                                lr_dados.lcllgt,
                                l_caddat,
                                l_cadhor
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_msg_erro = "Erro INSERT p_ctx01g07_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "ctx01g07_inc_alerta() / " clipped,
                         lr_parametro.mdtcod        clipped, "/",
                         lr_parametro.srrcoddig     clipped, "/",
                         lr_parametro.mdtinctip     clipped, "/",
                         lr_dados.atldat            clipped, "/",
                         lr_dados.atlhor            clipped, "/",
                         lr_dados.lclltt            clipped, "/",
                         lr_dados.lcllgt            clipped, "/",
                         l_caddat                   clipped, "/",
                         l_cadhor
        call errorlog(l_msg_erro)
        let l_cod_erro = 2
     end if

  end if

  close c_ctx01g07_001

  return l_cod_erro

end function

#---------------------------------------#
function ctx01g07_envia_msg(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,     # --NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano,     # --ANO DO SERVICO
         mdtcod       like datmmdtmvt.mdtcod,         # --CODIGO DO MDT
         mdtmsgtxt    like datmmdtmsgtxt.mdtmsgtxt    # --MENSAGEM MDT
  end record

  define l_cod_erro   smallint,
         l_mdtmsgnum  like datmmdtmsg.mdtmsgnum

  call ctx01g07_envia_msg_id(lr_parametro.atdsrvnum,     # --NUMERO DO SERVICO
                             lr_parametro.atdsrvano,     # --ANO DO SERVICO
                             lr_parametro.mdtcod   ,     # --CODIGO DO MDT
                             lr_parametro.mdtmsgtxt)     # --MENSAGEM MDT
       returning l_cod_erro, l_mdtmsgnum

  return l_cod_erro

end function

#PSI 237337 - RETORNO ID MENSAGEM
#---------------------------------------#
function ctx01g07_envia_msg_id(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,     # --NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano,     # --ANO DO SERVICO
         mdtcod       like datmmdtmvt.mdtcod,         # --CODIGO DO MDT
         mdtmsgtxt    like datmmdtmsgtxt.mdtmsgtxt    # --MENSAGEM MDT
  end record

  define l_cod_erro   smallint,
         l_msg_erro   char(200),
         l_mdtmsgnum  like datmmdtmsg.mdtmsgnum,
         l_atldat     like datmmdtlog.atldat,
         l_atlhor     like datmmdtlog.atlhor,
         l_pstcoddig  like dpaksocor.pstcoddig,
         l_socvclcod  like datkveiculo.socvclcod,
         l_srrcoddig  like datksrr.srrcoddig

  if m_ctx01g07_prep is null or
     m_ctx01g07_prep <> true then
     call ctx01g07_prepare()
  end if

  # -->INICIALIZACAO DAS VARIAVEIS
  let l_cod_erro  = 0
  let l_msg_erro  = null
  let l_mdtmsgnum = null
  let l_atldat    = null
  let l_atlhor    = null
  let l_pstcoddig = null
  let l_socvclcod = null
  let l_srrcoddig = null

  # Inclui tabelas de msg GPS do Informix quando AcionamentoWeb nao esta ativo
  if not ctx34g00_ver_acionamentoWEB(2) then

     whenever error continue
     execute pctx01g07011 using lr_parametro.mdtcod
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_cod_erro = 1
        let l_msg_erro = "Erro INSERT pctx01g07011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "ctx01g07_env_msg() / ", lr_parametro.mdtcod
        call errorlog(l_msg_erro)
     else

        let l_mdtmsgnum = sqlca.sqlerrd[2]

        # -->BUSCA A DATA E HORA DO BANCO
        call cts40g03_data_hora_banco(1)

             returning l_atldat, l_atlhor

        whenever error continue
        execute p_ctx01g07_004 using l_mdtmsgnum, l_atldat, l_atlhor
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let l_cod_erro = 1
           let l_msg_erro = "Erro INSERT p_ctx01g07_004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           call errorlog(l_msg_erro)
           let l_msg_erro = "ctx01g07_env_msg() / ", l_mdtmsgnum clipped, "/",
                                                     l_atldat    clipped, "/",
                                                     l_atlhor
           call errorlog(l_msg_erro)
        else

           whenever error continue
           execute p_ctx01g07_005 using l_mdtmsgnum, lr_parametro.mdtmsgtxt
           whenever error stop

           if sqlca.sqlcode <> 0 then
              let l_cod_erro = 1
              let l_msg_erro = "Erro INSERT p_ctx01g07_005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
              call errorlog(l_msg_erro)
              let l_msg_erro = "ctx01g07_env_msg_id() / ", l_mdtmsgnum               clipped, "/",
                                                        lr_parametro.mdtmsgtxt    clipped
              call errorlog(l_msg_erro)
           else

              if lr_parametro.atdsrvnum is not null then

                 whenever error continue
                 execute p_ctx01g07_006 using l_mdtmsgnum, lr_parametro.atdsrvnum, lr_parametro.atdsrvano
                 whenever error stop

                 if sqlca.sqlcode <> 0 then
                    let l_cod_erro = 1
                    let l_msg_erro = "Erro INSERT p_ctx01g07_006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                    call errorlog(l_msg_erro)
                    let l_msg_erro = "ctx01g07_env_msg_id() / ",
                                     l_mdtmsgnum            clipped, "/",
                                     lr_parametro.atdsrvnum clipped, "/",
                                     lr_parametro.atdsrvano
                    call errorlog(l_msg_erro)
                 end if

              end if

           end if

        end if

     end if
  else
     # AcionamentoWeb ativo
     let l_cod_erro = 0

     # -->BUSCA O CODIGO PRESTADOR, VEICULO E SOCORRISTA DO MDT
     open c_ctx01g07_004 using lr_parametro.mdtcod

     whenever error continue
     fetch c_ctx01g07_004 into l_pstcoddig,
                               l_socvclcod,
                               l_srrcoddig
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_cod_erro = sqlca.sqlcode
        if sqlca.sqlcode <> notfound then
           let l_msg_erro = "Erro SELECT c_ctx01g07_004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           call errorlog(l_msg_erro)
           let l_msg_erro = "ctx01g07_envia_msg_id() / ", lr_parametro.mdtcod
           call errorlog(l_msg_erro)
        end if
     end if

     close c_ctx01g07_004

     if l_cod_erro = 0 then
        call ctx34g02_enviar_msg_gps(l_pstcoddig,
                                     l_socvclcod,
                                     l_srrcoddig,
                                     lr_parametro.mdtmsgtxt)
             returning l_cod_erro, l_mdtmsgnum

     end if
  end if

  return l_cod_erro, l_mdtmsgnum

end function

#-----------------------------------------#
function ctx01g07_envia_pager(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         socvclcod    like datkveiculo.socvclcod,  # ---> CODIGO DO VEICULO
         titulo       char(40),                    # ---> TITULO DA MSG DO PAGER
         mensagem     char(880)                    # ---> MSG DO PAGER
  end record

  define lr_mdt       record
         errcod       smallint,
         sqlcode      integer,
         mstnum       like htlmmst.mstnum
  end record

  define l_cod_erro smallint,
         l_msg_erro char(200),
         l_pgrnum   like datkveiculo.pgrnum,
         l_ustcod   like htlrust.ustcod

  if m_ctx01g07_prep is null or
     m_ctx01g07_prep <> true then
     call ctx01g07_prepare()
  end if

  # -->INICIALIZACAO DAS VARIAVEIS
  initialize lr_mdt to null

  let l_cod_erro = 0
  let l_msg_erro = null
  let l_pgrnum   = null
  let l_ustcod   = null

  # -->BUSCA O NUMERO DO PAGER
  open c_ctx01g07_002 using lr_parametro.socvclcod

  whenever error continue
  fetch c_ctx01g07_002 into l_pgrnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_cod_erro = sqlca.sqlcode
        let l_msg_erro = "Erro SELECT c_ctx01g07_002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "ctx01g07_envia_pager() / ", lr_parametro.socvclcod
        call errorlog(l_msg_erro)
     end if
  else

     if l_pgrnum > 0 then
        call ctx01g07_pager_simples(l_pgrnum, lr_parametro.mensagem)
     end if

  end if

  close c_ctx01g07_002

  return l_cod_erro

end function

#------------------------------------#
function ctx01g07_espera(lr_parametro)
#------------------------------------#

  define lr_parametro record
         dataini      date,
         horaini      datetime hour to second
  end record

  define lr_dados     record
         datafim      date,
         horafim      datetime hour to second,
         resdat       integer,
         reshor       interval hour(06) to second,
         chrhor       char(10)
  end record

  initialize lr_dados to null

  # -->BUSCA DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1)
       returning lr_dados.datafim, lr_dados.horafim

  let lr_dados.resdat = (lr_dados.datafim - lr_parametro.dataini) * 24
  let lr_dados.reshor = (lr_dados.horafim - lr_parametro.horaini)

  let lr_dados.chrhor = lr_dados.resdat using "###&" , ":00:00"
  let lr_dados.reshor = (lr_dados.reshor + lr_dados.chrhor)


  return lr_dados.reshor

end function

#---------------------------------------#
function ctx01g07_dif_tempo(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         dataini      date,
         horaini      datetime hour to second,
         datafim      date,
         horafim      datetime hour to second
  end record

  define lr_dados     record
         resdat       integer,
         reshor       interval hour(06) to second,
         chrhor       char(10)
  end record

  initialize lr_dados to null

  let lr_dados.resdat = (lr_parametro.datafim - lr_parametro.dataini) * 24
  let lr_dados.reshor = (lr_parametro.horaini - lr_parametro.horafim)

  let lr_dados.chrhor = lr_dados.resdat using "###&" , ":00:00"
  let lr_dados.reshor = (lr_dados.reshor + lr_dados.chrhor)

  return lr_dados.reshor

end function

#-------------------------------------------#
function ctx01g07_pager_simples(lr_parametro)
#-------------------------------------------#

  define lr_parametro record
         prgnum       integer,   # ---> NUMERO DO PAGER
         texto        char(700)  # ---> TEXTO PARA SER ENVIADO PELO PAGER
  end record

  define l_comando    char(1000),
         l_arquivo    char(15),
         l_tempo      datetime minute to fraction,
         l_tempo_c    char(9),
         l_pager      smallint,
         l_mailtrim   char(50)

  if m_ctx01g07_prep is null or
     m_ctx01g07_prep <> true then
     call ctx01g07_prepare()
  end if

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_comando = null
  let l_arquivo = null
  let l_pager   = false
  let l_mailtrim = null

  open c_ctx01g07_003
  fetch c_ctx01g07_003 into l_pager
  close c_ctx01g07_003

  # ---> Consulta e-mail da teletrim
  open cctx01g07010
  fetch cctx01g07010 into l_mailtrim
  close cctx01g07010

  let l_tempo   = current
  let l_tempo_c = l_tempo

  ###if l_pager = true then
  ###
  ###   # ---> REMOVE AS ASPAS SIMPLES DO ARQUIVO
  ###   let lr_parametro.texto = ctx01g07_remove_aspa(lr_parametro.texto)
  ###
  ###   # ---> GERA O NOME DO ARQUIVO TEMPORARIO
  ###   let l_arquivo ="pager", l_tempo_c[1,2], l_tempo_c[4,5], l_tempo_c[7,9]
  ###
  ###   # ---> GERA O CONTEUDO DO SHELL PARA ENVIO DE E-MAIL
  ###   let l_comando = "echo '", lr_parametro.texto clipped, "' > ", l_arquivo clipped, ".txt;",
  ###                   "send_email.sh -r 'comunicacao.producao@portoseguro.com.br'",
  ###                                " -a ", l_mailtrim clipped,
  ###                                " -s '",lr_parametro.prgnum   using "<<<<<<<<&" ,"'",
  ###                                " < ", l_arquivo clipped, ".txt;",
  ###                   "rm ", l_arquivo clipped, ".txt;",
  ###                   "rm ", l_arquivo clipped, ".sh;"
  ###
  ###   # ---> GRAVA SHELL
  ###   let l_comando = 'echo "', l_comando clipped, '">', l_arquivo clipped, '.sh'
  ###   run l_comando
  ###
  ###   # ---> MUDA A PERMISSAO DO ARQUIVO, TORNANDO EXECUTAVEL
  ###   let l_comando = "chmod 777 ", l_arquivo clipped, ".sh"
  ###   run l_comando
  ###
  ###   # ---> EXECUTA O SHELL EM BACKGROUND
  ###   let l_comando = l_arquivo clipped, ".sh&"
  ###   run l_comando
  ###
  ###end if

end function

#--------------------------------#
function ctx01g07_km_p_metro(l_km)
#--------------------------------#

  # ---> FUNCAO QUE TRANSFORMA UMA DISTANCIA DE KM PARA METROS

  define l_km     decimal(8,4),
         l_metros integer

  let l_metros = null
  let l_metros = (l_km * 1000)

  return l_metros

end function

#-------------------------------------#
function ctx01g07_rem_eps_esq(l_string)
#-------------------------------------#

  # ---> FUNCAO RESPONSAVEL POR REMOVER OS ESPACOS A ESQUERDA DE UMA STRING
  # ---> DO TIPO interval hour(06) to second

  define l_string     char(20), # ---> STRING COM OS ESPACOS A ESQUERDA
         l_indice     smallint,
         l_string_ok  char(20)  # ---> STRING SEM OS ESPACOS A ESQUERDA

  let l_indice    = null
  let l_string_ok = " "

  for l_indice = 1 to length(l_string)

     if l_string[l_indice,l_indice] is not null and
        l_string[l_indice,l_indice] <> " " then
        let l_string_ok = l_string_ok clipped, l_string[l_indice,l_indice]
     end if

  end for

  return l_string_ok

end function

#----------------------------------------#
function ctx01g07_trans_data(lr_parametro)
#----------------------------------------#

  # ---> FUNCAO RESPONSAVEL POR TANSFORMAR UMA DATA E HORA
  # ---> NUMA VARIAVEL DO TIPO datetime year to second

  define lr_parametro record
         data         date,
         hora         datetime hour to second
  end record

  define l_data_trans datetime year to second,
         l_data_aux   char(19)

  let l_data_trans = null
  let l_data_aux   = null

  let l_data_aux   = lr_parametro.data using "yyyy-mm-dd", " ",
                     lr_parametro.hora

  let l_data_trans = l_data_aux

  return l_data_trans

end function

#---------------------------------------#
function ctx01g07_pega_dtahor(l_datahora)
#---------------------------------------#

  # ---> FUNCAO RESPONSAVEL POR DEVOLVER A DATA E HORA NO FORMATO
  # ---> dd/mm/yyyy hh:mm:ss A PARTIR DA VARIAVEL PASSADA COMO PARAMETRO

  define l_datahora datetime year to second,
         l_data     date,
         l_data_c   char(10),
         l_hora     datetime hour to second,
         l_aux_char char(19)

  let l_data     = null
  let l_data_c   = null
  let l_hora     = null
  let l_aux_char = null

  let l_aux_char = l_datahora

  let l_data_c   = l_aux_char[9,10], "/", # DIA
                   l_aux_char[6,7],  "/", # MES
                   l_aux_char[1,4]        # ANO

  let l_data     = l_data_c

  let l_hora     = l_aux_char[12,19]

  return l_data, l_hora

end function

#------------------------------------#
function ctx01g07_remove_aspa(l_texto)
#------------------------------------#

  define l_texto char(700),
         l_i     smallint

  let l_i = null

  for l_i = 1 to length(l_texto)
     if l_texto[l_i] = "'" then
        let l_texto[l_i] = " "
     end if
  end for

  return l_texto

end function
