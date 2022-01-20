#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Vistoria de Sinistro                                       #
# Modulo        : cts14m06                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 183431                                                     #
# OSF           : 036439                                                     #
#                 Obter informacoes da vistoria de sinistro.                 #
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
function cts14m06_prepare()
#--------------------------#
 define l_sql char(400)

 let l_sql = ' select succod '
                  ,' ,ramcod '
                  ,' ,aplnumdig '
                  ,' ,itmnumdig '
                  ,' ,prporg '
                  ,' ,prpnumdig '
              ,' from datmvstsin '
             ,' where sinvstnum = ? '
               ,' and sinvstano = ? '

 prepare p_cts14m06_001 from l_sql
 declare c_cts14m06_001 cursor for p_cts14m06_001

 let m_prep_sql = true

end function

#----------------------------------------------------#
function cts14m06_documento(l_sinvstnum, l_sinvstano)
#----------------------------------------------------#

 define l_sinvstnum like datmvstsin.sinvstnum
       ,l_sinvstano like datmvstsin.sinvstano
       ,l_erro      char(80)

 define lr_retorno  record
        resultado   smallint
       ,mensagem    char(40)
       ,succod      like datmvstsin.succod
       ,ramcod      like datmvstsin.ramcod
       ,aplnumdig   like datmvstsin.aplnumdig
       ,itmnumdig   like datmvstsin.itmnumdig
       ,prporg      like datmvstsin.prporg
       ,prpnumdig   like datmvstsin.prpnumdig
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
    call cts14m06_prepare()
 end if

 open c_cts14m06_001 using l_sinvstnum
                        ,l_sinvstano

 whenever error continue
 fetch c_cts14m06_001 into lr_retorno.succod
                        ,lr_retorno.ramcod
                        ,lr_retorno.aplnumdig
                        ,lr_retorno.itmnumdig
                        ,lr_retorno.prporg
                        ,lr_retorno.prpnumdig
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.mensagem = 'Sinistro nao encontrado'
       let lr_retorno.resultado = 2
    else
       let l_erro = ' Erro no SELECT c_cts14m06_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(l_erro)
       let l_erro = ' Funcao cts14m06_documento() ', l_sinvstnum, '/', l_sinvstano
       call errorlog(l_erro)
       let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' na consulta datmvstsin'
       let lr_retorno.resultado = 3
    end if
 else
    let lr_retorno.resultado = 1
 end if

 return lr_retorno.*

end function
