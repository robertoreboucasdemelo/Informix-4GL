#############################################################################
# Nome do Modulo: bdbsa132                                          Adriano #
#                                                                    Santos #
# Sumarizacao de informacoes do Painel das Controladoras           Abr/2010 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
#...........................................................................#
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define m_path       char(100)

 define am_retorno   array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

 define m_espera        interval hour(06) to second,
        m_tempo_limite  interval hour(06) to second,
        m_dist_minima   decimal(8,4),
        m_tmpexp        datetime year to second,
        m_prcstt        like dpamcrtpcs.prcstt,
        m_data_atual    date,
        m_hora_atual    datetime hour to second,
        m_msg_proc      char(80),
        m_tmpmvt        datetime year to second,
        m_tmptxt        char(20)

 define mr_retcontroladoras record
        erro           smallint ,
        mensagem       char(100)
 end record

 main

  define l_contingencia smallint,
         l_count integer,
         l_datmax date,
         l_hormax datetime hour to second

  call fun_dba_abre_banco("GUINCHOGPS")

  # Seta paramentros de banco depois da abertura
  set lock mode to wait 30
  set isolation to dirty read

  #----------------------#
  select sitename
  into g_hostname
  from dual
  #----------------------#

  let m_path = f_path("DBS","LOG")
  if m_path is null then
     let m_path = "."
  end if
  let m_path = m_path clipped,"/bdbsa132.log"

  call startlog(m_path)

  #call bdbsa132_prepare()

  # --> CONSTANTES
  let m_tempo_limite  = "00:05:00"  # --> TEMPO LIMITE PARA VERIFICACAO DE MOVIMNTO APOS QRU-REC
  let m_dist_minima   = 0.300       # --> DISTANCIA MINIMA DE DESLOCAMENTO APOS TEMPO LIMITE
  let m_espera        = null

  # BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

  display "BDBSA132 Carga:  ", m_data_atual, " ", m_hora_atual

  # DVP 25240
  let  m_tmpexp = current

  while true

     # --VERIFICA SE O ARQUIVO DE LOG EXISTE, SE NAO EXISTIR, ENCERRA O PROGRAMA
     if not cts40g03_verifi_log_existe(m_path) then
        display "Nao encontrou o arquivo de log: ", m_path clipped
        exit program(1)
     end if

     call ctx28g00("bdbsa132", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, m_prcstt

     let l_contingencia = null
     call cta00m08_ver_contingencia(4)
          returning l_contingencia

     if l_contingencia then
        display "Contingencia ativa ou carga ainda nao realizada."
     else
        if ctx34g00_ver_acionamentoWEB(2) then
           display "AcionamentoWeb Ativo."
        else
           # Se for o processo ativo
           if  m_prcstt = 'A' then

                # BUSCAR A DATA E HORA DO BANCO
                call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

                display "BDBSA132 ativo inicio: ", m_data_atual, " ", m_hora_atual

                let m_msg_proc = ""

                # Atualiza informacao dos paineis
                call bdbsa132_gravar_inf_control()

                # BUSCAR A DATA E HORA DO BANCO
                call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

                display "BDBSA132 ativo fim:    ", m_data_atual, " ", m_hora_atual, m_msg_proc clipped

           else
                # BUSCAR A DATA E HORA DO BANCO
                call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

                display "BDBSA132 standBy inicio: ", m_data_atual, " ", m_hora_atual

                let m_msg_proc = ""

                # BUSCAR A DATA E HORA DO BANCO
                call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

                display "BDBSA132 standBy fim:    ", m_data_atual, " ", m_hora_atual, m_msg_proc clipped

           end if
        end if
     end if

     sleep 30

  end while

 end main

###PSI 214566
#--------------------------------------------------------------------------
function bdbsa132_gravar_inf_control()
#--------------------------------------------------------------------------
  define l_data_atual            date,
         l_hora_atual            datetime hour to minute,
         l_data_atuam_hora_atual datetime year to minute

  let l_data_atuam_hora_atual = null

  # BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2) returning l_data_atual, l_hora_atual

  #Formatação da data(datetime year to minute)
  call ctd23g00_formatar_datahora(l_data_atual, l_hora_atual)
       returning l_data_atuam_hora_atual

  initialize mr_retcontroladoras to null

  call ctd23g00_gravar_inf_ctr(l_data_atuam_hora_atual)
       returning mr_retcontroladoras.*

  #if (mr_retcontroladoras.erro <> 1) then
  #   display "Erro ao atualizar informacoes das controladoras ",
  #            mr_retcontroladoras.mensagem clipped
  #end if

end function

function fonetica2()                                                                                
end function 