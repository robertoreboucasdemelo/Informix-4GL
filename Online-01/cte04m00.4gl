#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTE04M00                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 196541 - AGENDAMENTO DE SERVICOS                           #
#                  MODULO RESPONSAVEL PELAS SEGUINTES FUNCIONALIDADES:        #
#                    - GERAR NUMERO DE LIGACAO DO CORRETOR                    #
#                    - GERAR A LIGACAO DO CORRETOR                            #
#                    - GRAVAR O HISTORICO DO CORRETOR                         #
#                  ESTE PROGRAMA E CHAMADO POR JAVA VIA MQ.                   #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 09/02/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 21/12/2006  Priscila         CT         Chamar funcao especifica para       #
#                                         insercao em datmlighist             #
#-----------------------------------------------------------------------------#
# 16/03/2009 Carla Rampazzo PSI 235580 - Acrescentar Parametro na chamada de  #
#                                        cts40g20_ret_codassu()               #
#                                        1-Curso Direcao Defensiva            #
#                                        2-Demais Agendamentos                #
#                                      - Acrescentar Parametro de entrada para#
#                                        a funcao cte04m00_gera_lig()         #
#                                        Nro/Status do Curso Direcao Defensiva#
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

  define m_cte04m00_prep smallint

#-------------------------#
function cte04m00_prepare()
#-------------------------#

  define l_sql char(300)

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql = null

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? ",
                 " for update "

  prepare pcte04m00001 from l_sql
  declare ccte04m00001 cursor with hold for pcte04m00001

  let l_sql = " insert ",
                " into datkgeral ",
                    " (grlchv, ",
                     " grlinf, ",
                     " atldat, ",
                     " atlhor, ",
                     " atlemp, ",
                     " atlmat) ",
             " values (?, '0000000000', ?, ?, ?, ?) "

  prepare pcte04m00002 from l_sql

  let l_sql = " update datkgEral ",
                " set (grlinf) = (?) ",
               " where grlchv = ? "

  prepare pcte04m00003 from l_sql

  let l_sql = " insert ",
                " into dacmlig ",
                    " (corlignum, ",
                     " corligano, ",
                     " ligdat, ",
                     " lighorinc, ",
                     " lighorfnl, ",
                     " c24paxnum, ",
                     " c24solnom, ",
                     " corligorg, ",
                     " cademp, ",
                     " cadmat) ",
              " values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "

  prepare pcte04m00004 from l_sql

  let l_sql = " insert ",
                " into dacrligsus ",
                    " (corlignum, ",
                     " corligano, ",
                     " corsus) ",
              " values(?, ?, ?) "

  prepare pcte04m00005 from l_sql

  let l_sql = " insert ",
                " into dacmligass ",
                    " (corlignum, ",
                     " corligano, ",
                     " corligitmseq, ",
                     " corasscod, ",
                     " ligasshorinc, ",
                     " ligasshorfnl) ",
              " values(?, ?, ?, ?, ?, ?) "

  prepare pcte04m00006 from l_sql

  let l_sql = " insert ",
                " into dacrligagnvst ",
                    " (corlignum, ",
                     " corligitmseq, ",
                     " vstagnnum, ",
                     " vstagnstt, ",
                     " corligano) ",
              " values(?, ?, ?, ?, ?) "

  prepare pcts04m00007 from l_sql

  let l_sql = " insert ",
                " into dacrdrscrsagdlig ",
                    " (corlignum, ",
                     " corligano, ",
                     " corligitmseq, ",
                     " drscrsagdcod, ",
                     " agdligrelstt) ",
              " values(?, ?, ?, ?, ?)"
  prepare pcts04m00008 from l_sql

  let m_cte04m00_prep = true

end function

