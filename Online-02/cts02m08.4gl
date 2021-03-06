#*****************************************************************************#
# Modulo .........: cts02m08.4gl                                              #
# Analista .......: Fabio Lamartine                                           #
# Desenvolvimento.: Rodolfo Massini - 10/2013                                 #
# Objetivo........: Pop-up para agendamento de servicos, utiliza a regulacao  #
#                   do AW (Agenda Web) e pop-up para sugestoes.               #
#                                                                             #
#-----------------------------------------------------------------------------#
# 10/10/2013 - Rodolfo Massini                                                #
#-----------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Adaptacao regulacao via AW     #
#-----------------------------------------------------------------------------#
# 25/06/2015  Norton,Biztalk SPR-2015-13411 Otimizacao para Envio do de Email #
#                                           pelo Sistema e-mail_reL           #
#-----------------------------------------------------------------------------#
# 03/08/2015  Norton,Biztalk SPR-2015-15533 Otimizacao para Envio do de Email #
#                            para a PortoFaz                                  #
#-----------------------------------------------------------------------------#
# 16/03/2016  Eliane K, Fornax              Regulacao Nova Agenda             #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


 # RECORDS MODULARES
 define mr_req_reg_agenda record
    srvhordat             char(19)  # Data e hora do servico
   ,srvcidnom             char(50)  # Nome da cidade do servico
   ,srvufsgl              char(02)  # UF da cidade do servico
   ,asstipcod             dec(12,0) # Tipo de asistencia (nao existe no sistema Ct24h)
   ,vclcod                dec(5,0)  # Codigo do veiculo
   ,ctgtrfcod             dec(2,0)  # Codigo categoria tarifaria
   ,imdsrvflg             char(01)  # Flag servico imediato
   ,endindtpo             dec(1,0)  # Tipo indexacao do endereco
   ,endltt                dec(8,6)  # Latitude do endereco
   ,endlgt                dec(9,6)  # Longitude do endereco
   ,empcod                dec(2,0)  # Codigo da empresa
   ,atdsrvorg             smallint  # codigo da origem
   ,asitipcod             smallint  # codigo da assistencia
   ,socntzcod             smallint  # codigo da natureza
   ,socntzsub             smallint  # codigo da subnatureza (somente para fins de envio, nao existe no PS)
 end record

 define ma_res_reg_agenda array [1000] of record
    sts                   char(03) # Status (OK/NOK)
   ,rsrchv                char(25) # Chave de reserva
   ,atdhorpvt             char(05) # Hora prevista atendimento
   ,horfxa                char(11) # Faixa de horarios
   ,srvhordat             char(16) # Data e hora do servico
 end record

 # VARIVEIS MODULARES
 define m_prep_cts02m08    smallint                 # Flag SQL preparado
       ,m_previsao         datetime hour to minute  # Hora previsao atendimento

#-----------------------------------------------------------
function cts02m08_prepare()
#-----------------------------------------------------------

 define l_sql char(1500)

 # CONSULTA DE LIMITES
 let l_sql = null
 let l_sql = " select agdlimqtd   ",
               " from datksrvtip ",
              " where atdsrvorg = ? "

 prepare pcts02m08001 from l_sql
 declare ccts02m08001 cursor for pcts02m08001

 # CONSULTA DE PREVISAO
 let l_sql = null
 let l_sql = "select grlinf ",
               "from datkgeral ",
              "where grlchv = ? "

 prepare pcts02m08002 from l_sql
 declare ccts02m08002 cursor for pcts02m08002

 let l_sql = null
 let l_sql = ' select distinct '
            ,'        case when c.autctgatu is null '
            ,'          then 10                '
            ,'        else                     '
            ,'          c.autctgatu            '
            ,'        end autctgatu            '
            ,' from agbkveic v,                '
            ,'      agbktip  t,                '
            ,'      agbkmarca m,               '
            ,'      iddkdominio e,             '
            ,'      outer agetdecateg c        '
            ,' where v.vcltipcod = t.vcltipcod '
            ,'   and v.vclmrccod = t.vclmrccod '
            ,'   and v.vclmrccod = m.vclmrccod '
            ,'   and v.vclcoddig = c.vclcoddig '
            ,'   and e.cponom = "vclesp"       '
            ,'   and e.cpocod = v.vclesp       '
            ,'   and c.vigfnl = (select max(maxcat.vigfnl) '
            ,'                   from agetdecateg maxcat   '
            ,'                   where maxcat.vclcoddig = v.vclcoddig) '
            ,'   and v.vclcoddig = ? '
 prepare pcts02m08003 from l_sql
 declare ccts02m08003 cursor for pcts02m08003

 let l_sql = null
 let l_sql = ' select count(mpacidcod) '
            ,' from datkmpacid  '
            ,' where ufdcod    = ? '
            ,'   and cidnom like ? '
 prepare pcts02m08004 from l_sql
 declare ccts02m08004 cursor for pcts02m08004

 let l_sql = null
 let l_sql = ' select cidnom '
            ,' from datkmpacid  '
            ,' where ufdcod    = ? '
            ,'   and cidnom like ? '
 prepare pcts02m08005 from l_sql
 declare ccts02m08005 cursor for pcts02m08005

 let m_prep_cts02m08 = true

end function

