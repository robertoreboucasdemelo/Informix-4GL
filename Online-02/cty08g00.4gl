#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty08g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter informacoes do funcionario                           #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 19/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 18/11/2010 Robert Lima       CT 02086   Alterado o errorlog para display   #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql   smallint

#---------------------------#
 function cty08g00_prepare()
#---------------------------#

  define l_sql        char(200)
  let l_sql = "select funnom from isskfunc ",
              " where empcod = ? ",
              "   and funmat = ? ",
              "   and usrtip = ? "
  prepare pcty08g00001  from l_sql
  declare ccty08g00001  cursor for pcty08g00001

  let l_sql = "select acsnivcod from issmnivnovo ",
              " where usrtip = ? ",
              "   and empcod = ? ",
              "   and usrcod = ? ",
              "   and sissgl = ? "
  prepare pcty08g00002  from l_sql
  declare ccty08g00002  cursor for pcty08g00002

  let l_sql = "select dptnom from isskdepto ",
              " where dptsgl = ? "
  prepare pcty08g00003 from l_sql
  declare ccty08g00003 cursor for pcty08g00003

  let l_sql = "select dptsgl from isskfunc ",
              " where empcod = ? ",
              "   and funmat = ? ",
              "   and usrtip = ? "

  prepare pcty08g00004  from l_sql
  declare ccty08g00004  cursor for pcty08g00004

  let m_prep_sql = true

end function

#------------------------------------#
 function cty08g00_nome_func(lr_parm)
#------------------------------------#
 define lr_parm        record
        empcod         like isskfunc.empcod,
        funmat         like isskfunc.funmat,
        usrtip         like isskfunc.usrtip
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        funnom         like isskfunc.funnom
 end record

 define l_msg          char(60)
 if m_prep_sql is null or m_prep_sql <> true then
    call cty08g00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.empcod is null or
    lr_parm.funmat is null or
    lr_parm.usrtip is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametros nulos"
    return lr_retorno.*
 end if

 open ccty08g00001  using lr_parm.*
 whenever error continue
 fetch ccty08g00001 into  lr_retorno.funnom
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Funcionario nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccty08g00001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em isskfunc"
       display l_msg
       let l_msg = " cty08g00_nome_func() / ",lr_parm.empcod, " / ",
                                              lr_parm.funmat, " / ",
                                              lr_parm.usrtip
       display l_msg
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccty08g00001
 return lr_retorno.*
end function

#-------------------------------------#
 function cty08g00_nivel_func(lr_parm)
#-------------------------------------#
 define lr_parm        record
        usrtip         like isskfunc.usrtip,
        empcod         like isskfunc.empcod,
        usrcod         like isskfunc.funmat,
        sissgl         like issmnivnovo.sissgl
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        acsnivcod      like issmnivnovo.acsnivcod
 end record

 define l_msg          char(60)
 if m_prep_sql is null or m_prep_sql <> true then
    call cty08g00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.usrtip is null or
    lr_parm.empcod is null or
    lr_parm.usrcod is null or
    lr_parm.sissgl is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametros nulos"
    return lr_retorno.*
 end if

 open ccty08g00002 using lr_parm.*
 whenever error continue
 fetch ccty08g00002 into lr_retorno.acsnivcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Nivel de acesso nao encontrado"
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccty08g00002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em issmnivnovo"
       display l_msg
       let l_msg = " cty08g00_nivel_func() / ",lr_parm.usrtip, " / ", lr_parm.empcod, " / ",
                                               lr_parm.usrcod, " / ", lr_parm.sissgl
       display l_msg
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccty08g00002
 return lr_retorno.*
end function

#------------------------------------------#
 function cty08g00_descricao_depto(lr_parm)
#------------------------------------------#
 define lr_parm record
    dptsgl like isskdepto.dptsgl
 end record
 define lr_retorno record
    erro     smallint
   ,mensagem char(60)
   ,dptnom   like isskdepto.dptnom
 end record

 define l_msg char(60)
 if m_prep_sql is null or m_prep_sql <> true then
    call cty08g00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.dptsgl is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametros nulos"
    return lr_retorno.*
 end if

 open ccty08g00003 using lr_parm.dptsgl
 whenever error continue
 fetch ccty08g00003 into lr_retorno.dptnom
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Departamento nao cadastrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccty08g00003 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em isskdepto"
       display l_msg
       let l_msg = " cty08g00_descricao_depto() / ",lr_parm.dptsgl
       display l_msg
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccty08g00003
 return lr_retorno.*
end function

#------------------------------------#
 function cty08g00_depto_func(lr_parm)
#------------------------------------#
 define lr_parm        record
        empcod         like isskfunc.empcod,
        funmat         like isskfunc.funmat,
        usrtip         like isskfunc.usrtip
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        dptsgl         like isskfunc.dptsgl
 end record

 define l_msg          char(60)
 if m_prep_sql is null or m_prep_sql <> true then
    call cty08g00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.empcod is null or
    lr_parm.funmat is null or
    lr_parm.usrtip is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametros nulos"
    return lr_retorno.*
 end if

 open ccty08g00004  using lr_parm.*
 whenever error continue
 fetch ccty08g00004 into  lr_retorno.dptsgl
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Funcionario nao encontrado "
    else
       let lr_retorno.erro = 3
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em isskfunc"
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccty08g00004
 return lr_retorno.*
end function
