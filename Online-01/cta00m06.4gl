#---------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                           #
# ..........................................................................#
# Sistema       : Central 24 horas                                          #
# Modulo        : cta00m06                                                  #
# Analista Resp.: Ligia Mattge                                              #
# PSI           : 191094                                                    #
#                 Consistir o depertamento do atendente para definir o aceso#
#                 de exibicao das informacoes no sistema                    #
#...........................................................................#
# Desenvolvimento: Daniel , META                                            #
# Liberacao      : 11/09/2004                                               #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor  Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- -------------------------------------#
# 30/06/2009  Amilton,Meta             Definir libera��o de acesso ao       #
#                                      acionamento ao departamentos         #
# ----------  -------------- --------- -------------------------------------#
# 12/11/2009  Amilton,Meta             Definir atraves de uma chave de      #
#                                      dominio o acesso a nova tela de      #
#                                      indexacao de enderecos               #
#---------------------------------------------------------------------------#

database porto

define m_prep smallint
 define m_mens char(100)


function cta00m06_prepare()

  define l_sql char(500)
  let l_sql = null

  ---------------datkdominio------------------------------
  let l_sql = "select count(*) from datkdominio ",
              " where cponom = ? ",
              " and   cpodes = ? "
  prepare pcta00m06001 from l_sql
  declare ccta00m06001 cursor with hold for pcta00m06001

  let l_sql = "select count(*) from datkdominio ",
              " where cponom = ? ",
              " and   cpocod = ? "
  prepare pcta00m06002 from l_sql
  declare ccta00m06002 cursor with hold for pcta00m06002

  let l_sql = "select cpodes from datkdominio ",
              " where cponom = ? "
  prepare pcta00m06003 from l_sql
  declare ccta00m06003 cursor with hold for pcta00m06003

  ---------------iddkdominio------------------------------
  let l_sql = "select count(*) from iddkdominio ",
              " where cponom = ? ",
              " and   cpodes = ? "
  prepare pcta00m06004 from l_sql
  declare ccta00m06004 cursor with hold for pcta00m06004

  let l_sql = "select cpocod from datkdominio ",
              " where cponom = ? "
  prepare pcta00m06005 from l_sql
  declare ccta00m06005 cursor with hold for pcta00m06005
  let l_sql = "select count(*) from iddkdominio ",
              " where cponom = ? ",
              " and   cpodes = ? "
  prepare pcta00m06006 from l_sql
  declare ccta00m06006 cursor with hold for pcta00m06006
  let l_sql = "select count(*) from iddkdominio ",
              " where cponom = ? "
  prepare pcta00m06007 from l_sql
  declare ccta00m06007 cursor with hold for pcta00m06007
  let l_sql = "select count(*) from iddkdominio ",
              " where cponom = ? ",
              " and   substr(cpodes,1,3) = ? "
  prepare pcta00m06008 from l_sql
  declare ccta00m06008 cursor with hold for pcta00m06008
  let l_sql = "select substr(cpodes,5,2) from iddkdominio ",
              " where cponom = ? ",
              " and   substr(cpodes,1,3) = ? "
  prepare pcta00m06009 from l_sql
  declare ccta00m06009 cursor with hold for pcta00m06009
  let l_sql = ' select cpodes        '
             ,' from iddkdominio     '
             ,' where cponom =  ?    '
  prepare pcta00m06010 from l_sql
  declare ccta00m06010 cursor for pcta00m06010
  let l_sql = ' select count(*)       '
             ,' from iddkdominio      '
             ,' where cponom =  ?     '
             ,' and cpodes[01,02] = ? '
             ,' and cpodes[04,14] = ? '
  prepare pcta00m06011 from l_sql
  declare ccta00m06011 cursor for pcta00m06011
  let m_prep = true

end function