#-----------------------------------------------------------
function cts02m08(l_param, k_cts02m08, lr_req_reg_agenda)
#-----------------------------------------------------------

 # RECORDS DE ENTRADA DA FUNCAO

 define l_param  record
        atdfnlflg  like datmservico.atdfnlflg    # Flag final de atendimento
      , imdsrvflg  char (01)    # Flag servico imediato
      , altcidufd  smallint     # Regular novamente em funcao de alteracao de cidade/UF  # true/sim,false/nao
      , prslocflg  char(1)
 end record

 define k_cts02m08 record
        atdhorpvt      like datmservico.atdhorpvt    # Horas prevista atendimento
      , atddatprg      like datmservico.atddatprg    # Data programada
      , atdhorprg      like datmservico.atdhorprg    # Hora programada
      , atdpvtretflg   like datmservico.atdpvtretflg # Flag retorno segurado
      , rsrchv         char(25)                      # retorno de chave gerada ao entrar novamente na funcao
      , operacao       smallint # O que foi feito na funcao:
                                # 1 - liberado com regulacao
                                # 2 - liberado sem regulacao
                                # 3 - falha ao obter chave
                                # 4 - CTRL+C teclado e retorno com chave valida
                                # 5 - apenas consultando a partir do laudo. Se alterar endereco ou data/hora, vira para 0
 end record

 define lr_req_reg_agenda record
    srvhordat             char(19)  # Data e hora do servico
   ,srvcidnom             char(50)  # Nome da cidade do servico
   ,srvufsgl              char(02)  # UF da cidade so servico
   ,asstipcod             dec(12,0) # Tipo de asistencia (nao existe no sistema Ct24h)
   ,vclcod                dec(5,0)  # Codigo do veiculo
   ,ctgtrfcod             dec(2,0)  # Codigo categoria tarifaria
   ,imdsrvflg             char(01)  # Flag servico imediato
   ,endindtpo             dec(1,0)  # Tipo indexacao endereco
   ,endltt                dec(8,6)  # Latitude do endereco
   ,endlgt                dec(9,6)  # Longitude do endereco
   ,empcod                dec(2,0)  # Codigo empresa
   ,atdsrvorg             smallint  # codigo da origem
   ,asitipcod             smallint  # codigo da assistencia
   ,socntzcod             smallint  # codigo da natureza
   ,socntzsub             smallint  # codigo da subnatureza (somente para fins de envio, nao existe no PS)
 end record

 # RECORDS E VARIAVEIS DE SAIDA DA FUNCAO
 define d_cts02m08 record
    atdhorpvt      like datmservico.atdhorpvt    # Horas previstas atendimento
   ,atddatprg      like datmservico.atddatprg    # Data programada
   ,atdhorprg      like datmservico.atdhorprg    # Hora programada
   ,atdpvtretflg   like datmservico.atdpvtretflg # Flag retorno segurado
   ,imdsrvflg      char(01)                      # Quando alterou de imediato para programado
 end record

 # VARIAVEIS PARA USO INTERNO DA FUNCAO
 define l_xml_envio       char(5000)                 # XML de envio ao MQ
      , l_xml_retorno     char(5000)                 # XML de retorno do MQ
      , l_mens            char(300)                  # Mensagens de erro
      , l_data_limite     date                       # Data lim. de agendamento
      , prompt_key        char(01)                   # Mensagem do pop-up
      , l_data            date                       # Data - Multiuso (date)
      , l_data_char       char(10)                   # Data - Multiuso (texto)
      , l_hora2           datetime hour to minute    # Hora - Multiuso
      , l_hora3           datetime hour to minute    # Hora - Multiuso
      , l_nro_registros   smallint                   # Nro. de registros do XML
      , l_erro_atdhorprg  smallint                   # Controle de erro
      , l_erro_reg_agd    smallint                   # Ctrl. de erro reg. agenda
      , l_erro_obt_prv    smallint                   # Ctrl. de erro obt. prev.
      , l_erro_sug_ag     smallint                   # Ctrl. de erro sug. agenda
      , l_previsao_padrao datetime hour to minute    # Hrs. prev. (prev. padrao)
      , l_atddatprg       like datmservico.atddatprg # Data prog. do servico
      , l_atdhorprg       like datmservico.atdhorprg # Hora prog. do servico
      , l_digitavel       smallint                   # Flag ctrl. digitar prev.
      , l_rsrchv          char(25)
      , l_altdathor       smallint
      , l_reserva_ativa   smallint
      , l_agncotdatant    date                       # Data da cota atual AW (slot)
      , l_agncothorant    datetime hour to second    # Hora da cota atual AW (slot)
      , l_errcod          smallint
      , l_errmsg          char(80)

 define lr_retorno record
        coderro    smallint ,                 # Cod. de erro consulta de limites
        mens       char(300),                 # Msg. de erro consulta de limites
        agdlimqtd  like datksrvtip.agdlimqtd  # Limite de dias agendamento
 end record

 define l_min    char(02)
      , l_horaux char(05)

 define l_imputcancelou smallint

 initialize l_min, l_horaux to null

 # INICIALIZACAO DAS VARIAVEIS INTERNA E RECORD DE RETORNO DA FUNCAO
 initialize d_cts02m08.*
          , lr_retorno.*
          , ma_res_reg_agenda
          , mr_req_reg_agenda to null

 initialize l_xml_envio
          , l_xml_retorno
          , l_mens
          , l_data_limite
          , prompt_key
          , l_data
          , l_data_char
          , l_hora2
          , l_hora3
          , l_nro_registros
          , l_erro_atdhorprg
          , l_erro_reg_agd
          , l_erro_obt_prv
          , l_erro_sug_ag
          , l_previsao_padrao
          , l_atddatprg
          , l_atdhorprg
          , l_digitavel
          , l_rsrchv
          , l_altdathor
          , l_reserva_ativa
          , l_agncotdatant
          , l_agncothorant
          , l_errcod
          , l_errmsg
 to null

 initialize l_imputcancelou to null

 # TRATATIVAS E TRANSFORMACOES DE VARIAVEIS

 let mr_req_reg_agenda.* = lr_req_reg_agenda.*

 if k_cts02m08.atdpvtretflg  is null   then
    let k_cts02m08.atdpvtretflg = "N"
 end if

 let d_cts02m08.atdhorpvt    = k_cts02m08.atdhorpvt
 let d_cts02m08.atddatprg    = k_cts02m08.atddatprg
 let d_cts02m08.atdhorprg    = k_cts02m08.atdhorprg
 let d_cts02m08.atdpvtretflg = k_cts02m08.atdpvtretflg
 let d_cts02m08.imdsrvflg    = l_param.imdsrvflg

 let l_erro_atdhorprg = false
 let l_digitavel = true
 let l_altdathor = false

 let l_imputcancelou = false

 # SECAO DE TELA E CAMPOS

 open window cts02m08 at 11,54 with form "cts02m08" attribute(border,form line 1)

 let int_flag = false

 if k_cts02m08.operacao is null
    then
    let k_cts02m08.operacao = 0
 end if

 let l_rsrchv = k_cts02m08.rsrchv

 # Retira informacoes de previsao para servico Agendado na inclusao ou para
 # servico liberado sem regulacao
 if l_param.imdsrvflg = "N" and
    (k_cts02m08.operacao = 0 or k_cts02m08.operacao = 2 or k_cts02m08.operacao = 3)
    then
    let d_cts02m08.atdhorprg = null
    let d_cts02m08.atddatprg = null
 end if

 input by name d_cts02m08.atdpvtretflg
              ,d_cts02m08.atddatprg
              ,d_cts02m08.atdhorprg
       without defaults

  before input

     display by name d_cts02m08.atdhorpvt
     display by name d_cts02m08.atddatprg
     display by name d_cts02m08.atdhorprg
     display by name d_cts02m08.atdpvtretflg

     if l_param.imdsrvflg = "N"
        then
        let d_cts02m08.atdhorpvt = null
        display by name d_cts02m08.atdhorpvt
     end if

     # verifica se atdfnlflg = s, se sim nao altera atendimento e exibe
     # dados atuais na tela
     if l_param.atdfnlflg = "S"
        then
        prompt " (F17)Abandona " for char  prompt_key
        exit input
     end if

     if l_param.imdsrvflg = "S"
        then

        while true

           if l_param.imdsrvflg = "S" and l_digitavel = true and k_cts02m08.operacao = 0
              then

              # RETIRA INFORMACOES DE DATA E HORA PROGRAMADA
              let d_cts02m08.atddatprg = null
              let d_cts02m08.atdhorprg = null

              # OBTEM DATA E HORA ATUAL
              call cts40g03_data_hora_banco(2)
                    returning l_data
                             ,l_hora2

              let l_data_char = null
              let l_data_char = l_data

              let mr_req_reg_agenda.srvhordat = l_data_char[7,10] clipped
                                               ,"-" clipped
                                               ,l_data_char[4,5] clipped
                                               ,"-" clipped
                                               ,l_data_char[1,2] clipped
                                               ,"T" clipped
                                               ,l_hora2 clipped
                                               ,":00" clipped

              let mr_req_reg_agenda.imdsrvflg = "S"
              let d_cts02m08.imdsrvflg = "S"

              # let k_cts02m08.atddatprg = l_data
              # let k_cts02m08.atdhorprg = l_hora2
              # let d_cts02m08.atddatprg = l_data
              # let d_cts02m08.atdhorprg = l_hora2

              display by name d_cts02m08.atddatprg
              display by name d_cts02m08.atdhorprg

              # CHAMADA DO REGULAR AGENDA

              error "Obtendo previsao de atendimento e regulando agenda..."
              call cts02m08_regular_agenda() returning l_erro_reg_agd, l_nro_registros

              if l_erro_reg_agd = 0 then
                 if ma_res_reg_agenda[1].sts = "OK" then

                    # REGULACAO IMEDIATO OK
                    let k_cts02m08.operacao = 1

                    let d_cts02m08.atdhorpvt = ma_res_reg_agenda[1].atdhorpvt
                    let l_rsrchv = ma_res_reg_agenda[1].rsrchv

                    display by name d_cts02m08.atdhorpvt

                    error "Regulacao da agenda executada com sucesso!"
                    exit while
                 else

                    let mr_req_reg_agenda.imdsrvflg = "N"
                    let d_cts02m08.imdsrvflg = "N"

                    # REGULACAO IMEDIATO NOK - SERVICO ALTERA PARA AGENDADO
                    error "Nao ha cota disponivel. Alterado para agendado."

                    sleep 2

                    error "Ha sugestoes disponiveis."

                    call cts02m08_sugerir_agenda(l_nro_registros)
                         returning l_atddatprg
                                  ,l_atdhorprg
                                  ,l_erro_sug_ag

                    if l_erro_sug_ag = 0 then
                       let d_cts02m08.atdhorprg = l_atdhorprg
                       let d_cts02m08.atddatprg = l_atddatprg

                       display by name d_cts02m08.atdhorprg
                       display by name d_cts02m08.atddatprg
                    else
                       error " Erro ao obter agendamento sugerido "
                    end if
                 end if
                 # next field atdpvtretflg
                 exit while
              else
                 # cancelado o uso do servico obter previsao, usar a previsao padrao
                  # ERRO AO REGULAR AGENDA, SERA CHAMADO OBTER PREVISAO

                  # error "Erro de MQ regular agenda (imediato). Tentaremos chamar obter previsao!."
                  # sleep 3
                  #
                  # call cts02m08_obter_previsao()
                  #       returning l_erro_obt_prv
                  #
                  # if l_erro_obt_prv = 0 then
                  #
                  #      # OBTER PREVISAO OK
                  #
                  #      # INICIO - DISPLAY LOG
                  #      error "Sucesso ao chamar MQ obter previsao."
                  #      sleep 3
                  #      # FIM - DISPLAY LOG
                  #
                  #      # POPULAR CONTROLE "O QUE FOI FEITO"
                  #      let k_cts02m08.operacao = null
                  #      let k_cts02m08.operacao = 2
                  #
                  #      let d_cts02m08.atdhorpvt = m_previsao
                  #      display by name d_cts02m08.atdhorpvt
                  #      next field atdpvtretflg
                  #
                  # else

                  # ERRO AO OBTER PREVISAO, SERA CONSULTADO PREV. PADRAO
                  # INICIO - DISPLAY LOG
                  #  error "Erro chamar MQ obter previsao. Tentaremos consulta previsao padrao."
                  #  sleep 3
                 # FIM - DISPLAY LOG

                 # falha no processo liberar sem regulacao

                 let k_cts02m08.operacao = 2
                 let d_cts02m08.atdhorpvt    = k_cts02m08.atdhorpvt
                 let d_cts02m08.atddatprg    = k_cts02m08.atddatprg
                 let d_cts02m08.atdhorprg    = k_cts02m08.atdhorprg
                 let d_cts02m08.atdpvtretflg = k_cts02m08.atdpvtretflg
                 let d_cts02m08.imdsrvflg    = l_param.imdsrvflg

                 error "Previsao obtida do sistema INFORMIX!"
                 sleep 1
                 error ""

                 exit while
              end if
           else
              if k_cts02m08.operacao = 5  # somente consultando o laudo checa
                 then
                 #display "Servico imediato, somente consultando..."
                 exit while
              end if

              if k_cts02m08.operacao = 4  # entrou novamente com chave valida, checar e sair
                 then
                 call ctd41g00_checar_reserva(k_cts02m08.rsrchv)
                      returning l_reserva_ativa

                 if l_reserva_ativa = true
                    then
                    let l_rsrchv = k_cts02m08.rsrchv
                    let k_cts02m08.operacao = 1

                    error "Regulacao realizada e valida, continuar o processo."
                    # next field atdpvtretflg
                    exit while
                 else   # chave nao mais valida, faz o regula novamente
                    let l_digitavel = true
                    let k_cts02m08.operacao = 0

                    continue while
                 end if

              else

                  exit while
              end if
           end if

        end while

     end if

     if d_cts02m08.imdsrvflg = "S" and
        (d_cts02m08.atdhorpvt is null or d_cts02m08.atdhorpvt = "")
        then
        let l_previsao_padrao = null

        call cts02m08_previsao_padrao() returning l_previsao_padrao

        if l_previsao_padrao is not null
           then
           let d_cts02m08.atdhorpvt = l_previsao_padrao
           display by name d_cts02m08.atdhorpvt
        else

           error "Previsao de atendimento nao localizada"
        end if
     end if

  before field atdpvtretflg
     display by name d_cts02m08.atdpvtretflg attribute (reverse)

  after  field atdpvtretflg
     display by name d_cts02m08.atdpvtretflg

     if fgl_lastkey() = fgl_keyval("up")   and
        fgl_lastkey() = fgl_keyval("left")
        then
        next field atdpvtretflg
     end if

     if d_cts02m08.atdpvtretflg is null  or
       (d_cts02m08.atdpvtretflg <> "S" and d_cts02m08.atdpvtretflg <> "N")
        then
        error " Retorno ao Segurado deve ser (S)im ou (N)ao!"
        next field atdpvtretflg
     end if

     if d_cts02m08.imdsrvflg = "S"
        then
        exit input
     end if

  before field atddatprg
     display by name d_cts02m08.atddatprg attribute (reverse)

  after  field atddatprg
     display by name d_cts02m08.atddatprg

     if d_cts02m08.imdsrvflg = "N"
        then

        if d_cts02m08.atddatprg is null or d_cts02m08.atddatprg = 0
           then
           error " Data programada deve ser informada para servico"
                ," programado!"
           next field atddatprg
        end if

        call cts40g03_data_hora_banco(2)
             returning l_data
                      ,l_hora2

        if d_cts02m08.atddatprg < l_data   then
           error " Data programada menor que data atual!"
           next field atddatprg
        end if

        call cts02m08_busca_limite() returning lr_retorno.*

        let l_data_limite = l_data + lr_retorno.agdlimqtd units day

        if d_cts02m08.atddatprg > l_data_limite and
           g_documento.ciaempcod <> 27                 then
           let l_mens = " Data programada para mais de "
                        , lr_retorno.agdlimqtd clipped , " dias !"
           error l_mens
           let d_cts02m08.atddatprg = null
           next field atddatprg
        end if
     end if

  before field atdhorprg
     display by name d_cts02m08.atdhorprg attribute (reverse)

  after  field atdhorprg
     display by name d_cts02m08.atdhorprg

     if fgl_lastkey() = fgl_keyval("up")   or
        fgl_lastkey() = fgl_keyval("left") then
        next field atddatprg
     end if

     if d_cts02m08.imdsrvflg = "N"
        then

        if d_cts02m08.atdhorprg is null or
           d_cts02m08.atdhorprg =  0    then
           error " Hora programada deve ser informada para servico programado!"
           next field atdhorprg
        end if

        call cts40g03_data_hora_banco(2)
             returning l_data, l_hora2

        let l_hora3 = l_hora2 + 1 units hour

        if d_cts02m08.atddatprg = l_data   and
           d_cts02m08.atdhorprg < l_hora3  then
           error " Hora programada n�o pode ser menor que a carencia minima!"
           let l_erro_atdhorprg = true
           next field atdhorprg
        end if

        if d_cts02m08.atddatprg = l_data and
           d_cts02m08.atdhorprg < l_hora2 then
           error "Nao e' possivel abrir servico com hora retroativa"
           let l_erro_atdhorprg = true
           next field atdhorprg
        end if

        # agenda so permite hora cheia xx:00 ou xx:30
        initialize l_min, l_horaux to null
        let l_horaux = d_cts02m08.atdhorprg
        let l_min = l_horaux[4,5]
        let l_min = l_min using "&&"

        if l_min != '00' and l_min != '30'
           then
           error 'Agendamento permitido somente para hora cheia (xx:00 ou xx:30)'
           next field atdhorprg
        end if
     end if

     if g_documento.acao = "ALT"
        then
        call cts02m08_id_datahora_cota(k_cts02m08.rsrchv)
             returning l_errcod, l_errmsg, l_agncotdatant, l_agncothorant

        if l_errcod != 0
           then

           display l_errmsg clipped
        end if

        # verifica se alterou data/hora para regular novamente
        if d_cts02m08.atddatprg is not null and
           d_cts02m08.atdhorprg is not null and
           ( (l_agncotdatant != d_cts02m08.atddatprg) or
             (l_agncothorant != d_cts02m08.atdhorprg) )
           then
           let l_altdathor = true
           let k_cts02m08.operacao = 0
        end if
     end if

     # CHAMAR "REGULAR AGENDA"
     while true

        display by name d_cts02m08.atdhorprg
        display by name d_cts02m08.atddatprg

        # somente consulta a partir do RADIO
        if (l_altdathor = false and l_param.altcidufd = false and k_cts02m08.operacao = 5)
           then

           exit while
        end if

        # regulou com sucesso sem alteracao ou liberado sem regulacao, retorna ao laudo
        if (l_altdathor = false and l_param.altcidufd = false and k_cts02m08.operacao = 1) or
           k_cts02m08.operacao = 2
           then

           error "Regulacao realizada, continuar o processo."
           exit while
        end if

        # regulou com sucesso, entrou novamente na tela e cota ainda valida, retorna ao laudo
        if (l_altdathor = false and l_param.altcidufd = false and k_cts02m08.operacao = 4)
           then
           call ctd41g00_checar_reserva(k_cts02m08.rsrchv)
                returning l_reserva_ativa

            if l_reserva_ativa = true
               then
               let l_rsrchv = k_cts02m08.rsrchv

               error "Regulacao realizada e valida, continuar o processo."
               exit while
            end if
        end if

        let l_atddatprg = null
        let l_atdhorprg = null
        let l_data_char = null
        let l_data_char = d_cts02m08.atddatprg

        let mr_req_reg_agenda.srvhordat = l_data_char[7,10] clipped
                                         ,"-" clipped
                                         ,l_data_char[4,5] clipped
                                         ,"-" clipped
                                         ,l_data_char[1,2] clipped
                                         ,"T" clipped
                                         ,d_cts02m08.atdhorprg clipped
                                         ,":00" clipped

        # let mr_req_reg_agenda.imdsrvflg = "N"
        # let d_cts02m08.imdsrvflg = mr_req_reg_agenda.imdsrvflg
        error "Regulando agenda para servico agendado..."
        call cts02m08_regular_agenda() returning l_erro_reg_agd, l_nro_registros

        if l_erro_reg_agd = 0 then
           if ma_res_reg_agenda[1].sts = "OK" then

              # REGULACAO AGENDADO OK
              let k_cts02m08.operacao = 1

              let l_rsrchv = ma_res_reg_agenda[1].rsrchv

              # INICIO - DISPLAY LOG
              error "Regulacao da agenda executada com sucesso!"
              # FIM - DISPLAY LOG

              exit while

           else

              # REGULACAO AGENDADO NOK, SERAO EXIBIDAS SUGESTOES

              # INICIO - DISPLAY LOG
              error "Nao ha cota disponivel."
              sleep 1
              # FIM - DISPLAY LOG

              let k_cts02m08.operacao = null

              if ma_res_reg_agenda[1].horfxa is not null and
                 ma_res_reg_agenda[1].srvhordat is not null then

                 # se prestador no local e nao achou cota, libera sem regulacao
                 # regra confirmada pelo Renato Bastos em 21/08/14
                 if l_param.prslocflg is not null and l_param.prslocflg = 'S'
                    then
                    let k_cts02m08.operacao = 2

                    exit while
                 else
                    # CENARIO COM SUGESTOES
                    error "Ha sugestoes disponiveis."

                    call cts02m08_sugerir_agenda(l_nro_registros)
                         returning l_atddatprg
                                  ,l_atdhorprg
                                  ,l_erro_sug_ag

                    if l_erro_sug_ag = 0 then
                       let d_cts02m08.atdhorprg = l_atdhorprg
                       let d_cts02m08.atddatprg = l_atddatprg

                       display by name d_cts02m08.atdhorprg
                       display by name d_cts02m08.atddatprg

                       continue while  # se trouxe cota, faz o while novamente, regula e flag operacao = 1
                    else
                       error " Erro ao obter agendamento sugerido "
                       let k_cts02m08.operacao = null
                       exit while
                    end if
                 end if

              else

                 # CENARIO SEM SUGESTOES, LIBERAR SEM REGULACAO

                 # INICIO - DISPLAY LOG
                 error "Nao ha sugestoes disponiveis, sera liberado sem regulacao."

                 sleep 1
                 # FIM - DISPLAY LOG

                 let k_cts02m08.operacao = 2
                 exit while

              end if
           end if
        else

            # ERRO AO CHAMAR REGULAR AGENDA, LIBERAR SEM REGULACAO

            # INICIO - DISPLAY LOG
            error "Nao foi possivel regular servico agendado. Liberando sem regulacao!"

            sleep 2
            # FIM - DISPLAY LOG

            let k_cts02m08.operacao = 2
            exit while

        end if
     end while

     if k_cts02m08.operacao is null then
          next field atdhorprg
     end if

  on key (interrupt)

     if l_erro_atdhorprg then
          let d_cts02m08.atdhorprg = null
          let l_erro_atdhorprg = false
          next field atdhorprg
     end if

     if d_cts02m08.imdsrvflg is null
        then
         let d_cts02m08.imdsrvflg = l_param.imdsrvflg
     end if

     if k_cts02m08.operacao = 1  # manter o status na consulta a partir do radio
        then
        let k_cts02m08.operacao = 4

     end if

     let l_imputcancelou = true

     exit input

 end input

 close window cts02m08

 if l_imputcancelou then
 	 let int_flag = true
 else
 	 let int_flag = false
 end if

 return d_cts02m08.*
      , l_rsrchv
      , k_cts02m08.operacao
      , l_altdathor

