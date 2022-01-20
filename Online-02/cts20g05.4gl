#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : ATENDIMENTO SEGURADO                                       #
# Modulo        : cts20g05                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 190772                                                     #
#                 Obter o servico JIT.                                       #
#............................................................................#
# Desenvolvimento: Robson Carmo,META                                         #
# Liberacao      : 03/03/2005                                                #
#............................................................................#
#                                                                            #
#                       * * * Alteracoes * * *                               #
#                                                                            #
# Data       Autor Fabrica      Origem     Alteracao                         #
# ---------- -----------------  ---------- ----------------------------------#
#                                                                            #
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_cts20g05_prep smallint

#-------------------------#
function cts20g05_prepare()
#-------------------------#
 define l_sql char(300)

 let l_sql = ' select refatdsrvnum '
                  ,' ,refatdsrvano '
              ,' from datmsrvjit '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare p_cts20g05_001 from l_sql
 declare c_cts20g05_001 cursor for p_cts20g05_001

 let l_sql = ' select 1 '
              ,' from datmsrvjit '
             ,' where refatdsrvnum = ? '
               ,' and refatdsrvano = ? '
 prepare p_cts20g05_002 from l_sql
 declare c_cts20g05_002 cursor for p_cts20g05_002

 let m_cts20g05_prep = true

end function

#--------------------------------------#
function cts20g05_obter_srvjit(lr_param)
#--------------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,atdsrvnum     like datmsrvjit.atdsrvnum
   ,atdsrvano     like datmsrvjit.atdsrvano
 end record

 define lr_retorno1 record
    resultado    smallint
   ,mensagem     char(60)
   ,refatdsrvnum like datmsrvjit.refatdsrvnum
   ,refatdsrvano like datmsrvjit.refatdsrvano
 end record

 define lr_retorno2 record
    resultado smallint
   ,mensagem  char(60)
 end record

 define l_erro char(150)

 if m_cts20g05_prep is null or
    m_cts20g05_prep <> true then
    call cts20g05_prepare()
 end if

 initialize lr_retorno1 to null
 initialize lr_retorno2 to null

 let l_erro = null

 if lr_param.nivel_retorno = 1 then
    open c_cts20g05_001 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano

    whenever error continue
       fetch c_cts20g05_001 into lr_retorno1.refatdsrvnum
                              ,lr_retorno1.refatdsrvano
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno1.resultado = 2
          let lr_retorno1.mensagem = 'Servico JIT-RE nao encontrado'
       else
          let lr_retorno1.resultado = 3
          let lr_retorno1.mensagem = 'Erro '+ sqlca.sqlcode + ' em datmsrvjit'
          let l_erro = 'Erro SELECT c_cts20g05_001 ',sqlca.sqlcode,'|',sqlca.sqlerrd[2]
          call errorlog(l_erro)
          let l_erro = 'cts20g05_obter_srvjit() /', lr_param.atdsrvnum, '/'
                                                  , lr_param.atdsrvano
          call errorlog(l_erro)
       end if
    else
       let lr_retorno1.resultado = 1
    end if
    close c_cts20g05_001

    return lr_retorno1.*

  end if

  if lr_param.nivel_retorno = 2 then
     open c_cts20g05_002 using lr_param.atdsrvnum
                            ,lr_param.atdsrvano

     whenever error continue
        fetch c_cts20g05_002
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_retorno2.resultado = 2
           let lr_retorno2.mensagem = 'Servico JIT-RE nao encontrado'
        else
           let lr_retorno2.resultado = 3
           let lr_retorno2.mensagem = 'Erro '+ sqlca.sqlcode + ' em datmsrvjit'
           let l_erro = 'Erro SELECT c_cts20g05_002 ',sqlca.sqlcode,'|',sqlca.sqlerrd[2]
           call errorlog(l_erro)
           let l_erro = 'cts20g05_obter_srvjit() /', lr_param.atdsrvnum, '/'
                                                   , lr_param.atdsrvano
           call errorlog(l_erro)
        end if
     else
        let lr_retorno2.resultado = 1
     end if
     close c_cts20g05_002

     return lr_retorno2.*

  end if

end function
