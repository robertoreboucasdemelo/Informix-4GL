#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: WDATC004                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 196878 - ACIONAMENTO DOS SERVICOS DE ASSISTENCIA A         #
#                           PASSAGEIROS E CARRO EXTRA VIA INTERNET.           #
#                  OBTER O NOME DA LOCADORA OU LOJA P/SER UTILIZADO NO PORTAL #
#                  DE NEGOCIOS.                                               #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 20/03/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_wdatc004_prep smallint

#-------------------------#
function wdatc004_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select lcvnom ",
                " from datklocadora ",
               " where lcvcod = ? "

  prepare pwdatc004001 from l_sql
  declare cwdatc004001 cursor for pwdatc004001

  let l_sql = " select aviestnom ",
                " from datkavislocal ",
               " where aviestcod = ? "

  prepare pwdatc004002 from l_sql
  declare cwdatc004002 cursor for pwdatc004002

  let m_wdatc004_prep = true

end function

#------------------------------#
function wdatc004(l_sissgl, l_cod_loc_loj)
#------------------------------#

  define l_cod_loc_loj smallint, # --> CODIGO DA LOCADORA OU LOJA
         l_nom_loc_loj char(40), # --> NOME DA LOCADORA OU LOJA
         l_sissgl      char(40)  # --> NOME DO SISTEMA

  initialize  m_wdatc004_prep to null
  initialize  l_nom_loc_loj   to null

  if m_wdatc004_prep is null or
     m_wdatc004_prep <> true then
     call wdatc004_prepare()
  end if

  # --> BUSCA O NOME DA LOCADORA

  if l_sissgl = 'LCVONLINE' then
     open cwdatc004001 using l_cod_loc_loj
     fetch cwdatc004001 into l_nom_loc_loj
     close cwdatc004001
  else
     open cwdatc004002 using l_cod_loc_loj
     fetch cwdatc004002 into l_nom_loc_loj
     close cwdatc004002
  end if


  return l_nom_loc_loj

end function