end function

#-----------------------------------------------------------
function cts02m08_regular_agenda()
#-----------------------------------------------------------

 # VARIAVEIS UTILIZADAS NA FUNCAO
 define l_coderro       smallint     # Codigo de erro do retorno MQ
       ,l_msg_erro      char(30)     # Mensagem de erro do retorno MQ
       ,l_xml_envio     char(5000)   # XML enviado para o MQ
       ,l_xml_retorno   char(32000)  # XML retornado pelo MQ
       ,l_nro_registros smallint     # Numero de registros encontrados no parse
       ,l_erro_reg_agd  smallint     # Controle de erro da funcao
       ,l_msgEmail      varchar(255) # Solicitacao Renato Bastos
       ,l_online smallint

 # INICIALIZACAO DE VARIAVEIS
 initialize l_coderro
           ,l_msg_erro
           ,l_xml_envio
           ,l_xml_retorno
           ,ma_res_reg_agenda
           ,l_erro_reg_agd
           ,l_nro_registros
           ,l_msgEmail
           ,l_online
 to null

 # GERAR XML DE ENVIO
 call cts02m08_gera_xml_envio(1)
      returning l_xml_envio

 let l_online = online()
 call figrc006_enviar_pseudo_mq("PSOREGAGENSOA01R",
                                l_xml_envio clipped,
                                l_online)
           returning l_coderro
                    ,l_msg_erro
                    ,l_xml_retorno

 # VALIDAR RETORNO
 if l_coderro = 0 then
     call cts02m08_parse_xml_retorno(l_xml_retorno, 1)
          returning l_nro_registros

     if l_nro_registros > 0 then
          if ma_res_reg_agenda[1].sts = "OK" or
             ma_res_reg_agenda[1].sts = "NOK" then
               let l_erro_reg_agd = 0
          else
               let l_erro_reg_agd = 1
               ##--SPR-2015-13411 - Inicio
               let l_msgEmail = "Erro:  ao regular agenda Parse XML! "
                           ,"Dados importantes UF= ",mr_req_reg_agenda.srvufsgl
                           ,", CIDADE= ",mr_req_reg_agenda.srvcidnom     clipped
                           ,", DATA HORA= ",mr_req_reg_agenda.srvhordat  clipped
                           ,", TIPO SERV= ", mr_req_reg_agenda.imdsrvflg clipped
                           ,", TIP ASS= ",mr_req_reg_agenda.asitipcod    clipped
                           ,", CATEGORIA TARIF= ",mr_req_reg_agenda.ctgtrfcod clipped
                           ,", ORIGREM= ",mr_req_reg_agenda.atdsrvorg    clipped
                           ,", NATUREZA= ",mr_req_reg_agenda.socntzcod   clipped
                           ,", SUB NTZ= ",mr_req_reg_agenda.socntzsub    clipped

             if mr_req_reg_agenda.empcod <> 43 then
                 call cts02m08_enviar_email(l_msgEmail)
              else
              	 let l_coderro = 999 ## Indicar que ocorreu erro no Parse XML
                 call cts02m08_enviar_email_portofaz(l_coderro)
              end if
              ##--SPR-2015-13411 - Fim
          end if
     else
          let l_erro_reg_agd = 1
          ##--SPR-2015-13411 - Inicio
          let l_msgEmail = "Erro: ",l_coderro," ao regular cota da agenda! "
                      ,"Dados importantes UF= ",mr_req_reg_agenda.srvufsgl
                      ,", CIDADE= ",mr_req_reg_agenda.srvcidnom     clipped
                      ,", DATA HORA= ",mr_req_reg_agenda.srvhordat  clipped
                      ,", TIPO SERV= ", mr_req_reg_agenda.imdsrvflg clipped
                      ,", TIP ASS= ",mr_req_reg_agenda.asitipcod    clipped
                      ,", CATEGORIA TARIF= ",mr_req_reg_agenda.ctgtrfcod clipped
                      ,", ORIGREM= ",mr_req_reg_agenda.atdsrvorg    clipped
                      ,", NATUREZA= ",mr_req_reg_agenda.socntzcod   clipped
                      ,", SUB NTZ= ",mr_req_reg_agenda.socntzsub    clipped

        if mr_req_reg_agenda.empcod <> 43 then
            call cts02m08_enviar_email(l_msgEmail)
         else
         	  if l_coderro = 0 then
         	     let l_coderro = 998 ## Indicar que ocorreu erro ao regular cota da agenda
            end if
            call cts02m08_enviar_email_portofaz(l_coderro)
         end if
         ##--SPR-2015-13411 - Fim
     end if
 else

     let l_erro_reg_agd = 1

     let l_msgEmail = "Erro: ",l_coderro," ao regular cota da agenda! "
                      ,"Dados importantes UF= ",mr_req_reg_agenda.srvufsgl
                      ,", CIDADE= ",mr_req_reg_agenda.srvcidnom     clipped
                      ,", DATA HORA= ",mr_req_reg_agenda.srvhordat  clipped
                      ,", TIPO SERV= ", mr_req_reg_agenda.imdsrvflg clipped
                      ,", TIP ASS= ",mr_req_reg_agenda.asitipcod    clipped
                      ,", CATEGORIA TARIF= ",mr_req_reg_agenda.ctgtrfcod clipped
                      ,", ORIGREM= ",mr_req_reg_agenda.atdsrvorg    clipped
                      ,", NATUREZA= ",mr_req_reg_agenda.socntzcod   clipped
                      ,", SUB NTZ= ",mr_req_reg_agenda.socntzsub    clipped

     if mr_req_reg_agenda.empcod <> 43 then
        call cts02m08_enviar_email(l_msgEmail)
     else
     	  if l_coderro = 0 then
     	     let l_coderro = 998 ## Indicar que ocorreu erro ao regular cota da agenda
        end if
        call cts02m08_enviar_email_portofaz(l_coderro)
     end if

 end if

 # RETORNO DA FUNCAO
 return l_erro_reg_agd, l_nro_registros

