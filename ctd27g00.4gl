#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd27g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 229784                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA dpakprtbnfcrt        #
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
function ctd27g00_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select bnfcrtdes ",
                " from dpakprtbnfcrt ",
               " where bnfcrtcod = ? "

  prepare pctd27g00001 from l_sql
  declare cctd27g00001 cursor for pctd27g00001

  let m_prep = true

end function

#-----------------------------------------#
function ctd27g00_obter_criterios(lr_param)
#-----------------------------------------#
  define lr_param record
         tp_retorno smallint,
         bnfcrtcod like dpakprtbnfcrt.bnfcrtcod
  end record


  define lr_retorno record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100), 
         bnfcrtdes   like dpakprtbnfcrt.bnfcrtdes
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g00_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g00001 using lr_param.bnfcrtcod

  whenever error continue
  fetch cctd27g00001 into lr_retorno.bnfcrtdes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou criterios"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "ctd27g00/ctd27g00_obter_criterios() / ",
                             lr_param.bnfcrtcod

     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  close cctd27g00001

  if lr_param.tp_retorno = 1 then
     return lr_retorno.ret,
            lr_retorno.msg,
            lr_retorno.bnfcrtdes
  end if

end function
