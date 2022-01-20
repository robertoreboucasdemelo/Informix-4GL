#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts20g13                                                   #
# Analista Resp.: Carlos Ruiz                                                #
# PSI           : 202720                                                     #
#                 Obter os dados da tabela darservapol                       #
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

   define m_cts20g13_prep smallint

#----------------------------------------------------------------------------
function cts20g13_prepare()
#----------------------------------------------------------------------------
  define l_sql char(400)

  let l_sql = " select aplnumdig, ",
                     " succod, ",
                     " ramcod, ",
                     " itmnumdig ",
                " from datrservapol ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
  prepare pcts20g13001 from l_sql
  declare ccts20g13001 cursor for pcts20g13001
  
  let m_cts20g13_prep = true
  
end function




#-------------------------------------------#
function cts20g13_obter_apolice(lr_parametro)
#-------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datrservapol.atdsrvnum,
         atdsrvano    like datrservapol.atdsrvano
  end record

  define l_aplnumdig  like datrservapol.aplnumdig,
         l_succod     like datrservapol.succod,
         l_ramcod     like datrservapol.ramcod,
         l_itmnumdig  like datrservapol.itmnumdig,
         l_resultado  smallint,
         l_mensagem   char(80),
         l_msg_erro   char(100)

  if m_cts20g13_prep is null or
     m_cts20g13_prep <> true then
     call cts20g13_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_aplnumdig = null
  let l_succod    = null
  let l_ramcod    = null
  let l_itmnumdig = null
  let l_resultado = 0
  let l_mensagem  = null
  let l_msg_erro  = null

  open ccts20g13001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  whenever error continue
  fetch ccts20g13001 into l_aplnumdig,
                          l_succod,
                          l_ramcod,
                          l_itmnumdig
  whenever error stop

  if sqlca.sqlcode = 0 then
     let l_resultado = 1
  else
     if sqlca.sqlcode = notfound then
        #caso nao encontre registro
        let l_resultado = 2
        let l_mensagem = "Nao encontrada apolice para o servico"
     else
        let l_resultado = 3
        let l_mensagem = "Erro SELECT ccts20g13001 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_mensagem)
        let l_msg_erro = "cts20g13/cts20g13_obter_apolice() / ",
                         lr_parametro.atdsrvnum, "/", lr_parametro.atdsrvano
        call errorlog(l_msg_erro)
     end if
  end if

  close ccts20g13001

  return l_resultado,
         l_mensagem,
         l_aplnumdig,
         l_succod,
         l_ramcod,
         l_itmnumdig

end function