#----------------------------------------------------
function cta00m06(l_param_dptsgl)
#----------------------------------------------------

   define l_param_dptsgl  like isskfunc.dptsgl
   define l_flag_acesso   smallint
   if l_param_dptsgl = "c24tpf" then
      let l_flag_acesso = 0 # Tem acesso limitado no sistema
   else
      let l_flag_acesso = 1 # Tem acesso total no sistema
   end if
   return l_flag_acesso

end function

function cta00m06_acionamento(l_param_dptsgl)

   define l_param_dptsgl like isskfunc.dptsgl
   define l_flag_acesso  smallint
   define l_chave        char(20)
   let l_flag_acesso = 0
   let l_chave = 'acesso_acionamento'
   if m_prep = false or
      m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06001 using l_chave,l_param_dptsgl
   fetch ccta00m06001 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   return l_flag_acesso
end function

function cta00m06_sinistro_re(l_param_dptsgl)

define l_param_dptsgl like isskfunc.dptsgl
   define l_flag_acesso  smallint
   define l_chave        char(20)
   let l_flag_acesso = 0
   let l_chave = 'sinistro_re'
   if m_prep = false or
      m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06001 using l_chave,l_param_dptsgl
   fetch ccta00m06001 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   return l_flag_acesso

end function

function cta00m06_acesso_espelho(l_param_dptsgl)

   define l_param_dptsgl like isskfunc.dptsgl
   define l_flag_acesso  smallint
   define l_chave        char(20)
   let l_flag_acesso = 0
   let l_chave = 'acesso_espelho'
   if m_prep = false or m_prep is null then call cta00m06_prepare() end if
   whenever error continue
   open ccta00m06001 using l_chave,l_param_dptsgl
   fetch ccta00m06001 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   return l_flag_acesso

end function

function cta00m06_assunto_reclamacao(l_param)

   define l_param record
        assunto like datkassunto.c24astcod
       ,agp     like datkassunto.c24astagp
   end record
   define l_flag_acesso  smallint
   define l_chave        char(20)
   let l_flag_acesso = 0
   let l_chave = 'assunto_reclamacao'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06001 using l_chave,l_param.assunto
   fetch ccta00m06001 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   # Verifica o Agrupamento
   if l_flag_acesso = false then
      whenever error continue
      open ccta00m06001 using l_chave,l_param.agp
      fetch ccta00m06001 into l_flag_acesso
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
         call errorlog(m_mens)
         error m_mens
      end if
   end if
   return l_flag_acesso

end function

function cta00m06_grava_tabela(l_param)

   define l_param record
       assunto like datkassunto.c24astcod
      ,agp     like datkassunto.c24astagp
   end record
   define l_flag_acesso  smallint
   define l_chave        char(20)
   let l_flag_acesso = 0
   let l_chave = 'grava_tab_reclam'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06001 using l_chave,l_param.assunto
   fetch ccta00m06001 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   # Verifica o Agrupamento
   if l_flag_acesso = false then
      whenever error continue
      open ccta00m06001 using l_chave,l_param.agp
      fetch ccta00m06001 into l_flag_acesso
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
         call errorlog(m_mens)
         error m_mens
      end if
   end if
   return l_flag_acesso

end function

function cta00m06_acesso_indexacao_aut(l_atdsrvorg)

   define l_atdsrvorg like datmservico.atdsrvorg
   define l_flag_acesso  smallint
   define l_chave        char(20)
   let l_flag_acesso = false
   let l_chave = 'acesso_indexacao'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06002 using l_chave,l_atdsrvorg
   fetch ccta00m06002 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   return l_flag_acesso
end function

function cta00m06_carro_extra()
   define l_dias  char(3)
   define l_chave char(20)
   let l_dias = null
   let l_chave = 'carro_extra'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06003 using l_chave
   fetch ccta00m06003 into l_dias
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   return l_dias clipped
end function

function cta00m06_assunto_cort(l_c24astcod)

   define l_c24astcod like datkassunto.c24astcod

define l_flag_acesso  smallint
   define l_chave        char(20)

   let l_flag_acesso = false
   let l_chave = 'c24astcod_cort'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06004 using l_chave,l_c24astcod
   fetch ccta00m06004 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA IDDKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if
   return l_flag_acesso