end function

# cancelado o uso do servico obter previsao
 # #-----------------------------------------------------------
 # function cts02m08_obter_previsao()
 # #-----------------------------------------------------------
 #
 #  # VARIAVEIS UTILIZADAS NA FUNCAO
 #  define l_coderro       smallint    # Codigo de erro do retorno MQ
 #        ,l_msg_erro      char(30)    # Mensagem de erro do retorno MQ
 #        ,l_xml_envio     char(5000)  # XML enviado para o MQ
 #        ,l_xml_retorno   char(32000) # XML retornado pelo MQ
 #        ,l_xml_limpo     char(32000) # XML de retorno sem os namespaces
 #        ,l_nro_registros smallint    # Numero de registros encontrados no parse
 #        ,l_erro_obt_prv  smallint    # Controle de erro da funcao
 #        ,l_docHandle     integer     # ID do xml na memoria
 #
 #  # INICIALIZACAO DE VARIAVEIS
 #  initialize l_coderro
 #            ,l_msg_erro
 #            ,l_xml_envio
 #            ,l_xml_retorno
 #            ,l_erro_obt_prv
 #            ,l_nro_registros
 #            ,m_previsao
 #            ,l_docHandle
 #  to null
 #
 #  # GERAR XML DE ENVIO
 #  call cts02m08_gera_xml_envio(2)
 #            returning l_xml_envio, l_docHandle
 #
 #  ### INICIO - DISPLAY LOG
 #  display "XML Enviado (Obter Previsao)"
 #  display l_xml_envio clipped
 #  ### FIM - DISPLAY LOG
 #
 #  # ACIONAR FILA MQ
 #  call figrc006_enviar_pseudo_mq('PSOOBTPREVSOA01R',
 #                                  l_xml_envio clipped,
 #                                  online())
 #            returning l_coderro
 #                     ,l_msg_erro
 #                     ,l_xml_retorno
 #
 #   ### INICIO - DISPLAY LOG
 #  display "XML Retornado (Obter Previsao)"
 #  display l_xml_retorno clipped
 #  display "C�digo MQ (Obter Previsao): ", l_coderro
 #  ### FIM - DISPLAY LOG
 #
 #  # VALIDAR RETORNO
 #  if l_coderro = 0 then
 #
 #      call cts02m08_retira_namespce(l_xml_retorno)
 #           returning l_xml_limpo
 #
 #      call cts02m08_parse_xml_retorno(l_xml_limpo, 2)
 #           returning l_nro_registros
 #
 #      if l_nro_registros = 1 then
 #           if m_previsao is not null then
 #                let l_erro_obt_prv = 0
 #           else
 #                let l_erro_obt_prv = 1
 #           end if
 #      else
 #           let l_erro_obt_prv = 1
 #      end if
 #  else
 #      let l_erro_obt_prv = 1
 #  end if
 #
 #  # RETORNO DA FUNCAO
 #  return l_erro_obt_prv
 #
 # end function

#-----------------------------------------------------------
function cts02m08_gera_xml_envio(l_tipo_xml)
#-----------------------------------------------------------

 # VARIAVEIS UTILIZADAS NA FUNCAO
 define l_xml_envio      char(5000)   # XML enviado para o MQ
       ,l_tipo_xml       smallint     # Tipo do XML a ser montado:
                                      # 1) Regular Agenda
                                      # 2) Obter Previsao
       ,l_docHandle      integer      # ID do XML da memoria
       ,l_nomcid         like datmlcl.cidnom
       ,l_totcid         smallint

 # INICIALIZACAO DE VARIAVEIS
 initialize l_xml_envio
           ,l_docHandle
 to null

 if m_prep_cts02m08 is null or m_prep_cts02m08 = false
    then
    call cts02m08_prepare()
 end if

 # MONTAGEM XML DO REGULAR AGENDA
 if l_tipo_xml = 1 then

    # Criacao do XML da memoria
    let l_docHandle = figrc011_novo_xml("regularAgendaIn")

    # TAG DataHoraServico
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parDataHoraServico",
    mr_req_reg_agenda.srvhordat clipped)

    # Ajusta nome da cidade
    let l_nomcid = mr_req_reg_agenda.srvcidnom clipped, '%'
    open  ccts02m08004 using mr_req_reg_agenda.srvufsgl,
                             l_nomcid
    fetch ccts02m08004 into l_totcid

    if l_totcid = 1 then
       open  ccts02m08005 using mr_req_reg_agenda.srvufsgl,
                                l_nomcid
       fetch ccts02m08005 into mr_req_reg_agenda.srvcidnom
       close ccts02m08005
    end if
    close ccts02m08005

    # TAG parNomeCidade
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parNomeCidade",
    mr_req_reg_agenda.srvcidnom clipped)

    # TAG parUF
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parUF",
    mr_req_reg_agenda.srvufsgl clipped)

    # TAG parCodigoCatTar
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parCodigoCatTar",
    mr_req_reg_agenda.ctgtrfcod using "&&" clipped)

    # TAG parServicoImediato
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parServicoImediato",
    mr_req_reg_agenda.imdsrvflg clipped)

    # TAG parCodigoVeiculo
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parCodigoVeiculo",
    mr_req_reg_agenda.vclcod using "&&&&&" clipped)

    # TAG parTipoEndereco
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parTipoEndereco",
    mr_req_reg_agenda.endindtpo using "&" clipped)

    # TAG parLatitude
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parLatitude",
    mr_req_reg_agenda.endltt using "-<<<<<<&&.&&&&&&" clipped)

    # TAG parLongitude
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parLongitude",
    mr_req_reg_agenda.endlgt using "-<<<<<<<&&.&&&&&&" clipped)

    # TAG parEmpresa
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parEmpresa",
    mr_req_reg_agenda.empcod using "&&" clipped)

    # TAG parCodigoOrigem
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parCodigoOrigem",
    mr_req_reg_agenda.atdsrvorg using "&&&&&" clipped)

    # TAG parCodigoAssistencia
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parCodigoAssistencia",
    mr_req_reg_agenda.asitipcod using "&&&&&" clipped)

    # TAG parCodigoNatureza
    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parCodigoNatureza",
    mr_req_reg_agenda.socntzcod using "&&&&&" clipped)

    # TAG parCodigoSubNatureza
    if mr_req_reg_agenda.socntzsub is null and
       mr_req_reg_agenda.socntzcod is not null
       then
       let mr_req_reg_agenda.socntzsub = 0
    end if

    call figrc011_atualiza_xml(l_docHandle,
    "/regularAgendaIn/parCodigoSubNatureza",
    mr_req_reg_agenda.socntzsub using "&&&&&" clipped)

    # RETORNO DO XML GERADO
    let l_xml_envio = figrc011_retorna_xml_gerado(l_docHandle)

    #libera o xml
    call figrc011_fim_novo_xml(l_docHandle)

 end if

 # cancelado o uso do servico obter previsao
  # MONTAGEM XML OBTER PREVISAO
  # if l_tipo_xml = 2 then
  #    let l_xml_envio = '<?xml version="1.0" encoding="UTF-8"?>'
  #                     ,'<ns0:obterPrevisaoIn xmlns:ns0="http://www.portoseguro.'
  #                     ,'com.br/atendimentoSocorrista/business/AgendaAtendimento'
  #                     ,'SocorristaEBM/V1_0/">'
  #
  #                         # TAG parNomeCidade
  #                        ,'<ns0:parNomeCidade>'
  #                        ,mr_req_reg_agenda.srvcidnom clipped
  #                        ,'</ns0:parNomeCidade>'
  #
  #                        # TAG parUF
  #                        ,'<ns0:parUF>'
  #                        ,mr_req_reg_agenda.srvufsgl clipped
  #                        ,'</ns0:parUF>'
  #
  #                        # TAG parCodigoEspecialidade
  #                        ,'<ns0:parCodigoEspecialidade>'
  #                        ,mr_req_reg_agenda.asitipcod using "&&&&&&&&&&" clipped
  #                        ,'</ns0:parCodigoEspecialidade>'
  #
  #                        # TAG parCodigoCatTar
  #                        ,'<ns0:parCodigoCatTar>'
  #                        ,mr_req_reg_agenda.ctgtrfcod using "&&" clipped
  #                        ,'</ns0:parCodigoCatTar>'
  #
  #                     ,'</ns0:obterPrevisaoIn>'
  #
  # end if

 return l_xml_envio

