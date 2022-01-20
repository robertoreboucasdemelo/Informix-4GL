#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cts20g02                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI186406                                                  #
#                 Obter informacoes da ligacao.                              #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 01/09/2004                                                #
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
function cts20g02_prepare()
#--------------------------#
 define l_sql char(200)

 let l_sql = ' select c24astcod '
              ,' from datmligacao '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
               ,' and c24astcod = ? '

 prepare p_cts20g02_001 from l_sql
 declare c_cts20g02_001 cursor for p_cts20g02_001

 let m_prep = true
end function

#--------------------------#
function cts20g02(lr_param)
#--------------------------#
 define lr_param record
    atdsrvnum  like datmligacao.atdsrvnum
   ,atdsrvano  like datmligacao.atdsrvano
   ,c24astcod  like datmligacao.c24astcod
 end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(60)
   ,c24astcod    like datmligacao.c24astcod
 end record

 initialize lr_retorno to null

 if m_prep is null or
    m_prep <> true then
    call cts20g02_prepare()
 end if

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null then
    open c_cts20g02_001 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
                           ,lr_param.c24astcod
    whenever error continue
       fetch c_cts20g02_001 into lr_retorno.c24astcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Ligacao nao encontrada'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datmligacao'
          error ' Erro no SELECT c_cts20g02_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error ' Funcao cts20g02() ', lr_param.atdsrvnum, '/'
                                     , lr_param.atdsrvano sleep 2
       end if
    else
       let lr_retorno.resultado = 1
    end if
    close c_cts20g02_001
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if

 return lr_retorno.*

end function

