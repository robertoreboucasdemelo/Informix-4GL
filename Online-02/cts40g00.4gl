#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G00                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MODULO RESPONSA. PELO BUSCA DE INFORMACOES DAS TABELAS DE  #
#                  PARAMETROS (DATKATMACNPRT) E (DATRACNCID) DO ACION. AUTOMA.#
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 03/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/10/2006 Ligia Mattge    PSI202363  Distancia por cidade sede             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g00_prep smallint

#-------------------------#
function cts40g00_prepare()
#-------------------------#

  define l_sql char(400)

  let l_sql = " select acnlmttmp, ",
                     " acntntlmtqtd, ",
                     " netacnflg, ",
                     " atmacnprtcod ",
                " from datkatmacnprt ",
               " where atdsrvorg = ? ",
                 " and vigincdat = (select max(vigincdat) ",
                                    " from datkatmacnprt ",
                                   " where atdsrvorg = ?) "

  prepare p_cts40g00_001 from l_sql
  declare c_cts40g00_001 cursor for p_cts40g00_001

  let l_sql = " select acnsttflg ",
                " from datracncid ",
               " where atmacnprtcod = ? ",
                 " and cidcod = ? "

  prepare p_cts40g00_002 from l_sql
  declare c_cts40g00_002 cursor for p_cts40g00_002

  ## PSI 202363
  let l_sql = " select cidacndst ",
                " from datracncid ",
               " where atmacnprtcod = ? ",
                 " and cidcod = ? "

  prepare p_cts40g00_003 from l_sql
  declare c_cts40g00_003 cursor for p_cts40g00_003

  let m_cts40g00_prep = true

end function

#--------------------------------------------#
function cts40g00_obter_flg_acio(lr_parametro)
#--------------------------------------------#

  # --FUNCAO RESPONSAVEL POR FAZER A BUSCA
  # --DO FLAG DE ACIONAMENTO NA TABELA DE PARAMETRIZACAO

  define lr_parametro record
         atmacnprtcod like datracncid.atmacnprtcod,
         cidcod       like datracncid.cidcod
  end record

  define lr_retorno   record
         resultado    smallint,  # (0) = Ok   (1) = Not Found   (2) = Erro de acesso
         mensagem     char(100),
         acnsttflg    like datracncid.acnsttflg
  end record

  define l_msg        char(100)

  if m_cts40g00_prep is null or
     m_cts40g00_prep <> true then
     call cts40g00_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno to null

  let l_msg = null

  open c_cts40g00_002 using lr_parametro.atmacnprtcod,
                          lr_parametro.cidcod

  whenever error continue
  fetch c_cts40g00_002 into lr_retorno.acnsttflg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     initialize lr_retorno to null
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "Nao encontrou o flag da situacao do acionamento."
     else
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Erro SELECT c_cts40g00_002 / ",
                                  sqlca.sqlcode, "/",
                                  sqlca.sqlerrd[2]

        call errorlog(lr_retorno.mensagem)

        let l_msg = "cts40g00/cts40g00_obter_flg_acio() / ",
                    lr_parametro.atmacnprtcod, "/",
                    lr_parametro.cidcod

        call errorlog(l_msg)
     end if
  else
     let lr_retorno.resultado = 0
     let lr_retorno.mensagem  = null
  end if

  close c_cts40g00_002

  return lr_retorno.resultado,
         lr_retorno.mensagem,
         lr_retorno.acnsttflg

end function

#--------------------------------------------#
function cts40g00_obter_parametro(l_atdsrvorg)
#--------------------------------------------#

  # --FUNCAO RESPONSAVEL POR FAZER A VERIFICACAO SE NA TABELA DE
  # --PARAMETRIZACAO EXISTE PARAMETRO REGISTRADO COM ORIGEM = 9
  # --E DEVOLVER AS RESPECTIVAS LINHAS DA TABELA DE PARAMETRIZACAO

  define l_atdsrvorg like datkatmacnprt.atdsrvorg,
         l_msg       char(100)

  define lr_retorno   record
         resultado    smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acesso
         mensagem     char(100),
         acnlmttmp    like datkatmacnprt.acnlmttmp,
         acntntlmtqtd like datkatmacnprt.acntntlmtqtd,
         netacnflg    like datkatmacnprt.netacnflg,
         atmacnprtcod like datkatmacnprt.atmacnprtcod
  end record

  if m_cts40g00_prep is null or
     m_cts40g00_prep <> true then
     call cts40g00_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno to null

  let l_msg = null

  open c_cts40g00_001 using l_atdsrvorg,
                          l_atdsrvorg

  whenever error continue
  fetch c_cts40g00_001 into lr_retorno.acnlmttmp,
                          lr_retorno.acntntlmtqtd,
                          lr_retorno.netacnflg,
                          lr_retorno.atmacnprtcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     initialize lr_retorno to null
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "Nao encontrou os parametros p/o acionamento automatico."
     else
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Erro SELECT c_cts40g00_001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]

        call errorlog(lr_retorno.mensagem)

        let l_msg = "CTS40G00/cts40g00_obter_parametro() / ",
                     l_atdsrvorg

        call errorlog(l_msg)
     end if
  else
     let lr_retorno.resultado = 0
     let lr_retorno.mensagem  = null
  end if

  close c_cts40g00_001

  return lr_retorno.resultado,
         lr_retorno.mensagem,
         lr_retorno.acnlmttmp,
         lr_retorno.acntntlmtqtd,
         lr_retorno.netacnflg,
         lr_retorno.atmacnprtcod

end function

#--------------------------------------------#
function cts40g00_obter_distancia(lr_parametro)
#--------------------------------------------#

  # --FUNCAO RESPONSAVEL POR FAZER A BUSCA
  # --DO FLAG DE ACIONAMENTO NA TABELA DE PARAMETRIZACAO

  define lr_parametro record
         atmacnprtcod like datracncid.atmacnprtcod,
         cidcod       like datracncid.cidcod
  end record

  define lr_retorno   record
         resultado    smallint,  # (0) = Ok   (1) = Not Found   (2) = Erro de acesso
         mensagem     char(100),
         cidacndst    like datracncid.cidacndst
  end record

  define l_msg        char(100)

  if m_cts40g00_prep is null or
     m_cts40g00_prep <> true then
     call cts40g00_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno to null

  let l_msg = null

  open c_cts40g00_003 using lr_parametro.atmacnprtcod,
                          lr_parametro.cidcod

  whenever error continue
  fetch c_cts40g00_003 into lr_retorno.cidacndst
  whenever error stop

  if sqlca.sqlcode <> 0 then
     initialize lr_retorno to null
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "Nao encontrou distancia parametrizada no acionamento."
     else
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Erro SELECT c_cts40g00_002 / ",
                                  sqlca.sqlcode, "/",
                                  sqlca.sqlerrd[2]
     end if
  else
     if lr_retorno.cidacndst is null then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "Distancia nao parametrizada no acionamento."
     else
       let lr_retorno.resultado = 0
       let lr_retorno.mensagem  = null
     end if
  end if

  close c_cts40g00_003

  return lr_retorno.resultado,
         lr_retorno.mensagem,
         lr_retorno.cidacndst

end function