end function

#-----------------------------------------------------------
function cts02m08_parse_xml_retorno(l_xml_retorno, l_tipo_xml)
#-----------------------------------------------------------

 # PARAMETRO DE ENTRADA DA FUNCAO E VARIAVEIS INTERNAS
 define l_xml_retorno   char(32000) # XML para parse
       ,l_docHandle     integer     # Variavel para realizar parse
       ,l_path          char(200)   # Caminho generico do XML
       ,l_caminho       char(200)   # Caminho absoluto da TAG
       ,l_cursor        smallint    # Controle do cursor do parse
       ,l_fim           smallint    # Controle de fim do parse
       ,l_path_count    char(200)   # Caminho da TAG de registros
       ,l_nro_registros smallint    # Numero de registros encontrados no parse
       ,l_tipo_xml      smallint    # Tipo do XML a ser parseado:
                                           # 1) Regular Agenda
                                           # 2) Obter Previsao


 # INICIALIZACAO DAS VARIAVEIS INTERNAS
 initialize l_docHandle
           ,l_path
           ,l_path_count
           ,l_caminho
           ,l_cursor
           ,l_fim
           ,l_nro_registros
           ,ma_res_reg_agenda
           ,m_previsao
 to null

 # INICIO DO PARSE DO XML
 call figrc011_fim_parse()
 call figrc011_inicio_parse()
 let l_docHandle = figrc011_parse(l_xml_retorno)

 # PARSE XML REGULAR AGENDA
 if l_tipo_xml = 1 then

      let l_path = "/regularAgendaOut" clipped

      # VERIFICA QUANTOS REGISTROS FORAM ENCONTRADOS
      let l_path_count = "count(",l_path clipped,"/regulacao)"
      let l_nro_registros = figrc011_xpath(l_docHandle, l_path_count)

      if l_nro_registros > 1000 then
         let l_fim = 1000
         let l_nro_registros = 1000
      else
         let l_fim = l_nro_registros
      end if

      if l_nro_registros > 0 then
         for l_cursor = 1 to l_fim

           # STATUS
           let l_caminho = l_path clipped, "/regulacao["
                          ,l_cursor using "<<<<<<" ,"]/Status"
           let ma_res_reg_agenda[l_cursor].sts
           = figrc011_xpath(l_docHandle, l_caminho)

           # CHAVE DE RESERVA
           let l_caminho = l_path clipped, "/regulacao["
                          ,l_cursor using "<<<<<<" ,"]/ChaveReserva"
           let ma_res_reg_agenda[l_cursor].rsrchv
           = figrc011_xpath(l_docHandle, l_caminho)

           # PREVISAO DE ATENDIMENTO
           let l_caminho = l_path clipped, "/regulacao["
                          ,l_cursor using "<<<<<<" ,"]/PrevisaoAtendimento"
           let ma_res_reg_agenda[l_cursor].atdhorpvt
           = figrc011_xpath(l_docHandle, l_caminho)


           # FAIXA DE HORARIO
           let l_caminho = l_path clipped, "/regulacao["
                          ,l_cursor using "<<<<<<" ,"]/FaixaHorario"
           let ma_res_reg_agenda[l_cursor].horfxa
           = figrc011_xpath(l_docHandle, l_caminho)


           # DATA E HORA DO SERVICO
           let l_caminho = l_path clipped, "/regulacao["
                          ,l_cursor using "<<<<<<" ,"]/DataHoraServico"
           let ma_res_reg_agenda[l_cursor].srvhordat
           = figrc011_xpath(l_docHandle, l_caminho)

         end for
      end if
 end if


 call figrc011_fim_parse()

 return l_nro_registros

end function

#-----------------------------------------------------------
function cts02m08_sugerir_agenda(l_nro_registros)
#-----------------------------------------------------------

 # PARAMETRO DE ENTRADA DA FUNCAO E VARIAVEIS INTERNAS
 define l_cursor        smallint                # Controle do cursor
       ,l_pop_up        char(32000)             # Txt. para reinderizar o pop-up
       ,l_data_limite   date                    # Data limite agenda
       ,l_nro_registros smallint                # Nro. de registros (sugestoes)
       ,numero_selecao  smallint                # Nro. da selecao de sugestoes
       ,texto_selecao   char(40)                # Texto da selecao de sugestoes
       ,l_data          date                    # Data (date)
       ,l_hora          datetime hour to minute # Hora (datetime)
       ,l_data_popup    date                    # Data para popup
       ,l_erro_sug_ag   smallint                # Ctrl. de erro sugerir agenda
       ,l_linha         char(30)

 # INICIALIZACAO DAS VARIAVEIS INTERNAS
 initialize l_cursor
           ,l_pop_up
           ,l_data_limite
           ,numero_selecao
           ,texto_selecao
           ,l_data
           ,l_hora
           ,l_erro_sug_ag
           ,l_linha
 to null

 # MONTAGEM DAS SUGESTOES QUE SERAO CHAMADAS NO POPUP
 for l_cursor = 1 to l_nro_registros

       let l_data_popup = null
       let l_data_popup = ma_res_reg_agenda[l_cursor].srvhordat[1,10]
       initialize l_linha to null

       if ma_res_reg_agenda[l_cursor].horfxa[1,5] = ma_res_reg_agenda[l_cursor].horfxa[7,11]
          then
          let l_linha = l_data_popup using "dd/MM/yy", " ", ma_res_reg_agenda[l_cursor].horfxa[1,5]
       else
          let l_linha = l_data_popup using "dd/MM/yy", " entre "
                      , ma_res_reg_agenda[l_cursor].horfxa[1,5]
                      , " e ", ma_res_reg_agenda[l_cursor].horfxa[7,11]
       end if

       if l_cursor = 1 then
          let l_pop_up = l_pop_up clipped, l_linha clipped
       else
          if length(l_pop_up) > 31968 then
             exit for
          else
             let l_pop_up = l_pop_up clipped, "|" , l_linha clipped
          end if
       end if
 end for

 # CHAMADA DO POPUP
 call cts02m08_popup_sugestao('Agenda Disponivel',l_pop_up)
         returning numero_selecao
                  ,texto_selecao

 # VALIDACAO DO RETORNO
 if numero_selecao <> 0 then
      let l_data = texto_selecao[1,8]
      let l_erro_sug_ag = 0

      if length(texto_selecao) = 14
         then
         let l_hora = texto_selecao[10,14]
      else
         let l_hora = texto_selecao[16,20]
      end if
 else
      let l_data = null
      let l_hora = null
      let l_erro_sug_ag = 1
      error "Nao foi selecionado nenhum horario disponivel!"
 end if

 # RETORNO DA FUNCAO
 return l_data
       ,l_hora
       ,l_erro_sug_ag

end function

#-----------------------------------------------------------
function cts02m08_busca_limite()
#-----------------------------------------------------------

 # VARIAVEIS INTERNAS E INICIALIZACAO
 define l_agdlimqtd like datksrvtip.agdlimqtd # Quantidade de dias limite

 define lr_retorno record
        coderro smallint, # Codigo de erro banco de dados
        mens    char(300) # Mensagem de erro banco de dados
 end record

 initialize lr_retorno.*
           ,l_agdlimqtd
 to null

 # VERIFICA SE CONSULTA ESTA PREPARADA, CASO NAO PREPARA
 if m_prep_cts02m08 is null or
     m_prep_cts02m08 = false then
    call cts02m08_prepare()
 end if

 # ACESSO AO BANCO DE DADOS
 whenever error continue
 open ccts02m08001 using g_documento.atdsrvorg
 fetch ccts02m08001 into l_agdlimqtd
 whenever error stop

    # TRATATIVAS EM CASO DE ERRO
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno.coderro = sqlca.sqlcode
          let lr_retorno.mens = "Erro <",lr_retorno.coderro ,"> ao buscar "
                               ,"limite de agendamento, Avise a informatica !"
          error lr_retorno.mens
       else
          let lr_retorno.coderro = sqlca.sqlcode
          let lr_retorno.mens = "Erro <",lr_retorno.coderro ,"> ao buscar "
                               ,"limite de agendamento, Avise a informatica !"
          error lr_retorno.mens
       end if
    end if

 return lr_retorno.*,l_agdlimqtd

end function

#-----------------------------------------------------------
function cts02m08_previsao_padrao()
#-----------------------------------------------------------

 # VARIAVEIS INTERNAS E INICIALIZACAO
 define l_previsao_padrao datetime hour to minute # Previsao padrao
       ,l_parametro       char(100)               # Parametro para pesquisa
       ,l_erro            char(80)                # Mensagem de erro


 initialize l_previsao_padrao
           ,l_parametro
 to null

 let l_parametro = "PSOTMPPDRPRV"

 # VERIFICA SE CONSULTA ESTA PREPARADA, CASO NAO PREPARA
 if m_prep_cts02m08 is null or
    m_prep_cts02m08 = false then
    call cts02m08_prepare()
 end if

 # ACESSO AO BANCO DE DADOS
 whenever error continue
 open ccts02m08002 using l_parametro
 fetch ccts02m08002 into l_previsao_padrao
 whenever error stop

    # TRATATIVAS EM CASO DE ERRO
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let l_erro = "Erro <", sqlca.sqlcode,"> ao buscar previsao padrao, "
                      ,"Avise a informatica !"
          error l_erro
       else
          let l_erro = "Erro <", sqlca.sqlcode,"> ao buscar previsao padrao, "
                      ,"Avise a informatica !"
          error l_erro
       end if
    end if

 return l_previsao_padrao

end function

