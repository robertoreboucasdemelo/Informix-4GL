#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd27g01                                                   #
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
function ctd27g01_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select prtbnfgrpcod ",
                " from dpakprtbnfgrpcrt ",
               " where bnfcrtcod = ? "

  prepare pctd27g01001 from l_sql
  declare cctd27g01001 cursor for pctd27g01001

  let l_sql = " select prtbnfgrpcod ",
              "   from dpakprtbnfgrpcrt ",
              "  where prtbnfgrpcod = ? ",
              "    and bnfcrtcod = ? "

  prepare pctd27g01002 from l_sql
  declare cctd27g01002 cursor for pctd27g01002

  let m_prep = true

end function

#-----------------------------------------#
function ctd27g01_obter_grupo_criterios(lr_param)
#-----------------------------------------#
  define lr_param record
         tp_retorno smallint,
         bnfcrtcod like dpakprtbnfgrpcrt.bnfcrtcod
  end record


  define lr_retorno record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100), 
         prtbnfgrpcod   like dpakprtbnfgrpcrt.prtbnfgrpcod
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g01_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g01001 using lr_param.bnfcrtcod

  whenever error continue
  fetch cctd27g01001 into lr_retorno.prtbnfgrpcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou criterios"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "ctd27g01/ctd27g01_obter_grupo_criterios() / ",
                             lr_param.bnfcrtcod

     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  close cctd27g01001

  if lr_param.tp_retorno = 1 then
     return lr_retorno.ret,
            lr_retorno.msg,
            lr_retorno.prtbnfgrpcod
  end if

end function

#-----------------------------------------#
function ctd27g01_consis_grp_crt(lr_param)
#-----------------------------------------#
  define lr_param record
         prtbnfgrpcod like dpakprtbnfgrpcrt.prtbnfgrpcod,
         bnfcrtcod    like dpakprtbnfgrpcrt.bnfcrtcod
  end record

  define lr_retorno record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100)
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g01_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g01002 using lr_param.prtbnfgrpcod, lr_param.bnfcrtcod

  whenever error continue
  fetch cctd27g01002
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao consistiu grupo/criterio"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "ctd27g01/ctd27g01_obter_grupo_criterios() / ",
                             lr_param.bnfcrtcod

     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  close cctd27g01002

  return lr_retorno.ret,
         lr_retorno.msg

end function
