#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cts15g02                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI186406                                                  #
#                 Obter sigla do veiculo                                     #
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
function cts15g02_prepare()
#--------------------------#
 define l_sql char(200)
 let l_sql = ' select atdvclsgl '
              ,' from datkveiculo '
             ,' where socvclcod = ? '
 prepare pcts15g02001 from l_sql
 declare ccts15g02001 cursor for pcts15g02001

 let m_prep = true
end function

#------------------------------------#
function cts15g02_atdvclsgl(lr_param)
#------------------------------------#
 define lr_param record
    socvclcod  like datkveiculo.socvclcod
 end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(60)
   ,atdvclsgl    like datkveiculo.atdvclsgl
 end record
 initialize lr_retorno to null
 if m_prep is null or
    m_prep <> true then
    call cts15g02_prepare()
 end if
 if lr_param.socvclcod is not null then
    open ccts15g02001 using lr_param.socvclcod
    whenever error continue
       fetch ccts15g02001 into lr_retorno.atdvclsgl
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Sigla do Veiculo nao encontrado'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datkveiculo'
          error ' Erro no SELECT ccts15g02001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error ' Funcao cts15g02_atdvclsgl() ', lr_param.socvclcod sleep 2
       end if
    else
       let lr_retorno.resultado = 1
    end if
    close ccts15g02001
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if
 return lr_retorno.*
end function

