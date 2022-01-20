#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G03                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  FUNCOES GERAIS PARA UTILIZACAO EM PROCESSAMENTOS BATCH.    #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 04/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 18/11/2010 Robert Lima     CT 02086   Alterado o errorlog para display      #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g03_prep smallint

#-------------------------#
function cts40g03_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select today, current from dual "

  prepare p_cts40g03_001 from l_sql
  declare c_cts40g03_001 cursor for p_cts40g03_001

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "

  prepare p_cts40g03_002 from l_sql
  declare c_cts40g03_002 cursor for p_cts40g03_002

  let l_sql = " insert into datkgeral ",
                         " (grlchv, ",
                          " grlinf, ",
                          " atldat, ",
                          " atlhor, ",
                          " atlemp, ",
                          " atlmat) ",
                   " values(?,?,?,?,?,?) "

  prepare p_cts40g03_003 from l_sql

  let l_sql = " update datkgeral ",
                " set (atldat, atlhor) = (?,?) ",
               " where grlchv = ? "

  prepare p_cts40g03_004 from l_sql

  let l_sql = " select atlhor ",
                " from datkgeral ",
               " where grlchv = ? "

  prepare p_cts40g03_005 from l_sql
  declare c_cts40g03_003 cursor for p_cts40g03_005

  let m_cts40g03_prep = true

end function

#-----------------------------------------------#
function cts40g03_data_hora_banco(l_tipo_formato)
#-----------------------------------------------#

  define l_tipo_formato smallint

  # --DESCRICAO DO PARAMETRO DE ENTRADA, SE O TIPO DE FORMATO FOR:

    # 1 - RETORNA: DATA = date e HORA = datetime hour to second
    # 2 - RETORNA: DATA = date e HORA = datetime hour to minute

  define l_data  date,
         l_hora1 datetime hour to second,
         l_hora2 datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let m_cts40g03_prep = null

        let     l_data   =  null
        let     l_hora1  =  null
        let     l_hora2  =  null

  if m_cts40g03_prep is null or
     m_cts40g03_prep <> true then
     call cts40g03_prepare()
  end if

  let l_data  = null
  let l_hora1 = null
  let l_hora2 = null

  case l_tipo_formato

     when(1)

        open c_cts40g03_001
        whenever error continue
        fetch c_cts40g03_001 into l_data, l_hora1
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let l_data  = today
           let l_hora1 = current
        end if

        return l_data, l_hora1

     when(2)

        open c_cts40g03_001
        whenever error continue
        fetch c_cts40g03_001 into l_data, l_hora2
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let l_data  = today
           let l_hora2 = current
        end if

        return l_data, l_hora2

  end case

end function

#-------------------------------------------------#
function cts40g03_verifi_log_existe(l_path_arquivo)
#-------------------------------------------------#

  # --FUNCAO PARA VERIFCAR SE O ARQUIVO DE LOG EXISTE
  # --NO MOMENTO DA EXECUCAO DO PROGRAMA

  define l_comando      char(120),
         l_path_arquivo char(100),
         l_erro         integer,
         l_existe       smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_comando  =  null
        let     l_erro  =  null
        let     l_existe  =  null

  let  l_existe  = null
  let  l_comando = null
  let  l_erro    = null

  let l_comando = "ls ", l_path_arquivo clipped, " >/dev/null 2>/dev/null"

  run l_comando returning l_erro

  let l_existe = true

  if l_erro <> 0 then
     let l_existe = false
  end if

  return l_existe

end function

#----------------------------------------#
function cts40g03_exibe_info(lr_parametro)
#----------------------------------------#

  # --FUNCAO PARA MONITORAMENTO DE INICIO E FIM DO PROGRAMA

  define lr_parametro  record
         tipo_operacao char(01), # I - INICIO ou F - FIM
         nome_processo char(08)  # Nome do Programa
  end record

  define l_data    date,
         l_hora    datetime hour to second


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_data  =  null
        let     l_hora  =  null

  let l_data  = null
  let l_hora  = null

  call cts40g03_data_hora_banco(1)

       returning l_data,
                 l_hora

  if lr_parametro.tipo_operacao = "I" then
     display "------------------------------------"
     display lr_parametro.nome_processo, " Inicio: ", l_data, " ",l_hora
  else
     display lr_parametro.nome_processo, " Fim...: ", l_data, " ",l_hora
     display "------------------------------------"
     display " "
  end if

end function

