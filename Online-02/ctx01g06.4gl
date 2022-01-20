#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : ctx01g06                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 187887                                                     #
#                 Liberar o beneficio de concessao do carro extra.           #
#                 Este metodo reverte o motivo da locacao e desmarca a       #
#                 solicitacao.                                               #
#                 Excluir o beneficio do carro extra.                        #
#............................................................................#
# Desenvolvimento: Carlos, META                                              #
# Liberacao      : 30/12/2004                                                #
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
function ctx01g06_prepare()
#--------------------------#
 define l_sql char(250)

 let l_sql = ' update datmavisrent set avialgmtv    = ? '
                                   ,' ,aviprvent    = ? '
                                   ,' ,lcvsinavsflg = ? '
                              ,' where atdsrvnum = ? '
                                ,' and atdsrvano = ? '
 prepare p_ctx01g06_001 from l_sql

 let l_sql = ' update datmavisrent set lcvsinavsflg = ? '
                              ,' where atdsrvnum = ? '
                                ,' and atdsrvano = ? '
 prepare p_ctx01g06_002 from l_sql

 let m_prep = true

end function

#----------------------------------#
function ctx01g06_liberar(lr_param)
#----------------------------------#
 define lr_param record
    atdsrvnum      like datmavisrent.atdsrvnum
   ,atdsrvano      like datmavisrent.atdsrvano
   ,motivo         like datmavisrent.avialgmtv
   ,aviprvent      like datmavisrent.aviprvent
   ,lcvsinavsflg   like datmavisrent.lcvsinavsflg
 end record

 define lr_ret record
    resultado   smallint
   ,mensagem    char(100)
 end record

 define l_erro   char(80)

 initialize lr_ret to null
 let lr_ret.resultado = 2
 let l_erro = null

 if (lr_param.atdsrvnum    is null or
     lr_param.atdsrvnum    = ' ')  or
    (lr_param.atdsrvano    is null or
     lr_param.atdsrvano    = ' ')  or
    (lr_param.motivo       is null or
     lr_param.motivo       = ' ')  or
    (lr_param.lcvsinavsflg is null or
     lr_param.lcvsinavsflg = ' ')  then

    let lr_ret.mensagem = 'Parametros nulos - ctx01g06_liberar()'
    call errorlog(lr_ret.mensagem)
    return lr_ret.*
 end if

 if m_prep is null or
    m_prep <> true then
    call ctx01g06_prepare()
 end if

 whenever error continue
    execute p_ctx01g06_001 using lr_param.motivo
                                ,lr_param.aviprvent
                              ,lr_param.lcvsinavsflg
                              ,lr_param.atdsrvnum
                              ,lr_param.atdsrvano
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_ret.mensagem = 'Erro ', sqlca.sqlcode, ' na liberacao do beneficio'

    let l_erro = 'Erro UPDATE pctx01g06001: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
    call errorlog(l_erro)
    let l_erro = 'ctx01g06_liberar ',lr_param.motivo,'/'
                                    ,lr_param.lcvsinavsflg,'/'
                                    ,lr_param.atdsrvnum,'/'
                                    ,lr_param.atdsrvano
    call errorlog(l_erro)

 else
    let lr_ret.resultado = 1
 end if

 return lr_ret.*

end function

#---------------------------------#
function ctx01g06_excluir(lr_param)
#---------------------------------#
 define lr_param record
    atdsrvnum      like datmavisrent.atdsrvnum
   ,atdsrvano      like datmavisrent.atdsrvano
   ,lcvsinavsflg   like datmavisrent.lcvsinavsflg
 end record

 define lr_ret record
    resultado   smallint
   ,mensagem    char(100)
 end record

 define l_erro   char(80)

 initialize lr_ret to null
 let lr_ret.resultado = 2

 if (lr_param.atdsrvnum    is null or
     lr_param.atdsrvnum    = ' ')  or
    (lr_param.atdsrvano    is null or
     lr_param.atdsrvano    = ' ')  or
    (lr_param.lcvsinavsflg is null or
     lr_param.lcvsinavsflg = ' ')  then

    let lr_ret.mensagem = 'Parametros nulos - ctx01g06_excluir()'
    call errorlog(lr_ret.mensagem)
    return lr_ret.*
 end if

 if m_prep is null or
    m_prep <> true then
    call ctx01g06_prepare()
 end if

 whenever error continue
    execute p_ctx01g06_002 using lr_param.lcvsinavsflg
                              ,lr_param.atdsrvnum
                              ,lr_param.atdsrvano
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_ret.mensagem = 'Erro ', sqlca.sqlcode, ' na exclusao do beneficio'

    let l_erro = 'Erro UPDATE pctx01g06002: ' , sqlca.sqlcode, '/',sqlca.sqlerrd[2]
    call errorlog(l_erro)
    let l_erro = 'ctx01g06_excluir ',lr_param.lcvsinavsflg,'/'
                                    ,lr_param.atdsrvnum,'/'
                                    ,lr_param.atdsrvano
    call errorlog(l_erro)
 else
    let lr_ret.resultado = 1
 end if

 return lr_ret.*

end function