#-----------------------------------------------------------
function cts02m08_retira_namespce(l_xml)
#-----------------------------------------------------------

  # VARIAVEIS INTERNAS A INICIALIZACOES

  define l_array_quebras array [16000] of integer     # Array que armazena quebras
        ,l_linha_xmlns   integer     # Flag linha XLMS
        ,l_inicio_parse  integer     # Cursor inicio parse
        ,l_cursor        integer     # Cursor geral
        ,l_xml           char(32000) # XML recebido (param)
        ,l_tam_xml       integer     # Tamanho do XML recebido
        ,l_pos_array     integer     # Posicao do array
        ,l_dentro_tag    integer     # Flag dentro TAG
        ,l_xml_retorno   char(32000) # XML retornado
        ,l_posicao       integer     # Cursor de posicao
        ,l_pos_branco    integer     # Cursor de posicao branco
        ,l_qtd_brancos   integer     # Quantidade de branco
        ,l_brancos       char(200)   # Auxiliar de tratar brancos

  let l_inicio_parse = 0
  let l_posicao = 1
  let l_tam_xml = 0
  let l_linha_xmlns = true
  let l_cursor = 0
  let l_pos_array = 0
  let l_dentro_tag = false
  let l_pos_branco = false
  let l_qtd_brancos = 0

  initialize l_array_quebras
            ,l_xml_retorno
            ,l_brancos
            ,l_array_quebras
  to null

  # IDENTIFICAR O TAMANHO DO XML RECEBIDO (PARAM)

  let l_tam_xml = length(l_xml)

  # ALGORITMO PARA RETIRAR NAMECPACES DO XML

  for l_cursor = 1 to l_tam_xml
       if (l_xml[l_cursor, l_cursor + 2] = ' ?>') then
            let l_inicio_parse = l_cursor + 3
            exit for
       end if
  end for

  for l_cursor = l_inicio_parse to l_tam_xml

       if (l_xml[l_cursor, l_cursor + 5] = 'xmlns:') then
           let l_linha_xmlns = true
       end if

       if (l_linha_xmlns = true) then
            if (l_xml[l_cursor, l_cursor + 5] = 'xmlns:') then
                 let l_pos_array = l_pos_array + 1
                 let l_array_quebras[l_pos_array] = l_cursor - 2
                 continue for
            end if

            if (l_xml[l_cursor] = '>') then

                 if (l_xml[l_cursor -1] = '/') then
                    let l_pos_array = l_pos_array + 1
                    let l_array_quebras[l_pos_array] = l_cursor - 1
                    let l_linha_xmlns = false
                 else
                    let l_pos_array = l_pos_array + 1
                    let l_array_quebras[l_pos_array] = l_cursor
                    let l_linha_xmlns = false
                 end if

            end if
       end if

       if (l_linha_xmlns = false) then

            if (l_xml[l_cursor] = '<') then
                 let l_dentro_tag = true
            end if

            if (l_xml[l_cursor] = '>') then
                 let l_dentro_tag = false
            end if

            if l_dentro_tag = true then
                 if l_xml[l_cursor] = '<' then
                      if (l_xml[l_cursor + 1] = '/') then
                           let l_pos_array = l_pos_array + 1
                           let l_array_quebras[l_pos_array] = l_cursor + 1
                      else
                           let l_pos_array = l_pos_array + 1
                           let l_array_quebras[l_pos_array] = l_cursor
                      end if
                 end if

                 if (l_xml[l_cursor - 1] = ":") then
                           let l_pos_array = l_pos_array + 1
                           let l_array_quebras[l_pos_array] = l_cursor
                 end if
            end if
       end if
  end for

  let l_posicao = 1
  for l_cursor = 1 to l_tam_xml

       if (l_cursor > l_array_quebras[l_posicao + 1]) then
            let l_posicao = l_posicao + 2
       end if

       if ((l_cursor > l_array_quebras[l_posicao])      and
           (l_cursor < l_array_quebras[l_posicao + 1])) then
            continue for
       else

            if l_xml[l_cursor] = ' ' then
                 let l_pos_branco = true
                 let l_qtd_brancos = l_qtd_brancos + 1
                 continue for
            end if

            if l_pos_branco = true then
                 let l_xml_retorno = l_xml_retorno clipped
                                    ,l_brancos[1,l_qtd_brancos]
                                    ,l_xml[l_cursor] clipped
                 let l_pos_branco = false
                 let l_qtd_brancos = 0
            else
                 let l_xml_retorno = l_xml_retorno clipped,l_xml[l_cursor] clipped
            end if

       end if

  end for

  # RETORNO DA FUNCAO (XML LIMPO)

  return l_xml_retorno

end function

#-----------------------------------------------------------
 function cts02m08_popup_sugestao(p_entrada)
#-----------------------------------------------------------

 # VARIAVEIS E RECORD E INICIALIZACOES

 define p_entrada record
        titulo    char(25),   # Titulo do pop-up
        popup     char(32000) # Sugestoes a serem reinderizadas
 end record

 define a_saida array[1000] of record
        fundes             char (40) # Destino da funcao
 end record

 define strpos      smallint # Posicao string
       ,strini      smallint # Inicio string
       ,scr_aux     smallint # Source array auxiliar
       ,arr_aux     smallint # Cursor array auxiliar
       ,fun_des     char (40)# Destino funcao
       ,w_pf1       integer  # Uso inteno da funcao

 initialize strpos
           ,strini
           ,scr_aux
           ,arr_aux
           ,fun_des
           ,a_saida
 to null

 for  w_pf1  =  1  to  1000
             initialize  a_saida[w_pf1].*  to  null
 end  for

 # ABERTURA DA TELA

 open window cts02m08a at 09,38 with form "cts02m08a"
      attribute(form line 1, message line last, border)


 let int_flag = false

 let arr_aux = 1
 let strini = 1
 let p_entrada.popup = p_entrada.popup clipped

 for strpos = 1 to length(p_entrada.popup)
     if p_entrada.popup[strpos, strpos] = "|" then
        let a_saida[arr_aux].fundes = p_entrada.popup[strini,strpos-1]

        if arr_aux = 1000 then
           exit for
        else
           let arr_aux = arr_aux + 1
           let strini = strpos + 1
        end if

     end if
 end for

 let a_saida[arr_aux].fundes = p_entrada.popup[strini,strpos-1]

 message "(F8)Seleciona"
 call set_count(arr_aux)

 display by name p_entrada.titulo
 display array a_saida to s_cts02m08.*
    on key (interrupt,control-c)
       initialize a_saida   to null
       let arr_aux = 0
       exit display
    on key (F8)
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       exit display
 end display

 # FECHAMENTO DA TELA

 close window cts02m08a

 # TRATIVA DA OPCAO ESCOLHIDA

 if arr_aux = 0 then
    let fun_des = ""
 else
    let fun_des = a_saida[arr_aux].fundes
 end if

 # RETORNO DA FUNCAO
 return arr_aux,
        fun_des

end function

#----------------------------------------------------------------
function cts02m08_id_datahora_cota(l_rsrchv)
#----------------------------------------------------------------

  define l_rsrchv     char(25)                   # Chave gerada no AW (slot)
       , l_agncotdat  date                       # Data da cota retornada pelo AW (data do slot)
       , l_agncothor  datetime hour to second    # Hora da cota retornada pelo AW (data do slot)
       , l_errcod     smallint
       , l_errmsg     char(80)
       , l_txtaux     char(20)

  initialize l_errcod, l_errmsg, l_agncotdat, l_agncothor, l_txtaux to null

  if l_rsrchv is null or l_rsrchv = '' or length(l_rsrchv) < 15  # tamanho minimo da chave
     then
     let l_errcod = 99
     let l_errmsg = 'cts02m08 - ID cota regulada parametro nulo'
     #display l_errmsg clipped
     return l_errcod, l_errmsg, l_agncotdat, l_agncothor
  end if

  # Estrutura da chave no AW
  # 01 dia
  # 08 mes
  # 2014 ano
  # 230159 hora/min/seg
  # 00000 codigo da chave, sequencial de 5 posicoes
  # 01082014230159000000

  let l_agncotdat = l_rsrchv[1,8]
  let l_txtaux    = l_rsrchv[9,10], ':', l_rsrchv[11,12], ':', l_rsrchv[13,14]
  let l_agncothor = l_txtaux
  let l_errcod = 0
  let l_errmsg = null

  return l_errcod, l_errmsg, l_agncotdat, l_agncothor

end function

#----------------------------------------------------------------
function cts02m08_id_datahora_seq(l_rsrchv)
#----------------------------------------------------------------

  define l_rsrchv       char(25)                   # Chave gerada no AW (slot)
       , l_agncotdat    date                       # Data da cota retornada pelo AW (data do slot)
       , l_agncothor    datetime hour to second    # Hora da cota retornada pelo AW (data do slot)
       , l_errcod       smallint
       , l_errmsg       char(80)
       , l_txtaux       char(20)
       , l_hrrrsrnum    decimal(10,0)               # conforme campos da tabela datrsrvrsr
       , l_srvrsrhordat datetime year to second    # conforme campos da tabela datrsrvrsr
       , l_tam          smallint

  initialize l_errcod, l_errmsg, l_agncotdat, l_agncothor, l_txtaux
           , l_hrrrsrnum, l_srvrsrhordat, l_tam to null

  if l_rsrchv is null or l_rsrchv = '' or length(l_rsrchv) < 15  # tamanho minimo da chave
     then
     let l_errcod = 99
     let l_errmsg = 'cts02m08 - ID cota parametro nulo'
     #display l_errmsg clipped
     return l_errcod, l_errmsg, l_agncotdat, l_agncothor
  end if

  # Estrutura da chave no AW
  # 01 dia
  # 08 mes
  # 2014 ano
  # 230159 hora/min/seg
  # 000000 codigo da chave, sequencial de 6 posicoes
  # 01082014230100999999

  # campos data e hora
  let l_agncotdat = l_rsrchv[1,8]
  let l_txtaux    = l_rsrchv[9,10], ':', l_rsrchv[11,12], ':', l_rsrchv[13,14]
  let l_agncothor = l_txtaux

  initialize l_txtaux to null

  # campos datetime e sequencial da cota
  let l_tam = length(l_rsrchv)

  let l_txtaux = l_rsrchv[5,8] , '-', l_rsrchv[3,4]  , '-', l_rsrchv[1,2], ' '
               , l_rsrchv[9,10], ':', l_rsrchv[11,12], ':', l_rsrchv[13,14]

  let l_srvrsrhordat = l_txtaux
  let l_hrrrsrnum    = l_rsrchv[15, l_tam]
  let l_errcod = 0
  let l_errmsg = null

  return l_errcod, l_errmsg, l_agncotdat, l_agncothor, l_hrrrsrnum, l_srvrsrhordat

end function

