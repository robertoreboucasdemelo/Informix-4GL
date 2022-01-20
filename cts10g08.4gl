#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cts10g08                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI187550                                                  #
#                 Consistir o servico removido pelo sistema                  #
#............................................................................#
# Desenvolvimento: Carlos, META                                              #
# Liberacao      : 10/09/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep smallint

#--------------------------#
function cts10g08_prepare()
#--------------------------#
 define l_sql char(200)

 let l_sql = ' select 1 '
              ,' from datmlimpeza '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare p_cts10g08_001 from l_sql
 declare c_cts10g08_001 cursor for p_cts10g08_001

 let m_prep = true
end function

#----------------------------------#
function cts10g08_servico(lr_param)
#----------------------------------#
 define lr_param    record
        atdsrvnum   like datmlimpeza.atdsrvnum,
        atdsrvano   like datmlimpeza.atdsrvano
 end record

 define lr_retorno  record
        resultado   smallint,
        mensagem    char(60)
 end record
 define l_erro char(100)

 initialize lr_retorno.*  to null

 let l_erro = null

 if m_prep is null or
    m_prep <> true then
    call cts10g08_prepare()
 end if

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null then
    open c_cts10g08_001 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
    whenever error continue
       fetch c_cts10g08_001
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Servico nao encontrado'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datmlimpeza'
          let l_erro = ' Erro no SELECT c_cts10g08_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(l_erro)
          let l_erro = ' Funcao cts10g08_servico() ',lr_param.atdsrvnum, '/'
                                                    ,lr_param.atdsrvano
          call errorlog(l_erro)
       end if
    else
       let lr_retorno.resultado = 1
       let lr_retorno.mensagem  = 'Servico ja foi removido pelo sistema!'
    end if
    close c_cts10g08_001
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if

 return lr_retorno.*

end function

