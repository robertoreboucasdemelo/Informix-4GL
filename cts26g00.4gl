#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cts26g00                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI186406                                                  #
#                 Obter o serviço original.                                  #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 01/09/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 06/04/2005 Ronaldo, Meta     PSI189790  Criar funcao para obter natureza do#
#                                         servico de RE.                     #
# 08/11/2005 Ligia Mattge      PSI195138  Obter o espcod                     #
#----------------------------------------------------------------------------#
# 06/06/2008 Carla Rampazzo    Nao mostrar error/display qdo chamada for     #
#                              pelo Portal do Segurado                       #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prep smallint

#--------------------------#
function cts26g00_prepare()
#--------------------------#
 define l_sql char(200)

 let l_sql = 'select atdorgsrvnum '
                 ,' ,atdorgsrvano '
                 ,' ,socntzcod '
                 ,' ,espcod    ' #psi 195138
             ,' from datmsrvre '
            ,' where atdsrvnum = ? '
              ,' and atdsrvano = ? '
 prepare p_cts26g00_001 from l_sql
 declare c_cts26g00_001 cursor for p_cts26g00_001

 let m_prep = true
end function

#--------------------------#
function cts26g00(lr_param)
#--------------------------#
 define lr_param record
    atdsrvnum  like datmsrvre.atdsrvnum
   ,atdsrvano  like datmsrvre.atdsrvano
 end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(100)
   ,atdorgsrvnum like datmsrvre.atdorgsrvnum
   ,atdorgsrvano like datmsrvre.atdorgsrvano
 end record

 define l_socntzcod smallint

 let l_socntzcod = 0
 initialize lr_retorno to null

 if m_prep is null or
    m_prep <> true then
    call cts26g00_prepare()
 end if

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null then
    open c_cts26g00_001 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
    whenever error continue
       fetch c_cts26g00_001 into lr_retorno.atdorgsrvnum
                              ,lr_retorno.atdorgsrvano
                              ,l_socntzcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Servico de sinistro RE nao encontrado'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datmsrvre'
          error ' Erro no SELECT c_cts26g00_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error ' Funcao cts26g00() ', lr_param.atdsrvnum, '/'
                                     , lr_param.atdsrvano sleep 2
       end if
    else
       let lr_retorno.resultado = 1
    end if
    close c_cts26g00_001
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos - cts26g00()'
 end if

 return lr_retorno.*

end function

#----------------------------------------#
function cts26g00_obter_natureza(lr_param)
#----------------------------------------#
 define lr_param record
        atdsrvnum  like datmsrvre.atdsrvnum,
        atdsrvano  like datmsrvre.atdsrvano
 end record

 define lr_retorno   record
        resultado    smallint,
        mensagem     char(100),
        socntzcod    like datmsrvre.socntzcod,
        espcod       like datmsrvre.espcod
 end record

 define lr_armz      record
        atdorgsrvnum like datmsrvre.atdorgsrvnum,
        atdorgsrvano like datmsrvre.atdorgsrvano
 end record

 initialize lr_armz to null
 initialize lr_retorno to null

 if m_prep is null or
    m_prep <> true then
    call cts26g00_prepare()
 end if

 let lr_retorno.resultado = 1
 let lr_retorno.mensagem  = ''

 if lr_param.atdsrvnum is null or lr_param.atdsrvano is null then
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos - cts26g00_obter_natureza()'
    return lr_retorno.*
 end if

 open c_cts26g00_001 using lr_param.atdsrvnum,
                         lr_param.atdsrvano
 whenever error continue
 fetch c_cts26g00_001 into lr_armz.atdorgsrvnum,
                         lr_armz.atdorgsrvano,
                         lr_retorno.socntzcod,
                         lr_retorno.espcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Natureza do servico nao encontrada'
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datmsrvre'

       ---> Mostra mensagem de error so se a chamada for pelo Informix
       if g_origem is null or
	  g_origem = "IFX" then
          error 'cts26g00 / cts26g00_obter_natureza() Erro no SELECT '
               ,'ccts26g00002 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error 'cts26g00 / Funcao cts26g00() ',
                'atdsrvnum = ', lr_param.atdsrvnum, ' / ',
                'atdsrvano = ', lr_param.atdsrvano sleep 2
       end if
    end if
 end if
 close c_cts26g00_001

 return lr_retorno.*

end function