#----------------------------------------------------------------
function cts02m08_ins_cota(l_rsrchv, l_atdsrvnum, l_atdsrvano)
#----------------------------------------------------------------

  define l_rsrchv       char(25)
       , l_atdsrvnum    like datmservico.atdsrvnum
       , l_atdsrvano    like datmservico.atdsrvano
       , l_errcod       smallint
       , l_errmsg       char(80)
       , l_agncotdat    date
       , l_agncothor    datetime hour to second
       , l_hrrrsrnum    decimal(10,0)
       , l_srvrsrhordat datetime year to second

  initialize l_errcod, l_errmsg, l_agncotdat, l_agncothor, l_hrrrsrnum
           , l_srvrsrhordat to null

  if l_rsrchv is null or l_rsrchv = ''  or
     l_atdsrvnum is null or l_atdsrvnum <= 0 or
     l_atdsrvano is null or l_atdsrvano <= 0
     then
     let l_errcod = 99
     let l_errmsg = 'cts02m08 - Gravacao da regulacao, parametros nulos'

     return l_errcod, l_errmsg
  end if

  call cts02m08_id_datahora_seq(l_rsrchv)
       returning  l_errcod, l_errmsg, l_agncotdat, l_agncothor
                , l_hrrrsrnum, l_srvrsrhordat

  if l_errcod != 0
     then
     let l_errmsg = 'Gravacao da regulacao, erro ID datahora cota', l_errcod
     return l_errcod, l_errmsg
  end if

  whenever error continue

  insert into datrsrvrsr(atdsrvnum, atdsrvano, hrrrsrnum, srvrsrhordat)
  values (l_atdsrvnum, l_atdsrvano, l_hrrrsrnum, l_srvrsrhordat)

  let l_errcod = sqlca.sqlcode

  whenever error stop

  if l_errcod != 0
     then
     let l_errmsg = 'Gravacao da regulacao, erro ', l_errcod
  end if

  return l_errcod, l_errmsg

end function

#----------------------------------------------------------------
function cts02m08_sel_cota(l_atdsrvnum, l_atdsrvano)
#----------------------------------------------------------------

  define l_atdsrvnum    like datmservico.atdsrvnum
       , l_atdsrvano    like datmservico.atdsrvano
       , l_errcod       smallint
       , l_errmsg       char(80)
       , l_rsrchv       char(25)  # Chave gerada no AW (slot)
       , l_hrrrsrnum    decimal(10,0)
       , l_srvrsrhordat datetime year to second  # 2013-12-30 12:00:00
       , l_txtaux       char(20)
       , l_dia          char(02)
       , l_mes          char(02)
       , l_ano          char(04)
       , l_hor          char(02)
       , l_min          char(02)
       , l_sec          char(02)

  initialize l_errcod, l_errmsg, l_rsrchv, l_hrrrsrnum
           , l_srvrsrhordat, l_txtaux, l_dia, l_ano, l_mes, l_hor, l_min, l_sec  to null

  if l_atdsrvnum is null or l_atdsrvnum <= 0 or
     l_atdsrvano is null or l_atdsrvano <= 0
     then
     let l_errcod = 99
     let l_errmsg = 'cts02m08 - Selecao da regulacao, parametros nulos'
     #display l_errmsg clipped

     return l_errcod, l_errmsg
  end if

  whenever error continue

  select hrrrsrnum, srvrsrhordat into l_hrrrsrnum, l_srvrsrhordat
  from datrsrvrsr
  # from datrsrvrsr
  where atdsrvnum = l_atdsrvnum
    and atdsrvano = l_atdsrvano

  let l_errcod = sqlca.sqlcode

  whenever error stop

  if l_errcod != 0
     then
     let l_errmsg = 'Selecao da regulacao, erro ', l_errcod
     return l_errcod, l_errmsg, l_rsrchv
  end if

  # reconstruir a chave a partir do registro na tabela
  let l_txtaux = l_srvrsrhordat

  let l_dia = l_txtaux[09,10]
  let l_mes = l_txtaux[06,07]
  let l_ano = l_txtaux[01,04]
  let l_hor = l_txtaux[12,13]
  let l_min = l_txtaux[15,16]
  let l_sec = l_txtaux[18,19]

  let l_rsrchv = l_dia using "&&"
               , l_mes using "&&"
               , l_ano using "&&&&"
               , l_hor using "&&"
               , l_min using "&&"
               , l_sec using "&&"
               , l_hrrrsrnum using "<<<<<<<<<<"

  #display 'Chave refeita: ', l_rsrchv clipped

  return l_errcod, l_errmsg, l_rsrchv

end function

#----------------------------------------------------------------
function cts02m08_upd_cota(l_rsrchv, l_rsrchvant, l_atdsrvnum, l_atdsrvano)
#----------------------------------------------------------------

  define l_rsrchv       char(25)
       , l_rsrchvant    char(25)
       , l_atdsrvnum    like datmservico.atdsrvnum
       , l_atdsrvano    like datmservico.atdsrvano
       , l_errcod       smallint
       , l_errmsg       char(80)
       , l_agncotdat    date
       , l_agncothor    datetime hour to second
       , l_hrrrsrnum    decimal(10,0)
       , l_srvrsrhordat datetime year to second

  initialize l_errcod, l_errmsg, l_agncotdat, l_agncothor, l_hrrrsrnum
           , l_srvrsrhordat to null

  if l_rsrchv is null or l_rsrchv = ''  or
     l_atdsrvnum is null or l_atdsrvnum <= 0 or
     l_atdsrvano is null or l_atdsrvano <= 0
     then
     let l_errcod = 99
     let l_errmsg = 'cts02m08 - Atualizacao da regulacao, parametros nulos'
     #display l_errmsg clipped

     return
  end if

  call cts02m08_id_datahora_seq(l_rsrchv)
       returning  l_errcod, l_errmsg, l_agncotdat, l_agncothor
                , l_hrrrsrnum, l_srvrsrhordat

  if l_errcod != 0 or l_hrrrsrnum is null or l_srvrsrhordat is null
     then
     let l_errmsg = 'Atualizacao da regulacao, erro ID datahora cota', l_errcod
     return
  end if

  whenever error continue

  update datrsrvrsr
  # update datrsrvrsr
  set hrrrsrnum = l_hrrrsrnum, srvrsrhordat = l_srvrsrhordat
  where atdsrvnum = l_atdsrvnum
    and atdsrvano = l_atdsrvano

  let l_errcod = sqlca.sqlerrd[3]  # rows updated

  whenever error stop

  if l_errcod = 1
     then
     display 'Atualizacao da regulacao, sucesso'
  else
     let l_errmsg = 'Atualizacao da regulacao, erro ', l_errcod
     display l_errmsg clipped
  end if

end function

#----------------------------------------------------------------
function cts02m08_sel_ctgtrfcod(l_vclcoddig)
#----------------------------------------------------------------

  define l_vclcoddig dec(5,0)

  define l_errcod     smallint
       , l_errmsg     char(80)
       , l_ctgtrfcod  decimal(6,0)

  initialize l_errcod, l_errmsg, l_ctgtrfcod to null

  #display 'cts02m08_sel_ctgtrfcod entrada'

  if l_vclcoddig is null
     then
     let l_errcod = 99
     let l_errmsg = 'cts02m08_sel_ctgtrfcod, parametro nulo: ', l_vclcoddig
     #display l_errmsg clipped
     return l_errcod, l_errmsg, l_ctgtrfcod
  end if

  if m_prep_cts02m08 is null or m_prep_cts02m08 = false
     then
     call cts02m08_prepare()
  end if

  whenever error continue

  open ccts02m08003 using l_vclcoddig
  fetch ccts02m08003 into l_ctgtrfcod

  let l_errcod = sqlca.sqlcode

  whenever error stop

  if l_errcod != 0
     then
     let l_errmsg = 'cts02m08_sel_ctgtrfcod, erro: ', l_errcod, ' | vclcoddig: ', l_vclcoddig
     #display l_errmsg clipped
     return l_errcod, l_errmsg, l_ctgtrfcod
  end if

  return l_errcod, l_errmsg, l_ctgtrfcod

end function

#Envia email de erro com a integracao via MQ
#--------------------------------
function cts02m08_enviar_email(l_msgEmail)
#--------------------------------
define l_msgEmail      varchar(255)
      ,l_retorno       smallint

let l_retorno = null
##--SPR-2015-13411
##let l_retorno = ctx22g00_mail_corpo("AGENDA_PSO","Erro Agenda Porto Socorro",l_msgEmail)

##--SPR-2015-13411
let l_retorno = ctx22g00_mail_corpo("CTS02M08","Erro Agenda Porto Socorro",l_msgEmail)

if l_retorno <> 0 then
   if l_retorno <> 99 then
      error "Nao enviou email de erro na Agenda PSO. Avise Informatica!"
      sleep 2
   else
      error "Nao foi encontrado email para Agenda PSO."
      sleep 2
   end if
end if
end function #Fim ctd41g00_enviar_email

