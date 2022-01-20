#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G01                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MODULO RESPONSA. PELO BUSCA DO CODIGO DA NATUREZA E O CO-  #
#                  DIGO DA ESPECIALIDADE DA TABELA DATMSRVRE.                 #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 03/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g01_prep smallint

#-------------------------#
function cts40g01_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select socntzcod, ",
                     " espcod ",
                " from datmsrvre ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g01_001 from l_sql
  declare c_cts40g01_001 cursor for p_cts40g01_001

  let m_cts40g01_prep = true

end function

#-------------------------------------------------#
function cts40g01_obter_codnat_codesp(lr_parametro)
#-------------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvre.atdsrvnum,
         atdsrvano    like datmsrvre.atdsrvano
  end record

  define lr_retorno   record
         resultado    smallint,  # (0) = Ok   (1) = Not Found   (2) = Erro de acesso
         mensagem     char(100),
         socntzcod    like datmsrvre.socntzcod,
         espcod       like datmsrvre.espcod
  end record

  define l_msg        char(100)

  if m_cts40g01_prep is null or
     m_cts40g01_prep <> true then
     call cts40g01_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno to null

  let l_msg = null

  open c_cts40g01_001 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano

  whenever error continue
  fetch c_cts40g01_001 into lr_retorno.socntzcod,
                          lr_retorno.espcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     initialize lr_retorno to null
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "Nao encontrou o codigo da natureza e codigo da especialidade."
     else
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Erro SELECT c_cts40g01_001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]

        call errorlog(lr_retorno.mensagem)

        let l_msg = "CTS40G01/cts40g01_obter_codnat_codesp() / ",
                     lr_parametro.atdsrvnum, "/",
                     lr_parametro.atdsrvano

        call errorlog(l_msg)
     end if
  else
     let lr_retorno.resultado = 0
     let lr_retorno.mensagem  = null
  end if

  close c_cts40g01_001

  return lr_retorno.resultado,
         lr_retorno.mensagem,
         lr_retorno.socntzcod,
         lr_retorno.espcod

end function