end function

#----------------------------------------------------------------
function cta00m06_pet_vantagens() # PET
#----------------------------------------------------------------

   define l_flag_acesso  smallint
   define l_chave        char(20)
   define l_codigo       like datkdominio.cpodes
   define l_retorno      char(200)
   define l_qtd          integer
   define l_data_vig     date
   let l_flag_acesso = false
   let l_chave = 'pet_vantagens'
   let l_qtd = 0
   let l_retorno  = null
   let l_data_vig = null
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into l_codigo
        let l_qtd = l_qtd + 1
        if l_qtd > 1 then
           let l_retorno = l_retorno clipped , ',' ,l_codigo
        else
           let l_retorno = l_retorno clipped, l_codigo
        end if
   end foreach
   if l_qtd >= 1 then
      let l_retorno = '(' , l_retorno clipped , ')'
   end if
   whenever error stop

   if l_qtd = 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
   end if
   let l_chave = 'pet_data_vantagens'
   whenever error continue
   open ccta00m06003 using l_chave
   fetch ccta00m06003 into l_data_vig
   whenever error stop

   if l_data_vig is null then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE(",l_chave,") NA DATKDOMINIO "
      call errorlog(m_mens)
   end if
   return l_retorno,l_qtd, l_data_vig

end function
function cta00m06_re_contacorrente()

   define l_flag  char(1)
   define l_chave char(20)
   let l_flag = null
   let l_chave = 'conta_corrente'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06003 using l_chave
   fetch ccta00m06003 into l_flag
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if

   if l_flag = 'S' or
      l_flag = 's' then
      return true
   else
      return false
   end if


end function

function cta00m06_assistencia_multiplo(l_asitipcod)
   define l_asitipcod         like datmservico.asitipcod

   define l_flag_acesso  smallint
   define l_chave        char(20)

   let l_flag_acesso = false
   let l_chave = 'assistencia_multip'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06002 using l_chave,l_asitipcod
   fetch ccta00m06002 into l_flag_acesso
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if
   close ccta00m06002
   return l_flag_acesso


end function

#----------------------------------------
function cta00m06_alerta_despesas()
#----------------------------------------

   define l_vlr   integer
   define l_qtde  integer
   define l_chave char(20)
   let l_vlr   = 0
   let l_qtde  = 0
   let l_chave = 'alerta_vlr'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06003 using l_chave
   fetch ccta00m06003 into l_vlr
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   close ccta00m06003
   let l_chave = 'alerta_qtde'
   whenever error continue
   open ccta00m06003 using l_chave
   fetch ccta00m06003 into l_qtde
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   return l_vlr,
          l_qtde

end function

#======================================
function cta00m06_lista_email_alerta()
#======================================

   define emails   array[20] of char(100)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer
   for i = 1 to 20
       let emails[i] = null
   end for
   let i   = 1
   let l_lista  = null
   let l_chave = 'alerta_email'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into emails[i]
    if i = 1 then
      let l_lista = emails[i] clipped
    else
      let l_lista = l_lista clipped
                    ,","
                    ,emails[i] clipped
    end if
    let i = i+1
  end foreach
  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   close ccta00m06003
   return l_lista

end function

function cta00m06_empresas_atend_corretor()

define empresa   array[20] of smallint
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer
   for i = 1 to 20
       let empresa[i] = null
   end for
   let i   = 1
   let l_lista  = null
   let l_chave = 'empresa_corretor'
   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06005 using l_chave
   foreach ccta00m06005 into empresa[i]
    if i = 1 then
      let l_lista = empresa[i] clipped
    else
      let l_lista = l_lista clipped
                    ,","
                    ,empresa[i] clipped
    end if
    let i = i+1
  end foreach
  let l_lista = " ( ",l_lista clipped, " ) "
  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if
   close ccta00m06005
   return l_lista

end function
# -----------------------------------------------------------------------------
 function cta00m06_tipo_logradouro()
