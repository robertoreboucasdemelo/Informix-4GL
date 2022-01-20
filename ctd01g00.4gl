#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd01g00                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: 205206                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DATRCIDSED           #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 16/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/03/2010 Adriano Santos  PSI 252891 Retorno 3 ctd01g00_obter_cidsedcod    #
#-----------------------------------------------------------------------------#

database porto

  define m_prep_obter_cidsed    smallint
  define m_prep_verifica_cidsed smallint

#-------------------------#
function ctd01g00_prep_obter_cidsedcod()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select cidsedcod, atnflg, brrtipflg ",
                " from datrcidsed ",
               " where cidcod = ? "
  prepare pctd01g00001 from l_sql
  declare cctd01g00001 cursor for pctd01g00001

  let m_prep_obter_cidsed = true

end function

#Objetivo: obter a cidade sede de uma cidade
#-----------------------------------------#
function ctd01g00_obter_cidsedcod(param)
#-----------------------------------------#
  define param record
         tp_retorno smallint,
         cidcod like datrcidsed.cidcod
  end record

  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100) 

  define lr_dados   record
         cidsedcod    like datrcidsed.cidsedcod,
         atnflg       like datrcidsed.atnflg,
         brrtipflg    like datrcidsed.brrtipflg
  end record

  define l_msg        char(100)

  if m_prep_obter_cidsed is null or
     m_prep_obter_cidsed <> true then
     call ctd01g00_prep_obter_cidsedcod()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_retorno = 0
  let l_mensagem = null
  initialize lr_dados to null
  let l_msg = null

  open cctd01g00001 using param.cidcod

  whenever error continue
  fetch cctd01g00001 into lr_dados.cidsedcod,
                          lr_dados.atnflg,
                          lr_dados.brrtipflg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     initialize lr_dados to null
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou o codigo da cidade sede."
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd01g00001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]

        call errorlog(l_mensagem)

        let l_msg = "ctd01g00/ctd01g00_obter_cidsedcod() / ",
                     param.cidcod

        call errorlog(l_msg)
     end if
  else
     let l_retorno = 1
     let l_mensagem  = null
  end if

  close cctd01g00001

  case param.tp_retorno
      when 1
          return l_retorno,
                 l_mensagem,
                 lr_dados.cidsedcod
      when 2
          return l_retorno,
                 l_mensagem,
                 lr_dados.cidsedcod,
                 lr_dados.atnflg
      when 3
          return l_retorno,
                 l_mensagem,
                 lr_dados.cidsedcod,
                 lr_dados.brrtipflg
      
  end case

end function


#-------------------------#
function ctd01g00_prep_verifica_cidsed()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select  1 ",
                " from datrcidsed ",
               " where cidsedcod = ? "
  prepare pctd01g00002 from l_sql
  declare cctd01g00002 cursor for pctd01g00002

  let m_prep_verifica_cidsed = true

end function

#Objetivo: verifica se cidade e cidade sede
#-----------------------------------------#
function ctd01g00_verifica_cidsed(param)
#-----------------------------------------#

  define param record
         tp_retorno smallint,
         cidsedcod like datrcidsed.cidsedcod
  end record

  define l_retorno    smallint  # (1) = Ok (2) = Not Found (3) = Erro de acesso
  define l_mensagem   char(100)

  define l_msg        char(100)

  if m_prep_verifica_cidsed is null or
     m_prep_verifica_cidsed <> true then
     call ctd01g00_prep_verifica_cidsed()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_retorno = 0
  let l_mensagem = null
  let l_msg = null

  open cctd01g00002 using param.cidsedcod

  whenever error continue
  fetch cctd01g00002
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou o codigo como cidade sede."
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd01g00002 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]

        call errorlog(l_mensagem)

        let l_msg = "ctd01g00/ctd01g00_verifica_cidsed() / ",
                     param.cidsedcod

        call errorlog(l_msg)
     end if
  else
     let l_retorno = 1
     let l_mensagem  = null
  end if

  close cctd01g00002

  if param.tp_retorno = 1 then
     return l_retorno,
            l_mensagem
  end if

end function