#------------------------------------#
function cts40g03_espera(lr_parametro)
#------------------------------------#

  define lr_parametro record
         data         date,
         hora         datetime hour to minute
  end record

  define l_aux_char   char(16),
         l_agora      datetime year to minute,
         l_programado datetime year to minute,
         l_tempo      interval hour(6) to minute

  let l_agora      = current
  let l_aux_char   = null
  let l_programado = null
  let l_tempo      = null

  let l_aux_char = lr_parametro.data using "yyyy-mm-dd",
                                           " ",
                                           lr_parametro.hora
  let l_programado = l_aux_char

  # -> CALCULA O TEMPO
  let l_tempo = (l_agora - l_programado)

  return l_tempo

end function

#-------------------------------------#
function cts40g03_tempo_param(l_grlchv)
#-------------------------------------#

  # -> FUNCAO PARA OBTER O TEMPO PARAMETRIZADO
  # -> REFERENTE AO PROCESSAMENTO DOS BATCHS

  define l_grlchv  like datkgeral.grlchv,
         l_grlinf  like datkgeral.grlinf,
         l_aux_num smallint,
         l_tempo   datetime hour to second,
         l_status  smallint, # 0 -> OK   <> 0 -> ERRO DE ACESSO AO BD
         l_msg     char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_grlinf  =  null
        let     l_aux_num  =  null
        let     l_tempo  =  null
        let     l_status  =  null
        let     l_msg  =  null

  if m_cts40g03_prep is null or
     m_cts40g03_prep <> true then
     call cts40g03_prepare()
  end if

  let l_status = 0

  # --> BUSCA O TEMPO NA TABELA DATKGERAL
  open c_cts40g03_002 using l_grlchv
  whenever error continue
  fetch c_cts40g03_002 into l_grlinf
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_status = 1
     if sqlca.sqlcode = notfound then
        display "NAO ENCONTROU O TEMPO PARAMETRIZADO NA DATKGERAL. MODULO CTS40G03"
     else
        let l_msg = "ERRO SELECT c_cts40g03_002 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        display l_msg
        let l_msg = "cts40g03_tempo_param() ", l_grlchv clipped
        display l_msg
     end if
  else
     let l_aux_num = l_grlinf
     let l_grlinf  = null

     # -> FORMATA O TEMPO hh:mm:ss
     let l_grlinf  = "00:", l_aux_num using "&&" clipped, ":00"
     let l_tempo   = l_grlinf
  end if

  close c_cts40g03_002

  return l_status,
         l_grlinf

end function

#------------------------------------#
function cts40g03_tempo_atlz(l_grlchv)
#------------------------------------#

  # -> FUNCAO PARA OBTER O TEMPO DA ULTIMA ATUALIZACAO
  # -> REFERENTE AO PROCESSAMENTO DOS BATCHS

  define l_grlchv  like datkgeral.grlchv,
         l_atlhor  like datkgeral.atlhor,
         l_status  smallint, # 0 -> OK   <> 0 -> ERRO DE ACESSO AO BD
         l_msg     char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_atlhor  =  null
        let     l_status  =  null
        let     l_msg  =  null

  if m_cts40g03_prep is null or
     m_cts40g03_prep <> true then
     call cts40g03_prepare()
  end if

  let l_status = 0

  # --> BUSCA O TEMPO NA TABELA DATKGERAL
  open c_cts40g03_003 using l_grlchv
  whenever error continue
  fetch c_cts40g03_003 into l_atlhor
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_status = 1
     if sqlca.sqlcode = notfound then
        display "NAO ENCONTROU O TEMPO ULTIMA ATUAL. NA DATKGERAL. MODULO CTS40G03"
     else
        let l_msg = "ERRO SELECT c_cts40g03_003 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        display l_msg
        let l_msg = "cts40g03_tempo_atlz() ", l_grlchv clipped
        display l_msg
     end if
  end if

  close c_cts40g03_003

  return l_status,
         l_atlhor

end function