# -----------------------------------------------------------------------------
   define tplogradouro   array[20] of char(20)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer

   for i = 1 to 20
       let tplogradouro[i] = null
   end for

   let i   = 1
   let l_lista  = null
   let l_chave = 'Tipo_lougradouro'

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into tplogradouro[i]

   let tplogradouro[i] = upshift(tplogradouro[i])

    if i = 1 then
      let l_lista = tplogradouro[i] clipped
    else
      let l_lista = l_lista clipped
                    ,"|"
                    ,tplogradouro[i] clipped
    end if

    let i = i+1
  end foreach

  let l_lista = l_lista clipped

  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if

   close ccta00m06003

   return l_lista

end function



# -----------------------------------------------------------------------------
 function cta00m06_tipo_marginal()
# -----------------------------------------------------------------------------
   define tpmarginal   array[20] of char(200)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer

   for i = 1 to 20
       let tpmarginal[i] = null
   end for

   let i   = 1
   let l_lista  = null
   let l_chave = 'Tipo_marginal'

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into tpmarginal[i]

  let tpmarginal[i] = upshift(tpmarginal[i])


    if i = 1 then
      let l_lista = tpmarginal[i] clipped
    else
      let l_lista = l_lista clipped
                    ,"|"
                    ,tpmarginal[i] clipped
    end if

    let i = i+1
  end foreach

  let l_lista = l_lista clipped

  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if

   close ccta00m06003

   return l_lista

end function



# -----------------------------------------------------------------------------
 function cta00m06_tipo_sentido()
# -----------------------------------------------------------------------------
   define tpsentido   array[20] of char(20)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer

   for i = 1 to 20
       let tpsentido[i] = null
   end for

   let i   = 1
   let l_lista  = null
   let l_chave = 'Tipo_sentido'

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into tpsentido[i]

    if i = 1 then
      let l_lista = tpsentido[i] clipped
    else
      let l_lista = l_lista clipped
                    ,"|"
                    ,tpsentido[i] clipped
    end if

    let i = i+1
  end foreach

  let l_lista = l_lista clipped

  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if

   close ccta00m06003

   return l_lista

end function



# -----------------------------------------------------------------------------
 function cta00m06_tipo_sentido2()
# -----------------------------------------------------------------------------
   define tpsentido2   array[20] of char(20)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer

   for i = 1 to 20
       let tpsentido2[i] = null
   end for

   let i   = 1
   let l_lista  = null
   let l_chave = 'Tipo_sentido2'

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into tpsentido2[i]

    if i = 1 then
      let l_lista = tpsentido2[i] clipped
    else
      let l_lista = l_lista clipped
                    ,"|"
                    ,tpsentido2[i] clipped
    end if

    let i = i+1
  end foreach

  let l_lista = l_lista clipped

  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if

   close ccta00m06003

   return l_lista

end function



# -----------------------------------------------------------------------------
 function cta00m06_tipo_pista_marginal()
# -----------------------------------------------------------------------------
   define tppista   array[20] of char(200)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer

   for i = 1 to 20
       let tppista[i] = null
   end for

   let i   = 1
   let l_lista  = null
   let l_chave = 'Tipo_pista_marg'

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into tppista[i]

    if i = 1 then
      let l_lista = tppista[i] clipped
    else
      let l_lista = l_lista clipped
                    ,"|"
                    ,tppista[i] clipped
    end if

    let i = i+1
  end foreach

  let l_lista = l_lista clipped

  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if

   close ccta00m06003

   return l_lista

end function

function cta00m06_tipo_pista_rodovia()
# -----------------------------------------------------------------------------
   define tppista   array[20] of char(200)
   define l_lista  char(1000)
   define l_chave  char(20)
   define i        integer

   for i = 1 to 20
       let tppista[i] = null
   end for

   let i   = 1
   let l_lista  = null
   let l_chave = 'Tipo_pista_Rod'

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into tppista[i]

    if i = 1 then
      let l_lista = tppista[i] clipped
    else
      let l_lista = l_lista clipped
                    ,"|"
                    ,tppista[i] clipped
    end if

    let i = i+1
  end foreach

  let l_lista = l_lista clipped

  if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(m_mens)
      error m_mens
   end if

   close ccta00m06003

   return l_lista

