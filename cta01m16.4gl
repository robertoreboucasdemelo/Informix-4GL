#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTA01M16                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 202720 - SAUDE + CASA                                      #
#                  BUSCA DAS INFORMACOES DA TABELA DATKPLNSAU.                #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 22/09/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cta01m16_prep smallint

#-------------------------#
function cta01m16_prepare()
#-------------------------#

  define l_sql char(400)

  let l_sql = " select plndes, ",
                     " plnatnlimnum ",
                " from datkplnsau ",
               " where plncod = ? "

  prepare p_cta01m16_001 from l_sql
  declare c_cta01m16_001 cursor for p_cta01m16_001

  let l_sql = " update datkplnsau ",
                 " set(plndes,plnatnlimnum) = (?,?) ",
               " where plncod = ? "

  prepare p_cta01m16_002 from l_sql

  let l_sql = " insert into datkplnsau ",
                         " (plncod,plndes,plnatnlimnum) ",
                   " values(?,?,?) "

  prepare p_cta01m16_003 from l_sql

  let m_cta01m16_prep = true

end function

#----------------------------------------#
function cta01m16_sel_datkplnsau(l_plncod)
#----------------------------------------#

  define l_plncod       like datkplnsau.plncod,       # -> COD. DO PLANO
         l_plndes       like datkplnsau.plndes,       # -> DESCR. DO PLANO
         l_plnatnlimnum like datkplnsau.plnatnlimnum, # -> LIMITE DE UTILI. PLANO
         l_status       smallint,
         l_msg          char(80)

  #---------------------------------
  # DESCRICAO DO l_status DE RETORNO
  #---------------------------------
  # 1 -> OK, ENCONTROU AS INFORMACOES
  # 2 -> NAO ENCONTROU AS INFORMACOES
  # 3 -> ERRO DE ACESSO A BASE DE DADOS

  if m_cta01m16_prep is null or
     m_cta01m16_prep <> true then
     call cta01m16_prepare()
  end if

  let l_plndes       = null
  let l_plnatnlimnum = null
  let l_status       = 1
  let l_msg          = null

  open c_cta01m16_001 using l_plncod
  whenever error continue
  fetch c_cta01m16_001 into l_plndes,
                          l_plnatnlimnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_status       = 2
        let l_plndes       = null
        let l_plnatnlimnum = null
     else
        let l_status = 3
        let l_msg    = "Erro SELECT c_cta01m16_001 /",
                        sqlca.sqlcode, "/",
                        sqlca.sqlerrd[2]
     end if
  end if

  close c_cta01m16_001

  return l_status,
         l_msg,
         l_plndes,
         l_plnatnlimnum

end function

#--------------------------------------------#
function cta01m16_ins_datkplnsau(lr_parametro)
#--------------------------------------------#

  define lr_parametro record
         plncod       like datkplnsau.plncod,
         plndes       like datkplnsau.plndes,
         plnatnlimnum like datkplnsau.plnatnlimnum
  end record

  define l_status     smallint, # 1 - OK    2 - ERRO
         l_msg        char(80)

  if m_cta01m16_prep is null or
     m_cta01m16_prep <> true then
     call cta01m16_prepare()
  end if

  let l_status = 1
  let l_msg    = null

  whenever error continue
  execute p_cta01m16_003 using lr_parametro.plncod,
                             lr_parametro.plndes,
                             lr_parametro.plnatnlimnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_status = 2
     let l_msg    = "Erro INSERT p_cta01m16_003 /",
                    sqlca.sqlcode, "/",
                    sqlca.sqlerrd[2],
                    lr_parametro.plncod, "/",
                    lr_parametro.plndes, "/",
                    lr_parametro.plnatnlimnum
  end if

  return l_status,
         l_msg

end function

#--------------------------------------------#
function cta01m16_upd_datkplnsau(lr_parametro)
#--------------------------------------------#

  define lr_parametro record
         plncod       like datkplnsau.plncod,
         plndes       like datkplnsau.plndes,
         plnatnlimnum like datkplnsau.plnatnlimnum
  end record

  define l_status     smallint, # 1 - OK    2 - ERRO
         l_msg        char(80)

  if m_cta01m16_prep is null or
     m_cta01m16_prep <> true then
     call cta01m16_prepare()
  end if

  let l_status  = 1
  let l_msg     = null

  whenever error continue
  execute p_cta01m16_002 using lr_parametro.plndes,
                             lr_parametro.plnatnlimnum,
                             lr_parametro.plncod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_status = 2
     let l_msg    = "Erro UPDATE p_cta01m16_002 /",
                    sqlca.sqlcode, "/",
                    sqlca.sqlerrd[2],
                    lr_parametro.plncod, "/",
                    lr_parametro.plndes, "/",
                    lr_parametro.plnatnlimnum
  end if

  return l_status,
         l_msg

end function
