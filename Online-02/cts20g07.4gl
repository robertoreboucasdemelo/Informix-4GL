#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : ATENDIMENTO SEGURADO                                       #
# Modulo        : cts20g07                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 190772                                                     #
#                 Obter informacoes do cancelamento                          #
#............................................................................#
# Desenvolvimento: Robson Carmo,META                                         #
# Liberacao      : 03/03/2005                                                #
#............................................................................#
#                       * * * Alteracoes * * *                               #
#                                                                            #
# Data       Autor Fabrica      Origem     Alteracao                         #
# ---------- -----------------  ---------- ----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_cts20g07_prep smallint

#-------------------------#
function cts20g07_prepare()
#-------------------------#

 define l_sql char(300)

 let l_sql = ' select canmtvdes '
              ,' from datmvstsincanc '
             ,' where sinvstnum = ? '
               ,' and sinvstano = ? '
 prepare p_cts20g07_001 from l_sql
 declare c_cts20g07_001 cursor for p_cts20g07_001

 let m_cts20g07_prep = true

end function

#-------------------------------------#
function cts20g07_canc_vstsin(lr_param)
#-------------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,sinvstnum     like datmvstsincanc.sinvstnum
   ,sinvstano     like datmvstsincanc.sinvstano
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,canmtvdes like datmvstsincanc.canmtvdes
 end record

 define l_erro char(150)

 if m_cts20g07_prep is null or
    m_cts20g07_prep <> true then
    call cts20g07_prepare()
 end if

 initialize lr_retorno to null
 let l_erro = null

 if lr_param.nivel_retorno = 1 then
    open c_cts20g07_001 using lr_param.sinvstnum
                           ,lr_param.sinvstano

    whenever error continue
       fetch c_cts20g07_001 into lr_retorno.canmtvdes
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem = 'Cancelamento da vistoria nao encontrada'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem = 'Erro '+ sqlca.sqlcode + ' em datmvstsincanc'
          let l_erro = 'Erro SELECT c_cts20g07_001 ',sqlca.sqlcode,'|',sqlca.sqlerrd[2]
          call errorlog(l_erro)
          let l_erro = 'cts20g07_obter_srvjit() /', lr_param.sinvstnum, '/'
                                                  , lr_param.sinvstano
          call errorlog(l_erro)
       end if
    else
       let lr_retorno.resultado = 1
    end if
    close c_cts20g07_001

    return lr_retorno.*

 end if

end function