end function

#=============================================
function cta00m06_assunto_sinistro(l_assunto)
#=============================================

   define l_assunto like datkassunto.c24astcod

   define l_flag_acesso  smallint
   define l_chave        char(20)



   let l_flag_acesso = false
   let l_chave = 'assunto_sinistro'


   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06001 using l_chave,l_assunto
   fetch ccta00m06001 into l_flag_acesso
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if

   return l_flag_acesso
end function


#=============================================
 function cta00m06_jit_cidades(l_cidade,l_uf)
#=============================================
 define l_cidade          char(100)
 define l_uf              char(2)
 define l_chave           char(20)
 define l_flag_acesso     smallint
 define l_aux_cidade      char(100)

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   let l_flag_acesso = 0

   let l_chave = 'jit_cidnom'
   let l_chave = l_chave clipped

   # trata cidade/uf : 'SAO PAULO-SP'
   let l_aux_cidade = l_cidade clipped,'-',l_uf clipped
   let l_aux_cidade = l_aux_cidade clipped
   #

   whenever error continue
     open ccta00m06001 using l_chave
                           , l_aux_cidade
     fetch ccta00m06001 into l_flag_acesso
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO (jit_L11_L12)"
      call errorlog(m_mens)
      error m_mens
   end if

   return l_flag_acesso
end function

#=============================================
 function cta00m06_jit_email()
#=============================================
   define l_email        like datkdominio.cpodes
   define l_flag         smallint
   define l_lista_email  char(500)
   define l_chave        char(20)

   let l_lista_email = ''
   let l_email       = ''
   let l_chave       = 'jit_email'
   let l_flag        = 1

   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if

   whenever error continue
   open ccta00m06003 using l_chave
   foreach ccta00m06003 into l_email

     if l_flag = 1 then
        let l_flag = 2
        let l_lista_email = l_email clipped
     else
        let l_lista_email = l_lista_email clipped, ',' , l_email clipped
     end if

     let l_lista_email = l_lista_email clipped

   end foreach
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO (jit_email) "
      call errorlog(m_mens)
      error m_mens
   end if

   return l_lista_email
end function

#=============================================
function cta00m06_verifica_mtvassistencia(l_motivo)
#=============================================

   define l_motivo like datkasimtv.asimtvcod

   define l_flag_acesso  smallint
   define l_chave        char(20)



   let l_flag_acesso = false
   let l_chave = 'mtv_assistencia'


   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06002 using l_chave,l_motivo
   fetch ccta00m06002 into l_flag_acesso
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if

   return l_flag_acesso
end function

#=============================================
function cta00m06_verifica_tipo_assistencia(l_asitipcod)
#=============================================

   define l_asitipcod      like datkasitip.asitipcod

   define l_flag_acesso  smallint
   define l_chave        char(20)



   let l_flag_acesso = false
   let l_chave = 'tipo_assistencia'


   if m_prep = false or m_prep is null then
      call cta00m06_prepare()
   end if
   whenever error continue
   open ccta00m06002 using l_chave,l_asitipcod
   fetch ccta00m06002 into l_flag_acesso
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if

   return l_flag_acesso
end function

function cta00m06_permissao_comodidade(lr_param)
define lr_param record
       c24astcod like datkassunto.c24astcod,
       ramcod    like datrligapol.ramcod,
       succod    like datrligapol.succod,
       aplnumdig like datrligapol.aplnumdig,
       itmnumdig like datrligapol.itmnumdig
end record
define ws record
       clscod     like abbmclaus.clscod,
       clscodant  like abbmclaus.clscod
end record
define l_chave        char(20)
define l_retorno      smallint
define l_funapol       record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record
initialize l_funapol.* to null
let ws.clscod = null
let ws.clscodant = null
let l_retorno = null
let l_chave = 'cls_comodidade'
if m_prep = false or m_prep is null then
   call cta00m06_prepare()
