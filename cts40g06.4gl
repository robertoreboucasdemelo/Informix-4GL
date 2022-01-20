#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G06                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  - BLOQUEAR/DESBLOQUEAR VIATURAS.                           #
#                  - BLOQUEAR/DESBLOQUEAR SERVICOS.                           #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID/RAJI D. JAHCHAN                               #
# LIBERACAO......: 09/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g06_prep smallint

#-------------------------#
function cts40g06_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select c24atvcod ",
                " from dattfrotalocal ",
               " where socvclcod = ? "

  prepare p_cts40g06_001 from l_sql
  declare c_cts40g06_001 cursor for p_cts40g06_001

  let l_sql = " update datkveiculo ",
                " set (socacsflg, c24opemat, c24opeempcod, c24opeusrtip) = ",
                    " (?,?,9,'F') ",
               " where socvclcod = ? ",
                 " and socacsflg = ? "

  prepare p_cts40g06_002 from l_sql

  let l_sql = " update datmservico set c24opemat = ? ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g06_003 from l_sql

  let l_sql = " update datmservico ",
                " set (acnsttflg, atdfnlflg, c24opemat) = ('N','N','') ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g06_004 from l_sql

  let m_cts40g06_prep = true

end function

#--------------------------------------#
function cts40g06_bloq_veic(l_socvclcod,l_c24opemat)
#--------------------------------------#

  define l_socvclcod  like datkveiculo.socvclcod,
         l_c24opemat  like datkveiculo.c24opemat

  define l_cod_erro   integer,
         l_bloqueou   smallint,
         l_msg_erro   char(100),
         l_atual      char(01),
         l_futuro     char(01),
         l_c24atvcod  like dattfrotalocal.c24atvcod

  if m_cts40g06_prep is null or
     m_cts40g06_prep <> true then
     call cts40g06_prepare()
  end if

  let l_cod_erro  = 0
  let l_c24atvcod = null
  let l_bloqueou  = false
  let l_msg_erro  = null
  let l_atual     = "0" # -> VEICULO DESBLOQUEADO
  let l_futuro    = "1" # -> VEICULO BLOQUEADO

  open c_cts40g06_001 using l_socvclcod
  fetch c_cts40g06_001 into l_c24atvcod
  close c_cts40g06_001

  if l_c24atvcod = "QRV" then
     whenever error continue
     execute p_cts40g06_002 using l_futuro,
                                l_c24opemat,
                                l_socvclcod,
                                l_atual
     whenever error stop

      if sqlca.sqlcode <> 0 then
        let l_msg_erro = "Erro UPDATE p_cts40g06_002 / ",
                          sqlca.sqlcode, "/",
                          sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "cts40g06_bloq_veic() ", l_futuro, "/",
                                                  l_socvclcod, "/",
                                                  l_atual
        call errorlog(l_msg_erro)
     else

        if sqlca.sqlerrd[3] <> 0 then
           let l_bloqueou = true
        end if

     end if

     let l_cod_erro = sqlca.sqlcode
  end if

  return l_cod_erro,
         l_bloqueou

end function

#--------------------------------------#
function cts40g06_desb_veic(l_socvclcod,l_c24opemat)
#--------------------------------------#

  define l_socvclcod  like datkveiculo.socvclcod,
         l_c24opemat  like datkveiculo.c24opemat

  define l_cod_erro    integer,
         l_msg_erro    char(100),
         l_atual       char(01),
         l_futuro      char(01)

  if m_cts40g06_prep is null or
     m_cts40g06_prep <> true then
     call cts40g06_prepare()
  end if

  let l_cod_erro = 0
  let l_msg_erro = null
  let l_atual    = "1" # -> VEICULO BLOQUEADO
  let l_futuro   = "0" # -> VEICULO DESBLOQUEADO

  whenever error continue
  execute p_cts40g06_002 using l_futuro,
                             l_c24opemat,
                             l_socvclcod,
                             l_atual
  whenever error stop

   if sqlca.sqlcode <> 0 then
     let l_msg_erro = "Erro UPDATE p_cts40g06_002 / ",
                      sqlca.sqlcode, "/",
                      sqlca.sqlerrd[2]
     call errorlog(l_msg_erro)
     let l_msg_erro = "cts40g06_desb_veic() ", l_futuro, "/",
                                               l_socvclcod, "/",
                                               l_atual
     call errorlog(l_msg_erro)
  end if

  let l_cod_erro = sqlca.sqlcode

  return l_cod_erro

end function

#--------------------------------------#
function cts40g06_bloq_srv(lr_parametro)
#--------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_c24opemat  like datmservico.c24opemat,
         l_msg        char(80),
         l_status     integer

  if m_cts40g06_prep is null or
     m_cts40g06_prep <> true then
     call cts40g06_prepare()
  end if

  let l_c24opemat = 999999
  let l_msg       = null
  let l_status    = null

  # -> BLOQUEAR P/ACIONAMENTO AUTOMATICO
  whenever error continue
  execute p_cts40g06_003 using l_c24opemat,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro UPDATE p_cts40g06_003 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg)
     let l_msg = "cts40g06_bloq_srv() ", l_c24opemat, "/",
                                         lr_parametro.atdsrvnum, "/",
                                         lr_parametro.atdsrvano
     call errorlog(l_msg)
     let l_status = sqlca.sqlcode
  else
     call cts00g07_apos_servbloqueia(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)
     let l_status = 0
  end if

  return l_status

end function

#--------------------------------------#
function cts40g06_desb_srv(lr_parametro)
#--------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_c24opemat  like datmservico.c24opemat,
         l_status     integer,
         l_msg        char(80)

  if m_cts40g06_prep is null or
     m_cts40g06_prep <> true then
     call cts40g06_prepare()
  end if

  let l_c24opemat = null
  let l_status    = null
  let l_msg       = null

  # -> LIBERAR P/ACIONAMENTO AUTOMATICO
  whenever error continue
  execute p_cts40g06_003 using l_c24opemat,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro UPDATE p_cts40g06_003 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg)
     let l_msg = "cts40g06_desb_srv() ", l_c24opemat, "/",
                                         lr_parametro.atdsrvnum, "/",
                                         lr_parametro.atdsrvano
     call errorlog(l_msg)
     let l_status = sqlca.sqlcode
  else
     call cts00g07_apos_servdesbloqueia(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)
     let l_status = 0
  end if

  return l_status

end function

#---------------------------------------#
function cts40g06_env_radio(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_msg        char(80),
         l_status     integer

  if m_cts40g06_prep is null or
     m_cts40g06_prep <> true then
     call cts40g06_prepare()
  end if

  let l_msg    = null
  let l_status = null

  whenever error continue
  execute p_cts40g06_004 using lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro UPDATE p_cts40g06_004 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg)

     let l_msg = "cts40g06_env_radio()/", lr_parametro.atdsrvnum, "/",
                                          lr_parametro.atdsrvano
     call errorlog(l_msg)
     let l_status = sqlca.sqlcode
  else
     call cts00g07_apos_grvlaudo(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)
     let l_status = 0
  end if

  return l_status

end function



