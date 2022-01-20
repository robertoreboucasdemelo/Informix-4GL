#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd27g04                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 229784                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA dpakprtbnfgrpcrt
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 06/01/2009                                                 #
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
function ctd27g04_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select b.crttip ",
              "   from dpakprtbnfgrpcrt a, dpakprtbnfcrt b ",
              "  where a.prtbnfgrpcod = ? ",
              "    and a.bnfcrtcod = ? ",
              "    and a.bnfcrtcod = b.bnfcrtcod "

  prepare pctd27g04001 from l_sql
  declare cctd27g04001 cursor for pctd27g04001

  let m_prep = true

end function

#-----------------------------------------#
function ctd27g04_val_crit_grp(lr_param)
#-----------------------------------------#
  define lr_param     record
         prtbnfgrpcod like dpakprtbnfgrpcrt.prtbnfgrpcod,
         bnfcrtcod    like dpakprtbnfgrpcrt.bnfcrtcod   
  end record

  define lr_retorno record
         ret        smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg        char(100),
         crttip     like dpakprtbnfcrt.crttip
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g04_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g04001 using lr_param.prtbnfgrpcod, lr_param.bnfcrtcod
  whenever error continue
  fetch cctd27g04001 into lr_retorno.crttip
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou o criterio do grupo"
        let lr_retorno.crttip = "N"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "Erro em ctd27g04_val_crit_grp ", sqlca.sqlcode
     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  close cctd27g04001

  return lr_retorno.ret,
         lr_retorno.msg,
         lr_retorno.crttip

end function