end if
       call f_funapol_ultima_situacao(lr_param.succod,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig)
                            returning l_funapol.*
       declare c_cta00m06007 cursor for
        select clscod
          from abbmclaus
         where succod    = lr_param.succod
           and aplnumdig = lr_param.aplnumdig
           and itmnumdig = lr_param.itmnumdig
           and dctnumseq = l_funapol.dctnumseq
           and clscod in ("033","33R","034","035","34A","35A","35R",
                          "044","44R","046","46R","047","47R","048",
                          "48R","095")
       foreach c_cta00m06007 into ws.clscod
          if ws.clscod <> "034" and
             ws.clscod <> "071" then
              let ws.clscodant = ws.clscod
          end if
          if ws.clscod = "034" or
             ws.clscod = "071" then
           if cta13m00_verifica_clausula(lr_param.succod        ,
                                         lr_param.aplnumdig     ,
                                         lr_param.itmnumdig     ,
                                         l_funapol.dctnumseq ,
                                         ws.clscod           ) then
              let ws.clscod = ws.clscodant
              continue foreach
           end if
          end if
          exit foreach
       end foreach
whenever error continue
open ccta00m06006 using l_chave,
                        ws.clscod
fetch ccta00m06006 into l_retorno
whenever error stop
return l_retorno
end function
function cta00m06_exibe_problema(lr_param)
define lr_param record
       c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod,
       ramcod    like datrligapol.ramcod,
       succod    like datrligapol.succod,
       aplnumdig like datrligapol.aplnumdig,
       itmnumdig like datrligapol.itmnumdig
end record
define ws record
       clscod     like abbmclaus.clscod,
       clscodant  like abbmclaus.clscod
end record
define l_chave        char(20)
define l_retorno      smallint
define l_funapol       record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record
define l_autimsvlr          like abbmcasco.imsvlr
define l_count  integer
initialize l_funapol.* to null
let ws.clscod = null
let ws.clscodant = null
let l_retorno = null
let l_chave = null
let l_autimsvlr = null
let l_count = 0
if m_prep = false or m_prep is null then
   call cta00m06_prepare()
end if
       call f_funapol_ultima_situacao(lr_param.succod,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig)
                            returning l_funapol.*
       declare c_cta00m06008 cursor for
        select clscod
          from abbmclaus
         where succod    = lr_param.succod
           and aplnumdig = lr_param.aplnumdig
           and itmnumdig = lr_param.itmnumdig
           and dctnumseq = l_funapol.dctnumseq
           and clscod in ("033","33R","034","035","34A","35A","35R",
                          "044","44R","046","46R","047","47R","048",
                          "48R","095")
       foreach c_cta00m06008 into ws.clscod
          if ws.clscod <> "034" and
             ws.clscod <> "071" then
              let ws.clscodant = ws.clscod
          end if
          if ws.clscod = "034" or
             ws.clscod = "071" then
           if cta13m00_verifica_clausula(lr_param.succod        ,
                                         lr_param.aplnumdig     ,
                                         lr_param.itmnumdig     ,
                                         l_funapol.dctnumseq ,
                                         ws.clscod           ) then
              let ws.clscod = ws.clscodant
              continue foreach
           end if
          end if
          exit foreach
       end foreach
     call cta00m06_verifica_chave(ws.clscod)
          returning l_chave
     if l_chave is not null then
          whenever error continue
          open ccta00m06008 using l_chave,
                                  lr_param.c24pbmgrpcod
          fetch ccta00m06008 into l_count
          whenever error stop
     else
         let l_count = 1
     end if
    if l_count > 0 then
       let l_retorno = true
    else
       let l_retorno = false
    end if
    if l_retorno = true and
       ws.clscod = '044' and
       lr_param.c24pbmgrpcod = 116 then
       call cty26g00_ims_veic(lr_param.succod   ,
                              lr_param.aplnumdig,
                              lr_param.itmnumdig)
          returning l_autimsvlr
       if l_autimsvlr <= 110000 then
          let l_retorno = false
       end if
    end if
  return l_retorno
