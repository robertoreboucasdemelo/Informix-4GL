#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd27g02                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 229784                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA dpakprtbnfgrpcrt        #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 29/12/2008                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

  define m_prep smallint

#-------------------------#
function ctd27g02_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select fxavlr ",
                " from dpakbnfvlrfxa ",
               " where bnfcrtcod = ? ",
               "   and prtbnfgrpcod = ? ",
               "   and minper <= ? ",
               "   and maxper >= ? "

  prepare pctd27g02001 from l_sql
  declare cctd27g02001 cursor for pctd27g02001

  let l_sql = " select min(minper) ",
                " from dpakbnfvlrfxa ",
               " where bnfcrtcod = ? ",
               "   and prtbnfgrpcod = ? ",
               "   and minper > ? "

  prepare pctd27g02002 from l_sql
  declare cctd27g02002 cursor for pctd27g02002

  let l_sql = " select min(minper) ",
                " from dpakbnfvlrfxa ",
               " where bnfcrtcod = ? ",
               "   and prtbnfgrpcod = ? ",
               "   and minper < ? "

  prepare pctd27g02003 from l_sql
  declare cctd27g02003 cursor for pctd27g02003

  let m_prep = true

end function

#-----------------------------------------#
function ctd27g02_faixa_bonif(lr_param)
#-----------------------------------------#
  define lr_param record
         bnfcrtcod like dpakbnfvlrfxa.bnfcrtcod,
         prtbnfgrpcod like dpakbnfvlrfxa.prtbnfgrpcod,
         percsatisf   like dpakbnfvlrfxa.minper
  end record

  define lr_retorno record
         ret        smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg        char(100), 
         fxavlr     like dpakbnfvlrfxa.fxavlr
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g02_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g02001 using lr_param.bnfcrtcod, lr_param.prtbnfgrpcod,
                          lr_param.percsatisf, lr_param.percsatisf

  whenever error continue
  fetch cctd27g02001 into lr_retorno.fxavlr
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.fxavlr = 0
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou faixa de criterios"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "Erro em ctd27g02_faixa_bonif ", sqlca.sqlcode

     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  close cctd27g02001

  return lr_retorno.ret,
         lr_retorno.msg,
         lr_retorno.fxavlr

end function

#-----------------------------------------#
function ctd27g02_prox_minper(lr_param)
#-----------------------------------------#
  define lr_param record
         bnfcrtcod like dpakbnfvlrfxa.bnfcrtcod,
         prtbnfgrpcod like dpakbnfvlrfxa.prtbnfgrpcod,
         percsatisf   like dpakbnfvlrfxa.minper
  end record

  define lr_retorno record
         ret        smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg        char(100), 
         minper     like dpakbnfvlrfxa.minper
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g02_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g02002 using lr_param.bnfcrtcod, lr_param.prtbnfgrpcod,
                          lr_param.percsatisf

  whenever error continue
  fetch cctd27g02002 into lr_retorno.minper
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.minper = 0
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou a proxima faixa "
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "Erro em ctd27g02_minper ", sqlca.sqlcode
     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  if lr_retorno.minper is null or lr_retorno.minper = 0 then
     let lr_retorno.minper = 0
     let lr_retorno.ret = 2
     let lr_retorno.msg = "Nao encontrou a faixa cadastrada"
  end if


  close cctd27g02002

  return lr_retorno.ret,
         lr_retorno.msg,
         lr_retorno.minper

end function

#-----------------------------------------#
function ctd27g02_ant_minper(lr_param)
#-----------------------------------------#
  define lr_param record
         bnfcrtcod like dpakbnfvlrfxa.bnfcrtcod,
         prtbnfgrpcod like dpakbnfvlrfxa.prtbnfgrpcod,
         percsatisf   like dpakbnfvlrfxa.minper
  end record

  define lr_retorno record
         ret        smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg        char(100), 
         minper     like dpakbnfvlrfxa.minper
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g02_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g02003 using lr_param.bnfcrtcod, lr_param.prtbnfgrpcod,
                          lr_param.percsatisf

  whenever error continue
  fetch cctd27g02003 into lr_retorno.minper
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.minper = null
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou a faixa anterior"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "Erro em ctd27g02_minper ", sqlca.sqlcode
     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  if lr_retorno.minper is null then
     let lr_retorno.minper = 0
     let lr_retorno.ret = 2
     let lr_retorno.msg = "Nao encontrou a faixa cadastrada"
  end if


  close cctd27g02003

  return lr_retorno.ret,
         lr_retorno.msg,
         lr_retorno.minper

end function