#-----------------------------------#
function cts40g03_atlz_proc(l_grlchv)
#-----------------------------------#

  # -> FUNCAO PARA INSERIR NA TABELA DATKGERAL
  # -> SERVE PARA MONITORAR SE O PROGRAMA BATCH ESTA EM FUNCIONAMENTO

  define l_grlchv  like datkgeral.grlchv,
         l_grlinf  like datkgeral.grlinf,
         l_atldat  like datkgeral.atldat,
         l_atlhor  like datkgeral.atlhor,
         l_atlemp  like datkgeral.atlemp,
         l_atlmat  like datkgeral.atlmat,
         l_msg     char(100),
         l_status  smallint # 0 -> OK   <> 0 -> ERRO DE ACESSO AO BD


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_grlinf  =  null
        let     l_atldat  =  null
        let     l_atlhor  =  null
        let     l_atlemp  =  null
        let     l_atlmat  =  null
        let     l_msg  =  null
        let     l_status  =  null

  if m_cts40g03_prep is null or
     m_cts40g03_prep <> true then
     call cts40g03_prepare()
  end if

  let l_atlemp = 1
  let l_atlmat = 999999 # -> SISTEMA
  let l_status = 0

  # -> BUSCA DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1)
       returning l_atldat,
                 l_atlhor

  # --> VERIFICA SE A CHAVE JA EXISTE NA DATKGERAL
  open c_cts40g03_002 using l_grlchv
  whenever error continue
  fetch c_cts40g03_002 into l_grlinf
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        # -> INSERE NA TABELA datkgeral
        let l_grlinf = "MONITORAMENTO DO PROCESSAMENTO"
        whenever error continue
        execute p_cts40g03_003 using l_grlchv,
                                   l_grlinf,
                                   l_atldat,
                                   l_atlhor,
                                   l_atlemp,
                                   l_atlmat
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let l_msg = "ERRO INSERT p_cts40g03_003 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           display l_msg
           let l_msg = "cts40g03_atlz_proc() ", l_grlchv clipped, "/",
                                                l_grlinf clipped, "/",
                                                l_atldat, "/",
                                                l_atlhor, "/",
                                                l_atlemp, "/",
                                                l_atlmat
           display l_msg
           let l_status = 1
        end if

     else
        let l_msg = "ERRO SELECT c_cts40g03_002 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        display l_msg
        let l_msg = "cts40g03_atlz_proc() ", l_grlchv clipped
        display l_msg
        let l_status = 1
     end if
  else
     # -> ATUALIZA A TABELA datkgeral
     whenever error continue
     execute p_cts40g03_004 using l_atldat,
                                l_atlhor,
                                l_grlchv
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let l_msg = "ERRO UPDATE p_cts40g03_004 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        display l_msg
        let l_msg = "cts40g03_atlz_proc() ", l_grlchv clipped, "/",
                                             l_atldat, "/",
                                             l_atlhor
        display l_msg
        let l_status = 1
     end if
  end if

  close c_cts40g03_002

  return l_status

end function

#-----------------------------------------#
function cts40g03_srv_dist_acn(l_atdsrvnum)
#-----------------------------------------#

  # -> FUNCAO QUE AGUARDA O TEMPO NECESSARIO PARA DISTRIBUIR OS SERVICOS
  # -> DENTRO DOS ACIONAMENTOS AUTOMATICOS

  define l_atdsrvnum  char(07),
         l_tempo      datetime hour to second,
         l_tempo_char char(08),
         final_srv    smallint,
         final_tempo  smallint

  let l_tempo      = null
  let l_tempo_char = null
  let final_srv    = l_atdsrvnum[6,7]
  let final_srv    = final_srv mod 60

  while true

     let l_tempo      = current
     let l_tempo_char = l_tempo

     let final_tempo = l_tempo_char[7,8]
     let final_tempo = final_tempo

     if final_srv = final_tempo then
        exit while
     end if

     sleep 1

  end while

end function

#------------------------------------------#
function cts40g03_texto_contem(lr_parametro)
#------------------------------------------#

  # -> FUNCAO P/VERIFICAR SE DETERMINADO TEXTO ESTA CONTIDO EM OUTRO

  define lr_parametro record
         texto        char(32000),
         pesquisa     char(1000)
  end record

  define l_fim            smallint,
         l_i              smallint,
         l_tam_pesq       smallint, # -> TAMANHO DO TEXTO A SER PESQUISADO
         l_contem         smallint,
         l_texto_extraido char(100)

  # -> INICIALIZACAO DAS VARIAVEIS
  let l_fim            = null
  let l_i              = null
  let l_tam_pesq       = null
  let l_contem         = null
  let l_texto_extraido = null

  let l_tam_pesq  = (length(lr_parametro.pesquisa)-1)
  let l_fim       = (length(lr_parametro.texto)-l_tam_pesq)
  let l_contem    = false

  for l_i = 1 to l_fim
     let l_texto_extraido = lr_parametro.texto[l_i,l_tam_pesq+l_i]
     if l_texto_extraido = lr_parametro.pesquisa then
        let l_contem = true
        exit for
     end if
  end for

  return l_contem

end function
