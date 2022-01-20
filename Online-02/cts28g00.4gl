#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Ct24h                                               #
# Modulo        : cts28g00                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI           : 187887                                              #
# Objetivo      : Obter relacionamento entre servico X apolice        #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 21/12/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 15/02/2006  Andrei, Meta   PSI196878 Criar consistencia para niveis #
#                                      de retorno 1 e 2               #
#---------------------------------------------------------------------#

database porto

define m_prepare              smallint

#---------------------------#
function cts28g00_prepare()
#---------------------------#
define l_comando          char(600)


  let l_comando = " select succod,aplnumdig, itmnumdig, "
                 ,"        ramcod, edsnumref "
                 ,"   from datrservapol  "
                 ,"  where atdsrvnum = ? "
                 ,"    and atdsrvano = ? "

  prepare p_cts28g00_001 from l_comando
  declare c_cts28g00_001 cursor for p_cts28g00_001
  let m_prepare = true
end function

#------------------------------------#
function cts28g00_apol_serv(lr_param)
#------------------------------------#

define lr_param record
                nvlretorno smallint
               ,atdsrvnum  like datrservapol.atdsrvnum
               ,atdsrvano  like datrservapol.atdsrvano
            end record
#define l_atdsrvnum         like datrservapol.atdsrvnum
#      ,l_atdsrvano         like datrservapol.atdsrvano
define lr_retorno          record
       resultado           smallint
      ,mensagem            char(80)
      ,succod              like datrservapol.succod
      ,aplnumdig           like datrservapol.aplnumdig
      ,itmnumdig           like datrservapol.itmnumdig
      ,ramcod              like datrservapol.ramcod
      ,edsnumref           like datrservapol.edsnumref
                           end record
    initialize lr_retorno.* to null

    if lr_param.atdsrvnum  is null or
       lr_param.atdsrvano  is null or
       lr_param.nvlretorno is null then
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem  = "Parametros Incorretos! - cts28g00_apol_serv()"
       return lr_retorno.*
    end if

    if m_prepare is null or
       m_prepare <> true then
       call cts28g00_prepare()
    end if
    let lr_retorno.resultado = 1
    if lr_param.nvlretorno = 1 or
       lr_param.nvlretorno = 2 then
       open c_cts28g00_001 using lr_param.atdsrvnum
                              ,lr_param.atdsrvano
       whenever error continue
       fetch c_cts28g00_001 into lr_retorno.succod
                              ,lr_retorno.aplnumdig
                              ,lr_retorno.itmnumdig
                              ,lr_retorno.ramcod
                              ,lr_retorno.edsnumref
       whenever error stop
       if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = 'Apolice Nao Encontrada'
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                     ,' em datservapol - cts28g00_apol_serv'
         end if
       end if
       if lr_param.nvlretorno = 1 then
          return lr_retorno.resultado
                ,lr_retorno.mensagem
                ,lr_retorno.ramcod
                ,lr_retorno.succod
                ,lr_retorno.aplnumdig
                ,lr_retorno.itmnumdig
       else
          if lr_param.nvlretorno = 2 then
             return lr_retorno.resultado
                   ,lr_retorno.mensagem
                   ,lr_retorno.succod
                   ,lr_retorno.aplnumdig
                   ,lr_retorno.itmnumdig
                   ,lr_retorno.edsnumref
          end if
       end if
    end if
#    if sqlca.sqlcode <> 0 then
#       if sqlca.sqlcode < 0 then
#          let lr_retorno.resultado = 3
#          let lr_retorno.mensagem = "Erro: ", sqlca.sqlcode, '/'
#                                   ,sqlca.sqlerrd[2], " em datservapol - cts28g00_apol_serv"
#       else
#          let lr_retorno.resultado = 2
#          let lr_retorno.mensagem  = "Apolice Nao Encontrada "
#       end if
#    else
#       let lr_retorno.resultado = 1
#    end if
#
#    return lr_retorno.*

end function


