#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd27g05                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 229784                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA dpaksrvgrp        #
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
function ctd27g05_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select prtbnfgrpdes ",
                " from dpaksrvgrp ",
               " where prtbnfgrpcod = ? "

  prepare pctd27g05001 from l_sql
  declare cctd27g05001 cursor for pctd27g05001

  let m_prep = true

end function

#-----------------------------------------#
function ctd27g05_obter_desc_grp(lr_param)
#-----------------------------------------#
  define lr_param record
         tp_retorno smallint,
         prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod
  end record


  define lr_retorno record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100), 
         prtbnfgrpdes   like dpaksrvgrp.prtbnfgrpdes
  end record

  if m_prep is null or m_prep <> true then
     call ctd27g05_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno.* to null

  open cctd27g05001 using lr_param.prtbnfgrpcod

  whenever error continue
  fetch cctd27g05001 into lr_retorno.prtbnfgrpdes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.ret = 2
        let lr_retorno.msg = "Nao encontrou descricao do grupo"
     else
        let lr_retorno.ret = 3
        let lr_retorno.msg = "ctd27g05/ctd27g05_obter_desc_grp() / ",
                             lr_param.prtbnfgrpcod

     end if
  else
     let lr_retorno.ret = 1
     let lr_retorno.msg  = null
  end if

  close cctd27g05001

  if lr_param.tp_retorno = 1 then
     return lr_retorno.ret,
            lr_retorno.msg,
            lr_retorno.prtbnfgrpdes
  end if

end function