end function
function cta00m06_verifica_chave(lr_param)
define lr_param record
       clscod like abbmclaus.clscod
end record
define l_chave   char(20)
define l_retorno char(20)
define l_count   integer
let l_chave = null
let l_retorno = null
let l_count = 0
case lr_param.clscod
when "033"
    let l_chave = 'clausula_33'
when "33R"
    let l_chave = 'clausula_33R'
when "034"
    let l_chave = 'clausula_34'
when "34A"
    let l_chave = 'clausula_34A'
when "035"
    let l_chave = 'clausula_35'
when "35A"
    let l_chave = 'clausula_35A'
when "35R"
    let l_chave = 'clausula_35R'
when "044"
    let l_chave = 'clausula_44'
when "44R"
    let l_chave = 'clausula_44R'
when "046"
    let l_chave = 'clausula_46'
when "46R"
    let l_chave = 'clausula_46R'
when "047"
    let l_chave = 'clausula_47'
when "47R"
    let l_chave = 'clausula_47R'
when "048"
    let l_chave = 'clausula_48'
when "48R"
    let l_chave = 'clausula_48R'
when "095"
    let l_chave = 'clausula_95'
end case
whenever error continue
open ccta00m06007 using l_chave
fetch ccta00m06007 into l_count
whenever error stop
if l_count > 0 then
   let l_retorno = l_chave
end if
return l_retorno
end function
function cta00m06_buscalimite(lr_param)
    define lr_param record
           clscod like abbmclaus.clscod,
           c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod
    end record
    define l_limite char(5)
    define l_chave char(20)
    define lr_retorno smallint
    let l_limite = null
    let l_chave = null
    let lr_retorno = 0
    call cta00m06_verifica_chave(lr_param.clscod)
          returning l_chave
     if l_chave is not null then
          whenever error continue
          open ccta00m06009 using l_chave,
                                  lr_param.c24pbmgrpcod
          fetch ccta00m06009 into l_limite
          whenever error stop
     else
         let l_limite = 999
     end if
     if l_limite = " " or
        l_limite is null then
        let lr_retorno = 999
     else
        let lr_retorno = l_limite
     end if
return lr_retorno
end function
#========================================================================
 function cta00m06_recupera_email()
#========================================================================
define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes,
	email   char(32766)            ,
	flag    smallint
end record
initialize lr_retorno.* to null
let lr_retorno.flag = true
let lr_retorno.cponom = "cta00m06_email"
  open ccta00m06010 using  lr_retorno.cponom
  foreach ccta00m06010 into lr_retorno.cpodes
    if lr_retorno.flag then
      let lr_retorno.email = lr_retorno.cpodes clipped
      let lr_retorno.flag  = false
    else
      let lr_retorno.email = lr_retorno.email clipped, ";", lr_retorno.cpodes clipped
    end if
  end foreach
  return lr_retorno.email
end function
#========================================================================
function cta00m06_dispara_email(lr_param)
#========================================================================
define lr_param record
	succod       like abbmdoc.succod        ,
	ramcod       like datrservapol.ramcod   ,
  aplnumdig    like abbmdoc.aplnumdig     ,
  itmnumdig    like abbmdoc.itmnumdig     ,
  lignum       like datmligacao.lignum    ,
  c24astcod    like datkassunto.c24astcod
end record
define lr_mail      record
       de           char(500)
      ,para         char(5000)
      ,cc           char(500)
      ,cco          char(500)
      ,assunto      char(500)
      ,mensagem     char(32766)
      ,id_remetente char(20)
      ,tipo         char(4)