#Envia email de erro com a integracao via MQ para a PORTOFAZ
#--------------------------------------
function cts02m08_enviar_email_portofaz(l_coderro)
#--------------------------------------
 define l_coderro       smallint,     # Codigo de erro do retorno MQ
        l_msg           char(32000),
        l_retorno       smallint,
        l_natureza      char(30),
        l_cgccpf        char(16),
        l_data_char     char(20),
        l_mens_erro     char(30)

 let l_retorno   = null
 let l_natureza  = null
 let l_cgccpf    = null
 let l_data_char = null

 case l_coderro
 	    when 999
 	         let l_mens_erro = "Parse XML - MQ FORA" clipped
 	    when 998
 	    	   let l_mens_erro = "Regular Cota da Agenda-MQ FORA" clipped
 	    otherwise
 	          let l_mens_erro = l_coderro  ," - MQ FORA" clipped
 end case

 if g_documento.socntzdes is not null then
    let l_natureza = g_documento.socntzdes clipped
 else
	  let l_natureza = g_documento.asitipabvdes	clipped
 end if

 if g_documento.cgcord > 0 then
    let l_cgccpf   = g_documento.cgccpfnum using "&&&&&&&&"
                    ,"/"
                    ,g_documento.cgcord    using "&&&&"
                    ,"-"
                    ,g_documento.cgccpfdig using "&&"
 else
    let l_cgccpf   = g_documento.cgccpfnum using "&&&&&&&&&"
                    ,"-"
                    ,g_documento.cgccpfdig using "&&" clipped
 end if

 let l_data_char = mr_req_reg_agenda.srvhordat

 let l_data_char = l_data_char[9,10] clipped
                  ,"-" clipped
                 ,l_data_char[6,7] clipped
                 ,"-" clipped
                 ,l_data_char[1,4] clipped
                 ," "
                 ,l_data_char[12,16] clipped
                 ,":00" clipped

 let l_msg  =
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"',
  ' "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
  '<html xmlns="http://www.w3.org/1999/xhtml">',
  '<head>',
    '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />',
    '<title>Porto Seguro FAZ - Relat&oacute;rio de Servi&ccedil;o fechados',
      ' automaticamente pelo prestador',
    '</title>',
  '</head>',
  '<body bgcolor="#F6F6F6">',
  '<table width="650" border="0" align="center" cellpadding="10"',
     ' cellspacing="0">',
     '<tr>',
       '<td bgcolor="#FFFFFF"><a href="http://www.portosegurofaz.com.br/"',
         ' target="_blank"><img src="http://s1.portosegurofaz.com.br/skin/',
         'frontend/portoseguro/default/images/logo.png" width="219"',
         ' height="51" border="0" /></a>',
      '</td>',
     '</tr>',
     '<tr>',
       '<td bgcolor="#FFFFFF"><h1 style="font-family:Verdana;font-size:20px;',
         '">Problema Integra&ccedil;&atilde;o - Agenda Porto Socorro</h1>',
       '</td>',
     '</tr>',
     '<tr>',
        '<td bgcolor="#FFFFFF">',
          '<table width="100%" border="0" cellspacing="1"',
              ' cellpadding="10">',
            '<tr>',
              '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
                '#FFFFFF;font-family:Verdana;font-size:12px;">ERRO</span>',
                '</strong>',
              '</td>',
              '<td><span style="color:#333333;font-family:Verdana;font-size:',
              ##   '12px;">',l_coderro,' - MQ FORA</span>',
              '12px;">',l_mens_erro,'</span>',
              '</td>',
            '</tr>',
            '<tr>',
               '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
                 '#FFFFFF;font-family:Verdana;font-size:12px;">CPF</span>',
                 '</strong>',
               '</td>',
               '<td><span style="color:#333333;font-family:Verdana;',
                  'font-size:12px;">',l_cgccpf,'</span>',
               '</td>',
            '</tr>',
            '<tr>',
              '<td bgcolor="#00ADF5" align="right"><strong><span style="color:#',
                'FFFFFF;font-family:Verdana;font-size:12px;">CIDADE</span>',
                '</strong>',
              '</td>',
              '<td><span style="color:#333333;font-family:Verdana;font-size:12px;',
                 '">',mr_req_reg_agenda.srvcidnom,'</span>',
              '</td>',
            '</tr>',
            '<tr>',
              '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
              '#FFFFFF;font-family:Verdana;font-size:12px;">UF</span></strong>',
           '</td>',
        '<td><span style="color:#333333;font-family:Verdana;font-size:12px;">',
          mr_req_reg_agenda.srvufsgl,'</span>',
        '</td>',
     '</tr>',
     '<tr>',
        '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
          '#FFFFFF;font-family:Verdana;font-size:12px;">HOR&Aacute;RIO AGENDADO',
          '</span></strong>',
        '</td>',
        '<td><span style="color:#333333;font-family:Verdana;font-size:12px;',
          '">',l_data_char,'</span>',
        '</td>',
     '</tr>',
     '<tr>',
        '<td bgcolor="#00ADF5" align="right"><strong><span style="color:',
          '#FFFFFF;font-family:Verdana;font-size:12px;">NATUREZA</span>',
          '</strong>',
        '</td>',
        '<td><span style="color:#333333;font-family:Verdana;font-size:',
           '12px;">',l_natureza,'</span>',
        '</td>',
     '</tr>',
     '<tr>',
        '<td width="29%" bgcolor="#00ADF5" align="right"><strong><span',
           ' style="color:#FFFFFF;font-family:Verdana;font-size:12px;',
           '">PROBLEMA</span></strong>',
        '</td>',
        '<td width="71%"><span style="color:#333333;font-family:Verdana',
           ';font-size:12px;">',g_documento.atddfttxt,'</span>',
        '</td>',
     '</tr>',
     '</table>',
    '</td>',
   '</tr>',
  '</table>',
'</body>',
'</html>'

 let l_retorno = ctx22g00_envia_email_html("PTS02M08",
                                           "Erro Agenda Porto Socorro",l_msg)

 if l_retorno <> 0 then
    if l_retorno <> 99 then
       error "Nao enviou email de erro na Agenda PSO Portofaz. Avise Informatica!"
       sleep 2
    else
       error "Nao foi encontrado email para Agenda PSO Portofaz."
       sleep 2
    end if
 end if

end function #Fim cts02m08_enviar_email_portofaz

#------------------------------
# Eliane K. Fornax 16/03/2016
#-----------------------------------------------------------------------
function cts02m08_obtem_agenda(lr_req_reg_agenda)
#------------------------------------------------------------------------

 # RECORDS DE ENTRADA DA FUNCAO
 define lr_req_reg_agenda record
    srvhordat             char(19)  # Data e hora do servico
   ,srvcidnom             char(50)  # Nome da cidade do servico
   ,srvufsgl              char(02)  # UF da cidade so servico
   ,asstipcod             dec(12,0) # Tipo de assistencia (nao existe no sistema Ct24h)
   ,vclcod                dec(5,0)  # Codigo do veiculo
   ,ctgtrfcod             dec(2,0)  # Codigo categoria tarifaria
   ,imdsrvflg             char(01)  # Flag servico imediato
   ,endindtpo             dec(1,0)  # Tipo indexacao endereco
   ,endltt                dec(8,6)  # Latitude do endereco
   ,endlgt                dec(9,6)  # Longitude do endereco
   ,empcod                dec(2,0)  # Codigo empresa
   ,atdsrvorg             smallint  # codigo da origem
   ,asitipcod             smallint  # codigo da assistencia
   ,socntzcod             smallint  # codigo da natureza
   ,socntzsub             smallint  # codigo da subnatureza (somente para fins de envio, nao existe no PS)
 end record

# RECORDS E VARIAVEIS DE SAIDA DA FUNCAO

# VARIAVEIS PARA USO INTERNO DA FUNCAO
 define l_xml_envio       char(5000)                 # XML de envio ao MQ
      , l_xml_retorno     char(5000)                 # XML de retorno do MQ
      , l_mens            char(300)                  # Mensagens de erro
      , l_data            date                       # Data - Multiuso (date)
      , l_data_char       char(10)                   # Data - Multiuso (texto)
      , l_hora2           datetime hour to minute    # Hora - Multiuso
      , l_nro_registros   smallint                   # Nro. de registros do XML
      , l_erro_atdhorprg  smallint                   # Controle de erro
      , l_erro_reg_agd    smallint                   # Ctrl. de erro reg. agenda
      , l_erro_obt_prv    smallint                   # Ctrl. de erro obt. prev.
      , l_erro_sug_ag     smallint                   # Ctrl. de erro sug. agenda
      , l_previsao_padrao datetime hour to minute    # Hrs. prev. (prev. padrao)
      , l_atddatprg       like datmservico.atddatprg # Data prog. do servico
      , l_atdhorprg       like datmservico.atdhorprg # Hora prog. do servico
      , l_rsrchv          char(25)
      , l_altdathor       smallint
      , l_errcod          smallint
      , l_errmsg          char(80)
      , i                 int
      , l_lista_horarios  char(30000)

 define lr_retorno record
        coderro    smallint ,                 # Cod. de erro consulta de limites
        mens       char(300),                 # Msg. de erro consulta de limites
        agdlimqtd  like datksrvtip.agdlimqtd  # Limite de dias agendamento
 end record


 define l_min    char(02)
      , l_horaux char(05)

 initialize l_min, l_horaux to null

 # INICIALIZACAO DAS VARIAVEIS INTERNA E RECORD DE RETORNO DA FUNCAO
 initialize lr_retorno.*
           ,mr_req_reg_agenda to null

 initialize l_xml_envio
           ,l_xml_retorno
           ,l_mens
           ,l_data
           ,l_data_char
           ,l_hora2
           ,l_nro_registros
           ,l_erro_atdhorprg
           ,l_erro_reg_agd
           ,l_erro_obt_prv
           ,l_erro_sug_ag
           ,l_previsao_padrao
           ,l_atddatprg
           ,l_atdhorprg
           ,l_rsrchv
           ,l_altdathor
           ,l_errcod
           ,l_errmsg
	         ,i
	         ,l_lista_horarios to null

 # TRATATIVAS E TRANSFORMACOES DE VARIAVEIS

 let mr_req_reg_agenda.* = lr_req_reg_agenda.*

 let l_erro_atdhorprg = false
 let l_altdathor = false

    if mr_req_reg_agenda.imdsrvflg = "N" then     #0

       if lr_req_reg_agenda.srvhordat is null 
       	  or lr_req_reg_agenda.srvhordat = " " then
          # OBTEM DATA E HORA ATUAL
          call cts40g03_data_hora_banco(2)
                returning l_data
                         ,l_hora2
          
          let l_hora2 = l_hora2 - 2 units hour
          let l_data_char = null
          let l_data_char = l_data

          let mr_req_reg_agenda.srvhordat = l_data_char[7,10] clipped
                                           ,"-" clipped
                                           ,l_data_char[4,5] clipped
                                           ,"-" clipped
                                           ,l_data_char[1,2] clipped
                                           ,"T" clipped
                                           ,l_hora2 clipped
                                           ,":00" clipped
       end if

       let mr_req_reg_agenda.imdsrvflg = "N"

       # CHAMADA DO REGULAR AGENDA

       call cts02m08_regular_agenda() returning l_erro_reg_agd, l_nro_registros

       if l_erro_reg_agd = 0 then    #1
          if ma_res_reg_agenda[1].sts = "NOK" then
             # Retorno para:: Regulador de servicos para fila MQ
             display "# Retorno para:: Regulador de servicos para fila MQ"
		         let i = 1
		         let l_lista_horarios = null

             if ma_res_reg_agenda[1].srvhordat is null or ma_res_reg_agenda[1].srvhordat = ' ' then
                display "Nao ha cota disponivel."
                let l_nro_registros = 0
              else
		              while  i <= l_nro_registros

                     let l_lista_horarios = l_lista_horarios clipped,
					                                  ma_res_reg_agenda[i].srvhordat clipped,  '|'
                     let i = i + 1
		              end while
                  display "cts02m08:: l_lista_horarios = ", l_lista_horarios clipped
              end if
	        else     #2
              if ma_res_reg_agenda[1].sts = "OK" then
                 let l_nro_registros = 1
                 let l_rsrchv = ma_res_reg_agenda[1].rsrchv
                 let l_lista_horarios = today
                 let l_lista_horarios = l_lista_horarios, ma_res_reg_agenda[1].srvhordat[1,5]
                 # REGULACAO IMEDIATO OK
               end if
          end if    #2
       else   #1
          # cancelado o uso do servico
          display " # ERRO AO REGULAR AGENDA"
          # display "Previsao obtida do sistema INFORMIX!"
		      let l_nro_registros = 0
       end if   #1
    end if    #0

 #end if   #00


 return l_nro_registros, l_lista_horarios, l_rsrchv

end function

