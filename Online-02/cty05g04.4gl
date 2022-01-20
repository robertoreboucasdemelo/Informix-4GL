#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTY05G03                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: Obter dados da tabela abbmcasco                            #
#                                                                             #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 21/12/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 24/09/2009 Amilton,Meta               Inclusão da funcao para chamar a tela #
#                                       de vantangens (abstc232)              #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_cty05g04_prep smallint

#-------------------------#
function cty05g04_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select imsvlr ",
                " from abbmcasco ",
               " where succod = ? ",
                 " and aplnumdig = ? ",
                 " and itmnumdig = ? ",
                 " and dctnumseq = ? "

  prepare p_cty05g04_001 from l_sql
  declare c_cty05g04_001 cursor for p_cty05g04_001

  let l_sql = " select imsvlr, imsmda, clcdat "
             ," from  abbmcasco               "
             ," where succod    = ? and       "
             ,"       aplnumdig = ? and       "
             ,"       itmnumdig = ? and       "
             ,"       dctnumseq = ?           "
  prepare p_cty05g04_002 from l_sql
  declare c_cty05g04_002 cursor for p_cty05g04_002
  let m_cty05g04_prep = true

end function

#-----------------------------------------#
function cty05g04_dados_casco(lr_param)
#-----------------------------------------#

  define lr_param      record
         nivel_retorno smallint,
         succod        like abbmcasco.succod,
         aplnumdig     like abbmcasco.aplnumdig,
         itmnumdig     like abbmcasco.itmnumdig
  end record

  define l_res        smallint,
         l_msg        char(50),
         l_imsvlr     like abbmcasco.imsvlr

  let l_res    = 1
  let l_msg    = null
  let l_imsvlr = 0

  if m_cty05g04_prep is null or
     m_cty05g04_prep <> true then
     call cty05g04_prepare()
  end if

  call f_funapol_ultima_situacao(lr_param.succod,
                                  lr_param.aplnumdig,
                                  lr_param.itmnumdig)
       returning g_funapol.*

  open c_cty05g04_001 using lr_param.succod,
                          lr_param.aplnumdig,
                          lr_param.itmnumdig,
                          g_funapol.dctnumseq
  whenever error continue
  fetch c_cty05g04_001 into l_imsvlr
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_res = 2
        let l_msg = "Nao achou dados em abbmcasco"
     else
        let l_res = 3
        let l_msg = "Erro no acesso a abbmcasco ", sqlca.sqlcode
     end if
  end if

  close c_cty05g04_001

  case lr_param.nivel_retorno
       when 1
            return l_res, l_msg, l_imsvlr
  end case

end function

function cty05g04_vantagens()

  define lr_abbmcasco record
         imsvlr    like abbmcasco.imsvlr,
         imsmda    like abbmcasco.imsmda,
         clcdat    like abbmcasco.clcdat
  end record
  define lr_funapol record
     resultado char(01)
    ,dctnumseg decimal(04)
    ,vclsitatu decimal(04)
    ,autsitatu decimal(04)
    ,dmtsitatu decimal(04)
    ,dpssitatu decimal(04)
    ,appsitatu decimal(04)
    ,vidsitatu decimal(04)
  end record
  initialize lr_abbmcasco.* to null
  initialize lr_funapol.* to null
  if m_cty05g04_prep is null or
     m_cty05g04_prep <> true then
     call cty05g04_prepare()
  end if
  call f_funapol_ultima_situacao (g_documento.succod,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig)
       returning lr_funapol.*
  whenever error continue
  open c_cty05g04_002 using g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,lr_funapol.autsitatu
  fetch c_cty05g04_002 into lr_abbmcasco.imsvlr
                         ,lr_abbmcasco.imsmda
                         ,lr_abbmcasco.clcdat
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error "Erro( ",sqlca.sqlcode ," ) no acesso a abbmcasco ! Avise a informatica "
     return
  end if
  # Chama tela de vantagens do sistema do automovel
  call abstc232(g_documento.succod
               ,g_documento.aplnumdig
               ,g_documento.itmnumdig
               ,g_funapol.vclsitatu
               ,lr_abbmcasco.clcdat)



  return


end function