end  record
define lr_retorno record
       segnom      like gsakseg.segnom,
       corsus      like datmservico.corsus,
       cornom      like datmservico.cornom,
       cvnnom      char (20),
       vclcoddig   like datmservico.vclcoddig,
       vcldes      like datmservico.vcldes,
       vclanomdl   like datmservico.vclanomdl,
       vcllicnum   like datmservico.vcllicnum,
       vclchsinc   like abbmveic.vclchsinc,
       vclchsfnl   like abbmveic.vclchsfnl,
       vclcordes   char (12),
       vclchsnum   char(20)
 end record
define l_erro  smallint
define msg_erro char(500)
initialize lr_mail.*, lr_retorno.* to null
    call cts05g00 (lr_param.succod      ,
                   lr_param.ramcod      ,
                   lr_param.aplnumdig   ,
                   lr_param.itmnumdig)
         returning lr_retorno.segnom    ,
                   lr_retorno.corsus    ,
                   lr_retorno.cornom    ,
                   lr_retorno.cvnnom    ,
                   lr_retorno.vclcoddig ,
                   lr_retorno.vcldes    ,
                   lr_retorno.vclanomdl ,
                   lr_retorno.vcllicnum ,
                   lr_retorno.vclchsinc ,
                   lr_retorno.vclchsfnl ,
                   lr_retorno.vclcordes
    let lr_mail.de      = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para    = cta00m06_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""
    let lr_mail.assunto = lr_retorno.segnom clipped
    let lr_mail.mensagem  = cta00m06_monta_mensagem(lr_param.lignum    ,
                                                    lr_param.c24astcod ,
                                                    lr_param.succod    ,
                                                    lr_param.aplnumdig ,
                                                    lr_param.itmnumdig ,
                                                    lr_retorno.vcllicnum)
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"
    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------
     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro
#========================================================================
end function
#========================================================================
#========================================================================
function cta00m06_monta_mensagem(lr_param)
#========================================================================
define lr_param record
	 lignum     like datmligacao.lignum    ,
	 c24astcod  like datkassunto.c24astcod ,
	 succod     like abbmdoc.succod        ,
	 aplnumdig  like abbmdoc.aplnumdig     ,
	 itmnumdig  like abbmdoc.itmnumdig     ,
	 vcllicnum  like datmservico.vcllicnum
end record
define lr_retorno record
	mensagem  char(30000)
end record
initialize lr_retorno.* to null
          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------
          let lr_retorno.mensagem = " NUMERO DA LIGACAO: "   , lr_param.lignum    , "<br>",
                                    " APOLICE: "             , lr_param.succod    using "<<"          , " - ",
                                                               lr_param.aplnumdig using "<<<<<<<<<<"  , " - ",
                                                               lr_param.itmnumdig using "<<<<"        , "<br>",
                                    " ASSUNTO: "             , lr_param.c24astcod , "<br>",
                                    " PLACA: "               , lr_param.vcllicnum clipped
          return lr_retorno.mensagem
#========================================================================
end function
#========================================================================
#========================================================================
 function cta00m06_verifica_apolice(lr_param)
#========================================================================
define lr_param record
	succod       like abbmdoc.succod         ,
	ramcod       like datrservapol.ramcod    ,
  aplnumdig    like abbmdoc.aplnumdig      ,
  itmnumdig    like abbmdoc.itmnumdig      ,
  lignum       like datmligacao.lignum     ,
  c24astcod    like datkassunto.c24astcod
end record
define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	qtd     integer
end record
initialize lr_retorno.* to null
let lr_retorno.cponom = "cta00m06_apol"
  whenever error continue
  open ccta00m06011 using  lr_retorno.cponom,
                           lr_param.succod  ,
                           lr_param.aplnumdig
  fetch ccta00m06011 into lr_retorno.qtd
  whenever error stop
  if lr_retorno.qtd is not null and
  	 lr_retorno.qtd > 0         then
     call cta00m06_dispara_email(lr_param.succod    ,
                                 lr_param.ramcod    ,
                                 lr_param.aplnumdig ,
                                 lr_param.itmnumdig ,
                                 lr_param.lignum    ,
                                 lr_param.c24astcod )
  end if
end function