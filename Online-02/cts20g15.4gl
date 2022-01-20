#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts20g15                                                   #
# Analista Resp.: Carlos Ruiz                                                #
# PSI           : 202720                                                     #
#                 Obter ultima etapa do servico                              #
#............................................................................#
# Desenvolvimento: Priscila Staingel                                         #
# Liberacao      : 29/09/2006                                                #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#----------------------------------------------------------------------------#
 database porto

   define m_cts20g15_prep smallint

#----------------------------------------------------------------------------
 function cts20g15_prepare()
#----------------------------------------------------------------------------
  define l_sql char(400)
  
  let l_sql = " select atdetpcod ",
               " from datmsrvacp ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? ",
               " and atdsrvseq = (select max(atdsrvseq) ",
                                 " from datmsrvacp ",
                                 " where atdsrvnum = ? ",
                                 " and atdsrvano = ?) "

  prepare pcts20g15001 from l_sql
  declare ccts20g15001 cursor for pcts20g15001

end function

#---------------------------------------------#
function cts20g15_obter_ult_etapa(lr_parametro)
#---------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano
  end record

  define l_atdetpcod  like datmsrvacp.atdsrvseq,
         l_resultado  smallint,
         l_mensagem   char(80),
         l_msg_erro   char(100)

  if m_cts20g15_prep is null or
     m_cts20g15_prep <> true then
     call cts20g15_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_atdetpcod = null
  let l_resultado = 0
  let l_mensagem  = null
  let l_msg_erro  = null

  open ccts20g15001 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano

  whenever error continue
  fetch ccts20g15001 into l_atdetpcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_resultado = 1
        let l_mensagem  = "Nao encontrou a ultima etapa do servico: ", lr_parametro.atdsrvnum, "-",
                                                                       lr_parametro.atdsrvano
        call errorlog(l_mensagem)
     else
        let l_resultado = 2
        let l_mensagem = "Erro SELECT ccts20g15002 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_mensagem)
        let l_msg_erro = "cts20g15/cts20g15_obter_ult_etapa() / ",
                         lr_parametro.atdsrvnum, "/", lr_parametro.atdsrvano
        call errorlog(l_msg_erro)
     end if
  end if

  close ccts20g15001

  return l_resultado,
         l_mensagem,
         l_atdetpcod

end function