#-----------------------------------------#
function cte04m00_gera_numlig(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         atlmat       like datkgeral.atlmat,
         atlemp       like datkgeral.atlemp,
         servico      char(40)
  end record

  define lr_dados     record
         corlignum    like dacmlig.corlignum,
         corligano    like dacmlig.corligano,
         data         date,
         hora         datetime hour to second,
         grlchv       like igbkgeral.grlchv,
         grlinf       like igbkgeral.grlinf
  end record

  define l_msg_erro   char(300)

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_msg_erro = null

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_dados.*  to  null

  if m_cte04m00_prep is null or
     m_cte04m00_prep <> true then
     call cte04m00_prepare()
  end if

  # ---> INICIALIZACAO DAS VARIAVEIS
  initialize lr_dados to null

  let l_msg_erro = cte04m00_msg_ret("RLAC", # -> SERVICO SOLICITADO
                                    0,  # -> ESTADO
                                    "", # -> OPERACAO
                                    lr_parametro.servico, # -> SERVICO
                                    "", # -> CURSOR
                                    "", # -> SQLCODE
                                    "", # -> SQLERRD
                                    "", # -> CORLIGNUM
                                    "", # -> CORLIGANO
                                    "") # -> DESCRICAO ERRO

  # ---> BUSCA A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1)
       returning lr_dados.data, lr_dados.hora

  let lr_dados.corligano = year(lr_dados.data)

  begin work

  # ---> MONTA A CHAVE DE PESQUISA
  let lr_dados.grlchv = "ULTCORLIG", lr_dados.corligano using "####"

  # ---> FAZ A LEITURA NA TABELA DATKGERAL
  open  ccte04m00001 using lr_dados.grlchv
  whenever error continue
  fetch ccte04m00001 into  lr_dados.grlinf
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then

        # ---> BUSCA A DATA E HORA DO BANCO
        call cts40g03_data_hora_banco(1)
             returning lr_dados.data,
                       lr_dados.hora

        # ---> INSERE NA DATKGERAL
        whenever error continue
        execute pcte04m00002 using lr_dados.grlchv,
                                   lr_dados.data,
                                   lr_dados.hora,
                                   lr_parametro.atlemp,
                                   lr_parametro.atlmat
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let l_msg_erro = cte04m00_msg_ret("RLAC",               # -> SERVICO SOLICITADO
                                             1,                    # -> ESTADO
                                             "INSERT",             # -> OPERACAO
                                             lr_parametro.servico, # -> SERVICO
                                             "pcte04m00002",       # -> CURSOR
                                             sqlca.sqlcode,        # -> SQLCODE
                                             sqlca.sqlerrd[2],     # -> SQLERRD
                                             lr_dados.corlignum,   # -> CORLIGNUM
                                             lr_dados.corligano,   # -> CORLIGANO
                                             "")                   # -> DESCRICAO ERRO
           initialize lr_dados to null
           rollback work
           return l_msg_erro,
                  lr_dados.corlignum,
                  lr_dados.corligano
        end if

        close ccte04m00001

        # ---> FAZ A LEITURA NA TABELA DATKGERAL
        open  ccte04m00001 using lr_dados.grlchv
        whenever error continue
        fetch ccte04m00001 into lr_dados.grlinf
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let l_msg_erro = cte04m00_msg_ret("RLAC",               # -> SERVICO SOLICITADO
                                             1,                    # -> ESTADO
                                             "SELECT",             # -> OPERACAO
                                             lr_parametro.servico, # -> SERVICO
                                             "ccte04m00001",       # -> CURSOR
                                             sqlca.sqlcode,        # -> SQLCODE
                                             sqlca.sqlerrd[2],     # -> SQLERRD
                                             lr_dados.corlignum,   # -> CORLIGNUM
                                             lr_dados.corligano,   # -> CORLIGANO
                                             "")                   # -> DESCRICAO ERRO
           initialize lr_dados to null
           rollback work
           return l_msg_erro,
                  lr_dados.corlignum,
                  lr_dados.corligano
        end if
     else
        let l_msg_erro = cte04m00_msg_ret("RLAC",               # -> SERVICO SOLICITADO
                                          1,                    # -> ESTADO
                                          "SELECT",             # -> OPERACAO
                                          lr_parametro.servico, # -> SERVICO
                                          "ccte04m00001",       # -> CURSOR
                                          sqlca.sqlcode,        # -> SQLCODE
                                          sqlca.sqlerrd[2],     # -> SQLERRD
                                          lr_dados.corlignum,   # -> CORLIGNUM
                                          lr_dados.corligano,   # -> CORLIGANO
                                          "")                   # -> DESCRICAO ERRO
        initialize lr_dados to null
        rollback work
        return l_msg_erro,
               lr_dados.corlignum,
               lr_dados.corligano
     end if
  end if

  close ccte04m00001

  let lr_dados.corlignum     = lr_dados.grlinf[01,10]
  let lr_dados.corlignum     = lr_dados.corlignum + 1
  let lr_dados.grlinf[01,10] = lr_dados.corlignum using "&&&&&&&&&&"

  # ---> ATUALIZA A TABELA DATKGERAL
  whenever error continue
  execute pcte04m00003 using lr_dados.grlinf,
                             lr_dados.grlchv
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg_erro = cte04m00_msg_ret("RLAC",               # -> SERVICO SOLICITADO
                                       1,                    # -> ESTADO
                                       "UPDATE",             # -> OPERACAO
                                       lr_parametro.servico, # -> SERVICO
                                       "pcte04m00003",       # -> CURSOR
                                       sqlca.sqlcode,        # -> SQLCODE
                                       sqlca.sqlerrd[2],     # -> SQLERRD
                                       lr_dados.corlignum,   # -> CORLIGNUM
                                       lr_dados.corligano,   # -> CORLIGANO
                                       "")                   # -> DESCRICAO ERRO
     initialize lr_dados to null
     rollback work
  else
     commit work
  end if

  return l_msg_erro,
         lr_dados.corlignum,
         lr_dados.corligano

end function

#--------------------------------------#
function cte04m00_gera_lig(lr_parametro)
#--------------------------------------#

  define lr_parametro record
######   ligdat       like dacmlig.ligdat,
         ligdat       char (10),
         ligasshorinc like dacmligass.ligasshorinc,
         ligasshorfnl like dacmligass.ligasshorfnl,
         c24solnom    like dacmlig.c24solnom,
         corsus       like dacrligsus.corsus,
         vstagnnum    like datmagnwebsrv.vstagnnum,
         vstagnstt    like datmagnwebsrv.vstagnstt,
         cadmat       like dacmlig.cadmat,
         cademp       like dacmlig.cademp,
         corasscod    like dacmligass.corasscod,
         drscrsagdcod like dacrdrscrsagdlig.drscrsagdcod,
         agdligrelstt like dacrdrscrsagdlig.agdligrelstt,
         corlignum    like dacmligass.corlignum,
         corligano    like dacmligass.corligano,
         servico      char(40)
  end record

  define l_c24paxnum    like dacmlig.c24paxnum,
         l_corligorg    like dacmlig.corligorg,
         l_corligitmseq like dacmligass.corligitmseq,
         l_corasscod    like dacmligass.corasscod,
         l_msg_erro     char(300)

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_c24paxnum    = null
  let l_corligorg    = null
  let l_corligitmseq = null
  let l_corasscod    = null
  let l_msg_erro     = null

  if m_cte04m00_prep is null or
     m_cte04m00_prep <> true then
     call cte04m00_prepare()
  end if

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_c24paxnum    = 1
  let l_corligorg    = 2
  let l_corligitmseq = 1

  let l_msg_erro = cte04m00_msg_ret("RLAC", # -> SERVICO SOLICITADO
                                    0,      # -> ESTADO
                                    "",     # -> OPERACAO
                                    lr_parametro.servico, # -> SERVICO
                                    "", # -> CURSOR
                                    "", # -> SQLCODE
                                    "", # -> SQLERRD
                                    lr_parametro.corlignum, # -> CORLIGNUM
                                    lr_parametro.corligano, # -> CORLIGANO
                                    "") # -> DESCRICAO ERRO
  begin work

  whenever error continue
  execute pcte04m00004 using lr_parametro.corlignum,
                             lr_parametro.corligano,
                             lr_parametro.ligdat,
                             lr_parametro.ligasshorinc,
                             lr_parametro.ligasshorfnl,
                             l_c24paxnum,
                             lr_parametro.c24solnom,
                             l_corligorg,
                             lr_parametro.cademp,
                             lr_parametro.cadmat
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg_erro = cte04m00_msg_ret("RLAC",         # -> SERVICO SOLICITADO
                                       1,                      # -> ESTADO
                                       "INSERT",               # -> OPERACAO
                                       lr_parametro.servico,   # -> SERVICO
                                       "pcte04m00004",         # -> CURSOR
                                       sqlca.sqlcode,          # -> SQLCODE
                                       sqlca.sqlerrd[2],       # -> SQLERRD
                                       lr_parametro.corlignum, # -> CORLIGNUM
                                       lr_parametro.corligano, # -> CORLIGANO
                                       "")                 # -> DESCRICAO ERRO
     rollback work
     return l_msg_erro
  end if

  # ---> GRAVA SOLICITANTE CORRETOR
  if lr_parametro.corsus <> " " and
     lr_parametro.corsus is not null then

     whenever error continue
     execute pcte04m00005 using lr_parametro.corlignum,
                                lr_parametro.corligano,
                                lr_parametro.corsus
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_msg_erro = cte04m00_msg_ret("RLAC",        # -> SERVICO SOLICITADO
                                          1,                      # -> ESTADO
                                          "INSERT",               # -> OPERACAO
                                          lr_parametro.servico,   # -> SERVICO
                                          "pcte04m00005",         # -> CURSOR
                                          sqlca.sqlcode,          # -> SQLCODE
                                          sqlca.sqlerrd[2],       # -> SQLERRD
                                          lr_parametro.corlignum, # -> CORLIGNUM
                                          lr_parametro.corligano, # -> CORLIGANO
                                          "")            # -> DESCRICAO ERRO
        rollback work
        return l_msg_erro
     end if
  end if

  let l_corasscod = lr_parametro.corasscod

  ---> Demais Agendamentos via Web
  if lr_parametro.vstagnnum is not null then
     whenever error continue
     execute pcts04m00007 using lr_parametro.corlignum,
                                l_corligitmseq,
                                lr_parametro.vstagnnum,
                                lr_parametro.vstagnstt,
                                lr_parametro.corligano
     if sqlca.sqlcode <> 0 then
        let l_msg_erro = cte04m00_msg_ret("RLAC",        # -> SERVICO SOLICITADO
                                          1,                      # -> ESTADO
                                          "INSERT",               # -> OPERACAO
                                          lr_parametro.servico,   # -> SERVICO
                                          "pcts04m00007",         # -> CURSOR
                                          sqlca.sqlcode,          # -> SQLCODE
                                          sqlca.sqlerrd[2],       # -> SQLERRD
                                          lr_parametro.corlignum, # -> CORLIGNUM
                                          lr_parametro.corligano, # -> CORLIGANO
                                          "")            # -> DESCRICAO ERRO
        rollback work
        return l_msg_erro
     end if
     # ---> ABRE O ASSUNTO
     call cts40g20_ret_codassu("C",
                              #"ct24hs",
                               1,   # origem da ligacao = 1 (porto)
                               lr_parametro.corasscod,
                               2) ---> Demais Agendamentos
           returning l_corasscod
  end if


  ---> Agendamento do Curso de Direcao Defensiva
  if lr_parametro.drscrsagdcod is not null then
     whenever error continue
     execute pcts04m00008 using lr_parametro.corlignum,
                                lr_parametro.corligano,
                                l_corligitmseq,
                                lr_parametro.drscrsagdcod,
                                lr_parametro.agdligrelstt

     if sqlca.sqlcode <> 0 then
        let l_msg_erro = cte04m00_msg_ret("RLAC",        # -> SERVICO SOLICITADO
                                          1,                      # -> ESTADO
                                          "INSERT",               # -> OPERACAO
                                          lr_parametro.servico,   # -> SERVICO
                                          "pcts04m00008",         # -> CURSOR
                                          sqlca.sqlcode,          # -> SQLCODE
                                          sqlca.sqlerrd[2],       # -> SQLERRD
                                          lr_parametro.corlignum, # -> CORLIGNUM
                                          lr_parametro.corligano, # -> CORLIGANO
                                          "")            # -> DESCRICAO ERRO
        rollback work
        return l_msg_erro
     end if

     # ---> ABRE O ASSUNTO
     call cts40g20_ret_codassu("C",
                              #"ct24hs",
                               1,   # origem da ligacao = 1 (porto)
                               lr_parametro.corasscod,
                               1) ---> Curso Direcao Defensiva 
           returning l_corasscod
  end if


  whenever error continue
  execute pcte04m00006 using lr_parametro.corlignum,
                             lr_parametro.corligano,
                             l_corligitmseq,
                             l_corasscod,
                             lr_parametro.ligasshorinc,
                             lr_parametro.ligasshorfnl
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let l_msg_erro = cte04m00_msg_ret("RLAC",         # -> SERVICO SOLICITADO
                                       1,                      # -> ESTADO
                                       "INSERT",               # -> OPERACAO
                                       lr_parametro.servico,   # -> SERVICO
                                       "pcte04m00006",         # -> CURSOR
                                       sqlca.sqlcode,          # -> SQLCODE
                                       sqlca.sqlerrd[2],       # -> SQLERRD
                                       lr_parametro.corlignum, # -> CORLIGNUM
                                       lr_parametro.corligano, # -> CORLIGANO
                                       "")             # -> DESCRICAO ERRO
     rollback work
  else
     commit work
  end if

  return l_msg_erro

end function

#-------------------------------------#
function cte04m00_msg_ret(lr_parametro)
#-------------------------------------#

  define lr_parametro  record
         serv_solic    char(04), # RLAC -> RegistrarLigacaoAtendimentoCorretor
                                 # RHAC -> RegistrarHistoricoAtendimentoCorretor
         estado        smallint,
         operacao      char(20),
         servico       char(40),
         cursor        char(15),
         sqlcode       char(09),
         sqlerr        char(09),
         corlignum     char(10),
         corligano     char(05),
         desc_erro     char(100)
  end record

  define l_msg_retorno char(500)

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_msg_retorno = null

  case lr_parametro.serv_solic

     when("RLAC") # -> RegistrarLigacaoAtendimentoCorretor
        let l_msg_retorno = "<retorno>",
                            "<estado>",   lr_parametro.estado    using "<<<<&", "</estado>",
                            "<servico>",  lr_parametro.servico   clipped,       "</servico>",
                            "<ligacao>",  lr_parametro.corlignum clipped, "-",
                                          lr_parametro.corligano clipped,       "</ligacao>",
                            "<operacao>", lr_parametro.operacao  clipped,       "</operacao>",
                            "<cursor>",   lr_parametro.cursor    clipped,       "</cursor>",
                            "<sqlcode>",  lr_parametro.sqlcode   clipped,       "</sqlcode>",
                            "<sqlerr>",   lr_parametro.sqlerr    clipped,       "</sqlerr>",
                            "</retorno>" clipped

     when("RHAC") # -> RegistrarHistoricoAtendimentoCorretor
        let l_msg_retorno = "<retorno>",
                            "<estado>",         lr_parametro.estado    using "<<<<&", "</estado>",
                            "<descricao_erro>", lr_parametro.desc_erro clipped,  "</descricao_erro>",
                            "</retorno>" clipped

  end case

  return l_msg_retorno

end function

#----------------------------------------#
function cte04m00_grava_hist(lr_parametro)
#----------------------------------------#

  define lr_parametro record
        #caddat       like dacmligasshst.caddat,
         caddat       char(10),
         cadhor       like dacmligasshst.cadhor,
         empcod       like isskfunc.empcod,
         cadmat       like dacmligasshst.cadmat,
         corlignum    like dacmligasshst.corlignum,
         corligano    like dacmligasshst.corligano,
         historico    char(7000),
         servico      char(40)
  end record
  define lr_hist           record
         tipgrv            smallint,
         lignum            like datmlighist.lignum,
         c24funmat         like datmlighist.c24funmat,
         ligdat            like datmlighist.ligdat,
         lighorinc         like datmlighist.lighorinc,
         c24ligdsc         like datmlighist.c24ligdsc
  end record
  define lr_retorno   record
         tabname      like systables.tabname,
         sqlcode      integer
  end record

  define l_indice     smallint,
         l_caracteres smallint,
         l_limite_inf smallint,
         l_limite_sup smallint,
         l_status     smallint,
         l_msg_erro   char(300),
         l_historico  char(70),
         l_erro       char(50)  

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_indice     = null
  let l_historico  = null
  let l_status     = null
  let l_erro       = null
  let l_caracteres = 0
  let l_limite_inf = 0
  let l_limite_sup = 0

  let l_msg_erro = cte04m00_msg_ret("RHAC",  # -> SERVICO SOLICITADO
                                    0,       # -> ESTADO
                                    "",      # -> OPERACAO
                                    "",      # -> SERVICO
                                    "",      # -> CURSOR
                                    "",      # -> SQLCODE
                                    "",      # -> SQLERRD
                                    "",      # -> CORLIGNUM
                                    "",      # -> CORLIGANO
                                    "")      # -> DESCRICAO ERRO
  # ---> ATUALIZA GLOBAL
  let g_issk.funmat = lr_parametro.cadmat
  let g_issk.empcod = lr_parametro.empcod
  let g_issk.usrtip = "F"

  if lr_parametro.caddat is null or
     lr_parametro.caddat = " " then
     let lr_parametro.caddat = today
  end if

  if length(lr_parametro.historico) <= 70 then
     if lr_parametro.corligano is not null  then
        let l_status = cte01m04_insere("",
                                       "",
                                       lr_parametro.corlignum,
                                       lr_parametro.corligano,
                                       1,
                                       "",
                                       lr_parametro.historico,
                                       lr_parametro.caddat,
                                       lr_parametro.cadhor)
        if l_status <> 0 then
           let l_msg_erro = cte04m00_msg_ret("RHAC",  # -> SERVICO SOLICITADO
                                             1,       # -> ESTADO
                                             "",      # -> OPERACAO
                                             "",      # -> SERVICO
                                             "",      # -> CURSOR
                                             "",      # -> SQLCODE
                                             "",      # -> SQLERRD
                                             "",      # -> CORLIGNUM
                                             "",      # -> CORLIGANO
             "ERRO AO CHAMAR A FUNCAO CTE01M04_INSERE()") # -> DESCRICAO ERRO
           return l_msg_erro
        end if
     else  # -> HISTORICO PARA ATEND. SEGURADO

        initialize lr_hist.*    to null
        initialize lr_retorno.* to null

        let lr_hist.tipgrv    = 1
        let lr_hist.lignum    = lr_parametro.corlignum
        let lr_hist.c24funmat = lr_parametro.cadmat
        let lr_hist.ligdat    = lr_parametro.caddat
        let lr_hist.lighorinc = lr_parametro.cadhor
        let lr_hist.c24ligdsc = lr_parametro.historico

        #call cts10g00_historico(lr_hist.*)
        #     returning lr_retorno.*            
        call ctd06g01_ins_datmlighist(lr_hist.lignum,
                                      lr_hist.c24funmat,
                                      lr_hist.c24ligdsc,
                                      lr_hist.ligdat,
                                      lr_hist.lighorinc,
                                      g_issk.usrtip,
                                      g_issk.empcod  )
             returning lr_retorno.sqlcode,  #retorno
                       lr_retorno.tabname   #mensagem        

        if lr_retorno.sqlcode <> 1 then
           let l_msg_erro = cte04m00_msg_ret("RHAC",  # -> SERVICO SOLICITADO
                                             1,       # -> ESTADO
                                             "",      # -> OPERACAO
                                             "",      # -> SERVICO
                                             "",      # -> CURSOR
                                             "",      # -> SQLCODE
                                             "",      # -> SQLERRD
                                             "",      # -> CORLIGNUM
                                             "",      # -> CORLIGANO
             "ERRO AO CHAMAR A FUNCAO CTS06G01_INS_DATMLIGHIST()") 
           return l_msg_erro
        end if
     end if
  else
     # ---> O HISTORICO POSSUI MAIS DE UMA LINHA
     for l_indice = 1 to length(lr_parametro.historico)
        let l_caracteres = l_caracteres + 1
        if l_caracteres = 70 then # ---> UMA LINHA DE HISTORICO
           # ---> MONTA O LIMITE SUPERIOR E INFERIOR DA STRING DO HISTORICO
           let l_limite_inf = (l_indice + 1 - l_caracteres)
           let l_limite_sup = (l_indice + 1)
           # ---> HISTORICO QUE VAI SER INSERIDO(70 POSICOES)
           let l_historico  = lr_parametro.historico[l_limite_inf, l_limite_sup]
           if lr_parametro.corligano is not null then
              let l_status = cte01m04_insere("",
                                             "",
                                             lr_parametro.corlignum,
                                             lr_parametro.corligano,
                                             1,
                                             "",
                                             l_historico,
                                             lr_parametro.caddat,
                                             lr_parametro.cadhor)
           else  # historico segurado
              initialize lr_hist.*    to null
              initialize lr_retorno.* to null
              let lr_hist.tipgrv    = 1
              let lr_hist.lignum    = lr_parametro.corlignum
              let lr_hist.c24funmat = lr_parametro.cadmat
              let lr_hist.ligdat    = lr_parametro.caddat
              let lr_hist.lighorinc = lr_parametro.cadhor
              let lr_hist.c24ligdsc = l_historico
              #call cts10g00_historico(lr_hist.*)
              #     returning lr_retorno.*
              #let l_status = lr_retorno.sqlcode
              call ctd06g01_ins_datmlighist(lr_hist.lignum,
                                            lr_hist.c24funmat,
                                            lr_hist.c24ligdsc,
                                            lr_hist.ligdat,
                                            lr_hist.lighorinc,
                                            g_issk.usrtip,
                                            g_issk.empcod  )
                   returning l_status,            #retorno
                             lr_retorno.tabname   #mensagem                 
              if l_status = 1 then # retorno ok
                 let l_status = 0
              end if
           end if
           if l_status <> 0 then
              exit for
           end if
           let l_caracteres = 0
           let l_limite_inf = 0
           let l_limite_sup = 0
        end if
     end for
     if l_status <> 0 then
        if lr_parametro.corligano is not null then # historico corretor
           let l_erro = "ERRO AO CHAMAR A FUNCAO CTE01M04_INSERE()"
        else
           let l_erro = "ERRO AO CHAMAR A FUNCAO CTS06G01_ins_datmlighist()"
        end if
        let l_msg_erro = cte04m00_msg_ret("RHAC",  # -> SERVICO SOLICITADO
                                          l_status,# -> ESTADO
                                          "",      # -> OPERACAO
                                          "",      # -> SERVICO
                                          "",      # -> CURSOR
                                          "",      # -> SQLCODE
                                          "",      # -> SQLERRD
                                          "",      # -> CORLIGNUM
                                          "",      # -> CORLIGANO
                                          l_erro) # -> DESCRICAO ERRO
        return l_msg_erro
     end if
     # ---> VERIFICA SE POSSUI CARACTERES PENDENTES
     if l_caracteres > 0 then
        let l_limite_inf = (l_indice - l_caracteres)
        let l_limite_sup = (l_indice - 1)
        let l_historico  = lr_parametro.historico[l_limite_inf, l_limite_sup]
        if lr_parametro.corligano is not null then
           let l_status = cte01m04_insere("",
                                          "",
                                          lr_parametro.corlignum,
                                          lr_parametro.corligano,
                                          1,
                                          "",
                                          l_historico,
                                          lr_parametro.caddat,
                                          lr_parametro.cadhor)
        else  # historico segurado
           initialize lr_hist.*    to null
           initialize lr_retorno.* to null
           let lr_hist.tipgrv    = 1
           let lr_hist.lignum    = lr_parametro.corlignum
           let lr_hist.c24funmat = lr_parametro.cadmat
           let lr_hist.ligdat    = lr_parametro.caddat
           let lr_hist.lighorinc = lr_parametro.cadhor
           let lr_hist.c24ligdsc = l_historico
           #call cts10g00_historico(lr_hist.*)
           #     returning lr_retorno.*
           #let l_status = lr_retorno.sqlcode
           call ctd06g01_ins_datmlighist(lr_hist.lignum,
                                         lr_hist.c24funmat,
                                         lr_hist.c24ligdsc,
                                         lr_hist.ligdat,
                                         lr_hist.lighorinc,
                                         g_issk.usrtip,
                                         g_issk.empcod  )
                returning l_status,            #retorno
                          lr_retorno.tabname   #mensagem              
           if l_status = 1 then # retorno ok
              let l_status = 0
           end if
        end if
        if l_status <> 0 then
           if lr_parametro.corligano is not null then # historico corretor
              let l_erro = "ERRO AO CHAMAR A FUNCAO CTE01M04_INSERE()"
           else
              let l_erro = "ERRO AO CHAMAR A FUNCAO CTS06G01_ins_datmlighist()"
           end if
           let l_msg_erro = cte04m00_msg_ret("RHAC",  # -> SERVICO SOLICITADO
                                             l_status,# -> ESTADO
                                             "",      # -> OPERACAO
                                             "",      # -> SERVICO
                                             "",      # -> CURSOR
                                             "",      # -> SQLCODE
                                             "",      # -> SQLERRD
                                             "",      # -> CORLIGNUM
                                             "",      # -> CORLIGANO
                                             l_erro) # -> DESCRICAO ERRO
           return l_msg_erro
        end if
     end if
  end if
  return l_msg_erro
end function
