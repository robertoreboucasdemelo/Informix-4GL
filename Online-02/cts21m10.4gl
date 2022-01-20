#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Vistoria Sinistro RE                                       #
# Modulo        : cts21m10                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 183431                                                     #
# OSF           : 036439                                                     #
#                 Obter informacoes da vistoria de sinistro RE.              #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 17/06/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql smallint

#--------------------------#
function cts21m10_prepare()
#--------------------------#
 define l_sql char(200)

 let l_sql = ' select 1 '
              ,' from datmpedvist '
             ,' where sinvstnum = ? '
               ,' and sinvstano = ? '

 prepare p_cts21m10_001 from l_sql
 declare c_cts21m10_001 cursor for p_cts21m10_001

 let m_prep_sql = true
end function

#----------------------------------------------------------#
function cts21m10_valida_vistoria(l_sinvstnum, l_sinvstano)
#----------------------------------------------------------#

 define l_sinvstnum like datmpedvist.sinvstnum
       ,l_sinvstano like datmpedvist.sinvstano
       ,l_erro      char(80)
 define lr_retorno  record
        resultado   smallint
       ,mensagem    char(40)
 end record

 initialize lr_retorno.* to null

 if l_sinvstnum is null or
    l_sinvstano is null then
    let lr_retorno.mensagem = 'Sinistro nao deve ser nulo'
    let lr_retorno.resultado = 3
    return lr_retorno.*
 end if
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts21m10_prepare()
 end if

 open c_cts21m10_001 using l_sinvstnum
                        ,l_sinvstano
 whenever error continue
 fetch c_cts21m10_001
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.mensagem = 'Vistoria Sinistro RE nao cadastrada'
       let lr_retorno.resultado = 2
    else
       let l_erro = ' Erro no SELECT c_cts21m10_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(l_erro)
       let l_erro = ' Funcao cts21m10_valida_vistoria() ', l_sinvstnum, '/', l_sinvstano
       call errorlog(l_erro)
       let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode,' na consulta datmpedvist'
       let lr_retorno.resultado = 3
    end if
 else
    let lr_retorno.resultado = 1
 end if

 return lr_retorno.*

end function
