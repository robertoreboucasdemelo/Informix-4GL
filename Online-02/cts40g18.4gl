#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTS40G18                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTOMOVEL                  #
#                  VERIFICA SE O SERVICO ESTA SENDO ALTERADO PELO ATENDENTE   #
#                  NO MOMENTO DO ACIONAMENTO AUTOMATICO.                      #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g18_prep smallint

#-------------------------#
function cts40g18_prepare()
#-------------------------#

  define l_sql char(500)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

   let l_sql = " select c24opemat ",
                 " from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "

  prepare p_cts40g18_001 from l_sql
  declare c_cts40g18_001 cursor for p_cts40g18_001

  let l_sql = " update datmservico ",
                 " set c24opemat = ? ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g18_002 from l_sql

  let l_sql = " select atdetpcod from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = (select max(atdsrvseq) from datmsrvacp ",
                                   " where atdsrvnum = ? ",
                                     " and atdsrvano = ?) "

  prepare p_cts40g18_003 from l_sql
  declare c_cts40g18_002 cursor for p_cts40g18_003

  let l_sql = " select atdfnlflg ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g18_004 from l_sql
  declare c_cts40g18_003 cursor for p_cts40g18_004

  let m_cts40g18_prep = true

end function

#----------------------------------------#
function cts40g18_srv_em_uso(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_em_uso     smallint,
         l_c24opemat  like datmservico.c24opemat,
         l_msg        char(80)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_em_uso  =  null
        let     l_c24opemat  =  null
        let     l_msg  =  null

  if m_cts40g18_prep is null or
     m_cts40g18_prep <> true then
     call cts40g18_prepare()
  end if

  let l_em_uso    = false

  open c_cts40g18_001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  whenever error continue
  fetch c_cts40g18_001 into l_c24opemat
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_c24opemat = null
     else
        let l_msg = "Erro SELECT c_cts40g18_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg)
        let l_msg = "cts40g18_srv_em_uso() / ", lr_parametro.atdsrvnum, "/",
                                                lr_parametro.atdsrvano
        call errorlog(l_msg)
     end if
  end if

  close c_cts40g18_001

  # SE ENCONTROU MATRICULA, O SERVICO ESTA EM USO
  if l_c24opemat is not null then
     let l_em_uso = true
  end if

  return l_em_uso, l_c24opemat

end function

#--------------------------------------#
function cts40g18_bloqueia_srv(lr_param)
#--------------------------------------#

  define lr_param     record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_em_uso    smallint,
         l_c24opemat like datmservico.c24opemat,
         l_status    integer


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_em_uso  =  null
        let     l_c24opemat  =  null
        let     l_status  =  null

  if m_cts40g18_prep is null or
     m_cts40g18_prep <> true then
     call cts40g18_prepare()
  end if

  let l_em_uso    = false

  # --> VERIFICA SE O SERVICO ESTA EM USO
  call cts40g18_srv_em_uso(lr_param.atdsrvnum,
                           lr_param.atdsrvano)

       returning l_em_uso,
                 l_c24opemat

  # -> SE NAO TEM NINGUEM USANDO O SERVICO, BLOQUEIA P/ACIONAMENTO AUTOMATICO
  if l_em_uso = false  then
     let l_c24opemat = 999999
  else
     # -> SE ACIONOU AUTOMATICO, DESBLOQUEIA
     let l_c24opemat = null
  end if

  whenever error continue
  execute p_cts40g18_002 using l_c24opemat,
                             lr_param.atdsrvnum,
                             lr_param.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     display "Erro UPDATE p_cts40g18_002 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     display "bdbsa069_bloqueia_srv() ", l_c24opemat, "/",
                                         lr_param.atdsrvnum, "/",
                                         lr_param.atdsrvano
  else
    call cts00g07_apos_servbloqueia(lr_param.atdsrvnum,lr_param.atdsrvano)
  end if

  let l_status = sqlca.sqlcode

  return l_status

end function

#---------------------------------#
function cts40g18_srv(lr_parametro)
#---------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_atdetpcod like datmsrvacp.atdetpcod,
         l_msg        char(80)

  if m_cts40g18_prep is null or
     m_cts40g18_prep <> true then
     call cts40g18_prepare()
  end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_atdetpcod  =  null
        let     l_msg  =  null

  open c_cts40g18_002 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch c_cts40g18_002 into l_atdetpcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_atdetpcod = null
     else
        let l_msg = "Erro SELECT c_cts40g18_002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg)
        let l_msg = "cts40g18_srv() / ", lr_parametro.atdsrvnum, "/",
                                         lr_parametro.atdsrvano
        call errorlog(l_msg)
     end if
  end if

  close c_cts40g18_002

  if l_atdetpcod = 3 or
     l_atdetpcod = 4 or
     l_atdetpcod = 5 then
     return true ## SERVICO ACIONADO/CANCELADO
  else
     return false
  end if

end function

#--------------------------------------------#
function cts40g18_srv_finalizado(lr_parametro)
#--------------------------------------------#

  # -> VERIFICA SE O SERVICO JA FOI FINALIZADO

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_atdfnlflg  like datmservico.atdfnlflg,
         l_finalizado smallint

  if m_cts40g18_prep is null or
     m_cts40g18_prep <> true then
     call cts40g18_prepare()
  end if

  let l_atdfnlflg  = null
  let l_finalizado = false

  open c_cts40g18_003 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  fetch c_cts40g18_003 into l_atdfnlflg
  close c_cts40g18_003

  if l_atdfnlflg = "S" then
     let l_finalizado = true  # SERVICO FINALIZADO
  end if

  return l_finalizado

end function
